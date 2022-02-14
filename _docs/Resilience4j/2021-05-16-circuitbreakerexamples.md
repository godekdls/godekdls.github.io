---
title: CircuitBreaker Examples
navTitle: ㄴ Examples
category: Resilience4j
order: 7
permalink: /Resilience4j/circuitbreaker-examples/
description: 서킷 브레이커 사용 예시 한국어 번역
image: ./../../images/resilience4j/logo.png
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: resilience4j
originalRefLink: https://resilience4j.readme.io/v1.7.0/docs/examples
---

### 목차

- [Create a CircuitBreakerRegistry](#create-a-circuitbreakerregistry)
- [Create a CircuitBreaker](#create-a-circuitbreaker)
- [Decorate a functional interface](#decorate-a-functional-interface)
- [Execute a decorated functional interface](#execute-a-decorated-functional-interface)
- [Recover from an exception](#recover-from-an-exception)
- [Reset CircuitBreaker](#reset-circuitbreaker)
- [Transition to states manually](#transition-to-states-manually)
- [Override the RegistryStore](#override-the-registrystore)

---

## Create a CircuitBreakerRegistry

커스텀 CircuitBreakerConfig를 통해 CircuitBreakerRegistry를 만들어보자.

```java
// Create a custom configuration for a CircuitBreaker
CircuitBreakerConfig circuitBreakerConfig = CircuitBreakerConfig.custom()
    .failureRateThreshold(50)
    .waitDurationInOpenState(Duration.ofMillis(1000))
    .permittedNumberOfCallsInHalfOpenState(2)
    .slidingWindowSize(2)
    .recordExceptions(IOException.class, TimeoutException.class)
    .ignoreExceptions(BusinessException.class, OtherBusinessException.class)
    .build();

// Create a CircuitBreakerRegistry with a custom global configuration
CircuitBreakerRegistry circuitBreakerRegistry =
  CircuitBreakerRegistry.of(circuitBreakerConfig);
```

---

## Create a CircuitBreaker

CircuitBreakerRegistry에서 글로벌 디폴트 설정을 사용하는 CircuitBreaker를 가져온다.

```java
CircuitBreaker circuitBreaker = circuitBreakerRegistry
  .circuitBreaker("name");
```

---

## Decorate a functional interface

호출할 로직 `BackendService.doSomething()`을 CircuitBreaker로 데코레이팅하고, 데코레이팅한 supplier를 실행해 모든 예외를 복구한다.

```java
Supplier<String> decoratedSupplier = CircuitBreaker
    .decorateSupplier(circuitBreaker, backendService::doSomething);

String result = Try.ofSupplier(decoratedSupplier)
    .recover(throwable -> "Hello from Recovery").get();
```

---

## Execute a decorated functional interface

람다 표현식을 데코레이팅 없이 실행하돼 CircuitBreaker로 호출을 보호하고 싶을 때.

```java
String result = circuitBreaker
  .executeSupplier(backendService::doSomething);
```

---

## Recover from an exception

CircuitBreaker가 예외를 실패로 기록한 뒤에 예외를 복구하려면 `Try.recover()` 메소드를 체이닝하면 된다. 복구 메소드는 `Try.of()`가 `Failure<Throwable>` 모나드를 반환했을 때만 실행된다.

```java
// Given
CircuitBreaker circuitBreaker = CircuitBreaker.ofDefaults("testName");

// When I decorate my function and invoke the decorated function
CheckedFunction0<String> checkedSupplier =
  CircuitBreaker.decorateCheckedSupplier(circuitBreaker, () -> {
    throw new RuntimeException("BAM!");
});
Try<String> result = Try.of(checkedSupplier)
        .recover(throwable -> "Hello Recovery");

// Then the function should be a success, 
// because the exception could be recovered
assertThat(result.isSuccess()).isTrue();
// and the result must match the result of the recovery function.
assertThat(result.get()).isEqualTo("Hello Recovery");
```

CircuitBreaker가 예외를 실패로 기록하기 전에 복구하려면 다음과 같이 작성하면 된다:

```java
Supplier<String> supplier = () -> {
            throw new RuntimeException("BAM!");
        };

Supplier<String> supplierWithRecovery = SupplierUtils
  .recover(supplier, (exception) -> "Hello Recovery");

String result = circuitBreaker.executeSupplier(supplierWithRecovery);

assertThat(result).isEqualTo("Hello Recovery");
```

`SupplierUtils`와 `CallableUtils`엔 `andThen` 등과 같이 함수를 체이닝하는 데 사용할 수 있는 다른 메소드들도 있다. 예를 들어 HTTP 응답의 상태 코드를 확인해서 예외를 던질 수 있다.

```java
Supplier<String> supplierWithResultAndExceptionHandler = SupplierUtils
  .andThen(supplier, (result, exception) -> "Hello Recovery");

Supplier<HttpResponse> supplier = () -> httpClient.doRemoteCall();
Supplier<HttpResponse> supplierWithResultHandling = SupplierUtils.andThen(supplier, result -> {
    if (result.getStatusCode() == 400) {
       throw new ClientException();
    } else if (result.getStatusCode() == 500) {
       throw new ServerException();
    }
    return result;
});
HttpResponse httpResponse = circuitBreaker
  .executeSupplier(supplierWithResultHandling);
```

---

## Reset CircuitBreaker

서킷 브레이커는 원래 상태로 리셋할 수 있다. 사실상 모든 메트릭을 날리고 슬라이딩 윈도우를 리셋한다.

```java
CircuitBreaker circuitBreaker = CircuitBreaker.ofDefaults("testName");
circuitBreaker.reset();
```

---

## Transition to states manually

```java
CircuitBreaker circuitBreaker = CircuitBreaker.ofDefaults("testName");
circuitBreaker.transitionToDisabledState();
// circuitBreaker.onFailure(...) won't trigger a state change
circuitBreaker.transitionToClosedState(); // will transition to CLOSED state and re-enable normal behaviour, keeping metrics
circuitBreaker.transitionToForcedOpenState();
// circuitBreaker.onSuccess(...) won't trigger a state change
circuitBreaker.reset(); //  will transition to CLOSED state and re-enable normal behaviour, losing metrics
```

---

## Override the RegistryStore

커스텀 구현체로 인메모리 RegistryStore를 재정의할 수 있다. 예를 들어 일정 시간이 지나면 사용하지 않는 인스턴스를 제거하는 캐시를 사용하고 싶다면:

```java
CircuitBreakerRegistry circuitBreakerRegistry = CircuitBreakerRegistry.custom()
  .withRegistryStore(new CacheCircuitBreakerRegistryStore())
  .build();
```