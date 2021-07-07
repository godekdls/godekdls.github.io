---
title: Monitoring and Management over HTTP
category: Spring Boot
order: 44
permalink: /Spring%20Boot/monitoring-and-management-over-http/
description: 액추에이터 path, 포트, 주소, ssl 커스텀하기
image: ./../../images/springboot/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 부트
originalRefLink: https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#actuator.monitoring
parent: Spring Boot Actuator
parentUrl: /Spring%20Boot/spring-boot-actuator/
---
<script>defaultLanguages = ['properties']</script>

### 목차

- [8.3.1. Customizing the Management Endpoint Paths](#831-customizing-the-management-endpoint-paths)
- [8.3.2. Customizing the Management Server Port](#832-customizing-the-management-server-port)
- [8.3.3. Configuring Management-specific SSL](#833-configuring-management-specific-ssl)
- [8.3.4. Customizing the Management Server Address](#834-customizing-the-management-server-address)
- [8.3.5. Disabling HTTP Endpoints](#835-disabling-http-endpoints)

---

## 8.3. Monitoring and Management over HTTP

웹 애플리케이션을 개발하고 있다면 스프링 부트 액추에이터는 활성화한 모든 엔드포인트를 HTTP를 통해 노출하도록 자동 설정한다. URL 경로의 디폴트 컨벤션은 엔드포인트 `id` 앞에 `/actuator`를 붙이는 거다. 예를 들어 `health`는 `/actuator/health`로 노출한다.

> 액추에이터는 스프링 MVC, 스프링 웹플럭스, Jersey를 기본으로 지원한다. Jersey와 스프링 MVC가 둘 다 있을 때는 스프링 MVC를 사용한다.

> Jackson은 API 문서에서도 설명하고 있지만 ([HTML](https://docs.spring.io/spring-boot/docs/2.5.2/actuator-api/htmlsingle), [PDF](https://docs.spring.io/spring-boot/docs/2.5.2/actuator-api/pdf/spring-boot-actuator-web-api.pdf)), 적절한 JSON 응답을 만들기 위한 필수 의존성이다.

### 8.3.1. Customizing the Management Endpoint Paths

가끔은 management 엔드포인트에 사용할 프리픽스를 커스텀하면 유용할 때가 있다. 예를 들어, `/actuator`를 이미 다른 용도로 사용하고 있을 수도 있다. 다음 예시처럼 `management.endpoints.web.base-path` 프로퍼티를 사용하면 management 엔드포인트의 프리픽스를 변경할 수 있다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
management.endpoints.web.base-path=/manage
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
management:
  endpoints:
    web:
      base-path: "/manage"
```

위에 있는 `application.properties`는 엔드포인트를 `/actuator/{id}`에서 `/manage/{id}`로 변경하고 있다 (ex. `/manage/info`).

> [엔드포인트들을 다른 HTTP 포트로 노출하도록](#832-customizing-the-management-server-port) management 포트를 설정하지 않았다면, `management.endpoints.web.base-path`는 `server.servlet.context-path`(서블릿 웹 애플리케이션)이나 `spring.webflux.base-path`(리액티브 웹 애플리케이션)의 상대 경로다. `management.server.port`를 설정했다면 `management.endpoints.web.base-path`는 `management.server.base-path`의 상대 경로다.

엔드포인트를 다른 경로로 매핑하고 싶다면 `management.endpoints.web.path-mapping` 프로퍼티를 사용하면 된다.

아래 예시는 `/actuator/health`를 `/healthcheck`로 변경한다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
management.endpoints.web.base-path=/
management.endpoints.web.path-mapping.health=healthcheck
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
management:
  endpoints:
    web:
      base-path: "/"
      path-mapping:
        health: "healthcheck"
```

### 8.3.2. Customizing the Management Server Port

디폴트 HTTP 포트로 management 엔드포인트를 노출하는 건 클라우드 기반 배포에선 괜찮은 선택이다. 하지만 애플리케이션을 자체 데이터 센터 내에서 실행한다면 다른 HTTP 포트로 엔드포인트를 노출하고 싶을 수도 있다.

HTTP 포트를 변경하려면 `management.server.port` 프로퍼티를 아래 예시처럼 설정하면 된다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
management.server.port=8081
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
management:
  server:
    port: 8081
```

> Cloud Foundry에선 기본적으로 애플리케이션은 HTTP와 TCP 라우팅 모두 8080 포트에서만 요청을 받는다. Cloud Foundry에서 커스텀 management 포트를 사용하고 싶다면, 커스텀 포트로 트래픽을 전달하도록 애플리케이션의 라우트를 명시해야 한다.

### 8.3.3. Configuring Management-specific SSL

커스텀 포트를 사용하도록 설정했다면, 다양한 `management.server.ssl.*` 프로퍼티를 사용해 management 서버에 자체 SSL을 구성할 수도 있다. 예를 들어 아래 보이는 프로퍼티 설정을 사용하면 메인 애플리케이션은 HTTPS를 사용하면서 management 서버는 HTTP를 통해 이용할 수 있다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
server.port=8443
server.ssl.enabled=true
server.ssl.key-store=classpath:store.jks
server.ssl.key-password=secret
management.server.port=8080
management.server.ssl.enabled=false
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
server:
  port: 8443
  ssl:
    enabled: true
    key-store: "classpath:store.jks"
    key-password: secret
management:
  server:
    port: 8080
    ssl:
      enabled: false
```

아니면 메인 서버와 management 서버 모두 SSL을 사용하되, 키 스토어는 다르게 설정할 수도 있다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
server.port=8443
server.ssl.enabled=true
server.ssl.key-store=classpath:main.jks
server.ssl.key-password=secret
management.server.port=8080
management.server.ssl.enabled=true
management.server.ssl.key-store=classpath:management.jks
management.server.ssl.key-password=secret
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
server:
  port: 8443
  ssl:
    enabled: true
    key-store: "classpath:main.jks"
    key-password: "secret"
management:
  server:
    port: 8080
    ssl:
      enabled: true
      key-store: "classpath:management.jks"
      key-password: "secret"
```

### 8.3.4. Customizing the Management Server Address

`management.server.address` 프로퍼티를 설정하면 management 엔드포인트를 이용할 수 있는 주소를 커스텀할 수 있다. 내부 네트워크에서만 수신<sup>listen</sup>하거나, 네트워크 운영 센터나 `localhost`에서만 커넥션을 맺을 수 있게하려는 경우에 유용할 거다.

> 메인 서버 포트와 다른 포트를 사용할 때에만 다른 주소에서 수신할 수 있다.

아래 있는 `application.properties`에선, 원격에서 management에 커넥션을 맺을 수 없다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
management.server.port=8081
management.server.address=127.0.0.1
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
management:
  server:
    port: 8081
    address: "127.0.0.1"
```

### 8.3.5. Disabling HTTP Endpoints

엔드포인트들을 HTTP로 노출하지 않고 싶다면 다음 예제처럼 management 포트를 `-1`로 설정하면 된다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
management.server.port=-1
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
management:
  server:
    port: -1
```

다음 예제처럼 `management.endpoints.web.exposure.exclude` 프로퍼티를 사용해도 노출을 비활성화할 수 있다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
management.endpoints.web.exposure.exclude=*
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
management:
  endpoints:
    web:
      exposure:
        exclude: "*"
```
