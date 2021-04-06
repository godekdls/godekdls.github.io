---
title: Configuration
category: Spring Cloud Gateway
order: 11
permalink: /Spring%20Cloud%20Gateway/configuration/
description: 게이트웨이 설정 로딩 방식 한글 번역
image: ./../../images/springcloud/logo.jpeg
lastmod: 2021-04-06T22:00:00+09:00
comments: true
originalRefName: 스프링 클라우드 게이트웨이
originalRefLink: https://docs.spring.io/spring-cloud-gateway/docs/3.0.2/reference/html/#configuration
---

---

스프링 클라우드 게이트웨이의 설정은 `RouteDefinitionLocator` 인스턴스 컬렉션을 통해 구동된다. 다음은 `RouteDefinitionLocator` 인터페이스의 정의다:

**Example 63. RouteDefinitionLocator.java**

```java
public interface RouteDefinitionLocator {
    Flux<RouteDefinition> getRouteDefinitions();
}
```

기본적으로 `PropertiesRouteDefinitionLocator`는 스프링 부트의 `@ConfigurationProperties` 메커니즘을 통해 프로퍼티를 로드한다.

앞에서 보여준 설정 예시에선 모두 인자들을 이름을 지정하지 않고, 위치로 인자를 찾는 shortcut 표기법을 사용했다. 다음 두 예시는 동일한 설정이다:

**Example 64. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: setstatus_route
        uri: https://example.org
        filters:
        - name: SetStatus
          args:
            status: 401
      - id: setstatusshortcut_route
        uri: https://example.org
        filters:
        - SetStatus=401
```

게이트웨이의 사용 사례에 따라 프로퍼티로도 충분할 수 있지만, 프로덕션에선 데이터베이스같은 외부 소스에서 설정을 로드하는 게 더 좋을 수도 있다. 향후 마일스톤 버전에는 Redis, MongoDB, Cassandra같은 Spring Data Repositories 기반 `RouteDefinitionLocator` 구현체가 몇 가지 추가될 거다.