---
title: Bulkhead Examples
navTitle: ㄴ Examples
category: Resilience4j
order: 9
permalink: /Resilience4j/bulkhead-examples/
description: 벌크 헤드 사용 예시 한글 번역
image: ./../../images/resilience4j/logo.jpeg
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: resilience4j
originalRefLink: https://resilience4j.readme.io/v1.7.0/docs/examples-3
---

### 목차

- [Create a BulkheadRegistry](#create-a-bulkheadregistry)
- [Create a Bulkhead](#create-a-bulkhead)
- [Decorate a functional interface](#decorate-a-functional-interface)

---

## Create a BulkheadRegistry

커스텀 BulkheadConfig를 통해 BulkheadRegistry를 만들어보자.

```java
// Create a custom configuration for a Bulkhead
BulkheadConfig config = BulkheadConfig.custom()
        .maxConcurrentCalls(10)
        .maxWaitDuration(Duration.ofMillis(1))
        .build();

// Create a BulkheadRegistry with a custom global configuration
BulkheadRegistry bulkheadRegistry =
        BulkheadRegistry.of(config);
```

---

## Create a Bulkhead

BulkheadRegistry에서 글로벌 디폴트 설정을 사용하는 Bulkhead를 가져온다.

```java
Bulkhead bulkhead = bulkheadRegistry
  .bulkhead("name");
```

---

## Decorate a functional interface

호출할 로직 `BackendService.doSomething()`을 Bulkhead로 데코레이팅하고, 데코레이팅한 supplier를 실행해 모든 예외를 복구한다.

```java
Supplier<String> decoratedSupplier = Bulkhead
    .decorateSupplier(retry, backendService::doSomething);

String result = Try.ofSupplier(decoratedSupplier)
    .recover(throwable -> "Hello from Recovery").get();
```