---
title: Topic Configuration
category: Apache Kafka
order: 5
permalink: /Apache%20Kafka/topic-configuration/
description: 아파치 카프카 공식 문서에 있는 토픽 레벨 설정을 한글로 번역한 문서입니다.
image: ./../../images/kafka/logo.png
lastmod: 2021-02-14T22:25:00+09:00
comments: true
originalRefName: 아파치 카프카
originalRefLink: https://kafka.apache.org/27/documentation.html#topicconfigs
---

---

## 3.2 Topic-Level Configs

토픽과 관련된 설정들은 서버에 기본값이 있으며, 토픽별로 재정의할 수도 있다. 토픽별 설정을 지정하지 않으면 서버 기본값을 사용한다. 재정의할 설정은 토픽을 만들 때 `--config` 옵션을 하나 이상 지정하면 된다. 이 예시에선 커스텀 최대 메세지 크기와 플러시 간격을 사용해 *my-topic*이란 토픽을 생성한다:

```bash
> bin/kafka-topics.sh --bootstrap-server localhost:9092 \
  --create --topic my-topic --partitions 1 --replication-factor 1 \
  --config max.message.bytes=64000 --config flush.messages=1
```

재정의는 alter configs 명령어를 사용해서 변경하거나 나중에 필요해지면 설정할 수도 있다. 이 예시에선 *my-topic*의 최대 메세지 크기를 업데이트한다:

```bash
> bin/kafka-configs.sh --bootstrap-server localhost:9092 \
  --entity-type topics --entity-name my-topic \
  --alter --add-config max.message.bytes=128000
```

토픽에 재정의된 설정을 확인하려면:

```bash
> bin/kafka-configs.sh --bootstrap-server localhost:9092 \
  --entity-type topics --entity-name my-topic --describe
```

재정의한 설정을 삭제하려면:

```bash
> bin/kafka-configs.sh --bootstrap-server localhost:9092 \
  --entity-type topics --entity-name my-topic \
  --alter --delete-config max.message.bytes
```

다음은 토픽 레벨 설정들이다. 프로퍼티마다 서버의 디폴트 설정은 "Server Default Property"로 표기했다. 해당 서버 디폴트 설정값은 토픽 설정 재정의를 명시하지 않은 토픽에만 적용된다.

- #### cleanup.policy

  문자열 "delete"나 "compact", 혹은 둘 다 사용할 수 있다. 이 문자열은 오래된 로그 세그먼트에 적용할 보존 정책을 지정한다. 디폴트 정책("delete")은 보존 시간이나 크기 제한에 도달하면 오래된 세그먼트를 폐기한다. "compact" 설정은 토픽에 [로그 컴팩션](../design#48-log-compaction)을 활성화한다.

  |                    Type: | list               |
  | -----------------------: | ------------------ |
  |                 Default: | delete             |
  |            Valid Values: | [compact, delete]  |
  | Server Default Property: | [log.cleanup.policy](../broker-configuration#logcleanuppolicy) |
  |              Importance: | medium             |

- #### compression.type

  주어진 토픽에 사용할 최종 압축 타입을 지정한다. 이 설정은 표준 압축 코덱(‘gzip’, ‘snappy’, ‘lz4’, ‘zstd’)을 허용하며, 그 외 압축하지 않음을 나타내는 ‘uncompressed’와, 프로듀서가 설정한 기존 압축 코덱을 유지함을 나타내는 ‘producer’를 사용할 수 있다.

  |                    Type: | string                                            |
  | -----------------------: | ------------------------------------------------- |
  |                 Default: | producer                                          |
  |            Valid Values: | [uncompressed, zstd, lz4, snappy, gzip, producer] |
  | Server Default Property: | [compression.type](../broker-configuration#compressiontype)                                  |
  |              Importance: | medium                                            |

- #### delete.retention.ms

  [로그 컴팩션](../design#48-log-compaction)을 사용하는 토픽에서 삭제 톰스톤(tombstone) 마커를 보존하는 시간다. 이 설정은 컨슈머가 오프셋 0에서부터 시작하는 경우, 유효한 최종 스냅샷을 확보하기 위해 읽기를 완료해야 하는 시간 경계이기도 하다 (그렇지 않으면 컨슈머가 스캔을 완료하기 전에 삭제 톰스톤을 수집할 수도 있다).

  |                    Type: | long                            |
  | -----------------------: | ------------------------------- |
  |                 Default: | 86400000 (1 day)                |
  |            Valid Values: | [0,...]                         |
  | Server Default Property: | [log.cleaner.delete.retention.ms](../broker-configuration#logcleanerdeleteretentionms) |
  |              Importance: | medium                          |

- #### file.delete.delay.ms

  파일 시스템에서 파일을 삭제하기 전 대기할 시간

  |                    Type: | long                        |
  | -----------------------: | --------------------------- |
  |                 Default: | 60000 (1 minute)            |
  |            Valid Values: | [0,...]                     |
  | Server Default Property: | [log.segment.delete.delay.ms](../broker-configuration#logsegmentdeletedelayms) |
  |              Importance: | medium                      |

- #### flush.messages

  이 설정으론 로그에 기록할 데이터의 fsync를 강제할 간격을 지정할 수 있다. 예를 들어 1로 설정하면 모든 메세지마다 fsync를 실행한다. 5로 설정하면 메세지 다섯 개마다 fsync를 실행한다. 보통은 이 설정은 건드리지 말고, 내구성은 레플리카를 활용하고, 더 효율적인 운영 체제의 백그라운드 플러시에 맡기는 게 좋다. 이 설정은 토픽별로 재정의할 수 있다. ([토픽별 설정 섹션](#32-topic-level-configs) 참고).

  |                    Type: | long                        |
  | -----------------------: | --------------------------- |
  |                 Default: | 9223372036854775807         |
  |            Valid Values: | [0,...]                     |
  | Server Default Property: | [log.flush.interval.messages](../broker-configuration#logflushintervalmessages) |
  |              Importance: | medium                      |

- #### flush.ms

  이 설정으론 로그에 기록할 데이터의 fsync를 강제할 시간 간격을 지정할 수 있다. 예를 들어 1000으로 설정하면, 1000ms가 지나면 fsync를 실행한다. 보통은 이 설정은 건드리지 말고, 내구성은 레플리카를 활용하고, 더 효율적인 운영 체제의 백그라운드 플러시에 맡기는 게 좋다.

  |                    Type: | long                  |
  | -----------------------: | --------------------- |
  |                 Default: | 9223372036854775807   |
  |            Valid Values: | [0,...]               |
  | Server Default Property: | [log.flush.interval.ms](../broker-configuration#logflushintervalms) |
  |              Importance: | medium                |

- #### follower.replication.throttled.replicas

  팔로워 쪽에서 로그 복제를 스로틀링해야 하는 레플리카 리스트. 이 리스트는 [PartitionId]:[BrokerId],[PartitionId]:[BrokerId]:... 포맷으로 레플리카 리스트를 표현해야 한다. 아니면 와일드카드 '*'를 사용하면 이 토픽에 관한 모든 레플리카를 스로틀링할 수 있다.

  |                    Type: | list                                                  |
  | -----------------------: | ----------------------------------------------------- |
  |                 Default: | ""                                                    |
  |            Valid Values: | [partitionId]:[brokerId],[partitionId]:[brokerId],... |
  | Server Default Property: | follower.replication.throttled.replicas               |
  |              Importance: | medium                                                |

- #### index.interval.bytes

  이 설정은 카프카가 오프셋 인덱스에 인덱스 엔트리를 추가하는 빈도를 제어한다. 디폴트 설정은 대략 4096바이트마다 메세지를 인덱싱한다. 인덱싱을 더 자주 하면, 데이터를 읽을 때 로그가 있는 정확한 위치에 더 가깝게 이동할 수 있지만, 인덱스 크기는 더 커진다. 이 설정은 특별한 이유가 없다면 굳이 변경할 필요 없다.

  |                    Type: | int                      |
  | -----------------------: | ------------------------ |
  |                 Default: | 4096 (4 kibibytes)       |
  |            Valid Values: | [0,...]                  |
  | Server Default Property: | [log.index.interval.bytes](../broker-configuration#logindexintervalbytes) |
  |              Importance: | medium                   |

- #### leader.replication.throttled.replicas

  리더 쪽에서 로그 복제를 스로틀링해야 하는 레플리카 리스트. 이 리스트는 [PartitionId]:[BrokerId],[PartitionId]:[BrokerId]:... 포맷으로 레플리카 리스트를 표현해야 한다. 아니면 와일드카드 '*'를 사용하면 이 토픽에 관한 모든 레플리카를 스로틀링할 수 있다.

  |                    Type: | list                                                  |
  | -----------------------: | ----------------------------------------------------- |
  |                 Default: | ""                                                    |
  |            Valid Values: | [partitionId]:[brokerId],[partitionId]:[brokerId],... |
  | Server Default Property: | leader.replication.throttled.replicas                 |
  |              Importance: | medium                                                |

- #### max.compaction.lag.ms

  메세지가 컴팩션 대상에 오르지 않고 로그에 남아있는 최대 시간. 압축하는 로그에만 적용된다.

  |                    Type: | long                              |
  | -----------------------: | --------------------------------- |
  |                 Default: | 9223372036854775807               |
  |            Valid Values: | [1,...]                           |
  | Server Default Property: | [log.cleaner.max.compaction.lag.ms](../broker-configuration#logcleanermaxcompactionlagms) |
  |              Importance: | medium                            |

- #### max.message.bytes

  카프카에서 허용할 레코드 배치의 최대 크기 (압축을 활성화했다면 압축 후의 크기). 0.10.2 이전 버전의 컨슈머를 사용할 때 이 값을 늘린다면, 컨슈머의 페치 사이즈도 늘려야 그만큼의 레코드 배치를 가져올 수 있다. 최신 버전의 메세지 포맷에선, 효율성을 고려해 레코드는 항상 배치로 그룹화된다. 구버전에선, 압축하지 않은 레코드는 배치로 묶지 않으며, 이땐 단일 레코드에만 최대 크기가 적용된다.

  |                    Type: | int               |
  | -----------------------: | ----------------- |
  |                 Default: | 1048588           |
  |            Valid Values: | [0,...]           |
  | Server Default Property: | [message.max.bytes](../broker-configuration#messagemaxbytes) |
  |              Importance: | medium            |

- #### message.format.version

  브로커가 로그에 메세지를 추가할 때 사용할 메세지 포맷 버전을 지정한다. 유효한 ApiVersion을 사용해야 한다. 예를 들어: 0.8.2, 0.9.0.0, 0.10.0. 자세한 내용은 ApiVersion을 확인해라. 사용자가 특정 메세지 포맷 버전을 설정하면, 디스크에 있는 모든 기존 메세지가 이 버전보다 작거나 같음을 인증하는 거다. 이 값을 잘못 설정하면, 구버전을 사용하는 컨슈머는 메세지를 이해할 수 없는 포맷으로 받게되므로 컨슈머가 중단될 수 있다.

  |                    Type: | string                                                       |
  | -----------------------: | ------------------------------------------------------------ |
  |                 Default: | 2.7-IV2                                                      |
  |            Valid Values: | [0.8.0, 0.8.1, 0.8.2, 0.9.0, 0.10.0-IV0, 0.10.0-IV1, 0.10.1-IV0, 0.10.1-IV1, 0.10.1-IV2, 0.10.2-IV0, 0.11.0-IV0, 0.11.0-IV1, 0.11.0-IV2, 1.0-IV0, 1.1-IV0, 2.0-IV0, 2.0-IV1, 2.1-IV0, 2.1-IV1, 2.1-IV2, 2.2-IV0, 2.2-IV1, 2.3-IV0, 2.3-IV1, 2.4-IV0, 2.4-IV1, 2.5-IV0, 2.6-IV0, 2.7-IV0, 2.7-IV1, 2.7-IV2] |
  | Server Default Property: | [log.message.format.version](../broker-configuration#logmessageformatversion)                                   |
  |              Importance: | medium                                                       |

- #### message.timestamp.difference.max.ms

  브로커가 메세지를 받은 시각과 메세지에 지정한 타임스탬프의 차이를 허용할 최대치. [message.timestamp.type](#messagetimestamptype)=CreateTime으로 설정했다면, 타임스탬프 차이가 이 임계치를 초과하면 메세지를 거부한다. 이 설정은 [message.timestamp.type](#messagetimestamptype)=LogAppendTime에선 무시된다.

  |                    Type: | long                                    |
  | -----------------------: | --------------------------------------- |
  |                 Default: | 9223372036854775807                     |
  |            Valid Values: | [0,...]                                 |
  | Server Default Property: | [log.message.timestamp.difference.max.ms](../broker-configuration#logmessagetimestampdifferencemaxms) |
  |              Importance: | medium                                  |

- #### message.timestamp.type

  메세지의 타임스탬프가 메세지 생성 시각인지, 로그를 추가한 시각인지를 정의한다. `CreateTime`이나 `LogAppendTime` 중 하나를 사용해야 한다.

  |                    Type: | string                      |
  | -----------------------: | --------------------------- |
  |                 Default: | CreateTime                  |
  |            Valid Values: | [CreateTime, LogAppendTime] |
  | Server Default Property: | [log.message.timestamp.type](../broker-configuration#logmessagetimestamptype)  |
  |              Importance: | medium                      |

- #### min.cleanable.dirty.ratio

  이 설정은 로그 컴팩터가 로그 정리를 시도할 빈도를 제어한다 ([로그 컴팩션](../design#48-log-compaction)을 활성화했다는 가정 하에). 기본적으로는 50% 이상 압축된 로그는 정리하지 않는다. 이 비율은 로그 중복으로 낭비되는 공간의 최대 크기를 제한한다 (최대 50%의 로그가 중복될 수 있음). 비율이 높을수록 더 적은 횟수로 효율적으로 로그를 정리하지만, 로그에서 낭비되는 공간은 더 많아진다. [max.compaction.lag.ms](#maxcompactionlagms)나 [min.compaction.lag.ms](#mincompactionlagms) 설정도 지정했다면, 로그 컴팩터는 로그가 다음 조건 중 하나에 해당되는 즉시 압축 대상으로 간주한다: (1) 최소 [min.compaction.lag.ms](#mincompactionlagms)가 지나고 나서, dirty(압축하지 않은) 레코드가 있으면서 dirty 비율 임계치에 충족하는 경우, (2) 최대 [max.compaction.lag.ms](#maxcompactionlagms)가 지났는데 로그에 dirty(압축하지 않은) 레코드가 있는 경우.

  |                    Type: | double                          |
  | -----------------------: | ------------------------------- |
  |                 Default: | 0.5                             |
  |            Valid Values: | [0,...,1]                       |
  | Server Default Property: | [log.cleaner.min.cleanable.ratio](../broker-configuration#logcleanermincleanableratio) |
  |              Importance: | medium                          |

- #### min.compaction.lag.ms

  메세지를 압축하지 않고 로그에 남겨둘 최소 시간. 압축하는 로그에만 적용된다.

  |                    Type: | long                              |
  | -----------------------: | --------------------------------- |
  |                 Default: | 0                                 |
  |            Valid Values: | [0,...]                           |
  | Server Default Property: | [log.cleaner.min.compaction.lag.ms](../broker-configuration#logcleanermincompactionlagms) |
  |              Importance: | medium                            |

- #### min.insync.replicas

  이 값은 프로듀서에서 [acks](../producer-configuration#acks)를 “all”(또는 “-1”)로 설정했을 때, 쓰기를 승인(acknowledge)해야 하는 최소 레플리카 수를 지정한다. 최소한 이만큼을 승인해야 쓰기에 성공한 것으로 간주한다. 이 최소값에 충족하지 않으면, 프로듀서는 예외를 발생시킨다 (NotEnoughReplicas 또는 NotEnoughReplicasAfterAppend).
  이 설정과 [`acks`](../producer-configuration#acks)를 함께 사용하면 더 강력한 내구성을 보장할 수 있다. 전형적인 시나리오는 토픽을 replication factor 3으로 만들고, `min.insync.replicas`를 2로, [`acks`](../producer-configuration#acks)를 “all”로 메세지를 생산하는 거다. 이렇게 하면 레플리카 과반수 이상이 메세지를 받지 못하면 프로듀서에서 예외를 발생시킴을 보장할 수 있다.

  |                    Type: | int                 |
  | -----------------------: | ------------------- |
  |                 Default: | 1                   |
  |            Valid Values: | [1,...]             |
  | Server Default Property: | [min.insync.replicas](../broker-configuration#mininsyncreplicas) |
  |              Importance: | medium              |

- #### preallocate

  로그 세그먼트를 새로 만들 때 디스크에 파일을 미리 할당하려면 True로 설정해라.

  |                    Type: | boolean         |
  | -----------------------: | --------------- |
  |                 Default: | false           |
  |            Valid Values: |                 |
  | Server Default Property: | [log.preallocate](../broker-configuration#logpreallocate) |
  |              Importance: | medium          |

- #### retention.bytes

  이 설정은 "delete" 보존 정책을 사용하는 경우, 공간 확보를 위해 오래된 로그 세그먼트를 폐기하기 전까지 파티션(로그 세그먼트로 구성된)이 증가할 수 있는 최대 크기를 제어한다. 기본적으로는 크기 제한은 없으며, 시간 제한만 있다. 이 제한은 파티션 레벨에 적용되므로, 여기에 파티션 수를 곱해 토픽을 보존할 바이트를 계산한다.

  |                    Type: | long                |
  | -----------------------: | ------------------- |
  |                 Default: | -1                  |
  |            Valid Values: |                     |
  | Server Default Property: | [log.retention.bytes](../broker-configuration#logretentionbytes) |
  |              Importance: | medium              |

- #### retention.ms

  이 설정은 "delete" 보존 정책을 사용하는 경우, 공간 확보를 위해 오래된 로그 세그먼트를 폐기하기 전까지 로그를 보존할 최대 시간을 제어한다. 컨슈머가 데이터를 얼마나 빨리 읽어야 하는지에 대한 SLA를 나타내기도 한다. -1로 설정하면 시간 제한을 적용하지 않는다.

  |                    Type: | long               |
  | -----------------------: | ------------------ |
  |                 Default: | 604800000 (7 days) |
  |            Valid Values: | [-1,...]           |
  | Server Default Property: | [log.retention.ms](../broker-configuration#logretentionms)   |
  |              Importance: | medium             |

- #### segment.bytes

  이 설정은 로그의 세그먼트 파일 크기를 제어한다. 세그먼트 보존과 정리는 언제나 한 번에 파일 하나씩 수행하기 때문에, 세그먼트 크기가 클수록 파일 수는 줄어들지만, 보존을 세밀하게 제어하기 힘들어진다.

  |                    Type: | int                     |
  | -----------------------: | ----------------------- |
  |                 Default: | 1073741824 (1 gibibyte) |
  |            Valid Values: | [14,...]                |
  | Server Default Property: | [log.segment.bytes](../broker-configuration#logsegmentbytes)       |
  |              Importance: | medium                  |

- #### segment.index.bytes

  이 설정은 오프셋을 파일 위치에 매핑하는 인덱스의 크기를 제어한다. 이 인덱스 파일은 사전에 할당하며, 로그를 롤링한 후에만 축소시킨다(shrink). 보통은 이 설정은 변경할 필요 없다.

  |                    Type: | int                      |
  | -----------------------: | ------------------------ |
  |                 Default: | 10485760 (10 mebibytes)  |
  |            Valid Values: | [0,...]                  |
  | Server Default Property: | [log.index.size.max.bytes](../broker-configuration#logindexsizemaxbytes) |
  |              Importance: | medium                   |

- #### segment.jitter.ms

  세그먼트가 한꺼번에 롤링되지 않도록, 스케줄링한 세그먼트 롤링 시간에서 뺄 최대 랜덤 지터.

  |                    Type: | long               |
  | -----------------------: | ------------------ |
  |                 Default: | 0                  |
  |            Valid Values: | [0,...]            |
  | Server Default Property: | [log.roll.jitter.ms](../broker-configuration#logrolljitterms) |
  |              Importance: | medium             |

- #### segment.ms

  이 설정은 카프카가 강제로 로그를 롤링하는 주기를 제어한다. 보존 정책 상 오래된 데이터를 삭제하거나 압축할 정도로 세그먼트 파일이 가득 차지 않았더라도 롤링한다.

  |                    Type: | long               |
  | -----------------------: | ------------------ |
  |                 Default: | 604800000 (7 days) |
  |            Valid Values: | [1,...]            |
  | Server Default Property: | [log.roll.ms](../broker-configuration#logrollms)        |
  |              Importance: | medium             |

- #### unclean.leader.election.enable

  최후의 수단으로 ISR 셋에 속하지 않은 레플리카를 리더로 선출할지를 지정한다. 단, 이렇게 하면 데이터가 유실될 수 있다.

  |                    Type: | boolean                        |
  | -----------------------: | ------------------------------ |
  |                 Default: | false                          |
  |            Valid Values: |                                |
  | Server Default Property: | [unclean.leader.election.enable](../broker-configuration#uncleanleaderelectionenable) |
  |              Importance: | medium                         |

- #### message.downconversion.enable

  이 설정은 컨슈밍 요청에서 필요에 따라 메세지 포맷을 하위 버전으로 변환해줄지 여부를 제어한다. `false`로 설정하면, 브로커는 컨슈머가 더 오래된 메세지 포맷을 원해도 다운 컨버젼을 해주지 않는다. 브로커는 이런 구버전 클라이언트의 컨슘 요청에는 `UNSUPPORTED_VERSION` 오류로 응답한다. 이 설정은 메세지를 팔로워로 복제할 때 필요할 수도 있는 메세지 포멧 변환에는 적용되지 않는다.

  |                    Type: | boolean                           |
  | -----------------------: | --------------------------------- |
  |                 Default: | true                              |
  |            Valid Values: |                                   |
  | Server Default Property: | [log.message.downconversion.enable](../broker-configuration#logmessagedownconversionenable) |
  |              Importance: | low                               |
