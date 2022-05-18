---
title: Message Routing
category: Spring Integration
order: 13
permalink: /Spring%20Integration/messaging-routing/
description: todo
image: ./../../images/springintegration/logo.png
lastmod: 2022-01-05T21:30:00+09:00
comments: true
originalRefName: 스프링 인티그레이션
originalRefLink: https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/index-single.html#messaging-routing-chapter
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

`PayloadTypeRouter` 설정은 Spring Integration에서 제공하는 네임스페이스로도 가능하다 ([`Namespace Support`](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/configuration.html#configuration-namespace) 참고). Spring Integration의 네임스페이스를 이용하면 사실상 `<router/>` 설정과 그 구현체(`<bean/>` 요소로 정의한)를 하나의 설정으로 만들 수 있어 더 간단해진다. 다음 예제는 위와 동일한 설정이지만, 네임스페이스 지원을 이용한 `PayloadTypeRouter` 설정을 보여준다:

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

Spring Integration은 아래 예제에서 볼 수 있는 `RecipientListRouter` 설정을 위한 네임스페이스도 지원하고 있다 ([네임스페이스 지원](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/configuration.html#configuration-namespace) 참고):

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

4.1 버전부터 `RecipientListRouter`는 런타임에 동적으로 수신자<sup>recipient</sup>를 조작할 수 있는 여러 가지 동작들을 제공한다. 이런 관리성<sup>management</sup> 연산은 `RecipientListRouterManagement`를 통해 제공되며, `@ManagedResource` 어노테이션을 이용한다. 다음 예제와 같이 [컨트롤 버스](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/index-single.html#control-bus)를 이용할 수도 있고, JMX를 이용하는 방법도 있다:

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

XPath 라우터는 XML 모듈에 들어있다. [XPath를 이용해 XML 메시지 라우팅하기](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/xml.html#xml-xpath-routing)를 참고해라.

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

특정 커스텀 라우터 구현체를 다른 `<router>` 정의에서도 참조하고 있다면 보통 `ref` 속성을 사용하는 것이 좋다. 하지만 커스텀 라우터 구현체의 스코프를 하나의 `<router>` 정의 내로 한정하고 싶다면, 아래 예제와 같이 내부 빈 정의를 제공해도 된다:

```xml
<int:router method="someMethod" input-channel="input3"
            default-output-channel="defaultOutput3">
    <beans:bean class="org.foo.MyCustomRouter"/>
</int:router>
```

> 동일한 `<router>` 설정에서 `ref` 속성과 내부 핸들러 정의를 둘 다 사용하는 것은 허용하지 않는다. 둘 다 사용하면 모호한 조건이 만들어져 예외가 발생한다.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p><code class="highlighter-rouge">ref</code>
 속성으로 <code class="highlighter-rouge">AbstractMessageProducingHandler</code>를 상속한 빈을 참조하는 경우 (프레임워크에서 자체적으로 제공하는 라우터들처럼), 이 설정은 라우터를 직접 참조하도록 최적화된다. 이때는 각 <code class="highlighter-rouge">ref</code> 속성마다 별도 빈 인스턴스(또는 <code class="highlighter-rouge">prototype</code> 스코프 빈)를 참조하거나, 내부 <code class="highlighter-rouge">&lt;bean/&gt;</code> 설정 타입을 사용해야 한다. 단, 여기서 말하는 최적화는 라우터 XML 정의에 특정 라우터 전용 속성을 제공하지 않았을 때에만 적용된다. 무심코 여러 빈에서 동일한 메시지 핸들러를 참조한다면 설정 예외를 만나게될 거다.</p>
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

Sometimes, the routing logic may be simple, and writing a separate class for it and configuring it as a bean may seem like overkill. As of Spring Integration 2.0, we offer an alternative that lets you use SpEL to implement simple computations that previously required a custom POJO router.

> For more information about the Spring Expression Language, see the [relevant chapter in the Spring Framework Reference Guide](https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#expressions).

Generally, a SpEL expression is evaluated and its result is mapped to a channel, as the following example shows:

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

The following example shows the equivalent router configured in the Java DSL:

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

To simplify things even more, the SpEL expression may evaluate to a channel name, as the following expression shows:

```xml
<int:router input-channel="inChannel" expression="payload + 'Channel'"/>
```

In the preceding configuration, the result channel is computed by the SpEL expression, which concatenates the value of the `payload` with the literal `String`, 'Channel'.

Another virtue of SpEL for configuring routers is that an expression can return a `Collection`, effectively making every `<router>` a recipient list router. Whenever the expression returns multiple channel values, the message is forwarded to each channel. The following example shows such an expression:

```xml
<int:router input-channel="inChannel" expression="headers.channels"/>
```

In the above configuration, if the message includes a header with a name of 'channels' and the value of that header is a `List` of channel names, the message is sent to each channel in the list. You may also find collection projection and collection selection expressions useful when you need to select multiple channels. For further information, see:

- [Collection Projection](https://docs.spring.io/spring-framework/docs/current/spring-framework-reference/core.html#expressions-collection-projection)
- [Collection Selection](https://docs.spring.io/spring-framework/docs/current/spring-framework-reference/core.html#expressions-collection-selection)

#### Configuring a Router with Annotations

When using `@Router` to annotate a method, the method may return either a `MessageChannel` or a `String` type. In the latter case, the endpoint resolves the channel name as it does for the default output channel. Additionally, the method may return either a single value or a collection. If a collection is returned, the reply message is sent to multiple channels. To summarize, the following method signatures are all valid:

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

In addition to payload-based routing, a message may be routed based on metadata available within the message header as either a property or an attribute. In this case, a method annotated with `@Router` may include a parameter annotated with `@Header`, which is mapped to a header value as the following example shows and documented in [Annotation Support](https://docs.spring.io/spring-integration/docs/5.5.9/reference/html/configuration.html#annotations):

```java
@Router
public List<String> route(@Header("orderStatus") OrderStatus status)
```

> For routing of XML-based Messages, including XPath support, see [XML Support - Dealing with XML Payloads](https://docs.spring.io/spring-integration/docs/5.5.9/reference/html/xml.html#xml).

See also [Message Routers](https://docs.spring.io/spring-integration/docs/5.5.9/reference/html/dsl.html#java-dsl-routers) in the Java DSL chapter for more information about router configuration.

### 8.1.6. Dynamic Routers

Spring Integration provides quite a few different router configurations for common content-based routing use cases as well as the option of implementing custom routers as POJOs. For example, `PayloadTypeRouter` provides a simple way to configure a router that computes channels based on the payload type of the incoming message while `HeaderValueRouter` provides the same convenience in configuring a router that computes channels by evaluating the value of a particular message Header. There are also expression-based (SpEL) routers, in which the channel is determined based on evaluating an expression. All of these type of routers exhibit some dynamic characteristics.

However, these routers all require static configuration. Even in the case of expression-based routers, the expression itself is defined as part of the router configuration, which means that the same expression operating on the same value always results in the computation of the same channel. This is acceptable in most cases, since such routes are well defined and therefore predictable. But there are times when we need to change router configurations dynamically so that message flows may be routed to a different channel.

For example, you might want to bring down some part of your system for maintenance and temporarily re-reroute messages to a different message flow. As another example, you may want to introduce more granularity to your message flow by adding another route to handle a more concrete type of `java.lang.Number` (in the case of `PayloadTypeRouter`).

Unfortunately, with static router configuration to accomplish either of those goals, you would have to bring down your entire application, change the configuration of the router (change routes), and bring the application back up. This is obviously not a solution anyone wants.

The [dynamic router](https://www.enterpriseintegrationpatterns.com/DynamicRouter.html) pattern describes the mechanisms by which you can change or configure routers dynamically without bringing down the system or individual routers.

Before we get into the specifics of how Spring Integration supports dynamic routing, we need to consider the typical flow of a router:

1. Compute a channel identifier, which is a value calculated by the router once it receives the message. Typically, it is a String or an instance of the actual `MessageChannel`.
2. Resolve the channel identifier to a channel name. We describe specifics of this process later in this section.
3. Resolve the channel name to the actual `MessageChannel`

There is not much that can be done with regard to dynamic routing if Step 1 results in the actual instance of the `MessageChannel`, because the `MessageChannel` is the final product of any router’s job. However, if the first step results in a channel identifier that is not an instance of `MessageChannel`, you have quite a few possible ways to influence the process of deriving the `MessageChannel`. Consider the following example of a payload type router:

```xml
<int:payload-type-router input-channel="routingChannel">
    <int:mapping type="java.lang.String"  channel="channel1" />
    <int:mapping type="java.lang.Integer" channel="channel2" />
</int:payload-type-router>
```

Within the context of a payload type router, the three steps mentioned earlier would be realized as follows:

1. Compute a channel identifier that is the fully qualified name of the payload type (for example, `java.lang.String`).
2. Resolve the channel identifier to a channel name, where the result of the previous step is used to select the appropriate value from the payload type mapping defined in the `mapping` element.
3. Resolve the channel name to the actual instance of the `MessageChannel` as a reference to a bean within the application context (which is hopefully a `MessageChannel`) identified by the result of the previous step.

In other words, each step feeds the next step until the process completes.

Now consider an example of a header value router:

```xml
<int:header-value-router input-channel="inputChannel" header-name="testHeader">
    <int:mapping value="foo" channel="fooChannel" />
    <int:mapping value="bar" channel="barChannel" />
</int:header-value-router>
```

Now we can consider how the three steps work for a header value router:

1. Compute a channel identifier that is the value of the header identified by the `header-name` attribute.
2. Resolve the channel identifier a to channel name, where the result of the previous step is used to select the appropriate value from the general mapping defined in the `mapping` element.
3. Resolve the channel name to the actual instance of the `MessageChannel` as a reference to a bean within the application context (which is hopefully a `MessageChannel`) identified by the result of the previous step.

The preceding two configurations of two different router types look almost identical. However, if you look at the alternate configuration of the `HeaderValueRouter` we clearly see that there is no `mapping` sub element, as the following listing shows:

```xml
<int:header-value-router input-channel="inputChannel" header-name="testHeader">
```

However, the configuration is still perfectly valid. So the natural question is what about the mapping in the second step?

The second step is now optional. If `mapping` is not defined, then the channel identifier value computed in the first step is automatically treated as the `channel name`, which is now resolved to the actual `MessageChannel`, as in the third step. What it also means is that the second step is one of the key steps to providing dynamic characteristics to the routers, since it introduces a process that lets you change the way channel identifier resolves to the channel name, thus influencing the process of determining the final instance of the `MessageChannel` from the initial channel identifier.

For example, in the preceding configuration, assume that the `testHeader` value is 'kermit', which is now a channel identifier (the first step). Since there is no mapping in this router, resolving this channel identifier to a channel name (the second step) is impossible and this channel identifier is now treated as the channel name. However, what if there was a mapping but for a different value? The end result would still be the same, because, if a new value cannot be determined through the process of resolving the channel identifier to a channel name, the channel identifier becomes the channel name.

All that is left is for the third step to resolve the channel name ('kermit') to an actual instance of the `MessageChannel` identified by this name. That basically involves a bean lookup for the provided name. Now all messages that contain the header-value pair as `testHeader=kermit` are going to be routed to a `MessageChannel` whose bean name (its `id`) is 'kermit'.

But what if you want to route these messages to the 'simpson' channel? Obviously changing a static configuration works, but doing so also requires bringing your system down. However, if you had access to the channel identifier map, you could introduce a new mapping where the header-value pair is now `kermit=simpson`, thus letting the second step treat 'kermit' as a channel identifier while resolving it to 'simpson' as the channel name.

The same obviously applies for `PayloadTypeRouter`, where you can now remap or remove a particular payload type mapping. In fact, it applies to every other router, including expression-based routers, since their computed values now have a chance to go through the second step to be resolved to the actual `channel name`.

Any router that is a subclass of the `AbstractMappingMessageRouter` (which includes most framework-defined routers) is a dynamic router, because the `channelMapping` is defined at the `AbstractMappingMessageRouter` level. That map’s setter method is exposed as a public method along with the 'setChannelMapping' and 'removeChannelMapping' methods. These let you change, add, and remove router mappings at runtime, as long as you have a reference to the router itself. It also means that you could expose these same configuration options through JMX (see [JMX Support](https://docs.spring.io/spring-integration/docs/5.5.9/reference/html/jmx.html#jmx)) or the Spring Integration control bus (see [Control Bus](https://docs.spring.io/spring-integration/docs/5.5.9/reference/html/control-bus.html#control-bus)) functionality.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>Falling back to the channel key as the channel name is flexible and convenient. However, if you don’t trust the message creator, a malicious actor (who has knowledge of the system) could create a message that is routed to an unexpected channel. For example, if the key is set to the channel name of the router’s input channel, such a message would be routed back to the router, eventually resulting in a stack overflow error. You may therefore wish to disable this feature (set the <code class="highlighter-rouge">channelKeyFallback</code> property to <code class="highlighter-rouge">false</code>), and change the mappings instead if needed.</p>
</blockquote>

#### Manage Router Mappings using the Control Bus

One way to manage the router mappings is through the [control bus](https://www.enterpriseintegrationpatterns.com/ControlBus.html) pattern, which exposes a control channel to which you can send control messages to manage and monitor Spring Integration components, including routers.

> For more information about the control bus, see [Control Bus](https://docs.spring.io/spring-integration/docs/5.5.9/reference/html/control-bus.html#control-bus).

Typically, you would send a control message asking to invoke a particular operation on a particular managed component (such as a router). The following managed operations (methods) are specific to changing the router resolution process:

- `public void setChannelMapping(String key, String channelName)`: Lets you add a new or modify an existing mapping between `channel identifier` and `channel name`
- `public void removeChannelMapping(String key)`: Lets you remove a particular channel mapping, thus disconnecting the relationship between `channel identifier` and `channel name`

Note that these methods can be used for simple changes (such as updating a single route or adding or removing a route). However, if you want to remove one route and add another, the updates are not atomic. This means that the routing table may be in an indeterminate state between the updates. Starting with version 4.0, you can now use the control bus to update the entire routing table atomically. The following methods let you do so:

- `public Map<String, String>getChannelMappings()`: Returns the current mappings.
- `public void replaceChannelMappings(Properties channelMappings)`: Updates the mappings. Note that the `channelMappings` parameter is a `Properties` object. This arrangement lets a control bus command use the built-in `StringToPropertiesConverter`, as the following example shows:

```none
"@'router.handler'.replaceChannelMappings('foo=qux \n baz=bar')"
```

Note that each mapping is separated by a newline character (`\n`). For programmatic changes to the map, we recommend that you use the `setChannelMappings` method, due to type-safety concerns. `replaceChannelMappings` ignores keys or values that are not `String` objects.

#### Manage Router Mappings by Using JMX

You can also use Spring’s JMX support to expose a router instance and then use your favorite JMX client (for example, JConsole) to manage those operations (methods) for changing the router’s configuration.

> For more information about Spring Integration’s JMX support, see [JMX Support](https://docs.spring.io/spring-integration/docs/5.5.9/reference/html/jmx.html#jmx).

#### Routing Slip

Starting with version 4.1, Spring Integration provides an implementation of the [routing slip](https://www.enterpriseintegrationpatterns.com/RoutingTable.html) enterprise integration pattern. It is implemented as a `routingSlip` message header, which is used to determine the next channel in `AbstractMessageProducingHandler` instances, when an `outputChannel` is not specified for the endpoint. This pattern is useful in complex, dynamic cases, when it can become difficult to configure multiple routers to determine message flow. When a message arrives at an endpoint that has no `output-channel`, the `routingSlip` is consulted to determine the next channel to which the message is sent. When the routing slip is exhausted, normal `replyChannel` processing resumes.

Configuration for the routing slip is presented as a `HeaderEnricher` option — a semicolon-separated routing slip that contains `path` entries, as the following example shows:

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

The preceding example has:

- A `<context:property-placeholder>` configuration to demonstrate that the entries in the routing slip `path` can be specified as resolvable keys.
- The `<header-enricher>` `<routing-slip>` sub-element is used to populate the `RoutingSlipHeaderValueMessageProcessor` to the `HeaderEnricher` handler.
- The `RoutingSlipHeaderValueMessageProcessor` accepts a `String` array of resolved routing slip `path` entries and returns (from `processMessage()`) a `singletonMap` with the `path` as `key` and `0` as initial `routingSlipIndex`.

Routing Slip `path` entries can contain `MessageChannel` bean names, `RoutingSlipRouteStrategy` bean names, and Spring expressions (SpEL). The `RoutingSlipHeaderValueMessageProcessor` checks each routing slip `path` entry against the `BeanFactory` on the first `processMessage` invocation. It converts entries (which are not bean names in the application context) to `ExpressionEvaluatingRoutingSlipRouteStrategy` instances. `RoutingSlipRouteStrategy` entries are invoked multiple times, until they return null or an empty `String`.

Since the routing slip is involved in the `getOutputChannel` process, we have a request-reply context. The `RoutingSlipRouteStrategy` has been introduced to determine the next `outputChannel` that uses the `requestMessage` and the `reply` object. An implementation of this strategy should be registered as a bean in the application context, and its bean name is used in the routing slip `path`. The `ExpressionEvaluatingRoutingSlipRouteStrategy` implementation is provided. It accepts a SpEL expression and an internal `ExpressionEvaluatingRoutingSlipRouteStrategy.RequestAndReply` object is used as the root object of the evaluation context. This is to avoid the overhead of `EvaluationContext` creation for each `ExpressionEvaluatingRoutingSlipRouteStrategy.getNextPath()` invocation. It is a simple Java bean with two properties: `Message<?> request` and `Object reply`. With this expression implementation, we can specify routing slip `path` entries by using SpEL (for example, `@routingSlipRoutingPojo.get(request, reply)` and `request.headers[myRoutingSlipChannel]`) and avoid defining a bean for the `RoutingSlipRouteStrategy`.

> The `requestMessage` argument is always a `Message<?>`. Depending on context, the reply object may be a `Message<?>`, an `AbstractIntegrationMessageBuilder`, or an arbitrary application domain object (when, for example, it is returned by a POJO method invoked by a service activator). In the first two cases, the usual `Message` properties (`payload` and `headers`) are available when using SpEL (or a Java implementation). For an arbitrary domain object, these properties are not available. For this reason, be careful when you use routing slips in conjunction with POJO methods if the result is used to determine the next path.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>If a routing slip is involved in a distributed environment, we recommend not using inline expressions for the Routing Slip <code class="highlighter-rouge">path</code>. This recommendation applies to distributed environments such as cross-JVM applications, using a <code class="highlighter-rouge">request-reply</code> through a message broker (such as<a href="https://docs.spring.io/spring-integration/docs/5.5.9/reference/html/amqp.html#amqp">AMQP Support</a> or <a href="https://docs.spring.io/spring-integration/docs/5.5.9/reference/html/jms.html#jms">JMS Support</a>), or using a persistent <code class="highlighter-rouge">MessageStore</code> (<a href="https://docs.spring.io/spring-integration/docs/5.5.9/reference/html/message-store.html#message-store">Message Store</a>) in the integration flow. The framework uses <code class="highlighter-rouge">RoutingSlipHeaderValueMessageProcessor</code> to convert them to <code class="highlighter-rouge">ExpressionEvaluatingRoutingSlipRouteStrategy</code> objects, and they are used in the <code class="highlighter-rouge">routingSlip</code> message header. Since this class is not <code class="highlighter-rouge">Serializable</code> (it cannot be, because it depends on the <code class="highlighter-rouge">BeanFactory</code>), the entire <code class="highlighter-rouge">Message</code> becomes non-serializable and, in any distributed operation, we end up with a <code class="highlighter-rouge">NotSerializableException</code>. To overcome this limitation, register an <code class="highlighter-rouge">ExpressionEvaluatingRoutingSlipRouteStrategy</code> bean with the desired SpEL and use its bean name in the routing slip <code class="highlighter-rouge">path</code> configuration.</p>
</blockquote>

For Java configuration, you can add a `RoutingSlipHeaderValueMessageProcessor` instance to the `HeaderEnricher` bean definition, as the following example shows:

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

The routing slip algorithm works as follows when an endpoint produces a reply and no `outputChannel` has been defined:

- The `routingSlipIndex` is used to get a value from the routing slip `path` list.
- If the value from `routingSlipIndex` is `String`, it is used to get a bean from `BeanFactory`.
- If a returned bean is an instance of `MessageChannel`, it is used as the next `outputChannel` and the `routingSlipIndex` is incremented in the reply message header (the routing slip `path` entries remain unchanged).
- If a returned bean is an instance of `RoutingSlipRouteStrategy` and its `getNextPath` does not return an empty `String`, that result is used as a bean name for the next `outputChannel`. The `routingSlipIndex` remains unchanged.
- If `RoutingSlipRouteStrategy.getNextPath` returns an empty `String` or `null`, the `routingSlipIndex` is incremented and the `getOutputChannelFromRoutingSlip` is invoked recursively for the next Routing Slip `path` item.
- If the next routing slip `path` entry is not a `String`, it must be an instance of `RoutingSlipRouteStrategy`.
- When the `routingSlipIndex` exceeds the size of the routing slip `path` list, the algorithm moves to the default behavior for the standard `replyChannel` header.

### 8.1.7. Process Manager Enterprise Integration Pattern

Enterprise integration patterns include the [process manager](https://www.enterpriseintegrationpatterns.com/ProcessManager.html) pattern. You can now easily implement this pattern by using custom process manager logic encapsulated in a `RoutingSlipRouteStrategy` within the routing slip. In addition to a bean name, the `RoutingSlipRouteStrategy` can return any `MessageChannel` object, and there is no requirement that this `MessageChannel` instance be a bean in the application context. This way, we can provide powerful dynamic routing logic when there is no way to predict which channel should be used. A `MessageChannel` can be created within the `RoutingSlipRouteStrategy` and returned. A `FixedSubscriberChannel` with an associated `MessageHandler` implementation is a good combination for such cases. For example, you can route to a [Reactive Streams](https://projectreactor.io/docs/core/release/reference/#getting-started), as the following example shows:

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

Message filters are used to decide whether a `Message` should be passed along or dropped based on some criteria, such as a message header value or message content itself. Therefore, a message filter is similar to a router, except that, for each message received from the filter’s input channel, that same message may or may not be sent to the filter’s output channel. Unlike the router, it makes no decision regarding which message channel to send the message to but decides only whether to send the message at all.

> As we describe later in this section, the filter also supports a discard channel. In certain cases, it can play the role of a very simple router (or “switch”), based on a boolean condition.

In Spring Integration, you can configure a message filter as a message endpoint that delegates to an implementation of the `MessageSelector` interface. That interface is itself quite simple, as the following listing shows:

```java
public interface MessageSelector {

    boolean accept(Message<?> message);

}
```

The `MessageFilter` constructor accepts a selector instance, as the following example shows:

```java
MessageFilter filter = new MessageFilter(someSelector);
```

In combination with the namespace and SpEL, you can configure powerful filters with very little Java code.

### 8.2.1. Configuring a Filter with XML

You can use the `<filter>` element is used to create a message-selecting endpoint. In addition to `input-channel` and `output-channel` attributes, it requires a `ref` attribute. The `ref` can point to a `MessageSelector` implementation, as the following example shows:

```xml
<int:filter input-channel="input" ref="selector" output-channel="output"/>

<bean id="selector" class="example.MessageSelectorImpl"/>
```

Alternatively, you can add the `method` attribute. In that case, the `ref` attribute may refer to any object. The referenced method may expect either the `Message` type or the payload type of inbound messages. The method must return a boolean value. If the method returns 'true', the message is sent to the output channel. The following example shows how to configure a filter that uses the `method` attribute:

```xml
<int:filter input-channel="input" output-channel="output"
    ref="exampleObject" method="someBooleanReturningMethod"/>

<bean id="exampleObject" class="example.SomeObject"/>
```

If the selector or adapted POJO method returns `false`, a few settings control the handling of the rejected message. By default (if configured as in the preceding example), rejected messages are silently dropped. If rejection should instead result in an error condition, set the `throw-exception-on-rejection` attribute to `true`, as the following example shows:

```xml
<int:filter input-channel="input" ref="selector"
    output-channel="output" throw-exception-on-rejection="true"/>
```

If you want rejected messages to be routed to a specific channel, provide that reference as the `discard-channel`, as the following example shows:

```xml
<int:filter input-channel="input" ref="selector"
    output-channel="output" discard-channel="rejectedMessages"/>
```

See also [Advising Filters](https://docs.spring.io/spring-integration/docs/5.5.9/reference/html/handler-advice.html#advising-filters).

> Message filters are commonly used in conjunction with a publish-subscribe channel. Many filter endpoints may be subscribed to the same channel, and they decide whether to pass the message to the next endpoint, which could be any of the supported types (such as a service activator). This provides a reactive alternative to the more proactive approach of using a message router with a single point-to-point input channel and multiple output channels.

We recommend using a `ref` attribute if the custom filter implementation is referenced in other `<filter>` definitions. However, if the custom filter implementation is scoped to a single `<filter>` element, you should provide an inner bean definition, as the following example shows:

```xml
<int:filter method="someMethod" input-channel="inChannel" output-channel="outChannel">
  <beans:bean class="org.foo.MyCustomFilter"/>
</filter>
```

> Using both the `ref` attribute and an inner handler definition in the same `<filter>` configuration is not allowed, as it creates an ambiguous condition and throws an exception.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>If the <code class="highlighter-rouge">ref</code> attribute references a bean that extends <code class="highlighter-rouge">MessageFilter</code> (such as filters provided by the framework itself), the configuration is optimized by injecting the output channel into the filter bean directly. In this case, each <code class="highlighter-rouge">ref</code> must be to a separate bean instance (or a <code class="highlighter-rouge">prototype</code>-scoped bean) or use the inner <code class="highlighter-rouge">&lt;bean/&gt;</code> configuration type. However, this optimization applies only if you do not provide any filter-specific attributes in the filter XML definition. If you inadvertently reference the same message handler from multiple beans, you get a configuration exception.</p>
</blockquote>

With the introduction of SpEL support, Spring Integration added the `expression` attribute to the filter element. It can be used to avoid Java entirely for simple filters, as the following example shows:

```xml
<int:filter input-channel="input" expression="payload.equals('nonsense')"/>
```

The string passed as the value of the expression attribute is evaluated as a SpEL expression with the message available in the evaluation context. If you must include the result of an expression in the scope of the application context, you can use the `#{}` notation, as defined in the [SpEL reference documentation](https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#expressions-beandef), as the following example shows:

```xml
<int:filter input-channel="input"
            expression="payload.matches(#{filterPatterns.nonsensePattern})"/>
```

If the expression itself needs to be dynamic, you can use an 'expression' sub-element. That provides a level of indirection for resolving the expression by its key from an `ExpressionSource`. That is a strategy interface that you can implement directly, or you can rely upon a version available in Spring Integration that loads expressions from a “resource bundle” and can check for modifications after a given number of seconds. All of this is demonstrated in the following configuration example, where the expression could be reloaded within one minute if the underlying file had been modified:

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

If the `ExpressionSource` bean is named `expressionSource`, you need not provide the` source` attribute on the `<expression>` element. However, in the preceding example, we show it for completeness.

The 'config/integration/expressions.properties' file (or any more-specific version with a locale extension to be resolved in the typical way that resource-bundles are loaded) can contain a key/value pair, as the following example shows:

```none
filterPatterns.example=payload > 100
```

> All of these examples that use `expression` as an attribute or sub-element can also be applied within transformer, router, splitter, service-activator, and header-enricher elements. The semantics and role of the given component type would affect the interpretation of the evaluation result, in the same way that the return value of a method-invocation would be interpreted. For example, an expression can return strings that are to be treated as message channel names by a router component. However, the underlying functionality of evaluating the expression against the message as the root object and resolving bean names if prefixed with '@' is consistent across all of the core EIP components within Spring Integration.

### 8.2.2. Configuring a Filter with Annotations

The following example shows how to configure a filter by using annotations:

```java
public class PetFilter {
    ...
    @Filter  // (1)
    public boolean dogsOnly(String input) {
        ...
    }
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> An annotation indicating that this method is to be used as a filter. It must be specified if this class is to be used as a filter.</small>

All of the configuration options provided by the XML element are also available for the `@Filter` annotation.

The filter can be either referenced explicitly from XML or, if the `@MessageEndpoint` annotation is defined on the class, detected automatically through classpath scanning.

See also [Advising Endpoints Using Annotations](https://docs.spring.io/spring-integration/docs/5.5.9/reference/html/handler-advice.html#advising-with-annotations).

---

## 8.3. Splitter

The splitter is a component whose role is to partition a message into several parts and send the resulting messages to be processed independently. Very often, they are upstream producers in a pipeline that includes an aggregator.

### 8.3.1. Programming Model

The API for performing splitting consists of one base class, `AbstractMessageSplitter`. It is a `MessageHandler` implementation that encapsulates features common to splitters, such as filling in the appropriate message headers (`CORRELATION_ID`, `SEQUENCE_SIZE`, and `SEQUENCE_NUMBER`) on the messages that are produced. This filling enables tracking down the messages and the results of their processing (in a typical scenario, these headers get copied to the messages that are produced by the various transforming endpoints). The values can then be used, for example, by a [composed message processor](https://www.enterpriseintegrationpatterns.com/DistributionAggregate.html).

The following example shows an excerpt from `AbstractMessageSplitter`:

```java
public abstract class AbstractMessageSplitter
    extends AbstractReplyProducingMessageConsumer {
    ...
    protected abstract Object splitMessage(Message<?> message);

}
```

To implement a specific splitter in an application, you can extend `AbstractMessageSplitter` and implement the `splitMessage` method, which contains logic for splitting the messages. The return value can be one of the following:

- A `Collection` or an array of messages or an `Iterable` (or `Iterator`) that iterates over messages. In this case, the messages are sent as messages (after the `CORRELATION_ID`, `SEQUENCE_SIZE` and `SEQUENCE_NUMBER` are populated). Using this approach gives you more control — for example, to populate custom message headers as part of the splitting process.
- A `Collection` or an array of non-message objects or an `Iterable` (or `Iterator`) that iterates over non-message objects. It works like the prior case, except that each collection element is used as a message payload. Using this approach lets you focus on the domain objects without having to consider the messaging system and produces code that is easier to test.
- a `Message` or non-message object (but not a collection or an array). It works like the previous cases, except that a single message is sent out.

In Spring Integration, any POJO can implement the splitting algorithm, provided that it defines a method that accepts a single argument and has a return value. In this case, the return value of the method is interpreted as described earlier. The input argument might either be a `Message` or a simple POJO. In the latter case, the splitter receives the payload of the incoming message. We recommend this approach, because it decouples the code from the Spring Integration API and is typically easier to test.

#### Iterators

Starting with version 4.1, the `AbstractMessageSplitter` supports the `Iterator` type for the `value` to split. Note, in the case of an `Iterator` (or `Iterable`), we don’t have access to the number of underlying items and the `SEQUENCE_SIZE` header is set to `0`. This means that the default `SequenceSizeReleaseStrategy` of an `<aggregator>` won’t work and the group for the `CORRELATION_ID` from the `splitter` won’t be released; it will remain as `incomplete`. In this case you should use an appropriate custom `ReleaseStrategy` or rely on `send-partial-result-on-expiry` together with `group-timeout` or a `MessageGroupStoreReaper`.

Starting with version 5.0, the `AbstractMessageSplitter` provides `protected obtainSizeIfPossible()` methods to allow the determination of the size of the `Iterable` and `Iterator` objects if that is possible. For example `XPathMessageSplitter` can determine the size of the underlying `NodeList` object. And starting with version 5.0.9, this method also properly returns a size of the `com.fasterxml.jackson.core.TreeNode`.

An `Iterator` object is useful to avoid the need for building an entire collection in the memory before splitting. For example, when underlying items are populated from some external system (e.g. DataBase or FTP `MGET`) using iterations or streams.

#### Stream and Flux

Starting with version 5.0, the `AbstractMessageSplitter` supports the Java `Stream` and Reactive Streams `Publisher` types for the `value` to split. In this case, the target `Iterator` is built on their iteration functionality.

In addition, if the splitter’s output channel is an instance of a `ReactiveStreamsSubscribableChannel`, the `AbstractMessageSplitter` produces a `Flux` result instead of an `Iterator`, and the output channel is subscribed to this `Flux` for back-pressure-based splitting on downstream flow demand.

Starting with version 5.2, the splitter supports a `discardChannel` option for sending those request messages for which a split function has returned an empty container (collection, array, stream, `Flux` etc.). In this case there is just no item to iterate for sending to the `outputChannel`. The `null` splitting result remains as an end of flow indicator.

### 8.3.2. Configuring a Splitter with XML

A splitter can be configured through XML as follows:

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
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> The ID of the splitter is optional.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> A reference to a bean defined in the application context. The bean must implement the splitting logic, as described in the earlier section. Optional. If a reference to a bean is not provided, it is assumed that the payload of the message that arrived on the `input-channel` is an implementation of `java.util.Collection` and the default splitting logic is applied to the collection, incorporating each individual element into a message and sending it to the `output-channel`.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> The method (defined on the bean) that implements the splitting logic. Optional.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> The input channel of the splitter. Required.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> The channel to which the splitter sends the results of splitting the incoming message. Optional (because incoming messages can specify a reply channel themselves).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(6)</span> The channel to which the request message is sent in case of empty splitting result. Optional (they will stop as in case of `null` result).</small>

We recommend using a `ref` attribute if the custom splitter implementation can be referenced in other `<splitter>` definitions. However if the custom splitter handler implementation should be scoped to a single definition of the `<splitter>`, you can configure an inner bean definition, as the following example follows:

```xml
<int:splitter id="testSplitter" input-channel="inChannel" method="split"
                output-channel="outChannel">
  <beans:bean class="org.foo.TestSplitter"/>
</int:splitter>
```

> Using both a `ref` attribute and an inner handler definition in the same `<int:splitter>` configuration is not allowed, as it creates an ambiguous condition and results in an exception being thrown.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>If the <code class="highlighter-rouge">ref</code> attribute references a bean that extends <code class="highlighter-rouge">AbstractMessageProducingHandler</code> (such as splitters provided by the framework itself), the configuration is optimized by injecting the output channel into the handler directly. In this case, each <code class="highlighter-rouge">ref</code> must be a separate bean instance (or a <code class="highlighter-rouge">prototype</code>-scoped bean) or use the inner <code class="highlighter-rouge">&lt;bean/&gt;</code> configuration type. However, this optimization applies only if you do not provide any splitter-specific attributes in the splitter XML definition. If you inadvertently reference the same message handler from multiple beans, you get a configuration exception.</p>
</blockquote>

### 8.3.3. Configuring a Splitter with Annotations

The `@Splitter` annotation is applicable to methods that expect either the `Message` type or the message payload type, and the return values of the method should be a `Collection` of any type. If the returned values are not actual `Message` objects, each item is wrapped in a `Message` as the payload of the `Message`. Each resulting `Message` is sent to the designated output channel for the endpoint on which the `@Splitter` is defined.

The following example shows how to configure a splitter by using the `@Splitter` annotation:

```java
@Splitter
List<LineItem> extractItems(Order order) {
    return order.getItems()
}
```

See also [Advising Endpoints Using Annotations](https://docs.spring.io/spring-integration/docs/5.5.9/reference/html/handler-advice.html#advising-with-annotations), [Splitters](https://docs.spring.io/spring-integration/docs/5.5.9/reference/html/dsl.html#java-dsl-splitters) and [File Splitter](https://docs.spring.io/spring-integration/docs/5.5.9/reference/html/file.html#file-splitter).

---

## 8.4. Aggregator

Basically a mirror-image of the splitter, the aggregator is a type of message handler that receives multiple messages and combines them into a single message. In fact, an aggregator is often a downstream consumer in a pipeline that includes a splitter.

Technically, the aggregator is more complex than a splitter, because it is stateful. It must hold the messages to be aggregated and determine when the complete group of messages is ready to be aggregated. In order to do so, it requires a `MessageStore`.

### 8.4.1. Functionality

The Aggregator combines a group of related messages, by correlating and storing them, until the group is deemed to be complete. At that point, the aggregator creates a single message by processing the whole group and sends the aggregated message as output.

Implementing an aggregator requires providing the logic to perform the aggregation (that is, the creation of a single message from many). Two related concepts are correlation and release.

Correlation determines how messages are grouped for aggregation. In Spring Integration, correlation is done by default, based on the `IntegrationMessageHeaderAccessor.CORRELATION_ID` message header. Messages with the same `IntegrationMessageHeaderAccessor.CORRELATION_ID` are grouped together. However, you can customize the correlation strategy to allow other ways of specifying how the messages should be grouped together. To do so, you can implement a `CorrelationStrategy` (covered later in this chapter).

To determine the point at which a group of messages is ready to be processed, a `ReleaseStrategy` is consulted. The default release strategy for the aggregator releases a group when all messages included in a sequence are present, based on the `IntegrationMessageHeaderAccessor.SEQUENCE_SIZE` header. You can override this default strategy by providing a reference to a custom `ReleaseStrategy` implementation.

### 8.4.2. Programming Model

The Aggregation API consists of a number of classes:

- The interface `MessageGroupProcessor`, and its subclasses: `MethodInvokingAggregatingMessageGroupProcessor` and `ExpressionEvaluatingMessageGroupProcessor`
- The `ReleaseStrategy` interface and its default implementation: `SimpleSequenceSizeReleaseStrategy`
- The `CorrelationStrategy` interface and its default implementation: `HeaderAttributeCorrelationStrategy`

#### `AggregatingMessageHandler`

The `AggregatingMessageHandler` (a subclass of `AbstractCorrelatingMessageHandler`) is a `MessageHandler` implementation, encapsulating the common functionality of an aggregator (and other correlating use cases), which are as follows:

- Correlating messages into a group to be aggregated
- Maintaining those messages in a `MessageStore` until the group can be released
- Deciding when the group can be released
- Aggregating the released group into a single message
- Recognizing and responding to an expired group

The responsibility for deciding how the messages should be grouped together is delegated to a `CorrelationStrategy` instance. The responsibility for deciding whether the message group can be released is delegated to a `ReleaseStrategy` instance.

The following listing shows a brief highlight of the base `AbstractAggregatingMessageGroupProcessor` (the responsibility for implementing the `aggregatePayloads` method is left to the developer):

```java
public abstract class AbstractAggregatingMessageGroupProcessor
              implements MessageGroupProcessor {

    protected Map<String, Object> aggregateHeaders(MessageGroup group) {
        // default implementation exists
    }

    protected abstract Object aggregatePayloads(MessageGroup group, Map<String, Object> defaultHeaders);

}
```

See `DefaultAggregatingMessageGroupProcessor`, `ExpressionEvaluatingMessageGroupProcessor` and `MethodInvokingMessageGroupProcessor` as out-of-the-box implementations of the `AbstractAggregatingMessageGroupProcessor`.

Starting with version 5.2, a `Function<MessageGroup, Map<String, Object>>` strategy is available for the `AbstractAggregatingMessageGroupProcessor` to merge and compute (aggregate) headers for an output message. The `DefaultAggregateHeadersFunction` implementation is available with logic that returns all headers that have no conflicts among the group; an absent header on one or more messages within the group is not considered a conflict. Conflicting headers are omitted. Along with the newly introduced `DelegatingMessageGroupProcessor`, this function is used for any arbitrary (non-`AbstractAggregatingMessageGroupProcessor`) `MessageGroupProcessor` implementation. Essentially, the framework injects a provided function into an `AbstractAggregatingMessageGroupProcessor` instance and wraps all other implementations into a `DelegatingMessageGroupProcessor`. The difference in logic between the `AbstractAggregatingMessageGroupProcessor` and the `DelegatingMessageGroupProcessor` that the latter doesn’t compute headers in advance, before calling the delegate strategy, and doesn’t invoke the function if the delegate returns a `Message` or `AbstractIntegrationMessageBuilder`. In that case, the framework assumes that the target implementation has taken care of producing a proper set of headers populated into the returned result. The `Function<MessageGroup, Map<String, Object>>` strategy is available as the `headers-function` reference attribute for XML configuration, as the `AggregatorSpec.headersFunction()` option for the Java DSL and as `AggregatorFactoryBean.setHeadersFunction()` for plain Java configuration.

The `CorrelationStrategy` is owned by the `AbstractCorrelatingMessageHandler` and has a default value based on the `IntegrationMessageHeaderAccessor.CORRELATION_ID` message header, as the following example shows:

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

As for the actual processing of the message group, the default implementation is the `DefaultAggregatingMessageGroupProcessor`. It creates a single `Message` whose payload is a `List` of the payloads received for a given group. This works well for simple scatter-gather implementations with a splitter, a publish-subscribe channel, or a recipient list router upstream.

> When using a publish-subscribe channel or a recipient list router in this type of scenario, be sure to enable the `apply-sequence` flag. Doing so adds the necessary headers: `CORRELATION_ID`, `SEQUENCE_NUMBER`, and `SEQUENCE_SIZE`. That behavior is enabled by default for splitters in Spring Integration, but it is not enabled for publish-subscribe channels or for recipient list routers because those components may be used in a variety of contexts in which these headers are not necessary.

When implementing a specific aggregator strategy for an application, you can extend `AbstractAggregatingMessageGroupProcessor` and implement the `aggregatePayloads` method. However, there are better solutions, less coupled to the API, for implementing the aggregation logic, which can be configured either through XML or through annotations.

In general, any POJO can implement the aggregation algorithm if it provides a method that accepts a single `java.util.List` as an argument (parameterized lists are supported as well). This method is invoked for aggregating messages as follows:

- If the argument is a `java.util.Collection<T>` and the parameter type T is assignable to `Message`, the whole list of messages accumulated for aggregation is sent to the aggregator.
- If the argument is a non-parameterized `java.util.Collection` or the parameter type is not assignable to `Message`, the method receives the payloads of the accumulated messages.
- If the return type is not assignable to `Message`, it is treated as the payload for a `Message` that is automatically created by the framework.

> In the interest of code simplicity and promoting best practices such as low coupling, testability, and others, the preferred way of implementing the aggregation logic is through a POJO and using the XML or annotation support for configuring it in the application.

Starting with version 5.3, after processing message group, an `AbstractCorrelatingMessageHandler` performs a `MessageBuilder.popSequenceDetails()` message headers modification for the proper splitter-aggregator scenario with several nested levels. It is done only if the message group release result is not a collection of messages. In that case a target `MessageGroupProcessor` is responsible for the `MessageBuilder.popSequenceDetails()` call while building those messages.

If the `MessageGroupProcessor` returns a `Message`, a `MessageBuilder.popSequenceDetails()` will be performed on the output message only if the `sequenceDetails` matches with first message in group. (Previously this has been done only if a plain payload or an `AbstractIntegrationMessageBuilder` has been returned from the `MessageGroupProcessor`.)

This functionality can be controlled by a new `popSequence` `boolean` property, so the `MessageBuilder.popSequenceDetails()` can be disabled in some scenarios when correlation details have not been populated by the standard splitter. This property, essentially, undoes what has been done by the nearest upstream `applySequence = true` in the `AbstractMessageSplitter`. See [Splitter](https://docs.spring.io/spring-integration/docs/5.5.9/reference/html/splitter.html#splitter) for more information.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>The <code class="highlighter-rouge">SimpleMessageGroup.getMessages()</code> method returns an <code class="highlighter-rouge">unmodifiableCollection</code>. Therefore, if an aggregating POJO method has a <code class="highlighter-rouge">Collection&lt;Message&gt;</code> parameter, the argument passed in is exactly that <code class="highlighter-rouge">Collection</code> instance and, when you use a <code class="highlighter-rouge">SimpleMessageStore</code> for the aggregator, that original <code class="highlighter-rouge">Collection&lt;Message&gt;</code> is cleared after releasing the group. Consequently, the <code class="highlighter-rouge">Collection&lt;Message&gt;</code> variable in the POJO is cleared too, if it is passed out of the aggregator. If you wish to simply release that collection as-is for further processing, you must build a new <code class="highlighter-rouge">Collection</code> (for example, <code class="highlighter-rouge">new ArrayList&lt;Message&gt;(messages)</code>). Starting with version 4.3, the framework no longer copies the messages to a new collection, to avoid undesired extra object creation.</p>
</blockquote>


If the `processMessageGroup` method of the `MessageGroupProcessor` returns a collection, it must be a collection of `Message<?>` objects. In this case, the messages are individually released. Prior to version 4.2, it was not possible to provide a `MessageGroupProcessor` by using XML configuration. Only POJO methods could be used for aggregation. Now, if the framework detects that the referenced (or inner) bean implements `MessageProcessor`, it is used as the aggregator’s output processor.

If you wish to release a collection of objects from a custom `MessageGroupProcessor` as the payload of a message, your class should extend `AbstractAggregatingMessageGroupProcessor` and implement `aggregatePayloads()`.

Also, since version 4.2, a `SimpleMessageGroupProcessor` is provided. It returns the collection of messages from the group, which, as indicated earlier, causes the released messages to be sent individually.

This lets the aggregator work as a message barrier, where arriving messages are held until the release strategy fires and the group is released as a sequence of individual messages.

#### `ReleaseStrategy`

The `ReleaseStrategy` interface is defined as follows:

```java
public interface ReleaseStrategy {

  boolean canRelease(MessageGroup group);

}
```

In general, any POJO can implement the completion decision logic if it provides a method that accepts a single `java.util.List` as an argument (parameterized lists are supported as well) and returns a boolean value. This method is invoked after the arrival of each new message, to decide whether the group is complete or not, as follows:

- If the argument is a `java.util.List<T>` and the parameter type `T` is assignable to `Message`, the whole list of messages accumulated in the group is sent to the method.
- If the argument is a non-parametrized `java.util.List` or the parameter type is not assignable to `Message`, the method receives the payloads of the accumulated messages.
- The method must return `true` if the message group is ready for aggregation or false otherwise.

The following example shows how to use the `@ReleaseStrategy` annotation for a `List` of type `Message`:

```java
public class MyReleaseStrategy {

    @ReleaseStrategy
    public boolean canMessagesBeReleased(List<Message<?>>) {...}
}
```

The following example shows how to use the `@ReleaseStrategy` annotation for a `List` of type `String`:

```java
public class MyReleaseStrategy {

    @ReleaseStrategy
    public boolean canMessagesBeReleased(List<String>) {...}
}
```

Based on the signatures in the preceding two examples, the POJO-based release strategy is passed a `Collection` of not-yet-released messages (if you need access to the whole `Message`) or a `Collection` of payload objects (if the type parameter is anything other than `Message`). This satisfies the majority of use cases. However if, for some reason, you need to access the full `MessageGroup`, you should provide an implementation of the `ReleaseStrategy` interface.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>When handling potentially large groups, you should understand how these methods are invoked, because the release strategy may be invoked multiple times before the group is released. The most efficient is an implementation of <code class="highlighter-rouge">ReleaseStrategy</code>, because the aggregator can invoke it directly. The second most efficient is a POJO method with a <code class="highlighter-rouge">Collection&lt;Message&lt;?&gt;&gt;</code> parameter type. The least efficient is a POJO method with a <code class="highlighter-rouge">Collection&lt;Something&gt;</code> type. The framework has to copy the payloads from the messages in the group into a new collection (and possibly attempt conversion on the payloads to <code class="highlighter-rouge">Something</code>) every time the release strategy is called. Using <code class="highlighter-rouge">Collection&lt;?&gt;</code> avoids the conversion but still requires creating the new <code class="highlighter-rouge">Collection</code>.For these reasons, for large groups, we recommended that you implement <code class="highlighter-rouge">ReleaseStrategy</code>.</p>
</blockquote>

When the group is released for aggregation, all its not-yet-released messages are processed and removed from the group. If the group is also complete (that is, if all messages from a sequence have arrived or if there is no sequence defined), then the group is marked as complete. Any new messages for this group are sent to the discard channel (if defined). Setting `expire-groups-upon-completion` to `true` (the default is `false`) removes the entire group, and any new messages (with the same correlation ID as the removed group) form a new group. You can release partial sequences by using a `MessageGroupStoreReaper` together with `send-partial-result-on-expiry` being set to `true`.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>To facilitate discarding of late-arriving messages, the aggregator must maintain state about the group after it has been released. This can eventually cause out-of-memory conditions. To avoid such situations, you should consider configuring a <code class="highlighter-rouge">MessageGroupStoreReaper</code> to remove the group metadata. The expiry parameters should be set to expire groups once a point has been reach after which late messages are not expected to arrive. For information about configuring a reaper, see <a href="https://docs.spring.io/spring-integration/docs/5.5.9/reference/html/index-single.html#reaper">Managing State in an Aggregator: <code class="highlighter-rouge">MessageGroupStore</code></a>.</p>
</blockquote>


Spring Integration provides an implementation for `ReleaseStrategy`: `SimpleSequenceSizeReleaseStrategy`. This implementation consults the `SEQUENCE_NUMBER` and `SEQUENCE_SIZE` headers of each arriving message to decide when a message group is complete and ready to be aggregated. As shown earlier, it is also the default strategy.

> Before version 5.0, the default release strategy was `SequenceSizeReleaseStrategy`, which does not perform well with large groups. With that strategy, duplicate sequence numbers are detected and rejected. This operation can be expensive.

If you are aggregating large groups, you don’t need to release partial groups, and you don’t need to detect/reject duplicate sequences, consider using the `SimpleSequenceSizeReleaseStrategy` instead - it is much more efficient for these use cases, and is the default since *version 5.0* when partial group release is not specified.

#### Aggregating Large Groups

The 4.3 release changed the default `Collection` for messages in a `SimpleMessageGroup` to `HashSet` (it was previously a `BlockingQueue`). This was expensive when removing individual messages from large groups (an O(n) linear scan was required). Although the hash set is generally much faster to remove, it can be expensive for large messages, because the hash has to be calculated on both inserts and removes. If you have messages that are expensive to hash, consider using some other collection type. As discussed in [Using `MessageGroupFactory`](https://docs.spring.io/spring-integration/docs/5.5.9/reference/html/message-store.html#message-group-factory), a `SimpleMessageGroupFactory` is provided so that you can select the `Collection` that best suits your needs. You can also provide your own factory implementation to create some other `Collection<Message<?>>`.

The following example shows how to configure an aggregator with the previous implementation and a `SimpleSequenceSizeReleaseStrategy`:

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

> If the filter endpoint is involved in the flow upstream of an aggregator, the sequence size release strategy (fixed or based on the `sequenceSize` header) is not going to serve its purpose because some messages from a sequence may be discarded by the filter. In this case it is recommended to choose another `ReleaseStrategy`, or use compensation messages sent from a discard sub-flow carrying some information in their content to be skipped in a custom complete group function. See [Filter](https://docs.spring.io/spring-integration/docs/5.5.9/reference/html/filter.html#filter) for more information.

#### Correlation Strategy

The `CorrelationStrategy` interface is defined as follows:

```java
public interface CorrelationStrategy {

  Object getCorrelationKey(Message<?> message);

}
```

The method returns an `Object` that represents the correlation key used for associating the message with a message group. The key must satisfy the criteria used for a key in a `Map` with respect to the implementation of `equals()` and `hashCode()`.

In general, any POJO can implement the correlation logic, and the rules for mapping a message to a method’s argument (or arguments) are the same as for a `ServiceActivator` (including support for `@Header` annotations). The method must return a value, and the value must not be `null`.

Spring Integration provides an implementation for `CorrelationStrategy`: `HeaderAttributeCorrelationStrategy`. This implementation returns the value of one of the message headers (whose name is specified by a constructor argument) as the correlation key. By default, the correlation strategy is a `HeaderAttributeCorrelationStrategy` that returns the value of the `CORRELATION_ID` header attribute. If you have a custom header name you would like to use for correlation, you can configure it on an instance of `HeaderAttributeCorrelationStrategy` and provide that as a reference for the aggregator’s correlation strategy.

#### Lock Registry

Changes to groups are thread safe. So, when you send messages for the same correlation ID concurrently, only one of them will be processed in the aggregator, making it effectively as a **single-threaded per message group**. A `LockRegistry` is used to obtain a lock for the resolved correlation ID. A `DefaultLockRegistry` is used by default (in-memory). For synchronizing updates across servers where a shared `MessageGroupStore` is being used, you must configure a shared lock registry.

#### Avoiding Deadlocks

As discussed above, when message groups are mutated (messages added or released) a lock is held.

Consider the following flow:

```none
...->aggregator1-> ... ->aggregator2-> ...
```

If there are multiple threads, **and the aggregators share a common lock registry**, it is possible to get a deadlock. This will cause hung threads and `jstack <pid>` might present a result such as:

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

There are several ways to avoid this problem:

- ensure each aggregator has its own lock registry (this can be a shared registry across application instances but two or more aggregators in the flow must each have a distinct registry)
- use an `ExecutorChannel` or `QueueChannel` as the output channel of the aggregator so that the downstream flow runs on a new thread
- starting with version 5.1.1, set the `releaseLockBeforeSend` aggregator property to `true`

> This problem can also be caused if, for some reason, the output of a single aggregator is eventually routed back to the same aggregator. Of course, the first solution above does not apply in this case.

### 8.4.3. Configuring an Aggregator in Java DSL

See [Aggregators and Resequencers](https://docs.spring.io/spring-integration/docs/5.5.9/reference/html/dsl.html#java-dsl-aggregators) for how to configure an aggregator in Java DSL.

#### Configuring an Aggregator with XML

Spring Integration supports the configuration of an aggregator with XML through the `<aggregator/>` element. The following example shows an example of an aggregator:

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
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> The id of the aggregator is optional.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> Lifecycle attribute signaling whether the aggregator should be started during application context startup. Optional (the default is 'true').</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> The channel from which where aggregator receives messages. Required.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> The channel to which the aggregator sends the aggregation results. Optional (because incoming messages can themselves specify a reply channel in the 'replyChannel' message header).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> The channel to which the aggregator sends the messages that timed out (if `send-partial-result-on-expiry` is `false`). Optional.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(6)</span> A reference to a `MessageGroupStore` used to store groups of messages under their correlation key until they are complete. Optional. By default, it is a volatile in-memory store. See [Message Store](https://docs.spring.io/spring-integration/docs/5.5.9/reference/html/message-store.html#message-store) for more information.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(7)</span> The order of this aggregator when more than one handle is subscribed to the same `DirectChannel` (use for load-balancing purposes). Optional.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(8)</span> Indicates that expired messages should be aggregated and sent to the 'output-channel' or 'replyChannel' once their containing `MessageGroup` is expired (see [`MessageGroupStore.expireMessageGroups(long)`](https://docs.spring.io/spring-integration/api/org/springframework/integration/store/MessageGroupStore.html#expireMessageGroups-long)). One way of expiring a `MessageGroup` is by configuring a `MessageGroupStoreReaper`. However you can alternatively expire `MessageGroup` by calling `MessageGroupStore.expireMessageGroups(timeout)`. You can accomplish that through a Control Bus operation or, if you have a reference to the `MessageGroupStore` instance, by invoking `expireMessageGroups(timeout)`. Otherwise, by itself, this attribute does nothing. It serves only as an indicator of whether to discard or send to the output or reply channel any messages that are still in the `MessageGroup` that is about to be expired. Optional (the default is `false`). NOTE: This attribute might more properly be called `send-partial-result-on-timeout`, because the group may not actually expire if `expire-groups-upon-timeout` is set to `false`.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(9)</span> The timeout interval to wait when sending a reply `Message` to the `output-channel` or `discard-channel`. Defaults to `-1`, which results in blocking indefinitely. It is applied only if the output channel has some 'sending' limitations, such as a `QueueChannel` with a fixed 'capacity'. In this case, a `MessageDeliveryException` is thrown. For `AbstractSubscribableChannel` implementations, the `send-timeout` is ignored . For `group-timeout(-expression)`, the `MessageDeliveryException` from the scheduled expire task leads this task to be rescheduled. Optional.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(10)</span> A reference to a bean that implements the message correlation (grouping) algorithm. The bean can be an implementation of the `CorrelationStrategy` interface or a POJO. In the latter case, the `correlation-strategy-method` attribute must be defined as well. Optional (by default, the aggregator uses the `IntegrationMessageHeaderAccessor.CORRELATION_ID` header).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(11)</span> A method defined on the bean referenced by `correlation-strategy`. It implements the correlation decision algorithm. Optional, with restrictions (`correlation-strategy` must be present).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(12)</span> A SpEL expression representing the correlation strategy. Example: `"headers['something']"`. Only one of `correlation-strategy` or `correlation-strategy-expression` is allowed.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(13)</span> A reference to a bean defined in the application context. The bean must implement the aggregation logic, as described earlier. Optional (by default, the list of aggregated messages becomes a payload of the output message).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(14)</span> A method defined on the bean referenced by the `ref` attribute. It implements the message aggregation algorithm. Optional (it depends on `ref` attribute being defined).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(15)</span> A reference to a bean that implements the release strategy. The bean can be an implementation of the `ReleaseStrategy` interface or a POJO. In the latter case, the `release-strategy-method` attribute must be defined as well. Optional (by default, the aggregator uses the `IntegrationMessageHeaderAccessor.SEQUENCE_SIZE` header attribute).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(16)</span> A method defined on the bean referenced by the `release-strategy` attribute. It implements the completion decision algorithm. Optional, with restrictions (`release-strategy` must be present).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(17)</span> A SpEL expression representing the release strategy. The root object for the expression is a `MessageGroup`. Example: `"size() == 5"`. Only one of `release-strategy` or `release-strategy-expression` is allowed.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(18)</span> When set to `true` (the default is `false`), completed groups are removed from the message store, letting subsequent messages with the same correlation form a new group. The default behavior is to send messages with the same correlation as a completed group to the `discard-channel`.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(19)</span> Applies only if a `MessageGroupStoreReaper` is configured for the `MessageStore` of the `<aggregator>`. By default, when a `MessageGroupStoreReaper` is configured to expire partial groups, empty groups are also removed. Empty groups exist after a group is normally released. The empty groups enable the detection and discarding of late-arriving messages. If you wish to expire empty groups on a longer schedule than expiring partial groups, set this property. Empty groups are then not removed from the `MessageStore` until they have not been modified for at least this number of milliseconds. Note that the actual time to expire an empty group is also affected by the reaper’s `timeout` property, and it could be as much as this value plus the timeout.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(20)</span> A reference to a `org.springframework.integration.util.LockRegistry` bean. It used to obtain a `Lock` based on the `groupId` for concurrent operations on the `MessageGroup`. By default, an internal `DefaultLockRegistry` is used. Use of a distributed `LockRegistry`, such as the `ZookeeperLockRegistry`, ensures only one instance of the aggregator can operate on a group concurrently. See [Redis Lock Registry](https://docs.spring.io/spring-integration/docs/5.5.9/reference/html/redis.html#redis-lock-registry), [Gemfire Lock Registry](https://docs.spring.io/spring-integration/docs/5.5.9/reference/html/gemfire.html#gemfire-lock-registry), and [Zookeeper Lock Registry](https://docs.spring.io/spring-integration/docs/5.5.9/reference/html/zookeeper.html#zk-lock-registry) for more information.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(21)</span> A timeout (in milliseconds) to force the `MessageGroup` complete when the `ReleaseStrategy` does not release the group when the current message arrives. This attribute provides a built-in time-based release strategy for the aggregator when there is a need to emit a partial result (or discard the group) if a new message does not arrive for the `MessageGroup` within the timeout which counts from the time the last message arrived. To set up a timeout which counts from the time the `MessageGroup` was created see `group-timeout-expression` information. When a new message arrives at the aggregator, any existing `ScheduledFuture<?>` for its `MessageGroup` is canceled. If the `ReleaseStrategy` returns `false` (meaning do not release) and `groupTimeout > 0`, a new task is scheduled to expire the group. We do not advise setting this attribute to zero (or a negative value). Doing so effectively disables the aggregator, because every message group is immediately completed. You can, however, conditionally set it to zero (or a negative value) by using an expression. See `group-timeout-expression` for information. The action taken during the completion depends on the `ReleaseStrategy` and the `send-partial-group-on-expiry` attribute. See [Aggregator and Group Timeout](https://docs.spring.io/spring-integration/docs/5.5.9/reference/html/index-single.html#agg-and-group-to) for more information. It is mutually exclusive with 'group-timeout-expression' attribute.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(22)</span> The SpEL expression that evaluates to a `groupTimeout` with the `MessageGroup` as the `#root` evaluation context object. Used for scheduling the `MessageGroup` to be forced complete. If the expression evaluates to `null`, the completion is not scheduled. If it evaluates to zero, the group is completed immediately on the current thread. In effect, this provides a dynamic `group-timeout` property. As an example, if you wish to forcibly complete a `MessageGroup` after 10 seconds have elapsed since the time the group was created you might consider using the following SpEL expression: `timestamp + 10000 - T(System).currentTimeMillis()` where `timestamp` is provided by `MessageGroup.getTimestamp()` as the `MessageGroup` here is the `#root` evaluation context object. Bear in mind however that the group creation time might differ from the time of the first arrived message depending on other group expiration properties' configuration. See `group-timeout` for more information. Mutually exclusive with 'group-timeout' attribute.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(23)</span> When a group is completed due to a timeout (or by a `MessageGroupStoreReaper`), the group is expired (completely removed) by default. Late arriving messages start a new group. You can set this to `false` to complete the group but have its metadata remain so that late arriving messages are discarded. Empty groups can be expired later using a `MessageGroupStoreReaper` together with the `empty-group-min-timeout` attribute. It defaults to 'true'.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(24)</span> A `TaskScheduler` bean reference to schedule the `MessageGroup` to be forced complete if no new message arrives for the `MessageGroup` within the `groupTimeout`. If not provided, the default scheduler (`taskScheduler`) registered in the `ApplicationContext` (`ThreadPoolTaskScheduler`) is used. This attribute does not apply if `group-timeout` or `group-timeout-expression` is not specified.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(25)</span> Since version 4.1. It lets a transaction be started for the `forceComplete` operation. It is initiated from a `group-timeout(-expression)` or by a `MessageGroupStoreReaper` and is not applied to the normal `add`, `release`, and `discard` operations. Only this sub-element or `<expire-advice-chain/>` is allowed.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(26)</span> Since *version 4.1*. It allows the configuration of any `Advice` for the `forceComplete` operation. It is initiated from a `group-timeout(-expression)` or by a `MessageGroupStoreReaper` and is not applied to the normal `add`, `release`, and `discard` operations. Only this sub-element or `<expire-transactional/>` is allowed. A transaction `Advice` can also be configured here by using the Spring `tx` namespace.</small>

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p><strong>Expiring Groups</strong></p>

  <p>There are two attributes related to expiring (completely removing) groups. When a group is expired, there is no record of it, and, if a new message arrives with the same correlation, a new group is started. When a group is completed (without expiry), the empty group remains and late-arriving messages are discarded. Empty groups can be removed later by using a <code class="highlighter-rouge">MessageGroupStoreReaper</code> in combination with the <code class="highlighter-rouge">empty-group-min-timeout</code> attribute.</p>

  <p><code class="highlighter-rouge">expire-groups-upon-completion</code> relates to “normal” completion when the <code class="highlighter-rouge">ReleaseStrategy</code> releases the group. This defaults to <code class="highlighter-rouge">false</code>.</p>

  <p>If a group is not completed normally but is released or discarded because of a timeout, the group is normally expired. Since version 4.1, you can control this behavior by using <code class="highlighter-rouge">expire-groups-upon-timeout</code>. It defaults to <code class="highlighter-rouge">true</code> for backwards compatibility.</p>

  <blockquote>
    <p>When a group is timed out, the <code class="highlighter-rouge">ReleaseStrategy</code> is given one more opportunity to release the group. If it does so and <code class="highlighter-rouge">expire-groups-upon-timeout</code> is false, expiration is controlled by <code class="highlighter-rouge">expire-groups-upon-completion</code>. If the group is not released by the release strategy during timeout, then the expiration is controlled by the <code class="highlighter-rouge">expire-groups-upon-timeout</code>. Timed-out groups are either discarded or a partial release occurs (based on <code class="highlighter-rouge">send-partial-result-on-expiry</code>).</p>
  </blockquote>

  <p>Since version 5.0, empty groups are also scheduled for removal after <code class="highlighter-rouge">empty-group-min-timeout</code>. If <code class="highlighter-rouge">expireGroupsUponCompletion == false</code> and <code class="highlighter-rouge">minimumTimeoutForEmptyGroups &gt; 0</code>, the task to remove the group is scheduled when normal or partial sequences release happens.</p>

  <p>Starting with version 5.4, the aggregator (and resequencer) can be configured to expire orphaned groups (groups in a persistent message store that might not otherwise be released). The <code class="highlighter-rouge">expireTimeout</code> (if greater than <code class="highlighter-rouge">0</code>) indicates that groups older than this value in the store should be purged. The <code class="highlighter-rouge">purgeOrphanedGroups()</code> method is called on start up and, together with the provided <code class="highlighter-rouge">expireDuration</code>, periodically within a scheduled task. This method is also can be called externally at any time. The expiration logic is fully delegated to the <code class="highlighter-rouge">forceComplete(MessageGroup)</code> functionality according to the provided expiration options mentioned above. Such a periodic purge functionality is useful when a message store is needed to be cleaned up from those old groups which are not going to be released any more with regular message arrival logic. In most cases this happens after an application restart, when using a persistent message group store. The functionality is similar to the <code class="highlighter-rouge">MessageGroupStoreReaper</code> with a scheduled task, but provides a convenient way to deal with old groups within specific components, when using group timeout instead of a reaper. The <code class="highlighter-rouge">MessageGroupStore</code> must be provided exclusively for the current correlation endpoint. Otherwise one aggregator may purge groups from another. With the aggregator, groups expired using this technique will either be discarded or released as a partial group, depending on the <code class="highlighter-rouge">expireGroupsUponCompletion</code> property.</p>
</blockquote>

We generally recommend using a `ref` attribute if a custom aggregator handler implementation may be referenced in other `<aggregator>` definitions. However, if a custom aggregator implementation is only being used by a single definition of the `<aggregator>`, you can use an inner bean definition (starting with version 1.0.3) to configure the aggregation POJO within the `<aggregator>` element, as the following example shows:

```xml
<aggregator input-channel="input" method="sum" output-channel="output">
    <beans:bean class="org.foo.PojoAggregator"/>
</aggregator>
```

> Using both a `ref` attribute and an inner bean definition in the same `<aggregator>` configuration is not allowed, as it creates an ambiguous condition. In such cases, an Exception is thrown.

The following example shows an implementation of the aggregator bean:

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

An implementation of the completion strategy bean for the preceding example might be as follows:

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

> Wherever it makes sense to do so, the release strategy method and the aggregator method can be combined into a single bean.

An implementation of the correlation strategy bean for the example above might be as follows:

```java
public class PojoCorrelationStrategy {
...
  public Long groupNumbersByLastDigit(Long number) {
    return number % 10;
  }
}
```

The aggregator in the preceding example would group numbers by some criterion (in this case, the remainder after dividing by ten) and hold the group until the sum of the numbers provided by the payloads exceeds a certain value.

> Wherever it makes sense to do so, the release strategy method, the correlation strategy method, and the aggregator method can be combined in a single bean. (Actually, all of them or any two of them can be combined.)

#### Aggregators and Spring Expression Language (SpEL)

Since Spring Integration 2.0, you can handle the various strategies (correlation, release, and aggregation) with [SpEL](https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#expressions), which we recommend if the logic behind such a release strategy is relatively simple. Suppose you have a legacy component that was designed to receive an array of objects. We know that the default release strategy assembles all aggregated messages in the `List`. Now we have two problems. First, we need to extract individual messages from the list. Second, we need to extract the payload of each message and assemble the array of objects. The following example solves both problems:

```java
public String[] processRelease(List<Message<String>> messages){
    List<String> stringList = new ArrayList<String>();
    for (Message<String> message : messages) {
        stringList.add(message.getPayload());
    }
    return stringList.toArray(new String[]{});
}
```

However, with SpEL, such a requirement could actually be handled relatively easily with a one-line expression, thus sparing you from writing a custom class and configuring it as a bean. The following example shows how to do so:

```xml
<int:aggregator input-channel="aggChannel"
    output-channel="replyChannel"
    expression="#this.![payload].toArray()"/>
```

In the preceding configuration, we use a [collection projection](https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#expressions) expression to assemble a new collection from the payloads of all the messages in the list and then transform it to an array, thus achieving the same result as the earlier Java code.

You can apply the same expression-based approach when dealing with custom release and correlation strategies.

Instead of defining a bean for a custom `CorrelationStrategy` in the `correlation-strategy` attribute, you can implement your simple correlation logic as a SpEL expression and configure it in the `correlation-strategy-expression` attribute, as the following example shows:

```xml
correlation-strategy-expression="payload.person.id"
```

In the preceding example, we assume that the payload has a `person` attribute with an `id`, which is going to be used to correlate messages.

Likewise, for the `ReleaseStrategy`, you can implement your release logic as a SpEL expression and configure it in the `release-strategy-expression` attribute. The root object for evaluation context is the `MessageGroup` itself. The `List` of messages can be referenced by using the `message` property of the group within the expression.

> In releases prior to version 5.0, the root object was the collection of `Message<?>`, as the previous example shows:

```xml
release-strategy-expression="!messages.?[payload==5].empty"
```

In the preceding example, the root object of the SpEL evaluation context is the `MessageGroup` itself, and you are stating that, as soon as there is a message with payload of `5` in this group, the group should be released.

#### Aggregator and Group Timeout

Starting with version 4.0, two new mutually exclusive attributes have been introduced: `group-timeout` and `group-timeout-expression`. See [Configuring an Aggregator with XML](https://docs.spring.io/spring-integration/docs/5.5.9/reference/html/index-single.html#aggregator-xml). In some cases, you may need to emit the aggregator result (or discard the group) after a timeout if the `ReleaseStrategy` does not release when the current message arrives. For this purpose, the `groupTimeout` option lets scheduling the `MessageGroup` be forced to complete, as the following example shows:

```xml
<aggregator input-channel="input" output-channel="output"
        send-partial-result-on-expiry="true"
        group-timeout-expression="size() ge 2 ? 10000 : -1"
        release-strategy-expression="messages[0].headers.sequenceNumber == messages[0].headers.sequenceSize"/>
```

With this example, the normal release is possible if the aggregator receives the last message in sequence as defined by the `release-strategy-expression`. If that specific message does not arrive, the `groupTimeout` forces the group to complete after ten seconds, as long as the group contains at least two Messages.

The results of forcing the group to complete depends on the `ReleaseStrategy` and the `send-partial-result-on-expiry`. First, the release strategy is again consulted to see if a normal release is to be made. While the group has not changed, the `ReleaseStrategy` can decide to release the group at this time. If the release strategy still does not release the group, it is expired. If `send-partial-result-on-expiry` is `true`, existing messages in the (partial) `MessageGroup` are released as a normal aggregator reply message to the `output-channel`. Otherwise, it is discarded.

There is a difference between `groupTimeout` behavior and `MessageGroupStoreReaper` (see [Configuring an Aggregator with XML](https://docs.spring.io/spring-integration/docs/5.5.9/reference/html/index-single.html#aggregator-xml)). The reaper initiates forced completion for all `MessageGroup` s in the `MessageGroupStore` periodically. The `groupTimeout` does it for each `MessageGroup` individually if a new message does not arrive during the `groupTimeout`. Also, the reaper can be used to remove empty groups (empty groups are retained in order to discard late messages if `expire-groups-upon-completion` is false).

Starting with version 5.5, the `groupTimeoutExpression` can be evaluated to a `java.util.Date` instance. This can be useful in cases like determining a scheduled task moment based on the group creation time (`MessageGroup.getTimestamp()`) instead of a current message arrival as it is calculated when `groupTimeoutExpression` is evaluated to `long`:

```xml
group-timeout-expression="size() ge 2 ? new java.util.Date(timestamp + 200) : null"
```

#### Configuring an Aggregator with Annotations

The following example shows an aggregator configured with annotations:

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
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> An annotation indicating that this method should be used as an aggregator. It must be specified if this class is used as an aggregator.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> An annotation indicating that this method is used as the release strategy of an aggregator. If not present on any method, the aggregator uses the `SimpleSequenceSizeReleaseStrategy`.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> An annotation indicating that this method should be used as the correlation strategy of an aggregator. If no correlation strategy is indicated, the aggregator uses the `HeaderAttributeCorrelationStrategy` based on `CORRELATION_ID`.</small>

All the configuration options provided by the XML element are also available for the `@Aggregator` annotation.

The aggregator can be either referenced explicitly from XML or, if the `@MessageEndpoint` is defined on the class, detected automatically through classpath scanning.

Annotation configuration (`@Aggregator` and others) for the Aggregator component covers only simple use cases, where most default options are sufficient. If you need more control over those options when using annotation configuration, consider using a `@Bean` definition for the `AggregatingMessageHandler` and mark its `@Bean` method with `@ServiceActivator`, as the following example shows:

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

See [Programming Model](https://docs.spring.io/spring-integration/docs/5.5.9/reference/html/index-single.html#aggregator-api) and [Annotations on `@Bean` Methods](https://docs.spring.io/spring-integration/docs/5.5.9/reference/html/configuration.html#annotations_on_beans) for more information.

> Starting with version 4.2, the `AggregatorFactoryBean` is available to simplify Java configuration for the `AggregatingMessageHandler`.

### 8.4.4. Managing State in an Aggregator: `MessageGroupStore`

Aggregator (and some other patterns in Spring Integration) is a stateful pattern that requires decisions to be made based on a group of messages that have arrived over a period of time, all with the same correlation key. The design of the interfaces in the stateful patterns (such as `ReleaseStrategy`) is driven by the principle that the components (whether defined by the framework or by a user) should be able to remain stateless. All state is carried by the `MessageGroup` and its management is delegated to the `MessageGroupStore`. The `MessageGroupStore` interface is defined as follows:

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

For more information, see the [Javadoc](https://docs.spring.io/spring-integration/api/org/springframework/integration/store/MessageGroupStore.html).

The `MessageGroupStore` accumulates state information in `MessageGroups` while waiting for a release strategy to be triggered, and that event might not ever happen. So, to prevent stale messages from lingering, and for volatile stores to provide a hook for cleaning up when the application shuts down, the `MessageGroupStore` lets you register callbacks to apply to its `MessageGroups` when they expire. The interface is very straightforward, as the following listing shows:

```java
public interface MessageGroupCallback {

    void execute(MessageGroupStore messageGroupStore, MessageGroup group);

}
```

The callback has direct access to the store and the message group so that it can manage the persistent state (for example, by entirely removing the group from the store).

The `MessageGroupStore` maintains a list of these callbacks, which it applies, on demand, to all messages whose timestamps are earlier than a time supplied as a parameter (see the `registerMessageGroupExpiryCallback(..)` and `expireMessageGroups(..)` methods, described earlier).

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>It is important not to use the same <code class="highlighter-rouge">MessageGroupStore</code> instance in different aggregator components, when you intend to rely on the <code class="highlighter-rouge">expireMessageGroups</code> functionality. Every <code class="highlighter-rouge">AbstractCorrelatingMessageHandler</code> registers its own <code class="highlighter-rouge">MessageGroupCallback</code> based on the <code class="highlighter-rouge">forceComplete()</code> callback. This way each group for expiration may be completed or discarded by the wrong aggregator. Starting with version 5.0.10, a <code class="highlighter-rouge">UniqueExpiryCallback</code> is used from the <code class="highlighter-rouge">AbstractCorrelatingMessageHandler</code> for the registration callback in the <code class="highlighter-rouge">MessageGroupStore</code>. The <code class="highlighter-rouge">MessageGroupStore</code>, in turn, checks for presence an instance of this class and logs an error with an appropriate message if one is already present in the callbacks set. This way the Framework disallows usage of the <code class="highlighter-rouge">MessageGroupStore</code> instance in different aggregators/resequencers to avoid the mentioned side effect of expiration the groups not created by the particular correlation handler.</p>
</blockquote>

You can call the `expireMessageGroups` method with a timeout value. Any message older than the current time minus this value is expired and has the callbacks applied. Thus, it is the user of the store that defines what is meant by message group “expiry”.

As a convenience for users, Spring Integration provides a wrapper for the message expiry in the form of a `MessageGroupStoreReaper`, as the following example shows:

```xml
<bean id="reaper" class="org...MessageGroupStoreReaper">
    <property name="messageGroupStore" ref="messageStore"/>
    <property name="timeout" value="30000"/>
</bean>

<task:scheduled-tasks scheduler="scheduler">
    <task:scheduled ref="reaper" method="run" fixed-rate="10000"/>
</task:scheduled-tasks>
```

The reaper is a `Runnable`. In the preceding example, the message group store’s expire method is called every ten seconds. The timeout itself is 30 seconds.

> It is important to understand that the 'timeout' property of `MessageGroupStoreReaper` is an approximate value and is impacted by the rate of the task scheduler, since this property is only checked on the next scheduled execution of the `MessageGroupStoreReaper` task. For example, if the timeout is set for ten minutes but the `MessageGroupStoreReaper` task is scheduled to run every hour and the last execution of the `MessageGroupStoreReaper` task happened one minute before the timeout, the `MessageGroup` does not expire for the next 59 minutes. Consequently, we recommend setting the rate to be at least equal to the value of the timeout or shorter.

In addition to the reaper, the expiry callbacks are invoked when the application shuts down through a lifecycle callback in the `AbstractCorrelatingMessageHandler`.

The `AbstractCorrelatingMessageHandler` registers its own expiry callback, and this is the link with the boolean flag `send-partial-result-on-expiry` in the XML configuration of the aggregator. If the flag is set to `true`, then, when the expiry callback is invoked, any unmarked messages in groups that are not yet released can be sent on to the output channel.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>Since the <code class="highlighter-rouge">MessageGroupStoreReaper</code> is called from a scheduled task, and may result in the production of a message (depending on the <code class="highlighter-rouge">sendPartialResultOnExpiry</code> option) to a downstream integration flow, it is recommended to supply a custom <code class="highlighter-rouge">TaskScheduler</code> with a <code class="highlighter-rouge">MessagePublishingErrorHandler</code> to handler exceptions via an <code class="highlighter-rouge">errorChannel</code>, as it might be expected by the regular aggregator release functionality. The same logic applies for group timeout functionality which also relies on a <code class="highlighter-rouge">TaskScheduler</code>. See <a href="https://docs.spring.io/spring-integration/docs/5.5.9/reference/html/error-handling.html#error-handling">Error Handling</a> for more information.</p>
</blockquote>

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>When a shared <code class="highlighter-rouge">MessageStore</code> is used for different correlation endpoints, you must configure a proper <code class="highlighter-rouge">CorrelationStrategy</code> to ensure uniqueness for group IDs. Otherwise, unexpected behavior may happen when one correlation endpoint releases or expire messages from others. Messages with the same correlation key are stored in the same message group.</p>
  <p>Some <code class="highlighter-rouge">MessageStore</code> implementations allow using the same physical resources, by partitioning the data. For example, the <code class="highlighter-rouge">JdbcMessageStore</code> has a <code class="highlighter-rouge">region</code> property, and the <code class="highlighter-rouge">MongoDbMessageStore</code> has a <code class="highlighter-rouge">collectionName</code> property.</p>
  <p>For more information about the <code class="highlighter-rouge">MessageStore</code> interface and its implementations, see <a href="https://docs.spring.io/spring-integration/docs/5.5.9/reference/html/message-store.html#message-store">Message Store</a>.</p>
</blockquote>

### 8.4.5. Flux Aggregator

In version 5.2, the `FluxAggregatorMessageHandler` component has been introduced. It is based on the Project Reactor `Flux.groupBy()` and `Flux.window()` operators. The incoming messages are emitted into the `FluxSink` initiated by the `Flux.create()` in the constructor of this component. If the `outputChannel` is not provided or it is not an instance of `ReactiveStreamsSubscribableChannel`, the subscription to the main `Flux` is done from the `Lifecycle.start()` implementation. Otherwise it is postponed to the subscription done by the `ReactiveStreamsSubscribableChannel` implementation. The messages are grouped by the `Flux.groupBy()` using a `CorrelationStrategy` for the group key. By default, the `IntegrationMessageHeaderAccessor.CORRELATION_ID` header of the message is consulted.

By default every closed window is released as a `Flux` in payload of a message to produce. This message contains all the headers from the first message in the window. This `Flux` in the output message payload must be subscribed and processed downstream. Such a logic can be customized (or superseded) by the `setCombineFunction(Function<Flux<Message<?>>, Mono<Message<?>>>)` configuration option of the `FluxAggregatorMessageHandler`. For example, if we would like to have a `List` of payloads in the final message, we can configure a `Flux.collectList()` like this:

```java
fluxAggregatorMessageHandler.setCombineFunction(
                (messageFlux) ->
                        messageFlux
                                .map(Message::getPayload)
                                .collectList()
                                .map(GenericMessage::new));
```

There are several options in the `FluxAggregatorMessageHandler` to select an appropriate window strategy:

- `setBoundaryTrigger(Predicate<Message<?>>)` - is propagated to the `Flux.windowUntil()` operator. See its JavaDocs for more information. Has a precedence over all other window options.
- `setWindowSize(int)` and `setWindowSizeFunction(Function<Message<?>, Integer>)` - is propagated to the `Flux.window(int)` or `windowTimeout(int, Duration)`. By default a window size is calculated from the first message in group and its `IntegrationMessageHeaderAccessor.SEQUENCE_SIZE` header.
- `setWindowTimespan(Duration)` - is propagated to the `Flux.window(Duration)` or `windowTimeout(int, Duration)` depending on the window size configuration.
- `setWindowConfigurer(Function<Flux<Message<?>>, Flux<Flux<Message<?>>>>)` - a function to apply a transformation into the grouped fluxes for any custom window operation not covered by the exposed options.

Since this component is a `MessageHandler` implementation it can simply be used as a `@Bean` definition together with a `@ServiceActivator` messaging annotation. With Java DSL it can be used from the `.handle()` EIP-method. The sample below demonstrates how we can register an `IntegrationFlow` at runtime and how a `FluxAggregatorMessageHandler` can be correlated with a splitter upstream:

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

Starting with version 5.5, an `AbstractCorrelatingMessageHandler` (including its Java & XML DSLs) exposes a `groupConditionSupplier` option of the `BiFunction<Message<?>, String, String>` implementation. This function is used on each message added to the group and a result condition sentence is stored into the group for future consideration. The `ReleaseStrategy` may consult this condition instead of iterating over all the messages in the group. See `GroupConditionProvider` JavaDocs and [Message Group Condition](https://docs.spring.io/spring-integration/docs/5.5.9/reference/html/message-store.html#message-group-condition) for more information.

See also [File Aggregator](https://docs.spring.io/spring-integration/docs/5.5.9/reference/html/file.html#file-aggregator).

---

## 8.5. Resequencer

The resequencer is related to the aggregator but serves a different purpose. While the aggregator combines messages, the resequencer passes messages through without changing them.

### 8.5.1. Functionality

The resequencer works in a similar way to the aggregator, in the sense that it uses the `CORRELATION_ID` to store messages in groups. The difference is that the Resequencer does not process the messages in any way. Instead, it releases them in the order of their `SEQUENCE_NUMBER` header values.

With respect to that, you can opt to release all messages at once (after the whole sequence, according to the `SEQUENCE_SIZE`, and other possibilities) or as soon as a valid sequence is available. (We cover what we mean by "a valid sequence" later in this chapter.)

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>The resequencer is intended to resequence relatively short sequences of messages with small gaps. If you have a large number of disjoint sequences with many gaps, you may experience performance issues.</p>
</blockquote>

### 8.5.2. Configuring a Resequencer

See [Aggregators and Resequencers](https://docs.spring.io/spring-integration/docs/5.5.9/reference/html/dsl.html#java-dsl-aggregators) for configuring a resequencer in Java DSL.

Configuring a resequencer requires only including the appropriate element in XML.

The following example shows a resequencer configuration:

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
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> The id of the resequencer is optional.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> The input channel of the resequencer. Required.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> The channel to which the resequencer sends the reordered messages. Optional.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> The channel to which the resequencer sends the messages that timed out (if `send-partial-result-on-timeout` is set to `false`). Optional.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> Whether to send out ordered sequences as soon as they are available or only after the whole message group arrives. Optional. (The default is `false`.)</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(6)</span> A reference to a `MessageGroupStore` that can be used to store groups of messages under their correlation key until they are complete. Optional. (The default is a volatile in-memory store.)</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(7)</span> Whether, upon the expiration of the group, the ordered group should be sent out (even if some of the messages are missing). Optional. (The default is false.) See [Managing State in an Aggregator: `MessageGroupStore`](https://docs.spring.io/spring-integration/docs/5.5.9/reference/html/aggregator.html#reaper).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(8)</span> The timeout interval to wait when sending a reply `Message` to the `output-channel` or `discard-channel`. Defaults to `-1`, which blocks indefinitely. It is applied only if the output channel has some 'sending' limitations, such as a `QueueChannel` with a fixed 'capacity'. In this case, a `MessageDeliveryException` is thrown. The `send-timeout` is ignored for `AbstractSubscribableChannel` implementations. For `group-timeout(-expression)`, the `MessageDeliveryException` from the scheduled expiring task leads this task to be rescheduled. Optional.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(9)</span> A reference to a bean that implements the message correlation (grouping) algorithm. The bean can be an implementation of the `CorrelationStrategy` interface or a POJO. In the latter case, the `correlation-strategy-method` attribute must also be defined. Optional. (By default, the aggregator uses the `IntegrationMessageHeaderAccessor.CORRELATION_ID` header.)</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(10)</span> A method that is defined on the bean referenced by `correlation-strategy` and that implements the correlation decision algorithm. Optional, with restrictions (requires `correlation-strategy` to be present).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(11)</span> A SpEL expression representing the correlation strategy. Example: `"headers['something']"`. Only one of `correlation-strategy` or `correlation-strategy-expression` is allowed.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(12)</span> A reference to a bean that implements the release strategy. The bean can be an implementation of the `ReleaseStrategy` interface or a POJO. In the latter case, the `release-strategy-method` attribute must also be defined. Optional (by default, the aggregator will use the `IntegrationMessageHeaderAccessor.SEQUENCE_SIZE` header attribute).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(13)</span> A method that is defined on the bean referenced by `release-strategy` and that implements the completion decision algorithm. Optional, with restrictions (requires `release-strategy` to be present).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(14)</span> A SpEL expression representing the release strategy. The root object for the expression is a `MessageGroup`. Example: `"size() == 5"`. Only one of `release-strategy` or `release-strategy-expression` is allowed.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(15)</span> Only applies if a `MessageGroupStoreReaper` is configured for the `<resequencer>` `MessageStore`. By default, when a `MessageGroupStoreReaper` is configured to expire partial groups, empty groups are also removed. Empty groups exist after a group is released normally. This is to enable the detection and discarding of late-arriving messages. If you wish to expire empty groups on a longer schedule than expiring partial groups, set this property. Empty groups are then not removed from the `MessageStore` until they have not been modified for at least this number of milliseconds. Note that the actual time to expire an empty group is also affected by the reaper’s timeout property, and it could be as much as this value plus the timeout.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(16)</span> See [Configuring an Aggregator with XML](https://docs.spring.io/spring-integration/docs/5.5.9/reference/html/aggregator.html#aggregator-xml).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(17)</span> See [Configuring an Aggregator with XML](https://docs.spring.io/spring-integration/docs/5.5.9/reference/html/aggregator.html#aggregator-xml).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(18)</span> See [Configuring an Aggregator with XML](https://docs.spring.io/spring-integration/docs/5.5.8/reference/html/aggregator.html#aggregator-xml).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(19)</span> See [Configuring an Aggregator with XML](https://docs.spring.io/spring-integration/docs/5.5.8/reference/html/aggregator.html#aggregator-xml).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(20)</span> By default, when a group is completed due to a timeout (or by a `MessageGroupStoreReaper`), the empty group’s metadata is retained. Late arriving messages are immediately discarded. Set this to `true` to remove the group completely. Then, late arriving messages start a new group and are not be discarded until the group again times out. The new group is never released normally because of the “hole” in the sequence range that caused the timeout. Empty groups can be expired (completely removed) later by using a `MessageGroupStoreReaper` together with the `empty-group-min-timeout` attribute. Starting with version 5.0, empty groups are also scheduled for removal after the `empty-group-min-timeout` elapses. The default is 'false'.</small>

Also see [Aggregator Expiring Groups](https://docs.spring.io/spring-integration/docs/5.5.8/reference/html/aggregator.html#aggregator-expiring-groups) for more information.

> Since there is no custom behavior to be implemented in Java classes for resequencers, there is no annotation support for it.

---

## 8.6. Message Handler Chain

The `MessageHandlerChain` is an implementation of `MessageHandler` that can be configured as a single message endpoint while actually delegating to a chain of other handlers, such as filters, transformers, splitters, and so on. When several handlers need to be connected in a fixed, linear progression, this can lead to a much simpler configuration. For example, it is fairly common to provide a transformer before other components. Similarly, when you provide a filter before some other component in a chain, you essentially create a [selective consumer](https://www.enterpriseintegrationpatterns.com/MessageSelector.html). In either case, the chain requires only a single `input-channel` and a single `output-channel`, eliminating the need to define channels for each individual component.

> The `MessageHandlerChain` is mostly designed for an XML configuration. For Java DSL, an `IntegrationFlow` definition can be treated as a chain component, but it has nothing to do with concepts and principles described in this chapter below. See [Java DSL](https://docs.spring.io/spring-integration/docs/5.5.8/reference/html/dsl.html#java-dsl) for more information.

> Spring Integration’s `Filter` provides a boolean property: `throwExceptionOnRejection`. When you provide multiple selective consumers on the same point-to-point channel with different acceptance criteria, you should set this value 'true' (the default is `false`) so that the dispatcher knows that the message was rejected and, as a result, tries to pass the message on to other subscribers. If the exception were not thrown, it would appear to the dispatcher that the message had been passed on successfully even though the filter had dropped the message to prevent further processing. If you do indeed want to “drop” the messages, the filter’s 'discard-channel' might be useful, since it does give you a chance to perform some operation with the dropped message (such as sending it to a JMS queue or writing it to a log).

The handler chain simplifies configuration while internally maintaining the same degree of loose coupling between components, and it is trivial to modify the configuration if at some point a non-linear arrangement is required.

Internally, the chain is expanded into a linear setup of the listed endpoints, separated by anonymous channels. The reply channel header is not taken into account within the chain. Only after the last handler is invoked is the resulting message forwarded to the reply channel or the chain’s output channel. Because of this setup, all handlers except the last must implement the `MessageProducer` interface (which provides a 'setOutputChannel()' method). If the `outputChannel` on the `MessageHandlerChain` is set, the last handler needs only an output channel.

> As with other endpoints, the `output-channel` is optional. If there is a reply message at the end of the chain, the output-channel takes precedence. However, if it is not available, the chain handler checks for a reply channel header on the inbound message as a fallback.

In most cases, you need not implement `MessageHandler` yourself. The next section focuses on namespace support for the chain element. Most Spring Integration endpoints, such as service activators and transformers, are suitable for use within a `MessageHandlerChain`.

### 8.6.1. Configuring a Chain

The `<chain>` element provides an `input-channel` attribute. If the last element in the chain is capable of producing reply messages (optional), it also supports an `output-channel` attribute. The sub-elements are then filters, transformers, splitters, and service-activators. The last element may also be a router or an outbound channel adapter. The following example shows a chain definition:

```xml
<int:chain input-channel="input" output-channel="output">
    <int:filter ref="someSelector" throw-exception-on-rejection="true"/>
    <int:header-enricher>
        <int:header name="thing1" value="thing2"/>
    </int:header-enricher>
    <int:service-activator ref="someService" method="someMethod"/>
</int:chain>
```

The `<header-enricher>` element used in the preceding example sets a message header named `thing1` with a value of `thing2` on the message. A header enricher is a specialization of `Transformer` that touches only header values. You could obtain the same result by implementing a `MessageHandler` that did the header modifications and wiring that as a bean, but the header-enricher is a simpler option.

The `<chain>` can be configured as the last “closed-box” consumer of the message flow. For this solution, you can to put it at the end of the <chain> some <outbound-channel-adapter>, as the following example shows:

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
  <p>Certain attributes, such as <code class="highlighter-rouge">order</code> and <code class="highlighter-rouge">input-channel</code> are not allowed to be specified on components used within a chain. The same is true for the poller sub-element.</p>
  <p>For the Spring Integration core components, the XML schema itself enforces some of these constraints. However, for non-core components or your own custom components, these constraints are enforced by the XML namespace parser, not by the XML schema.</p>
  <p>These XML namespace parser constraints were added with Spring Integration 2.2. If you try to use disallowed attributes and elements, the XML namespace parser throws a <code class="highlighter-rouge">BeanDefinitionParsingException</code>.</p>
</blockquote>

### 8.6.2. Using the 'id' Attribute

Beginning with Spring Integration 3.0, if a chain element is given an `id` attribute, the bean name for the element is a combination of the chain’s `id` and the `id` of the element itself. Elements without `id` attributes are not registered as beans, but each one is given a `componentName` that includes the chain `id`. Consider the following example:

```xml
<int:chain id="somethingChain" input-channel="input">
    <int:service-activator id="somethingService" ref="someService" method="someMethod"/>
    <int:object-to-json-transformer/>
</int:chain>
```

In the preceding example:

- The `<chain>` root element has an `id` of 'somethingChain'. Consequently, the `AbstractEndpoint` implementation (`PollingConsumer` or `EventDrivenConsumer`, depending on the `input-channel` type) bean takes this value as its bean name.
- The `MessageHandlerChain` bean acquires a bean alias ('somethingChain.handler'), which allows direct access to this bean from the `BeanFactory`.
- The `<service-activator>` is not a fully fledged messaging endpoint (it is not a `PollingConsumer` or `EventDrivenConsumer`). It is a `MessageHandler` within the `<chain>`. In this case, the bean name registered with the `BeanFactory` is 'somethingChain$child.somethingService.handler'.
- The `componentName` of this `ServiceActivatingHandler` takes the same value but without the '.handler' suffix. It becomes 'somethingChain$child.somethingService'.
- The last `<chain>` sub-component, `<object-to-json-transformer>`, does not have an `id` attribute. Its `componentName` is based on its position in the `<chain>`. In this case, it is 'somethingChain$child#1'. (The final element of the name is the order within the chain, beginning with '#0'). Note, this transformer is not registered as a bean within the application context, so it does not get a `beanName`. However its `componentName` has a value that is useful for logging and other purposes.

The `id` attribute for `<chain>` elements lets them be eligible for [JMX export](https://docs.spring.io/spring-integration/docs/5.5.8/reference/html/jmx.html#jmx-mbean-exporter), and they are trackable in the [message history](https://docs.spring.io/spring-integration/docs/5.5.8/reference/html/message-history.html#message-history). You can access them from the `BeanFactory` by using the appropriate bean name, as discussed earlier.

> It is useful to provide an explicit `id` attribute on `<chain>` elements to simplify the identification of sub-components in logs and to provide access to them from the `BeanFactory` etc.

### 8.6.3. Calling a Chain from within a Chain

Sometimes, you need to make a nested call to another chain from within a chain and then come back and continue execution within the original chain. To accomplish this, you can use a messaging gateway by including a <gateway> element, as the following example shows:

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

In the preceding example, `nested-chain-a` is called at the end of `main-chain` processing by the 'gateway' element configured there. While in `nested-chain-a`, a call to a `nested-chain-b` is made after header enrichment. Then the flow comes back to finish execution in `nested-chain-b`. Finally, the flow returns to `main-chain`. When the nested version of a `<gateway>` element is defined in the chain, it does not require the `service-interface` attribute. Instead, it takes the message in its current state and places it on the channel defined in the `request-channel` attribute. When the downstream flow initiated by that gateway completes, a `Message` is returned to the gateway and continues its journey within the current chain.

---

## 8.7. Scatter-Gather

Starting with version 4.1, Spring Integration provides an implementation of the [scatter-gather](https://www.enterpriseintegrationpatterns.com/BroadcastAggregate.html) enterprise integration pattern. It is a compound endpoint for which the goal is to send a message to the recipients and aggregate the results. As noted in [*Enterprise Integration Patterns*](https://www.enterpriseintegrationpatterns.com/), it is a component for scenarios such as “best quote”, where we need to request information from several suppliers and decide which one provides us with the best term for the requested item.

Previously, the pattern could be configured by using discrete components. This enhancement brings more convenient configuration.

The `ScatterGatherHandler` is a request-reply endpoint that combines a `PublishSubscribeChannel` (or a `RecipientListRouter`) and an `AggregatingMessageHandler`. The request message is sent to the `scatter` channel, and the `ScatterGatherHandler` waits for the reply that the aggregator sends to the `outputChannel`.

### 8.7.1. Functionality

The `Scatter-Gather` pattern suggests two scenarios: “auction” and “distribution”. In both cases, the `aggregation` function is the same and provides all the options available for the `AggregatingMessageHandler`. (Actually, the `ScatterGatherHandler` requires only an `AggregatingMessageHandler` as a constructor argument.) See [Aggregator](https://docs.spring.io/spring-integration/docs/5.5.8/reference/html/aggregator.html#aggregator) for more information.

#### Auction

The auction `Scatter-Gather` variant uses “publish-subscribe” logic for the request message, where the “scatter” channel is a `PublishSubscribeChannel` with `apply-sequence="true"`. However, this channel can be any `MessageChannel` implementation (as is the case with the `request-channel` in the `ContentEnricher` — see [Content Enricher](https://docs.spring.io/spring-integration/docs/5.5.8/reference/html/content-enrichment.html#content-enricher)). However, in this case, you should create your own custom `correlationStrategy` for the `aggregation` function.

#### Distribution

The distribution `Scatter-Gather` variant is based on the `RecipientListRouter` (see [`RecipientListRouter`](https://docs.spring.io/spring-integration/docs/5.5.8/reference/html/router.html#router-implementations-recipientlistrouter)) with all available options for the `RecipientListRouter`. This is the second `ScatterGatherHandler` constructor argument. If you want to rely on only the default `correlationStrategy` for the `recipient-list-router` and the `aggregator`, you should specify `apply-sequence="true"`. Otherwise, you should supply a custom `correlationStrategy` for the `aggregator`. Unlike the `PublishSubscribeChannel` variant (the auction variant), having a `recipient-list-router` `selector` option lets filter target suppliers based on the message. With `apply-sequence="true"`, the default `sequenceSize` is supplied, and the `aggregator` can release the group correctly. The distribution option is mutually exclusive with the auction option.

For both the auction and the distribution variants, the request (scatter) message is enriched with the `gatherResultChannel` header to wait for a reply message from the `aggregator`.

By default, all suppliers should send their result to the `replyChannel` header (usually by omitting the `output-channel` from the ultimate endpoint). However, the `gatherChannel` option is also provided, letting suppliers send their reply to that channel for the aggregation.

### 8.7.2. Configuring a Scatter-Gather Endpoint

The following example shows Java configuration for the bean definition for `Scatter-Gather`:

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

In the preceding example, we configure the `RecipientListRouter` `distributor` bean with `applySequence="true"` and the list of recipient channels. The next bean is for an `AggregatingMessageHandler`. Finally, we inject both those beans into the `ScatterGatherHandler` bean definition and mark it as a `@ServiceActivator` to wire the scatter-gather component into the integration flow.

The following example shows how to configure the `<scatter-gather>` endpoint by using the XML namespace:

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
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> The id of the endpoint. The `ScatterGatherHandler` bean is registered with an alias of `id + '.handler'`. The `RecipientListRouter` bean is registered with an alias of `id + '.scatterer'`. The `AggregatingMessageHandler`bean is registered with an alias of `id + '.gatherer'`. Optional. (The `BeanFactory` generates a default `id` value.)</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> Lifecycle attribute signaling whether the endpoint should be started during application context initialization. In addition, the `ScatterGatherHandler` also implements `Lifecycle` and starts and stops `gatherEndpoint`, which is created internally if a `gather-channel` is provided. Optional. (The default is `true`.)</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> The channel on which to receive request messages to handle them in the `ScatterGatherHandler`. Required.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> The channel to which the `ScatterGatherHandler` sends the aggregation results. Optional. (Incoming messages can specify a reply channel themselves in the `replyChannel` message header).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> The channel to which to send the scatter message for the auction scenario. Optional. Mutually exclusive with the `<scatterer>` sub-element.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(6)</span> The channel on which to receive replies from each supplier for the aggregation. It is used as the `replyChannel` header in the scatter message. Optional. By default, the `FixedSubscriberChannel` is created.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(7)</span> The order of this component when more than one handler is subscribed to the same `DirectChannel` (use for load balancing purposes). Optional.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(8)</span> Specifies the phase in which the endpoint should be started and stopped. The startup order proceeds from lowest to highest, and the shutdown order is from highest to lowest. By default, this value is `Integer.MAX_VALUE`, meaning that this container starts as late as possible and stops as soon as possible. Optional.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(9)</span> The timeout interval to wait when sending a reply `Message` to the `output-channel`. By default, the send blocks for one second. It applies only if the output channel has some 'sending' limitations — for example, a `QueueChannel` with a fixed 'capacity' that is full. In this case, a `MessageDeliveryException` is thrown. The `send-timeout` is ignored for `AbstractSubscribableChannel` implementations. For `group-timeout(-expression)`, the `MessageDeliveryException` from the scheduled expire task leads this task to be rescheduled. Optional.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(10)</span> Lets you specify how long the scatter-gather waits for the reply message before returning. By default, it waits indefinitely. 'null' is returned if the reply times out. Optional. It defaults to `-1`, meaning to wait indefinitely.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(11)</span> Specifies whether the scatter-gather must return a non-null value. This value is `true` by default. Consequently, a `ReplyRequiredException` is thrown when the underlying aggregator returns a null value after `gather-timeout`. Note, if `null` is a possibility, the `gather-timeout` should be specified to avoid an indefinite wait.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(12)</span> The `<recipient-list-router>` options. Optional. Mutually exclusive with `scatter-channel` attribute.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(13)</span> The `<aggregator>` options. Required.</small>

### 8.7.3. Error Handling

Since Scatter-Gather is a multi request-reply component, error handling has some extra complexity. In some cases, it is better to just catch and ignore downstream exceptions if the `ReleaseStrategy` allows the process to finish with fewer replies than requests. In other cases something like a “compensation message” should be considered for returning from sub-flow, when an error happens.

Every async sub-flow should be configured with a `errorChannel` header for the proper error message sending from the `MessagePublishingErrorHandler`. Otherwise, an error will be sent to the global `errorChannel` with the common error handling logic. See [Error Handling](https://docs.spring.io/spring-integration/docs/5.5.8/reference/html/error-handling.html#error-handling) for more information about async error processing.

Synchronous flows may use an `ExpressionEvaluatingRequestHandlerAdvice` for ignoring the exception or returning a compensation message. When an exception is thrown from one of the sub-flows to the `ScatterGatherHandler`, it is just re-thrown to upstream. This way all other sub-flows will work for nothing and their replies are going to be ignored in the `ScatterGatherHandler`. This might be an expected behavior sometimes, but in most cases it would be better to handle the error in the particular sub-flow without impacting all others and the expectations in the gatherer.

Starting with version 5.1.3, the `ScatterGatherHandler` is supplied with the `errorChannelName` option. It is populated to the `errorChannel` header of the scatter message and is used in the when async error happens or can be used in the regular synchronous sub-flow for directly sending an error message.

The sample configuration below demonstrates async error handling by returning a compensation message:

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

To produce a proper reply, we have to copy headers (including `replyChannel` and `errorChannel`) from the `failedMessage` of the `MessagingException` that has been sent to the `scatterGatherErrorChannel` by the `MessagePublishingErrorHandler`. This way the target exception is returned to the gatherer of the `ScatterGatherHandler` for reply messages group completion. Such an exception `payload` can be filtered out in the `MessageGroupProcessor` of the gatherer or processed other way downstream, after the scatter-gather endpoint.

> Before sending scattering results to the gatherer, `ScatterGatherHandler` reinstates the request message headers, including reply and error channels if any. This way errors from the `AggregatingMessageHandler` are going to be propagated to the caller, even if an async hand off is applied in scatter recipient subflows. For successful operation, a `gatherResultChannel`, `originalReplyChannel` and `originalErrorChannel` headers must be transferred back to replies from scatter recipient subflows. In this case a reasonable, finite `gatherTimeout` must be configured for the `ScatterGatherHandler`. Otherwise it is going to be blocked waiting for a reply from the gatherer forever, by default.

---

## 8.8. Thread Barrier

Sometimes, we need to suspend a message flow thread until some other asynchronous event occurs. For example, consider an HTTP request that publishes a message to RabbitMQ. We might wish to not reply to the user until the RabbitMQ broker has issued an acknowledgment that the message was received.

In version 4.2, Spring Integration introduced the `<barrier/>` component for this purpose. The underlying `MessageHandler` is the `BarrierMessageHandler`. This class also implements `MessageTriggerAction`, in which a message passed to the `trigger()` method releases a corresponding thread in the `handleRequestMessage()` method (if present).

The suspended thread and trigger thread are correlated by invoking a `CorrelationStrategy` on the messages. When a message is sent to the `input-channel`, the thread is suspended for up to `requestTimeout` milliseconds, waiting for a corresponding trigger message. The default correlation strategy uses the `IntegrationMessageHeaderAccessor.CORRELATION_ID` header. When a trigger message arrives with the same correlation, the thread is released. The message sent to the `output-channel` after release is constructed by using a `MessageGroupProcessor`. By default, the message is a `Collection<?>` of the two payloads, and the headers are merged by using a `DefaultAggregatingMessageGroupProcessor`.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>If the <code class="highlighter-rouge">trigger()</code> method is invoked first (or after the main thread times out), it is suspended for up to <code class="highlighter-rouge">triggerTimeout</code> waiting for the suspending message to arrive. If you do not want to suspend the trigger thread, consider handing off to a <code class="highlighter-rouge">TaskExecutor</code> instead so that its thread is suspended instead.</p>
</blockquote>

> Prior version 5.4, there was only one `timeout` option for both request and trigger messages, but in some use-case it is better to have different timeouts for those actions. Therefore `requestTimeout` and `triggerTimeout` options have been introduced.

The `requires-reply` property determines the action to take if the suspended thread times out before the trigger message arrives. By default, it is `false`, which means the endpoint returns `null`, the flow ends, and the thread returns to the caller. When `true`, a `ReplyRequiredException` is thrown.

You can call the `trigger()` method programmatically (obtain the bean reference by using the name, `barrier.handler` — where `barrier` is the bean name of the barrier endpoint). Alternatively, you can configure an `<outbound-channel-adapter/>` to trigger the release.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>Only one thread can be suspended with the same correlation. The same correlation can be used multiple times but only once concurrently. An exception is thrown if a second thread arrives with the same correlation.</p>
</blockquote>

The following example shows how to use a custom header for correlation:

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

Depending on which one has a message arrive first, either the thread sending a message to `in` or the thread sending a message to `release` waits for up to ten seconds until the other message arrives. When the message is released, the `out` channel is sent a message that combines the result of invoking the custom `MessageGroupProcessor` bean, named `myOutputProcessor`. If the main thread times out and a trigger arrives later, you can configure a discard channel to which the late trigger is sent.

For an example of this component, see the [barrier sample application](https://github.com/spring-projects/spring-integration-samples/tree/main/basic/barrier).