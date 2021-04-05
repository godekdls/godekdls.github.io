---
title: Actuator API
category: Spring Cloud Gateway
order: 16
permalink: /Spring%20Cloud%20Gateway/actuator-api/
description: 액추에이터를 이용한 엔드포인트 사용 방법 한글 번역
image: ./../../images/springcloud/logo.jpeg
lastmod: 2021-04-06T22:00:00+09:00
comments: true
originalRefName: 스프링 클라우드 게이트웨이
originalRefLink: https://docs.spring.io/spring-cloud-gateway/docs/3.0.2/reference/html/#actuator-api
---

### 목차

- [15.1. Verbose Actuator Format](#151-verbose-actuator-format)
- [15.2. Retrieving Route Filters](#152-retrieving-route-filters)
  + [15.2.1. Global Filters](#1521-global-filters)
  + [15.2.2. Route Filters](#1522-route-filters)
- [15.3. Refreshing the Route Cache](#153-refreshing-the-route-cache)
- [15.4. Retrieving the Routes Defined in the Gateway](#154-retrieving-the-routes-defined-in-the-gateway)
- [15.5. Retrieving Information about a Particular Route](#155-retrieving-information-about-a-particular-route)
- [15.6. Creating and Deleting a Particular Route](#156-creating-and-deleting-a-particular-route)
- [15.7. Recap: The List of All endpoints](#157-recap-the-list-of-all-endpoints)

---

액추에이터 엔드포인트 `/gateway`를 사용하면 스프링 클라우드 게이트웨이 어플리케이션을 모니터링하고, 어플리케이션과 상호 작용할 수 있다. 원격으로 접근하려면 어플리케이션 프로퍼티에 엔드포인트를 [활성화](https://docs.spring.io/spring-boot/docs/current/reference/html/production-ready-endpoints.html#production-ready-endpoints-enabling-endpoints)하고 [HTTP나 JMX를 통해 노출해야](https://docs.spring.io/spring-boot/docs/current/reference/html/production-ready-endpoints.html#production-ready-endpoints-exposing-endpoints) 한다. 다음은 설정 방법을 보여주는 예시다:

**Example 70. application.properties**

```properties
management.endpoint.gateway.enabled=true # default value
management.endpoints.web.exposure.include=gateway
```

---

## 15.1. Verbose Actuator Format

더 자세한 포맷이 스프링 클라우드 게이트웨이에 새롭게 추가됐다. 이 포맷에선 각 route마다 세부 정보를 더 추가하기 때문에, 사용 가능한 모든 설정과, 각 route와 관련된 predicate와 필터를 함께 조회할 수 있다. 다음은 `/actuator/gateway/routes` 예시다:

```json
[
  {
    "predicate": "(Hosts: [**.addrequestheader.org] && Paths: [/headers], match trailing slash: true)",
    "route_id": "add_request_header_test",
    "filters": [
      "[[AddResponseHeader X-Response-Default-Foo = 'Default-Bar'], order = 1]",
      "[[AddRequestHeader X-Request-Foo = 'Bar'], order = 1]",
      "[[PrefixPath prefix = '/httpbin'], order = 2]"
    ],
    "uri": "lb://testservice",
    "order": 0
  }
]
```

이 기능은 디폴트로 활성화된다. 비활성화하려면 다음 프로퍼티를 설정해라:

**Example 71. application.properties**

```properties
spring.cloud.gateway.actuator.verbose.enabled=false
```

향후 릴리즈에선 디폴트로 `true`를 사용할 거다.

---

## 15.2. Retrieving Route Filters

이번 섹션에선 다음과 같은 route 필터를 조회하는 방법을 자세히 설명한다:

- [Global Filters](#1521-global-filters)
- [gateway-route-filters](#1522-route-filters)

### 15.2.1. Global Filters

모든 route에 적용된 [글로벌 필터](../globalfilters)를 조회하려면 `actuator/gateway/globalfilters`에 `GET` 요청을 보내라. 응답 결과는 다음과 유사할 거다:

```json
{
  "org.springframework.cloud.gateway.filter.LoadBalancerClientFilter@77856cc5": 10100,
  "org.springframework.cloud.gateway.filter.RouteToRequestUrlFilter@4f6fd101": 10000,
  "org.springframework.cloud.gateway.filter.NettyWriteResponseFilter@32d22650": -1,
  "org.springframework.cloud.gateway.filter.ForwardRoutingFilter@106459d9": 2147483647,
  "org.springframework.cloud.gateway.filter.NettyRoutingFilter@1fbd5e0": 2147483647,
  "org.springframework.cloud.gateway.filter.ForwardPathFilter@33a71d23": 0,
  "org.springframework.cloud.gateway.filter.AdaptCachedBodyGlobalFilter@135064ea": 2147483637,
  "org.springframework.cloud.gateway.filter.WebsocketRoutingFilter@23c05889": 2147483646
}
```

응답에는 마련돼 있는 글로벌 필터들의 세부 정보가 담겨있다. 모든 글로벌 필터마다 필터 객체의 문자열 표현과 (ex. `org.springframework.cloud.gateway.filter.LoadBalancerClientFilter@77856cc5`) 필터 체인 내의 순서 정보가 있다.

### 15.2.2. Route Filters

route에 적용된 [`GatewayFilter` 팩토리](../gatewayfilter-factories)를 조회하려면 `/actuator/gateway/routefilters`에 `GET` 요청을 보내라. 응답 결과는 다음과 유사할 거다:

```json
{
  "[AddRequestHeaderGatewayFilterFactory@570ed9c configClass = AbstractNameValueGatewayFilterFactory.NameValueConfig]": null,
  "[SecureHeadersGatewayFilterFactory@fceab5d configClass = Object]": null,
  "[SaveSessionGatewayFilterFactory@4449b273 configClass = Object]": null
}
```

응답에는 특정 route에 적용된 `GatewayFilter` 팩토리의 세부 정보가 담겨있다. 모든 팩토리마다 해당 객체의 문자열 표현이 있다 (ex. `[SecureHeadersGatewayFilterFactory@fceab5d configClass = Object]`). `null` 값은 엔드포인트 컨트롤러 구현이 아직 미완성이기 때문인데, `GatewayFilter` 팩토리 객체에 적용되지 않는 필터 체인에서의 순서를 설정하려고 하기 때문이다.

---

## 15.3. Refreshing the Route Cache

routes 캐시를 지우려면 `/actuator/gateway/refresh`에 `POST` 요청을 보내라. 이 요청은 응답 body 없이 200을 반환한다.

---

## 15.4. Retrieving the Routes Defined in the Gateway

게이트웨이에 정의한 route를 조회하려면 `/actuator/gateway/routes`에 `GET` 요청을 보내라. 응답 결과는 다음과 유사할 거다:

```json
[{
  "route_id": "first_route",
  "route_object": {
    "predicate": "org.springframework.cloud.gateway.handler.predicate.PathRoutePredicateFactory$$Lambda$432/1736826640@1e9d7e7d",
    "filters": [
      "OrderedGatewayFilter{delegate=org.springframework.cloud.gateway.filter.factory.PreserveHostHeaderGatewayFilterFactory$$Lambda$436/674480275@6631ef72, order=0}"
    ]
  },
  "order": 0
},
{
  "route_id": "second_route",
  "route_object": {
    "predicate": "org.springframework.cloud.gateway.handler.predicate.PathRoutePredicateFactory$$Lambda$432/1736826640@cd8d298",
    "filters": []
  },
  "order": 0
}]
```

응답에는 게이트웨이에 정의한 모든 route의 세부 정보가 담겨있다. 다음은 응답에 있는 각 요소(route)의 구조를 설명하는 테이블이다:

| Path                     | Type   | Description                                                  |
| :----------------------- | :----- | :----------------------------------------------------------- |
| `route_id`               | String | route ID.                                                    |
| `route_object.predicate` | Object | route predicate.                                             |
| `route_object.filters`   | Array  | route에 적용한 [`GatewayFilter` factories](../gatewayfilter-factories). |
| `order`                  | Number | route 순서.                                                  |

---

## 15.5. Retrieving Information about a Particular Route

단일 route의 정보를 조회하려면 `/actuator/gateway/routes/{id}`에 `GET` 요청을 보내라 (예를 들어 `/actuator/gateway/routes/first_route`). 응답 결과는 다음과 유사할 거다:

```json
{
  "id": "first_route",
  "predicates": [{
    "name": "Path",
    "args": {"_genkey_0":"/first"}
  }],
  "filters": [],
  "uri": "https://www.uri-destination.org",
  "order": 0
}]
```

다음은 응답 구조를 설명하는 테이블이다:

| Path         | Type   | Description                                                  |
| :----------- | :----- | :----------------------------------------------------------- |
| `id`         | String | route ID.                                                    |
| `predicates` | Array  | route predicate들의 컬렉션. 각 아이템은 주어진 predicate의 이름과 인자들을 정의한다. |
| `filters`    | Array  | route에 적용된 필터들의 컬렉션.                              |
| `uri`        | String | route의 목적지 URI.                                          |
| `order`      | Number | route 순서.                                                  |

---

## 15.6. Creating and Deleting a Particular Route

route를 생성하려면 JSON body로 route의 필드를 지정해서 ([특정 route 정보 조회하기](#155-retrieving-information-about-a-particular-route) 참고) `/gateway/routes/{id_route_to_create}`에 `POST` 요청을 보내라.

route를 삭제하려면 `/gateway/routes/{id_route_to_delete}`에 `DELETE` 요청을 보내라.

---

## 15.7. Recap: The List of All endpoints

아래 테이블에 스프링 클라우드 게이트웨이 액추에이터 엔드포인트를 요약해뒀다 (모든 엔드포인트는 `/actuator/gateway`가 기본 path다):

| ID              | HTTP Method | Description                                                  |
| :-------------- | :---------- | :----------------------------------------------------------- |
| `globalfilters` | GET         | route들에 적용된 글로벌 필터 리스트를 노출한다.              |
| `routefilters`  | GET         | 특정 route에 적용된 `GatewayFilter` 팩토리 리스트를 노출한다. |
| `refresh`       | POST        | 라우트 캐시를 삭제한다.                                      |
| `routes`        | GET         | 게이트웨이에 정의한 route 리스트를 노출한다.                 |
| `routes/{id}`   | GET         | 특정 route와 관련된 정보를 노출한다.                         |
| `routes/{id}`   | POST        | 게이트웨이에 새 route를 추가한다.                            |
| `routes/{id}`   | DELETE      | 게이트웨이에서 기존 route를 제거한다.                        |