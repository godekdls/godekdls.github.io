---
title: Reactor Netty Access Logs
category: Spring Cloud Gateway
order: 14
permalink: /Spring%20Cloud%20Gateway/reactor-netty-access-logs/
description: 리액터 네티 액세스 로그 설정 방법 한글 번역
image: ./../../images/springcloud/logo.jpeg
lastmod: 2021-04-06T22:00:00+09:00
comments: true
originalRefName: 스프링 클라우드 게이트웨이
originalRefLink: https://docs.spring.io/spring-cloud-gateway/docs/3.0.2/reference/html/#reactor-netty-access-logs
---

---

리액터 네티 액세스 로그를 활성화하려면 `-Dreactor.netty.http.server.accessLogEnabled=true`를 설정해라.

> 스프링 부트 프로퍼티가 아닌 자바 시스템 프로퍼티를 설정해야 한다.

로깅 시스템에서 액세스 로그 파일을 별도로 만들게 설정할 수도 있다. 다음은 Logback 설정 예시다:

**Example 68. logback.xml**

```xml
    <appender name="accessLog" class="ch.qos.logback.core.FileAppender">
        <file>access_log.log</file>
        <encoder>
            <pattern>%msg%n</pattern>
        </encoder>
    </appender>
    <appender name="async" class="ch.qos.logback.classic.AsyncAppender">
        <appender-ref ref="accessLog" />
    </appender>

    <logger name="reactor.netty.http.server.AccessLog" level="INFO" additivity="false">
        <appender-ref ref="async"/>
    </logger>
```