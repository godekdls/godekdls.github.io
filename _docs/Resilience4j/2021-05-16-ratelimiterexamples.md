---
title: RateLimiter Examples
navTitle: ㄴ Examples
category: Resilience4j
order: 11
permalink: /Resilience4j/latelimiter-examples/
description: RateLimiter 사용 예시 한국어 번역
image: ./../../images/resilience4j/logo.png
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: resilience4j
originalRefLink: https://resilience4j.readme.io/v1.7.0/docs/examples-4
---

### 목차

- [Create a RateLimiterRegistry](#create-a-ratelimiterregistry)
- [Override the RegistryStore](#override-the-registrystore)

---

## Create a RateLimiterRegistry

커스텀 RateLimiterConfig를 통해 RateLimiterRegistry를 만들어보자.

```java
// Create a custom configuration for a RateLimiter
RateLimiterConfig config = RateLimiterConfig.custom()
  .timeoutDuration(TIMEOUT)
  .limitRefreshPeriod(REFRESH_PERIOD)
  .limitForPeriod(LIMIT)
  .build();

// Create a RateLimiterRegistry with a custom global configuration
RateLimiterRegistry registry = RateLimiterRegistry.of(config);
```

---

## Override the RegistryStore

커스텀 구현체로 인메모리 RegistryStore를 재정의할 수 있다. 예를 들어 일정 시간이 지나면 사용하지 않는 인스턴스를 제거하는 캐시를 사용하고 싶다면:

```java
RateLimiterRegistry rateLimiterRegistry = RateLimiterRegistry.custom()
  .withRegistryStore(new CacheRateLimiterRegistryStore())
  .build();
```