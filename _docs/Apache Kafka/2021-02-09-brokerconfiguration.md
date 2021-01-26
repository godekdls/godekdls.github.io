---
title: Broker Configuration
category: Apache Kafka
order: 4
permalink: /Apache%20Kafka/broker-configuration/
description: 아파치 카프카 공식 문서에 있는 브로커 레벨 설정을 한글로 번역한 문서입니다.
image: ./../../images/kafka/logo.png
lastmod: 2021-02-14T22:25:00+09:00
comments: true
priority: 0.8
originalRefName: 아파치 카프카
originalRefLink: https://kafka.apache.org/27/documentation.html#configuration
---

### 목차

- [3.1 Broker Configs](#31-broker-configs)
  + [3.1.1 Updating Broker Configs](#311-updating-broker-configs)

---

카프카 설정은 [프로퍼티 파일 포맷](http://en.wikipedia.org/wiki/.properties)의 key-value 쌍을 사용한다. 설정 값은 파일로도, 프로그래밍 방식으로도 제공할 수 있다.

---

## 3.1 Broker Configs

핵심 설정은 다음과 같다:

- [`broker.id`](#brokerid)
- [`log.dirs`](#logdirs)
- [`zookeeper.connect`](#zookeeperconnect)

토픽 레벨 설정과 기본값은 [아래](../topic-configuration#32-topic-level-configs)에서 자세히 논한다.

- #### zookeeper.connect

  주키퍼 커넥션 문자열을 지정하며, 포맷은 `hostname:port`를 사용한다. 여기서 host, port는 주키퍼 서버의 호스트와 포트를 의미한다. 주키퍼가 다운됐을 때 다른 주키퍼 노드로 연결하려면 `hostname1:port1,hostname2:port2,hostname3:port3` 형식으로 여러 호스트를 지정해도 된다. 주키퍼 커넥션 문자열에 주키퍼 chroot 패스를 넣을 수도 있다. 이렇게 하면 관련 데이터를 해당 주키퍼 네임스페이스 경로 아래 어딘가에 저장한다. 예를 들어 chroot 패스를 `/chroot/path`로 설정하려면 커넥션 문자열을 `hostname1:port1,hostname2:port2,hostname3:port3/chroot/path`로 지정하면 된다.

  |         Type: | string    |
  | ------------: | --------- |
  |      Default: |           |
  | Valid Values: |           |
  |   Importance: | high      |
  |  Update Mode: | read-only |

- #### advertised.host.name

  DEPRECATED: [`advertised.listeners`](#advertisedlisteners)나 [`listeners`](#listeners)를 설정하지 않았을 때만 적용된다. 이 설정 대신 [`advertised.listeners`](#advertisedlisteners)를 사용해라.<br>
  클라이언트가 사용할 수 있도록, 주키퍼에 게시할 호스트명. IaaS 환경이라면 브로커가 바인드하는 인터페이스와는 달라야 할 수도 있다. 이 값을 설정하지 않으면 [`host.name`](#hostname) 값을 사용한다. 그 외는 <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">java.net.InetAddress.getCanonicalHostName()</span>이 반환한 값을 사용한다.

  |         Type: | string    |
  | ------------: | --------- |
  |      Default: | null      |
  | Valid Values: |           |
  |   Importance: | high      |
  |  Update Mode: | read-only |

- #### advertised.listeners

  클라이언트가 사용할 리스너가 [`listeners`](#listeners) 설정 프로퍼티와 다를 때 사용할 수 있는 리스너. 클라이언트가 사용할 수 있도록 주키퍼에 게시한다. IaaS 환경이라면 브로커가 바인드하는 인터페이스와는 달라야 할 수도 있다. 이 값을 설정하지 않으면 [`listeners`](#listeners) 값을 사용한다. [`listeners`](#listeners)와 달리 메타 주소 0.0.0.0은 유효하지 않다.<br>
  마찬가지로 [`listeners`](#listeners)와는 달리 이 프로퍼티에는 중복된 포트가 있을 수 있으므로, 다른 리스너의 주소를 노출하도록 구성할 수도 있다. 외부 로드 밸런서를 사용한다면 유용할 거다.

  |         Type: | string     |
  | ------------: | ---------- |
  |      Default: | null       |
  | Valid Values: |            |
  |   Importance: | high       |
  |  Update Mode: | per-broker |

- #### advertised.port

  DEPRECATED: [`advertised.listeners`](#advertisedlisteners)나 [`listeners`](#listeners)를 설정하지 않았을 때만 적용된다. 이 설정 대신 [`advertised.listeners`](#advertisedlisteners)를 사용해라.<br>
  클라이언트가 사용할 수 있도록 주키퍼에 게시할 포트. IaaS 환경이라면 브로커가 바인드하는 포트와는 달라야 할 수도 있다. 이 값을 설정하지 않으면 브로커가 바인딩하는 포트와 동일한 포트를 게시한다.

  |         Type: | int       |
  | ------------: | --------- |
  |      Default: | null      |
  | Valid Values: |           |
  |   Importance: | high      |
  |  Update Mode: | read-only |

- #### auto.create.topics.enable

  서버에서 토픽 자동 생성을 활성화한다.

  |         Type: | boolean   |
  | ------------: | --------- |
  |      Default: | true      |
  | Valid Values: |           |
  |   Importance: | high      |
  |  Update Mode: | read-only |

- #### auto.leader.rebalance.enable

  자동 리더 밸런싱을 활성화한다. 백그라운드 스레드에서 [`leader.imbalance.check.interval.seconds`](#leaderimbalancecheckintervalseconds)로 설정한 주기적인 인터벌에 따라 파티션 리더의 배포 상태를 확인한다. 리더 불균형 수치가 [`leader.imbalance.per.broker.percentage`](#leaderimbalanceperbrokerpercentage)를 초과하면 해당 파티션에 대해 선호하는 리더로 리더 리밸런스를 트리거한다.

  |         Type: | boolean   |
  | ------------: | --------- |
  |      Default: | true      |
  | Valid Values: |           |
  |   Importance: | high      |
  |  Update Mode: | read-only |

- #### background.threads

  여러 가지 백그라운드 처리 태스크에 사용할 스레드 수.

  |         Type: | int          |
  | ------------: | ------------ |
  |      Default: | 10           |
  | Valid Values: | [1,...]      |
  |   Importance: | high         |
  |  Update Mode: | cluster-wide |

- #### broker.id

  이 서버에서 사용할 브로커 id. 값을 설정하지 않으면 유니크한 브로커 id가 만들어진다. 주키퍼에서 생성된 브로커 id와 사용자가 설정한 브로커 id와의 충돌을 피하기 위해, 브로커 id는 [reserved.broker.max.id](#reservedbrokermaxid) + 1부터 시작하도록 만들어진다.

  |         Type: | int       |
  | ------------: | --------- |
  |      Default: | -1        |
  | Valid Values: |           |
  |   Importance: | high      |
  |  Update Mode: | read-only |

- #### compression.type

  주어진 토픽에 사용할 최종 압축 타입을 지정한다. 이 설정은 표준 압축 코덱('gzip', 'snappy', 'lz4', 'zstd')을 허용하며, 그 외 압축하지 않음을 나타내는 'uncompressed'와, 프로듀서가 설정한 기존 압축 코덱을 유지함을 나타내는 'producer'를 사용할 수 있다.

  |         Type: | string       |
  | ------------: | ------------ |
  |      Default: | producer     |
  | Valid Values: |              |
  |   Importance: | high         |
  |  Update Mode: | cluster-wide |

- #### control.plane.listener.name

  컨트롤러와 브로커 간의 통신에 사용할 리스너 이름. 브로커는 이 값을 사용해 리스너 리스트에서 전용 엔드포인트를 찾아 컨트롤러의 커넥션을 수신(listen)한다. 예를 들어 다음과 같은 설정으로 브로커를 기동하면:<br>
  ```properties
  listeners = INTERNAL://192.1.1.8:9092, EXTERNAL://10.1.1.5:9093, CONTROLLER://192.1.1.8:9094
  listener.security.protocol.map = INTERNAL:PLAINTEXT, EXTERNAL:SSL, CONTROLLER:SSL
  control.plane.listener.name = CONTROLLER
  ```
  이 브로커는 보안 프로토콜 "SSL"을 사용해 "192.1.1.8:9094"에서 수신을 시작한다.<br>
  컨트롤러에선 주키퍼를 통해 게시된 브로커의 엔드포인트를 발견하면, 이 설정 값으로 전용 엔드포인트를 찾아 브로커에 대한 커넥션을 구축한다.<br>
  예를 들어 카프카에 게시한 브로커의 엔드포인트가 다음과 같고,<br>
  ```properties
  "endpoints" : ["INTERNAL://broker1.example.com:9092","EXTERNAL://broker1.example.com:9093","CONTROLLER://broker1.example.com:9094"]
  ```
  컨트롤러 설정은 다음과 같다면:<br>
  ```properties
  listener.security.protocol.map = INTERNAL:PLAINTEXT, EXTERNAL:SSL, CONTROLLER:SSL
  control.plane.listener.name = CONTROLLER
  ```
  컨트롤러는 보안 프로토콜 "SSL"과 "broker1.example.com:9094"를 사용해 브로커와 연결하게 된다.<br>
  이 설정을 명시하지 않으면, 디폴트 값은 null이며, 컨트롤러 커넥션을 위한 전용 엔드포인트를 사용하지 않는다.

  |         Type: | string    |
  | ------------: | --------- |
  |      Default: | null      |
  | Valid Values: |           |
  |   Importance: | high      |
  |  Update Mode: | read-only |

- #### delete.topic.enable

  토픽 삭제를 활성화한다. 이 설정을 꺼놓으면 어드민 툴에서 토픽을 삭제해도 실제로는 지워지지 않는다.

  |         Type: | boolean   |
  | ------------: | --------- |
  |      Default: | true      |
  | Valid Values: |           |
  |   Importance: | high      |
  |  Update Mode: | read-only |

- #### host.name

  DEPRECATED: [`listeners`](#listeners)를 설정하지 않았을 때만 적용된다. 이 설정 대신 [`listeners`](#listeners)를 사용해라.<br>
  브로커의 호스트명. 설정하면 이 주소로만 바인딩한다. 설정하지 않으면 모든 인터페이스에 바인딩한다.

  |         Type: | string    |
  | ------------: | --------- |
  |      Default: | ""        |
  | Valid Values: |           |
  |   Importance: | high      |
  |  Update Mode: | read-only |

- #### leader.imbalance.check.interval.seconds

  컨트롤러가 파티션 리밸런스 검사를 트리거할 주기

  |         Type: | long      |
  | ------------: | --------- |
  |      Default: | 300       |
  | Valid Values: |           |
  |   Importance: | high      |
  |  Update Mode: | read-only |

- #### leader.imbalance.per.broker.percentage

  브로커 하나 당 허용하는 리더 불균형 비율. 브로커 당 수치가 이 값을 초과하면 컨트롤러가 리더 밸런스를 트리거한다. 값은 백분율로 지정한다.

  |         Type: | int       |
  | ------------: | --------- |
  |      Default: | 10        |
  | Valid Values: |           |
  |   Importance: | high      |
  |  Update Mode: | read-only |

- #### listeners

  리스너 리스트. 수신할 URI와 리스너 이름의 리스트로, 쉼표로 구분한다. 리스너 이름이 보안 프로토콜이 아니라면, [`listener.security.protocol.map`](#listenersecurityprotocolmap)을 함께 설정해야 한다.<br>
  리스너 이름과 포트는 유니크해야 한다.<br>
  모든 인터페이스에 바인드하려면 호스트명을 0.0.0.0으로 지정해라.<br>
  디폴트 인터페이스와 바인드하려면 호스트명을 비워둬라.<br>
  허용하는 리스너 리스트 예시:<br>
  ```properties
  PLAINTEXT://myhost:9092,SSL://:9091
  CLIENT://0.0.0.0:9092,REPLICATION://localhost:9093
  ```

  |         Type: | string     |
  | ------------: | ---------- |
  |      Default: | null       |
  | Valid Values: |            |
  |   Importance: | high       |
  |  Update Mode: | per-broker |

- #### log.dir

  로그 데이터를 보관할 디렉토리 ([log.dirs](#logdirs) 프로퍼티를 위한 부가 정보)

  |         Type: | string          |
  | ------------: | --------------- |
  |      Default: | /tmp/kafka-logs |
  | Valid Values: |                 |
  |   Importance: | high            |
  |  Update Mode: | read-only       |

- #### log.dirs

  로그 데이터를 보관할 디렉토리들. 설정하지 않으면 [log.dir](#logdir)에 있는 값을 사용한다.

  |         Type: | string    |
  | ------------: | --------- |
  |      Default: | null      |
  | Valid Values: |           |
  |   Importance: | high      |
  |  Update Mode: | read-only |

- #### log.flush.interval.messages

  메세지를 디스크로 플러시하기 전까지 로그 파티션에 누적할 메세지 수

  |         Type: | long                |
  | ------------: | ------------------- |
  |      Default: | 9223372036854775807 |
  | Valid Values: | [1,...]             |
  |   Importance: | high                |
  |  Update Mode: | cluster-wide        |

- #### log.flush.interval.ms

  모든 토픽의 메세지를 디스크로 플러시하기 전까지 메모리에 보관할 최대 시간 (ms 단위). 설정하지 않으면 [log.flush.scheduler.interval.ms](#logflushschedulerintervalms) 값을 사용한다.

  |         Type: | long         |
  | ------------: | ------------ |
  |      Default: | null         |
  | Valid Values: |              |
  |   Importance: | high         |
  |  Update Mode: | cluster-wide |

- #### log.flush.offset.checkpoint.interval.ms

  가장 최근 수행한 플러시를 기록하는 persistent 레코드를 업데이트할 주기. 로그 복구 포인트로 활용한다.

  |         Type: | int              |
  | ------------: | ---------------- |
  |      Default: | 60000 (1 minute) |
  | Valid Values: | [0,...]          |
  |   Importance: | high             |
  |  Update Mode: | read-only        |

- #### log.flush.scheduler.interval.ms

  로그 flusher가 디스크로 플러시할 로그가 있는지를 확인하는 주기 (ms)

  |         Type: | long                |
  | ------------: | ------------------- |
  |      Default: | 9223372036854775807 |
  | Valid Values: |                     |
  |   Importance: | high                |
  |  Update Mode: | read-only           |

- #### log.flush.start.offset.checkpoint.interval.ms

  로그 시작 오프셋을 저장하는 persistent 레코드를 업데이트할 주기

  |         Type: | int              |
  | ------------: | ---------------- |
  |      Default: | 60000 (1 minute) |
  | Valid Values: | [0,...]          |
  |   Importance: | high             |
  |  Update Mode: | read-only        |

- #### log.retention.bytes

  로그를 유지할 최대 사이즈로, 이 값을 초과하면 로그를 삭제한다

  |         Type: | long         |
  | ------------: | ------------ |
  |      Default: | -1           |
  | Valid Values: |              |
  |   Importance: | high         |
  |  Update Mode: | cluster-wide |

- #### log.retention.hours

  로그 파일을 유지할 기간으로 (시간 단위), 이 기간이 지나면 삭제한다. [log.retention.ms](#logretentionms) 프로퍼티의 다음 다음 후보로 사용하는 설정이다.

  |         Type: | int       |
  | ------------: | --------- |
  |      Default: | 168       |
  | Valid Values: |           |
  |   Importance: | high      |
  |  Update Mode: | read-only |

- #### log.retention.minutes

  로그 파일을 유지할 기간으로 (분 단위), 이 기간이 지나면 삭제한다. [log.retention.ms](#logretentionms) 프로퍼티 다음으로 사용하는 값이다. 값을 설정하지 않으면 [log.retention.hours](#logretentionhours) 값을 사용한다.

  |         Type: | int       |
  | ------------: | --------- |
  |      Default: | null      |
  | Valid Values: |           |
  |   Importance: | high      |
  |  Update Mode: | read-only |

- #### log.retention.ms

  로그 파일을 유지할 기간으로 (밀리세컨트 단위), 이 기간이 지나면 삭제한다. 값을 설정하지 않으면 [log.retention.minutes](#logretentionminutes) 값을 사용한다. -1로 설정하면 시간 제한을 적용하지 않는다.

  |         Type: | long         |
  | ------------: | ------------ |
  |      Default: | null         |
  | Valid Values: |              |
  |   Importance: | high         |
  |  Update Mode: | cluster-wide |

- #### log.roll.hours

  새 로그 세그먼트를 롤아웃하기 전까지의 최대 시간 (시간 단위). [log.roll.ms](#logrollms) 프로퍼티 다음으로 사용하는 값이다.

  |         Type: | int       |
  | ------------: | --------- |
  |      Default: | 168       |
  | Valid Values: | [1,...]   |
  |   Importance: | high      |
  |  Update Mode: | read-only |

- #### log.roll.jitter.hours

  최대 jitter (시간 단위). logRollTimeMillis에서 이 값을 뺀다. [log.roll.jitter.ms](#logrolljitterms) 프로퍼티 다음으로 사용하는 값이다.

  |         Type: | int       |
  | ------------: | --------- |
  |      Default: | 0         |
  | Valid Values: | [0,...]   |
  |   Importance: | high      |
  |  Update Mode: | read-only |

- #### log.roll.jitter.ms

  최대 jitter (밀리세컨드 단위). logRollTimeMillis에서 이 값을 뺀다. 값을 지정하지 않으면 [log.roll.jitter.hours](#logrolljitterhours)에 있는 값을 사용한다.

  |         Type: | long         |
  | ------------: | ------------ |
  |      Default: | null         |
  | Valid Values: |              |
  |   Importance: | high         |
  |  Update Mode: | cluster-wide |

- #### log.roll.ms

  새 로그 세그먼트를 롤아웃하기 전까지의 최대 시간 (밀리세컨드 단위). 값을 지정하지 않으면 [log.roll.hours](#logrollhours)에 있는 값을 사용한다.

  |         Type: | long         |
  | ------------: | ------------ |
  |      Default: | null         |
  | Valid Values: |              |
  |   Importance: | high         |
  |  Update Mode: | cluster-wide |

- #### log.segment.bytes

  단일 로그 파일의 최대 크기

  |         Type: | int                     |
  | ------------: | ----------------------- |
  |      Default: | 1073741824 (1 gibibyte) |
  | Valid Values: | [14,...]                |
  |   Importance: | high                    |
  |  Update Mode: | cluster-wide            |

- #### log.segment.delete.delay.ms

  파일 시스템에서 파일을 삭제하기 전 대기할 시간

  |         Type: | long             |
  | ------------: | ---------------- |
  |      Default: | 60000 (1 minute) |
  | Valid Values: | [0,...]          |
  |   Importance: | high             |
  |  Update Mode: | cluster-wide     |

- #### message.max.bytes

  카프카에서 허용할 레코드 배치의 최대 크기 (압축을 활성화했다면 압축 후의 크기). 0.10.2 이전 버전의 컨슈머를 사용할 때 이 값을 늘린다면, 컨슈머의 페치 사이즈도 늘려야 그만큼의 레코드 배치를 가져올 수 있다. 최신 버전의 메세지 포맷에선, 효율성을 고려해 레코드는 항상 배치로 그룹화된다. 구버전에선, 압축하지 않은 레코드는 배치로 묶지 않으며, 이땐 단일 레코드에만 최대 크기가 적용된다. 이 값은 토픽 레벨 설정 [`max.message.bytes`](../topic-configuration#maxmessagebytes)를 통해 토픽별로도 세팅할 수 있다.

  |         Type: | int          |
  | ------------: | ------------ |
  |      Default: | 1048588      |
  | Valid Values: | [0,...]      |
  |   Importance: | high         |
  |  Update Mode: | cluster-wide |

- #### min.insync.replicas

  이 값은 프로듀서에서 [acks](../producer-configuration#acks)를 "all"(또는 "-1")로 설정했을 때, 쓰기를 승인(acknowledge)해야 하는 최소 레플리카 수를 지정한다. 최소한 이만큼을 승인해야 쓰기에 성공한 것으로 간주한다. 이 최소값에 충족하지 않으면, 프로듀서는 예외를 발생시킨다 (NotEnoughReplicas 또는 NotEnoughReplicasAfterAppend).<br>
  이 설정과 [acks](../producer-configuration#acks)를 함께 사용하면 더 강력한 내구성을 보장할 수 있다. 전형적인 시나리오는 토픽을 replication factor 3으로 만들고, min.insync.replicas를 2로, [acks](../producer-configuration#acks)를 "all"로 메세지를 생산하는 거다. 이렇게 하면 레플리카 과반수 이상이 메세지를 받지 못하면 프로듀서에서 예외를 발생시킴을 보장할 수 있다.

  |         Type: | int          |
  | ------------: | ------------ |
  |      Default: | 1            |
  | Valid Values: | [1,...]      |
  |   Importance: | high         |
  |  Update Mode: | cluster-wide |

- #### num.io.threads

  디스크 I/O를 포함할 수도 있는, 서버에서 요청을 처리할 때 사용할 스레드 수

  |         Type: | int          |
  | ------------: | ------------ |
  |      Default: | 8            |
  | Valid Values: | [1,...]      |
  |   Importance: | high         |
  |  Update Mode: | cluster-wide |

- #### num.network.threads

  서버에서 네트워크로부터 요청을 받고 네트워크로 응답을 전송할 때 사용할 스레드 수

  |         Type: | int          |
  | ------------: | ------------ |
  |      Default: | 3            |
  | Valid Values: | [1,...]      |
  |   Importance: | high         |
  |  Update Mode: | cluster-wide |

- #### num.recovery.threads.per.data.dir

  기동 시 로그 복구와, 셧다운 시 플러시에 사용할 데이터 디렉토리 당 스레드 수

  |         Type: | int          |
  | ------------: | ------------ |
  |      Default: | 1            |
  | Valid Values: | [1,...]      |
  |   Importance: | high         |
  |  Update Mode: | cluster-wide |

- #### num.replica.alter.log.dirs.threads

  디스크 I/O를 포함할 수도 있는, 로그 디렉터리 간에 레플리카를 이동시킬 수 있는 스레드 수

  |         Type: | int       |
  | ------------: | --------- |
  |      Default: | null      |
  | Valid Values: |           |
  |   Importance: | high      |
  |  Update Mode: | read-only |

- #### num.replica.fetchers

  소스 브로커에서 메세지를 복제하는 데 사용할 fetcher 스레드 수. 이 값을 늘리면 팔로워 브로커의 I/O 병렬 처리 수준을 올릴 수 있다.

  |         Type: | int          |
  | ------------: | ------------ |
  |      Default: | 1            |
  | Valid Values: |              |
  |   Importance: | high         |
  |  Update Mode: | cluster-wide |

- #### offset.metadata.max.bytes

  오프셋 커밋과 함께 저장할 메타데이터 엔트리의 최대 크기

  |         Type: | int                |
  | ------------: | ------------------ |
  |      Default: | 4096 (4 kibibytes) |
  | Valid Values: |                    |
  |   Importance: | high               |
  |  Update Mode: | read-only          |

- #### offsets.commit.required.acks

  커밋을 수락하기 전 필요한 acks. 일반적으로는 디폴트 값(-1)을 재정의하지 않는 게 좋다.

  |         Type: | short     |
  | ------------: | --------- |
  |      Default: | -1        |
  | Valid Values: |           |
  |   Importance: | high      |
  |  Update Mode: | read-only |

- #### offsets.commit.timeout.ms

  오프셋 커밋은 오프셋 토픽의 모든 레플리카가 커밋을 받을 때까지 지연되며, 이 시간을 넘어가면 타임 아웃된다. 프로듀서 [reqeust timeout](../producer-configuration#requesttimeoutms)과 유사한 설정이다.

  |         Type: | int              |
  | ------------: | ---------------- |
  |      Default: | 5000 (5 seconds) |
  | Valid Values: | [1,...]          |
  |   Importance: | high             |
  |  Update Mode: | read-only        |

- #### offsets.load.buffer.size

  오프셋을 캐시로 로드할 때 오프셋 세그먼트에서 읽어올 배치 크기 (soft limit으로, 레코드가 너무 크면 재정의된다).

  |         Type: | int       |
  | ------------: | --------- |
  |      Default: | 5242880   |
  | Valid Values: | [1,...]   |
  |   Importance: | high      |
  |  Update Mode: | read-only |

- #### offsets.retention.check.interval.ms

  오래된 오프셋을 확인할 주기

  |         Type: | long                |
  | ------------: | ------------------- |
  |      Default: | 600000 (10 minutes) |
  | Valid Values: | [1,...]             |
  |   Importance: | high                |
  |  Update Mode: | read-only           |

- #### offsets.retention.minutes

  컨슈머 그룹에 있는 모든 컨슈머가 빠지면 (즉, 그룹이 비면), 오프셋은 보존 기간 동안 유지했다가 폐기된다. 독립형 컨슈머에선 (수동으로 파티션을 할당하는), 오프셋은 마지막 커밋 시간 이후부터 이 보존 기간이 지난 후에 만료된다.

  |         Type: | int       |
  | ------------: | --------- |
  |      Default: | 10080     |
  | Valid Values: | [1,...]   |
  |   Importance: | high      |
  |  Update Mode: | read-only |

- #### offsets.topic.compression.codec

  오프셋 토픽에 사용할 압축 코덱 - 압축은 "원자적" 커밋에 활용할 수 있다.

  |         Type: | int       |
  | ------------: | --------- |
  |      Default: | 0         |
  | Valid Values: |           |
  |   Importance: | high      |
  |  Update Mode: | read-only |

- #### offsets.topic.num.partitions

  오프셋 커밋 토픽의 파티션 수 (배포 후엔 변경하면 안 된다).

  |         Type: | int       |
  | ------------: | --------- |
  |      Default: | 50        |
  | Valid Values: | [1,...]   |
  |   Importance: | high      |
  |  Update Mode: | read-only |

- #### offsets.topic.replication.factor

  오프셋 토픽의 replication factor (가용성을 보장하려면 더 높게 설정). 클러스터 크기가 이 replication factor를 충족하지 않으면 내부 토픽 생성에 실패한다.

  |         Type: | short     |
  | ------------: | --------- |
  |      Default: | 3         |
  | Valid Values: | [1,...]   |
  |   Importance: | high      |
  |  Update Mode: | read-only |

- #### offsets.topic.segment.bytes

  로그 컴팩션과 캐시 로드를 더 빠르게 이용하려면, 오프셋 토픽 세그먼트 바이트를 비교적 작게 유지해야 한다.

  |         Type: | int                       |
  | ------------: | ------------------------- |
  |      Default: | 104857600 (100 mebibytes) |
  | Valid Values: | [1,...]                   |
  |   Importance: | high                      |
  |  Update Mode: | read-only                 |

- #### port

  DEPRECATED: [`listeners`](#listeners)를 설정하지 않았을 때만 사용한다. 이 프로퍼티 대신 [`listeners`](#listeners)를 사용해라.
  커넥션을 기다리고(listen) 수락할 포트.

  |         Type: | int       |
  | ------------: | --------- |
  |      Default: | 9092      |
  | Valid Values: |           |
  |   Importance: | high      |
  |  Update Mode: | read-only |

- #### queued.max.requests

  data-plane에서 허용할 대기 요청 수. 그 이상은 네트워크 스레드를 블로킹한다.

  |         Type: | int       |
  | ------------: | --------- |
  |      Default: | 500       |
  | Valid Values: | [1,...]   |
  |   Importance: | high      |
  |  Update Mode: | read-only |

- #### quota.consumer.default

  DEPRECATED: 주키퍼에 동적인 기본 할당량을 설정하지 않았을 때만 사용한다. clientId/컨슈머 그룹으로 구별되는 모든 컨슈머는, 이 값보다 초당 더 많은 바이트를 조회해가면 속도를 제한한다.

  |         Type: | long                |
  | ------------: | ------------------- |
  |      Default: | 9223372036854775807 |
  | Valid Values: | [1,...]             |
  |   Importance: | high                |
  |  Update Mode: | read-only           |

- #### quota.producer.default

  DEPRECATED: 주키퍼에 동적인 기본 할당량을 설정하지 않았을 때만 사용한다. clientId로 구별되는 모든 프로듀서는, 이 값보다 초당 더 많은 바이트를 생성하면 속도를 제한한다.

  |         Type: | long                |
  | ------------: | ------------------- |
  |      Default: | 9223372036854775807 |
  | Valid Values: | [1,...]             |
  |   Importance: | high                |
  |  Update Mode: | read-only           |

- #### replica.fetch.min.bytes

  각 페치 응답에 기대하는 최소 바이트. 바이트가 충분하지 않으면 [`replica.fetch.wait.max.ms`](#replicafetchwaitmaxms)(브로커 설정)까지 대기한다.

  |         Type: | int       |
  | ------------: | --------- |
  |      Default: | 1         |
  | Valid Values: |           |
  |   Importance: | high      |
  |  Update Mode: | read-only |

- #### replica.fetch.wait.max.ms

  팔로워 레플리카가 만드는 각 fetcher 요청이 최대로 대기할 시간. 처리량이 떨어지는 토픽에서 ISR이 빈번히 줄어들지 않게 막으려면 이 값은 항상 [replica.lag.time.max.ms](#replicalagtimemaxms)보다 작아야 한다.

  |         Type: | int       |
  | ------------: | --------- |
  |      Default: | 500       |
  | Valid Values: |           |
  |   Importance: | high      |
  |  Update Mode: | read-only |

- #### replica.high.watermark.checkpoint.interval.ms

  high watermark를 디스크에 저장하는 주기

  |         Type: | long             |
  | ------------: | ---------------- |
  |      Default: | 5000 (5 seconds) |
  | Valid Values: |                  |
  |   Importance: | high             |
  |  Update Mode: | read-only        |

- #### replica.lag.time.max.ms

  팔로워가 적어도 이 시간 동안 fetch 요청을 보내지 않았거나, 리더 로그 마지막 오프셋까지 컨슘하지 않으면 리더는 isr에서 이 팔로워를 제거한다.

  |         Type: | long               |
  | ------------: | ------------------ |
  |      Default: | 30000 (30 seconds) |
  | Valid Values: |                    |
  |   Importance: | high               |
  |  Update Mode: | read-only          |

- #### replica.socket.receive.buffer.bytes

  네트워크 요청을 처리할 소켓 수신 버퍼

  |         Type: | int                  |
  | ------------: | -------------------- |
  |      Default: | 65536 (64 kibibytes) |
  | Valid Values: |                      |
  |   Importance: | high                 |
  |  Update Mode: | read-only            |

- #### replica.socket.timeout.ms

  네트워크 요청에서 사용할 소켓 타임아웃. 최소한 [replica.fetch.wait.max.ms](#replicafetchwaitmaxms)만큼은 돼야 한다.

  |         Type: | int                |
  | ------------: | ------------------ |
  |      Default: | 30000 (30 seconds) |
  | Valid Values: |                    |
  |   Importance: | high               |
  |  Update Mode: | read-only          |

- #### request.timeout.ms

  이 설정은 클라이언트가 응답을 기다릴 최대 시간을 제어한다. 클라이언트는 타임 아웃될 때까지 응답을 받지 못하면, 필요한 경우 요청을 재전송할 수 있으며, 재시도 횟수를 모두 소진하면 요청은 실패로 끝난다.

  |         Type: | int                |
  | ------------: | ------------------ |
  |      Default: | 30000 (30 seconds) |
  | Valid Values: |                    |
  |   Importance: | high               |
  |  Update Mode: | read-only          |

- #### socket.receive.buffer.bytes

  소켓 서버 소켓의 SO_RCVBUF 버퍼. 값이 -1이면 OS 기본값을 사용한다.

  |         Type: | int                    |
  | ------------: | ---------------------- |
  |      Default: | 102400 (100 kibibytes) |
  | Valid Values: |                        |
  |   Importance: | high                   |
  |  Update Mode: | read-only              |

- #### socket.request.max.bytes

  소켓 요청의 최대 바이트 수

  |         Type: | int                       |
  | ------------: | ------------------------- |
  |      Default: | 104857600 (100 mebibytes) |
  | Valid Values: | [1,...]                   |
  |   Importance: | high                      |
  |  Update Mode: | read-only                 |

- #### socket.send.buffer.bytes

  소켓 서버 소켓의 SO_SNDBUF 버퍼. 값이 -1이면 OS 기본값을 사용한다.

  |         Type: | int                    |
  | ------------: | ---------------------- |
  |      Default: | 102400 (100 kibibytes) |
  | Valid Values: |                        |
  |   Importance: | high                   |
  |  Update Mode: | read-only              |

- #### transaction.max.timeout.ms

  트랜잭션에 최대로 허용할 타임아웃. 클라이언트가 요청한 트랜잭션이 이 시간을 넘어가면, 브로커는 InitProducerIdRequest에서 오류를 반환한다. 클라이언트 타임아웃이 너무 크면, 컨슈머가 트랜잭션에 속한 토픽을 읽는데 갇혀 지연될 수 있다. 이런 상황을 방지하는 설정이다.

  |         Type: | int                 |
  | ------------: | ------------------- |
  |      Default: | 900000 (15 minutes) |
  | Valid Values: | [1,...]             |
  |   Importance: | high                |
  |  Update Mode: | read-only           |

- #### transaction.state.log.load.buffer.size

  프로듀서 id와 트랜잭션을 캐시로 로드할 때 트랜잭션 로그 세그먼트에서 읽어올 배치 크기 (soft limit으로, 레코드가 너무 크면 재정의된다).

  |         Type: | int       |
  | ------------: | --------- |
  |      Default: | 5242880   |
  | Valid Values: | [1,...]   |
  |   Importance: | high      |
  |  Update Mode: | read-only |

- #### transaction.state.log.min.isr

  트랜잭션 토픽에 대한 [min.insync.replicas](#mininsyncreplicas) 설정을 재정의했다.

  |         Type: | int       |
  | ------------: | --------- |
  |      Default: | 2         |
  | Valid Values: | [1,...]   |
  |   Importance: | high      |
  |  Update Mode: | read-only |

- #### transaction.state.log.num.partitions

  트랜잭션 토픽의 파티션 수 (배포 후엔 변경하면 안 된다).

  |         Type: | int       |
  | ------------: | --------- |
  |      Default: | 50        |
  | Valid Values: | [1,...]   |
  |   Importance: | high      |
  |  Update Mode: | read-only |

- #### transaction.state.log.replication.factor

  트랜잭션 토픽의 replication factor (가용성을 보장하려면 더 높게 설정). 클러스터 크기가 이 replication factor를 충족하지 않으면 내부 토픽 생성에 실패한다.

  |         Type: | short     |
  | ------------: | --------- |
  |      Default: | 3         |
  | Valid Values: | [1,...]   |
  |   Importance: | high      |
  |  Update Mode: | read-only |

- #### transaction.state.log.segment.bytes

  로그 컴팩션과 캐시 로드를 더 빠르게 이용하려면, 트랜잭션 토픽 세그먼트 바이트를 비교적 작게 유지해야 한다.

  |         Type: | int                       |
  | ------------: | ------------------------- |
  |      Default: | 104857600 (100 mebibytes) |
  | Valid Values: | [1,...]                   |
  |   Importance: | high                      |
  |  Update Mode: | read-only                 |

- #### transactional.id.expiration.ms

  트랜잭션 코디네이터가 현재 트랜잭션의 트랜잭션 상태 업데이트를 기다릴 시간 (ms). 이 시간이 지날 때까지 업데이트하지 않으면 트랜잭션 id는 만료된다. 이 설정은 프로듀서 id 만료에도 영향을 미친다 - 프로듀서 id로 마지막 메세지를 쓴 뒤로 이 시간이 경과하면 프로듀서 id는 만료된다. 단, 토픽의 보존 설정으로 인해 프로듀서 id로 쓴 마지막 메세지가 삭제되면, 프로듀서 id가 더 빨리 만료될 수 있다.

  |         Type: | int                |
  | ------------: | ------------------ |
  |      Default: | 604800000 (7 days) |
  | Valid Values: | [1,...]            |
  |   Importance: | high               |
  |  Update Mode: | read-only          |

- #### unclean.leader.election.enable

  최후의 수단으로 ISR 셋에 속하지 않은 레플리카를 리더로 선출할지를 지정한다. 단, 이렇게 하면 데이터가 유실될 수 있다.

  |         Type: | boolean      |
  | ------------: | ------------ |
  |      Default: | false        |
  | Valid Values: |              |
  |   Importance: | high         |
  |  Update Mode: | cluster-wide |

- #### zookeeper.connection.timeout.ms

  클라이언트가 주키퍼에 대한 커넥션을 구축할 때 대기할 최대 시간. 설정하지 않으면 [zookeeper.session.timeout.ms](#zookeepersessiontimeoutms) 값을 사용한다.

  |         Type: | int       |
  | ------------: | --------- |
  |      Default: | null      |
  | Valid Values: |           |
  |   Importance: | high      |
  |  Update Mode: | read-only |

- #### zookeeper.max.in.flight.requests

  클라이언트가 주키퍼로 보낼 승인되지 않은(unacknowledged) 요청의 최대 수. 이 값을 넘어가면 블로킹된다.

  |         Type: | int       |
  | ------------: | --------- |
  |      Default: | 10        |
  | Valid Values: | [1,...]   |
  |   Importance: | high      |
  |  Update Mode: | read-only |

- #### zookeeper.session.timeout.ms

  주키퍼 세션 타임아웃

  |         Type: | int                |
  | ------------: | ------------------ |
  |      Default: | 18000 (18 seconds) |
  | Valid Values: |                    |
  |   Importance: | high               |
  |  Update Mode: | read-only          |

- #### zookeeper.set.acl

  클라이언트가 보안 ACL을 사용하도록 설정한다.

  |         Type: | boolean   |
  | ------------: | --------- |
  |      Default: | false     |
  | Valid Values: |           |
  |   Importance: | high      |
  |  Update Mode: | read-only |

- #### broker.id.generation.enable

  서버에서 브로커 id 자동 생성을 활성화한다. 활성화한다면, [reserved.broker.max.id](#reservedbrokermaxid)에 설정된 값을 검토해보는 게 좋다.

  |         Type: | boolean   |
  | ------------: | --------- |
  |      Default: | true      |
  | Valid Values: |           |
  |   Importance: | medium    |
  |  Update Mode: | read-only |

- #### broker.rack

  이 브로커의 랙. 레플리카를 할당할 때 이 설정을 통해 랙을 인식하고 내결함성을 지원한다. 예시: `RACK1`, `us-east-1d`

  |         Type: | string    |
  | ------------: | --------- |
  |      Default: | null      |
  | Valid Values: |           |
  |   Importance: | medium    |
  |  Update Mode: | read-only |

- #### connections.max.idle.ms

  유휴 커넥션 타임아웃: 서버 소켓 프로세서 스레드는 커넥션이 이 시간 이상 유휴 상태로 지속되면 커넥션을 종료한다.

  |         Type: | long                |
  | ------------: | ------------------- |
  |      Default: | 600000 (10 minutes) |
  | Valid Values: |                     |
  |   Importance: | medium              |
  |  Update Mode: | read-only           |

- #### connections.max.reauth.ms

  양수를 명시하면 (기본값은 양수가 아닌 0이다), 세션 수명이 이 설정 값을 초과하지 않았을 때 v2.2.0 이상의 클라이언트를 인증할 수 있다. 커넥션이 세션 수명 내에 재인증하지 않고, 이후에 재인증 외 다른 목적으로 사용되면 브로커는 커넥션을 끊는다. 필요하면 설정명 앞에 listener와 소문자로된 SASL 메커니즘 이름을 붙여도 된다. 예를 들어, listener.name.sasl_ssl.oauthbearer.connections.max.reauth.ms=3600000

  |         Type: | long      |
  | ------------: | --------- |
  |      Default: | 0         |
  | Valid Values: |           |
  |   Importance: | medium    |
  |  Update Mode: | read-only |

- #### controlled.shutdown.enable

  이 서버의 [통제된 셧다운](../operations#graceful-shutdown)을 활성화한다

  |         Type: | boolean   |
  | ------------: | --------- |
  |      Default: | true      |
  | Valid Values: |           |
  |   Importance: | medium    |
  |  Update Mode: | read-only |

- #### controlled.shutdown.max.retries

  [통제된 셧다운](../operations#graceful-shutdown)은 여러 가지 이유로 실패할 수 있다. 이렇게 실패했을 땐 이 설정이 재시도할 횟수를 결정한다.

  |         Type: | int       |
  | ------------: | --------- |
  |      Default: | 3         |
  | Valid Values: |           |
  |   Importance: | medium    |
  |  Update Mode: | read-only |

- #### controlled.shutdown.retry.backoff.ms

  시스템은 재시도할 때마다 전번 오류를 유발한 상태에서부터 복구해낼 시간이 필요하다 (컨트롤러 장애 조치, 복제 지연 등). 이 설정은 재시도하기 전에 대기할 시간을 결정한다.

  |         Type: | long             |
  | ------------: | ---------------- |
  |      Default: | 5000 (5 seconds) |
  | Valid Values: |                  |
  |   Importance: | medium           |
  |  Update Mode: | read-only        |

- #### controller.socket.timeout.ms

  컨트롤러 to 브로커 채널에서 사용할 소켓 타임아웃

  |         Type: | int                |
  | ------------: | ------------------ |
  |      Default: | 30000 (30 seconds) |
  | Valid Values: |                    |
  |   Importance: | medium             |
  |  Update Mode: | read-only          |

- #### default.replication.factor

  자동 생성한 토픽의 디폴트 replication factor

  |         Type: | int       |
  | ------------: | --------- |
  |      Default: | 1         |
  | Valid Values: |           |
  |   Importance: | medium    |
  |  Update Mode: | read-only |

- #### delegation.token.expiry.time.ms

  토큰을 갱신하기까지의 토큰 유효 시간(밀리세컨드). 디폴트는 하루다.

  |         Type: | long             |
  | ------------: | ---------------- |
  |      Default: | 86400000 (1 day) |
  | Valid Values: | [1,...]          |
  |   Importance: | medium           |
  |  Update Mode: | read-only        |

- #### delegation.token.master.key

  delegation 토큰을 생성하고 검증하기 위한 master/secret 키. 모든 브로커에 동일한 키를 설정해야 한다. 키를 설정하지 않거나 빈 문자열로 설정하면, 브로커는 delegation 토큰 지원을 비활성화한다.

  |         Type: | password  |
  | ------------: | --------- |
  |      Default: | null      |
  | Valid Values: |           |
  |   Importance: | medium    |
  |  Update Mode: | read-only |

- #### delegation.token.max.lifetime.ms

  토큰에는 더는 갱신할 수 없는 최대 수명이 있다. 디폴트는 7일이다.

  |         Type: | long               |
  | ------------: | ------------------ |
  |      Default: | 604800000 (7 days) |
  | Valid Values: | [1,...]            |
  |   Importance: | medium             |
  |  Update Mode: | read-only          |

- #### delete.records.purgatory.purge.interval.requests

  레코드 삭제 요청 purgatory의 퍼지 간격 (요청 수)

  |         Type: | int       |
  | ------------: | --------- |
  |      Default: | 1         |
  | Valid Values: |           |
  |   Importance: | medium    |
  |  Update Mode: | read-only |

- #### fetch.max.bytes

  페치 요청에 반환할 최대 바이트 수. 최소 1024은 돼야 한다.

  |         Type: | int                     |
  | ------------: | ----------------------- |
  |      Default: | 57671680 (55 mebibytes) |
  | Valid Values: | [1024,...]              |
  |   Importance: | medium                  |
  |  Update Mode: | read-only               |

- #### fetch.purgatory.purge.interval.requests

  페치 요청 purgatory의 퍼지 간격 (요청 수)

  |         Type: | int       |
  | ------------: | --------- |
  |      Default: | 1000      |
  | Valid Values: |           |
  |   Importance: | medium    |
  |  Update Mode: | read-only |

- #### group.initial.rebalance.delay.ms

  그룹 코디네이터가 새 그룹에서 처음 리밸런스를 수행하기 전에, 더 많은 컨슈머가 그룹에 들어올 수 있도록 기다리는 시간. 더 오래 기다리면 앞으로 리밸런스를 덜 할 순 있지만, 리밸런스를 시작하기까지 시간이 더 오래 걸린다.

  |         Type: | int              |
  | ------------: | ---------------- |
  |      Default: | 3000 (3 seconds) |
  | Valid Values: |                  |
  |   Importance: | medium           |
  |  Update Mode: | read-only        |

- #### group.max.session.timeout.ms

  등록된 컨슈머에게 허용하는 최대 세션 타임아웃. 타임아웃이 길면 오류를 감지하는 데는 시간이 더 소요되는 대신, 컨슈머는 하트 비트를 보내는 사이 사이 메세지 처리에 시간을 더 쏟을 수 있다.

  |         Type: | int                  |
  | ------------: | -------------------- |
  |      Default: | 1800000 (30 minutes) |
  | Valid Values: |                      |
  |   Importance: | medium               |
  |  Update Mode: | read-only            |

- #### group.max.size

  단일 컨슈머 그룹이 수용할 수 있는 최대 컨슈머 수.

  |         Type: | int        |
  | ------------: | ---------- |
  |      Default: | 2147483647 |
  | Valid Values: | [1,...]    |
  |   Importance: | medium     |
  |  Update Mode: | read-only  |

- #### group.min.session.timeout.ms

  등록된 컨슈머에게 허용하는 최소 세션 타임아웃. 타임아웃이 짧으면 컨슈머는 하트 비트를 더 자주 보내야 하지만, 실패를 더 빨리 감지할 수 있다. 단, 브로커 리소스를 과도하게 사용할 수도 있다.

  |         Type: | int              |
  | ------------: | ---------------- |
  |      Default: | 6000 (6 seconds) |
  | Valid Values: |                  |
  |   Importance: | medium           |
  |  Update Mode: | read-only        |

- #### inter.broker.listener.name

  브로커 간 통신에 사용하는 리스너 이름. 설정하지 않으면 리스너 이름은 [security.inter.broker.protocol](#securityinterbrokerprotocol)로 정의된다. 이 설정과 [security.inter.broker.protocol](#securityinterbrokerprotocol) 프로퍼티를 동시에 설정하는 건 오류다.

  |         Type: | string    |
  | ------------: | --------- |
  |      Default: | null      |
  | Valid Values: |           |
  |   Importance: | medium    |
  |  Update Mode: | read-only |

- #### inter.broker.protocol.version

  브로커 간에 사용할 프로토콜 버전을 지정한다.<br>
  보통은 모든 브로커를 새 버전으로 업그레이드한 후에 올린다.<br>
  유효한 값의 예시: 0.8.0, 0.8.1, 0.8.1.1, 0.8.2, 0.8.2.0, 0.8.2.1, 0.9.0.0, 0.9.0.1<br>
  전체 목록은 ApiVersion을 확인해봐라.

  |         Type: | string                                                       |
  | ------------: | ------------------------------------------------------------ |
  |      Default: | 2.7-IV2                                                      |
  | Valid Values: | [0.8.0, 0.8.1, 0.8.2, 0.9.0, 0.10.0-IV0, 0.10.0-IV1, 0.10.1-IV0, 0.10.1-IV1, 0.10.1-IV2, 0.10.2-IV0, 0.11.0-IV0, 0.11.0-IV1, 0.11.0-IV2, 1.0-IV0, 1.1-IV0, 2.0-IV0, 2.0-IV1, 2.1-IV0, 2.1-IV1, 2.1-IV2, 2.2-IV0, 2.2-IV1, 2.3-IV0, 2.3-IV1, 2.4-IV0, 2.4-IV1, 2.5-IV0, 2.6-IV0, 2.7-IV0, 2.7-IV1, 2.7-IV2] |
  |   Importance: | medium                                                       |
  |  Update Mode: | read-only                                                    |

- #### log.cleaner.backoff.ms

  정리할 로그가 없을 때 일시 정지할(sleep) 시간

  |         Type: | long               |
  | ------------: | ------------------ |
  |      Default: | 15000 (15 seconds) |
  | Valid Values: | [0,...]            |
  |   Importance: | medium             |
  |  Update Mode: | cluster-wide       |

- #### log.cleaner.dedupe.buffer.size

  모든 로그 클리너에 걸쳐 사용할, 로그 중복 제거에 쓸 총 메모리

  |         Type: | long         |
  | ------------: | ------------ |
  |      Default: | 134217728    |
  | Valid Values: |              |
  |   Importance: | medium       |
  |  Update Mode: | cluster-wide |

- #### log.cleaner.delete.retention.ms

  삭제 레코드를 얼마나 보존할지.

  |         Type: | long             |
  | ------------: | ---------------- |
  |      Default: | 86400000 (1 day) |
  | Valid Values: |                  |
  |   Importance: | medium           |
  |  Update Mode: | cluster-wide     |

- #### log.cleaner.enable

  서버에서 로그 클리너 프로세스 실행을 활성화한다. 내부 오프셋 토픽을 포함해서, [cleanup.policy](../topic-configuration#cleanuppolicy)=compact를 사용하는 토픽이 있다면 활성화해야 한다. 비활성화하면 해당 토픽들은 압축되지 않으며, 크기는 계속해서 커진다.

  |         Type: | boolean   |
  | ------------: | --------- |
  |      Default: | true      |
  | Valid Values: |           |
  |   Importance: | medium    |
  |  Update Mode: | read-only |

- #### log.cleaner.io.buffer.load.factor

  로그 클리너의 중복 제거용 버퍼 로드에 사용하는 요소. 중복 제거용 버퍼를 채울 수 있는 퍼센트를 의미한다. 값이 높을수록 더 많은 로그를 한 번에 정리할 수 있지만, 해시 충돌이 더 많아진다.

  |         Type: | double       |
  | ------------: | ------------ |
  |      Default: | 0.9          |
  | Valid Values: |              |
  |   Importance: | medium       |
  |  Update Mode: | cluster-wide |

- #### log.cleaner.io.buffer.size

  모든 클리너 스레드에 걸쳐 사용할, 로그 클리너 I/O 버퍼에 쓸 총 메모리

  |         Type: | int          |
  | ------------: | ------------ |
  |      Default: | 524288       |
  | Valid Values: | [0,...]      |
  |   Importance: | medium       |
  |  Update Mode: | cluster-wide |

- #### log.cleaner.io.max.bytes.per.second

  로그 클리너는 읽기/쓰기 I/O의 총합이 평균적으로 이 값보다 작도록 조절된다.

  |         Type: | double                 |
  | ------------: | ---------------------- |
  |      Default: | 1.7976931348623157E308 |
  | Valid Values: |                        |
  |   Importance: | medium                 |
  |  Update Mode: | cluster-wide           |

- #### log.cleaner.max.compaction.lag.ms

  메세지가 컴팩션 대상에 오르지 않고 로그에 남아있는 최대 시간. 압축하는 로그에만 적용된다.

  |         Type: | long                |
  | ------------: | ------------------- |
  |      Default: | 9223372036854775807 |
  | Valid Values: |                     |
  |   Importance: | medium              |
  |  Update Mode: | cluster-wide        |

- #### log.cleaner.min.cleanable.ratio

  로그를 정리 대상으로 올릴 수 있는, 전체 로그 대비 dirty 로그의 최소 비율. [log.cleaner.max.compaction.lag.ms](#logcleanermaxcompactionlagms)나 [log.cleaner.min.compaction.lag.ms](#logcleanermincompactionlagms) 설정도 지정했다면, 로그 컴팩터는 로그가 다음 조건 중 하나에 해당되는 즉시 압축 대상으로 간주한다: (1) 최소 [log.cleaner.min.compaction.lag.ms](#logcleanermincompactionlagms)가 지나고 나서, dirty(압축하지 않은) 레코드가 있으면서 dirty 비율 임계치에 충족하는 경우, (2) 최대 [log.cleaner.max.compaction.lag.ms](#logcleanermaxcompactionlagms)가 지났는데 로그에 dirty(압축하지 않은) 레코드가 있는 경우.

  |         Type: | double       |
  | ------------: | ------------ |
  |      Default: | 0.5          |
  | Valid Values: |              |
  |   Importance: | medium       |
  |  Update Mode: | cluster-wide |

- #### log.cleaner.min.compaction.lag.ms

  메세지를 압축하지 않고 로그에 남겨둘 최소 시간. 압축하는 로그에만 적용된다.

  |         Type: | long         |
  | ------------: | ------------ |
  |      Default: | 0            |
  | Valid Values: |              |
  |   Importance: | medium       |
  |  Update Mode: | cluster-wide |

- #### log.cleaner.threads

  로그 클리닝에 사용할 백그라운 스레드 수

  |         Type: | int          |
  | ------------: | ------------ |
  |      Default: | 1            |
  | Valid Values: | [0,...]      |
  |   Importance: | medium       |
  |  Update Mode: | cluster-wide |

- #### log.cleanup.policy

  보존 기준을 벗어난 세그먼트에 대한 기본 클린업 정책. 유효한 정책 리스트로, 콤마로 구분한다. 유효한 정책은 "delete"와 "compact"다.

  |         Type: | list              |
  | ------------: | ----------------- |
  |      Default: | delete            |
  | Valid Values: | [compact, delete] |
  |   Importance: | medium            |
  |  Update Mode: | cluster-wide      |

- #### log.index.interval.bytes

  오프셋 인덱스에 엔트리를 추가하는 간격

  |         Type: | int                |
  | ------------: | ------------------ |
  |      Default: | 4096 (4 kibibytes) |
  | Valid Values: | [0,...]            |
  |   Importance: | medium             |
  |  Update Mode: | cluster-wide       |

- #### log.index.size.max.bytes

  오프셋 인덱스의 최대 바이트 사이즈

  |         Type: | int                     |
  | ------------: | ----------------------- |
  |      Default: | 10485760 (10 mebibytes) |
  | Valid Values: | [4,...]                 |
  |   Importance: | medium                  |
  |  Update Mode: | cluster-wide            |

- #### log.message.format.version

  브로커가 로그에 메세지를 추가할 때 사용할 메세지 포맷 버전을 지정한다. 유효한 ApiVersion을 사용해야 한다. 예를 들어: 0.8.2, 0.9.0.0, 0.10.0. 자세한 내용은 ApiVersion을 확인해라. 사용자가 특정 메세지 포맷 버전을 설정하면, 디스크에 있는 모든 기존 메세지가 이 버전보다 작거나 같음을 인증하는 거다. 이 값을 잘못 설정하면, 구버전을 사용하는 컨슈머는 메세지를 이해할 수 없는 포맷으로 받게되므로 컨슈머가 중단될 수 있다.

  |         Type: | string                                                       |
  | ------------: | ------------------------------------------------------------ |
  |      Default: | 2.7-IV2                                                      |
  | Valid Values: | [0.8.0, 0.8.1, 0.8.2, 0.9.0, 0.10.0-IV0, 0.10.0-IV1, 0.10.1-IV0, 0.10.1-IV1, 0.10.1-IV2, 0.10.2-IV0, 0.11.0-IV0, 0.11.0-IV1, 0.11.0-IV2, 1.0-IV0, 1.1-IV0, 2.0-IV0, 2.0-IV1, 2.1-IV0, 2.1-IV1, 2.1-IV2, 2.2-IV0, 2.2-IV1, 2.3-IV0, 2.3-IV1, 2.4-IV0, 2.4-IV1, 2.5-IV0, 2.6-IV0, 2.7-IV0, 2.7-IV1, 2.7-IV2] |
  |   Importance: | medium                                                       |
  |  Update Mode: | read-only                                                    |

- #### log.message.timestamp.difference.max.ms

  브로커가 메세지를 받은 시각과 메세지에 지정한 타임스탬프의 차이를 허용할 최대치. [log.message.timestamp.type](#logmessagetimestamptype)=CreateTime으로 설정했다면, 타임스탬프 차이가 이 임계치를 초과하면 메세지를 거부한다. 이 설정은 [log.message.timestamp.type](#logmessagetimestamptype)=LogAppendTime에선 무시된다. 이 최대 타임스탬프 차이 허용치는 [log.retention.ms](#logretentionms)보다 크지 않아야 불필요한 로그 롤링을 빈번히 수행하지 않는다.

  |         Type: | long                |
  | ------------: | ------------------- |
  |      Default: | 9223372036854775807 |
  | Valid Values: |                     |
  |   Importance: | medium              |
  |  Update Mode: | cluster-wide        |

- #### log.message.timestamp.type

  메세지의 타임스탬프가 메세지 생성 시각인지, 로그를 추가한 시각인지를 정의한다. `CreateTime`이나 `LogAppendTime` 중 하나를 사용해야 한다.

  |         Type: | string                      |
  | ------------: | --------------------------- |
  |      Default: | CreateTime                  |
  | Valid Values: | [CreateTime, LogAppendTime] |
  |   Importance: | medium                      |
  |  Update Mode: | cluster-wide                |

- #### log.preallocate

  세그먼트를 새로 만들 때 파일을 미리 할당할 것인가? 카프카를 윈도우에서 사용한다면 true로 설정해야 할 거다.

  |         Type: | boolean      |
  | ------------: | ------------ |
  |      Default: | false        |
  | Valid Values: |              |
  |   Importance: | medium       |
  |  Update Mode: | cluster-wide |

- #### log.retention.check.interval.ms

  로그 클리너가 삭제할 수 있는 로그가 있는지 확인할 주기 (밀리세컨드 단위)

  |         Type: | long               |
  | ------------: | ------------------ |
  |      Default: | 300000 (5 minutes) |
  | Valid Values: | [1,...]            |
  |   Importance: | medium             |
  |  Update Mode: | read-only          |

- #### max.connection.creation.rate

  브로커에서 언제든지 허용할 시간당 최대 커넥션 생성 수. 설정명 앞에 리스너 프리픽스를 달아서 리스너 레벨 제한을 설정할 수도 있다. 예를 들어, `listener.name.internal.max.connection.creation.rate`. 브로커 전체의 커넥션 속도 제한은 브로커 용량을 기준으로 설정해야 하며, 리스너 제한은 어플리케이션 요구 사항에 따라 설정해야 한다. 브로커 간 리스너를 뺀 나머지는 리스너나 브로커 제한치에 도달하면 새 커넥션을 스로틀링한다. 브로커 간 리스너의 커넥션은 리스너 레벨 제한치에 도달했을 때만 스로틀링된다.

  |         Type: | int          |
  | ------------: | ------------ |
  |      Default: | 2147483647   |
  | Valid Values: | [0,...]      |
  |   Importance: | medium       |
  |  Update Mode: | cluster-wide |

- #### max.connections

  브로커에서 언제든지 허용할 최대 커넥션 수. [max.connections.per.ip](#maxconnectionsperip)로 설정한 모든 ip 단위 제한에 추가로 적용되는 제한이다. 설정명 앞에 리스너 프리픽스를 달아서 리스너 레벨 제한을 설정할 수도 있다. 예를 들어, `listener.name.internal.max.connections`. 브로커 전체 제한은 브로커 용량을 기준으로 설정해야 하며, 리스너 제한은 어플리케이션 요구 사항에 따라 설정해야 한다. 리스너나 브로커 제한치에 도달하면 새 커넥션을 차단한다. 브로커 전체 제한치에 도달하더라도 브로커 간 리스너의 커넥션은 허용한다. 이땐 다른 리스너에서 가장 최근에 사용한 커넥션이 닫히게 된다.

  |         Type: | int          |
  | ------------: | ------------ |
  |      Default: | 2147483647   |
  | Valid Values: | [0,...]      |
  |   Importance: | medium       |
  |  Update Mode: | cluster-wide |

- #### max.connections.per.ip

  각 IP 주소에서 허용되는 최대 커넥션 수. [max.connections.per.ip.overrides](#maxconnectionsperipoverrides) 프로퍼티로 재정의했다면 0으로 설정해도 된다. 제한치에 도달하면 해당 IP 주소에서 새 커넥션 생성을 막는다.

  |         Type: | int          |
  | ------------: | ------------ |
  |      Default: | 2147483647   |
  | Valid Values: | [0,...]      |
  |   Importance: | medium       |
  |  Update Mode: | cluster-wide |

- #### max.connections.per.ip.overrides

  디폴트 최대 커넥션 수를 재정의할 IP나 호스트명 리스트로, 콤마로 구분한다. 예를 들면 "hostName:100,127.0.0.1:200"

  |         Type: | string       |
  | ------------: | ------------ |
  |      Default: | ""           |
  | Valid Values: |              |
  |   Importance: | medium       |
  |  Update Mode: | cluster-wide |

- #### max.incremental.fetch.session.cache.slots

  [incremental 페치](https://cwiki-test.apache.org/confluence/display/KAFKA/KIP-227%3A+Introduce+Incremental+FetchRequests+to+Increase+Partition+Scalability)를 위한 페치 세션을 유지할 최대 갯수.

  |         Type: | int       |
  | ------------: | --------- |
  |      Default: | 1000      |
  | Valid Values: | [0,...]   |
  |   Importance: | medium    |
  |  Update Mode: | read-only |

- #### num.partitions

  토픽 당 디폴트 로그 파티션 수

  |         Type: | int       |
  | ------------: | --------- |
  |      Default: | 1         |
  | Valid Values: | [1,...]   |
  |   Importance: | medium    |
  |  Update Mode: | read-only |

- #### password.encoder.old.secret

  동적으로 설정한 암호를 인코딩하는데 사용했던 이전 시크릿. 시크릿을 업데이트할 때만 필요다. 값을 지정하면 동적으로 인코딩된 모든 패스워드는 이 이전 secret으로 디코딩되고, 브로커가 시작할 때 [password.encoder.secret](#passwordencodersecret)을 사용해 다시 인코딩한다.

  |         Type: | password  |
  | ------------: | --------- |
  |      Default: | null      |
  | Valid Values: |           |
  |   Importance: | medium    |
  |  Update Mode: | read-only |

- #### password.encoder.secret

  이 브로커에 동적으로 설정한 암호를 인코딩하는데 사용할 시크릿.

  |         Type: | password  |
  | ------------: | --------- |
  |      Default: | null      |
  | Valid Values: |           |
  |   Importance: | medium    |
  |  Update Mode: | read-only |

- #### principal.builder.class

  KafkaPrincipalBuilder 인터페이스를 구현한 클래스의 풀 네임(fully qualified name). 권한을 부여할 때 사용하는 KafkaPrincipal 객체를 빌드하는데 사용한다. 예전에 SSL을 통한 클라이언트 인증에 사용했었던, deprecated된 PrincipalBuilder 인터페이스도 지원한다. principal 빌더를 정의하지 않았을 때의 기본 동작은 사용 중인 보안 프로토콜에 따라 다르다. SSL 인증에선, 클라이언트 인증서가 있다면, 인증서의 DN(distinguished name)에 [`ssl.principal.mapping.rules`](#sslprincipalmappingrules)로 정의한 rule을 적용해서 principal을 만든다. 그외는, 클라이언트 인증이 필요하지 않다면 principal 이름은 ANONYMOUS가 된다. SASL 인증에선, GSSAPI를 사용 중이라면 [`sasl.kerberos.principal.to.local.rules`](#saslkerberosprincipaltolocalrules)에 정의된 rule에서, 다른 메커니즘에선 SASL 인증 ID를 통해 principal을 파생한다. PLAINTEXT에선 principal은 ANONYMOUS가 된다.

  |         Type: | class      |
  | ------------: | ---------- |
  |      Default: | null       |
  | Valid Values: |            |
  |   Importance: | medium     |
  |  Update Mode: | per-broker |

- #### producer.purgatory.purge.interval.requests

  프로듀서 요청 purgatory의 퍼지 간격 (요청 수)

  |         Type: | int       |
  | ------------: | --------- |
  |      Default: | 1000      |
  | Valid Values: |           |
  |   Importance: | medium    |
  |  Update Mode: | read-only |

- #### queued.max.request.bytes

  허용할 대기 바이트 수. 이 이상의 요청은 읽지 않는다.

  |         Type: | long      |
  | ------------: | --------- |
  |      Default: | -1        |
  | Valid Values: |           |
  |   Importance: | medium    |
  |  Update Mode: | read-only |

- #### replica.fetch.backoff.ms

  파티션 페치 오류가 발생했을 때 일시 정지할(sleep) 시간.

  |         Type: | int             |
  | ------------: | --------------- |
  |      Default: | 1000 (1 second) |
  | Valid Values: | [0,...]         |
  |   Importance: | medium          |
  |  Update Mode: | read-only       |

- #### replica.fetch.max.bytes

  각 파티션에 페치해볼 메세지 바이트 수. 이 값은 절대적인 최대값이 아니다. 비어있지 않은 첫 번째 파티션의 첫 레코드 배치가 이 값보다 크더라도, 진행을 이어갈 수 있도록 레코드 배치를 반환한다. 브로커가 허용하는 레코드 배치의 최대 크기는 [`message.max.bytes`](#messagemaxbytes)(브로커 설정), 또는 [`max.message.bytes`](../topic-configuration#maxmessagebytes)(토픽 설정)를 통해 정의된다.

  |         Type: | int                  |
  | ------------: | -------------------- |
  |      Default: | 1048576 (1 mebibyte) |
  | Valid Values: | [0,...]              |
  |   Importance: | medium               |
  |  Update Mode: | read-only            |

- #### replica.fetch.response.max.bytes

  전체 페치 응답에 기대하는 최대 바이트. 레코드는 배치로 조회하며, 비어있지 않은 첫 번째 파티션의 첫 레코드 배치가 이 값보다 크더라도, 진행을 이어갈 수 있도록 똑같이 레코드 배치를 반환한다. 따라서, 이 값은 절대적인 최대값이 아니다. 브로커가 허용하는 레코드 배치의 최대 크기는 [`message.max.bytes`](#messagemaxbytes)(브로커 설정), 또는 [`max.message.bytes`](../topic-configuration#maxmessagebytes)(토픽 설정)를 통해 정의된다.

  |         Type: | int                     |
  | ------------: | ----------------------- |
  |      Default: | 10485760 (10 mebibytes) |
  | Valid Values: | [0,...]                 |
  |   Importance: | medium                  |
  |  Update Mode: | read-only               |

- #### replica.selector.class

  ReplicaSelector를 구현한 클래스의 풀 네임(fully qualified name). 브로커는 이 인터페이스를 통해 선호하는 읽기 레플리카를 찾는다. 기본적으로는 리더를 리턴하는 구현체를 사용한다.

  |         Type: | string    |
  | ------------: | --------- |
  |      Default: | null      |
  | Valid Values: |           |
  |   Importance: | medium    |
  |  Update Mode: | read-only |

- #### reserved.broker.max.id

  [broker.id](#brokerid)에 사용할 수 있는 최대 숫자

  |         Type: | int       |
  | ------------: | --------- |
  |      Default: | 1000      |
  | Valid Values: | [0,...]   |
  |   Importance: | medium    |
  |  Update Mode: | read-only |

- #### sasl.client.callback.handler.class

  AuthenticateCallbackHandler 인터페이스를 구현한 SASL 클라이언트 콜백 핸들러 클래스의 풀 네임(fully qualified name).

  |         Type: | class     |
  | ------------: | --------- |
  |      Default: | null      |
  | Valid Values: |           |
  |   Importance: | medium    |
  |  Update Mode: | read-only |

- #### sasl.enabled.mechanisms

  카프카 서버에서 활성화할 SASL 메커니즘 리스트. 이 리스트엔 시큐리티 프로바이더를 사용할 수 있는 메커니즘은 모두 넣을 수 있다. 기본적으로는 GSSAPI만 활성화된다.

  |         Type: | list       |
  | ------------: | ---------- |
  |      Default: | GSSAPI     |
  | Valid Values: |            |
  |   Importance: | medium     |
  |  Update Mode: | per-broker |

- #### sasl.jaas.config

  JAAS 설정 파일 포맷에 있는, SASL 연결을 위한 JAAS 로그인 컨텍스트 파라미터. JAAS 설정 파일 포맷은 [여기](http://docs.oracle.com/javase/8/docs/technotes/guides/security/jgss/tutorials/LoginConfigFile.html)에서 설명하고 있다. 이 값에 사용하는 포맷은 '`loginModuleClass controlFlag (optionName=optionValue)*;`'이다. 브로커에선 앞에 listener와 소문자로된 SASL 메커니즘 이름을 지정해야 한다. 예를 들어, listener.name.sasl_ssl.scram-sha-256.sasl.jaas.config=com.example.ScramLoginModule required;

  |         Type: | password   |
  | ------------: | ---------- |
  |      Default: | null       |
  | Valid Values: |            |
  |   Importance: | medium     |
  |  Update Mode: | per-broker |

- #### sasl.kerberos.kinit.cmd

  커버로스 kinit 커맨드 경로.

  |         Type: | string         |
  | ------------: | -------------- |
  |      Default: | /usr/bin/kinit |
  | Valid Values: |                |
  |   Importance: | medium         |
  |  Update Mode: | per-broker     |

- #### sasl.kerberos.min.time.before.relogin

  리프레시 시도 간격 (로그인 스레드 sleep 시간).

  |         Type: | long       |
  | ------------: | ---------- |
  |      Default: | 60000      |
  | Valid Values: |            |
  |   Importance: | medium     |
  |  Update Mode: | per-broker |

- #### sasl.kerberos.principal.to.local.rules

  principal 이름을 짧은 이름(보통은 OS 사용자 이름)으로 매핑하기 위한 rule 리스트. 리스트에 있는 rule은 순서대로 평가하며, principal 이름과 일치하는 첫 번째 rule을 사용해 짧은 이름에 매핑한다. 뒤에 있는 rule은 무시한다. 기본적으로는, {username}/{hostname}@{REALM} 형식의 principal 이름은 {username}에 매핑된다. 포맷과 관련한 자세한 내용은 [보안 인가와 ACL](../security#74-authorization-and-acls)을 참고해라. 단, [`principal.builder.class`](#principalbuilderclass) 설정에 KafkaPrincipalBuilder 구현체를 지정했다면 이 설정은 무시한다.

  |         Type: | list       |
  | ------------: | ---------- |
  |      Default: | DEFAULT    |
  | Valid Values: |            |
  |   Importance: | medium     |
  |  Update Mode: | per-broker |

- #### sasl.kerberos.service.name

  카프카가 실행되는 커버로스 principal 이름. 카프카의 JAAS 설정으로도 정의할 수 있고, 카프카 설정에서도 정의할 수 있다.

  |         Type: | string     |
  | ------------: | ---------- |
  |      Default: | null       |
  | Valid Values: |            |
  |   Importance: | medium     |
  |  Update Mode: | per-broker |

- #### sasl.kerberos.ticket.renew.jitter

  갱신 시간에 추가되는 랜덤 지터 백분율.

  |         Type: | double     |
  | ------------: | ---------- |
  |      Default: | 0.05       |
  | Valid Values: |            |
  |   Importance: | medium     |
  |  Update Mode: | per-broker |

- #### sasl.kerberos.ticket.renew.window.factor

  로그인 스레드는 마지막 갱신 시각부터 티켓 만료 시간까지 남은 시간이, 지정한 지정한 윈도우 팩터만큼 지날 때까지 일시정지하며(sleep), 윈도우 팩터에 도달하면 티켓 갱신을 시도한다.

  |         Type: | double     |
  | ------------: | ---------- |
  |      Default: | 0.8        |
  | Valid Values: |            |
  |   Importance: | medium     |
  |  Update Mode: | per-broker |

- #### sasl.login.callback.handler.class

  AuthenticateCallbackHandler 인터페이스를 구현한 SASL 로그인 콜백 핸들러 클래스의 풀 네임(fully qualified name). 브로커에선 앞에 listener와 소문자로된 SASL 메커니즘 이름을 지정해야 한다. 예를 들면, listener.name.sasl_ssl.scram-sha-256.sasl.login.callback.handler.class=com.example.CustomScramLoginCallbackHandler

  |         Type: | class     |
  | ------------: | --------- |
  |      Default: | null      |
  | Valid Values: |           |
  |   Importance: | medium    |
  |  Update Mode: | read-only |

- #### sasl.login.class

  Login 인터페이스를 구현한 클래스의 풀 네임(fully qualified name). 브로커에선 앞에 listener와 소문자로된 SASL 메커니즘 이름을 지정해야 한다. 예를 들어, listener.name.sasl_ssl.scram-sha-256.sasl.login.class=com.example.CustomScramLogin

  |         Type: | class     |
  | ------------: | --------- |
  |      Default: | null      |
  | Valid Values: |           |
  |   Importance: | medium    |
  |  Update Mode: | read-only |

- #### sasl.login.refresh.buffer.seconds

  credential을 리프레시할 때, credential을 만료하기 전 유지할 버퍼 시간 (초 단위). 리프레시하려던 시간이 버퍼 시간보다 늦다면, 리프레시 시간을 앞당겨 가능한 한 버퍼 시간을 유지한다. 유효한 값은 0에서 3600(1시간) 사이다. 값을 지정하지 않으면 기본값 300(5분)을 사용한다. 이 값과 [sasl.login.refresh.min.period.seconds](#saslloginrefreshminperiodseconds)의 합이 credential의 남은 수명을 넘어가면 둘다 무시된다. 현재는 OAUTHBEARER에만 적용된다.

  |         Type: | short      |
  | ------------: | ---------- |
  |      Default: | 300        |
  | Valid Values: |            |
  |   Importance: | medium     |
  |  Update Mode: | per-broker |

- #### sasl.login.refresh.min.period.seconds

  credential을 리프레시하기 전에 로그인 리프레시 스레드가 대기할 최소 시간 (초 단위). 유효한 값은 0에서 900(15분) 사이다. 값을 지정하지 않으면 기본값 60(1분)을 사용한다. 이 값과 [sasl.login.refresh.buffer.seconds](#saslloginrefreshbufferseconds)의 합이 credential의 남은 수명을 넘어가면 둘다 무시된다. 현재는 OAUTHBEARER에만 적용된다.

  |         Type: | short      |
  | ------------: | ---------- |
  |      Default: | 60         |
  | Valid Values: |            |
  |   Importance: | medium     |
  |  Update Mode: | per-broker |

- #### sasl.login.refresh.window.factor

  로그인 리프레시 스레드는 credential의 수명이 지정한 윈도우 팩터만큼 지날 때까지 일시정지하며(sleep), 윈도우 팩터에 도달하면 credential 리프레시를 시도한다. 유효한 값은 0.5(50%)에서 1.0(100%) 사이다. 값을 지정하지 않으면 기본값 0.8(80%)을 사용한다. 현재는 OAUTHBEARER에만 적용된다.

  |         Type: | double     |
  | ------------: | ---------- |
  |      Default: | 0.8        |
  | Valid Values: |            |
  |   Importance: | medium     |
  |  Update Mode: | per-broker |

- #### sasl.login.refresh.window.jitter

  로그인 리프레시 스레드의 sleep 시간에 추가되는, credential의 수명 계산에 사용할 랜덤 지터의 최대 크기. 유효한 값은 0부터 0.25(25%) 이하다. 값을 지정하지 않으면 기본값 0.05(5%)를 사용한다. 현재는 OAUTHBEARER에만 적용된다.

  |         Type: | double     |
  | ------------: | ---------- |
  |      Default: | 0.05       |
  | Valid Values: |            |
  |   Importance: | medium     |
  |  Update Mode: | per-broker |

- #### sasl.mechanism.inter.broker.protocol

  브로커 간의 통신에 사용할 SASL 메커니즘. 디폴트는 GSSAPI다.

  |         Type: | string     |
  | ------------: | ---------- |
  |      Default: | GSSAPI     |
  | Valid Values: |            |
  |   Importance: | medium     |
  |  Update Mode: | per-broker |

- #### sasl.server.callback.handler.class

  AuthenticateCallbackHandler 인터페이스를 구현한 SASL 서버 콜백 핸들러 클래스의 풀 네임(fully qualified name). 서버 콜백 핸들러는 앞에 listener와 소문자로된 SASL 메커니즘 이름을 지정해야 한다. 예를 들어, listener.name.sasl_ssl.plain.sasl.server.callback.handler.class=com.example.CustomPlainCallbackHandler.

  |         Type: | class     |
  | ------------: | --------- |
  |      Default: | null      |
  | Valid Values: |           |
  |   Importance: | medium    |
  |  Update Mode: | read-only |

- #### security.inter.broker.protocol

  브로커 간 통신에 사용하는 보안 프로토콜. 유효한 값은 PLAINTEXT, SSL, SASL_PLAINTEXT, SASL_SSL이다. 이 설정과 [inter.broker.listener.name](#interbrokerlistenername) 프로퍼티를 동시에 설정하는 건 오류다.

  |         Type: | string    |
  | ------------: | --------- |
  |      Default: | PLAINTEXT |
  | Valid Values: |           |
  |   Importance: | medium    |
  |  Update Mode: | read-only |

- #### socket.connection.setup.timeout.max.ms

  클라이언트가 소켓 커넥션이 구축될 때까지 기다릴 최대 시간. 연이어서 커넥션 연결에 실패하면 매번 실패할 때마다 커넥션 세팅 타임아웃이 늘어나, 순식간에 이 최대값까지 커질 수 있다. 커넥션 폭풍을 방지하기 위해 타임아웃에 랜덤화 계수 0.2를 적용해, 계산된 값보다 20% 아래 ~ 20% 위까지의 랜덤 범위를 만든다.
  
  |         Type: | long                 |
  | ------------: | -------------------- |
  |      Default: | 127000 (127 seconds) |
  | Valid Values: |                      |
  |   Importance: | medium               |
  |  Update Mode: | read-only            |
  
- #### socket.connection.setup.timeout.ms

  클라이언트가 소켓 커넥션이 구축될 때까지 기다리는 시간. 타임아웃되기 전에 커넥션이 구축되지 않으면 클라이언트는 소켓 채널을 닫는다.

  |         Type: | long               |
  | ------------: | ------------------ |
  |      Default: | 10000 (10 seconds) |
  | Valid Values: |                    |
  |   Importance: | medium             |
  |  Update Mode: | read-only          |

- #### ssl.cipher.suites


  암호화 스위트 리스트. 암호와 스위트는 TLS나 SSL 네트워크 프로토콜로 네트워크 커넥션 보안 설정을 협상하는 데 사용되는 인증, 암호화, MAC, 키 교환 알고리즘을 하나로 조합해놓은 집합이다. 기본적으로는 가능한 모든 암호화 스위트를 지원한다.

|         Type: | list       |
| ------------: | ---------- |
|      Default: | ""         |
| Valid Values: |            |
|   Importance: | medium     |
|  Update Mode: | per-broker |

- #### ssl.client.auth

  카프카 브로커가 클라이언트 인증을 요청하도록 설정한다. 다음 설정이 일반적이다:

  - `ssl.client.auth=required` required로 설정하면 클라이언트 인증을 요구한다.
  - `ssl.client.auth=requested` 클라이언트 인증은 옵션이란 뜻이다. required와는 달리 클라이언트가 인증 정보를 제공할지를 자체적으로 선택할 수 있다.
  - `ssl.client.auth=none` 클라이언트 인증이 필요 없다는 뜻이다.

  |         Type: | string                      |
  | ------------: | --------------------------- |
  |      Default: | none                        |
  | Valid Values: | [required, requested, none] |
  |   Importance: | medium                      |
  |  Update Mode: | per-broker                  |

- #### ssl.enabled.protocols

  SSL 커넥션에 활성화할 프로토콜 리스트. 자바 11 이상에서 실행하면 기본값은 'TLSv1.2,TLSv1.3'이며, 그 외는 'TLSv1.2'다. 자바 11 기본값에선 클라이언트와 서버 둘 다 지원한다면 TLSv1.3을, 그외는 TLSv1.2로 폴백한다 (둘 다 최소 TLSv1.2는 지원한다고 가정). 대부분은 이 기본값으로도 충분하다. [`ssl.protocol`](#sslprotocol) 설정도 참고해라.

  |         Type: | list       |
  | ------------: | ---------- |
  |      Default: | TLSv1.2    |
  | Valid Values: |            |
  |   Importance: | medium     |
  |  Update Mode: | per-broker |

- #### ssl.key.password

  keystore 파일의 개인키 또는 [`ssl.keystore.key`](#sslkeystorekey)에 지정한 PEM 키의 패스워드. 클라이언트에선 양방향 인증을 설정했을 때만 필요하다.

  |         Type: | password   |
  | ------------: | ---------- |
  |      Default: | null       |
  | Valid Values: |            |
  |   Importance: | medium     |
  |  Update Mode: | per-broker |

- #### ssl.keymanager.algorithm

  SSL 커넥션에서 키 매니저 팩토리가 사용할 알고리즘. 기본값은 자바 가상 머신에 설정된 키 매니저 팩토리 알고리즘이다.

  |         Type: | string     |
  | ------------: | ---------- |
  |      Default: | SunX509    |
  | Valid Values: |            |
  |   Importance: | medium     |
  |  Update Mode: | per-broker |

- #### ssl.keystore.certificate.chain

  '[ssl.keystore.type](#sslkeystoretype)'에 지정한 포맷을 사용한 인증서 체인. 디폴트 SSL 엔진 팩토리는 X.509 인증서 리스트를 가진 PEM 형식만 지원한다.
  
  |         Type: | password   |
  | ------------: | ---------- |
  |      Default: | null       |
  | Valid Values: |            |
  |   Importance: | medium     |
  |  Update Mode: | per-broker |

- #### ssl.keystore.key

  '[ssl.keystore.type](#sslkeystoretype)'에 지정한 포맷을 사용한 개인키. 디폴트 SSL 엔진 팩토리는 PKCS#8 키를 가진 PEM 형식만 지원한다. 키가 암호화됐다면 '[ssl.key.password](#sslkeypassword)'를 통해 키 비밀번호를 지정해야 한다.

  |         Type: | password   |
  | ------------: | ---------- |
  |      Default: | null       |
  | Valid Values: |            |
  |   Importance: | medium     |
  |  Update Mode: | per-broker |

- #### ssl.keystore.location

  keystore 파일의 위치. 클라이언트에선 선택 사항이다. 클라이언트에선 양방향 인증에 사용할 수 있다.

  |         Type: | string     |
  | ------------: | ---------- |
  |      Default: | null       |
  | Valid Values: |            |
  |   Importance: | medium     |
  |  Update Mode: | per-broker |

- #### ssl.keystore.password

  keystore 파일의 저장소 패스워드. 클라이언트에선 선택 사항이며, '[ssl.keystore.location](#sslkeystorelocation)'을 설정했을 때만 필요하다. PEM 형식에는 keystore 패스워드를 지원하지 않는다.

  |         Type: | password   |
  | ------------: | ---------- |
  |      Default: | null       |
  | Valid Values: |            |
  |   Importance: | medium     |
  |  Update Mode: | per-broker |

- #### ssl.keystore.type

  keystore 파일의 파일 포맷. 클라이언트에선 선택 사항이다.

  |         Type: | string     |
  | ------------: | ---------- |
  |      Default: | JKS        |
  | Valid Values: |            |
  |   Importance: | medium     |
  |  Update Mode: | per-broker |

- #### ssl.protocol

  SSLContext를 생성할 때 사용할 SSL 프로토콜. 자바 11 이상에서 실행하면 기본값은 'TLSv1.3'이며, 그 외는 'TLSv1.2'다. 대부분은 이 기본값으로도 충분하다. 최신 JVM에서 허용하는 값은 'TLSv1.2'과 'TLSv1.3'이다. 구버전 JVM에선 'TLS', 'TLSv1.1', 'SSL', 'SSLv2', 'SSLv3'을 지원할 수도 있지만, 보안 취약점이 알려져 있어서 사용하지 않는 게 좋다. 이 설정과 '[ssl.enabled.protocols](#sslenabledprotocols)'에 기본값을 사용하면, 서버가 'TLSv1.3'을 지원하지 않는 경우엔 클라이언트는 'TLSv1.2'로 다운그레이드된다. 이 설정을 'TLSv1.2'로 지정하면, [ssl.enabled.protocols](#sslenabledprotocols)에 'TLSv1.3'이 있고 서버는 'TLSv1.3'만 지원하더라도, 클라이언트는 'TLSv1.3'을 사용하지 않는다.

  |         Type: | string     |
  | ------------: | ---------- |
  |      Default: | TLSv1.2    |
  | Valid Values: |            |
  |   Importance: | medium     |
  |  Update Mode: | per-broker |

- #### ssl.provider

  SSL 커넥션에 사용할 시큐리티 프로바이더 이름. 기본값은 JVM의 디폴트 시큐리티 프로바이더다.

  |         Type: | string     |
  | ------------: | ---------- |
  |      Default: | null       |
  | Valid Values: |            |
  |   Importance: | medium     |
  |  Update Mode: | per-broker |

- #### ssl.trustmanager.algorithm

  SSL 커넥션에서 trust 매니저 팩토리가 사용할 알고리즘. 기본값은 자바 가상 머신에 설정된 trust 매니저 팩토리 알고리즘이다.

  |         Type: | string     |
  | ------------: | ---------- |
  |      Default: | PKIX       |
  | Valid Values: |            |
  |   Importance: | medium     |
  |  Update Mode: | per-broker |

- #### ssl.truststore.certificates

  '[ssl.truststore.type](#ssltruststoretype)'에 지정한 포맷을 사용한 신뢰할 수 있는 인증서. 디폴트 SSL 엔진 팩토리는 X.509 인증서를 가진 PEM 형식만 지원한다.

  |         Type: | password   |
  | ------------: | ---------- |
  |      Default: | null       |
  | Valid Values: |            |
  |   Importance: | medium     |
  |  Update Mode: | per-broker |

- #### ssl.truststore.location

  truststore 파일의 위치.

  |         Type: | string     |
  | ------------: | ---------- |
  |      Default: | null       |
  | Valid Values: |            |
  |   Importance: | medium     |
  |  Update Mode: | per-broker |

- #### ssl.truststore.password

  truststore 파일의 패스워드. 패스워드를 설정하지 않으면 설정한 truststore 파일을 사용할 순 있지만 무결성 검사는 비활성화된다. PEM 형식에는 truststore 패스워드를 지원하지 않는다.

  |         Type: | password   |
  | ------------: | ---------- |
  |      Default: | null       |
  | Valid Values: |            |
  |   Importance: | medium     |
  |  Update Mode: | per-broker |

- #### ssl.truststore.type

  truststore 파일의 파일 포맷.

  |         Type: | string     |
  | ------------: | ---------- |
  |      Default: | JKS        |
  | Valid Values: |            |
  |   Importance: | medium     |
  |  Update Mode: | per-broker |

- #### zookeeper.clientCnxnSocket

  보통은 주키퍼에 TLS로 연결할 때 `org.apache.zookeeper.ClientCnxnSocketNetty`로 설정한다. 같은 이름을 가진 시스템 프로퍼티 `zookeeper.clientCnxnSocket`에 명시된 값을 재정의한다.

  |         Type: | string    |
  | ------------: | --------- |
  |      Default: | null      |
  | Valid Values: |           |
  |   Importance: | medium    |
  |  Update Mode: | read-only |

- #### zookeeper.ssl.client.enable

  주키퍼에 연결하는 클라이언트가 TLS를 사용하도록 설정한다. 여기에 값을 명시하면 시스템 프로퍼티 `zookeeper.client.secure`(이름이 다르다는 점 주의)를 통해 설정된 값을 재정의하게 된다. 둘 다 설정하지 않았다면 기본값으로 false를 사용한다. true일 땐 반드시 [`zookeeper.clientCnxnSocket`](#zookeeperclientcnxnsocket)을 설정해야 한다 (보통은 `org.apache.zookeeper.ClientCnxnSocketNetty`로). 함께 설정할만한 프로퍼티는 [`zookeeper.ssl.cipher.suites`](#zookeepersslciphersuites), [`zookeeper.ssl.crl.enable`](#zookeepersslcrlenable), [`zookeeper.ssl.enabled.protocols`](#zookeepersslenabledprotocols), [`zookeeper.ssl.endpoint.identification.algorithm`](#zookeepersslendpointidentificationalgorithm), [`zookeeper.ssl.keystore.location`](#zookeepersslkeystorelocation), [`zookeeper.ssl.keystore.password`](#zookeepersslkeystorepassword), [`zookeeper.ssl.keystore.type`](#zookeepersslkeystoretype), [`zookeeper.ssl.ocsp.enable`](#zookeepersslocspenable), [`zookeeper.ssl.protocol`](#zookeepersslprotocol), [`zookeeper.ssl.truststore.location`](#zookeeperssltruststorelocation), [`zookeeper.ssl.truststore.password`](#zookeeperssltruststorepassword), [`zookeeper.ssl.truststore.type`](#zookeeperssltruststoretype)이 있다.

  |         Type: | boolean   |
  | ------------: | --------- |
  |      Default: | false     |
  | Valid Values: |           |
  |   Importance: | medium    |
  |  Update Mode: | read-only |

- #### zookeeper.ssl.keystore.location

  클리이언트측 인증서를 통해 주키퍼에 TLS로 연결할 때 사용할 keystore의 위치. 시스템 프로퍼티 `zookeeper.ssl.keyStore.location`에 명시된 값을 재정의한다 (카멜케이스 주의).

  |         Type: | string    |
  | ------------: | --------- |
  |      Default: | null      |
  | Valid Values: |           |
  |   Importance: | medium    |
  |  Update Mode: | read-only |

- #### zookeeper.ssl.keystore.password

  클리이언트측 인증서를 통해 주키퍼에 TLS로 연결할 때 사용할 keystore 패스워드. 시스템 프로퍼티 `zookeeper.ssl.keyStore.password`에 명시된 값을 재정의한다 (카멜케이스 주의). 단, 주키퍼에선 keystore 패스워드와 다른 키 패스워드를 지원하지 않으므로, keystore 안에 있는 키 패스워드는 keystore 패스워드와 동일해야 한다. 그렇지 않으면 주키퍼로 연결할 수 없다.

  |         Type: | password  |
  | ------------: | --------- |
  |      Default: | null      |
  | Valid Values: |           |
  |   Importance: | medium    |
  |  Update Mode: | read-only |

- #### zookeeper.ssl.keystore.type

  클리이언트측 인증서를 통해 주키퍼에 TLS로 연결할 때 사용할 keystore 타입. 시스템 프로퍼티 `zookeeper.ssl.keyStore.type`에 명시된 값을 재정의한다 (카멜케이스 주의). 디폴트 값 `null`의 의미는 keystore의 filename 익스텐션으로 자동으로 타입을 감지한다는 뜻이다.

  |         Type: | string    |
  | ------------: | --------- |
  |      Default: | null      |
  | Valid Values: |           |
  |   Importance: | medium    |
  |  Update Mode: | read-only |

- #### zookeeper.ssl.truststore.location

  주키퍼에 TLS로 연결할 때 사용할 truststore 위치. 시스템 프로퍼티 `zookeeper.ssl.trustStore.location`에 명시된 값을 재정의한다 (카멜케이스 주의).

  |         Type: | string    |
  | ------------: | --------- |
  |      Default: | null      |
  | Valid Values: |           |
  |   Importance: | medium    |
  |  Update Mode: | read-only |

- #### zookeeper.ssl.truststore.password

  주키퍼에 TLS로 연결할 때 사용할 truststore 패스워드. 시스템 프로퍼티 `zookeeper.ssl.trustStore.password`에 명시된 값을 재정의한다 (카멜케이스 주의).

  |         Type: | password  |
  | ------------: | --------- |
  |      Default: | null      |
  | Valid Values: |           |
  |   Importance: | medium    |
  |  Update Mode: | read-only |

- #### zookeeper.ssl.truststore.type

  주키퍼에 TLS로 연결할 때 사용할 truststore 타입. 시스템 프로퍼티 `zookeeper.ssl.trustStore.type`에 명시된 값을 재정의한다 (카멜케이스 주의). 디폴트 값 `null`의 의미는 truststore의 filename 익스텐션으로 자동으로 타입을 감지한다는 뜻이다.

  |         Type: | string    |
  | ------------: | --------- |
  |      Default: | null      |
  | Valid Values: |           |
  |   Importance: | medium    |
  |  Update Mode: | read-only |

- #### alter.config.policy.class.name

  컨피그 변경 요청의 유효성을 검증할 정책 클래스. `org.apache.kafka.server.policy.AlterConfigPolicy` 인터페이스를 구현한 클래스를 사용해야 한다.

  |         Type: | class     |
  | ------------: | --------- |
  |      Default: | null      |
  | Valid Values: |           |
  |   Importance: | low       |
  |  Update Mode: | read-only |

- #### alter.log.dirs.replication.quota.window.num

  레플리카 로그 디렉토리 변경 할당량 측정을 위해 메모리에 보관할 샘플 수

  |         Type: | int       |
  | ------------: | --------- |
  |      Default: | 11        |
  | Valid Values: | [1,...]   |
  |   Importance: | low       |
  |  Update Mode: | read-only |

- #### alter.log.dirs.replication.quota.window.size.seconds

  레플리카 로그 디렉토리 변경 할당량을 계산할 각 샘플의 시간 범위

  |         Type: | int       |
  | ------------: | --------- |
  |      Default: | 1         |
  | Valid Values: | [1,...]   |
  |   Importance: | low       |
  |  Update Mode: | read-only |

- #### authorizer.class.name

  org.apache.kafka.server.authorizer.Authorizer 인터페이스를 구현한 클래스의 풀 네임(fully qualified name). 브로커는 이 인터페이스를 통해 권한을 부여한다. 이전에 인가에 사용했던 deprecated된 kafka.security.auth.Authorizer 트레잇을 구현한 authorizer도 지원한다.

  |         Type: | string    |
  | ------------: | --------- |
  |      Default: | ""        |
  | Valid Values: |           |
  |   Importance: | low       |
  |  Update Mode: | read-only |

- #### client.quota.callback.class

  ClientQuotaCallback 인터페이스를 구현한 클래스의 풀 네임(fully qualified name). 이 인터페이스를 통해 클라이언트 요청에 적용할 할당량 제한치를 결정한다. 기본적으론 주키퍼에 저장된 `<user, client-id>`나, `<user>` 또는 `<client-id>`의 할당량을 적용한다. 주어진 요청에 대해선 세션의 user principal과 요청의 client-id와 가장 구체적으로 매칭되는 할당량을 적용한다.

  |         Type: | class     |
  | ------------: | --------- |
  |      Default: | null      |
  | Valid Values: |           |
  |   Importance: | low       |
  |  Update Mode: | read-only |

- #### connection.failed.authentication.delay.ms

  인증 실패시 커넥션 종료 지연: 인증에 실패했을 때 커넥션 종료를 지연시킬 시간이다 (밀리세컨드). 커넥션 타임 아웃을 방지하려면 [connections.max.idle.ms](#connectionsmaxidlems)보다 작게 설정해야 한다.

  |         Type: | int       |
  | ------------: | --------- |
  |      Default: | 100       |
  | Valid Values: | [0,...]   |
  |   Importance: | low       |
  |  Update Mode: | read-only |

- #### controller.quota.window.num

  [컨트롤러 변동 할당량](https://cwiki.apache.org/confluence/display/KAFKA/KIP-599%3A+Throttle+Create+Topic%2C+Create+Partition+and+Delete+Topic+Operations) 측정을 위해 메모리에 보관할 샘플 수

  |         Type: | int       |
| ------------: | --------- |
  |      Default: | 11        |
  | Valid Values: | [1,...]   |
  |   Importance: | low       |
  |  Update Mode: | read-only |
  
- #### controller.quota.window.size.seconds

  [컨트롤러 변동 할당량](https://cwiki.apache.org/confluence/display/KAFKA/KIP-599%3A+Throttle+Create+Topic%2C+Create+Partition+and+Delete+Topic+Operations)을 계산할 각 샘플의 시간 범위

  |         Type: | int       |
  | ------------: | --------- |
  |      Default: | 1         |
  | Valid Values: | [1,...]   |
  |   Importance: | low       |
  |  Update Mode: | read-only |

- #### create.topic.policy.class.name

  유효성 검사에 사용할 토픽 생성 정책 클래스. `org.apache.kafka.server.policy.CreateTopicPolicy` 인터페이스를 구현한 클래스를 사용해야 한다.

  |         Type: | class     |
  | ------------: | --------- |
  |      Default: | null      |
  | Valid Values: |           |
  |   Importance: | low       |
  |  Update Mode: | read-only |

- #### delegation.token.expiry.check.interval.ms

  만료된 delegation 토큰을 삭제하기 위한 스캔 간격

  |         Type: | long             |
  | ------------: | ---------------- |
  |      Default: | 3600000 (1 hour) |
  | Valid Values: | [1,...]          |
  |   Importance: | low              |
  |  Update Mode: | read-only        |

- #### kafka.metrics.polling.interval.secs

  kafka.metrics.reporters 구현체에서 사용할 수 있는 메트릭 폴링 간격 (초 단위).

  |         Type: | int       |
  | ------------: | --------- |
  |      Default: | 10        |
  | Valid Values: | [1,...]   |
  |   Importance: | low       |
  |  Update Mode: | read-only |

- #### kafka.metrics.reporters

  Yammer 메트릭 커스텀 리포터로 사용할 클래스 리스트. 리포터는 `kafka.metrics.KafkaMetricsReporter` 트레잇을 구현해야 한다. 클라이언트에서 JMX 작업을 커스텀 리포터에 노출하고 싶으면, 커스텀 리포터는 `kafka.metrics.KafkaMetricsReporterMBean` 트레잇을 확장한 MBean 트레잇을 추가로 구현해서, 등록된 MBean이 표준 MBean 컨벤션을 따르도록 해야 한다.

  |         Type: | list      |
  | ------------: | --------- |
  |      Default: | ""        |
  | Valid Values: |           |
  |   Importance: | low       |
  |  Update Mode: | read-only |

- #### listener.security.protocol.map

  리스너 이름과 보안 프로토콜 간의 매핑. 둘 이상의 포트나 IP에서 사용하려면 각각을 같은 보안 프로토콜로 여러 번 정의해야 한다. 예를 들어, 내외부에서 모두 SSL이 필요한 경우에도 내부 트래픽과 외부 트래픽을 분리할 수 있다. 구체적으로 말하면, 리스너 이름을 INTERNAL, EXTERNAL로 정의하고, 이 프로퍼티는 `INTERNAL:SSL,EXTERNAL:SSL`로 정의할 수 있다. 보이는 것과 같이 키/값은 콜론으로, 맵 엔트리는 콤마로 구분한다. 각 리스너 이름은 맵에 한 번만 나와야 한다. 설정명에 정규화된 프리픽스(리스너 이름을 소문자로)를 추가하면, 각 리스너마다 다른 보안(SSL, SASL) 설정을 구성할 수 있다. 예를 들어, INTERNAL 리스너에 다른 keystore를 설정하려면, `listener.name.internal.ssl.keystore.location`을 설정명으로 사용할 수 있다. 리스너 이름을 가진 설정이 없다면 범용 설정으로 폴백한다 (ex. [`ssl.keystore.location`](#sslkeystorelocation)).

  |         Type: | string                                                       |
  | ------------: | ------------------------------------------------------------ |
  |      Default: | PLAINTEXT:PLAINTEXT,SSL:SSL,SASL_PLAINTEXT:SASL_PLAINTEXT,SASL_SSL:SASL_SSL |
  | Valid Values: |                                                              |
  |   Importance: | low                                                          |
  |  Update Mode: | per-broker                                                   |

- #### log.message.downconversion.enable

  이 설정은 컨슈밍 요청에서 필요에 따라 메세지 포맷을 하위 버전으로 변환해줄지 여부를 제어한다. `false`로 설정하면, 브로커는 컨슈머가 더 오래된 메세지 포맷을 원해도 다운 컨버젼을 해주지 않는다. 브로커는 이런 구버전 클라이언트의 컨슘 요청에는 `UNSUPPORTED_VERSION` 오류로 응답한다. 이 설정은 메세지를 팔로워로 복제할 때 필요할 수도 있는 메세지 포멧 변환에는 적용되지 않는다.

  |         Type: | boolean      |
  | ------------: | ------------ |
  |      Default: | true         |
  | Valid Values: |              |
  |   Importance: | low          |
  |  Update Mode: | cluster-wide |

- #### metric.reporters

  메트릭 리포터로 사용할 클래스 리스트. `org.apache.kafka.common.metrics.MetricsReporter` 인터페이스를 구현하면 새 메트릭을 생성을 통지 받을 클래스를 연결할 수 있다. JMX 통계를 등록하는 JmxReporter는 항상 추가된다.

  |         Type: | list         |
  | ------------: | ------------ |
  |      Default: | ""           |
  | Valid Values: |              |
  |   Importance: | low          |
  |  Update Mode: | cluster-wide |

- #### metrics.num.samples

  메트릭 계산을 위해 유지할 샘플 수.

  |         Type: | int       |
  | ------------: | --------- |
  |      Default: | 2         |
  | Valid Values: | [1,...]   |
  |   Importance: | low       |
  |  Update Mode: | read-only |

- #### metrics.recording.level

  메트릭을 기록할 제일 높은 레벨.

  |         Type: | string    |
  | ------------: | --------- |
  |      Default: | INFO      |
  | Valid Values: |           |
  |   Importance: | low       |
  |  Update Mode: | read-only |

- #### metrics.sample.window.ms

  메트릭 샘플을 계산할 시간 윈도우.

  |         Type: | long               |
  | ------------: | ------------------ |
  |      Default: | 30000 (30 seconds) |
  | Valid Values: | [1,...]            |
  |   Importance: | low                |
  |  Update Mode: | read-only          |

- #### password.encoder.cipher.algorithm

  설정한 패스워드를 동적으로 인코딩할 때 사용하는 암호화 알고리즘.

  |         Type: | string               |
  | ------------: | -------------------- |
  |      Default: | AES/CBC/PKCS5Padding |
  | Valid Values: |                      |
  |   Importance: | low                  |
  |  Update Mode: | read-only            |

- #### password.encoder.iterations

  설정한 패스워드를 동적으로 인코딩할 때 사용하는 반복 횟수.

  |         Type: | int        |
  | ------------: | ---------- |
  |      Default: | 4096       |
  | Valid Values: | [1024,...] |
  |   Importance: | low        |
  |  Update Mode: | read-only  |

- #### password.encoder.key.length

  설정한 패스워드를 동적으로 인코딩할 때 사용하는 키 길이.

  |         Type: | int       |
  | ------------: | --------- |
  |      Default: | 128       |
  | Valid Values: | [8,...]   |
  |   Importance: | low       |
  |  Update Mode: | read-only |

- #### password.encoder.keyfactory.algorithm

  설정한 패스워드를 동적으로 인코딩할 때 사용하는 SecretKeyFactory 알고리즘. 기본적으로는 가능하면 PBKDF2WithHmacSHA512를 사용하고, 그 외는 PBKDF2WithHmacSHA1을 사용한다.

  |         Type: | string    |
  | ------------: | --------- |
  |      Default: | null      |
  | Valid Values: |           |
  |   Importance: | low       |
  |  Update Mode: | read-only |

- #### quota.window.num

  클라이언트 할당량 측정을 위해 메모리에 보관할 샘플 수

  |         Type: | int       |
  | ------------: | --------- |
  |      Default: | 11        |
  | Valid Values: | [1,...]   |
  |   Importance: | low       |
  |  Update Mode: | read-only |

- #### quota.window.size.seconds

  클라이언트 할당량을 계산할 각 샘플의 시간 범위

  |         Type: | int       |
  | ------------: | --------- |
  |      Default: | 1         |
  | Valid Values: | [1,...]   |
  |   Importance: | low       |
  |  Update Mode: | read-only |

- #### replication.quota.window.num

  복제 할당량 측정을 위해 메모리에 보관할 샘플 수

  |         Type: | int       |
  | ------------: | --------- |
  |      Default: | 11        |
  | Valid Values: | [1,...]   |
  |   Importance: | low       |
  |  Update Mode: | read-only |

- #### replication.quota.window.size.seconds

  복제 할당량을 계산할 각 샘플의 시간 범위

  |         Type: | int       |
  | ------------: | --------- |
  |      Default: | 1         |
  | Valid Values: | [1,...]   |
  |   Importance: | low       |
  |  Update Mode: | read-only |

- #### security.providers

  보안 알고리즘을 구현한 프로바이더를 반환하는 설정 가능한 Creator 클래스 리스트. 이 클래스는 `org.apache.kafka.common.security.auth.SecurityProviderCreator` 인터페이스를 구현해야 한다.

  |         Type: | string    |
  | ------------: | --------- |
  |      Default: | null      |
  | Valid Values: |           |
  |   Importance: | low       |
  |  Update Mode: | read-only |

- #### ssl.endpoint.identification.algorithm

  서버 인증서를 사용해 서버 호스트명을 검증하는 엔드포인트 식별 알고리즘.

  |         Type: | string     |
  | ------------: | ---------- |
  |      Default: | https      |
  | Valid Values: |            |
  |   Importance: | low        |
  |  Update Mode: | per-broker |

- #### ssl.engine.factory.class

  SSLEngine 객체를 제공하는 org.apache.kafka.common.security.auth.SslEngineFactory 타입 클래스. 기본값은 org.apache.kafka.common.security.ssl.DefaultSslEngineFactory다.

  |         Type: | class      |
  | ------------: | ---------- |
  |      Default: | null       |
  | Valid Values: |            |
  |   Importance: | low        |
  |  Update Mode: | per-broker |

- #### ssl.principal.mapping.rules

  클라이언트 인증서의 DN(distinguished name)을 짧은 이름으로 매핑하기 위한 rule 리스트. 리스트에 있는 rule은 순서대로 평가하며, principal 이름과 일치하는 첫 번째 rule을 사용해 짧은 이름에 매핑한다. 뒤에 있는 rule은 무시한다. 기본적으로는 X.500 인증서의 DN이 principal이 된다. 포맷과 관려한 자세한 내용은 [보안 인가와 ACL](../security#74-authorization-and-acls)을 참고해라. 단, [`principal.builder.class`](#principalbuilderclass) 설정에 KafkaPrincipalBuilder 구현체를 지정했다면 이 설정은 무시한다.

  |         Type: | string    |
  | ------------: | --------- |
  |      Default: | DEFAULT   |
  | Valid Values: |           |
  |   Importance: | low       |
  |  Update Mode: | read-only |

- #### ssl.secure.random.implementation

  SSL 암호화 연산에 사용할 SecureRandom PRNG 구현체.

  |         Type: | string     |
  | ------------: | ---------- |
  |      Default: | null       |
  | Valid Values: |            |
  |   Importance: | low        |
  |  Update Mode: | per-broker |

- #### transaction.abort.timed.out.transaction.cleanup.interval.ms

  타임 아웃된 트랜잭션을 롤백할 주기

  |         Type: | int                |
  | ------------: | ------------------ |
  |      Default: | 10000 (10 seconds) |
  | Valid Values: | [1,...]            |
  |   Importance: | low                |
  |  Update Mode: | read-only          |

- #### transaction.remove.expired.transaction.cleanup.interval.ms

  [`transactional.id.expiration.ms`](#transactionalidexpirationms)가 지나 만료된 트랜잭션을 제거할 간격

  |         Type: | int              |
  | ------------: | ---------------- |
  |      Default: | 3600000 (1 hour) |
  | Valid Values: | [1,...]          |
  |   Importance: | low              |
  |  Update Mode: | read-only        |

- #### zookeeper.ssl.cipher.suites

  주키퍼 TLS 협상에서 사용할 활성화할 암호화 스위트를 지정한다 (csv). 시스템 프로퍼티 `zookeeper.ssl.ciphersuites`에 명시된 값을 재정의한다 ("ciphersuites"는 단어 하나라는 점에 주의). 디폴트 값 `null`의 의미는 사용 중인 자바 런타임에 의해 활성화할 암호와 스위트 리스트가 결정된는 뜻이다.  

  |         Type: | list      |
  | ------------: | --------- |
  |      Default: | null      |
  | Valid Values: |           |
  |   Importance: | low       |
  |  Update Mode: | read-only |

- #### zookeeper.ssl.crl.enable

  주키퍼 TLS 프로토콜에서 인증서 폐기 목록(Certificate Revocation List)을 활성화할지를 지정한다. 시스템 프로퍼티 `zookeeper.ssl.crl`에 명시된 값을 재정의한다 (이름이 더 짧게 끝난다는 점 주의).

  |         Type: | boolean   |
  | ------------: | --------- |
  |      Default: | false     |
  | Valid Values: |           |
  |   Importance: | low       |
  |  Update Mode: | read-only |

- #### zookeeper.ssl.enabled.protocols

  주키퍼 TLS 협상에서 활성화할 프로토콜들을 지정한다 (csv). 시스템 프로퍼티 `zookeeper.ssl.enabledProtocols`에 명시된 값을 재정의한다 (카멜 케이스 주의). 디폴트 값 `null`의 의미는 설정 프로퍼티 `zookeeper.ssl.protocol` 값이 활성화할 프로토콜이 된다는 뜻이다.

  |         Type: | list      |
  | ------------: | --------- |
  |      Default: | null      |
  | Valid Values: |           |
  |   Importance: | low       |
  |  Update Mode: | read-only |

- #### zookeeper.ssl.endpoint.identification.algorithm

  주키퍼 TLS 협상 프로세스에서 호스트명 검증을 활성화할지를 지정한다. "https"(대소문자 구분 없음)는 주키퍼 호스트명 검증을 활성화한다는 걸 의미하고, 공백 값을 명시하면 비활성화된다 (비활성화는 테스트 목적으로만 권장). 시스템 프로퍼티 `zookeeper.ssl.hostnameVerification`에 명시한 "true" 또는 "false" 값을 재정의한다 (이름과 값이 다르다는 점에 주의. true는 https를, false는 공백을 의미한다).

  |         Type: | string    |
  | ------------: | --------- |
  |      Default: | HTTPS     |
  | Valid Values: |           |
  |   Importance: | low       |
  |  Update Mode: | read-only |

- #### zookeeper.ssl.ocsp.enable

  주키퍼 TLS 프로토콜에서 온라인 인증서 상태 프로토콜(Online Certificate Status Protocol)을 활성화할지를 지정한다. 시스템 프로퍼티 `zookeeper.ssl.ocsp`에 명시된 값을 재정의한다 (이름이 더 짧게 끝난다는 점 주의).

  |         Type: | boolean   |
  | ------------: | --------- |
  |      Default: | false     |
  | Valid Values: |           |
  |   Importance: | low       |
  |  Update Mode: | read-only |

- #### zookeeper.ssl.protocol

  주키퍼 TLS 협상에서 활성화할 프로토콜을 지정한다. 시스템 프로퍼티 `zookeeper.ssl.protocol`에 명시된 값을 재정의한다.

  |         Type: | string    |
  | ------------: | --------- |
  |      Default: | TLSv1.2   |
  | Valid Values: |           |
  |   Importance: | low       |
  |  Update Mode: | read-only |

- #### zookeeper.sync.time.ms

  주키퍼 팔로워가 주키퍼 리더로부터 얼마나 떨어져 있을 수 있는지

  |         Type: | int              |
  | ------------: | ---------------- |
  |      Default: | 2000 (2 seconds) |
  | Valid Values: |                  |
  |   Importance: | low              |
  |  Update Mode: | read-only        |

브로커 설정에 대한 더 자세한 내용은 스칼라 클래스 `kafka.server.KafkaConfig`에서 확인할 수 있다.

### 3.1.1 Updating Broker Configs

카프카 1.1 버전부터 일부 브로커 설정은 브로커를 재시작하지 않고도 업데이트할 수 있다. 각 브로커 설정의 업데이트 모드는 [브로커 설정](#31-broker-configs)에 있는 `Update Mode` 컬럼을 참고해라.

- `read-only`: 업데이트하려면 브로커를 재시작해야 한다.
- `per-broker`: 각 브로커별로 동적으로 업데이트할 수 있다.
- `cluster-wide`:  동적으로 클러스터 전체의 디폴트 값으로 업데이트할 수 있다. 테스트를 위해 브로커별로도 업데이트해볼 수 있다.

현재 브로커 id 0에 있는 브로커 설정을 변경하려면 (예를 들어, 로그 클리너 스레드 수) :

```bash
> bin/kafka-configs.sh --bootstrap-server localhost:9092 \
  --entity-type brokers --entity-name 0 \
  --alter --add-config log.cleaner.threads=2
```

현재 브로커 id 0에 있는 다이나믹 브로커 설정을 조회하려면:

```bash
> bin/kafka-configs.sh --bootstrap-server localhost:9092 \
  --entity-type brokers --entity-name 0 --describe
```

재정의한 설정을 제거하고, 브로커 id 0에 정적으로 설정한 값이나 기본값으로 되돌리려면 (예를 들어, 로그 클리너 스레드 수) :

```bash
> bin/kafka-configs.sh --bootstrap-server localhost:9092 \
  --entity-type brokers --entity-name 0 \
  --alter --delete-config log.cleaner.threads
```

일부 설정에 클러스터 전체의 디폴트값을 설정하면, 설정값을 전체 클러스터에서 동일하게 유지할 수 있다. 클러스터 디폴트 업데이트는 클러스터에 있는 모든 브로커에 반영된다. 예를 들어, 모든 브로커의 로그 클리너 스레드를 업데이트하려면:

```bash
> bin/kafka-configs.sh --bootstrap-server localhost:9092 \
  --entity-type brokers --entity-default \
  --alter --add-config log.cleaner.threads=2
```

현재 설정된 클러스터 전체의 디폴트 다이나믹 설정을 조회하려면:

```bash
> bin/kafka-configs.sh --bootstrap-server localhost:9092 \
  --entity-type brokers --entity-default --describe
```

클러스터 수준에서 설정할 수 있는 모든 설정은 브로커별로도 설정할 수 있다 (예를 들어 테스트 용으로). 같은 설정 값을 여러 가지 레벨에서 정의하면, 다음과 같은 우선 순위가 적용된다:

- 주키퍼에 저장된 브로커별 다이나믹 설정
- 주키퍼에 저장된 클러스터 전체의 디폴트 다이나믹 설정
- `server.properties`에 있는 스태틱 설정
- 카프카 디폴트, [브로커 설정](#31-broker-configs) 참고

##### Updating Password Configs Dynamically

동적으로 업데이트한 패스워드 설정 값은 주키퍼에 저장하기 전에 암호화된다. 패스워드 설정의 다이나믹 업데이트를 활성화하려면, `server.properties`에 브로커 설정 [`password.encoder.secret`](#passwordencodersecret)을 설정해야 한다. 시크릿은 브로커마다 다를 수 있다.

패스워드 인코딩에 사용하는 시크릿은 브로커의 순차 재시작으로 교체할 수 있다. 암호를 인코딩하는데 사용했던, 현재 주키퍼에 있는 이전 시크릿은 스태틱 브로커 설정 [`password.encoder.old.secret`](#passwordencoderoldsecret)에 제공해야 하며, 새 시크릿은 [`password.encoder.secret`](#passwordencodersecret)에 제공해야 한다. 주키퍼에 저장돼 있는 모든 다이나믹 패스워드 설정은 브로커가 시작할 때 새 시크릿으로 다시 인코딩된다.

카프카 1.1.x에선, 패스워드 설정을 변경하는 게 아니더라도, `kafka-configs.sh`를 사용해 설정을 업데이트할 땐 모든 변경 요청에 동적으로 업데이트한 모든 패스워드 설정을 제공해야 한다. 이 제약은 이후 릴리즈에서 제거됐다.

##### Updating Password Configs in ZooKeeper Before Starting Brokers

Kafka 2.0.0부터 `kafka-configs.sh`를 사용하면 브로커를 부트스트랩하기 전에 주키퍼로 다이나믹 브로커 설정을 업데이트할 수 있다. 이렇게 하면 모든 패스워드 설정을 암호화된 형식으로 저장할 수 있으므로, `server.properties`에 명확한 패스워드가 없어도 된다. alter 커맨드에 패스워드 설정이 하나라도 있다면 반드시 브로커 설정 [`password.encoder.secret`](#passwordencodersecret)을 지정해야 한다. 다른 암호화 파라미터도 함께 지정할 수 있다. 패스워드 인코더 설정은 주키퍼에 유지되지 않는다. 예를 들어, 브로커 0에서 `INTERNAL` 리스너에 대한 SSL 키 패스워드를 저장하려면:

```bash
> bin/kafka-configs.sh --zookeeper localhost:2182 \
  --zk-tls-config-file zk_tls_config.properties \
  --entity-type brokers --entity-name 0 --alter \
  --add-config 'listener.name.internal.ssl.key.password=key-password,password.encoder.secret=secret,password.encoder.iterations=8192'
```

`listener.name.internal.ssl.key.password` 설정은 함께 제공한 인코더 설정을 통해 주키퍼에 암호화된 형태로 보관한다. 인코더 시크릿과 이터레이션은 주키퍼에 유지되지 않는다.

##### Updating SSL Keystore of an Existing Listener

인증서 손상 위험을 줄이기 위해 브로커에 유효 기간이 짧은 SSL keystore를 설정할 수도 있다. keystore는 브로커를 다시 시작하지 않고도 동적으로 업데이트할 수 있다. 설정명은 리스너 프리픽스 `listener.name.{listenerName.}`으로 시작해야 한다. 이렇게 해야 특정 리스너의 keystore 설정만 업데이트된다. 개별 브로커 수준에서 단일 alter 요청으로 업데이트할 수 있는 설정은 다음과 같다:

- [`ssl.keystore.type`](#sslkeystoretype)
- [`ssl.keystore.location`](#sslkeystorelocation)
- [`ssl.keystore.password`](#sslkeystorepassword)
- [`ssl.key.password`](#sslkeypassword)

keystore를 수정하려는 리스너가 브로커 간에 사용하는 리스너라면, 해당 리스너에 설정한 truststore가 새 keystore를 신뢰하는 경우에만 업데이트를 허용한다. 브로커는 그외 다른 리스너에선 keystore에 대한 신뢰 여부를 검증하지 않는다. 클라이언트 인증 실패를 방지하려면 이전 인증서를 서명한 같은 인증 기관에서 인증서를 서명받아야 한다.

##### Updating SSL Truststore of an Existing Listener

인증서를 추가하거나 제거할 때는, 브로커를 다시 시작하지 않고도 브로커 truststore를 동적으로 업데이트할 수 있다. 새 클라이언트 커넥션을 인증할 때는 업데이트된 truststore를 사용한다. 설정명은 리스너 프리픽스 `listener.name.{listenerName}.`으로 시작해야 한다. 이렇게 해야 특정 리스너의 truststore 설정만 업데이트된다. 개별 브로커 수준에서 단일 alter 요청으로 업데이트할 수 있는 설정은 다음과 같다:

- [`ssl.truststore.type`](#ssltruststoretype)
- [`ssl.truststore.location`](#ssltruststorelocation)
- [`ssl.truststore.password`](#ssltruststorepassword)

truststore를 수정하려는 리스너가 브로커 간에 사용하는 리스너라면, 새 truststore가 해당 리스너의 기존 keystore를 신뢰하는 경우에만 업데이트를 허용한다. 브로커는 그외 다른 리스너에선 업데이트 전에 신뢰 여부를 검증하지 않는다. 새 truststore에서 클라이언트 인증서 서명에 사용한 CA 인증서를 제거했다면 클라이언트 인증에 실패할 수 있다.

##### Updating Default Topic Configuration

브로커가 사용할 디폴트 토픽 설정 옵션은 브로커를 다시 시작하지 않아도 업데이트할 수 있다. 토픽별 설정으로 재정의하지 않아도 적용된다. 다음 설정들을 모든 브로커가 사용하는 클러스터 디폴트 레벨로 재정의할 수 있다:

- [`log.segment.bytes`](#logsegmentbytes)
- [`log.roll.ms`](#logrollms)
- [`log.roll.hours`](#logrollhours)
- [`log.roll.jitter.ms`](#logrolljitterms)
- [`log.roll.jitter.hours`](#logrolljitterhours)
- [`log.index.size.max.bytes`](#logindexsizemaxbytes)
- [`log.flush.interval.messages`](#logflushintervalmessages)
- [`log.flush.interval.ms`](#logflushintervalms)
- [`log.retention.bytes`](#logretentionbytes)
- [`log.retention.ms`](#logretentionms)
- [`log.retention.minutes`](#logretentionminutes)
- [`log.retention.hours`](#logretentionhours)
- [`log.index.interval.bytes`](#logindexintervalbytes)
- [`log.cleaner.delete.retention.ms`](#logcleanerdeleteretentionms)
- [`log.cleaner.min.compaction.lag.ms`](#logcleanermincompactionlagms)
- [`log.cleaner.max.compaction.lag.ms`](#logcleanermaxcompactionlagms)
- [`log.cleaner.min.cleanable.ratio`](#logcleanermincleanableratio)
- [`log.cleanup.policy`](#logcleanuppolicy)
- [`log.segment.delete.delay.ms`](#logsegmentdeletedelayms)
- [`unclean.leader.election.enable`](#uncleanleaderelectionenable)
- [`min.insync.replicas`](#mininsyncreplicas)
- [`message.max.bytes`](#messagemaxbytes)
- [`compression.type`](#compressiontype)
- [`log.preallocate`](#logpreallocate)
- [`log.message.timestamp.type`](#logmessagetimestamptype)
- [`log.message.timestamp.difference.max.ms`](#logmessagetimestampdifferencemaxms)

카프카 2.0.0부터는, [`unclean.leader.election.enable`](#uncleanleaderelectionenable) 설정을 동적으로 업데이트하면 컨트롤러에서 자동으로 unclean 리더 선출이 활성화된다. 카프카 1.1.x에선, [`unclean.leader.election.enable`](#uncleanleaderelectionenable)을 바꿔도 새 컨트롤러를 선출할 때만 적용된다. 컨트롤러 재선출은 다음 명령어를 실행하면 강제할 수 있다:

```bash
> bin/zookeeper-shell.sh localhost
rmr /controller
```

##### Updating Log Cleaner Configs

로그 클리너 설정은 모든 브로커가 사용하는 클러스터 디폴트 레벨에서 동적으로 업데이트할 수 있다. 변경 사항은 다음 회차의 로그 클리닝에 적용된다. 다음 설정들을 업데이트할 수 있다:

- [`log.cleaner.threads`](#logcleanerthreads)
- [`log.cleaner.io.max.bytes.per.second`](#logcleaneriomaxbytespersecond)
- [`log.cleaner.dedupe.buffer.size`](#logcleanerdedupebuffersize)
- [`log.cleaner.io.buffer.size`](#logcleaneriobuffersize)
- [`log.cleaner.io.buffer.load.factor`](#logcleaneriobufferloadfactor)
- [`log.cleaner.backoff.ms`](#logcleanerbackoffms)

##### Updating Thread Configs

브로커가 사용할 여러 가지 스레드 풀의 크기는 모든 브로커가 사용하는 클러스터 디폴트 레벨에서 동적으로 업데이트할 수 있다. 서비스 중단 없이 설정을 업데이트할 수 있도록 업데이트 범위는 `currentSize / 2` ~ `currentSize * 2`까지로 제한된다.

- [`num.network.threads`](#numnetworkthreads)
- [`num.io.threads`](#numiothreads)
- [`num.replica.fetchers`](#numreplicafetchers)
- [`num.recovery.threads.per.data.dir`](#numrecoverythreadsperdatadir)
- [`log.cleaner.threads`](#logcleanerthreads)
- [`background.threads`](#backgroundthreads)

##### Updating ConnectionQuota Configs

브로커가 IP/host에 최대로 허용하는 커넥션 수는 모든 브로커가 사용하는 클러스터 디폴트 레벨에서 동적으로 업데이트할 수 있다. 변경 사항은 새 커넥션을 만들 때 적용되며, 기존 커넥션 수도 함께 계산해서 최대치를 제한한다.

- [`max.connections.per.ip`](#maxconnectionsperip)
- [`max.connections.per.ip.overrides`](#maxconnectionsperipoverrides)

##### Adding and Removing Listeners

리스너는 동적으로 추가하거나 제거할 수 있다. 새 리스너를 추가할 땐, 리스너의 보안 설정은 리스너 프리픽스 `listener.name.{listenerName}.`을 붙인 설정을 통해 제공해야 한다. 새 리스너가 SASL을 사용한다면, JAAS 설정 프로퍼티 [`sasl.jaas.config`](#sasljaasconfig)에 listener, 메커니즘 프리픽스를 붙여서 JAAS 설정을 제공해야 한다. 자세한 내용은 [카프카 브로커의 JAAS 설정](../security#jaas-configuration-for-kafka-brokers)을 참고해라.

카프카 1.1.x에선 브로커 간 리스너는 동적으로 업데이트되지 않을 수도 있다. 브로커 간 리스너를 새 리스너로 업데이트하려면, 새 리스너는 모든 브로커에 브로커 재시작 없이 추가할 수 있을 거다. 그런 다음 [`inter.broker.listener.name`](#interbrokerlistenername)을 업데이트하려면 순차적으로 재시작해야 한다.

새 리스너의 모든 보안 설정 외에, 다음 설정도 개별 브로커 수준에서 동적으로 업데이트할 수 있다.

- [`listeners`](#listeners)
- [`advertised.listeners`](#advertisedlisteners)
- [`listener.security.protocol.map`](#listenersecurityprotocolmap)

브로커 간 통신에 사용하는 리스너는 반드시 스태틱 브로커 설정 [`inter.broker.listener.name`](#interbrokerlistenername)이나 [`security.inter.broker.protocol`](#securityinterbrokerprotocol)로 설정해야 한다.