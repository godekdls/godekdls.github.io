---
title: Topic/Partition Initial Offset
category: Spring for Apache Kafka
order: 15
permalink: /Spring for Apache Kafka/partition-initial-offset/
description: 초기 오프셋 설정하기
image: ./../../images/spring/logo.png
lastmod: 2025-09-12T23:34:00+09:00
comments: true
originalRefName: 스프링 카프카
originalRefLink: https://docs.spring.io/spring-kafka/reference/kafka/topic/partition-initial-offset.html
parent: Reference
parentUrl: /Spring for Apache Kafka/reference/
subparent: Using Spring for Apache Kafka
subparentUrl: /Spring for Apache Kafka/kafka/
---

---

파티션의 초기 오프셋을 설정하는 방법은 여러 가지가 있다.

파티션을 수동으로 할당하는 경우, 컨테이너를 설정할 때 (원한다면) `TopicPartitionOffset` 인자를 넘겨 초기 오프셋을 지정할 수 있다 ([메시지 리스너 컨테이너](../receiving-messages/#message-listener-containers) 참고). 또한 언제든 원하는 오프셋으로 되돌릴<sup>seek</sup> 수도 있다.

브로커가 파티션을 할당하는 그룹 관리<sup>group management</sup>를 이용하는 경우:

- 새로운 `group.id`일 경우, 컨슈머 프로퍼티 `auto.offset.reset`(`earliest` 또는 `latest`)으로 초기 오프셋을 결정한다.
- 그룹 ID가 이미 존재하는 경우, 해당 그룹 ID의 현재 오프셋을 초기 오프셋으로 사용한다. 하지만 초기화 시점에 (또는 그 이후 언제든) 특정 오프셋으로 되돌리는<sup>seek</sup> 것도 가능하다.