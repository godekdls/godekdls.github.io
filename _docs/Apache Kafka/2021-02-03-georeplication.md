---
title: Geo-Replication
category: Apache Kafka
order: 13
permalink: /Apache%20Kafka/geo-replication/
description: 카프카 미러링을 통해 개별 카프카 클러스터나, 데이터센터 또는 지리적 영역의 경계를 넘나드는 데이터 플로우을 정의하는 방법
image: ./../../images/kafka/logo.png
lastmod: 2021-02-14T22:25:00+09:00
comments: true
originalRefName: 아파치 카프카
originalRefLink: https://kafka.apache.org/27/documentation.html#georeplication
---

### 목차

- [6.2 Datacenters](#62-datacenters)
- [6.3 Geo-Replication (Cross-Cluster Data Mirroring)](#63-geo-replication-cross-cluster-data-mirroring)
  + [Geo-Replication Overview](#geo-replication-overview)
  + [What Are Replication Flows](#what-are-replication-flows)
  + [Configuring Geo-Replication](#configuring-geo-replication)
    * [Configuration File Syntax](#configuration-file-syntax)
    * [Creating and Enabling Replication Flows](#creating-and-enabling-replication-flows)
    * [Configuring Replication Flows](#configuring-replication-flows)
    * [Securing Replication Flows](#securing-replication-flows)
    * [Custom Naming of Replicated Topics in Target Clusters](#custom-naming-of-replicated-topics-in-target-clusters)
    * [Preventing Configuration Conflicts](#preventing-configuration-conflicts)
    * [Best Practice: Consume from Remote, Produce to Local](#best-practice-consume-from-remote-produce-to-local)
    * [Example: Active/Passive High Availability Deployment](#example-activepassive-high-availability-deployment)
    * [Example: Active/Active High Availability Deployment](#example-activeactive-high-availability-deployment)
    * [Example: Multi-Cluster Geo-Replication](#example-multi-cluster-geo-replication)
  + [Starting Geo-Replication](#starting-geo-replication)
  + [Stopping Geo-Replication](#stopping-geo-replication)
  + [Applying Configuration Changes](#applying-configuration-changes)
  + [Monitoring Geo-Replication](#monitoring-geo-replication)

---

## 6.2 Datacenters

어떤 서비스에선 데이터센터 여러 개에 걸친 데이터파이프 라인을 관리해야 한다. 권장하는 방법은 데이터센터마다 로컬 카프카 클러스터를 배포하고, 각 데이터센터의 어플리케이션 인스턴스는 해당 로컬 클러스터와만 상호 작용하며, 클러스터간에 데이터를 미러링 하는 거다 (그 방법은 [Geo-Replication](#63-geo-replication-cross-cluster-data-mirroring) 문서 참고).

이 패턴대로 배포하면, 데이터센터는 독립적인 엔티티로써 동작하고, 데이터센터 간 복제는 카프카 중앙에서 관리하고 조정할 수 있다. 이렇게하면 데이터센터 간 링크를 사용할 수 없을 때도 각 시설은 독립적으로 동작할 수 있다. 링크가 끊어지면 다시 따라잡고 복구하기까진 미러링이 뒤쳐져 있을 거다.

모든 데이터에 대한 글로벌 뷰가 필요한 어플리케이션이라면, 미러링을 통해 *모든* 데이터센터의 로컬 클러스터에서 미러링한 집계 데이터를 가진 클러스터를 제공할 수 있다. 전체 데이터 셋이 필요한 어플리케이션은 이 집계 클러스터에서 데이터를 읽어간다.

이것만이 유일한 배포 패턴은 아니다. 클러스터를 가져 오는데 대기 시간이 추가로 들어갈 게 뻔하긴 하지만, WAN을 통해서도 원격 카프카 클러스터에서 데이터를 읽고 쓸 수 있다.

카프카에선 프로듀서와 컨슈머 모두 자연히 데이터를 일괄로 처리하므로, 커넥션 대기 시간이 길더라도 높은 처리량을 달성할 수 있다. 처리량을 높히려면 [`socket.send.buffer.bytes`](../broker-configuration#socketsendbufferbytes), [`socket.receive.buffer.bytes`](../broker-configuration#socketreceivebufferbytes) 설정으로 프로듀서, 컨슈머 및 브로커에 대한 TCP 소켓 버퍼 크기를 늘려야 할 수도 있다. 적당한 값을 설정할 수 있는 방법은 [여기](http://en.wikipedia.org/wiki/Bandwidth-delay_product)에 정리돼 있다.

보통 *단일* 카프카 클러스터를 대기 시간이 긴 링크를 통해 데이터센터 여러 개를 넘나들도록 실행하는 건 바람직하지 *않다*. 이렇게 되면 카프카 쓰기와 주키퍼 쓰기 모두 복제 대기 시간이 매우 길어지며, 네트워크가 끊기면 카프카나 주키퍼를 모든 위치에서 사용할 수 없게 된다.

---

## 6.3 Geo-Replication (Cross-Cluster Data Mirroring)

### Geo-Replication Overview

카프카 관리자는 개별 카프카 클러스터나, 데이터센터 또는 지리적 영역의 경계를 넘나드는 데이터 플로우을 정의할 수 있다. 이런 이벤트 스트리밍은 보통 조직적, 기술적, 법적 요구 사항으로 세팅하게 된다. 일반적인 시나리오는 다음과 같다:

- 지리적 복제(Geo-replication)
- 재해 복구
- 엣지 클러스터를 중앙 집계 클러스터로 피딩
- 클러스터의 물리적인 격리 (프로덕션 vs. 테스트 등으로)
- 클라우드 마이그레이션 또는 하이브리드 클라우드 배포
- 법률 및 규정 준수

이런 클러스터 간의 데이터 플로우는 카프카의 MirrorMaker(버전 2)로 세팅할 수 있다. MirrorMaker는 서로 다른 카프카 환경 간에 데이터를 스트리밍 방식으로 복제하기 위한 툴이다. 카프카 커넥트 프레임워크 기반으로 구축됐으며, 다음과 같은 기능을 지원한다:

- 토픽 복제 (데이터와 설정 모두)
- 클러스터 간 어플리케이션 마이그레이션을 위한, 오프셋을 포함한 컨슈머 그룹 복제
- ACL 복제
- 파티셔닝 보전
- 새 토픽과 파티션 자동 감지
- 여러 데이터센터/클러스터에 걸친 end-to-end 복제 대기 시간 등의 광범위한 메트릭 제공
- 장애 허용과 수평 확장이 가능한 운용

*참고사항: MirrorMaker를 사용한 지리적 복제는, 카프카 클러스터 간의 데이터를 복제한다. 클러스터 간 복제는, 동일한 카프카 클러스터 내에서 데이터를 복제하는 카프카의 [클러스터 내 복제](../design#47-replication)와는 다른 개념이다.*

### What Are Replication Flows

MirrorMaker를 사용하면 카프카 관리자는 토픽, 토픽 설정, 카프카 그룹과 오프셋, ACL을 하나 이상의 소스 카프카 클러스터에서 하나 이상의 타겟 카프카 클러스터로 복제할 수 있다 (즉, 클러스터 환경간 복제). 간단히 말해서 MirrorMaker는 커넥터를 사용해 소스 클러스터를 컨슘하고 타겟 클러스터로 프로듀스한다.

소스에서 타겟 클러스터로 흐르는 이런 플로우를 복제 플로우라고 부른다. 이 플로우는 나중에 설명하는 MirrorMaker 설정 파일에서 `{source_cluster}->{target_cluster}` 형식으로 정의한다. 관리자는 이 플로우을 기반으로 복잡한 복제 토폴로지를 생성할 수 있다.

몇 가지 패턴을 예로 들면 다음과 같다:

- Active/Active 고가용성 배포: `A->B, B->A`
- Active/Passive 또는 Active/Standby 고가용성 배포: `A->B`
- 집계 (즉, 클러스터 여러 개에서 하나로): `A->K, B->K, C->K`
- Fan-out (즉, 클러스터 하나에서 여러 개로): `K->A, K->B, K->C`
- 포워딩: `A->B, B->C, C->D`

플로우는 기본적으로 모든 토픽과 컨슈머 그룹을 복제한다. 하지만 각 복제 플로우를 독립적으로 구성할 수도 있다. 예를 들어, 특정 토픽이나 컨슈머 그룹만 소스 클러스터에서 타겟 클러스터로 복제하도록 정의할 수 있다.

첫 번째 예시는 `primary` 클러스터에서 `secondary` 클러스터로 데이터 복제를 구성하는 예시다 (active/passive 설정):

```properties
# Basic settings
clusters = primary, secondary
primary.bootstrap.servers = broker3-primary:9092
secondary.bootstrap.servers = broker5-secondary:9092

# Define replication flows
primary->secondary.enable = true
primary->secondary.topics = foobar-topic, quux-.*
```

### Configuring Geo-Replication

여기서부터는 전용 MirrorMaker 클러스터를 구성하고 실행하는 방법을 설명한다. MirrorMaker를 기존 카프카 커넥트 클러스터나 지원하는 다른 배포 설정 내에서 실행하려면 [KIP-382: MirrorMaker 2.0](https://cwiki.apache.org/confluence/display/KAFKA/KIP-382%3A+MirrorMaker+2.0)을 참고해라. 단, 설정 프로퍼티명은 배포 모드에 따라 다를 수 있다.

아래 섹션에서 다루는 내용 외에, 다음 링크에서도 설정 세팅에 대한 추가 예제와 정보를 확인할 수 있다:

- [MirrorMakerConfig](https://github.com/apache/kafka/blob/trunk/connect/mirror/src/main/java/org/apache/kafka/connect/mirror/MirrorMakerConfig.java), [MirrorConnectorConfig](https://github.com/apache/kafka/blob/trunk/connect/mirror/src/main/java/org/apache/kafka/connect/mirror/MirrorConnectorConfig.java)
- 토픽은 [DefaultTopicFilter](https://github.com/apache/kafka/blob/trunk/connect/mirror/src/main/java/org/apache/kafka/connect/mirror/DefaultTopicFilter.java), 컨슈머 그룹은 [DefaultGroupFilter](https://github.com/apache/kafka/blob/trunk/connect/mirror/src/main/java/org/apache/kafka/connect/mirror/DefaultGroupFilter.java)
- 설정 세팅 예시: [connect-mirror-maker.properties](https://github.com/apache/kafka/blob/trunk/config/connect-mirror-maker.properties), [KIP-382: MirrorMaker 2.0](https://cwiki.apache.org/confluence/display/KAFKA/KIP-382%3A+MirrorMaker+2.0)

#### Configuration File Syntax

보통 MirrorMaker 설정 파일은 `connect-mirror-maker.properties`이다. 이 파일로 다양한 컴포넌트를 설정할 수 있다:

- MirrorMaker 설정: 클러스터 정의(alias)를 포함한 전역 설정과, 복제 플로우별 커스텀 설정
- 카프카 커넥트와 커넥터 설정
- 카프카 프로듀서, 컨슈머, 어드민 클라이언트 설정

MirrorMaker 설정 예시 (뒤에서 자세히 설명한다):

```properties
# Global settings
clusters = us-west, us-east   # defines cluster aliases
us-west.bootstrap.servers = broker3-west:9092
us-east.bootstrap.servers = broker5-east:9092

topics = .*   # all topics to be replicated by default

# Specific replication flow settings (here: flow from us-west to us-east)
us-west->us-east.enable = true
us-west->us.east.topics = foo.*, bar.*  # override the default above
```

MirrorMaker는 카프카 커넥트 프레임워크 기반이다. [카프카 커넥트 챕터](../kafka-connect-configuration)에서 설명했던 카프카 커넥트, 소스 커넥터, 싱크 커넥터 설정은 설정 세팅 이름을 변경하거나 프리픽스를 지정할 필요 없이, MirrorMaker 설정에 바로 사용할 수 있다.

MirrorMaker에서 사용할 커스텀 카프카 커넥터 설정 예시:

```properties
# Setting Kafka Connect defaults for MirrorMaker
tasks.max = 5
```

MirrorMaker는 [`tasks.max`](../kafka-connect-configuration#tasksmax)를 제외하고는 대부분 디폴트 카프카 커넥트 설정만으로도 잘 동작한다. MirrorMaker 프로세스 둘 이상에 작업량을 균등하게 분배하려면, 가능한 하드웨어 리소스와 복제할 토픽 파티션의 총 갯수에 따라 [`tasks.max`](../kafka-connect-configuration#tasksmax)를 최소 `2`(가급적이면 더 높게)로 설정하는 게 좋다.

MirrorMaker의 카프카 커넥트 설정은, *소스나 타겟 클러스터별로* 추가로 커스텀할 수 있다 (더 정확하게는, "커넥터 당" 카프카 커넥터 워커 레벨 설정 세팅). 이땐 MirrorMaker 설정 파일에 `{cluster}.{config_name}` 형식을 사용한다.

`us-west` 클러스터를 위한 커스텀 커넥터 설정 예시:

```properties
# us-west custom settings
us-west.offset.storage.topic = my-mirrormaker-offsets
```

MirrorMaker 내부에선 카프카 프로듀서, 컨슈머, 어드민 클라이언트를 사용한다. 이 클라이언트 설정도 커스텀이 필요할 때가 많다. 기본값을 재정의하려면 MirrorMaker 설정 파일에 다음 포맷을 사용해라:

- `{source}.consumer.{consumer_config_name}`
- `{target}.producer.{producer_config_name}`
- `{source_or_target}.admin.{admin_config_name}`

커스텀 프로듀서, 컨슈머, 어드민 클라이언트 설정 예시:

```properties
# us-west cluster (from which to consume)
us-west.consumer.isolation.level = read_committed
us-west.admin.bootstrap.servers = broker57-primary:9092

# us-east cluster (to which to produce)
us-east.producer.compression.type = gzip
us-east.producer.buffer.memory = 32768
us-east.admin.bootstrap.servers = broker8-secondary:9092
```

#### Creating and Enabling Replication Flows

복제 플로우를 정의하려면 먼저, MirrorMaker 설정 파일에 각 소스와 타겟 카프카 클러스터를 정의해야 한다.

- `clusters` (필수): 카프카 클러스터 "alias" 리스트로, 콤마로 구분한다.
- `{clusterAlias}.bootstrap.servers` (필수): 특정 클러스터에 대한 커넥션 정보. "bootstrap" 카프카 브로커 리스트로, 쉼표로 구분한다.

두 클러스터 alias `primary`, `secondary`와 커넥션 정보 정의 예시:

```properties
clusters = primary, secondary
primary.bootstrap.servers = broker10-primary:9092,broker-11-primary:9092
secondary.bootstrap.servers = broker5-secondary:9092,broker6-secondary:9092
```

그 다음엔, 필요에 따라 `{source}->{target}.enabled = true`를 명시해서 복제 플로우를 개별적으로 활성화해야 한다. 플로우에는 방향성이 있다는 걸 기억해라. Two-way(양방향) 복제가 필요하다면 양방향 플로우 모두 활성화해야 한다.

```properties
# Enable replication from primary to secondary
primary->secondary.enable = true
```

기본적으로 복제 플로우는, 소스 클러스터에 있는 모든 항목을 몇 가지 특별한 토픽과 컨슈머 그룹만 제외하고 전부 타겟 클러스터로 복제하며, 새로 생성된 모든 토픽과 그룹을 자동으로 감지한다. 타겟 클러스터에 복제된 토픽명은 소스 클러스터의 이름으로 시작한다 (아래 섹션 참조). 예를 들어, 소스 클러스터 `us-west`의 토픽 `foo`는 타겟 클러스터 `us-east`에 `us-west.foo`라는 토픽으로 복제된다.

이어지는 섹션에선 필요에 따라 이 기본 설정을 커스텀하는 방법에 대해 설명한다.

#### Configuring Replication Flows

복제 플로우 설정은 최상위 디폴트 설정들로(ex. `topics`) 구성되며, 그 위에 플로우 별 설정이(ex. `us-west->us-east.topics`) 적용된다. 최상위 기본값을 변경하려면 MirrorMaker 설정 파일에 필요한 최상위 설정을 추가해라. 특정 복제 플로우에 대해서만 기본값을 재정의할 땐 `{source}->{target}.{config.name}` 포맷을 사용한다.

가장 중요한 설정은 다음과 같다:

- `topics`: 소스 클러스터에 있는 복제할 토픽. 토픽 리스트나 정규 표현식으로 표현한다 (디폴트: `topics = .*`).
- `topics.exclude`: 이후 `topics` 설정에서 매칭되는 토픽을 제외한다. 토픽 리스트나 정규 표현식으로 표현한다 (디폴트: <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">topics.exclude = .*[\-\.]internal, .*\.replica, __.*</span>).
- `groups`: 소스 클러스터에 있는 복제할 컨슈머 그룹. 토픽 리스트나 정규 표현식으로 표현한다 (디폴트: `groups = .*`).
- `groups.exclude`: 이후 `groups` 설정에서 매칭되는 컨슈머 그룹을 제외한다. 토픽 리스트나 정규 표현식으로 표현한다 (디폴트: <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">groups.exclude = console-consumer-.*, connect-.*, __.*</span>)
- `{source}->{target}.enable`: `true`로 설정하면 복제 플로우를 활성화한다 (디폴트: `false`).

예시:

```properties
# Custom top-level defaults that apply to all replication flows
topics = .*
groups = consumer-group1, consumer-group2

# Don't forget to enable a flow!
us-west->us-east.enable = true

# Custom settings for specific replication flows
us-west->us-east.topics = foo.*
us-west->us-east.groups = bar.*
us-west->us-east.emit.heartbeats = false
```

다른 설정 세팅도 사용할 수 있으며, 일부는 아래에 나열해 뒀다. 이 세팅들은 대부분 디폴트 값으로 놔둬도 된다. 자세한 내용은 [MirrorMakerConfig](https://github.com/apache/kafka/blob/trunk/connect/mirror/src/main/java/org/apache/kafka/connect/mirror/MirrorMakerConfig.java), [MirrorConnectorConfig](https://github.com/apache/kafka/blob/trunk/connect/mirror/src/main/java/org/apache/kafka/connect/mirror/MirrorConnectorConfig.java)를 참고해라.

- `refresh.topics.enabled`: 소스 클러스터에서 새 토픽을 주기적으로 확인할지 여부 (디폴트: true)
- `refresh.topics.interval.seconds`: 소스 클러스터에서 새 토픽을 확인하는 주기. 기본값보다 낮게 설정하면 성능 저하의 원인이 될 수 있다 (디폴트: 6000, 10분 간격)
- `refresh.groups.enabled`: 소스 클러스터에서 새 컨슈머 그룹을 주기적으로 확인할지 여부 (디폴트: true)
- `refresh.groups.interval.seconds`: 소스 클러스터에서 새 컨슈머 그룹을 확인할 주기. 기본값보다 낮게 설정하면 성능 저하의 원인이 될 수 있다 (디폴트: 6000, 10분 간격)
- `sync.topic.configs.enabled`: 소스 클러스터에서 토픽 설정을 복제할지 여부 (디폴트: true)
- `sync.topic.acls.enabled`: 소스 클러스터에서 ACL을 동기화할지 여부 (디폴트: true)
- `emit.heartbeats.enabled`: 주기적으로 하트 비트를 방출할지 여부 (디폴트: true)
- `emit.heartbeats.interval.seconds`: 하트비트를 방출할 주기 (디폴트: 5, 5초 간격)
- `heartbeats.topic.replication.factor`: MirrorMaker 내부 하트 비트 토픽의 replication factor (디폴트: 3)
- `emit.checkpoints.enabled`: MirrorMaker의 컨슈머 오프셋을 주기적으로 방출할지 여부 (디폴트: true)
- `emit.checkpoints.interval.seconds`: 체크포인트를 방출할 빈도 (디폴트: 60, 10분 간격)
- `checkpoints.topic.replication.factor`: MirrorMaker 내부 체크포인트 토픽의 replication factor (디폴트: 3)
- `sync.group.offsets.enabled`: 타겟 클러스터에 연결된 활성 컨슈머가 없는 컨슈머 그룹을, 타겟 클러스터의 `__consumer_offsets` 토픽에 복제된 컨슈머 그룹(소스 클러스터에 있는) 오프셋으로 주기적으로 기록할지 여부 (디폴트: true)
- `sync.group.offsets.interval.seconds`: 컨슈머 그룹 오프셋을 동기화할 주기 (디폴트: 60, 10분 간격)
- `offset-syncs.topic.replication.factor`: MirrorMaker의 내부 offset-sync 토픽의 replication (디폴트: 3)

#### Securing Replication Flows

MirrorMaker는 [카프카 커넥트와 동일한 동일한 보안 설정](../kafka-connect-configuration)을 지원하므로, 자세한 내용은 링크된 섹션을 참고해라.

MirrorMaker와 `us-east` 클러스터 간의 통신을 암호화하는 예시:

```properties
us-east.security.protocol=SSL
us-east.ssl.truststore.location=/path/to/truststore.jks
us-east.ssl.truststore.password=my-secret-password
us-east.ssl.keystore.location=/path/to/keystore.jks
us-east.ssl.keystore.password=my-secret-password
us-east.ssl.key.password=my-secret-password
```

#### Custom Naming of Replicated Topics in Target Clusters

타겟 클러스터에 복제된 토픽(일명 *리모트* 토픽)은 복제 정책에 따라 이름이 변경된다. MirrorMaker는 이 정책을 통해 다른 클러스터의 이벤트(일명 레코드, 메세지)가 동일한 토픽 파티션에 기록되지 않도록 한다. 기본적으로 [DefaultReplicationPolicy](https://github.com/apache/kafka/blob/trunk/connect/mirror-client/src/main/java/org/apache/kafka/connect/mirror/DefaultReplicationPolicy.java)에 따라 타겟 클러스터에 복제된 토픽명은 `{source}.{source_topic_name}` 포맷으로 정해진다:

```text
us-west         us-east
=========       =================
                bar-topic
foo-topic  -->  us-west.foo-topic
```

구분자는 `replication.policy.separator` 설정으로 재정의할 수 있다 (디폴트: `.`):

```properties
# Defining a custom separator
us-west->us-east.replication.policy.separator = _
```

복제된 토픽의 명명법을 추가로 제어해야 한다면, 커스텀 `ReplicationPolicy`를 구현하고, MirrorMaker 설정에서 `replication.policy.class`를 재정의하면 된다 (디폴트는 `DefaultReplicationPolicy`다).

#### Preventing Configuration Conflicts

MirrorMaker 프로세스는 타겟 카프카 클러스터를 통해 설정을 공유한다. 이 동작은 타겟 클러스터가 같은 MirrorMaker 프로세스 간에 설정이 다르다면 충돌을 일으킬 수 있다.

예를 들어, 아래 두 MirrorMaker 프로세스는 서로 경쟁하는 관계다:

```properties
# Configuration of process 1
A->B.enabled = true
A->B.topics = foo

# Configuration of process 2
A->B.enabled = true
A->B.topics = bar
```

이렇게 되면 두 프로세스는 클러스터 `B`를 통해 설정을 공유하기 때문에 충돌이 생긴다. 두 프로세스 중 어떤 게 "리더"로 선출되었는지에 따라, 토픽 `foo` 또는 토픽 `bar`가 복제되지만, 둘 다 복제되지는 않는다.

따라서 동일한 타겟 클러스터로 흐르는 복제 플로우에선 MirrorMaker 설정을 일관되게 유지하는 게 중요하다. 예를 들어, 자동화 도구를 사용하거나, 모든 조직을 위한 단일 MirrorMaker 설정 파일을 공유하는 식으로 말이다.

#### Best Practice: Consume from Remote, Produce to Local

지연 시간("프로듀서 랙")을 최소화하려면, MirrorMaker 프로세스를 타겟 클러스터, 즉 데이터를 생성할 클러스터에 가능한 한 가깝게 두는 게 좋다. 카프카 프로듀서는 보통 카프카 컨슈머보다 불안정한 네트워크나 긴 지연 시간으로 인한 영향이 더 크기 때문이다.

```text
First DC          Second DC
==========        =========================
primary --------- MirrorMaker --> secondary
(remote)                           (local)
```

이렇게 "원격에서 컨슘, 로컬로 프로듀스" 세팅을 실행하려면, MirrorMaker 프로세스를 타겟 클러스터에 가깝고, 가급적이면 같은 위치에서 실행하고, 커맨드라인 파라미터 `--clusters`로 이 "로컬" 클러스터를 명시해라 (클러스터 alias 리스트로, 공백으로 구분):

```bash
# Run in secondary's data center, reading from the remote `primary` cluster
$ ./bin/connect-mirror-maker.sh connect-mirror-maker.properties --clusters secondary
```

`--clusters secondary`는 MirrorMaker 프로세스에 지정한 클러스터가 근처에 있음을 알리고, 다른 원격 위치에 있는 클러스터로 데이터를 복제하거나 설정을 전송하는 것을 막아준다.

#### Example: Active/Passive High Availability Deployment

다음 예시는 primary에서 secondary 카프카 환경으로 토픽을 복제하는 기본 설정을 보여주지만, secondary에서 primary로는 다시 복제하지 않는다. 프로덕션 세팅에는 대부분 보안 세팅같은 설정이 추가로 필요하다.

```properties
# Unidirectional flow (one-way) from primary to secondary cluster
primary.bootstrap.servers = broker1-primary:9092
secondary.bootstrap.servers = broker2-secondary:9092

primary->secondary.enabled = true
secondary->primary.enabled = false

primary->secondary.topics = foo.*  # only replicate some topics
```

#### Example: Active/Active High Availability Deployment

다음 예시는 두 클러스터간에 양방향으로 토픽을 복제하는 기본 설정을 보여준다. 프로덕션 세팅에는 대부분 보안 세팅같은 설정이 추가로 필요하다.

```properties
# Bidirectional flow (two-way) between us-west and us-east clusters
clusters = us-west, us-east
us-west.bootstrap.servers = broker1-west:9092,broker2-west:9092
Us-east.bootstrap.servers = broker3-east:9092,broker4-east:9092

us-west->us-east.enabled = true
us-east->us-west.enabled = true
```

*복제 "루프" (본래 A에서 B로 토픽을 복제한 다음, 이 복제된 토픽을 다시 B에서 A로 복제하는 등) 방지에 관한 참고 사항*: 위 플로우를 동일한 MirrorMaker 설정 파일에서 정의하기만 한다면, 두 클러스터 간의 복제 루프를 방지하기 위한 `topics.exclude` 설정을 추가로 명시하지 않아도 된다.

#### Example: Multi-Cluster Geo-Replication

앞에서 사용한 모든 정보를 더 큰 예시 하나로 모아보자. 데이터센터는 세 개가 있고 (west, east, north), 각 데이터센터마다 두 개의 카프카 클러스터(ex. `west-1`, `west-2`)가 있다고 상상해보자. 여기 있는 예시는 MirrorMaker를, (1) 각 데이터센터 내의 Active/Active 복제로 구성하는 방법과, (2) 교차 데이터센터 복제(Cross Data Center Replication, XDCR)로 구성하는 방법을 보여준다.

먼저, 설정에 소스/타겟 클러스터와 복제 플로우를 정의한다:

```properties
# Basic settings
clusters: west-1, west-2, east-1, east-2, north-1, north-2
west-1.bootstrap.servers = ...
west-2.bootstrap.servers = ...
east-1.bootstrap.servers = ...
east-2.bootstrap.servers = ...
north-1.bootstrap.servers = ...
north-2.bootstrap.servers = ...

# Replication flows for Active/Active in West DC
west-1->west-2.enabled = true
west-2->west-1.enabled = true

# Replication flows for Active/Active in East DC
east-1->east-2.enabled = true
east-2->east-1.enabled = true

# Replication flows for Active/Active in North DC
north-1->north-2.enabled = true
north-2->north-1.enabled = true

# Replication flows for XDCR via west-1, east-1, north-1
west-1->east-1.enabled  = true
west-1->north-1.enabled = true
east-1->west-1.enabled  = true
east-1->north-1.enabled = true
north-1->west-1.enabled = true
north-1->east-1.enabled = true
```

그런 다음, 각 데이터센터마다 하나 이상의 MirrorMaker를 시작한다:

```bash
# In West DC:
$ ./bin/connect-mirror-maker.sh connect-mirror-maker.properties --clusters west-1 west-2

# In East DC:
$ ./bin/connect-mirror-maker.sh connect-mirror-maker.properties --clusters east-1 east-2

# In North DC:
$ ./bin/connect-mirror-maker.sh connect-mirror-maker.properties --clusters north-1 north-2
```

이 설정을 사용하면, 모든 클러스터에 생성한 레코드가, 데이터센터 내에서 뿐 아니라 다른 데이터센터로도 복제된다. `--clusters` 파라미터를 제공하면 각 MirrorMaker 프로세스가 근처에 있는 클러스터에만 데이터를 생성하도록 만들 수 있다.

*참고사항* : 엄밀히 말해서 여기에 `--clusters` 파라미터를 꼭 써야하는 건 아니다. MirrorMaker는 이 파라미터 없이도 문제 없이 동작할 거다. 하지만 데이터센터 간의 "프로듀서 랙"으로 인해 처리량이 떨어질 수 있으며, 불필요한 데이터 전송 비용이 발생할 수 있다.

### Starting Geo-Replication

MirrorMaker 프로세스는 필요한만큼 적게도, 많이도 실행할 수 있다 (노드, 서버를 생각해봐라). MirrorMaker는 카프카 커넥트 기반이기 때문에, 동일한 카프카 클러스터를 복제하는 MirrorMaker 프로세스는 분산 설정 안에서 실행된다: 서로를 발견하고, 설정을 공유하고 (아래 섹션 참고), 작업 부하를 분산한다. 예를 들어, 복제 플로우의 처리량을 늘리고 싶다면, 별도 MirrorMaker 프로세스를 병렬로 실행하는 것도 한 가지 방법이다.

MirrorMaker 프로세스를 시작하려면 다음 명령어를 실행해라:

```bash
$ ./bin/connect-mirror-maker.sh connect-mirror-maker.properties
```

기동하고 나면, MirrorMaker 프로세스가 처음 데이터 복제를 시작하기까지 몇 분 정도 걸릴 수 있다.

앞에서 설명한대로, 원한다면 `--clusters` 파라미터를 설정해서 MirrorMaker 프로세스가 가까운 클러스터에만 데이터를 생성하도록 만들 수 있다.

```bash
# Note: The cluster alias us-west must be defined in the configuration file
$ ./bin/connect-mirror-maker.sh connect-mirror-maker.properties \
            --clusters us-west
```

*컨슈머 그룹 복제를 테스트할 때 주의사항*: 커맨드라인에서 MirrorMaker 설정을 테스트할 땐 `kafka-console-consumer.sh` 툴을 사용할 수도 있는데, MirrorMaker는 기본적으로 이 툴에서 생성한 컨슈머 그룹은 복제하지 않는다. 이 컨슈머 그룹도 복제하고 싶다면 `groups.exclude` 설정을 그에 맞게 수정해라 (디폴트: <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">groups.exclude = console-consumer-.*, connect-.*, __.*)</span>. 테스트를 완료 한 후에는 설정을 다시 업데이트해야 한다는 점을 잊지마라.

### Stopping Geo-Replication

실행중인 MirrorMaker 프로세스는 다음 명령어로 SIGTERM 신호를 보내 종료할 수 있다:

```bash
$ kill <MirrorMaker pid>
```

### Applying Configuration Changes

설정 변경 사항을 적용하려면, MirrorMaker 프로세스들을 다시 시작해야 한다.

### Monitoring Geo-Replication

MirrorMaker 프로세스를 실행할 땐, 모니터링을 통해 정의한 모든 복제 플로우가 올바르게 실행되고 있는지 확인하는 게 좋다. MirrorMaker는 커넥트 프레임워크를 기반으로 구축했으며, `source-record-poll-rate`같은 모든 커넥트의 메트릭을 상속한다. 추가로, MirrorMaker는 메트릭 그룹 `kafka.connect.mirror` 아래에 자체 메트릭을 생성한다. 메트릭은 다음 프로퍼티로 태깅된다:

- `source`: 소스 클러스터의 alias (ex. `primary`)
- `target`: 타겟 클러스터의 alias (ex. `secondary`)
- `topic`: 타겟 클러스터에 복제된 토픽
- `partition`: 복제 중인 파티션

메트릭은 복제된 토픽별로 추적한다. 토픽명을 보면 소스 클러스터를 유추할 수 있다. 예를 들어 `primary->secondary`로 `topic1`을 복제하면 다음과 같은 메트릭이 생긴다:

- `target=secondary`
- `topic=primary.topic1`
- `partition=1`

발생하는 메트릭은 다음과 같다:

```properties
# MBean: kafka.connect.mirror:type=MirrorSourceConnector,target=([-.w]+),topic=([-.w]+),partition=([0-9]+)

record-count            # number of records replicated source -> target
record-age-ms           # age of records when they are replicated
record-age-ms-min
record-age-ms-max
record-age-ms-avg
replication-latency-ms  # time it takes records to propagate source->target
replication-latency-ms-min
replication-latency-ms-max
replication-latency-ms-avg
byte-rate               # average number of bytes/sec in replicated records

# MBean: kafka.connect.mirror:type=MirrorCheckpointConnector,source=([-.w]+),target=([-.w]+)

checkpoint-latency-ms   # time it takes to replicate consumer offsets
checkpoint-latency-ms-min
checkpoint-latency-ms-max
checkpoint-latency-ms-avg
```

이 메트릭들은 생성 시점과 로그에 추가된 시점을 구분하지 않는다.
