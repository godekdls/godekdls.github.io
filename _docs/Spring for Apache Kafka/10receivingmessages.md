---
title: Receiving Messages
category: Spring for Apache Kafka
order: 11
permalink: /Spring for Apache Kafka/receiving-messages/
description: 스프링 카프카로 메시지 수신하기
image: ./../../images/spring/logo.png
lastmod: 2025-09-12T23:34:00+09:00
comments: true
originalRefName: 스프링 카프카
originalRefLink: https://docs.spring.io/spring-kafka/reference/3.3.10/receiving-messages.html
parent: Reference
parentUrl: /Spring for Apache Kafka/reference/
subparent: Using Spring for Apache Kafka
subparentUrl: /Spring for Apache Kafka/kafka/
---

---

메시지를 수신하려면, `MessageListenerContainer`를 설정하고 메시지 리스너를 제공하거나, `@KafkaListener` 어노테이션을 이용하면 된다.

### 목차

- [Message Listeners](#message-listeners)
- [Message Listener Containers](#message-listener-containers) 
  + [Using `KafkaMessageListenerContainer`](#using-kafkamessagelistenercontainer)
  + [Using `ConcurrentMessageListenerContainer`](#using-concurrentmessagelistenercontainer)
  + [Committing Offsets](#committing-offsets)
  + [Listener Container Auto Startup](#listener-container-auto-startup)
- [Manually Committing Offsets](#manually-committing-offsets)
- [Asynchronous `@KafkaListener` Return Types](#asynchronous-kafkalistener-return-types)
- [`@KafkaListener` Annotation](#kafkalistener-annotation)
  + [Record Listeners](#record-listeners)
  + [Explicit Partition Assignment](#explicit-partition-assignment)
  + [Manual Acknowledgment](#manual-acknowledgment)
  + [Consumer Record Metadata](#consumer-record-metadata)
  + [Batch Listeners](#batch-listeners)
  + [Annotation Properties](#annotation-properties)
- [Obtaining the Consumer `group.id`](#obtaining-the-consumer-groupid)
- [Container Thread Naming](#container-thread-naming)
- [`@KafkaListener` as a Meta Annotation](#kafkalistener-as-a-meta-annotation)
- [`@KafkaListener` on a Class](#kafkalistener-on-a-class)
- [`@KafkaListener` Attribute Modification](#kafkalistener-attribute-modification)
- [`@KafkaListener` Lifecycle Management](#kafkalistener-lifecycle-management)
  + [Retrieving MessageListenerContainers from KafkaListenerEndpointRegistry](#retrieving-messagelistenercontainers-from-kafkalistenerendpointregistry)
- [`@KafkaListener` `@Payload` Validation](#kafkalistener-payload-validation)
- [Rebalancing Listeners](#rebalancing-listeners)
- [Enforcing Consumer Rebalance](#enforcing-consumer-rebalance)
- [Forwarding Listener Results using `@SendTo`](#forwarding-listener-results-using-sendto)
- [Filtering Messages](#filtering-messages)
- [Retrying Deliveries](#retrying-deliveries)
- [Starting `@KafkaListener`s in Sequence](#starting-kafkalisteners-in-sequence)
- [Using `KafkaTemplate` to Receive](#using-kafkatemplate-to-receive)

---

## Message Listeners

[메시지 리스너 컨테이너](#message-listener-containers)를 사용할 때는 데이터를 수신할 리스너를 제공해야 한다. 현재는 지원하는 메시지 리스너 인터페이스는 총 여덟 가지가 있다. 이 인터페이스 목록은 아래에서 확인할 수 있다:

```java
public interface MessageListener<K, V> { // (1)

    void onMessage(ConsumerRecord<K, V> data);

}

public interface AcknowledgingMessageListener<K, V> { // (2)

    void onMessage(ConsumerRecord<K, V> data, Acknowledgment acknowledgment);

}

public interface ConsumerAwareMessageListener<K, V> extends MessageListener<K, V> { // (3)

    void onMessage(ConsumerRecord<K, V> data, Consumer<?, ?> consumer);

}

public interface AcknowledgingConsumerAwareMessageListener<K, V> extends MessageListener<K, V> { // (4)

    void onMessage(ConsumerRecord<K, V> data, Acknowledgment acknowledgment, Consumer<?, ?> consumer);

}

public interface BatchMessageListener<K, V> { // (5)

    void onMessage(List<ConsumerRecord<K, V>> data);

}

public interface BatchAcknowledgingMessageListener<K, V> { // (6)

    void onMessage(List<ConsumerRecord<K, V>> data, Acknowledgment acknowledgment);

}

public interface BatchConsumerAwareMessageListener<K, V> extends BatchMessageListener<K, V> { // (7)

    void onMessage(List<ConsumerRecord<K, V>> data, Consumer<?, ?> consumer);

}

public interface BatchAcknowledgingConsumerAwareMessageListener<K, V> extends BatchMessageListener<K, V> { // (8)

    void onMessage(List<ConsumerRecord<K, V>> data, Acknowledgment acknowledgment, Consumer<?, ?> consumer);

}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 자동 커밋을 사용 중이거나, [컨테이너에 커밋을 맡기고](#committing-offsets) 있다면, 이 인터페이스를 사용해 카프카 컨슈머의 `poll()` 메소드로 수신한 각 `ConsumerRecord` 인스턴스를 처리해라.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 수동 [커밋 방식](#committing-offsets) 중 하나를 사용 중이라면, 이 인터페이스를 사용해 카프카 컨슈머의 `poll()` 메소드로 수신한 각 `ConsumerRecord` 인스턴스를 처리해라.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 자동 커밋을 사용 중이거나, [컨테이너에 커밋을 맡기고](#committing-offsets) 있다면, 이 인터페이스를 사용해 카프카 컨슈머의 `poll()` 메소드로 수신한 각 `ConsumerRecord` 인스턴스를 처리해라. 이 인터페이스를 사용하면 `Consumer` 객체에 접근할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> 수동 [커밋 방식](#committing-offsets) 중 하나를 사용 중이라면, 이 인터페이스를 사용해 카프카 컨슈머의 `poll()` 메소드로 수신한 각 `ConsumerRecord` 인스턴스를 처리해라. 이 인터페이스를 사용하면 `Consumer` 객체에 접근할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> 자동 커밋을 사용 중이거나, [컨테이너에 커밋을 맡기고](#committing-offsets) 있다면, 이 인터페이스를 사용해 카프카 컨슈머의 `poll()` 메소드로 수신한 모든 `ConsumerRecord` 인스턴스를 처리해라. 이 인터페이스를 사용할 때는 리스너에서 전체 배치를 전달받기 때문에 `AckMode.RECORD`는 지원하지 않는다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(6)</span> 수동 [커밋 방식](#committing-offsets) 중 하나를 사용 중이라면, 이 인터페이스를 사용해 카프카 컨슈머의 `poll()` 메소드로 수신한 모든 `ConsumerRecord` 인스턴스를 처리해라.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(7)</span> 자동 커밋을 사용 중이거나, [컨테이너에 커밋을 맡기고](#committing-offsets) 있다면, 이 인터페이스를 사용해 카프카 컨슈머의 `poll()` 메소드로 수신한 모든 `ConsumerRecord` 인스턴스를 처리해라. 이 인터페이스를 사용할 때는 리스너에서 전체 배치를 전달받기 때문에 `AckMode.RECORD`는 지원하지 않는다. `Consumer` 객체에는 접근할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(8)</span> 수동 [커밋 방식](#committing-offsets) 중 하나를 사용 중이라면, 이 인터페이스를 사용해 카프카 컨슈머의 `poll()` 메소드로 수신한 모든 `ConsumerRecord` 인스턴스를 처리해라. `Consumer` 객체에 접근할 수 있다.</small>

> `Consumer` 객체는 스레드로부터 안전<sup>thread-safe</sup>하지 않다. 이 메소드들은 리스너를 호출하는 스레드에서만 호출해야 한다.

> 리스너 안에서 컨슈머의 위치나 커밋 오프셋에 영향을 줄 수 있는 `Consumer<?, ?>` 메소드를 실행해서는 안 된다. 이러한 정보는 컨테이너에서 관리해야 한다.

---

## Message Listener Containers

두 가지 `MessageListenerContainer` 구현체를 제공한다:

- `KafkaMessageListenerContainer`
- `ConcurrentMessageListenerContainer`

`KafkaMessageListenerContainer`는 단일 스레드 내에서 모든 토픽(또는 파티션)의 메시지를 전부 수신한다. `ConcurrentMessageListenerContainer`는 하나 이상의 `KafkaMessageListenerContainer` 인스턴스에 메시지 수신을 위임해서 멀티 스레드 컨슈밍이 가능하다.

2.2.7 버전부터 리스너 컨테이너에 `RecordInterceptor`를 추가할 수 있다. 이 인터셉터는 리스너 호출 전에 실행되므로, 레코드를 검사하거나 수정할 수 있다. 인터셉터에서 null을 반환하면 리스너는 실행되지 않는다. 2.7 버전부터는 리스너가 종료된 후(정상 종료했을 때와 예외를 던졌을 때 모두) 호출되는 별도 메소드를 제공한다. 또한 2.7 버전부터는 [배치 리스너](#batch-listeners)에 대해 유사한 기능을 제공하는 `BatchInterceptor`가 추가됐다. `ConsumerAwareRecordInterceptor`를 사용하면 `Consumer<?, ?>`에 접근할 수 있다 (`BatchInterceptor`도 마찬가지다). 이는 인터셉터 안에서 컨슈머 메트릭에 접근하는 식으로 활용할 수 있다.

> 이런 인터셉터 안에서는 컨슈머의 위치나 커밋 오프셋에 영향을 줄 수 있는 메소드를 실행해서는 안 된다. 이러한 정보는 컨테이너에서 관리해야 한다.

> 인터셉터에서 레코드를 변경하는 경우 (새로 만드는 식으로), `topic`, `partition`, `offset`은 동일하게 유지해야만 레코드 손실과 같은 예상치 못한 부작용을 방지할 수 있다.

`CompositeRecordInterceptor`와 `CompositeBatchInterceptor`를 사용하면 여러 인터셉터를 호출할 수 있다.

2.8 버전부터 기본적으로 트랜잭션을 실행한다면 트랜잭션을 시작하기 전에 인터셉터를 호출한다. 리스너 컨테이너의 `interceptBeforeTx` 프로퍼티를 `false`로 설정하면 트랜잭션 시작 전이 아닌 후에 인터셉터를 호출한다. 2.9 버전부터 이 설정은 `KafkaAwareTransactionManager`뿐만 아니라 다른 모든 트랜잭션 매니저에도 적용된다. 덕분에 컨테이너가 JDBC 트랜잭션 등을 시작하면 인터셉터에서도 관련 로직을 실행할 수 있다.

2.3.8, 2.4.6 버전부터는 `ConcurrentMessageListenerContainer`의 concurrency 값을 1보다 크게 지정하면 [스태틱 멤버십](.././Apache%20Kafka/design/#static-membership)을 사용할 수 있다. `group.instance.id` 뒤에는 `-n`이 붙는데, 여기서 `n`은 `1`부터 시작하는 값이다. `session.timeout.ms`를 늘리고 이를 잘 활용하면 애플리케이션 인스턴스를 재시작하는 상황 등에서 리밸런스 이벤트를 줄일 수 있다.

### Using `KafkaMessageListenerContainer`

`KafkaMessageListenerContainer`는 다음과 같은 생성자를 제공한다:

```java
public KafkaMessageListenerContainer(ConsumerFactory<K, V> consumerFactory,
                    ContainerProperties containerProperties)
```

이 생성자는 `ConsumerFactory`와 토픽 및 파티션에 대한 정보, 그리고 기타 다른 설정들을 `ContainerProperties` 객체로 넘겨받는다. `ContainerProperties`에는 다음과 같은 생성자가 존재한다:

```java
public ContainerProperties(TopicPartitionOffset... topicPartitions)

public ContainerProperties(String... topics)

public ContainerProperties(Pattern topicPattern)
```

첫 번째 생성자는 `TopicPartitionOffset` 배열을 인자로 넘겨, 컨테이너에서 사용할 파티션과 (컨슈머의 `assign()` 메소드로 할당한다), 초기 오프셋을 지정할 수 있다 (생략 가능). 오프셋 값에 양수를 지정하면 오프셋 그 자체로 간주한다. 음수 값을 지정하면 기본적으로 파티션 내에서 현재 세팅된 마지막 오프셋을 기준으로 한 상대 오프셋을 의미한다. `boolean` 인자를 추가로 넘길 수 있는 `TopicPartitionOffset` 생성자도 제공한다. `true`로 넘기면 초기 오프셋을 (양수이든 음수이든) 해당 컨슈머의 현재 위치에 대한 상대적인 오프셋으로 계산한다. 이 오프셋은 컨테이너를 시작할 때 적용한다. 두 번째 생성자는 토픽 배열을 받는데, 이때 카프카는 `group.id` 프로퍼티를 기반으로 파티션을 할당한다 (그룹 전체에 파티션을 분산시킨다). 세 번째 생성자는 정규식 `Pattern`을 이용해 토픽을 선택한다.

컨테이너에 `MessageListener`를 할당하려면 컨테이너를 생성할 때 `ContainerProps.setMessageListener` 메소드를 사용하면 된다. 다음 예제를 참고해라:

```java
ContainerProperties containerProps = new ContainerProperties("topic1", "topic2");
containerProps.setMessageListener(new MessageListener<Integer, String>() {
    ...
});
DefaultKafkaConsumerFactory<Integer, String> cf =
                        new DefaultKafkaConsumerFactory<>(consumerProps());
KafkaMessageListenerContainer<Integer, String> container =
                        new KafkaMessageListenerContainer<>(cf, containerProps);
return container;
```

위와 같이 프로퍼티를 전달받는 생성자를 이용해 `DefaultKafkaConsumerFactory`를 생성하면, 설정에 따라 키/값 `Deserializer` 클래스를 가져온다. 아니면 `Deserializer` 인스턴스를 `DefaultKafkaConsumerFactory` 생성자에 전달해도 되는데, 이 경우 모든 컨슈머가 동일한 인스턴스를 공유하게 된다. 또 다른 옵션은 각 `Consumer`에 대해 별도의 `Deserializer` 인스턴스를 얻는 데 사용될 `Supplier<Deserializer>`를 제공하는 거다 (버전 2.3부터 지원됨):

```java
DefaultKafkaConsumerFactory<Integer, CustomValue> cf =
                        new DefaultKafkaConsumerFactory<>(consumerProps(), null, () -> new CustomValueDeserializer());
KafkaMessageListenerContainer<Integer, String> container =
                        new KafkaMessageListenerContainer<>(cf, containerProps);
return container;
```

설정 가능한 다양한 프로퍼티들은 `ContainerProperties`의 [Javadoc](https://docs.spring.io/spring-kafka/api/org/springframework/kafka/listener/ContainerProperties.html)에 자세히 나와있다.

2.1.1 버전부터 `logContainerConfig`라는 새로운 프로퍼티를 사용할 수 있다. `true`로 설정하고 `INFO` 로그를 활성화해두면, 모든 리스너 컨테이너가 자체 설정 프로퍼티를 요약한 메시지를 로그로 남긴다.

기본적으로 토픽 오프셋의 커밋 로그는 `DEBUG` 레벨로 남긴다. 2.1.2 버전부터 `ContainerProperties`의 `commitLogLevel` 프로퍼티를 이용하면 관련 로그의 레벨을 변경할 수 있다. 예를 들어 로그 레벨을 `INFO`로 변경하려면 `containerProperties.setCommitLogLevel(LogIfLevelEnabled.Level.INFO);`를 사용하면 된다.

2.2 버전부터 `missingTopicsFatal`이라는 새로운 컨테이너 프로퍼티가 추가됐다 (2.3.4부터 `false`가 기본값이다). 이 프로퍼티는 설정한 토픽 중 하나라도 브로커에 존재하지 않는 토픽이 있다면 컨테이너를 시작하지 않도록 만든다. 컨테이너가 토픽 패턴(정규식)을 컨슘하도록 설정한 경우에는 적용되지 않는다. 이전에는 컨테이너 스레드가 토픽이 생길 때까지 `consumer.poll()`을 반복하며 많은 로그를 남겼었는데, 이 로그를 확인하지 않는 이상 문제를 인지하기 어려웠었다.

2.8 버전부터 새로운 컨테이너 프로퍼티 `authExceptionRetryInterval`을 도입했다. 이 프로퍼티는 `KafkaConsumer`에서 `AuthenticationException`이나 `AuthorizationException`이 발생한 경우 메시지 수신을 재시도하도록 만든다. 예를 들어, 설정한 user 정보가 특정 토픽에 대한 읽기 권한이 없거나 자격 증명이 잘못된 경우 이러한 예외가 발생할 수 있다. 이때 `authExceptionRetryInterval`을 정의했다면, 필요한 권한만 부여하면 컨테이너를 복구할 수 있다.

> 인터벌은 기본적으로 설정되어있지 않다. 인증<sup>authentication</sup> 및 인가<sup>authorization</sup> 오류는 치명적인 에러로 간주하고 컨테이너를 중지시킨다.

2.8 버전부터 컨슈머 팩토리를 생성할 때 deserializer 객체를 제공하면 (생성자나 setter 메소드를 통해), 팩토리는 `configure()` 메소드를 호출해서 넘겨받은 설정 프로퍼티로 해당 deserializer를 세팅한다.

### Using `ConcurrentMessageListenerContainer`

단일 생성자는 `KafkaListenerContainer`의 생성자와 유사하다. 다음은 생성자의 메소드 시그니처다:

```java
public ConcurrentMessageListenerContainer(ConsumerFactory<K, V> consumerFactory,
                            ContainerProperties containerProperties)
```

가장 큰 특징은 `concurrency` 프로퍼티를 받는다는 점이다. 예를 들어, `container.setConcurrency(3)`은 세 개의 `KafkaMessageListenerContainer` 인스턴스를 생성한다.

컨테이너 프로퍼티에 토픽(또는 토픽 패턴)을 설정하면, 카프카는 그룹 관리<sup>group management</sup> 기능을 이용해 컨슈머들 간에 파티션을 분배한다.

> 여러 토픽을 수신하는 경우, 기본 파티션 분배 방식이 생각한 것과 다를 수 있다. 예를 들어, 각각 5개의 파티션이 있는 세 가지 토픽이 있을 때 `concurrency=15`를 사용한다면, 활성 컨슈머는 각 토픽의 파티션이 하나씩 할당된 5개 뿐이고, 나머지 10개의 컨슈머는 유휴 상태로 유지되는 걸 확인할 수 있다. 이는 카프카의 기본 `ConsumerPartitionAssignor`가 `RangeAssignor`이기 때문이다 (Javadoc 참고). 이 경우 모든 컨슈머에 고르게 파티션을 분배하는 `RoundRobinAssignor`를 고려해 볼 수 있다. `RoundRobinAssignor`를 사용하면 모든 컨슈머에게 하나의 토픽(또는 하나의 파티션)이 할당된다. `ConsumerPartitionAssignor`를 변경하려면, `DefaultKafkaConsumerFactory`에 전달하는 프로퍼티에 컨슈머 프로퍼티 `partition.assignment.strategy`(`ConsumerConfig.PARTITION_ASSIGNMENT_STRATEGY_CONFIG`)를 설정하면 된다. 스프링 부트를 사용 중이라면 다음과 같이 strategy를 변경할 수 있다:
>
> ```properties
> spring.kafka.consumer.properties.partition.assignment.strategy=\
> org.apache.kafka.clients.consumer.RoundRobinAssignor
> ```

컨테이너 프로퍼티에 `TopicPartitionOffset`을 설정하면, `ConcurrentMessageListenerContainer`는 메시지 수신을 위임하는 `KafkaMessageListenerContainer` 인스턴스들에 `TopicPartitionOffset` 인스턴스를 분배한다.

예를 들어, `TopicPartitionOffset` 인스턴스를 6개 제공하고 `concurrency`를 `3`으로 설정했다면, 각각의 컨테이너는 두 개의 파티션을 위임받는다. `TopicPartitionOffset` 인스턴스가 5개였다면, 두 컨테이너는 각각 두 개의 파티션을 위임받고, 세 번째 컨테이너는 하나의 파티션을 위임받는다. `concurrency`가 `TopicPartitions`의 수보다 클 경우, 모든 컨테이너가 하나의 파티션을 받을 수 있도록 `concurrency`를 하향한다.

> `client.id` 프로퍼티(설정한 경우) 뒤에는 concurrency 설정에 따라 생성된 컨슈머 인스턴스를 구분하기 위해 `-n`을 붙인다. 이는 JMX를 활성화했을 때 MBean에 고유한 이름을 제공하기 위해 필요하다.

1.3 버전부터 `MessageListenerContainer`를 통해 내부 `KafkaConsumer`의 메트릭에 접근할 수 있다. `ConcurrentMessageListenerContainer`의 경우, `metrics()` 메소드는 모든 타켓 `KafkaMessageListenerContainer` 인스턴스에 대한 메트릭을 반환한다. 메트릭은 내부 `KafkaConsumer`에 설정된 `client-id`에 따라 `Map<MetricName, ? extends Metric>`으로 그룹을 분류한다.

2.3 버전부터 `ContainerProperties`는 `idleBetweenPolls` 옵션을 제공해서, 리스너 컨테이너의 메인 루프에서 `KafkaConsumer.poll()`을 호출하기 전 잠시 대기할 수 있다. 실제 sleep 인터벌은 지정한 옵션과, 컨슈머 설정 `max.poll.interval.ms` 값과 현재 레코드 배치 처리 시간의 차이 중 작은 값이 적용된다.

### Committing Offsets

오프셋 커밋을 위한 여러 가지 옵션을 제공한다. 컨슈머 프로퍼티 `enable.auto.commit`이 `true`이면 카프카는 설정에 맞게 오프셋을 자동 커밋한다. `false`이면 컨테이너의 몇 가지 `AckMode` 설정(이어서 설명한다)을 사용할 수 있다. 디폴트 `AckMode`는 `BATCH`다. 2.3 버전부터는 설정을 명시하지 않으면 프레임워크에선 `enable.auto.commit`을 `false`로 설정한다. 이전에는 이 프로퍼티를 따로 설정하지 않은 경우 카프카 기본값(`true`)을 사용했었다.

컨슈머 `poll()` 메소드는 하나 이상의 `ConsumerRecords`를 반환하며, 각 레코드마다 `MessageListener`를 호출한다. 각 `AckMode`에서 컨테이너가 수행하는 작업은 다음과 같다 (트랜잭션을 사용하지 않는 경우):

- `RECORD`: 리스너가 레코드를 처리한 후 반환될 때 오프셋을 커밋한다.
- `BATCH`: `poll()`이 반환한 모든 레코드를 처리한 후 오프셋을 커밋한다.
- `TIME`: `poll()`이 반환한 모든 레코드를 처리한 후, 마지막 커밋 이후 `ackTime`만큼 시간이 경과한 경우에만 오프셋을 커밋한다.
- `COUNT`: `poll()`이 반환한 모든 레코드를 처리한 후, 마지막 커밋 이후 `ackCount` 만큼의 레코드를 수신한 경우에만 오프셋을 커밋한다.
- `COUNT_TIME`: `TIME` 및 `COUNT`와 유사하지만, 두 조건 중 하나라도 `true`면 커밋한다.
- `MANUAL`: 메시지 리스너가 `Acknowledgment`의 `acknowledge()`를 직접 호출해야 한다. 그 이후에는 `BATCH`와 동일하게 동작한다.
- `MANUAL_IMMEDIATE`: 리스너가 `Acknowledgment.acknowledge()` 메소드를 호출할 때 오프셋을 즉시 커밋한다.

[트랜잭션](https://docs.spring.io/spring-kafka/reference/kafka/transactions.html)을 사용한다면 오프셋은 트랜잭션으로 전달되며, 리스너 타입에 따라 `RECORD` 또는 `BATCH`와 동일하게 동작한다.

> `MANUAL`과 `MANUAL_IMMEDIATE`는 리스너가 `AcknowledgingMessageListener` 또는 `BatchAcknowledgingMessageListener`일 때만 가능하다. [메시지 리스너](#message-listeners)를 참고해라.

컨슈머는 컨테이너 프로퍼티 `syncCommits`에 따라 `commitSync()` 또는 `commitAsync()` 메소드를 사용한다. `syncCommits`의 기본값은 `true`다. `setSyncCommitTimeout`도 함께 참고해라. 비동기로 커밋한 결과를 전달받고 싶다면 `setCommitCallback`을 확인해봐라. 디폴트 콜백은 에러를 로그로 남기는 (성공 시엔 디버그 레벨로) `LoggingCommitCallback`이다.

리스너 컨테이너는 자체 오프셋 커밋 메커니즘을 가지고 있기 때문에, 카프카의 `ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG`는 `false`로 설정하는 것이 좋다. 2.3 버전부터는 컨슈머 팩토리에 명시하거나 컨테이너의 컨슈머 프로퍼티로 재정의하지 않는 한 무조건 `false`로 세팅된다.

`Acknowledgment` 인터페이스는 다음과 같은 메소드를 가지고 있다:

```java
public interface Acknowledgment {

    void acknowledge();

}
```

리스너는 이 메소드 덕분에 오프셋 커밋 시점을 제어할 수 있다.

2.3 버전부터 `Acknowledgment` 인터페이스에는 두 가지 메소드 `nack(long sleep)`, `nack(int index, long sleep)`이 추가됐다. 첫 번째 메소드는 레코드 리스너와, 두 번째 메소드는 배치 리스너와 함께 사용한다. 리스너 유형에 맞지 않는 메소드를 호출하면 `IllegalStateException`이 발생한다.

> 배치의 일부만 커밋하려면 `nack()`을 사용해라. 트랜잭션을 사용 중일 때는 `AckMode`를 `MANUAL`로 설정해라. `nack()` 호출하면 처리를 마친 레코드의 오프셋이 트랜잭션으로 전달된다.

> `nack()`은 리스너를 실행하는 컨슈머 스레드에서만 호출할 수 있다.                                                                |

> `nack()`은 [비순차적 커밋 모드<sup>Out of Order Commits</sup>](#asynchronous-kafkalistener-return-types)에서는 사용할 수 없다.

레코드 리스너에서는, `nack()`을 호출하면 처리를 완료한 오프셋은 모두 커밋되고 마지막 폴링에서 남아 있는 레코드는 폐기하며, 처리를 완료하지 못한 레코드를 다음 `poll()`에서 다시 전달받을 수 있도록 해당 파티션의 오프셋을 되돌린다<sup>seek</sup>. `sleep` 인자를 세팅하면 레코드를 다시 전달받기 전에 컨슈머를 잠시 중단할 수 있다. 이는 `DefaultErrorHandler`를 사용하는 컨테이너가 예외를 던진 상황과 유사하다.

> `nack()`은 지정한 sleep 시간 동안 할당된 모든 파티션을 포함해 전체 리스너를 일시 중단한다.

배치 리스너를 사용할 때는, 일부 레코드 처리에 실패한 배치 안에서의 인덱스를 지정할 수 있다. `nack()`을 호출하면 이 인덱스 이전 레코드의 오프셋을 커밋하고, 실패로 인해 폐기된 레코드를 다음 `poll()`에서 다시 전달받을 수 있도록 해당 파티션의 오프셋을 되돌린다<sup>seek</sup>.

자세한 내용은 [컨테이너 에러 핸들러](https://docs.spring.io/spring-kafka/reference/kafka/annotation-error-handling.html#error-handlers)를 참고해라.

> 컨슈머는 sleep 상태에서는 일시 중지되므로, 컨슈머를 활성 상태로 유지할 수 있도록 브로커는 계속 폴링한다. 실제 sleep 시간과 그 정밀도는 컨테이너의 `pollTimeout`에 따라 결정되며, 기본값은 5초다. 최소 sleep 시간은 `pollTimeout`과 동일하며, pollTimeout의 배수 단위로만 지정된다. sleep 시간을 줄이거나 더 세밀하게 조절하고 싶다면 컨테이너의 `pollTimeout`을 줄이는 것을 검토해봐라.

3.0.10 버전부터 배치 리스너는 `Acknowledgment` 인자의 `acknowledge(index)`를 사용해 배치의 일부 오프셋만 커밋할 수 있다. 이 메소드를 호출하면 해당 인덱스의 레코드 오프셋을 커밋한다 (이전 모든 레코드도 함께). 배치의 일부를 커밋한 후 `acknowledge()`를 호출하면, 배치의 나머지 오프셋도 커밋된다. 이때는 다음과 같은 제약이 존재한다:

- `AckMode`는 `AckMode.MANUAL_IMMEDIATE`여야 한다
- 해당 메소드는 리스너 스레드에서 호출해야 한다
- 리스너는 `ConsumerRecords`를 직접 다루는 대신 `List`를 컨슘해야 한다
- 인덱스는 리스트 범위 안에 있어야 한다
- 인덱스 값은 이전에 호출했을 때 사용한 값보다 커야 한다

이러한 제약을 위반하게 되면 `acknowledge(index)`는 `IllegalArgumentException`이나 `IllegalStateException`을 던진다.

### Listener Container Auto Startup

리스너 컨테이너는 `SmartLifecycle`을 구현하고 있으며, `autoStartup`은 기본적으로 `true`다. 리스너 컨테이너는 꽤 늦은 순서로 시작되도록 설정돼있다 (`Integer.MAX-VALUE - 100`). 리스너의 데이터를 처리하는 다른 `SmartLifecycle` 컴포넌트들은 그보다 앞서 시작되어야 한다. `- 100`은 컨테이너를 시작한 이후에 다른 컴포넌트를 등록할 수 있도록 남겨둔 버퍼다.

---

## Manually Committing Offsets

일반적으로 `AckMode.MANUAL`이나 `AckMode.MANUAL_IMMEDIATE`를 사용할 때는, 카프카는 각 레코드에 대한 상태를 유지하지 않고 그룹/파티션별로 커밋된 오프셋만 유지하기 때문에, acknowledge는 반드시 순서대로 호출해야 한다. 2.8 버전부터는 컨테이너 프로퍼티 `asyncAcks`를 설정할 수 있어서, 폴링해온 레코드들의 ack를 순서와 상관 없이 처리할 수 있다. 리스너 컨테이너는 누락된 ack를 수신할 때까지 순서가 뒤바뀐 커밋<sup>out-of-order commits</sup>을  지연시킨다. 이전에 폴링한 모든 오프셋이 커밋될 때까지 컨슈머는 일시 중지된다 (새로운 레코드를 전달하지 않는다).

> 이 기능 덕분에 애플리케이션은 레코드를 비동기로 처리할 수 있지만, 메시지 처리에 실패했을 경우 메시지가 중복으로 전달될 가능성이 높아진다는 점을 이해하고 있어야 한다.

> `asyncAcks`를 활성화한 경우, [오프셋을 커밋](#committing-offsets)할 때 `nack()`(negative acknowledgments)을 사용할 수 없다.

---

## Asynchronous `@KafkaListener` Return Types

3.2 버전부터 `@KafkaListener`(및 `@KafkaHandler`)를 비동기 타입을 리턴하는 메소드에도 지정할 수 있어 응답을 비동기로 전송할 수 있다. 지원하는 반환 타입에는 `CompletableFuture<?>`, `Mono<?>`와 코틀린 `suspend` 함수가 있다.

```java
@KafkaListener(id = "myListener", topics = "myTopic")
public CompletableFuture<String> listen(String data) {
    ...
    CompletableFuture<String> future = new CompletableFuture<>();
    future.complete("done");
    return future;
}

@KafkaListener(id = "myListener", topics = "myTopic")
public Mono<Void> listen(String data) {
    ...
    return Mono.empty();
}
```

> 비동기 리턴 타입을 감지하면 `AckMode`는 자동으로 `MANUAL`로 설정되며, 순서와 무관한 커밋<sup> out-of-order commits</sup>도 가능해진다. 대신 비동기 작업이 완료되면 해당 시점에 ack가 수행된다. 비동기 처리가 에러로 끝나면, 컨테이너 에러 핸들러에 따라 메시지 복구 여부를 결정한다. 만약 리스너 메소드 내에서 비동기 결과 객체를 생성하지 못할 정도의 예외가 발생하면, **반드시** 예외를 catch해서 적절한 반환 객체를 리턴해야 메시지를 ack 처리하거나 복구할 수 있다.

비동기 리턴 타입(코틀린 suspend 함수 포함)을 가진 리스너에 `KafkaListenerErrorHandler`를 설정하면, 에러 발생 후  `KafkaListenerErrorHandler`가 실행된다.  `KafkaListenerErrorHandler`와 그 목적에 대한 자세한 내용은 [예외 처리](https://docs.spring.io/spring-kafka/reference/kafka/annotation-error-handling.html)를 참고해라.

---

## `@KafkaListener` Annotation

`@KafkaListener`은 빈 메소드를 리스너 컨테이너의 리스너로 지정하는 데 사용하는 어노테이션이다. 해당 빈은 `MessagingMessageListenerAdapter`로 래핑되며, 필요 시 메소드 파라미터에 맞게 데이터를 변환하는 컨버터 등의 다양한 기능이 세팅된다.

어노테이션 속성 대부분은 `#{…}`나 프로퍼티 플레이스홀더(`${…}`)를 사용한 SpEL로 설정할 수 있다. 자세한 내용은 [Javadoc](https://docs.spring.io/spring-kafka/api/org/springframework/kafka/annotation/KafkaListener.html)을 참고해라.

### Record Listeners

`@KafkaListener` 어노테이션을 이용하면 단순한 POJO를 리스너로 등록할 수 있다. 아래와 같이 사용할 수 있다:

```java
public class Listener {

    @KafkaListener(id = "foo", topics = "myTopic", clientIdPrefix = "myClientId")
    public void listen(String data) {
        ...
    }

}
```

이 방식은 `@Configuration` 클래스에 `@EnableKafka` 어노테이션을 선언해야 하며, 내부 `ConcurrentMessageListenerContainer`를 구성하는 데 사용하는 리스너 컨테이너 팩토리가 필요하다. 기본적으로 `kafkaListenerContainerFactory`라는 이름의 빈을 사용한다. 다음은 `ConcurrentMessageListenerContainer`를 사용하는 예제다:

```java
@Configuration
@EnableKafka
public class KafkaConfig {

    @Bean
    KafkaListenerContainerFactory<ConcurrentMessageListenerContainer<Integer, String>>
                        kafkaListenerContainerFactory() {
        ConcurrentKafkaListenerContainerFactory<Integer, String> factory =
                                new ConcurrentKafkaListenerContainerFactory<>();
        factory.setConsumerFactory(consumerFactory());
        factory.setConcurrency(3);
        factory.getContainerProperties().setPollTimeout(3000);
        return factory;
    }

    @Bean
    public ConsumerFactory<Integer, String> consumerFactory() {
        return new DefaultKafkaConsumerFactory<>(consumerConfigs());
    }

    @Bean
    public Map<String, Object> consumerConfigs() {
        Map<String, Object> props = new HashMap<>();
        props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
        ...
        return props;
    }
}
```

컨테이너 프로퍼티를 설정하려면 반드시 팩토리의 `getContainerProperties()` 메소드를 사용해야 한다. 그래야 컨테이너에 주입되는 실제 프로퍼티의 템플릿으로 사용된다.

2.1.1 버전부터 어노테이션으로 생성되는 컨슈머에 `client.id` 프로퍼티를 설정할 수 있다. concurrency 설정을 사용할 때는 `clientIdPrefix` 뒤에는 컨테이너 번호를 의미하는 `-n`을 붙인다.

2.2 버전부터는 어노테이션 자체의 속성을 통해 컨테이너 팩토리의 `concurrency`와 `autoStartup` 프로퍼티를 재정의할 수 있다. 이땐 단순 값은 물론, 프로퍼티 플레이스홀더나 SpEL 표현식도 사용할 수 있다. 아래 예시를 참고해라:

```java
@KafkaListener(id = "myListener", topics = "myTopic",
        autoStartup = "${listen.auto.start:true}", concurrency = "${listen.concurrency:3}")
public void listen(String data) {
    ...
}
```

### Explicit Partition Assignment

POJO 리스너에는 토픽과 파티션도 명시할 수 있다 (원한다면 초기 오프셋도). 아래 예제를 참고해라:

```java
@KafkaListener(id = "thing2", topicPartitions =
        { @TopicPartition(topic = "topic1", partitions = { "0", "1" }),
          @TopicPartition(topic = "topic2", partitions = "0",
             partitionOffsets = @PartitionOffset(partition = "1", initialOffset = "100"))
        })
public void listen(ConsumerRecord<?, ?> record) {
    ...
}
```

`partitions` 또는 `partitionOffsets` 속성 하나로만 각 파티션을 지정할 수 있으며, 두 속성을 동시에 사용할 수는 없다.

어노테이션 프로퍼티 대부분이 그렇듯 여기에도 SpEL 표현식을 사용할 수 있다. 대량의 파티션을 생성하는 방법은 [모든 파티션 수동으로 할당하기](https://docs.spring.io/spring-kafka/reference/tips.html)를 참고해라.

2.5.5 버전부터는 할당된 모든 파티션에 초기 오프셋을 적용할 수 있다:

```java
@KafkaListener(id = "thing3", topicPartitions =
        { @TopicPartition(topic = "topic1", partitions = { "0", "1" },
             partitionOffsets = @PartitionOffset(partition = "*", initialOffset = "0"))
        })
public void listen(ConsumerRecord<?, ?> record) {
    ...
}
```

`partitions` 속성에서 와일드카드 `*`는 모든 파티션을 의미한다. 각 `@TopicPartition`에서는 하나의 `@PartitionOffset`만 와일드카드를 사용할 수 있다.

또한 리스너가 `ConsumerSeekAware`를 구현할 경우, 수동으로 파티션을 할당하는 경우에도 `onPartitionsAssigned`를 호출한다. 파티션이 할당되는 시점에 임의의 오프셋으로 되돌아가는<sup>seek</sup> 식으로 활용할 수 있다.

2.6.4 버전부터는 파티션이나 피티션 범위를 콤마로 구분해 여러 개 지정할 수 있다:

```java
@KafkaListener(id = "pp", autoStartup = "false",
        topicPartitions = @TopicPartition(topic = "topic1",
                partitions = "0-5, 7, 10-15"))
public void process(String in) {
    ...
}
```

범위를 지정할 땐 양 끝값을 포함<sup>inclusive</sup>해서 지정한다. 위 예시에선 파티션 `0, 1, 2, 3, 4, 5, 7, 10, 11, 12, 13, 14, 15`를 할당한다.

초기 오프셋을 지정할 때도 동일한 기법을 사용할 수 있다:

```java
@KafkaListener(id = "thing3", topicPartitions =
        { @TopicPartition(topic = "topic1",
             partitionOffsets = @PartitionOffset(partition = "0-5", initialOffset = "0"))
        })
public void listen(ConsumerRecord<?, ?> record) {
    ...
}
```

초기 오프셋은 여섯 개의 파티션 모두에 적용된다.

3.2 버전부터 `@PartitionOffset`에 `SeekPosition.END`, `SeekPosition.BEGINNING`, `SeekPosition.TIMESTAMP`를 지정할 수 있으며, `seekPosition`에 enum  `SeekPosition`의 이름을 지정하면 된다:

```java
@KafkaListener(id = "seekPositionTime", topicPartitions = {
        @TopicPartition(topic = TOPIC_SEEK_POSITION, partitionOffsets = {
                @PartitionOffset(partition = "0", initialOffset = "723916800000", seekPosition = "TIMESTAMP"),
                @PartitionOffset(partition = "1", initialOffset = "0", seekPosition = "BEGINNING"),
                @PartitionOffset(partition = "2", initialOffset = "0", seekPosition = "END")
        })
})
public void listen(ConsumerRecord<?, ?> record) {
    ...
}
```

seekPosition을 `END`나 `BEGINNING`으로 설정하면 `initialOffset`과 `relativeToCurrent`를 무시한다. seekPosition을 `TIMESTAMP`로 설정하면`initialOffset`은 타임스탬프를 의미하게 된다.

### Manual Acknowledgment

수동 `AckMode`를 사용할 때는 리스너에게 `Acknowledgment`를 넘겨줄 수도 있다. 수동 `AckMode`를 활성화하려면 `ContainerProperties`의 ack-mode를 적절한 수동 모드로 설정해야 한다. 다음은 또 다른 컨테이너 팩토리의 사용 방법을 보여주는 예시다. 이 커스텀 컨테이너 팩토리에선 `getContainerProperties()`를 호출한 후 `setAckMode`를 호출해서 `AckMode`를 수동 모드로 설정해야 한다. 그렇지 않으면 `Acknowledgment` 객체로 null이 전달된다.

```java
@KafkaListener(id = "cat", topics = "myTopic",
          containerFactory = "kafkaManualAckListenerContainerFactory")
public void listen(String data, Acknowledgment ack) {
    ...
    ack.acknowledge();
}
```

### Consumer Record Metadata

마지막으로, 메시지 헤더에서 레코드에 대한 메타데이터를 확인할 수 있다. 메시지의 헤더는 다음과 같은 헤더명으로 조회할 수 있다:

- `KafkaHeaders.OFFSET`
- `KafkaHeaders.RECEIVED_KEY`
- `KafkaHeaders.RECEIVED_TOPIC`
- `KafkaHeaders.RECEIVED_PARTITION`
- `KafkaHeaders.RECEIVED_TIMESTAMP`
- `KafkaHeaders.TIMESTAMP_TYPE`

2.5 버전부터는 수신한 레코드의 키가 `null`인 경우 `RECEIVED_KEY`는 존재하지 않는다. 이전에는 헤더의 값이 `null`이었다. 이는 값이 `null`인 헤더는 존재하지 않는 `spring-messaging` 컨벤션을 지키기 위한 조치다.

다음은 헤더 사용법을 보여주는 예시다:

```java
@KafkaListener(id = "qux", topicPattern = "myTopic1")
public void listen(@Payload String foo,
        @Header(name = KafkaHeaders.RECEIVED_KEY, required = false) Integer key,
        @Header(KafkaHeaders.RECEIVED_PARTITION) int partition,
        @Header(KafkaHeaders.RECEIVED_TOPIC) String topic,
        @Header(KafkaHeaders.RECEIVED_TIMESTAMP) long ts
        ) {
    ...
}
```

> 파라미터 어노테이션(`@Payload`, `@Header`)은 추상 클래스가 아닌 리스너 메소드의 구현체에 명시해야 한다. 인터페이스에 정의된 경우는 감지하지 못한다.

2.5 버전부터는 헤더를 따로따로 받는 대신 `ConsumerRecordMetadata` 파라미터를 이용해 레코드 메타데이터를 수신할 수 있다.

```java
@KafkaListener(...)
public void listen(String str, ConsumerRecordMetadata meta) {
    ...
}
```

여기에는 키와 값을 제외한 `ConsumerRecord`의 모든 데이터가 들어있다.

### Batch Listeners

1.1 버전부터는 `@KafkaListener` 메소드를 통해 컨슈머 폴링으로 수신한 컨슈머 레코드의 배치를 통째로 전달받을 수 있다.

> 배치 리스너에서는 [논블러킹 재시도](https://docs.spring.io/spring-kafka/reference/retrytopic.html)를 지원하지 않는다.

배치 리스너를 생성하려면 리스너 컨테이너 팩토리의 `batchListener` 프로퍼티를 이용하면 된다. 그 방법은 다음 예제를 참고해라:

```java
@Bean
public KafkaListenerContainerFactory<?> batchFactory() {
    ConcurrentKafkaListenerContainerFactory<Integer, String> factory =
            new ConcurrentKafkaListenerContainerFactory<>();
    factory.setConsumerFactory(consumerFactory());
    factory.setBatchListener(true);
   return factory;
}
```

> 2.8 버전부터 `@KafkaListener` 어노테이션의 `batch` 프로퍼티로 팩토리의 `batchListener` 프로퍼티를 재정의할 수 있다. [컨테이너 에러 핸들러](https://docs.spring.io/spring-kafka/reference/kafka/annotation-error-handling.html#error-handlers)도 변경 되면서, 레코드 리스너와 배치 리스너에 동일한 팩토리를 재사용할 수 있게 됐다.

> 2.9.6 버전부터 컨테이너 팩토리는 `recordMessageConverter`, `batchMessageConverter` 프로퍼티에 대해 별도의 setter 메소드를 제공한다. 이전에는 레코드 리스너와 배치 리스너 둘 다에 적용되는 `messageConverter` 프로퍼티 하나만 존재했었다.

다음은 페이로드 리스트를 수신하는 예시다:

```java
@KafkaListener(id = "list", topics = "myTopic", containerFactory = "batchFactory")
public void listen(List<String> list) {
    ...
}
```

토픽, 파티션, 오프셋 등은 페이로드 옆에 헤더를 정의하면 확인할 수 있다. 헤더 사용법은 다음 예시를 참고해라:

```java
@KafkaListener(id = "list", topics = "myTopic", containerFactory = "batchFactory")
public void listen(List<String> list,
        @Header(KafkaHeaders.RECEIVED_KEY) List<Integer> keys,
        @Header(KafkaHeaders.RECEIVED_PARTITION) List<Integer> partitions,
        @Header(KafkaHeaders.RECEIVED_TOPIC) List<String> topics,
        @Header(KafkaHeaders.OFFSET) List<Long> offsets) {
    ...
}
```

아니면 각 메시지마다 오프셋과 기타 세부 정보가 담겨있는 `Message<?>` 객체의 `List`를 수신할 수도 있다. 단, 이 경우 해당 메소드에는 다른 파라미터를 정의할 수 없다 (수동 커밋 시 사용하는 `Acknowledgment`와 `Consumer<?, ?>` 파라미터는 예외). 다음 예제를 참고해라:

```java
@KafkaListener(id = "listMsg", topics = "myTopic", containerFactory = "batchFactory")
public void listen1(List<Message<?>> list) {
    ...
}

@KafkaListener(id = "listMsgAck", topics = "myTopic", containerFactory = "batchFactory")
public void listen2(List<Message<?>> list, Acknowledgment ack) {
    ...
}

@KafkaListener(id = "listMsgAckConsumer", topics = "myTopic", containerFactory = "batchFactory")
public void listen3(List<Message<?>> list, Acknowledgment ack, Consumer<?, ?> consumer) {
    ...
}
```

이 경우 페이로드 변환은 수행하지 않는다.

`BatchMessagingMessageConverter`에 `RecordMessageConverter`를 설정한 경우 `Message` 파라미터에 제네릭 타입을 추가할 수 있으며, 그에 맞게 페이로드가 변환된다. 자세한 내용은 [배치 리스너를 사용한 페이로드 변환](https://docs.spring.io/spring-kafka/reference/kafka/serdes.html#payload-conversion-with-batch)을 참고해라.

`ConsumerRecord<?, ?>` 객체의 리스트를 전달받을 수도 있지만, 이땐 다른 파라미터는 정의할 수 없다 (수동 커밋 시 사용하는 `Acknowledgment`와 `Consumer<?, ?>` 파라미터는 예외). 다음 예제를 참고해라:

```java
@KafkaListener(id = "listCRs", topics = "myTopic", containerFactory = "batchFactory")
public void listen(List<ConsumerRecord<Integer, String>> list) {
    ...
}

@KafkaListener(id = "listCRsAck", topics = "myTopic", containerFactory = "batchFactory")
public void listen(List<ConsumerRecord<Integer, String>> list, Acknowledgment ack) {
    ...
}
```

2.2 버전부터 `poll()` 메소드가 반환하는 `ConsumerRecords<?, ?>` 객체를 리스너에서 그대로 수신할 수 있으며, 덕분에 리스너에서 `partitions()`(관련 `TopicPartition` 인스턴스를 반환), `records(TopicPartition)`(특정 파티션에 속한 레코드만 선택적으로 조회)과 같은 추가 메소드에 접근할 수 있다. 다시 한번 말하지만, 이 경우 해당 메소드에는 다른 파라미터를 정의할 수 없다 (수동 커밋 시 사용하는 `Acknowledgment`와 `Consumer<?, ?>` 파라미터는 예외). 다음 예제를 참고해라:

```java
@KafkaListener(id = "pollResults", topics = "myTopic", containerFactory = "batchFactory")
public void pollResults(ConsumerRecords<?, ?> records) {
    ...
}
```

> 컨테이너 팩토리에 `RecordFilterStrategy`를 설정했더라도 `ConsumerRecords<?, ?>` 리스너에서는 `WARN` 로그만 남기고 무시한다. 배치 리스너에서 레코드를 필터링하려면 `List<?>` 형태의 리스너를 사용해야 한다. 기본적으로 레코드는 한 번에 하나씩 필터링된다. 2.8 버전부터는 `filterBatch`를 재정의해서 배치 전체를 한 번에 필터링할 수 있다.

### Annotation Properties

2.0 버전부터 `id` 프로퍼티는 (있다면) 카프카 컨슈머의 `group.id` 프로퍼티로 사용되며, 컨슈머 팩토리에 설정한 프로퍼티가 있다면 이를 재정의한다. `groupId`를 직접 명시하거나 `idIsGroup`을 false로 설정하면 예전처럼 컨슈머 팩토리의 `group.id`를 사용할 수도 있다.

어노테이션 프로퍼티 내에서는 대부분 아래와 같이 프로퍼티 플레이스홀더나 SpEL 표현식을 사용할 수 있다:

```java
@KafkaListener(topics = "${some.property}")

@KafkaListener(topics = "#{someBean.someProperty}",
    groupId = "#{someBean.someProperty}.group")
```

2.1.2 버전부터 SpEL 표현식은 특수 토큰인 `__listener`를 지원한다. 이는 해당 애노테이션이 선언된 현재 빈<sup>bean</sup> 인스턴스를 나타내는 가상의<sup>pseudo</sup> 빈<sup>bean</sup> 이름이다.

아래 예시를 살펴보자:

```java
@Bean
public Listener listener1() {
    return new Listener("topic1");
}

@Bean
public Listener listener2() {
    return new Listener("topic2");
}
```

위와 같이 빈을 정의했다면, 다음과 같은 코드를 작성할 수 있다:

```java
public class Listener {

    private final String topic;

    public Listener(String topic) {
        this.topic = topic;
    }

    @KafkaListener(topics = "#{__listener.topic}",
        groupId = "#{__listener.topic}.group")
    public void listen(...) {
        ...
    }

    public String getTopic() {
        return this.topic;
    }

}
```

그런 경우는 거의 없겠지만, 만약 `__listener`라는 빈이 실제로 존재한다면 다음과 같이 `beanRef` 속성을 사용해 표현식 토큰을 변경할 수 있다:

```java
@KafkaListener(beanRef = "__x", topics = "#{__x.topic}", groupId = "#{__x.topic}.group")
```

2.2.4 버전부터는 어노테이션에 직접 카프카 컨슈머 프로퍼티를 지정할 수 있으며, 컨슈머 팩토리에 같은 이름으로 정의한 프로퍼티들을 재정의한다. `group.id`와 `client.id`는 이 방법으로 지정할 수 **없으며**, 지정해도 무시된다. 이 프로퍼티들은 어노테이션 프로퍼티 `groupId`와 `clientIdPrefix`를 사용해라.

프로퍼티는 각각 일반적인 자바 `Properties` 파일 형식에 맞는 문자열로 지정한다 (e.g. `foo:bar`, `foo=bar`, `foo bar`). 예시는 아래 코드에서 확인할 수 있다:

```java
@KafkaListener(topics = "myTopic", groupId = "group", properties = {
    "max.poll.interval.ms:60000",
    ConsumerConfig.MAX_POLL_RECORDS_CONFIG + "=100"
})
```

다음은 [`RoutingKafkaTemplate` 사용하기](../sending-messages/#using-routingkafkatemplate)에서 보여줬던 토픽 메시지를 수신하기 위한 리스너다:

```java
@KafkaListener(id = "one", topics = "one")
public void listen1(String in) {
    System.out.println("1: " + in);
}

@KafkaListener(id = "two", topics = "two",
        properties = "value.deserializer:org.apache.kafka.common.serialization.ByteArrayDeserializer")
public void listen2(byte[] in) {
    System.out.println("2: " + new String(in));
}
```

---

## Obtaining the Consumer `group.id`

하나의 리스너 코드를 여러 컨테이너에서 실행한다면, 레코드가 어떤 컨테이너에서 온 것인지 확인할 수 있으면 유용할 거다 (컨슈머 프로퍼티 `group.id`로 식별할 수 있다).

이땐 리스너 스레드에서 `KafkaUtils.getConsumerGroupId()`를 호출하면 된다. 아니면 메소드 파라미터를 통해 그룹 ID에 접근하는 방법도 있다.

```java
@KafkaListener(id = "id", topicPattern = "someTopic")
public void listener(@Payload String payload, @Header(KafkaHeaders.GROUP_ID) String groupId) {
    ...
}
```

> 이 기능은 레코드 리스너와 `List<?>` 형식의 레코드 배열을 수신하는 배치 리스너에서 사용할 수 있다. `ConsumerRecords<?, ?>` 인자를 받는 배치 리스너에서는 사용할 수 **없다**. 이 경우에는 `KafkaUtils`를 이용해라. 

---

## Container Thread Naming

컨테이너는 `TaskExecutor`를 사용해 컨슈머와 리스너를 실행한다. 커스텀 executor를 사용하고 싶다면, 컨테이너의 `ContainerProperties` 프로퍼티 중 `consumerExecutor`를 설정하면 된다. 스레드 풀<sup>pooled executor</sup>을 사용할 때는, 해당 executor를 사용하는 모든 컨테이너의 동시성 수준을 고려해 충분한 스레드를 확보해야 한다. `ConcurrentMessageListenerContainer`를 사용할 경우, 각 컨슈머(`concurrency`)는 executor 풀에서 하나의 스레드를 사용한다.

별도의 컨슈머 executor를 제공하지 않으면 각 컨테이너는 `SimpleAsyncTaskExecutor`를 사용한다. 이 executor는 `<beanName>-C-<n>`과 같은 이름의 스레드를 생성한다. `ConcurrentMessageListenerContainer`의 경우, 스레드 이름의 `<beanName>` 부분이 `<beanName>-m` 형태가 되는데, 여기서 `m`은 컨슈머 인스턴스를 의미한다. `n`은 컨테이너가 시작될 때마다 증가한다. 따라서 빈 이름이 `container`인 경우, 이 컨테이너가 처음 시작될 때의 스레드 명은 `container-0-C-1`, `container-1-C-1` 등으로 설정된다. 중지 후 다시 시작할 때에는 `container-0-C-2`, `container-1-C-2`와 같은 이름을 사용한다.

`3.0.1` 버전부터는, 사용 중인 executor와 무관하게 스레드 이름을 변경할 수 있다. `AbstractMessageListenerContainer.changeConsumerThreadName` 프로퍼티를 `true`로 설정하면 `AbstractMessageListenerContainer.threadNameSupplier`를 호출해 스레드 이름을 가져간다. 이는 `Function<MessageListenerContainer, String>` 타입으로 선언되어 있으며, 기본 구현체는 `container.getListenerId()`를 반환한다.

---

## `@KafkaListener` as a Meta Annotation

2.2 버전부터 `@KafkaListener`를 메타 어노테이션으로 사용할 수 있다. 사용 방법은 다음 예시를 참고해라:

```java
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
@KafkaListener
public @interface MyThreeConsumersListener {

    @AliasFor(annotation = KafkaListener.class, attribute = "id")
    String id();

    @AliasFor(annotation = KafkaListener.class, attribute = "topics")
    String[] topics();

    @AliasFor(annotation = KafkaListener.class, attribute = "concurrency")
    String concurrency() default "3";

}
```

이땐 `topics`, `topicPattern`, `topicPartitions` 중 최소 하나는 반드시 지정해야 한다 (대부분의 경우와 같이, 컨슈머 팩토리 설정에 `group.id`를 명시하지 않았다면 `id`나 `groupId`도 필요하다). 다음을 참고해라:

```java
@MyThreeConsumersListener(id = "my.group", topics = "my.topic")
public void listen1(String in) {
    ...
}
```

---

## `@KafkaListener` on a Class

클래스에 `@KafkaListener`를 선언할 때에는 반드시 메소드에 `@KafkaHandler`를 지정해야 한다. 메시지를 전달할 때는, 변환된 메시지 페이로드 타입에 따라 호출할 메소드를 결정한다. 다음 예제를 참고해라:

```java
@KafkaListener(id = "multi", topics = "myTopic")
static class MultiListenerBean {

    @KafkaHandler
    public void listen(String foo) {
        ...
    }

    @KafkaHandler
    public void listen(Integer bar) {
        ...
    }

    @KafkaHandler(isDefault = true)
    public void listenDefault(Object object) {
        ...
    }

}
```

2.1.3 버전부터는 특정 `@KafkaHandler` 메소드를 매칭되는 메소드가 없을 경우 호출할 디폴트 메소드로 지정할 수 있다. 디폴트 메소드는 최대 하나만 지정할 수 있다. `@KafkaHandler` 메소드를 사용할 때에는, 페이로드가 이미 도메인 객체로 변환되어 있어야 한다 (그래야 매칭 여부를 판단할 수 있다). 이를 위해서는 커스텀 deserializer나 `JsonDeserializer`, 또는 `TypePrecedence`를 `TYPE_ID`로 설정한 `JsonMessageConverter`를 사용해야 한다. 자세한 내용은 [Serialization, Deserialization, and Message Conversion](https://docs.spring.io/spring-kafka/reference/kafka/serdes.html)을 참고해라.

> 스프링이 메소드 인자를 리졸브하는 방식에는 몇 가지 제약이 있기 때문에, 디폴트 `@KafkaHandler`에서는 헤더를 하나씩 받아올 수 없다. 대신에 [컨슈머 레코드 메타데이터](#consumer-record-metadata)에서 설명한 대로 `ConsumerRecordMetadata`를 사용해야 한다.

한 가지 예를 들어보면:

```java
@KafkaHandler(isDefault = true)
public void listenDefault(Object object, @Header(KafkaHeaders.RECEIVED_TOPIC) String topic) {
    ...
}
```

이때 object가 `String`인 경우는 제대로 동작하지 않는다. `topic` 파라미터에도 `object`에 대한 참조가 전달된다.

디폴트 메소드에서 레코드에 대한 메타데이터가 필요한 경우, 다음과 같이 작성하면 된다:

```java
@KafkaHandler(isDefault = true)
void listen(Object in, @Header(KafkaHeaders.RECORD_METADATA) ConsumerRecordMetadata meta) {
    String topic = meta.topic();
    ...
}
```

---

## `@KafkaListener` Attribute Modification

2.7.2 버전부터 컨테이너를 생성하기 전에 코드를 통해 어노테이션 속성을 수정할 수 있다. 애플리케이션 컨텍스트에 `KafkaListenerAnnotationBeanPostProcessor.AnnotationEnhancer`를 하나 이상 추가해주면 된다. `AnnotationEnhancer`는 `BiFunction<Map<String, Object>, AnnotatedElement, Map<String, Object>` 타입으로, 속성 맵을 반환해야 한다. 속성 값에는 SpEL이나 플레이스홀더를 사용할 수 있으며, 값을 리졸브 하기 전에 `AnnotationEnhancer`를 호출한다. `Ordered`를 구현한 enhancer가 여러 개 존재하는 경우 정의한 순서에 맞게 호출된다.

> `AnnotationEnhancer`는 애플리케이션 컨텍스트 라이프사이클의 매우 초기 단계에서 필요하기 때문에, 빈 정의는 반드시 `static`으로 선언해야 한다.

다음 예시를 참고해라:

```java
@Bean
public static AnnotationEnhancer groupIdEnhancer() {
    return (attrs, element) -> {
        attrs.put("groupId", attrs.get("id") + "." + (element instanceof Class
                ? ((Class<?>) element).getSimpleName()
                : ((Method) element).getDeclaringClass().getSimpleName()
                        +  "." + ((Method) element).getName()));
        return attrs;
    };
}
```

---

## `@KafkaListener` Lifecycle Management

`@KafkaListener` 어노테이션으로 만들어지는 리스너 컨테이너는 애플리케이션 컨텍스트 내의 빈이 아니다. 대신 `KafkaListenerEndpointRegistry` 타입의 인프라 빈에 등록된다. `KafkaListenerEndpointRegistry` 빈은 프레임워크에 의해 자동 정의되는 빈으로, 컨테이너의 라이프사이클을 관리한다. `autoStartup`이 `true`로 세팅된 모든 컨테이너를 자동으로 시작한다. 참고로, 모든 컨테이너 팩토리에서 생성하는 컨테이너는 전부 동일한 `phase`에 있어야 한다. 자세한 내용은 [리스너 컨테이너 자동 시작](#listener-container-auto-startup)을 참고해라. 레지스트리를 사용하면 코드를 통해 라이프사이클을 관리할 수 있다. 레지스트리를 시작하거나 중지하면 등록된 모든 컨테이너를 시작하거나 중지한다. 아니면 개별 컨테이너의 `id` 속성을 통해 해당 컨테이너에 대한 참조를 얻을 수도 있다. 또한 애노테이션에 `autoStartup`을 지정하면 컨테이너 팩토리에 설정된 기본 설정을 재정의할 수 있다. `KafkaListenerEndpointRegistry`는 애플리케이션 컨텍스트 빈으로 등록되어 있기 때문에, 등록된 컨테이너들을 관리하려면 자동 주입을 받으면 된다. 다음 예시를 참고해라:

```java
@KafkaListener(id = "myContainer", topics = "myTopic", autoStartup = "false")
public void listen(...) { ... }
```

```java
@Autowired
private KafkaListenerEndpointRegistry registry;

...

    this.registry.getListenerContainer("myContainer").start();

...
```

레지스트리는 자신이 관리하는 컨테이너의 라이프사이클만 관리한다. 애플리케이션 컨텍스트에서 가져올 수 있는, 빈으로 선언된 컨테이너는 레지스트리가 관리하지 않는다. 레지스트리가 관리하는 컨테이너 컬렉션은 레지스트리의 `getListenerContainers()` 메소드를 통해 확인할 수 있다. 2.2.5 버전에서는 레지스트리가 관리하는 컨테이너와 빈으로 선언된 컨테이너를 전부 반환하는 `getAllListenerContainers()` 메소드가 추가됐다. 반환된 컬렉션에는 이미 초기화된 prototype 빈이 들어있지만, lazy Initialization으로 선언된 빈은 초기화하지는 않는다.

> 애플리케이션 컨텍스트를 리프레시한 이후에 등록된 엔드포인트는 `autoStartup` 프로퍼티와 상관 없이 즉시 시작된다. 이는 `SmartLifecycle`의 규약을 따르는 것으로, `autoStartup`은 애플리케이션 컨텍스트 초기화 중에만 고려한다. 예를 들어 `@KafkaListener`를 붙인 빈을 prototype 스코프로 선언하면 뒤늦게 등록되는데, 이 경우 컨텍스트를 초기화한 이후에 인스턴스를 생성한다. 2.8.7 버전부터 레지스트리의 `alwaysStartAfterRefresh` 프로퍼티를 `false`로 설정하면 컨테이너의 `autoStartup` 프로퍼티에 따라 컨테이너의 시작 여부를 결정할 수 있다.

### Retrieving MessageListenerContainers from KafkaListenerEndpointRegistry

`KafkaListenerEndpointRegistry`는 `MessageListenerContainer` 인스턴스를 조회하는 여러 가지 메소드를 제공하므로, 다양한 요구사항에 맞게 컨테이너를 관리할 수 있다.

**모든 컨테이너**: 모든 리스너 컨테이너를 대상으로 작업하려면, 모든 컨테이너를 반환하는 `getListenerContainers()`를 사용해라.

```java
Collection<MessageListenerContainer> allContainers = registry.getListenerContainers();
```

**특정 ID를 가진 컨테이너**: 컨테이너를 개별로 관리하려면, ID로 조회할 수 있는 `getListenerContainer(String id)`를 사용해라.

```java
MessageListenerContainer specificContainer = registry.getListenerContainer("myContainerId");
```

**동적 컨테이너 필터링**: 3.2 버전에서는 조금 더 구체적인 조건으로 컨테이너를 조회할 수 있는 두 가지 오버로딩 메소드 `getListenerContainersMatching`을 도입했다. 하나는 ID 기반 필터링을 위한 `Predicate<String>`을 파라미터로 받으며, 다른 하나는 조금 더 복잡한 `BiPredicate<String, MessageListenerContainer>`를 받아 컨테이너 프로퍼티나 상태를 넘길 수 있다.

```java
// Prefix matching (Predicate<String>)
Collection<MessageListenerContainer> filteredContainers =
    registry.getListenerContainersMatching(id -> id.startsWith("productListener-retry-"));

// Regex matching (Predicate<String>)
Collection<MessageListenerContainer> regexFilteredContainers =
    registry.getListenerContainersMatching(myPattern::matches);

// Pre-built Set of IDs (Predicate<String>)
Collection<MessageListenerContainer> setFilteredContainers =
    registry.getListenerContainersMatching(myIdSet::contains);

// Advanced Filtering: ID prefix and running state (BiPredicate<String, MessageListenerContainer>)
Collection<MessageListenerContainer> advancedFilteredContainers =
    registry.getListenerContainersMatching(
        (id, container) -> id.startsWith("specificPrefix-") && container.isRunning()
    );
```

애플리케이션 내에서 이 메소드들을 잘 활용하면  `MessageListenerContainer` 인스턴스를 보다 효율적으로 관리하고 질의할 수 있다.

---

## `@KafkaListener` `@Payload` Validation

2.2 버전부터 `@KafkaListener`의 `@Payload` 인자를 검증하기 위한 `Validator`를 좀더 쉽게 등록할 수 있다. 이전에는 커스텀 `DefaultMessageHandlerMethodFactory`를 설정하고 registrar에 추가해줘야 했었다. 이제 registrar에 validator를 바로 추가할 수 있다. 그 방법은 아래 코드를 참고해라:

```java
@Configuration
@EnableKafka
public class Config implements KafkaListenerConfigurer {

    ...

    @Override
    public void configureKafkaListeners(KafkaListenerEndpointRegistrar registrar) {
      registrar.setValidator(new MyValidator());
    }

}
```

> 스프링 부트와 validation starter를 사용 중이라면, 아래 예시에서 볼 수 있듯이 `LocalValidatorFactoryBean`이 자동 설정된다: 

```java
@Configuration
@EnableKafka
public class Config implements KafkaListenerConfigurer {

    @Autowired
    private LocalValidatorFactoryBean validator;
    ...

    @Override
    public void configureKafkaListeners(KafkaListenerEndpointRegistrar registrar) {
      registrar.setValidator(this.validator);
    }
}
```

다음은 검증 방법을 보여주는 예시다:

```java
public static class ValidatedClass {

  @Max(10)
  private int bar;

  public int getBar() {
    return this.bar;
  }

  public void setBar(int bar) {
    this.bar = bar;
  }

}
```

```java
@KafkaListener(id="validated", topics = "annotated35", errorHandler = "validationErrorHandler",
      containerFactory = "kafkaJsonListenerContainerFactory")
public void validatedListener(@Payload @Valid ValidatedClass val) {
    ...
}

@Bean
public KafkaListenerErrorHandler validationErrorHandler() {
    return (m, e) -> {
        ...
    };
}
```

2.5.11 버전부터는 페이로드 검증을 클래스로 정의한 리스너의 `@KafkaHandler` 메소드에도 사용할 수 있다. 자세한 내용은 [클래스 단위의 `@KafkaListener`](#kafkalistener-on-a-class)를 참고해라.

3.1 버전부터는 이대신 `ErrorHandlingDeserializer`에서 유효성 검사를 수행할 수 있다. 자세한 내용은 [`ErrorHandlingDeserializer` 사용하기](https://docs.spring.io/spring-kafka/reference/kafka/serdes.html#error-handling-deserializer)를 참고해라.

---

## Rebalancing Listeners

`ContainerProperties`에는 `consumerRebalanceListener`라는 프로퍼티가 있는데, 이는 카프카 클라이언트의 `ConsumerRebalanceListener` 인터페이스 구현체를 받는 프로퍼티다. 이 프로퍼티를 지정하지 않으면 컨테이너는 리밸런싱 이벤트를 `INFO` 레벨로 남기는 로깅 리스너를 설정한다. 또한 하위 인터페이스 `ConsumerAwareRebalanceListener`도 하나 추가한다. `ConsumerAwareRebalanceListener` 인터페이스의 정의는 다음과 같다:

```java
public interface ConsumerAwareRebalanceListener extends ConsumerRebalanceListener {

    void onPartitionsRevokedBeforeCommit(Consumer<?, ?> consumer, Collection<TopicPartition> partitions);

    void onPartitionsRevokedAfterCommit(Consumer<?, ?> consumer, Collection<TopicPartition> partitions);

    void onPartitionsAssigned(Consumer<?, ?> consumer, Collection<TopicPartition> partitions);

    void onPartitionsLost(Consumer<?, ?> consumer, Collection<TopicPartition> partitions);

}
```

파티션을 회수할 때는 두 가지 콜백이 발생한다. 첫 번째 콜백은 즉시 호출하고, 두 번째 콜백은 보류 중<sup>pending</sup>인 오프셋을 커밋한 후에 호출한다. 특히 두 번째 콜백은 아래에 보이는 것처럼 외부 저장소에서 오프셋을 관리하는 경우에 유용하다:

```java
containerProperties.setConsumerRebalanceListener(new ConsumerAwareRebalanceListener() {

    @Override
    public void onPartitionsRevokedBeforeCommit(Consumer<?, ?> consumer, Collection<TopicPartition> partitions) {
        // acknowledge any pending Acknowledgments (if using manual acks)
    }

    @Override
    public void onPartitionsRevokedAfterCommit(Consumer<?, ?> consumer, Collection<TopicPartition> partitions) {
        // ...
        store(consumer.position(partition));
        // ...
    }

    @Override
    public void onPartitionsAssigned(Collection<TopicPartition> partitions) {
        // ...
        consumer.seek(partition, offsetTracker.getOffset() + 1);
        // ...
    }
});
```

> 2.4 버전부터 `onPartitionsLost()` 메소드를 새로 추가했다 (`ConsumerRebalanceLister`에 있는 같은 이름의 메소드와 유사하다). `ConsumerRebalanceLister`의 디폴트 구현체는 단순히 `onPartitionsRevoked`를 호출한다. 반면 `ConsumerAwareRebalanceListener`의 디폴트 구현체는 아무 작업도 수행하지 않는다. 리스너 컨테이너에 커스텀 리스너를 제공한다면 (둘 중 어떤 것이라도), `onPartitionsLost` 내에서 `onPartitionsRevoked`를 호출하지 않도록 주의해야 한다. `ConsumerRebalanceListener`를 구현하는 경우엔 디폴트 메소드를 재정의해야 한다. 그 이유는 리스너 컨테이너가 커스텀  메소드를 호출한 다음 자체 `onPartitionsLost` 구현체에서 `onPartitionsRevoked`를 호출하기 때문이다. 디폴트 동작으로 위임하도록 작성했다면, `Consumer`가 컨테이너의 리스너에서 해당 메소드를 호출할 때마다 `onPartitionsRevoked`가 두 번 호출되는 문제가 생긴다.

---

## Enforcing Consumer Rebalance

이제 카프카 클라이언트는 [강제 리밸런싱](https://cwiki.apache.org/confluence/display/KAFKA/KIP-568%3A+Explicit+rebalance+triggering+on+the+Consumer)을 트리거할 수 있다. 스프링 카프카는 `3.1.2` 버전부터 메시지 리스너 컨테이너를 통해 이 API를 카프카 컨슈머에서 호출할 수 있는 기능을 제공한다. 이 API를 호출하는 것은 단순히 카프카 컨슈머에게 강제 리밸런싱을 트리거하라고 알리는 것으로, 실제 리밸런싱은 다음 `poll()` 작업 중에 발생한다. 이미 리밸런싱이 진행 중인 경우 강제 리밸런싱 메소드를 호출해도 아무 일도 일어나지 않는다. 이 메소드를 호출하려면 현재 리밸런싱이 완료될 때까지 기다려야 한다. 자세한 내용은 `enforceRebalance`의 javadoc을 참고해라.

다음은 메시지 리스너 컨테이너를 사용해 강제로 리밸런싱을 유발하는 코드다.

```java
@KafkaListener(id = "my.id", topics = "my-topic")
void listen(ConsumerRecord<String, String> in) {
    System.out.println("From KafkaListener: " + in);
}

@Bean
public ApplicationRunner runner(KafkaTemplate<String, Object> template, KafkaListenerEndpointRegistry registry) {
    return args -> {
        final MessageListenerContainer listenerContainer = registry.getListenerContainer("my.id");
        System.out.println("Enforcing a rebalance");
        Thread.sleep(5_000);
        listenerContainer.enforceRebalance();
        Thread.sleep(5_000);
    };
}
```

위 코드를 보면, `KafkaListenerEndpointRegistry`를 사용해 메시지 리스너 컨테이너의 참조를 얻고, 이 컨테이너에서 `enforceRebalance` API를 호출한다. 리스너 컨테이너에서 `enforceRebalance`를 호출하면, 내부 카프카 컨슈머로 동작을 위임한다. 카프카 컨슈머는 다음 `poll()` 연산 시점에 리밸런스를 트리거한다.

---

## Forwarding Listener Results using `@SendTo`

Starting with version 2.0, if you also annotate a `@KafkaListener` with a `@SendTo` annotation and the method invocation returns a result, the result is forwarded to the topic specified by the `@SendTo`.

The `@SendTo` value can have several forms:

- `@SendTo("someTopic")` routes to the literal topic.
- `@SendTo("#{someExpression}")` routes to the topic determined by evaluating the expression once during application context initialization.
- `@SendTo("!{someExpression}")` routes to the topic determined by evaluating the expression at runtime. The `#root` object for the evaluation has three properties:
  - `request`: The inbound `ConsumerRecord` (or `ConsumerRecords` object for a batch listener).
  - `source`: The `org.springframework.messaging.Message<?>` converted from the `request`.
  - `result`: The method return result.
- `@SendTo` (no properties): This is treated as `!{source.headers['kafka_replyTopic']}` (since version 2.1.3).

Starting with versions 2.1.11 and 2.2.1, property placeholders are resolved within `@SendTo` values.

The result of the expression evaluation must be a `String` that represents the topic name. The following examples show the various ways to use `@SendTo`:

```java
@KafkaListener(topics = "annotated21")
@SendTo("!{request.value()}") // runtime SpEL
public String replyingListener(String in) {
    ...
}

@KafkaListener(topics = "${some.property:annotated22}")
@SendTo("#{myBean.replyTopic}") // config time SpEL
public Collection<String> replyingBatchListener(List<String> in) {
    ...
}

@KafkaListener(topics = "annotated23", errorHandler = "replyErrorHandler")
@SendTo("annotated23reply") // static reply topic definition
public String replyingListenerWithErrorHandler(String in) {
    ...
}
...
@KafkaListener(topics = "annotated25")
@SendTo("annotated25reply1")
public class MultiListenerSendTo {

    @KafkaHandler
    public String foo(String in) {
        ...
    }

    @KafkaHandler
    @SendTo("!{'annotated25reply2'}")
    public String bar(@Payload(required = false) KafkaNull nul,
            @Header(KafkaHeaders.RECEIVED_KEY) int key) {
        ...
    }

}
```

> In order to support `@SendTo`, the listener container factory must be provided with a `KafkaTemplate` (in its `replyTemplate` property), which is used to send the reply. This should be a `KafkaTemplate` and not a `ReplyingKafkaTemplate` which is used on the client-side for request/reply processing. When using Spring Boot, it will auto-configure the template into the factory; when configuring your own factory, it must be set as shown in the examples below.

Starting with version 2.2, you can add a `ReplyHeadersConfigurer` to the listener container factory. This is consulted to determine which headers you want to set in the reply message. The following example shows how to add a `ReplyHeadersConfigurer`:

```java
@Bean
public ConcurrentKafkaListenerContainerFactory<Integer, String> kafkaListenerContainerFactory() {
    ConcurrentKafkaListenerContainerFactory<Integer, String> factory =
        new ConcurrentKafkaListenerContainerFactory<>();
    factory.setConsumerFactory(cf());
    factory.setReplyTemplate(template());
    factory.setReplyHeadersConfigurer((k, v) -> k.equals("cat"));
    return factory;
}
```

You can also add more headers if you wish. The following example shows how to do so:

```java
@Bean
public ConcurrentKafkaListenerContainerFactory<Integer, String> kafkaListenerContainerFactory() {
    ConcurrentKafkaListenerContainerFactory<Integer, String> factory =
        new ConcurrentKafkaListenerContainerFactory<>();
    factory.setConsumerFactory(cf());
    factory.setReplyTemplate(template());
    factory.setReplyHeadersConfigurer(new ReplyHeadersConfigurer() {

      @Override
      public boolean shouldCopy(String headerName, Object headerValue) {
        return false;
      }

      @Override
      public Map<String, Object> additionalHeaders() {
        return Collections.singletonMap("qux", "fiz");
      }

    });
    return factory;
}
```

When you use `@SendTo`, you must configure the `ConcurrentKafkaListenerContainerFactory` with a `KafkaTemplate` in its `replyTemplate` property to perform the send. Spring Boot will automatically wire in its auto-configured template (or any if a single instance is present).

> Unless you use [request/reply semantics](https://docs.spring.io/spring-kafka/reference/kafka/sending-messages.html#replying-template), only the simple `send(topic, value)` method is used, so you may wish to create a subclass to generate the partition or key. The following example shows how to do so:

```java
@Bean
public KafkaTemplate<String, String> myReplyingTemplate() {
    return new KafkaTemplate<String, String>(producerFactory()) {

        @Override
        public CompletableFuture<SendResult<String, String>> send(String topic, String data) {
            return super.send(topic, partitionForData(data), keyForData(data), data);
        }

        ...

    };
}
```

> If the listener method returns `Message<?>` or `Collection<Message<?>>`, the listener method is responsible for setting up the message headers for the reply. For example, when handling a request from a `ReplyingKafkaTemplate`, you might do the following:
> <div class="language-java highlighter-rouge"><div class="highlight"><pre class="highlight"><code><span class="nd">@KafkaListener</span><span class="o">(</span><span class="n">id</span> <span class="o">=</span> <span class="s">"messageReturned"</span><span class="o">,</span> <span class="n">topics</span> <span class="o">=</span> <span class="s">"someTopic"</span><span class="o">)</span>
<span class="kd">public</span> <span class="nc">Message</span><span class="o">&lt;?&gt;</span> <span class="n">listen</span><span class="o">(</span><span class="nc">String</span> <span class="n">in</span><span class="o">,</span> <span class="nd">@Header</span><span class="o">(</span><span class="nc">KafkaHeaders</span><span class="o">.</span><span class="na">REPLY_TOPIC</span><span class="o">)</span> <span class="kt">byte</span><span class="o">[]</span> <span class="n">replyTo</span><span class="o">,</span>
        <span class="nd">@Header</span><span class="o">(</span><span class="nc">KafkaHeaders</span><span class="o">.</span><span class="na">CORRELATION_ID</span><span class="o">)</span> <span class="kt">byte</span><span class="o">[]</span> <span class="n">correlation</span><span class="o">)</span> <span class="o">{</span>
    <span class="k">return</span> <span class="nc">MessageBuilder</span><span class="o">.</span><span class="na">withPayload</span><span class="o">(</span><span class="n">in</span><span class="o">.</span><span class="na">toUpperCase</span><span class="o">())</span>
            <span class="o">.</span><span class="na">setHeader</span><span class="o">(</span><span class="nc">KafkaHeaders</span><span class="o">.</span><span class="na">TOPIC</span><span class="o">,</span> <span class="n">replyTo</span><span class="o">)</span>
            <span class="o">.</span><span class="na">setHeader</span><span class="o">(</span><span class="nc">KafkaHeaders</span><span class="o">.</span><span class="na">KEY</span><span class="o">,</span> <span class="mi">42</span><span class="o">)</span>
            <span class="o">.</span><span class="na">setHeader</span><span class="o">(</span><span class="nc">KafkaHeaders</span><span class="o">.</span><span class="na">CORRELATION_ID</span><span class="o">,</span> <span class="n">correlation</span><span class="o">)</span>
            <span class="o">.</span><span class="na">setHeader</span><span class="o">(</span><span class="s">"someOtherHeader"</span><span class="o">,</span> <span class="s">"someValue"</span><span class="o">)</span>
            <span class="o">.</span><span class="na">build</span><span class="o">();</span>
<span class="o">}</span>
</code></pre></div></div>

When using request/reply semantics, the target partition can be requested by the sender.

> You can annotate a `@KafkaListener` method with `@SendTo` even if no result is returned. This is to allow the configuration of an `errorHandler` that can forward information about a failed message delivery to some topic. The following example shows how to do so:
> <div class="language-java highlighter-rouge"><div class="highlight"><pre class="highlight"><code><span class="nd">@KafkaListener</span><span class="o">(</span><span class="n">id</span> <span class="o">=</span> <span class="s">"voidListenerWithReplyingErrorHandler"</span><span class="o">,</span> <span class="n">topics</span> <span class="o">=</span> <span class="s">"someTopic"</span><span class="o">,</span>
        <span class="n">errorHandler</span> <span class="o">=</span> <span class="s">"voidSendToErrorHandler"</span><span class="o">)</span>
<span class="nd">@SendTo</span><span class="o">(</span><span class="s">"failures"</span><span class="o">)</span>
<span class="kd">public</span> <span class="kt">void</span> <span class="nf">voidListenerWithReplyingErrorHandler</span><span class="o">(</span><span class="nc">String</span> <span class="n">in</span><span class="o">)</span> <span class="o">{</span>
    <span class="k">throw</span> <span class="k">new</span> <span class="nf">RuntimeException</span><span class="o">(</span><span class="s">"fail"</span><span class="o">);</span>
<span class="o">}</span>
<span class="nd">@Bean</span>
<span class="kd">public</span> <span class="nc">KafkaListenerErrorHandler</span> <span class="nf">voidSendToErrorHandler</span><span class="o">()</span> <span class="o">{</span>
    <span class="k">return</span> <span class="o">(</span><span class="n">m</span><span class="o">,</span> <span class="n">e</span><span class="o">)</span> <span class="o">-&gt;</span> <span class="o">{</span>
        <span class="k">return</span> <span class="o">...</span> <span class="c1">// some information about the failure and input data</span>
    <span class="o">};</span>
<span class="o">}</span>
</code></pre></div></div>

> See [Handling Exceptions](https://docs.spring.io/spring-kafka/reference/kafka/annotation-error-handling.html) for more information.

> If a listener method returns an `Iterable`, by default a record for each element as the value is sent. Starting with version 2.3.5, set the `splitIterables` property on `@KafkaListener` to `false` and the entire result will be sent as the value of a single `ProducerRecord`. This requires a suitable serializer in the reply template’s producer configuration. However, if the reply is `Iterable<Message<?>>` the property is ignored and each message is sent separately.

---

## Filtering Messages

In certain scenarios, such as rebalancing, a message that has already been processed may be redelivered. The framework cannot know whether such a message has been processed or not. That is an application-level function. This is known as the [Idempotent Receiver](https://www.enterpriseintegrationpatterns.com/patterns/messaging/IdempotentReceiver.html) pattern and Spring Integration provides an [implementation](https://docs.spring.io/spring-integration/reference/handler-advice/idempotent-receiver.html) of it.

The Spring for Apache Kafka project also provides some assistance by means of the `FilteringMessageListenerAdapter` class, which can wrap your `MessageListener`. This class takes an implementation of `RecordFilterStrategy` in which you implement the `filter` method to signal that a message is a duplicate and should be discarded. This has an additional property called `ackDiscarded`, which indicates whether the adapter should acknowledge the discarded record. It is `false` by default.

When you use `@KafkaListener`, set the `RecordFilterStrategy` (and optionally `ackDiscarded`) on the container factory so that the listener is wrapped in the appropriate filtering adapter.

In addition, a `FilteringBatchMessageListenerAdapter` is provided, for when you use a batch [message listener](https://docs.spring.io/spring-kafka/reference/kafka/receiving-messages/message-listeners.html).

> The `FilteringBatchMessageListenerAdapter` is ignored if your `@KafkaListener` receives a `ConsumerRecords<?, ?>` instead of `List<ConsumerRecord<?, ?>>`, because `ConsumerRecords` is immutable.

Starting with version 2.8.4, you can override the listener container factory’s default `RecordFilterStrategy` by using the `filter` property on the listener annotations.

```java
@KafkaListener(id = "filtered", topics = "topic", filter = "differentFilter")
public void listen(Thing thing) {
    ...
}
```

Starting with version 3.3, Ignoring empty batches that result from filtering by `RecordFilterStrategy` is supported. When implementing `RecordFilterStrategy`, it can be configured through `ignoreEmptyBatch()`. The default setting is `false`, indicating `KafkaListener` will be invoked even if all `ConsumerRecord`s are filtered out.

If `true` is returned, the `KafkaListener` will not be invoked when all `ConsumerRecord` are filtered out. However, commit to broker, will still be executed.

If `false` is returned, the `KafkaListener` will be invoked when all `ConsumerRecord` are filtered out.

Here are some examples.

```java
public class IgnoreEmptyBatchRecordFilterStrategy implements RecordFilterStrategy {
    ...
    @Override
    public List<ConsumerRecord<String, String>> filterBatch(
            List<ConsumerRecord<String, String>> consumerRecords) {
        return List.of();
    }

    @Override
    public boolean ignoreEmptyBatch() {
        return true;
    }
};

// NOTE: ignoreEmptyBatchRecordFilterStrategy is bean name of IgnoreEmptyBatchRecordFilterStrategy instance.
@KafkaListener(id = "filtered", topics = "topic", filter = "ignoreEmptyBatchRecordFilterStrategy")
public void listen(List<Thing> things) {
    ...
}
```

In this case, `IgnoreEmptyBatchRecordFilterStrategy` always returns empty list and return `true` as result of `ignoreEmptyBatch()`. Thus `KafkaListener#listen(…)` never will be invoked at all.

```java
public class NotIgnoreEmptyBatchRecordFilterStrategy implements RecordFilterStrategy {
    ...
    @Override
    public List<ConsumerRecord<String, String>> filterBatch(
            List<ConsumerRecord<String, String>> consumerRecords) {
        return List.of();
    }

    @Override
    public boolean ignoreEmptyBatch() {
        return false;
    }
};

// NOTE: notIgnoreEmptyBatchRecordFilterStrategy is bean name of NotIgnoreEmptyBatchRecordFilterStrategy instance.
@KafkaListener(id = "filtered", topics = "topic", filter = "notIgnoreEmptyBatchRecordFilterStrategy")
public void listen(List<Thing> things) {
    ...
}
```

However, in this case, `IgnoreEmptyBatchRecordFilterStrategy` always returns empty list and return `false` as result of `ignoreEmptyBatch()`. Thus `KafkaListener#listen(…)` always will be invoked.

---

## Retrying Deliveries

See the `DefaultErrorHandler` in [Handling Exceptions](https://docs.spring.io/spring-kafka/reference/kafka/annotation-error-handling.html).

---

## Starting `@KafkaListener`s in Sequence

A common use case is to start a listener after another listener has consumed all the records in a topic. For example, you may want to load the contents of one or more compacted topics into memory before processing records from other topics. Starting with version 2.7.3, a new component `ContainerGroupSequencer` has been introduced. It uses the `@KafkaListener`'s `containerGroup` property to group containers together and start the containers in the next group, when all the containers in the current group have gone idle.

It is best illustrated with an example.

```java
@KafkaListener(id = "listen1", topics = "topic1", containerGroup = "g1", concurrency = "2")
public void listen1(String in) {
}

@KafkaListener(id = "listen2", topics = "topic2", containerGroup = "g1", concurrency = "2")
public void listen2(String in) {
}

@KafkaListener(id = "listen3", topics = "topic3", containerGroup = "g2", concurrency = "2")
public void listen3(String in) {
}

@KafkaListener(id = "listen4", topics = "topic4", containerGroup = "g2", concurrency = "2")
public void listen4(String in) {
}

@Bean
ContainerGroupSequencer sequencer(KafkaListenerEndpointRegistry registry) {
    return new ContainerGroupSequencer(registry, 5000, "g1", "g2");
}
```

Here, we have 4 listeners in two groups, `g1` and `g2`.

During application context initialization, the sequencer sets the `autoStartup` property of all the containers in the provided groups to `false`. It also sets the `idleEventInterval` for any containers (that do not already have one set) to the supplied value (5000ms in this case). Then, when the sequencer is started by the application context, the containers in the first group are started. As `ListenerContainerIdleEvent`s are received, each individual child container in each container is stopped. When all child containers in a `ConcurrentMessageListenerContainer` are stopped, the parent container is stopped. When all containers in a group have been stopped, the containers in the next group are started. There is no limit to the number of groups or containers in a group.

By default, the containers in the final group (`g2` above) are not stopped when they go idle. To modify that behavior, set `stopLastGroupWhenIdle` to `true` on the sequencer.

As an aside, previously containers in each group were added to a bean of type `Collection<MessageListenerContainer>` with the bean name being the `containerGroup`. These collections are now deprecated in favor of beans of type `ContainerGroup` with a bean name that is the group name, suffixed with `.group`; in the example above, there would be 2 beans `g1.group` and `g2.group`. The `Collection` beans will be removed in a future release.

---

## Using `KafkaTemplate` to Receive

This section covers how to use `KafkaTemplate` to receive messages.

Starting with version 2.8, the template has four `receive()` methods:

```java
ConsumerRecord<K, V> receive(String topic, int partition, long offset);

ConsumerRecord<K, V> receive(String topic, int partition, long offset, Duration pollTimeout);

ConsumerRecords<K, V> receive(Collection<TopicPartitionOffset> requested);

ConsumerRecords<K, V> receive(Collection<TopicPartitionOffset> requested, Duration pollTimeout);Copied!
```

As you can see, you need to know the partition and offset of the record(s) you need to retrieve; a new `Consumer` is created (and closed) for each operation.

With the last two methods, each record is retrieved individually and the results assembled into a `ConsumerRecords` object. When creating the `TopicPartitionOffset`s for the request, only positive, absolute offsets are supported.