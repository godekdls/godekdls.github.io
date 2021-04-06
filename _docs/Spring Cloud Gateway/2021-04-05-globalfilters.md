---
title: Global Filters
category: Spring Cloud Gateway
order: 8
permalink: /Spring%20Cloud%20Gateway/globalfilters/
description: 스프링 클라우드 게이트웨이가 제공하는 여러 가지 글로벌 필터 소개 한글 번역
image: ./../../images/springcloud/logo.jpeg
lastmod: 2021-04-06T22:00:00+09:00
comments: true
originalRefName: 스프링 클라우드 게이트웨이
originalRefLink: https://docs.spring.io/spring-cloud-gateway/docs/3.0.2/reference/html/#global-filters
---

### 목차

- [7.1. Combined Global Filter and GatewayFilter Ordering](#71-combined-global-filter-and-gatewayfilter-ordering)
- [7.2. Forward Routing Filter](#72-forward-routing-filter)
- [7.3. The LoadBalancerClient Filter](#73-the-loadbalancerclient-filter)
- [7.4. The ReactiveLoadBalancerClientFilter](#74-the-reactiveloadbalancerclientfilter)
- [7.5. The Netty Routing Filter](#75-the-netty-routing-filter)
- [7.6. The Netty Write Response Filter](#76-the-netty-write-response-filter)
- [7.7. The RouteToRequestUrl Filter](#77-the-routetorequesturl-filter)
- [7.8. The Websocket Routing Filter](#78-the-websocket-routing-filter)
- [7.9. The Gateway Metrics Filter](#79-the-gateway-metrics-filter)
- [7.10. Marking An Exchange As Routed](#710-marking-an-exchange-as-routed)

---

`GlobalFilter` 인터페이스 시그니처는 `GatewayFilter`와 동일하다. `GlobalFilter`는 모든 route에 조건부로 적용되는 특수 필터다.

> 이 인터페이스와 사용법은 향후 마일스톤 릴리즈에서 변경될 수 있다.

---

## 7.1. Combined Global Filter and `GatewayFilter` Ordering

요청이 route에 매칭되면 필터링 웹 핸들러는 모든 `GlobalFilter` 인스턴스와 route에 등록된 모든 `GatewayFilter` 인스턴스를 필터 체인에 추가한다. 필터 체인을 결합한 다음엔 `org.springframework.core.Ordered` 인터페이스로 정렬하며, 순서는 `getOrder()` 메소드를 구현하면 원하는대로 설정할 수 있다.

스프링 클라우드 게이트웨이는 필터 로직을 실행할 때 "pre", "post" 단계를 구분한다 ([How it Works](../how-it-works) 섹션 참고). 따라서 우선 순위가 제일 높은 필터는 "pre" 단계에선 첫 번째로, "post" 단계에선 마지막으로 실행된다.

다음은 필터 체인을 설정하는 예시다:

**Example 55. ExampleConfiguration.java**

```java
@Bean
public GlobalFilter customFilter() {
    return new CustomGlobalFilter();
}

public class CustomGlobalFilter implements GlobalFilter, Ordered {

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        log.info("custom global filter");
        return chain.filter(exchange);
    }

    @Override
    public int getOrder() {
        return -1;
    }
}
```

---

## 7.2. Forward Routing Filter

`ForwardRoutingFilter`는 exchange 속성 `ServerWebExchangeUtils.GATEWAY_REQUEST_URL_ATTR`에서 URI를 찾는다. URL에 `forward` 스킴이 있으면 (ex. `forward:///localendpoint`), 스프링 `DispatcherHandler`를 사용해서 요청을 처리한다. 요청 URL의 path는 포워드 URL에 있는 path로 재정의된다. 원래 있던 URL은 `ServerWebExchangeUtils.GATEWAY_ORIGINAL_REQUEST_URL_ATTR` 속성에 있는 리스트에 추가한다.

---

## 7.3. The `LoadBalancerClient` Filter

`LoadBalancerClientFilter`는 `ServerWebExchangeUtils.GATEWAY_REQUEST_URL_ATTR`이란 exchange 속성에서 URI를 찾는다. URL에 `lb` 스키킴이 있으면 (ex. `lb://myservice`) 스프링 클라우드 `LoadBalancerClient`를 사용해서 이름을 (이 예시에선 `myservice`) 실제 호스트와 포트로 리졸브하고, 같은 속성에 URI를 대체해 넣는다. 원래 있던 URL은 `ServerWebExchangeUtils.GATEWAY_ORIGINAL_REQUEST_URL_ATTR` 속성에 있는 리스트에 추가한다. 이 필터는 `ServerWebExchangeUtils.GATEWAY_SCHEME_PREFIX_ATTR` 속성값도 `lb`와 같은지 확인한다. 속성 값이 `lb`라면 같은 규칙을 적용한다. 다음은 `LoadBalancerClientFilter` 설정 예시다:

**Example 56. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: myRoute
        uri: lb://service
        predicates:
        - Path=/service/**
```

> `LoadBalancer`에서 서비스 인스턴스를 찾을 수 없다면 기본적으로 `503`을 반환한다. `spring.cloud.gateway.loadbalancer.use404=true`를 설정하면 `404`를 반환하도록 만들 수 있다.

> `LoadBalancer`에서 반환한 `ServiceInstance`의 `isSecure` 값은 게이트웨이에 전송한 요청에 지정했던 스킴을 재정의한다. 예를 들어 게이트웨이에 `HTTPS`를 통해 요청이 들어왔더라도, `isSecure`가 false면 다운스트림 요청은 `HTTP`를 통해 이루어진다. 반대 상황도 가능하다. 하지만 게이트웨이 설정에서 route에 `GATEWAY_SCHEME_PREFIX_ATTR`을 지정하면 route URL에 있는 스킴이 `ServiceInstance` 설정을 또 한번 재정의하게 된다.

> 게이트웨이는 LoadBalancer 기능을 모두 지원한다. 자세한 내용은 [Spring Cloud Commons 문서](https://docs.spring.io/spring-cloud-commons/docs/current/reference/html/#spring-cloud-loadbalancer)에서 확인할 수 있다.

---

## 7.4. The `ReactiveLoadBalancerClientFilter`

`ReactiveLoadBalancerClientFilter`는 `ServerWebExchangeUtils.GATEWAY_REQUEST_URL_ATTR`이란 exchange 속성에서 URI를 찾는다. URL에 `lb` 스키킴이 있으면 (ex. `lb://myservice`) 스프링 클라우드 `ReactorLoadBalancer`를 사용해서 이름을 (이 예시에선 `myservice`) 실제 호스트와 포트로 리졸브하고, 같은 속성에 URI를 대체해 넣는다. 원래 있던 URL은 `ServerWebExchangeUtils.GATEWAY_ORIGINAL_REQUEST_URL_ATTR` 속성에 있는 리스트에 추가한다. 이 필터는 `ServerWebExchangeUtils.GATEWAY_SCHEME_PREFIX_ATTR` 속성값도 `lb`와 같은지 확인한다. 속성 값이 `lb`라면 같은 규칙을 적용한다. 다음은 `ReactiveLoadBalancerClientFilter` 설정 예시다:

**Example 57. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: myRoute
        uri: lb://service
        predicates:
        - Path=/service/**
```

> `ReactorLoadBalancer`에서 서비스 인스턴스를 찾을 수 없다면 기본적으로 `503`을 반환한다. `spring.cloud.gateway.loadbalancer.use404=true`를 설정하면 `404`를 반환하도록 만들 수 있다.

> `ReactiveLoadBalancerClientFilter`에서 반환한 `ServiceInstance`의 `isSecure` 값은 게이트웨이에 전송한 요청에 지정했던 스킴을 재정의한다. 예를 들어 게이트웨이에 `HTTPS`를 통해 요청이 들어왔더라도, `isSecure`가 false면 다운스트림 요청은 `HTTP`를 통해 이루어진다. 반대 상황도 가능하다. 하지만 게이트웨이 설정에서 route에 `GATEWAY_SCHEME_PREFIX_ATTR`을 지정하면 route URL에 있는 스킴이 `ServiceInstance` 설정을 또 한번 재정의하게 된다.

---

## 7.5. The Netty Routing Filter

Netty 라우팅 필터는 exchange의 `ServerWebExchangeUtils.GATEWAY_REQUEST_URL_ATTR` 속성에서 조회한 URL에 `http`나 `https` 스킴이 있을 때 실행된다. 이땐 Netty `HttpClient`를 사용해서 다운스트림 프록시 요청을 만든다. 응답은 이후 필터에서 사용할 수 있도록 exchange의 `ServerWebExchangeUtils.CLIENT_RESPONSE_ATTR` 속성에 저장한다. (아직 실험 단계지만, 같은 로직을 실행하지만 Netty가 필요하지 않은 `WebClientHttpRoutingFilter`도 있다.)

---

## 7.6. The Netty Write Response Filter

`NettyWriteResponseFilter`는 exchage의 `ServerWebExchangeUtils.CLIENT_RESPONSE_ATTR` 속성에 Netty `HttpClientResponse`가 있을 때 실행된다. 다른 필터를 모두 완료한 뒤에 실행되며, 게이트웨이 클라이언트에 돌려줄 응답에 프록시 응답을 작성한다. (아직 실험 단계지만, 같은 로직을 실행하지만 Netty가 필요하지 않은 `WebClientWriteResponseFilter`도 있다.)

---

## 7.7. The `RouteToRequestUrl` Filter

exchange의 `ServerWebExchangeUtils.GATEWAY_ROUTE_ATTR` 속성에 `Route` 객체가 있으면 `RouteToRequestUrlFilter`가 실행된다. 요청 URI를 기반으로 새 URI를 생성하는데, 이때 URI는 `Route` 객체의 URI 속성을 반영해서 만들어진다. 새 URI는 exchange 속성 `ServerWebExchangeUtils.GATEWAY_REQUEST_URL_ATTR`에 추가한다.

URI에 `lb:ws://serviceid`같은 스킴 프리픽스가 있을 때는, `lb` 스킴은 URI에서 제거되고, 이후 필터 체인에서 사용할 수 있도록 `ServerWebExchangeUtils.GATEWAY_SCHEME_PREFIX_ATTR`에 추가한다.

---

## 7.8. The Websocket Routing Filter

exchage의 `ServerWebExchangeUtils.GATEWAY_REQUEST_URL_ATTR` 속성에 있는 URL에 `ws`나 `wss` 스킴이 있을 땐 웹소켓 라우팅 필터가 실행된다. 이때는 스프링 WebSocket 인프라를 통해 웹소켓 요청을 다운스트림으로 전달한다.

URI에 `lb:ws://serviceid`같은 `lb` 프리픽스를 지정하면 웹소켓 요청을 로드밸런싱할 수 있다.

> [SockJS](https://github.com/sockjs)를 일반 HTTP에 대한 폴백으로 사용한다면 웹소켓 route 외에 일반 HTTP route도 설정해야 한다.

다음은 웹소켓 라우팅 필터 설정 예시다:

**Example 58. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      # SockJS route
      - id: websocket_sockjs_route
        uri: http://localhost:3001
        predicates:
        - Path=/websocket/info/**
      # Normal Websocket route
      - id: websocket_route
        uri: ws://localhost:3001
        predicates:
        - Path=/websocket/**
```

---

## 7.9. The Gateway Metrics Filter

게이트웨이 메트릭을 활성화하려면 프로젝트 의존성에 `spring-boot-starter-actuator`를 추가해라. 의존성을 추가하면 `spring.cloud.gateway.metrics.enabled` 프로퍼티를 `false`로 명시하지 않는 한 디폴트로 게이트웨이 메트릭 필터를 실행한다. 이 필터는 다음과 같은 태그로 `gateway.requests`라는 타이머 메트릭을 추가한다:

- `routeId`: route ID.
- `routeUri`: API를 라우팅한 URI.
- `outcome`: [HttpStatus.Series](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/http/HttpStatus.Series.html)로 분류한 결과.
- `status`: 클라이언트에 돌려준 요청의 HTTP 상태 코드.
- `httpStatusCode`: 클라이언트에 돌려준 요청의 HTTP 상태 코드.
- `httpMethod`: 요청에 사용한 HTTP 메소드.

이 메트릭들은 `/actuator/metrics/gateway.requests`에서 수집해갈 수 있으며, 쉽게 프로메테우스와 통합해 [그라파나](https://docs.spring.io/spring-cloud-gateway/docs/3.0.2/reference/html/images/gateway-grafana-dashboard.jpeg) [대시 보드](https://docs.spring.io/spring-cloud-gateway/docs/3.0.2/reference/html/gateway-grafana-dashboard.json)를 만들 수 있다.

> 프로메테우스 엔드포인트를 활성화하려면 프로젝트 의존성에 `micrometer-registry-prometheus`를 추가해라.

---

## 7.10. Marking An Exchange As Routed

게이트웨이에선 `ServerWebExchange`를 라우팅한 뒤에는 exchange 속성에 `gatewayAlreadyRouted`를 추가해서 해당 exchange는 "라우팅 되었음"으로 마킹한다. 일단 요청이 라우팅된 걸로 마킹되고 나면, 다른 라우팅 필터들은 요청을 다시 라우팅하지 않고 근본적으로 필터를 건너뛰게 된다. Exchange를 라우팅 완료로 마킹하거나, 이미 라우팅 됐는지를 확인할 수 있는 간편한 메소드들이 준비되어 있다.

- `ServerWebExchangeUtils.isAlreadyRouted`는 `ServerWebExchange` 객체를 받아 "라우팅이 되었는지"를 확인한다.
- `ServerWebExchangeUtils.setAlreadyRouted`는 `ServerWebExchange` 객체를 받아 "라우팅 되었음"으로 마킹한다.