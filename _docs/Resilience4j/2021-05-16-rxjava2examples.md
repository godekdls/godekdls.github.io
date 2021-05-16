---
title: RXJAVA2 Examples
navTitle: Examples
category: Resilience4j
order: 20
permalink: /Resilience4j/rxjava2-examples/
description: resilience4j-rxjava2 모듈 사용 예시
image: ./../../images/resilience4j/logo.png
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: resilience4j
originalRefLink: https://resilience4j.readme.io/v1.7.0/docs/examples-2
---

### 목차

- [Decorate Flowable with a CircuitBreaker](#decorate-flowable-with-a-circuitbreaker)
- [Decorate Flowable with a RateLimiter](#decorate-flowable-with-a-ratelimiter)
- [Decorate Flowable with a Bulkhead](#decorate-flowable-with-a-bulkhead)
- [Decorate Flowable with Retry](#decorate-flowable-with-retry)

---

## Decorate Flowable with a CircuitBreaker

다음 예제는 커스텀 RxJava 연산자를 사용해서 Observable을 데코레이트하는 방법을 보여준다. Observable, Flowable, Single, Maybe, Completable같은 다른 리액티브 타입도 모두 지원한다.

`CircuitBreakerOperator`는 다운스트림 subscriber/observer가 업스트림 Publisher를 구독할 수 있는 권한을 얻을 수 있는지 확인한다. CircuitBreakerOperator는 CircuitBreaker가 OPEN 상태면 다운스트림 subscriber에게 `CallNotPermittedException`을 방출한다.

```java
CircuitBreaker circuitBreaker = CircuitBreaker.ofDefaults("name");
Flowable.fromCallable(backendService::doSomething)
    .compose(CircuitBreakerOperator.of(circuitBreaker))
```

---

## Decorate Flowable with a RateLimiter

다음 예제는 커스텀 RxJava 연산자를 사용해서 Flowable을 데코레이트하는 방법을 보여준다.<br>Flowable, Single, Maybe, Completable같은 다른 리액티브 타입도 모두 지원한다.

`RateLimiterOperator`는 다운스트림 subscriber/observer가 업스트림 Publisher를 구독할 수 있는 권한을 얻을 수 있는지 확인한다. RateLimiterOperator는 Rate limit을 초과하면 다운스트림 subscriber에게 `RequestNotPermitted` 에러를 방출한다.

```java
RateLimiter rateLimiter = RateLimiter.ofDefaults("name");
Flowable.fromCallable(backendService::doSomething)
    .compose(RateLimiterOperator.of(rateLimiter))
```

---

## Decorate Flowable with a Bulkhead

다음 예제는 커스텀 RxJava 연산자를 사용해서 Flowable을 데코레이트하는 방법을 보여준다.<br>Flowable, Single, Maybe, Completable같은 다른 리액티브 타입도 모두 지원한다.

`BulkheadOperator`는 다운스트림 subscriber/observer가 업스트림 Publisher를 구독할 수 있는 권한을 얻을 수 있는지 확인한다. BulkheadOperator는 Bulkhead가 가득차면 다운스트림 subscriber에게 `BulkheadFullException`을 방출한다.

```java
Bulkhead bulkhead = Bulkhead.ofDefaults("name");
Flowable.fromCallable(backendService::doSomething)
  .compose(BulkheadOperator.of(bulkhead));
```

---

## Decorate Flowable with Retry

```java
Retry retry = Retry.ofDefaults("backendName");
Flowable.fromCallable(backendService::doSomething)
    .compose(RetryOperator.of(retry))
```