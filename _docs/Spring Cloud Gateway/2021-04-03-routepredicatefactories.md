---
title: Route Predicate Factories
category: Spring Cloud Gateway
order: 6
permalink: /Spring%20Cloud%20Gateway/route-predicate-factories/
description: 스프링 클라우드 게이트웨이가 제공하는 여러 가지 route predicate 팩토리 소개 한글 번역
image: ./../../images/springcloud/logo.jpeg
lastmod: 2021-04-06T22:00:00+09:00
comments: true
originalRefName: 스프링 클라우드 게이트웨이
originalRefLink: https://docs.spring.io/spring-cloud-gateway/docs/3.0.2/reference/html/#gateway-request-predicates-factories
---

### 목차

- [5.1. The After Route Predicate Factory](#51-the-after-route-predicate-factory)
- [5.2. The Before Route Predicate Factory](#52-the-before-route-predicate-factory)
- [5.3. The Between Route Predicate Factory](#53-the-between-route-predicate-factory)
- [5.4. The Cookie Route Predicate Factory](#54-the-cookie-route-predicate-factory)
- [5.5. The Header Route Predicate Factory](#55-the-header-route-predicate-factory)
- [5.6. The Host Route Predicate Factory](#56-the-host-route-predicate-factory)
- [5.7. The Method Route Predicate Factory](#57-the-method-route-predicate-factory)
- [5.8. The Path Route Predicate Factory](#58-the-path-route-predicate-factory)
- [5.9. The Query Route Predicate Factory](#59-the-query-route-predicate-factory)
- [5.10. The RemoteAddr Route Predicate Factory](#510-the-remoteaddr-route-predicate-factory)
- [5.11. The Weight Route Predicate Factory](#511-the-weight-route-predicate-factory)
  + [5.11.1. Modifying the Way Remote Addresses Are Resolved](#5111-modifying-the-way-remote-addresses-are-resolved)

---

스프링 클라우드 게이트웨이는 스프링 웹플럭스의 `HandlerMapping`을 등록해 route를 매칭한다. 스프링 클라우드 게이트웨이는 다양한 route predicate 팩토리를 내장하고 있다. predicate들은 전부 각자의 HTTP 요청 속성을 매칭시킨다. 논리적인 `and` 표현을 사용해 여러 가지 route predicate 팩토리를 조합할 수도 있다.

---

## 5.1. The After Route Predicate Factory

`After` route predicate 팩토리는 `datetime`(자바 `ZonedDateTime`)이란 파라미터를 하나 사용한다. 이 predicate는 지정한 `datetime`보다 이후에 발생한 요청을 매칭시킨다. 다음은 after route predicate 설정 예시다:

**Example 1. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: after_route
        uri: https://example.org
        predicates:
        - After=2017-01-20T17:42:47.789-07:00[America/Denver]
```

이 route는 산악 표준시 (덴버) 2017년 1월 20일 17:42 이후에 발생한 모든 요청을 매칭한다.

---

## 5.2. The Before Route Predicate Factory

`Before` route predicate 팩토리는 `datetime`(자바 `ZonedDateTime`)이란 파라미터를 하나 사용한다. 이 predicate는 지정한 `datetime`보다 이전에 발생한 요청을 매칭시킨다. 다음은 before route predicate 설정 예시다:

**Example 2. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: before_route
        uri: https://example.org
        predicates:
        - Before=2017-01-20T17:42:47.789-07:00[America/Denver]
```

이 route는 산악 표준시 (덴버) 2017년 1월 20일 17:42 이전에 발생한 모든 요청을 매칭한다.

---

## 5.3. The Between Route Predicate Factory

`Between` route predicate 팩토리는 자바 `ZonedDateTime` 객체 `datetime1`, `datetime2` 두 파라미터를 사용한다. 이 predicate는 `datetime1` 이후, `datetime2` 이전에 발생한 요청을 매칭시킨다. `datetime1` 파라미터는 `datetime2`보다 앞선 시각이어야 한다. 다음은 between route predicate 설정 예시다:

**Example 3. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: between_route
        uri: https://example.org
        predicates:
        - Between=2017-01-20T17:42:47.789-07:00[America/Denver], 2017-01-21T17:42:47.789-07:00[America/Denver]
```

이 route는 산악 표준시 (덴버) 2017년 1월 20일 17:42 이후, 2017년 1월 21일 17:42 이전에 발생한 모든 요청을 매칭한다. 이 조건은 점검 기간 등에 활용할 수 있다.

---

## 5.4. The Cookie Route Predicate Factory

`Cookie` route predicate 팩토리는 두 가지 파라미터 쿠키 `name`과 `regexp`(자바 정규 표현식)를 사용한다. 이 predicate는 주어진 이름을 가진 쿠키 값이 정규식과 일치할 때 요청을 매칭시킨다. 다음은 쿠키 route predicate 팩토리 설정 예시다:

**Example 4. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: cookie_route
        uri: https://example.org
        predicates:
        - Cookie=chocolate, ch.p
```

이 route는 값이 정규 표현식 `ch.p`와 일치하는 `chocolate`이란 쿠키를 가진 요청을 매칭한다.

---

## 5.5. The Header Route Predicate Factory

`Header` route predicate 팩토리는 두 가지 파라미터 헤더 `name`과 `regexp`(자바 정규 표현식)를 사용한다. 이 predicate는 주어진 이름을 가진 헤더 값이 정규식과 일치할 때 요청을 매칭시킨다. 다음은 헤더 route predicate 설정 예시다:

**Example 5. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: header_route
        uri: https://example.org
        predicates:
        - Header=X-Request-Id, \d+
```

이 route는 `X-Request-Id`라는 헤더 값이 값이 정규 표현식 `\d+`와 일치하는 (즉, 숫자 값이 하나 이상 들어있는) 요청을 매칭한다.

---

## 5.6. The Host Route Predicate Factory

`Host` route predicate 팩토리는 호스트명 패턴 리스트를 가리키는 파라미터 `patterns`를 하나 사용한다. 패턴은 Ant-style 패턴으로 `,`을 구분자로 사용한다. 이 predicate는 패턴과 일치하는 `Host` 헤더를 매칭시킨다. 다음은 호스트 route predicate 설정 예시다:

**Example 6. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: host_route
        uri: https://example.org
        predicates:
        - Host=**.somehost.org,**.anotherhost.org
```

URI 템플릿 변수도 지원한다 (ex. `{sub}.myhost.org`).

이 route는 요청에 있는 `Host` 값이 `www.somehost.org`나 `beta.somehost.org`, `www.anotherhost.org`일 때 매칭한다.

이 predicate는 URI 템플릿 변수(예를 들어 위 예시에선 `sub`으로 정의한 변수)의 이름과 값을 맵으로 추출한 뒤, `ServerWebExchange.getAttributes()`에 `ServerWebExchangeUtils.URI_TEMPLATE_VARIABLES_ATTRIBUTE`에 정의된 키로 추가한다. 이렇게 하고나면 [`GatewayFilter` 팩토리](#gateway-route-filters)에서 변수 값을 사용할 수 있다.

---

## 5.7. The Method Route Predicate Factory

`Method` Route Predicate 팩토리는 하나 이상의 매칭할 HTTP 메소드를 파라미터로 사용한다. 다음은 메소드 route predicate 설정 예시다:

**Example 7. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: method_route
        uri: https://example.org
        predicates:
        - Method=GET,POST
```

이 route는 요청 메소드가 `GET`이나 `POST`일 때 매칭한다.

---

## 5.8. The Path Route Predicate Factory

`Path` Route Predicate 팩토리는 두 가지 파라미터, 스프링 `PathMatcher` 리스트 `patterns`와 `matchTrailingSlash`란 생략 가능한 플래그(기본값은 `true`)를 사용한다. 다음은 path route predicate 설정 예시다:

**Example 8. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: path_route
        uri: https://example.org
        predicates:
        - Path=/red/{segment},/blue/{segment}
```

이 route는 요청 path가 `/red/1`나 `/red/1/`, `/red/blue`, `/blue/green`일 때 매칭한다.

`matchTrailingSlash`를 `false`로 설정했을 땐 `/red/1/`은 매칭시키지 않는다.

이 predicate는 URI 템플릿 변수(예를 들어 위 예시에선 `segment`로 정의한 변수)의 이름과 값을 맵으로 추출한 뒤, `ServerWebExchange.getAttributes()`에 `ServerWebExchangeUtils.URI_TEMPLATE_VARIABLES_ATTRIBUTE`에 정의된 키로 추가한다. 이렇게 하고나면 [`GatewayFilter` 팩토리](#gateway-route-filters)에서 변수 값을 사용할 수 있다.

이런 변수에 더 쉽게 접근할 수 있는 유틸리티 메소드도 있다 (`get` 메소드). 다음은 `get` 메소드를 사용하는 방법을 보여주는 예시다:

```java
Map<String, String> uriVariables = ServerWebExchangeUtils.getPathPredicateVariables(exchange);

String segment = uriVariables.get("segment");
```

---

## 5.9. The Query Route Predicate Factory

`Query` route predicate 팩토리는 필수 파라미터 `param`과 생략 가능한 `regexp`(자바 정규 표현식)를 사용한다. 다음은 쿼리 route predicate 설정 예시다:

**Example 9. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: query_route
        uri: https://example.org
        predicates:
        - Query=green
```

이 route는 쿼리 파라미터 `green`을 가진 요청을 매칭한다.

**application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: query_route
        uri: https://example.org
        predicates:
        - Query=red, gree.
```

이 route는 쿼리 파라미터 `red`가 정규 표현식 `gree.`와 일치하는 요청을 매칭한다. 따라서 `green`과 `greet`가 매칭된다.

---

## 5.10. The RemoteAddr Route Predicate Factory

`RemoteAddr` route predicate 팩토리는 `192.168.0.1/16`과 같은 (여기서 `192.168.0.1`은 IP 주소고, `16`은 서브넷 마스크다) CIDR 표기(IPv4 또는 IPv6) 문자열 리스트 `sources`를 사용한다 (최소 사이즈 1). 다음은 RemoteAddr route predicate 설정 예시다:

**Example 10. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: remoteaddr_route
        uri: https://example.org
        predicates:
        - RemoteAddr=192.168.1.1/24
```

이 route는 예를 들어 요청의 remote address가 `192.168.1.10`일 때 매칭한다.

---

## 5.11. The Weight Route Predicate Factory

`Weight` route predicate 팩토리는 두 파라미터 `group`, `weight`(int)를 사용한다. weight는 그룹별로 계산된다. 다음은 weight route predicate 설정 예시다:

**Example 11. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: weight_high
        uri: https://weighthigh.org
        predicates:
        - Weight=group1, 8
      - id: weight_low
        uri: https://weightlow.org
        predicates:
        - Weight=group1, 2
```

이 route는 트래픽의 ~80%를 weighthigh.org로, 트래픽의 ~20%를 weightlow.org로 전달한다.

### 5.11.1. Modifying the Way Remote Addresses Are Resolved

RemoteAddr route predicate 팩토리는 기본적으로 들어온 요청의 remote address를 사용한다. 스프링 클라우드 게이트웨이가 프록시 레이어 뒤에 있다면 이 값이 실제 클라이언트 IP 주소와 일치하지 않을 수도 있다.

remote address를 리졸브하는 방식은 커스텀 `RemoteAddressResolver`를 설정해서 변경할 수 있다. 스프링 클라우드 게이트웨이는 디폴트는 아니지만, [X-Forwarded-For 헤더](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Forwarded-For) 기반 remote address 리졸버 `XForwardedRemoteAddressResolver`를 하나 제공한다.

`XForwardedRemoteAddressResolver`엔 보안에 다르게 접근하는 두 가지 스태틱 생성자 메소드가 있다:

- `XForwardedRemoteAddressResolver::trustAll`은 무조건 `X-Forwarded-For` 헤더에서 찾은 첫 번째 IP 주소를 사용하는 `RemoteAddressResolver`를 반환한다. 이때는 클라이언트가 악의적으로 `X-Forwarded-For`에 초기 값을 설정할 수 있어 스푸핑(spoofing)에 취약하다.
- `XForwardedRemoteAddressResolver::maxTrustedIndex`는 스프링 클라우드 게이트웨이 앞에서 실행되는 신뢰할 수 있는 인프라 수를 가지고 인덱스를 고른다. 예를 들어서 HAProxy를 통해서만 스프링 클라우드 게이트웨이에 접근할 수 있을 땐 1을 사용해야 한다. 스프링 클라우드 게이트웨이에 접근하기 전에 신뢰할 수 있는 인프라 홉이 두 개 필요하다면 2를 사용해야 한다.

아래 헤더를 생각해보자:

```properties
X-Forwarded-For: 0.0.0.1, 0.0.0.2, 0.0.0.3
```

이땐 아래 `maxTrustedIndex` 값에 따라 다음과 같은 remote address를 생성한다:

| `maxTrustedIndex`        | result                                                     |
| :----------------------- | :--------------------------------------------------------- |
| [`Integer.MIN_VALUE`,0]  | (invalid, 초기화 단계에서 `IllegalArgumentException` 발생) |
| 1                        | 0.0.0.3                                                    |
| 2                        | 0.0.0.2                                                    |
| 3                        | 0.0.0.1                                                    |
| [4, `Integer.MAX_VALUE`] | 0.0.0.1                                                    |

<span id="gateway-route-filters"></span>다음은 같은 설정을 자바로 구성하는 예시다:

**Example 12. GatewayConfig.java**

```java
RemoteAddressResolver resolver = XForwardedRemoteAddressResolver
    .maxTrustedIndex(1);

...

.route("direct-route",
    r -> r.remoteAddr("10.1.1.1", "10.10.1.1/24")
        .uri("https://downstream1")
.route("proxied-route",
    r -> r.remoteAddr(resolver, "10.10.1.1", "10.10.1.1/24")
        .uri("https://downstream2")
)
```