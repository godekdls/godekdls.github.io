---
title: Properties and Configuration
category: Spring Boot 2.X
order: 58
permalink: /Spring%20Boot/howto.properties-and-configuration/
description: 스프링 부트 프로퍼티와 관련된 how to 가이드 (설정 파일 정의하기, 프로파일 활성화하기, 환경에 따라 설정 변경하기 등)
image: ./../../images/springboot/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 부트
originalRefLink: https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#howto.properties-and-configuration
parent: “How-to” Guides
parentUrl: /Spring%20Boot/how-to-guides/
priority: 0.4
---
<script>defaultLanguages = ['properties']</script>

### 목차

- [12.2.1. Automatically Expand Properties at Build Time](#1221-automatically-expand-properties-at-build-time)
  + [Automatic Property Expansion Using Maven](#automatic-property-expansion-using-maven)
  + [Automatic Property Expansion Using Gradle](#automatic-property-expansion-using-gradle)
- [12.2.2. Externalize the Configuration of SpringApplication](#1222-externalize-the-configuration-of-springapplication)
- [12.2.3. Change the Location of External Properties of an Application](#1223-change-the-location-of-external-properties-of-an-application)
- [12.2.4. Use ‘Short’ Command Line Arguments](#1224-use-short-command-line-arguments)
- [12.2.5. Use YAML for External Properties](#1225-use-yaml-for-external-properties)
- [12.2.6. Set the Active Spring Profiles](#1226-set-the-active-spring-profiles)
- [12.2.7. Set the Default Profile Name](#1227-set-the-default-profile-name)
- [12.2.8. Change Configuration Depending on the Environment](#1228-change-configuration-depending-on-the-environment)
- [12.2.9. Discover Built-in Options for External Properties](#1229-discover-built-in-options-for-external-properties)

---

## 12.2. Properties and Configuration

이번 섹션은 프로퍼티와 설정 정보들을 읽어오고 설정하는 것과, 이 것들이 스프링 부트 애플리케이션과 하는 상호 작용과 관련된 토픽들을 담고있다.

### 12.2.1. Automatically Expand Properties at Build Time

프로젝트의 빌드 설정에 이미 명시한 프로퍼티들은 하드코딩하는 대신 기존의 빌드 설정을 활용해서 자동으로 확장할 수 있다. 메이븐과 그래들에서 모두 가능하다.

#### Automatic Property Expansion Using Maven

메이븐 프로젝트에 있는 프로퍼티는 리소스 필터링을 사용해 자동으로 확장할 수 있다. `spring-boot-starter-parent`를 사용한다면 다음 예제와 같이 `@..@` 플레이스홀더를 통해 메이븐 '프로젝트 프로퍼티'를 참조할 수 있다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
app.encoding=@project.build.sourceEncoding@
app.java.version=@java.version@
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
app:
  encoding: "@project.build.sourceEncoding@"
  java:
    version: "@java.version@"
```

> 프로덕션 설정만 이런식으로 필터링된다 (다시 말해, `src/test/resources`에는 필터링이 적용되지 않는다).

> `addResources` 플래그를 활성화하면 `spring-boot:run` goal에서 바로 `src/main/resources`를 클래스패스에 추가할 수 있다 (hot reloading을 사용할 목적으로). 이렇게 하면 리소스 필터링과 이 기능을 우회할 수 있다. 대신에 `exec:java` goal을 사용하거나 플러그인 설정을 커스텀해도 된다. 자세한 내용은 [플러그인 사용 페이지](https://docs.spring.io/spring-boot/docs/2.5.2/maven-plugin/reference/htmlsingle/#getting-started)를 참고해라.

starter parent를 사용하지 않는다면 `pom.xml`의 `<build/>` 요소 안에 아래 요소를 추가해야 한다:

```xml
<resources>
    <resource>
        <directory>src/main/resources</directory>
        <filtering>true</filtering>
    </resource>
</resources>
```

`<plugins/>` 안에는 다음 요소도 추가해야 한다:

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-resources-plugin</artifactId>
    <version>2.7</version>
    <configuration>
        <delimiters>
            <delimiter>@</delimiter>
        </delimiters>
        <useDefaultDelimiters>false</useDefaultDelimiters>
    </configuration>
</plugin>
```

> 설정에서 표준 스프링 플레이스홀더(ex. `${placeholder}`)를 사용하고 있을 때는 `useDefaultDelimiters` 프로퍼티가 중요하다. 이 프로퍼티를 `false`로 설정하지 않으면 빌드하면서 설정 값이 변경돼버릴 수도 있다.

#### Automatic Property Expansion Using Gradle

그래들 프로젝트에 있는 프로퍼티는 자바 플러그인의 `processResources` 태스크를 설정해주면 자동으로 확장할 수 있다:

```gradle
processResources {
    expand(project.properties)
}
```

이렇게 설정해줬다면 아래 예제처럼 플레이스홀더를 통해 그래들 프로젝트의 프로퍼티를 참조할 수 있다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
app.name=${name}
app.description=${description}
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
app:
  name: "${name}"
  description: "${description}"
```

> 그래들의 `expand` 메소드는 `${..}` 토큰을 변환하는 Groovy의 `SimpleTemplateEngine`을 사용한다. `${..}` 스타일은 스프링의 자체 프로퍼티 플레이스홀더 메커니즘과 충돌한다. 스프링 프로퍼티 플레이스홀더를 자동 확장과 함께 사용하려면, 스프링 프로퍼티 플레이스홀더를 `\${..}`와 같이 이스케이프해라.

### 12.2.2. Externalize the Configuration of SpringApplication

`SpringApplication`은 빈 프로퍼티 setter를 가지고 있기 때문에, 애플리케이션을 생성할 땐 이 자바 API를 사용하면 동작을 수정할 수 있다. 아니면 `spring.main.*`에 프로퍼티를 설정하는 식으로 설정을 밖으로 빼도 된다. 예를 들어 `application.properties`에는 다음과 같은 설정이 있을 수 있다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.main.web-application-type=none
spring.main.banner-mode=off
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  main:
    web-application-type: "none"
    banner-mode: "off"
```

이렇게 하면 기동 시에 스프링 배너를 출력하지 않고, 애플리케이션은 임베디드 웹 서버를 시작하지 않는다.

외부 설정에 정의한 프로퍼티는 특별히 주요 소스만 빼고는 모두 자바 API로 지정한 값을 재정의하고 대체한다. 주요 소스는 `SpringApplication` 생성자로 제공하는 소스를 뜻한다:

```java
@SpringBootApplication
public class MyApplication {

    public static void main(String[] args) {
        SpringApplication application = new SpringApplication(MyApplication.class);
        application.setBannerMode(Banner.Mode.OFF);
        application.run(args);
    }

}
```

또는 `SpringApplicationBuilder`의 `sources(…)` 메소드로 제공하기도 한다:

```java
public class MyApplication {

    public static void main(String[] args) {
        new SpringApplicationBuilder()
            .bannerMode(Banner.Mode.OFF)
            .sources(MyApplication.class)
            .run(args);
    }

}
```

위 예제에서 다음과 같은 설정을 가지고 있다면:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.main.sources=com.example.MyDatabaseConfig,com.example.MyJmsConfig
spring.main.banner-mode=console
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  main:
    sources: "com.example.MyDatabaseConfig,com.example.MyJmsConfig"
    banner-mode: "console"
```

실제 애플리케이션은 배너를 출력하고 (설정으로 재정의됐다), `ApplicationContext`에 세 가지 소스를 사용한다. 사용하는 애플리케이션 소스는 다음과 같다:

1. `MyApplication` (코드에서 가져온)
2. `MyDatabaseConfig` (외부 설정에서 가져온)
3. `MyJmsConfig` (외부 설정에서 가져온)

### 12.2.3. Change the Location of External Properties of an Application

기본적으로 다른 소스로 정의한 프로퍼티들은 정해진 순서대로 스프링 `Environment`에 추가된다 (정확한 순서는 '스프링 부트 기능' 섹션에 있는 "[외부 설정](../externalized-configuration)"을 참고해라).

다음과 같은 시스템 프로퍼티(또는 환경 변수)를 제공하면 이 동작을 변경할 수도 있다:

- `spring.config.name` (`SPRING_CONFIG_NAME`): 파일 명의 루트로, 기본값은 `application`이다.
- `spring.config.location` (`SPRING_CONFIG_LOCATION`): 로드할 파일 (ex. 클래스패스 리소스나 URL). 이를 위한 별도의 `Environment` 프로퍼티 소스가 설정돼 있으며, 시스템 프로퍼티나 환경 변수, 커맨드라인으로 재정의할 수 있다.

environment에 무엇을 설정하든 간에 스프링 부트는 항상 위에서 설명한 대로 `application.properties`를 로드한다. YAML을 사용하면 '.yml'을 확장자로 사용하는 파일도 기본으로 목록에 추가된다.

스프링 부트는 로드한 설정 파일은 `DEBUG` 레벨로 로그를 남기며, 찾지 못한 후보들은 `TRACE` 레벨로 기록한다.

자세한 내용은 [`ConfigFileApplicationListener`](https://github.com/spring-projects/spring-boot/tree/v2.5.2/spring-boot-project/spring-boot/src/main/java/org/springframework/boot/context/config/ConfigFileApplicationListener.java)를 참고해라.

### 12.2.4. Use ‘Short’ Command Line Arguments

간혹 커맨드라인에서 (예를 들자면) `--server.port=9000` 대신 `--port=9000`을 사용해서 프로퍼티를 설정하길 좋아하는 사람들이 있다. 이렇게 사용하고 싶을 땐 아래처럼 `application.properties`에 플레이스홀더를 사용하면 된다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
server.port=${port:8080}
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
server:
  port: "${port:8080}"
```

> `spring-boot-starter-parent` POM을 상속했다면, `maven-resources-plugins`의 디폴트 필터 토큰은 `${*}`에서 `@`로 변경돼서 스프링의 플레이스홀더와의 충돌을 막아준다 (즉, `${maven.token}`이 아닌 `@maven.token@`). `application.properties`에서 활용할 용도로 메이븐 필터링을 직접 활성화했을 때에도 디폴트 필터 토큰을 [다른 구분 기호](https://maven.apache.org/plugins/maven-resources-plugin/resources-mojo.html#delimiters)로 변경해주는 게 좋다.

> 이렇게 설정했을 때는 Heroku나 Cloud Foundry같은 PaaS 환경에선 포트 바인딩이 동작한다. 이 두 플랫폼에선 `PORT` 환경 변수가 자동으로 설정되고, 스프링은 대문자로 지정한 환경변수도 `Environment` 프로퍼티에 바인딩할 수 있다.

### 12.2.5. Use YAML for External Properties

YAML은 JSON의 상위 집합으로, 아래 보이는 것처럼 외부 프로퍼티를 계층구조로 저장할 수 있어 편리하다:

```yaml
spring:
  application:
    name: "cruncher"
  datasource:
    driver-class-name: "com.mysql.jdbc.Driver"
    url: "jdbc:mysql://localhost/test"
server:
  port: 9000
```

`application.yml`이란 파일을 만들어 클래스패스 루트에 넣어라. 그런 다음 의존성에 `snakeyaml`을 추가해라 (메이븐 좌표<sup>coordinates</sup>는 `org.yaml:snakeaml`이며, `spring-boot-starter`를 사용하고 있다면 이미 추가됐을 거다). YAML 파일은 자바 `Map<String,Object>`로 파싱되며 (JSON 객체와 유사하게), 스프링 부트에선 이 맵을 펼쳐서<sup>flatten</sup> 자바의 `Properties` 파일에서 많이들 사용하는 것처럼 depth는 하나로 줄이고, 점(`.`)으로 키를 구분한다.

앞에서 보여준 YAML은 아래 있는 `application.properties` 파일과 동일하다:

```properties
spring.application.name=cruncher
spring.datasource.driver-class-name=com.mysql.jdbc.Driver
spring.datasource.url=jdbc:mysql://localhost/test
server.port=9000
```

YAML에 대해 좀 더 자세히 알고 싶다면 '스프링 부트 기능' 섹션에 있는 "[YAML로 작업하기](../externalized-configuration#725-working-with-yaml)"를 읽어봐라.

### 12.2.6. Set the Active Spring Profiles

스프링 `Environment`에도 스프링 프로파일을 설정할 수 있는 API가 있긴 하지만, 보통은 시스템 프로퍼티(`spring.profiles.active`)나 OS 환경 변수(`SPRING_PROFILES_ACTIVE`)를 설정한다. 아래처럼 애플리케이션을 기동할 때 `-D` 인자를 사용하는 방법도 있다 (메인 클래스나 jar 아카이브 앞에 둬야 한다는 점에 주의해라):

```shell
$ java -jar -Dspring.profiles.active=production demo-0.0.1-SNAPSHOT.jar
```

스프링 부트에선 아래 예제처럼 `application.properties`에서도 활성 프로파일을 설정할 수 있다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.profiles.active=production
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  profiles:
    active: "production"
```

이 방법으로 프로파일을 설정하게되면 시스템 프로퍼티나 환경 변수를 설정했을 땐 덮어써지지만, `SpringApplicationBuilder.profiles()` 메소드로는 교체되지 않는다. 그렇기 때문에 후자의 자바 API를 사용하면 기본값을 변경하지 않으면서 프로파일을 더 추가할 수 있다.

자세한 내용은 "스프링 부트 기능" 섹션에서 "[프로파일](../profiles)"을 찾아 읽어봐라.

### 12.2.7. Set the Default Profile Name

디폴트 프로파일은 활성 프로파일이 없을 때 사용하는 프로파일이다. 기본적으로 디폴트 프로파일명은 `default`지만, 시스템 프로퍼티(`spring.profiles.default`)나 OS 환경 변수(`SPRING_PROFILES_DEFAULT`)로 변경할 수 있다.

스프링 부트에선 아래 예제처럼 `application.properties`에서도 디폴트 프로파일명을 설정할 수 있다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.profiles.default=dev
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  profiles:
    default: "dev"
```

자세한 내용은 "스프링 부트 기능" 섹션에서 "[프로파일](../profiles)"을 찾아 읽어봐라.

### 12.2.8. Change Configuration Depending on the Environment

스프링 부트는 multi-document YAML, Properties 파일을 지원하며 (자세한 내용은 [multi-document 파일로 작업하기](../externalized-configuration#working-with-multi-document-files) 참고), 이 도큐먼트들은 활성 프로파일 조건에 따라 활성화할 수 있다.

도큐먼트에 `spring.config.activate.on-profile` 키가 들어있다면, 거기에 있는 프로파일 값(프로파일들을 쉼표로 구분하거나, 또는 프로파일 표현식)은 스프링의 `Environment.acceptsProfiles()` 메소드에 넘겨진다. 매칭되는 프로파일 표현식을 가지고 있는 문서가 최종적으로 병합된다 (매칭되지 않으면 병합 시에 사용하지 않는다):

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
server.port=9000
#---
spring.config.activate.on-profile=development
server.port=9001
#---
spring.config.activate.on-profile=production
server.port=0
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
server:
  port: 9000
---
spring:
  config:
    activate:
      on-profile: "development"
server:
  port: 9001
---
spring:
  config:
    activate:
      on-profile: "production"
server:
  port: 0
```

위 예제에선 9000이 디폴트 포트다. 하지만 `development`란 스프링 프로파일이 활성화되면 9001 포트를 사용한다. `production`을 활성화하면 0번 포트를 사용한다.

> 도큐먼트는 만나는 순서대로 병합한다. 뒤에 있는 값이 앞에 있는 값보다 우선순위가 높다.

### 12.2.9. Discover Built-in Options for External Properties

스프링 부트는 런타임에 `application.properties`(또는 `.yml` 파일 등)에 있는 외부 프로퍼티를 애플리케이션에 바인딩한다. 클래스패스에 있는 다른 jar 파일에서도 프로퍼티를 가져올 수 있기 때문에, 한 곳에서 다 가져오는 전체 지원 프로퍼티 목록같은 건 존재하지 않으며, 기술적으로도 불가능하다.

액추에이터를 추가해서 실행한 애플리케이션은 `configprops` 엔드포인트를 이용할 수 있으며, 이 엔드포인트에선  `@ConfigurationProperties`를 통해 바인딩됐거나 바인딩할 수 있는 모든 프로퍼티를 확인할 수 있다.

부록에는 스프링 부트에서 지원하는 프로퍼티 중 가장 많이 쓰이는 프로퍼티 목록과 [`application.properties`](https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#application-properties) 예제가 들어 있다. 프로퍼티는 소스 코드에서 `@ConfigurationProperties`와 `@Value` 어노테이션을 찾아보는 게 가장 확실하며, 한 번씩은 `Binder`를 사용해서 가져오기도 한다. 프로퍼티를 로드하는 정확한 순서가 알고 싶다면 "[외부 설정](../externalized-configuration)" 챕터를 확인해봐라.
