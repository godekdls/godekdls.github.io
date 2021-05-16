---
title: GatewayFilter Factories
category: Spring Cloud Gateway
order: 7
permalink: /Spring%20Cloud%20Gateway/gatewayfilter-factories/
description: 스프링 클라우드 게이트웨이가 제공하는 여러 가지 GatewayFilter 팩토리 소개 한글 번역
image: ./../../images/springcloud/logo.jpeg
lastmod: 2021-04-06T22:00:00+09:00
comments: true
originalRefName: 스프링 클라우드 게이트웨이
originalRefLink: https://docs.spring.io/spring-cloud-gateway/docs/3.0.2/reference/html/#gatewayfilter-factories
---

### 목차

- [6.1. The AddRequestHeader GatewayFilter Factory](#61-the-addrequestheader-gatewayfilter-factory)
- [6.2. The AddRequestParameter GatewayFilter Factory](#62-the-addrequestparameter-gatewayfilter-factory)
- [6.3. The AddResponseHeader GatewayFilter Factory](#63-the-addresponseheader-gatewayfilter-factory)
- [6.4. The DedupeResponseHeader GatewayFilter Factory](#64-the-deduperesponseheader-gatewayfilter-factory)
- [6.5. Spring Cloud CircuitBreaker GatewayFilter Factory](#65-spring-cloud-circuitbreaker-gatewayfilter-factory)
  + [6.5.1. Tripping The Circuit Breaker On Status Codes](#651-tripping-the-circuit-breaker-on-status-codes)
- [6.6. The FallbackHeaders GatewayFilter Factory](#66-the-fallbackheaders-gatewayfilter-factory)
- [6.7. The MapRequestHeader GatewayFilter Factory](#67-the-maprequestheader-gatewayfilter-factory)
- [6.8. The PrefixPath GatewayFilter Factory](#68-the-prefixpath-gatewayfilter-factory)
- [6.9. The PreserveHostHeader GatewayFilter Factory](#69-the-preservehostheader-gatewayfilter-factory)
- [6.10. The RequestRateLimiter GatewayFilter Factory](#610-the-requestratelimiter-gatewayfilter-factory)
  + [6.10.1. The Redis RateLimiter](#6101-the-redis-ratelimiter)
- [6.11. The RedirectTo GatewayFilter Factory](#611-the-redirectto-gatewayfilter-factory)
- [6.12. The RemoveRequestHeader GatewayFilter Factory](#612-the-removerequestheader-gatewayfilter-factory)
- [6.13. RemoveResponseHeader GatewayFilter Factory](#613-removeresponseheader-gatewayfilter-factory)
- [6.14. The RemoveRequestParameter GatewayFilter Factory](#614-the-removerequestparameter-gatewayfilter-factory)
- [6.15. The RewritePath GatewayFilter Factory](#615-the-rewritepath-gatewayfilter-factory)
- [6.16. RewriteLocationResponseHeader GatewayFilter Factory](#616-rewritelocationresponseheader-gatewayfilter-factory)
- [6.17. The RewriteResponseHeader GatewayFilter Factory](#617-the-rewriteresponseheader-gatewayfilter-factory)
- [6.18. The SaveSession GatewayFilter Factory](#618-the-savesession-gatewayfilter-factory)
- [6.19. The SecureHeaders GatewayFilter Factory](#619-the-secureheaders-gatewayfilter-factory)
- [6.20. The SetPath GatewayFilter Factory](#620-the-setpath-gatewayfilter-factory)
- [6.21. The SetRequestHeader GatewayFilter Factory](#621-the-setrequestheader-gatewayfilter-factory)
- [6.22. The SetResponseHeader GatewayFilter Factory](#622-the-setresponseheader-gatewayfilter-factory)
- [6.23. The SetStatus GatewayFilter Factory](#623-the-setstatus-gatewayfilter-factory)
- [6.24. The StripPrefix GatewayFilter Factory](#624-the-stripprefix-gatewayfilter-factory)
- [6.25. The Retry GatewayFilter Factory](#625-the-retry-gatewayfilter-factory)
- [6.26. The RequestSize GatewayFilter Factory](#626-the-requestsize-gatewayfilter-factory)
- [6.27. The SetRequestHostHeader GatewayFilter Factory](#627-the-setrequesthostheader-gatewayfilter-factory)
- [6.28. Modify a Request Body GatewayFilter Factory](#628-modify-a-request-body-gatewayfilter-factory)
- [6.29. Modify a Response Body GatewayFilter Factory](#629-modify-a-response-body-gatewayfilter-factory)
- [6.30. Token Relay GatewayFilter Factory](#630-token-relay-gatewayfilter-factory)
- [6.31. Default Filters](#631-default-filters)

---

Route 필터를 사용하면 전달받은 HTTP 요청이나 전송할 HTTP 응답을 원하는 대로 수정할 수 있다. Route 필터는 route 단위로 지정한다. 스프링 클라우드 게이트웨이는 다양한 내장 GatewayFilter 팩토리를 제공한다.

> 아래 있는 필터들을 사용하는 방법은 [유닛 테스트](https://github.com/spring-cloud/spring-cloud-gateway/tree/master/spring-cloud-gateway-server/src/test/java/org/springframework/cloud/gateway/filter/factory)에서 자세한 예시를 확인할 수 있다.

---

## 6.1. The `AddRequestHeader` `GatewayFilter` Factory

`AddRequestHeader` `GatewayFilter` 팩토리는 `name`, `value` 파라미터를 사용한다. 다음은 `AddRequestHeader` `GatewayFilter` 설정 예시다:

**Example 13. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: add_request_header_route
        uri: https://example.org
        filters:
        - AddRequestHeader=X-Request-red, blue
```

이 예시에선 매칭된 모든 요청을 다운스트림으로 보내기 전에 `X-Request-red:blue` 헤더를 추가한다.

`AddRequestHeader`는 path나 호스트를 매칭할 때 사용한 URI 변수를 인식할 수 있다. URI 변수는 value에서 활용할 수 있으며, 런타임에 치환된다. 다음은 변수를 하나 사용하는 `AddRequestHeader` `GatewayFilter` 설정 예시다:

**Example 14. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: add_request_header_route
        uri: https://example.org
        predicates:
        - Path=/red/{segment}
        filters:
        - AddRequestHeader=X-Request-Red, Blue-{segment}
```

---

## 6.2. The `AddRequestParameter` `GatewayFilter` Factory

`AddRequestParameter` `GatewayFilter` 팩토리는 `name`, `value` 파라미터를 사용한다. 다음은 `AddRequestParameter` `GatewayFilter` 설정 예시다:

**Example 15. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: add_request_parameter_route
        uri: https://example.org
        filters:
        - AddRequestParameter=red, blue
```

이 예시에선 매칭된 모든 요청을 다운스트림으로 보내기 전에 쿼리 스트링에 `red=blue`를 추가한다.

`AddRequestParameter`는 path나 호스트를 매칭할 때 사용한 URI 변수를 인식할 수 있다. URI 변수는 value에서 활용할 수 있으며, 런타임에 치환된다. 다음은 변수를 하나 사용하는 `AddRequestParameter` `GatewayFilter` 설정 예시다:

**Example 16. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: add_request_parameter_route
        uri: https://example.org
        predicates:
        - Host: {segment}.myhost.org
        filters:
        - AddRequestParameter=foo, bar-{segment}
```

---

## 6.3. The `AddResponseHeader` `GatewayFilter` Factory

`AddResponseHeader` `GatewayFilter` 팩토리는 `name`, `value` 파라미터를 사용한다. 다음은 `AddResponseHeader` `GatewayFilter` 설정 예시다:

**Example 17. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: add_response_header_route
        uri: https://example.org
        filters:
        - AddResponseHeader=X-Response-Red, Blue
```

이 예시에선 매칭된 모든 요청에서 다운스트림 응답 헤더에 `X-Response-red:blue`를 추가한다.

`AddResponseHeader`는 path나 호스트를 매칭할 때 사용한 URI 변수를 인식할 수 있다. URI 변수는 value에서 활용할 수 있으며, 런타임에 치환된다. 다음은 변수를 하나 사용하는 `AddResponseHeader` `GatewayFilter` 설정 예시다:

**Example 18. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: add_response_header_route
        uri: https://example.org
        predicates:
        - Host: {segment}.myhost.org
        filters:
        - AddResponseHeader=foo, bar-{segment}
```

---

## 6.4. The `DedupeResponseHeader` `GatewayFilter` Factory

`DedupeResponseHeader` `GatewayFilter` 팩토리는 `name` 파라미터와 옵션 파라미터 `strategy`를 사용한다. `name`에는 헤더 이름 리스트를 공백으로 구분해서 담을 수 있다. 다음은 `DedupeResponseHeader` `GatewayFilter` 설정 예시다:

**Example 19. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: dedupe_response_header_route
        uri: https://example.org
        filters:
        - DedupeResponseHeader=Access-Control-Allow-Credentials Access-Control-Allow-Origin
```

이렇게 설정한 뒤 게이트웨이 CORS 로직과 다운스트림 로직에서 모두 응답 헤더 `Access-Control-Allow-Credentials`, `Access-Control-Allow-Origin`을 추가한다면, 헤더에 중복된 값을 제거해준다.

`DedupeResponseHeader` 필터는 생략 가능한 파라미터 `strategy`도 허용한다. 허용되는 값은 `RETAIN_FIRST`(기본값), `RETAIN_LAST`, `RETAIN_UNIQUE`다.

---

## 6.5. Spring Cloud CircuitBreaker GatewayFilter Factory

스프링 클라우드 `CircuitBreaker` `GatewayFilter` 팩토리는 스프링 클라우드 CircuitBreaker API를 사용해서 게이트웨이 route를 서킷 브레이커로 감싼다. 스프링 클라우드 CircuitBreaker는 스프링 클라우드 게이트웨이와 함께 사용할 수 있는 다양한 라이브러리를 지원한다. 스프링 클라우드에선 Resilience4J를 바로 사용할 수 있다.

스프링 클라우드 `CircuitBreaker` 필터를 활성화하려면 클래스패스에 `spring-cloud-starter-circuitbreaker-reactor-resilience4j`를 추가해야 한다. 다음은 스프링 클라우드 `CircuitBreaker` `GatewayFilter` 설정 예시다:

**Example 20. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: circuitbreaker_route
        uri: https://example.org
        filters:
        - CircuitBreaker=myCircuitBreaker
```

서킷 브레이커를 설정하려면 사용하고 있는 서킷 브레이커 구현체 설정을 참고해라.

- [Resilience4J 문서](https://cloud.spring.io/spring-cloud-circuitbreaker/reference/html/spring-cloud-circuitbreaker.html)

스프링 클라우드 CircuitBreaker 필터에는 생략 가능한 파라미터 `fallbackUri`도 넘길 수 있다. 현재는 `forward:` 스킴 URI만 지원한다. 폴백이 호출되면 URI와 매칭되는 컨트롤러로 요청을 포워딩한다. 다음은 이 같은 폴백을 설정하는 예시다:

**Example 21. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: circuitbreaker_route
        uri: lb://backing-service:8088
        predicates:
        - Path=/consumingServiceEndpoint
        filters:
        - name: CircuitBreaker
          args:
            name: myCircuitBreaker
            fallbackUri: forward:/inCaseOfFailureUseThis
        - RewritePath=/consumingServiceEndpoint, /backingServiceEndpoint
```

다음은 같은 설정을 자바로 구성하는 예시다:

**Example 22. Application.java**

```java
@Bean
public RouteLocator routes(RouteLocatorBuilder builder) {
    return builder.routes().route(
            "circuitbreaker_route",
            r -> r.path("/consumingServiceEndpoint")
                    .filters(f -> f.circuitBreaker(c -> c.name("myCircuitBreaker")
                            .fallbackUri("forward:/inCaseOfFailureUseThis"))
                            .rewritePath("/consumingServiceEndpoint", "/backingServiceEndpoint"))
                    .uri("lb://backing-service:8088").build()
    );
}
```

이 예시에선 서킷 브레이커 폴백이 호출되면 `/inCaseofFailureUseThis` URI로 포워딩시킨다. 여기선 (선택 사항) 스프링 클라우드 LoadBalancer 로드 밸런싱도 시연하고 있다 (목적지 URI에 `lb` 프리픽스로 정의).

일차적인 시나리오는 `fallbackUri`를 사용해 게이트웨이 어플리케이션 내에 있는 내부 컨트롤러나 핸들러를 정의하는 거다. 하지만 다음과 같이 외부 어플리케이션에 있는 컨트롤러나 핸들러로 요청을 다시 라우팅할 수도 있다:

**Example 23. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: ingredients
        uri: lb://ingredients
        predicates:
        - Path=//ingredients/**
        filters:
        - name: CircuitBreaker
          args:
            name: fetchIngredients
            fallbackUri: forward:/fallback
      - id: ingredients-fallback
        uri: http://localhost:9994
        predicates:
        - Path=/fallback
```

이 예시에선 게이트웨이 어플리케이션엔 폴백 엔드포인트나 핸들러가 없다. 하지만 `localhost:9994`에 등록된 다른 어플리케이션이 하나 존재한다.

스프링 클라우드 CircuitBreaker GatewayFilter는 요청이 폴백으로 전달될 땐 폴백을 유발한 `Throwable`도 제공한다. 게이트웨이 어플리케이션 내에서 폴백을 처리할 때 사용할 수 있는 `ServerWebExchange`에 `ServerWebExchangeUtils.CIRCUITBREAKER_EXECUTION_EXCEPTION_ATTR` 속성으로 추가된다.

외부 컨트롤러/핸들러에 다시 라우팅할 때는 예외 관련 세부 정보를 가진 헤더를 추가할 수 있다. 자세한 내용은 [FallbackHeaders GatewayFilter Factory 섹션](#66-the-fallbackheaders-gatewayfilter-factory)에서 확인할 수 있다.

### 6.5.1. Tripping The Circuit Breaker On Status Codes

어떤 상황에선 래핑하는 route에서 반환한 상태 코드를 기반으로 서킷 브레이커를 작동시키고 싶을 수도 있다. 서킷 브레이커 설정 객체는 서킷 브레이커를 작동시킬 상태 코드 리스트를 가져온다. 서킷 브레이커를 작동시킬 상태 코드를 설정할 땐 상태 코드의 정수 값을 사용해도 되고, `HttpStatus` enum을 문자열로 나타내도 된다.

**Example 24. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: circuitbreaker_route
        uri: lb://backing-service:8088
        predicates:
        - Path=/consumingServiceEndpoint
        filters:
        - name: CircuitBreaker
          args:
            name: myCircuitBreaker
            fallbackUri: forward:/inCaseOfFailureUseThis
            statusCodes:
              - 500
              - "NOT_FOUND"
```

**Example 25. Application.java**

```java
@Bean
public RouteLocator routes(RouteLocatorBuilder builder) {
    return builder.routes()
        .route("circuitbreaker_route", r -> r.path("/consumingServiceEndpoint")
            .filters(f -> f.circuitBreaker(c -> c.name("myCircuitBreaker").fallbackUri("forward:/inCaseOfFailureUseThis").addStatusCode("INTERNAL_SERVER_ERROR"))
                .rewritePath("/consumingServiceEndpoint", "/backingServiceEndpoint")).uri("lb://backing-service:8088")
        .build();
}
```

---

## 6.6. The `FallbackHeaders` `GatewayFilter` Factory

`FallbackHeaders` 팩토리를 사용하면 다음 시나리오에서와 같이 외부 어플리케이션의 `fallbackUri`로 전달하는 요청에 스프링 클라우드 CircuitBreaker execution 예외와 관련한 세부 정보를 헤더로 추가할 수 있다:

**Example 26. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: ingredients
        uri: lb://ingredients
        predicates:
        - Path=//ingredients/**
        filters:
        - name: CircuitBreaker
          args:
            name: fetchIngredients
            fallbackUri: forward:/fallback
      - id: ingredients-fallback
        uri: http://localhost:9994
        predicates:
        - Path=/fallback
        filters:
        - name: FallbackHeaders
          args:
            executionExceptionTypeHeaderName: Test-Header
```

이 예시에선 서킷 브레이커를 실행하는 동안 execution 예외가 발생하면, `localhost:9994`에서 실행 중인 어플리케이션의 `fallback` 엔드포인트나 핸들러로 요청을 포워딩시킨다. `FallbackHeaders` 필터가 예외 타입, 메세지 정보와, (있다면) root cause 예외 타입과 메세지 정보를 가진 헤더를 추가해준다.

설정 헤더들의 이름은 다음 인자 값을 설정하면 재정의할 수 있다 (기본값과 함께 표기했다):

- `executionExceptionTypeHeaderName` (`"Execution-Exception-Type"`)
- `executionExceptionMessageHeaderName` (`"Execution-Exception-Message"`)
- `rootCauseExceptionTypeHeaderName` (`"Root-Cause-Exception-Type"`)
- `rootCauseExceptionMessageHeaderName` (`"Root-Cause-Exception-Message"`)

서킷 브레이커와 게이트웨이에 대한 자세한 내용은 [스프링 클라우드 CircuitBreaker 팩토리 섹션](#65-spring-cloud-circuitbreaker-gatewayfilter-factory)을 참고해라.

---

## 6.7. The `MapRequestHeader` `GatewayFilter` Factory

`MapRequestHeader` `GatewayFilter` 팩토리는 `fromHeader`, `toHeader` 파라미터를 사용한다. 헤더(`toHeader`)를 하나 새로 생성하며, 값은 전달받은 http 요청에 있는 기존 헤더(`fromHeader`)에서 추출한다. 이 필터는 입력 헤더가 없을 땐 아무 영향도 없다. 새로 만들 헤더가 이미 있는 경우엔 기존 값에 새 값을 추가로 더 넣는다. 다음은 `MapRequestHeader` 설정 예시다:

**Example 27. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: map_request_header_route
        uri: https://example.org
        filters:
        - MapRequestHeader=Blue, X-Request-Red
```

여기선 다운스트림 요청에 전달받은 HTTP 요청의 `Blue` 헤더 값을 추가한 `X-Request-Red:<values>` 헤더를 넣어준다.

---

## 6.8. The `PrefixPath` `GatewayFilter` Factory

`PrefixPath` `GatewayFilter` 팩토리는 단일 파라미터 `prefix`를 사용한다. 다음은 `PrefixPath` `GatewayFilter` 설정 예시다:

**Example 28. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: prefixpath_route
        uri: https://example.org
        filters:
        - PrefixPath=/mypath
```

이 예시에선 매칭된 모든 요청 path에 `/mypath` 프리픽스를 추가할 거다. 따라서 `/hello`에 대한 요청은 `/mypath/hello`로 전송된다.

---

## 6.9. The `PreserveHostHeader` `GatewayFilter` Factory

`PreserveHostHeader` `GatewayFilter` 팩토리엔 파라미터가 없다. 이 필터는 HTTP 클라이언트가 결정하는 호스트 헤더가 아닌, 원래 요청에 있던 호스트 헤더를 전송하도록 만드는 요청 속성을 설정한다. 이 요청 속성은 나중에 라우팅 필터에서 조회해간다. 다음은 `PreserveHostHeader` `GatewayFilter` 설정 예시다:

**Example 29. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: preserve_host_route
        uri: https://example.org
        filters:
        - PreserveHostHeader
```

---

## 6.10. The `RequestRateLimiter` `GatewayFilter` Factory

`RequestRateLimiter` `GatewayFilter` 팩토리는 `RateLimiter` 구현체를 사용해서 현재 요청을 이어서 진행할지를 결정한다. 요청을 허용하지 않을 땐 `HTTP 429 - Too Many Requests`(디폴트) 상태를 반환한다.

이 필터는 선택 파라미터 `keyResolver`와 rate limiter 전용 파라미터들을 사용한다 (뒤에서 설명한다).

`keyResolver`는 `KeyResolver` 인터페이스를 구현하는 빈이다. 설정에선 SpEL을 사용해 빈 이름을 참조해라. `#{@myKeyResolver}`는 `myKeyResolver`라는 빈을 참조하는 SpEL 표현식이다. 다음은 `KeyResolver` 인터페이스다:

**Example 30. KeyResolver.java**

```java
public interface KeyResolver {
    Mono<String> resolve(ServerWebExchange exchange);
}
```

`KeyResolver` 인터페이스를 사용하면 요청을 제한하기 위한 키를 원하는 전략으로 가져올 수 있다. 향후 마일스톤 릴리즈에선 몇 가지 `KeyResolver` 구현체를 추가할 예정이다.

`KeyResolver`의 기본 구현체는 `PrincipalNameKeyResolver`로, `ServerWebExchange`에서 `Principal`을 조회해 `Principal.getName()`을 호출한다.

기본적으로는 `KeyResolver`에서 키를 찾지 못하면 요청을 거부한다. 이 동작은 `spring.cloud.gateway.filter.request-rate-limiter.deny-empty-key`(`true`/`false`)와 `spring.cloud.gateway.filter.request-rate-limiter.empty-key-status-code` 프로퍼티를 설정해서 조절할 수 있다.

> `RequestRateLimiter`는 "shorcut" 표기법으로는 설정할 수 없다. 아래는 *유효하지 않은* 예시다:
>
> **Example 31. application.properties**
>
> ````properties
> # INVALID SHORTCUT CONFIGURATION
> spring.cloud.gateway.routes[0].filters[0]=RequestRateLimiter=2, 2, #{@userkeyresolver}
> ````

### 6.10.1. The Redis `RateLimiter`

Redis 구현체는 [Stripe](https://stripe.com/blog/rate-limiters)에서 구현한 로직을 기반으로 만들었다. 이 구현체는 스프링 부트 스타터 `spring-boot-starter-data-redis-reactive`가 필요하다.

사용하는 알고리즘은 [토큰 버킷 알고리즘](https://en.wikipedia.org/wiki/Token_bucket)이다.

`redis-rate-limiter.replenishRate` 프로퍼티는 요청을 드랍하지 않고 사용자마다 허용할 초당 요청 수다. 토큰 버킷을 채우는 속도라고 할 수 있다.

`redis-rate-limiter.burstCapacity` 프로퍼티는 사용자마다 1초 동안 허용할 최대 요청 수를 가리킨다. 토큰 버킷이 보유할 수 있는 토큰 수라고 할 수 있다. 이 값을 0으로 설정하면 모든 요청을 차단한다.

`redis-rate-limiter.requestedTokens` 프로퍼티는 요청에 드는 토큰 수다. 각 요청마다 버킷에서 가져오는 토큰 수로, 기본값은 `1`이다.

`replenishRate`와 `burstCapacity`에 동일한 값을 설정하면 일정한 비율로만 요청을 허용할 수 있다. `burstCapacity`를 `replenishRate` 보다 높게 설정하면 일시적으로 급증하는 요청(temporary bursts)을 허용할 수 있다. 이 땐 버스트가 두 번 연속되면 요청을 드랍하게 되므로 (`HTTP 429 - Too Many Requests`), 최초 버스트 발생 후 일정 시간이 지나야 요청을 허용할 수 있다 (`replenishRate`에 따라). 다음은 `redis-rate-limiter` 설정 예시다:

아래는 `replenishRate`을 원하는 요청 수로, `requestedTokens`를 시간 범위로(초) 설정하고, `replenishRate`와 `requestedTokens`에 따라 `burstCapacity`를 산출해 `1 request/s`로 속도를 제한한다. 예를 들어 `replenishRate=1`, `requestedTokens=60`, `burstCapacity=60`을 설정하면 `1 request/min`으로 제한된다.

**Example 32. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: requestratelimiter_route
        uri: https://example.org
        filters:
        - name: RequestRateLimiter
          args:
            redis-rate-limiter.replenishRate: 10
            redis-rate-limiter.burstCapacity: 20
            redis-rate-limiter.requestedTokens: 1
```

다음은 자바를 사용한 KeyResolver 설정 예시다:

**Example 33. Config.java**

```java
@Bean
KeyResolver userKeyResolver() {
    return exchange -> Mono.just(exchange.getRequest().getQueryParams().getFirst("user"));
}
```

여기선 사용자 당 요청 속도 제한을 10으로 정의하고 있다. 버스트는 20만큼 허용하지만, 그 다음 1초 동안은 10 개의 요청만 허용한다. 여기서 보여준 `KeyResolver`는 요청 파라미터 `user`를 가져오는 간단한 구현체다 (프로덕션에 권장하는 설정은 아니다).

rate limiter는 `RateLimiter` 인터페이스를 구현하는 빈으로도 정의할 수 있다. 설정에선 SpEL을 사용해 빈 이름을 참조하면 된다. `#{@myRateLimiter}`는 `myRateLimiter`라는 빈을 참조하는 SpEL 표현식이다. 다음은 앞에서 정의한 `KeyResolver`를 사용하는 rate limiter를 정의하고 있다:

**Example 34. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: requestratelimiter_route
        uri: https://example.org
        filters:
        - name: RequestRateLimiter
          args:
            rate-limiter: "#{@myRateLimiter}"
            key-resolver: "#{@userKeyResolver}"
```

---

## 6.11. The `RedirectTo` `GatewayFilter` Factory

`RedirectTo` GatewayFilter 팩토리는 두 파라미터 `status`와 `url`을 사용한다. `status` 파라미터는 301같은 300 번대 리다이렉션 시리즈 HTTP 코드여야 한다. `url` 파라미터는 유효한 URL이어야 하며, `Location` 헤더을 나타낸다. 상대경로로 리다이렉션할 땐 route 정의에 있는 uri는 `uri: no://op`를 사용해야 한다. 다음은 `RedirectTo` `GatewayFilter`설정 예시다:

**Example 35. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: prefixpath_route
        uri: https://example.org
        filters:
        - RedirectTo=302, https://acme.org
```

이렇게 하면 리다이렉션을 수행할 수 있도록 `Location:https://acme.org` 헤더와 함께 302 상태를 전송한다.

---

## 6.12. The `RemoveRequestHeader` GatewayFilter Factory

`RemoveRequestHeader` `GatewayFilter` 팩토리는 `name` 파라미터를 사용한다. 이 파라미터는 제거할 헤더의 이름이다. 다음은 `RemoveRequestHeader` `GatewayFilter` 설정 예시다:

**Example 36. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: removerequestheader_route
        uri: https://example.org
        filters:
        - RemoveRequestHeader=X-Request-Foo
```

이렇게 하면 다운스트림으로 전송하기 전에 `X-Request-Foo` 헤더를 제거한다.

---

## 6.13. `RemoveResponseHeader` `GatewayFilter` Factory

`RemoveResponseHeader` `GatewayFilter` 팩토리는 `name` 파라미터를 사용한다. 이 파라미터는 제거할 헤더의 이름이다. 다음은 `RemoveResponseHeader` `GatewayFilter` 설정 예시다:

**Example 37. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: removeresponseheader_route
        uri: https://example.org
        filters:
        - RemoveResponseHeader=X-Response-Foo
```

이렇게 하면 응답을 게이트웨이 클라이언트로 반환하기 전에 `X-Response-Foo` 헤더를 제거한다.

이 필터로 민감한 헤더를 모두 제거하려면 필요한 route 마다 필터를 설정해야 한다. 아니면 `spring.cloud.gateway.default-filters`를 사용하면 필터는 한 번만 설정해도 모든 route에 적용된다.

---

## 6.14. The `RemoveRequestParameter` `GatewayFilter` Factory

`RemoveRequestParameter` `GatewayFilter` 팩토리는 `name` 파라미터를 사용한다. 이 파라미터는 제거할 쿼리 파라미터의 이름이다. 다음은 `RemoveRequestParameter` `GatewayFilter` 설정 예시다:

**Example 38. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: removerequestparameter_route
        uri: https://example.org
        filters:
        - RemoveRequestParameter=red
```

이렇게 하면 다운스트림으로 전송하기 전에 `red` 파라미터를 제거한다.

---

## 6.15. The `RewritePath` `GatewayFilter` Factory

`RewritePath` `GatewayFilter` 팩토리는 path를 가리키는 `regexp` 파라미터와, `replacement` 파라미터를 사용한다. 여기선 요청 path를 유연하게 재작성할 수 있도록 자바 정규 표현식을 사용한다. 다음은 `RewritePath` `GatewayFilter` 설정 예시다:

**Example 39. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: rewritepath_route
        uri: https://example.org
        predicates:
        - Path=/red/**
        filters:
        - RewritePath=/red/?(?<segment>.*), /$\{segment}
```

이 예시에선 `/red/blue` 요청을 받으면 다운스트림 요청을 만들기 전에 path를 `/blue`로 설정한다. 단, YAML 스펙에 따라 `$`는 `$\`로 치환해야 한다.

---

## 6.16. `RewriteLocationResponseHeader` `GatewayFilter` Factory

`RewriteLocationResponseHeader` `GatewayFilter` 팩토리는 `Location` 응답 헤더 값을 수정한다. 일반적으로 백엔드와 관련해서 필요한 세부 정보를 제거할 때 사용한다. 사용하는 파라미터는 `stripVersionMode`, `locationHeaderName`, `hostValue`, `protocolsRegex`다. 다음은 `RewriteLocationResponseHeader` `GatewayFilter` 설정 예시다:

**Example 40. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: rewritelocationresponseheader_route
        uri: http://example.org
        filters:
        - RewriteLocationResponseHeader=AS_IN_REQUEST, Location, ,
```

예를 들어 `POST api.example.com/some/object/name` 요청에선, `Location` 응답 헤더 값 `object-service.prod.example.net/v2/some/object/id`는 `api.example.com/some/object/id`로 재작성된다.

`stripVersionMode` 파라미터에 사용할 수 있는 값은 `NEVER_STRIP`, `AS_IN_REQUEST`(디폴트), `ALWAYS_STRIP`이다.

- `NEVER_STRIP`: 원래 요청 path에 버전이 없더라도 버전을 제거하지 않는다.
- `AS_IN_REQUEST`: 원래 요청 path에 버전이 없을 때에만 버전을 제거한다.
- `ALWAYS_STRIP`: 원래 요청 path에 버전이 있더라도 무조건 버전을 제거한다.

응답 헤더 `Location`의 `host:port` 부분을 치환할 땐 `hostValue` 파라미터를 사용한다 (제공했다면). 파라미터를 제공하지 않았다면 요청 헤더에 있는 `Host` 값을 사용한다.

`protocolsRegex` 파라미터는 프로토콜 명을 매칭할 유효한 정규식 `String`이어야 한다. 매칭되지 않으면 필터에선 아무 작업도 수행하지 않는다. 기본값은 `http|https|ftp|ftps`다.

---

## 6.17. The `RewriteResponseHeader` `GatewayFilter` Factory

`RewriteResponseHeader` `GatewayFilter` 팩토리는 `name`, `regexp`, `replacement` 파라미터를 사용한다. 여기선 응답 헤더를 유연하게 재작성할 수 있도록 자바 정규 표현식을 사용한다. 다음은 `RewriteResponseHeader` `GatewayFilter` 설정 예시다:

**Example 41. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: rewriteresponseheader_route
        uri: https://example.org
        filters:
        - RewriteResponseHeader=X-Response-Red, , password=[^&]+, password=***
```

헤더 값 `/42?user=ford&password=omg!what&flag=true`의 경우, 다운스트림 요청을 만든 후에 `/42?user=ford&password=***&flag=true`로 세팅된다. YAML 스펙에 따라 `$`를 사용하려면 `$\`를 명시해야 한다.

---

## 6.18. The `SaveSession` `GatewayFilter` Factory

`SaveSession` `GatewayFilter` 팩토리는 다운스트림으로 넘기기 전에 `WebSession::save` 실행을 강제한다. 특히 [스프링 세션](https://projects.spring.io/spring-session/) 등을 지연(lazy) 데이터 저장소에 저장하며, 원격 호출 실행 전에 반드시 세션 상태를 저장해야 할 때 많이 쓴다. 다음은 `SaveSession` `GatewayFilter` 설정 예시다:

**Example 42. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: save_session
        uri: https://example.org
        predicates:
        - Path=/foo/**
        filters:
        - SaveSession
```

[스프링 시큐리티](https://spring.io/projects/spring-security)를 스프링 세션과 통합하고, 보안 관련 세부 정보를 반드시 원격 프로세스로 전달해야 한다면 특히 중요하다.

---

## 6.19. The `SecureHeaders` `GatewayFilter` Factory

`SecureHeaders` `GatewayFilter` 팩토리는 [이 블로그 게시글](https://blog.appcanary.com/2017/http-security-headers.html)의 권고에 따라 응답에 여러 가지 헤더를 추가한다.

추가하는 헤더는 다음과 같다 (기본값도 함께 표기했다):

- `X-Xss-Protection:1` <span class="custom-blockquote">(mode=block)</span>
- `Strict-Transport-Security` <span class="custom-blockquote">(max-age=631138519)</span>
- `X-Frame-Options` <span class="custom-blockquote">(DENY)</span>
- `X-Content-Type-Options` <span class="custom-blockquote">(nosniff)</span>
- `Referrer-Policy` <span class="custom-blockquote">(no-referrer)</span>
- `Content-Security-Policy` <span class="custom-blockquote">(default-src 'self' https:; font-src 'self' https: data:; img-src 'self' https: data:; object-src 'none'; script-src https:; style-src 'self' https: 'unsafe-inline)'</span>
- `X-Download-Options` <span class="custom-blockquote">(noopen)</span>
- `X-Permitted-Cross-Domain-Policies` <span class="custom-blockquote">(none)</span>

기본값을 변경하려면 `spring.cloud.gateway.filter.secure-headers` 네임스페이스에 적절한 프로퍼티를 설정해라. 다음과 같은 프로퍼티를 이용할 수 있다:

- `xss-protection-header`
- `strict-transport-security`
- `x-frame-options`
- `x-content-type-options`
- `referrer-policy`
- `content-security-policy`
- `x-download-options`
- `x-permitted-cross-domain-policies`

기본값을 비활성화하려면 `spring.cloud.gateway.filter.secure-headers.disable` 프로퍼티에 값들을 콤마로 구분해서 넣어라. 사용법은 다음 예제를 참고해라:

```properties
spring.cloud.gateway.filter.secure-headers.disable=x-frame-options,strict-transport-security
```

> 비활성화할 때는 소문자로 된 보안 헤더의 풀 네임을 사용해야 한다.

---

## 6.20. The `SetPath` `GatewayFilter` Factory

`SetPath` `GatewayFilter` 팩토리는 path를 가리키는 `template` 파라미터를 사용한다. 이 클래스를 사용하면 간단하게 path의 세그먼트를 템플릿화해서 요청 path를 조작할 수 있다. 여기선 스프링 프레임워크의 URI 템플릿을 사용한다. 세그먼트는 여러 개를 매칭시킬 수 있다. 다음은 `SetPath` `GatewayFilter` 설정 예시다:

**Example 43. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: setpath_route
        uri: https://example.org
        predicates:
        - Path=/red/{segment}
        filters:
        - SetPath=/{segment}
```

여기선 `/red/blue` 요청을 받으면 다운스트림 요청을 만들기 전에 path를 `/blue`로 설정한다.

---

## 6.21. The `SetRequestHeader` `GatewayFilter` Factory

`SetRequestHeader` `GatewayFilter` 팩토리는 `name`, `value` 파라미터를 사용한다. 다음은 `SetRequestHeader` `GatewayFilter` 설정 예시다:

**Example 44. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: setrequestheader_route
        uri: https://example.org
        filters:
        - SetRequestHeader=X-Request-Red, Blue
```

이 `GatewayFilter`는 모든 헤더를 지정한 이름으로 (추가한다기 보단) 대체한다. 따라서 `X-Request-Red:1234`로 요청을 보내더라도, 다운스트림 서비스에서 받는 요청 헤더는 `X-Request-Red:Blue`로 대체된다.

`SetRequestHeader`는 path나 호스트를 매칭할 때 사용한 URI 변수를 인식할 수 있다. URI 변수는 value에서 활용할 수 있으며, 런타임에 치환된다. 다음은 변수를 하나 사용하는 `SetRequestHeader` `GatewayFilter` 설정 예시다:

**Example 45. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: setrequestheader_route
        uri: https://example.org
        predicates:
        - Host: {segment}.myhost.org
        filters:
        - SetRequestHeader=foo, bar-{segment}
```

---

## 6.22. The `SetResponseHeader` `GatewayFilter` Factory

`SetResponseHeader` `GatewayFilter` 팩토리는 `name`, `value` 파라미터를 사용한다. 다음은 `SetResponseHeader` `GatewayFilter` 설정 예시다:

**Example 46. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: setresponseheader_route
        uri: https://example.org
        filters:
        - SetResponseHeader=X-Response-Red, Blue
```

이 `GatewayFilter`는 모든 헤더를 지정한 이름으로 (추가한다기 보단) 대체한다. 따라서 다운스트림 서버가 `X-Response-Red:1234`로 응답하면, 게이트웨이 클라이언트가 수신하는 응답은 `X-Response-Red:Blue`로 대체된다.

`SetResponseHeader`는 path나 호스트를 매칭할 때 사용한 URI 변수를 인식할 수 있다. URI 변수는 value에서 활용할 수 있으며, 런타임에 치환된다. 다음은 변수를 하나 사용하는 `SetResponseHeader` `GatewayFilter` 설정 예시다:

**Example 47. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: setresponseheader_route
        uri: https://example.org
        predicates:
        - Host: {segment}.myhost.org
        filters:
        - SetResponseHeader=foo, bar-{segment}
```

---

## 6.23. The `SetStatus` `GatewayFilter` Factory

`SetStatus` `GatewayFilter` 팩토리는 단일 파라미터 `status`를 사용한다. 이 파라미터는 유효한 스프링 `HttpStatus`여야 한다. `404`같은 정수 값을 사용해도 되고, enum을 문자열로 표현해도 된다(`NOT_FOUND`). 다음은 `SetStatus` `GatewayFilter` 설정 예시다:

**Example 48. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: setstatusstring_route
        uri: https://example.org
        filters:
        - SetStatus=BAD_REQUEST
      - id: setstatusint_route
        uri: https://example.org
        filters:
        - SetStatus=401
```

두 케이스 모두 응답 HTTP 상태 코드를 401로 설정한다.

`SetStatus` `GatewayFilter`에선 프록시한 요청의 기존 HTTP 상태 코드를 응답 헤더에 넣어 반환할 수도 있다. 아래 프로퍼티를 설정하면 응답에 헤더를 추가한다:

**Example 49. application.yml**

```yaml
spring:
  cloud:
    gateway:
      set-status:
        original-status-header-name: original-http-status
```

---

## 6.24. The `StripPrefix` `GatewayFilter` Factory

`StripPrefix` `GatewayFilter` 팩토리는 단일 파라미터 `parts`를 사용한다. `parts` 파라미터는 요청을 다운스트림으로 보내기 전에 제거할 path 수를 나타낸다. 다음은 `StripPrefix` `GatewayFilter` 설정 예시다:

**Example 50. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: nameRoot
        uri: https://nameservice
        predicates:
        - Path=/name/**
        filters:
        - StripPrefix=2
```

게이트웨이를 통해 `/name/blue/red`로 요청을 보내면 `nameservice`에 보내는 요청은 `nameservice/red`가 된다.

---

## 6.25. The Retry `GatewayFilter` Factory

`Retry` `GatewayFilter` 팩토리가 지원하는 파라미터는 다음과 같다:

- `retries`: 재시도해볼 횟수.
- `statuses`: 재시도해야 하는 HTTP 상태 코드들로, `org.springframework.http.HttpStatus`로 표현한다.
- `methods`: 재시도해야 하는 HTTP 메소드들로, `org.springframework.http.HttpMethod`로 표현한다.
- `series`: 재시도할 상태 코드 시리즈들로, `org.springframework.http.HttpStatus.Series`로 표현한다.
- `exceptions`: 던져지면 재시도해야 하는 예외들 리스트.
- `backoff`: 재시도에 설정하는 exponential backoff. 재시도는 `firstBackoff * (factor ^ n)`만큼의 백오프 인터벌을 두고 수행하며, 여기서 `n`은 반복 회차(iteration)를 나타낸다. `maxBackoff`를 설정하면 백오프는 최대 `maxBackoff`까지만 적용된다. `basedOnPreviousValue`가 true일 땐 백오프를 `prevBackoff * factor`로 계산한다.

`Retry` 필터를 활성화하면 설정되는 기본값은 다음과 같다:

- `retries`: 세 번
- `series`: 5XX 시리즈
- `methods`: GET 메소드
- `exceptions`: `IOException`과 `TimeoutException`
- `backoff`: 비활성화

다음은 `Retry` `GatewayFilter` 설정 예시다:

**Example 51. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: retry_test
        uri: http://localhost:8080/flakey
        predicates:
        - Host=*.retry.com
        filters:
        - name: Retry
          args:
            retries: 3
            statuses: BAD_GATEWAY
            methods: GET,POST
            backoff:
              firstBackoff: 10ms
              maxBackoff: 50ms
              factor: 2
              basedOnPreviousValue: false
```

> `forward:` 프리픽스가 붙은 URL에서 retry 필터를 사용할 때는, 에러 발생 시 응답을 클라이언트로 전송하고 커밋할 수 있는 어떤 작업도 수행하지 않도록 타겟 엔드포인트를 신중히 작성해야 한다. 예를 들어, 타겟 엔드포인트가 어노테이션을 선언한 컨트롤러라면, 타겟 컨트롤러 메소드에선 에러 상태 코드를 가진 `ResponseEntity`를 리턴해선 안 된다. 그대신 `Exception`을 던지거나 에러 신호를 보내야 한다 (예를 들어 `Mono.error(ex)`를 리턴해서). 이렇게 해야만 retry 필터가 재시도할 수 있다.

> body를 가진 HTTP 메소드에 retry 필터를 사용하면, body를 캐시하고 게이트웨이 메모리를 사용하게 된다. body는 `ServerWebExchangeUtils.CACHED_REQUEST_BODY_ATTR`에 정의된 요청 속성에 캐시된다. 객체의 타입은 `org.springframework.core.io.buffer.DataBuffer`다.

---

## 6.26. The `RequestSize` `GatewayFilter` Factory

`RequestSize` `GatewayFilter` 팩토리는 허용치보다 크기가 큰 요청은 다운스트림 서비스에 도달하지 못하도록 제한할 수 있다. 이 필터는 `maxSize` 파라미터를 사용한다. `maxSize`는 `DataSize` 타입이므로, 숫자 뒤에 `KB` `MB`같은 `DataUnit` suffix를 정의해도 된다. suffix가 없을 때 기본값은 바이트를 나타내는 `B`로, 허용할 요청 크기 제한치를 바이트 단위로 정의한다. 다음은 `RequestSize` `GatewayFilter` 설정 예시다:

**Example 52. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: request_size_route
        uri: http://localhost:8080/upload
        predicates:
        - Path=/upload
        filters:
        - name: RequestSize
          args:
            maxSize: 5000000
```

`RequestSize` `GatewayFilter` 팩토리는 사이즈 때문에 요청을 거부할 땐, 응답 상태를 `413 Payload Too Large`로 설정하고 `errorMessage` 헤더를 별도로 추가한다. 다음은 `errorMessage` 예시다:

```properties
errorMessage: Request size is larger than permissible limit. Request size is 6.0 MB where permissible limit is 5.0 MB
```

> route 정의에 요청 사이즈를 filter 인자로 제공하지 않으면 디폴트로 5MB로 설정된다.

---

## 6.27. The `SetRequestHostHeader` `GatewayFilter` Factory

가끔은 host 헤더를 재정의해야 하기도 한다. 이런 상황에선 `SetRequestHostHeader` `GatewayFilter` 팩토리로 기존 host 헤더를 지정값으로 대체할 수 있다. 이 필터는 `host` 파라미터를 사용한다. 다음은 `SetRequestHostHeader` `GatewayFilter` 설정 예시다:

**Example 53. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: set_request_host_header_route
        uri: http://localhost:8080/headers
        predicates:
        - Path=/headers
        filters:
        - name: SetRequestHostHeader
          args:
            host: example.org
```

이 `SetRequestHostHeader` `GatewayFilter` 팩토리는 host 헤더 값을 `example.org`로 대체한다.

---

## 6.28. Modify a Request Body `GatewayFilter` Factory

`ModifyRequestBody` 필터 팩토리를 사용하면 게이트웨이에서 다운스트림으로 요청을 전송하기 전에 요청 body를 수정할 수 있다.

> 이 필터는 자바 DSL을 통해서만 설정할 수 있다.

다음은 `GatewayFilter`로 요청 body를 수정하는 방법을 보여주는 예시다:

```java
@Bean
public RouteLocator routes(RouteLocatorBuilder builder) {
    return builder.routes()
            .route("rewrite_request_obj", r -> r.host("*.rewriterequestobj.org")
                    .filters(f -> f.prefixPath("/httpbin")
                            .modifyRequestBody(String.class, Hello.class,
                                    MediaType.APPLICATION_JSON_VALUE,
                                    (exchange, s) -> Mono.just(new Hello(s.toUpperCase())))
                    )
                    .uri(uri))
            .build();
}

static class Hello {
    String message;

    public Hello() { }

    public Hello(String message) {
        this.message = message;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}
```

> 요청에 body가 없으면 `RewriteFunction`에는 `null`이 전달된다. 요청 body가 없을 때는 `Mono.empty()`를 반환해야 한다.

---

## 6.29. Modify a Response Body `GatewayFilter` Factory

`ModifyResponseBody` 필터를 사용하면 응답 body를 클라이언트로 돌려주기 전에 수정할 수 있다.

> 이 필터는 자바 DSL을 통해서만 설정할 수 있다.

다음은 `GatewayFilter`로 응답 body를 수정하는 방법을 보여주는 예시다:

```java
@Bean
public RouteLocator routes(RouteLocatorBuilder builder) {
    return builder.routes()
        .route("rewrite_response_upper", r -> r.host("*.rewriteresponseupper.org")
            .filters(f -> f.prefixPath("/httpbin")
                .modifyResponseBody(String.class, String.class,
                    (exchange, s) -> Mono.just(s.toUpperCase()))).uri(uri))
        .build();
}
```

> 응답에 body가 없다면 `RewriteFunction`에는 `null`이 전달된다. 응답 body가 없을 때는 `Mono.empty()`를 반환해야 한다.

---

## 6.30. Token Relay `GatewayFilter` Factory

Token Relay에선 OAuth2 컨슈머가 클라이언트로 동작하며, 전달받은 토큰을 리소스 요청에 추가해서 전송한다. 컨슈머는 순수 클라이언트(SSO 어플리케이션 등)일 수도 있고, 리소스 서버일 수도 있다.

스프링 클라우드 게이트웨이는 OAuth2 액세스 토큰을 프록시하는 다운스트림 서비스로 전달할 수 있다. 게이트웨이에 이 기능을 넣으려면 다음과 같이 `TokenRelayGatewayFilterFactory`를 추가해야 한다:

**App.java**

```java
@Bean
public RouteLocator customRouteLocator(RouteLocatorBuilder builder) {
    return builder.routes()
            .route("resource", r -> r.path("/resource")
                    .filters(f -> f.tokenRelay())
                    .uri("http://localhost:9000"))
            .build();
}
```

또는

**application.yaml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: resource
        uri: http://localhost:9000
        predicates:
        - Path=/resource
        filters:
        - TokenRelay=
```

이렇게 하면 (사용자를 로그인시키고 토큰을 잡아내는 것 말고도) 인증 토큰을 다운스트림 서비스로 전달할 거다 (여기선 `/resource`).

이 기능을 스프링 클라우드 게이트웨이에서 사용하려면 다음 의존성을 추가해라.

- `org.springframework.boot:spring-boot-starter-oauth2-client`

원리가 뭘까? [TokenRelayGatewayFilterFactory](https://github.com/spring-cloud/spring-cloud-gateway/blob/3e00fef5828f6a7deadda912bcd30ac618fa7fc5/spring-cloud-gateway-server/src/main/java/org/springframework/cloud/gateway/filter/factory/TokenRelayGatewayFilterFactory.java) 필터는 현재 인증된 사용자로부터 액세스 토큰을 추출해 다운스트림 요청 헤더에 집어넣는다.

동작하는 전체 샘플은 [이 프로젝트](https://github.com/spring-cloud-samples/sample-gateway-oauth2login)를 참고해라.

> `TokenRelayGatewayFilterFactory` 빈은 `ReactiveClientRegistrationRepository` 빈 생성을 트리거하는 적절한 `spring.security.oauth2.client.*` 프로퍼티를 설정했을 때에만 생성된다.

> `TokenRelayGatewayFilterFactory`에서 사용하는 디폴트 `ReactiveOAuth2AuthorizedClientService` 구현체는 인 메모리 데이터 저장소를 사용한다. 좀더 탄탄한 솔루션이 필요하다면 자체 `ReactiveOAuth2AuthorizedClientService` 구현체를 제공해야 한다.

---

## 6.31. Default Filters

모든 route에 적용할 필터를 추가하려면 `spring.cloud.gateway.default-filters`를 사용하면 된다. 이 프로퍼티는 필터 리스트를 사용한다. 다음은 디폴트 필터 셋을 정의하는 예시다:

**Example 54. application.yml**

```yaml
spring:
  cloud:
    gateway:
      default-filters:
      - AddResponseHeader=X-Response-Default-Red, Default-Blue
      - PrefixPath=/httpbin
```