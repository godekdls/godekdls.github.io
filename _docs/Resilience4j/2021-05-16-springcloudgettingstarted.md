---
title: Spring cloud Getting Started
navTitle: Getting Started
category: Resilience4j
order: 25
permalink: /Resilience4j/spring-cloud-getting-started/
description: 스프링 클라우드 2와 Resilience4j를 통합하는 방법 소개
image: ./../../images/resilience4j/logo.jpeg
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: resilience4j
originalRefLink: https://resilience4j.readme.io/v1.7.0/docs/getting-started-6
boundary: SPRING CLOUD
---

### 목차

- [Setup](#setup)
- [Demo](#demo)

---

## Setup

Resilience4j의 Spring Cloud 2 Starter를 컴파일 의존성으로 추가해라.<br>Spring Cloud 2 Starter를 사용하면 Spring Cloud Config를 중심으로 프로퍼티를 관리하고 런타임에 리프레시할 수 있다.

이 모듈은 런타임에 `org.springframework.boot:spring-boot-starter-actuator`와 `org.springframework.boot:spring-boot-starter-aop`를 제공해준다고 가정한다.

```gradle
repositories {
    jCenter()
}

dependencies {
    compile "io.github.resilience4j:resilience4j-spring-cloud2:${resilience4jVersion}"
    compile('org.springframework.boot:spring-boot-starter-actuator')
    compile('org.springframework.boot:spring-boot-starter-aop')
    compile('org.springframework.cloud:spring-cloud-starter-config')  
}
```

설정은 Spring Boot 2 Starter와 유사하다.

---

## Demo

스프링 클라우드 2 환경 설정과 사용 방법은 [demo](https://github.com/resilience4j/resilience4j-spring-cloud2-demo)에서 시연하고 있다.