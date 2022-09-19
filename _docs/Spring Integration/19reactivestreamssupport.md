---
title: Reactive Streams Support
category: Spring Integration
order: 19
permalink: /Spring%20Integration/reactive-streams/
description: todo
image: ./../../images/springintegration/logo.png
lastmod: 2022-01-05T21:30:00+09:00
comments: true
originalRefName: 스프링 인티그레이션
parent: Core Messaging
originalRefLink: https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/reactive-streams.html#reactive-streams
parentUrl: /Spring%20Integration/core-messaging/
---

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

Spring Integration은 프레임워크 내 몇몇 곳과 다양한 측면에서 [리액티브 스트림즈](https://www.reactive-streams.org/) 상호 작용을 지원한다. 리액티브 스트림즈와 관련한 내용들은 대부분 이 페이지에서 다루며, 필요에 따라 세부 챕터로 이어지는 링크를 달아놨다.

## 14.1 Preface

Spring Integration을 간단히 요약하면 스프링 프로그래밍 모델을 확장해서 유명 엔터프라이즈 통합 패턴들을 지원한다고 말할 수 있다. 덕분에 스프링 기반 애플리케이션 내에서 경량으로 메시지를 처리할 수 있으며, 어댑터를 선언해 외부 시스템과 통합할 수 있다. Spring Integration의 주요 목표는 유지보수와 테스트가 가능한 코드를 생산하려면 반드시 필요한 관심사의 분리<sup>separation of concerns</sup>를 그대로 가져가면서, 동시에 엔터프라이즈 통합 솔루션을 구축할 수 있는 간단한 모델을 제공하는 거다. 애플리케이션에선 `message`, `channel`, `endpoint`같은 일급 객체<sup>first class citizen</sup>를 사용해서 이 목표를 달성할 수 있다. 이런 객체들을 이용하면 통합 플로우(파이프라인)를 구축할 수 있다. 통합 플로우에선 (대부분의 경우), 하나의 엔드포인트는 하나의 채널에 메시지를 생성하며, 또 다른 엔드포인트에서 이를 컨슘해간다. 이런식으로 통합 상호 작용 모델과 타겟 비즈니스 로직을 구별한다. 여기서 주목할 건 중간에 있는 채널이다. 플로우의 동작은 채널 구현체에 따라 달라지며, 채널이 엔드포인트에 영향을 주진 않는다.

한편, 리액티브 스트림즈는 논블로킹 back pressure를 지원하는 비동기 스트림 처리의 표준이다. 리액티브 스트림즈의 메인 목표는 비동기 경계를 넘어 스트림 데이터를 교환하는 것을 제어하면서 (다른 스레드나 스레드 풀로 데이터를 전달하는 등), 동시에 데이터를 받는 쪽에서 어느 정도일지 모를 양의 데이터를 버퍼링하도록 강제하지 않는 거다. 다시 말해, 이 모델의 핵심 개념인 back pressure는 스레드들을 중재하는 큐에 제한<sup>bounded</sup>을 둘 수 있게 해준다. [프로젝트 리액터](https://projectreactor.io/)같은 리액티브 스트림즈 구현체는 스트림 애플리케이션의 처리 그래프 전반에서 이런 특징들과 장점을 유지시켜 주는 게 목적이다. 리액티브 스트림즈 라이브러리의 궁극적인 목표는 애플리케이션을 위한 타입들과 연산자 집합, 관련 API를 프로그래밍 언어 구조에서 가능한 한 투명하고 유연하게 제공하는 것이지만, 최종적인 솔루션은 일반적인 함수 체인을 실행할 때 생각하는 명령형<sup>imperative</sup>과는 거리가 멀다. 리액티브 환경에선 정의와 실행 단계를 따로 생각해야 한다. 실제 실행은 이후 말단에 있는 리액티브 publisher를 구독할 때 일어나며, 필요에 따라 back-pressure를 적용해 맨 아래 정의에서 윗쪽으로 데이터 수요를 푸시한다 - 즉, 지금 최대로 처리할 수 있는 만큼 이벤트를 요청한다. 리액티브 애플리케이션은 하나의 `"stream"`으로 볼 수 있다 (Spring Integration 용어에 익숙해졌다면 `"flow"`). 실제로 Java 9부턴 `java.util.concurrent.Flow`라는 클래스로 리액티브 스트림즈 SPI를 제공한다.

이 시점엔 Spring Integration 엔드포인트에 몇 가지 리액티브 프레임워크 연산자를 적용하기만 하면 쉽게 리액티브 스트림즈 애플리케이션을 작성할 수 있을 것이라 생각될 수 있다. 하지만 실제 문제는 훨씬 더 광범위하며, 모든 엔드포인트를 리액티브 스트림 안에서 투명하게 처리할 수 있는 건 아니다 (ex. `JdbcMessageHandler`). 물론 Spring Integration에서 리액티브 스트림즈를 지원하면서 삼은 주요 목표는 전체 프로세스를 온디맨드<sup>on demand</sup>로 시작하고 back-pressure를 적용할 준비를 마친, 완전한 반응형으로 만들어주는 거다. 채널 어댑터의 타겟 프로토콜과 관련 시스템이 리액티브 스트림즈 상호 작용 모델을 제공하지 않는다면 완전한 반응형은 구축할 수 없다. 이어지는 섹션에선 통합 플로우 구조는 유지하면서 리액티브 애플리케이션을 개발하기 위한 Spring Integration의 구성 요소들과 처리 방식을 설명한다.

> Spring Integration에서 모든 리액티브 스트림즈 상호 작용은 `Mono`와 `Flux`같은 [프로젝트 리액터](https://projectreactor.io/) 타입으로 구현한다.

---

## 14.2 Messaging Gateway

The simplest point of interaction with Reactive Streams is a `@MessagingGateway` where we just make a return type of the gateway method as a `Mono<?>` - and the whole integration flow behind a gateway method call is going to be performed when a subscription happens on the returned `Mono` instance. See [Reactor `Mono`](../messaging-endpoints/#reactor-mono) for more information. A similar `Mono`-reply approach is used in the framework internally for inbound gateways which are fully based on Reactive Streams compatible protocols (see [Reactive Channel Adapters](#1411-reactive-channel-adapters) below for more information). The send-and-receive operation is wrapped into a `Mono.deffer()` with chaining a reply evaluation from the `replyChannel` header whenever it is available. This way an inbound component for the particular reactive protocol (e.g. Netty) is going to be as a subscriber and initiator for a reactive flow performed on the Spring Integration. If the request payload is a reactive type, it would be better to handle it withing a reactive stream definition deferring a process to the initiator subscription. For this purpose a handler method must return a reactive type as well. See the next section for more information.

리액티브 스트림즈와 가장 간단하게 상호 작용할 수 있는 지점은 `@MessagingGateway`로, 게이트웨이 메소드의 리턴 타입을  `Mono<?>`로 만들어주면 된다. 게이트웨이 메소드를 실행한 뒤 이어지는 전체 통합 플로우는 반환된 `Mono` 인스턴스를 구독할 때 진행된다. 자세한 내용은 [리액터 `Mono`](../messaging-endpoints/#reactor-mono)를 참고해라. 프레임워크 내부에서도 인바운드 게이트웨이에 유사한 `Mono` 응답 방식을 사용하는데, 완전한 리액티브 스트림즈 호환 프로토콜 기반으로 동작한다 (자세한 내용은 아래있는 [리액티브 채널 어댑터](#1411-reactive-channel-adapters)를 참고해라). send-and-receive 작업은 `Mono.deffer()`로 감싸지며, `replyChannel` 헤더가 있다면 응답을 체닝한다. 이렇게 하면 특정 리액티브 프로토콜(e.g. Netty)을 위한 인바운드 컴포넌트가 Spring Integration에서 수행되는 리액티브 플로우의 subscriber이자 initiator가 된다. 요청 페이로드가 리액티브 타입인 경우엔, initiator 구독으로 처리를 연기하는 리액티브 스트림 정의로 처리하는 것이 좋다. 이를 위해 핸들러 메소드 역시 리액티브 타입을 반환해야 한다. 자세한 내용은 다음 섹션을 참고해라.

---

## 14.3 Reactive Reply Payload

When a reply producing `MessageHandler` returns a reactive type payload for a reply message, it is processed in an asynchronous manner with a regular `MessageChannel` implementation   the `outputChannel` and flattened with on demand subscription when the output channel is a `ReactiveStreamsSubscribableChannel` implementation, e.g. `FluxMessageChannel`. With a standard imperative `MessageChannel` use-case, and if a reply payload is a **multi-value** publisher (see `ReactiveAdapter.isMultiValue()` for more information), it is wrapped into a `Mono.just()`. A result of this, the `Mono` has to be subscribed explicitly downstream or flattened by the `FluxMessageChannel` downstream. With a `ReactiveStreamsSubscribableChannel` for the `outputChannel`, there is no need to be concerned about return type and subscription; everything is processed smoothly by the framework internally.

`MessageHandler`를 생성하는 응답이 응답 메시지로 리액티브 타입 페이로드를 반환하면, `outputChannel`에 대해 제공되는 일반 `MessageChannel` 구현으로 비동기 방식으로 처리되고 출력 채널이 ` ReactiveStreamsSubscribableChannel` 구현, 예. `FluxMessageChannel`. 표준 명령형 `MessageChannel` 사용 사례와 응답 페이로드가 **다중 값** 게시자인 경우(자세한 내용은 `ReactiveAdapter.isMultiValue()` 참조) `Mono.just( )`. 그 결과 `Mono`는 명시적으로 다운스트림에 구독되거나 `FluxMessageChannel` 다운스트림에 의해 병합되어야 합니다. `outputChannel`에 대한 `ReactiveStreamsSubscribableChannel`을 사용하면 반환 유형 및 구독에 대해 걱정할 필요가 없습니다. 모든 것은 프레임워크에서 내부적으로 원활하게 처리됩니다.

See [Asynchronous Service Activator](../messaging-endpoints/#1052-asynchronous-service-activator) for more information.

---

## 14.4 `FluxMessageChannel` and `ReactiveStreamsConsumer`

The `FluxMessageChannel` is a combined implementation of `MessageChannel` and `Publisher<Message<?>>`. A `Flux`, as a hot source, is created internally for sinking incoming messages from the `send()` implementation. The `Publisher.subscribe()` implementation is delegated to that internal `Flux`. Also, for on demand upstream consumption, the `FluxMessageChannel` provides an implementation for the `ReactiveStreamsSubscribableChannel` contract. Any upstream `Publisher` (see Source Polling Channel Adapter and splitter below, for example) provided for this channel is auto-subscribed when subscription is ready for this channel. Events from this delegating publishers are sunk into an internal `Flux` mentioned above.

A consumer for the `FluxMessageChannel` must be a `org.reactivestreams.Subscriber` instance for honoring the Reactive Streams contract. Fortunately, all of the `MessageHandler` implementations in Spring Integration also implement a `CoreSubscriber` from project Reactor. And thanks to a `ReactiveStreamsConsumer` implementation in between, the whole integration flow configuration is left transparent for target developers. In this case, the flow behavior is changed from an imperative push model to a reactive pull model. A `ReactiveStreamsConsumer` can also be used to turn any `MessageChannel` into a reactive source using `IntegrationReactiveUtils`, making an integration flow partially reactive.

See [`FluxMessageChannel`](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/channel.html#flux-message-channel) for more information.

Starting with version 5.5, the `ConsumerEndpointSpec` introduces a `reactive()` option to make the endpoint in the flow as a `ReactiveStreamsConsumer` independently of the input channel. The optional `Function<? super Flux<Message<?>>, ? extends Publisher<Message<?>>>` can be provided to customise a source `Flux` from the input channel via `Flux.transform()` operation, e.g. with the `publishOn()`, `doOnNext()`, `retry()` etc. This functionality is represented as a `@Reactive` sub-annotation for all the messaging annotation (`@ServiceActivator`, `@Splitter` etc.) via their `reactive()` attribute.

---

## 14.5 Source Polling Channel Adapter

Usually, the `SourcePollingChannelAdapter` relies on the task which is initiated by the `TaskScheduler`. A polling trigger is built from the provided options and used for periodic scheduling a task to poll a target source of data or events. When an `outputChannel` is a `ReactiveStreamsSubscribableChannel`, the same `Trigger` is used to determine the next time for execution, but instead of scheduling tasks, the `SourcePollingChannelAdapter` creates a `Flux<Message<?>>` based on the `Flux.generate()` for the `nextExecutionTime` values and `Mono.delay()` for a duration from the previous step. A `Flux.flatMapMany()` is used then to poll `maxMessagesPerPoll` and sink them into an output `Flux`. This generator `Flux` is subscribed by the provided `ReactiveStreamsSubscribableChannel` honoring a back-pressure downstream. Starting with version 5.5, when `maxMessagesPerPoll == 0`, the source is not called at all, and `flatMapMany()` is completed immediately via a `Mono.empty()` result until the `maxMessagesPerPoll` is changed to non-zero value at a later time, e.g. via a Control Bus. This way, any `MessageSource` implementation can be turned into a reactive hot source.

See [Polling Consumer](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/polling-consumer.html#polling-consumer) for more information.

---

## 14.6 Event-Driven Channel Adapter

`MessageProducerSupport` is the base class for event-driven channel adapters and, typically, its `sendMessage(Message<?>)` is used as a listener callback in the producing driver API. This callback can also be easily plugged into the `doOnNext()` Reactor operator when a message producer implementation builds a `Flux` of messages instead of listener-based functionality. In fact, this is done in the framework when an `outputChannel` of the message producer is not a `ReactiveStreamsSubscribableChannel`. However, for improved end-user experience, and to allow more back-pressure ready functionality, the `MessageProducerSupport` provides a `subscribeToPublisher(Publisher<? extends Message<?>>)` API to be used in the target implementation when a `Publisher<Message<?>>>` is the source of data from the target system. Typically, it is used from the `doStart()` implementation when target driver API is called for a `Publisher` of source data. It is recommended to combine a reactive `MessageProducerSupport` implementation with a `FluxMessageChannel` as the `outputChannel` for on-demand subscription and event consumption downstream. The channel adapter goes to a stopped state when a subscription to the `Publisher` is cancelled. Calling `stop()` on such a channel adapter completes the producing from the source `Publisher`. The channel adapter can be restarted with automatic subscription to a newly created source `Publisher`.

---

## 14.7 Message Source to Reactive Streams

Starting with version 5.3, a `ReactiveMessageSourceProducer` is provided. It is a combination of a provided `MessageSource` and event-driven production into the configured `outputChannel`. Internally it wraps a `MessageSource` into the repeatedly resubscribed `Mono` producing a `Flux<Message<?>>` to be subscribed in the `subscribeToPublisher(Publisher<? extends Message<?>>)` mentioned above. The subscription for this `Mono` is done using `Schedulers.boundedElastic()` to avoid possible blocking in the target `MessageSource`. When the message source returns `null` (no data to pull), the `Mono` is turned into a `repeatWhenEmpty()` state with a `delay` for a subsequent re-subscription based on a `IntegrationReactiveUtils.DELAY_WHEN_EMPTY_KEY` `Duration` entry from the subscriber context. By default it is 1 second. If the `MessageSource` produces messages with a `IntegrationMessageHeaderAccessor.ACKNOWLEDGMENT_CALLBACK` information in the headers, it is acknowledged (if necessary) in the `doOnSuccess()` of the original `Mono` and rejected in the `doOnError()` if the downstream flow throws a `MessagingException` with the failed message to reject. This `ReactiveMessageSourceProducer` could be used for any use-case when a a polling channel adapter’s features should be turned into a reactive, on demand solution for any existing `MessageSource<?>` implementation.

---

## 14.8 Splitter and Aggregator

When an `AbstractMessageSplitter` gets a `Publisher` for its logic, the process goes naturally over the items in the `Publisher` to map them into messages for sending to the `outputChannel`. If this channel is a `ReactiveStreamsSubscribableChannel`, the `Flux` wrapper for the `Publisher` is subscribed on demand from that channel and this splitter behavior looks more like a `flatMap` Reactor operator, when we map an incoming event into multi-value output `Publisher`. It makes most sense when the whole integration flow is built with a `FluxMessageChannel` before and after the splitter, aligning Spring Integration configuration with a Reactive Streams requirements and its operators for event processing. With a regular channel, a `Publisher` is converted into an `Iterable` for standard iterate-and-produce splitting logic.

A `FluxAggregatorMessageHandler` is another sample of specific Reactive Streams logic implementation which could be treated as a `"reactive operator"` in terms of Project Reactor. It is based on the `Flux.groupBy()` and `Flux.window()` (or `buffer()`) operators. The incoming messages are sunk into a `Flux.create()` initiated when a `FluxAggregatorMessageHandler` is created, making it as a hot source. This `Flux` is subscribed to by a `ReactiveStreamsSubscribableChannel` on demand, or directly in the `FluxAggregatorMessageHandler.start()` when the `outputChannel` is not reactive. This `MessageHandler` has its power, when the whole integration flow is built with a `FluxMessageChannel` before and after this component, making the whole logic back-pressure ready.

See [Stream and Flux Splitting](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/splitter.html#split-stream-and-flux) and [Flux Aggregator](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/aggregator.html#flux-aggregator) for more information.

---

## 14.9 Java DSL

An `IntegrationFlow` in Java DSL can start from any `Publisher` instance (see `IntegrationFlows.from(Publisher<Message<T>>)`). Also, with an `IntegrationFlowBuilder.toReactivePublisher()` operator, the `IntegrationFlow` can be turned into a reactive hot source. A `FluxMessageChannel` is used internally in both cases; it can subscribe to an inbound `Publisher` according to its `ReactiveStreamsSubscribableChannel` contract and it is a `Publisher<Message<?>>` by itself for downstream subscribers. With a dynamic `IntegrationFlow` registration we can implement a powerful logic combining Reactive Streams with this integration flow bridging to/from `Publisher`.

Starting with version 5.5.6, a `toReactivePublisher(boolean autoStartOnSubscribe)` operator variant is present to control a lifecycle of the whole `IntegrationFlow` behind the returned `Publisher<Message<?>>`. Typically, the subscription and consumption from the reactive publisher happens in the later runtime phase, not during reactive stream composition, or even `ApplicationContext` startup. To avoid boilerplate code for lifecycle management of the `IntegrationFlow` at the `Publisher<Message<?>>` subscription point and for better end-user experience, this new operator with the `autoStartOnSubscribe` flag has been introduced. It marks (if `true`) the `IntegrationFlow` and its components for `autoStartup = false`, so an `ApplicationContext` won’t initiate production and consumption of messages in the flow automatically. Instead the `start()` for the `IntegrationFlow` is initiated from the internal `Flux.doOnSubscribe()`. Independently of the `autoStartOnSubscribe` value, the flow is stopped from a `Flux.doOnCancel()` and `Flux.doOnTerminate()` - it does not make sense to produce messages if there is nothing to consume them.

For the exact opposite use-case, when `IntegrationFlow` should call a reactive stream and continue after completion, a `fluxTransform()` operator is provided in the `IntegrationFlowDefinition`. The flow at this point is turned into a `FluxMessageChannel` which is propagated into a provided `fluxFunction`, performed in the `Flux.transform()` operator. A result of the function is wrapped into a `Mono<Message<?>>` for flat-mapping into an output `Flux` which is subscribed by another `FluxMessageChannel` for downstream flow.

See [Java DSL Chapter](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/dsl.html#java-dsl) for more information.

---

## 14.10 `ReactiveMessageHandler`

Starting with version 5.3, the `ReactiveMessageHandler` is supported natively in the framework. This type of message handler is designed for reactive clients which return a reactive type for on-demand subscription for low-level operation execution and doesn’t provide any reply data to continue a reactive stream composition. When a `ReactiveMessageHandler` is used in the imperative integration flow, the `handleMessage()` result in subscribed immediately after return, just because there is no reactive streams composition in such a flow to honor back-pressure. In this case the framework wraps this `ReactiveMessageHandler` into a `ReactiveMessageHandlerAdapter` - a plain implementation of `MessageHandler`. However when a `ReactiveStreamsConsumer` is involved in the flow (e.g. when channel to consume is a `FluxMessageChannel`), such a `ReactiveMessageHandler` is composed to the whole reactive stream with a `flatMap()` Reactor operator to honor back-pressure during consumption.

One of the out-of-the-box `ReactiveMessageHandler` implementation is a `ReactiveMongoDbStoringMessageHandler` for Outbound Channel Adapter. See [MongoDB Reactive Channel Adapters](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/mongodb.html#mongodb-reactive-channel-adapters) for more information.

---

## 14.11 Reactive Channel Adapters

When the target protocol for integration provides a Reactive Streams solution, it becomes straightforward to implement channel adapters in Spring Integration.

An inbound, event-driven channel adapter implementation is about wrapping a request (if necessary) into a deferred `Mono` or `Flux` and perform a send (and produce reply, if any) only when a protocol component initiates a subscription into a `Mono` returned from the listener method. This way we have a reactive stream solution encapsulated exactly in this component. Of course, downstream integration flow subscribed on the output channel should honor Reactive Streams specification and be performed in the on demand, back-pressure ready manner. This is not always available by the nature (or the current implementation) of `MessageHandler` processor used in the integration flow. This limitation can be handled using thread pools and queues or `FluxMessageChannel` (see above) before and after integration endpoints when there is no reactive implementation.

A reactive outbound channel adapter implementation is about initiation (or continuation) of a reactive stream to interaction with an external system according provided reactive API for the target protocol. An inbound payload could be a reactive type per se or as an event of the whole integration flow which is a part of reactive stream on top. A returned reactive type can be subscribed immediately if we are in one-way, fire-and-forget scenario, or it is propagated downstream (request-reply scenarios) for further integration flow or an explicit subscription in the target business logic, but still downstream preserving reactive streams semantics.

Currently Spring Integration provides channel adapter (or gateway) implementations for [WebFlux](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/webflux.html#webflux), [RSocket](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/rsocket.html#rsocket), [MongoDb](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/mongodb.html#mongodb) and [R2DBC](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/r2dbc.html#r2dbc). The [Redis Stream Channel Adapters](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/redis.html#redis-stream-outbound) are also reactive and uses `ReactiveStreamOperations` from Spring Data. Also an [Apache Cassandra Extension](https://github.com/spring-projects/spring-integration-extensions/tree/main/spring-integration-cassandra) provides a `MessageHandler` implementation for the Cassandra reactive driver. More reactive channel adapters are coming, for example for Apache Kafka in [Kafka](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/kafka.html#kafka) based on the `ReactiveKafkaProducerTemplate` and `ReactiveKafkaConsumerTemplate` from [Spring for Apache Kafka](https://spring.io/projects/spring-kafka) etc. For many other non-reactive channel adapters thread pools are recommended to avoid blocking during reactive stream processing.
