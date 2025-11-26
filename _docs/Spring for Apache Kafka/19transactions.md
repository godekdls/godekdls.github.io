---
title: Transactions
category: Spring for Apache Kafka
order: 20
permalink: /Spring for Apache Kafka/transactions/
description: todo
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

스프링 부트를 사용한다면 `spring.kafka.producer.transaction-id-prefix` 프로퍼티만 설정해주면면 된다. 그러면 스프링 부트가 자동으로 `KafkaTransactionManager` 빈을 설정하고 리스너 컨테이너에 주입해준다.

> 2.5.8 버전부터는 프로듀서 팩토리에 `maxAge` 프로퍼티를 설정할 수 있다. 브로커의 `transactional.id.expiration.ms` 동안 트랜잭션 프로듀서가 유휴<sup>idle</sup> 상태로 머무를 수 있는 경우 이 프로퍼티를 이용하면 된다. 현재 `kafka-clients`에서는 이러한 상황이 생기면 리밸런싱 없이도 `ProducerFencedException`이 발생할 수 있다. `maxAge`를 `transactional.id.expiration.ms`보다 작게 설정하면, 팩토리는 프로듀서가 max age를 초과할 경우 프로듀서를 갱신한다.

---

## Using `KafkaTransactionManager`

`KafkaTransactionManager`는 스프링 프레임워크의 `PlatformTransactionManager` 구현체다. `KafkaTransactionManager`는 생성자를 통해 프로듀서 팩토리의 참조를 넘겨받는다. 만약 커스텀 프로듀서 팩토리를 넘긴다면, 해당 팩토리는 반드시 트랜잭션을 지원해야 한다. `ProducerFactory.transactionCapable()`을 참고해라.

`KafkaTransactionManager`는 스프링의 표준 트랜잭션 메커니즘과 함께 사용할 수 있다 (`@Transactional`, `TransactionTemplate` 등). 트랜잭션을 활성화하면, 트랜잭션 범위 내에서 실행되는 `KafkaTemplate` 작업은 모두 현재 트랜잭션의 `Producer`를 사용한다. 트랜잭션 매니저는 성공 여부에 따라 트랜잭션을 커밋하거나 롤백한다. 이때 `KafkaTemplate`은 반드시 트랜잭션 매니저와 동일한 `ProducerFactory`를 사용하도록 설정해야 한다.

---

## Transaction Synchronization

This section refers to producer-only transactions (transactions not started by a listener container); see [Using Consumer-Initiated Transactions](#using-consumer-initiated-transactions) for information about chaining transactions when the container starts the transaction.

이번 섹션에선 프로듀서 전용 트랜잭션을 설명한다 (즉, 리스너 컨테이너가 트랜잭션을 시작하지 않는다). 컨테이너가 트랜잭션을 시작하는 경우 트랜잭션을 체이닝하는 방식은 [컨슈머가 시작한 트랜잭션 사용하기](#using-consumer-initiated-transactions)를 참고해라.

If you want to send records to kafka and perform some database updates, you can use normal Spring transaction management with, say, a `DataSourceTransactionManager`.

```java
@Transactional
public void process(List<Thing> things) {
    things.forEach(thing -> this.kafkaTemplate.send("topic", thing));
    updateDb(things);
}
```

The interceptor for the `@Transactional` annotation starts the transaction and the `KafkaTemplate` will synchronize a transaction with that transaction manager; each send will participate in that transaction. When the method exits, the database transaction will commit followed by the Kafka transaction. If you wish the commits to be performed in the reverse order (Kafka first), use nested `@Transactional` methods, with the outer method configured to use the `DataSourceTransactionManager`, and the inner method configured to use the `KafkaTransactionManager`.

See [Examples of Kafka Transactions with Other Transaction Managers](https://docs.spring.io/spring-kafka/reference/tips.html#ex-jdbc-sync) for examples of an application that synchronizes JDBC and Kafka transactions in Kafka-first or DB-first configurations.

> Starting with versions 2.5.17, 2.6.12, 2.7.9 and 2.8.0, if the commit fails on the synchronized transaction (after the primary transaction has committed), the exception will be thrown to the caller. Previously, this was silently ignored (logged at debug level). Applications should take remedial action, if necessary, to compensate for the committed primary transaction.

---

## Using Consumer-Initiated Transactions

`ChainedKafkaTransactionManager`는 2.7버전부터 deprecated되었다. 상위 클래스 `ChainedTransactionManager`에 대한 자세한 내용은 JavaDoc을 확인해봐라. 이대신, 카프카 트랜잭션은 컨테이너에서 `KafkaTransactionManager`로 시작하고, 그 외 다른 트랜잭션은 리스너 메소드에 `@Transactional`을 선언하면 된다.

JDBC 트랜잭션과 Kafka 트랜잭션을 연결하는 예시는 [다른 트랜잭션 매니저와 함께 사용하는 카프카 트랜잭션 예시](https://docs.spring.io/spring-kafka/reference/tips.html#ex-jdbc-sync)를 참고해라.

> Non-Blocking Retries는 [컨테이너 트랜잭션](#using-consumer-initiated-transactions)과 함께 사용할 수 없다. 리스너 코드에서 예외를 던지면, 컨테이너 트랜잭션은 커밋에 성공하고, 해당 레코드는 retryable 토픽으로 전송된다.

---

## `KafkaTemplate` Local Transactions

You can use the `KafkaTemplate` to execute a series of operations within a local transaction. The following example shows how to do so:

```java
boolean result = template.executeInTransaction(t -> {
    t.sendDefault("thing1", "thing2");
    t.sendDefault("cat", "hat");
    return true;
});
```

The argument in the callback is the template itself (`this`). If the callback exits normally, the transaction is committed. If an exception is thrown, the transaction is rolled back.

> If there is a `KafkaTransactionManager` (or synchronized) transaction in process, it is not used. Instead, a new "nested" transaction is used.

---

## `TransactionIdPrefix`

With `EOSMode.V2` (aka `BETA`), the only supported mode, it is no longer necessary to use the same `transactional.id`, even for consumer-initiated transactions; in fact, it must be unique on each instance the same as for producer-initiated transactions. This property must have a different value on each application instance.

---

## `TransactionIdSuffix Fixed`

Since 3.2, a new `TransactionIdSuffixStrategy` interface was introduced to manage `transactional.id` suffix. The default implementation is `DefaultTransactionIdSuffixStrategy` when setting `maxCache` greater than zero can reuse `transactional.id` within a specific range, otherwise suffixes will be generated on the fly by incrementing a counter. When a transaction producer is requested and `transactional.id` all in use, throw a `NoProducerAvailableException`. User can then use a `RetryTemplate` configured to retry that exception, with a suitably configured back off.

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

When setting `maxCache` to 5, `transactional.id` is `my.txid.`+`{0-4}`.

> When using `KafkaTransactionManager` with the `ConcurrentMessageListenerContainer` and enabling `maxCache`, it is necessary to set `maxCache` to a value greater than or equal to `concurrency`. If a `MessageListenerContainer` is unable to acquire a `transactional.id` suffix, it will throw a `NoProducerAvailableException`. When using nested transactions in the `ConcurrentMessageListenerContainer`, it is necessary to adjust the maxCache setting to handle the increased number of nested transactions.

---

## `KafkaTemplate` Transactional and non-Transactional Publishing

Normally, when a `KafkaTemplate` is transactional (configured with a transaction-capable producer factory), transactions are required. The transaction can be started by a `TransactionTemplate`, a `@Transactional` method, calling `executeInTransaction`, or by a listener container, when configured with a `KafkaTransactionManager`. Any attempt to use the template outside the scope of a transaction results in the template throwing an `IllegalStateException`. Starting with version 2.4.3, you can set the template’s `allowNonTransactional` property to `true`. In that case, the template will allow the operation to run without a transaction, by calling the `ProducerFactory`'s `createNonTransactionalProducer()` method; the producer will be cached, or thread-bound, as normal for reuse. See [Using `DefaultKafkaProducerFactory`](https://docs.spring.io/spring-kafka/reference/kafka/sending-messages.html#producer-factory).

---

## Transactions with Batch Listeners

When a listener fails while transactions are being used, the `AfterRollbackProcessor` is invoked to take some action after the rollback occurs. When using the default `AfterRollbackProcessor` with a record listener, seeks are performed so that the failed record will be redelivered. With a batch listener, however, the whole batch will be redelivered because the framework doesn’t know which record in the batch failed. See [After-rollback Processor](https://docs.spring.io/spring-kafka/reference/kafka/annotation-error-handling.html#after-rollback) for more information.

When using a batch listener, version 2.4.2 introduced an alternative mechanism to deal with failures while processing a batch: `BatchToRecordAdapter`. When a container factory with `batchListener` set to true is configured with a `BatchToRecordAdapter`, the listener is invoked with one record at a time. This enables error handling within the batch, while still making it possible to stop processing the entire batch, depending on the exception type. A default `BatchToRecordAdapter` is provided, that can be configured with a standard `ConsumerRecordRecoverer` such as the `DeadLetterPublishingRecoverer`. The following test case configuration snippet illustrates how to use this feature:

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