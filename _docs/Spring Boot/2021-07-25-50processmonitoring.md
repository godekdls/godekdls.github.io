---
title: Process Monitoring
category: Spring Boot
order: 50
permalink: /Spring%20Boot/process-monitoring/
description: 스프링 부트 애플리케이션 프로세스 모니터링하기
image: ./../../images/springboot/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 부트
originalRefLink: https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#actuator.process-monitoring
parent: Spring Boot Actuator
parentUrl: /Spring%20Boot/spring-boot-actuator/
---

### 목차

- [8.9.1. Extending Configuration](#891-extending-configuration)
- [8.9.2. Programmatically](#892-programmatically)

---

## 8.9. Process Monitoring

`spring-boot` 모듈에선, 프로세스를 모니터링할 때 보통 유용한 파일을 생성해주는 두 가지 클래스를 찾을 수 있다:

- `ApplicationPidFileWriter`는 애플리케이션 PID를 가지고 있는 파일을 생성한다 (기본적으로 애플리케이션 디렉토리 아래 `application.pid`라는 이름으로).
- `WebServerPortFileWriter`는 실행 중인 웹 서버의 포트를 가지고 있는 파일(여러 개일수 있음)을 생성한다 (기본적으로 애플리케이션 디렉토리 아래 `application.port`라는 이름으로).

이 두 writer는 기본적으론 활성화되지 않지만, 아래 방법으로 활성화할 수 있다:

- [외부 설정으로](#891-extending-configuration)
- [코드로](#892-programmatically)

### 8.9.1. Extending Configuration

아래 예시처럼 `META-INF/spring.factories` 파일에서 PID 파일을 작성하는 리스너를 활성화할 수 있다:

```
org.springframework.context.ApplicationListener=\
org.springframework.boot.context.ApplicationPidFileWriter,\
org.springframework.boot.web.context.WebServerPortFileWriter
```

### 8.9.2. Programmatically

`SpringApplication.addListeners(…)` 메소드를 호출해 원하는 `Writer` 객체를 전달해도 리스너를 활성화할 수 있다. 이때는 `Writer` 생성자에서 파일 이름과 경로를 커스텀하는 것도 가능하다.