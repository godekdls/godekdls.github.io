---
title: What’s New in 3.3 Since 3.2
navTitle: What’s new?
category: Spring for Apache Kafka
order: 3
permalink: /Spring for Apache Kafka/whats-new/
description: 스프링 카프카 3.3 버전에서 추가된 기능들
image: ./../../images/logo.png
lastmod: 2025-09-12T23:34:00+09:00
comments: true
originalRefName: 스프링 카프카
originalRefLink: https://docs.spring.io/spring-kafka/reference/3.3.10/whats-new.html
---

---

This section covers the changes made from version 3.2 to version 3.3. For changes in earlier version, see [Change History](https://docs.spring.io/spring-kafka/reference/appendix/change-history.html).

### DLT Topic Naming Convention

The naming convention for DLT topics has been standardized to use the "-dlt" suffix consistently. This change ensures compatibility and avoids conflicts when transitioning between different retry solutions. Users who wish to retain the ".DLT" suffix behavior need to opt-in explicitly by setting the appropriate DLT name property.

### Enhanced Seek Operations for Consumer Groups

A new method, `getGroupId()`, has been added to the `ConsumerSeekCallback` interface. This method allows for more selective seek operations by targeting only the desired consumer group. The `AbstractConsumerSeekAware` can also now register, retrieve, and remove all callbacks for each topic partition in a multi-group listener scenario without missing any. See the new APIs (`getSeekCallbacksFor(TopicPartition topicPartition)`, `getTopicsAndCallbacks()`) for more details. For more details, see [Seek API Docs](https://docs.spring.io/spring-kafka/reference/kafka/seek.html#seek).

### Configurable Handling of Empty Batches in Kafka Listener with RecordFilterStrategy

`RecordFilterStrategy` now supports ignoring empty batches that result from filtering. This can be configured through overriding default method `ignoreEmptyBatch()`, which defaults to false, ensuring `KafkaListener` is invoked even if all `ConsumerRecords` are filtered out. For more details, see [Message receive filtering Docs](https://docs.spring.io/spring-kafka/reference/kafka/receiving-messages/filtering.html).

### ConcurrentContainerStoppedEvent

The `ConcurentContainerMessageListenerContainer` emits now a `ConcurrentContainerStoppedEvent` when all of its child containers are stopped. For more details, see [Application Events](https://docs.spring.io/spring-kafka/reference/kafka/events.html) and `ConcurrentContainerStoppedEvent` Javadocs.

### Original Record Key in Reply

When using `ReplyingKafkaTemplate`, if the original record from the request contains a key, then that same key will be part of the reply as well. For more details, see [Sending Messages](https://docs.spring.io/spring-kafka/reference/kafka/sending-messages.html) section of the reference docs.

### Customizing Logging in DeadLetterPublishingRecovererFactory

When using `DeadLetterPublishingRecovererFactory`, the user applications can override the `maybeLogListenerException` method to customize the logging behavior.

### Customize Admin client in KafkaAdmin

When extending `KafkaAdmin`, user applications may override the `createAdmin` method to customize Admin client creation.

### Customizing The Implementation of Kafka Streams

When using `KafkaStreamsCustomizer` it is now possible to return a custom implementation of the `KafkaStreams` object by overriding the `initKafkaStreams` method.

### KafkaHeaders.DELIVERY_ATTEMPT for batch listeners

When using a `BatchListener`, the `ConsumerRecord` can have the `KafkaHeaders.DELIVERY_ATTMPT` header in its headers fields. If the `DeliveryAttemptAwareRetryListener` is set to error handler as retry listener, each `ConsumerRecord` has delivery attempt header. For more details, see [Kafka Headers for Batch Listener](https://docs.spring.io/spring-kafka/reference/kafka/annotation-error-handling.html#delivery-attempts-header-for-batch-listener).

### Kafka Metrics Listeners and `TaskScheduler`

The `MicrometerProducerListener`, `MicrometerConsumerListener` and `KafkaStreamsMicrometerListener` can now be configured with a `TaskScheduler`. See `KafkaMetricsSupport` JavaDocs and [Micrometer Support](https://docs.spring.io/spring-kafka/reference/kafka/micrometer.html) for more information.
