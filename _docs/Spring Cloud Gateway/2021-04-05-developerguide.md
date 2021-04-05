---
title: Developer Guide
category: Spring Cloud Gateway
order: 18
permalink: /Spring%20Cloud%20Gateway/developer-guide/
description: 커스텀 RoutePredicateFactory/GatewayFilter 팩토리, GlobalFilter 정의하기 한글 번역
image: ./../../images/springcloud/logo.jpeg
lastmod: 2021-04-06T22:00:00+09:00
comments: true
originalRefName: 스프링 클라우드 게이트웨이
originalRefLink: https://docs.spring.io/spring-cloud-gateway/docs/3.0.2/reference/html/#developer-guide
---

### 목차

- [17.1. Writing Custom Route Predicate Factories](#171-writing-custom-route-predicate-factories)
- [17.2. Writing Custom GatewayFilter Factories](#172-writing-custom-gatewayfilter-factories)
  + [17.2.1. Naming Custom Filters And References In Configuration](#1721-naming-custom-filters-and-references-in-configuration)
- [17.3. Writing Custom Global Filters](#173-writing-custom-global-filters)

---

이 문서는 게이트웨이에 몇 가지 커스텀 컴포넌트를 작성하기 위한 기본 가이드다.

---

## 17.1. Writing Custom Route Predicate Factories

Route Predicate를 작성하려면 `RoutePredicateFactory`를 구현해야 한다. `AbstractRoutePredicateFactory`라는 추상 클래스를 상속해도 된다.

**MyRoutePredicateFactory.java**

```java
public class MyRoutePredicateFactory extends AbstractRoutePredicateFactory<HeaderRoutePredicateFactory.Config> {

    public MyRoutePredicateFactory() {
        super(Config.class);
    }

    @Override
    public Predicate<ServerWebExchange> apply(Config config) {
        // grab configuration from Config object
        return exchange -> {
            //grab the request
            ServerHttpRequest request = exchange.getRequest();
            //take information from the request to see if it
            //matches configuration.
            return matches(config, request);
        };
    }

    public static class Config {
        //Put the configuration properties for your filter here
    }

}
```

---

## 17.2. Writing Custom GatewayFilter Factories

GatewayFilter를 작성하려면 `GatewayFilterFactory`를 구현해야 한다. `AbstractGatewayFilterFactory`라는 추상 클래스를 상속해도 된다. 다음은 그 방법을 보여주는 예시다:

**Example 72. PreGatewayFilterFactory.java**

```java
public class PreGatewayFilterFactory extends AbstractGatewayFilterFactory<PreGatewayFilterFactory.Config> {

    public PreGatewayFilterFactory() {
        super(Config.class);
    }

    @Override
    public GatewayFilter apply(Config config) {
        // grab configuration from Config object
        return (exchange, chain) -> {
            //If you want to build a "pre" filter you need to manipulate the
            //request before calling chain.filter
            ServerHttpRequest.Builder builder = exchange.getRequest().mutate();
            //use builder to manipulate the request
            return chain.filter(exchange.mutate().request(builder.build()).build());
        };
    }

    public static class Config {
        //Put the configuration properties for your filter here
    }

}
```

**PostGatewayFilterFactory.java**

```java
public class PostGatewayFilterFactory extends AbstractGatewayFilterFactory<PostGatewayFilterFactory.Config> {

    public PostGatewayFilterFactory() {
        super(Config.class);
    }

    @Override
    public GatewayFilter apply(Config config) {
        // grab configuration from Config object
        return (exchange, chain) -> {
            return chain.filter(exchange).then(Mono.fromRunnable(() -> {
                ServerHttpResponse response = exchange.getResponse();
                //Manipulate the response in some way
            }));
        };
    }

    public static class Config {
        //Put the configuration properties for your filter here
    }

}
```

### 17.2.1. Naming Custom Filters And References In Configuration

커스텀 필터 클래스 이름은 `GatewayFilterFactory`로 끝나야 한다.

예를 들어서, 설정 파일에서 `Something`이란 필터를 참조하려면 `SomethingGatewayFilterFactory`라는 클래스 안에 필터가 있어야 한다.

> `class AnotherThing`과 같이 이름에 `GatewayFilterFactory` suffix가 없는 게이트웨이 필터도 생성할 수는 있다. 설정 파일에선 `AnotherThing`으로 참조할 수 있다. 하지만 공식적으로 지원하는 네이밍 컨벤션은 **아니다**. 이 문법은 향후 릴리즈에서 제거될 수도 있다. 필터 이름은 컨벤션 규정을 준수하도록 업데이트해라.

---

## 17.3. Writing Custom Global Filters

커스텀 글로벌 필터를 작성하려면 `GlobalFilter` 인터페이스를 구현해야 한다. 이 필터는 모든 요청에 적용된다.

다음 예제에선 각각 글로벌 pre, post 필터를 설정하고 있다:

```java
@Bean
public GlobalFilter customGlobalFilter() {
    return (exchange, chain) -> exchange.getPrincipal()
        .map(Principal::getName)
        .defaultIfEmpty("Default User")
        .map(userName -> {
          //adds header to proxied request
          exchange.getRequest().mutate().header("CUSTOM-REQUEST-HEADER", userName).build();
          return exchange;
        })
        .flatMap(chain::filter);
}

@Bean
public GlobalFilter customGlobalPostFilter() {
    return (exchange, chain) -> chain.filter(exchange)
        .then(Mono.just(exchange))
        .map(serverWebExchange -> {
          //adds header to response
          serverWebExchange.getResponse().getHeaders().set("CUSTOM-RESPONSE-HEADER",
              HttpStatus.OK.equals(serverWebExchange.getResponse().getStatusCode()) ? "It worked": "It did not work");
          return serverWebExchange;
        })
        .then();
}
```