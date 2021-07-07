---
title: HTTP Tracing
category: Spring Boot
order: 49
permalink: /Spring%20Boot/http-tracing/
description: 액추에이터로 HTTP tracing 정보 추적하기
image: ./../../images/springboot/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 부트
originalRefLink: https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#actuator.tracing
parent: Spring Boot Actuator
parentUrl: /Spring%20Boot/spring-boot-actuator/
---

### 목차

- [8.8.1. Custom HTTP tracing](#881-custom-http-tracing)

---

## 8.8. HTTP Tracing

HTTP Tracing은 애플리케이션 설정에 `HttpTraceRepository` 타입 빈을 제공하면 활성화할 수 있다. 스프링 부트는 간편한 `InMemoryHttpTraceRepository`를 제공한다. 여기서는 request-response exchange에 대한 trace를 기본적으로 마지막 100개까지 저장한다. `InMemoryHttpTraceRepository`는 다른 Tracing 솔루션에 비하면 다소 제한적이며, 개발 환경에서만 사용하는 걸 권장한다. 프로덕션 환경에선 Zipkin이나 Spring Cloud Sleuth같이 프로덕션에 적합한 tracing이나 observability 솔루션을 사용하는 게 좋다. 아니면 요구사항에 맞는 `HttpTraceRepository`를 직접 만들어라.

`HttpTraceRepository`에 저장된 request-response exchange 정보는 `httptrace` 엔드포인트를 이용해 조회할 수 있다.

### 8.8.1. Custom HTTP tracing

각 trace에 추가하는 항목들을 커스텀하려면 설정 프로퍼티 `management.trace.http.include`를 사용해라. 다른 것들을 좀 더 커스텀하고 싶으면, 자체 `HttpExchangeTracer` 구현체를 등록하는 걸 고려해봐라.