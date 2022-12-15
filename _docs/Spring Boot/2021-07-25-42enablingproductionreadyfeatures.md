---
title: Enabling Production-ready Features
category: Spring Boot 2.X
order: 42
permalink: /Spring%20Boot/enabling-production-ready-features/
description: 스프링 부트 프로젝트에서 액추에이터 기능을 활성화하는 방법
image: ./../../images/springboot/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 부트
originalRefLink: https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#actuator.enabling
parent: Spring Boot Actuator
parentUrl: /Spring%20Boot/spring-boot-actuator/
priority: 0.4
---

### 목차

- [8.1. Enabling Production-ready Features](#81-enabling-production-ready-features)

---

## 8.1. Enabling Production-ready Features

스프링 부트의 production-ready feature는 전부 [`spring-boot-actuator`](https://github.com/spring-projects/spring-boot/tree/v2.5.2/spring-boot-project/spring-boot-actuator) 모듈에 들어있다. 이 기능들은 `spring-boot-starter-actuator` '스타터' 의존성을 추가해서 활성화하는 게 좋다.

> #### 액추에이터의 정의
>
> 액추에이터는 제조업에서 쓰이는 용어로, 무언가를 움직이거나 제어하기 위한 기계적인 장치를 지칭한다. 액추에이터는 작은 변화로도 많은 움직임들을 만들어낼 수 있다.

메이븐 기반 프로젝트에 액추에이터를 추가하려면 다음과 같이 '스타터' 의존성을 넣어라:

```xml
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-actuator</artifactId>
    </dependency>
</dependencies>
```

그래들은 다음과 같이 선언하면 된다:

```gradle
dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-actuator'
}
```