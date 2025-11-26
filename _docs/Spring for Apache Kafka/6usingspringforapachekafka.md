---
title: Using Spring for Apache Kafka
category: Spring for Apache Kafka
order: 7
permalink: /Spring for Apache Kafka/kafka/
description: 스프링 카프카 사용하기
image: ./../../images/spring/logo.png
lastmod: 2025-09-12T23:34:00+09:00
comments: true
originalRefName: 스프링 카프카
originalRefLink: https://docs.spring.io/spring-kafka/reference/kafka/kafka.html
parent: Reference
parentUrl: /Spring for Apache Kafka/reference/
subparent: Using Spring for Apache Kafka
subparentUrl: /Spring for Apache Kafka/kafka/
isSubparent: true
---

---

이번 섹션에선 스프링 카프카의 사용성에 영향을 미치는 여러 가지 요소들을 자세히 설명한다. 짧고 간단한 소개는 [퀵 가이드](../quick-tour)를 참고해라.

---

## Section Summary

- [카프카 연결하기](../connecting)
- [토픽 설정하기](../configuring-topics)
- [메시지 전송하기](../sending-messages)
- [메시지 수신하기](../receiving-messages)
- [리스너 컨테이너 프로퍼티](../container-props)
- [컨테이너 동적으로 생성하기](../dynamic-containers)
- [애플리케이션 이벤트](../events)
- [토픽/파티션 초기 오프셋](../partition-initial-offset)
- [특정 오프셋으로 되돌아가기](../seek)
- [컨테이너 팩토리](../container-factory)
- [Thread Safety](../thread-safety)
- [모니터링](../micrometer)
- [트랜잭션](../transactions)
- [Exactly Once Semantics](https://docs.spring.io/spring-kafka/reference/kafka/exactly-once.html)
- [Wiring Spring Beans into Producer/Consumer Interceptors](https://docs.spring.io/spring-kafka/reference/kafka/interceptors.html)
- [Producer Interceptor Managed in Spring](https://docs.spring.io/spring-kafka/reference/kafka/producer-interceptor-managed-in-spring.html)
- [Pausing and Resuming Listener Containers](https://docs.spring.io/spring-kafka/reference/kafka/pause-resume.html)
- [Pausing and Resuming Partitions on Listener Containers](https://docs.spring.io/spring-kafka/reference/kafka/pause-resume-partitions.html)
- [Serialization, Deserialization, and Message Conversion](https://docs.spring.io/spring-kafka/reference/kafka/serdes.html)
- [Message Headers](https://docs.spring.io/spring-kafka/reference/kafka/headers.html)
- [Null Payloads and Log Compaction of 'Tombstone' Records](https://docs.spring.io/spring-kafka/reference/kafka/tombstones.html)
- [Handling Exceptions](https://docs.spring.io/spring-kafka/reference/kafka/annotation-error-handling.html)
- [JAAS and Kerberos](https://docs.spring.io/spring-kafka/reference/kafka/kerberos.html)
