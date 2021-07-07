---
title: Upgrading Spring Boot
category: Spring Boot
order: 6
permalink: /Spring%20Boot/upgrading-spring-boot/
description: 스프링 부트 버전 업그레이드 가이드
image: ./../../images/springboot/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 부트
originalRefLink: https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#upgrading
---

### 목차

- [5.1. Upgrading from 1.x](#51-upgrading-from-1x)
- [5.2. Upgrading to a new feature release](#52-upgrading-to-a-new-feature-release)
- [5.3. Upgrading the Spring Boot CLI](#53-upgrading-the-spring-boot-cli)

---

스프링 부트 버전을 업그레이드하는 방법은 프로젝트 [wiki](https://github.com/spring-projects/spring-boot/wiki)에서 가이드하고 있다. [릴리즈 노트](https://github.com/spring-projects/spring-boot/wiki#release-notes) 섹션에서 업그레이드하고 싶은 버전을 찾아 링크를 따라가라.

릴리즈 노트 맨 앞에는 항상 업그레이드 가이드가 담겨 있다. 릴리즈 버전이 두 버전 이상 뒤처져 있다면 반드시 건더뛴 버전의 릴리즈 노트도 검토해야 한다.

---

## 5.1. Upgrading from 1.x

스프링 부트 `1.x` 릴리즈에서 업그레이드한다면 자세한 업그레이드 지침을 제공하는 [프로젝트 위키의 "마이그레이션 가이드"](https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-2.0-Migration-Guide)를 확인해라. 각 릴리즈의 "새롭고 주목할만한<sup>new and noteworthy</sup>" 피처 리스트를 알아보려면 ["릴리즈 노트"](https://github.com/spring-projects/spring-boot/wiki)도 함께 확인해라.

---

## 5.2. Upgrading to a new feature release

새 피처 릴리즈로 업그레이드할 땐, 일부 프로퍼티의 이름이 변경되었거나 제거됐을 수도 있다. 스프링 부트는 애플리케이션 환경을 분석해 기동 시 진단 결과를 출력해주면서 동시에 런타임에 임시로 프로퍼티를 마이그레이션해주기도 한다. 이 기능을 사용하려면 프로젝트에 다음 의존성을 추가해라:

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-properties-migrator</artifactId>
    <scope>runtime</scope>
</dependency>
```

> 이 모듈에선 `@PropertySource`를 사용할 때 등, 뒤늦게 environment에 추가되는 프로퍼티는 고려하지 않는다.

> 마이그레이션을 완료하고 나면 프로젝트 의존성에서 이 모듈을 제거해야 한다.

---

## 5.3. Upgrading the Spring Boot CLI

기존에 설치한 CLI 버전을 업그레이드하려면 적절한 패키지 매니저 명령(ex. `brew upgrade`)을 사용해라. CLI를 수동으로 설치했다면 [표준 지침](../getting-started/#manual-installation)을 따르되, `PATH` 환경 변수를 업데이트해 이전 레퍼런스를 제거하는 것을 잊지 마라.
