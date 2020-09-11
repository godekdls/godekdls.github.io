---
title: Security Namespace Configuration
category: Spring Security
order: 19
permalink: /Spring%20Security/securitynamespaceconfiguration/
description: 스프링 시큐리티의 XML 네임스페이스를 소개합니다. 공식 문서에 있는 "Security Namespace Configuration" 챕터를 한글로 번역한 문서입니다.
image: ./../../images/springsecurity/spring-security.png
lastmod: 2020-09-03T20:00:00+09:00
comments: true
completed: false
originalRefName: 스프링 시큐리티
originalRefLink: https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#ns-config
---

### 목차:

- [18.1. Introduction](#181-introduction)
  + [18.1.1. Design of the Namespace](#1811-design-of-the-namespace)
- [18.2. Getting Started with Security Namespace Configuration](#182-getting-started-with-security-namespace-configuration)
  + [18.2.1. web.xml Configuration](#1821-webxml-configuration)
  + [18.2.2. A Minimal \<http\> Configuration](#1822-a-minimal-http-configuration)
    * [Setting a Default Post-Login Destination](#setting-a-default-post-login-destination)
- [18.3. Advanced Web Features](#183-advanced-web-features)
  + [18.3.1. Adding in Your Own Filters](#1831-adding-in-your-own-filters)
- [18.4. Method Security](#184-method-security)
- [18.5. The Default AccessDecisionManager](#185-the-default-accessdecisionmanager)
  + [18.5.1. Customizing the AccessDecisionManager](#1851-customizing-the-accessdecisionmanager)

---

## 18.1. Introduction

네임스페이스 설정은 스프링 프레임워크 2.0 버전부터 지원했다. XML 스키마 요소를 추가하면 전통적인 스프링 빈 어플리케이션 컨텍스트 문법을 한층 더 보강할 수 있다. 자세한 정보는 스프링 [레퍼런스 문서](https://docs.spring.io/spring/docs/current/spring-framework-reference/htmlsingle/)에 나와있다. 네임스페이스 요소는 각 빈 설정을 더 간결하게, 혹은 더 강력하게 만들어주며, 도메인 관심사와 더 밀접하게 매칭되고 사용자로부터 복잡성을 숨겨주는 문법을 사용할 수 있다. 간단한 요소 하나로 어플리케이션 컨텍스트에 여러 빈과 그에 따른 처리 단계가 추가됐다는 사실을 숨길 수도 있다. 예를 들어 아래 시큐리티 네임스페이스 요소를 어플리케이션 컨텍스트에 추가하면 어플리케이션 내에서 테스트 용도로 사용할 수 있는 임베디드 LDAP 서버를 기동한다.

```xml
<security:ldap-server />
```

이 방법은 아파치 디렉토리 서버 빈을 직접 연결하는 것보다 훨씬 간단하다. 필요한 설정은 대부분 `ldap-server` 요소 속성으로 지원하므로, 사용자는 생성해야 할 빈과 빈 프로퍼티 이름을 신경쓰지 않아도 된다. XML 에디터로 어플리케이션 컨텍스트 파일을 편집하면 사용 가능한 속성과 요소 정보를 제공한다. 표준 스프링 네임스페이스를 위한 특별한 기능이 있는 [Spring Tool Suite](https://spring.io/tools)를 추천한다.

어플리케이션 컨텍스트에서 시큐리티 네임스페이스를 사용하려면 클래스패스에  `spring-security-config` jar가 있어야 한다. 그다음엔 어플리케이션 컨텍스트 파일에 스키마만 선언하면 된다:

```xml
<beans xmlns="http://www.springframework.org/schema/beans"
xmlns:security="http://www.springframework.org/schema/security"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:schemaLocation="http://www.springframework.org/schema/beans
        https://www.springframework.org/schema/beans/spring-beans-3.0.xsd
        http://www.springframework.org/schema/security
        https://www.springframework.org/schema/security/spring-security.xsd">
    ...
</beans>
```

"beans" 대신 "security"를 디폴트 네임스페이스로 사용하는 예제가 많다 (샘플 어플리케이션에서도). 이땐 시큐리티 네임스페이스 요소의 프리픽스를 생략할 수 있으므로 컨텐츠 가독성이 더 좋아진다. 어플리케이션 컨텍스트를 별도 파일로 분리해서 보안 설정 대부분을 한 파일에 담는다면 이 방법이 더 나을 거다. 시큐리티 어플리케이션 컨텍스트 파일 앞부분은 다음과 같다.

```xml
<beans:beans xmlns="http://www.springframework.org/schema/security"
xmlns:beans="http://www.springframework.org/schema/beans"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:schemaLocation="http://www.springframework.org/schema/beans
        https://www.springframework.org/schema/beans/spring-beans-3.0.xsd
        http://www.springframework.org/schema/security
        https://www.springframework.org/schema/security/spring-security.xsd">
    ...
</beans:beans>
```

이 챕터에선 지금부터 이 문법을 사용한다고 가정한다.

### 18.1.1. Design of the Namespace

네임스페이스는 프레임워크에서 가장 많이 쓰는 기능을 지원하도록 설계했으며, 어플리케이션에선 단순화한 간결한 문법을 사용할 수 있도록 만들었다. 프레임워크 내에 있는 대규모 종속성을 기반으로 설계했으며, 다음 영역으로 나눌 수 있다:

- *Web/HTTP Security* - 가장 복잡한 부분. URL 보호, 로그인/에러 페이지 렌더링 등의 인증 메커니즘 적용에 필요한 필터와 관련 서비스 빈을 설정한다.
- *Business Object (Method) Security* - 서비스 레이어를 보호하는 옵션.
- *AuthenticationManager* - 프레임워크 내 다른 영역에서 들어온 인증 요청을 처리한다.
- *AccessDecisionManager* - 웹, 메소드 시큐리티와 관련한 접근 결정을 내린다. 디폴트로 하나가 등록되지만, 일반 스프링 빈 문법으로 커스텀 빈을 정의할 수 있다.
- *AuthenticationProvider*s - 인증 매니저가 사용자를 인증할 때 사용할 메커니즘. 몇 가지 표준 옵션과 기존 문법으로 네임스페이스에 커스텀 빈 정의할 수 있다.
- *UserDetailsService* - 인증 provider와 밀접한 연관이 있지만, 종종 다른 빈에서도 필요로 한다.

이어지는 섹션에서는 이 컴포넌트들을 설정하는 방법을 알아볼 것이다.

---

## 18.2. Getting Started with Security Namespace Configuration

이번 섹션에선 네임스페이스 설정으로 일부 프레임워크 주요 기능을 사용하는 방법을 살펴본다. 일단은 최대한 빨리 어플리케이션을 기동해보고, 기존 웹 어플리케이션에 네임스페이스로 몇 가지 테스트 로그인을 지원하는 인증, 접근 제어 기능을 추가해 보겠다. 데이터베이스나 다른 보안 레포지토리로 인증을 전환하는 방법은 그 다음에 살펴보겠다. 이후 섹션에선 좀 더 복잡한 네임스페이스 설정 옵션을 소개한다.

### 18.2.1. web.xml Configuration

가장 먼저 할 일은 `web.xml` 파일에 아래 필터 정의를 추가하는 것이다:

```xml
<filter>
<filter-name>springSecurityFilterChain</filter-name>
<filter-class>org.springframework.web.filter.DelegatingFilterProxy</filter-class>
</filter>

<filter-mapping>
<filter-name>springSecurityFilterChain</filter-name>
<url-pattern>/*</url-pattern>
</filter-mapping>
```

이 설정은 스프링 시큐리티 웹 인프라에 훅을 제공한다. `DelegatingFilterProxy`는 어플리케이션 컨텍스트에 스프링 빈으로 정의한 필터 구현체에 위임하는 스프링 프레임워크 클래스다. 이 경우엔 웹 보안 처리를 위해 네임스페이스에서 생성한 내부 인프라 빈으로, 이름은 "springSecurityFilterChain"이다. 이 빈 이름을 직접 사용해서는 안 된다. 이 설정을 `web.xml`에 추가했으면, 이제 어플리케이션 컨텍스트 파일을 사용할 준비가 된 것이다. 웹 보안 서비스는 `<http>` 요소로 설정한다.

### 18.2.2. A Minimal \<http\> Configuration

아래 설정만 추가하면 웹 보안을 시작할 수 있다.

```xml
<http>
<intercept-url pattern="/**" access="hasRole('USER')" />
<form-login />
<logout />
</http>
```

이 설정대로라면, 어플리케이션 내 모든 URL을 보호하며, 접근하려면 `ROLE_USER` role이 필요하고, 사용자 이름과 비밀번호를 폼에 입력해 로그인할 수 있으며, 어플리케이션에서 로그아웃할 수 있는 로그아웃 URL을 등록한다. `<http>` 요소는 웹과 관련한 모든 네임스페이스 기능의 부모 요소다. `<intercept-url>`은 ant path 스타일 문법으로 요청 URL을 비교하는 `pattern`을 정의한다. 이대신 정규식을 사용할 수도 있다 (자세한 내용은 네임스페이스 부록 참고). `access` 속성은 주어진 패턴에 일치하는 요청에 접근할 때 필요한 속성을 정의한다. 디폴트 설정에선 보통 role 리스트를 쉼표로 구분해서 표기하며, 이 중 하나는 가지고 있는 사용자만 요청을 수행할 수 있다. "ROLE\_" 프리픽스는 사용자의 권한을 간단히 비교하겠다는 표시다. 다시 말해 일반적인 role 기반 검사를 사용하겠다는 뜻이다. 스프링 시큐리티의 접근 제어는 간단한 role 비교에 국한되지는 않는다 (따라서 다른 보안 속성 타입과 구분하기 위해 프리픽스를 사용한다). 해석이 어떻게 달라지는지는 뒤에서 살펴보겠다. 스프링 시큐리티 3.0에서는 [EL 표현식](../authorization#113-expression-based-access-control)으로도 속성을 채울 수 있다.

> `<intercept-url>` 요소를 여러 개 만들어서 URL 셋에 따라 다른 접근 조건을 정의할 수 있지만, 나열한 순서대로 비교하며 가장 먼저 일치한 항목을 사용한다. 따라서 가장 구체적인 조건을 맨 위에 둬야 한다. `method` 속성을 추가하면 특정 HTTP 메소드만 (`GET`, `POST`, `PUT` 등) 매칭되도록 제한할 수 있다.

사용자를 추가하고 싶다면 네임스페이스에 직접 테스트 데이터 셋을 정의하면 된다:

```xml
<authentication-manager>
<authentication-provider>
    <user-service>
    <!-- Password is prefixed with {noop} to indicate to DelegatingPasswordEncoder that
    NoOpPasswordEncoder should be used. This is not safe for production, but makes reading
    in samples easier. Normally passwords should be hashed using BCrypt -->
    <user name="jimi" password="{noop}jimispassword" authorities="ROLE_USER, ROLE_ADMIN" />
    <user name="bob" password="{noop}bobspassword" authorities="ROLE_USER" />
    </user-service>
</authentication-provider>
</authentication-manager>
```

아래 예제는 같은 비밀번호를 안전하게 저장하는 한 가지 예시다. 비밀번호 인코딩은 `DelegatingPasswordEncoder`가 설정에 있는 `PasswordEncoder`로 매칭해주며, 이 비밀번호는 `{bcrypt}`로 시작하기 때문에 BCrypt로 해싱한다:

```xml
<authentication-manager>
<authentication-provider>
    <user-service>
    <user name="jimi" password="{bcrypt}$2a$10$ddEWZUl8aU0GdZPPpy7wbu82dvEw/pBpbRvDQRqA41y6mK1CoH00m"
            authorities="ROLE_USER, ROLE_ADMIN" />
    <user name="bob" password="{bcrypt}$2a$10$/elFpMBnAYYig6KRR5bvOOYeZr1ie1hSogJryg9qDlhza4oCw1Qka"
            authorities="ROLE_USER" />
    <user name="jimi" password="{noop}jimispassword" authorities="ROLE_USER, ROLE_ADMIN" />
    <user name="bob" password="{noop}bobspassword" authorities="ROLE_USER" />
    </user-service>
</authentication-provider>
</authentication-manager>
```

>  프레임워크의 이전 버전 네임스페이스에 익숙하다면 여기에서 무슨 일이 벌어지고 있는지 대략 예상될 것이다. `<http>` 요소는 `FilterChainProxy`와 이를 사용하는 필터 빈을 생성해 준다. 필터 위치는 미리 정의돼 있기 때문에, 흔한 이슈 중 하나인 필터 순서를 잘못 정의하는 이슈를 피할 수 있다.
>
>  `<authentication-provider>` 요소는 `DaoAuthenticationProvider` 빈을,  `<user-service>` 요소는 `InMemoryDaoImpl`을 생성한다. 모든 `authentication-provider` 요소는 `ProviderManager`를 만들고 여기에 인증 provider를 등록하는 `<authentication-manager>` 요소의 자식 요소여야 한다. 생성하는 빈들에 대한 자세한 정보는 [네임스페이스 부록](../thesecuritynamespace#225-the-security-namespace)에서 찾을 수 있다. 프레임워크에서 중요한 클래스가 무엇인지, 그리고 클래스가 어떻게 사용되는지 이해하고 싶다면, 특히 나중에 커스텀해야 할 수도 있다면, 함께 확인해보는 게 좋다.

위 설정은 두 명의 사용자와, 사용자의 비밀번호, 어플리케이션 내 role을 (접근 제어에 사용할) 정의한다. `user-service`의 `properties` 속성으로 표준 properties 파일에서 사용자 정보를 로드할 수도 있다. 파일 형식에 대한 자세한 설명은 [인메모리 인증](../authentication#10104-in-memory-authentication) 섹션을 참고해라. `<authentication-provider>` 요소를 사용했다는 것은 인증 manager가 사용자 정보를 사용해서 인증 요청을 처리한다는 뜻이다. `<authentication-provider>` 요소를 여러 개 만들어서 다른 인증 소스를 정의할 수도 있으며, 각 소스는 순서대로 참조한다.

여기까지 왔으면 어플리케이션을 기동시킬 수 있으며, 계속하려면 로그인이 필요하다. 어플리케이션을 직접 기동해봐도 좋고, 프로젝트 내에 있는 "tutorial" 샘플 어플리케이션을 기동해봐도 좋다.

#### Setting a Default Post-Login Destination

보호 중인 리소스에 접근할 때 로그인 폼을 띄우지 않는다면 `default-target-url` 옵션대로 동작한다. 이 옵션은 로그인에 성공한 사용자가 이동할 URL로, 디폴트 값은 "/"다. `always-use-default-target` 속성을 "true"로 설정하면 사용자는 결국엔 *무조건* 이 페이지로 이동하게 된다 (로그인이 필요했던 건지 또는 원해서 로그인한 건지와는 상관없이). 사용자가 항상 "홈" 페이지에서 시작해야 하는 경우에 이를 활용할 수 있다. 예를 들어:

```xml
<http pattern="/login.htm*" security="none"/>
<http use-expressions="false">
<intercept-url pattern='/**' access='ROLE_USER' />
<form-login login-page='/login.htm' default-target-url='/home.htm'
        always-use-default-target='true' />
</http>
```

목적지를 더 세세하게 컨트롤하려면 `default-target-url` 대신 `authentication-success-handler-ref` 속성을 사용하면 된다. 이 속성을 사용하면 `AuthenticationSuccessHandler` 빈을 참조해야 한다.

---

## 18.3. Advanced Web Features

### 18.3.1. Adding in Your Own Filters

전에 스프링 시큐리티를 사용해본 적이 있다면 프레임워크에서 필터 체인을 관리해서 서비스를 적용한다는 것을 알거다. 필터 스택에서 원하는 위치에 자체 필터를 추가하거나, 현재는 네임스페이스 설정 옵션이 (CAS 등) 없는 스프링 시큐리티 필터를 사용해야 할 수도 있다. 또는 `UsernamePasswordAuthenticationFilter`같이, `<form-login>`  요소로 생성하며 빈을 명시적으로 선언하면 몇 가지 옵션을 설정할 수 있는 표준 네임스페이스 필터를 커스텀할 수도 있다. 네임스페이스 설정엔 필터 체인이 직접 노출되지 않는데 어떻게 이런게 가능할까?

네임스페이스에선 항상 필터 순서를 엄격히 지킨다. 어플리케이션 컨텍스트를 생성할 때 네임스페이스를 처리하는 코드에서 필터 빈을 정렬한다. 각 표준 스프링 시큐리티 필터는 네임스페이스 전용 별칭이 있으며, 위치가 정해져 있다.

> 이전 버전에선 필터 인스턴스를 생성한 이후, 어플리케이션 컨텍스트 후처리 로직에서 필터를 정렬했다. 3.0+ 버전에선, 이제 클래스를 인스턴스화하기 전에 빈 메타데이터를 가지고 정렬한다. 따라서 `<http>` 요소를 파싱할 때 전체 필터 리스트를 알고 있어야 하고, 자체 필터를 추가하는 방식에도 영향을 끼쳤다. 그로 인해 3.0에서 문법이 약간 달라졌다.

필터와 이를 구성하는 별칭, 네임스페이스 요소/속성은 [Standard Filter Aliases and Ordering](#filter-stack)에 나와있다. 아래 필터는 필터 체인에서 실행하는 순서로 나열했다.

<span id="filter-stack"></span>**Table 2. Standard Filter Aliases and Ordering**

| Alias                        | Filter Class                                          | Namespace Element or Attribute           |
| :--------------------------- | :---------------------------------------------------- | :--------------------------------------- |
| CHANNEL_FILTER               | `ChannelProcessingFilter`                             | `http/intercept-url@requires-channel`    |
| SECURITY_CONTEXT_FILTER      | `SecurityContextPersistenceFilter`                    | `http`                                   |
| CONCURRENT_SESSION_FILTER    | `ConcurrentSessionFilter`                             | `session-management/concurrency-control` |
| HEADERS_FILTER               | `HeaderWriterFilter`                                  | `http/headers`                           |
| CSRF_FILTER                  | `CsrfFilter`                                          | `http/csrf`                              |
| LOGOUT_FILTER                | `LogoutFilter`                                        | `http/logout`                            |
| X509_FILTER                  | `X509AuthenticationFilter`                            | `http/x509`                              |
| PRE_AUTH_FILTER              | `AbstractPreAuthenticatedProcessingFilter` Subclasses | N/A                                      |
| CAS_FILTER                   | `CasAuthenticationFilter`                             | N/A                                      |
| FORM_LOGIN_FILTER            | `UsernamePasswordAuthenticationFilter`                | `http/form-login`                        |
| BASIC_AUTH_FILTER            | `BasicAuthenticationFilter`                           | `http/http-basic`                        |
| SERVLET_API_SUPPORT_FILTER   | `SecurityContextHolderAwareRequestFilter`             | `http/@servlet-api-provision`            |
| JAAS_API_SUPPORT_FILTER      | `JaasApiIntegrationFilter`                            | `http/@jaas-api-provision`               |
| REMEMBER_ME_FILTER           | `RememberMeAuthenticationFilter`                      | `http/remember-me`                       |
| ANONYMOUS_FILTER             | `AnonymousAuthenticationFilter`                       | `http/anonymous`                         |
| SESSION_MANAGEMENT_FILTER    | `SessionManagementFilter`                             | `session-management`                     |
| EXCEPTION_TRANSLATION_FILTER | `ExceptionTranslationFilter`                          | `http`                                   |
| FILTER_SECURITY_INTERCEPTOR  | `FilterSecurityInterceptor`                           | `http`                                   |
| SWITCH_USER_FILTER           | `SwitchUserFilter`                                    | N/A                                      |

자체 필터를 스택에 추가할 땐, `custom-filter` 요소에 이 이름 중 하나로 필터 위치를 명시할 수 있다:

```xml
<http>
<custom-filter position="FORM_LOGIN_FILTER" ref="myFilter" />
</http>

<beans:bean id="myFilter" class="com.mycompany.MySpecialAuthenticationFilter"/>
```

스택에 있는 다른 필터 앞뒤에 필터를 추가하고 싶으면 `after`, `before` 속성을 사용하면 된다. `position` 속성에 "FIRST"나 "LAST"를 사용하면 필터를 전체 스택 앞뒤에 배치할 수 있다.

> **Avoiding filter position conflicts**
>
> 커스텀 필터를 네임스페이스에서 생성하는 표준 필터 중 하나와 동일한 위치에 추가한다면, 실수로 네임스페이스 버전 필터를 넣지 않도록 주의해야 한다. 기능을 교체하려는 필터를 만드는 모든 요소를 제거해라.
>
> 단, `<http>`  요소 때문에 추가된 필터는 (`SecurityContextPersistenceFilter`, `ExceptionTranslationFilter` `FilterSecurityInterceptor`) 교체할 수 없다. 디폴트로 추가되는 필터 중 비활성화할 수 있는 필터도 있긴하다. `AnonymousAuthenticationFilter`는 기본으로 추가되며,  [session-fixation 방어](../authentication#10113-session-fixation-attack-protection)를 비활성화하지 않는 한 `SessionManagementFilter`도 필터 체인에 추가된다.

인증 엔트리 포인트가 필요한 네임스페이스 필터를 교체한다면 (i.e. 인증하지 않은 사용자가 보호 중인 리소스에 접근을 시도해서 인증 프로세스를 트리거링하는 경우) 커스텀 엔트리 포인트 빈도 추가해야 한다.

---

## 18.4. Method Security

2.0 버전 이후 스프링 시큐리티는 서비스 레이어 메소드를 보호하기 위한 기능을 대폭 개선했다. 프레임워크의 기존 `@Secured` 애노테이션 외에 JSR-250 애노테이션도 지원한다. 3.0부터는 새로운 [표현식 기반 애노테이션](../authorization/#113-expression-based-access-control)도 사용할 수 있다. 원하는 빈을 선언한 곳을 `intercept-methods` 요소로 장식하면 단일 빈을 보호할 수도 있고, AspectJ 스타일 포인트컷으로 서비스 레이어 전체에 걸친 빈을 보호할 수도 있다.

---

## 18.5. The Default AccessDecisionManager

이번 섹션에선 스프링 시큐리티 내 접근 제어를 위한 기본 아키텍처를 알고 있다고 가정한다. 이 섹션은 간단히 role을 기반으로 권한을 확인하는 대신 더 복잡한 로직을 커스텀할 사람들을 위한 섹션이므로, 접근 제어 아키텍처를 잘 모르면 일단은 건너 뛰고 다음에 다시 와도 좋다.

네임스페이스 설정을 사용하면 `AccessDecisionManager`의 디폴트 인스턴스가 자동으로 등록되며, 이를 사용해서 `intercept-url`과 `protect-pointcut` 선언에 지정한 access 속성을 기반으로 (애노테이션으로 보호하는 메소드가 있다면 애노테이션도) 메소드 실행과 웹 URL 접근 권한을 결정한다.

디폴트 전략은 `RoleVoter`와 `AuthenticatedVoter`를 사용하는 `AffirmativeBased` `AccessDecisionManager`다. 자세한 설명은 [인가](../authorization#111-authorization-architecture) 챕터에서 찾아볼 수 있다.

### 18.5.1. Customizing the AccessDecisionManager

더 복잡한 접근 제어 전략이 필요할 땐, 웹, 메소드 시큐리티 모두 쉽게 다른 방법으로 변경할 수 있다.

메소드 시큐리티에선 `global-method-security`의 `access-decision-manager-ref` 속성을 어플리케이션 컨텍스트에 있는 적절한 `AccessDecisionManager` 빈 `id`로 설정하면 된다:

```xml
<global-method-security access-decision-manager-ref="myAccessDecisionManagerBean">
...
</global-method-security>
```

웹 보안에서도 문법은 동일하지만 `http` 요소로 설정한다:

```xml
<http access-decision-manager-ref="myAccessDecisionManagerBean">
...
</http>
```