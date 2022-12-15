---
title: Spring Integration
category: Spring Boot 2.X
order: 31
permalink: /Spring%20Boot/spring-integration/
description: 스프링 부트로 Spring Integration 자동 설정하기
image: ./../../images/springboot/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 부트
originalRefLink: https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#features.spring-integration
parent: Spring Boot Features
parentUrl: /Spring%20Boot/spring-boot-features/
priority: 0.4
---
<script>defaultLanguages = ['properties']</script>

---

## 7.23. Spring Integration

스프링 부트를 사용하면 `spring-boot-starter-integration` "스타터"를 활용하는 등, [Spring Integration](https://spring.io/projects/spring-integration) 작업을 좀 더 수월하게 진행할 수 있다. Spring Integration은 메세지 처리나 HTTP, TCP 등과 같은 전송 로직을 추상화해준다. 클래스패스에 Spring Integration이 있으면 `@EnableIntegration` 어노테이션을 통해 초기화된다.

Spring Integration 폴링 로직은 [자동 설정된 `TaskScheduler`](../task-execution-and-scheduling)를 사용한다.

스프링 부트는 그밖의 Spring Integration 모듈이 있으면 몇 가지 다른 기능들도 설정한다. 클래스패스에 `spring-integration-jmx`도 있으면 JMX를 통해 메세지 처리 통계를 게시한다. `spring-integration-jdbc`가 있을 땐 아래처럼 기동 시에 디폴트 데이터베이스 스키마를 생성할 수 있다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.integration.jdbc.initialize-schema=always
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  integration:
    jdbc:
      initialize-schema: "always"
```

`spring-integration-rsocket`이 있을 땐 `"spring.rsocket.server.*"` 프로퍼티를 사용해서 RSocket 서버를 구성하고, `IntegrationRSocketEndpoint`나 `RSocketOutboundGateway` 컴포넌트를 사용해서 수신하는 RSocket 메세지를 처리할 수 있다. 여기에선 Spring Integration RSocket 채널 어댑터와 `@MessageMapping` 핸들러를 처리할 수 있다 ( `"spring.integration.rsocket.server.message-mapping-enabled"`를 설정하면).

스프링 부트에선 `ClientRSocketConnector`도 설정 프로퍼티를 통해 자동 설정할 수 있다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
# Connecting to a RSocket server over TCP
spring.integration.rsocket.client.host=example.org
spring.integration.rsocket.client.port=9898
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
# Connecting to a RSocket server over TCP
spring:
  integration:
    rsocket:
      client:
        host: "example.org"
        port: 9898
```

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
# Connecting to a RSocket Server over WebSocket
spring.integration.rsocket.client.uri=ws://example.org
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
# Connecting to a RSocket Server over WebSocket
spring:
  integration:
    rsocket:
      client:
        uri: "ws://example.org"
```

자세한 내용은 [`IntegrationAutoConfiguration`](https://github.com/spring-projects/spring-boot/tree/v2.5.2/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/integration/IntegrationAutoConfiguration.java)과 [`IntegrationProperties`](https://github.com/spring-projects/spring-boot/tree/v2.5.2/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/integration/IntegrationProperties.java) 클래스를 참고해라.

기본적으로 Micrometer `meterRegistry` 빈이 있으면 Spring Integration 메트릭은 Micrometer에서 관리한다. 레거시 Spring Integration 메트릭을 사용하려면 애플리케이션 컨텍스트에 `DefaultMetricsFactory` 빈을 하나 추가해라.
