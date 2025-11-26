---
title: Monitoring
category: Spring for Apache Kafka
order: 19
permalink: /Spring for Apache Kafka/micrometer/
description: todo
image: ./../../images/spring/logo.png
lastmod: 2025-09-12T23:34:00+09:00
comments: true
originalRefName: 스프링 카프카
originalRefLink: https://docs.spring.io/spring-kafka/reference/kafka/micrometer.html
parent: Reference
parentUrl: /Spring for Apache Kafka/reference/
subparent: Using Spring for Apache Kafka
subparentUrl: /Spring for Apache Kafka/kafka/
---

### 목차

- [Monitoring Listener Performance](#monitoring-listener-performance)
- [Monitoring KafkaTemplate Performance](#monitoring-kafkatemplate-performance)
- [Micrometer Native Metrics](#micrometer-native-metrics)
- [Micrometer Observation](#micrometer-observation)
  - [Batch Listener Observations](#batch-listener-observations)

---

## Monitoring Listener Performance

2.3 버전부터 클래스패스에 `Micrometer`가 존재하면서 애플리케이션 컨텍스트에 `MeterRegistry`가 하나 있을 경우, 리스너 컨테이너는 자동으로 리스너를 위한 Micrometer `Timer`를 생성하고 업데이트한다. 타이머를 비활성화하려면 `ContainerProperty`의 `micrometerEnabled`를 `false`로 설정하면 된다.

관리하는 타이머는 총 두 가지로, 리스너 실행에 성공한 경우를 위한 타이머와, 실패한 경우를 위한 타이머가 있다.

타이머 이름은 `spring.kafka.listener`이며, 다음과 같은 태그를 가진다:

- `name` : (컨테이너 빈 이름)
- `result` : `success` 또는 `failure`
- `exception` : `none` 또는 `ListenerExecutionFailedException`

`ContainerProperties`의 `micrometerTags` 프로퍼티를 이용하면 다른 태그를 더 추가할 수 있다.

2.9.8, 3.0.6 버전부터는 `ContainerProperties`의 `micrometerTagsProvider`로 함수를 제공할 수 있다. 이 함수는 `ConsumerRecord<?, ?>`를 받아 해당 레코드를 기반으로 태그를 반환하며, 그러면 `micrometerTags`에 있는 기존 정적인 태그와 병합된다.

> concurrent 컨테이너를 사용할 때는 각 스레드마다 타이머가 생성된다. `name` tag는 뒤에 `-n`이 붙으며, 여기서 n은 `0`부터 `concurrency-1`까지의 값이다.

---

## Monitoring KafkaTemplate Performance

2.3 버전부터 클래스패스에 `Micrometer`가 존재하면서 애플리케이션 컨텍스트에 `MeterRegistry`가 하나 있을 경우, 템플릿은 자동으로 전송 작업을 위한 Micrometer `Timer`를 생성하고 업데이트한다. 타이머를 비활성화하려면 `ContainerProperty`의 `micrometerEnabled`를 `false`로 설정하면 된다.

관리하는 타이머는 총 두 가지로, 리스너 실행에 성공한 경우를 위한 타이머와, 실패한 경우를 위한 타이머가 있다.

타이머 이름은 `spring.kafka.template`이며, 다음과 같은 태그를 가진다:

- `name` : (템플릿 빈 이름)
- `result` : `success` 또는 `failure`
- `exception` : `none` 또는실패 시 exception 클래스명

템플릿의 `micrometerTags` 프로퍼티를 이용하면 다른 태그를 더 추가할 수 있다.

2.9.8, 3.0.6 버전부터는 `KafkaTemplate.setMicrometerTagsProvider(Function<ProducerRecord<?, ?>, Map<String, String>>)` 프로퍼티를 제공할 수 있다. 이 함수는 `ProducerRecord<?, ?>`를 받아 해당 레코드를 기반으로 태그를 반환하며, 그러면 `micrometerTags`에 있는 기존 정적인 태그와 병합된다.

---

## Micrometer Native Metrics

2.5 버전부터 스프링 프레임워크는 프로듀서와 컨슈머를 생성하거나 종료할 때 Micrometer `KafkaClientMetrics` 인스턴스를 관리할 수 있는 [팩토리 리스너](../connecting/#factory-listeners)를 제공한다.

이 기능을 활성화하려면, 간단히 프로듀서와 컨슈머 팩토리에 리스너를 추가해주면 된다:

```java
@Bean
public ConsumerFactory<String, String> myConsumerFactory() {
    Map<String, Object> configs = consumerConfigs();
    ...
    DefaultKafkaConsumerFactory<String, String> cf = new DefaultKafkaConsumerFactory<>(configs);
    ...
    cf.addListener(new MicrometerConsumerListener<String, String>(meterRegistry(),
            Collections.singletonList(new ImmutableTag("customTag", "customTagValue"))));
    ...
    return cf;
}

@Bean
public ProducerFactory<String, String> myProducerFactory() {
    Map<String, Object> configs = producerConfigs();
    configs.put(ProducerConfig.CLIENT_ID_CONFIG, "myClientId");
    ...
    DefaultKafkaProducerFactory<String, String> pf = new DefaultKafkaProducerFactory<>(configs);
    ...
    pf.addListener(new MicrometerProducerListener<String, String>(meterRegistry(),
            Collections.singletonList(new ImmutableTag("customTag", "customTagValue"))));
    ...
    return pf;
}
```

리스너에 전달되는 컨슈머/프로듀서 `id`는 `spring.id`라는 이름으로 meter의 태그에 추가된다.

다음은 카프카 메트릭 중 하나를 조회하는 예시다:

```java
double count = this.meterRegistry.get("kafka.producer.node.incoming.byte.total")
                .tag("customTag", "customTagValue")
                .tag("spring.id", "myProducerFactory.myClientId-1")
                .functionCounter()
                .count();
```

`StreamsBuilderFactoryBean`에도 비슷한 리스너를 제공하고 있다. 자세한 내용은 [KafkaStreams Micrometer 지원](https://docs.spring.io/spring-kafka/reference/streams.html#streams-micrometer)을 참고해라.

3.3 버전부터는 `KafkaMetricsSupport`라는 추상 클래스를 도입했다. 이 클래스는 넘겨받은 카프카 클라이언트의 `io.micrometer.core.instrument.binder.kafka.KafkaMetrics`를 `MeterRegistry`에 바인딩한다. 앞서 언급한 `MicrometerConsumerListener`, `MicrometerProducerListener`, `KafkaStreamsMicrometerListener` 역시 이 클래스를 상속하고 있다. 물론, 카프카 클라이언트를 사용한다면 다른 케이스에도 활용할 수 있다. 이 클래스를 상속하고, `bindClient()`와 `unbindClient()` API를 직접 호출해서 카프카 클라이언트 메트릭을 Micrometer collector에 연결해주면 된다.

---

## Micrometer Observation

3.0 버전부터 `KafkaTemplate`과 리스너 컨테이너에 Micrometer Observation을 사용할 수 있다.

`KafkaTemplate`과 `ContainerProperties`의 `observationEnabled`를 `true`로 설정하면 Observation이 활성화된다. 이 설정을 사용하면 각 observation이 타이머를 관리하기 때문에 [Micrometer 타이머](./)는 비활성화된다.

> Micrometer Observation은 배치 리스너를 지원하지 않는다. 이 경우 Micrometer 타이머가 활성화된다.

자세한 내용은 [Micrometer 트레이싱](https://docs.micrometer.io/tracing/reference/1.6)을 참고해라.

타이머/트레이스에 태그를 추가하려면, 템플릿 또는 리스너 컨테이너에 각각 커스텀`KafkaTemplateObservationConvention`/`KafkaListenerObservationConvention` 구현체를 설정해라.

디폴트구현체는 템플릿 Observation에는 `bean.name` 태그를, 컨테이너 Observation에는 `listener.id` 태그를 추가한다.

`DefaultKafkaTemplateObservationConvention`이나 `DefaultKafkaListenerObservationConvention`을 상속해도 되고, 완전히 새로운 구현체를 제공해도 된다.

기록되는 기본 Observation에 대한 자세한 내용은 [Micrometer Observation 문서](https://docs.spring.io/spring-kafka/reference/appendix/micrometer.html#observation-gen)를 참고해라.

3.0.6 버전부터, 컨슈머 또는 프로듀서 레코드의 정보를 기반으로 타이머와 트레이스에 동적인 태그를 추가할 수 있다. 이땐 리스너 컨테이너 프로퍼티나 `KafkaTemplate`에 각각 커스텀 `KafkaListenerObservationConvention`, `KafkaTemplateObservationConvention`을 설정하면 된다. 두 Observation 컨텍스트에 있는 `record` 프로퍼티는 각각 `ConsumerRecord` 또는 `ProducerRecord`가 들어있다.

sender와 receiver 컨텍스트의 `remoteServiceName` 프로퍼티는 카프카 `clusterId` 프로퍼티로 세팅된다. 이 값은 `KafkaAdmin`으로 가져온다. 만약 어드민 권한이 없다거나 하는 이유로 클러스터 id를 조회할 수 없다면, 3.1 버전부터는 `KafkaAdmin`에 직접 `clusterId`를 설정하고 이를 `KafkaTemplate`과 리스너 컨테이너에 주입해주면 된다. `clusterId`가 `null`(디폴트)이면, 어드민은 admin operation `describeCluster`를 실행해 브로커에서 클러스터 id를 조회한다.

### Batch Listener Observations

배치 리스너를 사용할 때는 기본적으로 `ObservationRegistry`가 존재하더라도 Observation을 생성하지 않는다. Observation의 스코프는 스레드에 묶이게 되고, 배치 리스너에서는 Observation과 레코드 간에 1:1 매핑이 존재하지 않기 때문이다.

배치 리스너에서 레코드 단위 Observation을 활성화고 싶다면, 컨테이너 팩토리 프로퍼티 `recordObservationsInBatch`를 `true`로 설정해라.

```java
@Bean
ConcurrentKafkaListenerContainerFactory<?, ?> kafkaListenerContainerFactory(
        ConcurrentKafkaListenerContainerFactoryConfigurer configurer,
        ConsumerFactory<Object, Object> kafkaConsumerFactory) {

    ConcurrentKafkaListenerContainerFactory<Object, Object> factory = new ConcurrentKafkaListenerContainerFactory<>();
    configurer.configure(factory, kafkaConsumerFactory);
    factory.getContainerProperties().setRecordObservationsInBatch(true);
    return factory;
}
```

이 프로퍼티가 `true`이면, 배치에 포함된 각 레코드마다 Observation이 생성된다. 하지만 이 Observation은 리스너 메소드로 전파되진 않는다. 애플리케이션은 Observation 컨텍스트를 사용해 배치 내 각 레코드의 처리 과정을 추적할 수 있다. 덕분에 배치 환경에서도 개별 레코드의 처리 상태를 파악할 수 있다.