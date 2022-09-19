---
title: Messaging Endpoints
category: Spring Integration
order: 15
permalink: /Spring%20Integration/messaging-endpoints/
description: todo
image: ./../../images/springintegration/logo.png
lastmod: 2022-01-05T21:30:00+09:00
comments: true
originalRefName: 스프링 인티그레이션
parent: Core Messaging
originalRefLink: https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/index-single.html#messaging-endpoints-chapter
parentUrl: /Spring%20Integration/core-messaging/
---
<script>defaultLanguages = ['java-dsl', 'maven']</script>

---

## 목차

- [10.1. Message Endpoints](#101-message-endpoints)
  + [10.1.1. Message Handler](#1011-message-handler)
  + [10.1.2. Event-driven Consumer](#1012-event-driven-consumer)
  + [10.1.3. Polling Consumer](#1013-polling-consumer)
  + [10.1.4. Endpoint Namespace Support](#1014-endpoint-namespace-support)
    * [Examples](#examples)
    * [AOP Advice chains](#aop-advice-chains)
  + [10.1.5. Changing Polling Rate at Runtime](#1015-changing-polling-rate-at-runtime)
  + [10.1.6. Payload Type Conversion](#1016-payload-type-conversion)
  + [10.1.7. Content Type Conversion](#1017-content-type-conversion)
  + [10.1.8. Asynchronous Polling](#1018-asynchronous-polling)
  + [10.1.9. Endpoint Inner Beans](#1019-endpoint-inner-beans)
- [10.2. Endpoint Roles](#102-endpoint-roles)
- [10.3. Leadership Event Handling](#103-leadership-event-handling)
- [10.4. Messaging Gateways](#104-messaging-gateways)
  + [10.4.1. Enter the GatewayProxyFactoryBean](#1041-enter-the-gatewayproxyfactorybean)
  + [10.4.2. Gateway XML Namespace Support](#1042-gateway-xml-namespace-support)
  + [10.4.3. Setting the Default Reply Channel](#1043-setting-the-default-reply-channel)
  + [10.4.4. Gateway Configuration with Annotations and XML](#1044-gateway-configuration-with-annotations-and-xml)
    * [Expressions and “Global” Headers](#expressions-and-global-headers)
  + [10.4.5. Mapping Method Arguments to a Message](#1045-mapping-method-arguments-to-a-message)
    * [Mapping Method Arguments](#mapping-method-arguments)
  + [10.4.6. @MessagingGateway Annotation](#1046-messaginggateway-annotation)
  + [10.4.7. Invoking No-Argument Methods](#1047-invoking-no-argument-methods)
  + [10.4.8. Invoking default Methods](#1048-invoking-default-methods)
  + [10.4.9. Error Handling](#1049-error-handling)
  + [10.4.10. Gateway Timeouts](#10410-gateway-timeouts)
  + [10.4.11. Asynchronous Gateway](#10411-asynchronous-gateway)
    * [ListenableFuture](#listenablefuture)
    * [AsyncTaskExecutor](#asynctaskexecutor)
    * [CompletableFuture](#completablefuture)
    * [Reactor Mono](#reactor-mono)
    * [Downstream Flows Returning an Asynchronous Type](#downstream-flows-returning-an-asynchronous-type)
    * [void Return Type](#void-return-type)
  + [10.4.12. Gateway Behavior When No response Arrives](#10412-gateway-behavior-when-no-response-arrives)
    * [다운스트림 프로세스가 오랫동안 실행될 때](#다운스트림-프로세스가-오랫동안-실행될-때)
    * [다운스트림 구성 요소가 'null'을 반환할 때](#다운스트림-구성-요소가-null을-반환할-때)
    * [다운스트림 구성 요소의 반환 타입은 ‘void’인데 게이트웨이 메소드 시그니처는 void가 아닐 때](#다운스트림-구성-요소의-반환-타입은-void인데-게이트웨이-메소드-시그니처는-void가-아닐-때)
    * [다운스트림 구성 요소가 Runtime Exception으로 끝났을 때](#다운스트림-구성-요소가-runtime-exception으로-끝났을-때)
- [10.5. Service Activator](#105-service-activator)
  + [10.5.1. Configuring Service Activator](#1051-configuring-service-activator)
    * [Service Activators and the Spring Expression Language (SpEL)](#service-activators-and-the-spring-expression-language-spel)
  + [10.5.2. Asynchronous Service Activator](#1052-asynchronous-service-activator)
  + [10.5.3. Service Activator and Method Return Type](#1053-service-activator-and-method-return-type)
- [10.6. Delayer](#106-delayer)
  + [10.6.1. Configuring a Delayer](#1061-configuring-a-delayer)
  + [10.6.2. Delayer and a Message Store](#1062-delayer-and-a-message-store)
  + [10.6.3. Release Failures](#1063-release-failures)
- [10.7. Scripting Support](#107-scripting-support)
  + [10.7.1. Script Configuration](#1071-script-configuration)
    * [Script Variable Bindings](#script-variable-bindings)
- [10.8. Groovy support](#108-groovy-support)
  + [10.8.1. Groovy Configuration](#1081-groovy-configuration)
  + [10.8.2. Groovy Object Customization](#1082-groovy-object-customization)
  + [10.8.3. Groovy Script Compiler Customization](#1083-groovy-script-compiler-customization)
  + [10.8.4. Control Bus](#1084-control-bus)
- [10.9. Adding Behavior to Endpoints](#109-adding-behavior-to-endpoints)
  + [10.9.1. Provided Advice Classes](#1091-provided-advice-classes)
    * [Retry Advice](#retry-advice)
    * [Circuit Breaker Advice](#circuit-breaker-advice)
    * [Expression Evaluating Advice](#expression-evaluating-advice)
    * [Rate Limiter Advice](#rate-limiter-advice)
    * [Caching Advice](#caching-advice)
  + [10.9.2. Reactive Advice](#1092-reactive-advice)
  + [10.9.3. Custom Advice Classes](#1093-custom-advice-classes)
  + [10.9.4. Other Advice Chain Elements](#1094-other-advice-chain-elements)
  + [10.9.5. Handling Message Advice](#1095-handling-message-advice)
  + [10.9.6. Transaction Support](#1096-transaction-support)
  + [10.9.7. Advising Filters](#1097-advising-filters)
  + [10.9.8. Advising Endpoints Using Annotations](#1098-advising-endpoints-using-annotations)
  + [10.9.9. Ordering Advices within an Advice Chain](#1099-ordering-advices-within-an-advice-chain)
  + [10.9.10. Advised Handler Properties](#10910-advised-handler-properties)
  + [10.9.11. Idempotent Receiver Enterprise Integration Pattern](#10911-idempotent-receiver-enterprise-integration-pattern)
- [10.10. Logging Channel Adapter](#1010-logging-channel-adapter)
  + [10.10.1. Using Java Configuration](#10101-using-java-configuration)
  + [10.10.2. Configuring with the Java DSL](#10102-configuring-with-the-java-dsl)
- [10.11. java.util.function Interfaces Support](#1011-javautilfunction-interfaces-support)
  + [10.11.1. Kotlin Lambdas](#10111-kotlin-lambdas)

---

## 10.1. Message Endpoints

이 챕터에선 제일 먼저 배경 이론 몇 가지를 다루고 Spring Integration의 다양한 메시지 처리 구성 요소들을 구동하는 내부 API를 깊게 파해쳐본다. 여기에서 다루는 내용을 알아두면 뒷단에서 어떤 일이 일어나는지 이해할 수 있을 거다. 하지만 간단한 네임스페이스로 다양한 요소들을 설정하고 바로 실행해보고 싶다면 당장은 [엔드포인트 네임스페이스 지원](#1014-endpoint-namespace-support)으로 건너뛰어도 좋다.

개요를 다룰 때도 언급했지만, 메시지 엔드포인트는 메시지 처리에 필요한 구성 요소들을 채널에 연결해주는 일을 담당한다. 이어지는 챕터에선 메시지를 컨슘하는 다양한 구성 요소들을 다룬다. 일부 구성 요소는 응답 메시지를 전송하기도 있다. 메시지를 전송하는 것은 꽤 간단하다. 앞서 [메시지 채널](../messaging-channels/#61-message-channels)에서 설명한 것처럼, 메시지 채널로 메시지를 전송하면 된다. 하지만 메시지를 받는 건 조금 복잡하다. [폴링 컨슈머](https://www.enterpriseintegrationpatterns.com/PollingConsumer.html)와 [이벤트 기반<sup>event-driven</sup> 컨슈머](https://www.enterpriseintegrationpatterns.com/EventDrivenConsumer.html)라는 두 가지 유형의 컨슈머가 있는 것이 주원인이다.

이 둘 중에는 이벤트 기반 컨슈머가 훨씬 간단하다. 이벤트 기반 컨슈머는 별도 폴러 스레드를 관리하거나 스케줄링할 필요가 없으며, 사실상 콜백 메소드를 하나 가지고 있는 리스너라고 볼 수 있다. Spring Integration이 제공하는 subscribable 채널 중 하나에 연결할 때는 이벤트 기반 컨슈머를 사용하면 되서 간단하다. 하지만 버퍼링(pollable) 채널에 연결할 땐, 특정 구성 요소를 이용해 폴링 스레드를 스케줄링하고 관리해야만 한다. Spring Integration은 이 두 가지 유형의 컨슈머를 모두 지원할 수 있도록, 두 종류의 엔드포인트 구현체를 제공한다. 따라서 컨슈머 자체는 콜백 인터페이스만 구현하면 된다. 폴링이 필요한 경우엔 이 엔드포인트가 컨슈머 인스턴스의 컨테이너 역할을 한다. 이점은 메시지 기반 빈들을 호스팅하기 위해 컨테이너를 사용하는 것과 유사하지만, 이 컨슈머들은 `ApplicationContext` 내에서 실행되는 스프핑 관리 객체이기 때문에 스프링 자체의 `MessageListener` 컨테이너에 더 가깝다.

### 10.1.1. Message Handler

프레임워크 내에는 Spring Integration의 `MessageHandler` 인터페이스를 구현한 구성 요소가 많이 있다. 다시 말하면, 이 인터페이스는 공개 API가 아니며, 일반적으로 `MessageHandler`를 직접 구현할 일은 없다. 그렇지만 메시지 컨슈머가 실제로 컨슘한 메시지를 처리할 때 사용하는 인터페이스이기 때문에, 이 전략 인터페이스를 알아두면 컨슈머의 전반적인 역할을 이해하는 데 도움이 될 거다. 이 인터페이스는 다음과 같이 정의돼있다:

```java
public interface MessageHandler {

    void handleMessage(Message<?> message);

}
```

인터페이스는 단순하지만, 다음 챕터에서 다루는 대부분의 구성 요소들(라우터, 트랜스포머, 스플리터, aggregator, 서비스 activator 등)의 토대가 될 인터페이스다. 이 구성 요소들은 저마다 메시지를 다르게 처리하지만, 실제로 메시지를 수신하기 위한 요구 사항은 동일하며, 폴링과 이벤트 기반 동작을 선택하는 것 또한 동일하다. Spring Integration은 이 콜백 기반 핸들러들을 호스팅하고 메시지 채널에 연결해주는 두 가지 엔드포인트 구현체를 제공한다.

### 10.1.2. Event-driven Consumer

두 가지 중 더 간단한 이벤트 기반 컨슈머 엔드포인트를 먼저 다뤄보자. `SubscribableChannel` 인터페이스는 `subscribe()` 메소드를 제공하고, 이 메소드는 `MessageHandler` 파라미터를 받는다는 점을 기억할 거다 ([`SubscribableChannel`](../messaging-channels/#subscribablechannel) 참고). 아래 코드를 보면 `subscribe` 메소드의 정의를 알 수 있다:

```java
subscribableChannel.subscribe(messageHandler);
```

채널을 구독하는 핸들러는 해당 채널을 능동적으로 폴링할 필요가 없기 때문에, 여기서는 이벤트 기반 컨슈머를 사용한다. 아래 예제에서 볼 수 있듯이, Spring Integration이 제공하는 구현체는 `SubscribableChannel`과 `MessageHandler`를 받는다:

```java
SubscribableChannel channel = context.getBean("subscribableChannel", SubscribableChannel.class);

EventDrivenConsumer consumer = new EventDrivenConsumer(channel, exampleHandler);
```

### 10.1.3. Polling Consumer

Spring Integration은 `PollingConsumer`도 제공하는데, 아래 예제에서 알 수 있듯이 `PollableChannel`을 구현한 채널이어야 한다는 점만 빼면 같은 방법으로 인스턴스화할 수 있다:

```java
PollableChannel channel = context.getBean("pollableChannel", PollableChannel.class);

PollingConsumer consumer = new PollingConsumer(channel, exampleHandler);
```

> 폴링 컨슈머에 대한 자세한 내용은 [폴러](../messaging-channels/#62-poller)와 [채널 어댑터](../messaging-channels/#63-channel-adapter)를 참고해라.

폴링 컨슈머엔 다양한 옵션을 설정할 수 있다. 예를 들면 필수 프로퍼티 중엔 트리거가 있다. 다음은 트리거를 설정하는 방법을 보여주는 예시다:

```java
PollingConsumer consumer = new PollingConsumer(channel, handler);

consumer.setTrigger(new PeriodicTrigger(30, TimeUnit.SECONDS));
```

`PeriodicTrigger`를 정의할 땐 보통 간단히 인터벌을 지정하지만 (밀리세컨드 단위), `initialDelay`와 boolean 프로퍼티 `fixedRate`도 지원한다 (디폴트는 `false`다 — 즉, 딜레이를 고정하지 않는다). 아래 예제에선 두 가지 프로퍼티를 모두 세팅하고 있다:

```java
PeriodicTrigger trigger = new PeriodicTrigger(1000);
trigger.setInitialDelay(5000);
trigger.setFixedRate(true);
```

위 예제에서 세 가지 설정으로 만들어지는 트리거는 5초를 대기했다가 1초 간격으로 태스크를 트리거한다.

`CronTrigger`는 유효한 cron 표현식이 있어야 한다. 자세한 내용은 [Javadoc](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/scheduling/support/CronTrigger.html)을 확인해봐라. 다음은 `CronTrigger`를 새로 세팅하는 예시다:

```java
CronTrigger trigger = new CronTrigger("*/10 * * * * MON-FRI");
```

위 예시에서 정의한 트리거는 월요일부터 금요일까지 10초 간격으로 태스크를 트리거한다.

트리거 외에도, 폴링 관련 설정 프로퍼티로는 `maxMessagesPerPoll`, `receiveTimeout`을 지정할 수 있다. 다음은 두 가지 프로퍼티를 설정하는 방법을 보여주는 예시다:

```java
PollingConsumer consumer = new PollingConsumer(channel, handler);

consumer.setMaxMessagesPerPoll(10);
consumer.setReceiveTimeout(5000);
```

`maxMessagesPerPoll` 프로퍼티는 한 번의 폴링 사이클에서 최대로 수신할 메시지 수를 지정한다. 즉, 폴러는 `null`을 반환받거나 최대값에 도달할 때까지 대기 없이 `receive()`를 계속해서 호출한다. 예를 들어, 폴러가 10초 간격 트리거를 가지고 있고 `maxMessagesPerPoll` 은 `25`로 설정돼있다고 가정하면, 큐 안에 100개의 메시지가 들어있는 채널을 폴링하는 경우, 이 100개의 메시지는 40초 안에 전부 조회할 수 있다. 25개를 수신한 다음 10초를 기다렸다가 그 다음 25개를 수신하는 식이다. `maxMessagesPerPoll`을 음수로 설정한다면 `null`을 반환받을 때까지 하나의 폴링 사이클 안에서 `MessageSource.receive()`를 계속 호출한다. 5.5 버전부턴 `0`이 특별한 의미를 지니는데, `MessageSource.receive()` 호출을 전부 건너뛴다. 즉, 나중에 컨트롤 버스 등을 통해 `maxMessagesPerPoll`이 0이 아닌 값으로 바뀌기 전까진 이 폴링 엔드포인트를 일시 중단하는 것으로 보면 된다.

`receiveTimeout` 프로퍼티는 receive 연산을 실행할 때 사용 가능한 메시지가 없다면 폴러가 대기해야 하는 시간을 지정한다. 예를 들어서, 겉보기엔 비슷해 보여도 실제로는 상당히 다른 두 가지 옵션을 비교해보자: 첫 번째는 5초의 인터벌을 지닌 트리거를 가지고 있으며, receive 타임아웃은 50ms다. 두 번째 옵션은 50ms 인터벌의 트리거를 가지고 있으며, receive 타임아웃이 5초다. 첫 번째 폴러는 메시지가 채널에 도착한 시간보다 최대 4950ms까지 늦게 메시지를 받을 수 있다 (폴링 사이클 하나가 끝난 직후에 메시지가 도착한다면). 반면 두 번째 설정에서 메시지를 수신하는 시간은 50ms 이상으로 뒤쳐지지 않는다. 차이점이 있다면 두 번째 옵션에선 스레드가 대기하고 있어야 한다는 점이다. 하지만 결과적으로 보면 메시지가 도착할 시 훨씬 더 빠르게 응답할 수 있다. "long polling"으로 알려져있는 이 기술은 폴링해오는 소스에서 이벤트 기반 동작을 시뮬레이션할 때 활용할 수 있다.

폴링 컨슈머는 다음과 같이 스프링 `TaskExecutor`에 동작을 위임할 수도 있다:

```java
PollingConsumer consumer = new PollingConsumer(channel, handler);

TaskExecutor taskExecutor = context.getBean("exampleExecutor", TaskExecutor.class);
consumer.setTaskExecutor(taskExecutor);
```

더 나아가면 `PollingConsumer`는 `adviceChain`이란 프로퍼티를 가지고 있다. 이 프로퍼티를 사용하면 트랜잭션을 포함한 그밖의 횡단 관심사<sup>cross cutting concern</sup>를 위한 AOP 어드바이스 `List`를 지정할 수 있다. 이 어드바이스들은 `doPoll()` 메소드 전후에 적용된다. 좀더 상세한 내용은 [엔드포인트 네임스페이스 지원](#1014-endpoint-namespace-support) 밑에 있는 AOP 어드바이스 체인과 트랜잭션 지원에 관한 섹션을 참고해라.

앞에 있는 예제들은 의존성 lookup을 사용한다. 하지만 이런 컨슈머는 대부분 스프링 빈으로 정의한다는 점을 기억해두자. 실제로 Spring Integration은 채널 유형에 따라 적당한 컨슈머 타입을 생성해주는 `ConsumerEndpointFactoryBean`이란 `FactoryBean`도 제공하고 있다. 뿐만 아니라, Spring Integration은 이런 세부 사항은 감출 수 있도록 XML 네임스페이스를 전폭적으로 지원하고 있다. 이 가이드 문서에선 각 컴포넌트 타입을 소개할 때 네임스페이스 기반 설정을 함께 다루고 있다.

> 많은 `MessageHandler` 구현체들이 응답 메시지를 생성할 수 있다. 앞서 언급했듯이 메시지를 전송하는 것은 메시지를 받는 것에 비하면 꽤나 간단하다. 그렇다고 하더라도, 응답 메시지를 언제 얼마나 전송할지는 핸들러 타입에 따라 달라진다. 예를 들어서 aggregator는 많은 메시지가 도착할 때까지 기다리며, 메시지 하나로 여러 가지 응답을 생성할 수 있는 splitter의 다운스트림 컨슈머로 구성되는 경우가 많다. 네임스페이스 설정을 사용한다면 이런 세부 사항을 정확히 알지 못해도 괜찮다. 하지만 일부 구성 요소들은 공통 기본 클래스 `AbstractReplyProducingMessageHandler`를 통해 `setOutputChannel(..)` 메소드를 제공한다는 사실을 알아두면 좋다.

### 10.1.4. Endpoint Namespace Support

라우터, 트랜스포머, 서비스 activator 등의 엔드포인트 요소를 설정하는 상황별 예제는 이 레퍼런스 메뉴얼 곳곳에서 찾을 수 있다. `input-channel` 속성은 대부분이 지원하며, `output-channel` 속성을 지원하는 엔드포인트도 다양하다. 이 엔드포인트 요소를 파싱하고 나면 참조하는 `input-channel` 유형에 따라, `PollableChannel`이라면 `PollingConsumer`를, `SubscribableChannel`이라면 `EventDrivenConsumer` 인스턴스를 생성한다. pollable 채널을 참조할 땐 엔드포인트 요소의 하위 요소 `poller`와 그 속성을 기반으로 폴링 동작이 정의된다.

다음은 `poller`에 설정할 수 있는 모든 옵션을 나타낸 예시다:

```xml
<int:poller cron=""                                  <!-- (1) -->
            default="false"                          <!-- (2) -->
            error-channel=""                         <!-- (3) -->
            fixed-delay=""                           <!-- (4) -->
            fixed-rate=""                            <!-- (5) -->
            id=""                                    <!-- (6) -->
            max-messages-per-poll=""                 <!-- (7) -->
            receive-timeout=""                       <!-- (8) -->
            ref=""                                   <!-- (9) -->
            task-executor=""                         <!-- (10) -->
            time-unit="MILLISECONDS"                 <!-- (11) -->
            trigger="">                              <!-- (12) -->
            <int:advice-chain />                     <!-- (13) -->
            <int:transactional />                    <!-- (14) -->
</int:poller>
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 폴러를 Cron 표현식을 사용해 설정할 수 있다.<br>내부 구현체는 `org.springframework.scheduling.support.CronTrigger`를 사용한다.<br>이 속성을 설정한다면 `fixed-delay`, `trigger`, `fixed-rate`, `ref` 속성은 지정하면 안 된다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 이 속성을 `true`로 설정하면 단 하나의 글로벌 디폴트 폴러만 정의할 수 있다.<br>애플리케이션 컨텍스트에 디폴트 폴러를 둘 이상 정의하면 예외가 발생한다.<br>`PollableChannel`에 연결된 엔드포인트(`PollingConsumer`)나 `SourcePollingChannelAdapter` 중 명시적으로 폴러를 설정하지 않은 엔드포인트는 이 글로벌 디폴트 폴러를 사용한다.<br>디폴트는 `false`다.<br>생략할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 이 폴러를 실행하다 에러가 발생하면, 에러 메시지를 전송할 채널.<br>예외가 발생한 것을 숨기려면 `nullChannel`을 참조하면 된다.<br>생략할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> fixed delay 트리거는 내부적으로 `PeriodicTrigger`를 사용한다.<br>`time-unit` 속성을 사용하지 않는다면 밀리세컨드로 단위로 값을 지정해야 한다.<br>이 속성을 설정한다면 `fixed-rate`, `trigger`, `cron`, `ref` 속성은 지정하면 안 된다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> fixed rate 트리거는 내부적으로 `PeriodicTrigger`를 사용한다.<br>`time-unit` 속성을 사용하지 않는다면 밀리세컨드로 단위로 값을 지정해야 한다.<br>이 속성을 설정한다면 `fixed-delay`, `trigger`, `cron`, `ref` 속성은 지정하면 안 된다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(6)</span> 폴러의 내부 빈 정의를 참조하는 ID (`org.springframework.integration.scheduling.PollerMetadata`).<br>디폴트 폴러가 아니라면 (`default="true"`) 최상위 poller 요소엔 이 `id` 속성이 있어야 한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(7)</span> 자세한 내용은 [인바운드 채널 어댑터 설정하기](../messaging-channels/#631-configuring-an-inbound-channel-adapter)를 참고해라.<br>따로 지정하지 않았을 때 사용하는 기본값은 컨텍스트에 따라 다르다.<br>`PollingConsumer`를 사용한다면 이 속성의 기본값은 `-1`이다.<br>하지만 `SourcePollingChannelAdapter`를 사용하는 경우 `max-messages-per-poll` 속성은 `1`이 디폴트다.<br>생략할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(8)</span> 이 값은 내부에서 사용하는 클래스 `PollerMetadata`에 세팅된다.<br>따로 지정하지 않으 1000이 디폴트다 (밀리세컨드).<br>생략할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(9)</span> 또 다른 최상위 poller 빈에 대한 참조.<br>이 최상위 `poller` 요소엔 `ref` 속성이 있어선 안 된다.<br>이 속성을 설정한다면 `fixed-rate`, `trigger`, `cron`, `fixed-delay` 속성은 지정하면 안 된다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(10)</span> 커스텀 태스크 executor를 참조하는 기능을 제공한다.<br>자세한 내용은 [TaskExecutor 지원](#taskexecutor-support)을 참고해라.<br>생략할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(11)</span> 이 속성은 내부 `org.springframework.scheduling.support.PeriodicTrigger`에서 사용할 `java.util.concurrent.TimeUnit` enum 값을 지정한다.<br>따라서 이 속성은 `fixed-delay`나 `fixed-rate`과 함께 사용해야 한다.<br>`cron`이나 참조 속성 `trigger`와 함께 사용하면 오류가 발생한다.<br>`PeriodicTrigger`는 최대 밀리세컨드까지 지원한다.<br>그렇기 때문에 밀리세컨드와 세컨드만 사용할 수 있다.<br>값을 지정하지 않으면 `fixed-delay` 혹은 `fixed-rate` 값은 밀리세컨드로 해석된다.<br>기본적으로 이 enum은 초 단위 인터벌을 사용하는 트리거를 세팅할 때 사용하기 좋다.<br>hourly, daily, monthly 설정이 필요하다면 이 속성 대신 `cron` 트리거를 사용하는 것을 권장한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(12)</span> `org.springframework.scheduling.Trigger` 인터페이스를 구현한 스프링 빈을 참조할 수 있다.<br>하지만 이 속성을 설정한다면 `fixed-delay`, `fixed-rate`, `cron`, `ref` 속성 중엔 어떤 것도 지정해선 안 된다.<br>생략할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(13)</span> 그밖의 횡단 관심사<sup>cross-cutting concern</sup>를 위한 AOP 어바이스들을 지정할 수 있다.<br>자세한 내용은 [트랜잭션 지원](#transaction-support)을 참고해라.<br>생략할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(14)</span> 폴러에 트랜잭션을 적용할 수 있다.<br>자세한 내용은 [AOP 어드바이스 체인](#aop-advice-chains)을 참고해라.<br>생략할 수 있다.</small>

#### Examples

1초 간격으로 트리거하는 간단한 폴러는 다음과 같이 설정할 수 있다:

```xml
<int:transformer input-channel="pollable"
    ref="transformer"
    output-channel="output">
    <int:poller fixed-rate="1000"/>
</int:transformer>
```

`fixed-rate` 속성 대신 `fixed-delay` 속성을 사용하는 방법도 있다.

Cron 표현식을 기반으로 동작하는 폴러의 경우, 다음 예제와 같이 대신 `cron` 속성을 사용한다:

```xml
<int:transformer input-channel="pollable"
    ref="transformer"
    output-channel="output">
    <int:poller cron="*/10 * * * * MON-FRI"/>
</int:transformer>
```

입력 채널이 `PollableChannel`일 땐 폴러 설정이 필요하다. 구체적으로 말하면, 앞에서 언급했듯이 `trigger`는 `PollingConsumer` 클래스의 필수 프로퍼티다. 따라서 폴링 컨슈머 엔드포인트 설정에서 하위 요소 `poller`를 생략하면 예외가 발생할 수 있다. pollable이 아닌 채널에 연결된 요소에 폴러를 설정하려고 해도 예외가 발생할 수 있다.

아래 예제처럼 최상위 레벨에도 폴러를 만들 수 있다. 이 경우엔 `ref` 속성만 있면 된다:

```xml
<int:poller id="weekdayPoller" cron="*/10 * * * * MON-FRI"/>

<int:transformer input-channel="pollable"
    ref="transformer"
    output-channel="output">
    <int:poller ref="weekdayPoller"/>
</int:transformer>
```

> `ref` 속성은 내부 폴러 정의에서만 허용한다. 이 속성을 최상위 레벨 폴러에 정의하면 애플리케이션 컨텍스트를 초기화하는 중에 설정 예외가 발생한다.

##### Global Default Poller

글로벌 디폴트 폴러를 정의하면 여기서 설정이 더 간단해진다. XML DSL 안에 최상위 레벨 폴러가 하나라면 `default` 속성을 `true`로 설정할 수 있다. 자바 설정이었다면 반드시 `PollerMetadata.DEFAULT_POLLER`란 이름으로 `PollerMetadata` 빈을 선언해야 한다. 이렇게 설정하면, 같은 `ApplicationContext`에 정의된 `PollableChannel`을 입력 채널로 가지고 있으면서, 명시해둔 `poller` 설정이 없는 엔드포인트는 전부 이 디폴트 폴러를 사용한다. 다음은 디폴트 폴러와, 이 폴러를 사용하는 트랜스포머를 보여주는 예시다:

<div class="switch-language-wrapper java-dsl java kotlin-dsl xml">
<span class="switch-language java-dsl">Java DSL</span>
<span class="switch-language java">Java</span>
<span class="switch-language kotlin-dsl">Kotlin DSL</span>
<span class="switch-language xml">XML</span>
</div>
<div class="language-only-for-java-dsl java-dsl java kotlin-dsl xml"></div>
```java
@Bean(name = PollerMetadata.DEFAULT_POLLER)
public PollerMetadata defaultPoller() {
    PollerMetadata pollerMetadata = new PollerMetadata();
    pollerMetadata.setMaxMessagesPerPoll(5);
    pollerMetadata.setTrigger(new PeriodicTrigger(3000));
    return pollerMetadata;
}

// No 'poller' attribute because there is a default global poller
@Bean
public IntegrationFlow transformFlow(MyTransformer transformer) {
    return IntegrationFlows.from(MessageChannels.queue("pollable"))
                           .transform(transformer) // No 'poller' attribute because there is a default global poller
                           .channel("output")
                           .get();
}
```
<div class="language-only-for-java java-dsl java kotlin-dsl xml"></div>
```java
@Bean(PollerMetadata.DEFAULT_POLLER)
public PollerMetadata defaultPoller() {
    PollerMetadata pollerMetadata = new PollerMetadata();
    pollerMetadata.setMaxMessagesPerPoll(5);
    pollerMetadata.setTrigger(new PeriodicTrigger(3000));
    return pollerMetadata;
}

@Bean
public QueueChannel pollable() {
   return new QueueChannel();
}
// No 'poller' attribute because there is a default global poller
@Transformer(inputChannel = "pollable", outputChannel = "output")
public Object transform(Object payload) {
    ...
}
```
<div class="language-only-for-kotlin-dsl java-dsl java kotlin-dsl xml"></div>
```kotlin
@Bean(PollerMetadata.DEFAULT_POLLER)
fun defaultPoller() =
    PollerMetadata()
        .also {
            it.maxMessagesPerPoll = 5
            it.trigger = PeriodicTrigger(3000)
        }

@Bean
fun convertFlow() =
    integrationFlow(MessageChannels.queue("pollable")) {
        transform(transformer) // No 'poller' attribute because there is a default global poller
        channel("output")
}
```
<div class="language-only-for-xml java-dsl java kotlin-dsl xml"></div>
```xml
<int:poller id="defaultPoller" default="true" max-messages-per-poll="5" fixed-delay="3000"/>

<!-- No <poller/> sub-element is necessary, because there is a default -->
<int:transformer input-channel="pollable"
                 ref="transformer"
                 output-channel="output"/>
```

##### Transaction Support

Spring Integration은 폴러에 트랜잭션을 적용할 수 있게 지원하고 있기 때문에, 각각의 receive-and-forward 연산을 하나의 원자적인 작업 단위로 수행할 수 있다. 폴러에 트랜잭션을 설정하려면 하위 요소 `<transactional/>`을 추가해라. 다음은 사용 가능한 속성들을 보여주는 예시다:

```xml
<int:poller fixed-delay="1000">
    <int:transactional transaction-manager="txManager"
                       propagation="REQUIRED"
                       isolation="REPEATABLE_READ"
                       timeout="10000"
                       read-only="false"/>
</int:poller>
```

좀 더 자세한 정보는 [폴러 트랜잭션 지원](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/transactions.html#transaction-poller)을 참고해라.

#### AOP Advice chains

스프링은 프록시 메커니즘을 통해 트랜잭션을 지원한다. 이 메커니즘에선 `TransactionInterceptor`(AOP 어드바이스)가 폴러로 시작된 메시지 플로우의 트랜잭션 관련 동작을 처리해준다. 그렇기 때문에 반드시 폴러와 관련된 다른 횡단 관심사<sup>cross cutting behavior</sup>를 위한 별도 어드바이스들을 제공해야 할 때가 있다. 이럴 땐 `poller`의 `advice-chain` 요소를 사용하면 된다. 이 요소를 이용하면 `MethodInterceptor` 인터페이스 구현 클래스에 다른 어드바이스들을 더 추가할 수 있다. 다음은 `poller`에 `advice-chain`을 정의하는 예시다:

```xml
<int:service-activator id="advicedSa" input-channel="goodInputWithAdvice" ref="testBean"
		method="good" output-channel="output">
	<int:poller max-messages-per-poll="1" fixed-rate="10000">
		 <int:advice-chain>
			<ref bean="adviceA" />
			<beans:bean class="org.something.SampleAdvice" />
			<ref bean="txAdvice" />
		</int:advice-chain>
	</int:poller>
</int:service-activator>
```

`MethodInterceptor` 인터페이스를 구현하는 방법에 대한 자세한 내용은 [스프링 프레임워크 레퍼런스 가이드에 있는 AOP 섹션](https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#aop-api)을 참고해라. 꼭 트랜잭션 설정이 있는게 아니더라도, 폴러에 어드바이스 체인을 적용하면 메시지 플로우 동작을 향상시킬 수 있다.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>어드바이스 체인을 사용할 땐, 하위 요소 <code class="highlighter-rouge">&lt;transactional/&gt;</code>을 지정할 수 없다. 그대신 <code class="highlighter-rouge">&lt;tx:advice/&gt;</code> 빈을 선언하고 <code class="highlighter-rouge">&lt;advice-chain/&gt;</code>에 추가해라. 전체 설정에 관한 상세 정보는 <a href="https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/transactions.html#transaction-poller">폴러 트랜잭션 지원</a>을 참고해라.</p>
</blockquote>

##### TaskExecutor Support

폴링 스레드는 스프링의 `TaskExecutor` 인스턴스로도 실행할 수 있다. 이렇게 하면 엔드포인트 혹은 엔드포인트 그룹에 동시성을 부여하게 된다. 스프링 3.0부터 코어 스프링 프레임워크는 `task` 네임스페이스를 지원하는데, 여기 있는 `<executor/>` 요소는 간단한 스레드 풀 executor를 생성해준다. 이 요소는 풀 사이즈와 큐 용량같은 동시성 설정을 위한 공통 속성들을 받는다. 스레드 풀링 executor를 설정하면 부하 속에서 엔드포인트가 동작하는 방식에 상당한 차이를 만들어낼 수 있다. 엔드포인트의 성능은 반드시 고려해야 하는 중요 인자 중 하나이기 때문에 (또 다른 중요 인자로는 엔드포인트가 구독하는 채널의 예상 볼륨이 있다), 이런 설정들은 엔드포인트별로 따로 이용할 수 있다. XML 네임스페이스 지원을 이용해 설정한 폴링 엔드포인트에서 동시성 효과를 누리려면, `<poller/>` 요소에 `task-executor` 참조를 제공하고, 아래 예시에 보이는 프로퍼티들 중 원하는 것들을 지정해라:

```xml
<int:poller task-executor="pool" fixed-rate="1000"/>

<task:executor id="pool"
               pool-size="5-25"
               queue-capacity="20"
               keep-alive="120"/>
```

task-executor를 제공하지 않으면 컨슈머의 핸들러는 호출자의 스레드에서 실행된다. 일반적인 상황에서 호출자는 보통 디폴트 `TaskScheduler`다 ([태스크 스케줄러 설정하기](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/configuration.html#namespace-taskscheduler) 참고). `task-executor` 속성은 스프링의 `TaskExecutor` 인터페이스를 구현한 빈의 이름을 참조할 수 있다는 점도 알아두면 좋다. 위 예제에 보이는 `executor` 요소는 편의상 표기했으니 참고해라.

[폴링 컨슈머의 배경 이론에 대해 설명하면서](#1013-polling-consumer) 언급했듯이, 폴링 컨슈머는 이벤트 기반 동작을 시뮬레이션할 때에도 활용할 수 있다. receive 타임아웃은 길고 인터벌은 짧은 트리거를 이용하면, 메시지 소스를 폴링하는 방식이더라도 메시지가 도착하면 매우 빠르게 반응할 수 있다. 단, 이 테크닉은 소스를 호출하면 타임아웃되기 전까지 블로킹되는 경우에만 가능하다. 예를 들어 파일 폴러는 블로킹되지 않는다. `receive()`를 호출할 때마다 즉시 반환되며, 새 파일이 있을 수도 없을 수도 있다. 따라서 폴러에 `receive-timeout`을 길게 설정하더라도, 블로킹되지 않기 때문에 이 값을 사용할 수 없다. 한편 Spring Integration의 자체 큐 기반 채널을 사용한다면 타임아웃을 적절히 활용할 수 있다. 다음 예제는 폴링 컨슈머로 메시지를 거의 도착하는 즉시 수신하는 방법을 보여준다:

```xml
<int:service-activator input-channel="someQueueChannel"
    output-channel="output">
    <int:poller receive-timeout="30000" fixed-rate="10"/>

</int:service-activator>
```

이 테크닉은 내부에서 정해진 시간 동안 대기하는 스레드를 하나 사용하는 것이 전부기 때문에 오버헤드가 많이 따라오지 않는다. 이 스레드는 (예를 들어) 스래싱<sup>thrashing</sup>, 무한 while 루프에 비하면 그만큼 CPU 리소스를 잡아먹지 않는다.

### 10.1.5. Changing Polling Rate at Runtime

폴러를 `fixed-delay`나 `fixed-rate` 속성으로 설정할 땐, 디폴트 구현체는 `PeriodicTrigger` 인스턴스를 사용한다. `PeriodicTrigger`는 코어 스프링 프레임워크에 들어있다. 이 클래스는 인터벌을 생성자 인자로만 받기 때문에 런타임에 변경이 불가능하다.

하지만 `org.springframework.scheduling.Trigger` 인터페이스는 직접 구현할 수 있다. 그래도 처음엔 `PeriodicTrigger`를 사용해보는 것도 좋다. 이후에 인터벌(period)을 위한 setter를 추가하거나, 트리거 자체에 스로틀링<sup>throttling </sup> 로직을 직접 넣을 수도 있다. `nextExecutionTime`을 호출해서 다음번 폴링을 스케줄링할 때마다 이 `period` 프로퍼티를 사용한다. 이 커스텀 트리거를 폴러 안에서 사용하려면 애플리케이션 컨텍스트에 커스텀 트리거 빈을 정의하고, `trigger` 속성에서 이 인스턴스를 참조해서 폴러 설정에 의존성을 주입해줘라. 그러면 트리거 빈에 대한 참조를 가져와서 폴링 인터벌을 변경할 수 있다.

예제가 필요하다면 [Spring Integration Samples](https://github.com/SpringSource/spring-integration-samples/tree/main/intermediate) 프로젝트를 확인해봐라. `dynamic-poller`라는 샘플에서 커스텀 트리거를 사용해서 런타임에 폴링 인터벌을 변경하는 것을 확인할 수 있다.

이 샘플에선 [`org.springframework.scheduling.Trigger`](https://docs.spring.io/spring/docs/current/javadoc-api/org/springframework/scheduling/Trigger.html) 인터페이스를 구현한 커스텀 트리거를 사용한다. 이 샘플의 트리거는 스프링의 [`PeriodicTrigger`](https://docs.spring.io/spring/docs/current/javadoc-api/org/springframework/scheduling/support/PeriodicTrigger.html) 구현체를 기반으로 만들었다. 하지만 커스텀 트리거의 필드들은 final이 아니며, 프로퍼티들엔 명시적인 getter와 setter가 있어 런타임에 폴링 인터벌을 동적으로 변경할 수 있다.

> 그렇지만 Trigger 메소드는 `nextExecutionTime()`이기 때문에, 다이나믹 트리거를 변경하더라도 다음번 폴링 전까진 기존 설정을 그대로 사용한다는 점을 이해해야 한다. 현재 다음번 실행 시간으로 설정된 시간 이전에 트리거를 강제로 동작시킬 수 있는 방법은 없다.

### 10.1.6. Payload Type Conversion

이 문서에선 메시지나 임의의 `Object`를 입력 파라미터로 받는 다양한 엔드포인트들의 상황별 설정과 구현 예시도 만날 수 있다. `Object`를 받을 땐, 이 파라미터는 메시지 페이로드에 매핑되거나, 페이로드 혹은 헤더의 특정 필드에 매핑된다 (SpEL<sup>Spring Expression Language</sup> 사용 시). 하지만 엔드포인트 메소드의 입력 파라미터 타입이 페이로드나 하위 필드 타입과 항상 일치하는 것은 아니다. 이럴 땐 타입 변환을 수행해야 한다. Spring Integration을 사용하면 타입 컨버터를 손쉽게 등록할 수 있다 (스프링 `ConversionService`를 이용해서). Spring Integration은 `integrationConversionService`라는 자체 변환 서비스 빈을 가지고 있다. 이 빈은 컨버터를 하나라도 정의하면 Spring Integration 인프라에서 즉시 자동으로 생성한다. 컨버터를 등록하려면 `org.springframework.core.convert.converter.Converter`나, `org.springframework.core.convert.converter.GenericConverter` 또는 `org.springframework.core.convert.converter.ConverterFactory`를 구현하면 된다.

`Converter` 구현체는 무엇보다도 간결한데, 어떤 타입을 다른 타입으로 변환하는 일을 담당한다. 클래스 계층 구조로 변환하는 것 같이 더 정교한 조작이 필요할 땐 `GenericConverter`를 사용하면 되고, 어쩌면 `ConditionalConverter`를 구현할 수도 있다. 이 인터페이스들은 `from`, `to` 타입 descriptor를 사용하므로 좀더 복잡한 변환 로직을 만들 수 있다. 예를 들어 변환 대상이 `Something`이라는 추상 클래스이고 (파라미터 타입, 채널 데이터 타입 등), `Thing1`과 `Thing`이라는 구현체가 있으며, 입력 타입에 따라 둘 중 하나로 변환하려 한다면 `GenericConverter`를 사용하면 된다. 자세한 내용은 아래 인터페이스들의 Javadoc을 참고해라:

- [org.springframework.core.convert.converter.Converter](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/core/convert/converter/Converter.html)
- [org.springframework.core.convert.converter.GenericConverter](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/core/convert/converter/package-summary.html)
- [org.springframework.core.convert.converter.ConverterFactory](https://docs.spring.io/spring/docs/current/javadoc-api/org/springframework/core/convert/converter/ConverterFactory.html)

컨버터를 구현했다면, 아래 예제와 같이 네임스페이스를 이용해 간편하게 등록할 수 있다:

```xml
<int:converter ref="sampleConverter"/>

<bean id="sampleConverter" class="foo.bar.TestConverter"/>
```

아니면 아래 예제처럼 내부 빈으로 사용해도 된다:

```xml
<int:converter>
    <bean class="o.s.i.config.xml.ConverterParserTests$TestConverter3"/>
</int:converter>
```

Spring Integration 4.0부터는 다음 예제처럼 어노테이션을 이용해 위와 동일한 설정을 만들 수 있다:

```java
@Component
@IntegrationConverter
public class TestConverter implements Converter<Boolean, Number> {

	public Number convert(Boolean source) {
		return source ? 1 : 0;
	}

}
```

아니면 아래처럼 `@Configuration` 어노테이션을 사용해도 된다:

```java
@Configuration
@EnableIntegration
public class ContextConfiguration {

	@Bean
	@IntegrationConverter
	public SerializingConverter serializingConverter() {
		return new SerializingConverter();
	}

}
```

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>스프링 프레임워크에서 애플리케이션 컨텍스트를 설정할 땐 직접 <code class="highlighter-rouge">conversionService</code> 빈을 추가할 수 있다 (<a href="https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#core-convert-Spring-config">ConversionService 설정하기</a> 챕터 참고). 이 서비스는 빈을 생성하고 설정할 때 변환이 필요한 경우에 사용한다.</p>
  <p>반면, <code class="highlighter-rouge">integrationConversionService</code>는 런타임 변환에 사용한다. 이들의 용도는 상당히 다르다. 데이터 타입 채널, 페이로드 타입 트랜스포머 등에서, 빈 생성자 인자와 프로퍼티들을 연결하는 용도로 만든 컨버터를 사용해 런타임에 메시지로 스프링 인티그레이션 표현식을 평가하면 의도치 않은 결과가 나올 수 있다.</p>
  <p>하지만 스프링 <code class="highlighter-rouge">ConversionService</code>를 Spring Integration <code class="highlighter-rouge">IntegrationConversionService</code>로 사용하려는 경우엔, 아래 예제와 같이 애플리케이션 컨텍스트 안에 alias를 설정해주면 된다:</p>
  <div class="language-xml highlighter-rouge"><div class="highlight"><pre class="highlight"><code><span class="nt">&lt;alias</span> <span class="na">name=</span><span class="s">"conversionService"</span> <span class="na">alias=</span><span class="s">"integrationConversionService"</span><span class="nt">/&gt;</span>
</code></pre></div>  </div>
  <p>이렇게 하면 <code class="highlighter-rouge">ConversionService</code>에서 제공하는 컨버터들을 Spring Integration의 런타임 변환에 사용할 수 있다.</p>
</blockquote>

### 10.1.7. Content Type Conversion

5.0 버전부터 기본적으로 메소드 실행 메커니즘은 `org.springframework.messaging.handler.invocation.InvocableHandlerMethod` 인프라를 이용한다. 이때 `HandlerMethodArgumentResolver` 구현체는 (ex. `PayloadArgumentResolver`, `MessageMethodArgumentResolver`) `MessageConverter` 인터페이스를 사용해 전달받은 `payload`를 타겟 메소드의 인자 타입으로 변환할 수 있다. 변환 자체는 메시지 헤더 `contentType`을 가지고 수행할 수 있다. Spring Integration은 `ConfigurableCompositeMessageConverter`를 제공한다. 이 구현체는 등록된 컨버터 목록에 로직을 위임하는 데, 컨버터 중 하나가 null이 아닌 값을 반환할 때까지 실행해본다. `ConfigurableCompositeMessageConverter`는 기본적으로 다음과 같은 컨버터들을 제공한다 (순서를 지켜서):

1. [`MappingJackson2MessageConverter`](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/jms/support/converter/MappingJackson2MessageConverter.html) (클래스패스에 Jackson 프로세서가 있다면)
2. [`ByteArrayMessageConverter`](https://docs.spring.io/spring/docs/current/javadoc-api/org/springframework/messaging/converter/ByteArrayMessageConverter.html)
3. [`ObjectStringMessageConverter`](https://docs.spring.io/spring-integration/docs/current/api//org/springframework/integration/support/converter/ObjectStringMessageConverter.html)
4. [`GenericMessageConverter`](https://docs.spring.io/spring/docs/current/javadoc-api/org/springframework/messaging/converter/GenericMessageConverter.html)

각각의 용도와 변환에 사용할 적절한 `contentType` 값에 대한 자세한 내용은 Javadoc을 확인해봐라 (앞에 링크를 걸어뒀다). `ConfigurableCompositeMessageConverter`를 사용하는 이유는 앞에 있는 디폴트 컨버터들을 사용하든 안 하든, 다른 `MessageConverter` 구현체들과 함께 제공할 수 있기 때문이다. 아래 예제처럼 디폴트 컨버터를 재정의해서 애플리케이션 컨텍스트에 적절한 빈으로 등록해줄 수도 있다:

```java
@Bean(name = IntegrationContextUtils.ARGUMENT_RESOLVER_MESSAGE_CONVERTER_BEAN_NAME)
public ConfigurableCompositeMessageConverter compositeMessageConverter() {
    List<MessageConverter> converters =
        Arrays.asList(new MarshallingMessageConverter(jaxb2Marshaller()),
                 new JavaSerializationMessageConverter());
    return new ConfigurableCompositeMessageConverter(converters);
}
```

위에 보이는 두 가지 컨버터는 디폴트 컨버터들보다 앞에 등록된다. 뿐만 아니라, `ConfigurableCompositeMessageConverter`를 사용하지 않고 자체 `MessageConverter`를 `integrationArgumentResolverMessageConverter`란 이름으로 빈을 등록해서 사용할 수도 있다 (`IntegrationContextUtils.ARGUMENT_RESOLVER_MESSAGE_CONVERTER_BEAN_NAME` 프로퍼티를 설정해서).

> SpEL 메소드를 실행하는 경우엔 `MessageConverter` 기반 (`contentType` 헤더도 포함해서) 변환은 이용할 수 없다. 이 경우 [페이로드 타입 변환](#1016-payload-type-conversion)에서 설명한 일반적인 클래스 간 변환만 가능하다.

### 10.1.8. Asynchronous Polling

메시지를 비동기로 폴링하려면, 폴러의 `task-executor` 속성이 기존 `TaskExecutor` 빈 인스턴스를 가리키도록 만들어주면 된다 (스프링 3.0에선 `task` 네임스페이스를 이용해 손쉽게 설정할 수 있다). 하지만 폴러에 `TaskExecutor`를 설정할 땐 반드시 이해하고 넘어가야 하는 것들이 몇 가지 있다.

폴러와 `TaskExecutor`라는 두 가지 설정이 있다는 점에서 문제가 시작된다. 이 둘의 조화가 서로 맞아야 한다. 그렇지 않으면 인위적인 메모리 누수<sup>memory leak</sup>가 발생할 수 있다.

아래 설정을 한 번 생각해보자:

```xml
<int:channel id="publishChannel">
    <int:queue />
</int:channel>

<int:service-activator input-channel="publishChannel" ref="myService">
	<int:poller receive-timeout="5000" task-executor="taskExecutor" fixed-rate="50" />
</int:service-activator>

<task:executor id="taskExecutor" pool-size="20" />
```

위 예시는 장단이 맞지 않는 설정이다.

기본적으로 태스크 executor는 무한한<sup>unbounded</sup> 태스크 큐를 가진다. 폴러는 모든 스레드가 블로킹돼 새 메시지가 도착하길 기다리거나 타임아웃되서 만료되길 기다리고 있더라도 계속해서 새 태스크를 예약한다. 타임아웃을 5초로 두고 태스크를 실행하는 20개의 스레드가 있다고 가정하면, 초당 4개 꼴로 태스크가 실행된다. 하지만 초당 20개 꼴로 새 태스크가 예약되므로, 태스크 executor 안에 있는 내부 큐는 초당 16개의 속도로 증가하기 때문에 (프로세스는 유휴 상태<sup>idle</sup>인데도) 메모리 누수<sup>memory leak</sup>가 발생한다.

이 문제를 해결하는 방법 중 하나로는, 태스크 executor의 `queue-capacity` 속성을 설정하는 방법이 있다. 0이라도 상관 없다. 태스크 Executor의 `rejection-policy` 속성을 설정해서 (`DISCARD` 등으로) 큐에 메시지를 넣을 수 없을 때 수행할 작업을 지정하는 식으로 관리하는 방법도 있다. 다시 말하지만, `TaskExecutor`를 설정한다면 깊게 이해하고 넘어가야 하는 부분이 있다. 이 주제에 대해 자세히 알고 싶다면 스프링 레퍼런스 매뉴얼에 있는 ["태스크 실행과 예약"](https://docs.spring.io/spring/docs/current/spring-framework-reference/integration.html#scheduling)을 참고해라.

### 10.1.9. Endpoint Inner Beans

엔드포인트 중에는 composite 빈으로 사용하는 엔드포인트가 꽤 있다. 컨슈머들과 폴링 인바운드 채널 어댑터들도 모두 마찬가지다. 컨슈머는 (폴링, 이벤트 기반 컨슈머 모두) 동작을 `MessageHandler`에 위임한다. 폴링 어댑터는 `MessageSource`에 위임해서 메시지를 가져온다. 한 번씩 런타임이나 테스트를 진행할 때 위임받은 객체<sup>delegate</sup> 빈의 참조를 얻어와 설정을 변경할 수 있다면 유용할 거다. 이 빈들의 이름은 정해진 규칙을 따르고 있기 때문에, 이 이름을 통해 `ApplicationContext`에서 꺼내올 수 있다. `MessageHandler` 인스턴스는 `someConsumer.handler`같은 빈 ID로 애플리케이션 컨텍스트에 등록된다 (여기서 'consumer'는 엔드포인트의 `id` 속성 값이다). `MessageSource` 인스턴스의 빈 ID는 `somePolledAdapter.source`같이 생겼으며, 여기서 'somePolledAdapter'는 어댑터의 ID다.

위에서 설명한 내용은 프레임워크 자체의 구성 요소들에만 해당하는 이야기다. 대신 다음 예제와 같이 내부 빈 정의를 사용해도 된다:

```xml
<int:service-activator id="exampleServiceActivator" input-channel="inChannel"
            output-channel = "outChannel" method="foo">
    <beans:bean class="org.foo.ExampleServiceActivator"/>
</int:service-activator>
```

이 빈은 내부에 선언된 다른 빈들처럼 처리돼서 애플리케이션 컨텍스트에 등록되지 않는다. 이 빈에 다른 방법으로 액세스하고 싶다면 최상위 레벨에 `id`를 사용해 선언하고 대신 `ref` 속성으로 참조해라. 자세한 내용은 [스프링 문서](https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#beans-inner-beans)를 참고해라.

---

## 10.2. Endpoint Roles

4.2 버전부턴 엔드포인트를 role에 할당할 수 있다. 이 role을 통해 여러 엔드포인트들을 한 번에 시작하고 중지할 수 있다. 리더십이 부여되거나 회수될 때 엔드포인트 셋을 시작, 중지할 수 있는 리더십 선출<sup>leadership election</sup>을 사용한다면 특히 더 유용하다. 스프링은 애플리케이션 컨텍스트에 `IntegrationContextUtils.INTEGRATION_LIFECYCLE_ROLE_CONTROLLER`라는 이름으로 `SmartLifecycleRoleController` 빈을 등록한다. 수명 주기를 제어해야 한다면 이 빈을 주입하거나 `@Autowired`하면 된다:

```xml
<bean class="com.some.project.SomeLifecycleControl">
    <property name="roleController" ref="integrationLifecycleRoleController"/>
</bean>
```

엔드포인트를 role에 할당할 땐 XML 설정이나, 자바 설정을 이용해도 되고, 코드로 직접 할당할 수도 있다. 다음은 XML을 사용해 엔드포인트 role을 설정하는 예시다:

```xml
<int:inbound-channel-adapter id="ica" channel="someChannel" expression="'foo'" role="cluster"
        auto-startup="false">
    <int:poller fixed-rate="60000" />
</int:inbound-channel-adapter>
```

다음은 자바에서 만드는 빈에 엔드포인트 role을 설정하는 방법을 보여주는 예시다:

```java
@Bean
@ServiceActivator(inputChannel = "sendAsyncChannel", autoStartup="false")
@Role("cluster")
public MessageHandler sendAsyncHandler() {
    return // some MessageHandler
}
```

아래 예제는 자바 메소드에 엔드포인트 role을 설정하고 있다:

```java
@Payload("#args[0].toLowerCase()")
@Role("cluster")
public String handle(String payload) {
    return payload.toUpperCase();
}
```

다음은 자바에서 `SmartLifecycleRoleController`를 사용해 엔드포인트 role을 설정하는 방법이다:

```java
@Autowired
private SmartLifecycleRoleController roleController;
...
    this.roleController.addSmartLifeCycleToRole("cluster", someEndpoint);
...
```

다음은 자바에서 `IntegrationFlow`를 이용해 엔드포인트 role을 설정하는 예시다:

```java
IntegrationFlow flow -> flow
        .handle(..., e -> e.role("cluster"));
```

이 예시들은 모두 `cluster` role에 엔드포인트를 추가한다.

`roleController.startLifecyclesInRole("cluster")` 메소드를 호출하면 엔드포인트를 시작하고, `stopLifecyclesInRole` 메소드를 호출하면 중지된다.

> `SmartLifecycle`을 구현한 객체라면 꼭 엔드포인트가 아니어도 코드로 직접 추가할 수 있다.

`SmartLifecycleRoleController`는 `ApplicationListener<AbstractLeaderEvent>`를 구현하고 있으며, 리더십을 부여받거나 회수하면 (어떤 빈이 `OnGrantedEvent`나 `OnRevokedEvent`를 게시하면) 그에 해당하는 `SmartLifecycle` 객체들을 자동으로 시작하고 중지해준다.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>리더십 선출<sup>leadership election</sup>을 이용해 컴포넌트들을 시작하고 중지한다면 XML 속성 <code class="highlighter-rouge">auto-startup</code>(빈 프로퍼티 <code class="highlighter-rouge">autoStartup</code>)을 <code class="highlighter-rouge">false</code>로 설정하는 것이 중요한데, 이렇게 해야 컨텍스트 초기화 중에 애플리케이션 컨텍스트가 컴포넌트들을 시작하지 않는다.</p>
</blockquote>

`SmartLifecycleRoleController`는 4.3.8 버전부터 다음과 같은 여러 가지 상태 메소드들을 제공한다:

```java
public Collection<String> getRoles() // (1)

public boolean allEndpointsRunning(String role) // (2)

public boolean noEndpointsRunning(String role) // (3)

public Map<String, Boolean> getEndpointsRunningStatus(String role) // (4)
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 관리 중인 role 리스트를 반환한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 이 role에 해당하는 모든 엔드포인트가 실행 중이면 `true`를 반환한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 이 role에 해당하는 엔드포인트들 중, 실행 중인 엔드포인트가 없으면 `true`를 반환한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> **컴포넌트 이름 : 실행 상태**를 매핑한 맵을 반환한다. 컴포넌트 이름은 일반적으로 빈의 이름을 뜻한다.</small>

---

## 10.3. Leadership Event Handling

엔드포인트 그룹은 리더십이 부여되거나 회수됨에 따라 시작, 중지할 수 있다. 클러스터 안에 있는 인스턴스 중에서 단 하나의 인스턴스만 공유 리소스를 컨슘해야 하는 상황 등에 활용할 수 있다. 대표적인 예시는 공유 디렉토리를 폴링하는 파일 인바운드 채널 어댑터다. ([파일 읽기](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/file.html#file-reading) 참고).

리더 선출에 참여해서, 리더로 선출되거나 리더십이 회수되거나, 또는 리더가 되려면 필요한 리소스를 획득하지 못한 경우에 통지 받을 수 있도록, 애플리케이션은 "leader initiator"라는 컴포넌트를 애플리케이션 컨텍스트 안에 하나 생성한다. 일반적으로 leader initiator는 `SmartLifecycle`이기 때문에, 컨텍스트가 시작할 때 시작되며 (선택 사항), 리더십이 변경되면 통지를 보낸다. 뿐만 아니라 5.0 버전부터는 `publishFailedEvents`를 `true`로 설정하면 실패 통보를 받을 수 있어, 실패 발생 시 원하는 조치를 취할 수 있다. 컨벤션에 따라 이 콜백들을 수신할 `Candidate`를 하나 제공해야 한다. 추가로, 프레임워크에서 제공하는 `Context` 객체를 통해 리더십을 회수할 수도 있다. 원하는 코드에서 `o.s.i.leader.event.AbstractLeaderEvent` 인스턴스(`OnGrantedEvent`와 `OnRevokedEvent`의 상위 클래스)를 수신<sup>listen</sup>하고 적절히 대응할 수도 있다 (ex. `SmartLifecycleRoleController`를 이용해서). 이 이벤트엔 `Context` 객체에 대한 참조가 담겨있다. 다음은 `Context` 인터페이스의 정의다:

```java
public interface Context {

	boolean isLeader();

	void yield();

	String getRole();

}
```

5.0.6 버전부턴 이 컨텍스트를 통해 candidate의 role에 접근할 수 있다.

Spring Integration은 leader initiator의 기본적인 구현체를 제공하는데, `LockRegistry` 인터페이스를 기반으로 동작한다. 이 구현체를 사용하려면 다음과 같이 인스턴스를 빈으로 생성해줘야 한다:

```java
@Bean
public LockRegistryLeaderInitiator leaderInitiator(LockRegistry locks) {
    return new LockRegistryLeaderInitiator(locks);
}
```

lock 레지스트리를 제대로 구현했다면, 리더는 최대 하나까지만 가능하다. lock 레지스트리에서 lock이 만료되거나 문제가 생겼을 때 예외를 던지기도 한다면 (이상적으로는 `InterruptedException`), 리더가 없는 상태로 유지되는 시간은 lock 구현체 자체의 대기 시간만큼만으로 최소화할 수 있다. 기본적으로, `busyWaitMillis` 프로퍼티는 추가적인 지연 시간을 더하는데, 이는 lock이 불완전해서 만료된 사실을 lock을 다시 얻어오려고 해봐야만 알 수 있는 좀 더 흔한 상황에서 CPU가 고갈되지 않게 하기 위함이다.

Zookeeper를 이용한 리더십 선출과 이벤트에 대한 자세한 내용은 [Zookeeper 리더십 이벤트 핸들링](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/zookeeper.html#zk-leadership)을 참고해라.

---

## 10.4. Messaging Gateways

게이트웨이는 Spring Integration에서 제공하는 메시징 API들을 숨겨준다. 덕분에 Spring Integration API를 인식하지 않고 애플리케이션의 비지니스 로직을 작성할 수 있다. 범용 게이트웨이를 사용하면 간단한 인터페이스 하나와만 상호 작용하는 코드를 만들 수 있다.

### 10.4.1. Enter the `GatewayProxyFactoryBean`

앞에서도 언급했지만, Spring Integration API (게이트웨이 클래스도 포함해서)에 대한 의존성을 없앨 수 있다면 정말 좋을 거다. Spring Integration은 의존성을 없앨 수 있도록 `GatewayProxyFactoryBean`을 제공한다. 이 클래스는 원하는 인터페이스에 대한 프록시를 생성해주며, 내부적으로 아래 보이는 게이트웨이 메소드들을 실행한다. 비즈니스 메소드엔 의존성 주입을 통해 이 인터페이스를 연결해주면 된다.

다음은 Spring Integration과 상호 작용하는 데 사용할 인터페이스 예시다:

```java
package org.cafeteria;

public interface Cafe {

    void placeOrder(Order order);

}
```

### 10.4.2. Gateway XML Namespace Support

네임스페이스 역시 지원하고 있다. 다음과 같이 원하는 인터페이스를 서비스로 설정할 수 있다:

```xml
<int:gateway id="cafeService"
         service-interface="org.cafeteria.Cafe"
         default-request-channel="requestChannel"
         default-reply-timeout="10000"
         default-reply-channel="replyChannel"/>
```

이렇게 설정해주고 나면, 다른 빈에는 `cafeService`를 주입할 수 있으며, `Cafe` 인터페이스의 프록시 인스턴스로 메소드를 호출하는 코드에선 Spring Integration API를 인지하지 못한다. 일반적으로 Spring Remoting(RMI, HttpInvoker 등)과 유사하게 처리할 수 있다. `gateway` 요소를 사용하는 예시는 부록에 있는 [“Samples”](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/samples.html#samples)를 참고해라 (Cafe 데모).

위 설정에 있는 디폴트 속성들은 게이트웨이 인터페이스에 있는 모든 메소드에 적용된다. reply 타임아웃을 지정하지 않으면 호출 스레드는 응답을 무한정 기다린다. [응답이 없을 때의 게이트웨이 동작](#10412-gateway-behavior-when-no-response-arrives)을 참고해라.

기본값들은 메소드별로 재정의할 수 있다. [어노테이션 및 XML을 이용한 게이트웨이 설정](#1044-gateway-configuration-with-annotations-and-xml)을 참고해라.

### 10.4.3. Setting the Default Reply Channel

게이트웨이는 응답을 수신<sup>listen</sup>하는 익명 reply 채널을 임시로 자동 생성하기 때문에, 일반적으론 `default-reply-channel`을 지정할 필요가 없다. 하지만 상황에 따라 `default-reply-channel`(또는 HTTP, JMS 등과 같은 어댑터 게이트웨이에선 `reply-channel`)을 정의하라는 로그가 남을 때도 있다.

그 배경을 이해하기 위해 게이트웨이의 내부 동작을 간단하게 설명해보겠다. 게이트웨이는 reply 채널로 사용할 임시 point-to-point 채널을 생성한다. 이 채널은 익명 채널이며, 메시지 헤더 `replyChannel`에 추가된다. `default-reply-channel`(원격 어댑터 게이트웨이에선 `reply-channel`)을 직접 명시한다면 publish-subscribe 채널을 가리킬 수도 있다. publish-subscribe란 이름을 보면 알 수 있지만, 이 채널은 구독자를 둘 이상 추가할 수 있는 채널이다. 그러면 Spring Integration은 내부적으로 임시 `replyChannel`과 명시적으로 정의한 `default-reply-channel` 사이에 브리지를 생성한다.

응답을 게이트웨이 뿐 아니라 다른 컨슈머에게도 전송하고 싶다고 가정해보자. 그러려면 두 가지 조건을 만족해야 한다:

- 구독할 수 있도록 이름을 가진 채널 (익명이 아닌 채널)
- 그 중에서도 publish-subscribe 채널

게이트웨이의 디폴트 전략에서 헤더에 추가하는 reply 채널은 익명, point-to-point 채널이기 때문에 이런 요구 사항들을 충족하지 않는다. 다시 말해, 다른 구독자가 채널을 이용할 수 없고, 가능하다고 쳐도 해당 채널은 point-to-point로 동작하기 때문에 하나의 구독자만 메시지를 받을 수 있다. `default-reply-channel`을 정의하면 원하는 채널을 가리킬 수 있다. 즉, `publish-subscribe-channel`을 정의하면 된다. 그러면 게이트웨이는 이 채널에서 헤더에 저장된 임시 익명 reply 채널로 이어주는 브리지를 생성한다.

인터셉터를 통해 모니터링이나 감사<sup>audit</sup>를 진행하기 위한 (ex. [wiretap](../messaging-channels/#wire-tap)) reply 채널을 명시적으로 제공하고 싶을 수도 있다. 채널 인터셉터를 설정할 때도 채널의 이름이 필요하다.

> 5.4 버전부터 게이트웨이 메소드의 리턴 타입이 `void`인 경우, 스프링은 `replyChannel` 헤더가 명시돼있지 않다면 `replyChannel` 헤더에 `nullChannel` 빈 참조를 채운다. 이렇게 하면 다운스트림 플로우에서 발생할 수 있는 응답을 전부 폐기하므로, 단방향 게이트웨이를 구현할 수 있다.

### 10.4.4. Gateway Configuration with Annotations and XML

아래 예제를 살펴보자. 앞에 있는 `Cafe` 인터페이스 예제를 확장해서 `@Gateway` 어노테이션을 추가했다:

```java
public interface Cafe {

    @Gateway(requestChannel="orders")
    void placeOrder(Order order);

}
```

다음 예제와 같이  `@Header` 어노테이션을 사용하면 메시지 헤더에 해당하는 값들을 추가할 수 있다:

```java
public interface FileWriter {

    @Gateway(requestChannel="filesOut")
    void write(byte[] content, @Header(FileHeaders.FILENAME) String filename);

}
```

XML을 이용해 게이트웨이 메소드를 설정하고 싶다면, 다음과 같이 게이트웨이 설정에 `method` 요소를 추가해주면 된다:

```xml
<int:gateway id="myGateway" service-interface="org.foo.bar.TestGateway"
      default-request-channel="inputC">
  <int:default-header name="calledMethod" expression="#gatewayMethod.name"/>
  <int:method name="echo" request-channel="inputA" reply-timeout="2" request-timeout="200"/>
  <int:method name="echoUpperCase" request-channel="inputB"/>
  <int:method name="echoViaDefault"/>
</int:gateway>
```

메소드마다 실행할 때 사용할 헤더도 XML로 제공할 수 있다. 사실상 설정하려는 헤더가 정적이어서, 게이트웨이의 메소드 시그니처에 `@Header` 어노테이션로 임베딩시키고 싶진 않을 때 유용하다. 예시로 대출을 중개한다고 가정해보면, 어떤 요청 타입이 들어왔는지에 따라 (견적을 하나만 요청했는지, 전부 요청했는지) 대출 견적을 집계하는 방식을 다르게 가져가려 한다. 어떤 게이트웨이 메소드를 실행했는지를 보고 요청 타입을 판별하는 것은 가능은 하더라도 관심사의 분리<sup>separation of concerns</sup> 패러다임에 맞지 않는다 (메소드는 자바 아티팩트다). 하지만 메시지 헤더에 의도(메타 정보)를 표현하는 것은, 메시징 아키텍처에선 자연스러운 일이다. 다음은 두 가지 메소드에 각각 다른 메시지 헤더를 추가하는 예시다:

```xml
<int:gateway id="loanBrokerGateway"
         service-interface="org.springframework.integration.loanbroker.LoanBrokerGateway">
  <int:method name="getLoanQuote" request-channel="loanBrokerPreProcessingChannel">
    <int:header name="RESPONSE_TYPE" value="BEST"/>
  </int:method>
  <int:method name="getAllLoanQuotes" request-channel="loanBrokerPreProcessingChannel">
    <int:header name="RESPONSE_TYPE" value="ALL"/>
  </int:method>
</int:gateway>
```

위 예시에선 'RESPONSE_TYPE' 헤더에 게이트웨이의 메소드에 따라 다른 값을 설정한다.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p><code class="highlighter-rouge">requestChannel</code> 등을 <code class="highlighter-rouge">&lt;int:method/&gt;</code>와 <code class="highlighter-rouge">@Gateway</code> 어노테이션에 둘 다 지정하면 어노테이션에 있는 값을 사용한다.</p>
</blockquote>

> XML에 인자를 받지 않는 게이트웨이를 지정했을 때, 인터페이스 메소드에 `@Gateway`와 `@Payload` 어노테이션이 모두 있는 경우 (`payloadExpression`이나 `<int:method/>` 요소의  `payload-expression`을 지정한 경우), `@Payload` 값은 무시된다.

#### Expressions and “Global” Headers

`<header/>` 요소에선 `value` 대신 `expression`을 사용할 수 있다. 여기 지정한 SpEL 표현식을 평가해서 헤더 값을 결정한다. 5.2 버전부터 평가 컨텍스트의 `#root` 객체는 `getMethod()`와 `getArgs()` 접근자를 가지고 있는 `MethodArgsHolder`다.

아래 있는 두 가지 표현식 평가 컨텍스트 변수는 5.2 버전부터 deprecated되었다:

- \#args: 메소드 인자들을 가지고 있는 `Object[]`
- \#gatewayMethod: 실행된 `service-interface`의 메소드를 나타내는 객체 (`java.reflect.Method`). 이후 플로우에선 (ex. 라우팅 등에) 이 변수를 담고 있는 헤더를 활용할 수 있다. 예를 들어, 간단하게 메소드명을 기준으로 라우팅하고 싶다면 `#gatewayMethod.name` 표현식으로 헤더를 추가하면 된다.

> `java.reflect.Method`는 직렬화가 불가능하다. 나중에 메시지를 직렬화하게 되면 `method` 표현식이 담겨있는 헤더는 손실된다. 그렇기 때문에 직렬화가 필요한 경우에는 `method.name`이나 `method.toString()`을 사용하는 게 좋다. `toString()` 메소드는 파라미터와 리턴 타입을 포함한 메소드의 정보를 `String`으로 표현해준다.

3.0 버전부터 `<default-header/>` 요소를 정의하면 어떤 메소드가 실행됐는지와는 무관하게 게이트웨이에서 생성한 모든 메시지에 헤더를 추가할 수 있다. 특정 헤더를 메소드에 직접 정의하면 디폴트 헤더보다 우선시한다. 여기에서 메소드에 정의한 헤더는 서비스 인터페이스의 `@Header` 어노테이션을 재정의한다. 그러나 디폴트 헤더는 서비스 인터페이스의 `@Header` 어노테이션을 재정의하지 않는다.

게이트웨이는 이제 모든 메소드에 적용되는 (재정의하지만 않는다면) `default-payload-expression`도 지원한다.

### 10.4.5. Mapping Method Arguments to a Message

앞에서 보여준 방법대로 설정하면 메소드 인자를 어떤 메시지 요소(페이로드, 헤더)에 매핑할지를 직접 제어할 수 있다. 반면, 설정이 명시되어 있지 않으면 특정 컨벤션을 사용해 매핑을 수행하게 된다. 이 컨벤션은 상황에 따라서 어떤 인자가 페이로드이고, 어떤 인자를 헤더에 매핑해야 하는지 결정할 수 없을 때도 있다. 아래 예시를 살펴보자:

```java
public String send1(Object thing1, Map thing2);

public String send2(Map thing1, Map thing2);
```

첫 번째 케이스에선, 컨벤션에 따라 첫 번째 인자를 (`Map`만 아니라면) 페이로드에 매핑하고 두 번째 인자가 헤더가 된다.

두 번째 케이스에선 (또는 첫 번째 케이스에서 `thing1` 인자가 `Map`인 경우), 어떤 인자를 페이로드로 취급해야 하는지 프레임워크가 결정할 수 없다. 결과적으로 매핑에 실패한다. 이 문제는 일반적으로 `payload-expression`이나, `@Payload` 또는 `@Headers` 어노테이션을 사용하면 해결할 수 있다.

아니면 (컨벤션으로 해결할 수 없다면) 메소드를 실행할 때 메시지를 매핑하는 일을 전부 직접 구현하는 방법도 있다. `MethodArgsMessageMapper`를 구현해서 `<gateway/>`의 `mapper` 속성에 지정해주면 된다. 이 매퍼는 `MethodArgsHolder`를 메시지로 매핑하는 역할을 담당한다. `MethodArgsHolder`는 `java.reflect.Method` 인스턴스와 인자들이 담겨있는 `Object[]`를 래핑한 간단한 클래스다. 커스텀 매퍼를 제공할 땐 게이트웨이의 `default-payload-expression` 속성이나 `<default-header/>` 요소는 사용할 수 없다. 마찬가지로 `<method/>` 요소에선 `payload-expression` 속성과 `<header/>` 요소를 허용하지 않는다.

#### Mapping Method Arguments

아래 코드에선 메소드 인자를 메시지에 매핑하는 방법과 함께, 잘못된 설정의 몇 가지 예시를 확인할 수 있다:

```java
public interface MyGateway {

    void payloadAndHeaderMapWithoutAnnotations(String s, Map<String, Object> map);

    void payloadAndHeaderMapWithAnnotations(@Payload String s, @Headers Map<String, Object> map);

    void headerValuesAndPayloadWithAnnotations(@Header("k1") String x, @Payload String s, @Header("k2") String y);

    void mapOnly(Map<String, Object> map); // the payload is the map and no custom headers are added

    void twoMapsAndOneAnnotatedWithPayload(@Payload Map<String, Object> payload, Map<String, Object> headers);

    @Payload("#args[0] + #args[1] + '!'")
    void payloadAnnotationAtMethodLevel(String a, String b);

    @Payload("@someBean.exclaim(#args[0])")
    void payloadAnnotationAtMethodLevelUsingBeanResolver(String s);

    void payloadAnnotationWithExpression(@Payload("toUpperCase()") String s);

    void payloadAnnotationWithExpressionUsingBeanResolver(@Payload("@someBean.sum(#this)") String s); //  (1)

    // invalid
    void twoMapsWithoutAnnotations(Map<String, Object> m1, Map<String, Object> m2);

    // invalid
    void twoPayloads(@Payload String s1, @Payload String s2);

    // invalid
    void payloadAndHeaderAnnotationsOnSameParameter(@Payload @Header("x") String s);

    // invalid
    void payloadAndHeadersAnnotationsOnSameParameter(@Payload @Headers Map<String, Object> map);

}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span>  SpEL 변수 `#this`는 인자를 나타낸다 — 이 경우 `s`의 값 .</small>

같은 설정을 XML을 이용하면 약간 달라지는데, 이땐 메소드 인자에 대한 `#this` 컨텍스트가 없기 때문이다. 하지만 아래 예제와 같이 `#args` 변수를 사용하면 표현식으로 메소드 인자를 참조할 수 있다:

```xml
<int:gateway id="myGateway" service-interface="org.something.MyGateway">
  <int:method name="send1" payload-expression="#args[0] + 'thing2'"/>
  <int:method name="send2" payload-expression="@someBean.sum(#args[0])"/>
  <int:method name="send3" payload-expression="#method"/>
  <int:method name="send4">
    <int:header name="thing1" expression="#args[2].toUpperCase()"/>
  </int:method>
</int:gateway>
```

### 10.4.6. `@MessagingGateway` Annotation

4.0 버전부터 게이트웨이 서비스 인터페이스를 설정하기 위해 xml 요소 `<gateway/>`를 정의하는 대신 `@MessagingGateway` 어노테이션으로 간단히 마킹할 수 있다. 아래 있는 두 예제를 보면 동일한 게이트웨이를 설정하는 두 가지 방법을 비교해볼 수 있다:

```xml
<int:gateway id="myGateway" service-interface="org.something.TestGateway"
      default-request-channel="inputC">
  <int:default-header name="calledMethod" expression="#gatewayMethod.name"/>
  <int:method name="echo" request-channel="inputA" reply-timeout="2" request-timeout="200"/>
  <int:method name="echoUpperCase" request-channel="inputB">
    <int:header name="thing1" value="thing2"/>
  </int:method>
  <int:method name="echoViaDefault"/>
</int:gateway>
```

```java
@MessagingGateway(name = "myGateway", defaultRequestChannel = "inputC",
		  defaultHeaders = @GatewayHeader(name = "calledMethod",
		                           expression="#gatewayMethod.name"))
public interface TestGateway {

   @Gateway(requestChannel = "inputA", replyTimeout = 2, requestTimeout = 200)
   String echo(String payload);

   @Gateway(requestChannel = "inputB", headers = @GatewayHeader(name = "thing1", value="thing2"))
   String echoUpperCase(String payload);

   String echoViaDefault(String payload);

}
```

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>Spring Integration은 XML 설정과 유사하게 컴포넌트 스캔 중에도 이런 어노테이션들을 발견하면, 메시징 인프라를 이용해 <code class="highlighter-rouge">proxy</code> 구현체를 생성한다. 여기서 말하는 스캔을 수행하고 애플리케이션 컨텍스트에 <code class="highlighter-rouge">BeanDefinition</code>을 등록하려면 <code class="highlighter-rouge">@Configuration</code> 클래스에 <code class="highlighter-rouge">@IntegrationComponentScan</code> 어노테이션을 추가해라. 표준 <code class="highlighter-rouge">@ComponentScan</code> 인프라에선 인터페이스들을 처리해주지 않는다. 그렇기 때문에 인터페이스 위에 있는 <code class="highlighter-rouge">@MessagingGateway</code> 어노테이션을 정제해서 관련 <code class="highlighter-rouge">GatewayProxyFactoryBean</code> 인스턴스를 등록할 수 있도록 커스텀 <code class="highlighter-rouge">@IntegrationComponentScan</code> 로직을 도입했다. <a href="https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/configuration.html#annotations">어노테이션 지원</a>도 함께 참고해라.</p>
</blockquote>

서비스 인터페이스 위에 `@MessagingGateway`, `@Profile` 어노테이션을 함께 마킹해주면, 해당 프로파일이 활성화되지 않았을 땐 빈을 생성하지 않을 수 있다.

> XML 설정을 전혀 사용하지 않는다면 `@Configuration` 클래스 중 최소 하나엔 `@EnableIntegration` 어노테이션을 선언해줘야 한다. 자세한 내용은 [설정과 `@EnableIntegration`](../overview/#55-configuration-and-enableintegration)을 참고해라.

### 10.4.7. Invoking No-Argument Methods

게이트웨이 인터페이스에서 인자를 받지 않는 메소드를 호출할 땐, `PollableChannel`에서 `Message`를 수신하는 게 기본 동작이다.

하지만 간혹, 인자가 없는 메소드를 트리거해서, 사용자가 파라미터를 제공할 필요가 없는 다운스트림의 다른 구성 요소와 상호 작용하고 싶을 수도 있다. 예를 들면 인자가 없는 SQL 호출이나 저장 프로시저<sup>stored procedure</sup>를 트리거하고 싶을 수 있다. 

send-and-receive 시맨틱스를 달성하려면 반드시 페이로드를 제공해야 한다. 페이로드 생성을 위해 인터페이스 메소드에 파라미터를 추가해야 하는 건 아니다. `@Payload` 어노테이션을 이용하거나 XML의 `method` 요소에서 `payload-expression` 속성을 사용하면 된다. 다음은 페이로드로 이용할 수 있는 몇 가지 예시다:

- 리터럴<sup>literal</sup> 문자열
- \#gatewayMethod.name
- new java.util.Date()
- @someBean.someMethod()가 반환하는 값

다음은 `@Payload` 어노테이션을 사용하는 예시다:

```xml
public interface Cafe {

    @Payload("new java.util.Date()")
    List<Order> retrieveOpenOrders();

}
```

`@Gateway` 어노테이션을 이용할 수도 있다.

```xml
public interface Cafe {

    @Gateway(payloadExpression = "new java.util.Date()")
    List<Order> retrieveOpenOrders();

}
```

> 두 어노테이션이 모두 있다면 (그리고 `payloadExpression`을 지정했다면) `@Gateway`를 우선시한다.

 [어노테이션과 XML을 이용한 게이트웨이 설정](#1044-gateway-configuration-with-annotations-and-xml)도 함께 참고해라.

인자를 받지 않고, 값을 반환하지도 않는 메소드에 페이로드 표현식이 포함되어 있으면, send-only로 처리한다.

### 10.4.8. Invoking `default` Methods

게이트웨이 프록시에서 사용하는 인터페이스는 `default` 메소드를 가질 수 있다. 5.3 버전부턴 프록시 메커니즘 대신 `java.lang.invoke.MethodHandle`을 이용해 `default` 메소드를 호출할 수 있도록 프록시에 `DefaultMethodInvokingMethodInterceptor`를 주입한다. `java.util.function.Function`같이 JDK에 포함되어있는 인터페이스 역시 게이트웨이 프록시에 사용할 수 있지만, 여기 있는 `default` 메소드는 호출할 수 없다. JDK 클래스에 대한 `MethodHandles.Lookup` 인스턴스를 만드는 건 자바 내부 보안에 걸리기 때문이다. 이런 메소드들은 메소드 위에 `@Gateway` 어노테이션을 명시하거나, `@MessagingGateway` 어노테이션이나 XML 요소 `<gateway>`에서 `proxyDefaultMethods`를 사용해도 앞에 프록시를 둘 수 있다 (구현 로직이 없어짐과 동시에 이전 게이트웨이 프록시 방식으로 복귀한다).

### 10.4.9. Error Handling

게이트웨이를 실행하는 동안에도 에러가 발생할 수 있다. 기본적으로, 게이트웨이의 메소드를 실행하는 동안 다운스트림에서 발생하는 모든 에러는 "그 상태 그대로" 다시 던져진다. 예를 들어서 아래 있는 간단한 플로우를 생각해보자:

```none
gateway -> service-activator
```

서비스 activator에 의해 호출된 서비스가 `MyException`을 던진다면 (예를 들어서), 프레임워크는 이를 `MessagingException`으로 감싸고 `failedMessage` 프로퍼티에 서비스 activator에 전달된 메시지를 첨부한다. 결과적으로 프레임워크에서 남기는 모든 로그엔 실패에 관한 전체 컨텍스트가 담기게 된다. 기본적으로 게이트웨이에서 예외를 catch하면 `MyException`을 감싸지 않은 채로 호출부에게 던진다. 게이트웨이 메소드 선언부에 `throws` 절을 구성하면 cause 체인에서 원하는 예외 타입을 매칭시킬 수 있다. 예를 들어 다운스트림에서 발생한 에러에 대한 모든 원인과 메시지 처리 정보가 포함된 `MessagingException`을 통으로 catch하고 싶다면, 다음과 유사한 게이트웨이 메소드를 사용하면 된다:

```java
public interface MyGateway {

    void performProcess() throws MessagingException;

}
```

스프링은 POJO 프로그래밍을 권장하고 있기 때문에, 메시지 처리 인프라에 호출자를 노출하는 게 꺼려질 수 있다.

게이트웨이 메소드에 아무런 `throws` 절이 없다면 게이트웨이는 cause 트리를 탐색해서 `MessagingException`이 아닌 `RuntimeException`을 찾는다. 아무 것도 발견하지 못하면 프레임워크는 `MessagingException`을 던진다. 앞의 예시에서 `MyException`이 `SomeOtherException`이란 원인을 가지고 있고 메소드가 `throws SomeOtherException`을 선언하고 있는 경우, 게이트웨이는 감싸진 예외를 언랩<sup>unwrap</sup>해서 `SomeOtherException`을 호출부에 던진다.

게이트웨이 선언에 `service-interface`가 없다면 내부 프레임워크 인터페이스인 `RequestReplyExchanger`를 사용한다.

아래 예제를 살펴보자:

```java
public interface RequestReplyExchanger {

	Message<?> exchange(Message<?> request) throws MessagingException;

}
```

이 `exchange` 메소드는 5.0 버전 전엔 `throws` 절이 없었기 때문에 예외가 언랩<sup>unwrap</sup>했었다. 이 인터페이스를 사용하면서 이전 언랩<sup>unwrap</sup> 동작으로 돌아가고 싶다면, 커스텀 `service-interface`를 사용하거나, 아니면 `MessagingException`의 ` cause`에 직접 액세스해야 한다.

하지만 에러를 전파하는 대신 로그로만 남기고 싶을 수도 있고, 예외를 유효한 응답으로 처리해야 할 수도 있다 (호출부가 이해할 수 있는 "에러 메시지"로 적당히 매핑하는 식으로). 게이트웨이는 이를 위한 에러 전용 메시지 채널과 `error-channel` 속성을 지원한다. 아래 예시에선 'transformer'가 `Exception`으로부터 응답 `Message`를 생성한다:

```xml
<int:gateway id="sampleGateway"
    default-request-channel="gatewayChannel"
    service-interface="foo.bar.SimpleGateway"
    error-channel="exceptionTransformationChannel"/>

<int:transformer input-channel="exceptionTransformationChannel"
        ref="exceptionTransformer" method="createErrorResponse"/>
```

`exceptionTransformer`는 원하는 에러 응답 객체를 생성할 수 있는 간단한 POJO를 이용하면 된다. 이 에러 응답 객체가 바로 호출부에 다시 전송되는 페이로드가 된다. 필요하다면 "에러 플로우" 안 에서 정교한 로직을 더 실행할 수 있다. 에러 플로우에선 라우터(Spring Integration의 `ErrorMessageExceptionTypeRouter` 포함), 필터 등을 사용할 수 있다. 하지만 대부분의 경우는 간단한 'transformer'만으로도 충분할 거다.

아니면 예외를 로그로만 기록할 수도 있다 (혹은 어딘가에 비동기로 전송하거나). 단방향 플로우를 만든다면 호출부엔 아무 것도 전송되지 않는다. 예외를 완전히 숨기려면<sup>suppress</sup> 글로벌 `nullChannel`의 참조를 제공하면 된다 (사실상 `/dev/null` 처리 방식). 마지막으로, 위에서도 언급했지만, `error-channel`이 정의돼 있지 않으면 평소와 같이 예외를 전파한다.

`@MessagingGateway` 어노테이션을 이용한다면 (`@MessagingGateway Annotation` 참고), `errorChannel` 속성을 사용할 수 있다.

5.0 버전부터 리턴 타입이 `void`인 게이트웨이 메소드를 사용하면 (단방향 플로우), 전달되는 각 메시지의 표준 `errorChannel` 헤더에 `error-channel` 참조가 채워진다 (제공했다면). 이를 이용하면 표준 `ExecutorChannel` 설정(또는 `QueueChannel`) 기반 다운스트림 비동기 플로우에서 디폴트 글로벌 `errorChannel` 예외 전송 동작을 재정의할 수 있다. 이전에는 `@GatewayHeader` 어노테이션이나 `<header>` 요소를 사용해서 수동으로 `errorChannel` 헤더를 지정해야 했다. 비동기 플로우의 `void` 메소드의 경우 `error-channel` 프로퍼티가 무시됐었고, 그대신 디폴트 `errorChannel`로 오류 메시지를 전송했었다.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>메시징 시스템을 간단한 POJO 게이트웨이를 통해 노출하게 되면 좋은 점도 있지만, 실존하는 내부 메시징 시스템을 "숨기는 것"에는 대가가 따르기 때문에 몇 가지를 생각해봐야 한다. 우리는 자바 메소드가 최대한 빨리 반환되길 바라며, 호출부가 void, 리턴 값이나 예외가 던져지길 기다리고 있는데 무한정 멈춰있지<sup>hang</sup> 않기를 바란다. 메시징 시스템 앞에 일반적인 메소드를 프록시로 두는 경우엔, 내부 메시지 처리 동작이 잠재적으로 비동기 특성을 가질 수 있음을 고려해야 한다. 이는 게이트웨이에 의해 시작된 메시지가 필터에 걸려 버려져 응답 생성을 담당하는 구성 요소에 도달하지 못할 수도 있음을 의미한다. 서비스 activator 메소드에서 예외가 발생해 응답을 제공하지 않을 수도 있다 (우린 null 메시지를 생성하지 않기 때문에). 즉, 응답 메시지는 여러 가지 상황으로 인해 도착하지 않을 수 있다. 이는 메시징 시스템에선 지극히 자연스러운 일이다. 이번엔 게이트웨이 메소드로 인해 생길 수 있는 일을 생각해 보자. 게이트웨이 메소드의 입력 인자는 메시지에 통합돼 다운스트림으로 전송된다. 이 응답 메시지는 게이트웨이 메소드의 반환 값으로 변환된다. 따라서 게이트웨이를 호출할 때마다 매번 응답 메시지가 있길 바랄 수도 있다. 그렇지 않으면 게이트웨이 메소드는 영영 반환되지 않고 멈춰버릴<sup>hang</sup> 수 있다. 이 상황을 해결하는 한 가지 방법은 비동기 게이트웨이를 사용하는 거다 (뒤에서 설명한다). 또 다른 방법으론 <code class="highlighter-rouge">reply-timeout</code> 속성을 명시하는 방법이 있다. 게이트웨이는 <code class="highlighter-rouge">reply-timeout</code>으로 지정한 시간 이상으로 멈춰있지<sup>hang</sup> 않으며, 해당 시간만큼 경과하면 'null'을 반환한다. 마지막으로, 서비스 activator에서 'requires-reply'와 같은 다운스트림 플래그를 설정하거나 필터에서 'throw-exceptions-on-rejection'을 설정하는 걸 검토해보는 게 좋다. 이 옵션들은 이 챕터의 마지막 섹션에서 좀더 자세히 논한다.</p>
</blockquote>


> 다운스트림 플로우가 `ErrorMessage`를 반환하면 해당 `payload`(`Throwable`)는 일반적인 다운스트림 에러로 처리된다. `error-channel`이 설정돼 있으면 에러 플로우로 전송되며, 그렇지 않으면 게이트웨이 호출부로 페이로드를 던진다. 유사하게 `error-channel`의 에러 플로우에서 `ErrorMessage`를 반환하면 호출부에 해당 페이로드를 던진다. 이는 `Throwable` 페이로드를 가진 모든 메시지에 동일하게 적용된다. 비동기 상황에서 호출자에게 직접 `Exception`을 전파해야 할 때 유용할 거다. 이땐 `Exception`을 반환하거나 (특정 서비스의 `reply`로) 던지면 된다. 일반적으로, 비동기 플로우라 하더라도 다운스트림 플로우에서 발생한 예외는 프레임워크가 게이트웨이로 다시 전파해준다. [TCP Client-Server Multiplex](https://github.com/spring-projects/spring-integration-samples/tree/main/intermediate/tcp-client-server-multiplex) 샘플에선 호출자에게 예외를 반환하는 두 가지 테크닉을 모두 살펴볼 수 있다. 이 샘플에선 `aggregator`와 `group-timeout`([Aggregator와 Group Timeout](../messaging-routing/#aggregator-and-group-timeout) 참고)을 이용해 소켓 IO 오류를 발생시키며, discard 플로우에서 대기 중인 스레드에 `MessagingTimeoutException` 응답을 보낸다. 

### 10.4.10. Gateway Timeouts

게이트웨이는 `requestTimeout`과 `replyTimeout`이라는 두 가지 타임아웃 프로퍼티를 가지고 있다. `requestTimeout`은 채널이 블로킹될 수 있는 경우에만 적용된다 (예를 들어 유한<sup>bounded</sup> `QueueChannel`이 가득 찼을 때). `replyTimeout` 값은 게이트웨이가 응답을 기다리는 시간으로, 이 시간이 지나면 `null`을 반환한다. 기본값은 무한대다.

이 타임아웃 값들은 게이트웨이의 모든 메소드나 (`defaultRequestTimeout`, `defaultReplyTimeout`) `MessagingGateway` 인터페이스 어노테이션에서 사용할 기본값으로 설정할 수 있다. 개별 메소드에선 자식 요소 `<method/>`나 `@Gateway` 어노테이션에서 기본값을 재정의할 수 있다.

5.0 버전부터 다음과 같이 표현식으로 타임아웃을 정의할 수 있다:

```java
@Gateway(payloadExpression = "#args[0]", requestChannel = "someChannel",
        requestTimeoutExpression = "#args[1]", replyTimeoutExpression = "#args[2]")
String lateReply(String payload, long requestTimeout, long replyTimeout);
```

평가 컨텍스트는 `BeanResolver`를 가지고 있으며 (다른 빈을 참조하려면 `@someBean`을 사용해라), 배열 변수 `#args`를 이용할 수 있다.

XML로 설정할 땐, 다음 예제와 같이 타임아웃 속성에 긴 값이나 SpEL 표현식을 사용할 수 있다:

```xml
<method name="someMethod" request-channel="someRequestChannel"
                      payload-expression="#args[0]"
                      request-timeout="1000"
                      reply-timeout="#args[1]">
</method>
```

### 10.4.11. Asynchronous Gateway

메시징 게이트웨이는 하나의 패턴으로, 메시지 시스템의 기능은 전부 사용하면서도 메시지 처리와 관련된 코드는 숨길 수 있게 해준다. [앞서 언급한](#1041-enter-the-gatewayproxyfactorybean) `GatewayProxyFactoryBean` 덕분에 서비스 인터페이스를 통해 간편하게 프록시를 노출하고, 메시징 시스템에 POJO 기반으로 (자체 도메인 객체나, 프리미티브<sup>primitive</sup>/문자열, 기타 다른 객체 기반) 접근할 수 있다. 하지만 값을 반환하는 POJO 메소드에서 게이트웨이를 이용하는 경우, 각 요청 메시지(메소드를 실행할 때 생성되는)마다 응답 메시지(메소드를 반환하면 생성되는)가 반드시 있어야 함을 의미한다. 메시징 시스템은 본래 비동기이므로 "각 요청마다 항상 응답이 존재할 것"이라는 규약을 항상 보장하기 어렵다. Spring Integration 2.0은 비동기 게이트웨이를 도입해서, 응답을 기다릴지나 응답이 도착하기까지 걸리는 시간을 알 수 없는 상황에서도 플로우를 간편하게 시작할 수 있다.

이런 상황을 위해 Spring Integration은 `java.util.concurrent.Future` 인스턴스를 이용해 비동기 게이트웨이를 지원한다.

XML 설정에선 아무 것도 달라지지 않으며, 비동기 게이트웨이를 정의할 때도 아래 예시처럼 일반적인 게이트웨이를 정의할 때와 동일한 설정을 이용하면 된다:

```xml
<int:gateway id="mathService"
     service-interface="org.springframework.integration.sample.gateway.futures.MathServiceGateway"
     default-request-channel="requestChannel"/>
```

하지만 게이트웨이 인터페이스(서비스 인터페이스)는 다음과 같이 약간 달라진다:

```java
public interface MathServiceGateway {

  Future<Integer> multiplyByTwo(int i);

}
```

위 예제에 보이듯이, 이 게이트웨이 메소드의 반환 타입은 `Future`다. `GatewayProxyFactoryBean`은 게이트웨이 메소드의 반환 타입이 `Future`임을 확인하면 `AsyncTaskExecutor`를 사용해 즉시 비동기 모드로 전환한다. 비동기 게이트웨이는 이 정도의 차이만 있다. 이런 메소드를 호출하면 항상 `Future` 인스턴스를 즉시 반환한다. 그런 다음 원하는 타이밍에 `Future`와 상호 작용해 결과를 얻거나 취소하는 등의 작업을 수행할 수 있다. 또한 평소 `Future` 인스턴스를 사용할 때와 마찬가지로 `get()`을 호출하면 타임아웃, 실행 예외 등이 발생할 수 있다. 다음 예제는 비동기 게이트웨이가 반환하는 `Future`를 사용하는 방법을 보여주는 예시다:

```java
MathServiceGateway mathService = ac.getBean("mathService", MathServiceGateway.class);
Future<Integer> result = mathService.multiplyByTwo(number);
// do something else here since the reply might take a moment
int finalResult =  result.get(1000, TimeUnit.SECONDS);
```

좀 더 상세한 예제는 Spring Integration samples 레포지토리에 있는 [async-gateway](https://github.com/spring-projects/spring-integration-samples/tree/main/intermediate/async-gateway)를 참고해라.

#### `ListenableFuture`

비동기 게이트웨이 메소드는 4.1 버전부터 `ListenableFuture`(Spring Framework 4.0에서 도입했다)도 반환할 수 있다. 이 타입을 반환하면 실행 결과를 사용할 수 있는 시점에 (혹은 예외가 발생했을 때) 호출할 콜백을 제공할 수 있다. 게이트웨이가 이 리턴 타입을 감지하고 동시에 [task executor](#asynctaskexecutor)가 `AsyncListenableTaskExecutor`라면, 이 executor의 `submitListenable()` 메소드를 실행한다. 다음은 `ListenableFuture`를 사용하는 방법을 보여주는 예시다:

```java
ListenableFuture<String> result = this.asyncGateway.async("something");
result.addCallback(new ListenableFutureCallback<String>() {

    @Override
    public void onSuccess(String result) {
        ...
    }

    @Override
    public void onFailure(Throwable t) {
        ...
    }
});
```

#### `AsyncTaskExecutor`

`GatewayProxyFactoryBean`은 기본적으로 리턴 타입이 `Future`인 게이트웨이 메소드에서 내부 `AsyncInvocationTask` 인스턴스를 제출<sup>submit</sup>할 땐 `org.springframework.core.task.SimpleAsyncTaskExecutor`를 사용한다. 하지만 `<gateway/>` 요소에서 `async-executor` 속성을 이용하면 스프링 애플리케이션 컨텍스트 내에서 사용할 수 있는 `java.util.concurrent.Executor` 구현체를 참조시킬 수 있다.

(디폴트) `SimpleAsyncTaskExecutor`는 리턴 타입이 `Future`와 `ListenableFuture`일 때를 모두 지원하여며,각각 `FutureTask`와 `ListenableFutureTask`를 반환한다. [`CompletableFuture`](#completablefuture)를 참고해라. 디폴트 executor가 있더라도, 아래 예제처럼 외부 executor를 하나 제공하면 로그에서 스레드를 식별할 수 있어 유용하다 (XML을 사용할 땐 executor의 빈 이름을 기반으로 스레드 명이 정해진다):

```java
@Bean
public AsyncTaskExecutor exec() {
    SimpleAsyncTaskExecutor simpleAsyncTaskExecutor = new SimpleAsyncTaskExecutor();
    simpleAsyncTaskExecutor.setThreadNamePrefix("exec-");
    return simpleAsyncTaskExecutor;
}

@MessagingGateway(asyncExecutor = "exec")
public interface ExecGateway {

    @Gateway(requestChannel = "gatewayChannel")
    Future<?> doAsync(String foo);

}
```

다른 `Future` 구현체를 반환하고 싶다면, 커스텀 executor를 제공하거나, executor를 완전히 비활성화하고 `Future`를 다운스트림 플로우의 응답 메시지 페이로드 안에 넣어 반환하면 된다. executor를 비활성화하려면 `GatewayProxyFactoryBean`에서 `null`로 세팅해라 (`setAsyncTaskExecutor(null)`). XML로 게이트웨이를 설정할 땐 `async-executor=""`를 사용해라. `@MessagingGateway` 어노테이션을 이용해 설정하는 경우 아래와 유사한 코드를 사용하면 된다:

```java
@MessagingGateway(asyncExecutor = AnnotationConstants.NULL)
public interface NoExecGateway {

    @Gateway(requestChannel = "gatewayChannel")
    Future<?> doAsync(String foo);

}
```

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>리턴 타입이 설정한 executor가 지원하지 않는 <code class="highlighter-rouge">Future</code>의 특정 구현체이거나 다른 하위 인터페이스인 경우, 플로우는 호출자의 스레드에서 실행되며, 이땐 플로우에서 반드시 응답 메시지 페이로드에서 요구하는 타입을 반환해야 한다.</p>
</blockquote>

#### `CompletableFuture`

게이트웨이 메소드는 4.2 버전부터 `CompletableFuture<?>`를 반환할 수 있다. 이 타입을 반환할 땐 두 가지 모드로 실행할 수 있다:

- 비동기 executor를 하나 제공하고 리턴 타입이 정확히 `CompletableFuture`(서브클래스가 아닌)인 경우, 프레임워크는 이 executor에서 태스크를 실행하고 호출부에 즉시 `CompletableFuture`를 반환한다. 이 future를 만드는 덴 `CompletableFuture.supplyAsync(Supplier<U> supplier, Executor executor)`를 사용한다.
- 비동기 executor가 `null`로 명시되어있고 리턴 타입이 `CompletableFuture` 또는 `CompletableFuture`의 하위 클래스인 경우, 호출자의 스레드에서 플로우를 실행한다. 이 시나리오에선 다운스트림 플로우가 적절한 타입의 `CompletableFuture`를 반환할 것이라 예상한다.

##### 사용 시나리오

아래 시나리오에선, 호출자 스레드는 `CompletableFuture<Invoice>`와 함께 즉시 반환된다. 이 feature는 다운스트림 플로우가 게이트웨이에 응답할 때 완료된다 (`Invoice` 객체와 함께).

```java
CompletableFuture<Invoice> order(Order order);
```

```xml
<int:gateway service-interface="something.Service" default-request-channel="orders" />
```

아래 시나리오에선, 호출자 스레드는 다운스트림 플로우가 게이트웨이에 대한 응답 페이로드로 `CompletableFuture<Invoice>`를 제공할 때 반환된다. 송장<sup>invoice</sup>이 준비되면 다른 프로세스에서 future를 완료해야 한다.

```java
CompletableFuture<Invoice> order(Order order);
```

```xml
<int:gateway service-interface="foo.Service" default-request-channel="orders"
    async-executor="" />
```

아래 시나리오에선, 호출자 스레드는 다운스트림 플로우가 게이트웨이에 대한 응답 페이로드로 `CompletableFuture<Invoice>`를 제공할 때 반환된다. 송장<sup>invoice</sup>이 준비되면 다른 프로세스에서 future를 완료해야 한다. `DEBUG` 로그를 활성화했다면 이 시나리오엔 비동기 executor를 사용할 수 없다는 로그가 기록된다.

```java
MyCompletableFuture<Invoice> order(Order order);
```

```xml
<int:gateway service-interface="foo.Service" default-request-channel="orders" />
```

`CompletableFuture` 인스턴스를 이용해 다음과 같이 응답을 추가로 조작할 수도 있다:

```java
CompletableFuture<String> process(String data);

...

CompletableFuture result = process("foo")
    .thenApply(t -> t.toUpperCase());

...

String out = result.get(10, TimeUnit.SECONDS);
```

#### Reactor `Mono`

`GatewayProxyFactoryBean`은 5.0 버전부터 게이트웨이 인터페이스 메소드에서 [프로젝트 리액터](https://projectreactor.io/)를 사용할 수 있게 지원한다. [`Mono`](https://github.com/reactor/reactor-core)를 리턴 타입으로 사용하면 된다. 내부 `AsyncInvocationTask`는 `Mono.fromCallable()`로 감싸진다.

`Mono`는 나중에 결과를 조회할 때 사용할 수 있으며 (`Future<?>`와 유사하다), 또는 게이트웨이로 결과가 반환되면 `Consumer`를 실행하는 식으로 dispatcher와 함께 사용할 수 있다.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p><code class="highlighter-rouge">Mono</code>는 프레임워크에 의해 곧바로 플러시되지 않는다. 그렇기 때문에 내부 메시지 플로우는 게이트웨이 메소드가 반환되기 전까진 시작되지 않는다 (<code class="highlighter-rouge">Future&lt;?&gt;</code> <code class="highlighter-rouge">Executor</code> 태스크에서와 같이). 플로우는 <code class="highlighter-rouge">Mono</code>가 구독되면 시작한다. 또는 <code class="highlighter-rouge">subscribe()</code>가 전체 <code class="highlighter-rouge">Flux</code>와 관련돼있다면, <code class="highlighter-rouge">Mono</code>("Composable")가 리액터 스트림의 일부일 수도 있다. 다음은 프로젝트 리액터로 게이트웨이를 생성하는 방법을 보여주는 예시다:</p>
</blockquote>

```java
@MessagingGateway
public static interface TestGateway {

	@Gateway(requestChannel = "promiseChannel")
	Mono<Integer> multiply(Integer value);

	}

	    ...

	@ServiceActivator(inputChannel = "promiseChannel")
	public Integer multiply(Integer value) {
			return value * 2;
	}

		...

    Flux.just("1", "2", "3", "4", "5")
            .map(Integer::parseInt)
            .flatMap(this.testGateway::multiply)
            .collectList()
            .subscribe(integers -> ...);
```

프로젝트 리액터를 사용하는 또 다른 예시로 아래 있는 간단한 콜백 시나리오를 들 수 있다:

```java
Mono<Invoice> mono = service.process(myOrder);

mono.subscribe(invoice -> handleInvoice(invoice));
```

호출 스레드는 계속 이어지며, 플로우가 완료되면 `handleInvoice()`를 호출한다.

#### Downstream Flows Returning an Asynchronous Type

위에서 `ListenableFuture`를 설명하며 언급했듯이, 특정 다운스트림 구성 요소가 비동기 페이로드를 가진 (`Future`, `Mono` 등) 메시지를 반환하게 만들고 싶다면, 반드시 비동기 executor를 `null`로 명시해줘야 한다 (XML 설정을 사용하는 경우 `""`). 그러면 호출자 스레드에서 플로우를 실행하며, 그 결과는 나중에 조회할 수 있다.

#### `void` Return Type

앞에서 언급했던 리턴 타입들과는 달리, 메소드 리턴 타입이 `void`인 경우엔, 호출자 스레드는 즉시 반환하고 비동기로 다운스트림 플로우를 실행하는 것을 의도한 건지를 프레임워크가 판단하기 어렵다. 이런 경우엔 반드시 아래 예제처럼 인터페이스 메소드 위에 `@Async` 어노테이션을 선언해줘야 한다:

```java
@MessagingGateway
public interface MyGateway {

    @Gateway(requestChannel = "sendAsyncChannel")
    @Async
    void sendAsync(String payload);

}
```

`Future<?>` 타입을 반환할 때와는 달리, 특정 커스텀 `TaskExecutor`를 `@Async` 어노테이션과 연결해주지 않고서는 플로우에서 예외를 던졌는지를 호출자에게 알릴 수 있는 방법이 없다.

### 10.4.12. Gateway Behavior When No response Arrives

[앞에서 언급한 대로](#1041-enter-the-gatewayproxyfactorybean) 게이트웨이를 이용하면 간편하게 POJO 메소드를 실행해서 메시징 시스템과 상호 작용할 수 있다. 반면 일반적인 메소드를 실행하면 언제나 반환되는데 (예외가 발생하더라도), 메시지를 교환하는 상황은 일반적인 메소드 실행과 일대일로 매핑되지 않기도 한다 (예를 들면, 응답 메시지가 도착하지 않을 수도 있다 — 이는 반환되지 않는 메소드와 동일하다).

여기서부터는 다양한 시나리오들과 함께 게이트웨이를 어떻게 하면 좀 더 예측 가능한 방향으로 동작시킬 수 있는지를 다룬다. 동기식으로 동작하는 게이트웨이는 특정 속성들을 이용해 예측이 가능한 방향으로 구성할 수 있지만, 속성에 따라 예상대로 동작하지 않는 상황도 벌어진다. 그 중 하나는 `reply-timeout`이다 (메소드 레벨. 게이트웨이 레벨에선 `default-reply-timeout`). 여기서는 다양한 시나리오를 통해 `reply-timeout` 속성이 동기식 게이트웨이의 동작에 영향을 줄 수 있는 것과 없는 것들을 알아본다. 싱글 스레드 시나리오(다운스트림의 모든 구성 요소가 direct 채널을 통해 연결된다)와 멀티 스레드 시나리오(예를 들어, 다운스트림 어딘가에 싱글 스레드의 범위를 벗어나는 pollable 채널이나 executor 채널이 있을 수 있다)를 나눠서 생각해본다.

#### 다운스트림 프로세스가 오랫동안 실행될 때

- Sync Gateway, single-threaded

  다운스트림 구성 요소가 계속해서 실행 중인 경우 (아마도 무한 루프에 빠졌거나 서비스가 느려서) `reply-timeout`을 설정해도 아무런 효과가 없으며, 다운스트림 서비스가 종료될 때까지 (반환하거나 예외를 던져서) 게이트웨이 메소드는 반환되지 않는다.

- Sync Gateway, multi-threaded

  멀티 스레드 메시지 플로우에서 다운스트림 구성 요소가 계속해서 실행 중인 경우 (아마도 무한 루프에 빠졌거나 서비스가 느려서) `reply-timeout`을 설정하면 효과가 있는데, 타임아웃 발생 시 게이트웨이 메소드 실행부가 반환된다. `GatewayProxyFactoryBean`이 타임아웃이 만료될 때까지 기다리며 응답 채널을 폴링하기 때문이다. 하지만 실제 응답이 만들어지기 전에 타임아웃이 발생하면 게이트웨이 메소드에서 'null'을 반환하게 될 수 있다. 응답 메시지는 (생성됐다면) 게이트웨이 메소드 실행부가 반환된 후에 응답 채널로 보내진다는 점을 이해하고 있어야 한다. 이 사실을 염두에 두고 플로우를 설계하는 것이 좋다 .

#### 다운스트림 구성 요소가 'null'을 반환할 때

- Sync Gateway — single-threaded

  다운스트림 구성 요소가 'null'을 반환했는데 `reply-timeout`이 설정돼있지 않은 경우, 게이트웨이 메소드 실행부는 무기한으로 멈추게된다<sup>hang</sup>. `reply-timeout`을 설정하거나 'null'을 반환할 수 있는 다운스트림 구성 요소(ex. 서비스 activator)에 `requires-reply` 속성이 설정돼있지 않다면 말이다. 이 경우 예외를 던지고 게이트웨이로 전파된다.

- Sync Gateway — multi-threaded

  위 케이스와 동일하게 동작한다.

#### 다운스트림 구성 요소의 반환 타입은 'void'인데 게이트웨이 메소드 시그니처는 void가 아닐 때

- Sync Gateway — single-threaded

  다운스트림 구성 요소가 'void'를 반환할 때 `reply-timeout`이 설정돼있지 않다면, 게이트웨이 메소드 실행부는 무기한으로 멈추게된다<sup>hang</sup>. `reply-timeout`을 설정하지 않는다면 말이다.

- Sync Gateway — multi-threaded

  위 케이스와 동일하게 동작한다.

#### 다운스트림 구성 요소가 Runtime Exception으로 끝났을 때

- Sync Gateway — single-threaded

  다운스트림 구성 요소에서 런타임 예외가 발생하면, 예외는 에러 메시지를 통해 게이트웨이로 다시 전파되고 다시 던져진다.

- Sync Gateway — multi-threaded

  위 케이스와 동일하게 동작한다.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p><code class="highlighter-rouge">reply-timeout</code>은 디폴트가 무한<sup>unbounded</sup>이라는 점을 알아두는 게 좋다. 그렇기 때문에 <code class="highlighter-rouge">reply-timeout</code>을 명시하지 않으면 게이트웨이 메소드 실행부는 무기한으로 멈출 수도 있다<sup>hang</sup>. 따라서 이런 시나리오 중 하나라도 해당될 가능성이 희박하더라도, 플로우를 분석해서 <code class="highlighter-rouge">reply-timeout</code> 속성을 "안전한" 값으로 설정해놔야 한다. 다운스트림 구성 요소의 <code class="highlighter-rouge">requires-reply</code> 속성을 'true'로 설정하면 더 좋은데, 다운스트림 구성 요소가 내부적으로 null을 반환하면 즉시 예외를 던지기 때문에 응답을 보장할 수 있다. 하지만 <code class="highlighter-rouge">reply-timeout</code>이 아무런 소용이 없는 상황도 있다는 것도 함께 인지해야 한다 (<a href="#다운스트림-프로세스가-오랫동안-실행될-때">첫 번째 시나리오</a> 참고). 즉, 메시지 플로우를 분석해서 언제 비동기 게이트웨이가 아닌 동기식 게이트웨이를 사용할지를 결정하는 것 또한 중요한 일이다. <a href="#10411-asynchronous-gateway">앞에서 설명한 것처럼</a> 비동기 게이트웨이는 간단히 말하면 <code class="highlighter-rouge">Future</code> 인스턴스를 반환하는 게이트웨이 메소드를 정의하는 일이다. 이렇게 하면 값을 반환한다는 것을 보장받을 수 있으며, 실행 결과를 가지고 좀 더 세부적인 컨트롤이 가능하다. 또한 라우터를 다룰 때는 <code class="highlighter-rouge">resolution-required</code> 속성을 'true'로 설정하면 라우터가 특정 채널을 리졸브할 수 없는 경우엔 예외가 발생한다는 점을 기억해둬야 한다. 마찬가지로 필터를 다룰 땐 <code class="highlighter-rouge">throw-exception-on-rejection</code> 속성을 설정할 수 있다. 둘 모두 <code class="highlighter-rouge">requires-reply</code> 속성을 가진 서비스 activator가 있는 것처럼 동작하게 된다. 다른 말로 하면, 게이트웨이 메소드를 실행할 때 응답 받는 것을 보장하는 데 도움이 된다.</p>
</blockquote>


> `<gateway/>` 요소에서 `reply-timeout`은 무한이다<sup>unbounded</sup> (`GatewayProxyFactoryBean`에서 만들어진다). 외부와의 통합을 위한 인바운드 게이트웨이(WS, HTTP 등)는 이런 게이트웨이들과 공통된 특징과 속성이 많이 있다. 하지만 이런 인바운드 게이트웨이의 경우 디폴트 `reply-timeout`은 1000 밀리세컨드다 (1초). 다운스트림에서 비동기 처리를 다른 스레드가 이어받는 경우, 게이트웨이 타임아웃이 발생하기 전에 플로우가 완료될 수 있도록 이 속성을 늘려야 할 수 있다.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>게이트웨이로 스레드가 반환될 때 타이머가 시작된다는 것을 이해해야 한다. 즉, 플로우가 완료되거나 메시지가 다른 스레드로 전달될 때 말이다. 이 시점부터 호출 스레드는 응답을 기다리기 시작한다. 플로우가 완전히 동기식으로 동작한다면 호출 스레드에서 즉시 응답을 사용하면 된다. 비동기 플로우의 경우 스레드는 이 시간만큼 대기한다.</p>
</blockquote>

`IntegrationFlows`를 이용해 게이트웨이를 정의하는 방법은 Java DSL 챕터에 있는 [`IntegrationFlow` as Gateway](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/dsl.html#integration-flow-as-gateway)를 참고해라.

---

## 10.5. Service Activator

서비스 activator는 엔드포인트 타입 중 하나로, 스프링이 관리하는 객체를 입력 채널에 연결해서 서비스 역할을 담당할 수 있도록 해준다. 서비스가 출력을 생성하는 경우엔 출력 채널에도 연결할 수 있다. 출력이 있는 서비스가 처리 파이프라인(또는 메시지 플로우) 상 맨끝에 위치할 수도 있는데, 이 경우엔 인바운드 메시지의 `replyChannel` 헤더를 활용할 수 있다. 출력 채널이 정의되지 않았을 때의 기본 동작이기도 하다. 여기에서 설명하는 설정 옵션들은 대부분 다른 구성 요소에서도 동일하게 동작한다.

### 10.5.1. Configuring Service Activator

서비스 activator를 생성할 땐 다음과 같이 'service-activator' 요소와 'input-channel', 'ref' 속성을 이용하면 된다:

```xml
<int:service-activator input-channel="exampleChannel" ref="exampleHandler"/>
```

위 설정에선 `exampleHandler`의 메소드들 중, 다음과 같은 메시지 처리 요구 사항 중 하나를 충족하는 메소드들을 전부 선별한다:

- `@ServiceActivator` 어노테이션을 선언한 메소드
- `public` 메소드
- `requiresReply == true`라면 `void`를 반환하지 않는 메소드

호출할 타겟 메소드는 런타임에 각 요청 메시지에 있는 `payload` 타입에 따라 선택하거나, 타겟 클래스에 폴백 메소드가 있다면 `Message<?>` 타입 폴백을 사용하기도 한다.

5.0 버전부터 서비스 메소드 하나를 `@org.springframework.integration.annotation.Default`로 마킹하면 매칭되는 케이스가 없을 때 폴백으로 사용할 수 있다. [컨텐츠 타입 변환](#1017-content-type-conversion)을 진행한 후 타겟 매소드를 실행할 때 활용하기 좋다.

객체에 명시되어있는 메소드에 위임하고 싶다면 다음과 같이 `method` 속성을 추가해주면 된다:

```xml
<int:service-activator input-channel="exampleChannel" ref="somePojo" method="someMethod"/>
```

두 케이스 모두 서비스 메소드가 null이 아닌 값을 반환하면, 서비스 activator는 적절한 응답 채널로 응답 메시지를 전송해본다. 응답 채널을 결정할 땐 가장 먼저 다음과 같이 엔드포인트 설정에 `output-channel`을 제공했는지를 확인한다:

```xml
<int:service-activator input-channel="exampleChannel" output-channel="replyChannel"
                       ref="somePojo" method="someMethod"/>
```

메소드는 결과를 반환하는데 `output-channel`이 정의되지 않았다면, 프레임워크는 요청 메시지에 있는 `replyChannel` 헤더를 확인한다. 이 헤더에 값이 들어있으면 해당 타입을 체크해본다. `MessageChannel` 타입이라면 응답 메시지를 이 채널로 전송한다. `String 타입`인 경우 서비스 activator는 해당 채널명을 채널 인스턴스로 리졸브해본다. 채널을 리졸브할 수 없다면 `DestinationResolutionException`을 던진다. 채널을 리졸브할 수 있다면 해당 채널로 메시지를 전송한다. 요청 메시지에 `replyChannel` 헤더가 없고 `reply` 객체가 `Message`였다면 이 메시지의 `replyChannel` 헤더를 참조해서 다음 행선지를 결정한다. 이 테크닉은 Spring Integration에서 request-reply 메시지를 처리할 때도 사용하고 있으며, return address 패턴의 한 예시이기도 하다.

메소드가 결과를 반환하는데, 반환 결과를 폐기<sup>discard</sup>하고 플로우를 종료하고 싶다면, `output-channel`을 `NullChannel`로 전송하도록 설정해야 한다. 프레임워크는 간편하게 이용할 수 있도록 `nullChannel`이라는 이름으로 하나를 등록해준다. 자세한 내용은 [특별한 채널들](../messaging-channels/#616-special-channels)을 참고해라.

서비스 activator는 응답 메시지를 생성하지 않아도 되는 구성 요소 중 하나다. 메소드가 `null`을 반환하거나 리턴 타입이 `void`인 경우 서비스 activator는 메소드를 실행한 후 별도 신호 없이 종료된다. 이 동작은 `AbstractReplyProducingMessageHandler.requiresReply` 옵션으로 제어할 수 있으며, XML 네임스페이스를 이용할 땐 `requires-reply`로 설정하면 된다. 이 플래그를 `true`로 설정했을 때 메소드가 null을 반환하면 `ReplyRequiredException`을 던진다.

서비스 메소드의 인자는 메시지일 수도, 임의의 타입일 수도 있다. 임의의 타입일 땐 메시지 페이로드인 것으로 가정하며, 메시지에서 페이로드를 추출해서 서비스 메소드에 주입해준다. 이렇게 하면 POJO 모델을 따를 수 있으므로, Spring Integration을 이용할 땐 일반적으로 이렇게 사용하기를 권장한다. [어노테이션 지원](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/configuration.html#annotations)에서 설명하는 것처럼 인자들은 `@Header`나 `@Headers` 어노테이션을 선언할 수도 있다.

> 서비스 메소드는 인자가 없어도 되기 때문에, 이벤트 스타일의 서비스 액티베이터를 구현할 수 있으며 (여기선 오로지 서비스 메소드를 실행하는 것에만 관심을 둔다) 메시지의 내용은 신경쓰지 않아도 된다. 메시지가 null JMS 메시지라고 생각해보자. 예를 들면 입력 채널에 보관된 메시지들을 모니터링하거나 간단한 카운터를 구현할 수 있다.

아래 보이는 것 처럼 4.1 버전부터는 메시지 프로퍼티(`payload`, `headers`)를 받는 POJO 메소드 파라미터에 Java 8 `Optional`을 사용해도 문제 없이 변환해준다:

```java
public class MyBean {
    public String computeValue(Optional<String> payload,
               @Header(value="foo", required=false) String foo1,
               @Header(value="foo") Optional<String> foo2) {
        if (payload.isPresent()) {
            String value = payload.get();
            ...
        }
        else {
           ...
       }
    }

}
```

커스텀 서비스 activator 핸들러 구현체를 다른 `<service-activator>` 정의에서 재사용할 수 있다면 보통은 `ref` 속성을 사용하는 게 좋다. 하지만 하나의 `<service-activator>` 정의 안에서만 사용한다면, 다음과 같이 내부 빈 정의를 제공할 수도 있다:

```xml
<int:service-activator id="exampleServiceActivator" input-channel="inChannel"
            output-channel = "outChannel" method="someMethod">
    <beans:bean class="org.something.ExampleServiceActivator"/>
</int:service-activator>
```

> 동일한 `<service-activator>` 설정에서 `ref` 속성과 내부 핸들러 정의를 모두 사용하는 것은 허용하지 않는다. 둘 다 사용하면 조건이 모호해져 예외가 발생한다.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p><code class="highlighter-rouge">ref</code> 속성에서 <code class="highlighter-rouge">AbstractMessageProducingHandler</code>를 상속한 빈을 참조하는 경우 (프레임워크 자체에서 제공하는 핸들러 등), 이 설정은 출력 채널을 핸들러에 직접 주입하는 식으로 최적화된다. 이때는 각 <code class="highlighter-rouge">ref</code> 속성마다 별도 빈 인스턴스(또는 <code class="highlighter-rouge">prototype</code> 스코프 빈)를 참조하거나, 내부 <code class="highlighter-rouge">&lt;bean/&gt;</code> 설정을 이용해야 한다. 무심코 여러 빈에서 동일한 메시지 핸들러를 참조한다면 설정 예외를 만나게될 거다.</p>
</blockquote>

#### Service Activators and the Spring Expression Language (SpEL)

Spring Integration 2.0 이후로는 서비스 activator에서 [SpEL](https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#expressions) 역시 활용할 수 있다.

예를 들면, 다음과 같이 `ref` 속성에서 빈을 가리키거나 내부 빈 정의를 추가하지 않아도 원하는 빈의 메소드를 호출할 수 있다:

```xml
<int:service-activator input-channel="in" output-channel="out"
	expression="@accountService.processAccount(payload, headers.accountId)"/>

	<bean id="accountService" class="thing1.thing2.Account"/>
```

위 설정에선 `ref` 속성이나 내부 빈을 이용해 'accountService'를 주입하지 않고, SpEL의 `@beanId` 표기법을 통해 메시지 페이로드와 호환되는 타입을 하나 받는 메소드를 실행한다. 이땐 헤더 값도 함께 전달한다. 유효한 SpEL 표현식이라면 메시지에 있는 어떤 내용이든지 사용해서 평가할 수 있다. 아래와 같이 전체 로직을 하나의 표현식으로 캡슐화할 수 있다면 서비스 activator는 빈을 참조하지 않아도 된다:

```xml
<int:service-activator input-channel="in" output-channel="out" expression="payload * 2"/>
```

위 설정에선 페이로드 값에 2를 곱하는 것이 서비스 로직이다. SpEL을 사용하면 쉽게 처리할 수 있다.

서비스 activator 설정에 관한 좀 더 자세한 내용은 Java DSL 챕터에 있는 [서비스 액티베이터와 `.handle()` 메소드](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/dsl.html#java-dsl-handle)를 참고해라.

### 10.5.2. Asynchronous Service Activator

서비스 activator는 호출 스레드에서 실행된다. 입력 채널이 `SubscribableChannel`이라면 업스트림 스레드를, `PollableChannel`이라면 폴러 스레드를 뜻한다. 서비스가 `ListenableFuture<?>`를 반환하면 출력(또는 응답) 채널로 보내는 메시지의 페이로드에 이를 담아 보내는 게 기본 동작이다. 4.3 버전부터는 `async` 속성을 `true`로 설정할 수 있다 (자바 설정에선 `setAsync(true)`). `async` 속성을 `true`로 설정했을 때 서비스가 `ListenableFuture<?>`를 반환하면, 호출 스레드는 즉시 release되고 응답 메시지는 future를 완료하는 스레드로 전달된다. 이는 `PollableChannel`을 사용하는, 오랫동안 실행되는 서비스에서 특히 유리하다. 폴러 스레드를 release하면 프레임워크 내에서 다른 서비스를 수행할 수 있기 때문이다.

서비스에서 future를 `Exception`으로 완료하면 일반적인 에러 처리 프로세스를 진행한다. `errorChannel` 헤더가 있다면 이곳으로 `ErrorMessage`를 전송하고, 그 외는 디폴트 `errorChannel`(가능한 경우)로 `ErrorMessage`를 전송한다.

### 10.5.3. Service Activator and Method Return Type

서비스 메소드는 어떤 타입이든지 반환할 수 있으며, 반환 값은 응답 메시지 페이로드가 된다. 이 경우 새로운 `Message<?>` 객체가 만들어지며, 요청 메시지에 있는 헤더들이 전부 복사된다. 대부분의 Spring Integration `MessageHandler` 구현체들은 POJO 메소드 실행을 기반으로 상호 작용할 땐 이런 방식으로 동작한다.

서비스 메소드에서 `Message<?>` 객체를 완성해서 반환할 수도 있다. 하지만 [트랜스포머](../messaging-transformation/#91-transformer)와 달리 Service Activator에선, 반환된 메시지에 요청 메시지에 있던 헤더가 없다면 요청 메시지에서 헤더를 복사해서 메시지를 수정한다. 따라서 메소드 파라미터가 `Message<?>`일 때 서비스 메소드에서 기존 헤더의 전부가 아닌 일부만 복사하더라도, 응답 메시지엔 전부 다시 나타날 거다. 응답 메시지에서 헤더를 제거하는 일은 Service Activator의 책임이 아니며, 느슨한 결합이라는 원칙을 추구한다면 통합 플로우에 `HeaderFilter`를 추가해주는 게 좋다. 아니면 Service Activator대신 Transformer를 사용해도 좋지만, 이 경우 `Message<?>` 전체를 반환한다면 요청 메시지의 헤더를 복사하는 일(필요한 경우)을 포함해서, 메시지에 대한 모든 책임은 메소드에 있다. 프레임워크의 중요 헤더가 있다면 (e.g. `replyChannel`, `errorChannel`) 반드시 보존해줘야 한다.

---

## 10.6. Delayer

delayer는 메시지 플로우를 정해진 간격으로 지연시키는 간단한 엔드포인트다. 메시지가 지연될 땐 기존 sender를 블로킹하지 않는다. 그보단 지연된 메시지는 `org.springframework.scheduling.TaskScheduler` 인스턴스로 스케줄링되어 지연 시간이 지난 이후 출력 채널로 전송된다. 이 처리 방식은 많은 양의 sender 스레드를 블로킹하지 않기 때문에 지연 시간이 다소 길더라도 확장이 가능하다. 반면, 일반적인 케이스라면 메시지를 실제로 놓아줄<sup>release</sup> 땐 쓰레드 풀을 사용한다. 이 섹션에선 delayer를 설정하는 예제를 몇 가지 다뤄본다.

### 10.6.1. Configuring a Delayer

`<delayer>` 요소는 두 메시지 채널 사이의 메시지 플로우를 지연시킬 때 사용한다. 다른 엔드포인트들과 마찬가지로 'input-channel'과 'output-channel' 속성을 제공할 수 있지만, delayer는 각 메시지를 지연시킬 시간(밀리세컨드)을 결정하는 'default-delay'와 'expression' 속성(그리고 'expression' 요소)도 가지고 있다. 다음은 모든 메시지를 3초씩 지연시키는 예시다:

```xml
<int:delayer id="delayer" input-channel="input"
             default-delay="3000" output-channel="output"/>
```

메시지마다 각자 지연 시간을 결정해야 할 때는 다음과 같이 'expression' 속성을 이용해 SpEL 표현식을 지정할 수도 있다:

<div class="switch-language-wrapper java-dsl kotlin-dsl java xml">
<span class="switch-language java-dsl">Java DSL</span>
<span class="switch-language kotlin-dsl">Kotlin DSL</span>
<span class="switch-language java">Java</span>
<span class="switch-language xml">XML</span>
</div>
<div class="language-only-for-java-dsl java-dsl kotlin-dsl java xml"></div>
```java
@Bean
public IntegrationFlow flow() {
    return IntegrationFlows.from("input")
            .delay("delayer.messageGroupId", d -> d
                    .defaultDelay(3_000L)
                    .delayExpression("headers['delay']"))
            .channel("output")
            .get();
}
```
<div class="language-only-for-kotlin-dsl java-dsl kotlin-dsl java xml"></div>
```kotlin
@Bean
fun flow() =
    integrationFlow("input") {
        delay("delayer.messageGroupId") {
            defaultDelay(3000L)
            delayExpression("headers['delay']")
        }
        channel("output")
    }
```
<div class="language-only-for-java java-dsl kotlin-dsl java xml"></div>
```java
@ServiceActivator(inputChannel = "input")
@Bean
public DelayHandler delayer() {
    DelayHandler handler = new DelayHandler("delayer.messageGroupId");
    handler.setDefaultDelay(3_000L);
    handler.setDelayExpressionString("headers['delay']");
    handler.setOutputChannelName("output");
    return handler;
}
```
<div class="language-only-for-xml java-dsl kotlin-dsl java xml"></div>
```xml
<int:delayer id="delayer" input-channel="input" output-channel="output"
             default-delay="3000" expression="headers['delay']"/>
```

위 예시에서 설정한 3초라는 시간은 주어진 인바운드 메시지에서 표현식이 null로 평가될 때에만 적용된다. 표현식을 평가한 결과가 유효한 메시지에만 지연 시간을 적용하려면 'default-delay'를 `0`(디폴트)으로 설정하면 된다. 지연 시간이 `0`(또는 그 이하)인 메시지는 호출 스레드에서 즉시 메시지를 전송한다.

> XML 파서는 메시지 그룹 ID(`<beanName>.messageGroupId`)를 사용한다.

> delay 핸들러에선 표현식으로 밀리세컨드 단위의 시간 간격을 나타낼 수 있으며 (`toString()` 메소드의 실행 결과를 `Long`으로 파싱할 수 있는 `Object`), 절대 시간을 나타내는 `java.util.Date` 인스턴스를 만들어도 된다. 첫 번째 케이스에선 현재 시간을 기준으로 밀리세컨드를 계산한다 (예를 들어 `5000`으로 평가된다면, delayer가 메시지를 수신한 시간으로부터 최소 5초 동안 메시지를 지연시킨다). `Date` 인스턴스를 사용하면 해당 `Date` 객체가 나타내는 시간이 될 때까지 메시지를 놓아주지<sup>release</sup> 않는다. 지연 시간이 양수가 아니거나 과거 날짜에 해당하는 값이라면 지연이 발생하지 않는다. 그대신 기존 sender의 스레드에서 출력 채널로 곧장 전송된다. 표현식을 평가한 결과가 `Date`도 아니고 `Long`으로 파싱할 수도 없는 경우엔 디폴트 지연 시간(있다면 — 디폴트는 `0`)을 적용한다.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>표현식을 평가하는 중엔 잘못된 표현식을 사용하는 등의 이유로 evaluation exception이 발생할 수 있다. 이런 예외들은 기본적으로 무시되며 (DEBUG 레벨로 로그를 남기기는 한다), delayer는 디폴트 지연 시간(있다면)으로 폴백한다. 이 동작은 <code class="highlighter-rouge">ignore-expression-failures</code> 속성을 설정하면 수정할 수 있다. 이 속성은 기본적으로 <code class="highlighter-rouge">true</code>로 설정되며, delayer는 방금 설명한대로 동작한다. 반대로 evaluation exception을 무시하는 대신 delayer의 호출부로 던지고 싶다면 <code class="highlighter-rouge">ignore-expression-failures</code> 속성을 <code class="highlighter-rouge">false</code>로 설정해라.</p>
</blockquote>

> 위 예제에선 delay 표현식을 `headers['delay']`로 지정했다. 이 구문은 `Map` 요소에 액세스하기 위한 SpEL `Indexer` 구문이다 (`MessageHeaders`는 `Map`을 구현하고 있다). 이 구문은 `headers.get("delay")`를 호출한다. 맵 요소의 이름이 간단할 땐 ('.'이 들어있지 않을 땐) SpEL “dot accessor” 구문도 사용할 수 있다. 그러면 이 헤더 표현식은 `headers.delay`로 명시할 수 있다. 하지만 헤더가 누락됐을 때의 결과는 달라진다. 첫 번째 케이스에서 표현식은 `null`로 평가된다. 두 번째 케이스에선 다음과 유사한 결과를 낳게 된다:
>
> ```java
> org.springframework.expression.spel.SpelEvaluationException: EL1008E:(pos 8):
> 		   Field or property 'delay' cannot be found on object of type 'org.springframework.messaging.MessageHeaders'
> ```
>
> 결과적으로, 헤더가 생략될 가능성이 있고 디폴트 지연 시간으로 폴백하고 싶다면, 예외를 catch하는 것보단 null을 감지하는 것이 더 빠르기 때문에, dot property accessor 구문 보단 indexer 구문을 사용하는 것이 일반적으로 더 효율적이다 (권장하는 방법이기도 하다).

delayer는 동작을 스프링 `TaskScheduler` 인터페이스의 인스턴스에 위임한다. delayer에서 사용하는 디폴트 스케줄러는 Spring Integration에서 기동 시 제공하는 `ThreadPoolTaskScheduler` 인스턴스다. 자세한 내용은 [태스크 스케줄러 설정하기](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/configuration.html#namespace-taskscheduler)를 참고해라. 다른 스케줄러에 위임하고 싶다면, 다음과 같이 delayer 요소의 'scheduler' 속성을 통해 참조를 제공하면 된다:

```xml
<int:delayer id="delayer" input-channel="input" output-channel="output"
    expression="headers.delay"
    scheduler="exampleTaskScheduler"/>

<task:scheduler id="exampleTaskScheduler" pool-size="3"/>
```

> 외부 `ThreadPoolTaskScheduler`를 설정한다면 스케줄러 프로퍼티에 `waitForTasksToCompleteOnShutdown = true`를 설정할 수 있다. 이 설정을 이용하면 애플리케이션을 종료할 때 이미 실행 상태에 있는 'delay' 태스크를 완전하게 완료할 수 있다 (메시지를 놓아주는<sup>release</sup> 등). Spring Integration 2.2 이전에는 `DelayHandler`가 백그라운드에서 자체 스케줄러를 생성할 수 있었기 때문에 `<delayer>` 요소에서 이 프로퍼티를 사용할 수 있었다. 2.2부터 delayer는 외부 스케줄러 인스턴스가 필요하며 `waitForTasksToCompleteOnShutdown`은 제거됐다. 이제 스케줄러의 자체 설정을 사용해야 한다.

> `ThreadPoolTaskScheduler`는 `errorHandler`라는 속성이 있는데, 이 속성엔 `org.springframework.util.ErrorHandler`의 구현체를 주입할 수 있다. 이 핸들러를 이용하면 지연된 메시지를 전송하는 예약 태스크 스레드에서 발생하는 `Exception`을 처리할 수 있다. 기본적으론 `org.springframework.scheduling.support.TaskUtils$LoggingErrorHandler`를 사용하며, 로그에서 스택 트레이스를 확인할 수 있다. `org.springframework.integration.channel.MessagePublishingErrorHandler` 사용을 검토해보는 것도 좋다. 이 구현체는 `ErrorMessage`를 실패한 메시지의 헤더에 있는 `error-channel`이나 디폴트 `error-channel`로 전송해준다. 이때 에러 처리는 트랜잭션을 (있다면) 롤백한 이후에 진행한다. [릴리즈 실패](#1063-release-failures)를 참고해라.

### 10.6.2. Delayer and a Message Store

`DelayHandler`는 설정에 있는 `MessageStore`의 메시지 그룹에 지연된 메시지를 보관한다. ('groupId'는 `<delayer>` 요소의 필수 속성 'id'를 기반으로 만들어진다.) 예약 태스크에선 `DelayHandler`가 `output-channel`로 메시지를 전송하기 직전에 `MessageStore`에서 지연된 메시지를 제거한다. 설정한 `MessageStore`가 영구적인<sup>persistent</sup> 스토어라면 (ex. `JdbcMessageStore`), 애플리케이션이 종료해도 메시지를 잃어버리지 않는다. `DelayHandler`는 애플리케이션이 기동되면 `MessageStore`의 메시지 그룹에서 메시지를 읽어와, 메시지의 기존 도착 시간을 기반으로 delay 태스크를 다시 예약한다 (delay가 숫자일 때). delay 헤더가 `Date`인 메시지에선 이 `Date`를 사용해 다시 스케줄링한다. 지연된 메시지가 'delay' 값보다 더 오래 `MessageStore`에 남아 있었다면 기동 직후에 전송한다.

`<delayer>`는 두 가지 요소 `<transactional>`과 `<advice-chain>` 중 하나로 보강할 수 있다 (이 둘은 함께 사용할 수 없다). 이 AOP 어드바이스의 `List`는 `DelayHandler.ReleaseMessageHandler`로 적용돼 내부에서 프록시 처리된다. 이 핸들러는 예약된 태스크의 `Thread`에서 지연 시간이 지난 이후 메시지를 릴리즈하는 일을 담당한다. 예를 들면 다운스트림 메시지 플로우에서 예외가 발생해 `ReleaseMessageHandler`의 트랜잭션을 롤백하는 상황 등에 활용된다. 이 경우 지연된 메시지는 영구<sup>persistent</sup> `MessageStore`에 남게된다. `<advice-chain>` 안에선 원하는 커스텀 `org.aopalliance.aop.Advice` 구현체도 사용할 수 있다. `<transactional>` 요소는 트랜잭션 어드바이스만 가지고 있는 간단한 어드바이스 체인을 정의한다. 다음은 `<delayer>` 안에서 `advice-chain`을 사용하는 예제다:

```xml
<int:delayer id="delayer" input-channel="input" output-channel="output"
    expression="headers.delay"
    message-store="jdbcMessageStore">
    <int:advice-chain>
        <beans:ref bean="customAdviceBean"/>
        <tx:advice>
            <tx:attributes>
                <tx:method name="*" read-only="true"/>
            </tx:attributes>
        </tx:advice>
    </int:advice-chain>
</int:delayer>
```

`DelayHandler`는 관리하는 오퍼레이션(`getDelayedMessageCount`, `reschedulePersistedMessages`)을 통해 JMX `MBean`으로 익스포트할 수 있다. 이를 통해 보관 중인<sup>persisted</sup> 지연 메시지를 런타임에 다시 스케줄링할 수 있다 (예를 들어 `TaskScheduler`가 이전에 중단된 상태인 경우). 이런 류의 오퍼레이션은 다음과 같이 `Control Bus` 명령을 통해 실행할 수 있다:

```java
Message<String> delayerReschedulingMessage =
    MessageBuilder.withPayload("@'delayer.handler'.reschedulePersistedMessages()").build();
controlBusChannel.send(delayerReschedulingMessage);
```

> 메시지 스토어와 JMX, 컨트롤 버스에 관한 자세한 내용은 [시스템 관리](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/system-management.html#system-management-chapter)를 참고해라.

5.3.7 버전부터 메시지를 `MessageStore`에 저장할 때 트랜잭션이 활성화된 상태라면, `TransactionSynchronization.afterCommit()` 콜백에서 릴리즈 태스크를 예약한다. 이렇게 하는 이유는 트랜잭션이 커밋되기 전에 예약된 릴리즈 태스크가 실행돼 메시지를 찾을 수 없는 경합 상태에 놓일 수 있기 때문이다. 이 경우 메시지는 지연 시간이 지난 이후나 트랜잭션 커밋 이후 중 더 늦은 시점에 릴리즈된다.

### 10.6.3. Release Failures

5.0.8 버전부터 delayer엔 두 가지 프로퍼티가 새로 생겼다:

- `maxAttempts` (디폴트 5)
- `retryDelay` (디폴트 1초)

메시지를 놓아줄<sup>release</sup> 땐, 다운스트림 플로우가 실패했다면 `retryDelay`가 지난 이후에 릴리즈를 시도한다. `maxAttempts`에 도달하면 메시지를 폐기한다 (트랜잭션 내에서 릴리즈를 진행하는 경우만 아니면. 트랜잭션을 적용하면 메시지는 스토어에 남아 있지만, 애플리케이션을 재시작하거나 `reschedulePersistedMessages( )` 메소드를 실행하기 전엔 더 이상 릴리즈 태스크를 예약하지 않는다).

또한 `delayedMessageErrorChannel`을 설정할 수 있다. 릴리즈에 실패하면 이 채널로 `ErrorMessage`가 전달된다. `ErrorMessage`의 페이로드엔 예외가 담기며, `originalMessage`란 프로퍼티를 가지고 있다. `ErrorMessage`에는 현재 카운트가 담겨있는 `IntegrationMessageHeaderAccessor.DELIVERY_ATTEMPT` 헤더가 들어 있다.

에러 플로우에서 에러 메시지를 컨슘하고 정상적으로 종료되면 별도로 다른 조치를 취하지 않는다. 트랜잭션 내에서 릴리즈를 진행한다면, 트랜잭션은 커밋되고 스토어에 있는 메시지를 삭제한다. 에러 플로우에서 예외가 발생하면 위에서 설명한 대로 최대 `maxAttempts`까지 릴리즈를 재시도한다.

---

## 10.7. Scripting Support

Spring Integration 2.1부터 Java 6에서 도입된 [자바 사양을 위한 JSR223 스크립팅](https://www.jcp.org/en/jsr/detail?id=223)을 지원하기 시작했다. 따라서 다양한 통합 구성 요소들의 로직을, 지원 언어(Ruby, JRuby, Groovy, Kotlin 포함)로 작성한 스크립트로 제공할 수 있다. Spring Integration에서 SpEL<sup>Spring Expression Language</sup>을 사용하는 방식과 유사하다. JSR223에 대한 자세한 내용은 [이 문서](https://docs.oracle.com/javase/8/docs/technotes/guides/scripting/prog_guide/api.html)를 읽어봐라.

> Java 11부터 Nashorn JavaScript 엔진은 deprecated되었으며, Java 15에선 제거될 가능성이 있다. 지금부터는 다른 스크립팅 언어를 이용하는 쪽을 검토해보는 것이 좋다.

먼저 프로젝트에 아래 의존성을 추가해야 한다:

<div class="switch-language-wrapper maven gradle">
<span class="switch-language maven">Maven</span>
<span class="switch-language gradle">Gradle</span>
</div>
<div class="language-only-for-maven maven gradle"></div>
```xml
<dependency>
    <groupId>org.springframework.integration</groupId>
    <artifactId>spring-integration-scripting</artifactId>
    <version>5.5.12</version>
</dependency>
```
<div class="language-only-for-gradle maven gradle"></div>
```groovy
compile "org.springframework.integration:spring-integration-scripting:5.5.12"
```

추가로, 스크립트 엔진 구현체를 추가해야 한다 (e.g. JRuby, Jython).

Spring Integration은 5.2 버전부터 Kotlin Jsr223을 지원한다. 이를 사용하려면 프로젝트에 다음 의존성을 추가해야 한다:

<div class="switch-language-wrapper maven gradle">
<span class="switch-language maven">Maven</span>
<span class="switch-language gradle">Gradle</span>
</div>
<div class="language-only-for-maven maven gradle"></div>
```xml
<dependency>
    <groupId>org.jetbrains.kotlin</groupId>
    <artifactId>kotlin-script-util</artifactId>
    <scope>runtime</scope>
</dependency>
<dependency>
    <groupId>org.jetbrains.kotlin</groupId>
    <artifactId>kotlin-compiler-embeddable</artifactId>
    <scope>runtime</scope>
</dependency>
<dependency>
    <groupId>org.jetbrains.kotlin</groupId>
    <artifactId>kotlin-scripting-compiler-embeddable</artifactId>
    <scope>runtime</scope>
</dependency>
```
<div class="language-only-for-gradle maven gradle"></div>
```groovy
runtime 'org.jetbrains.kotlin:kotlin-script-util'
runtime 'org.jetbrains.kotlin:kotlin-compiler-embeddable'
runtime 'org.jetbrains.kotlin:kotlin-scripting-compiler-embeddable'
```

언어를 직접 `kotlin`으로 설정하거나, 확장자가 `.kts`인 스크립트 파일이 있으면 `KotlinScriptExecutor`를 사용한다.

JVM 스크립팅 언어를 사용하려면 반드시 클래스패스에 해당 언어에 대한 JSR223 구현체가 있어야 한다. [Groovy](https://groovy-lang.org/)와 [JRuby](https://www.jruby.org/) 프로젝트는 표준 배포판에서 JSR233을 지원하고 있다.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>써드 파티에서 구현한 JSR223 언어 구현체도 다양하다. Spring Integration과 특정 구현체와의 호환성은 해당 구현체의 개발자가 사양을 어떻게 이해하고 얼마나 잘 따랐는지에 따라 달라진다.</p>
</blockquote>
> 스크립팅 언어로 Groovy를 사용할 계획이라면, Groovy에 특화된 기능들을 추가로 제공하는 [Spring-Integration의 Groovy 지원 모듈](#108-groovy-support)을 사용하는 게 좋다. 물론 이 섹션도 관련이 있긴 하다.

### 10.7.1. Script Configuration

가지고 있는 통합 요구 사항이 얼마나 복잡한지에 따라, 스크립트를 XML 설정의 CDATA를 이용해 인라인으로 넣거나, 스크립트를 포함하는 스프링 리소스를 참조시키면 된다. Spring Integration은 스크립팅 지원을 위해 `ScriptExecutingMessageProcessor`를 정의하는데, 이 클래스는 메시지 페이로드를 `payload`라는 변수에 바인딩하고 메시지 헤더를 `headers`라는 변수에 바인딩한다. 두 변수 모두 스크립트 실행 컨텍스트 내에서 접근할 수 있다. 개발자는 이 변수들을 사용해서 스크립트를 작성하기만 하면 된다. 아래 두 설정은 필터를 생성하는 예시다:

<div class="switch-language-wrapper java-dsl xml">
<span class="switch-language java-dsl">Java DSL</span>
<span class="switch-language xml">XML</span>
</div>
<div class="language-only-for-java-dsl java-dsl xml"></div>
```java
@Bean
public IntegrationFlow scriptFilter() {
    return f -> f.filter(Scripts.processor("some/path/to/ruby/script/RubyFilterTests.rb"));
}
...
@Bean
public Resource scriptResource() {
	return new ByteArrayResource("headers.type == 'good'".getBytes());
}

@Bean
public IntegrationFlow scriptFilter() {
	return f -> f.filter(Scripts.processor(scriptResource()).lang("groovy"));
}
```
<div class="language-only-for-xml java-dsl xml"></div>
```xml
<int:filter input-channel="referencedScriptInput">
   <int-script:script location="some/path/to/ruby/script/RubyFilterTests.rb"/>
</int:filter>

<int:filter input-channel="inlineScriptInput">
     <int-script:script lang="groovy">
     <![CDATA[
     return payload == 'good'
   ]]>
  </int-script:script>
</int:filter>
```

위 예제에서 확인할 수 있듯이, 스크립트는 인라인으로 포함시킬 수도 있고, 리소스 위치를 참조시킬 수도 있다 (`location` 속성을 이용해서). 참고로, `lang`은 언어 이름(혹은 JSR223 alias)을 나타내는 속성이다.

스크립팅을 지원하는 또 다른 Spring Integration 엔드포인트로는 `router`, `service-activator`, `transformer`, `splitter`가 있다. 각자의 스크립팅 설정도 위와 동일하게 설정한다 (endpoint 요소는 제외하고).

스크립팅과 관련해서는 또 하나 유용한 기능을 제공하는데, 애플리케이션 컨텍스트를 재시작하지 않아도 스크립트를 업데이트(reload)할 수 있다. 그러려면 다음과 같이 `script` 요소에 `refresh-check-delay` 속성을 명시하면 된다:

<div class="switch-language-wrapper java-dsl xml">
<span class="switch-language java-dsl">Java DSL</span>
<span class="switch-language xml">XML</span>
</div>
<div class="language-only-for-java-dsl java-dsl xml"></div>
```java
Scripts.processor(...).refreshCheckDelay(5000)
}
```
<div class="language-only-for-xml java-dsl xml"></div>
```xml
<int-script:script location="..." refresh-check-delay="5000"/>
```

위 예시에선 5초 간격으로 스크립트가 있는 곳에서 업데이트를 확인한다. 스크립트가 업데이트되었다면, 업데이트 이후 5초가 지난 이후엔 전부 새 스크립트를 실행하게 된다.

다음 예제를 살펴보자:

<div class="switch-language-wrapper java-dsl xml">
<span class="switch-language java-dsl">Java DSL</span>
<span class="switch-language xml">XML</span>
</div>
<div class="language-only-for-java-dsl java-dsl xml"></div>
```java
Scripts.processor(...).refreshCheckDelay(0)
}
```
<div class="language-only-for-xml java-dsl xml"></div>
```xml
<int-script:script location="..." refresh-check-delay="0"/>
```

위 예제에선 스크립트가 수정되는 즉시 컨텍스트를 업데이트한다. 이 트릭을 이용해 손쉽게 '실시간' 동기화를 설정할 수 있다. 음수 값은 전부 애플리케이션 컨텍스트를 초기화한 이후엔 스크립트를 다시 로드하지 않는다는 걸 의미하며, 이 동작이 디폴트 동작이다. 다음은 절대 업데이트되지 않는 스크립트 예시다:

<div class="switch-language-wrapper java-dsl xml">
<span class="switch-language java-dsl">Java DSL</span>
<span class="switch-language xml">XML</span>
</div>
<div class="language-only-for-java-dsl java-dsl xml"></div>
```java
Scripts.processor(...).refreshCheckDelay(-1)
}
```
<div class="language-only-for-xml java-dsl xml"></div>
```xml
<int-script:script location="..." refresh-check-delay="-1"/>
```

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>인라인 스크립트는 다시 로드할 수 없다.</p>
</blockquote>


#### Script Variable Bindings

외부에서 스크립트의 실행 컨텍스트에 제공한 변수들을 스크립트에서 참조할 땐 변수 바인딩을 이용한다. 기본적으로 사용할 수 있는 바인딩 변수는 `payload`와 `headers`가 있다. 스크립트에 다른 변수도 함께 바인딩하고 싶다면 다음 예제와 같이 `<variable>` 요소(또는 `ScriptSpec.variables()` 옵션)를 사용하면 된다:

<div class="switch-language-wrapper java-dsl xml">
<span class="switch-language java-dsl">Java DSL</span>
<span class="switch-language xml">XML</span>
</div>
<div class="language-only-for-java-dsl java-dsl xml"></div>
```java
Scripts.processor("foo/bar/MyScript.py")
    .variables(Map.of("var1", "thing1", "var2", "thing2", "date", date))
}
```
<div class="language-only-for-xml java-dsl xml"></div>
```xml
<script:script lang="py" location="foo/bar/MyScript.py">
    <script:variable name="var1" value="thing1"/>
    <script:variable name="var2" value="thing2"/>
    <script:variable name="date" ref="date"/>
</script:script>
```

위 예제에 보이는 것처럼, 스크립트 변수는 스칼라 값이나 스프링 빈 참조에 바인딩할 수 있다. 참고로, 따로 명시하진 않았지만 `payload`와 `headers` 역시 바인딩 변수로 사용할 수 있다.

Spring Integration 3.0에선 `variable` 요소와 더불어 `variables` 속성도 도입했다. 이 속성과 `variable` 요소는 상호 배타적이지 않아서 하나의 `script` 구성 요소 내에서 조합해 쓸 수 있다. 하지만 변수는 정의된 위치에 관계없이 반드시 고유해야 한다. 추가로, Spring Integration 3.0부터는 다음과 같이 인라인 스크립트에도 변수 바인딩을 사용할 수 있다:

```xml
<service-activator input-channel="input">
    <script:script lang="ruby" variables="thing1=THING1, date-ref=dateBean">
        <script:variable name="thing2" ref="thing2Bean"/>
        <script:variable name="thing3" value="thing2"/>
        <![CDATA[
            payload.foo = thing1
            payload.date = date
            payload.bar = thing2
            payload.baz = thing3
            payload
        ]]>
    </script:script>
</service-activator>
```

위 예제에선 인라인 스크립트, `variable` 요소, `variables` 속성을 조합해서 사용하고 있다. `variables` 속성은 값을 콤마로 구분해서 지정하며, 각 세그먼트는 변수와 그 값을 '='로 구분해 나타낸다. 변수명은 위 예시의 `date-ref`와 같이 `-ref`를 suffix로 사용할 수 있다. 이는 바인딩 변수의 이름은 `date`이지만, 애플리케이션 컨텍스트의 `dateBean` 빈 참조 값을 사용한다는 의미다. 프로퍼티 플레이스홀더 설정이나 커맨드라인 인자를 사용할 때 유용할 거다.

변수를 생성하는 방법을 세세하게 제어하고 싶다면, 자바 클래스를 구현해서 아래 인터페이스에서 정의하는 `ScriptVariableGenerator` 전략을 사용하면 된다:

```java
public interface ScriptVariableGenerator {

    Map<String, Object> generateScriptVariables(Message<?> message);

}
```

이 인터페이스를 사용하려면 `generateScriptVariables(Message)` 메소드를 구현해야 한다. message 인자를 이용해 메시지 페이로드와 헤더에 있는 모든 데이터에 접근할 수 있으며, 바인딩된 변수들의 `Map`을 반환하면 된다. 메시지로 스크립트를 실행할 때마다 이 메소드를 호출한다. 다음은 `ScriptVariableGenerator` 구현체를 제공하고 `script-variable-generator` 속성으로 참조시키는 방법을 보여주는 예시다:

<div class="switch-language-wrapper java-dsl xml">
<span class="switch-language java-dsl">Java DSL</span>
<span class="switch-language xml">XML</span>
</div>
<div class="language-only-for-java-dsl java-dsl xml"></div>
```java
Scripts.processor("foo/bar/MyScript.groovy")
    .variableGenerator(new foo.bar.MyScriptVariableGenerator())
}
```
<div class="language-only-for-xml java-dsl xml"></div>
```xml
<int-script:script location="foo/bar/MyScript.groovy"
        script-variable-generator="variableGenerator"/>

<bean id="variableGenerator" class="foo.bar.MyScriptVariableGenerator"/>
```

`script-variable-generator`를 제공하지 않으면 스크립트 컴포넌트는 `DefaultScriptVariableGenerator`를 사용한다. 이 클래스는 `generateScriptVariables(Message)` 메소드에서 설정한 `<variable>` 요소들을 전부 `Message`의 `payload`, `headers` 변수와 함께 병합한다.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p><code class="highlighter-rouge">script-variable-generator</code> 속성과 <code class="highlighter-rouge">&lt;variable&gt;</code> 요소를 모두 지정하는 것은 안 된다. 이 둘은 함께 사용할 수 없다.</p>
</blockquote>

---

## 10.8. Groovy support

Spring Integration 2.0부터는 Groovy를 지원하기 때문에, 다양한 통합 구성 요소들의 로직을 Groovy 스크립팅 언어로 제공할 수 있다. 라우팅, 변환 등 다양한 통합 로직에 SpEL<sup>Spring Expression Language</sup>을 활용하는 방식과 유사하다. Groovy에 대한 자세한 내용은 [프로젝트 웹 사이트](https://groovy-lang.org/)에서 확인할 수 있는 Groovy 문서를 참고해라.

먼저 프로젝트에 아래 의존성을 추가해야 한다:

**Maven**

```xml
<dependency>
    <groupId>org.springframework.integration</groupId>
    <artifactId>spring-integration-groovy</artifactId>
    <version>5.5.12</version>
</dependency>
```

**Gradle**

```groovy
compile "org.springframework.integration:spring-integration-groovy:5.5.12"
```

### 10.8.1. Groovy Configuration

Spring Integration 2.1에서 제공하는 Groovy 전용 설정 네임스페이스는 Spring Integration의 스크립팅 지원을 확장한 것으로, [스크립팅 지원](#107-scripting-support) 섹션에 상세하게 다룬 핵심 설정과 동작을 공유한다. Groovy 스크립트는 범용 스크립팅 지원 모듈을 이용해도 되지만, Groovy 모듈은 스프링 프레임워크의 `org.springframework.scripting.groovy.GroovyScriptFactory`와 관련 컴포넌트들을 통해 `Groovy` 설정 네임스페이스를 따로 제공하며, Groovy 전용 기능들을 사용할 수 있게 해준다. 다음은 두 가지 설정 예시다:

**Example 2. Filter**

```xml
<int:filter input-channel="referencedScriptInput">
   <int-groovy:script location="some/path/to/groovy/file/GroovyFilterTests.groovy"/>
</int:filter>

<int:filter input-channel="inlineScriptInput">
     <int-groovy:script><![CDATA[
     return payload == 'good'
   ]]></int-groovy:script>
</int:filter>
```

위 예시를 보면 일반 스크립팅 지원을 사용할 때와 거의 동일해 보인다. 유일한 차이점은 네임스페이스 프리픽스 `int-groovy`를 사용해서, Groovy 네임스페이스를 불러온다는 점이다. 이 네임스페이스에선 `<script>` 태그 위에 `lang` 속성을 지정할 수 없다는 점도 함께 알아두자.

### 10.8.2. Groovy Object Customization

Groovy 객체 자체를 커스텀해야 한다면 (단순히 변수를 세팅하는 것 이상으로), `customizer` 속성을 이용해 `GroovyObjectCustomizer`를 구현한 빈을 참조시키면 된다. 예를 들어, `MetaClass`를 수정해서 스크립트 내에서 사용할 수 있는 함수들을 등록하는 식으로 DSL<sup>domain-specific language</sup>을 구현하는 상황 등에 활용할 수 있다. 다음은 그 방법을 보여주는 예시다:

```xml
<int:service-activator input-channel="groovyChannel">
    <int-groovy:script location="somewhere/SomeScript.groovy" customizer="groovyCustomizer"/>
</int:service-activator>

<beans:bean id="groovyCustomizer" class="org.something.MyGroovyObjectCustomizer"/>
```

커스텀 `GroovyObjectCustomizer`는 `<variable>` 요소나 `script-variable-generator` 속성을 사용할 때도 설정할 수 있다. 인라인 스크립트를 정의할 때도 가능하다.

Spring Integration 3.0에선 `variable` 요소와 함께 조합해 쓸 수 있는 `variables` 속성을 도입했다. 또한 groovy 스크립트는, 해당 이름을 가진 바인딩 변수를 제공하지 않은 경우 `BeanFactory` 안에 있는 빈으로 변수를 리졸브하는 기능이 있다. 다음은 변수 하나(`entityManager`)를 활용하는 예시다:

```xml
<int-groovy:script>
    <![CDATA[
        entityManager.persist(payload)
        payload
    ]]>
</int-groovy:script>
```

애플리케이션 컨텍스트엔 위와 같이 사용할 수 있는 있는 `entityManager` 빈이 있어야 한다.

`<variable>` 요소, `variables` 속성, `script-variable-generator` 속성에 대한 자세한 내용은 [스크립트 변수 바인딩](#script-variable-bindings)을 참고해라.

### 10.8.3. Groovy Script Compiler Customization

Groovy 컴파일러 커스텀 옵션 중 가장 많이 사용하는 건 어노테이션 힌트 `@CompileStatic`이다. 이 어노테이션은 클래스 레벨이나 메소드 레벨에 사용할 수 있다. 자세한 내용은 Groovy [레퍼런스 매뉴얼](https://groovy-lang.org/metaprogramming.html#section-typechecked)에서 [@CompileStatic](https://groovy-lang.org/metaprogramming.html#xform-CompileStatic) 부분을 찾아 읽어봐라. 간단한 스크립트에서 이 기능을 활용하려면 (통합 시나리오에서) 스크립트 코드를 좀 더 자바와 가깝게 변경해야 한다. 아래 `<filter>` 스크립트를 생각해보자:

```groovy
headers.type == 'good'
```

위 스크립트는 Spring Integration에선 아래 메소드로 바뀐다:

```groovy
@groovy.transform.CompileStatic
String filter(Map headers) {
	headers.type == 'good'
}

filter(headers)
```

이렇게 변경하고 나면 `filter()` 메소드는 `getProperty()` 팩토리와 `CallSite` 프록시같은 Groovy의 동적인 호출 단계는 건너뛰고, 정적인 자바 코드로 변환되고 컴파일된다.

4.3 버전부터는 Spring Integration Groovy 구성 요소를 설정할 때 `compile-static` `boolean` 옵션을 사용할 수 있다. 이 옵션은 내부 `CompilerConfiguration`에 `@CompileStatic`을 사용하는 `ASTTransformationCustomizer`를 추가해준다. 그러면 스크립트 코드에서 `@CompileStatic`을 이용한 메소드 선언을 생략해도 순수 자바 코드로 컴파일할 수 있다. 위 스크립트는 다음과 같이 더 짧게 바뀌지만, 인터프리터로 실행하는 스크립트에 비하면 약간 더 장황한 편이다:

```groovy
binding.variables.headers.type == 'good'
```

`@CompileStatic`을 사용하면 동적인 `GroovyObject.getProperty()`를 이용할 수가 없기 때문에 `headers`와 `payload`에 접근할 땐 (다른 변수들도) 반드시 `groovy.lang.Script` `binding` 프로퍼티를 통해야 한다.

이와 함께 빈 참조를 지정할 수 있는 `compiler-configuration` 속성을 도입했다. 이 속성으로는 `ImportCustomizer`를 사용하는 등, Groovy 컴파일러를 다양하게 커스텀할 수 있다. 이 기능을 자세히 알아보려면 Groovy 문서에서 [고급 컴파일러 설정](https://melix.github.io/blog/2011/05/12/customizing_groovy_compilation_process.html)을 읽어봐라.

> `compilerConfiguration`을 사용하면 `@CompileStatic` 어노테이션을 위한 `ASTTransformationCustomizer`가 자동으로 추가되지 않으며, `compileStatic` 옵션을 재정의하게 된다. `CompileStatic`도 사용해야 한다면, 커스텀 `compilerConfiguration`의 `CompilationCustomizers`에 `new ASTTransformationCustomizer(CompileStatic.class)`를 직접 추가해줘야 한다.

> Groovy 컴파일러를 커스텀해도 `refresh-check-delay` 옵션엔 영향을 미치지 않으며, 다시 로드할 수 있는 스크립트 역시 정적으로 컴파일할 수 있다.

### 10.8.4. Control Bus

[엔터프라이즈 통합 패턴](https://www.enterpriseintegrationpatterns.com/ControlBus.html)에서 설명하는 것처럼, 컨트롤 버스에 깔려있는 아이디어는 "애플리케이션 수준"에서 메시지를 처리할 때 사용하는 메시징 시스템을 그대로 활용해서 프레임워크 내에 있는 구성 요소들을 모니터링하고 관리하겠다는 거다. Spring Integration은 앞서 다뤘던 어댑터들을 기반으로 움직이기 때문에, 정의된 작업을 호출하는 수단으로 메시지를 전송할 수 있다. Groovy 스크립트 또한 이런 작업에 해당할 수 있다. 다음은 컨트롤 버스를 위한 Groovy 스크립트를 설정하는 예시다:

```xml
<int-groovy:control-bus input-channel="operationChannel"/>
```

컨트롤 버스는 가지고 있는 입력 채널을 통해 애플리케이션 컨텍스트에 있는 빈을 호출한다.

Groovy 컨트롤 버스는 입력 채널에서 받은 메시지를 Groovy 스크립트로 실행한다. 메시지를 받아서 본문을 스크립트로 컴파일하고, `GroovyObjectCustomizer`로 커스텀한 뒤 실행한다. 컨트롤 버스의 `MessageProcessor`는 애플리케이션 컨텍스트 내 빈들 중 `@ManagedResource`를 선언한 빈과 스프링의 `Lifecycle` 인터페이스나 기반 클래스 `CustomizableThreadCreator`를 확장한 빈들을 변수로 노출해준다 (ex. `TaskExecutor`와 `TaskScheduler ` 구현체들).

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>컨트롤 버스의 커맨드 스크립트에서 커스텀 스코프(ex. 'request')로 관리하는 빈을 사용한다면 주의가 필요하다. 특히 비동기 메시지 플로우라면 더욱 더 주의해야 한다. 컨트롤 버스의 <code class="highlighter-rouge">MessageProcessor</code>는 애플리케이션 컨텍스트에 있는 빈을 노출할 수 없는 경우 커맨드 스크립트를 실행하는 중에 <code class="highlighter-rouge">BeansException</code>이 발생할 수 있다. 예를 들어 커스텀 스코프의 컨텍스트가 설정되지 않았다면, 해당 스코프 내 빈을 가져오려하면 <code class="highlighter-rouge">BeanCreationException</code>을 유발하게 된다.</p>
</blockquote>

Groovy 객체를 좀 더 커스텀해야 한다면 다음 예제와 같이 `customizer` 속성을 이용해 `GroovyObjectCustomizer`를 구현한 빈을 참조하는 것도 가능하다:

```xml
<int-groovy:control-bus input-channel="input"
        output-channel="output"
        customizer="groovyCustomizer"/>

<beans:bean id="groovyCustomizer" class="org.foo.MyGroovyObjectCustomizer"/>
```

---

## 10.9. Adding Behavior to Endpoints

Spring Integration 2.2 이전에는 폴러의 `<advice-chain/>` 요소에 AOP Advice를 추가해서 전반적인 통합 플로우에 원하는 동작을 추가할 수 있었다. 하지만 다운스트림 엔드포인트를 전부 다시 실행하는 게 아니라, 단순히 REST 웹 서비스만 다시 호출하고 싶다고 가정해보자.

아래 있는 플로우를 한 번 생각해보자:

```none
inbound-adapter->poller->http-gateway1->http-gateway2->jdbc-outbound-adapter
```

폴러의 어드바이스 체인에 재시도 로직을 구성했다면, 네트워크 결함으로 인해 `http-gateway2` 호출에 실패한 경우, 재시도로 인해 `http-gateway1`과 `http-gateway2`는 두 번 호출된다. 마찬가지로 jdbc-outbound-adapter에서 일시적인 에러가 발생했을 때에도 `jdbc-outbound-adapter`를 다시 실행하기 전 두 HTTP 게이트웨이를 또 다시 호출한다.

Spring Integration 2.2부턴 개별 엔드포인트에 동작을 추가할 수 있다. 다양한 엔드포인트에 `<request-handler-advice-chain/>` 요소를 추가해주면 된다. 다음은 `outbound-gateway` 내에서 `<request-handler-advice-chain/>` 요소를 사용하는 예시다:

```xml
<int-http:outbound-gateway id="withAdvice"
    url-expression="'http://localhost/test1'"
    request-channel="requests"
    reply-channel="nextChannel">
    <int-http:request-handler-advice-chain>
        <ref bean="myRetryAdvice" />
    </int-http:request-handler-advice-chain>
</int-http:outbound-gateway>
```

이 경우 `myRetryAdvice`는 이 게이트웨이에만 국소적으로 적용되며, 응답을 `nextChannel`로 전송하고 난 뒤에 다운스트림에서 일어나는 작업들엔 적용되지 않는다. 즉, 어드바이스 스코프는 엔드포인트 자체로 제한된다.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>현재로썬 어드바이스는 전체 엔드포인트들을 아우르는 <code class="highlighter-rouge">&lt;chain/&gt;</code>엔 적용할 수 없다. <code class="highlighter-rouge">&lt;request-handler-advice-chain&gt;</code>은 chain 자체의 자식 요소로는 사용할 수 없다.</p>
  <p>하지만 <code class="highlighter-rouge">&lt;request-handler-advice-chain&gt;</code>은 <code class="highlighter-rouge">&lt;chain/&gt;</code> 요소 안에 있는 엔드포인트들 중, 응답을 생성하는 엔드포인트들에 개별적으로 추가할 수 있다. 한 가지 예외가 있다면, 응답을 생성하지 않는 체인에선, 체인의 마지막 요소가 <code class="highlighter-rouge">outbound-channel-adapter</code>이기 때문에 마지막 요소에는 어드바이스를 적용할 수 없다는 점이다. 이런 요소에 어드바이스를 적용해야 한다면 해당 어댑터를 체인 외부로 이동시켜야 한다 (체인의 <code class="highlighter-rouge">output-channel</code>이 어댑터의 <code class="highlighter-rouge">input-channel</code>이 된다). 그러면 평소대로 어댑터에 어드바이스를 적용할 수 있다. 응답을 생성하는 체인의 경우 모든 자식 요소에 어드바이스를 적용할 수 있다.</p>
</blockquote>

### 10.9.1. Provided Advice Classes

일반적인 메커니즘을 이용해 AOP 어드바이스 클래스를 적용하는 방법도 있지만, Spring Integration은 다음과 같은 어드바이스 구현체들을 기본으로 제공하고 있다:

- `RequestHandlerRetryAdvice` ([Retry Advice](#retry-advice)에서 설명한다)
- `RequestHandlerCircuitBreakerAdvice` ([Circuit Breaker Advice](#circuit-breaker-advice)에서 설명한다)
- `ExpressionEvaluatingRequestHandlerAdvice` ([Expression Evaluating Advice](#expression-evaluating-advice)에서 설명한다)
- `RateLimiterRequestHandlerAdvice` ([Rate Limiter Advice](#rate-limiter-advice)에서 설명한다)
- `CacheRequestHandlerAdvice` ([Caching Advice](#caching-advice)에서 설명한다)
- `ReactiveRequestHandlerAdvice` ([Reactive Advice](#1092-reactive-advice)에서 설명한다)

#### Retry Advice

retry 어드바이스(`o.s.i.handler.advice.RequestHandlerRetryAdvice`)는 [Spring Retry](https://github.com/spring-projects/spring-retry) 프로젝트에서 제공하는 풍부한 재시도 메커니즘을 활용하는 어드바이스다. `spring-retry`의 핵심 컴포넌트는 `RetryTemplate`이다. 이 클래스를 이용하면 재시도 횟수를 전부 소진했을 때 취할 조치를 결정하는 `RecoveryCallback` 전략과, `RetryPolicy`, `BackoffPolicy` 전략(다양한 구현체들도 함께) 등, 재시도 시나리오를 정교하게 구성할 수 있다.

- **Stateless Retry**

  Stateless retry는 재시도 동작을 전부 어드바이스 내에서 처리하는 케이스를 뜻한다. 스레드는 잠시 멈춘<sup>pause</sup> 뒤 (그렇게 설정했다면) 작업을 재시도한다.

- **Stateful Retry**

  Stateful retry는 어드바이스 내에서 재시도 상태를 관리하되, 어드바이스에선 예외를 던지고 호출자가 요청을 다시 제출하는 케이스를 뜻한다. 예들 들면 현재 스레드에서 재시도를 수행하는 대신, 메시지를 보낸 쪽에서 (ex. JMS) 메시지 재전송을 책임지도록 만들고 싶을 수 있다. Stateful retry에선 전달받은 요청이 재시도된 요청인지를 감지하기 위한 몇 가지 메커니즘이 필요하다.

`spring-retry`에 대한 자세한 내용은 [해당 프로젝트의 Javadoc](https://docs.spring.io/spring-integration/api/)과 `spring-retry`의 시초였던 [스프링 배치](../../Spring%20Batch/retry/)의 레퍼런스 문서를 참고해라.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>디폴트 백오프 동작은 백오프를 사용하지 않는 거다. 즉, 곧바로 재시도한다. 다시 시도할 때마다 스레드를 멈추는<sup>pause</sup> 백오프 정책을 사용하면, 과도한 메모리 사용 및 스레드 고갈을 비롯한 성능 이슈가 발생할 수 있다. 대용량 환경에선 백오프 정책을 주의해서 사용해야 한다.</p>
</blockquote>

##### Configuring the Retry Advice

이번 섹션에서 다루는 예제들은 다음과 같이 언제나 예외를 던지는 `<service-activator>`를 사용한다:

```java
public class FailingService {

    public void service(String message) {
        throw new RuntimeException("error");
    }
}
```

- **Simple Stateless Retry**

  디폴트 `RetryTemplate`은 재시도를 세 번까지 해보는 `SimpleRetryPolicy`를 가지고 있다. `BackOffPolicy`는 없기 때문에, 세 번 다 지연 없이 연이어 재시도한다. `RecoveryCallback` 또한 없기 때문에, 최종적으로 재시도에 실패하고 나면 호출자에게 예외를 던진다. Spring Integration 환경에선 최종적으로 발생한 예외를 인바운드 엔드포인트의 `error-channel`을 이용해 처리할 수 있다. 다음은 `RetryTemplate`을 사용하는 예제와 `DEBUG`로 출력된 로그다:

  ```xml
  <int:service-activator input-channel="input" ref="failer" method="service">
      <int:request-handler-advice-chain>
          <bean class="o.s.i.handler.advice.RequestHandlerRetryAdvice"/>
      </int:request-handler-advice-chain>
  </int:service-activator>
  
  DEBUG [task-scheduler-2]preSend on channel 'input', message: [Payload=...]
  DEBUG [task-scheduler-2]Retry: count=0
  DEBUG [task-scheduler-2]Checking for rethrow: count=1
  DEBUG [task-scheduler-2]Retry: count=1
  DEBUG [task-scheduler-2]Checking for rethrow: count=2
  DEBUG [task-scheduler-2]Retry: count=2
  DEBUG [task-scheduler-2]Checking for rethrow: count=3
  DEBUG [task-scheduler-2]Retry failed last attempt: count=3
  ```

- **Simple Stateless Retry with Recovery**

  다음은 위 설정에 `RecoveryCallback`을 추가하고, `ErrorMessageSendingRecoverer`를 사용해 특정 채널에 `ErrorMessage`를 전송하는 예시다:

  ```xml
  <int:service-activator input-channel="input" ref="failer" method="service">
      <int:request-handler-advice-chain>
          <bean class="o.s.i.handler.advice.RequestHandlerRetryAdvice">
              <property name="recoveryCallback">
                  <bean class="o.s.i.handler.advice.ErrorMessageSendingRecoverer">
                      <constructor-arg ref="myErrorChannel" />
                  </bean>
              </property>
          </bean>
      </int:request-handler-advice-chain>
  </int:service-activator>
  
  DEBUG [task-scheduler-2]preSend on channel 'input', message: [Payload=...]
  DEBUG [task-scheduler-2]Retry: count=0
  DEBUG [task-scheduler-2]Checking for rethrow: count=1
  DEBUG [task-scheduler-2]Retry: count=1
  DEBUG [task-scheduler-2]Checking for rethrow: count=2
  DEBUG [task-scheduler-2]Retry: count=2
  DEBUG [task-scheduler-2]Checking for rethrow: count=3
  DEBUG [task-scheduler-2]Retry failed last attempt: count=3
  DEBUG [task-scheduler-2]Sending ErrorMessage :failedMessage:[Payload=...]
  ```

- **Stateless Retry with Customized Policies, and Recovery**

  좀 더 정교한 수정이 필요할 땐 어드바이스에 커스텀한 `RetryTemplate`을 제공할 수 있다. 이 예제에선 계속해서 `SimpleRetryPolicy`를 사용하지만, 시도 횟수를 4회로 늘리고 있다. 또한 `ExponentialBackoffPolicy`를 추가해서, 첫 번째로 재시도할 땐 1초, 두 번째엔 5초, 세 번째엔 25초를 기다린다 (총 4회 시도). 다음은 예제 코드와 `DEBUG`로 출력된 로그다:

  ```xml
  <int:service-activator input-channel="input" ref="failer" method="service">
      <int:request-handler-advice-chain>
          <bean class="o.s.i.handler.advice.RequestHandlerRetryAdvice">
              <property name="recoveryCallback">
                  <bean class="o.s.i.handler.advice.ErrorMessageSendingRecoverer">
                      <constructor-arg ref="myErrorChannel" />
                  </bean>
              </property>
              <property name="retryTemplate" ref="retryTemplate" />
          </bean>
      </int:request-handler-advice-chain>
  </int:service-activator>
  
  <bean id="retryTemplate" class="org.springframework.retry.support.RetryTemplate">
      <property name="retryPolicy">
          <bean class="org.springframework.retry.policy.SimpleRetryPolicy">
              <property name="maxAttempts" value="4" />
          </bean>
      </property>
      <property name="backOffPolicy">
          <bean class="org.springframework.retry.backoff.ExponentialBackOffPolicy">
              <property name="initialInterval" value="1000" />
              <property name="multiplier" value="5.0" />
              <property name="maxInterval" value="60000" />
          </bean>
      </property>
  </bean>
  
  27.058 DEBUG [task-scheduler-1]preSend on channel 'input', message: [Payload=...]
  27.071 DEBUG [task-scheduler-1]Retry: count=0
  27.080 DEBUG [task-scheduler-1]Sleeping for 1000
  28.081 DEBUG [task-scheduler-1]Checking for rethrow: count=1
  28.081 DEBUG [task-scheduler-1]Retry: count=1
  28.081 DEBUG [task-scheduler-1]Sleeping for 5000
  33.082 DEBUG [task-scheduler-1]Checking for rethrow: count=2
  33.082 DEBUG [task-scheduler-1]Retry: count=2
  33.083 DEBUG [task-scheduler-1]Sleeping for 25000
  58.083 DEBUG [task-scheduler-1]Checking for rethrow: count=3
  58.083 DEBUG [task-scheduler-1]Retry: count=3
  58.084 DEBUG [task-scheduler-1]Checking for rethrow: count=4
  58.084 DEBUG [task-scheduler-1]Retry failed last attempt: count=4
  58.086 DEBUG [task-scheduler-1]Sending ErrorMessage :failedMessage:[Payload=...]
  ```

- **Namespace Support for Stateless Retry**

  4.0 버전부터는 retry 어드바이스를 위한 네임스페이스 지원 덕분에, 위 설정을 다음과 같이 훨씬 더 단순하게 바꿀 수 있다:

  ```xml
  <int:service-activator input-channel="input" ref="failer" method="service">
      <int:request-handler-advice-chain>
          <ref bean="retrier" />
      </int:request-handler-advice-chain>
  </int:service-activator>
  
  <int:handler-retry-advice id="retrier" max-attempts="4" recovery-channel="myErrorChannel">
      <int:exponential-back-off initial="1000" multiplier="5.0" maximum="60000" />
  </int:handler-retry-advice>
  ```

  위 예제에선 어드바이스를 최상위 빈으로 정의했기 때문에 여러 `request-handler-advice-chain` 인스턴스에서 사용할 수 있다. 아래 예제와 같이 체인 안에 곧바로 어드바이스를 정의할 수도 있다:

  ```xml
  <int:service-activator input-channel="input" ref="failer" method="service">
      <int:request-handler-advice-chain>
          <int:retry-advice id="retrier" max-attempts="4" recovery-channel="myErrorChannel">
              <int:exponential-back-off initial="1000" multiplier="5.0" maximum="60000" />
          </int:retry-advice>
      </int:request-handler-advice-chain>
  </int:service-activator>
  ```

  `<handler-retry-advice>`는 자식 요소로 `<fixed-back-off>`나 `<exponential-back-off>`를 지정할 수 있고, 자식 요소가 없을 수도 있다. `<handler-retry-advice>`는 자식 요소가 없으면 백오프를 사용하지 않는다. `recovery-channel`이 없을 땐 재시도 횟수를 모두 소진하고 나면 예외를 던진다. 이 네임스페이스는 stateless retry에서만 사용할 수 있다.

  좀더 복잡한 환경에선 (커스텀 policy를 사용하는 등),일반적인 `<bean>` 정의를 활용해라.

- **Simple Stateful Retry with Recovery**

  재시도를 stateful로 만들으려면 어드바이스에 `RetryStateGenerator` 구현체를 제공해줘야 한다. 이 클래스로 다시 제출된 메시지를 식별할 수 있기 때문에, `RetryTemplate`은 현재 메시지를 보고 재시도 현황을 파악할 수 있다. 프레임워크에선 SpEL 표현식을 사용해 메시지 식별자를 결정하는 `SpelExpressionRetryStateGenerator`를 제공하고 있다. 이 예제에선 다시 한 번 디폴트 policy를 사용한다 (백오프 없이 세 번까지 시도). stateless retry와 마찬가지로 이런 정책들은 커스텀이 가능하다. 다음은 예제 코드와 `DEBUG`로 출력된 로그다:

  ```xml
  <int:service-activator input-channel="input" ref="failer" method="service">
      <int:request-handler-advice-chain>
          <bean class="o.s.i.handler.advice.RequestHandlerRetryAdvice">
              <property name="retryStateGenerator">
                  <bean class="o.s.i.handler.advice.SpelExpressionRetryStateGenerator">
                      <constructor-arg value="headers['jms_messageId']" />
                  </bean>
              </property>
              <property name="recoveryCallback">
                  <bean class="o.s.i.handler.advice.ErrorMessageSendingRecoverer">
                      <constructor-arg ref="myErrorChannel" />
                  </bean>
              </property>
          </bean>
      </int:request-handler-advice-chain>
  </int:service-activator>
  
  24.351 DEBUG [Container#0-1]preSend on channel 'input', message: [Payload=...]
  24.368 DEBUG [Container#0-1]Retry: count=0
  24.387 DEBUG [Container#0-1]Checking for rethrow: count=1
  24.387 DEBUG [Container#0-1]Rethrow in retry for policy: count=1
  24.387 WARN  [Container#0-1]failure occurred in gateway sendAndReceive
  org.springframework.integration.MessagingException: Failed to invoke handler
  ...
  Caused by: java.lang.RuntimeException: foo
  ...
  24.391 DEBUG [Container#0-1]Initiating transaction rollback on application exception
  ...
  25.412 DEBUG [Container#0-1]preSend on channel 'input', message: [Payload=...]
  25.412 DEBUG [Container#0-1]Retry: count=1
  25.413 DEBUG [Container#0-1]Checking for rethrow: count=2
  25.413 DEBUG [Container#0-1]Rethrow in retry for policy: count=2
  25.413 WARN  [Container#0-1]failure occurred in gateway sendAndReceive
  org.springframework.integration.MessagingException: Failed to invoke handler
  ...
  Caused by: java.lang.RuntimeException: foo
  ...
  25.414 DEBUG [Container#0-1]Initiating transaction rollback on application exception
  ...
  26.418 DEBUG [Container#0-1]preSend on channel 'input', message: [Payload=...]
  26.418 DEBUG [Container#0-1]Retry: count=2
  26.419 DEBUG [Container#0-1]Checking for rethrow: count=3
  26.419 DEBUG [Container#0-1]Rethrow in retry for policy: count=3
  26.419 WARN  [Container#0-1]failure occurred in gateway sendAndReceive
  org.springframework.integration.MessagingException: Failed to invoke handler
  ...
  Caused by: java.lang.RuntimeException: foo
  ...
  26.420 DEBUG [Container#0-1]Initiating transaction rollback on application exception
  ...
  27.425 DEBUG [Container#0-1]preSend on channel 'input', message: [Payload=...]
  27.426 DEBUG [Container#0-1]Retry failed last attempt: count=3
  27.426 DEBUG [Container#0-1]Sending ErrorMessage :failedMessage:[Payload=...]
  ```

  위 예제를 stateless 예제와 비교해서 보면, stateful 재시도를 사용할 땐 실패할 때마다 매번 호출자에게 예외를 던지는 것을 알 수 있다.

- **Exception Classification for Retry**

  Spring Retry는 재시도를 유발할 예외를 상당히 유연하게 결정할 수 있다. 디폴트 설정에선 모든 예외에서 재시도하고 exception classifier는 최상위 예외를 확인한다. 예를 들어 `MyException`에 대해서만 재시도하도록 설정했다면, 애플리케이션에서 `SomeOtherException`이 발생하면 cause가 `MyException`이더라도 재시도하지 않는다.
  
  Spring Retry 1.0.3부터 `BinaryExceptionClassifier`에는 `traverseCauses`라는 프로퍼티를 가진다 (디폴트는 `false`). `true`로 설정하면 매칭되는 항목을 찾거나 더 이상 cause가 없을 때까지 exception cause를 거슬러 올라간다.
  
  재시도에 이 classifier를 사용하고 싶다면, 최대 시도 횟수와 `Exception` 객체의 `Map`, `traverseCauses` boolean을 받는 생성자를 이용해 `SimpleRetryPolicy`를 생성해라. 그런 다음 이 정책을 `RetryTemplate`에 주입하면 된다.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>이 경우엔 사용자가 정의한 예외를 <code class="highlighter-rouge">MessagingException</code>으로 감쌀 수 있기 때문에 <code class="highlighter-rouge">traverseCauses</code>가 필요하다.</p>
</blockquote>

#### Circuit Breaker Advice

서킷 브레이커 패턴은 서비스를 현재 사용할 수 없다면 해당 서비스에 시간과 리소스를 낭비하지 않겠다는 개념이다. `o.s.i.handler.advice.RequestHandlerCircuitBreakerAdvice`는 이 패턴을 구현한 클래스다. 서킷 브래이커가 닫혀 있으면 엔드포인트는 서비스 호출을 시도한다. 서킷 브레이커는 연속으로 특정 횟수만큼 실패하면 열린다. 열린 상태일 때 새로 요청이 들어오면 "빠르게 실패"하고 정해진 시간 동안은 서비스 호출을 시도하지 않는다.

정해진 시간이 지나면 서킷 브레이커는 half-open 상태로 세팅된다. 이 상태에선 한 번이라도 실패하면 서킷 브레이커는 즉시 열린 상태로 돌아간다. 호출에 성공했다면 서킷 브레이커는 다시 닫히며, 이때는 설정한 횟수만큼 다시 연속해서 실패하지 않는다면 열리지 않는다. 서킷 브레이커를 언제 다시 열지를 결정할 수 있도록 호출에 성공할 때마다 실패 횟수는 0으로 리셋된다.

일반적으로 서킷 브레이커 어드바이스는 실패하는 데 시간이 좀 걸리기도 하는 (네트워크 연결을 시도하는 중 타임아웃이 발생하는 등) 외부 서비스에 활용하곤 한다.

`RequestHandlerCircuitBreakerAdvice`엔 `threshold`와 `halfOpenAfter`라는 두 가지 프로퍼티가 있다. `threshold` 프로퍼티는 서킷 브레이커를 열으려면 필요한 연속 실패 횟수를 나타낸다. 디폴트는 `5`다. `halfOpenAfter` 프로퍼티는, 마지막으로 실패한 시간을 기준으로 서킷 브레이커가 다시 요청을 보내보기 전에 대기하는 시간이다. 디폴트는 1000밀리세컨드다.

다음은 서킷 브레이커를 설정하는 예제와, `DEBUG`, `ERROR`로 출력된 로그다:

```xml
<int:service-activator input-channel="input" ref="failer" method="service">
    <int:request-handler-advice-chain>
        <bean class="o.s.i.handler.advice.RequestHandlerCircuitBreakerAdvice">
            <property name="threshold" value="2" />
            <property name="halfOpenAfter" value="12000" />
        </bean>
    </int:request-handler-advice-chain>
</int:service-activator>

05.617 DEBUG [task-scheduler-1]preSend on channel 'input', message: [Payload=...]
05.638 ERROR [task-scheduler-1]org.springframework.messaging.MessageHandlingException: java.lang.RuntimeException: foo
...
10.598 DEBUG [task-scheduler-2]preSend on channel 'input', message: [Payload=...]
10.600 ERROR [task-scheduler-2]org.springframework.messaging.MessageHandlingException: java.lang.RuntimeException: foo
...
15.598 DEBUG [task-scheduler-3]preSend on channel 'input', message: [Payload=...]
15.599 ERROR [task-scheduler-3]org.springframework.messaging.MessagingException: Circuit Breaker is Open for ServiceActivator
...
20.598 DEBUG [task-scheduler-2]preSend on channel 'input', message: [Payload=...]
20.598 ERROR [task-scheduler-2]org.springframework.messaging.MessagingException: Circuit Breaker is Open for ServiceActivator
...
25.598 DEBUG [task-scheduler-5]preSend on channel 'input', message: [Payload=...]
25.601 ERROR [task-scheduler-5]org.springframework.messaging.MessageHandlingException: java.lang.RuntimeException: foo
...
30.598 DEBUG [task-scheduler-1]preSend on channel 'input', message: [Payload=foo...]
30.599 ERROR [task-scheduler-1]org.springframework.messaging.MessagingException: Circuit Breaker is Open for ServiceActivator
```

위 예제에선 threshold를 `2`로 설정하고 `halfOpenAfter`는 `12`초로 설정하고 있다. 요청은 5초간격으로 새로 도착한다. 처음 두 번은 서비스를 호출했다. 세 번째와 네 번째 시도에선 서킷 브레이커가 열려있음을 나타내는 예외와 함께 실패했다. 다섯 번째 요청은 마지막으로 호출에 실패한지 15초가 지난 다음 들어온 요청이기 때문에 실제로 서비스 호출을 시도했다. 서킷 브레이커는 즉시 열리고, 여섯 번째 시도 또한 즉시 실패한다.

#### Expression Evaluating Advice

그 다음으로 제공하는 어드바이스 클래스는 `o.s.i.handler.advice.ExpressionEvaluatingRequestHandlerAdvice`다. 이 어드바이스는 다른 두 가지 어드바이스보단 좀 더 범용적인데, 엔드포인트로 전송된 기존 인바운드 메시지로 표현식을 평가할 수 있다. 성공했을 때와 실패했을 때를 나눠서 별도의 표현식을 평가할 수 있다. 원한다면 입력 메시지와 평가 결과를 함께 담은 메시지를 특정 메시지 채널로 전송할 수 있다.

이 어드바이스의 대표적인 사용 사례는 `<ftp:outbound-channel-adapter/>`를 사용해, 전송에 성공하면 파일을 특정 디렉터리로 이동시키고 실패하면 또 다른 디렉터리로 이동시키는 케이스다.

이 어드바이스는 성공 시 사용할 표현식, 실패 시 사용할 표현식과, 그리고 각각에 해당하는 채널을 설정할 수 있는 프로퍼티를 가지고 있다. 성공한 케이스에서 `successChannel`로 전송하는 메시지는 `AdviceMessage`로, 표현식을 평가한 결과를 페이로드로 가지고 있다. `AdviceMessage`는 핸들러로 전송된 원본 메시지를 저장하는 `inputMessage`라는 또 다른 프로퍼티도 가지고 있다. `failureChannel`에 전송되는 (핸들러에서 예외를 던지면) 메시지는 `ErrorMessage`로, 페이로드에 `MessageHandlingExpressionEvaluatingAdviceException`을 담고있다. `MessagingException` 인스턴스가 전부 그렇듯, 이 페이로드는 `failedMessage`, `cause` 프로퍼티를 가지고 있으며, 추가로 표현식 평가 결과가 들어있는 `evaluationResult`라는 프로퍼티도 존재한다.

> 5.1.3 버전부터 채널은 설정했지만 표현식을 제공하지 않은 경우, 디폴트 표현식을 사용해 메시지의 `payload`를 평가한다.

어드바이스 스코프 내에서 예외가 발생하면 기본적으로 `failureExpression`을 평가한 뒤 호출부로 해당 예외를 던진다. 예외를 던지는 게 싫다면 `trapException` 프로퍼티를 `true`로 설정해라. 다음은 Java DSL을 사용해 어드바이스를 설정하는 방법을 보여주는 예제다:

```java
@SpringBootApplication
public class EerhaApplication {

    public static void main(String[] args) {
        ConfigurableApplicationContext context = SpringApplication.run(EerhaApplication.class, args);
        MessageChannel in = context.getBean("advised.input", MessageChannel.class);
        in.send(new GenericMessage<>("good"));
        in.send(new GenericMessage<>("bad"));
        context.close();
    }

    @Bean
    public IntegrationFlow advised() {
        return f -> f.handle((GenericHandler<String>) (payload, headers) -> {
            if (payload.equals("good")) {
                return null;
            }
            else {
                throw new RuntimeException("some failure");
            }
        }, c -> c.advice(expressionAdvice()));
    }

    @Bean
    public Advice expressionAdvice() {
        ExpressionEvaluatingRequestHandlerAdvice advice = new ExpressionEvaluatingRequestHandlerAdvice();
        advice.setSuccessChannelName("success.input");
        advice.setOnSuccessExpressionString("payload + ' was successful'");
        advice.setFailureChannelName("failure.input");
        advice.setOnFailureExpressionString(
                "payload + ' was bad, with reason: ' + #exception.cause.message");
        advice.setTrapException(true);
        return advice;
    }

    @Bean
    public IntegrationFlow success() {
        return f -> f.handle(System.out::println);
    }

    @Bean
    public IntegrationFlow failure() {
        return f -> f.handle(System.out::println);
    }

}
```

#### Rate Limiter Advice

Rate Limiter 어드바이스(`RateLimiterRequestHandlerAdvice`)를 사용하면 엔드포인트가 요청으로 인해 과부하에 걸리지 않도록 보호할 수 있다. 속도 제한을 어기면 요청을 차단한다.

Rate Limiter 어드바이스는 분당 `n`개 이상의 요청을 허용하지 않는 외부 서비스 provider에 사용하는 케이스가 대표적이다.

`RateLimiterRequestHandlerAdvice` 구현체는 완벽하게 [Resilience4j](../../Resilience4j/latelimiter/) 프로젝트를 기반으로 동작하며, `RateLimiter`나 `RateLimiterConfig`를 주입받아야 한다. 디폴트값이나 커스텀 이름도 함께 설정할 수 있다.

다음은 1초당 하나의 요청만 허용하도록 rate limiter 어드바이스를 설정하는 예시다:

```java
@Bean
public RateLimiterRequestHandlerAdvice rateLimiterRequestHandlerAdvice() {
    return new RateLimiterRequestHandlerAdvice(RateLimiterConfig.custom()
            .limitRefreshPeriod(Duration.ofSeconds(1))
            .limitForPeriod(1)
            .build());
}

@ServiceActivator(inputChannel = "requestChannel", outputChannel = "resultChannel",
		adviceChain = "rateLimiterRequestHandlerAdvice")
public String handleRequest(String payload) {
    ...
}
```

#### Caching Advice

5.2 버전부터는 `CacheRequestHandlerAdvice`를 사용할 수 있다. 이 클래스는 [스프링 프레임워크](https://docs.spring.io/spring/docs/current/spring-framework-reference/integration.html#cache)가 추상화해놓은 캐시 인프라를 사용하며, `@Caching` 어노테이션 패밀리에서 제공하는 개념과 기능들을 그대로 사용한다. 내부 로직에선 `CacheAspectSupport`를 상속해서,  `AbstractReplyProducingMessageHandler.RequestHandler.handleRequestMessage` 메소드를 중심으로 요청 `Message<?>`를 인자로 넘겨 캐시 연산을 프록시처리한다. 이 어드바이스는 캐시 키를 평가할 SpEL 표현식이나 `Function`을 지정할 수 있다. 요청 `Message<?>`는 SpEL 평가 컨텍스트의 루트 객체나 `Function` 입력 인자를 통해 접근할 수 있다. 기본적으론 요청 메시지의 `payload`를 캐시 키로 사용한다. `CacheRequestHandlerAdvice`는 디폴트 캐시 연산이 하나의 `CacheableOperation`이거나 임의의 `CacheOperation` 셋을 사용하는 경우, 반드시 `cacheNames`를 설정해줘야 한다. 모든 `CacheOperation`은 별도로 설정할 수도 있고, `CacheManager`, `CacheResolver`, `CacheErrorHandler`같은 옵션들을 공유할 수 있으며, `CacheRequestHandlerAdvice` 설정에서 재사용할 수 있다. 스프링 프레임워크의 `@CacheConfig`와 `@Caching` 어노테이션 조합을 설정하는 것과 유사하다. `CacheManager`를 제공하지 않으면 기본적으로 `CacheAspectSupport`에서 `BeanFactory`를 사용해 빈 하나를 리졸브한다.

다음 예제에선 서로 다른 캐시 연산 셋을 갖는 두 가지 어드바이스를 설정하고 있다:

```java
@Bean
public CacheRequestHandlerAdvice cacheAdvice() {
    CacheRequestHandlerAdvice cacheRequestHandlerAdvice = new CacheRequestHandlerAdvice(TEST_CACHE);
    cacheRequestHandlerAdvice.setKeyExpressionString("payload");
    return cacheRequestHandlerAdvice;
}

@Transformer(inputChannel = "transformerChannel", outputChannel = "nullChannel", adviceChain = "cacheAdvice")
public Object transform(Message<?> message) {
    ...
}

@Bean
public CacheRequestHandlerAdvice cachePutAndEvictAdvice() {
    CacheRequestHandlerAdvice cacheRequestHandlerAdvice = new CacheRequestHandlerAdvice();
    cacheRequestHandlerAdvice.setKeyExpressionString("payload");
    CachePutOperation.Builder cachePutBuilder = new CachePutOperation.Builder();
    cachePutBuilder.setCacheName(TEST_PUT_CACHE);
    CacheEvictOperation.Builder cacheEvictBuilder = new CacheEvictOperation.Builder();
    cacheEvictBuilder.setCacheName(TEST_CACHE);
    cacheRequestHandlerAdvice.setCacheOperations(cachePutBuilder.build(), cacheEvictBuilder.build());
    return cacheRequestHandlerAdvice;
}

@ServiceActivator(inputChannel = "serviceChannel", outputChannel = "nullChannel",
    adviceChain = "cachePutAndEvictAdvice")
public Message<?> service(Message<?> message) {
    ...
}
```

### 10.9.2. Reactive Advice

Starting with version 5.3, a `ReactiveRequestHandlerAdvice` can be used for request message handlers producing a `Mono` replies. A `BiFunction<Message<?>, Mono<?>, Publisher<?>>` has to be provided for this advice and it is called from the `Mono.transform()` operator on a reply produced by the intercepted `handleRequestMessage()` method implementation. Typically such a `Mono` customization is necessary when we would like to control network fluctuations via `timeout()`, `retry()` and similar support operators. For example when we can an HTTP request over WebFlux client, we could use below configuration to not wait for response more than 5 seconds:

```java
.handle(WebFlux.outboundGateway("https://somehost/"),
                       e -> e.customizeMonoReply((message, mono) -> mono.timeout(Duration.ofSeconds(5))));
```

The `message` argument is the request message for the message handler and can be used to determine request-scope attributes. The `mono` argument is the result of this message handler’s `handleRequestMessage()` method implementation. A nested `Mono.transform()` can also be called from this function to apply, for example, a [Reactive Circuit Breaker](https://spring.io/projects/spring-cloud-circuitbreaker).

### 10.9.3. Custom Advice Classes

In addition to the provided advice classes [described earlier](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/index-single.html#advice-classes), you can implement your own advice classes. While you can provide any implementation of `org.aopalliance.aop.Advice` (usually `org.aopalliance.intercept.MethodInterceptor`), we generally recommend that you subclass `o.s.i.handler.advice.AbstractRequestHandlerAdvice`. This has the benefit of avoiding the writing of low-level aspect-oriented programming code as well as providing a starting point that is specifically tailored for use in this environment.

Subclasses need to implement the `doInvoke()` method, the definition of which follows:

```java
/**
 * Subclasses implement this method to apply behavior to the {@link MessageHandler} callback.execute()
 * invokes the handler method and returns its result, or null).
 * @param callback Subclasses invoke the execute() method on this interface to invoke the handler method.
 * @param target The target handler.
 * @param message The message that will be sent to the handler.
 * @return the result after invoking the {@link MessageHandler}.
 * @throws Exception
 */
protected abstract Object doInvoke(ExecutionCallback callback, Object target, Message<?> message) throws Exception;
```

The callback parameter is a convenience to avoid subclasses that deal with AOP directly. Invoking the `callback.execute()` method invokes the message handler.

The `target` parameter is provided for those subclasses that need to maintain state for a specific handler, perhaps by maintaining that state in a `Map` keyed by the target. This feature allows the same advice to be applied to multiple handlers. The `RequestHandlerCircuitBreakerAdvice` uses advice this to keep circuit breaker state for each handler.

The `message` parameter is the message sent to the handler. While the advice cannot modify the message before invoking the handler, it can modify the payload (if it has mutable properties). Typically, an advice would use the message for logging or to send a copy of the message somewhere before or after invoking the handler.

The return value would normally be the value returned by `callback.execute()`. However, the advice does have the ability to modify the return value. Note that only `AbstractReplyProducingMessageHandler` instances return values. The following example shows a custom advice class that extends `AbstractRequestHandlerAdvice`:

```java
public class MyAdvice extends AbstractRequestHandlerAdvice {

    @Override
    protected Object doInvoke(ExecutionCallback callback, Object target, Message<?> message) throws Exception {
        // add code before the invocation
        Object result = callback.execute();
        // add code after the invocation
        return result;
    }
}
```

> In addition to the `execute()` method, `ExecutionCallback` provides an additional method: `cloneAndExecute()`. This method must be used in cases where the invocation might be called multiple times within a single execution of `doInvoke()`, such as in the `RequestHandlerRetryAdvice`. This is required because the Spring AOP `org.springframework.aop.framework.ReflectiveMethodInvocation` object maintains state by keeping track of which advice in a chain was last invoked. This state must be reset for each call.For more information, see the [ReflectiveMethodInvocation](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/aop/framework/ReflectiveMethodInvocation.html) Javadoc.

### 10.9.4. Other Advice Chain Elements

While the abstract class mentioned above is a convenience, you can add any `Advice`, including a transaction advice, to the chain.

### 10.9.5. Handling Message Advice

As discussed in [the introduction to this section](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/index-single.html#message-handler-advice-chain), advice objects in a request handler advice chain are applied to just the current endpoint, not the downstream flow (if any). For `MessageHandler` objects that produce a reply (such as those that extend `AbstractReplyProducingMessageHandler`), the advice is applied to an internal method: `handleRequestMessage()` (called from `MessageHandler.handleMessage()`). For other message handlers, the advice is applied to `MessageHandler.handleMessage()`.

There are some circumstances where, even if a message handler is an `AbstractReplyProducingMessageHandler`, the advice must be applied to the `handleMessage` method. For example, the [idempotent receiver](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/index-single.html#idempotent-receiver) might return `null`, which would cause an exception if the handler’s `replyRequired` property is set to `true`. Another example is the `BoundRabbitChannelAdvice` — see [Strict Message Ordering](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/amqp.html#amqp-strict-ordering).

Starting with version 4.3.1, a new `HandleMessageAdvice` interface and its base implementation (`AbstractHandleMessageAdvice`) have been introduced. `Advice` objects that implement `HandleMessageAdvice` are always applied to the `handleMessage()` method, regardless of the handler type.

It is important to understand that `HandleMessageAdvice` implementations (such as [idempotent receiver](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/index-single.html#idempotent-receiver)), when applied to a handlers that return responses, are dissociated from the `adviceChain` and properly applied to the `MessageHandler.handleMessage()` method.

> Because of this disassociation, the advice chain order is not honored.

Consider the following configuration:

```xml
<some-reply-producing-endpoint ... >
    <int:request-handler-advice-chain>
        <tx:advice ... />
        <ref bean="myHandleMessageAdvice" />
    </int:request-handler-advice-chain>
</some-reply-producing-endpoint>
```

In the preceding example, the `<tx:advice>` is applied to the `AbstractReplyProducingMessageHandler.handleRequestMessage()`. However, `myHandleMessageAdvice` is applied for to `MessageHandler.handleMessage()`. Therefore, it is invoked **before** the `<tx:advice>`. To retain the order, you should follow the standard [Spring AOP](https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#aop-api) configuration approach and use an endpoint `id` together with the `.handler` suffix to obtain the target `MessageHandler` bean. Note that, in that case, the entire downstream flow is within the transaction scope.

In the case of a `MessageHandler` that does not return a response, the advice chain order is retained.

Starting with version 5.3, the `HandleMessageAdviceAdapter` is present to let apply any existing `MethodInterceptor` for the `MessageHandler.handleMessage()` and, therefore, whole sub-flow. For example a `RetryOperationsInterceptor` could be applied for the whole sub-flow starting from some endpoint, which is not possible by default because consumer endpoint applies advices only for the `AbstractReplyProducingMessageHandler.RequestHandler.handleRequestMessage()`. Starting with version 5.3, the `HandleMessageAdviceAdapter` is provided to apply any `MethodInterceptor` for the `MessageHandler.handleMessage()` method and, therefore, the whole sub-flow. For example, a `RetryOperationsInterceptor` could be applied to the whole sub-flow starting from some endpoint; this is not possible, by default, because the consumer endpoint applies advices only to the `AbstractReplyProducingMessageHandler.RequestHandler.handleRequestMessage()`.

### 10.9.6. Transaction Support

Starting with version 5.0, a new `TransactionHandleMessageAdvice` has been introduced to make the whole downstream flow transactional, thanks to the `HandleMessageAdvice` implementation. When a regular `TransactionInterceptor` is used in the `<request-handler-advice-chain>` element (for example, through configuring `<tx:advice>`), a started transaction is only applied only for an internal `AbstractReplyProducingMessageHandler.handleRequestMessage()` and is not propagated to the downstream flow.

To simplify XML configuration, along with the `<request-handler-advice-chain>`, a `<transactional>` element has been added to all `<outbound-gateway>` and `<service-activator>` and related components. The following example shows `<transactional>` in use:

```xml
<int-rmi:outbound-gateway remote-channel="foo" host="localhost"
    request-channel="good" reply-channel="reply" port="#{@port}">
        <int-rmi:transactional/>
</int-rmi:outbound-gateway>

<bean id="transactionManager" class="org.mockito.Mockito" factory-method="mock">
    <constructor-arg value="org.springframework.transaction.TransactionManager"/>
</bean>
```

If you are familiar with the [JPA integration components](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/jpa.html#jpa), such a configuration is not new, but now we can start a transaction from any point in our flow — not only from the `<poller>` or a message-driven channel adapter such as [JMS](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/jms.html#jms-message-driven-channel-adapter).

Java configuration can be simplified by using the `TransactionInterceptorBuilder`, and the result bean name can be used in the [messaging annotations](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/configuration.html#annotations) `adviceChain` attribute, as the following example shows:

```java
@Bean
public ConcurrentMetadataStore store() {
    return new SimpleMetadataStore(hazelcastInstance()
                       .getMap("idempotentReceiverMetadataStore"));
}

@Bean
public IdempotentReceiverInterceptor idempotentReceiverInterceptor() {
    return new IdempotentReceiverInterceptor(
            new MetadataStoreSelector(
                    message -> message.getPayload().toString(),
                    message -> message.getPayload().toString().toUpperCase(), store()));
}

@Bean
public TransactionInterceptor transactionInterceptor() {
    return new TransactionInterceptorBuilder(true)
                .transactionManager(this.transactionManager)
                .isolation(Isolation.READ_COMMITTED)
                .propagation(Propagation.REQUIRES_NEW)
                .build();
}

@Bean
@org.springframework.integration.annotation.Transformer(inputChannel = "input",
         outputChannel = "output",
         adviceChain = { "idempotentReceiverInterceptor",
                 "transactionInterceptor" })
public Transformer transformer() {
    return message -> message;
}
```

Note the `true` parameter on the `TransactionInterceptorBuilder` constructor. It causes the creation of a `TransactionHandleMessageAdvice`, not a regular `TransactionInterceptor`.

Java DSL supports an `Advice` through the `.transactional()` options on the endpoint configuration, as the following example shows:

```java
@Bean
public IntegrationFlow updatingGatewayFlow() {
    return f -> f
        .handle(Jpa.updatingGateway(this.entityManagerFactory),
                e -> e.transactional(true))
        .channel(c -> c.queue("persistResults"));
}
```

### 10.9.7. Advising Filters

There is an additional consideration when advising `Filter` advices. By default, any discard actions (when the filter returns `false`) are performed within the scope of the advice chain. This could include all the flow downstream of the discard channel. So, for example, if an element downstream of the discard channel throws an exception and there is a retry advice, the process is retried. Also, if `throwExceptionOnRejection` is set to `true` (the exception is thrown within the scope of the advice).

Setting `discard-within-advice` to `false` modifies this behavior and the discard (or exception) occurs after the advice chain is called.

### 10.9.8. Advising Endpoints Using Annotations

When configuring certain endpoints by using annotations (`@Filter`, `@ServiceActivator`, `@Splitter`, and `@Transformer`), you can supply a bean name for the advice chain in the `adviceChain` attribute. In addition, the `@Filter` annotation also has the `discardWithinAdvice` attribute, which can be used to configure the discard behavior, as discussed in [Advising Filters](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/index-single.html#advising-filters). The following example causes the discard to be performed after the advice:

```java
@MessageEndpoint
public class MyAdvisedFilter {

    @Filter(inputChannel="input", outputChannel="output",
            adviceChain="adviceChain", discardWithinAdvice="false")
    public boolean filter(String s) {
        return s.contains("good");
    }
}
```

### 10.9.9. Ordering Advices within an Advice Chain

Advice classes are “around” advices and are applied in a nested fashion. The first advice is the outermost, while the last advice is the innermost (that is, closest to the handler being advised). It is important to put the advice classes in the correct order to achieve the functionality you desire.

For example, suppose you want to add a retry advice and a transaction advice. You may want to place the retry advice advice first, followed by the transaction advice. Consequently, each retry is performed in a new transaction. On the other hand, if you want all the attempts and any recovery operations (in the retry `RecoveryCallback`) to be scoped within the transaction, you could put the transaction advice first.

### 10.9.10. Advised Handler Properties

Sometimes, it is useful to access handler properties from within the advice. For example, most handlers implement `NamedComponent` to let you access the component name.

The target object can be accessed through the `target` argument (when subclassing `AbstractRequestHandlerAdvice`) or `invocation.getThis()` (when implementing `org.aopalliance.intercept.MethodInterceptor`).

When the entire handler is advised (such as when the handler does not produce replies or the advice implements `HandleMessageAdvice`), you can cast the target object to an interface, such as `NamedComponent`, as shown in the following example:

```java
String componentName = ((NamedComponent) target).getComponentName();
```

When you implement `MethodInterceptor` directly, you could cast the target object as follows:

```java
String componentName = ((NamedComponent) invocation.getThis()).getComponentName();
```

When only the `handleRequestMessage()` method is advised (in a reply-producing handler), you need to access the full handler, which is an `AbstractReplyProducingMessageHandler`. The following example shows how to do so:

```java
AbstractReplyProducingMessageHandler handler =
    ((AbstractReplyProducingMessageHandler.RequestHandler) target).getAdvisedHandler();

String componentName = handler.getComponentName();
```

### 10.9.11. Idempotent Receiver Enterprise Integration Pattern

Starting with version 4.1, Spring Integration provides an implementation of the [Idempotent Receiver](https://www.enterpriseintegrationpatterns.com/IdempotentReceiver.html) Enterprise Integration Pattern. It is a functional pattern and the whole idempotency logic should be implemented in the application. However, to simplify the decision-making, the `IdempotentReceiverInterceptor` component is provided. This is an AOP `Advice` that is applied to the `MessageHandler.handleMessage()` method and that can `filter` a request message or mark it as a `duplicate`, according to its configuration.

Previously, you could have implemented this pattern by using a custom `MessageSelector` in a `<filter/>` (see [Filter](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/filter.html#filter)), for example. However, since this pattern really defines the behavior of an endpoint rather than being an endpoint itself, the idempotent receiver implementation does not provide an endpoint component. Rather, it is applied to endpoints declared in the application.

The logic of the `IdempotentReceiverInterceptor` is based on the provided `MessageSelector` and, if the message is not accepted by that selector, it is enriched with the `duplicateMessage` header set to `true`. The target `MessageHandler` (or downstream flow) can consult this header to implement the correct idempotency logic. If the `IdempotentReceiverInterceptor` is configured with a `discardChannel` or `throwExceptionOnRejection = true`, the duplicate message is not sent to the target `MessageHandler.handleMessage()`. Rather, it is discarded. If you want to discard (do nothing with) the duplicate message, the `discardChannel` should be configured with a `NullChannel`, such as the default `nullChannel` bean.

To maintain state between messages and provide the ability to compare messages for the idempotency, we provide the `MetadataStoreSelector`. It accepts a `MessageProcessor` implementation (which creates a lookup key based on the `Message`) and an optional `ConcurrentMetadataStore` ([Metadata Store](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/meta-data-store.html#metadata-store)). See the [`MetadataStoreSelector` Javadoc](https://docs.spring.io/spring-integration/api/org/springframework/integration/selector/MetadataStoreSelector.html) for more information. You can also customize the `value` for `ConcurrentMetadataStore` by using an additional `MessageProcessor`. By default, `MetadataStoreSelector` uses the `timestamp` message header.

Normally, the selector selects a message for acceptance if there is no existing value for the key. In some cases, it is useful to compare the current and new values for a key, to determine whether the message should be accepted. Starting with version 5.3, the `compareValues` property is provided which references a `BiPredicate<String, String>`; the first parameter is the old value; return `true` to accept the message and replace the old value with the new value in the `MetadataStore`. This can be useful to reduce the number of keys; for example, when processing lines in a file, you can store the file name in the key and the current line number in the value. Then, after a restart, you can skip lines that have already been processed. See [Idempotent Downstream Processing a Split File](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/file.html#idempotent-file-splitter) for an example.

For convenience, the `MetadataStoreSelector` options are configurable directly on the `<idempotent-receiver>` component. The following listing shows all the possible attributes:

```xml
<idempotent-receiver
        id=""  <!-- (1) -->
        endpoint=""  <!-- (2) -->
        selector=""  <!-- (3) -->
        discard-channel=""  <!-- (4) -->
        metadata-store=""  <!-- (5) -->
        key-strategy=""  <!-- (6) -->
        key-expression=""  <!-- (7) -->
        value-strategy=""  <!-- (8) -->
        value-expression=""  <!-- (9) -->
        compare-values="" <!-- (10) -->
        throw-exception-on-rejection="" />  <!-- (11) -->
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> The ID of the `IdempotentReceiverInterceptor` bean. Optional.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> Consumer endpoint name(s) or pattern(s) to which this interceptor is applied. Separate names (patterns) with commas (`,`), such as `endpoint="aaa, bbb*, **ccc, \*ddd**, eee*fff"`. Endpoint bean names matching these patterns are then used to retrieve the target endpoint’s `MessageHandler` bean (using its `.handler` suffix), and the `IdempotentReceiverInterceptor` is applied to those beans. Required.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> A `MessageSelector` bean reference. Mutually exclusive with `metadata-store` and `key-strategy (key-expression)`. When `selector` is not provided, one of `key-strategy` or `key-strategy-expression` is required.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> Identifies the channel to which to send a message when the `IdempotentReceiverInterceptor` does not accept it. When omitted, duplicate messages are forwarded to the handler with a `duplicateMessage` header. Optional.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> A `ConcurrentMetadataStore` reference. Used by the underlying `MetadataStoreSelector`. Mutually exclusive with `selector`. Optional. The default `MetadataStoreSelector` uses an internal `SimpleMetadataStore` that does not maintain state across application executions.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(6)</span> A `MessageProcessor` reference. Used by the underlying `MetadataStoreSelector`. Evaluates an `idempotentKey` from the request message. Mutually exclusive with `selector` and `key-expression`. When a `selector` is not provided, one of `key-strategy` or `key-strategy-expression` is required.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(7)</span> A SpEL expression to populate an `ExpressionEvaluatingMessageProcessor`. Used by the underlying `MetadataStoreSelector`. Evaluates an `idempotentKey` by using the request message as the evaluation context root object. Mutually exclusive with `selector` and `key-strategy`. When a `selector` is not provided, one of `key-strategy` or `key-strategy-expression` is required.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(8)</span> A `MessageProcessor` reference. Used by the underlying `MetadataStoreSelector`. Evaluates a `value` for the `idempotentKey` from the request message. Mutually exclusive with `selector` and `value-expression`. By default, the 'MetadataStoreSelector' uses the 'timestamp' message header as the Metadata 'value'.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(9)</span> A SpEL expression to populate an `ExpressionEvaluatingMessageProcessor`. Used by the underlying `MetadataStoreSelector`. Evaluates a `value` for the `idempotentKey` by using the request message as the evaluation context root object. Mutually exclusive with `selector` and `value-strategy`. By default, the 'MetadataStoreSelector' uses the 'timestamp' message header as the metadata 'value'.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(10)</span> A reference to a `BiPredicate<String, String>` bean which allows you to optionally select a message by comparing the old and new values for the key; `null` by default.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(11)</span> Whether to throw an exception if the `IdempotentReceiverInterceptor` rejects the message. Defaults to `false`. It is applied regardless of whether or not a `discard-channel` is provided.</small>

For Java configuration, Spring Integration provides the method-level `@IdempotentReceiver` annotation. It is used to mark a `method` that has a messaging annotation (`@ServiceActivator`, `@Router`, and others) to specify which `IdempotentReceiverInterceptor` objects are applied to this endpoint. The following example shows how to use the `@IdempotentReceiver` annotation:

```java
@Bean
public IdempotentReceiverInterceptor idempotentReceiverInterceptor() {
   return new IdempotentReceiverInterceptor(new MetadataStoreSelector(m ->
                                                    m.getHeaders().get(INVOICE_NBR_HEADER)));
}

@Bean
@ServiceActivator(inputChannel = "input", outputChannel = "output")
@IdempotentReceiver("idempotentReceiverInterceptor")
public MessageHandler myService() {
    ....
}
```

When you use the Java DSL, you can add the interceptor to the endpoint’s advice chain, as the following example shows:

```java
@Bean
public IntegrationFlow flow() {
    ...
        .handle("someBean", "someMethod",
            e -> e.advice(idempotentReceiverInterceptor()))
    ...
}
```

> The `IdempotentReceiverInterceptor` is designed only for the `MessageHandler.handleMessage(Message<?>)` method. Starting with version 4.3.1, it implements `HandleMessageAdvice`, with the `AbstractHandleMessageAdvice` as a base class, for better dissociation. See [Handling Message Advice](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/index-single.html#handle-message-advice) for more information.

---

## 10.10. Logging Channel Adapter

The `<logging-channel-adapter>` is often used in conjunction with a wire tap, as discussed in [Wire Tap](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/channel.html#channel-wiretap). However, it can also be used as the ultimate consumer of any flow. For example, consider a flow that ends with a `<service-activator>` that returns a result, but you wish to discard that result. To do that, you could send the result to `NullChannel`. Alternatively, you can route it to an `INFO` level `<logging-channel-adapter>`. That way, you can see the discarded message when logging at `INFO` level but not see it when logging at (for example) the `WARN` level. With a `NullChannel`, you would see only the discarded message when logging at the `DEBUG` level. The following listing shows all the possible attributes for the `logging-channel-adapter` element:

```xml
<int:logging-channel-adapter
    channel="" <!-- (1) -->
    level="INFO" <!-- (2) -->
    expression="" <!-- (3) -->
    log-full-message="false" <!-- (4) -->
    logger-name="" /> <!-- (5) -->
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> The channel connecting the logging adapter to an upstream component.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> The logging level at which messages sent to this adapter will be logged. Default: `INFO`.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> A SpEL expression representing exactly what parts of the message are logged. Default: `payload` — only the payload is logged. if `log-full-message` is specified, this attribute cannot be specified.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> When `true`, the entire message (including headers) is logged. Default: `false` — only the payload is logged. This attribute cannot be specified if `expression` is specified.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> Specifies the `name` of the logger (known as `category` in `log4j`). Used to identify log messages created by this adapter. This enables setting the log name (in the logging subsystem) for individual adapters. By default, all adapters log under the following name: `org.springframework.integration.handler.LoggingHandler`.</small>

### 10.10.1. Using Java Configuration

The following Spring Boot application shows an example of configuring the `LoggingHandler` by using Java configuration:

```java
@SpringBootApplication
public class LoggingJavaApplication {

    public static void main(String[] args) {
        ConfigurableApplicationContext context =
             new SpringApplicationBuilder(LoggingJavaApplication.class)
                    .web(false)
                    .run(args);
         MyGateway gateway = context.getBean(MyGateway.class);
         gateway.sendToLogger("foo");
    }

    @Bean
    @ServiceActivator(inputChannel = "logChannel")
    public LoggingHandler logging() {
        LoggingHandler adapter = new LoggingHandler(LoggingHandler.Level.DEBUG);
        adapter.setLoggerName("TEST_LOGGER");
        adapter.setLogExpressionString("headers.id + ': ' + payload");
        return adapter;
    }

    @MessagingGateway(defaultRequestChannel = "logChannel")
    public interface MyGateway {

        void sendToLogger(String data);

    }

}
```

### 10.10.2. Configuring with the Java DSL

The following Spring Boot application shows an example of configuring the logging channel adapter by using the Java DSL:

```java
@SpringBootApplication
public class LoggingJavaApplication {

    public static void main(String[] args) {
        ConfigurableApplicationContext context =
             new SpringApplicationBuilder(LoggingJavaApplication.class)
                    .web(false)
                    .run(args);
         MyGateway gateway = context.getBean(MyGateway.class);
         gateway.sendToLogger("foo");
    }

    @Bean
    public IntegrationFlow loggingFlow() {
        return IntegrationFlows.from(MyGateway.class)
                     .log(LoggingHandler.Level.DEBUG, "TEST_LOGGER",
                           m -> m.getHeaders().getId() + ": " + m.getPayload());
    }

    @MessagingGateway
    public interface MyGateway {

        void sendToLogger(String data);

    }

}
```

---

## 10.11. `java.util.function` Interfaces Support

Starting with version 5.1, Spring Integration provides direct support for interfaces in the `java.util.function` package. All messaging endpoints, (Service Activator, Transformer, Filter, etc.) can now refer to `Function` (or `Consumer`) beans. The [Messaging Annotations](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/configuration.html#annotations) can be applied directly on these beans similar to regular `MessageHandler` definitions. For example if you have this `Function` bean definition:

```java
@Configuration
public class FunctionConfiguration {

    @Bean
    public Function<String, String> functionAsService() {
        return String::toUpperCase;
    }

}
```

You can use it as a simple reference in an XML configuration file:

```xml
<service-activator input-channel="processorViaFunctionChannel" ref="functionAsService"/>
```

When we configure our flow with Messaging Annotations, the code is straightforward:

```java
@Bean
@Transformer(inputChannel = "functionServiceChannel")
public Function<String, String> functionAsService() {
    return String::toUpperCase;
}
```

When the function returns an array, `Collection` (essentially, any `Iterable`), `Stream` or Reactor `Flux`, `@Splitter` can be used on such a bean to perform iteration over the result content.

The `java.util.function.Consumer` interface can be used for an `<int:outbound-channel-adapter>` or, together with the `@ServiceActivator` annotation, to perform the final step of a flow:

```java
@Bean
@ServiceActivator(inputChannel = "messageConsumerServiceChannel")
public Consumer<Message<?>> messageConsumerAsService() {
    // Has to be an anonymous class for proper type inference
    return new Consumer<Message<?>>() {

        @Override
        public void accept(Message<?> e) {
            collector().add(e);
        }

    };
}
```

Also, pay attention to the comment in the code snippet above: if you would like to deal with the whole message in your `Function`/`Consumer` you cannot use a lambda definition. Because of Java type erasure we cannot determine the target type for the `apply()/accept()` method call.

The `java.util.function.Supplier` interface can simply be used together with the `@InboundChannelAdapter` annotation, or as a `ref` in an `<int:inbound-channel-adapter>`:

```java
@Bean
@InboundChannelAdapter(value = "inputChannel", poller = @Poller(fixedDelay = "1000"))
public Supplier<String> pojoSupplier() {
    return () -> "foo";
}
```

With the Java DSL we just need to use a reference to the function bean in the endpoint definitions. Meanwhile an implementation of the `Supplier` interface can be used as regular `MessageSource` definition:

```java
@Bean
public Function<String, String> toUpperCaseFunction() {
    return String::toUpperCase;
}

@Bean
public Supplier<String> stringSupplier() {
    return () -> "foo";
}

@Bean
public IntegrationFlow supplierFlow() {
    return IntegrationFlows.from(stringSupplier())
                .transform(toUpperCaseFunction())
                .channel("suppliedChannel")
                .get();
}
```

This function support is useful when used together with the [Spring Cloud Function](https://cloud.spring.io/spring-cloud-function/) framework, where we have a function catalog and can refer to its member functions from an integration flow definition.

### 10.11.1. Kotlin Lambdas

The Framework also has been improved to support Kotlin lambdas for functions so now you can use a combination of the Kotlin language and Spring Integration flow definitions:

```java
@Bean
@Transformer(inputChannel = "functionServiceChannel")
fun kotlinFunction(): (String) -> String {
    return { it.toUpperCase() }
}

@Bean
@ServiceActivator(inputChannel = "messageConsumerServiceChannel")
fun kotlinConsumer(): (Message<Any>) -> Unit {
    return { print(it) }
}

@Bean
@InboundChannelAdapter(value = "counterChannel",
        poller = [Poller(fixedRate = "10", maxMessagesPerPoll = "1")])
fun kotlinSupplier(): () -> String {
    return { "baz" }
}
```