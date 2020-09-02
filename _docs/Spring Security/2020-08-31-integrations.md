---
title: Integrations
category: Spring Security
order: 15
permalink: /Spring%20Security/integrations/
description: 스프링 시큐리티를 서블릿 API, spring data, spring mvc, websocket 등과 통합하는 방법을 설명합니다. 공식 문서에 있는 "integrations" 챕터를 한글로 번역한 문서입니다.
image: ./../../images/springsecurity/spring-security.png
lastmod: 2020-09-01T21:30:00+09:00
comments: true
completed: false
originalRefName: 스프링 시큐리티
originalRefLink: https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#integrations
---

### 목차:

- [15.1. Servlet API integration](#151-servlet-api-integration)
  + [15.1.1. Servlet 2.5+ Integration](#1511-servlet-25-integration)
    * [HttpServletRequest.getRemoteUser()](#httpservletrequestgetremoteuser)
    * [HttpServletRequest.getUserPrincipal()](#httpservletrequestgetuserprincipal)
    * [HttpServletRequest.isUserInRole(String)](#httpservletrequestisuserinrolestring)
  + [15.1.2. Servlet 3+ Integration](#1512-servlet-3-integration)
    * [HttpServletRequest.authenticate(HttpServletRequest,HttpServletResponse)](#httpservletrequestauthenticatehttpservletrequesthttpservletresponse)
    * [HttpServletRequest.login(String,String)](#httpservletrequestloginstringstring)
    * [HttpServletRequest.logout()](#httpservletrequestlogout)
    * [AsyncContext.start(Runnable)](#asynccontextstartrunnable)
    * [Async Servlet Support](#async-servlet-support)
  + [15.1.3. Servlet 3.1+ Integration](#1513-servlet-31-integration)
- [15.2. Spring Data Integration](#152-spring-data-integration)
  + [15.2.1. Spring Data & Spring Security Configuration](#1521-spring-data--spring-security-configuration)
  + [15.2.2. Security Expressions within @Query](#1522-security-expressions-within-query)
- [15.3. Concurrency Support](#153-concurrency-support)
  + [15.3.1. DelegatingSecurityContextRunnable](#1531-delegatingsecuritycontextrunnable)
  + [15.3.2. DelegatingSecurityContextExecutor](#1532-delegatingsecuritycontextexecutor)
  + [15.3.3. Spring Security Concurrency Classes](#1533-spring-security-concurrency-classes)
- [15.4. Jackson Support](#154-jackson-support)
- [15.5. Localization](#155-localization)
- [15.6. Spring MVC Integration](#156-spring-mvc-integration)
  + [15.6.1. @EnableWebMvcSecurity](#1561-enablewebmvcsecurity)
  + [15.6.2. MvcRequestMatcher](#1562-mvcrequestmatcher)
  + [15.6.3. @AuthenticationPrincipal](#1563-authenticationprincipal)
  + [15.6.4. Spring MVC Async Integration](#1564-spring-mvc-async-integration)
  + [15.6.5. Spring MVC and CSRF Integration](#1565-spring-mvc-and-csrf-integration)
    * [Automatic Token Inclusion](#automatic-token-inclusion)
    * [Resolving the CsrfToken](#resolving-the-csrftoken)
- [15.7. WebSocket Security](#157-websocket-security)
  + [15.7.1. WebSocket Configuration](#1571-websocket-configuration)
  + [15.7.2. WebSocket Authentication](#1572-websocket-authentication)
  + [15.7.3. WebSocket Authorization](#1573-websocket-authorization)
    * [WebSocket Authorization Notes](#websocket-authorization-notes)
    * [Outbound Messages](#outbound-messages)
  + [15.7.4. Enforcing Same Origin Policy](#1574-enforcing-same-origin-policy)
    * [Why Same Origin?](#why-same-origin)
    * [Spring WebSocket Allowed Origin](#spring-websocket-allowed-origin)
    * [Adding CSRF to Stomp Headers](#adding-csrf-to-stomp-headers)
    * [Disable CSRF within WebSockets](#disable-csrf-within-websockets)
  + [15.7.5. Working with SockJS](#1575-working-with-sockjs)
    * [SockJS & frame-options](#sockjs--frame-options)
    * [SockJS & Relaxing CSRF](#sockjs--relaxing-csrf)
- [15.8. CORS](#158-cors)
- [15.9. JSP Tag Libraries](#159-jsp-tag-libraries)
  + [15.9.1. Declaring the Taglib](#1591-declaring-the-taglib)
  + [15.9.2. The authorize Tag](#1592-the-authorize-tag)
    * [Disabling Tag Authorization for Testing](#disabling-tag-authorization-for-testing)
  + [15.9.3. The authentication Tag](#1593-the-authentication-tag)
  + [15.9.4. The accesscontrollist Tag](#1594-the-accesscontrollist-tag)
  + [15.9.5. The csrfInput Tag](#1595-the-csrfinput-tag)
  + [15.9.6. The csrfMetaTags Tag](#1596-the-csrfmetatags-tag)

---

## 15.1. Servlet API integration

이번 섹션에선 스프링 시큐리티를 서블릿 API와 통합하는 방법을 설명한다. [servletapi-xml](https://github.com/spring-projects/spring-security/tree/master/samples/xml/servletapi) 샘플 어플리케이션은 여기서 설명하는 메소드들을 사용하고 있다.

### 15.1.1. Servlet 2.5+ Integration

#### HttpServletRequest.getRemoteUser()

[HttpServletRequest.getRemoteUser()](https://docs.oracle.com/javaee/6/api/javax/servlet/http/HttpServletRequest.html#getRemoteUser())는 `SecurityContextHolder.getContext().getAuthentication().getName()` 결과를 리턴하며, 보통 현재 username을 나타낸다. 어플리케이션에 현재 username을 노출할 때 유용하다. 추가로 null인지 확인해서 사용자가 인증됐는지 또는 익명인지도 판별할 수 있다. 사용자의 인증 여부를 알면 특정 UI 요소를 노출할지 말지를 결정할 수 있다 (i.e. 로그아웃 링크는 인증한 사용자에게만 노출해야 한다).

#### HttpServletRequest.getUserPrincipal()

[HttpServletRequest.getUserPrincipal()](https://docs.oracle.com/javaee/6/api/javax/servlet/http/HttpServletRequest.html#getUserPrincipal())은 `SecurityContextHolder.getContext().getAuthentication()` 결과 `Authentication`을 리턴한다. 사용자 이름과 비밀번호 기반 인증을 사용했다면 보통 `UsernamePasswordAuthenticationToken` 인스턴스를 리턴한다. 이 메소드는 사용자의 다른 정보를 확인할 때 유용하다. 예를 들어 커스텀 `UserDetailsService`를 사용해서 사용자의 이름과 성을 가지고 있는 커스텀 `UserDetails`를 리턴할 수 있다. 이 정보는 아래 코드로 가져올 수 있다:

```java
Authentication auth = httpServletRequest.getUserPrincipal();
// assume integrated custom UserDetails called MyCustomUserDetails
// by default, typically instance of UserDetails
MyCustomUserDetails userDetails = (MyCustomUserDetails) auth.getPrincipal();
String firstName = userDetails.getFirstName();
String lastName = userDetails.getLastName();
```

> 어플리케이션 전체에서 너무 많은 로직을 실행하는 건 보통 좋은 관행이 아니다. 대신에 이런 코드를 한 곳에 몰아서 스프링 시큐리티와 서블릿 API의 결합도를 최소화해야 한다.

#### HttpServletRequest.isUserInRole(String)

[HttpServletRequest.isUserInRole(String)](https://docs.oracle.com/javaee/6/api/javax/servlet/http/HttpServletRequest.html#isUserInRole(java.lang.String))은 넘겨받은 role을 가진 `GrantedAuthority`가 `SecurityContextHolder.getContext().getAuthentication().getAuthorities()`에 있는지 알려준다. 일반적으로 "ROLE\_" 프리픽스는 자동으로 추가되기 때문에 이 메소드를 사용할 때는 프리픽스를 사용하지 않는다. 예를 들어 현재 사용자가 "ROLE_ADMIN" 권한이 있는지 알고싶다면 다음 코드를 사용한다:

```java
boolean isAdmin = httpServletRequest.isUserInRole("ADMIN");
```

이 메소드는 특정 UI 컴포넌트를 노출할지 결정할 때 유용하다. 예를 들어 어드민 링크는 현재 사용자가 어드민일 때만 노출해야 한다.

### 15.1.2. Servlet 3+ Integration

아래 섹션에선 스프링 시큐리티와 통합할 수 있는 서블릿 3 메소드를 설명한다.

#### HttpServletRequest.authenticate(HttpServletRequest,HttpServletResponse)

[HttpServletRequest.authenticate(HttpServletRequest,HttpServletResponse)](https://docs.oracle.com/javaee/6/api/javax/servlet/http/HttpServletRequest.html#authenticate(javax.servlet.http.HttpServletResponse)) 메소드는 현재 사용자가 인증한 사용자인지 확인할 때 사용한다. 인증하지 않았다면 설정에 있는 AuthenticationEntryPoint로 사용자에게 인증을 요청한다 (i.e. 로그인 페이지로 리다이렉트).

#### HttpServletRequest.login(String,String)

[HttpServletRequest.login(String,String)](https://docs.oracle.com/javaee/6/api/javax/servlet/http/HttpServletRequest.html#login(java.lang.String, java.lang.String)) 메소드는 사용자를 현재 `AuthenticationManager`로 인증할 때 사용한다. 예를 들어 다음 코드는 사용자 이름 "user", 비밀번호 "password"로 인증을 시도한다:

```java
try {
httpServletRequest.login("user","password");
} catch(ServletException e) {
// fail to authenticate
}
```

> 스프링 시큐리티에서 실패한 인증을 처리하고 싶다면 ServletException을 캐치할 필요 없다.

#### HttpServletRequest.logout()

[HttpServletRequest.logout()](https://docs.oracle.com/javaee/6/api/javax/servlet/http/HttpServletRequest.html#logout()) 메소드는 현재 사용자를 로그아웃할 때 사용한다.

보통 로그아웃은 SecurityContextHolder를 비우고, HttpSession을 무효화하고, 모든 "Remember Me" 인증 정보를 삭제한다는 것을 의미한다. 하지만 LogoutHandler 구현체는 스프링 시큐리티 설정에 따라 달라질 수 있다. 주의할 점은, HttpServletRequest.logout()을 실행한 다음에는 응답을 직접 만들어야 한다는 것이다. 보통은 웰컴 페이지로 리다이렉트한다.

#### AsyncContext.start(Runnable)

[AsyncContext.start(Runnable)](https://docs.oracle.com/javaee/6/api/javax/servlet/AsyncContext.html#start(java.lang.Runnable)) 메소드는 credential을 새 스레드로 전파해 준다. 스프링 시큐리티의 동시 처리 기능을 사용하면, 스프링 시큐리티는 AsyncContext.start(Runnable)을 재정의해서 현재 SecurityContext를 사용해서 Runnable을 처리한다. 예를 들어 다음 코드는 현재 사용자의 인증 정보를 출력한다:

```java
final AsyncContext async = httpServletRequest.startAsync();
async.start(new Runnable() {
    public void run() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        try {
            final HttpServletResponse asyncResponse = (HttpServletResponse) async.getResponse();
            asyncResponse.setStatus(HttpServletResponse.SC_OK);
            asyncResponse.getWriter().write(String.valueOf(authentication));
            async.complete();
        } catch(Exception e) {
            throw new RuntimeException(e);
        }
    }
});
```

#### Async Servlet Support

자바 설정을 사용 중이라면 이미 async 서블릿을 사용할 준비가 된 것이다. XML 설정을 사용한다면 몇 가지를 수정해야 한다. 먼저 web.xml에서 최소 3.0 스키마를 사용하고 있는지를 확인해야 한다:

```xml
<web-app xmlns="http://java.sun.com/xml/ns/javaee"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:schemaLocation="http://java.sun.com/xml/ns/javaee https://java.sun.com/xml/ns/javaee/web-app_3_0.xsd"
version="3.0">

</web-app>
```

그 다음 springSecurityFilterChain이 비동기 요청을 처리하도록 설정해야 한다.

```xml
<filter>
<filter-name>springSecurityFilterChain</filter-name>
<filter-class>
    org.springframework.web.filter.DelegatingFilterProxy
</filter-class>
<async-supported>true</async-supported>
</filter>
<filter-mapping>
<filter-name>springSecurityFilterChain</filter-name>
<url-pattern>/*</url-pattern>
<dispatcher>REQUEST</dispatcher>
<dispatcher>ASYNC</dispatcher>
</filter-mapping>
```

이게 전부다! 이제 스프링 시큐리티는 비동기 요청을 사용해도 SecurityContext를 전파해 준다.

어떻게 가능하냐고? 정말 알고 싶지 않다면 이번 섹션은 건너뛰어도 좋다. 관심 있는 사람만 보면 된다. 대부분은 서블릿 스펙에 내장돼 있지만, 스프링 시큐리티에서 비동기 요청을 처리하기 위해 약간은 수정했다. 스프링 시큐리티 3.2 이전에는 HttpServletResponse를 커밋하면 즉시 자동으로 SecurityContextHolder에 있는 SecurityContext를 저장했다. 이는 비동기 환경에선 문제가 될 수 있다. 예를 들어 다음 코드를 생각해 보자:

```java
httpServletRequest.startAsync();
new Thread("AsyncThread") {
    @Override
    public void run() {
        try {
            // Do work
            TimeUnit.SECONDS.sleep(1);

            // Write to and commit the httpServletResponse
            httpServletResponse.getOutputStream().flush();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}.start();
```

문제는 스프링 시큐리티는 이 스레드를 알지 못하기 때문에 SecurityContext를 전파하지 않는다는 것이다. 즉 HttpServletResponse를 커밋할 때는 SecurityContext가 없다. 스프링 시큐리티가 HttpServletResponse를 커밋할 때 자동으로 SecurityContext를 저장하면 로그인한 사용자를 잃게 된다.

3.2 버전부터 스프링 시큐리티는 더 이상 HttpServletRequest.startAsync() 호출 직후 HttpServletResponse를 커밋할 때 자동으로 SecurityContext를 저장하지 않는다.

### 15.1.3. Servlet 3.1+ Integration

아래 섹션에선 스프링 시큐리티와 통합할 수 있는 서블릿 3.1 메소드를 설명한다.

#### HttpServletRequest#changeSessionId()

[HttpServletRequest.changeSessionId()](https://docs.oracle.com/javaee/7/api/javax/servlet/http/HttpServletRequest.html#changeSessionId())는 서블릿 3.1 이상에서 [Session Fixation](../authentication#10113-session-fixation-attack-protection) 공격을 방어하는 디폴트 메소드다.

---

## 15.2. Spring Data Integration

스프링 시큐리티는 스프링 데이터와의 통합을 지원하므로 쿼리에서 현재 사용자를 참조할 수 있다. 유용하기도 하지만, 쿼리에 사용자가 꼭 필요할 때도 있다. 페이지 처리를 하는 경우가 그런데, 결과를 나중에 필터링하면 원하는 페이지를 한 번에 조회할 수 없기 때문이다.

### 15.2.1. Spring Data & Spring Security Configuration

이 기능을 사용하려면 `org.springframework.security:spring-security-data` 의존성을 추가하고 `SecurityEvaluationContextExtension` 타입 빈을 정의해야 한다. 자바 설정에선 다음과 같다:

```java
@Bean
public SecurityEvaluationContextExtension securityEvaluationContextExtension() {
    return new SecurityEvaluationContextExtension();
}
```

XML 설정은 다음과 같다:

```xml
<bean class="org.springframework.security.data.repository.query.SecurityEvaluationContextExtension"/>
```

### 15.2.2. Security Expressions within @Query

이제 쿼리에서 스프링 시큐리티를 사용할 수 있다. 예를 들어:

```java
@Repository
public interface MessageRepository extends PagingAndSortingRepository<Message,Long> {
    @Query("select m from Message m where m.to.id = ?#{ principal?.id }")
    Page<Message> findInbox(Pageable pageable);
}
```

이 코드는 `Authentication.getPrincipal().getId()`가 `Message` 수신자와 동일한지 체크한다. 이 예제는 principal을 id 프로퍼티를 가지고 있는 Object로 커스텀했다는 가정이 있다. `SecurityEvaluationContextExtension` 빈을 정의했기 때문에 쿼리에 모든 [공통 보안 표현식](../authorization#common-built-in-expressions)을 사용할 수 있다.

---

## 15.3. Concurrency Support

대부분의 환경에서 보안 정보는 스레드별로 저장한다. 이 말은 새 `Thread`를 실행하면 `SecurityContext`를 잃어버린다는 뜻이기도 하다. 스프링 시큐리티는 이를 쉽게 해결할 수 있는 몇 가지 기반을 제공한다. 멀티 스레드 환경에서 스프링 시큐리티를 사용할 수 있는 저수준 추상화를 제공한다. 이는 사실 [AsyncContext.start(Runnable)](#asynccontextstartrunnable)과 [Spring MVC Async Integration](#1564-spring-mvc-async-integration)과의 통합을 위해 구축한 것이다.

### 15.3.1. DelegatingSecurityContextRunnable

스프링 시큐리티의 동시 처리 기능에서 가장 기본적인 구성 요소 중 하나는 `DelegatingSecurityContextRunnable`이다. 이 클래스는 위임할 `Runnable`을 감싸 `SecurityContextHolder`에서 특정 `SecurityContext`를 초기화한다. 그 다음 Runnable을 실행하고 이후 `SecurityContextHolder`를 비운다.  `DelegatingSecurityContextRunnable`은 다음과 같다:

```java
public void run() {
    try {
        SecurityContextHolder.setContext(securityContext);
        delegate.run();
    } finally {
        SecurityContextHolder.clearContext();
    }
}
```

매우 간단하면서도 매끄럽게 SecurityContext를 다른 스레드로 전달해준다. 이 기능은 대부분이 스레드별로 SecurityContextHolder를 사용하기 때문에 중요하다. 예를 들어 스프링 시큐리티의 [\<global-method-security\>](https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#nsa-global-method-security)로 서비스를 보호하고 있을 수도 있다. 이제 현재 `Thread`의 `SecurityContext`를 보호 중인 서비스를 실행하는 `Thread`로 쉽게 전달할 수 있다. 다음 코드는 그 방법을 보여주고 있다:

```java
Runnable originalRunnable = new Runnable() {
    public void run() {
        // invoke secured service
    }
};

SecurityContext context = SecurityContextHolder.getContext();
DelegatingSecurityContextRunnable wrappedRunnable =
    new DelegatingSecurityContextRunnable(originalRunnable, context);

new Thread(wrappedRunnable).start();
```

위 코드는 다음 스텝을 수행한다:

- 보호 중인 서비스를 실행하는 `Runnable`을 생성한다. 이때는 스프링 시큐리티를 인식하지 못한다.
- `SecurityContextHolder`에서 사용하고 싶은 `SecurityContext`를 가져와서 `DelegatingSecurityContextRunnable`을 초기화한다.
- `DelegatingSecurityContextRunnable`로 스레드를 만든다.
- 새로 만든 스레드를 실행한다.

`SecurityContextHolder`에서 `SecurityContext`를 꺼내 `DelegatingSecurityContextRunnable`을 생성하는 경우는 꽤 흔하기 때문에, 이를 위한 전용 생성자가 있다. 다음 코드는 위에 있는 코드와 동일하다:

```java
Runnable originalRunnable = new Runnable() {
    public void run() {
        // invoke secured service
    }
};

DelegatingSecurityContextRunnable wrappedRunnable =
    new DelegatingSecurityContextRunnable(originalRunnable);

new Thread(wrappedRunnable).start();
```

이 코드는 사용하기는 쉽지만, 코드에 스프링 시큐리티를 사용 중이라는 점이 드러난다. 다음 섹션에선 `DelegatingSecurityContextExecutor`를 사용해서 스프링 시큐리티와 관련된 코드를 숨기는 방법을 알아볼 것이다.

### 15.3.2. DelegatingSecurityContextExecutor

이전 섹션을 통해 간단하게 `DelegatingSecurityContextRunnable`을 쓸 수 있다는 걸 알게 됐지만, 스프링 시큐리티를 알아야 사용할 수 있기 때문에 이상적이지는 않았다. `DelegatingSecurityContextExecutor`는 어떻게 스프링 시큐리티를 사용하고 있다는 사실을 숨기는지 알아보자.

`DelegatingSecurityContextExecutor`는 `Runnable` 대신 `Executor`에 위임한다는 점만 빼면 `DelegatingSecurityContextRunnable`과 매우 유사하다. 사용 방법은 아래 예제를 보면 된다:

```java
SecurityContext context = SecurityContextHolder.createEmptyContext();
Authentication authentication =
    new UsernamePasswordAuthenticationToken("user","doesnotmatter", AuthorityUtils.createAuthorityList("ROLE_USER"));
context.setAuthentication(authentication);

SimpleAsyncTaskExecutor delegateExecutor =
    new SimpleAsyncTaskExecutor();
DelegatingSecurityContextExecutor executor =
    new DelegatingSecurityContextExecutor(delegateExecutor, context);

Runnable originalRunnable = new Runnable() {
    public void run() {
        // invoke secured service
    }
};

executor.execute(originalRunnable);
```

위 코드는 다음 스텝을 수행한다:

- `DelegatingSecurityContextExecutor`에서 사용할 `SecurityContext`를 생성한다. 이 예제에서는 단순하게 직접 `SecurityContext`를 만든다는 점에 주의해라. 하지만 어디서 어떻게 `SecurityContext`를 가져오는지는 중요하지 않다 (i.e. 원한다면 `SecurityContextHolder`에서 가져올 수 있다).
- 제출한 `Runnable`들을 실행할 delegateExecutor를 생성한다.
- 마지막으로 execute 메소드로 받은 모든 Runnable을 `DelegatingSecurityContextRunnable`로 감싸주는 `DelegatingSecurityContextExecutor`를 생성한다. 이 클래스는 Runnable을 감싸서 delegateExecutor로 넘긴다. 이때 `DelegatingSecurityContextExecutor`에 제출한 모든 Runnable은 동일한 `SecurityContext`를 사용한다. 권한을 가진 사용자로 백그라운드 태스크를 실행할 때 활용할 수 있다.
- 지금은 "이게 어떻게 스프링 시큐리티를 드러내지 않는 코드란 거지?"라는 의문이 들 수 있다. 코드에서 직접 `SecurityContext`와 `DelegatingSecurityContextExecutor`를 만드는 대신, 미리 초기화한 `DelegatingSecurityContextExecutor` 인스턴스를 주입할 수 있다.

```java
@Autowired
private Executor executor; // becomes an instance of our DelegatingSecurityContextExecutor

public void submitRunnable() {
    Runnable originalRunnable = new Runnable() {
        public void run() {
        // invoke secured service
        }
    };
    executor.execute(originalRunnable);
}
```

이제 코드를 보면 `SecurityContext`가 `Thread`로 전파되며, `originalRunnable`을 실행한 뒤 `SecurityContextHolder`를 비운다는 점을 알 수 없다. 이 예제에선 각 스레드를 같은 사용자로 실행한다. `executor.execute(Runnable)`을 실행하는 시점에 `SecurityContextHolder`에 있는 사용자로 (i.e. 현재 로그인한 사용자) `originalRunnable`을 처리하고 싶었다면? `DelegatingSecurityContextExecutor` 생성자에서 `SecurityContext` 인자를 제거하면 된다. 예를 들어:

```java
SimpleAsyncTaskExecutor delegateExecutor = new SimpleAsyncTaskExecutor();
DelegatingSecurityContextExecutor executor =
    new DelegatingSecurityContextExecutor(delegateExecutor);
```

이제 `executor.execute(Runnable)`을 호출할 때마다 가장 먼저 `SecurityContextHolder`에서 `SecurityContext`를 가져오고, 이 `SecurityContext`로 `DelegatingSecurityContextRunnable`을 만든다. 따라서 `executor.execute(Runnable)` 코드를 호출할 때 사용한 동일한 사용자로 `Runnable`을 실행한다.

### 15.3.3. Spring Security Concurrency Classes

자바 concurrent API와 스프링 태스크 추상화를 추가로 통합하는 방법은 Javadoc을 참고해라. 이전 코드를 이해했다면 바로 이해할 수 있을 것이다.

- DelegatingSecurityContextCallable
- DelegatingSecurityContextExecutor
- DelegatingSecurityContextExecutorService
- DelegatingSecurityContextRunnable
- DelegatingSecurityContextScheduledExecutorService
- DelegatingSecurityContextSchedulingTaskExecutor
- DelegatingSecurityContextAsyncTaskExecutor
- DelegatingSecurityContextTaskExecutor
- DelegatingSecurityContextTaskScheduler

---

## 15.4. Jackson Support

스프링 시큐리티 관련 클래스를 영속화할 수 있도록 Jackson을 지원한다. 덕분에 분산 세션을 (i.e. 세션 복제, 스프링 세션 등) 사용할 때 스프링 시큐리티 관련 클래스의 직렬화 성능을 끌어올릴 수 있다.

Jackson을 사용하려면 `ObjectMapper`에 ([jackson-databind](https://github.com/FasterXML/jackson-databind)) `SecurityJackson2Modules.getModules(ClassLoader)`를 등록해라 :

```java
ObjectMapper mapper = new ObjectMapper();
ClassLoader loader = getClass().getClassLoader();
List<Module> modules = SecurityJackson2Modules.getModules(loader);
mapper.registerModules(modules);

// ... use ObjectMapper as normally ...
SecurityContext context = new SecurityContextImpl();
// ...
String json = mapper.writeValueAsString(context);
```

> Jackson을 지원하는 스프링 시큐리티 모듈은 다음과 같다:
> - spring-security-core (`CoreJackson2Module`)
> - spring-security-web (`WebJackson2Module`, `WebServletJackson2Module`, `WebServerJackson2Module`)
> - [spring-security-oauth2-client](../oauth2#122-oauth-20-client) (`OAuth2ClientJackson2Module`)
> - spring-security-cas (`CasJackson2Module`)

---

## 15.5. Localization

스프링 시큐리티는 예외 메세지를 최종 사용자가 보기 편한 언어로 현지화해준다. 모든 보안 메세지는 디폴트로 영어로 표기하기 때문에, 영어권 사람들을 위한 어플리케이션을 설계한다면 아무 것도 하지 않아도 된다. 이번 섹션은 다른 locale 사용을 위해 알아야할 모든 것을 망라한다.

인증 실패나 접근 거절(인가 실패)과 관련한 모든 예외 메세지는 현지화할 수 있다. 어플리케이션 개발자나 시스템 개발자를 위한 예외나 로깅용 메세지는 (잘못된 속성, 인터페이스 제약 조건 위반, 잘못된 생성자 사용, 시작 시간 유효성 검증, 디버그 레벨 로그 등) 현지화하지 않으며 대신에 스프링 시큐리티 코드에 영어로 하드코딩돼 있다.

`spring-security-core-xx.jar` 모듈을 보면 `org.springframework.security` 패키지에 `messages.properties` 파일과, 일부 대표 언어로 현지화한 파일이 순서대로 들어있다. 스프링 시큐리티엔 스프링의 `MessageSourceAware` 인터페이스를 구현한 클래스가 있고, 기동 시 어플리케이션 컨텍스트에 메세지 리졸버를 주입하므로, `ApplicationContext`에서 메세지를 참조할 수 있다. 메세지를 참조하려면 보통 어플리케이션 내에 메세지를 참조할 빈을 등록하기만 하면 된다. 예를 들어:

```xml
<bean id="messageSource"
    class="org.springframework.context.support.ReloadableResourceBundleMessageSource">
<property name="basename" value="classpath:org/springframework/security/messages"/>
</bean>
```

이 `messages.properties` 이름은 표준 리소스 번들에 따라 지정되며 스프링 시큐리티 메세지가 지원하는 디폴트 언어를 나타낸다. 디폴트 파일은 영어다.

`messages.properties`를 커스텀하거나 다른 언어를 지원하고 싶으면, 파일을 복사해서 적절하게 이름을 변경하고 위에 있는 빈 선언에 등록해라. 이 파일에는 메세지 키가 그렇게 많지 않으므로, 이 파일을 주요 이니셔티브로 여기면 안 된다. 파일을 locale 버전에 맞게 새로 만든다면, JIRA 태스크에 로깅하고 적절한 이름으로 `messages.properties` 파일을 만들어 우리 커뮤니티에 공유해주면 좋겠다.

스프링 시큐리티에서 실제로 적절한 메세지를 찾을 때는 스프링의 localization 기능을 사용한다. 따라서 요청에 있는 locale 정보를 스프링의 `org.springframework.context.i18n.LocaleContextHolder`에 저장해야 한다. 스프링 MVC의 `DispatcherServlet`이 이를 자동으로 저장해주긴 하지만, 스프링 시큐리티의 필터는 그전에 실행되므로 필터를 호출하기 전에 `LocaleContextHolder`에 정확한 `Locale`을 설정해야 한다. 필터에서 직접 설정하거나 (`web.xml`에서 스프링 시큐리티 필터보다 앞에 있는 필터로), 스프링의 `RequestContextFilter`를 사용할 수 있다. 스프링의 localization을 사용하는 자세한 방법은 스프링 프레임워크 문서를 참고하라.

"contacts" 샘플 어플리케이션은 현지화된 메세지를 사용하도록 설정돼 있다.

---

## 15.6. Spring MVC Integration

스프링 시큐리티는 스프링 MVC와 통합할 수 있는 여러 가지 옵션을 제공한다. 이번 섹션에선 스프링 MVC 통합을 자세히 설명한다.

### 15.6.1. @EnableWebMvcSecurity

> 스프링 시큐리티 4.0부터 `@EnableWebMvcSecurity`는 제거 대상에 올랐다 (deprecated). 대신 클래스패스를 기반으로 스프링 MVC 기능을 추가하는 `@EnableWebSecurity`를 사용해라.

스프링 시큐리티와 스프링 MVC를 통합하려면 설정에 `@EnableWebSecurity` 애노테이션을 추가해라.

> 스프링 시큐리티는 스프링 MVC의 [WebMvcConfigurer](https://docs.spring.io/spring/docs/5.0.0.RELEASE/spring-framework-reference/web.html#mvc-config-customize)를 사용하는 설정을 제공한다. 따라서 `WebMvcConfigurationSupport`를 직접 통합하는 등 좀 더 세세한 옵션을 변경하고 싶다면, 스프링 시큐리티 설정을 직접 제공해야 한다.

### 15.6.2. MvcRequestMatcher

스프링 MVC에서 `MvcRequestMatcher`로 URL을 비교하던 방식을, 스프링 시큐리티에서도 그대로 사용할 수 있다. 요청을 처리하기 전에 보안 규칙과 매칭되는지 확인하는 식으로 활용할 수 있다.

`MvcRequestMatcher`를 사용하려면 스프링 시큐리티 설정이 있는 `ApplicationContext`와  `DispatcherServlet`이 있는 `ApplicationContext`가 동일해야 한다. 스프링 시큐리티의 `MvcRequestMatcher`는 스프링 MVC 설정에 있는 `mvcHandlerMappingIntrospector`란 이름의 `HandlerMappingIntrospector`빈을 사용하기 때문이다.

`web.xml`에선 설정을 `DispatcherServlet.xml`에 추가해야 한다는 말이기도 하다.

```xml
<listener>
  <listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>
</listener>

<!-- All Spring Configuration (both MVC and Security) are in /WEB-INF/spring/ -->
<context-param>
  <param-name>contextConfigLocation</param-name>
  <param-value>/WEB-INF/spring/*.xml</param-value>
</context-param>

<servlet>
  <servlet-name>spring</servlet-name>
  <servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
  <!-- Load from the ContextLoaderListener -->
  <init-param>
    <param-name>contextConfigLocation</param-name>
    <param-value></param-value>
  </init-param>
</servlet>

<servlet-mapping>
  <servlet-name>spring</servlet-name>
  <url-pattern>/</url-pattern>
</servlet-mapping>
```

`DispatcherServlet`의 `ApplicationContext`엔 아래 `WebSecurityConfiguration`이 있다.

```java
public class SecurityInitializer extends
    AbstractAnnotationConfigDispatcherServletInitializer {

  @Override
  protected Class<?>[] getRootConfigClasses() {
    return null;
  }

  @Override
  protected Class<?>[] getServletConfigClasses() {
    return new Class[] { RootConfiguration.class,
        WebMvcConfiguration.class };
  }

  @Override
  protected String[] getServletMappings() {
    return new String[] { "/" };
  }
}
```

> 인가 조건은 항상 `HttpServletRequest` 매칭과 메소드 시큐리티를 함께 사용하길 권장한다.
>
> 일단 `HttpServletRequest` 매칭을 사용하면 앞 단에서 한 번 검사를 수행하기 때문에 [공격에 노출될 수 있는 지점(attack surface)](https://en.wikipedia.org/wiki/Attack_surface)을 최소화할 수 있다. 메소드 시큐리티는 누군가가 웹 인가 규칙을 통과하더라도 어플리케이션을 한 번 더 보호할 수 있다. 이는 [심층 방어(Defence in Depth)](https://en.wikipedia.org/wiki/Defense_in_depth_(computing))로 알려져 있다.

다음과 같이 매핑한 컨트롤러를 생각해 보자:

```java
@RequestMapping("/admin")
public String admin() {
```

이 컨트롤러 메소드를 어드민 사용자만 접근할 수 있도록 제한하려면, 다음과 같이 `HttpServletRequest`를 매칭하는 인가 조건을 만들 수 있다:

```java
protected configure(HttpSecurity http) throws Exception {
    http
        .authorizeRequests(authorize -> authorize
            .antMatchers("/admin").hasRole("ADMIN")
        );
}
```

XML을 사용한다면

```xml
<http>
    <intercept-url pattern="/admin" access="hasRole('ADMIN')"/>
</http>
```

두 설정 모두 어드민 사용자로 인증한 사용자만 `/admin` URL에 접근할 수 있도록 만든다. 하지만 스프링 MVC 설정에 따라 `/admin.html`도 `admin()` 메소드로 매핑될 수 있다. 심지어 스프링 MVC 설정에 따라 `/admin/`도 `admin()` 메소드로 매핑될 수 있다.

문제는 보안 규칙에선 `/admin`만 보호하고 있다는 것이다. 스프링 MVC에 따라 가능한 모든 URL에 규칙을 추가할 수도 있지만, 굉장히 장황하고 따분한 일이다.

대신에 스프링 시큐리티의 `MvcRequestMatcher`를 활용할 수 있다. 아래 설정은 스프링 MVC가 URL을 매칭하는 방식과 동일한 방식으로 URL을 비교하기 때문에, 스프링 MVC가 매핑하는 모든 URL을 보호한다: 

```java
protected configure(HttpSecurity http) throws Exception {
    http
        .authorizeRequests(authorize -> authorize
            .mvcMatchers("/admin").hasRole("ADMIN")
        );
}
```

XML을 사용한다면

```xml
<http request-matcher="mvc">
    <intercept-url pattern="/admin" access="hasRole('ADMIN')"/>
</http>
```

### 15.6.3. @AuthenticationPrincipal

스프링 시큐리티는 스프링 MVC 인자에 자동으로 현재 `Authentication.getPrincipal()`을 리졸브해주는 `AuthenticationPrincipalArgumentResolver`를 제공한다. `@EnableWebSecurity`를 사용하면 자동으로 스프링 MVC에 추가된다. XML 설정을 사용한다면 직접 추가해야 한다. 예를 들어:

```xml
<mvc:annotation-driven>
        <mvc:argument-resolvers>
                <bean class="org.springframework.security.web.method.annotation.AuthenticationPrincipalArgumentResolver" />
        </mvc:argument-resolvers>
</mvc:annotation-driven>
```

`AuthenticationPrincipalArgumentResolver`를 제대로 설정했다면 스프링 MVC 레이어에서 스프링 시큐리티를 완전히 분리할 수 있다.

커스텀 `UserDetailsService`가 `UserDetails`를 구현한 `Object`와, 커스텀 `CustomUser` `Object`를 리턴하는 경우를 생각해 보자. 현재 인증한 사용자의 `CustomUser`는 아래 코드로 접근할 수 있다:

```java
@RequestMapping("/messages/inbox")
public ModelAndView findMessagesForUser() {
    Authentication authentication =
    SecurityContextHolder.getContext().getAuthentication();
    CustomUser custom = (CustomUser) authentication == null ? null : authentication.getPrincipal();

    // .. find messages for this user and return them ...
}
```

스프링 시큐리티 3.2부터는 애노테이션을 사용해서 메소드 인자를 직접 리졸브할 수 있다. 예를 들어:

```java
import org.springframework.security.core.annotation.AuthenticationPrincipal;

// ...

@RequestMapping("/messages/inbox")
public ModelAndView findMessagesForUser(@AuthenticationPrincipal CustomUser customUser) {

    // .. find messages for this user and return them ...
}
```

principal을 다른 식으로 변환해야 할 때도 있다. 예를 들어 `CustomUser`가 final 클래스라면 상속할 수 없다. 이럴때는 `UserDetailsService`는 `UserDetails`를 구현한 `Object`를 리턴하고, `CustomUser`에 접근할 수 있는 `getCustomUser` 메소드를 따로 제공할 수 있다. 예를 들어 다음과 같다:

```java
public class CustomUserUserDetails extends User {
        // ...
        public CustomUser getCustomUser() {
                return customUser;
        }
}
```

이럴땐 `Authentication.getPrincipal()`을 루트 객체로 사용하는 [SpEL 표현식](https://docs.spring.io/spring/docs/current/spring-framework-reference/html/expressions.html)으로 `CustomUser`에 접근할 수 있다:

```java
import org.springframework.security.core.annotation.AuthenticationPrincipal;

// ...

@RequestMapping("/messages/inbox")
public ModelAndView findMessagesForUser(@AuthenticationPrincipal(expression = "customUser") CustomUser customUser) {

    // .. find messages for this user and return them ...
}
```

SpEL 표현식 안에서 빈을 참조할 수도 있다. 예를 들어 JPA로 사용자를 관리하고, 현재 사용자의 프로퍼티를 수정하고 저장한다면 아래 코드를 사용할 수 있다:

```java
import org.springframework.security.core.annotation.AuthenticationPrincipal;

// ...

@PutMapping("/users/self")
public ModelAndView updateName(@AuthenticationPrincipal(expression = "@jpaEntityManager.merge(#this)") CustomUser attachedCustomUser,
        @RequestParam String firstName) {

    // change the firstName on an attached instance which will be persisted to the database
    attachedCustomUser.setFirstName(firstName);

    // ...
}
```

자체 애노테이션에 `@AuthenticationPrincipal`을 메타 애노테이션으로 선언하면 스프링 시큐리티 의존성을 더 줄일 수 있다. 아래에서는 이 방법을 사용해 `@CurrentUser` 애노테이션을 만드는 방법을 설명한다.

> 스프링 시큐리티 의존성을 줄이기 위해 `@CurrentUser`를 별도로 만드는 게 소모적일 수도 있다. 꼭 필요한 작업은 아니지만, 스프링 시큐리티와 관련한 코드를 한 곳에 모아 분리하는 데는 도움이 된다.

```java
@Target({ElementType.PARAMETER, ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Documented
@AuthenticationPrincipal
public @interface CurrentUser {}
```

이제 `@CurrentUser`를 정의했으므로 현재 인증한 사용자를 `CustomUser`로 리졸브하라는 의미로 사용할 수 있다. 또한 스프링 시큐리티 의존성을 파일 하나로 몰은 효과도 있다.

```java
@RequestMapping("/messages/inbox")
public ModelAndView findMessagesForUser(@CurrentUser CustomUser customUser) {

    // .. find messages for this user and return them ...
}
```

### 15.6.4. Spring MVC Async Integration

스프링 웹 MVC 3.2+는 [비동기 요청 처리](https://docs.spring.io/spring/docs/3.2.x/spring-framework-reference/html/mvc.html#mvc-ann-async)를 지원한다. 별도 설정을 추가하지 않아도 스프링 시큐리티는 컨트롤러에서 리턴한 `Callable`을 실행할 `Thread`에 자동으로 `SecurityContext`를 설정한다. 예를 들어 아래 메소드에서 리턴한 `Callable`을 실행할 때는, `Callable`을 생성했을 때 있는 `SecurityContext`가 자동으로 세팅된다:

```java
@RequestMapping(method=RequestMethod.POST)
public Callable<String> processUpload(final MultipartFile file) {

return new Callable<String>() {
    public Object call() throws Exception {
    // ...
    return "someView";
    }
};
}
```

> **Associating SecurityContext to Callable’s**
>
> 좀 더 기술적인 설명을 덧붙이자면, 스프링 시큐리티는 `WebAsyncManager`와 통합된다. `Callable`을 처리할 때 사용하는 `SecurityContext`는 `startCallableProcessing`을 실행하는 시점에 `SecurityContextHolder`에 있는 `SecurityContext`다.

컨트롤러에서 리턴하는 `DeferredResult`는 자동으로 통합되지 않는다. `DeferredResult`는 사용자가 처리하기 때문에 자동으로 통합할 방법이 없기 때문이다. 하지만 스프링 시큐리티와 투명하게 통합되는 [동시 처리 기능](#153-concurrency-support)을 사용할 순 있다.

### 15.6.5. Spring MVC and CSRF Integration

#### Automatic Token Inclusion

폼에 [스프링 MVC 폼 태그](https://docs.spring.io/spring/docs/3.2.x/spring-framework-reference/html/view.html#view-jsp-formtaglib-formtag)를 사용하면 스프링 시큐리티가 자동으로 [CSRF 토큰을 넣어준다](../protectionagainstexploits#include-the-csrf-token). 예를 들어 아래 JSP는:

```xml
<jsp:root xmlns:jsp="http://java.sun.com/JSP/Page"
    xmlns:c="http://java.sun.com/jsp/jstl/core"
    xmlns:form="http://www.springframework.org/tags/form" version="2.0">
    <jsp:directive.page language="java" contentType="text/html" />
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
    <!-- ... -->

    <c:url var="logoutUrl" value="/logout"/>
    <form:form action="${logoutUrl}"
        method="post">
    <input type="submit"
        value="Log out" />
    <input type="hidden"
        name="${_csrf.parameterName}"
        value="${_csrf.token}"/>
    </form:form>

    <!-- ... -->
</html>
</jsp:root>
```

아래와 유사한 HTML을 출력한다:

```xml
<!-- ... -->

<form action="/context/logout" method="post">
<input type="submit" value="Log out"/>
<input type="hidden" name="_csrf" value="f81d4fae-7dec-11d0-a765-00a0c91e6bf6"/>
</form>

<!-- ... -->
```

#### Resolving the CsrfToken

스프링 시큐리티는 스프링 MVC 인자에 자동으로 현재 `CsrfToken`을 리졸브해주는 `CsrfTokenArgumentResolver`를 제공한다. [@EnableWebSecurity](../javaconfiguration#jc-hello-wsca)를 사용하면 자동으로 스프링 MVC 설정에 추가된다. XML 설정을 사용한다면 직접 추가해야 한다. 예를 들어:

`CsrfTokenArgumentResolver`를 제대로 설정했다면 스태틱 HTML 기반 어플리케이션에 `CsrfToken`을 사용할 수 있다.

```java
@RestController
public class CsrfController {

    @RequestMapping("/csrf")
    public CsrfToken csrf(CsrfToken token) {
        return token;
    }
}
```

`CsrfToken`은 다른 도메인에 노출하지 않아야 한다. 다시말해 [Cross Origin Sharing (CORS)](https://developer.mozilla.org/en-US/docs/Web/HTTP/Access_control_CORS)을 사용하고 있다면 외부 도메인에 `CsrfToken`을 노출해선 **안 된다**.

---

## 15.7. WebSocket Security

스프링 시큐리티 4에서 [스프링의 웹소켓](https://docs.spring.io/spring/docs/current/spring-framework-reference/html/websocket.html) 보안 추가했다. 이번 섹션에선 스프링 시큐리티로 웹 소켓을 보호하는 방법을 설명한다.

> 실제로 동작하는 웹 소켓 보안 예제는 https://github.com/spring-projects/spring-session/tree/master/spring-session-samples/spring-session-sample-boot-websocket에서 볼 수 있다.

> #### Direct JSR-356 Support
>
> JSR-356을 지원하는 건 크게 의미가 없어서 스프링 시큐리티는 이를 직접 지원하지 않는다. 포맷을 알 수 없기 때문인데, [알 수 없는 포맷을 보호하기 위해 스프링이 할 수 있는 일은 많지 않다](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#websocket-intro). 게다가 JSR-356에선 메세지를 가로챌 방법이 없기 때문에 보안을 적용하려면 비니지스 로직 영역을 침범할 수 밖에 없다.

### 15.7.1. WebSocket Configuration

스프링 시큐리티 4.0에선 스프링 메세지 추상화를 이용한 웹소켓 인가 기능을 추가했다. 자바 설정을 사용한다면 간단하게 `AbstractSecurityWebSocketMessageBrokerConfigurer`를 상속해서 `MessageSecurityMetadataSourceRegistry`를 설정해라. 예를 들어:

```java
@Configuration
public class WebSocketSecurityConfig
      extends AbstractSecurityWebSocketMessageBrokerConfigurer { // (1) (2)

    protected void configureInbound(MessageSecurityMetadataSourceRegistry messages) {
        messages
                .simpDestMatchers("/user/**").authenticated() // (3)
    }
}
```

이렇게 하면 다음을 보장할 수 있다:
- <small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 모든 인바운드 CONNECT 메세지는 [동일 출처 정책](#1574-enforcing-same-origin-policy)에 따라 유효한 CSRF 토큰이 있어야 한다.</small><br>
- <small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> SecurityContextHolder는 인바운드 요청의 simpUser 헤더 속성 정보로 사용자 정보를 채운다.</small><br>
- <small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 메세지엔 적당한 권한이 필요하다. 특히 "/user/"로 시작하는 모든 인바운드 메세지는 ROLE_USER 권한이 필요하다. 권한 인가에 대한 자세한 설명은 [WebSocket Authorization](#1573-websocket-authorization)에 있다.</small>

스프링 시큐리티는 웹소켓 보안을 위한 [XML 네임스페이스](https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#nsa-websocket-security)도 제공한다. 위와 동일한 XML 설정은 다음과 같다:

```xml
<websocket-message-broker> <!-- (1) (2) -->
    <!-- (3) -->
    <intercept-message pattern="/user/**" access="hasRole('USER')" />
</websocket-message-broker>
```

이렇게 하면 다음을 보장할 수 있다:
- <small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 모든 인바운드 CONNECT 메세지는 [동일 출처 정책](#1574-enforcing-same-origin-policy)에 따라 유효한 CSRF 토큰이 있어야 한다.</small><br>
- <small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> SecurityContextHolder는 인바운드 요청의 simpUser 헤더 속성 정보로 사용자 정보를 채운다.</small><br>
- <small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 메세지엔 적당한 권한이 필요하다. 특히 "/user/"로 시작하는 모든 인바운드 메세지는 ROLE_USER 권한이 필요하다. 권한 인가에 대한 자세한 설명은 [WebSocket Authorization](#1573-websocket-authorization)에 있다.</small>

### 15.7.2. WebSocket Authentication

웹소켓은 커넥션을 맺었을 때 HTTP 요청에 있는 인증 정보를 재사용한다. 즉, `HttpServletRequest`에 있는 `Principal`이 웹소켓으로도 전달된다는 뜻이다. 스프링 시큐리티를 사용한다면 `HttpServletRequest`의 `Principal`이 자동으로 재정의된다.

좀 더 구체적으로 말하면, HTTP 기반 웹 어플리케이션에서 스프링 시큐리티로 인증 설정을 해 놨다면, 웹소켓 어플리케이션에서도 사용자를 인증할 수 있다.

### 15.7.3. WebSocket Authorization

스프링 시큐리티 4.0에서 스프링 메세지 추상화를 이용한 웹소켓 인가 기능을 추가했다. 자바 설정을 사용한다면 간단하게 `AbstractSecurityWebSocketMessageBrokerConfigurer`를 상속해서 `MessageSecurityMetadataSourceRegistry`를 설정해라. 예를 들어:

```java
@Configuration
public class WebSocketSecurityConfig extends AbstractSecurityWebSocketMessageBrokerConfigurer {

    @Override
    protected void configureInbound(MessageSecurityMetadataSourceRegistry messages) {
        messages
                .nullDestMatcher().authenticated() // (1)
                .simpSubscribeDestMatchers("/user/queue/errors").permitAll() // (2)
                .simpDestMatchers("/app/**").hasRole("USER") // (3)
                .simpSubscribeDestMatchers("/user/**", "/topic/friends/*").hasRole("USER") // (4)
                .simpTypeMatchers(MESSAGE, SUBSCRIBE).denyAll() // (5)
                .anyMessage().denyAll(); // (6)

    }
}
```

이렇게 설정하면 다음을 보장할 수 있다:
- <small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> destination이 없는 모든 메세지는 (i.e. MESSAGE, SUBSCRIBE를 제외한 모든 메세지 타입) 사용자 인증이 필요하다.</small><br>
- <small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 누구든지 /user/queue/errors를 구독할 수 있다.</small><br>
- <small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> "/app/"으로 시작하는 destination이 있는 모든 메세지는 ROLE_USER 권한이 필요하다.</small><br>
- <small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span>  "/user/"나 "/topic/friends/"로 시작하는 모든 SUBSCRIBE 타입 메세지는 ROLE_USER 권한이 필요하다.</small><br>
- <small><span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> 다른 MESSAGE, SUBSCRIBE 타입 메세지는 모두 거절한다. 6번이 있어서 이 설정은 없어도 되지만, 특정 메세지 타입을 매칭하는 방법을 보여준다.</small><br>
- <small><span style="background-color: #a9dcfc; border-radius: 50px;">(6)</span> 그 외 모든 메세지는 거절한다. 특정 메세지를 누락하지 않도록 이렇게 막아두는 게 좋다.</small>

스프링 시큐리티는 웹소켓 보안을 위한 [XML 네임스페이스](https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#nsa-websocket-security)도 제공한다. 위와 동일한 XML 설정은 다음과 같다:

```xml
<websocket-message-broker>
    <!-- (1) -->
    <intercept-message type="CONNECT" access="permitAll" />
    <intercept-message type="UNSUBSCRIBE" access="permitAll" />
    <intercept-message type="DISCONNECT" access="permitAll" />

    <intercept-message pattern="/user/queue/errors" type="SUBSCRIBE" access="permitAll" /> <!-- (2) -->
    <intercept-message pattern="/app/**" access="hasRole('USER')" /> <!-- (3) -->

    <!-- (4) -->
    <intercept-message pattern="/user/**" access="hasRole('USER')" />
    <intercept-message pattern="/topic/friends/*" access="hasRole('USER')" />

    <!-- (5) -->
    <intercept-message type="MESSAGE" access="denyAll" />
    <intercept-message type="SUBSCRIBE" access="denyAll" />

    <intercept-message pattern="/**" access="denyAll" /> <!-- (6) -->
</websocket-message-broker>
```

이렇게 설정하면 다음을 보장할 수 있다:
- <small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 모든 CONNECT, UNSUBSCRIBE, DISCONNECT 타입 메세지는 사용자 인증이 필요하다.</small><br>
- <small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 누구든지 /user/queue/errors를 구독할 수 있다.</small><br>
- <small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> "/app/"으로 시작하는 destination이 있는 모든 메세지는 ROLE_USER 권한이 필요하다.</small><br>
- <small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> "/user/"나 "/topic/friends/"로 시작하는 모든 SUBSCRIBE 타입 메세지는 ROLE_USER 권한이 필요하다.</small><br>
- <small><span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> 다른 MESSAGE, SUBSCRIBE 타입 메세지는 모두 거절한다. 6번이 있어서 이 설정은 없어도 되지만, 특정 메세지 타입을 매칭하는 방법을 보여준다.</small><br>
- <small><span style="background-color: #a9dcfc; border-radius: 50px;">(6)</span> 그 외 destination이 있는 모든 메세지는 거절한다. 특정 메세지를 누락하지 않도록 이렇게 막아두는 게 좋다.</small>

#### WebSocket Authorization Notes

어플리케이션을 제대로 보호하려면 스프링이 어떻게 웹소켓을 지원하는지 이해하고 있어야 한다.

##### WebSocket Authorization on Message Types

SUBSCRIBE와 MESSAGE 타입이 어떻게 다르며 스프링에서 어떻게 동작하는지 알아두는 것도 중요하다.

채팅 어플리케이션을 생각해 보자.

- 시스템에선 "/topic/system/notifications"를 destination으로 가지고 있는 알림 **메세지**를 모든 사용자에게 전송할 수 있다.
- 클라이언트는 "/topic/system/notifications"를 **구독**해서 알림을 받을 수 있다.

클라이언트는 "/topic/system/notifications"를 **구독**할 순 있지만 여기로 **메세지**를 전송할 순 없어야 한다. 클라이언트가 "/topic/system/notifications"에 **메세지**를 보낼 수 있도록 허용하면, 클라이언트가 시스템을 사칭해 이 엔드포인트로 직접 메세지를 전송할 수도 있다.

보통은 [브로커 프리픽스](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#websocket-stomp)로 (i.e. "/topic/", "/queue/") 시작하는 destination에 전송하는 모든 **메세지**를 거절하는 게 일반적이다.

##### WebSocket Authorization on Destinations

destination이 어떻게 변경되는지도 알아두는 것이 좋다.

채팅 어플리케이션을 생각해 보자.

- 사용자가 다른 특정 사용자에게 메세지를 보낼 때는 "/app/chat"을 destination으로 설정한 메세지를 전송한다.
- 어플리케이션에서 메세지를 받으면 "from" 속성을 현재 사용자로 명시했는지 확인한다 (클라이언트는 신뢰할 수 없다).
- 그러면 어플리케이션에서 `SimpMessageSendingOperations.convertAndSendToUser("toUser", "/queue/messages", message)`를 사용해서 수신자에게 메세지를 전송한다.
- 메세지의 destination은 "/queue/user/messages-\<sessionid\>"로 바뀐다.

위 어플리케이션에서는 클라이언트가 "/queue/user/messages-\<sessionid\>"로 변환되는 "/user/queue"를 수신할 수 있게 만들려고 한다. 하지만 클라이언트는 모든 사용자의 메세지를 의미하는 "/queue/\*"는 수신할 수 없다.

보통은 [브로커 프리픽스](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#websocket-stomp)로 (i.e. "/topic/" or "/queue/") 시작하는 메세지는 **구독**할 수 없게 막는 것이 일반적이다. 물론 아래와 같은 상황에선 예외를 둘 수 있다.

#### Outbound Messages

스프링 문서에는 시스템에서 어떻게 메세지가 흘러가는지 설명하는 [Flow of Messages](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#websocket-stomp-message-flow) 섹션이 있다. 단, 스프링 시큐리티는 `clientInboundChannel`만 보호해준다는 점을 유의해야 한다. 스프링 시큐리티는 `clientOutboundChannel`은 보호하지 않는다.

가장 큰 이유는 성능 때문이다. 보통 들어오는 메세지에 비해 나가는 메세지가 더 많다. 아웃바운드를 메세지를 보호하기보단 엔드포인트 구독을 보호하는 게 더 낫다.

### 15.7.4. Enforcing Same Origin Policy

브라우저는 웹소켓 커넥션을 맺을 때 [동일 출처 정책](https://en.wikipedia.org/wiki/Same-origin_policy)을 시행하지 않는다는 점에 주의해야 한다. 웹소켓을 사용할 땐 반드시 이 점을 고려해서 개발해야 한다.

#### Why Same Origin?

이 사례를 한 번 생각해 보자. bank.com에 방문한 사용자가 계정을 인증한다. 같은 사용자가 브라우저에서 다른 탭을 열어 evil.com을 방문한다. 동일 출처 정책에 따라 evil.com에선 bank.com에서 데이터를 읽거나 쓸 수 없다.

웹소켓에선 동일 출처 정책을 시행하지 않는다. 실제로 bank.com에서 명시적으로 이를 막지 않는 한, evil.com은 사용자 대신 데이터를 읽고 쓸 수 있다. 즉, 사용자가 웹소켓으로 할 수 있는 일은 (i.e. 송금) 전부 evil.com에서도 재현할 수 있다.

SockJS는 웹소켓을 모방하므로 이 역시 동일 출처 정책을 그냥 통과한다. 따라서 외부 도메인에서 SockJS를 사용해 어플리케이션에 접근할 수 없도록 직접 방어 로직을 구현해야 한다.

#### Spring WebSocket Allowed Origin

다행히도 스프링은 4.1.5 버전부터, 웹소켓과 SockJS를 사용할 때 [현재 도메인](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#websocket-server-allowed-origins)에서만 접근할 수 있도록 지원한다. 스프링 시큐리티는 [심층 방어(defence in depth)](https://en.wikipedia.org/wiki/Defense_in_depth_%28computing%29)를 위한 protection 레이어를 하나 더 추가했다.

#### Adding CSRF to Stomp Headers

스프링 시큐리티를 사용하면 기본적으로 모든 CONNECT 타입 메세지에 [CSRF 토큰](../features#521-cross-site-request-forgery-csrf)이 있어야 한다. 즉, CSRF 토큰에 접근할 수 있는 사이트만 커넥션을 맺을 수 있다. **Origin이 동일한** 사이트만 CSRF 토큰에 접근할 수 있으므로 외부 도메인은 커넥션을 맺을 수 없다.

보통은 HTTP 헤더나 HTTP 파라미터에 CSRF 토큰을 추가한다. 하지만 SockJS로는 불가능하다. 대신에 Stomp 헤더에 토큰을 추가해야 한다.

어플리케이션은 요청 속성 _csrf에 접근해서 [CSRF 토큰을 가져올 수 있다](../protectionagainstexploits#include-the-csrf-token). 예를 들어 다음 코드를 사용하면 JSP에서 `CsrfToken`에 접근할 수 있다:

```javascript
var headerName = "${_csrf.headerName}";
var token = "${_csrf.token}";
```

스태틱 HTML을 사용한다면 REST 엔드포인트로 `CsrfToken`을 노출할 수 있다. 예를 들어 아래 코드는 /csrf URL로 `CsrfToken`을 노출한다.

```java
@RestController
public class CsrfController {

    @RequestMapping("/csrf")
    public CsrfToken csrf(CsrfToken token) {
        return token;
    }
}
```

자바스크립트에선 이 엔드포인트로 REST 요청을 보내, 응답으로 headerName과 토큰을 채울 수 있다.

이제 Stomp 클라이언트에 토큰을 추가할 수 있다. 예를 들어:

```javascript
...
var headers = {};
headers[headerName] = token;
stompClient.connect(headers, function(frame) {
  ...

}
```

#### Disable CSRF within WebSockets

다른 도메인에서도 사이트에 접근할 수 있도록 허용하고 싶다면 스프링 시큐리티 기능을 비활성화하면 된다. 예를 들어 자바 설정에선 아래 코드를 사용하면 된다:

```java
@Configuration
public class WebSocketSecurityConfig extends AbstractSecurityWebSocketMessageBrokerConfigurer {

    ...

    @Override
    protected boolean sameOriginDisabled() {
        return true;
    }
}
```

### 15.7.5. Working with SockJS

[SockJS](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#websocket-fallback)는 구 버전 브라우저를 위한 폴백 전송을 제공한다. 폴백 옵션을 사용한다면 SockJS가 스프링 시큐리티 어플리케이션에서 동작할 수 있게 몇 가지 보안 제약 조건을 완화해야 한다.

#### SockJS & frame-options

SockJS는 메세지를 [아이프레임으로 전송](https://github.com/sockjs/sockjs-client/tree/v0.3.4)할 수도 있다. 스프링 시큐리티는 클릭재킹 공격을 막기 위해 기본적으로 사이트를 프레임에 넣을 수 없게 [막는다](../features#x-frame-options). SockJS의 프레임 기반 전송을 허용하려면 동일 출처에선 컨텐츠를 프레임에 넣을 수 있도록 스프링 시큐리티 설정을 바꿔야 한다.

X-Frame-Options는 [frame-options](https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#nsa-frame-options) 요소로 커스텀할 수 있다. 예를 들어 아래 설정은 스프링 시큐리티에 "X-Frame-Options: SAMEORIGIN"을 사용하도록 지시해서 동일한 도메인에서는 아이프레임을 허용한다.

```xml
<http>
    <!-- ... -->

    <headers>
        <frame-options
          policy="SAMEORIGIN" />
    </headers>
</http>
```

이와 유사하게 자바 설정에선 다음 코드로 프레임 옵션을 동일 출처로 변경할 수 있다:

```java
@EnableWebSecurity
public class WebSecurityConfig extends
   WebSecurityConfigurerAdapter {

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http
            // ...
            .headers(headers -> headers
                .frameOptions(frameOptions -> frameOptions
                     .sameOrigin()
                )
        );
    }
}
```

#### SockJS & Relaxing CSRF

SockJS는 HTTP 기반으로 CONNECT 메세지를 전송할 땐 POST를 사용한다. 보통은 HTTP 헤더나 HTTP 파라미터에 CSRF 토큰을 추가한다. 하지만 SockJS로는 불가능하다. 대신에 [Adding CSRF to Stomp Headers](#adding-csrf-to-stomp-headers)에서 설명한대로 Stomp 헤더에 토큰을 추가해야 한다.

이 말은 웹 레이어에서 CSRF 방어를 완화해야 한다는 뜻이기도 하다. 특히, connect URL에서 CSRF 방어를 비활성화해야 한다. 모든 URL에서 CSRF 방어를 비활성화하려는 것은 *아니다*. 모든 URL에서 비활성화하면 CSRF 공격에 취약해질 수 있다.

이땐 단순히 CSRF RequestMatcher를 설정하면 된다. 자바 설정을 사용한다면 매우 간단해 진다. 예를 들어 stomp 엔드포인트가 "/chat"라면 아래 설정으로 "/chat/"로 시작하는 URL만 CSRF 방어를 비활성화할 수 있다:

```java
@Configuration
@EnableWebSecurity
public class WebSecurityConfig
    extends WebSecurityConfigurerAdapter {

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf
                // ignore our stomp endpoints since they are protected using Stomp headers
                .ignoringAntMatchers("/chat/**")
            )
            .headers(headers -> headers
                // allow same origin to frame our site to support iframe SockJS
                .frameOptions(frameOptions -> frameOptions
                    .sameOrigin()
                )
            )
            .authorizeRequests(authorize -> authorize
                ...
            )
            ...
```

XML 설정을 사용한다면 [csrf@request-matcher-ref](https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#nsa-csrf-request-matcher-ref)를 사용해라. 예를 들어:

```xml
<http ...>
    <csrf request-matcher-ref="csrfMatcher"/>

    <headers>
        <frame-options policy="SAMEORIGIN"/>
    </headers>

    ...
</http>

<b:bean id="csrfMatcher"
    class="AndRequestMatcher">
    <b:constructor-arg value="#{T(org.springframework.security.web.csrf.CsrfFilter).DEFAULT_CSRF_MATCHER}"/>
    <b:constructor-arg>
        <b:bean class="org.springframework.security.web.util.matcher.NegatedRequestMatcher">
          <b:bean class="org.springframework.security.web.util.matcher.AntPathRequestMatcher">
            <b:constructor-arg value="/chat/**"/>
          </b:bean>
        </b:bean>
    </b:constructor-arg>
</b:bean>
```

---

## 15.8. CORS

스프링 프레임워크는 [CORS를 완벽하게 지원한다](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-cors). pre-flight 요청엔 쿠키가 없으므로 (i.e. `JSESSIONID`) CORS는 반드시 스프링 시큐리티보다 먼저 처리해야 한다. 쿠키가 없는 요청을 스프링 시큐리티에서 먼저 처리하면 인증하지 않은 사용자로 간주해서 (요청에 쿠키가 없으므로) 요청을 거절한다.

CORS를 가장 먼저 처리하는 제일 간단한 방법은 `CorsFilter`를 사용하는 것이다. 스프링 시큐리티와 `CorsFilter`를 통합할 땐 아래처럼  `CorsConfigurationSource`를 설정하면 된다:

```java
@EnableWebSecurity
public class WebSecurityConfig extends WebSecurityConfigurerAdapter {

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http
            // by default uses a Bean by the name of corsConfigurationSource
            .cors(withDefaults())
            ...
    }

    @Bean
    CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOrigins(Arrays.asList("https://example.com"));
        configuration.setAllowedMethods(Arrays.asList("GET","POST"));
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}
```

XML을 사용한다면

```xml
<http>
    <cors configuration-source-ref="corsSource"/>
    ...
</http>
<b:bean id="corsSource" class="org.springframework.web.cors.UrlBasedCorsConfigurationSource">
    ...
</b:bean>
```

스프링 MVC의 CORS 기능을 사용하고 있다면 `CorsConfigurationSource` 설정을 생략할 수 있으며, 스프링 시큐리티는 스프링 MVC에 제공한 CORS 설정을 사용할 것이다.

```java
@EnableWebSecurity
public class WebSecurityConfig extends WebSecurityConfigurerAdapter {

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http
            // if Spring MVC is on classpath and no CorsConfigurationSource is provided,
            // Spring Security will use CORS configuration provided to Spring MVC
            .cors(withDefaults())
            ...
    }
}
```

XML을 사용한다면

```xml
<http>
    <!-- Default to Spring MVC's CORS configuration -->
    <cors />
    ...
</http>
```

---

## 15.9. JSP Tag Libraries

스프링 시큐리티는 JPS에서 보안 정보에 접근하고 보안 제약 조건을 적용할 수 있는 자체 태그 라이브러리를 제공한다.

### 15.9.1. Declaring the Taglib

이 태그를 사용하려면 JSP에 보안 taglib를 명시해야 한다:

```xml
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
```

### 15.9.2. The authorize Tag

이 태그는 조건에 따라 컨텐츠를 노출할할 때 사용한다. 스프링 시큐리티 3.0에선 두 가지 방법으로 활용할 수 있다. 먼저 태그의 `access` 속성에 [웹 보안 표현식](../authorization#1132-web-security-expressions)을 명시하는 방법이 있다. 표현식 평가는 어플리케이션 컨텍스트에 정의한 `SecurityExpressionHandler<FilterInvocation>`으로 위임한다 (이를 사용하려면 `<http>` 네임스페이스 설정에 있는 웹 표현식을 활성화해야 한다). 예를 들어 다음과 같이 사용할 수 있다:

```xml
<sec:authorize access="hasRole('supervisor')">

This content will only be visible to users who have the "supervisor" authority in their list of <tt>GrantedAuthority</tt>s.

</sec:authorize>
```

스프링 시큐리티의 PermissionEvaluator를 사용하면 태그로 permission도 검사할 수 있다. 예를 들어:

```xml
<sec:authorize access="hasPermission(#domain,'read') or hasPermission(#domain,'write')">

This content will only be visible to users who have read or write permission to the Object found as a request attribute named "domain".

</sec:authorize>
```

흔한 요구사항 중 하나로, 사용자가 실제로 특정 링크를 클릭할 권한이 있을 때만 링크를 보여주곤 한다. 링크를 허용할지를 어떻게 미리 결정하냐고? 이 태그는 특정 URL을 속성으로 정의하는 식으로도 활용할 수 있다. URL을 실행할 권한이 있는 사용자일 때만 태그 본문를 노출하며, 그렇지 않을 땐 생략한다. 예를 들어 다음과 같이 활용할 수 있다:

```xml
<sec:authorize url="/admin">

This content will only be visible to users who are authorized to send requests to the "/admin" URL.

</sec:authorize>
```

이 태그를 사용하려면 어플리케이션 컨텍스트에 `WebInvocationPrivilegeEvaluator` 인스턴스도 필요하다. 네임스페이스를 사용한다면 자동으로 하나가 등록된다. 이 인스턴스는 전달받은 URL로 더미 웹 요청을 만들어 요청 성공/실패 여부를 확인하는 `DefaultWebInvocationPrivilegeEvaluator` 인스턴스다. 이를 통해 접근 제어를 `<http>` 네임스페이스 설정에 정의한 `intercept-url`로 위임할 수 있으며, JSP에서 권한 정보를 (필요한 role 등) 중복으로 가지고 있지 않아도 된다. HTTP 메소드를 제공하는 `method` 속성과 결합하면 좀 더 구체적인 조건으로 매칭할 수 있다.

태그를 평가한 결과값인 Boolean은 (접근을 허용하거나 거부하는지 여부), `var` 속성에 변수 이름을 넣어 페이지 컨텍스트 스코프 변수에 저장할 수 있다. 따라서 동일한 페이지 내에서는 같은 조건을 다시 평가하지 않아도 된다.

#### Disabling Tag Authorization for Testing

권한이 없는 사용자에게 링크를 숨겨도 URL 접근을 차단하지는 않는다. 예를 들어 사용자가 직접 브라우저에 주소를 입력해서 접근할 수 있다. 실제로 백엔드에서 링크를 보호하는지 테스트하기 위해 숨겨진 영역을 노출하고 싶을 수도 있다. 시스템 프로퍼티  `spring.security.disableUISecurity`를 `true`로 설정하면 `authorize` 태그는 계속 실행되지만 컨텐츠를 숨기지는 않는다. 대신에 디폴트로 컨텐츠를 `<span class="securityHiddenUI">…</span>` 태그로 감싸준다. 이 점을 활용해서 특정 CSS 스타일을 적용해 다른 배경 색을 지정하는 식으로 "숨겨진" 컨텐츠를 표시할 수 있다. 예시를 보고 싶다면 이 속성을 활성화한 상태에서 "tutorial" 샘플 어플리케이션을 실행해 봐라.

`spring.security.securedUIPrefix`, `spring.security.securedUISuffix` 프로퍼티로 디폴트 `span` 태그 주변 텍스트를 변경할 수도 있다 (빈 문자열을 사용해서 완전히 제거하는 것도 가능하다).

### 15.9.3. The authentication Tag

이 태그는 보안 컨텍스트에 저장된 현재 `Authentication` 객체에 접근할 수 있게 해준다. JSP에서 객체 프로퍼티를 직접 렌더링한다. 예를 들어 `Authentication`의 `principal` 프로퍼티가 스프링 시큐리티의 `UserDetails` 객체 인스턴스라면, `<sec:authentication property="principal.username" />` 는 현재 사용자의 이름으로 렌더링된다.

물론 이 때문에 JSP 태그를 사용할 필요는 없으며, 뷰에서는 가능한 한 로직을 최소화하는 것을 선호하는 사람들도 있다. MVC 컨트롤러에서 `Authentication` 객체에 접근해서 (`SecurityContextHolder.getContext().getAuthentication()` 호출) 뷰를 렌더링할 때 사용하는 모델에 직접 데이터를 추가하는 방법도 있다.

### 15.9.4. The accesscontrollist Tag

이 태그는 스프링 시큐리티의 ACL 모듈을 사용할 때만 쓸 수 있다. 이 태그는 특정 도메인 객체에서 필요한 permission 리스트를 쉼표로 구분해서 확인한다. 현재 사용자가 permission을 모두 가지고 있다면 태그 본문을 노출한다. 그렇지 않으면 생략한다. 예를 들어:

> 일반적으로 이 태그는 사용하지 않는 것이 좋다 (deprecated). 대신에 [authorize 태그](#1592-the-authorize-tag)를 사용해라.

```xml
<sec:accesscontrollist hasPermission="1,2" domainObject="${someObject}">

This will be shown if the user has all of the permissions represented by the values "1" or "2" on the given object.

</sec:accesscontrollist>
```

permission은 어플리케이션 컨텍스트에 정의한 `PermissionFactory` 전달돼 ACL `Permission` 인스턴스로 변환되므로, 팩토리가 지원하는 모든 형식을 사용할 수 있다 - 정수여야 한다는 법은 없으며 `READ`, `WRITE`같은 문자열도 사용할 수 있다. `PermissionFactory`가 없으면 `DefaultPermissionFactory` 인스턴스를 사용한다. 객체에 대한 `Acl` 인스턴스를 로드할 땐 어플리케이션 컨텍스트에 있는 `AclService`를 사용한다. 필요한 permission을 넘겨 `Acl`을 실행해서 해당 permissin이 전부 있는지 체크한다.

이 태그도 `authorize` 태그와 동일하게 `var` 속성을 지원한다.

### 15.9.5. The csrfInput Tag

CSRF 방어를 활성화하면, 이 태그는 CSRF 방어 토큰에 필요한 name, value 필드를 가지고 있는 hidden 폼를 삽입한다. CSRF 방어를 활성화하지 않으면 이 태그는 아무것도 출력하지 않는다.

일반적으로 스프링 시큐리티는 모든 `<form:form>` 태그에 CSRF 폼 필드를 자동으로 추가하지만, 어떤 이유로 `<form:form>`을 사용할 수 없다면 `csrfInput`으로 쉽게 대체할 수 있다.

이 태그는 평소에 다른 입력 필드를 넣는 HTML `<form></form>` 블록 안에 배치해야 한다. 이 태그를 스프링  `<form:form></form:form>` 블록 안에 두면 *안 된다*. 스프링 시큐리티는 스프링 폼을 자동으로 처리한다.

```xml
<form method="post" action="/do/something">
    <sec:csrfInput />
    Name:<br />
    <input type="text" name="name" />
    ...
</form>
```

### 15.9.6. The csrfMetaTags Tag

CSRF 방어를 활성화하면, 이 태그는 CSRF 방어 토큰 폼 필드와, 헤더 이름, CSRF 보호 토큰 값을 포함하는 메타 태그를 삽입한다. 어플리케이션 내 자바스크립트에서 CSRF를 방어할 때 이 메타 태그를 활용할 수 있다.

`csrfMetaTags`는 평소에 다른 메타 태그를 넣는 HTML `<head></head>` 블록 안에 배치해야 한다. 이 태그를 사용하면 자바스크립트에서 간단하게 폼 필드 이름, 헤더 이름, 토큰 값에 접근할 수 있다. 이 예제에서는 더 쉽게 활용할 수 있는 JQuery를 사용한다.

```xml
<!DOCTYPE html>
<html>
    <head>
        <title>CSRF Protected JavaScript Page</title>
        <meta name="description" content="This is the description for this page" />
        <sec:csrfMetaTags />
        <script type="text/javascript" language="javascript">

            var csrfParameter = $("meta[name='_csrf_parameter']").attr("content");
            var csrfHeader = $("meta[name='_csrf_header']").attr("content");
            var csrfToken = $("meta[name='_csrf']").attr("content");

            // using XMLHttpRequest directly to send an x-www-form-urlencoded request
            var ajax = new XMLHttpRequest();
            ajax.open("POST", "https://www.example.org/do/something", true);
            ajax.setRequestHeader("Content-Type", "application/x-www-form-urlencoded data");
            ajax.send(csrfParameter + "=" + csrfToken + "&name=John&...");

            // using XMLHttpRequest directly to send a non-x-www-form-urlencoded request
            var ajax = new XMLHttpRequest();
            ajax.open("POST", "https://www.example.org/do/something", true);
            ajax.setRequestHeader(csrfHeader, csrfToken);
            ajax.send("...");

            // using JQuery to send an x-www-form-urlencoded request
            var data = {};
            data[csrfParameter] = csrfToken;
            data["name"] = "John";
            ...
            $.ajax({
                url: "https://www.example.org/do/something",
                type: "POST",
                data: data,
                ...
            });

            // using JQuery to send a non-x-www-form-urlencoded request
            var headers = {};
            headers[csrfHeader] = csrfToken;
            $.ajax({
                url: "https://www.example.org/do/something",
                type: "POST",
                headers: headers,
                ...
            });

        <script>
    </head>
    <body>
        ...
    </body>
</html>
```

CSRF 방어를 활성화하지 않으면 `csrfMetaTags`는 아무것도 출력하지 않는다.
