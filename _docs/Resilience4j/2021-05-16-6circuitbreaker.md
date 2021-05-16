---
title: CircuitBreaker
category: Resilience4j
order: 6
permalink: /Resilience4j/circuitbreaker/
description: 서킷 브레이커 기본 소개를 한글로 번역한 문서입니다. 서킷 브레이커 동작 원리와 카운트/시간 기반 슬라이딩 윈도우, 실패 비율 임계치 등의 설정값을 소개합니다.
image: ./../../images/resilience4j/39cdd54-state_machine.jpeg
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: resilience4j
originalRefLink: https://resilience4j.readme.io/v1.7.0/docs/circuitbreaker
boundary: CORE MODULES
priority: 0.8
---

### 목차

- [Introduction](#introduction)
- [Count-based sliding window](#count-based-sliding-window)
- [Time-based sliding window](#time-based-sliding-window)
- [Failure rate and slow call rate thresholds](#failure-rate-and-slow-call-rate-thresholds)
- [Create a CircuitBreakerRegistry](#create-a-circuitbreakerregistry)
- [Create and configure a CircuitBreaker](#create-and-configure-a-circuitbreaker)
- [Decorate and execute a functional interface](#decorate-and-execute-a-functional-interface)
- [Consume emitted RegistryEvents](#consume-emitted-registryevents)
- [Consume emitted CircuitBreakerEvents](#consume-emitted-circuitbreakerevents)
- [Override the RegistryStore](#override-the-registrystore)

---

## Introduction

CircuitBreaker는 [유한 상태 기계(finite state machine, FSM)](https://ko.wikipedia.org/wiki/%EC%9C%A0%ED%95%9C_%EC%83%81%ED%83%9C_%EA%B8%B0%EA%B3%84)를 통해 구현한다. 여기에는 일반적인 상태 세 가지와 (`CLOSED`, `OPEN`, `HALF_OPEN`), 두 가지 특수 상태가 (`DISABLED`, `FORCED_OPEN`) 있다.

![39cdd54-state_machine](../../images/resilience4j/39cdd54-state_machine.jpeg)

CircuitBreaker는 호출 결과를 저장하고 집계할 땐 슬라이딩 윈도우를 사용한다. [카운트 기반 슬라이딩 윈도우(count-based sliding window)](#count-based-sliding-window)와 [시간 기반 슬라이딩 윈도우(time-based sliding window)](#time-based-sliding-window)라는 두 가지 선택지가 있다. 카운트 기반 슬라이딩 윈도우는 마지막으로 호출한 N번의 결과를 집계하고, 시간 기반 슬라이딩 윈도우는 마지막 N초 동안의 호출 결과를 집계한다.

---

## Count-based sliding window

카운트 기반 슬라이딩 윈도우는 N개의 측정값을 지닌 원형 배열로 구현한다.<br>
카운트 윈도우의 크기가 10이라면, 원형 배열에는 항상 10개의 측정 값이 존재한다.<br>슬라이딩 윈도우는 총 집계를 조금씩 업데이트해 나간다. 총 집계 업데이트는 새 호출 결과를 기록할 때 일어난다. 가장 오래된 측정값이 제거되면, 총 집계에서 이 측정값을 차감시키고 해당 버킷은 리셋된다. (Subtract-on-Evict)

스냅샷은 미리 집계돼 있으며, 윈도우 크기와는 무관하기 때문에 스냅샷을 조회할 때 필요한 시간은 상수 O(1)이다.<br>
이 구현체에서 필요로하는 공간(메모리 소비)은 O(n)이 되겠다.

---

## Time-based sliding window

시간 기반 슬라이딩 윈도우는 N개의 부분 집계(버킷)를 지닌 원형 배열로 구현한다.<br>
시간 윈도우의 크기가 10초라면, 원형 배열에는 항상 10개의 부분 집계(버킷)가 존재한다. 각 버킷은 특정 epoch second 동안 일어난 모든 호출 결과를 집계한다. (부분 집계). 원형 배열에서 헤드 버킷은 현재 epoch second의 호출 결과를 담고 있다. 나머지 부분 집계는 지나간 초 동안의 호출 결과를 저장하고 있다.<br>슬라이딩 윈도우는 호출 결과(튜플)를 개별적으로 저장하진 않고, 부분 집계(버킷)와 총 집계를 조금씩 업데이트해 나간다.<br>
총 집계는 새 호출 결과를 기록할 때마다 업데이트된다. 가장 오래된 버킷이 제거되면, 총 집계에서 이 버킷의 부분 집계는 제외되며, 해당 버킷은 리셋된다. (Subtract-on-Evict)

스냅샷은 미리 집계돼 있으며, 시간 윈도우 크기와는 무관하기 때문에 스냅샷을 조회할 때 필요한 시간은 상수 O(1)이다.<br>
호출 결과(튜플)를 개별적으로 저장하지 않기 때문에, 이 구현체에서 필요로하는 공간(메모리 소비)은 상수 O(n)과 근접하겠다. 여기서 생성되는 건 부분 집계 N개와, 총 집계 1개가 전부다.

부분 집계는 실패한 호출과, 느렸던 호출(slow call), 총 호출 횟수를 카운팅하기 위한 3개의 integer로 구성된다. 추가로, 전체 호출에 소요한 총 시간을 저장하는 long 하나를 가지고 있다.

---

## Failure rate and slow call rate thresholds

실패 비율이 설정한 임계치보다 크거나 같을 땐 CircuitBreaker의 상태는 CLOSED에서 OPEN으로 변경된다. 예를 들어 50% 이상이 실패로 기록됐을 때 등 말이다.<br>
기본적으로는 모든 예외를 실패로 간주한다. 실패로 간주할 예외 리스트를 정의해도 된다. 이렇게 하면 무시하는 예외만 아니면 그 외 모든 예외를 성공으로 간주한다. 예외는 무시할 수도 있는데, 무시한 예외는 실패, 성공, 둘 중 무엇으로도 계산하지 않는다.

느린 호출(slow call) 비율이 설정한 임계치보다 크거나 같을 때도 CircuitBreaker는 CLOSED에서 OPEN으로 변경된다. 예를 들어 50% 이상이 5초 이상 소요된 것으로 기록됐을 때 말이다. 이렇게하면 외부 시스템이 아직까진 응답을 안 준 건 아니더라도, 미리 부하를 줄일 수 있다.

실패 비율과 느린 호출 비율을 계산하려면 먼저 호출 결과를 최소치는 기록한 상태여야 한다. 예를 들어 최소한으로 필요한 호출 횟수가 10번이라면, 호출을 최소 10번은 기록한 다음에야 실패 비율을 계산할 수 있다. 9번밖에 측정하지 않았다면 9번 모두 실패했더라도 CircuitBreaker는 열리지 않는다.

CircuitBreaker는 OPEN 상태일 땐 `CallNotPermittedException`을 던져 호출을 반려한다. 대기 시간이 경과하고 나면 OPEN에서 HALF_OPEN으로 상태가 변경되며, 설정한 횟수만큼 호출을 허용해 이 백엔드가 아직도 이용 불가능한지, 아니면 사용 가능한 상태로 돌아왔는지 확인한다. 허용한 호출을 모두 완료할 때 까지는 그 이상의 호출은 `CallNotPermittedException`으로 거부된다.<br>
실패 비율이나 느린 호출 비율이 설정한 임계치보다 크거나 같으면 상태는 다시 OPEN으로 변경된다. 둘 모두 임계치 미만이면  CLOSED 상태로 돌아간다.

서킷 브레이커는 두 가지 특수 상태 DISABLED(항상 접근 허용)와 FORCED_OPEN(항상 접근 거부)을 지원한다. 이 두 상태에선 서킷 브레이커 이벤트(상태 전환은 예외)를 생성하지도, 메트릭을 기록하지도 않는다. 이 상태에서 빠져나오려면 상태 전환을 트리거하거나 서킷 브레이커를 리셋하는 방법 밖에 없다.

CircuitBreaker는 다음과 같이 구현했기 때문에 thread-safe하다:

- CircuitBreaker의 상태는 AtomicReference에 저장한다.
- CircuitBreaker는 원자적 연산과 사이드 이펙트 없는 함수를 통해 상태를 업데이트한다.
- 슬라이딩 윈도우에 호출 결과를 기록하고 스냅샷을 조회할 땐 동기화한다.

즉, 원자성을 보장해야 하며, 특정 시점엔 하나의 스레드만 상태나 슬라이딩 윈도우를 업데이트할 수 있다.

단, CircuitBreaker는 함수 호출을 동기화하진 않는다. 다시 말해 함수 호출 자체는 크리티컬한 섹션에 속하지 않는다. 함수 호출을 모두 동기화 했다면 CircuitBreaker엔 엄청난 성능 저하와 병목 현상이 발생할 거다. 호출한 함수가 느려지면 전반적인 성능/처리량에 주는 영향이 크다.

동시에 20개의 스레드가 함수 실행 권한을 요청해도 CircuitBreaker가 닫힌 상태였다면 모든 스레드가 함수를 호출할 수 있다. 슬라이딩 윈도우 크기가 15였다고 해도 가능하다. 사이즈가 15라고 해서 이 슬라이딩 윈도우를 동시에 실행할 수 있는 스레드가 15개 뿐이라는 뜻은 아니다. 동시 스레드 수를 제한하고 싶다면 Bulkhead를 사용해라. CircuitBreaker와 Bulkhead를 조합해도 된다.

**Example with 1 Thread**:

![45dc011-Thread1](../../images/resilience4j/45dc011-Thread1.png)

**Example with 3 Threads**:

![8d10418-Multiplethreads](../../images/resilience4j/8d10418-Multiplethreads.png)

---

## Create a CircuitBreakerRegistry

Resilience4j는 thread safety와 원자성을 보장해주는 ConcurrentHashMap 기반 인 메모리 `CircuitBreakerRegistry`를 함께 제공한다. 이 `CircuitBreakerRegistry`를 사용해서 CircuitBreaker 인스턴스들을 관리(생성/조회)할 수 있다. 모든 CircuitBreaker 인스턴스를 위한 글로벌 디폴트 `CircuitBreakerConfig`를 사용하는 `CircuitBreakerRegistry`는 다음과 같이 생성할 수 있다.

```java
CircuitBreakerRegistry circuitBreakerRegistry = 
  CircuitBreakerRegistry.ofDefaults();
```

---

## Create and configure a CircuitBreaker

자체 커스텀 글로벌 `CircuitBreakerConfig`를 제공하는 것도 가능하다. 커스텀 글로벌 `CircuitBreakerConfig`를 만들 땐 CircuitBreakerConfig 빌더를 사용하면 된다. 이 빌더를 통해 아래와 같은 프로퍼티를 설정할 수 있다.

| Config property                                              | Default Value                                                | Description                                                  |
| :----------------------------------------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| <span class="custom-blockquote">failureRateThreshold</span>  | 50                                                           | 실패 비율 임계치를 백분율로 설정한다. 실패 비율이 임계치보다 크거나 같으면 CircuitBreaker는 open 상태로 전환되며, 이때부터 호출을 끊어낸다. |
| <span class="custom-blockquote">slowCallRateThreshold</span> | 100                                                          | 임계 값을 백분율로 설정한다. CircuitBreaker는 호출에 걸리는 시간이 `slowCallDurationThreshold`보다 길면 느린 호출로 간주한다. 느린 호출 비율이 이 임계치보다 크거나 같으면 CircuitBreaker는 open 상태로 전환되며, 이때부터 호출을 끊어낸다. |
| <span class="custom-blockquote">slowCallDurationThreshold</span> | 60000 [ms]                                                   | 호출에 소요되는 시간이 설정한 임계치보다 길면 느린 호출로 계산한다. |
| <span class="custom-blockquote">permittedNumberOfCalls InHalfOpenState</span> | 10                                                           | CircuitBreaker가 half open 상태일 때 허용할 호출 횟수를 설정한다. |
| <span class="custom-blockquote">maxWaitDurationInHalfOpenState</span> | 0                                                            | CircuitBreaker를 Half Open 상태로 유지할 수 있는 최대 시간으로, 이 시간만큼 경과하면 open 상태로 전환한다. 0일 땐 허용 횟수만큼 호출을 모두 완료할 때까지 HalfOpen 상태로 무한정 기다린다. |
| <span class="custom-blockquote">slidingWindowType</span>     | COUNT_BASED                                                  | CircuitBreaker가 닫힌 상태에서 호출 결과를 기록할 때 쓸 슬라이딩 윈도우 타입을 설정한다. 슬라이딩 윈도우는 카운트 기반과 시간 기반이 있다. 슬라이딩 윈도우가 COUNT_BASED일 땐 마지막 `slidingWindowSize` 횟수만큼의 호출을 기록하고 집계한다. TIME_BASED일 땐 마지막 `slidingWindowSize` 초 동안의 호출을 기록하고 집계한다. |
| <span class="custom-blockquote">slidingWindowSize</span>     | 100                                                          | CircuitBreaker가 닫힌 상태에서 호출 결과를 기록할 때 쓸 슬라이딩 윈도우의 크기를 설정한다. |
| <span class="custom-blockquote">minimumNumberOfCalls</span>  | 100                                                          | CircuitBreaker가 실패 비율이나 느린 호출 비율을 계산할 때 필요한 (슬라이딩 윈도우 주기마다) 최소 호출 수를 설정한다. 예를 들어서 `minimumNumberOfCalls`가 10이라면 최소한 호출을 10번을 기록해야 실패 비율을 계산할 수 있다. 기록한 호출 횟수가 9번 뿐이라면 9번 모두 실패했더라도 CircuitBreaker는 열리지 않는다. |
| <span class="custom-blockquote">waitDurationInOpenState</span> | 60000 [ms]                                                   | CircuitBreaker가 half-open에서 open으로 전환하기 전 기다리는 시간. |
| <span class="custom-blockquote">automaticTransition FromOpenToHalfOpenEnabled</span> | false                                                        | true로 설정하면 CircuitBreaker는 open 상태에서 자동으로 half-open 상태로 전환하며, 이땐 호출이 없어도 전환을 트리거한다. 시간이 `waitIntervalFunctionInOpenState` 만큼 경과하면 모든 CircuitBreaker 인스턴스를 모니터링해서 HALF_OPEN으로 전환시키는 스레드가 생성된다. 반대로 false로 설정하면 `waitIntervalFunctionInOpenState` 만큼 경과하더라도 호출이 한 번은 일어나야 HALF_OPEN으로 전환한다. 이때 좋은 점은 모든 CircuitBreaker의 상태를 모니터링하는 스레드가 없다는 거다. |
| <span class="custom-blockquote">recordExceptions</span>      | empty                                                        | 실패로 기록해 실패 비율 계산에 포함시킬 예외 리스트. `ignoreExceptions`를 통해 무시하겠다고 명시하지만 않았다면, 리스트에 일치하거나 상속한 예외가 있다면 모두 실패로 간주한다. 예외 리스트를 지정하게 되면 나머지 예외는 `ignoreExceptions`로 무시하는 예외를 빼고는 전부 성공으로 계산한다. |
| <span class="custom-blockquote">ignoreExceptions</span>      | empty                                                        | 무시만 하고 실패나 성공으로 계산하지 않는 예외 리스트. 리스트에 일치하거나 상속한 예외가 있다면, `recordExceptions`에 지정했더라도 실패나 성공으로 간주하지 않는다. |
| <span class="custom-blockquote">recordException</span>       | <span class="custom-blockquote">throwable -> true</span><br>기본적으론 모든 예외를 실패로 기록한다. | 예외를 실패로 기록할지를 평가하는 커스텀 Predicate. 예외를 실패로 계산해야 할 땐 true를 리턴해야 한다. `ignoreExceptions`로 무시되는 경우를 제외하고는 성공으로 간주해야 한다면 false를 반환해야 한다. |
| <span class="custom-blockquote">ignoreException</span>       | <span class="custom-blockquote">throwable -> false</span><br>기본적으론 어떤 예외도 무시하지 않는다. | 예외를 무시해서 실패나 성공으로 간주하지 않을지를 평가하는 커스텀 Predicate. 예외를 무시해야 할 땐 true를, 실패로 간주해야 할 땐 false를 리턴해야 한다. |

```java
// Create a custom configuration for a CircuitBreaker
CircuitBreakerConfig circuitBreakerConfig = CircuitBreakerConfig.custom()
  .failureRateThreshold(50)
  .slowCallRateThreshold(50)
  .waitDurationInOpenState(Duration.ofMillis(1000))
  .slowCallDurationThreshold(Duration.ofSeconds(2))
  .permittedNumberOfCallsInHalfOpenState(3)
  .minimumNumberOfCalls(10)
  .slidingWindowType(SlidingWindowType.TIME_BASED)
  .slidingWindowSize(5)
  .recordException(e -> INTERNAL_SERVER_ERROR
                 .equals(getResponse().getStatus()))
  .recordExceptions(IOException.class, TimeoutException.class)
  .ignoreExceptions(BusinessException.class, OtherBusinessException.class)
  .build();

// Create a CircuitBreakerRegistry with a custom global configuration
CircuitBreakerRegistry circuitBreakerRegistry = 
  CircuitBreakerRegistry.of(circuitBreakerConfig);

// Get or create a CircuitBreaker from the CircuitBreakerRegistry 
// with the global default configuration
CircuitBreaker circuitBreakerWithDefaultConfig = 
  circuitBreakerRegistry.circuitBreaker("name1");

// Get or create a CircuitBreaker from the CircuitBreakerRegistry 
// with a custom configuration
CircuitBreaker circuitBreakerWithCustomConfig = circuitBreakerRegistry
  .circuitBreaker("name2", circuitBreakerConfig);
```

여러 CircuitBreaker 인스턴스에 공유할 수 있는 설정을 추가할 수도 있다.

```java
CircuitBreakerConfig circuitBreakerConfig = CircuitBreakerConfig.custom()
  .failureRateThreshold(70)
  .build();

circuitBreakerRegistry.addConfiguration("someSharedConfig", config);

CircuitBreaker circuitBreaker = circuitBreakerRegistry
  .circuitBreaker("name", "someSharedConfig");
```

설정 재정의도 가능하다.

```java
CircuitBreakerConfig defaultConfig = circuitBreakerRegistry
   .getDefaultConfig();

CircuitBreakerConfig overwrittenConfig = CircuitBreakerConfig
  .from(defaultConfig)
  .waitDurationInOpenState(Duration.ofSeconds(20))
  .build();
```

CircuitBreakerRegistry를 통해 CircuitBreaker 인스턴스를 관리하고 싶지 않다면, 인스턴스를 직접 만들어도 된다.

```java
// Create a custom configuration for a CircuitBreaker
CircuitBreakerConfig circuitBreakerConfig = CircuitBreakerConfig.custom()
  .recordExceptions(IOException.class, TimeoutException.class)
  .ignoreExceptions(BusinessException.class, OtherBusinessException.class)
  .build();

CircuitBreaker customCircuitBreaker = CircuitBreaker
  .of("testName", circuitBreakerConfig);
```

아니면 빌더 메소드를 사용해서 CircuitBreakerRegistry를 생성하는 방법도 있다.

```java
Map <String, String> circuitBreakerTags = Map.of("key1", "value1", "key2", "value2");

CircuitBreakerRegistry circuitBreakerRegistry = CircuitBreakerRegistry.custom()
    .withCircuitBreakerConfig(CircuitBreakerConfig.ofDefaults())
    .addRegistryEventConsumer(new RegistryEventConsumer() {
        @Override
        public void onEntryAddedEvent(EntryAddedEvent entryAddedEvent) {
            // implementation
        }
        @Override
        public void onEntryRemovedEvent(EntryRemovedEvent entryRemoveEvent) {
            // implementation
        }
        @Override
        public void onEntryReplacedEvent(EntryReplacedEvent entryReplacedEvent) {
            // implementation
        }
    })
    .withTags(circuitBreakerTags)
    .build();

CircuitBreaker circuitBreaker = circuitBreakerRegistry.circuitBreaker("testName");
```

자체의 레지스트리 구현체를 사용하고 싶다면 `RegistryStore` 인터페이스를 직접 구현해서 빌더 메소드로 연결하면 된다.

```java
CircuitBreakerRegistry registry = CircuitBreakerRegistry.custom()
    .withRegistryStore(new YourRegistryStoreImplementation())
    .withCircuitBreakerConfig(CircuitBreakerConfig.ofDefaults())
    .build():
```

---

## Decorate and execute a functional interface

`Callable`, `Supplier`, `Runnable`, `Consumer`, `CheckedRunnable`, `CheckedSupplier`, `CheckedConsumer`, `CompletionStage`라면 모두 CircuitBreaker로 데코레이트할 수 있다.<br>데코레이팅한 함수는 Vavr에 있는 `Try.of(…)`나 `Try.run(…)`을 통해 호출하면 된다. 이렇게 하면 map, flatMap, filter, recover, andThen으로 다른 함수를 체이닝할 수 있다. 체이닝한 함수는 CircuitBreaker가 CLOSED나 HALF_OPEN 상태일 때만 실행된다.<br>아래 예제에서 `Try.of(…)`는 함수 호출에 성공하면 `Success<String>` 모나드를 반환한다. 함수에서 예외를 던지면 `Failure<Throwable>` 모나드를 반환하며, map은 실행되지 않는다.

```java
// Given
CircuitBreaker circuitBreaker = CircuitBreaker.ofDefaults("testName");

// When I decorate my function
CheckedFunction0<String> decoratedSupplier = CircuitBreaker
        .decorateCheckedSupplier(circuitBreaker, () -> "This can be any method which returns: 'Hello");

// and chain an other function with map
Try<String> result = Try.of(decoratedSupplier)
                .map(value -> value + " world'");

// Then the Try Monad returns a Success<String>, if all functions ran successfully.
assertThat(result.isSuccess()).isTrue();
assertThat(result.get()).isEqualTo("This can be any method which returns: 'Hello world'");
```

---

## Consume emitted RegistryEvents

CircuitBreakerRegistry에 이벤트 컨슈머를 등록해서 CircuitBreaker가 생성, 교체, 삭제될 때마다 필요한 로직을 실행할 수 있다.

```java
CircuitBreakerRegistry circuitBreakerRegistry = CircuitBreakerRegistry.ofDefaults();
circuitBreakerRegistry.getEventPublisher()
  .onEntryAdded(entryAddedEvent -> {
    CircuitBreaker addedCircuitBreaker = entryAddedEvent.getAddedEntry();
    LOG.info("CircuitBreaker {} added", addedCircuitBreaker.getName());
  })
  .onEntryRemoved(entryRemovedEvent -> {
    CircuitBreaker removedCircuitBreaker = entryRemovedEvent.getRemovedEntry();
    LOG.info("CircuitBreaker {} removed", removedCircuitBreaker.getName());
  });
```

---

## Consume emitted CircuitBreakerEvents

CircuitBreakerEvent는 상태 전환이나, 서킷 브레이커 리셋 이벤트일 수도 있고, 호출 성공 이벤트, 에러 기록, 에러 무시 이벤트일 수도 있다. 모든 이벤트는 이벤트 생성 시간, 호출에 소요된 시간과 같은 추가 정보를 가지고 있다. 이벤트를 컨슘하려면 이벤트 컨슈머를 등록해야 한다.

```java
circuitBreaker.getEventPublisher()
    .onSuccess(event -> logger.info(...))
    .onError(event -> logger.info(...))
    .onIgnoredError(event -> logger.info(...))
    .onReset(event -> logger.info(...))
    .onStateTransition(event -> logger.info(...));
// Or if you want to register a consumer listening
// to all events, you can do:
circuitBreaker.getEventPublisher()
    .onEvent(event -> logger.info(...));
```

CircularEventConsumer를 사용하면 용량을 고정해둔 원형 버퍼에 이벤트를 저장할 수 있다.

```java
CircularEventConsumer<CircuitBreakerEvent> ringBuffer = 
  new CircularEventConsumer<>(10);
circuitBreaker.getEventPublisher().onEvent(ringBuffer);
List<CircuitBreakerEvent> bufferedEvents = ringBuffer.getBufferedEvents()
```

RxJava나 RxJava2 어댑터를 사용하면 EventPublisher를 리액티브 스트림으로 전환할 수 있다.

---

## Override the RegistryStore

인 메모리 RegistryStore는 커스텀 구현체로 재정의할 수 있다. 예를 들어 일정 시간이 지나면 사용하지 않는 인스턴스를 제거하는 캐시를 사용하고 싶다면:

```java
CircuitBreakerRegistry circuitBreakerRegistry = CircuitBreakerRegistry.custom()
  .withRegistryStore(new CacheCircuitBreakerRegistryStore())
  .build();
```