---
title: Kafka Streams Configuration
category: Apache Kafka
order: 9
permalink: /Apache%20Kafka/kafka-streams-configuration/
description: 아파치 카프카 공식 문서에 있는 카프카 스트림즈 설정을 한국어로 번역한 문서입니다.
image: ./../../images/kafka/logo.png
lastmod: 2021-01-11T15:00:00+09:00
comments: true
originalRefName: 아파치 카프카
originalRefLink: https://kafka.apache.org/27/documentation.html#streamsconfigs
---

---

## 3.6 Kafka Streams Configs

다음은 카프카 스트림즈 클라이언트 라이브러리의 설정이다.

- #### application.id

  스트림 처리 어플리케이션의 식별자. 카프카 클러스터 내에서 고유해야 한다. 이 값은 1) 디폴트 client-id 프리픽스, 2) 멤버십 관리를 위한 group-id, 3) changelog 토픽 프리픽스로 사용한다.

  |         Type: | string |
  | ------------: | ------ |
  |      Default: |        |
  | Valid Values: |        |
  |   Importance: | high   |

- #### bootstrap.servers

  카프카 클러스터에 대한 초기 커넥션을 구축하는 데 사용할 호스트/포트 쌍 리스트. 클라이언트가 부트스트랩될 땐 여기에 지정한 서버랑은 상관 없이 모든 서버를 사용하게 된다 — 이 리스트는 전체 서버 셋을 발견하기 위한 초기 호스트에만 영향을 준다. 리스트엔 `host1:port1,host2:port2,...` 포맷을 사용해야 한다. 이 서버들은 전체 클러스터 멤버십(동적으로 변경될 수 있음)을 발견하기 위한 초기 커넥션에만 사용하기 때문에, 이 리스트에 전체 서버 셋을 넣어야 하는 건 아니다 (단, 서버 하나가 다운됐다면 최소 두 개가 필요할 순 있다).

  |         Type: | list |
  | ------------: | ---- |
  |      Default: |      |
  | Valid Values: |      |
  |   Importance: | high |

- #### replication.factor

  스트림 처리 어플리케이션에서 생성하는 change log 토픽과 repartition 토픽에 사용할 replication factor.

  |         Type: | int  |
  | ------------: | ---- |
  |      Default: | 1    |
  | Valid Values: |      |
  |   Importance: | high |

- #### state.dir

  상태 저장소로 사용할 디렉터리 경로. 이 경로는 같은 파일 시스템을 공유하는 모든 스트림 인스턴스에서 고유해야 한다.

  |         Type: | string             |
  | ------------: | ------------------ |
  |      Default: | /tmp/kafka-streams |
  | Valid Values: |                    |
  |   Importance: | high               |

- #### acceptable.recovery.lag

  최대로 허용할 랙 (따라잡아야 하는 오프셋 수). 이 정도까지의 랙은 클라이언트가 활성 태스크를 따라잡고 있는 걸로 간주한다. 
  The maximum acceptable lag (number of offsets to catch up) for a client to be considered caught-up for an active task.
  주어진 워크로드에 대해 1분 미만의 복구 시간에 해당해야 한다. 
  Should correspond to a recovery time of well under a minute for a given workload.
  최소 0 이상이어야 한다.

  |         Type: | long    |
  | ------------: | ------- |
  |      Default: | 10000   |
  | Valid Values: | [0,...] |
  |   Importance: | medium  |

- #### cache.max.bytes.buffering

  모든 스레드에서 버퍼링에 사용할 메모리의 최대 바이트

  |         Type: | long     |
  | ------------: | -------- |
  |      Default: | 10485760 |
  | Valid Values: | [0,...]  |
  |   Importance: | medium   |

- #### client.id

  내부 컨슈머, 프로듀서, restore 컨슈머의 클라이언트 ID에 사용할 ID 프리픽스 문자열. '-StreamThread--' 패턴을 사용한다.

  |         Type: | string |
  | ------------: | ------ |
  |      Default: | ""     |
  | Valid Values: |        |
  |   Importance: | medium |

- #### default.deserialization.exception.handler

  `org.apache.kafka.streams.errors.DeserializationExceptionHandler` 인터페이스를 구현한 예외 처리 클래스.

  |         Type: | class                                                      |
  | ------------: | ---------------------------------------------------------- |
  |      Default: | org.apache.kafka.streams.errors.LogAndFailExceptionHandler |
  | Valid Values: |                                                            |
  |   Importance: | medium                                                     |

- #### default.key.serde

  `org.apache.kafka.common.serialization.Serde` 인터페이스를 구현하는 키에 대한 디폴트 시리얼라이저/디시리얼라이저 클래스.
  WindowedSerde 클래스를 사용할 땐 'default.windowed.key.serde.inner'나 'default.windowed.value.serde.inner'를 통해
  `org.apache.kafka.common.serialization.Serde` 인터페이스를 구현하는 내부 serde 클래스도 설정해야 한다.
  Note when windowed serde class is used, one needs to set the inner serde class 
  that implements the `org.apache.kafka.common.serialization.Serde` interface via 
  'default.windowed.key.serde.inner' or 'default.windowed.value.serde.inner' as well

  |         Type: | class                                                       |
  | ------------: | ----------------------------------------------------------- |
  |      Default: | org.apache.kafka.common.serialization.Serdes$ByteArraySerde |
  | Valid Values: |                                                             |
  |   Importance: | medium                                                      |

- #### default.production.exception.handler

  `org.apache.kafka.streams.errors.ProductionExceptionHandler` 인터페이스를 구현한 예외 처리 클래스.

  |         Type: | class                                                        |
  | ------------: | ------------------------------------------------------------ |
  |      Default: | org.apache.kafka.streams.errors.DefaultProductionExceptionHandler |
  | Valid Values: |                                                              |
  |   Importance: | medium                                                       |

- #### default.timestamp.extractor

  `org.apache.kafka.streams.processor.TimestampExtractor` 인터페이스를 구현한 디폴트 timestamp extractor 클래스. 

  |         Type: | class                                                     |
  | ------------: | --------------------------------------------------------- |
  |      Default: | org.apache.kafka.streams.processor.FailOnInvalidTimestamp |
  | Valid Values: |                                                           |
  |   Importance: | medium                                                    |

- #### default.value.serde

  Default serializer / deserializer class for value that implements the `org.apache.kafka.common.serialization.Serde` interface. Note when windowed serde class is used, one needs to set the inner serde class that implements the `org.apache.kafka.common.serialization.Serde` interface via 'default.windowed.key.serde.inner' or 'default.windowed.value.serde.inner' as well

  |         Type: | class                                                       |
  | ------------: | ----------------------------------------------------------- |
  |      Default: | org.apache.kafka.common.serialization.Serdes$ByteArraySerde |
  | Valid Values: |                                                             |
  |   Importance: | medium                                                      |

- #### default.windowed.key.serde.inner

  Default serializer / deserializer for the inner class of a windowed key. 반드시 `org.apache.kafka.common.serialization.Serde` 인터페이스를 구현해야 한다.

  |         Type: | class  |
  | ------------: | ------ |
  |      Default: | null   |
  | Valid Values: |        |
  |   Importance: | medium |

- #### default.windowed.value.serde.inner

  윈도우를 적용한 값에 사용하는 내부 클래스의 디폴트 시리얼라이저/디시리얼라이저. 반드시 `org.apache.kafka.common.serialization.Serde` 인터페이스를 구현해야 한다.
  Default serializer / deserializer for the inner class of a windowed value. Must implement the `org.apache.kafka.common.serialization.Serde` interface.

  |         Type: | class  |
  | ------------: | ------ |
  |      Default: | null   |
  | Valid Values: |        |
  |   Importance: | medium |

- #### max.task.idle.ms

  Maximum amount of time in milliseconds a stream task will stay idle when not all of its partition buffers contain records, to avoid potential out-of-order record processing across multiple input streams.

  |         Type: | long   |
  | ------------: | ------ |
  |      Default: | 0      |
  | Valid Values: |        |
  |   Importance: | medium |

- #### max.warmup.replicas

  The maximum number of warmup replicas (extra standbys beyond the configured num.standbys) that can be assigned at once for the purpose of keeping the task available on one instance while it is warming up on another instance it has been reassigned to. Used to throttle how much extra broker traffic and cluster state can be used for high availability. Must be at least 1.

  |         Type: | int     |
  | ------------: | ------- |
  |      Default: | 2       |
  | Valid Values: | [1,...] |
  |   Importance: | medium  |

- #### num.standby.replicas

  The number of standby replicas for each task.

  |         Type: | int    |
  | ------------: | ------ |
  |      Default: | 0      |
  | Valid Values: |        |
  |   Importance: | medium |

- #### num.stream.threads

  스트림 처리를 실행할 스레드 수.

  |         Type: | int    |
  | ------------: | ------ |
  |      Default: | 1      |
  | Valid Values: |        |
  |   Importance: | medium |

- #### processing.guarantee

  The processing guarantee that should be used. Possible values are `at_least_once` (default), `exactly_once` (requires brokers version 0.11.0 or higher), and `exactly_once_beta` (requires brokers version 2.5 or higher). Note that exactly-once processing requires a cluster of at least three brokers by default what is the recommended setting for production; for development you can change this, by adjusting broker setting `transaction.state.log.replication.factor` and `transaction.state.log.min.isr`.

  |         Type: | string                                           |
  | ------------: | ------------------------------------------------ |
  |      Default: | at_least_once                                    |
  | Valid Values: | [at_least_once, exactly_once, exactly_once_beta] |
  |   Importance: | medium                                           |

- #### security.protocol

  브로커와 통신할 때 사용하는 프로토콜. 유효한 값은 PLAINTEXT, SSL, SASL_PLAINTEXT, SASL_SSL이다.

  |         Type: | string    |
  | ------------: | --------- |
  |      Default: | PLAINTEXT |
  | Valid Values: |           |
  |   Importance: | medium    |

- #### task.timeout.ms

  The maximum amount of time in milliseconds a task might stall due to internal errors and retries until an error is raised. For a timeout of 0ms, a task would raise an error for the first internal error. For any timeout larger than 0ms, a task will retry at least once before an error is raised.

  |         Type: | long               |
  | ------------: | ------------------ |
  |      Default: | 300000 (5 minutes) |
  | Valid Values: | [0,...]            |
  |   Importance: | medium             |

- #### topology.optimization

  카프카 스트림즈에 토폴로지를 최적화해야 하는지 알려주는 설정. 기본적으로 비활성화한다.

  |         Type: | string      |
  | ------------: | ----------- |
  |      Default: | none        |
  | Valid Values: | [none, all] |
  |   Importance: | medium      |

- #### application.server

  A host:port pair pointing to a user-defined endpoint that can be used for state store discovery and interactive queries on this KafkaStreams instance.

  |         Type: | string |
  | ------------: | ------ |
  |      Default: | ""     |
  | Valid Values: |        |
  |   Importance: | low    |

- #### buffered.records.per.partition

  
  Maximum number of records to buffer per partition.

  |         Type: | int  |
  | ------------: | ---- |
  |      Default: | 1000 |
  | Valid Values: |      |
  |   Importance: | low  |

- #### built.in.metrics.version

  사용할 빌트인 메트릭의 버전.

  |         Type: | string               |
  | ------------: | -------------------- |
  |      Default: | latest               |
  | Valid Values: | [0.10.0-2.4, latest] |
  |   Importance: | low                  |

- #### commit.interval.ms

  The frequency in milliseconds with which to save the position of the processor. (Note, if `processing.guarantee` is set to `exactly_once`, the default value is `100`, otherwise the default value is `30000`.

  |         Type: | long               |
  | ------------: | ------------------ |
  |      Default: | 30000 (30 seconds) |
  | Valid Values: | [0,...]            |
  |   Importance: | low                |

- #### connections.max.idle.ms

  유휴 커넥션은 이 설정에 지정한 시간(밀리세컨드)이 지나면 종료한다.

  |         Type: | long               |
  | ------------: | ------------------ |
  |      Default: | 540000 (9 minutes) |
  | Valid Values: |                    |
  |   Importance: | low                |

- #### metadata.max.age.ms

  새로운 브로커나 파티션을 사전에 발견할 수 있도록, 파티션 리더십이 변경되지 않아도 메타데이터를 강제로 리프레시할 간격 (밀리세컨드).

  |         Type: | long               |
  | ------------: | ------------------ |
  |      Default: | 300000 (5 minutes) |
  | Valid Values: | [0,...]            |
  |   Importance: | low                |

- #### metric.reporters

  메트릭 리포터로 사용할 클래스 리스트. `org.apache.kafka.common.metrics.MetricsReporter` 인터페이스를 구현하면 새 메트릭을 생성을 통지 받을 클래스를 연결할 수 있다. JMX 통계를 등록하는 JmxReporter는 항상 추가된다.

  |         Type: | list |
  | ------------: | ---- |
  |      Default: | ""   |
  | Valid Values: |      |
  |   Importance: | low  |

- #### metrics.num.samples

  메트릭 계산을 위해 유지할 샘플 수.

  |         Type: | int     |
  | ------------: | ------- |
  |      Default: | 2       |
  | Valid Values: | [1,...] |
  |   Importance: | low     |

- #### metrics.recording.level

  메트릭을 기록할 제일 높은 레벨.

  |         Type: | string               |
  | ------------: | -------------------- |
  |      Default: | INFO                 |
  | Valid Values: | [INFO, DEBUG, TRACE] |
  |   Importance: | low                  |

- #### metrics.sample.window.ms

  메트릭 샘플을 계산할 시간 윈도우.

  |         Type: | long               |
  | ------------: | ------------------ |
  |      Default: | 30000 (30 seconds) |
  | Valid Values: | [0,...]            |
  |   Importance: | low                |

- #### partition.grouper

  `org.apache.kafka.streams.processor.PartitionGrouper` 인터페이스를 구현하는 파티션 grouper 클래스. 경고: 이 설정은 deprecated되었으며, 3.0.0 릴리즈에서 제거할 예정이다.

  |         Type: | class                                                      |
  | ------------: | ---------------------------------------------------------- |
  |      Default: | org.apache.kafka.streams.processor.DefaultPartitionGrouper |
  | Valid Values: |                                                            |
  |   Importance: | low                                                        |

- #### poll.ms

  The amount of time in milliseconds to block waiting for input.

  |         Type: | long |
  | ------------: | ---- |
  |      Default: | 100  |
  | Valid Values: |      |
  |   Importance: | low  |

- #### probing.rebalance.interval.ms

  The maximum time in milliseconds to wait before triggering a rebalance to probe for warmup replicas that have finished warming up and are ready to become active. Probing rebalances will continue to be triggered until the assignment is balanced. Must be at least 1 minute.

  |         Type: | long                |
  | ------------: | ------------------- |
  |      Default: | 600000 (10 minutes) |
  | Valid Values: | [60000,...]         |
  |   Importance: | low                 |

- #### receive.buffer.bytes

  데이터를 읽을 때 사용하는 TCP 수신 버퍼(SO_RCVBUF)의 크기. 값이 -1이면 OS 기본값을 사용한다.

  |         Type: | int                  |
  | ------------: | -------------------- |
  |      Default: | 32768 (32 kibibytes) |
  | Valid Values: | [-1,...]             |
  |   Importance: | low                  |

- #### reconnect.backoff.max.ms

  브로커에 연결을 반복해서 실패했을 때, 다시 연결해보기까지 대기하는 최대 시간 (밀리세컨드). 연이어서 커넥션 연결에 실패하면 매번 실패할 때마다 호스트 당 백오프 값이 늘어나, 순식간에 이 최대값까지 커질 수 있다. 커넥션 폭풍을 방지하기 위해 백오프 증가값을 계산한 후에 20 % 랜덤 지터를 추가한다.

  |         Type: | long            |
  | ------------: | --------------- |
  |      Default: | 1000 (1 second) |
  | Valid Values: | [0,...]         |
  |   Importance: | low             |

- #### reconnect.backoff.ms

  주어진 호스트에 연결을 다시 시도하기 전 대기하는 기본 시간. 리소스를 차지한채 반복문으로 계속해서 같은 호스트에 연결하는 것을 방지한다. 이 백오프는 클라이언트가 브로커에 연결을 시도하는 모든 곳에 적용된다.

  |         Type: | long    |
  | ------------: | ------- |
  |      Default: | 50      |
  | Valid Values: | [0,...] |
  |   Importance: | low     |

- #### request.timeout.ms

  이 설정은 클라이언트가 응답을 기다릴 최대 시간을 제어한다. 클라이언트는 타임 아웃될 때까지 응답을 받지 못하면, 필요한 경우 요청을 재전송할 수 있으며, 재시도 횟수를 모두 소진하면 요청은 실패로 끝난다.

  |         Type: | int                |
  | ------------: | ------------------ |
  |      Default: | 40000 (40 seconds) |
  | Valid Values: | [0,...]            |
  |   Importance: | low                |

- #### retries

  0보다 크게 설정하면, 클라이언트는 일시적인 오류로 실패한 모든 요청를 다시 전송한다. 이 값은 0이나 `MAX_VALUE`로 설정하고, 그에 맞는 타임 아웃 파라미터로 클라이언트가 요청을 재시도하는 전체적인 시간을 제어하는 것을 권장한다.

  |         Type: | int                |
  | ------------: | ------------------ |
  |      Default: | 0                  |
  | Valid Values: | [0,...,2147483647] |
  |   Importance: | low                |

- #### retry.backoff.ms

  주어진 토픽 파티션에 실패한 요청을 재시도하기 전 대기하는 시간. 일부 실패 시나리오에서 리소스를 차지한채 반복문으로 계속해서 요청을 보내는 것을 방지한다.

  |         Type: | long    |
  | ------------: | ------- |
  |      Default: | 100     |
  | Valid Values: | [0,...] |
  |   Importance: | low     |

- #### rocksdb.config.setter

  `org.apache.kafka.streams.state.RocksDBConfigSetter` 인터페이스를 구현한 Rocks DB config setter 클래스 또는 클래스 명

  |         Type: | class |
  | ------------: | ----- |
  |      Default: | null  |
  | Valid Values: |       |
  |   Importance: | low   |

- #### send.buffer.bytes

  데이터를 전송할 때 사용하는 TCP 전송 버퍼(SO_SNDBUF)의 크기. 값이 -1이면 OS 기본값을 사용한다.

  |         Type: | int                    |
  | ------------: | ---------------------- |
  |      Default: | 131072 (128 kibibytes) |
  | Valid Values: | [-1,...]               |
  |   Importance: | low                    |

- #### state.cleanup.delay.ms

  The amount of time in milliseconds to wait before deleting state when a partition has migrated. Only state directories that have not been modified for at least `state.cleanup.delay.ms` will be removed

  |         Type: | long                |
  | ------------: | ------------------- |
  |      Default: | 600000 (10 minutes) |
  | Valid Values: |                     |
  |   Importance: | low                 |

- #### upgrade.from

  Allows upgrading in a backward compatible way. This is needed when upgrading from [0.10.0, 1.1] to 2.0+, or when upgrading from [2.0, 2.3] to 2.4+. When upgrading from 2.4 to a newer version it is not required to specify this config. Default is `null`. Accepted values are "0.10.0", "0.10.1", "0.10.2", "0.11.0", "1.0", "1.1", "2.0", "2.1", "2.2", "2.3" (for upgrading from the corresponding old version).

  |         Type: | string                                                       |
  | ------------: | ------------------------------------------------------------ |
  |      Default: | null                                                         |
  | Valid Values: | [null, 0.10.0, 0.10.1, 0.10.2, 0.11.0, 1.0, 1.1, 2.0, 2.1, 2.2, 2.3] |
  |   Importance: | low                                                          |

- #### windowstore.changelog.additional.retention.ms

  Added to a windows maintainMs to ensure data is not deleted from the log prematurely. Allows for clock drift. Default is 1 day

  |         Type: | long             |
  | ------------: | ---------------- |
  |      Default: | 86400000 (1 day) |
  | Valid Values: |                  |
  |   Importance: | low              |
