---
title: Externalized Configuration
category: Spring Boot 2.X
order: 10
permalink: /Spring%20Boot/externalized-configuration/
description: properties/yaml 파일, 환경 변수, 커맨드라인 인자 등으로 스프링 부트 설정을 관리하고 바인딩하는 방법
image: ./../../images/springboot/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 부트
originalRefLink: https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#features.external-config
parent: Spring Boot Features
parentUrl: /Spring%20Boot/spring-boot-features/
priority: 0.4
---
<script>defaultLanguages = ['properties']</script>

### 목차

- [7.2.1. Accessing Command Line Properties](#721-accessing-command-line-properties)
- [7.2.2. JSON Application Properties](#722-json-application-properties)
- [7.2.3. External Application Properties](#723-external-application-properties)
  + [Optional Locations](#optional-locations)
  + [Wildcard Locations](#wildcard-locations)
  + [Profile Specific Files](#profile-specific-files)
  + [Importing Additional Data](#importing-additional-data)
  + [Importing Extensionless Files](#importing-extensionless-files)
  + [Using Configuration Trees](#using-configuration-trees)
  + [Property Placeholders](#property-placeholders)
  + [Working with Multi-Document Files](#working-with-multi-document-files)
  + [Activation Properties](#activation-properties)
- [7.2.4. Encrypting Properties](#724-encrypting-properties)
- [7.2.5. Working with YAML](#725-working-with-yaml)
  + [Mapping YAML to Properties](#mapping-yaml-to-properties)
  + [Directly Loading YAML](#directly-loading-yaml)
- [7.2.6. Configuring Random Values](#726-configuring-random-values)
- [7.2.7. Configuring System Environment Properties](#727-configuring-system-environment-properties)
- [7.2.8. Type-safe Configuration Properties](#728-type-safe-configuration-properties)
  + [JavaBean properties binding](#javabean-properties-binding)
  + [Constructor binding](#constructor-binding)
  + [Enabling @ConfigurationProperties-annotated types](#enabling-configurationproperties-annotated-types)
  + [Using @ConfigurationProperties-annotated types](#using-configurationproperties-annotated-types)
  + [Third-party Configuration](#third-party-configuration)
  + [Relaxed Binding](#relaxed-binding)
  + [Merging Complex Types](#merging-complex-types)
  + [Properties Conversion](#properties-conversion)
  + [@ConfigurationProperties Validation](#configurationproperties-validation)
  + [@ConfigurationProperties vs. @Value](#configurationproperties-vs-value)

---

## 7.2. Externalized Configuration

스프링 부트에선 설정을 외부로 뺄 수 있어서, 같은 애플리케이션을 서로 다른 환경으로 작업할 수 있다. 외부 설정은 자바 Properties 파일, YAML 파일, 환경 변수, 커맨드라인 인자 등 다양한 소스를 활용할 수 있다.

프로퍼티 값은 `@Value` 어노테이션을 통해 빈에 직접 주입하거나, 스프링의 `Environment` 인터페이스로 접근해도 되고, `@ConfigurationProperties`를 통해 [객체 구조에 바인딩](#728-type-safe-configuration-properties)할 수도 있다.

스프링 부트는 `PropertySource`를 적용하는 순서를 정확하게 설계해놨기 때문에, 사리에 맞게 값을 재정의할 수 있다. 프로퍼티를 적용하는 순서는 다음과 같다 (밑에 있는 값이 위에 있는 값을 재정의한다):

1. 디폴트 프로퍼티 (`SpringApplication.setDefaultProperties` 설정으로 지정).
2. `@Configuration` 클래스 위에 있는 [`@PropertySource`](https://docs.spring.io/spring-framework/docs/5.3.8/javadoc-api/org/springframework/context/annotation/PropertySource.html) 어노테이션. 이 프로퍼티 소스는 애플리케이션 컨텍스트를 리프레시하기 전까지는 `Environment`에 추가되지 않는다는 점에 주의하자. 리프레시를 시작하기 전에 읽어가는 `logging.*`, `spring.main.*`같은 프로퍼티를 설정하기엔 적합하지 않다.
3. 컨피그 데이터 (`application.properties` 파일 등)
4. `random.*` 프로퍼티만 가지고 있는 `RandomValuePropertySource`.
5. OS 환경 변수.
6. 자바 시스템 프로퍼티 (`System.getProperties()`).
7. `java:comp/env`의 JNDI 속성.
8. `ServletContext` init 파라미터.
9. `ServletConfig` init 파라미터.
10. `SPRING_APPLICATION_JSON`에 있는 프로퍼티 (환경 변수나 시스템 프로퍼티에 내장된 인라인 JSON).
11. 커맨드라인 인자.
12. 테스트에 있는 `properties` 속성. [`@SpringBootTest`](https://docs.spring.io/spring-boot/docs/2.5.2/api/org/springframework/boot/test/context/SpringBootTest.html)와 [애플리케이션 일부를 테스트하기 위한 test 어노테이션](../testing/#auto-configured-tests)에서 사용할 수 있다.
13. 테스트에 있는 [`@TestPropertySource`](https://docs.spring.io/spring-framework/docs/5.3.8/javadoc-api/org/springframework/test/context/TestPropertySource.html) 어노테이션.
14. devtools를 활성화한 경우 `$HOME/.config/spring-boot` 디렉토리에 있는 [Devtools 글로벌 설정 프로퍼티](../developing-with-spring-boot#684-global-settings).

컨피그 데이터 파일은 다음과 같은 순서로 적용한다:

1. jar에 패키징한 [애플리케이션 프로퍼티](#723-external-application-properties) (`application.properties` 또는 YAML로 작성한 파일).
2. jar에 패키징한 [프로파일 전용 애플리케이션 프로퍼티](#profile-specific-files) (`application-{profile}.properties` 또는 YAML로 작성한 파일).
3. 패키징한 jar 밖에 있는 [애플리케이션 프로퍼티](#723-external-application-properties) (`application.properties` 또는 YAML로 작성한 파일).
4. 패키징한 jar 밖에 있는 [프로파일 전용 애플리케이션 프로퍼티](#profile-specific-files) (`application-{profile}.properties` 또는 YAML로 작성한 파일).

> 파일 형식은 전체 애플리케이션에서 하나로 통일하는 게 좋다. 같은 위치에 `.properties`와 `.yml` 설정 파일이 둘 다 있다면 `.properties`를 우선시한다.

구체적인 예시를 위해 다음과 같이 `name` 프로퍼티를 사용하는 `@Component`를 개발한다고 해보자:

```java
@Component
public class MyBean {

    @Value("${name}")
    private String name;

    // ...

}
```

애플리케이션 클래스패스(ex. jar 내부)에 적당한 `name` 프로퍼티의 디폴트 값을 제공하는 `application.properties` 파일이 있을 수 있다. 다른 환경에서 실행할 때는 `name`을 재정의하는 `application.properties` 파일을 jar 외부에서 제공할 수 있다. 일회성 테스트라면 커맨드라인 스위치로 프로퍼티를 특정해서 (ex. `java -jar app.jar --name="Spring"`) 기동할 수도 있다.

> `env`, `configprops` 엔드포인트는 어떤 프로퍼티에 그 값이 왜 들어가 있는지를 확인할 때 유용하다. 이 두 엔드포인트를 통해 기대와 다른 프로퍼티 값을 진단해볼 수 있다. 자세한 내용은 "[Production ready features](../endpoints)"를 참고해라.

### 7.2.1. Accessing Command Line Properties

`SpringApplication`은 기본적으로 모든 커맨드라인 옵션 인자(즉, `--server.port=9000`같이 `--`로 시작하는 인자)를 `property`로 변환해서 스프링 `Environment`에 추가한다. 앞에서도 언급했지만, 커맨드라인 프로퍼티는 항상 파일 기반 프로퍼티 소스보다 우선한다.

커맨드라인 프로퍼티가 `Environment`에 추가되는게 싫다면 `SpringApplication.setAddCommandLineProperties(false)`로 비활성화할 수 있다.

### 7.2.2. JSON Application Properties

종종 Environment 변수와 시스템 프로퍼티에는 일부 프로퍼티명은 사용할 수 없다는 제약이 따르곤 한다. 스프링 부트에선 이럴 때를 대비해 프로퍼티 블록을 단일 JSON 구조로 인코딩할 수 있게 해준다.

애플리케이션을 기동하게 되면 `spring.application.json`이나 `SPRING_APPLICATION_JSON` 프로퍼티를 파싱해서 `Environment`에 추가한다.

예를 들어, UN\*X 쉘의 커맨드라인에서 환경 변수로 `SPRING_APPLICATION_JSON` 프로퍼티를 제공할 수 있다:

```shell
$ SPRING_APPLICATION_JSON='{"my":{"name":"test"}}' java -jar myapp.jar
```

앞의 예시에선 스프링 `Environment`는 `my.name=test`라는 프로퍼티를 가지게 된다.

동일한 JSON을 시스템 프로퍼티로도 제공할 수 있다:

```shell
$ java -Dspring.application.json='{"my":{"name":"test"}}' -jar myapp.jar
```

또는 JSON을 커맨드라인 인자로 제공해도 된다:

```shell
$ java -jar myapp.jar --spring.application.json='{"my":{"name":"test"}}'
```

전형적인 애플리케이션 서버에 배포한다면 `java:comp/env/spring.application.json`이라는 JNDI 변수를 사용할 수도 있다.

> JSON에 있는 `null` 값은 프로퍼티 소스에 추가는 되지만, `PropertySourcesPropertyResolver`는 `null` 프로퍼티를 누락 값<sup>missing values</sup>으로 처리한다. 다시 말해 JSON의 `null` 값으론 우선 순위가 더 낮은 프로퍼티 소스의 프로퍼티를 재정의할 수 없다.

### 7.2.3. External Application Properties

스프링 부트는 애플리케이션을 시작하면서 다음 위치에서 자동으로 `application.properties`와 `application.yaml` 파일을 찾아 로드한다:

1. 클래스패스에서<br>
   a\. 클래스패스 루트<br>
   b\. 클래스패스 `/config` 패키지<br>
2. 현재 디렉토리에서<br>
   a\. 현재 디렉토리<br>
   b\. 현재 디렉토리 밑에 있는 `/config` 디렉토리<br>
   c\. 하위 `/config` 디렉토리 바로 밑에 있는 디렉토리들<br>

이 항목들은 우선 순위에 따라 정렬된다 (밑에 있는 항목이 밑에 위에 있는 항목을 재정의한다). 로드한 파일에 있는 도큐먼트들은 스프링 `Environment`에 `PropertySources`로 추가된다.

설정 파일명으로 `application`이 마음에 들지 않으면 environment 프로퍼티 `spring.config.name`을 지정해서 다른 파일명으로 전환하면 된다. 예를 들어 `myproject.properties`와 `myproject.yaml` 파일을 찾고 싶다면 다음과 같이 애플리케이션을 실행하면 된다:

```shell
$ java -jar myproject.jar --spring.config.name=myproject
```

environment 프로퍼티 `spring.config.location`을 사용해 참조할 위치를 명시할 수도 있다. 이 프로퍼티는 확인할 위치를 하나 이상, 쉼표로 구분해서 받는다.

다음은 두 개의 다른 파일을 지정하는 예시다:

```shell
$ java -jar myproject.jar --spring.config.location=\
    optional:classpath:/default.properties,\
    optional:classpath:/override.properties
```

> [location이 없을 수도 있어서](#optional-locations) 파일이 존재하지 않아도 상관없다면 `optional:`을 프리픽스로 사용해라.

> `spring.config.name`, `spring.config.location`, `spring.config.additional-location`은 로드할 파일을 결정하기 때문에 읽어가는 시점이 훨씬 빠르다. 따라서 이 값들은 environment 프로퍼티(보통 OS 환경 변수나, 시스템 프로퍼티, 커맨드라인 인자)로 정의해야 한다.

`spring.config.location`에 디렉토리(파일이 아닌)를 지정한다면 `/`로 끝나야 한다. 디렉토리엔 런타임에 로드하기 전 `spring.config.name`으로 생성한 이름이 덧붙여진다. `spring.config.location`에 지정한 파일들은 그대로 임포트한다.

> location 값으로 사용한 디렉토리와 파일은 모두 [프로파일 전용 파일](#profile-specific-files)도 함께 확인하기 위해 치환<sup>expand</sup>된다. 예를 들어 `classpath:myconfig.properties`가 `spring.config.location`으로 있는 경우 적절한 `classpath:myconfig-<profile>.properties` 파일도 로드되는 걸 알 수 있다.

대부분은 단일 파일이나 디렉토리를 참조하는 `spring.config.location` 항목을 추가한다. location은 정의된 순서대로 처리되며, 나중에 정의한 location이 앞에 나온 location을 재정의할 수 있다.

<span id="features.external-config.files.location-groups"></span>location 설정이 복잡한데 프로파일별 설정 파일까지 사용한다면, 스프링 부트가 이 파일들을 그룹화활 방법을 알 수 있도록 힌트를 더 제공해야 할 수도 있다. location 그룹은 모두 동일한 레벨로 간주하는 location의 모음이다. 예를 들어 모든 클래스패스 location을 그룹으로 묶고, 모든 외부 location은 또 다른 그룹으로 묶고 싶을 수 있다. 하나의 location 그룹 내에 있는 항목은 `;`로 구분해야 한다. 자세한 내용은 "[프로파일 전용 파일](#profile-specific-files)" 섹션에 있는 예제를 참고해라.

`spring.config.location`을 사용해 설정한 location은 디폴트 location을 대체한다. 예를 들어 `spring.config.location`을 <span class="custom-blockquote">optional:classpath:/custom-config/,optional:file:./custom-config/</span>로 설정했다면 고려하는 전체 location 셋은 다음과 같다:

1. `optional:classpath:custom-config/`
2. `optional:file:./custom-config/`

location을 대체하기 보단 별도 location을 더 추가하고 싶은 거라면 `spring.config.additional-location`을 사용하면 된다. 추가된 location에서 로드한 프로퍼티는 디폴트 location에 있는 프로퍼티를 재정의 할 수 있다. 예를 들어 `spring.config.additional-location`을 <span class="custom-blockquote">optional:classpath:/custom-config/,optional:file:./custom-config/</span>로 설정했다면 고려하는 전체 location 셋은 다음과 같다:

1. `optional:classpath:/;optional:classpath:/config/`
2. `optional:file:./;optional:file:./config/;optional:file:./config/*/`
3. `optional:classpath:custom-config/`
4. `optional:file:./custom-config/`

이 검색 순서를 잘 활용하면 설정 파일 하나에 기본값을 지정하고, 다른 설정 파일에선 필요에 따라 이 값을 재정의할 수 있다. 애플리케이션의 기본값은 디폴트 location 중 하나에 있는 `application.properties`(또는 `spring.config.name`으로 지정한 다른 베이스 이름)에 제공하면 된다. 이 기본값들은 런타임에 커스텀 location 중 하나에 있는 다른 파일로 재정의될 수 있다.

> 시스템 프로퍼티가 아닌 환경 변수를 사용할 때는 대부분의 운영 체제에서 키 이름을 마침표로 구분할 수 없다. 하지만 그대신 밑줄을 사용할 수 있다 (ex. `spring.config.name` 대신 `SPRING_CONFIG_NAME`). 자세한 내용은 [환경 변수로 바인딩하기](#binding-from-environment-variables)를 참고해라.

> 애플리케이션을 서블릿 컨테이너나 애플리케이션 서버에서 실행한다면 JNDI 프로퍼티(`java:comp/env`)나 서블릿 컨텍스트 init 파라미터를 환경 변수나 시스템 프로퍼티 대용으로 사용할 수 있다.

#### Optional Locations

설정 데이터 위치로 지정한 location이 존재하지 않으면 기본적으로 스프링 부트는 `ConfigDataLocationNotFoundException`을 던지며, 애플리케이션은 기동되지 않는다.

location을 지정하고는 싶지만 항상 존재하지 않아도 되는 위치라면 `optional:` 프리픽스를 사용하면 된다. 이 프리픽스는 `spring.config.location`, `spring.config.additional-location` 프로퍼티 뿐 아니라 [`spring.config.import`](#importing-additional-data) 선언에도 사용할 수 있다.

예를 들어 `spring.config.import`에 `optional:file:./myconfig.properties`를 사용하면 `myconfig.properties` 파일이 없더라도 애플리케이션을 시작할 수 있다.

`ConfigDataLocationNotFoundExceptions`를 전부 무시하고 무조건 애플리케이션 기동을 이어가려면 `spring.config.on-not-found` 프로퍼티를 사용하면 된다. `SpringApplication.setDefaultProperties(…)`나 시스템/환경 변수를 사용해 값을 `ignore`로 설정해라.

#### Wildcard Locations

설정 파일 location에서 마지막 path 세그먼트에 `*` 문자가 포함돼 있으면 와일드카드 location으로 간주한다. 와일드카드는 설정을 로드할 때 확장 적용되서<sup>expand</sup>, 바로 밑에 있는 디렉토리도 함께 확인한다. 와일드카드 location은 설정 프로퍼티 소스가 여러 개 있을 때 쿠버네티스같은 환경에서 특히 유용하다.

예를 들어 몇 가지 Redis 설정과, MySQL 설정이 둘 다 있다면, 이 두 설정 모두 `application.properties` 파일에 있어야 하면서도 별도로 유지하고 싶을 수가 있다. 따라서 `/config/redis/application.properties`와 `/config/mysql/application.properties` 같이 다른 location에 `application.properties` 파일을 별도로 두 번 마운트하게 된다. 이런 상황이라면 와일드카드 location `config/*/`가 두 파일을 모두 처리해줄 거다.

기본적으로 스프링 부트는 디폴트 검색 위치에 `config/*/`도 포함시킨다. 즉, jar 밖에 있는 `/config` 디렉토리의 모든 하위 디렉토리를 검색하게 된다.

`spring.config.location`과 `spring.config.additional-location` 프로퍼티에 직접 와일드카드 location을 사용해도 된다.

> 와일드카드 location은 `*`은 하나만 포함하고, 디렉토리인 경우 `*/`로, 파일인 경우 `*/<filename>`으로 끝나야 한다. 와일드카드를 가진 location은 절대 경로를 포함한 파일 이름을 기준으로 알파벳순으로 정렬된다.

> 와일드카드 location은 외부 디렉토리에서만 작동한다. `classpath:` location에선 와일드카드를 사용할 수 없다.

#### Profile Specific Files

스프링 부트는 `application` 프로퍼티 파일뿐 아니라, `application-{profile}`을 네이밍 컨벤션으로 사용하는 프로파일 전용 파일도 로드해본다. 예를 들어 애플리케이션이 `prod`라는 프로파일을 활성화하고 YAML 파일을 사용한다면, `application.yml`과 `application-prod.yml`을 둘 다 찾는다.

프로파일 전용 프로퍼티는 표준 `application.properties`와 동일한 위치에서 로드하며, 프로파일 전용 파일은 항상 프로파일을 특정하지 않은 파일보다 우선시된다. 프로파일을 여러 개 지정했을 때는 마지막 프로파일이 이기는 전략<sup>last-wins strategy</sup>을 적용한다. 예를 들어, `spring.profiles.active` 프로퍼티에 `prod,live` 프로파일을 지정하면 `application-prod.properties`에 있는 값은 `application-live.properties`에 있는 값으로 재정의될 수 있다.

> 마지막 프로파일이 이긴다는 이 전략<sup>last-wins strategy</sup>은 [location 그룹](#features.external-config.files.location-groups) 레벨에 적용된다. `spring.config.location` 값 `classpath:/cfg/,classpath:/ext/`는 `classpath:/cfg/;classpath:/ext/`와는 재정의 규칙이 다르다.
>
> 예를 들어, 위에서 언급한 `prod,live` 예시를 계속 이어가자면, 다음과 같은 파일이 있을 수 있다:
>
> ```
> /cfg
> application-live.properties
> /ext
> application-live.properties
> application-prod.properties
> ```
>
> `spring.config.location`에 `classpath:/cfg/,classpath:/ext/`를 사용하면, `/ext`의 파일보다 먼저 `/cfg`의 파일들을 전부 처리한다.
>
> 1. `/cfg/application-live.properties`
> 2. `/ext/application-prod.properties`
> 3. `/ext/application-live.properties`
>
> 이 값 대신 `classpath:/cfg/;classpath:/ext/`를 사용하면 (`;`를 구분자로 사용), `/cfg`와 `/ext`를 동일한 레벨로 처리한다.
>
> 1. `/ext/application-prod.properties`
> 2. `/cfg/application-live.properties`
> 3. `/ext/application-live.properties`

`Environment`는 활성 프로파일을 설정하지 않았을 때 사용하는 디폴트 프로파일 셋을 가지고 있다 (기본값은 `[default]`). 즉, 명시적으로 활성화한 프로파일이 없으면 `application-default`에서 프로퍼티를 조회한다.

> 프로퍼티 파일들은 무조건 한 번만 로드한다. 이미 프로파일 전용 프로퍼티 파일을 직접 [임포트](#importing-additional-data)했다면, 다시 임포트하지 않는다.

#### Importing Additional Data

더 나아가 `spring.config.import` 프로퍼티를 사용하면 애플리케이션 프로퍼티에 다른 위치에 있는 설정 데이터를 임포트할 수 있다. 임포트는 발견하는 대로 처리하며, 임포트를 선언한 도큐먼트 바로 아래에 도큐먼트를 추가한 것처럼 다룬다.

예를 들어 클래스패스의 `application.properties` 파일에 다음과 같은 설정이 있을 수 있다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.application.name=myapp
spring.config.import=optional:file:./dev.properties
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  application:
    name: "myapp"
  config:
    import: "optional:file:./dev.properties"
```

이 설정은 현재 디렉토리에 있는 `dev.properties` 파일을 임포트하게 만든다 (해당 파일이 있으면). 임포트한 `dev.properties`에 있는 값은 임포트를 트리거한 파일보다 우선시된다. 위 예제에선 `dev.properties`가 `spring.application.name`을 다른 값으로 재정의할 수 있다.

임포트는 몇 번을 선언하더라도 딱 한 번만 가져온다. properties/yaml에 있는 하나의 도큐먼트 안에서는 임포트 순서는 중요하지 않다. 예를 들어, 아래 두  예시는 같은 결과를 낳는다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.config.import=my.properties
my.property=value
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  config:
    import: my.properties
my:
  property: value
```

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
my.property=value
spring.config.import=my.properties
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
my:
  property: value
spring:
  config:
    import: my.properties
```

두 예시 모두 `my.properties` 파일에 있는 값이 임포트를 트리거한 파일보다 우선 순위가 높다.

`spring.config.import` 키 하나에 location을 여러 개 지정해도 된다. location은 정의한 순서대로 처리되며, 뒤에 있는 import가 우선 순위가 높다.

> 필요 시엔 [프로파일 전용 프로퍼티 파일](#profile-specific-files)도 임포트 대상에 올린다. 위 예시는 `my.properties`와 `my-<profile>.properties`를 함께 임포트한다.

> 스프링 부트는 다양한 location을 지원하기 위한 플러그형 API를 포함하고 있다. 기본적으로는 자바 Properties, YAML, "[설정 트리](#using-configuration-trees)"를 임포트할 수 있다.
>
> 써드 파티 jar에선 다른 기술적 지원을 제공하기도 한다 (파일이 로컬에 있을 필요는 없다). 예를 들어 설정 데이터가 Consul이나 Apache ZooKeeper, Netflix Archaius같은 외부 저장소에 있는 것을 생각해볼 수 있다.
>
> 자체 location을 지원하려면 `org.springframework.boot.context.config` 패키지에 있는 `ConfigDataLocationResolver`와 `ConfigDataLoader` 클래스를 확인해봐라.

#### Importing Extensionless Files

일부 클라우드 플랫폼에선 볼륨으로 마운트한 파일에는 파일 확장자를 추가할 수 없다. 이렇게 확장자가 없는 파일을 임포트하기 위해선, 스프링 부트가 이 파일을 어떻게 로드해야 할지 알 수 있도록 힌트를 줘야 한다. 대괄호 안에 확장자 힌트를 넣으면 된다.

예를 들어 `/etc/config/myconfig`란 파일을 yaml로 임포트하려 한다고 해보자. `application.properties`를 다음과 같이 작성하면 이 파일을 임포트할 수 있다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.config.import=file:/etc/config/myconfig[.yaml]
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  config:
    import: "file:/etc/config/myconfig[.yaml]"
```

#### Using Configuration Trees

클라우드 플랫폼(ex. 쿠버네티스)에서 애플리케이션을 실행할 때는 한 번씩 플랫폼이 제공하는 설정 값을 읽어야 할 때가 있다. 환경 변수를 이런 목적으로 사용하는 건 드물진 않지만, 특히 값을 외부에 노출하면 안 되는 경우엔 사용하기 어렵다.

이제는 많은 클라우드 플랫폼에서 환경 변수의 대안으로 마운트한 데이터 볼륨에 설정을 매핑할 수 있다. 예를 들어 쿠버네티스는 [`ConfigMap`](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#populate-a-volume-with-data-stored-in-a-configmap)과 [`Secret`](https://kubernetes.io/docs/concepts/configuration/secret/#using-secrets-as-files-from-a-pod)을 볼륨에 마운트할 수 있다.

사용할 수 있는 공통 볼륨 마운트 패턴은 두 가지가 있다:

1. 전체 프로퍼티 셋을 가지고 있는 단일 파일 (보통은 YAML로 작성).
2. 디렉토리 트리에 파일을 여러 개 작성하고, 파일 이름을 '키'로, 내용을 '값'으로 활용한다.

첫 번째 패턴에선 [앞에서](#importing-additional-data) 설명한대로 `spring.config.import`를 사용해 YAML이나 Properties 파일을 직접 임포트하면 된다. 두 번째 패턴에선 스프링 부트가 모든 파일을 프로퍼티로 노출해야 한다는 것을 알 수 있도록 `configtree:` 프리픽스를 사용해야 한다.

예를 들어서 쿠버네티스가 다음과 같은 볼륨을 마운트했다고 상상해보자:

```
etc/
  config/
    myapp/
      username
      password
```

`username` 파일의 내용은 설정 값이고, `password`의 내용은 시크릿이다.

이 프로퍼티들을 임포트하려면 `application.properties`나 `application.yaml` 파일에 다음 내용을 추가하면 된다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.config.import=optional:configtree:/etc/config/
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  config:
    import: "optional:configtree:/etc/config/"
```

이렇게 하고나면 평소대로 `Environment`에서 `myapp.username`, `myapp.password` 프로퍼티에 접근하고 주입할 수 있다.

> 설정 트리 값은 예상되는 내용에 따라 문자열 `String` 타입으로도, `byte[]` 타입으로도 바인딩될 수 있다.

같은 상위 폴더 안에 임포트할 설정 트리가 여러 개 있을 땐 와일드카드를 활용하면 한 번에 임포트할 수 있다. `/*/`로 끝나는 `configtree:` location은 바로 아래에 있는 항목들을 모두 설정 트리로 가져온다.

예를 들어, 아래와 같은 볼륨이 있을 땐:

```
etc/
  config/
    dbconfig/
      db/
        username
        password
    mqconfig/
      mq/
        username
        password
```

`configtree:/etc/config/*/`를 임포트 location으로 사용하면 된다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.config.import=optional:configtree:/etc/config/*/
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  config:
    import: "optional:configtree:/etc/config/*/"
```

이렇게 하면 `db.username`, `db.password`, `mq.username`, `mq.password` 프로퍼티가 추가될 거다.

> 와일드카드를 통해 로드한 디렉토리들은 알파벳순으로 정렬된다. 순서를 변경하고 싶다면 각 location을 별도의 import로 나눠 선언해야 한다.

설정 트리는 도커 시크릿에도 사용할 수 있다. 도커 스웜 서비스에 시크릿 액세스 권한을 부여하면 이 시크릿은 컨테이너에 마운트된다. 예를 들어 `db.password`라는 이름을 가진 시크릿이 `/run/secrets/` 위치에 마운트된 경우엔 다음과 같은 방법으로 `db.password`를 스프링 environment에서 사용할 수 있도록 만들 수 있다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.config.import=optional:configtree:/run/secrets/
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  config:
    import: "optional:configtree:/run/secrets/"
```

#### Property Placeholders

`application.properties`와 `application.yml`에 있는 값들을 사용할 땐 기존 `Environment`를 통해 필터링되기 때문에, 먼저 정의해둔 값(ex. 시스템 프로퍼티로)을 재참조할 수 있다. 즉, 값 어디에나 표준 프로퍼티 플레이스홀더 구문 `${name}`을 사용할 수 있다.

예를 들어 아래 파일은 `app.description`을 "MyApp is a Spring Boot application"으로 설정하고 있다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
app.name=MyApp
app.description=${app.name} is a Spring Boot application
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
app:
  name: "MyApp"
  description: "${app.name} is a Spring Boot application"
```

> 이 테크닉을 통해 기존 스프링 부트 프로퍼티를 좀 더 "짧은" 프로퍼티로 다시 만들 수도 있다. 자세한 내용은 how-to 가이드 *['짧은' 커맨드라인 인자 사용하기](../howto.properties-and-configuration#1224-use-short-command-line-arguments)*를 참고해라.

#### Working with Multi-Document Files

스프링 부트에선 물리적인 파일 하나를 각각 독립적으로 추가되는 여러 개의 논리적 도큐먼트로 분할할 수 있다. 도큐먼트는 위에서 아래 순으로 처리된다. 뒤에 있는 문서는 앞에 있는 문서에서 정의한 프로퍼티를 재정의할 수 있다.

`application.yml` 파일에선 표준 YAML multi-document 구문을 사용한다. 연속된 세 개의 하이픈이 한 도큐먼트 끝과 다음 도큐먼트의 시작을 나타낸다.

예를 들어 다음 파일은 두 개의 논리적인 도큐먼트를 가지고 있다:

```yaml
spring.application.name: MyApp
---
spring.config.activate.on-cloud-platform: kubernetes
spring.application.name: MyCloudApp
```

`application.properties` 파일에선 특별한 주석 `#---`으로 도큐먼트 분할을 마킹한다:

```properties
spring.application.name=MyApp
#---
spring.config.activate.on-cloud-platform=kubernetes
spring.application.name=MyCloudApp
```

> 프로퍼티 파일 구분 기호 앞에는 공백이 없어야 하며, 하이픈 문자가 정확히 세 개 있어야 한다. 구분 기호 바로 앞, 뒷 줄은 주석이면 안 된다.

> multi-document 프로퍼티 파일은 `spring.config.activate.on-profile`같은 활성화 프로퍼티와 함께 사용하는 경우가 많다. 자세한 내용은 [다음 섹션](#activation-properties)을 참고해라.

> multi-document 프로퍼티 파일은 `@PropertySource`나 `@TestPropertySource` 어노테이션으로 로드할 수 없다.

#### Activation Properties

일부 프로퍼티는 특정 조건이 충족할 때만 활성화하는 게 유용할 때가 있다. 예를 들어 특정 프로파일을 활성화했을 때만 의미 있는 프로퍼티가 있을 수 있다.

`spring.config.activate.*`를 사용하면 프로퍼티 도큐먼트를 조건부로 활성화할 수 있다.

다음과 같은 활성화 프로퍼티를 사용할 수 있다:

| Property            | Note                                              |
| :------------------ | :------------------------------------------------ |
| `on-profile`        | 일치해야만 도큐먼트를 활성화하는 프로파일 표현식. |
| `on-cloud-platform` | 감지해야만 도큐먼트를 활성화하는 `CloudPlatform`. |

예를 들어 아래 예시에선 쿠버네티스에서 실행하고, "prod"나 "staging" 프로파일을 활성화했을 때만 두 번째 도큐먼트가 활성화된다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
myprop=always-set
#---
spring.config.activate.on-cloud-platform=kubernetes
spring.config.activate.on-profile=prod | staging
myotherprop=sometimes-set
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
myprop:
  always-set
---
spring:
  config:
    activate:
      on-cloud-platform: "kubernetes"
      on-profile: "prod | staging"
myotherprop: sometimes-set
```

### 7.2.4. Encrypting Properties

스프링 부트는 프로퍼티 값 암호화를 내장 지원하고 있진 않지만, 스프링 `Environment`에 들어간 값을 수정하는 데 필요한 훅 포인트를 제공한다. `EnvironmentPostProcessor` 인터페이스를 사용하면 애플리케이션 기동 전에 `Environment`를 조작할 수 있다. 자세한 내용은 [애플리케이션을 시작하기 전에 Environment 또는 ApplicationContext 커스텀하기](../howto.spring-boot-application#1213-customize-the-environment-or-applicationcontext-before-it-starts)를 참고해라.

credential과 패스워드를 안전하게 저장할 방법을 찾고 있다면, [Spring Cloud Vault](https://cloud.spring.io/spring-cloud-vault/) 프로젝트에서 [HashiCorp Vault](https://www.vaultproject.io/)에 외부 설정을 저장할 수 있도록 지원한다.

### 7.2.5. Working with YAML

[YAML](https://yaml.org/)은 JSON의 상위 집합이기에, 계층구조를 가지고 있는 설정 데이터를 지정할 때 편하다. `SpringApplication` 클래스는 클래스패스에 [SnakeYAML](https://bitbucket.org/asomov/snakeyaml) 라이브러리가 있다면 properties 대안으로 YAML을 자동 지원한다.

> “스타터”를 사용한다면 `spring-boot-starter`에 의해 자동으로 SnakeYAML이 제공될 거다.

#### Mapping YAML to Properties

YAML 도큐먼트의 계층구조는 스프링 `Environment`에서 사용할 수 있는 플랫<sup>flat</sup> 구조로 변환해야만 한다. 예를 들어 아래 YAML 도큐먼트를 생각해보자:

```yaml
environments:
  dev:
    url: https://dev.example.com
    name: Developer Setup
  prod:
    url: https://another.example.com
    name: My Cool App
```

이 프로퍼티들은 `Environment`에서 액세스하기 위해 다음과 같이 펼쳐진다<sup>flattened</sup>:

```properties
environments.dev.url=https://dev.example.com
environments.dev.name=Developer Setup
environments.prod.url=https://another.example.com
environments.prod.name=My Cool App
```

마찬가지로 YAML 리스트도 펼쳐야 한다. YAML 리스트는 `[index]` 역참조자<sup>dereferencers</sup>를 가진 프로퍼티 키로 표현한다. 예를 들어 아래 YAML을 생각해보자:

```yaml
my:
 servers:
 - dev.example.com
 - another.example.com
```

위 예시는 아래 프로퍼티들로 변환된다:

```properties
my.servers[0]=dev.example.com
my.servers[1]=another.example.com
```

> `[index]` 표기법을 사용하는 프로퍼티는 스프링 부트의 `Binder` 클래스를 통해 자바 `List`나 `Set` 객체에 바인딩할 수 있다. 자세한 내용은 아래에 있는 "[Type-safe 설정 프로퍼티](#728-type-safe-configuration-properties)" 섹션을 참고해라.

> YAML 파일은 `@PropertySource`나 `@TestPropertySource` 어노테이션으로 로드할 수 없다. 따라서 이 방식으로 값을 로드해야 할 땐 properties 파일을 사용해야 한다.

#### Directly Loading YAML

스프링 프레임워크는 YAML 도큐먼트를 로드할 수 있는 두 가지 간편 클래스를 제공한다. `YamlPropertiesFactoryBean`은 YAML을 `Properties`로, `YamlMapFactoryBean`은 YAML을 `Map`으로 로드한다.

YAML을 스프링 `PropertySource`로 로드하고 싶으면 `YamlPropertySourceLoader` 클래스를 사용할 수도 있다.

### 7.2.6. Configuring Random Values

`RandomValuePropertySource`는 랜덤 값을 주입할 때 유용하다 (예를 들어 시크릿이나 테스트 케이스에). 다음 예제에서 보이는 것처럼 integer, long, uuid, string을 생성할 수 있다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
my.secret=${random.value}
my.number=${random.int}
my.bignumber=${random.long}
my.uuid=${random.uuid}
my.number-less-than-ten=${random.int(10)}
my.number-in-range=${random.int[1024,65536]}
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
my:
  secret: "${random.value}"
  number: "${random.int}"
  bignumber: "${random.long}"
  uuid: "${random.uuid}"
  number-less-than-ten: "${random.int(10)}"
  number-in-range: "${random.int[1024,65536]}"
```

`random.int*`에서 사용하는 구문은 `OPEN value (,max) CLOSE`다. 여기서 `OPEN,CLOSE`는 임의의 문자를 나타내며, `value,max`는 정수다. `max`를 제공하면 `value`가 최소값, `max`가 최대값이 된다 (`max` 미만 까지).

### 7.2.7. Configuring System Environment Properties

스프링 부트에선 environment 프로퍼티에 프리픽스를 설정할 수 있다. 설정 요구 사항이 다른 여러 스프링 부트 애플리케이션이 시스템 환경을 공유하는 경우에 유용하다. 시스템 환경 프로퍼티의 프리픽스는 `SpringApplication`에 직접 설정할 수 있다.

예를 들어 프리픽스를 `input`으로 설정하면 `remote.timeout`과 같은 프로퍼티도 시스템 환경의 `input.remote.timeout`으로 리졸브된다.

### 7.2.8. Type-safe Configuration Properties

설정 프로퍼티를 일일이 `@Value("${property}")` 어노테이션을 사용해 주입하기가 번거로울 수도 있는데, 작업 중인 프로퍼티가 많거나 데이터 자체 계층구조가 복잡하면 더욱 그렇다. 스프링 부트는 프로퍼티를 이용할 수 있는 방법을 한 가지 더 제공하는데, 이 방법에선 빈 타입을 확실하게 정해둬서 애플리케이션 설정의 유효성을 미리 검사할 수 있다.

> [`@Value`와 type-safe 설정 프로퍼티의 차이점](#configurationproperties-vs-value)도 함께 보면 좋다.

#### JavaBean properties binding

다음 예제처럼 표준 JavaBean 프로퍼티를 선언하고 있는 빈에는 프로퍼티 값을 바인딩할 수 있다:

```java
@ConfigurationProperties("my.service")
public class MyProperties {

    private boolean enabled;

    private InetAddress remoteAddress;

    private final Security security = new Security();

    // getters / setters...

    public static class Security {

        private String username;

        private String password;

        private List<String> roles = new ArrayList<>(Collections.singleton("USER"));

        // getters / setters...

    }

}
```

위 POJO로 정의하는 프로퍼티는 다음과 같다:

- `my.service.enabled` (`false`가 디폴트)
- `my.service.remote-address`, (`String`에서 타입 강제 변환).
- `my.service.security.username` (프로퍼티명에 따라 이름이 결정되는 중첩 "security" 객체를 사용했다. 경우에 따라서는 이 반환 타입은 전혀 사용하지 않고 `SecurityProperties`를 사용할 수도 있다.)
- `my.service.security.password`.
- `my.service.security.roles` (`USER`를 디폴트로 갖는 `String` 컬렉션).

> 스프링 부트에서 `@ConfigurationProperties` 클래스에 매핑하는 프로퍼티는 (properties 파일, YAML 파일, 환경 변수 등을 통해 구성하는 프로퍼티) public API긴 하지만, 클래스 자체에 있는 접근자(getters/setters)는 직접 사용하는 용도가 아니다.

> 스프링 MVC에서와 동일하게 표준 자바 빈 property descriptor를 통해 바인딩하기 때문에, 이런 구조에선 비어있는 디폴트 생성자에 의존하며, 일반적으로는 getter와 setter가 필수다. 다음과 같은 경우엔 setter를 생략할 수 있다:
>
> - 맵<sup>Map</sup>은 초기화만 해줬다면 getter만 있으면 되고 setter는 없어도 된다. 바인더를 통해 수정할 수 있기 때문이다.
> - 컬렉션과 배열은 인덱스(보통 YAML에서)나 쉼표로 구분하는 단일 값(properties)을 통해 액세스할 수 있다. 후자에선 setter가 필수다. 이런 타입에선 항상 setter를 추가하는 게 좋다. 컬렉션을 직접 초기화한다면 불변 객체<sup>immutable</sup>는 아닌지 반드시 확인해봐야 한다 (앞의 예제에서처럼 변경 가능해야 한다).
> - 중첩된 POJO 프로퍼티를 직접 초기화한다면 (위 예제의 `Security` 필드같이) setter가 필요하지 않다. 런타임에 바인더를 이용해 기본 생성자로 인스턴스를 생성하고 싶다면 setter가 필요하다.
>
> 프로젝트 롬복을 사용해 자동으로 getter와 setter를 추가하는 사람들도 있다. 이런 타입에선 롬복이 생성자를 만들지 않도록 주의해야 한다. 롬복이 어떤 생성자를 만들게 되면, 컨테이너가 객체 인스턴스를 만들 때 그 생성자를 자동으로 사용하게 된다.
>
> 마지막으로, 프로퍼티를 바인딩할 땐 표준 자바 빈 프로퍼티만 고려하며, 스태틱 프로퍼티 바인딩은 지원하지 않는다.

#### Constructor binding

앞 섹션에서 보여줬던 예제는 아래와 같이 변경이 불가능한<sup>immutable</sup> 객체로 다시 작성할 수 있다:

```java
@ConstructorBinding
@ConfigurationProperties("my.service")
public class MyProperties {

    // fields...

    public MyProperties(boolean enabled, InetAddress remoteAddress, Security security) {
        this.enabled = enabled;
        this.remoteAddress = remoteAddress;
        this.security = security;
    }

    // getters...

    public static class Security {

        // fields...

        public Security(String username, String password, @DefaultValue("USER") List<String> roles) {
            this.username = username;
            this.password = password;
            this.roles = roles;
        }

        // getters...

    }

}
```

이 설정에선 `@ConstructorBinding` 어노테이션을 사용해 생성자 바인딩을 사용하겠다는 것을 알린다. 즉, 바인더는 바인딩할 파라미터를 가지고 있는 생성자를 찾아볼 거다.

`@ConstructorBinding` 클래스 안에 중첩돼 있는 멤버(ex. 위 예제의 `Security`)도 생성자를 통해 바인딩된다.

기본값은 `@DefaultValue`로 지정할 수 있으며, 프로퍼티 값이 없을 때는 여기 지정한 `String` 값에 같은 변환 서비스를 적용해 타겟 타입으로 강제 변환시킨다. 기본적으로는 `Security`에 바인딩된 프로퍼티가 없으면 `MyProperties` 인스턴스는 `security`를 `null`로 가질 거다. `Security`에 바인딩된 프로퍼티가 없더라도 null이 아닌 인스턴스를 반환하려면 비어 있는 `@DefaultValue` 어노테이션을 사용하면 된다:

```java
public MyProperties(boolean enabled, InetAddress remoteAddress, @DefaultValue Security security) {
    this.enabled = enabled;
    this.remoteAddress = remoteAddress;
    this.security = security;
}
```

> 생성자 바인딩을 사용하려면 `@EnableConfigurationProperties`나 설정 프로퍼티 스캔을 사용해 해당 클래스를 활성화해야 한다. 일반적인 스프링 메커니즘으로 생성하는 빈(ex. `@Component` 빈, `@Bean` 메소드로 생성하는 빈, `@Import`로 로드하는 빈)에는 생성자 바인딩을 사용할 수 없다.

> 클래스에 생성자가 둘 이상이라면 `@ConstructorBinding`을 바인딩할 생성자에 직접 사용해도 된다.

> `@ConfigurationProperties`의 주요 용도는 프로퍼티를 지정한 타입으로 리턴하는 거다. `java.util.Optional`은 설정 프로퍼티 주입에 적합하지 않기 때문에 함께 사용하는 것을 권장하지 않는다. `Optional` 프로퍼티를 선언하더라도, 다른 타입을 사용하는 프로퍼티와의 일관성을 위해, 값이 없으면 비어 있는 `Optional`이 아니라 `null`을 바인딩한다.

#### Enabling @ConfigurationProperties-annotated types

스프링 부트를 활용하면 `@ConfigurationProperties` 타입을 바인딩해서 빈으로 등록할 수 있다. 설정 프로퍼티는 클래스별로 하나하나 활성화해도 되고, 컴포넌트 스캔과 유사한 방식으로 동작하는 설정 프로퍼티 스캔을 활성화해도 된다.

경우에 따라서는 `@ConfigurationProperties` 어노테이션을 달아준 클래스가 스캔에 적합하지 않을 수도 있다. 예를 들어, 자체 자동 설정을 개발 중이거나 조건에 따라 활성화하려는 경우가 그렇다. 이럴 땐 `@EnableConfigurationProperties` 어노테이션을 사용해서 처리할 타입들을 지정해라. 다음 예제처럼 `@Configuration` 클래스에 선언해주면 된다:

```java
@Configuration(proxyBeanMethods = false)
@EnableConfigurationProperties(SomeProperties.class)
public class MyConfiguration {

}
```

설정 프로퍼티 스캔을 사용하려면 애플리케이션에 `@ConfigurationPropertiesScan` 어노테이션을 추가해라. 보통은 `@SpringBootApplication` 어노테이션을 선언한 메인 애플리케이션 클래스에 추가하지만 다른 `@Configuration` 클래스에 추가해도 상관없다. 기본적으로는 이 어노테이션을 선언한 클래스의 패키지에서 스캔을 진행한다. 스캔할 패키지를 직접 정의하려면 다음 예제처럼 하면 된다:

```java
@SpringBootApplication
@ConfigurationPropertiesScan({ "com.example.app", "com.example.another" })
public class MyApplication {

}
```

> `@ConfigurationProperties` 빈이 설정 프로퍼티 스캔이나 `@EnableConfigurationProperties`를 통해 등록될 땐, 빈 이름은 컨벤션에 따라 `<prefix>-<fqn>`으로 결정된다. 여기서 `<prefix>`는 `@ConfigurationProperties` 어노테이션에 지정한 environment 키 프리픽스이고, `<fqn>`은 빈의 풀 네임<sup>fully qualified name</sup>이다. 어노테이션에 프리픽스를 지정하지 않으면 빈의 풀 네임만 사용한다.
>
> 위 예제에 있는 빈 이름은 `com.example.app-com.example.app.SomeProperties`다.

`@ConfigurationProperties`로는 environment만 다루는게 좋고, 특히 컨텍스트에 있는 다른 빈은 주입하지 않는 게 좋다. 별다른 방법이 없다면 setter 주입을 사용하거나 프레임워크에서 제공하는 `*Aware` 인터페이스들(ex. `Environment`에 접근해야 할 땐 `EnvironmentAware`)을 활용하면 된다. 그래도 생성자를 통해 다른 빈을 주입하고 싶다면, 설정 프로퍼티 빈에 `@Component` 어노테이션을 달고 JavaBean 기반 프로퍼티 바인딩을 사용해야 한다.

#### Using @ConfigurationProperties-annotated types

이런 방식의 설정은 아래와 같은 `SpringApplication` 외부 YAML 설정과 특히 잘 어울린다:

```yaml
my:
    service:
        remote-address: 192.168.1.1
        security:
            username: admin
            roles:
              - USER
              - ADMIN
```

`@ConfigurationProperties` 빈을 사용할 때는 다른 빈을 주입할 때처럼 똑같이 주입해주면 된다:

```java
@Service
public class MyService {

    private final SomeProperties properties;

    public MyService(SomeProperties properties) {
        this.properties = properties;
    }

    public void openConnection() {
        Server server = new Server(this.properties.getRemoteAddress());
        server.start();
        // ...
    }

    // ...

}
```

> `@ConfigurationProperties`를 사용하면 애플리케이션에 정의한 키를 IDE에서 자동 완성으로 입력할 수 있게 도와주는 메타데이터 파일도 생성할 수 있다. 자세한 내용은 [부록](https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#configuration-metadata)을 참고해라.

#### Third-party Configuration

`@ConfigurationProperties`는 클래스에 추가할 수도 있지만, public `@Bean` 메소드에도 사용할 수 있다. 직접 제어할 수 없는 써드 파티 컴포넌트에 프로퍼티를 바인딩할 때 특히 유용하다.

`Environment` 프로퍼티로 빈을 구성하려면 다음 예제처럼 `@ConfigurationProperties`를 해당 빈 정의에 추가해라:

```java
@Configuration(proxyBeanMethods = false)
public class ThirdPartyConfiguration {

    @Bean
    @ConfigurationProperties(prefix = "another")
    public AnotherComponent anotherComponent() {
        return new AnotherComponent();
    }

}
```

`another` 프로픽스로 정의한 JavaBean 프로퍼티는 모두 이전 `SomeProperties` 예제와 유사한 방식으로 `AnotherComponent` 빈에 매핑된다.

#### Relaxed Binding

스프링 부트는 `Environment` 프로퍼티를 `@ConfigurationProperties` 빈에 바인딩할 땐 몇 가지 규칙을 완화해서 적용하기 때문에, `Environment` 프로퍼티명과 빈 프로퍼티명이 정확히 일치할 필요는 없다. 잘 활용하면 좋을만한 대표적인 예시를 들면, environment 프로퍼티를 대쉬로 구분하거나 (ex. `context-path`를 `contextPath`에 바인딩), 대문자로 표기할 때다 (ex. `PORT`를 `port`에 바인딩).

예를 들어 아래 `@ConfigurationProperties` 클래스를 살펴보자:

```java
@ConfigurationProperties(prefix = "my.main-project.person")
public class MyPersonProperties {

    private String firstName;

    public String getFirstName() {
        return this.firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

}
```

위 코드에선 다음과 같은 프로퍼티명을 적용할 수 있다:

| Property                            | Note                                                         |
| :---------------------------------- | :----------------------------------------------------------- |
| `my.main-project.person.first-name` | 케밥 케이스. `.properties`, `.yml` 파일에서 권장.            |
| `my.main-project.person.firstName`  | 표준 카멜 케이스 구문.                                       |
| `my.main-project.person.first_name` | 언더스코어 표기법. `.properties`,  `.yml` 파일에서 사용할 수 있는 또 하나의 방법. |
| `MY_MAINPROJECT_PERSON_FIRSTNAME`   | 대문자 형식. 시스템 환경 변수에서 권장.                      |

> 이 어노테이션에 있는 `prefix` 값은 *반드시* 케밥케이스를 사용해야 한다 (`my.main-project.person`같이 소문자를 사용하고 `-`로 구분).

| Property Source | Simple                                                       | List                                                         |
| :-------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| Properties 파일 | 카멜 케이스, 케밥 케이스, 언더스코어 표기법                  | `[ ]`를 사용하는 표준 리스트 구문 또는 값을 콤마로 구분      |
| YAML 파일       | 카멜 케이스, 케밥 케이스, 언더스코어 표기법                  | 표준 YAML 리스트 구문 또는 값을 콤마로 구분                  |
| 환경 변수       | 대문자 형식이면서 언더스코어를 구분자로 사용 [환경 변수 바인딩하기](#binding-from-environment-variables) 참고). | 숫자를 언더스코어로 감싸서 표현 ([환경 변수 바인딩하기](#binding-from-environment-variables) 참고) |
| 시스템 프로퍼티 | 카멜 케이스, 케밥 케이스, 언더스코어 표기법                  | `[ ]`를 사용하는 표준 리스트 구문 또는 값을 콤마로 구분      |

> 프로퍼티는 가능하면 `my.person.first-name=Rod`와 같이 소문자 케밥 형식으로 저장하길 권장한다.

##### Binding Maps

`Map` 프로퍼티에 값을 바인딩할 땐 기존 `key` 값을 유지하기 위해 특별한 대괄호 표기법을 사용해야 할 수도 있다. 키를 `[]`로 감싸지 않으면 알파벳과 숫자, `-`, `.` 문자를 제외한 다른 문자는 모두 제거된다.

예를 들어서 아래 프로퍼티를 `Map<String,String>`에 바인딩한다고 생각해보자:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
my.map.[/key1]=value1
my.map.[/key2]=value2
my.map./key3=value3
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
my:
  map:
    "[/key1]": "value1"
    "[/key2]": "value2"
    "/key3": "value3"
```

> YAML 파일에선 키에 있는 대괄호는 따옴표로 감싸야 제대로 파싱된다.

위에 있는 프로퍼티는 `Map`에 바인딩될 때 `/key1`, `/key2`, `key3`를 맵의 키로 사용한다. `key3`에 있는 슬래시는에서 대괄호로 감싸지 않았기 때문에 제거된다.

간혹 `key`에 `.`가 포함돼 있는 값을 스칼라가 아닌 값에 바인딩한다면 대괄호 표기법을 사용해야 할 수도 있다. 예를 들어 `a.b=c`를 `Map<String, Object>`에 바인딩하면 `{"a"={"b"="c"}}`를 엔트리로 가진 맵을 반환하는 반면, `[a.b]=c`는 `{"a.b"="c"}`를 엔트리로 가진 맵을 반환한다.

##### Binding from Environment Variables

대부분의 운영 체제는 환경 변수 이름에 사용할 수 있는 문자에 엄격한 규칙을 둔다. 예를 들어 리눅스 쉘 변수에는 문자(`a`~`z` 또는 `A`~`Z`), 숫자(`0` ~`9`), 언더스코어(`_`) 만 사용할 수 있다. 유닉스 쉘 변수도 컨벤션에 따라 대문자 이름만 사용한다.

스프링 부트는 가능한 한 이런 네이밍 제약과 호환될 수 있도록 완화한 바인딩 규칙을 설계했다.

표준 형식<sup>canonical-form</sup>을 따르는 프로퍼티명은 다음 규칙에 따라 환경 변수 이름으로 변환할 수 있다:

- 닷(`.`)을 언더스코어(`_`)로 치환한다.
- 대쉬(`-`)는 모두 지운다.
- 대문자로 변환한다.

예를 들어 설정 프로퍼티 `spring.main.log-startup-info`는 `SPRING_MAIN_LOGSTARTUPINFO`라는 환경 변수로 만들 수 있다.

환경 변수는 객체 리스트에도 바인딩할 수 있다. `List`에 바인딩하려면 변수 이름 안에서 요소 번호를 언더스코어로 감싸야 한다.

예를 들어 설정 프로퍼티 `my.service[0].other`는 `MY_SERVICE_0_OTHER`라는 환경 변수를 사용할 수 있다.

#### Merging Complex Types

리스트 설정이 두 곳 이상에 있을 땐 전체 리스트를 대체하는 식으로 재정의된다.

예를 들어 `name`, `description` 속성을 가진 `MyPojo` 객체를 생각해보자. 이 속성들의 디폴트 값은 `null`이다. 다음 예제는 `MyProperties`로 `MyPojo` 객체 리스트를 노출한다:

```java
@ConfigurationProperties("my")
public class MyProperties {

    private final List<MyPojo> list = new ArrayList<>();

    public List<MyPojo> getList() {
        return this.list;
    }

}
```

이제 아래 설정을 살펴보자:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
my.list[0].name=my name
my.list[0].description=my description
#---
spring.config.activate.on-profile=dev
my.list[0].name=my another name
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
my:
  list:
  - name: "my name"
    description: "my description"
---
spring:
  config:
    activate:
      on-profile: "dev"
my:
  list:
  - name: "my another name"
```

`dev` 프로파일을 활성화하지 않으면 `MyProperties.list`는 위에서 정의한 `MyPojo`를 딱 하나 가진다. 하지만 `dev` 프로파일을 활성화하더라도 `list`는 *여전히* 하나의 항목만 가진다 (name은 `my another name`이고 description은 `null`). 이 설정은 두 번째 `MyPojo` 인스턴스를 리스트에 추가해주지 *않으며*, 아이템을 병합해주지도 않는다.

여러 프로파일에서 `List`를 지정하더라도, 우선 순위가 가장 높은 리스트를 사용한다 (이 리스트만 사용한다). 다음 예제를 생각해보자:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
my.list[0].name=my name
my.list[0].description=my description
my.list[1].name=another name
my.list[1].description=another description
#---
spring.config.activate.on-profile=dev
my.list[0].name=my another name
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
my:
  list:
  - name: "my name"
    description: "my description"
  - name: "another name"
    description: "another description"
---
spring:
  config:
    activate:
      on-profile: "dev"
my:
  list:
  - name: "my another name"
```

위 예제에서 `dev` 프로파일을 활성화하면 `MyProperties.list`는 *딱 하나의* `MyPojo` 엔트리를 갖게된다 (name은 `my another name`, description은 `null`). YAML에선 쉼표로 구분하는 리스트와 YAML 리스트 둘 다 리스트의 내용을 완전히 재정의할 수 있다.

`Map` 프로퍼티는 여러 소스에서 가져온 프로퍼티 값을 통해 바인딩할 수 있다. 하지만 같은 프로퍼티가 여러 소스에 있다면 우선 순위가 가장 높은 프로퍼티를 사용한다. 다음 예제는 `MyProperties`로 `Map<String, MyPojo>`를 노출한다:

```java
@ConfigurationProperties("my")
public class MyProperties {

    private final Map<String, MyPojo> map = new LinkedHashMap<>();

    public Map<String, MyPojo> getMap() {
        return this.map;
    }

}
```

이제 아래 설정을 살펴보자:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
my.map.key1.name=my name 1
my.map.key1.description=my description 1
#---
spring.config.activate.on-profile=dev
my.map.key1.name=dev name 1
my.map.key2.name=dev name 2
my.map.key2.description=dev description 2
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
my:
  map:
    key1:
      name: "my name 1"
      description: "my description 1"
---
spring:
  config:
    activate:
      on-profile: "dev"
my:
  map:
    key1:
      name: "dev name 1"
    key2:
      name: "dev name 2"
      description: "dev description 2"
```

`dev` 프로파일을 활성화하지 않으면 `MyProperties.map`은 `key1`를 키로 가진 엔트리를 하나만 가진다(name은 `my name 1`, description은 `my description 1`). 하지만 `dev` 프로파일을 활성화하면 `map`에는 `key1` 키와(name은 `dev name 1`, description은 `my description 1`)와 `key2` 키(name은 `dev name 2`, description은 `dev description 2`) 두 가지 엔트리가 추가된다.

> 이 병합 규칙은 파일말고도 다른 프로퍼티 소스에도 모두 적용된다.

#### Properties Conversion

스프링 부트에서 `@ConfigurationProperties` 빈에 값을 바인딩할 땐 외부 애플리케이션 프로퍼티 타입을 정의된 타입으로 강제 전환한다. 타입 변환 로직을 커스텀하고 싶다면 `ConversionService` 빈(빈 이름을 `conversionService`로)이나, 커스텀 프로퍼티 에디터(`CustomEditorConfigurer` 빈을 통해), 또는 커스텀 `Converters`(빈 정의에 `@ConfigurationPropertiesBinding` 어노테이션을 선언해서)를 제공하면 된다.

> 애플리케이션 라이프 사이클에서 `ConversionService` 빈을 요청하는 시점은 매우 빠르기 때문에, `ConversionService`가 사용하는 의존성에는 제한을 둬야 한다. 보통 `ConversionService`를 생성하는 시점에는 필요한 의존성들이 완전히 초기화되지 않았을 거다. 커스텀 `ConversionService`를 설정 키를 강제하는 데는 사용하지 않고, `@ConfigurationPropertiesBinding`으로 지정한 커스텀 컨버터에만 의존한다면 커스텀 `ConversionService` 이름은 변경하는 게 좋을 거다.

##### Converting Durations

스프링 부트에는 기간을 나타내는 전용 표현 방식이 있다. 프로퍼티를 `java.time.Duration`으로 선언하면, 애플리케이션 프로퍼티에 다음과 같은 포맷을 사용할 수 있다:

- 일반적인 `long` (`@DurationUnit`을 명시하지 않으면 밀리세컨드를 디폴트 단위로 사용)
- [`java.time.Duration`에서 사용하는](https://docs.oracle.com/javase/8/docs/api/java/time/Duration.html#parse-java.lang.CharSequence-) 표준 ISO-8601 포맷
- 좀 더 가독성있게 값과 단위를 결합한 포맷 (ex. `10s`는 10초를 의미한다)

아래 예제를 살펴보자:

```java
@ConfigurationProperties("my")
public class MyProperties {

    @DurationUnit(ChronoUnit.SECONDS)
    private Duration sessionTimeout = Duration.ofSeconds(30);

    private Duration readTimeout = Duration.ofMillis(1000);

    // getters / setters...

}
```

`30`, `PT30S`, `30s` 모두 동일하게 세션 타임아웃을 30초로 지정한다. read 타임아웃을 500ms으로 지정할 땐 `500`, `PT0.5S`, `500ms` 모두 사용할 수 있다.

다른 단위도 사용할 수 있는데, 지원하는 단위는 다음과 같다:

- `ns` (nanoseconds)
- `us` (microseconds)
- `ms` (milliseconds)
- `s` (seconds)
- `m` (minutes)
- `h` (hours)
- `d` (days)

기본 단위는 밀리세컨드이며, 위 샘플에 보이는 것처럼 `@DurationUnit`을 사용하면 재정의할 수 있다.

생성자 바인딩을 선호한다면, 같은 프로퍼티를 다음과 같이 정의해도 된다:

```java
@ConfigurationProperties("my")
@ConstructorBinding
public class MyProperties {

    // fields...

    public MyProperties(@DurationUnit(ChronoUnit.SECONDS) @DefaultValue("30s") Duration sessionTimeout,
            @DefaultValue("1000ms") Duration readTimeout) {
        this.sessionTimeout = sessionTimeout;
        this.readTimeout = readTimeout;
    }

    // getters...

}
```

> `Long` 프로퍼티를 매핑할 때는 단위가 밀리세컨드가 아니라면 단위를 정의해줘야 한다 (`@DurationUnit`). 단위를 지정하면 훨씬 더 풍부한 포맷을 사용할 수 있으며, 매핑 결과를 예측하기도 더 쉽다.

##### Converting periods

스프링 부트에선 duration 외에 `java.time.Period` 타입도 사용할 수 있다. 애플리케이션 프로퍼티엔 다음과 같은 포맷을 사용할 수 있다:

- 일반적인 `int` (`@PeriodUnit`을 명시하지 않으면 days를 디폴트 단위로 사용)
- [`java.time.Duration`에서 사용하는](https://docs.oracle.com/javase/8/docs/api/java/time/Duration.html#parse-java.lang.CharSequence-) 표준 ISO-8601 포맷
- 값과 단위 쌍을 결합한 심플 포맷 (ex. `1y3d`는 1년 + 3일을 의미한다)

심플 포맷에선 다음과 같은 단위를 지원한다:

- `y` (years)
- `m` (months)
- `w` (weeks)
- `d` (days)

> `java.time.Period` 타입은 실제로는 주<sup>week</sup> 단위 숫자를 따로 저장하진 않으며, "7일"을 짧게 표현하는 것 뿐이다.

##### Converting Data Sizes

스프링 프레임워크는 사이즈를 바이트 단위로 표현할 수 있는 `DataSize` 값 타입을 제공한다. `DataSize` 프로퍼티를 정의하면 애플리케이션 프로퍼티에 다음 포맷을 사용할 수 있다:

- 일반적인 `long` (`@DataSizeUnit`을 명시하지 않으면 바이트를 디폴트 단위로 사용)
- 좀 더 가독성있게 값과 단위를 결합한 포맷 (ex. `10MB`는 10메가바이트를 의미한다)

아래 예제를 살펴보자:

```java
@ConfigurationProperties("my")
public class MyProperties {

    @DataSizeUnit(DataUnit.MEGABYTES)
    private DataSize bufferSize = DataSize.ofMegabytes(2);

    private DataSize sizeThreshold = DataSize.ofBytes(512);

    // getters/setters...

}
```

`10`, `10MB` 모두 동일하게 버퍼 사이즈를 10메가바이트로 지정한다. 사이즈 임계치를 256바이트로 지정할 땐 `256`, `256B` 모두 사용할 수 있다.

다른 단위도 사용할 수 있는데, 지원하는 단위는 다음과 같다:

- `B` (bytes)
- `KB` (kilobytes)
- `MB` (megabytes)
- `GB` (gigabytes)
- `TB` (terabytes)

기본 단위는 바이트이며, 위 샘플에 보이는 것처럼 `@DataSizeUnit`을 사용하면 재정의할 수 있다.

생성자 바인딩을 선호한다면, 같은 프로퍼티를 다음과 같이 정의해도 된다:

```java
@ConfigurationProperties("my")
@ConstructorBinding
public class MyProperties {

    // fields...

    public MyProperties(@DataSizeUnit(DataUnit.MEGABYTES) @DefaultValue("2MB") DataSize bufferSize,
            @DefaultValue("512B") DataSize sizeThreshold) {
        this.bufferSize = bufferSize;
        this.sizeThreshold = sizeThreshold;
    }

    // getters...

}
```

> `Long` 프로퍼티를 매핑할 때는 단위가 바이트가 아니라면 단위를 정의해줘야 한다 (`@DataSizeUnit`). 단위를 지정하면 훨씬 더 풍부한 포맷을 사용할 수 있으며, 매핑 결과를 예측하기도 더 쉽다.

#### @ConfigurationProperties Validation

스프링 부트는 `@ConfigurationProperties` 클래스에 스프링의 `@Validated` 어노테이션이 있으면 유효성을 검사한다. 설정 클래스에 JSR-303 `javax.validation` constraint 어노테이션을 바로 사용해도 된다. 단, 클래스패스에 그에 맞는 JSR-303 구현체가 있는지 확인해본 다음 아래 예제처럼 원하는 필드에 constraint 어노테이션을 추가해라:

```java
@ConfigurationProperties("my.service")
@Validated
public class MyProperties {

    @NotNull
    private InetAddress remoteAddress;

    // getters/setters...

}
```

> 설정 프로퍼티를 만드는 `@Bean` 메소드에 `@Validated` 어노테이션을 선언해도 유효성 검사를 트리거한다.

프로퍼티가 없을 때조차 포함해서 무조건 중첩된 프로퍼티의 유효성 검사도 트리거하려면, 관련 필드에 `@Valid` 어노테이션을 추가해야 한다. 다음 코드는 앞에 있던 `MyProperties` 예제를 수정한 코드다:

```java
@ConfigurationProperties("my.service")
@Validated
public class MyProperties {

    @NotNull
    private InetAddress remoteAddress;

    @Valid
    private final Security security = new Security();

    // getters/setters...

    public static class Security {

        @NotEmpty
        private String username;

        // getters/setters...

    }

}
```

`configurationPropertiesValidator`라는 빈을 정의해서 커스텀 스프링 `Validator`를 추가할 수도 있다. 이때 `@Bean` 메소드는 `static`으로 선언해야 한다. 설정 프로퍼티 validator는 애플리케이션의 라이프사이클 초기에 생성되며, `@Bean` 메소드를 스태틱으로 선언하면 `@Configuration` 클래스 인스턴스를 만들지 않고도 빈을 생성할 수 있다. 이렇게하면 인스턴스를 더 빨리 만들었을 때 생기는 문제들을 피할 수 있다.

> `spring-boot-actuator` 모듈은 모든 `@ConfigurationProperties` 빈들을 노출해주는 엔드포인트를 제공한다. 웹 브라우저에서 `/actuator/configprops`에 접근하거나 JMX 엔드포인트를 이용해라. 자세한 내용은 "[Production ready features](../endpoints)" 섹션을 참고해라.

#### @ConfigurationProperties vs. @Value

`@Value` 어노테이션은 핵심 컨테이너 기능 중 하나로, type-safe 설정 프로퍼티와는 제공하는 기능이 다르다. 다음 테이블에 `@ConfigurationProperties`와 `@Value`에서 지원하는 기능을 요약해 뒀다:

| Feature                                                      | `@ConfigurationProperties` | `@Value`                                                     |
| :----------------------------------------------------------- | :------------------------- | :----------------------------------------------------------- |
| [바인딩 규칙 완화](#relaxed-binding)                         | Yes                        | 제한적 ([아래 노트](#features.external-config.typesafe-configuration-properties.vs-value-annotation.note) 참고) |
| [메타데이터 지원](https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#configuration-metadata) | Yes                        | No                                                           |
| `SpEL` 표현식                                                | No                         | Yes                                                          |

> <span id="features.external-config.typesafe-configuration-properties.vs-value-annotation.note"></span>`@Value`를 사용하려면 프로퍼티명을 표준 형식<sup>canonical form</sup>(소문자만 사용한 케밥 케이스)으로 참조하는 게 좋다. 표준 형식을 사용하면 스프링 부트가 `@ConfigurationProperties`를 바인딩할 때 사용하는 완화된 규칙와 동일한 논리를 활용할 수 있다. 예를 들어 `@Value("{demo.item-price}")`는 `application.properties` 파일에서 `demo.item-price`와 `demo.itemPrice`를, 시스템 환경에선 `DEMO_ITEMPRICE`를 찾는다. 하지만 `@Value("{demo.itemPrice}")`를 사용하면 `demo.item-price`와 `DEMO_ITEMPRICE`는 고려하지 않는다.

자체 컴포넌트에 설정 키를 여러 개 정의한다면 POJO에 `@ConfigurationProperties` 어노테이션을 선언해서 같이 묶어주는 게 좋다. 이렇게하면 구조화된 type-safe 객체를 빈에 주입할 수 있다.

[애플리케이션 프로퍼티 파일](#723-external-application-properties)에 있는 `SpEL` 표현식은 파일을 파싱해 environment에 값을 집어 넣는 시점에는 처리되지 않는다. 하지만 `@Value` 안에서는 `SpEL` 표현식을 사용할 수 있다. 애플리케이션 프로퍼티 파일에 있는 프로퍼티 값이 `SpEL` 표현식이라면 `@Value`를 통해 사용하는 시점에 평가된다.
