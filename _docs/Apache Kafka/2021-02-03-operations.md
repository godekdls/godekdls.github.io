---
title: Operations
category: Apache Kafka
order: 12
permalink: /Apache%20Kafka/operations/
description: 카프카 운영에 필요한 커맨드라인 명령어와, 주요 카프카 설정, 자바, OS, 파일시스템 튜닝, 주키퍼 정책
image: ./../../images/kafka/logo.png
lastmod: 2021-02-14T22:25:00+09:00
comments: true
priority: 0.7
originalRefName: 아파치 카프카
originalRefLink: https://kafka.apache.org/27/documentation.html#operations
---

<blockquote style="background-color: #fbebf3; border-color: #d63583; padding-top: 20px; padding-bottom: 20px;">
<p><a href="../geo-replication">Geo-Replication</a>과 <a href="../monitoring">모니터링</a> 챕터는 따로 분리했습니다. 원문에선 모두 하나의 챕터에서 다루고 있으니 참고하시길 바랍니다.</p>
</blockquote>

### 목차

- [6.1 Basic Kafka Operations](#61-basic-kafka-operations)
  + [Adding and removing topics](#adding-and-removing-topics)
  + [Modifying topics](#modifying-topics)
  + [Graceful shutdown](#graceful-shutdown)
  + [Balancing leadership](#balancing-leadership)
  + [Balancing Replicas Across Racks](#balancing-replicas-across-racks)
  + [Mirroring data between clusters & Geo-replication](#mirroring-data-between-clusters--geo-replication)
  + [Checking consumer position](#checking-consumer-position)
  + [Managing Consumer Groups](#managing-consumer-groups)
  + [Expanding your cluster](#expanding-your-cluster)
    * [Automatically migrating data to new machines](#automatically-migrating-data-to-new-machines)
    * [Custom partition assignment and migration](#custom-partition-assignment-and-migration)
  + [Decommissioning brokers](#decommissioning-brokers)
  + [Increasing replication factor](#increasing-replication-factor)
  + [Limiting Bandwidth Usage during Data Migration](#limiting-bandwidth-usage-during-data-migration)
    * [Safe usage of throttled replication](#safe-usage-of-throttled-replication)
  + [Setting quotas](#setting-quotas)
- [6.2 Datacenters](../geo-replication#62-datacenters)
- [6.3 Geo-Replication (Cross-Cluster Data Mirroring)](../geo-replication#63-geo-replication-cross-cluster-data-mirroring)
  + [Geo-Replication Overview](../geo-replication#geo-replication-overview)
  + [What Are Replication Flows](../geo-replication#what-are-replication-flows)
  + [Configuring Geo-Replication](../geo-replication#configuring-geo-replication)
    * [Configuration File Syntax](../geo-replication#configuration-file-syntax)
    * [Creating and Enabling Replication Flows](../geo-replication#creating-and-enabling-replication-flows)
    * [Configuring Replication Flows](../geo-replication#configuring-replication-flows)
    * [Securing Replication Flows](#securing-replication-flows)
    * [Custom Naming of Replicated Topics in Target Clusters](../geo-replication#custom-naming-of-replicated-topics-in-target-clusters)
    * [Preventing Configuration Conflicts](../geo-replication#preventing-configuration-conflicts)
    * [Best Practice: Consume from Remote, Produce to Local](../geo-replication#best-practice-consume-from-remote-produce-to-local)
    * [Example: Active/Passive High Availability Deployment](../geo-replication#example-activepassive-high-availability-deployment)
    * [Example: Active/Active High Availability Deployment](../geo-replication#example-activeactive-high-availability-deployment)
    * [Example: Multi-Cluster Geo-Replication](../geo-replication#example-multi-cluster-geo-replication)
  + [Starting Geo-Replication](../geo-replication#starting-geo-replication)
  + [Stopping Geo-Replication](../geo-replication#stopping-geo-replication)
  + [Applying Configuration Changes](../geo-replication#applying-configuration-changes)
  + [Monitoring Geo-Replication](../geo-replication#monitoring-geo-replication)
- [6.4 Kafka Configuration](#64-kafka-configuration)
  + [Important Client Configurations](#important-client-configurations)
  + [A Production Server Config](#a-production-server-config)
- [6.5 Java Version](#65-java-version)
- [6.6 Hardware and OS](#66-hardware-and-os)
  + [OS](#os)
  + [Disks and Filesystems](#disks-and-filesystem)
  + [Application vs. OS Flush Management](#application-vs-os-flush-management)
  + [Understanding Linux OS Flush Behavior](#understanding-linux-os-flush-behavior)
  + [Filesystem Selection](#filesystem-selection)
    * [General Filesystem Notes](#general-filesystem-notes)
    * [XFS Notes](#xfs-notes)
    * [EXT4 Notes](#ext4-notes)
- [6.7 Monitoring](../monitoring)
  + [Security Considerations for Remote Monitoring using JMX](../monitoring#security-considerations-for-remote-monitoring-using-jmx)
  + [Common monitoring metrics for producer/consumer/connect/streams](../monitoring#common-monitoring-metrics-for-producerconsumerconnectstreams)
  + [Common Per-broker metrics for producer/consumer/connect/streams](../monitoring#common-per-broker-metrics-for-producerconsumerconnectstreams)
  + [Producer Monitoring](../monitoring#producer-monitoring)
    * [Producer Sender Metrics](../monitoring#producer-sender-metrics)
  + [Consumer Monitoring](../monitoring#consumer-monitoring)
    * [Consumer Group Metrics](../monitoring#consumer-group-metrics)
    * [Consumer Fetch Metrics](../monitoring#consumer-fetch-metrics)
  + [Connect Monitoring](../monitoring#connect-monitoring)
  + Streams Monitoring
    * Client Metrics
    * Thread Metrics
    * Task Metrics
    * Processor Node Metrics
    * State Store Metrics
    * RocksDB Metrics
    * Record Cache Metrics
  + [Others](../monitoring#others)
- [6.8 ZooKeeper](#68-zookeeper)
  + [Stable Version](#stable-version)
  + [Operationalizing ZooKeeper](#operationalizing-zookeeper)

---

여기서는 링크드인에서 사용해본 경험을 바탕으로 카프카를 실제 프로덕션 시스템으로 실행하는 방법에 대해 설명한다. 알고 있는 다른 팁이 있다면 우리한테 보내주길 바란다.

---

## 6.1 Basic Kafka Operations

이번 섹션에선 카프카 클러스터에서 수행하게될 가장 일반적인 작업들을 리뷰한다. 이 섹션에서 리뷰하는 모든 툴은 카프카 배포판의 `bin/` 디렉토리에서 이용할 수 있으며, 모든 툴은 인자 없이 실행하면 가능한 모든 커맨드라인 옵션에 대한 세부 정보를 출력한다.

### Adding and removing topics

토픽은 수동으로 추가하거나, 존재하지 않는 토픽에 처음 데이터를 발행하는 시점에 자동으로 생성할 수 있다. 토픽을 자동으로 생성한다면, 자동 생성하는 토픽에 사용할 디폴트 [토픽 설정](../topic-configuration)을 조정하는 게 좋다.

토픽을 추가하고 수정할 땐 토픽 툴을 사용한다:

```bash
> bin/kafka-topics.sh --bootstrap-server broker_host:port \
  --create --topic my_topic_name \
  --partitions 20 --replication-factor 3 --config x=y
```

replication factor는 작성하는 모든 메세지를 복제할 서버 수를 제어한다. replication factor가 3이면, 최대 서버 2대까지는 실패해도 데이터에 접근할 수 있다. 데이터 컨슘을 중단하지 않고 시스템을 투명하게 회복할 수 있도록 replication factor는 2나 3으로 두는 게 좋다.

파티션 수는 토픽을 분할할 로그 수를 제어한다. 파티션 수에 따라 달라질 수 있는 게 몇 가지 있다. 먼저, 하나의 파티션은 전부 하나의 서버에 저장된다. 그러니까 파티션이 20개라면, 전체 데이터 셋은 (그리고 읽기/쓰기 로드는) 서버가 아무리 많아도 최대 20개의 서버에서만 처리된다 (레플리카는 계산하지 않았다). 마지막으로, 파티션 수에 따라 컨슈머가 최대로 수행할 수 있는 병렬 처리 정도가 달라진다. 이 내용은 [개념 섹션](../design#45-the-consumer)에서 자세히 다룬다.

분할된 각 파티션 로그는 카프카 로그 디렉토리 아래 자체 폴더에 저장된다. 이 폴더의 이름은 토픽명에 대쉬(-)와 파티션 id를 붙인 이름이다. 전형적인 폴더명은 255자를 넘어갈 수 없기 때문에 토픽명에도 길이 제한이 있다. 카프카에선 파티션 수가 100,000개를 넘지 않을 거라 가정한다. 따라서 토픽명은 249자를 초과할 수 없다. 이렇게하면 폴더 이름에 대쉬와 파티션 id를 위한 최대 다섯 자리 숫자를 넣을 공간을 확보할 수 있다.

커맨드라인에 추가한 설정은, 데이터를 보존해야 하는 기간같이 서버가 가지고 있는 디폴트 설정을 재정의한다. 전체 토픽별 설정은 [여기](../topic-configuration)에 정리해놨다.

### Modifying topics

같은 토픽 툴로 토픽의 설정이나 파티셔닝을 변경할 수 있다.

파티션을 추가하려면 다음을 실행하면 된다.

```bash
> bin/kafka-topics.sh --bootstrap-server broker_host:port \
  --alter --topic my_topic_name --partitions 40
```

파티션을 사용할 땐 어떤 의미를 부여해서 데이터를 분할하기도 하는데, 파티션을 추가해도 기존 데이터의 파티션은 변경되지 않는다는 점을 알아둬라. 그렇기 때문에 컨슈머가 파티션에 의존하고 있다면, 파티션을 추가하고나면 컨슈머 동작이 꼬일수도 있다. 즉, 데이터를 <span class="custom-blockquote">hash(key) % number_of_partitions</span>로 분할한다면, 파티션을 추가해서 데이터를 셔플링할 순 있지만, 어떻든간에 카프카는 데이터를 자동으로 재분배하지 않는다.

설정을 추가하려면:

```bash
> bin/kafka-configs.sh --bootstrap-server broker_host:port \
  --entity-type topics --entity-name my_topic_name \
  --alter --add-config x=y
```

설정을 제거하려면:

```bash
> bin/kafka-configs.sh --bootstrap-server broker_host:port \
  --entity-type topics --entity-name my_topic_name \
  --alter --delete-config x
```

마지막으로 토픽을 삭제하려면:

```bash
> bin/kafka-topics.sh --bootstrap-server broker_host:port --delete --topic my_topic_name
```

카프카는 현재로썬 토픽 파티션 수를 줄이는 기능은 지원하지 않는다.

토픽의 replication factor를 변경하는 방법은 [여기](#increasing-replication-factor)에서 확인할 수 있다.

### Graceful shutdown

카프카 클러스터는 브로커 종료나 실패를 자동으로 감지하고, 그 장비에 있던 파티션의 새 리더를 선출한다. 서버가 실패한 경우든, 유지 관리나 설정 변경을 위해 의도적으로 중단한 경우든 동일하다. 후자의 경우, 카프카는 서버를 그냥 죽이기보단, 좀 더 graceful하게 서버를 중지할 수 있는 메커니즘을 지원한다. 서버를 graceful하게 중지하면 두 가지 최적화를 이용할 수 있다:

1. 모든 로그를 디스크에 동기화하기 때문에 다시 시작할 때 로그를 복구할 필요가 없다 (로그 테일에 있는 모든 메세지에 대한 체크섬 검증 등). 로그 복구는 시간이 걸리는 작업이므로, 재시작을 더 빨리할 수 있다.
2. 종료하기 전에 이 서버가 리더인 파티션을 다른 레플리카로 마이그레이션한다. 이렇게하면 리더십 이전이 좀 더 빨라지고, 각 파티션을 사용할 수 없는 시간이 몇 밀리세컨드 정도로 최소화된다.

직접 kill 명령어를 실행할 때만 빼고는 서버가 중지될 때마다 로그 동기화가 일어나지만, 이렇게 통제된 리더십 마이그레이션에는 특별한 설정이 필요하다:

```properties
controlled.shutdown.enable=true
```

이렇게 통제된 종료는 브로커에서 호스팅하는 *모든* 파티션이 레플리카가 있을 때만 성공한다는 점에 주의해라 (즉, replication factor가 1보다 크면서, *동시에* 레플리카 중 최소 하나가 활성 상태여야 한다). 보통 마지막 레플리카를 종료하면 토픽 파티션을 사용할 수 없게 되므로 의미한 동작과 일맥상통할 거다.

### Balancing leadership

브로커가 중지되거나 크래시날 때마다, 이 브로커의 파티션 리더십은 다른 레플리카로 이전된다. 브로커가 다시 시작했을 땐, 이 브로커는 모든 파티션의 팔로워로써만 존재하며, 클라이언트 읽기/쓰기에는 사용되지 않는다.

카프카는 이런 불균형을 방지할 수 있도록 선호하는 레플리카(preferred replicas)란 개념을 가진다. 파티션의 레플리카 리스트가 1,5,9라면, 리스트 맨 앞에 있는 노드1을 노드5, 9보다 리더로 선호한다. 카프카 클러스터는 기본적으로 레플리카를 복구하면 리더십도 복원하려고 할 거다. 이 동작은 다음 프로퍼티로 설정한다:

```properties
auto.leader.rebalance.enable=true
```

false로도 설정할 수 있지만, 이렇게되면 복구한 레플리카에 대한 리더십은 다음 명령어를 실행해 수동으로 복원해야 한다:

```bash
> bin/kafka-preferred-replica-election.sh --bootstrap-server broker_host:port
```

### Balancing Replicas Across Racks

랙 인식 기능은 동일한 파티션의 레플리카를 여러 랙으로 분산시킨다. 이 기능은 카프카가 브로커가 실패했을 때 제공하는 보장을 랙 실패까지로 확장한다. 이렇게하면 데이터가 유실될만한 상황은 같은 랙에 있는 모든 브로커가 한 번에 다 실패하는 경우로 제한한다. 이 기능은 EC2의 가용 영역(availability zone)같은 다른 브로커 그룹에도 적용할 수 있다.

브로커가 특정 랙에 속한다는 것은 브로커 설정 프로퍼티로 지정할 수 있다:

```properties
broker.rack=my-rack-id
```

토픽을 [생성하거나](#adding-and-removing-topics), [수정하거나](#modifying-topics), 레플리카를 [재분배하면](#expanding-your-cluster), 랙 제약 조건에 따라 레플리카는 가능한 한 많은 랙에 걸쳐 저장된다 (파티션은 min(#racks, replication-factor) 만큼의 랙에 분산된다).

브로커에 레플리카를 할당할 때 사용하는 알고리즘은, 브로커가 랙에 분산되는 방식과는 상관없이, 브로커 당 리더 수가 일정하게 유지되도록 만든다. 이를 통해 처리량의 균형을 유지한다.

하지만 랙마다 할당된 브로커 수가 다르다면, 레플리카는 고르게 할당되지 않는다. 브로커 수가 상대적으로 적은 랙이 있다면 레플리카가 더 많이 할당될 거다. 그에 따라 스토리지를 더 사용하게 되고, 복제에 더 많은 리소스를 투입하게 된다. 따라서 랙당 브로커 수는 동일하게 구성하는 게 좋다.

### Mirroring data between clusters & Geo-replication

카프카 관리자는 개별 카프카 클러스터나, 데이터센터 또는 지리적 영역의 경계를 넘나드는 데이터 플로우을 정의할 수 있다. 자세한 내용은 [Geo-Replication](../geo-replication#63-geo-replication-cross-cluster-data-mirroring) 섹션을 참고해라.

### Checking consumer position

컨슈머의 위치를 확인해보면 간간이 유용할 거다. 카프카엔 컨슈머 그룹에 있는 모든 컨슈머의 위치와, 컨슈머가 로그 끝에서 얼마나 뒤처져 있는지 보여주는 툴이 있다. 이 툴을 *my-topic*이란 토픽을 컨슘밍하는 *my-group*이란 컨슈머 그룹에서 실행한다면:

```bash
> bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group my-group

TOPIC                          PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG        CONSUMER-ID                                       HOST                           CLIENT-ID
my-topic                       0          2               4               2          consumer-1-029af89c-873c-4751-a720-cefd41a669d6   /127.0.0.1                     consumer-1
my-topic                       1          2               3               1          consumer-1-029af89c-873c-4751-a720-cefd41a669d6   /127.0.0.1                     consumer-1
my-topic                       2          2               3               1          consumer-2-42c1abd4-e3b2-425d-a8bb-e1ea49b29bb2   /127.0.0.1                     consumer-2
```

### Managing Consumer Groups

ConsumerGroupCommand 툴을 사용하면, 컨슈머 그룹을 나열하고, 조회(describe)하고, 삭제할 수 있다. 컨슈머 그룹은 수동으로 삭제할 수도 있고, 해당 그룹에서 마지막으로 커밋한 오프셋이 만료되면 자동으로 삭제할 수도 있다. 수동 삭제는 활성 멤버가 없는 그룹에서만 동작한다. 예를 들어, 모든 토픽에 걸친 모든 컨슈머 그룹을 나열하려면:

```bash
> bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --list

test-consumer-group
```

오프셋을 보려면, 앞에서 언급했듯이, 다음과 같이 컨슈머 그룹을 "describe"한다:

```bash
> bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group my-group

TOPIC           PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG             CONSUMER-ID                                    HOST            CLIENT-ID
topic3          0          241019          395308          154289          consumer2-e76ea8c3-5d30-4299-9005-47eb41f3d3c4 /127.0.0.1      consumer2
topic2          1          520678          803288          282610          consumer2-e76ea8c3-5d30-4299-9005-47eb41f3d3c4 /127.0.0.1      consumer2
topic3          1          241018          398817          157799          consumer2-e76ea8c3-5d30-4299-9005-47eb41f3d3c4 /127.0.0.1      consumer2
topic1          0          854144          855809          1665            consumer1-3fc8d6f1-581a-4472-bdf3-3515b4aee8c1 /127.0.0.1      consumer1
topic2          0          460537          803290          342753          consumer1-3fc8d6f1-581a-4472-bdf3-3515b4aee8c1 /127.0.0.1      consumer1
topic3          2          243655          398812          155157          consumer4-117fe4d3-c6c1-4178-8ee9-eb4a3954bee0 /127.0.0.1      consumer4
```

컨슈머 그룹과 관련된 상세 정보를 조회할 때 사용할 수 있는 추가 "describe" 옵션은 매우 다양하다:

- \-\-members: 이 옵션은 컨슈머 그룹에 있는 모든 활성 멤버 리스트를 제공한다.

  ```bash
  > bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 \
    --describe --group my-group --members
  
  CONSUMER-ID                                    HOST            CLIENT-ID       #PARTITIONS
  consumer1-3fc8d6f1-581a-4472-bdf3-3515b4aee8c1 /127.0.0.1      consumer1       2
  consumer4-117fe4d3-c6c1-4178-8ee9-eb4a3954bee0 /127.0.0.1      consumer4       1
  consumer2-e76ea8c3-5d30-4299-9005-47eb41f3d3c4 /127.0.0.1      consumer2       3
  consumer3-ecea43e4-1f01-479f-8349-f9130b75d8ee /127.0.0.1      consumer3       0
  ```

- \-\-members \-\-verbose: 이 옵션은 위에 있는 "\-\-members" 옵션에서 보여주는 정보 외에도, 각 멤버에 할당된 파티션을 보여준다.

  ```bash
  > bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 \
    --describe --group my-group --members --verbose
  
  CONSUMER-ID                                    HOST            CLIENT-ID       #PARTITIONS     ASSIGNMENT
  consumer1-3fc8d6f1-581a-4472-bdf3-3515b4aee8c1 /127.0.0.1      consumer1       2               topic1(0), topic2(0)
  consumer4-117fe4d3-c6c1-4178-8ee9-eb4a3954bee0 /127.0.0.1      consumer4       1               topic3(2)
  consumer2-e76ea8c3-5d30-4299-9005-47eb41f3d3c4 /127.0.0.1      consumer2       3               topic2(1), topic3(0,1)
  consumer3-ecea43e4-1f01-479f-8349-f9130b75d8ee /127.0.0.1      consumer3       0               -
  ```

- \-\-offsets: 디폴트 describe 옵션으로, "\-\-describe" 옵션과 동일한 내용을 출력한다.

- \-\-state: 이 옵션은 유용한 그룹 레벨 정보를 제공한다.

  ```bash
  > bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 \
    --describe --group my-group --state
  
  COORDINATOR (ID)          ASSIGNMENT-STRATEGY       STATE                #MEMBERS
  localhost:9092 (0)        range                     Stable               4
  ```

하나 이상의 컨슈머 그룹을 수동으로 삭제하려면, "\-\-delete" 옵션을 사용하면 된다:

```bash
> bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 \
  --delete --group my-group --group my-other-group

Deletion of requested consumer groups ('my-group', 'my-other-group') was successful.
```

컨슈머 그룹의 오프셋을 리셋하려면, "\-\-reset-offsets" 옵션을 사용하면 된다. 이 옵션은 한 번에 컨슈머 그룹 하나씩 사용할 수 있다. \-\-all-topics 또는 \-\-topic으로 범위를 정의해야 한다. '\-\-from-file' 시나리오를 사용하는 게 아니라면 범위는 하나만 선택해야 한다. 더불어, 먼저 컨슈머 인스턴스가 비활성 상태인지부터 확인해야 한다. 자세한 내용은 [KIP-122](https://cwiki.apache.org/confluence/display/KAFKA/KIP-122%3A+Add+Reset+Consumer+Group+Offsets+tooling)를 참고해라.

오프셋 리셋은 세 가지 실행 옵션이 있다:

- (디폴트) 리셋할 오프셋을 출력해본다.
- \-\-execute : 실제 \-\-reset-offsets 프로세스를 실행한다.
- \-\-export : 결과를 CSV 포맷으로 export한다.

\-\-reset-offsets에선 시나리오도 선택해야 한다 (최소 하나는 선택해야 한다):

- \-\-to-datetime \<String: datetime\> : datetime 이후 오프셋으로 리셋한다. 포맷: 'YYYY-MM-DDTHH:mm:SS.sss'
- \-\-to-earliest : 오프셋을 맨 앞으로 리셋한다.
- \-\-to-latest : 오프셋을 맨 뒤로 리셋한다.
- \-\-shift-by \<Long: number-of-offsets\> : 현재 오프셋을 'n'만큼 이동시킨다. 여기서 'n'은 양수일 수도 있고 음수일 수도 있다.
- \-\-from-file : 오프셋을 CSV 파일에 정의된 값으로 리셋한다.
- \-\-to-current : 오프셋을 현재 오프셋으로 리셋한다.
- \-\-by-duration \<String: duration\> : 오프셋을 현재 타임스탬프의 일정 기간 전으로 재설정한다. 포맷: 'PnDTnHnMnS'
- \-\-to-offset : 오프셋을 특정 오프셋으로 리셋한다.

주의할 점은, 범위를 벗어난 오프셋은 유효한 마지막 오프셋으로 조정된다. 예를 들어, 오프셋의 끝이 10인데 15만큼 오프셋을 shift하도록 요청하면, 실제는 오프셋 10이 설정된다.

예를 들어, 컨슈머 그룹의 오프셋을 최신 오프셋으로 리셋하려면:

```bash
> bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 \
  --reset-offsets --group consumergroup1 --topic topic1 --to-latest

TOPIC                          PARTITION  NEW-OFFSET
topic1                         0          0
```

구버전 high-level 컨슈머를 사용 중이고 그룹 메타데이터를 주키퍼에 저장하고 있다면 (`offsets.storage=zookeeper`), `--bootstrap-server` 대신 `--zookeeper`를 넘겨라:

```bash
> bin/kafka-consumer-groups.sh --zookeeper localhost:2181 --list
```

### Expanding your cluster

카프카 클러스터에 서버를 추가하기란 정말 쉽다. 새 서버에 고유한 브로커 id를 할당하고, 카프카를 기동하기만 하면 된다. 단, 이렇게 추가한 새 서버에는 데이터 파티션이 자동으로 할당되진 않기 때문에, 파티션 이동시켜주지 않으면, 새 토픽이 생기기 전엔 어떤 작업도 수행하지 않는다. 따라서 클러스터에 새 장비를 추가할 땐 보통 기존 데이터 일부를 새 장비로 마이그레이션하는 게 좋다.

데이터 마이그레이션 프로세스는 시작만 수동으로 해주면, 완전히 자동으로 진행된다. 카프카 내부에선, 마이그레이션할 파티션에 새 서버를 팔로워로 추가하고, 이 파티션에 있는 데이터를 완전히 복제해가도록 한다. 새 서버가 파티션을 완전히 복제하고 in-sync 레플리카에 조인하면, 기존 복제본 중 하나가 해당 파티션 데이터를 삭제한다.

파티션을 다른 브로커로 이동시킬 땐 파티션 재할당 툴을 사용하면 된다. 모든 브로커에 데이터 로드와 파티션 크기를 균등하게 나누는 게 가장 이상적이다. 하지만 파티션 재할당 툴에는 카프카 클러스터의 데이터 분포를 자동으로 익히고, 부하를 균등하게 분산하게끔 파티션을 이동하는 그런 기능은 없다. 따라서 관리자가 이동시킬 토픽이나 파티션을 파악해야 한다.

파티션 재할당 툴은 세 가지 모드 중 하나로 실행할 수 있다:

- \-\-generate: 이 모드에선 토픽과 브로커 목록을 알려주면, 지정한 토픽의 모든 파티션을 새 브로커로 이동시킬 재할당 후보 플랜을 만든다. 이 옵션은 그저 주어진 토픽과 타겟 브로커 리스트로 파티션 재할당 플랜을 만드는 한 가지 간편한 방법일 뿐이다.
- \-\-execute: 이 모드에선 사용자가 제공한 재할당 플랜(\-\-reassignment-json-file 옵션으로)에 따라 파티션 재할당을 시작한다. 재할당 플랜은 관리자가 한땀한땀 만든 커스텀 플랜일 수도 있고, \-\-generate 옵션으로 만들 수도 있다.
- \-\-verify: 이 모드에선 마지막으로 실행한 \-\-execute에 나열한 모든 파티션의 재할당 상태를 확인해준다. 가능한 상태는 successfully completed, failed, in progress다.

#### Automatically migrating data to new machines

파티션 재할당 툴을 사용하면 현재 브로커 셋에 있는 토픽 일부를 새로 추가한 브로커로 이동시킬 수 있다. 새 브로커 셋을 추가하고 나면, 파티션을 하나씩 하나씩 이동시키는 것보단 전체 토픽을 이동시키는 게 더 쉽기 때문에, 보통 파티션 재할당 툴은 기존 클러스터를 확장할 때 많이 쓴다. 클러스터 확장을 위해 사용한다면, 새 브로커 셋으로 이동시킬 토픽과 새 브로커 리스트는 사용자가 제공해야 한다. 그러면 이 툴은 주어진 토픽 리스트의 모든 파티션을 새 브로커 셋에 고르게 분배한다. 이동 중에는 토픽의 replication factor는 일정하게 유지된다. 사실상 입력한 토픽 목록에 대한 모든 파티션 레플리카는 이전 브로커 셋에서 새로 추가한 브로커로 이동된다.

예를 들어서, 다음 예제에선 토픽 foo1, foo2의 모든 파티션을 새 브로커 셋 5,6으로 이동시킨다. 이동이 끝나면 토픽 foo1, foo2의 모든 파티션은 브로커 *5, 6에만* 존재하게 될 거다.

이 툴은 토픽 리스트 입력을 json 파일로 받기 때문에, 먼저 이동할 토픽을 식별해서 다음과 같은 json 파일을 만들어야 한다:

```bash
> cat topics-to-move.json

{"topics": [{"topic": "foo1"},
            {"topic": "foo2"}],
"version": 1
}
```

json 파일을 준비했으면, 파티션 재할당 툴을 사용해 재할당 후보 플랜을 만들어라:

```bash
> bin/kafka-reassign-partitions.sh --bootstrap-server localhost:9092 \
  --topics-to-move-json-file topics-to-move.json \
  --broker-list "5,6" --generate
  
Current partition replica assignment

{"version":1,
"partitions":[{"topic":"foo1","partition":2,"replicas":[1,2]},
              {"topic":"foo1","partition":0,"replicas":[3,4]},
              {"topic":"foo2","partition":2,"replicas":[1,2]},
              {"topic":"foo2","partition":0,"replicas":[3,4]},
              {"topic":"foo1","partition":1,"replicas":[2,3]},
              {"topic":"foo2","partition":1,"replicas":[2,3]}]
}

Proposed partition reassignment configuration

{"version":1,
"partitions":[{"topic":"foo1","partition":2,"replicas":[5,6]},
              {"topic":"foo1","partition":0,"replicas":[5,6]},
              {"topic":"foo2","partition":2,"replicas":[5,6]},
              {"topic":"foo2","partition":0,"replicas":[5,6]},
              {"topic":"foo1","partition":1,"replicas":[5,6]},
              {"topic":"foo2","partition":1,"replicas":[5,6]}]
}
```

이 툴은 토픽 foo1, foo2의 모든 파티션을 브로커 5, 6으로 이동할 할당 후보 플랜을 만든다. 단, 이 시점에선 파티션 이동은 시작되지 않았으며, 현재 할당 정보와 새 할당 후보를 제안하는 게 전부라는 점에 주의해라. 롤백할 경우에 대비해서 현재 할당 정보를 저장해둬야 한다. 새 할당 정보는 아래처럼 \-\-execute 옵션의 입력으로 사용하려면 json 파일에 저장해야 한다 (ex. expand-cluster-reassignment.json):

```bash
> bin/kafka-reassign-partitions.sh --bootstrap-server localhost:9092 \
  --reassignment-json-file expand-cluster-reassignment.json --execute

Current partition replica assignment

{"version":1,
"partitions":[{"topic":"foo1","partition":2,"replicas":[1,2]},
              {"topic":"foo1","partition":0,"replicas":[3,4]},
              {"topic":"foo2","partition":2,"replicas":[1,2]},
              {"topic":"foo2","partition":0,"replicas":[3,4]},
              {"topic":"foo1","partition":1,"replicas":[2,3]},
              {"topic":"foo2","partition":1,"replicas":[2,3]}]
}

Save this to use as the \-\-reassignment-json-file option during rollback
Successfully started reassignment of partitions
{"version":1,
"partitions":[{"topic":"foo1","partition":2,"replicas":[5,6]},
              {"topic":"foo1","partition":0,"replicas":[5,6]},
              {"topic":"foo2","partition":2,"replicas":[5,6]},
              {"topic":"foo2","partition":0,"replicas":[5,6]},
              {"topic":"foo1","partition":1,"replicas":[5,6]},
              {"topic":"foo2","partition":1,"replicas":[5,6]}]
}
```

마지막으로 \-\-verify 옵션을 사용하면 파티션 재할당 상태를 확인할 수 있다. \-\-verify 옵션에서도, \-\-execute 옵션에서 사용했던 것과 동일한 expand-cluster-reassignment.json을 사용해야 한다:

```bash
> bin/kafka-reassign-partitions.sh --bootstrap-server localhost:9092 \
  --reassignment-json-file expand-cluster-reassignment.json --verify

Status of partition reassignment:
Reassignment of partition [foo1,0] completed successfully
Reassignment of partition [foo1,1] is in progress
Reassignment of partition [foo1,2] is in progress
Reassignment of partition [foo2,0] completed successfully
Reassignment of partition [foo2,1] completed successfully
Reassignment of partition [foo2,2] completed successfully
```

#### Custom partition assignment and migration

파티션 재할당 툴을 사용할 땐 특정 브로커 셋으로 보낼 파티션 레플리카를 션별해서 이동시킬 수도 있다. 이때는 사용자가 재할당 플랜을 알고 있으며, 재할당 후보 플랜을 만드는 툴은 필요 없다고 가정하고, 사실상  \-\-generate 단계를 건너 뛰고 곧바로 \-\-execute 단계로 이동한다.

예를 들어서, 다음 예제에선 토픽 foo1의 파티션 0을 브로커 5, 6으로, 토픽 foo2의 파티션 1을 브로커 2,3으로 이동시킨다:

먼저 커스텀 재할당 플랜을 json 파일로 직접 만든다:

```bash
> cat custom-reassignment.json

{"version":1,
"partitions":[{"topic":"foo1","partition":0,"replicas":[5,6]},
              {"topic":"foo2","partition":1,"replicas":[2,3]}]
}
```

그다음은, 이 json파일을 가지고 \-\-execute 옵션을 실행해 재할당 프로세스를 시작한다:

```bash
> bin/kafka-reassign-partitions.sh --bootstrap-server localhost:9092 \
  --reassignment-json-file custom-reassignment.json --execute

Current partition replica assignment

{"version":1,
"partitions":[{"topic":"foo1","partition":0,"replicas":[1,2]},
              {"topic":"foo2","partition":1,"replicas":[3,4]}]
}

Save this to use as the --reassignment-json-file option during rollback
Successfully started reassignment of partitions
{"version":1,
"partitions":[{"topic":"foo1","partition":0,"replicas":[5,6]},
              {"topic":"foo2","partition":1,"replicas":[2,3]}]
}
```

\-\-verify 옵션을 사용하면 파티션 재할당 상태를 확인할 수 있다. \-\-verify 옵션에서도, \-\-execute 옵션에서 사용했던 것과 동일한 custom-reassignment.json을 사용해야 한다:

```bash
> bin/kafka-reassign-partitions.sh --bootstrap-server localhost:9092 \
  --reassignment-json-file custom-reassignment.json --verify

Status of partition reassignment:
Reassignment of partition [foo1,0] completed successfully
Reassignment of partition [foo2,1] completed successfully
```

### Decommissioning brokers

파티션 재할당 툴엔 아직 브로커 제거를 위한 재할당 플랜을 자동으로 생성하는 기능은 없다. 따라서 관리자가 제거할 브로커가 호스팅하는 모든 파티션의 레플리카를 나머지 브로커로 이동시킬 재할당 플랜을 수립해야 한다. 재할당 플랜을 세울 땐, 제거할 브로커의 모든 레플리카가 다른 브로커 하나로만 이동되지 않게 만들어야 하기 때문에, 비교적 지루한 작업일 수 있다. 향후에는 브로커 제거를 위한 툴을 추가해서 이 프로세스를 수월하게 진행할 수 있도록 지원할 계획이다.

### Increasing replication factor

기존 파티션의 replication factor를 늘리는 건 꽤 쉽다. 커스텀 재할당 json 파일에 추가 레플리카를 지정하고, \-\-execute 옵션에 이 파일을 사용하기만 하면, 지정한 파티션의 replication factor를 늘릴 수 있다.

예를 들어서, 다음 예제에선 토픽 foo의 파티션 0의 replication factor를 1에서 3으로 늘린다. replication factor를 늘리기 전엔, 파티션의 유일한 레플리카는 브로커 5에 있었다. replication factor를 늘리면서 생기는 레플리카는 브로커 6,7에 추가할 거다.

먼저 커스텀 재할당 플랜을 json 파일로 직접 만든다:

```bash
> cat increase-replication-factor.json

{"version":1,
"partitions":[{"topic":"foo","partition":0,"replicas":[5,6,7]}]}
```

그다음은, 이 json파일을 가지고 \-\-execute 옵션을 실행해 재할당 프로세스를 시작한다:

```bash
> bin/kafka-reassign-partitions.sh --bootstrap-server localhost:9092 \
  --reassignment-json-file increase-replication-factor.json --execute

Current partition replica assignment

{"version":1,
"partitions":[{"topic":"foo","partition":0,"replicas":[5]}]}

Save this to use as the --reassignment-json-file option during rollback
Successfully started reassignment of partitions
{"version":1,
"partitions":[{"topic":"foo","partition":0,"replicas":[5,6,7]}]}
```

\-\-verify 옵션을 사용하면 파티션 재할당 상태를 확인할 수 있다. \-\-verify 옵션에서도, \-\-execute 옵션에서 사용했던 것과 동일한 increase-replication-factor.json을 사용해야 한다:

```bash
> bin/kafka-reassign-partitions.sh --bootstrap-server localhost:9092 \
  --reassignment-json-file increase-replication-factor.json --verify

Status of partition reassignment:
Reassignment of partition [foo,0] completed successfully
```

replication factor가 늘었는지는 kafka-topics 툴로도 확인할 수 있다:

```bash
> bin/kafka-topics.sh --bootstrap-server localhost:9092 --topic foo --describe

Topic:foo	PartitionCount:1	ReplicationFactor:3	Configs:
  Topic: foo	Partition: 0	Leader: 5	Replicas: 5,6,7	Isr: 5,6,7
```

### Limiting Bandwidth Usage during Data Migration

카프카에선 장비 간 레플리카를 이동시키는 데 사용할 대역폭의 상한을 설정하는 식으로 복제 트래픽을 제한할 수 있다. 대역폭 제한은 클러스터 리밸런싱, 새 브로커 부트스트랩, 브로커 추가/제거 시에 유용하다. 이렇게 데이터 집약적인 작업이 사용자에게 미치는 영향을 제한하기 때문이다.

스로틀(throttle)을 작동시킬 수 있는 인터페이스는 두 가지가 있다. 가장 간단하면서도 가장 안전한 방법은, kafka-reassign-partitions.sh를 실행할 때 스로틀을 적용하는 거다. 하지만 kafka-configs.sh를 사용해도 스로틀 값을 직접 조회하고 변경할 수 있다.

예를 들어, 아래 명령어를 통해 리밸런스를 실행한다면, 파티션 이동에 50MB/s 이상은 사용하지 않는다.

```bash
$ bin/kafka-reassign-partitions.sh --bootstrap-server localhost:9092 \
  --execute --reassignment-json-file bigger-cluster.json --throttle 50000000
```

이 스크립트를 실행하면 스로틀이 작동하는 것을 확인할 수 있다:

```bash
The throttle limit was set to 50000000 B/s
Successfully started reassignment of partitions.
```

리밸런싱 중에 스로틀을 변경하려면, 예를 들어, 처리량을 늘려서 더 빨리 완료시키고 싶다면, 같은 reassignment-json-file을 넘겨 execute 명령을 다시 실행하면 된다:

```bash
$ bin/kafka-reassign-partitions.sh --bootstrap-server localhost:9092 \
 --execute --reassignment-json-file bigger-cluster.json --throttle 700000000

There is an existing assignment running.
The throttle limit was set to 700000000 B/s
```

리밸런싱이 끝나고나면 관리자는 \-\-verify 옵션을 사용해 리밸런스 상태를 확인할 수 있다. 리밸런스가 완료되면, 해당 스로틀은 \-\-verify 명령을 통해 제거된다. 리밸런스가 끝나면 관리자가 제때 \-\-verify 옵션 명령을 실행해서 스로틀을 제거해야 한다. 이렇게하지 않으면, 정기적인 복제 트래픽마저 제한될 수 있다.

\-\-verify 옵션을 실행했을 때 재할당이 모두 완료됐다면, 이 스크립트로 스로틀을 제거했음을 확인할 수 있다:

```bash
> bin/kafka-reassign-partitions.sh --bootstrap-server localhost:9092 \
  --verify --reassignment-json-file bigger-cluster.json

Status of partition reassignment:
Reassignment of partition [my-topic,1] completed successfully
Reassignment of partition [mytopic,0] completed successfully
Throttle was removed.
```

관리자는 kafka-configs.sh로도 할당된 설정을 검증할 수 있다. 스로틀링 프로세스는 두 가지 스로틀 설정 쌍으로 관리한다. 첫 번째는 스로틀 값 자체를 나타내는 설정이다. 이 설정은 브로커 레벨에서 동적인 프로퍼티로 구성한다:

```properties
leader.replication.throttled.rate
follower.replication.throttled.rate
```

다음은 스로틀링할 레플리카의 셋을 열거하는 설정 쌍이다:

```properties
leader.replication.throttled.replicas
follower.replication.throttled.replicas
```

이 설정은 토픽 단위로 설정한다.

kafka-reassign-partitions.sh를 실행하면 네 가지 설정 값 모두 자동으로 할당된다 (아래에서 설명한다).

스로틀 제한 설정을 조회하려면:

```bash
> bin/kafka-configs.sh --describe --bootstrap-server localhost:9092 --entity-type brokers

Configs for brokers '2' are leader.replication.throttled.rate=700000000,follower.replication.throttled.rate=700000000
Configs for brokers '1' are leader.replication.throttled.rate=700000000,follower.replication.throttled.rate=700000000
```

여기선 리더 측과 팔로워 측 모두에 적용된 복제 프로토콜의 스로틀을 출력한다. 기본적으로는, 양쪽 모두 동일한 스로틀 처리량을 할당받는다.

스로틀링할 레플리카 리스트를 조회하려면:

```bash
> bin/kafka-configs.sh --describe --bootstrap-server localhost:9092 --entity-type topics

Configs for topic 'my-topic' are leader.replication.throttled.replicas=1:102,0:101,
    follower.replication.throttled.replicas=1:101,0:102
```

여기서는 리더 스로틀이 브로커 102의 파티션 1과, 브로커 101의 파티션 0에 적용된 것을 확인할 수 있다. 마찬가지로 팔로워 스로틀은 브로커 101의 파티션 1과, 브로커 102의 파티션 0에 적용된다.

기본적으로 kafka-reassign-partitions.sh는 리밸런스를 진행하기 앞서 존재하는 모든 레플리카에 리더 스로틀을 적용한다. 이 리플리카에 중에는 리더도 있을 거다. 팔로워 스로틀은 실제 이동할 모든 목적지에 적용한다. 그러니까 만약 어떤 파티션의 레플리카가 브로커 101, 102에 있는데, 이 파티션을 102, 103으로 재할당한다면, 이 파티션에선 리더 스로틀은 101,102에 적용되고, 팔로워 스로틀은 103에만 적용된다.

필요하다면, kafka-configs.sh의 \-\-alter 스위치로 스로틀 설정을 수동으로 변경할 수도 있다.

#### Safe usage of throttled replication

복제 프로세스를 스로틀링할 땐 주의할 점이 몇 가지 있다. 특히:

*(1) 스로틀 제거:*

재할당이 끝나면 제때 스로틀을 제거해야 한다 (kafka-reassign-partitions.sh \-\-verify를 실행해서).

*(2) 진행 여부 확인:*

쓰기 요청 속도와 비교했을 때 쓰로틀을 너무 낮게 설정하면 복제가 진행되지 않을 수도 있다. 다음과 같은 상황에서 그렇다:

```
max(BytesInPerSec) > throttle
```

여기서 BytesInPerSec는 각 브로커마다 프로듀서의 쓰기 처리량을 모니터링하는 메트릭이다.

관리자는 이 메트릭을 통해 리밸런싱하는 동안 복제가 진행되고 있는지 모니터링할 수 있다:

```properties
kafka.server:type=FetcherLagMetrics,name=ConsumerLag,clientId=([-.\w]+),topic=([-.\w]+),partition=([0-9]+)
```

복제가 되고 있다면 랙은 지속적으로 줄어들어야 한다. 이 메트릭이 줄어들지 않으면 관리자는 위에서 설명한대로 스로틀 처리량을 늘려야 한다.

### Setting quotas

할당량 재정의와 기본값은 [여기](../design#49-quotas)에서 설명한대로, (user, client-id), user, client-id 레벨에 설정할 수 있다. 기본적으로는, 클라이언트는 무제한을 할당받는다. 각 (user, client-id), user, client-id 그룹에 대한 할당량은 커스텀할 수 있다.

(user=user1, client-id=clientA)에 대한 커스텀 할당량을 설정한다:

```bash
> bin/kafka-configs.sh  --bootstrap-server localhost:9092 --alter \
 --add-config 'producer_byte_rate=1024,consumer_byte_rate=2048,request_percentage=200' \
 --entity-type users --entity-name user1 --entity-type clients --entity-name clientA

Updated config for entity: user-principal 'user1', client-id 'clientA'.
```

user=user1에 대한 커스텀 할당량을 설정한다:

```bash
> bin/kafka-configs.sh  --bootstrap-server localhost:9092 --alter \
 --add-config 'producer_byte_rate=1024,consumer_byte_rate=2048,request_percentage=200' \
 --entity-type users --entity-name user1

Updated config for entity: user-principal 'user1'.
```

client-id=clientA에 대한 커스텀 할당량을 설정한다:

```bash
> bin/kafka-configs.sh  --bootstrap-server localhost:9092 --alter \
 --add-config 'producer_byte_rate=1024,consumer_byte_rate=2048,request_percentage=200' \
 --entity-type clients --entity-name clientA

Updated config for entity: client-id 'clientA'.
```

 *\-\-entity-name* 대신 *\-\-entity-default* 옵션을 지정하면 각 (user, client-id), user, client-id 그룹에 대한 디폴트 할당량을 설정할 수 있다.

user=userA에 대한 디폴트 client-id 할당량을 설정한다:

```bash
> bin/kafka-configs.sh  --bootstrap-server localhost:9092 --alter \
 --add-config 'producer_byte_rate=1024,consumer_byte_rate=2048,request_percentage=200' \
 --entity-type users --entity-name user1 --entity-type clients --entity-default

Updated config for entity: user-principal 'user1', default client-id.
```

user에 대한 디폴트 할당량을 설정한다:

```bash
> bin/kafka-configs.sh  --bootstrap-server localhost:9092 --alter \
 --add-config 'producer_byte_rate=1024,consumer_byte_rate=2048,request_percentage=200' \
 --entity-type users --entity-default

Updated config for entity: default user-principal.
```

client-id에 대한 디폴트 할당량을 설정한다:

```bash
> bin/kafka-configs.sh  --bootstrap-server localhost:9092 --alter \
 --add-config 'producer_byte_rate=1024,consumer_byte_rate=2048,request_percentage=200' \
 --entity-type clients --entity-default

Updated config for entity: default client-id.
```

지정한 (user, client-id)의 할당량을 조회하는 방법은 여기 있다:

```bash
> bin/kafka-configs.sh  --bootstrap-server localhost:9092 --describe \
 --entity-type users --entity-name user1 --entity-type clients --entity-name clientA

Configs for user-principal 'user1', client-id 'clientA' are producer_byte_rate=1024,consumer_byte_rate=2048,request_percentage=200
```

지정한 user의 할당량을 조회한다:

```bash
> bin/kafka-configs.sh  --bootstrap-server localhost:9092 --describe \
 --entity-type users --entity-name user1

Configs for user-principal 'user1' are producer_byte_rate=1024,consumer_byte_rate=2048,request_percentage=200
```

지정한 client-id의 할당량을 조회한다:

```bash
> bin/kafka-configs.sh  --bootstrap-server localhost:9092 --describe \
 --entity-type clients --entity-name clientA

Configs for client-id 'clientA' are producer_byte_rate=1024,consumer_byte_rate=2048,request_percentage=200
```

엔티티 이름을 지정하지 않은면, 지정된 타입의 모든 엔티티를 출력한다. 예를 들어, 다음은 모든 사용자를 조회한다:

```bash
> bin/kafka-configs.sh  --bootstrap-server localhost:9092 --describe \
 --entity-type users

Configs for user-principal 'user1' are producer_byte_rate=1024,consumer_byte_rate=2048,request_percentage=200
Configs for default user-principal are producer_byte_rate=1024,consumer_byte_rate=2048,request_percentage=200
```

유사하게 모든 (user, client)를 출력한다:

```bash
> bin/kafka-configs.sh  --bootstrap-server localhost:9092 --describe \
 --entity-type users --entity-type clients

Configs for user-principal 'user1', default client-id are producer_byte_rate=1024,consumer_byte_rate=2048,request_percentage=200
Configs for user-principal 'user1', client-id 'clientA' are producer_byte_rate=1024,consumer_byte_rate=2048,request_percentage=200
```

브로커 설정으로 모든 client-id에 적용되는 디폴트 할당량을 설정할 수 있다. 이 프로퍼티들은 주키퍼에 할당량 재정의나 기본값을 설정하지 않았을 때만 적용된다. 기본적으로 모든 client-id에 무제한을 할당한다. 다음은 컨슈머와 컨슈머 client-id당 기본 할당량을 10MB/sec로 설정한다.

```properties
quota.producer.default=10485760
quota.consumer.default=10485760
```

이 프로퍼티들은 더 이상 사용하지 않으며 (deprecated), 향후 릴리즈에선 제거될 수도 있다. kafka-configs.sh로 설정한 기본값이 이 프로퍼티보다 우선 순위가 높다.

---

## 6.4 Kafka Configuration

### Important Client Configurations

프로듀서에서 제일 중요한 설정은 다음과 같다:

- [acks](../producer-configuration#acks)
- [compression](../producer-configuration#compressiontype)
- [batch size](../producer-configuration#batchsize)

가장 중요한 컨슈머 설정은 fetch size다.

모든 설정은 설정 섹션에 정리돼 있다. ([프로듀서 설정](../producer-configuration) / [컨슈머 설정](../consumer-configuration))

### A Production Server Config

다음은 프로덕션 서버 설정 예시다:

```properties
# ZooKeeper
zookeeper.connect=[list of ZooKeeper servers]

# Log configuration
num.partitions=8
default.replication.factor=3
log.dir=[List of directories. Kafka should have its own dedicated disk(s) or SSD(s).]

# Other configurations
broker.id=[An integer. Start with 0 and increment by 1 for each new broker.]
listeners=[list of listeners]
auto.create.topics.enable=false
min.insync.replicas=2
queued.max.requests=[number of concurrent requests]
```

클라이언트 설정은 유스 케이스에 따라 크게 달라진다.

---

## 6.5 Java Version

자바 8과 자바 11을 지원한다. 자바 11은 TLS를 활성화한 경우 훨씬 더 나은 성능을 보여서 적극 권장하고 있다 (G1GC, CRC32C, 컴팩트 스트링, 스레드-로컬 핸드셰이크 등 다른 성능 개선점도 많다). 보안 측면에선, 무료로 사용할 수 있는 구버전에선 보안 취약점이 공개됐기 때문에, 최신 릴리즈 패치 버전을 권장한다. OpenJDK 기반 자바 구현체로 (Oracle JDK 포함) 카프카를 실행하기 위한 전형적인 인자는 다음과 같다:

```bash
-Xmx6g -Xms6g -XX:MetaspaceSize=96m -XX:+UseG1GC
-XX:MaxGCPauseMillis=20 -XX:InitiatingHeapOccupancyPercent=35 -XX:G1HeapRegionSize=16M
-XX:MinMetaspaceFreeRatio=50 -XX:MaxMetaspaceFreeRatio=80 -XX:+ExplicitGCInvokesConcurrent
```

참고로, 여기 나온 자바 인자를 사용하는, 링크드인의 가장 바쁜 클러스터 중 하나의 통계(피크 시)는 다음과 같다:

- 60 brokers
- 50k partitions (replication factor 2)
- 800k messages/sec in
- 300 MB/sec inbound, 1 GB/sec+ outbound

이 클러스터에 있는 모든 브로커에선, GC pause time의 90%는 약 21ms이며, 초당 young GC는 1개 미만이다.

---

## 6.6 Hardware and OS

우리는 24GB 메모리가 있는 듀얼 쿼드 코어 Intel Xeon 시스템을 사용하고 있다.

활성 reader와 writer를 버퍼링하려면 충분한 메모리가 필요하다. 필요한 메모리는, 30초 동안 버퍼링한다고 가정하면, write_throughput*30으로 계산해 어림잡아 추정할 수 있다.

디스크 처리량도 중요하다. 우리는 8x7200 rpm SATA 드라이브를 사용한다. 보통 성능상 병목은 디스크 처리량이며, 디스크는 많을수록 좋다. 플러시 동작을 구성하는 방법에 따라, 더 비싼 디스크를 쓰는 보람이 있을 수도 있고, 그렇지 않을 수도 있다 (강제 플러시를 자주 사용한다면, 더 높은 RPM SAS 드라이브가 더 좋을 수 있다).

### OS

카프카는 유닉스 시스템이라면 잘 실행될 것이며, 리눅스와 Solaris에서 테스트되었다.

Windows에서 실행했을 때는 몇 가지 이슈를 확인했다. 수정되면 좋겠지마는 현재로썬 Windows는 잘 지원되는 플랫폼은 아니다.

OS 레벨 튜닝이 많이 필요하진 않지만, 고려해볼만한 OS 레벨 설정이 세 가지 있다:

- 파일 디스크립터 제한 : 카프카는 로그 세그먼트와 활성 커넥션에 파일 디스크립터를 사용한다. 브로커 하나에서 많은 파티션을 호스팅한다면, 만들어진 커넥션 수에, 모든 로그 세그먼트를 추적하기 위한 최소 (파티션 수)*(파티션 크기/세그먼트 크기) 만큼이 추가로 필요하다는 점을 유념해라. 브로커 프로세스에 파일 디스크립터 최소 100000개를 허용하는 것부터 시작해보길 바란다. 참고: mmap() 함수는 close()로 삭제하지 않는 파일 디스크립터 fildes와 관련된 파일에 대한 별도 참조를 추가한다. 이 참조는 이 파일에 대한 매핑이 더 이상 없을 때 제거된다.
- 소켓 버퍼 최대 사이즈 : [여기에서 설명하는대로](http://www.psc.edu/index.php/networking/641-tcp-tune), 데이터센터 간에도 데이터를 고성능으로 전송하고 싶다면 늘릴 수 있다.
- 프로세스가 가질 수 있는 최대 메모리 맵 영역 (일명 vm.max_map_count): [리눅스 커널 문서를 참고해라](http://kernel.org/doc/Documentation/sysctl/vm.txt). 브로커가 가질 수 있는 최대 파티션 수를 산정할 땐, 이 OS 레벨 프로퍼티를 눈여겨 봐야 한다. 많은 리눅스 시스템에서 vm.max_map_count의 기본값은 약 65535다. 파티션마다 할당된 각 로그 세그먼트에는 index/timeindex 파일 쌍이 필요하며, 각 파일마다 맵 영역 1개를 사용한다. 다시 말해, 로그 세그먼트마다 맵 영역을 2개 사용한다. 따라서 파티션이 단일 로그 세그먼트를 호스팅한다면, 파티션마다 맵 영역이 최소 2개 필요하다. 이게 무슨 말이냐하면, 브로커 하나에 파티션 50000개를 생성하면, 100000개의 맵 영역이 할당되고, 디폴트 vm.max_map_count를 가진 시스템에선 OutOfMemoryError(Map failed)와 함께 크래시날 수 있다는 말이다. 파티션 당 로그 세그먼트 수는 세그먼트 크기, 부하 정도, 보존 정책에 따라 다르며, 보통은 하나보단 많다.

### Disks and Filesystem

어느정도 처리량을 보장하려면 드라이브를 여러 개 사용하는 게 좋으며, 지연 시간을 보장하려면 카프카 데이터에 사용하는 드라이브를 다른 어플리케이션 로그나 기타 OS 파일 시스템 활동에 공유하지 않는 게 좋다. 드라이브를 함께 묶어 단일 볼륨으로 RAID를 구성하거나, 포맷하고 별도로 자체 디렉토리를 마운트할 수도 있다. 카프카는 복제를 지원하기 때문에, RAID에서 제공하는 이중화를 어플리케이션 레벨에서도 제공할 수 있다. 드라이브 구성에 따라 몇 가지 장단점이 있다.

데이터 디렉토리를 여러 개 구성하면, 데이터 디렉토리에 파티션을 라운드 로빈으로 할당한다. 파티션 하나에 있는 모든 데이터는 전부 디렉토리 하나에 기록된다. 데이터가 파티션에 고르게 퍼져있지 않다면, 디스크간에도 로드 불균형이 발생할 수 있다.

RAID는 더 낮은 수준에서 로드의 균형을 맞추기 때문에, 디스크 간의 로드 균형을 더 잘 조정할 수 있다 (항상 그런 건 아니지만). RAID의 주요 단점은 일반적으로 쓰기 처리량이 크게 떨어지고, 가용 디스크 공간이 줄어든다는 거다.

RAID를 썼을 때 좋아질만한 점 중 하나는 디스크 실패를 허용하는 능력이다. 하지만 우리 경험에 따르면, RAID 어레이 재구성은 사실상 서버를 비활성할 정도로 I/O 집약적이어서, 실질적인 가용성이 그렇게까지 개선되진 않는다.

### Application vs. OS Flush Management

카프카는 언제나 모든 데이터를 파일 시스템에 즉시 기록하며, 플러시를 사용해 데이터를 OS 캐시에서 디스크로 강제할 시점을 제어하는 플러시 정책을 설정할 수 있다. 이 플러시 정책으로 일정 기간이 지나거나 메세지를 특정 수만큼 기록한 다음 강제로 데이터를 디스크에 저장하도록 제어한다. 이 설정에는 여러 가지 옵션이 있다.

어쨌거나 카프카는 데이터가 플러시됐음을 알 수 있으려면 언젠간 fsync를 호출해야 한다. 카프카는 fsync'd로 알려지지 않은 로그 세그먼트를 복구할 땐 CRC를 확인해서 각 메세지의 무결성을 확인하고, 기동 시 실행되는 복구 프로세스에서, 함께 필요한 오프셋 인덱스 파일을 다시 빌드한다.

카프카가 제공하는 내구성에선 데이터를 디스크에 동기화할 필요가 없다. 실패한 노드는 항상 레플리카로 복구하기 때문이다.

어플리케이션 fsync는 완전히 비활성화하는 디폴트 플러시 설정을 사용하기를 권장한다. 이 설정은 OS에서 수행하는 백그라운드 플러시와 카프카 자체 백그라운드 플러시에 의존한다는 걸 의미한다. 웬만한 용도엔 이렇게 두는 게 가장 좋을 거다: knob를 튜닝하지 않아도 되고, 뛰어난 처리량과 지연 시간을 제공하며, 완전한 복구를 보장한다. 우리는 로컬 디스크에 동기화하는 것보단 복제로 제공하는 내구성 보장이 더 효과적이라고 생각하지만, 강박관념이 있는 사람들은 그래도 둘 다 사용하는 걸 선호할 수 있으며, 어플리케이션 레벨 fsync 정책은 계속 지원하고 있다.

어플리케이션 레벨 플러시를 설정했을 때 단점은 디스크 사용 패턴에서 효율성이 떨어지고 (OS에서 쓰기를 재정렬할 여지가 줄어든다), 리눅스 파일 시스템 대부분에서 fsync는 파일 쓰기를 블로킹하므로 지연이 생길 수 있다는 거다. 백그라운드 플러싱은 훨씬 더 세밀한 페이지 레벨 잠금을 수행한다.

일반적으론 파일 시스템의 저수준을 튜닝할 필욘 없지만, 이어지는 몇 섹션에선 유용할만한 것들을 살펴 보겠다.

### Understanding Linux OS Flush Behavior

리눅스에서 파일 시스템에 기록된 데이터는 디스크에 기록할 시점(어플리케이션 레벨 fsync나 OS의 자체 플러시 정책으로)까지 [페이지 캐시](http://en.wikipedia.org/wiki/Page_cache)에 유지된다. 데이터 플러시는 pdflush라고 부르는(2.6.32 이후에선 커널 "flusher threads") 백그라운드 스레드 셋이 수행한다.

Pdflush에는 설정에 따라, 캐시에서 관리할 수 있는 dirty 데이터 양과 디스크에 기록해야 하기 전까지 유지할 시간을 제어하는 정책이 있다. 이 정책은 [여기](http://web.archive.org/web/20160518040713/http://www.westnet.com/~gsmith/content/linux-pdflush.htm)에서 설명하고 있다. Pdflush가 데이터 쓰기 속도를 따라가지 못하면, 결국엔 쓰기 프로세스가 블로킹돼 쓰기에 지연이 생기고 데이터 축적 속도를 늦춘다.

현재 OS 메모리 사용 상태는 다음 명령어로 확인할 수 있다.

```bash
> cat /proc/meminfo 
```

여기서 사용하는 값들의 의미는 위에 있는 링크에 나와있다.

페이지 캐시를 사용하면, 디스크에 기록할 데이터를 프로세스 안에 있는 캐시에 저장하는 것보다 더 나은 점이 몇 가지 있다:

- I/O 스케줄러는 연이은 작은 쓰기를 더 큰 물리적 쓰기로 일괄 처리해서 처리량을 올린다.
- I/O 스케줄러는 쓰기 연산을 디스크 헤드 이동을 최소화하는 방향으로 재정렬해서 처리량을 올린다.
- 자동으로 시스템의 모든 여유 메모리를 사용한다.

### Filesystem Selection

카프카는 디스크에 있는 일반 파일을 사용하기 때문에, 특정 파일 시스템에 대한 의존성은 없다. 그렇긴해도 EXT4와 XFS를 가장 많이 사용한다. 역사적으론 EXT4를 더 많이 사용해왔지만, 최근 개선 사항으로 XFS 파일 시스템이 카프카 워크 로드에서 안정성 저하 없이 더 나은 성능을 보여주는 것으로 나타났다.

다양한 파일 시스템 생성, 마운트 옵션을 사용해서 메세지 부하가 상당히 많은 클러스터에서 비교 테스트를 수행해봤다. append 연산에 걸린 시간을 나타내는 카프카의 기본 메트릭 "Request Local Time"을 모니터링했다. XFS가 보여준 로컬 시간이 훨씬 더 빨랐고 (160ms vs. EXT4는 최상의 설정에서도  250ms+), 평균 대기 시간도 더 적었다. 게다가 디스크 성능 변동도 XFS에서 더 적었다.

#### General Filesystem Notes

리눅스 시스템에서 데이터 디렉토리에 사용하는 파일 시스템이라면, 다음 옵션으로 마운트하는 게 좋다:

- noatime: 이 옵션은 파일을 읽을 때 파일의 atime(마지막 액세스 시간) 속성 업데이트를 비활성화한다. 이렇게 하면 특히 컨슈머를 부트스트래핑할 때 상당 수의 파일 시스템 쓰기를 없앨 수 있다. 카프카는 atime 속성은 전혀 사용하지 않기 때문에 비활성화해도 안전하다.

#### XFS Notes

XFS 파일 시스템엔 자체 자동 튜닝이 상당히 많기 때문에, 파일 시스템을 만들 때나 마운트할 때 굳이 기본 세팅을 변경할 필욘 없다. 고려해봄직한 튜닝 파라미터를 굳이 뽑자면 다음과 같다:

- largeio: 이 파라미터에 따라 stat 호출로 보고하는 선호 I/O 크기가 달라질 수 있다. 디스크 쓰기가 큰 편이라면 더 높은 성능을 보여줄 수 있지만, 실제로는 성능에 거의 영향이 없으며, 있다고 해도 효과가 크지 않다.
- nobarrier: 배터리 카드를 가진 비휘발성 캐시에선, 이 옵션으로 주기적인 쓰기 플러시를 비활성화하면 성능이 약간 올라갈 수 있다. 하지만 디바이스가 제대로 작동한다면 파일 시스템에 플러시가 필요하지 않다고 보고할 거고, 이 옵션의 효과도 사라진다.

#### EXT4 Notes

카프카 데이터 디렉토리로 사용할 파일 시스템으로, EXT4를 선택해도 좋지만, 성능을 최대로 얻으려면 몇 가지 마운트 옵션을 조정해야 한다. 게다가, 이런 옵션들은 보통 실패 시나리오에선 안전하지 않으며, 훨씬 더 많은 데이터가 유실되거나 손상될 수 있다. 단일 브로커 실패에선, 디스크를 완전히 비우고서 클러스터에서 레플리카를 다시 빌드하면 되기 때문에 별 문제 되지 않는다. 하지만 정전같은 다중 장애 시나리오에선, 쉽게 복구할 수 없는 기본 파일 시스템(거기 있는 데이터도)이 손상될 수 있다는 뜻이다. 조정할 수 있는 옵션은 다음과 같다:

- data=writeback: Ext4의 기본값은 data=ordered로, 일부 쓰기에 확실한 순서를 매긴다. 카프카는 플러시하지 않은 모든 로그 데이터를 지나치게 꼼꼼할 정도로 복구해보기 때문에, 이 순서는 필요 없다. 이렇게 세팅하면 순서 제약 조건을 제거하며, 대기 시간이 상당히 줄어드는 걸로 보인다.
- 저널링 비활성: 저널링은 일종의 트레이드 오프다. 서버 충돌 후에 재부팅 속도는 빨라지지만, 여기저기에 잠금을 추가해 쓰기 성능에 변동이 생긴다. 재부팅 시간은 게의치 않으며 쓰기 지연 시간이 급증하는 주요 원인을 줄이고 싶다면 저널링을 완전히 꺼도 된다.
- commit=num_secs: 이 옵션은 ext4가 메타데이터 저널에 커밋하는 빈도를 조정한다. 더 낮게 설정하면, 장애 발생 시 플러시하지 않은 데이터 손실이 줄어든다. 더 높게 설정하면 처리량이 개선된다.
- nobh: 이 설정은 data=writeback 모드를 사용할 때 순서 보장을 추가로 제어한다. 카프카는 쓰기 순서에 의존하지 않고 처리량과 대기 시간을 개선하므로 카프카에서 사용해도 안전하다.
- delalloc: 지연된 할당(delayed allocation)은 물리적인 쓰기가 발생하기 전엔 파일 시스템이 어떤 블록도 할당하지 않는다는 걸 의미한다. 이를 통해 ext4는 작은 페이지 대신 큰 범위를 할당할 수 있으며, 데이터를 순차적으로 기록하기에도 좋다. 이 기능은 처리량 관점에서 괜찮다. 파일 시스템의 잠금을 수반해 약간의 지연 시간 변동이 생기는 것으로 보인다.

---

## 6.8 ZooKeeper

### Stable version

현재 stable 브랜치는 3.5다. 카프카는 3.5 시리즈의 최신 릴리즈를 포함하도록 정기적으로 업데이트하고 있다.

### Operationalizing ZooKeeper

우리는 운영상 안정적인 주키퍼를 설치하기 위해 다음 정책을 따르고 있다:

- 물리/하드웨어/네트워크 레이아웃의 이중화: 괜찮은 하드웨어가 있다고 모든 것을 같은 하드웨어, 동일한 랙에 넣지 말고, 전원과 네트워크 경로를 여러 벌 유지해라. 전형적인 주키퍼 앙상블은 5개 또는 7개의 서버로, 각각 서버 다운을 2대와 3대까지 견딜 수 있다. 소규모 배포라면, 서버 3개를 사용하는 것도 괜찮지만, 이때는 서버 다운은 1대까지만 견딜 수 있다는 점을 명심해라.
- I/O 분리: 쓰기 트래픽이 많다면, 거의 틀림없이 전용 트랜잭션 로그를 위한 디스크 그룹이 필요할 거다. 트랜잭션 로그에 대한 쓰기는 동기식이므로 (하지만 성능을 위해 일괄로 처리한다), 동시 쓰기는 성능에 상당한 영향을 미칠 수 있다. 동시 쓰기 소스 중 하나는 주키퍼 스냅샷일 수도 있으며, 이상적으로는 트랜잭션 로그와는 분리된 별도 디스크 그룹에 작성해야 한다. 스냅샷은 디스크에 비동기식으로 기록되므로, 보통은 운영 체제, 메세지 로그 파일과 공유해도 괜찮긴 하다. 별도 디스크 그룹을 사용하는 서버는 dataLogDir 파라미터로 설정할 수 있다.
- 어플리케이션 분리: 다른 어플리케이션의 사용 패턴을 정말로 이해한게 아니라면, 동일한 구역에 설치하기 보단 주키퍼를 별도로 격리하는 게 좋다 (하드웨어 역량에 따라 균형을 맞추려는 걸 수도 있지만).
- 가상화 사용시 주의사항: 클러스터 레이아웃과 읽기/쓰기 패턴, SLA에 따라 잘 동작할 수도 있지만, 주키퍼는 시간에 매우 민감할 수 있기 때문에, 가상화 계층으로 추가된 작은 오버 헤드때문에 주키퍼가 떨어져 나갈 수도 있다.
- 주키퍼 설정: 주키퍼는 자바이므로, '충분한' 힙 공간을 제공해야 한다 (보통은 3-5G로 실행하는데, 대부분 여기에 있는 데이터 셋 크기 때문이다). 안타깝게도, 힙 사이즈에 대한 괜찮은 공식은 없지만, 주키퍼 상태를 더 많이 허용하면 스냅샷이 커질 수 있고, 큰 스냅샵은 복구 시간에 영향을 미칠 수 있다는 걸 명심해라. 실제로 스냅샷이 너무 커지면 (수 기가 바이트), initLimit 파라미터를 서버가 복구하고 앙상블에 참여할 수 있는 충분한 시간으로 늘려야 할 수도 있다.
- 모니터링: JMX와 4lw(4 letter words) 명령어 모두 매우 유용한데, 경우에 따라 겹치기도 한다 (이럴땐 4lw를 선호한다. 4lw는 더 예측하기 쉽고, 아니면 적어도 LI 모니터링 인프라와 더 잘 어우러진다).
- 클러스터를 과도하게 구축하지 말아라: 대규모 클러스터는, 특히 쓰기를 많이 사용하는 패턴에선, 클러스터 내 통신이 많이 필요하단 걸 의미한다 (쓰기와 후속 클러스터 구성원 업데이트에 관한 정족수). 그렇다고 과도하게 줄이지는 마라 (클러스터 가용량이 모자를 수도 있다). 서버가 많아지면 읽기 수용량도 늘어난다.

전반적으로 카프카에선, 부하를 견딜 수 있는 한 (표준 확장 플랜도 포함해서), 주키퍼 시스템을 가능한 작고 간단하게 유지하려고 애쓰고 있다. 카프카에선 주키퍼 공식 릴리즈와 비교했을 때 설정이나 어플리케이션 레이아웃에 별다른 걸 추가하지 않으며, 가능한 한 내장형으로 유지하려고 한다. 이러한 이유로 카프카에선 OS 패키지 버전은 건너 뛰는 편이다. OS 패키지 버전에선 OS 표준 계층 구조에 뭔가를 집어넣는 경향이 있어, 더 나은 표현이 있으면 좋겠지만, '난잡'해질 수 있다.