---
title: Spring Session
category: Spring Boot
order: 32
permalink: /Spring%20Boot/spring-session/
description: 스프링 부트로 스프링 세션 자동 설정하기
image: ./../../images/springboot/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 부트
originalRefLink: https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#features.spring-session
parent: Spring Boot Features
parentUrl: /Spring%20Boot/spring-boot-features/
---
<script>defaultLanguages = ['properties']</script>

---

## 7.24. Spring Session

스프링 부트는 다양한 데이터 저장소를 위한 [Spring Session](https://spring.io/projects/spring-session) 자동 설정을 제공한다. 서블릿 웹 애플리케이션을 개발할 때는 아래와 같은 저장소를 자동 설정할 수 있다:

- JDBC
- Redis
- Hazelcast
- MongoDB

서블릿 자동 설정을 이용하면 `@Enable*HttpSession`은 사용할 필요 없다.

리액티브 웹 애플리케이션을 개발할 때는 아래 저장소를 자동 설정할 수 있다:

- Redis
- MongoDB

리액티브 자동 설정을 이용하면 `@Enable*WebSession`은 사용할 필요 없다.

클래스패스에 스프링 세션 모듈이 딱 하나 있을 땐 스프링 부트는 자동으로 해당 저장소 구현체를 사용한다. 구현체가 둘 이상 있을 때는 세션을 저장할 [`StoreType`](https://github.com/spring-projects/spring-boot/tree/v2.5.2/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/session/StoreType.java)을 선택해야 한다. 예를 들어 JDBC를 백엔드 저장소로 사용하려면 애플리케이션을 다음과 같이 설정하면 된다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.session.store-type=jdbc
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  session:
    store-type: "jdbc"
```

> `store-type`을 `none`으로 설정하면 스프링 세션을 비활성화할 수 있다.

각 저장소마다 별도 설정들을 가지고 있다. 예를 들어 다음 예제처럼 JDBC 저장소에서 사용할 테이블 이름을 커스텀할 수 있다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.session.jdbc.table-name=SESSIONS
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  session:
    jdbc:
      table-name: "SESSIONS"
```

세션 타임아웃을 설정하고 싶을 땐 `spring.session.timeout` 프로퍼티를 사용할 수 있다. 서블릿 웹 어플리케이션에서 이 프로퍼티를 설정하지 않으면 자동 설정에선 `server.servlet.session.timeout` 값으로 폴백한다.

`@Enable*HttpSession`(서블릿) 또는 `@Enable*WebSession`(리액티브)을 사용하면 스프링 세션 설정을 직접 제어할 수 있다. 이 어노테이션을 사용하면 자동 설정은 취소된다. 이때는 앞에서 설명한 설정 프로퍼티 대신 어노테이션의 속성을 사용해서 스프링 세션을 설정할 수 있다.