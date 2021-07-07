---
title: Graceful shutdown
category: Spring Boot
order: 16
permalink: /Spring%20Boot/graceful-shutdown/
description: 스프링 부트 애플리케이션 서버에 graceful shutdown 적용하기
image: ./../../images/springboot/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 부트
originalRefLink: https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#features.graceful-shutdown
parent: Spring Boot Features
parentUrl: /Spring%20Boot/spring-boot-features/
---
<script>defaultLanguages = ['properties']</script>

---

## 7.8. Graceful shutdown

네 가지 임베디드 웹 서버(Jetty, Reactor Netty, Tomcat, Undertow)와, 리액티브 및 서블릿 기반 웹 애플리케이션 모두 graceful 셧다운을 지원한다. graceful 셧다운은 애플리케이션 컨텍스트를 닫는 과정에서 발생하며, `SmartLifecycle` 빈을 중지하는 가장 초기 단계에서 수행한다. 이 중지 프로세스에선 타임아웃을 사용해서 기존 요청은 완료할 수 있도록 두지만, 새로운 요청은 허용하지 않는 유예 기간을 둔다. 새 요청을 거부하는 정확한 방식은 사용하는 웹 서버에 따라 다르다. Jetty, Reactor Netty, Tomcat은 네트워크 계층에서 더 이상 요청을 수락하지 않는다. Undertow는 요청을 수락하지만, 곧바로 service unavailable(503) 응답을 보낸다.

> 톰캣에서 graceful 셧다운을 사용하려면 톰캣 9.0.33 이상이 필요하다.

graceful 셧다운을 활성화하려면 다음 예시처럼 `server.shutdown` 프로퍼티를 설정해라:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
server.shutdown=graceful
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
server:
  shutdown: "graceful"
```

타임아웃 기간을 설정하려면 다음 예시처럼 `spring.lifecycle.timeout-per-shutdown-phase` 프로퍼티를 설정해라:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.lifecycle.timeout-per-shutdown-phase=20s
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  lifecycle:
    timeout-per-shutdown-phase: "20s"
```

> IDE에선 적절한 `SIGTERM` 시그널을 전송하지 않으면 graceful 셧다운이 제대로 동작하지 않을 수 있다. 자세한 내용은 IDE 문서를 참고해라.