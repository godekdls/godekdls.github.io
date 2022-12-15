---
title: Getting Started
category: Spring Boot 2.X
order: 5
permalink: /Spring%20Boot/getting-started/
description: 스프링 부트 소개, 설치 방법, 어플리케이션을 개발하고 실행해보기
image: ./../../images/springboot/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 부트
originalRefLink: https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#getting-started
priority: 0.6
---

### 목차

- [4.1. Introducing Spring Boot](#41-introducing-spring-boot)
- [4.2. System Requirements](#42-system-requirements)
  + [4.2.1. Servlet Containers](#421-servlet-containers)
- [4.3. Installing Spring Boot](#43-installing-spring-boot)
  + [4.3.1. Installation Instructions for the Java Developer](#431-installation-instructions-for-the-java-developer)
    * [Maven Installation](#maven-installation)
    * [Gradle Installation](#gradle-installation)
  + [4.3.2. Installing the Spring Boot CLI](#432-installing-the-spring-boot-cli)
    * [Manual Installation](#manual-installation)
    * [Installation with SDKMAN!](#installation-with-sdkman)
    * [OSX Homebrew Installation](#osx-homebrew-installation)
    * [MacPorts Installation](#macports-installation)
    * [Command-line Completion](#command-line-completion)
    * [Windows Scoop Installation](#windows-scoop-installation)
    * [Quick-start Spring CLI Example](#quick-start-spring-cli-example)
- [4.4. Developing Your First Spring Boot Application](#44-developing-your-first-spring-boot-application)
  + [4.4.1. Creating the POM](#441-creating-the-pom)
  + [4.4.2. Adding Classpath Dependencies](#442-adding-classpath-dependencies)
  + [4.4.3. Writing the Code](#443-writing-the-code)
    * [The @RestController and @RequestMapping Annotations](#the-restcontroller-and-requestmapping-annotations)
    * [The @EnableAutoConfiguration Annotation](#the-enableautoconfiguration-annotation)
    * [The “main” Method](#the-main-method)
  + [4.4.4. Running the Example](#444-running-the-example)
  + [4.4.5. Creating an Executable Jar](#445-creating-an-executable-jar)
- [4.5. What to Read Next](#45-what-to-read-next)

---

스프링 부트나 "스프링" 자체가 처음이라면 이 섹션을 읽는 것부터 시작해라. "무엇이", "어떻게", "왜"와 관련된 기초적인 궁금증을 해결해 줄 거다. 여기서는 스프링 부트를 소개하고 설치 가이드를 함께 다룬다. 그런 다음 첫 번째 스프링 부트 애플리케이션을 빌드해보면서, 몇 가지 핵심 원칙들을 논한다.

---

## 4.1. Introducing Spring Boot

스프링 부트는 스프링 기반 애플리케이션을 독립형<sup>stand-alone </sup>, 프로덕션 레벨로 만들고 실행할 수 있게 도와준다. 스프링 부트는 스프링 플랫폼과 써드 파티 라이브러리들의 설계 철학을 최대한 수용하기 때문에, 큰 고민 없이 바로 시작할 수 있다. 스프링 부트 애플리케이션 대부분은 아주 적은 양의 스프링 설정으로도 충분하다.

스프링 부트를 사용하면 `java -jar`나, 좀 더 전통적으로는 war 배포를 통해 기동시킬 수 있는 자바 애플리케이션을 만들 수 있다. 더불어 "스프링 스크립트"를 실행하는 커맨드라인 툴도 함께 제공한다.

스프링 부트의 주요 목표는 다음과 같다:

- 모든 스프링 개발자가 근본적으로 더 빠르고 쉽게 접근할 수 있는 시작 환경을 제공한다.
- 곧바로 사용할 수 있는 옵션을 제공하되, 기본값에서 벗어나는 요구 사항이 생기면 쉽게 틀에서 벗어날 수 있다.
- 비지니스 로직과는 관련 없지만, 대규모 프로젝트에서 흔히 필요한 기능들을 다양하게 제공한다 (임베디드 서버, 보안, 메트릭, 헬스 체크, 설정 외부화 등).
- XML 설정을 위한 코드 생성이나 다른 조건은 전혀 요구하지 않는다.

---

## 4.2. System Requirements

스프링 부트 2.5.2에선 [자바 8](https://www.java.com/)이 필요하며, 자바 16까지 호환된다. [스프링 프레임워크 5.3.8](https://docs.spring.io/spring-framework/docs/5.3.8/reference/html/)이나 그 이상도 필요하다.

직접 지원하고 있는 빌드 툴은 다음과 같다:

| Build Tool | Version           |
| :--------- | :---------------- |
| Maven      | 3.5+              |
| Gradle     | 6.8.x, 6.9.x, 7.x |

### 4.2.1. Servlet Containers

스프링 부트는 다음과 같은 임베디드 서블릿 컨테이너를 지원한다:

| Name         | Servlet Version |
| :----------- | :-------------- |
| Tomcat 9.0   | 4.0             |
| Jetty 9.4    | 3.1             |
| Jetty 10.0   | 4.0             |
| Undertow 2.0 | 4.0             |

다른 컨테이너도 서블릿 3.1+와 호환된다면 스프링 부트 애플리케이션을 배포할 수 있다.

---

## 4.3. Installing Spring Boot

스프링 부트는 "전형적인" Java 개발 도구와 함께 사용해도 되고, 커맨드라인 툴로도 설치할 수 있다. 어느 쪽이든 [자바 SDK v1.8](https://www.java.com/) 이상이 필요하다. 시작하기 전에 앞서, 다음 명령어를 통해 현재 설치된 자바 버전을 확인해봐라.

```shell
$ java -version
```

자바 개발이 처음이거나 스프링 부트를 연습해보고 싶다면, [스프링 부트 CLI](#432-installing-the-spring-boot-cli)(커맨드라인 인터페이스)를 먼저 사용해 보는 것도 좋다. 그 외는 "전형적인" 설치 가이드를 읽도록 해라.

### 4.3.1. Installation Instructions for the Java Developer

스프링 부트는 다른 표준 자바 라이브러리와 동일하게 사용할 수 있다. 먼저, 클래스패스에 적당한 `spring-boot-*.jar` 파일을 추가해라. 스프링 부트에선 특별한 도구 통합이 필요 없이 때문에, IDE나 텍스트 편집기를 사용하면 된다. 게다가 스프링 부트 애플리케이션이라고 해서 특별할 건 없으므로, 다른 자바 프로그램과 동일하게 스프링 부트 애플리케이션을 실행하고 디버깅할 수 있다.

스프링 부트 jar를 복사해서 붙여 넣을 *수는 있지만*, 보통은 의존성 관리를 지원하는 빌드 도구(메이븐이나 그래들)를 사용하길 권장한다.

#### Maven Installation

스프링 부트는 아파치 메이븐 3.3이나 그 이상과 호환된다. 아직 메이븐을 설치하지 않았다면 [maven.apache.org](https://maven.apache.org/)의 가이드에 따라 설치해라.

> 메이븐을 패키지 매니저로 설치할 수 있는 운영 체제도 많이 있다. OSX Homebrew를 사용한다면 `brew install maven`을 실행해봐라. Ubuntu 사용자는 `sudo apt-get install maven`을 실행하면 된다. [Chocolatey](https://chocolatey.org/)를 사용하는 Windows 사용자는 elevated (관리자) 프롬프트에서 `choco install maven`을 실행하면 된다.

스프링 부트 의존성에선 `org.springframework.boot`를 `groupId`로 사용한다. 보통 메이븐 POM 파일은 `spring-boot-starter-parent` 프로젝트를 상속하고, ["스타터"](../developing-with-spring-boot#615-starters)를 하나 이상 선언한다. 그외 스프링 부트는 실행 가능한 jar를 생성할 수 있는 [메이븐 플러그인](../build-tool-plugins#111-spring-boot-maven-plugin)도 옵션으로 제공한다.

스프링 부트와 메이븐을 시작하는 자세한 방법은 메이븐 플러그인 레퍼런스 가이드의 [Getting Started 섹션](https://docs.spring.io/spring-boot/docs/2.5.2/maven-plugin/reference/htmlsingle/#)에서 확인할 수 있다.

#### Gradle Installation

스프링 부트는 그래들 6.8, 6.9 및 7.x와 호환된다. 아직 그래들을 설치하지 않았다면 [gradle.org](https://gradle.org/)의 가이드에 따라 설치해라.

스프링 부트 의존성은 `org.springframework.boot` `group`을 사용해 선언할 수 있다. 보통 그래들 프로젝트는 ["스타터"](../developing-with-spring-boot#615-starters) 하나 이상을 의존성으로 선언한다. 스프링 부트는 의존성 선언을 단순화하고 실행 가능한 jar를 만드는 데 활용할 수 있는 유용한 [그래들 플러그인](../build-tool-plugins#112-spring-boot-gradle-plugin)을 하나 제공한다.

> #### Gradle Wrapper
>
> Gradle Wrapper는 프로젝트를 빌드해야 할 때 그래들을 "얻어오는" 꽤 괜찮은 방법을 제공한다. 소스 코드와 함께 커밋해 빌드 프로세스를 부트스트랩할 수 있는 조그마한 스크립트이자 라이브러리다. 자세한 내용은 [docs.gradle.org/current/userguide/gradle_wrapper.html](https://docs.gradle.org/current/userguide/gradle_wrapper.html)을 참고해라.

스프링 부트와 그래들을 시작하는 자세한 방법은 그래들 플러그인 레퍼런스 가이드의 [Getting Started 섹션](https://docs.spring.io/spring-boot/docs/2.5.2/gradle-plugin/reference/htmlsingle/#getting-started)에서 확인할 수 있다.

### 4.3.2. Installing the Spring Boot CLI

스프링 부트 CLI(커맨드라인 인터페이스)는 스프링으로 빠르게 프로토타입을 만들어 볼 수 있는 커맨드라인 툴이다. 이 CLI를 통해 [Groovy](https://groovy-lang.org/) 스크립트를 실행할 수 있다. 따라서 대량의 보일러플레이트 코드 없이, 익숙한 자바와 유사한 구문을 사용할 수 있다.

스프링 부트로 작업한다고 해서 무조건 CLI를 사용해야 하는 건 아니지만, IDE 없이도 스프링 애플리케이션을 쉽고 빠르게 시작할 수 있다.

#### Manual Installation

스프링 CLI 배포판은 스프링 소프트웨어 레포지토리에서 다운받을 수 있다:

- [spring-boot-cli-2.5.2-bin.zip](https://repo.spring.io/release/org/springframework/boot/spring-boot-cli/2.5.2/spring-boot-cli-2.5.2-bin.zip)
- [spring-boot-cli-2.5.2-bin.tar.gz](https://repo.spring.io/release/org/springframework/boot/spring-boot-cli/2.5.2/spring-boot-cli-2.5.2-bin.tar.gz)

따끈따끈한 최신 [스냅샷 배포판](https://repo.spring.io/snapshot/org/springframework/boot/spring-boot-cli/)도 받을 수 있다.

다운로드가 완료되면 압축을 해제한 아카이브에 있는 [INSTALL.txt](https://raw.githubusercontent.com/spring-projects/spring-boot/v2.5.2/spring-boot-project/spring-boot-cli/src/main/content/INSTALL.txt) 가이드대로 따라해라. 요약하면 `.zip` 파일 안에 있는 `bin/` 디렉토리에는 `spring` 스크립트(Windows에선 `spring.bat`)가 들어있다. 아니면 `.jar` 파일과 함께 `java -jar`를 사용해도 된다 (스크립트를 활용하면 클래스패스 설정에 문제가 없는지 쉽게 확인할 수 있다).

#### Installation with SDKMAN!

SDKMAN!(소프트웨어 개발 키트 매니저)은 Groovy와 스프링 부트 CLI를 포함한 다양한 바이너리 SDK의 여러 가지 버전들을 관리할 수 있는 툴이다. [sdkman.io](https://sdkman.io/)에서 SDKMAN!을 받아 다음 명령어를 통해 스프링 부트를 설치해라:

```shell
$ sdk install springboot
$ spring --version
Spring Boot v2.5.2
```

CLI를 위한 기능을 개발해서 직접 빌드한 버전에 액세스하고 싶다면 다음 명령어를 사용해라:

```shell
$ sdk install springboot dev /path/to/spring-boot/spring-boot-cli/target/spring-boot-cli-2.5.2-bin/spring-2.5.2/
$ sdk default springboot dev
$ spring --version
Spring CLI v2.5.2
```

위 가이드에선 `dev`라는 `spring`의 로컬 인스턴스를 설치한다. 여기선 빌드한 타겟 경로를 가리키므로, springboot를 다시 빌드할 때마다 항상 `spring`은 최신 상태를 유지한다.

다음 명령어를 실행해보면 확인할 수 있다:

```shell
$ sdk ls springboot

================================================================================
Available Springboot Versions
================================================================================
> + dev
* 2.5.2

================================================================================
+ - local version
* - installed
> - currently in use
================================================================================
```

#### OSX Homebrew Installation

Mac에서 [Homebrew](https://brew.sh/)를 사용한다면 다음 명령어를 통해 스프링 부트 CLI를 설치할 수 있다:

```shell
$ brew tap spring-io/tap
$ brew install spring-boot
```

Homebrew는 `spring`을 `/usr/local/bin`에 설치한다.

> 해당 formula가 실행되지 않는다면 설치된 Brew가 구버전이어서 그럴 거다. 이럴 땐 `brew update`를 수행한 뒤 다시 실행해봐라.

#### MacPorts Installation

Mac에서 [MacPorts](https://www.macports.org/)를 사용한다면 다음 명령어를 통해 스프링 부트 CLI를 설치할 수 있다:

```shell
$ sudo port install spring-boot-cli
```

#### Command-line Completion

스프링 부트 CLI는 [BASH](https://en.wikipedia.org/wiki/Bash_(Unix_shell))와 [zsh](https://en.wikipedia.org/wiki/Z_shell) 쉘을 위한 자동 완성을 제공하는 스크립트를 포함하고 있다. 어떤 쉘이든지 해당 스크립트(`spring`이라고도 함)를 `source`해오거나, 개인 계정이나 시스템 전체에 걸친 bash 자동 완성 초기화에 이 스크립트를 넣어주면 된다. 데비안 시스템에선, 시스템 전체에 걸친 스크립트는 `/shell-completion/bash`에 있으며, 새 쉘을 시작하면 이 디렉토리에 있는 모든 스크립트를 실행한다. 예를 들어서 SDKMAN!을 통해 설치했다면 다음 명령어를 사용해 수동으로 스크립트를 실행할 수 있다:

```shell
$ . ~/.sdkman/candidates/springboot/current/shell-completion/bash/spring
$ spring <HIT TAB HERE>
  grab  help  jar  run  test  version
```

> 스프링 부트 CLI를 Homebrew나 MacPorts를 사용해 설치했다면 커맨드라인 자동 완성 스크립트는 자동으로 쉘에 등록된다.

#### Windows Scoop Installation

Windows에서 [Scoop](https://scoop.sh/)을 사용한다면 다음 명령어를 통해 스프링 부트 CLI를 설치할 수 있다:

```shell
> scoop bucket add extras
> scoop install springboot
```

Scoop는 `spring`을 `~/scoop/apps/springboot/current/bin`에 설치한다.

> 앱 매니페스트가 표시되지 않으면 설치된 scoop이 구버전이어서 그럴 거다. 이럴 땐 `scoop update`를 수행한 뒤 다시 실행해봐라.

#### Quick-start Spring CLI Example

아래 웹 애플리케이션을 통해 설치가 잘 됐는지 확인해볼 수 있다. 먼저, 다음과 같이 `app.groovy`라는 파일을 만들어라:

```groovy
@RestController
class ThisWillActuallyRun {

    @RequestMapping("/")
    String home() {
        "Hello World!"
    }

}
```

그 다음 쉘에서 다음 명령어를 실행해라:

```shell
$ spring run app.groovy
```

> 애플리케이션을 처음 실행할 때는 의존성을 다운받기 때문에 느리다. 이후엔 훨씬 빠르게 실행된다.

좋아하는 웹 브라우저를 열어 `localhost:8080`에 접속해보자. 다음과 같은 문구가 출력되는 게 보일 거다:

```
Hello World!
```

---

## 4.4. Developing Your First Spring Boot Application

이번 섹션에선 간단한 "Hello World!" 웹 애플리케이션을 개발하는 방법을 설명하면서 스프링 부트의 핵심 기능들을 짚어보겠다. 메이븐은 대부분의 IDE에서 지원하므로, 이 프로젝트는 메이븐으로 빌드한다.

> [spring.io](https://spring.io/) 웹 사이트에선 스프링 부트를 사용하는 "Getting Started" [가이드](https://spring.io/guides)를 다양하게 제공하고 있다. 해결하고자 하는 문제가 있다면 이곳을 먼저 확인해봐라.
>
> [start.spring.io](https://start.spring.io/)에 접속해 의존성 검색기에서 "웹" 스타터를 선택하면 아래 단계를 건너 뛸수 있다. 이 사이트에선 새 프로젝트 구조를 만들어 주므로, [곧바로 코딩을 시작할 수 있다](#443-writing-the-code). 자세한 내용은 [start.spring.io 사용자 가이드](https://github.com/spring-io/start.spring.io/blob/main/USING.adoc)를 확인해봐라.

시작하기 전에 앞서, 터미널을 열고 다음 명령어를 실행해서 유효한 자바와 메이븐 버전이 설치돼 있는지 확인해봐라.

```shell
$ java -version
java version "1.8.0_102"
Java(TM) SE Runtime Environment (build 1.8.0_102-b14)
Java HotSpot(TM) 64-Bit Server VM (build 25.102-b14, mixed mode)
$ mvn -v
Apache Maven 3.5.4 (1edded0938998edf8bf061f1ceb3cfdeccf443fe; 2018-06-17T14:33:14-04:00)
Maven home: /usr/local/Cellar/maven/3.3.9/libexec
Java version: 1.8.0_102, vendor: Oracle Corporation
```

> 이 샘플은 자체 디렉토리에 만들어야 한다. 이어지는 가이드에선 적절한 디렉토리를 만들었으며, 해당 디렉토리가 현재 디렉토리라고 가정한다.

### 4.4.1. Creating the POM

먼저 메이븐 `pom.xml` 파일을 만들어야 한다. `pom.xml`은 프로젝트를 빌드하는 데 사용하는 레시피같은 존재다. 선호하는 텍스트 편집기를 열어 다음 내용을 추가해라:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.example</groupId>
    <artifactId>myproject</artifactId>
    <version>0.0.1-SNAPSHOT</version>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.5.2</version>
    </parent>

    <!-- Additional lines to be added here... -->

</project>
```

위 xml 파일을 사용하면 빌드가 잘 실행될 거다. `mvn package`를 실행하면 테스트해볼 수 있다 (지금은 "jar will be empty - no content was marked for inclusion!"이란 경고는 무시해도 된다).

> 이 시점에서 프로젝트를 IDE로 임포트해도 좋다 (최신 자바 IDE는 대부분 메이븐 지원을 내장하고 있다). 우리는 간단하게 단순 텍스트 편집기를 계속 사용해서 예제를 진행해보겠다.

### 4.4.2. Adding Classpath Dependencies

스프링 부트는 클래스패스에 jar를 추가해주는 다양한 "스타터"를 제공한다. [스모크 테스트](https://en.wikipedia.org/wiki/Smoke_testing_(software))를 위한 우리의 애플리케이션은 POM의 `parent` 섹션에 `spring-boot-starter-parent`를 사용한다. `spring-boot-starter-parent`는 유용한 메이븐 기본값을 제공하는 특별한 스타터다. 이 스타터는 [`dependency-management`](../developing-with-spring-boot#611-dependency-management) 섹션도 제공해서, "그 덕을 보는<sup>blessed</sup>" 의존성에선 `version` 태그를 생략할 수 있다.

다른 "스타터들"은 특정 유형의 애플리케이션을 개발할 때 필요할만한 의존성들을 제공한다. 우리는 웹 애플리케이션을 개발 중이므로 `spring-boot-starter-web` 의존성을 추가한다. 그 전에 다음 명령어를 실행해서 현재 가지고 있는 의존성을 확인해볼 수 있다:

```shell
$ mvn dependency:tree

[INFO] com.example:myproject:jar:0.0.1-SNAPSHOT
```

`mvn dependency:tree`는 프로젝트 의존성 트리를 출력하는 명령어다. `spring-boot-starter-parent`는 그 자체만으론 의존성을 제공하진 않는다는 점을 확인할  수 있다. 필요한 의존성을 추가하려면 `pom.xml`을 열어 `parent` 섹션 바로 아래에 `spring-boot-starter-web` 의존성을 추가해라:

```xml
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
</dependencies>
```

`mvn dependency:tree`를 다시 실행해보면 이제, 톰켓 웹 서버와 스프링 부트 자체를 포함한 다른 많은 의존성이 추가됐음을 알 수 있다.

### 4.4.3. Writing the Code

우리의 애플리케이션을 완성하려면 자바 파일을 하나 만들어야 한다. 기본적으로 메이븐은 `src/main/java`에 있는 소스 코드를 컴파일하므로, 이 디렉토리 구조를 만든 다음, `src/main/java/MyApplication.java`라는 파일에 다음 코드를 넣어라.

```java
@RestController
@EnableAutoConfiguration
public class MyApplication {

    @RequestMapping("/")
    String home() {
        return "Hello World!";
    }

    public static void main(String[] args) {
        SpringApplication.run(MyApplication.class, args);
    }

}
```

여기에 코드는 별로 없지만 꽤 많은 일이 진행되고 있다. 중요한 부분은 다음 몇 섹션에서 단계별로 나누어 설명한다.

#### The @RestController and @RequestMapping Annotations

`MyApplication` 클래스에서 첫 번째로 보이는 어노테이션은 `@RestController`다. *stereotype* 어노테이션이라고도 알려져 있다. 이 어노테이션은 코드를 읽는 사람들과 스프링에게, 이 클래스가 담당하는 역할이 무엇인지 힌트를 주고 있다. 여기선 우리 클래스는 웹 `@Controller`이므로, 스프링은 들어오는 웹 요청을 처리할 때 이 클래스를 고려하게 된다.

`@RequestMapping` 어노테이션은 "라우팅" 정보를 제공한다. 이 어노테이션은 스프링에게 `/` 경로로 오는 모든 HTTP 요청은 `home` 메소드에 매핑되어야한다는 점을 알려준다. `@RestController` 어노테이션은 결과로 만들어진 문자열을 곧바로 호출자에게 렌더링해주도록 스프링에 지시한다.

> `@RestController`와 `@RequestMapping` 어노테이션은 스프링 MVC 어노테이션이다 (스프링 부트에만 국한되지 않는다). 자세한 내용은 스프링 레퍼런스 문서에 있는 [MVC 섹션](https://docs.spring.io/spring-framework/docs/5.3.8/reference/html/web.html#mvc)을 참고해라.

#### The @EnableAutoConfiguration Annotation

두 번째로 보이는 클래스 레벨 어노테이션은 `@EnableAutoConfiguration`이다. 이 어노테이션은 추가한 jar 의존성에 따라 스프링을 어떻게 구성해야 할지 "추측"하도록 스프링 부트에 지시한다. `spring-boot-starter-web`이 톰캣과 스프링 MVC를 추가했기 때문에, 이땐 웹 애플리케이션을 개발한다고 가정하고, 이에 따라 스프링을 자동 설정한다.

> #### Starters and Auto-configuration
>
> 자동 설정은 "스타터"와 잘 작동하도록 설계됐지만, 이 두 개념이 직접적으로 연결돼 있지는 않다. 스타터를 사용하지 않고 jar 의존성을 자유롭게 골라 담아도 된다. 그래도 스프링 부트는 최선을 다 해 애플리케이션을 자동으로 설정해줄 거다.

#### The “main” Method

애플리케이션에서 마지막으로 주목할 곳은 `main` 메소드다. 이 메소드는 자바 컨벤션에 따라 애플리케이션 진입점을 나타내는 표준 메소드다. 우리의 메인 메소드는 `run`을 호출함으로써 스프링 부트의 `SpringApplication` 클래스에 위임한다. `SpringApplication`은 스프링을 시작해 애플리케이션을 부트스트랩하고, 그에 따라 자동 설정된 톰캣 웹 서버를 시작하게 된다. 우리는 `run` 메소드에 `MyApplication.class`를 인자로 전달해서 스프링의 주요 컴포넌트 중 하나인 `SpringApplication`에 이 클래스를 알려줘야 한다. `args` 배열은 커맨드라인 인자를 노출하기 위해 함께 전달한다.

### 4.4.4. Running the Example

여기까지 전부 따라했다면 애플리케이션을 기동할 수 있다. `spring-boot-starter-parent` POM을 사용했기 때문에, 애플리케이션을 시작할 땐 `run` goal을 활용할 수 있다. 프로젝트 루트 디렉토리에서 `mvn spring-boot:run`을 입력해서 애플리케이션을 기동해라. 다음과 유사한 내용이 출력되는 걸 볼 수 있을 거다:

```shell
$ mvn spring-boot:run

  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::  (v2.5.2)
....... . . .
....... . . . (log output here)
....... . . .
........ Started MyApplication in 2.222 seconds (JVM running for 6.514)
```

웹 브라우저를 하나 열어 `localhost:8080`으로 접속하면 다음과 같은 문구가 출력되는 게 보일 거다:

```
Hello World!
```

애플리케이션을 정상적으로<sup>gracefully</sup> 종료하려면 `ctrl-c`를 눌러라.

### 4.4.5. Creating an Executable Jar

프로덕션에서도 활용할 수 있는, 완전히 자립적으로 실행할 수 있는 jar 파일<sup>self-contained executable jar</sup>을 만들어 보고 이 예제를 마치겠다. 실행 가능한<sup>executable</sup> jar("fat jar"라고도 부른다)는 컴파일된 클래스와, 코드를 실행하는 데 필요한 모든 jar 의존성을 함께 가지고 있는 아카이브다.

> #### Executable jars and Java
>
> 자바는 중첩된 jar 파일(jar 안에 들어있는 jar 파일)을 로드하는 표준 기법을 제시하지 않는다. 자립적으로 실행할 수 있는<sup>self-contained</sup> 어플리케이션을 배포하고자 한다면 문제일 수도 있다.
>
> 많은 개발자들은 이 문제를 해결하기 위해 "uber" jar를 사용한다. uber jar는 모든 애플리케이션 의존성에 있는 클래스들을 전부 단일 아카이브로 패키징한다. 이렇게 접근했을 때의 문제는 어떤 라이브러리가 애플리케이션에 들어 있던 건지 알아보기가 어렵다는 거다. 여러 jar에서 같은 파일 이름(내용은 다른)을 사용할 때에도 문제가 되곤 한다.
>
> 스프링 부트는 [다른 방법](https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#executable-jar)을 사용하며, 실제로 jar를 직접 중첩할 수 있게 해준다.

실행 가능한 jar를 생성하려면 `pom.xml`에 `spring-boot-maven-plugin`을 추가해야 한다. `dependencies` 섹션 바로 아래에 다음 설정을 추가해라:

```xml
<build>
    <plugins>
        <plugin>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-maven-plugin</artifactId>
        </plugin>
    </plugins>
</build>
```

> `spring-boot-starter-parent` POM에는 `repackage` goal을 바인딩하는 `<executions>` 설정이 들어 있다. Parent POM을 사용하지 않는다면 이 설정을 직접 선언해야 한다. 자세한 내용은 [플러그인 문서](https://docs.spring.io/spring-boot/docs/2.5.2/maven-plugin/reference/htmlsingle/#getting-started)를 참고해라.

`pom.xml`을 저장하고, 커맨드라인에서 다음과 같이 `mvn package`를 실행해라:

```shell
$ mvn package

[INFO] Scanning for projects...
[INFO]
[INFO] ------------------------------------------------------------------------
[INFO] Building myproject 0.0.1-SNAPSHOT
[INFO] ------------------------------------------------------------------------
[INFO] .... ..
[INFO] --- maven-jar-plugin:2.4:jar (default-jar) @ myproject ---
[INFO] Building jar: /Users/developer/example/spring-boot-example/target/myproject-0.0.1-SNAPSHOT.jar
[INFO]
[INFO] --- spring-boot-maven-plugin:2.5.2:repackage (default) @ myproject ---
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
```

`target` 디렉토리를 보면 `myproject-0.0.1-SNAPSHOT.jar`가 있을 거다. 파일 사이즈는 약 10MB 정도일 거다. 내부를 들여다보고 싶다면 다음과 같이 `jar tvf`를 실행하면 된다:

```shell
$ jar tvf target/myproject-0.0.1-SNAPSHOT.jar
```

`target` 디렉토리에는 `myproject-0.0.1-SNAPSHOT.jar.original`이라는 훨씬 작은 파일도 있을 거다. 이 파일은 스프링 부트에 의해 리패키징되기 전에 메이븐이 생성한 원본 jar 파일이다.

이 애플리케이션을 실행하려면, 다음과 같이 `java -jar` 명령어를 사용해라:

```shell
$ java -jar target/myproject-0.0.1-SNAPSHOT.jar

  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::  (v2.5.2)
....... . . .
....... . . . (log output here)
....... . . .
........ Started MyApplication in 2.536 seconds (JVM running for 2.864)
```

애플리케이션을 종료하려면 전처럼 `ctrl-c`를 눌러라.

---

## 4.5. What to Read Next

이 섹션을 통해 스프링 부트의 기본 개념을 몇 가지 얻어가고, 직접 애플리케이션을 작성하는 방법을 익혔기를 바란다. 직접 해보는 걸 좋아하는 개발자라면 [spring.io](https://spring.io/)로 바로 이동해, "스프링으로 이걸 어떻게 해결할 수 있나요?" 류의 문제를 가이드해주는 [getting started](https://spring.io/guides/) 가이드를 확인해보는 게 좋다. 스프링 부트 전용 "[How-to](../how-to-guides)" 레퍼런스 문서도 제공한다.

그 외는 *[스프링 부트로 개발하기](../developing-with-spring-boot)*를 다음으로 읽는 게 가장 이상적이다. 빨리 진행하고 싶다면 앞부분은 건너뛰고 *[스프링 부트 기능들](../spring-boot-features)*에 대해 읽어봐도 좋다.
