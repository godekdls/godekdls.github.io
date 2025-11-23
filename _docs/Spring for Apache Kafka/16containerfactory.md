---
title: Container factory
category: Spring for Apache Kafka
order: 17
permalink: /Spring for Apache Kafka/container-factory/
description: 컨테이너 팩토리 사용법
image: ./../../images/spring/logo.png
lastmod: 2025-09-12T23:34:00+09:00
comments: true
originalRefName: 스프링 카프카
originalRefLink: https://docs.spring.io/spring-kafka/reference/kafka/container-factory.html
parent: Reference
parentUrl: /Spring for Apache Kafka/reference/
subparent: Using Spring for Apache Kafka
subparentUrl: /Spring for Apache Kafka/kafka/
---

---

[`@KafkaListener` 애노테이션](../receiving-messages/#kafkalistener-annotation)을 다룰 때 언급했듯이, 애노테이션을 선언한 메소드들을 위한 컨테이너는 `ConcurrentKafkaListenerContainerFactory`를 사용해서 만든다.

2.2 버전부터는, 같은 팩토리를 사용해 원하는 `ConcurrentMessageListenerContainer`를 생성할 수 있다. 비슷한 프로퍼티를 사용해 여러 컨테이너를 생성하고 싶거나, 스프링 부트의 자동 설정으로 만들어지는 팩토리처럼 외부에서 설정한 팩토리를 사용하고 싶은 경우 유용할 거다. 컨테이너가 생성된 이후에도 컨테이너 프로퍼티를 추가로 수정할 수 있으며, 대부분 `container.getContainerProperties()`를 이용하면 된다. 다음은 `ConcurrentMessageListenerContainer`를 설정하는 예시다:

```java
@Bean
public ConcurrentMessageListenerContainer<String, String>(
        ConcurrentKafkaListenerContainerFactory<String, String> factory) {

    ConcurrentMessageListenerContainer<String, String> container =
        factory.createContainer("topic1", "topic2");
    container.setMessageListener(m -> { ... } );
    return container;
}
```

> 이렇게 만든 컨테이너는 엔드포인트 레지스트리에 등록되지 않는다. 애플리케이션 컨텍스트에 등록하려면 `@Bean` 정의로 생성해야 한다.

2.3.4 버전부터는 팩토리에 `ContainerCustomizer`를 등록해서, 생성한 컨테이너에 추가 설정을 더 넣을 수 있다:

```java
@Bean
public KafkaListenerContainerFactory<?> kafkaListenerContainerFactory() {
    ConcurrentKafkaListenerContainerFactory<Integer, String> factory =
            new ConcurrentKafkaListenerContainerFactory<>();
    ...
    factory.setContainerCustomizer(container -> { /* customize the container */ });
    return factory;
}
```

3.1 버전부터는 `KafkaListener` 애노테이션에 `ContainerPostProcessor`의 빈 이름을 지정해서, 단일 리스너도 같은 방식으로 커스텀할 수 있다.

```java
@Bean
public ContainerPostProcessor<String, String, AbstractMessageListenerContainer<String, String>> customContainerPostProcessor() {
    return container -> { /* customize the container */ };
}

...

@KafkaListener(..., containerPostProcessor="customContainerPostProcessor", ...)
```