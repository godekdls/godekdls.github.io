---
title: Retry Examples
navTitle: ㄴ Examples
category: Resilience4j
order: 13
permalink: /Resilience4j/retry-examples/
description: Retry 사용 예시 한글 번역
image: ./../../images/resilience4j/logo.jpeg
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: resilience4j
originalRefLink: https://resilience4j.readme.io/v1.7.0/docs/examples-5
---

### 목차

- [Create a RetryRegistry](#create-a-retryregistry)

---

## Create a RetryRegistry

커스텀 RetryConfig를 통해 RetryRegistry를 만들어보자.

```java
RetryConfig config = RetryConfig.custom()
    .maxAttempts(2)
    .waitDuration(Duration.ofMillis(100))
    .retryOnResult(response -> response.getStatus() == 500)
    .retryOnException(e -> e instanceof WebServiceException)
    .retryExceptions(IOException.class, TimeoutException.class)
    .ignoreExceptions(BunsinessException.class, OtherBunsinessException.class)
    .build();
    
// Create a RetryRegistry with a custom global configuration
RetryRegistry registry = RetryRegistry.of(config);
```