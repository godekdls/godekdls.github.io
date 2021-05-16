---
title: Introduction
category: Resilience4j
order: 2
permalink: /Resilience4j/introduction/
description: resilience4j의 기본적인 개념과 예제, 모듈 소개 한글 번역
image: ./../../images/resilience4j/logo.jpeg
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: resilience4j
originalRefLink: https://resilience4j.readme.io/v1.7.0/docs/getting-started
boundary: GETTING STARTED
---

### 목차

- [Sneak preview](#sneak-preview)
- [Modularization](#modularization)
- [All core modules and the Decorators class](#all-core-modules-and-the-decorators-class)
- [Core modules](#core-modules)
- [Add-on modules](#add-on-modules)
  + [Frameworks modules](#frameworks-modules)
  + [Reactive modules](#reactive-modules)
  + [Metrics modules](#metrics-modules)
- [3rd party modules](#3rd-party-modules)

---

Resilience4j는 사용하기 쉬운 경량 fault tolerance 라이브러리로, 영감은 [넷플릭스 히스트릭스](https://github.com/Netflix/Hystrix)에서 받았지만, 자바 8과 함수형 프로그래밍을 위해 설계했다. Resilience4j가 사용하는 라이브러리는 다른 외부 라이브러리에 의존하지 않는 [Vavr](http://www.vavr.io/) 뿐이기 때문에 가볍다. 반면 넷플릭스 히스트릭스는 Archaius에 컴파일 의존성이 있는데, Archaius는 Guava, Apache Commons Configuration 등 훨씬 더 많은 외부 라이브러리에 의존한다.

Resilience4j는 Circuit Breaker나, Rate Limiter, Retry, Bulkhead를 사용해 모든 함수형 인터페이스와, 람다 표현식, 메소드 참조를 한 단계 더 진전시키는 고차 함수(데코레이터)를 제공한다. 함수형 인터페이스, 람다 표현식, 메소드 참조라면 모두 데코레이터를 둘 이상도 포갤 수 있다. 필요한 데코레이터만 직접 선택할 수 있다는 장점도 있다.

Resilience4j를 사용하면 복잡하게 갈 필요 없이, 진짜 필요한 것만 선택해 쓸 수 있다.

---

## Sneak preview

다음 예제에서는 CircuitBreaker와 Retry로 람다 표현식을 데코레이팅해서 예외 발생 시 최대 3번까지 재시도하는 방법을 보여준다.
재시도 사이 사이 대기할 인터벌이나, 커스텀 백오프 알고리즘도 설정할 수 있다.
이 예시에선 Vavr의 `Try` 모나드를 사용해 예외를 복구시키며, 모든 재시도 끝에도 실패했다면 다른 람다 표현식을 폴백으로 실행한다.

```java
// Create a CircuitBreaker with default configuration
CircuitBreaker circuitBreaker = CircuitBreaker
  .ofDefaults("backendService");

// Create a Retry with default configuration
// 3 retry attempts and a fixed time interval between retries of 500ms
Retry retry = Retry
  .ofDefaults("backendService");

// Create a Bulkhead with default configuration
Bulkhead bulkhead = Bulkhead
  .ofDefaults("backendService");

Supplier<String> supplier = () -> backendService
  .doSomething(param1, param2)

// Decorate your call to backendService.doSomething() 
// with a Bulkhead, CircuitBreaker and Retry
// **note: you will need the resilience4j-all dependency for this
Supplier<String> decoratedSupplier = Decorators.ofSupplier(supplier)
  .withCircuitBreaker(circuitBreaker)
  .withBulkhead(bulkhead)
  .withRetry(retry)  
  .decorate();

// Execute the decorated supplier and recover from any exception
String result = Try.ofSupplier(decoratedSupplier)
  .recover(throwable -> "Hello from Recovery").get();

// When you don't want to decorate your lambda expression,
// but just execute it and protect the call by a CircuitBreaker.
String result = circuitBreaker
  .executeSupplier(backendService::doSomething);

// You can also run the supplier asynchronously in a ThreadPoolBulkhead
 ThreadPoolBulkhead threadPoolBulkhead = ThreadPoolBulkhead
  .ofDefaults("backendService");

// The Scheduler is needed to schedule a timeout 
// on a non-blocking CompletableFuture
ScheduledExecutorService scheduledExecutorService = Executors.newScheduledThreadPool(3);
TimeLimiter timeLimiter = TimeLimiter.of(Duration.ofSeconds(1));

CompletableFuture<String> future = Decorators.ofSupplier(supplier)
    .withThreadPoolBulkhead(threadPoolBulkhead)
    .withTimeLimiter(timeLimiter, scheduledExecutorService)
    .withCircuitBreaker(circuitBreaker)
    .withFallback(asList(TimeoutException.class, 
                         CallNotPermittedException.class, 
                         BulkheadFullException.class),  
                  throwable -> "Hello from Recovery")
    .get().toCompletableFuture();
```

---

## Modularization

Resilience4j를 사용하면 복잡하게 갈 필요 없이, 진짜 필요한 것만 선택해 쓸 수 있다.

Resilience4는 몇 가지 코어 모듈과 애드온 모듈을 제공한다:

---

## All core modules and the Decorators class

- `resilience4j-all`

---

## Core modules

- `resilience4j-circuitbreaker`: Circuit breaking
- `resilience4j-ratelimiter`: Rate limiting
- `resilience4j-bulkhead`: Bulkheading
- `resilience4j-retry`: Automatic retrying (sync, async)
- `resilience4j-cache`: Result caching
- `resilience4j-timelimiter`: Timeout handling

---

## Add-on modules

- `resilience4j-retrofit`: Retrofit 어댑터
- `resilience4j-feign`: Feign 어댑터
- `resilience4j-consumer`: 원형 버버 이벤트 컨슈머
- `resilience4j-kotlin`: 코틀린 코루틴 지원

### Frameworks modules

- `resilience4j-spring-boot`: 스프링 부트 스타터
- `resilience4j-spring-boot2`: 스프링 부트 2 스타터
- `resilience4j-ratpack`: Ratpack 스타터
- `resilience4j-vertx`: Vertx Future 데코레이터

### Reactive modules

- `resilience4j-rxjava2`: 커스텀 RxJava2 연산자
- `resilience4j-reactor`: 커스텀 스프링 리액터 연산자

### Metrics modules

- `resilience4j-micrometer`: Micrometer Metrics exporter
- `resilience4j-metrics`: Dropwizard Metrics exporter
- `resilience4j-prometheus`: Prometheus Metrics exporter

---

## 3rd party modules

- [Camel Circuit Breaker](https://camel.apache.org/manual/latest/resilience4j-eip.html)
- [Spring Cloud Circuit Breaker](https://spring.io/projects/spring-cloud-circuitbreaker)
- [http4k resilience module](https://www.http4k.org/guide/modules/resilience/)