---
title: SpringApplication
category: Spring Boot
order: 9
permalink: /Spring%20Boot/spring-application/
description: 스프링 부트 애플리케이션을 부트스트랩하기 위한 SpringApplication 클래스와 라이프 사이클, 이벤트 소개
image: ./../../images/springboot/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 부트
originalRefLink: https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#features.spring-application
parent: Spring Boot Features
parentUrl: /Spring%20Boot/spring-boot-features/
---
<script>defaultLanguages = ['properties']</script>

### 목차

- [7.1.1. Startup Failure](#711-startup-failure)
- [7.1.2. Lazy Initialization](#712-lazy-initialization)
- [7.1.3. Customizing the Banner](#713-customizing-the-banner)
- [7.1.4. Customizing SpringApplication](#714-customizing-springapplication)
- [7.1.5. Fluent Builder API](#715-fluent-builder-api)
- [7.1.6. Application Availability](#716-application-availability)
  + [Liveness State](#liveness-state)
  + [Readiness State](#readiness-state)
  + [Managing the Application Availability State](#managing-the-application-availability-state)
- [7.1.7. Application Events and Listeners](#717-application-events-and-listeners)
- [7.1.8. Web Environment](#718-web-environment)
- [7.1.9. Accessing Application Arguments](#719-accessing-application-arguments)
- [7.1.10. Using the ApplicationRunner or CommandLineRunner](#7110-using-the-applicationrunner-or-commandlinerunner)
- [7.1.11. Application Exit](#7111-application-exit)
- [7.1.12. Admin Features](#7112-admin-features)
- [7.1.13. Application Startup tracking](#7113-application-startup-tracking)

---

##  7.1. SpringApplication

`main()` 메소드로 시작하는 스프링 애플리케이션은 `SpringApplication` 클래스로 간편하게 부트스트랩할 수 있다. 대부분은 다음 예제처럼 스태틱 메소드 `SpringApplication.run`에 부트스트랩을 위임하면 된다:

```java
@SpringBootApplication
public class MyApplication {

    public static void main(String[] args) {
        SpringApplication.run(MyApplication.class, args);
    }

}
```

애플리케이션을 시작하면 다음과 유사한 문구가 출력되는 게 보일 거다:

```java
  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::   v2.5.2

2021-02-03 10:33:25.224  INFO 17321 --- [           main] o.s.b.d.s.s.SpringAppplicationExample    : Starting SpringAppplicationExample using Java 1.8.0_232 on mycomputer with PID 17321 (/apps/myjar.jar started by pwebb)
2021-02-03 10:33:25.226  INFO 17900 --- [           main] o.s.b.d.s.s.SpringAppplicationExample    : No active profile set, falling back to default profiles: default
2021-02-03 10:33:26.046  INFO 17321 --- [           main] o.s.b.w.embedded.tomcat.TomcatWebServer  : Tomcat initialized with port(s): 8080 (http)
2021-02-03 10:33:26.054  INFO 17900 --- [           main] o.apache.catalina.core.StandardService   : Starting service [Tomcat]
2021-02-03 10:33:26.055  INFO 17900 --- [           main] org.apache.catalina.core.StandardEngine  : Starting Servlet engine: [Apache Tomcat/9.0.41]
2021-02-03 10:33:26.097  INFO 17900 --- [           main] o.a.c.c.C.[Tomcat].[localhost].[/]       : Initializing Spring embedded WebApplicationContext
2021-02-03 10:33:26.097  INFO 17900 --- [           main] w.s.c.ServletWebServerApplicationContext : Root WebApplicationContext: initialization completed in 821 ms
2021-02-03 10:33:26.144  INFO 17900 --- [           main] s.tomcat.SampleTomcatApplication         : ServletContext initialized
2021-02-03 10:33:26.376  INFO 17900 --- [           main] o.s.b.w.embedded.tomcat.TomcatWebServer  : Tomcat started on port(s): 8080 (http) with context path ''
2021-02-03 10:33:26.384  INFO 17900 --- [           main] o.s.b.d.s.s.SpringAppplicationExample    : Started SampleTomcatApplication in 1.514 seconds (JVM running for 1.823)
```

기본적으로 애플리케이션을 시작한 사용자 등, 상세한 기동 정보를 가지고 있는 `INFO` 로그 메세지가 출력된다. `INFO` 말고 다른 로그 레벨을 원한다면 [로그 레벨](../logging#745-log-levels)에서 설명하는 대로 설정을 넣으면 된다. 애플리케이션 버전은 메인 애플리케이션 클래스가 있는 패키지의 구현 버전을 보고 결정한다. 기동 정보 로깅은 `spring.main.log-startup-info`를 `false`로 설정하면 끌 수 있다. 이렇게하면 애플리케이션의 활성 프로파일 로깅도 꺼진다.

> 기동 시에 부가적인 로그를 넣고싶다면 `SpringApplication`의 하위 클래스에서 `logStartupInfo(boolean)`을 재정의하면 된다.

### 7.1.1. Startup Failure

애플리케이션 기동에 실패했다면 등록돼 있는 `FailureAnalyzers`가 전용 에러 메세지와 문제 해결을 위해 필요한 구체적인 조치를 알려줄 거다. 예를 들어 `8080` 포트에서 웹 애플리케이션을 시작했는데 이 포트가 이미 사용 중이라면 아래 메세지와 유사한 내용을 볼 수 있을 거다:

```java
***************************
APPLICATION FAILED TO START
***************************

Description:

Embedded servlet container failed to start. Port 8080 was already in use.

Action:

Identify and stop the process that's listening on port 8080 or configure this application to listen on another port.
```

> 스프링 부트는 다양한 `FailureAnalyzer` 구현체를 제공하지만, [직접 만든 구현체를 추가](../howto.spring-boot-application#1211-create-your-own-failureanalyzer)할 수도 있다.

예외를 처리할 수 있는 failure analyzer가 없더라도 전체 컨디션 리포트를 표기하면 무엇이 잘못됐는지를 파악하기가 좀 더 쉬워진다. 컨디션 리포트를 출력하려면 [`debug` 프로퍼티를 활성화](../externalized-configuration)하거나 <span class="custom-blockquote">org.springframework.boot.autoconfigure.logging.ConditionEvaluationReportLoggingListener</span>에 [`DEBUG` 로그를 활성화](../logging#745-log-levels)해야 한다.

예를 들어 `java -jar`를 사용해서 애플리케이션을 실행한다면 다음과 같이 `debug` 프로퍼티를 활성화할 수 있다:

```shell
$ java -jar myproject-0.0.1-SNAPSHOT.jar --debug
```

### 7.1.2. Lazy Initialization

`SpringApplication`은 필요에 따라 애플리케이션을 lazy 방식으로 초기화할 수 있다. 지연된 초기화<sup>lazy initialization</sup>가 활성화되면 애플리케이션을 기동하면서 모든 빈을 생성하기 보단, 필요에 따라 빈을 만든다. 결과적으론 지연 초기화를 통해 애플리케이션 기동에 걸리는 시간을 줄일 수 있다. 웹 애플리케이션에선 지연 초기화를 사용하면 HTTP 요청을 받기 전까진 웹과 관련된 많은 빈들을 초기화하지 않는다.

지연 초기화의 단점은 애플리케이션의 문제마저도 뒤늦게 발견할 수 있다는 거다. 잘못 설정한 빈을 lazy 방식으로 초기화하게 되면 기동 시엔 실패하지 않으며, 해당 빈을 초기화할 때가 돼서야 문제가 드러난다. 게다가 JVM의 메모리가 기동 시 초기화되는 빈 뿐만 아니라 애플리케이션의 다른 빈들도 전부 수용할 수 있을만큼 충분한지도 신경써서 확인해야 한다. 이러한 이유로 지연 초기화는 기본적으로 활성화하지 않으며, 지연 초기화를 활성화하려면 먼저 JVM의 힙 사이즈를 세밀하게 조정해보는 게 좋다.

지연 초기화는 `SpringApplicationBuilder`의 `lazyInitialization`이나, `SpringApplication`의 `setLazyInitialization` 메소드를 사용해 코드로 직접 활성화할 수 있다. 아니면 다음 예제처럼 `spring.main.lazy-initialization` 프로퍼티로 활성화해도 된다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.main.lazy-initialization=true
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  main:
    lazy-initialization: true
```

> 특정 빈들만 지연 초기화를 비활성화하고 나머지는 지연 초기화를 사용하고 싶다면 `@Lazy(false)` 어노테이션을 사용해 lazy 속성을 `false`로 명시하면 된다.

### 7.1.3. Customizing the Banner

기동 시 출력하는 배너는 클래스패스에 `banner.txt` 파일을 추가하거나, `spring.banner.location` 프로퍼티를 배너 파일의 위치로 설정해서 변경할 수 있다. 파일 인코딩이 UTF-8이 아니라면 `spring.banner.charset`을 설정하면 된다. 텍스트 파일 외에도, `banner.gif`, `banner.jpg`, `banner.png`같은 이미지 파일도 클래스패스에 추가하거나 `spring.banner.image.location` 프로퍼티에 설정할 수 있다. 이미지는 ASCII 아트<sup>ASCII art representation</sup>로 변환되며, 텍스트 배너 위에 출력된다.

`banner.txt` 파일 안에서는 다음과 같은 플레이스홀더를 사용할 수 있다:

| Variable                                                     | Description                                                  |
| :----------------------------------------------------------- | :----------------------------------------------------------- |
| `${application.version}`                                     | `MANIFEST.MF`에 선언한 애플리케이션의 버전 번호. 예를 들어 `Implementation-Version: 1.0`은 `1.0`으로 출력된다. |
| `${application.formatted-version}`                           | `MANIFEST.MF`에 선언한 애플리케이션의 버전을 출력용으로 포맷을 맞춰준 값 (괄호로 감싸고 앞에 `v`를 붙인다). 예를 들어 `(v1.0)`. |
| `${spring-boot.version}`                                     | 사용 중인 스프링 부트 버전. 예를 들어 `2.5.2`.               |
| `${spring-boot.formatted-version}`                           | 사용 중인 스프링 부트 버전을 출력용으로 포맷을 맞춰준 값 (괄호로 감싸고 앞에 `v`를 붙인다). 예를 들어 `(v2.5.2)`. |
| `${Ansi.NAME}` (또는 `${AnsiColor.NAME}`, `${AnsiBackground.NAME}`, `${AnsiStyle.NAME}`) | 여기서 `NAME`은 ANSI 이스케이프 코드<sup>ANSI escape code</sup>의 이름이다. 자세한 내용은 [`AnsiPropertySource`](https://github.com/spring-projects/spring-boot/tree/v2.5.2/spring-boot-project/spring-boot/src/main/java/org/springframework/boot/ansi/AnsiPropertySource.java)를 참고해라. |
| `${application.title}`                                       | `MANIFEST.MF`에 선언한 애플리케이션 타이틀. 예를 들어 `Implementation-Title: MyApp`은 `MyApp`으로 출력된다. |

> 배너를 코드를 통해 만들고 싶다면 `SpringApplication.setBanner(…)` 메소드를 사용하면 된다. `org.springframework.boot.Banner` 인터페이스를 사용해 자체 `printBanner()` 메소드를 구현해라.

`spring.main.banner-mode` 프로퍼티를 사용하면 배너를 `System.out`(`console`)에 출력할지, 설정한 로거(`log`)로 전송할지, 아예 생성하지 않을지(`off`)도 결정할 수 있다.

출력된 배너는 `springBootBanner`라는 이름의 싱글톤 빈으로 등록된다.

> `${application.version}`, `${application.formatted-version}` 프로퍼티는 스프링 부트 런처를 사용할 때만 이용할 수 있다. `java -cp <classpath> <mainclass>`로 패키징하지 않은 jar<sup>unpacked jar</sup>를 실행했다면 이 값들은 리졸브되지 않는다.
>
> 그렇기 때문에 패키징하지 않는 jar는 항상 `java org.springframework.boot.loader.JarLauncher`를 사용해 시작하는 게 좋다. 이렇게하면 클래스패스를 빌드하고 앱을 시작하기 전에 `application.*` 배너 변수를 초기화한다.

### 7.1.4. Customizing SpringApplication

`SpringApplication` 기본값이 마음에 들지 않으면 로컬 인스턴스를 만들어 커스텀해도 된다. 예를 들어 배너를 끄려면 다음과 같이 작성하면 된다:

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

> `SpringApplication` 생성자에 전달하는 인자는 스프링 빈을 위한 설정 소스다. 대부분 이 인자들은 `@Configuration` 클래스의 레퍼런스지만, `@Component` 클래스를 직접 참조하는 레퍼런스일 수도 있다.

`SpringApplication`은 `application.properties` 파일로도 설정할 수 있다. 자세한 내용은 *[설정 밖으로 빼기](../externalized-configuration)*를 참고해라.

전체 설정 옵션들은 [`SpringApplication` Javadoc](https://docs.spring.io/spring-boot/docs/2.5.2/api/org/springframework/boot/SpringApplication.html)에서 확인할 수 있다.

### 7.1.5. Fluent Builder API

`ApplicationContext`를 계층구조로 만들어야 하거나 (부모/자식 관계를 가진 여러 개의 컨텍스트), "fluent" 빌더 API를 선호한다면 `SpringApplicationBuilder`를 사용하면 된다.

아래 예제에 보이듯이, `SpringApplicationBuilder`를 사용하면 메소드를 여러 번 연결해서 호출할 수 있으며, `SpringApplicationBuilder`는 계층구조를 생성할 수 있는 `parent`, `child` 메소드를 가지고 있다:

```java
new SpringApplicationBuilder()
        .sources(Parent.class)
        .child(Application.class)
        .bannerMode(Banner.Mode.OFF)
        .run(args);
```

> `ApplicationContext` 계층을 만들 땐 제약이 몇 가지 있다. 예를 들어 웹 컴포넌트는 **반드시** 자식 컨텍스트 안에 포함시켜야 하며, 부모와 자식 컨텍스트에 같은 `Environment`를 사용한다. 자세한 내용은 [`SpringApplicationBuilder` Javadoc](https://docs.spring.io/spring-boot/docs/2.5.2/api/org/springframework/boot/builder/SpringApplicationBuilder.html)을 참고해라.

### 7.1.6. Application Availability

애플리케이션을 플랫폼에 배포하게 되면, [쿠버네티스 프로브](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)같은 인프라를 활용해 애플리케이션의 가용성 정보를 플랫폼에 전달할 수 있다. 스프링 부트는 흔히 사용하는 가용 상태<sup>availability state</sup>, "liveness", "readiness" 두 가지를 기본으로 제공한다. 스프링 부트의 "액추에이터" 기능을 사용하고 있다면 이 상태들은 health 엔드포인트 그룹으로 노출된다.

더불어 자체 빈에 `ApplicationAvailability` 인터페이스를 주입하면 직접 가용 상태를 조회할 수도 있다.

#### Liveness State

애플리케이션의 "Liveness" 상태는 내부 상태가 올바르게 작동할 수 있는 상태인지 또는 현재 실패했다면 자체적으로 복구할 수 있는 상태인지를 알려준다. "Liveness" 상태가 깨졌다는 건 애플리케이션이 복구할 수 없는 상태에 있으며, 인프라에서 애플리케이션을 재시작해야 한다는 걸 의미한다.

> 일반적으로 "Liveness" 상태는 [헬스 체크](../endpoints#828-health-information)와 같은 외부 상태를 기반으로 동작하면 안 된다. 이렇게 되면 외부 시스템(데이터베이스, 웹 API, 외부 캐시)이 실패했을 때 플랫폼 전체에 걸친 대규모 재시작과 연이은 실패를 트리거하게 된다.

스프링 부트 애플리케이션의 내부 상태는 주로 스프링 `ApplicationContext` 상태를 대변한다. 애플리케이션 컨텍스트 기동에 성공하면 스프링 부트는 애플리케이션이 유효한 상태에 있다고 가정한다. 컨텍스트가 리프레시를 마치는 즉시 애플리케이션를 활성 상태로 간주한다. [스프링 부트 애플리케이션 라이프 사이클과 관련 애플리케이션 이벤트들](#717-application-events-and-listeners)을 참고해라.

#### Readiness State

애플리케이션의 "Readiness" 상태는 애플리케이션이 트래픽을 처리할 준비가 되었는지를 나타낸다. "Readiness" 상태가 깨졌다는 건 현재는 플랫폼이 트래픽을 해당 애플리케이션으로 라우팅하면 안 된다는 걸 뜻한다. Readiness 실패는 보통 기동 중에 `CommandLineRunner`와 `ApplicationRunner` 컴포넌트를 처리하는 동안 발생하며, 애플리케이션이 트래픽을 더 받기엔 너무 바쁘다고 판단하는 경우에도 언제든지 발생할 수 있다.

애플리케이션과 커맨드라인 runner 실행을 마치는 즉시 애플리케이션이 준비된 것으로 간주한다. [스프링 부트 애플리케이션 라이프 사이클과 관련 애플리케이션 이벤트들](#717-application-events-and-listeners)을 참고해라.

> 애플리케이션 기동 시 실행하길 바라는 태스크는 `@PostConstruct`같은 스프링 컴포넌트 라이프 사이클 콜백을 사용하기보단, `CommandLineRunner`와 `ApplicationRunner` 컴포넌트로 실행해야 한다.

#### Managing the Application Availability State

애플리케이션 컴포넌트는 `ApplicationAvailability` 인터페이스를 주입해서 여기 있는 메소드를 호출하면 언제든지 현재 가용 상태를 조회할 수 있다. 대개는 애플리케이션에서 상태가 업데이트되면 통지받거나<sup>listen</sup>, 애플리케이션의 상태를 업데이트하고 싶어질 거다.

예를 들어, 쿠버네티스 "exec Probe"로 상태를 알 수 있도록 애플리케이션의 "Readiness" 상태를 파일로 익스포트할 수 있다:

```java
@Component
public class MyReadinessStateExporter {

    @EventListener
    public void onStateChange(AvailabilityChangeEvent<ReadinessState> event) {
        switch (event.getState()) {
        case ACCEPTING_TRAFFIC:
            // create file /tmp/healthy
            break;
        case REFUSING_TRAFFIC:
            // remove file /tmp/healthy
            break;
        }
    }

}
```

애플리케이션이 실패해서 복구할 수 없을 때에도 애플리케이션 상태를 업데이트할 수 있다:

```java
@Component
public class MyLocalCacheVerifier {

    private final ApplicationEventPublisher eventPublisher;

    public MyLocalCacheVerifier(ApplicationEventPublisher eventPublisher) {
        this.eventPublisher = eventPublisher;
    }

    public void checkLocalCache() {
        try {
            // ...
        }
        catch (CacheCompletelyBrokenException ex) {
            AvailabilityChangeEvent.publish(this.eventPublisher, ex, LivenessState.BROKEN);
        }
    }

}
```

스프링 부트는 [액추에이터 Health 엔드포인트를 통해 쿠버네티스의 "Liveness", "Readiness" HTTP 프로브](../endpoints#829-kubernetes-probes)를 제공한다. [스프링 부트 애플리케이션을 쿠버네티스에 배포하는 방법은 전용 섹션에서](../deploying-spring-boot-applications#922-kubernetes) 상세 가이드를 확인할 수 있다.

### 7.1.7. Application Events and Listeners

[`ContextRefreshedEvent`](https://docs.spring.io/spring-framework/docs/5.3.8/javadoc-api/org/springframework/context/event/ContextRefreshedEvent.html)같은 일상적인 스프링 프레임워크 이벤트 말고도, `SpringApplication`은 몇 가지 다른 애플리케이션 이벤트들도 전송한다.

> 어떤 이벤트들은 실제로 `ApplicationContext`가 생성되기 전에 트리거되므로, 이런 이벤트에는 `@Bean`으로 리스너를 등록할 수 없다. 이런 이벤트 리스너는 `SpringApplication.addListeners(…)` 메소드나 `SpringApplicationBuilder.listeners(…)` 메소드로 등록할 수 있다.
>
> 이런 리스너도 애플리케이션 생성 방식에 관계 없이 자동으로 등록되도록 하려면 프로젝트에 `META-INF/spring.factories` 파일을 추가하고, 아래 예시처럼 <span class="custom-blockquote">org.springframework.context.ApplicationListener</span> 키를 사용해 원하는 리스너를 참조시키면 된다:
>
> ```
> org.springframework.context.ApplicationListener=com.example.project.MyListener
> ```

애플리케이션이 실행될 때는 다음과 같은 순서로 애플리케이션 이벤트를 전송한다:

1. 기동을 시작하고 리스너와 이니셜라이저 등록만 마치면, 나머지 프로세스를 진행하기 전에 가장 먼저 `ApplicationStartingEvent`를 전송한다.
2. 컨텍스트에서 사용할 `Environment`를 파악하면 컨텍스트를 생성하기 전에 `ApplicationEnvironmentPreparedEvent`를 전송한다.
3. `ApplicationContext`가 준비되면 `ApplicationContextInitializer`를 호출하고서, 빈 정의를 로드하기 전에 먼저 `ApplicationContextInitializedEvent`를 전송한다.
4. 빈 정의를 로드하고 나면 리프레시를 시작하기 직전에 `ApplicationPreparedEvent`를 전송한다.
5. 컨텍스트를 리프레시한 후엔 애플리케이션과 커맨드라인 runner를 호출하기 전에 먼저 `ApplicationStartedEvent`를 전송한다.
6. 직후에 `AvailabilityChangeEvent`로 `LivenessState.CORRECT`를 전송해 애플리케이션을 활성 상태로 간주함을 알린다.
7. [애플리케이션과 커맨드라인 runner](#7110-using-the-applicationrunner-or-commandlinerunner)를 호출한 후엔 `ApplicationReadyEvent`를 전송한다.
8. 직후에 `AvailabilityChangeEvent`로 `ReadinessState.ACCEPTING_TRAFFIC`을 전송해 애플리케이션이 서비스 요청을 처리할 준비가 되었음을 알린다.
9. 기동 시 예외가 있으면 `ApplicationFailedEvent`를 전송한다.

위에서는 `SpringApplication`과 직접적인 연관이 있는 `SpringApplicationEvent`들만 나타냈다. 이 이벤트들 외에도, `ApplicationPreparedEvent`를 전송하고 나서 `ApplicationStartedEvent`를 전송하기 전에 아래와 같은 이벤트들도 게시한다:

- `WebServer`가 준비되고 나면 `WebServerInitializedEvent`를 전송한다. 서블릿과 리액티브에선 각각 `ServletWebServerInitializedEvent`와 `ReactiveWebServerInitializedEvent`를 전송한다.
- `ApplicationContext`가 리프레시되면 `ContextRefreshedEvent`를 전송한다.

> 보통은 애플리케이션 이벤트를 사용할 필욘 없지만, 존재하는 것 정도는 알아두는 게 좋다. 스프링 부트는 내부적으로 이벤트들을 사용해 다양한 태스크를 처리한다.

> 이벤트 리스너는 기본적으로 같은 스레드에서 실행되기 때문에, 그 안에서 너무 긴 태스크를 수행해선 안 된다. 이럴 땐 이벤트 리스너대신 [애플리케이션과 커맨드라인 runner](#7110-using-the-applicationrunner-or-commandlinerunner)를 검토해봐라.

애플리케이션 이벤트는 스프링 프레임워크의 이벤트 게시 메커니즘<sup>event publishing mechanism</sup>을 사용해 전송한다. 이 메커니즘으로 인해 자식 컨텍스트의 리스너에 게시된 이벤트는 모든 상위 컨텍스트의 리스너에도 게시된다. 따라서 애플리케이션이 `SpringApplication` 인스턴스의 계층구조를 사용한다면, 리스너는 같은 유형의 애플리케이션 이벤트 인스턴스를 여러 번 수신할 수도 있다.

리스너에서 해당 컨텍스트에 대한 이벤트와 하위 컨텍스트에 대한 이벤트를 구별하려면, 해당 애플리케이션 컨텍스트 주입을 요청한 다음 주입한 컨텍스트를 이벤트의 컨텍스트와 비교해야 한다. 컨텍스트는 `ApplicationContextAware`를 구현하거나, 리스너가 빈일 땐 `@Autowired`를 사용해 주입할 수 있다.

### 7.1.8. Web Environment

`SpringApplication`은 사용자를 대신해서 `ApplicationContext`를 올바른 타입으로 생성해본다. `WebApplicationType`을 결정하는 데 사용하는 알고리즘은 다음과 같다:

- 스프링 MVC가 있다면 `AnnotationConfigServletWebServerApplicationContext`를 사용한다
- 스프링 MVC는 없고 스프링 웹플럭스가 있다면 `AnnotationConfigReactiveWebServerApplicationContext`를 사용한다
- 그 외엔 `AnnotationConfigApplicationContext`를 사용한다

즉, 하나의 애플리케이션에서 스프링 MVC와 스프링 웹플럭스의 새 `WebClient`를 동시에 사용한다면 기본적으로 스프링 MVC를 사용한다. 이 동작은 `setWebApplicationType(WebApplicationType)`을 호출하면 간단하게 재정의할 수 있다.

`setApplicationContextClass(…)`를 호출하면 사용하는 `ApplicationContext` 타입을 직접 선택할 수도 있다.

> JUnit 테스트 내에서 `SpringApplication`을 사용할 땐 보통은 `setWebApplicationType(WebApplicationType.NONE)`을 호출하는 게 바람직하다.

### 7.1.9. Accessing Application Arguments

`SpringApplication.run(…)`에 전달한 애플리케이션 인자에 접근해야 한다면 <span class="custom-blockquote">org.springframework.boot.ApplicationArguments</span> 빈을 주입하면 된다. 이 `ApplicationArguments` 인터페이스는 다음 예제에서 볼 수 있듯, 원본 `String[]` 인자들과 함께 이를 파싱한 `option`, `non-option` 인자에 접근할 수 있게 해준다.

```java
@Component
public class MyBean {

    public MyBean(ApplicationArguments args) {
        boolean debug = args.containsOption("debug");
        List<String> files = args.getNonOptionArgs();
        if (debug) {
            System.out.println(files);
        }
        // if run with "--debug logfile.txt" prints ["logfile.txt"]
    }

}
```

> 그 외에도 스프링 부트는 스프링 `Environment`에 `CommandLinePropertySource`를 등록한다. 덕분에 `@Value` 어노테이션을 사용해 애플리케이션 인자를 하나씩 주입할 수도 있다.

### 7.1.10. Using the ApplicationRunner or CommandLineRunner

`SpringApplication`이 시작되고 나면 실행해야 하는 코드가 있다면 `ApplicationRunner`나 `CommandLineRunner` 인터페이스를 구현하면 된다. 두 인터페이스 동작 방식은 동일하며, `SpringApplication.run(…)`을 완료하기 직전에 호출하는 `run`  메소드를 하나 제공한다.

> 이 인터페이스는 애플리케이션을 기동한 후 트래픽을 받기 시작하기 전에 실행해야 하는 작업에 적합하다.

`ApplicationRunner`는 앞에서 설명한 `ApplicationArguments` 인터페이스를 사용하는 반면, `CommandLineRunner` 인터페이스에선 문자열 배열로 애플리케이션 인자에 접근할 수 있게 해준다. 다음은 `run` 메소드를 가지고 있는 `CommandLineRunner` 예시다:

```java
@Component
public class MyCommandLineRunner implements CommandLineRunner {

    @Override
    public void run(String... args) {
        // Do something...
    }

}
```

정의해둔 몇 가지 `CommandLineRunner`나 `ApplicationRunner` 빈을 정해진 순서로 호출해야 한다면, `org.springframework.core.Ordered` 인터페이스를 구현하거나 `org.springframework.core.annotation.Order` 어노테이션을 사용하면 된다.

### 7.1.11. Application Exit

모든 `SpringApplication`은 JVM에 셧다운 훅을 등록해서 종료 시 `ApplicationContext`가 정상적으로<sup>gracefully</sup> 닫히도록 만든다. 이땐 모든 표준 스프링 라이프 사이클 콜백(ex. `DisposableBean` 인터페이스, `@PreDestroy` 어노테이션)을 사용할 수 있다.

또한 `SpringApplication.exit()`를 호출할 때 특정 종료 코드를 반환하고 싶은 빈은 `org.springframework.boot.ExitCodeGenerator` 인터페이스를 구현하면 된다. 다음 예제처럼 `System.exit()`에 이 종료 코드를 전달하면 이 값을 상태 코드로 반환할 수 있다:

```java
@SpringBootApplication
public class MyApplication {

    @Bean
    public ExitCodeGenerator exitCodeGenerator() {
        return () -> 42;
    }

    public static void main(String[] args) {
        System.exit(SpringApplication.exit(SpringApplication.run(MyApplication.class, args)));
    }

}
```

`ExitCodeGenerator` 인터페이스는 예외 클래스에서 구현해도 된다. 이 인터페이스를 구현한 예외가 발생하면 스프링 부트는 구현한 `getExitCode()` 메소드가 제공하는 종료 코드를 리턴한다.

### 7.1.12. Admin Features

`spring.application.admin.enabled` 프로퍼티를 지정하면 애플리케이션을 위한 어드민 관련 기능을 활성화할 수 있다. 어드민 기능을 활성화하면 플랫폼 `MBeanServer`에 [`SpringApplicationAdminMXBean`](https://github.com/spring-projects/spring-boot/tree/v2.5.2/spring-boot-project/spring-boot/src/main/java/org/springframework/boot/admin/SpringApplicationAdminMXBean.java)을 노출한다. 이 기능을 사용하면 스프링 부트 애플리케이션을 원격에서 관리할 수 있다. 서비스 래퍼 구현에서도 유용할 거다.

> 애플리케이션이 실행되고 있는 HTTP 포트를 알고 싶다면 `local.server.port` 키로 프로퍼티를 가져와라.

### 7.1.13. Application Startup tracking

애플리케이션이 기동되는 동안 `SpringApplication`과 `ApplicationContext`는 애플리케이션 라이프 사이클, 빈 라이프 사이클, 애플리케이션 이벤트 처리와 관련된 많은 작업들을 진행한다. [`ApplicationStartup`](https://docs.spring.io/spring-framework/docs/5.3.8/javadoc-api/org/springframework/core/metrics/ApplicationStartup.html)을 사용하면 스프링 프레임워크의 지원을 받아 [`StartupStep` 객체로 애플리케이션 기동 시퀀스를 추적할 수 있다](https://docs.spring.io/spring-framework/docs/5.3.8/reference/html/core.html#context-functionality-startup). 이 데이터는 프로파일링 목적이나 애플리케이션 기동 프로세스를 좀 더 잘 이해하기 위한 용도로 수집하면 된다.

`ApplicationStartup` 구현체는 `SpringApplication` 인스턴스를 설정할 때 선택할 수 있다. 예를 들어 다음과 같이 작성하면 `BufferingApplicationStartup`을 사용할 수 있다:

```java
@SpringBootApplication
public class MyApplication {

    public static void main(String[] args) {
        SpringApplication application = new SpringApplication(MyApplication.class);
        application.setApplicationStartup(new BufferingApplicationStartup(2048));
        application.run(args);
    }

}
```

첫 번째로 소개할 구현체는 `FlightRecorderApplicationStartup`으로, 스프링 프레임워크에서 제공한다. 자바 Flight Recorder 세션에 스프링 전용 startup 이벤트를 추가하며, 애플리케이션을 프로파일링하고 해당 스프링 컨텍스트 라이프 사이클을 JVM 이벤트(ex. 할당, GC, 클래스 로딩…)와 연계해서 모니터링하는 용도로 사용한다. 이 구현체를 설정하고 나면, 애플리케이션을 Flight Recorder가 활성화된 상태로 실행해서 데이터를 기록할 수 있다.

```shell
$ java -XX:StartFlightRecording:filename=recording.jfr,duration=10s -jar demo.jar
```

스프링 부트는 또 다른 구현체 `BufferingApplicationStartup`을 제공한다. 이 구현체는 startup 스텝을 버퍼링하고 이를 외부 메트릭 시스템으로 빼내기 위한 용도다. `BufferingApplicationStartup` 타입 빈은 애플리케이션의 모든 컴포넌트에서 요청할 수 있다.

스프링 부트는 이 정보를 JSON 도큐먼트로 제공하는 [`startup` 엔드포인트](https://docs.spring.io/spring-boot/docs/2.5.2/actuator-api/htmlsingle/#startup)를 노출하도록 설정할 수도 있다.
