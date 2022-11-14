---
title: Reactive Streams Support
category: Spring Integration
order: 19
permalink: /Spring%20Integration/reactive-streams/
description: 리액티브 스트림즈 애프리케이션에 Spring Integration 적용하기
image: ./../../images/springintegration/logo.png
lastmod: 2022-10-21T13:30:00+09:00
comments: true
originalRefName: 스프링 인티그레이션
parent: Core Messaging
originalRefLink: https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/reactive-streams.html#reactive-streams
parentUrl: /Spring%20Integration/core-messaging/
---

Spring Integration은 프레임워크 내에서 다양한 측면으로 [리액티브 스트림즈](https://www.reactive-streams.org/)와의 상호 작용을 지원하고 있다. 리액티브 스트림즈와 관련된 내용들은 대부분 이 페이지에서 다루며, 필요에 따라 세부 챕터로 이어지는 링크를 달아놨다.

---

## 목차

- [14.1 Preface](#141-preface)
- [14.2 Messaging Gateway](#142-messaging-gateway)
- [14.3 Reactive Reply Payload](#143-reactive-reply-payload)
- [14.4 FluxMessageChannel and ReactiveStreamsConsumer](#144-fluxmessagechannel-and-reactivestreamsconsumer)
- [14.5 Source Polling Channel Adapter](#145-source-polling-channel-adapter)
- [14.6 Event-Driven Channel Adapter](#146-event-driven-channel-adapter)
- [14.7 Message Source to Reactive Streams](#147-message-source-to-reactive-streams)
- [14.8 Splitter and Aggregator](#148-splitter-and-aggregator)
- [14.9 Java DSL](#149-java-dsl)
- [14.10 ReactiveMessageHandler](#1410-reactivemessagehandler)
- [14.11 Reactive Channel Adapters](#1411-reactive-channel-adapters)

---

## 14.1 Preface

Spring Integration을 간단히 요약하면 스프링의 프로그래밍 모델을 확장해서 유명 엔터프라이즈 통합 패턴들을 지원한다고 말할 수 있다. 덕분에 스프링 기반 애플리케이션 내에서 경량으로 메시지를 처리할 수 있으며, 어댑터를 선언해 외부 시스템과 통합할 수 있다. Spring Integration의 주요 목표는 유지 보수와 테스트가 가능한 코드를 생산하려면 반드시 필요한 관심사의 분리<sup>separation of concerns</sup>를 그대로 가져가면서, 동시에 엔터프라이즈 통합 솔루션을 구축할 수 있는 간단한 모델을 제공하는 거다. 애플리케이션에선 `message`, `channel`, `endpoint`같은 일급 객체<sup>first class citizen</sup>를 사용해서 이 목표를 달성할 수 있다. 이런 객체들을 이용하면 손 쉽게 통합 플로우(파이프라인)를 구축할 수 있다. 통합 플로우에선 (대부분의 경우), 하나의 엔드포인트는 하나의 채널에 메시지를 생성하며, 또 다른 엔드포인트에서 이를 컨슘해간다. 이런식으로 역할을 나눠 통합에 필요한 상호 작용 모델과 타겟 비즈니스 로직을 구별한다. 여기서 주목할 것은 중간에 위치하고 있는 채널이다. 플로우의 동작은 이 채널의 구현체에 따라 달라지며, 이로 인해 엔드포인트가 바뀌어야 하는 것은 없다.

한편, 리액티브 스트림즈는 논블로킹 back pressure를 지원하는 비동기 스트림 처리의 표준이다. 리액티브 스트림즈의 메인 목표는 비동기 경계를 넘어 스트림 데이터를 교환하는 것을 제어하면서 (다른 스레드나 스레드 풀로 데이터를 전달하는 등), 동시에 데이터를 받는 쪽에서 어느 정도일지 모를 양의 데이터를 버퍼링하도록 강제하지 않는 거다. 다시 말해, 이 모델의 핵심 개념인 back pressure는 스레드들을 중재하는 큐에 제한<sup>bounded</sup>을 둘 수 있게 해준다. [프로젝트 리액터](https://projectreactor.io/)같은 리액티브 스트림즈 구현체는 스트림 애플리케이션의 처리 그래프 전반에서 이런 특징들과 장점을 유지시켜 주는 게 목적이다. 리액티브 스트림즈 라이브러리의 궁극적인 목표는 애플리케이션을 위한 타입들과 연산자 집합, 관련 API를 프로그래밍 언어 구조 내에서 가능한 한 투명하고 유연하게 제공하는 것이지만, 최종적인 솔루션은 일반적인 함수 체인을 실행할 때 생각하는 명령형<sup>imperative</sup>과는 거리가 멀다. 리액티브 환경에선 정의와 실행 단계를 따로 생각해야 한다. 실제 실행은 이후 말단에 있는 리액티브 publisher를 구독할 때 일어나며, 필요에 따라 back-pressure를 적용해 맨 아래 정의에서 윗쪽으로 데이터 수요를 푸시한다 - 즉, 지금 최대로 처리할 수 있는 만큼 이벤트를 요청한다. 리액티브 애플리케이션은 하나의 `"stream"`으로 볼 수 있다 (Spring Integration 용어에 익숙해졌다면 `"flow"`). 실제로 Java 9부턴 `java.util.concurrent.Flow`라는 클래스로 리액티브 스트림즈 SPI를 제공한다.

이 시점엔 Spring Integration 엔드포인트에 몇 가지 리액티브 프레임워크 연산자를 적용하기만 하면 쉽게 리액티브 스트림즈 애플리케이션을 작성할 수 있을 것이라 생각될 수 있다. 하지만 실제 문제는 훨씬 더 광범위하며, 모든 엔드포인트를 리액티브 스트림 안에서 투명하게 처리할 수 있는 건 아니다 (ex. `JdbcMessageHandler`). 물론 Spring Integration에서 리액티브 스트림즈를 지원하면서 삼은 주요 목표는 전체 프로세스를 온디맨드<sup>on demand</sup>로 시작하고 back-pressure를 적용할 준비를 마친, 완전한 반응형으로 만들어주는 거다. 하지만 채널 어댑터의 타겟 프로토콜과 관련 시스템이 리액티브 스트림즈 상호 작용 모델을 제공하지 않는다면 완전한 반응형은 구축할 수 없다. 이어지는 섹션에선 통합 플로우 구조는 유지하면서 리액티브 애플리케이션을 개발하기 위한 Spring Integration의 구성 요소들과 처리 방식을 설명한다.

> Spring Integration에서 모든 리액티브 스트림즈 상호 작용은 `Mono`와 `Flux`같은 [프로젝트 리액터](https://projectreactor.io/) 타입으로 구현한다.

---

## 14.2 Messaging Gateway

리액티브 스트림즈와 가장 쉽게 상호 작용할 수 있는 건 `@MessagingGateway`다. 여기서는 게이트웨이 메소드의 리턴 타입을  `Mono<?>`로 만들어주기만 하면 된다. 그러면 반환된 `Mono` 인스턴스를 구독하는 시점에 게이트웨이 메소드 뒷단에서 이어지는 전체 통합 플로우가 시작된다. 자세한 내용은 [리액터 `Mono`](../messaging-endpoints/#reactor-mono)를 참고해라. 이와 유사하게 프레임워크 내부에서도 인바운드 게이트웨이에 `Mono` 응답 방식을 사용하는데, 이 인바운드 게이트웨이들은 완전히 리액티브 스트림즈와 호환되는 프로토콜을 기반으로 동작한다 (자세한 내용은 아래있는 [리액티브 채널 어댑터](#1411-reactive-channel-adapters)를 참고해라). send-and-receive 작업은 `Mono.deffer()`로 감싸지며, `replyChannel` 헤더가 있다면 체이닝을 통해 응답을 가져온다. 이렇게 하면 특정 리액티브 프로토콜(e.g. Netty)을 위한 인바운드 컴포넌트가 Spring Integration에서 진행하는 리액티브 플로우의 subscriber이자 initiator가 된다. 요청 페이로드가 리액티브 타입인 경우엔, initiator가 구독할 때까지 처리를 연기하는 리액티브 스트림 정의로 처리하는 것이 좋다. 그러려면 핸들러 메소드 역시 리액티브 타입을 반환해야 한다. 자세한 내용은 다음 섹션을 참고해라.

---

## 14.3 Reactive Reply Payload

응답을 생성하는 `MessageHandler`가 응답 메시지로 리액티브 타입 페이로드를 반환하면, `outputChannel`로 설정한 일반 `MessageChannel` 구현체가 응답 메시지를 비동기로 처리해주며, 이 출력 채널이 `ReactiveStreamsSubscribableChannel`을 구현한 경우엔 (ex. `FluxMessageChannel`) 응답 메세지는 구독하는 시점에 다시 펼쳐진다<sup>flatten</sup>. 표준 명령형<sup>imperative</sup> `MessageChannel`에서 응답 페이로드가 **multi-value** publisher인 경우엔 (자세한 정보는 `ReactiveAdapter.isMultiValue()` 참고), 응답 페이로드를 `Mono.just()`로 감싼다. 따라서 다운스트림에서 이 `Mono`를 명시적으로 구독하거나 다운스트림 `FluxMessageChannel`에서 다시 펼쳐야 한다<sup>flatten</sup>. `outputChannel`이 `ReactiveStreamsSubscribableChannel`일 땐 리턴 타입이나 구독에 대해 신경쓰지 않아도 된다. 전부 프레임워크 내부에서 순조롭게 처리될 거다.

자세한 정보는 [비동기 서비스 Activator](../messaging-endpoints/#1052-asynchronous-service-activator)를 참고해라.

---

## 14.4 `FluxMessageChannel` and `ReactiveStreamsConsumer`

`FluxMessageChannel`은 `MessageChannel`과 `Publisher<Message<?>>`를 모두 구현하고 있다. `send()` 구현부에서 전달받은 메시지들을 싱크<sup>sink</sup>하기 위해 내부적으로 hot source인 `Flux`를 생성한다. `Publisher.subscribe()` 구현은 내부 `Flux`에 위임한다. 또한 `FluxMessageChannel`은 업스트림 publisher를 온디맨드로 컨슘할 수 있도록 `ReactiveStreamsSubscribableChannel` 인터페이스도 구현하고 있다. 이 채널에 업스트림 `Publisher`를 설정하면 (ex. 아래에서 소스 폴링 채널 어댑터와 splitter 참고), 채널에 대한 구독이 준비되면 자동으로 구독한다. 이 publisher에서 발생하는 이벤트틀은 위에서 언급한 내부 `Flux`에 싱크<sup>sink</sup>한다.

`FluxMessageChannel`의 컨슈머는 리액티브 스트림즈 스펙을 준수할 수 있도록 반드시 `org.reactivestreams.Subscriber` 인스턴스여야 한다. 다행히도 Spring Integration의 모든 `MessageHandler` 구현체들은 Reactor의 `CoreSubscriber`도 구현하고 있다. 그리고 이 둘을 연결해주는 `ReactiveStreamsConsumer` 클래스 덕분에 크게 신경쓰지 않아도 쉽게 전체적인 통합 플로우를 구성할 수 있다. 이 경우 플로우 동작은 명령형<sup>imperative</sup> push 모델에서 반응형<sup>reactive</sup> pull 모델로 변경된다. `ReactiveStreamsConsumer`는 `IntegrationReactiveUtils`를 사용해 `MessageChannel`을 리액티브 소스로 전환할 수도 있어서, 통합 플로우 일부를 리액티브로 만들 때도 활용할 수 있다.

자세한 내용은 [`FluxMessageChannel`](../messaging-channels/#fluxmessagechannel)을 참고해라.

5.5 버전부터 `ConsumerEndpointSpec`은 `reactive()` 옵션을 도입해서 입력 채널과는 상관 없이 플로우의 엔드포인트를 `ReactiveStreamsConsumer`로 만들 수 있다. 원한다면 `Function<? super Flux<Message<?>>, ? extends Publisher<Message<?>>>`를 제공해서 입력 채널로 만드는 소스 `Flux`를 `Flux.transform()` 연산을 통해 커스텀할 수 있다 (`publishOn()`, `doOnNext()`, `retry()` 등으로). 이 기능은 모든 메시지 처리 어노테이션(`@ServiceActivator`, `@Splitter` 등)에 있는 서브 어노테이션 `@Reactive`로 나타내며, `reactive()` 속성을 통해 이용할 수 있다.

---

## 14.5 Source Polling Channel Adapter

일반적으로 `SourcePollingChannelAdapter`는 `TaskScheduler`로 시작하는 태스크에 의존한다. 즉, 설정한 옵션들로 폴링 트리거를 만들고, 타겟 소스에서 데이터나 이벤트를 폴링하는 태스크를 주기적으로 스케줄링한다. 하지만 `outputChannel`이 `ReactiveStreamsSubscribableChannel`일 땐, 같은 `Trigger`를 사용해 다음 실행 시간을 결정하지만, 태스크를 예약하는 대신 `SourcePollingChannelAdapter`에서 `Flux<Message<?>>`를 생성한다. 이 flux를 생성할 땐 `nextExecutionTime` 값으로 `Flux.generate()`를 호출하고, 이전 스텝의 duration으로 `Mono.delay()`를 실행한다. 그런 다음 `Flux.flatMapMany()`를 사용해 `maxMessagesPerPoll`만큼 폴링해서 출력 `Flux`에 싱크<sup>sink</sup>해둔다. 이 `Flux` generator는 설정에 있는 `ReactiveStreamsSubscribableChannel`에서 다운스트림 back-pressure를 준수하며 구독해간다. 5.5 버전부터 `maxMessagesPerPoll == 0`일 때는 source를 아예 호출하지 않으며, 이후 컨트롤 버스 등을 통해 `maxMessagesPerPoll`이 0이 아니 값으로 바뀌기 전까지는 `flatMapMany()`는 `Mono.empty()`를 반환하고 즉시 완료된다. 이런 방식을 통해 모든 `MessageSource` 구현체는 리액티브 hot source로 전환할 수 있다.

자세한 정보는 [폴링 컨슈머](../messaging-channels/#62-poller)를 참고해라.

---

## 14.6 Event-Driven Channel Adapter

`MessageProducerSupport`는 이벤트 기반 채널 어댑터의 기본 클래스이며, 메시지를 생산해 이벤트를 발생시키는 API는 보통 여기 있는 `sendMessage(Message<?>)` 메소드를 리스너 콜백으로 사용한다. 이 콜백은 메시지 producer 구현체가 리스너를 이용하는 대신 메시지의 `Flux`를 생성하더라도 Reactor 연산자 `doOnNext()`에 쉽게 연결할 수 있다. 사실, 메시지 producer의 `outputChannel`이 `ReactiveStreamsSubscribableChannel`이 아닐 땐 프레임워크 단에서 이미 이렇게 처리해주고 있다. 하지만  타겟 시스템의 데이터 소스가 `Publisher<Message<?>>>`일 땐 `MessageProducerSupport`의 `subscribeToPublisher(Publisher<? extends Message<?>>)`를 이용하면 좀 더 쉽게 back-pressure를 지원할 수 있다. 이 메소드는 소스 데이터의 `Publisher`로 이벤트를 발생시킬 때 일반적으로 `doStart()` 구현부 안에서 호출한다. 온 디맨드 구독과 다운스트림의 이벤트 컨슈밍을 위해서는 리액티브 `MessageProducerSupport` 구현체에 `FluxMessageChannel`을 `outputChannel`로 조합해서 사용하는 것이 좋다. `Publisher` 구독이 취소되면 채널 어댑터는 중지 상태가 된다. 이런 채널 어댑터에서 `stop()`을 호출하면 소스 `Publisher`에서 메시지 생성을 끝마친다. 소스 `Publisher`가 새로 생성되면 자동으로 구독이 일어나 채널 어댑터를 다시 시작할 수 있다.

---

## 14.7 Message Source to Reactive Streams

5.3 버전부터는 `ReactiveMessageSourceProducer`를 제공한다. 이 클래스에선 건네받은 `MessageSource`에 이벤트 기반 메시지 생성 로직을 더해, 설정한 `outputChannel`로 메시지를 전송해준다. 내부적으로는 `Flux<Message<?>>`를 생성하는 `Mono`로 `MessageSource`를 감싸고, 반복해서 재구독한다. 이 `Flux<Message<?>>`는 위에서 언급한 `subscribeToPublisher(Publisher<? extends Message<?>>)`에서 구독한다. 이 `Mono`를 구독할 땐 타겟 `MessageSource`에서 가능한 블로킹되는 것을 피하기 위해 `Schedulers.boundedElastic()`을 사용한다. 메시지 소스가 `null`을 반환하면 (가져올 데이터 없을 때), `Mono`는 `repeatWhenEmpty()` 상태로 전환되며 이후 재구독할 땐 구독자 컨텍스트에 있는 `IntegrationReactiveUtils.DELAY_WHEN_EMPTY_KEY` `Duration`에 기반한 `delay`를 사용한다. 딜레이 기본값은 1초다. `MessageSource`가 생산한 메시지의 헤더에 `IntegrationMessageHeaderAccessor.ACKNOWLEDGMENT_CALLBACK` 정보가 담겨 있을 땐, 본래 `Mono`의 `doOnSuccess()`에서 메시지를 승인<sup>acknowledge</sup>하고 (필요하다면), 다운스트림 플로우에서 `MessagingException`을 발생시켜 실패 메시지를 전달하면 `doOnError()`에서 거부<sup>reject</sup>한다. 기존 `MessageSource<?>` 구현체를 위한 폴링 채널 어댑터를 반응형 온디맨드 솔루션으로 전환해야 할 땐 언제든지 이 `ReactiveMessageSourceProducer`를 사용하면 된다.

---

## 14.8 Splitter and Aggregator

`AbstractMessageSplitter`는 로직 중간에 `Publisher`를 만나면 자연스럽게 `Publisher` 안의 항목들을 `outputChannel`로 전송할 메시지로 매핑한다. 출력 채널이 `ReactiveStreamsSubscribableChannel`일 땐, 이 채널의 요구에 따라<sup>on demand</sup> `Publisher`를 감싼 `Flux`를 구독하며, 이때 splitter의 동작은 들어오는 이벤트를 multi-value `Publisher`로 매핑해 출력하는 리액터 연산자 `flatMap`에 좀더 가깝게 보인다. 가장 이상적인 구성은, splitter 전후에 `FluxMessageChannel`을 두고 전체 통합 플로우를 리액티브 스트림즈 요구 사항에 맞춰 관련 연산자들로 이벤트를 처리할 수 있게 만드는 거다. 일반 채널을 사용한다면 표준 분할 로직인 iterate-and-produce 방식으로 메시지를 처리할 수 있도록 `Publisher`를 `Iterable`로 변환한다.

`FluxAggregatorMessageHandler`는 프로젝트 리액터 관점에서 바라보면 하나의 **"리액티브 연산자"**로 생각할 수 있는 또 다른 리액티브 스트림즈 로직의 구현체다. 이 클래스는 `Flux.groupBy()`, `Flux.window()`(또는 `buffer()`) 연산자를 기반으로 동작한다. 들어오는 메시지들은 `FluxAggregatorMessageHandler`를 생성할 때 시작하는 `Flux.create()`에 싱크<sup>sink</sup>해서 hot source로 동작시킨다. 이 `Flux`는 `ReactiveStreamsSubscribableChannel`에서 온 디맨드로 구독하거나, `outputChannel`이 리액티브가 아닐 땐 `FluxAggregatorMessageHandler.start()`에서 곧바로 구독한다. 이 `FluxAggregatorMessageHandler`가 진가를 발휘할 때는 앞뒤에 `FluxMessageChannel`을 사용해 전체 통합 플로우를 구성했을 때로, 전체 로직에 back-pressure를 가져다 줄 수 있다.

자세한 내용은 [Stream and Flux Splitting](../messaging-routing/#stream-and-flux)과 [Flux Aggregator](../messaging-routing/#845-flux-aggregator)를 읽어봐라.

---

## 14.9 Java DSL

Java DSL의 `IntegrationFlow`는 원하는 `Publisher` 인스턴스로부터 시작할 수 있다 (`IntegrationFlows.from(Publisher<Message<T>>)` 참고). 또한 `IntegrationFlowBuilder.toReactivePublisher()` 연산자를 사용하면 `IntegrationFlow`를 리액티브 hot source로 전환할 수 있다. 두 케이스 모두 내부에선 `FluxMessageChannel`을 사용한다. `FluxMessageChannel`은 `ReactiveStreamsSubscribableChannel` 인터페이스를 구현하고 있어서 인바운드 `Publisher`를 구독할 수 있으며, 동시에 `Publisher<Message<?>>`를 구현하기도 해서 다운스트림 구독자를 등록할 수도 있다. `IntegrationFlow`를 동적으로 등록하면, `Publisher`를 이어주는 이 통합 플로우에 리액티브 스트림즈를 조합해서 더 강력한 로직을 구현할 수 있다.

5.5.6 버전부터는 `toReactivePublisher(boolean autoStartOnSubscribe)` 연산자를 제공한다. 이 연산자에선 반환하는 `Publisher<Message<?>>` 뒤에 있는 전체 `IntegrationFlow`의 수명 주기를 제어할 수 있다. 일반적으로 리액티브 publisher를 구독하고 컨슘하는 일은, 리액티브 스트림을 구성하거나 `ApplicationContext`를 시작할 때가 아닌 이후 런타임 단계에서 일어난다. `autoStartOnSubscribe` 플래그를 사용하는 이 새 연산자를 활용하면 `Publisher<Message<?>>`를 구독하는 곳에 `IntegrationFlow`의 수명 주기를 관리하기 위한 보일러플레이트 코드를 작성하지 않아도 된다. 이 연산자에선 (`true`를 넘기면) `IntegrationFlow`와 거기 있는 구성 요소들을 `autoStartup = false`로 마킹하기 때문에, `ApplicationContext`에서 플로우에 메시지를 생성하거나 컨슘하는 일을 자동으로 시작하지 않는다. 대신 내부 `Flux.doOnSubscribe()`에서 `IntegrationFlow`의 `start()`를 호출한다. `Flux.doOnCancel()`과 `Flux.doOnTerminate()`에선 `autoStartOnSubscribe` 값과는 상관없이 플로우를 중단한다 (컨슘하는 쪽이 없으면 메시지를 생성할 이유가 없다).

이와는 정반대로 `IntegrationFlow`가 리액티브 스트림을 호출하고, 완료된 후에도 계속 이어가야 하는 케이스에선, `IntegrationFlowDefinition`의 `fluxTransform()` 연산자를 사용하면 된다. 이 연산자를 호출하면 플로우는 `FluxMessageChannel`로 전환되고, 이어서 `Flux.transform()` 연산자에서 전달받은 `fluxFunction`을 실행한다. 이 함수의 실행 결과는 flatMap 연산자 안에서 `Mono<Message<?>>`로 감싸지고, 여기서 출력한 `Flux`를 다운스트림 플로우에서 또 다른 `FluxMessageChannel`로 구독한다.

자세한 내용은 [Java DSL 챕터](../java-dsl)를 확인해봐라.

---

## 14.10 `ReactiveMessageHandler`

5.3 버전부터 프레임워크에서 자체적으로 `ReactiveMessageHandler`를 지원한다. `ReactiveMessageHandler`는 저수준 로직에서 온 디맨드로 구독할 수 있도록 리액티브 타입을 반환하고, 응답 데이터 제공 없이 리액티브 스트림 구성을 이어가는 리액티브 클라이언트를 위해 설계됐다. 명령형<sup>imperative</sup> 통합 플로우에서 `ReactiveMessageHandler`를 사용하는 경우, back-pressure를 지킬 수 있는 리액티브 스트림즈 구성이 없기 때문에 `handleMessage()`를 반환한 직후에 구독한다. 이 경우 프레임워크는 `ReactiveMessageHandler`를 `MessageHandler`의 순수 구현체인 `ReactiveMessageHandlerAdapter`로 감싼다. 하지만 `ReactiveStreamsConsumer`를 가지고 있는 플로우라면 (ex. 컨슘할 채널이 `FluxMessageChannel`인 경우) back-pressure를 지키며 컨슘할 수 있도록 Reactor 연산자 `flatMap()`을 사용해 `ReactiveMessageHandler`를 완전한 리액티브 스트림으로 구성한다.

기본 제공하는 `ReactiveMessageHandler` 구현체 중 하나로는 아웃바운드 채널 어댑터를 위한 `ReactiveMongoDbStoringMessageHandler`가 있다. 자세한 내용은 [MongoDB 리액티브 채널 어댑터](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/mongodb.html#mongodb-reactive-channel-adapters)를 참고해라.

---

## 14.11 Reactive Channel Adapters

통합에 사용할 타겟 프로토콜이 리액티브 스트림즈 솔루션을 제공한다면, Spring Integration에서 채널 어댑터를 구현하는 건 꽤 간단해진다.

이벤트 기반 인바운드 채널 어댑터를 구현할 땐, 요청을 (필요하면) `Mono`나 `Flux`로 감싸 연기하고<sup>defer</sup>, 프로토콜 컴포넌트가 이 리스너 메소드에서 반환한 `Mono`를 구독하기 시작했을 때에만 메시지를 전송한다 (필요 시 응답을 생성한다). 이렇게 하면 리액티브 스트림을 위한 솔루션은 정확하게 이 컴포넌트 안에 캡슐화하게 된다. 물론 이 출력 채널을 구독하는 다운스트림 통합 플로우는 리액티브 스트림즈 사양을 준수하고, 온 디맨드 back-pressure를 지키며 동작해야 한다. 하지만 통합 플로우에 사용하는 `MessageHandler` 프로세서(또는 현재 구현체)에 따라, 인바운드 채널 어댑터가 항상 가능한 것은 아니다. 리액티브 구현체가 없을 땐 통합 엔드포인트 앞뒤에 스레드 풀과 큐, 또는 `FluxMessageChannel`(위 섹션 참고)을 사용해 해결할 수 있다.

리액티브 아웃바운드 채널 어댑터를 구현할 땐, 타겟 프로토콜 전용 리액티브 API를 사용해 리액티브 스트림을 시작하거나 이어가며 외부 시스템과 상호 작용하면 된다. 인바운드 페이로드는 그 자체로 리액티브 타입일 수도 있고, 리액티브 스트림을 구성하는 통합 플로우에서 발생한 이벤트일 수도 있다. 반환한 리액티브 타입은 단방향 fire-and-forget 시나리오라면 즉시 구독할 수 있고, 통합 플로우를 추가로 이어가거나 타겟 비즈니스 로직에서 직접 구독할 땐 다운스트림으로 전파할 수 있는데 (request-reply 시나리오), 그러더라도 다운스트림에선 리액티브 스트림즈 시맨틱스를 보존한다.

현재 Spring Integration은 [WebFlux](../webflux), [RSocket](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/rsocket.html#rsocket), [MongoDb](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/mongodb.html#mongodb), [R2DBC](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/r2dbc.html#r2dbc) 전용 채널 어댑터(혹은 게이트웨이) 구현체를 제공하고 있다. [Redis Stream Channel Adapter들](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/redis.html#redis-stream-outbound) 역시 반응형이며, Spring Data의 `ReactiveStreamOperations`를 사용한다. 더불어 [Apache Cassandra Extension](https://github.com/spring-projects/spring-integration-extensions/tree/main/spring-integration-cassandra)에선 Cassandra 리액티브 드라이버를 위한 `MessageHandler` 구현체를 제공하고 있다. 다른 리액티브 채널 어댑터도 다양하게 지원하고 있는데, 예를 들면 [Spring for Apache Kafka](https://spring.io/projects/spring-kafka)의 `ReactiveKafkaProducerTemplate`과 `ReactiveKafkaConsumerTemplate`을 사용하는 [Apache Kafka](../kafka) 전용 어댑터가 있다. 그 외 다양한 non-reactive 채널 어댑터를 사용할 때는 리액티브 스트림을 처리하는 중 블로킹되지 않도록 스레드 풀을 사용하는 것을 권장한다.
