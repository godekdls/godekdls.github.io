---
title: Spring Cloud Sleuth customization
category: Spring Cloud Sleuth
order: 7
permalink: /Spring%20Cloud%20Sleuth/sleuth-customization/
description: TODO
image: ./../../images/springcloud/logo.jpeg
lastmod: 2024-06-22T13:30:00+09:00
comments: true
originalRefName: 스프링 클라우드 슬루스
originalRefLink: https://docs.spring.io/spring-cloud-sleuth/docs/3.1.11/reference/htmlsingle/#howto
originalVersion: 3.1.11
---

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
- [6.21. Spring Security](#621-async-annotated-methods)
- [6.22. R2DBC](#622-scheduled-annotated-methods)
- [6.23. Spring Vault](#623-executor-executorservice-and-scheduledexecutorservice)
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

Sleuth는 카프카 클라이언트(`KafkaProducer`, `KafkaConsumer`)에 데코레이터 패턴을 적용해 생산<sup>produce</sup>하거나 컨슘<sup>consume</sup>하는 이벤트마다 span을 생성한다. 이 기능은 `spring.sleuth.kafka.enabled` 값을 `false`로 설정하면 비활성화할 수 있다.

> Sleuth의 자동 설정으로 이 패턴을 적용하려면 `Producer` 또는 `Consumer`를 빈으로 등록해야 한다. 그리고 이 빈들을 주입할 때는 타입을 `Producer` 또는 `Consumer`로 지정해야 한다 (e.g. `KafkaProducer`가 아니라).

프로젝트 리액터를 지원할 때는, 정의된 모든 `KafkaReceiver<K,V>` 타입 빈을 `TracingKafkaReceiver<K,V>`로 감싼다. 이렇게 하면 수신하는 요소마다 자체 트레이싱<sup>tracing</sup> 컨텍스트가 전파되어 별도의 퍼블리셔가 생성된다. 리액터 계측<sup>instrumentation</sup>과 함께 사용하면 span의 컨텍스트에 접근할 수 있다.

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

Spring Cloud Sleuth는 스케줄링된 메소드 실행가 실행될 때도 이를 계측<sup>instrumentation</sup>하기 때문에, 트레이싱<sup>tracing</sup> 정보는 여러 스레드를 오갈 때도 잘 전달된다. 이 동작은 `spring.sleuth.scheduled.enabled` 값을 `false`로 설정하면 비활성화할 수 있다.

메소드 위에 `@Scheduled` 애노테이션을 선언하면, 다음과 같은 span을 자동으로 생성해준다:

- 애노테이션을 선언한 메소드 이름을 span 이름으로 사용한다
- 해당 클래스 이름과 메소명을 태그로 추가한다.

`@Scheduled`를 선언한 클래스 중 span을 만들고 싶지 않은 클래스도 있다면, `spring.sleuth.scheduled.skipPattern`을 해당 클래스의 풀 네임<sup>fully qualified name</sup>과 매칭되는 정규식으로 설정해주면 된다.

### 6.2.3. Executor, ExecutorService, and ScheduledExecutorService

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

Slueth는 `LazyTraceExecutor`, `TraceableExecutorService`, `TraceableScheduledExecutorService`를 제공한다. 이 구현체들은 새 태스크를 제출<sup>submit</sup>하거나, 실행하거나, 스케줄링될 때마다 span을 생성한다.

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

> 이 설정을 빈 후처리<sup>post process</sup> 중에 처리할 수 있도록 `@Configuration` 클래스에 `@Role(BeanDefinition.ROLE_INFRASTRUCTURE)`을 추가하는 것을 잊지 말자.

---

## 6.3. HTTP Client Integration

이 섹션에서 설명하는 기능들은 `spring.sleuth.web.client.enabled` 프로퍼티를 `false`와 같이 설정해 비활성화할 수 있다.

### 6.3.1. Synchronous Rest Template

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

Slueth는 `RestTemplate` 인터셉터를 주입해 요청에 모든 트레이싱<sup>tracing</sup> 정보가 전달되도록 만든다. 호출이 이루어질 때마다 새 span이 생성되고, 이 span은 응답을 받자마자 닫힌다. 동기식<sup>synchronous</sup>의 `RestTemplate` 기능들을 끄려면 `spring.sleuth.web.client.enabled`를 `false`로 설정해라.

> 인터셉터를 주입할 수 있으려면 `RestTemplate`을 빈으로 등록해야 한다. `new` 키워드로 `RestTemplate` 인스턴스를 직접 생성했다면 요청을 계측<sup>instrumentation</sup>하지 않는다.

### 6.3.2. Asynchronous Rest Template

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

> Sleuth `2.0.0` 버전부터는 더 이상 `AsyncRestTemplate` 타입 빈을 등록하지 않는다. `AsyncRestTemplate` 빈이 필요하다면 직접 만들어야 한다. 그러면 slueth에서 알아서 요청을 계측<sup>instrumentation</sup>해줄 거다.

`AsyncRestTemplate` 관련 기능들을 끄려면 `spring.sleuth.web.async.client.enabled`를 `false`로 설정해라. 디폴트 `TraceAsyncClientHttpRequestFactoryWrapper`를 생성하지 않으려면 `spring.sleuth.web.async.client.factory.enabled`를 `false`로 설정해라. `AsyncRestClient`를 아예 생성하지 않으려면 `spring.sleuth.web.async.client.template.enabled`를 `false`로 설정해라.

#### Multiple Asynchronous Rest Templates

간혹 비동기<sup>Asynchronous</sup> 비동기 RestTemplate의 구현체가 여러 개 필요한 경우가 있다. 다음은 이럴 때 필요한 커스텀 `AsyncRestTemplate`을 설정하는 예시다:

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

Sine Sleuth uses a Bean Post Processor (BPP) to modify executors the `Executor` type that you provided will be modified and the return type will be the trace version of that executor. That can lead to exceptions simillar to this

```java
12:12:49.606 [main] DEBUG org.springframework.context.annotation.AnnotationConfigApplicationContext - Closing org.springframework.context.annotation.AnnotationConfigApplicationContext@2401f4c3, started on Wed Jan 19 12:12:49 GMT 2022
Exception in thread "main" org.springframework.beans.factory.BeanNotOfRequiredTypeException: Bean named 'exampleConfigurer' is expected to be of type 'com.example.demo.Gh29151Application$Example' but was actually of type 'org.springframework.cloud.sleuth.instrument.async.LazyTraceAsyncCustomizer'
```

If you see such exceptions you must

- disable sleuth async
- manually instrument the executors using their trace representations

Example

```properties
spring.sleuth.async.enabled=false
```

and configuration example

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

You can read more about this in this [issue](https://github.com/spring-cloud/spring-cloud-sleuth/issues/2100).

#### `WebClient`

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

We inject a `ExchangeFilterFunction` implementation that creates a span and, through on-success and on-error callbacks, takes care of closing client-side spans.

To block this feature, set `spring.sleuth.web.client.enabled` to `false`.

> You have to register `WebClient` as a bean so that the tracing instrumentation gets applied. If you create a `WebClient` instance with a `new` keyword, the instrumentation does NOT work.

##### Logbook with WebClient

In order to add support for Logbook with WebClient `org.zalando:logbook-spring-boot-webflux-autoconfigure` you need to add the following configuration. You can read more about this integration in [this issue](https://github.com/spring-cloud/spring-cloud-sleuth/issues/1690).

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

If you use the [Traverson](https://docs.spring.io/spring-hateoas/docs/current/reference/html/#client.traverson) library, you can inject a `RestTemplate` as a bean into your Traverson object. Since `RestTemplate` is already intercepted, you get full support for tracing in your client. The following pseudo code shows how to do that:

```java
@Autowired RestTemplate restTemplate;

Traverson traverson = new Traverson(URI.create("https://some/address"),
    MediaType.APPLICATION_JSON, MediaType.APPLICATION_JSON_UTF8).setRestOperations(restTemplate);
// use Traverson
```

#### Apache `HttpClientBuilder` and `HttpAsyncClientBuilder`

This feature is available for Brave tracer implementation.

We instrument the `HttpClientBuilder` and `HttpAsyncClientBuilder` so that tracing context gets injected to the sent requests.

To block these features, set `spring.sleuth.web.client.enabled` to `false`.

#### Netty `HttpClient`

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

We instrument the Netty’s `HttpClient`.

To block this feature, set `spring.sleuth.web.client.enabled` to `false`.

> You have to register `HttpClient` as a bean so that the instrumentation happens. If you create a `HttpClient` instance with a `new` keyword, the instrumentation does NOT work.

#### `UserInfoRestTemplateCustomizer`

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

We instrument the Spring Security’s `UserInfoRestTemplateCustomizer`.

To block this feature, set `spring.sleuth.web.client.enabled` to `false`.

---

## 6.4. HTTP Server Integration

Features from this section can be disabled by setting the `spring.sleuth.web.enabled` property with value equal to `false`.

### 6.4.1. HTTP Filter

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

Through the `TracingFilter`, all sampled incoming requests result in creation of a Span. You can configure which URIs you would like to skip by setting the `spring.sleuth.web.skipPattern` property. If you have `ManagementServerProperties` on classpath, its value of `contextPath` gets appended to the provided skip pattern. If you want to reuse the Sleuth’s default skip patterns and just append your own, pass those patterns by using the `spring.sleuth.web.additionalSkipPattern`.

By default, all the spring boot actuator endpoints are automatically added to the skip pattern. If you want to disable this behaviour set `spring.sleuth.web.ignore-auto-configured-skip-patterns` to `true`.

To change the order of tracing filter registration, please set the `spring.sleuth.web.filter-order` property.

To disable the filter that logs uncaught exceptions you can disable the `spring.sleuth.web.exception-throwing-filter-enabled` property.

### 6.4.2. Async Servlet support

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

If your controller returns a `Callable` or a `WebAsyncTask`, Spring Cloud Sleuth continues the existing span instead of creating a new one.

### 6.4.3. WebFlux support

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

Through `TraceWebFilter`, all sampled incoming requests result in creation of a Span. That Span’s name is `http:` + the path to which the request was sent. For example, if the request was sent to `/this/that`, the name is `http:/this/that`. You can configure which URIs you would like to skip by using the `spring.sleuth.web.skipPattern` property. If you have `ManagementServerProperties` on the classpath, its value of `contextPath` gets appended to the provided skip pattern. If you want to reuse Sleuth’s default skip patterns and append your own, pass those patterns by using the `spring.sleuth.web.additionalSkipPattern`.

In order to achieve best results in terms of performance and context propagation we suggest that you switch the `spring.sleuth.reactor.instrumentation-type` to `MANUAL`. In order to execute code with the span in scope you can call `WebFluxSleuthOperators.withSpanInScope`. Example:

```java
@GetMapping("/simpleManual")
public Mono<String> simpleManual() {
    return Mono.just("hello").map(String::toUpperCase).doOnEach(WebFluxSleuthOperators
            .withSpanInScope(SignalType.ON_NEXT, signal -> log.info("Hello from simple [{}]", signal.get())));
}
```

To change the order of tracing filter registration, please set the `spring.sleuth.web.filter-order` property.

### 6.4.4. Reactor Netty HttpServer

If you’re using Reactor Netty and would like to have your access logs instrumented you need to add the `io.projectreactor.netty:reactor-netty-http-brave` (this will work only for the Brave Tracer). Also add the following configuration to your project.

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

Features from this section can be disabled by setting the `spring.sleuth.messaging.enabled` property with value equal to `false`.

### 6.5.1. Spring Integration

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

Spring Cloud Sleuth integrates with [Spring Integration](https://projects.spring.io/spring-integration/). It creates spans for publish and subscribe events. To disable Spring Integration instrumentation, set `spring.sleuth.integration.enabled` to `false`.

You can provide the `spring.sleuth.integration.patterns` pattern to explicitly provide the names of channels that you want to include for tracing. By default, all channels but `hystrixStreamOutput` channel are included.

> When using the `Executor` to build a Spring Integration `IntegrationFlow`, you must use the untraced version of the `Executor`. Decorating the Spring Integration Executor Channel with `TraceableExecutorService` causes the spans to be improperly closed.

If you want to customize the way tracing context is read from and written to message headers, it’s enough for you to register beans of types:

- `Propagator.Setter<MessageHeaderAccessor>` - for writing headers to the message
- `Propagator.Getter<MessageHeaderAccessor>` - for reading headers from the message

#### Spring Integration Customization

#### Customizing messaging spans

In order to change the default span names and tags, just register a bean of type `MessageSpanCustomizer`. You can also override the existing `DefaultMessageSpanCustomizer` to extend the existing behaviour.

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

Spring Cloud Sleuth can instrument Spring Cloud Function. Since Spring Cloud Stream uses Spring Cloud Function you will get the messaging instrumentation out of the box.

The way to achieve it is to provide a `Function` or `Consumer` or `Supplier` that takes in a `Message` as a parameter e.g. `Function<Message<String>, Message<Integer>>`. If the type **is not** `Message` then instrumentation **will not** take place.

For a reactive `Consumer<Flux<Message<?>>>` remember to manually close the span and clear the context before you call `.subscribe()`. Example:

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

NOTE: For Sleuth to work with any `Supplier` (e.g. `Supplier<Flux<Message<String>>>`) you must fall back to Spring Integration based instrumentation by setting `spring.sleuth.integration.enabled` to `true`.

You can disable Spring Cloud Stream integration by setting the value of `spring.sleuth.function.enabled` to `false`.

If you want to fully control the life cycle of spans within the reactive messaging context of Spring Cloud Stream remember to disable the Spring Cloud Stream integration and leverage the `MessagingSleuthOperators` utility class that allows you to manipulate the input and output messages in order to continue the tracing context and to execute custom code within the tracing context.

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

This feature is available for Brave tracer implementation.

We instrument the `RabbitTemplate` so that tracing headers get injected into the message.

To block this feature, set `spring.sleuth.messaging.rabbit.enabled` to `false`.

### 6.5.4. Spring Kafka

This feature is available for Brave tracer implementation.

We instrument the Spring Kafka’s `ProducerFactory` and `ConsumerFactory` so that tracing headers get injected into the created Spring Kafka’s `Producer` and `Consumer`.

To block this feature, set `spring.sleuth.messaging.kafka.enabled` to `false`.

### 6.5.5. Spring Kafka Streams

This feature is available for Brave tracer implementation.

We instrument the `KafkaStreams` `KafkaClientSupplier` so that tracing headers get injected into the `Producer` and `Consumer`s. A `KafkaStreamsTracing` bean allows for further instrumentation through additional `TransformerSupplier` and `ProcessorSupplier` methods.

To block this feature, set `spring.sleuth.messaging.kafka.streams.enabled` to `false`.

### 6.5.6. Spring JMS

This feature is available for Brave tracer implementation.

We instrument the `JmsTemplate` so that tracing headers get injected into the message. We also support `@JmsListener` annotated methods on the consumer side.

To block this feature, set `spring.sleuth.messaging.jms.enabled` to `false`.

> We don’t support baggage propagation for JMS

---

## 6.6. OpenFeign

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

By default, Spring Cloud Sleuth provides integration with Feign through `TraceFeignClientAutoConfiguration`. You can disable it entirely by setting `spring.sleuth.feign.enabled` to `false`. If you do so, no Feign-related instrumentation take place.

Part of Feign instrumentation is done through a `FeignBeanPostProcessor`. You can disable it by setting `spring.sleuth.feign.processor.enabled` to `false`. If you set it to `false`, Spring Cloud Sleuth does not instrument any of your custom Feign components. However, all the default instrumentation is still there.

---

## 6.7. OpenTracing

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

Spring Cloud Sleuth is compatible with [OpenTracing](https://opentracing.io/). If you have OpenTracing on the classpath, we automatically register the OpenTracing `Tracer` bean. If you wish to disable this, set `spring.sleuth.opentracing.enabled` to `false`

---

## 6.8. Quartz

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

We instrument quartz jobs by adding Job/Trigger listeners to the Quartz Scheduler.

To turn off this feature, set the `spring.sleuth.quartz.enabled` property to `false`.

---

## 6.9. Reactor

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

We have the following modes of instrumenting reactor based applications that can be set via `spring.sleuth.reactor.instrumentation-type` property:

- `DECORATE_QUEUES` - With the new Reactor [queue wrapping mechanism](https://github.com/reactor/reactor-core/pull/2566) (Reactor 3.4.3) we’re instrumenting the way threads are switched by Reactor. This should lead to feature parity with `ON_EACH` with low performance impact.
- `DECORATE_ON_EACH` - wraps every Reactor operator in a trace representation. Passes the tracing context in most cases. This mode might lead to drastic performance degradation.
- `DECORATE_ON_LAST` - wraps last Reactor operator in a trace representation. Passes the tracing context in some cases thus accessing MDC context might not work. This mode might lead to medium performance degradation.
- `MANUAL` - wraps every Reactor in the least invasive way without passing of tracing context. It’s up to the user to do it.

Current default is `ON_EACH` for backward compatibility reasons, however we encourage the users to migrate to the `MANUAL` instrumentation and profit from `WebFluxSleuthOperators` and `MessagingSleuthOperators`. The performance improvement can be substantial. Example:

```java
@GetMapping("/simpleManual")
public Mono<String> simpleManual() {
    return Mono.just("hello").map(String::toUpperCase).doOnEach(WebFluxSleuthOperators
            .withSpanInScope(SignalType.ON_NEXT, signal -> log.info("Hello from simple [{}]", signal.get())));
}
```

To disable Reactor support, set the `spring.sleuth.reactor.enabled` property to `false`.

---

## 6.10. Redis

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

We’re using the `Tracing` abstraction from Lettuce. If Brave is on the classpath we configure `Tracing` to be `BraveTracing`.

To disable Redis support, set the `spring.sleuth.redis.enabled` property to `false`.

### 6.10.1. Redis With Legacy Brave Only Support

To use the Brave only supported feature you need to set the value of `spring.sleuth.redis.legacy.enabled` to `true`. This is the default mechanism available up till version 3.1.0 of Spring Cloud Sleuth.

We set `tracing` property to Lettuce `ClientResources` instance to enable Brave tracing built in Lettuce.

Spring Cloud Sleuth will provide a traced version of the `ClientResources` bean. If you have your own implementation of that bean, remember to customize the `ClientResources.Builder` with a stream of `ClientResourcesBuilderCustomizer`s like presented below:

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

If you wrap your logic in `Runnable` or `Callable`, you can wrap those classes in their Sleuth representative, as shown in the following example for `Runnable`:

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

The following example shows how to do so for `Callable`:

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

That way, you ensure that a new span is created and closed for each execution.

---

## 6.12. RPC

This feature is available for Brave tracer implementation.

Sleuth automatically configures the `RpcTracing` bean which serves as a foundation for RPC instrumentation such as gRPC or Dubbo.

If a customization of client / server sampling of the RPC traces is required, just register a bean of type `brave.sampler.SamplerFunction<RpcRequest>` and name the bean `sleuthRpcClientSampler` for client sampler and `sleuthRpcServerSampler` for server sampler.

For your convenience the `@RpcClientSampler` and `@RpcServerSampler` annotations can be used to inject the proper beans or to reference the bean names via their static String `NAME` fields.

Ex. Here’s a sampler that traces 100 "GetUserToken" server requests per second. This doesn’t start new traces for requests to the health check service. Other requests will use the global sampling configuration.

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

For more, see [github.com/openzipkin/brave/tree/master/instrumentation/rpc#sampling-policy](https://github.com/openzipkin/brave/tree/master/instrumentation/rpc#sampling-policy)

### 6.12.1. Dubbo RPC support

Via the integration with Brave, Spring Cloud Sleuth supports [Dubbo](https://dubbo.apache.org/). It’s enough to add the `brave-instrumentation-dubbo` dependency:

```xml
<dependency>
    <groupId>io.zipkin.brave</groupId>
    <artifactId>brave-instrumentation-dubbo</artifactId>
</dependency>
```

You need to also set a `dubbo.properties` file with the following contents:

```properties
dubbo.provider.filter=tracing
dubbo.consumer.filter=tracing
```

You can read more about Brave - Dubbo integration [here](https://github.com/openzipkin/brave/tree/master/instrumentation/dubbo-rpc). An example of Spring Cloud Sleuth and Dubbo can be found [here](https://github.com/openzipkin/sleuth-webmvc-example/compare/add-dubbo-tracing).

### 6.12.2. gRPC

Spring Cloud Sleuth provides instrumentation for [gRPC](https://grpc.io/) via the Brave tracer. You can disable it entirely by setting `spring.sleuth.grpc.enabled` to `false`.

#### Variant 1

##### Dependencies

> The gRPC integration relies on two external libraries to instrument clients and servers and both of those libraries must be on the class path to enable the instrumentation.

Maven:

```
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

```
    compile("io.github.lognet:grpc-spring-boot-starter")
    compile("io.zipkin.brave:brave-instrumentation-grpc")
```

##### Server Instrumentation

Spring Cloud Sleuth leverages grpc-spring-boot-starter to register Brave’s gRPC server interceptor with all services annotated with `@GRpcService`.

##### Client Instrumentation

gRPC clients leverage a `ManagedChannelBuilder` to construct a `ManagedChannel` used to communicate to the gRPC server. The native `ManagedChannelBuilder` provides static methods as entry points for construction of `ManagedChannel` instances, however, this mechanism is outside the influence of the Spring application context.

> Spring Cloud Sleuth provides a `SpringAwareManagedChannelBuilder` that can be customized through the Spring application context and injected by gRPC clients. **This builder must be used when creating `ManagedChannel` instances.**

Sleuth creates a `TracingManagedChannelBuilderCustomizer` which inject Brave’s client interceptor into the `SpringAwareManagedChannelBuilder`.

#### Variant 2

[Grpc Spring Boot Starter](https://github.com/yidongnan/grpc-spring-boot-starter) automatically detects the presence of Spring Cloud Sleuth and Brave’s instrumentation for gRPC and registers the necessary client and/or server tooling.

---

## 6.13. RxJava

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

We registering a custom [`RxJavaSchedulersHook`](https://github.com/ReactiveX/RxJava/wiki/Plugins#rxjavaschedulershook) that wraps all `Action0` instances in their Sleuth representative, which is called `TraceAction`. The hook either starts or continues a span, depending on whether tracing was already going on before the Action was scheduled. To disable the custom `RxJavaSchedulersHook`, set the `spring.sleuth.rxjava.schedulers.hook.enabled` to `false`.

You can define a list of regular expressions for thread names for which you do not want spans to be created. To do so, provide a comma-separated list of regular expressions in the `spring.sleuth.rxjava.schedulers.ignoredthreads` property.

> The suggested approach to reactive programming and Sleuth is to use the Reactor support.

---

## 6.14. Spring Cloud CircuitBreaker

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

If you have Spring Cloud CircuitBreaker on the classpath, we will wrap the passed command `Supplier` and the fallback `Function` in its trace representations. We will also instrument the reactive implementation of the CircuitBreaker. In order to disable this instrumentation set `spring.sleuth.circuitbreaker.enabled` to `false`.

---

## 6.15. Spring Cloud Config Server

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

If you have Spring Cloud Config Server running on the classpath, we will wrap the `EnvironmentRepository` in a span. In order to disable this instrumentation set `spring.sleuth.config.server.enabled` to `false`.

---

## 6.16. Spring Cloud Deployer

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

If you have Spring Cloud Deployer running on the classpath, we wrap the `AppDeployer` in a trace representation. We are polling the application for its status at a default interval. You can change that default by setting the `spring.sleuth.deployer.status-poll-delay` property. In order to disable this instrumentation set `spring.sleuth.deployer.enabled` to `false`.

---

## 6.17. Spring RSocket

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

If you have Spring RSocket running on the classpath, we wrap the inbound and outbound communication to propagate the tracing context via the metadata. In order to disable this instrumentation set `spring.sleuth.rsocket.enabled` to `false`.

---

## 6.18. Spring Batch

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

If you have Spring Batch running on the classpath, we wrap the `StepBuilderFactory` and the `JobBuilderFactory` to propagate the tracing context. In order to disable this instrumentation set `spring.sleuth.batch.enabled` to `false`.

---

## 6.19. Spring Cloud Task

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

If you have Spring Cloud Task running on the classpath, we’re instrumenting `TaskExecutionListener` and `CommandLineRunner` and `ApplicationRunner`. In order to disable this instrumentation set `spring.sleuth.task.enabled` to `false`.

---

## 6.20. Spring Tx

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

If you have Spring Tx on the classpath we will instrument the `PlatformTransactionManager` and the `ReactiveTransactionManager` to create a span whenever a new transaction is created. Due to technical constraints we will not instrument classes that extend Spring’s `AbstractPlatformTransactionManager`. In order to disable this instrumentation set `spring.sleuth.tx.enabled` to `false`.

---

## 6.21. Spring Security

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

If you have Spring Security on the classpath, we create an implementation of `SecurityContextChangedListener` that annotates a current span with an event when context has changed. In order to disable this instrumentation set `spring.sleuth.security.enabled` to `false`.

---

## 6.22. R2DBC

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

If you have R2DBC Proxy on the classpath we will instrument the `ConnectionFactory`so that it contains a custom `ProxyExecutionListener`. In order to disable this instrumentation set `spring.sleuth.r2dbc.enabled` to `false`.

---

## 6.23. Spring Vault

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

We’re instrumenting the `RestTemplate` or `WebClient` instances used by Spring Vault to communicate with Vault. In order to disable this instrumentation set `spring.sleuth.vault.enabled` to `false`.

---

## 6.24. Spring Tomcat

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

We’re adding an instrumented Tomcat’s `Valve` that originates the span. In order to disable this instrumentation set `spring.sleuth.web.tomcat.enabled` to `false`.

---

## 6.25. Spring Data Cassandra

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

We’re instrumenting Casandra’s `CqlSession` and `ReactiveSession` interfaces and we’re providing our own implementation of the `RequestTracker`. In order to disable this instrumentation set `spring.sleuth.cassandra.enabled` to `false`.

---

## 6.26. Spring JDBC

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다. It has been ported from the [spring-boot-datasource-decorator](https://github.com/gavlyukovskiy/spring-boot-data-source-decorator/) project.

We’re decorating `DataSource`s in a trace representation. We delegate actual proxying to either [p6spy](https://github.com/p6spy/p6spy) or [datasource-proxy](https://github.com/ttddyy/datasource-proxy). In order to use this feature you need to have them on the classpath.

P6Spy Maven

P6Spy Gradle

Datasource Proxy Maven

Datasource Proxy Gradle

```xml
<dependency>
    <groupId>p6spy</groupId>
    <artifactId>p6spy</artifactId>
    <version>${p6spy.version}</version>
    <scope>runtime</scope>
</dependency>
```

Please check the [appendix](https://docs.spring.io/spring-cloud-sleuth/docs/3.1.11/reference/htmlsingle/#appendix) page under `spring.sleuth.jdbc.p6spy` for all p6spy configuration options and `spring.sleuth.jdbc.datasource-proxy` for all datasource proxy configuration options.

For P6Spy by default logging parameter values will be disabled, set `spring.sleuth.jdbc.p6spy.tracing.include-parameter-values` to `true` to enable it.

You can configure P6Spy manually using one of available configuration methods. For more information please refer to the [P6Spy Configuration Guide](http://p6spy.readthedocs.io/en/latest/configandusage.html).

For Datasource Proxy by default logging queries will be disabled, set `spring.sleuth.jdbc.datasource-proxy.slow-query.enable-logging` to `true` to enable logging slow queries and set `spring.sleuth.jdbc.datasource-proxy.query.enable-logging` to `true` to enable logging all queries.

In order to disable this instrumentation set `spring.sleuth.jdbc.enabled` to `false`.

---

## 6.27. MongoDB

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

We’re adding command listeners that wrap all commands in a span. If you want to have additional socket address related tags on the span set the `spring.sleuth.mongodb.socket-address-span-customizer.enabled` to `true`.

In order to disable this instrumentation set `spring.sleuth.mongodb.enabled` to `false`.

---

## 6.28. Spring Session

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

We’re instrumenting the `Session` repositories that wraps all operations in a span. In order to disable this instrumentation set `spring.sleuth.session.enabled` to `false`.

---

## 6.29. Kotlin Coroutines

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

We’re adding Kotlin Coroutines that allow you to retrieve the current span via the `Tracer` bean. You can either pass the bean to the Kotlin Coroutine context via `Tracer.asContextElement()` method execution or if you have Reactor Kotlin Coroutine integration on the classpath, we will retrieve it from Reactor’s context. To retrieve the current span you can call the `currentSpan()` method within the Kotlin Coroutine.

---

## 6.30. Prometheus Exemplars

이 기능은 모든 트레이서<sup>tracer</sup> 구현체에서 사용할 수 있다.

[Prometheus Exemplars](https://prometheus.io/docs/prometheus/latest/feature_flags/#exemplars-storage) are supported through `SpanContextSupplier`. If you use [Micrometer](https://micrometer.io/), this will be auto-configured for you, but you can register `SpanContextSupplier` directly to Prometheus if you want.
Please check the [Prometheus Docs](https://prometheus.io/docs/prometheus/latest/feature_flags/#exemplars-storage), since this feature needs to be explicitly enabled on Prometheus' side, and it is only supported using the [OpenMetrics](https://github.com/OpenObservability/OpenMetrics/blob/v1.0.0/specification/OpenMetrics.md#exemplars) format.
