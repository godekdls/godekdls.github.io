---
title: Monitoring and Management over JMX
category: Spring Boot 2.X
order: 45
permalink: /Spring%20Boot/actuator.monitoring-and-management-over-jmx/
description: 액추에이터 엔드포인트를 JMX로 노출하기
image: ./../../images/springboot/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 부트
originalRefLink: https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#actuator.jmx
parent: Spring Boot Actuator
parentUrl: /Spring%20Boot/spring-boot-actuator/
priority: 0.4
---
<script>defaultLanguages = ['properties']</script>

### 목차

- [8.4.1. Customizing MBean Names](#841-customizing-mbean-names)
- [8.4.2. Disabling JMX Endpoints](#842-disabling-jmx-endpoints)
- [8.4.3. Using Jolokia for JMX over HTTP](#843-using-jolokia-for-jmx-over-http)
  + [Customizing Jolokia](#customizing-jolokia)
  + [Disabling Jolokia](#disabling-jolokia)

---

## 8.4. Monitoring and Management over JMX

JMX<sup>Java Management Extensions</sup>는 애플리케이션을 모니터링하고 관리할 수 있는 표준 메커니즘을 제공한다. 기본적으로 이 기능은 활성화하지 않으며, 설정 프로퍼티 `spring.jmx.enabled`를 `true`로 설정하면 켤 수 있다. 스프링 부트는 기본적으로 `org.springframework.boot` 도메인 아래에 JMX MBean으로 management 엔드포인트를 노출한다. JMX 도메인에 엔드포인트를 등록하는 로직을 전부 직접 제어하려면 자체 `EndpointObjectNameFactory` 구현체를 등록하는 걸 검토해봐라.

### 8.4.1. Customizing MBean Names

보통 MBean의 이름은 엔드포인트의 `id`로 만들어진다. 예를 들어 `health` 엔드포인트는 `org.springframework.boot:type=Endpoint,name=Health`로 노출된다.

애플리케이션에 스프링 `ApplicationContext`가 둘 이상일 땐 MBean 이름이 충돌할 수도 있다. 이럴 땐 `spring.jmx.unique-names` 프로퍼티를 `true`로 설정해서 MBean 이름들을 항상 유니크하게 만들어주면 된다.

엔드포인트를 노출할 JMX 도메인을 커스텀할 수도 있다. 아래 `application.properties`를 참고해라:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.jmx.unique-names=true
management.endpoints.jmx.domain=com.example.myapp
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  jmx:
    unique-names: true
management:
  endpoints:
    jmx:
      domain: "com.example.myapp"
```

### 8.4.2. Disabling JMX Endpoints

엔드포인트들을 JMX로 노출하지 않고 싶다면 다음 예제처럼 `management.endpoints.jmx.exposure.exclude` 프로퍼티를 `*`로 설정하면 된다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
management.endpoints.jmx.exposure.exclude=*
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
management:
  endpoints:
    jmx:
      exposure:
        exclude: "*"
```

### 8.4.3. Using Jolokia for JMX over HTTP

Jolokia는 JMX 빈에 접근하는 또다른 방법을 제공하는 JMX-HTTP bridge다. Jolokia를 사용하려면 `org.jolokia:jolokia-core` 의존성을 추가해라. 예를 들어 메이븐에선 아래 의존성을 추가하면 된다:

```xml
<dependency>
    <groupId>org.jolokia</groupId>
    <artifactId>jolokia-core</artifactId>
</dependency>
```

그런 다음 `management.endpoints.web.exposure.include` 프로퍼티에 `jolokia`나 `*`을 추가하면 Jolokia 엔드포인트를 노출할 수 있다. 그러면 management HTTP 서버에서 `/actuator/jolokia`를 사용해 액세스할 수 있다.

> Jolokia 엔드포인트는 Jolokia의 서블릿을 액추에이터 엔드포인트로 노출한다. 따라서 Jolokia 엔드포인트는 스프링 MVC와 Jersey같은 서블릿 환경 전용이다. 웹플럭스 애플리케이션에선 이 엔드포인트를 사용할 수 없다.

#### Customizing Jolokia

Jolokia는 전통적인 서블릿 파라미터를 이용해 세팅할 수 있는 여러 가지 설정을 가지고 있다. 스프링 부트에서는 `application.properties` 파일을 사용하면 된다. 다음 예제처럼 파라미터 앞에 `management.endpoint.jolokia.config.`를 붙여주면 된다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
management.endpoint.jolokia.config.debug=true
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
management:
  endpoint:
    jolokia:
      config:
        debug: true
```

#### Disabling Jolokia

Jolokia를 사용하긴 하지만 스프링 부트에서 설정하는 건 싫다면 다음과 같이 `management.endpoint.jolokia.enabled` 프로퍼티를 `false`로 설정해라:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
management.endpoint.jolokia.enabled=false
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
management:
  endpoint:
    jolokia:
      enabled: false
```
