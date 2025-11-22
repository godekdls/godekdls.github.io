---
title: Quick Tour
category: Spring for Apache Kafka
order: 5
permalink: /Spring for Apache Kafka/quick-tour/
description: 스프링 카프카 시작하기
image: ./../../images/spring/logo.png
lastmod: 2025-09-12T23:34:00+09:00
comments: true
originalRefName: 스프링 카프카
originalRefLink: https://docs.spring.io/spring-kafka/reference/kafka/quick-tour.html
parent: Introduction
parentUrl: /Spring for Apache Kafka/introduction/
---
<script>defaultLanguages = ['maven', 'java']</script>

### 목차

- [Compatibility](#compatibility)
- [Getting Started](#getting-started)
  + [Spring Boot Consumer App](#spring-boot-consumer-app)
  + [Spring Boot Producer App](#spring-boot-producer-app) 
  + [With Java Configuration (No Spring Boot)](#with-java-configuration-no-spring-boot)

---

필수 조건: Apache Kafka를 설치하고 실행해야 한다. 그리고 클래스패스에 스프링 카프카 JAR 파일(`spring-kafka`)과 모든 의존성이 존재해야 한다. 빌드 툴을 사용 중이라면 간단히 의존성을 선언해주면 된다.

스프링 부트를 사용하지 않는다면, `spring-kafka` jar를 프로젝트 의존성으로 선언해라.

<div class="switch-language-wrapper maven gradle">
<span class="switch-language maven">Maven</span>
<span class="switch-language gradle">Gradle</span>
</div>
<div class="language-only-for-maven maven gradle"></div>
```xml
<dependency>
  <groupId>org.springframework.kafka</groupId>
  <artifactId>spring-kafka</artifactId>
  <version>3.3.10</version>
</dependency>
```
<div class="language-only-for-gradle maven gradle"></div>
```groovy
compile 'org.springframework.kafka:spring-kafka:3.3.10'
```

> 스프링 부트를 사용한다면 (그리고 start.spring.io로 프로젝트를 생성하지 않았다면), 버전을 생략해도 스프링 부트가 자동으로 호환되는 적당한 버전을 다운받는다:

<div class="switch-language-wrapper maven gradle">
<span class="switch-language maven">Maven</span>
<span class="switch-language gradle">Gradle</span>
</div>
<div class="language-only-for-maven maven gradle"></div>
```xml
<dependency>
  <groupId>org.springframework.kafka</groupId>
  <artifactId>spring-kafka</artifactId>
</dependency>
```
<div class="language-only-for-gradle maven gradle"></div>
```groovy
implementation 'org.springframework.kafka:spring-kafka'
```

하지만 [start.spring.io](https://start.spring.io/)(Spring Tool Suits와 Intellij IDEA의 프로젝트 생성 도우미)를 이용해 프로젝트를 생성하고, 의존성으로 'Spring for Apache Kafka'를 선택하는 방법이 가장 쉽고 빠르다.

---

## Compatibility

이 가이드에서는 다음과 같은 버전을 사용한다:

- Apache Kafka Clients 4.0.x
- Spring Framework 7.0.0x
- 자바 최소 버전: 17

---

## Getting Started

스프링 카프카를 가장 빠르게 시작하고 싶다면 [start.spring.io](https://start.spring.io/)(Spring Tool Suits와 Intellij IDEA의 프로젝트 생성 도우미)를 이용해 프로젝트를 생성하고, 의존성으로 'Spring for Apache Kafka'를 선택하면 된다. 스프링 부트가 자동으로 설정해주는 내부 빈들에 대한 자세한 설명은 [스프링 부트 문서](../../Spring%20Boot/messaging/#7143-apache-kafka-support)를 참고해라.

다음은 최소한의 코드로 작성한 컨슈머 애플리케이션이다.

### Spring Boot Consumer App

*Application*

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">Java</span>
<span class="switch-language kotlin">Kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
@SpringBootApplication
public class Application {

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }

    @Bean
    public NewTopic topic() {
        return TopicBuilder.name("topic1")
                .partitions(10)
                .replicas(1)
                .build();
    }

    @KafkaListener(id = "myId", topics = "topic1")
    public void listen(String in) {
        System.out.println(in);
    }

}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
@SpringBootApplication
class Application {

    @Bean
    fun topic() = NewTopic("topic1", 10, 1)

    @KafkaListener(id = "myId", topics = ["topic1"])
    fun listen(value: String?) {
        println(value)
    }

}

fun main(args: Array<String>) = runApplication<Application>(*args)
```

*application.properties*

```properties
spring.kafka.consumer.auto-offset-reset=earliest
```

`NewTopic` 빈 덕분에 브로커에 토픽이 생성된다. 토픽이 이미 있다면 설정하지 않아도 된다.

### Spring Boot Producer App

*Application*

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">Java</span>
<span class="switch-language kotlin">Kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
@SpringBootApplication
public class Application {

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }

    @Bean
    public NewTopic topic() {
        return TopicBuilder.name("topic1")
                .partitions(10)
                .replicas(1)
                .build();
    }

    @Bean
    public ApplicationRunner runner(KafkaTemplate<String, String> template) {
        return args -> {
            template.send("topic1", "test");
        };
    }

}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
@SpringBootApplication
class Application {

    @Bean
    fun topic() = NewTopic("topic1", 10, 1)

    @Bean
    fun runner(template: KafkaTemplate<String?, String?>) =
        ApplicationRunner { template.send("topic1", "test") }

    companion object {
        @JvmStatic
        fun main(args: Array<String>) = runApplication<Application>(*args)
    }

}
```

### With Java Configuration (No Spring Boot)

> 스프링 카프카는 스프링 애플리케이션 컨텍스트 내에서 사용하는 용도로 설계됐다. 예를 들어, 스프링 컨텍스트 밖에서 직접 리스너 컨테이너를 생성하는 경우, 컨테이너가 구현하는 모든 `...Aware` 인터페이스에 필요한 것들을 직접 처리하지 않으면 일부 기능이 동작하지 않을 수 있다.

다음은 스프링 부트를 사용하지 않는 애플리케이션의 예시다. 이 애플리케이션은 `Consumer`와 `Producer`를 모두 다룬다.

*Without Spring Boot*

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">Java</span>
<span class="switch-language kotlin">Kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
public class Sender {

    public static void main(String[] args) {
        AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(Config.class);
        context.getBean(Sender.class).send("test", 42);
    }

    private final KafkaTemplate<Integer, String> template;

    public Sender(KafkaTemplate<Integer, String> template) {
        this.template = template;
    }

    public void send(String toSend, int key) {
        this.template.send("topic1", key, toSend);
    }

}

public class Listener {

    @KafkaListener(id = "listen1", topics = "topic1")
    public void listen1(String in) {
        System.out.println(in);
    }

}

@Configuration
@EnableKafka
public class Config {

    @Bean
    ConcurrentKafkaListenerContainerFactory<Integer, String>
                        kafkaListenerContainerFactory(ConsumerFactory<Integer, String> consumerFactory) {
        ConcurrentKafkaListenerContainerFactory<Integer, String> factory =
                                new ConcurrentKafkaListenerContainerFactory<>();
        factory.setConsumerFactory(consumerFactory);
        return factory;
    }

    @Bean
    public ConsumerFactory<Integer, String> consumerFactory() {
        return new DefaultKafkaConsumerFactory<>(consumerProps());
    }

    private Map<String, Object> consumerProps() {
        Map<String, Object> props = new HashMap<>();
        props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
        props.put(ConsumerConfig.GROUP_ID_CONFIG, "group");
        props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, IntegerDeserializer.class);
        props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);
        props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");
        // ...
        return props;
    }

    @Bean
    public Sender sender(KafkaTemplate<Integer, String> template) {
        return new Sender(template);
    }

    @Bean
    public Listener listener() {
        return new Listener();
    }

    @Bean
    public ProducerFactory<Integer, String> producerFactory() {
        return new DefaultKafkaProducerFactory<>(senderProps());
    }

    private Map<String, Object> senderProps() {
        Map<String, Object> props = new HashMap<>();
        props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
        props.put(ProducerConfig.LINGER_MS_CONFIG, 10);
        props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, IntegerSerializer.class);
        props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class);
        //...
        return props;
    }

    @Bean
    public KafkaTemplate<Integer, String> kafkaTemplate(ProducerFactory<Integer, String> producerFactory) {
        return new KafkaTemplate<>(producerFactory);
    }

}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
class Sender(private val template: KafkaTemplate<Int, String>) {

    fun send(toSend: String, key: Int) {
        template.send("topic1", key, toSend)
    }

}

class Listener {

    @KafkaListener(id = "listen1", topics = ["topic1"])
    fun listen1(`in`: String) {
        println(`in`)
    }

}

@Configuration
@EnableKafka
class Config {

    @Bean
    fun kafkaListenerContainerFactory(consumerFactory: ConsumerFactory<Int, String>) =
        ConcurrentKafkaListenerContainerFactory<Int, String>().also { it.consumerFactory = consumerFactory }


    @Bean
    fun consumerFactory() = DefaultKafkaConsumerFactory<Int, String>(consumerProps)

    val consumerProps = mapOf(
        ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG to "localhost:9092",
        ConsumerConfig.GROUP_ID_CONFIG to "group",
        ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG to IntegerDeserializer::class.java,
        ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG to StringDeserializer::class.java,
        ConsumerConfig.AUTO_OFFSET_RESET_CONFIG to "earliest"
    )

    @Bean
    fun sender(template: KafkaTemplate<Int, String>) = Sender(template)

    @Bean
    fun listener() = Listener()

    @Bean
    fun producerFactory() = DefaultKafkaProducerFactory<Int, String>(senderProps)

    val senderProps = mapOf(
        ProducerConfig.BOOTSTRAP_SERVERS_CONFIG to "localhost:9092",
        ProducerConfig.LINGER_MS_CONFIG to 10,
        ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG to IntegerSerializer::class.java,
        ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG to StringSerializer::class.java
    )

    @Bean
    fun kafkaTemplate(producerFactory: ProducerFactory<Int, String>) = KafkaTemplate(producerFactory)

}
```

보다시피, 스프링 부트를 사용하지 않을 때는 여러 가지 빈들을 직접 정의해야 한다.