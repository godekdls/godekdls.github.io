---
title: HttpHeadersFilters
category: Spring Cloud Gateway
order: 9
permalink: /Spring%20Cloud%20Gateway/httpheadersfilters/
description: 스프링 클라우드 게이트웨이가 제공하는 여러 가지 HttpHeadersFilter 소개 한국어 번역
image: ./../../images/springcloud/logo.jpeg
lastmod: 2021-04-06T22:00:00+09:00
comments: true
originalRefName: 스프링 클라우드 게이트웨이
originalRefLink: https://docs.spring.io/spring-cloud-gateway/docs/3.0.2/reference/html/#httpheadersfilters
---

### 목차

- [8.1. Forwarded Headers Filter](#81-forwarded-headers-filter)
- [8.2. RemoveHopByHop Headers Filter](#82-removehopbyhop-headers-filter)
- [8.3. XForwarded Headers Filter](#83-xforwarded-headers-filter)

---

HttpHeadersFilter 류는 `NettyRoutingFilter`에서와 같이 요청을 다운스트림에 전송하기 전에 적용된다.

---

## 8.1. Forwarded Headers Filter

`Forwarded` Headers 필터는 다운스트림 서비스로 보낼 `Forwarded` 헤더를 생성한다. 기존 `Forwarded` 헤더에 현재 요청의 `Host` 헤더와 스킴, 포트를 추가한다.

---

## 8.2. RemoveHopByHop Headers Filter

`RemoveHopByHop` Headers 필터는 forwarded 요청에서 헤더를 제거한다. 제거할 기본 헤더 목록은 [IETF](https://tools.ietf.org/html/draft-ietf-httpbis-p1-messaging-14#section-7.1.3)에서 따왔다.

기본으로 제거되는 헤더는 다음과 같다:

- Connection
- Keep-Alive
- Proxy-Authenticate
- Proxy-Authorization
- TE
- Trailer
- Transfer-Encoding
- Upgrade

변경하려면 `spring.cloud.gateway.filter.remove-hop-by-hop.headers` 프로퍼티에 제거할 헤더명의 리스트를 설정해라.

---

## 8.3. XForwarded Headers Filter

`XForwarded` Headers 필터는 다운스트림 서비스로 보낼 다양한 `X-Forwarded-*` 헤더를 생성한다. 현재 요청의 `Host` 헤더, 스킴, 포트, path를 사용해서 다양한 헤더를 만든다.

각 헤더 생성은 다음 boolean 프로퍼티로 제어할 수 있다 (디폴트는 true다):

- `spring.cloud.gateway.x-forwarded.for-enabled`
- `spring.cloud.gateway.x-forwarded.host-enabled`
- `spring.cloud.gateway.x-forwarded.port-enabled`
- `spring.cloud.gateway.x-forwarded.proto-enabled`
- `spring.cloud.gateway.x-forwarded.prefix-enabled`

각 헤더에 값을 여러 개 추가하려면 다음 boolean 프로퍼티로 제어하면 된다 (디폴트는 true다):

- `spring.cloud.gateway.x-forwarded.for-append`
- `spring.cloud.gateway.x-forwarded.host-append`
- `spring.cloud.gateway.x-forwarded.port-append`
- `spring.cloud.gateway.x-forwarded.proto-append`
- `spring.cloud.gateway.x-forwarded.prefix-append`