---
title: Thread Safety
category: Spring for Apache Kafka
order: 18
permalink: /Spring for Apache Kafka/thread-safety/
description: todo
image: ./../../images/spring/logo.png
lastmod: 2025-09-12T23:34:00+09:00
comments: true
originalRefName: 스프링 카프카
originalRefLink: https://docs.spring.io/spring-kafka/reference/kafka/thread-safety.html
parent: Reference
parentUrl: /Spring for Apache Kafka/reference/
subparent: Using Spring for Apache Kafka
subparentUrl: /Spring for Apache Kafka/kafka/
---

---

`ConcurrentMessageListenerContainer`를 사용할 때는 하나의 리스너 인스턴스가 모든 컨슈머 스레드에서 호출된다. 따라서 리스너는 스레드로부터 안전<sup>thread-safe</sup>해야 하며, 가능하면 상태가 없는<sup>stateless</sup> 리스너를 사용하는 것이 좋다. 리스너를 스레드로부터 안전하게 만들 수 없거나, 동기화 로직을 추가하는 게 concurrency의 이점을 크게 감소시킨다면, 아래 기법 중 하나를 사용할 수 있다:

- `concurrency=1`인 컨테이너 `n`개와 프로토타입 스코프의 `MessageListener` 빈을 사용해 모든 컨테이너가 자체 인스턴스를 가지도록 만든다 (이 방법은 `@KafkaListener`를 사용할 경우 불가능하다).
- `ThreadLocal<?>` 인스턴스에 상태를 저장한다.
- 싱글톤 리스너가 `SimpleThreadScope`(또는 이와 유사한 스코프)로 선언된 빈에 동작을 위임하게 만든다.

스레드 상태를 쉽게 정리할 수 있도록 (두 번째와 세 번째 방법에서), 2.2 버전부터 리스너 컨테이너는 각 스레드가 종료될 때 `ConsumerStoppedEvent`를 발행한다. `ApplicationListener`나 `@EventListener` 메소드로 이 이벤트를 수신해 `ThreadLocal<?>` 인스턴스를 제거하거나, 스레드 스코프에서 해당 빈으로 `remove()`를 호출해라. 참고로, `SimpleThreadScope`는 `DisposableBean` 같은 정리용 인터페이스를 가진 빈을 파기하지 않으므로, 인스턴스에서 직접 `destroy()`를 호출해야 한다.

> 기본적으로 애플리케이션 컨텍스트의 이벤트 멀티캐스터는 이벤트 리스너를 호출 스레드에서 실행한다. 멀티캐스터를 async executor를 사용하도록 변경하면 스레드가 제대로 정리되지 않을 수 있다.

---

## Special Note on Virtual Threads and Concurrent Message Listener Containers

아직까지 내부 라이브러리에 있는 일부 클래스는 스레드 동기화를 위해 `synchronized` 블록을 사용하고 있기 때문에, `ConcurrentMessageListenerContainer`를 virtual thread와 함께 사용할 때는 주의해서 사용해야 한다. virtual thread를 활성화한 상태에서, 설정한 concurrency가 사용 가능한 platform thread 수를 초과하면, virtual thread가 platform thread 위에 고정될 가능성이 매우 높아지고, 그 과정에서 경쟁 상태<sup>race condition</sup>가 발생할 수 있다. 따라서 스프링 카프카가 사용하는 써드 파티 라이브러리들이 virtual thread를 완전히 지원하기 전까지는, 메시지 리스너 컨테이너의 concurrency 값을 platform thread 수와 같거나 더 낮게 유지하는 것을 권장한다. 이렇게 하면 virtual thread가 platform thread에 고정되면서 발생하는 경쟁 상태<sup>race condition</sup>를 피할 수 있다.