---
title: Authentication
category: Spring Security
order: 11
permalink: /Spring%20Security/authentication/
description: 서블릿 기반 어플리케이션에서 스프링 시큐리티의 인증(authentication)을 적용하는 방법
image: ./../../images/springsecurity/securitycontextholder.png
lastmod: 2020-08-08T10:00:00+09:00
comments: true
---
<script>defaultLanguages = ['java', 'maven']</script>

> [스프링 시큐리티 공식 레퍼런스](https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#servlet-authentication)를 한글로 번역한 문서입니다.
>
> 전체 목차는 [여기](../contents/)에 있습니다.

{% include adsense.html %}

### 목차:

- [10.1. SecurityContextHolder](#101-securitycontextholder)
- [10.2. SecurityContext](#102-securitycontext)
- [10.3. Authentication](#103-authentication)
- [10.4. GrantedAuthority](#104-grantedauthority)
- [10.5. AuthenticationManager](#105-authenticationmanager)
- [10.6. ProviderManager](#106-providermanager)
- [10.7. AuthenticationProvider](#107-authenticationprovider)
- [10.8. Request Credentials with AuthenticationEntryPoint](#108-request-credentials-with-authenticationentrypoint)
- [10.9. AbstractAuthenticationProcessingFilter](#109-abstractauthenticationprocessingfilter)
- [10.10. Username/Password Authentication](#1010-usernamepassword-authentication)
  + [10.10.1. Form Login](#10101-form-login)
  + [10.10.2. Basic Authentication](#10102-basic-authentication)
  + [10.10.3. Digest Authentication](#10103-digest-authentication)
  + [10.10.4. In-Memory Authentication](#10104-in-memory-authentication)
  + [10.10.5. JDBC Authentication](#10105-jdbc-authentication)
    * [Default Schema](#default-schema)
    * [Setting up a DataSource](#setting-up-a-datasource)
    * [JdbcUserDetailsManager Bean](#jdbcuserdetailsmanager-bean)
  + [10.10.6. UserDetails](#10106-userdetails)
  + [10.10.7. UserDetailsService](#10107-userdetailsservice)
  + [10.10.8. PasswordEncoder](#10108-passwordencoder)
  + [10.10.9. DaoAuthenticationProvider](#10109-daoauthenticationprovider)
  + [10.10.10. LDAP Authentication](#101010-ldap-authentication)
    * [Prerequisites](#prerequisites)
    * [Setting up an Embedded LDAP Server](#setting-up-an-embedded-ldap-server)
    * [Authentication](#authentication)
    * [Using Bind Authentication](#using-bind-authentication)
    * [Using Password Authentication](#using-password-authentication)
    * [LdapAuthoritiesPopulator](#ldapauthoritiespopulator)
    * [Active Directory](#active-directory)
- [10.11. Session Management](#1011-session-management)
  + [10.11.1. Detecting Timeouts](#10111-detecting-timeouts)
  + [10.11.2. Concurrent Session Control](#10112-concurrent-session-control)
  + [10.11.3. Session Fixation Attack Protection](#10113-session-fixation-attack-protection)
  + [10.11.4. SessionManagementFilter](#10114-sessionmanagementfilter)
  + [10.11.5. SessionAuthenticationStrategy](#10115-sessionauthenticationstrategy)
  + [10.11.6. Concurrency Control](#10116-concurrency-control)
    * [Querying the SessionRegistry for currently authenticated users and their sessions](#querying-the-sessionregistry-for-currently-authenticated-users-and-their-sessions)
- [10.12. Remember-Me Authentication](#1012-remember-me-authentication)
  + [10.12.1. Overview](#10121-overview)
  + [10.12.2. Simple Hash-Based Token Approach](#10122-simple-hash-based-token-approach)
  + [10.12.3. Persistent Token Approach](#10123-persistent-token-approach)
  + [10.12.4. Remember-Me Interfaces and Implementations](#10124-remember-me-interfaces-and-implementations)
    * [TokenBasedRememberMeServices](#tokenbasedremembermeservices)
    * [PersistentTokenBasedRememberMeServices](#persistenttokenbasedremembermeservices)
- [10.13. OpenID Support](#1013-openid-support)
  + [10.13.1. Attribute Exchange](#10131-attribute-exchange)
- [10.14. Anonymous Authentication](#1014-anonymous-authentication)
  + [10.14.1. Overview](#10141-overview)
  + [10.14.2. Configuration](#10142-configuration)
  + [10.14.3. AuthenticationTrustResolver](#10143-authenticationtrustresolver)
- [10.15. Pre-Authentication Scenarios](#1015-pre-authentication-scenarios)
  + [10.15.1. Pre-Authentication Framework Classes](#10151-pre-authentication-framework-classes)
    * [AbstractPreAuthenticatedProcessingFilter](#abstractpreauthenticatedprocessingfilter)
    * [PreAuthenticatedAuthenticationProvider](#preauthenticatedauthenticationprovider)
    * [Http403ForbiddenEntryPoint](#http403forbiddenentrypoint)
  + [10.15.2. Concrete Implementations](#10152-concrete-implementations)
    * [Request-Header Authentication (Siteminder)](#request-header-authentication-siteminder)
    * [Java EE Container Authentication](#java-ee-container-authentication)
- [10.16. Java Authentication and Authorization Service (JAAS) Provider](#1016-java-authentication-and-authorization-service-jaas-provider)
  + [10.16.1. Overview](#10161-overview)
  + [10.16.2. AbstractJaasAuthenticationProvider](#10162-abstractjaasauthenticationprovider)
    * [JAAS CallbackHandler](#jaas-callbackhandler)
    * [JAAS AuthorityGranter](#jaas-authoritygranter)
  + [10.16.3. DefaultJaasAuthenticationProvider](#10163-defaultjaasauthenticationprovider)
    * [InMemoryConfiguration](#inmemoryconfiguration)
    * [DefaultJaasAuthenticationProvider Example Configuration](#defaultjaasauthenticationprovider-example-configuration)
  + [10.16.4. JaasAuthenticationProvider](#10164-jaasauthenticationprovider)
  + [10.16.5. Running as a Subject](#10165-running-as-a-subject)
- [10.17. CAS Authentication](#1017-cas-authentication)
  + [10.17.1. Overview](#10171-overview)
  + [10.17.2. How CAS Works](#10172-how-cas-works)
    * [Spring Security and CAS Interaction Sequence](#spring-security-and-cas-interaction-sequence)
  + [10.17.3. Configuration of CAS Client](#10173-configuration-of-cas-client)
    * [Service Ticket Authentication](#service-ticket-authentication)
    * [Single Logout](#single-logout)
    * [Authenticating to a Stateless Service with CAS](#authenticating-to-a-stateless-service-with-cas)
    * [Proxy Ticket Authentication](#proxy-ticket-authentication)
- [10.18. X.509 Authentication](#1018-x509-authentication)
  + [10.18.1. Overview](#10181-overview)
  + [10.18.2. Adding X.509 Authentication to Your Web Application](#10182-adding-x509-authentication-to-your-web-application)
  + [10.18.3. Setting up SSL in Tomcat](#10183-setting-up-ssl-in-tomcat)
- [10.19. Run-As Authentication Replacement](#1019-run-as-authentication-replacement)
  + [10.19.1. Overview](#10191-overview)
  + [10.19.2. Configuration](#10192-configuration)
- [10.20. Handling Logouts](#1020-handling-logouts)
  + [10.20.1. Logout Java Configuration](#10201-logout-java-configuration)
  + [10.20.2. Logout XML Configuration](#10202-logout-xml-configuration)
  + [10.20.3. LogoutHandler](#10203-logouthandler)
  + [10.20.4. LogoutSuccessHandler](#10204-logoutsuccesshandler)
  + [10.20.5. Further Logout-Related References](#10205-further-logout-related-references)
- [10.21. Authentication Events](#1021-authentication-events)
  + [10.21.1. Adding Exception Mappings](#10211-adding-exception-mappings)
  + [10.21.2. Default Event](#10212-default-event)

---

스프링 시큐리티는 [인증](../features#51-authentication)을 종합적으로 지원한다. 이번 섹션에서 다루는 내용은 다음과 같다:

#### Architecture Components

이 섹션에선 서블릿 인증에서 사용하는 스프링 시큐리티의 주요 아키텍처 컴포넌트를 설명한다. 이 컴포넌트가 어떻게 함께 동작하는지 구체적인 플로우를 그려보고 싶다면 [Authentication Mechanism](#authentication-mechanisms) 섹션을 참고하라.

- [SecurityContextHolder](#101-securitycontextholder) - 스프링 시큐리티에서 [인증한](../features#51-authentication) 대상에 대한 상세 정보는 `SecurityContextHolder`에 저장한다.
- [SecurityContext](#102-securitycontext) - `SecurityContextHolder`로 접근할 수 있으며 현재 인증한 사용자의  `Authentication`을 가지고 있다.
- [Authentication](#103-authentication) - 사용자가 제공한 인증용 credential이나 `SecurityContext`에 있는 현재 사용자의 credential을 제공하며, `AuthenticationManager`의 입력으로 사용한다.
- [GrantedAuthority](#104-grantedauthority) - `Authentication`에서 접근 주체(principal)에 부여한 권한 (i.e. roles, scopes 등.)
- [AuthenticationManager](#105-authenticationmanager) - 스프링 시큐리티의 필터가 [인증](../features#51-authentication)을 어떻게 수행할지를 정의하는 API.
- [ProviderManager](#106-providermanager) - 가장 많이 사용하는 `AuthenticationManager` 구현체.
- [AuthenticationProvider](#107-authenticationprovider) - `ProviderManager`가 특정 인증 유형을 수행할 때 사용한다.
- [Request Credentials with `AuthenticationEntryPoint`](#108-request-credentials-with-authenticationentrypoint) - 클라이언트에 credential을 요청할 때 사용한다. (i.e. 로그인 페이지로 리다이렉트하거나 `WWW-Authenticate` 헤더를 전송하는 등)
- [AbstractAuthenticationProcessingFilter](#109-abstractauthenticationprocessingfilter) - 인증에 사용할 `Filter`의 베이스. 필터를 잘 이해하면 여러 컴포넌트를 조합해서 심도 있는 인증 플로우를 구성할 수 있다.

#### Authentication Mechanisms

- [Username and Password](#1010-usernamepassword-authentication) - 사용자 이름/비밀번호로 인증하는 방법
- [OAuth 2.0 Login](https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#oauth2login) - OpenID Connect를 사용한 OAuth 2.0 로그인과 비표준 OAuth 2.0 로그인 (i.e. GitHub)
- [SAML 2.0 Login](https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#servlet-saml2) - SAML 2.0 로그인
- [Central Authentication Server (CAS)](#1017-cas-authentication) - Central Authentication Server (CAS) 지원
- [Remember Me](#1012-remember-me-authentication) - 세션이 만료된 사용자를 기억하는 방법
- [JAAS Authentication](#1016-java-authentication-and-authorization-service-jaas-provider) - JAAS를 사용한 인증
- [OpenID](#1013-openid-support) - OpenID 인증 (OpenID Connect와 혼동하지 말 것)
- [Pre-Authentication Scenarios](#1015-pre-authentication-scenarios) - 인증은 [SiteMinder](https://www.siteminder.com/)나 Java EE security 같은 외부 메커니즘으로 처리하면서 스프링 시큐리티로 권한 인가와 주요 취약점 공격을 방어할 수 있다.
- [X509 Authentication](#1018-x509-authentication) - X509 인증

---

## 10.1. SecurityContextHolder

스프링 시큐리티 인증 모델의 중심에는 `SecurityContextHolder`가 있다. 이 홀더는 [SecurityContext](#102-securitycontext)를 가지고 있다.

![SecurityContextHolder](./../../images/springsecurity/securitycontextholder.png)

`SecurityContextHolder`에는 스프링 시큐리티로 [인증](../features#51-authentication)한 사용자의 상세 정보를 저장한다. 스프링 시큐리티는 `SecurityContextHolder`에 어떻게 값을 넣는지는 상관하지 않는다. 값이 있다면 현재 인증한 사용자 정보로 사용한다.

사용자가 인증됐음을 나타내는 가장 쉬운 방법은 직접 `SecurityContextHolder`를 설정하는 것이다.

**Example 49. Setting `SecurityContextHolder`**

```java
SecurityContext context = SecurityContextHolder.createEmptyContext(); // (1)
Authentication authentication =
    new TestingAuthenticationToken("username", "password", "ROLE_USER"); // (2)
context.setAuthentication(authentication);

SecurityContextHolder.setContext(context); // (3)
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 비어있는 `SecurityContext`를 만드는 것으로 시작한다. 스레드 경합을 피하려면 `SecurityContextHolder.getContext().setAuthentication(authentication)`을 사용해선 안 되며, 새 `SecurityContext` 인스턴스를 생성해야 한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 그다음 새 [`Authentication`](#103-authentication) 객체를 생성한다. `Authentication` 구현체라면 전부 `SecurityContext`에 설정할 수 있다. 여기선 간단하게 `TestingAuthenticationToken`을 사용했다. 프로덕션 환경에선 `UsernamePasswordAuthenticationToken(userDetails, password, authorities)`를 주로 사용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 마지막으로 `SecurityContextHolder`에 `SecurityContext`를  설정해 준다. 스프링 시큐리티는 이 정보를 사용해서 권한을 [인가](../authentication)한다.</small>

인증된 주체(principal) 정보를 얻어야 한다면 `SecurityContextHolder`에 접근하면 된다.

**Example 50. Access Currently Authenticated User**

```java
SecurityContext context = SecurityContextHolder.getContext();
Authentication authentication = context.getAuthentication();
String username = authentication.getName();
Object principal = authentication.getPrincipal();
Collection<? extends GrantedAuthority> authorities = authentication.getAuthorities();
```

기본적으로 `SecurityContextHolder`는 `ThreadLocal`을 사용해서 정보를 저장하기 때문에 위 메소드에 `SecurityContext`를 넘기지 않아도 동일한 스레드에선 항상 `SecurityContext`에 접근할 수 있다. 기존 principal 요청을 처리한 다음에 비워주는 것만 잊지 않으면 `ThreadLocal`을 사용해도 안전하다. 스프링 시큐리티의 [FilterChainProxy](../servletsecuritythebigpicture#93-filterchainproxy)은 항상 `SecurityContext`를 비워준다.

어플리케이션의 스레드 처리 방식에 따라서 `ThreadLocal`이 전혀 적합하지 않을 때도 있다. 예를 들어 스윙 클라이언트에선 자바 가상머신에 있는 전체 스레드에서 보안 컨텍스트를 하나만 사용해야 할 수 있다. 이럴 때는 기동시점에 사용할 컨텍스트 저장 전략을 설정할 수 있다. standalone 어플리케이션에는 `SecurityContextHolder.MODE_GLOBAL` 전략을 적용할 수 있다. 인증 처리를 마친 스레드가 생성한 다른 스레드에서도 동일한 보안 컨텍스트를 사용해야 하는 어플리케이션이라면 `SecurityContextHolder.MODE_INHERITABLETHREADLOCAL`을 적용하면 된다. 디폴트 전략은 `SecurityContextHolder.MODE_THREADLOCAL`이며, 두 가지 방법으로 바꿀 수 있다. 첫 번째 방법은 시스템 프로퍼티를 설정하는 것이고, 두 번째 방법은 `SecurityContextHolder`에 있는 스태틱 메소드를 사용하는 것이다. 대부분은 디폴트 전략으로도 충분하지만, 바꿔야 한다면 `SecurityContextHolder` JavaDoc을 참고하라.

---

## 10.2. SecurityContext

[`SecurityContext`](https://docs.spring.io/spring-security/site/docs/current/api/org/springframework/security/core/context/SecurityContext.html)는 [SecurityContextHolder](#101-securitycontextholder)로 접근할 수 있다. `SecurityContext`는 [Authentication](#103-authentication) 객체를 가지고 있다.

---

## 10.3. Authentication

스프링 시큐리티에서 [`Authentication`](https://docs.spring.io/spring-security/site/docs/current/api/org/springframework/security/core/Authentication.html)이 주로 담당하는 일은 다음과 같다:

- [`AuthenticationManager`](#105-authenticationmanager)의 입력으로 사용되어 사용자가 제공한 인증용 credential을 제공한다. 이 시나리오에선 `isAuthenticated()`는 `false`를 리턴한다.
- 현재 인증된 사용자를 나타낸다. 현재 `Authentication`은 [SecurityContext](#102-securitycontext)에서 가져올 수 있다.

`Authentication`은 다음을 가지고 있다:

- `principal` - 사용자를 식별한다. 사용자 이름/비밀번호로 인증할 땐 보통 [`UserDetails`](#10106-userdetails) 인스턴스다.
- `credentials` - 주로 비밀번호. 대부분은 유출되지 않도록 사용자를 인증한 다음 비운다.
- `authorities` - 사용자에게 부여된 권한은 [`GrantedAuthority`](#104-grantedauthority)로 추상화한다.  예시로 roles나 scopes가 있다.

---

## 10.4. GrantedAuthority

사용자에게 부여된 권한은 [`GrantedAuthority`](#104-grantedauthority)로 추상화한다.  예시로 roles나 scopes가 있다.

`GrantedAuthority`는 [`Authentication.getAuthorities()`](#103-authentication) 메소드로 접근할 수 있다. 이 메소드는 `GrantedAuthority` 객체의 `Collection`을 리턴한다. `GrantedAuthority`는 말 그대로 주체(principal)에게 부여된 권한이다. 권한은 보통 `ROLE_ADMINISTRATOR`나 `ROLE_HR_SUPERVISOR`같은 "역할 (role)"이다. 이런 역할은 나중에 웹 인가, 메소드 인가, 도메인 객체 인가에서 설정한다. 스프링 시큐리티는 role을 해석하고 권한을 확인하는 기능도 지원한다. 이름/비밀번호 기반 인증을 사용한다면 보통 [`UserDetailsService`](#10107-userdetailsservice)가 `GrantedAuthority`를 로드한다.

`GrantedAuthority` 객체는 일반적으로 어플리케이션 전체에 걸친 권한을 의미한다. 특정 도메인 객체에 국한되지 않는다. 따라서 `Employee` 객체 번호 54의 권한을 나타내는 `GrantedAuthority`, 이런 식으로는 잘 쓰지 않는다. 이렇게 사용하면 권한을 수천 개 만들게 될 수도 있고 메모리가 부족해지기 십상이다 (그렇지 않더라도 최소한 사용자를 인증하는 시간이 길어진다). 물론, 스프링 시큐리티는 이런 일반적인 요구사항을 처리하도록 설계했지만, 원한다면 도메인 객체 보안을 적용할 수도 있다.

---

## 10.5. AuthenticationManager

[`AuthenticationManager`](https://docs.spring.io/spring-security/site/docs/current/api/org/springframework/security/authentication/AuthenticationManager.html)는 스프링 시큐리티 필터의 [인증](../features#51-authentication) 수행 방식을 정의하는 API다. 리턴한 [`Authentication`](#103-authentication)을 [SecurityContextHolder](#101-securitycontextholder)에 설정하는 건, `AuthenticationManager`를 호출한 컨트롤러 (i.e. [스프링 시큐리티의 필터](../servletsecuritythebigpicture#95-security-filters))가 담당한다. *스프링 시큐리티의 `Filters`*를 사용하지 않는다면 `AuthenticationManager`를 사용할 필요 없이 직접 `SecurityContextHolder`를 설정하면 된다.

`AuthenticationManager` 구현체는 어떤 것을 사용해도 좋지만, 가장 많이 사용하는 구현체는 [`ProviderManager`](#106-providermanager)다.

---

## 10.6. ProviderManager

[`ProviderManager`](https://docs.spring.io/spring-security/site/docs/current/api/org/springframework/security/authentication/ProviderManager.html)는 가장 많이 쓰는 [`AuthenticationManager`](#105-authenticationmanager) 구현체다. `ProviderManager`는 [`AuthenticationProvider`](#107-authenticationprovider)의 `List`에 위임한다. 모든 `AuthenticationProvider`는 인증을 성공시키거나, 실패시키거나, 아니면 결정을 내릴 수 없는 것으로 판단하고 다운스트림에 있는 `AuthenticationProvider`가 결정하도록 만들 수 있다. 설정한 `AuthenticationProvider`가 전부 인증하지 못하면 `ProviderNotFoundException`과 함께 실패한다. 이 예외는 특별한  `AuthenticationException`으로,  넘겨진 `Authentication` 유형을 지원하는 `ProviderManager`를 설정하지 않았음을 의미한다.

![ProviderManager](./../../images/springsecurity/providermanager.png)

보통은 `AuthenticationProvider`마다 각자가 맡은 인증을 수행하는 법을 알고 있다. 예를 들어 `AuthenticationProvider` 하나는 이름/비밀번호를 검증할 수 있고, 다른 건 SAML 인증을 담당할 수 있다. 이렇게 하면 인증 유형마다 담당 `AuthenticationProvider`가 있기 때문에, `AuthenticationManager` 빈 하나만 외부로 노출하면서도 여러 인증 유형을 지원할 수 있다.

원한다면 `ProviderManager`에 인증을 수행할 수 있는 `AuthenticationProvider`가 없을 때 사용할 부모 `AuthenticationManager`를 설정할 수도 있다. 부모는 `AuthenticationManager`의 어떤 구현체든지 될 수 있지만 보통 `ProviderManager` 인스턴스를 많이 사용한다.

![ProviderManager Parent](./../../images/springsecurity/providermanager-parent.png)

사실 `ProviderManager` 인스턴스 여러 개에서 동일한 부모 `AuthenticationManager`를 공유하는 것도 가능하다. 공통 인증을 사용하는 (부모 `AuthenticationManager`를 공유) [`SecurityFilterChain`](../servletsecuritythebigpicture#94-securityfilterchain) 인스턴스가 여러 개 있고, 각각의 인증 메커니즘이 다른 경우  (다른 `ProviderManager` 인스턴스) 흔히 쓰는 패턴이다.

![ProviderManagers Parent](./../../images/springsecurity/providermanagers-parent.png)

기본적으로 `ProviderManager`는 인증 요청에 성공하면 리턴된 `Authentication` 객체에 있는 모든 민감한 credential 정보를 지운다. 이로써 비밀번호 같은 정보를 `HttpSession`에 필요 이상으로 길게 유지하지 않는 것이다.

상태가 없는 어플리케이션에서 성능 향상 등을 위해 사용자 객체를 캐시한다면 문제가 될 수 있다. `Authentication`이 캐시 안에 있는 객체를 참조하고 있는데 (`UserDetails` 인스턴스 등) credential을 제거한다면, 캐시된 값으로는 더 이상 인증할 수 없다. 캐시를 사용한다면 이 점을 반드시 고려해야 한다. 캐시 구현부나 리턴된 `Authentication` 객체를 생성하는 `AuthenticationProvider`에서 객체의 복사본을 만들면 명쾌하게 해결된다. 아니면 `ProviderManager`의 `eraseCredentialsAfterAuthentication` 프로퍼티를 비활성화시켜도 된다. 자세한 정보는 [Javadoc](https://docs.spring.io/spring-security/site/docs/current/api/org/springframework/security/authentication/ProviderManager.html)을 참고하라.

---

## 10.7. AuthenticationProvider

[`ProviderManager`](#106-providermanager)엔 [`AuthenticationProvider`](https://docs.spring.io/spring-security/site/docs/current/api/org/springframework/security/authentication/AuthenticationProvider.html)를 여러 개 주입할 수 있다. `AuthenticationProvider`마다 담당하는 인증 유형이 다르다. 예를 들어 [`DaoAuthenticationProvider`](#10109-daoauthenticationprovider)는 이름/비밀번호 기반 인증을, `JwtAuthenticationProvider`는 JWT 토큰 인증을 지원한다.

---

## 10.8. Request Credentials with `AuthenticationEntryPoint`

[`AuthenticationEntryPoint`](https://docs.spring.io/spring-security/site/docs/current/api/org/springframework/security/web/AuthenticationEntryPoint.html)는 클라이언트의 credential을 요청하는 HTTP 응답을 보낼 때 사용한다.

클라이언트가 리소스를 요청할 때 미리 이름/비밀번호 같은 credential을 함께 보낼 때도 있다. 이럴 때는 credential을 요청하는 HTTP 응답을 만들 필요가 없다.

어떨 땐 클라이언트가 접근 권한이 없는 리소스에 인증되지 않은 요청을 보내기도 한다. 이때는 `AuthenticationEntryPoint` 구현체로 클라이언트에 credential을 요청한다. `AuthenticationEntryPoint`는 [로그인 페이지로 리다이렉트](#10101-form-login)하거나, [WWW-Authenticate](#10102-basic-authentication) 헤더로 응답하는 등의 일을 담당한다.

---

## 10.9. AbstractAuthenticationProcessingFilter

[`AbstractAuthenticationProcessingFilter`](https://docs.spring.io/spring-security/site/docs/current/api/org/springframework/security/web/authentication/AbstractAuthenticationProcessingFilter.html)는 사용자의 credential을 인증하기 위한 베이스 `Filter`다. credential을 인증할 수 없다면, 스프링 시큐리티는 보통 [`AuthenticationEntryPoint`](#108-request-credentials-with-authenticationentrypoint)로 credential을 요청한다.

그러고 나면 `AbstractAuthenticationProcessingFilter`는 제출한 모든 인증 요청을 처리할 수 있다.

![AbstractAuthenticationProcessingFilter](./../../images/springsecurity/abstractauthenticationprocessingfilter.png)

- <span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 사용자가 credential을 제출하면 `AbstractAuthenticationProcessingFilter`는 인증할 `HttpServletRequest`로부터 [`Authentication`](#103-authentication)을 만든다. 생성하는 `Authentication` 타입은 `AbstractAuthenticationProcessingFilter` 하위 클래스에 따라 다르다. 예를 들어 [`UsernamePasswordAuthenticationFilter`](#servlet-authentication-usernamepasswordauthenticationfilter)는 `HttpServletRequest`에 있는 *username*과 *password*로 `UsernamePasswordAuthenticationToken`을 생성한다.
- <span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 그다음엔 [`Authentication`](#103-authentication)을 [`AuthenticationManager`](#105-authenticationmanager)로 넘겨서 인증한다.
- <span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 인증에 실패하면 (*Failure*)
  + [SecurityContextHolder](#101-securitycontextholder)를 비운다.
  + `RememberMeServices.loginFail`을 실행한다. remember me를 설정하지 않았다면 아무 동작도 하지 않는다.
  + `AuthenticationFailureHandler`를 실행한다.
- <span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> 인증에 성공하면 (*Success*)
  + `SessionAuthenticationStrategy`에 새로 로그인했음을 통보한다.
  + [SecurityContextHolder](#101-securitycontextholder)에 [Authentication](#103-authentication)을 세팅한다. 이후 `SecurityContextPersistenceFilter`가 `HttpSession`에 `SecurityContext`를 저장한다.
  + `RememberMeServices.loginSuccess`를 실행한다. remember me를 설정하지 않았다면 아무 동작도 하지 않는다.
  + `ApplicationEventPublisher`는 `InteractiveAuthenticationSuccessEvent`를 발생시킨다.

---

## 10.10. Username/Password Authentication

사용자 이름과 비밀번호 검증은 사용자를 인증할 때 가장 많이 사용하는 방법 중 하나다. 그렇기 때문에 스프링 시큐리티는 이름과 비밀번호로 인증할 수 있는 방법을 종합적으로 지원한다.

<span id="servlet-authentication-unpwd-input">**Reading the Username & Password**

스프링 시큐리티는 `HttpServletRequest`에서 이름과 비밀번호를 읽을 수 있는 다음 메커니즘을 기본으로 제공한다:

- [폼 로그인](#10101-form-login)
- [기본 인증](#10102-basic-authentication)
- [다이제스트 인증](#10103-digest-authentication)

<span id="servlet-authentication-unpwd-storage"></span>**Storage Mechanisms**

이름/비밀번호 조회 메커니즘은 지원하는 저장 메커니즘 중 어떤 것과도 조합할 수 있다:

- [인메모리 인증](#10104-in-memory-authentication)과 심플 스토리지
- [JDBC 인증](#10105-jdbc-authentication)과 관계형 데이터베이스
- [UserDetailsService](#10107-userdetailsservice)와 커스텀 데이터 스토어
- [LDAP 인증](#101010-ldap-authentication)과 LDAP 스토리지

### 10.10.1. Form Login

스프링 시큐리티는 html 폼 기반 사용자 이름/비밀번호 인증을 지원한다. 이번 섹션에선 스프링 시큐리티의 폼 기반 인증 동작 방식을 설명한다.

스프링 시큐리티에서 폼 기반 로그인이 어떻게 동작하는지 살펴보자. 먼저 로그인 폼으로 리다이렉트하는 방법을 설명한다.

![Redirecting to the Log In Page](./../../images/springsecurity/loginurlauthenticationentrypoint.png)

이전에 설명했던 [`SecurityFilterChain`](../servletsecuritythebigpicture#94-securityfilterchain) 다이어그램을 기반으로 그린 그림이다.

- <span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 먼저 사용자가 권한이 없는 리소스 `/private`에 인증되지 않은 요청을 보낸다.
- <span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 스프링 시큐리티의 [`FilterSecurityInterceptor`](../authorization#112-authorize-httpservletrequest-with-filtersecurityinterceptor)에서 `AccessDeniedException`을 던져 인증되지 않은 요청을 *거절*했음을 알린다.
- <span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 인증되지 않은 사용자이므로 [`ExceptionTranslationFilter`](../servletsecuritythebigpicture#96-handling-security-exceptions)에서 *인증을 시작*하고, 설정한 [`AuthenticationEntryPoint`](#108-request-credentials-with-authenticationentrypoint)로 로그인 페이지로의 리다이렉트 응답을 전송한다. `AuthenticationEntryPoint`는 대부분 [`LoginUrlAuthenticationEntryPoint`](https://docs.spring.io/spring-security/site/docs/current/api/org/springframework/security/web/authentication/LoginUrlAuthenticationEntryPoint.html) 인스턴스다.
- <span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> 그러면 브라우저는 리다이렉트된 로그인 페이지를 요청한다.
- <span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> 어플리케이션에선 [로그인 페이지를 렌더링](#servlet-authentication-form-custom)해야 한다.

<span id="servlet-authentication-usernamepasswordauthenticationfilter"></span>username과 password를 제출하면 `UsernamePasswordAuthenticationFilter`가 이 값을 인증한다. `UsernamePasswordAuthenticationFilter`는 [AbstractAuthenticationProcessingFilter](#109-abstractauthenticationprocessingfilter)를 상속했기 때문에 다이어그램도 비슷하다.

![Authenticating Username and Password](./../../images/springsecurity/usernamepasswordauthenticationfilter.png)

이전에 설명했던 [`SecurityFilterChain`](../servletsecuritythebigpicture#94-securityfilterchain) 다이어그램을 기반으로 그린 그림이다.

- <span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 사용자가 username과 password를 제출하면 `UsernamePasswordAuthenticationFilter`는 `HttpServletRequest`에서 이 값을 추출해 [`Authentication`](#103-authentication) 유형 중 하나인 `UsernamePasswordAuthenticationToken`을 만든다.
- <span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 그다음엔 `UsernamePasswordAuthenticationToken`을 `AuthenticationManager`로 넘겨 인증한다. `AuthenticationManager` 상세 동작은 [사용자 정보를 저장](#servlet-authentication-unpwd-storage)한 방식에 따라 다르다.
- <span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 인증에 실패하면 (*Failure*)
  + [SecurityContextHolder](#101-securitycontextholder)를 비운다.
  + `RememberMeServices.loginFail`을 실행한다. remember me를 설정하지 않았다면 아무 동작도 하지 않는다.
  + `AuthenticationFailureHandler`를 실행한다.
- <span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> 인증에 성공하면 (*Success*)
  + `SessionAuthenticationStrategy`에 새로 로그인했음을 통보한다.
  + [SecurityContextHolder](#101-securitycontextholder)에 [Authentication](#103-authentication)을 세팅한다.
  + `RememberMeServices.loginSuccess`를 실행한다. remember me를 설정하지 않았다면 아무 동작도 하지 않는다.
  + `ApplicationEventPublisher`는 `InteractiveAuthenticationSuccessEvent`를 발생시킨다.
  + `AuthenticationSuccessHandler`를 실행한다. 보통 로그인 페이지로 리다이렉트할 때는 `SimpleUrlAuthenticationSuccessHandler`가 [`ExceptionTranslationFilter`](../servletsecuritythebigpicture#96-handling-security-exceptions)에 저장된 요청으로 리다이렉트한다.

스프링 시큐리티에선 폼 로그인이 디폴트로 활성화된다. 하지만 서블릿 기반 설정을 사용한다면 폼 기반 로그인을 명시해야 한다. 최소한 아래와 같은 설정이 있어야 한다:

**Example 51. Form Log In**

<div class="switch-language-wrapper java xml kotlin">
<span class="switch-language java">java</span>
<span class="switch-language xml">xml</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java xml kotlin"></div>
```java
protected void configure(HttpSecurity http) {
    http
        // ...
        .formLogin(withDefaults());
}
```
<div class="language-only-for-xml java xml kotlin"></div>
```xml
<http>
    <!-- ... -->
    <form-login />
</http>
```
<div class="language-only-for-kotlin java xml kotlin"></div>
```kotlin
fun configure(http: HttpSecurity) {
    http {
        // ...
        formLogin { }
    }
}
```

이 설정에선 디폴트 로그인 페이지로 렌더링한다. 프로덕션에서 사용할 어플리케이션은 대부분 커스텀 로그인 폼이 필요하다.

<span id="servlet-authentication-form-custom"></span>커스텀 로그인 폼을 설정하는 방법은 아래 설정에 있다.

**Example 52. Custom Log In Form Configuration**

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
        .formLogin(form -> form
            .loginPage("/login")
            .permitAll()
        );
}
```
<div class="language-only-for-xml java xml kotlin"></div>
```xml
<http>
    <!-- ... -->
    <intercept-url pattern="/login" access="permitAll" />
    <form-login login-page="/login" />
</http>
```
<div class="language-only-for-kotlin java xml kotlin"></div>
```kotlin
fun configure(http: HttpSecurity) {
    http {
        // ...
        formLogin {
            loginPage = "/login"
            permitAll()
        }
    }
}
```

스프링 시큐리티 설정에 로그인 페이지를 명시했다면 페이지 렌더링을 직접 구현해야 한다. 다음은 로그인 페이지 `/login`에서 필요한 HTML 로그인 폼을 생성하는 [타임리프](https://www.thymeleaf.org/) 템플릿이다:

**Example 53. Log In Form**

> **src/main/resources/templates/login.html**

```xml
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:th="https://www.thymeleaf.org">
    <head>
        <title>Please Log In</title>
    </head>
    <body>
        <h1>Please Log In</h1>
        <div th:if="${param.error}">
            Invalid username and password.</div>
        <div th:if="${param.logout}">
            You have been logged out.</div>
        <form th:action="@{/login}" method="post">
            <div>
            <input type="text" name="username" placeholder="Username"/>
            </div>
            <div>
            <input type="password" name="password" placeholder="Password"/>
            </div>
            <input type="submit" value="Log in" />
        </form>
    </body>
</html>
```

디폴트 HTML 폼은 몇 가지 핵심 규칙을 따른다:

- `/login`에 `post` 요청을 보내야 한다.
- [CSRF 토큰](https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#servlet-csrf)을 포함해야 하며, 타임리프에서는 [자동으로 추가](https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#servlet-csrf-include-form-auto)된다.
- 사용자 이름은 `username` 파라미터로 명시해야 한다.
- 비밀번호는 `password` 파라미터로 명시해야 한다.
- HTTP 파라미터 error가 있으면 사용자가 유효한 username / password를 제공하지 못했음을 나타낸다.
- HTTP 파라미터 logout이 있으면 사용자가 로그아웃에 성공한 것을 나타낸다.

대부분은 로그인 페이지를 더 커스텀할 필요가 없을 것이다. 하지만 위에 있는 것 이상으로 더 커스텀하고 싶다면 추가 설정을 넣으면 된다.

스프링 MVC를 사용한다면 `GET /login` 요청을, 만든 로그인 템플릿으로 매핑하는 컨트롤러가 필요하다. 다음 코드는 최소한으로 작성한 샘플 `LoginController`다:

**Example 54. LoginController**

> **src/main/java/example/LoginController.java**

```java
@Controller
class LoginController {
    @GetMapping("/login")
    String login() {
        return "login";
    }
}
```

### 10.10.2. Basic Authentication

이번 섹션에서는 스프링 시큐리티가 어떻게 서블릿 기반 어플리케이션에서 [기본 HTTP 인증](https://tools.ietf.org/html/rfc7617)을 지원하는지 다룬다.

스프링 시큐리티에서 HTTP 기본 인증이 어떻게 동작하는지 살펴보자. 먼저 인증되지 않은 클라이언트에게 [WWW-Authenticate](https://tools.ietf.org/html/rfc7235#section-4.1) 헤더를 다시 전송하는 것을 확인할 것이다.

![Sending WWW-Authenticate Header](./../../images/springsecurity/basicauthenticationentrypoint.png)

이전에 설명했던 [`SecurityFilterChain`](../servletsecuritythebigpicture#94-securityfilterchain) 다이어그램을 기반으로 그린 그림이다.

- <span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 먼저 사용자가 권한이 없는 리소스 `/private`에 인증되지 않은 요청을 보낸다.
- <span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 스프링 시큐리티의 [`FilterSecurityInterceptor`](../authorization#112-authorize-httpservletrequest-with-filtersecurityinterceptor)에서 `AccessDeniedException`을 던져 인증되지 않은 요청을 *거절*했음을 알린다.
- <span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 인증되지 않은 사용자이므로 [`ExceptionTranslationFilter`](../servletsecuritythebigpicture#96-handling-security-exceptions)에서 *인증을 시작*한다. 설정한 [`AuthenticationEntryPoint`](#108-request-credentials-with-authenticationentrypoint)는 [`BasicAuthenticationEntryPoint`](https://docs.spring.io/spring-security/site/docs/current/api/org/springframework/security/web/authentication/www/BasicAuthenticationEntryPoint.html) 인스턴스로, WWW-Authenticate 헤더를 전송한다. 이때는 클라이언트가 기존 요청을 다시 전송할 수 있으므로 `RequestCache`는 보통 `NullRequestCache`를 사용한다.

클라이언트는  WWW-Authenticate 헤더를 받으면 username과 password로 재시도해야 한다는 것을 알고 있다. 다음은 username과 password를 처리하는 플로우다:

![Authenticating Username and Password](./../../images/springsecurity/basicauthenticationfilter.png)

이전에 설명했던 [`SecurityFilterChain`](../servletsecuritythebigpicture#94-securityfilterchain) 다이어그램을 기반으로 그린 그림이다.

- <span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 사용자가 username과 password를 제출하면 `UsernamePasswordAuthenticationFilter`는 `HttpServletRequest`에서 이 값을 추출해 [`Authentication`](#103-authentication) 유형 중 하나인 `UsernamePasswordAuthenticationToken`을 만든다.
- <span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 그다음엔 `UsernamePasswordAuthenticationToken`을 `AuthenticationManager`로 넘겨 인증한다. `AuthenticationManager` 상세 동작은 [사용자 정보를 저장](#servlet-authentication-unpwd-storage)한 방식에 따라 다르다.
- <span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 인증에 실패하면 (*Failure*)
  + [SecurityContextHolder](#101-securitycontextholder)를 비운다.
  + `RememberMeServices.loginFail`을 실행한다. remember me를 설정하지 않았다면 아무 동작도 하지 않는다.
  + `AuthenticationEntryPoint`를 실행해서 WWW-Authenticate 전송을 트리거한다.
- <span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> 인증에 성공하면 (*Success*)
  + [SecurityContextHolder](#101-securitycontextholder)에 [Authentication](#103-authentication)을 세팅한다.
  + `RememberMeServices.loginSuccess`을 실행한다. remember me를 설정하지 않았다면 아무 동작도 하지 않는다.
  + `BasicAuthenticationFilter`에서 `FilterChain.doFilter(request,response)`를 호출해서 나머지 어플리케이션 로직을 실행한다.

스프링 시큐리티에선 HTTP 기본 인증을 디폴트로 활성화한다. 하지만 서블릿 기반 설정을 사용한다면 HTTP 기본을 명시해야 한다.

최소한 아래와 같은 설정이 필요하다:

**Example 55. Explicit HTTP Basic Configuration**

<div class="switch-language-wrapper java xml kotlin">
<span class="switch-language java">java</span>
<span class="switch-language xml">xml</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java xml kotlin"></div>
```java
protected void configure(HttpSecurity http) {
    http
        // ...
        .httpBasic(withDefaults());
}
```
<div class="language-only-for-xml java xml kotlin"></div>
```xml
<http>
    <!-- ... -->
    <http-basic />
</http>
```
<div class="language-only-for-kotlin java xml kotlin"></div>
```kotlin
fun configure(http: HttpSecurity) {
    http {
        // ...
        httpBasic { }
    }
}
```

### 10.10.3. Digest Authentication

이번 섹션에선 `DigestAuthenticationFilter`가 제공하는 [다이제스트 인증](https://tools.ietf.org/html/rfc2617) 지원 방식을 자세히 다룬다.

>  다이제스트 인증은 안전하지 않으므로 최신 어플리케이션에선 사용하지 말아야 한다. 비밀번호를 일반 텍스트나 암호화 또는 MD5 형식으로 저장해야 한다는 게 가장 큰 문제다. 이 저장 형식은 전부 안전하지 않다. 그대신 다이제스트에선 지원하지 않는, 단방향 적응형 비밀번호 해시 (i.e. bCrypt, PBKDF2, SCrypt 등)를 사용해서 credential을 저장해야 한다.

다이제스트 인증에선 [기본 인증](#10102-basic-authentication)의 많은 문제점을 개선하기 위한 시도였다. 특히 네트워크 상에서 credential을 일반 텍스트로 전달하지 않게 만들 수 있다. 많은 [브라우저가 다이제스트 인증을 지원하고 있다](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Digest#Browser_compatibility).

HTTP 다이제스트 인증 관리 표준은 [RFC 2617](https://tools.ietf.org/html/rfc2617)에 정의돼 있으며, [RFC 2069](https://tools.ietf.org/html/rfc2069)에서 업데이트 됐다. user agent 대부분은 RFC 2617을 구현하고 있다. 스프링 시큐리티가 지원하는 다이제스트 인증은 RFC 2617에서 규정한 “auth" quality of protection (`qop`)과 호환되며, 이전 버전 RFC 2069와도 호환된다. 암호화하지 않은 HTTP (i.e. TLS/HTTPS 미적용) 통신에서 최대한 안전하게 인증을 처리하고 싶다면 다이제스트 인증이 더 매력적으로 느껴질 것이다. 하지만 [HTTPS](../features#523-http)는 무조건 적용하는 게 좋다.

다이제스트 인증의 핵심은 "nonce"다. 서버에서 생성하는 값으로, 스프링 시큐리티의 nonce는 다음 형식을 따른다:

**Example 56. Digest Syntax**

```txt
base64(expirationTime + ":" + md5Hex(expirationTime + ":" + key))
expirationTime:   The date and time when the nonce expires, expressed in milliseconds
key:              A private key to prevent modification of the nonce token
```

안전하지 않은 일반 텍스트 [비밀번호를 저장](../features#512-password-storage)할 땐 `NoOpPasswordEncoder`를 사용하도록 [설정](../features#password-storage-configuration)했는지 확인해야 한다. 다음은 다이제스트 인증 설정 예시다:

**Example 57. Digest Authentication**

<div class="switch-language-wrapper java xml">
<span class="switch-language java">java</span>
<span class="switch-language xml">xml</span>
</div>
<div class="language-only-for-java java xml"></div>
```java
@Autowired
UserDetailsService userDetailsService;

DigestAuthenticationEntryPoint entryPoint() {
    DigestAuthenticationEntryPoint result = new DigestAuthenticationEntryPoint();
    result.setRealmName("My App Relam");
    result.setKey("3028472b-da34-4501-bfd8-a355c42bdf92");
}

DigestAuthenticationFilter digestAuthenticationFilter() {
    DigestAuthenticationFilter result = new DigestAuthenticationFilter();
    result.setUserDetailsService(userDetailsService);
    result.setAuthenticationEntryPoint(entryPoint());
}

protected void configure(HttpSecurity http) throws Exception {
    http
        // ...
        .exceptionHandling(e -> e.authenticationEntryPoint(authenticationEntryPoint()))
        .addFilterBefore(digestFilter());
}
```
<div class="language-only-for-xml  java xml"></div>
```xml
<b:bean id="digestFilter"
        class="org.springframework.security.web.authentication.www.DigestAuthenticationFilter"
    p:userDetailsService-ref="jdbcDaoImpl"
    p:authenticationEntryPoint-ref="digestEntryPoint"
/>

<b:bean id="digestEntryPoint"
        class="org.springframework.security.web.authentication.www.DigestAuthenticationEntryPoint"
    p:realmName="My App Realm"
    p:key="3028472b-da34-4501-bfd8-a355c42bdf92"
/>

<http>
    <!-- ... -->
    <custom-filter ref="userFilter" position="DIGEST_AUTH_FILTER"/>
</http>
```

### 10.10.4. In-Memory Authentication

스프링 시큐리티의 `InMemoryUserDetailsManager`는 메모리 기반으로 username/password를 인증하는 [UserDetailsService](#10107-userdetailsservice) 구현체다. `InMemoryUserDetailsManager`는 `UserDetailsManager` 인터페이스도 구현했기 때문에 `UserDetails`를 관리할 수 있다. 스프링 시큐리티는 [username/password를 읽어](#servlet-authentication-unpwd-input) 인증할 때 `UserDetails`를 사용한다.

이 예제에선 [스프링 부트 CLI](../features#encode-with-spring-boot-cli)로 비밀번호 `password`를 인코딩했으며, 인코딩된 값 `{bcrypt}$2a$10$GRLdNijSQMUvl/au9ofL.eDwmoohzzS7.rmNSJZ.0FxO/BTk76klW`를 얻었다.

**Example 58. InMemoryUserDetailsManager Java Configuration**

<div class="switch-language-wrapper java xml kotlin">
<span class="switch-language java">java</span>
<span class="switch-language xml">xml</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java xml kotlin"></div>
```java
@Bean
public UserDetailsService users() {
    UserDetails user = User.builder()
        .username("user")
        .password("{bcrypt}$2a$10$GRLdNijSQMUvl/au9ofL.eDwmoohzzS7.rmNSJZ.0FxO/BTk76klW")
        .roles("USER")
        .build();
    UserDetails admin = User.builder()
        .username("admin")
        .password("{bcrypt}$2a$10$GRLdNijSQMUvl/au9ofL.eDwmoohzzS7.rmNSJZ.0FxO/BTk76klW")
        .roles("USER", "ADMIN")
        .build();
    return new InMemoryUserDetailsManager(user, admin);
}
```
<div class="language-only-for-xml java xml kotlin"></div>
```xml
<user-service>
    <user name="user"
        password="{bcrypt}$2a$10$GRLdNijSQMUvl/au9ofL.eDwmoohzzS7.rmNSJZ.0FxO/BTk76klW"
        authorities="ROLE_USER" />
    <user name="admin"
        password="{bcrypt}$2a$10$GRLdNijSQMUvl/au9ofL.eDwmoohzzS7.rmNSJZ.0FxO/BTk76klW"
        authorities="ROLE_USER,ROLE_ADMIN" />
</user-service>
```
<div class="language-only-for-kotlin java xml kotlin"></div>
```kotlin
@Bean
fun users(): UserDetailsService {
    val user = User.builder()
        .username("user")
        .password("{bcrypt}$2a$10\$GRLdNijSQMUvl/au9ofL.eDwmoohzzS7.rmNSJZ.0FxO/BTk76klW")
        .roles("USER")
        .build()
    val admin = User.builder()
        .username("admin")
        .password("{bcrypt}$2a$10\$GRLdNijSQMUvl/au9ofL.eDwmoohzzS7.rmNSJZ.0FxO/BTk76klW")
        .roles("USER", "ADMIN")
        .build()
    return InMemoryUserDetailsManager(user, admin)
}
```

위 예제는 비밀번호를 안전한 포맷으로 저장하지만, 아직 아쉬운 점이 많다.

아래 예제는 [User.withDefaultPasswordEncoder](../features#getting-started-experience)로 메모리에 저장할 비밀번호를 보호한다. 하지만 소스 코드를 디컴파일하면 비밀번호를 쉽게 탈취할 수 있다. 따라서 `User.withDefaultPasswordEncoder`는 처음 시작해볼 때만 사용해야 하며, 프로덕션 코드엔 사용하면 안 된다.

**Example 59. InMemoryUserDetailsManager with User.withDefaultPasswordEncoder**

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
@Bean
public UserDetailsService users() {
    // The builder will ensure the passwords are encoded before saving in memory
    UserBuilder users = User.withDefaultPasswordEncoder();
    UserDetails user = users
        .username("user")
        .password("password")
        .roles("USER")
        .build();
    UserDetails admin = users
        .username("admin")
        .password("password")
        .roles("USER", "ADMIN")
        .build();
    return new InMemoryUserDetailsManager(user, admin);
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
@Bean
fun users(): UserDetailsService {
    // The builder will ensure the passwords are encoded before saving in memory
    val users = User.withDefaultPasswordEncoder()
    val user = users
        .username("user")
        .password("password")
        .roles("USER")
        .build()
    val admin = users
        .username("admin")
        .password("password")
        .roles("USER", "ADMIN")
        .build()
    return InMemoryUserDetailsManager(user, admin)
}
```

XML 기반으로는 간단하게 `User.withDefaultPasswordEncoder`를 설정할 방법이 없다. 데모 프로젝트나 단순 연습용 코드라면 앞에 `{noop}`을 프리픽스로 달아서 [인코딩하지 않음](../features#password-storage-format)을 지정하는 방법도 있다.

**Example 60. \<user-service\> `{noop}` XML Configuration**

```xml
<user-service>
    <user name="user"
        password="{noop}password"
        authorities="ROLE_USER" />
    <user name="admin"
        password="{noop}password"
        authorities="ROLE_USER,ROLE_ADMIN" />
</user-service>
```

### 10.10.5. JDBC Authentication

스프링 시큐리티의 `JdbcDaoImpl`는 JDBC기반으로 username/password를 인증하는 [UserDetailsService](#10107-userdetailsservice) 구현체다. `JdbcDaoImpl`을 상속한 `JdbcUserDetailsManager`는 `UserDetailsManager` 인터페이스도 구현했기 때문에 `UserDetails`를 관리할 수 있다. 스프링 시큐리티는 [username/password를 읽어](#servlet-authentication-unpwd-input) 인증할 때 `UserDetails`를 사용한다.

아래에서는 다음과 같은 내용을 다룬다:

- 스프링 시큐리티 JDBC 인증에서 사용하는 [디폴트 스키마](#default-schema)
- [데이터 소스 설정](#setting-up-a-datasource)
- [JdbcUserDetailsManager 빈](#jdbcuserdetailsmanager-bean)

#### Default Schema

스프링 시큐리티는 JDBC 기반 인증을 위한 기본 쿼리를 제공한다. 여기에선 디폴트 쿼리에서 사용되는 디폴트 스키마를 다룬다. 쿼리나 데이터베이스 방언(dialect)을 커스텀한다면 스키마도 함께 바꿔야 한다.

#### User Schema

`JdbcDaoImpl`에서 사용자의 비밀번호, 계정 상태 (활성화/비활성화), 권한 (roles) 리스트를 로드하려면 테이블이 있어야 한다. 필요한 디폴트 스키마는 다음과 같다:

> 디폴트 스키마는 클래스 패스 리소스 `org/springframework/security/core/userdetails/jdbc/users.ddl`로도 접근할 수 있다.

**Example 61. Default User Schema**

```sql
create table users(
    username varchar_ignorecase(50) not null primary key,
    password varchar_ignorecase(50) not null,
    enabled boolean not null
);

create table authorities (
    username varchar_ignorecase(50) not null,
    authority varchar_ignorecase(50) not null,
    constraint fk_authorities_users foreign key(username) references users(username)
);
create unique index ix_auth_username on authorities (username,authority);
```

오라클도 많이 쓰는 데이터베이스 중 하나지만, 약간 다른 스키마가 필요하다. 오라클의 디폴트 사용자 스키마는 다음과 같다:

**Example 62. Default User Schema for Oracle Databases**

```sql
CREATE TABLE USERS (
    USERNAME NVARCHAR2(128) PRIMARY KEY,
    PASSWORD NVARCHAR2(128) NOT NULL,
    ENABLED CHAR(1) CHECK (ENABLED IN ('Y','N') ) NOT NULL
);


CREATE TABLE AUTHORITIES (
    USERNAME NVARCHAR2(128) NOT NULL,
    AUTHORITY NVARCHAR2(128) NOT NULL
);
ALTER TABLE AUTHORITIES ADD CONSTRAINT AUTHORITIES_UNIQUE UNIQUE (USERNAME, AUTHORITY);
ALTER TABLE AUTHORITIES ADD CONSTRAINT AUTHORITIES_FK1 FOREIGN KEY (USERNAME) REFERENCES USERS (USERNAME) ENABLE;
```

#### Group Schema

그룹을 사용하는 어플리케이션은 그룹 스키마도 필요하다. 디폴트 그룹 스키마는 다음과 같다:

**Example 63. Default Group Schema**

```sql
create table groups (
    id bigint generated by default as identity(start with 0) primary key,
    group_name varchar_ignorecase(50) not null
);

create table group_authorities (
    group_id bigint not null,
    authority varchar(50) not null,
    constraint fk_group_authorities_group foreign key(group_id) references groups(id)
);

create table group_members (
    id bigint generated by default as identity(start with 0) primary key,
    username varchar(50) not null,
    group_id bigint not null,
    constraint fk_group_members_group foreign key(group_id) references groups(id)
);
```

#### Setting up a DataSource

`JdbcUserDetailsManager`를 설정하려면 먼저 `DataSource`가 있어야 한다. 예제에서는 [디폴트 사용자 스키마](#default-schema)로 초기화하는 [임베디드 데이터소스](https://docs.spring.io/spring-framework/docs/current/spring-framework-reference/data-access.html#jdbc-embedded-database-support)를 설정한다.

**Example 64. Embedded Data Source**

<div class="switch-language-wrapper java xml kotlin">
<span class="switch-language java">java</span>
<span class="switch-language xml">xml</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java xml kotlin"></div>
```java
@Bean
DataSource dataSource() {
    return new EmbeddedDatabaseBuilder()
        .setType(H2)
        .addScript("classpath:org/springframework/security/core/userdetails/jdbc/users.ddl")
        .build();
}
```
<div class="language-only-for-xml java xml kotlin"></div>
```xml
<jdbc:embedded-database>
    <jdbc:script location="classpath:org/springframework/security/core/userdetails/jdbc/users.ddl"/>
</jdbc:embedded-database>
```
<div class="language-only-for-kotlin java xml kotlin"></div>
```kotlin
@Bean
fun dataSource(): DataSource {
    return EmbeddedDatabaseBuilder()
        .setType(H2)
        .addScript("classpath:org/springframework/security/core/userdetails/jdbc/users.ddl")
        .build()
}
```

프로덕션 환경에선 외부 데이터베이스 커넥션을 설정해야 한다.

#### JdbcUserDetailsManager Bean

이 예제에선 [스프링 부트 CLI](../features#encode-with-spring-boot-cli)로 비밀번호 `password`를 인코딩했으며, 인코딩된 값 `{bcrypt}$2a$10$GRLdNijSQMUvl/au9ofL.eDwmoohzzS7.rmNSJZ.0FxO/BTk76klW`를 얻었다. 비밀번호를 저장하는 방법은 [PasswordEncoder](../features#512-password-storage) 섹션을 참고하라.

**Example 65. JdbcUserDetailsManager**

<div class="switch-language-wrapper java xml kotlin">
<span class="switch-language java">java</span>
<span class="switch-language xml">xml</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java xml kotlin"></div>
```java
@Bean
UserDetailsManager users(DataSource dataSource) {
    UserDetails user = User.builder()
        .username("user")
        .password("{bcrypt}$2a$10$GRLdNijSQMUvl/au9ofL.eDwmoohzzS7.rmNSJZ.0FxO/BTk76klW")
        .roles("USER")
        .build();
    UserDetails admin = User.builder()
        .username("admin")
        .password("{bcrypt}$2a$10$GRLdNijSQMUvl/au9ofL.eDwmoohzzS7.rmNSJZ.0FxO/BTk76klW")
        .roles("USER", "ADMIN")
        .build();
    JdbcUserDetailsManager users = new JdbcUserDetailsManager(dataSource);
    users.createUser()
}
```
<div class="language-only-for-xml java xml kotlin"></div>
```xml
<jdbc-user-service>
    <user name="user"
        password="{bcrypt}$2a$10$GRLdNijSQMUvl/au9ofL.eDwmoohzzS7.rmNSJZ.0FxO/BTk76klW"
        authorities="ROLE_USER" />
    <user name="admin"
        password="{bcrypt}$2a$10$GRLdNijSQMUvl/au9ofL.eDwmoohzzS7.rmNSJZ.0FxO/BTk76klW"
        authorities="ROLE_USER,ROLE_ADMIN" />
</jdbc-user-service>
```
<div class="language-only-for-kotlin java xml kotlin"></div>
```kotlin
@Bean
fun users(dataSource: DataSource): UserDetailsManager {
    val user = User.builder()
            .username("user")
            .password("{bcrypt}$2a$10\$GRLdNijSQMUvl/au9ofL.eDwmoohzzS7.rmNSJZ.0FxO/BTk76klW")
            .roles("USER")
            .build();
    val admin = User.builder()
            .username("admin")
            .password("{bcrypt}$2a$10\$GRLdNijSQMUvl/au9ofL.eDwmoohzzS7.rmNSJZ.0FxO/BTk76klW")
            .roles("USER", "ADMIN")
            .build();
    val users = JdbcUserDetailsManager(dataSource)
    users.createUser(user)
    users.createUser(admin)
    return users
}
```

### 10.10.6. UserDetails

[`UserDetails`](https://docs.spring.io/spring-security/site/docs/current/api/org/springframework/security/core/userdetails/UserDetails.html)는 [`UserDetailsService`](#10107-userdetailsservice)가 리턴하는 값이다. [`DaoAuthenticationProvider`](#10109-daoauthenticationprovider)가 `UserDetails`를 인증하고, 이 `UserDetails`를 principal로 가진 [`Authentication`](#103-authentication)을 리턴한다.

### 10.10.7. UserDetailsService

[`UserDetailsService`](https://docs.spring.io/spring-security/site/docs/current/api/org/springframework/security/core/userdetails/UserDetailsService.html)는 [`DaoAuthenticationProvider`](#10109-daoauthenticationprovider)가 username/password로 인증할 때 필요한 username, password와 다른 속성을 조회할 때 사용한다. 스프링 시큐리티가 제공하는 `UserDetailsService`는 [인메모리](#10104-in-memory-authentication)와 [JDBC](#10105-jdbc-authentication) 기반 구현체가 있다.

커스텀 인증을 정의하려면 커스텀 `UserDetailsService`를 빈으로 만들면 된다. 예를 들어 `CustomUserDetailsService`가 `UserDetailsService`를 구현했다고 가정하고, 인증을 커스텀해보자:

> `AuthenticationManagerBuilder`를 사용하지 않고 `AuthenticationProviderBean` 빈을 정의하지도 않았을 때 사용하는 방법이다.

**Example 66. Custom UserDetailsService Bean**

<div class="switch-language-wrapper java xml kotlin">
<span class="switch-language java">java</span>
<span class="switch-language xml">xml</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java xml kotlin"></div>
```java
@Bean
CustomUserDetailsService customUserDetailsService() {
    return new CustomUserDetailsService();
}
```
<div class="language-only-for-xml java xml kotlin"></div>
```xml
<b:bean class="example.CustomUserDetailsService"/>
```
<div class="language-only-for-kotlin java xml kotlin"></div>
```kotlin
@Bean
fun customUserDetailsService() = CustomUserDetailsService()
```

### 10.10.8. PasswordEncoder

서블릿에서 스프링 시큐리티를 사용하면 [`PasswordEncoder`](../features#512-password-storage)를 통합해 비밀번호를 안전하게 저장할 수 있다. 스프링 시큐리티가 사용하는 `PasswordEncoder` 구현체를 커스텀하려면 [`PasswordEncoder` 빈을 정의](../features#password-storage-configuration)하면 된다.

### 10.10.9. DaoAuthenticationProvider

[`DaoAuthenticationProvider`](https://docs.spring.io/spring-security/site/docs/current/api/org/springframework/security/authentication/dao/DaoAuthenticationProvider.html)는 [`UserDetailsService`](#10107-userdetailsservice)와 [`PasswordEncoder`](../authentication#10108-passwordencoder)로 username/password를 인증하는 [`AuthenticationProvider`](#107-authenticationprovider) 구현체다.

스프링 시큐리티에서 `DaoAuthenticationProvider`가 동작하는 방식을 살펴보자. 다음은 [Username & Password 조회](#servlet-authentication-unpwd-input)를 설명할 때 다룬 이미지에서 [`AuthenticationManager`](#105-authenticationmanager)가 동작하는 방식을 자세히 나타낸 그림이다.

![DaoAuthenticationProvider Usage](./../../images/springsecurity/daoauthenticationprovider.png)

- <span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> [Username & Password를 조회](#servlet-authentication-unpwd-input)하는 인증 `Filter`에서 `UsernamePasswordAuthenticationToken`을 [`ProviderManager`](#106-providermanager)를 구현하고 있는`AuthenticationManager`로 넘긴다.
- <span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 이 `ProviderManager`는 [AuthenticationProvider](#107-authenticationprovider)로 `DaoAuthenticationProvider`를 사용하도록 설정돼 있다.
- <span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> `DaoAuthenticationProvider`는 `UserDetailsService`에서 `UserDetails`를 조회한다.
- <span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> 그다음 `DaoAuthenticationProvider`는 이전 단계에서 얻은 `UserDetails`에 있는 비밀번호를 [`PasswordEncoder`](../authentication#10108-passwordencoder)로 검증한다.
- <span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> 인증에 성공하면 `UsernamePasswordAuthenticationToken` 타입의 [`Authentication`](#103-authentication)을 반환하며, `UserDetailsService`가 리턴한 `UserDetails`를 principal로 가지고 있다. 결국에 리턴한 `UsernamePasswordAuthenticationToken`은 인증 `Filter`에서 [`SecurityContextHolder`](#101-securitycontextholder)로 세팅된다.

### 10.10.10. LDAP Authentication

LDAP은 조직에서 사용자 정보를 관리하기 위한 중앙 저장소와 인증 서비스로 많이 사용한다. 어플리케이션 사용자의 role을 저장할 때도 사용할 수 있다.

스프링 시큐리티의 LDAP 기반 인증은 [username/password를 읽어](#servlet-authentication-unpwd-input) 인증할 때 사용한다. 하지만 username/password로 인증하더라도 `UserDetailsService`와 통합되지는 않는다. LDAP 서버는 [bind 인증](#using-bind-authentication)에서 비밀번호를 반환하지 않기 때문에 어플리케이션에서 비밀번호를 인증할 수 없기 때문이다.

LDAP 서버의 설정 시나리오는 다양하므로 스프링 시큐리티는 전체 설정을 바꿀 수 있는 LDAP provider를 제공한다. 인증과 role을 조회할 때는 별도의 전략 인터페이스를 사용하며, 다양한 상황에서 설정할 수 있는 디폴트 구현체를 제공한다.

#### Prerequisites

스프링 시큐리티에서 LDAP을 적용하기 전에 먼저 LDAP을 숙지해야 한다. 이 페이지는 관련 개념을 소개하고 무료 LDAP 서버 OpenLDAP으로 디렉토리를 설정하는 가이드를 제공하고 있다: [https://www.zytrax.com/books/ldap/](https://www.zytrax.com/books/ldap/). 자바에서 LDAP에 접근할 때 사용하는 JNDI API를 알아두면 유용할 때도 있다. 스프링 시큐리티의 LDAP provider에선 외부 LDAP 라이브러리를 사용하지 않지만 (Mozilla, JLDAP 등), 스프링 LDAP을 종합적으로 사용하므로 스프링 LDAP 프로젝트를 잘 알아두면 커스텀할 때 도움이 될 것이다.

LDAP 인증을 사용한다면 LDAP 커넥션 풀을 제대로 설정하는 것도 중요하다. 방법을 잘 모르겠다면 [자바 LDAP 문서](https://docs.oracle.com/javase/jndi/tutorial/ldap/connect/config.html)를 참고하라.

#### Setting up an Embedded LDAP Server

가장 먼저 설정에서 가리킬 LDAP 서버가 필요하다. 보통 임베디드 LDAP 서버로 시작하는 게 가장 간단하다. 스프링 시큐리티는 아래 두 가지를 지원한다:

- [Embedded UnboundID Server](#embedded-unboundid-server)
- [Embedded ApacheDS Server](#embedded-apacheds-server)

아래 있는 샘플은 `password`란 비밀번호를 가진 `user`와 `admin` 사용자로 임베디드 LDAP 서버를 초기화하며, 이 `users.ldif` 파일은 클래스패스 리소스에서도 볼 수 있다.

**users.ldif**

```ldif
dn: ou=groups,dc=springframework,dc=org
objectclass: top
objectclass: organizationalUnit
ou: groups

dn: ou=people,dc=springframework,dc=org
objectclass: top
objectclass: organizationalUnit
ou: people

dn: uid=admin,ou=people,dc=springframework,dc=org
objectclass: top
objectclass: person
objectclass: organizationalPerson
objectclass: inetOrgPerson
cn: Rod Johnson
sn: Johnson
uid: admin
userPassword: password

dn: uid=user,ou=people,dc=springframework,dc=org
objectclass: top
objectclass: person
objectclass: organizationalPerson
objectclass: inetOrgPerson
cn: Dianne Emu
sn: Emu
uid: user
userPassword: password

dn: cn=user,ou=groups,dc=springframework,dc=org
objectclass: top
objectclass: groupOfNames
cn: user
uniqueMember: uid=admin,ou=people,dc=springframework,dc=org
uniqueMember: uid=user,ou=people,dc=springframework,dc=org

dn: cn=admin,ou=groups,dc=springframework,dc=org
objectclass: top
objectclass: groupOfNames
cn: admin
uniqueMember: uid=admin,ou=people,dc=springframework,dc=org
```

#### Embedded UnboundID Server

[UnboundID](https://ldap.com/unboundid-ldap-sdk-for-java/)를 사용하려면 아래 의존성을 추가해라:

**Example 67. UnboundID Dependencies**

<div class="switch-language-wrapper maven gradle">
<span class="switch-language maven">maven</span>
<span class="switch-language gradle">gradle</span>
</div>
<div class="language-only-for-maven maven gradle"></div>
```xml
<dependency>
    <groupId>com.unboundid</groupId>
    <artifactId>unboundid-ldapsdk</artifactId>
    <version>4.0.14</version>
    <scope>runtime</scope>
</dependency>
```
<div class="language-only-for-gradle maven gradle"></div>
```groovy
depenendencies {
    runtimeOnly "com.unboundid:unboundid-ldapsdk:4.0.14"
}
```

그러면 임베디드 LDAP 서버를 설정할 수 있다.

**Example 68. Embedded LDAP Server Configuration**

<div class="switch-language-wrapper java xml kotlin">
<span class="switch-language java">java</span>
<span class="switch-language xml">xml</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java xml kotlin"></div>
```java
@Bean
UnboundIdContainer ldapContainer() {
    return new UnboundIdContainer("dc=springframework,dc=org",
                "classpath:users.ldif");
}
```
<div class="language-only-for-xml java xml kotlin"></div>
```xml
<b:bean class="org.springframework.security.ldap.server.UnboundIdContainer"
    c:defaultPartitionSuffix="dc=springframework,dc=org"
    c:ldif="classpath:users.ldif"/>
```
<div class="language-only-for-kotlin java xml kotlin"></div>
```kotlin
@Bean
fun ldapContainer(): UnboundIdContainer {
    return UnboundIdContainer("dc=springframework,dc=org","classpath:users.ldif")
}
```

#### Embedded ApacheDS Server

>  스프링 시큐리티에서 사용하는 ApacheDS 1.x는 더 이상 유지보수하지 않고 있다. 안타깝게도 ApacheDS 2.x는 안정화된 릴리즈 버전은 없으며 마일스톤 버전만 있다. ApacheDS 2.x의 안정화된 릴리즈 버전이 배포되면 업데이트를 고려해 보겠다.

[Apache DS](https://directory.apache.org/apacheds/)를 사용하려면 아래 의존성을 추가해라:

**Example 69. ApacheDS Dependencies**

<div class="switch-language-wrapper maven gradle">
<span class="switch-language maven">maven</span>
<span class="switch-language gradle">gradle</span>
</div>
<div class="language-only-for-maven maven gradle"></div>
```xml
<dependency>
    <groupId>org.apache.directory.server</groupId>
    <artifactId>apacheds-core</artifactId>
    <version>1.5.5</version>
    <scope>runtime</scope>
</dependency>
<dependency>
    <groupId>org.apache.directory.server</groupId>
    <artifactId>apacheds-server-jndi</artifactId>
    <version>1.5.5</version>
    <scope>runtime</scope>
</dependency>
```
<div class="language-only-for-gradle maven gradle"></div>
```groovy
depenendencies {
    runtimeOnly "org.apache.directory.server:apacheds-core:1.5.5"
    runtimeOnly "org.apache.directory.server:apacheds-server-jndi:1.5.5"
}
```

그러면 임베디드 LDAP 서버를 설정할 수 있다.

**Example 70. Embedded LDAP Server Configuration**

<div class="switch-language-wrapper java xml kotlin">
<span class="switch-language java">java</span>
<span class="switch-language xml">xml</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java xml kotlin"></div>
```java
@Bean
ApacheDSContainer ldapContainer() {
    return new ApacheDSContainer("dc=springframework,dc=org",
                "classpath:users.ldif");
}
```
<div class="language-only-for-xml java xml kotlin"></div>
```xml
<b:bean class="org.springframework.security.ldap.server.ApacheDSContainer"
    c:defaultPartitionSuffix="dc=springframework,dc=org"
    c:ldif="classpath:users.ldif"/>
```
<div class="language-only-for-kotlin java xml kotlin"></div>
```kotlin
@Bean
fun ldapContainer(): ApacheDSContainer {
    return ApacheDSContainer("dc=springframework,dc=org", "classpath:users.ldif")
}
```

#### LDAP ContextSource

설정에서 사용할 LDAP 서버가 있다면, 스프링 시큐리티에서도 사용자를 인증할 때 사용할 LDAP 서버를 가리키도록 해야 한다. LDAP `ContextSource`를 생성하면 되는데, 이는 JDBC의 `DataSource`와 동일하다고 보면 된다.

<div class="switch-language-wrapper java xml kotlin">
<span class="switch-language java">java</span>
<span class="switch-language xml">xml</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java xml kotlin"></div>
```java
ContextSource contextSource(UnboundIdContainer container) {
    return new DefaultSpringSecurityContextSource("ldap://localhost:53389/dc=springframework,dc=org");
}
```
<div class="language-only-for-xml java xml kotlin"></div>
```xml
<ldap-server
    url="ldap://localhost:53389/dc=springframework,dc=org" />
```
<div class="language-only-for-kotlin java xml kotlin"></div>
```kotlin
fun contextSource(container: UnboundIdContainer): ContextSource {
    return DefaultSpringSecurityContextSource("ldap://localhost:53389/dc=springframework,dc=org")
}
```

#### Authentication

LDAP bind 인증을 사용하면 클라이언트에선 비밀번호는 물론, 비밀번호 해시값도 조회할 수 없으므로, 스프링 시큐리티의 LDAP은 [UserDetailsService](#10107-userdetailsservice)를 사용하지 않는다. 즉, 스프링 시큐리티에선 비밀번호를 조회한 후 인증할 수 없다는 뜻이다.

따라서 `LdapAuthenticator` 인터페이스로 LDAP을 지원한다. `LdapAuthenticator`는 필요한 모든 사용자의 속성을 조회하는 일도 담당한다. 사용하는 인증 유형에 따라 속성에 대한 권한이 다르기 때문이다. 예를 들어 사용자로 바인딩한다면 사용자 고유 권한으로 읽어야 할 수 있다.

스프링 시큐리티는 두 가지 `LdapAuthenticator` 구현체를 제공한다.

- [Using Bind Authentication](#using-bind-authentication)
- [Using Password Authentication](https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#servlet-authentication-ldap-pwd)

#### Using Bind Authentication

[Bind 인증](https://ldap.com/the-ldap-bind-operation/)은 LDAP에서 가장 많이 사용하는 사용자 인증 메커니즘이다. bind 인증에선 LDAP 서버로 사용자 credential을 (i.e. username/password) 전송하면 서버에서 이를 인증한다. bind 인증의 장점은 사용자의 비밀 정보 (i.e. 비밀번호)를 클라이언트에 노출할 필요가 없어서 유출될 가능성이 적다는 것이다.

다음은 bind 인증 설정 예시다:

**Example 72. Bind Authentication**

<div class="switch-language-wrapper java xml kotlin">
<span class="switch-language java">java</span>
<span class="switch-language xml">xml</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java xml kotlin"></div>
```java
@Bean
BindAuthenticator authenticator(BaseLdapPathContextSource contextSource) {
    BindAuthenticator authenticator = new BindAuthenticator(contextSource);
    authenticator.setUserDnPatterns(new String[] { "uid={0},ou=people" });
    return authenticator;
}

@Bean
LdapAuthenticationProvider authenticationProvider(LdapAuthenticator authenticator) {
    return new LdapAuthenticationProvider(authenticator);
}
```
<div class="language-only-for-xml java xml kotlin"></div>
```xml
<ldap-authentication-provider
    user-dn-pattern="uid={0},ou=people"/>
```
<div class="language-only-for-kotlin java xml kotlin"></div>
```kotlin
@Bean
fun authenticator(contextSource: BaseLdapPathContextSource): BindAuthenticator {
    val authenticator = BindAuthenticator(contextSource)
    authenticator.setUserDnPatterns(arrayOf("uid={0},ou=people"))
    return authenticator
}

@Bean
fun authenticationProvider(authenticator: LdapAuthenticator): LdapAuthenticationProvider {
    return LdapAuthenticationProvider(authenticator)
}
```

이 예제에서는 설정 패턴에 사용자의 로그인 이름을 적용하고, 비밀번호와 함께 사용자로 바인딩해 해당 사용자의 DN을 얻는다. 이 방법은 모든 사용자를 디렉토리 내 단일 노드에 저장했을 때 사용하는 방법이다. 사용자 위치를 찾기 위한 LDAP 검색 필터를 설정하려면 다음처럼 사용해야 한다:

**Example 73. Bind Authentication with Search Filter**

<div class="switch-language-wrapper java xml kotlin">
<span class="switch-language java">java</span>
<span class="switch-language xml">xml</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java xml kotlin"></div>
```java
@Bean
BindAuthenticator authenticator(BaseLdapPathContextSource contextSource) {
    String searchBase = "ou=people";
    String filter = "(uid={0})";
    FilterBasedLdapUserSearch search =
        new FilterBasedLdapUserSearch(searchBase, filter, contextSource);
    BindAuthenticator authenticator = new BindAuthenticator(contextSource);
    authenticator.setUserSearch(search);
    return authenticator;
}

@Bean
LdapAuthenticationProvider authenticationProvider(LdapAuthenticator authenticator) {
    return new LdapAuthenticationProvider(authenticator);
}
```
<div class="language-only-for-xml java xml kotlin"></div>
```xml
<ldap-authentication-provider
        user-dn-pattern="uid={0},ou=people">
    <password-compare />
</ldap-authentication-provider>
```
<div class="language-only-for-kotlin java xml kotlin"></div>
```kotlin
@Bean
fun authenticator(contextSource: BaseLdapPathContextSource): BindAuthenticator {
    val searchBase = "ou=people"
    val filter = "(uid={0})"
    val search = FilterBasedLdapUserSearch(searchBase, filter, contextSource)
    val authenticator = BindAuthenticator(contextSource)
    authenticator.setUserSearch(search)
    return authenticator
}

@Bean
fun authenticationProvider(authenticator: LdapAuthenticator): LdapAuthenticationProvider {
    return LdapAuthenticationProvider(authenticator)
}
```

[위에서 정의한](#ldap-contextsource) `ContextSource`를 사용하면 DN `ou=people,dc=springframework,dc=org`에서 `(uid={0})` 필터로 검색할 것이다. 다시 한 번 말하자면, 필터 이름 안에 있는 파라미터는 사용자 로그인 이름으로 대체되기 때문에 사용자 이름과 동일한 `uid` 속성을 가진 엔트리를 검색할 것이다. search base를 제공하지 않으면 루트에서 검색한다.

#### Using Password Authentication

비밀번호 비교 방식은 사용자가 제공한 비밀번호와 레포지토리에 저장된 비밀번호를 비교한다. 로컬에서 비밀번호 속성을 조회하고 검사할 수도 있고, LDAP "compare" 연산자를 실행해서 사용자가 제공한 비밀번호를 서버로 보내 서버에서 비교하고 로컬에서는 실제 비밀번호를 조회하지 않는 방법도 있다. 비밀번호를 랜덤 솔트(salt)와 함께 해싱했다면 LDAP compare를 실행할 수 없다.

**Example 74. Minimal Password Compare Configuration**

<div class="switch-language-wrapper java xml kotlin">
<span class="switch-language java">java</span>
<span class="switch-language xml">xml</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java xml kotlin"></div>
```java
@Bean
PasswordComparisonAuthenticator authenticator(BaseLdapPathContextSource contextSource) {
    return new PasswordComparisonAuthenticator(contextSource);
}

@Bean
LdapAuthenticationProvider authenticationProvider(LdapAuthenticator authenticator) {
    return new LdapAuthenticationProvider(authenticator);
}
```
<div class="language-only-for-xml java xml kotlin"></div>
```xml
<ldap-authentication-provider
        user-dn-pattern="uid={0},ou=people">
    <password-compare />
</ldap-authentication-provider>
```
<div class="language-only-for-kotlin java xml kotlin"></div>
```kotlin
@Bean
fun authenticator(contextSource: BaseLdapPathContextSource): PasswordComparisonAuthenticator {
    return PasswordComparisonAuthenticator(contextSource)
}

@Bean
fun authenticationProvider(authenticator: LdapAuthenticator): LdapAuthenticationProvider {
    return LdapAuthenticationProvider(authenticator)
}
```

다음은 커스텀을 적용한 고급 설정 예시다:

**Example 75. Password Compare Configuration**

<div class="switch-language-wrapper java xml kotlin">
<span class="switch-language java">java</span>
<span class="switch-language xml">xml</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java xml kotlin"></div>
```java
@Bean
PasswordComparisonAuthenticator authenticator(BaseLdapPathContextSource contextSource) {
    PasswordComparisonAuthenticator authenticator =
        new PasswordComparisonAuthenticator(contextSource);
    authenticator.setPasswordAttributeName("pwd"); // (1)
    authenticator.setPasswordEncoder(new BCryptPasswordEncoder()); // (2)
    return authenticator;
}

@Bean
LdapAuthenticationProvider authenticationProvider(LdapAuthenticator authenticator) {
    return new LdapAuthenticationProvider(authenticator);
}
```
<div class="language-only-for-xml java xml kotlin"></div>
```xml
<ldap-authentication-provider
        user-dn-pattern="uid={0},ou=people">
    <password-compare password-attribute="pwd"> <!-- (1) -->
        <password-encoder ref="passwordEncoder" /> <!-- (2) -->
    </password-compare>
</ldap-authentication-provider>
<b:bean id="passwordEncoder"
    class="org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder" />
```
<div class="language-only-for-kotlin java xml kotlin"></div>
```kotlin
@Bean
fun authenticator(contextSource: BaseLdapPathContextSource): PasswordComparisonAuthenticator {
    val authenticator = PasswordComparisonAuthenticator(contextSource)
    authenticator.setPasswordAttributeName("pwd") // (1)
    authenticator.setPasswordEncoder(BCryptPasswordEncoder()) // (2)
    return authenticator
}

@Bean
fun authenticationProvider(authenticator: LdapAuthenticator): LdapAuthenticationProvider {
    return LdapAuthenticationProvider(authenticator)
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 비밀번호 속성을 `pwd`로 지정한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> `BCryptPasswordEncoder`를 사용한다.</small>

#### LdapAuthoritiesPopulator

스프링 시큐리티는 `LdapAuthoritiesPopulator`로 사용자에게 돌려줄 권한을 결정한다.

**Example 76. Minimal Password Compare Configuration**

<div class="switch-language-wrapper java xml kotlin">
<span class="switch-language java">java</span>
<span class="switch-language xml">xml</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java xml kotlin"></div>
```java
@Bean
LdapAuthoritiesPopulator authorities(BaseLdapPathContextSource contextSource) {
    String groupSearchBase = "";
    DefaultLdapAuthoritiesPopulator authorities =
        new DefaultLdapAuthoritiesPopulator(contextSource, groupSearchBase);
    authorities.setGroupSearchFilter("member={0}");
    return authorities;
}

@Bean
LdapAuthenticationProvider authenticationProvider(LdapAuthenticator authenticator, LdapAuthoritiesPopulator authorities) {
    return new LdapAuthenticationProvider(authenticator, authorities);
}
```
<div class="language-only-for-xml java xml kotlin"></div>
```xml
<ldap-authentication-provider
    user-dn-pattern="uid={0},ou=people"
    group-search-filter="member={0}"/>
```
<div class="language-only-for-kotlin java xml kotlin"></div>
```kotlin
@Bean
fun authorities(contextSource: BaseLdapPathContextSource): LdapAuthoritiesPopulator {
    val groupSearchBase = ""
    val authorities = DefaultLdapAuthoritiesPopulator(contextSource, groupSearchBase)
    authorities.setGroupSearchFilter("member={0}")
    return authorities
}

@Bean
fun authenticationProvider(authenticator: LdapAuthenticator, authorities: LdapAuthoritiesPopulator): LdapAuthenticationProvider {
    return LdapAuthenticationProvider(authenticator, authorities)
}
```

#### Active Directory

Active Directory는 자체 비표준 인증 옵션을 지원하며, 일반적인 사용 패턴이 표준 `LdapAuthenticationProvider`에 그렇게 들어 맞지는 않는다. 보통 LDAP의 distinguished name이 아닌 도메인 username으로 (`user@domain` 양식) 인증한다. 스프링 시큐리티는 편의를 위해 전형적인 Active Directory 설정으로 커스텀한 인증 provider를 제공한다.

`ActiveDirectoryLdapAuthenticationProvider` 설정은 꽤 간단하다. 도메인 이름과 서버 주소를 제공할 LDAP URL만 설정하면 된다. 다음은 설정 예시이다:

**Example 77. Example Active Directory Configuration**

<div class="switch-language-wrapper java xml kotlin">
<span class="switch-language java">java</span>
<span class="switch-language xml">xml</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java xml kotlin"></div>
```java
@Bean
ActiveDirectoryLdapAuthenticationProvider authenticationProvider() {
    return new ActiveDirectoryLdapAuthenticationProvider("example.com", "ldap://company.example.com/");
}
```
<div class="language-only-for-xml java xml kotlin"></div>
```xml
<bean id="authenticationProvider"
        class="org.springframework.security.ldap.authentication.ad.ActiveDirectoryLdapAuthenticationProvider">
    <constructor-arg value="example.com" />
    <constructor-arg value="ldap://company.example.com/" />
</bean>
```
<div class="language-only-for-kotlin java xml kotlin"></div>
```kotlin
@Bean
fun authenticationProvider(): ActiveDirectoryLdapAuthenticationProvider {
    return ActiveDirectoryLdapAuthenticationProvider("example.com", "ldap://company.example.com/")
}
```

---

## 10.11. Session Management

HTTP 세션 관련 기능은 `SessionManagementFilter`와 필터가 위임하는 `SessionAuthenticationStrategy` 인터페이스가 처리한다. 전형적으로 session-fixation 공격을 방어하고, 세션 타임아웃을 감지하고, 인증된 사용자가 동시에 열 수 있는 세션 수를 제한하는 등에 사용한다.

### 10.11.1. Detecting Timeouts

스프링 시큐리티는 유효하지 않은 세션 ID를 제출하면 이를 감지해서 적절한 URL로 리다이렉트할 수 있다. 이는 `session-management` 요소로 설정한다.

```xml
<http>
...
<session-management invalid-session-url="/invalidSession.htm" />
</http>
```

이 메커니즘으로 세션 타임아웃도 감지하도록 설정했다면, 로그아웃한 사용자가 브라우저를 닫지 않고 다시 로그인했을 때 에러로 오인할 수 있다. 세션을 무효화할 때 세션 쿠키를 비우지 않으면 로그아웃했더라도 같은 쿠키를 제출하기 때문이다. 아래와 같은 방식으로 로그아웃할 때 로그아웃 핸들러에서 JSESSIONID 쿠키를 제거할 수 있다.

```xml
<http>
<logout delete-cookies="JSESSIONID" />
</http>
```

안타깝게도 모든 서블릿 컨테이너에서 동작하는지는 보장할 수 없으므로, 맞는 환경에서 테스트해봐야 한다.

> 어플리케이션 앞단에 프록시가 있다면 프록시 서버 설정으로도 세션 쿠키를 삭제할 수 있다. 예를 들어 아래와 같이 로그아웃 요청에 대한 응답에서 아파치 HTTPD의 mod_headers로 `JSESSIONID` 쿠키를 만료시킬 수 있다 (어플리케이션을 `/tutorial` 경로로 배포했다고 가정):
>
> ```xml
> <LocationMatch "/tutorial/logout">
> Header always set Set-Cookie "JSESSIONID=;Path=/tutorial;Expires=Thu, 01 Jan 1970 00:00:00 GMT"
> </LocationMatch>
> ```

### 10.11.2. Concurrent Session Control

스프링 시큐리티에서는 간단하게 몇 가지만 추가하면 같은 사용자가 여러 번 로그인할 수 없도록 제한할 수 있다. 먼저 `web.xml` 파일에 아래 리스너를 추가하면, 스프링 시큐리티는 세션 라이프사이클 이벤트를 통지받는다:

```xml
<listener>
<listener-class>
    org.springframework.security.web.session.HttpSessionEventPublisher
</listener-class>
</listener>
```

그 다음 어플리케이션 컨텍스트에 다음을 추가해라:

```xml
<http>
...
<session-management>
    <concurrency-control max-sessions="1" />
</session-management>
</http>
```

이렇게 하면 같은 사용자는 로그인을 여러 번 할 수 없다 - 이후 다시 로그인하면 그 전 로그인을 무효로 만든다. 재로그인을 아예 방지하려면 다음과 같이 사용해라:

```xml
<http>
...
<session-management>
    <concurrency-control max-sessions="1" error-if-maximum-exceeded="true" />
</session-management>
</http>
```

이제 두 번째 로그인부터는 거부한다. "거부"란, 폼 기반으로 로그인한 사용자는 `authentication-failure-url`로 이동됨을 의미한다. 두 번째 인증이 "remember-me"같은, 상호작용이 없는 다른 매커니즘을 통한 인증이었다면, "unauthorized" (401) 에러로 응답한다. 에러 페이지가 따로 있다면 `session-management` 요소에 `session-authentication-error-url` 속성을 추가하면 된다.

폼 기반 로그인에서 사용할 커스텀 인증 필터가 있다면 세션 동시 제어 설정을 명시해야 한다. 자세한 정보는 [세션 관리 챕터](#1011-session-management)를 참고하라.

### 10.11.3. Session Fixation Attack Protection

[Session fixation](https://en.wikipedia.org/wiki/Session_fixation) 공격은 사이트에 접근해서 세션을 생성한 뒤, 다른 사용자가 이 세션으로 로그인하도록 유도한다 (세션 식별자를 파라미터로 가지고 있는 링크를 보내는 식으로). 스프링 시큐리티는 사용자가 로그인하면 자동적으로 새 세션을 만들거나 세션 ID를 바꿔서 이 공격을 방어한다. 방어할 필요 없거나 다른 요구사항과 충돌이 있다면, `<session-management>`의 `session-fixation-protection` 속성으로 설정을 바꿀 수 있다. 사용할 수 있는 옵션은 네 가지다.

- `none` - 아무 일도 하지 않는다. 기존 세션을 유지한다.
- `newSession` - "깨끗한"새 세션을 만들고 기존 세션 데이터는 복사해 가지 않는다 (스프링 시큐리티 관련 속성은 복사한다).
- `migrateSession` - 새 세션을 만들고 기존 세션 속성을 모두 새 세션으로 복사한다. 서블릿 3.0과 이전 컨테이너에서 디폴트로 사용한다.
- `changeSessionId` - 새 세션을 만들지 않는다. 대신에 서블릿 컨테이너가 제공하는 방식으로 session fixation 공격을 방어한다 (`HttpServletRequest#changeSessionId()`). 이 옵션은 서블릿 3.1 (자바 EE 7)과 그 이상의 컨테이너에서만 사용할 수 있다. 구버전 컨테이너에서 이 옵션을 사용하면 예외가 발생한다. 서블릿 3.1과 이후 컨테이너에서 디폴트로 사용한다.

session fixation을 방어할 땐 어플리케이션 컨텍스트에서 `SessionFixationProtectionEvent`가 발생한다. `changeSessionId` 옵션으로 설정하면 모든 `javax.servlet.http.HttpSessionIdListener`*에도* 통보하므로, 어플리케이션이 두 이벤트를 모두 통보받도록 되어있다면 주의해서 사용해야 한다. 추가 정보는 [세션 관리](#1011-session-management) 챕터를 확인하라.

### 10.11.4. SessionManagementFilter

`SessionManagementFilter`는 `SecurityContextRepository` 컨텐츠를 `SecurityContextHolder`에 있는 현재 컨텐츠와 비교해서 현재 요청을 처리하는 동안 사용자를 인증했는지를 확인한다. 보통은 pre-authentication이나 remember-me같은 상호작용이 없는 인증에서 사용한다. 필터는 레포지토리에 인증 컨텍스트가 있으면 아무런 처리도 하지 않는다. 반대로 레포지토리에 인증 컨텍스트가 없고 스레드 로컬 `SecurityContext`에 (익명이 아닌) `Authentication` 객체가 있다면, 이전 필터에서 인증한 것으로 간주한다. 이땐 설정해둔 `SessionAuthenticationStrategy`를 실행한다.

현재 사용자가 인증된 사용자가 아니면 필터는 유효하지 않은 세션 ID로 요청됐는지 확인해서 (예를 들어 타임아웃 등으로) 설정해둔 `InvalidSessionStrategy`가 있으면 실행한다. 보통은 고정된 URL로 리다이렉트하는 식으로 가장 많이 사용하며, 표준 구현체 `SimpleRedirectInvalidSessionStrategy`로 캡슐화한다. 후자는 [앞에서 설명한 것처럼](#1011-session-management) 네임스페이스로 유효하지 않은 세션 요청을 리다이렉트할 URL을 설정할 때도 사용한다.

### 10.11.5. SessionAuthenticationStrategy

`SessionAuthenticationStrategy`는 `SessionManagementFilter`, `AbstractAuthenticationProcessingFilter` 둘 다 사용하므로 커스텀 폼 로그인 클래스를 만드는 등의 상황에선 둘 모두에 주입해줘야 한다. 네임스페이스와 커스텀 빈을 결합하는 전형적인 설정은 다음과 같다:

```xml
<http>
<custom-filter position="FORM_LOGIN_FILTER" ref="myAuthFilter" />
<session-management session-authentication-strategy-ref="sas"/>
</http>

<beans:bean id="myAuthFilter" class=
"org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter">
    <beans:property name="sessionAuthenticationStrategy" ref="sas" />
    ...
</beans:bean>

<beans:bean id="sas" class=
"org.springframework.security.web.authentication.session.SessionFixationProtectionStrategy" />
```

디폴트 `SessionFixationProtectionStrategy`를 사용한다면, `HttpSessionBindingListener`를 구현한 빈을 세션에 저장하면 제대로 동작하지 않을 수 있으며, 스프링 세션 스코프 빈도 마찬가지다. 자세한 정보는 `SessionFixationProtectionStrategy` Javadoc을 참고해라.

### 10.11.6. Concurrency Control

스프링 시큐리티는 접근 주체(principal)가 같은 어플리케이션에 동시에 인증할 수 있는 횟수를 제한할 수 있다. 많은 ISV는 이를 사용해서 라이센스를 관리하고, 네트워크 관리자는 사람들이 로그인 이름을 공유하는 것을 막는다. 예를 들어 "Batman"이란 사용자가 세션 2개로 웹 어플리케이션에 로그인하지 못하게 막을 수 있다. 이전 로그인을 만료시키거나 재로그인 시 에러를 발생시킬 수 있다. 두 번째 방법을 사용한다면 직접 로그인하지 않은 사용자는 (예를 들어 단순히 브라우저를 닫은 경우) 기존 세션이 만료되기 전까진 다시 로그인 할 수 없다는 점에 주의해야 한다.

동시성 제어는 네임스페이스로 지원한다. 최소 설정은 이전 네임스페이스 쳅터를 확인하라. 설정 일부를 커스텀해야 할 때도 있다.

동시성 제어는 `SessionAuthenticationStrategy`를 구현한 `ConcurrentSessionControlAuthenticationStrategy`가 담당한다.

> 이전에는 `ProviderManager`에 `ConcurrentSessionController`를 설정해서 동시 인증을 체크했다. `ConcurrentSessionController`는 사용자가 허용하는 세션 횟수를 넘겼는지 체크한다. 하지만 이 방법은 HTTP 세션을 미리 만들어야 해서 바람직하지 않다. 스프링 시큐리티 3에서는 `AuthenticationManager`가 먼저 사용자를 인증한 다음, 인증에 성공하면 세션을 만들고 다른 세션을 열수 있는지를 체크한다.

동시 세션을 제어하려면 먼저 `web.xml`에 다음을 추가해야 한다:

```xml
<listener>
    <listener-class>
    org.springframework.security.web.session.HttpSessionEventPublisher
    </listener-class>
</listener>
```

그다음 `FilterChainProxy`에 `ConcurrentSessionFilter`를 추가해야 한다. `ConcurrentSessionFilter`는 생성자에 2개의 인자가 필요하다. 일반적으로 `SessionRegistryImpl`을 가리키는 `sessionRegistry`와, 세션 만료 시 적용할 전략을 정의하는 `sessionInformationExpiredStrategy`다. 다음은 네임스페이스로 `FilterChainProxy`와 다른 디폴트 빈을 설정하는 예시다:

```xml
<http>
<custom-filter position="CONCURRENT_SESSION_FILTER" ref="concurrencyFilter" />
<custom-filter position="FORM_LOGIN_FILTER" ref="myAuthFilter" />

<session-management session-authentication-strategy-ref="sas"/>
</http>

<beans:bean id="redirectSessionInformationExpiredStrategy"
class="org.springframework.security.web.session.SimpleRedirectSessionInformationExpiredStrategy">
<beans:constructor-arg name="invalidSessionUrl" value="/session-expired.htm" />
</beans:bean>

<beans:bean id="concurrencyFilter"
class="org.springframework.security.web.session.ConcurrentSessionFilter">
<beans:constructor-arg name="sessionRegistry" ref="sessionRegistry" />
<beans:constructor-arg name="sessionInformationExpiredStrategy" ref="redirectSessionInformationExpiredStrategy" />
</beans:bean>

<beans:bean id="myAuthFilter" class=
"org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter">
<beans:property name="sessionAuthenticationStrategy" ref="sas" />
<beans:property name="authenticationManager" ref="authenticationManager" />
</beans:bean>

<beans:bean id="sas" class="org.springframework.security.web.authentication.session.CompositeSessionAuthenticationStrategy">
<beans:constructor-arg>
    <beans:list>
    <beans:bean class="org.springframework.security.web.authentication.session.ConcurrentSessionControlAuthenticationStrategy">
        <beans:constructor-arg ref="sessionRegistry"/>
        <beans:property name="maximumSessions" value="1" />
        <beans:property name="exceptionIfMaximumExceeded" value="true" />
    </beans:bean>
    <beans:bean class="org.springframework.security.web.authentication.session.SessionFixationProtectionStrategy">
    </beans:bean>
    <beans:bean class="org.springframework.security.web.authentication.session.RegisterSessionAuthenticationStrategy">
        <beans:constructor-arg ref="sessionRegistry"/>
    </beans:bean>
    </beans:list>
</beans:constructor-arg>
</beans:bean>

<beans:bean id="sessionRegistry"
    class="org.springframework.security.core.session.SessionRegistryImpl" />
```

`web.xml`에 리스너를 추가하면 `HttpSession`을 시작하고 종료할 때마다 스프링 `ApplicationContext`에 `ApplicationEvent`를 발생시킨다. 세션이 끝나면 `SessionRegistryImpl`에 통지할 수 있기 때문에 매우 중요한 기능이다. 리스너가 없다면, 세션 허용치를 초과한 사용자는 다른 세션을 로그아웃하거나 타임아웃이 나도 절대 다시 로그인할 수 없을 것이다.

#### Querying the SessionRegistry for currently authenticated users and their sessions

네임스페이스을 사용했던 일반 빈을 사용했던, 동시성 제어를 설정했다면 어플리케이션에서 직접 `SessionRegistry`를 참조할 수 있다. 따라서 사용자의 세션 수를 제한하고 싶지 않더라도 동시성 제어를 설정하는 건 나름의 가치가 있다. 세션을 제한하지 않으려면 `maximumSession` 프로퍼티를 -1로 설정하면 된다. 네임스페이스를 사용한다면 `session-registry-alias` 속성으로 내부에서 생성한 `SessionRegistry`의 alias를 설정할 수 있으며, 다른 원하는 빈에 주입할 때 참조로 사용할 수 있다.

`getAllPrincipals()` 메소드는 현재 인증된 사용자 리스트를 제공한다. `getAllSessions(Object principal, boolean includeExpiredSessions)` 메소드는 사용자의 세션 리스트를 `SessionInformation` 객체 리스트로 리턴한다. `SessionInformation` 인스턴스의 `expireNow()` 메소드를 호출하면 세션을 만료시킬 수도 있다. 사용자가 다시 돌아왔을 때는 다른 작업을 이어갈 수 없을 것이다. 어드민성 어플리케이션 등에선 이 메런 메소드가 유용할 것이다. 자세한 정보는 Javadoc을 참고하라.

---

## 10.12. Remember-Me Authentication

### 10.12.1. Overview

Remember-me 또는 persistent-login 인증은 인증 주체(principal)의 식별자를 기억하고 여러 세션에 사용할 수 있는 웹사이트를 말한다. 보통 브라우저에서 전송한 쿠키를 이후 세션에서 감지하고 자동으로 로그인하는 식으로 동작한다. 스프링 시큐리티는 이를 위한 훅과 두 가지 remember-me 구현체를 제공한다. 구현체 하나는 쿠키 기반 토큰을 해시로 보호하고, 다른 하나는 데이터베이스 등의 영구 스토리지 메커니즘으로 토큰을 저장한다.

두 구현체 모두 `UserDetailsService`가 있어야 한다는 점을 주의해라. `UserDetailsService`를 사용하지 않는 인증 provider를 쓴다면 (LDAP provider 등), 어플리케이션 컨텍스트에 `UserDetailsService` 빈을 따로 추가하지 않으면 동작하지 않는다.

### 10.12.2. Simple Hash-Based Token Approach

이 방법은 해시를 사용해서 remember-me 전략을 구현한다. 쿠키는 본질적으로 인증 상호작용에 성공하면 브라우저가 보내는 값이며, 다음과 같이 구성된다:

```txt
base64(username + ":" + expirationTime + ":" +
md5Hex(username + ":" + expirationTime + ":" password + ":" + key))

username:          As identifiable to the UserDetailsService
password:          That matches the one in the retrieved UserDetails
expirationTime:    The date and time when the remember-me token expires, expressed in milliseconds
key:               A private key to prevent modification of the remember-me token
```

따라서 remember-me 토큰은 명시한 기간에만 유효하며, 사용자 이름이나 비밀번호, 키가 변경되면 더 이상 유효하지 않다. 특히 remember-me 토큰은 유출되면 만료되기 전까지 모든 user agent에서 사용할 수 있다는 보안 이슈가 있다. 다이제스트 인증을 사용할 때와 같은 이슈다. 인증 주체(principal)가 토큰이 탈취됐음을 알 수 있다면 비밀번호를 바꿔서 즉시 모든 remember-me 토큰을 무효화시킬 수 있다. 보안이 더 중요한 서비스라면 다음 섹션에 있는 방법을 사용해야 한다. 아니면 차라리 remember-me 인증을 사용하지 말아야 한다.

[네임스페이스 설정](https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#ns-config) 챕터에 있는 주제가 익숙하다면, `<remember-me>` 요소만 더하면 remember-me 인증을 활성화할 수 있다:

```xml
<http>
...
<remember-me key="myAppKey"/>
</http>
```

보통은 자동으로 `UserDetailsService`를 선택한다. 어플리케이션에 `UserDetailsService`가 둘 이상이라면 `user-service-ref` 속성에 `UserDetailsService` 사용할 빈 이름을 지정해야 한다.

### 10.12.3. Persistent Token Approach

이 방법은 http://jaspan.com/improved_persistent_login_cookie_best_practice 문서를 기반으로 동작하며, 사소하게 수정된 부분도 있다. 네임스페이스 설정으로 이 방법을 사용하려면 데이터소스 레퍼런스를 제공해야 한다:

```xml
<http>
...
<remember-me data-source-ref="someDataSource"/>
</http>
```

데이터베이스엔 아래 SQL로 생성한 (또는 이와 동일한) `persistent_logins` 테이블이 있어야 한다:

```ddl
create table persistent_logins (username varchar(64) not null,
                                series varchar(64) primary key,
                                token varchar(64) not null,
                                last_used timestamp not null)
```

### 10.12.4. Remember-Me Interfaces and Implementations

Remember-me는`UsernamePasswordAuthenticationFilter`와 사용하며, `AbstractAuthenticationProcessingFilter` 클래스에 있는 훅으로 구현한다. `BasicAuthenticationFilter`와도 사용할 수 있다. 훅에선 적당할 때 `RememberMeServices` 구현체를 실행한다. 인터페이스는 다음과 같다:

```java
Authentication autoLogin(HttpServletRequest request, HttpServletResponse response);

void loginFail(HttpServletRequest request, HttpServletResponse response);

void loginSuccess(HttpServletRequest request, HttpServletResponse response,
    Authentication successfulAuthentication);
```

여기선 `AbstractAuthenticationProcessingFilter`는 `loginFail()`과 `loginSuccess()`만 호출한다는 점만 기억해두자. 메소드가 하는 일은 Javadoc에 자세히 나와있다. `SecurityContextHolder`에 `Authentication`이 없으면 `RememberMeAuthenticationFilter`는 항상 `autoLogin()` 메소드를 호출한다. 따라서 이 인터페이스는 기본적으로 remember-me 구현체를 제공하며, 인증 관련 이벤트를 통지해주고, 웹 요청에 있는 쿠키를 기억해야할 때 구현체에 위임해 준다. 이 설계 덕분에 remember-me 구현 전략을 얼마든지 적용할 수 있다. 위에서 스프링 시큐리티는 두 구현체를 제공한다고 했는데, 이제 차례대로 살펴볼 것이다.

#### TokenBasedRememberMeServices

이 구현체는 [Simple Hash-Based Token Approach](#10122-simple-hash-based-token-approach)에서 설명한 더 간단한 접근 방식을 구현한다. `TokenBasedRememberMeServices`는 `RememberMeAuthenticationToken`을 생성하며, 이는 `RememberMeAuthenticationProvider`가 처리한다. 이 인증 provider와 `TokenBasedRememberMeServices`는 `key`를 공유한다. `TokenBasedRememberMeServices`는 서명을 비교할 때 사용자 이름과 비밀번호를 조회하기 위해 UserDetailsService 하나가 필요하며, 올바른 `GrantedAuthority` 여러 개를 가지고 있는 `RememberMeAuthenticationToken`을 생성한다. 로그아웃 명령은 사용자가 요청했을 때 어플리케이션에서 쿠키를 무효화하는 식으로 구현해야 한다. `TokenBasedRememberMeServices`는 스프링 시큐리티의 `LogoutHandler`도 구현하고 있기 때문에 `LogoutFilter`를 함께 사용하면 자동으로 쿠키를 비울 수 있다.

remember-me 서비스를 활성화하려면 다음과 같은 빈을 어플리케이션 컨텍스트에 추가해야 한다:

```xml
<bean id="rememberMeFilter" class=
"org.springframework.security.web.authentication.rememberme.RememberMeAuthenticationFilter">
<property name="rememberMeServices" ref="rememberMeServices"/>
<property name="authenticationManager" ref="theAuthenticationManager" />
</bean>

<bean id="rememberMeServices" class=
"org.springframework.security.web.authentication.rememberme.TokenBasedRememberMeServices">
<property name="userDetailsService" ref="myUserDetailsService"/>
<property name="key" value="springRocks"/>
</bean>

<bean id="rememberMeAuthenticationProvider" class=
"org.springframework.security.authentication.RememberMeAuthenticationProvider">
<property name="key" value="springRocks"/>
</bean>
```

`RememberMeServices` 구현체는 `UsernamePasswordAuthenticationFilter.setRememberMeServices()` 프로퍼티에, `RememberMeAuthenticationProvider`는 `AuthenticationManager.setProviders()` 리스트에, `RememberMeAuthenticationFilter`는 `FilterChainProxy`에 (보통 `UsernamePasswordAuthenticationFilter` 바로 다음에) 추가해야한 다는 점을 잊지 말자.

#### PersistentTokenBasedRememberMeServices

이 클래스도 `TokenBasedRememberMeServices`처럼 사용할 수 있지만, 토큰을 저장할 `PersistentTokenRepository`를 추가로 설정해야 한다. 표준 구현체는 두 가지가 있다:

- 테스트 전용 `InMemoryTokenRepositoryImpl`
- 데이터베이스에 토큰을 저장하는 `JdbcTokenRepositoryImpl`

데이터베이스 스키마는 위의 [Persistent Token Approach](#10123-persistent-token-approach) 섹션에 나와 있다.

---

## 10.13. OpenID Support

네임스페이스는 [OpenID](https://openid.net/) 로그인을 지원하며, 일반적인 폼 기반 로그인을 약간만 바꿔서 함께 사용할 수도 있다.

```xml
<http>
<intercept-url pattern="/**" access="ROLE_USER" />
<openid-login />
</http>
```

그다음엔 OpenID 제공자에 사용할 사이트를 등록하고 (myopenid.com 등) 인메모리 `<user-service>`에 사용자 정보를 추가해야 한다:

```xml
<user name="https://jimi.hendrix.myopenid.com/" authorities="ROLE_USER" />
```

인증하려면 `myopenid.com` 사이트로 로그인할 수 있어야 한다. `openid-login` 요소에 있는 `user-service-ref` 속성을 설정하면 OpenID를 사용할 `UserDetailsService`를 지정할 수 있다. 위에 있는 사용자 데이터는 해당 사용자의 권한을 로드할때만 사용하기 때문에, 비밀번호 속성은 생략했다. 내부적으로는 비밀번호를 랜덤으로 생성해서 다른 설정에서 이 사용자 데이터로 인증할 수 없게 방지한다.

### 10.13.1. Attribute Exchange

OpenID [attribute exchange](https://openid.net/specs/openid-attribute-exchange-1_0.html)를 지원한다. 예를 들어 다음 설정은 OpenID 제공자로부터 이메일과 이름 전체를 받아오기 위한 어플리케이션 설정이다:

```xml
<openid-login>
<attribute-exchange>
    <openid-attribute name="email" type="https://axschema.org/contact/email" required="true"/>
    <openid-attribute name="name" type="https://axschema.org/namePerson"/>
</attribute-exchange>
</openid-login>
```

OpenID 속성에서 사용하는 "type"은 특정 스키마로 결정하는 URI를 가리킨다 (여기선 https://axschema.org/). 인증에 꼭 필요한 속성은 `required`로 지정한다. 정확한 스키마와 속성은 OpenID 제공자에따라 다르다. 인증을 처리할 때 속성값을 반환하며, 이후엔 다음과 같은 코드로 접근할 수 있다:

```java
OpenIDAuthenticationToken token =
    (OpenIDAuthenticationToken)SecurityContextHolder.getContext().getAuthentication();
List<OpenIDAttribute> attributes = token.getAttributes();
```

`OpenIDAuthenticationToken`은 [SecurityContextHolder](#101-securitycontextholder)에서 얻을 수 있다. `OpenIDAttribute`는 속성 타입과 획득한 값을 가지고 있다 (속성에 따라 값이 여러 개일 수 있음). `attribute-exchange` 요소를 여러 개 사용할 수도 있는데, 이땐 요소마다 `identifier-matcher` 속성을 사용한다. 이 속성은 사용자가 제공하는 OpenID 식별자와 매치할 정규식을 가지고 있다. 설정 예시는 코드에 있는 OpenID 샘플 어플리케이션을 참고하라. 구글 야후, MyOpenID 제공자에서 지원하는 각 속성 리스트를 제공한다.

---

## 10.14. Anonymous Authentication

### 10.14.1. Overview

보안에서 주로 권장하는 방식은 허용할 것을 명시하고 나머지는 허용하지 않는 "deny-by-default"다. 특히 웹 어플리케이션이라면, 유사하게 인증하지 않은 사용하가 접근할 수 있는 페이지를 정의할 수 있다. 많은 사이트에서 몇 가지 URL만 (홈이나 로그인 페이지) 제외하고는 인증을 요구한다. 이럴 때는 모든 안전한 리소스를 명시하는 것보다 접근을 허용할 몇 가지 URL만 가지고 접근 속성을 설정하는 게 가장 쉽다. 달리 말하면, 디폴트로 `ROLE_SOMETHING`이 필요하다고 정의하고 로그인이나 로그아웃, 기본 홈 등에서만 이 룰에 예외를 적용하는 게 나을 때가 많다. 원한다면 이런 예외 페이지들을 필터 체인을 완전히 생략해서 접근 제어를 우회할 수 있지만, 인증된 사용자에게는 다른 정보를 보여주는 페이지였다거나 하는 이유로 바람직하지 않을 수 있다.

이게 익명 인증이 의미하는 바이다. "익명으로 인증된" 사용자와 "인증되지 않은 사용자"는 개념적으로 아무 차이가 없다. 스프링 시큐리티의 익명 인증은 그저 접근 제어 속성을 좀 더 편리하게 설정하게 해줄 뿐이다. 예를 들어 `getCallerPrincipal`같은 서블릿 API를 호출하면 null을 리턴하는 건 마찬가지지만, 실제로 `SecurityContextHolder`에는 익명 인증 객체가 담겨있다.

익명 인증이 유용한 경우가 또 있는데, 권한을 확인하는 인터셉터에서 `SecurityContextHolder`를 사용해 principal이 해당 작업을 실행할 권한이 있는지 확인할 때가 그렇다. `SecurityContextHolder`엔 항상 `null`이 아닌 `Authentication` 객체가 있다는 점을 알면 좀 더 견고한 방법으로 권한을 부여할 수 있다.

### 10.14.2. Configuration

스프링 시큐리티 3.0 HTTP 설정을 사용하면 자동으로 익명 인증을 지원하며 `<anonymous>` 요소로 커스텀하거나 비활성화할 수 있다. 전통적인 빈 설정을 사용하고 있지 않으면 여기 있는 빈을 설정할 필요는 없다.

익명 인증 기능은 세 가지 클래스가 함께 제공한다. `AnonymousAuthenticationToken`은 `Authentication` 구현체로, 익명 principal에 적용할 여러 `GrantedAuthority`를 저장한다. 이에 맞는 `AnonymousAuthenticationProvider`가 `ProviderManager`에 연결되면 `AnonymousAuthenticationToken`을 허용한다. 마지막으로 `AnonymousAuthenticationFilter`가 있다. 이 필터는 일반적인 인증 매커니즘 이후 연결되며, `SecurityContextHolder`에 `Authentication`이 없으면 자동으로 `AnonymousAuthenticationToken`을 추가한다. 필터와 인증 provider 정의는 다음과 같다:

```xml
<bean id="anonymousAuthFilter"
    class="org.springframework.security.web.authentication.AnonymousAuthenticationFilter">
<property name="key" value="foobar"/>
<property name="userAttribute" value="anonymousUser,ROLE_ANONYMOUS"/>
</bean>

<bean id="anonymousAuthenticationProvider"
    class="org.springframework.security.authentication.AnonymousAuthenticationProvider">
<property name="key" value="foobar"/>
</bean>
```

필터와 인증 provider가 동일한 `key`를 공유하므로, 인증 provider는 필터가 생성한 토큰을 수용한다. `userAttribute`는 `usernameInTheAuthenticationToken,grantedAuthority[,grantedAuthority]` 형식으로 표현한다. `InMemoryDaoImpl`의 `userMap` 프로퍼티에서 등호 뒤에 사용하는 문법과 동일하다.

앞에서 말했듯이 익명 인증을 사용하면 모든 URI 패턴에 보안을 적용할 수 있다. 예를 들어:

```xml
<bean id="filterSecurityInterceptor"
    class="org.springframework.security.web.access.intercept.FilterSecurityInterceptor">
<property name="authenticationManager" ref="authenticationManager"/>
<property name="accessDecisionManager" ref="httpRequestAccessDecisionManager"/>
<property name="securityMetadata">
    <security:filter-security-metadata-source>
    <security:intercept-url pattern='/index.jsp' access='ROLE_ANONYMOUS,ROLE_USER'/>
    <security:intercept-url pattern='/hello.htm' access='ROLE_ANONYMOUS,ROLE_USER'/>
    <security:intercept-url pattern='/logoff.jsp' access='ROLE_ANONYMOUS,ROLE_USER'/>
    <security:intercept-url pattern='/login.jsp' access='ROLE_ANONYMOUS,ROLE_USER'/>
    <security:intercept-url pattern='/**' access='ROLE_USER'/>
    </security:filter-security-metadata-source>" +
</property>
</bean>
```

### 10.14.3. AuthenticationTrustResolver

Rounding out the anonymous authentication discussion is the `AuthenticationTrustResolver` interface, with its corresponding `AuthenticationTrustResolverImpl` implementation. This interface provides an `isAnonymous(Authentication)` method, which allows interested classes to take into account this special type of authentication status. The `ExceptionTranslationFilter` uses this interface in processing `AccessDeniedException` s. If an `AccessDeniedException` is thrown, and the authentication is of an anonymous type, instead of throwing a 403 (forbidden) response, the filter will instead commence the `AuthenticationEntryPoint` so the principal can authenticate properly. This is a necessary distinction, otherwise principals would always be deemed "authenticated" and never be given an opportunity to login via form, basic, digest or some other normal authentication mechanism.

You will often see the `ROLE_ANONYMOUS` attribute in the above interceptor configuration replaced with `IS_AUTHENTICATED_ANONYMOUSLY`, which is effectively the same thing when defining access controls. This is an example of the use of the `AuthenticatedVoter` which we will see in the [authorization chapter](https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#authz-authenticated-voter). It uses an `AuthenticationTrustResolver` to process this particular configuration attribute and grant access to anonymous users. The `AuthenticatedVoter` approach is more powerful, since it allows you to differentiate between anonymous, remember-me and fully-authenticated users. If you don’t need this functionality though, then you can stick with `ROLE_ANONYMOUS`, which will be processed by Spring Security’s standard `RoleVoter`.

---

## 10.15. Pre-Authentication Scenarios

There are situations where you want to use Spring Security for authorization, but the user has already been reliably authenticated by some external system prior to accessing the application. We refer to these situations as "pre-authenticated" scenarios. Examples include X.509, Siteminder and authentication by the Java EE container in which the application is running. When using pre-authentication, Spring Security has to

- Identify the user making the request.
- Obtain the authorities for the user.

The details will depend on the external authentication mechanism. A user might be identified by their certificate information in the case of X.509, or by an HTTP request header in the case of Siteminder. If relying on container authentication, the user will be identified by calling the `getUserPrincipal()` method on the incoming HTTP request. In some cases, the external mechanism may supply role/authority information for the user but in others the authorities must be obtained from a separate source, such as a `UserDetailsService`.

### 10.15.1. Pre-Authentication Framework Classes

Because most pre-authentication mechanisms follow the same pattern, Spring Security has a set of classes which provide an internal framework for implementing pre-authenticated authentication providers. This removes duplication and allows new implementations to be added in a structured fashion, without having to write everything from scratch. You don’t need to know about these classes if you want to use something like [X.509 authentication](#1018-x509-authentication), as it already has a namespace configuration option which is simpler to use and get started with. If you need to use explicit bean configuration or are planning on writing your own implementation then an understanding of how the provided implementations work will be useful. You will find classes under the `org.springframework.security.web.authentication.preauth`. We just provide an outline here so you should consult the Javadoc and source where appropriate.

#### AbstractPreAuthenticatedProcessingFilter

This class will check the current contents of the security context and, if empty, it will attempt to extract user information from the HTTP request and submit it to the `AuthenticationManager`. Subclasses override the following methods to obtain this information:

```java
protected abstract Object getPreAuthenticatedPrincipal(HttpServletRequest request);

protected abstract Object getPreAuthenticatedCredentials(HttpServletRequest request);
```

After calling these, the filter will create a `PreAuthenticatedAuthenticationToken` containing the returned data and submit it for authentication. By "authentication" here, we really just mean further processing to perhaps load the user’s authorities, but the standard Spring Security authentication architecture is followed.

Like other Spring Security authentication filters, the pre-authentication filter has an `authenticationDetailsSource` property which by default will create a `WebAuthenticationDetails` object to store additional information such as the session-identifier and originating IP address in the `details` property of the `Authentication` object. In cases where user role information can be obtained from the pre-authentication mechanism, the data is also stored in this property, with the details implementing the `GrantedAuthoritiesContainer` interface. This enables the authentication provider to read the authorities which were externally allocated to the user. We’ll look at a concrete example next.

#### J2eeBasedPreAuthenticatedWebAuthenticationDetailsSource

If the filter is configured with an `authenticationDetailsSource` which is an instance of this class, the authority information is obtained by calling the `isUserInRole(String role)` method for each of a pre-determined set of "mappable roles". The class gets these from a configured `MappableAttributesRetriever`. Possible implementations include hard-coding a list in the application context and reading the role information from the `<security-role>` information in a `web.xml` file. The pre-authentication sample application uses the latter approach.

There is an additional stage where the roles (or attributes) are mapped to Spring Security `GrantedAuthority` objects using a configured `Attributes2GrantedAuthoritiesMapper`. The default will just add the usual `ROLE_` prefix to the names, but it gives you full control over the behaviour.

#### PreAuthenticatedAuthenticationProvider

The pre-authenticated provider has little more to do than load the `UserDetails` object for the user. It does this by delegating to an `AuthenticationUserDetailsService`. The latter is similar to the standard `UserDetailsService` but takes an `Authentication` object rather than just user name:

```java
public interface AuthenticationUserDetailsService {
    UserDetails loadUserDetails(Authentication token) throws UsernameNotFoundException;
}
```

This interface may have also other uses but with pre-authentication it allows access to the authorities which were packaged in the `Authentication` object, as we saw in the previous section. The `PreAuthenticatedGrantedAuthoritiesUserDetailsService` class does this. Alternatively, it may delegate to a standard `UserDetailsService` via the `UserDetailsByNameServiceWrapper` implementation.

#### Http403ForbiddenEntryPoint

The [`AuthenticationEntryPoint`](#108-request-credentials-with-authenticationentrypoint) is responsible for kick-starting the authentication process for an unauthenticated user (when they try to access a protected resource), but in the pre-authenticated case this doesn’t apply. You would only configure the `ExceptionTranslationFilter` with an instance of this class if you aren’t using pre-authentication in combination with other authentication mechanisms. It will be called if the user is rejected by the `AbstractPreAuthenticatedProcessingFilter` resulting in a null authentication. It always returns a `403`-forbidden response code if called.

### 10.15.2. Concrete Implementations

X.509 authentication is covered in its [own chapter](#1018-x509-authentication). Here we’ll look at some classes which provide support for other pre-authenticated scenarios.

#### Request-Header Authentication (Siteminder)

An external authentication system may supply information to the application by setting specific headers on the HTTP request. A well-known example of this is Siteminder, which passes the username in a header called `SM_USER`. This mechanism is supported by the class `RequestHeaderAuthenticationFilter` which simply extracts the username from the header. It defaults to using the name `SM_USER` as the header name. See the Javadoc for more details.

>  Note that when using a system like this, the framework performs no authentication checks at all and it is *extremely* important that the external system is configured properly and protects all access to the application. If an attacker is able to forge the headers in their original request without this being detected then they could potentially choose any username they wished.

#### Siteminder Example Configuration

A typical configuration using this filter would look like this:

```xml
<security:http>
<!-- Additional http configuration omitted -->
<security:custom-filter position="PRE_AUTH_FILTER" ref="siteminderFilter" />
</security:http>

<bean id="siteminderFilter" class="org.springframework.security.web.authentication.preauth.RequestHeaderAuthenticationFilter">
<property name="principalRequestHeader" value="SM_USER"/>
<property name="authenticationManager" ref="authenticationManager" />
</bean>

<bean id="preauthAuthProvider" class="org.springframework.security.web.authentication.preauth.PreAuthenticatedAuthenticationProvider">
<property name="preAuthenticatedUserDetailsService">
    <bean id="userDetailsServiceWrapper"
        class="org.springframework.security.core.userdetails.UserDetailsByNameServiceWrapper">
    <property name="userDetailsService" ref="userDetailsService"/>
    </bean>
</property>
</bean>

<security:authentication-manager alias="authenticationManager">
<security:authentication-provider ref="preauthAuthProvider" />
</security:authentication-manager>
```

We’ve assumed here that the [security namespace](https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#ns-config) is being used for configuration. It’s also assumed that you have added a `UserDetailsService` (called "userDetailsService") to your configuration to load the user’s roles.

#### Java EE Container Authentication

The class `J2eePreAuthenticatedProcessingFilter` will extract the username from the `userPrincipal` property of the `HttpServletRequest`. Use of this filter would usually be combined with the use of Java EE roles as described above in [J2eeBasedPreAuthenticatedWebAuthenticationDetailsSource](https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#j2ee-preauth-details).

There is a sample application in the codebase which uses this approach, so get hold of the code from github and have a look at the application context file if you are interested. The code is in the `samples/xml/preauth` directory.

---

## 10.16. Java Authentication and Authorization Service (JAAS) Provider

### 10.16.1. Overview

Spring Security provides a package able to delegate authentication requests to the Java Authentication and Authorization Service (JAAS). This package is discussed in detail below.

### 10.16.2. AbstractJaasAuthenticationProvider

The `AbstractJaasAuthenticationProvider` is the basis for the provided JAAS `AuthenticationProvider` implementations. Subclasses must implement a method that creates the `LoginContext`. The `AbstractJaasAuthenticationProvider` has a number of dependencies that can be injected into it that are discussed below.

#### JAAS CallbackHandler

Most JAAS `LoginModule` s require a callback of some sort. These callbacks are usually used to obtain the username and password from the user.

In a Spring Security deployment, Spring Security is responsible for this user interaction (via the authentication mechanism). Thus, by the time the authentication request is delegated through to JAAS, Spring Security’s authentication mechanism will already have fully-populated an `Authentication` object containing all the information required by the JAAS `LoginModule`.

Therefore, the JAAS package for Spring Security provides two default callback handlers, `JaasNameCallbackHandler` and `JaasPasswordCallbackHandler`. Each of these callback handlers implement `JaasAuthenticationCallbackHandler`. In most cases these callback handlers can simply be used without understanding the internal mechanics.

For those needing full control over the callback behavior, internally `AbstractJaasAuthenticationProvider` wraps these `JaasAuthenticationCallbackHandler` s with an `InternalCallbackHandler`. The `InternalCallbackHandler` is the class that actually implements JAAS normal `CallbackHandler` interface. Any time that the JAAS `LoginModule` is used, it is passed a list of application context configured `InternalCallbackHandler` s. If the `LoginModule` requests a callback against the `InternalCallbackHandler` s, the callback is in-turn passed to the `JaasAuthenticationCallbackHandler` s being wrapped.

#### JAAS AuthorityGranter

JAAS works with principals. Even "roles" are represented as principals in JAAS. Spring Security, on the other hand, works with `Authentication` objects. Each `Authentication` object contains a single principal, and multiple `GrantedAuthority` s. To facilitate mapping between these different concepts, Spring Security’s JAAS package includes an `AuthorityGranter` interface.

An `AuthorityGranter` is responsible for inspecting a JAAS principal and returning a set of `String` s, representing the authorities assigned to the principal. For each returned authority string, the `AbstractJaasAuthenticationProvider` creates a `JaasGrantedAuthority` (which implements Spring Security’s `GrantedAuthority` interface) containing the authority string and the JAAS principal that the `AuthorityGranter` was passed. The `AbstractJaasAuthenticationProvider` obtains the JAAS principals by firstly successfully authenticating the user’s credentials using the JAAS `LoginModule`, and then accessing the `LoginContext` it returns. A call to `LoginContext.getSubject().getPrincipals()` is made, with each resulting principal passed to each `AuthorityGranter` defined against the `AbstractJaasAuthenticationProvider.setAuthorityGranters(List)` property.

Spring Security does not include any production `AuthorityGranter` s given that every JAAS principal has an implementation-specific meaning. However, there is a `TestAuthorityGranter` in the unit tests that demonstrates a simple `AuthorityGranter` implementation.

### 10.16.3. DefaultJaasAuthenticationProvider

The `DefaultJaasAuthenticationProvider` allows a JAAS `Configuration` object to be injected into it as a dependency. It then creates a `LoginContext` using the injected JAAS `Configuration`. This means that `DefaultJaasAuthenticationProvider` is not bound any particular implementation of `Configuration` as `JaasAuthenticationProvider` is.

#### InMemoryConfiguration

In order to make it easy to inject a `Configuration` into `DefaultJaasAuthenticationProvider`, a default in-memory implementation named `InMemoryConfiguration` is provided. The implementation constructor accepts a `Map` where each key represents a login configuration name and the value represents an `Array` of `AppConfigurationEntry` s. `InMemoryConfiguration` also supports a default `Array` of `AppConfigurationEntry` objects that will be used if no mapping is found within the provided `Map`. For details, refer to the class level javadoc of `InMemoryConfiguration`.

#### DefaultJaasAuthenticationProvider Example Configuration

While the Spring configuration for `InMemoryConfiguration` can be more verbose than the standarad JAAS configuration files, using it in conjuction with `DefaultJaasAuthenticationProvider` is more flexible than `JaasAuthenticationProvider` since it not dependant on the default `Configuration` implementation.

An example configuration of `DefaultJaasAuthenticationProvider` using `InMemoryConfiguration` is provided below. Note that custom implementations of `Configuration` can easily be injected into `DefaultJaasAuthenticationProvider` as well.

```xml
<bean id="jaasAuthProvider"
class="org.springframework.security.authentication.jaas.DefaultJaasAuthenticationProvider">
<property name="configuration">
<bean class="org.springframework.security.authentication.jaas.memory.InMemoryConfiguration">
<constructor-arg>
    <map>
    <!--
    SPRINGSECURITY is the default loginContextName
    for AbstractJaasAuthenticationProvider
    -->
    <entry key="SPRINGSECURITY">
    <array>
    <bean class="javax.security.auth.login.AppConfigurationEntry">
        <constructor-arg value="sample.SampleLoginModule" />
        <constructor-arg>
        <util:constant static-field=
            "javax.security.auth.login.AppConfigurationEntry$LoginModuleControlFlag.REQUIRED"/>
        </constructor-arg>
        <constructor-arg>
        <map></map>
        </constructor-arg>
        </bean>
    </array>
    </entry>
    </map>
    </constructor-arg>
</bean>
</property>
<property name="authorityGranters">
<list>
    <!-- You will need to write your own implementation of AuthorityGranter -->
    <bean class="org.springframework.security.authentication.jaas.TestAuthorityGranter"/>
</list>
</property>
</bean>
```

### 10.16.4. JaasAuthenticationProvider

The `JaasAuthenticationProvider` assumes the default `Configuration` is an instance of [ConfigFile](https://download.oracle.com/javase/1.4.2/docs/guide/security/jaas/spec/com/sun/security/auth/login/ConfigFile.html). This assumption is made in order to attempt to update the `Configuration`. The `JaasAuthenticationProvider` then uses the default `Configuration` to create the `LoginContext`.

Let’s assume we have a JAAS login configuration file, `/WEB-INF/login.conf`, with the following contents:

```txt
JAASTest {
    sample.SampleLoginModule required;
};
```

Like all Spring Security beans, the `JaasAuthenticationProvider` is configured via the application context. The following definitions would correspond to the above JAAS login configuration file:

```xml
<bean id="jaasAuthenticationProvider"
class="org.springframework.security.authentication.jaas.JaasAuthenticationProvider">
<property name="loginConfig" value="/WEB-INF/login.conf"/>
<property name="loginContextName" value="JAASTest"/>
<property name="callbackHandlers">
<list>
<bean
    class="org.springframework.security.authentication.jaas.JaasNameCallbackHandler"/>
<bean
    class="org.springframework.security.authentication.jaas.JaasPasswordCallbackHandler"/>
</list>
</property>
<property name="authorityGranters">
    <list>
    <bean class="org.springframework.security.authentication.jaas.TestAuthorityGranter"/>
    </list>
</property>
</bean>
```

### 10.16.5. Running as a Subject

If configured, the `JaasApiIntegrationFilter` will attempt to run as the `Subject` on the `JaasAuthenticationToken`. This means that the `Subject` can be accessed using:

```java
Subject subject = Subject.getSubject(AccessController.getContext());
```

This integration can easily be configured using the [jaas-api-provision](https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#nsa-http-jaas-api-provision) attribute. This feature is useful when integrating with legacy or external API’s that rely on the JAAS Subject being populated.

---

## 10.17. CAS Authentication

### 10.17.1. Overview

JA-SIG produces an enterprise-wide single sign on system known as CAS. Unlike other initiatives, JA-SIG’s Central Authentication Service is open source, widely used, simple to understand, platform independent, and supports proxy capabilities. Spring Security fully supports CAS, and provides an easy migration path from single-application deployments of Spring Security through to multiple-application deployments secured by an enterprise-wide CAS server.

You can learn more about CAS at [https://www.apereo.org](https://www.apereo.org/). You will also need to visit this site to download the CAS Server files.

### 10.17.2. How CAS Works

Whilst the CAS web site contains documents that detail the architecture of CAS, we present the general overview again here within the context of Spring Security. Spring Security 3.x supports CAS 3. At the time of writing, the CAS server was at version 3.4.

Somewhere in your enterprise you will need to setup a CAS server. The CAS server is simply a standard WAR file, so there isn’t anything difficult about setting up your server. Inside the WAR file you will customise the login and other single sign on pages displayed to users.

When deploying a CAS 3.4 server, you will also need to specify an `AuthenticationHandler` in the `deployerConfigContext.xml` included with CAS. The `AuthenticationHandler` has a simple method that returns a boolean as to whether a given set of Credentials is valid. Your `AuthenticationHandler` implementation will need to link into some type of backend authentication repository, such as an LDAP server or database. CAS itself includes numerous `AuthenticationHandler` s out of the box to assist with this. When you download and deploy the server war file, it is set up to successfully authenticate users who enter a password matching their username, which is useful for testing.

Apart from the CAS server itself, the other key players are of course the secure web applications deployed throughout your enterprise. These web applications are known as "services". There are three types of services. Those that authenticate service tickets, those that can obtain proxy tickets, and those that authenticate proxy tickets. Authenticating a proxy ticket differs because the list of proxies must be validated and often times a proxy ticket can be reused.

#### Spring Security and CAS Interaction Sequence

The basic interaction between a web browser, CAS server and a Spring Security-secured service is as follows:

- The web user is browsing the service’s public pages. CAS or Spring Security is not involved.
- The user eventually requests a page that is either secure or one of the beans it uses is secure. Spring Security’s `ExceptionTranslationFilter` will detect the `AccessDeniedException` or `AuthenticationException`.
- Because the user’s `Authentication` object (or lack thereof) caused an `AuthenticationException`, the `ExceptionTranslationFilter` will call the configured `AuthenticationEntryPoint`. If using CAS, this will be the `CasAuthenticationEntryPoint` class.
- The `CasAuthenticationEntryPoint` will redirect the user’s browser to the CAS server. It will also indicate a `service` parameter, which is the callback URL for the Spring Security service (your application). For example, the URL to which the browser is redirected might be https://my.company.com/cas/login?service=https%3A%2F%2Fserver3.company.com%2Fwebapp%2Flogin/cas.
- After the user’s browser redirects to CAS, they will be prompted for their username and password. If the user presents a session cookie which indicates they’ve previously logged on, they will not be prompted to login again (there is an exception to this procedure, which we’ll cover later). CAS will use the `PasswordHandler` (or `AuthenticationHandler` if using CAS 3.0) discussed above to decide whether the username and password is valid.
- Upon successful login, CAS will redirect the user’s browser back to the original service. It will also include a `ticket` parameter, which is an opaque string representing the "service ticket". Continuing our earlier example, the URL the browser is redirected to might be https://server3.company.com/webapp/login/cas?ticket=ST-0-ER94xMJmn6pha35CQRoZ.
- Back in the service web application, the `CasAuthenticationFilter` is always listening for requests to `/login/cas` (this is configurable, but we’ll use the defaults in this introduction). The processing filter will construct a `UsernamePasswordAuthenticationToken` representing the service ticket. The principal will be equal to `CasAuthenticationFilter.CAS_STATEFUL_IDENTIFIER`, whilst the credentials will be the service ticket opaque value. This authentication request will then be handed to the configured `AuthenticationManager`.
- The `AuthenticationManager` implementation will be the `ProviderManager`, which is in turn configured with the `CasAuthenticationProvider`. The `CasAuthenticationProvider` only responds to `UsernamePasswordAuthenticationToken` s containing the CAS-specific principal (such as `CasAuthenticationFilter.CAS_STATEFUL_IDENTIFIER`) and `CasAuthenticationToken` s (discussed later).
- `CasAuthenticationProvider` will validate the service ticket using a `TicketValidator` implementation. This will typically be a `Cas20ServiceTicketValidator` which is one of the classes included in the CAS client library. In the event the application needs to validate proxy tickets, the `Cas20ProxyTicketValidator` is used. The `TicketValidator` makes an HTTPS request to the CAS server in order to validate the service ticket. It may also include a proxy callback URL, which is included in this example: https://my.company.com/cas/proxyValidate?service=https%3A%2F%2Fserver3.company.com%2Fwebapp%2Flogin/cas&ticket=ST-0-ER94xMJmn6pha35CQRoZ&pgtUrl=https://server3.company.com/webapp/login/cas/proxyreceptor.
- Back on the CAS server, the validation request will be received. If the presented service ticket matches the service URL the ticket was issued to, CAS will provide an affirmative response in XML indicating the username. If any proxy was involved in the authentication (discussed below), the list of proxies is also included in the XML response.
- [OPTIONAL] If the request to the CAS validation service included the proxy callback URL (in the `pgtUrl` parameter), CAS will include a `pgtIou` string in the XML response. This `pgtIou` represents a proxy-granting ticket IOU. The CAS server will then create its own HTTPS connection back to the `pgtUrl`. This is to mutually authenticate the CAS server and the claimed service URL. The HTTPS connection will be used to send a proxy granting ticket to the original web application. For example, https://server3.company.com/webapp/login/cas/proxyreceptor?pgtIou=PGTIOU-0-R0zlgrl4pdAQwBvJWO3vnNpevwqStbSGcq3vKB2SqSFFRnjPHt&pgtId=PGT-1-si9YkkHLrtACBo64rmsi3v2nf7cpCResXg5MpESZFArbaZiOKH.
- The `Cas20TicketValidator` will parse the XML received from the CAS server. It will return to the `CasAuthenticationProvider` a `TicketResponse`, which includes the username (mandatory), proxy list (if any were involved), and proxy-granting ticket IOU (if the proxy callback was requested).
- Next `CasAuthenticationProvider` will call a configured `CasProxyDecider`. The `CasProxyDecider` indicates whether the proxy list in the `TicketResponse` is acceptable to the service. Several implementations are provided with Spring Security: `RejectProxyTickets`, `AcceptAnyCasProxy` and `NamedCasProxyDecider`. These names are largely self-explanatory, except `NamedCasProxyDecider` which allows a `List` of trusted proxies to be provided.
- `CasAuthenticationProvider` will next request a `AuthenticationUserDetailsService` to load the `GrantedAuthority` objects that apply to the user contained in the `Assertion`.
- If there were no problems, `CasAuthenticationProvider` constructs a `CasAuthenticationToken` including the details contained in the `TicketResponse` and the `GrantedAuthority`s.
- Control then returns to `CasAuthenticationFilter`, which places the created `CasAuthenticationToken` in the security context.
- The user’s browser is redirected to the original page that caused the `AuthenticationException` (or a custom destination depending on the configuration).

It’s good that you’re still here! Let’s now look at how this is configured

### 10.17.3. Configuration of CAS Client

The web application side of CAS is made easy due to Spring Security. It is assumed you already know the basics of using Spring Security, so these are not covered again below. We’ll assume a namespace based configuration is being used and add in the CAS beans as required. Each section builds upon the previous section. A full CAS sample application can be found in the Spring Security [Samples](https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#samples).

#### Service Ticket Authentication

This section describes how to setup Spring Security to authenticate Service Tickets. Often times this is all a web application requires. You will need to add a `ServiceProperties` bean to your application context. This represents your CAS service:

```xml
<bean id="serviceProperties"
    class="org.springframework.security.cas.ServiceProperties">
<property name="service"
    value="https://localhost:8443/cas-sample/login/cas"/>
<property name="sendRenew" value="false"/>
</bean>
```

The `service` must equal a URL that will be monitored by the `CasAuthenticationFilter`. The `sendRenew` defaults to false, but should be set to true if your application is particularly sensitive. What this parameter does is tell the CAS login service that a single sign on login is unacceptable. Instead, the user will need to re-enter their username and password in order to gain access to the service.

The following beans should be configured to commence the CAS authentication process (assuming you’re using a namespace configuration):

```xml
<security:http entry-point-ref="casEntryPoint">
...
<security:custom-filter position="CAS_FILTER" ref="casFilter" />
</security:http>

<bean id="casFilter"
    class="org.springframework.security.cas.web.CasAuthenticationFilter">
<property name="authenticationManager" ref="authenticationManager"/>
</bean>

<bean id="casEntryPoint"
    class="org.springframework.security.cas.web.CasAuthenticationEntryPoint">
<property name="loginUrl" value="https://localhost:9443/cas/login"/>
<property name="serviceProperties" ref="serviceProperties"/>
</bean>
```

For CAS to operate, the `ExceptionTranslationFilter` must have its `authenticationEntryPoint` property set to the `CasAuthenticationEntryPoint` bean. This can easily be done using [entry-point-ref](https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#nsa-http-entry-point-ref) as is done in the example above. The `CasAuthenticationEntryPoint` must refer to the `ServiceProperties` bean (discussed above), which provides the URL to the enterprise’s CAS login server. This is where the user’s browser will be redirected.

The `CasAuthenticationFilter` has very similar properties to the `UsernamePasswordAuthenticationFilter` (used for form-based logins). You can use these properties to customize things like behavior for authentication success and failure.

Next you need to add a `CasAuthenticationProvider` and its collaborators:

```xml
<security:authentication-manager alias="authenticationManager">
<security:authentication-provider ref="casAuthenticationProvider" />
</security:authentication-manager>

<bean id="casAuthenticationProvider"
    class="org.springframework.security.cas.authentication.CasAuthenticationProvider">
<property name="authenticationUserDetailsService">
    <bean class="org.springframework.security.core.userdetails.UserDetailsByNameServiceWrapper">
    <constructor-arg ref="userService" />
    </bean>
</property>
<property name="serviceProperties" ref="serviceProperties" />
<property name="ticketValidator">
    <bean class="org.jasig.cas.client.validation.Cas20ServiceTicketValidator">
    <constructor-arg index="0" value="https://localhost:9443/cas" />
    </bean>
</property>
<property name="key" value="an_id_for_this_auth_provider_only"/>
</bean>

<security:user-service id="userService">
<!-- Password is prefixed with {noop} to indicate to DelegatingPasswordEncoder that
NoOpPasswordEncoder should be used.
This is not safe for production, but makes reading
in samples easier.
Normally passwords should be hashed using BCrypt -->
<security:user name="joe" password="{noop}joe" authorities="ROLE_USER" />
...
</security:user-service>
```

The `CasAuthenticationProvider` uses a `UserDetailsService` instance to load the authorities for a user, once they have been authenticated by CAS. We’ve shown a simple in-memory setup here. Note that the `CasAuthenticationProvider` does not actually use the password for authentication, but it does use the authorities.

The beans are all reasonably self-explanatory if you refer back to the [How CAS Works](https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#cas-how-it-works) section.

This completes the most basic configuration for CAS. If you haven’t made any mistakes, your web application should happily work within the framework of CAS single sign on. No other parts of Spring Security need to be concerned about the fact CAS handled authentication. In the following sections we will discuss some (optional) more advanced configurations.

#### Single Logout

The CAS protocol supports Single Logout and can be easily added to your Spring Security configuration. Below are updates to the Spring Security configuration that handle Single Logout

```xml
<security:http entry-point-ref="casEntryPoint">
...
<security:logout logout-success-url="/cas-logout.jsp"/>
<security:custom-filter ref="requestSingleLogoutFilter" before="LOGOUT_FILTER"/>
<security:custom-filter ref="singleLogoutFilter" before="CAS_FILTER"/>
</security:http>

<!-- This filter handles a Single Logout Request from the CAS Server -->
<bean id="singleLogoutFilter" class="org.jasig.cas.client.session.SingleSignOutFilter"/>

<!-- This filter redirects to the CAS Server to signal Single Logout should be performed -->
<bean id="requestSingleLogoutFilter"
    class="org.springframework.security.web.authentication.logout.LogoutFilter">
<constructor-arg value="https://localhost:9443/cas/logout"/>
<constructor-arg>
    <bean class=
        "org.springframework.security.web.authentication.logout.SecurityContextLogoutHandler"/>
</constructor-arg>
<property name="filterProcessesUrl" value="/logout/cas"/>
</bean>
```

The `logout` element logs the user out of the local application, but does not terminate the session with the CAS server or any other applications that have been logged into. The `requestSingleLogoutFilter` filter will allow the URL of `/spring_security_cas_logout` to be requested to redirect the application to the configured CAS Server logout URL. Then the CAS Server will send a Single Logout request to all the services that were signed into. The `singleLogoutFilter` handles the Single Logout request by looking up the `HttpSession` in a static `Map` and then invalidating it.

It might be confusing why both the `logout` element and the `singleLogoutFilter` are needed. It is considered best practice to logout locally first since the `SingleSignOutFilter` just stores the `HttpSession` in a static `Map` in order to call invalidate on it. With the configuration above, the flow of logout would be:

- The user requests `/logout` which would log the user out of the local application and send the user to the logout success page.
- The logout success page, `/cas-logout.jsp`, should instruct the user to click a link pointing to `/logout/cas` in order to logout out of all applications.
- When the user clicks the link, the user is redirected to the CAS single logout URL (https://localhost:9443/cas/logout).
- On the CAS Server side, the CAS single logout URL then submits single logout requests to all the CAS Services. On the CAS Service side, JASIG’s `SingleSignOutFilter` processes the logout request by invalidating the original session.

The next step is to add the following to your web.xml

```xml
<filter>
<filter-name>characterEncodingFilter</filter-name>
<filter-class>
    org.springframework.web.filter.CharacterEncodingFilter
</filter-class>
<init-param>
    <param-name>encoding</param-name>
    <param-value>UTF-8</param-value>
</init-param>
</filter>
<filter-mapping>
<filter-name>characterEncodingFilter</filter-name>
<url-pattern>/*</url-pattern>
</filter-mapping>
<listener>
<listener-class>
    org.jasig.cas.client.session.SingleSignOutHttpSessionListener
</listener-class>
</listener>
```

When using the SingleSignOutFilter you might encounter some encoding issues. Therefore it is recommended to add the `CharacterEncodingFilter` to ensure that the character encoding is correct when using the `SingleSignOutFilter`. Again, refer to JASIG’s documentation for details. The `SingleSignOutHttpSessionListener` ensures that when an `HttpSession` expires, the mapping used for single logout is removed.

#### Authenticating to a Stateless Service with CAS

This section describes how to authenticate to a service using CAS. In other words, this section discusses how to setup a client that uses a service that authenticates with CAS. The next section describes how to setup a stateless service to Authenticate using CAS.

#### Configuring CAS to Obtain Proxy Granting Tickets

In order to authenticate to a stateless service, the application needs to obtain a proxy granting ticket (PGT). This section describes how to configure Spring Security to obtain a PGT building upon thencas-st[Service Ticket Authentication] configuration.

The first step is to include a `ProxyGrantingTicketStorage` in your Spring Security configuration. This is used to store PGT’s that are obtained by the `CasAuthenticationFilter` so that they can be used to obtain proxy tickets. An example configuration is shown below

```xml
<!--
NOTE: In a real application you should not use an in memory implementation.
You will also want to ensure to clean up expired tickets by calling
ProxyGrantingTicketStorage.cleanup()
-->
<bean id="pgtStorage" class="org.jasig.cas.client.proxy.ProxyGrantingTicketStorageImpl"/>
```

The next step is to update the `CasAuthenticationProvider` to be able to obtain proxy tickets. To do this replace the `Cas20ServiceTicketValidator` with a `Cas20ProxyTicketValidator`. The `proxyCallbackUrl` should be set to a URL that the application will receive PGT’s at. Last, the configuration should also reference the `ProxyGrantingTicketStorage` so it can use a PGT to obtain proxy tickets. You can find an example of the configuration changes that should be made below.

```xml
<bean id="casAuthenticationProvider"
    class="org.springframework.security.cas.authentication.CasAuthenticationProvider">
...
<property name="ticketValidator">
    <bean class="org.jasig.cas.client.validation.Cas20ProxyTicketValidator">
    <constructor-arg value="https://localhost:9443/cas"/>
        <property name="proxyCallbackUrl"
        value="https://localhost:8443/cas-sample/login/cas/proxyreceptor"/>
    <property name="proxyGrantingTicketStorage" ref="pgtStorage"/>
    </bean>
</property>
</bean>
```

The last step is to update the `CasAuthenticationFilter` to accept PGT and to store them in the `ProxyGrantingTicketStorage`. It is important the `proxyReceptorUrl` matches the `proxyCallbackUrl` of the `Cas20ProxyTicketValidator`. An example configuration is shown below.

```xml
<bean id="casFilter"
        class="org.springframework.security.cas.web.CasAuthenticationFilter">
    ...
    <property name="proxyGrantingTicketStorage" ref="pgtStorage"/>
    <property name="proxyReceptorUrl" value="/login/cas/proxyreceptor"/>
</bean>
```

#### Calling a Stateless Service Using a Proxy Ticket

Now that Spring Security obtains PGTs, you can use them to create proxy tickets which can be used to authenticate to a stateless service. The CAS [sample application](https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#samples) contains a working example in the `ProxyTicketSampleServlet`. Example code can be found below:

```java
protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
// NOTE: The CasAuthenticationToken can also be obtained using
// SecurityContextHolder.getContext().getAuthentication()
final CasAuthenticationToken token = (CasAuthenticationToken) request.getUserPrincipal();
// proxyTicket could be reused to make calls to the CAS service even if the
// target url differs
final String proxyTicket = token.getAssertion().getPrincipal().getProxyTicketFor(targetUrl);

// Make a remote call using the proxy ticket
final String serviceUrl = targetUrl+"?ticket="+URLEncoder.encode(proxyTicket, "UTF-8");
String proxyResponse = CommonUtils.getResponseFromServer(serviceUrl, "UTF-8");
...
}
```

#### Proxy Ticket Authentication

The `CasAuthenticationProvider` distinguishes between stateful and stateless clients. A stateful client is considered any that submits to the `filterProcessUrl` of the `CasAuthenticationFilter`. A stateless client is any that presents an authentication request to `CasAuthenticationFilter` on a URL other than the `filterProcessUrl`.

Because remoting protocols have no way of presenting themselves within the context of an `HttpSession`, it isn’t possible to rely on the default practice of storing the security context in the session between requests. Furthermore, because the CAS server invalidates a ticket after it has been validated by the `TicketValidator`, presenting the same proxy ticket on subsequent requests will not work.

One obvious option is to not use CAS at all for remoting protocol clients. However, this would eliminate many of the desirable features of CAS. As a middle-ground, the `CasAuthenticationProvider` uses a `StatelessTicketCache`. This is used solely for stateless clients which use a principal equal to `CasAuthenticationFilter.CAS_STATELESS_IDENTIFIER`. What happens is the `CasAuthenticationProvider` will store the resulting `CasAuthenticationToken` in the `StatelessTicketCache`, keyed on the proxy ticket. Accordingly, remoting protocol clients can present the same proxy ticket and the `CasAuthenticationProvider` will not need to contact the CAS server for validation (aside from the first request). Once authenticated, the proxy ticket could be used for URLs other than the original target service.

This section builds upon the previous sections to accommodate proxy ticket authentication. The first step is to specify to authenticate all artifacts as shown below.

```xml
<bean id="serviceProperties"
    class="org.springframework.security.cas.ServiceProperties">
...
<property name="authenticateAllArtifacts" value="true"/>
</bean>
```

The next step is to specify `serviceProperties` and the `authenticationDetailsSource` for the `CasAuthenticationFilter`. The `serviceProperties` property instructs the `CasAuthenticationFilter` to attempt to authenticate all artifacts instead of only ones present on the `filterProcessUrl`. The `ServiceAuthenticationDetailsSource` creates a `ServiceAuthenticationDetails` that ensures the current URL, based upon the `HttpServletRequest`, is used as the service URL when validating the ticket. The method for generating the service URL can be customized by injecting a custom `AuthenticationDetailsSource` that returns a custom `ServiceAuthenticationDetails`.

```xml
<bean id="casFilter"
    class="org.springframework.security.cas.web.CasAuthenticationFilter">
...
<property name="serviceProperties" ref="serviceProperties"/>
<property name="authenticationDetailsSource">
    <bean class=
    "org.springframework.security.cas.web.authentication.ServiceAuthenticationDetailsSource">
    <constructor-arg ref="serviceProperties"/>
    </bean>
</property>
</bean>
```

You will also need to update the `CasAuthenticationProvider` to handle proxy tickets. To do this replace the `Cas20ServiceTicketValidator` with a `Cas20ProxyTicketValidator`. You will need to configure the `statelessTicketCache` and which proxies you want to accept. You can find an example of the updates required to accept all proxies below.

```xml
<bean id="casAuthenticationProvider"
    class="org.springframework.security.cas.authentication.CasAuthenticationProvider">
...
<property name="ticketValidator">
    <bean class="org.jasig.cas.client.validation.Cas20ProxyTicketValidator">
    <constructor-arg value="https://localhost:9443/cas"/>
    <property name="acceptAnyProxy" value="true"/>
    </bean>
</property>
<property name="statelessTicketCache">
    <bean class="org.springframework.security.cas.authentication.EhCacheBasedTicketCache">
    <property name="cache">
        <bean class="net.sf.ehcache.Cache"
            init-method="initialise" destroy-method="dispose">
        <constructor-arg value="casTickets"/>
        <constructor-arg value="50"/>
        <constructor-arg value="true"/>
        <constructor-arg value="false"/>
        <constructor-arg value="3600"/>
        <constructor-arg value="900"/>
        </bean>
    </property>
    </bean>
</property>
</bean>
```

---

## 10.18. X.509 Authentication

### 10.18.1. Overview

The most common use of X.509 certificate authentication is in verifying the identity of a server when using SSL, most commonly when using HTTPS from a browser. The browser will automatically check that the certificate presented by a server has been issued (ie digitally signed) by one of a list of trusted certificate authorities which it maintains.

You can also use SSL with "mutual authentication"; the server will then request a valid certificate from the client as part of the SSL handshake. The server will authenticate the client by checking that its certificate is signed by an acceptable authority. If a valid certificate has been provided, it can be obtained through the servlet API in an application. Spring Security X.509 module extracts the certificate using a filter. It maps the certificate to an application user and loads that user’s set of granted authorities for use with the standard Spring Security infrastructure.

You should be familiar with using certificates and setting up client authentication for your servlet container before attempting to use it with Spring Security. Most of the work is in creating and installing suitable certificates and keys. For example, if you’re using Tomcat then read the instructions here https://tomcat.apache.org/tomcat-6.0-doc/ssl-howto.html. It’s important that you get this working before trying it out with Spring Security

### 10.18.2. Adding X.509 Authentication to Your Web Application

Enabling X.509 client authentication is very straightforward. Just add the `<x509/>` element to your http security namespace configuration.

```xml
<http>
...
    <x509 subject-principal-regex="CN=(.*?)," user-service-ref="userService"/>;
</http>
```

The element has two optional attributes:

- `subject-principal-regex`. The regular expression used to extract a username from the certificate’s subject name. The default value is shown above. This is the username which will be passed to the `UserDetailsService` to load the authorities for the user.
- `user-service-ref`. This is the bean Id of the `UserDetailsService` to be used with X.509. It isn’t needed if there is only one defined in your application context.

The `subject-principal-regex` should contain a single group. For example the default expression "CN=(.*?)," matches the common name field. So if the subject name in the certificate is "CN=Jimi Hendrix, OU=…", this will give a user name of "Jimi Hendrix". The matches are case insensitive. So "emailAddress=(.*?)," will match "EMAILADDRESS=[jimi@hendrix.org](mailto:jimi@hendrix.org),CN=…" giving a user name "[jimi@hendrix.org](mailto:jimi@hendrix.org)". If the client presents a certificate and a valid username is successfully extracted, then there should be a valid `Authentication` object in the security context. If no certificate is found, or no corresponding user could be found then the security context will remain empty. This means that you can easily use X.509 authentication with other options such as a form-based login.

### 10.18.3. Setting up SSL in Tomcat

There are some pre-generated certificates in the `samples/certificate` directory in the Spring Security project. You can use these to enable SSL for testing if you don’t want to generate your own. The file `server.jks` contains the server certificate, private key and the issuing certificate authority certificate. There are also some client certificate files for the users from the sample applications. You can install these in your browser to enable SSL client authentication.

To run tomcat with SSL support, drop the `server.jks` file into the tomcat `conf` directory and add the following connector to the `server.xml` file

```xml
<Connector port="8443" protocol="HTTP/1.1" SSLEnabled="true" scheme="https" secure="true"
            clientAuth="true" sslProtocol="TLS"
            keystoreFile="${catalina.home}/conf/server.jks"
            keystoreType="JKS" keystorePass="password"
            truststoreFile="${catalina.home}/conf/server.jks"
            truststoreType="JKS" truststorePass="password"
/>
```

`clientAuth` can also be set to `want` if you still want SSL connections to succeed even if the client doesn’t provide a certificate. Clients which don’t present a certificate won’t be able to access any objects secured by Spring Security unless you use a non-X.509 authentication mechanism, such as form authentication.

---

## 10.19. Run-As Authentication Replacement

### 10.19.1. Overview

The `AbstractSecurityInterceptor` is able to temporarily replace the `Authentication` object in the `SecurityContext` and `SecurityContextHolder` during the secure object callback phase. This only occurs if the original `Authentication` object was successfully processed by the `AuthenticationManager` and `AccessDecisionManager`. The `RunAsManager` will indicate the replacement `Authentication` object, if any, that should be used during the `SecurityInterceptorCallback`.

By temporarily replacing the `Authentication` object during the secure object callback phase, the secured invocation will be able to call other objects which require different authentication and authorization credentials. It will also be able to perform any internal security checks for specific `GrantedAuthority` objects. Because Spring Security provides a number of helper classes that automatically configure remoting protocols based on the contents of the `SecurityContextHolder`, these run-as replacements are particularly useful when calling remote web services

### 10.19.2. Configuration

A `RunAsManager` interface is provided by Spring Security:

```java
Authentication buildRunAs(Authentication authentication, Object object,
    List<ConfigAttribute> config);

boolean supports(ConfigAttribute attribute);

boolean supports(Class clazz);
```

The first method returns the `Authentication` object that should replace the existing `Authentication` object for the duration of the method invocation. If the method returns `null`, it indicates no replacement should be made. The second method is used by the `AbstractSecurityInterceptor` as part of its startup validation of configuration attributes. The `supports(Class)` method is called by a security interceptor implementation to ensure the configured `RunAsManager` supports the type of secure object that the security interceptor will present.

One concrete implementation of a `RunAsManager` is provided with Spring Security. The `RunAsManagerImpl` class returns a replacement `RunAsUserToken` if any `ConfigAttribute` starts with `RUN_AS_`. If any such `ConfigAttribute` is found, the replacement `RunAsUserToken` will contain the same principal, credentials and granted authorities as the original `Authentication` object, along with a new `SimpleGrantedAuthority` for each `RUN_AS_` `ConfigAttribute`. Each new `SimpleGrantedAuthority` will be prefixed with `ROLE_`, followed by the `RUN_AS` `ConfigAttribute`. For example, a `RUN_AS_SERVER` will result in the replacement `RunAsUserToken` containing a `ROLE_RUN_AS_SERVER` granted authority.

The replacement `RunAsUserToken` is just like any other `Authentication` object. It needs to be authenticated by the `AuthenticationManager`, probably via delegation to a suitable `AuthenticationProvider`. The `RunAsImplAuthenticationProvider` performs such authentication. It simply accepts as valid any `RunAsUserToken` presented.

To ensure malicious code does not create a `RunAsUserToken` and present it for guaranteed acceptance by the `RunAsImplAuthenticationProvider`, the hash of a key is stored in all generated tokens. The `RunAsManagerImpl` and `RunAsImplAuthenticationProvider` is created in the bean context with the same key:

```xml
<bean id="runAsManager"
    class="org.springframework.security.access.intercept.RunAsManagerImpl">
<property name="key" value="my_run_as_password"/>
</bean>

<bean id="runAsAuthenticationProvider"
    class="org.springframework.security.access.intercept.RunAsImplAuthenticationProvider">
<property name="key" value="my_run_as_password"/>
</bean>
```

By using the same key, each `RunAsUserToken` can be validated it was created by an approved `RunAsManagerImpl`. The `RunAsUserToken` is immutable after creation for security reasons

---

## 10.20. Handling Logouts

### 10.20.1. Logout Java Configuration

When using the `WebSecurityConfigurerAdapter`, logout capabilities are automatically applied. The default is that accessing the URL `/logout` will log the user out by:

- Invalidating the HTTP Session
- Cleaning up any RememberMe authentication that was configured
- Clearing the `SecurityContextHolder`
- Redirect to `/login?logout`

Similar to configuring login capabilities, however, you also have various options to further customize your logout requirements:

```java
protected void configure(HttpSecurity http) throws Exception {
    http
        .logout(logout -> logout                              // (1)
            .logoutUrl("/my/logout")                          // (2)
            .logoutSuccessUrl("/my/index")                    // (3)
            .logoutSuccessHandler(logoutSuccessHandler)       // (4)
            .invalidateHttpSession(true)                      // (5)
            .addLogoutHandler(logoutHandler)                  // (6)
            .deleteCookies(cookieNamesToClear)                // (7)
        )
        ...
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> Provides logout support. This is automatically applied when using `WebSecurityConfigurerAdapter`.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)The URL that triggers log out to occur (default is `/logout`). If CSRF protection is enabled (default), then the request must also be a POST. For more information, please consult the [JavaDoc](https://docs.spring.io/spring-security/site/docs/current/api/org/springframework/security/config/annotation/web/configurers/LogoutConfigurer.html#logoutUrl-java.lang.String-).</span> </small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> The URL to redirect to after logout has occurred. The default is `/login?logout`. For more information, please consult the [JavaDoc](https://docs.spring.io/spring-security/site/docs/current/api/org/springframework/security/config/annotation/web/configurers/LogoutConfigurer.html#logoutSuccessUrl-java.lang.String-).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> Let’s you specify a custom `LogoutSuccessHandler`. If this is specified, `logoutSuccessUrl()` is ignored. For more information, please consult the [JavaDoc](https://docs.spring.io/spring-security/site/docs/current/api/org/springframework/security/config/annotation/web/configurers/LogoutConfigurer.html#logoutSuccessHandler-org.springframework.security.web.authentication.logout.LogoutSuccessHandler-).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> Specify whether to invalidate the `HttpSession` at the time of logout. This is **true** by default. Configures the `SecurityContextLogoutHandler` under the covers. For more information, please consult the [JavaDoc](https://docs.spring.io/spring-security/site/docs/current/api/org/springframework/security/config/annotation/web/configurers/LogoutConfigurer.html#invalidateHttpSession-boolean-).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(6)</span> Adds a `LogoutHandler`. `SecurityContextLogoutHandler` is added as the last `LogoutHandler` by default.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(7)</span> Allows specifying the names of cookies to be removed on logout success. This is a shortcut for adding a `CookieClearingLogoutHandler` explicitly.</small>

>  Logouts can of course also be configured using the XML Namespace notation. Please see the documentation for the [logout element](https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#nsa-logout) in the Spring Security XML Namespace section for further details.

Generally, in order to customize logout functionality, you can add `LogoutHandler` and/or `LogoutSuccessHandler` implementations. For many common scenarios, these handlers are applied under the covers when using the fluent API.

### 10.20.2. Logout XML Configuration

The `logout` element adds support for logging out by navigating to a particular URL. The default logout URL is `/logout`, but you can set it to something else using the `logout-url` attribute. More information on other available attributes may be found in the namespace appendix.

### 10.20.3. LogoutHandler

Generally, `LogoutHandler` implementations indicate classes that are able to participate in logout handling. They are expected to be invoked to perform necessary clean-up. As such they should not throw exceptions. Various implementations are provided:

- [PersistentTokenBasedRememberMeServices](https://docs.spring.io/spring-security/site/docs/current/api/org/springframework/security/web/authentication/rememberme/PersistentTokenBasedRememberMeServices.html)
- [TokenBasedRememberMeServices](https://docs.spring.io/spring-security/site/docs/current/api/org/springframework/security/web/authentication/rememberme/TokenBasedRememberMeServices.html)
- [CookieClearingLogoutHandler](https://docs.spring.io/spring-security/site/docs/current/api/org/springframework/security/web/authentication/logout/CookieClearingLogoutHandler.html)
- [CsrfLogoutHandler](https://docs.spring.io/spring-security/site/docs/current/api/org/springframework/security/web/csrf/CsrfLogoutHandler.html)
- [SecurityContextLogoutHandler](https://docs.spring.io/spring-security/site/docs/current/api/org/springframework/security/web/authentication/logout/SecurityContextLogoutHandler.html)
- [HeaderWriterLogoutHandler](https://docs.spring.io/spring-security/site/docs/current/api/org/springframework/security/web/authentication/logout/HeaderWriterLogoutHandler.html)

Please see [Remember-Me Interfaces and Implementations](https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#remember-me-impls) for details.

Instead of providing `LogoutHandler` implementations directly, the fluent API also provides shortcuts that provide the respective `LogoutHandler` implementations under the covers. E.g. `deleteCookies()` allows specifying the names of one or more cookies to be removed on logout success. This is a shortcut compared to adding a `CookieClearingLogoutHandler`.

### 10.20.4. LogoutSuccessHandler

The `LogoutSuccessHandler` is called after a successful logout by the `LogoutFilter`, to handle e.g. redirection or forwarding to the appropriate destination. Note that the interface is almost the same as the `LogoutHandler` but may raise an exception.

The following implementations are provided:

- [SimpleUrlLogoutSuccessHandler](https://docs.spring.io/spring-security/site/docs/current/api/org/springframework/security/web/authentication/logout/SimpleUrlLogoutSuccessHandler.html)
- HttpStatusReturningLogoutSuccessHandler

As mentioned above, you don’t need to specify the `SimpleUrlLogoutSuccessHandler` directly. Instead, the fluent API provides a shortcut by setting the `logoutSuccessUrl()`. This will setup the `SimpleUrlLogoutSuccessHandler` under the covers. The provided URL will be redirected to after a logout has occurred. The default is `/login?logout`.

The `HttpStatusReturningLogoutSuccessHandler` can be interesting in REST API type scenarios. Instead of redirecting to a URL upon the successful logout, this `LogoutSuccessHandler` allows you to provide a plain HTTP status code to be returned. If not configured a status code 200 will be returned by default.

### 10.20.5. Further Logout-Related References

- [Logout Handling](https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#ns-logout)
- [Testing Logout](https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#test-logout)
- [HttpServletRequest.logout()](https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#servletapi-logout)
- [Remember-Me Interfaces and Implementations](https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#remember-me-impls)
- [Logging Out](https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#servlet-considerations-csrf-logout) in section CSRF Caveats
- Section [Single Logout](https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#cas-singlelogout) (CAS protocol)
- Documentation for the [logout element](https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#nsa-logout) in the Spring Security XML Namespace section

---

## 10.21. Authentication Events

For each authentication that succeeds or fails, a `AuthenticationSuccessEvent` or `AuthenticationFailureEvent` is fired, respectively.

To listen for these events, you must first publish an `AuthenticationEventPublisher`. Spring Security’s `DefaultAuthenticationEventPublisher` will probably do fine:

```java
@Bean
public AuthenticationEventPublisher authenticationEventPublisher
        (ApplicationEventPublisher applicationEventPublisher) {
    return new DefaultAuthenticationEventPublisher(applicationEventPublisher);
}
```

Then, you can use Spring’s `@EventListener` support:

```java
@Component
public class AuthenticationEvents {
    @EventListener
    public void onSuccess(AuthenticationSuccessEvent success) {
        // ...
    }

    @EventListener
    public void onFailure(AuthenticationFailureEvent failures) {
        // ...
    }
}
```

While similar to `AuthenticationSuccessHandler` and `AuthenticationFailureHandler`, these are nice in that they can be used independently from the servlet API.

### 10.21.1. Adding Exception Mappings

`DefaultAuthenticationEventPublisher` by default will publish an `AuthenticationFailureEvent` for the following events:

| Exception                        | Event                                          |
| -------------------------------- | ---------------------------------------------- |
| `BadCredentialsException`        | `AuthenticationFailureBadCredentialsEvent`     |
| `UsernameNotFoundException`      | `AuthenticationFailureBadCredentialsEvent`     |
| `AccountExpiredException`        | `AuthenticationFailureExpiredEvent`            |
| `ProviderNotFoundException`      | `AuthenticationFailureProviderNotFoundEvent`   |
| `DisabledException`              | `AuthenticationFailureDisabledEvent`           |
| `LockedException`                | `AuthenticationFailureLockedEvent`             |
| `AuthenticationServiceException` | `AuthenticationFailureServiceExceptionEvent`   |
| `CredentialsExpiredException`    | `AuthenticationFailureCredentialsExpiredEvent` |
| `InvalidBearerTokenException`    | `AuthenticationFailureBadCredentialsEvent`     |

The publisher does an exact `Exception` match, which means that sub-classes of these exceptions won’t also produce events.

To that end, you may want to supply additional mappings to the publisher via the `setAdditionalExceptionMappings` method:

```java
@Bean
public AuthenticationEventPublisher authenticationEventPublisher
        (ApplicationEventPublisher applicationEventPublisher) {
    Map<Class<? extends AuthenticationException>,
        Class<? extends AuthenticationFailureEvent>> mapping =
            Collections.singletonMap(FooException.class, FooEvent.class);
    AuthenticationEventPublisher authenticationEventPublisher =
        new DefaultAuthenticationEventPublisher(applicationEventPublisher);
    authenticationEventPublisher.setAdditionalExceptionMappings(mapping);
    return authenticationEventPublisher;
}
```

### 10.21.2. Default Event

And, you can supply a catch-all event to fire in the case of any `AuthenticationException`:

```java
@Bean
public AuthenticationEventPublisher authenticationEventPublisher
        (ApplicationEventPublisher applicationEventPublisher) {
    AuthenticationEventPublisher authenticationEventPublisher =
        new DefaultAuthenticationEventPublisher(applicationEventPublisher);
    authenticationEventPublisher.setDefaultAuthenticationFailureEvent
        (GenericAuthenticationFailureEvent.class);
    return authenticationEventPublisher;
}
```

---

전체 목차는 [여기](../contents/)에 있습니다.