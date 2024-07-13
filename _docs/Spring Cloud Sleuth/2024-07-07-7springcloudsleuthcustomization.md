---
title: Spring Cloud Sleuth customization
category: Spring Cloud Sleuth
order: 7
permalink: /Spring%20Cloud%20Sleuth/sleuth-customization/
description: 스프링 클라우드 슬루스의 다양한 통합 기능들과 이를 커스텀 하는 방법
image: ./../../images/springcloud/logo.jpeg
lastmod: 2024-07-13T14:47:00+09:00
comments: true
originalRefName: 스프링 클라우드 슬루스
originalRefLink: https://docs.spring.io/spring-cloud-sleuth/docs/3.1.11/reference/htmlsingle/#howto
originalVersion: 3.1.11
---
<script>defaultLanguages = ['p6spy-maven']</script>

이번 섹션에선 Spring Cloud Sleuth의 다양한 기능들을 커스텀하는 방법을 설명한다. Spring Cloud Sleuth가 생성하는 span, 태그, 이벤트 목록은 [부록](../appendix/#631-spring-cloud-sleuth-spans)을 참고해라.

### 목차

- [6.1. Apache Kafka](#61-apache-kafka)
- [6.2. Asynchronous Communication](#62-asynchronous-communication)
  + [6.2.1. `@Async` Annotated methods](#621-async-annotated-methods)
  + [6.2.2. `@Scheduled` Annotated Methods](#622-scheduled-annotated-methods)
  + [6.2.3. Executor, ExecutorService, and ScheduledExecutorService](#623-executor-executorservice-and-scheduledexecutorservice)
    * [Customization of Executors](#customization-of-executors)
- [6.3. HTTP Client Integration](#63-http-client-integration)
  + [6.3.1. Synchronous Rest Template](#631-synchronous-rest-template)
  + [6.3.2. Asynchronous Rest Template](#632-asynchronous-rest-template)
    * [Multiple Asynchronous Rest Templates](#multiple-asynchronous-rest-templates)
    * [Troubleshooting Async Configuration Issues](#troubleshooting-async-configuration-issues)
    * [`WebClient`](#webclient)
    * [Traverson](#traverson)
    * [Apache `HttpClientBuilder` and `HttpAsyncClientBuilder`](#apache-httpclientbuilder-and-httpasyncclientbuilder)
    * [Netty `HttpClient`](#netty-httpclient)
    * [`UserInfoRestTemplateCustomizer`](#userinforesttemplatecustomizer)
- [6.4. HTTP Server Integration](#64-http-server-integration)
  + [6.4.1. HTTP Filter](#641-http-filter)
  + [6.4.2. Async Servlet support](#642-async-servlet-support)
  + [6.4.3. WebFlux support](#643-webflux-support)
  + [6.4.4. Reactor Netty HttpServer](#644-reactor-netty-httpserver)
- [6.5. Messaging](#65-messaging)
  + [6.5.1. Spring Integration](#651-spring-integration)
    * [Spring Integration Customization](#spring-integration-customization)
    * [Customizing messaging spans](#customizing-messaging-spans)
  + [6.5.2. Spring Cloud Function and Spring Cloud Stream](#652-spring-cloud-function-and-spring-cloud-stream)
  + [6.5.3. Spring RabbitMq](#653-spring-rabbitmq)
  + [6.5.4. Spring Kafka](#654-spring-kafka)
  + [6.5.5. Spring Kafka Streams](#655-spring-kafka-streams)
  + [6.5.6. Spring JMS](#656-spring-jms)
- [6.6. OpenFeign](#66-openfeign)
- [6.7. OpenTracing](#67-opentracing)
- [6.8. Quartz](#68-quartz)
- [6.9. Reactor](#69-reactor)
- [6.10. Redis](#610-redis)
  + [6.10.1. Redis With Legacy Brave Only Support](#6101-redis-with-legacy-brave-only-support)
- [6.11. Runnable and Callable](#611-runnable-and-callable)
- [6.12. RPC](#612-rpc)
  + [6.12.1. Dubbo RPC support](#6121-dubbo-rpc-support)
  + [6.12.2. gRPC](#6122-grpc)
    * [Variant 1](#variant-1)
    * [Variant 2](#variant-2)
- [6.13. RxJava](#613-rxjava)
- [6.14. Spring Cloud CircuitBreaker](#614-spring-cloud-circuitbreaker)
- [6.15. Spring Cloud Config Server](#615-spring-cloud-config-server)
- [6.16. Spring Cloud Deployer](#616-spring-cloud-deployer)
- [6.17. Spring RSocket](#617-spring-rsocket)
- [6.18. Spring Batch](#618-spring-batch)
- [6.19. Spring Cloud Task](#619-spring-cloud-task)
- [6.20. Spring Tx](#620-spring-tx)
- [6.21. Spring Security](#621-spring-security)
- [6.22. R2DBC](#622-r2dbc)
- [6.23. Spring Vault](#623-spring-vault)
- [6.24. Spring Tomcat](#624-spring-tomcat)
- [6.25. Spring Data Cassandra](#625-spring-data-cassandra)
- [6.26. Spring JDBC](#626-spring-jdbc)
- [6.27. MongoDB](#627-mongodb)
- [6.28. Spring Session](#628-spring-session)
- [6.29. Kotlin Coroutines](#629-kotlin-coroutines)
- [6.30. Prometheus Exemplars](#630-prometheus-exemplars)

---

## 6.1. Apache Kafka

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

Sleuth는 카프카 클라이언트(`KafkaProducer`, `KafkaConsumer`)에 데코레이터 패턴을 적용해 이벤트를 생산<sup>produce</sup>하거나 컨슘<sup>consume</sup>할 때마다 span을 생성한다. 이 기능은 `spring.sleuth.kafka.enabled` 값을 `false`로 설정하면 비활성화할 수 있다.

> 이 데코레이터 패턴을 Sleuth의 자동 설정으로 적용하려면 `Producer` 또는 `Consumer`를 빈으로 등록해야 한다. 그리고 이 빈들을 주입할 때는 타입을 `Producer` 또는 `Consumer`로 지정해야 한다 (e.g. `KafkaProducer`가 아니라).

프로젝트 리액터의 경우, 정의된 모든 `KafkaReceiver<K,V>` 타입 빈을 `TracingKafkaReceiver<K,V>`로 감싼다. 이렇게 하면 수신하는 요소마다 자체 트레이싱<sup>tracing</sup> 컨텍스트가 전파되어 별도의 퍼블리셔가 생성된다. 리액터 계측<sup>instrumentation</sup>과 함께 사용하면 span의 컨텍스트에 접근할 수 있다.

부모 컨텍스트가 없는 경우, 새 trace-id를 사용해 자식 span만 생성한다.

```java
@Bean
KafkaReceiver<K, V> reactiveKafkaReceiver(ReceiverOptions<K,V> options) {
    return KafkaReceiver.create(options);
}
```

이후 요소들을 수신하기 시작하면 컨텍스트를 처리할 수 있다.

```java
@Bean
DisposableBean exampleRunningConsumer(KafkaReceiver<String, String> receiver){
    reactor.core.Disposable disposable = receiver.receive()
        //If you need to read context you can for example use deferContextual
        .flatMap(record -> Mono.deferContextual(context -> Mono.just(record)))
        .doOnNext(record -> log.info("I will be coorelated to the child span created with parent context from kafka record"))
        .subscribe(record -> record.receiverOffset().acknowledge());

    return disposable::dispose;
}
```

---

## 6.2. Asynchronous Communication

이번 섹션에선 Spring Cloud Sleuth에서 비동기 통신을 커스텀하는 방법에 대해 설명한다.

### 6.2.1. `@Async` Annotated methods

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

Spring Cloud Sleuth는 비동기 통신과 관련된 구성 요소들을 계측<sup>instrumentation</sup>하기 때문에, 트레이싱<sup>tracing</sup> 정보는 여러 스레드를 오갈 때도 잘 전달된다. 이 동작은 `spring.sleuth.async.enabled` 값을 `false`로 설정하면 비활성화할 수 있다.

메소드 위에 `@Async` 애노테이션을 선언하면, 기존 Span은 자동으로 다음과 같이 변경된다:

- 메소드 위에 `@SpanName` 애노테이션을 선언한 경우, 이 애노테이션의 value를 Span의 이름으로 사용한다.
- 메소드 위에 `@SpanName` 애노테이션이 없다면, `@Async` 애노테이션을 선언한 메소드명을 Span의 이름으로 사용한다.
- 해당 클래스명과 메소드명을 태그로 추가한다.

기존 span을 수정하는 것이기 때문에 원래 이름을 유지하고 싶다면 (e.g. HTTP 요청을 받아 span이 만들어진 경우 등) , `@Async`를 선언한 메소드를 `@NewSpan` 애노테이션으로 감싸거나 span을 직접 새로 만들어야 한다.

### 6.2.2. `@Scheduled` Annotated Methods

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

Spring Cloud Sleuth는 스케줄링된 메소드가 실행될 때도 이를 계측<sup>instrumentation</sup>하기 때문에, 트레이싱<sup>tracing</sup> 정보는 여러 스레드를 오갈 때도 잘 전달된다. 이 동작은 `spring.sleuth.scheduled.enabled` 값을 `false`로 설정하면 비활성화할 수 있다.

메소드 위에 `@Scheduled` 애노테이션을 선언하면, 다음과 같은 span을 자동으로 생성해준다:

- 애노테이션을 선언한 메소드 이름을 span 이름으로 사용한다
- 해당 클래스명과 메소명을 태그로 추가한다.

`@Scheduled`를 선언한 클래스 중 span을 만들고 싶지 않은 클래스도 있다면, `spring.sleuth.scheduled.skipPattern`을 해당 클래스의 풀 네임<sup>fully qualified name</sup>과 매칭되는 정규식으로 설정해주면 된다.

### 6.2.3. Executor, ExecutorService, and ScheduledExecutorService

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

Sleuth는 `LazyTraceExecutor`, `TraceableExecutorService`, `TraceableScheduledExecutorService`를 제공한다. 이 구현체들은 새 태스크를 제출<sup>submit</sup>하거나, 실행하거나, 스케줄링될 때마다 span을 생성한다.

다음은 `CompletableFuture`로 코드를 작성하면서 `TraceableExecutorService`로 트레이싱<sup>tracing</sup> 정보를 전달하는 예시다:

```java
CompletableFuture<Long> completableFuture = CompletableFuture.supplyAsync(() -> {
    // perform some logic
    return 1_000_000L;
}, new TraceableExecutorService(beanFactory, executorService,
        // 'calculateTax' explicitly names the span - this param is optional
        "calculateTax"));
```

> Sleuth는 그 자체로는 `parallelStream()`과 동작하지 않는다. 병렬 스트림을 통해 트레이싱<sup>tracing</sup> 정보를 전파하고 싶을 땐, 앞에서 보여준 대로 `supplyAsync(...)`를 통해 구현해야 한다.

`Executor` 인터페이스를 구현한 빈 중에 span을 만들고 싶지 않은 게 있다면, `spring.sleuth.async.ignored-beans` 프로퍼티에 해당 빈들의 이름을 지정하면 된다.

이 동작은 `spring.sleuth.async.enabled` 값을 `false`로 설정하면 비활성화할 수 있다.

#### Customization of Executors

간혹 `AsyncExecutor`의 커스텀 인스턴스를 설정해야 하는 경우가 있다. 커스텀 `Executor`를 설정하는 방법은 아래 예제를 참고해라:

```java
@Configuration(proxyBeanMethods = false)
@EnableAutoConfiguration
@EnableAsync
// add the infrastructure role to ensure that the bean gets auto-proxied
@Role(BeanDefinition.ROLE_INFRASTRUCTURE)
public static class CustomExecutorConfig extends AsyncConfigurerSupport {

    @Autowired
    BeanFactory beanFactory;

    @Override
    public Executor getAsyncExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        // CUSTOMIZE HERE
        executor.setCorePoolSize(7);
        executor.setMaxPoolSize(42);
        executor.setQueueCapacity(11);
        executor.setThreadNamePrefix("MyExecutor-");
        // DON'T FORGET TO INITIALIZE
        executor.initialize();
        return new LazyTraceExecutor(this.beanFactory, executor);
    }

}
```

> 이 설정을 빈 후처리<sup>post process</sup> 중에 처리할 수 있도록, `@Configuration` 클래스에 `@Role(BeanDefinition.ROLE_INFRASTRUCTURE)`를 추가하는 것을 잊지 말자.

---

## 6.3. HTTP Client Integration

이 섹션에서 설명하는 기능들은 `spring.sleuth.web.client.enabled` 프로퍼티를 `false`와 같이 설정해 비활성화할 수 있다.

### 6.3.1. Synchronous Rest Template

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

Sleuth는 `RestTemplate` 인터셉터를 주입해 요청에 모든 트레이싱<sup>tracing</sup> 정보가 전달되도록 만든다. 호출이 이루어질 때마다 새 span이 생성되고, 이 span은 응답을 받자마자 닫힌다. 동기식<sup>synchronous</sup> `RestTemplate` 기능들을 끄려면 `spring.sleuth.web.client.enabled`를 `false`로 설정해라.

> 인터셉터를 주입할 수 있으려면 `RestTemplate`을 빈으로 등록해야 한다. `new` 키워드로 `RestTemplate` 인스턴스를 직접 생성했다면 요청을 계측<sup>instrumentation</sup>하지 **않는다**.

### 6.3.2. Asynchronous Rest Template

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

> Sleuth `2.0.0` 버전부터는 더 이상 `AsyncRestTemplate` 타입 빈을 등록하지 않는다. `AsyncRestTemplate` 빈이 필요하다면 직접 만들어야 한다. 그러면 xsleuth에서 알아서 요청을 계측<sup>instrumentation</sup>해줄 거다.

`AsyncRestTemplate` 관련 기능들을 끄려면 `spring.sleuth.web.async.client.enabled`를 `false`로 설정해라. 디폴트 `TraceAsyncClientHttpRequestFactoryWrapper`를 생성하지 않으려면 `spring.sleuth.web.async.client.factory.enabled`를 `false`로 설정해라. `AsyncRestClient`를 아예 생성하지 않으려면 `spring.sleuth.web.async.client.template.enabled`를 `false`로 설정해라.

#### Multiple Asynchronous Rest Templates

간혹 비동기<sup>asynchronous</sup> 비동기 RestTemplate의 구현체가 여러 개 필요한 경우가 있다. 다음은 이럴 때 필요한 커스텀 `AsyncRestTemplate`을 설정하는 예시다:

```java
@Configuration(proxyBeanMethods = false)
public static class TestConfig {

    @Bean(name = "customAsyncRestTemplate")
    public AsyncRestTemplate traceAsyncRestTemplate() {
        return new AsyncRestTemplate(asyncClientFactory(), clientHttpRequestFactory());
    }

    private ClientHttpRequestFactory clientHttpRequestFactory() {
        ClientHttpRequestFactory clientHttpRequestFactory = new CustomClientHttpRequestFactory();
        // CUSTOMIZE HERE
        return clientHttpRequestFactory;
    }

    private AsyncClientHttpRequestFactory asyncClientFactory() {
        AsyncClientHttpRequestFactory factory = new CustomAsyncClientHttpRequestFactory();
        // CUSTOMIZE HERE
        return factory;
    }

}
```

#### Troubleshooting Async Configuration Issues

Sleuth는 빈 포스트 프로세서<sup>Bean Post Processor (BPP)</sup>를 사용해 `Executor`를 수정하기 때문에, 설정한 `Executor` 타입 대신 트레이스<sup>trace</sup>를 지원하는 sleuth의 executor 타입이 반환될 수 있다. 이로 인해 다음과 유사한 예외가 발생하기도 한다.

```java
12:12:49.606 [main] DEBUG org.springframework.context.annotation.AnnotationConfigApplicationContext - Closing org.springframework.context.annotation.AnnotationConfigApplicationContext@2401f4c3, started on Wed Jan 19 12:12:49 GMT 2022
Exception in thread "main" org.springframework.beans.factory.BeanNotOfRequiredTypeException: Bean named 'exampleConfigurer' is expected to be of type 'com.example.demo.Gh29151Application$Example' but was actually of type 'org.springframework.cloud.sleuth.instrument.async.LazyTraceAsyncCustomizer'
```

이러한 예외를 만났을 때 해결책은 다음과 같다:

- sleuth async 설정을 비활성화한다.
- executor를 계측<sup>instrumentation</sup>할 수 있도록, 해당 executor를 지원하는 sleuth의 전용 executor 클래스를 수동으로 설정한다.

**예제**

```properties
spring.sleuth.async.enabled=false
```

**configuration 예제**

```java
@Configuration
@EnableAsync
public class AsyncConfiguration implements AsyncConfigurer {

    private final BeanFactory beanFactory;

    public AsyncConfiguration(BeanFactory beanFactory) {
        this.beanFactory = beanFactory;
    }

    @Override
    @Bean("AsyncTaskExecutor")
    public Executor getAsyncExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.initialize();
        return new LazyTraceThreadPoolTaskExecutor(beanFactory, executor);
    }
}
```

더 자세한 정보는 이 [이슈](https://github.com/spring-cloud/spring-cloud-sleuth/issues/2100)에서 확인할 수 있다.

#### `WebClient`

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

Sleuth는 `ExchangeFilterFunction` 구현체를 주입하는데, 이 클래스는 span을 생성하고, span을 잘 관리하고 있다가 on-success/on-error 콜백을 통해 닫아준다.

이 기능을 끄려면 `spring.sleuth.web.client.enabled` 프로퍼티를 `false`로 설정해라.

> 트레이싱 정보들을 계측<sup>instrumentation</sup>하려면 `WebClient`를 빈으로 등록해줘야 한다. `new` 키워드로 `WebClient` 인스턴스를 직접 생성하면 아무것도 계측<sup>instrumentation</sup>되지 **않는다**.

##### Logbook with WebClient

WebClient `org.zalando:logbook-spring-boot-webflux-autoconfigure`로 Logbook에 대한 지원을 추가하려면 아래 설정을 추가해야 한다. 이 통합 기능에 대한 자세한 내용은 [이 이슈](https://github.com/spring-cloud/spring-cloud-sleuth/issues/1690)에서 확인할 수 있다.

```java
@Configuration
@Import(LogbookWebFluxAutoConfiguration.class)
public class LogbookConfiguration {

    @Bean
    public LogstashLogbackSink logbackSink(final HttpLogFormatter formatter) {
        return new LogstashLogbackSink(formatter);
    }

    @Bean
    public CorrelationId correlationId(final Tracer tracer) {
        return request -> requireNonNull(requireNonNull(tracer.currentSpan())).context().traceId();
    }

    @Bean
    ReactorNettyHttpTracing reactorNettyHttpTracing(final HttpTracing httpTracing) {
        return ReactorNettyHttpTracing.create(httpTracing);
    }

    @Bean
    NettyServerCustomizer nettyServerCustomizer(final Logbook logbook,
            final ReactorNettyHttpTracing reactorNettyHttpTracing) {
        return server -> reactorNettyHttpTracing.decorateHttpServer(
                server.doOnConnection(conn -> conn.addHandlerFirst(new LogbookServerHandler(logbook))));
    }

    @Bean
    WebClient webClient(final Logbook logbook, final ReactorNettyHttpTracing reactorNettyHttpTracing) {
        return WebClient.builder()
                .clientConnector(new ReactorClientHttpConnector(reactorNettyHttpTracing.decorateHttpClient(HttpClient
                        .create().doOnConnected(conn -> conn.addHandlerLast(new LogbookClientHandler(logbook))))))
                .build();
    }

}
```

#### Traverson

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

[Traverson](https://docs.spring.io/spring-hateoas/docs/current/reference/html/#client.traverson) 라이브러리를 사용하는 경우, `RestTemplate` 빈을 가져와 Traverson 객체에 주입해줄 수 있다. 이 `RestTemplate`은 이미 인터셉터가 설정돼 있기 때문에, `RestTemplate`을 사용할 때와 동일하게 그대로 클라이언트를 추적할 수 있다. 다음은 `RestTemplate`을 주입받는 방법을 보여주는 슈도 코드다:

```java
@Autowired RestTemplate restTemplate;

Traverson traverson = new Traverson(URI.create("https://some/address"),
    MediaType.APPLICATION_JSON, MediaType.APPLICATION_JSON_UTF8).setRestOperations(restTemplate);
// use Traverson
```

#### Apache `HttpClientBuilder` and `HttpAsyncClientBuilder`

이 기능은 Brave 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

Sleuth는 `HttpClientBuilder`와 `HttpAsyncClientBuilder`를 계측<sup>instrumentation</sup>하기 때문에, 요청이 들어오면 트레이싱<sup>tracing</sup> 컨텍스트가 주입된다.

이 기능을 끄려면 `spring.sleuth.web.client.enabled`를 `false`로 설정해라.

#### Netty `HttpClient`

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

Sleuth는 Netty의 `HttpClient`를 계측<sup>instrumentation</sup>한다.

이 기능을 끄려면 `spring.sleuth.web.client.enabled`를 `false`로 설정해라.

> 요청을 계측<sup>instrumentation</sup>하려면 `HttpClient`를 빈으로 등록해야 한다. `new` 키워드를 사용해 `HttpClient` 인스턴스를 직접 생성하면 아무것도 계측<sup>instrumentation</sup>되지 **않는다**.

#### `UserInfoRestTemplateCustomizer`

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

Sleuth는 Spring Security의 `UserInfoRestTemplateCustomizer`를 계측한다.

이 기능을 끄려면 `spring.sleuth.web.client.enabled`를 `false`로 설정해라.

---

## 6.4. HTTP Server Integration

이 섹션에서 설명하는 기능들은 `spring.sleuth.web.enabled` 프로퍼티를 `false`와 같이 설정하면 비활성화할 수 있다.

### 6.4.1. HTTP Filter

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

들어온 요청 중 샘플링하는 모든 요청은 `TracingFilter`를 통해 Span을 생성한다. `spring.sleuth.web.skipPattern` 프로퍼티를 설정하면 건너뛸 URI를 지정할 수 있다. 클래스패스에 `ManagementServerProperties`가 있는 경우, 지정한 skip 패턴에 `contextPath`의 값도 추가된다. Sleuth의 디폴트 skip 패턴은 그대로 사용하면서 별도 패턴을 추가로 넣고 싶다면, `spring.sleuth.web.additionalSkipPattern`으로 원하는 패턴을 전달해라.

기본적으로 스프링 부트 액추에이터 엔드포인트들은 전부 skip 패턴에 자동으로 추가된다. 이 동작을 원치 않는다면 `spring.sleuth.web.ignore-auto-configured-skip-patterns`를 `true`로 설정해라.

`TracingFilter`를 등록하는 순서를 변경하려면, `spring.sleuth.web.filter-order` 프로퍼티를 수정해라.

처리되지 않은 예외<sup>uncaught exception</sup>를 로깅하는 필터를 비활성화하려면, `spring.sleuth.web.exception-throwing-filter-enabled` 프로퍼티를 비활성화하면 된다.

### 6.4.2. Async Servlet support

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

컨트롤러가 `Callable`이나 `WebAsyncTask`를 반환하는 경우 Spring Cloud Sleuth는 span을 새로 생성하지 않고 기존 span을 계속 이어간다.

### 6.4.3. WebFlux support

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

들어온 요청 중 샘플링하는 모든 요청은 `TraceWebFilter`를 통해 Span을 생성한다. 이때 Span의 이름은 `http:` + 요청이 전송된 경로를 사용한다. 예를 들어 요청이 `/this/that`으로 전송된 경우에 Span의 이름은 `http:/this/that`이다. `spring.sleuth.web.skipPattern` 프로퍼티를 설정하면 건너뛸 URI를 지정할 수 있다. 클래스패스에 `ManagementServerProperties`가 있는 경우, 지정한 skip 패턴에 `contextPath`의 값도 추가된다. Sleuth의 디폴트 skip 패턴은 그대로 사용하면서 별도 패턴을 추가로 넣고 싶다면, `spring.sleuth.web.additionalSkipPattern`으로 원하는 패턴을 전달해라.

성능이나 컨텍스트 전파<sup>propagation</sup> 측면에서 효율을 끌어올리려면, `spring.sleuth.reactor.instrumentation-type`을 `MANUAL`로 변경하는 것이 좋다. 스코프 내에 있는 span으로 코드를 실행하려면 `WebFluxSleuthOperators.withSpanInScope`를 호출하면 된다. 예를 들어:

```java
@GetMapping("/simpleManual")
public Mono<String> simpleManual() {
    return Mono.just("hello").map(String::toUpperCase).doOnEach(WebFluxSleuthOperators
            .withSpanInScope(SignalType.ON_NEXT, signal -> log.info("Hello from simple [{}]", signal.get())));
}
```

트레이싱<sup>tracing</sup> 필터를 등록하는 순서를 변경하려면, `spring.sleuth.web.filter-order` 프로퍼티를 수정해라.

### 6.4.4. Reactor Netty HttpServer

Reactor Netty를 사용 중인데 액세스 로그를 계측<sup>instrumentation</sup>하고 싶다면, `io.projectreactor.netty:reactor-netty-http-brave`를 추가해야 한다 (Brave Tracer에서만 동작한다). 또한 프로젝트에 아래 설정을 추가해라:

```java
@Configuration(proxyBeanMethods = false)
class TraceNettyConfig {

    @Bean
    NettyServerCustomizer traceNettyServerCustomizer(ObjectProvider<HttpTracing> tracing) {
        return server -> ReactorNettyHttpTracing.create(tracing.getObject()).decorateHttpServer(server);
    }
}
```

---

## 6.5. Messaging

이 섹션에서 설명하는 기능들은 `spring.sleuth.messaging.enabled` 프로퍼티를 `false`와 같이 설정하면 비활성화할 수 있다.

### 6.5.1. Spring Integration

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

Spring Cloud Sleuth는 [Spring Integration](https://projects.spring.io/spring-integration/)과 통합된다. 즉, 이벤트를 발행<sup>publish</sup>하고 구독<sup>subscribe</sup>할 때마다 span을 생성한다. Spring Integration 계측<sup>instrumentation</sup> 기능을 비활성화하려면, `spring.sleuth.integration.enabled`를 `false`로 설정해라.

트레이싱<sup>tracing</sup>에 포함시킬 채널명을 직접 명시하고 싶다면, `spring.sleuth.integration.patterns`에 원하는 패턴을 제공하면 된다. 기본적으로는 `hystrixStreamOutput` 채널을 제외한 모든 채널을 추적한다.

> `Executor`를 사용해 Spring Integration의 `IntegrationFlow`을 빌드하는 경우, 트레이싱<sup>tracing</sup> 관련 코드가 없는 본래 `Executor`를 사용해야 한다. `TraceableExecutorService`로 Spring Integration Executor 채널을 감싸게 되면<sup>decorate</sup>, span을 닫는 동작과 관련해서 에러가 발생한다.

메시지 헤더에서 트레이싱<sup>tracing</sup> 컨텍스트를 읽고 쓰는 방식을 커스텀하고 싶다면, 아래 타입으로 빈을 등록해주기만 하면 된다:

- `Propagator.Setter<MessageHeaderAccessor>` - 메시지에 헤더를 쓰는 용도
- `Propagator.Getter<MessageHeaderAccessor>` - 메시지에서 헤더를 읽어들이는 용도

#### Spring Integration Customization

#### Customizing messaging spans

span의 디폴트 이름과 태그를 변경하려면 `MessageSpanCustomizer` 타입 빈만 등록해주면 된다. 아니면 기존 `DefaultMessageSpanCustomizer`를 상속해 기존 동작을 재정의하는 방법도 있다.

```java
@Component
  class MyMessageSpanCustomizer extends DefaultMessageSpanCustomizer {
      @Override
      public Span customizeHandle(Span spanCustomizer,
              Message<?> message, MessageChannel messageChannel) {
          return super.customizeHandle(spanCustomizer, message, messageChannel)
                  .name("changedHandle")
                  .tag("handleKey", "handleValue")
                  .tag("channelName", channelName(messageChannel));
      }

      @Override
      public Span.Builder customizeSend(Span.Builder builder,
              Message<?> message, MessageChannel messageChannel) {
          return super.customizeSend(builder, message, messageChannel)
                  .name("changedSend")
                  .tag("sendKey", "sendValue")
                  .tag("channelName", channelName(messageChannel));
      }
  }
```

### 6.5.2. Spring Cloud Function and Spring Cloud Stream

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

Spring Cloud Sleuth는 Spring Cloud Function를 계측<sup>instrumentation</sup>할 수 있다. Spring Cloud Stream은 Spring Cloud Function을 사용하기 때문에, 특별한 설정 없이도 메시지 처리를 바로 계측<sup>instrumentation</sup>할 수 있다.

이땐 파라미터로 `Message`를 받는  `Function`이나 `Consumer`, 또는 `Supplier`를 제공하면 된다 (e.g. `Function<Message<String>, Message<Integer>>`). `Message` 타입을 받지 **않는** 경우 메시지 처리 동작을 계측<sup>instrumentation</sup>하지 **않는다**.

`Consumer<Flux<Message<?>>>`처럼 리액티브 타입을 사용한다면, `.subscribe()`를 호출하기 전에 span을 수동으로 닫고 컨텍스트를 비워야 한다는 점을 기억해두자. 예를 들어:

```java
@Bean
    Consumer<Flux<Message<String>>> channel(Tracer tracer) {
        // For the reactive consumer remember to call "subscribe()" at the end, otherwise
        // you'll get the "Dispatcher has no subscribers" error
        return i -> i
                    .doOnNext(s -> log.info("HELLO"))
                    // You must finish the span yourself and clear the tracing context like presented below.
                    // Otherwise you will be missing out the span that wraps the function execution.
                    .doOnNext(s -> {
                        tracer.currentSpan().end();
                        tracer.withSpan(null);
                    })
                    .subscribe();
    }
}
```

NOTE: Sleuth가 어떤 `Supplier`와도 함께 동작할 수 있으려면 (e.g. `Supplier<Flux<Message<String>>>`), `spring.sleuth.integration.enabled`를 `true`로 설정해 Spring Integration 기반 계측<sup>instrumentation</sup>으로 폴백해야 한다.

Spring Cloud Stream 통합 기능은 `spring.sleuth.function.enabled`를 `false`로 설정해 비활성화할 수 있다.

Spring Cloud Stream의 리액티브 메시징 컨텍스트 내에서 span의 수명 주기를 전부 다 제어하고 싶다면, Spring Cloud Stream 통합을 비활성화하고 유틸리티 클래스 `MessagingSleuthOperators`를 활용해야 한다는 점을 기억해두자. `MessagingSleuthOperators`를 사용하면 입출력 메시지를 조작해서, 트레이싱<sup>tracing</sup> 컨텍스트를 계속 이어가고 트레이싱<sup>tracing</sup> 컨텍스트 내에서 사용자 정의 코드를 실행할 수 있다.

```java
class SimpleReactiveManualFunction implements Function<Flux<Message<String>>, Flux<Message<String>>> {

    private static final Logger log = LoggerFactory.getLogger(SimpleReactiveFunction.class);

    private final BeanFactory beanFactory;

    SimpleReactiveManualFunction(BeanFactory beanFactory) {
        this.beanFactory = beanFactory;
    }

    @Override
    public Flux<Message<String>> apply(Flux<Message<String>> input) {
        return input.map(message -> (MessagingSleuthOperators.asFunction(this.beanFactory, message))
                .andThen(msg -> MessagingSleuthOperators.withSpanInScope(this.beanFactory, msg, stringMessage -> {
                    log.info("Hello from simple manual [{}]", stringMessage.getPayload());
                    return stringMessage;
                })).andThen(msg -> MessagingSleuthOperators.afterMessageHandled(this.beanFactory, msg, null))
                .andThen(msg -> MessageBuilder.createMessage(msg.getPayload().toUpperCase(), msg.getHeaders()))
                .andThen(msg -> MessagingSleuthOperators.handleOutputMessage(this.beanFactory, msg)).apply(message));
    }

}
```

### 6.5.3. Spring RabbitMq

이 기능은 Brave 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

Sleuth는 `RabbitTemplate`을 계측<sup>instrumentation</sup>해서 메시지에 트레이싱<sup>tracing</sup> 헤더를 주입한다.

이 기능을 끄러면 `spring.sleuth.messaging.rabbit.enabled`를 `false`로 설정해라.

### 6.5.4. Spring Kafka

이 기능은 Brave 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

Sleuth는 Spring Kafka의 `ProducerFactory`와 `ConsumerFactory`를 계측<sup>instrumentation</sup>해서 기존 Spring Kafka의 `Producer`와 `Consumer`에 트레이싱<sup>tracing</sup> 헤더를 주입해준다.

이 기능을 그러면 `spring.sleuth.messaging.kafka.enabled`를 `false`로 설정해라.

### 6.5.5. Spring Kafka Streams

이 기능은 Brave 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

Sleuth는 `KafkaStreams` `KafkaClientSupplier`를 계측<sup>instrumentation</sup>해서 `Producer`와 `Consumer`들에 트레이싱<sup>tracing</sup> 헤더를 주입해준다. `KafkaStreamsTracing` 빈은 `TransformerSupplier`와 `ProcessorSupplier` 메소드들을 통해 다른 것들을 추가적으로 계측<sup>instrumentation</sup>해준다.

이 기능을 끄러면 `spring.sleuth.messaging.kafka.streams.enabled`를 `false`로 설정해라.

### 6.5.6. Spring JMS

이 기능은 Brave 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

Sleuth는 `JmsTemplate`을 계측<sup>instrumentation</sup>해서 메시지에 트레이싱<sup>tracing</sup> 헤더를 주입한다. 또한 컨슈머 측에서 메소드 위에 `@JmsListener` 애노테이션을 선언한 코드도 지원한다.

이 기능을 끄러면 `spring.sleuth.messaging.jms.enabled`를 `false`로 설정해라.

> JMS에서 baggage 전파<sup>propagation</sup>는 지원하지 않는다.

---

## 6.6. OpenFeign

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

기본적으로 Spring Cloud Sleuth는 `TraceFeignClientAutoConfiguration`을 통해 Feign과의 통합을 지원한다. `spring.sleuth.feign.enabled`를 `false`로 설정하면 이 기능을 완전히 비활성화할 수 있다. 이렇게 설정하면 Feign 관련 계측<sup>instrumentation</sup> 로직은 실행되지 않는다.

Feign 계측<sup>instrumentation</sup> 동작 중 일부는 `FeignBeanPostProcessor`를 통해 수행된다. 이 동작은 `spring.sleuth.feign.processor.enabled`를 `false`로 설정면 비활성화할 수 있다. 이 프로퍼티를 `false`로 설정하면, Spring Cloud Sleuth는 커스텀 Feign 컴포넌트들은 계측<sup>instrumentation</sup>하지 않는다. 하지만 다른 디폴트 계측<sup>instrumentation</sup> 동작들은 전부 그대로 유지된다.

---

## 6.7. OpenTracing

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

Spring Cloud Sleuth는 [OpenTracing](https://opentracing.io/)과 호환된다. 클래스패스에 OpenTracing이 존재하면, OpenTracing `Tracer` 빈을 자동으로 등록한다. 이 기능을 비활성화하려면 `spring.sleuth.opentracing.enabled`를 `false`로 설정해라.

---

## 6.8. Quartz

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

Sleuth는 Quartz 스케줄러에 Job/Trigger 리스너를 추가하는 식으로 quartz job을 계측<sup>instrumentation</sup>한다.

이 기능을 끄려면 `spring.sleuth.quartz.enabled` 프로퍼티를 `false`로 설정해라.

---

## 6.9. Reactor

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

Sleuth는 다음과 같은 모드로 리액터 기반 애플리케이션을 계측<sup>instrumentation</sup>할 수 있으며, 이 모드들은 `spring.sleuth.reactor.instrumentation-type` 프로퍼티를 통해 변경할 수 있다:

- `DECORATE_QUEUES` - Sleuth는 Reactor의 새로운 [큐 래핑 메커니즘](https://github.com/reactor/reactor-core/pull/2566)을 이용해 (Reactor 3.4.3), Reactor가 스레드를 전환하는 방식을 계측<sup>instrumentation</sup>하고 있다. 이 방식은 성능에 미치는 영향이 적으면서 `ON_EACH`와 기능적으론 동일하다.
- `DECORATE_ON_EACH` - 모든 Reactor 연산자를 트레이스<sup>trace</sup> 코드로 래핑한다. 대부분의 케이스에서 트레이싱<sup>tracing</sup> 컨텍스트를 전달한다. 이 모드는 급격한 성능 저하를 초래할 수 있다.
- `DECORATE_ON_LAST` - 마지막 Reactor 연산자를 트레이스<sup>trace</sup> 코드로 래핑한다. 경우에 따라 트레이싱<sup>tracing</sup> 컨텍스트를 전달하기도 하고, 전달하지 않기도 하기 때문에, MDC 컨텍스트에 액세스하지 못할 수도 있다. 이 모드는 중간 정도의 성능 저하를 초래할 수 있다.
- `MANUAL` - 트레이싱<sup>tracing</sup> 컨텍스트를 전달하지 않고, 최소한의 영역만 건들여서 모든 Reactor를 래핑한다. 컨텍스트 전달 여부는 사용자가 결정한다.

이전 버전과의 호환성 때문에 현재 기본값은 `ON_EACH`이지만, `MANUAL` 계측<sup>instrumentation</sup>으로 마이그레이션해서 `WebFluxSleuthOperators`와 `MessagingSleuthOperators`를 최대한 활용하기를 권장한다. 성능이 상당히 개선될 거다. 예를 들어:

```java
@GetMapping("/simpleManual")
public Mono<String> simpleManual() {
    return Mono.just("hello").map(String::toUpperCase).doOnEach(WebFluxSleuthOperators
            .withSpanInScope(SignalType.ON_NEXT, signal -> log.info("Hello from simple [{}]", signal.get())));
}
```

리액터 지원을 비활성화하려면 `spring.sleuth.reactor.enabled` 프로퍼티를 `false`로 설정해라.

---

## 6.10. Redis

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

Sleuth는 Lettuce의 `Tracing` 코드를 사용한다. 클래스패스에 Brave가 있는 경우 `Tracing`을 `BraveTracing`으로 설정한다.

Redis 지원을 비활성화하려면 `spring.sleuth.redis.enabled` 프로퍼티를 `false`로 설정해라.

### 6.10.1. Redis With Legacy Brave Only Support

Brave만 지원하는 기능을 사용하려면 `spring.sleuth.redis.legacy.enabled`의 값을 `true`로 설정해야 한다. 이 설정은 Spring Cloud Sleuth 3.1.0 버전까지 제공되는 디폴트 메커니즘이다.

Sleuth에선 `tracing` 프로퍼티를 Lettuce `ClientResources` 인스턴스로 설정해 Lettuce에 내장된 Brave 트레이싱<sup>tracing</sup> 기능을 활성화한다.

Spring Cloud Sleuth는 트레이스<sup>trace</sup>를 지원하는 `ClientResources` 빈을 제공한다. 자체 구현체를 빈으로 사용하고 싶은 경우, 아래 예시와 같이 `ClientResourcesBuilderCustomizer`의 스트림으로 `ClientResources.Builder`를 커스텀하는 것을 잊지 말자:

```java
@Bean(destroyMethod = "shutdown")
DefaultClientResources myLettuceClientResources(ObjectProvider<ClientResourcesBuilderCustomizer> customizer) {
    DefaultClientResources.Builder builder = DefaultClientResources.builder();
    // setting up the builder manually
    customizer.stream().forEach(c -> c.customize(builder));
    return builder.build();
}
```

---

## 6.11. Runnable and Callable

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

특정 로직을 `Runnable`이나 `Callable`로 감싸는 경우, Sleuth가 제공하는 전용 클래스로 한 번 더 감싸면 된다. 다음은 `Runnable`을 사용하는 예시이다:

```java
Runnable runnable = new Runnable() {
    @Override
    public void run() {
        // do some work
    }

    @Override
    public String toString() {
        return "spanNameFromToStringMethod";
    }
};
// Manual `TraceRunnable` creation with explicit "calculateTax" Span name
Runnable traceRunnable = new TraceRunnable(this.tracer, spanNamer, runnable, "calculateTax");
```

다음은 `Callable` 사용 예시다:

```java
Callable<String> callable = new Callable<String>() {
    @Override
    public String call() throws Exception {
        return someLogic();
    }

    @Override
    public String toString() {
        return "spanNameFromToStringMethod";
    }
};
// Manual `TraceCallable` creation with explicit "calculateTax" Span name
Callable<String> traceCallable = new TraceCallable<>(tracer, spanNamer, callable, "calculateTax");
```

이렇게 코드를 작성하면 로직이 실행될 때마다 새 span이 생성되고 닫힌다.

---

## 6.12. RPC

이 기능은 Brave 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

Sleuth는 gRPC나 Dubbo와 같은 RPC 계측<sup>instrumentation</sup>의 기반이 되는 `RpcTracing` 빈을 자동으로 설정해준다.

RPC를 추적할 때 사용할 클라이언트/서버 샘플링 로직을 커스텀해야 하는 경우, `brave.sampler.SamplerFunction<RpcRequest>` 타입 빈을 등록하고, 클라이언트 샘플러의 경우 빈 이름을 `sleuthRpcClientSampler`로, 서버 샘플러의 경우 `sleuthRpcServerSampler`로 지정하기만 하면 된다.

간단히 빈을 주입받 싶으면 `@RpcClientSampler`와 `@RpcServerSampler` 애노테이션을 사용하면 되고, 빈의 이름은 각 애노테이션에 정의된 스태틱 문자열 `NAME` 필드를 참조하면 된다.

Ex. 다음은 초당 100개의 서버 요청 "GetUserToken"을 추적하는 샘플러다. 이때 health check 서비스에 대한 요청은 트레이스<sup>trace</sup>를 새로 시작하지 않는다. 다른 요청은 글로벌 샘플링 설정에 따른다.

```java
@Configuration(proxyBeanMethods = false)
    class Config {
  @Bean(name = RpcServerSampler.NAME)
  SamplerFunction<RpcRequest> myRpcSampler() {
      Matcher<RpcRequest> userAuth = and(serviceEquals("users.UserService"), methodEquals("GetUserToken"));
      return RpcRuleSampler.newBuilder().putRule(serviceEquals("grpc.health.v1.Health"), Sampler.NEVER_SAMPLE)
              .putRule(userAuth, RateLimitingSampler.create(100)).build();
  }
}
```

더 자세한 내용은 [github.com/openzipkin/brave/tree/master/instrumentation/rpc#sampling-policy](https://github.com/openzipkin/brave/tree/master/instrumentation/rpc#sampling-policy)를 참고해라.

### 6.12.1. Dubbo RPC support

Spring Cloud Sleuth는 Brave와의 통합을 통해 [Dubbo](https://dubbo.apache.org/)를 지원한다. `brave-instrumentation-dubbo` 의존성만 추가하면 된다:

```xml
<dependency>
    <groupId>io.zipkin.brave</groupId>
    <artifactId>brave-instrumentation-dubbo</artifactId>
</dependency>
```

또한 `dubbo.properties` 파일에 다음과 같이 설정을 추가해야 한다:

```properties
dubbo.provider.filter=tracing
dubbo.consumer.filter=tracing
```

Brave - Dubbo 통합에 관한 자세한 내용은 [이곳](https://github.com/openzipkin/brave/tree/master/instrumentation/dubbo-rpc)에서 확인할 수 있다. Spring Cloud Sleuth와 Dubbo를 사용하는 예제는 [여기](https://github.com/openzipkin/sleuth-webmvc-example/compare/add-dubbo-tracing)에서 확인할 수 있다.

### 6.12.2. gRPC

Spring Cloud Sleuth는 Brave 트레이서<sup>tracer</sup>를 통해 [gRPC](https://grpc.io/) 계측<sup>instrumentation</sup> 기능을 제공한다. `spring.sleuth.grpc.enabled`를 `false`로 설정하면 이 기능을 완전히 비활성화할 수 있다.

#### Variant 1

##### 의존성

> gRPC 통합에선 클라이언트와 서버 계측<sup>instrumentation</sup>을 위해 두 가지 외부 라이브러리에 의존하며, 두 라이브러리가 모두 클래스패스에 있어야 계측<sup>instrumentation</sup> 기능이 활성화된다.

Maven:

```xml
        <dependency>
            <groupId>io.github.lognet</groupId>
            <artifactId>grpc-spring-boot-starter</artifactId>
        </dependency>
        <dependency>
            <groupId>io.zipkin.brave</groupId>
            <artifactId>brave-instrumentation-grpc</artifactId>
        </dependency>
```

Gradle:

```groovy
    compile("io.github.lognet:grpc-spring-boot-starter")
    compile("io.zipkin.brave:brave-instrumentation-grpc")
```

##### 서버 계측

Spring Cloud Sleuth는 grpc-spring-boot-starter를 활용해 `@GRpcService`를 선언한 모든 서비스와 Brave의 gRPC 서버 인터셉터를 등록한다.

##### 클라이언트 계측

gRPC 클라이언트는 `ManagedChannelBuilder`를 활용해 gRPC 서버와 통신할 때 사용하는 `ManagedChannel`을 구성한다. 네이티브 `ManagedChannelBuilder`는 `ManagedChannel` 인스턴스를 구성할 때 진입점으로 사용할 수 있는 스태틱 메소드를 제공하지만, 이 메커니즘은 스프링 애플리케이션 컨텍스트의 영향 밖에 있다.

> Spring Cloud Sleuth는 `SpringAwareManagedChannelBuilder`를 제공하는데, 이 빌더는 스프링 애플리케이션 컨텍스트를 통해 커스텀할 수 있고, gRPC 클라이언트로 주입받을 수 있다. **`ManagedChannel` 인스턴스를 생성할 때는 반드시 이 빌더를 사용해야 한다.**

Sleuth는 `TracingManagedChannelBuilderCustomizer`를 생성해서 Brave의 클라이언트 인터셉터를 `SpringAwareManagedChannelBuilder`에 주입한다.

#### Variant 2

[Grpc 스프링 부트 스타터](https://github.com/yidongnan/grpc-spring-boot-starter)는 gRPC를 위한 Spring Cloud Sleuth와 Brave의 계측<sup>instrumentation</sup> 코드가 있는지 자동으로 감지하고 필요한 클라이언트나 서버 툴을 등록한다.

---

## 6.13. RxJava

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

Sleuth는 모든 `Action0` 인스턴스를 `TraceAction`이라는 Sleuth의 클래스로 래핑하는 커스텀 [`RxJavaSchedulersHook`](https://github.com/ReactiveX/RxJava/wiki/Plugins#rxjavaschedulershook)을 등록한다. 이 훅은 Action을 스케줄링하기 전에 트레이싱<sup>tracing</sup>이 이미 진행 중인지 여부에 따라 span을 새로 시작하거나 계속 이어간다. 이 커스텀 `RxJavaSchedulersHook`을 비활성화하려면 `spring.sleuth.rxjava.schedulers.hook.enabled`를 `false`로 설정해라.

Span을 새로 생성하지 않을 스레드의 이름은 정규식으로 정의할 수 있다. `spring.sleuth.rxjava.schedulers.ignoredthreads` 프로퍼티에 정규식 목록을 콤마로 구분해서 지정하면 된다.

> 리액티브 프로그래밍과 Sleuth를 함께 사용할 때는 리액터의 기능을 활용하는 것을 권장한다.

---

## 6.14. Spring Cloud CircuitBreaker

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

클래스패스에 Spring Cloud CircuitBreaker가 있다면, sleuth는 전달받은 command `Supplier`와 fallback `Function`을 전용 클래스로 래핑한다. 또한 CircuitBreaker의 리액티브 구현체 역시 계측<sup>instrumentation</sup>을 지원한다. 이 기능을 비활성화하려면 `spring.sleuth.circuitbreaker.enabled`를 `false`로 설정해라.

---

## 6.15. Spring Cloud Config Server

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

클래스패스에서 Spring Cloud Config 서버가 실행 중이면, sleuth는 `EnvironmentRepository`를 span으로 감싼다. 이 계측<sup>instrumentation</sup> 기능을 비활성화하려면 `spring.sleuth.config.server.enabled`를 `false`로 설정해라.

---

## 6.16. Spring Cloud Deployer

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

클래스패스에서 Spring Cloud Deployer가 실행 중이면, sleuth는 `AppDeployer`를 전용 클래스로 래핑한다. 이 클래스에선 애플리케이션의 상태를 디폴트 인터벌에 따라 폴링한다. 기본값은 `spring.sleuth.deployer.status-poll-delay` 프로퍼티를 통해 변경할 수 있다. 이 계측<sup>instrumentation</sup> 기능을  비활성화하려면 `spring.sleuth.deployer.enabled`를 `false`로 설정해라.

---

## 6.17. Spring RSocket

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

클래스패스에서 Spring RSocket이 실행 중이면, sleuth는 인바운드/아웃바운드 통신을 감싸 메타데이터를 통해 트레이싱<sup>tracing</sup> 컨텍스트를 전파<sup>propagate</sup>한다. 이 계측<sup>instrumentation</sup> 기능을 비활성화하려면 `spring.sleuth.rsocket.enabled`를 `false`로 설정해라.

---

## 6.18. Spring Batch

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

클래스패스에서 Spring Batch가 실행 중인 경우, sleuth는 `StepBuilderFactory`와 `JobBuilderFactory`를 래핑해서 트레이싱<sup>tracing</sup> 컨텍스트를 전파<sup>propagate</sup>한다. 이 계측<sup>instrumentation</sup> 기능을 비활성화하려면 `spring.sleuth.batch.enabled`를 `false`로 설정해라.

---

## 6.19. Spring Cloud Task

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

클래스패스에서 Spring Cloud Task가 실행 중인 경우, sleuth는 `TaskExecutionListener`와 `CommandLineRunner`, `ApplicationRunner`를 계측<sup>instrumentation</sup>한다. 이 기능을 비활성화하려면 `spring.sleuth.task.enabled`를 `false`로 설정해라.

---

## 6.20. Spring Tx

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

클래스패스에 Spring Tx가 있다면, sleuth는 `PlatformTransactionManager`와 `ReactiveTransactionManager`를 계측<sup>instrumentation</sup>해서 새 트랜잭션이 생성될 때마다 span을 새로 만든다. 기술적인 한계로 인해 스프링의 `AbstractPlatformTransactionManager`를 상속한 클래스들은 계측<sup>instrumentation</sup>하지 않는다. 이 기능을 비활성화하려면 `spring.sleuth.tx.enabled`를 `false`로 설정해라.

---

## 6.21. Spring Security

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

클래스패스에 Spring Security가 있다면, sleuth는 컨텍스트가 변경될 때 현재 스팬에 이벤트를 추가하는 `SecurityContextChangedListener`의 구현체를 생성한다. 이 계측<sup>instrumentation</sup> 기능을 비활성화하려면 `spring.sleuth.security.enabled`를 `false`로 설정해라.

---

## 6.22. R2DBC

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

클래스패스에 R2DBC 프록시가 있다면, sleuth는 `ConnectionFactory`를 계측<sup>instrumentation</sup>해서 커스텀 `ProxyExecutionListener`를 하나 추가한다. 이 계측<sup>instrumentation</sup> 기능을 비활성화하려면 `spring.sleuth.r2dbc.enabled`를 `false`로 설정해라.

---

## 6.23. Spring Vault

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

Sleuth는 Spring Vault가 Vault와 통신하는 데 사용하는 `RestTemplate`이나 `WebClient` 인스턴스를 계측<sup>instrumentation</sup>하고 있다. 이 계측<sup>instrumentation</sup> 기능을 비활성화하려면 `spring.sleuth.vault.enabled`를 `false`로 설정해라.

---

## 6.24. Spring Tomcat

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

Sleuth는 Tomcat의 `Valve`를, span을 사용하는 전용 구현체로 하나 추가한다. 이 계측<sup>instrumentation</sup> 기능을 비활성화하려면 `spring.sleuth.web.tomcat.enabled`를 `false`로 설정해라.

---

## 6.25. Spring Data Cassandra

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

Sleuth는 Casandra의 `CqlSession`과 `ReactiveSession` 인터페이스를 계측<sup>instrumentation</sup>하고 있으며, `RequestTracker`의 자체 구현체를 제공하고 있다. 이 계측<sup>instrumentation</sup> 기능을 비활성화하려면 `spring.sleuth.cassandra.enabled`를 `false`로 설정해라.

---

## 6.26. Spring JDBC

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다. 관련 코드들은 [spring-boot-datasource-decorator](https://github.com/gavlyukovskiy/spring-boot-data-source-decorator/) 프로젝트에서 가져왔다.

Sleuth는 `DataSource`를 전용 클래스로 감싼다<sup>decorate</sup>. 실제 프록시 처리는 [p6spy](https://github.com/p6spy/p6spy) 혹은 [datasource-proxy](https://github.com/ttddyy/datasource-proxy)에 위임한다. 이 기능을 사용하려면 해당 프록시가 클래스패스에 있어야 한다.


<div class="switch-language-wrapper p6spy-maven p6spy-gradle proxy-maven proxy-gradle">
<span class="switch-language p6spy-maven">P6Spy Maven</span>
<span class="switch-language p6spy-gradle">P6Spy Gradle</span>
<span class="switch-language proxy-maven">Datasource Proxy Maven</span>
<span class="switch-language proxy-gradle">Datasource Proxy Gradle</span>
</div>
<div class="language-only-for-p6spy-maven p6spy-maven p6spy-gradle proxy-maven proxy-gradle"></div>
```xml
<dependency>
    <groupId>p6spy</groupId>
    <artifactId>p6spy</artifactId>
    <version>${p6spy.version}</version>
    <scope>runtime</scope>
</dependency>
```
<div class="language-only-for-p6spy-gradle p6spy-maven p6spy-gradle proxy-maven proxy-gradle"></div>
```groovy
runtimeOnly "p6spy:p6spy:${p6spyVersion}"
```
<div class="language-only-for-proxy-maven p6spy-maven p6spy-gradle proxy-maven proxy-gradle"></div>
```xml
<dependency>
    <groupId>net.ttddyy</groupId>
    <artifactId>datasource-proxy</artifactId>
    <version>${datasource-proxy.version}</version>
    <scope>runtime</scope>
</dependency>
```
<div class="language-only-for-proxy-gradle p6spy-maven p6spy-gradle proxy-maven proxy-gradle"></div>
```groovy
runtimeOnly "net.ttddyy:datasource-proxy:${datasourceProxyVersion}"
```

전체 p6spy 설정 옵션들은 [부록](../appendix) 페이지에서 `spring.sleuth.jdbc.p6spy`를, 전체 데이터소스 프록시 설정 옵션들은 `spring.sleuth.jdbc.datasource-proxy`를 확인하길 바란다.

P6Spy의 경우 기본적으로 파라미터 값들은 로깅하지 않으므로, 파라미터도 로그에 남기려면 `spring.sleuth.jdbc.p6spy.tracing.include-parameter-values`를 `true`로 설정해라.

P6Spy가 제공하는 설정 메소드 중 하나를 사용해 P6Spy를 수동으로 구성할 수도 있다. 자세한 내용은 [P6Spy 설정 가이드](http://p6spy.readthedocs.io/en/latest/configandusage.html)를 참고해라.

Datasource Proxy의 경우 기본적으로 쿼리를 로깅하지 않으므로, 슬로우 쿼리를 로그에 남기려면 `spring.sleuth.jdbc.datasource-proxy.slow-query.enable-logging`을 `true`로 설정하고, 모든 쿼리를 로그에 남기려면 `spring.sleuth.jdbc.datasource-proxy.query.enable-logging`을 `true`로 설정해라.

이 계측<sup>instrumentation</sup> 기능을 비활성화하려면 `spring.sleuth.jdbc.enabled`를 `false`로 설정해라.

---

## 6.27. MongoDB

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

Sleuth는 모든 명령어를 span으로 감싸는 커맨드 리스너를 추가한다. Span에 별도로 소켓 주소 관련 태그를 추가하려면 `spring.sleuth.mongodb.socket-address-span-customizer.enabled`를 `true`로 설정해라.

이 계측<sup>instrumentation</sup> 기능을 비활성화하려면 `spring.sleuth.mongodb.enabled`를 `false`로 설정해라.

---

## 6.28. Spring Session

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

Sleuth는 모든 작업<sup>operation</sup>을 span으로 감싸는 `Session` 레포지토리를 계측<sup>instrumentation</sup>하고 있다. 이 계측<sup>instrumentation</sup> 기능을 비활성화하려면 `spring.sleuth.session.enabled`를 `false`로 설정해라.

---

## 6.29. Kotlin Coroutines

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

Sleuth는 `Tracer` 빈을 통해 현재 span을 조회할 수 있게 해주는 코틀린 코루틴을 추가하고 있다. `Tracer.asContextElement()` 메소드를 실행해 `Tracer` 빈을 코틀린 코루틴 컨텍스트로 전달해주면 되고, 아니면 클래스패스에 Reactor Kotlin 코루틴 통합이 들어있는 경우엔 Reactor의 컨텍스트에서 `Tracer` 빈을 가져올 수도 있다. 현재 span을 조회하려면 코틀린 코루틴 내에서 `currentSpan()` 메소드를 호출하면 된다.

---

## 6.30. Prometheus Exemplars

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

[프로메테우스 Exemplar](../../Prometheus/feature-flags/#exemplars-storage)는 `SpanContextSupplier`를 통해 지원한다. [Micrometer](https://micrometer.io/)를 사용 중이라면 자동으로 설정되지만, 원한다면 프로메테우스에 직접 `SpanContextSupplier`를 등록할 수도 있다.<br>이 기능은 프로메테우스 쪽에서 명시적으로 활성화해줘야 하며, [OpenMetrics](https://github.com/OpenObservability/OpenMetrics/blob/v1.0.0/specification/OpenMetrics.md#exemplars) 형식에서만 지원되므로 [프로메테우스 문서](../../Prometheus/feature-flags/#exemplars-storage)를 확인해보기 바란다.