---
title: Http timeouts configuration
category: Spring Cloud Gateway
order: 13
permalink: /Spring%20Cloud%20Gateway/http-timeouts-configuration/
description: route에 Http 타임아웃을 설정하는 방법, 디스커버리 서비스 레지스트리에 등록된 서비스를 기반으로 route를 만들고 predicate와 필터를 설정하는 방법 한글 번역
image: ./../../images/springcloud/logo.jpeg
lastmod: 2021-04-06T22:00:00+09:00
comments: true
originalRefName: 스프링 클라우드 게이트웨이
originalRefLink: https://docs.spring.io/spring-cloud-gateway/docs/3.0.2/reference/html/#http-timeouts-configuration
---

### 목차

- [12.1. Global timeouts](#121-global-timeouts)
- [12.2. Per-route timeouts](#122-per-route-timeouts)
- [12.3. Fluent Java Routes API](#123-fluent-java-routes-api)
- [12.4. The DiscoveryClient Route Definition Locator](#124-the-discoveryclient-route-definition-locator)
  + [12.4.1. Configuring Predicates and Filters For DiscoveryClient Routes](#1241-configuring-predicates-and-filters-for-discoveryclient-routes)
    
---

모든 route에 사용할 Http 타임아웃(response/connect)을 설정하고, 특정 route마다 설정을 재정의할 수 있다.

---

## 12.1. Global timeouts

전역 http 타임아웃을 설정하려면:<br>
`connect-timeout`은 밀리세컨드로 지정해야 한다.<br>
`response-timeout`은 java.time.Duration으로 지정해야 한다.<br>

**global http timeouts example**

```yaml
spring:
  cloud:
    gateway:
      httpclient:
        connect-timeout: 1000
        response-timeout: 5s
```

---

## 12.2. Per-route timeouts

route 단위 타임아웃을 설정하려면:<br>
`connect-timeout`은 밀리세컨드로 지정해야 한다.<br>
`response-timeout`은 밀리세컨드로 지정해야 한다.<br>

**per-route http timeouts configuration via configuration**

```yaml
      - id: per_route_timeouts
        uri: https://example.org
        predicates:
          - name: Path
            args:
              pattern: /delay/{timeout}
        metadata:
          response-timeout: 200
          connect-timeout: 200
```

**per-route timeouts configuration using Java DSL**

```java
import static org.springframework.cloud.gateway.support.RouteMetadataUtils.CONNECT_TIMEOUT_ATTR;
import static org.springframework.cloud.gateway.support.RouteMetadataUtils.RESPONSE_TIMEOUT_ATTR;

      @Bean
      public RouteLocator customRouteLocator(RouteLocatorBuilder routeBuilder){
         return routeBuilder.routes()
               .route("test1", r -> {
                  return r.host("*.somehost.org").and().path("/somepath")
                        .filters(f -> f.addRequestHeader("header1", "header-value-1"))
                        .metadata(RESPONSE_TIMEOUT_ATTR, 200)
                        .metadata(CONNECT_TIMEOUT_ATTR, 200)
                        .uri("http://someuri");
               })
               .build();
      }
```

---

## 12.3. Fluent Java Routes API

`RouteLocatorBuilder` 빈은 자바 설정을 간소화할 수 있는 fluent API를 제공한다. 다음은 사용 방법을 보여주는 예시다:

**Example 66. GatewaySampleApplication.java**

```java
// static imports from GatewayFilters and RoutePredicates
@Bean
public RouteLocator customRouteLocator(RouteLocatorBuilder builder, ThrottleGatewayFilterFactory throttle) {
    return builder.routes()
            .route(r -> r.host("**.abc.org").and().path("/image/png")
                .filters(f ->
                        f.addResponseHeader("X-TestHeader", "foobar"))
                .uri("http://httpbin.org:80")
            )
            .route(r -> r.path("/image/webp")
                .filters(f ->
                        f.addResponseHeader("X-AnotherHeader", "baz"))
                .metadata("key", "value")
                .uri("http://httpbin.org:80")
            )
            .route(r -> r.order(-1)
                .host("**.throttle.org").and().path("/get")
                .filters(f -> f.filter(throttle.apply(1, 1, 10, TimeUnit.SECONDS)))
                .metadata("key", "value")
                .uri("http://httpbin.org:80")
            )
            .build();
}
```

게다가 이 스타일에선 predicate를 더 다양하게 커스텀해 정의할 수 있다. `RouteDefinitionLocator` 빈으로 정의한 predicate는 논리적 `and` 연산자를 사용해 결합된다. fluent Java API를 사용하면 `Predicate` 클래스의 `and()`, `or()`, `negate()` 연산자를 좀 더 다양하게 활용할 수 있다.

---

## 12.4. The `DiscoveryClient` Route Definition Locator

 게이트웨이는 `DiscoveryClient` 호환 서비스 레지스트리에 등록된 서비스를 기반으로 route를 생성하도록 설정할 수 있다.

이 기능을 활성화하려면 `spring.cloud.gateway.discovery.locator.enabled=true`를 설정하돼, 반드시 클래스패스에 `DiscoveryClient` 구현체가 (ex. Netflix Eureka, Consul, Zookeeper) 있고 활성화돼 있어야 한다.

### 12.4.1. Configuring Predicates and Filters For `DiscoveryClient` Routes

게이트웨이는 `DiscoveryClient`로 생성된 route엔 기본적으로 predicate와 필터를 하나씩 정의한다.

디폴트 predicate는 `/serviceId/**` 패턴으로 정의한 path predicate며, 여기서 `serviceId`는 `DiscoveryClient`의 서비스 ID다.

디폴트 필터는 regexp `/serviceId/?(?<remaining>.*)`와 replacement `/${remaining}`을 가진 rewrite path 필터다. 이렇게 하면 요청을 다운스트림으로 전송하기 전에 서비스 ID는 path에서 제거된다.

`DiscoveryClient` route에서 사용할 predicate나 필터를 커스텀하고 싶다면, `spring.cloud.gateway.discovery.locator.predicates[x]`와 `spring.cloud.gateway.discovery.locator.filters[y]`를 설정해라. 단, 앞에서 보여준 디폴트 predicate와 필터 기능을 보존하고 싶다면, 디폴트 predicate, 필터도 반드시 추가해야 한다. 다음은 어떻게 설정을 구성하는지 보여주는 예시다:

**Example 67. application.properties**

```properties
spring.cloud.gateway.discovery.locator.predicates[0].name: Path
spring.cloud.gateway.discovery.locator.predicates[0].args[pattern]: "'/'+serviceId+'/**'"
spring.cloud.gateway.discovery.locator.predicates[1].name: Host
spring.cloud.gateway.discovery.locator.predicates[1].args[pattern]: "'**.foo.com'"
spring.cloud.gateway.discovery.locator.filters[0].name: CircuitBreaker
spring.cloud.gateway.discovery.locator.filters[0].args[name]: serviceId
spring.cloud.gateway.discovery.locator.filters[1].name: RewritePath
spring.cloud.gateway.discovery.locator.filters[1].args[regexp]: "'/' + serviceId + '/?(?<remaining>.*)'"
spring.cloud.gateway.discovery.locator.filters[1].args[replacement]: "'/${remaining}'"
```