---
title: Documentation Overview
category: Spring Boot
order: 4
permalink: /Spring%20Boot/documentation-overview/
description: 스프링 부트 레퍼런스 문서의 개요와 길라잡이
image: ./../../images/springboot/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 부트
originalRefLink: https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#documentation
---

### 목차

- [3.1. First Steps](#31-first-steps)
- [3.2. Upgrading From an Earlier Version](#32-upgrading-from-an-earlier-version)
- [3.3. Developing with Spring Boot](#33-developing-with-spring-boot)
- [3.4. Learning About Spring Boot Features](#34-learning-about-spring-boot-features)
- [3.5. Moving to Production](#35-moving-to-production)
- [3.6. Advanced Topics](#36-advanced-topics)

---

이 섹션은 스프링 부트 레퍼런스 문서에 대한 짤막한 개요를 제공한다. 이 문서의 길잡이가 되어줄 것이다.

이 문서의 최신 버전은 [docs.spring.io/spring-boot/docs/current/reference/](https://docs.spring.io/spring-boot/docs/current/reference/)에서 확인할 수 있다.

---

## 3.1. First Steps

스프링 부트나 '스프링' 자체가 처음이라면 [아래 토픽들](../getting-started)부터 시작해봐라:

- **밑바닥부터:** [개요](../getting-started#41-introducing-spring-boot) \| [요구사항](../getting-started#42-system-requirements) \| [설치](../getting-started#43-installing-spring-boot)
- **튜토리얼:** [Part 1](../getting-started#44-developing-your-first-spring-boot-application) \| [Part 2](../getting-started#443-writing-the-code)
- **예제 실행해보기:** [Part 1](../getting-started#444-running-the-example) \| [Part 2](../getting-started#445-creating-an-executable-jar)

---

## 3.2. Upgrading From an Earlier Version

스프링 부트는 항상 [지원하는 버전](https://github.com/spring-projects/spring-boot/wiki/Supported-Versions)으로 실행하고 있는지 확인하는 게 좋다.

다음 링크에선 업그레이드하고자 하는 버전에 따라 몇 가지 추가 팁을 얻을 수 있다:

- **From 1.x:** [1.x에서 업그레이드하기](../upgrading-spring-boot#51-upgrading-from-1x)
- **To a new feature release:** [새 피처 릴리즈로 업그레이드하기](../upgrading-spring-boot#52-upgrading-to-a-new-feature-release)
- **Spring Boot CLI:** [스프링 부트 CLI 업그레이드하기](../upgrading-spring-boot#53-upgrading-the-spring-boot-cli)

---

## 3.3. Developing with Spring Boot

스프링 부트를 실제로 사용해볼 준비가 됐는가? [이 문서에선 다음과 같은 내용을 다룬다](../developing-with-spring-boot)

- **빌드 시스템:** [Maven](../developing-with-spring-boot#612-maven) \| [Gradle](../developing-with-spring-boot#613-gradle) \| [Ant](../developing-with-spring-boot#614-ant) \| [Starters](../developing-with-spring-boot#615-starters)
- **베스트 프랙티스:** [코드 구조](../developing-with-spring-boot#62-structuring-your-code) \| [@Configuration](../developing-with-spring-boot#63-configuration-classes) \| [@EnableAutoConfiguration](../developing-with-spring-boot#64-auto-configuration) \| [빈과 의존성 주입](../developing-with-spring-boot#65-spring-beans-and-dependency-injection)
- **코드 실행하기:** [IDE](../developing-with-spring-boot#671-running-from-an-ide) \| [Packaged](../developing-with-spring-boot#672-running-as-a-packaged-application) \| [Maven](../developing-with-spring-boot#673-using-the-maven-plugin) \| [Gradle](../developing-with-spring-boot#674-using-the-gradle-plugin)
- **애플리케이션 패키징하기:** [프로덕션 jars](../developing-with-spring-boot#69-packaging-your-application-for-production)
- **스프링 부트 CLI:** [CLI 사용하기](../spring-boot-cli)

---

## 3.4. Learning About Spring Boot Features

스프링 부트의 핵심 기능을 자세히 알고 싶은가? [다음과 같은 내용들이 준비돼 있다](../spring-boot-features):

- **핵심 기능:** [SpringApplication](../spring-application) \| [외부 설정](../externalized-configuration) \| [프로파일](../profiles) \| [로깅](../logging)
- **웹 애플리케이션:** [MVC](../developing-web-applications#771-the-spring-web-mvc-framework) \| [임베디드 컨테이너](../developing-web-applications#774-embedded-servlet-container-support)
- **데이터 다루기:** [SQL](../working-with-sql-databases) \| [NO-SQL](../working-with-nosql-technologies)
- **메세지 처리:** [개요](../messaging) \| [JMS](../messaging#7141-jms)
- **테스트:** [개요](../testing) \| [부트 애플리케이션](../testing#7263-testing-spring-boot-applications) \| [유틸리티](../testing#7264-test-utilities)
- **익스텐션:** [자동 설정](../creating-your-own-auto-configuration) \| [@Conditions](../creating-your-own-auto-configuration#7293-condition-annotations)

---

## 3.5. Moving to Production

스프링 부트 애플리케이션을 프로덕션으로 내보낼 준비가 됐다면, 마음에 들만한 [몇 가지 트릭들](../spring-boot-actuator)을 제공한다:

- **Management 엔드포인트:** [개요](../endpoints)
- **커넥션 옵션:** [HTTP](../monitoring-and-management-over-http) \| [JMX](../actuator.monitoring-and-management-over-jmx)
- **모니터링:** [메트릭](../metrics) \| [Auditing](../auditing) \| [HTTP 트레이싱](../http-tracing) \| [프로세스](../process-monitoring)

---

## 3.6. Advanced Topics

마지막으로, 좀 더 많은 것들을 해보고 싶은 사용자는 아래 토픽들을 살펴봐도 좋다:

- **스프링 부트 애플리케이션 배포:** [클라우드 배포](../deploying-spring-boot-applications#92-deploying-to-the-cloud) \| [OS 서비스](../deploying-spring-boot-applications#932-unixlinux-services)
- **빌드 툴 플러그인:** [메이븐](../build-tool-plugins#111-spring-boot-maven-plugin) \| [그래들](../build-tool-plugins#112-spring-boot-gradle-plugin)
- **부록:** [애플리케이션 프로퍼티](https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#application-properties) \| [설정 메타데이터](https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#configuration-metadata) \| [자동 설정 클래스들](https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#auto-configuration-classes) \| [테스트 자동 설정 어노테이션들](https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#test-auto-configuration) \| [실행 가능한 jar 파일<sup>Executable Jars</sup>](https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#executable-jar) \| [의존성 버전들](https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#dependency-versions)

