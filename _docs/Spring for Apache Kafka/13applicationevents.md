---
title: Application Events
category: Spring for Apache Kafka
order: 14
permalink: /Spring for Apache Kafka/events/
description: 리스너 컨테이너와 컨슈머가 발행하는 스프링 애플리케이션 이벤트들
image: ./../../images/spring/logo.png
lastmod: 2025-09-12T23:34:00+09:00
comments: true
originalRefName: 스프링 카프카
originalRefLink: https://docs.spring.io/spring-kafka/reference/kafka/events.html
parent: Reference
parentUrl: /Spring for Apache Kafka/reference/
subparent: Using Spring for Apache Kafka
subparentUrl: /Spring for Apache Kafka/kafka/
---

---

리스너 컨테이너와 그 컨슈머들은 다음과 같은 스프링 애플리케이션 이벤트를 발행한다:

- `ConsumerStartingEvent`: 컨슈머 스레드가 처음 시작할 때 폴링을 시작 전에 발행한다.
- `ConsumerStartedEvent`: 컨슈머가 폴링을 시작하려는 시점에 발행한다.
- `ConsumerFailedToStartEvent`: 컨테이너 프로퍼티 `consumerStartTimeout` 내에 `ConsumerStartingEvent`가 발행되지 않으면 발행된다. 이 이벤트가 발생했다는 것은 설정한 task executor의 스레드 수로는 컨테이너와 그 concurrency를 감당할 수 없다는 신호일 수 있다. 이런 상황에선 에러 로그도 출력된다.
- `ListenerContainerIdleEvent`: (설정한 경우)`idleEventInterval` 내에 메시지를 수신하지 못하면 발행한다.
- `ListenerContainerNoLongerIdleEvent`: `ListenerContainerIdleEvent`를 발행한 이후 레코드를 컨슘하면 발행한다.
- `ListenerContainerPartitionIdleEvent`: (설정한 경우)`idleEventInterval` 내에 특정 파티션에서 메시지를 수신하지 못하면 발행한다.
- `ListenerContainerPartitionNoLongerIdleEvent`: `ListenerContainerPartitionIdleEvent`를 발행한 이후 해당 파티션에서 레코드를 컨슘하면 발행한다.
- `NonResponsiveConsumerEvent`: 컨슈머가 `poll` 메소드에서 블로킹된 것으로 보일 때 발행된다.
- `ConsumerPartitionPausedEvent`: 파티션이 중단되면 컨슈머마다 발행한다.
- `ConsumerPartitionResumedEvent`: 파티션이 재개되면 컨슈머마다 발행한다.
- `ConsumerPausedEvent`: 컨테이너가 중단되면 컨슈머마다 발행한다.
- `ConsumerResumedEvent`: 컨테이너가 재개되면 컨슈머마다 발행한다.
- `ConsumerStoppingEvent`: 각 컨슈머가 중지하기 직전에 발행한다.
- `ConsumerStoppedEvent`: 컨슈머가 닫힌 후 발행한다. [Thread Safety](https://docs.spring.io/spring-kafka/reference/kafka/thread-safety.html)를 참고해라.
- `ConsumerRetryAuthEvent`: 컨슈머가 인증<sup>authentication</sup> 또는 인가<sup>authorization</sup>에 실패해서 재시도 중일 때 발행한다.
- `ConsumerRetryAuthSuccessfulEvent`: 인증<sup>authentication</sup> 또는 인가<sup>authorization</sup> 재시도에 성공하면 발행된다. 이 이벤트는 `ConsumerRetryAuthEvent`가 발행된 적이 있었을 때만 발생한다.
- `ContainerStoppedEvent`: 모든 컨슈머가 중지되면 발행한다.
- `ConcurrentContainerStoppedEvent`: `ConcurrentMessageListenerContainer`가 중지되면 발행한다.

> 기본적으로 애플리케이션 컨텍스트의 이벤트 멀티캐스터는 호출 스레드에서 이벤트 리스너를 실행한다. 멀티캐스터를 async executor를 사용하도록 변경한다면, 이벤트가 컨슈머에 대한 참조를 가지고 있어도 `Consumer`의 메소드를 호출하면 안 된다.

`ListenerContainerIdleEvent`는 다음과 같은 프로퍼티를 가지고 있다:

- `source`: 이벤트를 발행한 리스너 컨테이너 인스턴스.
- `container`: 리스너 컨테이너 또는 source 컨테이너가 자식일 경우 부모 리스너 컨테이너.
- `id`: 리스너 ID (또는 컨테이너 빈 이름).
- `idleTime`: 이벤트가 발생했을 당시 컨테이너가 idle 상태였던 시간.
- `topicPartitions`: 이벤트가 발생했을 당시 컨테이너에 할당되어 있던 토픽과 파티션.
- `consumer`: 카프카 `Consumer` 객체에 대한 참조. 예를 들어, 이전에 컨슈머의 `pause()`를 호출한 상태라면 이 이벤트를 받아 `resume()`을 호출할 수 있다.
- `paused`: 컨테이너가 현재 정지 상태인지 여부. 자세한 내용은 [리스너 컨테이너 일시 중지하고 재개하기](../pause-resume)를 참고해라.

`ListenerContainerNoLongerIdleEvent`는 `idleTime`과 `paused`를 제외하고는 동일한 프로퍼티를 가지고 있다.

`ListenerContainerPartitionIdleEvent`는 다음과 같은 프로퍼티를 가지고 있다:

- `source`: 이벤트를 발행한 리스너 컨테이너 인스턴스.
- `container`: 리스너 컨테이너 또는 source 컨테이너가 자식일 경우 부모 리스너 컨테이너.
- `id`: 리스너 ID (또는 컨테이너 빈 이름).
- `idleTime`: 이벤트가 발생했을 당시 파티션 컨슈밍이 idle 상태였던 시간.
- `topicPartition`: 이벤트를 유발한 토픽과 파티션.
- `consumer`: 카프카 `Consumer` 객체에 대한 참조. 예를 들어, 이전에 컨슈머의 `pause()`를 호출한 상태라면 이 이벤트를 받아 `resume()`을 호출할 수 있다.
- `paused`: 해당 파티션 컨슈밍이 현재 컨슈머에서 멈춰 있는 상태인지 여부. 자세한 내용은 [리스너 컨테이너 일시 중지하고 재개하기](../pause-resume)를 참고해라.

`ListenerContainerPartitionNoLongerIdleEvent`는 `idleTime`과 `paused`를 제외하고는 동일한 프로퍼티를 가지고 있다.

`NonResponsiveConsumerEvent`는 다음과 같은 프로퍼티를 가지고 있다:

- `source`: 이벤트를 발행한 리스너 컨테이너 인스턴스.
- `container`: 리스너 컨테이너 또는 source 컨테이너가 자식일 경우 부모 리스너 컨테이너.
- `id`: 리스너 ID (또는 컨테이너 빈 이름).
- `timeSinceLastPoll`: 컨테이너가 마지막으로 `poll()`을 호출하기 직전의 시각.
- `topicPartitions`: 이벤트가 발생했을 당시 컨테이너에 할당되어 있던 토픽과 파티션.
- `consumer`: 카프카 `Consumer` 객체에 대한 참조. 예를 들어, 이전에 컨슈머의 `pause()`를 호출한 상태라면 이 이벤트를 받아 `resume()`을 호출할 수 있다.
- `paused`: 컨테이너가 현재 정지 상태인지 여부. 자세한 내용은 [리스너 컨테이너 일시 중지하고 재개하기](../pause-resume)를 참고해라.

`ConsumerPausedEvent`, `ConsumerResumedEvent`, `ConsumerStoppingEvent`는 다음과 같은 프로퍼티를 가지고 있다:

- `source`: 이벤트를 발행한 리스너 컨테이너 인스턴스.
- `container`: 리스너 컨테이너 또는 source 컨테이너가 자식일 경우 부모 리스너 컨테이너.
- `partitions`: 관련 `TopicPartition` 인스턴스들.

`ConsumerPartitionPausedEvent`, `ConsumerPartitionResumedEvent`는 다음과 같은 프로퍼티를 가지고 있다:

- `source`: 이벤트를 발행한 리스너 컨테이너 인스턴스.
- `container`: 리스너 컨테이너 또는 source 컨테이너가 자식일 경우 부모 리스너 컨테이너.
- `partition`: 관련 `TopicPartition` 인스턴스들.

`ConsumerRetryAuthEvent`는 다음과 같은 프로퍼티를 가지고 있다:

- `source`: 이벤트를 발행한 리스너 컨테이너 인스턴스.
- `container`: 리스너 컨테이너 또는 source 컨테이너가 자식일 경우 부모 리스너 컨테이너.
- `reason`:
  - `AUTHENTICATION` - `AuthenticationException`으로 이벤트를 발행한 경우.
  - `AUTHORIZATION` - `AuthorizationException`으로 이벤트를 발행한 경우.

`ConsumerStartingEvent`, `ConsumerStartedEvent`, `ConsumerFailedToStartEvent`, `ConsumerStoppedEvent`, `ConsumerRetryAuthSuccessfulEvent`, `ContainerStoppedEvent`는 다음과 같은 프로퍼티를 가지고 있다:

- `source`: 이벤트를 발행한 리스너 컨테이너 인스턴스.
- `container`: 리스너 컨테이너 또는 source 컨테이너가 자식일 경우 부모 리스너 컨테이너.

모든 컨테이너는 자식이든 부모든 상관 없이 `ContainerStoppedEvent`를 발행한다. 부모 컨테이너의 경우 source와 container 프로퍼티 값이 동일하다.

추가로, `ConsumerStoppedEvent`는 다음과 같은 별도 프로퍼티를 가지고 있다:

- `reason`:
  - `NORMAL` - 컨슈머가 정상적으로 종료된 경우 (컨테이너가 종료됨).
  - `ABNORMAL` - 컨슈머가 비정상적으로 종료된 경우 (컨테이너가 비정상적으로 중지됨).
  - `ERROR` - `java.lang.Error`가 발생한 경우.
  - `FENCED` - 트랜잭션 지원 프로듀서가 접근 권한을 빼았겼으며<sup>fenced</sup>, 컨테이너 프로퍼티 `stopContainerWhenFenced`가 `true`인 경우.
  - `AUTH` - `AuthenticationException`이나 `AuthorizationException`이 발생했으며 `authExceptionRetryInterval`을 설정하지 않은 경우.
  - `NO_OFFSET` - 특정 파티션에 오프셋이 없고 `auto.offset.reset` 정책이 `none`인 경우.

컨슈머 중단 이벤트가 발생됐다면, 이 이벤트를 통해 컨테이너를 재시작할 수 있다:

```java
if (event.getReason().equals(Reason.FENCED)) {
    event.getSource(MessageListenerContainer.class).start();
}
```

---

## Detecting Idle and Non-Responsive Consumers

비동기 컨슈머는 효율적이지만, 유휴<sup>idle</sup> 상태를 감지하는 것이 문제다. 일정 시간 동안 메시지가 도착하지 않으면 어떤 조치를 취하고 싶을 수도 있다.

일정 시간 동안 어떠한 메시지도 전달받지 않으면 리스너 컨테이너에서 `ListenerContainerIdleEvent`를 발행하도록 설정할 수 있다. 그러면 컨테이너가 유휴 상태인 동안에는 `idleEventInterval`(밀리세컨드) 간격으로 이벤트를 발행한다.

이 기능을 사용하려면 컨테이너에 `idleEventInterval`을 설정하면 된다. 그 방법은 아래 예시를 참고해라:

```java
@Bean
public KafkaMessageListenerContainer(ConsumerFactory<String, String> consumerFactory) {
    ContainerProperties containerProps = new ContainerProperties("topic1", "topic2");
    ...
    containerProps.setIdleEventInterval(60000L);
    ...
    KafkaMessageListenerContainer<String, String> container = new KafKaMessageListenerContainer<>(consumerFactory, containerProps);
    return container;
}
```

다음은 `@KafkaListener`를 사용할 때 `idleEventInterval`을 설정하는 예시다:

```java
@Bean
public ConcurrentKafkaListenerContainerFactory kafkaListenerContainerFactory() {
    ConcurrentKafkaListenerContainerFactory<String, String> factory =
                new ConcurrentKafkaListenerContainerFactory<>();
    ...
    factory.getContainerProperties().setIdleEventInterval(60000L);
    ...
    return factory;
}
```

두 예시 모두 컨테이너가 유휴 상태인 동안 1분에 한 번씩 이벤트를 발행한다.

어떤한 이유로 컨슈머의 `poll()` 메소드가 끝나지 않는다면, 메시지 자체를 받아오지 못해 idle 이벤트를 생성할 수 없게 된다 (`kafka-clients` 초기 버전에서 브로커에 연결할 수 없을 때 문제가 되었던 부분이다). 이 경우 컨테이너는 `pollTimeout` 프로퍼티에 3을 곱한 시간 내에 poll 메소드가 반환되지 않으면 `NonResponsiveConsumerEvent`를 발행한다. 각 컨테이너는 기본적으로 30초마다 `NonResponsiveConsumerEvent`를 발행할지를 체크한다. 이 동작을 변경하고 싶다면, 리스너 컨테이너를 구성할 때 `ContainerProperties`의 `monitorInterval`(디폴트 30초)과 `noPollThreshold`(디폴트 3.0) 프로퍼티를 수정하면 된다. 경쟁 상태<sup>race condition</sup>로 인한 무의미한 이벤트가 발생하지 않도록 `noPollThreshold` 값은 1.0보다 크게 설정해야 한다. 이러한 이벤트를 수신하면 컨테이너를 종료시킬 수 있고, 그러면 컨슈머도 깨워 종료시킬 수 있다.

2.6.2 버전부터 컨테이너가 `ListenerContainerIdleEvent`를 발행한 이후 레코드를 수신하게 되면
 `ListenerContainerNoLongerIdleEvent`를 발행한다.

---

## Event Consumption

다음에 나오는 예시는 `@KafkaListener`와 `@EventListener`를 하나의 클래스에 작성한다. 애플리케이션 리스너는 모든 컨테이너의 이벤트를 받는다는 점을 주의해라. 따라서 어떤 컨테이너가 유휴<sup>idle</sup> 상태인지에 따라 다른 작업을 수행하고 싶다면 리스너 ID를 체크해야 한다. 이런 이유라면 `@EventListener`의 `condition`을 사용하는 방법도 있다.

이벤트 프로퍼티에 대한 자세한 내용은 [애플리케이션 이벤트](./)를 참고해라.

이 이벤트는 일반적으로 컨슈머 스레드에서 발행하므로, `Consumer` 객체를 직접 사용해도 안전하다.

다음은 `@KafkaListener`와 `@EventListener`를 사용하는 예시다:

```java
public class Listener {

    @KafkaListener(id = "qux", topics = "annotated")
    public void listen4(@Payload String foo, Acknowledgment ack) {
        ...
    }

    @EventListener(condition = "event.listenerId.startsWith('qux-')")
    public void eventHandler(ListenerContainerIdleEvent event) {
        ...
    }

}
```

> 이벤트 리스너는 모든 컨테이너의 이벤트를 수신한다. 따라서 위 예시에서는 리스너 ID를 사용해 수신할 이벤트를 특정한다. `@KafkaListener`로 생성된 컨테이너는 concurrency를 지원하므로, 실제 컨테이너 이름은 `id-n` 형식이며, 여기서 `n`은 concurrency 지원을 위해 각 인스턴스에 부여하는 고유 값이다. 이 때문에 condition에 `startsWith`를 사용하고 있다.

> idle 이벤트를 통해 리스너 컨테이너를 중지하고 싶더라도, 리스너를 호출한 스레드에서 `container.stop()`을 호출해선 안 된다. 그렇게 되면 지연이 발생하며, 불필요한 로그가 출력될 수 있다. 그대신 이벤트를 다른 스레드로 넘기고 거기서 컨테이너를 중지하면 된다. 또한 컨테이너 인스턴스가 자식 컨테이너인 경우에도 `stop()`을 호출하면 안 된다. 대신 concurrent 컨테이너에서 `stop()`을 호출해라.

### Current Positions when Idle

리스너에서 `ConsumerSeekAware`를 구현하면, 유후<sup>idle</sup> 상태를 감지했을 때 현재 position을 획득할 수 있다. 자세한 내용은 [seek](https://docs.spring.io/spring-kafka/reference/kafka/seek.html) 문서에 있는 `onIdleContainer()`를 참고해라.