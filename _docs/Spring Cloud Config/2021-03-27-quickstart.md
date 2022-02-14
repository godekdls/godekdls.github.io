---
title: Quick Start
category: Spring Cloud Config
order: 2
permalink: /Spring%20Cloud%20Config/quick-start/
description: 스프링 클라우드 컨피그 퀵스타트 가이드를 한국어로 번역한 문서입니다.
image: ./../../images/springcloud/logo.jpeg
lastmod: 2021-03-31T22:00:00+09:00
comments: true
originalRefName: 스프링 클라우드 컨피그
originalRefLink: https://docs.spring.io/spring-cloud-config/docs/3.0.3/reference/html/#_quick_start
---

### 목차

- [Client Side Usage](#client-side-usage)

---

여기서는 스프링 클라우드 컨피그 서버의 서버 사용법과 클라이언트 사용법을 함께 안내한다.

먼저, 다음과 같이 서버를 시작한다:

```bash
$ cd spring-cloud-config-server
$ ../mvnw spring-boot:run
```

이 서버는 스프링 부트 어플리케이션이므로, 원한다면 IDE에서 실행해도 된다 (메인 클래스는 `ConfigServerApplication`이다).

다음으로 아래와 같이 클라이언트를 사용해보자:

```bash
$ curl localhost:8888/foo/development
{
  "name": "foo",
  "profiles": [
    "development"
  ]
  ....
  "propertySources": [
    {
      "name": "https://github.com/spring-cloud-samples/config-repo/foo-development.properties",
      "source": {
        "bar": "spam",
        "foo": "from foo development"
      }
    },
    {
      "name": "https://github.com/spring-cloud-samples/config-repo/foo.properties",
      "source": {
        "foo": "from foo props",
        "democonfigclient.message": "hello spring io"
      }
    },
    ....
```

기본 전략에선 git 레포지토리(`spring.cloud.config.server.git.uri`)를 클론해와 프로퍼티 소스를 찾고, 그 값을 사용해 미니 `SpringApplication`을 초기화한다. 이 미니 어플리케이션의 `Environment`로 프로퍼티 소스들을 나열해 JSON 엔드포인트에 게시한다.

HTTP 서비스는 아래과 같은 유형의 리소스를 가진다:

```
/{application}/{profile}[/{label}]
/{application}-{profile}.yml
/{label}/{application}-{profile}.yml
/{application}-{profile}.properties
/{label}/{application}-{profile}.properties
```

예를 들어:

```sh
curl localhost:8888/foo/development
curl localhost:8888/foo/development/master
curl localhost:8888/foo/development,db/master
curl localhost:8888/foo-development.yml
curl localhost:8888/foo-db.properties
curl localhost:8888/master/foo-db.properties
```

여기서 `application`은 `SpringApplication`의 `spring.config.name`으로 주입되며 (전형적인 스프링 부트 앱에서는 보통 `application`), `profile`은 활성 프로파일 (또는 콤마로 구분한 프로퍼티 리스트), `label`은 생략 가능한 git 레이블이다 (기본값은 `master`).

스프링 클라우드 컨피그 서버는 리모트 클라이언트를 위한 설정을 다양한 소스에서 받아온다. 다음 예제는 아래에 있는 git 레포지토리(반드시 제공해야 하는 값)에서 설정을 가져온다:

```yaml
spring:
  cloud:
    config:
      server:
        git:
          uri: https://github.com/spring-cloud-samples/config-repo
```

그외 JDBC 호환 데이터베이스나, Subversion, Hashicorp Vault, Credhub, 로컬 파일시스템도 소스로 활용할 수 있다.

## Client Side Usage

어플리케이션에서 이 기능들을 사용하려면, 스프링 부트 어플리케이션에 spring-cloud-config-client를 의존성을 넣어 빌드하면 된다 (예시는 config-client나 샘플 어플리케이션의 테스트 케이스를 참고해라). 의존성 추가는 스프링 부트 스타터 `org.springframework.cloud:spring-cloud-starter-config`를 사용하는 게 제일 간편하다. 메이븐 사용자를 위한 부모 pom과 BOM(`spring-cloud-starter-parent`)과, 그래들, 스프링 CLI 사용자를 위한 Spring IO 버전 관리 프로퍼티 파일도 제공한다. 다음은 전형적인 메이븐 설정 예시다:

**pom.xml**

```xml
<parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>{spring-boot-docs-version}</version>
    <relativePath /> <!-- lookup parent from repository -->
</parent>

<dependencyManagement>
	<dependencies>
		<dependency>
			<groupId>org.springframework.cloud</groupId>
			<artifactId>spring-cloud-dependencies</artifactId>
			<version>{spring-cloud-version}</version>
			<type>pom</type>
			<scope>import</scope>
		</dependency>
	</dependencies>
</dependencyManagement>

<dependencies>
	<dependency>
		<groupId>org.springframework.cloud</groupId>
		<artifactId>spring-cloud-starter-config</artifactId>
	</dependency>
	<dependency>
		<groupId>org.springframework.boot</groupId>
		<artifactId>spring-boot-starter-test</artifactId>
		<scope>test</scope>
	</dependency>
</dependencies>

<build>
	<plugins>
           <plugin>
               <groupId>org.springframework.boot</groupId>
               <artifactId>spring-boot-maven-plugin</artifactId>
           </plugin>
	</plugins>
</build>

   <!-- repositories also needed for snapshots and milestones -->
```

이제 아래 HTTP 서버같은, 표준 스프링 부트 어플리케이션을 만들 수 있다:

```java
@SpringBootApplication
@RestController
public class Application {

    @RequestMapping("/")
    public String home() {
        return "Hello World!";
    }

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }

}
```

이 HTTP 서버를 실행하면, 기동 시 8888 포트의 디폴트 로컬 컨피그 서버(실행 중이라면)에서 외부 설정을 찾는다. 이 동작을 수정하고 싶다면, 아래 예제처럼 `application.properties`를 통해 컨피그 서버 위치를 변경하면 된다:

```properties
spring.config.import=optional:configserver:http://myconfigserver.com
```

어플리케이션 이름을 따로 설정하지 않으면 기본적으로 `application`을 사용한다. 이 이름을 변경하려면 `application.properties` 파일에 아래 프로퍼티를 추가하면 된다:

```properties
spring.application.name: myapp
```

> `${spring.application.name}` 프로퍼티를 설정할 땐, 앱 이름 앞에 예약어 `application-`을 사용하지 않아야 올바른 프로퍼티 소스를 리졸브할 수 있다.

컨피그 서버 프로퍼티는 아래 예제에서 확인할 수 있듯, `/env` 엔드포인트에 우선 순위가 높은 프로퍼티 소스로 보여진다.

```bash
$ curl localhost:8080/env
{
  "activeProfiles": [],
  {
    "name": "servletContextInitParams",
    "properties": {}
  },
  {
    "name": "configserver:https://github.com/spring-cloud-samples/config-repo/foo.properties",
    "properties": {
      "foo": {
        "value": "bar",
        "origin": "Config Server https://github.com/spring-cloud-samples/config-repo/foo.properties:2:12"
      }
    }
  },
  ...
}
```

`configserver:<URL of remote repository>/<file name>`이란 프로퍼티 소스에는 `bar`를 값으로 갖는 `foo` 프로퍼티가 들어있다.

> 프로퍼티 소스 이름에 있는 URL은 컨피그 서버 URL이 아니라 git 레포지토리다.

> 스프링 클라우드 컨피그 클라이언트를 사용한다면, `spring.config.import` 프로퍼티를 설정해야 컨피그 서버에 바인딩할 수 있다. 자세한 내용은 [스프링 클라우드 컨피그 레퍼런스 가이드 내에서](../spring-cloud-config-client#spring-boot-config-data-import) 확인할 수 있다.
>
