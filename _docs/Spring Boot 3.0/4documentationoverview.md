---
title: Documentation Overview
category: Spring Boot 3.0
order: 4
permalink: /Spring%20Boot/3.x/documentation-overview/
description: 스프링 부트 레퍼런스 문서의 개요와 길라잡이
image: ./../../../images/springboot/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 부트
originalRefLink: https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#documentation
---

### 목차

- [3.1. First Steps](#31-first-steps)
- [3.2. Upgrading From an Earlier Version](#32-upgrading-from-an-earlier-version)
- [3.3. Developing with Spring Boot](#33-developing-with-spring-boot)
- [3.4. Learning About Spring Boot Features](#34-learning-about-spring-boot-features)
- [3.5. Web](#35-moving-to-production)
- [3.6. Data](#36-data)
- [3.7. Messaging](#37-messaging)
- [3.8. IO](#38-io)
- [3.9. Container Images](#39-container-images)
- [3.10. GraalVM Native Images](#310-graalvm-native-images)
- [3.11. Advanced Topics](#311-advanced-topics)

---

이 섹션은 스프링 부트 레퍼런스 문서에 대한 짤막한 개요를 제공한다. 이 문서의 길잡이가 되어줄 것이다.

이 문서의 최신 버전은 [docs.spring.io/spring-boot/docs/current/reference/](https://docs.spring.io/spring-boot/docs/current/reference/)에서 확인할 수 있다.

---

## 3.1. First Steps

스프링 부트나 '스프링' 자체가 처음이라면 [아래 토픽들](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#getting-started)부터 시작해봐라:

- **밑바닥부터:** [개요](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#getting-started.introducing-spring-boot) \| [요구사항](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#getting-started.system-requirements) \| [설치](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#getting-started.installing)
- **튜토리얼:** [Part 1](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#getting-started.first-application) \| [Part 2](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#getting-started.first-application.code)
- **예제 실습:** [Part 1](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#getting-started.first-application.run) \| [Part 2](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#getting-started.first-application.executable-jar)

---

## 3.2. Upgrading From an Earlier Version

스프링 부트는 [지원하는 버전](https://github.com/spring-projects/spring-boot/wiki/Supported-Versions)으로 실행하고 있는지 항상 확인해주는 게 좋다.

아래 있는 링크에선 업그레이드하고자 하는 버전에 따라 몇 가지 추가 팁을 얻을 수 있다:

- **From 1.x:** [1.x에서 업그레이드하기](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#upgrading.from-1x)
- **To a new feature release:** [새 피처 릴리즈로 업그레이드하기](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#upgrading.to-feature)
- **Spring Boot CLI:** [스프링 부트 CLI 업그레이드하기](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#upgrading.cli)

---

## 3.3. Developing with Spring Boot

스프링 부트를 실제로 사용해볼 준비가 됐는가? [이 문서에선 다음과 같은 내용을 다룬다](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#using):

- **빌드 시스템:** [Maven](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#using.build-systems.maven) \| [Gradle](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#using.build-systems.gradle) \| [Ant](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#using.build-systems.ant) \| [Starters](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#using.build-systems.starters)
- **베스트 프랙티스:** [코드 구조](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#using.structuring-your-code) \| [@Configuration](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#using.configuration-classes) \| [@EnableAutoConfiguration](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#using.auto-configuration) \| [빈과 의존성 주입](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#using.spring-beans-and-dependency-injection)
- **코드 실행하기:** [IDE](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#using.running-your-application.from-an-ide) \| [Packaged](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#using.running-your-application.as-a-packaged-application) \| [Maven](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#using.running-your-application.with-the-maven-plugin) \| [Gradle](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#using.running-your-application.with-the-gradle-plugin)
- **애플리케이션 패키징하기:** [프로덕션 jars](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#using.packaging-for-production)
- **스프링 부트 CLI:** [CLI 사용하기](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#cli)

---

## 3.4. Learning About Spring Boot Features

스프링 부트의 핵심 기능을 자세히 알고 싶은가? [다음과 같은 내용들이 준비돼 있다](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#features):

- **스프링 애플리케이션:** [SpringApplication](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#features.spring-application)
- **외부 설정:** [External Configuration](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#features.external-config)
- **프로파일:** [Profiles](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#features.profiles)
- **로깅:** [Logging](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#features.logging)

---

## 3.5. Web

스프링 부트로 웹 애플리케이션을 만든다면, 아래 있는 주제들을 살펴봐라:

- **Servlet Web Applications:** [스프링 MVC, Jersey, 임베디드 서블릿 컨테이너](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#web.servlet)
- **Reactive Web Applications:** [스프링 웹플럭스, 임베디드 서블릿 컨테이너](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#web.reactive)
- **Graceful Shutdown:** [Graceful Shutdown](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#web.graceful-shutdown)
- **Spring Security:** [디폴트 시큐리티 설정, OAuth2와 SAML을 위한 자동 설정](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#web.security)
- **Spring Session:** [Spring Session 자동 설정](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#web.spring-session)
- **Spring HATEOAS:** [Spring HATEOAS 자동 설정](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#web.spring-hateoas)

---

## 3.6. Data

데이터 저장소를 다루는 애플리케이션을 개발한다면, 아래 링크에서 설정 방법을 확인할 수 있다:

- **SQL:** [SQL Datastore 설정, 임베디드 데이터베이스 지원, 커넥션 풀 등](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#data.sql)
- **NOSQL:** [Redis, MongoDB, Neo4j 등과 같은 NOSQL 저장소를 위한 자동 설정](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#data.nosql)

---

## 3.7. Messaging

메시지 전송 프로토콜을 사용한다면, 아래 섹션 중에서 필요한 것들을 참고하면 된다:

- **JMS:** [ActiveMQ/Artemis 자동 설정, JMS를 통해 메시지 주고받기](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#messaging.jms)
- **AMQP:** [RabbitMQ 자동 설정](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#messaging.amqp)
- **Kafka:** [스프링 Kafka 자동 설정](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#messaging.kafka)
- **RSocket:** [스프링 프레임워크의 RSocket 지원 자동 설정](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#messaging.rsocket)
- **Spring Integration:** [스프링 인티그레이션 자동 설정](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#messaging.spring-integration)

---

## 3.8. IO

IO 기능이 필요한 애플리케이션을 개발한다면, 아래 섹션 중에서 필요한 것들을 참고하면 된다:

- **Caching:** [EhCache, Hazelcast, Infinispan 등을 이용한 캐시 처리](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#io.caching)
- **Quartz:** [Quartz 스케줄링](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#io.quartz)
- **Mail:** [메일 전송하기](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#io.email)
- **Validation:** [JSR-303 Validation](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#io.validation)
- **REST Clients:** [RestTemplate과 WebClient를 이용한 REST 서비스 호출](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#io.rest-client)
- **Webservices:** [Spring Web Services 자동 설정](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#io.webservices)
- **JTA:** [JTA를 이용한 분산 트랜잭션](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#io.jta)

---

## 3.9. Container Images

스프링 부트는 컨테이너 이미지를 효율적으로 빌드할 수 있도록 지원을 아끼지 않고 있다. 자세한 내용은 아래에서 확인할 수 있다:

- **효율적인 컨테이너 이미지:** [도커 이미지같은 컨테이너 이미지를 최적화하기 위한 팁들](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#container-images.efficient-images)
- **Dockerfiles:** [dockerfile을 이용해 컨테이너 이미지 빌드하기](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#container-images.dockerfiles)
- **클라우드 네이티브 빌드팩:** [메이븐과 그래들을 통한 클라우드 네이티브 빌드팩 지원](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#container-images.buildpacks)

---

## 3.10. GraalVM Native Images

스프링 부트 애플리케이션은 GraalVM을 이용해 네이티브 실행 파일로 변환할 수 있다. 네이티브 이미지에 관한 지원 사항은 아래에서 자세히 설명하고 있다:

- **GraalVM 네티이브 이미지:** [소개](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#native-image.introducing-graalvm-native-images) \| [JVM과의 주요 차이점들](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#native-image.introducing-graalvm-native-images.key-differences-with-jvm-deployments) \| [AOT<sup>Ahead-of-Time</sup> 처리](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#native-image.introducing-graalvm-native-images.understanding-aot-processing)
- **Getting Started:** [빌드팩](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#native-image.developing-your-first-application.buildpacks) \| [네이티브 빌드 툴](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#native-image.developing-your-first-application.native-build-tools)
- **테스트:** [JVM](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#native-image.testing.with-the-jvm) \| [네이티브 빌드 툴](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#native-image.testing.with-native-build-tools)
- **Advanced Topics:** [설정 프로퍼티 중첩하기](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#native-image.advanced.nested-configuration-properties) \| [JAR 변환하기](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#native-image.advanced.converting-executable-jars) \| [알려진 제약들](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#native-image.advanced.known-limitations)

---

## 3.11. Advanced Topics

마지막으로, 스프링 부트를 이용해 좀 더 많은 것들을 해보고 싶다면 아래 토픽들을 살펴보면 좋다:

- **스프링 부트 애플리케이션 배포:** [클라우드 배포](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#deployment.cloud) \| [OS 서비스](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#deployment.installing.nix-services)
- **빌드 툴 플러그인:** [메이븐](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#build-tool-plugins.maven) \| [그래들](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#build-tool-plugins.gradle)
- **부록:** [애플리케이션 프로퍼티](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#appendix.application-properties) \| [설정 메타데이터](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#appendix.configuration-metadata) \| [자동 설정 클래스들](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#appendix.auto-configuration-classes) \| [테스트 자동 설정 어네토이션들](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#appendix.test-auto-configuration) \| [실행 가능한 jar 파일<sup>Executable Jars</sup>](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#appendix.executable-jar) \| [의존성 버전들](https://docs.spring.io/spring-boot/docs/3.0.0/reference/htmlsingle/#appendix.dependency-versions)
