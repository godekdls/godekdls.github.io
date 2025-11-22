---
title: Configuring Topics
category: Spring for Apache Kafka
order: 9
permalink: /Spring for Apache Kafka/configuring-topics/
description: 스프링 카프카로 토픽 설정하기
image: ./../../images/spring/logo.png
lastmod: 2025-09-12T23:34:00+09:00
comments: true
originalRefName: 스프링 카프카
originalRefLink: https://docs.spring.io/spring-kafka/reference/kafka/configuring-topics.html
parent: Reference
parentUrl: /Spring for Apache Kafka/reference/
subparent: Using Spring for Apache Kafka
subparentUrl: /Spring for Apache Kafka/kafka/
---
<script>defaultLanguages = ['java']</script>

---

애플리케이션 컨텍스트에 `KafkaAdmin` 빈을 정의하면 자동으로 브로커에 토픽을 추가할 수 있다. 그러려면 애플리케이션 컨텍스트에 각 토픽마다 `NewTopic` `@Bean`을 추가해주면 된다. 2.3 버전에서는 이런 빈을 더 쉽게 생성할 수 있도록 새로운 클래스 `TopicBuilder`를 도입했다. 다음은 이를 사용하는 예제다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">Java</span>
<span class="switch-language kotlin">Kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
@Bean
public KafkaAdmin admin() {
    Map<String, Object> configs = new HashMap<>();
    configs.put(AdminClientConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
    return new KafkaAdmin(configs);
}

@Bean
public NewTopic topic1() {
    return TopicBuilder.name("thing1")
        .partitions(10)
        .replicas(3)
        .compact()
        .build();
}

@Bean
public NewTopic topic2() {
    return TopicBuilder.name("thing2")
        .partitions(10)
        .replicas(3)
        .config(TopicConfig.COMPRESSION_TYPE_CONFIG, "zstd")
        .build();
}

@Bean
public NewTopic topic3() {
    return TopicBuilder.name("thing3")
        .assignReplicas(0, List.of(0, 1))
        .assignReplicas(1, List.of(1, 2))
        .assignReplicas(2, List.of(2, 0))
        .config(TopicConfig.COMPRESSION_TYPE_CONFIG, "zstd")
        .build();
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
@Bean
fun admin() = KafkaAdmin(mapOf(AdminClientConfig.BOOTSTRAP_SERVERS_CONFIG to "localhost:9092"))

@Bean
fun topic1() =
    TopicBuilder.name("thing1")
        .partitions(10)
        .replicas(3)
        .compact()
        .build()

@Bean
fun topic2() =
    TopicBuilder.name("thing2")
        .partitions(10)
        .replicas(3)
        .config(TopicConfig.COMPRESSION_TYPE_CONFIG, "zstd")
        .build()

@Bean
fun topic3() =
    TopicBuilder.name("thing3")
        .assignReplicas(0, Arrays.asList(0, 1))
        .assignReplicas(1, Arrays.asList(1, 2))
        .assignReplicas(2, Arrays.asList(2, 0))
        .config(TopicConfig.COMPRESSION_TYPE_CONFIG, "zstd")
        .build()
```

2.6 버전부터는 `partitions()`와 `replicas()`는 생략할 수 있으며, 해당 프로퍼티에는 브로커의 기본값이 적용된다. 이 기능을 사용하려면 브로커 버전이 최소 2.4.0 이상이어야 한다 ([KIP-464](https://cwiki.apache.org/confluence/display/KAFKA/KIP-464%3A+Defaults+for+AdminClient%23createTopic) 참고).

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">Java</span>
<span class="switch-language kotlin">Kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
@Bean
public NewTopic topic4() {
    return TopicBuilder.name("defaultBoth")
            .build();
}

@Bean
public NewTopic topic5() {
return TopicBuilder.name("defaultPart")
.replicas(1)
.build();
}

@Bean
public NewTopic topic6() {
return TopicBuilder.name("defaultRepl")
.partitions(3)
.build();
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
@Bean
fun topic4() = TopicBuilder.name("defaultBoth").build()

@Bean
fun topic5() = TopicBuilder.name("defaultPart").replicas(1).build()

@Bean
fun topic6() = TopicBuilder.name("defaultRepl").partitions(3).build()
```

2.7 버전부터는 `KafkaAdmin.NewTopics` 빈을 하나 정의하고 `NewTopic`을 여러 개 선언할 수 있다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">Java</span>
<span class="switch-language kotlin">Kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
@Bean
public KafkaAdmin.NewTopics topics456() {
    return new NewTopics(
            TopicBuilder.name("defaultBoth")
                .build(),
            TopicBuilder.name("defaultPart")
                .replicas(1)
                .build(),
            TopicBuilder.name("defaultRepl")
                .partitions(3)
                .build());
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
@Bean
fun topics456() = KafkaAdmin.NewTopics(
    TopicBuilder.name("defaultBoth")
        .build(),
    TopicBuilder.name("defaultPart")
        .replicas(1)
        .build(),
    TopicBuilder.name("defaultRepl")
        .partitions(3)
        .build()
)
```

> 스프링 부트를 사용한다면 `KafkaAdmin` 빈이 자동으로 등록되기 때문에, `NewTopic`(또는 `NewTopics`) `@Bean`만 있으면 된다.

브로커에 연결할 수 없는 경우 기본적으로 로그를 남기지만, 컨텍스트 로딩은 계속 진행한다. 어드민의 `initialize()` 메소드를 호출하면 이후 원할 때 재시도할 수 있다. 이런 상태를 그냥 넘어가고 싶지 않다면 어드민의 `fatalIfBrokerNotAvailable` 프로퍼티를 `true`로 설정해라. 그러면 컨텍스트 초기화에 실패한다.

> 브로커가 이를 지원하는 경우 (1.0.0 이상), 어드민은 기존 토픽의 파티션 수가 `NewTopic.numPartitions`보다 적다고 판단되면 파티션 수를 늘린다.

2.7 버전부터 `KafkaAdmin`은 런타임에 토픽을 생성하고 조사할 수 있는 메소드를 제공한다.

4.0 버전부터는 토픽을 삭제할 수 있는 메소드도 제공한다.

- `createOrModifyTopics`
- `describeTopics`
-  `deleteTopics` (since 4.0)

이런 토픽 관리 기능을 사용하려면 `AdminClient`를 직접 사용하면 된다. 그 방법은 다음 예제를 참고해라:

```java
@Autowired
private KafkaAdmin admin;

...

    AdminClient client = AdminClient.create(admin.getConfigurationProperties());
    ...
    client.close();
```

2.9.10, 3.0.9 버전부터 `Predicate<NewTopic>`을 제공해서 특정 `NewTopic` 빈을 생성/수정할지 판단하게 만들 수 있다. 예를 들어서, 서로 다른 클러스터를 가리키는 여러 가지 `KafkaAdmin` 인스턴스가 있을 때, 이를 활용해 각 어드민이 생성, 수정할 토픽을 선택할 수 있다.

```java
admin.setCreateOrModifyTopic(nt -> !nt.name().equals("dontCreateThisOne"));
```