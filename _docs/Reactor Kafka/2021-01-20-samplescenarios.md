---
title: Sample Scenarios
category: Reactor Kafka
order: 8
permalink: /Reactor%20Kafka/samplescenarios/
description: 리액터 카프카를 이용한 여러 가지 유스 케이스 구현 예시
image: ./../../images/reactor/logo.png
lastmod: 2021-01-11T15:00:00+09:00
comments: true
originalRefName: 프로젝트 리액터 카프카
originalRefLink: https://projectreactor.io/docs/kafka/1.3.1/reference/index.html#_sample_scenarios
---

### 목차

- [7.1. Sending records to Kafka](#71-sending-records-to-kafka)
- [7.2. Replaying records from Kafka topics](#72-replaying-records-from-kafka-topics)
- [7.3. Reactive pipeline with Kafka sink](#73-reactive-pipeline-with-kafka-sink)
- [7.4. Reactive pipeline with Kafka source](#74-reactive-pipeline-with-kafka-source)
- [7.5. Reactive pipeline with Kafka source and sink](#75-reactive-pipeline-with-kafka-source-and-sink)
- [7.6. At-most-once delivery](#76-at-most-once-delivery)
- [7.7. Fan-out with Multiple Streams](#77-fan-out-with-multiple-streams)
- [7.8. Concurrent Processing with Partition-Based Ordering](#78-concurrent-processing-with-partition-based-ordering)
- [7.9. Transactional send](#79-transactional-send)
- [7.10. Exactly-once delivery](#710-exactly-once-delivery)

---

이번 섹션에선 리액티브 카프카 API를 사용할만한 전형적인 시나리오에 필요한 샘플 코드를 보여준다. 전체 코드는 [하위 프로젝트 samples](https://github.com/reactor/reactor-kafka/tree/master/reactor-kafka-samples)에 있다.

---

## 7.1. Sending records to Kafka

KafkaSender API로 카프카에 아웃바운드 레코드를 전송하는 자세한 방법은 [KafkaSender API](../whatsnewinreactorkafka120release#62-reactive-kafka-sender)를 참고해라. 아래 코드에선 카프카로 레코드를 전송하고 그 응답을 처리하는 간단한 파이프라인을 만든다. 아웃바운드 플로우는 반환한 Flux를 구독할 때 트리거된다.

```java
KafkaSender.create(SenderOptions.<Integer, String>create(producerProps).maxInFlight(512))   // (1)
           .send(outbound.map(r -> senderRecord(r)))                                        // (2)
           .doOnNext(result -> processResponse(result))                                     // (3)
           .doOnError(e -> processError(e));
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 최대 in-flight 메세지는 512로 설정한 sender를 만든다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 센더 레코드 시퀀스를 전송한다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> onNext가 트리거되면 send 결과를 처리한다</small>

---

## 7.2. Replaying records from Kafka topics

KafkaReceiver API로 카프카 토픽에 있는 레코드를 컨슘하는 자세한 방법은 [KafkaReceiver API](../whatsnewinreactorkafka120release#63-reactive-kafka-receiver)를 참고해라. 아래 코드에선 토픽에 있는 모든 레코드를 방출하고 메세지를 처리한 후에 오프셋을 커밋하는 Flux 하나를 만든다. 수동으로 acknowledge()를 호출해 at-least-once 딜리버리 시맨틱스를 제공한다.

```java
ReceiverOptions<Integer, String> options =
    ReceiverOptions.<Integer, String>create(consumerProps)
                   .consumerProperty(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest")  // (1)
                   .commitBatchSize(10)                                                    // (2)
                   .subscription(Collections.singleton("demo-topic"));                     // (3)
KafkaReceiver.create(options)
             .receive()
             .doOnNext(r -> {
                     processRecord(r);                   // (4)
                     r.receiverOffset().acknowledge();   // (5)
                 });
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 커밋한 오프셋을 찾을 수 없다면 각 파티션에서 가장 앞에 있는 오프셋부터 컨슈밍을 시작한다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 10개의 메세지를 승인(acknowledge)할 때마다 커밋한다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 컨슘할 토픽들</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> 카프카에서 컨슘한 레코드를 처리한다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> 레코드를 컨슘했음을 알린다 (acknowledge)</small>

---

## 7.3. Reactive pipeline with Kafka sink

아래 코드에선 외부 소스의 메세지를 컨슘하고, 적절히 변환한 뒤 다시 카프카에 저장한다. 일시적인 오류로 파이프라인이 중단되지 않도록 카프카 프로듀서 재시도 횟수를 큰 수로 설정한다. 소스 데이터는 카프카에 정상적으로 레코드를 기록한 후에만 커밋한다. 

```java
senderOptions = senderOptions
    .producerProperty(ProducerConfig.ACKS_CONFIG, "all")                  // (1)
    .producerProperty(ProducerConfig.RETRIES_CONFIG, Integer.MAX_VALUE)   // (2)
    .maxInFlight(128);                                                    // (3)
KafkaSender.create(senderOptions)
           .send(source.flux().map(r -> transform(r)))                      // (4)
           .doOnError(e-> log.error("Send failed, terminating.", e))        // (5)
           .doOnNext(r -> source.commit(r.correlationMetadata()));          // (6)
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 카프카는 메세지를 모든 ISR(in-sync replica)에 전달한 뒤에 acks=all로 전송을 승인한다(acknowlege)</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 브로커가 일시적으로 실패했을 때를 대응하기 위해 프로듀서 재시도 횟수를 큰 수로 지정한다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 프로듀서 버퍼가 가득차 파이프라인을 블로킹하지 않도록 최대 in-flight 수를 낮게 잡는다. 디폴트로 stopOnError는 true로 설정된다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> 외부 소스에서 데이터를 받아, 적절히 변환한 뒤 카프카에 전송한다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> 전송에 실패하면 치명적인 에러로 간주하고 전체 파이프라인을 실패시킨다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(6)</span> 센더 레코드에 있는 correlation 메타데이터로 소스 레코드를 커밋한다</small>

---

## 7.4. Reactive pipeline with Kafka source

아래 코드는 카프카 토픽 레코드를 컨슘하고, 레코드를 변환한 다음 외부 싱크로 전송한다. 카프카 컨슈머 오프셋은 레코드를 싱크에 문제없이 출력한 후에 커밋한다.

```java
receiverOptions = receiverOptions
    .commitInterval(Duration.ZERO)              // (1)
    .commitBatchSize(0)                         // (2)
    .subscription(Pattern.compile(topics));     // (3)
KafkaReceiver.create(receiverOptions)
             .receive()
             .publishOn(Schedulers.newSingle("sample", true))
             .concatMap(m -> sink.store(transform(m))                                   // (4)
                               .doOnSuccess(r -> m.receiverOffset().commit().block())); // (5)
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 주기적인 커밋을 비활성화한다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 배치 사이즈 기반 커밋을 비활성화한다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 와일드카드 구독</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> 카프카 레코드를 변환해서 외부 싱크에 저장한다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> 레코드를 싱크에 전송하는 데 성공하면 동기로 커밋한다</small>

---

## 7.5. Reactive pipeline with Kafka source and sink

아래 코드는 카프카 토픽 메세지를 컨슘하고, 수신한 메세지를 적절히 변환한 뒤 그 결과를 다른 카프카 토픽에 저장한다. 수동 acknowledgement 모드에서 출력 레코드를 카프카에 전달한 후에 메세지를 확인하면(acknowledge) at-least-once 시맨틱스를 제공한다. 확인된 오프셋은 설정한 커밋 인터벌에 따라 주기적으로 커밋된다.

```java
receiverOptions = receiverOptions
    .commitInterval(Duration.ofSeconds(10))        // (1)
    .subscription(Pattern.compile(topics));
sender.send(KafkaReceiver.create(receiverOptions)
                         .receive()
                         .map(m -> SenderRecord.create(transform(m.value()), m.receiverOffset())))  // (2)
      .doOnNext(m -> m.correlationMetadata().acknowledge());  // (3)
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 자동 커밋 인터벌을 설정한다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 수신한 레코드를 변환하고 아웃바운드 레코드를 만든다. 이땐 변환된 데이터를 프로듀서 레코드로, 인바운드 오프셋을 correlation 메타데이터로 사용한다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 아웃바운드 레코드를 카프카에 전달한 후 correlation 메타데이터로 사용한 오프셋 인스턴스를 통해 인바운드 오프셋을 확인한다(acknowledge).</small>

---

## 7.6. At-most-once delivery

아래 코드는 at-most once 딜리버리 플로우를 시연한다. 프로듀서는 acks를 기다리지 않으며, 전혀 재시도하지 않는다. 첫 번째 시도에서 카프카에 전달하지 못한 메세지는 유실된다. 컨슈머가 재시작해도 메세지를 다시 전달하지 않도록, `KafkaReceiver`는 어플리케이션에 메세지를 전달하기 전에 오프셋을 커밋한다. 이 코드는 토픽 파티션 replication factor를 1로 지정해 at-most-once 딜리버리에 사용할 수 있다.

```java
senderOptions = senderOptions
    .producerProperty(ProducerConfig.ACKS_CONFIG, "0")     // (1)
    .producerProperty(ProducerConfig.RETRIES_CONFIG, "0")  // (2)
    .stopOnError(false);                                   // (3)
receiverOptions = receiverOptions
    .subscription(Collections.singleton(sourceTopic));
KafkaSender.create(senderOptions)
            .send(KafkaReceiver.create(receiverOptions)
                               .receiveAtmostOnce()              // (4)     
                               .map(cr -> SenderRecord.create(transform(cr.value()), cr.offset())));
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> acks=0일 땐 메세지를 카프카 브로커에 전달하기 전에 버퍼에만 담으면 전송이 끝난 것으로 간주한다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 프로듀서는 재시도하지 않는다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 모든 에러는 무시하고 남은 레코드 전송을 이어간다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> 최대 한 번만 수신한다</small>

---

## 7.7. Fan-out with Multiple Streams

아래 코드는 동일한 레코드를 여러 가지 독립적인 스트림으로 처리하는 일대다(fan-out)를 시연한다. 각 스트림은 다른 스레드에서 처리되며, 입력 레코드를 변환해 카프카 토픽에 저장한다.

리액터의 [EmitterProcessor](https://projectreactor.io/docs/core/release/api/reactor/core/publisher/EmitterProcessor.html)는 카프카에서 받은 입력 레코드를 여러 구독자에게 브로드캐스트하는 용도로 사용한다.

```java
EmitterProcessor<Person> processor = EmitterProcessor.create();         // (1)
BlockingSink<Person> incoming = processor.connectSink();                // (2)
inputRecords = KafkaReceiver.create(receiverOptions)
                            .receive()
                            .doOnNext(m -> incoming.emit(m.value()));   // (3)

outputRecords1 = processor.publishOn(scheduler1).map(p -> process1(p)); // (4)
outputRecords2 = processor.publishOn(scheduler2).map(p -> process2(p)); // (5)

Flux.merge(sender.send(outputRecords1), sender.send(outputRecords2))
    .doOnSubscribe(s -> inputRecords.subscribe())
    .subscribe();                                                       // (6)
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 카프카 인바운드 레코드를 일대다(fan-out)로 처리하기 위한 publish/subscribe EmitterProcessor를 생성한다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 메세지를 방출할 BlockingSink를 만든다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 카프에서 메세지를 받아 BlockingSink로 방출한다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> 스케줄러에서 레코드를 컨슘하고, 적절히 처리해 카프카로 전송할 출력 레코드를 만든다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> 같은 인풋 데이터에 다른 스케줄러를 사용하는 또 다른 프로세서를 추가한다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(6)</span> 스트림을 병합하고 구독해서 플로우를 시작한다</small>

---

## 7.8. Concurrent Processing with Partition-Based Ordering

아래 코드는 카프카 토픽 메세지를 컨슘하고, 메세지를 멀티 스레드로 처리해 그 결과를 다른 카프카 토픽에 저장하는 플로우를 시연한다. 메세지를 파티션별로 그룹화해 메세지를 처리하고 커밋하는 순서를 보장한다. 각 파티션 내 메세지는 단일 스레드에서 처리된다.

```java
Scheduler scheduler = Schedulers.newElastic("sample", 60, true);
KafkaReceiver.create(receiverOptions)
             .receive()
             .groupBy(m -> m.receiverOffset().topicPartition())                  // (1)
             .flatMap(partitionFlux ->
                 partitionFlux.publishOn(scheduler)
                              .map(r -> processRecord(partitionFlux.key(), r))
                              .sample(Duration.ofMillis(5000))                   // (2)
                              .concatMap(offset -> offset.commit()));            // (3)
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 파티션으로 그룹을 나눠 순서를 보장한다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 주기적으로 커밋한다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> concatMap을 사용해 순서대로 커밋한다</small>

---

## 7.9. Transactional send

아래 코드는 외부 소스에서 메세지를 컨슘하고, 적절히 변환한 뒤, 변환한 레코드 여러 개를 묶어 한 트랜잭션 내에서 서로 다른 카프카 토픽에 저장한다.

```java
senderOptions = senderOptions
    .producerProperty(ProducerConfig.TRANSACTIONAL_ID_CONFIG, "SampleTxn");       // (1)
KafkaSender.create(senderOptions)
           .sendTransactionally(source.map(r -> Flux.fromIterable(transform(r)))) // (2)
           .concatMap(r -> r)
           .doOnError(e-> log.error("Send failed, terminating.", e))
           .doOnNext(r -> log.debug("Send completed {}", r.correlationMetadata());
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 프로듀서에 트랜잭션 id를 설정한다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 각 소스 레코드로 만든 여러 레코드를 한 트랜잭션으로 묶어 전송한다</small>

---

## 7.10. Exactly-once delivery

아래 코드는 exactly once 딜리버리 플로우를 시연한다. 카프카 토픽에서 받은 소스 레코드는 적절히 변환한 뒤 카프카로 전송한다. 레코드의 각 배치는 새 트랜잭션으로 어플리케이션에 전달된다. 각 배치의 소스 레코드 오프셋은 해당 트랜잭션 내에서 자동으로 커밋된다. 각 트랜잭션은 해당 배치에 있는 레코드를 변환해서 목적지 토픽으로 문제 없이 전달한 뒤에 어플리케이션에서 직접 커밋한다. 그다음 레코드 배치는 현재 트랜잭션이 커밋된 후에 새 트랜잭션으로 어플리케이션에 전달된다.

```java
senderOptions = senderOptions
    .producerProperty(ProducerConfig.TRANSACTIONAL_ID_CONFIG, "SampleTxn");    // (1)
receiverOptions = receiverOptions
    .consumerProperty(ConsumerConfig.ISOLATION_LEVEL_CONFIG, "read_committed") // (2)
    .subscription(Collections.singleton(sourceTopic));
sender = KafkaSender.create(senderOptions);
transactionManager = sender.transactionManager();
receiver.receiveExactlyOnce(transactionManager)                                // (3)
        .concatMap(f -> sender.send(f.map(r -> transform(r)))                  // (4)
                              .concatWith(transactionManager.commit()))        // (5)
        .onErrorResume(e -> transactionManager.abort().then(Mono.error(e)))    // (6)
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 프로듀서에 트랜잭션 id를 설정한다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 커밋된 메세지만 컨슘한다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 트랜잭션 내에서 정확히 한 번만 수신하며, 오프셋은 트랜잭션을 커밋할 때 자동으로 커밋된다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> 소스 레코드 오프셋과 동일한 트랜잭션 내에서 변환한 레코드를 전송한다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> 문제 없이 전송하고 나면 트랜잭션을 커밋한다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(6)</span> 전송에 실패하면 트랜잭션을 중단하고 에러를 전파한다</small>