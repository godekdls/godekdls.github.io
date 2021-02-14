---
title: Monitoring
category: Apache Kafka
order: 14
permalink: /Apache%20Kafka/monitoring/
description: 아파치 카프카 모니터링 메트릭
image: ./../../images/kafka/logo.png
lastmod: 2021-02-14T22:25:00+09:00
comments: true
originalRefName: 아파치 카프카
originalRefLink: https://kafka.apache.org/27/documentation.html#monitoring
---

### 목차

+ [Security Considerations for Remote Monitoring using JMX](#security-considerations-for-remote-monitoring-using-jmx)
+ [Common monitoring metrics for producer/consumer/connect/streams](#common-monitoring-metrics-for-producerconsumerconnectstreams)
+ [Common Per-broker metrics for producer/consumer/connect/streams](#common-per-broker-metrics-for-producerconsumerconnectstreams)
+ [Producer Monitoring](#producer-monitoring)
  + [Producer Sender Metrics](#producer-sender-metrics)
+ [Consumer Monitoring](#consumer-monitoring)
  + [Consumer Group Metrics](#consumer-group-metrics)
  + [Consumer Fetch Metrics](#consumer-fetch-metrics)
+ [Connect Monitoring](#connect-monitoring)
+ Streams Monitoring
  + Client Metrics
  + Thread Metrics
  + Task Metrics
  + Processor Node Metrics
  + State Store Metrics
  + RocksDB Metrics
  + Record Cache Metrics
+ [Others](#others)

---

## 6.7 Monitoring

카프카는 Yammer Metrics를 사용해 서버의 메트릭을 리포트한다. 자바 클라이언트는 내장 메트릭 레지스트리 Kafka Metrics를 사용해 클라이언트 어플리케이션의 전이 의존성을 최소화한다. 둘 모두 JMX를 통해 메트릭을 노출하며, 연결할 리포터를 설정해서 모니터링 시스템 지표를 후킹해갈 수 있다.

카프카의 rate 메트릭은 모두 `-total`로 끝나는 누적 카운트 메트릭을 가진다. 예를 들어 `records-consumed-rate`에는 `records-consumed-total`이란 메트릭이 있다.

jconsole을 실행하고 실행 중인 카프카 클라이언트나 서버에 연결시키면 사용 가능한 메트릭을 가장 쉽게 확인해볼 수 있다. jconsole을 사용하면 JMX로 수집한 모든 메트릭을 둘러볼 수 있다.

### Security Considerations for Remote Monitoring using JMX

기본적으로 아파치 카프카에선 원격 JMX를 비활성화한다. JMX를 통한 원격 모니터링은, CLI로 환경 변수 `JMX_PORT`를 설정한 뒤 프로세스를 시작하면 활성화되며, 프로그래밍 방식으로 원격 JMX를 활성화하려면, 표준 자바 시스템 프로퍼티를 사용하면 된다. 프로덕션 환경에서 원격 JMX를 활성화할 때는, 반드시 보안도 같이 활성화해서 권한이 없는 사용자가 브로커나 어플리케이션을 모니터링하거나 제어할 수 없도록 해야하며, 이를 실행하고 있는 플랫폼도 마찬가지다. 카프카에서는 기본적으로 JMX에 대한 인증은 비활성화돼 있으며, 프로덕션 환경을 배포할 땐, 환경 변수 `KAFKA_JMX_OPTS`를 설정하고 CLI 프로세스를 시작하거나, 적절한 자바 시스템 프로퍼티를 설정해서 보안 설정을 재정의해야 한다. JMX 보안에 대한 자세한 내용은 [JMX 기술을 사용한 모니터링과 관리](https://docs.oracle.com/javase/8/docs/technotes/guides/management/agent.html)를 참고해라.

우리는 다음 메트릭을 시각화하고 알림을 걸어두고 있다:

| DESCRIPTION                                                  | MBEAN NAME                                                   | NORMAL VALUE                                                 |
| :--- | :--- | :----------------------------------------------------------- |
| 메세지 유입 속도                                             | kafka.server:type=BrokerTopicMetrics,<br>name=MessagesInPerSec |                                                              |
| 초당 클라이언트에서 유입되는 바이트                          | kafka.server:type=BrokerTopicMetrics,<br>name=BytesInPerSec  |                                                              |
| 초당 다른 브로커에서 유입되는 바이트                         | kafka.server:type=BrokerTopicMetrics,<br>name=ReplicationBytesInPerSec |                                                              |
| 요청율                                                       | kafka.network:type=RequestMetrics,<br>name=RequestsPerSec,<br>request={Produce\|<br />FetchConsumer\|FetchFollower} |                                                              |
| 에러율                                                       | kafka.network:type=RequestMetrics,<br>name=ErrorsPerSec,<br>request=([-.\w]+),error=([-.\w]+) | 요청 타입별, 에러 코드별로 수집한 에러 응답 수. 응답 하나에 에러가 여러 개 있다면 모두 카운트한다. error=NONE은 응답이 성공했음을 가리킨다. |
| 요청 바이트 사이즈                                           | kafka.network:type=RequestMetrics,<br>name=RequestBytes,<br>request=([-.\w]+) | 요청 타입별 요청 크기.                                       |
| 임시 메모리 바이트 사이즈                                    | kafka.network:type=RequestMetrics,<br>name=TemporaryMemoryBytes,<br>request={Produce\|Fetch} | 메세지 포맷 변환과 압축 해제에 사용하는 임시 메모리.         |
| 메세지 변환 시간                                             | kafka.network:type=RequestMetrics,<br>name=MessageConversionsTimeMs,<br>request={Produce\|Fetch} | 메세지 포맷 변환에 소요된 시간 (밀리세컨드).               |
| 메세지 변환율                                                | kafka.server:type=BrokerTopicMetrics,<br>name={Produce\|Fetch<br />}MessageConversionsPerSec,<br>topic=([-.\w]+) | 메세지 포맷 변환이 필요한 레코드를 요청한 수                 |
| 요청 큐 사이즈                                               | kafka.network:type=RequestChannel,<br>name=RequestQueueSize  | 요청 큐의 크기.                                              |
| 초당 클라이언트로 보내는 바이트                           | kafka.server:type=BrokerTopicMetrics,<br>name=BytesOutPerSec |                                                              |
| 초당 다른 브로커로 보내는 바이트                            | kafka.server:type=BrokerTopicMetrics,<br>name=ReplicationBytesOutPerSec |                                                              |
| [컴팩트](../design#48-log-compaction) 토픽에 키를 지정하지 않아 메세지 유효성 검사에 실패한 비율 | kafka.server:type=BrokerTopicMetrics,<br>name=<br />NoKeyCompactedTopicRecordsPerSec |                                                              |
| magic 넘버가 유효하지 않아 메세지 유효성 검증에 실패한 비율  | kafka.server:type=BrokerTopicMetrics,<br>name=<br />InvalidMagicNumberRecordsPerSec |                                                              |
| crc 체크섬이 정확하지 않아 메세지 유효성 검증에 실패한 비율  | kafka.server:type=BrokerTopicMetrics,<br>name=<br />InvalidMessageCrcRecordsPerSec |                                                              |
| 배치 안에 있는 오프셋이나 시퀀스 번호가 연속되지 않아 메세지 유효성 검증에 실패한 비율 | kafka.server:type=BrokerTopicMetrics,<br>name=<br />InvalidOffsetOrSequenceRecordsPerSec |                                                              |
| 로그 플러시 비율과 시간                                      | kafka.log:type=LogFlushStats,<br>name=LogFlushRateAndTimeMs  |                                                              |
| 레플리카가 부족한 파티션 수 (재할당 중이 아닌 레플리카 수 - ISR 수 > 0) | kafka.server:type=ReplicaManager,<br>name=UnderReplicatedPartitions | 0                                                            |
| 최소 레플리카보다 적은 파티션 (\|ISR\| < min.insync.replicas) | kafka.server:type=ReplicaManager,<br>name=UnderMinIsrPartitionCount | 0                                                            |
| 최소 레플리카만큼 있는 파티션 (\|ISR\| = min.insync.replicas) | kafka.server:type=ReplicaManager,<br>name=AtMinIsrPartitionCount | 0                                                            |
| 오프라인 로그 디렉토리 수                                    | kafka.log:type=LogManager,<br>name=OfflineLogDirectoryCount  | 0                                                            |
| 브로커에 컨트롤러가 활성화돼 있는지                          | kafka.controller:type=KafkaController,<br>name=ActiveControllerCount | 클러스터에서 브로커 하나만 1을 가진다.                       |
| 리더 선출 비율                                               | kafka.controller:type=ControllerStats,<br>name=LeaderElectionRateAndTimeMs | 실패한 브로커가 있으면 0이 아니다.                           |
| Unclean 리더 선출 비율                                       | kafka.controller:type=ControllerStats,<br>name=UncleanLeaderElectionsPerSec | 0                                                            |
| 삭제가 펜딩되고 있는 토픽                                    | kafka.controller:type=KafkaController,<br>name=TopicsToDeleteCount |                                                              |
| 삭제가 펜딩되고 있는 레플리카                                | kafka.controller:type=KafkaController,<br>name=ReplicasToDeleteCount |                                                              |
| 일시적으로 삭제가 불가능해서 삭제가 펜딩되고 있는 토픽       | kafka.controller:type=KafkaController,<br>name=TopicsIneligibleToDeleteCount |                                                              |
| 일시적으로 삭제가 불가능해서 삭제가 펜딩되고 있는 레플리카   | kafka.controller:type=KafkaController,<br>name=ReplicasIneligibleToDeleteCount |                                                              |
| 파티션 수                                                    | kafka.server:type=ReplicaManager,<br>name=PartitionCount     | 보통은 브로커간에 균등하게 나눠져 있다.                      |
| 리더 레플리카 수                                             | kafka.server:type=ReplicaManager,<br>name=LeaderCount        | 보통은 브로커간에 균등하게 나눠져 있다.                      |
| ISR 감소율                                                   | kafka.server:type=ReplicaManager,<br>name=IsrShrinksPerSec   | 브로커가 다운되면 일부 파티션에 대한 ISR이 줄어든다. 다운됐던 브로커가 다시 살아나면, 레플리카가 완전히 따라잡았을 때 ISR이 증가한다. 다운된 경우 외에는 ISR 감소, 증가율 모두 0일 거다. |
| ISR 증가율                                                   | kafka.server:type=ReplicaManager,<br>name=IsrExpandsPerSec   | 위를 참고.                                                   |
| 팔로워와 리더 레플리카 사이 최대 메세지 랙                 | kafka.server:type=ReplicaFetcherManager,<br>name=MaxLag,clientId=Replica | 랙은 프로듀스 요청의 최대 배치 사이즈 비례한다.              |
| 팔로워 레플리카당 메세지 랙                                  | kafka.server:type=FetcherLagMetrics,<br>name=ConsumerLag,clientId=([-.\w]+),<br>topic=([-.\w]+),partition=([0-9]+) | 랙은 프로듀스 요청의 최대 배치 사이즈 비례한다.              |
| 프로듀서 purgatory에서 기다리고 있는 요청                         | kafka.server:type=<br>DelayedOperationPurgatory,<br>name=PurgatorySize,<br>delayedOperation=Produce | ack=-1을 사용하면 0이 아니다.                                |
| fetch purgatory에서 기다리고 있는 요청                            | kafka.server:type=<br>DelayedOperationPurgatory,<br>name=PurgatorySize,<br>delayedOperation=Fetch | 컨슈머의 fetch.wait.max.ms 설정에 따라 달라진다.             |
| 요청을 처리하는 데 걸린 전체 시간                            | kafka.network:type=RequestMetrics,<br>name=TotalTimeMs,request=<br>{Produce\|FetchConsumer\|FetchFollower} | 큐, 로컬, 원격, 응답 전송 시간으로 나뉜다.                   |
| 요청이 요청 큐에서 대기하는 시간                             | kafka.network:type=RequestMetrics,<br>name=RequestQueueTimeMs,<br>request={Produce\|FetchConsumer\|FetchFollower} |                                                              |
| 리더에서 요청을 처리하는 시간                                | kafka.network:type=RequestMetrics,<br>name=LocalTimeMs,<br>request={Produce\|FetchConsumer\|FetchFollower} |                                                              |
| 요청이 팔로워를 기다리는 시간                                | kafka.network:type=RequestMetrics,<br>name=RemoteTimeMs,<br>request={Produce\|FetchConsumer\|FetchFollower} | ack=-1이면, 프로듀스 요청에선 0이 아니다.                    |
| 요청이 응답 큐에서 대기하는 시간                             | kafka.network:type=RequestMetrics,<br>name=ResponseQueueTimeMs,<br>request={Produce\|FetchConsumer\|FetchFollower} |                                                              |
| 응답을 전송하는 시간                                         | kafka.network:type=RequestMetrics,<br>name=ResponseSendTimeMs,<br>request={Produce\|FetchConsumer\|FetchFollower} |                                                              |
| 컨슈머가 프로듀서보다 뒤처져있는 메세지 수. 브로커가 아닌 컨슈머가 발행한다. | kafka.consumer:type=<br>consumer-fetch-manager-metrics,<br>client-id={client-id}<br> Attribute: records-lag-max |                                                              |
| 네트워크 프로세스가 유휴 상태인 평균 시간                    | kafka.network:type=SocketServer,<br>name=NetworkProcessorAvgIdlePercent | 0~1 사이. 이상적으론 > 0.3                                   |
| 커넥션이 만료됐는데, 클라이언트가 재인증을 하지 않고, 다른 요청을 보내 프로세서에서 연결이 끊어진 커넥션 수 | kafka.server:type=socket-server-metrics,<br>listener=[SASL_PLAINTEXT\|SASL_SSL],<br>networkProcessor=<#>,<br>name=expired-connections-killed-count | 재인증을 활성화했다면 이상적인 값은 0이며, 이 리스너, 프로세서에 연결된 클라이언트 중엔 2.2.0 이전 버전은 없다는 뜻이다. |
| 커넥션이 만료됐는데, 클라이언트가 재인증을 하지 않고, 다른 요청을 보내 모든 프로세서에서 연결이 끊어진 전체 커넥션 수 | kafka.network:type=SocketServer,<br>name=ExpiredConnectionsKilledCount | 재인증을 활성화했다면 이상적인 값은 0이며, 이 브로커에 연결된 클라이언트 중엔 2.2.0 이전 버전은 없다는 뜻이다. |
| 요청 핸들러 스레드가 유휴 상태인 평균 시간                   | kafka.server:type=<br>KafkaRequestHandlerPool,name=<br>RequestHandlerAvgIdlePercent | 0~1 사이. 이상적으론 > 0.3                                   |
| (user, client-id)나, user 또는 client-id 당 대역폭 할당량 관련 지표 | kafka.server:type={Produce\|Fetch},<br>user=([-.\w]+),<br>client-id=([-.\w]+) | 두 가지 속성이 있다. throttle-time은 클라이언트가 스로틀링된 시간을 ms로 나타낸다. 이상적인 값은 0이다. byte-rate는 클라이언트의 데이터 프로듀스/컨슘 속도를 bytes/sec로 나타난다. (user, client-id) 할당량에선, user와 client-id를 모두 지정한다. 클라이언트에 client-id 단위로 할당량을 적용했다면, user는 지정하지 않는다. user 단위 할당량을 적용했다면 client-id를 지정하지 않는다. |
| (user, client-id)나, user 또는 client-id 당 요청 할당량 관련 지표 | kafka.server:type=Request,<br>user=([-.\w]+),<br>client-id=([-.\w]+) | 두 가지 속성이 있다. throttle-time은 클라이언트가 스로틀링된 시간을 ms로 나타낸다. 이상적인 값은 0이다. request-time은 브로커가 클라이언트 그룹의 요청을 처리하기 위해 네트워크와 I/O 스레드에서 소요한 시간의 백분율을 나타낸다. (user, client-id) 할당량에선, user와 client-id를 모두 지정한다. 클라이언트에 client-id 단위로 할당량을 적용했다면, user는 지정하지 않는다. user 단위 할당량을 적용했다면 client-id를 지정하지 않는다. |
| 스로틀링에서 벗어난 요청                                     | kafka.server:type=Request                                    | exempt-throttle-time은 스로틀링에서 벗어난 요청을 처리하기 위해 브로커 네트워크, I/O 스레드에서 소요한 시간의 백분율을 나타낸다. |
| 주키퍼 클라이언트 요청 지연 시간                             | kafka.server:type=ZooKeeperClientMetrics,<br>name=ZooKeeperRequestLatencyMs | 브로커가 주키퍼에 보낸 요청의 지연 시간 (밀리세컨드).        |
| 주키퍼 커넥션 상태                                           | kafka.server:type=SessionExpireListener,<br>name=SessionState | 주키퍼 세션의 연결 상태.<br />다음 중 하나일 수 있다:<br /> Disconnected\|SyncConnected<br />\|AuthFailed\|ConnectedReadOnly<br />\|SaslAuthenticated\|Expired. |
| 그룹 메타데이터를 로드하는데 걸린 최대 시간                  | kafka.server:type=<br>group-coordinator-metrics,<br>name=partition-load-time-max | 지난 30초 동안, 컨슈머 오프셋 파티션을 로드하면서 오프셋, 그룹 메타데이터를 로드하는데 걸린 최대 시간 (밀리세컨드). (로드 태스크가 스케줄링되길 기다리는데 소요한 시간도 포함) |
| 그룹 메다데이터를 로드하는데 걸린 평균 시간                  | kafka.server:type=<br>group-coordinator-metrics,<br>name=partition-load-time-avg | 지난 30초 동안, 컨슈머 오프셋 파티션을 로드하면서 오프셋, 그룹 메타데이터를 로드하는데 걸린 평균 시간 (밀리세컨드). (로드 태스크가 스케줄링되길 기다리는데 소요한 시간도 포함) |
| 트랜잭션 메타데이터를 로드하는데 걸린 최대 시간              | kafka.server:type=transaction-coordinator-metrics,<br>name=partition-load-time-max | 지난 30초 동안, 컨슈머 오프셋 파티션을 로드하면서 트랜잭션 메타데이터를 로드하는데 걸린 최대 시간 (밀리세컨드). (로드 태스크가 스케줄링되길 기다리는데 소요한 시간도 포함) |
| 트랜잭션 메타데이터를 로드하는데 걸린 평균 시간              | kafka.server:type=transaction-coordinator-metrics,<br>name=partition-load-time-avg | 지난 30초 동안, 컨슈머 오프셋 파티션을 로드하면서 트랜잭션 메타데이터를 로드하는데 걸린 평균 시간 (밀리세컨드). (로드 태스크가 스케줄링되길 기다리는데 소요한 시간도 포함) |
| 컨슈머 그룹 오프셋 카운트                                    | kafka.server:type=GroupMetadataManager,<br>name=NumOffsets   | 컨슈머 그룹의 커밋된 오프셋의 총 갯수                        |
| 컨슈머 그룹 카운트                                           | kafka.server:type=GroupMetadataManager,<br>name=NumGroups    | 컨슈머 그룹의 총 갯수                                        |
| 상태별 컨슈머 그룹 카운트                                    | kafka.server:type=GroupMetadataManager,<br>name=NumGroups[PreparingRebalance,<br>CompletingRebalance,Empty,Stable,Dead] | 상태별 컨슈머 그룹 수: PreparingRebalance, CompletingRebalance, <br />Empty, Stable, Dead |
| 재할당 중인 파티션 수                                        | kafka.server:type=ReplicaManager,<br>name=ReassigningPartitions | 브로커에서 재할당 중인 리더 파티션 수                        |
| 재할당 트래픽으로 나가고 있는 바이트 속도                    | kafka.server:type=BrokerTopicMetrics,<br>name=ReassignmentBytesOutPerSec |                                                              |
| 재할당 트래픽으로 유입중인 바이트 속도                       | kafka.server:type=BrokerTopicMetrics,<br>name=ReassignmentBytesInPerSec |                                                              |

### Common monitoring metrics for producer/consumer/connect/streams

다음 메트릭은 프로듀서/컨슈머/커넥터/스트림즈 인스턴스에서 사용할 수 있다. 전용 메트릭은 아래 섹션들을 참고해라.

| METRIC/ATTRIBUTE NAME                     | DESCRIPTION                                                  | MBEAN NAME                                                   |
| :---------------------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| connection-close-rate                     | 윈도우 내에서 닫힌 초당 커넥션 수.                           | kafka.[producer\|consumer\|connect]:type=[producer\|consumer\|connect]-metrics,client-id=([-.\w]+) |
| connection-close-total                    | 윈도우 내에서 닫힌 전체 커넥션.                              | kafka.[producer\|consumer\|connect]:type=[producer\|consumer\|connect]-metrics,client-id=([-.\w]+) |
| connection-creation-rate                  | 윈도우 내에서 새로 구축한 초당 커넥션 수.                    | kafka.[producer\|consumer\|connect]:type=[producer\|consumer\|connect]-metrics,client-id=([-.\w]+) |
| connection-creation-total                 | 윈도우 내에서 새로 구축한 전체 커넥션.                       | kafka.[producer\|consumer\|connect]:type=[producer\|consumer\|connect]-metrics,client-id=([-.\w]+) |
| network-io-rate                           | 모든 커넥션의 초당 평균 네트워크 작업(읽기/쓰기) 수.         | kafka.[producer\|consumer\|connect]:type=[producer\|consumer\|connect]-metrics,client-id=([-.\w]+) |
| network-io-total                          | 모든 커넥션의 네트워크 작업(읽기/쓰기) 총 갯수               | kafka.[producer\|consumer\|connect]:type=[producer\|consumer\|connect]-metrics,client-id=([-.\w]+) |
| outgoing-byte-rate                        | 모든 서버로 보내는 초당 평균 바이트 수.                      | kafka.[producer\|consumer\|connect]:type=[producer\|consumer\|connect]-metrics,client-id=([-.\w]+) |
| outgoing-byte-total                       | 모든 서버로 보내는 총 바이트 수.                             | kafka.[producer\|consumer\|connect]:type=[producer\|consumer\|connect]-metrics,client-id=([-.\w]+) |
| request-rate                              | 초당 전송한 평균 요청 수.                                    | kafka.[producer\|consumer\|connect]:type=[producer\|consumer\|connect]-metrics,client-id=([-.\w]+) |
| request-total                             | 전송한 요청의 총 갯수.                                       | kafka.[producer\|consumer\|connect]:type=[producer\|consumer\|connect]-metrics,client-id=([-.\w]+) |
| request-size-avg                          | 윈도우 내에 있는 모든 요청의 평균 크기.                      | kafka.[producer\|consumer\|connect]:type=[producer\|consumer\|connect]-metrics,client-id=([-.\w]+) |
| request-size-max                          | 윈도우 내에서 전송한 모든 요청의 최대 사이즈.                | kafka.[producer\|consumer\|connect]:type=[producer\|consumer\|connect]-metrics,client-id=([-.\w]+) |
| incoming-byte-rate                        | 모든 소켓에서 읽은 초당 바이트.                              | kafka.[producer\|consumer\|connect]:type=[producer\|consumer\|connect]-metrics,client-id=([-.\w]+) |
| incoming-byte-total                       | 모든 소켓에서 읽은 총 바이트.                                | kafka.[producer\|consumer\|connect]:type=[producer\|consumer\|connect]-metrics,client-id=([-.\w]+) |
| response-rate                             | 초당 수신한 응답.                                            | kafka.[producer\|consumer\|connect]:type=[producer\|consumer\|connect]-metrics,client-id=([-.\w]+) |
| response-total                            | 수신한 응답의 총 갯수.                                       | kafka.[producer\|consumer\|connect]:type=[producer\|consumer\|connect]-metrics,client-id=([-.\w]+) |
| select-rate                               | I/O 계층이 새로 수행할 I/O를 확인한 초당 횟수.               | kafka.[producer\|consumer\|connect]:type=[producer\|consumer\|connect]-metrics,client-id=([-.\w]+) |
| select-total                              | I/O 계층이 새로 수행할 I/O를 확인한 총 횟수.                 | kafka.[producer\|consumer\|connect]:type=[producer\|consumer\|connect]-metrics,client-id=([-.\w]+) |
| io-wait-time-ns-avg                       | I/O 스레드가 소켓이 읽기나 쓰기를 준비하길 기다리는데 소요한 평균 시간 (나노세컨드). | kafka.[producer\|consumer\|connect]:type=[producer\|consumer\|connect]-metrics,client-id=([-.\w]+) |
| io-wait-ratio                             | I/O 스레드가 대기하는데 소비한 시간 비율                     | kafka.[producer\|consumer\|connect]:type=[producer\|consumer\|connect]-metrics,client-id=([-.\w]+) |
| io-time-ns-avg                            | select 호출 당 I/O에 걸린 평균 시간 (나노세컨드).            | kafka.[producer\|consumer\|connect]:type=[producer\|consumer\|connect]-metrics,client-id=([-.\w]+) |
| io-ratio                                  | I/O 스레드가 I/O를 수행하는데 소비한 시간 비율.              | kafka.[producer\|consumer\|connect]:type=[producer\|consumer\|connect]-metrics,client-id=([-.\w]+) |
| connection-count                          | 현재 활성 커넥션 수.                                         | kafka.[producer\|consumer\|connect]:type=[producer\|consumer\|connect]-metrics,client-id=([-.\w]+) |
| successful-authentication-rate            | SASL나 SSL로 인증에 성공한 초당 커넥션 수.                   | kafka.[producer\|consumer\|connect]:type=[producer\|consumer\|connect]-metrics,client-id=([-.\w]+) |
| successful-authentication-total           | SASL나 SSL로 인증에 성공한 커넥션의 총 갯수.                 | kafka.[producer\|consumer\|connect]:type=[producer\|consumer\|connect]-metrics,client-id=([-.\w]+) |
| failed-authentication-rate                | 초당 인증에 실패한 커넥션 수.                                | kafka.[producer\|consumer\|connect]:type=[producer\|consumer\|connect]-metrics,client-id=([-.\w]+) |
| failed-authentication-total               | 인증에 실패한 커넥션의 총 갯수.                              | kafka.[producer\|consumer\|connect]:type=[producer\|consumer\|connect]-metrics,client-id=([-.\w]+) |
| successful-reauthentication-rate          | SASL로 재인증에 성공한 초당 커넥션 수.                       | kafka.[producer\|consumer\|connect]:type=[producer\|consumer\|connect]-metrics,client-id=([-.\w]+) |
| successful-reauthentication-total         | SASL로 재인증에 성공한 커넥션의 총 갯수.                     | kafka.[producer\|consumer\|connect]:type=[producer\|consumer\|connect]-metrics,client-id=([-.\w]+) |
| reauthentication-latency-max              | 재인증에서 발생한 최대 지연 시간 (ms).                       | kafka.[producer\|consumer\|connect]:type=[producer\|consumer\|connect]-metrics,client-id=([-.\w]+) |
| reauthentication-latency-avg              | 재인증에서 발생한 평균 지연 시간 (ms).                       | kafka.[producer\|consumer\|connect]:type=[producer\|consumer\|connect]-metrics,client-id=([-.\w]+) |
| failed-reauthentication-rate              | 초당 재인증에 실패한 커넥션 수.                              | kafka.[producer\|consumer\|connect]:type=[producer\|consumer\|connect]-metrics,client-id=([-.\w]+) |
| failed-reauthentication-total             | 재인증에 실패한 커넥션의 총 갯수.                            | kafka.[producer\|consumer\|connect]:type=[producer\|consumer\|connect]-metrics,client-id=([-.\w]+) |
| successful-authentication-no-reauth-total | 재인증을 지원하지 않는 2.2.0 이전 버전 SASL 클라이언트에서 인증에 성공한 총 커넥션 수. 계속 0이 아닐 수도 있다. | kafka.[producer\|consumer\|connect]:type=[producer\|consumer\|connect]-metrics,client-id=([-.\w]+) |

### Common Per-broker metrics for producer/consumer/connect/streams

다음 메트릭은 프로듀서/컨슈머/커넥터/스트림즈 인스턴스에서 사용할 수 있다. 전용 메트릭은 아래 섹션들을 참고해라.

| METRIC/ATTRIBUTE NAME | DESCRIPTION                                               | MBEAN NAME                                                   |
| :-------------------- | :-------------------------------------------------------- | :----------------------------------------------------------- |
| outgoing-byte-rate    | 노드 하나로 전송하는 초당 평균 바이트 수.                 | kafka.[producer\|consumer\|connect]:type=[consumer\|producer\|connect]-node-metrics,client-id=([-.\w]+),node-id=([0-9]+) |
| outgoing-byte-total   | 노드 하나로 보내는 총 바이트 수.                          | kafka.[producer\|consumer\|connect]:type=[consumer\|producer\|connect]-node-metrics,client-id=([-.\w]+),node-id=([0-9]+) |
| request-rate          | 초당 노드 하나로 전송한 평균 요청 수.                     | kafka.[producer\|consumer\|connect]:type=[consumer\|producer\|connect]-node-metrics,client-id=([-.\w]+),node-id=([0-9]+) |
| request-total         | 노드 하나로 전송한 요청의 총 갯수.                        | kafka.[producer\|consumer\|connect]:type=[consumer\|producer\|connect]-node-metrics,client-id=([-.\w]+),node-id=([0-9]+) |
| request-size-avg      | 윈도우 내에서 노드 하나로 전송한 모든 요청의 평균 크기.   | kafka.[producer\|consumer\|connect]:type=[consumer\|producer\|connect]-node-metrics,client-id=([-.\w]+),node-id=([0-9]+) |
| request-size-max      | 윈도우 내에서 노드 하나로 전송한 모든 요청의 최대 사이즈. | kafka.[producer\|consumer\|connect]:type=[consumer\|producer\|connect]-node-metrics,client-id=([-.\w]+),node-id=([0-9]+) |
| incoming-byte-rate    | 노드 하나에서 받은 초당 평균 바이트.                      | kafka.[producer\|consumer\|connect]:type=[consumer\|producer\|connect]-node-metrics,client-id=([-.\w]+),node-id=([0-9]+) |
| incoming-byte-total   | 노드 하나에서 받은 총 바이트.                             | kafka.[producer\|consumer\|connect]:type=[consumer\|producer\|connect]-node-metrics,client-id=([-.\w]+),node-id=([0-9]+) |
| request-latency-avg   | 노드의 평균 요청 지연시간 (ms).                           | kafka.[producer\|consumer\|connect]:type=[consumer\|producer\|connect]-node-metrics,client-id=([-.\w]+),node-id=([0-9]+) |
| request-latency-max   | 노드의 최대 요청 지연시간 (ms).                           | kafka.[producer\|consumer\|connect]:type=[consumer\|producer\|connect]-node-metrics,client-id=([-.\w]+),node-id=([0-9]+) |
| response-rate         | 초당 노드 하나에서 받은 응답.                             | kafka.[producer\|consumer\|connect]:type=[consumer\|producer\|connect]-node-metrics,client-id=([-.\w]+),node-id=([0-9]+) |
| response-total        | 노드 하나에서 받은 응답의 총 갯수.                        | kafka.[producer\|consumer\|connect]:type=[consumer\|producer\|connect]-node-metrics,client-id=([-.\w]+),node-id=([0-9]+) |

### Producer monitoring

프로듀서 인스턴스엔 다음과 같은 메트릭이 있다.

| METRIC/ATTRIBUTE NAME  | DESCRIPTION                                                  | MBEAN NAME                                               |
| :--------------------- | :----------------------------------------------------------- | :------------------------------------------------------- |
| waiting-threads        | 레코드가 버퍼 메모리 큐에 들어가길 기다리고 있는 블로킹된 사용자 스레드 수. | kafka.producer:type=producer-metrics,client-id=([-.\w]+) |
| buffer-total-bytes     | 클라이언트가 사용할 수 있는 버퍼 메모리 최대치 (현재 사용 중인지 아니와는 상관 없이). | kafka.producer:type=producer-metrics,client-id=([-.\w]+) |
| buffer-available-bytes | 사용 중이 아닌 버퍼 메모리의 총량 (할당되지 않았거나, free 리스트에 있는). | kafka.producer:type=producer-metrics,client-id=([-.\w]+) |
| bufferpool-wait-time   | 어펜더가 공간 할당을 기다리는 시간.                          | kafka.producer:type=producer-metrics,client-id=([-.\w]+) |

#### Producer Sender Metrics

##### kafka.producer:type=producer-metrics,client-id="{client-id}"

| ATTRIBUTE NAME            | DESCRIPTION                                                  |
| :------------------------ | :----------------------------------------------------------- |
| batch-size-avg            | 요청 당 파티션 당 전송한 평균 바이트 수.                     |
| batch-size-max            | 요청 당 파티션 당 전송한 최대 바이트 수.                     |
| batch-split-rate          | 초당 평균 배치 분할 수.                                      |
| batch-split-total         | 총 배치 분할 횟수.                                         |
| compression-rate-avg      | 압축 전후 대비 배치 크기의 평균 비율로 정의한, 레코드 배치의 평균 압축률. |
| metadata-age              | 현재 사용 중인 프로듀서 메타데이터의 수명 (초 단위).         |
| produce-throttle-time-avg | 브로커가 요청을 스로틀링한 평균 시간 (ms).                   |
| produce-throttle-time-max | 브로커가 요청을 스로틀링한 최대 시간 (ms).                   |
| record-error-rate         | 레코드 전송 중 오류가 발생한 초당 평균 횟수.                 |
| record-error-total        | 레코드 전송 중 오류가 발생한 총 횟수.                        |
| record-queue-time-avg     | 레코드 배치가 전송 버퍼에서 보낸 평균 시간 (ms).             |
| record-queue-time-max     | 레코드 배치가 전송 버퍼에서 보낸 최대 시간 (ms).             |
| record-retry-rate         | 레코드 전송을 재시도한 초당 평균 횟수.                       |
| record-retry-total        | 레코드 전송을 재시도한 총 횟수.                              |
| record-send-rate          | 초당 전송한 평균 레코드 수.                                  |
| record-send-total         | 전송한 레코드의 총 갯수.                                     |
| record-size-avg           | 평균 레코드 사이즈.                                          |
| record-size-max           | 레코드 최대 크기.                                            |
| records-per-request-avg   | 요청 당 평균 레코드 수.                                      |
| request-latency-avg       | 평균 요청 지연 시간 (ms).                                    |
| request-latency-max       | 최대 요청 지연 시간 (ms).                                    |
| requests-in-flight        | 응답을 기다리는, 현재 진행 중인 요청 수.                     |

##### kafka.producer:type=producer-topic-metrics,client-id="{client-id}",topic="{topic}"

| ATTRIBUTE NAME     | DESCRIPTION                                                  |
| :----------------- | :----------------------------------------------------------- |
| byte-rate          | 토픽에 전송한 초당 평균 바이트 수.                           |
| byte-total         | 토픽에 전송한 총 바이트 수.                                  |
| compression-rate   | 토픽의 압축 전후 대비 배치 크기의 평균 비율로 정의한, 레코드 배치의 평균 압축률. |
| record-error-rate  | 토픽 레코드 전송 중 오류가 발생한 초당 평균 횟수.            |
| record-error-total | 토픽 레코드 전송 중 오류가 발생한 총 횟수.                   |
| record-retry-rate  | 토픽 레코드 전송을 재시도한 초당 평균 횟수.                  |
| record-retry-total | 토픽 레코드 전송을 재시도한 총 횟수.                         |
| record-send-rate   | 초당 전송한 평균 토픽 레코드 수.                             |
| record-send-total  | 전송한 토픽 레코드의 총 갯수.                                |

### Consumer monitoring

컨슈머 인스턴스엔 다음과 같은 메트릭이 있다.

| METRIC/ATTRIBUTE NAME | DESCRIPTION                                                  | MBEAN NAME                                               |
| :-------------------- | :----------------------------------------------------------- | :------------------------------------------------------- |
| time-between-poll-avg | 평균 poll() 호출 간격.                                       | kafka.consumer:type=consumer-metrics,client-id=([-.\w]+) |
| time-between-poll-max | poll() 호출 사이 최대 지연.                                  | kafka.consumer:type=consumer-metrics,client-id=([-.\w]+) |
| last-poll-seconds-ago | 마지막으로 poll()을 호출하고 난 뒤 지난 시간 (초 단위).      | kafka.consumer:type=consumer-metrics,client-id=([-.\w]+) |
| poll-idle-ratio-avg   | 사용자 코드가 레코드를 처리하길 기다리는 상황과 상반되는, 컨슈머의 poll()이 유휴 상태인 평균 시간. | kafka.consumer:type=consumer-metrics,client-id=([-.\w]+) |

#### Consumer Group Metrics

| METRIC/ATTRIBUTE NAME           | DESCRIPTION                                                  | MBEAN NAME                                                   |
| :------------------------------ | :----------------------------------------------------------- | :----------------------------------------------------------- |
| commit-latency-avg              | 커밋 요청에 소요된 평균 시간.                                | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+) |
| commit-latency-max              | 커밋 요청에 소요된 최대 시간.                                | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+) |
| commit-rate                     | 초당 커밋을 호출한 횟수.                                     | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+) |
| commit-total                    | 커밋을 호출한 총 횟수.                                       | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+) |
| assigned-partitions             | 현재 이 컨슈머에 할당된 파티션 수.                           | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+) |
| heartbeat-response-time-max     | 하트비트 요청에 대한 응답을 받는데 걸린 최대 시간            | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+) |
| heartbeat-rate                  | 초당 평균 하트비트 수.                                       | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+) |
| heartbeat-total                 | 총 하트비트 수.                                              | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+) |
| join-time-avg                   | 그룹에 다시 참여하는 데 소요된 평균 시간.                    | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+) |
| join-time-max                   | 그룹에 다시 참여하는 데 소요된 최대 시간.                    | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+) |
| join-rate                       | 초 당 그룹 join 횟수.                                        | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+) |
| join-total                      | 총 그룹 join 횟수.                                           | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+) |
| sync-time-avg                   | 그룹 sync에 소요된 평균 시간.                                | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+) |
| sync-time-max                   | 그룹 sync에 소요한 최대 시간.                                | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+) |
| sync-rate                       | 초당 그룹 sync 횟수.                                         | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+) |
| sync-total                      | 총 그룹 sync 횟수.                                           | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+) |
| rebalance-latency-avg           | 그룹 리밸런스에 소요된 평균 시간.                            | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+) |
| rebalance-latency-max           | 그룹 리밸런스에 소요한 최대 시간.                            | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+) |
| rebalance-latency-total         | 지금까지 그룹 리밸런스에 소요된 총 시간.                     | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+) |
| rebalance-total                 | 참여한 그룹 리밸런스의 총 갯수.                              | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+) |
| rebalance-rate-per-hour         | 시간 당 참여한 그룹 리밸런스 수.                             | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+) |
| failed-rebalance-total          | 실패한 그룹 리밸런스의 총 갯수.                              | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+) |
| failed-rebalance-rate-per-hour  | 시간 당 실패한 그룹 리밸런스 이벤트 수.                      | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+) |
| last-rebalance-seconds-ago      | 마지막 리밸런스 이벤트 이후 지난 시간 (초 단위).             | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+) |
| last-heartbeat-seconds-ago      | 마지막 컨트롤러 하트비트 이후 지난 시간 (초 단위).           | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+) |
| partitions-revoked-latency-avg  | on-partitions-revoked 리밸런스 리스너 콜백에 소요된 평균 시간.  | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+) |
| partitions-revoked-latency-max  | on-partitions-revoked 리밸런스 리스너 콜백에 소요한 최대 시간. | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+) |
| partitions-assigned-latency-avg | on-partitions-assigned 리밸런스 리스너 콜백에 소요된 평균 시간. | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+) |
| partitions-assigned-latency-max | on-partitions-assigned 리밸런스 리스너 콜백에 소요한 최대 시간. | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+) |
| partitions-lost-latency-avg     | on-partitions-lost 리밸런스 리스너 콜백에 소요된 평균 시간.  | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+) |
| partitions-lost-latency-max     | on-partitions-lost 리밸런스 리스너 콜백에 소요한 최대 시간.  | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+) |

#### Consumer Fetch Metrics

##### kafka.consumer:type=consumer-fetch-manager-metrics,client-id="{client-id}"

| ATTRIBUTE NAME          | DESCRIPTION                                                  |
| :------------------------ | :----------------------------------------------------------- |
| bytes-consumed-rate     | 초당 컨슘한 평균 바이트 수. |
| bytes-consumed-total    | 컨슘한 총 바이트 수.                |
| fetch-latency-avg       | 페치 요청에 소요된 평균 시간.  |
| fetch-latency-max       | 페치 요청에 소요한 최대 시간.    |
| fetch-rate              | 초당 페치 요청 수.          |
| fetch-size-avg          | 요청 당 가져온 평균 바이트 수. |
| fetch-size-max          | 요청 당 가져온 최대 바이트 수. |
| fetch-throttle-time-avg | 평균 스로틀 시간 (ms).                 |
| fetch-throttle-time-max | 최대 스로틀 시간 (ms)           |
| fetch-total             | 페치 요청의 총 갯수.         |
| records-consumed-rate   | 초당 컨슘한 평균 레코드 수. |
| records-consumed-total  | 컨슘한 레코드의 총 갯수.           |
| records-lag-max         | 이 윈도우 내 모든 파티션에 대한 최대 랙 (레코드 수). |
| records-lead-min        | 이 윈도우 내 모든 파티션에 대한 최소 리드 (레코드 수). |
| records-per-request-avg | 각 요청 당 평균 레코드 수. |

##### kafka.consumer:type=consumer-fetch-manager-metrics,client-id="{client-id}",topic="{topic}"

| ATTRIBUTE NAME          | DESCRIPTION                                                  |
| :------------------------ | :----------------------------------------------------------- |
| bytes-consumed-rate     | 초당 토픽을 컨슘한 평균 바이트 수. |
| bytes-consumed-total    | 토픽을 컨슘한 총 바이트 수. |
| fetch-size-avg          | 요청 당 토픽에서 가져온 평균 바이트 수. |
| fetch-size-max          | 요청 당 토픽에서 가져온 최대 바이트 수. |
| records-consumed-rate   | 초당 컨슘한 평균 토픽 레코드 수. |
| records-consumed-total  | 컨슘한 토픽 레코드의 총 갯수. |
| records-per-request-avg | 각 요청 당 평균 토픽 레코드 수. |

##### kafka.consumer:type=consumer-fetch-manager-metrics,partition="{partition}",topic="{topic}",client-id="{client-id}"

| ATTRIBUTE NAME          | DESCRIPTION                                                  |
| :------------------------ | :----------------------------------------------------------- |
| preferred-read-replica  | 현재 읽고 있는 파티션의 레플리카. 리더에서 읽고 있다면 -1. |
| records-lag             | 파티션의 가장 최근 lag.             |
| records-lag-avg         | 파티션의 평균 lag.                    |
| records-lag-max         | 파티션의 최대 lag.                        |
| records-lead            | 파티션의 가장 최근 lead.                  |
| records-lead-avg        | 파티션의 평균 lead.                     |
| records-lead-min        | 파티션의 최소 lead.                       |

### Connect Monitoring

커넥트 워커 프로세스는 모든 프로듀서와 컨슈머 메트릭 뿐 아니라 커넥트 전용 메트릭도 가진다. 워커 프로세스 자체에 여러 가지 메트릭이 있으며, 각 커넥터와 태스크도 별도 메트릭을 가진다.

##### kafka.connect:type=connect-worker-metrics

| ATTRIBUTE NAME                       | DESCRIPTION                                                  |
| :------------------------ | :----------------------------------------------------------- |
| connector-count                      | 이 워커에서 실행하는 커넥터 수. |
| connector-startup-attempts-total     | 이 워커가 커넥터 기동을 시도한 총 횟수. |
| connector-startup-failure-percentage | 이 워커의 커넥터가 시작에 실패한 평균 백분율. |
| connector-startup-failure-total      | 커넥터 시작에 실패한 총 횟수. |
| connector-startup-success-percentage | 이 워커의 커넥터가 시작에 성공한 평균 백분율. |
| connector-startup-success-total      | 커넥터 시작에 성공한 총 횟수. |
| task-count                           | 이 워커에서 실행하는 태스크 수.     |
| task-startup-attempts-total          | 이 워커가 태스크 기동을 시도한 총횟수. |
| task-startup-failure-percentage      | 이 워커의 태스크가 시작에 실패한 평균 백분율. |
| task-startup-failure-total           | 태스크 시작에 실패한 총 횟수. |
| task-startup-success-percentage      | 이 워커의 태스크가 시작에 성공한 평균 백분율. |
| task-startup-success-total           | 태스크 시작에 성공한 총 횟수. |

##### kafka.connect:type=connect-worker-metrics,connector="{connector}"

| ATTRIBUTE NAME                       | DESCRIPTION                                                  |
| :------------------------ | :----------------------------------------------------------- |
| connector-destroyed-task-count       | 이 워커에 있는 커넥터의 삭제된 태스크 수. |
| connector-failed-task-count          | 이 워커에 있는 커넥터의 실패한 테스크 수. |
| connector-paused-task-count          | 이 워커에 있는 커넥터의 일시 정지된 태스크 수. |
| connector-running-task-count         | 이 워커에 있는 커넥터의 실행 중인 태스크 수. |
| connector-total-task-count           | 이 워커에 있는 커넥터의 태스크 수. |
| connector-unassigned-task-count      | 이 워커에 있는 커넥터의 할당되지 않은 태스크 수. |

##### kafka.connect:type=connect-worker-rebalance-metrics

| ATTRIBUTE NAME                       | DESCRIPTION                                                  |
| :------------------------ | :----------------------------------------------------------- |
| completed-rebalances-total           | 이 워커가 리밸런싱을 완료한 총 횟수. |
| connect-protocol                     | 이 클러스터에서 사용하는 커넥트 프로토콜. |
| epoch                                | 이 워커의 epoch 또는 generation number.       |
| leader-name                          | 그룹 리더 이름.                        |
| rebalance-avg-time-ms                | 이 워커가 리밸런싱에 소요한 평균 시간 (밀리세컨드). |
| rebalance-max-time-ms                | 이 워커가 리밸런싱에 소요한 최대 시간 (밀리세컨드). |
| rebalancing                          | 현재 이 워커가 리밸런싱 중인지 여부. |
| time-since-last-rebalance-ms         | 이 워커가 마지막으로 리밸런싱을 완료한 후 지난 시간 (밀리세컨드). |

##### kafka.connect:type=connector-metrics,connector="{connector}"

| ATTRIBUTE NAME                       | DESCRIPTION                                                  |
| :------------------------ | :----------------------------------------------------------- |
| connector-class                      | 커넥터 클래스 이름.                   |
| connector-type                       | 커넥터 타입. 'source', 'sink' 중 하나. |
| connector-version                    | 커넥터에서 보고한 커넥터 클래스 버전. |
| status                               | 커넥터의 상태. 'unassigned', 'running', 'paused', 'failed', 'destroyed' 중 하나. |

##### kafka.connect:type=connector-task-metrics,connector="{connector}",task="{task}"

| ATTRIBUTE NAME                       | DESCRIPTION                                                  |
| :------------------------ | :----------------------------------------------------------- |
| batch-size-avg                       | 이 커넥터에서 처리한 배치의 평균 크기. |
| batch-size-max                       | 이 커넥터에서 실행한 배치의 최대 크기. |
| offset-commit-avg-time-ms            | 이 태스크에서 오프셋을 커밋하는데 걸린 평균 시간 (밀리세컨드). |
| offset-commit-failure-percentage     | 이 태스크에서 오프셋 커밋에 실패한 평균 백분율. |
| offset-commit-max-time-ms            | 이 태스크에서 오프셋을 커밋하는데 걸린 최대 시간 (밀리세컨드). |
| offset-commit-success-percentage     | 이 태스크에서 오프셋 커밋에 성공한 평균 백분율. |
| pause-ratio                          | 이 태스크가 일시 중지 상태로 보낸 시간 비율. |
| running-ratio                        | 이 태스크가 실행 중 상태로 보낸 시간 비율. |
| status                               | 커넥터 태스크의 상태. 'unassigned', 'running', 'paused', 'failed', 'destroyed' 중 하나. |

##### kafka.connect:type=sink-task-metrics,connector="{connector}",task="{task}"

| ATTRIBUTE NAME                       | DESCRIPTION                                                  |
| :------------------------ | :----------------------------------------------------------- |
| offset-commit-completion-rate        | 오프셋 커밋을 성공적으로 완료한 초당 평균 횟수. |
| offset-commit-completion-total       | 오프셋 커밋을 성공적으로 완료한 총 횟수. |
| offset-commit-seq-no                 | 현재 오프셋 커밋의 시퀀스 번호. |
| offset-commit-skip-rate              | 오프셋 커밋 응답을 너무 늦게 받아 건너뛰거나 무시한 초당 평균 횟수. |
| offset-commit-skip-total             | 오프셋 커밋 응답을 너무 늦게 받아 건너뛰거나 무시한 총 횟수. |
| partition-count                      | 이 태스크에 할당된 토픽 파티션 수. 이 태스크는 현재 워커에 지정된 싱크 커넥터에 속한다. |
| put-batch-avg-time-ms                | 이 태스크에서 레코드 배치를 싱크에 넣는데 걸린 평균 시간. |
| put-batch-max-time-ms                | 이 태스크에서 레코드 배치를 싱크에 넣는데 걸린 최대 시간. |
| sink-record-active-count             | 카프카에서 읽어왔지만, 싱크 태스크에서 아직 완전히 커밋/플러시/승인하지 않은 레코드 수. |
| sink-record-active-count-avg         | 카프카에서 읽어왔지만, 싱크 태스크에서 아직 완전히 커밋/플러시/승인하지 않은 평균 레코드 수. |
| sink-record-active-count-max         | 카프카에서 읽어왔지만, 싱크 태스크에서 아직 완전히 커밋/플러시/승인하지 않은 최대 레코드 수. |
| sink-record-lag-max                  | 모든 토픽 파티션 중에서, 싱크 태스크가 컨슈머 위치보다 뒤쳐진 레코드 수가 가장 큰 최대 lag. |
| sink-record-read-rate                | 이 태스크가 카프카에서 읽어온 초당 평균 레코드 수. 이 레코드는 transformation을 적용하기 전이다. 이 태스크는 현재 워커에 지정된 싱크 커넥터에 속한다. |
| sink-record-read-total               | 마지막으로 태스크를 재시작한 이후부터 이 태스크가 카프카에서 읽은 총 레코드 수. 이 태스크는 현재 워커에 지정된 싱크 커넥터에 속한다. |
| sink-record-send-rate                | transformation을 거쳐 이 태스크로 send/put한 초당 평균 레코드 수. 이 태스크는 현재 워커에 지정된 싱크 커넥터에 속한다. 이 레코드는 transformation을 적용한 뒤며, transformation에서 제외시킨 레코드는 불포함한다. |
| sink-record-send-total               | 마지막으로 태스크를 재시작한 이후부터, transformation을 거쳐 이 태스크로 send/put한 총 레코드 수. 이 태스크는 현재 워커에 지정된 싱크 커넥터에 속한다. |

##### kafka.connect:type=source-task-metrics,connector="{connector}",task="{task}"

| ATTRIBUTE NAME                       | DESCRIPTION                                                  |
| :------------------------ | :----------------------------------------------------------- |
| poll-batch-avg-time-ms               | 이 태스크에서 소스 레코드 배치를 poll하는데 걸린 평균 시간 (밀리세컨드). |
| poll-batch-max-time-ms               | 이 태스크에서 소스 레코드 배치를 poll하는데 걸린 최대 시간 (밀리세컨드). |
| source-record-active-count           | 이 태스크에서 만들었지만 아직 카프카에 완전히 기록되진 않은 레코드 수. |
| source-record-active-count-avg       | 이 태스크에서 만들었지만 아직 카프카에 완전히 기록되진 않은 평균 레코드 수. |
| source-record-active-count-max       | 이 태스크에서 만들었지만 아직 카프카에 완전히 기록되진 않은 최대 레코드 수. |
| source-record-poll-rate              | 이 태스크가 produce/poll한 (transformation 전) 초당 평균 레코드 수. 이 태스크는 현재 워커에 지정된 소스 커넥터에 속한다. |
| source-record-poll-total             | 이 태스크가 produce/poll한 (transformation 전) 총 레코드 수. 이 태스크는 현재 워커에 지정된 소스 커넥터에 속한다. |
| source-record-write-rate             | 이 태스크에서 transformation을 거쳐 카프카에 기록한 초당 평균 레코드 수. 이 태스크는 현재 워커에 지정된 소스 커넥터에 속한다. 이 레코드는 transformation을 적용한 뒤며, transformation에서 제외시킨 레코드는 불포함한다. |
| source-record-write-total            | 마지막으로 태스크를 재시작한 이후부터, 이 태스크에서 transformation을 거쳐 카프카에 기록한 레코드 수. 이 태스크는 현재 워커에 지정된 소스 커넥터에 속한다. |

##### kafka.connect:type=task-error-metrics,connector="{connector}",task="{task}"

| ATTRIBUTE NAME                       | DESCRIPTION                                                  |
| :------------------------ | :----------------------------------------------------------- |
| deadletterqueue-produce-failures     | DLQ에 쓰기를 실패한 횟수. |
| deadletterqueue-produce-requests     | DQL에 쓰기를 시도한 횟수. |
| last-error-timestamp                 | 이 태스크에서 마지막으로 에러가 발생한 epoch 타임스탬프. |
| total-errors-logged                  | 로깅한 에러 수.               |
| total-record-errors                  | 이 태스크에서 에러가 발생한 레코드 수. |
| total-record-failures                | 이 태스크에서 처리에 실패한 레코드 수. |
| total-records-skipped                | 에러 때문에 스킵한 레코드 수. |
| total-retries                        | 작업을 재시도한 횟수.                 |


### Others

GC 시간과 관련 지표, 그리고 CPU 사용률, I/O 서비스 시간 등과 같은 다양한 서버 지표를 모니터링하길 권장한다. 클라이언트 측에서는 시간당 message/byte 비율과(전체 지표와 토픽별 지표), 요청 속도/크기/시간을, 컨슈머 측에선 모든 파티션에서 메세지의 최대 랙과, 최소 페치 요청 속도를 모니터링하길 권한다. 컨슈머가 계속해서 메세지 생성 속도를 따라가려면 최대 랙이 임계치보다 작아야하며, 최소 페치 속도는 0보다 커야 한다.