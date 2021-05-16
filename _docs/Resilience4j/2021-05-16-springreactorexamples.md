---
title: Spring Reactor Examples
navTitle: Examples
category: Resilience4j
order: 22
permalink: /Resilience4j/spring-reactor-examples/
description: resilience4j-reactor 모듈 사용 예시
image: ./../../images/resilience4j/logo.jpeg
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: resilience4j
originalRefLink: https://resilience4j.readme.io/v1.7.0/docs/examples-1
---

### 목차

- [Decorate Mono or Flux with a CircuitBreaker](#decorate-mono-or-flux-with-a-circuitbreaker)
- [Decorate Mono or Flux with a RateLimiter](#decorate-mono-or-flux-with-a-ratelimiter)
- [Decorate Mono or Flux with a Bulkhead](#decorate-mono-or-flux-with-a-bulkhead)
- [Decorate Mono or Flux with Retry](#decorate-mono-or-flux-with-retry)

---

## Decorate Mono or Flux with a CircuitBreaker

다음 예제는 커스텀 리액터 연산자를 사용해서 Mono를 데코레이트하는 방법을 보여준다. Flux도 지원한다.

`CircuitBreakerOperator`는 다운스트림 subscriber/observer가 업스트림 Publisher를 구독할 수 있는 권한을 얻을 수 있는지 확인한다. CircuitBreakerOperator는 CircuitBreaker가 OPEN 상태면 다운스트림 subscriber에게 `CallNotPermittedException`을 방출한다.

```java
CircuitBreaker circuitBreaker = CircuitBreaker.ofDefaults("name");
Mono.fromCallable(backendService::doSomething)
    .transformDeferred(CircuitBreakerOperator.of(circuitBreaker))
```

---

## Decorate Mono or Flux with a RateLimiter

다음 예제는 커스텀 리액터 연산자를 사용해서 Mono를 데코레이트하는 방법을 보여준다. Flux도 지원한다.

`RateLimiterOperator`는 다운스트림 subscriber/observer가 업스트림 Publisher를 구독할 수 있는 권한을 얻을 수 있는지 확인한다. RateLimiterOperator는 Rate limit을 초과하면 업스트림의 데이터 요청을 지연시키거나 다운스트림 subscriber에게 `RequestNotPermitted` 에러를 방출할 수 있다.

```java
RateLimiter rateLimiter = RateLimiter.ofDefaults("name");
Mono.fromCallable(backendService::doSomething)
    .transformDeferred(RateLimiterOperator.of(rateLimiter))
```

---

## Decorate Mono or Flux with a Bulkhead

다음 예제는 커스텀 리액터 연산자를 사용해서 Mono를 데코레이트하는 방법을 보여준다. Flux도 지원한다.

`BulkheadOperator`는 다운스트림 subscriber/observer가 업스트림 Publisher를 구독할 수 있는 권한을 얻을 수 있는지 확인한다. BulkheadOperator는 Bulkhead가 가득차면 다운스트림 subscriber에게 `BulkheadFullException`을 방출한다.

```java
Bulkhead bulkhead = Bulkhead.ofDefaults("name");
Mono.fromCallable(backendService::doSomething)
  .transformDeferred(BulkheadOperator.of(bulkhead));
```

---

## Decorate Mono or Flux with Retry

```java
Retry retry = Retry.ofDefaults("backendName");
Mono.fromCallable(backendService::doSomething)
    .transformDeferred(RetryOperator.of(retry))
```