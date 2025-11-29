---
title: Exactly Once Semantics
category: Spring for Apache Kafka
order: 21
permalink: /Spring for Apache Kafka/exactly-once/
description: 트랜잭션을 이용해 Exactly Once Semantics 구현하기
image: ./../../images/spring/logo.png
lastmod: 2025-09-12T23:34:00+09:00
comments: true
originalRefName: 스프링 카프카
originalRefLink: https://docs.spring.io/spring-kafka/reference/kafka/exactly-once.html
parent: Reference
parentUrl: /Spring for Apache Kafka/reference/
subparent: Using Spring for Apache Kafka
subparentUrl: /Spring for Apache Kafka/kafka/
---

---

리스너 컨테이너에는 `KafkaAwareTransactionManager` 인스턴스를 설정할 수 있다. 그러면 컨테이너는 리스너를 실행하기 전에 트랜잭션을 시작하고, 이 리스너에서 수행하는 모든 `KafkaTemplate` 작업은 트랜잭션에 참여하게 된다. 리스너가 레코드 처리를 정상적으로 마치면 (`BatchMessageListener` 사용 시엔 여러 개의 레코드), 컨테이너는 트랜잭션 매니저가 트랜잭션을 커밋하기 전에 `producer.sendOffsetsToTransaction()`을 호출해 오프셋을 트랜잭션에 포함시킨다. 리스너가 예외를 던지면 트랜잭션은 롤백되고, 컨슈머의 위치는 되돌아가 다시 폴링하면 롤백된 레코드를 조회될 수 있다. 자세한 내용과 반복적으로 실패하는 레코드를 처리하는 방법은 [After-rollback Processor](https://docs.spring.io/spring-kafka/reference/kafka/annotation-error-handling.html#after-rollback)를 참고해라.

트랜잭션을 이용하면 Exactly Once Semantics(EOS)를 구현할 수 있다.

Exactly Once Semantics는 `read → process → write` **시퀀스**를 정확히 한 번만 수행함을 보장한다는 뜻이다. (정확히는 read와 process 단계에는 at least once semantics 보장)

Spring for Apache Kafka 3.0 버전 이후부터는 `EOSMode.V2`만 지원한다:

- `V2` - 일명 fetch-offset-request fencing (2.5 버전부터)

> 브로커 버전은 2.5 이상이어야 한다.

`V2` 모드에서는 `group.id/topic/partition` 조합마다 별도의 프로듀서를 유지하지 않아도 된다. 트랜잭션에 오프셋과 함께 컨슈머 메타데이터도 함께 전달하기 때문에, 브로커는 이 정보를 기반으로 해당 프로듀서가 접근 권한을 잃은<sup>fenced</sup> 프로듀서인지 아닌지 판단할 수 있다.

자세한 내용은 [KIP-447](https://cwiki.apache.org/confluence/display/KAFKA/KIP-447%3A+Producer+scalability+for+exactly+once+semantics)을 참고해라.

`V2`는 이전까지 `BETA`로 불렸지만, 스프링 카프카도 [KIP-732](https://cwiki.apache.org/confluence/display/KAFKA/KIP-732%3A+Deprecate+eos-alpha+and+replace+eos-beta+with+eos-v2)에 맞추어 `EOSMode` 이름을 변경했다.