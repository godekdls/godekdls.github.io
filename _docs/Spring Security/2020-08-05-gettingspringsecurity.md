---
title: Getting Spring Security
category: Spring Security
order: 5
permalink: /Spring%20Security/gettingspringsecurity/
description: 스프링 시큐리티를 시작하기 한글 번역
image: ./../../images/springsecurity/spring-security.png
lastmod: 2020-08-05T10:00:00+09:00
comments: true
completed: false
---

> [스프링 시큐리티 공식 레퍼런스](https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#getting)를 한글로 번역한 문서입니다.
>
> 전체 목차는 [여기](../contents/)에 있습니다.

{% include adsense.html %}

### 목차:

- [4.1. Release Numbering](#41-release-numbering)
- [4.2. Usage with Maven](#42-usage-with-maven)
  + [4.2.1. Spring Boot with Maven](#421-spring-boot-with-maven)
  + [4.2.2. Maven Without Spring Boot](#422-maven-without-spring-boot)
  + [4.2.3. Maven Repositories](#423-maven-repositories)
- [4.3. Gradle](#43-gradle)
  + [4.3.1. Spring Boot with Gradle](#431-spring-boot-with-gradle)
  + [4.3.2. Gradle Without Spring Boot](#432-gradle-without-spring-boot)
  + [4.3.3. Gradle Repositories](#433-gradle-repositories)
  
---

이번 섹션에서는 스프링 시큐리티 바이너리 파일로 개발을 시작하기 위한 모든 것을 다룬다. 소스 코드를 보고 싶으면 [Source Code 섹션](../springsecuritycommunity#23-source-code)을 참고하라.

---

## 4.1. Release Numbering

스프링 시큐리티 버전은 MAJOR.MINOR.PATCH 형식을 사용한다:

- MAJOR 버전은 이전 버전과 호환되지 않는 변경사항이 있을 때 올린다. 보통은 최신 보안 방향성에 맞게 개선했을 때에 해당한다.
- MINOR 버전에서도 개선사항이 추가되지만, 좀 더 소극적인 업데이트다.
- PATCH 레벨은 버그를 수정하는 경우를 제외하면 전후 버전과 완전히 호환된다.

---

## 4.2. Usage with Maven

스프링 시큐리티도 대부분의 오픈 소스 프로젝트처럼 메이븐 아티팩트로 의존성을 배포한다. 이번 섹션 주제는 메이븐으로 스프링 시큐리티 의존성을 추가하는 상세 가이드다.

### 4.2.1. Spring Boot with Maven

스프링 부트는 스프링 시큐리티 관련 의존성을 모두 함께 묶어놓은 `spring-boot-starter-security` 스타터를 제공한다. 스타터는 IDE 인테그레이션 ([Eclipse](https://joshlong.com/jl/blogPost/tech_tip_geting_started_with_spring_boot.html), [IntelliJ](https://www.jetbrains.com/help/idea/spring-boot.html#d1489567e2), [NetBeans](https://github.com/AlexFalappa/nb-springboot/wiki/Quick-Tour))이나 [https://start.spring.io](https://start.spring.io/)를 통해 [스프링 이니셜라이저](https://docs.spring.io/initializr/docs/current/reference/html/)를 사용하는 게 가장 간단하면서도 권장하는 방법이다.

아니면 다음 예제처럼 수동으로 스타터를 추가해도 된다:

**Example 1. pom.xml**

```xml
<dependencies>
    <!-- ... other dependency elements ... -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-security</artifactId>
    </dependency>
</dependencies>
```

스프링 부트는 메이븐 BOM으로 의존성 버전을 관리하기 때문에 버전을 생략해도 된다. 스프링 시큐리티 버전을 오버라이드하고 싶다면 다음 예제처럼 메이븐 속성에 버전을 명시하면 된다.

**Example 2. pom.xml**

```xml
<properties>
    <!-- ... -->
    <spring-security.version>5.3.2.RELEASE</spring-security.version>
</dependencies>
```

스프링 시큐리티에서 호환성을 보장하지 않는 업데이트는 메이저 릴리즈에서만 이루어지기 때문에, 스프링 부트에서 스프링 시큐리티 최신 버전을 사용하는 것은 괜찮다. 하지만 어떨 땐 스프링 프레임워크 버전도 함께 올려야 할 때도 있다. 이땐 다음 예제처럼 메이븐 프로퍼티를 추가하면 된다:

**Example 3. pom.xml**

```xml
<properties>
    <!-- ... -->
    <spring.version>5.2.6.RELEASE</spring.version>
</dependencies>
```

다른 부가 기능을 사용한다면 (LDAP, OpenID 등) 적당한 [프로젝트 모듈](../projectmodules)을 추가해야 한다.

### 4.2.2. Maven Without Spring Boot

스프링 부트 없이 스프링 시큐리티를 사용한다면, 스프링 시큐리티의 BOM으로 전체 프로젝트의 버전을 통일하는 게 좋다. 그 방법은 다음 예제에 있다:

**Example 4. pom.xml**

```xml
<dependencyManagement>
    <dependencies>
        <!-- ... other dependency elements ... -->
        <dependency>
            <groupId>org.springframework.security</groupId>
            <artifactId>spring-security-bom</artifactId>
            <version>{spring-security-version}</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>
```

스프링 시큐리티를 사용하기 위한 최소한의 메이븐 의존성 셋은 보통 다음과 같다:

**Example 5. pom.xml**

```xml
<dependencies>
    <!-- ... other dependency elements ... -->
    <dependency>
        <groupId>org.springframework.security</groupId>
        <artifactId>spring-security-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.security</groupId>
        <artifactId>spring-security-config</artifactId>
    </dependency>
</dependencies>
```

다른 부가 기능을 사용한다면 (LDAP, OpenID 등) 적당한 [프로젝트 모듈](../projectmodules)을 추가해야 한다.

스프링 시큐리티는 스프링 프레윔워크 5.2.6.RELEASE를 기준으로 빌드했지만, 일반적으로 스프링 프레임워크 5.x 버전 이상에서는 잘 동작할 것이다. 많은 사용자가 스프링 시큐리티의 전이 의존성 (transitive dependency)이 스프링 프레임워크 5.2.6.RELEASE를 리졸브한다는 사실을 간과하곤 하는데, 이는 알 수 없는 클래스 패스 문제를 일으킬 수도 있다. 이를 해결하기 위한 가장 쉬운 방법은 다음 예제처럼 `pom.xml`의 `<dependencyManagement>` 섹션 안에서 `spring-framework-bom`을 사용하는 것이다:

**Example 6. pom.xml**

```xml
<dependencyManagement>
    <dependencies>
        <!-- ... other dependency elements ... -->
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-framework-bom</artifactId>
            <version>5.2.6.RELEASE</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>
```

위 예제대로 설정하면 스프링 시큐리티의 모든 전이 의존성에서 스프링 5.2.6.RELEASE 모듈을 사용한다.

> 이 방식은 메이븐의 “bill of materials” (BOM) 개념을 사용하며, Maven 2.0.9+에서만 사용할 수 있다. 어떻게 의존성을 관리하고 해결하는지에 대한 자세한 정보는 [메이븐의 의존성 메커니즘 소개 문서](https://maven.apache.org/guides/introduction/introduction-to-dependency-mechanism.html)를 참고하라.

### 4.2.3. Maven Repositories

모든 GA 릴리즈는 (.RELEASE로 끝나는 버전) 메이븐 중앙 저장소에 배포하므로 pom에 별도 메이븐 레포지토리를 추가할 필욘 없다.

스냅샷 버전을 사용한다면 다음처럼 스프링 스냅샷 레포지토리를 정의해야 한다:

**Example 7. pom.xml**

```xml
<repositories>
    <!-- ... possibly other repository elements ... -->
    <repository>
        <id>spring-snapshot</id>
        <name>Spring Snapshot Repository</name>
        <url>https://repo.spring.io/snapshot</url>
    </repository>
</repositories>
```

마일스톤이나 릴리즈 후보 버전을 사용한다면 다음처럼 스프링 마일스톤 레포지토리를 정의해야 한다:

**Example 8. pom.xml**

```xml
<repositories>
    <!-- ... possibly other repository elements ... -->
    <repository>
        <id>spring-milestone</id>
        <name>Spring Milestone Repository</name>
        <url>https://repo.spring.io/milestone</url>
    </repository>
</repositories>
```

---

## 4.3. Gradle

스프링 시큐리티도 대부분의 오픈 소스 프로젝트처럼 메이븐 아티팩트로 의존성을 배포하며, first-class 그래들을 지원한다. 이어지는 주제는 그래들로 스프링 시큐리티 의존성을 추가하는 상세 가이드다.

### 4.3.1. Spring Boot with Gradle

스프링 부트는 스프링 시큐리티 관련 의존성을 모두 함께 묶어놓은 `spring-boot-starter-security` 스타터를 제공한다. 스타터는 IDE 인테그레이션 ([Eclipse](https://joshlong.com/jl/blogPost/tech_tip_geting_started_with_spring_boot.html), [IntelliJ](https://www.jetbrains.com/help/idea/spring-boot.html#d1489567e2), [NetBeans](https://github.com/AlexFalappa/nb-springboot/wiki/Quick-Tour))이나 [https://start.spring.io](https://start.spring.io/)를 통해 [스프링 이니셜라이저](https://docs.spring.io/initializr/docs/current/reference/htmlsingle/)를 사용하는 게 가장 간단하면서도 권장하는 방법이다.

아니면 다음 예제처럼 수동으로 스타터를 추가해도 된다:

**Example 9. build.gradle**

```groovy
dependencies {
    compile "org.springframework.boot:spring-boot-starter-security"
}
```

스프링 부트는 메이븐 BOM으로 의존성 버전을 관리하기 때문에 버전을 생략해도 된다. 스프링 시큐리티 버전을 오버라이드하고 싶다면 다음 예제처럼 그래들 속성에 버전을 명시하면 된다.

**Example 10. build.gradle**

```groovy
ext['spring-security.version']='5.3.2.RELEASE'
```

스프링 시큐리티에서 호환성을 보장하지 않는 업데이트는 메이저 릴리즈에서만 이루어지기 때문에, 스프링 부트에서 스프링 시큐리티 최신 버전을 사용하는 것은 괜찮다. 하지만 어떨 땐 스프링 프레임워크 버전도 함께 올려야 할 때도 있다. 이땐 다음 예제처럼 그래들 프로퍼티를 추가하면 된다:

**Example 11. build.gradle**

```groovy
ext['spring.version']='5.2.6.RELEASE'
```

다른 부가 기능을 사용한다면 (LDAP, OpenID 등) 적당한 [프로젝트 모듈](../projectmodules)을 추가해야 한다.

### 4.3.2. Gradle Without Spring Boot

스프링 부트 없이 스프링 시큐리티를 사용한다면, 스프링 시큐리티의 BOM으로 전체 프로젝트의 버전을 통일하는 게 좋다. 다음 예제처럼  [Dependency Management Plugin](https://github.com/spring-gradle-plugins/dependency-management-plugin)을 적용하면 된다:

**Example 12. build.gradle**

```groovy
plugins {
    id "io.spring.dependency-management" version "1.0.6.RELEASE"
}

dependencyManagement {
    imports {
        mavenBom 'org.springframework.security:spring-security-bom:5.3.2.RELEASE'
    }
}
```

스프링 시큐리티를 사용하기 위한 최소한의 메이븐 의존성 셋은 보통 다음과 같다:

**Example 13. build.gradle**

```groovy
dependencies {
    compile "org.springframework.security:spring-security-web"
    compile "org.springframework.security:spring-security-config"
}
```

다른 부가 기능을 사용한다면 (LDAP, OpenID 등) 적당한 [프로젝트 모듈](../projectmodules)을 추가해야 한다.

스프링 시큐리티는 스프링 프레윔워크 5.2.6.RELEASE를 기준으로 빌드했지만, 일반적으로 스프링 프레임워크 5.x 버전 이상에서는 잘 동작할 것이다. 많은 사용자가 스프링 시큐리티의 전이 의존성 (transitive dependency)이 스프링 프레임워크 5.2.6.RELEASE를 리졸브한다는 사실을 간과하곤 하는데, 이는 알 수 없는 클래스 패스 문제를 일으킬 수도 있다. 이를 해결하기 위한 가장 쉬운 방법은 다음 예제처럼 `pom.xml`의 `<dependencyManagement>` 섹션 안에서 `spring-framework-bom`을 사용하는 것이다. 다음처럼 [Dependency Management Plugin](https://github.com/spring-gradle-plugins/dependency-management-plugin)을 적용하면 된다:

**Example 14. build.gradle**

```groovy
plugins {
    id "io.spring.dependency-management" version "1.0.6.RELEASE"
}

dependencyManagement {
    imports {
        mavenBom 'org.springframework:spring-framework-bom:5.2.6.RELEASE'
    }
}
```

위 예제대로 설정하면 스프링 시큐리티의 모든 전이 의존성에서 스프링 5.2.6.RELEASE 모듈을 사용한다.

### 4.3.3. Gradle Repositories

모든 GA 릴리즈는 (.RELEASE로 끝나는 버전) 메이븐 중앙 저장소에 배포하므로 mavenCentral() 레포지토리만 있으면 된다. 아래처럼 사용하면 된다:

**Example 15. build.gradle**

```groovy
repositories {
    mavenCentral()
}
```

스냅샷 버전을 사용한다면 다음처럼 스프링 스냅샷 레포지토리를 정의해야 한다:

**Example 16. build.gradle**

```groovy
repositories {
    maven { url 'https://repo.spring.io/snapshot' }
}
```

마일스톤이나 릴리즈 후보 버전을 사용한다면 다음처럼 스프링 마일스톤 레포지토리를 정의해야 한다:

**Example 17. build.gradle**

```groovy
repositories {
    maven { url 'https://repo.spring.io/milestone' }
}
```

---

> 전체 목차는 [여기](../contents/)에 있습니다.