---
title: Traditional Deployment
category: Spring Boot
order: 73
permalink: /Spring%20Boot/howto.traditional-deployment/
description: 전통적인 war 패포와 관련된 how to 가이드 (war 파일 만들기, 스프링 애플리케이션을 부트로 마이그레이션하기 등)
image: ./../../images/springboot/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 부트
originalRefLink: https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#howto.traditional-deployment
parent: “How-to” Guides
parentUrl: /Spring%20Boot/how-to-guides/
---

### 목차

- [12.17.1. Create a Deployable War File](#12171-create-a-deployable-war-file)
- [12.17.2. Convert an Existing Application to Spring Boot](#12172-convert-an-existing-application-to-spring-boot)
- [12.17.3. Deploying a WAR to WebLogic](#12173-deploying-a-war-to-weblogic)

---

## 12.17. Traditional Deployment

스프링 부트는 최근들어 사용하는 배포 방식뿐만이 아니라 전통적인 배포 방식도 지원하고 있다. 이번 섹션에선 전통적인 배포 방식과 관련해서 많이 묻는 질문들에 답해보겠다.

### 12.17.1. Create a Deployable War File

> 스프링 웹플럭스는 엄밀히 서블릿 API에 의존하지 않으며 애플리케이션은 디폴트로 임베디드 Reactor Netty 서버에 배포되기 때문에, 웹플럭스 애플리케이션에선 War 배포를 지원하지 않는다.

배포 가능한 war 파일을 생성하는 첫 번째 단계는 `SpringBootServletInitializer` 하위 클래스를 하나 만들고 `configure` 메소드를 재정의하는 거다. 이렇게 하면 스프링 프레임워크의 서블릿 3.0 지원을 통해 서블릿 컨테이너로 기동시킬 때 필요한 애플리케이션 설정들을 넣어줄 수 있다. 보통은 다음 예제와 같이 애플리케이션의 메인 클래스가 `SpringBootServletInitializer`를 상속하도록 변경해야 한다:

```java
@SpringBootApplication
public class MyApplication extends SpringBootServletInitializer {

    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
        return application.sources(MyApplication.class);
    }

    public static void main(String[] args) {
        SpringApplication.run(MyApplication.class, args);
    }

}
```

다음 단계는 프로젝트로 jar 파일이 아닌 war 파일을 생성하도록 빌드 설정을 수정해주는 거다. 메이븐과 `spring-boot-starter-parent`(메이븐의 war 플러그인 설정해주는)를 사용하고 있다면, 다음과 같이 `pom.xml`을 war로 패키징하도록 수정해주기만 하면 된다:

```xml
<packaging>war</packaging>
```

그래들에선 프로젝트에 war 플러그인을 적용하려면 다음과 같이 `build.gradle`을 수정해줘야 한다:

```gradle
apply plugin: 'war'
```

마지막으로 임베디드 서블릿 컨테이너가 war 파일을 배포하는 서블릿 컨테이너에 지장을 주지 않게 만들어줘야 한다. 그러려면 임베디드 서블릿 컨테이너 의존성을 provided로 마킹해야 한다.

다음은 메이븐을 사용해 서블릿 컨테이너(여기선 톰캣)를 provided로 마킹하는 예제다:

```xml
<dependencies>
    <!-- ... -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-tomcat</artifactId>
        <scope>provided</scope>
    </dependency>
    <!-- ... -->
</dependencies>
```

다음은 그래들을 사용해 서블릿 컨테이너(여기선 톰캣)를 provided로 마킹하는 예제다:

```gradle
dependencies {
    // ...
    providedRuntime 'org.springframework.boot:spring-boot-starter-tomcat'
    // ...
}
```

> 그래들의 `compileOnly` 설정보다는 `providedRuntime`을 더 많이 사용한다. 다른 제약 사항도 많지만, 그 중에서도 `compileOnly` 의존성은 테스트 클래스패스에 추가되지 않기 때문에, 웹 기반 통합 테스트는 전부 실패한다.

[스프링 부트 빌드 툴](../build-tool-plugins)을 사용하고 있을 때 임베디드 서블릿 컨테이너 의존성을 provided로 마킹하게 되면, provided 의존성들을 `lib-provided` 디렉토리에 패키징한 채로 가지고 있는 실행 가능한<sup>executable</sup> war 파일이 만들어진다. 덕분에 서블릿 컨테이너에 배포하는 것 뿐만 아니라, 커맨드라인에서도 `java -jar`를 사용해 애플리케이션을 실행할 수 있다.

### 12.17.2. Convert an Existing Application to Spring Boot

웹을 사용하지 않던 기존 스프링 애플리케이션을 스프링 부트 애플리케이션으로 전환하려면, `ApplicationContext`를 생성하는 코드를 교체하고 `SpringApplication`이나 `SpringApplicationBuilder`를 호출하도록 변경해라. 스프링 MVC 웹 애플리케이션에선 보통, 먼저 배포 가능한 war 애플리케이션을 만들면 이후에 실행 가능한<sup>executable</sup> war나 jar로 쉽게 마이그레이션할 수 있다. [jar를 war로 전환하기 기초 가이드](https://spring.io/guides/gs/convert-jar-to-war/)를 참고해라.

`SpringBootServletInitializer`를 상속하고 (예를 들어 `Application`이란 클래스로) 스프링 부트 `@SpringBootApplication` 어노테이션을 추가해 배포 가능한 war를 생성하려면, 아래와 유사한 코드를 사용하면 된다:

```java
@SpringBootApplication
public class MyApplication extends SpringBootServletInitializer {

    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
        // Customize the application or call application.sources(...) to add sources
        // Since our example is itself a @Configuration class (via @SpringBootApplication)
        // we actually don't need to override this method.
        return application;
    }


}
```

`sources` 메소드에 추가하는 건 그저 스프링 `ApplicationContext`라는 것을 기억해둬라. 보통은 이미 동작하고 있던 건 여기서도 잘 동작할 거다. 몇 가지 빈들은 나중엔 제거해서 스프링 부트가 가지고 있는 기본값을 사용할 수는 있겠지만, 그 전에도 동작하는 걸 볼 수 있을 거다.

스태틱 리소스는 클래스패스 루트의 `/public`(또는 `/static`,  `/resources`, `/META-INF/resources`)으로 이동할 수 있다. `messages.properties`도 동일하다 (스프링 부트가 클래스패스의 루트에서 자동으로 감지한다).

평범하게 스프링 `DispatcherServlet`과 스프링 시큐리티를 사용하고 있다면 더 변경하지 않아도 된다. 애플리케이션에 다른 기능도 있다면 (예를 들어 다른 서블릿이나 필터를 사용하고 있다면), 다음과 같이 `web.xml`에 있는 요소들을 대신해 `Application` 컨텍스트에 몇 가지 설정을 추가해야 할 수도 있다:

- `web.xml`의 `<servlet/>`과 `<servlet-mapping/>`에 정의했던 설정은 `Servlet`이나 `ServletRegistrationBean` 타입 `@Bean`으로 컨테이너에 추가한다.
- `Filter`나 `FilterRegistrationBean` 타입 `@Bean`도 유사하게 동작한다 (`<filter/>`와 `<filter-mapping/>`).
- XML 파일에 있는 `ApplicationContext`는 `Application`의 `@ImportResource`를 통해 추가할 수 있다. 아니면 어노테이션 설정을 이미 어느 정도 사용하고 있다면, `@Bean` 정의 몇 줄을 추가해 다시 만들어도 된다.

war 파일이 잘 동작한다면, 이제 다음 예제처럼 `Application`에 `main` 메소드를 추가하면 실행 가능하게 만들어줄 수 있다:

```java
public static void main(String[] args) {
    SpringApplication.run(MyApplication.class, args);
}
```

> 애플리케이션을 war로도 실행 가능한 애플리케이션으로도 기동할 작정이라면, 빌더로 커스텀한 코드는 메소드로 빼서 `SpringBootServletInitializer` 콜백과 다음과 유사한 클래스의 `main` 메소드에서 모두 사용할 수 있게 공유해줘야 한다:
>
> ```java
> @SpringBootApplication
> public class MyApplication extends SpringBootServletInitializer {
> 
>    @Override
>    protected SpringApplicationBuilder configure(SpringApplicationBuilder builder) {
>         return customizerBuilder(builder);
>    }
> 
>    public static void main(String[] args) {
>         customizerBuilder(new SpringApplicationBuilder()).run(args);
>    }
> 
>    private static SpringApplicationBuilder customizerBuilder(SpringApplicationBuilder builder) {
>         return builder.sources(MyApplication.class).bannerMode(Banner.Mode.OFF);
>    }
> 
> }
> ```

애플리케이션은 다음 중 둘 이상의 범주에 속할 수 있다:

- `web.xml`을 사용하지 않는 서블릿 3.0+ 애플리케이션.
- `web.xml`을 사용하는 애플리케이션.
- 컨텍스트 계층구조를 사용하는 애플리케이션.
- 컨텍스트 계층구조를 사용하지 않는 애플리케이션.

모든 케이스에서 전환이 가능하지만, 약간씩 필요한 기술들이 다를 수 있다.

서블릿 3.0+ 애플리케이션에선 이미 스프링 서블릿 3.0+ initializer 지원 클래스들을 사용하고 있다면 매우 쉽게 전환할 수 있다. 보통은 기존 `WebApplicationInitializer`의 코드를 전부 `SpringBootServletInitializer`로 옮겨주면 된다. 기존 애플리케이션이 `ApplicationContext`를 둘 이상 사용하고 있다면 (예를 들어 `AbstractDispatcherServletInitializer`를 사용하는 경우), 모든 컨텍스트 소스를 단일 `SpringApplication`으로 합칠 수 있을 거다. 이때 주로 겪는 문제는 복잡도 때문에 컨텍스트를 합쳤을 때 잘 동작하지 않아서 컨텍스트 계층을 유지해야 하는 경우다. 예제가 필요하다면 [계층구조 만들기](../howto.spring-boot-application#1214-build-an-applicationcontext-hierarchy-adding-a-parent-or-root-context)를 참고해라. 기존에 웹 전용 기능들을 포함하고 있는 부모 컨텍스트는 보통 모든 `ServletContextAware` 컴포넌트들을 자식 컨텍스트에 두도록 분할해야 한다.

아직 스프링 애플리케이션이 아니더라도 스프링 부트 애플리케이션으로 전환할 수 있으며, 앞서 언급한 가이드도 도움이 될 거다. 하지만 아직까진 문제가 발생하는 경우도 있다. 이럴 땐 [Stack Overflow에 `spring-boot` 태그를 붙여 질문을 올려](https://stackoverflow.com/questions/tagged/spring-boot)주길 바란다.

### 12.17.3. Deploying a WAR to WebLogic

스프링 부트 애플리케이션을 WebLogic으로 배포하려면 반드시 서블릿 이니셜라이저가 `WebApplicationInitializer`를 **직접** 구현하고 있어야 한다 (이미 이 이니셜라이져를 구현하고 있는 베이스 클래스를 상속했더라도).

전형적인 WebLogic을 위한 이니셜라이저는 다음 예제와 유사하게 만든다:

```java
@SpringBootApplication
public class MyApplication extends SpringBootServletInitializer implements WebApplicationInitializer {

}
```

Logback을 사용하고 있다면 WebLogic이 서버에 미리 설치돼 있는 버전이 아닌 패키징된 버전을 사용하도록 알려줘야 한다. 아래와 같은 내용을 담고 있는 `WEB-INF/weblogic.xml` 파일을 추가하면 된다:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<wls:weblogic-web-app
    xmlns:wls="http://xmlns.oracle.com/weblogic/weblogic-web-app"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://java.sun.com/xml/ns/javaee
        https://java.sun.com/xml/ns/javaee/ejb-jar_3_0.xsd
        http://xmlns.oracle.com/weblogic/weblogic-web-app
        https://xmlns.oracle.com/weblogic/weblogic-web-app/1.4/weblogic-web-app.xsd">
    <wls:container-descriptor>
        <wls:prefer-application-packages>
            <wls:package-name>org.slf4j</wls:package-name>
        </wls:prefer-application-packages>
    </wls:container-descriptor>
</wls:weblogic-web-app>
```
