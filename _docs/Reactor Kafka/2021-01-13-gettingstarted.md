---
title: Getting Started
category: Reactor Kafka
order: 4
permalink: /Reactor%20Kafka/gettingstarted/
description: 리액터 카프카 샘플 맛보기 한글 번역
image: ./../../images/reactor/logo.png
lastmod: 2021-01-11T15:00:00+09:00
comments: true
originalRefName: 프로젝트 리액터 카프카
originalRefLink: https://projectreactor.io/docs/kafka/1.3.1/reference/index.html#_getting_started
---

### 목차

- [3.1. Requirements](#31-requirements)
- [3.2. Quick Start](#32-quick-start)
  + [3.2.1. Start Kafka](#321-start-kafka)
  + [3.2.2. Run Reactor Kafka Samples](#322-run-reactor-kafka-samples)
    * [Sample Producer](#sample-producer)
    * [Sample Consumer](#sample-consumer)
  + [3.2.3. Building Reactor Kafka Applications](#323-building-reactor-kafka-applications)

---

## 3.1. Requirements

자바 JRE를 설치해야 한다 (자바 8 이상).

[아파치 카프카](https://kafka.apache.org/)를 설치해야 한다 (1.0.0 이상). 카프카는 [kafka.apache.org/downloads.html](https://kafka.apache.org/downloads.html)에서 다운받을 수 있다. 단, 리액터 카프카를 사용하려면 아파치 카프카 클라이언트 라이브러리는 2.0.0 이상, 브로커 버전은 1.0.0 이상이 필요하다.

---

## 3.2. Quick Start

이 튜토리얼에선 주키퍼, 카프카 단일 노드를 설정하고 샘플 리액티브 프로듀서, 컨슈머를 실행한다. 멀티 브로커 클러스터 설정 가이드는 [여기](https://kafka.apache.org/documentation#quickstart_multibroker)에서 확인할 수 있다.

### 3.2.1. Start Kafka

아직 카프카를 다운받지 않았다면 [2.0.0](https://www.apache.org/dyn/closer.cgi?path=/kafka/2.0.0/kafka_2.11-2.0.0.tgz) 버전 이상을 다운받아라.

릴리즈 압축을 풀고 KAFKA_DIR을 설치 디렉토리로 설정해라. 예를 들어,

```bash
> tar -zxf kafka_2.11-2.0.0.tgz -C /opt
> export KAFKA_DIR=/opt/kafka_2.11-2.0.0
```

다운받은 카프카에 들어 있는 주키퍼 인스톨을 사용해 단일 노드 주키퍼 인스턴스를 기동해보자:

```bash
> $KAFKA_DIR/bin/zookeeper-server-start.sh $KAFKA_DIR/config/zookeeper.properties > /tmp/zookeeper.log &
```

단일 노드 카프카 인스턴스도 기동한다:

```bash
> $KAFKA_DIR/bin/kafka-server-start.sh $KAFKA_DIR/config/server.properties > /tmp/kafka.log &
```

카프카 토픽을 생성해라:

```bash
> $KAFKA_DIR/bin/kafka-topics.sh --zookeeper localhost:2181 --create --replication-factor 1 --partitions 2 --topic demo-topic
Created topic "demo-topic".
```

카프카 토픽이 제대로 만들어졌는지 확인해보자:

```bash
> $KAFKA_DIR/bin/kafka-topics.sh --zookeeper localhost:2181 --describe
Topic: demo-topic	PartitionCount:2		ReplicationFactor:1	Configs:
Topic: demo-topic	Partition: 0	Leader: 0	Replicas: 0		Isr: 0
Topic: demo-topic	Partition: 1	Leader: 0	Replicas: 0		Isr: 0
```

### 3.2.2. Run Reactor Kafka Samples

[github.com/reactor/reactor-kafka/](https://github.com/reactor/reactor-kafka/)에서 리액터 카프카를 다운받고 빌드해라.

```bash
> git clone https://github.com/reactor/reactor-kafka
> cd reactor-kafka
> ./gradlew jar
```

reactor-kafka 샘플을 실행하려면 `CLASSPATH`를 설정해야 한다. `CLASSPATH`는 하위 프로젝트 samples의 classpath 태스크로 가져올 수 있다.

```bash
> export CLASSPATH=`./gradlew -q :reactor-kafka-samples:classpath`
```

#### Sample Producer

샘플 프로듀서 코드는 [github.com/reactor/reactor-kafka/blob/master/reactor-kafka-samples/src/main/java/reactor/kafka/samples/SampleProducer.java](https://github.com/reactor/reactor-kafka/blob/master/reactor-kafka-samples/src/main/java/reactor/kafka/samples/SampleProducer.java)를 확인해라.

샘플 프로듀서를 실행해보자:

```bash
> $KAFKA_DIR/bin/kafka-run-class.sh reactor.kafka.samples.SampleProducer
Message 2 sent successfully, topic-partition=demo-topic-1 offset=0 timestamp=13:33:16:716 GMT 30 Nov 2016
Message 3 sent successfully, topic-partition=demo-topic-1 offset=1 timestamp=13:33:16:716 GMT 30 Nov 2016
Message 4 sent successfully, topic-partition=demo-topic-1 offset=2 timestamp=13:33:16:716 GMT 30 Nov 2016
Message 6 sent successfully, topic-partition=demo-topic-1 offset=3 timestamp=13:33:16:716 GMT 30 Nov 2016
Message 7 sent successfully, topic-partition=demo-topic-1 offset=4 timestamp=13:33:16:716 GMT 30 Nov 2016
Message 10 sent successfully, topic-partition=demo-topic-1 offset=5 timestamp=13:33:16:716 GMT 30 Nov 2016
Message 11 sent successfully, topic-partition=demo-topic-1 offset=6 timestamp=13:33:16:716 GMT 30 Nov 2016
Message 12 sent successfully, topic-partition=demo-topic-1 offset=7 timestamp=13:33:16:717 GMT 30 Nov 2016
Message 13 sent successfully, topic-partition=demo-topic-1 offset=8 timestamp=13:33:16:717 GMT 30 Nov 2016
Message 14 sent successfully, topic-partition=demo-topic-1 offset=9 timestamp=13:33:16:717 GMT 30 Nov 2016
Message 16 sent successfully, topic-partition=demo-topic-1 offset=10 timestamp=13:33:16:717 GMT 30 Nov 2016
Message 17 sent successfully, topic-partition=demo-topic-1 offset=11 timestamp=13:33:16:717 GMT 30 Nov 2016
Message 20 sent successfully, topic-partition=demo-topic-1 offset=12 timestamp=13:33:16:717 GMT 30 Nov 2016
Message 1 sent successfully, topic-partition=demo-topic-0 offset=0 timestamp=13:33:16:712 GMT 30 Nov 2016
Message 5 sent successfully, topic-partition=demo-topic-0 offset=1 timestamp=13:33:16:716 GMT 30 Nov 2016
Message 8 sent successfully, topic-partition=demo-topic-0 offset=2 timestamp=13:33:16:716 GMT 30 Nov 2016
Message 9 sent successfully, topic-partition=demo-topic-0 offset=3 timestamp=13:33:16:716 GMT 30 Nov 2016
Message 15 sent successfully, topic-partition=demo-topic-0 offset=4 timestamp=13:33:16:717 GMT 30 Nov 2016
Message 18 sent successfully, topic-partition=demo-topic-0 offset=5 timestamp=13:33:16:717 GMT 30 Nov 2016
Message 19 sent successfully, topic-partition=demo-topic-0 offset=6 timestamp=13:33:16:717 GMT 30 Nov 2016
```

샘플 프로듀서는 디폴트 파티셔너를 사용해 메세지 20개를 카프카 토픽 `demo-topic`으로 전송한다. 발행한 각 메세지는 파티션과 오프셋을 콘솔에 출력한다. 위에 있는 출력 샘플에서 보이듯이 출력 결과는 메세지 발행 순서와 다를 수 있다. 메세지는 각 파티션에 순서대로 전달되지만, 다른 파티션에 전송한 메세지 결과가 중간에 끼어들 수도 있다. 이 샘플에선, 각 출력 결과와 메세지를 매칭하기 위해 메세지 인덱스를 correlation 메타데이터로 추가한다.

#### Sample Consumer

샘플 컨슈머 코드는 [github.com/reactor/reactor-kafka/blob/master/reactor-kafka-samples/src/main/java/reactor/kafka/samples/SampleConsumer.java](https://github.com/reactor/reactor-kafka/blob/master/reactor-kafka-samples/src/main/java/reactor/kafka/samples/SampleConsumer.java)를 확인해라.

샘플 컨슈머를 실행해보자:

```bash
> $KAFKA_DIR/bin/kafka-run-class.sh reactor.kafka.samples.SampleConsumer
Received message: topic-partition=demo-topic-1 offset=0 timestamp=13:33:16:716 GMT 30 Nov 2016 key=2 value=Message_2
Received message: topic-partition=demo-topic-1 offset=1 timestamp=13:33:16:716 GMT 30 Nov 2016 key=3 value=Message_3
Received message: topic-partition=demo-topic-1 offset=2 timestamp=13:33:16:716 GMT 30 Nov 2016 key=4 value=Message_4
Received message: topic-partition=demo-topic-1 offset=3 timestamp=13:33:16:716 GMT 30 Nov 2016 key=6 value=Message_6
Received message: topic-partition=demo-topic-1 offset=4 timestamp=13:33:16:716 GMT 30 Nov 2016 key=7 value=Message_7
Received message: topic-partition=demo-topic-1 offset=5 timestamp=13:33:16:716 GMT 30 Nov 2016 key=10 value=Message_10
Received message: topic-partition=demo-topic-1 offset=6 timestamp=13:33:16:716 GMT 30 Nov 2016 key=11 value=Message_11
Received message: topic-partition=demo-topic-1 offset=7 timestamp=13:33:16:717 GMT 30 Nov 2016 key=12 value=Message_12
Received message: topic-partition=demo-topic-1 offset=8 timestamp=13:33:16:717 GMT 30 Nov 2016 key=13 value=Message_13
Received message: topic-partition=demo-topic-1 offset=9 timestamp=13:33:16:717 GMT 30 Nov 2016 key=14 value=Message_14
Received message: topic-partition=demo-topic-1 offset=10 timestamp=13:33:16:717 GMT 30 Nov 2016 key=16 value=Message_16
Received message: topic-partition=demo-topic-1 offset=11 timestamp=13:33:16:717 GMT 30 Nov 2016 key=17 value=Message_17
Received message: topic-partition=demo-topic-1 offset=12 timestamp=13:33:16:717 GMT 30 Nov 2016 key=20 value=Message_20
Received message: topic-partition=demo-topic-0 offset=0 timestamp=13:33:16:712 GMT 30 Nov 2016 key=1 value=Message_1
Received message: topic-partition=demo-topic-0 offset=1 timestamp=13:33:16:716 GMT 30 Nov 2016 key=5 value=Message_5
Received message: topic-partition=demo-topic-0 offset=2 timestamp=13:33:16:716 GMT 30 Nov 2016 key=8 value=Message_8
Received message: topic-partition=demo-topic-0 offset=3 timestamp=13:33:16:716 GMT 30 Nov 2016 key=9 value=Message_9
Received message: topic-partition=demo-topic-0 offset=4 timestamp=13:33:16:717 GMT 30 Nov 2016 key=15 value=Message_15
Received message: topic-partition=demo-topic-0 offset=5 timestamp=13:33:16:717 GMT 30 Nov 2016 key=18 value=Message_18
Received message: topic-partition=demo-topic-0 offset=6 timestamp=13:33:16:717 GMT 30 Nov 2016 key=19 value=Message_19
```

샘플 컨슈머는 `demo-topic` 토픽에서 메세지를 컨슘해 콘솔에 출력한다. 프로듀서 샘플에서 발행한 메세지 20개가 콘솔에 찍힐거다. 위에 있는 출력 샘플에서 보이듯이 각 파티션의 메세지는 순서대로 컨슘하지만, 다른 파티션에서 컨슘한 메세지가 중간에 끼어들 수도 있다.

리액터 카프카 API를 사용해 어플리케이션을 빌드하려면 리액터 카프카 의존성을 넣어줘야 한다:

그래들:

```gradle
dependencies {
    compile "io.projectreactor.kafka:reactor-kafka:1.1.0.RELEASE"
}
```

메이븐:

```xml
<dependency>
    <groupId>io.projectreactor.kafka</groupId>
    <artifactId>reactor-kafka</artifactId>
    <version>1.1.0.RELEASE</version>
</dependency>
```