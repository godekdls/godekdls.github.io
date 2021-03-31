---
title: Spring Cloud Config Client
category: Spring Cloud Config
order: 8
permalink: /Spring%20Cloud%20Config/spring-cloud-config-client/
description: 스프링 클라우드 컨피그 클라이언트를 한글로 번역한 문서입니다. 컨피그 클라이언트 설정 방법, Config first/Discovery first 부트스트랩 등을 설명합니다.
image: ./../../images/springcloud/logo.jpeg
lastmod: 2021-03-31T22:00:00+09:00
comments: true
originalRefName: 스프링 클라우드 컨피그
originalRefLink: https://docs.spring.io/spring-cloud-config/docs/3.0.3/reference/html/#_spring_cloud_config_client
---

### 목차

- [Spring Boot Config Data Import](#spring-boot-config-data-import)
- [Config First Bootstrap](#config-first-bootstrap)
- [Discovery First Bootstrap](#discovery-first-bootstrap)
- [Config Client Fail Fast](#config-client-fail-fast)
- [Config Client Retry](#config-client-retry)
- [Locating Remote Configuration Resources](#locating-remote-configuration-resources)
- [Specifying Multiple Urls for the Config Server](#specifying-multiple-urls-for-the-config-server)
- [Configuring Timeouts](#configuring-timeouts)
- [Security](#security)
- [Health Indicator](#health-indicator)
- [Providing A Custom RestTemplate](#providing-a-custom-resttemplate)
- [Vault](#vault)
  + [Nested Keys In Vault](#nested-keys-in-vault)

---

스프링 부트 어플리케이션에선 스프링 컨피그 서버(또는 어플리케이션 개발자가 제공하는 다른 외부 프로퍼티 소스)를 즉시 활용할 수 있다.  `Environment` 변경 이벤트와 관련한 몇 가지 유용한 기능도 활용할 수 있다.

---

## Spring Boot Config Data Import

스프링 부트 2.4에선 `spring.config.import` 프로퍼티를 통해 설정 데이터를 가져오는 새로운 방법을 도입했다. 이제 이게 컨피그 서버에 바인딩하는 기본 방식이다.

컨피그 서버 연결을 선택 사항으로 두려면 application.properties에 아래 설정을 넣어라:

**application.properties**

```properties
spring.config.import=optional:configserver:
```

이렇게 하면 디폴트 위치 "http://localhost:8888"에 있는 컨피그 서버에 연결한다. `optional:` 프리픽스를 제거하면 컨피그 서버에 연결할 수 없을 땐 컨피그 클라이언트는 기동되지 않는다. 컨피그 서버 위치를 변경하려면 `spring.cloud.config.uri`를 설정하거나 `spring.config.import` 문에 `spring.config.import=optional:configserver:http://myhost:8888` 등의 url을 추가해라. Import 프로퍼티에 있는 위치가 uri 프로퍼티보다 우선시된다.

> `spring.config.import`를 통한 Spring Boot Config Data import 방식에선 `bootstrap` 파일(properties 또는 yaml)은 필요 **없다**.

---

## Config First Bootstrap

레거시 부트스트랩 방식으로 컨피그 서버에 연결하려면, 반드시 프로퍼티나 `spring-cloud-starter-bootstrap` 스타터를 통해 부트스트랩을 활성화해야 한다. 부트스트랩을 활성화하는 프로퍼티는 `spring.cloud.bootstrap.enabled=true`다. 이 값은 시스템 프로퍼티나 환경 변수로 설정해야 한다. 부트스트랩을 활성화하면 클래스패스에서 스프링 클라우드 컨피그 클라이언트를 사용하는 모든 어플리케이션은 다음과 같이 컨피그 서버에 연결된다: 컨피그 클라이언트를 시작하면 컨피그 서버에 바인딩하고 (`spring.cloud.config.uri` 부트스트랩 설정 프로퍼티를 통해), 리모트 프로퍼티 소스로 스프링 `Environment`를 초기화한다.

부트스트랩을 활성화하고 나면 컨피그 서버를 이용할 모든 클라이언트 어플리케이션에는 `bootstrap.yml`(또는 환경 변수)이 필요하며, 여기에 `spring.cloud.config.uri`에 서버 주소를 설정해줘야 한다 (기본값은 "http://localhost:8888"이다).

---

## Discovery First Bootstrap

Spring Cloud Netflix나 Eureka Service Discovery, Spring Cloud Consul같은 `DiscoveryClient` 구현체를 사용한다면, 컨피그 서버를 디스커버리 서비스에 등록할 수 있다. 하지만 디폴트 "Config First" 모드에선 클라이언트 등록을 이용할 수 없다.

`DiscoveryClient`를 사용해 컨피그 서버를 찾는 걸 선호한다면, `spring.cloud.config.discovery.enabled=true`를 설정하면 된다 (기본값은 `false`). 이렇게 되면 모든 클라이언트 어플리케이션에 적절한 디스커버리 설정과 `bootstrap.yml`(또는 환경 변수)이 필요해진다. 예를 들어 Spring Cloud Netflix에선 유레카 서버 주소를 정의해야 한다 (ex. `eureka.client.serviceUrl.defaultZone`). 이 옵션을 사용하면 기동 시에 서비스 등록 정보를 찾기 위한 네트워크 왕복이 추가된다. 대신에 디스커버리 서비스를 고정해둘 수만 있으면, 컨피그 서버는 엔드포인트 변경이 가능해진다. 디폴트 서비스 ID는 `configserver`지만,  클라이언트 측에선 `spring.cloud.config.discovery.serviceId`를 설정해 변경할 수 있다 (서버 측에선 일반적인 서비스에서처럼 `spring.application.name`을 설정하는 식으로 변경할 수 있다).

디스커버리 클라이언트 구현체는 모두 일종의 메타데이터 맵을 지원한다 (예를 들어, 유레카엔 `eureka.instance.metadataMap`이 있다). 클라이언트가 제대로 연결하려면 컨피그 서버의 서비스 등록 메타데이터에 몇 가지 프로퍼티를 추가로 설정해야 할 수도 있다. 컨피그 서버를 HTTP Basic으로 보호 중이라면, `user`, `password`로 credentail을 설정할 수 있다. 컨피그 서버에 컨텍스트 경로가 있다면 `configPath`를 설정할 수도 있다. 아래 YAML 파일은 유레카 클라이언트를 사용하는 컨피그 서버를 위한 설정 예시다:

```yaml
eureka:
  instance:
    ...
    metadataMap:
      user: osufhalskjrtl
      password: lviuhlszvaorhvlo5847
      configPath: /config
```

---

## Config Client Fail Fast

상황에 따라 컨피그 서버에 연결할 수 없으면 서비스 기동에 실패하길 바랄 수 있다. 이렇게 동작하길 원한다면 부트스트랩 설정 프로퍼티 `spring.cloud.config.fail-fast=true`를 설정하면 클라이언트는 Exception과 함께 중단된다.

> 비슷한 기능을 `spring.config.import`를 사용해 추가하고 싶다면, 단순히 `optional:` 프리픽스를 생략하면 된다.

---

## Config Client Retry

어플리케이션을 시작할 때 가끔씩 컨피그 서버를 이용할 수 없을 것 같다면, 실패한 뒤에도 계속 시도하도록 만들 수 있다. 먼저 `spring.cloud.config.fail-fast=true`로 설정해야 한다. 그다음 클래스패스에 `spring-retry`와 `spring-boot-starter-aop`를 추가해야 한다. 기본 동작에선 6번을 재시도하며, 초기 백오프 간격은 1000ms이고, 이후엔 1.1배씩 더 기다려본다. 이 설정들과 기타 다른 설정은 `spring.cloud.config.retry.*` 프로퍼티로 변경할 수 있다.

> 재시도 동작을 완전히 제어하고 싶다면, `RetryOperationsInterceptor` 타입 `@Bean`을 `configServerRetryInterceptor`란 ID로 추가해라. Spring Retry에는 인터셉터 생성을 지원하는 `RetryInterceptorBuilder`가 들어있다.

---

## Locating Remote Configuration Resources

컨피그 서비스는 `/{application}/{profile}/{label}`로 프로퍼티 소스를 제공한다. 여기서 클라이언트 앱은 디폴트로 다음과 같이 바인딩한다:

- "name" = `${spring.application.name}`
- "profile" = `${spring.profiles.active}` (사실상 `Environment.getActiveProfiles()`)
- "label" = "master"

> `${spring.application.name}` 프로퍼티를 설정할 땐, 앱 이름 앞에 예약어 `application-`을 사용하지 않아야 올바른 프로퍼티 소스를 리졸브할 수 있다.

이 값들은 모두 `spring.cloud.config.*`를 설정해서 재정의할 수 있다 (여기서 `*`은 `name`, `profile`, `label`이다). `label`은 이전 버전 설정으로 롤백할 때 유용하다. 디폴트 컨피그 서버 구현체를 사용하면 `label`은 git 레이블이나 브랜치 명, 커밋 ID가 될 수 있다. 레이블은 콤마로 구분해서 리스트로도 제공할 수 있다. 이땐 리스트에 있는 항목을, 하나가 성공할 때까지 순서대로 시도해본다. 이 동작은 피처 브랜치로 작업할 때 유용할 거다. 예를 들어서, 설정 레이블을 작업 중인 브랜치에 맞추고는 싶지만, 피처 브랜치가 없어도 동작하게 만들고 싶을 수 있다 (이럴 땐 `spring.cloud.config.label=myfeature,develop`를 사용해라).

---

## Specifying Multiple Urls for the Config Server

컨피그 서버 인스턴스를 여러 개 배포한 상태에서, 가끔씩 인스턴스 하나 이상을 이용할 수 없을 것 같을 때 가용성을 보장하려면 URL을 여러 개 지정하거나 (`spring.cloud.config.uri` 프로퍼티 아래 리스트를 콤마로 구분해서), 모든 인스턴스를 유레카같은 서비스 레지스트리에 등록하면 된다 (Discovery-First 부트스트랩 모드를 사용 중이라면). 단, 이렇게 하면 컨피그 서버가 실행 중이 아니거나 (즉, 어플리케이션이 종료된 경우), 커넥션 타임아웃이 발생했을 때에만 고가용성이 보장된다. 예를 들어 컨피그 서버가 500 (Internal Server Error) 응답을 반환하거나, 컨피그 클라이언트가 컨피그 서버에서 401을 응답받으면 (bad credentials 등의 이유로), 컨피그 클라이언트는 다른 URL로 프로퍼티를 조회해보지 않는다. 이런 류의 에러는 가용성 문제가 아니라 사용자 문제를 나타낸다.

컨피그 서버에서 HTTP 기본 인증을 사용한다면, 현재는 `spring.cloud.config.uri` 프로퍼티에 지정한 각 URL 안에 credential을 추가하는 경우에만 컨피그 서버 별로 인증 credential을 지원할 수 있다. 다른 보안 메커니즘을 사용한다면 (현재로썬) 컨피그 서버 별로 인증, 인가를 지원할 수 없다.

---

## Configuring Timeouts

타임아웃 임계치를 설정하고 싶다면:

- Read 타임아웃은 `spring.cloud.config.request-read-timeout` 프로퍼티로 설정할 수 있다.
- Connection 타임아웃은 `spring.cloud.config.request-connect-timeout` 프로퍼티로 설정할 수 있다.

---

## Security

서버에서 HTTP 기본 인증을 사용한다면 클라이언트는 password를 (기본값이 아니라면 username도) 알고 있어야 한다. username과 password는 다음 예제와 같이 컨피그 서버 URI나 별도 username, password 프로퍼티를 통해 지정할 수 있다:

```yaml
spring:
  cloud:
    config:
     uri: https://user:secret@myconfig.mycompany.com
```

다음 예제는 같은 정보를 다른 방법으로 전달한다:

```yaml
spring:
  cloud:
    config:
     uri: https://myconfig.mycompany.com
     username: user
     password: secret
```

`spring.cloud.config.password`와 `spring.cloud.config.username`에 있는 값은 URI에 있는 정보를 재정의한다.

어플리케이션을 Cloud Foundry에 앱을 배포한다면 서비스 credential을 사용해 password를 제공하는 게 제일 좋다 (설정 파일에 있을 필요가 없으므로 URI 등으로). 다음 예제는 로컬과 `configserver`라는 Cloud Foundry의 사용자 제공 서비스에서 동작한다:

```yaml
spring:
  cloud:
    config:
     uri: ${vcap.services.configserver.credentials.uri:http://user:password@localhost:8888}
```

컨피그 서버가 클라이언트 측 TLS 인증서를 요구한다면, 다음 예제처럼 프로퍼티를 통해 클라이언트 측 TLS 인증서와 trust store를 설정할 수 있다:

```yaml
spring:
  cloud:
    config:
      uri: https://myconfig.myconfig.com
      tls:
        enabled: true
        key-store: <path-of-key-store>
        key-store-type: PKCS12
        key-store-password: <key-store-password>
        key-password: <key-password>
        trust-store: <path-of-trust-store>
        trust-store-type: PKCS12
        trust-store-password: <trust-store-password>
```

컨피그 클라이언트 측 TLS를 활성화하려면 `spring.cloud.config.tls.enabled`가 `true`여야 한다. `spring.cloud.config.tls.trust-store`를 생략하면 JVM 디폴트 trust store를 사용한다. `spring.cloud.config.tls.key-store-type`과 `spring.cloud.config.tls.trust-store-type`의 기본값은 PKCS12다. password 프로퍼티를 생략하면 빈 password로 간주한다.

다른 보안 메커니즘을 사용하는 경우엔 `ConfigServicePropertySourceLocator`에 [`RestTemplate`을 제공](#providing-a-custom-resttemplate)해야 할 수도 있다 (예를 들어 부트스트랩 컨텍스트에서 가져와서 주입하는 등).

---

## Health Indicator

컨피그 클라이언트는 컨피그 서버에서 설정을 로드해보는 스프링 부트 Health Indicator를 제공한다. 이 health indicator는 `health.config.enabled=false`를 설정하면 비활성화할 수 있다. 응답도 성능상의 이유로 캐시된다. 기본 캐시 유지 시간은 5분이다. 이 값을 변경하려면 `health.config.time-to-live` 프로퍼티를 설정해라 (밀리세컨드 단위).

---

## Providing A Custom RestTemplate

경우에 따라 클라이언트에서 컨피그 서버에 보내는 요청을 커스텀해야 할 수도 있다. 전형적으로 서버에 보낼 요청을 인증하기 위한 특별한 `Authorization` 헤더를 전달할 때가 그렇다. 커스텀 `RestTemplate`을 제공하려면:

1. 다음 예제처럼 `PropertySourceLocator` 구현체로 새 설정 빈을 작성해라:

   **CustomConfigServiceBootstrapConfiguration.java**
  
   ```java
   @Configuration
   public class CustomConfigServiceBootstrapConfiguration {
       @Bean
       public ConfigServicePropertySourceLocator configServicePropertySourceLocator() {
           ConfigClientProperties clientProperties = configClientProperties();
          ConfigServicePropertySourceLocator configServicePropertySourceLocator =  new ConfigServicePropertySourceLocator(clientProperties);
           configServicePropertySourceLocator.setRestTemplate(customRestTemplate(clientProperties));
           return configServicePropertySourceLocator;
       }
   }
   ```
  
   > `Authorization` 헤더를 추가하는 방식을 단순화하려면 이대신 `spring.cloud.config.headers.*` 프로퍼티를 사용해도 된다.

2. `resources/META-INF`에 `spring.factories`라는 파일을 만들고, 다음 예제와 같이 커스텀 설정을 명시해라:

   **spring.factories**
  
   ```properties
   org.springframework.cloud.bootstrap.BootstrapConfiguration = com.my.config.client.CustomConfigServiceBootstrapConfiguration
   ```

---

## Vault

컨피그 백엔드 서버로 Vault를 사용하고 있다면, 클라이언트는 서버가 Vault에서 값을 조회할 수 있도록 토큰을 제공해야 한다. 토큰을 제공하려면 다음 예제와 같이 클라이언트의 `bootstrap.yml` 안에 `spring.cloud.config.token`을 설정해주면 된다:

```yaml
spring:
  cloud:
    config:
      token: YourVaultToken
```

---

### Nested Keys In Vault

Vault에선 다음 예제처럼 값에 중첩키를 지정할 수 있다:

```bash
echo -n '{"appA": {"secret": "appAsecret"}, "bar": "baz"}' | vault write secret/myapp -
```

이 명령어는 Vault에 JSON 객체를 작성하는 명령어다. 스프링에서 이런 값에 접근할 땐 다음 예제처럼 늘 쓰던 dot(`.`)을 사용하면 된다.

```java
@Value("${appA.secret}")
String name = "World";
```

위 코드에서 `name` 변수 값은 `appAsecret`으로 설정된다.