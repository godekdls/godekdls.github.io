---
title: Spring Boot CLI
category: Spring Boot 2.X
order: 54
permalink: /Spring%20Boot/spring-boot-cli/
description: 스프링 부트 CLI로 애플리케이션 개발하기
image: ./../../images/springboot/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 부트
originalRefLink: https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#cli
priority: 0.4
---

### 목차

- [10.1. Installing the CLI](#101-installing-the-cli)
- [10.2. Using the CLI](#102-using-the-cli)
  + [10.2.1. Running Applications with the CLI](#1021-running-applications-with-the-cli)
    * [Deduced “grab” Dependencies](#deduced-grab-dependencies)
    * [Deduced “grab” Coordinates](#deduced-grab-coordinates)
    * [Default Import Statements](#default-import-statements)
    * [Automatic Main Method](#automatic-main-method)
    * [Custom Dependency Management](#custom-dependency-management)
  + [10.2.2. Applications with Multiple Source Files](#1022-applications-with-multiple-source-files)
  + [10.2.3. Packaging Your Application](#1023-packaging-your-application)
  + [10.2.4. Initialize a New Project](#1024-initialize-a-new-project)
  + [10.2.5. Using the Embedded Shell](#1025-using-the-embedded-shell)
  + [10.2.6. Adding Extensions to the CLI](#1026-adding-extensions-to-the-cli)
- [10.3. Developing Applications with the Groovy Beans DSL](#103-developing-applications-with-the-groovy-beans-dsl)
- [10.4. Configuring the CLI with settings.xml](#104-configuring-the-cli-with-settingsxml)
- [10.5. What to Read Next](#105-what-to-read-next)

---

스프링 부트 CLI는 스프링 애플리케이션을 빠르게 개발할 수 있도록 도와주는 커맨드라인 툴이다. CLI에선 Groovy 스크립트를 실행할 수 있기 때문에, 대량의 보일러플레이트 없이 익숙한 자바와 유사한 구문을 사용할 수 있다. 새로운 프로젝트를 부트스트랩하거나 프로젝트를 위한 자체 명령어를 작성할 수도 있다.

---

## 10.1. Installing the CLI

스프링 부트 CLI(커맨드라인 인터페이스)는 SDKMAN!(SDK Manager)을 사용해 수동으로 설치할 수도 있고, OSX 사용자라면 Homebrew나 MacPorts를 이용해도 된다. 전반적인 설치 가이드는 "Getting started" 섹션에 있는 *[스프링 부트 CLI 설치하기](../getting-started#432-installing-the-spring-boot-cli)*를 참고해라.

---

## 10.2. Using the CLI

CLI를 설치했다면 커맨드라인에서 `spring`을 입력하고 엔터키를 눌러주면 CLI를 실행할 수 있다. `spring`을 아무런 인자 없이 실행하면 아래와 같은 도움말이 출력된다:

```shell
$ spring
usage: spring [--help] [--version]
       <command> [<args>]

Available commands are:

  run [options] <files> [--] [args]
    Run a spring groovy script

  _... more command help is shown here_
```

`spring help`를 입력하면 다음과 같이 지원하는 명령어에 대한 자세한 정보를 확인할 수 있다:

```shell
$ spring help run
spring run - Run a spring groovy script

usage: spring run [options] <files> [--] [args]

Option                     Description
------                     -----------
--autoconfigure [Boolean]  Add autoconfigure compiler
                             transformations (default: true)
--classpath, -cp           Additional classpath entries
--no-guess-dependencies    Do not attempt to guess dependencies
--no-guess-imports         Do not attempt to guess imports
-q, --quiet                Quiet logging
-v, --verbose              Verbose logging of dependency
                             resolution
--watch                    Watch the specified file for changes
```

`version` 명령어를 통해서는 사용 중인 스프링 부트 버전을 빠르게 확인해볼 수 있다:

```shell
$ spring version
Spring CLI v2.5.2
```

### 10.2.1. Running Applications with the CLI

`run` 명령어를 사용하면 Groovy 소스 코드를 컴파일하고 실행할 수 있다. 스프링 부트 CLI는 완전히 자립적으로 실행할 수 있기 때문에<sup>self-contained</sup>, 따로 Groovy를 설치할 필요는 없다.

다음 코드는 Groovy로 작성한 "hello world" 웹 애플리케이션 예시다:

*hello.groovy*

```groovy
@RestController
class WebApplication {

    @RequestMapping("/")
    String home() {
        "Hello World!"
    }

}
```

이 애플리케이션을 컴파일하고 실행하려면 다음 명령어를 입력해라:

```shell
$ spring run hello.groovy
```

애플리케이션에 커맨드라인 인자를 전달하려면 다음 예시처럼 `--`를 사용해서 "spring" 커맨드 인자와 분리해주면 된다:

```shell
$ spring run hello.groovy -- --server.port=9000
```

JVM 커맨드라인 인자를 설정하려면 아래 예시처럼 환경 변수 `JAVA_OPTS`를 사용하면 된다:

```shell
$ JAVA_OPTS=-Xmx1024m spring run hello.groovy
```

> Microsoft Windows에서 `JAVA_OPTS`를 설정할 땐 `set "JAVA_OPTS=-Xms256m -Xmx2048m"`같이, 지시문 전체를 인용해야 한다. 이렇게 해야 프로세스에 값이 제대로 전달된다.

#### Deduced “grab” Dependencies

표준 Groovy는 써드 파티 라이브러리 의존성을 선언할 수 있는 `@Grab` 어노테이션을 가지고 있다. 덕분에 빌드 툴 없이 Groovy만으로 메이븐이나 그래들과 동일한 방식으로 jar를 다운로드할 수 있어 유용하다.

스프링 부트는 이 기술을 좀 더 확장해서, 코드를 기반으로 "가져올<sup>grab</sup>" 라이브러리를 추론한다. 예를 들어, 앞에서 보여준 `WebApplication` 코드는 `@RestController` 어노테이션을 사용하므로 스프링 부트는 "톰캣"과 "스프링 MVC"를 가져온다<sup>grab</sup>.

다음과 같은 아이템들을 "grab 힌트"로 사용한다:

| Items                                                      | Grabs                          |
| :--------------------------------------------------------- | :----------------------------- |
| `JdbcTemplate`, `NamedParameterJdbcTemplate`, `DataSource` | JDBC Application.              |
| `@EnableJms`                                               | JMS Application.               |
| `@EnableCaching`                                           | Caching abstraction.           |
| `@Test`                                                    | JUnit.                         |
| `@EnableRabbit`                                            | RabbitMQ.                      |
| extends `Specification`                                    | Spock test.                    |
| `@EnableBatchProcessing`                                   | Spring Batch.                  |
| `@MessageEndpoint` `@EnableIntegration`                    | Spring Integration.            |
| `@Controller` `@RestController` `@EnableWebMvc`            | Spring MVC + Embedded Tomcat.  |
| `@EnableWebSecurity`                                       | Spring Security.               |
| `@EnableTransactionManagement`                             | Spring Transaction Management. |

> 어떻게 커스텀이 적용되는지 정확히 알고싶다면 스프링 부트 CLI 소스 코드에 있는 [`CompilerAutoConfiguration`](https://github.com/spring-projects/spring-boot/tree/v2.5.2/spring-boot-project/spring-boot-cli/src/main/java/org/springframework/boot/cli/compiler/CompilerAutoConfiguration.java)의 하위 클래스들을 확인해봐라.

#### Deduced “grab” Coordinates

스프링 부트는 의존성을 그룹이나 버전 없이 지정할 수 있게 만드는 식으로 (ex. `@Grab('freemarker')`) Groovy의 표준 `@Grab` 지원을 확장한다. 이때는 스프링 부트의 디폴트 의존성 메타데이터를 확인해서 아티팩트의 그룹과 버전을 추론한다.	

> 디폴트 메타데이터는 사용하는 CLI 버전에 묶여있다. 디폴트 메타데이터는 CLI 버전을 갈아탈 때만 바뀌기 때문에, 의존성 버전을 변경할 수 있는 시점을 직접 제어할 수 있다. 디폴트 메타데이터에 들어있는 의존성과 그 버전은 [부록](https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#dependency-versions)에 있는 테이블에서 확인하면 된다.

#### Default Import Statements

Groovy에선 여러 가지 `import` 문이 자동으로 추가되기 때문에 코드 양을 줄일 수 있다. 앞에 있는 예제에서 풀네임<sup>fully-qualified name</sup>이나 `import` 문 없이 `@Component`, `@RestController`, `@RequestMapping`을 참조한 점에 주목해라.

> 다양한 스프링 어노테이션은 `import` 문이 없어도 동작한다. import 구문을 추가하기 전에 먼저 애플리케이션을 실행해보고 실패하는 게 있나 확인해봐라.

#### Automatic Main Method

자바 애플리케이션에서 같은 코드를 실행하려면 `public static void main(String[] args)` 메소드가 필요하지만, `Groovy` 스크립트에선 필요하지 않다. 컴파일된 코드를 `source`로 이용해 `SpringApplication`을 자동으로 생성한다.

#### Custom Dependency Management

기본적으로 CLI는 `@Grab` 의존성을 리졸브할 땐 `spring-boot-dependencies`에 선언된 의존성 관리를 이용한다. 디폴트 의존성 관리를 재정의할 별도 의존성 관리는 `@DependencyManagementBom` 어노테이션을 통해 설정할 수 있다. 이 어노테이션의 value에는 메이븐 BOM의 좌표<sup>coordinates</sup>(`groupId:artifactId:version`)를 하나 이상 지정해야 한다.

예를 들어 아래처럼 선언하면 된다:

```java
@DependencyManagementBom("com.example.custom-bom:1.0.0")
```

위에서는 `com/example/custom-versions/1.0.0/` 아래에 있는 메이븐 레포지토리에서 `custom-bom-1.0.0.pom`을 선언하고 있다.

다음과 같이 BOM을 여러 개 지정하면 선언한 순서대로 적용된다:

```java
@DependencyManagementBom([
    "com.example.custom-bom:1.0.0",
    "com.example.another-bom:1.0.0"])
```

위 예시는 `another-bom`의 의존성 관리가 `custom-bom`의 의존성 관리를 재정의한다는 것을 나타낸다.

`@Grab`을 사용할 수 있는 곳이라면 어디든지 `@DependencyManagementBom`을 사용할 수 있다. 하지만 의존성 관리 순서를 일관성 있게 관리하려면 `@DependencyManagementBom`은 애플리케이션에서 최대 한 번만 사용하는 게 좋다.

### 10.2.2. Applications with Multiple Source Files

파일 입력을 받는 명령어에는 모두 "shell globbing"을 사용할 수 있다. 즉, 아래 예시처럼 단일 디렉토리 내에 있는 파일들을 한 번에 사용할 수 있다:

```shell
$ spring run *.groovy
```

### 10.2.3. Packaging Your Application

다음과 같이 `jar` 커맨드를 사용하면 애플리케이션을 자립적으로 실행시킬 수 있는<sup>self-contained executable</sup> jar 파일로 패키징할 수 있다:

```shell
$ spring jar my-app.jar *.groovy
```

이렇게 만들어지는 jar에는 애플리케이션을 컴파일해서 만든 클래스들과 애플리케이션의 모든 의존성이 들어있기 때문에, `java -jar`를 사용해서 실행할 수 있다. jar 파일에는 애플리케이션의 클래스패스에 있는 항목들도 포함되어 있다. `--include`와 `--exclude`를 사용하면 jar에 경로를 직접 추가하고 제거할 수 있다. 둘 모두 쉼표로 구분하며, 기본값에서 제거해야 함을 나타낼 땐 "+", "-" 형식의 프리픽스를 사용할 수 있다. 디폴트 includes는 다음과 같다:

```
public/**, resources/**, static/**, templates/**, META-INF/**, *
```

디폴트 excludes는 다음과 같다:

```
.*, repository/**, build/**, target/**, **/*.jar, **/*.groovy
```

자세한 정보는 커맨드라인에 `spring help jar`를 입력해봐라.

### 10.2.4. Initialize a New Project

`init` 커맨드를 사용하면 쉘 안에서 [start.spring.io](https://start.spring.io/)를 사용해 새 프로젝트를 생성할 수 있다:

```shell
$ spring init --dependencies=web,data-jpa my-project
Using service at https://start.spring.io
Project extracted to '/Users/developer/example/my-project'
```

위 예시에선 `spring-boot-starter-web`과 `spring-boot-starter-data-jpa`를 사용하는 메이븐 기반 프로젝트로 `my-project` 디렉토리를 생성한다. 아래처럼 `--list` 플래그를 사용하면 이 서비스의 기능들을 확인할 수 있다:

```shell
$ spring init --list
=======================================
Capabilities of https://start.spring.io
=======================================

Available dependencies:
-----------------------
actuator - Actuator: Production ready features to help you monitor and manage your application
...
web - Web: Support for full-stack web development, including Tomcat and spring-webmvc
websocket - Websocket: Support for WebSocket development
ws - WS: Support for Spring Web Services

Available project types:
------------------------
gradle-build -  Gradle Config [format:build, build:gradle]
gradle-project -  Gradle Project [format:project, build:gradle]
maven-build -  Maven POM [format:build, build:maven]
maven-project -  Maven Project [format:project, build:maven] (default)

...
```

`init` 커맨드는 많은 옵션들을 지원한다. 자세한 정보는 `help`에서 출력해주는 내용을 확인해봐라. 예를 들어 아래 명령어로는 자바 8과 `war` 패키징을 사용하는 그래들 프로젝트를 생성할 수 있다:

```shell
$ spring init --build=gradle --java-version=1.8 --dependencies=websocket --packaging=war sample-app.zip
Using service at https://start.spring.io
Content saved to 'sample-app.zip'
```

### 10.2.5. Using the Embedded Shell

스프링 부트는 BASH와 zsh 쉘을 위한 명령어 자동 완성 스크립트를 포함하고 있다. 이 쉘들을 사용하지 않을 때는 (Windows 사용자라거나) 아래와 같이 `shell` 커맨드를 통해 통합 쉘을 시작할 수 있다:

```shell
$ spring shell
Spring Boot (v2.5.2)
Hit TAB to complete. Type \'help' and hit RETURN for help, and \'exit' to quit.
```

이 임베디드 쉘 안에선 다른 명령어를 직접 실행할 수 있다:

```shell
$ version
Spring CLI v2.5.2
```

임베디드 쉘은 `tab` 자동 완성 외에도 ANSI 색상 출력을 지원한다. 네이티브 커맨드를 실행해야 할 때는 `!`를 프리픽스로 사용하면 된다. 임베디드 쉘을 종료하려면 `ctrl-c`를 눌러라.

### 10.2.6. Adding Extensions to the CLI

`install` 커맨드를 사용하면 CLI에 익스텐션을 추가할 수 있다. 이 명령어엔 아래와 같이 아티팩트 좌표<sup>coordinates</sup>를 `group:artifact:version` 형식으로 하나 이상 넘긴다:

```shell
$ spring install com.example:spring-boot-cli-extension:1.0.0.RELEASE
```

제공한 좌표<sup>coordinates</sup>로 식별한 아티팩트 외에도, 이 아티팩드가 가지고 있는 의존성도 모두 인스톨된다.

의존성을 제거하려면 `uninstall` 커맨드를 사용해라. `install` 커맨드와 마찬가지로 아래처럼 아티팩트 좌표<sup>coordinates</sup>를 `group:artifact:version` 형식으로 하나 이상 받는다:

```shell
$ spring uninstall com.example:spring-boot-cli-extension:1.0.0.RELEASE
```

이렇게 하면 사용자가 제공한 좌표<sup>coordinates</sup>로 식별한 아티팩트와 그 의존성을 제거한다.

모든 추가 의존성을 제거하려면 아래처럼 `--all` 옵션을 사용하면 된다:

```shell
$ spring uninstall --all
```

---

## 10.3. Developing Applications with the Groovy Beans DSL

스프링 프레임워크 4.0은 `beans{}` "DSL"([Grails](https://grails.org/)에서 빌려온)을 네티이브로 지원하고 있으며, 같은 포맷을 사용해서 Groovy 애플리케이션 스크립트에 빈 정의를 임베딩시킬 수 있다. 아래처럼 한번 씩 미들웨어 선언같은 외부 기능을 포함시킬 때 사용하기 좋다:

```groovy
@Configuration(proxyBeanMethods = false)
class Application implements CommandLineRunner {

    @Autowired
    SharedService service

    @Override
    void run(String... args) {
        println service.message
    }

}

import my.company.SharedService

beans {
    service(SharedService) {
        message = "Hello World"
    }
}
```

최상위 레벨에 선언하기만 한다면 클래스 선언과 같은 파일에 `beans{}`를 함께 쓸 수 있다. 물론, 원한다면 별도 파일에 bean DSL을 넣어도 된다.

---

## 10.4. Configuring the CLI with settings.xml

스프링 부트 CLI는 메이븐의 의존성 resolution 엔진 Aether를 통해 의존성을 리졸브한다. CLI는 `~/.m2/settings.xml`에 있는 메이븐 설정을 이용해 Aether를 구성한다. CLI에서 따르는 설정은 다음과 같다:

- Offline
- Mirrors
- Servers
- Proxies
- Profiles
  - Activation
  - Repositories
- Active profiles

자세한 내용은 [메이븐의 설정 문서](https://maven.apache.org/settings.html)를 확인해봐라.

---

## 10.5. What to Read Next

깃허브 레포지토리에는 스프링 부트 CLI를 탐구해보기 좋은 몇 가지 [샘플 groovy 스크립트](https://github.com/spring-projects/spring-boot/tree/v2.5.2/spring-boot-project/spring-boot-cli/samples)가 들어있다. [소스 코드](https://github.com/spring-projects/spring-boot/tree/v2.5.2/spring-boot-project/spring-boot-cli/src/main/java/org/springframework/boot/cli) 전체를 아우르는 Javadoc도 대규모로 제공한다.

CLI 툴에서 한계를 봤다면, 애플리케이션을 전부 그래들이나 메이븐으로 빌드하는 "Groovy 프로젝트"로 전환할 수 있는 방법이 궁금할 거다. 다음 섹션에선 그래들이나 메이븐과 함께 사용할 수 있는 스프링 부트의 "[빌드 툴 플러그인](../build-tool-plugins)"을 다룬다.