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

특정 커스텀 라우터 구현체를 다른 `<router>` 정의에서도 참조할 수 있다면 보통 `ref` 속성을 사용하는 것이 좋다. 하지만 커스텀 라우터 구현체의 스코프를 하나의 `<router>` 정의 내로 한정하고 싶다면, 아래 예제와 같이 내부 빈 정의를 제공해도 된다:

```xml
<int:router method="someMethod" input-channel="input3"
            default-output-channel="defaultOutput3">
    <beans:bean class="org.foo.MyCustomRouter"/>
</int:router>
```

> 동일한 `<router>` 설정에서 `ref` 속성과 내부 핸들러 정의를 둘 다 사용하는 것은 허용하지 않는다. 둘 다 사용하면 모호한 조건이 만들어져 예외가 발생한다.

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

꼭 페이로드를 기반으로 라우팅하지 않고, 메시지 헤더 안에 있는 프로퍼티나 attribute 등의 메타데이터를 기반으로도 라우팅할 수 있다. 헤더를 활용할 땐 `@Router`를 달아준 메소드에 `@Header`를 선언한 파라미터를 추가할 수 있다. 아래 예제에서 확인할 수 있듯이, 이 파라미터에는 헤더의 값이 매핑된다. 자세한 내용은 [어노테이션 지원](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/configuration.html#annotations)에서 설명하고 있다:

```java
@Router
public List<String> route(@Header("orderStatus") OrderStatus status)
```

> XPath 지원을 포함해서, XML 기반 메시지 라우팅에 대해 알아보려면 [XML 지원 - XML 페이로드 처리하기](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/xml.html#xml)를 참고해라.

라우터 설정을 좀더 자세히 알아보려면 Java DSL 챕터에 있는 [메시지 라우터](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/dsl.html#java-dsl-routers)를 함께 읽어봐라.

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

`channelMapping`은 `AbstractMappingMessageRouter` 단에서 정의되기 때문에 , `AbstractMappingMessageRouter`를 상속한 라우터는 전부 다이나믹 라우터다 (프레임워크에서 정의하는 대부분의 라우터도 포함해서). 이 맵의 setter 메소드는 public으로 노출돼있으며, 'setChannelMapping', 'removeChannelMapping' 메소드도 함께 제공한다. 따라서 라우터 자체에 대한 참조만 가지고 있다면 이 메소드들을 이용해 런타임에 라우터 매핑을 변경, 추가, 제거할 수 있다. JMX([JMX 지원](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/jmx.html#jmx) 참고)나 Spring Integration 컨트롤 버스([컨트롤 버스](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/control-bus.html#control-bus) 참고) 기능을 통해서도 같은 설정 옵션을 제공할 수 있다는 뜻이기도 하다.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>채널 이름의 폴백으로 채널 키를 활용하면 간편하면서도 유연하게 대응할 수 있다. 그러나 메시지 생성자를 신뢰할 수 없는 상황이라면, 시스템을 잘 아는 누군가가 악의적으로 메시지를 생성해 예상치 못한 채널로 라우팅시킬 수도 있다. 예를 들어 키가 라우터의 입력 채널 이름으로 설정돼 있다면, 이런 메시지는 해당 라우터로 다시 라우팅되며, 종국엔 스택 오버플로 에러를 일으킨다. 따라서 이 기능은 비활성화하고 (<code class="highlighter-rouge">channelKeyFallback</code> 속성을 <code class="highlighter-rouge">false</code>로 설정) 필요한 경우 매핑 정보를 변경해야 할 수도 있다.</p>
</blockquote>

#### Manage Router Mappings using the Control Bus

라우터 매핑을 관리하는 방법 중에는 [컨트롤 버스](https://www.enterpriseintegrationpatterns.com/ControlBus.html) 패턴을 이용하는 방법이 있다. 이 패턴은 컨트롤 채널이라는 별도 채널로 메시지를 전송해 라우터를 포함한 Spring Integration 구성 요소들을 관리하고 모니터링한다.

> 컨트롤 버스에 관한 자세한 내용은 [컨트롤 버스](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/control-bus.html#control-bus)를 읽어봐라.

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

> 스프링이 제공하는 JMX 관련 기능은 [JMX 지원](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/jmx.html#jmx)을 읽어봐라.

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
  <p>라우팅 슬립이 분산 환경과 연계된다면 라우팅 슬립 <code class="highlighter-rouge">path</code>에 인라인 표현식은 사용하지 않는 게 좋다. 이는 메시지 브로커(<a href="https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/amqp.html#amqp">AMQP 지원</a> 또는 <a href="https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/jms.html#jms">JMS 지원</a>)를 통해 <code class="highlighter-rouge">request-reply</code>를 주고받거나, 인티그레이션 플로우에서 영구<sup>persistent</sup> <code class="highlighter-rouge">MessageStore</code>(<a href="https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/message-store.html#message-store">메시지 스토어</a>)를 사용하는 교차 JVM 애플리케이션과 같은 분산 환경에서도 마찬가지다. 프레임워크는 <code class="highlighter-rouge">RoutingSlipHeaderValueMessageProcessor</code>를 사용해 <code class="highlighter-rouge">path</code> 값을 <code class="highlighter-rouge">ExpressionEvaluatingRoutingSlipRouteStrategy</code> 객체로 변환하며, 이 객체는 메시지 헤더 <code class="highlighter-rouge">routingSlip</code>에 채워진다. 이 클래스는 <code class="highlighter-rouge">Serializable</code>이 아니기 때문에 (<code class="highlighter-rouge">BeanFactory</code>에 의존하기 때문에 불가능하다), 전체 <code class="highlighter-rouge">Message</code> 역시 직렬화가 불가능하며, 모든 분산 작업에서 <code class="highlighter-rouge">NotSerializableException</code>을 만나게 된다. 따라서, 적합한 SpEL을 이용해 <code class="highlighter-rouge">ExpressionEvaluatingRoutingSlipRouteStrategy</code> 빈을 등록하고, 라우팅 슬립 <code class="highlighter-rouge">path</code> 설정에선 이 빈 이름을 사용해라.</p>
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

[필터에 어드바이스 체인 적용하기](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/index-single.html#advising-filters)도 함께 참고해라.

> 일반적으로 메시지 필터는 publish-subscribe 채널과 함께 사용한다. 같은 채널을 다양한 필터 엔드포인트가 구독할 수 있으며, 필터를 통해 다음 엔드포인트로 메시지를 전달할지를 결정하게 된다. 다음 엔드포인트는 지원하는 타입이라면 무엇이든 될 수 있다 (ex. 서비스 activator). point-to-point 입력 채널 하나와 여러 가지 출력 채널을 사용하는 메시지 라우터에선 메시지를 전송할 채널을 사전에 세팅해 놓는다면, 메시지 필터는 그대신 다양한 구독자별로 대응을 추가해나가는 방안이다.

커스텀 필터 구현체를 다른 `<filter>` 정의에서도 참조할 수 있다면 `ref` 속성을 사용하길 권장한다. 반대로 커스텀 필터 구현체의 스코프가 단일 `<filter>` 요소로 한정된다면, 다음 예제와 같이 내부 빈 정의를 이용하는 게 좋다:

```xml
<int:filter method="someMethod" input-channel="inChannel" output-channel="outChannel">
  <beans:bean class="org.foo.MyCustomFilter"/>
</filter>
```

> 동일한 `<filter>` 설정에서 `ref` 속성과 내부 핸들러 정의를 둘 다 사용하는 것은 허용하지 않는다. 둘 다 사용하면 모호한 조건이 만들어져 예외가 발생한다.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p><code class="highlighter-rouge">ref</code> 속성으로 <code class="highlighter-rouge">MessageFilter</code>를 상속한 빈을 참조하는 경우 (프레임워크에서 자체적으로 제공하는 필터들처럼), 출력 채널을 필터 빈에 직접 주입하는 식으로 최적화된다. 이때는 각 <code class="highlighter-rouge">ref</code> 속성마다 별도 빈 인스턴스(또는 <code class="highlighter-rouge">prototype</code> 스코프 빈)을 참조하거나, 내부 <code class="highlighter-rouge">&lt;bean/&gt;</code> 설정을 이용해야 한다. 단, 여기서 말하는 최적화는 필터 XML 정의에 특정 필터 전용 속성을 제공하지 않았을 때에만 적용된다. 무심코 여러 빈에서 동일한 메시지 핸들러를 참조하면 설정 예외를 만나게될 거다.</p>
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

[어노테이션을 이용해 엔드포인트에 어드바이스 체인 적용하기](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/handler-advice.html#advising-with-annotations)도 함께 참고해라.

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

> 동일한 `<int:splitter>` 설정에서 `ref` 속성과 내부 핸들러 정의를 둘 다 사용하는 것은 허용하지 않는다. 둘 다 사용하면 모호한 조건이 만들어져 예외가 발생한다.

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

[어노테이션을 이용해 엔드포인트에 어드바이스 체인 적용하기](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/handler-advice.html#advising-with-annotations), [splitter](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/dsl.html#java-dsl-splitters), [파일 splitter](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/file.html#file-splitter)도 함께 참고해라.

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

4.3 릴리즈에선 `SimpleMessageGroup`에 메시지들을 담는 디폴트 `Collection`을 `HashSet`으로 변경했다. 전에는 `BlockingQueue`를 사용했는데, 규모가 큰 그룹에선 개별 메시지들을 제거하는 비용이 상당했다 (O(n)에 해당하는 선형 탐색이 필요했다). 해시 셋은 일반적으로 제거 연산이 훨씬 빠르긴 하지만, 삽입과 제거 연산 모두 해시 값을 계산해야 하기 때문에 대용량 메시지라면 역시 비용이 커질 수 있다. 메시지에서 해시 값을 계산해내는 비용이 크다면 다른 컬렉션 타입을 고려해봐야 한다. [`MessageGroupFactory` 사용하기](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/message-store.html#message-group-factory)에서도 설명하지만, `SimpleMessageGroupFactory`라는 구현체를 제공하므로 요구사항에 가장 잘맞는 `Collection`을 선택해주면 된다. 아니면 자체 팩토리 구현체를 제공해서 다른 `Collection<Message<?>>`를 생성하는 것도 가능하다.

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

Java DSL을 이용해 aggregator를 설정하는 방법은 [Aggregators and Resequencers](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/dsl.html#java-dsl-aggregators)를 참고해라.

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
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 애플리케이션 컨텍스트를 기동하면서 aggregator를 시작해야 하는지 여부를 나타내는 라이프사이클 관련 속성이다. 생략할 수 있다 (디폴트는 'true').</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> aggregator가 메시지를 받아올 채널. 필수 값이다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> aggregator가 집계 결과를 전송할 채널. 생략할 수 있다 (수신한 메시지 자체의 헤더 'replyChannel'에 응답 채널이 지정돼 있을 수도 있기 때문).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> aggregator가 타임아웃된 메시지들을 전송할 채널 (`send-partial-result-on-expiry`가 `false`인 경우에). 생략할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(6)</span> 메시지 그룹이 완성될 때까지 correlation 키 아래 메시지들을 저장하는 `MessageGroupStore`에 대한 참조. 생략할 수 있다. 기본적으로 휘발성의 인메모리 저장소를 사용한다. 자세한 내용은 [메시지 스토어](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/message-store.html#message-store)를 참고해라.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(7)</span> 둘 이상의 핸들러가 동일한 `DirectChannel`을 구독하는 경우 참고하는 이 aggregator의 순서 (로드 밸런싱 목적으로 사용). 생략할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(8)</span> 메시지들을 담고있는 `MessageGroup`이 만료되면 해당 메시지들을 집계해 'output-channel'이나 'replyChannel'로 보내야 하는지를 나타낸다 ([`MessageGroupStore.expireMessageGroups(long)`](https://docs.spring.io/spring-integration/api/org/springframework/integration/store/MessageGroupStore.html#expireMessageGroups-long) 참고). `MessageGroup`을 만료시키는 방법으로는 `MessageGroupStoreReaper`를 설정하는 방법이 있다. 하지만 이 방법 대신 `MessageGroupStore.expireMessageGroups(timeout)`를 호출해도 `MessageGroup`을 만료시킬 수 있다. Control Bus를 통해도 되고, `MessageGroupStore` 인스턴스에 대한 참조를 가지고 있다면 `expireMessageGroups(timeout)`를 호출하면 된다. `MessageGroup`이 만료되지 않는다면 이 속성만으로는 아무런 일도 일어나지 않는다. 곧 만료되는 `MessageGroup`에 아직 남아 있는 메시지들을 전부 버릴지 출력 또는 응답 채널로 보낼지를 나타내는 단순한 지표라고 볼 수 있다. 이 속성은 생략할 수 있다 (디폴트는 `false`). 참고로, `expire-groups-upon-timeout`을 `false`로 설정한 경우 그룹이 실제로 만료되지 않을 수 있으므로 `send-partial-result-on-timeout`이라고 부르는 게 더 적합하다고 볼 수도 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(9)</span> 응답 `Message`를 `output-channel` 또는 `discard-channel`로 전송할 때 대기하는 타임아웃 간격. 기본값은 `-1`로 무한으로 블로킹된다. 고정 'capacity'를 사용하는 `QueueChannel`같이, '전송'에 제한이 있는 출력 채널을 사용할 때만 적용된다. 타임아웃이 발생하면 `MessageDeliveryException`을 던진다. `AbstractSubscribableChannel`의 구현체들은 `send-timeout`을 무시한다. `group-timeout(-expression)`의 경우 예약된 expire 태스크에서 `MessageDeliveryException`이 발생하면 해당 태스크를 다시 스케줄링한다. 생략할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(10)</span> 메시지 correlation (grouping) 알고리즘을 구현한 빈에 대한 참조. 이 빈은 `CorrelationStrategy` 인터페이스의 구현체일 수도, POJO일 수도 있다. 후자라면 `correlation-strategy-method` 속성도 반드시 함께 정의해야 한다. 생략할 수 있다 (aggregator는 기본적으로 `IntegrationMessageHeaderAccessor.CORRELATION_ID` 헤더를 사용한다).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(11)</span> `correlation-strategy`가 참조하는 빈에 정의돼있는 메소드. 이 메소드에서 correlation 결정 알고리즘을 구현한다. 생략할 수 있으며, 제약이 존재한다 (`correlation-strategy`를 반드시 정의해야 한다).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(12)</span> correlation 전략을 나타내는 SpEL 표현식 (ex. `"headers['something']"`). `correlation-strategy`나 `correlation-strategy-expression` 둘 중 하나만 사용할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(13)</span> 애플리케이션 컨텍스트에 정의돼있는 빈에 대한 참조. 이 빈은 앞에서 설명했듯이 반드시 집계 로직을 구현해야 한다. 생략할 수 있다 (기본적으론 집계한 메시지들의 리스트를 출력 메시지의 페이로드로 활용한다).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(14)</span> `ref` 속성으로 참조하는 빈에 정의돼있는 메소드. 이 메소드에서 메시지 집계 알고리즘을 구현한다. 생략할 수 있다 (`ref` 속성을 정의했는지에 따라 다르다).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(15)</span> release 전략을 구현한 빈에 대한 참조. 이 빈은 `ReleaseStrategy` 인터페이스의 구현체일 수도, POJO일 수도 있다. 후자라면 `release-strategy-method` 속성도 반드시 함께 정의해야 한다. 생략할 수 있다 (aggregator는 기본적으로 `IntegrationMessageHeaderAccessor.SEQUENCE_SIZE` 헤더를 사용한다).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(16)</span> `release-strategy` 속성이 참조하는 빈에 정의돼있는 메소드. 이 메소드에서 completion 결정 알고리즘을 구현한다. 생략할 수 있으며, 제약이 존재한다 (`release-strategy`를 반드시 정의해야 한다).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(17)</span> release 전략을 나타내는 SpEL 표현식 (ex. `"size() == 5"`). 표현식의 루트 객체는 `MessageGroup`이다. `release-strategy`나 `release-strategy-expression` 둘 중 하나만 사용할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(18)</span> `true`로 설정하면 (디폴트는 `false`다) 완료된 그룹은 메시지 스토어에서 제거되며, 이후 correlation이 같은 메시지가 도착하면 새 그룹을 만들게된다. 기본 동작에선 완료된 그룹과 동일한 correlation을 가진 메시지들은 `discard-channel`로 전송된다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(19)</span> `<aggregator>`의 `MessageStore`에 `MessageGroupStoreReaper`를 설정했을 때만 적용된다. `MessageGroupStoreReaper`가 그룹을 부분적으로 만료하도록 설정돼있다면 기본적으로 비어있는 그룹 역시 제거한다. 빈 그룹은 그룹이 정상적으로 release된 후에 존재하는데, 덕분에 늦게 도착하는 메시지들을 감지하고 폐기할 수 있다. 그룹을 부분적으로 만료시키는 것보다 더 긴 주기로 빈 그룹을 만료시키고 싶다면 이 속성을 설정해라. 비어있는 그룹들은 최소한 이 밀리세컨드 동안 수정되지 않는다면 `MessageStore`에서 제거되지 않을 거다. 빈 그룹이 실제로 만료되는 시간은 reaper의 `timeout` 속성에도 영향을 받으며, 이 값에 타임아웃을 더한 시간만큼 걸릴 수도 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(20)</span> `org.springframework.integration.util.LockRegistry` 빈에 대한 참조. `groupId`를 기반으로 `Lock`을 획득하는데 사용한다. 덕분에 같은 `MessageGroup`에 동시에 접근하는 상황을 대응할 수 있다. 기본적으론 내부 `DefaultLockRegistry`를 사용한다. `ZookeeperLockRegistry`같은 분산 `LockRegistry`를 사용하면 특정 그룹에선 동시에 하나의 aggregator 인스턴스만이 작업할 수 있다. 자세한 내용은 [Redis Lock Registry](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/redis.html#redis-lock-registry), [Gemfire Lock Registry](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/gemfire.html#gemfire-lock-registry), [Zookeeper Lock Registry](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/zookeeper.html#zk-lock-registry)를 참고해라.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(21)</span> 현재 메시지가 도착했을 때 `ReleaseStrategy`가 그룹을 release하지 않으면 `MessageGroup`을 강제로 완료 상태로 만드는 타임아웃 (밀리세컨드 단위). 이 속성 덕분에 aggregator에 시간 기반 릴리즈 전략이 하나 내장된다고 볼 수 있다. `MessageGroup`에 마지막으로 메시지가 도착한 이후 타임아웃 기간 동안 새 메시지가 도착하지 않는 경우, 부분적인 결과를 내보내야 할 때 (혹은 그룹을 폐기해야 할 때) 활용할 수 있다. `MessageGroup`이 생성된 시점부터 타임아웃을 계산하고 싶다면 `group-timeout-expression` 속성을 검토해봐라. aggregator에 메시지가 새로 도착하면 해당 `MessageGroup`에 예약돼있는 기존 `ScheduledFuture<?>`는 모두 취소된다. `ReleaseStrategy`가 `false`를 반환하고 (release하지 않음을 의미) `groupTimeout > 0`이라면, 그룹을 만료시키는 태스크를 새로 예약한다. 이 속성을 0이나 음수 값으로 설정하는 것은 권하지 않는다. 이렇게 되면 모든 메시지 그룹이 즉시 완료되기 때문에 사실상 aggregator를 비활성화하는 거나 마찬가지다. 하지만 표현식을 사용하면 조건부로 0이나 음수로 설정할 수 있다. 자세한 내용은 `group-timeout-expression`을 참고해라. 그룹을 완료 상태로 만들면서 하는 일들은 `ReleaseStrategy`와 `send-partial-group-on-expiry` 속성에 따라 달라진다. 자세한 내용은 [Aggregator와 그룹 타임아웃](#aggregator-and-group-timeout)을 참고해라. 이 속성은 `group-timeout-expression`과 함께 사용할 수 없다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(22)</span> `groupTimeout`으로 평가되는 SpEL 표현식. `#root` 평가 컨텍스트 객체로 `MessageGroup`을 사용한다. 이 속성을 이용하면 `MessageGroup`을 강제로 완료 상태로 만드는 태스크를 예약할 수 있다. 표현식이 `null`로 평가되면 태스크를 예약하지 않는다. 0으로 평가되면 해당 그룹은 현재 스레드에서 즉시 완료된다. 사실상 이 속성은 `group-timeout`을 동적으로 만들어준다고 볼 수 있다. 예를 들어 그룹이 만들어지고 나서 10초가 지나면 `MessageGroup`을 강제로 완료시키고 싶다면, 이 SpEL 표현식을 검토해볼 수 있다: `timestamp + 10000 - T(System).currentTimeMillis()`. `MessageGroup`이 `#root` 평가 컨텍스트 객체이므로, 여기서 `timestamp`는 `MessageGroup.getTimestamp()`로 제공된다. 하지만 그룹의 생성 시각은 다른 그룹 만료 속성들을 어떻게 설정했는지에 따라, 메시지가 처음 도착한 시간과는 다를 수 있다는 사실을 명심해라. 자세한 내용은 `group-timeout`를 참고해라. `group-timeout` 속성과는 함께 사용할 수 없다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(23)</span> 타임아웃으로 인해 (또는 `MessageGroupStoreReaper`로 인해) 그룹이 완료되면 기본적으로 해당 그룹은 만료된다 (완전히 제거된다). 이후 도착하는 메시지들은 새 그룹을 만들게 된다. 이 속성을 `false`로 설정하면 그룹을 완료하되 메타데이터는 남겨둘 수 있어 늦게 도착한 메시지들을 폐기할 수 있다. 빈 그룹은 `empty-group-min-timeout` 속성과 `MessageGroupStoreReaper`를 함께 사용하면 이후 만료시킬 수 있다. 기본값은 `true`다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(24)</span> `TaskScheduler` 빈에 참조. `MessageGroup`에 `groupTimeout` 내에 새 메시지가 도착하지 않으면 `MessageGroup`을 강제로 완료시키는 태스크를 예약할 때 사용한다. 따로 지정하지 않으면 `ApplicationContext`에 등록돼있는 기본 스케줄러 `taskScheduler`(`ThreadPoolTaskScheduler`)를 사용한다. 이 속성은 `group-timeout`이나 `group-timeout-expression`을 지정하지 않았다면 적용되지 않는다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(25)</span> 4.1 버전부터 지원. `forceComplete` 작업을 위해 트랜잭션을 시작할 수 있다. `forceComplete` 작업은  `group-timeout(-expression)`이나 `MessageGroupStoreReaper`에 의해 시작되며, 일반적인 `add`, `release`, `discard` 작업에는 적용되지 않는다. 하위 요소는 이 요소와 `<expire-advice-chain/>`만 허용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(26)</span> *4.1 버전*부터 지원. `forceComplete` 작업에 원하는 `Advice`를 설정할 수 있다. `forceComplete` 작업은 `group-timeout(-expression)`이나 `MessageGroupStoreReaper`에 의해 시작되며, 일반적인 `add`, `release`, `discard` 작업에는 적용되지 않는다. 하위 요소는 이 요소나 `<expire-transactional/>`만 허용한다. Spring `tx` 네임스페이스를 사용하면 이곳에 트랜잭션 `Advice`를 구성할 수도 있다.</small>

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p><strong>Expiring Groups</strong></p>
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

> 동일한 `<aggregator>` 설정에서 `ref` 속성과 내부 빈 정의를 둘 다 사용하는 것은 허용하지 않는다. 둘 다 사용하면 모호한 조건이 만들어져 예외가 발생한다.

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

이 예제에선 `release-strategy-expression`에 정의된 대로, aggregator가 시퀀스 내 마지막 메시지를 수신하면 정상적인 release가 가능하다. release를 유발해줄 메시지가 도착하지 않을 때는, 그룹에 메시지가 최소 두 개 들어있기만 한다면 `groupTimeout`이 10초 뒤 그룹을 강제로 완료 상태로 바꾼다.

그룹을 강제로 완료한 뒤의 결과는 `ReleaseStrategy`와 `send-partial-result-on-expiry`에 따라 달라진다. 먼저 release 전략을 다시 호출해 정상적인 release가 가능한지를 확인해본다. 그룹이 변경되진 않았더라도, `ReleaseStrategy`로 이번엔 그룹을 release할지를 결정할 수 있다. release 전략에서 이번에도 그룹을 release하지 않는다면 해당 그룹은 만료된다. 이때 `send-partial-result-on-expiry`가 `true`이면 (부분적인) `MessageGroup`에 있는 기존 메시지들은 `output-channel`로 보내는 일반적인 aggregator 응답 메시지로 release되며, `true`가 아닐 땐 폐기된다.

There is a difference between `groupTimeout` behavior and `MessageGroupStoreReaper` (see [Configuring an Aggregator with XML](#configuring-an-aggregator-with-xml)). The reaper initiates forced completion for all `MessageGroup` s in the `MessageGroupStore` periodically. The `groupTimeout` does it for each `MessageGroup` individually if a new message does not arrive during the `groupTimeout`. Also, the reaper can be used to remove empty groups (empty groups are retained in order to discard late messages if `expire-groups-upon-completion` is false).

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

See [Programming Model](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/index-single.html#aggregator-api) and [Annotations on `@Bean` Methods](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/configuration.html#annotations_on_beans) for more information.

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
  <p>Since the <code class="highlighter-rouge">MessageGroupStoreReaper</code> is called from a scheduled task, and may result in the production of a message (depending on the <code class="highlighter-rouge">sendPartialResultOnExpiry</code> option) to a downstream integration flow, it is recommended to supply a custom <code class="highlighter-rouge">TaskScheduler</code> with a <code class="highlighter-rouge">MessagePublishingErrorHandler</code> to handler exceptions via an <code class="highlighter-rouge">errorChannel</code>, as it might be expected by the regular aggregator release functionality. The same logic applies for group timeout functionality which also relies on a <code class="highlighter-rouge">TaskScheduler</code>. See <a href="https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/error-handling.html#error-handling">Error Handling</a> for more information.</p>
</blockquote>

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>When a shared <code class="highlighter-rouge">MessageStore</code> is used for different correlation endpoints, you must configure a proper <code class="highlighter-rouge">CorrelationStrategy</code> to ensure uniqueness for group IDs. Otherwise, unexpected behavior may happen when one correlation endpoint releases or expire messages from others. Messages with the same correlation key are stored in the same message group.</p>
  <p>Some <code class="highlighter-rouge">MessageStore</code> implementations allow using the same physical resources, by partitioning the data. For example, the <code class="highlighter-rouge">JdbcMessageStore</code> has a <code class="highlighter-rouge">region</code> property, and the <code class="highlighter-rouge">MongoDbMessageStore</code> has a <code class="highlighter-rouge">collectionName</code> property.</p>
  <p>For more information about the <code class="highlighter-rouge">MessageStore</code> interface and its implementations, see <a href="https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/message-store.html#message-store">Message Store</a>.</p>
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

Starting with version 5.5, an `AbstractCorrelatingMessageHandler` (including its Java & XML DSLs) exposes a `groupConditionSupplier` option of the `BiFunction<Message<?>, String, String>` implementation. This function is used on each message added to the group and a result condition sentence is stored into the group for future consideration. The `ReleaseStrategy` may consult this condition instead of iterating over all the messages in the group. See `GroupConditionProvider` JavaDocs and [Message Group Condition](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/message-store.html#message-group-condition) for more information.

See also [File Aggregator](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/file.html#file-aggregator).

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

See [Aggregators and Resequencers](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/dsl.html#java-dsl-aggregators) for configuring a resequencer in Java DSL.

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
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(7)</span> Whether, upon the expiration of the group, the ordered group should be sent out (even if some of the messages are missing). Optional. (The default is false.) See [Managing State in an Aggregator: `MessageGroupStore`](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/aggregator.html#reaper).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(8)</span> The timeout interval to wait when sending a reply `Message` to the `output-channel` or `discard-channel`. Defaults to `-1`, which blocks indefinitely. It is applied only if the output channel has some 'sending' limitations, such as a `QueueChannel` with a fixed 'capacity'. In this case, a `MessageDeliveryException` is thrown. The `send-timeout` is ignored for `AbstractSubscribableChannel` implementations. For `group-timeout(-expression)`, the `MessageDeliveryException` from the scheduled expiring task leads this task to be rescheduled. Optional.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(9)</span> A reference to a bean that implements the message correlation (grouping) algorithm. The bean can be an implementation of the `CorrelationStrategy` interface or a POJO. In the latter case, the `correlation-strategy-method` attribute must also be defined. Optional. (By default, the aggregator uses the `IntegrationMessageHeaderAccessor.CORRELATION_ID` header.)</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(10)</span> A method that is defined on the bean referenced by `correlation-strategy` and that implements the correlation decision algorithm. Optional, with restrictions (requires `correlation-strategy` to be present).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(11)</span> A SpEL expression representing the correlation strategy. Example: `"headers['something']"`. Only one of `correlation-strategy` or `correlation-strategy-expression` is allowed.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(12)</span> A reference to a bean that implements the release strategy. The bean can be an implementation of the `ReleaseStrategy` interface or a POJO. In the latter case, the `release-strategy-method` attribute must also be defined. Optional (by default, the aggregator will use the `IntegrationMessageHeaderAccessor.SEQUENCE_SIZE` header attribute).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(13)</span> A method that is defined on the bean referenced by `release-strategy` and that implements the completion decision algorithm. Optional, with restrictions (requires `release-strategy` to be present).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(14)</span> A SpEL expression representing the release strategy. The root object for the expression is a `MessageGroup`. Example: `"size() == 5"`. Only one of `release-strategy` or `release-strategy-expression` is allowed.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(15)</span> Only applies if a `MessageGroupStoreReaper` is configured for the `<resequencer>` `MessageStore`. By default, when a `MessageGroupStoreReaper` is configured to expire partial groups, empty groups are also removed. Empty groups exist after a group is released normally. This is to enable the detection and discarding of late-arriving messages. If you wish to expire empty groups on a longer schedule than expiring partial groups, set this property. Empty groups are then not removed from the `MessageStore` until they have not been modified for at least this number of milliseconds. Note that the actual time to expire an empty group is also affected by the reaper’s timeout property, and it could be as much as this value plus the timeout.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(16)</span> See [Configuring an Aggregator with XML](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/aggregator.html#aggregator-xml).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(17)</span> See [Configuring an Aggregator with XML](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/aggregator.html#aggregator-xml).</small><br>
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