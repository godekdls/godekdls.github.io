---
title: TimeLimiter
category: Resilience4j
order: 14
permalink: /Resilience4j/timelimiter/
description: TimeLimiter 모듈 기본 소개를 한글로 번역한 문서입니다. TimeLimiter 동작 원리와 설정값을 소개합니다.
image: ./../../images/resilience4j/logo.jpeg
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: resilience4j
originalRefLink: https://resilience4j.readme.io/v1.7.0/docs/timeout
---

### 목차

- [Create a TimeLimiterRegistry](#create-a-timelimiterregistry)
- [Create and configure TimeLimiter](#create-and-configure-timelimiter)
- [Decorate and execute a functional interface](#decorate-and-execute-a-functional-interface)

---

## Create a TimeLimiterRegistry

이 모듈은 CircuitBreaker 모듈과 동일하게 TimeLimiter 인스턴스들을 관리(생성/조회)할 수 있는 인 메모리 `TimeLimiterRegistry`를 제공한다.

```java
TimeLimiterRegistry timeLimiterRegistry = TimeLimiterRegistry.ofDefaults();
```

---

## Create and configure TimeLimiter

커스텀 글로벌 `TimeLimiterConfig`를 제공하는 것도 가능하다. 커스텀 글로벌 `TimeLimiterConfig`를 생성할 땐 TimeLimiterConfig 빌더를 사용하면 된다. 이 빌더를 통해 다음과 같은 프로퍼티를 설정할 수 있다:

- 타임 아웃
- 실행중인 future에서 cancel()을 호출해야 하는지 여부

```java
TimeLimiterConfig config = TimeLimiterConfig.custom()
   .cancelRunningFuture(true)
   .timeoutDuration(Duration.ofMillis(500))
   .build();

// Create a TimeLimiterRegistry with a custom global configuration
TimeLimiterRegistry timeLimiterRegistry = TimeLimiterRegistry.of(config);

// Get or create a TimeLimiter from the registry - 
// TimeLimiter will be backed by the default config
TimeLimiter timeLimiterWithDefaultConfig = registry.timeLimiter("name1");

// Get or create a TimeLimiter from the registry, 
// use a custom configuration when creating the TimeLimiter
TimeLimiterConfig config = TimeLimiterConfig.custom()
   .cancelRunningFuture(false)
   .timeoutDuration(Duration.ofMillis(1000))
   .build();

TimeLimiter timeLimiterWithCustomConfig = registry.timeLimiter("name2", config);
```

---

## Decorate and execute a functional interface

TimeLimiter는 `CompletionStage`, `Future`를 데코레이팅해서 실행 시간을 제한할 수 있는 고차원 데코레이터 함수를 가지고 있다.

```java
// Given I have a helloWorldService.sayHelloWorld() method which takes too long
HelloWorldService helloWorldService = mock(HelloWorldService.class);

// Create a TimeLimiter
TimeLimiter timeLimiter = TimeLimiter.of(Duration.ofSeconds(1));
// The Scheduler is needed to schedule a timeout on a non-blocking CompletableFuture
ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(3);

// The non-blocking variant with a CompletableFuture
CompletableFuture<String> result = timeLimiter.executeCompletionStage(
  scheduler, () -> CompletableFuture.supplyAsync(helloWorldService::sayHelloWorld)).toCompletableFuture();

// The blocking variant which is basically future.get(timeoutDuration, MILLISECONDS)
String result = timeLimiter.executeFutureSupplier(
  () -> CompletableFuture.supplyAsync(() -> helloWorldService::sayHelloWorld));
```