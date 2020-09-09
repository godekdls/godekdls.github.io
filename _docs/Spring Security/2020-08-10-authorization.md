---
title: Authorization
category: Spring Security
order: 12
permalink: /Spring%20Security/authorization/
description: 서블릿 기반 어플리케이션에 적용할 수 있는 스프링 시큐리티 인가를 설명합니다. 공식 문서에 있는 "authorization" 챕터를 한글로 번역한 문서입니다.
image: ./../../images/springsecurity/filtersecurityinterceptor.png
priority: 0.8
lastmod: 2020-08-25T23:10:00+09:00
comments: true
completed: false
originalRefName: 스프링 시큐리티
originalRefLink: https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#servlet-authorization
---
<script>defaultLanguages = ['java']</script>

### 목차:

- [11.1. Authorization Architecture](#111-authorization-architecture)
  + [11.1.1. Authorities](#1111-authorities)
  + [11.1.2. Pre-Invocation Handling](#1112-pre-invocation-handling)
    * [The AccessDecisionManager](#the-accessdecisionmanager)
    * [Voting-Based AccessDecisionManager Implementations](#voting-based-accessdecisionmanager-implementations)
  + [11.1.3. After Invocation Handling](#1113-after-invocation-handling)
  + [11.1.4. Hierarchical Roles](#1114-hierarchical-roles)
- [11.2. Authorize HttpServletRequest with FilterSecurityInterceptor](#112-authorize-httpservletrequest-with-filtersecurityinterceptor)
- [11.3. Expression-Based Access Control](#113-expression-based-access-control)
  + [11.3.1. Overview](#1131-overview)
    * [Common Built-In Expressions](#common-built-in-expressions)
  + [11.3.2. Web Security Expressions](#1132-web-security-expressions)
    * [Referring to Beans in Web Security Expressions](#referring-to-beans-in-web-security-expressions)
    * [Path Variables in Web Security Expressions](#path-variables-in-web-security-expressions)
  + [11.3.3. Method Security Expressions](#1133-method-security-expressions)
    * [@Pre and @Post Annotations](#pre-and-post-annotations)
    * [Built-In Expressions](#built-in-expressions)
- [11.4. Secure Object Implementations](#114-secure-object-implementations)
  + [11.4.1. AOP Alliance (MethodInvocation) Security Interceptor](#1141-aop-alliance-methodinvocation-security-interceptor)
    * [Explicit MethodSecurityInterceptor Configuration](#explicit-methodsecurityinterceptor-configuration)
  + [11.4.2. AspectJ (JoinPoint) Security Interceptor](#1142-aspectj-joinpoint-security-interceptor)
- [11.5. Method Security](#115-method-security)
  + [11.5.1. EnableGlobalMethodSecurity](#1151-enableglobalmethodsecurity)
  + [11.5.2. GlobalMethodSecurityConfiguration](#1152-globalmethodsecurityconfiguration)
  + [11.5.3. The \<global-method-security\> Element](#1153-the-global-method-security-element)
  + [11.5.4. Adding Security Pointcuts using protect-pointcut](#1154-adding-security-pointcuts-using-protect-pointcut)
- [11.6. Domain Object Security (ACLs)](#116-domain-object-security-acls)
  + [11.6.1. Overview](#1161-overview)
  + [11.6.2. Key Concepts](#1162-key-concepts)
  + [11.6.3. Getting Started](#1163-getting-started)
  
---

스프링 시큐리티의 고급 인가 기능은 가장 인기 있는 기능 중 하나다. 인증 방법과 상관없이 (스프링 시큐리티가 제공하는 메커니즘과 provider 사용 여부나, 컨테이너나 스프링 시큐리티 외의 인증 권한과의 통합 여부와는 상관없이) 어플리케이션에 일관적이고, 간단하게 인증 서비스를 적용할 수 있다.

이번 장에선 Part I에서 소개했던 `AbstractSecurityInterceptor`의 다양한 구현체를 살펴본다. 그다음 도메인 접근 제어 목록을 통해 인가 기능을 세부적으로 튜닝하는 방법을 살펴볼 것이다.

---

## 11.1. Authorization Architecture

### 11.1.1. Authorities

[`Authentication`](../authentication#103-authentication) 섹션에선 어떻게 모든 `Authentication` 구현체가 `GrantedAuthority` 객체 리스트를 저장하는지를 설명한다. `GrantedAuthority` 객체는 principal에게 부여한 권한을 나타낸다. `AuthenticationManager`가 `GrantedAuthority` 객체를 `Authentication` 객체에 삽입하며, 이후 권한을 결정할 때 `AccessDecisionManager`가 `GrantedAuthority`를 읽어간다.

`GrantedAuthority`는 메소드가 하나 뿐인 인터페이스다:

```java
String getAuthority();
```

`AccessDecisionManager`들은 이 메소드로 `GrantedAuthority`를 정확한 `String`으로 얻을 수 있다. `GrantedAuthority`가 값을 `String`으로 리턴하기 때문에 `AccessDecisionManager` 대부분이 이를 쉽게 "읽어"갈 수 있다. `GrantedAuthority`를 명확하게 `String`으로 표현할 수 없다면 `GrantedAuthority`는 "복잡한 케이스"로 간주하고 `getAuthority()`는 `null`을 리턴한다.

"복잡한" `GrantedAuthority`의 예시로는 고객 계정 번호에 따라 적용할 작업과 권한 임계치 리스트를 저장하는 일이 있다. 이 복잡한 `GrantedAuthority`를 `String`으로 표현하긴 어렵기때문에 `getAuthority()`는 `null`을 리턴할 것이다. `null`을 리턴했다는 것은 `AccessDecisionManager`에 `GrantedAuthority`를 이해하기 위한 구체적인 코드가 있어야 한다는 뜻이다.

스프링 시큐리티는 한 가지 `GrantedAuthority` 구현체, `SimpleGrantedAuthority`를 제공한다. 이 클래스는 사용자가 지정한 `String`을 `GrantedAuthority`로 변환해 준다. 시큐리티 아키텍처에 속한 모든 `AuthenticationProvider`는 `Authentication` 객체 값을 채울 때 `SimpleGrantedAuthority`를 사용한다.

### 11.1.2. Pre-Invocation Handling

스프링 시큐리티는 method invocation이나 웹 요청같은 보안 객체에 대한 접근을 제어하는 인터셉터를 제공한다. 호출을 허용할지 말지를 결정하는 pre-invocation 결정은 `AccessDecisionManager`에서 내린다.

#### The AccessDecisionManager

`AccessDecisionManager`는 `AbstractSecurityInterceptor`에서 호출하며, 최종적인 접근 제어를 결정한다. `AccessDecisionManager`는 세 가지 메소드가 있다:

```java
void decide(Authentication authentication, Object secureObject,
    Collection<ConfigAttribute> attrs) throws AccessDeniedException;

boolean supports(ConfigAttribute attribute);

boolean supports(Class clazz);
```

`AccessDecisionManager`의 `decide` 메소드는 권한을 결정하기 위해 필요한 모든 정보를 건내 받는다. 특히, 보안 `Object`를 건내 받으면 실제 보안 객체를 실행할 때 넘긴 인자를 검사할 수 있다. 예를 들어 보안 객체가 `MethodInvocation`이었다고 가정해보자. 모든 `Customer` 인자에 관한 `MethodInvocation`은 쉽게 찾을 수 있으며, `AccessDecisionManager` 안에선 일련의 보안 로직으로 principal이 customer 관련 동작을 실행하도록 허가할 수 있다. 접근을 거절한 경우엔 `AccessDeniedException`을 던진다.

`supports(ConfigAttribute)` 메소드는 기동 시점에  `AbstractSecurityInterceptor`가 호출하며, `AccessDecisionManager`가 건내받은 `ConfigAttribute`를 처리할 수 있는지 여부를 결정한다. `supports(Class)` 메소드는 시큐리티 인터셉터 구현체가 호출하며, 설정해둔 `AccessDecisionManager`가 시큐리티 인터셉터가 제출할 보안 객체 타입을 지원하는지 확인한다.

#### Voting-Based AccessDecisionManager Implementations

인가와 관련한 모든 동작을 제어하고 싶다면 커스텀 `AccessDecisionManager`를 사용해도 되지만, 스프링 시큐리티는 투표를 기반으로 동작하는 몇 가지 `AccessDecisionManager` 구현체를 제공한다. 아래 있는 [Voting Decision Manager](#authz-access-voting)는 관련 클래스를 도식화한 그림이다.

<span id="authz-access-voting">**Figure 11. Voting Decision Manager**</span><br>![Voting Decision Manager](./../../images/springsecurity/access-decision-voting.png)

이 방식에선 권한을 결정할 때 일련의 `AccessDecisionVoter` 구현체에 의견을 묻는다. 그러고나면 `AccessDecisionManager`가 투표 결과를 평가해서 `AccessDeniedException`을 던질지 말지 결정을 내린다.

`AccessDecisionVoter`는 메소드 세 개를 가진  인터페이스다:

```java
int vote(Authentication authentication, Object object, Collection<ConfigAttribute> attrs);

boolean supports(ConfigAttribute attribute);

boolean supports(Class clazz);
```

구현체는 `AccessDecisionVoter`의 스태틱 필드 `ACCESS_ABSTAIN`, `ACCESS_DENIED`, `ACCESS_GRANTED` 중 하나를 의미하는 `int` 값을 리턴한다. 인가에 대해서 특별한 의견이 없을 때 구현체는 `ACCESS_ABSTAIN`을 리턴한다. 의견이 있다면 반드시 `ACCESS_DENIED`나 `ACCESS_GRANTED`를 리턴해야 한다.

스프링 시큐리티는 투표 결과를 집계하는 `AccessDecisionManager` 구현체 세 가지를 제공한다. `ConsensusBased`는 기권표가 아닌 투표 결과를 합산해 접근을 허가하거나 거절한다. 투표 결과가 동점이거나 모두 기권표일 때의 동작은 프로퍼티로 조절할 수 있다. `AffirmativeBased`는 `ACCESS_GRANTED`를 하나 이상 받으면 권한을 부여한다 (i.e. 찬성표가 하나라도 있으면 거절표는 무시한다). `ConsensusBased`와 마찬가지로 모두 기권했을 때의 동작을 제어할 수 있는 파라미터를 제공한다. `UnanimousBased`는 기권을 제외한 모든 표가 만장일치로 `ACCESS_GRANTED`일 때만 접근을 허가한다. `ACCESS_DENIED`가 하나라도 있으면 접근을 거부한다. 다른 구현체와 마찬가지로 모두 기권했을 때의 동작을 제어하는 파라미터가 있다.

다른 방식으로 투표 결과를 집계하는 커스텀 `AccessDecisionManager`를 구현해도 된다. 예를 들어, 특정 `AccessDecisionVoter`의 투표에는 가중치를 두고, 특정 voter의 거절표는 기각시킬 수도 있다.

#### RoleVoter

스프링 시큐리티가 제공하는 `AccessDecisionVoter` 중 가장 많이 사용하는 건 간단한 `RoleVoter`다. `RoleVoter`는 설정 속성을 간단한 role 이름으로 취급하고, 사용자가 해당 role을 할당받았으면 접근 허가에 투표한다.

프리픽스 `ROLE_`로 시작하는 `ConfigAttribute`이 있을 때 투표에 참여한다. `GrantedAuthority`가 리턴하는 `String`이 (`getAuthority()` 메소드 사용) `ROLE_`로 시작하는 `ConfigAttributes` 중 하나라도 완전히 일치하면 찬성표를 던진다. `ROLE_`로 시작하는 `ConfigAttribute`와 일치하는 게 하나도 없으면 `RoleVoter`는 반대표를 던진다. `ROLE_`로 시작하는 `ConfigAttribute`가 없으면 기권한다.

#### AuthenticatedVoter

또 다른 voter는 이전 챕터에서 살짝 언급했던 `AuthenticatedVoter`다. 이 voter는 익명 사용자와, 완전히 인증된 사용자와, remember-me로 인증한 사용자를 구분할 수 있다. 많은 사이트에서 일부 페이지를 remember-me로 인증한 사용자에게도 열어 놓지만, 모든 페이지에 접근하려면 로그인을 요구한다.

익명 사용자 접근을 위한 `IS_AUTHENTICATED_ANONYMOUSLY` 속성은 `AuthenticatedVoter`가 처리한다. 자세한 정보는 이 클래스의 Javadoc을 참고해라.

#### Custom Voters

원한다면 당연히 커스텀 `AccessDecisionVoter`를 구현해서 원하는 곳에 접근 제어 로직을 넣을 수 있다. 보통 어플리케이션에 특화된 로직이나 (비지니스 로직 관련) 보안 관리 로직을 구현하는 데 사용한다. 예를 들어 스프링 웹 사이트에 있는 [블로그 문서](https://spring.io/blog/2009/01/03/spring-security-customization-part-2-adjusting-secured-session-in-real-time)에서 설명하는 방법으로, 계정이 정지된 사용자의 접근을 실시간으로 거절할 수 있다.

### 11.1.3. After Invocation Handling

보안 객체를 실행하기 전에는 `AbstractSecurityInterceptor`가 `AccessDecisionManager`를 호출하는데, 반면에 보안 객체가 실제로 리턴하는 객체를 바꿔야 하는 어플리케이션도 있다. 이땐 직접 AOP 관심사를 구현해도 되지만, 스프링 시큐리티는 ACL 기능과 통합되는 몇 가지 구현체를 가진 편리한 훅을 제공한다.

아래 있는 [After Invocation Implementation](#authz-after-invocation)은 스프링 시큐리티의 `AfterInvocationManager`와 해당 구현체를 도식화한 그림이다.

<span id="authz-after-invocation">**Figure 12. After Invocation Implementation**</span><br>![After Invocation Implementation](./../../images/springsecurity/after-invocation.png)

스프링 시큐리티의 설계가 대부분 그렇듯, `AfterInvocationManager`도 `AfterInvocationProviderManager`라는 구현체가 하나 있으며, 이 구현체는 `AfterInvocationProvider` 리스트를 폴링한다. 각 `AfterInvocationProvider`는 리턴 객체를 수정하거나 `AccessDeniedException`을 던질 수 있다. 사실 여러 provider가 객체를 수정할 수 있기 때문에, provider에 전달하는 객체는 리스트에 있는 이 전 provider가 리턴한 결과다.

`AfterInvocationManager`를 사용하더라도, `MethodSecurityInterceptor`의 `AccessDecisionManager`가 동작을 허용하도록 만들 설정 속성이 필요하다는 점을 알아둬야 한다. `AccessDecisionManager` 구현체 등 전형적인 스프링 시큐리티 설정을 사용했다면, 특정 보안 method invocation을 위해 정의한 설정 속성이 없는 경우 모든 `AccessDecisionVoter`가 투표를 기권할 것이다. 결국 `AccessDecisionManager`의 "allowIfAllAbstainDecisions" 프로퍼티가 `false`였다면 `AccessDeniedException`을 던질 것이다. 이 이슈를 피하려면 (1) "allowIfAllAbstainDecisions"를 `true`로 설정하거나 (보통 이 방법은 추천하지 않긴 하지만), (2) `AccessDecisionVoter`가 접근 허용에 투표할 수 있도록 해당하는 설정 속성을 최소 한 개 사용해야 한다. 후자는 (권장하는 방법) 보통 `ROLE_USER`나 `ROLE_AUTHENTICATED` 설정 속성을 이용한다.

### 11.1.4. Hierarchical Roles

특정 role은 자동으로 다른 role도 "포함"해야 한다는 건 일반적인 요구사항이다. 예를 들어 "admin" role과 "user" role이 있는 어플리케이션에선, 일반 user가 할 수 있는 모든 일은 admin도 할 수 있길 바랄 수 있다. 이를 위해선 먼저, 모든 admin 사용자에게 "user" role도 부여하는 방법이 있다. 아니면 "user" role이 필요한 모든 접근 제약 조건을 "admin" role도 포함하도록 수정하는 방법도 있다. 어플리케이션이 관리하는 role이 많다면 이 방법은 꽤나 복잡해질 것이다.

role-hierarchy를 사용하면 특정 role이 (또는 권한이) 다른 role을 포함하도록 설정할 수 있다. 스프링 시큐리티의 [RoleVoter](#rolevoter)를 확장한 `RoleHierarchyVoter`는 `RoleHierarchy`를 설정할 수 있으며, 이 값을 통해 사용자에게 할당할 모든 "reachable authorities"를 가져올 수 있다. 전형적인 설정은 다음과 같다:

```xml
<bean id="roleVoter" class="org.springframework.security.access.vote.RoleHierarchyVoter">
    <constructor-arg ref="roleHierarchy" />
</bean>
<bean id="roleHierarchy"
        class="org.springframework.security.access.hierarchicalroles.RoleHierarchyImpl">
    <property name="hierarchy">
        <value>
            ROLE_ADMIN > ROLE_STAFF
            ROLE_STAFF > ROLE_USER
            ROLE_USER > ROLE_GUEST
        </value>
    </property>
</bean>
```

여기서 사용한 계층 구조에는 네 가지 역할이 있다 (`ROLE_ADMIN ⇒ ROLE_STAFF ⇒ ROLE_USER ⇒ ROLE_GUEST`). `AccessDecisionManager`에 위 `RoleHierarchyVoter`를 설정하면 제약 조건을 평가할 때, `ROLE_ADMIN`으로 인증한 사용자는 마치 네 가지 role을 모두 가진 것처럼 행동할 수 있다. `>` 부호는 "포함한다"로 해석하면 된다.

Role hierarchy는 어플리케이션의 접근 제어 설정을 단순화하고, 사용자마다 할당할 권한을 줄일 수 있는 편리한 수단이다. 좀 더 복잡한 요구사항이 있다면 어플리케이션에 필요한 특정 접근 권한과 사용자에게 할당할 role을 매핑하는 로직을 정의해서 사용자 정보를 로드할 때 이 둘을 변환하면 된다.

---

## 11.2. Authorize HttpServletRequest with FilterSecurityInterceptor

이번 섹션은 [서블릿 아키텍처와 구현체](../servletsecuritythebigpicture)를 기반으로 서블릿 기반 어플리케이션에서 어떻게  [인가](#)를 처리하는지 자세히 설명한다.

[`FilterSecurityInterceptor`](https://docs.spring.io/spring-security/site/docs/current/api/org/springframework/security/web/access/intercept/FilterSecurityInterceptor.html)는 `HttpServletRequest`에 [인가](#)를 제공한다. 이 인터셉터는 [FilterChainProxy](../servletsecuritythebigpicture#93-filterchainproxy)에 하나의 [보안 필터](../servletsecuritythebigpicture#95-security-filters)로 추가된다.

![Authorize HttpServletRequest](./../../images/springsecurity/filtersecurityinterceptor.png)

- <span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 먼저 `FilterSecurityInterceptor`가 [SecurityContextHolder](../authentication#101-securitycontextholder)에서 [Authentication](../authentication#103-authentication)을 조회한다.
- <span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 두 번째는 `FilterSecurityInterceptor`가 넘겨받은 `HttpServletRequest`, `HttpServletResponse`, `FilterChain`으로  [`FilterInvocation`](https://docs.spring.io/spring-security/site/docs/current/api/org/springframework/security/web/FilterInvocation.html)을 만든다.
- <span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 그다음 `FilterInvocation`을 `SecurityMetadataSource`로 넘겨 `ConfigAttribute` 컬렉션을 가져온다.
- <span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> 마지막으로 `Authentication`, `FilterInvocation`, `ConfigAttribute` 컬렉션을 `AccessDecisionManager`로 넘긴다.
  - <span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> 인가를 거절하면 `AccessDeniedException`을 던진다. 이땐 [`ExceptionTranslationFilter`](../servletsecuritythebigpicture#96-handling-security-exceptions)가 `AccessDeniedException`을 처리한다.
  - <span style="background-color: #a9dcfc; border-radius: 50px;">(6)</span> 인가를 승인하면 `FilterSecurityInterceptor`는 일반적인 어플리케이션 프로세스를 실행할 수 있게 [FilterChain](../servletsecuritythebigpicture#91-a-review-of-filters)을 이어간다.

기본적으로 스프링 시큐리티에서 권한을 인가하려면 모든 요청을 인증해야 한다. 명시적으로 설정하면 다음과 같다:

**Example 78. Every Request Must be Authenticated**

<div class="switch-language-wrapper java xml kotlin">
<span class="switch-language java">java</span>
<span class="switch-language xml">xml</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java xml kotlin"></div>
```java
protected void configure(HttpSecurity http) throws Exception {
    http
        // ...
        .authorizeRequests(authorize -> authorize
            .anyRequest().authenticated()
        );
}
```
<div class="language-only-for-xml java xml kotlin"></div>
```xml
<http>
    <!-- ... -->
    <intercept-url pattern="/**" access="authenticated"/>
</http>
```
<div class="language-only-for-kotlin java xml kotlin"></div>
```kotlin
fun configure(http: HttpSecurity) {
    http {
        // ...
        authorizeRequests {
            authorize(anyRequest, authenticated)
        }
    }
}
```

우선순위에 따라 다른 규칙을 추가할 수도 있다:

**Example 79. Authorize Requests**

<div class="switch-language-wrapper java xml kotlin">
<span class="switch-language java">java</span>
<span class="switch-language xml">xml</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java xml kotlin"></div>
```java
protected void configure(HttpSecurity http) throws Exception {
    http
        // ...
        .authorizeRequests(authorize -> authorize        // (1)
            .mvcMatchers("/resources/**", "/signup", "/about").permitAll()         // (2)
            .mvcMatchers("/admin/**").hasRole("ADMIN")        // (3)
            .mvcMatchers("/db/**").access("hasRole('ADMIN') and hasRole('DBA')")        // (4)
            .anyRequest().denyAll()        // (5)         
        );
}
```
<div class="language-only-for-xml java xml kotlin"></div>
```xml
<http> <!-- (1) -->
    <!-- ... -->
    <!-- (2) -->
    <intercept-url pattern="/resources/**" access="permitAll"/>
    <intercept-url pattern="/signup" access="permitAll"/>
    <intercept-url pattern="/about" access="permitAll"/>

    <intercept-url pattern="/admin/**" access="hasRole('ADMIN')"/> <!-- (3) -->
    <intercept-url pattern="/db/**" access="hasRole('ADMIN') and hasRole('DBA')"/> <!-- (4) -->
    <intercept-url pattern="/**" access="denyAll"/> <!-- (5) -->
</http>
```
<div class="language-only-for-kotlin java xml kotlin"></div>
```kotlin
fun configure(http: HttpSecurity) {
   http {
        authorizeRequests { // (1)
            authorize("/resources/**", permitAll) // (2)
            authorize("/signup", permitAll)
            authorize("/about", permitAll)

            authorize("/admin/**", hasRole("ADMIN")) // (3)
            authorize("/db/**", "hasRole('ADMIN') and hasRole('DBA')") // (4)
            authorize(anyRequest, denyAll) // (5)
        }
    }
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 인가 조건을 여러 개 명시했다. 각 규칙은 선언한 순서대로 적용된다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 모든 사용자가 접근할 수 있는 URL 패턴을 여러 개 지정했다. 구체적으로 말하면 "/resources/"로 시작하는 URL이나, "/signup", "/about" 요청은 모든 사용자가 접근할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> "/admin/"으로 시작하는 모든 요청은 "ROLE_ADMIN"을 가진 사용자로 제한한다. `hasRole` 메소드를 사용했기 때문에 "ROLE\_" 프리픽스는 지정할 필요 없다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> "/db/"로 시작하는 모든 요청은 "ROLE_ADMIN"과 "ROLE_DBA" 모두 필요하다. `hasRole` 메소드를 사용했기 때문에 "ROLE\_" 프리픽스는 지정할 필요 없다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> 위 조건에 충족하지 않는 다른 URL은 접근을 거절한다. 실수로 인증 조건을 누락하는 것을 방지하려면 이 전략을 사용하는 게 좋다.</small>

---

## 11.3. Expression-Based Access Control

스프링 시큐리티 3.0부터 간단한 설정 속성과 voter로 접근 권한을 결정하는 방법 외에도, 스프링 EL 표현식을 사용해 인가 메커니즘을 구현할 수 있다. 표현식 기반으로 접근을 제어할 땐 동일한 아키텍처를 사용하지만, 복잡한 Boolean 로직을 간단한 표현식 하나로 캡슐화할 수 있다.

### 11.3.1. Overview

스프링 시큐리티는 스프링 EL 표현식을 사용하며, 이 주제를 자세히 알고싶다면 동작 방식을 살펴보는게 좋다. 표현식을 평가할 땐 평가 컨텍스트의 일부로 "루트 객체" 사용한다. 스프링 시큐리티는 웹과 메소드 시큐리티 전용 클래스를 루트 객체로 사용하기 때문에, 별도의 내장 표현식을 사용할 수 있으며 현재 principal 등에 접근할 수 있다.

#### Common Built-In Expressions

표현식 루트 객체를 위한 베이스 클래스는 `SecurityExpressionRoot`다. 이 클래스는 웹, 메소드 시큐리티에서 공통적으로 사용할 수 있는 공통 표현식 몇 가지를 제공한다.

**Table 1. Common built-in expressions**

| Expression                                                   | Description                                                  |
| :----------------------------------------------------------- | :----------------------------------------------------------- |
| `hasRole(String role)`                                       | 현재 principal이 명시한 role을 가지고 있으면 `true`를 리턴한다.<br><br>예를 들어,  `hasRole('admin')`<br><br>기본적으로 파라미터로 넘긴 role이 'ROLE\_'로 시작하지 않으면 이 프리픽스를 추가한다. `DefaultWebSecurityExpressionHandler`의 `defaultRolePrefix`를 수정하면 이를 커스텀할 수 있다. |
| `hasAnyRole(String… roles)`                                  | 현재 principal이 명시한 role 중 하나라도 가지고 있으면 `true`를 리턴한다 (문자열 리스트를 콤마로 구분해서 전달한다).<br><br>예를 들어 `hasAnyRole('admin', 'user')`<br><br>기본적으로 파라미터로 넘긴 role이 'ROLE\_'로 시작하지 않으면 이 프리픽스를 추가한다. `DefaultWebSecurityExpressionHandler`의 `defaultRolePrefix`를 수정하면 이를 커스텀할 수 있다. |
| `hasAuthority(String authority)`                             | 현재 principal이 명시한 권한이 있으면 `true`를 리턴한다.<br><br>예를 들어 `hasAuthority('read')` |
| `hasAnyAuthority(String… authorities)`                       | 현재 principal이 명시한 권한 중 하나라도 있으면 `true`를 리턴한다 (문자열 리스트를 콤마로 구분해서 전달한다).<br><br>예를 들어 `hasAnyAuthority('read', 'write')` |
| `principal`                                                  | 현재 사용자를 나타내는 principal 객체에 직접 접근할 수 있다. |
| `authentication`                                             | `SecurityContext`로 조회할 수 있는 현재 `Authentication` 객체에 직접 접근할 수 있다. |
| `permitAll`                                                  | 항상 `true`로 평가한다.                                      |
| `denyAll`                                                    | 항상 `false`로 평가한다.                                     |
| `isAnonymous()`                                              | 현재 principal이 익명 사용자면 `true`를 리턴한다.            |
| `isRememberMe()`                                             | 현재 principal이 remember-me 사용자면 `true`를 리턴한다.     |
| `isAuthenticated()`                                          | 사용자가 익명이 아니면 `true`를 리턴한다.                    |
| `isFullyAuthenticated()`                                     | 사용자가 익명 사용자나 remember-me 사용자가 아니면 `true`를 리턴한다. |
| `hasPermission(Object target, Object permission)`            | 사용자가 target에 해당 permission 권한이 있으면 `true`를 리턴한다. 예를 들어 `hasPermission(domainObject, 'read')` |
| `hasPermission(Object targetId, String targetType, Object permission)` | 사용자가 target에 해당 permission 권한이 있으면 `true`를 리턴한다. 예를 들어 `hasPermission(1, 'com.example.domain.Message', 'read')` |

### 11.3.2. Web Security Expressions

URL별로 표현식을 적용하려면 먼저 `<http>` 요소의 `use-expressions` 속성을 `true`로 설정해야 한다. 이렇게 하면 스프링 시큐리티는 `<intercept-url>` 요소의 `access` 속성에 스프링 EL 표현식이 있음을 인지할 수 있다. 표현식은 접근을 허용할지 말지를 Boolean으로 평가해야 한다. 예를 들어:

```xml
<http>
    <intercept-url pattern="/admin*"
        access="hasRole('admin') and hasIpAddress('192.168.1.0/24')"/>
    ...
</http>
```

여기서는 어플리케이션의 "admin" 영역은 (URL 패턴으로 정의함) "admin" 권한을 부여받은 사용자가 로컬 서브넷으로 접근할 때만 사용할 수 있도록 정의했다. 내장된 `hasRole` 표현식은 이미 이전 섹션에서 살펴봤다. `hasIpAddress` 표현식은 웹 보안에서 사용할 수 있는 또다른 내장 표현식이다. `WebSecurityExpressionRoot` 클래스에 정의돼 있으며, 이 클래스의 인스턴스를 웹 접근 표현식을 평가할 때의 루트 객체로 사용한다. 또한 이 객체는 `HttpServletRequest` 객체를 `request`란 이름으로 직접 노출하므로 표현식에서 직접 request를 실행할 수도 있다. 표현식을 사용하면 네임스페이스에 있는 `AccessDecisionManager`에 `WebExpressionVoter`가 추가된다. 따라서 네임스페이스 없이 표현식을 사용한다면 이 중 하나를 설정에 직접 추가해야 한다.

#### Referring to Beans in Web Security Expressions

사용할 수 있는 표현식을 늘리고 싶다면, 어떤 객체든지 스프링 빈으로 정의하면 쉽게 참조할 수 있다. 예를 들어 `webSecurity`란 이름의 빈이 있고, 이 빈의 메소드 시그니처는 다음과 같다고 가정해보자:

```java
public class WebSecurity {
        public boolean check(Authentication authentication, HttpServletRequest request) {
                ...
        }
}
```

이 메소드는 다음과 같이 참조할 수 있다:

```xml
<http>
    <intercept-url pattern="/user/**"
        access="@webSecurity.check(authentication,request)"/>
    ...
</http>
```

또는 자바 설정을 사용한다면

```java
http
    .authorizeRequests(authorize -> authorize
        .antMatchers("/user/**").access("@webSecurity.check(authentication,request)")
        ...
    )
```

#### Path Variables in Web Security Expressions

어땔 땐 URL에 있는 path variable을 참조하고 싶을 수도 있다. 예를 들어 `/user/{userId}` 형식의 URL path에서 id를 가져와 사용자를 검색하는 RESTful 어플리케이션을 생각해 보자.

path variable도 패턴에 지정해서 쉽게 참조할 수 있다. 예를 들어 `webSecurity`란 이름의 빈이 있고, 이 빈의 메소드 시그니처는 다음과 같다고 가정해보자:

```java
public class WebSecurity {
        public boolean checkUserId(Authentication authentication, int id) {
                ...
        }
}
```

이 메소드는 다음과 같이 참조할 수 있다:

```xml
<http>
    <intercept-url pattern="/user/{userId}/**"
        access="@webSecurity.checkUserId(authentication,#userId)"/>
    ...
</http>
```

또는 자바 설정을 사용한다면

```java
http
    .authorizeRequests(authorize -> authorize
        .antMatchers("/user/{userId}/**").access("@webSecurity.checkUserId(authentication,#userId)")
        ...
    );
```

두 설정 모두, URL이 매칭되면 checkUserId 메소드로 path variable을 (변환까지 해서) 전달한다. 예를 들어 URL이 `/user/123/resource`였다면 전달하는 id는 `123`이다.

### 11.3.3. Method Security Expressions

메소드 시큐리티는 단순한 허가 또는 거절보다 조금 더 복잡한 규칙을 사용한다. 스프링 시큐리티 3.0은 표현식을 종합적으로 지원하기 위한 새 애노테이션을 도입했다.

#### @Pre and @Post Annotations

네 가지 애노테이션이 표현식 속성을 지원한다. 사전/사후 권한 체크를 지원하며, 제출한 컬렉션 인자나 리턴한 값을 필터링할 수도 있다. 이 애노테이션은 바로 `@PreAuthorize`, `@PreFilter`, `@PostAuthorize`, `@PostFilter`다. 애노테이션 사용은 네임스페이스의 `global-method-security` 요소로 활성화한다.

```xml
<global-method-security pre-post-annotations="enabled"/>
```

#### Access Control using @PreAuthorize and @PostAuthorize

가장 유용할 애노테이션은 실제로 메소드를 실행할 수 있는지 없는지를 결정하는 `@PreAuthorize`다. 예를 들어 (["contacts" 샘플 어플리케이션](https://github.com/spring-projects/spring-security/tree/master/samples/xml/contacts) 코드 일부 발췌)

```java
@PreAuthorize("hasRole('USER')")
public void create(Contact contact);
```

이는 "ROLE_USER" 권한이 있는 사용자만 접근할 수 있다는 뜻이다. 물론 전통적인 설정과 간단한 설정 속성으로도 동일한 권한 조건을 쉽게 구성할 수 있다. 하지만 이건 어떨까:

```java
@PreAuthorize("hasPermission(#contact, 'admin')")
public void deletePermission(Contact contact, Sid recipient, Permission permission);
```

여기선 현재 사용자가 실제로 주어진 연락처에 "admin" 권한이 있는지를 확인하기 위해 메소드 인자를 표현식 일부로 사용하고 있다. 내장 표현식 `hasPermission()`은 어플리케이션 컨텍스트를 통해 스프링 시큐리티의 ACL 모듈로 연결되며, [아래에서 다룬다](#the-permissionevaluator-interface). 메소드 인자는 이름을 기준으로 표현식 변수로 접근할 수 있다.

스프링 시큐리티가 메소드 인자를 리졸브하는 방법은 여러 가지가 있다. 스프링 시큐리티는 `DefaultSecurityParameterNameDiscoverer`를 사용해서 파라미터 이름을 발견한다. 디폴트로 메소드 전체에 대해 다음 옵션을 시도해 본다.

- 메소드의 단일 인자에 `@P` 애노테이션이 있는 경우 이 값을 사용한다. 이 애노테이션은 파라미터 이름에 관한 정보를 담지 않는 JDK 8 이전 버전으로 컴파일한 인터페이스에 유용하다. 예를 들어:

  ```java
  import org.springframework.security.access.method.P;
  
  ...
  
  @PreAuthorize("#c.name == authentication.name")
  public void doSomething(@P("c") Contact contact);
  ```

  이를 사용하면 내부적으로 어떤 애노테이션이든지 value 속성을 지원하도록 커스텀할 수 있는 `AnnotationParameterNameDiscoverer`를 사용한다.

- 메소드 파라미터 한 개라도 스프링 데이터의 `@Param` 애노테이션이 있으면 이 값을 사용한다. 이 애노테이션은 파라미터 이름에 관한 정보를 담지 않는 JDK 8 이전 버전으로 컴파일한 인터페이스에 유용하다. 예를 들어:

  ```java
  import org.springframework.data.repository.query.Param;
  
  ...
  
  @PreAuthorize("#n == authentication.name")
  Contact findContactByName(@Param("n") String name);
  ```

  이를 사용하면 내부적으로 어떤 애노테이션이든지 value 속성을 지원하도록 커스텀할 수 있는 `AnnotationParameterNameDiscoverer`를 사용한다.

- -parameters 인자를 사용해서 JDK 8로 소스 코드를 컴파일하고 스프링 4+를 사용했다면, 표준 JDK 리플렉션 API로 파라미터 이름을 찾는다. 클래스와 인터페이스 둘 모두에서 동작한다.

- 마지막으로 debug symbol을 포함해서 컴파일했다면, 이 debug symbol을 사용해서 파라미터 이름을 찾는다. 인터페이스는 파라미터 이름과 관련한 디버그 정보가 없으므로 동작하지 않는다. 인터페이스를 사용한다면 애노테이션이나 JDK 8 방식을 사용해야 한다.

표현식 내에선 모든 스프링 EL 기능을 사용할 수 있으므로 인자의 프로퍼티에도 접근할 수 있다. 예를 들어 특정 메소드를, username이 연락처의 이름과 일치하는 사용자에게만 허가하고 싶다면 다음과 같이 작성할 수 있다.

```java
@PreAuthorize("#contact.name == authentication.name")
public void doSomething(Contact contact);
```

여기선 또 다른 내장 표현식 `authentication`을 사용했으며, 이는 보안 컨텍스트에 저장된 `Authentication`을 나타낸다. `principal` 표현식을 사용하면 "principal" 프로퍼티에 직접 접근할 수도 있다. 보통 이 값은 `UserDetails` 인스턴스이므로 `principal.username`이나 `principal.enabled`같은 표현식을 사용하면 된다.

일반적이진 않지만, 메소드를 실행한 다음에 접근 제어를 확인하고 싶을 수도 있다. 이땐 `@PostAuthorize` 애노테이션을 사용하면 된다. 메소드가 리턴한 값에 접근하려면 표현식에 내장된 이름 `returnObject`를 사용해라.

#### Filtering using @PreFilter and @PostFilter

이미 알고 있겠지만, 스프링 시큐리티는 컬렉션이나 배열 필터링을 지원하며, 이제는 표현식으로 구현할 수 있다. 메소드가 리턴한 값에 가장 많이 사용한다. 예를 들어:

```java
@PreAuthorize("hasRole('USER')")
@PostFilter("hasPermission(filterObject, 'read') or hasPermission(filterObject, 'admin')")
public List<Contact> getAll();
```

`@PostFilter` 애노테이션을 사용하면, 스프링 시큐리티는 리턴된 컬렉션을 순회해서 표현식 결과가 false인 모든 요소를 제거한다. `filterObject`는 컬렉션의 현재 객체를 참조한다. `@PreFilter`를 사용하면 메소드 호출 전에 필터링할 수도 있지만, 흔한 요구사항은 아니다. 기본 문법은 동일하지만, 컬렉션 타입 인자가 둘 이상이라면 애노테이션의 `filterTarget` 프로퍼티로 이름을 지정해야 한다.

필터링은 데이터 조회 쿼리를 튜닝하는 용도가 아니라는 점을 명심해야 한다. 사이즈가 큰 컬렉션을 필터링하고 많은 엔트리를 제거하는 것은 비효율적이다.

#### Built-In Expressions

시큐리티에 특화된 내장 표현식도 있다. 사실 위에서 이미 다뤘다. `filterTarget`과 `returnValue`도 간단하게 사용할 수 있지만, `hasPermission()` 표현식을 사용하면 좀 더 자세히 살펴볼 수도 있다.

#### The PermissionEvaluator interface

`hasPermission()` 표현식은 `PermissionEvaluator` 인스턴스로 위임된다. 이는 표현식 시스템과 스프링 시큐리티의 ACL 시스템을 연결하기 위한 것으로, 추상적인 permission 기반으로 도메인 객체에 인가 조건을 명시할 수 있다. ACL 모듈에 직접적인 의존성은 없으므로 필요하다면 다른 구현체로 바꿀 수 있다. 이 인터페이스엔 두 가지 메소드가 있다:

```java
boolean hasPermission(Authentication authentication, Object targetDomainObject,
                            Object permission);

boolean hasPermission(Authentication authentication, Serializable targetId,
                            String targetType, Object permission);
```

첫 번째 인자 (`Authentication` 객체)를 제공하지 않은 경우만 제외하면 모두 가능한 표현식으로 매핑된다. 첫 번째 메소드는 접근을 제어하는 도메인 객체를 이미 로드한 경우에 사용된다. 현재 사용자가 이 객체에 대한 주어진 permission이 있다면 표현식은 true를 리턴할 것이다. 두 번째 버전은 객체를 로드하진 않았지만 그 식별자를 알 때 사용한다. 올바른 ACL permission을 로드하려면 도메인 객체에 대한 추상적인 "type" 지정자도 필요하다. 보통은 그 객체의 자바 클래스를 사용하지만, permission을 로드하는 방식과 일치하기만 하면 꼭 그래야 한다는 법은 없다.

`hasPermission()` 표현식을 사용하려면 어플리케이션 컨텍스트에 `PermissionEvaluator`를 명시해야 한다. 예를 들어 다음과 같다:

```xml
<security:global-method-security pre-post-annotations="enabled">
<security:expression-handler ref="expressionHandler"/>
</security:global-method-security>

<bean id="expressionHandler" class=
"org.springframework.security.access.expression.method.DefaultMethodSecurityExpressionHandler">
    <property name="permissionEvaluator" ref="myPermissionEvaluator"/>
</bean>
```

`myPermissionEvaluator`는 `PermissionEvaluator`를 구현한 빈이다. 보통 `AclPermissionEvaluator`라고 하는 ACL 모듈에 있는 구현체를 사용한다. 자세한 내용은 ["Contacts" 샘플 어플리케이션 설정](https://github.com/spring-projects/spring-security/blob/master/samples/xml/contacts/src/main/resources/applicationContext-security.xml)을 참고해라.

#### Method Security Meta Annotations

메소드 시큐리티에 메타 애노테이션을 사용하면 코드를 좀 더 가독성있게 만들 수 있다. 코드 전체에 걸쳐 똑같은 복잡한 표현식을 반복하고 있다면 특히 유용할 것이다. 예를 들어 아래 코드를 생각해 보자:

```java
@PreAuthorize("#contact.name == authentication.name")
```

이 코드를 모든 곳에 반복하는 대신, 이 코드 대신 사용할 메타 애노테이션을 만들 수 있다.

```java
@Retention(RetentionPolicy.RUNTIME)
@PreAuthorize("#contact.name == authentication.name")
public @interface ContactPermission {}
```

메타 애노테이션은 스프링 시큐리티의 모든 메소드 시큐리티 애노테이션에 사용할 수 있다. 스펙 준수를 위해 JSR-250 애노테이션은 메타 애노테이션을 지원하지 않는다.

---

## 11.4. Secure Object Implementations

### 11.4.1. AOP Alliance (MethodInvocation) Security Interceptor

스프링 시큐리티 2.0 이전엔 `MethodInvocation`을 보호하려면 꽤 많은 보일러플레이트 설정이 필요했다. 현재 권장하는 메소드 시큐리티 설정 방법은 [네임스페이스 설정](../securitynamespaceconfiguration#184-method-security)이다. 이 방법을 사용하면 메소드 시큐리티를 위한 빈들이 자동으로 설정되기 때문에 구현체를 알 필요가 정말 없다. 여기선 관련 클래스 개요만 간단하게 짚고 넘어간다.

메소드 시큐리티는 `MethodInvocation`을 보호해 주는 `MethodSecurityInterceptor`로 구현한다. 설정 방법에 따라 인터셉터를 특정한 빈 하나에서만 사용할 수도 있고, 인터셉터 하나를 여러 빈이 공유할 수도 있다. 인터셉터는 `MethodSecurityMetadataSource` 인스턴스를 사용해서 특정 method invocation에 적용할 설정 속성을 가져온다. `MapBasedMethodSecurityMetadataSource`로는 메소드 이름을 (와일드카드 지원) 키로 갖는 설정 속성을 저장하며, 내부적으로 `<intercept-methods>`나 `<protect-point>` 요소로 어플리케이션에 해당 속성을 정의했을 때 사용한다. 다른 구현체는 애노테이션 기반 설정에서 사용한다.

#### Explicit MethodSecurityInterceptor Configuration

물론 어플리케이션 컨텍스트에 `MethodSecurityInterceptor`를 직접 설정해서 스프링 AOP의 프록시 메커니즘과 함께 사용할 수도 있다:

```xml
<bean id="bankManagerSecurity" class=
    "org.springframework.security.access.intercept.aopalliance.MethodSecurityInterceptor">
<property name="authenticationManager" ref="authenticationManager"/>
<property name="accessDecisionManager" ref="accessDecisionManager"/>
<property name="afterInvocationManager" ref="afterInvocationManager"/>
<property name="securityMetadataSource">
    <sec:method-security-metadata-source>
    <sec:protect method="com.mycompany.BankManager.delete*" access="ROLE_SUPERVISOR"/>
    <sec:protect method="com.mycompany.BankManager.getBalance" access="ROLE_TELLER,ROLE_SUPERVISOR"/>
    </sec:method-security-metadata-source>
</property>
</bean>
```

### 11.4.2. AspectJ (JoinPoint) Security Interceptor

AspectJ 보안 인터셉터는 앞에서 설명한 AOP Alliance 보안 인터셉터와 매우 유사하다. 실제로 이번 섹션에선 차이점만 다뤄볼 것이다.

이 AspectJ 인터셉터 이름은 `AspectJSecurityInterceptor`다. 프록시를 통해 인터셉터를 구성할 때 스프링 어플리케이션 컨텍스트에 의존하는 AOP Alliance 보안 인터셉터와는 달리, `AspectJSecurityInterceptor`는 AspectJ 컴파일러를 통해 구성된다. 어플리케이션 하나에 보안 인터셉터 두 종류를 모두 사용하는 게 그렇게 드문 일도 아니다. 보통 `AspectJSecurityInterceptor`로 도메인 객체 인스턴스 보안을 처리하고, AOP Alliance `MethodSecurityInterceptor`로 서비스 레이어 보안을 처리한다.

먼저 스프링 어플리케이션 컨텍스트에 `AspectJSecurityInterceptor`를 설정하는 방법을 알아보자:

```xml
<bean id="bankManagerSecurity" class=
    "org.springframework.security.access.intercept.aspectj.AspectJMethodSecurityInterceptor">
<property name="authenticationManager" ref="authenticationManager"/>
<property name="accessDecisionManager" ref="accessDecisionManager"/>
<property name="afterInvocationManager" ref="afterInvocationManager"/>
<property name="securityMetadataSource">
    <sec:method-security-metadata-source>
    <sec:protect method="com.mycompany.BankManager.delete*" access="ROLE_SUPERVISOR"/>
    <sec:protect method="com.mycompany.BankManager.getBalance" access="ROLE_TELLER,ROLE_SUPERVISOR"/>
    </sec:method-security-metadata-source>
</property>
</bean>
```

보이는 바와 같이 클래스 명만 제외하면 `AspectJSecurityInterceptor`는 AOP Alliance 보안 인터셉터와 완전히 동일하다. 사실 `SecurityMetadataSource`는 AOP 라이브러리에 있는 클래스가 아닌 `java.lang.reflect.Method`로 동작하기 때문에, 두 인터셉터에 같은 `securityMetadataSource`를 공유하는 것도 가능하다. 물론 접근 권한을 결정할 땐 관련 AOP 라이브러리 전용 invocation을 (ie `MethodInvocation` 또는 `JoinPoint`) 사용하기 때문에, 다양한 추가 기준도 고려해서 결정할 수 있다 (메소드 인자 등).

다음은 AspectJ `aspect`를 정의해야 한다. 예를 들어:

```java
package org.springframework.security.samples.aspectj;

import org.springframework.security.access.intercept.aspectj.AspectJSecurityInterceptor;
import org.springframework.security.access.intercept.aspectj.AspectJCallback;
import org.springframework.beans.factory.InitializingBean;

public aspect DomainObjectInstanceSecurityAspect implements InitializingBean {

    private AspectJSecurityInterceptor securityInterceptor;

    pointcut domainObjectInstanceExecution(): target(PersistableEntity)
        && execution(public * *(..)) && !within(DomainObjectInstanceSecurityAspect);

    Object around(): domainObjectInstanceExecution() {
        if (this.securityInterceptor == null) {
            return proceed();
        }

        AspectJCallback callback = new AspectJCallback() {
            public Object proceedWithObject() {
                return proceed();
            }
        };

        return this.securityInterceptor.invoke(thisJoinPoint, callback);
    }

    public AspectJSecurityInterceptor getSecurityInterceptor() {
        return securityInterceptor;
    }

    public void setSecurityInterceptor(AspectJSecurityInterceptor securityInterceptor) {
        this.securityInterceptor = securityInterceptor;
    }

    public void afterPropertiesSet() throws Exception {
        if (this.securityInterceptor == null)
            throw new IllegalArgumentException("securityInterceptor required");
        }
    }
}
```

위 예시에선 보안 인터셉터는 모든 `PersistableEntity` 인스턴스에 적용되며, `PersistableEntity`는 위에 나타나있지 않지만 추상 클래스다. (원하는 다른 클래스나 `pointcut` 표현식을 사용해도 된다). 궁금할까봐 말하자면, `AspectJCallback`은 `proceed();` 구문은 `around()` 본문 내에 있을 때만 특별한 의미를 갖기 때문에 필요하다. `AspectJSecurityInterceptor`는 타겟 객체를 계속 이어가려면 이 익명 `AspectJCallback` 클래스를 실행한다.

스프링이 이 aspect를 로드하고 `AspectJSecurityInterceptor`와 연결할 수 있도록 설정을 추가해야 한다. 이를 위한 빈 정의는 아래에 있다:

```xml
<bean id="domainObjectInstanceSecurityAspect"
    class="security.samples.aspectj.DomainObjectInstanceSecurityAspect"
    factory-method="aspectOf">
<property name="securityInterceptor" ref="bankManagerSecurity"/>
</bean>
```

이게 전부다! 이제 어플리케이션 내 어디든지 적합하다고 생각하는 방법으로 (eg. `new Person();`) 빈을 만들 수 있으며, 그 빈에는 시큐리티 인터셉터가 적용될 거다.

---

## 11.5. Method Security

2.0 버전 이후 스프링 시큐리티는 서비스 레이어 메소드를 보호하기 위한 기능을 대폭 개선했다. 프레임워크의 기존 `@Secured` 애노테이션 외에 JSR-250 애노테이션도 지원한다. 3.0부터는 새로운 [표현식 기반 애노테이션](#113-expression-based-access-control)도 사용할 수 있다. 원하는 빈을 선언한 곳을 `intercept-methods` 요소로 장식하면 단일 빈을 보호할 수도 있고, AspectJ 스타일 포인트컷으로 서비스 레이어 전체에 걸친 빈을 보호할 수도 있다.

### 11.5.1. EnableGlobalMethodSecurity

`@Configuration` 인스턴스 중 아무곳에나 `@EnableGlobalMethodSecurity` 애노테이션을 붙이면 애노테이션 기반 보안 기능을 활성화할 수 있다. 예를 들어 아래 코드는 스프링 시큐리티의 `@Secured` 애노테이션을 활성화한다.

```java
@EnableGlobalMethodSecurity(securedEnabled = true)
public class MethodSecurityConfig {
// ...
}
```

메소드에 (클래스나 인터페이스에 있는) 애노테이션을 달면 이제 해당 메소드의 조건에 따라 접근을 제한할 것이다. 스프링 시큐리티의 네이티브 애노테이션은 메소드의 속성 셋을 정의한다. 이 값은 실제 결정을 내리는 `AccessDecisionManager`로 전달된다:

```java
public interface BankService {

@Secured("IS_AUTHENTICATED_ANONYMOUSLY")
public Account readAccount(Long id);

@Secured("IS_AUTHENTICATED_ANONYMOUSLY")
public Account[] findAccounts();

@Secured("ROLE_TELLER")
public Account post(Account account, double amount);
}
```

JSR-250 애노테이션은 다음과 같이 활성화할 수 있다.

```java
@EnableGlobalMethodSecurity(jsr250Enabled = true)
public class MethodSecurityConfig {
// ...
}
```

이는 표준을 따르며 간단한 role기반 제약 조건을 적용할 순 있지만, 스프링 시큐리티의 네이티브 애노테이션같은 기능은 없다. 새로운 표현식 기반 문법을 사용하려면 다음과 같이 작성해야 한다.

```java
@EnableGlobalMethodSecurity(prePostEnabled = true)
public class MethodSecurityConfig {
// ...
}
```

위와 동일한 자바 코드는 다음과 같다:

```java
public interface BankService {

@PreAuthorize("isAnonymous()")
public Account readAccount(Long id);

@PreAuthorize("isAnonymous()")
public Account[] findAccounts();

@PreAuthorize("hasAuthority('ROLE_TELLER')")
public Account post(Account account, double amount);
}
```

### 11.5.2. GlobalMethodSecurityConfiguration

`@EnableGlobalMethodSecurity` 애노테이션이 지원하는 것보다 더 복잡한 작업이 필요할 때도 있을 것이다. 이런 인스턴스는 `GlobalMethodSecurityConfiguration`을 확장해서 하위 클래스에도 `@EnableGlobalMethodSecurity` 애노테이션을 달아주면 된다. 예를 들어 커스텀 `MethodSecurityExpressionHandler`를 사용하고 싶다면 아래 설정을 사용할 수 있다:

```java
@EnableGlobalMethodSecurity(prePostEnabled = true)
public class MethodSecurityConfig extends GlobalMethodSecurityConfiguration {
    @Override
    protected MethodSecurityExpressionHandler createExpressionHandler() {
        // ... create and return custom MethodSecurityExpressionHandler ...
        return expressionHandler;
    }
}
```

재정의할 수 있는 메소드에 대한 자세한 정보는 `GlobalMethodSecurityConfiguration` Javadoc을 참고해라.

### 11.5.3. The \<global-method-security\> Element

이 요소는 애노테이션 기반 보안을 활성화하며 (요소에 적절한 속성을 설정해서), 어플리케이션 컨텍스트 전역에 적용할 포인트컷 선언을 함께 묶을 때도 사용한다. `<global-method-security>` 요소 하나만 선언하면 된다. 아래 선언문은 스프링 시큐리티의 `@Secured` 지원을 활성화한다:

```xml
<global-method-security secured-annotations="enabled" />
```

메소드에 (클래스나 인터페이스에 있는) 애노테이션을 달면 이제 해당 메소드의 조건에 따라 접근을 제한할 것이다. 스프링 시큐리티의 네이티브 애노테이션은 메소드의 속성 셋을 정의한다. 이 값은 실제 결정을 내리는 `AccessDecisionManager`로 전달된다:

```java
public interface BankService {

@Secured("IS_AUTHENTICATED_ANONYMOUSLY")
public Account readAccount(Long id);

@Secured("IS_AUTHENTICATED_ANONYMOUSLY")
public Account[] findAccounts();

@Secured("ROLE_TELLER")
public Account post(Account account, double amount);
}
```

JSR-250 애노테이션은 다음과 같이 활성화할 수 있다.

```xml
<global-method-security jsr250-annotations="enabled" />
```

이는 표준을 따르며 간단한 role기반 제약 조건을 적용할 순 있지만, 스프링 시큐리티의 네이티브 애노테이션같은 기능은 없다. 새로운 표현식 기반 문법을 사용하려면 다음과 같이 작성해야 한다.

```xml
<global-method-security pre-post-annotations="enabled" />
```

위와 동일한 자바 코드는 다음과 같다:

```java
public interface BankService {

@PreAuthorize("isAnonymous()")
public Account readAccount(Long id);

@PreAuthorize("isAnonymous()")
public Account[] findAccounts();

@PreAuthorize("hasAuthority('ROLE_TELLER')")
public Account post(Account account, double amount);
}
```

사용자의 권한 리스트로 role 이름을 확인하는 것 외에 다른 규칙을 간단하게 정의해야 한다면 표현식 기반 애노테이션을 사용하는 게 좋다.

> 애노테이션을 붙인 메소드는 스프링 빈으로 정의한 (메소드 시큐리티가 활성화된 어플리케이션 컨텍스트 내에 있는) 인스턴스일 때만 보안이 적용된다. 스프링이 생성하지 않는 인스턴스를 (예를 들어 `new` 연산자로 생성한 인스턴스) 보호하고 싶다면 AspectJ를 사용해야 한다.

>  어플리케이션 내에선 애노테이션 유형을 여러 개 활성화해도 되지만, 특정 인터페이스나 클래스에는 한 가지 유형만 적용해야 한다. 그렇지 않으면 의도한 대로 정의되지 않을 것이다. 메소드 하나에서 두 애노테이션을 발견하면 둘 중 하나만 적용한다.

### 11.5.4. Adding Security Pointcuts using protect-pointcut

`protect-pointcut`은 좀 더 강력한 기능을 제공하는데, 간단한 선언문 하나만으로도 많은 빈을 보호할 수 있다. 다음 예제를 생각해 보자:

```xml
<global-method-security>
<protect-pointcut expression="execution(* com.mycompany.*Service.*(..))"
    access="ROLE_USER"/>
</global-method-security>
```

여기선 어플리케이션 컨텍스트에 선언한 빈 중 `com.mycompany` 패키지에 있으며 "Service"로 끝나는 클래스의 모든 메소드를 보호한다. `ROLE_USER` role이 있는 사용자만 이 메소드를 실행할 수 있다. URL 매칭과 마찬가지로, 첫 번째로 매칭되는 표현식을 사용하기 때문에 가장 구체적인 조건이 앞에 있어야 한다. 시큐리티 애노테이션이 포인트컷보다 우선시된다.

---

## 11.6. Domain Object Security (ACLs)

### 11.6.1. Overview

복잡한 어플리케이션은 단순히 웹 요청이나 메소드 실행 단위로 접근 권한을 관리할 수 없을 때도 있다. 대신에 누가 (`Authentication`), 언제 (`MethodInvocation`) 무엇을 (`SomeDomainObject`)을 하는가를 전부 고려해야 한다. 다시 말해 메소드를 실행하는 실제 도메인 객체 인스턴를 고려해서 인가 여부를 결정해야 한다.

동물 병원에서 필요한 어플리케이션을 설계한다고 생각해보자. 스프링 기반 어플리케이션에서 사용할 사용자는 크게 동물 병원 직원과 손님으로 나뉜다. 직원은 모든 데이터에 접근할 수 있지만 손님은 본인의 기록만 볼 수 있다. 조금 더 재미 있게, 손님은 "강아지 유치원" 멘토나 지역 "포니 클럽" 회장같은 자신의 기록을 다른 사용자도 볼 수 있게 만들 수 있다고 해보자. 스프링 시큐리티를 기반으로 만든다면 고려해볼 수 있는 옵션이 몇 가지 있다:

- 비지니스 메소드에 보안 로직을 작성한다. `Customer` 도메인 객체 인스턴스 안에 있는 컬렉션을 참조해서 어떤 사용자가 권한이 있는지 결정할 수 있다.  `SecurityContextHolder.getContext().getAuthentication()`을 사용해서 `Authentication` 객체에 접근한다.
- `Authentication` 객체에 저장된 `GrantedAuthority[]`를 사용하는 `AccessDecisionVoter`를 만든다. 이 말은 `AuthenticationManager`에서 `Authentication`에 princial이 접근할 수 있는 각 `Customer` 도메인 객체 인스턴스를 의미하는 커스텀 `GrantedAuthority[]`를 채워 넣어야 한다는 뜻이다.
- `AccessDecisionVoter`가 타겟 `Customer` 도메인 객체를 직접 열도록 만든다. 이 말은 voter에서 DAO에 접근해 `Customer` 객체를 가져와야 한다는 뜻이다. 그러면 voter는 `Customer` 객체의 승인된 사용자 컬렉션에 접근해서 그에 따른 결정을 내릴 것이다.

여기 있는 해결책 모두 정당한 방법이다. 하지만 첫 번째 방법은 인가 권한 확인 로직과 비지니스 코드의 결합도가 올라간다. 이로 인한 주요 문제점은 단위 테스트가 어려워지며, `Customer` 인가 로직을 어디에도 재사용하기 어렵다는 것이다. `Authentication` 객체에서 `GrantedAuthority[]`를 가져오는 것도 괜찮지만, `Customer`가 많아지면 확장하기 어렵다. 사용자가 5000명의 `Customer`에 접근할 수 있다면 (불가능할 것 같지만, 대형 포니 클럽의 유명한 수의사라고 생각해보라!), `Authentication` 객체를 구성하는데 그만큼의 메모리와 시간이 필요하며, 이는 결코 바람직한 일이 아니다. 세 번째 방법은 외부 코드에서 직접 `Customer`를 열기 때문에 이 셋 중엔 가장 나은 방법처럼 보인다. 관심사를 분리했고, 메모리나 CPU 사이클을 낭비하진 않지만, `AccessDecisionVoter`와 마지막 비지니스 메소드 자체에서 `Customer` 객체를 가져오는 DAO를 호출한다는 점은 여전히 비효율적이다. 메소드를 호출할 때마다 두번씩 접근하는 건 분명히 바람직하지 않다. 게다가 여기 있는 모든 방법은 접근 제어 리스트(access control list, ACL) 저장 로직과 비지니스 로직을 직접 처음부터 작성해야 한다.

다행히도 다른 방법이 하나 더 있는데, 아래에서 이야기할 것이다.

### 11.6.2. Key Concepts

스프링 시큐리티의 ACL 서비스는 `spring-security-acl-xxx.jar`에 실려있다. 스프링 시큐리티의 도메인 객체 인스턴스 보안 기능을 사용하려면 이 JAR를 클래스패스에 포함시켜야 한다.

스프링 시큐리티의 도메인 객체 인스턴스 보안 기능의 중심은 바로 접근 제어 목록(ACL)에 있다. 시스템 내 에 있는 모든 도메인 객체 인스턴스는 자신의 ACL을 가지며, ACL은 누가 그 객체에 접근할 수 있고 없는지에 대한 정보를 가지고 있다. 이를 염두에 두고, 이제 스프링 시큐리티가 제공하는 세 가지 핵심 ACL 관련 기능을 살펴보자:

- 모든 도메인 객체의 ACL 엔트리를 효율적으로 조회하는 기능 (이 ACL들을 수정하는 기능도 포함)
- 메소드를 호출하기 전에 principal이 해당 객체로 작업을 수행할 권한이 있는지 확인하는 기능
- 메소드를 호출한 후에 principal이 해당 객체로 (아니면 그 객체가 리턴한 값으로) 작업을 수행할 권한이 있는지 확인하는 기능

첫 번째 기능에서 알 수 있듯이, 스프링 시큐리티 ACL 모듈의 핵심 기능 중 하나는 ACL을 빠르게 조회하는 것이다. 이 ACL 저장소 기능은 매우 중요한 것 중 하나인데, 모든 도메인 객체 인스턴스는 접근 제어 엔트리를 여러 개 가질 것이고, 각 ACL은 트리같은 구조로 다른 ACL들을 상속기 때문에 그렇다 (매우 흔하게 사용하는 패턴이고, 스프링 시큐리티도 기본적으로 지원한다). 스프링 시큐리티의 ACL 기능은 ACL 고성능 검색 외에도, 플러그인처럼 쉽게 사용할 수 있는 캐시, 데드락을 최소화한 데이터베이스 업데이트, ORM 프레임워크와의 독립성 (직접 JDBC를 사용한다), 적절한 캡슐화, 투명한 데이터베이스 업데이트를 함께 고려해서 설계했다.

데이터베이스가 ACL 모듈 작동의 중심에 있으므로, 구현체에서 디폴트로 사용하는 네 가지 메인 테이블을 살펴보겠다. 다음은 전형적인 스프링 시큐리티 ACL에서 사용하는 테이블이며, 밑으로 갈수록 로우(row)가 많은 테이블이다:

- ACL_SID는 시스템 내 모든 principal 또는 권한을 식별할 수 있게 해준다 ("SID"는 "security identity"를 나타낸다). 컬럼은 SID를 나타내는 텍스트인 ID와, 이 텍스트가 principal 이름인지 `GrantedAuthority`인지를 나타내는 플래그 둘 뿐이다. 따라서 각 principal 또는 `GrantedAuthority`마다 로우(row)를 한 개씩 갖는다. permission을 조회하는 용도로 사용할 땐 SID를 보통 "recipient"라고 부른다.
- ACL_CLASS는 시스템 내 모든 도메인 객체 클래스를 식별할 수 있게 해준다. 컬럼은 ID와 자바 클래스명 둘 뿐이다. 따라서 ACL permission을 저장할 각 클래스 당 로우를 한 개씩 갖는다.
- ACL_OBJECT_IDENTITY는 시스템 내 각 유니크한 도메인 객체 인스턴스 정보를 저장한다. 컬럼은 ID와, ACL_CLASS 테이블에 대한 외래키, 어떤 ACL_CLASS 인스턴스 정보를 제공하는지 알 수 있는 유니크 식별자, ACL_CLASS 테이블에 대한 외래키, parent, 도메인 객체 인스턴스의 소유자를 나타내는 ACL_SID 테이블에 대한 외래키, ACL 엔트리가 다른 부모 ACL을 상속할 수 있는지를 나타내는 값이 있다. ACL permission을 저장하는 모든 도메인 객체 인스턴스마다 로우가 한 개씩 있다.
- 마지막으로 ACL_ENTRY는 각 recipient에 할당된 각 permission을 저장한다. 컬럼은 ACL_OBJECT_IDENTITY에 대한 외래키, recipient (ie ACL_SID에 대한 외래키), 감사(auditing) 여부, 실제 permission을 허가하는지 거부하는지를 나타내는 정수 비트 마스크가 있다. 특정 도메인 객체에 permission을 받은 모든 recipient마다 로우가 한 개씩 있다.

마지막 테이블에서 언급했지만, ACL 시스템은 정수 비트 마스킹을 사용한다. ACL 시스템을 사용한다고 해서 비트 시프트를 잘 알아야 하는 것은 아니므로 걱정하지 않아도 된다. 32비트를 끄고 킨다는 게 뭔지만 이해한다면 충분하다. 각 비트는 permission을 나타내며, 기본적으로 0비트는 read, 1비트는 write, 2비트는 create, 3비트는 delete, 4비트는 관리자 permission을 의미한다. 다른 permission을 사용하고 싶으면 쉽게 자체 `Permission` 인스턴스를 구현할 수 있으며, 나머지 ACL 프레임워크 코드는 해당 구현체를 알지 못해도 잘 동작할 것이다.

시스템 내에 있는 도메인 객체 수는 정수 비트 마스크를 사용하기로 한 것과는 아무 상관 없다는 것을 이해해야 한다. permission은 32비트로 표현할 수 있지만, 도메인 객체는 수십억 개가 있을 수도 있다 (ACL_OBJECT_IDENTITY와 ACL_ENTRY 로우가 수십억개가 될 수 있다는 뜻이다). 도메인 객체마다 비트가 하나씩 필요하다고 오해하는 사람들이 가끔 있어서 짚고 넘어가는데, 이는 잘못된 생각이다.

ACL 시스템이 하는 일과 테이블 구조에 대해 기본적인 내용은 설명했으므로, 이제 핵심 인터페이스를 설명한다. 핵심 인터페이스는 다음과 같다:

- `Acl`: 모든 도메인 객체는 `Acl` 객체를 딱 하나씩 가진다. `Acl`은 내부적으로 `AccessControlEntry`들을 가지고 있으며, `Acl` 소유자가 누군지 알고 있다. Acl이 도메인 객체를 직접 참조하진 않고, 대신 `ObjectIdentity`를 참조한다. 이 `Acl`은 ACL_OBJECT_IDENTITY 테이블에 저장한다.
- `AccessControlEntry`: `Acl`은 여러 `AccessControlEntry`를 가지고 있으며, 프레임워크에선 `AccessControlEntry`를 종종 ACE로 표현한다. 각 ACE는 `Permission`, `Sid`, `Acl` 튜플을 참조한다. ACE는 허가 또는 비허가일 수 있으며 감사 설정을 가지고 있다. ACE는 ACL_ENTRY 테이블에 저장한다.
- `Permission`: permission은 특정 불변(immutable) 비트 마스크를 나타내며, 비트 마스킹이나 정보 출력 등 편리한 함수를 제공한다. 위에서 설명한 기본 permission은 (0~4 비트) `BasePermission` 클래스에 있다.
- `Sid`: ACL 모듈은 principal과 `GrantedAuthority[]`를 참조해야 한다. "security identity"를 나타내는 `Sid` 인터페이스로 간접적으로 접근할 수 있다. 주로 사용하는 클래스는 `PrincipalSid`와 (`Authentication` 객체 안에 있는 principal을 나타냄), `GrantedAuthoritySid`가 있다. 이 보안 식별 정보는 ACL_SID 테이블에 저장한다.
- `ObjectIdentity`: ACL 모듈 내부에선 `ObjectIdentity`로 각 도메인 객체를 표현한다. 디폴트 구현체는 `ObjectIdentityImpl`이다.
- `AclService`: 주어진 `ObjectIdentity`에 적용할 수 있는 `Acl`을 검색한다. 기본으로 제공하는 구현체는 (`JdbcAclService`) `LookupStrategy`에 검색 연산을 위임한다. `LookupStrategy`는 검색을 배치로 처리하며 (`BasicLookupStrategy`), 구체화 뷰(materialized views), 계층구조 쿼리(hierarchical queries)와, 유사한 성능 중심 non-ANSI SQL 기능을 위한 커스텀 구현체를 지원하는 등, ACL 정보를 검색하기 위한 최적화된 전략을 제공한다.
- `MutableAclService`: `Acl`을 수정해서 저장할 수 있다. 필요하지 않다면 이 인터페이스는 사용하지 않아도 된다.

즉시 사용할 수 있는 AclService와 관련 데이터베이스 클래스는 모두 ANSI SQL을 사용한다는 점에 주의해라. 따라서 주요 데이터베이스에서는 모두 동작할 것이다. 이 글을 쓰는 시점에는 Hypersonic SQL, PostgreSQL, Microsoft SQL Server, Oracle로 테스트를 완료했다.

스프링 시큐리티는 ACL 모듈을 사용하는 두 가지 샘플을 제공한다. Contacts 샘플과 Document Management System (DMS) 샘플이다. 이 샘플을 살펴보길 추천한다.

### 11.6.3. Getting Started

스프링 시큐리티의 ACL 기능을 사용하려면, 어딘가엔 ACL 정보를 저장해야 한다. 즉 스프링을 사용하는 `DataSource` 인스턴스가 필요하다. 그러면 `DataSource`를 `JdbcMutableAclService`, `BasicLookupStrategy` 인스턴스에 주입한다. 후자는 고성능 ACL 검색 기능, 전자는 수정 기능을 제공한다. 설정 예시는 스프링 시큐리티가 함께 제공하는 샘플 중 하나를 참고하라. 또한 마지막 섹션에 있는 ACL 관련 테이블 4개를 데이터베이스에 추가해야 한다 (적당한 SQL 문은 ACL 샘플 참고).

필요한 스키마와 `JdbcMutableAclService` 인스턴스를 만들었다면, 도메인 모델이 스프링 시큐리티 ACL 패키지와 호환되는지를 확인해야 한다. `ObjectIdentityImpl`은 다양하게 사용할 수 있으므로, 아마 이것 만으로 충분할 것이다. 도메인 객체엔 대부분 `public Serializable getId()` 메소드가 있을 것이다. 리턴 타입이 long이거나 long과 호환되는 경우엔 (eg int), `ObjectIdentity` 문제는 더 이상 생각하지 않아도 된다. ACL 모듈은 많은 곳에서 long 식별자를 사용한다. long (또는 int, byte 등)을 사용하지 않는 다면 클래스를 대량 다시 구현해야 할 가능성이 높다. long은 이미 모든 데이터베이스 시퀀스와 호환되고, 가장 많이 사용하는 식별자 데이터 타입이며, 일반적인 사용 시나리오에서 전부 수용할 수 있는 길이이므로, 스프링 시큐리티의 ACL 모듈은 long 이외의 식별자를 지원하지 않는다.

다음 코드는 `Acl`을 만들고 기존 `Acl`을 수정하는 방법을 보여준다:

```java
// Prepare the information we'd like in our access control entry (ACE)
ObjectIdentity oi = new ObjectIdentityImpl(Foo.class, new Long(44));
Sid sid = new PrincipalSid("Samantha");
Permission p = BasePermission.ADMINISTRATION;

// Create or update the relevant ACL
MutableAcl acl = null;
try {
acl = (MutableAcl) aclService.readAclById(oi);
} catch (NotFoundException nfe) {
acl = aclService.createAcl(oi);
}

// Now grant some permissions via an access control entry (ACE)
acl.insertAce(acl.getEntries().length, p, sid, true);
aclService.updateAcl(acl);
```

위 예제에선 식별 숫자가 44인 "Foo" 도메인 객체와 관련된 ACL을 검색한다. 그다음 "Samantha"란 이름을 가진 principal이 해당 객체를 "관리"할 수 있게 ACE를 추가한다. 이 코드는 insertAce 메소드만 제외하면 따로 설명할 필요가 없다. insertAce 메소드의 첫 번째 인자는 새 엔트리를 추가할 Acl 상의 위치를 나타낸다. 위 예제에선 단순히 기존 ACE 목록 끝에 새 ACE를 추가하고 있다. 마지막 인자는 ACE 허가인지 거부인지를 나타내는 Boolean 값인다. 대부분은 허가이겠지만 (true), 거절이었다면 (false) 사실상 permission을 막는다.

스프링 시큐리티는 ACL 생성, 수정, 삭제 기능을 DAO나 레포지토리 연산의 일부로 자동으로 통합해주지 않는다. 따라서 각 도메인 객체마다 위와 같은 코드를 작성해야 한다. 서비스 레이어에 AOP를 적용해서, 서비스 레이어 작업에 자동으로 ACL 정보를 통합하는 걸 고려해볼만 하다. 우린 이 방법이 꽤 효과가 있었다.

위에 있는 방법을 사용해서 데이터베이스에 ACL 정보를 저장했다면, 이제 실제로 인가 결정 로직에 ACL 정보를 사용하는 일이 남았다. 여기에는 여러 가지 선택 사항이 있다. 메소드 호출 전후에 각각 호출할 `AccessDecisionVoter`나 `AfterInvocationProvider`를 직접 만들 수도 있다. 이 클래스는 `AclService`로 관련 ACL을 검색한 다음 `Acl.isGranted(Permission[] permission, Sid[] sids, boolean administrativeMode)`를 호출해서 권한을 부여할지 말지 결정한다. 아니면 `AclEntryVoter`나 `AclEntryAfterInvocationProvider`, `AclEntryAfterInvocationCollectionFilteringProvider` 클래스를 사용하는 방법도 있다. 이 클래스들은 모두 런타임에 ACL 정보를 평가하는 선언적인(declarative) 접근법을 제공하므로 코드를 작성하지 않아도 된다. 이 클래스들을 어떻게 사용하면 되는지 알아 보려면 샘플 어플리케이션을 참고해라.
