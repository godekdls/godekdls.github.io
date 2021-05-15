---
title: Configuring Resilience4J Circuit Breakers
category: Spring Cloud Circuit Breaker
order: 2
permalink: /Spring%20Cloud%20Circuit%20Breaker/configuring-resilience4j-circuit-breakers/
description: todo
image: ./../../images/springcloud/logo.jpeg
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: 스프링 클라우드 서킷 브레이커
originalRefLink: https://docs.spring.io/spring-cloud-circuitbreaker/docs/2.0.1/reference/html/#configuring-resilience4j-circuit-breakers
---

### 목차

- [1.1. Starters](#11-starters)
- [1.2. Auto-Configuration](#12-auto-configuration)
- [1.3. Default Configuration](#13-default-configuration)
  + [Reactive Example](#reactive-example)
- [1.4. Specific Circuit Breaker Configuration](#14-specific-circuit-breaker-configuration)
  + [Reactive Example](#reactive-example-1)
- [1.5. Collecting Metrics](#15-collecting-metrics)

---

## 1.1. Starters

Resilience4J 구현체엔 두 종류의 스타터가 있다. 하나는 reactive 어플리케이션 전용, 다른 하나는 non-reactive 어플리케이션 용이다.

- `org.springframework.cloud:spring-cloud-starter-circuitbreaker-resilience4j` - non-reactive 어플리케이션
- `org.springframework.cloud:spring-cloud-starter-circuitbreaker-reactor-resilience4j` - reactive 어플리케이션

---

## 1.2. Auto-Configuration

Resilience4J 자동 설정은 `spring.cloud.circuitbreaker.resilience4j.enabled`를 `false`로 설정하면 비활성화할 수 있다.

---

## 1.3. Default Configuration

모든 서킷 브레이커에서 사용할 디폴트 설정을 만들고 싶다면 `Resilience4JCircuitBreakerFactory`나`ReactiveResilience4JCircuitBreakerFactory`를 넘겨받는 `Customize` 빈을 만들어라. `configureDefault` 메소드를 통해 디폴트 설정을 제공할 수 있다.

```java
@Bean
public Customizer<Resilience4JCircuitBreakerFactory> defaultCustomizer() {
    return factory -> factory.configureDefault(id -> new Resilience4JConfigBuilder(id)
            .timeLimiterConfig(TimeLimiterConfig.custom().timeoutDuration(Duration.ofSeconds(4)).build())
            .circuitBreakerConfig(CircuitBreakerConfig.ofDefaults())
            .build());
}
```

#### Reactive Example

```java
@Bean
public Customizer<ReactiveResilience4JCircuitBreakerFactory> defaultCustomizer() {
    return factory -> factory.configureDefault(id -> new Resilience4JConfigBuilder(id)
            .circuitBreakerConfig(CircuitBreakerConfig.ofDefaults())
            .timeLimiterConfig(TimeLimiterConfig.custom().timeoutDuration(Duration.ofSeconds(4)).build()).build());
}
```

---

## 1.4. Specific Circuit Breaker Configuration

디폴트 설정을 제공할 때처럼 `Resilience4JCircuitBreakerFactory`나 `ReactiveResilience4JCircuitBreakerFactory`를 넘겨받는 `Customize` 빈을 생성하면 된다.

```java
@Bean
public Customizer<Resilience4JCircuitBreakerFactory> slowCustomizer() {
    return factory -> factory.configure(builder -> builder.circuitBreakerConfig(CircuitBreakerConfig.ofDefaults())
            .timeLimiterConfig(TimeLimiterConfig.custom().timeoutDuration(Duration.ofSeconds(2)).build()), "slow");
}
```

서킷 브레이커를 생성할 때 사용할 설정을 지정하는 것 말고도, 서킷 브레이커를 생성한 후 호출자에 반환하기 전에 커스텀할 수도 있다. 이땐 `addCircuitBreakerCustomizer` 메소드를 사용하면 된다. Resilience4J 서킷 브레이커에 이벤트 핸들러를 추가한다면 유용할 거다.

```java
@Bean
public Customizer<Resilience4JCircuitBreakerFactory> slowCustomizer() {
    return factory -> factory.addCircuitBreakerCustomizer(circuitBreaker -> circuitBreaker.getEventPublisher()
    .onError(normalFluxErrorConsumer).onSuccess(normalFluxSuccessConsumer), "normalflux");
}
```

#### Reactive Example

```java
@Bean
public Customizer<ReactiveResilience4JCircuitBreakerFactory> slowCustomizer() {
    return factory -> {
        factory.configure(builder -> builder
        .timeLimiterConfig(TimeLimiterConfig.custom().timeoutDuration(Duration.ofSeconds(2)).build())
        .circuitBreakerConfig(CircuitBreakerConfig.ofDefaults()), "slow", "slowflux");
        factory.addCircuitBreakerCustomizer(circuitBreaker -> circuitBreaker.getEventPublisher()
            .onError(normalFluxErrorConsumer).onSuccess(normalFluxSuccessConsumer), "normalflux");
     };
}
```

---

## 1.5. Collecting Metrics

스프링 클라우드 서킷 브레이커 Resilience4j는 클래스패스에 의존성만 제대로 추가해줬다면 메트릭 수집을 위한 자동 설정을 기본으로 제공한다. 메트릭 수집을 활성화하려면 `org.springframework.boot:spring-boot-starter-actuator`와 `io.github.resilience4j:resilience4j-micrometer`를 포함하고 있어야 한다. 이 라이브러리 의존성이 존재하면 메트릭이 생성된다. 메트릭과 관련해서 자세한 정보는 [Resilience4j 문서](../../Resilience4j/micrometer)를 참고해라.

> `micrometer-core`는 `spring-boot-starter-actuator`에서 가져오기 때문에 직접 추가해줄 필욘 없다.