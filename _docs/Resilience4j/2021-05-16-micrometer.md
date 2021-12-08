---
title: Micrometer
category: Resilience4j
order: 27
permalink: /Resilience4j/micrometer/
description: CircuitBreaker, Retry, Bulkhead, RateLimiter, TimeLimiter를 모니터링할 수 있는 Micrometer 메트릭 소개
image: ./../../images/resilience4j/logo.png
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: resilience4j
originalRefLink: https://resilience4j.readme.io/v1.7.0/docs/micrometer
boundary: METRICS
---

### 목차

- [CircuitBreaker Metrics](#circuitbreaker-metrics)
- [Retry Metrics](#retry-metrics)
- [Bulkhead Metrics](#bulkhead-metrics)
- [RateLimiter Metrics](#ratelimiter-metrics)
- [TimeLimiter](#timelimiter)
- [Prometheus](#prometheus)

---

Resilience4j는 InfluxDB나 프로메테우스같이 가장 많이 사용하는 모니터링 시스템을 지원하기 위한 [Micrometer](http://micrometer.io/) 전용 모듈을 제공한다.<br>이 모듈은 런타임에 `micrometer-core`를 제공해준다고 가정한다. 스프링 리액터는 전이 의존성이 아니다.

```gradle
repositories {
    jCenter()
}

dependencies {
    compile "io.github.resilience4j:resilience4j-micrometer:${resilience4jVersion}"
}
```

---

## CircuitBreaker Metrics

다음은 CircuitBreaker 메트릭을 `MeterRegistry`에 바인딩하는 방법을 보여주는 코드다. 여기선 모든 CircuitBreaker 인스턴스를 한 번에 바인딩하고, 새로 만들어진 인스턴스를 동적으로 바인딩하기 위해 이벤트 컨슈머를 등록한다.

```java
MeterRegistry meterRegistry = new SimpleMeterRegistry();
CircuitBreakerRegistry circuitBreakerRegistry = CircuitBreakerRegistry.ofDefaults();
CircuitBreaker foo = circuitBreakerRegistry
  .circuitBreaker("backendA");
CircuitBreaker boo = circuitBreakerRegistry
  .circuitBreaker("backendB");

TaggedCircuitBreakerMetrics
  .ofCircuitBreakerRegistry(circuitBreakerRegistry)
  .bindTo(meterRegistry)
```

다음과 같은 메트릭을 내보낸다:

| Metric name                                                  | Type                                    | Tags                                                         | Description                                  |
| :----------------------------------------------------------- | :-------------------------------------- | :----------------------------------------------------------- | :------------------------------------------- |
| `resilience4j`<br/>`.circuitbreaker`<br>`.calls`             | Timer                                   | 다음 중 하나:<br>kind="failed"<br/>kind="successful"<br/>kind="ignored"<br/><br/>name="backendA" | 성공, 실패, 또는 무시한 전체 호출 횟수       |
| `resilience4j`<br/>`.circuitbreaker`<br/>`.max.buffered.calls` | Gauge                                   | name="backendA"                                              | 현재 원형 버퍼에 저장할 수 있는 최대 호출 수 |
| `resilience4j`<br/>`.circuitbreaker`<br/>`.state`            | Gauge<br/>0 - Not active<br/>1 - Active | 다음 중 하나:<br/>state="closed"<br/>state="open"<br/>state="half_open" <br/>state="forced_open"<br/>state="disabled" <br/><br/>name="backendA" | 서킷 브레이커의 상태                         |
| `resilience4j`<br/>`.circuitbreaker`<br/>`.failure.rate`     | Gauge                                   | name="backendA"                                              | 서킷 브레이커의 실패 비율                    |
| `resilience4j`<br/>`.circuitbreaker`<br/>`.buffered.calls`   | Gauge                                   | 다음 중 하나:<br/>kind="failed"<br/>kind="successful"<br/><br/> name="backendA" | 원형 버퍼에 저장된 성공, 실패한 호출 횟수    |
| `resilience4`<br/>`.circuitbreaker`<br/>`.not.permitted.calls` | Counter                                 | kind="not_permitted"<br/><br/> name="backendA"               | 허가받지 못한 총 호출 횟수                   |
| `resilience4j`<br/>`.circuitbreaker`<br/>`.slow.call.rate`   | Gauge                                   | name="backendA"                                              | 서킷 브레이커의 느린 호출(slow call)         |

---

## Retry Metrics

다음은 Retry 메트릭을 `MeterRegistry`에 바인딩하는 방법을 보여주는 코드다. 여기선 모든 Retry 인스턴스를 한 번에 바인딩하고, 새로 만들어진 인스턴스를 동적으로 바인딩하기 위해 이벤트 컨슈머를 등록한다.

```java
MeterRegistry meterRegistry = new SimpleMeterRegistry();
RetryRegistry retryRegistry = RetryRegistry.ofDefaults();
Retry retry = retryRegistry.retry("backendA");

// Register all retries at once
TaggedRetryMetrics
  .ofRetryRegistry(retryRegistry)
  .bindTo(meterRegistry);
```

다음과 같은 메트릭을 내보낸다:

| Metric name                              | Type  | Tags                                                         | Description      |
| :--------------------------------------- | :---- | :----------------------------------------------------------- | :--------------- |
| `resilience4j`<br/>`.retry`<br/>`.calls` | Gauge | 다음 중 하나:<br>kind="successful.without.retry"<br/>kind="successful.with.retry"<br/>kind="failed.with.retry" <br/>kind="failed.without.retry"<br/><br/>name="backendA" | 종류별 호출 횟수 |

---

## Bulkhead Metrics

다음은 Bulkhead 메트릭을 `MeterRegistry`에 바인딩하는 방법을 보여주는 코드다. 여기선 모든 Bulkhead 인스턴스를 한 번에 바인딩하고, 새로 만들어진 인스턴스를 동적으로 바인딩하기 위해 이벤트 컨슈머를 등록한다.

```java
MeterRegistry meterRegistry = new SimpleMeterRegistry();
BulkheadRegistry bulkheadRegistry = BulkheadRegistry.ofDefaults();
Bulkhead bulkhead = bulkheadRegistry.bulkhead("backendA");

// Register all retries at once
TaggedBulkheadMetrics
  .ofBulkheadRegistry(bulkheadRegistry)
  .bindTo(meterRegistry);
```

다음과 같은 메트릭을 내보낸다:

| Metric name                                                  | Type  | Tags            | Description              |
| :----------------------------------------------------------- | :---- | :-------------- | :----------------------- |
| `resilience4j`<br>`.bulkhead`<br/>`.available`<br/>`.concurrent.calls` | Gauge | name="backendA" | 사용 가능한 권한 수      |
| `resilience4j`<br/>`.bulkhead`<br/>`.max.allowed`<br/>`.concurrent.calls` | Gauge | name="backendA" | 사용 가능한 최대 권한 수 |

---

## RateLimiter Metrics

다음은 RateLimiter 메트릭을 `MeterRegistry`에 바인딩하는 방법을 보여주는 코드다. 여기선 모든 RateLimiter 인스턴스를 한 번에 바인딩하고, 새로 만들어진 인스턴스를 동적으로 바인딩하기 위해 이벤트 컨슈머를 등록한다.

```java
MeterRegistry meterRegistry = new SimpleMeterRegistry();
RateLimiterRegistry rateLimiterRegistry = RateLimiterRegistry.ofDefaults();
RateLimiter rateLimiter = rateLimiterRegistry
  .rateLimiter("backendA");

// Register rate limiters at once
TaggedRateLimiterMetrics
  .ofRateLimiterRegistry(rateLimiterRegistry)
  .bindTo(meterRegistry);
```

다음과 같은 메트릭을 내보낸다:

| Metric name                                            | Type  | Tags            | Description         |
| :----------------------------------------------------- | :---- | :-------------- | :------------------ |
| `resilience4j.ratelimiter`<br>`.available.permissions` | Gauge | name="backendA" | 사용 가능한 권한 수 |
| `resilience4j.ratelimiter`<br>`.waiting.threads`       | Gauge | name="backendA" | 대기 중인 스레드 수 |

---

## TimeLimiter

다음은 TimeLimiter 메트릭을 `MeterRegistry`에 바인딩하는 방법을 보여주는 코드다. 여기선 모든 TimeLimiter 인스턴스를 한 번에 바인딩하고, 새로 만들어진 인스턴스를 동적으로 바인딩하기 위해 이벤트 컨슈머를 등록한다.

```java
MeterRegistry meterRegistry = new SimpleMeterRegistry();
TimeLimiterRegistry timeLimiterRegistry = TimeLimiterRegistry.ofDefaults();
TimeLimiter timeLimiter = timeLimiterRegistry
  .timeLimiter("backendA");

// Register time limiters at once
TaggedTimeLimiterMetrics
  .ofTimeLimiterRegistry(timeLimiterRegistry)
  .bindTo(meterRegistry);
```

다음과 같은 메트릭을 내보낸다:

| Metric name                      | Type    | Tags                              | Description                     |
| :------------------------------- | :------ | :-------------------------------- | :------------------------------ |
| `resilience4j.timelimiter.calls` | Counter | name="backendA" kind="successful" | 성공한 총 호출 횟수             |
| `resilience4j.timelimiter.calls` | Counter | name="backendA" kind="failed"     | 실패한 총 호출 횟수             |
| `resilience4j.timelimiter.calls` | Counter | name="backendA" kind="timeout"    | 타임 아웃이 발생한 총 호출 횟수 |

---

## Prometheus

메트릭을 프로메테우스에 게시하려면 다음 의존성을 추가해야 한다:

```gradle
dependencies {
    compile "io.micrometer:micrometer-registry-prometheus"
}
```

CircuitBreaker마다 다음과 같은 메트릭을 내보낸다:

```prometheus
# HELP resilience4j_circuitbreaker_buffered_calls The number of buffered failed calls stored in the ring buffer
# TYPE resilience4j_circuitbreaker_buffered_calls gauge
resilience4j_circuitbreaker_buffered_calls{kind="failed",name="backendA",} 0.0
resilience4j_circuitbreaker_buffered_calls{kind="successful",name="backendA",} 0.0

# HELP resilience4j_circuitbreaker_calls_total Total number of not permitted calls
# TYPE resilience4j_circuitbreaker_calls_total counter
resilience4j_circuitbreaker_calls_total{kind="not_permitted",name="backendA",} 0.0

# HELP resilience4j_circuitbreaker_state The states of the circuit breaker
# TYPE resilience4j_circuitbreaker_state gauge
resilience4j_circuitbreaker_state{name="backendA",state="half_open",} 0.0
resilience4j_circuitbreaker_state{name="backendA",state="forced_open",} 0.0
resilience4j_circuitbreaker_state{name="backendA",state="disabled",} 0.0
resilience4j_circuitbreaker_state{name="backendA",state="closed",} 1.0
resilience4j_circuitbreaker_state{name="backendA",state="open",} 0.0
resilience4j_circuitbreaker_state{name="backendA",} 0.0

# HELP resilience4j_circuitbreaker_failure_rate The failure rate of the circuit breaker
# TYPE resilience4j_circuitbreaker_failure_rate gauge
resilience4j_circuitbreaker_failure_rate{name="backendA",} 20.0

# HELP resilience4j_circuitbreaker_max_buffered_calls The maximum number of buffered calls which can be stored in the ring buffer
# TYPE resilience4j_circuitbreaker_max_buffered_calls gauge
resilience4j_circuitbreaker_max_buffered_calls{name="backendA",} 5.0

# HELP resilience4j_circuitbreaker_calls_seconds_max Total duration of calls
# TYPE resilience4j_circuitbreaker_calls_seconds_max gauge
resilience4j_circuitbreaker_calls_seconds_max{kind="successful",name="backendA",} 0.0
resilience4j_circuitbreaker_calls_seconds_max{kind="failed",name="backendA",} 0.0
resilience4j_circuitbreaker_calls_seconds_max{kind="ignored",name="backendA",} 0.0

resilience4j_circuitbreaker_calls_seconds_sum{kind="ignored",name="backendA",} 0.0

# HELP resilience4j_circuitbreaker_calls_seconds Total number of successful calls
# TYPE resilience4j_circuitbreaker_calls_seconds histogram
resilience4j_circuitbreaker_calls_seconds_count{kind="successful",name="backendA",} 0.0
resilience4j_circuitbreaker_calls_seconds_sum{kind="successful",name="backendA",} 0.0

# HELP resilience4j_circuitbreaker_calls_seconds Total number of failed calls
# TYPE resilience4j_circuitbreaker_calls_seconds histogram
resilience4j_circuitbreaker_calls_seconds_count{kind="failed",name="backendA",} 0.0
resilience4j_circuitbreaker_calls_seconds_sum{kind="failed",name="backendA",} 0.0
```

Bulkhead마다 다음과 같은 메트릭을 내보낸다:

```prometheus
# HELP resilience4j_bulkhead_available_concurrent_calls The number of available permissions
# TYPE resilience4j_bulkhead_available_concurrent_calls gauge
resilience4j_bulkhead_available_concurrent_calls{name="backendA",} 10.0

# HELP resilience4j_bulkhead_max_allowed_concurrent_calls The maximum number available permissions
# TYPE resilience4j_bulkhead_max_allowed_concurrent_calls gauge
resilience4j_bulkhead_max_allowed_concurrent_calls{name="backendA",} 10.0
```

Retry마다 다음과 같은 메트릭을 내보낸다:

```prometheus
# HELP resilience4j_retry_calls The number of successful calls without a retry attempt
# TYPE resilience4j_retry_calls gauge
resilience4j_retry_calls{kind="failed_with_retry",name="backendA",} 0.0
resilience4j_retry_calls{kind="failed_without_retry",name="backendA",} 0.0
resilience4j_retry_calls{kind="successful_without_retry",name="backendA",} 0.0
resilience4j_retry_calls{kind="successful_with_retry",name="backendA",} 0.0
```

RateLimiter마다 다음과 같은 메트릭을 내보낸다:

```prometheus
# HELP resilience4j_ratelimiter_waiting_threads The number of waiting threads
# TYPE resilience4j_ratelimiter_waiting_threads gauge
resilience4j_ratelimiter_waiting_threads{name="backendA",} 0.0

# HELP resilience4j_ratelimiter_available_permissions The number of available permissions
# TYPE resilience4j_ratelimiter_available_permissions gauge
resilience4j_ratelimiter_available_permissions{name="backendA",} 50.0
```