---
title: Seeking to a Specific Offset
category: Spring for Apache Kafka
order: 16
permalink: /Spring for Apache Kafka/seek/
description: 특정 오프셋으로 되돌아가기
image: ./../../images/spring/logo.png
lastmod: 2025-09-12T23:34:00+09:00
comments: true
originalRefName: 스프링 카프카
originalRefLink: https://docs.spring.io/spring-kafka/reference/kafka/seek.html
parent: Reference
parentUrl: /Spring for Apache Kafka/reference/
subparent: Using Spring for Apache Kafka
subparentUrl: /Spring for Apache Kafka/kafka/
---

---

오프셋을 되돌리려면<sup>seek</sup>, 리스너가 `ConsumerSeekAware`를 구현하고 있어야 한다. `ConsumerSeekAware` 인터페이스는 다음 메소드들을 가지고 있다:

```java
void registerSeekCallback(ConsumerSeekCallback callback);

void onPartitionsAssigned(Map<TopicPartition, Long> assignments, ConsumerSeekCallback callback);

void onPartitionsRevoked(Collection<TopicPartition> partitions);

void onIdleContainer(Map<TopicPartition, Long> assignments, ConsumerSeekCallback callback);
```

`registerSeekCallback`은 컨테이너가 시작될 때, 그리고 파티션이 할당될 때마다 실행된다. 초기화 이후 임의의 시점에 오프셋을 변경<sup>seek</sup>하려면 이 콜백을 사용해라. 이때 콜백에 대한 참조는 따로 저장해 두어야 한다. 여러 컨테이너에서 하나의 리스너를 사용하는 경우 (`ConcurrentMessageListenerContainer` 포함), 콜백은 `ThreadLocal`이나 리스너 `Thread`를 키로 사용하는 다른 곳에 저장해야 한다.

그룹 관리<sup>group management</sup>를 이용하는 경우, 파티션이 할당되면 `onPartitionsAssigned`가 호출된다. 이 메소드를 통해 콜백을 호출하면 파티션의 초기 오프셋을 세팅할 수 있다. 또한 이 메소드를 이용해 해당 스레드의 콜백을 할당된 파티션에 연결할 수도 있다 (아래 예시 참고). 이때는 `registerSeekCallback`에 전달된 콜백이 아니라, 이 메소드의 인자로 전달된 콜백을 사용해야 한다. 2.5.5 버전부터는 [수동으로 파티션을 할당](../receiving-messages/#explicit-partition-assignment)할 때도 이 메소드가 호출된다.

`onPartitionsRevoked`는 컨테이너가 중지되거나 카프카가 할당된 파티션을 회수할 때 호출된다. 이땐 해당 스레드의 콜백은 폐기하고, 회수된 파티션과의 연결을 모두 제거해야 한다.

`ConsumerSeekCallback`은 다음과 같은 메소드를 가지고 있다:

```java
void seek(String topic, int partition, long offset);

void seek(String topic, int partition, Function<Long, Long> offsetComputeFunction);

void seekToBeginning(String topic, int partition);

void seekToBeginning(Collection<TopicPartitions> partitions);

void seekToEnd(String topic, int partition);

void seekToEnd(Collection<TopicPartitions> partitions);

void seekRelative(String topic, int partition, long offset, boolean toCurrent);

void seekToTimestamp(String topic, int partition, long timestamp);

void seekToTimestamp(Collection<TopicPartition> topicPartitions, long timestamp);

String getGroupId();
```

두 가지 `seek` 메소드로는 임의의 오프셋으로 되돌아갈<sup>seek</sup>수 있다. 프레임워크의 3.2 버전에선 오프셋을 계산할 수 있는 `Function`을 인자로 받는 메소드가 추가됐다. 이 함수는 현재 오프셋(컨슈머가 반환하는 현재 위치, 즉 다음번에 fetch할 오프셋)에 접근할 수 있다. 사용자는 함수 정의 내부에서 컨슈머의 현재 오프셋을 기준으로 되돌아갈<sup>seek</sup> 오프셋을 결정할 수 있다.

`seekRelative`는 2.3 버전에서 추가되었으며, 이동할 오프셋을 상대적인 위치로부터 계산한다.

- 음수 `offset`과 `toCurrent` `false` — 파티션의 끝을 기준으로 오프셋을 이동한다.
- 양수 `offset`과 `toCurrent` `false` — 파티션의 시작을 기준으로 오프셋을 이동한다.
- 음수 `offset`과 `toCurrent` `true` — 현재 파티션을 기준으로 오프셋을 이동한다 (rewind).
- 양수 `offset`과 `toCurrent` `true` — 현재 파티션을 기준으로 오프셋을 이동한다 (fast forward).

`seekToTimestamp` 메소드 역시 2.3 버전에 추가됐다.

> 여러 파티션에서 같은 타임스탬프로 오프셋을 옮기려면, `onIdleContainer` 메소드보단 `onPartitionsAssigned`를 이용하는 것이 좋다. 컨슈머의 `offsetsForTimes` 메소드를 단 한 번만 호출해서 타임스탬프에 맞는 오프셋을 더 효율적으로 찾을 수 있기 때문이다. 여러 곳에서 호출하는 경우, 컨테이너는 타임스탬프 기반 오프셋 이동 요청을 모두 모아서 한 번의 `offsetsForTimes` 호출로 처리한다.

유휴<sup>idle</sup> 컨테이너가 감지되었을 때는 `onIdleContainer()`에서 오프셋을 이동시킬 수도 있다. 유휴 컨테이너 감지를 활성화하는 방법은 [Idle & Non-Responsive 컨슈머 감지하기](../events/#detecting-idle-and-non-responsive-consumers)를 참고해라.

> 컬렉션을 받는 `seekToBeginning` 메소드는, 압축<sup>compacted</sup> 토픽을 처리할 때 애플리케이션이 시작될 때마다 항상 시작점으로 오프셋을 이동시키는 등에 활용하기 좋다:

```java
public class MyListener implements ConsumerSeekAware {

    ...

    @Override
    public void onPartitionsAssigned(Map<TopicPartition, Long> assignments, ConsumerSeekCallback callback) {
        callback.seekToBeginning(assignments.keySet());
    }

}
```

런타임에 임의로 오프셋을 이동시키려면, 해당 스레드에 맞는 `registerSeekCallback`으로 받은 콜백 참조를 사용해라.

다음은 콜백을 사용하는 간단한 스프링 부트 애플리케이션이다. 이 애플리케이션은 토픽에 10개의 레코드를 전송하며, 콘솔에서 `<Enter>`를 입력하면 모든 파티션의 오프셋을 시작점으로 이동시킨다.

```java
@SpringBootApplication
public class SeekExampleApplication {

    public static void main(String[] args) {
        SpringApplication.run(SeekExampleApplication.class, args);
    }

    @Bean
    public ApplicationRunner runner(Listener listener, KafkaTemplate<String, String> template) {
        return args -> {
            IntStream.range(0, 10).forEach(i -> template.send(
                new ProducerRecord<>("seekExample", i % 3, "foo", "bar")));
            while (true) {
                System.in.read();
                listener.seekToStart();
            }
        };
    }

    @Bean
    public NewTopic topic() {
        return new NewTopic("seekExample", 3, (short) 1);
    }

}

@Component
class Listener implements ConsumerSeekAware {

    private static final Logger logger = LoggerFactory.getLogger(Listener.class);

    private final ThreadLocal<ConsumerSeekCallback> callbackForThread = new ThreadLocal<>();

    private final Map<TopicPartition, ConsumerSeekCallback> callbacks = new ConcurrentHashMap<>();

    @Override
    public void registerSeekCallback(ConsumerSeekCallback callback) {
        this.callbackForThread.set(callback);
    }

    @Override
    public void onPartitionsAssigned(Map<TopicPartition, Long> assignments, ConsumerSeekCallback callback) {
        assignments.keySet().forEach(tp -> this.callbacks.put(tp, this.callbackForThread.get()));
    }

    @Override
    public void onPartitionsRevoked(Collection<TopicPartition> partitions) {
        partitions.forEach(tp -> this.callbacks.remove(tp));
        this.callbackForThread.remove();
    }

    @Override
    public void onIdleContainer(Map<TopicPartition, Long> assignments, ConsumerSeekCallback callback) {
    }

    @KafkaListener(id = "seekExample", topics = "seekExample", concurrency = "3")
    public void listen(ConsumerRecord<String, String> in) {
        logger.info(in.toString());
    }

    public void seekToStart() {
        this.callbacks.forEach((tp, callback) -> callback.seekToBeginning(tp.topic(), tp.partition()));
    }

}
```

2.3 버전에서는 `AbstractConsumerSeekAware` 클래스가 추가되어 더 간단해졌다. 이 클래스를 사용하면 토픽/파티션마다 어떤 콜백을 사용해야 하는지 따로 추적하지 않아도 된다. 아래 예시는 컨테이너가 유휴<sup>idle</sup> 상태가 될 때마다 각 파티션에서 마지막으로 처리한 레코드로 오프셋을 이동시킨다. 또한 외부에서 임의로 호출해서 파티션을 한 레코드만큼 되돌아갈<sup>rewind</sup> 수 있는 메소드들도 존재한다.

```java
public class SeekToLastOnIdleListener extends AbstractConsumerSeekAware {

    @KafkaListener(id = "seekOnIdle", topics = "seekOnIdle")
    public void listen(String in) {
        ...
    }

    @Override
    public void onIdleContainer(Map<TopicPartition, Long> assignments,
            ConsumerSeekCallback callback) {

            assignments.keySet().forEach(tp -> callback.seekRelative(tp.topic(), tp.partition(), -1, true));
    }

    /**
    * Rewind all partitions one record.
    */
    public void rewindAllOneRecord() {
        getTopicsAndCallbacks()
            .forEach((tp, callbacks) ->
                    callbacks.forEach(callback -> callback.seekRelative(tp.topic(), tp.partition(), -1, true))
            );
    }

    /**
    * Rewind one partition one record.
    */
    public void rewindOnePartitionOneRecord(String topic, int partition) {
        getSeekCallbacksFor(new TopicPartition(topic, partition))
            .forEach(callback -> callback.seekRelative(topic, partition, -1, true));
    }

}
```

2.6 버전에선 `AbstractConsumerSeekAware`에 몇 가지 편의 메소드가 더 추가됐다:

- `seekToBeginning()` - 할당된 모든 파티션의 오프셋을 시작점으로 이동시킨다.
- `seekToEnd()` - 할당된 모든 파티션의 오프셋을 끝으로 이동시킨다.
- `seekToTimestamp(long timestamp)` - 할당된 모든 파티션을 해당 타임스탬프가 나타내는 오프셋으로 이동시킨다.

*Example*:

```java
public class MyListener extends AbstractConsumerSeekAware {

    @KafkaListener(...)
    void listen(...) {
        ...
    }
}

public class SomeOtherBean {

    MyListener listener;

    ...

    void someMethod() {
        this.listener.seekToTimestamp(System.currentTimeMillis() - 60_000);
    }

}
```

3.3 버전부터는 `ConsumerSeekAware.ConsumerSeekCallback` 인터페이스에 `getGroupId()` 메소드가 추가됐다. 이 메소드는 seek 콜백이 어떤 컨슈머 그룹과 관련있는지 식별해야 할 때 특히 유용하다.

> `AbstractConsumerSeekAware`를 상속한 클래스를 사용하는 경우, 리스너 하나에서 오프셋을 이동시키더라도, 같은 클래스 내에 있는 모든 리스너에 영향을 줄 수 있다. 항상 이렇게 동작하길 바라진 않을 것이다. 이 문제를 해결하려면 콜백에서 제공하는 `getGroupId()` 메소드를 사용해라. 이 메소드를 이용하면 원하는 컨슈머 그룹만 타겟해서 오프셋을 이동시킬 수 있다.