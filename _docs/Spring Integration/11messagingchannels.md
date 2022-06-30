---
title: Messaging Channels
category: Spring Integration
order: 11
permalink: /Spring%20Integration/messaging-channels/
description: 메시지 채널 인터페이스와 구현체들
image: ./../../images/springintegration/logo.png
lastmod: 2022-01-05T21:30:00+09:00
comments: true
originalRefName: 스프링 인티그레이션
originalRefLink: https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/index-single.html#messaging-channels-section
parent: Core Messaging
parentUrl: /Spring%20Integration/core-messaging/
---
<script>defaultLanguages = ['java']</script>

### 목차

- [6.1. Message Channels](#61-message-channels)
  + [6.1.1. The MessageChannel Interface](#611-the-messagechannel-interface)
    * [PollableChannel](#pollablechannel)
    * [SubscribableChannel](#subscribablechannel)
  + [6.1.2. Message Channel Implementations](#612-message-channel-implementations)
    * [PublishSubscribeChannel](#publishsubscribechannel)
    * [QueueChannel](#queuechannel)
    * [PriorityChannel](#prioritychannel)
    * [RendezvousChannel](#rendezvouschannel)
    * [DirectChannel](#directchannel)
    * [ExecutorChannel](#executorchannel)
    * [FluxMessageChannel](#fluxmessagechannel)
    * [Scoped Channel](#scoped-channel)
  + [6.1.3. Channel Interceptors](#613-channel-interceptors)
  + [6.1.4. MessagingTemplate](#614-messagingtemplate)
  + [6.1.5. Configuring Message Channels](#615-configuring-message-channels)
    * [DirectChannel Configuration](#directchannel-configuration)
    * [Datatype Channel Configuration](#datatype-channel-configuration)
    * [QueueChannel Configuration](#queuechannel-configuration)
    * [PublishSubscribeChannel Configuration](#publishsubscribechannel-configuration)
    * [ExecutorChannel](#executorchannel-1)
    * [PriorityChannel Configuration](#prioritychannel-configuration)
    * [RendezvousChannel Configuration](#rendezvouschannel-configuration)
    * [Scoped Channel Configuration](#scoped-channel-configuration)
    * [Channel Interceptor Configuration](#channel-interceptor-configuration)
    * [Global Channel Interceptor Configuration](#global-channel-interceptor-configuration)
    * [Wire Tap](#wire-tap)
    * [Conditional Wire Taps](#conditional-wire-taps)
    * [Global Wire Tap Configuration](#global-wire-tap-configuration)
  + [6.1.6. Special Channels](#616-special-channels)
- [6.2. Poller](#62-poller)
  + [6.2.1. Polling Consumer](#621-polling-consumer)
  + [6.2.2. Pollable Message Source](#622-pollable-message-source)
  + [6.2.3. Deferred Acknowledgment Pollable Message Source](#623-deferred-acknowledgment-pollable-message-source)
  + [6.2.4. Conditional Pollers for Message Sources](#624-conditional-pollers-for-message-sources)
    * [Background](#background)
    * [“Smart” Polling](#smart-polling)
    * [SimpleActiveIdleReceiveMessageAdvice](#simpleactiveidlereceivemessageadvice)
    * [CompoundTriggerAdvice](#compoundtriggeradvice)
    * [MessageSource-only Advices](#messagesource-only-advices)
- [6.3. Channel Adapter](#63-channel-adapter)
  + [6.3.1. Configuring An Inbound Channel Adapter](#631-configuring-an-inbound-channel-adapter)
  + [6.3.2. Configuring An Outbound Channel Adapter](#632-configuring-an-outbound-channel-adapter)
  + [6.3.3. Channel Adapter Expressions and Scripts](#633-channel-adapter-expressions-and-scripts)
- [6.4. Messaging Bridge](#64-messaging-bridge)
  + [6.4.1. Configuring a Bridge with XML](#641-configuring-a-bridge-with-xml)
  + [6.4.2. Configuring a Bridge with Java Configuration](#642-configuring-a-bridge-with-java-configuration)
  + [6.4.3. Configuring a Bridge with the Java DSL](#643-configuring-a-bridge-with-the-java-dsl)

---

## 6.1. Message Channels

`Message`는 데이터 캡슐화라는 중요한 역할을 맡고있다. 하지만 메시지 프로듀서와 메시지 컨슈머를 분리해주는 것은 `MessageChannel`이다.

### 6.1.1. The MessageChannel Interface

Spring Integration의 최상위 `MessageChannel` 인터페이스는 다음과 같이 정의된다:

```java
public interface MessageChannel {

    boolean send(Message message);

    boolean send(Message message, long timeout);
}
```

메시지를 전송할 때는, 메시지 전송에 성공하면 `true`를 반환한다. 전송 중에 타임아웃이 발생하거나 중단<sup>interrupt</sup>되면 `false`를 반환한다. 

#### `PollableChannel`

메시지 채널은 메시지를 버퍼링할 수도, 하지 않을 수도 있으므로 ([Spring Integration Overview](../overview)에서 언급한 바 있다), 두 가지 하위 인터페이스로 버퍼링(pollable) 채널과 비버퍼링(subscribable) 채널의 동작을 구분한다. 다음은 `PollableChannel` 인터페이스의 정의다:

```java
public interface PollableChannel extends MessageChannel {

    Message<?> receive();

    Message<?> receive(long timeout);

}
```

메시지를 수신할 때에도 send 메소드와 마찬가지로 타임아웃이나 인터럽트 시에 반환 값은 null이 된다.

#### `SubscribableChannel`

`SubscribableChannel`은 자신을 구독하는 `MessageHandler` 인스턴스에 직접 메시지를 보내는 채널들이 구현하는 기본 인터페이스다. 따라서 폴링을 위한 receive 메소드는 제공하지 않는다. 그대신 구독자들을 관리할 수 있는 메소드를 정의한다. 다음은 `SubscribableChannel` 인터페이스의 정의다:

```java
public interface SubscribableChannel extends MessageChannel {

    boolean subscribe(MessageHandler handler);

    boolean unsubscribe(MessageHandler handler);

}
```

### 6.1.2. Message Channel Implementations

Spring Integration은 다양한 종류의 메시지 채널 구현체를 제공한다. 이어지는 섹션에서는 구현체들을 하나씩 간단하게 요약해본다.

#### `PublishSubscribeChannel`

`PublishSubscribeChannel` 구현체는 전달받은 모든 `Message`를 자신을 구독하는 모든 핸들러로 브로드캐스트한다. 주로 통보<sup>notification</sup>를 위한 이벤트 메시지들을 (일반적으로 단일 핸들러로 처리하는 것을 의도하는 [document message](https://www.enterpriseintegrationpatterns.com/DocumentMessage.html)와 정반대의 성격을 지니고 있다) 전송하는 데 사용하는 경우가 가장 많다. `PublishSubscribeChannel`은 오직 전송만을 위한 구현체라는 점에 유의하자. 이 구현체는 `send(Message)` 메소드를 호출하면 구독자에게 직접 브로드캐스트하기 때문에, 컨슈머는 메시지를 폴링할 수 없다 (`PollableChannel`을 구현하지 않았기 때문에 `receive()` 메소드 자체가 없다). 그보단 구독자 자체는 전부 `MessageHandler`여야 하며, 구독자의 `handleMessage(Message)` 메소드를 차례로 호출한다.

3.0 버전 이전에는 구독자가 없는 `PublishSubscribeChannel`에서 `send` 메소드를 호출하면 `false`를 반환했었다. `MessagingTemplate`과 함께 사용하면 `MessageDeliveryException`이 발생했었다. 이 동작은 3.0부터 변경돼서 구독자가 최소치만큼 존재한다면 (그리고 메세지 처리에 성공하면) `send`는 항상 성공한 것으로 간주한다. 이 동작은 `minSubscribers` 프로퍼티를 설정하면 수정할 수 있으며, 기본값은 `0`이다.

> `TaskExecutor`를 사용할 때는 실제 메시지 처리를 비동기로 수행하기 때문에, `send`의 성공 여부는 오직 구독자가 적당한 수만큼 존재하는지로만 결정된다.

#### `QueueChannel`

`QueueChannel`은 큐 하나를 감싸고 있는 구현체다. `PublishSubscribeChannel`과는 달리 `QueueChannel`은 point-to-point 시멘틱스를 가진다. 즉, 채널에 컨슈머가 여럿 있더라도, 해당 채널로 전송된 모든 `Message`는 하나의 컨슈머만 받아야 한다. 이 구현체는 인자가 없는 기본 생성자와 (사실상 `Integer.MAX_VALUE`라는 용량을 무제한으로 제공), 아래에 보이는 큐 용량을 받는 생성자를 하나 제공한다:

```java
public QueueChannel(int capacity)
```

용량 제한치를 다 사용하지 않은 채널은 내부 큐에 메시지를 저장하며, `send(Message<?>)` 메소드는 메시지를 처리할 준비가 된 receiver가 없더라도 즉시 반환한다. 큐가 가득 차면 여유 공간이 생기기 전까지는 sender를 블로킹한다. 또는 타임아웃 파라미터를 별도로 받는 send 메소드를 사용하는 경우엔, 큐에 여유가 생기거나 타임아웃이 발생할 때까지 큐를 블로킹한다. 마찬가지로 `receive()`를 호출할 때도 큐에 메시지가 있다면 즉시 반환하지만, 큐가 비어 있다면 메시지를 사용할 수 있게 되거나 혹은 타임아웃을 지정했다면 이 시간이 경과할 때까지 receive 호출이 차단될 수 있다. 두 경우 모두 타임아웃 값으로 0을 전달하면 큐의 상태에 관계 없이 강제로 즉시 반환하도록 만들 수 있다. 하지만 `timeout` 파라미터 없이 `send()`나 `receive()`를 호출하면 무한정 블로킹된다는 점에 유의하자.

#### `PriorityChannel`

`QueueChannel`은 FIFO<sup>first-in-first-out</sup>를 따르는 반면, `PriorityChannel`을 사용하면 채널 내에서 우선 순위에 따라 메시지를 정렬할 수 있다. 기본적으로 우선 순위는 각 메시지 안에 있는 `priority` 헤더로 결정한다. 우선 순위 결정 로직을 커스텀하고 싶다면 `PriorityChannel` 생성자에 `Comparator<Message<?>>` 타입을 제공하면 된다.

#### `RendezvousChannel`

`RendezvousChannel`은 다른 곳에서 이 채널의 `receive()` 메소드를 호출할 때까지 sender를 블로킹하는 "direct-handoff" 시나리오를 구현하고 있다. 상대방은 sender가 메시지를 보낼 때까지 블로킹된다. 내부적으로 이 구현체는 `SynchronousQueue`(용량이 없는 `BlockingQueue`의 구현체)를 사용한다는 점만 빼면 `QueueChannel`과 매우 유사하다. 이 클래스는 sender와 receiver가 각자 다른 스레드에서 동작하지만 큐에서 비동기로 메세지를 삭제하는 게 적합하지 않은 상황에 활용할 수 있다. 즉, `QueueChannel`을 사용하면 메시지가 내부 큐에 저장돼서 어디에서도 수신하지 않을 가능성이 있지만, `RendezvousChannel`에선 어떠한 receiver가 메시지를 수락했다는 것을 sender가 바로 알 수 있다.

> 이렇게 큐를 기반으로 동작하는 모든 채널들은 메세지를 기본적으로 메모리에만 저장한다는 점을 명심하자. 지속성<sup>persistence</sup>이 요구된다면 'queue' 요소에 'message-store' 속성을 넣어 persistent `MessageStore` 구현체를 참조시키거나, 로컬 채널을 JMS를 이용하는 채널이나 채널 어댑터같이 persistent 브로커를 사용하는 채널로 교체해주면 된다. 후자를 선택하면 [JMS 지원](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/jms.html#jms)에서 설명하는 메시지 영구 보관<sup>persistence</sup>을 위한 모든 JMS provider의 구현체를 활용할 수 있다. 하지만 큐 안에서 메세지를 버퍼링할 필요가 없다면, 다음 섹션에서 설명하는 `DirectChannel`을 사용하는 게 가장 간단할 거다.

`RendezvousChannel`은 request-reply 작업을 구현할 때도 유용하게 활용할 수 있다. sender에서 임시로 `RendezvousChannel`의 익명 인스턴스를 생성하고, `Message`를 빌드할 때 'replyChannel' 헤더에 이 인스턴스를 설정할 수 있다. sender는 이 `Message`를 보낸 후 즉시 `receive`를 호출해서 (원한다면 타임아웃 값도 제공해서) 응답 `Message`를 기다리는 동안 블로킹할 수 있다. 이 패턴은 Spring Integration의 많은 request-reply 구성 요소들이 내부적으로 사용하는 구현 로직과 매우 유사하다.

#### `DirectChannel`

`DirectChannel`은 point-to-point 시멘틱스를 가지지만, 다른 한 편으론 앞에서 설명한 큐 기반 채널 구현체들보단 `PublishSubscribeChannel`과 더 유사하다. 이 클래스는 `PollableChannel` 인터페이스 대신 `SubscribableChannel` 인터페이스를 구현하므로 구독자에게 직접 메시지를 발송한다. 하지만 point-to-point 채널로서, 이 채널을 구독하는 하나의 `MessageHandler`에게 각 `Message`를 전송한다는 점에서 `PublishSubscribeChannel`과 다르다.

`DirectChannel`은 point-to-point 채널 중 가장 간단한 채널이기도 하면서, 단일 스레드로 채널의 "양쪽" 작업을 모두 수행할 수 있다는 중요한 특징이 있다. 예를 들어 핸들러가 `DirectChannel`을 구독할 때 이 채널에 `Message`를 전송하면, `send()` 메소드를 반환하기 전에 sender의 스레드에서 직접 핸들러의 `handleMessage(Message)` 메소드 실행을 트리거한다.

이렇게 동작하는 채널 구현체를 제공하는 주된 이유는 채널을 이용함으로써 누릴 수 있는 추상화와 느슨한 결합<sup>loose coupling</sup>은 그대로 누리면서, 채널 전체를 커버할 수 있는 트랜잭션을 지원하기 위함이다. 트랜잭션 범위 내에서 `send()` 메소드를 호출하면 핸들러의 실행 결과(ex. 데이터베이스 레코드 업데이트)로 해당 트랜잭션의 최종적인 결과(커밋 또는 롤백)가 결정된다.

> `DirectChannel`은 가장 간단한 구현체이기도 하고, poller의 스레드를 스케줄링하고 관리하지 않아 별도 오버헤드가 없기 때문에, `DirectChannel`이 Spring Integration의 기본 채널 타입이다. 보통 애플리케이션을 개발할 땐 필요한 채널들을 정의하고, 버퍼링이나 입력 스로틀링<sup>throttling</sup>이 요구되는 채널을 선별해서 큐 기반 `PollableChannel`로 수정하는 식으로 진행한다. 마찬가지로 메시지를 브로드캐스트해야 하는 채널이 있다면 `DirectChannel`이 아니라 `PublishSubscribeChannel`을 사용해야 한다. 이런 채널들을 하나씩 설정하는 방법은 뒤에서 보여준다.

`DirectChannel`은 내부적으로 이 채널을 구독하는 메시지 핸들러를 호출하는 일을 메시지 디스패처에 위임한다. 이 디스패처는 `load-balancer`나 `load-balancer-ref` 속성으로 결정되는 (이 둘은 함께 사용할 수 없다) 로드 밸런싱 전략을 가질 수 있다. 로드 밸런싱 전략으로는 여러 메시지 핸들러가 같은 채널을 구독할 때 디스패처가 메시지 핸들러에 메시지를 분배하는 방법을 결정한다. `load-balancer` 속성으로는 간편히 기본 제공하는 `LoadBalancingStrategy` 구현체를 가리킬 수 있다. 이 속성에는 `round-robin`(핸들러를 돌아가며 로드 밸런싱)과 `none`(로드 밸런싱을 명시적으로 비활성화)만 사용할 수 있다. 향후 버전에선 다른 구현체가 추가될 수도 있다. 하지만 3.0 버전부터는 자체 `LoadBalancingStrategy` 구현체를 만들어 `load-balancer-ref` 속성을 통해 주입할 수 있다. 이 속성은 아래 보이는 예제처럼 `LoadBalancingStrategy`를 구현한 빈을 가리켜야 한다:

`FixedSubscriberChannel`은 구독을 취소할 수 없는 단일 `MessageHandler` 구독자만 지원하는 `SubscribableChannel`이다. 이 구현체는 다른 구독자는 관여하지 않으며 채널 인터셉터 필요 없이, 높은 처리량이 요구되는 유스 케이스에 활용할 수 있다.

```xml
<int:channel id="lbRefChannel">
  <int:dispatcher load-balancer-ref="lb"/>
</int:channel>

<bean id="lb" class="foo.bar.SampleLoadBalancingStrategy"/>
```

`load-balancer` 속성과 `load-balancer-ref` 속성은 함께 사용할 수 없다는 점에 주의하자.

로드 밸런싱은 boolean 프로퍼티 `failover`에 따라서도 동작이 달라진다.  디스패처는 `failover` 값이 true일 땐 (기본값), 먼저 선택된 핸들러가 예외를 던지면 그 다음 핸들러로 폴백한다 (필요하다면). 폴백 순서는 핸들러 자체에 order 값이 정의돼 있으면 이 값으로 결정하고, 그 외는 핸들러가 구독한 순서대로 결정된다.

상황에 따라 디스패처는 항상 첫 번째 핸들러를 호출하고, 에러가 발생할 때마다 매번 일정한 순서로 폴백해야 할 때도 있다. 이럴 땐 로드 밸런싱 전략을 제공하지 않는 것이 좋다. 즉, 디스패처는 로드 밸런싱을 활성화하지 않아도 boolean 프로퍼티 `failover`를 계속 지원한다. 물론 로드 밸런싱이 없을 땐 가지고 있는 핸들러의 순서에 따라 항상 첫 번째 핸들러로 시작한다. 이 방식은 예를 들면 첫 번째, 두 번째, 세 번째 핸들러 등에 대한 명확한 정의가 있을 때 적합하다. 네임스페이스를 이용할 땐 엔드포인트에 있는 `order` 속성이 이 순서를 결정한다.

> 로드 밸런싱과  `failover`는 채널을 구독하는 메시지 핸들러가 두 개 이상 있을 때에만 적용된다는 점에 주의하자. 네임스페이스를 이용할 때에는 둘 이상의 엔드포인트가 `input-channel` 속성으로 같은 채널을 참조하는 상황을 의미한다.

5.2 버전부터 `failover`가 true일 땐, 설정에 따라 실패한 현재 핸들러를 실패 메시지와 함께 `debug` 또는 `info` 로그로 기록한다.

#### `ExecutorChannel`

`ExecutorChannel`은 `DirectChannel`과 동일한 디스패처 설정(로드 밸런싱 전략 및 boolean 프로퍼티 `failover`)을 지원하는 point-to-point 채널이다. 이 두 가지 디스패치 채널 유형의 가장 큰 차이점은, `ExecutorChannel`은 디스패치 수행을 `TaskExecutor` 인스턴스에 위임한다는 거다. 따라서 일반적으로 send 메소드가 블로킹되지 않는다는 것을 알 수 있는데, 동시에 핸들러 호출을 sender의 스레드에서 진행하지 않을 수도 있다는 걸 뜻한다. 따라서 sender와 이를 받는 핸들러를 아우르는 트랜잭션은 지원하지 않는다.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>경우에 따라 sender가 블로킹될 수도 있다. 예를 들어, <code class="highlighter-rouge">TaskExecutor</code>를 클라이언트를 스로틀링<sup>throttling</sup>하는 rejection 정책과 함께 사용하는 경우엔 (ex. <code class="highlighter-rouge">ThreadPoolExecutor.CallerRunsPolicy</code>), 스레드 풀이 최대 용량에 도달해 있고 executor의 작업 큐가 가득 찼다면 언제든지 sender의 스레드에서 해당 메소드를 실행할 수 있다. 이런 상황은 언제나 예측할 수 없는 방식으로 일어나기 때문에 이걸 믿고 트랜잭션을 사용해선 안 된다.</p>
</blockquote>


#### `FluxMessageChannel`

`FluxMessageChannel`은 다운스트림에 있는 리액티브 구독자가 온디맨드로 컨슘해갈 수 있도록 전달받은 메세지를 내부 `reactor.core.publisher.Flux`로 `"sink"`하는 `org.reactivestreams.Publisher`의 구현체다. 이 채널 구현체는 `SubscribableChannel`이나 `PollableChannel`이 아니기 때문에, `org.reactivestreams.Subscriber` 인스턴스만이 이 채널에서 리액티브 스트림의 back-pressure를 지키며 메세지를 컨슘해갈 수 있다. 한편으로는 `FluxMessageChannel`은 `ReactiveStreamsSubscribableChannel` 인터페이스의 `subscribeTo(Publisher<Message<?>>)` 메소드를 구현해 리액티브 소스 publisher로부터 이벤트를 받아 리액티브 스트림을 통합 플로우로 연결해준다. 전체 통합 플로우에서 완전하게 리액티브로 동작하려면 플로우에 있는 모든 엔드포인트 사이사이에 반드시 이런 채널을 배치해야 한다.

리액티브 스트림즈와의 상호 작용에 대한 자세한 내용은 [리액티브 스트림즈 지원](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/reactive-streams.html#reactive-streams)을 참고해라.

#### Scoped Channel

Spring Integration 1.0에선 `ThreadLocalChannel`을 제공했었지만 이 구현체는 2.0에서 제거됐다. 이제 같은 요구 사항은 채널에 `scope` 속성을 추가하는 좀 더 범용적인 방법으로 해결할 수 있다. 이 속성에는 컨텍스트 내에서 사용 가능한 스코프의 이름을 지정한다. 예를 들어 웹 환경에서는 여러 가지 스코프를 사용할 수 있으며 컨텍스트에 원하는 커스텀 스코프 구현체를 등록할 수 있다. 다음은 thread-local 스코프를 등록하고 채널 하나에 적용해보는 예제다:

```xml
<int:channel id="threadScopedChannel" scope="thread">
     <int:queue />
</int:channel>

<bean class="org.springframework.beans.factory.config.CustomScopeConfigurer">
    <property name="scopes">
        <map>
            <entry key="thread" value="org.springframework.context.support.SimpleThreadScope" />
        </map>
    </property>
</bean>
```

위 예제에서 정의하는 채널 역시 내부적으로 큐에 위임하고 있지만, 이 채널은 현재 스레드에 바인딩돼 있으므로 큐의 내용물도 비슷하게 바인딩된다. 이렇게 하면 채널에 메세지를 전송한 스레드는 이후에 같은 메시지들을 받을 수 있지만, 다른 스레드에선 해당 메시지에 액세스할 수 없게 된다. 스레드 스코프를 적용하는 채널이 필요한 경우는 거의 없지만, 단일 스레드로 작업하기 위해 `DirectChannel` 인스턴스를 사용하고 있지만 응답 메시지는 또 다른 "말단<sup>terminal</sup>" 채널로 전송해야 하는 상황이라면 유용할 거다. 이 말단 채널에 스레드 스코프를 적용했다면 기존 전송 스레드가 말단 채널에서 응답을 수집할 수 있다.

이제 모든 채널은 스코프를 지정할 수 있으므로 thread-Local 외에도 자체 스코프들을 정의할 수 있다.

### 6.1.3. Channel Interceptors

메시지 아키텍처는 공통적으로 필요한 동작들을 처리해주며, 비침투적인<sup>non-invasive</sup> 방식으로 시스템을 관통하는 메시지에서 의미 있는 정보를 잡아낼 수 있다는 장점이 있다. `Message` 인스턴스는 `MessageChannel` 인스턴스를 통해 주고 받기 때문에, 이 채널을 통해 send와 receive 동작을 가로챌 수 있다. 각 동작들을 위한 메소드는 아래 있는 전략 인터페이스 `ChannelInterceptor`가 제공한다:

```java
public interface ChannelInterceptor {

    Message<?> preSend(Message<?> message, MessageChannel channel);

    void postSend(Message<?> message, MessageChannel channel, boolean sent);

    void afterSendCompletion(Message<?> message, MessageChannel channel, boolean sent, Exception ex);

    boolean preReceive(MessageChannel channel);

    Message<?> postReceive(Message<?> message, MessageChannel channel);

    void afterReceiveCompletion(Message<?> message, MessageChannel channel, Exception ex);
}
```

이 인터페이스를 구현한 인터셉터를 만들었다면, 아래와 같이 호출만 해주면 채널에 등록할 수 있다:

```java
channel.addInterceptor(someChannelInterceptor);
```

`Message` 인스턴스를 반환하는 메소드들은 `Message`를 변환하는 데 이용할 수 있으며, 더 이상의 처리를 막고싶다면 'null'을 반환해도 된다 (물론 모든 메소드에서 `RuntimeException`을 던질 수 있다). `preReceive` 메소드에서도 `false`를 반환하면 receive 작업이 진행되는 걸 막을 수 있다.

> `receive()`를 호출하는 것은 `PollableChannel`과만 관련 있다는 점을 기억해두자. 사실 `SubscribableChannel` 인터페이스는 `receive()` 메소드를 정의하고 있지도 않다. 그 이유는 `Message`가 `SubscribableChannel`로 전송될 땐 채널 유형에 따라 0개 이상의 구독자에게 곧바로 전송되기 때문이다 (예를 들어 `PublishSubscribeChannel`은 모든 구독자에게 메시지를 전송한다) . 따라서 인터셉터 메소드 `preReceive(…)`, `postReceive(…)`, `afterReceiveCompletion(…)`은 `PollableChannel`에 인터셉터를 적용했을 때만 실행된다.

Spring Integration은 [Wire Tap](https://www.enterpriseintegrationpatterns.com/WireTap.html) 패턴을 구현한 클래스도 제공한다. 이 구현체는 기존 플로우는 별도로 변경하지 않은 채 `Message`를 다른 채널로 전송해주는 간단한 인터셉터다. 디버깅과 모니터링에 아주 유용할 거다. 예제는 [Wire Tap](#wire-tap)에서 확인할 수 있다.

인터셉터의 모든 메소드를 구현해야 하는 상황은 거의 없기 때문에, 이 인터페이스는 no-op 디폴트 메소드들을 제공한다 (`void`를 반환하는 메소드들은 아무 코드도 없고, `Message`를 반환하는 메소드들은 `Message`를 그대로 반환하고, `boolean` 메소드는 `true`를 반환한다).

> 인터셉터 메소드들이 호출되는 순서는 채널 유형에 따라 달라진다. 앞에서도 설명했지만, `receive()` 메소드를 가로채가는 채널은 애초에 큐 기반 채널들이 유일하다. send, receive 메소드를 가로채는 순서는 sender와 receiver 각자의 스레드 타이밍에 따라서도 달라진다. 예를 들어 receiver가 먼저 블로킹돼서 메시지를 기다리고 있었다면, `preSend`, `preReceive`, `postReceive`, `postSend` 순서로 호출될 수 있다. 반대로 sender가 채널에 메시지를 보내 이미 반환한 뒤에 receiver가 폴링하는 상황이라면, `preSend`, `postSend` (얼마만큼의 시간 경과), `preReceive`, `postReceive` 순이 된다. 이때 경과하는 시간은 여러 가지 요인에 따라 달라지므로 보통은 예측이 불가능하다 (실제로 receive가 일어나지 않을 수도 있다). 큐 유형에 따라서 달라지기도 한다 (ex. rendezvous vs priority). 간단히 말해 `preSend`가 `postSend` 보다 먼저 실행된다는 점과, `preReceive`가 `postReceive` 보다 먼저 실행된다는 점 외에는 어떠한 순서도 가정하면 안 된다.

Spring Framework 4.1과 Spring Integration 4.1부터 `ChannelInterceptor`는 `afterSendCompletion()`, `afterReceiveCompletion()`이라는 신규 메소드를 제공한다. 이 메소드들은 예외 발생 여부에 상관 없이 `send()`, `receive()` 호출 이후에 실행되기 때문에 리소스 정리에 이용할 수 있다. 채널에서 이 메소드들을 호출할 땐, `ChannelInterceptor` 목록에서 앞서 `preSend()`와 `preReceive()`를 호출했던 순서의 역순으로 인터셉터를 가져와 호출한다는 점에 주의하자.

5.1 버전부터 동적으로 등록된 채널에도 글로벌 채널 인터셉터가 적용된다 (ex. `beanFactory.initializeBean()`으로 초기화하거나, 자바 DSL에서 `IntegrationFlowContext`를 사용해 초기화하는 빈들). 이전에는 애플리케이션 컨텍스트를 리프레시한 이후에 빈을 생성할 땐 인터셉터가 적용되지 않았다.

그 외에도, 5.1 버전부터 수신한 메시지가 없으면 더 이상 `ChannelInterceptor.postReceive()`를 호출하지 않는다. 더 이상 `null` `Message<?>`를 체크하지 않아도 된다. 이전에는 이 메소드가 호출됐었다. 이전 동작에 의존하는 인터셉터가 있다면 대신 `afterReceiveCompleted()`를 구현해라. 이 메소드는 메시지 수신 여부에 관계없이 실행된다.

> 5.2 버전부터 `ChannelInterceptorAware`는 deprecated 되었으며, Spring Messaging 모듈에 있는 `InterceptableChannel`로 대신한다. `ChannelInterceptorAware`는 구버전과의 호환성을 위해 `InterceptableChannel`을 상속하고 있다.

### 6.1.4. `MessagingTemplate`

엔드포인트와 다양한 설정 옵션들이 도입됐고, Spring Integration은 메시지 관련 구성 요소들의 기반을 마련해 메시지 처리 시스템이 애플리케이션 코드를 비침투적으로<sup>non-invasive</sup> 실행할 수 있도록 만들어준다. 하지만 애플리케이션 코드에서 메시지 처리 시스템을 호출해야 하는 경우가 간혹 있다. Spring Integration은 이런 유스 케이스를 구현할 때 간편하게 활용할 수 있는 `MessagingTemplate`을 제공한다. `MessagingTemplate`은 request & reply 시나리오를 포함해 메시지 채널 전반에 걸친 다양한 작업들을 지원한다. 예를 들면 다음과 같이 요청을 보내고 응답을 기다릴 수 있다:

```java
MessagingTemplate template = new MessagingTemplate();

Message reply = template.sendAndReceive(someChannel, new GenericMessage("test"));
```

위 예제에서 템플릿은 내부적으로 임시 익명 채널을 하나 생성한다. 템플릿에 'sendTimeout', 'receiveTimeout' 프로퍼티를 설정하는 것도 가능하며, 그외 다른 exchange 유형들도 지원한다. 다음은 관련 메소드들의 시그니처를 나타낸 코드다:

```java
public boolean send(final MessageChannel channel, final Message<?> message) { ...
}

public Message<?> sendAndReceive(final MessageChannel channel, final Message<?> request) { ...
}

public Message<?> receive(final PollableChannel<?> channel) { ...
}
```

> [Enter the `GatewayProxyFactoryBean`](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/gateway.html#gateway-proxy)에서는 `Message` 인스턴스 대신 페이로드나 헤더 값들을 사용해 단순한 인터페이스를 호출할 수 있는 덜 침투적인<sup>invasive</sup> 방법을 소개하고 있다.

### 6.1.5. Configuring Message Channels

메시지 채널 인스턴스를 생성하려면 다음과 같이 xml에서 `<channel/>` 요소를 사용하거나, 자바 설정에선 `DirectChannel` 인스턴스를 사용하면 된다:

<div class="switch-language-wrapper java xml">
<span class="switch-language java">Java</span>
<span class="switch-language xml">XML</span>
</div>
<div class="language-only-for-java java xml"></div>
```java
@Bean
public MessageChannel exampleChannel() {
    return new DirectChannel();
}
```
<div class="language-only-for-xml java xml"></div>
```xml
<int:channel id="exampleChannel"/>
```

다른 하위 요소 없이 `<channel/>` 요소를 사용하면 `DirectChannel` 인스턴스(`SubscribableChannel`)가 만들어진다.

publish-subscribe 채널을 생성하려면 다음과 같이 `<publish-subscribe-channel/>` 요소를 사용해라 (자바에선 `PublishSubscribeChannel`):

<div class="switch-language-wrapper java xml">
<span class="switch-language java">Java</span>
<span class="switch-language xml">XML</span>
</div>
<div class="language-only-for-java java xml"></div>
```java
@Bean
public MessageChannel exampleChannel() {
    return new PublishSubscribeChannel();
}
```
<div class="language-only-for-xml java xml"></div>
```xml
<int:publish-subscribe-channel id="exampleChannel"/>
```

다양한 하위 요소 `<queue/>`를 활용해서 다른 pollable 채널을 생성할 수도 있다 ([메시지 채널 구현체](#612-message-channel-implementations)에서 설명했던 유형들). 이어지는 섹션에선 채널 유형별로 예제를 소개한다.

#### `DirectChannel` Configuration

앞에서도 말했듯이 `DirectChannel`은 디폴트 채널이다. 다음은 이 디폴트 채널을 정의하는 모습을 보여준다:

<div class="switch-language-wrapper java xml">
<span class="switch-language java">java</span>
<span class="switch-language xml">xml</span>
</div>
<div class="language-only-for-java java xml"></div>
```java
@Bean
public MessageChannel directChannel() {
    return new DirectChannel();
}
```
<div class="language-only-for-xml java xml"></div>
```xml
<int:channel id="directChannel"/>
```

디폴트 채널은 라운드 로빈 로드 밸런서를 가지고 있으며 패일오버도 활성화돼 있다 (자세한 내용은 [`DirectChannel`](#directchannel) 참고). 이 중 비활성화하고 싶은 게 있다면 하위 요소 `<dispatcher/>`(`DirectChannel`의 `LoadBalancingStrategy` 생성자)를 추가하고 속성을 다음과 같이 설정해라:

<div class="switch-language-wrapper java xml">
<span class="switch-language java">java</span>
<span class="switch-language xml">xml</span>
</div>
<div class="language-only-for-java java xml"></div>
```java
@Bean
public MessageChannel failFastChannel() {
    DirectChannel channel = new DirectChannel();
    channel.setFailover(false);
    return channel;
}

@Bean
public MessageChannel failFastChannel() {
    return new DirectChannel(null);
}
```
<div class="language-only-for-xml java xml"></div>
```xml
<int:channel id="failFastChannel">
    <int:dispatcher failover="false"/>
</channel>

<int:channel id="channelWithFixedOrderSequenceFailover">
    <int:dispatcher load-balancer="none"/>
</int:channel>
```

#### Datatype Channel Configuration

간혹 컨슈머가 특정 유형의 페이로드만 처리할 수 있어서 입력 메시지의 페이로드 유형을 반드시 확인해야 할 때가 있다. 아마도 메세지 필터를 이용하는 방법이 가장 먼저 떠오를 거다. 하지만 메시지 필터가 할 수 있는 일은 컨슈머 요구 사항에 맞지 않는 메시지를 걸러내는 게 전부다. 또 다른 방법은 컨텐츠 기반 라우터를 이용해서, 맞지 않는 데이터를 가지고 있는 메시지를 특정 트랜스포머로 라우팅해 필요한 데이터 타입으로 변환해주는 거다. 이렇게도 구현할 수 있지만, [Datatype Channel](https://www.enterpriseintegrationpatterns.com/DatatypeChannel.html) 패턴을 적용하면 같은 로직을 더 쉽게 구현할 수 있다. 각 페이로드 데이터의 유형마다 별도 datatype 채널을 사용하면 된다.

특정한 페이로드 유형을 가지고 있는 메시지만 허용하는 datatype 채널을 생성하려면, 다음 예제와 같이 채널 요소의 `datatype` 속성에 데이터 타입에 해당하는 클래스의 풀 네임<sup>fully-qualified name</sup>을 지정해라:

<div class="switch-language-wrapper java xml">
<span class="switch-language java">Java</span>
<span class="switch-language xml">XML</span>
</div>
<div class="language-only-for-java java xml"></div>
```java
@Bean
public MessageChannel numberChannel() {
    DirectChannel channel = new DirectChannel();
    channel.setDatatypes(Number.class);
    return channel;
}
```
<div class="language-only-for-xml java xml"></div>
```xml
<int:channel id="numberChannel" datatype="java.lang.Number"/>
```

데이터 타입을 검사할 땐 채널의 datatype에 할당할 수 있는 모든 타입을 통과시킨다는 점을 주의하자. 다시 말해 위 예제에 있는 `numberChannel`은 페이로드가 `java.lang.Integer`나 `java.lang.Double`인 메시지를 모두 수락한다. 타입이 여러 개일 땐 다음 예제와 같이 콤마로 구분해서 지정해주면 된다:

<div class="switch-language-wrapper java xml">
<span class="switch-language java">Java</span>
<span class="switch-language xml">XML</span>
</div>
<div class="language-only-for-java java xml"></div>
```java
@Bean
public MessageChannel numberChannel() {
    DirectChannel channel = new DirectChannel();
    channel.setDatatypes(String.class, Number.class);
    return channel;
}
```
<div class="language-only-for-xml java xml"></div>
```xml
<int:channel id="stringOrNumberChannel" datatype="java.lang.String,java.lang.Number"/>
```

따라서 위 예제에 있는 'numberChannel'은 데이터 타입이 `java.lang.Number`인 메시지만 수락한다. 그런데 메시지의 페이로드가 요구하는 타입이 아닌 경우엔 어떤 일이 일어날까? 이는 `integrationConversionService`라는 스프링의 [Conversion Service](https://docs.spring.io/spring/docs/current/spring-framework-reference/html/validation.html#core-convert-ConversionService-API) 인스턴스 빈을 정의했는지에 따라 다르다. 이 빈을 정의하지 않았다면 즉시 `Exception`이 발생한다. 하지만 `integrationConversionService` 빈을 정의했다면, 이 빈을 사용해 메시지의 페이로드를 허용할 수 있는 타입으로 변환해본다.

커스텀 컨버터를 등록하는 것도 가능하다. 예를 들어 위에서 설정한 'numberChannel'에 `String` 페이로드를 가지고 있는 메시지를 보낸다고 가정해보자. 메세지를 다음과 같이 처리할 수도 있다:

```java
MessageChannel inChannel = context.getBean("numberChannel", MessageChannel.class);
inChannel.send(new GenericMessage<String>("5"));
```

평소 같은 상황이라면 아무런 문제 없는 작업이다. 하지만 지금은 Datatype 채널을 사용하고 있기 때문에, 코드를 이렇게 작성하면 아래와 유사한 예외가 발생하게 된다:

```java
Exception in thread "main" org.springframework.integration.MessageDeliveryException:
Channel 'numberChannel'
expected one of the following datataypes [class java.lang.Number],
but received [class java.lang.String]
…
```

이 예외가 발생하는 원인은 `Number` 타입의 페이로드가 필요한데 `String`을 전송했기 때문이다. 따라서 `String`을 `Number`로 변환해줄 무언가가 필요하다. 이럴 땐 아래 예제와 비슷한 컨버터를 구현하면 된다:

```java
public static class StringToIntegerConverter implements Converter<String, Integer> {
    public Integer convert(String source) {
        return Integer.parseInt(source);
    }
}
```

그런 다음 아래 예제처럼 Integration Conversion Service에서 쓸 컨버터로 등록해주면 된다:

<div class="switch-language-wrapper java xml">
<span class="switch-language java">Java</span>
<span class="switch-language xml">XML</span>
</div>
<div class="language-only-for-java java xml"></div>
```java
@Bean
@IntegrationConverter
public StringToIntegerConverter strToInt {
    return new StringToIntegerConverter();
}
```
<div class="language-only-for-xml java xml"></div>
```xml
<int:converter ref="strToInt"/>

<bean id="strToInt" class="org.springframework.integration.util.Demo.StringToIntegerConverter"/>
```

아니면 `@Component` 어노테이션으로 마킹해 자동 스캔을 이용하고 있다면, `StringToIntegerConverter` 클래스에서 바로 등록해줄 수도 있다.

이 'converter' 요소를 파싱할 땐 `integrationConversionService` 빈이 아직 정의되지 않은 경우 `integrationConversionService` 빈을 생성한다. 이 컨버터를 등록해주면 datatype 채널에서 컨버터를 사용해 `String` 페이로드를 `Integer`로 변환하기 때문에 `send` 작업에 성공할 거다.

페이로드 타입 변환과 관련해서 자세한 내용은 [Payload Type Conversion](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/endpoint.html#payload-type-conversion)을 참고해라.

4.0 버전부터 `integrationConversionService`는 애플리케이션 컨텍스트 내에서 conversion service를 가져오는 `DefaultDatatypeChannelMessageConverter`가 실행한다. 사용하고 싶은 다른 변환 기술이 있다면 채널에 `message-converter` 속성을 명시하면 된다. 이 속성은 반드시 `MessageConverter` 구현체를 참조해야 한다. 컨버터 메소드 중에는 `fromMessage`만 사용한다. 컨버터는 이 메소드를 통해 메시지 헤더에 접근할 수 있다 (변환에 `content-type`같은 헤더의 정보가 필요한 상황도 있을 수 있다). 이 메소드는 변환을 마친 페이로드나 전체 `Message` 객체만 반환할 수 있다. 후자의 경우 컨버터에서 인바운드 메시지에 있는 모든 헤더를 복사했는지 주의해야 한다.

아니면 `MessageConverter` 타입 `<bean/>`을 `datatypeChannelMessageConverter`란 ID로 선언해도 된다. 이렇게 등록한 컨버터는 모든 `datatype` 채널에서 사용하게 된다.

#### `QueueChannel` Configuration

`QueueChannel`을 생성하려면 하위 요소 `<queue/>`를 사용해라. 채널의 용량은 다음과 같이 지정할 수 있다:

<div class="switch-language-wrapper java xml">
<span class="switch-language java">Java</span>
<span class="switch-language xml">XML</span>
</div>
<div class="language-only-for-java java xml"></div>
```java
@Bean
public PollableChannel queueChannel() {
    return new QueueChannel(25);
}
```
<div class="language-only-for-xml java xml"></div>
```xml
<int:channel id="queueChannel">
    <queue capacity="25"/>
</int:channel>
```

> 이 하위 요소 `<queue/>`에 'capacity' 속성 값을 제공하지 않으면 무한한<sup>unbounded</sup> 큐가 만들어진다. 메모리 고갈같은 문제를 만나지 않으려면 웬만하면 값을 명시해서 유한<sup>bounded</sup> 큐를 생성하는 게 좋다.

##### Persistent `QueueChannel` Configuration

`QueueChannel`은 메시지를 버퍼링하는 기능을 제공하지만 기본적으론 인 메모리에서만 동작하기 때문에, 시스템 오류가 발생하면 메시지가 손실될 가능성도 있다. `QueueChannel`을 전략 인터페이스 `MessageGroupStore`의 persistent 구현체와 함께 사용하면 이런 위험을 줄일 수 있다. `MessageGroupStore`와 `MessageStore`에 대한 자세한 내용은 [메시지 스토어](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/message-store.html#message-store)를 참고해라.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p><code class="highlighter-rouge">message-store</code> 속성을 사용할 때는 <code class="highlighter-rouge">capacity</code> 속성을 사용할 수 없다.</p>
</blockquote>

`QueueChannel`이 `Message`를 받으면 메시지 스토어에 메시지를 추가한다. `QueueChannel`에서 `Message`를 폴링해가면 메시지 스토어에서 메시지를 제거한다.

기본적으로 `QueueChannel`은 인 메모리 큐에 메시지를 저장기 때문에 앞에서도 언급했듯이 메시지가 손실될 수도 있다. 하지만 Spring Integration은 `JdbcChannelMessageStore`같은 영구<sup>persistent</sup> 저장소를 제공한다.

`QueueChannel` 류에 메시지 스토어를 설정할 땐 다음 예제와 같이 `message-store` 속성을 추가해주면 된다:

```xml
<int:channel id="dbBackedChannel">
    <int:queue message-store="channelStore"/>
</int:channel>

<bean id="channelStore" class="o.s.i.jdbc.store.JdbcChannelMessageStore">
    <property name="dataSource" ref="dataSource"/>
    <property name="channelMessageStoreQueryProvider" ref="queryProvider"/>
</bean>
```

(자바/코틀린 설정 옵션은 아래 있는 샘플 코드를 참고해라.)

Spring Integration JDBC 모듈은 많이 사용하는 데이터베이스를 위한 스키마 DDL<sup>Data Definition Language</sup>도 제공하고 있다. 이스키마들은 JDBC 모듈(`spring-integration-jdbc`)의 org.springframework.integration.jdbc.store.channel 패키지 안에 들어있다.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>여기서는 짚고 넘어가야 할 특징이 하나 있다. 트랜잭션을 지원하는 영구<sup>persistent</sup> 스토어에서 (ex. <code class="highlighter-rouge">JdbcChannelMessageStore</code>) poller에 트랜잭션이 설정돼 있다면, 스토어에서 제거된 메시지는 트랜잭션이 성공적으로 완료돼야만 영구적으로 제거될 수 있다. 반면 트랜잭션이 롤백되면 <code class="highlighter-rouge">Message</code>는 사라지지 않는다.</p>
</blockquote>


"NoSQL" 데이터 스토어와 관련된 스프링 프로젝트가 점점 늘어나면서, 다양한 메시지 스토어 구현체들을 사용할 수 있게 됐다. 가지고 있는 요구 사항에 맞는 인터페이스를 찾을 수 없다면 자체 `MessageGroupStore` 인터페이스 구현체를 제공하는 것도 가능하다.

4.0 버전부터는 가능하면 `QueueChannel` 인스턴스는 `ChannelMessageStore`를 사용하도록 설정하는 것을 권장한다. `ChannelMessageStore` 류는 보통 일반적인 메시지 스토어에 비해 이 용도에 맞게 최적화돼 있다. `ChannelMessageStore`가 `ChannelPriorityMessageStore`라면 우선순위 내에서 FIFO로 메시지를 수신한다. 우선 순위 개념은 메시지 저장소 구현체에 의해 결정된다. 예를 들어 아래 코드는 [MongoDB 채널 메시지 스토어](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/mongodb.html#mongodb-priority-channel-message-store)를 위한 자바 설정 코드다:

<div class="switch-language-wrapper java java-dsl kotlin-dsl">
<span class="switch-language java">Java</span>
<span class="switch-language java-dsl">Java DSL</span>
<span class="switch-language kotlin-dsl">Kotlin DSL</span>
</div>
<div class="language-only-for-java java java-dsl kotlin-dsl"></div>
```java
@Bean
public BasicMessageGroupStore mongoDbChannelMessageStore(MongoDbFactory mongoDbFactory) {
    MongoDbChannelMessageStore store = new MongoDbChannelMessageStore(mongoDbFactory);
    store.setPriorityEnabled(true);
    return store;
}

@Bean
public PollableChannel priorityQueue(BasicMessageGroupStore mongoDbChannelMessageStore) {
    return new PriorityChannel(new MessageGroupQueue(mongoDbChannelMessageStore, "priorityQueue"));
}
```
<div class="language-only-for-java-dsl java java-dsl kotlin-dsl"></div>
```java
@Bean
public IntegrationFlow priorityFlow(PriorityCapableChannelMessageStore mongoDbChannelMessageStore) {
    return IntegrationFlows.from((Channels c) ->
            c.priority("priorityChannel", mongoDbChannelMessageStore, "priorityGroup"))
            ....
            .get();
}
```
<div class="language-only-for-kotlin-dsl java java-dsl kotlin-dsl"></div>
```kotlin
@Bean
fun priorityFlow(mongoDbChannelMessageStore: PriorityCapableChannelMessageStore) =
    integrationFlow {
        channel { priority("priorityChannel", mongoDbChannelMessageStore, "priorityGroup") }
    }
```

> `MessageGroupQueue` 클래스에 주목해라. 이 클래스는 `MessageGroupStore`를 사용하는 `BlockingQueue` 구현체다.

하위 요소 `<int:queue>`의 `ref` 속성이나 전용 생성자를 이용해서도 `QueueChannel` 환경을 커스텀할 수 있다. 이 속성으로는 원하는 `java.util.Queue` 구현체에 대한 참조를 제공한다. 예를 들어 Hazelcast 분산 [`IQueue`](https://hazelcast.com/use-cases/imdg/imdg-messaging/)는 다음과 같이 설정할 수 있다:

```java
@Bean
public HazelcastInstance hazelcastInstance() {
    return Hazelcast.newHazelcastInstance(new Config()
                                           .setProperty("hazelcast.logging.type", "log4j"));
}

@Bean
public PollableChannel distributedQueue() {
    return new QueueChannel(hazelcastInstance()
                              .getQueue("springIntegrationQueue"));
}
```

#### `PublishSubscribeChannel` Configuration

`PublishSubscribeChannel`을 생성하려면 `<publish-subscribe-channel/>` 요소를 사용해라. 이 요소를 사용할 땐 다음과 같이 메시지 발행에 사용할 `task-executor`를 지정할 수도 있다 (아무것도 지정하지 않으면 sender의 스레드에서 발행한다):

<div class="switch-language-wrapper java xml">
<span class="switch-language java">Java</span>
<span class="switch-language xml">XML</span>
</div>
<div class="language-only-for-java java xml"></div>
```java
@Bean
public MessageChannel pubsubChannel() {
    return new PublishSubscribeChannel(someExecutor());
}
```
<div class="language-only-for-xml java xml"></div>
```xml
<int:publish-subscribe-channel id="pubsubChannel" task-executor="someExecutor"/>
```

`Executor`와 함께 `ErrorHandler`를 설정할 수도 있다. 기본적으로 `PublishSubscribeChannel`은 `MessagePublishingErrorHandler` 구현체를 사용해 `errorChannel` 헤더에 있는 `MessageChannel`이나 글로벌 `errorChannel` 인스턴스로 에러를 전송한다. `Executor`를 설정하지 않았다면 `ErrorHandler`는 무시되며, 호출자의 스레드에서 곧바로 예외가 발생한다.

`PublishSubscribeChannel` 다운스트림에 resequencer나 aggregator를 사용한다면, 채널의 'apply-sequence' 속성을 `true`로 설정하면 된다. 이 설정은 채널에서 메시지를 넘겨주기 전에 메세지 헤더 `sequence-size`, `sequence-number`와 correlation ID를 설정해야 한다는 뜻이다. 예를 들어 5명의 구독자가 있다면 `sequence-size`는 `5`로 설정되고, 메시지에 있는 `sequence-number` 헤더 값은  `1`에서 `5` 사이 값을 갖게 된다.

다음은 `apply-sequence` 헤더를 `true`로 설정하는 방법을 보여주는 예제다:

<div class="switch-language-wrapper java xml">
<span class="switch-language java">Java</span>
<span class="switch-language xml">XML</span>
</div>
<div class="language-only-for-java java xml"></div>
```java
@Bean
public MessageChannel pubsubChannel() {
    PublishSubscribeChannel channel = new PublishSubscribeChannel();
    channel.setApplySequence(true);
    return channel;
}
```
<div class="language-only-for-xml java xml"></div>
```xml
<int:publish-subscribe-channel id="pubsubChannel" apply-sequence="true"/>
```

> `apply-sequence` 값은 기본적으로 `false`이기 때문에, publish-subscribe 채널은 완전히 동일한 메시지 인스턴스를 여러 아웃바운드 채널에 전송할 수 있다. Spring Integration에선 페이로드와 헤더 참조 값에 불변성<sup>immutability</sup>을 지키고 있기 때문에, 이 플래그를 `true`로 설정하면 채널에선 페이로드 참조는 같지만 헤더 값들은 다른 새 `Message` 인스턴스를 생성한다.

5.4.3 버전부터는 구독자가 없을 때 채널에서 아무 처리 없이 메시지를 무시하는 것이 싫다면 `PublishSubscribeChannel`을 생성할 때 `BroadcastingDispatcher`에서 사용할 옵션 `requireSubscribers`를 설정하는 것도 가능하다. 이 옵션을 `true`로 설정했을 때 구독자가 없으면 `Dispatcher has no subscribers`라는 메시지를 가지고 있는 `MessageDispatchingException`이 발생한다.

#### `ExecutorChannel`

`ExecutorChannel`을 생성하려면 하위 요소 `<dispatcher>`와 함께 `task-executor` 속성을 추가해라. 이 속성으로는 컨텍스트 내에 있는 모든 `TaskExecutor`를 참조할 수 있다. 예를 들면 채널을 구독 중인 핸들러들에게 메시지를 발송하기 위한 스레드 풀을 구성할 수 있다. 앞에서도 언급했지만 이렇게 하면 sender와 receiver가 단일 스레드로 실행 컨텍스트를 공유하지 않기 때문에, 핸들러를 호출한다고 해도 활성 트랜잭션 컨텍스트를 공유하지 않는다 (즉, 핸들러가 `Exception`을 던질 수 있지만 `send` 호출은 이미 문제 없이 반환하고 난 이후다). 다음은 `dispatcher` 요소를 사용하면서 `task-executor` 속성에 executor를 지정하는 방법을 보여주는 예제다:

<div class="switch-language-wrapper java xml">
<span class="switch-language java">Java</span>
<span class="switch-language xml">XML</span>
</div>
<div class="language-only-for-java java xml"></div>
```java
@Bean
public MessageChannel executorChannel() {
    return new ExecutorChannel(someExecutor());
}
```
<div class="language-only-for-xml java xml"></div>
```xml
<int:channel id="executorChannel">
    <int:dispatcher task-executor="someExecutor"/>
</int:channel>
```

> 하위 요소 `<dispatcher/>`에서도 앞서 [`DirectChannel` 설정](#directchannel-configuration)에서 설명한 것처럼 `load-balancer`와 `failover` 옵션을 사용할 수 있다. 기본값도 동일하게 적용된다. 따라서 아래와 같이 이 속성들을 따로 지정해주지 않으면 채널에선 패일오버가 활성화되며, 라운드 로빈 로드 밸런싱 전략을 갖게된다.
>
> ```xml
> <int:channel id="executorChannelWithoutFailover">
>  <int:dispatcher task-executor="someExecutor" failover="false"/>
> </int:channel>
> ```

#### `PriorityChannel` Configuration

`PriorityChannel`을 생성하려면 아래 예제와 같이 하위 요소 `<priority-queue/>`를 사용해라:

<div class="switch-language-wrapper java xml">
<span class="switch-language java">Java</span>
<span class="switch-language xml">XML</span>
</div>
<div class="language-only-for-java java xml"></div>
```java
@Bean
public PollableChannel priorityChannel() {
    return new PriorityChannel(20);
}
```
<div class="language-only-for-xml java xml"></div>
```xml
<int:channel id="priorityChannel">
    <int:priority-queue capacity="20"/>
</int:channel>
```

이 채널은 기본적으로 메시지에 있는 `priority` 헤더를 참고한다. 하지만 그대신 커스텀 `Comparator` 참조를 제공할 수도 있다. 그 외에도 `PriorityChannel`는 (다른 유형들처럼) `datatype` 속성을 지원한다. `QueueChannel`과 마찬가지로 `capacity` 속성도 지원한다. 다음은 세 가지를 모두 사용하는 예제다:

<div class="switch-language-wrapper java xml">
<span class="switch-language java">Java</span>
<span class="switch-language xml">XML</span>
</div>
<div class="language-only-for-java java xml"></div>
```java
@Bean
public PollableChannel priorityChannel() {
    PriorityChannel channel = new PriorityChannel(20, widgetComparator());
    channel.setDatatypes(example.Widget.class);
    return channel;
}
```
<div class="language-only-for-xml java xml"></div>
```xml
<int:channel id="priorityChannel" datatype="example.Widget">
    <int:priority-queue comparator="widgetComparator"
                    capacity="10"/>
</int:channel>
```

4.0 버전부터 자식 요소 `priority-channel`은 `message-store` 옵션을 지원한다 (이런 경우엔 `comparator`와 `capacity`는 사용할 수 없다). 이때 메시지 스토어는 `PriorityCapableChannelMessageStore`여야 한다. 현재는 `Redis`, `JDBC`, `MongoDB`를 위한 `PriorityCapableChannelMessageStore` 구현체를 제공하고 있다. 자세한 내용은 [`QueueChannel` 설정](#queuechannel-configuration)과 [메시지 스토어](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/message-store.html#message-store)를 참고해라. 설정 샘플은 [Backing Message Channels](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/jdbc.html#jdbc-message-store-channels)를 확인해보면 된다.

#### `RendezvousChannel` Configuration

하위 요소 queue가 `<rendezvous-queue>`이면 `RendezvousChannel`이 생성된다. 앞에서 다룬 설정 옵션 외에 추가적인 옵션은 제공하지 않으며, 용량이 0인 direct handoff 큐를 사용하기 때문에 따로 용량을 설정할 수 없다. 다음은 `RendezvousChannel`을 선언하는 방법을 보여주는 예시다:

<div class="switch-language-wrapper java xml">
<span class="switch-language java">Java</span>
<span class="switch-language xml">XML</span>
</div>
<div class="language-only-for-java java xml"></div>
```java
@Bean
public PollableChannel rendezvousChannel() {
    return new RendezvousChannel();
}
```
<div class="language-only-for-xml java xml"></div>
```xml
<int:channel id="rendezvousChannel"/>
    <int:rendezvous-queue/>
</int:channel>
```

#### Scoped Channel Configuration

모든 채널은 다음 예제와 같이 `scope` 속성과 함께 설정할 수 있다:

```xml
<int:channel id="threadLocalChannel" scope="thread"/>
```

#### Channel Interceptor Configuration

메시지 채널에선 [채널 인터셉터](#613-channel-interceptors)에서 설명했던 인터셉터를 사용할 수도 있다. `<interceptors/>`는 `<channel/>`의 하위 요소에 추가하면 된다 (또는 구체적인 요소 타입 아래). 다음 예제와 같이 `ref` 속성을 통해 스프링이 관리하는 모든 `ChannelInterceptor` 인터페이스 구현 객체를 참조할 수 있다:

```xml
<int:channel id="exampleChannel">
    <int:interceptors>
        <ref bean="trafficMonitoringInterceptor"/>
    </int:interceptors>
</int:channel>
```

인터셉터에선 보통 여러 채널에서 재사용할 수 있는 공통 동작을 구현하기 때문에, 일반적으로 인터셉터 구현체는 별도로 떼어내서 정의해두는 게 좋다.

#### Global Channel Interceptor Configuration

채널 인터셉터를 이용하면 개개 채널에서 횡단 관심사<sup>cross-cutting behavior</sup>를 깔끔하고 간단명료하게 처리할 수 있다. 하지만 여러 가지 채널에 같은 동작을 적용해야 하는 경우, 각 채널마다 같은 인터셉터 셋을 설정하는 건 효율적인 방법이라고 볼 수 없다. Spring Integration은 반복되는 설정 없이 여러 채널에 인터셉터를 적용할 수 있는 글로벌 인터셉터를 제공한다. 아래 두 가지 예제를 생각해보자:

```xml
<int:channel-interceptor pattern="input*, thing2*, thing1, !cat*" order="3">
    <bean class="thing1.thing2SampleInterceptor"/>
</int:channel-interceptor>
```

```xml
<int:channel-interceptor ref="myInterceptor" pattern="input*, thing2*, thing1, !cat*" order="3"/>

<bean id="myInterceptor" class="thing1.thing2SampleInterceptor"/>
```

글로벌 인터셉터는 `<channel-interceptor/>` 요소를 이용해 정의할 수 있으며, `pattern` 속성으로 정의한 패턴 중 매칭되는 패턴이 있는 모든 채널에 적용된다. 위 예제에선 'thing1' 채널과, 'thing2' 혹은 'input'으로 시작하는 모든 채널에 글로벌 인터셉터가 적용되지만, 'thing3'로 시작하는 채널엔 적용되지 않는다 (5.0 버전부터).

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>패턴에 이런 구문을 추가하면 (가능성은 희박하지만) 발생할 수 있는 문제가 하나 있다. 이름이 <code class="highlighter-rouge">!thing1</code>이라는 빈이 있다고 해서 채널 인터셉터의 <code class="highlighter-rouge">pattern</code>에 <code class="highlighter-rouge">!thing1</code>이라는 패턴을 포함시켜도 이 빈은 매칭되지 않는다. 이 패턴은 이름이 <code class="highlighter-rouge">thing1</code>이 아닌 모든 빈에 매칭된다. 이럴 땐 <code class="highlighter-rouge">\</code>를 이용해 패턴 안에 있는 <code class="highlighter-rouge">!</code>를 이스케이프하면 된다. <code class="highlighter-rouge">\!thing1</code> 패턴은 이름이 <code class="highlighter-rouge">!thing1</code>인 빈에 매칭된다.</p>
</blockquote>


특정 채널에 인터셉터가 여러 개 있을 땐 order 속성을 이용해 인터셉터를 어떤 순서로 주입할지를 관리할 수 있다. 예를 들어 'inputChannel' 채널은 아래 예시와 같이 로컬에서 설정한 인터셉터를 가지고 있을 수도 있다 (아래 참고):

```xml
<int:channel id="inputChannel">
  <int:interceptors>
    <int:wire-tap channel="logger"/>
  </int:interceptors>
</int:channel>
```

"로컬에서 다른 인터셉터를 설정했거나 다른 글로벌 인터셉터 정의가 있을 땐 글로벌 인터셉터는 어떤 식으로 주입될까?" 예리한 질문이다. 현재는 인터셉터 실행 순서를 정의할 수 있는 간단한 메커니즘을 제공한다. `order` 속성에 양수를 사용하면 기존에 있는 인터셉터 이후에 주입을, 음수는 기존 인터셉터보다 먼저 주입됨을 보장한다. 따라서 앞에 있는 예시에선 글로벌 인터셉터가 로컬에서 설정한 'wire-tap' 인터셉터보다 나중에 주입된다 (`order`가 `0`보다 크기 때문에). `pattern`이 매칭되는 또 다른 글로벌 인터셉터가 있는 경우엔 두 인터셉터가 가지고 있는 `order` 속성 값을 비교해서 순서를 결정하게 된다. 기존 인터셉터보다 먼저 글로벌 인터셉터를 주입하려면 `order` 속성에 음수 값을 사용해라.

> `order`와 `pattern` 속성은 모두 선택 사항이다. `order`의 기본값은 0, `pattern`의 기본값은 '*'다 (모든 채널에 매칭).

#### Wire Tap

앞에서도 언급했지만, Spring Integration은 간단한 wire tap 인터셉터를 하나 제공한다. Wire tap은 `<interceptors/>` 요소 내에서 모든 채널에 설정할 수 있다. 이 인터셉터는 디버깅에 특히 유용하며, 아래 보이는 것처럼 Spring Integration의 로깅 채널 어댑터와 조합해서 사용할 수 있다:

```xml
<int:channel id="in">
    <int:interceptors>
        <int:wire-tap channel="logger"/>
    </int:interceptors>
</int:channel>

<int:logging-channel-adapter id="logger" level="DEBUG"/>
```

> 'logging-channel-adapter'는 SpEL 표현식으로 'payload'와 'headers' 변수를 나타낼 수 있는 'expression' 속성도 받을 수 있다. 아니면 전체 메시지의 `toString()` 값을 기록하고 싶다면 'log-full-message' 속성을 `true`를 지정하면 된다. 이 속성은 기본적으로 `false`이기 때문에 페이로드만 기록한다. `true`로 설정하면 페이로드 외에도 전체 헤더를 로깅할 수 있다. 그래도 가장 유연하게 활용할 수 있는 건 'expression' 옵션이긴 하다 (ex. `expression="payload.user.name"`).

wire tap이나 다른 비슷한 컴포넌트들([Message Publishing Configuration](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/message-publishing.html#message-publishing-config))에 대해 흔히 하는 오해 중 하나는 이런 컴포넌트들은 저절로 알아서 완전한 비동기로 동작할 거란 생각이다. 컴포넌트로서 wire tap은 기본적으로 비동기로 실행되지 않는다. Spring Integration은 그보단 비동기 설정을 메시지 채널이라는 하나의 수단으로 모아 통합하는 것에 집중한다. 메시지 플로우에서 어떤 부분을 동기 혹은 비동기로 만들어주는 건 그 플로우 안에 설정된 메시지 채널의 타입이다. 메시지 채널로 추상화했을 때 누릴 수 있는 혜택 중 하나이기도 하다. 스프링은 프레임워크를 시작할 때부터 항상 일급 객체<sup>first-class citizen</sup>로서 메시지 채널의 필요성과 가치를 강조해 왔다. 메시지 채널은 EIP 패턴을 내부적, 암묵적으로 실현하는 것만이 전부가 아니다. 메세지 채널은 엔드 유저에게 설정 가능한 컴포넌트로 완전히 노출된다. 따라서 wire tap 컴포넌트에서는 아래 있는 작업들만 수행해야 한다:

- 채널을 이용해<sup>tap</sup> (ex. `channelA`) 메시지 플로우 가로채기
- 각 메시지를 잡아내기
- 메시지를 다른 채널로 (ex. `channelB`) 전송하기

wire tap은 근본적으로 일종의 브리지<sup>bridge</sup> 패턴이라고 볼 수 있지만, 채널 정의 안에 캡슐화돼있다는 특징이 있다 (그렇기 때문에 플로우를 방해하지 않고 활성/비활성화하기 더 쉽다). 게다가 브리지와는 달리 기본적으로 또 다른 메시지 플로우로 갈래를 만든다<sup>fork</sup>. 이 플로우는 동기식으로 동작할까 아니면 비동기로 동작할까? 정답은 메시지 채널 'channelB'의 유형에 따라 다르다. 'channelB'는 direct 채널, pollable 채널, executor 채널일 수 있다. 마지막 두 개는 스레드 경계를 무너트려 이런 채널을 통한 통신을 비동기로 만들어준다. 채널을 구독 중인 핸들러로 메시지를 전달하는 일은 해당 채널로 메시지를 전송한 스레드와는 다른 스레드에서 일어나기 때문이다. wire-tap 플로우는 바로 이런 식으로 동기 또는 비동기로 동작하도록 결정된다. 덕분에 특정 코드 조각을 동기로 구현해야 하는지 비동기로 구현해야 하는지를 (thread-safe한 코드를 작성하는 것은 별개) 미리 걱정하지 않아도 된다. 프레임워크 내에 있는 다른 구성 요소들도 마찬가지이며 (메시지 publisher같은), 일관성과 간결함을 한 단계 끌어올릴 수 있다. 두 개의 코드 조각(즉, 컴포넌트 A와 컴포넌트 B)이 협업할 때 해당 동작을 동기 또는 비동기로 만드는 것은 실제로 메시지 채널을 통해 연결될 때다. 향후에 동기에서 비동기로 변경하고 싶을 수도 있으며, 메시지 채널을 이용하면 코드를 건드리지 않고도 즉시 변경할 수 있다.

wire tap에 관해 마지막으로 한 가지 더 기억해둬야 할 점은 위에서 설명한 이유로 기본적으론 비동기로 동작하지는 않지만서도, 일반적으로는 메시지를 가능한 한 빨리 전달하는 것이 바람직하다는 점이다. 따라서 wire tap의 아웃바운드 채널엔 비동기 채널을 사용하는 게 일반적이다. 하지만 디폴트로 비동기가 적용되진 않는다. 디폴트가 비동기였다면 트랜잭션 경계를 지키고 싶어도 그러지 못하게되는 케이스가 많을 거다. 감사<sup>auditing</sup> 목적으로 wire tap 패턴을 사용한다면 원래의 트랜잭션 내에서 감사 메시지가 전송되기를 바랄 수도 있다. 예시로, wire tap을 JMS 아웃바운드 채널 어댑터에 연결할 수 있다. 이렇게 하면 양측의 장점을 모두 취할 수 있다. 1) JMS 메시지 전송을 트랜잭션 내에서 진행할 수 있으며, 2) 그와 동시에 "fire-and-forget"으로 동작하기 때문에, 메인 메시지 플로우에서 눈에 띄는 지연은 일어나지 않게 된다.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>4.0 버전부터 인터셉터(<a href="https://docs.spring.io/autorepo/docs/spring-integration/current/api/org/springframework/integration/channel/interceptor/WireTap.html"><code class="highlighter-rouge">WireTap</code> 클래스</a>같은)가 채널을 참조할 때는 순환 참조를 피하는 게 중요해졌다. 인터셉터에선 참조 중인 채널은 가로채갈 대상 채널에서 제외시켜야 한다. 이때는 제외 로직을 직접 작성하는 것도 가능하고, 적당한 패턴을 사용해도 된다. <code class="highlighter-rouge">channel</code>을 참조하는 커스텀 <code class="highlighter-rouge">ChannelInterceptor</code>가 있다면 <code class="highlighter-rouge">VetoCapableInterceptor</code>를 구현하는 것을 검토해봐라. 이 인터페이스를 사용하면 프레임워크에서 인터셉터에 설정한 패턴을 기반으로 각각의 후보 채널을 가로채도 괜찮은지를 확인해본다. 인터셉터 메소드에서 건내받은 채널이 인터셉터에서 참조하는 채널이 아닌지를 런타임에 확인할 수도 있다. <code class="highlighter-rouge">WireTap</code>은 이 두 가지 테크닉을 모두 사용한다.</p>
</blockquote>


4.3 버전부터 `WireTap`에는 `MessageChannel` 인스턴스 대신 `channelName`을 받는 별도 생성자가 하나 더 생겼다. 이 생성자는 자바 설정을 이용할 때와 채널 자동 생성 로직 사용할 때 편리할 거다. 실제 타겟 `MessageChannel` 빈은 이후 인터셉터가 처음으로 동작할 때 지정한 `channelName`을 통해 리졸브된다.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>채널을 리졸브할 땐 <code class="highlighter-rouge">BeanFactory</code>가 필요하기 때문에, wire tap 인스턴스는 반드시 스프링이 관리하는 빈이어야 한다.</p>
</blockquote>

전형적인 wire-tapping 패턴은 다음 예제와 같이 자바 DSL 설정을 이용해 late-binding 방식으로 단순화할 수도 있다:

```java
@Bean
public PollableChannel myChannel() {
    return MessageChannels.queue()
            .wireTap("loggingFlow.input")
            .get();
}

@Bean
public IntegrationFlow loggingFlow() {
    return f -> f.log();
}
```

#### Conditional Wire Taps

Wire tap은 `selector`나 `selector-expression` 속성을 이용하면 조건부로 만들 수 있다. `selector`는 `MessageSelector` 빈을 참조하는데, 이 빈은 메시지를 탭 채널로 보내야 하는지를 런타임에 결정할 수 있다. `selector-expression`도 마찬가지로 같은 일을 수행하는 boolean SpEL 표현식이다. 표현식이 `true`로 평가되면 메시지를 탭 채널로 전송한다.

#### Global Wire Tap Configuration

[글로벌 채널 인터셉터 설정](#global-channel-interceptor-configuration)의 특별한 케이스로, 글로벌 wire tap을 설정하는 것도 가능하다. 이땐 최상위 `wire-tap` 요소를 설정해야 한다. 이제 일반 `wire-tap` 네임스페이스를 지원하는 것 외에도 `pattern`과 `order` 속성을 지원하며, `channel-interceptor`에서 사용했을 때와 정확히 동일한 방식으로 동작한다. 다음은 글로벌 wire tap을 구성하는 방법을 보여주는 예시다:

<div class="switch-language-wrapper java xml">
<span class="switch-language java">Java</span>
<span class="switch-language xml">XML</span>
</div>
<div class="language-only-for-java java xml"></div>
```java
@Bean
@GlobalChannelInterceptor(patterns = "input*,thing2*,thing1", order = 3)
public WireTap wireTap(MessageChannel wiretapChannel) {
    return new WireTap(wiretapChannel);
}
```
<div class="language-only-for-xml java xml"></div>
```xml
<int:wire-tap pattern="input*, thing2*, thing1" order="3" channel="wiretapChannel"/>
```

> 글로벌 wire tap을 이용하면 기존 채널 수정은 없이 간단히 외부에 하나의 채널을 위한 wire tap을 설정할 수 있다. 그러려면 `pattern` 속성을 타겟 채널 이름으로 설정하면 된다. 이 테크닉을 이용하면 예를 들어 채널에 있는 메시지를 검증하기 위한 테스트 케이스를 구성할 수 있다.

### 6.1.6. Special Channels

`errorChannel`과 `nullChannel`이라는 두 특별한 채널은 애플리케이션 컨텍스트 안에 디폴트로 정의된다. 'nullChannel'(`NullChannel`의 인스턴스)은 마치 `/dev/null`처럼 동작하며, 전달받은 모든 메시지를 `DEBUG` 레벨로 기록한 뒤 곧바로 반환한다. 페이로드가 `org.reactivestreams.Publisher`인 메세지를 받으면 특별한 처리를 하나 진행한다. 데이터는 버리더라도 리액티브 스트림 처리를 시작할 수 있도록 이 채널 안에서 `Publisher`를 즉시 구독한다. 리액티브 스트림 처리 중에 던져진 에러는 (`Subscriber.onError(Throwable)` 참고) 이후 살펴볼 수 있도록 warn 레벨로 기록한다. 이런 에러가 발생했을 때 어떠한 조치를 취해야 하는 경우엔 이 `nullChannel`에 대한 `Mono` 응답을 생성하는 메시지 핸들러에 [`ReactiveRequestHandlerAdvice`](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/handler-advice.html#reactive-advice)를 적용해 `Mono.doOnError()`를 커스텀하면 된다. 크게 상관 없는 응답에서 채널 resolution 에러가 발생한다면, 관련 구성 요소의 `output-channel` 속성을 'nullChannel'로 설정하면 된다 ('nullChannel'이란 이름은 애플리케이션 컨텍스트 내에서 예약돼있다).

'errorChannel'은 내부적으로 에러 메시지를 전송하는 데 사용되며, 커스텀 설정을 통해 재정의할 수도 있다. 이 채널은 [에러 핸들링](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/error-handling.html#error-handling)에서 자세히 논한다.

메시지 채널 및 인터셉터에 대한 자세한 내용은 자바 DSL 챕터에 있는 [메시지 채널](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/dsl.html#java-dsl-channels)을 함께 참고해라.

---

## 6.2. Poller

이번 섹션에선 Spring Integration에서 폴링이 어떤 식으로 일어나는지를 설명한다.

### 6.2.1. Polling Consumer

메시지 엔드포인트(채널 어댑터)가 채널에 연결되고 인스턴스화될 땐 아래 중 하나의 인스턴스가 만들어진다:

- [`PollingConsumer`](https://docs.spring.io/spring-integration/api/org/springframework/integration/endpoint/PollingConsumer.html)
- [`EventDrivenConsumer`](https://docs.spring.io/spring-integration/api/org/springframework/integration/endpoint/EventDrivenConsumer.html)

실제 구현체는 이 엔드포인트에 연결되는 채널의 유형에 따라 다르다.  [`org.springframework.messaging.SubscribableChannel`](https://docs.spring.io/spring/docs/current/javadoc-api/index.html?org/springframework/messaging/SubscribableChannel.html) 인터페이스를 구현한 채널에 연결된 채널 어댑터는 `EventDrivenConsumer` 인스턴스를 생성한다. 반면 [`org.springframework.messaging.PollableChannel`](https://docs.spring.io/spring/docs/current/javadoc-api/index.html?org/springframework/messaging/PollableChannel.html) 인터페이스를 구현한 채널(ex. `QueueChannel`)에 연결된 채널 어댑터는 `PollingConsumer`의 인스턴스를 생성한다.

폴링 컨슈머는 Spring Integration 구성 요소들이 이벤트를 기반으로 메시지를 처리하기보단, 메시지를 능동적으로 폴링할 수 있게 만들어준다.

폴링 컨슈머는 수많은 메시지 처리 시나리오에서 꼭 필요한 횡단 관심사<sup>cross-cutting concern</sup>를 대변한다. Spring Integration에서 폴링 컨슈머는 Gregor Hohpe와 Bobby Woolf의 서적 *Enterprise Integration Patterns*에서 설명하는 같은 이름의 패턴을 기반으로 만들어졌다. 이 패턴에 대한 설명은 [서적의 전용 웹사이트](https://www.enterpriseintegrationpatterns.com/PollingConsumer.html)에서 확인해볼 수 있다.

### 6.2.2. Pollable Message Source

Spring Integration은 또 다른 폴링 컨슈머 패턴을 하나 더 제공한다. 인바운드 채널 어댑터를 사용할 때 이런 어댑터들은 `SourcePollingChannelAdapter`로 감싸는 경우가 많다. 예를 들어, 원격 FTP 서버에서 메시지를 조회할 땐 [FTP 인바운드 채널 어댑터](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/ftp.html#ftp-inbound)에서 설명하는 어댑터는 주기적으로 메시지를 조회할 수 있도록 poller를 함께 설정한다. 이렇게 구성 요소에 poller를 함께 설정하게 되면 만들어지는 인스턴스들은 아래 타입 중 하나다:

- [`PollingConsumer`](https://docs.spring.io/spring-integration/api/org/springframework/integration/endpoint/PollingConsumer.html)
- [`SourcePollingChannelAdapter`](https://docs.spring.io/spring-integration/api/org/springframework/integration/endpoint/SourcePollingChannelAdapter.html)

즉, poller는 인바운드와 아웃바운드 메시지 처리에 모두 사용할 수 있다. 다음은 poller를 이용하는 몇 가지 유스 케이스들이다:

- FTP 서버, 데이터베이스, 웹 서비스같은 특정 외부 시스템을 폴링
- 내부 (pollable) 메시지 채널 폴링
- 내부 서비스 폴링 (자바 클래스에 있는 메소드를 반복해서 실행하는 등)

> 트랜잭션을 시작하기 위한 트랜잭션 어드바이스같이, `advice-chain` 안에 있는 AOP 어드바이스 클래스들은 poller에도 적용할 수 있다. 4.1 버전부터는 `PollSkipAdvice`라는 것을 제공한다. poller는 트리거를 사용해 다음 폴링 시간을 결정하는데, `PollSkipAdvice`는 이 폴링을 억제(skip)하는 데 활용할 수 있다. 보통은 다운스트림에서 메시지를 처리하기 어려운 상황에서 사용한다. 이 어드바이스를 사용하려면 `PollSkipStrategy` 구현체를 하나 제공해야 한다. 4.2.5 버전부터는 `SimplePollSkipStrategy`라는 구현체를 제공한다. 이 구현체를 사용하려면 해당 인스턴스를 애플리케이션 컨텍스트에 빈으로 추가하고, `PollSkipAdvice`에 주입한 뒤, 이 어드바이스를 poller의 어드바이스 체인에 추가해주면 된다. 폴링을 건너뛰려면 `skipPolls()`를 호출하고, 폴링을 재개할 땐 `reset()`을 호출해라. 4.2 버전에선 관련 기능이 훨씬 더 유연해졌다. [메시지 소스를 위한 조건부 poller](#624-conditional-pollers-for-message-sources)를 참고해라.

이번 챕터의 목적은 폴링 컨슈머를 개괄적으로 알아보고, 이 폴링 컨슈머가 어떻게 [메시지 채널](#61-message-channels)과 [채널 어댑터](#63-channel-adapter)라는 개념과 어우러지는지를 설명하는 것이었다. 폴링 컨슈머와 함께 메시징 엔드포인트에 대한 전반적인 내용을 알아보고 싶다면 [메시지 엔드포인트](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/endpoint.html#endpoint)를 읽어봐라.

### 6.2.3. Deferred Acknowledgment Pollable Message Source

5.0.1 버전부터 일부 모듈에서 다운스트림 플로우가 완료될 때까지 (또는 메시지를 다른 스레드로 넘길 때까지) 승인<sup>acknowledgment</sup>을 연기할 수 있는 `MessageSource` 구현체를 제공한다. 현 시점엔 `AmqpMessageSource`와 `KafkaMessageSource`만 제공하고 있다.

이런 메시지 소스를 사용하면 메시지에 `IntegrationMessageHeaderAccessor.ACKNOWLEDGMENT_CALLBACK` 헤더가 추가된다 ([`MessageHeaderAccessor` API](../message/#721-messageheaderaccessor-api) 참고). pollable 메시지 소스와 함께 사용할 때는 이 헤더에 아래 보이는 `AcknowledgementCallback` 인스턴스가 담긴다:

```java
@FunctionalInterface
public interface AcknowledgmentCallback {

    void acknowledge(Status status);

    boolean isAcknowledged();

    void noAutoAck();

    default boolean isAutoAck();

    enum Status {

        /**
         * Mark the message as accepted.
         */
        ACCEPT,

        /**
         * Mark the message as rejected.
         */
        REJECT,

        /**
         * Reject the message and requeue so that it will be redelivered.
         */
        REQUEUE

    }

}
```

모든 메시지 소스가 `REJECT` 상태를 지원하는 건 아니다. 예를 들어 `KafkaMessageSource`에선 `REJECT`를 `ACCEPT`와 동일하게 취급하고 있다.

애플리케이션에선 다음 예제와 같이 언제든지 메시지를 승인<sup>acknowledge</sup>할 수 있다:

```java
Message<?> received = source.receive();

...

StaticMessageHeaderAccessor.getAcknowledgmentCallback(received)
        .acknowledge(Status.ACCEPT);
```

`MessageSource`가 `SourcePollingChannelAdapter`에 연결되었다면, 다운스트림 플로우가 완료되고 나서 poller 스레드가 어댑터로 반환됐을 때, 어댑터는 해당 `ackCallback`이 이미 승인<sup>acknowledgment</sup>되었는지 확인한 뒤, 아직 승인 전이라면 상태를 `ACCEPT`로 설정한다 (혹은 플로우에서 예외를 던졌다면 `REJECT`로 설정한다). 이 상태 값들은 [`AcknowledgementCallback.Status` Enum](https://docs.spring.io/spring-integration/api/org/springframework/integration/acks/AcknowledgmentCallback.Status.html)에 정의돼 있다.

Spring Integration은 `MessageSource`를 애드혹으로 폴링할 수 있도록 `MessageSourcePollingTemplate`을 제공한다. 이 클래스 역시 `MessageHandler` 콜백이 반환됐을 때 (또는 예외가 던져졌을 때) `AcknowledgementCallback`에 `ACCEPT` 또는 `REJECT`를 설정하는 일을 담당한다. 다음은 `MessageSourcePollingTemplate`을 이용해 메시지를 폴링하는 법을 보여주는 예시다:

```java
MessageSourcePollingTemplate template =
    new MessageSourcePollingTemplate(this.source);
template.poll(h -> {
    ...
});
```

두 케이스 모두 (`SourcePollingChannelAdapter`, `MessageSourcePollingTemplate`) 콜백에서 `noAutoAck()`를 호출하면 자동 ack/nack를 비활성화할 수 있다. 메시지를 다른 스레드로 전달해서 나중에 승인<sup>acknowledge</sup>하려는 경우 비활성화할 수 있다. 모든 구현체가 이 기능을 지원하는 것은 아니다 (예를 들면 아파치 카프카는 오프셋 커밋을 동일한 스레드에서 수행해야 하기 때문에 지원하지 않는다).

### 6.2.4. Conditional Pollers for Message Sources

이번 섹션에선 조건부<sup>conditional</sup> poller를 사용하는 방법에 대해 다룬다.

#### Background

poller의 `advice-chain` 안에 있는 `Advice` 객체들은 폴링 태스크 전체에 관여한다 (메시지 조회와 처리 모두). 이런 “around advice” 메소드들은 폴링 자체에만 액세스할 수 있을 뿐, 관련 컨텍스트엔 접근할 수 없다. 트랜잭션 안에서 태스크를 실행하거나, 앞에서 언급한 것처럼 어떠한 외부 조건에 따라 폴링을 건너뛰는 등의 요구 사항에서는 아무런 문제 없다. 하지만 poll의 `receive` 파트 결과에 따라 어떤 조치를 취하고 싶거나, 조건에 따라 그때그때 poller를 조정하려면 어떻게 해야 할까? Spring Integration은 이럴 때 활용할 수 있는 "스마트" 폴링을 제공한다.

#### “Smart” Polling

5.3 버전에선 `ReceiveMessageAdvice`라는 인터페이스를 도입했다. (`AbstractMessageSourceAdvice`는 `MessageSourceMutator`의 `default` 메소드들이 있기 때문에 deprecated됐다.) `advice-chain`에 있는 `Advice` 객체 중 이 인터페이스를 구현하는 모든 어드바이스는 receive 동작에만 적용된다 (`MessageSource.receive()`, `PollableChannel.receive(timeout)`). 따라서 이 어드바이스는 `SourcePollingChannelAdapter`나 `PollingConsumer`에만 적용할 수 있다. 이런 클래스들은 다음 메소드를 구현하고 있다:

- `beforeReceive(Object source)`: 이 메소드는 `Object.receive()` 메소드보다 먼저 호출된다. 그렇기 때문에 여기서는 소스를 검사하고 재설정할 수 있다. `false`를 반환하면 해당 폴링을 취소한다 (앞에서 언급한 `PollSkipAdvice`와 유사하다).
- `Message<?> afterReceive(Message<?> result, Object source)`: 이 메소드는 `receive()` 메소드 이후에 호출된다. 여기서도 소스를 재설정하거나 원하는 조치를 취할 수 있다 (대부분 이 result에 따라 조치를 취할텐데, result는 소스에서 생성한 메시지가 없으면 `null`이 될 수도 있다). 여기서는 심지어 다른 메시지를 반환하는 것도 가능하다.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p><strong>Thread safety</strong></p>
  <p>어드바이스가 무언가를 변경한다면 poller에 <code class="highlighter-rouge">TaskExecutor</code>를 함께 설정해선 안 된다. 어드바이스가 소스를 변경하는 것은 스레드로부터 안전하지 않으며, 특히 폴링 주기가 잦은 poller에선 예기치 않은 결과를 초래할 수 있다. 폴링 결과를 동시에 처리해야 하는 경우 poller에 executor를 추가하는 대신 다운스트림에 <code class="highlighter-rouge">ExecutorChannel</code>을 두는 것을 고려해봐라.</p>
</blockquote>

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p><strong>Advice Chain Ordering</strong></p>
  <p>어드바이스 체인이 어떤 식으로 초기화되는지를 이해하고 있어야 한다. <code class="highlighter-rouge">ReceiveMessageAdvice</code>를 구현하지 않은 <code class="highlighter-rouge">Advice</code> 객체들은 폴링 프로세스 전체에 적용되며, <code class="highlighter-rouge">ReceiveMessageAdvice</code>보다 먼저 순차적으로 호출된다. <code class="highlighter-rouge">ReceiveMessageAdvice</code> 객체들은 그다음에 소스 <code class="highlighter-rouge">receive()</code> 메소드 앞뒤에서 순서대로 호출된다. 예를 들어 <code class="highlighter-rouge">Advice</code> 객체 <code class="highlighter-rouge">a, b, c, d</code>가 있고, 여기서 <code class="highlighter-rouge">b</code>와 <code class="highlighter-rouge">d</code>는 <code class="highlighter-rouge">ReceiveMessageAdvice</code>라면, 이 객체들은 <code class="highlighter-rouge">a, c, b, d</code> 순으로 적용된다. 추가로, 소스가 이미 <code class="highlighter-rouge">Proxy</code>라면, 기존에 있는 <code class="highlighter-rouge">Advice</code> 객체들을 호출한 이후에 <code class="highlighter-rouge">ReceiveMessageAdvice</code>가 호출된다. 이 순서를 변경하고 싶으면 직접 프록시를 연결해야 한다.</p>
</blockquote>


#### `SimpleActiveIdleReceiveMessageAdvice`

(이전에 `MessageSource` 전용으로 사용했던 `SimpleActiveIdleMessageSourceAdvice`는 deprecated되었다.) 이 어드바이스는 `ReceiveMessageAdvice`의 간단한 구현체다. `DynamicPeriodicTrigger`와 함께 조합해서 쓰면 이전 폴링에서 메시지를 생성했는지 여부에 따라 폴링 주기를 조정할수 있다. 단, poller에서도 반드시 같은 `DynamicPeriodicTrigger`를 참조해야 한다.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p><strong>Important: Async Handoff</strong></p>
  <p><code class="highlighter-rouge">SimpleActiveIdleReceiveMessageAdvice</code>는 <code class="highlighter-rouge">receive()</code> 결과를 기반으로 트리거를 수정한다. 하지만 이는 어드바이스가 poller 스레드에서 호출되는 경우에만 반영된다. poller에 <code class="highlighter-rouge">task-executor</code>가 설정돼 있으면 동작하지 않는다. 폴링 결과를 가져온 후에 비동기 연산을 실행하는 곳에서 이 어드바이스를 사용하고 싶다면, 비동기 연산은 <code class="highlighter-rouge">ExecutorChannel</code> 등을 이용해 나중으로 넘겨라.</p>
</blockquote>

#### `CompoundTriggerAdvice`

이 어드바이스를 사용하면 폴링으로 메시지를 반환했는지에 따라 두 가지 트리거 중 하나를 선택할 수 있다. `CronTrigger`를 사용하는 poller를 생각해보자. `CronTrigger` 인스턴스는 불변<sup>immutable</sup> 객체이기 때문에 일단 생성하고 나면 변경이 불가능하다. cron 표현식을 이용해 매시간 한 번씩 폴링을 트리거하되, 메시지를 받지 못하면 일 분에 한 번 폴링하고, 메시지가 조회되면 다시 이전 cron 표현식으로 되돌아가는 유스케이스를 생각해보자.

이 어드바이스(그리고 poller)는 이런 목적으로 `CompoundTrigger`를 사용한다. `CompoundTrigger`의 `primary` 트리거에 `CronTrigger`를 사용하면 된다. 어드바이스에서 메시지를 수신하지 못했음을 감지하면 `CompoundTrigger`에 secondary 트리거를 추가한다. `CompoundTrigger` 인스턴스의 `nextExecutionTime` 메소드가 실행되면 secondary 트리거(있으면)에 위임하게 된다. 그 외엔 primary 트리거에 위임한다.

poller에서도 반드시 같은 `CompoundTrigger`를 참조해야 한다.

다음 예시는 hourly cron 표현식을 사용하고 1분 간격으로 폴백하는 설정을 보여준다:

```xml
<int:inbound-channel-adapter channel="nullChannel" auto-startup="false">
    <bean class="org.springframework.integration.endpoint.PollerAdviceTests.Source" />
    <int:poller trigger="compoundTrigger">
        <int:advice-chain>
            <bean class="org.springframework.integration.aop.CompoundTriggerAdvice">
                <constructor-arg ref="compoundTrigger"/>
                <constructor-arg ref="secondary"/>
            </bean>
        </int:advice-chain>
    </int:poller>
</int:inbound-channel-adapter>

<bean id="compoundTrigger" class="org.springframework.integration.util.CompoundTrigger">
    <constructor-arg ref="primary" />
</bean>

<bean id="primary" class="org.springframework.scheduling.support.CronTrigger">
    <constructor-arg value="0 0 * * * *" /> <!-- top of every hour -->
</bean>

<bean id="secondary" class="org.springframework.scheduling.support.PeriodicTrigger">
    <constructor-arg value="60000" />
</bean>
```

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p><strong>Important: Async Handoff</strong></p>
  <p><code class="highlighter-rouge">CompoundTriggerAdvice</code>는 <code class="highlighter-rouge">receive()</code> 결과를 기반으로 트리거를 수정한다. 하지만 이는 어드바이스가 poller 스레드에서 호출되는 경우에만 반영된다. poller에 <code class="highlighter-rouge">task-executor</code>가 설정돼 있으면 동작하지 않는다. 폴링 결과를 가져온 후에 비동기 연산을 실행하는 곳에서 이 어드바이스를 사용하고 싶다면, 비동기 연산은 <code class="highlighter-rouge">ExecutorChannel</code> 등을 이용해 나중으로 넘겨라.</p>
</blockquote>

#### MessageSource-only Advices

어드바이스 중엔 `MessageSource.receive()`에만 적용되는 어드바이스가 있는데, 이런 어드바이스는 `PollableChannel`에선 의미가 없다. 이럴 때 사용할 수 있는 `MessageSourceMutator` 인터페이스가 여전히 남아있다 (`ReceiveMessageAdvice`를 상속한 인터페이스). 여기 있는 `default` 메소드들을 사용하면 이미 deprecated된 `AbstractMessageSourceAdvice`를 완전히 대체할 수 있으며, `MessageSource`에만 프록시 처리를 적용하는 곳에서 사용해야 한다. 자세한 내용은 [인바운드 채널 어댑터: 멀티 서버 및 멀티 디렉토리 폴링하기](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/ftp.html#ftp-rotating-server-advice)를 참고해라.

---

## 6.3. Channel Adapter

채널 어댑터는 sender나 receiver 하나를 메시지 채널에 연결시켜주는 메시지 엔드포인트다. Spring Integration은 JMS, 파일, HTTP, 웹 서비스, 메일 등과 같은 다양한 전송 방식을 지원하는 수많은 어댑터를 제공한다. 각 어댑터들은 이후 별도 챕터에서 설명한다. 이 챕터에선 메소드를 실행해주는 채널 어댑터의 간단하면서 동시에 유연한 기능에 집중한다. 인바운드 어댑터와 아웃바운드 어댑터가 둘 다 존재하며, 각각은 코어 네임스페이스에서 제공하는 XML 요소로 설정할 수 있다. 소스나 목적지로 호출할 수 있는 메소드만 있다면 어댑터를 이용해 Spring Integration을 쉽게 확장할 수 있다.

### 6.3.1. Configuring An Inbound Channel Adapter

`inbound-channel-adapter` 요소(자바 설정에선 `SourcePollingChannelAdapter`)는 스프링이 관리하는 객체에 있는 모든 메소드를 호출할 수 있으며, 메소드의 출력을 `Message`로 변환한 후 null이 아닌 반환 값만 `MessageChannel`로 전송할 수 있다. 이 어댑터에서 구독이 일어나면 poller가 소스로부터 메시지 수신을 시도해본다. 이때 poller는 제공한 설정에 따라 `TaskScheduler`로 예약된다. 채널 어댑터에 폴링 간격이나 cron 표현식을 개별적으로 설정하려면 'poller' 요소를 'fixed-rate' 또는 'cron'과 같은 스케줄링 속성 중 하나와 함께 제공하면 된다. 아래 예제에선 두 가지 `inbound-channel-adapter` 인스턴스를 정의하고 있다:

<div class="switch-language-wrapper java-dsl java kotlin-dsl xml">
<span class="switch-language java-dsl">Java DSL</span>
<span class="switch-language java">Java</span>
<span class="switch-language kotlin-dsl">Kotlin DSL</span>
<span class="switch-language xml">XML</span>
</div>
<div class="language-only-for-java-dsl java-dsl java kotlin-dsl xml"></div>
```java
@Bean
public IntegrationFlow source1() {
    return IntegrationFlows.from(() -> new GenericMessage<>(...),
                             e -> e.poller(p -> p.fixedRate(5000)))
                ...
                .get();
}

@Bean
public IntegrationFlow source2() {
    return IntegrationFlows.from(() -> new GenericMessage<>(...),
                             e -> e.poller(p -> p.cron("30 * 9-17 * * MON-FRI")))
                ...
                .get();
}
```
<div class="language-only-for-java java-dsl java kotlin-dsl xml"></div>
```java
public class SourceService {

    @InboundChannelAdapter(channel = "channel1", poller = @Poller(fixedRate = "5000"))
    Object method1() {
        ...
    }

    @InboundChannelAdapter(channel = "channel2", poller = @Poller(cron = "30 * 9-17 * * MON-FRI"))
    Object method2() {
        ...
    }
}
```
<div class="language-only-for-kotlin-dsl java-dsl java kotlin-dsl xml"></div>
```kotlin
@Bean
fun messageSourceFlow() =
    integrationFlow( { GenericMessage<>(...) },
                    { poller { it.fixedRate(5000) } }) {
        ...
    }
```
<div class="language-only-for-xml java-dsl java kotlin-dsl xml"></div>
```xml
<int:inbound-channel-adapter ref="source1" method="method1" channel="channel1">
    <int:poller fixed-rate="5000"/>
</int:inbound-channel-adapter>

<int:inbound-channel-adapter ref="source2" method="method2" channel="channel2">
<int:poller cron="30 * 9-17 * * MON-FRI"/>
</int:channel-adapter>
```

[채널 어댑터 표현식과 스크립트](#633-channel-adapter-expressions-and-scripts)도 함께 읽어봐라.

> poller를 지정하지 않았다면, 컨텍스트에 반드시 디폴트 poller가 딱 하나 등록돼 있어야 한다. 자세한 내용은 [엔드포인트 네임스페이스 지원](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/endpoint.html#endpoint-namespace)을 참고해라.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p><strong>Important: Poller Configuration</strong></p>
  <p><code class="highlighter-rouge">inbound-channel-adapter</code> 타입은 전부 <code class="highlighter-rouge">SourcePollingChannelAdapter</code>로 지원한다. 그렇기 때문에 이 타입들은 <code class="highlighter-rouge">MessageSource</code>를 폴링하는 poller 설정을 가지고 있다. 이 설정은 poller 안에 지정하며, 이를 통해 <code class="highlighter-rouge">Message</code> 페이로드가 될 값을 생산하는 커스텀 메소드를 호출한다. 다음은 두 가지 poller 설정을 보여주는 예시다:</p>
  <div class="language-xml highlighter-rouge"><div class="highlight"><pre class="highlight"><code><span class="nt">&lt;int:poller</span> <span class="na">max-messages-per-poll=</span><span class="s">"1"</span> <span class="na">fixed-rate=</span><span class="s">"1000"</span><span class="nt">/&gt;</span>


<span class="nt">&lt;int:poller</span> <span class="na">max-messages-per-poll=</span><span class="s">"10"</span> <span class="na">fixed-rate=</span><span class="s">"1000"</span><span class="nt">/&gt;</span>
</code></pre></div>  </div>

<p>첫 번째 설정에선 <code class="highlighter-rouge">max-messages-per-poll</code> 속성에 따라 폴링 한 번당 폴링 태스크를 한 번 실행하며, 각 태스크(폴링) 중에는 메소드(메시지를 생성하는)가 한 번 호출된다. 두 번째 설정에선 폴링 태스크는 폴링 한 번당 10번 또는 'null'을 반환할 때까지 호출된다. 따라서 1초 간격으로 일어나는 폴링 한 번당 최대 10개의 메시지를 생성할 수 있다. 하지만 설정이 다음과 같으면 어떻게 될까?</p>
  <div class="language-xml highlighter-rouge"><div class="highlight"><pre class="highlight"><code><span class="nt">&lt;int:poller</span> <span class="na">fixed-rate=</span><span class="s">"1000"</span><span class="nt">/&gt;</span>
</code></pre></div>  </div>
<p><code class="highlighter-rouge">max-messages-per-poll</code>을 지정하지 않은 것에 주목하자. 나중에 다루겠지만, <code class="highlighter-rouge">PollingConsumer</code>에선 (ex. <code class="highlighter-rouge">service-activator</code>, <code class="highlighter-rouge">filter</code>, <code class="highlighter-rouge">router</code> 등) 이와 동일한 poller 설정은 <code class="highlighter-rouge">max-messages-per-poll</code>에 <code class="highlighter-rouge">-1</code>이란 기본값을 가질 거다. 즉, "폴링 메소드가 null을 반환하기 전까진 폴링 태스크를 쉬지 않고 실행한다"는 것을 의미한다 (대부분 null은 <code class="highlighter-rouge">QueueChannel</code>에 더 이상 메시지가 없을 때 반환한다). null을 반환한 다음엔 1초 간 동작을 멈춘다<sup>sleep</sup>.</p>
  <p>하지만 <code class="highlighter-rouge">SourcePollingChannelAdapter</code>에선 약간 다르다. 직접 음수 값으로 명시하지 않았다면 (ex. <code class="highlighter-rouge">-1</code>) <code class="highlighter-rouge">max-messages-per-poll</code>의 기본값은 <code class="highlighter-rouge">1</code>이다. 덕분에 이때는 poller가 라이프사이클 이벤트(start, stop같은)에 반응할 수 있으며, <code class="highlighter-rouge">MessageSource</code> 메소드 구현부에서 null을 반환하지 않아 중단이 불가능해지고 결국 무한 루프에서 빠지게 되는 일을 방지할 수 있다.</p>
  <p>하지만 구현한 메소드가 null을 반환한다고 확신할 수 있고, 폴링할 때마다 가능한 많은 소스를 폴링해야 한다면, 다음 예제와 같이 <code class="highlighter-rouge">max-messages-per-poll</code>을 음수로 명시해야 한다.</p>

  <div class="language-xml highlighter-rouge"><div class="highlight"><pre class="highlight"><code><span class="nt">&lt;int:poller</span> <span class="na">max-messages-per-poll=</span><span class="s">"-1"</span> <span class="na">fixed-rate=</span><span class="s">"1000"</span><span class="nt">/&gt;</span>
</code></pre></div>  </div>
  <p>5.5 버전부터 <code class="highlighter-rouge">max-messages-per-poll</code>에서 <code class="highlighter-rouge">0</code>이란 값은 특별한 의미를 가진다. <code class="highlighter-rouge">0</code>은 <code class="highlighter-rouge">MessageSource.receive()</code> 호출을 완전히 건너뛰겠다는 뜻이다. 따라서 이 인바운드 채널 어댑터는 <code class="highlighter-rouge">maxMessagesPerPoll</code>이 이후 0이 아닌 값으로 변경되기 전까진 (ex. 컨트롤 버스를 통해) 일시 중지하는 것으로 간주할 수 있다.</p>
  <p>조금 더 자세히 알아보고 싶다면 <a href="https://docs.spring.io/spring-integration/docs/5.5.8/reference/html/endpoint.html#global-default-poller">글로벌 디폴트 Poller</a>도 함께 읽어봐라.</p>
</blockquote>

### 6.3.2. Configuring An Outbound Channel Adapter

`outbound-channel-adapter` 요소(자바 설정에선 `@ServiceActivator`) 역시 `MessageChannel`을, 채널로 전송된 메시지 페이로드를 이용해 실행해야 하는 모든 POJO 컨슈머 메소드에 연결할 수 있다. 다음은 아웃바운드 채널 어댑터를 정의하는 방법을 보여주는 예시다:

<div class="switch-language-wrapper java-dsl java kotlin-dsl xml">
<span class="switch-language java-dsl">Java DSL</span>
<span class="switch-language java">Java</span>
<span class="switch-language kotlin-dsl">Kotlin DSL</span>
<span class="switch-language xml">XML</span>
</div>
<div class="language-only-for-java-dsl java-dsl java kotlin-dsl xml"></div>
```java
@Bean
public IntegrationFlow outboundChannelAdapterFlow(MyPojo myPojo) {
    return f -> f
             .handle(myPojo, "handle");
}
```
<div class="language-only-for-java java-dsl java kotlin-dsl xml"></div>
```java
public class MyPojo {

    @ServiceActivator(channel = "channel1")
    void handle(Object payload) {
        ...
    }

}
```
<div class="language-only-for-kotlin-dsl java-dsl java kotlin-dsl xml"></div>
```kotlin
@Bean
fun outboundChannelAdapterFlow(myPojo: MyPojo) =
    integrationFlow {
        handle(myPojo, "handle")
    }
```
<div class="language-only-for-xml java-dsl java kotlin-dsl xml"></div>
```xml
<int:outbound-channel-adapter channel="channel1" ref="target" method="handle"/>

<beans:bean id="target" class="org.MyPojo"/>
```

어탭터를 적용하는 채널이 `PollableChannel`일 땐, 반드시 다음과 같이 하위 요소 poller를 제공해야 한다 (`@ServiceActivator`에선 하위 어노테이션 `@Poller`):

<div class="switch-language-wrapper java xml">
<span class="switch-language java">Java</span>
<span class="switch-language xml">XML</span>
</div>
<div class="language-only-for-java java xml"></div>
```java
public class MyPojo {

    @ServiceActivator(channel = "channel1", poller = @Poller(fixedRate = "3000"))
    void handle(Object payload) {
        ...
    }

}
```
<div class="language-only-for-xml java xml"></div>
```xml
<int:outbound-channel-adapter channel="channel2" ref="target" method="handle">
    <int:poller fixed-rate="3000" />
</int:outbound-channel-adapter>

<beans:bean id="target" class="org.MyPojo"/>
```

POJO 컨슈머 구현체를 다른 `<outbound-channel-adapter>` 정의에서도 사용할 수 있다면 `ref` 속성을 이용해야 한다. 하지만 컨슈머 구현체를 `<outbound-channel-adapter>` 정의 딱 하나에서만 참조한다면 다음 예제와 같이 내부 빈으로 정의해도 된다:

```xml
<int:outbound-channel-adapter channel="channel" method="handle">
    <beans:bean class="org.Foo"/>
</int:outbound-channel-adapter>
```

> `<outbound-channel-adapter>` 설정 하나에서 `ref` 속성과 내부 핸들러 정의를 둘 다 사용하게 되면 어정쩡한 상태에 놓이게 된다. 따라서 이런 설정은 허용하지 않으며, 정의하면 예외가 발생한다.

모든 채널 어댑터는 `channel` 참조 없이 생성할 수 있다. 이땐 암묵적으로 `DirectChannel` 인스턴스를 생성한다. 이렇게 생성된 채널의 이름에는 `<inbound-channel-adapter>` 혹은 `<outbound-channel-adapter>` 요소에 있는 `id` 속성을 사용한다. 따라서 `channel`을 제공하지 않는다면 `id`가 있어야 한다.

### 6.3.3. Channel Adapter Expressions and Scripts

`<inbound-channel-adapter>`와 `<outbound-channel-adapter>`도 다른 Spring Integration 구성 요소들처럼 SpEL 표현식을 지원한다. SpEL을 사용하려면 빈을 정의할 때 메소드 호출에 필요한 'ref', 'method' 속성 대신, 'expression' 속성을 이용해 표현식 문자열을 제공해라. 표현식을 평가할 때도 정의된 규약<sup>contract</sup>은 메소드를 실행할 때와 동일하다. `<inbound-channel-adapter>`의 표현식은 평가 결과가 null이 아닐 때마다 메시지를 생성하며, `<outbound-channel-adapter>`의 표현식은 반환 타입이 void인 메소드를 호출하는 것과 동등해야 한다.

Spring Integration 3.0부터 `<int:inbound-channel-adapter/>`는 하위 요소 SpEL `<expression/>`(또는 `<script/>`)으로도 설정할 수 있다. 이땐 단순 'expression' 속성을 사용할 때보다 더 정교한 설정이 필요하다. `location` 속성을 이용해 `Resource`로 스크립트를 제공하는 경우엔, `refresh-check-delay`를 설정해 리소스를 주기적으로 리프레시할 수도 있다. 폴링할 때마다 스크립트를 체크하고 싶다면, 다음 예제와 같이 poller의 트리거와 설정을 조율해줘야 한다.

```xml
<int:inbound-channel-adapter ref="source1" method="method1" channel="channel1">
    <int:poller max-messages-per-poll="1" fixed-delay="5000"/>
    <script:script lang="ruby" location="Foo.rb" refresh-check-delay="5000"/>
</int:inbound-channel-adapter>
```

하위 요소 `<expression/>`을 사용할 땐 `ReloadableResourceBundleExpressionSource`에 있는 프로퍼티 `cacheSeconds`도 함께 참고해라. 표현식에 대한 자세한 내용은 [SpEL<sup>Spring Expression Language</sup>](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/spel.html#spel)을 참고해라. 스크립트에 관해서는 [Groovy 지원](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/groovy.html#groovy)과 [스크립팅 지원](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/scripting.html#scripting)을 확인해봐라.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p><code class="highlighter-rouge">&lt;int:inbound-channel-adapter/&gt;</code>(<code class="highlighter-rouge">SourcePollingChannelAdapter</code>)는 어떠한 내부 <code class="highlighter-rouge">MessageSource</code> 폴링을 주기적으로 트리거해서 메시지 플로우를 시작하는 엔드포인트다. 폴링 시점에는 메시지 객체가 없기 때문에 표현식과 스크립트에선 루트 <code class="highlighter-rouge">Message</code>에 액세스할 수 없다. 따라서 다른 메시징 SpEL 표현식에선 대부분 사용할 수 있는 페이로드나 헤더 프로퍼티가 없다. 스크립트에선 헤더와 페이로드를 가지고 있는 완전한 <code class="highlighter-rouge">Message</code> 객체를 생성해 반환하거나, 페이로드만을 반환할 수 있다. 페이로드만 반환했을 땐 프레임워크가 기본적인 헤더들을 가지고 있는 메시지로 감싸준다.</p>
</blockquote>


---

## 6.4. Messaging Bridge

메시징 브리지는 두 개의 메시지 채널이나 채널 어댑터를 연결해주는 비교적 간단한 엔드포인트다. 예를 들어 `PollableChannel`을 `SubscribableChannel`에 연결해서 구독하는 엔드포인트에선 폴링 설정을 신경쓸 필요 없게 만들고 싶을 수도 있다. 폴링 설정은 메시징 브리지가 대신 제공한다.

메시징 브리지를 이용하면 두 채널 사이에 중간 poller를 제공해 인바운드 메시지를 스로틀링<sup>throttling</sup>할 수 있다. poller의 트리거로 두 번째 채널에 메시지가 도착하는 속도가 결정되며, poller의 `maxMessagesPerPoll` 프로퍼티는 처리량을 제한한다.

메시징 브리지는 서로 다른 두 개의 시스템을 연결하는 데에도 활용할 수 있다. 이때는 Spring Integration의 역할은 각 시스템들을 연결하고 필요한 경우 poller를 관리하는 것으로 한정된다. 두 시스템 사이에 트랜스포머를 최소 하나 둬서 각각의 포맷을 변환하는 구조를 더 많이 사용하긴 할 거다. 이 경우엔 채널들을 트랜스포머 엔드포인트의 'input-channel', 'output-channel'로 제공하면 된다. 사실 데이터 포맷 변환이 필요하지 않은 경우엔 메시징 브리지만으로 충분할 수 있다.

### 6.4.1. Configuring a Bridge with XML

두 개의 채널 또는 채널 어댑터 사이에 메시징 브리지를 생성하려면 `<bridge>` 요소를 이용하면 된다. 다음 예제와 같이 `input-channel`, `output-channel`  속성을 제공해라:

```xml
<int:bridge input-channel="input" output-channel="output"/>
```

메시징 브리지는 흔히 위에서 언급한대로 `PollableChannel`을 `SubscribableChannel`에 연결하는 식으로 활용하곤 한다. 이때는 메시징 브리지가 throttler 역할도 수행할 수 있다:

```xml
<int:bridge input-channel="pollable" output-channel="subscribable">
     <int:poller max-messages-per-poll="10" fixed-rate="5000"/>
</int:bridge>
```

비슷한 메커니즘으로 채널 어댑터들도 연결할 수 있다. 다음은 Spring Integration의 `stream` 네임스페이스에 있는 `stdin`과 `stdout` 어댑터 사이에 간단한 "echo"를 생성하는 예제다:

```xml
<int-stream:stdin-channel-adapter id="stdin"/>

<int-stream:stdout-channel-adapter id="stdout"/>

<int:bridge id="echo" input-channel="stdin" output-channel="stdout"/>
```

file-to-JMS나 mail-to-file같은 다른 채널 어댑터 브리지에도 이와 유사한 설정을 사용할 수 있다 (더 유용할 수도 있다). 다음 챕터에선 다양한 채널 어댑터들을 다뤄볼 예정이다.

> 브리지에 'output-channel'을 정의하지 않으면 인바운드 메시지에서 제공하는 reply channel을 사용한다 (있다면). output과  reply channel 모두 이용할 수 없다면 예외가 던져진다.

### 6.4.2. Configuring a Bridge with Java Configuration

다음은 `@BridgeFrom` 어노테이션을 이용해 자바에서 브리지를 설정하는 방법을 보여주는 예시다:

```java
@Bean
public PollableChannel polled() {
    return new QueueChannel();
}

@Bean
@BridgeFrom(value = "polled", poller = @Poller(fixedDelay = "5000", maxMessagesPerPoll = "10"))
public SubscribableChannel direct() {
    return new DirectChannel();
}
```

다음은 `@BridgeTo` 어노테이션을 이용해 자바에서 브리지를 설정하는 방법을 보여주는 예시다:

```java
@Bean
@BridgeTo(value = "direct", poller = @Poller(fixedDelay = "5000", maxMessagesPerPoll = "10"))
public PollableChannel polled() {
    return new QueueChannel();
}

@Bean
public SubscribableChannel direct() {
    return new DirectChannel();
}
```

아니면 아래 예제처럼 `BridgeHandler`를 이용해도 된다:

```java
@Bean
@ServiceActivator(inputChannel = "polled",
        poller = @Poller(fixedRate = "5000", maxMessagesPerPoll = "10"))
public BridgeHandler bridge() {
    BridgeHandler bridge = new BridgeHandler();
    bridge.setOutputChannelName("direct");
    return bridge;
}
```

### 6.4.3. Configuring a Bridge with the Java DSL

다음 예제와 같이 자바 DSL<sup>Domain Specific Language</sup>을 사용해 브리지를 구성할 수도 있다:

```java
@Bean
public IntegrationFlow bridgeFlow() {
    return IntegrationFlows.from("polled")
            .bridge(e -> e.poller(Pollers.fixedDelay(5000).maxMessagesPerPoll(10)))
            .channel("direct")
            .get();
}
```
