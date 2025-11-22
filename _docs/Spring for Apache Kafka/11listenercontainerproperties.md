---
title: Listener Container Properties
category: Spring for Apache Kafka
order: 12
permalink: /Spring for Apache Kafka/container-props/
description: 스프링 카프카 컨테이너 프로퍼티 총정리
image: ./../../images/spring/logo.png
lastmod: 2025-09-12T23:34:00+09:00
comments: true
originalRefName: 스프링 카프카
originalRefLink: https://docs.spring.io/spring-kafka/reference/kafka/container-props.html
parent: Reference
parentUrl: /Spring for Apache Kafka/reference/
subparent: Using Spring for Apache Kafka
subparentUrl: /Spring for Apache Kafka/kafka/
---

---

*Table 1.* `ContainerProperties` *Properties*

| Property                                  | Default                   | Description                                                  |
| :---------------------------------------- | :------------------------ | :----------------------------------------------------------- |
| `ackCount`                                | 1                         | `ackMode`가 `COUNT` 또는 `COUNT_TIME`일 때, 대기 중인 오프셋을 커밋하기 전에 처리할 레코드 수. |
| `adviceChain`                             | `null`                    | 메시지 리스너를 감싸고 있는, 순서대로 실행되는 `Advice` 객체 체인 (e.g. `MethodInterceptor` around advice). |
| `ackMode`                                 | BATCH                     | 오프셋 커밋 방식을 제어한다 - [오프셋 커밋하기](../receiving-messages/#committing-offsets) 참고. |
| `ackTime`                                 | 5000                      | `ackMode`가 `TIME` 또는 `COUNT_TIME`일 때, 대기 중인 오프셋을 커밋하기까지 기다리는 시간 (밀리세컨드) |
| `assignmentCommitOption`                  | LATEST_ONLY _NO_TX        | 파티션이 할당될 때 초기 오프셋 위치를 커밋할지 여부. 기본적으로는 `ConsumerConfig.AUTO_OFFSET_RESET_CONFIG`가 `latest`일 때만 초기 오프셋을 커밋하며, 트랜잭션 매니저가 있더라도 트랜잭션 안에서 실행되지 않는다. 가능한 옵션들에 대해서는 `ContainerProperties.AssignmentCommitOption` JavaDoc을 참고해라. |
| `asyncAcks`                               | `false`                   | 비순차적<sup>out-of-order</sup> 커밋을 활성화한다 ([수동으로 오프셋 커밋하기 참고](../receiving-messages/#manually-committing-offsets)). 컨슈머는 일시 중지 상태가 되며, 누락된 ack를 모두 수신할 때까지 커밋을 보류한다. |
| `authExceptionRetryInterval`              | `null`                    | 카프카 클라이언트에서 `AuthenticationException`이나 `AuthorizationException`이 발생하면 이 `Duration`만큼 멈췄다가 다음 폴링을 수행한다. 이 값이 null이면, 이러한 예외를 치명적인 에러로 간주하고 컨테이너를 중지한다. |
| `batchRecoverAfterRollback`               | `false`                   | `true`로 설정하면 배치 단위 복구를 활성화한다. [After Rollback Processor](../annotation-error-handling/#after-rollback-processor)를 참고해라. |
| `clientId`                                | (empty string)            | 컨슈머 프로퍼티 `client.id`에 적용할 프리픽스. 컨슈머 팩토리의 `client.id` 프로퍼티를 재정의한다. concurrent 컨테이너에서는 각 컨슈머 인스턴스마다 뒤에 `-n`이 추가된다. |
| `checkDeserExWhenKeyNull`                 | false                     | `true`로 설정하면 수신한 메시지의 key가 null인 경우 항상 `DeserializationException` 헤더를 확인한다. `DelegatingDeserializer`를 사용하는 경우 등, 컨슈머 코드에 `ErrorHandlingDeserializer` 설정 여부를 알 수 없는 경우에 유용하다. |
| `checkDeserExWhenValueNull`               | false                     | `true`로 설정하면 수신한 메시지의 value가 null인 경우 항상 `DeserializationException` 헤더를 확인한다. `DelegatingDeserializer`를 사용하는 경우 등, 컨슈머 코드에 `ErrorHandlingDeserializer` 설정 여부를 알 수 없는 경우에 유용하다. |
| `commitCallback`                          | `null`                    | 값을 지정했다면, `syncCommits`가 `false`이면 커밋을 완료한 후에 이 콜백을 호출한다. |
| `commitLogLevel`                          | DEBUG                     | 오프셋 커밋과 관련된 로그에 사용할 로그 레벨.                |
| `consumerRebalanceListener`               | `null`                    | 리밸런스 리스너를 지정한다. [리밸런싱 리스너 문서](../receiving-messages/#rebalancing-listeners)를 참고해라. |
| `commitRetries`                           | 3                         | `syncCommits`를 true로 설정했을 때, `RetriableCommitFailedException` 발생 시 재시도할 횟수를 설정한다. 기본값은 3이다 (총 4회 시도). |
| `consumerStartTimeout`                    | 30s                       | 컨슈머가 시작하기를 기다리는 시간으로, 이 시간이 경과하면 에러를 기록한다. 예를 들면 task executor 사용 중에 스레드가 부족한 경우 발생할 수 있다. |
| `deliveryAttemptHeader`                   | `false`                   | [Delivery Attempts 헤더](../annotation-error-handling/#delivery-attempts-header) 참고. |
| `eosMode`                                 | `V2`                      | Exactly Once Semantics 모드. [Exactly Once Semantics](https://docs.spring.io/spring-kafka/reference/kafka/exactly-once.html) 문서를 참고해라. |
| `fixTxOffsets`                            | `false`                   | 트랜잭션을 지원하는 프로듀서가 생성한 레코드를 컨슘할 때, 컨슈머가 파티션의 끝에 위치해 있다면, 트랜잭션 커밋/롤백을 표시하기 위한 슈도<sup>pseudo</sup> 레코드와 롤백된 레코드의 존재로 인해 랙이 0보다 큰 것으로 잘못 보고될 수 있다. 기능적으로 컨슈머에 영향을 미치지 않지만, “랙”이 0이 아니라는 점에 우려를 표한 사용자도 있었다. 이 프로퍼티를 `true`로 설정하게 되면 컨테이너가 잘못 보고한 오프셋을 바로잡는다. 커밋 과정을 불필요하게 복잡하게 만들지 않도록 다음번 폴링 전에 검사를 수행한다. 이 글을 쓰는 시점 기준으로는, 컨슈머를 `isolation.level=read_committed`로 설정하고 `max.poll.records`가 1보다 클 때만 랙을 수정한다. 자세한 내용은 [KAFKA-10683](https://issues.apache.org/jira/browse/KAFKA-10683)을 참고해라. |
| `groupId`                                 | `null`                    | 컨슈머 프로퍼티 `group.id`를 재정의한다. 자동으로 `@KafkaListener`의 `id` 또는 `groupId` 프로퍼티로 설정된다. |
| `idleBeforeDataMultiplier`                | 5.0                       | 레코드를 수신하기 전에 `idleEventInterval`에 적용하는 배율. 레코드를 수신한 이후에는 더 이상 배율을 적용하지 않는다. 2.8 버전부터 지원한다. |
| `idleBetweenPolls`                        | 0                         | 폴링을 반복할 때 각 poll 사이에서 스레드를 멈춰서 전달 속도를 늦추는 데 사용한다. 레코드 배치 처리 시간에 이 값을 더한 값은 컨슈머 프로퍼티 `max.poll.interval.ms`보다 작아야 한다. |
| `idleEventInterval`                       | `null`                    | 설정 시 `ListenerContainerIdleEvent`의 발행을 활성화한다. 자세한 내용은 [애플리케이션 이벤트](https://docs.spring.io/spring-kafka/reference/kafka/events.html)와 [유휴<sup>idle</sup> 및 응답이 없는 컨슈머 탐지하기](https://docs.spring.io/spring-kafka/reference/kafka/events.html#idle-containers)를 참고해라. `idleBeforeDataMultiplier`도 함께 참고해라. |
| `idlePartitionEventInterval`              | `null`                    | 설정 시 `ListenerContainerIdlePartitionEvent` 발행을 활성화한다. 자세한 내용은 [애플리케이션 이벤트](https://docs.spring.io/spring-kafka/reference/kafka/events.html)와 [유휴<sup>idle</sup> 및 응답이 없는 컨슈머 탐지하기](https://docs.spring.io/spring-kafka/reference/kafka/events.html#idle-containers)를 참고해라. |
| `kafkaConsumerProperties`                 | None                      | 컨슈머 팩토리에 설정한 임의의 컨슈머 프로퍼티를 재정의하는 데 사용한다. |
| `kafkaAwareTransactionManager`            | `null`                    | [트랜잭션](https://docs.spring.io/spring-kafka/reference/kafka/transactions.html) 참고. |
| `listenerTaskExecutor`                    | `SimpleAsyncTaskExecutor` | 컨슈머 스레드를 실행할 task executor. 디폴트 executor는 `<name>-C-n` 형식의 이름을 가진 스레드를 생성한다. 여기서 name은 `KafkaMessageListenerContainer`의 경우 빈의 이름이며, `ConcurrentMessageListenerContainer`의 경우 빈 이름 뒤에 `-m`을 추가한다. `m`은 각 자식 컨테이너마다 증가하는 값이다. [컨테이너 스레드 네이밍](https://docs.spring.io/spring-kafka/reference/kafka/receiving-messages/container-thread-naming.html#container-thread-naming)을 참고해라. |
| `logContainerConfig`                      | `false`                   | 모든 컨테이너 프로퍼티를 INFO 레벨로 로깅하려면 `true`로 설정해라. |
| `messageListener`                         | `null`                    | 메시지 리스너.                                               |
| `micrometerEnabled`                       | `true`                    | 컨슈머 스레드에 대해 마이크로미터 타이머를 유지할지 여부.    |
| `micrometerTags`                          | empty                     | 마이크로미터 메트릭에 추가할 정적인 태그 맵.                 |
| `micrometerTagsProvider`                  | `null`                    | 컨슈머 레코드를 기반으로 동적 태그를 제공하는 함수.          |
| `missingTopicsFatal`                      | `false`                   | true로 설정하면 설정한 토픽이 브로커에 존재하지 않을 경우 컨테이너를 시작하지 않는다. |
| `monitorInterval`                         | 30s                       | `NonResponsiveConsumerEvent`를 감지하기 위해 컨슈머 스레드 상태를 확인할 빈도. `noPollThreshold`와 `pollTimeout`을 참고해라. |
| `noPollThreshold`                         | 3.0                       | `pollTimeOut`을 곱해서 `NonResponsiveConsumerEvent`를 발행할지 여부를 결정한다. `monitorInterval`을 참고해라. |
| `observationConvention`                   | `null`                    | 설정 시, 컨슈머 레코드에 있는 정보를 기반으로 타이머와 트레이스에 동적 태그를 추가한다. |
| `observationEnabled`                      | `false`                   | `true`로 설정하면 마이그로미터를 통한 관측을 활성화한다.     |
| `offsetAndMetadataProvider`               | `null`                    | `OffsetAndMetadata`의 provider. 기본적으로 이 provider는 빈 메타데이터를 가진 `OffsetAndMetadata`를 생성한다. provider를 통해 메타데이터를 커스텀할 수 있다. |
| `onlyLogRecordMetadata`                   | `false`                   | `false`로 설정하면 단순히 로그에 `topic-partition@offset`을 남기는 대신 컨슈머 레코드 전체를 남긴다 (에러, 디버그 로그 등). |
| `pauseImmediate`                          | `false`                   | 컨테이너가 일시 중지되면, 이전 폴링에서 가져온 모든 레코드를 처리한 다음이 아닌, 현재 레코드를 처리한 다음에 메시지 처리를 중단한다. 남은 레코드는 메모리에 유지되며, 컨테이너가 재개될 때 리스너로 전달된다. |
| `pollTimeout`                             | 5000                      | `Consumer.poll()`을 호출할 때 전달하는 타임아웃 (밀리세컨드). |
| `pollTimeoutWhilePaused`                  | 100                       | 컨테이너가 일시 중지 상태일 때 `Consumer.poll()`에 전달하는 타임아웃 (밀리세컨드). |
| `restartAfterAuthExceptions`              | false                     | `true`이면 인가<sup>authorization</sup>/인증<sup>authentication</sup> 예외로 중단된 경우 컨테이너를 재시작한다. |
| `scheduler`                               | `ThreadPoolTaskScheduler` | 컨슈머 모니터링 태스크를 실행할 스케줄러.                    |
| `shutdownTimeout`                         | 10000                     | 모든 컨슈머가 중단될 때까지 `stop()` 메소드를 블로킹할 최대 시간 (밀리세컨드). 이 시간이 경과하면 `ContainerStoppedEvent`를 발행한다. |
| `stopContainerWhenFenced`                 | `false`                   | `ProducerFencedException`이 발생하면 리스너 컨테이너를 중지한다. 자세한 내용은 [롤백 후 프로세서](https://docs.spring.io/spring-kafka/reference/kafka/annotation-error-handling.html#after-rollback)를 참고해라. |
| `stopImmediate`                           | `false`                   | 컨테이너가 중지될 때, 이전 폴링에서 가져온 모든 레코드를 처리한 다음이 아닌, 현재 레코드 처리한 다음에 메시지 처리를 중단한다. |
| `subBatchPerPartition`                    | Description 참고.         | 배치 리스너를 사용할 때 이 값을 `true`로 설정하면, 폴링 결과를 파티션별로 나눈 서브 배치로 리스너를 호출한다. 기본값은 `false`다. |
| `syncCommitTimeout`                       | `null`                    | `syncCommits`가 `true`일 때 사용할 타임아웃. 설정하지 않은 경우 컨테이너는 컨슈머 프로퍼티 `default.api.timeout.ms`를 확인해보고, 이 값도 없다면 60초를 기다린다. |
| `syncCommits`                             | `true`                    | 오프셋 커밋을 sync로 할지 async로 할지 여부. `commitCallback`을 참고해라. |
| `topics` `topicPattern` `topicPartitions` | n/a                       | 설정한 토픽이나 토픽 패턴, 또는 명시적으로 할당한 토픽/파티션. 함께 사용할 수 없으며, 최소 하나는 지정해야 한다. `ContainerProperties`의 생성자를 통해 필수로 넘겨줘야 한다. |
| `transactionManager`                      | `null`                    | 3.2 버전부터 deprecated되었다. [[kafkaAwareTransactionManager\]](https://docs.spring.io/spring-kafka/reference/kafka/container-props.html#kafkaAwareTransactionManager)와 [기타 다른 트랜잭션 매니저들](https://docs.spring.io/spring-kafka/reference/kafka/transactions.html#transaction-synchronization)을 참고해라. |

---

*Table 2.* `AbstractMessageListenerContainer` *Properties*

| Property                    | Default                         | Description                                                  |
| :-------------------------- | :------------------------------ | :----------------------------------------------------------- |
| `afterRollbackProcessor`    | `DefaultAfterRollbackProcessor` | 트랜잭션을 롤백한 다음 호출할 `AfterRollbackProcessor`.      |
| `applicationEventPublisher` | application context             | 이벤트 퍼블리셔.                                             |
| `batchErrorHandler`         | Description 참고.               | Deprecated - `commonErrorHandler` 참고.                      |
| `batchInterceptor`          | `null`                          | 배치 리스너 호출 전에 실행할 `BatchInterceptor`를 설정한다. 레코드 리스너에는 적용되지 않는다. `interceptBeforeTx`도 함께 참고해라. |
| `beanName`                  | 빈 이름                         | 컨테이너의 빈 이름. 자식 컨테이너의 경우 뒤에 `-n`이 붙는다. |
| `commonErrorHandler`        | Description 참고.               | `DefaultAfterRollbackProcessor`를 사용할 때 `transactionManager`가 있는 경우 `null`로, 그 외는 `DefaultErrorHandler`로 설정한다. 자세한 내용은 [컨테이너 에러 핸들러](../annotation-error-handling/#container-error-handlers)를 참고해라. |
| `containerProperties`       | `ContainerProperties`           | 컨테이너 프로퍼티 인스턴스.                                  |
| `groupId`                   | Description 참고.               | `containerProperties.groupId`가 존재하는 경우 해당 값을, 그 외는 컨슈머 팩토리의 `group.id` 프로퍼티를 사용한다. |
| `interceptBeforeTx`         | `true`                          | 트랜잭션 시작 전후에 `recordInterceptor`를 호출할지 여부를 결정한다. |
| `listenerId`                | Description 참고.               | 사용자가 설정한 컨테이너의 빈 이름 또는 `@KafkaListener`의 `id` 속성. |
| `listenerInfo`              | null                            | `KafkaHeaders.LISTENER_INFO` 헤더에 채울 값. `@KafkaListener`를 사용할 경우 이 값은 `info` 속성에서 가져온다. 이 헤더는 `RecordInterceptor`나 `RecordFilterStrategy`, 리스너 코드 자체 등 다양한 곳에서 사용할 수 있다. |
| `pauseRequested`            | (read only)                     | 컨슈머 일시 정지를 요청한 상태라면 true다.                   |
| `recordInterceptor`         | `null`                          | 레코드 리스너 실행 전에 호출할 `RecordInterceptor`를 설정한다. 배치 리스너에는 적용되지 않는다. `interceptBeforeTx`도 함께 참고해라. |
| `topicCheckTimeout`         | 30s                             | 컨테이너 프로퍼티 `missingTopicsFatal`이 `true`일 때, `describeTopics` 작업이 완료될 때까지 대기하는 시간 (초 단위). |

---

*Table 3.* `KafkaMessageListenerContainer` *Properties*

| Property             | Default     | Description                                                  |
| :------------------- | :---------- | :----------------------------------------------------------- |
| `assignedPartitions` | (read only) | 현재 이 컨테이너에 할당된 파티션 (명시적이든 아니든).        |
| `clientIdSuffix`     | `null`      | concurrent 컨테이너가 각 자식 컨테이너의 컨슈머마다 고유한 `client.id`를 부여하는 데 사용한다. |
| `containerPaused`    | n/a         | 일시 정지를 요청했고 컨슈머가 실제로 일시 정지한 경우 true다. |

---

*Table 4.* `ConcurrentMessageListenerContainer` *Properties*

| Property               | Default     | Description                                                  |
| :--------------------- | :---------- | :----------------------------------------------------------- |
| `alwaysClientIdSuffix` | `true`      | `concurrency`가 1일 때 컨슈머 프로퍼티 `client.id`에 접미사를 추가하지 않으려면 false로 설정해라. |
| `assignedPartitions`   | (read only) | 현재 이 컨테이너의 자식 `KafkaMessageListenerContainer`에 할당된 파티션의 모음 (명시적이든 아니든). |
| `concurrency`          | 1           | 관리할 자식 `KafkaMessageListenerContainer`의 수.            |
| `containerPaused`      | n/a         | 일시 정지를 요청했고 모든 자식 컨테이너의 컨슈머가 실제로 일시 정지한 경우 true다. |
| `containers`           | n/a         | 모든 자식 `KafkaMessageListenerContainer`에 대한 참조.       |