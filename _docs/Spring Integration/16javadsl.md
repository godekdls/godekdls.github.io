---
title: Java DSL
category: Spring Integration
order: 16
permalink: /Spring%20Integration/java-dsl/
description: todo
image: ./../../images/springintegration/logo.png
lastmod: 2022-01-05T21:30:00+09:00
comments: true
originalRefName: 스프링 인티그레이션
parent: Core Messaging
originalRefLink: https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/index-single.html#java-dsl
parentUrl: /Spring%20Integration/core-messaging/
---

---

## 목차

- [11.1. DSL Basics](#111-dsl-basics)
- [11.2. Message Channels](#112-message-channels)
- [11.3. Pollers](#113-pollers)
- [11.4. The reactive() Endpoint](#114-the-reactive-endpoint)
- [11.5. DSL and Endpoint Configuration](#115-dsl-and-endpoint-configuration)
- [11.6. Transformers](#116-transformers)
- [11.7. Inbound Channel Adapters](#117-inbound-channel-adapters)
- [11.8. Message Routers](#118-message-routers)
- [11.9. Splitters](#119-splitters)
- [11.10. Aggregators and Resequencers](#1110-aggregators-and-resequencers)
- [11.11. Service Activators and the .handle() method](#1111-service-activators-and-the-handle-method)
- [11.12. Operator gateway()](#1112-operator-gateway)
- [11.13. Operator log()](#1113-operator-log)
- [11.14. Operator intercept()](#1114-operator-intercept)
- [11.15. MessageChannelSpec.wireTap()](#1115-messagechannelspecwiretap)
- [11.16. Working With Message Flows](#1116-working-with-message-flows)
- [11.17. FunctionExpression](#1117-functionexpression)
- [11.18. Sub-flows support](#1118-sub-flows-support)
- [11.19. Using Protocol Adapters](#1119-using-protocol-adapters)
- [11.20. IntegrationFlowAdapter](#1120-integrationflowadapter)
- [11.21. Dynamic and Runtime Integration Flows](#1121-dynamic-and-runtime-integration-flows)
- [11.22. IntegrationFlow as a Gateway](#1122-integrationflow-as-a-gateway)
- [11.23. DSL Extensions](#1123-dsl-extensions)
- [11.24. Integration Flows Composition](#1124-integration-flows-composition)

---

자바 설정과 DSL을 사용하면 스프링 `@configuration` 클래스에서 빌더와 fluent API로 간편하게 Spring Integration 메시지 플로우를 구성할 수 있다.

([코틀린 DSL](../kotlin-dsl)도 함께 참고해라.)

Spring Integration의 자바 DSL은 본질적으로 Spring Integration을 위한 파사드<sup>facade</sup>라고 할 수 있다. DSL의 fluent `Builder` 패턴을 사용하면 Spring Framework와 Spring Integration의 기존 자바 설정에 Spring Integration 메시지 플로우를 간단하게 끼워 넣을 수 있다. Java 8부터 사용 가능한 람다를 지원하며, 직접 사용하기도 하기 때문에 훨씬 짧은 코드로 설정을 완성할 수 있다.

DSL을 사용하는 쓸만한 예제는 [CAFE](https://github.com/spring-projects/spring-integration-samples/tree/main/dsl/cafe-dsl)를 참고해라.

DSL은 `IntegrationFlowBuilder`를 위한 팩토리 클래스, `IntegrationFlows`로 이용할 수 있다. DSL을 이용해 `integrationflow`를 생성하고, `@bean` 어노테이션을 이용해 스프링 빈으로 등록해주면 된다. DSL의 빌더 패턴을 사용하면 한 없이 복잡할 수 있는 구조를, 람다를 인자로 받는 메소드들의 계층 구조로 표현할 수 있다.

`IntegrationflowBuilder`는 `IntegrationFlow` 빈 안에 통합 구성 요소들을 수집하는 게 전부다 (`MessageChannel` 인스턴스, `AbstractEndpoint` 인스턴스 등). 이후 이 구성 요소들은 `IntegrationFlowBeanPostProcessor`를 통해 파싱돼서 애플리케이션 컨텍스트 빈으로 등록된다.

자바 DSL은 Spring Integration 클래스를 직접 사용하기 때문에 XML 생성이나 파싱이 필요 없다. 하지만 DSL은 구문적으로 XML을 대신하는 게 전부가 아니다. 가장 눈에 띄는 기능 중 하나는 엔드포인트 로직을 인라인 람다로 정의하는 것으로, 커스텀 로직을 위해 클래스를 따로 정의하지 않아도 된다. 어떻게 보면 Spring Integration의 SpEL<sup>Spring Expression Language</sup>과 인라인 스크립팅으로도 가능한 것이지만, 진짜 진가를 발휘하는 것은 람다이며, 작성하기도 훨씬 쉽다.

다음은 자바 설정을 사용해 Spring Integration을 구성하는 예시다:

```java
@Configuration
@EnableIntegration
public class MyConfiguration {

    @Bean
    public AtomicInteger integerSource() {
        return new AtomicInteger();
    }

    @Bean
    public IntegrationFlow myFlow() {
        return IntegrationFlows.fromSupplier(integerSource()::getAndIncrement,
                                         c -> c.poller(Pollers.fixedRate(100)))
                    .channel("inputChannel")
                    .filter((Integer p) -> p > 0)
                    .transform(Object::toString)
                    .channel(MessageChannels.queue())
                    .get();
    }
}
```

위 설정에선 `ApplicationContext`가 시작된 후 Spring Integration 엔드포인트들과 메시지 채널들을 생성한다. 자바 설정은 XML 설정 대신 사용해도 되고, 함께 사용해서 설정을 보강해도 좋다. 자바 설정을 사용하기 위해 기존 XML 설정들을 전부 걷어내야 하는 것은 아니다.

---

## 11.1. DSL Basics

앞에서 언급한 `IntegrationFlowBuilder` API는 `org.springframework.integration.dsl` 패키지에 들어있다. 이 패키지엔 여러 가지 `IntegrationComponentSpec` 구현체도 들어있는데, 이 구현체들 역시 빌더이며, 실제 엔드포인트를 설정할 수 있는 fluent API를 제공한다. `IntegrationFlowBuilder` 인프라는 메시지 기반 애플리케이션에 흔히 필요한 [엔터프라이즈 통합 패턴<sup>enterprise integration patterns; EIP</sup>](https://www.enterpriseintegrationpatterns.com/)을 제공한다 (채널, 엔드포인트, 폴러, 채널 인터셉터 등).

DSL에선 가독성을 위해 엔드포인트들을 동사로 표현한다. 다음은 많이 사용하는 DSL 메소드들의 이름과 거기 연결되는 EIP 엔드포인트들이다:

- transform → `Transformer`
- filter → `Filter`
- handle → `ServiceActivator`
- split → `Splitter`
- aggregate → `Aggregator`
- route → `Router`
- bridge → `Bridge`

통합이라는 것은 이런 엔드포인트들을 구성해 하나 이상의 메시지 플로우를 만든다는 개념이다. EIP에선 공식적으로 '메시지 플로우'라는 용어를 정의하진 않았지만, 메시지 플로우를 유명 메시지 처리 패턴들을 사용하는 하나의 작업 단위로 생각하면 편하다. DSL에선 `IntegrationFlow`를 사용해 채널과 채널 사이 엔드포인트들의 구조를 정의한다. 하지만 `IntegrationFlow`는 실제 애플리케이션 컨텍스트에 있는 빈에 설정 프로퍼티들을 채워주는 역할만 담당하며, 런타임에 사용되지 않는다. 하지만 `IntegrationFlow` 빈은 `Lifecycle`로 주입받아 전체 플로우를 `start()`, `stop()`시키는 식으로 제어할 수 있다. 전체 플로우는 이 `IntegrationFlow`와 관련된 모든 Spring Integration 구성 요소에 위임된다. 다음은 `IntegrationFlowBuilder`의 EIP 메소드를 이용해 `IntegrationFlows` 팩토리로 `IntegrationFlow` 빈을 정의하는 예시다:

```java
@Bean
public IntegrationFlow integerFlow() {
    return IntegrationFlows.from("input")
            .<String, Integer>transform(Integer::parseInt)
            .get();
}
```

`transform`은 엔드포인트 인자로 람다를 받는다. 람다는 메시지 페이로드를 넘겨 실행하게 된다. 이 메소드의 실제 인자는 `GenericTransformer<S, T>`다. 따라서 여기엔 기본 제공하는 트랜스포머들을 사용할 수 있다 (`ObjectToJsonTransformer`, `FileToStringTransformer` 등).

`IntegrationFlowBuilder`는 내부에서 각각 `MessageTransformingHandler`와 `ConsumerEndpointFactoryBean`을 사용해서 `MessageHandler`와 이에 대한 엔드포인트를 인식한다. 다른 예제를 하나 더 살펴보자:

```java
@Bean
public IntegrationFlow myFlow() {
    return IntegrationFlows.from("input")
                .filter("World"::equals)
                .transform("Hello "::concat)
                .handle(System.out::println)
                .get();
}
```

위 예제는 `Filter → Transformer → Service Activator` 순서로 짜여져있다. 여기서 구성하는 플로우는 "편도<sup>one way</sup>" 플로우다. 즉, 응답 메시지는 따로 제공하지 않고 페이로드를 STDOUT으로 출력하는 게 전부다. 엔드포인트들은 다이렉트 채널을 통해 자동으로 연결된다.

<blockquote  style="background-color: #fbebf3; border-color: #d63583;">
  <p id="java-dsl-class-cast"><strong>람다와 <code class="highlighter-rouge">Message&lt;?&gt;</code> 인자</strong></p>
  <p>EIP 메소드에서 람다가 받는 "입력" 인자는 보통 메시지 페이로드다. 전체 메시지에 접근하고 싶다면, 오버로딩 메소드 중에 첫 번째 파라미터로 <code class="highlighter-rouge">Class&lt;?&gt;</code>를 받는 메소드를 사용해라. 예를 들어 아래 코드는 잘 동작하는 코드가 아니다:</p>
  <div class="language-java highlighter-rouge"><div class="highlight"><pre class="highlight"><code><span class="o">.&lt;</span><span class="nc">Message</span><span class="o">&lt;?&gt;,</span> <span class="nc">Foo</span><span class="o">&gt;</span><span class="n">transform</span><span class="o">(</span><span class="n">m</span> <span class="o">-&gt;</span> <span class="n">newFooFromMessage</span><span class="o">(</span><span class="n">m</span><span class="o">))</span>
</code></pre></div>  </div>
  <p>여기선 람다가 인자 타입을 유지하지 않았기 때문에, 프레임워크에선 페이로드를 <code class="highlighter-rouge">Message&lt;?&gt;</code>로 캐스팅하려고 하고 결국엔 런타임에 <code class="highlighter-rouge">ClassCastException</code>이 발생한다.</p>
  <p>대신 아래 메소드를 사용해라:</p>
  <div class="language-java highlighter-rouge"><div class="highlight"><pre class="highlight"><code><span class="o">.(</span><span class="nc">Message</span><span class="o">.</span><span class="na">class</span><span class="o">,</span> <span class="n">m</span> <span class="o">-&gt;</span> <span class="n">newFooFromMessage</span><span class="o">(</span><span class="n">m</span><span class="o">))</span>
</code></pre></div>  </div>
</blockquote>

<blockquote  style="background-color: #fbebf3; border-color: #d63583;">
  <p><strong>Bean Definitions override</strong></p>
  <p>Java DSL은 플로우 정의에서 인라인으로 정의한 객체를 빈으로 등록할 수 있을 뿐만 아니라, 기존에 주입된 빈을 재사용할 수도 있다. 인라인 객체와 기존 빈 정의에 같은 이름을 사용하는 빈이 있으면 설정이 잘못되었음을 나타내는 <code class="highlighter-rouge">BeanDefinitionOverrideException</code>이 발생한다. 하지만 <code class="highlighter-rouge">prototype</code> 빈을 처리할 땐, <code class="highlighter-rouge">BeanFactory</code>에서 <code class="highlighter-rouge">prototype</code> 빈을 호출할 때마다 새 인스턴스를 반환하기 때문에 integration flow processor에서 기존 빈 정의를 감지할 수 있는 방법이 없다. 따라서 빈 등록이나 기존 <code class="highlighter-rouge">prototype</code> 빈 정의를 검사하지 않고 반환된 인스턴스를 <code class="highlighter-rouge">IntegrationFlow</code>에서 그대로 사용하게 된다. 하지만 ID가 명시되어 있으면서, <code class="highlighter-rouge">prototype</code> 스코프에 이 이름으로 정의된 빈이 있는 경우엔, 해당 빈으로 <code class="highlighter-rouge">BeanFactory.initializeBean()</code>을 호출한다.</p>
</blockquote>

---

## 11.2. Message Channels

Java DSL은 `IntegrationFlowBuilder`와 EIP 메소드 말고도, `MessageChannel` 인스턴스를 설정할 수 있는 fluent API도 제공한다. `MessageChannel`을 설정할 땐 빌더 팩토리`MessageChannels`를 이용하면 된다. 사용 방법은 다음 예제를 참고해라:

```java
@Bean
public MessageChannel priorityChannel() {
    return MessageChannels.priority(this.mongoDbChannelMessageStore, "priorityGroup")
                        .interceptor(wireTap())
                        .get();
}
```

XML 설정에서 `input-channel`/`output-channel` 쌍을 연결했던 것처럼, 여기서는 `IntegrationFlowBuilder`의 EIP 메소드 `channel()`에서 `MessageChannels` 빌더 팩토리를 사용해 엔드포인트를 연결할 수 있다. 엔드포인트들은 기본적으로 `DirectChannel` 인스턴스와 연결되며, 이때 빈 이름은 `[IntegrationFlow.beanName].channel#[channelNameIndex]` 패턴을 사용한다. `MessageChannels` 빌더 팩토리를 인라인으로 사용해 이름이 없이 만들어진 채널에도 이 규칙을 적용한다. 하지만 `MessageChannels`의 모든 메소드는 `channelId`를 받는 메소드가 오버로딩되어 있어, `MessageChannel` 인스턴스의 빈 이름을 직접 설정할 수도 있다. `MessageChannel`에 대한 참조와 `beanName`은 빈 메소드를 호출해서 지정할 수 있다. 다음은 EIP 메소드 `channel()`을 사용하는 다양한 방법을 나타낸 예시다:

```java
@Bean
public MessageChannel queueChannel() {
    return MessageChannels.queue().get();
}

@Bean
public MessageChannel publishSubscribe() {
    return MessageChannels.publishSubscribe().get();
}

@Bean
public IntegrationFlow channelFlow() {
    return IntegrationFlows.from("input")
                .fixedSubscriberChannel()
                .channel("queueChannel")
                .channel(publishSubscribe())
                .channel(MessageChannels.executor("executorChannel", this.taskExecutor))
                .channel("output")
                .get();
}
```

- `from("input")`은 "이 '입력' id를 가진`MessageChannel`을 찾아 사용하거나 새로 생성한다"는 것을 의미한다.
- `fixedSubscriberChannel()`은 `FixedSubscriberChannel` 인스턴스를 하나 생성해서 `channelFlow.channel#0`이라는 이름으로 등록한다.
- `channel("queueChannel")`은 동작 방식은 동일하지만 기존 `queueChannel` 빈을 사용한다.
- `channel(publishSubscribe())`는 빈 메소드를 참조하고 있다.
- `channel(MessageChannels.executor("executorChannel", this.taskExecutor))`는 `ExecutorChannel`에 `IntegrationComponentSpec`을 정의하고 `executorChannel`로 등록하는 `IntegrationFlowBuilder`다.
- `channel("output")`은 이름이 `output`인 빈이 이미 존재하지 않는다면, 이 이름으로 `DirectChannel` 빈을 등록한다.

참고: 위에서 정의한 `IntegrationFlow`는 유효한 정의이며, 여기서 사용한 채널들은 전부 `BridgeHandler` 인스턴스를 가진 엔드포인트에 적용된다.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>다른 <code class="highlighter-rouge">IntegrationFlow</code> 인스턴스에서 <code class="highlighter-rouge">MessageChannels</code> 팩토리를 통해 동일한 인라인 채널을 정의하지 않도록 주의해라. DSL 파서는 존재하지 않는 객체를 빈으로 등록하더라도, 다른 <code class="highlighter-rouge">IntegrationFlow</code> 컨테이너에 동일한 객체(<code class="highlighter-rouge">MessageChannel</code>)가 있는지를 판별할 수 없다. 다음은 잘못된 예시다:</p>
</blockquote>

```java
@Bean
public IntegrationFlow startFlow() {
    return IntegrationFlows.from("input")
                .transform(...)
                .channel(MessageChannels.queue("queueChannel"))
                .get();
}

@Bean
public IntegrationFlow endFlow() {
    return IntegrationFlows.from(MessageChannels.queue("queueChannel"))
                .handle(...)
                .get();
}
```

이 예제는 다음과 같은 예외를 발생시킨다:

```java
Caused by: java.lang.IllegalStateException:
Could not register object [queueChannel] under bean name 'queueChannel':
     there is already object [queueChannel] bound
	    at o.s.b.f.s.DefaultSingletonBeanRegistry.registerSingleton(DefaultSingletonBeanRegistry.java:129)
```

제대로 동작하게 만들려면 채널에 `@Bean`을 선언하고, 두 `IntegrationFlow` 인스턴스에서 이 빈 메소드를 사용해야 한다.

---

## 11.3. Pollers

Spring Integration은 `AbstractPollingEndpoint` 구현체를 위한 `PollerMetadata`를 설정할 수 있는 fluent API도 제공한다. 다음 예제와 같이 빌더 팩토리 `Pollers`를 사용해 공통 빈을 정의하거나, `IntegrationFlowBuilder` EIP 메소드에서 만든 구성에 메타정보를 설정할 수 있다:

```java
@Bean(name = PollerMetadata.DEFAULT_POLLER)
public PollerSpec poller() {
    return Pollers.fixedRate(500)
        .errorChannel("myErrors");
}
```

자세한 내용은 Javadoc에 있는 [`Pollers`](https://docs.spring.io/spring-integration/api/org/springframework/integration/dsl/Pollers.html)와 [`PollerSpec`](https://docs.spring.io/spring-integration/api/org/springframework/integration/dsl/PollerSpec.html)을 참고해라.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>DSL을 사용해 <code class="highlighter-rouge">PollerSpec</code>을 <code class="highlighter-rouge">@Bean</code>으로 설정한다면, 해당 빈 정의에선 <code class="highlighter-rouge">get()</code> 메소드를 호출하지 말아라. <code class="highlighter-rouge">PollerSpec</code>은 스펙에 따라 <code class="highlighter-rouge">PollerMetadata</code> 객체를 생성하고 모든 프로퍼티를 초기화하는 <code class="highlighter-rouge">FactoryBean</code>이다.</p>
</blockquote>

---

## 11.4. The `reactive()` Endpoint

5.5 버전부터 `ConsumerEndpointSpec`은 `reactive()` 설정 프로퍼티를 제공한다. 원한다면 customizer `Function<? super Flux<Message<?>>, ? extends Publisher<Message<?>>>`를 넘길 수 있다. 이 옵션은 입력 채널 유형과 관계없이 타겟 엔드포인트를 `ReactiveStreamsConsumer` 인스턴스로 설정하며, 입력 채널은 `IntegrationReactiveUtils.messageChannelToFlux()`를 통해 `Flux`로 변환한다. 함수를 지정하면 `Flux.transform()` 연산자에서 이 함수를 사용해서, 입력 채널의 리액티브 스트림 소스를 커스텀한다 (`publishOn()`, `log()`, `doOnNext()` 등).

다음은 최종 subscriber, producer와는 독립적으로 입력 채널의 스레드에서 `DirectChannel`로 publishing 스레드를 변경하는 방법을 보여주는 예시다:

```java
@Bean
public IntegrationFlow reactiveEndpointFlow() {
    return IntegrationFlows
            .from("inputChannel")
            .<String, Integer>transform(Integer::parseInt,
                    e -> e.reactive(flux -> flux.publishOn(Schedulers.parallel())))
            .get();
}
```

자세한 정보는 [리액티브 스트림즈 지원](../reactive-streams)을 참고해라.

---

## 11.5. DSL and Endpoint Configuration

모든 `IntegrationFlowBuilder` EIP 메소드는 람다 파라미터를 받는 메소드가 오버로딩되어 있어 `AbstractEndpoint` 인스턴스에 옵션을 제공할 수 있다 (`SmartLifecycle`, `PollerMetadata`, `request-handler-advice-chain` 등). 각각은 범용 인자들을 가지고 있어서, 다음과 같이 엔드포인트와, 컨텍스트 내 `MessageHandler`까지도 설정할 수 있다:

```java
@Bean
public IntegrationFlow flow2() {
    return IntegrationFlows.from(this.inputChannel)
                .transform(new PayloadSerializingTransformer(),
                       c -> c.autoStartup(false).id("payloadSerializingTransformer"))
                .transform((Integer p) -> p * 2, c -> c.advice(this.expressionAdvice()))
                .get();
}
```

참고로, `EndpointSpec`은 `id()` 메소드를 제공해서, 자동으로 만들어진 이름을 사용하는 대신 원하는 이름으로 엔드포인트 빈을 등록할 수 있다.

`MessageHandler`를 빈으로 참조하는 경우, DSL 정의에 `.advice()` 메소드가 있다면 기존 `adviceChain` 설정은 전부 재정의된다:

```java
@Bean
public TcpOutboundGateway tcpOut() {
    TcpOutboundGateway gateway = new TcpOutboundGateway();
    gateway.setConnectionFactory(cf());
    gateway.setAdviceChain(Collections.singletonList(fooAdvice()));
    return gateway;
}

@Bean
public IntegrationFlow clientTcpFlow() {
    return f -> f
        .handle(tcpOut(), e -> e.advice(testAdvice()))
        .transform(Transformers.objectToString());
}
```

즉, 이 설정에선 어드바이스 체인이 병합되는 게 아니라 `testAdvice()` 빈만 사용하게 된다.

---

## 11.6. Transformers

DSL API는 fluent 팩토리 `Transformers`를 제공하므로, EIP 메소드 `.transform()` 내에서 타겟 객체를 간편하게 인라인으로 정의할 수 있다. 사용 방법은 아래 예제를 참고해라:

```java
@Bean
public IntegrationFlow transformFlow() {
    return IntegrationFlows.from("input")
            .transform(Transformers.fromJson(MyPojo.class))
            .transform(Transformers.serializer())
            .get();
}
```

번거롭게 setter를 사용하 것보다 플로우 정의가 훨씬 더 간단해졌다. 참고로, `Transformers`를 사용해 타겟 `Transformer` 인스턴스를 `@Bean`으로 선언하고, 이 빈을 다시 `IntegrationFlow` 정의 내 빈 메소드로 사용할 수 있다. 그렇더라도 DSL 파서는 인라인 객체가 빈으로 정의되지 않았다면 빈 선언을 처리해준다.

좀 더 자세한 정보나 지원하는 팩토리 메소드들을 알아보려면 Javadoc에 있는 [Transformers](https://docs.spring.io/spring-integration/api/org/springframework/integration/dsl/Transformers.html)를 참고해라.

[람다와 `Message` 인자](#java-dsl-class-cast)도 함께 참고해라.

---

## 11.7. Inbound Channel Adapters

일반적으로 메시지 플로우는 인바운드 채널 어댑터로부터 시작된다 (ex. `<int-jdbc:inbound-channel-adapter>`). 이 어댑터는 `<poller>`를 함께 설정하고, 폴러는 주기적으로 `MessageSource<?>`에 메시지 생성을 요청한다. 그런데 Java DSL을 사용할 땐 `MessageSource<?>`에서 `IntegrationFlow`를 시작할 수도 있다. 이땐 빌더 팩토리 `IntegrationFlows`의 오버로딩 메소드 `IntegrationFlows.from(MessageSource<?> messageSource)`를 사용한다. `MessageSource<?>`를 빈으로 설정하고 이 메소드에 인자로 제공해주면 된다. `IntegrationFlows.from()`의 두 번째 파라미터는 `Consumer<SourcePollingChannelAdapterSpec>` 람다로, `SourcePollingChannelAdapter`에 대한 옵션을 제공할 수 있다 (ex. `PollerMetadata`, `SmartLifecycle`). 다음은 이 fluent API와 람다를 사용해 `IntegrationFlow`를 생성하는 예시다:

```java
@Bean
public MessageSource<Object> jdbcMessageSource() {
    return new JdbcPollingChannelAdapter(this.dataSource, "SELECT * FROM something");
}

@Bean
public IntegrationFlow pollingFlow() {
    return IntegrationFlows.from(jdbcMessageSource(),
                c -> c.poller(Pollers.fixedRate(100).maxMessagesPerPoll(1)))
            .transform(Transformers.toJson())
            .channel("furtherProcessChannel")
            .get();
}
```

`Message` 객체를 직접 빌드할 필요가 없을 땐 `java.util.function.Supplier`를 기반으로 동작하는 `IntegrationFlows.fromSupplier()` 메소드를 사용하면 된다. `Supplier.get()`의 호출 결과는 자동으로 `Message`로 감싸진다 (호출 결과가 `Message`가 아니라면).

---

## 11.8. Message Routers

Spring Integration은 기본적으로 여러가지 라우터들을 타입별로 제공하고 있다:

- `HeaderValueRouter`
- `PayloadTypeRouter`
- `ExceptionTypeRouter`
- `RecipientListRouter`
- `XPathRouter`

다른 여러가지 DSL `IntegrationFlowBuilder` EIP 메소드들과 마찬가지로, `route()` 메소드 역시 원하는 `AbstractMessageRouter` 구현체를 적용할 수도 있고, 간편히 SpEL 표현식을 `String`으로 제공하거나 `ref`-`method` 쌍을 사용할 수도 있다. 또한 `Consumer<RouterSpec<MethodInvokingRouter>>`에 람다를 사용해서 `route()`를 구성할 수도 있다. fluent API는 다음 예제와 같이 `channelMapping(String key, String channelName)` 쌍과 같은 `AbstractMappingMessageRouter` 옵션도 제공한다:

```java
@Bean
public IntegrationFlow routeFlowByLambda() {
    return IntegrationFlows.from("routerInput")
            .<Integer, Boolean>route(p -> p % 2 == 0,
                    m -> m.suffix("Channel")
                            .channelMapping(true, "even")
                            .channelMapping(false, "odd")
            )
            .get();
}
```

다음은 간단한 표현식 기반 라우터 예시다:

```java
@Bean
public IntegrationFlow routeFlowByExpression() {
    return IntegrationFlows.from("routerInput")
            .route("headers['destChannel']")
            .get();
}
```

`routeToRecipients()` 메소드는 아래 보이는 것처럼 `Consumer<RecipientListRouterSpec>`을 인자로 받는다:

```java
@Bean
public IntegrationFlow recipientListFlow() {
    return IntegrationFlows.from("recipientListInput")
            .<String, String>transform(p -> p.replaceFirst("Payload", ""))
            .routeToRecipients(r -> r
                    .recipient("thing1-channel", "'thing1' == payload")
                    .recipientMessageSelector("thing2-channel", m ->
                            m.getHeaders().containsKey("recipient")
                                    && (boolean) m.getHeaders().get("recipient"))
                    .recipientFlow("'thing1' == payload or 'thing2' == payload or 'thing3' == payload",
                            f -> f.<String, String>transform(String::toUpperCase)
                                    .channel(c -> c.queue("recipientListSubFlow1Result")))
                    .recipientFlow((String p) -> p.startsWith("thing3"),
                            f -> f.transform("Hello "::concat)
                                    .channel(c -> c.queue("recipientListSubFlow2Result")))
                    .recipientFlow(new FunctionExpression<Message<?>>(m ->
                                    "thing3".equals(m.getPayload())),
                            f -> f.channel(c -> c.queue("recipientListSubFlow3Result")))
                    .defaultOutputToParentFlow())
            .get();
}
```

`.routeToRecipients()` 정의에서 `.defaultOutputToParentFlow()`를 사용하면, 라우터의 `defaultOutput`을 게이트웨이로 설정해서 메인 플로우에서 매칭되지 않는 메시지들을 계속해서 처리해나갈 수 있다.

[람다와 `Message` 인자](#java-dsl-class-cast)도 함께 참고해라.

---

## 11.9. Splitters

splitter를 생성할 땐 EIP 메소드 `split()`을 사용해라. `split()` 메소드는 페이로드가 `Iterable`이나 `Iterator`, `Array`, `Stream`, 리액티브 `Publisher`라면 기본적으로 각 항목을 개별 메시지로 출력한다. `split()` 메소드는 람다와, SpEL 표현식, `AbstractMessageSplitter` 구현체를 모두 받는다. 아니면 파라미터 없이 사용해서 `DefaultMessageSplitter`를 제공해도 된다. 아래 코드는 `split()`에 람다를 제공하는 예제다: 

```java
@Bean
public IntegrationFlow splitFlow() {
    return IntegrationFlows.from("splitInput")
              .split(s -> s.applySequence(false).delimiters(","))
              .channel(MessageChannels.executor(taskExecutor()))
              .get();
}
```

위 예제에서 생성하는 splitter는 콤마로 구분하는 `String`을 담고있는 메시지를 분할한다.

[람다와 `Message` 인자](#java-dsl-class-cast)도 함께 참고해라.

---

## 11.10. Aggregators and Resequencers

`Aggregator`는 `Splitter`와 반대되는 개념이다. `Aggregator`는 메시지들의 시퀀스를 단일 메시지로 집계하기 때문에 더 복잡할 수밖에 없다. 기본적으로 aggregator는 전달받은 메시지들의 페이로드 컬렉션을 담은 메시지를 반환한다. `Resequencer`에 적용되는 규칙 또한 동일하다. 다음은 splitter-aggregator 패턴의 전형적인 예시다:

```java
@Bean
public IntegrationFlow splitAggregateFlow() {
    return IntegrationFlows.from("splitAggregateInput")
            .split()
            .channel(MessageChannels.executor(this.taskExecutor()))
            .resequence()
            .aggregate()
            .get();
}
```

`split()` 메소드는 리스트를 개별 메시지로 분할해서 `ExecutorChannel`로 전송한다. `resequence()` 메소드는 메시지 헤더에 있는 세부 시퀀스 정보에 따라 메시지를 재정렬한다. `aggregate()` 메소드는 이 메시지들을 수집한다.

하지만 특히 중요한 건, release 전략과 correlation 전략을 지정해서 디폴트 동작을 변경할 수 있다는 거다. 다음 예제를 살펴보자:

```java
.aggregate(a ->
        a.correlationStrategy(m -> m.getHeaders().get("myCorrelationKey"))
            .releaseStrategy(g -> g.size() > 10)
            .messageStore(messageStore()))
```

위 예제에선 `myCorrelationKey` 헤더를 가진 메시지들을 연계해서 최소 10개가 누적되면 메시지를 놓아준다<sup>release</sup>.

EIP 메소드 `resequence()`에도 비슷한 람다 설정을 제공하고 있다.

---

## 11.11. Service Activators and the `.handle()` method

EIP 메소드 `.handle()`의 목적은 원하는 `MessageHandler` 구현체나 특정 POJO의 메소드를 호출하는 거다. 또는 람다 표현식을 사용해 원하는 "움직임"을 정의하는 식으로도 활용할 수 있다. Spring Integration은 이럴 때 사용할 수 있는 범용 함수형 인터페이스 `GenericHandler<P>`를 도입했다. 이 인터페이스의 `handle` 메소드를 실행하려면 두 가지 파라미터, `P payload`와 `MessageHeaders headers`가 필요하다 (5.1부터). 두 파라미터를 이용해 다음과 같이 플로우를 정의할 수 있다:

```java
@Bean
public IntegrationFlow myFlow() {
    return IntegrationFlows.from("flow3Input")
        .<Integer>handle((p, h) -> p * 2)
        .get();
}
```

위 예제에선 정수를 받아 전부 두 배로 만든다.

그런데 Spring Integration의 주요 목표 중 하나는 `loose coupling`으로, 런타임에 메시지 페이로드를 메시지 핸들러의 타겟 인자 타입으로 변환해준다. 자바는 람다 클래스에 제네릭 타입을 리졸브해주지 않기 때문에, 대부분의 EIP 메소드와 `LambdaMessageProcessor`에 별도 `payloadType` 인자를 추가해서 해결하고 있다. 즉, 변환 작업을 스프링의 `ConversionService`에 위임한다. `ConversionService`는 지정한 `type`을 사용해 요청 메시지를 타겟 메소드 인자로 변환해준다. 다음 예시는 그에 따라 바뀌는 `IntegrationFlow`를 보여준다:

```java
@Bean
public IntegrationFlow integerFlow() {
    return IntegrationFlows.from("input")
            .<byte[], String>transform(p - > new String(p, "UTF-8"))
            .handle(Integer.class, (p, h) -> p * 2)
            .get();
}
```

또한 `ConversionService` 내에 `BytesToIntegerConverter`를 등록해주면 `.transform()`을 추가로 작성하지 않아도 된다:

```java
@Bean
@IntegrationConverter
public BytesToIntegerConverter bytesToIntegerConverter() {
   return new BytesToIntegerConverter();
}

@Bean
public IntegrationFlow integerFlow() {
    return IntegrationFlows.from("input")
             .handle(Integer.class, (p, h) -> p * 2)
            .get();
}
```

[람다와 `Message` 인자](#java-dsl-class-cast)도 함께 참고해라.

---

## 11.12. Operator gateway()

`IntegrationFlow` 정의에서 사용하는 `gateway()` 연산자는 특별한 서비스 activator 구현체로, 입력 채널을 통해 다른 엔드포인트나 통합 플로우를 호출하고 응답을 기다린다. 기술적으로 보면 `<chain>` 정의로 감싼 `<gateway>` 컴포넌트와 역할이 동일하며 ([체인 내에서 체인 호출하기](../messaging-routing/#863-calling-a-chain-from-within-a-chain) 참고), 플로우를 보다 깔끔하고 직관적으로 만들어준다. 논리적으로, 그리고 비즈니스 관점에서 보면, 타겟 통합 솔루션 곳곳에서 기능을 배포하고 재사용할 수 있게 해주는 메시징 게이트웨이다 ([메시징 게이트웨이](../messaging-endpoints/#104-messaging-gateways) 참고). 이 연산자는 목적에 따라 다양한 메소드가 오버로딩되어 있다.

- `gateway(String requestChannel)`은 이름을 통해 특정한 엔드포인트의 입력 채널에 메시지를 전송한다.
- `gateway(MessageChannel requestChannel)`은 직접 주입한 엔드포인트의 입력 채널에 메시지를 전송한다.
- `gateway(IntegrationFlow flow)`는 지정한 `IntegrationFlow`의 입력 채널로 메시지를 전송한다.

이 메소들은 모두 타겟 `GatewayMessageHandler`와 각각의 `AbstractEndpoint`를 설정할 수 있는 `Consumer<GatewayEndpointSpec>`을 두 번째 인자로 받는 메소드도 함께 제공하고 있다. 또한 `IntegrationFlow` 기반 메소드들을 사용하면, 기존 `IntegrationFlow` 빈을 호출하거나, `IntegrationFlow` 함수형 인터페이스에 람다를 배치해 특정 플로우를 하위 플로우로 선언할 수 있다. 람다는 `private` 메소드로 따로 추출해도 좋다:

```java
@Bean
IntegrationFlow someFlow() {
        return IntegrationFlows
                .from(...)
                .gateway(subFlow())
                .handle(...)
                .get();
}

private static IntegrationFlow subFlow() {
        return f -> f
                .scatterGather(s -> s.recipientFlow(...),
                        g -> g.outputProcessor(MessageGroup::getOne))
}
```

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>다운스트림 플로우가 항상 응답을 반환하진 않을 땐 <code class="highlighter-rouge">requestTimeout</code>을 0으로 설정해야 호출 스레드가 무한정 중단<sup>hang</sup>되지 않는다. 그러면 플로우는 해당 지점에서 종료되고 다른 작업을 할 수 있도록 스레드를 반환한다.</p>
</blockquote>

---

## 11.13. Operator log()

Spring Integration 플로우를 통해 메시지 여정을 기록할 수 있는 (`<logging-channel-adapter>`) 간편한 연산자 `log()`를 제공한다. 내부적으로는 `LoggingHandler`를 구독자로 가지는 `WireTap` `ChannelInterceptor`로 구현하며, 들어오는 메시지를 다음 엔드포인트나 현재 채널에 기록하는 일을 담당한다. 다음은 `LoggingHandler`를 사용하는 방법을 보여주는 예시다:

```java
.filter(...)
.log(LoggingHandler.Level.ERROR, "test.category", m -> m.getHeaders().getId())
.route(...)
```

위 예제에선 필터를 통과한 메세지에 한해서, 라우팅하기 전 `test.category`에 `id` 헤더를 `ERROR` 레벨로 기록한다.

이 연산자를 플로우 끝에서 사용하면 단방향 핸들러로 정의돼 플로우를 마무리한다. 응답을 생성하는 플로우로 만들려면 `log()` 다음에 간단한 `bridge()`를 사용하거나, 5.1 버전부터는 `logAndReply()` 연산자로 대체해주면 된다. `logAndReply`는 플로우 마지막에만 사용할 수 있다.

---

## 11.14. Operator intercept()

5.3 버전부터 `intercept()` 연산자를 사용하면 플로우의 현재 `MessageChannel`에 하나 이상의 `ChannelInterceptor` 인스턴스를 등록할 수 있다. `MessageChannels` API를 통해 명시적인 `MessageChannel`을 만드는 대신 이 방법을 사용할 수 있다. 다음은 `MessageSelectingInterceptor`를 사용해 예외를 가진 특정 메시지들을 거부하는 예시다:

```java
.transform(...)
.intercept(new MessageSelectingInterceptor(m -> m.getPayload().isValid()))
.handle(...)
```

---

## 11.15. `MessageChannelSpec.wireTap()`

Spring Integration에는 `.wireTap()` fluent API `MessageChannelSpec` 빌더가 포함돼 있다. 아래 예제에선 `wireTap` 메소드를 사용해 입력을 로그로 남긴다:

```java
@Bean
public QueueChannelSpec myChannel() {
    return MessageChannels.queue()
            .wireTap("loggingFlow.input");
}

@Bean
public IntegrationFlow loggingFlow() {
    return f -> f.log();
}
```
<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p><code class="highlighter-rouge">MessageChannel</code>이 <code class="highlighter-rouge">InterceptableChannel</code>의 인스턴스이면 <code class="highlighter-rouge">log()</code>, <code class="highlighter-rouge">wireTap()</code>, <code class="highlighter-rouge">intercept()</code> 연산자는 현재 <code class="highlighter-rouge">MessageChannel</code>에 적용된다. 그 외는 현재 설정된 엔드포인트에 대한 플로우에 중간 <code class="highlighter-rouge">DirectChannel</code>이 주입된다. 아래 예제에선 <code class="highlighter-rouge">DirectChannel</code>이 <code class="highlighter-rouge">InterceptableChannel</code>을 구현하고 있기 때문에 <code class="highlighter-rouge">WireTap</code> 인터셉터는 <code class="highlighter-rouge">myChannel</code>에 직접 추가된다:</p>
  <div class="language-java highlighter-rouge"><div class="highlight"><pre class="highlight"><code><span class="nd">@Bean</span>
<span class="nc">MessageChannel</span> <span class="nf">myChannel</span><span class="o">()</span> <span class="o">{</span>
    <span class="k">return</span> <span class="k">new</span> <span class="nf">DirectChannel</span><span class="o">();</span>
<span class="o">}</span>
<span class="o">...</span>
    <span class="o">.</span><span class="na">channel</span><span class="o">(</span><span class="n">myChannel</span><span class="o">())</span>
    <span class="o">.</span><span class="na">log</span><span class="o">()</span>
<span class="o">}</span>
</code></pre></div>  </div>
</blockquote>

현재 `MessageChannel`이 `InterceptableChannel`을 구현한 채널이 아니라면, 자동으로 `DirectChannel`과 `BridgeHandler`가 `IntegrationFlow`에 주입되고, `WireTap`은 새로 만들어진 이 `DirectChannel`에 추가된다. 아래 예제를 보면 채널 선언이 따로 없다:

```java
.handle(...)
.log()
}
```

위 예제에서는 (채널을 선언하지 않은 경우라면 항상) 자동으로 `DirectChannel` 하나가 `IntegrationFlow`의 현재 위치에 주입되며, 현재 설정에 있는 ([앞에서 설명한](#1111-service-activators-and-the-handle-method) `.handle()`로 설정한) `ServiceActivatingHandler`의 출력 채널로 이 `DirectChannel`을 사용한다.

---

## 11.16. Working With Message Flows

`IntegrationFlowBuilder`는 메시지 플로우에 연결할 통합 구성 요소들을 생성할 수 있는 최상위 API를 제공한다. 통합 요구사항을 단일 플로우만으로 해결할 수 있다면 (생각보다 자주 있는 일이다) `IntegrationFlowBuilder`를 사용하는 게 가장 편하다. 그 외는 `MessageChannel` 인스턴스들을 통해 `IntegrationFlow` 인스턴스들을 조인할 수 있다.

Spring Integration에서 `MessageFlow`는 기본적으로 하나의 "체인"으로 동작한다. 즉, 엔드포인트들은 자동으로, 그리고 암묵적으로 `DirectChannel` 인스턴스들로 연결된다. 하지만 메시지 플로우가 실제로 하나의 체인으로 구성되는 것은 아닌데, 그보단 훨씬 더 유연한 편이다. 예를 들어 `inputChannel`의 이름을 알고 있다면 (즉, 직접 명시적으로 정의했다면) 플로우 내에서 원하는 구성 요소에 메시지를 보낼 수 있다. 다이렉트 채널 대신 채널 어댑터를 사용할 수 있도록 (원격 전송 프로토콜, 파일 I/O 등을 활성화하는 용도로) 플로우 내에서 외부에 정의한 채널을 참조할 수도 있다. 이와 같이 DSL에선 Spring Integration `chain` 요소는 크게 중요하지 않기 때문에 따로 지원하지 않는다.

Spring Integration Java DSL은 다른 설정 옵션들이 그러하듯 빈 정의 모델을 생성하며, 기존 스프링 프레임워크 `@Configuration` 인프라를 기반으로 동작한다. 그렇기 때문에 XML 정의와 함께 사용할 수 있으며, Spring Integration의 메시지 처리 어노테이션 설정과 연결해서 사용할 수 있다.

람다를 사용해서 직접 `IntegrationFlow` 인스턴스를 정의할 수도 있다. 다음은 그 방법을 보여주는 예제다:

```java
@Bean
public IntegrationFlow lambdaFlow() {
    return f -> f.filter("World"::equals)
                   .transform("Hello "::concat)
                   .handle(System.out::println);
}
```

이 정의로 만들어지는 통합 구성 요소들 역시 암묵적으로 다이렉트 채널로 연결된다. 여기서 유일한 제약은 이 플로우는 `lambdaFlow.input`으로 이름 지어진 다이렉트 채널로 시작된다는 거다. 참고로 람다 플로우는 `MessageSource`나 `MessageProducer`에서 시작할 수 없다.

5.1 버전부터 이런 류의 `IntegrationFlow`는 프록시로 감싸지기 때문에 라이프사이클을 제어할 수 있으며, 내부적으로 연결된 `StandardIntegrationFlow`의 `inputChannel`에 접근할 수 있게 된다.

5.0.6 버전부터 `IntegrationFlow`의 구성 요소로 만들어지는 빈 이름에는 플로우 빈 이름과 점(`.`)이 프리픽스로 붙는다. 예를 들어, 위 예제에서 `.transform("Hello "::concat)`으로 만들어진 `ConsumerEndpointFactoryBean`의 이름은 `lambdaFlow.o.s.i.config.ConsumerEndpointFactoryBean#0`이 된다. (`o.s.i`는 페이지에 맞게 `org.springframework.integration`을 줄인 것이다.) 이 엔드포인트에 해당하는 `Transformer` 구현체 빈의 이름은 `lambdaFlow.transformer#0`인데 (5.1부터), 이땐 `MethodInvokingTransformer` 클래스의 풀 네임<sup>fully qualified name</sup>을 사용하는 대신 구성 요소의 타입을 사용한다. 플로우 내에서 자동으로 빈 이름을 생성해야 할 때는 모든 `NamedComponent`에 동일한 패턴을 적용한다. 이렇게 자동으로 만들어지는 빈 이름에 플로우 ID를 붙이는 목적은 향후 로그를 파싱하거나, 특정 분석 툴로 구성 요소들을 그룹화하거나, 런타임에 통합 플로우를 동시에 등록하려고 할 때 경쟁 조건을 방지하기 위함이다. 자세한 내용은 [동적인 런타임 통합 플로우](#1121-dynamic-and-runtime-integration-flows)를 참고해라.

---

## 11.17. `FunctionExpression`

We introduced the `FunctionExpression` class (an implementation of SpEL’s `Expression` interface) to let us use lambdas and `generics`. The `Function<T, R>` option is provided for the DSL components, along with an `expression` option, when there is the implicit `Strategy` variant from Core Spring Integration. The following example shows how to use a function expression:

`FunctionExpression` 클래스(SpEL의 `Expression` 인터페이스 구현체)를 도입했으므로 이제 람다와 `generic`을 사용할 수 있다. Core Spring Integration의 암시적인 `Strategy` 변형이 있는 경우 DSL 구성 요소에는 `expression` 옵션과 함께 `Function<T, R>` 옵션을 제공한다. 다음은 함수 표현식을 사용하는 예제다:

```java
.enrich(e -> e.requestChannel("enrichChannel")
            .requestPayload(Message::getPayload)
            .propertyFunction("date", m -> new Date()))
```

`FunctionExpression`은 `SpelExpression`과 마찬가지로 런타임 타입 변환도 지원한다.

---

## 11.18. Sub-flows support

일부 `if…else`, `publish-subscribe` 구성 요소들은 서브 플로우를 사용해 로직이나 매핑 정보를 지정할 수 있다. 가장 간단한 샘플은 아래 보이는 `.publishSubscribeChannel()`이다:

```java
@Bean
public IntegrationFlow subscribersFlow() {
    return flow -> flow
            .publishSubscribeChannel(Executors.newCachedThreadPool(), s -> s
                    .subscribe(f -> f
                            .<Integer>handle((p, h) -> p / 2)
                            .channel(c -> c.queue("subscriber1Results")))
                    .subscribe(f -> f
                            .<Integer>handle((p, h) -> p * 2)
                            .channel(c -> c.queue("subscriber2Results"))))
            .<Integer>handle((p, h) -> p * 3)
            .channel(c -> c.queue("subscriber3Results"));
}
```

별도의 `IntegrationFlow` `@Bean`을 정의해도 동일한 결과를 얻을 수 있지만, 서브 플로우를 정의해 로직을 구성하는 것도 유용하다. 서브 플로우를 이용하면 코드는 더 간결해지고 가독성이 더 좋아진다.

5.3 버전부터 브로커 기반 메시지 채널에 서브 플로우 구독자들을 설정할 수 있도록, `BroadcastCapableChannel` 기반 `publishSubscribeChannel()` 구현체를 제공한다. 예를 들어 이제 `Jms.publishSubscribeChannel()`에 여러 구독자를 서브 플로우로 설정할 수 있다:

```java
@Bean
public BroadcastCapableChannel jmsPublishSubscribeChannel() {
    return Jms.publishSubscribeChannel(jmsConnectionFactory())
                .destination("pubsub")
                .get();
}

@Bean
public IntegrationFlow pubSubFlow() {
    return f -> f
            .publishSubscribeChannel(jmsPublishSubscribeChannel(),
                    pubsub -> pubsub
                            .subscribe(subFlow -> subFlow
                                .channel(c -> c.queue("jmsPubSubBridgeChannel1")))
                            .subscribe(subFlow -> subFlow
                                .channel(c -> c.queue("jmsPubSubBridgeChannel2"))));
}

@Bean
public BroadcastCapableChannel jmsPublishSubscribeChannel(ConnectionFactory jmsConnectionFactory) {
    return (BroadcastCapableChannel) Jms.publishSubscribeChannel(jmsConnectionFactory)
            .destination("pubsub")
            .get();
}
```

유사한 `publish-subscribe` 서브 플로우 구성으로 `.routeToRecipients()` 메소드를 사용할 수 있다.

또 다른 예는 `.filter()` 메소드에서 `.discardChannel()` 대신 `.discardFlow()`를 사용하는 거다.

`.route()`는 따로 살펴볼 필요가 있다. 다음 예제를 생각해보자:

```java
@Bean
public IntegrationFlow routeFlow() {
    return f -> f
            .<Integer, Boolean>route(p -> p % 2 == 0,
                    m -> m.channelMapping("true", "evenChannel")
                            .subFlowMapping("false", sf ->
                                    sf.<Integer>handle((p, h) -> p * 3)))
            .transform(Object::toString)
            .channel(c -> c.queue("oddChannel"));
}
```

`.channelMapping()`은 일반적인 `Router` 매핑과 동일하게 동작하지만 `.subFlowMapping()`으로 인해 서브 플로우는 메인 플로우에 묶이게 된다. 다시 말하면, 라우터의 서브 플로우는 `.route()` 이후 전부 메인 플로우로 돌아간다.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>간혹 <code class="highlighter-rouge">.subFlowMapping()</code>에서 기존 <code class="highlighter-rouge">IntegrationFlow</code> <code class="highlighter-rouge">@Bean</code>을 참조해야 할 때가 있다. 다음은 그 방법을 보여주는 예시다:</p>



  <div class="language-java highlighter-rouge"><div class="highlight"><pre class="highlight"><code><span class="nd">@Bean</span>
<span class="kd">public</span> <span class="nc">IntegrationFlow</span> <span class="nf">splitRouteAggregate</span><span class="o">()</span> <span class="o">{</span>
    <span class="k">return</span> <span class="n">f</span> <span class="o">-&gt;</span> <span class="n">f</span>
            <span class="o">.</span><span class="na">split</span><span class="o">()</span>
            <span class="o">.&lt;</span><span class="nc">Integer</span><span class="o">,</span> <span class="nc">Boolean</span><span class="o">&gt;</span><span class="n">route</span><span class="o">(</span><span class="n">o</span> <span class="o">-&gt;</span> <span class="n">o</span> <span class="o">%</span> <span class="mi">2</span> <span class="o">==</span> <span class="mi">0</span><span class="o">,</span>
                    <span class="n">m</span> <span class="o">-&gt;</span> <span class="n">m</span>
                            <span class="o">.</span><span class="na">subFlowMapping</span><span class="o">(</span><span class="kc">true</span><span class="o">,</span> <span class="n">oddFlow</span><span class="o">())</span>
                            <span class="o">.</span><span class="na">subFlowMapping</span><span class="o">(</span><span class="kc">false</span><span class="o">,</span> <span class="n">sf</span> <span class="o">-&gt;</span> <span class="n">sf</span><span class="o">.</span><span class="na">gateway</span><span class="o">(</span><span class="n">evenFlow</span><span class="o">())))</span>
            <span class="o">.</span><span class="na">aggregate</span><span class="o">();</span>
<span class="o">}</span>

<span class="nd">@Bean</span>
<span class="kd">public</span> <span class="nc">IntegrationFlow</span> <span class="nf">oddFlow</span><span class="o">()</span> <span class="o">{</span>
    <span class="k">return</span> <span class="n">f</span> <span class="o">-&gt;</span> <span class="n">f</span><span class="o">.</span><span class="na">handle</span><span class="o">(</span><span class="n">m</span> <span class="o">-&gt;</span> <span class="nc">System</span><span class="o">.</span><span class="na">out</span><span class="o">.</span><span class="na">println</span><span class="o">(</span><span class="s">"odd"</span><span class="o">));</span>
<span class="o">}</span>

<span class="nd">@Bean</span>
<span class="kd">public</span> <span class="nc">IntegrationFlow</span> <span class="nf">evenFlow</span><span class="o">()</span> <span class="o">{</span>
    <span class="k">return</span> <span class="n">f</span> <span class="o">-&gt;</span> <span class="n">f</span><span class="o">.</span><span class="na">handle</span><span class="o">((</span><span class="n">p</span><span class="o">,</span> <span class="n">h</span><span class="o">)</span> <span class="o">-&gt;</span> <span class="s">"even"</span><span class="o">);</span>
<span class="o">}</span>
</code></pre></div>  </div>

  <p>이때, 서브 플로우에서 응답을 받아 메인 플로우를 이어가야 할 때는 위 예제에서 처럼 <code class="highlighter-rouge">IntegrationFlow</code> 빈 참조(또는 해당 입력 채널)를 <code class="highlighter-rouge">.gateway()</code>로 감싸줘야 한다. 위 예제에선 <code class="highlighter-rouge">oddFlow()</code> 참조는 <code class="highlighter-rouge">.gateway()</code>로 감싸지 않았다. 즉, 이 라우팅 브랜치에선 응답을 기대하지 않는다는 뜻이다. 그렇지 않았다면 다음과 유사한 예외를 만나게 될 거다:</p>

  <div class="language-java highlighter-rouge"><div class="highlight"><pre class="highlight"><code><span class="nc">Caused</span> <span class="nl">by:</span> <span class="n">org</span><span class="o">.</span><span class="na">springframework</span><span class="o">.</span><span class="na">beans</span><span class="o">.</span><span class="na">factory</span><span class="o">.</span><span class="na">BeanCreationException</span><span class="o">:</span>
    <span class="nc">The</span> <span class="err">'</span><span class="n">currentComponent</span><span class="err">'</span> <span class="o">(</span><span class="n">org</span><span class="o">.</span><span class="na">springframework</span><span class="o">.</span><span class="na">integration</span><span class="o">.</span><span class="na">router</span><span class="o">.</span><span class="na">MethodInvokingRouter</span><span class="err">@</span><span class="mi">7965</span><span class="n">a51c</span><span class="o">)</span>
    <span class="n">is</span> <span class="n">a</span> <span class="n">one</span><span class="o">-</span><span class="n">way</span> <span class="err">'</span><span class="nc">MessageHandler</span><span class="err">'</span> <span class="n">and</span> <span class="n">it</span> <span class="n">isn</span><span class="err">'</span><span class="n">t</span> <span class="n">appropriate</span> <span class="n">to</span> <span class="n">configure</span> <span class="err">'</span><span class="n">outputChannel</span><span class="err">'</span><span class="o">.</span>
    <span class="nc">This</span> <span class="n">is</span> <span class="n">the</span> <span class="n">end</span> <span class="n">of</span> <span class="n">the</span> <span class="n">integration</span> <span class="n">flow</span><span class="o">.</span>
</code></pre></div>  </div>
  <p>서브 플로우를 람다로 구성할 땐 서브 플로우의와 request-reply 상호 작용은 프레임워크가 처리해주므로 게이트웨이가 필요하지 않다.</p>

</blockquote>

서브 플로우는 원하는 만큼 중첩할 수 있지만 권장하진 않는다. 사실, 아무리 라우터라고 하더라도, 하나의 플로우 안에 복잡한 서브 플로우를 잔뜩 추가한다면 금방 스파게티 코드가 탄생할 거고 사람이 분석하기가 점점 어려워질 거다.

> DSL로 서브 플로우를 설정하는 경우, 일반적으로 채널이 필요한 구성 요소를 설정하고 해당 서브 플로우가 `channel()` 요소로 시작한다면, 프레임워크는 암묵적으로 해당 구성 요소의 출력 채널과 서브 플로우의 입력 채널 사이에 `bridge()`를 하나 배치한다. 예를 들어 아래 `filter` 정의에서는:
>
> ```java
> .filter(p -> p instanceof String, e -> e
> 	.discardFlow(df -> df
>                       .channel(MessageChannels.queue())
>                       ...)
> ```
>
> 프레임워크는 내부적으로 `MessageFilter.discardChannel`에 주입할 `DirectChannel` 빈을 하나 생성한다. 그런 다음 서브 플로우를 이 다이렉트 채널로 시작하는 `IntegrationFlow`로 감싸고, 이 플로우에 명시한 `channel()` 앞에 `bridge`를 배치한다. 기존 `IntegrationFlow` 빈을 서브 플로우로 참조한다면 (람다 등으로 인라인 서브 플로우를 정의하지 않고), 프레임워크에서 플로우 빈의 첫 번째 채널을 리졸브할 수 있기 때문에 이런 브리지가 필요하지 않다. 인라인 서브 플로우에선 아직 입력 채널을 사용할 수 없다.

---

## 11.19. Using Protocol Adapters

지금까지 보여준 모든 예제들은 DSL이 Spring Integration 프로그래밍 모델을 사용해 어떻게 메시지 처리 아키텍처를 지원하는지를 보여주고 있다. 하지만 아직 진짜 통합은 해본 적 없다. 진짜 통합을 진행하려면 HTTP, JMS, AMQP, TCP, JDBC, FTP, SMTP 등을 통해 원격 리소스에 액세스하거나 로컬 파일 시스템에 접근해야 한다. Spring Integration은 이것들을 전부 지원하며, 사실 그 이상을 지원하고 있다. 이상적으로 보면 DSL에서도 이런 것들을 전부 최고 수준으로 지원해야 하는 게 맞지만, 이런 것들을 전부 구현하고 Spring Integration에 새로운 어댑터가 추가되면 또 다시 반영하기란 어려운 일이다. 그래서 DSL은 지속적으로 Spring Integration을 따라잡을 것이란 기대가 있다.

그렇기 때문에 Spring Integration은 프로토콜별 메시지 처리 동작을 매끄럽게 정의할 수 있는 고수준 API를 제공하고 있다. 여기서는 팩토리와 빌더 패턴, 람다를 사용한다. 팩토리 클래스는 프로토콜 전용 Spring Integration 모듈에 있는 구현체를 위한 XML 네임스페이스와 역할이 동일하기 때문에 "네임스페이스 팩토리"라고 생각해도 좋다. 현재 Spring Integration Java DSL은 `Amqp`, `Feed`, `Jms`, `Files`, `(S)Ftp`, `Http`, `JPA`, `MongoDb`, `TCP/UDP`,  `Mail`, `WebFlux`, `Scripts`를 위한 네임스페이스 팩토리를 지원한다. 다음은 이 중 세 가지의 사용법을 보여주는 예제다 (`Amqp`, `Jms`, `Mail`):

```java
@Bean
public IntegrationFlow amqpFlow() {
    return IntegrationFlows.from(Amqp.inboundGateway(this.rabbitConnectionFactory, queue()))
            .transform("hello "::concat)
            .transform(String.class, String::toUpperCase)
            .get();
}

@Bean
public IntegrationFlow jmsOutboundGatewayFlow() {
    return IntegrationFlows.from("jmsOutboundGatewayChannel")
            .handle(Jms.outboundGateway(this.jmsConnectionFactory)
                        .replyContainer(c ->
                                    c.concurrentConsumers(3)
                                            .sessionTransacted(true))
                        .requestDestination("jmsPipelineTest"))
            .get();
}

@Bean
public IntegrationFlow sendMailFlow() {
    return IntegrationFlows.from("sendMailChannel")
            .handle(Mail.outboundAdapter("localhost")
                            .port(smtpPort)
                            .credentials("user", "pw")
                            .protocol("smtp")
                            .javaMailProperties(p -> p.put("mail.debug", "true")),
                    e -> e.id("sendMailEndpoint"))
            .get();
}
```

위 예제는 "네임스페이스 팩토리"를 인라인 어댑터로 선언해서 사용하는 방법을 보여준다. 하지만 네임스페이스 팩토리를 `@Bean` 정의에서 사용하면 `IntegrationFlow` 메소드 체인의 가독성을 더 개선할 수 있다.

> 우리는 다른 것보다 우선적으로 이 네임스페이스 팩토리들에 대한 커뮤니티 피드백을 요청하고 있다. 또한 다음에 지원해야 하는 어댑터와 게이트웨이의 우선 순위에 대한 의견도 감사히 받고있다.

이 레퍼런스 매뉴얼에 있는 프로토콜 전용 챕터를 보면 더 많은 자바 DSL 샘플 코드를 확인할 수 있다.

그외 다른 프로토콜 채널 어댑터는 다음과 같이 일반적인 빈들로 설정해서 `IntegrationFlow`에 연결해줄 수 있다:

```java
@Bean
public QueueChannelSpec wrongMessagesChannel() {
    return MessageChannels
            .queue()
            .wireTap("wrongMessagesWireTapChannel");
}

@Bean
public IntegrationFlow xpathFlow(MessageChannel wrongMessagesChannel) {
    return IntegrationFlows.from("inputChannel")
            .filter(new StringValueTestXPathMessageSelector("namespace-uri(/*)", "my:namespace"),
                    e -> e.discardChannel(wrongMessagesChannel))
            .log(LoggingHandler.Level.ERROR, "test.category", m -> m.getHeaders().getId())
            .route(xpathRouter(wrongMessagesChannel))
            .get();
}

@Bean
public AbstractMappingMessageRouter xpathRouter(MessageChannel wrongMessagesChannel) {
    XPathRouter router = new XPathRouter("local-name(/*)");
    router.setEvaluateAsString(true);
    router.setResolutionRequired(false);
    router.setDefaultOutputChannel(wrongMessagesChannel);
    router.setChannelMapping("Tags", "splittingChannel");
    router.setChannelMapping("Tag", "receivedChannel");
    return router;
}
```

---

## 11.20. `IntegrationFlowAdapter`

`IntegrationFlow` 인터페이스는 아래 예제와 같이 직접 구현해서 스캔 대상에 오를 수 있는 컴포넌트로 지정할 수 있다:

```java
@Component
public class MyFlow implements IntegrationFlow {

    @Override
    public void configure(IntegrationFlowDefinition<?> f) {
        f.<String, String>transform(String::toUpperCase);
    }

}
```

이 컴포넌트는 `IntegrationFlowBeanPostProcessor`에서 가져가 파싱해서 애플리케이션 컨텍스트에 등록한다.

편의상 기본 구현 클래스인 `IntegrationFlowAdapter`를 제공하고 있다. 이 클래스를 사용하면 느슨한 결합<sup>loosely coupled</sup>이라는 아키텍처의 장점을 누릴 수 있다. 이 클래스에서 `from()` 메소드 중 하나를 사용해 `IntegrationFlowDefinition`을 생성하려면 다음과 같은 `buildFlow()` 메소드 구현부가 필요하다:

```java
@Component
public class MyFlowAdapter extends IntegrationFlowAdapter {

    private final AtomicBoolean invoked = new AtomicBoolean();

    public Date nextExecutionTime(TriggerContext triggerContext) {
          return this.invoked.getAndSet(true) ? null : new Date();
    }

    @Override
    protected IntegrationFlowDefinition<?> buildFlow() {
        return from(this::messageSource,
                      e -> e.poller(p -> p.trigger(this::nextExecutionTime)))
                 .split(this)
                 .transform(this)
                 .aggregate(a -> a.processor(this, null), null)
                 .enrichHeaders(Collections.singletonMap("thing1", "THING1"))
                 .filter(this)
                 .handle(this)
                 .channel(c -> c.queue("myFlowAdapterOutput"));
    }

    public String messageSource() {
         return "T,H,I,N,G,2";
    }

    @Splitter
    public String[] split(String payload) {
         return StringUtils.commaDelimitedListToStringArray(payload);
    }

    @Transformer
    public String transform(String payload) {
         return payload.toLowerCase();
    }

    @Aggregator
    public String aggregate(List<String> payloads) {
           return payloads.stream().collect(Collectors.joining());
    }

    @Filter
    public boolean filter(@Header Optional<String> thing1) {
            return thing1.isPresent();
    }

    @ServiceActivator
    public String handle(String payload, @Header String thing1) {
           return payload + ":" + thing1;
    }

}
```

---

## 11.21. Dynamic and Runtime Integration Flows

`IntegrationFlow`와 관련해서 필요한 모든 구성 요소들은 런타임에 등록해줄 수 있다. 5.0 버전 이전에는 `BeanFactory.registerSingleton()`을 훅으로 사용했었다. 스프링 프레임워크 `5.0`부터 코드를 통해 `BeanDefinition`을 등록할 수 있도록 `instanceSupplier`를 훅으로 사용한다. 다음은 코드를 통해 빈을 등록하는 방법을 보여주는 코드다:

```java
BeanDefinition beanDefinition =
         BeanDefinitionBuilder.genericBeanDefinition((Class<Object>) bean.getClass(), () -> bean)
               .getRawBeanDefinition();

((BeanDefinitionRegistry) this.beanFactory).registerBeanDefinition(beanName, beanDefinition);
```

위 예시에서 `instanceSupplier` 훅은 `genericBeanDefinition` 메소드에서 사용하는 마지막 파라미터로, 람다로 넘겨주고 있다.

필요한 모든 빈 초기화와 라이프사이클 처리는 표준 컨텍스트 설정 빈 정의와 마찬가지로 자동으로 수행된다.

개발 경험을 단순화할 수 있도록 Spring Integration은, 다음 예제와 같이 런타임에 `IntegrationFlow` 인스턴스를 등록하고 관리할 수 있게 해주는 `IntegrationFlowContext`를 도입했다:

```java
@Autowired
private AbstractServerConnectionFactory server1;

@Autowired
private IntegrationFlowContext flowContext;

...

@Test
public void testTcpGateways() {
    TestingUtilities.waitListening(this.server1, null);

    IntegrationFlow flow = f -> f
            .handle(Tcp.outboundGateway(Tcp.netClient("localhost", this.server1.getPort())
                    .serializer(TcpCodecs.crlf())
                    .deserializer(TcpCodecs.lengthHeader1())
                    .id("client1"))
                .remoteTimeout(m -> 5000))
            .transform(Transformers.objectToString());

    IntegrationFlowRegistration theFlow = this.flowContext.registration(flow).register();
    assertThat(theFlow.getMessagingTemplate().convertSendAndReceive("foo", String.class), equalTo("FOO"));
}
```

이 클래스는 여러 가지 설정 옵션을 통해 유사한 플로우를 여러 인스턴스로 만들어야 할 때 유용하다. 이때는 옵션을 순회하면서 반복문 안에서 `IntegrationFlow` 인스턴스를 만들고 등록하면 된다. 또 다른 케이스는 스프링 기반이 아닌 데이터 소스를 즉석에서 생성해야 하는 경우다. 예를 들면 아래 보이는 리액티브 스트림즈 이벤트 소스가 그렇다:

```java
Flux<Message<?>> messageFlux =
    Flux.just("1,2,3,4")
        .map(v -> v.split(","))
        .flatMapIterable(Arrays::asList)
        .map(Integer::parseInt)
        .map(GenericMessage<Integer>::new);

QueueChannel resultChannel = new QueueChannel();

IntegrationFlow integrationFlow =
    IntegrationFlows.from(messageFlux)
        .<Integer, Integer>transform(p -> p * 2)
        .channel(resultChannel)
        .get();

this.integrationFlowContext.registration(integrationFlow)
            .register();
```

`IntegrationFlowRegistrationBuilder`(`IntegrationFlowContext.registration()`의 반환값)를 사용하면 등록할 `IntegrationFlow` 빈의 이름을 지정하고, `autoStartup` 여부를 조정하고, Spring Integration 이외 다른 빈을 등록할 수 있다. 일반적으로 이런 빈들은 커넥션 팩토리나 (AMQP, JMS, (S)FTP, TCP/UDP 등), serializer/deserializer, 기타 다른 서포트 구성 요소들에 해당한다.

동적으로 등록한 `IntegrationFlow`와 관련한 모든 빈들은 더 이상 필요하지 않다면 `IntegrationFlowRegistration.destroy()` 콜백을 사용해 제거할 수 있다. 자세한 내용은 [`IntegrationFlowContext` Javadoc](https://docs.spring.io/spring-integration/api/org/springframework/integration/dsl/context/IntegrationFlowContext.html)을 참고해라.

> 5.0.6 버전부터 `IntegrationFlow` 정의에서 만드는 모든 빈들의 이름엔 앞엔 플로우 ID가 붙는다. 그렇기 때문에 항상 플로우 ID를 명시해주는 것이 좋다. 그렇지 않으면 `IntegrationFlow`를 위한 빈 이름을 생성해서 해당 빈을 등록할 때 `IntegrationFlowContext`에서 동기화 장벽을 시작한다. 만들어진 빈 이름 하나를 다른 `IntegrationFlow` 인스턴스에서 사용할 수 있는 경우 경쟁 조건을 피할 수 있도록, 빈 이름을 생성하는 작업과 빈을 등록하는 작업을 동기화한다.

또한 5.0.6 버전에서는 registration 빌더 API에 `useFlowIdAsPrefix()`라는 메소드를 새로 추가했다. 이 메소드를 활용하면 다음 예제와 같이 동일한 플로우를 여러 인스턴스로 선언할 때, 플로우들의 구성 요소가 동일한 ID를 가져도 빈 이름으로 충돌이 발생하지 않게 만들어줄 수 있다:

```java
private void registerFlows() {
    IntegrationFlowRegistration flow1 =
              this.flowContext.registration(buildFlow(1234))
                    .id("tcp1")
                    .useFlowIdAsPrefix()
                    .register();

    IntegrationFlowRegistration flow2 =
              this.flowContext.registration(buildFlow(1235))
                    .id("tcp2")
                    .useFlowIdAsPrefix()
                    .register();
}

private IntegrationFlow buildFlow(int port) {
    return f -> f
            .handle(Tcp.outboundGateway(Tcp.netClient("localhost", port)
                    .serializer(TcpCodecs.crlf())
                    .deserializer(TcpCodecs.lengthHeader1())
                    .id("client"))
                .remoteTimeout(m -> 5000))
            .transform(Transformers.objectToString());
}
```

이 경우 첫 번째 플로우의 메시지 핸들러는 `tcp1.client.handler`라는 빈 이름으로 참조할 수 있다.

> `useFlowIdAsPrefix()`를 사용할 땐 `id` 속성을 지정해야 한다.

---

## 11.22. `IntegrationFlow` as a Gateway

`IntegrationFlow`는 다음과 같이 `GatewayProxyFactoryBean` 구성 요소를 제공하는 서비스 인터페이스에서 시작할 수 있다:

```java
public interface ControlBusGateway {

    void send(String command);
}

...

@Bean
public IntegrationFlow controlBusFlow() {
    return IntegrationFlows.from(ControlBusGateway.class)
            .controlBus()
            .get();
}
```

인터페이스 메소드를 위한 프록시는 모두 채널과 함께 제공돼서 `IntegrationFlow`의 다음 통합 구성 요소에 메시지를 전송할 수 있다. 서비스 인터페이스는 `@MessagingGateway` 어노테이션으로, 메소드는 `@Gateway` 어노테이션으로 마킹할 수 있다. 하지만 어노테이션을 사용하더라도 `requestChannel`은 무시되며, `IntegrationFlow`의 다음 구성 요소에 대한 내부 채널로 재정의된다. 그렇지 않았다면 `IntegrationFlow`를 사용해 이런 설정을 만드는 것 자체가 의미 없었을 거다.

기본적으로 `GatewayProxyFactoryBean`의 빈 이름은 컨벤션에 따라 `[FLOW_BEAN_NAME.gateway]`와 같이 정해진다. `@MessagingGateway.name()` 속성이나 팩토리 메소드를 오버로딩한 `IntegrationFlows.from(Class<?> serviceInterface, Consumer<GatewayProxySpec> endpointConfigurer)`를 사용하면 이 ID를 변경할 수 있다. 또한 인터페이스 위에 선언한 `@MessagingGateway` 어노테이션의 모든 속성이 타겟 `GatewayProxyFactoryBean`에 적용된다. 어노테이션 설정을 적용할 수 없는 경우엔 `Consumer<GatewayProxySpec>`을 받는 메소드를 사용하면 타겟 프록시에 적절한 옵션을 제공할 수 있다. 이 DSL 메소드는 5.2 버전부터 사용할 수 있다.

Java 8에선 다음과 같이 `java.util.function` 인터페이스를 사용해서도 통합 게이트웨이를 만들 수 있다:

```java
@Bean
public IntegrationFlow errorRecovererFlow() {
    return IntegrationFlows.from(Function.class, (gateway) -> gateway.beanName("errorRecovererFunction"))
            .handle((GenericHandler<?>) (p, h) -> {
                throw new RuntimeException("intentional");
            }, e -> e.advice(retryAdvice()))
            .get();
}
```

이 `errorRecovererFlow`는 다음과 같이 사용할 수 있다:

```java
@Autowired
@Qualifier("errorRecovererFunction")
private Function<String, String> errorRecovererFlowGateway;
```

---

## 11.23. DSL Extensions

5.3 버전부터는 `IntegrationFlowExtension`을 도입해서, EIP 복합<sup>composite</sup> 연산자로 기존 Java DSL을 확장하고 커스텀할 수 있다. `IntegrationFlow` 빈 정의에서 사용할 수 있는 메소드를 제공하는 이 클래스를 상속하기만 하면 된다. 이 익스텐션 클래스는 커스텀 `IntegrationComponentSpec` 설정에도 사용할 수 있다. 예를 들어 누락된 옵션이나 디폴트 옵션을 기존 `IntegrationComponentSpec` 익스텐션에서 구현할 수 있다. 아래 샘플은 커스텀 복합<sup>composite</sup> 연산자와, 디폴트 커스텀 `outputProcessor`에 `AggregatorSpec` 익스텐션을 사용하는 모습을 보여준다:

```java
public class CustomIntegrationFlowDefinition
        extends IntegrationFlowExtension<CustomIntegrationFlowDefinition> {

    public CustomIntegrationFlowDefinition upperCaseAfterSplit() {
        return split()
                .transform("payload.toUpperCase()");
    }

    public CustomIntegrationFlowDefinition customAggregate(Consumer<CustomAggregatorSpec> aggregator) {
        return register(new CustomAggregatorSpec(), aggregator);
    }

}

public class CustomAggregatorSpec extends AggregatorSpec {

    CustomAggregatorSpec() {
        outputProcessor(group ->
                group.getMessages()
                        .stream()
                        .map(Message::getPayload)
                        .map(String.class::cast)
                        .collect(Collectors.joining(", ")));
    }

}
```

이 익스텐션에서 만든 DSL 연산자는 익스텐션 클래스를 반환해야 메소드 체인 플로우에서 활용할 수 있다. 익스텐션 클래스를 반환하면 신규 DSL 연산자와 기존 DSL 연산자를 모두 이용해 타겟 `IntegrationFlow`를 정의할 수 있다:

```java
@Bean
public IntegrationFlow customFlowDefinition() {
    return
            new CustomIntegrationFlowDefinition()
                    .log()
                    .upperCaseAfterSplit()
                    .channel("innerChannel")
                    .customAggregate(customAggregatorSpec ->
                            customAggregatorSpec.expireGroupsUponCompletion(true))
                    .logAndReply();
}
```

---

## 11.24. Integration Flows Composition

Spring Integration에서 1급 시민으로서 추상화되어있는 `MessageChannel`이 있다면, 언제나 통합 플로우를 여러 개 조합할 수 있다. 플로우에 있는 모든 엔드포인트의 입력 채널은 원하는 엔드포인트로 메시지를 전송하는 데 사용할 수 있으며, 꼭 이 채널을 출력으로 가지고 있지 않아도 된다. 더 나아가면 `@MessagingGateway` 인터페이스, Content Enricher 컴포넌트, `<chain>`과 같은 복합<sup>composite</sup> 엔드포인트, 이제는 `IntegrationFlow` 빈까지 있기 때문에 (ex. `IntegrationFlowAdapter`), 충분히 쉽게 비지니스 로직을 짧고, 재사용 가능하게 분할할 수 있다. 메시지를 송수신할 `MessageChannel`만 잘 알고 있다면 플로우를 원하는 대로 조립할 수 있다.

`5.5.4` 버전부터 `IntegrationFlows`엔 팩토리 메소드 `from(IntegrationFlow)`가 추가되어, 더 많은 것들을 `MessageChannel`로 추상화하고 최종 사용자에겐 상세 구현 정보를 숨길 수 있다. 이 메소드를 사용하면 기존 플로우의 출력에서 현재 `IntegrationFlow`를 시작할 수 있다:

```java
@Bean
IntegrationFlow templateSourceFlow() {
    return IntegrationFlows.fromSupplier(() -> "test data")
            .channel("sourceChannel")
            .get();
}

@Bean
IntegrationFlow compositionMainFlow(IntegrationFlow templateSourceFlow) {
    return IntegrationFlows.from(templateSourceFlow)
            .<String, String>transform(String::toUpperCase)
            .channel(c -> c.queue("compositionMainFlowResult"))
            .get();
}
```

한편, `IntegrationFlowDefinition`엔 현재 플로우를 다른 플로우의 입력 채널에서 이어가기 위한 터미널 연산자 `to(IntegrationFlow)`를 추가했다:

```java
@Bean
IntegrationFlow mainFlow(IntegrationFlow otherFlow) {
    return f -> f
            .<String, String>transform(String::toUpperCase)
            .to(otherFlow);
}

@Bean
IntegrationFlow otherFlow() {
    return f -> f
            .<String, String>transform(p -> p + " from other flow")
            .channel(c -> c.queue("otherFlowResultChannel"));
}
```

플로우 중간에 껴 넣는 구성은 기존 EIP 메소드 `gateway(IntegrationFlow)`로 간단히 완성할 수 있다. 이렇게 하면 아무리 복잡한 플로우라도 훨씬 간단하고 재사용할 수 있는 코드 블록들로 구성할 수 있다. 예를 들어, 의존성에 `IntegrationFlow` 빈들의 라이브러리를 추가할 수 있으며, 이 빈들의 설정 클래스를 최종 프로젝트로 임포트해서 `IntegrationFlow`를 정의할 때 주입해주기만 하면 된다.