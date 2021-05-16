---
title: Configuring Spring Retry Circuit Breakers
category: Spring Cloud Circuit Breaker
order: 3
permalink: /Spring%20Cloud%20Circuit%20Breaker/configuring-spring-retry-circuit-breakers/
description: 스프링 클라우드 Retry 서킷 브레이커 의존성을 추가하고 설정하는 방법
image: ./../../images/springcloud/logo.jpeg
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: 스프링 클라우드 서킷 브레이커
originalRefLink: https://docs.spring.io/spring-cloud-circuitbreaker/docs/2.0.1/reference/html/#configuring-spring-retry-circuit-breakers
---

### 목차

- [2.1. Default Configuration](#21-default-configuration)
- [2.2. Specific Circuit Breaker Configuration](#22-specific-circuit-breaker-configuration)

---

스프링 어플리케이션에 Spring Retry를 사용하면 재시도 로직을 선언만으로 추가할 수 있다. 이 프로젝트 하위에는 서킷 브레이커 기능을 구현한 로직이 포함돼 있다. Spring Retry는 자체 [`CircuitBreakerRetryPolicy`](https://github.com/spring-projects/spring-retry/blob/master/src/main/java/org/springframework/retry/policy/CircuitBreakerRetryPolicy.java)와 [stateful retry](https://github.com/spring-projects/spring-retry#stateful-retry)를 조합해서 서킷 브레이커 구현체를 제공한다. Spring Retry를 사용해 생성한 모든 서킷 브레이커는 `CircuitBreakerRetryPolicy`와 [`DefaultRetryState`](https://github.com/spring-projects/spring-retry/blob/master/src/main/java/org/springframework/retry/support/DefaultRetryState.java)를 통해 생성된다. 이 두 클래스는 `SpringRetryConfigBuilder`로 구성할 수 있다.

---

## 2.1. Default Configuration

모든 서킷 브레이커에서 사용할 디폴트 설정을 만들고 싶다면 `SpringRetryCircuitBreakerFactory`를 넘겨받는 `Customize` 빈을 만들어라. `configureDefault` 메소드를 통해 디폴트 설정을 제공할 수 있다.

```java
@Bean
public Customizer<SpringRetryCircuitBreakerFactory> defaultCustomizer() {
    return factory -> factory.configureDefault(id -> new SpringRetryConfigBuilder(id)
        .retryPolicy(new TimeoutRetryPolicy()).build());
}
```

---

## 2.2. Specific Circuit Breaker Configuration

디폴트 설정을 제공할 때처럼 `SpringRetryCircuitBreakerFactory`를 넘겨받는 `Customize` 빈을 생성하면 된다.

```java
@Bean
public Customizer<SpringRetryCircuitBreakerFactory> slowCustomizer() {
    return factory -> factory.configure(builder -> builder.retryPolicy(new SimpleRetryPolicy(1)).build(), "slow");
}
```

서킷 브레이커를 생성할 때 사용할 설정을 지정하는 것 말고도, 서킷 브레이커를 생성한 후 호출자에 반환하기 전에 커스텀할 수도 있다. 이땐 `addRetryTemplateCustomizers` 메소드를 사용하면 된다. `RetryTemplate`에 이벤트 핸들러를 추가한다면 유용할 거다.

```java
@Bean
public Customizer<SpringRetryCircuitBreakerFactory> slowCustomizer() {
    return factory -> factory.addRetryTemplateCustomizers(retryTemplate -> retryTemplate.registerListener(new RetryListener() {

        @Override
        public <T, E extends Throwable> boolean open(RetryContext context, RetryCallback<T, E> callback) {
            return false;
        }

        @Override
        public <T, E extends Throwable> void close(RetryContext context, RetryCallback<T, E> callback, Throwable throwable) {

        }

        @Override
        public <T, E extends Throwable> void onError(RetryContext context, RetryCallback<T, E> callback, Throwable throwable) {

        }
    }));
}
```