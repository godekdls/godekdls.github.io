---
title: Developing with Spring Boot
category: Spring Boot
order: 7
permalink: /Spring%20Boot/developing-with-spring-boot/
description: 스프링 부트 공식 문서 한국어 번역. 빌드 시스템, 스타터, 기본 코드 구성, 자동 설정, 애플리케이션 실행 방법, devtools 소개
image: ./../../images/springboot/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 부트
originalRefLink: https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#using
priority: 0.8
---
<script>defaultLanguages = ['properties']</script>

### 목차

- [6.1. Build Systems](#61-build-systems)
  + [6.1.1. Dependency Management](#611-dependency-management)
  + [6.1.2. Maven](#612-maven)
  + [6.1.3. Gradle](#613-gradle)
  + [6.1.4. Ant](#614-ant)
  + [6.1.5. Starters](#615-starters)
- [6.2. Structuring Your Code](#62-structuring-your-code)
  + [6.2.1. Using the “default” Package](#621-using-the-default-package)
  + [6.2.2. Locating the Main Application Class](#622-locating-the-main-application-class)
- [6.3. Configuration Classes](#63-configuration-classes)
  + [6.3.1. Importing Additional Configuration Classes](#631-importing-additional-configuration-classes)
  + [6.3.2. Importing XML Configuration](#632-importing-xml-configuration)
- [6.4. Auto-configuration](#64-auto-configuration)
  + [6.4.1. Gradually Replacing Auto-configuration](#641-gradually-replacing-auto-configuration)
  + [6.4.2. Disabling Specific Auto-configuration Classes](#642-disabling-specific-auto-configuration-classes)
- [6.5. Spring Beans and Dependency Injection](#65-spring-beans-and-dependency-injection)
- [6.6. Using the @SpringBootApplication Annotation](#66-using-the-springbootapplication-annotation)
- [6.7. Running Your Application](#67-running-your-application)
  + [6.7.1. Running from an IDE](#671-running-from-an-ide)
  + [6.7.2. Running as a Packaged Application](#672-running-as-a-packaged-application)
  + [6.7.3. Using the Maven Plugin](#673-using-the-maven-plugin)
  + [6.7.4. Using the Gradle Plugin](#674-using-the-gradle-plugin)
  + [6.7.5. Hot Swapping](#675-hot-swapping)
- [6.8. Developer Tools](#68-developer-tools)
  + [6.8.1. Property Defaults](#681-property-defaults)
  + [6.8.2. Automatic Restart](#682-automatic-restart)
    * [Logging changes in condition evaluation](#logging-changes-in-condition-evaluation)
    * [Excluding Resources](#excluding-resources)
    * [Watching Additional Paths](#watching-additional-paths)
    * [Disabling Restart](#disabling-restart)
    * [Using a Trigger File](#using-a-trigger-file)
    * [Customizing the Restart Classloader](#customizing-the-restart-classloader)
    * [Known Limitations](#known-limitations)
  + [6.8.3. LiveReload](#683-livereload)
  + [6.8.4. Global Settings](#684-global-settings)
    * [Configuring File System Watcher](#configuring-file-system-watcher)
  + [6.8.5. Remote Applications](#685-remote-applications)
    * [Running the Remote Client Application](#running-the-remote-client-application)
    * [Remote Update](#remote-update)
- [6.9. Packaging Your Application for Production](#69-packaging-your-application-for-production)
- [6.10. What to Read Next](#610-what-to-read-next)

---

이번 섹션에선 스프링 부트를 사용하는 방법을 좀 더 자세히 설명한다. 빌드 시스템, 자동 설정, 애플리케이션 실행 방법과 같은 주제들을 다룬다. 스프링 부트 베스트 프랙티스도 몇 가지를 함께 다룬다. 스프링 부트라고 해서 특별히 다를 것은 없지만 (사용할 수 있는 라이브러리 중 하나일 뿐), 따라 하면 개발 프로세스를 좀 더 쉽게 만들어 주는 권장 사항은 몇 가지 존재한다.

스프링 부트가 처음이라면 이번 섹션에 들어가기 전에 *[Getting Started](../getting-started)* 가이드를 먼저 읽고 오는 게 좋다.

---

## 6.1. Build Systems

특별한 사유가 없다면 무조건 [*의존성 관리*](#611-dependency-management)를 지원하고 "메이븐 중앙" 저장소에 올라와 있는 아티팩트를 사용할 수 있는 빌드 시스템을 하나 고르는 게 좋다. 추천하는 툴은 메이븐이나 그래들이다. 스프링 부트에선 다른 빌드 시스템(ex. Ant)도 활용할 수 있지만, 따로 지원하고 있진 않다.

### 6.1.1. Dependency Management

스프링 부트의 각 릴리즈들은 지원하는 의존성 리스트를 선별해서 제공한다. 이런 의존성들은 전부 스프링 부트가 관리하기 때문에, 실제로 빌드 설정에 직접 버전을 지정하지 않아도 된다. 스프링 부트 자체의 버전을 올리면 이 의존성들도 그에 따라 버전이 올라간다.

> 그래도 필요하다면 직접 버전을 지정해 스프링 부트의 권장 버전을 재정의할 수 있다.

이 선별 리스트에는 스프링 부트와 함께 사용할 수 있는 모든 스프링 모듈 뿐 아니라, 잘 선별해둔 써드 파티 라이브러리 목록도 함께 들어 있다. 이 리스트는 [메이븐](#612-maven) 및 [그래들](#613-gradle)과 함께 사용할 수 있는 표준 BOM<sup>Bills of Materials</sup> (`spring-boot-dependencies`)으로 제공한다.

> 스프링 부트의 각 릴리즈들은 스프링 프레임워크의 베이스 버전과 연계된다. 스프링 프레임워크의 버전은 지정하지 않는 것을 **강력히** 권한다.

### 6.1.2. Maven

메이븐으로 스프링 부트를 사용하는 방법을 알아보려면, 스프링 부트의 메이븐 플러그인 문서를 참고해라:

- 레퍼런스 ([HTML](https://docs.spring.io/spring-boot/docs/2.5.2/maven-plugin/reference/htmlsingle/), [PDF](https://docs.spring.io/spring-boot/docs/2.5.2/maven-plugin/reference/pdf/spring-boot-maven-plugin-reference.pdf))
- [API](https://docs.spring.io/spring-boot/docs/2.5.2/maven-plugin/api/)

### 6.1.3. Gradle

그래들로 스프링 부트를 사용하는 방법을 알아보려면, 스프링 부트의 그래들 플러그인 문서를 참고해라:

- 레퍼런스 ([HTML](https://docs.spring.io/spring-boot/docs/2.5.2/gradle-plugin/reference/htmlsingle/), [PDF](https://docs.spring.io/spring-boot/docs/2.5.2/gradle-plugin/reference/pdf/spring-boot-gradle-plugin-reference.pdf))
- [API](https://docs.spring.io/spring-boot/docs/2.5.2/gradle-plugin/api/)

### 6.1.4. Ant

아파치 Ant+Ivy로도 스프링 부트 프로젝트를 빌드할 수 있다. Ant로 실행 가능한 jar<sup>executable jar</sup>를 만드는 데 활용할 수 있는 `spring-boot-antlib` "AntLib" 모듈도 존재한다.

일반적인 `ivy.xml` 파일에 다음 예제와 유사하게 의존성을 선언할 수 있다:

```xml
<ivy-module version="2.0">
    <info organisation="org.springframework.boot" module="spring-boot-sample-ant" />
    <configurations>
        <conf name="compile" description="everything needed to compile this module" />
        <conf name="runtime" extends="compile" description="everything needed to run this module" />
    </configurations>
    <dependencies>
        <dependency org="org.springframework.boot" name="spring-boot-starter"
            rev="${spring-boot.version}" conf="compile" />
    </dependencies>
</ivy-module>
```

전형적인 `build.xml`은 아래와 유사할 거다:

```xml
<project
    xmlns:ivy="antlib:org.apache.ivy.ant"
    xmlns:spring-boot="antlib:org.springframework.boot.ant"
    name="myapp" default="build">

    <property name="spring-boot.version" value="2.5.2" />

    <target name="resolve" description="--> retrieve dependencies with ivy">
        <ivy:retrieve pattern="lib/[conf]/[artifact]-[type]-[revision].[ext]" />
    </target>

    <target name="classpaths" depends="resolve">
        <path id="compile.classpath">
            <fileset dir="lib/compile" includes="*.jar" />
        </path>
    </target>

    <target name="init" depends="classpaths">
        <mkdir dir="build/classes" />
    </target>

    <target name="compile" depends="init" description="compile">
        <javac srcdir="src/main/java" destdir="build/classes" classpathref="compile.classpath" />
    </target>

    <target name="build" depends="compile">
        <spring-boot:exejar destfile="build/myapp.jar" classes="build/classes">
            <spring-boot:lib>
                <fileset dir="lib/runtime" />
            </spring-boot:lib>
        </spring-boot:exejar>
    </target>
</project>
```

> `spring-boot-antlib` 모듈을 사용하고 싶지 않다면 "How-to" 가이드 *[spring-boot-antlib를 사용하지 않고 Ant로 실행 가능한 아카이브 빌드하기](../howto.build#12169-build-an-executable-archive-from-ant-without-using-spring-boot-antlib)*를 참고해라.

### 6.1.5. Starters

스타터는 애플리케이션에 포함시킬 수 있는 간편한 의존성 디스크립터<sup>descriptor</sup> 셋이다. 샘플 코드를 일일이 물색하고 의존성 디스크립터를 잔뜩 복붙할 필요없이, 필요한 스프링과 관련 기술을 모두 한 번에 가져올 수 있다. 예를 들어서 데이터베이스 접근을 위해 스프링과 JPA를 사용하고 싶다면, 프로젝트에 `spring-boot-starter-data-jpa` 의존성을 넣으면 된다.

스타터는 프로젝트를 재빠르게 시작, 실행하는 데 필요한 여러 가지 의존성을 가지고 있으며, 관리, 지원하는 일관적인 전이 의존성<sup>transitive dependencies</sup> 셋도 함께 가지고 있다.

> #### What’s in a name
>
> **공식** 스타터는 모두 유사한 네이밍 패턴을 따른다; `spring-boot-starter-*`에서 `*`는 애플리케이션의 특정한 타입을 나타낸다. 이 네이밍은 필요한 스타터를 쉽게 찾을 수 있도록 의도한 구조다. 많은 IDE에선 메이븐 통합을 지원하므로 이름으로 의존성을 검색할 수 있다. 예를 들어 적절한 이클립스나 스프링 툴즈 플러그인이 설치됐다면, POM 편집기에서 `ctrl-space`를 누르고 "spring-boot-starter"를 입력하면 전체 목록을 확인할 수 있다.
>
> "[나만의 스타터 만들기](../creating-your-own-auto-configuration#7295-creating-your-own-starter)" 섹션에서 설명하는 것처럼, `spring-boot`는 공식 스프링 부트 아티팩트 전용으로 예약되어 있으므로, 써드 파티 스타터는 `spring-boot`로 시작해선 안 된다. 써드 파티 스타터는 그보단 보통 프로젝트 이름으로 시작한다. 예를 들어 `thirdpartyproject`라는 프로젝트의 써드 파티 스타터는 보통 `thirdpartyproject-spring-boot-starter`로 명명한다.

아래에 보이는 애플리케이션 스타터는 `org.springframework.boot` 그룹으로 스프링 부트가 제공하는 스타터들이다:

*Table 1. Spring Boot application starters*

| Name                                                         | Description                                                  |
| :----------------------------------------------------------- | :----------------------------------------------------------- |
| `spring-boot-starter`                                        | 자동 설정, 로깅, YAML을 포함하는 핵심 스타터                 |
| `spring-boot-starter-activemq`                               | 아파치 ActiveMQ를 이용한 JMS 메세지 처리를 위한 스타터       |
| `spring-boot-starter-amqp`                                   | 스프링 AMQP과 Rabbit MQ를 사용하기 위한 스타터               |
| `spring-boot-starter-aop`                                    | 스프링 AOP와 AspectJ를 통한 관점 지향 프로그래밍<sup>aspect-oriented programming</sup>을 위한 스타터 |
| `spring-boot-starter-artemis`                                | 아파치 Artemis를 이용한 JMS 메세지 처리를 위한 스타터        |
| `spring-boot-starter-batch`                                  | 스프링 배치를 사용하기 위한 스타터                           |
| `spring-boot-starter-cache`                                  | 스프링 프레임워크가 지원하는 캐시를 사용하기 위한 스타터     |
| `spring-boot-starter-data-cassandra`                         | 카산드라 분산 데이터베이스와 Spring Data Cassandra를 사용하기 위한 스타터 |
| `spring-boot-starter-data-cassandra-reactive`                | 카산드라 분산 데이터베이스와 Spring Data Cassandra Reactive를 사용하기 위한 스타터 |
| `spring-boot-starter-data-couchbase`                         | 카우치베이스 document-oriented 데이터베이스와 Spring Data Couchbase를 사용하기 위한 스타터 |
| `spring-boot-starter-data-couchbase-reactive`                | 카우치베이스 document-oriented 데이터베이스와 Spring Data Couchbase Reactive를 사용하기 위한 스타터 |
| `spring-boot-starter-data-elasticsearch`                     | 엘라스틱서치 검색, 분석 엔진과 Spring Data Elasticsearch를 사용하기 위한 스타터 |
| `spring-boot-starter-data-jdbc`                              | Spring Data JDBC를 사용하기 위한 스타터                      |
| <span id="spring-boot-starter-data-jpa"></span>`spring-boot-starter-data-jpa` | Spring Data JPA와 하이버네이트를 사용하기 위한 스타터        |
| `spring-boot-starter-data-ldap`                              | Spring Data LDAP을 사용하기 위한 스타터                      |
| `spring-boot-starter-data-mongodb`                           | 몽고DB document-oriented 데이터베이스와 Spring Data MongoDB를 사용하기 위한 스타터 |
| `spring-boot-starter-data-mongodb-reactive`                  | 몽고DB document-oriented 데이터베이스와 Spring Data MongoDB Reactive를 사용하기 위한 스타터 |
| `spring-boot-starter-data-neo4j`                             | Neo4j 그래프 데이터베이스와 Spring Data Neo4j를 사용하기 위한 스타터 |
| `spring-boot-starter-data-r2dbc`                             | Spring Data R2DBC를 사용하기 위한 스타터                     |
| `spring-boot-starter-data-redis`                             | Spring Data Redis와 Lettuce 클라이언트를 활용해 레디스 key-value 데이터 스토어를 사용하기 위한 스타터 |
| `spring-boot-starter-data-redis-reactive`                    | Spring Data Redis reactive와 Lettuce 클라이언트를 활용해 레디스 key-value 데이터 스토어를 사용하기 위한 스타터 |
| `spring-boot-starter-data-rest`                              | Spring Data REST를 통해 스프링 데이터 레포지토리를 REST로 노출하기 위한 스타터 |
| `spring-boot-starter-freemarker`                             | FreeMarker 뷰를 이용해 MVC 웹 어플리케이션을 만들기 위한 스타터 |
| `spring-boot-starter-groovy-templates`                       | Groovy 템플릿 뷰를 이용해 MVC 웹 어플리케이션을 만들기 위한 스타터 |
| `spring-boot-starter-hateoas`                                | Spring MVC와 Spring HATEOAS를 사용해 하이퍼 미디어 기반 RESTful 웹 애플리케이션을 만들기 위한 스타터 |
| `spring-boot-starter-integration`                            | Spring Integration을 사용하기 위한 스타터                    |
| <span id="spring-boot-starter-jdbc"></span>`spring-boot-starter-jdbc` | JDBC와 HikariCP 커넥션 풀을 사용하기 위한 스타터             |
| `spring-boot-starter-jersey`                                 | JAX-RS와 Jersey를 사용하는 RESTful 웹 애플리케이션을 만들기 위한 스타터. [`spring-boot-starter-web`](#spring-boot-starter-web)으로 대체할 수 있다. |
| `spring-boot-starter-jooq`                                   | jOOQ를 이용해 SQL 데이터베이스에 접근하기 위한 스타터. [`spring-boot-starter-data-jpa`](#spring-boot-starter-data-jpa)나 [`spring-boot-starter-jdbc`](#spring-boot-starter-jdbc)로 대체할 수 있다. |
| `spring-boot-starter-json`                                   | json을 읽고 쓰기 위한 스타터                                 |
| `spring-boot-starter-jta-atomikos`                           | Atomikos를 사용하는 JTP 트랜잭션을 위한 스타터               |
| `spring-boot-starter-mail`                                   | 자바 Mail과 스프링 프레임워크의 지원을 받아 이메일을 전송하기 위한 스타터 |
| `spring-boot-starter-mustache`                               | Mustache 뷰를 사용해 웹 어플리케이션을 만들기 위한 스타터    |
| `spring-boot-starter-oauth2-client`                          | 스프링 시큐리티의 OAuth2/OpenID Connect 클라이언트 기능을 사용하기 위한 스타터 |
| `spring-boot-starter-oauth2-resource-server`                 | 스프링 시큐리티의 OAuth2 리소스 서버 기능을 사용하기 위한 스타터 |
| `spring-boot-starter-quartz`                                 | Quartz 스케줄러를 사용하기 위한 스타터                       |
| `spring-boot-starter-rsocket`                                | RSocket 클라이언트와 서버 구축을 위한 스타터                 |
| `spring-boot-starter-security`                               | Spring Security를 사용하기 위한 스타터                       |
| `spring-boot-starter-test`                                   | JUnit Jupiter, Hamcrest, Mockito 등의 라이브러리로 스프링 부트 애플리케이션을 테스트하기 위한 스타터 |
| `spring-boot-starter-thymeleaf`                              | Thymeleaf 뷰를 사용해 MVC 웹 어플리케이션을 만들기 위한 스타터 |
| `spring-boot-starter-validation`                             | Java Bean Validation과 Hibernate Validator를 사용하기 위한 스타터 |
| <span id="spring-boot-starter-web"></span>`spring-boot-starter-web` | 스프링 MVC를 이용해 RESTful 등의 웹 애플리케이션을 만들 수 있는 스타터. 톰캣을 디폴트 임베디드 컨테이너로 사용한다 |
| `spring-boot-starter-web-services`                           | Spring Web Services를 사용하기 위한 스타터                   |
| `spring-boot-starter-webflux`                                | 스프링 프레임워크로 리액티브 웹을 지원받아 웹플럭스 애플리케이션을 만들기 위한 스타터 |
| `spring-boot-starter-websocket`                              | 스프링 프레임워크로 웹소켓을 지원받아 웹소켓 애플리케이션을 만들기 위한 스타터 |

애플리케이션 스타터 외에도 아래 있는 스타터를 사용해 *[production ready](../spring-boot-actuator)* 기능을 추가할 수 있다:

*Table 2. Spring Boot production starters*

| Name                           | Description                                                  |
| :----------------------------- | :----------------------------------------------------------- |
| `spring-boot-starter-actuator` | 스프링 부트의 액추에이터를 사용하기 위한 스타터. 애플리케이션 모니터링과 관리를 도와주는 production ready 기능들을 제공한다. |

마지막으로, 스프링 부트는 기술적인 부분을 제외하거나 교체하고 싶을 때 사용할 수 있는 스타터도 제공한다:

*Table 3. Spring Boot technical starters*

| Name                                                         | Description                                                  |
| :----------------------------------------------------------- | :----------------------------------------------------------- |
| `spring-boot-starter-jetty`                                  | Jetty를 임베디드 서블릿 컨테이너로 사용하기 위한 스타터. [`spring-boot-starter-tomcat`](#spring-boot-starter-tomcat)으로 대체할 수 있다. |
| `spring-boot-starter-log4j2`                                 | Log4j2로 로그를 남기기 위한 스타터. [`spring-boot-starter-logging`](#spring-boot-starter-logging)으로 대체할 수 있다. |
| <span id="spring-boot-starter-logging"></span>`spring-boot-starter-logging` | Logback으로 로그를 남기기 위한 스타터. 디폴트 로깅 스타터다  |
| `spring-boot-starter-reactor-netty`                          | 리액터 네티를 임베디드 리액티브 HTTP 서버로 사용하기 위한 스타터 |
| <span id="spring-boot-starter-tomcat"></span>`spring-boot-starter-tomcat` | 톰캣을 임베디드 서블릿 컨테이너로 사용하기 위한 스타터. [`spring-boot-starter-web`](#spring-boot-starter-web)에서 디폴트 서블릿 컨테이너 스타터로 사용한다. |
| `spring-boot-starter-undertow`                               | Undertow를 임베디드 서블릿 컨테이너로 사용하기 위한 스타터. [`spring-boot-starter-tomcat`](#spring-boot-starter-tomcat)으로 대체할 수 있다. |

기술적인 부분을 교체하는 방법을 알아 보려면 how-to 문서 [웹 서버 교체하기](../howto.embedded-web-servers#1231-use-another-web-server)와 [로그 시스템](../howto.logging#1272-configure-log4j-for-logging)을 확인해봐라.

> 커뮤니티에서 기여한 다른 스타터들을 알아보고 싶다면 `spring-boot-starters` 모듈 깃허브에 있는 [README 파일](https://github.com/spring-projects/spring-boot/tree/main/spring-boot-project/spring-boot-starters/README.adoc)을 확인해봐라.

---

## 6.2. Structuring Your Code

스프링 부트를 동작시킬 때는 특정한 코드 레이아웃을 요구하지 않는다. 하지만 도움이 될만한 베스트 프랙티스는 몇 가지 존재한다.

### 6.2.1. Using the “default” Package

클래스에 `package` 선언이 없을 땐 이 클래스는 "디폴트 패키지"에 있는 것으로 간주한다. "디폴트 패키지" 활용은 일반적으론 권장하고 있지 않으며, 가능하면 피하는 게 좋다. 스프링 부트 애플리케이션에선 디폴트 패키지에 `@ComponentScan`이나 `@ConfigurationPropertiesScan`, `@EntityScan`, `@SpringBootApplication` 어노테이션을 적용하게 되면, 모든 jar에 있는 클래스를 전부 읽기때문에 특정 문제를 일으킬 수 있다.

> 패키지명은 자바에서 권장하는 패키지 네이밍 컨벤션에 따르고, 도메인 이름을 역순으로 (ex. `com.example.project`) 사용하는 걸 권장한다.

### 6.2.2. Locating the Main Application Class

일반적으로 메인 애플리케이션 클래스는 다른 클래스들을 아우르는 루트 패키지에 배치하는 걸 권장한다. [`@SpringBootApplication` 어노테이션](#66-using-the-springbootapplication-annotation)은 보통 메인 클래스에 두며, 특정 항목들을 찾기 위한 기본 "검색 패키지"를 암시하게 된다. 예를 들어 JPA 애플리케이션을 작성하고 있다면 `@SpringBootApplication` 어노테이션을 단 클래스의 패키지를 통해 `@Entity` 항목들을 검색한다. 루트 패키지를 사용하면 개발 중인 프로젝트에만 컴포넌트 스캔을 적용하는 게 가능하다.

> `@SpringBootApplication`을 사용하고 싶지 않다면, `@SpringBootApplication`이 임포트하는 `@EnableAutoConfiguration`과 `@ComponentScan` 어노테이션이 같은 동작을 정의하기 때문에, 이 두 어노테이션을 대신 사용해도 된다.

다음은 전형적인 레이아웃 예시다:

```
com
 +- example
     +- myapplication
         +- MyApplication.java
         |
         +- customer
         |   +- Customer.java
         |   +- CustomerController.java
         |   +- CustomerService.java
         |   +- CustomerRepository.java
         |
         +- order
             +- Order.java
             +- OrderController.java
             +- OrderService.java
             +- OrderRepository.java
```

`MyApplication.java` 파일에선 다음과 같이 기본적인 `@SpringBootApplication`과 함께 `main` 메소드를 선언할 거다:

```java
@SpringBootApplication
public class MyApplication {

    public static void main(String[] args) {
        SpringApplication.run(MyApplication.class, args);
    }

}
```

---

## 6.3. Configuration Classes

스프링 부트에선 자바 기반 설정을 선호한다. `SpringApplication`은 XML 소스와도 사용할 수 있지만, 보통은 주요 소스는 단일 `@Configuration` 클래스로 두는 것이 좋다. 일반적으로 주요 `@Configuration`으로 좋은 후보는 `main` 메소드를 정의하는 클래스다.

> 인터넷에는 XML 설정을 사용하는 스프링 설정 예제가 많이 있다. 하지만 가능하다면 무조건 같은 설정이라도 자바 기반 설정으로 구성하도록 해라. `Enable*.` 어노테이션을 검색해보는 것으로 시작하는 것도 좋다.

### 6.3.1. Importing Additional Configuration Classes

모든 `@Configuration`을 단일 클래스에 넣을 필요는 없다. `@Import` 어노테이션을 사용하면 다른 설정 클래스를 임포트할 수 있다. 아니면 `@ComponentScan`을 이용해서 `@Configuration` 클래스를 포함하는 전체 스프링 컴포넌트를 자동으로 선택해도 된다.

### 6.3.2. Importing XML Configuration

반드시 XML 기반 설정을 사용해야 하더라도, `@Configuration` 클래스로 시작하길 권한다. 그러고 나서 `@ImportResource` 어노테이션을 사용하면 XML 설정 파일을 로드할 수 있다.

---

## 6.4. Auto-configuration

스프링 부트 자동 설정은 추가한 jar 의존성을 기반으로 스프링 애플리케이션을 자동으로 설정해준다. 예를 들어 클래스패스에 `HSQLDB`가 있고 데이터베이스 커넥션 빈을 수동으로 설정하지 않았다면, 스프링 부트는 인 메모리 데이터베이스를 자동 설정한다.

자동 설정을 사용하려면 `@Configuration` 클래스 중 하나에 `@EnableAutoConfiguration`이나 `@SpringBootApplication` 어노테이션을 추가해줘야 한다.

> `@SpringBootApplication`과 `@EnableAutoConfiguration` 어노테이션은 둘 중 하나만 추가해야 한다. 보통은 주요 `@Configuration` 클래스에만 둘 중 하나를 추가하는 게 좋다.

### 6.4.1. Gradually Replacing Auto-configuration

자동 설정을 강제하진 않는다. 언제든지 자체 설정을 정의해 원하는 일부 자동 설정을 대체할 수 있다. 예를 들어, 자체 `DataSource` 빈을 추가하면 디폴트 임베디드 데이터베이스는 비활성화된다.

현재 적용되고 있는 자동 설정과 그 이유를 확인해야 한다면 `--debug` 스위치로 애플리케이션을 시작해라. 그러면 선택한 코어 로거에서 디버그 로그가 활성화되며, 콘솔에 컨디션 리포트를 출력한다.

### 6.4.2. Disabling Specific Auto-configuration Classes

원하지 않는 자동 설정 클래스가 적용되고 있는 걸 확인했다면, 다음 예제처럼 `@SpringBootApplication`의 exclude 속성으로 원하는 클래스를 비활성화할 수 있다:

```java
@SpringBootApplication(exclude = { DataSourceAutoConfiguration.class })
public class MyApplication {

}
```

비활성화하길 원하는 클래스가 클래스패스에 없다면 `@SpringBootApplication` 어노테이션의 `excludeName` 속성을 대신 사용해 클래스의 풀 네임<sup>fully qualified name</sup>을 지정하면 된다. `@SpringBootApplication`보단 `@EnableAutoConfiguration`을 선호한다면, 이 어노테이션에서도 `exclude`와  `excludeName`을 사용할 수 있다. 마지막으로, `spring.autoconfigure.exclude` 프로퍼티를 사용해 제외시킬 자동 설정 클래스 리스트를 제어해도 된다.

> 어노테이션 레벨과 프로퍼티를 둘 다 사용해서 제외할 클래스를 정의해도 된다.

> 자동 설정 클래스는 `public`이긴 하지만, 이 클래스에서 퍼블릭 API로 여겨지는 유일한 측면은 자동 설정을 비활성화하는 데 사용할 수 있는 클래스 이름 뿐이다. 중첩되어 있는 설정 클래스나 빈 메소드 등, 실제 이 클래스들의 내부 컨텐츠는 내부에서만 사용하기 위한 것이므로 직접 사용은 삼가는 게 좋다.

---

## 6.5. Spring Beans and Dependency Injection

원하는 빈을 만들고 주입할 의존성을 정의할 땐 표준 스프링 프레임워크 기술을 전부 자유롭게 사용해도 된다. 일반적으로 생성자 주입을 통해 의존성을 연결하고 `@ComponentScan`으로 빈을 찾는 것을 권장한다.

코드 구조를 위에서 제안한대로 짜게 되면 (애플리케이션 클래스를 최상위 패키지에 배치), `@ComponentScan`을 인자 없이 추가해도 되고, 이미 `@ComponentScan`을 포함하고 있는 `@SpringBootApplication` 어노테이션을 사용해도 된다. 모든 애플리케이션 컴포넌트는 (`@Component`, `@Service`, `@Repository`, `@Controller`) 자동으로 스프링 빈으로 등록된다.

다음 예제는 생성자 주입을 통해 필수 `RiskAssessor` 빈을 가져오는 `@Service` 빈을 보여준다:

```java
@Service
public class MyAccountService implements AccountService {

    private final RiskAssessor riskAssessor;

    public MyAccountService(RiskAssessor riskAssessor) {
        this.riskAssessor = riskAssessor;
    }

    // ...

}
```

빈에 생성자가 둘 이상 있다면, 스프링에서 사용할 생성자에 `@Autowired`를 마킹해줘야 한다:

```java
@Service
public class MyAccountService implements AccountService {

    private final RiskAssessor riskAssessor;

    private final PrintStream out;

    @Autowired
    public MyAccountService(RiskAssessor riskAssessor) {
        this.riskAssessor = riskAssessor;
        this.out = System.out;
    }

    public MyAccountService(RiskAssessor riskAssessor, PrintStream out) {
        this.riskAssessor = riskAssessor;
        this.out = out;
    }

    // ...

}
```

> 생성자 주입을 사용하면서 `riskAssessor` 필드를 `final`로 표기해, 차후에 변경할 수 없음을 나타냈음에 주목해라.

---

## 6.6. Using the @SpringBootApplication Annotation

많은 스프링 부트 개발자들은 애플리케이션에 자동 설정과 컴포넌트 스캔을 적용하고, "애플리케이션 클래스"에 추가 설정을 정의하는 걸 좋아한다. 이 세 가지 기능은 `@SpringBootApplication` 어노테이션 하나로 활성화할 수 있다:

- `@EnableAutoConfiguration`: [스프링 부트의 자동 설정 메커니즘](#64-auto-configuration)을 활성화한다
- `@ComponentScan`: 애플리케이션이 위치한 패키지에 `@Component` 스캔을 활성화한다 ([베스트 프랙티스](#62-structuring-your-code) 참고)
- `@SpringBootConfiguration`: 컨텍스트에 별도 빈 등록이나 추가 설정 클래스 임포트를 활성화한다. 스프링의 표준 `@Configuration`을 대체하는 애노테이션으로, 인테그레이션 테스트에서 [설정을 감지](../testing/#detecting-test-configuration)할 수 있게 도와준다.

```java
@SpringBootApplication // same as @SpringBootConfiguration @EnableAutoConfiguration
                        // @ComponentScan
public class MyApplication {

    public static void main(String[] args) {
        SpringApplication.run(MyApplication.class, args);
    }

}
```

> `@SpringBootApplication`은 `@EnableAutoConfiguration`, `@ComponentScan`의 속성을 커스텀할 수 있는 alias도 제공한다.

> 이 기능들은 모두 필수는 아니며, 원하면 각 어노테이션이 활성화하는 기능을 직접 사용해서 대체해도 된다. 예를 들어 컴포넌트 스캔이나 설정 프로퍼티 스캔을 사용하고 싶지 않다면:
>
> ```java
> @SpringBootConfiguration(proxyBeanMethods = false)
> @EnableAutoConfiguration
> @Import({ SomeConfiguration.class, AnotherConfiguration.class })
> public class MyApplication {
> 
>     public static void main(String[] args) {
>         SpringApplication.run(MyApplication.class, args);
>     }
> 
> }
> ```
>
> 이 예제에서 `MyApplication`은 `@Component` 어노테이션이 달린 클래스와 `@ConfigurationProperties` 어노테이션이 달린 클래스는 자동으로 감지하지 않고 사용자 정의 빈을 명시적으로 임포트(`@Import`)하고 있다는 점만 제외하면, 다른 스프링 부트 애플리케이션과 별반 다르지 않다.

---

## 6.7. Running Your Application

애플리케이션을 jar로 패키징하고 임베디드 HTTP 서버를 사용했을 때 가장 좋은 점 중 하나는, 애플리케이션을 평소 다른 애플리케이션을 실행할 때처럼 똑같은 방법으로 실행할 수 있다는 거다. 스프링 부트 애플리케이션을 디버깅할 때도 마찬가지다. 특별한 IDE 플러그인이나 익스텐션은 필요하지 않다.

> 이 섹션에선 jar 기반 패키징만 다룬다. 애플리케이션을 war 파일로 패키징하기로 했다면 해당 서버와 IDE 문서를 참고해야 한다.

### 6.7.1. Running from an IDE

IDE에서선 스프링 부트 애플리케이션을 자바 애플리케이션으로 실행할 수 있다. 단, 먼저 프로젝트를 임포트해야 한다. 임포트하는 방법은 사용하는 IDE와 빌드 시스템에 따라 다르다. IDE 대부분은 메이븐 프로젝트를 직접 임포트할 수 있다. 예를 들어 Eclipse 사용자는 `File` 메뉴에서 `Import…` → `Existing Maven Projects`를 선택하면 된다.

프로젝트를 IDE로 직접 임포트할 수 없다면, 빌드 플러그인을 사용해서 IDE 메타데이터를 생성할 수 있을 거다. 메이븐에는 [Eclipse](https://maven.apache.org/plugins/maven-eclipse-plugin/)와 [IDEA](https://maven.apache.org/plugins/maven-idea-plugin/) 전용 플러그인이 포함되어 있다. 그래들은 [다양한 IDE](https://docs.gradle.org/current/userguide/userguide.html) 전용 플러그인을 제공한다.

> 의도치 않게 웹 애플리케이션을 두 번 실행하면 "Port already in use" 에러를 만나게 된다. Spring Tools 사용자는 `Run` 버튼 대신 `Relaunch` 버튼을 사용하면 기존 인스턴스를 종료할 수 있다.

### 6.7.2. Running as a Packaged Application

스프링 부트 메이븐 플러그인이나 그래들 플러그인을 사용해서 실행 가능한 jar<sup>executable jar</sup>를 만든다면, 다음 예제와 같이 `java -jar`를 사용해 애플리케이션을 실행할 수 있다:

```shell
$ java -jar target/myapplication-0.0.1-SNAPSHOT.jar
```

패키징한 애플리케이션을 원격 디버깅 지원을 활성화한 상태에서 실행할 수도 있다. 그러면 아래 보이는 것처럼 패키징한 애플리케이션에 디버거를 연결할 수 있다:

```shell
$ java -Xdebug -Xrunjdwp:server=y,transport=dt_socket,address=8000,suspend=n \
       -jar target/myapplication-0.0.1-SNAPSHOT.jar
```

### 6.7.3. Using the Maven Plugin

스프링 부트 메이븐 플러그인에는 애플리케이션을 빠르게 컴파일하고 실행할 수 있는 `run` goal이 들어 있다. 애플리케이션은 IDE에서처럼 패키징되지 않은 형태<sup>exploded form</sup>로 실행된다. 다음은 스프링 부트 애플리케이션을 실행하는 전형적인 메이븐 명령어다:

```shell
$ mvn spring-boot:run
```

다음 예제처럼 운영 체제 환경 변수 `MAVEN_OPTS`를 사용할 수도 있다:

```shell
$ export MAVEN_OPTS=-Xmx1024m
```

### 6.7.4. Using the Gradle Plugin

스프링 부트 그래들 플러그인에도 애플리케이션을 패키징되지 않은 형태<sup>exploded form</sup>로 실행할 수 있는 `bootRun` 태스크가 들어 있다. `org.springframework.boot`와 `java` 플러그인을 적용했다면 `bootRun` 태스크가 추가되며, 다음과 같이 실행할 수 있다:

```sh
$ gradle bootRun
```

다음 예제처럼 운영 체제 환경 변수 `JAVA_OPTS`를 사용할 수도 있다:

```sh
$ export JAVA_OPTS=-Xmx1024m
```

### 6.7.5. Hot Swapping

스프링 부트 애플리케이션은 순수 자바 애플리케이션이기 때문에, JVM hot-swapping은 특별한 설정 없이도 동작할 거다. JVM hot swapping은 대체할 수 있는 바이트 코드가 다소 제한적이다. 보다 완벽한 솔루션이 필요하다면 [JRebel](https://www.jrebel.com/products/jrebel)을 사용할 수 있다.

`spring-boot-devtools` 모듈 또한 빠른 애플리케이션 재시작을 지원한다. 자세한 내용은 ["How-to" 문서 Hot swapping](../howto.hot-swapping)을 참고해라.

---

## 6.8. Developer Tools

스프링 부트는 애플리케이션 개발 경험을 좀 더 쾌적하게 해주는 도구 셋을 추가로 가지고 있다. 어떤 프로젝트라도 `spring-boot-devtools` 모듈을 넣으면 개발 시점에 유용할 추가 기능들을 이용할 수 있다. devtools 지원을 포함하려면 아래 메이븐과 그래들 예시처럼 모듈 의존성을 빌드에 추가해라:

*Maven*

```xml
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-devtools</artifactId>
        <optional>true</optional>
    </dependency>
</dependencies>
```

*Gradle*

```gradle
dependencies {
    developmentOnly("org.springframework.boot:spring-boot-devtools")
}
```

> 완전히 패키징된 애플리케이션을 실행하면 Developer tools는 자동으로 비활성화된다. `java -jar`로 애플리케이션을 기동하거나 특수 클래스 로더로 기동했다면 "프로덕션 애플리케이션"으로 간주한다. 이 동작은 시스템 프로퍼티 `spring.devtools.restart.enabled`로 제어할 수 있다. 애플리케이션을 시작할 때 사용한 클래스 로더에 관계없이 devtools를 활성화하려면 시스템 프로퍼티 `-Dspring.devtools.restart.enabled=true`를 설정해라. devtools 실행 자체가 보안 위협일 수 있는 프로덕션 환경에선 이렇게 하면 안 된다. devtools를 비활성화하려면 의존성을 제외하거나 시스템 프로퍼티 `-Dspring.devtools.restart.enabled=false`를 설정해라.

> 메이븐에서 이 의존성을 optional로 지정하거나 그래들의 `developmentOnly` 설정을 사용하면 (위 예제에서처럼), devtools는 해당 프로젝트를 사용하는 다른 모듈에는 전이되지 않는다.

> 리패키징한 아카이브엔 기본적으로 devtools가 포함되지 않는다. [원격 devtools 기능](#685-remote-applications)을 사용하고 싶다면 리패키징한 아카이브에 따로 devtools를 포함시켜줘야 한다. 메이븐 플러그인을 사용한다면 `excludeDevtools` 프로퍼티를 `false`로 설정해라. 그래들 플러그인 사용 시엔 [태스크의 클래스패스에 `developmentOnly` 설정을 추가해라](https://docs.spring.io/spring-boot/docs/2.5.2/gradle-plugin/reference/htmlsingle/#packaging-executable.configuring.including-development-only-dependencies).

### 6.8.1. Property Defaults

스프링 부트에서 지원하는 라이브러리 중에는 성능을 위해 캐시를 사용하는 라이브러리가 몇 개 있다. 예를 들어 [템플릿 엔진](../developing-web-applications#template-engines)은 템플릿 파일을 반복해서 파싱하지 않도록 컴파일한 템플릿을 캐시에 저장한다. 스프링 MVC에선 스태틱 리소스를 서빙할 때 응답에 HTTP 캐시 헤더를 추가하기도 한다.

캐시는 프로덕션 환경에선 매우 유용하지만, 개발 중에는 방금 변경한 내용을 확인할 수 없어서 오히려 역효과를 가져온다. 이러한 이유로 spring-boot-devtools는 디폴트로 캐시 옵션을 비활성화한다.

캐시 옵션은 보통 `application.properties` 파일 설정으로 구성한다. 예를 들어, 타임리프는 `spring.thymeleaf.cache` 프로퍼티를 제공한다. `spring-boot-devtools` 모듈에선 이런 프로퍼티를 수동으로 설정할 필요없이, 자동으로 개발 시점에 적합한 설정을 적용해준다.

스프링 MVC나 스프링 웹플럭스 애플리케이션을 개발할 때는 웹 요청 관련 정보가 더 필요하기 때문에, developer tools는 `web` 로깅 그룹에 `DEBUG` 로깅을 활성화한다. 덕분에 들어오는 요청, 처리 중인 핸들러, 응답 결과 등에 대한 정보를 확인할 수 있다. 요청 세부 정보를 전부 남기고 싶다면 (민감 정보를 모두 포함해서) 설정 프로퍼티 `spring.mvc.log-request`나 `spring.codec.log-request-details`를 활성화하면 된다.

> 프로퍼티 기본값을 적용하고 싶지 않다면 `application.properties`에서 `spring.devtools.add-properties`를 `false`로 설정하면 된다.

> devtools로 적용되는 전체 프로퍼티를 알고 싶다면 [DevToolsPropertyDefaultsPostProcessor](https://github.com/spring-projects/spring-boot/tree/v2.5.2/spring-boot-project/spring-boot-devtools/src/main/java/org/springframework/boot/devtools/env/DevToolsPropertyDefaultsPostProcessor.java)를 확인해봐라.

### 6.8.2. Automatic Restart

`spring-boot-devtools`를 사용하는 애플리케이션은 클래스패스에 있는 파일이 변경될 때마다 자동으로 재시작된다. 코드 변경에 대한 피드백 루프를 매우 빠르게 제공하기 때문에, IDE에서 작업할 때 매우 유용할 거다. 기본적으로 디렉토리 하나를 가리키는 클래스패스에서 모든 엔트리의 변경사항을 모니터링한다. 스태틱 파일<sup>static asset</sup>이나 뷰 템플릿같은 특정 리소스들은 [애플리케이션을 다시 시작할 필요가 없다](#excluding-resources)는 점에 주의해라.

> #### Triggering a restart
> 
> DevTools는 클래스패스 리소스를 모니터링하기 대문에, 재시작을 트리거할 수 있는 유일한 방법은 클래스패스를 업데이트하는 거다. 클래스패스를 업데이트하는 법은 사용 중인 IDE에 따라 다르다.
> 
> - Eclipse에선 수정된 파일을 저장하면 클래스패스가 업데이트되고 재시작을 트리거한다.
> - IntelliJ IDEA에선 프로젝트 빌드가 (`Build → Build Project`) 동일한 효과를 가진다.
> - 빌드 플러그인을 사용하고 있다면, 메이븐에선 `mvn compile`을, 그래들에선 `gradle build`를 실행하면 재시작을 트리거한다.

> 빌드 플러그인을 사용해 메이븐이나 그래들로 재시작한다면 반드시 `forking`을 `enabled`로 설정해둬야 한다. forking을 비활성화하면 devtools에서 사용하는 격리된<sup>isolated</sup> 애플리케이션 클래스 로더가 만들어지지 않으며 재시작이 제대로 되지 않을 거다.

> 자동 재시작은 LiveReload와 함께 사용할 때도 매우 잘 동작한다. 자세한 내용은 [LiveReload 섹션을 참고해라](#683-livereload). JRebel을 사용한다면 동적으로 클래스를 재로드하기 위해 자동 재시작은 비활성화된다. 다른 devtools 기능(LiveReload와 프로퍼티 재정의 등)은 계속 사용할 수 있다.

> DevTools는 재시작할 때 애플리케이션 컨텍스트의 셧다운 훅을 사용해 종료한다. 셧다운 훅을 비활성화했다면 (`SpringApplication.setRegisterShutdownHook(false)`) 제대로 동작하지 않는다.

> DevTools는 `ApplicationContext`에서 사용하는 `ResourceLoader`를 커스텀해야 한다. 어플리케이션에서 이미 `ResourceLoader`를 제공했다면 래핑될 거다. `ApplicationContext`에서 `getResource` 메소드를 직접 재정의하는 방식은 지원하지 않는다.

> #### Restart vs Reload
>
> 스프링 부트가 애플리케이션을 재시작해줄 땐 두 가지 클래스 로더를 이용하는 테크닉을 쓴다. 변경되지 않는 클래스(ex. 써드 파티 jar에 있는 클래스들)는 *base* 클래스 로더에 로드한다. 현재 개발 중인 클래스는 *restart* 클래스 로더에 로드한다. 애플리케이션이 재시작되면 기존 *restart* 클래스 로더는 폐기되고, 새로운 클래스 로더를 만든다. 이렇게 접근하게 되면 *base* 클래스 로더는 이미 클래스를 로드한 상태로 준비돼 있기 때문에, 애플리케이션 재시작은 보통 "cold starts" 보단 훨씬 빠르다.
>
> 재시작이 그렇게 빠르지 않거나 클래스 로딩 이슈를 만나게 되면 ZeroTurnaround의 [JRebel](https://jrebel.com/software/jrebel/)과 같은 리로딩 기술을 고려해볼 수 있다. 이런 기술에선 클래스를 로드하면서 클래스를 재작성하는 식으로 리로딩한다.

#### Logging changes in condition evaluation

기본적으로는 애플리케이션이 재시작할 때마다 condition evaluation delta를 보여주는 리포트를 로깅한다. 이 리포트는 빈 추가나 제거, 설정 프로퍼티 세팅과 같은 변경으로 인해 애플리케이션의 자동 설정에 생긴 변경 사항을 보여준다.

리포트 로깅을 비활성화하려면 다음 프로퍼티를 설정해라:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.devtools.restart.log-condition-evaluation-delta=false
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  devtools:
    restart:
      log-condition-evaluation-delta: false
```

#### Excluding Resources

어떤 리소스들은 변경됐다고 해서 꼭 재시작을 트리거할 필요가 없다. 예를 들어 타임리프 템플릿은 그 자리에서 바로 편집할 수 있다. 기본적으로 `/META-INF/maven`이나 `/META-INF/resources`, `/resources`, `/static`, `/public`, `/templates`에 있는 리소스를 변경하면 재시작 대신 [live reload](#683-livereload)를 트리거한다. 재시작에서 제외시킬 리소스들을 커스텀하고 싶다면 `spring.devtools.restart.exclude` 프로퍼티를 사용하면 된다. 예를 들어 `/static`과 `/public`만 제외하려면 프로퍼티를 다음과 같이 설정하면 된다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.devtools.restart.exclude=static/**,public/**
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  devtools:
    restart:
      exclude: "static/**,public/**"
```

> 이 기본값들은 유지하되 제외시킬 리소스를 별도로 더 *추가*하려면 `spring.devtools.restart.additional-exclude` 프로퍼티를 대신 사용해라.

#### Watching Additional Paths

클래스패스에 존재하지 않는 파일을 변경했을 때도 애플리케이션을 재시작하거나 리로드하고 싶을 수 있다. `spring.devtools.restart.additional-paths` 프로퍼티를 사용해 변경 사항을 감시할 추가 경로를 설정하면 된다. 추가한 경로 아래에서 변경 사항이 발생했을 때 전체 재시작을 트리거할지 [live reload](#683-livereload)를 트리거할지는 [앞에서 설명한](#excluding-resources) `spring.devtools.restart.exclude` 프로퍼티를 사용해 제어할 수 있다.

#### Disabling Restart

재시작 기능을 사용하고 싶지 않다면 `spring.devtools.restart.enabled` 프로퍼티로 비활성화할 수 있다. 대부분은 이 프로퍼티는 `application.properties`에 설정하면 된다 (이렇게하면 restart 클래스 로더를 초기화하긴 하지만 파일의 변경 사항을 감시하지 않는다).

재시작 지원을 *완전히* 꺼버리고 싶다면 (예를 들어 특정 라이브러리와 함께 사용했을 때 잘 동작하지 않는 경우 등), 다음 예제에서와 같이 `SpringApplication.run(…)`을 호출하기 전에  `System` 프로퍼티 `spring.devtools.restart.enabled`를 `false`로 설정해야 한다:

```java
@SpringBootApplication
public class MyApplication {

    public static void main(String[] args) {
        System.setProperty("spring.devtools.restart.enabled", "false");
        SpringApplication.run(MyApplication.class, args);
    }

}
```

#### Using a Trigger File

변경된 파일을 계속해서 컴파일하는 IDE로 작업 중이라면, 특정 시점에만 재시작을 트리거하는 게 좋다. 이땐 "트리거 파일"이란 특별한 파일을 이용해서, 실제로 재시작 검사를 트리거하고 싶을 때만 수정해주면 된다.

> 이 파일을 수정할 때마다 검사를 트리거하긴 하지만, 실제 재시작은 Devtools가 할 일이 있음을 감지한 경우에만 발생한다.

트리거 파일을 사용하려면 `spring.devtools.restart.trigger-file` 프로퍼티를 트리거 파일의 이름으로 설정해라 (경로는 전부 제외). 트리거 파일은 클래스패스 어딘가엔 있어야 한다.

예를 들어 프로젝트 구조가 다음과 같다면:

```
src
+- main
   +- resources
      +- .reloadtrigger
```

`trigger-file` 프로퍼티는 다음과 같이 설정할 수 있다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.devtools.restart.trigger-file=.reloadtrigger
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  devtools:
    restart:
      trigger-file: ".reloadtrigger"
```

이제 `src/main/resources/.reloadtrigger`가 업데이트됐을 때만 재시작될 거다.

> `spring.devtools.restart.trigger-file`을 [글로벌 설정](#684-global-settings)으로 설정하면 모든 프로젝트가 같은 방식으로 동작하게 된다.

일부 IDE에선 트리거 파일을 수동으로 업데이트하지 않아도 된다. [Eclipse 전용 Spring Tools](https://spring.io/tools)와 [IntelliJ IDEA (Ultimate Edition)](https://www.jetbrains.com/idea/) 모두 이 기능을 지원한다. Spring Tools를 사용하면 콘솔 뷰에서 "reload" 버튼을 사용하면 된다 (`trigger-file` 이름이 `.reloadtrigger`인 경우에 한해). IntelliJ IDEA에선 [문서에 있는 가이드](https://www.jetbrains.com/help/idea/spring-boot.html#application-update-policies)를 따르면 된다.

#### Customizing the Restart Classloader

앞서 [Restart vs Reload](#restart-vs-reload) 섹션에서 설명했듯이 재시작 기능은 두 개의 클래스 로더를 사용해 구현한다. 이 방식은 대부분의 애플리케이션에서 잘 동작한다. 하지만 클래스 로딩 이슈가 발생할 때도 있다.

기본적으로 IDE에서 열려있는 모든 프로젝트는 "restart" 클래스 로더로 로드되고, 일반 `.jar` 파일은 "base" 클래스 로더로 로드된다. 멀티 모듈 프로젝트에서 작업하면서 모든 모듈을 IDE로 임포트하지 않았다면, 로드 대상을 커스텀해야 할 수도 있다. 커스텀하려면 `META-INF/spring-devtools.properties` 파일을 만들면 된다.

`spring-devtools.properties` 파일에는 `restart.exclude`와 `restart.include`로 시작하는 프로퍼티를 담으면 된다. `include` 요소는 "restart" 클래스 로더로 가져와야 하는 항목이고, `exclude` 요소는 "base" 클래스 로더로 가져와야 하는 항목들이다. 프로퍼티 값에는 다음 예제에서 보이는 것처럼 클래스패스에 적용할 정규식 패턴을 사용한다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
restart.exclude.companycommonlibs=/mycorp-common-[\\w\\d-\\.]+\\.jar
restart.include.projectcommon=/mycorp-myproj-[\\w\\d-\\.]+\\.jar
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
restart:
  exclude:
    companycommonlibs: "/mycorp-common-[\\w\\d-\\.]+\\.jar"
  include:
    projectcommon: "/mycorp-myproj-[\\w\\d-\\.]+\\.jar"
```

> 모든 프로퍼티 키는 유니크해야 한다. `restart.include.`나 `restart.exclude.`로 시작하는 각 프로퍼티는 하나만 반영된다.

> 클래스패스에 `META-INF/spring-devtools.properties`가 있으면 전부 로드한다. 이런 파일들은 프로젝트 내부에 패키징해도 되고, 프로젝트가 사용하는 라이브러리에 패키징해도 된다.

#### Known Limitations

재시작 기능은 표준 `ObjectInputStream`을 사용해 역직렬화한 객체에선 제대로 동작하지 않는다. 데이터를 역직렬화해야 한다면 스프링의 `ConfigurableObjectInputStream`을 `Thread.currentThread().getContextClassLoader()`와 함께 사용해야 할 수도 있다.

안타깝게도 일부 써드 파티 라이브러리에선 컨텍스트 클래스 로더를 고려하지 않고 역직렬화를 수행한다. 이러한 문제를 발견하면 원저자에게 수정을 요청해야 한다.

### 6.8.3. LiveReload

`spring-boot-devtools` 모듈에는 리소스가 변경 되면 브라우저 새로 고침을 트리거할 수 있는 임베디드 LiveReload 서버가 포함돼 있다. LiveReload 브라우저 익스텐션은 [livereload.com](http://livereload.com/extensions/)에서 받을 수 있으며, Chrome, Firefox, Safari에서 무료로 제공한다.

애플리케이션을 실행할 때 LiveReload 서버를 시작하고 싶지 않다면 `spring.devtools.livereload.enabled` 프로퍼티를 `false`로 설정하면 된다.

> LiveReload 서버는 한 번에 하나만 실행할 수 있다. 애플리케이션을 시작하기 전에 다른 LiveReload 서버가 실행 중이진 아닌지 먼저 확인해봐라. IDE에서 애플리케이션을 여러 개 기동하면, 제일 먼저 시작한 애플리케이션에서만 LiveReload를 사용할 수 있다.

> 파일이 변경될 때 LiveReload를 트리거하려면 [자동 재시작](# 682-automatic-restart)을 활성화해야 한다.

### 6.8.4. Global Settings

`$HOME/.config/spring-boot` 디렉토리에 다음 파일 중 하나를 추가하면 글로벌 devtools 설정을 구성할 수 있다:

1. `spring-boot-devtools.properties`
2. `spring-boot-devtools.yaml`
3. `spring-boot-devtools.yml`

이 파일에 추가한 모든 프로퍼티는 devtools를 사용하는 해당 기기의 *모든* 스프링 부트 애플리케이션에 적용된다. 예를 들어 항상 [트리거 파일](#using-a-trigger-file)을 통해 재시작하도록 설정하고 싶으면 `spring-boot-devtools` 파일에 다음 프로퍼티를 추가하면 된다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.devtools.restart.trigger-file=.reloadtrigger
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  devtools:
    restart:
      trigger-file: ".reloadtrigger"
```

> `$HOME/.config/spring-boot`에 devtools 설정 파일이 없으면 `$HOME` 디렉토리의 루트에서 `.spring-boot-devtools.properties` 파일이 있는지 찾아본다. 따라서 `$HOME/.config/spring-boot` 위치를 지원하지 않는 구버전 스프링 부트를 사용하는 애플리케이션과 devtools 글로벌 설정을 공유할 수 있다.

> devtools properties/yaml 파일에선 프로파일을 지원하지 않는다. `.spring-boot-devtools.properties`에선 프로파일을 활성화해도 그에따라 [프로파일 전용 설정 파일](../externalized-configuration#profile-specific-files)을 로드하지 않는다. YAML과 Properties 파일 모두 프로파일을 특정하는 파일 이름(`spring-boot-devtools-<profile>.properties` 형식)과 `spring.config.activate.on-profile` 도큐먼트를 지원하지 않는다.

#### Configuring File System Watcher

[FileSystemWatcher](https://github.com/spring-projects/spring-boot/tree/v2.5.2/spring-boot-project/spring-boot-devtools/src/main/java/org/springframework/boot/devtools/filewatch/FileSystemWatcher.java)는 특정 시간 간격으로 클래스의 변경 사항을 폴링해서, 미리 정의된 휴지 기간<sup>quiet period</sup> 동안 기다리면서 더 이상 변경이 없는지 확인한다. 스프링 부트는 스프링 부트가 읽을 수 있는 위치로 파일을 컴파일하고 복사할 때 전적으로 IDE에 의존하기 때문에, devtools가 애플리케이션을 재시작했을 때 변경 사항이 얼마동안 반영되지 않을 수도 있다. 이 문제가 지속적으로 나타나면 `spring.devtools.restart.poll-interval`과 `spring.devtools.restart.quiet-period` 파라미터를 개발 환경에 맞는 값으로 늘려봐라:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.devtools.restart.poll-interval=2s
spring.devtools.restart.quiet-period=1s
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  devtools:
    restart:
      poll-interval: "2s"
      quiet-period: "1s"
```

이제 2초마다 모니터링하는 클래스패스 디렉토리의 변경 사항을 폴링하며, 다른 클래스 변경 사항이 추가로 없는지 확인하기 위해 1초 동안 휴지 기간을 유지한다.

### 6.8.5. Remote Applications

스프링 부트 developer tools는 로컬에서 개발할 때만 활용할 수 있는 건 아니다. 애플리케이션을 원격으로 실행할 때도 몇 가지 기능을 사용할 수 있다. 원격 지원은 보안을 위협하는 요소일 수 있기 때문에 기본적으론 비활성화돼 있다. 신뢰할 수 있는 네트워크에서 실행하거나 SSL을 통해 보호 중일 때만 활성화해야 한다. 이런 옵션이 전부 불가능하다면 DevTools의 원격 지원을 사용해선 안 된다. 프로덕션 배포에선 절대 이 기능을 활성화하면 안 된다.

원격 지원을 활성화하려면 다음과 같이 리패키징된 아카이브에 `devtools`를 포함시켜야 한다:

```xml
<build>
    <plugins>
        <plugin>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-maven-plugin</artifactId>
            <configuration>
                <excludeDevtools>false</excludeDevtools>
            </configuration>
        </plugin>
    </plugins>
</build>
```

그다음 `spring.devtools.remote.secret` 프로퍼티를 설정해야 한다. 중요한 패스워드나 시크릿 정보와 마찬가지로, 이 값은 단순히 추측하거나 무차별 대입<sup>brute-forced</sup>으로 알아낼 수 없을만큼 유니크하고 견고해야 한다.

원격 devtools 지원은 커넥션을 수용하는 서버 사이드 엔드포인트와, IDE에서 직접 실행하는 클라이언트 애플리케이션, 이 두가지로 나눠서 제공한다. 서버 컴포넌트는 `spring.devtools.remote.secret` 프로퍼티를 설정하면 자동으로 활성화된다. 클라이언트 컴포넌트는 직접 수동으로 시작해야 한다.

#### Running the Remote Client Application

원격 클라이언트 애플리케이션은 IDE 내에서만 실행하도록 설계했다. 연결할 원격 프로젝트와 동일한 클래스패스로 `org.springframework.boot.devtools.RemoteSpringApplication`을 실행해야 한다. 애플리케이션의 유일한 필수 인자는 커넥션을 맺을 원격 URL이다.

예를 들어 Eclipse나 Spring Tools를 사용 중이고, Cloud Foundry에 `my-app`이라는 프로젝트를 배포했다면 아래 절차대로 따라하면 된다:

- `Run` 메뉴에서 `Run Configurations…`를 선택한다.
- 새로운 `Java Application` "launch configuration"을 생성한다.
- `my-app` 프로젝트를 찾는다.
- `org.springframework.boot.devtools.RemoteSpringApplication`을 메인 클래스로 사용한다.
- `Program arguments`에 `https://myapp.cfapps.io`(또는 사용할 원격 URL)를 추가한다.

원격 클라이언트를 실행하면 다음과 유사한 문구를 볼 수 있을 거다:

```java
  .   ____          _                                              __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _          ___               _      \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` |        | _ \___ _ __  ___| |_ ___ \ \ \ \
 \\/  ___)| |_)| | | | | || (_| []::::::[]   / -_) '  \/ _ \  _/ -_) ) ) ) )
  '  |____| .__|_| |_|_| |_\__, |        |_|_\___|_|_|_\___/\__\___|/ / / /
 =========|_|==============|___/===================================/_/_/_/
 :: Spring Boot Remote :: 2.5.2

2015-06-10 18:25:06.632  INFO 14938 --- [           main] o.s.b.devtools.RemoteSpringApplication   : Starting RemoteSpringApplication on pwmbp with PID 14938 (/Users/pwebb/projects/spring-boot/code/spring-boot-project/spring-boot-devtools/target/classes started by pwebb in /Users/pwebb/projects/spring-boot/code)
2015-06-10 18:25:06.671  INFO 14938 --- [           main] s.c.a.AnnotationConfigApplicationContext : Refreshing org.springframework.context.annotation.AnnotationConfigApplicationContext@2a17b7b6: startup date [Wed Jun 10 18:25:06 PDT 2015]; root of context hierarchy
2015-06-10 18:25:07.043  WARN 14938 --- [           main] o.s.b.d.r.c.RemoteClientConfiguration    : The connection to http://localhost:8080 is insecure. You should use a URL starting with 'https://'.
2015-06-10 18:25:07.074  INFO 14938 --- [           main] o.s.b.d.a.OptionalLiveReloadServer       : LiveReload server is running on port 35729
2015-06-10 18:25:07.130  INFO 14938 --- [           main] o.s.b.devtools.RemoteSpringApplication   : Started RemoteSpringApplication in 0.74 seconds (JVM running for 1.105)
```

> 원격 클라이언트는 실제 애플리케이션과 동일한 클래스패스를 사용하기 때문에 애플리케이션 프로퍼티를 직접 읽을 수 있다. 덕분에 `spring.devtools.remote.secret` 프로퍼티를 읽고 서버에 전달해 인증할 수 있다.

> 커넥션 프로토콜로는 항상 `https://`를 사용해서 트래픽을 암호화하고 패스워드를 가로챌 수 없도록 하는 게 좋다.

> 원격 애플리케이션에 접근할 때 프록시를 사용해야 한다면 `spring.devtools.remote.proxy.host`와 `spring.devtools.remote.proxy.port` 프로퍼티를 설정해라.

#### Remote Update

원격 클라이언트는 [로컬 재시작](#682-automatic-restart)과 같은 방식으로 애플리케이션 클래스패스의 변경 사항을 모니터링한다. 업데이트된 리소스가 있다면 원격 애플리케이션으로 푸시되고 (*필요 시*) 재시작을 트리거한다. 로컬엔 없는 클라우드 서비스를 사용하는 기능을 계속해서 변경하는 경우 유용할 거다. 보통은 원격 업데이트와 재시작은 전체 재빌드와 배포 사이클보다 훨씬 빠르다.

개발 환경이 느리다면 휴지 기간이 충분하지 않을 수도 있고, 클래스의 변경 사항이 배치로 분할될 수도 있다. 서버는 클래스 변경을 알리는 첫 번째 배치가 업로드된 후에 재시작된다. 서버가 재시작되기 때문에 다음 배치는 애플리케이션으로 전송할 수 없게 된다.

이 문제는 보통 일부 클래스 업로드 실패와 그에 따른 재시도를 나타내는 `RemoteSpringApplication`의 경고 로그로 드러나게 된다. 문제는 첫 번째 변경 배치가 업로드된 후에 애플리케이션 코드가 일관성을 잃고 재시작 실패로도 이어질 수 있다는 점이다. 이 문제가 지속적으로 나타나면 `spring.devtools.restart.poll-interval`과 `spring.devtools.restart.quiet-period` 파라미터를 개발 환경에 맞는 값으로 늘려봐라. 이 프로퍼티를 설정하려면 [파일 시스템 와처 설정하기](#configuring-file-system-watcher) 섹션을 참고해라.

> 파일들은 원격 클라이언트가 실행 중일 때만 모니터링된다. 원격 클라이언트를 시작하기 전에는 파일을 변경해도 원격 서버로 푸시되지 않는다.

---

## 6.9. Packaging Your Application for Production

프로덕션 배포에는 실행 가능한 jar<sup>executable jar</sup>를 이용할 수 있다. 이 jar는 자립적으로 실행할 수 있기 때문에<sup>self-contained</sup>, 클라우드 기반 배포에도 잘 들어맞는다.

상태 체크<sup>health</sup>, 감사<sup>auditing</sup>, 메트릭 REST, JMX 엔드포인트와 같은 추가적인 "production ready" 기능이 필요하다면 `spring-boot-actuator`를 추가해보는 것도 좋다. 자세한 내용은 *[Spring Boot Actuator: Production-ready Features](../spring-boot-actuator)*를 참고해라.

---

## 6.10. What to Read Next

이제 스프링 부트 사용법과 따라야 할 베스트 프랙티스들에 대해 이해했을 거다. 이제 특정 *[스프링 부트 기능](../spring-boot-features)*을 깊히 알아 봐도 좋고, 스프링 부트의 "[production ready](../spring-boot-actuator)" 쪽을 살펴봐도 된다.
