---
title: Wiring Spring Beans into Producer/Consumer Interceptors
category: Spring for Apache Kafka
order: 22
permalink: /Spring for Apache Kafka/interceptors/
description: 프로듀서/컨슈머 인터셉터에 스프링 빈 주입하기
image: ./../../images/spring/logo.png
lastmod: 2025-09-12T23:34:00+09:00
comments: true
originalRefName: 스프링 카프카
originalRefLink: https://docs.spring.io/spring-kafka/reference/kafka/interceptors.html
parent: Reference
parentUrl: /Spring for Apache Kafka/reference/
subparent: Using Spring for Apache Kafka
subparentUrl: /Spring for Apache Kafka/kafka/
---

---

아파치 카프카를 사용할 때에는 프로듀서와 컨슈머에 인터셉터를 추가할 수 있다. 이 인터셉터 객체들은 스프링이 아닌 카프카가 직접 관리하기 때문에, 일반적인 스프링 의존성 주입 방식으로는 스프링 빈을 주입할 수 없다. 이때는 인터셉터의 `config()` 메소드를 사용해 의존성을 수동으로 주입할 수 있다. 아래 있는 스프링 부트 애플리케이션 예시에서는, 스프링 부트의 디폴트 팩토리를 재정의해서 설정 프로퍼티에 사용할 빈을 추가하고 있다:

```java
@SpringBootApplication
public class Application {

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }

    @Bean
    public ConsumerFactory<?, ?> kafkaConsumerFactory(SomeBean someBean) {
        Map<String, Object> consumerProperties = new HashMap<>();
        // consumerProperties.put(..., ...)
        // ...
        consumerProperties.put(ConsumerConfig.INTERCEPTOR_CLASSES_CONFIG, MyConsumerInterceptor.class.getName());
        consumerProperties.put("some.bean", someBean);
        return new DefaultKafkaConsumerFactory<>(consumerProperties);
    }

    @Bean
    public ProducerFactory<?, ?> kafkaProducerFactory(SomeBean someBean) {
        Map<String, Object> producerProperties = new HashMap<>();
        // producerProperties.put(..., ...)
        // ...
        producerProperties.put(ProducerConfig.INTERCEPTOR_CLASSES_CONFIG, MyProducerInterceptor.class.getName());
        producerProperties.put("some.bean", someBean);
        return new DefaultKafkaProducerFactory<>(producerProperties);
    }

    @Bean
    public SomeBean someBean() {
        return new SomeBean();
    }

    @KafkaListener(id = "kgk897", topics = "kgh897")
    public void listen(String in) {
        System.out.println("Received " + in);
    }

    @Bean
    public ApplicationRunner runner(KafkaTemplate<String, String> template) {
        return args -> template.send("kgh897", "test");
    }

    @Bean
    public NewTopic kRequests() {
        return TopicBuilder.name("kgh897")
            .partitions(1)
            .replicas(1)
            .build();
    }

}
```

```java
public class SomeBean {

    public void someMethod(String what) {
        System.out.println(what + " in my foo bean");
    }

}
```

```java
public class MyProducerInterceptor implements ProducerInterceptor<String, String> {

    private SomeBean bean;

    @Override
    public void configure(Map<String, ?> configs) {
        this.bean = (SomeBean) configs.get("some.bean");
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
public class MyConsumerInterceptor implements ConsumerInterceptor<String, String> {

    private SomeBean bean;

    @Override
    public void configure(Map<String, ?> configs) {
        this.bean = (SomeBean) configs.get("some.bean");
    }

    @Override
    public ConsumerRecords<String, String> onConsume(ConsumerRecords<String, String> records) {
        this.bean.someMethod("consumer interceptor");
        return records;
    }

    @Override
    public void onCommit(Map<TopicPartition, OffsetAndMetadata> offsets) {
    }

    @Override
    public void close() {
    }

}
```

결과:

```java
producer interceptor in my foo bean
consumer interceptor in my foo bean
Received test
```