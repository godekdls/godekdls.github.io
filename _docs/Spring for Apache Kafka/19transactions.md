---
title: Transactions
category: Spring for Apache Kafka
order: 20
permalink: /Spring for Apache Kafka/transactions/
description: 스프링 카프카로 트랜잭션 사용하기
image: ./../../images/spring/logo.png
lastmod: 2025-09-12T23:34:00+09:00
comments: true
originalRefName: 스프링 카프카
originalRefLink: https://docs.spring.io/spring-kafka/reference/kafka/transactions.html
parent: Reference
parentUrl: /Spring for Apache Kafka/reference/
subparent: Using Spring for Apache Kafka
subparentUrl: /Spring for Apache Kafka/kafka/
---

---

이번 섹션에선 스프링 카프카가 트랜잭션을 지원하는 방식에 대해 설명한다.

### 목차

- [Overview](#overview)
- [Using KafkaTransactionManager](#using-kafkatransactionmanager)
- [Transaction Synchronization](#transaction-synchronization)
- [Using Consumer-Initiated Transactions](#using-consumer-initiated-transactions)
- [KafkaTemplate Local Transactions](#kafkatemplate-local-transactions)
- [TransactionIdPrefix](#transactionidprefix)
- [TransactionIdSuffix Fixed](#transactionidsuffix-fixed)
- [KafkaTemplate Transactional and non-Transactional Publishing](#kafkatemplate-transactional-and-non-transactional-publishing)
- [Transactions with Batch Listeners](#transactions-with-batch-listeners)

---

## Overview

트랜잭션 기능은 클라이언트 라이브러리 0.11.0.0에서 추됐다. Spring for Apache Kafka는 다음과 같은 방식으로 트랜잭션을 지원한다:

- `KafkaTransactionManager`: 스프링의 표준 트랜잭션 메커니즘을 이용한다 (`@Transactional`, `TransactionTemplate` 등)
- 트랜잭션 기반 `KafkaMessageListenerContainer`
- `KafkaTemplate`을 이용한 로컬 트랜잭션
- 다른 트랜잭션 매니저와 트랜잭션 동기화

트랜잭션은 `DefaultKafkaProducerFactory`에 `transactionIdPrefix`를 설정하면 활성화된다. 트랜잭션을 활성화하면 팩토리는 하나의 `Producer`를 관리하고 공유하는 대신, 트랜잭션 지원 프로듀서를 만들어 캐시에 저장한다. 사용자가 프로듀서에서 `close()`를 호출해도 실제로 프로듀서를 닫지 않고, 재사용할 수 있도록 캐시에 반환한다. 각 프로듀서의 `transactional.id` 프로퍼티는 `transactionIdPrefix + n`이며, `n`은 0부터 시작해 새로운 프로듀서가 생성될 때마다 증가한다. Spring for Apache Kafka 구버전에서는 레코드 단위로 메시지를 처리하는 리스너 컨테이너가 트랜잭션을 시작할 때는 zombie fencing 지원을 위해 다른 방식으로 `transactional.id`를 생성했었다. 하지만 3.0 버전부터는 `EOSMode.V2`가 유일한 옵션이기 때문에 지금은 그럴 필요가 없어졌다. 멀티 인스턴스 환경에서 애플리케이션을 실행할 경우, `transactionIdPrefix`는 인스턴스별로 고유해야 한다.

[Exactly Once Semantics](https://docs.spring.io/spring-kafka/reference/kafka/exactly-once.html)도 함께 참고해라.

[`transactionIdPrefix`](#transactionidsuffix-fixed)도 함께 참고해라.

스프링 부트를 사용한다면 `spring.kafka.producer.transaction-id-prefix` 프로퍼티만 설정해주면 된다. 그러면 스프링 부트가 자동으로 `KafkaTransactionManager` 빈을 설정하고 리스너 컨테이너에 주입해준다.

> 2.5.8 버전부터는 프로듀서 팩토리에 `maxAge` 프로퍼티를 설정할 수 있다. 브로커의 `transactional.id.expiration.ms` 동안 트랜잭션 프로듀서가 유휴<sup>idle</sup> 상태로 머무를 수 있는 경우 이 프로퍼티를 이용하면 된다. 현재 `kafka-clients`에서는 이러한 상황이 생기면 리밸런싱 없이도 `ProducerFencedException`이 발생할 수 있다. `maxAge`를 `transactional.id.expiration.ms`보다 작게 설정하면, 팩토리는 프로듀서가 max age를 초과할 경우 프로듀서를 갱신한다.

---

## Using `KafkaTransactionManager`

`KafkaTransactionManager`는 스프링 프레임워크의 `PlatformTransactionManager` 구현체다. `KafkaTransactionManager`는 생성자를 통해 프로듀서 팩토리의 참조를 넘겨받는다. 만약 커스텀 프로듀서 팩토리를 넘긴다면, 해당 팩토리는 반드시 트랜잭션을 지원해야 한다. `ProducerFactory.transactionCapable()`을 참고해라.

`KafkaTransactionManager`는 스프링의 표준 트랜잭션 메커니즘과 함께 사용할 수 있다 (`@Transactional`, `TransactionTemplate` 등). 트랜잭션을 활성화하면, 트랜잭션 범위 내에서 실행되는 `KafkaTemplate` 작업은 모두 현재 트랜잭션의 `Producer`를 사용한다. 트랜잭션 매니저는 성공 여부에 따라 트랜잭션을 커밋하거나 롤백한다. 이때 `KafkaTemplate`은 반드시 트랜잭션 매니저와 동일한 `ProducerFactory`를 사용하도록 설정해야 한다.

---

## Transaction Synchronization

이번 섹션에선 프로듀서 전용 트랜잭션을 설명한다 (리스너 컨테이너가 시작하는 트랜잭션이 아니다). 컨테이너가 시작하는 트랜잭션을 체이닝하는 방법은 [컨슈머로 트랜잭션 시작하기](#using-consumer-initiated-transactions)를 참고해라.

카프카로 레코드를 전송하는 동시에 데이터베이스에도 업데이트하고 싶다면 `DataSourceTransactionManager`를 사용하는 등, 일반적인 스프링 트랜잭션처럼 관리하면 된다.

```java
@Transactional
public void process(List<Thing> things) {
    things.forEach(thing -> this.kafkaTemplate.send("topic", thing));
    updateDb(things);
}
```

`@Transactional` 애노테이션 전용 인터셉터가 트랜잭션을 시작한다. `KafkaTemplate`은 트랜잭션 매니저와 트랜잭션을 동기화하며, 모든 메시지 전송 작업은 해당 트랜잭션에 참여하게 된다. 메소드가 종료되면, 데이터베이스 트랜잭션이 먼저 커밋되고, 그 다음 카프카 트랜잭션이 커밋된다. 커밋 순서를 바꾸고 싶다면 (카프카 커밋을 먼저하고 싶다면) `@Transactional` 메소드를 중첩해서 사용해라. 바깥쪽 메소드는 `DataSourceTransactionManager`를 사용하고, 안쪽 메소드는 `KafkaTransactionManager`를 사용하도록 설정해라.

JDBC와 카프카 트랜잭션을 동기화하면서 둘 중 하나를 먼저 커밋하도록 설정하는 코드는, [다른 트랜잭션 매니저와 함께 사용하는 카프카 트랜잭션 예시](https://docs.spring.io/spring-kafka/reference/tips.html#ex-jdbc-sync)를 참고해라.

> 2.5.17, 2.6.12, 2.7.9, 2.8.0 버전부터, 동기화 중인 트랜잭션의 커밋이 실패했을 때는 (앞선 트랜잭션이 먼저 커밋된 이후에) 호출부에 예외를 던진다. 이전 버전에서는 아무 일도 하지 않고 넘어가기 때문에 (debug 레벨 로그만 출력한다), 필요하다면 애플리케이션에서 직접 보상 트랜잭션 등의 조치를 취해야 한다.

---

## Using Consumer-Initiated Transactions

`ChainedKafkaTransactionManager`는 2.7버전부터 deprecated되었다. 상위 클래스 `ChainedTransactionManager`에 대한 자세한 내용은 JavaDoc을 확인해봐라. 이제 컨테이너에서 카프카 트랜잭션을 시작할 땐 `KafkaTransactionManager`를 사용하고, 그 외 다른 트랜잭션은 리스너 메소드에 `@Transactional`을 선언하면 된다.

JDBC 트랜잭션과 Kafka 트랜잭션을 연결하는 예시는 [다른 트랜잭션 매니저와 함께 사용하는 카프카 트랜잭션 예시](https://docs.spring.io/spring-kafka/reference/tips.html#ex-jdbc-sync)를 참고해라.

> Non-Blocking Retries는 [컨테이너 트랜잭션](#using-consumer-initiated-transactions)과 함께 사용할 수 없다. 리스너 코드에서 예외를 던지면, 컨테이너 트랜잭션은 커밋에 성공하고, 해당 레코드는 retryable 토픽으로 전송된다.

---

## `KafkaTemplate` Local Transactions

`KafkaTemplate`을 사용하면 일련의 작업들을 로컬 트랜잭션 내에서 수행할 수 있다. 그 방법은 아래 예시를 참고해라:

```java
boolean result = template.executeInTransaction(t -> {
    t.sendDefault("thing1", "thing2");
    t.sendDefault("cat", "hat");
    return true;
});
```

콜백 내에서 사용하는 인자는 템플릿 자체(`this`)다. 콜백이 정상적으로 종료되면 트랜잭션을 커밋하고, 예외가 발생하면 트랜잭션을 롤백한다.

> `KafkaTransactionManager`에 진행 중인 (또는 동기화된) 트랜잭션이 있더라도, 해당 트랜잭션은 사용하지 않는다. 대신 새로운 "중첩<sup>nested</sup>" 트랜잭션을 시작한다.

---

## `TransactionIdPrefix`

유일하게 지원하는 모드 `EOSMode.V2`(일명 `BETA`)에서는 컨슈머가 트랜잭션을 시작하는 경우에도 동일한 `transactional.id`를 사용할 필요가 없다. 사실, 프로듀서가 트랜잭션을 시작하는 경우와 마찬가지로, `transactional.id`는 반드시 모든 인스턴스마다 고유해야 한다. 즉, 이 프로퍼티는 각 애플리케이션 인스턴스마다 서로 다른 값을 가져야 한다.

---

## `TransactionIdSuffix Fixed`

3.2 버전에서 도입한 `transactionIdSuffixStrategy` 인터페이스로 `transactional.id`의 suffix를 관리할 수 있다. 디폴트 구현체는 `DefaultTransactionIdSuffixStrategy`로, `maxCache`를 0보다 큰 값으로 설정하면 특정 범위 내에서 `transactional.id`를 재사용할 수 있고, 그 외엔 그때그때 suffix 카운터를 증가시키킨다. 트랜잭션 프로듀서를 요청했는데 사용 가능한 `transactional.id`가 모두 소진된 상태라면 `NoProducerAvailableException`을 던진다. 이때는 `RetryTemplate`을 사용해 적절한 backoff 설정하면 재시도해볼 수 있다.

```java
public static class Config {

    @Bean
    public ProducerFactory<String, String> myProducerFactory() {
        Map<String, Object> configs = producerConfigs();
        configs.put(ProducerConfig.CLIENT_ID_CONFIG, "myClientId");
        ...
        DefaultKafkaProducerFactory<String, String> pf = new DefaultKafkaProducerFactory<>(configs);
        ...
        TransactionIdSuffixStrategy ss = new DefaultTransactionIdSuffixStrategy(5);
        pf.setTransactionIdSuffixStrategy(ss);
        return pf;
    }

}
```

`maxCache`를 5로 설정하면, `transactional.id`는 `my.txid.` + `{0–4}`와 같이 설정된다.

> `KafkaTransactionManager`를 `ConcurrentMessageListenerContainer`와 함께 사용하고 `maxCache`를 활성화한다면, `maxCache`는 `concurrency`보다 크거나 같게 설정해야 한다. `MessageListenerContainer`가 `transactional.id` suffix를 확보하지 못하면 `NoProducerAvailableException`이 발생한다. `ConcurrentMessageListenerContainer`에서 중첩<sup>nested</sup> 트랜잭션을 사용하는 경우, 그만큼 늘어난 트랜잭션을 처리할 수 있도록 `maxCache` 값을 조정해야 한다.

---

## `KafkaTemplate` Transactional and non-Transactional Publishing

일반적으로 `KafkaTemplate`에 트랜잭션을 활성화했다면 (트랜잭션이 가능한 프로듀서 팩토리를 설정했다면), 트랜잭션이 있어야만 동작을 실행할 수 있다. 트랜잭션은 `TransactionTemplate`으로 시작할 수도 있고, `@Transactional` 메소드나 `executeInTransaction` 호출, 혹은 `KafkaTransactionManager`를 설정한 리스너 컨테이너로도 시작할 수 있다. 트랜잭션 범위 밖에서 템플릿을 사용하려고 하면, 템플릿은 `IllegalStateException`을 던진다. 2.4.3 버전부터는 템플릿의 `allowNonTransactional` 프로퍼티를 `true`로 설정할 수 있는데, 이 경우 템플릿은 `ProducerFactory`의 `createNonTransactionalProducer()` 메소드를 호출하고, 트랜잭션 없이도 동작할 수 있게 된다. 이때 프로듀서는 일반적인 방식 그대로 캐시에 저장하거나 스레드에 묶어 재사용한다. 자세한 내용은 [`DefaultKafkaProducerFactory 사용하기`](../sending-messages/#using-defaultkafkaproducerfactory)를 참고해라.

---

## Transactions with Batch Listeners

트랜잭션이 진행 중일 때 리스너가 실패하면, `AfterRollbackProcessor`이 실행돼 롤백 이후 필요한 조치를 취할 수 있다. 레코드 리스너와 디폴트 `AfterRollbackProcessor`를 사용할 땐, 오프셋을 되돌려<sup>seek</sup> 실패한 레코드를 다시 전달한다. 반면 배치 리스너에서는 배치 내 어떤 레코드가 실패했는지 프레임워크가 판단할 수 없기 때문에 전체 배치를 다시 전달한다. 자세한 내용은 [After-rollback Processor](../annotation-error-handling/#after-rollback-processor)을 참고해라.

배치 리스너를 사용 중이라면, 2.4.2 버전에서 배치 처리에 실패할 경우 실행할 수 있는 다른 대안으로 `BatchToRecordAdapter`를 도입했다. `batchListener`를 true로 설정한 컨테이너 팩토리에 `BatchToRecordAdapter`를 설정해두면, 레코드 하나당 리스너를 한 번 호출한다. 덕분에 배치 내에서 에러를 처리할 수 있으며, 예외 타입에 따라 배치 전체의 처리를 중단하는 것도 가능하다. 기본으로 제공하는 디폴트 `BatchToRecordAdapter`에서는 `DeadLetterPublishingRecoverer` 등의 표준 `ConsumerRecordRecoverer`를 설정할 수 있다. 그 방법은 아래 설정을 참고해라:

```java
public static class TestListener {

    final List<String> values = new ArrayList<>();

    @KafkaListener(id = "batchRecordAdapter", topics = "test")
    public void listen(String data) {
        values.add(data);
        if ("bar".equals(data)) {
            throw new RuntimeException("reject partial");
        }
    }

}

@Configuration
@EnableKafka
public static class Config {

    ConsumerRecord<?, ?> failed;

    @Bean
    public TestListener test() {
        return new TestListener();
    }

    @Bean
    public ConsumerFactory<?, ?> consumerFactory() {
        return mock(ConsumerFactory.class);
    }

    @Bean
    public ConcurrentKafkaListenerContainerFactory<String, String> kafkaListenerContainerFactory() {
        ConcurrentKafkaListenerContainerFactory factory = new ConcurrentKafkaListenerContainerFactory();
        factory.setConsumerFactory(consumerFactory());
        factory.setBatchListener(true);
        factory.setBatchToRecordAdapter(new DefaultBatchToRecordAdapter<>((record, ex) ->  {
            this.failed = record;
        }));
        return factory;
    }

}
```