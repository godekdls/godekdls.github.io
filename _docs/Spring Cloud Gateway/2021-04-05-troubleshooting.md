---
title: Troubleshooting
category: Spring Cloud Gateway
order: 17
permalink: /Spring%20Cloud%20Gateway/troubleshooting/
description: 스프링 클라우드 게이트웨이를 사용하다 트러블슈팅이 필요한 경우 도움이 될 만한 정보들 한국어 번역
image: ./../../images/springcloud/logo.jpeg
lastmod: 2021-04-06T22:00:00+09:00
comments: true
originalRefName: 스프링 클라우드 게이트웨이
originalRefLink: https://docs.spring.io/spring-cloud-gateway/docs/3.0.2/reference/html/#troubleshooting
---

### 목차

- [16.1. Log Levels](#161-log-levels)
- [16.2. Wiretap](#162-wiretap)

---

이번 섹션에선 스프링 클라우드 게이트웨이를 사용할 때 흔히 발생할 수 있는 문제들을 다룬다.

---

## 16.1. Log Levels

다음 로거에서 `DEBUG`와 `TRACE` 레벨로 남긴 로그 중에 트러블슈팅에 도움이 될만한 정보가 있을 수도 있다:

- `org.springframework.cloud.gateway`
- `org.springframework.http.server.reactive`
- `org.springframework.web.reactive`
- `org.springframework.boot.autoconfigure.web`
- `reactor.netty`
- `redisratelimiter`

---

## 16.2. Wiretap

리액터 네티 `HttpClient`와 `HttpServer`는 wiretap을 활성화할 수 있다. 활성화하고서 `reactor.netty` 로그 레벨을 `DEBUG`나 `TRACE`로 설정하면, 네트워크로 송수신한 헤더와 body같은 정보를 로깅한다. wiretap을 활성화하려면 `HttpServer`, `HttpClient`에 각각 `spring.cloud.gateway.httpserver.wiretap=true`, `spring.cloud.gateway.httpclient.wiretap=true`를 설정해라.