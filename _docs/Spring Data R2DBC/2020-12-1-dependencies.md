---
title: Dependencies
category: Spring Data R2DBC
order: 11
permalink: /Spring%20Data%20R2DBC/dependencies/
description: 스프링 데이터 R2DBC 의존성 버전 관리하기 한글 번역
image: ./../../images/spring/logo.png
lastmod: 2020-12-10T12:00:00+09:00
comments: true
originalRefName: 스프링 데이터 R2DBC
originalRefLink: https://docs.spring.io/spring-data/r2dbc/docs/1.2.2/reference/html/#dependencies
---

### 목차

- [10.1. Dependency Management with Spring Boot](#101-dependency-management-with-spring-boot)
- [10.2. Spring Framework](#102-spring-framework)

---

 스프링 데이터 모듈은 각자 시작한 날짜가 다르기 때문에, 대부분 메이저 버전과 마이너 버전 번호가 다르다. 호환되는 버전을 미리 모아둔 스프링 데이터 릴리즈 트레인 BOM에 맡기는 게 제일 간편하다. 메이븐 프로젝트에선 다음과 같이 POM 파일 `<dependencyManagement />` 섹션 안에 의존성을 선언하면 된다:

**Example 1. Using the Spring Data release train BOM**

```xml
<dependencyManagement>
  <dependencies>
    <dependency>
      <groupId>org.springframework.data</groupId>
      <artifactId>spring-data-bom</artifactId>
      <version>2020.0.2</version>
      <scope>import</scope>
      <type>pom</type>
    </dependency>
  </dependencies>
</dependencyManagement>
```

<span id="dependencies.train-version"></span>최신 릴리즈 트레인 버전은 `2020.0.2`다. 트레인 버전은 [calver](https://calver.org/)의 `YYYY.MINOR.MICRO` 패턴을 사용한다. GA 릴리즈와 서비스 릴리즈는 `${calver}`를, 나머지 버전은 `${calver}-${modifier}` 패턴을 따른다. `modifier`는 다음 중 하나를 사용한다:

- `SNAPSHOT`: 현재 스냅샷
- `M1`, `M2` 등: 마일스톤
- `RC1`, `RC2` 등: 릴리즈 후보

BOM 사용 예시는 [스프링 데이터 예제 레포지토리](https://github.com/spring-projects/spring-data-examples/tree/master/bom)에 있다. BOM을 사용하면 아래처럼 `<dependencies />` 블록 안에 버전 없이도 원하는 스프링 데이터 모듈을 선언할 수 있다:

**Example 2. Declaring a dependency to a Spring Data module**

```xml
<dependencies>
  <dependency>
    <groupId>org.springframework.data</groupId>
    <artifactId>spring-data-jpa</artifactId>
  </dependency>
</dependencies>
```

---

## 10.1. Dependency Management with Spring Boot

스프링 부트는 스프링 데이터 모듈 최신 버전을 골라준다. 그래도 더 최신 버전을 쓰고 싶다면, `spring-data-releasetrain.version` 프로퍼티를 원하는 [트레인 버전과 이터레이션](#dependencies.train-version)으로 설정해라.

---

## 10.2. Spring Framework

스프링 데이터 모듈 최신 버전을 사용하려면 스프링 프레임워크 5.3.2 이상이 필요하다. 물론 버그를 수정한, 이보다 더 낮은 마이너 버전에서도 동작할 수도 있다. 하지만 같은 버전대라면 그 안에선 제일 최신 버전을 사용하는 게 가장 좋다.