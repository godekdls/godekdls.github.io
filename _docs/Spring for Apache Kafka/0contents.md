---
title: Contents
category: Spring for Apache Kafka
order: 1
permalink: /Spring%20for%20Apache%20Kafka/contents/
image: ./../../images/spring/logo.jpeg
lastmod: 2025-09-12T23:34:00+09:00
comments: true
originalRefName: 스프링 카프카
originalRefLink: https://docs.spring.io/spring-kafka/reference/kafka/index.html
originalVersion: 4.0.0
description: 스프링 카프카 레퍼런스를 한글로 번역한 문서입니다. 버전은 4.0.0 기준입니다.
---

---

목차:

1. [Overview](../overview)
2. [What’s new?](../whats-new)
 - [What’s New in 3.3 Since 3.2](../whats-new)
  + [DLT Topic Naming Convention]
  + [Enhanced Seek Operations for Consumer Groups ]
  + [Configurable Handling of Empty Batches in Kafka Listener with RecordFilterStrategy]
  + [ConcurrentContainerStoppedEvent]
  + [Original Record Key in Reply]
  + [Customizing Logging in DeadLetterPublishingRecovererFactory]
  + [Customize Admin client in KafkaAdmin]
  + [Customizing The Implementation of Kafka Streams]
  + [KafkaHeaders.DELIVERY_ATTEMPT for batch listeners]
  + [Kafka Metrics Listeners and TaskScheduler]
  + [Edit this Page]
  + [GitHub Project]
  + [Stack Overflow]
3. [Introduction](../introduction)
- [Quick Tour](../quick-tour)
 + [Compatibility](../quick-tour#compatibility)
 + [Getting Started](../quick-tour#getting-started)
4. [Reference](../reference)
- [Using Spring for Apache Kafka](../kafka)
 + [Connecting to Kafka](../connecting)
 + [Configuring Topics](../configuring-topics)
 + [Sending Messages](../sending-messages)
 + [Receiving Messages](../receiving-messages)
 + [Listener Container Properties](..container-props)
 + [Dynamically Creating Containers
 + [Application Events
 + [Topic/Partition Initial Offset
 + [Seeking to a Specific Offset
 + [Container factory
 + [Thread Safety
 + [Monitoring
 + [Transactions
 + [Exactly Once Semantics
 + [Wiring Spring Beans into Producer/Consumer Interceptors
 + [Producer Interceptor Managed in Spring
 + [Pausing and Resuming Listener Containers](../pause-resume)
 + [Pausing and Resuming Partitions on Listener Containers](../pause-resume-partitions)
 + [Serialization, Deserialization, and Message Conversion
 + [Message Headers
 + [Null Payloads and Log Compaction of 'Tombstone' Records
 + [Handling Exceptions](../annotation-error-handling)
 + [JAAS and Kerberos
- [Non-Blocking Retries]
 + [How the Pattern Works]
 + [Back Off Delay Precision]
 + [Configuration]
 + [Programmatic Construction]
 + [Features]
 + [Combining Blocking and Non-Blocking Retries]
 + [Accessing Delivery Attempts]
 + [Topic Naming]
 + [Multiple Listeners, Same Topic(s)]
 + [DLT Strategies]
 + [Specifying a ListenerContainerFactory]
 + [Accessing Topics' Information at Runtime]
 + [Changing KafkaBackOffException Logging Level]
- [Apache Kafka Streams Support]
- [Testing Applications]
5. Tips, Tricks and Examples
6. Other Resources
7. Override Spring Boot Dependencies
8. Micrometer Observation Documentation
9. Native Images
10. Change History