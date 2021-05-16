---
title: MICRONAUT Getting Started
navTitle: Getting Started
category: Resilience4j
order: 24
permalink: /Resilience4j/micronaut-getting-started/
description: micronaut과 Resilience4j를 통합하는 방법. 설정 프로퍼티, 어노테이션 소개
image: ./../../images/resilience4j/logo.jpeg
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: resilience4j
originalRefLink: https://resilience4j.readme.io/v1.7.0/docs/getting-started-7
boundary: MICRONAUT
---

### 목차

- [Setup](#setup)
- [Demo](#demo)
- [Configuration](#configuration)
- [Configuration through Interceptor](#configuration-through-interceptor)
- [Annotations](#annotations)
- [Aspect order](#aspect-order)

---

## Setup

Resilience4j의  Micronaut Starter를 컴파일 의존성으로 추가해라.

micronaut 의존성을 위한 maven bom `io.micronaut:micronaut-bom:2.0.0.M3`을 포함시켜라.

```gradle
repositories {
    mavenCentral()
    jCenter()
}

dependencyManagement {
    imports {
        mavenBom 'io.micronaut:micronaut-bom:2.0.0.M3'
    }
}

dependencies {
  annotationProcessor "io.micronaut:micronaut-inject-java"
  annotationProcessor "io.micronaut:micronaut-validation"
  compile "io.github.resilience4j:resilience4j-micronaut:${resilience4jVersion}"
}
```

---

## Demo

Micronaut 환경 설정과 사용 방법은 [demo](https://github.com/resilience4j/resilience4j-micronaut-demo)에서 시연하고 있다.

---

## Configuration

CircuitBreaker, Retry, RateLimiter, Bulkhead, Thread pool bulkhead, TimeLimiter 인스턴스는 Micronaut의 설정 파일 `application.yml`로 설정할 수 있다.<br>예를 들어:

```yaml
resilience4j:
  circuitbreaker:
    enabled: true
    instances:
      backendA:
        baseConfig: default
      backendB:
        registerHealthIndicator: true
        slidingWindowSize: 10
        minimumNumberOfCalls: 10
        permittedNumberOfCallsInHalfOpenState: 3
        waitDurationInOpenState: PT5s
        failureRateThreshold: 50
        eventConsumerBufferSize: 10
        recordFailurePredicate: resilience4j.micronaut.demo.exception.RecordFailurePredicate
    configs:
      default:
        registerHealthIndicator: true
        slidingWindowSize: 10
        minimumNumberOfCalls: 5
        permittedNumberOfCallsInHalfOpenState: 3
        automaticTransitionFromOpenToHalfOpenEnabled: true
        waitDurationInOpenState: PT5s
        failureRateThreshold: 50
        eventConsumerBufferSize: 10
        recordExceptions:
          - io.micronaut.http.exceptions.HttpStatusException
          - java.util.concurrent.TimeoutException
          - java.io.IOException
        ignoreExceptions:
          - resilience4j.micronaut.demo.exception.BusinessException
      shared:
        slidingWindowSize: 100
        permittedNumberOfCallsInHalfOpenState: 30
        waitDurationInOpenState: PT1s
        failureRateThreshold: 50
        eventConsumerBufferSize: 10
        ignoreExceptions:
          - resilience4j.micronaut.demo.exception.BusinessException
  retry:
    enabled: true
    configs:
      default:
        maxAttempts: 3
        waitDuration: 100
        retryExceptions:
          - io.micronaut.http.exceptions.HttpStatusException
          - java.util.concurrent.TimeoutException
          - java.io.IOException
        ignoreExceptions:
          - resilience4j.micronaut.demo.exception.BusinessException
    instances:
      backendA:
        baseConfig: default
      backendB:
        baseConfig: default
  bulkhead:
    enabled: true
    configs:
      default:
        maxConcurrentCalls: 100
    instances:
      backendA:
        maxConcurrentCalls: 10
      backendB:
        maxWaitDuration: PT0.01S
        maxConcurrentCalls: 20
  thread-pool-bulkhead:
    enabled: true
    configs:
      default:
        maxThreadPoolSize: 4
        coreThreadPoolSize: 2
        queueCapacity: 2
    instances:
      backendA:
        baseConfig: default
      backendB:
        maxThreadPoolSize: 1
        coreThreadPoolSize: 1
        queueCapacity: 1
  ratelimiter:
    enabled: true
    configs:
      default:
        registerHealthIndicator: false
        limitForPeriod: 10
        limitRefreshPeriod: 1s
        timeoutDuration: 0
        eventConsumerBufferSize: 100
    instances:
      backendA:
        baseConfig: default
      backendB:
        limitForPeriod: 6
        limitRefreshPeriod: PT0.5S
        timeoutDuration: 3s
  timelimiter:
    enabled: true
    configs:
      default:
        cancelRunningFuture: false
        timeoutDuration: PT2s
    instances:
      backendA:
        baseConfig: default
      backendB:
        baseConfig: default
```

Micronaut 설정 파일 `application.yml`로 디폴트 설정을 재정의하거나, 공유 설정을 정의, 재정의하는 것도 가능하다.<br>예를 들어:

```yaml
resilience4j: 
  circuitbreaker: 
    enabled: true
  configs: 
    default: 
      eventConsumerBufferSize: 10
      failureRateThreshold: 60
      permittedNumberOfCallsInHalfOpenState: 10
      registerHealthIndicator: true
      slidingWindowSize: 100
      waitDurationInOpenState: 10000
    someShared: 
      permittedNumberOfCallsInHalfOpenState: 10
      slidingWindowSize: 50
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
@CircuitBreakerQualifier
public CircuitBreakerConfigCustomizer testCustomizer() {
    return CircuitBreakerConfigCustomizer
        .of("backendA", builder -> builder.slidingWindowSize(100));
}
```

Resilience4j는 위 예제처럼 사용할 수 있는 자체 customizer 타입을 가지고 있다. 이 빈들은 정확한 Qualifier로 마킹해야 한다:

| Resilienc4j Type   | Instance Customizer class                                    | Qualifier                                                    |
| :----------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| Circuit breaker    | <span class="custom-blockquote">CircuitBreakerConfigCustomizer</span> | <span class="custom-blockquote">@CircuitBreakerQualifier</span> |
| Retry              | <span class="custom-blockquote">RetryConfigCustomizer</span> | <span class="custom-blockquote">@RetryQualifier</span>       |
| Rate limiter       | <span class="custom-blockquote">RateLimiterConfigCustomizer</span> | <span class="custom-blockquote">@RateLimiterQualifier</span> |
| Bulkhead           | <span class="custom-blockquote">BulkheadConfigCustomizer</span> | <span class="custom-blockquote">@BulkheadQualifier</span>    |
| ThreadPoolBulkhead | <span class="custom-blockquote">ThreadPoolBulkheadConfigCustomizer</span> | <span class="custom-blockquote">@ThreadPoolBulkheadQualifier</span> |
| Time Limiter       | <span class="custom-blockquote">TimeLimiterConfigCustomizer</span> | <span class="custom-blockquote">@TimeLimiterQualifier</span> |

---

## Configuration through Interceptor

빈을 주입하기 전에 가로채갈 수도 있다. 즉, Resilience4j 프로퍼티를 가로채서 커스텀 로직을 추가로 실행할 수 있다.

```java
package io.micronaut.ignite.docs.config;

@Singleton
public class BulkheadConfiguration implements BeanCreatedEventListener<BulkheadProperties> {
    @Override
    public IgniteConfiguration onCreated(BeanCreatedEvent<BulkheadConfigurationProperties> event) {
        CircuitBreakerProperties configuration = event.getBean();
        return configuration;
    }
}
```

| Resilience4j Type                                            |
| :----------------------------------------------------------- |
| <span class="custom-blockquote">BulkheadConfigurationProperties</span> |
| <span class="custom-blockquote">CircuitBreakerConfigurationProperties</span> |
| <span class="custom-blockquote">RateLimiterProperties</span> |
| <span class="custom-blockquote">RetryProperties</span>       |
| <span class="custom-blockquote">TimeLimiterProperties</span> |
| <span class="custom-blockquote">ThreadPoolBulkheadProperties</span> |

---

## Annotations

Micronaut 스타터는 자동으로 설정해주는 어노테이션과 AOP Aspect를 제공한다.<br>
RateLimiter, Retry, CircuitBreaker, Bulkhead 어노테이션은 동기식 리턴 타입과, CompletableFuture 등의 비동기 타입, 스프링 리액터의 Flux/Mono같은 리액티브 타입을 지원한다 (`resilience4j-reactor`같은 적절한 패키지를 임포트했다면).

Bulkhead 어노테이션에는 사용할 bulkhead 구현체를 정의하는 type 속성이 있다. 기본값은 세마포어지만 type 속성을 설정해서 스레드 풀로 변경할 수 있다:

```java
@Bulkhead(name = BACKEND_A, type = Bulkhead.Type.THREADPOOL)
public CompletableFuture<String> futureFailure() {
    CompletableFuture<String> future = new CompletableFuture<>();
    future.completeExceptionally(new IOException("BAM!"));
    return future;
}
```

다음은 resilience4j가 지원하는 스프링 aspect를 모두 표기한 예시다:

```java
@Override
@Bulkhead(name = BACKEND_A, type = Bulkhead.Type.THREADPOOL)
@TimeLimiter(name = BACKEND_A)
@CircuitBreaker(name = BACKEND_A, fallbackMethod = "futureFallback")
public CompletableFuture<String> futureTimeout() {
    Try.run(() -> Thread.sleep(5000));
    return CompletableFuture.completedFuture("Hello World from backend A");
}


 @Executable
 public String fallback() {
    return "Recovered HttpServerErrorException";
 }

@Executable
public CompletableFuture<String> futureFallback() {
    return CompletableFuture.completedFuture("Recovered specific TimeoutException");
}
```

폴백 메소드는 같은 클래스에 있어야 하며, `@Executable`로 마킹해야 한다는 점을 반드시 기억해두자.

폴백 메소드는 인자 시그니처와 리턴 타입이 동일하게 매칭돼야 한다.

---

## Aspect order

Resilience4j Aspect 순서는 다음과 같다:<br>`Retry ( CircuitBreaker ( RateLimiter ( TimeLimiter ( Bulkhead ( Function ) ) ) ) )`<br>

현재로썬 aspect 실행 순서를 변경할 수 있는 방법은 없다.