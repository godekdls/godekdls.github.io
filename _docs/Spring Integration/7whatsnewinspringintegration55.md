---
title: What’s New in Spring Integration 5.5?
category: Spring Integration
order: 7
permalink: /Spring%20Integration/whats-new-55/
description: 스프링 인티그레이션 5.5에서 새로 추가된 기능들
image: ./../../images/springintegration/logo.png
lastmod: 2022-01-05T21:30:00+09:00
comments: true
originalRefName: 스프링 인티그레이션
originalRefLink: https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/index-single.html#whats-new
parent: What’s New?
parentUrl: /Spring%20Integration/whats-new/
---

---

If you are interested in more details, see the Issue Tracker tickets that were resolved as part of the 5.5 development process.

### 목차

- [4.1. New Components](#41-new-components)
  + [4.1.1. File Aggregator](#411-file-aggregator)
  + [4.1.2. MQTT v5 Support](#412-mqtt-v5-support)
- [4.2. General Changes](#42-general-changes)
  + [4.2.1. Integration Flows Composition](#421-integration-flows-composition)
  + [4.2.2. AMQP Changes](#422-amqp-changes)
  + [4.2.3. Redis Changes](#423-redis-changes)
  + [4.2.4. HTTP Changes](#424-http-changes)
  + [4.2.5. File/FTP/SFTP Changes](#425-fileftpsftp-changes)
  + [4.2.6. MongoDb Changes](#426-mongodb-changes)
  + [4.2.7. WebSockets Changes](#427-websockets-changes)
  + [4.2.8. JPA Changes](#428-jpa-changes)
  + [4.2.9. Gateway Changes](#429-gateway-changes)

---

## 4.1. New Components

### 4.1.1. File Aggregator

A `FileSplitter.FileMaker`-based implementation of `CorrelationStrategy`, `ReleaseStrategy` and `MessageGroupProcessor` as a `FileAggregator` component was introduced. See [File Aggregator](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/file.html#file-aggregator) for more information.

### 4.1.2. MQTT v5 Support

The `Mqttv5PahoMessageDrivenChannelAdapter` and `Mqttv5PahoMessageHandler` (including respective `MqttHeaderMapper`) were introduced to support MQTT v5 protocol communication. See [MQTT v5 Support](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/mqtt.html#mqtt-v5) for more information.

---

## 4.2. General Changes

All the persistent `MessageGroupStore` implementation provide a `streamMessagesForGroup(Object groupId)` contract based on the target database streaming API. See [Message Store](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/message-store.html#message-store) for more information.

The `integrationGlobalProperties` bean (if declared) must be now an instance of `org.springframework.integration.context.IntegrationProperties` instead of `java.util.Properties`, which support is deprecated for backward compatibility. The `spring.integration.channels.error.requireSubscribers=true` global property is added to indicate that the global default `errorChannel` must be configured with the `requireSubscribers` option (or not). The `spring.integration.channels.error.ignoreFailures=true` global property is added to indicate that the global default `errorChannel` must ignore (or not) dispatching errors and pass the message to the next handler. See [Global Properties](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/configuration.html#global-properties) for more information.

An `AbstractPollingEndpoint` (source polling channel adapter and polling consumer) treats `maxMessagesPerPoll == 0` as to skip calling the source. It can be changed to different value later on, e.g. via a Control Bus. See [Polling Consumer](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/endpoint.html#endpoint-pollingconsumer) for more information.

The `ConsumerEndpointFactoryBean` now accept a `reactiveCustomizer` `Function` to any input channel as reactive stream source and use a `ReactiveStreamsConsumer` underneath. This is covered as a `ConsumerEndpointSpec.reactive()` option in Java DSL and as a `@Reactive` nested annotation for the messaging annotations. See [Reactive Streams Support](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/reactive-streams.html#reactive-streams) for more information.

The `groupTimeoutExpression` for a correlation message handler (an `Aggregator` and `Resequencer`) can now be evaluated to a `java.util.Date` for some fine-grained scheduling use-cases. Also the `BiFunction groupConditionSupplier` option is added to the `AbstractCorrelatingMessageHandler` to supply a `MessageGroup` condition against a message to be added to the group. See [Aggregator](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/aggregator.html#aggregator) for more information.

The `MessageGroup` abstraction can be supplied with a `condition` to evaluate later on to make a decision for the group. See [Message Group Condition](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/message-store.html#message-group-condition) for more information.

### 4.2.1. Integration Flows Composition

The new `IntegrationFlows.from(IntegrationFlow)` factory method has been added to allow starting the current `IntegrationFlow` from the output of an existing flow. In addition, the `IntegrationFlowDefinition` has added a `to(IntegrationFlow)` terminal operator to continue the current flow at the input channel of some other flow. See [Integration Flows Composition](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/dsl.html#integration-flows-composition) for more information.

### 4.2.2. AMQP Changes

The `AmqpInboundChannelAdapter` and `AmqpInboundGateway` (and the respective Java DSL builders) now support an `org.springframework.amqp.rabbit.retry.MessageRecoverer` as an AMQP-specific alternative to the general purpose `RecoveryCallback`. See [AMQP Support](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/amqp.html#amqp) for more information.

### 4.2.3. Redis Changes

The `ReactiveRedisStreamMessageProducer` has now setters for all the `StreamReceiver.StreamReceiverOptionsBuilder` options, including an `onErrorResume` function. See [Redis Support](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/redis.html#redis) for more information.

### 4.2.4. HTTP Changes

The `HttpRequestExecutingMessageHandler` doesn’t fallback to the `application/x-java-serialized-object` content type any more and lets the `RestTemplate` make the final decision for the request body conversion based on the `HttpMessageConverter` provided. It also has now an `extractResponseBody` flag (which is `true` by default) to return just the response body, or to return the whole `ResponseEntity` as the reply message payload, independently of the provided `expectedResponseType`. Same option is presented for the `WebFluxRequestExecutingMessageHandler`, too. See [HTTP Support](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/http.html#http) for more information.

### 4.2.5. File/FTP/SFTP Changes

The persistent file list filters now have a boolean property `forRecursion`. Setting this property to `true`, also sets `alwaysAcceptDirectories`, which means that the recursive operation on the outbound gateways (`ls` and `mget`) will now always traverse the full directory tree each time. This is to solve a problem where changes deep in the directory tree were not detected. In addition, `forRecursion=true` causes the full path to files to be used as the metadata store keys; this solves a problem where the filter did not work properly if a file with the same name appears multiple times in different directories. IMPORTANT: This means that existing keys in a persistent metadata store will not be found for files beneath the top level directory. For this reason, the property is `false` by default; this may change in a future release.

The `FileInboundChannelAdapterSpec` has now a convenient `recursive(boolean)` option instead of requiring an explicit reference to the `RecursiveDirectoryScanner`.

The `remoteDirectoryExpression` can now be used in the `mv` command for convenience.

### 4.2.6. MongoDb Changes

The `MongoDbMessageSourceSpec` was added into MongoDd Java DSL. An `update` option is now exposed on both the `MongoDbMessageSource` and `ReactiveMongoDbMessageSource` implementations.

See [MongoDb Support](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/mongodb.html#mongodb) for more information.

### 4.2.7. WebSockets Changes

The WebSocket channel adapters based on `ServerWebSocketContainer` can now be registered and removed at runtime.

See [WebSockets Support](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/web-sockets.html#web-sockets) for more information.

### 4.2.8. JPA Changes

The `JpaOutboundGateway` now supports an `Iterable` message payload for a `PersistMode.DELETE`.

See [Outbound Channel Adapter](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/jpa.html#jpa-outbound-channel-adapter) for more information.

### 4.2.9. Gateway Changes

Previously, when using XML configuration, `@Gateway.payloadExpression` was ignored for no-argument methods. There is one possible breaking change - if the method is annotated with `@Payload` as well as `@Gateway` (with a different expression) previously, the `@Payload` would be applied, now the `@Gateway.payloadExpression` is applied. See [Gateway Configuration with Annotations and XML](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/gateway.html#gateway-configuration-annotations) and [Invoking No-Argument Methods](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/gateway.html#gateway-calling-no-argument-methods) for more information.