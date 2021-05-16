---
title: Configuring Route Predicate Factories and Gateway Filter Factories
category: Spring Cloud Gateway
order: 5
permalink: /Spring%20Cloud%20Gateway/configuring-route-predicate-factories-and-gateway-filter-factories/
description: Route Predicate 팩토리와 Gateway Filter 팩토리를 설정하는 방법
image: ./../../images/springcloud/logo.jpeg
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: 스프링 클라우드 게이트웨이
originalRefLink: https://docs.spring.io/spring-cloud-gateway/docs/3.0.2/reference/html/#configuring-route-predicate-factories-and-gateway-filter-factories
---

### 목차

- [4.1. Shortcut Configuration](#41-shortcut-configuration)
- [4.2. Fully Expanded Arguments](#42-fully-expanded-arguments)

---

predicate와 필터를 구성하는 방법은 **shortcut**(한 문장에 명시) 방식과 **fully expanded arguments**(모든 인자를 직접 지정) 방식 두 가지가 있다. 이 문서에 나오는 예시에선 대부분 shortcut 방식을 사용한다.

이름과 인자명들은 첫 문장에 규칙에 따라 나열하거나, 각 섹션에 나누어 명시한다. shortcut 설정에선 보통 인자를 필요한 순서대로 나열한다.

---

## 4.1. Shortcut Configuration

Shortcut 설정은 필터 이름, 등호(`=`), 콤마(`,`)로 구분하는 인자 값들 순으로 인식된다.

**application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: after_route
        uri: https://example.org
        predicates:
        - Cookie=mycookie,mycookievalue
```

위에 있는 샘플에선 쿠키명 `mycookie`, 매칭할 값 `mycookievalue`, 이 두 인자로 `Cookie` Route Predicate Factory를 정의한다.

---

## 4.2. Fully Expanded Arguments

Fully expanded arguments는 이름/값 쌍을 가진 표준 yaml 설정과 유사하다. 보통은 `name` 키와 `args` 키를 가진다. `args` 키는 predicate나 필터를 구성하는데 필요한 키/값 쌍의 맵이다.

**application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: after_route
        uri: https://example.org
        predicates:
        - name: Cookie
          args:
            name: mycookie
            regexp: mycookievalue
```

이 파일은 위에서 보여준 `Cookie` predicate shortcut 설정을 전부 나타낸 설정이다.