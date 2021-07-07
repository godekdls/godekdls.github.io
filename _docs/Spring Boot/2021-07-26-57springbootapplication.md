---
title: Spring Boot Application
category: Spring Boot
order: 57
permalink: /Spring%20Boot/howto.spring-boot-application/
description: 스프링 부트 애플리케이션과 관련된 how to 가이드 (자동 설정 트러블 슈팅, ApplicationContext 커스텀하기)
image: ./../../images/springboot/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 부트
originalRefLink: https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#howto.application
parent: “How-to” Guides
parentUrl: /Spring%20Boot/how-to-guides/
---

### 목차

- [12.1.1. Create Your Own FailureAnalyzer](#1211-create-your-own-failureanalyzer)
- [12.1.2. Troubleshoot Auto-configuration](#1212-troubleshoot-auto-configuration)
- [12.1.3. Customize the Environment or ApplicationContext Before It Starts](#1213-customize-the-environment-or-applicationcontext-before-it-starts)
- [12.1.4. Build an ApplicationContext Hierarchy (Adding a Parent or Root Context)](#1214-build-an-applicationcontext-hierarchy-adding-a-parent-or-root-context)
- [12.1.5. Create a Non-web Application](#1215-create-a-non-web-application)

---

## 12.1. Spring Boot Application

이번 섹션은 스프링 부트 애플리케이션과 직접적인 연관이 있는 토픽들을 담고 있다.

### 12.1.1. Create Your Own FailureAnalyzer

[`FailureAnalyzer`](https://docs.spring.io/spring-boot/docs/2.5.2/api/org/springframework/boot/diagnostics/FailureAnalyzer.html)는 기동시 시 예외를 가로채서 [`FailureAnalysis`](https://docs.spring.io/spring-boot/docs/2.5.2/api/org/springframework/boot/diagnostics/FailureAnalysis.html)로 감싸 사람이 읽을 수 있는 메세지로 변환할 때 사용하기 좋은 인터페이스다. 스프링 부트는 애플리케이션 컨텍스트와 관련된 예외나 JSR-303 유효성 검사 등에 활용할 수 있는 analyzer를 제공한다. 물론 직접 만들 수도 있다.

`AbstractFailureAnalyzer`는 `FailureAnalyzer`를 간편하게 사용할 수 있게 확장한 클래스로, 처리할 예외에 지정한 예외 타입이 존재하는 지를 확인해준다. 이 클래스를 상속받으면 실제로 예외가 존재할 때만 처리하도록 구현할 수 있다. 어떤 이유에서든지 예외를 처리할 수 없을 때는 다른 구현체가 예외를 처리할 수 있도록 `null`을 반환해라.

`FailureAnalyzer` 구현체는 반드시 `META-INF/spring.factories`에 등록해줘야 한다. 다음은 `ProjectConstraintViolationFailureAnalyzer`를 등록하는 예시다:

```properties
org.springframework.boot.diagnostics.FailureAnalyzer=\
com.example.ProjectConstraintViolationFailureAnalyzer
```

> `BeanFactory`나 `Environment`에 접근해야 한다면 `FailureAnalyzer`에서 각각 `BeanFactoryAware`, `EnvironmentAware`를 구현하면 된다.

### 12.1.2. Troubleshoot Auto-configuration

스프링 부트 자동 설정은 "맞는 일을 하기 위해" 최선을 다하지만, 상황에 따라 실패할 수도 있으며, 이유를 알아내기 어려울 때도 있다.

스프링 부트의 모든 `ApplicationContext`에선 정말 유용한 `ConditionEvaluationReport`를 사용할 수 있다. 이 리포트는 `DEBUG` 로그 출력을 활성화하면 볼 수 있다. `spring-boot-actuator`([액추에이터 챕터](../spring-boot-actuator) 참고)를 사용한다면, 이 리포트를 JSON으로 렌더링해주는 `conditions` 엔드포인트도 이용할 수 있다. 이 엔드포인트를 활용해 애플리케이션을 디버그하고, 스프링 부트가 런타임에 추가한(그리고 추가하지 않은 기능도 함께) 기능들을 확인해봐라.

소스 코드와 Javadoc을 살펴보면 다른 궁금증도 많이 해결될 거다. 코드를 읽을 때는 경험상 아래 규칙을 기억해두면 좋다:

- `*AutoConfiguration`이란 클래스를 찾아 소스 코드를 읽어봐라. 어떤 기능이 언제 활성화되는지 알아내려면  `@Conditional*` 어노테이션을 특히 주의깊게 살펴봐라. 앱에서 결정한 모든 자동 설정 결과를 콘솔 로그를 통해 확인하려면 커맨드라인에 `--debug`를 추가하거나 시스템 프로퍼티 `-Ddebug`를 추가해라. 액추에이터를 활성화해서 실행 중인 애플리케이션에선 같은 정보를 `conditions` 엔드포인트(`/actuator/conditions` 혹은 JMX로)에서 확인할 수 있다.
- `@ConfigurationProperties`로 사용 중인 클래스(ex. [`ServerProperties`](https://github.com/spring-projects/spring-boot/tree/v2.5.2/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/web/ServerProperties.java))를 찾아 가능한 외부 설정 옵션들을 읽어봐라. `@ConfigurationProperties` 어노테이션은 외부 프로퍼티의 프리픽스로 사용하는 `name` 속성을 가지고 있다. 즉, `ServerProperties`는 `prefix="server"`를 가지고 있고, 그에 따라 설정 프로퍼티는 `server.port`, `server.address`가 된다. 액추에이터를 활성화해서 실행 중인 애플리케이션에선 `configprops` 엔드포인트를 확인해라.
- `Environment`에 있는 설정 값을 [완화한 바인딩 규칙으로](../externalized-configuration#relaxed-binding) 명시해 가져오려면 `Binder`에서 `bind` 메소드를 사용하는 방법을 살펴봐라. 보통은 프리픽스와 함께 사용한다.
- `Environment`에 직접 바인딩되는 `@Value` 어노테이션을 찾아봐라.
- SpEL 표현식에 따라 기능을 켜고 끄는 `@ConditionalOnExpression` 어노테이션을 찾아봐라. SpEL 표현식은 보통 `Environment`에서 리졸브하는 플레이스홀더로 평가한다.

### 12.1.3. Customize the Environment or ApplicationContext Before It Starts

`SpringApplication`은 컨텍스트나 environment를 커스텀할 때 사용할 수 있는 `ApplicationListeners`와 `ApplicationContextInitializers`를 가지고 있다. 스프링 부트는 `META-INF/spring.factories`에서 내부적으로 사용할 여러 가지 커스텀 로직을 로드한다. 별도 커스텀 로직을 등록하는 방법은 여러 가지가 있다:

- 애플리케이션 단위로 `SpringApplication`을 실행하기 전 코드를 통해 `addListeners`와 `addInitializers` 메소드를 호출하는 방법.
- 애플리케이션 단위로 `context.initializer.classes`나 `context.listener.classes` 프로퍼티 설정을 선언하는 방법.
- `META-INF/spring.factories`를 추가하고 jar 파일을 패키징해서, 모든 애플리케이션이 이 jar 파일을 라이브러리로 활용하는 방법.

`SpringApplication`은 리스너에게 특별한 `ApplicationEvent`들을 전송하고 (몇 가지 이벤트는 컨텍스트를 만들기 전에 전송한다), `ApplicationContext`가 게시한 이벤트들을 수신할 리스너도 등록한다. 전체 목록은 '스프링 부트 기능' 섹션에 있는 "[애플리케이션 이벤트와 리스너](../spring-application#717-application-events-and-listeners)"를 참고해라.

`EnvironmentPostProcessor`를 사용하면 애플리케이션 컨텍스트를 리프레시하기 전에도 `Environment`를 커스텀할 수 있다. 모든 구현체는 아래 예시처럼 `META-INF/spring.factories`에 등록해야 한다:

```
org.springframework.boot.env.EnvironmentPostProcessor=com.example.YourEnvironmentPostProcessor
```

이 구현체에선 임의의 파일들을 로드해서 `Environment`에 추가할 수 있다. 예를 들어 아래 코드에선 클래스패스에 있는 YAML 설정 파일을 로드한다:

```java
public class MyEnvironmentPostProcessor implements EnvironmentPostProcessor {

    private final YamlPropertySourceLoader loader = new YamlPropertySourceLoader();

    @Override
    public void postProcessEnvironment(ConfigurableEnvironment environment, SpringApplication application) {
        Resource path = new ClassPathResource("com/example/myapp/config.yml");
        PropertySource<?> propertySource = loadYaml(path);
        environment.getPropertySources().addLast(propertySource);
    }

    private PropertySource<?> loadYaml(Resource path) {
        Assert.isTrue(path.exists(), () -> "Resource " + path + " does not exist");
        try {
            return this.loader.load("custom-resource", path).get(0);
        }
        catch (IOException ex) {
            throw new IllegalStateException("Failed to load yaml configuration from " + path, ex);
        }
    }

}
```

> `Environment`에는 스프링 부트가 기본으로 로드하는 일반적인 프로퍼티 소스가 전부 준비돼 있다. 그렇기 때문에 environment에서 이런 파일의 위치를 가져올 수도 있다. 위 예제에선 리스트 마지막에 `custom-resource` 프로퍼티 소스를 추가해서, 다른 위치에 정의되어 있는 일반적인 키가 우선적으로 적용되게 만들고 있다. 직접 구현할 땐 순서를 다르게 정의해도 된다.

> `@SpringBootApplication` 위에 `@PropertySource`를 선언하면 간편하게 `Environment` 안에 있는 커스텀 리소스를 로드할 수 있는 것처럼 보일 수도 있지만 권장하지 않는다. 이런 프로퍼티 소스는 애플리케이션 컨텍스트를 리프레시할 때까지 `Environment`에 추가되지 않는다. 리프레시를 시작하기 전에 읽어가는 `logging.*`, `spring.main.*`같은 프로퍼티를 설정하기에는 너무 늦다.

### 12.1.4. Build an ApplicationContext Hierarchy (Adding a Parent or Root Context)

`SpringApplicationBuilder` 클래스를 사용하면 `ApplicationContext`의 부모/자식 계층구조를 만들 수 있다. 자세한 내용은 '스프링 부트 기능' 섹션에 있는 "[Fluent Builder API](../spring-application#715-fluent-builder-api)"를 참고해라.

### 12.1.5. Create a Non-web Application

스프링 애플리케이션이라고 해서 무조건 웹 애플리케이션(또는 웹 서비스)일 필요는 없다. `main` 메소드에서 몇 가지 코드를 실행하되, 사용할 인프라를 설정하는 용도로 스프링 애플리케이션을 부트스트랩하고 싶을 때는, 스프링 부트의 `SpringApplication` 기능을 사용하면 된다. `SpringApplication`은 웹 애플리케이션이 필요한지 아닌지에 따라 `ApplicationContext` 클래스를 변경한다. 이를 위해 가장 먼저 할 수 있는 일은 서버 관련 의존성(ex. 서블릿 API)을 클래스패스에서 제외하는 거다. 이게 어렵다면 (예를 들어 동일한 코드를 기반으로 애플리케이션을 두 개 실행한다거나) `SpringApplication` 인스턴스에서 직접 `setWebApplicationType(WebApplicationType.NONE)`을 호출하거나, `applicationContextClass` 프로퍼티를 설정해주면 된다 (자바 API나 외부 프로퍼티를 이용해서). 비즈니스 로직으로 실행하고 싶은 애플리케이션 코드는 `CommandLineRunner`로 구현하고 `@Bean` 정의로 컨텍스트에 넣어주면 된다.
