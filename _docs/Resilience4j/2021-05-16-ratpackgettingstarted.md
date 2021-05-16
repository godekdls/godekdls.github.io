---
title: Ratpack Getting Started
navTitle: Getting Started
category: Resilience4j
order: 26
permalink: /Resilience4j/ratpack-getting-started/
description: Ratpack과 Resilience4j를 통합하는 방법. 설정 프로퍼티, 어노테이션, 엔드포인트 소개
image: ./../../images/resilience4j/logo.png
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: resilience4j
originalRefLink: https://resilience4j.readme.io/v1.7.0/docs/getting-started-5
boundary: RATPACK
---

### 목차

- [Setup](#setup)
- [Demo](#demo)
- [Configuration](#configuration)
- [Annotations](#annotations)
- [Events Endpoint](#events-endpoint)

---

## Setup

Resilience4j의 Ratpack Starter를 컴파일 의존성으로 추가해라:

```gradle
repositories {
    jCenter()
}

dependencies {
    compile "io.github.resilience4j:resilience4j-ratpack:${resilience4jVersion}"
}
```

---

## Demo

Ratpack 환경 설정과 사용 방법은 [demo](https://github.com/resilience4j/resilience4j-ratpack-demo)에서 시연하고 있다.

---

## Configuration

CircuitBreaker, Retry, RateLimiter, Bulkhead, Thread pool bulkhead 인스턴스는 Ratpack의 설정 파일 `application.yml`로 설정할 수 있다.<br>예를 들어:

```yaml
resilience4j:
    circuitbreaker:
        instances:
            backendA:
                ringBufferSizeInClosedState: 100
            backendB:
                ringBufferSizeInClosedState: 10
                ringBufferSizeInHalfOpenState: 3
                waitDurationInOpenState: PT50S
                failureRateThreshold: 50
                eventConsumerBufferSize: 10
                recordFailurePredicate: io.github.robwin.exception.RecordFailurePredicate

    retry:
        instances:
            backendA:
                maxRetryAttempts: 3
                waitDuration: PT10S
                enableExponentialBackoff: true
                exponentialBackoffMultiplier: 2
                retryExceptions:
                    - java.io.IOException
                ignoreExceptions:
                    - io.github.robwin.exception.BusinessException
            backendB:
                maxRetryAttempts: 3
                waitDuration: PT10S
                retryExceptions:
                    - java.io.IOException
                ignoreExceptions:
                    - io.github.robwin.exception.BusinessException

    bulkhead:
        instances:
            backendA:
                maxConcurrentCall: 10
            backendB:
                maxWaitDuration: PT0.01S
                maxConcurrentCall: 20

    threadpoolbulkhead:
      instances:
        backendC:
          threadPoolProperties:
            maxThreadPoolSize: 1
            coreThreadPoolSize: 1
            queueCapacity: 1

    ratelimiter:
        instances:
            backendA:
                limitForPeriod: 10
                limitRefreshPeriod: PT1S
                timeoutDuration: 0
                eventConsumerBufferSize: 100
            backendB:
                limitForPeriod: 6
                limitRefreshPeriod: PT0.5S
                timeoutDuration: PT3S
```

Ratpack 설정 파일 `application.yml`로 디폴트 설정을 재정의하거나, 공유 설정을 정의, 재정의하는 것도 가능하다.<br>예를 들어:

```yaml
resilience4j:
    circuitbreaker:
        configs:
            default:
                ringBufferSizeInClosedState: 100
                ringBufferSizeInHalfOpenState: 10
                waitDurationInOpenState: 10000
                failureRateThreshold: 60
                eventConsumerBufferSize: 10
            someShared:
                ringBufferSizeInClosedState: 50
                ringBufferSizeInHalfOpenState: 10
        instances:
            backendA:
                baseConfig: default
                waitDurationInOpenState: 5000
            backendB:
                baseConfig: someShared
```

---

## Annotations

Ratpack 라이브러리는 자동으로 설정해주는 어노테이션과 AOP Aspect를 제공한다.<br>
RateLimiter, Retry, CircuitBreaker, Bulkhead 어노테이션은 동기식 리턴 타입과, CompletableFuture 등의 비동기 타입, Raptack의 Promise나 스프링 리액터의 Flux/Mono같은 리액티브 타입을 지원한다.

현재 Bulkhead 어노테이션에는 사용할 bulkhead 구현체를 정의하는 type 속성이 있다. 기본값은 세마포어지만 type 속성을 설정해서 스레드 풀로 변경할 수 있다:

```java
@Bulkhead(name = BACKEND, type = Bulkhead.Type.THREADPOOL)
public CompletableFuture<String> doSomethingAsync() throws InterruptedException {
       Thread.sleep(500);
       return CompletableFuture.completedFuture("Test");
}
```

다음은 resilience4j가 지원하는 AOP aspect를 모두 표기한 예시다:

```java
@CircuitBreaker(name = BACKEND, fallbackMethod = "fallback")
@RateLimiter(name = BACKEND)
@Bulkhead(name = BACKEND)
@Retry(name = BACKEND, fallbackMethod = "fallback")
public Promise<String> method(String param1) {
   return Promise.error(new NumberFormatException());
 }

private Promise<String> fallback(String param1, IllegalArgumentException e) {
  return Promise.just("test");
}

private Promise<String> fallback(String param1, RuntimeException e) {
  return Promise.just("test");
}
```

폴백 메소드는 같은 클래스에 있어야 하며, 같은 메소드 시그니처를 가져야 한다는 점을 반드시 기억해두자 (원한다면 exception 파라미터 하나는 추가해도 된다).

fallbackMethod 메소드가 여러 개라면 가장 가깝게 일치하는 메소드를 호출한다. 예를 들면 다음과 같다:

`NumberFormatException`으로부터 복구를 시도하면 `String fallback(String parameter, IllegalArgumentException exception)}` 시그니처를 가진 메소드가 실행된다.

여러 메소드에 모두 같은 폴백 메소드를 한 방에 정의하고 싶을 때는, 모든 메소드의 리턴 타입이 같은 경우에 한해서만 exception 파라미터 하나를 사용해서 글로벌 폴백 메소드를 정의할 수 있다.

---

## Events Endpoint

CircuitBreaker, Retry, RateLimiter, Bulkhead 이벤트를 발행하게 되면 별도의 원형 이벤트 컨슈머 버퍼에 저장된다. 이벤트 컨슈머 버퍼의 크기는 application.yml 파일에서 설정할 수 있다 (`eventConsumerBufferSize`).

`/circuitbreaker/states` 엔드포인트에선 모든 CircuitBreaker 인스턴스의 상태를 나열한다. `/circuitbreaker/events` 엔드포인트는 모든 CircuitBreaker 인스턴스의 이벤트 리스트를 보여준다. 이 이벤트 엔드포인트는 Retry, RateLimiter, Bulkhead에서도 사용할 수 있다.<br>
예를 들어:

```json
{
"circuitBreakerEvents":[
  {
    "circuitBreakerName": "backendA",
    "type": "ERROR",
    "creationTime": "2019-01-10T15:39:17.117-05:00[America/Chicago]",
    "errorMessage": "java.io.IOException: 500 This is a remote exception",
    "durationInMs": 0
  },
  {
    "circuitBreakerName": "backendA",
    "type": "SUCCESS",
    "creationTime": "2019-01-10T15:39:20.518-05:00[America/Chicago]",
    "durationInMs": 0
  },
  {
    "circuitBreakerName": "backendB",
    "type": "ERROR",
    "creationTime": "2019-01-10T15:41:31.159-05:00[America/Chicago]",
    "errorMessage": "java.io.IOException: 500 This is a remote exception",
    "durationInMs": 0
  },
  {
    "circuitBreakerName": "backendB",
    "type": "SUCCESS",
    "creationTime": "2019-01-10T15:41:33.526-05:00[America/Chicago]",
    "durationInMs": 0
  }
]
}
```