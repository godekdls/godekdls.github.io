---
title: Message Routing
category: Spring Integration
order: 13
permalink: /Spring%20Integration/messaging-routing/
description: 메시지 라우터 인터페이스와 구현체들
image: ./../../images/springintegration/logo.png
lastmod: 2022-01-05T21:30:00+09:00
comments: true
originalRefName: 스프링 인티그레이션
originalRefLink: https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/index-single.html#messaging-routing-chapter
parent: Core Messaging
parentUrl: /Spring%20Integration/core-messaging/
---
<script>defaultLanguages = ['java']</script>

---

이 챕터에선 Spring Integration을 사용해 메시지를 라우팅하는 방법을 자세히 다룬다.

### 목차

- [8.1. Routers](#81-routers)
  + [8.1.1. Overview](#811-overview)
  + [8.1.2. Common Router Parameters](#812-common-router-parameters)
    * [Inside and Outside of a Chain](#inside-and-outside-of-a-chain)
    * [Top-Level (Outside of a Chain)](#top-level-outside-of-a-chain)
  + [8.1.3. Router Implementations](#813-router-implementations)
    * [PayloadTypeRouter](#payloadtyperouter)
    * [HeaderValueRouter](#headervaluerouter)
    * [RecipientListRouter](#recipientlistrouter)
    * [RecipientListRouterManagement](#recipientlistroutermanagement)
    * [XPath Router](#xpath-router)
    * [Routing and Error Handling](#routing-and-error-handling)
  + [8.1.4. Configuring a Generic Router](#814-configuring-a-generic-router)
    * [Configuring a Content-based Router with XML](#configuring-a-content-based-router-with-xml)
  + [8.1.5. Routers and the Spring Expression Language (SpEL)](#815-routers-and-the-spring-expression-language-spel)
    * [Configuring a Router with Annotations](#configuring-a-router-with-annotations)
  + [8.1.6. Dynamic Routers](#816-dynamic-routers)
    * [Manage Router Mappings using the Control Bus](#manage-router-mappings-using-the-control-bus)
    * [Manage Router Mappings by Using JMX](#manage-router-mappings-by-using-jmx)
    * [Routing Slip](#routing-slip)
  + [8.1.7. Process Manager Enterprise Integration Pattern](#817-process-manager-enterprise-integration-pattern)
- [8.2. Filter](#82-filter)
  + [8.2.1. Configuring a Filter with XML](#821-configuring-a-filter-with-xml)
  + [8.2.2. Configuring a Filter with Annotations](#822-configuring-a-filter-with-annotations)
- [8.3. Splitter](#83-splitter)
  + [8.3.1. Programming Model](#831-programming-model)
    * [Iterators](#iterators)
    * [Stream and Flux](#stream-and-flux)
  + [8.3.2. Configuring a Splitter with XML](#832-configuring-a-splitter-with-xml)
  + [8.3.3. Configuring a Splitter with Annotations](#833-configuring-a-splitter-with-annotations)
- [8.4. Aggregator](#84-aggregator)
  + [8.4.1. Functionality](#841-functionality)
  + [8.4.2. Programming Model](#842-programming-model)
    * [AggregatingMessageHandler](#aggregatingmessagehandler)
    * [ReleaseStrategy](#releasestrategy)
    * [Aggregating Large Groups](#aggregating-large-groups)
    * [Correlation Strategy](#correlation-strategy)
    * [Lock Registry](#lock-registry)
    * [Avoiding Deadlocks](#avoiding-deadlocks)
  + [8.4.3. Configuring an Aggregator in Java DSL](#843-configuring-an-aggregator-in-java-dsl)
    * [Configuring an Aggregator with XML](#configuring-an-aggregator-with-xml)
    * [Configuring an Aggregator with Annotations](#configuring-an-aggregator-with-annotations)
  + [8.4.4. Managing State in an Aggregator: MessageGroupStore](#844-managing-state-in-an-aggregator-messagegroupstore)
  + [8.4.5. Flux Aggregator](#845-flux-aggregator)
  + [8.4.6. Condition on the Message Group](#846-condition-on-the-message-group)
- [8.5. Resequencer](#85-resequencer)
  + [8.5.1. Functionality](#851-functionality)
  + [8.5.2. Configuring a Resequencer](#852-configuring-a-resequencer)
- [8.6. Message Handler Chain](#86-message-handler-chain)
  + [8.6.1. Configuring a Chain](#861-configuring-a-chain)
  + [8.6.2. Using the 'id' Attribute](#862-using-the-id-attribute)
  + [8.6.3. Calling a Chain from within a Chain](#863-calling-a-chain-from-within-a-chain)
- [8.7. Scatter-Gather](#87-scatter-gather)
  + [8.7.1. Functionality](#871-functionality)
    * [Auction](#auction)
    * [Distribution](#distribution)
  + [8.7.2. Configuring a Scatter-Gather Endpoint](#872-configuring-a-scatter-gather-endpoint)
  + [8.7.3. Error Handling](#873-error-handling)
- [8.8. Thread Barrier](#88-thread-barrier)

---

## 8.1. Routers

이번 섹션에선 라우터가 어떻게 동작하는지를 설명하며, 다음과 같은 주제를 다룬다:

- [개요](#811-overview)
- [공통 라우터 파라미터들](#812-common-router-parameters)
- [라우터 구현체들](#813-router-implementations)
- [범용 라우터 설정하기](#814-configuring-a-generic-router)
- [라우터와 SpEL<sup>Spring Expression Language</sup>](#815-routers-and-the-spring-expression-language-spel)
- [다이나믹 라우터](#816-dynamic-routers)

### 8.1.1. Overview

라우터는 수많은 메시징 아키텍처에서 없어서는 안 되는 요소다. 라우터는 메시지 채널에서 메시지를 컨슘하고, 가지고 있는 조건 셋에 따라 컨슘한 각 메시지를 하나 이상의 다른 메시지 채널로 전달해준다.

Spring Integration은 다음과 같은 라우터를 제공한다:

- [Payload Type Router](#payloadtyperouter)
- [Header Value Router](#headervaluerouter)
- [Recipient List Router](#recipientlistrouter)
- [XPath Router (XML 모듈에 들어있다)](#xpath-router)
- [Error Message Exception Type Router](#routing-and-error-handling)
- [(범용) Router](#814-configuring-a-generic-router)

라우터 구현체들은 다양한 설정 파라미터를 공통으로 사용하고 있다. 하지만 라우터마다 몇 가지 차이점이 존재한다. 게다가 설정 파라미터를 사용할 수 있는지는 라우터를 체인 안에서 사용하는지, 바깥에서 사용하는지에 따라 달라진다. 바로 바로 참고할 수 있도록 사용 가능한 모든 속성들은 아래 두 테이블에 정리해뒀다.

다음은 체인 바깥에 있는 라우터에서 사용할 수 있는 설정 파라미터들을 정리한 테이블이다:

**Table 4. Routers Outside of a Chain**

| Attribute              | router                                                       | header value router                                          | xpath router                                                 | payload type router                                          | recipient list route                                         | exception type router                                        |
| :--------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| apply-sequence         | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) |
| default-output-channel | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) |
| resolution-required    | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) |
| ignore-send-failures   | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) |
| timeout                | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) |
| id                     | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) |
| auto-startup           | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) |
| input-channel          | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) |
| order                  | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) |
| method                 | ![tickmark](/images/springintegration/tickmark.png) |                                                              |                                                              |                                                              |                                                              |                                                              |
| ref                    | ![tickmark](/images/springintegration/tickmark.png) |                                                              |                                                              |                                                              |                                                              |                                                              |
| expression             | ![tickmark](/images/springintegration/tickmark.png) |                                                              |                                                              |                                                              |                                                              |                                                              |
| header-name            |                                                              | ![tickmark](/images/springintegration/tickmark.png) |                                                              |                                                              |                                                              |                                                              |
| evaluate-as-string     |                                                              |                                                              | ![tickmark](/images/springintegration/tickmark.png) |                                                              |                                                              |                                                              |
| xpath-expression-ref   |                                                              |                                                              | ![tickmark](/images/springintegration/tickmark.png) |                                                              |                                                              |                                                              |
| converter              |                                                              |                                                              | ![tickmark](/images/springintegration/tickmark.png) |                                                              |                                                              |                                                              |

다음은 체인 안에 있는 라우터에서 사용할 수 있는 설정 파라미터들을 정리한 테이블이다:

**Table 5. Routers Inside of a Chain**

| Attribute              | router                                                       | header value router                                          | xpath router                                                 | payload type router                                          | recipient list router                                        | exception type router                                        |
| :--------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| apply-sequence         | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) |
| default-output-channel | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) |
| resolution-required    | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) |
| ignore-send-failures   | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) |
| timeout                | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) | ![tickmark](/images/springintegration/tickmark.png) |
| id                     |                                                              |                                                              |                                                              |                                                              |                                                              |                                                              |
| auto-startup           |                                                              |                                                              |                                                              |                                                              |                                                              |                                                              |
| input-channel          |                                                              |                                                              |                                                              |                                                              |                                                              |                                                              |
| order                  |                                                              |                                                              |                                                              |                                                              |                                                              |                                                              |
| method                 | ![tickmark](/images/springintegration/tickmark.png) |                                                              |                                                              |                                                              |                                                              |                                                              |
| ref                    | ![tickmark](/images/springintegration/tickmark.png) |                                                              |                                                              |                                                              |                                                              |                                                              |
| expression             | ![tickmark](/images/springintegration/tickmark.png) |                                                              |                                                              |                                                              |                                                              |                                                              |
| header-name            |                                                              | ![tickmark](/images/springintegration/tickmark.png) |                                                              |                                                              |                                                              |                                                              |
| evaluate-as-string     |                                                              |                                                              | ![tickmark](/images/springintegration/tickmark.png) |                                                              |                                                              |                                                              |
| xpath-expression-ref   |                                                              |                                                              | ![tickmark](/images/springintegration/tickmark.png) |                                                              |                                                              |                                                              |
| converter              |                                                              |                                                              | ![tickmark](/images/springintegration/tickmark.png) |                                                              |                                                              |                                                              |

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>Spring Integration 2.1부터 모든 라우터 구현체에서 라우터 파라미터를 좀더 표준화해서 사용한다. 그렇기 때문에 사소한 변경이지만 몇 가지는 이전 Spring Integration 기반 애플리케이션과 호환이 안 될 수도 있다.</p>
  <p>Spring Integration 2.1부터 <code class="highlighter-rouge">ignore-channel-name-resolution-failures</code> 속성은 제거되었으며, 관련 기능은 <code class="highlighter-rouge">resolution-required</code> 속성으로 통합됐다. 뿐만 아니라 <code class="highlighter-rouge">resolution-required</code> 속성은 이제 <code class="highlighter-rouge">true</code>가 기본값이다.</p>
  <p>이렇게 변경되기 전엔 <code class="highlighter-rouge">resolution-required</code> 속성은 <code class="highlighter-rouge">false</code>가 기본값이었으며, 어떤 채널로도 리졸브되지 않고 <code class="highlighter-rouge">default-output-channel</code> 또한 설정돼있지 않으면 아무런 경고 없이 메시지가 버려졌었다. 통합 이후에는 최소한 채널 하나로는 리졸브되어야 하며, 채널을 결정하지 못하면 (혹은 전송에 성공하지 못하면) 기본적으로 <code class="highlighter-rouge">MessageDeliveryException</code>이 발생한다.</p>
  <p>에러를 발생시키는 대신 메시지를 버리는 동작을 선호한다면 <code class="highlighter-rouge">default-output-channel="nullChannel"</code>을 설정하면 된다.</p>
</blockquote>



### 8.1.2. Common Router Parameters

이 섹션에선 모든 라우터에서 공통으로 사용하는 파라미터들을 설명한다 (이 챕터 앞에서 보여준 두 테이블에서 모든 칸에 체크되어 있는 파라미터들).

#### Inside and Outside of a Chain

다음 파라미터들은 체인 내부와 바깥에 있는 모든 라우터에서 유효하다.

- `apply-sequence`<br>
  이 속성으로는 각 메시지에 시퀀스 넘버와 사이즈 헤더를 추가해야 하는지 여부를 지정한다. 생략할 수 있으며, 생략 시 기본값은 `false`다.

- `default-output-channel`<br>
  이 속성을 설정하면 채널 리졸브 과정에서 채널을 반환하지 못했을 때 메시지를 전송할 채널의 참조를 제공할 수 있다. 디폴트 출력 채널을 제공하지 않으면 라우터는 예외를 던진다. 예외를 발생시키는 대신 메시지를 버리고 싶다면 디폴트 출력 채널 속성을 `nullChannel`로 설정해라.

  > `resolution-required`가 `false`이고 채널이 리졸브되지 않았을 때에만 `default-output-channel`로 메시지를 전송한다.

- `resolution-required`<br>
  이 속성으로는 채널명이 항상 존재하는 채널 인스턴스로 리졸브되어야 하는지를 지정한다. `true`로 설정하면 채널을 리졸브할 수 없을 땐 `MessagingException`이 발생한다. `false`로 설정하면 리졸브할 수 없는 채널들은 무시하게 된다. 생략할 수 있으며, 생략 시 기본값은 `true`다.

  > `resolution-required`가 `false`이고 채널이 리졸브되지 않았을 때에만 `default-output-channel`로 (지정했다면) 메시지를 전송한다.

- `ignore-send-failures`<br>
  `true`로 설정하면 메시지 채널로 전송에 실패해도 무시한다. `false`로 설정했다면 그대신 `MessageDeliveryException`이 발생하며, 라우터가 둘 이상의 채널을 리졸브하는 경우라면 이어지는 채널들엔 메시지를 전송하지 않는다.

  이 속성에 따른 정확한 동작은 메시지를 전송하는 `Channel` 유형에 따라 다르다. 예를 들어, 다이렉트 채널을 사용하는 경우 (단일 스레드), 멀리 떨어져있는 다운스트림 구성 요소에서 발생하는 예외로 인해 전송에 실패할 수도 있다. 하지만 단순한 큐 채널로 메시지를 전송할 때는 (비동기), 예외가 던져질 가능성은 상당히 희박하다.

  > 대부분의 라우터는 메시지를 단일 채널로 라우팅하지만, 둘 이상의 채널 이름을 반환하기도 한다. 예를 들면 `recipient-list-router`가 그렇다. 한 가지 채널로만 라우팅하는 라우터에서 이 속성을 `true`로 설정하면 발생한 모든 예외가 덮어지기 때문에 일반적으론 큰 의미를 찾을 수 없다. 이 경우 에러 플로우에서 발생한 예외는 플로우 진입점에서 캐치하는 것이 더 좋다. 그렇기 때문에 일반적으론 `ignore-send-failures` 속성을 `true`로 설정하는 것은 라우터 구현체가 채널 이름을 둘 이상 반환할 때가 좀더 의미있다고 볼 수 있다. 이때는 실패한 채널 다음에 있는 다른 채널들이 이어서 메시지를 수신할 거기 때문이다. 이 속성의 기본값은 `false`다.

- `timeout`<br>
  `timeout` 속성은 타겟 메시지 채널에 메시지를 전송할 때 최대로 기다릴 시간을 밀리초 단위로 지정한다. 기본적으론 send 작업은 무한정 블로킹된다.

#### Top-Level (Outside of a Chain)

다음 파라미터들은 체인 바깥에 있는 모든 최상위 라우터에서만 유효하다.

- `id`<br>
  내부 스프링 빈의 정의를 식별한다. 라우터에서 내부 스프링 빈은, 라우터의 `input-channel`이 `SubscribableChannel`인지 `PollableChannel`인지에 따라 각각 `EventDrivenConsumer`, `PollingConsumer`의 인스턴스가 된다. 이 속성은 생략 가능하다.

- `auto-startup`<br>
  이 속성은 "라이프사이클" 속성으로, 애플리케이션 컨텍스트를 기동하는 중에 이 구성 요소를 시작해야 하는지를 나타낸다. 이 속성은 생략할 수 있으며, 생략 시 기본값은 `true`다.

- `input-channel`<br>
  이 엔드포인트가 수신하는 메시지 채널.

- `order`<br>
  이 속성은 이 엔드포인트가 어떤 채널의 구독자로서 연결돼있을 때 호출할 순서를 정의한다. 특히 연결된 채널이 패일오버 디스패치 전략을 사용할 때 활용하곤 한다. 이 엔드포인트 자체가 큐를 가진 채널의 폴링 컨슈머인 경우엔 아무런 효과가 없다.

### 8.1.3. Router Implementations

메시지를 컨텐츠 기반으로 라우팅할 땐 종종 도메인에 특화된 로직이 필요하기 때문에, 대부분의 유스 케이스에선 Spring Integration의 XML 네임스페이스나 어노테이션을 이용해 POJO에 위임할 수 있는 옵션이 필요할 거다. 이 두 가지는 모두 뒤에서 논한다. 여기서는 먼저 공통 요구 사항을 충족하는 몇 가지 구현체들을 소개한다.

#### `PayloadTypeRouter`

아래 예시에 보이는 `PayloadTypeRouter`는 페이로드 타입을 매핑해서 정의한 채널로 메시지를 전송한다:

```xml
<bean id="payloadTypeRouter"
      class="org.springframework.integration.router.PayloadTypeRouter">
    <property name="channelMapping">
        <map>
            <entry key="java.lang.String" value-ref="stringChannel"/>
            <entry key="java.lang.Integer" value-ref="integerChannel"/>
        </map>
    </property>
</bean>
```

`PayloadTypeRouter` 설정은 Spring Integration에서 제공하는 네임스페이스로도 가능하다 ([`Namespace Support`](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/configuration.html#configuration-namespace) 참고). Spring Integration의 네임스페이스를 이용하면 사실상 `<router/>` 설정과 그 구현체(`<bean/>` 요소로 정의한)를 하나의 설정으로 만들 수 있어 더 간단해진다. 다음 예제는 위와 동일한 설정이지만, 네임스페이스 지원을 이용한 `PayloadTypeRouter` 설정을 보여준다:

```xml
<int:payload-type-router input-channel="routingChannel">
    <int:mapping type="java.lang.String" channel="stringChannel" />
    <int:mapping type="java.lang.Integer" channel="integerChannel" />
</int:payload-type-router>
```

다음은 자바를 이용한 동일한 라우터 설정 예시다:

```java
@ServiceActivator(inputChannel = "routingChannel")
@Bean
public PayloadTypeRouter router() {
    PayloadTypeRouter router = new PayloadTypeRouter();
    router.setChannelMapping(String.class.getName(), "stringChannel");
    router.setChannelMapping(Integer.class.getName(), "integerChannel");
    return router;
}
```

자바 DSL을 사용할 땐 두 가지 옵션이 있다.

먼저, 위에 있는 예제에서처럼 라우터 객체를 정의하는 방법이 있다:

```java
@Bean
public IntegrationFlow routerFlow1() {
    return IntegrationFlows.from("routingChannel")
            .route(router())
            .get();
}

public PayloadTypeRouter router() {
    PayloadTypeRouter router = new PayloadTypeRouter();
    router.setChannelMapping(String.class.getName(), "stringChannel");
    router.setChannelMapping(Integer.class.getName(), "integerChannel");
    return router;
}
```

라우터는 `@Bean`이어도 되지만 반드시 그래야 하는 것은 아니다. `@Bean`이 아니면 플로우에서 라우터를 등록한다.

둘째, 다음 예제처럼 DSL 플로우 자체 내에서 라우팅 함수를 정의해도 된다:

```java
@Bean
public IntegrationFlow routerFlow2() {
    return IntegrationFlows.from("routingChannel")
            .<Object, Class<?>>route(Object::getClass, m -> m
                    .channelMapping(String.class, "stringChannel")
                    .channelMapping(Integer.class, "integerChannel"))
            .get();
}
```

#### `HeaderValueRouter`

`HeaderValueRouter`는 헤더 값마다 설정된 매핑 정보를 이용해 메시지를 전송할 채널을 결정한다. `HeaderValueRouter`를 생성할 땐 평가할 헤더의 이름으로 초기화를 진행한다. 이때 헤더 값에는 아래 두 가지 중 하나를 사용할 수 있다:

- 임의의 값
- 채널 이름

헤더에 임의의 값을 저장할 땐 이런 헤더 값을 채널 이름으로 매핑해주는 설정이 별도로 필요하다. 그 외는 추가 설정은 필요하지 않다.

Spring Integration은 `HeaderValueRouter`를 위한 간단한 네임스페이스 기반 XML 설정을 제공한다. 다음은 헤더 값을 채널로 매핑해주는 설정을 가지고 있는 `HeaderValueRouter` 설정 예시다:

```xml
<int:header-value-router input-channel="routingChannel" header-name="testHeader">
    <int:mapping value="someHeaderValue" channel="channelA" />
    <int:mapping value="someOtherHeaderValue" channel="channelB" />
</int:header-value-router>
```

위에서 정의한 라우터는 리졸브 과정에서 채널을 결정하지 못하면 예외가 발생할 수 있다. 이때 예외를 던지기보단 리졸브되지 않은 메시지는 디폴트 출력 채널(`default-output-channel` 속성으로 정의)로 전송하고 싶다면 `resolution-required`를 `false`로 설정해라.

메세지가 가진 헤더 값에 매핑된 채널이 없으면 일반적으로 `default-output-channel`로 전송된다. 하지만 헤더 값에 매핑된 채널은 있지만 해당 채널을 리졸브할 수 없는 경우, `resolution-required` 속성을 `false`로 설정해야 `default-output-channel`로 메시지를 라우팅한다.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>이 속성은 Spring Integration 2.1부터 <code class="highlighter-rouge">ignore-channel-name-resolution-failures</code>에서 <code class="highlighter-rouge">resolution-required</code>로 변경됐다. <code class="highlighter-rouge">resolution-required</code> 속성의 기본값은 <code class="highlighter-rouge">true</code>다.</p>
</blockquote>

다음은 자바를 이용한 동일한 라우터 설정 예시다:

```java
@ServiceActivator(inputChannel = "routingChannel")
@Bean
public HeaderValueRouter router() {
    HeaderValueRouter router = new HeaderValueRouter("testHeader");
    router.setChannelMapping("someHeaderValue", "channelA");
    router.setChannelMapping("someOtherHeaderValue", "channelB");
    return router;
}
```

자바 DSL을 사용할 땐 두 가지 옵션이 있다. 먼저, 위에 있는 예제에서처럼 라우터 객체를 정의하는 방법이 있다:

```java
@Bean
public IntegrationFlow routerFlow1() {
    return IntegrationFlows.from("routingChannel")
            .route(router())
            .get();
}

public HeaderValueRouter router() {
    HeaderValueRouter router = new HeaderValueRouter("testHeader");
    router.setChannelMapping("someHeaderValue", "channelA");
    router.setChannelMapping("someOtherHeaderValue", "channelB");
    return router;
}
```

라우터는 `@Bean`이어도 되지만 반드시 그래야 하는 것은 아니다. `@Bean`이 아니면 플로우에서 라우터를 등록한다.

둘째, 다음 예제처럼 DSL 플로우 자체 내에서 라우팅 함수를 정의해도 된다:

```java
@Bean
public IntegrationFlow routerFlow2() {
    return IntegrationFlows.from("routingChannel")
            .route(Message.class, m -> m.getHeaders().get("testHeader", String.class),
                    m -> m
                        .channelMapping("someHeaderValue", "channelA")
                        .channelMapping("someOtherHeaderValue", "channelB"),
                e -> e.id("headerValueRouter"))
            .get();
}
```

헤더 값 자체가 채널 이름을 나타낸다면 헤더 값을 채널 이름에 매핑해주는 설정은 필요하지 않다. 다음은 이와 같이 헤더 값을 채널 이름에 매핑할 필요가 없는 라우터를 보여주는 예시다:

```xml
<int:header-value-router input-channel="routingChannel" header-name="testHeader"/>
```

> 채널 리졸브 동작은 Spring Integration 2.1부터 더 명확해졌다. 예를 들어 `default-output-channel` 속성을 생략하면, 라우터가 유효한 채널을 하나도 리졸브하지 못했고 `resolution-required`를 `false`로 설정해 채널 리졸브 실패를 전부 무시한 경우 `MessageDeliveryException`이 발생한다.
>
> 라우터는 기본적으로 메시지를 적어도 하나의 채널로는 라우팅할 수 있어야 한다. 정말로 메시지가 버려지길 원한다면 `default-output-channel` 역시 `nullChannel`로 설정해줘야 한다.

#### `RecipientListRouter`

`RecipientListRouter`는 메시지를 받으면 정적으로 정의돼있는 메시지 채널 목록으로 전송해준다. 다음은 `RecipientListRouter`를 생성하는 예시다:

```xml
<bean id="recipientListRouter"
      class="org.springframework.integration.router.RecipientListRouter">
    <property name="channels">
        <list>
            <ref bean="channel1"/>
            <ref bean="channel2"/>
            <ref bean="channel3"/>
        </list>
    </property>
</bean>
```

Spring Integration은 아래 예제에서 볼 수 있는 `RecipientListRouter` 설정을 위한 네임스페이스도 지원하고 있다 ([네임스페이스 지원](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/configuration.html#configuration-namespace) 참고):

```xml
<int:recipient-list-router id="customRouter" input-channel="routingChannel"
        timeout="1234"
        ignore-send-failures="true"
        apply-sequence="true">
  <int:recipient channel="channel1"/>
  <int:recipient channel="channel2"/>
</int:recipient-list-router>
```

다음은 자바를 이용한 동일한 라우터 설정 예시다:

```java
@ServiceActivator(inputChannel = "routingChannel")
@Bean
public RecipientListRouter router() {
    RecipientListRouter router = new RecipientListRouter();
    router.setSendTimeout(1_234L);
    router.setIgnoreSendFailures(true);
    router.setApplySequence(true);
    router.addRecipient("channel1");
    router.addRecipient("channel2");
    router.addRecipient("channel3");
    return router;
}
```

다음은 Java DSL을 이용한 동일한 라우터 설정 예시다:

```java
@Bean
public IntegrationFlow routerFlow() {
    return IntegrationFlows.from("routingChannel")
            .routeToRecipients(r -> r
                    .applySequence(true)
                    .ignoreSendFailures(true)
                    .recipient("channel1")
                    .recipient("channel2")
                    .recipient("channel3")
                    .sendTimeout(1_234L))
            .get();
}
```

> 여기서 'apply-sequence' 플래그의 효과는 publish-subscribe-channel에서와 동일하며, publish-subscribe-channel과 마찬가지로 `recipient-list-router`에서도 기본적으로 비활성화돼있다. 자세한 내용은 [`PublishSubscribeChannel` 설정](../messaging-channels/#publishsubscribechannel-configuration)을 참고해라.

`RecipientListRouter`를 설정할 땐 SpEL<sup>Spring Expression Language</sup>을 이용해 메세지를 받을 각 채널마다 셀렉터를 지정할 수도 있다. '선택적인 컨슈머'로 동작시키기 위해 '체인' 앞 부분에 필터를 두는 것과 유사하다. 하지만 이 경우엔 아래 예제에서 볼 수 있듯이 라우터 설정 하나만으로 구성할 수 있다:

```xml
<int:recipient-list-router id="customRouter" input-channel="routingChannel">
    <int:recipient channel="channel1" selector-expression="payload.equals('foo')"/>
    <int:recipient channel="channel2" selector-expression="headers.containsKey('bar')"/>
</int:recipient-list-router>
```

위 설정에선 `selector-expression` 속성에 있는 SpEL 표현식을 평가해서, 입력 메시지가 주어졌을 때 해당 채널<sup>recipient</sup>을 recipient 목록에 포함시킬지를 결정한다. 이때 표현식을 평가하면 반드시 boolean이 나와야 한다. 이 속성을 정의하지 않은 채널은 항상 recipient 목록에 포함된다.

#### `RecipientListRouterManagement`

4.1 버전부터 `RecipientListRouter`는 런타임에 동적으로 수신자<sup>recipient</sup>를 조작할 수 있는 여러 가지 동작들을 제공한다. 이런 관리성<sup>management</sup> 연산은 `RecipientListRouterManagement`를 통해 제공되며, `@ManagedResource` 어노테이션을 이용한다. 다음 예제와 같이 [컨트롤 버스](../system-management/#135-control-bus)를 이용할 수도 있고, JMX를 이용하는 방법도 있다:

```xml
<control-bus input-channel="controlBus"/>

<recipient-list-router id="simpleRouter" input-channel="routingChannelA">
   <recipient channel="channel1"/>
</recipient-list-router>

<channel id="channel2"/>
```

```java
messagingTemplate.convertAndSend(controlBus, "@'simpleRouter.handler'.addRecipient('channel2')");
```

애플리케이션이 기동하는 시점에는 `simpleRouter`에 `channel1`이라는 수신자<sup>recipient</sup>가 하나만 존재한다. 하지만 `addRecipient` 명령어를 실행하고 나면 `channel2`가 추가된다. "메시지에 들어있는 무언가에 관심을 새로 등록"하는 유스 케이스라고 할 수 있다. 일정 기간 동안은 라우터가 전달하는 메시지에 관심이 있을 수 있다면, 이 `recipient-list-router`를 구독할 것이며, 어느 시점에는 구독을 취소하면 된다.

런타임에 `<recipient-list-router>`를 관리해주는 이 management 연산 덕분에, 맨 처음엔 `<recipient>`를 설정하지 않아도 된다. 이때는 메시지에 매칭되는 수신자<sup>recipient</sup>가 없을 때의 `RecipientListRouter` 동작과 동일하다. `defaultOutputChannel`이 설정돼 있으면 메시지는 이곳으로 보내진다. 그 외는 `MessageDeliveryException`을 던진다.

#### XPath Router

XPath 라우터는 XML 모듈에 들어있다. [XPath를 이용해 XML 메시지 라우팅하기](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/xml.html#xml-xpath-routing)를 참고해라.

#### Routing and Error Handling

Spring Integration은 에러 메시지를 라우팅하기 위한 특별한 타입 기반 라우터 `ErrorMessageExceptionTypeRouter`를 제공한다. 에러 메시지는 `payload`가 `Throwable` 인스턴스인 메시지로 정의할 수 있다. `ErrorMessageExceptionTypeRouter`는 `PayloadTypeRouter`와 유사하다. 사실 거의 똑같다고 봐도 된다. 유일한 차이점은 `PayloadTypeRouter`는 페이로드 인스턴스의 인스턴스 계층 구조를 탐색해서 (ex. `payload.getClass().getSuperclass()`) 가장 구체적인 타입과 매핑된 채널 정보를 찾는 반면, `ErrorMessageExceptionTypeRouter`는 'exception causes'의 계층 구조를 탐색해 (ex. `payload.getCause()`) 가장 구체적인 `Throwable` 타입과 매핑된 채널을 찾으며, `mappingClass.isInstance(Cause)`를 사용해 해당 `cause`를 클래스나 다른 슈퍼 클래스에 매칭해본다는 점이다.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>이때는 채널의 매핑 순서가 중요하다. 즉, <code class="highlighter-rouge">RuntimeException</code>이 아닌 <code class="highlighter-rouge">IllegalArgumentException</code>에 매핑된 정보를 가져와야 하는 요구사항이 있다면, 라우터엔 <code class="highlighter-rouge">RuntimeException</code> 항목을 먼저 구성해야 한다.</p>
</blockquote>

> 4.3 버전부터 `ErrorMessageExceptionTypeRouter`는 초기화 단계에서 모든 매핑 클래스를 로드하기 때문에, 문제가 있다면 미리 `ClassNotFoundException`이 발생한다.

다음은 `ErrorMessageExceptionTypeRouter`를 설정하는 예시다:

```xml
<int:exception-type-router input-channel="inputChannel"
                           default-output-channel="defaultChannel">
    <int:mapping exception-type="java.lang.IllegalArgumentException"
                 channel="illegalChannel"/>
    <int:mapping exception-type="java.lang.NullPointerException"
                 channel="npeChannel"/>
</int:exception-type-router>

<int:channel id="illegalChannel" />
<int:channel id="npeChannel" />
```

### 8.1.4. Configuring a Generic Router

Spring Integration은 범용 라우터를 하나 제공하므로, 범용적인 목적으로 라우팅하는 데엔 이 라우터를 활용하면 된다 (Spring Integration이 제공하는, 각자의 분야에 특화돼 있는 다른 라우터들과는 상반된다).

#### Configuring a Content-based Router with XML

`router` 요소를 이용하면 라우터를 입력 채널에 연결할 수 있으며, 선택적으로 `default-output-channel` 속성도 지정할 수 있다. `ref` 속성으로는 커스텀 라우터 구현체의 빈 이름을 참조한다 (라우터 구현체는 반드시 `AbstractMessageRouter`를 상속하고 있어야 한다). 다음은 세 가지 범용 라우터 예시다:

```xml
<int:router ref="payloadTypeRouter" input-channel="input1"
            default-output-channel="defaultOutput1"/>

<int:router ref="recipientListRouter" input-channel="input2"
            default-output-channel="defaultOutput2"/>

<int:router ref="customRouter" input-channel="input3"
            default-output-channel="defaultOutput3"/>

<beans:bean id="customRouterBean" class="org.foo.MyCustomRouter"/>
```

아니면 `ref`로 내부에 `@Router` 어노테이션을 가지고 있는 POJO를 가리키는 방법도 있고 (뒤에서 보여준다), `ref`와 함께 명시적인 메소드 이름을 결합하기도 한다. 메소드를 지정하는 방법도 뒤에 나오는 `@Router` 어노테이션 섹션에 설명하는 방식과 동일하게 동작한다. 아래 예시에선 `ref` 속성으로 POJO를 가리키는 라우터를 정의하고 있다:

```xml
<int:router input-channel="input" ref="somePojo" method="someMethod"/>
```

특정 커스텀 라우터 구현체를 다른 `<router>` 정의에서도 참조할 수 있다면 보통 `ref` 속성을 사용하는 것이 좋다. 하지만 커스텀 라우터 구현체의 스코프를 하나의 `<router>` 정의 내로 한정하고 싶다면, 아래 예제와 같이 내부 빈 정의를 제공해도 된다:

```xml
<int:router method="someMethod" input-channel="input3"
            default-output-channel="defaultOutput3">
    <beans:bean class="org.foo.MyCustomRouter"/>
</int:router>
```

> 동일한 `<router>` 설정에서 `ref` 속성과 내부 핸들러 정의를 둘 다 사용하는 것은 허용하지 않는다. 둘 다 사용하면 조건이 모호해져 예외가 발생한다.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p><code class="highlighter-rouge">ref</code>
 속성으로 <code class="highlighter-rouge">AbstractMessageProducingHandler</code>를 상속한 빈을 참조하는 경우 (프레임워크에서 자체적으로 제공하는 라우터들처럼), 라우터를 직접 참조하도록 최적화된다. 이때는 각 <code class="highlighter-rouge">ref</code> 속성마다 별도 빈 인스턴스(또는 <code class="highlighter-rouge">prototype</code> 스코프 빈)를 참조하거나, 내부 <code class="highlighter-rouge">&lt;bean/&gt;</code> 설정을 이용해야 한다. 단, 여기서 말하는 최적화는 라우터 XML 정의에 특정 라우터 전용 속성을 제공하지 않았을 때에만 적용된다. 무심코 여러 빈에서 동일한 메시지 핸들러를 참조한다면 설정 예외를 만나게될 거다.</p>
</blockquote>

다음은 자바를 이용한 동일한 라우터 설정 예시다:

```java
@Bean
@Router(inputChannel = "routingChannel")
public AbstractMessageRouter myCustomRouter() {
    return new AbstractMessageRouter() {

        @Override
        protected Collection<MessageChannel> determineTargetChannels(Message<?> message) {
            return // determine channel(s) for message
        }

    };
}
```

다음은 Java DSL을 이용한 동일한 라우터 설정 예시다:

```java
@Bean
public IntegrationFlow routerFlow() {
    return IntegrationFlows.from("routingChannel")
            .route(myCustomRouter())
            .get();
}

public AbstractMessageRouter myCustomRouter() {
    return new AbstractMessageRouter() {

        @Override
        protected Collection<MessageChannel> determineTargetChannels(Message<?> message) {
            return // determine channel(s) for message
        }

    };
}
```

아니면 아래 예제처럼 메시지 페이로드에 있는 데이터를 통해 라우팅할 수도 있다:

```java
@Bean
public IntegrationFlow routerFlow() {
    return IntegrationFlows.from("routingChannel")
            .route(String.class, p -> p.contains("foo") ? "fooChannel" : "barChannel")
            .get();
}
```

### 8.1.5. Routers and the Spring Expression Language (SpEL)

간혹가다 보면 라우팅 로직이 매우 단순할 때도 있는데, 이럴땐 라우팅만을 위해 별도 클래스를 만들어 빈으로 설정하기까지 하는 건 조금 과할 수 있다. 이전에는 간단한 계산에도 커스텀 POJO 라우터를 만들어야 했지만, Spring Integration 2.0부터는 대신 SpEL을 이용할 수 있다.

> SpEL<sup>Spring Expression Language</sup>에 관한 자세한 내용은 [스프링 프레임워크 레퍼런스 가이드에서 관련 챕터](https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#expressions)를 확인해봐라.

일반적으로 SpEL 표현식은 다음과 같이 평가해서 그 결과를 채널에 매핑시킨다:

```xml
<int:router input-channel="inChannel" expression="payload.paymentType">
    <int:mapping value="CASH" channel="cashPaymentChannel"/>
    <int:mapping value="CREDIT" channel="authorizePaymentChannel"/>
    <int:mapping value="DEBIT" channel="authorizePaymentChannel"/>
</int:router>
```

다음은 자바를 이용한 동일한 라우터 설정 예시다:

```java
@Router(inputChannel = "routingChannel")
@Bean
public ExpressionEvaluatingRouter router() {
    ExpressionEvaluatingRouter router = new ExpressionEvaluatingRouter("payload.paymentType");
    router.setChannelMapping("CASH", "cashPaymentChannel");
    router.setChannelMapping("CREDIT", "authorizePaymentChannel");
    router.setChannelMapping("DEBIT", "authorizePaymentChannel");
    return router;
}
```

다음은 Java DSL을 이용한 동일한 라우터 설정 예시다:

```java
@Bean
public IntegrationFlow routerFlow() {
    return IntegrationFlows.from("routingChannel")
        .route("payload.paymentType", r -> r
            .channelMapping("CASH", "cashPaymentChannel")
            .channelMapping("CREDIT", "authorizePaymentChannel")
            .channelMapping("DEBIT", "authorizePaymentChannel"))
        .get();
}
```

SpEL 표현식 자체가 채널 이름으로 평가된다면 좀더 간결해진다:

```xml
<int:router input-channel="inChannel" expression="payload + 'Channel'"/>
```

위 설정을 보면, SpEL 표현식은 `payload` 값 뒤에 리터럴 `String` 'Channel'을 붙이고 있으며, 이를 계산한 결과를 채널로 사용하고 있다.

라우터를 설정할 때 SpEL을 사용하면 좋은 점이 또 있는데, 바로, 표현식은 `Collection`을 반환할 수 있고, 사실상 모든 `<router>`를 recipient list로 만들 수 있다는 점이다. 표현식에서 채널 값으로 여러 개의 값을 반환하기만 하면 해당 메시지는 각각의 채널로 전달된다. 다음은 값을 여러 개 반환하는 표현식 예시다:

```xml
<int:router input-channel="inChannel" expression="headers.channels"/>
```

위 설정에선, 메시지에 'channels'라는 헤더가 담겨있고 그 값이 채널 이름의 `List`라면, 해당 리스트에 들어있는 각각의 채널로 메시지를 전송한다. 여러 채널을 선택해야 하는 경우엔 collection projection과 collection selection 표현식이 적합할 수도 있다. 더 자세한 내용은 아래 링크를 참고해라:

- [Collection Projection](https://docs.spring.io/spring-framework/docs/current/spring-framework-reference/core.html#expressions-collection-projection)
- [Collection Selection](https://docs.spring.io/spring-framework/docs/current/spring-framework-reference/core.html#expressions-collection-selection)

#### Configuring a Router with Annotations

메소드 위에 `@Router`를 선언했다면 이 메소드에선 `MessageChannel`이나 `String` 타입을 반환할 수 있다. 후자의 경우  채널에서와 마찬가지로 채널명으로 바로 리졸브한다. 또한 이 메소드는 단일 값을 반환할 수도 있지만, 컬렉션을 반환할 수도 있다. 컬렉션을 반환하면 응답 메시지는 여러 채널로 전송된다. 정리하자면, 아래 있는 메소드 시그니처들을 모두 사용할 수 있다:

```java
@Router
public MessageChannel route(Message message) {...}

@Router
public List<MessageChannel> route(Message message) {...}

@Router
public String route(Foo payload) {...}

@Router
public List<String> route(Foo payload) {...}
```

꼭 페이로드를 기반으로 라우팅하지 않고, 메시지 헤더 안에 있는 프로퍼티나 attribute 등의 메타데이터를 기반으로도 라우팅할 수 있다. 헤더를 활용할 땐 `@Router`를 달아준 메소드에 `@Header`를 선언한 파라미터를 추가할 수 있다. 아래 예제에서 확인할 수 있듯이, 이 파라미터에는 헤더의 값이 매핑된다. 자세한 내용은 [어노테이션 지원](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/configuration.html#annotations)에서 설명하고 있다:

```java
@Router
public List<String> route(@Header("orderStatus") OrderStatus status)
```

> XPath 지원을 포함해서, XML 기반 메시지 라우팅에 대해 알아보려면 [XML 지원 - XML 페이로드 처리하기](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/xml.html#xml)를 참고해라.

라우터 설정을 좀더 자세히 알아보려면 Java DSL 챕터에 있는 [메시지 라우터](../java-dsl/#118-message-routers)를 함께 읽어봐라.

### 8.1.6. Dynamic Routers

Spring Integration은 POJO에 해당하는 커스텀 라우터를 구현하기 위한 옵션뿐 아니라, 흔히 쓰는 컨텐츠 기반 라우팅을 위한 설정들을 다양하게 제공하고 있다. 예를 들어 `PayloadTypeRouter`로는 전달받은 메시지의 페이로드 타입을 기반으로 채널을 계산하는 라우터를 간단하게 설정할 수 있으며, `HeaderValueRouter`는 메시지에 있는 특정 헤더 값을 평가해서 채널을 계산해준다. 표현식을 평가해서 채널을 결정하는 표현식 기반(SpEL) 라우터도 존재한다. 이런 라우터들은 모두 어느 정도 동적인 특성을 지니고 있다.

하지만 이 라우터들은 모두 정적인 설정을 필요로 한다. 표현식 기반 라우터라고 하더라도, 표현식 자체를 라우터 설정에 정의한다. 다시 말해, 같은 표현식을 같은 값으로 실행하면 언제나 같은 채널을 계산해낸다. 이런 식의 라우팅 규칙은 명확해서 예측하기도 쉽기 때문에 대부분의 케이스에 잘 활용할 수 있다. 하지만 간혹 라우터 설정을 동적으로 변경해서 메시지 플로우를 또다른 채널로 라우팅해야 하는 경우가 있다.

예를 들어 유지 보수를 위해 잠시 일부 시스템을 중단하고 일시적으로 메시지들을 다른 메시지 플로우로 재라우팅할 수 있다. 또 다른 예시로는, (`PayloadTypeRouter`의 경우) 라우팅 로직을 하나 더 추가해서 메시지 플로우를 좀더 세분화해 `java.lang.Number`에서 좀더 구체적인 타입을 처리하고 싶을 수도 있다.

하지만 안타깝게도 정적인 라우터 설정을 사용하고 있었다면 이런 목표들을 달성할 땐, 전체 애플리케이션을 중단하고 라우터 설정을 변경한 뒤 (routes 수정) 애플리케이션을 다시 기동해야 한다. 단언컨데 이런 솔루션을 원하는 사람은 없을 거다.

[다이나믹 라우터](https://www.enterpriseintegrationpatterns.com/DynamicRouter.html) 패턴에선 시스템이나 개별 라우터 중단 없이 라우터를 동적으로 변경하거나 설정할 수 있는 메커니즘을 다루고 있다.

Spring Integration이 동적인 라우팅을 어떻게 지원하는지에 대해 자세히 알아보기 전에 먼저, 라우터의 일반적인 흐름을 생각해볼 필요가 있다:

1. 채널 식별자를 계산한다. 채널 식별자란 라우터가 메시지를 받아 계산하는 값을 말한다. 보통은 문자열이거나, 실제 `MessageChannel`의 인스턴스다.
2. 채널 식별자를 채널 이름으로 리졸브한다. 이 프로세스에 관해서는 뒤에서 자세히 논한다.
3. 이 채널명을 실제 `MessageChannel`로 리졸브한다.

Step 1에서 실제 `MessageChannel`의 인스턴스를 가져오게 되면 동적인 라우팅에 관해서는 할 수 있는 일이 많지 않다. 어떤 라우터라도 `MessageChannel`이 최종 결과물이기 때문이다. 하지만 첫 번째 스텝에서 계산한 채널 식별자가 `MessageChannel` 인스턴스가 아니라면 다양한 방법으로 `MessageChannel`을 얻어오는 프로세스에 변화를 줄 수 있다. 아래 있는 페이로드 타입 라우터를 예시로 살펴보자:

```xml
<int:payload-type-router input-channel="routingChannel">
    <int:mapping type="java.lang.String"  channel="channel1" />
    <int:mapping type="java.lang.Integer" channel="channel2" />
</int:payload-type-router>
```

페이로드 타입 라우터의 컨텍스트 내에서 살펴보면, 앞서 언급한 세 단계의 스텝은 다음과 같이 진행될 거다:

1. 페이로드 타입의 풀네임<sup>fully qualified name</sup>에 해당하는 채널 식별자를 계산한다 (ex. `java.lang.String`).
2. 이 채널 식별자를 채널 이름으로 리졸브한다. 이때는 이전 스텝에서 얻은 값을 이용해 페이로드 타입 매핑 정보에서 적절한 값을 선택한다. 매핑 정보는 `mapping` 요소에 정의돼있다.
3. 이 채널명을 실제 `MessageChannel` 인스턴스로 리졸브한다. 이때는 앞 스텝에서 계산한 이름으로 식별된 애플리케이션 컨텍스트 내 빈(`MessageChannel`)을 참조한다.

즉, 각 스텝이 진행되는 동안에는 다음 스텝을 위한 값을 계산한다.

이번에는 header value 라우터를 예로 들어보겠다:

```xml
<int:header-value-router input-channel="inputChannel" header-name="testHeader">
    <int:mapping value="foo" channel="fooChannel" />
    <int:mapping value="bar" channel="barChannel" />
</int:header-value-router>
```

이제 header value 라우터에서는 이 세 단계의 스텝이 어떻게 동작할지 생각해보자:

1. 채널 식별자를 계산한다. 여기서 채널 식별자는 헤더의 값을 뜻하며, `header-name` 속성으로 식별한다.
2. 이 채널 식별자를 채널 이름으로 리졸브한다. 이때는 이전 스텝에서 얻은 값을 이용해 일반적인 매핑 정보에서 적절한 값을 선택한다. 매핑 정보는 `mapping` 요소에 정의돼있다.
3. 이 채널명을 실제 `MessageChannel` 인스턴스로 리졸브한다. 이때는 앞 스텝에서 계산한 이름으로 식별된 애플리케이션 컨텍스트 내 빈(`MessageChannel`)을 참조한다.

앞에서 살펴본 두 가지 유형의 라우터 설정은 거의 동일해 보인다. 하지만 `HeaderValueRouter`의 또 다른 설정을 살펴보면, 이번에는 분명히 하위 요소 `mapping`이 없다는 게 보일 거다:

```xml
<int:header-value-router input-channel="inputChannel" header-name="testHeader">
```

하지만 이 설정 역시 아무런 문제 없는 설정이다. 자연스럽게 이어지는 질문으로 넘어가보면, 두 번째 스텝에서의 매핑은 어떻게 되는 걸까?

이제 두 번째 스텝은 옵션이다. `mapping`이 정의돼있지 않은 경우, 첫 번째 스텝에서 계산한 채널 식별자 값을 자동으로 **채널 이름**으로 처리하며, 세 번째 스텝에선 이 값을 실제 `MessageChannel`로 리졸브한다. 즉, 두 번째 스텝이 라우터에 동적인 특성을 더해주는 핵심 단계라는 것을 의미한다. 두 번째 스텝을 통해 채널 식별자를 채널명으로 식별하는 방식에 변화를 줄 수 있으며, 궁극적으로 초기 채널 식별자로부터 최종 `MessageChannel` 인스턴스를 결정하는 프로세스를 수정할 수 있다.

예를 들어서 위 설정에서 채널 식별자로 활용하는 (첫 번째 스텝) `testHeader` 값이 'kermit'이라고 가정해보자. 이 라우터에는 매핑 정보가 없기 때문에 이 채널 식별자를 채널 이름으로 리졸브하는 것은 불가능하며 (두 번째 스텝), 이제 이 채널 식별자를 채널명으로 취급한다. 반대로 매핑 정보는 있는데 다른 값이 들어있다면 어떻게 될까? 최종 결과는 동일한데, 그 이유는 채널 식별자를 채널명으로 리졸브하는 과정에서  값을 결정할 수 없으면 채널 식별자가 채널 이름이 되기 때문이다.

이제 세 번째 스텝을 통해 채널 이름('kermit')을, 이 이름으로 식별하는 실제 `MessageChannel` 인스턴스로 리졸브하는 일이 남아있다. 이때는 기본적으로 주어진 이름에 해당하는 빈을 조회해본다. 이제 헤더-값 쌍으로 `testHeader=kermit`을 가지고 있는 모든 메시지는 빈 이름(`id`)이 'kermit'인 `MessageChannel`로 라우팅된다.

이번엔 이 메시지들을 'simpson' 채널로 라우팅하려면 어떻게 해야 할까? 정적인 설정을 수정하는 방법도 있지만, 이렇게 되면 시스템을 중단시켜야 한다. 반면 채널 식별자 맵에 액세스할 수 있다면, 헤더-값 `kermit=simpson`을 새로 매핑할 수 있다. 이렇게 하면 두 번째 스텝에서 'kermit'을 'simpson'이란 채널로 리졸브되는 채널 식별자로 취급한다.

`PayloadTypeRouter`에서도 동일하다. 특정 페이로드 타입을 다시 매핑하거나 기존 매핑을 제거하면 된다. 사실, 표현식 기반 라우터는 물론, 다른 라우터들도 전부 동일하다. 매핑을 추가해주면 이제 라우터에서 계산하는 값들은 실제 **채널 이름**을 리졸브하기 위한 두 번째 스텝을 거칠 수 있기 때문이다.

`channelMapping`은 `AbstractMappingMessageRouter` 단에서 정의되기 때문에 , `AbstractMappingMessageRouter`를 상속한 라우터는 전부 다이나믹 라우터다 (프레임워크에서 정의하는 대부분의 라우터도 포함해서). 이 맵의 setter 메소드는 public으로 노출돼있으며, 'setChannelMapping', 'removeChannelMapping' 메소드도 함께 제공한다. 따라서 라우터 자체에 대한 참조만 가지고 있다면 이 메소드들을 이용해 런타임에 라우터 매핑을 변경, 추가, 제거할 수 있다. JMX([JMX 지원](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/jmx.html#jmx) 참고)나 Spring Integration 컨트롤 버스([컨트롤 버스](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/control-bus.html#control-bus) 참고) 기능을 통해서도 같은 설정 옵션을 제공할 수 있다는 뜻이기도 하다.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>채널 이름의 폴백으로 채널 키를 활용하면 간편하면서도 유연하게 대응할 수 있다. 그러나 메시지 생성자를 신뢰할 수 없는 상황이라면, 시스템을 잘 아는 누군가가 악의적으로 메시지를 생성해 예상치 못한 채널로 라우팅시킬 수도 있다. 예를 들어 키가 라우터의 입력 채널 이름으로 설정돼 있다면, 이런 메시지는 해당 라우터로 다시 라우팅되며, 종국엔 스택 오버플로 에러를 일으킨다. 따라서 이 기능은 비활성화하고 (<code class="highlighter-rouge">channelKeyFallback</code> 속성을 <code class="highlighter-rouge">false</code>로 설정) 필요한 경우 매핑 정보를 변경해야 할 수도 있다.</p>
</blockquote>

#### Manage Router Mappings using the Control Bus

라우터 매핑을 관리하는 방법 중에는 [컨트롤 버스](https://www.enterpriseintegrationpatterns.com/ControlBus.html) 패턴을 이용하는 방법이 있다. 이 패턴은 컨트롤 채널이라는 별도 채널로 메시지를 전송해 라우터를 포함한 Spring Integration 구성 요소들을 관리하고 모니터링한다.

> 컨트롤 버스에 관한 자세한 내용은 [컨트롤 버스](../system-management/#135-control-bus)를 읽어봐라.

일반적으로 컨트롤 메시지를 전송할 땐, 메세지를 통해 관리 중인 특정 컴포넌트(라우터 등)에서 특정한 작업을 실행하도록 요청한다. 아래 있는 관리성 연산(메소드)들은 라우터의 리졸브 프로세스를 변경한다:

- `public void setChannelMapping(String key, String channelName)`: **채널 식별자**와 **채널 이름**을 새로 매핑하거나 기존 매핑 정보를 수정할 수 있다
- `public void removeChannelMapping(String key)`: 특정 채널에 매핑된 정보를 제거해서 **채널 식별자**와 **채널 이름**의 연결 관계를 끊을 수 있다

이 메소드들은 단순한 변경 작업에 활용할 수 있다 (라우팅 정보 하나를 업데이트하거나 삭제하는 등). 하지만 라우팅 정보 하나를 지우고서 다른 라우팅 정보를 추가하려는 경우, 이 두 번의 업데이트는 원자적<sup>atomic</sup>이지 않다는 점에 주의하자. 즉, 두 번의 업데이트를 진행하는 찰나에는 라우팅 테이블이 이도저도 아닌 애매한 상태에 놓일 수 있다는 걸 의미한다. 4.0 버전부터는 컨트롤 버스를 이용해 전체 라우팅 테이블을 원자적으로 업데이트할 수 있다. 아래 메소드들을 이용하면 된다:

- `public Map<String, String> getChannelMappings()`: 현재 가지고 있는 채널 매핑 정보를 반환한다.
- `public void replaceChannelMappings(Properties channelMappings)`: 매핑 정보를 업데이트한다. `channelMappings` 파라미터는 `Properties` 객체라는 점에 주목해라. 덕분에 아래 예시처럼 컨트롤 버스 명령어에서 내장 `StringToPropertiesConverter`를 사용할 수 있다:

```java
"@'router.handler'.replaceChannelMappings('foo=qux \n baz=bar')"
```

각각의 매핑 정보는 개행 문자(`\n`)로 구분한다. 매핑 정보를 코드를 통해 수정해야 한다면 type-safety 문제도 있기 때문에 `setChannelMappings` 메소드를 사용하는 것을 권장한다. `replaceChannelMappings`에선 키나 값이 `String` 객체가 아닌 정보는 무시한다.

#### Manage Router Mappings by Using JMX

스프링의 JMX 지원을 이용해 라우터 인스턴스를 하나 노출한 다음 자주 사용하는 JMX 클라이언트(ex. JConsole)를 사용해도 라우터 설정을 변경하는 연산(메소드)들을 관리할 수 있다.

> 스프링이 제공하는 JMX 관련 기능은 [JMX 지원](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/jmx.html#jmx)을 읽어봐라.

#### Routing Slip

4.1 버전부터 Spring Integration은 엔터프라이즈 통합 패턴 [라우팅 슬립](https://www.enterpriseintegrationpatterns.com/RoutingTable.html)의 구현체를 제공한다. 이 구현체에선 `routingSlip`이라는 헤더를 활용한다. 엔드포인트에 `outputChannel`이 지정돼있지 않은 경우, `AbstractMessageProducingHandler` 인스턴스에서 이 `routingSlip` 헤더를 이용해 다음 채널을 결정한다. 이 패턴은 메시지 플로우를 결정하려면 라우터를 여러 가지 설정해야 하는, 복잡하고 동적인 환경에서 활용하기 좋다. 메시지가 `output-channel`을 가지고 있지 않은 엔드포인트에 도착하면 `routingSlip`을 참조해 메시지를 전송할 채널을 결정한다. 라우팅 슬립에서도 다음 채널을 찾지 못하면 일반적인 `replyChannel` 처리를 재개한다.

라우팅 슬립과 관련한 설정은 아래 보이는 `HeaderEnricher` 옵션으로 표현한다. 각 라우팅 슬립 `path`는 세미콜론으로 구분하고 있다:

```xml
<util:properties id="properties">
    <beans:prop key="myRoutePath1">channel1</beans:prop>
    <beans:prop key="myRoutePath2">request.headers[myRoutingSlipChannel]</beans:prop>
</util:properties>

<context:property-placeholder properties-ref="properties"/>

<header-enricher input-channel="input" output-channel="process">
    <routing-slip
        value="${myRoutePath1}; @routingSlipRoutingPojo.get(request, reply);
               routingSlipRoutingStrategy; ${myRoutePath2}; finishChannel"/>
</header-enricher>
```

위 예시에는 다음과 같은 설정이 있다:

- `<context:property-placeholder>` 설정. 라우팅 슬립 `path` 항목에 프로퍼티 키를 지정할 수 있음을 알 수 있다. 
- `<header-enricher>`의 하위 요소 `<routing-slip>`을 이용해 `HeaderEnricher` 핸들러에 `RoutingSlipHeaderValueMessageProcessor` 정보를 채운다.
- `RoutingSlipHeaderValueMessageProcessor`는 라우팅 슬립 `path` 항목을 담고 있는 `String` 배열을 받는다. 이 문자열은 프로퍼티 리졸브를 마친 상태다. `processMessage()` 메소드에선 `singletonMap`을 반환하며, 이 맵은 `path`를 `key`로 가지고 있고, 초기 `routingSlipIndex`는 `0`으로 세팅돼있다.

라우팅 슬립 `path` 항목에는 `MessageChannel` 빈의 이름이나 `RoutingSlipRouteStrategy` 빈의 이름, 스프링 표현식(SpEL)을 담을 수 있다. `RoutingSlipHeaderValueMessageProcessor`는 `processMessage` 메소드가 최초로 실행됐을 때 각 라우팅 슬립 `path` 항목을 `BeanFactory`에서 조회해본다. 애플리케이션 컨텍스트 내에 있는 빈의 이름이 아닌 항목들은 `ExpressionEvaluatingRoutingSlipRouteStrategy` 인스턴스로 변환한다. `RoutingSlipRouteStrategy` 항목들은 null이나 비어있는 `String`을 반환하는 동안에는 반복해서 호출한다.

라우팅 슬립은 `getOutputChannel` 프로세스 중에 사용하는 패턴이기 때문에, request-reply 조합마다 컨텍스트를 가진다. `RoutingSlipRouteStrategy`는 현재 `requestMessage`와 `reply` 객체로 다음 `outputChannel`을 결정하는 용도로 도입했다. 이 strategy 구현체는 애플리케이션 컨텍스트에 빈으로 등록되어야 하며, 이 빈 이름은 라우팅 슬립 `path`에서 사용할 수 있다. 현재는 `ExpressionEvaluatingRoutingSlipRouteStrategy`라는 구현체를 제공하고 있다. 이 구현체는 SpEL 표현식을 받으며 내부 `ExpressionEvaluatingRoutingSlipRouteStrategy.RequestAndReply` 객체를 평가 컨텍스트의 루트 객체로 사용한다. 덕분에 `ExpressionEvaluatingRoutingSlipRouteStrategy.getNextPath()`를 호출할 때마다 `EvaluationContext`를 생성하는 오버헤드를 피할 수 있다. `ExpressionEvaluatingRoutingSlipRouteStrategy.RequestAndReply`는 `Message<?> request`와 `Object reply`라는 두 가지 속성을 가지고 있는 간단한 자바 빈이다. 이 구현체를 사용하면 SpEL을 통해 라우팅 슬립 `path` 항목을 지정할 수 있으며 (ex. `@routingSlipRoutingPojo.get(request, reply)`, `request.headers[myRoutingSlipChannel]`), `RoutingSlipRouteStrategy` 빈을 따로 정의하지 않아도 된다.

> `requestMessage` 인자는 언제나 `Message<?>`다. 반면 reply 객체는 컨텍스트에 따라 `Message<?>`일 수도, `AbstractIntegrationMessageBuilder`일 수도 있으며, 임의의 애플리케이션 도메인 객체일 수도 있다 (ex. 서비스 액티베이터로 실행한 POJO 메소드가 반환한 객체). 앞의 두 케이스라면, SpEL(또는 자바 구현체)에서 평소대로 `Message` 프로퍼티(`payload`와 `headers`)를 사용할 수 있다. 하지만 임의의 도메인 객체라면 이 프로퍼티를 사용할 수 없다. 따라서 POJO 메소드의 실행 결과로 다음 path를 결정하는 경우 라우팅 슬립을 주의해서 사용해야 한다.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>라우팅 슬립이 분산 환경과 연계된다면 라우팅 슬립 <code class="highlighter-rouge">path</code>에 인라인 표현식은 사용하지 않는 게 좋다. 이는 메시지 브로커(<a href="https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/amqp.html#amqp">AMQP 지원</a> 또는 <a href="https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/jms.html#jms">JMS 지원</a>)를 통해 <code class="highlighter-rouge">request-reply</code>를 주고받거나, 인티그레이션 플로우에서 영구<sup>persistent</sup> <code class="highlighter-rouge">MessageStore</code>(<a href="../system-management/#133-message-store">메시지 스토어</a>)를 사용하는 교차 JVM 애플리케이션과 같은 분산 환경에서도 마찬가지다. 프레임워크는 <code class="highlighter-rouge">RoutingSlipHeaderValueMessageProcessor</code>를 사용해 <code class="highlighter-rouge">path</code> 값을 <code class="highlighter-rouge">ExpressionEvaluatingRoutingSlipRouteStrategy</code> 객체로 변환하며, 이 객체는 메시지 헤더 <code class="highlighter-rouge">routingSlip</code>에 채워진다. 이 클래스는 <code class="highlighter-rouge">Serializable</code>이 아니기 때문에 (<code class="highlighter-rouge">BeanFactory</code>에 의존하기 때문에 불가능하다), 전체 <code class="highlighter-rouge">Message</code> 역시 직렬화가 불가능하며, 모든 분산 작업에서 <code class="highlighter-rouge">NotSerializableException</code>을 만나게 된다. 따라서, 적합한 SpEL을 이용해 <code class="highlighter-rouge">ExpressionEvaluatingRoutingSlipRouteStrategy</code> 빈을 등록하고, 라우팅 슬립 <code class="highlighter-rouge">path</code> 설정에선 이 빈 이름을 사용해라.</p>
</blockquote>

자바 설정에선 다음과 같이 `HeaderEnricher` 빈 정의에 `RoutingSlipHeaderValueMessageProcessor` 인스턴스를 추가해주면 된다:

```java
@Bean
@Transformer(inputChannel = "routingSlipHeaderChannel")
public HeaderEnricher headerEnricher() {
    return new HeaderEnricher(Collections.singletonMap(IntegrationMessageHeaderAccessor.ROUTING_SLIP,
            new RoutingSlipHeaderValueMessageProcessor("myRoutePath1",
                                                       "@routingSlipRoutingPojo.get(request, reply)",
                                                       "routingSlipRoutingStrategy",
                                                       "request.headers[myRoutingSlipChannel]",
                                                       "finishChannel")));
}
```

엔드포인트가 응답을 생성했을 때 `outputChannel`이 정의돼있지 않은 경우, 라우팅 슬립 알고리즘은 다음과 같이 동작한다:

- `routingSlipIndex`를 사용해 라우팅 슬립 `path` 목록에서 값을 하나 가져온다.
- `routingSlipIndex`로 가져온 값이 `String`인 경우, 이 문자열을 사용해 `BeanFactory`에서 빈을 가져온다.
- 반환된 빈이 `MessageChannel` 인스턴스인 경우, 이 채널을 다음 `outputChannel`로 사용하며, 응답 메시지 헤더의 `routingSlipIndex`는 1만큼 증가시킨다 (라우팅 슬립 `path` 항목들은 변경하지 않고 유지한다).
- 반환된 빈이 `RoutingSlipRouteStrategy` 인스턴스면서 `getNextPath` 메소드가 비어 있지 않은 `String`을 반환한 경우, 이 반환 값을 다음 `outputChannel`의 빈 이름으로 사용한다. `routingSlipIndex`는 변경하지 않고 유지한다.
- `RoutingSlipRouteStrategy.getNextPath`가 빈 `String`이나 `null`을 반환하면, `routingSlipIndex`를 증가시키고 `getOutputChannelFromRoutingSlip`을 재귀적으로 실행해 다음 라우팅 슬립 `path` 항목을 조회한다.
- 목록에서 가져온 라우팅 슬립 `path` 항목이 `String`이 아니라면 반드시 `RoutingSlipRouteStrategy` 인스턴스여야 한다.
- `routingSlipIndex`가 라우팅 슬립 `path` 목록의 사이즈를 넘어서면, 이 알고리즘은 표준 `replyChannel` 헤더를 이용하는 디폴트 동작으로 넘어간다.

### 8.1.7. Process Manager Enterprise Integration Pattern

엔터프라이즈 통합 패턴 중에는 [프로세스 매니저](https://www.enterpriseintegrationpatterns.com/ProcessManager.html)라는 패턴이 있다. 이제 커스텀 프로세스 매니저 로직을 작성하고 라우팅 슬립 안에서 `RoutingSlipRouteStrategy`로 캡슐화만 해주면 쉽게 이 패턴을 쉽게 구현할 수 있다. `RoutingSlipRouteStrategy`는 빈 이름 외에도 `MessageChannel` 객체라면 전부 반환할 수 있으며, 이 `MessageChannel` 인스턴스가 꼭 애플리케이션 컨텍스트 내 빈이어야 한다는 법은 없다. 어떤 채널을 사용해야 하는지를 미리 예측하기가 어려울 땐 이 패턴을 활용해 동적으로 메시지를 라우팅할 수 있다. `MessageChannel`은 `RoutingSlipRouteStrategy` 내에서 생성하고 반환해도 된다. 이런 케이스엔 `MessageHandler` 구현체가 고정으로 연결돼있는 `FixedSubscriberChannel`을 사용하는 것도 괜찮다. 예를 들어 다음 예제와 같이 [리액티브 스트림즈](../../Reactor%20Core/gettingstarted)로 라우팅할 수 있다:

```java
@Bean
public PollableChannel resultsChannel() {
    return new QueueChannel();
}

@Bean
public RoutingSlipRouteStrategy routeStrategy() {
    return (requestMessage, reply) -> requestMessage.getPayload() instanceof String
            ? new FixedSubscriberChannel(m ->
            Mono.just((String) m.getPayload())
                    .map(String::toUpperCase)
                    .subscribe(v -> messagingTemplate().convertAndSend(resultsChannel(), v)))
            : new FixedSubscriberChannel(m ->
            Mono.just((Integer) m.getPayload())
                    .map(v -> v * 2)
                    .subscribe(v -> messagingTemplate().convertAndSend(resultsChannel(), v)));
}
```

---

## 8.2. Filter

메시지 필터는 메시지 헤더나 컨텐츠 자체같은 어떤 기준에 따라 `Message`를 다음으로 전달할지, 아니면 버려야 할지를 결정한다. 즉, 메시지 필터는 라우터와 매우 유사하며, 필터의 입력 채널로 받은 메시지는 필터의 출력 채널로 전송할 수도, 전송하지 않을 수도 있다는 점만 다르다. 라우터와는 달리 메시지를 전송할 채널은 결정하지 않으며, 메시지를 전달할지 여부를 결정하는 게 전부다.

> 뒤에서도 설명하지만, 필터는 discard 채널도 지원한다. 사용하는 방법에 따라 boolean 조건을 기반으로 매우 간단한 라우터(또는 "스위치")로 동작시킬 수 있다.

Spring Integration에서 메세지 필터를 설정할 땐 `MessageSelector` 인터페이스 구현체에 위임하는 메시지 엔드포인트를 만들면 된다. 이 인터페이스 자체는 아래에 보이는 것처럼 매우 단순하다:

```java
public interface MessageSelector {

    boolean accept(Message<?> message);

}
```

`MessageFilter` 생성자는 아래 보이는 것처럼 selector 인스턴스를 하나 받는다:

```java
MessageFilter filter = new MessageFilter(someSelector);
```

네임스페이스와 SpEL을 조합하면 자바 코드는 거의 없이도 쓸만한 필터들을 구성할 수 있다.

### 8.2.1. Configuring a Filter with XML

메시지를 선별해주는 엔드포인트를 만들려면 `<filter>` 요소를 사용하면 된다. `input-channel`과 `output-channel` 속성 외에도, `ref`라는 속성이 필요하다. `ref`에선 아래 예제와 같이 `MessageSelector` 구현체를 가리켜주면 된다:

```xml
<int:filter input-channel="input" ref="selector" output-channel="output"/>

<bean id="selector" class="example.MessageSelectorImpl"/>
```

아니면 `method` 속성을 추가하는 방법도 있다. 이때는 `ref` 속성에서 모든 객체를 참조할 수 있다. 참조하는 메소드에선 `Message` 타입이나 인바운드 메시지의 페이로드 타입을 받아 처리하면 되며, 반환 타입은 boolean이어야 한다. 'true'를 반환하면 메시지를 출력 채널로 전송한다. 다음은 `method` 속성을 사용해 필터를 설정하는 예시다:

```xml
<int:filter input-channel="input" output-channel="output"
    ref="exampleObject" method="someBooleanReturningMethod"/>

<bean id="exampleObject" class="example.SomeObject"/>
```

selector 혹은 적당한 POJO 메소드에서 `false`를 반환해 거절한 메시지는 몇 가지 설정을 통해 제어한다. 기본적으로는 (앞의 예시처럼 설정한 경우) 거부된 메시지는 별다른 오류 없이 버려진다. 메시지를 거절할 때 에러를 발생시켜야 한다면 아래 예제처럼 `throw-exception-on-rejection` 속성을 `true`로 설정해라:

```xml
<int:filter input-channel="input" ref="selector"
    output-channel="output" throw-exception-on-rejection="true"/>
```

거절한 메시지를 특정 채널로 라우팅하고 싶다면, 다음 예제와 같이 `discard-channel`로 전송할 채널을 지정해라:

```xml
<int:filter input-channel="input" ref="selector"
    output-channel="output" discard-channel="rejectedMessages"/>
```

[필터에 어드바이스 체인 적용하기](../messaging-endpoints/#1097-advising-filters)도 함께 참고해라.

> 일반적으로 메시지 필터는 publish-subscribe 채널과 함께 사용한다. 같은 채널을 다양한 필터 엔드포인트가 구독할 수 있으며, 필터를 통해 다음 엔드포인트로 메시지를 전달할지를 결정하게 된다. 다음 엔드포인트는 지원하는 타입이라면 무엇이든 될 수 있다 (ex. 서비스 activator). point-to-point 입력 채널 하나와 여러 가지 출력 채널을 사용하는 메시지 라우터에선 메시지를 전송할 채널을 사전에 세팅해 놓는다면, 메시지 필터는 그대신 다양한 구독자별로 대응을 추가해나가는 방안이다.

커스텀 필터 구현체를 다른 `<filter>` 정의에서도 참조할 수 있다면 `ref` 속성을 사용하길 권장한다. 반대로 커스텀 필터 구현체의 스코프가 단일 `<filter>` 요소로 한정된다면, 다음 예제와 같이 내부 빈 정의를 이용하는 게 좋다:

```xml
<int:filter method="someMethod" input-channel="inChannel" output-channel="outChannel">
  <beans:bean class="org.foo.MyCustomFilter"/>
</filter>
```

> 동일한 `<filter>` 설정에서 `ref` 속성과 내부 핸들러 정의를 둘 다 사용하는 것은 허용하지 않는다. 둘 다 사용하면 조건이 모호해져 예외가 발생한다.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p><code class="highlighter-rouge">ref</code> 속성으로 <code class="highlighter-rouge">MessageFilter</code>를 상속한 빈을 참조하는 경우 (프레임워크에서 자체적으로 제공하는 필터들처럼), 출력 채널을 필터 빈에 직접 주입하는 식으로 최적화된다. 이때는 각 <code class="highlighter-rouge">ref</code> 속성마다 별도 빈 인스턴스(또는 <code class="highlighter-rouge">prototype</code> 스코프 빈)를 참조하거나, 내부 <code class="highlighter-rouge">&lt;bean/&gt;</code> 설정을 이용해야 한다. 단, 여기서 말하는 최적화는 필터 XML 정의에 특정 필터 전용 속성을 제공하지 않았을 때에만 적용된다. 무심코 여러 빈에서 동일한 메시지 핸들러를 참조하면 설정 예외를 만나게될 거다.</p>
</blockquote>
SpEL 지원이 도입돼면서 Spring Integration은 필터 요소에 `expression` 속성을 추가했다. 이제 다음 예제와 같이 간단한 필터라면 자바 코드는 전혀 없어도 된다:

```xml
<int:filter input-channel="input" expression="payload.equals('nonsense')"/>
```

expression 속성 값으로 전달한 문자열은 평가 컨텍스트 내 메시지와 함께 SpEL 표현식으로 평가된다. 애플리케이션 컨텍스트 스코프 내 표현식 결과를 재사용해야 하는 경우, [SpEL 레퍼런스 문서](https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#expressions-beandef)에서 정의하는 대로 `#{}` 표기법을 사용하면 된다:

```xml
<int:filter input-channel="input"
            expression="payload.matches(#{filterPatterns.nonsensePattern})"/>
```

표현식 자체를 동적으로 구성하고 싶다면 'expression'을 하위 요소로 추가하면 된다. 이렇게 하면 `ExpressionSource`에 있는 키를 통해 간접적으로 표현식을 리졸브한다. `ExpressionSource`는 전략 인터페이스로, 직접 구현해도 좋고, Spring Integration이 제공하는 구현체를 사용해도 된다. Spring Integration이 제공하는 구현체는 "리소스 번들"에서 표현식을 로드하고 지정 시간이 지나면 (초 단위) 변경 사항을 확인할 수 있다. 아래와 같이 설정해주면 내부 파일이 수정되는 경우 1분 이내로 표현식을 다시 로드할 수 있다:

```xml
<int:filter input-channel="input" output-channel="output">
    <int:expression key="filterPatterns.example" source="myExpressions"/>
</int:filter>

<beans:bean id="myExpressions"
    class="o.s.i.expression.ReloadableResourceBundleExpressionSource">
    <beans:property name="basename" value="config/integration/expressions"/>
    <beans:property name="cacheSeconds" value="60"/>
</beans:bean>
```

`ExpressionSource` 빈의 이름이 `expressionSource`라면 `<expression>` 요소에 `source` 속성을 지정하지 않아도 된다. 위 예제에선 참고할 수 있도록 표기해놓았다.

'config/integration/expressions.properties' 파일은 (리소스 번들을 로드하는 일반적인 방식으로 리졸브하는, locale 별 전용 확장파일도 가능) 다음과 같은 키/값 쌍을 가지고 있을 수 있다:

```none
filterPatterns.example=payload > 100
```

> 속성이나 하위 요소로 `expression`을 사용하는 이 예제들은 모두 트랜스포머, 라우터, splitter, service-activator, header-enricher 요소에도 적용할 수 있다. 컴포넌트 유형마다 가지고 있는 시맨틱스와 역할에 따라, 메소드의 반환 값을 다르게 해석하고 그에 따라 평가 결과도 달라진다. 예를 들어, 라우터 컴포넌트라면 표현식에서 메시지 채널 이름으로 취급할 문자열을 반환할 수 있다. 하지만 메시지를 루트 객체로 두고 표현식을 평가한다는 점과, 앞에 '@'가 있으면 빈 이름을 리졸브하는 기본적인 기능은 Spring Integration 안에 있는 모든 핵심 EIP 컴포넌트에서 동일하다.

### 8.2.2. Configuring a Filter with Annotations

다음은 어노테이션을 이용해 필터를 설정하는 예시다:

```java
public class PetFilter {
    ...
    @Filter  // (1)
    public boolean dogsOnly(String input) {
        ...
    }
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span>이 메소드를 필터로 사용한다는 것을 나타내는 어노테이션. 이 클래스를 필터로 사용하려면 반드시 지정해야 한다.</small>

XML 요소에서 제공하는 설정 옵션은 전부 `@Filter` 어노테이션에서도 사용할 수 있다.

이 필터는 XML 안에서 직접 참조해도 되고, 클래스 위에 `@MessageEndpoint` 어노테이션을 선언했다면 클래스패스 스캔을 통해 자동으로 감지할 수도 있다.

[어노테이션을 이용해 엔드포인트에 어드바이스 체인 적용하기](../messaging-endpoints/#1098-advising-endpoints-using-annotations)도 함께 참고해라.

---

## 8.3. Splitter

splitter는 하나의 메시지를 여러 메시지로 분할해 독립적으로 처리할 수 있도록 전송해주는 일을 담당한다. 보통은 파이프라인 뒷쪽에 aggregator를 가지고 있는 업스트림 프로듀서일 때가 많다.

### 8.3.1. Programming Model

분할 동작을 위한 API는 `AbstractMessageSplitter`라는 클래스에서 시작한다. 이 클래스는 새로 만드는 메시지에 적당한 메시지 헤더를 채우는 등 (`CORRELATION_ID`, `SEQUENCE_SIZE`, `SEQUENCE_NUMBER`), splitter에서 공통적으로 필요한 기능들을 캡슐화해놓은 `MessageHandler` 구현체다. 이런 헤더를 채움으로써 메시지와 그 처리 결과를 추적할 수 있게된다 (일반적인 상황에선 이런 헤더들은 다양한 엔드포인트에서 변환되어 만들어지는 메시지에 그대로 복사된다). 이런 값들은 [복합메시지 프로세서](https://www.enterpriseintegrationpatterns.com/DistributionAggregate.html) 등에서 활용할 수 있다.

다음은 `AbstractMessageSplitter`에서 가져온 코드다:

```java
public abstract class AbstractMessageSplitter
    extends AbstractReplyProducingMessageConsumer {
    ...
    protected abstract Object splitMessage(Message<?> message);

}
```

애플리케이션에 맞는 splitter를 구현하려면 `AbstractMessageSplitter`를 상속하고, `splitMessage` 메소드를 구현해 메시지 분할 로직을 넣어주면 된다. 메소드에선 다음 중 하나를 반환하면 된다:

- 메시지의 `Collection`이나 배열, 또는 메시지를 순회하는 `Iterable` (혹은 `Iterator`). 이때는 컬렉션에 있는 메시지를 그대로 전달한다 (`CORRELATION_ID`, `SEQUENCE_SIZE`, `SEQUENCE_NUMBER`를 채운 후에). 이렇게 하면 분할 과정에서 커스텀 메시지 헤더를 채우는 등 더 많은 것들을 직접 제어할 수있다.
- 메시지가 아닌 다른 객체의 `Collection`이나 배열, 또는 메시지가 아닌 객체를 순회하는 `Iterable` (혹은 `Iterator`). 이때는 컬렉션에 있는 각 요소를 메시지 페이로드로 사용한다는 점만 빼면 위 케이스와 동일하게 동작한다. 이렇게  하면 메시징 시스템을 고려할 필요 없이 도메인 객체에 집중할 수 있으며, 작성한 코드를 테스트하기도 쉽다.
- `Message`나 다른 객체 (컬렉션이나 배열이 아닌). 단일 메시지를 전송한다는 점만 제외하면 위 두 케이스와 동일하게 동작한다.

Spring Integration에선 단일 인자를 받아 값을 반환하는 메소드를 하나 정의하기만 하면, 모든 POJO가 분할 알고리즘을 구현할 수 있다. POJO 메소드의 반환 값은 위에서 설명한 방법대로 해석된다. 입력 인자는 `Message`이거나 간단한 POJO일 수 있다. 후자의 경우 splitter는 전달받은 메시지의 페이로드를 받게 된다. 이 방법을 사용하면 애플리케이션 코드와 Spring Integration API와의 결합도를 낮출 수 있으며, 보통 테스트도 더 쉽기 때문에 더 권장하곤 한다.

#### Iterators

4.1 버전부터 `AbstractMessageSplitter`는 분할 결과를 `Iterator` 타입으로 생성할 수 있다. 주의할 점은, `Iterator`(혹은 `Iterable`)를 사용하면 내부 아이템 갯수에 액세스할 수 없으며, 그렇기 때문에 `SEQUENCE_SIZE` 헤더는 `0`으로 설정된다는 점이다. 즉, `<aggregator>`의 디폴트 `SequenceSizeReleaseStrategy`가 제대로 작동하지 않으며, 해당 `splitter`에서 채운 `CORRELATION_ID`에 해당하는 그룹은 release되지 않고 `incomplete` 상태로 남는다. 이 경우 적절한 커스텀 `ReleaseStrategy`를 구현하거나, `send-partial-result-on-expiry`를 `group-timeout`이나 `MessageGroupStoreReaper`와 함께 사용해야 한다.

5.0 버전부터 `AbstractMessageSplitter`는 가능한 경우 `Iterable` 및 `Iterator` 객체의 사이즈를 결정할 수 있는 `protected gatherSizeIfPossible()` 메소드를 제공한다. 예를 들어 `XPathMessageSplitter`는 내부 `NodeList` 객체의 사이즈를 알아낼 수 있다. 게다가 5.0.9 버전부터는 `com.fasterxml.jackson.core.TreeNode`의 사이즈도 적절히 반환해준다.

`Iterator` 객체는 메시지를 분할하기 전 메모리에 전체 컬렉션을 만들어둘 필요가 없어 유용하다. 예를 들면 어떤 외부 시스템(ex. DataBase, FTP `MGET`)에서 이터레이션이나 스트림을 사용해 내부 아이템들을 채우는 경우가 그렇다.

#### Stream and Flux

5.0 버전부터 `AbstractMessageSplitter`는 분할 결과를 자바 `Stream`과 리액티브 스트림즈 `Publisher` 타입으로 생성할 수 있다. 이 경우 각 타입이 제공하는 iteration 기능에 맞게 타겟 `Iterator`를 생성한다.

덧붙이면, splitter의 출력 채널이 `ReactiveStreamsSubscribableChannel`의 인스턴스인 경우, `AbstractMessageSplitter`는 `Iterator` 대신에 `Flux`로 된 결과를 생성하며, 이 출력 채널은 `Flux`를 구독해 다운스트림 플로우의 수요에 따라 back-pressure 기반으로 메시지를 분할한다.

5.2 버전부터 splitter는 `discardChannel` 옵션을 지원한다. split 함수가 비어있는 컨테이너(컬렉션, 배열, 스트림, `Flux` 등)를 반환한 메시지는 이 `discardChannel`로 전송된다. 빈 컨테이너를 리턴하면 순회할 아이템이 없어 `outputChannel`로 전송하지 않는다. split 결과가 `null`일 땐 그대로 반환해 플로우의 종료를 알린다.

### 8.3.2. Configuring a Splitter with XML

splitter는 다음과 같이 XML을 통해 설정할 수 있다:

```xml
<int:channel id="inputChannel"/>

<int:splitter id="splitter"            <!-- (1) -->
  ref="splitterBean"                   <!-- (2) -->
  method="split"                       <!-- (3) -->
  input-channel="inputChannel"         <!-- (4) -->
  output-channel="outputChannel"       <!-- (5) -->
  discard-channel="discardChannel" />  <!-- (6) -->

<int:channel id="outputChannel"/>

<beans:bean id="splitterBean" class="sample.PojoSplitter"/>
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> splitter의 ID는 선택사항이다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 애플리케이션 컨텍스트에 정의한 빈에 대한 참조. 이 빈은 반드시 앞 섹션에서 설명한 대로 분할 로직을 구현해야 하며, 생략할 수 있다. 빈 참조를 제공하지 않은 경우 `input-channel`에 도착한 메시지의 페이로드는 개별 요소들을 담고있는 `java.util.Collection` 구현체로 가정하고, 이 컬렉션에 디폴트 분할 로직을 적용한 뒤 `output-channel`로 전송한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 분할 로직을 구현한 메소드 (빈에 정의돼 있는 메소드). 생략할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> splitter의 입력 채널. 생략할 수 없다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> splitter가 받은 메시지를 분할한 결과들을 전송할 채널. 생략할 수 있다 (전달받은 메시지 자체에 응답 채널이 지정돼 있을 수 있기 때문).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(6)</span> 분할 결과가 비어 있는 경우 해당 요청 메시지를 전송할 채널. 생략할 수 있다 (결과가 `null`이면 중단한다).

커스텀 splitter 구현체를 다른 `<splitter>` 정의에서도 참조할 수 있다면 보통 `ref` 속성을 사용하는 것이 좋다. 하지만 커스텀 splitter 구현체의 스코프를 단일 `<splitter>` 정의 내로 한정하고 싶다면, 다음 예제와 같이 내부 빈 정의를 제공해도 된다:

```xml
<int:splitter id="testSplitter" input-channel="inChannel" method="split"
                output-channel="outChannel">
  <beans:bean class="org.foo.TestSplitter"/>
</int:splitter>
```

> 동일한 `<int:splitter>` 설정에서 `ref` 속성과 내부 핸들러 정의를 둘 다 사용하는 것은 허용하지 않는다. 둘 다 사용하면 조건이 모호해져 예외가 발생한다.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p><code class="highlighter-rouge">ref</code>
 속성으로 <code class="highlighter-rouge">AbstractMessageProducingHandler</code>를 상속한 빈을 참조하는 경우 (프레임워크에서 자체적으로 제공하는 splitter들처럼), 출력 채널을 핸들러에 직접 주입하는 식으로 최적화된다. 이때는 각 <code class="highlighter-rouge">ref</code> 속성마다 별도 빈 인스턴스(또는 <code class="highlighter-rouge">prototype</code> 스코프 빈)를 참조하거나, 내부 <code class="highlighter-rouge">&lt;bean/&gt;</code> 설정을 이용해야 한다. 단, 여기서 말하는 최적화는 splitter XML 정의에 특정 splitter 전용 속성을 제공하지 않았을 때에만 적용된다. 무심코 여러 빈에서 동일한 메시지 핸들러를 참조한다면 설정 예외를 만나게될 거다.</p>
</blockquote>


### 8.3.3. Configuring a Splitter with Annotations

`@Splitter` 어노테이션은 `Message` 타입이나 메시지 페이로드 타입을 받는 메소드에 적용할 수 있으며, 메소드의 반환 값은 어떤 타입의 `Collection`이어야 한다. 반환한 값들이 실제 `Message` 객체가 아니라면 각 항목을 페이로드로 갖는 `Message`로 감싼다. 결과로 만들어진 `Message`는 `@Splitter`를 정의한 엔드포인트에 지정된 출력 채널로 전송된다.

다음은 `@Splitter` 어노테이션을 사용해 splitter를 설정하는 방법을 보여주는 예시다:

```java
@Splitter
List<LineItem> extractItems(Order order) {
    return order.getItems()
}
```

[어노테이션을 이용해 엔드포인트에 어드바이스 체인 적용하기](../messaging-endpoints/#1098-advising-endpoints-using-annotations), [splitter](../java-dsl/#119-splitters), [파일 splitter](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/file.html#file-splitter)도 함께 참고해라.

---

## 8.4. Aggregator

aggregator는 여러 메시지를 받아 하나의 메시지로 결합해주는 메시지 핸들러로, splitter와 정반대 개념이다. 사실 aggregator는 파이프라인 앞쪽에 splitter를 가지고있는 다운스트림 컨슈머인 경우가 많다.

기술적으로 접근하면 aggregator는 상태를 가지기 때문에<sup>stateful</sup> splitter보다 복잡하다. 집계할 메시지들을 따로 보관해야 하며, 메시지 그룹을 집계할 준비가 됐는지도 판단해야 한다. 이와 같은 이유로 aggregator에선 `MessageStore`가 필요하다.

### 8.4.1. Functionality

Aggregator는 그룹이 완전히 준비됐다고 판단될 때까지 관련 메시지들을 연계해서 저장하고 그룹으로 결합한다. 그룹이 준비되면 전체 메시지를 가지고 하나의 메시지를 만들어 출력 채널로 전송한다.

aggregator를 구현하려면 집계 로직을 제공해야 한다 (여러 메시지로 하나의 메시지를 만드는 로직). 여기서는 correlation과 release라는 두 가지 개념이 나온다.

Correlation은 집계할 메시지들을 어떻게 묶을지를 판단하는 거다. Spring Integration에선 기본적으로 메시지 헤더 `IntegrationMessageHeaderAccessor.CORRELATION_ID`를 기반으로 correlation을 진행한다. 같은 `IntegrationMessageHeaderAccessor.CORRELATION_ID`를 가지고 있는 메시지들은 함께 묶인다. 물론, correlation 전략을 커스텀해서 직접 메시지를 묶을 방법을 지정할 수도 있다. 이때는 `CorrelationStrategy`를 구현하면 된다 (뒤에서 다룬다).

메시지 그룹을 처리할 준비가 됐는지는 `ReleaseStrategy`를 통해 결정한다. aggregator의 디폴트 release 전략에선  `IntegrationMessageHeaderAccessor.SEQUENCE_SIZE` 헤더를 기준으로 시퀀스 내 모든 메시지를 가지고 있다고 판단되면 그룹이 준비됐다고 보고 처리를 시작한다<sup>release</sup>. 디폴트 전략을 재정의하려면 커스텀 `ReleaseStrategy` 구현체의 참조를 제공하면 된다.

### 8.4.2. Programming Model

Aggregation API엔 다양한 클래스가 있다:

- 인터페이스 `MessageGroupProcessor`와 하위 클래스들: `MethodInvokingAggregatingMessageGroupProcessor`, `ExpressionEvaluatingMessageGroupProcessor`
- `ReleaseStrategy` 인터페이스와 디폴트 구현체: `SimpleSequenceSizeReleaseStrategy`
- `CorrelationStrategy` 인터페이스와 디폴트 구현체: `HeaderAttributeCorrelationStrategy`

#### `AggregatingMessageHandler`

`AggregatingMessageHandler`(`AbstractCorrelatingMessageHandler`의 하위 클래스)는 `MessageHandler` 구현체로, 다음과 같은 aggregator의 공통 기능을 캡슐화하고 있다 (다른 유스 케이스들도 포함하고 있다):

- 함께 집계할 메시지들을 하나의 그룹으로 연계
- 그룹을 release할 수 있을 때까지 이 메시지들을 `MessageStore`에 보관
- 그룹을 release할 수 있는 시점을 결정
- release한 그룹을 하나의 메시지로 집계
- 만료된 그룹을 알아내고 필요한 처리를 수행

메시지들을 어떻게 함께 묶어줄지 결정하는 일은 `CorrelationStrategy` 인스턴스에, 메시지 그룹을 release해도 되는지 결정하는 일은 `ReleaseStrategy` 인스턴스에 위임한다.

다음은 `AbstractAggregatingMessageGroupProcessor`에서 중요한 부분을 간략하게 나타낸 코드다 (`aggregatePayloads` 메소드는 개발자가 직접 구현한다):

```java
public abstract class AbstractAggregatingMessageGroupProcessor
              implements MessageGroupProcessor {

    protected Map<String, Object> aggregateHeaders(MessageGroup group) {
        // default implementation exists
    }

    protected abstract Object aggregatePayloads(MessageGroup group, Map<String, Object> defaultHeaders);

}
```

기본으로 제공하는 `AbstractAggregatingMessageGroupProcessor` 구현체는 `DefaultAggregatingMessageGroupProcessor`, `ExpressionEvaluatingMessageGroupProcessor`, `MethodInvokingMessageGroupProcessor`를 확인해봐라.

5.2 버전부터 `AbstractAggregatingMessageGroupProcessor`는 `Function<MessageGroup, Map<String, Object>>` 전략을 이용해 출력 메시지에 사용할 헤더를 통합하고 계산(집계)할 수 있다. 디폴트 구현체 `DefaultAggregateHeadersFunction`은 그룹 내에서 충돌이 없는 헤더들을 전부 반환한다; 그룹 내 모든 메시지에 담겨있지 않으면 충돌로 간주하지 않는다. 충돌하는 헤더는 제외시킨다. 그외 임의의 `MessageGroupProcessor` 구현체에선 (`AbstractAggregatingMessageGroupProcessor`를 구현하지 않은 구현체) 이 함수와 새로 도입된 `DelegatingMessageGroupProcessor`를 함께 사용한다. 스프링은 기본적으로, 설정해준 함수를 `AbstractAggregatingMessageGroupProcessor` 인스턴스에 주입하며, 그 외 다른 구현체는 모두 `DelegatingMessageGroupProcessor`로 감싼다. `AbstractAggregatingMessageGroupProcessor`와 `DelegatingMessageGroupProcessor`의 로직상 차이점은, 후자는 delegate 전략을 호출하기 전에 미리 헤더를 계산하지 않고, delegate가 `Message`나 `AbstractIntegrationMessageBuilder`를 반환하면 이 함수를 호출하지 않는다는 점이다. 이 경우 프레임워크는 타겟 구현체가 필요한 헤더들을 넣어서 반환했다고 가정한다. `Function<MessageGroup, Map<String, Object>>` 전략은 XML 설정에선 `headers-function` 참조 속성으로, Java DSL에선 `AggregatorSpec.headersFunction()` 옵션으로, 일반 자바 설정에선 `AggregatorFactoryBean.setHeadersFunction`으로 설정할 수 있다.

`CorrelationStrategy`는 `AbstractCorrelatingMessageHandler`가 가지고 있으며, 아래 보이는 것처럼 디폴트로는 메시지 헤더 `IntegrationMessageHeaderAccessor.CORRELATION_ID`를 기반으로 동작하는 구현체를 사용한다:

```java
public AbstractCorrelatingMessageHandler(MessageGroupProcessor processor, MessageGroupStore store,
        CorrelationStrategy correlationStrategy, ReleaseStrategy releaseStrategy) {
    ...
    this.correlationStrategy = correlationStrategy == null ?
        new HeaderAttributeCorrelationStrategy(IntegrationMessageHeaderAccessor.CORRELATION_ID) : correlationStrategy;
    this.releaseStrategy = releaseStrategy == null ? new SimpleSequenceSizeReleaseStrategy() : releaseStrategy;
    ...
}
```

메시지 그룹을 실제로 처리하는 기본 구현체는 `DefaultAggregatingMessageGroupProcessor`다. 이 클래스는 그룹으로 건내받은 페이로드의 `List`를 페이로드로 가지는 `Message`를 하나 생성한다. 이 구현체는 업스트림에 payload 나 publish-subscribe 채널, recipient list 라우터가 있을 때 간단한 scatter-gather 패턴을 구현하기 좋다.

> 이런 시나리오에서 publish-subscribe 채널이나 recipient list 라우터를 사용할 땐 `apply-sequence` 플래그를 활성화해줘야 한다. 그러면 필요한 헤더들이 추가될 거다 (`CORRELATION_ID`, `SEQUENCE_NUMBER`, `SEQUENCE_SIZE`). Spring Integration에 있는 splitter에선 기본적으로 활성화돼 있지만, publish-subscribe 채널이나 recipient list 라우터는 이런 헤더가 필요 없는 매우 다양한 컨텍스트에서 사용할 수 있기 때문에 기본으로 활성화되지 않는다.

애플리케이션에 필요한 전용 aggregator 전략을 구현하려면 `AbstractAggregatingMessageGroupProcessor`를 상속받아 `aggregatePayloads` 메소드를 구현하면 된다. 하지만 다른 방법을 이용하면 Aggregation API와의 결합도는 낮게 유지한 채 집계 로직을 구현할 수 있는데, 이때는 XML이나 어노테이션으로 설정을 추가해주면 된다.

대개는 단일 인자로 `java.util.List`를 받는 메소드만 있으면 모든 POJO로 집계 알고리즘을 구현할 수 있다 (리스트에 객체도 담을 수 있다). 이 메소드는 메시지들을 집계할 때 다음과 같이 실행된다:

- 인자가 `java.util.Collection<T>`이고 파라미터 타입 T를 `Message`에 할당할 수 있는 경우, 누적된 전체 메시지 리스트를 받는다.
- 인자가 파라미터 타입을 지정한 `java.util.Collection`이 아니거나, `Message`에 파라미터 타입을 할당할 수 없는 경우, 이 메소드엔 누적된 메시지들의 페이로드를 넘긴다.
- 리턴 타입이 `Message`에 할당할 수 없는 타입인 경우, 리턴한 객체를 페이로드로 취급하고 프레임워크에서 자동으로 `Message`를 만든다.

> 코드 복잡도나, 결합도, 테스트 난이도 등을 고려했을 땐, POJO를 통해 집계 로직을 구현하고 XML이나 어노테이션 설정을 추가하는 방식을 권장한다.

5.3 버전부터 `AbstractCorrelatingMessageHandler`는 메시지 그룹을 처리한 뒤 `MessageBuilder.popSequenceDetails()`를 호출해 메시지 헤더를 수정한다. 따라서 splitter-aggregator가 중첩돼있는 경우를 대응할 수 있다. 단, 메시지 그룹을 release한 결과가 메시지 컬렉션이 아닐 때만 호출한다. 이때는 타겟 `MessageGroupProcessor`가 메시지를 빌드하면서 `MessageBuilder.popSequenceDetails()`를 호출해야 한다.

`MessageGroupProcessor`가 `Message` 하나를 반환하면, 그룹 내 첫 번째 메시지와 `sequenceDetails`가 일치할 때만 출력 메시지에서 `MessageBuilder.popSequenceDetails()`를 실행할 거다. (이전에는 `MessageGroupProcessor`에서 순수 페이로드나 `AbstractIntegrationMessageBuilder`를 반환했을 때만 실행했었다.)

이 기능은 새롭게 지원하는 `boolean` 프로퍼티 `popSequence`로 제어할 수 있다. 따라서 표준 splitter에서 세부 correlation 정보를 채워넣지 않았다면 `MessageBuilder.popSequenceDetails()`를 비활성해도 된다. 이 프로퍼티는 사실상 업스트림에서 `applySequence = true`로 설정돼있는 가장 가까운 `AbstractMessageSplitter`가 수행한 작업을 원복한다. 자세한 내용은 [Splitter](#83-splitter)를 참고해라.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p><code class="highlighter-rouge">SimpleMessageGroup.getMessages()</code> 메소드는 <code class="highlighter-rouge">unmodifiableCollection</code>을 반환한다. 따라서 집계 로직이 담긴 POJO 메소드에 <code class="highlighter-rouge">Collection&lt;Message&gt;</code> 파라미터가 있을 때 전달하는 인자는 완전히 같은 <code class="highlighter-rouge">Collection</code> 인스턴스이며, aggregator에 <code class="highlighter-rouge">SimpleMessageStore</code>를 사용할 땐 그룹을 release하고 나면 본래 <code class="highlighter-rouge">Collection&lt;Message&gt;</code>는 비워진다. 결과적으로 POJO의 <code class="highlighter-rouge">Collection&lt;Message&gt;</code> 변수도 aggregator 바깥으로 전달되면 비워진다. 별도 처리를 위해 해당 컬렉션은 유지하면서 release하고 싶다면 반드시 <code class="highlighter-rouge">Collection</code>을 새로 생성해야 한다 (ex. <code class="highlighter-rouge">new ArrayList&lt;Message&gt;(messages)</code>). 4.3 버전부터 스프링은 불필요한 객체를 생성하지 않기 위해 더 이상 메시지들을 새 컬렉션으로 복사하지 않는다.</p>
</blockquote>
`MessageGroupProcessor`의 `processMessageGroup` 메소드가 컬렉션을 반환한다면 반드시 `Message<?>` 객체의 컬렉션이어야 한다. 이 경우 메시지들은 각각 따로 release된다. 4.2 버전 이전에는 XML 설정을 통해 `MessageGroupProcessor`를 제공할 수 없었고, 집계에는 오직 POJO 메소드만 사용할 수 있었다. 이제는 스프링이 참조하는 빈(또는 내부 빈)이 `MessageProcessor`를 구현한 것을 감지하면 이 빈을 aggregator의 출력 프로세서로 사용한다.

커스텀 `MessageGroupProcessor`가 반환한 객체 컬렉션을 메시지 페이로드로 삼아 release 하려면 직접 `AbstractAggregatingMessageGroupProcessor`를 상속받아 `aggregatePayloads()`를 구현해야 한다.

추가로, 4.2 버전부터 `SimpleMessageGroupProcessor`를 제공한다. 이 구현체는 앞에서 지정한 그룹의 메시지 컬렉션을 그대로 반환하므로, release된 메시지들은 개별적으로 전송된다.

이 클래스를 활용하면 aggregator를 메시지 barrier로 동작시킬 수 있다. 도착한 메시지들은 release 전략이 시행돼 해당 그룹을 개별 메시지들의 시퀀스로 release할 때까지 전송하지 않고 보류된다.

#### `ReleaseStrategy`

`ReleaseStrategy` 인터페이스는 다음과 같이 정의돼있다:

```java
public interface ReleaseStrategy {

  boolean canRelease(MessageGroup group);

}
```

일반적으로는 `java.util.List`를 단일 인자로 받아 (리스트에 파라미터 타입을 지정해도 된다) boolean 값을 반환하는 메소드를 제공한다면 POJO로도 그룹의 준비 여부를 판단하는 로직을 구현할 수 있다. POJO의 메소드는 메세지가 새로 도착할 때마다 다음과 같은 방법으로 호출돼 그룹이 온전히 준비되었는지를 판단한다:

- 인자가 `java.util.List<T>`이면서 파라미터 타입 `T`를 `Message`에 할당할 수 있는 경우, 이 메소드엔 그룹에 누적된 전체 메시지 목록이 전달된다.
- 인자가 파라미터 타입을 지정한 `java.util.List`가 아니거나 `Message`에 파라미터 타입을 할당할 수 없는 경우, 이 메소드엔 누적된 메시지들의 페이로드가 전달된다.
- 이 메소드는 메시지 그룹을 집계할 준비가 됐다면 반드시 `true`를, 그렇지 않으면 `false`를 반환해야 한다.

다음은 `Message` 타입 `List`에서 `@ReleaseStrategy` 어노테이션을 사용하는 예시다:

```java
public class MyReleaseStrategy {

    @ReleaseStrategy
    public boolean canMessagesBeReleased(List<Message<?>>) {...}
}
```

다음은 `String` 타입 `List`에서 `@ReleaseStrategy` 어노테이션을 사용하는 예시다:

```java
public class MyReleaseStrategy {

    @ReleaseStrategy
    public boolean canMessagesBeReleased(List<String>) {...}
}
```

POJO 기반 release 전략에선 위 두 예제에 보이는 시그니처에 따라, 아직 release되지 않은 메시지들의 `Collection`(`Message` 전체가 필요할 때)이나 페이로드 객체들의 `Collection`(타입 파라미터가 `Message`가 아닐 때)을 전달받는다. 대부분의 유스 케이스에선 이 두 가지로도 충분할 거다. 하지만 어떠한 이유로 전체 `MessageGroup`에 접근해야 한다면, `ReleaseStrategy` 인터페이스의 구현체를 제공해야 한다.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
    <p>그룹이 release되기 전까지는 release 전략을 여러 번 반복해서 호출할 수 있으므로 규모가 큰 그룹을 처리할 때는 이런 메소드들이 호출되는 방식을 이해하고 있어야 한다. 가장 효율적인 방법은 <code class="highlighter-rouge">ReleaseStrategy</code>의 구현체를 사용하는 거다. <code class="highlighter-rouge">ReleaseStrategy</code>의 구현체는 aggregator가 직접 호출할 수 있기 때문이다. 그 다음으로 효율적인 방법은 파라미터 타입으로 <code class="highlighter-rouge">Collection&lt;Message&lt;?&gt;&gt;</code>를 사용하는 POJO 메소드다. <code class="highlighter-rouge">Collection&lt;Something&gt;</code> 타입을 이용하는 POJO 메소드가 가장 효율적이지 못하다. 프레임워크는 release 전략을 호출할 때마다 그룹에 있는 메시지들의 페이로드를 새 컬렉션으로 복사해야 한다 (게다가 페이로드를 <code class="highlighter-rouge">Something</code>으로 변환해야 할 수도 있다). <code class="highlighter-rouge">Collection&lt;?&gt;</code>을 사용하면 변환을 피할 수 있지만 <code class="highlighter-rouge">Collection</code>을 새로 만들어야 한다는 사실은 변하지 않는다.</p>
    <p>이러한 이유로 규모가 큰 그룹을 사용할 때는 <code class="highlighter-rouge">ReleaseStrategy</code>를 구현하는 것이 좋다.</p>
</blockquote>

그룹을 release하고 집계할 때는, release되지 않았던 메시지들을 모두 처리해 그룹에서 제거한다. 그룹 역시 준비됐다면 (즉, 특정 시퀀스의 모든 메시지가 도착했거나 정의한 시퀀스가 없는 경우) 그룹은 complete로 마킹된다. 이 그룹에 새 메시지가 도착하면 전부 discard 채널(정의했다면)로 전송된다. `expire-groups-upon-completion`을 `true`로 설정하면 (기본값은 `false`다) 그룹을 통으로 제거하며, 새 메시지가 도착하면 (제거된 그룹과 동일한 correlation ID를 가지고 있는 메시지) 새로운 그룹을 형성한다. `send-partial-result-on-expiry`를 `true`로 설정한 상태에서 `MessageGroupStoreReaper`를 이용하면 시퀀스가 일부만 모였을 때에도 release할 수 있다.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>뒤늦게 도착한 메시지들을 폐기할 수 있으려면 aggregator는 반드시 그룹이 release된 이후에도 그룹에 대한 상태를 유지하고 있어야 한다. 이로 인해 종국엔 OOM<sup>out-of-memory</sup>이 발생하기도 한다. 이런 상황이 발생하지 않도록 하려면 <code class="highlighter-rouge">MessageGroupStoreReaper</code>를 설정해 그룹 메타데이터를 제거하는 방법을 검토해보는 것이 좋다. expiry 파라미터는 더 이상 뒤늦게 도착하는 메시지가 없을 것으로 예상되는 시점에 그룹을 만료시킬 수 있도록 설정해야 한다. reaper 설정에 대한 자세한 내용은 <a href="#844-managing-state-in-an-aggregator-messagegroupstore">Aggregator에서 상태 관리하기: <code class="highlighter-rouge">MessageGroupStore</code></a>를 참고해라.</p>
</blockquote>

Spring Integration은 `ReleaseStrategy`의 구현체 `SimpleSequenceSizeReleaseStrategy`를 제공한다. 이 구현체는 도착하는 각 메시지에 있는 `SEQUENCE_NUMBER`, `SEQUENCE_SIZE` 헤더를 통해 메시지 그룹이 완성돼 집계할 준비가 됐는지를 판단한다. 앞에서도 언급했지만 이 구현체가 디폴트 전략이다.

> 5.0 버전 이전에 사용하던 디폴트 release 전략은 `SequenceSizeReleaseStrategy`로, 규모가 큰 그룹에선 활용하기가 어려웠다. 이 전략을 사용하면 중복된 시퀀스 넘버를 감지해 거절하는데, 이 작업은 비용이 커지기 십상이다.

집계하는 그룹의 규모가 크고, 그룹을 일부만 release할 필요가 없으며, 중복 시퀀스를 감지/거절할 필요가 없다면 이대신 `SimpleSequenceSizeReleaseStrategy`를 사용하는 것을 검토해봐라. 이런 유스 케이스라면 `SimpleSequenceSizeReleaseStrategy`가 훨씬 더 효율적이며, *5.0 버전* 이후부턴 그룹을 부분적으로 release하지 않을 때 디폴트로 사용한다.

#### Aggregating Large Groups

4.3 릴리즈에선 `SimpleMessageGroup`에 메시지들을 담는 디폴트 `Collection`을 `HashSet`으로 변경했다. 전에는 `BlockingQueue`를 사용했는데, 규모가 큰 그룹에선 개별 메시지들을 제거하는 비용이 상당했다 (O(n)에 해당하는 선형 탐색이 필요했다). 해시 셋은 일반적으로 제거 연산이 훨씬 빠르긴 하지만, 삽입과 제거 연산 모두 해시 값을 계산해야 하기 때문에 대용량 메시지라면 역시 비용이 커질 수 있다. 메시지에서 해시 값을 계산해내는 비용이 크다면 다른 컬렉션 타입을 고려해봐야 한다. [`MessageGroupFactory` 사용하기](../system-management/#1331-using-messagegroupfactory)에서도 설명하지만, `SimpleMessageGroupFactory`라는 구현체를 제공하므로 요구사항에 가장 잘맞는 `Collection`을 선택해주면 된다. 아니면 자체 팩토리 구현체를 제공해서 다른 `Collection<Message<?>>`를 생성하는 것도 가능하다.

다음은 이전에 사용했던 구현체와 `SimpleSequenceSizeReleaseStrategy`로 aggregator를 설정하는 예제다:

```xml
<int:aggregator input-channel="aggregate"
    output-channel="out" message-store="store" release-strategy="releaser" />

<bean id="store" class="org.springframework.integration.store.SimpleMessageStore">
    <property name="messageGroupFactory">
        <bean class="org.springframework.integration.store.SimpleMessageGroupFactory">
            <constructor-arg value="BLOCKING_QUEUE"/>
        </bean>
    </property>
</bean>

<bean id="releaser" class="SimpleSequenceSizeReleaseStrategy" />
```

> aggregator의 업스트림에 필터 엔드포인트가 있는 경우, 필터에서 시퀀스에 속하는 일부 메시지를 제거할 수 있기 때문에 시퀀스 사이즈 release 전략(고정 사이즈를 사용하거나 `sequenceSize` 헤더를 이용하는 전략)은 원래 목적대로 사용할 수 없다. 이런 경우엔 다른 `ReleaseStrategy`를 선택하는 것이 좋다. 아니면 하위 discard 플로우에서 건너뛸 컨텐츠에 대한 정보를 담은 보상 메시지를 전송하고, complete 그룹 함수를 커스텀해 이 메시지를 활용하는 방법도 있다. 자세한 내용은 [필터](#82-filter)를 참고해라.

#### Correlation Strategy

`CorrelationStrategy` 인터페이스는 다음과 같이 정의돼있다:

```java
public interface CorrelationStrategy {

  Object getCorrelationKey(Message<?> message);

}
```

이 메소드가 반환하는 `Object`는 메시지를 메시지 그룹으로 연결하는 데 사용하는 correlation 키를 나타낸다. 이 키의 `equals()`와 `hashCode()` 메소드를 구현할 땐 `Map`에서의 키에 해당하는 기준을 충족하도록 구현해야 한다.

일반적으로 POJO로도 correlation 로직을 구현할 수 있으며, 메시지가 메소드의 인자(여러 개 가능)로 매핑되는 규칙은 `ServiceActivator`에서와 동일하다 (`@Header` 어노테이션도 포함해서). 이 메소드는 반드시 값을 하나 반환해야 하며, `null`이어선 안 된다.

Spring Integration은 `CorrelationStrategy`의 구현체 `HeaderAttributeCorrelationStrategy`를 제공한다. 이 구현체는 메시지 헤더 중 하나의 값을 correlation 키로 반환한다 (생성자 인자를 통해 사용할 헤더의 이름을 지정한다). 디폴트로 사용하는 correlation 전략은 `CORRELATION_ID` 헤더 값을 반환하는 `HeaderAttributeCorrelationStrategy`다. correlation에 이용하고 싶은 커스텀 헤더가 있다면 `HeaderAttributeCorrelationStrategy` 인스턴스를 따로 하나 설정해서 aggregator에서 사용할 correlation 전략으로 참조를 제공해주면 된다.

#### Lock Registry

그룹을 변경하는 일은 스레드로부터 안전하다<sup>thread-safe</sup>. 따라서 동시에 같은 correlation ID로 여러 메시지를 전송하더라도 aggregator에선 그 중 하나의 메시지만 처리하며, 사실상 **메시지 그룹당 하나의 스레드**로 작업하게 된다. correlation ID를 리졸브한 뒤 락<sup>lock</sup>을 얻어올 땐 `LockRegistry`를 사용한다. 기본적으론 `DefaultLockRegistry`를 사용한다 (인메모리 구현체). 같은 `MessageGroupStore`를 공유하는 서버들 간에 업데이트 내역을 동기화하려면 반드시 공유<sup>shared</sup> 락 레지스트리를 설정해줘야 한다.

#### Avoiding Deadlocks

위에서 설명한 바와 같이, 메시지 그룹이 변경될 때는 (메시지를 추가하거나 release할 땐) 락<sup>lock</sup>을 획득해 들고있는다.

다음과 같은 플로우를 생각해보자:

```none
...->aggregator1-> ... ->aggregator2-> ...
```

멀티 스레드를 이용하고 있고, **여러 aggregator가 하나의 공통 락 레지스트리를 공유**하는 경우 교착 상태<sup>deadlock</sup>에 빠지게 될 수 있다. 교착 상태에 빠지면 스레드가 멈추게 되며<sup>hang</sup>, `jstack <pid>`가 다음과 같은 결과를 보일 수 있다:

```none
Found one Java-level deadlock:
=============================
"t2":
  waiting for ownable synchronizer 0x000000076c1cbfa0, (a java.util.concurrent.locks.ReentrantLock$NonfairSync),
  which is held by "t1"
"t1":
  waiting for ownable synchronizer 0x000000076c1ccc00, (a java.util.concurrent.locks.ReentrantLock$NonfairSync),
  which is held by "t2"
```

이 문제는 여러 가지 방법으로 방지할 수 있다:

- 각 aggregator가 자체적인 락 레지스트리를 지니게 한다 (애플리케이션 인스턴스 간엔 하나의 레지스트리를 공유할 수 있지만, 하나의 플로우 상에 있는 복수 개의 aggregator는 반드시 각각 별개의 레지스트리를 가져야 한다)
- 다운스트림 플로우는 새로운 스레드에서 실행할 수 있도록 `ExecutorChannel`이나 `QueueChannel`을 aggregator의 출력 채널로 사용한다
- 5.1.1 버전부터, aggregator 프로퍼티 `releaseLockBeforeSend`를 `true`로 설정한다

> 어떤 이유로 특정 aggregator의 출력이 결국 동일한 aggregator로 다시 라우팅되는 경우에도 이 문제가 발생할 수 있다. 이 경우엔 당연히 위에 있는 첫 번째 방법으론 해결할 수 없다.

### 8.4.3. Configuring an Aggregator in Java DSL

Java DSL을 이용해 aggregator를 설정하는 방법은 [Aggregators and Resequencers](../java-dsl/#1110-aggregators-and-resequencers)를 참고해라.

#### Configuring an Aggregator with XML

Spring Integration에서 XML로 aggregator를 설정하려면 `<aggregator/>` 요소를 이용하면 된다. 다음은 aggregator를 하나 설정하는 예시다:

```xml
<channel id="inputChannel"/>

<int:aggregator id="myAggregator"                          <!-- (1) -->
        auto-startup="true"                                <!-- (2) -->
        input-channel="inputChannel"                       <!-- (3) -->
        output-channel="outputChannel"                     <!-- (4) -->
        discard-channel="throwAwayChannel"                 <!-- (5) -->
        message-store="persistentMessageStore"             <!-- (6) -->
        order="1"                                          <!-- (7) -->
        send-partial-result-on-expiry="false"              <!-- (8) -->
        send-timeout="1000"                                <!-- (9) -->

        correlation-strategy="correlationStrategyBean"     <!-- (10) -->
        correlation-strategy-method="correlate"            <!-- (11) -->
        correlation-strategy-expression="headers['foo']"   <!-- (12) -->

        ref="aggregatorBean"                               <!-- (13) -->
        method="aggregate"                                 <!-- (14) -->

        release-strategy="releaseStrategyBean"             <!-- (15) -->
        release-strategy-method="release"                  <!-- (16) -->
        release-strategy-expression="size() == 5"          <!-- (17) -->

        expire-groups-upon-completion="false"              <!-- (18) -->
        empty-group-min-timeout="60000"                    <!-- (19) -->

        lock-registry="lockRegistry"                       <!-- (20) -->

        group-timeout="60000"                              <!-- (21) -->
        group-timeout-expression="size() ge 2 ? 100 : -1"  <!-- (22) -->
        expire-groups-upon-timeout="true"                  <!-- (23) -->

        scheduler="taskScheduler" >                        <!-- (24) -->
            <expire-transactional/>                        <!-- (25) -->
            <expire-advice-chain/>                         <!-- (26) -->
</aggregator>

<int:channel id="outputChannel"/>

<int:channel id="throwAwayChannel"/>

<bean id="persistentMessageStore" class="org.springframework.integration.jdbc.store.JdbcMessageStore">
    <constructor-arg ref="dataSource"/>
</bean>

<bean id="aggregatorBean" class="sample.PojoAggregator"/>

<bean id="releaseStrategyBean" class="sample.PojoReleaseStrategy"/>

<bean id="correlationStrategyBean" class="sample.PojoCorrelationStrategy"/>
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> aggregator의 id는 선택사항이다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 애플리케이션 컨텍스트를 기동하면서 aggregator를 시작해야 하는지 여부를 나타내는 라이프사이클 관련 속성이다.<br>생략할 수 있다 (디폴트는 'true').</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> aggregator가 메시지를 받아올 채널.<br>필수 값이다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> aggregator가 집계 결과를 전송할 채널.<br>생략할 수 있다 (수신한 메시지 자체의 헤더 'replyChannel'에 응답 채널이 지정돼 있을 수도 있기 때문).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> aggregator가 타임아웃된 메시지들을 전송할 채널 (`send-partial-result-on-expiry`가 `false`인 경우에).<br>생략할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(6)</span> 메시지 그룹이 완성될 때까지 correlation 키 아래 메시지들을 저장하는 `MessageGroupStore`에 대한 참조.<br>생략할 수 있다.<br>기본적으로 휘발성의 인메모리 저장소를 사용한다.<br>자세한 내용은 [메시지 스토어](../system-management/#133-message-store)를 참고해라.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(7)</span> 둘 이상의 핸들러가 동일한 `DirectChannel`을 구독하는 경우 참고하는 이 aggregator의 순서 (로드 밸런싱 목적으로 사용).<br>생략할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(8)</span> 메시지들을 담고있는 `MessageGroup`이 만료되면 해당 메시지들을 집계해 'output-channel'이나 'replyChannel'로 보내야 하는지를 나타낸다 ([`MessageGroupStore.expireMessageGroups(long)`](https://docs.spring.io/spring-integration/api/org/springframework/integration/store/MessageGroupStore.html#expireMessageGroups-long) 참고).<br>`MessageGroup`을 만료시키는 방법으로는 `MessageGroupStoreReaper`를 설정하는 방법이 있다.<br>하지만 이 방법 대신 `MessageGroupStore.expireMessageGroups(timeout)`를 호출해도 `MessageGroup`을 만료시킬 수 있다.<br>Control Bus를 통해도 되고, `MessageGroupStore` 인스턴스에 대한 참조를 가지고 있다면 `expireMessageGroups(timeout)`를 호출하면 된다.<br>`MessageGroup`이 만료되지 않는다면 이 속성만으로는 아무런 일도 일어나지 않는다.<br>곧 만료되는 `MessageGroup`에 아직 남아 있는 메시지들을 전부 버릴지 출력 또는 응답 채널로 보낼지를 나타내는 단순한 지표라고 볼 수 있다.<br>이 속성은 생략할 수 있다 (디폴트는 `false`).<br>참고로, `expire-groups-upon-timeout`을 `false`로 설정한 경우 그룹이 실제로 만료되지 않을 수 있으므로 `send-partial-result-on-timeout`이라고 부르는 게 더 적합하다고 볼 수도 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(9)</span> 응답 `Message`를 `output-channel` 또는 `discard-channel`로 전송할 때 대기하는 타임아웃 간격.<br>기본값은 `-1`로 무한으로 블로킹된다.<br>고정 'capacity'를 사용하는 `QueueChannel`같이, '전송'에 제한이 있는 출력 채널을 사용할 때만 적용된다.<br>타임아웃이 발생하면 `MessageDeliveryException`을 던진다.<br>`AbstractSubscribableChannel`의 구현체들은 `send-timeout`을 무시한다.<br>`group-timeout(-expression)`의 경우 예약된 expire 태스크에서 `MessageDeliveryException`이 발생하면 해당 태스크를 다시 스케줄링한다.<br>생략할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(10)</span> 메시지 correlation (grouping) 알고리즘을 구현한 빈에 대한 참조.<br>이 빈은 `CorrelationStrategy` 인터페이스의 구현체일 수도, POJO일 수도 있다.<br>후자라면 `correlation-strategy-method` 속성도 반드시 함께 정의해야 한다.<br>생략할 수 있다 (aggregator는 기본적으로 `IntegrationMessageHeaderAccessor.CORRELATION_ID` 헤더를 사용한다).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(11)</span> `correlation-strategy`가 참조하는 빈에 정의돼있는 메소드.<br>이 메소드에서 correlation 결정 알고리즘을 구현한다.<br>생략할 수 있으며, 제약이 존재한다 (`correlation-strategy`를 반드시 정의해야 한다).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(12)</span> correlation 전략을 나타내는 SpEL 표현식.<br>ex: `"headers['something']"`.<br>`correlation-strategy`나 `correlation-strategy-expression`은 둘 중 하나만 사용할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(13)</span> 애플리케이션 컨텍스트에 정의돼있는 빈에 대한 참조.<br>이 빈은 앞에서 설명했듯이 반드시 집계 로직을 구현해야 한다.<br>생략할 수 있다 (기본적으론 집계한 메시지들의 리스트를 출력 메시지의 페이로드로 활용한다).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(14)</span> `ref` 속성으로 참조하는 빈에 정의돼있는 메소드.<br>이 메소드에서 메시지 집계 알고리즘을 구현한다.<br>생략할 수 있다 (`ref` 속성을 정의했는지에 따라 다르다).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(15)</span> release 전략을 구현한 빈에 대한 참조.<br>이 빈은 `ReleaseStrategy` 인터페이스의 구현체일 수도, POJO일 수도 있다.<br>후자라면 `release-strategy-method` 속성도 반드시 함께 정의해야 한다.<br>생략할 수 있다 (aggregator는 기본적으로 `IntegrationMessageHeaderAccessor.SEQUENCE_SIZE` 헤더를 사용한다).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(16)</span> `release-strategy` 속성이 참조하는 빈에 정의돼있는 메소드.<br>이 메소드에서 completion 결정 알고리즘을 구현한다.<br>생략할 수 있으며, 제약이 존재한다 (`release-strategy`를 반드시 정의해야 한다).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(17)</span> release 전략을 나타내는 SpEL 표현식.<br>표현식의 루트 객체는 `MessageGroup`이다.<br>ex: `"size() == 5"`.<br>`release-strategy`나 `release-strategy-expression`은 둘 중 하나만 사용할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(18)</span> `true`로 설정하면 (디폴트는 `false`다) 완료된 그룹은 메시지 스토어에서 제거되며, 이후 correlation이 같은 메시지가 도착하면 새 그룹을 만들게된다.<br>기본 동작에선 완료된 그룹과 동일한 correlation을 가진 메시지들은 `discard-channel`로 전송된다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(19)</span> `<aggregator>`의 `MessageStore`에 `MessageGroupStoreReaper`를 설정했을 때만 적용된다.<br>`MessageGroupStoreReaper`가 그룹을 부분적으로 만료하도록 설정돼있다면 기본적으로 비어있는 그룹 역시 제거한다.<br>빈 그룹은 그룹이 정상적으로 release된 후에 존재하는데, 덕분에 늦게 도착하는 메시지들을 감지하고 폐기할 수 있다.<br>그룹을 부분적으로 만료시키는 것보다 더 긴 주기로 빈 그룹을 만료시키고 싶다면 이 속성을 설정해라.<br>비어있는 그룹들은 최소한 이 밀리세컨드 동안 수정되지 않는다면 `MessageStore`에서 제거되지 않을 거다.<br>빈 그룹이 실제로 만료되는 시간은 reaper의 `timeout` 속성에도 영향을 받으며, 이 값에 타임아웃을 더한 시간만큼 걸릴 수도 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(20)</span> `org.springframework.integration.util.LockRegistry` 빈에 대한 참조.<br>`groupId`를 기반으로 `Lock`을 획득하는데 사용한다. 덕분에 같은 `MessageGroup`에 동시에 접근하는 상황을 대응할 수 있다.<br>기본적으론 내부 `DefaultLockRegistry`를 사용한다.<br>`ZookeeperLockRegistry`같은 분산 `LockRegistry`를 사용하면 특정 그룹에선 동시에 하나의 aggregator 인스턴스만이 작업할 수 있다.<br>자세한 내용은 [Redis Lock Registry](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/redis.html#redis-lock-registry), [Gemfire Lock Registry](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/gemfire.html#gemfire-lock-registry), [Zookeeper Lock Registry](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/zookeeper.html#zk-lock-registry)를 참고해라.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(21)</span> 현재 메시지가 도착했을 때 `ReleaseStrategy`가 그룹을 release하지 않으면 `MessageGroup`을 강제로 완료 상태로 만드는 타임아웃 (밀리세컨드 단위).<br>이 속성 덕분에 aggregator에 시간 기반 릴리즈 전략이 하나 내장된다고 볼 수 있다. `MessageGroup`에 마지막으로 메시지가 도착한 이후 타임아웃 기간 동안 새 메시지가 도착하지 않는 경우, 부분적인 결과를 내보내야 할 때 (혹은 그룹을 폐기해야 할 때) 활용할 수 있다.<br>`MessageGroup`이 생성된 시점부터 타임아웃을 계산하고 싶다면 `group-timeout-expression` 속성을 검토해봐라.<br>aggregator에 메시지가 새로 도착하면 해당 `MessageGroup`에 예약돼있는 기존 `ScheduledFuture<?>`는 모두 취소된다. `ReleaseStrategy`가 `false`를 반환하고 (release하지 않음을 의미) `groupTimeout > 0`이라면, 그룹을 만료시키는 태스크를 새로 예약한다.<br>이 속성을 0이나 음수 값으로 설정하는 것은 권하지 않는다.<br>이렇게 되면 모든 메시지 그룹이 즉시 완료되기 때문에 사실상 aggregator를 비활성화하는 거나 마찬가지다.<br>하지만 표현식을 사용하면 조건부로 0이나 음수로 설정할 수 있다.<br>자세한 내용은 `group-timeout-expression`을 참고해라.<br>그룹을 완료 상태로 만들면서 하는 일들은 `ReleaseStrategy`와 `send-partial-group-on-expiry` 속성에 따라 달라진다.<br>자세한 내용은 [Aggregator와 그룹 타임아웃](#aggregator-and-group-timeout)을 참고해라.<br>이 속성은 `group-timeout-expression`과 함께 사용할 수 없다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(22)</span> `groupTimeout`으로 평가되는 SpEL 표현식. `#root` 평가 컨텍스트 객체로 `MessageGroup`을 사용한다.<br>이 속성을 이용하면 `MessageGroup`을 강제로 완료 상태로 만드는 태스크를 예약할 수 있다.<br>표현식이 `null`로 평가되면 태스크를 예약하지 않는다.<br>0으로 평가되면 해당 그룹은 현재 스레드에서 즉시 완료된다.<br>사실상 이 속성은 `group-timeout`을 동적으로 만들어준다고 볼 수 있다.<br>예를 들어 그룹이 만들어지고 나서 10초가 지나면 `MessageGroup`을 강제로 완료시키고 싶다면, 이 SpEL 표현식을 검토해볼 수 있다: `timestamp + 10000 - T(System).currentTimeMillis()`. `MessageGroup`이 `#root` 평가 컨텍스트 객체이므로, 여기서 `timestamp`는 `MessageGroup.getTimestamp()`로 제공된다.<br>하지만 그룹의 생성 시각은 다른 그룹 만료 속성들을 어떻게 설정했는지에 따라, 메시지가 처음 도착한 시간과는 다를 수 있다는 사실을 명심해라.<br>자세한 내용은 `group-timeout`를 참고해라.<br>`group-timeout` 속성과는 함께 사용할 수 없다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(23)</span> 타임아웃으로 인해 (또는 `MessageGroupStoreReaper`로 인해) 그룹이 완료되면 기본적으로 해당 그룹은 만료된다 (완전히 제거된다).<br>이후 도착하는 메시지들은 새 그룹을 만들게 된다.<br>이 속성을 `false`로 설정하면 그룹을 완료하되 메타데이터는 남겨둘 수 있어 늦게 도착한 메시지들을 폐기할 수 있다.<br>빈 그룹은 `empty-group-min-timeout` 속성과 `MessageGroupStoreReaper`를 함께 사용하면 이후 만료시킬 수 있다.<br>기본값은 `true`다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(24)</span> `TaskScheduler` 빈에 참조. `MessageGroup`에 `groupTimeout` 내에 새 메시지가 도착하지 않으면 `MessageGroup`을 강제로 완료시키는 태스크를 예약할 때 사용한다.<br>따로 지정하지 않으면 `ApplicationContext`에 등록돼있는 기본 스케줄러 `taskScheduler`(`ThreadPoolTaskScheduler`)를 사용한다.<br>이 속성은 `group-timeout`이나 `group-timeout-expression`을 지정하지 않았다면 적용되지 않는다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(25)</span> 4.1 버전부터 지원.<br>`forceComplete` 작업을 위해 트랜잭션을 시작할 수 있다.<br>`forceComplete` 작업은  `group-timeout(-expression)`이나 `MessageGroupStoreReaper`에 의해 시작되며, 일반적인 `add`, `release`, `discard` 작업에는 적용되지 않는다.<br>하위 요소는 이 요소와 `<expire-advice-chain/>`만 허용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(26)</span> *4.1 버전*부터 지원.<br>`forceComplete` 작업에 원하는 `Advice`를 설정할 수 있다.<br>`forceComplete` 작업은 `group-timeout(-expression)`이나 `MessageGroupStoreReaper`에 의해 시작되며, 일반적인 `add`, `release`, `discard` 작업에는 적용되지 않는다.<br>하위 요소는 이 요소나 `<expire-transactional/>`만 허용한다.<br>Spring `tx` 네임스페이스를 사용하면 이곳에 트랜잭션 `Advice`를 구성할 수도 있다.</small>

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p id="aggregator-expiring-groups"><strong>Expiring Groups</strong></p>
  <p>그룹 만료(완전히 제거)와 관련해서는 두 가지 속성이 있다. 그룹이 만료되고 나면 관련 기록이 사라지며, 같은 correlation을 가진 메시지가 새로 도착하면 새로운 그룹을 시작한다. 그룹이 완료되면 (만료되지 않고) 빈 그룹이 남아 있게되며, 늦게 도착한 메시지들은 버려진다. 이 비어있는 그룹은 <code class="highlighter-rouge">empty-group-min-timeout</code> 속성과 <code class="highlighter-rouge">MessageGroupStoreReaper</code>를 조합해서 사용하면 이후에 제거할 수 있다.</p>
  <p><code class="highlighter-rouge">expire-groups-upon-completion</code>은 <code class="highlighter-rouge">ReleaseStrategy</code>가 그룹을 release하는 "정상적인" 완료와 관련된 속성이다. 기본값은 <code class="highlighter-rouge">false</code>다.</p>
  <p>그룹이 정상적으로 완료되진 않았지만 타임아웃으로 인해 release됐거나 폐기되었다면 해당 그룹은 통상적으로 만료된다. 이 동작은 4.1 버전부터 <code class="highlighter-rouge">expire-groups-upon-timeout</code>을 이용해 제어할 수 있다. 이전 버전과의 호환성을 위해 <code class="highlighter-rouge">true</code>가 디폴트다.</p>
  <blockquote>
    <p>그룹에 주어진 시간이 다 경과해 타임아웃되면 <code class="highlighter-rouge">ReleaseStrategy</code>가 그룹을 release할 수 있는 기회가 한 번 더 주어진다. 이때 그룹이 release되고 <code class="highlighter-rouge">expire-groups-upon-timeout</code>이 false인 경우, <code class="highlighter-rouge">expire-groups-upon-completion</code>에 따라 만료 여부가 결정된다. 타임아웃이 발생했는데도 릴리즈 전략으로 그룹이 release되지 않은 경우, <code class="highlighter-rouge">expire-groups-upon-timeout</code>에 따라 만료 여부가 결정된다. 타임아웃된 그룹들은 폐기되거나 부분적으로 release된다 (<code class="highlighter-rouge">send-partial-result-on-expiry</code>에 따라서).</p>
  </blockquote>
  <p>5.0 버전부터는 <code class="highlighter-rouge">empty-group-min-timeout</code> 만큼 시간이 경과해도 빈 그룹을 제거하는 태스크가 예약된다. 일반적인 release나 부분적인 시퀀스 release가 발생했을 때 <code class="highlighter-rouge">expireGroupsUponCompletion == false</code>이면서 <code class="highlighter-rouge">minimumTimeoutForEmptyGroups &gt; 0</code>이라면 그룹을 삭제하는 태스크가 예약된다.</p>
  <p>5.4 버전부터 aggregator(및 resequencer)는 설정을 통해 버려진<sup>orphaned</sup> 그룹을 만료시키도록 만들어줄 수 있다 (영구<sup>persistent</sup> 메시지 스토어에 있으며, 이 설정이 없으면 release되지 않을 수도 있는 그룹들을 뜻한다). <code class="highlighter-rouge">expireTimeout</code>(<code class="highlighter-rouge">0</code>보다 클 때)은 스토어에서 이 값보다 오래된 그룹은 제거<sup>purge</sup>해야 한다는 걸 나타낸다. <code class="highlighter-rouge">purgeOrphanedGroups()</code> 메소드는 기동 시에 한번 호출하며, 지정한 <code class="highlighter-rouge">expireDuration</code> 간격으로 스케줄링되는 태스크 내에서 주기적으로 호출한다. 이 메소드는 또한 언제든지 외부에서도 호출할 수 있다. 만료 로직은 위에서 언급한 만료 옵션들에 따라 <code class="highlighter-rouge">forceComplete(MessageGroup)</code>에 완전히 위임한다. 이런 주기적인 퍼지<sup>purge</sup> 기능은 일반적인 메시지 도착 로직으로는 더 이상 release되지 않는 오래된 그룹에서 메시지 스토어를 정리해줘야 할 때 유용하다. 이런 케이스는 대부분 영구<sup>persistent</sup> 메시지 그룹 스토어를 사용 중일 때 애플리케이션이 재시작되고나서 발생한다. 이 기능은 예약된 태스크에서 <code class="highlighter-rouge">MessageGroupStoreReaper</code>를 사용하는 것과 유사하지만, reaper 대신 그룹 타임아웃을 사용할 때 특정 컴포넌트 내에서 오래된 그룹들을 쉽게 처리할 수 있게 해준다. <code class="highlighter-rouge">MessageGroupStore</code>는 현재 correlation 엔드포인트에 대해서만 배타적으로 제공돼야 한다. 그렇지 않으면 특정 aggregator에서 다른 aggregator의 그룹을 제거해버릴 수도 있다. 이렇게 aggregator를 사용하면, 이 테크닉으로 만료된 그룹은 <code class="highlighter-rouge">expireGroupsUponCompletion</code> 속성에 따라 버려지거나 부분적으로 release된다.</p>
</blockquote>


커스텀 aggregator 핸들러 구현체를 다른 `<aggregator>` 정의에서도 참조할 수 있다면 보통 `ref` 속성 사용을 권장한다. 하지만 커스텀 aggregator 구현체를 하나의 `<aggregator>` 정의에서만 사용한다면, 다음과 같이 내부 빈 정의를 사용해 (1.0.3 버전부터) `<aggregator>` 요소 내에 POJO를 설정해도 된다:

```xml
<aggregator input-channel="input" method="sum" output-channel="output">
    <beans:bean class="org.foo.PojoAggregator"/>
</aggregator>
```

> 동일한 `<aggregator>` 설정에서 `ref` 속성과 내부 빈 정의를 둘 다 사용하는 것은 허용하지 않는다. 둘 다 사용하면 조건이 모호해져 예외가 발생한다.

다음은 aggregator 빈의 구현체 예시다:

```java
public class PojoAggregator {

  public Long add(List<Long> results) {
    long total = 0l;
    for (long partialResult: results) {
      total += partialResult;
    }
    return total;
  }
}
```

위 예시에서 사용할 completion strategy 빈은 다음과 같이 구현할 수 있다:

```java
public class PojoReleaseStrategy {
...
  public boolean canRelease(List<Long> numbers) {
    int sum = 0;
    for (long number: numbers) {
      sum += number;
    }
    return sum >= maxValue;
  }
}
```

> 상황에 따라 필요하다면 release strategy 메소드와 aggregator 메소드를 하나의 빈으로 결합할 수도 있다.

위 예시에서 사용할 correlation strategy 빈은 다음과 같이 구현할 수 있다:

```java
public class PojoCorrelationStrategy {
...
  public Long groupNumbersByLastDigit(Long number) {
    return number % 10;
  }
}
```

위 예제에서 aggregator는 어떠한 기준(이 경우 10으로 나눈 나머지 값)에 따라 숫자들을 그룹으로 묶으며, 페이로드에 해당하는 숫자들의 합이 특정 값을 넘어가기 전까지 그룹을 유지한다.

> 상황에 따라 필요하다면 release strategy 메소드와  correlation strategy 메소드, aggregator 메소드를 하나의 빈으로 결합할 수도 있다. (사실 전부 다 결합할 수도, 두 개만 결합할 수도 있다.)

#### Aggregators and Spring Expression Language (SpEL)

Spring Integration 2.0부터 [SpEL](https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#expressions)을 사용해 다양한 전략들(correlation, release, aggregation)을 처리할 수 있으며, 이런 release 전략 등이 비교적 단순한 로직이라면 사용을 권장하고 있다. 객체의 배열을 받도록 설계된 레거시 컴포넌트가 있다고 가정해보자. 우리는 디폴트 release 전략이 `List`에 집계된 모든 메시지를 조립한다는 것을 알고 있다. 여기서는 두 가지 요구사항이 있다. 먼저, 리스트에서 메시지들을 개별적으로 추출해야 한다. 둘째, 각 메시지의 페이로드를 추출해서 객체들의 배열로 조합해야 한다. 다음은 두 요구사항을 모두 해결한 예제다:

```java
public String[] processRelease(List<Message<String>> messages){
    List<String> stringList = new ArrayList<String>();
    for (Message<String> message : messages) {
        stringList.add(message.getPayload());
    }
    return stringList.toArray(new String[]{});
}
```

하지만 SpEL을 사용한다면, 실제로 이런 요구사항은 한 줄짜리 표현식으로 비교적 간단하게 처리할 수 있다. 따라서 커스텀 클래스를 작성하고 빈으로 설정해줄 필요가 없어진다. 다음은 SpEL을 사용한 예제다:

```xml
<int:aggregator input-channel="aggChannel"
    output-channel="replyChannel"
    expression="#this.![payload].toArray()"/>
```

위 설정에선 [collection projection](https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#expressions) 표현식을 사용해 리스트에 있는 모든 메시지들의 페이로드를 모아 새 컬렉션을 만든 다음, 이를 배열로 변환한다. 즉, 앞서 보여준 자바 코드와 동일한 결과를 만들어낸다.

커스텀 release, correlation 전략을 처리할 때도 마찬가지로 표현식을 이용할 수 있다.

`correlation-strategy` 속성으로 커스텀 `CorrelationStrategy` 빈을 정의하는 대신, 다음 예제와 같이 SpEL 표현식으로 간단한 correlation 로직을 구현하고 `correlation-strategy-expression` 속성에 설정해주면 된다:

```xml
correlation-strategy-expression="payload.person.id"
```

위 예제에선 페이로드에 `id`가 있는 `person`이란 속성이 있다고 가정하고 있다. 메시지를 연계할 땐 바로 이 속성을 사용할 거다.

`ReleaseStrategy`에서도 마찬가지로 release 로직을 SpEL 표현식으로 구현하고 `release-strategy-expression` 속성에 설정해주면 된다. 평가 컨텍스트의 루트 객체는 `MessageGroup` 자체다. 표현식 내에서 메시지들의 `List`를 참조하려면 이 그룹의 `message` 프로퍼티를 사용하면 된다.

> 5.0 버전 이전 릴리즈에서 루트 객체는 이전 예제에서도 알 수 있듯이 `Message<?>`의 컬렉션이었다:

```xml
release-strategy-expression="!messages.?[payload==5].empty"
```

위 예제에선 SpEL 평가 컨텍스트의 루트 객체는 `MessageGroup` 자체이며, 이 그룹에 `5`라는 페이로드를 가진 메시지가 생기는 즉시 그룹을 release해야 한다고 명시하고 있다.

#### Aggregator and Group Timeout

4.0 버전부터 새로운 두 가지 속성 `group-timeout`, `group-timeout-expression`이 도입됐으며, 이 둘은 상호 배타적이다 (함께 사용할 수 없다). [XML로 Aggregator 설정하기](#configuring-an-aggregator-with-xml)를 함께 참고해라. 경우에 따라서는 현재 메시지가 도착했을 때 `ReleaseStrategy`가 그룹을 release시키지 않는다면, 타임아웃 이후 집계 결과를 내보내거나 그룹을 폐기해야 할 수도 있다. 이때는 다음과 같이 `groupTimeout` 옵션을 이용해 `MessageGroup`을 강제로 완료시키는 태스크를 예약할 수 있다:

```xml
<aggregator input-channel="input" output-channel="output"
        send-partial-result-on-expiry="true"
        group-timeout-expression="size() ge 2 ? 10000 : -1"
        release-strategy-expression="messages[0].headers.sequenceNumber == messages[0].headers.sequenceSize"/>
```

이 예제에선 `release-strategy-expression`에 정의된 대로, aggregator가 시퀀스 내 마지막 메시지를 수신하면 정상적인 release가 가능하다. release를 유발해줄 메시지가 도착하지 않을 때는, 그룹에 메시지가 최소 두 개 들어있기만 한다면 `groupTimeout`이 10초 뒤 그룹을 강제로 완료 상태로 바꿔준다.

그룹을 강제로 완료한 뒤의 결과는 `ReleaseStrategy`와 `send-partial-result-on-expiry`에 따라 달라진다. 먼저 release 전략을 다시 호출해 정상적인 release가 가능한지를 확인해본다. 그룹이 변경되진 않았더라도, `ReleaseStrategy`로 이번엔 그룹을 release할지를 결정할 수 있다. release 전략에서 이번에도 그룹을 release하지 않는다면 해당 그룹은 만료된다. 이때 `send-partial-result-on-expiry`가 `true`이면 (일부만 담겨있는) `MessageGroup`에 있는 기존 메시지들은 `output-channel`로 보내는 일반적인 aggregator 응답 메시지로 release되며, `true`가 아닐 땐 폐기된다.

`groupTimeout` 관련 동작과 `MessageGroupStoreReaper`에는 한 가지 차이점이 있다 ([XML로 Aggregator 설정하기](#configuring-an-aggregator-with-xml) 참고). Reaper는 주기적으로 `MessageGroupStore`의 모든 `MessageGroup`에 대한 강제 완료 처리를 시작한다. `groupTimeout`은 `groupTimeout`이 지나도 새 메시지가 도착하지 않으면 각 `MessageGroup`에 대해 같은 처리를 개별적으로 수행한다. 또한 reaper는 빈 그룹을 제거할 때에도 사용할 수 있다 (빈 그룹들을 유지하는 이유는 `expire-groups-upon-completion`이 false일 때 뒤늦게 도착하는 메시지들을 폐기하기 위함이다).

5.5 버전부터 `groupTimeoutExpression`은 `java.util.Date` 인스턴스로 평가될 수 있다. `groupTimeoutExpression`을 `long`으로 평가해서 메시지가 도착한 시간을 기반으로 타임아웃을 계산하는 대신, 그룹 생성 시간(`MessageGroup.getTimestamp()`)을 기반으로 태스크를 예약할 수 있어 유용하다:

```java
group-timeout-expression="size() ge 2 ? new java.util.Date(timestamp + 200) : null"
```

#### Configuring an Aggregator with Annotations

다음은 어노테이션을 이용해 aggregator를 설정하는 예시다:

```java
public class Waiter {
  ...

  @Aggregator  // (1)
  public Delivery aggregatingMethod(List<OrderItem> items) {
    ...
  }

  @ReleaseStrategy  // (2)
  public boolean releaseChecker(List<Message<?>> messages) {
    ...
  }

  @CorrelationStrategy  // (3)
  public String correlateBy(OrderItem item) {
    ...
  }
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 이 어노테이션은 이 메소드를 aggregator로 사용해야 한다는 걸 나타낸다. 이 클래스를 aggregator로 사용한다면 반드시 명시해야 한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 이 어노테이션은 이 메소드를 aggregator의 release 전략으로 사용해야 한다는 걸 나타낸다. 어떤 메소드에도 선언하지 않으면 aggregator는 `SimpleSequenceSizeReleaseStrategy`를 사용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 이 어노테이션은 이 메소드를 aggregator의 correlation 전략으로 사용해야 한다는 걸 나타낸다. correlation 전략을 지정하지 않으면 aggregator는 `CORRELATION_ID` 기반 `HeaderAttributeCorrelationStrategy`를 사용한다.</small>

`@Aggregator` 어노테이션을 이용할 때도 XML 요소에서 제공하는 모든 설정 옵션을 사용할 수 있다.

aggregator는 XML에 명시적되어있다면 XML에서 참조할 수도 있고, 클래스에 `@MessageEndpoint`를 정의했다면 클래스패스 스캔을 통해 자동으로 감지할 수도 있다.

Aggregator 컴포넌트를 어노테이션으로 설정한다면 (`@Aggregator` 등), 대부분 디폴트 옵션들만으로 충분한 간단한 유스 케이스만 구성할 수 있다. 어노테이션 설정을 사용하는데 관련 옵션들을 좀더 커스텀해야 한다면, 다음과 같이 `AggregatingMessageHandler`를 `@Bean`으로 정의하고 해당 `@Bean` 메소드를 `@ServiceActivator`로 마킹하는 것을 검토해봐라:

```java
@ServiceActivator(inputChannel = "aggregatorChannel")
@Bean
public MessageHandler aggregator(MessageGroupStore jdbcMessageGroupStore) {
     AggregatingMessageHandler aggregator =
                       new AggregatingMessageHandler(new DefaultAggregatingMessageGroupProcessor(),
                                                 jdbcMessageGroupStore);
     aggregator.setOutputChannel(resultsChannel());
     aggregator.setGroupTimeoutExpression(new ValueExpression<>(500L));
     aggregator.setTaskScheduler(this.taskScheduler);
     return aggregator;
}
```

자세한 정보는 [프로그래밍 모델](#842-programming-model)과 [`@Bean` 메소드 위에 선언할 수 있는 어노테이션들](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/configuration.html#annotations_on_beans)을 읽어봐라.

> 4.2 버전부터는 `AggregatorFactoryBean`을 이용해 좀더 간단한 자바 설정으로 `AggregatingMessageHandler`를 구성할 수 있다.

### 8.4.4. Managing State in an Aggregator: `MessageGroupStore`

Aggregator는 일정 기간 동안 같은 correlation 키로 도착한 메시지들을 기반으로 메시지 그룹을 결정해야 하는 stateful 패턴이다 (Spring Integration에는 aggregator 말고도 stateful에 해당하는 몇 가지 다른 패턴들도 있다). Stateful 패턴에 쓰이는 인터페이스들은 (`ReleaseStrategy` 등) 해당 컴포넌트가 (정의한 주체가 프레임워크이든 사용자든) stateless 상태를 유지할 수 있어야 한다는 원칙 하에 설계한다. 모든 상태 정보는 `MessageGroup`에 담겨있으며, 상태 관리는 `MessageGroupStore`에 위임한다. `MessageGroupStore` 인터페이스는 다음과 같이 정의돼있다:

```java
public interface MessageGroupStore {

    int getMessageCountForAllMessageGroups();

    int getMarkedMessageCountForAllMessageGroups();

    int getMessageGroupCount();

    MessageGroup getMessageGroup(Object groupId);

    MessageGroup addMessageToGroup(Object groupId, Message<?> message);

    MessageGroup markMessageGroup(MessageGroup group);

    MessageGroup removeMessageFromGroup(Object key, Message<?> messageToRemove);

    MessageGroup markMessageFromGroup(Object key, Message<?> messageToMark);

    void removeMessageGroup(Object groupId);

    void registerMessageGroupExpiryCallback(MessageGroupCallback callback);

    int expireMessageGroups(long timeout);
}
```

자세한 정보는 [Javadoc](https://docs.spring.io/spring-integration/api/org/springframework/integration/store/MessageGroupStore.html)을 참고해라.

`MessageGroupStore`는 release 전략이 트리거되기를 기다리면서 `MessageGroups`에 상태 정보를 누적하는데, release 전략은 끝내 트리거되지 않을 수도 있다. 따라서 `MessageGroupStore`를 사용할 땐 `MessageGroup`이 만료될 때 적용할 콜백을 등록할 수 있다. 콜백을 활용하면 오래된<sup>stale </sup> 메시지를 정리해줄 수 있으며, 휘발성<sup>volatile</sup> 저장소를 이용할 땐 애플리케이션이 종료될 때 리소스 정리를 위한 훅을 등록할 수 있다. 콜백 인터페이스는 아래 보이는 것처럼 매우 직관적이다:

```java
public interface MessageGroupCallback {

    void execute(MessageGroupStore messageGroupStore, MessageGroup group);

}
```

콜백에선 메시지 스토어와 메시지 그룹에 직접 접근할 수 있으므로, 보관 중인<sup>persistent</sup> 상태를 관리할 수 있다 (예를 들어 메시지 스토어에서 그룹을 통째로 제거할 수 있다).

`MessageGroupStore`는 이 콜백 목록을 가지고 있으며, 타임스탬프가 파라미터로 전달보다 시간보다 앞선 모든 메시지를 대상으로 콜백을 실행한다 (앞에서 설명한 `registerMessageGroupExpiryCallback(..)`, `expireMessageGroups(..)` 메소드 참고).

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p><code class="highlighter-rouge">expireMessageGroups</code> 기능을 이용한다면, 다른 aggregator 컴포넌트에서 같은 <code class="highlighter-rouge">MessageGroupStore</code> 인스턴스를 사용하지 않도록 주의해야 한다. <code class="highlighter-rouge">AbstractCorrelatingMessageHandler</code>는 전부 <code class="highlighter-rouge">forceComplete()</code> 콜백을 기반으로 자체 <code class="highlighter-rouge">MessageGroupCallback</code>을 등록한다. 이렇게 하면 만료되는 그룹들이 엉뚱한 aggregator에 의해 완료되거나 폐기될 수 있다. 5.0.10 버전부터 <code class="highlighter-rouge">AbstractCorrelatingMessageHandler</code>에서 <code class="highlighter-rouge">MessageGroupStore</code>에 콜백을 등록할 땐 <code class="highlighter-rouge">UniqueExpiryCallback</code>을 사용한다. <code class="highlighter-rouge">MessageGroupStore</code>에선 해당 클래스의 인스턴스가 이미 있는지를 확인하고, 콜백 셋에 같은 인스턴스가 존재하는 경우 적당한 에러 그를 남긴다. 프레임워크는 이와 같이 다른 aggregator/resequencer에서 <code class="highlighter-rouge">MessageGroupStore</code> 인스턴스를 사용하지 못하도록 해서, 앞서 언급한 특정 correlation 핸들러가 직접 만들지 않는 그룹을 만료시키는 부작용을 방지해준다.</p>
</blockquote>

`expireMessageGroups` 메소드를 호출할 땐 타임아웃 값을 넘길 수 있다. 현재 시간에서 이 값을 뺀 시간보다 오래된 메시지들은 전부 만료되고 콜백을 실행한다. 따라서 메시지 그룹의 "만료"가 의미하는 바는 메시지 스토어의 사용자가 결정할 수 있다.

Spring Integration은 편의를 위해 메시지 만료를 위한 래퍼 `MessageGroupStoreReaper`를 제공한다:

```xml
<bean id="reaper" class="org...MessageGroupStoreReaper">
    <property name="messageGroupStore" ref="messageStore"/>
    <property name="timeout" value="30000"/>
</bean>

<task:scheduled-tasks scheduler="scheduler">
    <task:scheduled ref="reaper" method="run" fixed-rate="10000"/>
</task:scheduled-tasks>
```

이 reaper는 `Runnable`이다. 위 예제에선 메시지 그룹 스토어의 expire 메소드를 10초마다 호출한다. 자체 타임아웃은 30초다.

> `MessageGroupStoreReaper`의 'timeout' 프로퍼티는 대략적인 근사치라는 걸 이해해야 한다. 이 프로퍼티는 다음에 예약된 `MessageGroupStoreReaper` 태스크를 실행할 때에만 확인하기 때문에, 실제 타임아웃은 태스크 스케줄러의 속도에 따라 달라질 수 있다. 예를 들어 타임아웃은 10분으로 설정돼 있지만, `MessageGroupStoreReaper` 태스크가 매시간 실행되도록 예약돼 있고 `MessageGroupStoreReaper` 태스크를 마지막으로 실행한 게 타임아웃 1분 전이라면, 앞으로 59분 동안은 `MessageGroup`이 만료되지 않는다. 따라서 태스크 실행 간격은 최소한 타임아웃과 같거나 더 짧은 간격으로 설정하는 것이 좋다.

만료 콜백은 리퍼 외에도 `AbstractCorrelatingMessageHandler`의 라이프사이클 콜백을 통해 애플리케이션이 종료될 때도 실행된다.

`AbstractCorrelatingMessageHandler`는 자체 만료 콜백을 등록하며, 콜백은 aggregator의 XML 설정에 있는 boolean 플래그 `send-partial-result-on-expiry`와 연결된다. 이 플래그를 `true`로 설정하면 만료 콜백이 실행될 때 아직 release 전인 그룹에 있는, 마킹되지 않는 메시지들을 출력 채널로 전송할 수 있다.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p><code class="highlighter-rouge">MessageGroupStoreReaper</code>는 예약된 태스크에서 호출하고 다운스트림 플로우로 메시지를 보낼 수도 있기때문에 (<code class="highlighter-rouge">sendPartialResultOnExpiry</code> 옵션에 따라 다르다), <code class="highlighter-rouge">MessagePublishingErrorHandler</code>와 커스텀 <code class="highlighter-rouge">TaskScheduler</code>를 제공해서 <code class="highlighter-rouge">errorChannel</code>을 통해 예외를 처리하는 것을 권장한다. 일반적인 aggregator release 기능에서도 기대하는 방식이기도 하다. 마찬가지로 <code class="highlighter-rouge">TaskScheduler</code>에 의존하는 그룹 타임아웃에서도 동일하다. 자세한 내용은 <a href="https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/error-handling.html#error-handling">에러 핸들링</a>을 참고해라.</p>
</blockquote>

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>서로 다른 correlation 엔드포인트에서 하나의 <code class="highlighter-rouge">MessageStore</code>를 공유하고 있다면 반드시 적합한 <code class="highlighter-rouge">CorrelationStrategy</code>를 설정해서  그룹 ID의 고유성을 보장해줘야 한다. 그렇지 않으면 특정 correlation 엔드포인트가 다른 엔드포인트의 메시지를 release하거나 만료해서 의도와는 다르게 동작할 수도 있다. correlation 키가 동일한 메시지는 동일한 메시지 그룹에 저장된다.</p>
  <p><code class="highlighter-rouge">MessageStore</code> 구현체에 따라서는 데이터를 분할해 물리적으로 동일한 리소스를 사용할 수 있는 구현체도 있다. 예를 들어 <code class="highlighter-rouge">JdbcMessageStore</code>에는 <code class="highlighter-rouge">region</code>이란 속성이 있으며, <code class="highlighter-rouge">MongoDbMessageStore</code>에는 <code class="highlighter-rouge">collectionName</code>이란 속성이 있다.</p>
  <p><code class="highlighter-rouge">MessageStore</code> 인터페이스와 구현체에 대한 좀더 자세한 내용은 <a href="../system-management/#133-message-store">메시지 스토어</a>를 읽봐라.</p>
</blockquote>

### 8.4.5. Flux Aggregator

5.2 버전에선 `FluxAggregatorMessageHandler` 컴포넌트를 도입했다. 이 핸들러는 프로젝트 리액터의 `Flux.groupBy()`, `Flux.window()` 연산자를 사용한다. 들어오는 메시지들은 생성자 안에서 `Flux.create()`로 시작했던 `FluxSink`로 방출한다. `outputChannel`을 제공하지 않거나 `ReactiveStreamsSubscribableChannel`의 인스턴스가 아닌 경우, 메인 `Flux`에 대한 구독은 `Lifecycle.start()` 구현부에서 수행한다. 그 외는 `ReactiveStreamsSubscribableChannel` 구현체에서 구독을 수행하는 것으로 연기한다. 메시지들은 `Flux.groupBy()`를 통해 묶이며, 그룹 키엔 `CorrelationStrategy`를 사용한다. 기본적으론 메시지의 `IntegrationMessageHeaderAccessor.CORRELATION_ID` 헤더를 참조한다.

기본적으로 윈도우가 닫히면 페이로드에 `Flux`를 담은 메시지를 만들어 윈도우를 release한다. 이 메시지는 윈도우의 첫 번째 메시지에 있는 모든 헤더를 가지고 있다. 출력 메시지 페이로드 안에 담겨있는 이 `Flux`는 다운스트림에서 반드시 구독하고 처리해야 한다. 관련 로직은 `FluxAggregatorMessageHandler`의 설정 옵션 `setCombineFunction(Function<Flux<Message<?>>, Mono<Message<?>>>)`로 커스텀(또는 대체)할 수 있다. 예를 들어, 최종적으로 만드는 메시지에 페이로드의 `List`를 담고싶다면 다음과 같이 `Flux.collectList()`를 설정해주면 된다:

```java
fluxAggregatorMessageHandler.setCombineFunction(
                (messageFlux) ->
                        messageFlux
                                .map(Message::getPayload)
                                .collectList()
                                .map(GenericMessage::new));
```

`FluxAggregatorMessageHandler`에는 여러 가지 옵션이 있어 적절한 윈도우 전략을 선택할 수 있다:

- `setBoundaryTrigger(Predicate<Message<?>>)` - `Flux.windowUntil()` 연산자로 전파된다. 자세한 내용은 해당 JavaDocs를 참고해라. 전체 윈도우 옵션 중에서 우선순위가 가장 높다.
- `setWindowSize(int)`, `setWindowSizeFunction(Function<Message<?>, Integer>)` - `Flux.window(int)` 혹은 `windowTimeout(int, Duration)`으로 전파된다. 기본적으로 윈도우 사이즈는 그룹의 첫 번째 메시지와 거기있는 `IntegrationMessageHeaderAccessor.SEQUENCE_SIZE` 헤더로 계산한다.
- `setWindowTimespan(Duration)` - 윈도우 사이즈 설정에 따라 `Flux.window(Duration)`이나 `windowTimeout(int, Duration)`으로 전파된다.
- `setWindowConfigurer(Function<Flux<Message<?>>, Flux<Flux<Message<?>>>>)` - 기존 옵션으론 해결할 수 없는 커스텀 윈도우 연산을 위한, 그룹으로 묶인 플럭스들을 변환하는 함수.

이 컴포넌트는 `MessageHandler` 구현체이므로 간단히 메시징 어노테이션 `@ServiceActivator`와 `@Bean` 정의로 사용할 수 있다. Java DSL에선 EIP 메소드 `.handle()`에서 사용하면 된다. 아래 보이는 샘플은 런타임에 `IntegrationFlow`를 등록하고, `FluxAggregatorMessageHandler`를 업스트림 splitter와 연계하는 방법을 보여준다:

```java
IntegrationFlow fluxFlow =
        (flow) -> flow
                .split()
                .channel(MessageChannels.flux())
                .handle(new FluxAggregatorMessageHandler());

IntegrationFlowContext.IntegrationFlowRegistration registration =
        this.integrationFlowContext.registration(fluxFlow)
                .register();

@SuppressWarnings("unchecked")
Flux<Message<?>> window =
        registration.getMessagingTemplate()
                .convertSendAndReceive(new Integer[] { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 }, Flux.class);
```

### 8.4.6. Condition on the Message Group

5.5 버전부터 `AbstractCorrelatingMessageHandler`(자바 & XML DSL 포함)는 `BiFunction<Message<?>, String, String>` 타입 옵션 `groupConditionSupplier`를 제공한다. 이 함수는 그룹에 메시지가 추가될 때마다 호출하며, 리턴한 condition 문자열은 그룹에 저장돼 이후에 참작할 수 있다. `ReleaseStrategy`에선 그룹에 있는 모든 메시지를 순회하는 대신에 이 condition을 참조할 수 있다. 자세한 내용은 `GroupConditionProvider` JavaDocs와 [메시지 그룹 Condition](../system-management/#1333-message-group-condition)을 참고해라.

[File Aggregator](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/file.html#file-aggregator)도 함께 읽어보면 좋다.

---

## 8.5. Resequencer

resequencer는 aggregator와 관련이 있지만 사용하는 목적은 다르다. Aggregator는 메시지들을 결합해주는 반면, resequencer를 거치더라도 메시지는 변경되지 않는다.

### 8.5.1. Functionality

resequencer는 `CORRELATION_ID`를 사용해 메시지들을 그룹에 저장한다는 점에선 aggregator와 유사하게 동작한다. 차이점은 Resequencer는 어떤 방식으로든 메시지를 가공하지 않는다는 것이다. 대신 `SEQUENCE_NUMBER` 헤더 값을 기준으로 메시지들을 정렬해서 release한다.

이와 관련해서는, 모든 메시지를 한 번에 release할 수도 있고 (`SEQUENCE_SIZE` 등에 따라 전체 시퀀스가 모이고 나면), 유효한 시퀀스가 하나라도 있으면 즉시 release할 수 있다. (이 챕뒤 에서 "유효한 시퀀스"가 의미하는 바를 설명한다.)

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>resequencer는 짧은 간격으로 들어오는, 상대적으로 짧은 메시지 시퀀스를 재배열하는 용도다. 긴 시간 동안 따로 따로 들어오는 시퀀스가 많다면 성능 문제를 겪을 수도 있다.</p>
</blockquote>

### 8.5.2. Configuring a Resequencer

Java DSL을 이용해 resequencer를 설정한다면 [Aggregator와 Resequencer](../java-dsl/#1110-aggregators-and-resequencers)를 참고해라.

resequencer를 설정할 땐 XML에 적당한 요소만 추가해주면 된다.

다음은 resequencer 설정 예시다:

```xml
<int:channel id="inputChannel"/>

<int:channel id="outputChannel"/>

<int:resequencer id="completelyDefinedResequencer"  <!-- (1) -->
  input-channel="inputChannel"  <!-- (2) -->
  output-channel="outputChannel"  <!-- (3) -->
  discard-channel="discardChannel"  <!-- (4) -->
  release-partial-sequences="true"  <!-- (5) -->
  message-store="messageStore"  <!-- (6) -->
  send-partial-result-on-expiry="true"  <!-- (7) -->
  send-timeout="86420000"  <!-- (8) -->
  correlation-strategy="correlationStrategyBean"  <!-- (9) -->
  correlation-strategy-method="correlate"  <!-- (10) -->
  correlation-strategy-expression="headers['something']"  <!-- (11) -->
  release-strategy="releaseStrategyBean"  <!-- (12) -->
  release-strategy-method="release"  <!-- (13) -->
  release-strategy-expression="size() == 10"  <!-- (14) -->
  empty-group-min-timeout="60000"  <!-- (15) -->

  lock-registry="lockRegistry"  <!-- (16) -->

  group-timeout="60000"  <!-- (17) -->
  group-timeout-expression="size() ge 2 ? 100 : -1"  <!-- (18) --> 
  scheduler="taskScheduler" />  <!-- (19) -->
  expire-group-upon-timeout="false" />  <!-- (20) -->
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span>  resequencer의 id는 생략할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span>  resequencer의 입력 채널.<br>생략할 수 없다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> resequencer가 재정렬한 메시지들을 전송할 채널.<br>생략할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> resequencer가 타임아웃된 메시지들을 전송할 채널 (`send-partial-result-on-timeout`을 `false`로 설정한 경우).<br>생략할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> 정렬한 시퀀스들을 가능할 때 바로 전송할지 아니면 전체 메시지 그룹이 모이고 나면 보낼지 여부.<br>생략할 수 있다.<br>(기본값은 `false`다.)</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(6)</span> 메시지 그룹이 완성될 때까지 correlation 키 아래 메시지 그룹을 저장하는 데 사용하는 `MessageGroupStore`에 대한 참조.<br>생략할 수 있다.<br>(기본적으로 휘발성의 인메모리 저장소를 사용한다.)</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(7)</span> 그룹이 만료되면 정렬한 그룹을 전송해야 하는지 여부 (일부 메시지가 누락됐더라도).<br>생략할 수 있다.<br>(디폴트는 false다.)<br>[Aggregator에서 상태 관리하기: `MessageGroupStore`](#844-managing-state-in-an-aggregator-messagegroupstore)를 참고해라.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(8)</span> 응답 `Message`를 `output-channel` 또는 `discard-channel`에 전송할 때 대기하는 타임아웃 간격. 기본값은 `-1`로 무한으로 블로킹된다.<br>고정 'capacity'를 사용하는 `QueueChannel`같이, '전송'에 제한이 있는 출력 채널을 사용할 때만 적용된다. 타임아웃이 발생하면 `MessageDeliveryException`을 던진다.<br>`AbstractSubscribableChannel`의 구현체들은 `send-timeout`을 무시한다.<br>`group-timeout(-expression)`의 경우 예약된 expire 태스크에서 `MessageDeliveryException`이 발생하면 해당 태스크를 다시 스케줄링한다.<br>생략할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(9)</span> 메시지 correlation (grouping) 알고리즘을 구현한 빈에 대한 참조.<br>이 빈은 `CorrelationStrategy` 인터페이스의 구현체일 수도, POJO일 수도 있다.<br>후자라면 `correlation-strategy-method` 속성도 반드시 함께 정의해야 한다.<br>생략할 수 있다 (aggregator는 기본적으로 `IntegrationMessageHeaderAccessor.CORRELATION_ID` 헤더를 사용한다.)</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(10)</span> `correlation-strategy`가 참조하는 빈에 정의돼있는 메소드. 이 메소드에서 correlation 결정 알고리즘을 구현한다.<br>생략할 수 있으며, 제약이 존재한다 (`correlation-strategy`를 반드시 정의해야 한다).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(11)</span> correlation 전략을 나타내는 SpEL 표현식.<br>ex: `"headers['something']"`).<br>`correlation-strategy`나 `correlation-strategy-expression`은 둘 중 하나만 사용할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(12)</span> release 전략을 구현한 빈에 대한 참조.<br>이 빈은 `ReleaseStrategy` 인터페이스의 구현체일 수도, POJO일 수도 있다.<br>후자라면 `release-strategy-method` 속성도 반드시 함께 정의해야 한다.<br>생략할 수 있다 (aggregator는 기본적으로 `IntegrationMessageHeaderAccessor.SEQUENCE_SIZE` 헤더를 사용한다).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(13)</span> `release-strategy`가 참조하는 빈에 정의돼있는 메소드. 이 메소드에서 completion 결정 알고리즘을 구현한다.<br>생략할 수 있으며, 제약이 존재한다 (`release-strategy`를 반드시 정의해야 한다).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(14)</span> release 전략을 나타내는 SpEL 표현식.<br>표현식의 루트 객체는 `MessageGroup`이다.<br>ex: `"size() == 5"`.<br>`release-strategy`나 `release-strategy-expression`은 둘 중 하나만 사용할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(15)</span> `<resequencer>` 의`MessageStore`에 `MessageGroupStoreReaper`를 설정했을 때만 적용된다.<br>`MessageGroupStoreReaper`가 그룹을 부분적으로 만료하도록 설정돼있다면 기본적으로 비어있는 그룹 역시 제거한다.<br>빈 그룹은 그룹이 정상적으로 release된 후에 존재하는데, 덕분에 늦게 도착하는 메시지들을 감지하고 폐기할 수 있다.<br>그룹을 부분적으로 만료시키는 것보다 더 긴 주기로 빈 그룹을 만료시키고 싶다면 이 속성을 설정해라.<br>비어있는 그룹들은 최소한 이 밀리세컨드 동안 수정되지 않는다면 `MessageStore`에서 제거되지 않을 거다.<br>빈 그룹이 실제로 만료되는 시간은 reaper의 타임아웃 속성에도 영향을 받으며, 이 값에 타임아웃을 더한 시간만큼 걸릴 수도 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(16)</span> [XML로 Aggregator 설정하기](#configuring-an-aggregator-with-xml) 참고.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(17)</span> [XML로 Aggregator 설정하기](#configuring-an-aggregator-with-xml) 참고.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(18)</span> [XML로 Aggregator 설정하기](#configuring-an-aggregator-with-xml) 참고.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(19)</span> [XML로 Aggregator 설정하기](#configuring-an-aggregator-with-xml) 참고.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(20)</span> 타임아웃으로 인해 (또는 `MessageGroupStoreReaper`로 인해) 그룹이 완료되면 기본적으로 빈 그룹의 메타데이터를 보관한다.<br>따라서 늦게 도착하는 메시지들은 즉시 폐기된다.<br>그룹을 완전히 제거하려면 이 속성을 `true`로 설정해라.<br>그러면 늦게 도착한 메시지들은 새 그룹을 시작하고 그룹이 다시 타임아웃되기 전까진 폐기하지 않는다.<br>새로 만들어진 그룹은 타임아웃를 유발한 시퀀스 범위 내의 "구멍" 때문에 절대 정상적으로 release되지 않는다.<br>빈 그룹들은 `empty-group-min-timeout` 속성과 `MessageGroupStoreReaper`를 함께 사용하면 이후 만료시킬 수 있다 (완전히 제거된다).<br>5.0 버전부터 `empty-group-min-timeout`이 경과하면 빈 그룹도 함께 제거하도록 스케줄링된다.<br>기본값은 'false'다.</small>

자세한 내용은 [Aggregator 그룹 만료시키기](#aggregator-expiring-groups)를 함께 참고해라.

> resequencer와 관련해서는, 자바 클래스에서 구현할만한 커스텀 동작이 없기 때문에 따로 지원하는 어노테이션은 없다.

---

## 8.6. Message Handler Chain

`MessageHandlerChain`은 실제 동작은 필터, transformer, splitter 등과 같은 다른 핸들러들로 구성된 체인에 위임하면서, 단일 메시지 엔드포인트로 설정할 수 있는 `MessageHandler`의 구현체다. 여러 가지 핸들러를 고정된 순서로 연결해서 선형으로 실행해야 한다면 `MessageHandlerChain`을 이용하는 게 훨씬 더 간단하다. 예를 들면 다른 구성 요소 앞에 transformer를 두는 경우가 꽤 많다. 비슷하게 체인 앞부분에 필터를 두면 본질적으로 [선택적인<sup>selective</sup> 컨슈머](https://www.enterpriseintegrationpatterns.com/MessageSelector.html)를 만들게 된다. 두 체인 모두 하나의 `input-channel`과 하나의 `output-channel`만 있으면 되기 때문에, 구성 요소마다 개별적으로 채널을 정의해주지 않아도 된다.

> `MessageHandlerChain`은 대부분 XML 설정 위주로 설계됐다. Java DSL의 `IntegrationFlow` 정의는 하나의 체인 컴포넌트로 취급할 순 있지만, 아래에서 설명하는 개념과 원칙들과는 관련이 없다. 자세한 내용은 [Java DSL](../java-dsl)을 참고해라.

> Spring Integration의 `Filter`는 `throwExceptionOnRejection`이라는 boolean 프로퍼티를 제공한다. 하나의 point-to-point 채널에서 메시지를 수락하는 기준이 다른 여러 가지 선택적<sup>selective</sup> 컨슈머가 있다면, 이 값을 'true'로 설정해주는 것이 좋다 (기본값은 `false`다). 그러면 dispatcher에서 메시지가 거부되었음을 알 수 있으며, 결과적으로 메시지를 다른 구독자에게 전달해볼 수 있다. 예외를 던지지 않으면, 필터에서 메시지를 버려 추가적인 처리가 일어나지 않는 경우에도 dispatcher는 메시지 전달에 성공한 것으로 밖에 알 수가 없다. 정말로 메시지를 "삭제<sup>drop</sup>"하고 싶을 때는 필터의 'discard-channel'도 유용할 수 있다. 'discard-channel'을 이용하면 삭제된 메시지로 원하는 작업을 수행할 수 있다 (JMS 큐에 메시지를 전송하거나 로그로 남기는 등).

핸들러 체인 설정은 매우 단순한데, 내부 구성 요소 간의 결합도는 똑같이 느슨하게 유지해준다. 어느 시점엔 비선형적인 조합이 필요해지더라도, 쉽게 설정을 변경할 수 있다.

체인의 내부에선 가지고 있는 엔드포인트들을 선형적으로 확장한다. 이 엔드포인트들은 익명 채널로 구분된다. 체인 내에선 reply 채널 헤더를 고려하지 않는다. 마지막 핸들러를 호출했을 때만 결과 메시지를 reply 채널이나 체인의 출력 채널로 전달한다. 이와 같은 구조로 인해 마지막 핸들러를 제외한 모든 핸들러는 `MessageProducer` 인터페이스를 구현해야 한다 ('setOutputChannel()' 메소드). `MessageHandlerChain`에 `outputChannel`이 설정돼 있으면 마지막 핸들러는 출력 채널 하나만 있으면 된다.

> 다른 엔드포인트와 마찬가지로 `output-channel`은 선택 사항이다. 체인이 끝날 때 응답 메시지가 있는 경우 output-channel을 우선시한다. 하지만 응답 메시지가 없다면 체인 핸들러는 폴백으로 인바운드 메시지에서 reply 채널 헤더를 확인해본다.

대부분의 경우 `MessageHandler`를 직접 구현할 필요가 없다. 다음 섹션에선 네임스페이스 지원을 이용해 체인 요소를 설정하는 방법에 집중한다. 서비스 activator와 transformer같은 대부분의 Spring Integration 엔드포인트들은 `MessageHandlerChain` 내에서 사용하기 알맞게 설계돼있다.

### 8.6.1. Configuring a Chain

`<chain>` 요소는 `input-channel` 속성을 제공한다. 체인의 마지막 요소가 응답 메시지를 생성하는 경우를 위해 (선택 사항이다), `output-channel` 속성도 지원한다. 하위 요소로는 filter, transformer, splitter, service-activator가 있다. 마지막 요소는 라우터나 아웃바운드 채널 어댑터일 수도 있다. 다음은 체인을 정의하는 예시다:

```xml
<int:chain input-channel="input" output-channel="output">
    <int:filter ref="someSelector" throw-exception-on-rejection="true"/>
    <int:header-enricher>
        <int:header name="thing1" value="thing2"/>
    </int:header-enricher>
    <int:service-activator ref="someService" method="someMethod"/>
</int:chain>
```

위 예제에서 사용한 `<header-enricher>` 요소는 메시지에 `thing1`이라는 헤더를 `thing2`라는 값으로 설정해준다. 헤더 enricher는 헤더 값에만 손을 대는 특화된 `Transformer`다. 헤더를 수정하는 `MessageHandler`를 구현하고 빈으로 연결해줘도 같은 결과를 얻을 수 있지만, header-enricher가 훨씬 더 간단하다.

`<chain>`은 메시지 플로우를 "마감하는<sup>closed-box</sup>" 마지막 컨슈머로 설정해도 된다. 이럴 땐 아래 예제와 같이 \<chain\>의 끝에 원하는 \<outbound-channel-adapter\>를 넣어주면 된다:

```xml
<int:chain input-channel="input">
    <int-xml:marshalling-transformer marshaller="marshaller" result-type="StringResult" />
    <int:service-activator ref="someService" method="someMethod"/>
    <int:header-enricher>
        <int:header name="thing1" value="thing2"/>
    </int:header-enricher>
    <int:logging-channel-adapter level="INFO" log-full-message="true"/>
</int:chain>
```

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p><strong>Disallowed Attributes and Elements</strong></p>
  <p>체인 내에 있는 구성 요소에선 <code class="highlighter-rouge">order</code>와 <code class="highlighter-rouge">input-channel</code>같은 몇 가지 속성들을 지정할 수 없다. 하위요소 poller에서도 마찬가지다.</p>
  <p>Spring Integration 핵심 컴포넌트들은 XML 스키마 자체가 일부 제약 조건을 시행한다. 하지만 비핵심 컴포넌트들이나 사용자의 커스텀 컴포넌트의 경우, 이런 제약들은 XML 스키마가 아닌 XML 네임스페이스 파서가 적용한다.</p>
  <p>XML 네임스페이스 파서의 제약 조건은 Spring Integration 2.2에서 추가됐다. 허용하지 않는 속성이나 요소를 사용하려고 하면 XML 네임스페이스 파서에서 <code class="highlighter-rouge">BeanDefinitionParsingException</code>을 던진다.</p>
</blockquote>

### 8.6.2. Using the 'id' Attribute

Spring Integration 3.0부터 체인 요소에 `id` 속성이 주어지면, 체인의 `id`와 요소 자체의 `id`를 조합한 값을 요소의 빈 이름으로 사용한다. `id` 속성이 없는 요소는 빈으로 등록되진 않지만, 각각은 체인 `id`를 포함하는 `componentName`이 부여된다. 아래 예시를 살펴보자:

```xml
<int:chain id="somethingChain" input-channel="input">
    <int:service-activator id="somethingService" ref="someService" method="someMethod"/>
    <int:object-to-json-transformer/>
</int:chain>
```

위 예제에선:

- 루트 요소 `<chain>`에는 'somethingChain'이란 `id`가 있다. 따라서 `AbstractEndpoint`를 구현한 (`Input-channel`의 유형에 따라 `PollingConsumer`나 `EventDrivenConsumer`) 빈은 이 값을 빈 이름으로 사용한다.
- `MessageHandlerChain` 빈은 빈 alias가 생기며 ('somethingChain.handler'), 덕분에 `BeanFactory`에서 이 빈에 직접 액세스할 수 있다.
- `<service-activator>`는 모든 것을 다 갖춘 메시징 엔드포인트라고 할 수 없다 (`PollingConsumer`나 `EventDrivenConsumer`가 아니다). `<chain>` 내에 존재하는 `MessageHandler`다. 이 경우 `BeanFactory`엔 `somethingChain$child.somethingService.handler`라는 이름의 빈으로 등록된다.
- 이 `ServiceActivatingHandler`의 `componentName`은 동일한 값을 사용하지만 '.handler' suffix는 없다. 즉, 'somethingChain$child.somethingService'가 된다.
- `<chain>`의 마지막 하위 구성 요소 `<object-to-json-transformer>`는 `id` 속성을 가지고 있지 않다. 이 요소의 `componentName`은 `<chain>`에서의 위치를 기반으로 만들어진다. 이 예시에선 'somethingChain$child#1'이다. (이름의 마지막 부분이 체인 내의 순서를 나타내며, '#0'으로 시작한다). 참고로 이 transformer는 애플리케이션 컨텍스트 내 빈으로 등록되지 않으므로, `beanName`은 주어지지 않는다. 하지만 `componentName`에 로깅 등에 유용한 값이 담겨 있다.

`<chain>` 요소들에 `id` 속성을 사용하면 [JMX 익스포터](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/jmx.html#jmx-mbean-exporter)에도 적합하며, [메시지 히스토리](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/message-history.html#message-history)에서 추적할 수 있다. 앞에서 언급한 것처럼 적당한 빈 이름을 사용하면 `BeanFactory`로 액세스할 수도 있다.

> `<chain>` 요소에 `id` 속성을 명시하면, 로그에서 하위 구성 요소를 간단하게 식별하고, `BeanFactory`에서 액세스할 수 있어 유용하다.

### 8.6.3. Calling a Chain from within a Chain

간혹 체인 내에서 다른 체인을 중첩해서 호출한 뒤, 다시 돌아와 원래의 체인을 계속해서 실행해야 할 때가 있다. 이럴 땐 다음 예제와 같이 \<gateway\> 요소를 추가해서 메시징 게이트웨이를 사용하면 된다:

```xml
<int:chain id="main-chain" input-channel="in" output-channel="out">
    <int:header-enricher>
      <int:header name="name" value="Many" />
    </int:header-enricher>
    <int:service-activator>
      <bean class="org.foo.SampleService" />
    </int:service-activator>
    <int:gateway request-channel="inputA"/>
</int:chain>

<int:chain id="nested-chain-a" input-channel="inputA">
    <int:header-enricher>
        <int:header name="name" value="Moe" />
    </int:header-enricher>
    <int:gateway request-channel="inputB"/>
    <int:service-activator>
        <bean class="org.foo.SampleService" />
    </int:service-activator>
</int:chain>

<int:chain id="nested-chain-b" input-channel="inputB">
    <int:header-enricher>
        <int:header name="name" value="Jack" />
    </int:header-enricher>
    <int:service-activator>
        <bean class="org.foo.SampleService" />
    </int:service-activator>
</int:chain>
```

위 예제에선 `main-chain` 처리가 끝나갈 때 체인 끝에 설정돼있는 'gateway' 요소가 `nested-chain-a`를 호출한다. `nested-chain-a`를 처리하는 동안은 헤더를 추가<sup>enrichment</sup>한 후에 `nested-chain-b`를 호출한다. 이후 원래 흐름으로 돌아와 `nested-chain-b`에서의 실행을 완료한다. 마지막엔 `main-chain`으로 돌아간다. 체인 안에 `<gateway>` 요소를 중첩해서 정의할 땐 `service-interface` 속성이 필요하지 않다. 대신 메시지를 현재 상태로 가져와 `request-channel` 속성에 정의돼있는 채널에 배치한다. 이 게이트웨이가 시작한 다운스트림 플로우가 완료되면 게이트웨이로 `Message`가 반환되고 현재 체인에서 여정을 이어간다.

---

## 8.7. Scatter-Gather

4.1 버전부터 Spring Integration은 엔터프라이즈 통합 패턴 [scatter-gather](https://www.enterpriseintegrationpatterns.com/BroadcastAggregate.html)의 구현체를 제공한다. 이 구현체는 복합 엔드포인트로, 여러 수신자<sup>recipient</sup>에게 메시지를 보내고 그 결과를 집계하는 것이 목적이다. [*Enterprise Integration Patterns*](https://www.enterpriseintegrationpatterns.com/)에서 언급하는 것 처럼, 이 컴포넌트는 "최상의 견적<sup>best quote</sup>"을 찾는 시나리오에 적용할 수 있다. 여기서 말하는 최상의 견적이란, 여러 공급 업체<sup>supplier</sup>에 정보를 요청하고 요청 항목에 가장 적합한 조건을 제공할 수 있는 업체를 결정하는 것을 말한다.

예전엔 이 패턴을 구성할 땐 컴포넌트들을 개별적으로 사용했었다. 이제는 전보다 간편하게 설정할 수 있다.

`ScatterGatherHandler`는 `PublishSubscribeChannel`(또는 `RecipientListRouter`)과 `AggregatingMessageHandler`를 결합한 request-reply 엔드포인트다. 요청 메시지는 `scatter` 채널로 전송되며, `ScatterGatherHandler`는 응답을 기다렸다가 aggregator를 이용해 응답을 `outputChannel`로 전송한다.

### 8.7.1. Functionality

`Scatter-Gather` 패턴에는 "경매<sup>auction</sup>" 방식과 "배급<sup>distribution</sup>" 방식이 있다. 두 시나리오 모두 `aggregation` 기능은 동일하며, `AggregatingMessageHandler`에서 사용할 수 있는 모든 옵션을 제공한다. (사실 `ScatterGatherHandler`의 생성자 인자로는 `AggregatingMessageHandler`만 넘겨주면 된다.) 자세한 내용은 [Aggregator](#84-aggregator)를 참고해라.

#### Auction

`Scatter-Gather`의 auction 버전은 요청 메시지에 “publish-subscribe” 로직을 적용한다. 이때 “scatter” 채널은 `apply-sequence="true"`인 `PublishSubscribeChannel`이다. 물론 이 채널엔 어떤 `MessageChannel` 구현체라도 사용할 수 있다 (`ContentEnricher`의 `request-channel`에서처럼 — [Content Enricher](../messaging-transformation/#92-content-enricher) 참고). 하지만 그러려면 `aggregation`에 사용할 자체 커스텀 `correlationStrategy`를 만들어야 한다.

#### Distribution

`Scatter-Gather`의 distribution 버전은 `RecipientListRouter` 기반이어서, `RecipientListRouter`에서 제공하는 모든 옵션을 사용할 수 있다 ([`RecipientListRouter`](#recipientlistrouter) 참고). `recipient-list-router`와 `aggregator`에서 디폴트 `correlationStrategy`만 사용하고 싶다면 `apply-sequence="true"`를 지정해야 한다. 그렇지 않으면 `aggregator`에서 사용할 커스텀 `correlationStrategy`를 제공해줘야 한다. `PublishSubscribeChannel` 방식(auction 버전)과는 달리, `recipient-list-router` `selector` 옵션을 사용하면 메시지를 기반으로 타겟 supplier를 필터링할 수 있다. `apply-sequence="true"`를 사용하면 디폴트 `sequenceSize`가 제공되서 `aggregator`에서 그룹을 적당히 release할 수 있다. distribution 옵션과 auction 옵션을 함께 사용할 순 없다.

auction과 distribution 방식 모두, `aggregator`의 응답 메시지를 기다릴 수 있도록 요청 (scatter) 메시지에 `gatherResultChannel` 헤더를 추가한다.

기본적으로 모든 supplier는 `replyChannel` 헤더로 결과를 전송해야 한다 (보통은 최종 엔드포인트에서 `output-channel`을 생략하는 식으로). 하지만 `gatherChannel` 옵션도 제공하므로, supplier는 이 채널에 응답을 보내 집계할 수도 있다.

### 8.7.2. Configuring a Scatter-Gather Endpoint

다음은 `Scatter-Gather` 빈을 정의하는 자바 설정 예시다:

```java
@Bean
public MessageHandler distributor() {
    RecipientListRouter router = new RecipientListRouter();
    router.setApplySequence(true);
    router.setChannels(Arrays.asList(distributionChannel1(), distributionChannel2(),
            distributionChannel3()));
    return router;
}

@Bean
public MessageHandler gatherer() {
	return new AggregatingMessageHandler(
			new ExpressionEvaluatingMessageGroupProcessor("^[payload gt 5] ?: -1D"),
			new SimpleMessageStore(),
			new HeaderAttributeCorrelationStrategy(
			       IntegrationMessageHeaderAccessor.CORRELATION_ID),
			new ExpressionEvaluatingReleaseStrategy("size() == 2"));
}

@Bean
@ServiceActivator(inputChannel = "distributionChannel")
public MessageHandler scatterGatherDistribution() {
	ScatterGatherHandler handler = new ScatterGatherHandler(distributor(), gatherer());
	handler.setOutputChannel(output());
	return handler;
}
```

위 예시에선 `applySequence="true"`와 recipient 채널 리스트를 사용해 `RecipientListRouter` `distributor` 빈을 설정하고 있다. 다음 보이는 빈은 `AggregatingMessageHandler`다. 마지막으로 이 두 가지 빈을 `ScatterGatherHandler` 빈 정의에 주입하고 `@ServiceActivator`로 마킹해서, 이 scatter-gather 컴포넌트를 인티그레이션 플로우에 연결한다.

다음은 XML 네임스페이스를 이용해 `<scatter-gather>` 엔드포인트를 설정하는 예시다:

```xml
<scatter-gather
		id=""  <!-- (1) -->
		auto-startup=""  <!-- (2) -->
		input-channel=""  <!-- (3) -->
		output-channel=""  <!-- (4) -->
		scatter-channel=""  <!-- (5) -->
		gather-channel=""  <!-- (6) -->
		order=""  <!-- (7) -->
		phase=""  <!-- (8) -->
		send-timeout=""  <!-- (9) -->
		gather-timeout=""  <!-- (10) -->
		requires-reply="" > <!-- (11) -->
			<scatterer/>  <!-- (12) -->
			<gatherer/>  <!-- (13) -->
</scatter-gather>
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 이 엔드포인트의 ID.<br>`ScatterGatherHandler` 빈은 `id + '.handler'`라는 alias와 함께 등록된다.<br>`RecipientListRouter` 빈은 `id + '.scatterer'`라는 alias로 등록된다.<br>`AggregatingMessageHandler` 빈은 `id + '.gatherer'`라는 alias로 등록된다.<br>생략할 수 있다.<br>(`BeanFactory`가 디폴트 `id` 값을 생성해준다.)</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 애플리케이션 컨텍스트를 초기화할 때 이 엔드포인트를 시작해야 하는지를 나타내는 라이프사이클 속성.<br>참고로, `ScatterGatherHandler`는 `Lifecycle`도 구현하고 있으며, `gather-channel`을 제공하면 내부적으로 생성하는 `gatherEndpoint`를 시작하고 중지한다.<br>생략할 수 있다.<br>(디폴트는 `true`다.)</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> `ScatterGatherHandler`로 처리할 요청 메시지를 수신하는 채널.<br>필수 값이다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> `ScatterGatherHandler`가 집계 결과를 전송할 채널.<br>생략할 수 있다.<br>(전달받는 메시지 자체에서 `replyChannel` 헤더를 이용해 응답 채널을 지정할 수 있다.)</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> auction 시나리오에서 scatter 메시지를 전송할 채널.<br>생략할 수 있다.<br>하위 요소 `<scatterer>`와 함께 사용할 수 없다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(6)</span> 집계를 위해 각 supplier로부터 응답을 수신할 채널.<br>scatter 메시지의 `replyChannel` 헤더로 사용한다.<br>생략할 수 있다.<br>기본적으로 `FixedSubscriberChannel`이 만들어진다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(7)</span> 둘 이상의 핸들러가 같은 `DirectChannel`을 구독하는 경우를 위한 이 컴포넌트의 순서 (로드 밸런싱 용도).<br>생략할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(8)</span> 이 엔드포인트를 시작하고 중지해야 하는 phase를 지정한다.<br>시작은 제일 낮은 값에서부터 제일 높은 값 순서로 진행하며, 종료는 높은 값에서 낮은 값 순이다.<br>기본적으로 이 값은 `Integer.MAX_VALUE`로, 이 컨테이너는 가능한 한 늦게 시작하며, 중지는 가능한 한 빨리 진행한다.<br>생략할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(9)</span> 응답 `Message`를 `output-channel`로 전송할 때 대기하는 타임아웃 간격.<br>기본적으론 전송하는 1초 동안 블로킹한다.<br>고정 'capacity'를 사용하는 `QueueChannel`같이, '전송'에 제한이 있는 출력 채널을 사용할 때만 적용된다.<br>타이아웃이 발생하면 `MessageDeliveryException`을 던진다.<br>`AbstractSubscribableChannel`의 구현체들은 `send-timeout`을 무시한다.<br>`group-timeout(-expression)`의 경우 예약된 expire 태스크에서 `MessageDeliveryException`이 발생하면 해당 태스크를 다시 스케줄링한다.<br>생략할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(10)</span> scatter-gather가 응답 메시지를 반환하기 전 대기할 시간을 지정할 수 있다.<br>기본적으로 무한정 대기한다.<br>응답 시간을 초과하면 'null'을 반환한다.<br>생략할 수 있다.<br>기본값은 무기한 대기를 뜻하는 `-1`이다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(11)</span> scatter-gather가 반드시 null이 아닌 값을 반환해야 하는지 여부를 지정한다.<br>기본값은 `true`다.<br>따라서 내부 aggregator가 `gather-timeout`이 지나고 나서 null 값을 반환하면 `ReplyRequiredException`이 발생한다.<br>`null`을 반환할 수 있다면, `gather-timeout`을 지정해야 무한정 대기하지 않는다는 점에 주의하자.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(12)</span> `<recipient-list-router>` 옵션들.<br>생략할 수 있다.<br>`scatter-channel` 속성과는 함께 사용할 수 없다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(13)</span> `<aggregator>` 옵션들.<br>필수 값이다.</small>

### 8.7.3. Error Handling

Scatter-Gather는 여러 개의 request와 reply를 다루는 컴포넌트기 때문에 에러를 핸들링하기가 조금 더 복잡한 편이다. `ReleaseStrategy`에서 요청보다 응답이 적어도 처리를 종료하도록 만든다면, 경우에 따라서는 다운스트림에서 발생한 예외를 잡아 단순히 무시하는 게 더 좋을 수도 있다. 그렇지 않을 땐 에러가 발생하면 하위 플로우에서 "보상 메시지<sup>compensation message</sup>"같은 걸 반환하는 것을 고려해봐야 한다.

하위 플로우 중 비동기<sup>async</sup> 플로우가 있다면 전부 `errorChannel` 헤더를 설정해야 `MessagePublishingErrorHandler`가 적절한 에러 메시지를 전송할 수 있다. 그렇지 않으면 공통 에러 핸들링 로직을 통해 글로벌 `errorChannel`로 에러를 전송한다. 비동기 에러 처리에 대한 자세한 내용은 [에러 핸들링](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/error-handling.html#error-handling)을 참고해라.

동기<sup>Synchronous</sup> 플로우는 `ExpressionEvaluatingRequestHandlerAdvice`를 사용해 예외를 무시하거나 보상 메시지를 반환할 수 있다. 하위 플로우 중 하나가 `ScatterGatherHandler`로 예외를 던지면 업스트림으로 다시 던진다. 이처럼 다른 하위 플로우가 응답을 하더라도 `ScatterGatherHandler`에선 그 응답을 무시하게 된다. 원하는 동작일 수도 있지만, 대부분의 경우 다른 플로우와 gatherer 동작에 영향을 주지 않도록 하위 플로우에서 발생한 에러를 처리해주는 것이 좋다.

5.1.3 버전부터 `ScatterGatherHandler`는 `errorChannelName` 옵션과 함께 제공된다. 이 값은 scatter 메시지의 `errorChannel` 헤더에 채워지며, 비동기 에러가 발생할 때 사용하거나, 일반적인 동기식 하위 플로우에서 에러 메시지를 직접 전송할 때 사용할 수 있다.

다음은 보상 메시지를 반환해 에러를 비동기로 처리하는 예시다:

```java
@Bean
public IntegrationFlow scatterGatherAndExecutorChannelSubFlow(TaskExecutor taskExecutor) {
    return f -> f
            .scatterGather(
                    scatterer -> scatterer
                            .applySequence(true)
                            .recipientFlow(f1 -> f1.transform(p -> "Sub-flow#1"))
                            .recipientFlow(f2 -> f2
                                    .channel(c -> c.executor(taskExecutor))
                                    .transform(p -> {
                                        throw new RuntimeException("Sub-flow#2");
                                    })),
                    null,
                    s -> s.errorChannel("scatterGatherErrorChannel"));
}

@ServiceActivator(inputChannel = "scatterGatherErrorChannel")
public Message<?> processAsyncScatterError(MessagingException payload) {
    return MessageBuilder.withPayload(payload.getCause().getCause())
            .copyHeaders(payload.getFailedMessage().getHeaders())
            .build();
}
```

적절한 응답을 생성하려면, `MessagePublishingErrorHandler`가 `scatterGatherErrorChannel`로 전송한 `MessagingException`에서 `failedMessage`의 헤더를 복사해야 한다 (`replyChannel`, `errorChannel` 포함). 이렇게 하면 응답 메시지 그룹을 완료할 수 있도록 `ScatterGatherHandler` gatherer로 타겟 exception이 반환된다. 이런 exception `payload`는 gatherer의 `MessageGroupProcessor`에서 필터링하거나, scatter-gather 엔드포인트 이후 다운스트림에서 다른 식으로 처리할 수 있다.

> `ScatterGatherHandler`는 scatter 결과를 gatherer에게 보내기 전에 reply, error 채널을 포함한 (있다면) 요청 메시지 헤더를 복원한다. 이렇게 하면 하위 플로우(scatter 수신자<sup>recipient</sup>)와 비동기로 메시지를 주고 받더라도 호출자에게 `AggregatingMessageHandler`에서 발생한 에러가 전파된다. 제대로 동작하려면 반드시 하위 플로우(scatter 수신자<sup>recipient</sup>)가 보내는 응답으로 `gatherResultChannel`, `originalReplyChannel`, `originalErrorChannel` 헤더가 전달돼야 한다. 이땐 반드시 `ScatterGatherHandler`에 적당한 `gatherTimeout`을 설정해줘야 한다 (유한한 값으로). 그렇지 않으면 디폴트 동작에 따라 gatherer의 응답을 한없이 기다리며 블로킹된다.

---

## 8.8. Thread Barrier

간혹 다른 비동기 이벤트가 발생할 때까지 메시지 플로우 스레드를 잠시 중단해야 할 때가 있다. 예를 들어서 HTTP 요청을 통해 RabbitMQ에 메시지를 발행한다고 생각해보자. RabbitMQ 브로커가 메시지를 수신했다고 승인<sup>acknowledgment</sup>하기 전까진 사용자에게 응답을 전송하지 않길 바랄 수 있다.

Spring Integration은 4.2 버전에서 이런 용도로 사용할 수 있는 `<barrier/>` 컴포넌트를 도입했다. 내부에서 사용하는 `MessageHandler`는 `BarrierMessageHandler`다. 이 클래스는 `MessageTriggerAction`도 구현하고 있는데, 여기 있는 `trigger()` 메소드에 메시지가 전달되면 `handleRequestMessage()` 메소드에서 그에 맞는 스레드를 (있으면) 놓아준다<sup>release</sup>.

일시 중단 중인 스레드<sup>suspended thread</sup>와 트리거 스레드<sup>trigger thread</sup>는 메시지로 `CorrelationStrategy`를 호출해서 연계한다. `input-channel`로 메시지가 전달되면 이 스레드는 그에 상응하는 트리거 메시지를 기다리며 최대 `requestTimeout` 밀리세컨드 동안 일시 중단된다. 디폴트 correlation 전략은 `IntegrationMessageHeaderAccessor.CORRELATION_ID` 헤더를 사용한다. 동일한 correlation을 가진 트리거 메시지가 도착하면 이 스레드를 놓아준다<sup>release</sup>. 스레드를 해제하고 나서 `output-channel`로 전송하는 메시지는 `MessageGroupProcessor`를 사용해 구성한다. 이 메시지는 기본적으로 두 개의 페이로드를 가진 `Collection<?>`이며, 헤더는 `DefaultAggregatingMessageGroupProcessor`를 사용해 병합한다.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>스레드를 일시 중단하기도 전에 <code class="highlighter-rouge">trigger()</code> 메소드가 먼저 호출되면 (또는 메인 스레드에서 타임아웃 발생 이후 호출되면), 최대 <code class="highlighter-rouge">triggerTimeout</code> 동안 일시 중단을 유발했어야할 메시지가 도착하기를 기다린다. 트리거 스레드를 일시 중단하고 싶지 않다면, 대신 <code class="highlighter-rouge">TaskExecutor</code>에 전달해서 여기 있는 스레드가 일시 중단되도록 하는 것도 괜찮다.</p>
</blockquote>


> 5.4 버전 이전에는 요청 메시지와 트리거 메시지에 타임아웃을 지정할 땐 `timeout` 옵션 하나를 공유했었지만, 사용하기에 따라 각각에 타임아웃 값을 다르게 설정하는 게 더 좋은 경우가 있었다. 따라서 `requestTimeout`과 `triggerTimeout` 옵션을 새로 도입했다.

`requires-reply` 프로퍼티는 일시 중단 중인 스레드가 트리거 메시지 도착 전에 타임아웃된 경우 수행할 일을 결정한다. 기본값은 `false`로, 엔드포인트는 `null`을 리턴해 플로우를 종료하고, 스레드는 호출자로 반환된다. `true`일 땐 `ReplyRequiredException`이 발생한다.

`trigger()` 메소드는 코드에서 직접 호출할 수 있다 (`barrier.handler`라는 이름으로 빈 참조를 얻어서 — 이때 `barrier`는 barrier 엔드포인트의 빈 이름이다). 또는 `<outbound-channel-adapter/>`를 설정해서 release를 트리거해도 된다.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>하나의 correlation은 하나의 스레드만 중단할 수 있다. 같은 correlation을 여러 번 사용할 수는 있지만 동시에 사용하는 것은 안 된다. 같은 correlation으로 스레드가 두 번 도착하면 예외가 발생한다.</p>
</blockquote>

다음은 correlation에 커스텀 헤더를 사용하는 예시다:

<div class="switch-language-wrapper java xml">
<span class="switch-language java">Java</span>
<span class="switch-language xml">XML</span>
</div>
<div class="language-only-for-java java xml"></div>
```java
@ServiceActivator(inputChannel="in")
@Bean
public BarrierMessageHandler barrier(MessageChannel out, MessageChannel lateTriggerChannel) {
    BarrierMessageHandler barrier = new BarrierMessageHandler(10000);
    barrier.setOutputChannel(out());
    barrier.setDiscardChannel(lateTriggerChannel);
    return barrier;
}

@ServiceActivator (inputChannel="release")
@Bean
public MessageHandler releaser(MessageTriggerAction barrier) {
    return barrier::trigger(message);
}
```
<div class="language-only-for-xml java xml"></div>
```xml
<int:barrier id="barrier1" input-channel="in" output-channel="out"
        correlation-strategy-expression="headers['myHeader']"
        output-processor="myOutputProcessor"
        discard-channel="lateTriggerChannel"
        timeout="10000">
</int:barrier>

<int:outbound-channel-adapter channel="release" ref="barrier1.handler" method="trigger" />
```

어느 쪽에 먼저 메시지가 도착했는지에 따라 `in`에 메시지를 전송하는 스레드 혹은 `release`에 메시지를 전송하는 스레드가 상대 메시지가 도착할 때까지 최대 10초 동안 대기하게 된다. 메시지가 release되면 `myOutputProcessor`라는 커스텀 `MessageGroupProcessor` 빈을 실행해 합친 메시지를 `out` 채널로 전송한다. 메인 스레드가 타임아웃되고 나서 트리거가 도착하면, 뒤늦게 도착한 트리거를 전송할 discard 채널을 설정할 수 있다.

이 컴포넌트를 사용하는 예제가 궁금하다면, [barrier 샘플 애플리케이션](https://github.com/spring-projects/spring-integration-samples/tree/main/basic/barrier)을 확인해봐라.