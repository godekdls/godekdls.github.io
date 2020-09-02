---
title: Java Configuration
category: Spring Security
order: 17
permalink: /Spring%20Security/javaconfiguration/
description: 자바 코드로 스프링 시큐리티를 설정하는 방법을 설명합니다. 공식 문서에 있는 "Java Configuration" 챕터를 한글로 번역한 문서입니다.
image: ./../../images/springsecurity/spring-security.png
lastmod: 2020-09-01T21:30:00+09:00
comments: true
completed: false
originalRefName: 스프링 시큐리티
originalRefLink: https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#jc
---

### 목차:

- [16.1. Hello Web Security Java Configuration](#161-hello-web-security-java-configuration)
  + [16.1.1. AbstractSecurityWebApplicationInitializer](#1611-abstractsecuritywebapplicationinitializer)
  + [16.1.2. AbstractSecurityWebApplicationInitializer without Existing Spring](#1612-abstractsecuritywebapplicationinitializer-without-existing-spring)
  + [16.1.3. AbstractSecurityWebApplicationInitializer with Spring MVC](#1613-abstractsecuritywebapplicationinitializer-with-spring-mvc)
- [16.2. HttpSecurity](#162-httpsecurity)
- [16.3. Multiple HttpSecurity](#163-multiple-httpsecurity)
- [16.4. Custom DSLs](#164-custom-dsls)
- [16.5. Post Processing Configured Objects](#165-post-processing-configured-objects)

---

스프링 프레임워크의 전반적인 [자바 설정](https://docs.spring.io/spring/docs/3.1.x/spring-framework-reference/html/beans.html#beans-java) 지원은 스프링 3.1에서 추가됐다. 스프링 시큐리티는 3.2 버전부터 자바 설정을 지원하므로 XML 없이도 손쉽게 스프링 시큐리티 설정을 만들할 수 있다.

[시큐리티 네임스페이스 설정](https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#ns-config)에 익숙하다면, 자바 설정도 네임스페이스 설정과 꽤 유사하다는 걸 알 수 있을 거다.

> 스프링 시큐리티는 자바 설정을 사용하는 [많은 샘플 어플리케이션](https://github.com/spring-projects/spring-security/tree/master/samples/javaconfig)을 제공한다.

---

## 16.1. Hello Web Security Java Configuration

먼저 스프링 시큐리티 자바 설정을 만드는 것부터 시작한다. 이 설정은 `springSecurityFilterChain`으로 알려진, 어플리케이션 내 모든 보안 처리를 (어플리케이션 URL 보호, 제출한 사용자 이름과 비밀번호 검증, 로그인 폼으로 리다이렉트 등) 담당하는 서블릿 필터를 생성한다. 다음은 가장 기본적인 스프링 시큐리티 자바 설정 예시다:

<span id="jc-hello-wsca"></span>
```java
import org.springframework.beans.factory.annotation.Autowired;

import org.springframework.context.annotation.*;
import org.springframework.security.config.annotation.authentication.builders.*;
import org.springframework.security.config.annotation.web.configuration.*;

@EnableWebSecurity
public class WebSecurityConfig {

    @Bean
    public UserDetailsService userDetailsService() {
        InMemoryUserDetailsManager manager = new InMemoryUserDetailsManager();
        manager.createUser(User.withDefaultPasswordEncoder().username("user").password("password").roles("USER").build());
        return manager;
    }
}
```

이 설정은 간단하지만 많은 일을 해준다. 기능을 요약하면 다음과 같다:

- 어플리케이션의 모든 URL에 인증 요구
- 로그인 폼 생성
- **사용자 이름** *user*와 **비밀번호** *password*를 사용한 사용자의 폼 기반 인증 지원
- 사용자 로그아웃 지원
- [CSRF 공격](https://en.wikipedia.org/wiki/Cross-site_request_forgery) 방어
- [Session Fixation](https://en.wikipedia.org/wiki/Session_fixation) 방어
- 보안 헤더 통합
  - [HTTP Strict Transport Security](https://en.wikipedia.org/wiki/HTTP_Strict_Transport_Security)로 요청을 보호
  - [X-Content-Type-Options](https://msdn.microsoft.com/en-us/library/ie/gg622941(v=vs.85).aspx) 통합
  - Cache Control (어플리케이션에서 특정 스태틱 리소스에 캐시를 허용하도록 재정의할 수 있다)
  - [X-XSS-Protection](https://msdn.microsoft.com/en-us/library/dd565647(v=vs.85).aspx) 통합
  - X-Frame-Options 통합으로 [클릭재킹](https://en.wikipedia.org/wiki/Clickjacking) 방어 지원
- 서블릿 API 메소드 통합
  - [HttpServletRequest#getRemoteUser()](https://docs.oracle.com/javaee/6/api/javax/servlet/http/HttpServletRequest.html#getRemoteUser())
  - [HttpServletRequest#getUserPrincipal()](https://docs.oracle.com/javaee/6/api/javax/servlet/http/HttpServletRequest.html#getUserPrincipal())
  - [HttpServletRequest#isUserInRole(java.lang.String)](https://docs.oracle.com/javaee/6/api/javax/servlet/http/HttpServletRequest.html#isUserInRole(java.lang.String))
  - [HttpServletRequest#login(java.lang.String, java.lang.String)](https://docs.oracle.com/javaee/6/api/javax/servlet/http/HttpServletRequest.html#login(java.lang.String, java.lang.String))
  - [HttpServletRequest#logout()](https://docs.oracle.com/javaee/6/api/javax/servlet/http/HttpServletRequest.html#logout())

### 16.1.1. AbstractSecurityWebApplicationInitializer

다음 단계는 war에 `springSecurityFilterChain`을 등록하는 것이다. 자바 설정에선 서블릿 3.0+ 환경에서 지원하는 [스프링의 WebApplicationInitializer](https://docs.spring.io/spring/docs/3.2.x/spring-framework-reference/html/mvc.html#mvc-container-config)를 사용할 수 있다. 놀랄것도 없이 당연히 스프링 시큐리티는 `springSecurityFilterChain`을 등록해주는 베이스 클래스 `AbstractSecurityWebApplicationInitializer`를 제공한다. `AbstractSecurityWebApplicationInitializer`를 사용하는 방법은 이미 스프링을 사용하고 있는지 또는 스프링 시큐리티가 어플리케이션의 유일한 스프링 컴포넌트인지에 따라 다르다.

- [기존 스프링 없이 AbstractSecurityWebApplicationInitializer 사용하기](#1612-abstractsecuritywebapplicationinitializer-without-existing-spring) - 스프링을 사용하고 있지 않다면 이 가이드를 따라라.
- [스프링 MVC에서 AbstractSecurityWebApplicationInitializer 사용하기](#1613-abstractsecuritywebapplicationinitializer-with-spring-mvc) - 이미 스프링을 사용하고 있다면 이 가이드를 따라라.

### 16.1.2. AbstractSecurityWebApplicationInitializer without Existing Spring

스프링이나 스프링 MVC를 사용하고 있지 않다면, `WebSecurityConfig`를 사용할 수 있도록 이 클래스를 상위 클래스로 넘겨야 한다. 예시는 아래에 있다:

```java
import org.springframework.security.web.context.*;

public class SecurityWebApplicationInitializer
    extends AbstractSecurityWebApplicationInitializer {

    public SecurityWebApplicationInitializer() {
        super(WebSecurityConfig.class);
    }
}
```

`SecurityWebApplicationInitializer`는 다음과 같은 일을 한다:

- 어플리케이션의 모든 URL에 자동으로 springSecurityFilterChain 필터를 등록한다
- [WebSecurityConfig](#jc-hello-wsca)를 로드하는 ContextLoaderListener를 추가한다.

### 16.1.3. AbstractSecurityWebApplicationInitializer with Spring MVC

어플리케이션의 다른 곳에서 스프링을 사용하고 있다면 아마 스프링 설정을 로딩하는 `WebApplicationInitializer`가 이미 있을 거다. 이전 설정을 그대로 사용하면 오류가 생긴다. 대신에 기존 `ApplicationContext`에 스프링 시큐리티를 등록해야 한다. 예를 들어 스프링 MVC를 사용하고 있다면 `SecurityWebApplicationInitializer`는 다음과 같을 것이다:

```java
import org.springframework.security.web.context.*;

public class SecurityWebApplicationInitializer
    extends AbstractSecurityWebApplicationInitializer {

}
```

이 코드는 단순히 모든 어플리케이션 URL에 springSecurityFilterChain 필터를 등록한다. 이렇게 하면 기존 ApplicationInitializer에 `WebSecurityConfig`를 로드한다. 예를 들어 스프링 MVC를 사용하고 있다면 `getRootConfigClasses()` 안에 추가된다.

```java
public class MvcWebApplicationInitializer extends
        AbstractAnnotationConfigDispatcherServletInitializer {

    @Override
    protected Class<?>[] getRootConfigClasses() {
        return new Class[] { WebSecurityConfig.class };
    }

    // ... other overrides ...
}
```

---

## 16.2. HttpSecurity

지금까지 [WebSecurityConfig](#jc-hello-wsca)에는 사용자를 인증하는 방법에 대한 정보만 있었다. 스프링 시큐리티는 모든 사용자를 인증해야 한다는 걸 어떻게 알 수 있을까? 폼 기반 인증을 지원해야 한다는 것은 또 어떻게 알까? 사실은 뒷단에서 실행하는 `WebSecurityConfigurerAdapter`라는 설정 클래스가 있다. 이 클래스는 디폴트로 아래와 같이 구현돼 있는 `configure`라는 메소드가 있다:

```java
protected void configure(HttpSecurity http) throws Exception {
    http
        .authorizeRequests(authorize -> authorize
            .anyRequest().authenticated()
        )
        .formLogin(withDefaults())
        .httpBasic(withDefaults());
}
```

이 디폴트 설정은:

- 어플리케이션의 모든 요청은 인증한 사용자만 사용할 수 있음을 보장한다.
- 폼 기반 로그인 인증을 지원한다.
- HTTP 기본 인증을 지원한다.

이 설정은 XML 네임스페이스 설정과도 매우 유사하다는 것을 알 수 있다:

```xml
<http>
    <intercept-url pattern="/**" access="authenticated"/>
    <form-login />
    <http-basic />
</http>
```

---

## 16.3. Multiple HttpSecurity

`<http>` 블록을 여러 개 만들 수 있듯이, HttpSecurity 인스턴스도 여러 개 설정할 수 있다. 핵심은 `WebSecurityConfigurerAdapter`를 여러 번 상속하는 것이다. 예를 들어 다음 예제에선 `/api/`로 시작하는 URL은 다른 설정을 사용한다:

```java
@EnableWebSecurity
public class MultiHttpSecurityConfig {
    @Bean                                                           // (1)
    public UserDetailsService userDetailsService() throws Exception {
        // ensure the passwords are encoded properly
        UserBuilder users = User.withDefaultPasswordEncoder();
        InMemoryUserDetailsManager manager = new InMemoryUserDetailsManager();
        manager.createUser(users.username("user").password("password").roles("USER").build());
        manager.createUser(users.username("admin").password("password").roles("USER","ADMIN").build());
        return manager;
    }

    @Configuration
    @Order(1)                                                        // (2)
    public static class ApiWebSecurityConfigurationAdapter extends WebSecurityConfigurerAdapter {
        protected void configure(HttpSecurity http) throws Exception {
            http
                .antMatcher("/api/**")                               // (3)
                .authorizeRequests(authorize -> authorize
                    .anyRequest().hasRole("ADMIN")
                )
                .httpBasic(withDefaults());
        }
    }

    @Configuration                                                   // (4)
    public static class FormLoginWebSecurityConfigurerAdapter extends WebSecurityConfigurerAdapter {

        @Override
        protected void configure(HttpSecurity http) throws Exception {
            http
                .authorizeRequests(authorize -> authorize
                    .anyRequest().authenticated()
                )
                .formLogin(withDefaults());
        }
    }
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 평소처럼 인증을 설정한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> `WebSecurityConfigurerAdapter` 인스턴스를 생성하고, `@Order`를 명시해서 가장 우선시할 `WebSecurityConfigurerAdapter`로 설정한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> `http.antMatcher`는 이 `HttpSecurity`는 `/api/`로 시작하는 URL에만 적용한다고 말하고 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> 다른 `WebSecurityConfigurerAdapter` 인스턴스를 생성한다. `/api/`로 시작하지 않는 URL은 이 설정을 사용한다. 이 설정은 `1`보다 큰 `@Order` 값을 가지므로 `ApiWebSecurityConfigurationAdapter` 이후에 사용한다 (기본적으로 `@Order`를 생략하면 마지막이 된다).</small>

---

## 16.4. Custom DSLs

스프링 시큐리티에 직접 만든 커스텀 DSL을 제공할 수도 있다. 예를 들어 다음과 같은 코드가 있을 수 있다:

```java
public class MyCustomDsl extends AbstractHttpConfigurer<MyCustomDsl, HttpSecurity> {
    private boolean flag;

    @Override
    public void init(H http) throws Exception {
        // any method that adds another configurer
        // must be done in the init method
        http.csrf().disable();
    }

    @Override
    public void configure(H http) throws Exception {
        ApplicationContext context = http.getSharedObject(ApplicationContext.class);

        // here we lookup from the ApplicationContext. You can also just create a new instance.
        MyFilter myFilter = context.getBean(MyFilter.class);
        myFilter.setFlag(flag);
        http.addFilterBefore(myFilter, UsernamePasswordAuthenticationFilter.class);
    }

    public MyCustomDsl flag(boolean value) {
        this.flag = value;
        return this;
    }

    public static MyCustomDsl customDsl() {
        return new MyCustomDsl();
    }
}
```

> 실제로 `HttpSecurity.authorizeRequests()` 같은 메소드를 구현하는 방식과 동일하다.

이 커스텀 DSL은 다음과 같이 사용할 수 있다:

```java
@EnableWebSecurity
public class Config extends WebSecurityConfigurerAdapter {
    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http
            .apply(customDsl())
                .flag(true)
                .and()
            ...;
    }
}
```

코드 실행 순서는 다음과 같다:

- `Config`에 있는 configure 메소드를 실행한다.
- `MyCustomDsl`에 있는 init 메소드를 실행한다.
- `MyCustomDsl`에 있는 configure 메소드를 실행한다.

원한다면 `SpringFactories`를 사용해서, `WebSecurityConfiguerAdapter`가 기본적으로 `MyCustomDsl`을 추가하도록 만들 수 있다. 예를 들어 아래와 같은 내용을 담은 `META-INF/spring.factories` 리소스를 클래스패스에 만들 수 있다:

**META-INF/spring.factories**

```
org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer = sample.MyCustomDsl
```

디폴트 설정을 명시적으로 비활성화할 수도 있다.

```java
@EnableWebSecurity
public class Config extends WebSecurityConfigurerAdapter {
    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http
            .apply(customDsl()).disable()
            ...;
    }
}
```

---

## 16.5. Post Processing Configured Objects

스프링 시큐리티의 자바 설정은, 설정하는 모든 객체의 전체 프로퍼티를 노출하지는 않는다. 이로써 대다수에게는 설정을 단순화해준다. 어쨋든, 모든 프로퍼티를 노출했다면 사용자는 표준 빈 설정을 사용했을 것이다.

모든 프로퍼티를 직접 노출하지 않는 데에는 그만한 이유가 있지만, 좀 더 세세하게 설정을 변경하고 싶을 수도 있다. 이를 해결하기 위해 스프링 시큐리티는 자바 설정으로 만든 인스턴스를 수정하거나 대체할 수 있는 `ObjectPostProcessor` 개념을 도입했다. 예를 들어 `FilterSecurityInterceptor`의 `filterSecurityPublishAuthorizationSuccess` 프로퍼티를 설정하려는 경우 다음 코드를 사용할 수 있다:

```java
@Override
protected void configure(HttpSecurity http) throws Exception {
    http
        .authorizeRequests(authorize -> authorize
            .anyRequest().authenticated()
            .withObjectPostProcessor(new ObjectPostProcessor<FilterSecurityInterceptor>() {
                public <O extends FilterSecurityInterceptor> O postProcess(
                        O fsi) {
                    fsi.setPublishAuthorizationSuccess(true);
                    return fsi;
                }
            })
        );
}
```