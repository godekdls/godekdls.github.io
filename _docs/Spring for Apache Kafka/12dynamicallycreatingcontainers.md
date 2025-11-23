---
title: Dynamically Creating Containers
category: Spring for Apache Kafka
order: 13
permalink: /Spring for Apache Kafka/dynamic-containers/
description: 컨테이너 동적으로 생성하기
image: ./../../images/spring/logo.png
lastmod: 2025-09-12T23:34:00+09:00
comments: true
originalRefName: 스프링 카프카
originalRefLink: https://docs.spring.io/spring-kafka/reference/kafka/dynamic-containers.html
parent: Reference
parentUrl: /Spring for Apache Kafka/reference/
subparent: Using Spring for Apache Kafka
subparentUrl: /Spring for Apache Kafka/kafka/
---
<script>defaultLanguages = ['java']</script>

---

리스너 컨테이너를 런타임에 생성하는 기법은 여러 가지 있다. 이번 섹션에선 그 기법들 중 몇 가지를 살펴본다.

### 목차

- [MessageListener Implementations](#messagelistener-implementations)
- [Prototype Beans](#prototype-beans)

---

## MessageListener Implementations

리스너를 직접 구현한다면, 간단하게 컨테이너 팩토리를 사용해 자체 리스너를 위한 기본 컨테이너를 생성하면 된다:

*User Listener*

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">Java</span>
<span class="switch-language kotlin">Kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
public class MyListener implements MessageListener<String, String> {

    @Override
    public void onMessage(ConsumerRecord<String, String> data) {
        // ...
    }

}

private ConcurrentMessageListenerContainer<String, String> createContainer(
        ConcurrentKafkaListenerContainerFactory<String, String> factory, String topic, String group) {

    ConcurrentMessageListenerContainer<String, String> container = factory.createContainer(topic);
    container.getContainerProperties().setMessageListener(new MyListener());
    container.getContainerProperties().setGroupId(group);
    container.setBeanName(group);
    container.start();
    return container;
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
class MyListener : MessageListener<String, String> {

    override fun onMessage(data: ConsumerRecord<String, String>) {

        // ...
    }

}

private fun createContainer(
    factory: ConcurrentKafkaListenerContainerFactory<String, String>, topic: String, group: String
): ConcurrentMessageListenerContainer<String, String> {
    val container = factory.createContainer(topic)
    container.containerProperties.setMessageListener(MyListener())
    container.containerProperties.setGroupId(group)
    container.beanName = group
    container.start()
    return container
}
```

---

## Prototype Beans

`@KafkaListener`를 선언한 메소드를 지원할 컨테이너는, 프로토타입 빈으로 선언하면 동적으로 생성할 수 있다:

*Prototype*

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">Java</span>
<span class="switch-language kotlin">Kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
public class MyPojo {

    private final String id;

    private final String topic;

    public MyPojo(String id, String topic) {
        this.id = id;
        this.topic = topic;
    }

    public String getId() {
        return this.id;
    }

    public String getTopic() {
        return this.topic;
    }

    @KafkaListener(id = "#{__listener.id}", topics = "#{__listener.topic}")
    public void listen(String in) {
        System.out.println(in);
    }

}

@Bean
@Scope(ConfigurableBeanFactory.SCOPE_PROTOTYPE)
MyPojo pojo(String id, String topic) {
    return new MyPojo(id, topic);
}

applicationContext.getBean(MyPojo.class, "one", "topic2");
applicationContext.getBean(MyPojo.class, "two", "topic3");
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
class MyPojo(val id: String, val topic: String) {

    @KafkaListener(id = "#{__listener.id}", topics = ["#{__listener.topic}"])
    fun listen(`in`: String?) {
        println(`in`)
    }

}

@Bean
@Scope(ConfigurableBeanFactory.SCOPE_PROTOTYPE)
fun pojo(id: String, topic: String): MyPojo {
    return MyPojo(id, topic)
}

applicationContext.getBean(MyPojo::class.java, "one", "topic2")
applicationContext.getBean(MyPojo::class.java, "two", "topic3")
```


> 리스너는 반드시 고유한 ID를 가져야 한다. 2.8.9 버전부터 `KafkaListenerEndpointRegistry`는 `unregisterListenerContainer(String id)` 메소드를 제공해서 ID를 재사용할 수 있다. 컨테이너를 등록 해제<sup>unregister</sup>해도 `stop()`이 호출되는 것은 아니니, 정지는 직접 해야 한다.