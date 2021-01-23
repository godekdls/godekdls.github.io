---
title: Reactive Kafka Sender & Kafka Receiver
category: Reactor Kafka
order: 7
permalink: /Reactor%20Kafka/whatsnewinreactorkafka120release/
description: KafkaSender, KafkaReceiver API 사용법 한글 번역
image: ./../../images/reactor/logo.png
lastmod: 2021-01-11T15:00:00+09:00
comments: true
priority: 0.8
originalRefName: 프로젝트 리액터 카프카
originalRefLink: https://projectreactor.io/docs/kafka/1.3.1/reference/index.html#_what_s_new_in_reactor_kafka_1_2_0_release
---

<blockquote style="background-color: #fbebf3; border-color: #d63583; padding-top: 20px; padding-bottom: 20px;">
<p>원문의 타이틀은 "<span style="font-weight: bold;">What’s new in Reactor Kafka 1.2.0.RELEASE</span>"입니다. 리액터 카프카 API에 대한 명세를 대부분 이번 챕터에 포함하고 있어 임의로 타이틀을 변경했습니다. 원문 보실 때 참고하시길 바랍니다.</p>
</blockquote>

### 목차

- [6.1. Overview](#61-overview)
- [6.2. Reactive Kafka Sender](#62-reactive-kafka-sender)
  + [6.2.1. Error handling](#621-error-handling)
  + [6.2.2. Send without result metadata](#622-send-without-result-metadata)
  + [6.2.3. Threading model](#623-threading-model)
  + [6.2.4. Non-blocking back-pressure](#624-non-blocking-back-pressure)
  + [6.2.5. Closing the KafkaSender](#625-closing-the-kafkasender)
  + [6.2.6. Access to the underlying KafkaProducer](#626-access-to-the-underlying-kafkaproducer)
- [6.3. Reactive Kafka Receiver](#63-reactive-kafka-receiver)
  + [6.3.1. Subscribing to wildcard patterns](#631-subscribing-to-wildcard-patterns)
  + [6.3.2. Manual assignment of topic partitions](#632-manual-assignment-of-topic-partitions)
  + [6.3.3. Controlling commit frequency](#633-controlling-commit-frequency)
  + [6.3.4. Auto-acknowledgement of batches of records](#634-auto-acknowledgement-of-batches-of-records)
  + [6.3.5. Disabling automatic commits](#635-disabling-automatic-commits)
  + [6.3.6. At-most-once delivery](#636-at-most-once-delivery)
  + [6.3.7. Partition assignment and revocation listeners](#637-partition-assignment-and-revocation-listeners)
  + [6.3.8. Controlling start offsets for consuming records](#638-controlling-start-offsets-for-consuming-records)
  + [6.3.9. Consumer lifecycle](#639-consumer-lifecycle)

---

1.2.0.RELEASE는 단순히 리액터 3.3.0.RELEASE 버전에 맞춰 개발했다.

---

## 6.1. Overview

이번 섹션에선 아파치 카프카를 사용해 메세지를 생산하고 컨슘하기 위한 리액티브 API를 설명한다. 리액터 카프카엔 두 가지 핵심 인터페이스가 있다:

1. 카프카에 메세지를 발행하는 <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">reactor.kafka.sender.KafkaSender</span>
2. 카프카의 메세지를 컨슘하는 <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">reactor.kafka.receiver.KafkaReceiver</span>

전체 리액터 카프카 API는 [javadocs](https://projectreactor.io/docs/kafka/1.3.1/api/index.html)에서 확인할 수 있다.

카프카 리액터는 [리액터 코어](../../Reactor%20Core/contents)로 ["리액티브 스트림"](https://github.com/reactive-streams/reactive-streams-jvm) API를 구현한다.

---

## 6.2. Reactive Kafka Sender

카프카로 보내는 아웃바운드 메세지는 <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">reactor.kafka.sender.KafkaSender</span>로 전송한다. Sender는 thread-safe하며, 여러 스레드에 공유해 처리량을 끌어올릴 수 있다. `KafkaSender`는 카프카로 메세지를 전송할 때 사용하는 `KafkaProducer` 하나와 연결된다.

`KafkaSender`는 sender 설정 옵션 <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">reactor.kafka.sender.SenderOptions</span> 인스턴스로 만든다. `KafkaSender`를 만든 후엔 `SenderOptions`를 수정해도 `KafkaSender`에 반영되지 않는다. 부트스트랩 카프카 브로커 리스트나 시리얼라이저같은 `SenderOptions`의 프로퍼티는 내부 `KafkaProducer`로 전달된다. 이런 프로퍼티는 `SenderOptions` 인스턴스 생성 시점에 만들어도 되고, 인스턴스 생성 후에 setter 메소드 `SenderOptions#producerProperty`를 사용해도 된다. 최대 in-flight 메세지 수같은 리액티브 `KafkaSender` 전용 설정 옵션도 `KafkaSender` 인스턴스를 만들기 전에 미리 설정할 수 있다.

`SenderOptions<K, V>`, `KafkaSender<K, V>`의 제네릭 타입은 `KafkaSender`로 발행할 프로듀서 레코드의 키, 값 타입이며, `KafkaSender`를 생성하기 전에 `SenderOptions` 인스턴스에 키, 값의 시리얼라이저를 설정해야 한다.

```java
Map<String, Object> producerProps = new HashMap<>();
producerProps.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers);
producerProps.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, IntegerSerializer.class);
producerProps.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class);

SenderOptions<Integer, String> senderOptions =
    SenderOptions.<Integer, String>create(producerProps)       // (1)
                 .maxInFlight(1024);                           // (2)
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `KafkaProducer`에서 사용할 프로퍼티를 지정한다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 리액티브 `KafkaSender` 전용 옵션을 설정한다</small>

필요한 옵션을 미리 `SenderOptions` 인스턴스로 정의했다면, 이 옵션으로 새 `KafkaSender` 인스턴스를 만들 수 있다.

```java
KafkaSender<Integer, String> sender = KafkaSender.create(senderOptions);
```

이제 `KafkaSender`로 카프카에 메세지를 보낼 수 있다. 내부 `KafkaProducer` 인스턴스는 첫 번째 메세지를 보낼 준비가되면 그때가서 생성한다. 이 시점에선 `KafkaSender` 인스턴스를 만들긴 했지만 아직 카프카에 연결되진 않았다.

이제 카프카로 전송할 메세지 시퀀스를 만들어보자. 카프카로 보낼 각 아웃바운드 메세지는 `SenderRecord`로 표현한다. `SenderRecord`는 카프카 [ProducerRecord](https://kafka.apache.org/0102/javadoc/org/apache/kafka/clients/producer/ProducerRecord.html)에, 레코드와 전송 결과를 매칭하기 위한 별도 correlation 메타데이터를 추가한 클래스다. `ProducerRecord`는 카프카로 보낼 키/값 쌍과, 메세지를 전송할 카프카 토픽명을 가지고 있다. 원한다면 프로듀서 레코드에 메세지를 전송할 파티션을 지정해도 되고, 설정에 있는 파티셔너가 파티션을 선택하게 둬도 된다. 레코드엔 타임스탬프도 지정할 수 있으며, 지정하지 않으면 프로듀서가 현재 타임스탬프를 할당한다. `SenderRecord`에 추가한 correlation 메타데이터는 카프카론 전송되지 않지만, send 연산자가 완료 또는 실패했을 때 해당 레코드를 보내고 받은 `SendResult`에 담긴다. 다른 파티션에 보낸 전송 결과가 중간에 끼어들 수 있기 때문에, 이 correlation 메타데이터로 전송한 레코드와 결과를 매칭한다.

카프카로 메세지를 전송하기 위해 레코드의 [Flux](https://projectreactor.io/docs/core/release/api/reactor/core/publisher/Flux.html)를 만들어 보겠다. Flux를 처음 접한다면, 리액터 클래스 `Flux`, `Mono`를 사용해볼 수 있는 실습 튜토리얼 [Lite Rx API 직접 구현해보기](https://github.com/reactor/lite-rx-api-hands-on)를 참고해라.

```java
Flux<SenderRecord<Integer, String, Integer>> outboundFlux =
    Flux.range(1, 10)
        .map(i -> SenderRecord.create(topic, partition, timestamp, i, "Message_" + i, i));
```

위 코드는 카프카로 보낼 메세지 시퀀스를 만드는 코드다. 여기서는 메세지 인덱스를 각 `SenderRecord`의 correlation 메타데이터로 사용한다. 이제 이 아웃바운드 Flux를, 앞에서 만든 `KafkaSender`를 사용해 카프카에 전송할 수 있다.

아래 코드는 카프카로 레코드를 전송하고, 카프카에서 받은 응답 메타데이터와 레코드별 correlation 메타데이터를 출력한다. 마지막에 있는 `subscribe()`가 업스트림에 카프카에 레코드를 전송하도록 요청하고, 카프카에서 받은 응답 메타데이터를 다운스트림으로 트리거한다. 각 결과를 받으면, `onNext` 핸들러가 카프카에서 받은 레코드 메타데이터와 레코드 식별을 위한 correlation 메타데이터를 콘솔에 출력한다. 카프카가 보낸 응답에는 레코드를 전송한 파티션과 레코드를 추가한 오프셋이 들어있다 (유효한 값이 있으면). 레코드들을 파티션 여러 개로 전송했다면, 각 파티션에선 순서대로 응답 받지만, 다른 파티션의 응답이 중간에 끼어들 수도 있다.

```java
sender.send(outboundFlux)                          // (1)
      .doOnError(e-> log.error("Send failed", e))  // (2)
      .doOnNext(r -> System.out.printf("Message #%d send response: %s\n", r.correlationMetadata(), r.recordMetadata())) // (3)
      .subscribe();    // (4)
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 아웃바운드 Flux를 위한 리액티브 send 연산자</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 카프카 전송에 실패하면 에러 로그를 남긴다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 카프카에서 받은 메타데이터와 `correlationMetadata()`에 있는 메세지 인덱스를 출력한다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> 구독을 통해 `outboundFlux`의 레코드를 카프카로 전송하는 실제 플로우를 트리거한다.</small>

샘플 프로듀서 전체 코드는 [github.com/reactor/reactor-kafka/blob/master/reactor-kafka-samples/src/main/java/reactor/kafka/samples/SampleProducer.java](https://github.com/reactor/reactor-kafka/blob/master/reactor-kafka-samples/src/main/java/reactor/kafka/samples/SampleProducer.java)를 확인해라.

### 6.2.1. Error handling

```java
public SenderOptions<K, V> stopOnError(boolean stopOnError);
```

`SenderOptions#stopOnError()`는 레코드 하나라도, 설정한 재시도 횟수만큼 카프카에 전송해본 뒤에도 또다시 실패하면, 전송 시퀀스를 즉시 실패시킬지, 아니면 모든 레코드를 처리할 때까지 기다릴 건지를 지정한다. `ProducerConfig#ACKS_CONFIG`, `ProducerConfig#RETRIES_CONFIG`와 함께 설정해 원하는 서비스 품질을 구현할 수 있다.

```java
<T> Flux<SenderResult<T>> send(Publisher<SenderRecord<K, V, T>> outboundRecords);
```

`stopOnError`가 false면 각 레코드를 전송할 때마다 성공 또는 에러 응답을 반환한다. 에러 응답을 받았을 땐, 카프카가 전송에 실패한 이유를 담아 보낸 exception이 `SenderResult`에 설정되며, `SenderResult#exception()`으로 조회할 수 있다. Flux는 `outboundRecords`에 발행한 모든 레코드를 전송해보고 나서 에러로 종료된다. `outboundRecords`가 종료하지 않는 `Flux`라면 send 연산자는 사용자가 직접 SenderResult `Flux`를 취소할 때까지 계속해서 `outboundRecords` `Flux`로 발행한 레코드를 전송한다.

`stopOnError`가 true면 첫 번째로 전송에 실패했을 때 응답을 반환하며, SenderResult Flux는 에러 발생 즉시 종료한다. 아웃바운드 메세지는 언제든지  여러 개가 in-flight 상태일 수 있기 때문에, 첫 번째 실패를 감지한 후에도 일부 메세지가 카프카에 전달됐을 수도 있다. in-flight 메세지 수를 제한하려면 `SenderOptions#maxInFlight()` 옵션을 설정하면 된다.

### 6.2.2. Send without result metadata

각 전송 요청마다 결과를 받지 않아도 된다면, `KafkaOutbound` 인터페이스를 사용해 correlation 메타데이터 없이 바로 `ProducerRecord`를 카프카에 전송할 수 있다. `KafkaOutbound`는 send 연산자를 체이닝할 수 있는 fluent 인터페이스다.

```java
KafkaOutbound<K, V> send(Publisher<? extends ProducerRecord<K, V>> outboundRecords);
```

send 시퀀스는 `KafkaOutbound#then()`으로 가져온 Mono를 구독할 때 시작된다. 이 Mono는 모든 아웃바운드 레코드를 문제 없이 전송하고 나면 성공으로 완료된다. 한 번이라도 전송에 실패하면 Mono는 종료된다. `outboundRecords`가 종료하지 않는 `Flux`라면, 전송에 실패하거나 반환한 `Mono`를 취소할 때까지 계속해서 레코드를 전송한다.

```java
sender.createOutbound()
      .send(Flux.range(1,  10)
                .map(i -> new ProducerRecord<Integer, String>(topic, i, "Message_" + i))) // (1)
      .then()                                                    // (2)
      .doOnError(e -> e.printStackTrace())                       // (3)
      .doOnSuccess(s -> System.out.println("Sends succeeded"))   // (4)
      .subscribe();                                              // (5)
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `ProducerRecord` 플럭스를 만든다. `SenderRecord`로 레코드를 감싸지 않는다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> `Mono`를 가져온다. 이 `Mono`를 구독하면 메세지 플로우를 시작한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 에러는 하나 이상의 레코드 전송에 실패했음을 뜻한다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> 성공은 모든 레코드를 발행했음을 뜻하며, 각 파티션이나 오프셋은 반환하지 않는다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> 구독해서 실제 전송을 요청한다</small>

`KafkaOutbound`에선 send를 여러 번 호출해 체이닝할 수 있다. `KafkaOutbound#then()`이 반환한 Mono를 구독하면, 선언한 순서대로 send를 실행한다. send 체인 중 하나라도 설정한 재시도 횟수만큼 전송했는데도 또다시 실패하면 시퀀스는 취소된다.

```java
sender.createOutbound()
      .send(flux1)                                               // (1)
      .send(flux2)
      .send(flux3)
      .then()                                                    // (2)
      .doOnError(e -> e.printStackTrace())                       // (3)
      .doOnSuccess(s -> System.out.println("Sends succeeded"))   // (4)
      .subscribe();                                              // (5)
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 순서대로 `flux1`, `flux2`, `flux3`을 전송한다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> `Mono`를 가져온다. 이 `Mono`를 구독하면 메세지 플로우 시퀀스를 시작한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 에러는 send 체인 중 하나 이상의 레코드 전송에 실패했음을 뜻한다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> 성공은 전체 체인에 있는 모든 레코드를 발행했음을 뜻한다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(6)</span> 구독해서 체인에 있는 send 시퀀스를 시작한다</small>

전송에 실패하면 무조건 `KafkaProducer`에 설정한 재시도 횟수만큼 시도해보며, 리액티브 `KafkaSender`가 실패를 반환했다는 건 설정한 재시도 횟수만큼 시도한 이후에 또다시 전송에 실패했음을 의미한다. 재시도를 했다면 메세지 순서가 다르게 전달될 수도 있다. 재정렬을 방지하려면 프로듀서 프로퍼티 `ProducerConfig#MAX_IN_FLIGHT_REQUESTS_PER_CONNECTION`을 1로 설정하면 된다.

### 6.2.3. Threading model

`KafkaProducer`는 별도 네트워크 스레드로 요청을 전송하고 응답을 처리한다. 어플리케이션에서 결과를 처리하면서 이 프로듀서 네트워크 스레드를 블로킹하지 않도록, `KafkaSender`는 별도 스케줄러로 응답을 전달한다. 기본적으로 이 스케줄러는 더 필요하지 않으면 해제하는 단일 스레드 풀을 사용하는 스케줄러다. 필요하면 스케줄러를 재정의할 수 있다. 예를 들어 카프카 전송은 파이프라인 일부이고, 실제 파이프라인은 더 큰 범위라면 병렬 스케줄러를 사용할 수 있다. 이럴땐 `KafkaSender` 인스턴스를 만들기 전에 `SenderOptions` 인스턴스에서 다음 메소드를 사용하면 된다:

```java
public SenderOptions<K, V> scheduler(Scheduler scheduler);
```

### 6.2.4. Non-blocking back-pressure

in-flight 전송 수는 `maxInFlight` 옵션으로 제어할 수 있다. 응답이 펜딩되고 있다면 보낼 수 있는 요청 수는 `maxInFlight`만큼으로 제한되서, 업스트림에선 그 이상의 요청을 보낼 수 없다. 리액티브 파이프라인에서 `KafkaSender`를 사용할 땐, 이 `maxInFlight`를 `KafkaProducer`의 `buffer.memory`, `max.block.ms` 옵션과 함께 조합해서 사용할 메모리와 스레드를 제어할 수 있다. 이 옵션은 `KafkaSender`를 생성하기 전에 `SenderOptions`에 설정하면 된다. 디폴트는 256이다. 작은 메세지라면 더 높게 설정해 처리량을 늘릴 수 있다.

```java
public SenderOptions<K, V> maxInFlight(int maxInFlight);
```

### 6.2.5. Closing the KafkaSender

`KafkaSender`를 다 썼다면 `KafkaSender` 인스턴스를 닫을 수 있다. 이렇게 하면 내부 `KafkaProducer`를 닫아, 모든 클라이언트 커넥션을 종료하고 프로듀서가 사용하는 모든 메모리를 해제한다.

```java
sender.close();
```

### 6.2.6. Access to the underlying `KafkaProducer`

리액티브 어플리케이션은 간혹, `KafkaSender` 인터페이스엔 없는 작업때문에 내부 프로듀서 인스턴스에 접근해야 할 때도 있다. 예를 들어 어플리케이션에서 레코드를 전송할 파티션을 결정하려면 토픽의 파티션 수를 알아야 한다. `send`같이 `KafkaSender`가 직접 제공하지 않는 연산은, `KafkaSender#doOnProducer`를 사용하면 내부 `KafkaProducer`로 실행할 수 있다.

```java
sender.doOnProducer(producer -> producer.partitionsFor(topic))
      .doOnSuccess(partitions -> System.out.println("Partitions " + partitions))
      .subscribe();
```

사용자가 제공한 메소드는 비동기로 실행된다. `doOnProducer`는  `Mono`를 반환하며, 이 `Mono`는 사용자가 제공한 함수가 반환한 값으로 완료된다.

---

## 6.3. Reactive Kafka Receiver

카프카 토픽에 저장된 메세지는 리액티브 리시버 <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">reactor.kafka.receiver.KafkaReceiver</span>로 컨슘한다. 각 `KafkaReceiver` 인스턴스는 단일 `KafkaConsumer` 인스턴스와 연결된다. 내부 `KafkaConsumer`는 멀티 스레드로 동시에 접근할 수 없기 때문에 `KafkaReceiver`도 thread-safe하지 않다.

리시버는 리시버 설정 옵션 <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">reactor.kafka.receiver.ReceiverOptions</span> 인스턴스로 만든다. `KafkaReceiver` 인스턴스를 만든 후엔 `ReceiverOptions`를 수정해도 `KafkaReceiver`엔 반영되지 않는다. 부트스트랩 카프카 브로커 리스트나 디시리얼라이저같은 `ReceiverOptions` 프로퍼티는 내부 `KafkaConsumer`로 전달된다. 이런 프로퍼티는 `ReceiverOptions` 인스턴스 생성 시점에 만들어도 되고, 인스턴스 생성 후에 setter 메소드 `ReceiverOptions#consumerProperty`를 사용해도 된다. 구독 토픽같은 리액티브 `KafkaReceiver`용 설정 옵션은 `KafkaReceiver` 인스턴스를 만들기 전에 추가해야 한다.

`ReceiverOptions<K, V>`, `KafkaReceiver<K, V>`의 제네릭 타입은 리시버로 컨슘할 컨슈머 레코드의 키, 값 타입이며, `KafkaReceiver`를 생성하기 전에 `ReceiverOptions` 인스턴스에 키, 값의 디시리얼라이저를 설정해야 한다.

```java
Map<String, Object> consumerProps = new HashMap<>();
consumerProps.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers);
consumerProps.put(ConsumerConfig.GROUP_ID_CONFIG, "sample-group");
consumerProps.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, IntegerDeserializer.class);
consumerProps.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);

ReceiverOptions<Integer, String> receiverOptions =
    ReceiverOptions.<Integer, String>create(consumerProps)         // (1)
                   .subscription(Collections.singleton(topic));    // (2)
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `KafkaConsumer`에 제공할 프로퍼티를 지정한다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 구독할 토픽</small>

필요한 옵션을 미리 `ReceiverOptions` 인스턴스로 정의했다면, 이 옵션으로 새 `KafkaReceiver` 인스턴스를 만들어 인바운드 메세지를 컨슘할 수 있다. 아래 코드는 리시버 인스턴스를 만들고, 리시버로 인바운드 플럭스를 만든다. 내부 `KafkaConsumer` 인스턴스는 인바운드 플럭스를 구독하면 그때가서 생성한다.

```java
Flux<ReceiverRecord<Integer, String>> inboundFlux =
    KafkaReceiver.create(receiverOptions)
                 .receive();
```

이제 인바운드 카프카 플럭스를 컨슘할 수 있다. 플럭스로 전달받는 각 인바운드 메세지는 `ReceiverRecord`로 표현한다. 각 리시버 레코드는 `KafkaConsumer`가 반환한 [ConsumerRecord](https://kafka.apache.org/0102/javadoc/org/apache/kafka/clients/consumer/ConsumerRecord.html)이며, 커밋할 수 있는 `ReceiverOffset` 인스턴스를 가지고 있다. 확인되지 않은 오프셋은 커밋하지 않으므로, 메세지를 처리하고 나면 반드시 오프셋을 처리했음을 알려야 한다 (acknowledge). 커밋 인터벌이나 커밋 배치 사이즈를 설정했다면, 확인된(acknowledged) 오프셋을 주기적으로 커밋한다. 커밋 연산을 더 세밀하게 제어해야 할 땐 `ReceiverOffset#commit()`을 사용해 수동으로 오프셋을 커밋해도 된다.

```java
inboundFlux.subscribe(r -> {
    System.out.printf("Received message: %s\n", r);           // (1)
    r.receiverOffset().acknowledge();                         // (2)
});
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 카프카로부터 받은 각 컨슈머 레코드를 출력한다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 오프셋을 커밋할 수 있게 레코드 처리를 완료했음을 알린다</small>

### 6.3.1. Subscribing to wildcard patterns

위에 있는 예제에선 단일 카프카 토픽을 구독했다. `ReceiverOptions#subscription()`에 토픽 컬렉션을 넘기면 같은 API로 둘 이상의 토픽을 구독할 수 있다. 구독할 패턴을 지정하는 식으로 와일드카드 패턴도 구독할 수 있다. `KafkaConsumer`는 그룹 관리를 통해 패턴과 매칭되는 토픽이 만들어지거나 삭제될 때 동적으로 할당된 토픽을 업데이트하며, 매칭한 토픽의 파티션을 사용 가능한 컨슈머 인스턴스에 할당한다.

```java
receiverOptions = receiverOptions.subscription(Pattern.compile("demo.*"));  // (1)
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> "demo"로 시작하는 모든 토픽 레코드를 컨슘한다</small>

`ReceiverOptions`를 수정할 게 남았다면 리시버 인스턴스를 만들기 전에 반영해야 한다. 구독을 변경하면 기존에 있던 옵션 인스턴스의 모든 구독 정보를 삭제한다.

### 6.3.2. Manual assignment of topic partitions

카프카 컨슈머 그룹 관리를 이용하는 대신, 직접 수동으로 리시버에 파티션을 할당해도 된다.

```java
receiverOptions = receiverOptions.assignment(Collections.singleton(new TopicPartition(topic, 0))); // (1)
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 지정한 토픽의 파티션 0을 컨슘한다</small>

파티션을 새로 할당하면 옵션 인스턴스에 있던 기존 구독, 할당 정보는 삭제된다. 옵션 인스턴스에 수동으로 파티션을 할당하면, 이 옵션 인스턴스로 만든 모든 리시버는 지정한 모든 파티션의 메세지를 컨슘한다.

### 6.3.3. Controlling commit frequency

커밋 주기는 커밋 인터벌과 커밋 배치 사이즈로 제어할 수 있다. 인터벌이나 배치 사이즈에 도달하면 커밋을 수행한다. 이 옵션은 리시버 인스턴스를 만들기 전에 `ReceiverOptions`에 설정하면 된다. 인터벌이나 배치 사이즈 중 하나만 설정해도 되고 둘 다 설정해도 된다. 커밋 인터벌을 설정하면, 레코드를 하나라도 컨슘했다면 해당 인터벌 내에 최소한 한 번은 커밋을 스케줄링한다. 커밋 배치 사이즈를 설정하면, 설정한 수만큼 레코드를 컨슘하고 처리했음을 알려주면(acknowledge) 커밋을 스케줄링한다.

커밋 주기를 기반으로 자동 커밋하고, 컨슘한 레코드를 다 처리한 후 수동으로 처리됐음을 알리면(acknowledge), at-least-once 딜리버리 시맨틱스가 제공된다. 메세지를 받았더라도, 컨슈밍 어플리케이션이 메세지를 처리하고 acknowledge()를 호출하기 전에 크래시가 나면, 메세지를 다시 전달한다. `ReceiverOffset#acknowledge()`를 통해 처리를 완료했음을 명시한 오프셋만 커밋된다. 주의할 점은 오프셋을 승인하면(acknowledge) 같은 파티션에 있는 이전 오프셋도 모두 승인된다. 리밸런싱 중에 파티션을 회수하거나 receive Flux가 종료할 때도 승인된 모든 오프셋을 커밋한다.

커밋 시점을 세밀하게 제어해야 하는 어플리케이션은 주기적인 커밋을 비활성화하고 커밋을 트리거해야 할 때 직접 `ReceiverOffset#commit()`을 호출하면 된다. 이때 커밋은 기본적으로 비동기로 동작하지만, 어플리케이션에서 반환된 Mono로 `Mono#block()`을 호출해 동기로 커밋할 수도 있다. 어플리케이션에서 컨슘한 메세지를 모아 승인하고(acknowledge) 주기적으로 `commit()`을 호출해 확인된(acknowledged) 오프셋을 커밋하면 일괄 커밋을 수행할 수 있다.

```java
receiver.receive()
        .doOnNext(r -> {
                process(r);
                r.receiverOffset().commit().block();
            });
```

오프셋을 커밋하면 해당 파티션에 있는 이전 오프셋도 모두 승인하고(acknowledge) 커밋한다는 점에 주의해라. 리밸런싱 중에 파티션을 회수하거나 receive Flux가 종료될 때도 모든 승인된(acknowledged) 오프셋을 커밋한다.

### 6.3.4. Auto-acknowledgement of batches of records

`KafkaReceiver#receiveAutoAck`는 `KafkaConsumer#poll()`이 반환한 각 레코드 배치를 가지고 있는 `Flux`를 반환한다. 배치마다 해당 Flux가 종료될 때 레코드를 자동으로 승인한다 (acknowledge).

```java
KafkaReceiver.create(receiverOptions)
             .receiveAutoAck()
             .concatMap(r -> r)                                      // (1)
             .subscribe(r -> System.out.println("Received: " + r));  // (2)
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 순서대로 연결한다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 전달받은 각 컨슈머 레코드를 출력하며, ack를 명시하지 않아도 된다</small>

배치 하나로 받아올 최대 레코드 수는 `KafkaConsumer` 프로퍼티 `MAX_POLL_RECORDS`로 제어할 수 있다. `KafkaConsumer`에 설정한 fetch 사이즈와 대기 시간과 함께 poll마다 카프카 브로커에서 받아 오는 데이터의 양을 제어한다. 각 배치는 해당 Flux가 종료된 후 확인 처리한(acknowledge) Flux로 반환한다. 확인된(acknowledged) 레코드는 설정한 커밋 인터벌과 배치 사이즈에 따라 주기적으로 커밋된다. 이 모드에선 어플리케이션이 acknowledge나 커밋을 직접 수행할 필요가 없기 때문에 사용하기 간편하다. 효율적이기도 하고, at-least-once 메세지 딜리버리에 활용할 수 있다.

### 6.3.5. Disabling automatic commits

카프카에 오프셋을 커밋할 필요가 없는 어플리케이션은, `KafkaReceiver#receive()`로 컨슘한 모든 레코드에서 acknowledge를 호출하지 않는 식으로 자동 커밋을 비활성화할 수 있다.

```java
receiverOptions = ReceiverOptions.<Integer, String>create()
        .commitInterval(Duration.ZERO)             // (1)
        .commitBatchSize(0);                       // (2)
KafkaReceiver.create(receiverOptions)
             .receive()
             .subscribe(r -> process(r));          // (3)
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 주기적인 커밋을 비활성화한다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 배치 사이즈 기반 커밋을 비활성화한다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 레코드를 처리하지만, 처리를 완료했다고 알리지는 않는다</small>

### 6.3.6. At-most-once delivery

레코드를 다시 전송받는 게 싫으면 자동 커밋을 비활성화할 수도 있다. `ConsumerConfig#AUTO_OFFSET_RESET_CONFIG`를 "latest"로 설정하면 새 레코드만 컨슘한다. 단, 어플리케이션이 실패해서 재기동하면 일부 레코드는 컨슘하지 않을 수 있으며 이 동작은 정확히 예측할 수 없다.

`KafkaReceiver#receiveAtmostOnce`를 사용하면 at-most-once 시맨틱스로 레코드를 컨슘하고, 어플리케이션이 실패하거나 크래시날 때 파티션 당 유실될 수 있는 레코드 수를 설정할 수 있다. 오프셋은 해당 레코드를 어플리케이션에 전달하기 전에 동기로 커밋된다. 컨슈머 어플리케이션이 실패하더라도 레코드를 재전송하지 않음을 보장하지만, 커밋한 후 레코드를 처리하기 전에 어플리케이션이 실패하면 일부 레코드는 처리하지 못할 수 있다.

이 모드에선 각 레코드를 개별적으로 커밋하고, 커밋 연산이 성공할 때까지 레코드를 전달하지 않기 때문에 비용이 많이 든다. `ReceiverOptions#atmostOnceCommitCommitAheadSize`를 설정하면 커밋 비용을 줄이고 이미 커밋한 레코드 오프셋은 전달 전에 블로킹하지 않을 수 있다. 기본적으로 commit-ahead는 비활성화되어 있으며, 어플리케이션이 크래시나는 경우 파티션 당 최대 레코드 하나가 유실된다. commit-ahead를 설정하면 파티션 당 손실될 수 있는 최대 레코드 수는 `ReceiverOptions#atmostOnceCommitCommitAheadSize + 1`이 된다.

```java
KafkaReceiver.create(receiverOptions)
             .receiveAtmostOnce()
             .subscribe(r -> System.out.println("Received: " + r));  // (1)
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 각 컨슈머 레코드를 처리한다. 처리에 실패해도 이 레코드는 재전송하지 않는다</small>

### 6.3.7. Partition assignment and revocation listeners

컨슈머에 파티션이 할당되거나 회수될 때 필요한 작업은 assignment 리스너, revocation 리스너를 통해 수행할 수 있다.

그룹 관리를 사용한다면, 리밸런스 작업 후 컨슈머에 파티션이 할당될 때마다 assignment 리스너가 호출된다. 수동으로 파티션을 할당했다면, 컨슈머가 시작될 때 assignment 리스너를 호출한다. assignment 리스너로는 할당된 파티션의 특정 오프셋을 찾아올 수 있으므로, 지정한 오프셋부터 메세지를 컨슘할 수 있다.

revocation 리스너는, 그룹 관리를 사용한다면 리밸런스 작업 후 컨슈머에서 파티션이 회수될 때마다 호출된다. 수동으로 파티션을 할당했다면, 컨슈머를 종료하기 전에 revocation 리스너를 호출한다. 수동으로 커밋할 땐 revocation 리스너를 처리한 오프셋을 커밋하는 용도로 활용할 수 있다. 자동 커밋을 활성화했다면 파티션을 회수할 때 확인된(acknowledged) 오프셋을 자동으로 커밋한다.

### 6.3.8. Controlling start offsets for consuming records

기본적으로 리시버는 파티션을 할당받으면, 해당 파티션에서 마지막으로 커밋한 오프셋부터 레코드를 컨슘하기 시작한다. 커밋된 오프셋 정보가 따로 없다면 `KafkaConsumer`에 설정한 오프셋 리셋 전략 `ConsumerConfig#AUTO_OFFSET_RESET_CONFIG`에 따라 파티션의 earliest 또는 latest 오프셋을 시작 오프셋으로 설정한다. 시작 오프셋은 assignment 리스너에서 새 오프셋을 찾아 오는 식으로 재정의할 수 있다. `ReceiverPartition`은 파티션 안에서 earliest, latest 오프셋을 찾을 수 있는 메소드를 제공하며, 오프셋을 직접 특정할 수도 있다.

```java
void seekToBeginning();
void seekToEnd();
void seek(long offset);
```

예를 들어, 다음 코드는 latest 오프셋부터 메세지 컨슘을 시작한다.

```java
receiverOptions = receiverOptions
            .addAssignListener(partitions -> partitions.forEach(p -> p.seekToEnd())) // (1)
            .subscription(Collections.singleton(topic));
KafkaReceiver.create(receiverOptions).receive().subscribe();
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 할당된 각 파티션에서 마지막 오프셋을 찾는다</small>

### 6.3.9. Consumer lifecycle

각 `KafkaReceiver` 인스턴스는 `KafkaConsumer` 하나와 연결되며, `KafkaConsumer` 인스턴스는 `KafkaReceiver`의 receive 메소드 중 하나로 반환한 인바운드 Flux를 구독할 때 생성한다. 이 컨슈머는 Flux가 완료 될 때까지 계속 살아 있다. Flux가 완료되면 확인된 모든 오프셋이 커밋되고, 내부 컨슈머도 종료한다.

`KafkaReceiver` 인스턴스 당 receive 연산은 한 번에 하나씩만 활성화할 수 있다. 모든 receive 메소드는 마지막에 반환한 receive Flux가 종료된 후에 호출할 수 있다.