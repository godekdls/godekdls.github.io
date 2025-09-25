---
title: Connecting to Kafka
category: Spring for Apache Kafka
order: 8
permalink: /Spring for Apache Kafka/connecting/
description: 스프링 카프카로 카프카 연결하기
image: ./../../images/spring/logo.png
lastmod: 2025-09-12T23:34:00+09:00
comments: true
originalRefName: 스프링 카프카
originalRefLink: https://docs.spring.io/spring-kafka/reference/3.3.10/connecting.html
parent: Reference
parentUrl: /Spring for Apache Kafka/reference/
subparent: Using Spring for Apache Kafka
subparentUrl: /Spring for Apache Kafka/kafka/
---

---

- `KafkaAdmin` - [토픽 설정하기](../configuring-topics/) 참고
- `ProducerFactory` - [메시지 전송하기](https://docs.spring.io/spring-kafka/reference/kafka/sending-messages.html) 참고
- `ConsumerFactory` - [메시지 수신하기](https://docs.spring.io/spring-kafka/reference/kafka/receiving-messages.html) 참고

2.5 버전부터 `KafkaAdmin`, `ProducerFactory`, `ConsumerFactory` 모두 `KafkaResourceFactory`를 상속한다. 덕분에 런타임에 `Supplier<String>`을 설정해 부트스트랩 서버를 변경할 수 있다: `setBootstrapServersSupplier(() -> …)`. 커넥션을 새로 맺을 때마다 이 설정을 통해 서버 목록을 가져온다. 컨슈머<sup>Consumer</sup>와 프로듀서<sup>Producer</sup>는 일반적으로 한 번 만들어놓고 계속해서 사용한다. 기존 프로듀서<sup>Producer</sup>를 종료하려면 `DefaultKafkaProducerFactory`의 `reset()`을 호출해라. 기존 컨슈머<sup>Consumer</sup>를 종료하려면 `KafkaListenerEndpointRegistry`에서 `stop()`(그리고 `start()`)을 호출하거나, 다른 리스너 컨테이너 빈에서 `stop()`과 `start()`를 호출해라.

스프링 프레임워크는 부트스트랩 서버를 두 세트 설정할 수 있는 `ABSwitchCluster`도 제공한다 (항상 한쪽만 활성 상태다). `ABSwitchCluster`를 구성하고, 그 인스턴스를 프로듀서 팩토리, 컨슈머 팩토리와 `KafkaAdmin`에 `setBootstrapServersSupplier()`를 통해 추가해라. 부트스트랩 서버를 전환하고 싶을 땐 `primary()`나 `secondary()`를 호출하고, 프로듀서 팩토리에서는 커넥션을 새로 맺을 수 있도록 `reset()`을 호출해라. 컨슈머의 경우 모든 리스너 컨테이너에 대해 `stop()`과 `start()`를 호출해라. `@KafkaListener`를 사용할 때는 `KafkaListenerEndpointRegistry` 빈에 대해 `stop()`과 `start()`를 호출해라.

자세한 내용은 Javadocs를 참고해라.

### 목차

- [Factory Listeners](#factory-listeners)
- [Default client ID prefixes](#default-client-id-prefixes)

---

## Factory Listeners

2.5 버전부터 `DefaultKafkaProducerFactory`와 `DefaultKafkaConsumerFactory`는 `Listener`를 설정해 프로듀서나 컨슈머가 생성, 종료될 때마다 알림을 받을 수 있다.

*Producer Factory Listener*

```java
interface Listener<K, V> {

    default void producerAdded(String id, Producer<K, V> producer) {
    }

    default void producerRemoved(String id, Producer<K, V> producer) {
    }

}
```

*Consumer Factory Listener*

```java
interface Listener<K, V> {

    default void consumerAdded(String id, Consumer<K, V> consumer) {
    }

    default void consumerRemoved(String id, Consumer<K, V> consumer) {
    }

}
```

둘 모두 `id` 값은 팩토리 `beanName` 프로퍼티와, 생성 후 `metrics()`에서 얻을 수 있는 `client-id` 프로퍼티를 `.`으로 연결해 만든다.

이런 리스너는 예를 들면, 새 클라이언트가 만들어질 때마다 Micrometer `KafkaClientMetrics` 인스턴스를 생성하고 바인딩하는 데 사용할 수 있다 (클라이언트가 종료될 때는 닫음).

스프링 프레임워크는 정확히 이 용도로 사용할 수 있는 리스너를 제공한다. 자세한 내용은 [Micrometer Native Metrics](https://docs.spring.io/spring-kafka/reference/kafka/micrometer.html#micrometer-native)를 참고해라.

---

## Default client ID prefixes

3.2 버전부터 스프링 부트 애플리케이션에서 `spring.application.name` 프로퍼티를 이용해 애플리케이션 이름을 정의했다면, 아래 클라이언트에서 자동 생성하는 클라이언트 ID에 이 이름을 디폴트 프리픽스로 사용한다:

- 컨슈머 그룹을 사용하지 않는 컨슈머 클라이언트
- 프로듀서 클라이언트
- 어드민 클라이언트

덕분에 서버 측에서 어떠한 문제를 해결하거나 할당량을 제한하고 싶을 때 원하는 클라이언트를 더 쉽게 식별할 수 있다.

*Table 1. spring.application.name=myapp을 설정한 스프링 부트 애플리케이션에서 만들어지는 클라이언트 ID 예시*

| 클라이언트 타입                           | 애플리케이션 이름이 없는 경우 | 애플리케이션 이름이 있는 경우 |
| :---------------------------------------- | :---------------------------- | :---------------------------- |
| 컨슈머 그룹이 없는 클라이언트             | consumer-null-1               | myapp-consumer-1              |
| "mygroup"이라는 컨슈머 그룹에 속한 컨슈머 | consumer-mygroup-1            | consumer-mygroup-1            |
| 프로듀서                                  | producer-1                    | myapp-producer-1              |
| 어드민                                    | adminclient-1                 | myapp-admin-1                 |
