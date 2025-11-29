---
title: Producer Interceptor Managed in Spring
category: Spring for Apache Kafka
order: 23
permalink: /Spring for Apache Kafka/producer-interceptor-managed-in-spring/
description: 스프링 빈이 관리하는 프로듀서 인터셉터 사용하기
image: ./../../images/spring/logo.png
lastmod: 2025-09-12T23:34:00+09:00
comments: true
originalRefName: 스프링 카프카
originalRefLink: https://docs.spring.io/spring-kafka/reference/kafka/producer-interceptor-managed-in-spring.html
parent: Reference
parentUrl: /Spring for Apache Kafka/reference/
subparent: Using Spring for Apache Kafka
subparentUrl: /Spring for Apache Kafka/kafka/
---

---

3.0.0 버전부터 프로듀서 인터셉터의 경우, 아파치 카프카의 프로듀서 설정에 인터셉터 클래스명을 지정하는 방식 외에도, 인터셉터를 스프링이 직접 관리하는 빈으로 설정할 수 있다. 그러려면 프로듀서 인터셉터를 `KafkaTemplate`에 설정해줘야 한다. 아래 예시는 앞에서 보여줬던 `MyProducerInterceptor`를 사용하지만, 이번에는 내부 컨피그 프로퍼티를 사용하지 않는다.

```java
public class MyProducerInterceptor implements ProducerInterceptor<String, String> {

    private final SomeBean bean;

    public MyProducerInterceptor(SomeBean bean) {
        this.bean = bean;
    }

    @Override
    public void configure(Map<String, ?> configs) {
    }

    @Override
    public ProducerRecord<String, String> onSend(ProducerRecord<String, String> record) {
        this.bean.someMethod("producer interceptor");
        return record;
    }

    @Override
    public void onAcknowledgement(RecordMetadata metadata, Exception exception) {
    }

    @Override
    public void close() {
    }

}
```

```java
@Bean
public MyProducerInterceptor myProducerInterceptor(SomeBean someBean) {
  return new MyProducerInterceptor(someBean);
}

@Bean
public KafkaTemplate<String, String> kafkaTemplate(ProducerFactory<String, String> pf, MyProducerInterceptor myProducerInterceptor) {
   KafkaTemplate<String, String> kafkaTemplate = new KafkaTemplate<>(pf);
   kafkaTemplate.setProducerInterceptor(myProducerInterceptor);
}
```

이제 레코드를 전송하기 직전에 프로듀서 인터셉터의 `onSend` 메소드를 실행한다. 서버에 데이터를 전송하고 ACK를 받으면 `onAcknowledgement` 메소드를 실행한다. `onAcknowledgement`는 프로듀서가 사용자 콜백을 실행하기 직전에 호출한다.

스프링을 통해 관리하고 `KafkaTemplate`에 적용할 프로듀서 인터셉터가 여러 개라면 `CompositeProducerInterceptor`를 사용해야 한다. `CompositeProducerInterceptor`는 프로듀서 인터셉터를 추가한 순서를 기억한다. 내부에 있는 각 `ProducerInterceptor` 구현체는 `CompositeProducerInterceptor`에 등록한 순서대로 호출한다.