---
title: Sending Messages
category: Spring for Apache Kafka
order: 10
permalink: /Spring for Apache Kafka/sending-messages/
description: 스프링 카프카로 메시지 전송하기
image: ./../../images/spring/logo.png
lastmod: 2025-09-12T23:34:00+09:00
comments: true
originalRefName: 스프링 카프카
originalRefLink: https://docs.spring.io/spring-kafka/reference/kafka/sending-messages.html
parent: Reference
parentUrl: /Spring for Apache Kafka/reference/
subparent: Using Spring for Apache Kafka
subparentUrl: /Spring for Apache Kafka/kafka/
---
<script>defaultLanguages = ['java']</script>

---

이번 섹션에선 메시지를 전송하는 방법을 설명한다.

### 목차

- [Using KafkaTemplate](#using-kafkatemplate)
  + [Overview](#overview)
  + [Examples](#examples)
- [Using RoutingKafkaTemplate](#using-routingkafkatemplate)
- [Using DefaultKafkaProducerFactory](#using-defaultkafkaproducerfactory)
- [Using ReplyingKafkaTemplate](#using-replyingkafkatemplate)
    + [Request/Reply with Message<?>s](#requestreply-with-messages)
- [Reply Type Message<?>](#reply-type-message)
    + [Original Record Key in Reply](#original-record-key-in-reply)
- [Aggregating Multiple Replies](#aggregating-multiple-replies)

---

## Using `KafkaTemplate`

이번 섹션에선 `KafkaTemplate`을 사용해 메시지를 전송하는 방법에 대해 설명한다.

### Overview

`KafkaTemplate`은 프로듀서를 감싸고 있어서, 간편하게 카프카 토픽에 데이터를 전송할 수 있는 메소드를 제공한다. 다음은 `KafkaTemplate`에 있는 관련 메소드들이다:

```java
CompletableFuture<SendResult<K, V>> sendDefault(V data);

CompletableFuture<SendResult<K, V>> sendDefault(K key, V data);

CompletableFuture<SendResult<K, V>> sendDefault(Integer partition, K key, V data);

CompletableFuture<SendResult<K, V>> sendDefault(Integer partition, Long timestamp, K key, V data);

CompletableFuture<SendResult<K, V>> send(String topic, V data);

CompletableFuture<SendResult<K, V>> send(String topic, K key, V data);

CompletableFuture<SendResult<K, V>> send(String topic, Integer partition, K key, V data);

CompletableFuture<SendResult<K, V>> send(String topic, Integer partition, Long timestamp, K key, V data);

CompletableFuture<SendResult<K, V>> send(ProducerRecord<K, V> record);

CompletableFuture<SendResult<K, V>> send(Message<?> message);

Map<MetricName, ? extends Metric> metrics();

List<PartitionInfo> partitionsFor(String topic);

<T> T execute(ProducerCallback<K, V, T> callback);

<T> T executeInTransaction(OperationsCallback<K, V, T> callback);

// Flush the producer.
void flush();

interface ProducerCallback<K, V, T> {

    T doInKafka(Producer<K, V> producer);

}

interface OperationsCallback<K, V, T> {

    T doInOperations(KafkaOperations<K, V> operations);

}
```

자세한 내용은 [Javadoc](https://docs.spring.io/spring-kafka/docs/4.0.0/api/org/springframework/kafka/core/KafkaTemplate.html)을 참고해라.

`sendDefault` API를 사용하려면 템플릿에 디폴트 토픽을 지정해야 한다.

이 API는 파라미터로 `timestamp`를 받아 레코드에 함꼐 저장한다. 사용자가 제공한 타임스탬프를 저장하는 방식은 카프카 토픽에 타임스탬프 타입을 어떻게 설정했느냐에 따라 달라진다. `CREATE_TIME`을 사용하도록 토픽을 설정했다면, 사용자가 지정한 타임스탬프를 기록한다 (지정하지 않은 경우엔 자동으로 만들어진다). 토픽을 `LOG_APPEND_TIME`을 사용하도록 설정했다면, 사용자가 지정한 타임스탬프는 무시하고 브로커가 브로커의 로컬 시간을 추가한다.

`metrics`, `partitionsFor` 메소드는 내부 [`Producer`](https://kafka.apache.org/41/javadoc/org/apache/kafka/clients/producer/Producer.html)에 있는 동일한 메소드에 위임한다. `execute` 메소드를 이용하면 내부 [`Producer`](https://kafka.apache.org/41/javadoc/org/apache/kafka/clients/producer/Producer.html)에 직접 접근할 수 있다.

> 스프링 컴포넌트로 메시지를 전송할 때, `NewTopic` 빈을 통해 자동으로 토픽을 생성하고 있다면 `@PostConstruct` 메소드 사용은 피하는 게 좋다. `@PostConstruct`는 애플리케이션 컨텍스트가 완전히 준비되기 전에 실행되기 때문에, 토픽이 하나도 없는 초기 브로커에서는 `UnknownTopicOrPartitionException`이 발생할 수 있다.
>
> 대신에 이 방법들을 고려해봐라:
>
> - 메시지를 전송하기 전에 `ApplicationListener<ContextRefreshedEvent>`를 사용해 컨텍스트가 완전히 리프레시됐는지 체크한다.
> - `KafkaAdmin` 빈이 초기화를 마친 후에 시작할 수 있도록 `SmartLifecycle`을 구현한다.
> - 외부에서 토픽을 미리 생성한다.

템플릿을 사용하고 싶다면, 프로듀서 팩토리를 하나 구성하고 템플릿의 생성자로 제공해주면 된다. 그 방법은 다음 예시를 참고해라:

```java
@Bean
public ProducerFactory<Integer, String> producerFactory() {
    return new DefaultKafkaProducerFactory<>(producerConfigs());
}

@Bean
public Map<String, Object> producerConfigs() {
    Map<String, Object> props = new HashMap<>();
    props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
    props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, IntegerSerializer.class);
    props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class);
    // See https://kafka.apache.org/41/documentation/#producerconfigs for more properties
    return props;
}

@Bean
public KafkaTemplate<Integer, String> kafkaTemplate() {
    return new KafkaTemplate<Integer, String>(producerFactory());
}
```

2.5 버전부터는 팩토리의 `ProducerConfig` 프로퍼티를 재정의하면, 동일한 팩토리를 이용해 다른 프로듀서 설정을 가진 템플릿을 만들 수 있다.

```java
@Bean
public KafkaTemplate<String, String> stringTemplate(ProducerFactory<String, String> pf) {
    return new KafkaTemplate<>(pf);
}

@Bean
public KafkaTemplate<String, byte[]> bytesTemplate(ProducerFactory<String, byte[]> pf) {
    return new KafkaTemplate<>(pf,
            Collections.singletonMap(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, ByteArraySerializer.class));
}
```

`ProducerFactory<?, ?>` 타입의 빈(스프링 부트에서 자동 설정된 빈 등)은 좀 더 구체적인 제네릭 타입으로도 참조할 수 있다.

표준 `<bean/>` 정의를 사용해 템플릿을 설정하는 방법도 있다.

그런 다음 템플릿 메소드 중 원하는 것을 호출하면 된다.

`Message<?>` 파라미터를 받는 메소드를 사용한다면, 메시지 헤더에는 다음 항목으로 토픽, 파티션, 키, 타임스탬프 정보를 제공할 수 있다:

- `KafkaHeaders.TOPIC`
- `KafkaHeaders.PARTITION`
- `KafkaHeaders.KEY`
- `KafkaHeaders.TIMESTAMP`

메시지의 payload는 실제 전송되는 데이터다.

원한다면 `KafkaTemplate`에 `ProducerListener`를 설정해서, `Future`가 완료될 때까지 기다리는 대신 전송 결과(성공 또는 실패)를 비동기로 콜백받을 수도 있다. `ProducerListener` 인터페이스는 다음과 같이 정의돼 있다:

```java
public interface ProducerListener<K, V> {

    default void onSuccess(ProducerRecord<K, V> producerRecord, RecordMetadata recordMetadata) {
	}

    default void onError(ProducerRecord<K, V> producerRecord, RecordMetadata recordMetadata, Exception exception) {
	}

}
```

기본적으로는 전송에 성공하면 아무 일도 하지 않고 에러만 로그에 남기는 `LoggingProducerListener`가 세팅된다.

이 메소드들 중 딱 하나만 구현하고 싶은 경우를 위해 디폴트 메소드 구현체도 제공하고 있다.

send 메소드는 `CompletableFuture<SendResult>`를 반환한다는 점에 주의해라. 리스너에 콜백을 등록하면 비동기로 전송 결과를 수신할 수 있다. 그 방법은 다음 예제를 참고해라:

```java
CompletableFuture<SendResult<Integer, String>> future = template.send("myTopic", "something");
future.whenComplete((result, ex) -> {
    ...
});
```

`SendResult`에는 `ProducerRecord`와 `RecordMetadata`라는 두 개의 프로퍼티가 있다. 이 객체에 대한 정보는 Kafka API 문서를 참고해라.

`Throwable`은 `KafkaProducerException`으로 캐스팅할 수 있는데,  `KafkaProducerException`은 `producerRecord` 프로퍼티에 실패한 레코드를 가지고 있다.

결과를 기다리는 동안 전송 스레드를 블로킹하고 싶다면, future의 `get()` 메소드를 호출하면 된다. 이 메소드는 타임아웃을 지정하는 버전으로 사용하는 게 좋다. `linger.ms`를 설정한 경우 기다리기 전에 먼저 `flush()`를 호출하는 것이 좋고, 아니면 템플릿에 `autoFlush` 파라미터를 받는 생성자가 있어서, 메시지를 전송할 때마다 템플릿이 `flush()` 하도록 만들 수 있다. 플러시는 프로듀서 프로퍼티 `linger.ms`를 설정해서, 일정 시간이 지나면 배치가 꽉 차지 않아도 바로 전송하려는 경우에만 필요하다.

### Examples

다음은 카프카로 메시지를 전송하는 예시다:

*Example 1. Non Blocking (Async)*

```java
public void sendToKafka(final MyOutputData data) {
    final ProducerRecord<String, String> record = createRecord(data);

    CompletableFuture<SendResult<String, String>> future = template.send(record);
    future.whenComplete((result, ex) -> {
        if (ex == null) {
            handleSuccess(data);
        }
        else {
            handleFailure(data, record, ex);
        }
    });
}
```

*Blocking (Sync)*

```java
public void sendToKafka(final MyOutputData data) {
    final ProducerRecord<String, String> record = createRecord(data);

    try {
        template.send(record).get(10, TimeUnit.SECONDS);
        handleSuccess(data);
    }
    catch (ExecutionException e) {
        handleFailure(data, record, e.getCause());
    }
    catch (TimeoutException | InterruptedException e) {
        handleFailure(data, record, e);
    }
}
```

`ExecutionException`의 cause는 `producerRecord` 프로퍼티를 가지고 있는 `KafkaProducerException`이라는 점에 주목해라.

---

## Using `RoutingKafkaTemplate`

2.5 버전부터는 `RoutingKafkaTemplate`을 사용해 런타임에 대상 `topic`의 이름을 기준으로 프로듀서를 선택할 수 있다.

> 라우팅 템플릿은 대상 토픽을 알 수 없기 때문에 트랜잭션이나 `execute`, `flush`, `metrics` 같은 동작을 지원하지 **않는다**.

이때 템플릿은 `java.util.regex.Pattern`이 키, `ProducerFactory<Object, Object>` 인스턴스가 값인 맵이 필요하다. 이 맵은 순서대로 탐색하기 때문에, 순서가 유지되는 자료구조여야 하며 (e.g. `LinkedHashMap`), 더 구체적인 패턴을 앞쪽에 추가해야 한다.

다음은 동일한 템플릿을 사용해 여러 가지 토픽에 각각 다른 value serializer로 메시지를 전송하는 간단한 스프링 부트 애플리케이션 예제다.

```java
@SpringBootApplication
public class Application {

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }

    @Bean
    public RoutingKafkaTemplate routingTemplate(GenericApplicationContext context,
            ProducerFactory<Object, Object> pf) {

        // Clone the PF with a different Serializer, register with Spring for shutdown
        Map<String, Object> configs = new HashMap<>(pf.getConfigurationProperties());
        configs.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, ByteArraySerializer.class);
        DefaultKafkaProducerFactory<Object, Object> bytesPF = new DefaultKafkaProducerFactory<>(configs);
        context.registerBean("bytesPF", DefaultKafkaProducerFactory.class, () -> bytesPF);

        Map<Pattern, ProducerFactory<Object, Object>> map = new LinkedHashMap<>();
        map.put(Pattern.compile("two"), bytesPF);
        map.put(Pattern.compile(".+"), pf); // Default PF with StringSerializer
        return new RoutingKafkaTemplate(map);
    }

    @Bean
    public ApplicationRunner runner(RoutingKafkaTemplate routingTemplate) {
        return args -> {
            routingTemplate.send("one", "thing1");
            routingTemplate.send("two", "thing2".getBytes());
        };
    }

}
```

이 예제에 상응하는 `@KafkaListener`는 [어노테이션 프로퍼티](https://docs.spring.io/spring-kafka/reference/kafka/receiving-messages/listener-annotation.html#annotation-properties) 챕터에서 확인할 수 있다.

비슷한 결과를 얻을 수 있지만, 같은 토픽에 다른 타입을 전송하는 것과 같은 추가 기능이 있는 다른 기법도 있다. 이에 대해서는 [Serializer와 Deserializer에 위임하기](https://docs.spring.io/spring-kafka/reference/kafka/serdes.html#delegating-serialization)를 참고해라.

---

## Using `DefaultKafkaProducerFactory`

[`KafkaTemplate` 사용하기](#using-kafkatemplate)에서 본 것과 같이, 프로듀서를 생성할 때는 `ProducerFactory`를 사용한다.

[트랜잭션](https://docs.spring.io/spring-kafka/reference/kafka/transactions.html)을 사용하지 않는 경우, `DefaultKafkaProducerFactory`는 기본적으로 `KafkaProducer` JavaDoc에서 권장하는 대로 모든 클라이언트에서 사용하는 싱글톤 프로듀서를 생성한다. 하지만 템플릿에서 `flush()`를 호출하면 같은 프로듀서를 사용하는 다른 스레드에 지연이 생길 수도 있다. 2.3 버전부터 `DefaultKafkaProducerFactory`는 새로운 프로퍼티 `producerPerThread`를 가지고 있다. 이 프로퍼티를 `true`로 설정하면, 팩토리는 이 문제를 방지할 수 있도록 각 스레드마다 별도의 프로듀서를 생성(및 캐시)한다.

> `producerPerThread`를 `true`로 설정한 경우, 프로듀서를 다 사용했다면 **반드시** 팩토리에서 `closeThreadBoundProducer()`를 호출해 줘야 한다. 그러면 프로듀서가 물리적으로 닫히고 `ThreadLocal`에서 제거된다. 이 프로듀서들은 `reset()`이나 `destroy()`를 호출해도 정리되지 않는다.

[`KafkaTemplate`의 트랜잭션<sup>Transactional</sup> 발행과 비트랜잭션<sup>non-Transactional</sup> 발행](https://docs.spring.io/spring-kafka/reference/kafka/transactions.html#tx-template-mixed)도 함께 참고해라.

`DefaultKafkaProducerFactory`를 생성할 때는, 프로퍼티 맵만 받는 생성자를 사용하면 사용할 키/값 `Serializer` 클래스를 선택할 수 있고 ([`KafkaTemplate` 사용하기](#using-kafkatemplate)에 있는 예시 참고), 아니면  `DefaultKafkaProducerFactory` 생성자로 `Serializer` 인스턴스를 직접 전달할 수도 있다 (이 경우 모든 `Producer`가 동일한 인스턴스를 공유한다). 또는 각 `Producer`마다 별도의 `Serializer` 인스턴스를 획득할 수 있도록 `Supplier<Serializer>`를 제공하는 방법도 있다 (2.3 버전부터):

```java
@Bean
public ProducerFactory<Integer, CustomValue> producerFactory() {
    return new DefaultKafkaProducerFactory<>(producerConfigs(), null, () -> new CustomValueSerializer());
}

@Bean
public KafkaTemplate<Integer, CustomValue> kafkaTemplate() {
    return new KafkaTemplate<Integer, CustomValue>(producerFactory());
}
```

2.5.10 버전부터는 팩토리를 생성한 이후에도 프로듀서 프로퍼티를 수정할 수 있다. 예를 들면, 자격 증명이 변경된 이후 SSL 키나 인증서 저장소 위치를 업데이트해야 하는 경우에 유용할 수 있다. 변경 사항은 기존 프로듀서 인스턴스에는 영향을 미치지 않기 때문에, `reset()`을 호출해 기존 프로듀서를 닫아주면 새로운 프로퍼티로 새 프로듀서가 생성된다.

> 트랜잭션 프로듀서 팩토리를 비트랜잭션으로 변경할 수는 없으며, 그 반대도 마찬가지다.

이제 두 가지 새로운 메소드를 제공한다:

```java
void updateConfigs(Map<String, Object> updates);

void removeConfig(String configKey);
```

2.8 버전부터 (생성자 또는 setter를 통해) serializer 객체를 제공하면, 팩토리에서 설정 프로퍼티를 사용해 `configure()` 메소드를 호출해 serializer를 세팅한다.

---

## Using `ReplyingKafkaTemplate`

2.1.3 버전에서는 요청/응답<sup>request/reply</sup> 동작 방식을 지원하기 위해 `KafkaTemplate`의 서브클래스를 도입했다. 새 클래스의 이름은 `ReplyingKafkaTemplate`으로, 다음과 같은 메소드 시그니처를 가진 두 개의 메소드를 추가로 가지고 있다:

```java
RequestReplyFuture<K, V, R> sendAndReceive(ProducerRecord<K, V> record);

RequestReplyFuture<K, V, R> sendAndReceive(ProducerRecord<K, V> record,
    Duration replyTimeout);
```

([`Message`를 사용한 요청/응답<sup>Request/Reply</sup>](#requestreply-with-messages))도 함께 참고해라.

이 메소드는 비동기로 값이(타임아웃이 발생하면 예외가) 채워지는 `CompletableFuture`를 반환한다.
여기에는 `KafkaTemplate.send()`를 호출한 결과를 담는 `sendFuture` 프로퍼티가 포함돼 있다.
 이 `sendFuture`를 사용하면 send 작업이 어떻게 처리되었는지 판단할 수 있다.

첫 번째 메소드를 호출하거나, `replyTimeout` 인자를 `null`로 넘기면, 템플릿의 `defaultReplyTimeout` 프로퍼티를 사용한다 (기본 설정은 5초다).

2.8.8 버전부터 템플릿에 `waitForAssignment`라는 새 메소드가 추가됐다. reply 컨테이너를 `auto.offset.reset=latest`로 설정한 경우, 이 메소드를 이용하면 컨테이너가 초기화되기 전에 요청을 보내고 응답이 먼저 도착해 버리는 상황을 방지할 수 있다.

> 그룹 관리 없이 수동으로 파티션을 할당하는 경우, 대기 시간은 반드시 컨테이너의 `pollTimeout` 프로퍼티보다 커야 한다. 첫 번째 poll이 완료된 이후에야 할당 완료 알림을 받을 수 있기 때문이다.

다음은 이 기능을 사용하는 스프링 부트 애플리케이션 예시다:

```java
@SpringBootApplication
public class KRequestingApplication {

    public static void main(String[] args) {
        SpringApplication.run(KRequestingApplication.class, args).close();
    }

    @Bean
    public ApplicationRunner runner(ReplyingKafkaTemplate<String, String, String> template) {
        return args -> {
            if (!template.waitForAssignment(Duration.ofSeconds(10))) {
                throw new IllegalStateException("Reply container did not initialize");
            }
            ProducerRecord<String, String> record = new ProducerRecord<>("kRequests", "foo");
            RequestReplyFuture<String, String, String> replyFuture = template.sendAndReceive(record);
            SendResult<String, String> sendResult = replyFuture.getSendFuture().get(10, TimeUnit.SECONDS);
            System.out.println("Sent ok: " + sendResult.getRecordMetadata());
            ConsumerRecord<String, String> consumerRecord = replyFuture.get(10, TimeUnit.SECONDS);
            System.out.println("Return value: " + consumerRecord.value());
        };
    }

    @Bean
    public ReplyingKafkaTemplate<String, String, String> replyingTemplate(
            ProducerFactory<String, String> pf,
            ConcurrentMessageListenerContainer<String, String> repliesContainer) {

        return new ReplyingKafkaTemplate<>(pf, repliesContainer);
    }

    @Bean
    public ConcurrentMessageListenerContainer<String, String> repliesContainer(
            ConcurrentKafkaListenerContainerFactory<String, String> containerFactory) {

        ConcurrentMessageListenerContainer<String, String> repliesContainer =
                containerFactory.createContainer("kReplies");
        repliesContainer.getContainerProperties().setGroupId("repliesGroup");
        repliesContainer.setAutoStartup(false);
        return repliesContainer;
    }

    @Bean
    public NewTopic kRequests() {
        return TopicBuilder.name("kRequests")
            .partitions(10)
            .replicas(2)
            .build();
    }

    @Bean
    public NewTopic kReplies() {
        return TopicBuilder.name("kReplies")
            .partitions(10)
            .replicas(2)
            .build();
    }

}
```

스프링 부트가 자동 설정한 컨테이너 팩토리를 사용해 reply 컨테이너를 생성할 수 있다는 점에 주목하자.

응답에 복잡한 deserializer를 사용하는 경우, 설정한 deserializer에 동작을 위임하는 [`ErrorHandlingDeserializer`](https://docs.spring.io/spring-kafka/reference/kafka/serdes.html#error-handling-deserializer)를 고려해보는 것이 좋다. 이렇게 구성하면 `RequestReplyFuture`는 예외 상태로 끝날 수 있으며, 이때 발생한 `ExecutionException`을 캐치하면 `cause` 프로퍼티에 `DeserializationException`이 들어 있다.

2.6.7 버전부터 템플릿은 `DeserializationException` 감지에 더해, (설정했다면) `replyErrorChecker` 함수도 호출한다. 이 함수가 예외를 반환하면, 해당 future는 예외 상태로 완료된다.

다음은 예시 코드다:

```java
template.setReplyErrorChecker(record -> {
    Header error = record.headers().lastHeader("serverSentAnError");
    if (error != null) {
        return new MyException(new String(error.value()));
    }
    else {
        return null;
    }
});

...

RequestReplyFuture<Integer, String, String> future = template.sendAndReceive(record);
try {
    future.getSendFuture().get(10, TimeUnit.SECONDS); // send ok
    ConsumerRecord<Integer, String> consumerRecord = future.get(10, TimeUnit.SECONDS);
    ...
}
catch (InterruptedException e) {
    ...
}
catch (ExecutionException e) {
    if (e.getCause() instanceof MyException) {
        ...
    }
}
catch (TimeoutException e) {
    ...
}
```

템플릿은 기본적으로 `KafkaHeaders.CORRELATION_ID`라는 이름의 헤더를 설정하며, 서버 측에서는 이 값을 그대로 응답 메시지에 되돌려 보내야 한다.

다음은 응답을 처리하는 `@KafkaListener` 애플리케이션 예시다:

```java
@SpringBootApplication
public class KReplyingApplication {

    public static void main(String[] args) {
        SpringApplication.run(KReplyingApplication.class, args);
    }

    @KafkaListener(id="server", topics = "kRequests")
    @SendTo // use default replyTo expression
    public String listen(String in) {
        System.out.println("Server received: " + in);
        return in.toUpperCase();
    }

    @Bean
    public NewTopic kRequests() {
        return TopicBuilder.name("kRequests")
            .partitions(10)
            .replicas(2)
            .build();
    }

    @Bean // not required if Jackson is on the classpath
    public MessagingMessageConverter simpleMapperConverter() {
        MessagingMessageConverter messagingMessageConverter = new MessagingMessageConverter();
        messagingMessageConverter.setHeaderMapper(new SimpleKafkaHeaderMapper());
        return messagingMessageConverter;
    }

}
```

`@KafkaListener` 인프라는 correlation ID를 그대로 되돌려 보내며, 응답을 전송할 토픽을 결정한다.

응답을 전송하는 자세한 방법은 [`@SendTo`를 사용해 리스너 결과 포워딩하기](https://docs.spring.io/spring-kafka/reference/kafka/receiving-messages/annotation-send-to.html)를 참고해라. 템플릿은 기본적으로 `KafkaHeaders.REPLY_TOPIC` 헤더를 통해 응답을 전송할 토픽을 지정한다.

2.2 버전부터 템플릿은 설정한 reply 컨테이너를 이용해 reply 토픽 또는 파티션을 자동으로 감지한다. 컨테이너가 단일 토픽 또는 단일 `TopicPartitionOffset`만을 수신하도록 설정되어 있다면, 해당 정보를 사용해 reply 헤더를 세팅한다. 반면 컨테이너가 그 외 방식으로 구성되어 있다면, 사용자가 직접 reply 헤더를 설정해야 한다. 이 경우 초기화 과정에서 `INFO` 레벨 로그가 출력된다. 다음은 `KafkaHeaders.REPLY_TOPIC`을 사용하는 예시다:

```java
record.headers().add(new RecordHeader(KafkaHeaders.REPLY_TOPIC, "kReplies".getBytes()));
```

단일 reply `TopicPartitionOffset`을 설정하는 경우, 각 인스턴스가 서로 다른 파티션을 구독하기만 한다면 여러 `ReplyingKafkaTemplate`에서 같은 reply 토픽을 함께 사용할 수 있다. 단일 reply 토픽을 설정하는 경우에는, 각 인스턴스가 서로 다른 `group.id`를 사용해야 한다. 이때는 모든 인스턴스가 모든 reply 메시지를 받지만, correlation ID를 통해 내가 보낸 요청에 대한 응답인지 판단할 수 있다. 이 방식은 오토 스케일링<sup>auto-scaling</sup> 환경에서 유용할 수 있지만, 불필요한 reply로 인한 네트워크 트래픽이 추가되며, 불필요한 reply를 폐기하는 오버헤드가 조금 생긴다. 이때는 템플릿의 `sharedReplyTopic`을 `true`로 설정하는 것을 권장한다. 이렇게 하면 예상치 못한 reply에 대한 로그 레벨이 기본값인 ERROR에서 DEBUG로 낮아진다.

다음은 하나의 reply 토픽을 공유하는 reply 컨테이너를 설정하는 예시다:

```java
@Bean
public ConcurrentMessageListenerContainer<String, String> replyContainer(
        ConcurrentKafkaListenerContainerFactory<String, String> containerFactory) {

    ConcurrentMessageListenerContainer<String, String> container = containerFactory.createContainer("topic2");
    container.getContainerProperties().setGroupId(UUID.randomUUID().toString()); // unique
    Properties props = new Properties();
    props.setProperty(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "latest"); // so the new group doesn't get old replies
    container.getContainerProperties().setKafkaConsumerProperties(props);
    return container;
}
```

> 여러 개의 클라이언트 인스턴스를 사용하면서, 앞에서 설명한 방식대로 설정하지 않는다면, 각 인스턴스마다 전용 reply 토픽이 필요하다. 아니면 `KafkaHeaders.REPLY_PARTITION` 헤더를 설정해서, 각 인스턴스마다 고유한 파티션을 사용하도록 만들 수도 있다. 이 헤더는 4바이트 정수(big-endian)를 포함하며, 서버 측은 이 헤더를 통해 올바른 파티션으로 응답을 라우팅해야 한다(`@KafkaListener`가 이 작업을 수행한다). 하지만 이 방식에서는 reply 컨테이너는 카프카의 그룹 관리 기능을 사용할 수 없으며, 반드시 정해진 파티션만 구독하도록 설정해야 한다 (`ContainerProperties` 생성자에서 `TopicPartitionOffset`을 사용해서).

> `JsonKafkaHeaderMapper`는 (`@KafkaListener`에서 필요) 클래스패스에 Jackson이 존재해야 동작한다. Jackson이 없으면 메시지 컨버터는 header mapper를 사용할 수 없기 때문에, 앞에 있는 예시처럼 `SimpleKafkaHeaderMapper`를 이용해 직접 `MessagingMessageConverter`를 구성해야 한다.

기본적으로 아래 세 가지 헤더를 사용한다:

- `KafkaHeaders.CORRELATION_ID` - 응답을 요청에 매칭할 때 사용
- `KafkaHeaders.REPLY_TOPIC` - 서버에게 응답을 보낼 토픽을 알려주는 용도
- `KafkaHeaders.REPLY_PARTITION` - (선택 사항) 서버에게 응답을 보낼 파티션을 알려주는 용도

`@KafkaListener`가 동작할 땐 이 헤더를 통해 응답을 올바른 곳에 라우팅한다.

2.3 버전부터는 템플릿의 `correlationHeaderName`, `replyTopicHeaderName`, `replyPartitionHeaderName` 프로퍼티를 통해 사용할 헤더명을 커스텀할 수 있다. 서버가 스프링 애플리케이션이 아닐 때 (혹은 `@KafkaListener`를 사용하지 않는 경우) 유용할 거다.

> 반대로 요청을 보내는 쪽이 스프링 애플리케이션이 아니어서 correlation 정보를 다른 헤더에 담는 경우라면, 3.0 버전부터 리스너 컨테이너 팩토리에 커스텀 `correlationHeaderName`을 설정할 수 있으며, 응답으로도 지정한 헤더를 돌려받는다. 이전에는 리스너가 커스텀 correlation 헤더를 직접 되돌려 보냈어야 했다.

### Request/Reply with `Message<?>`s

2.7 버전에서는 `ReplyingKafkaTemplate`에 `spring-messaging`의 `Message<?>` 인터페이스를 통해 메시지를 주고 받을 수 있는 메소드가 추가됐다.

```java
RequestReplyMessageFuture<K, V> sendAndReceive(Message<?> message);

<P> RequestReplyTypedMessageFuture<K, V, P> sendAndReceive(Message<?> message,
        ParameterizedTypeReference<P> returnType);
```

위 메소드들은 템플릿의 디폴트 `replyTimeout`을 사용하며, 메소드를 호출할 때 타임아웃 값을 넘길 수 있는 메소드도 오버로딩돼 있다.

컨슈머의 `Deserializer` 혹은 템플릿의 `MessageConverter`가 설정이나 응답 메시지의 타입 메타데이터만 있다면 추가 정보 없이도 payload를 변환할 수 있다면 첫 번째 메소드를 사용해라.

메시지 컨버터가 메시지를 변환하는 데 필요한 반환 타입 정보를 넘겨줘야 할 땐 두 번째 메소드를 사용해라. 이렇게 하면 응답 메시지에 타입 메타데이터가 없더라도, 하나의 템플릿으로 서로 다른 타입을 받을 수 있다. 서버 측이 스프링 애플리케이션이 아닌 경우에 유용할 거다. 다음은 두 번째 메소드를 사용하는 예시다:

*Template Bean*

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">Java</span>
<span class="switch-language kotlin">Kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
@Bean
ReplyingKafkaTemplate<String, String, String> template(
        ProducerFactory<String, String> pf,
        ConcurrentKafkaListenerContainerFactory<String, String> factory) {

    ConcurrentMessageListenerContainer<String, String> replyContainer =
            factory.createContainer("replies");
    replyContainer.getContainerProperties().setGroupId("request.replies");
    ReplyingKafkaTemplate<String, String, String> template =
            new ReplyingKafkaTemplate<>(pf, replyContainer);
    template.setMessageConverter(new ByteArrayJsonMessageConverter());
    template.setDefaultTopic("requests");
    return template;
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
@Bean
fun template(
    pf: ProducerFactory<String?, String>?,
    factory: ConcurrentKafkaListenerContainerFactory<String?, String?>
): ReplyingKafkaTemplate<String?, String, String?> {
    val replyContainer = factory.createContainer("replies")
    replyContainer.containerProperties.groupId = "request.replies"
    val template = ReplyingKafkaTemplate(pf, replyContainer)
    template.messageConverter = ByteArrayJsonMessageConverter()
    template.defaultTopic = "requests"
    return template
}
```

*Using the template*

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">Java</span>
<span class="switch-language kotlin">Kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
RequestReplyTypedMessageFuture<String, String, Thing> future1 =
        template.sendAndReceive(MessageBuilder.withPayload("getAThing").build(),
                new ParameterizedTypeReference<Thing>() { });
log.info(future1.getSendFuture().get(10, TimeUnit.SECONDS).getRecordMetadata().toString());
Thing thing = future1.get(10, TimeUnit.SECONDS).getPayload();
log.info(thing.toString());

RequestReplyTypedMessageFuture<String, String, List<Thing>> future2 =
template.sendAndReceive(MessageBuilder.withPayload("getThings").build(),
new ParameterizedTypeReference<List<Thing>>() { });
log.info(future2.getSendFuture().get(10, TimeUnit.SECONDS).getRecordMetadata().toString());
List<Thing> things = future2.get(10, TimeUnit.SECONDS).getPayload();
things.forEach(thing1 -> log.info(thing1.toString()));
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
val future1: RequestReplyTypedMessageFuture<String?, String?, Thing?>? =
    template.sendAndReceive(MessageBuilder.withPayload("getAThing").build(),
        object : ParameterizedTypeReference<Thing?>() {})
log.info(future1?.sendFuture?.get(10, TimeUnit.SECONDS)?.recordMetadata?.toString())
val thing = future1?.get(10, TimeUnit.SECONDS)?.payload
log.info(thing.toString())

val future2: RequestReplyTypedMessageFuture<String?, String?, List<Thing?>?>? =
    template.sendAndReceive(MessageBuilder.withPayload("getThings").build(),
        object : ParameterizedTypeReference<List<Thing?>?>() {})
log.info(future2?.sendFuture?.get(10, TimeUnit.SECONDS)?.recordMetadata.toString())
val things = future2?.get(10, TimeUnit.SECONDS)?.payload
things?.forEach(Consumer { thing1: Thing? -> log.info(thing1.toString()) })
```

---

## Reply Type Message<?>

`@KafkaListener`가 `Message<?>`를 반환할 경우, 2.5 버전 이전에는 reply 토픽과 correlation id 헤더를 직접 채웠어야 했다. 아래 예시는 요청에 있는 reply 토픽 헤더를 사용한다:

```java
@KafkaListener(id = "requestor", topics = "request")
@SendTo
public Message<?> messageReturn(String in) {
    return MessageBuilder.withPayload(in.toUpperCase())
            .setHeader(KafkaHeaders.TOPIC, replyTo)
            .setHeader(KafkaHeaders.KEY, 42)
            .setHeader(KafkaHeaders.CORRELATION_ID, correlation)
            .build();
}
```

이 예시를 통해 reply 레코드에 key를 설정하는 방법도 알 수 있다.

2.5 버전부터는 프레임워크가 이러한 헤더가 없으면 자동으로 감지하고, `@SendTo`로 지정한 토픽 또는 요청 메시지에 있는 `KafkaHeaders.REPLY_TOPIC` 헤더 (있다면)로 값을 채워준다. 또한 요청 메시지에 `KafkaHeaders.CORRELATION_ID`나 `KafkaHeaders.REPLY_PARTITION`이 있을 경우, 그 값도 그대로 되돌려 보낸다.

```java
@KafkaListener(id = "requestor", topics = "request")
@SendTo  // default REPLY_TOPIC header
public Message<?> messageReturn(String in) {
    return MessageBuilder.withPayload(in.toUpperCase())
            .setHeader(KafkaHeaders.KEY, 42)
            .build();
}
```

### Original Record Key in Reply

3.3 버전부터는, 요청 메시지에 카프카 레코드 key가 있다면 reply 레코드에도 그대로 유지한다. 이 동작은 request/reply 방식으로 단일 레코드를 주고 받는 경우에만 유효하다. 리스너가 배치 모드이거나 반환 타입이 컬렉션인 경우에는, 애플리케이션이 직접 reply 레코드를 `Message` 타입으로 감싸서 어떤 key를 사용할지 지정해야 한다.

---

## Aggregating Multiple Replies

[ReplyingKafkaTemplate 사용하기](#using-replyingkafkatemplate)에 보여준 `ReplyingKafkaTemplate`은 단일 레코드를 주고 받는 용도이다. 하나의 메시지를 여러 곳에서 받아 각각 reply를 보내는 경우에는 `AggregatingReplyingKafkaTemplate`을 사용해라. 이 템플릿은 [엔터프라이즈 통합 패턴 Scatter-Gather](https://www.enterpriseintegrationpatterns.com/patterns/messaging/BroadcastAggregate.html)의 클라이언트 측 구현체다.

`ReplyingKafkaTemplate`와 마찬가지로, `AggregatingReplyingKafkaTemplate`의 생성자는 reply를 수신하기 위한 프로듀서 팩토리와 리스너 컨테이너를 인자로 받는다. 여기에는 세 번째 파라미터로 `BiPredicate<List<ConsumerRecord<K, R>>, Boolean> releaseStrategy`가 있는데, reply를 받을 때마다 매번 이 전략을 호출한다. predicate가 `true`를 반환하면, 해당 `ConsumerRecord` 컬렉션을 사용해 `sendAndReceive` 메소드가 반환한 Future를 완료한다.

`returnPartialOnTimeout`이라는 프로퍼티가 추가로 있는데 기본값은 false다. 이 값을 `true`로 설정하면 타임아웃이 발생해도 `KafkaReplyTimeoutException`으로 Future를 완료시키지 않고, (reply 레코드를 하나라도 받았다면) 그때까지 수집한 결과로 Future를 정상 상태로 완료한다.

2.3.5 버전부터는 타임아웃이 발생해도 predicate를 호출한다 (`returnPartialOnTimeout`이 `true`인 경우). predicate의 첫 번째 인자는 현재까지 받은 레코드 리스트이며, 두 번째 인자로는 `true`를 넘기는데, 이는 타임아웃으로 인한 호출임을 나타내는 값이다. predicate에서는 레코드 리스트를 수정할 수도 있다.

```java
AggregatingReplyingKafkaTemplate<Integer, String, String> template =
        new AggregatingReplyingKafkaTemplate<>(producerFactory, container,
                        coll -> coll.size() == releaseSize);
...
RequestReplyFuture<Integer, String, Collection<ConsumerRecord<Integer, String>>> future =
        template.sendAndReceive(record);
future.getSendFuture().get(10, TimeUnit.SECONDS); // send ok
ConsumerRecord<Integer, Collection<ConsumerRecord<Integer, String>>> consumerRecord =
        future.get(30, TimeUnit.SECONDS);
```

반환 타입은 값이 `ConsumerRecord`의 컬렉션인 `ConsumerRecord`라는 점에 주의해라. "바깥쪽" `ConsumerRecord`는 "실제" 레코드가 아니라, 템플릿이 수신한 reply 레코드들을 담기 위해 임의로 만든 레코드다. release가 정상적으로 이루어지면 (release strategy가 true를 반환하면), 토픽명은 `aggregatedResults`로 설정된다. `returnPartialOnTimeout`이 true이고 타임아웃이 발생했다면 (그리고 최소 하나 이상의 reply 레코드를 받았다면), 토픽명은 `partialResultsAfterTimeout`으로 설정된다. 템플릿은 이러한 "topic" 이름을 위한 static 상수를 제공한다.

```java
/**
 * Pseudo topic name for the "outer" {@link ConsumerRecords} that has the aggregated
 * results in its value after a normal release by the release strategy.
 */
public static final String AGGREGATED_RESULTS_TOPIC = "aggregatedResults";

/**
 * Pseudo topic name for the "outer" {@link ConsumerRecords} that has the aggregated
 * results in its value after a timeout.
 */
public static final String PARTIAL_RESULTS_AFTER_TIMEOUT_TOPIC = "partialResultsAfterTimeout";
```

`Collection` 안에 있는 실제 `ConsumerRecord`들에는 응답를 수신한 실제 토픽 정보가 담겨있다.

> reply를 수신하는 리스너 컨테이너는 반드시 `AckMode.MANUAL`이나 `AckMode.MANUAL_IMMEDIATE`으로 설정해야 하며, 컨슈머 프로퍼티 `enable.auto.commit`은 `false`여야 한다 (2.3 버전부터 `false`가 기본값이다). 템플릿은 아직 처리 중인 요청이 없을 때에만 오프셋을 커밋해서 메시지 유실에 대한 가능성을 제거한다. 즉, release strategy가 마지막으로 처리 중인 요청을 release할 때 offset을 커밋한다. 리밸런싱이 발생하면 reply가 중복으로 전달될 수 있는데, 요청을 처리 할 땐 중복 reply는 무시한다. 중복으로 도착한 reply가 이미 release한 reply라면 관련 에러 로그가 찍힐 수 있다.

> aggregating 템플릿을 [`ErrorHandlingDeserializer`](https://docs.spring.io/spring-kafka/reference/kafka/serdes.html#error-handling-deserializer)와 함께 사용하는 경우, 프레임워크는 `DeserializationException`을 자동으로 감지하지 않는다. 그대신 헤더에 deserialization 예외 정보를 담아 값이 null인 레코드를 그대로 반환한다. 애플리케이션에서 deserialization 예외가 발생했는지 판단하려면 유틸리티 메소드 `ReplyingKafkaTemplate.checkDeserialization()`을 호출하는 것을 권장한다. 자세한 내용은 해당 JavaDoc을 참고해라. aggregating 템플릿에서는 `replyErrorChecker`도 호출하지 않기 때문에, 각 reply 요소마다 직접 검사를 수행해야 한다.