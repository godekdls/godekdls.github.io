---
title: Pausing and Resuming Listener Containers
category: Spring for Apache Kafka
order: 24
permalink: /Spring for Apache Kafka/pause-resume/
description: 리스너 컨테이너 일시중단하고 재개하기
image: ./../../images/spring/logo.png
lastmod: 2025-09-12T23:34:00+09:00
comments: true
originalRefName: 스프링 카프카
originalRefLink: https://docs.spring.io/spring-kafka/reference/kafka/pause-resume.html
parent: Reference
parentUrl: /Spring for Apache Kafka/reference/
subparent: Using Spring for Apache Kafka
subparentUrl: /Spring for Apache Kafka/kafka/
---

---

2.1.3 버전에서는 리스너 컨테이너에 `pause()`, `resume()` 메소드가 추가됐다. 이전에는 `ConsumerAwareMessageListener` 안에서 직접 컨슈머를 중지시키고, `Consumer` 객체에 접근할 수 있는 `ListenerContainerIdleEvent`를 수신해 컨슈밍을 재개할 수 있었다. 이벤트 리스너를 통해 유휴 상태인<sup>idle</sup> 컨테이너에서 컨슈머를 일시 중단할 수는 있었지만, 이벤트 리스너를 컨슈머 스레드에서 실행한다는 보장이 없기 때문에 어떤 경우에는 스레드로부터 안전하지 않았다. 컨슈머를 안전하게 일시 중지하고 재개하려면, 리스너 컨테이너의 `pause()`, `resume()` 메소드를 사용해야 한다. `pause()`는 다음 `poll()` 직전에 적용되고, `resume()`은 현재 `poll()`이 반환된 직후에 적용된다. 컨테이너가 일시 중단되면, 컨슈머 그룹<sup>group management</sup>을 사용 중인 경우, 리밸런싱을 방지하기 위해 컨슈머를 계속 폴링<sup>`poll()`</sup>하지만 레코드를  받아오지는 않는다. 자세한 내용은 카프카 문서를 참고해라.

2.1.5 버전부터 `isPauseRequested()`를 통해 `pause()`의 호출 여부를 확인할 수 있다. 하지만 실제로 컨슈머는 아직 중단되지 않았을 수도 있다. `isConsumerPaused()`는 모든 `Consumer` 인스턴스가 실제로 일시 중지된 경우 true를 반환한다.

또한 2.1.5 이후부터는, `source` 프로퍼티에 컨테이너를, `partitions` 프로퍼티엔 `TopicPartition` 인스턴스를 담고 있는 `ConsumerPausedEvent`와 `ConsumerResumedEvent`를 발행한다.

2.9 버전부터 새로운 컨테이너 프로퍼티 `pauseImmediate`를 true로 설정하면, 현재 레코드만 처리한 후 바로 컨슈밍을 일시 중단한다. 원래는 이전에 폴링한 모든 레코드를 처리한 후에 컨슈밍을 중단한다. [pauseImmediate](https://docs.spring.io/spring-kafka/reference/kafka/container-props.html#pauseImmediate)을 참고해라.

다음은 컨테이너 레지스트리를 사용해 `@KafkaListener` 메소드의 컨테이너에 대한 참조를 가져오고, 해당 컨슈머를 일시 중지하거나 다시 시작하고, 관련 이벤트를 수신하는 간단한 스프링 부트 애플리케이션이다:

```java
@SpringBootApplication
public class Application implements ApplicationListener<KafkaEvent> {

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args).close();
    }

    @Override
    public void onApplicationEvent(KafkaEvent event) {
        System.out.println(event);
    }

    @Bean
    public ApplicationRunner runner(KafkaListenerEndpointRegistry registry,
            KafkaTemplate<String, String> template) {
        return args -> {
            template.send("pause.resume.topic", "thing1");
            Thread.sleep(10_000);
            System.out.println("pausing");
            registry.getListenerContainer("pause.resume").pause();
            Thread.sleep(10_000);
            template.send("pause.resume.topic", "thing2");
            Thread.sleep(10_000);
            System.out.println("resuming");
            registry.getListenerContainer("pause.resume").resume();
            Thread.sleep(10_000);
        };
    }

    @KafkaListener(id = "pause.resume", topics = "pause.resume.topic")
    public void listen(String in) {
        System.out.println(in);
    }

    @Bean
    public NewTopic topic() {
        return TopicBuilder.name("pause.resume.topic")
            .partitions(2)
            .replicas(1)
            .build();
    }

}
```

위 예제를 실행한 결과는 다음과 같다:

```none
partitions assigned: [pause.resume.topic-1, pause.resume.topic-0]
thing1
pausing
ConsumerPausedEvent [partitions=[pause.resume.topic-1, pause.resume.topic-0]]
resuming
ConsumerResumedEvent [partitions=[pause.resume.topic-1, pause.resume.topic-0]]
thing2
```
