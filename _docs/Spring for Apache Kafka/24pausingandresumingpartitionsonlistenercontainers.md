---
title: Pausing and Resuming Partitions on Listener Containers
category: Spring for Apache Kafka
order: 25
permalink: /Spring for Apache Kafka/pause-resume-partitions/
description: 파티션 단위로 리스너 컨테이너 일시중단하고 재개하기
image: ./../../images/spring/logo.png
lastmod: 2025-09-12T23:34:00+09:00
comments: true
originalRefName: 스프링 카프카
originalRefLink: https://docs.spring.io/spring-kafka/reference/3.3.10/pause-resume-partitions.html
parent: Reference
parentUrl: /Spring for Apache Kafka/reference/
subparent: Using Spring for Apache Kafka
subparentUrl: /Spring for Apache Kafka/kafka/
---

---

2.7 버전부터 리스너 컨테이너의 `pausePartition(TopicPartition topicPartition)`과 `resumePartition(TopicPartition topicPartition)` 메소드를 사용해, 해당 컨슈머에 할당된 특정 파티션의 컨슈밍을 일시 중단하고 재개할 수 있다. 일시 중지와 재개는 기존 카프카 API의 `pause()`, `resume()` 메소드와 유사하게, 각각 `poll()` 전과 후에 발생한다. `isPartitionPauseRequested()` 메소드는 해당 파티션에 일시 중단을 요청한 경우 true를 반환한다. `isPartitionPaused()` 메소드는 해당 파티션이 실제로 일시 중단된 경우 true를 반환한다.

또한 2.7 버전부터는, `ConsumerPartitionPausedEvent`와 `ConsumerPartitionResumedEvent` 이벤트가 발행되며, 이벤트에는 해당 컨테이너와 (`source` 프로퍼티), `TopicPartition` 정보가 담겨있다.
