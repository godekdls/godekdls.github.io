---
title: Creating Your Own Auto-configuration
category: Spring Boot
order: 37
permalink: /Spring%20Boot/creating-your-own-auto-configuration/
description: 직접 스프링 부트 자동 설정 개발하기
image: ./../../images/springboot/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 부트
originalRefLink: https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#features.developing-auto-configuration
parent: Spring Boot Features
parentUrl: /Spring%20Boot/spring-boot-features/
---

### 목차

- [7.29.1. Understanding Auto-configured Beans](#7291-understanding-auto-configured-beans)
- [7.29.2. Locating Auto-configuration Candidates](#7292-locating-auto-configuration-candidates)
- [7.29.3. Condition Annotations](#7293-condition-annotations)
  + [Class Conditions](#class-conditions)
  + [Bean Conditions](#bean-conditions)
  + [Property Conditions](#property-conditions)
  + [Resource Conditions](#resource-conditions)
  + [Web Application Conditions](#web-application-conditions)
  + [SpEL Expression Conditions](#spel-expression-conditions)
- [7.29.4. Testing your Auto-configuration](#7294-testing-your-auto-configuration)
  + [Simulating a Web Context](#simulating-a-web-context)
  + [Overriding the Classpath](#overriding-the-classpath)
- [7.29.5. Creating Your Own Starter](#7295-creating-your-own-starter)
  + [Naming](#naming)
  + [Configuration keys](#configuration-keys)
  + [The “autoconfigure” Module](#the-autoconfigure-module)
  + [Starter Module](#starter-module)

---

## 7.29. Creating Your Own Auto-configuration

공유 라이브러리를 개발하는 회사에서 일한다거나, 오픈 소스나 상용 라이브러리를 만들고 있다면 자체 자동 설정을 개발하고 싶을 수 있다. 자동 설정 클래스는 외부 jar 번들로 제공할 수 있으며, 그렇더라도 스프링 부트에서 감지해낼 수 있다.

자동 설정은 자동 설정 코드와 더불어, 같이 사용할만한 전형적인 라이브러리들을 함께 제공하는 "스타터"에 연계할 수 있다. 자체 자동 설정을 구축하기 전에 먼저 알아둬야 할 점들을 다루고 나서 [커스텀 스타터를 만들 때 필요한 전형적인 절차](#7295-creating-your-own-starter)로 넘어가겠다.

> 스타터를 만드는 방법을 단계별로 소개하고 있는 [데모 프로젝트](https://github.com/snicoll-demos/spring-boot-master-auto-configuration)를 제공한다.

### 7.29.1. Understanding Auto-configured Beans

자동 설정을 잘 들여다보면, 표준 `@Configuration` 클래스를 사용해서 구현하고 있다. `@Conditional` 어노테이션을 함께 사용하면 자동 설정을 적용해야 하는 시점을 제한할 수 있다. 자동 설정 클래스에선 보통 `@ConditionalOnClass`와 `@ConditionalOnMissingBean` 어노테이션을 사용한다. 이 둘을 사용하면 관련 클래스를 발견함과 동시에 자체 `@Configuration`을 선언하지 않았을 때만 자동 설정을 적용할 수 있다.

[`spring-boot-autoconfigure`](https://github.com/spring-projects/spring-boot/tree/v2.5.2/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure)에 있는 소스 코드를 둘려보면 스프링이 제공하는 `@Configuration` 클래스들을 확인할 수 있다 ([`META-INF/spring.factories`](https://github.com/spring-projects/spring-boot/tree/v2.5.2/spring-boot-project/spring-boot-autoconfigure/src/main/resources/META-INF/spring.factories) 파일 참고).

### 7.29.2. Locating Auto-configuration Candidates

스프링 부트는 게시한 jar 내에 `META-INF/spring.factories` 파일이 있는지를 확인해본다. 이 파일에선 아래처럼 원하는 설정 클래스들을  `EnableAutoConfiguration` 키 밑으로 나열해야 한다:

```
org.springframework.boot.autoconfigure.EnableAutoConfiguration=\
com.mycorp.libx.autoconfigure.LibXAutoConfiguration,\
com.mycorp.libx.autoconfigure.LibXWebAutoConfiguration
```

> 자동 설정은 반드시 *이 방식으로만* 로드해야 한다. 자동 설정은 특정 패키지 공간에 정의해 둬야 하며, 절대 컴포넌트 스캔의 대상이 되면 안 된다. 뿐만 아니라, 자동 설정 클래스에선 다른 컴포넌트를 찾기 위해 컴포넌트 스캔을 활성화해선 안 된다. 그대신 `@Import`로 지정해줘야 한다.

설정을 원하는 순서대로 적용해야 한다면 [`@AutoConfigureAfter`](https://github.com/spring-projects/spring-boot/tree/v2.5.2/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/AutoConfigureAfter.java)나 [`@AutoConfigureBefore`](https://github.com/spring-projects/spring-boot/tree/v2.5.2/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/AutoConfigureBefore.java) 어노테이션을 사용하면 된다. 예를 들어 웹 전용 설정을 제공할 때는 `WebMvcAutoConfiguration`을 먼저 적용한 다음에 적용해야 할 수 있다.

순서를 지정하고 싶은 자동 설정들이 서로를 직접 알진 못해야 한다면 `@AutoConfigureOrder`를 사용해도 된다. 이 어노테이션은 일반 `@Order` 어노테이션과 시맨틱스는 같지만, 자동 설정 클래스들을 위한 전용 순서를 제공한다.

자동 설정 클래스를 적용하는 순서는 표준 `@Configuration` 클래스와 동일하게 거기에 있는 빈을 정의하는 순서에만 영향이 있다. 이후에 빈을 생성하는 순서에는 영향이 없으며, 빈 생성 순서는 각 빈이 가지고 있는 의존성과 `@DependsOn` 관계들로만 결정된다.

### 7.29.3. Condition Annotations

자동 설정 클래스를 만들 땐 `@Conditional` 어노테이션 하나 이상은 거의 항상 필요할 거다. 많이 쓰는 예시로는 `@ConditionalOnMissingBean` 어노테이션이 있는데, 자동 설정되는 기본 값을 필요할 때 개발자가 직접 재정의할 수 있게 해주는 어노테이션이다.

스프링 부트에는 `@Configuration` 클래스나 `@Bean` 메소드 개별로 어노테이션을 달아 자체 코드에 재사용할 수 있는 여러 가지 `@Conditional` 어노테이션들이 들어 있다. 다음과 같은 어노테이션들이 있다:

- [Class Conditions](#class-conditions)
- [Bean Conditions](#bean-conditions)
- [Property Conditions](#property-conditions)
- [Resource Conditions](#resource-conditions)
- [Web Application Conditions](#web-application-conditions)
- [SpEL Expression Conditions](#spel-expression-conditions)

#### Class Conditions

`@ConditionalOnClass`와 `@ConditionalOnMissingClass` 어노테이션을 사용하면 특정 클래스의 유무에 따라 `@Configuration` 클래스를 포함시킬 수 있다. 어노테이션 메타데이터는 [ASM](https://asm.ow2.io/)을 통해 파싱한다는 사실 덕분에, `value` 속성에선 실제 클래스가 실행 중인 애플리케이션의 클래스패스에 없더라도 참조할 수 있다. `String`으로 클래스명을 지정하고 싶다면 `name` 속성을 사용해도 된다.

전형적인 리턴 타입을 조건으로 두는 `@Bean` 메소드에선 이 메커니즘이 똑같이 적용되지 않는다. 메소드의 조건을 적용하기 전에 이미 JVM이 클래스를 로드하고, 메소드 참조를 처리했을 건데, 이 시점에 클래스가 존재하지 않으면 실패할 거다.

이럴 때는 아래 예시처럼 별도 `@Configuration` 클래스를 사용하면 조건을 격리시킬 수 있다:

```java
@Configuration(proxyBeanMethods = false)
// Some conditions ...
public class MyAutoConfiguration {

    // Auto-configured beans ...

    @Configuration(proxyBeanMethods = false)
    @ConditionalOnClass(SomeService.class)
    public static class SomeServiceConfiguration {

        @Bean
        @ConditionalOnMissingBean
        public SomeService someService() {
            return new SomeService();
        }

    }

}
```

> `@ConditionalOnClass`나 `@ConditionalOnMissingClass`를 메타 어노테이션으로 사용해서 자체 [composed annotation](https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#beans-meta-annotations)을 구성한다면, 이렇게는 처리하지 못하며, 반드시 `name`으로 클래스를 참조해야 한다.

#### Bean Conditions

`@ConditionalOnBean`과 `@ConditionalOnMissingBean` 어노테이션으로는 특정 빈의 유무에 따라 빈을 포함시킬 수 있다. `value` 속성으로 빈의 타입을 지정할 수도 있고, `name`으로 빈의 이름을 지정할 수도 있다. `search` 속성을 사용하면 빈을 탐색할 `ApplicationContext` 계층구조를 제한할 수 있다.

아래 예시처럼 `@Bean` 메소드에 배치하게 되면, 기본적으로 메소드 리턴 타입을 타겟 타입으로 사용한다:

```java
@Configuration(proxyBeanMethods = false)
public class MyAutoConfiguration {

    @Bean
    @ConditionalOnMissingBean
    public SomeService someService() {
        return new SomeService();
    }

}
```

위 예시에선 `MyService` 타입 빈이 `ApplicationContext`에 없으면 `myService` 빈을 생성한다.

> 이런 조건들은 지금까지 처리한 내용을 기반으로 평가하기 때문에, 빈 정의를 추가하는 순서에 특히 주의해야 한다. 그렇기 때문에 자동 설정 클래스에서는 `@ConditionalOnBean`과 `@ConditionalOnMissingBean` 어노테이션만 사용하기를 권장한다 (사용자 정의 빈을 추가한 다음에 로드하는 것을 보장할 수 있기 때문).

> `@ConditionalOnBean`과 `@ConditionalOnMissingBean`을 선언한다고 해서 무조건 `@Configuration` 클래스 생성까지 막는 건 아니다. 이런 조건을 클래스 레벨에 사용하는 것과, 클래스에 있는 각 `@Bean` 메소드에 어노테이션을 마킹하는 것의 유일한 차이점은 전자에선 조건에 맞지 않으면 `@Configuration` 클래스를 빈으로 등록하지 않는다는 거다.

> `@Bean` 메소드를 선언할 때는 메소드 리턴 타입에 가능한 한 타입정보를 최대한 많이 제공해라. 예를 들어 빈의 실제 클래스가 인터페이스를 구현하고 있다면, 빈 메소드의 리턴 타입은 인터페이스가 아닌 실제 클래스로 지정해야 한다. bean condition을 사용할 땐 특히 더 중요해지는데, 빈의 유무는 메소드 시그니처에서 확인할 수 있는 타입 정보에만 의존해서 평가하기 때문이다.

#### Property Conditions

`@ConditionalOnProperty` 어노테이션을 사용하면 스프링 Environment 프로퍼티를 기반으로 설정을 포함시킬 수 있다. `prefix`, `name` 속성을 사용해서 확인할 프로퍼티를 지정한다. 기본적으로는 프로퍼티가 존재하고 `false`가 아닐 때 매칭된다. `haveValue`와 `matchIfMissing` 속성을 사용하면 좀 더 복잡한 검사 조건을 만들 수 있다.

#### Resource Conditions

`@ConditionalOnResource` 어노테이션을 사용하면 특정 리소스가 있을 때만 설정을 포함시킬 수 있다. 리소스는 `file:/home/user/test.dat`과 같이 평소 사용하는 스프링 컨벤션에 따라 지정하면 된다.

#### Web Application Conditions

`@ConditionalOnWebApplication`과 `@ConditionalOnNotWebApplication` 어노테이션을 사용하면 애플리케이션이 "웹 애플리케이션"인지에 따라 설정을 포함시킬 수 있다. 서블릿 기반 웹 애플리케이션은 스프링의 `WebApplicationContext`를 사용하거나, `session` 스코프를 정의하거나, `ConfigurableWebEnvironment`가 있는 애플리케이션을 뜻한다. 리액티브 웹 애플리케이션은 `ReactiveWebApplicationContext`를 사용하거나 `ConfigurableReactiveWebEnvironment`가 있는 애플리케이션을 의미한다.

`@ConditionalOnWarDeployment` 어노테이션을 사용하면 애플리케이션이 컨테이너에 배포하는 전통적인 WAR 애플리케이션인지 여부에 따라 설정을 포함시킬 수 있다. 이 조건은 임베디드 서버에서 실행하는 어플리케이션에선 매칭되지 않는다.

#### SpEL Expression Conditions

`@ConditionalOnExpression` 어노테이션을 사용하면 [SpEL 표현식](https://docs.spring.io/spring-framework/docs/5.3.8/reference/html/core.html#expressions)의 결과에 따라 설정을 포함시킬 수 있다.

### 7.29.4. Testing your Auto-configuration

자동 설정은 여러 가지 요소로 달라질 수 있다. 사용자 설정(`@Bean` 정의와 `Environment` 커스텀), 조건 평가(특정 라이브러리가 있는지) 등 많은 요인이 있다. 구체적으로 말하면, 각 테스트마다 이런 커스텀 조합을 잘 반영한 `ApplicationContext`를 생성해야 한다. 이런 일은 `ApplicationContextRunner`를 활용하면 잘 해낼 수 있다.

보통 `ApplicationContextRunner`는 클래스의 필드로 정의해서 기초가 될 공통 설정들을 수집한다. 다음 예시에선 `MyServiceAutoConfiguration`을 항상 호출하도록 만들고 있다:

```java
private final ApplicationContextRunner contextRunner = new ApplicationContextRunner()
        .withConfiguration(AutoConfigurations.of(MyServiceAutoConfiguration.class));
```

> 자동 설정을 여러 개 정의해야 할때는, 애플리케이션을 실행할 때와 정확히 같은 순서로 호출하기 때문에 굳이 선언부를 정렬할 필요는 없다.

각 테스트에선 runner를 사용해 원하는 유스 케이스를 표현하면 된다. 예를 들어 아래 샘플에선 사용자 설정(`UserConfiguration`)을 실행한 다음 의도대로 자동 설정이 적용되지 않는지를 확인하고 있다. `run`을 호출하면 넘겨주는 콜백 컨텍스트를 이용해 `AssertJ`를 호출할 수 있다.

```java
@Test
void defaultServiceBacksOff() {
    this.contextRunner.withUserConfiguration(UserConfiguration.class).run((context) -> {
        assertThat(context).hasSingleBean(MyService.class);
        assertThat(context).getBean("myCustomService").isSameAs(context.getBean(MyService.class));
    });
}

@Configuration(proxyBeanMethods = false)
static class UserConfiguration {

    @Bean
    MyService myCustomService() {
        return new MyService("mine");
    }

}
```

아래 보이는 것처럼 `Environment`도 쉽게 커스텀할 수 있다:

```java
@Test
void serviceNameCanBeConfigured() {
    this.contextRunner.withPropertyValues("user.name=test123").run((context) -> {
        assertThat(context).hasSingleBean(MyService.class);
        assertThat(context.getBean(MyService.class).getName()).isEqualTo("test123");
    });
}
```

runner를 사용해서 `ConditionEvaluationReport`를 확인할 수도 있다. 이 리포트는 `INFO`나 `DEBUG` 레벨로 출력할 수 있다. 다음 예제는 자동 설정 테스트에서 `ConditionEvaluationReportLoggingListener`를 사용해 리포트를 출력하는 방법을 보여준다.

```java
class MyConditionEvaluationReportingTests {

    @Test
    void autoConfigTest() {
        new ApplicationContextRunner()
            .withInitializer(new ConditionEvaluationReportLoggingListener(LogLevel.INFO))
            .run((context) -> {
                    // Test something...
            });
    }

}
```

#### Simulating a Web Context

서블릿이나 리액티브 웹 애플리케이션 컨텍스트에서만 작동하는 자동 설정을 테스트해야 한다면 각각 `WebApplicationContextRunner`와 `ReactiveWebApplicationContextRunner`를 사용해라.

#### Overriding the Classpath

런타임에 특정 클래스나 패키지가 없을 때 어떤 일이 발생하는지도 테스트가 가능하다. 스프링 부트는 간단하게 runner와 같이 쓸 수 있는 `FilteredClassLoader`를 제공한다. 다음 예제에선 `MyService`가 없을 때 자동 설정이 적절히 비활성화되는지 검증하고 있다:

```java
@Test
void serviceIsIgnoredIfLibraryIsNotPresent() {
    this.contextRunner.withClassLoader(new FilteredClassLoader(MyService.class))
            .run((context) -> assertThat(context).doesNotHaveBean("myService"));
}
```

### 7.29.5. Creating Your Own Starter

전형적인 스프링 부트 스타터에는 주어진 기술에서 필요한 인프라를 자동 설정하고 커스텀하는 코드가 들어 있다. 이를 "acme"라고 칭하겠다. 쉽게 확장이 가능하게 만들고 싶으면 전용 네임스페이스 안에 여러 가지 설정 키들을 정의해 environment에 노출해주면 된다. 마지막으로 사용자측에선 시작해보기가 최대한 쉽도록 "스타터" 의존성을 하나 제공한다.

좀 더 구체적으로 말하면, 커스텀 스타터에는 아래와 같은 것들을 넣을 수 있다:

- "acme"을 위한 자동 설정 코드를 가지고 있는 `autoconfigure` 모듈.
- 이 `autoconfigure` 모듈 의존성과, "acme", 그리고 일반적으로 많이 사용하는 별도 의존성들을 제공하는 `starter` 모듈. 쉽게 말해, 스타터를 추가하면 그 라이브러리를 사용하는 데 필요한 모든 것이 제공돼야 한다.

이 두 모듈을 꼭 구분할 필요는 전혀 없다. "acme"에 여러 가지 취향, 옵션, 비필수 기능들이 반영돼 있는 경우엔, 일부 기능은 옵션이라는 점을 명확히 표현할 수 있도록 자동 설정을 분리하는 게 좋다. 게다가 분리하게되면 이런 비필수 의존성에 자신의 생각을 반영한 스타터를 만들 수 있다. 동시에 다른 사람들은 `autoconfigure` 모듈만 의존하고, 다른 의견을 담아 자신만의 스타터를 만들 수도 있다.

자동 설정이 비교적 간단하고 생략 가능한 기능은 없다면 두 모듈을 스타터로 합치는 게 확실한 선택이다.

#### Naming

스타터를 만들려면 적절한 네임스페이스를 정해야 한다. 메이븐 `groupId`가 다르더라도 `spring-boot`로 시작하는 이름은 모듈 이름에 사용하지 말아라. 지금 자동 설정하고 있는 부분을 향후 스프링이 공식으로 지원할 수도 있다.

경험상 결합한 하나의 모듈을 만든다면 스타터 이름을 따오는 게 좋다. 예를 들어 "acme"을 위한 스타터를 만들고 있으며, 자동 설정 모듈의 이름을 `acme-spring-boot`로, 스타터의 이름은 `acme-spring-boot-starter`로 정한다고 해보자. 이 둘을 결합한 하나의 모듈만 만드는 경우, 이름은 `acme-spring-boot-starter`로 정해라.

#### Configuration keys

스타터에서 설정 키를 제공하려는 경우 고유한 네임스페이스를 사용해라. 특히, 스프링 부트가 사용하는 네임스페이스(`server`, `management`, `spring` 등)에는 키를 추가하지 마라. 같은 네임스페이스를 사용하면 향후에 모듈을 손상시키는 방향으로 네임스페이스를 수정해야 할 수 있다. 경험상 모든 키 앞에는 직접 소유하고 있는 네임스페이스를 붙이는 게 좋다 (ex. `acme`).

다음 예제와 같이 각 프로퍼티에는 javadoc 필드를 추가해서 설정 키를 문서화하도록 해라:

```java
@ConfigurationProperties("acme")
public class AcmeProperties {

    /**
     * Whether to check the location of acme resources.
     */
    private boolean checkLocation = true;

    /**
     * Timeout for establishing a connection to the acme server.
     */
    private Duration loginTimeout = Duration.ofSeconds(3);

    // getters/setters ...

}
```

> `@ConfigurationProperties` 필드 Javadoc은 JSON에 넣기 전에 따로 다른 처리는 하지 않기 때문에, 일반 텍스트만 사용해야 한다.

다음은 일관성 있는 description을 만들기 위해 내부적으로 준수하는 몇 가지 규칙들이다:

- description을 "The"나 "A"로 시작하지 않는다
- `boolean` 타입에선 "Whether" 나 "Enable"로 description을 시작한다
- 컬렉션 기반 타입에선 "Comma-separated list"로 description을 시작한다
- `long`보다는 `java.time.Duration`을 사용하고, 기본 단위가 밀리세컨드가 아니라면 설명을 추가한다. ex. "If a duration suffix is not specified, seconds will be used".
- 런타임에 결정해야 하는 게 아니라면 description에선 기본값을 설명하지 않는다

직접 만드는 키에서도 IDE 지원을 활용할 수 있도록 하려면 [메타데이터 생성을 트리거](https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#configuration-metadata.annotation-processor)해야 한다. 키가 제대로 문서화됐는지 알아보기 위해 만들어지는 메타데이터 파일(`META-INF/spring-configuration-metadata.json`)을 확인해보고 싶을 수도 있다. 자체 스타터를 호환되는 IDE에서 사용해보는 것도 메타데이터 품질을 검증하기 좋은 아이디어다.

#### The “autoconfigure” Module

`autoconfigure` 모듈에는 라이브러리를 시작하는 데 필요한 모든 것이 들어 있다. 추가로, 설정 키를 정의(ex. `@ConfigurationProperties`)하고 있을 수도 있고, 컴포넌트를 초기화하는 방식을 조금더 커스텀할 때 활용할 수 있는 콜백 인터페이스류도 가지고 있을 수 있다.

> 이 라이브러리 의존성을 선언할 땐 optional로 마킹해야 프로젝트에 `autoconfigure` 모듈을 추가하기가 쉬워진다. 이렇게 하면 스프링 부트는 기본적으로 라이브러리를 제공하지 않았을 땐 적용을 취소한다.

스프링 부트는 annotation processor를 사용해 메타데이터 파일(`META-INF/spring-autoconfigure-metadata.properties`)에서 자동 설정 대한 조건들을 수집한다. 이 파일이 있으면 매칭되지 않는 자동 설정들을 미리 필터링해서 기동 시간이 줄어들게 된다. 자동 설정을 가지고 있는 모듈에는 아래 의존성을 추가해주는 게 좋다:

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-autoconfigure-processor</artifactId>
    <optional>true</optional>
</dependency>
```

자동 설정을 애플리케이션 안에 직접 정의했다면, `repackage` goal에서 이 의존성을 fat jar에 추가하지 않도록 `spring-boot-maven-plugin`을 설정해줘야 한다:

```xml
<project>
    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <configuration>
                    <excludes>
                        <exclude>
                            <groupId>org.springframework.boot</groupId>
                            <artifactId>spring-boot-autoconfigure-processor</artifactId>
                        </exclude>
                    </excludes>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
```

그래들 4.5 이하에선 아래 예제처럼 `compileOnly` 설정으로 의존성을 선언해야 한다:

```gradle
dependencies {
    compileOnly "org.springframework.boot:spring-boot-autoconfigure-processor"
}
```

그래들 4.6 이상에선 아래 예제처럼 `annotationProcessor` 설정으로 의존성을 선언해야 한다:

```gradle
dependencies {
    annotationProcessor "org.springframework.boot:spring-boot-autoconfigure-processor"
}
```

#### Starter Module

스타터는 실제로는 비어있는 jar다. 스타터가 가진 유일한 목적은 라이브러리를 사용할 때 필요한 의존성을 제공하는 거다. 스타터는 시작하는 데 필요한 게 무엇인지를 관점에 따라 모아놓은 것이라고 생각해도 된다.

만들고 있는 스타터를 어떤 프로젝트에서 추가해갈지는 함부로 가정하지 마라. 자동 설정을 적용 중인 라이브러리에 일반적으로 다른 스타터가 필요하다면 그 라이브러리도 함께 언급해라. 라이브러리를 일반적으로 사용할 땐 불필요한 의존성은 포함하지 않는게 맞기 때문에, optional 의존성이 많아지면 적당한 *디폴트* 의존성 셋을 제공하기가 어려울 수도 있다. 다시 말해, optional 의존성들은 추가하지 않는게 좋다.

> 어느 쪽이든, 스타터는 무조건 코어 스프링 부트 스타터(`spring-boot-starter`)를 직접적으로든 간접적으로든 참조하게 된다 (다시 말해 만들고 있는 스타터가 다른 스타터에 의존하고 있다면 추가해줄 필요는 없다). 직접 만든 커스텀 스타터만 사용하는 프로젝트에선, 코어 스타터가 있기 때문에 스프링 부트의 핵심 기능을 그대로 사용할 수 있을 거다.

