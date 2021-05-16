---
title: Spring Boot 2 Getting Started
navTitle: Getting Started
category: Resilience4j
order: 23
permalink: /Resilience4j/spring-boot-2-getting-started/
description: 스프링 부트 2와 Resilience4j를 통합하는 방법. 설정 프로퍼티, 어노테이션, 엔드포인트 소개
image: ./../../images/resilience4j/logo.jpeg
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: resilience4j
originalRefLink: https://resilience4j.readme.io/v1.7.0/docs/getting-started-3
boundary: SPRING BOOT 2
priority: 0.8
---

### 목차

- [Setup](#setup)
- [Demo](#demo)
- [Configuration](#configuration)
- [Annotations](#annotations)
- [Aspect order](#aspect-order)
- [Metrics endpoint](#metrics-endpoint)
- [Health endpoint](#health-endpoint)
- [Events endpoint](#events-endpoint)

---

## Setup

Resilience4j의 Spring Boot 2 Starter를 컴파일 의존성으로 추가해라.

이 모듈은 런타임에 `org.springframework.boot:spring-boot-starter-actuator`와 `org.springframework.boot:spring-boot-starter-aop`를 제공해준다고 가정한다. 스프링 부트2와 웹플럭스를 같이 사용하고 있다면 `io.github.resilience4j:resilience4j-reactor`도 필요하다.

```gradle
repositories {
    jCenter()
}

dependencies {
  compile "io.github.resilience4j:resilience4j-spring-boot2:${resilience4jVersion}"
  compile('org.springframework.boot:spring-boot-starter-actuator')
  compile('org.springframework.boot:spring-boot-starter-aop')
}
```

---

## Demo

스프링 부트 2 환경 설정과 사용 방법은 [demo](https://github.com/resilience4j/resilience4j-spring-boot2-demo)에서 시연하고 있다.

---

## Configuration

CircuitBreaker, Retry, RateLimiter, Bulkhead, Thread pool bulkhead, TimeLimiter 인스턴스는 스프링 부트의 설정 파일 `application.yml`로 설정할 수 있다.<br>예를 들어:

```yaml
resilience4j.circuitbreaker:
    instances:
        backendA:
            registerHealthIndicator: true
            slidingWindowSize: 100
        backendB:
            registerHealthIndicator: true
            slidingWindowSize: 10
            permittedNumberOfCallsInHalfOpenState: 3
            slidingWindowType: TIME_BASED
            minimumNumberOfCalls: 20
            waitDurationInOpenState: 50s
            failureRateThreshold: 50
            eventConsumerBufferSize: 10
            recordFailurePredicate: io.github.robwin.exception.RecordFailurePredicate
            
resilience4j.retry:
    instances:
        backendA:
            maxAttempts: 3
            waitDuration: 10s
            enableExponentialBackoff: true
            exponentialBackoffMultiplier: 2
            retryExceptions:
                - org.springframework.web.client.HttpServerErrorException
                - java.io.IOException
            ignoreExceptions:
                - io.github.robwin.exception.BusinessException
        backendB:
            maxAttempts: 3
            waitDuration: 10s
            retryExceptions:
                - org.springframework.web.client.HttpServerErrorException
                - java.io.IOException
            ignoreExceptions:
                - io.github.robwin.exception.BusinessException
                
resilience4j.bulkhead:
    instances:
        backendA:
            maxConcurrentCalls: 10
        backendB:
            maxWaitDuration: 10ms
            maxConcurrentCalls: 20
            
resilience4j.thread-pool-bulkhead:
  instances:
    backendC:
      maxThreadPoolSize: 1
      coreThreadPoolSize: 1
      queueCapacity: 1
        
resilience4j.ratelimiter:
    instances:
        backendA:
            limitForPeriod: 10
            limitRefreshPeriod: 1s
            timeoutDuration: 0
            registerHealthIndicator: true
            eventConsumerBufferSize: 100
        backendB:
            limitForPeriod: 6
            limitRefreshPeriod: 500ms
            timeoutDuration: 3s
            
resilience4j.timelimiter:
    instances:
        backendA:
            timeoutDuration: 2s
            cancelRunningFuture: true
        backendB:
            timeoutDuration: 1s
            cancelRunningFuture: false
```

스프링 부트 설정 파일 `application.yml`로 디폴트 설정을 재정의하거나, 공유 설정을 정의, 재정의하는 것도 가능하다.<br>예를 들어:

```yaml
resilience4j.circuitbreaker:
    configs:
        default:
            slidingWindowSize: 100
            permittedNumberOfCallsInHalfOpenState: 10
            waitDurationInOpenState: 10000
            failureRateThreshold: 60
            eventConsumerBufferSize: 10
            registerHealthIndicator: true
        someShared:
            slidingWindowSize: 50
            permittedNumberOfCallsInHalfOpenState: 10
    instances:
        backendA:
            baseConfig: default
            waitDurationInOpenState: 5000
        backendB:
            baseConfig: someShared
```

특정 인스턴스 이름에다 Customizer를 사용해서 CircuitBreaker, Bulkhead, Retry, RateLimiter, TimeLimiter 인스턴스의 설정을 재정의할 수도 있다. 다음은 위에 있는 YAML 파일에서 설정한 CircuitBreaker **backendA**를 재정의하는 방법을 보여주는 예시다:

```java
@Bean
public CircuitBreakerConfigCustomizer testCustomizer() {
    return CircuitBreakerConfigCustomizer
        .of("backendA", builder -> builder.slidingWindowSize(100));
}
```

Resilience4j는 위 예제처럼 사용할 수 있는 자체 customizer 타입을 가지고 있다:

| Resilienc4j Type   | Instance Customizer class                                    |
| :----------------- | :----------------------------------------------------------- |
| Circuit breaker    | <span class="custom-blockquote">CircuitBreakerConfigCustomizer</span> |
| Retry              | <span class="custom-blockquote">RetryConfigCustomizer</span> |
| Rate limiter       | <span class="custom-blockquote">RateLimiterConfigCustomizer</span> |
| Bulkhead           | <span class="custom-blockquote">BulkheadConfigCustomizer</span> |
| ThreadPoolBulkhead | <span class="custom-blockquote">ThreadPoolBulkheadConfigCustomizer</span> |
| Time Limiter       | <span class="custom-blockquote">TimeLimiterConfigCustomizer</span> |

---

## Annotations

스프링 부트2 스타터는 자동으로 설정해주는 어노테이션과 AOP Aspect를 제공한다.<br>
RateLimiter, Retry, CircuitBreaker, Bulkhead 어노테이션은 동기식 리턴 타입과, CompletableFuture 등의 비동기 타입, 스프링 리액터의 Flux/Mono같은 리액티브 타입을 지원한다 (`resilience4j-reactor`같은 적절한 패키지를 임포트했다면).

Bulkhead 어노테이션에는 사용할 bulkhead 구현체를 정의하는 type 속성이 있다. 기본값은 세마포어지만 type 속성을 설정해서 스레드 풀로 변경할 수 있다:

```java
@Bulkhead(name = BACKEND, type = Bulkhead.Type.THREADPOOL)
public CompletableFuture<String> doSomethingAsync() throws InterruptedException {
        Thread.sleep(500);
        return CompletableFuture.completedFuture("Test");
 }
```

다음은 resilience4j가 지원하는 스프링 aspect를 모두 표기한 예시다:

```java
@CircuitBreaker(name = BACKEND, fallbackMethod = "fallback")
@RateLimiter(name = BACKEND)
@Bulkhead(name = BACKEND)
@Retry(name = BACKEND, fallbackMethod = "fallback")
@TimeLimiter(name = BACKEND)
public Mono<String> method(String param1) {
    return Mono.error(new NumberFormatException());
}

private Mono<String> fallback(String param1, IllegalArgumentException e) {
    return Mono.just("test");
}

private Mono<String> fallback(String param1, RuntimeException e) {
    return Mono.just("test");
}
```

폴백 메소드는 같은 클래스에 있어야 하며, 같은 메소드 시그니처에 타겟 exception 파라미터 하나를 추가로 가져야 한다는 점을 반드시 기억해두자.

fallbackMethod 메소드가 여러 개라면 가장 가깝게 일치하는 메소드를 호출한다. 예를 들면 다음과 같다:

`NumberFormatException`으로부터 복구를 시도하면 `String fallback(String parameter, IllegalArgumentException exception)}` 시그니처를 가진 메소드가 실행된다.

여러 메소드에 모두 같은 폴백 메소드를 한 방에 정의하고 싶을 때는, 모든 메소드의 리턴 타입이 같은 경우에 한해서만 exception 파라미터 하나를 사용해서 글로벌 폴백 메소드를 정의할 수 있다.

---

## Aspect order

Resilience4j Aspect 순서는 다음과 같다:<br>
`Retry ( CircuitBreaker ( RateLimiter ( TimeLimiter ( Bulkhead ( Function ) ) ) ) )`<br>
따라서 `Retry`는 마지막에 적용된다 (필요한 경우에).<br>순서를 바꾸고 싶다면 스프링 어노테이션 스타일 대신 함수형 체이닝 스타일을 사용하거나, 아래 프로퍼티로 aspect 순서를 명시해야 한다:

```properties
- resilience4j.retry.retryAspectOrder
- resilience4j.circuitbreaker.circuitBreakerAspectOrder
- resilience4j.ratelimiter.rateLimiterAspectOrder
- resilience4j.timelimiter.timeLimiterAspectOrder
```

예를 들어서 Retry 처리가 끝난 후에 서킷 브레이커를 시작하려면 `retryAspectOrder` 프로퍼티를 `circuitBreakerAspectOrder` 값보다 큰 값으로 설정해야 한다 (높은 값 = 더 높은 우선 순위).

```yaml
resilience4j:
  circuitbreaker:
    circuitBreakerAspectOrder: 1
  retry:
    retryAspectOrder: 2
```

---

## Metrics endpoint

CircuitBreaker, Retry, RateLimiter, Bulkhead, TimeLimiter 메트릭은 메트릭 엔드포인트에 자동으로 게시된다. 사용 가능한 메트릭 이름을 조회하고 싶으면 `actuator/metrics`에 GET 요청을 보내봐라. 자세한 내용은 [Actuator Metrics 문서](https://docs.spring.io/spring-boot/docs/current/actuator-api/html/#metrics)를 참고해라.

```json
{
    "names": [
        "resilience4j.circuitbreaker.calls",
        "resilience4j.circuitbreaker.buffered.calls",
        "resilience4j.circuitbreaker.state",
        "resilience4j.circuitbreaker.failure.rate"
        ]
}
```

특정 메트릭을 조회하려면  `/actuator/metrics/{metric.name}`에 GET 요청을 보내라.
예를 들어: `/actuator/metrics/resilience4j.circuitbreaker.calls`

```json
{
    "name": "resilience4j.circuitbreaker.calls",
    "measurements": [
        {
            "statistic": "VALUE",
            "value": 3
        }
    ],
    "availableTags": [
        {
            "tag": "kind",
            "values": [
                "not_permitted",
                "successful",
                "failed"
            ]
        },
        {
            "tag": "name",
            "values": [
                "backendB",
                "backendA"
            ]
        }
    ]
}
```

프로메테우스 엔드포인트에 CircuitBreaker 엔드포인트를 게시하려면 `io.micrometer:micrometer-registry-prometheus` 의존성을 추가해야 한다.

메트릭들을 조회하려면 `/actuator/prometheus`에 GET 요청을 보내라. 자세한 내용은 [Micrometer 시작하기](https://resilience4j.readme.io/docs/micrometer)를 참고해라.

---

## Health endpoint

Spring Boot Actuator health 정보를 통해 실행 중인 어플리케이션의 상태를 확인할 수 있다. 이 정보는 프로덕션 시스템에 심각한 문제가 있는 경우 누군가에게 알람을 보내는 용도로 모니터링 소프트웨어에서 자주 사용하곤 한다.<br>
기본적으로 CircuitBreaker나 RateLimiter health indicator는 비활성화돼 있다. CircuitBreaker가 OPEN 상태일 땐 어플리케이션 상태가 DOWN이기 때문이다. 물론 원하는 바와 다를 수도 있다. 이땐 설정을 통해 활성화할 수 있다.

```yaml
management.health.circuitbreakers.enabled: true
management.health.ratelimiters.enabled: true

resilience4j.circuitbreaker:
  configs:
    default:
      registerHealthIndicator: true


resilience4j.ratelimiter:
  configs:
    default:
      registerHealthIndicator: true
```

CircuitBreaker가 닫혔을 땐 UP, open 상태는 DOWN, half-open는 UNKNOWN으로 매핑된다.

예를 들어:

```json
{
  "status": "UP",
  "details": {
    "circuitBreakers": {
      "status": "UP",
      "details": {
        "backendB": {
          "status": "UP",
          "details": {
            "failureRate": "-1.0%",
            "failureRateThreshold": "50.0%",
            "slowCallRate": "-1.0%",
            "slowCallRateThreshold": "100.0%",
            "bufferedCalls": 0,
            "slowCalls": 0,
            "slowFailedCalls": 0,
            "failedCalls": 0,
            "notPermittedCalls": 0,
            "state": "CLOSED"
          }
        },
        "backendA": {
          "status": "UP",
          "details": {
            "failureRate": "-1.0%",
            "failureRateThreshold": "50.0%",
            "slowCallRate": "-1.0%",
            "slowCallRateThreshold": "100.0%",
            "bufferedCalls": 0,
            "slowCalls": 0,
            "slowFailedCalls": 0,
            "failedCalls": 0,
            "notPermittedCalls": 0,
            "state": "CLOSED"
          }
        }
      }
    }
  }
}
```

---

## Events endpoint

CircuitBreaker, Retry, RateLimiter, Bulkhead, TimeLimiter 이벤트를 발행하게 되면 별도의 원형 이벤트 컨슈머 버퍼에 저장된다. 이벤트 컨슈머 버퍼의 크기는 application.yml 파일에서 설정할 수 있다 (`eventConsumerBufferSize`).

`/actuator/circuitbreakers` 엔드포인트에선 모든 CircuitBreaker 인스턴스 이름을 나열한다. 이 엔드포인트는 Retry, RateLimiter, Bulkhead, TimeLimiter에서도 사용할 수 있다.<br>
예를 들어:

```json
{
    "circuitBreakers": [
      "backendA",
      "backendB"
    ]
}
```

`/actuator/circuitbreakerevents` 엔드포인트는 기본적으로 모든 CircuitBreaker 인스턴스에서 가장 최근에 발행한 이벤트100개를 보여준다. 이 엔드포인트는 Retry, RateLimiter, Bulkhead, TimeLimiter에서도 사용할 수 있다.

```json
{
    "circuitBreakerEvents": [
        {
            "circuitBreakerName": "backendA",
            "type": "ERROR",
            "creationTime": "2017-01-10T15:39:17.117+01:00[Europe/Berlin]",
            "errorMessage": "org.springframework.web.client.HttpServerErrorException: 500 This is a remote exception",
            "durationInMs": 0
        },
        {
            "circuitBreakerName": "backendA",
            "type": "SUCCESS",
            "creationTime": "2017-01-10T15:39:20.518+01:00[Europe/Berlin]",
            "durationInMs": 0
        },
        {
            "circuitBreakerName": "backendB",
            "type": "ERROR",
            "creationTime": "2017-01-10T15:41:31.159+01:00[Europe/Berlin]",
            "errorMessage": "org.springframework.web.client.HttpServerErrorException: 500 This is a remote exception",
            "durationInMs": 0
        },
        {
            "circuitBreakerName": "backendB",
            "type": "SUCCESS",
            "creationTime": "2017-01-10T15:41:33.526+01:00[Europe/Berlin]",
            "durationInMs": 0
        }
    ]
}
```