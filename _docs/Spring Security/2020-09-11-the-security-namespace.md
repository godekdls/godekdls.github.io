---
title: The Security Namespace
category: Spring Security
order: 23
permalink: /Spring%20Security/thesecuritynamespace/
description: 스프링 시큐리티 네임스페이스 전체 요소와 속성을 설명합니다. 공식 문서에 있는 "The Security Namespace" 챕터를 한글로 번역한 문서입니다.
image: ./../../images/springsecurity/spring-security.png
lastmod: 2020-09-20T23:18:12+09:00
comments: true
originalRefName: 스프링 시큐리티
originalRefLink: https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#appendix-namespace
---

### 목차:

- [22.5. The Security Namespace](#225-the-security-namespace)
  + [22.5.1. Web Application Security](#2251-web-application-security)
    * [\<debug\>](#debug)
    * [\<http\>](#http)
    * [\<access-denied-handler\>](#access-denied-handler)
    * [\<cors\>](#cors)
    * [\<headers\>](#header)
    * [\<cache-control\>](#cache-control)
    * [\<hsts\>](#hsts)
    * [\<hpkp\>](#hpkp)
    * [\<pins\>](#pins)
    * [\<pin\>](#pin)
    * [\<content-security-policy\>](#content-security-policy)
    * [\<referrer-policy\>](#referrer-policy)
    * [\<feature-policy\>](#feature-policy)
    * [\<frame-options\>](#frame-options)
    * [\<xss-protection\>](#xss-protection)
    * [\<content-type-options\>](#content-type-options)
    * [\<header\>](#header)
    * [\<anonymous\>](#anonymous)
    * [\<csrf\>](#csrf)
    * [\<custom-filter\>](#custom-filter)
    * [\<expression-handler\>](#expression-handler)
    * [\<form-login\>](#form-login)
    * [\<oauth2-login\>](#oauth2-login)
    * [\<oauth2-client\>](#oauth2-client)
    * [\<authorization-code-grant\>](#authorization-code-grant)
    * [\<client-registrations\>](#client-registrations)
    * [\<client-registration\>](#client-registration)
    * [\<provider\>](#provider)
    * [\<oauth2-resource-server\>](#oauth2-resource-server)
    * [\<jwt\>](#jwt)
    * [\<opaque-token\>](#opaque-token)
    * [\<http-basic\>](#http-basic)
    * [\<http-firewall\> Element](#http-firewall-element)
    * [\<intercept-url\>](#intercept-url)
    * [\<jee\>](#jee)
    * [\<logout\>](#logout)
    * [\<openid-login\>](#openid-login)
    * [\<attribute-exchange\>](#attribute-exchange)
    * [\<openid-attribute\>](#openid-attribute)
    * [\<port-mappings\>](#port-mappings)
    * [\<port-mapping\>](#port-mapping)
    * [\<remember-me\>](#remember-me)
    * [\<request-cache\> Element](#request-cache-element)
    * [\<session-management\>](#session-management)
    * [\<concurrency-control\>](#concurrency-control)
    * [\<x509\>](#x509)
    * [\<filter-chain-map\>](#filter-chain-map)
    * [\<filter-chain\>](#filter-chain)
    * [\<filter-security-metadata-source\>](#filter-security-metadata-source)
  + [22.5.2. WebSocket Security](#2252-websocket-security)
    * [\<websocket-message-broker\>](#websocket-message-broker)
    * [\<intercept-message\>](#intercept-message)
  + [22.5.3. Authentication Services](#2253-authentication-services)
    * [\<authentication-manager\>](#authentication-manager)
    * [\<authentication-provider\>](#authentication-provider)
    * [\<jdbc-user-service\>](#jdbc-user-service)
    * [\<password-encoder\>](#password-encoder)
    * [\<user-service\>](#user-service)
    * [\<user\>](#user)
  + [22.5.4. Method Security](#2254-method-security)
    * [\<global-method-security\>](#global-method-security)
    * [\<after-invocation-provider\>](#after-invocation-provider)
    * [\<pre-post-annotation-handling\>](#pre-post-annotation-handling)
    * [\<invocation-attribute-factory\>](#invocation-attribute-factory)
    * [\<post-invocation-advice\>](#post-invocation-advice)
    * [\<pre-invocation-advice\>](#pre-invocation-advice)
    * [Securing Methods using](#securing-methods-using)
    * [\<intercept-methods\>](#intercept-methods)
    * [\<method-security-metadata-source\>](#method-security-metadata-source)
    * [\<protect\>](#protect)
  + [22.5.5. LDAP Namespace Options](#2255-ldap-namespace-options)
    * [Defining the LDAP Server using the](#defining-the-ldap-server-using-the)
    * [\<ldap-authentication-provider\>](#ldap-authentication-provider)
    * [\<password-compare\>](#password-compare)
    * [\<ldap-user-service\>](#ldap-user-service)
    
---

## 22.5. The Security Namespace

여기에선 시큐리티 네임스페이스에서 사용할 수 있는 요소와, 각 요소가 생성하는 기본적인 빈에 대해 설명한다 (각 클래스와 동작 방식은 이미 알고 있다고 가정한다. 자세한 정보는 프로젝트 Javadoc이나 이 문서의 다른 챕터를 참고해라). 네임스페이스를 사용해본 적이 없다면 네임스페이스 설정 [입문 챕터](../securitynamespaceconfiguration)를 읽어봐라. 이번 챕터는 입문 챕터를 보충 설명하기 위한 챕터다. 스키마 기반 설정을 편집할 땐 괜찮은 XML 에디터를 사용하는 게 좋다. XML 에디터를 사용하면 문맥상 사용할 수 있는 요소나 속성을 그 용도와 함께 표기해준다. 네임스페이스는 [RELAX NG](https://relaxng.org/) Compact 포맷으로 작성하고 이후에 XSD 스키마로 변환된다. 이 포맷에 익숙하다면 [스키마 파일](https://raw.githubusercontent.com/spring-projects/spring-security/master/config/src/main/resources/org/springframework/security/config/spring-security-4.1.rnc)을 직접 확인해 보는 것도 괜찮다.

### 22.5.1. Web Application Security

#### \<debug\>

스프링 시큐리티 디버깅 인프라를 활성화한다. 사람이 읽을 수 있는 (멀티 라인 사용) 디버깅 정보를 출력하므로, 스프링 필터로 들어오는 요청을 모니터링할 수 있다. 요청 파라미터나 헤더같은 민감한 정보가 포함될 수 있으므로 개발 환경에서만 사용해야 한다.

#### \<http\>

어플리케이션에서 `<http>` 요소를 사용하면 "springSecurityFilterChain"이라는 `FilterChainProxy` 빈을 생성하며, 이 요소에 있는 설정대로 `FilterChainProxy` 안에 필터 체인을 구축한다. 스프링 시큐리티 3.1부터 `http` 요소를 더 추가해서 다른 필터 체인을 생성할 수 있다. 일부 핵심 필터는 항상 필터 체인에 추가되며, 속성이나 하위 요소 존재 여부에 따라 스택에 추가하는 필터도 있다. 표준 필터의 위치는 고정이기 때문에 (네임스페이스 소개 섹션에 있는 [필터 순서 테이블](../securitynamespaceconfiguration#filter-stack) 참고) 이전처럼 사용자가 `FilterChainProxy` 빈에 필터 체인을 직접 명시해야 했을 때 흔히 발생하는 오류 요소를 제거했다. 물론 설정을 완전히 제어해야 한다면 직접 명시하는 것도 가능하다.

[`AuthenticationManager`](../authentication#105-authenticationmanager)를 참조해야 하는 필터는 전부, 네임스페이스 설정으로 생성한 내부 인스턴스를 자동으로 주입받는다.

각 `<http>` 네임스페이스 블록은 항상 `SecurityContextPersistenceFilter`, `ExceptionTranslationFilter`, `FilterSecurityInterceptor`를 생성한다. 이 필터는 고정이며 변경할 수 없다.

##### \<http\> Attributes

`<http>` 요소에 있는 속성으로 핵심 필터의 프로퍼티를 조절할 수 있다.

- **access-decision-manager-ref** HTTP 요청 인가에 사용할 `AccessDecisionManager` 구현체의 ID. 생략할 수 있으며, 디폴트로는 `RoleVoter`, `AuthenticatedVoter`와 함께 `AffirmativeBased` 구현체를 사용한다.
- **authentication-manager-ref** http 요소로 생성한 `FilterChain`에서 사용할 `AuthenticationManager`에 대한 참조.
- **auto-config** 자동으로 등록하는 설정으론 로그인 폼, 기본 인증, 로그아웃 서비스가 있다. "true"로 설정하면 이 모든 기능이 추가된다 (별도 요소로 설정을 커스텀할 수는 있음). 생략하면 디폴트로 "false"로 세팅된다. 이 속성은 사용하지 않는 게 좋다. 대신에 혼동되지 않도록 각 필요한 설정 요소를 명시하는 게 좋다.
- **create-session** 스프링 시큐리티 클래스에서 HTTP 세션을 생성하는 방법을 제어한다. 다음과 같은 옵션이 있다:
  - `always` - 세션이 없다면 스프링 시큐리티에서 미리 세션을 생성한다.
  - `ifRequired` - 필요할 때만 스프링 시큐리티에서 세션을 생성한다 (디폴트).
  - `never` - 스프링 시큐리티에선 세션을 생성하지 않지만, 어플리케이션에서 만든 세션이 있다면 그 세션을 사용한다.
  - `stateless` - 스프링 시큐리테이서 세션을 생성하지 않으며, 스프링 `Authentication`을 가져올 때 세션을 무시한다.
- **disable-url-rewriting** 어플리케이션의 URL에 세션 ID를 추가하지 않도록 막는다. 이 속성을 `true`로 설정했다면 반드시 클라이언트에서 쿠키를 사용해야 한다. 디폴트는 `true`다.
- <span id="nsa-http-entry-point-ref"></span>**entry-point-ref** 일반적으로 `AuthenticationEntryPoint`는 설정에 있는 인증 메커니즘에 따라 설정된다. 이 속성으로 인증 처리를 시작할 커스텀 `AuthenticationEntryPoint` 빈을 정의하면 이 동작을 재정의할 수 있다.
- <span id="nsa-http-jaas-api-provision"></span>**jaas-api-provision** 가능한 경우 `JaasApiIntegrationFilter` 빈을 스택에 추가하며, `JaasAuthenticationToken`에서 얻은 `Subject`로 요청을 실행한다. 디폴트는 `false`다.
- **name** 컨텍스트 내에 있는 다른 빈에서 이 빈을 참조할 때 사용할 빈 식별자.
- **once-per-request** `FilterSecurityInterceptor`의 `observeOncePerRequest` 프로퍼티에 해당한다. 디폴트는 `true`다.
- <span id="nsa-http-pattern"><span>**pattern** [http](#http) 요소에 정의한 패턴에 따라 필터 리스트로 보낼 요청을 필터링한다. 설정한 [request-matcher](#nsa-http-request-matcher)에 따라 다르게 해석한다. 패턴을 정의하지 않으면 모든 요청을 매칭하므로 가장 구체적인 패턴을 맨 앞에 선언해야 한다.
- **realm** 기본 인증에서 (활성화한 경우에만) 사용할 realm 이름을 설정한다. `BasicAuthenticationEntryPoint`의 `realmName` 프로퍼티에 해당한다.
- <span id="nsa-http-request-matcher"></span>**request-matcher** `FilterChainProxy`와 `intercept-url`로 생성한 빈에서 요청을 매칭할 때 사용할 `RequestMatcher` 전략을 정의한다. 현재 옵션은 `mvc`, `ant`, `regex`, `ciRegex`가 있으며, 스프링 MVC의 경우 ant, 정규식, 대소문자를 구분하지 않는 정규식이 있다. 각 [intercept-url](#intercept-url) 요소마다 [pattern](#nsa-intercept-url-pattern), [method](#nsa-intercept-url-method), [servlet-path](#nsa-intercept-url-servlet-path) 속성을 사용해 별도 인스턴스를 생성한다. Ant path는 `AntPathRequestMatcher`를, 정규식은 `RegexRequestMatcher`를, 스프링 MVC path는 `MvcRequestMatcher`를 사용한다. 정확히 어떻게 매칭하는지 자세히 알고싶다면 이 클래스들의 Javadoc을 참고해라. 디폴트 전략은 Ant path다.
- **request-matcher-ref** `RequestMatcher`를 구현한 빈에 대한 참조로, 이 `FilterChain` 사용 여부를 결정한다. [pattern](#nsa-http-pattern)보다 더 강력하다.
- **security** 이 속성을 `none`으로 설정하면 요청 패턴을 비어있는 필터 체인에 매핑한다. 이땐 보안을 적용하지 않으며 스프링 시큐리티 기능도 사용할 수 없다.
- **security-context-repository-ref** `SecurityContextPersistenceFilter`에 커스텀 `SecurityContextRepository`를 주입할 수 있다.
- **servlet-api-provision** 스택에 `SecurityContextHolderAwareRequestFilter` 빈을 추가하면 구현되는 `isUserInRole()`, `getPrincipal()`같은 `HttpServletRequest` 버전 보안 메소드를 제공한다. 디폴트는 `true`다.
- **use-expressions** [표현식 기반 접근 제어](../authorization#1132-web-security-expressions) 챕터에서 설명한 것처럼, `access` 속성에 EL 표현식을 활성화한다. 디폴트는 `true`다.

##### Child Elements of \<http\>

- [access-denied-handler](#access-denied-handler)
- [anonymous](#anonymous)
- [cors](#cors)
- [csrf](#csrf)
- [custom-filter](#custom-filter)
- [expression-handler](#expression-handler)
- [form-login](#form-login)
- [headers](#headers)
- [http-basic](#http-basic)
- [intercept-url](#intercept-url)
- [jee](#jee)
- [logout](#logout)
- [oauth2-client](#oauth2-client)
- [oauth2-login](#oauth2-login)
- [oauth2-resource-server](#oauth2-resource-server)
- [openid-login](#openid-login)
- [port-mappings](#port-mappings)
- [remember-me](#remember-me)
- [request-cache](#request-cache-element)
- [session-management](#session-management)
- [x509](#x509)

#### \<access-denied-handler\>

이 요소로는 [error-page](#nsa-access-denied-handler-error-page) 속성으로 `ExceptionTranslationFilter`에서 사용하는 디폴트 `AccessDeniedHandler`의 `errorPage` 프로퍼티를 설정하거나, [ref](#nsa-access-denied-handler-ref) 속성으로 자체 구현체를 제공할 수 있다. 자세한 내용은 [ExceptionTranslationFilter](../servletsecuritythebigpicture#96-handling-security-exceptions) 섹션에서 설명한다.

##### Parent Elements of \<access-denied-handler\>

- [http](#http)

##### \<access-denied-handler\> Attributes

- <span id="nsa-access-denied-handler-error-page"></span>**error-page** 인증된 사용자가 접근 권한이 없는 페이지를 요청했을 때 리다이렉션할 접근 거절 페이지.
- <span id="nsa-access-denied-handler-ref"></span>**ref** `AccessDeniedHandler` 타입 스프링 빈에 대한 참조를 정의한다.

#### \<cors\>

이 요소로 `CorsFilter`를 설정할 수 있다. `CorsFilter`나 `CorsConfigurationSource`를 따로 선언하지 않았고, 클래스패스에 스프링 MVC가 있으면 `HandlerMappingIntrospector`를 `CorsConfigurationSource`로 사용한다.

##### \<cors\> Attributes

`<cors>` 요소에 있는 속성으로 cors 요소를 제어한다.

- **ref** `CorsFilter` 빈 이름을 명시하는 속성으로, 생략할 수 있다.
- **cors-configuration-source-ref** XML 네임스페이스에서 생성한 `CorsFilter`에 주입할 `CorsConfigurationSource` 빈 이름을 명시하는 속성으로, 생략할 수 있다.

##### Parent Elements of \<cors\>

- [http](#http)

#### \<headers\>

이 요소는 응답과 함께 전송할 추가 (보안) 헤더를 설정한다. 여러 헤더를 쉽게 설정할 수 있으며, [header](#header) 요소로 커스텀 헤더를 설정할 수도 있다. 추가적인 정보는 이 문서의 [보안 헤더](../features#522-security-http-response-headers) 섹션에서 확인할 수 있다.

- `Cache-Control`, `Pragma`, `Expires` - [cache-control](#cache-control) 요소로 설정할 수 있다. 이 헤더를 사용하면 브라우저에서 보호 중인 페이지를 캐시에 저장하지 않는다.
- `Strict-Transport-Security` - [hsts](#hsts) 요소로 설정할 수 있다. 이 헤더를 사용하고 나면 브라우저에서 자동으로 HTTPS 요청을 보낸다.
- `X-Frame-Options` - [frame-options](#frame-options) 요소로 설정할 수 있다. [X-Frame-Options](https://en.wikipedia.org/wiki/Clickjacking#X-Frame-Options) 헤더는 클릭재킹 공격을 방어할 때 사용한다.
- `X-XSS-Protection` - [xss-protection](#xss-protection) 요소로 설정할 수 있다. 브라우저는 [X-XSS-Protection](https://en.wikipedia.org/wiki/Cross-site_scripting) 헤더가 있으면 기본적인 제어를 시작한다.
- `X-Content-Type-Options` - [content-type-options](#content-type-options) 요소로 설정할 수 있다. [X-Content-Type-Options](https://docs.microsoft.com/en-us/archive/blogs/ie/ie8-security-part-vi-beta-2-update) 헤더를 사용하면 인터넷 익스플로러는 응답에 선언한 content-type 외의 타입으로 MIME 스니핑을 하지 않는다. 구글 크롬 확장 프로그램을 다운로드할 때도 이 헤더를 사용한다.
- `Public-Key-Pinning` 또는 `Public-Key-Pinning-Report-Only` - [hpkp](#hpkp) 요소로 설정할 수 있다. HTTPS 웹사이트는 hpkp 헤더로 잘못 발급한 인증서나 허위 인증서를 사용하는 공격을 방지할 수 있다.
- `Content-Security-Policy` 또는 `Content-Security-Policy-Report-Only` - [content-security-policy](#content-security-policy) 요소로 설정할 수 있다. [컨텐츠 보안 정책(CSP)](https://www.w3.org/TR/CSP2/)은 웹 어플리케이션에서 XSS(cross-site scripting)같은 컨텐츠 인젝션 공격 취약성을 개선할 때 사용할 수 있는 메커니즘이다.
- `Referrer-Policy` - [referrer-policy](#referrer-policy) 요소로 설정할 수 있다. [Referrer-Policy](https://www.w3.org/TR/referrer-policy/)는 웹 어플리케이션에서 사용자가 직전에 방문했던 페이지를 가리키는 레퍼러 필드를 관리할 수 있는 메커니즘이다.
- `Feature-Policy` - [feature-policy](#feature-policy) 요소로 설정할 수 있다. [Feature-Policy](https://wicg.github.io/feature-policy/)는 브라우저의 특정 API나 웹 기능을 웹 개발자가 원하는대로 활성화, 비활성화, 수정할 수 있는 메커니즘이다.

##### \<headers\> Attributes

`<headers>` 요소에 있는 속성으로 headers 요소를 제어한다.

- **defaults-disabled** 스프링 시큐리티의 디폴트 HTTP 응답 헤더를 비활성화할 수 있는, 생략 가능한 속성. 디폴트는 false다 (디폴트 헤더를 추가한다).
- **disabled** 스프링 시큐리티의 HTTP 응답 헤더를 비활성화할 수 있는, 생략 가능한 속성. 디폴트는 false다 (헤더를 활성화한다).

##### Parent Elements of \<headers\>

- [http](#http)

##### Child Elements of \<headers\>

- [cache-control](#cache-control)
- [content-security-policy](#content-security-policy)
- [content-type-options](#content-type-options)
- [feature-policy](#feature-policy)
- [frame-options](#frame-options)
- [header](#header)
- [hpkp](#hpkp)
- [hsts](#hsts)
- [referrer-policy](#referrer-policy)
- [xss-protection](#xss-protection)

#### \<cache-control\>

브라우저에서 보호 중인 페이지를 캐시에 저장하지 않게 만들려면 `Cache-Control`, `Pragma`, `Expires` 헤더를 추가해라.

##### \<cache-control\> Attributes

- **disabled** Cache-Control을 비활성화할지를 지정한다. 디폴트는 false다.

##### Parent Elements of \<cache-control\>

- [headers](#headers)

#### \<hsts\>

활성화하면 보호 중인 모든 요청에 대한 응답에 [Strict-Transport-Security](https://tools.ietf.org/html/rfc6797) 헤더를 추가한다. 이 헤더를 사용하고 나면 브라우저에서 자동으로 HTTPS 요청을 보낸다.

##### \<hsts\> Attributes

- **disabled** Strict-Transport-Security를 비활성화할지를 지정한다. 디폴트는 false다.
- **include-sub-domains** 하위 도메인을 포함할지를 지정한다. 디폴트는 true다.
- **max-age-seconds** 호스트를 알고 있는 HSTS 호스트로 간주할 최대 시간을 지정한다. 디폴트는 1년이다.
- **request-matcher-ref** 헤더 설정 여부를 결정할 때 사용할 RequestMatcher 인스턴스. 디폴트로는 HttpServletRequest.isSecure()가 true면 헤더를 추가한다.
- **preload** preload를 추가할지를 지정한다. 디폴트는 false다.

##### Parent Elements of \<hsts\>

- [headers](#headers)

#### \<hpkp\>

활성화하면 보호 중인 모든 요청에 대한 응답에 [Public Key Pinning Extension for HTTP](https://tools.ietf.org/html/rfc7469) 헤더를 추가한다. HTTPS 웹사이트는 hpkp 헤더로 잘못 발급한 인증서나 허위 인증서를 사용하는 공격을 방지할 수 있다.

##### \<hpkp\> Attributes

- **disabled** HTTP Public Key Pinning (HPKP)을 비활성화할지를 지정한다. 디폴트는 true다.
- **include-sub-domains** 하위 도메인을 포함할지를 지정한다. 디폴트는 false다.
- **max-age-seconds** Public-Key-Pins 헤더의 max-age 지시문 값을 설정한다. 디폴트는 60일이다.
- **report-only** 브라우저가 pin 검증 실패를 리포팅만 할지를 지정한다. 디폴트는 true다.
- **report-uri** 브라우저가 pin 검증 실패를 보고할 URI를 지정한다.

##### Parent Elements of \<hpkp\>

- [headers](#headers)

#### \<pins\>

pin 리스트

##### Child Elements of \<pins\>

- [pin](#pin)

#### \<pin\>

값에는 base64로 인코딩한 SPKI 핑거프린트를, 속성에는 암호화 해시 알고리즘을 지정한다.

##### \<pin\> Attributes

- **algorithm** 암호화 해시 알고리즘. 디폴트는 SHA256이다.

##### Parent Elements of \<pin\>

- [pins](#pins)

#### \<content-security-policy\>

활성화하면 응답에 [Content Security Policy (CSP)](https://www.w3.org/TR/CSP2/) 헤더를 추가한다. CSP는 웹 어플리케이션에서 XSS(cross-site scripting)같은 컨텐츠 인젝션 공격 취약성을 개선할 때 사용할 수 있는 메커니즘이다.

##### \<content-security-policy\> Attributes

- **policy-directives** Content-Security-Policy 헤더의 (report-only가 true라면 Content-Security-Policy-Report-Only 헤더) 보안 정책 지시문을 나타낸다.
- **report-only** 정책 위반을 리포팅만 하고 싶다면 true로 설정해서 Content-Security-Policy-Report-Only 헤더를 활성화해라. 디폴트는 false다.

##### Parent Elements of \<content-security-policy\>

- [headers](#headers)

#### \<referrer-policy\>

활성화하면 응답에 [Referrer Policy](https://www.w3.org/TR/referrer-policy/) 헤더를 추가한다

##### \<referrer-policy\> Attributes

- **policy** Referrer-Policy 헤더의 정책. 디폴트는 "no-referrer"다.

##### Parent Elements of \<referrer-policy\>

- [headers](#headers)

#### \<feature-policy\>

활성화하면 응답에 [Feature Policy](https://wicg.github.io/feature-policy/) 헤더를 추가한다.

##### \<feature-policy\> Attributes

- **policy-directives** Feature-Policy 헤더의 보안 정책 지시문.

##### Parent Elements of \<feature-policy\>

- [headers](#headers)

#### \<frame-options\>

활성화하면 응답에 [X-Frame-Options 헤더](https://tools.ietf.org/html/draft-ietf-websec-x-frame-options)를 추가한다. 최신 브라우저는 이 헤더가 있으면 보안 정보를 확인해서 [클릭재킹](https://en.wikipedia.org/wiki/Clickjacking) 공격을 막는다.

##### \<frame-options\> Attributes

- **disabled** 비활성화하면 X-Frame-Options 헤더를 추가하지 않는다. 디폴트는 false다.
- **policy**
  - `DENY` 사이트에 상관 없이 프레임에서 페이지를 노출할 수 없다. frame-options-policy를 명시하면 디폴트로 이 정책을 사용한다.
  - `SAMEORIGIN` 페이지와 동일한 origin에서만 프레임으로 페이지를 노출할 수 있다.
  - `ALLOW-FROM origin` 지정한 origin에서만 프레임으로 페이지를 노출할 수 있다.<br>
    다시 말하면 DENY에선 다른 사이트뿐 아니라 동일한 사이트에서도 프레임 안에 페이지를 로드할 수 없다. 반면 SAMEORIGIN을 사용하면 페이지를 서빙하는 동일한 사이트에선 해당 페이지를 프레임 안에 넣을 수 있다.
- <span id="nsa-frame-options-strategy"></span>**strategy** ALLOW-FROM 정책에서 사용할 `AllowFromStrategy`를 선택한다.
  - `static` 정적인 단일 ALLOW-FROM 값을 사용한다. 값은 [value](#nsa-frame-options-value) 속성으로 설정한다.
  - `regexp` 정규식으로 요청을 검증하고 허용 여부를 확인한다. 정규식은 [value](#nsa-frame-options-value) 속성으로 설정한다. 검증할 때 이 값을 가져와야 하는 요청 파라미터는 [from-parameter](#nsa-frame-options-from-parameter)로 지정한다.
  - `whitelist` 허용할 도메인 리스트로, 쉼표로 구분한다. 쉼표로 구분하는 리스트는 [value](#nsa-frame-options-value) 속성으로 설정한다. 검증할 때 이 값을 가져와야 하는 요청 파라미터는 [from-parameter](#nsa-frame-options-from-parameter)로 지정한다.
- **ref** 미리 정의된 전략을 사용하는 대신 커스텀 `AllowFromStrategy`를 사용할 수도 있다. 이 빈에 대한 참조는 ref 속성으로 지정한다.
- <span id="nsa-frame-options-value"></span>**value** ALLOW-FROM을 사용할 때 [strategy](#nsa-frame-options-strategy)에서 사용할 값.
- <span id="nsa-frame-options-from-parameter"></span>**from-parameter** ALLOW-FROM 정책에서 regexp나 whitelist를 사용할 때 필요한 요청 파라미터 이름을 지정한다.

##### Parent Elements of \<frame-options\>

- [headers](#headers)

#### \<xss-protection\>

[reflected / Type-1 Cross-Site Scripting (XSS)](https://en.wikipedia.org/wiki/Cross-site_scripting#Non-Persistent) 공격을 방어하려면 응답에 [X-XSS-Protection 헤더](https://docs.microsoft.com/en-us/archive/blogs/ie/ie8-security-part-iv-the-xss-filter)를 추가해라. 단, 이 방법은 XSS 공격을 완전히 막아주진 못한다!

##### \<xss-protection\> Attributes

- **xss-protection-disabled** [reflected / Type-1 Cross-Site Scripting (XSS)](https://en.wikipedia.org/wiki/Cross-site_scripting#Non-Persistent) 방어를 위한 헤더를 추가하지 않는다.
- **xss-protection-enabled** Explicitly enable or disable [reflected / Type-1 Cross-Site Scripting (XSS)](https://en.wikipedia.org/wiki/Cross-site_scripting#Non-Persistent) 방어를 명시적으로 활성화/비활성화 한다.
- **xss-protection-block** 이 속성과 xss-protection-enabled 속성이 true면 헤더에 mode=block을 추가한다. 이는 브라우저가 페이지를 전부 로드하지 말아야 한다는 뜻이다. 이 속성은 false고 xss-protection-enabled이 true면, reflected 공격이 감지돼도 페이지를 렌더링할 수 있긴 하지만, 공격을 방어할 수 있도록 응답을 수정한다. 이 모드는 우회하는 방법이 있기 때문에 페이지를 완전히 막아버리는게 더 적합할 때도 있다.

##### Parent Elements of \<xss-protection\>

- [headers](#headers)

#### \<content-type-options\>

응답에 X-Content-Type-Options header 값을 nosniff로 추가한다. IE8+와 크롬 확장 프로그램에선 이 헤더로 [MIME-sniffing을 막는다](https://docs.microsoft.com/en-us/archive/blogs/ie/ie8-security-part-vi-beta-2-update).

##### \<content-type-options\> Attributes

- **disabled** Content Type Options를 비활성화할 때 명시한다. 디폴트는 false다.

##### Parent Elements of \<content-type-options\>

- [headers](#headers)

#### \<header\>

응답에 다른 헤더를 추가하려면 name, value를 모두 지정해야 한다.

##### \<header-attributes\> Attributes

- **header-name** 헤더의 `name.`
- **value** 추가할 헤더의 `value`.
- <span id="nsa-header-ref"></span>**ref** `HeaderWriter` 인터페이스의 커스텀 구현체에 대한 참조.

##### Parent Elements of \<header\>

- [headers](#headers)

#### \<anonymous\>

`AnonymousAuthenticationFilter`와 (필터 스택에), `AnonymousAuthenticationProvider`를 추가한다. `IS_AUTHENTICATED_ANONYMOUSLY` 속성을 사용할 때 필요하다.

##### Parent Elements of \<anonymous\>

- [http](#http)

##### \<anonymous\> Attributes

- **enabled** 디폴트 네임스페이스 설정에선 익명 "인증" 기능을 자동으로 활성화한다. 이 프로퍼티로 비활성화할 수 있다.
- **granted-authority** 익명 요청에 할당할 부여 권한. 보통은 익명 요청에 특정 role을 할당하는 식으로 사용하며, 이후 권한 인가를 결정할 때 이 role을 사용한다. 지정하지 않으면 디폴트로 `ROLE_ANONYMOUS`를 사용한다.
- **key** provider와 필터가 공유하는 키. 일반적으로는 설정하지 않아도 된다. 설정하지 않으면 디폴트로 안전하게 생성한 랜덤 값을 사용한다. 물론 안전한 랜덤 값을 생성하는 데 시간을 소요하기 때문에, 값을 미리 설정해두면 익명 기능을 사용할 때 기동 시간을 줄일 수 있다.
- **username** 익명 요청에 할당할 사용자 이름. 이 값으로 로깅이나 감사(auditing)에 중요한 역할을 하는 principal을 식별할 수 있다. 설정하지 않으면 디폴트로 `anonymousUser`를 사용한다.

#### \<csrf\>

이 요소는 어플리케이션에 [CSRF(Cross Site Request Forger)](https://en.wikipedia.org/wiki/Cross-site_request_forgery) 방어 기능을 추가한다. 또한 인증 성공 시 "GET" 요청만 캐시하도록 디폴트 RequestCache를 업데이트한다. 추가 정보는 이 문서의 [Cross Site Request Forgery (CSRF)](../features#521-cross-site-request-forgery-csrf) 섹션에서 확인할 수 있다.

##### Parent Elements of \<csrf\>

- [http](#http)

##### \<csrf\> Attributes

- **disabled** 스프링 시큐리티의 CSRF 방어를 비활성화할 때 명시하는 속성으로, 생략할 수 있다. 디폴트는 false다 (CSRF 방어를 활성화한다). 특별한 이유가 없다면 CSRF를 활성화한 채로 두는 게 좋다.
- **token-repository-ref** 사용할 CsrfTokenRepository. 디폴트는 `HttpSessionCsrfTokenRepository`다.
- <span id="nsa-csrf-request-matcher-ref"></span>**request-matcher-ref** CSRF를 적용 여부를 결정하기 위한 RequestMatcher 인스턴스. 디폴트는 "GET", "TRACE", "HEAD", "OPTIONS"를 제외한 모든 HTTP 메소드다.

#### \<custom-filter\>

이 요소는 필터 체인에 필터를 추가할 때 사용한다. 요소 자체에서 빈을 추가로 생성하진 않지만, 이미 어플리케이션 컨텍스트에 정의한 `javax.servlet.Filter` 타입 빈을 찾아 스프링 시큐리티가 관리하는 필터 체인의 특정 위치에 추가해 준다. 자세한 설명은 [네임스페이스 챕터](../securitynamespaceconfiguration#1831-adding-in-your-own-filters)에서 확인할 수 있다.

##### Parent Elements of \<custom-filter\>

- [http](#http)

##### \<custom-filter\> Attributes

- **after** 체인에서 커스텀 필터 바로 뒤에 있어야 하는 필터. 이 기능은 표준 스프링 시큐리티 필터를 어느 정도 알고 있으며, 자체 필터를 보안 필터 체인에 추가하려는 고급 사용자에게만 필요하다. 필터 이름은 특정 스프링 시큐리티 필터 구현체에 매핑된다.
- **before** 체인에서 커스텀 필터 바로 앞에 있어야 하는 필터.
- **position** 커스텀 필터를 배치할 체인의 명시적인 위치. 표준 필터를 대체할 때 사용해라.
- **ref** `Filter`를 구현한 스프링 빈에 대한 참조를 정의한다.

#### \<expression-handler\>

표현식 기반 접근 제어를 활성화한 경우에 사용할 `SecurityExpressionHandler` 인스턴스를 정의한다. 제공하지 않으면 디폴트 구현체를 (ACL 미지원) 사용한다.

##### Parent Elements of \<expression-handler\>

- [global-method-security](#global-method-security)
- [http](#http)
- [websocket-message-broker](#websocket-message-broker)

##### \<expression-handler\> Attributes

- **ref** `SecurityExpressionHandler`를 구현한 스프링 빈에 대한 참조를 정의한다.

#### \<form-login\>

`UsernamePasswordAuthenticationFilter`를 필터 스택에 추가하고, `LoginUrlAuthenticationEntryPoint`를 어플리케이션 컨텍스트에 추가해서 필요할 때 인증을 제공한다. 이 요소는 네임스페이스가 생성한 다른 entry point보다 항상 우선시된다. 속성을 제공하지 않으면 "/login" URL에 로그인 페이지를 자동으로 생성한다. 이 동작은 [`form-login` 속성](#form-login-attributes)으로 커스텀할 수 있다.

##### Parent Elements of \<form-login\>

- [http](#http)

##### \<form-login\> Attributes

- <span id="nsa-form-login-always-use-default-target"></span>**always-use-default-target** `true`로 설정하면 사용자는 로그인 페이지에 어떻게 도착했는지와는 상관없이, 항상 [default-target-url](#nsa-form-login-default-target-url)에 있는 값에서부터 시작한다. 이 속성은 `UsernamePasswordAuthenticationFilter`의 `alwaysUseDefaultTargetUrl` 프로퍼티로 매핑한다. 디폴트는 `false`다.
- **authentication-details-source-ref** 인증 필터에서 사용할 `AuthenticationDetailsSource` 참조.
- **authentication-failure-handler-ref** [authentication-failure-url](#nsa-form-login-authentication-failure-url) 대신 사용할 수 있는 속성으로, 인증 실패 시 플로우를 전부 컨트롤할 수 있다. 값에는 어플리케이션 컨텍스트에 있는 `AuthenticationFailureHandler` 빈 이름을 지정해야 한다.
- <span id="nsa-form-login-authentication-failure-url"></span>**authentication-failure-url** `UsernamePasswordAuthenticationFilter`의 `authenticationFailureUrl` 프로퍼티에 매핑한다. 로그인에 실패했을 때 브라우저가 리다이렉트할 URL이다. 디폴트는 자동 로그인 페이지 generator가 알아서 처리하는 `/login?error`로, 에러 메시지와 함께 로그인 페이지를 다시 렌러딩한다.
- **authentication-success-handler-ref** [default-target-url](#nsa-form-login-default-target-url)과 [always-use-default-target](#nsa-form-login-always-use-default-target) 대신 사용할 수 있는 속성으로, 인증 성공 시 플로우를 전부 컨트롤할 수 있다. 값에는 어플리케이션 컨텍스트에 있는 `AuthenticationSuccessHandler` 빈 이름을 지정해야 한다. 디폴트로 사용하는 구현체는 `SavedRequestAwareAuthenticationSuccessHandler`이며, [default-target-url](#nsa-form-login-default-target-url)과 함께 주입된다.
- <span id="nsa-form-login-default-target-url"></span>**default-target-url** `UsernamePasswordAuthenticationFilter`의 `defaultTargetUrl` 프로퍼티로 매핑된다. 설정하지 않으면 디폴트 값은 "/"다 (어플리케이션 루트). 사용자가 기존 요청 URL로 이동하면서 로그인하지 않은 채로 보호 중인 리소스에 접근하려고 한다면, 로그인한 후에 이 URL로 이동하게 된다.
- **login-page** 로그인 페이지를 렌더링할 때 사용할 URL. `LoginUrlAuthenticationEntryPoint`의 `loginFormUrl` 프로퍼티로 매핑된다. 디폴트는 "/login"이다.
- **login-processing-url** `UsernamePasswordAuthenticationFilter`의 `filterProcessesUrl` 프로퍼티로 매핑된다. 디폴트는 "/login"이다.
- **password-parameter** 비밀번호를 담고 있는 요청 파라미터 이름. 디폴트는 "password"다.
- **username-parameter** 사용자 이름을 담고 있는 요청 파리미터 이름. 디폴트는 "username"이다.
- **authentication-success-forward-url** `ForwardAuthenticationSuccessHandler`를 `UsernamePasswordAuthenticationFilter`의 `authenticationSuccessHandler` 프로퍼티로 매핑한다.
- **authentication-failure-forward-url** `ForwardAuthenticationFailureHandler`를 `UsernamePasswordAuthenticationFilter`의 `authenticationFailureHandler` 프로퍼티로 매핑한다.

#### \<oauth2-login\>

[OAuth 2.0 Login](../oauth2#121-oauth-20-login) 기능을 설정해서 OAuth 2.0, OpenID Connect 1.0 Provider로 인증한다.

##### Parent Elements of \<oauth2-login\>

- [http](#http)

##### \<oauth2-login\> Attributes

- **client-registration-repository-ref** `ClientRegistrationRepository`에 대한 참조.
- **authorized-client-repository-ref** `OAuth2AuthorizedClientRepository`에 대한 참조.
- **authorized-client-service-ref** `OAuth2AuthorizedClientService`에 대한 참조.
- **authorization-request-repository-ref** `AuthorizationRequestRepository`에 대한 참조.
- **authorization-request-resolver-ref** `OAuth2AuthorizationRequestResolver`에 대한 참조
- **access-token-response-client-ref** `OAuth2AccessTokenResponseClient`에 대한 참조.
- **user-authorities-mapper-ref** `GrantedAuthoritiesMapper`에 대한 참조.
- **user-service-ref** `OAuth2UserService`에 대한 참조.
- **oidc-user-service-ref** OpenID Connect `OAuth2UserService`에 대한 참조.
- **login-processing-url** 필터가 인증 요청을 처리할 URI.
- **login-page** 로그인할 사용자를 보낼 URI.
- **authentication-success-handler-ref** `AuthenticationSuccessHandler`에 대한 참조.
- **authentication-failure-handler-ref** `AuthenticationFailureHandler`에 대한 참조.
- **jwt-decoder-factory-ref** `OidcAuthorizationCodeAuthenticationProvider`가 사용할 `JwtDecoderFactory`에 대한 참조.

#### \<oauth2-client\>

[OAuth 2.0 클라이언트](../oauth2#122-oauth-20-client) 기능을 설정한다.

##### Parent Elements of \<oauth2-client\>

- [http](#http)

##### \<oauth2-client\> Attributes

- **client-registration-repository-ref** `ClientRegistrationRepository`에 대한 참조.
- **authorized-client-repository-ref** `OAuth2AuthorizedClientRepository`에 대한 참조.
- **authorized-client-service-ref** `OAuth2AuthorizedClientService`에 대한 참조.

##### Child Elements of \<oauth2-client\>

- [authorization-code-grant](#authorization-code-grant)

#### \<authorization-code-grant\>

[OAuth 2.0 인가 코드 부여](../oauth2#1222-authorization-grant-support)를 설정한다.

##### Parent Elements of \<authorization-code-grant\>

- [oauth2-client](#oauth2-client)

##### \<authorization-code-grant\> Attributes

- **authorization-request-repository-ref** `AuthorizationRequestRepository`에 대한 참조.
- **authorization-request-resolver-ref** `OAuth2AuthorizationRequestResolver`에 대한 참조.
- **access-token-response-client-ref** `OAuth2AccessTokenResponseClient`에 대한 참조.

#### \<client-registrations\>

OAuth 2.0 또는 OpenID Connect 1.0 Provider에 등록한 클라이언트([ClientRegistration](../oauth2#clientregistration))의 컨테이너 요소.

##### Child Elements of \<client-registrations\>

- [client-registration](#client-registration)
- [provider](#provider)

#### \<client-registration\>

OAuth 2.0 또는 OpenID Connect 1.0 Provider에 등록한 클라이언트를 나타낸다.

##### Parent Elements of \<client-registration\>

- [client-registrations](#client-registrations)

##### \<client-registration\> Attributes

- **registration-id** `ClientRegistration`을 식별할 수 있는 유니크한 ID.
- **client-id** 클라이언트 식별자.
- **client-secret** 클라이언트 secret.
- **client-authentication-method** provider에서 클라이언트를 인증할 때 사용할 메소드. **basic**, **post**,  **none**[(public 클라이언트)](https://tools.ietf.org/html/rfc6749#section-2.1)을 지원한다.
- **authorization-grant-type** OAuth 2.0 인가 프레임워크는 네 가지 [권한 부여 (Authorization Grant)](https://tools.ietf.org/html/rfc6749#section-1.3) 타입을 정의하고 있다. 지원하는 값은 `authorization_code`, `client_credentials`, `password`다.
- **redirect-uri** 클라이언트에 등록한 리다이렉트 URL로, 사용자의 인증으로 클라이언트에 접근 권한을 부여하고 나면, *인가 서버*가 이 URL로 최종 사용자의 user-agent를 리다이렉트시킨다.
- **scope** 인가 요청 플로우에서 클라이언트가 요청한 openid, 이메일, 프로필 등의 scope.
- **client-name** 클라이언트를 나타내는 이름. 자동 생성되는 로그인 페이지에서 노출하는 등에 사용한다.
- **provider-id** 관련 provider에 대한 참조. `<provider>` 요소를 참조하거나, 공통 provider (구글, 깃허브, 페이스북, 옥타) 중 하나를 사용할 수 있다.

##### \<provider\>

OAuth 2.0 또는 OpenID Connect 1.0 Provider에 관한 설정 정보

##### Parent Elements of \<provider\>

- [client-registrations](#client-registrations)

##### \<provider\> Attributes

- **provider-id** provider를 식별할 수 있는 유니크한 ID.
- **authorization-uri** 인가 서버의 인가 엔드포인트 URI.
- **token-uri** 인가 서버의 토큰 엔드포인트 URL.
- **user-info-uri** 인증된 최종 사용자의 클레임/속성에 접근할 때 사용하는 UserInfo 엔드포인트 URI.
- **user-info-authentication-method** UserInfo 엔드포인트로 액세스 토큰을 전송할 때 사용할 인증 메소드. **header**, **form**, **query**를 지원한다.
- **user-info-user-name-attribute** UserInfo 응답에 있는 속성 이름으로, 최종 사용자의 이름이나 식별자에 접근할 때 사용한다.
- **jwk-set-uri** 인가 서버에서 [JSON 웹 키 (JWK)](https://tools.ietf.org/html/rfc7517) 셋을 가져올 때 사용할 URI. 이 키 셋엔 ID 토큰의 [JSON Web Signature (JWS)](https://tools.ietf.org/html/rfc7515)를 검증할 때 사용할 암호키가 있으며, UserInfo 응답을 검증할 때도 사용할 수 있다.
- **issuer-uri** `ClientRegistration`을 초기화할 때 OpenID Connect Provider의 [설정 엔드포인트](https://openid.net/specs/openid-connect-discovery-1_0.html#ProviderConfig)나 인가 서버의 [메타데이터 엔드포인트](https://tools.ietf.org/html/rfc8414#section-3)를 찾기 위한 URI.

#### \<oauth2-resource-server\>

설정에 `BearerTokenAuthenticationFilter`, `BearerTokenAuthenticationEntryPoint`, `BearerTokenAccessDeniedHandler`를 추가한다. `<jwt>`나 `<opaque-token>`을 함께 지정해야 한다.

##### Parents Elements of \<oauth2-resource-server\>

- [http](#http)

##### Child Elements of \<oauth2-resource-server\>

- [jwt](#jwt)
- [opaque-token](#opaque-token)

##### \<oauth2-resource-server\> Attributes

- **authentication-manager-resolver-ref** 요청 시점에 `AuthenticationManager`를 리졸브하는 `AuthenticationManagerResolver`에 대한 참조.
- **bearer-token-resolver-ref** 요청에서 bearer 토큰을 가져오는 `BearerTokenResolver`에 대한 참조.
- **entry-point-ref** 권한이 없는 요청을 처리할 `AuthenticationEntryPoint`에 대한 참조.

#### \<jwt\>

JWT를 사용하는 OAuth 2.0 리소스 서버를 나타낸다.

##### Parent Elements of \<jwt\>

- [oauth2-resource-server](#oauth2-resource-server)

##### \<jwt\> Attributes

- **jwt-authentication-converter-ref** `Converter<Jwt, AbstractAuthenticationToken>`에 대한 참조.
- **jwt-decoder-ref** `JwtDecoder`에 대한 참조. `jwk-set-uri`를 재정의하는 더 큰 컴포넌트다.
- **jwk-set-uri** 서명을 검증할 때 사용할 키를 OAuth 2.0 인가 서버에서 로드하기 위한 JWK 셋 Uri.

#### \<opaque-token\>

opaque 토큰을 사용하는 OAuth 2.0 리소스 서버를 나타낸다.

##### Parent Elements of \<opaque-token\>

- [oauth2-resource-server](#oauth2-resource-server)

##### \<opaque-token\> Attributes

- **introspector-ref** `OpaqueTokenIntrospector`에 대한 참조. `introspection-uri`, `client-id`, `client-secret`을 재정의하는 더 큰 컴포넌트다.
- **introspection-uri** opaque 토큰의 상세 정보를 얻기 위한 Introspection Uri. `client-id`, `client-secret`과 함께 제공해야 한다.
- **client-id** `introspection-uri`에서 클라이언트를 인증하기 위한 클라이언트 id.
- **client-secret** `introspection-uri`에서 클라이언트를 인증하기 위한 클라이언트 Secret.

#### \<http-basic\>

설정에 `BasicAuthenticationFilter`, `BasicAuthenticationEntryPoint`를 추가한다. 후자는 폼 기반 로그인을 활성화하지 않은 경우에만 사용하는 설정 엔트리 포인트다.

##### Parent Elements of \<http-basic\>

- [http](#http)

##### \<http-basic\> Attributes

- **authentication-details-source-ref** 인증 필터에서 사용할 `AuthenticationDetailsSource`에 대한 참조.
- **entry-point-ref** `BasicAuthenticationFilter`에서 사용할 `AuthenticationEntryPoint`를 설정한다.

#### \<http-firewall\> Element

네임스페이스가 생성한 `FilterChainProxy`에 커스텀 `HttpFirewall` 구현체를 주입할 수 있는 최상위 요소다. 대부분은 디폴트 구현체로도 충분할 거다.

##### \<http-firewall\> Attributes

- **ref** `HttpFirewall`을 구현한 스프링 빈에 대한 참조를 정의한다.

#### \<intercept-url\>

이 요소로는 어플리케이션에서 관심있는 URL 패턴 셋을 정의하고, 이 URL을 처리하는 방법을 설정할 수 있다. `FilterSecurityInterceptor`에서 사용하는 `FilterInvocationSecurityMetadataSource`는 이 요소에 있는 값으로 설정한다. 예를 들어 특정 URL은 HTTPS로 접근해야 하는 경우엔 `ChannelProcessingFilter`를 설정할 수도 있다. 지정한 패턴과 요청을 매칭할 때는 요소를 선언한 순서대로 매칭한다. 따라서 가장 구체적인 패턴이 앞에 오고, 가장 일반적인 패턴이 마지막에 와야 한다.

##### Parent Elements of \<intercept-url\>

- [filter-security-metadata-source](#filter-security-metadata-source)
- [http](#http)

##### \<intercept-url\> Attributes

- **access** 정의한 URL 패턴/메소드 조합에 해당하는 접근 속성 리스트로, `FilterInvocationSecurityMetadataSource`에 저장된다. 보안 설정 속성을 (role 이름 등) 쉼표로 구분한 리스트여야 한다.
- <span id="nsa-intercept-url-method"></span>**method** 요청과 매칭할 패턴과 서블릿 path(옵션)와 함께 사용할 HTTP 메소드. 생략하면 모든 메소드와 매칭된다. 동일한 패턴이라면 메소드를 지정한 매칭이 우선시된다.
- <span id="nsa-intercept-url-pattern"></span>**pattern** URL path를 정의하는 패턴. 상위 http 요소의 `request-matcher` 속성에 따라 내용이 달라지므로, 기본적으로는 ant path 문법이 적용된다.
- **request-matcher-ref** `<intercept-url>`을 적용할지 결정하는 `RequestMatcher`에 대한 참조.
- **requires-channel** 특정 URL 패턴에 HTTP, HTTPS 중 어떤 것으로 접근해야 하는지에 따라 "http" 또는 "https"가 될 수 있다. 우선 순위가 없다면 "any"를 사용해도 된다. 이 속성을 사용한 `<intercept-url>`이 있다면, 필터 스택에 `ChannelProcessingFilter`가 추가되고, 어플리케이션 컨텍스트에 관련 의존성도 추가된다.

`<port-mappings>` 설정을 추가하면, 이 요소를 통해 `SecureChannelProcessor`와 `InsecureChannelProcessor` 빈이 HTTP/HTTPS로 리다렉트할 포트를 결정한다.

> 이 설정은 [filter-security-metadata-source](#filter-security-metadata-source)에선 유효하지 않다.

- <span id="nsa-intercept-url-servlet-path"></span>**servlet-path** 요청을 매칭할 때 패턴, HTTP 메소드와 함께 사용하는 서블릿 path. 이 속성은 [request-matcher](#nsa-http-request-matcher)가 'mvc'일 때만 적용된다. 또한 이 값은 다음 두 가지 케이스에서만 필요하다. 1) `ServletContext`에 `'/'`로 시작하는 매핑이 있는 서로 다른 `HttpServlet`이 2개 이상 있다. 2) 패턴은 등록한 `HttpServlet` path와 동일한 값으로 시작한다 (디폴트 (루트) `HttpServlet` `'/'`는 제외).

> 이 설정은 [filter-security-metadata-source](#filter-security-metadata-source)에선 유효하지 않다.

#### \<jee\>

필터 체인에 J2eePreAuthenticatedProcessingFilter를 추가해서 컨테이너 인증을 통합한다.

##### Parent Elements of \<jee\>

- [http](#http)

##### \<jee\> Attributes

- **mappable-roles** HttpServletRequest에서 찾을 role 리스트로, 쉼표로 구분한다.
- **user-service-ref** user-service (또는 UserDetailsService 빈) Id에 대한 참조.

#### \<logout\>

필터 스택에 `LogoutFilter`를 추가한다. `SecurityContextLogoutHandler`를 함께 설정한다.

##### Parent Elements of \<logout\>

- [http](#http)

##### \<logout\> Attributes

- **delete-cookies** 사용자가 로그아웃하면 삭제할 쿠키 이름. 쉼표로 구분한다.
- **invalidate-session** `SecurityContextLogoutHandler`의 `invalidateHttpSession`으로 매핑된다. 디폴트는 "true"이므로, 로그아웃하면 세션을 무효화한다.
- **logout-success-url** 로그아웃하고나서 사용자가 이동할 URL. 디폴트는 \<form-login-login-page\>/?logout이다 (i.e. /login?logout).<br>
  이 속성을 설정하면 `SessionManagementFilter`에 속성 값으로 설정한 `SimpleRedirectInvalidSessionStrategy`를 주입한다. 유효하지 않은 세션 ID를 제출하면, 이 전략을 실행해서 설정에 있는 URL로 리다이렉트한다.
- **logout-url** 로그아웃을 유발할 URL (i.e. 필터로 처리할). 디폴트는 "/logout"이다.
- **success-handler-ref** 로그아웃 이후 처리를 담당할 `LogoutSuccessHandler` 인스턴스를 제공할 때 사용한다.

#### \<openid-login\>

`<form-login>`과 유사하며, 속성이 동일하다. `login-processing-url`의 디폴트 값은 "/login/openid"다. `OpenIDAuthenticationFilter`와 `OpenIDAuthenticationProvider`를 등록한다. 후자는 `UserDetailsService`를 참조해야 한다. 다시 말하지만, `user-service-ref` 속성으로 `id`를 지정하거나, 어플리케이션 컨텍스트에서 자동으로 찾을 수 있다.

##### Parent Elements of \<openid-login\>

- [http](#http)

##### \<openid-login\> Attributes

- <span id="nsa-openid-login-always-use-default-target"></span>**always-use-default-target** 로그아웃한 사용자를 항상 default-target-url로 리다이렉트해야 하는지 여부.
- **authentication-details-source-ref** 인증 필터에서 사용할 AuthenticationDetailsSource에 대한 참조.
- **authentication-failure-handler-ref** 인증에 실패한 요청을 처리하는 AuthenticationFailureHandler 빈에 대한 참조. 구현체는 후속으로 이어지는 URL로 이동시키는 일도 처리해야 하므로 authentication-failure-url과 함께 사용하면 안 된다.
- **authentication-failure-url** 로그인 실패 페이지 URL. 지정하지 않으면 스프링 시큐리티는 자동으로  /login?login_error URL에 로그인 실패 URL을 생성하고, 요청 시 로그인 실패 URL을 렌더링하기 위한 필터를 생성한다.
- **authentication-success-forward-url** `ForwardAuthenticationSuccessHandler`를 `UsernamePasswordAuthenticationFilter`의 `authenticationSuccessHandler` 프로퍼티로 매핑한다.
- **authentication-failure-forward-url** `ForwardAuthenticationFailureHandler`를 `UsernamePasswordAuthenticationFilter`의 `authenticationFailureHandler` 프로퍼티로 매핑한다.
- **authentication-success-handler-ref** 인증에 성공한 요청을 처리하는 AuthenticationSuccessHandler 빈에 대한 참조. 구현체는 후속으로 이어지는 URL로 이동시키는 일도 처리해야 하므로 [default-target-url](#nsa-openid-login-default-target-url)과 (또는 [always-use-default-target](#nsa-openid-login-always-use-default-target)과) 함께 사용하면 안 된다.
- <span id="nsa-openid-login-default-target-url"></span>**default-target-url** 인증에 성공한 이후, 사용자의 이전 작업을 재개할 수 없는 경우 리다이렉션할 URL. 일반적으로 사용자가 보호 중인 페이지를 요청해서 인증을 트리거하기 전에, 로그인 페이지를 방문한 경우에 해당한다. 지정하지 않으면 디폴트로 어플리케이션의 루트를 사용한다.
- **login-page** 로그인 페이지 URL. 지정하지 않으면 "/login" URL에 로그인 URL을 자동으로 생성하고, 요청 시 로그인 URL을 렌더링하기 위한 필터를 생성한다.
- **login-processing-url** 로그인 폼을 제출할 URL. 생략하면 디폴트는 "/login"이다.
- **password-parameter** 비밀번호를 담고 있는 요청 파라미터 이름. 디폴트는 "password"다.
- **user-service-ref** user-service (또는 UserDetailsService 빈) Id에 대한 참조.
- **username-parameter** 사용자 이름을 담고 있는 요청 파리미터 이름. 디폴트는 "username”이다.

##### Child Elements of \<openid-login\>

- [attribute-exchange](#attribute-exchange)

#### \<attribute-exchange\>

`attribute-exchange` 요소는 identity provider로 요청해야 하는 속성 리스트를 정의한다. 예제는 네임스페이스 설정 챕터에 있는 [OpenID Support](../authentication#1013-openid-support) 섹션에서 확인할 수 있다. OpenID 식별자를 매칭할 수 있는 정규식을 `identifier-match` 속성에 지정하면, 요소를 둘 이상 정의할 수 있다. 이렇게 하면 여러 공급자에서 (구글, 야후 등) 각각 다른 속성 리스트를 가져올 수 있다.

##### Parent Elements of \<attribute-exchange\>

- [openid-login](#openid-login)

##### \<attribute-exchange\> Attributes

- **identifier-match** 인증에 사용할 attribute-exchange 설정을 정하기 위해 OpenID 식별자와 비교하는 정규식.

##### Child Elements of \<attribute-exchange\>

- [openid-attribute](#openid-attribute)

#### \<openid-attribute\>

OpenID AX [Fetch 요청](https://openid.net/specs/openid-attribute-exchange-1_0.html#fetch_request)을 만들 때 사용할 속성

##### Parent Elements of \<openid-attribute\>

- [attribute-exchange](#attribute-exchange)

##### \<openid-attribute\> Attributes

- **count** 반환받고 싶은 속성 수를 지정한다. 예를 들어 3개의 이메일 주소를 받을 수 있다. 디폴트는 1이다.
- **name** 반환받고 싶은 속성 이름을 지정한다. 예를 들어 email.
- **required** OP에 이 속성이 필수값임을 알리지만, OP가 이 속성을 반환하지 않아도 에러가 발생하진 않는다. 디폴트는 false다.
- **type** 속성 타입을 지정한다. 예를 들어 https://axschema.org/contact/email. 유효한 속성 타입은 OP의 문서를 참고해라.

#### \<port-mappings\>

`PortMapperImpl` 인스턴스는 secure URL과 insecure URL로 리다이렉션하기 위해 디폴트로 설정에 추가된다. 원한다면 이 요소로 클래스가 정의하고 있는 디폴트 매핑을 재정의할 수 있다. 각 하위 `<port-mapping>`  요소로는 HTTP:HTTPS 포트 쌍을 정의한다. 디폴트 매핑은 80:443과 8080:8443이다. 재정의하는 예제는 [Redirect to HTTPS](../protectionagainstexploits#1431-redirect-to-https) 섹션에서 확인할 수 있다.

##### Parent Elements of \<port-mappings\>

- [http](#http)

##### Child Elements of \<port-mappings\>

- [port-mapping](#port-mapping)

#### \<port-mapping\>

강제로 리다이렉트시킬 때 http 포트를 https 포트로 매핑할 수 있다.

##### Parent Elements of \<port-mapping\>

- [port-mappings](#port-mappings)

##### \<port-mapping\> Attributes

- **http** 사용할 http 포트.
- **https** 사용할 https 포트.

#### \<remember-me\>

필터 스택에 `RememberMeAuthenticationFilter`를 추가한다. 필터엔 `TokenBasedRememberMeServices`, `PersistentTokenBasedRememberMeServices` 순으로 설정되며, 혹은 속성에 따라 사용자가 지정한 `RememberMeServices` 구현체를 설정할 수도 있다.

##### Parent Elements of \<remember-me\>

- [http](#http)

##### \<remember-me\> Attributes

- **authentication-success-handler-ref** 인증 성공 처리를 직접 제어해야 한다면 `RememberMeAuthenticationFilter`의 `authenticationSuccessHandler` 프로퍼티를 설정해라. 어플리케이션 컨텍스트에 있는 `AuthenticationSuccessHandler` 빈 이름을 설정해야 한다.
- **data-source-ref** `DataSource` 빈에 대한 참조. 이 속성을 설정하면`JdbcTokenRepositoryImpl` 인스턴스로 설정된 `PersistentTokenBasedRememberMeServices`를 사용한다.
- **remember-me-parameter** remember-me 인증으로 전환해주는 요청 파리미터명. 디폴트는 "remember-me"다. 이 값은 `AbstractRememberMeServices`의 "parameter" 프로퍼티로 매핑된다.
- **remember-me-cookie** remember-me 인증에서 사용할 토큰을 저장하는 쿠키명. 디폴트는 "remember-me"다. 이 값은 `AbstractRememberMeServices`의 "cookieName" 프로퍼티로 매핑된다.
- **key** `AbstractRememberMeServices`의 "key" 프로퍼티로 매핑된다. remember-me 쿠키가 단일 어플리케이션 내에서만 유효하도록 유니크한 값으로 설정해야 한다. 따로 설정하지 않으면 안전한 랜덤 값을 생성한다. 안전한 랜덤 값을 생성하는 데 시간을 소요하기 때문에, 값을 미리 설정해두면 remember-me 기능을 사용할 때 기동 시간을 줄일 수 있다.
- **services-alias** 내부에서 정의한 `RememberMeServices` 빈을 어플리케이션 컨텍스트에 있는 다른 빈에서도 사용할 수 있도록 별칭을 외부로 노출한다.
- **services-ref** 필터에서 사용할 `RememberMeServices` 구현체를 완전히 제어할 수 있다. 이 인터페이스를 구현한, 어플리케이션 컨텍스트에 있는 빈 `id`를 지정해야 한다. 로그아웃 필터를 사용 중이라면 `LogoutHandler` 인터페이스도 구현해야 한다.
- **token-repository-ref** `PersistentTokenBasedRememberMeServices`를 설정하지만 커스텀 `PersistentTokenRepository` 빈을 사용할 수 있다.
- **token-validity-seconds** `AbstractRememberMeServices`의 `tokenValiditySeconds` 프로퍼티에 매핑된다. remember-me 쿠키의 유효 기간을 초 단위로 지정한다. 디폴트는 14일이다.
- **use-secure-cookie** remember-me 쿠키는 HTTPS로만 제출하고, "secure" 플래그를 다는게 좋다. 디폴트로는 로그인 요청으로 맺은 커넥션이 secure 커넥션이라면 secure 쿠키를 사용한다 (그래야 하므로). 이 프로퍼티를 `false`로 설정하면 secure 쿠키를 사용하지 않는다. `true`로 설정하면 항상 쿠키에 secure 플래그를 설정한다. 이 속성은 `AbstractRememberMeServices`의 `useSecureCookie` 프로퍼티에 매핑된다.
- **user-service-ref** remember-me services 구현체는 `UserDetailsService`에 접근해야 하므로 어플리케이션 컨텍스트에 최소 하나는 정의돼 있어야 한다. 딱 하나만 있으면 네임스페이스 설정에서 자동으로 선택한다. 인스턴스가 여러 개일 땐 이 속성으로 빈 `id`를 지정할 수 있다.

#### \<request-cache\> Element

`ExceptionTranslationFilter`에서 `AuthenticationEntryPoint`를 실행하기 전에, 요청 정보를 저장할 때 사용할 `RequestCache` 인스턴스를 설정한다.

##### Parent Elements of \<request-cache\>

- [http](#http)

##### \<request-cache\> Attributes

- **ref** 스프링 빈 `RequestCache`에 대한 참조를 정의한다.

#### \<session-management\>

세션 관리 기능은 필터 스택에 `SessionManagementFilter`를 추가하는 것으로 구현한다.

##### Parent Elements of \<session-management\>

- [http](#http)

##### \<session-management\> Attributes

- **invalid-session-url** 이 속성을 설정하면 이 값으로 설정한 `SimpleRedirectInvalidSessionStrategy`를 `SessionManagementFilter`에 주입한다. 유효하지 않은 세션 ID를 제출하면, 이 전략을 실행해서 설정한 URL로 리다이렉트한다.
- **invalid-session-strategy-ref** SessionManagementFilter에서 사용할 InvalidSessionStrategy 인스턴스를 주입할 수 있다. 이 속성이나 `invalid-session-url` 속성을 사용하면 되고, 둘 다 사용하는 것은 안 된다.
- **session-authentication-error-url** SessionAuthenticationStrategy에서 예외가 발생하면 노출할 오류 페이지 URL을 정의한다. 설정하지 않으면 클라이언트에 unauthorized (401) 에러 코드를 반환한다. 폼 기반 로그인에서 에러가 발생했을 땐 이 이 속성을 적용하지 않으며, 인증 실패 URL을 우선 적용한다.
- **session-authentication-strategy-ref** SessionManagementFilter에서 사용할 SessionAuthenticationStrategy 인스턴스를 주입할 수 있다.
- **session-fixation-protection** 사용자를 인증할 때 적용할 session fixation 방어 방법을 지정한다. "none"으로 설정하면 아무런 방어도 하지 않는다. "newSession"은 스프링 시큐리티와 관련있는 속성만 마이그레이션한 빈 세션을 새로 만든다. "migrateSession"은 새 세션을 만들어 기존 세션의 모든 속성을 새 세션으로 복사한다. 서블릿 3.1(자바 EE 7) 이상의 컨테이너에선 "changeSessionId"를 명시하면 기존 세션을 유지하고 컨테이너에서 제공하는 session fixation 방어(HttpServletRequest#changeSessionId())를 사용한다. 서블릿 3.1 이상 컨테이너는 "changeSessionId"가, 이전 버전에선 "migrateSession"이 디폴트다. 구버전 컨테이너에서 "changeSessionId"를 사용하면 예외를 던진다.<br>
  session fixation 방어를 활성화하면 `SessionManagementFilter`에 적절하게 설정한 `DefaultSessionAuthenticationStrategy`를 주입한다. 이 클래스에 대한 자세한 정보는 Javadoc을 참고해라.

##### Child Elements of \<session-management\>

- [concurrency-control](#concurrency-control)

#### \<concurrency-control\>

동시 세션 제어 기능을 추가하면 사용자의 활성 상태 세션 수를 제한할 수 있다. `ConcurrentSessionFilter`를 생성하고, `SessionManagementFilter`는 `ConcurrentSessionControlAuthenticationStrategy`를 사용한다. `form-login` 요소를 선언했다면 여기서 생성한 인증 필터에도 전략 객체를 주입한다. 전략에서 사용할 `SessionRegistry` 인스턴스도 (커스텀 빈을 사용하지 않는다면 `SessionRegistryImpl` 인스턴스) 함께 생성한다.

##### Parent Elements of \<concurrency-control\>

- [session-management](#session-management)

##### \<concurrency-control\> Attributes

- **error-if-maximum-exceeded** "true"로 설정하면 사용자가 세션 최대 허용치를 초과할 때 `SessionAuthenticationException`이 발생한다. 디폴트 동작은 기존 세션을 만료한다.
- **expired-url** 세션 허용치를 다 채운 상태에서 다른 곳에서 또 로그인하려고 하면 동시 세션 컨트롤러가 세션을 "만료 처리"할 수도 있다. 이 속성은 이때 사용자가 만료된 세션을 사용하려고 하면 리다이렉트할 URL이다. `exception-if-maximum-exceeded`를 설정하지 않았다면 이 속성을 설정해야 한다. 값을 제공하지 않으면 응답에 만료 메세지를 직접 write한다.
- **expired-session-strategy-ref** ConcurrentSessionFilter에서 사용할 ExpiredSessionStrategy 인스턴스를 주입한다.
- **max-sessions** `ConcurrentSessionControlAuthenticationStrategy`의 `maximumSessions` 프로퍼티에 매핑된다. `-1`로 지정하면 세션 수를 제한하지 않는다.
- **session-registry-alias** 내부 세션 레지스트리에 대한 참조를 만들면 자체 빈이나 관리 인터페이스에서 이를 사용할 수 있다. `session-registry-alias` 속성을 지정하면 내부 빈을 노출하며, 다른 설정에선 이 이름으로 참조할 수 있다.
- **session-registry-ref** `session-registry-ref` 속성을 사용하면 자체 `SessionRegistry` 구현체를 등록할 수 있다. 이 구현체는 다른 동시 세션 제어 빈과 연결되므로 다른 빈에서도 이 구현체를 사용할 수 있다.

#### \<x509\>

X.509 인증 기능을 추가한다. 필터 스택에 `X509AuthenticationFilter`를 추가하고, `Http403ForbiddenEntryPoint` 빈을 생성한다. 후자는 사용 중인 다른 인증 메커니즘이 없을 때만 사용한다 (유일한 기능은 HTTP 403 에러 코드를 반환하는 것이다). `UserDetailsService`에 사용자 권한 로드를 위임하는 `PreAuthenticatedAuthenticationProvider`도 생성한다.

##### Parent Elements of \<x509\>

- [http](#http)

##### \<x509\> Attributes

- **authentication-details-source-ref** `AuthenticationDetailsSource`에 대한 참조.
- **subject-principal-regex** 인증서에서 사용자 이름을 추출할 때 사용할 정규식을 정의한다 (`UserDetailsService`와 함께 사용).
- **user-service-ref** `UserDetailsService` 인스턴스가 여러 개일 때 X.509에서 사용할 인스턴스를 지정한다. 설정하지 않으면 자동으로 적절한 인스턴스를 찾아 사용한다.

#### \<filter-chain-map\>

FilterChainMap에 FilterChainProxy 인스턴스를 명시적으로 설정할 때 사용한다.

##### \<filter-chain-map\> Attributes

- <span id="nsa-filter-chain-map-request-matcher"></span>**request-matcher** 요청을 매칭할 전략을 정의한다. 현재 옵션은 'ant'(ant path 패턴), 정규식은 'regex', 대소문자를 구분하지 않는 정규식은 'ciRegex'다.

##### Child Elements of \<filter-chain-map\>

- [filter-chain](#filter-chain)

#### \<filter-chain\>

특정 URL 패턴과 해당 패턴에 매칭되는 URL에 적용할 필터 리스트를 정의하는데 사용한다. 여러 필터 체인 요소를 리스트로 모아 FilterChainProxy를 설정할 때는, 가장 구체적인 패턴이 리스트 맨 위에, 가장 일반적인 패턴은 맨 아래에 있어야 한다.

##### Parent Elements of \<filter-chain\>

- [filter-chain-map](#filter-chain-map)

##### \<filter-chain\> Attributes

- **filters** `Filter`를 구현한 스프링 빈에 대한 참조로, 쉼표로 구분한 리스트로 표기한다. "none"은 이 `FilterChain`엔 `Filter`를 사용하지 않는다는 뜻이다.
- **pattern** RequestMatcher를 생성할 때 [request-matcher](#nsa-filter-chain-map-request-matcher)와 조합할 패턴.
- **request-matcher-ref** `filters` 속성에 있는 `Filter`의 호출 여부를 결정할 때 사용하는 `RequestMatcher`에 대한 참조.

#### \<filter-security-metadata-source\>

FilterSecurityInterceptor와 함께 사용할 FilterSecurityMetadataSource 빈을 명시적으로 설정할 때 사용한다. 일반적으로 \<http\> 요소를 사용하지 않고 FilterChainProxy를 명시적으로 설정할 때만 필요하다. 하위 intercept-url 요소는 pattern, method, access 속성만 사용해야 한다. 그 외는 모두 설정 에러가 발생한다.

##### \<filter-security-metadata-source\> Attributes

- **id** 컨텍스트 내에 있는 다른 빈에서 이 빈을 참조할 때 사용할 빈 식별자.
- **request-matcher** 요청을 매칭할 전략을 정의한다. 현재 옵션은 'ant'(ant path 패턴), 정규식은 'regex', 대소문자를 구분하지 않는 정규식은 'ciRegex'다.
- **use-expressions**  \<intercept-url\> 요소의 'access' 속성에서 기존 설정 속성 리스트대신 정규식 사용을 활성화한다. 디폴트는 'true'다. 활성화하면 각 속성에 Boolean 표현식을 하나씩 설정해야 한다. 표현식을 'true'로 평가하면 접근을 승인한다.

##### Child Elements of \<filter-security-metadata-source\>

- [intercept-url](#intercept-url)

### 22.5.2. WebSocket Security

스프링 시큐리티 4.0+는 메세지 인가 처리를 지원한다. 이 기능을 활용할 수 있는 한 가지 예시는 웹소켓 기반 어플리케이션 인증이다.

#### \<websocket-message-broker\>

이 websocket-message-broker 요소는 두 가지 모드가 있다. [websocket-message-broker@id](#nsa-websocket-message-broker-id)를 지정하지 않으면 이 요소는 다음과 같은 일을 한다:

- SimpAnnotationMethodMessageHandler에 AuthenticationPrincipalArgumentResolver를 커스텀 인자 리졸버로 등록한다. 따라서 `@AuthenticationPrincipal`로 현재 `Authentication`의 principal을 확인할 수 있다.
- clientInboundChannel에 SecurityContextChannelInterceptor를 자동으로 등록한다. 이렇게 하면 SecurityContextHolder를 메시지에 있는 사용자로 채운다.
- clientInboundChannel에 ChannelSecurityInterceptor를 등록한다. 이렇게 하면 메세지에 인가 조건을 명시할 수 있다.
- clientInboundChannel에 CsrfChannelInterceptor를 등록한다. 이렇게 하면 기존 도메인의 요청만 활성화할 수 있다.
- WebSocketHttpRequestHandler나 TransportHandlingSockJsService, DefaultSockJsService에 CsrfTokenHandshakeInterceptor를 등록한다. 이렇게 하면 HttpServletRequest에 있는 CsrfToken을 웹소켓 세션 속성으로 복사할 수 있다.

이 것 외에 다른 처리가 필요하다면 id를 명시해서 ChannelSecurityInterceptor를 지정할 수 있다. 그런 다음 스프링의 메세징 인프라와 직접 연결하면 된다. 이 방법은 더 번거롭긴 하지만, 설정을 더 세세하게 제어할 수 있다.

##### \<websocket-message-broker\> Attributes

- <span id="nsa-websocket-message-broker-id"></span>**id** 컨텍스트 내 다른 곳에서 ChannelSecurityInterceptor 빈을 참조할 때 사용할 빈 식별자. 이 속성을 지정하면 스프링 메세징 내에 스프링 시큐리티를 명시적으로 설정해야 한다. 지정하지 않으면 [\<websocket-message-broker\>](#websocket-message-broker)에서 설명한 것처럼 스프링 시큐리티는 메시징 인프라와 자동으로 통합된다.
- **same-origin-disabled** Stomp 헤더에 CSRF 토큰이 있어야 한다는 요구 사항을 비활성화한다 (디폴트는 false). 다른 origin에서의 SockJS 커넥션을 허용해야 할 때 기본값을 변경할 수 있다.

##### Child Elements of \<websocket-message-broker\>

- [expression-handler](#expression-handler)
- [intercept-message](#intercept-message)

#### \<intercept-message\>

메세지에 인가 규칙을 정의한다.

##### Parent Elements of \<intercept-message\>

- [websocket-message-broker](#websocket-message-broker)

##### \<intercept-message\> Attributes

- **pattern** 메세지 destination과 매칭할 ant 패턴. 예를 들어 "/\*\*"는 destination이 있는 모든 메세지와 매칭된다. "/admin/\*\*"은 "/admin/\*\*"으로 시작하는 destination이 있는 모든 메세지와 매칭된다.
- **type** 매칭할 메세지 타입. 유효한 값은 SimpMessageType에 정의돼 있다 (i.e. CONNECT, CONNECT_ACK, HEARTBEAT, MESSAGE, SUBSCRIBE, UNSUBSCRIBE, DISCONNECT, DISCONNECT_ACK, OTHER).
- **access** 메세지를 보호할 때 사용할 표현식. 예를 들어 "denyAll"은 매칭되는 모든 메세지를 거절한다. "permitAll"은 매칭되는 모든 메세지에 접근 권한을 부여한다. "hasRole('ADMIN')"은 'ROLE_ADMIN' role을 가진 사용자만 매칭된 메세지에 접근할 수 있다.

### 22.5.3. Authentication Services

스프링 시큐리티 3.0 이전에는 내부에서 자동으로 `AuthenticationManager`를 등록했다. 지금은 `<authentication-manager>` 요소로 직접 하나를 등록해야 한다. 이 요소는 스프링 시큐리티의 `ProviderManager` 클래스를 생성한다. `ProviderManager`엔 `AuthenticationProvider` 인스턴스를 하나 이상 설정해야 한다. `AuthenticationProvider` 인스턴스는 네임스페이스가 제공하는 요소로 생성하거나, `authentication-provider` 요소를 사용해서 표준 빈 정의를 리스트에 추가할 수도 있다.

#### \<authentication-manager\>

네임스페이스를 사용하는 스프링 시큐리티 어플리케이션은 반드시 이 요소를 어딘가에 추가해야 한다. 이 요소는 어플리케이션에 인증 서비스를 제공하는 `AuthenticationManager`를 등록한다. `AuthenticationProvider` 인스턴스를 생성하는 모든 요소는 이 요소의 자식 요소로 정의해야 한다.

##### \<authentication-manager\> Attributes

- **alias** 이 속성으로는 자체 설정에서 사용할 내부 인스턴스의 별칭을 정의할 수 있다.
- **erase-credentials** true로 설정하면, 사용자를 인증하고 나서 AuthenticationManager는 반환받은 Authentication 객체에 있는 모든 credential 데이터를 지운다. 말그대로 [`ProviderManager`](../authentication#106-providermanager)의 `eraseCredentialsAfterAuthentication` 프로퍼티로 매핑된다.
- **id** 이 속성으로는 자체 설정에서 사용할 내부 인스턴스 id를 정의할 수 있다. alias 요소와 동일하지만, 다른 요소들처럼 일관적으로 id 속성을 사용할 수 있다.

##### Child Elements of \<authentication-manager\>

- [authentication-provider](#authentication-provider)
- [ldap-authentication-provider](#ldap-authentication-provider)

#### \<authentication-provider\>

`ref` 속성과 함께 사용하지 않는 한, 이 요소는 `DaoAuthenticationProvider`를 설정하는 약칭으로 사용된다. `DaoAuthenticationProvider`는 `UserDetailsService`에서 사용자 정보를 불러와서 사용자 이름/비밀번호 조합을 로그인할 때 제공한 값과 비교한다. `UserDetailsService` 인스턴스는 네임스페이스 요소로 정의할 수 있다 (`jdbc-user-service` 또는 `user-service-ref` 속성으로 어플리케이션 컨텍스트에 있는 다른 빈을 가리켜서).

##### Parent Elements of \<authentication-provider\>

- [authentication-manager](#authentication-manager)

##### \<authentication-provider\> Attributes

- **ref** `AuthenticationProvider`를 구현한 스프링 빈에 대한 참조를 정의한다.

자체 `AuthenticationProvider` 구현체를 만들었다면 (또는 어떠한 이유로 스프링 시큐리티가 제공하는 구현체 중 하나를 기존 빈으로 설정하고 싶다면) 아래 문법을 사용해서 내부 `ProviderManager` 리스트에 추가할 수 있다:

```xml
<security:authentication-manager>
<security:authentication-provider ref="myAuthenticationProvider" />
</security:authentication-manager>
<bean id="myAuthenticationProvider" class="com.something.MyAuthenticationProvider"/>
```

- **user-service-ref** 표준 빈 요소나 커스텀 user-service 요소로 생성할 수 있는, UserDetailsService를 구현한 빈에 대한 참조.

##### Child Elements of \<authentication-provider\>

- [jdbc-user-service](#jdbc-user-service)
- [ldap-user-service](#ldap-user-service)
- [password-encoder](#password-encoder)
- [user-service](#user-service)

#### \<jdbc-user-service\>

JDBC 기반 UserDetailsService를 생성한다.

##### \<jdbc-user-service\> Attributes

- **authorities-by-username-query** 주어진 사용자 이름으로 부여받은 권한을 검색할 SQL 문.
디폴트 쿼리는 다음과 같다:
```sql
select username, authority from authorities where username = ?
```
- **cache-ref** UserDetailsService에서 사용할 캐시에 대한 참조를 정의한다.
- **data-source-ref** 필요한 테이블을 제공할 DataSource의 빈 ID.
- **group-authorities-by-username-query** 주어진 사용자 이름으로 사용자의 그룹 권한을 질의할 SQL 문. 디폴트는 다음과 같다.
  ```sql
  select
  g.id, g.group_name, ga.authority
  from
  groups g, group_members gm, group_authorities ga
  where
  gm.username = ? and g.id = ga.group_id and g.id = gm.group_id
  ```
- **id** 컨텍스트 내에 있는 다른 빈에서 이 빈을 참조할 때 사용할 빈 식별자.
- **role-prefix** 영구 스토리지에서 불러온 role 문자열에 추가할 비어있지 않은 문자열 (디폴트는 "ROLE\_"). 디폴트는 빈 문자열이 아니므로 프리픽스를 사용하지 않으려면 "none"으로 지정해라.
- **users-by-username-query** 사용자 이름에 따른 사용자 이름과 비밀번호, 활성화 상태를 질의할 SQL 문. 디폴트는 다음과 같다.
  
  ```sql
  select username, password, enabled from users where username = ?
  ```

#### \<password-encoder\>

인증 provider는 [Password Storage](../features#512-password-storage) 섹션에서 설명했듯이, 옵션으로 비밀번호 인코더를 설정할 수 있다. 이 요소를 사용하면 빈에 적절한 `PasswordEncoder` 인스턴스를 주입해 준다.

##### Parent Elements of \<password-encoder\>

- [authentication-provider](#authentication-provider)
- [password-compare](#password-compare)

##### \<password-encoder\> Attributes

- **hash** 사용자 비밀번호에 사용할 해싱 알고리즘을 정의한다. MD4는 매우 약한 해싱 알고리즘이기 때문에 사용하지 않기를 강력히 권고한다.
- **ref** `PasswordEncoder`를 구현한 스프링 빈에 대한 참조를 정의한다.

#### \<user-service\>

properties 파일, 또는 자식 요소 "user" 리스트를 사용해서 인메모리 UserDetailsService를 만든다. 사용자 이름은 대소문자 구분 없이 찾을 수 있도록 내부적으로 소문자로 변환한다. 따라서 대소문자를 구분해야 한다면 사용하면 안 된다.

##### \<user-service\> Attributes

- **id** 컨텍스트 내에 있는 다른 빈에서 이 빈을 참조할 때 사용할 빈 식별자.
- **properties** Properties 파일 위치. 각 라인은 아래와 같은 형식을 사용한다

  ```none
  username=password,grantedAuthority[,grantedAuthority][,enabled|disabled]
  ```

##### Child Elements of \<user-service\>

- [user](#user)

#### \<user\>

어플리케이션의 사용자를 나타낸다.

##### Parent Elements of \<user\>

- [user-service](#user-service)

##### \<user\> Attributes

- **authorities** 사용자에게 부여된 하나 이상의 권한. 쉼표로 권한을 구분한다 (공백 없음). 예를 들어 "ROLE_USER,ROLE_ADMINISTRATOR"
- **disabled** 계정을 비활성화 또는 사용 불가로 표시하려면 "true"로 설정하면 된다.
- **locked** 계정을 잠김 또는 사용 불가로 표시하려면 "true"로 설정하면 된다.
- **name** 사용자에게 할당한 사용자 이름.
- **password** 사용자에게 할당한 비밀번호. 해당 인증 provider가 해싱을 지원한다면 해싱한 비밀번호일 수도 있다 ("user-service" 요소의 "hash" 요소를 설정해야 한다). 데이터를 인증에는 사용하지 않고 권한에 접근할 때만 사용한다면 이 속성을 생략할 수 있다. 생략하면 네임스페이스에서 랜덤값을 생성해서 실수로 인증에 사용하지 않도록 방지해 준다. 빈 값은 허용하지 않는다.

### 22.5.4. Method Security

#### \<global-method-security\>

이 요소로 스프링 시큐리티 빈의 메소드를 보호하기 위한 주요 기능을 추가한다. 메소드는 애노테이션으로 보호하거나 (인터페이스나 클래스 레벨에 정의한), 하위 요소에 AspectJ 문법을 사용하는 포인트컷 셋을 정의해서 보호할 수 있다.

##### \<global-method-security\> Attributes

- **access-decision-manager-ref** 메소드 시큐리티는 웹 시큐리티와 동일한 `AccessDecisionManager` 설정을 사용하지만, 이 속성으로 재정의할 수 있다. 디폴트로는 RoleVoter와 AuthenticatedVoter를 사용하는 AffirmativeBased 구현체를 사용한다.
- **authentication-manager-ref** 메소드 시큐리티에서 사용할 `AuthenticationManager`에 대한 참조.
- **jsr250-annotations** JSR-250 스타일 속성 사용 여부를 지정한다 (i.e. "RolesAllowed"). JSR-250 스타일을 사용하려면 클래스패스에 javax.annotation.security 클래스가 있어야 한다. true로 설정하면 `AccessDecisionManager`에 `Jsr250Voter`도 추가하므로, 커스텀 구현체에서 JSR-250 애노테이션을 사용하고 싶다면 이에 맞는 속성을 추가해야 한다.
- **metadata-source-ref** 다른 소스(디폴트 애노테이션 등)보다 우선시할 외부 `MethodSecurityMetadataSource`를 제공할 수 있다.
- **mode** 이 속성을 "aspectj"로 설정하면 디폴트 스프링 AOP 대신 AspectJ를 사용한다. 보호할 메소드는 `spring-security-aspects` 모듈에 있는 `AnnotationSecurityAspect`로 구성해야 한다. AspectJ는 인터페이스에 있는 애노테이션은 상속하지 않는다는 자바의 규칙을 따른다는 점에 주의해라. 이 말은 인터페이스에 시큐리티 애노테이션을 정의한 메소드는 보호되지 않는다는 뜻이다. AspectJ를 사용할 땐 이대신 클래스에 시큐리티 애노테이션을 선언해야 한다.
- **order** 메소드 시큐리티 인터셉터에 advice "순서"를 설정할 수 있다.
- **pre-post-annotations** 어플리케이션 컨텍스트에 스프링 시큐리티의 사전, 사후 실행 애노테이션 (@PreFilter, @PreAuthorize, @PostFilter, @PostAuthorize) 활성화 여부를 지정한다. 디폴트는 "disabled"다.
- **proxy-target-class** true로 지정하면 인터페이스 기반 프록시 대신 클래스 기반 프록시를 사용한다.
- **run-as-manager-ref** 설정에 있는 `MethodSecurityInterceptor`에서 옵션으로 사용하는 `RunAsManager` 구현체에 대한 참조.
- **secured-annotations** 어플리케이션 컨텍스트에 스프링 시큐리티의 @Secured 애노테이션 활성화 여부를 지정한다. 디폴트는 "disabled"다.

##### Child Elements of \<global-method-security\>

- [after-invocation-provider](#after-invocation-provider)
- [expression-handler](#expression-handler)
- [pre-post-annotation-handling](#pre-post-annotation-handling)
- [protect-pointcut](#securing-methods-using)

#### \<after-invocation-provider\>

이 요소로는 `<global-method-security>` 네임스페이스에서 관리하는 보안 인터셉터에서 사용할 `AfterInvocationProvider`를 장식할 수 있다. `global-method-security` 요소 안에 이 요소를 0개 이상을 정의할 수 있으며, 각 요소에는 어플리케이션 컨텍스트에 있는 `AfterInvocationProvider` 빈 인스턴스를 가리키는 `ref` 속성이 있다.

##### Parent Elements of \<after-invocation-provider\>

- [global-method-security](#global-method-security)

##### \<after-invocation-provider\> Attributes

- **ref** `AfterInvocationProvider`를 구현한 스프링 빈에 대한 참조.

#### \<pre-post-annotation-handling\>

이 요소를 사용하면 스프링 시큐리티의 사전, 사후 실행 애노테이션을 (@PreFilter, @PreAuthorize, @PostFilter, @PostAuthorize) 처리하는 디폴트 표현식 기반 메커니즘을 완전히 대체할 수 있다. 이 애노테이션을 활성화했을 때만 적용된다.

##### Parent Elements of \<pre-post-annotation-handling\>

- [global-method-security](#global-method-security)

##### Child Elements of \<pre-post-annotation-handling\>

- [invocation-attribute-factory](#invocation-attribute-factory)
- [post-invocation-advice](#post-invocation-advice)
- [pre-invocation-advice](#pre-invocation-advice)

#### \<invocation-attribute-factory\>

애노테이션을 선언한 메소드에서 사전, 사후 실행 메타데이터를 생성할 때 사용하는 PrePostInvocationAttributeFactory 인스턴스를 정의한다.

##### Parent Elements of \<invocation-attribute-factory\>

- [pre-post-annotation-handling](#pre-post-annotation-handling)

##### \<invocation-attribute-factory\> Attributes

- **ref** 스프링 빈 id에 대한 참조를 정의한다.

#### \<post-invocation-advice\>

\<pre-post-annotation-handling\> 요소에서 사용할 `PostInvocationAuthorizationAdvice`를 ref로 지정해서 `PostInvocationAdviceProvider`를 커스텀한다.

##### Parent Elements of \<post-invocation-advice\>

- [pre-post-annotation-handling](#pre-post-annotation-handling)

##### \<post-invocation-advice\> Attributes

- **ref** 스프링 빈 id에 대한 참조를 정의한다.

#### \<pre-invocation-advice\>

\<pre-post-annotation-handling\> 요소에서 사용할 `PreInvocationAuthorizationAdviceVoter`를 ref로 지정해서 `PreInvocationAuthorizationAdviceVoter`를 커스텀한다.

##### Parent Elements of \<pre-invocation-advice\>

- [pre-post-annotation-handling](#pre-post-annotation-handling)

##### \<pre-invocation-advice\> Attributes

- **ref** 스프링 빈 id에 대한 참조를 정의한다.

#### Securing Methods using

`@Secured` 애노테이션으로 개별 메소드나 클래스에 보안 속성을 정의하는 대신, `<protect-pointcut>` 요소로 서비스 레이어에 있는 전체 메소드와 인터페이스 셋에 걸친 cross-cutting 보안 제약 조건을 정의할 수 있다. 예제는 [네임스페이스 소개](../authorization#1154-adding-security-pointcuts-using-protect-pointcut) 섹션에서 확인할 수 있다.

##### Parent Elements of \<protect-pointcut\>

- [global-method-security](#global-method-security)

##### \<protect-pointcut\> Attributes

- **access** 포인트컷에 매칭되는 모든 메소드에 적용할 접근 설정 속성 리스트. e.g. "ROLE_A,ROLE_B"
- **expression** 'execution' 키워드를 포함하는 AspectJ 표현식. 예를 들어 'execution(int com.foo.TargetObject.countLength(String))' (따옴표 제외).

#### \<intercept-methods\>

빈 정의 안에 이 요소를 사용하면, 해당 빈에 보안 인터셉터를 추가하고 메소드의 접근 설정 속성을 지정할 수 있다.

##### \<intercept-methods\> Attributes

- **access-decision-manager-ref** 생성한 메소드 시큐리티 인터셉터에서 선택적으로 사용할 AccessDecisionManager 빈 ID.

##### Child Elements of \<intercept-methods\>

- [protect](#protect)

#### \<method-security-metadata-source\>

MethodSecurityMetadataSource 인스턴스를 생성한다.

##### \<method-security-metadata-source\> Attributes

- **id** 컨텍스트 내에 있는 다른 빈에서 이 빈을 참조할 때 사용할 빈 식별자.
- **use-expressions** \<intercept-url\> 요소의 'access' 속성에서 기존 설정 속성 리스트대신 표현식 사용을 활성화한다. 디폴트는 'false'다. 활성화한다면 각 속성에 단일 Boolean 표현식을 사용해야 한다. 표현식을 'true'로 평가하면 접근 권한을 부여한다.

##### Child Elements of \<method-security-metadata-source\>

- [protect](#protect)

#### \<protect\>

보호할 메소드와, 이 메소드에 적용할 접근 제어 설정 속성을 정의한다. "protect" 선언을 "global-method-security"가 제공하는 서비스와 함께 쓰지 **않기를** 강력히 권고한다.

##### Parent Elements of \<protect\>

- [intercept-methods](#intercept-methods)
- [method-security-metadata-source](#method-security-metadata-source)

##### \<protect\> Attributes

- **access** 메소드에 적용할 접근 설정 속성 리스트. e.g. "ROLE_A,ROLE_B".
- **method** 메소드 이름.

### 22.5.5. LDAP Namespace Options

LDAP은 [전용 챕터](../authentication#101010-ldap-authentication)에서 자세히 다룬다. 여기선 어떻게 네임스페이스 옵션이 스프링 빈에 매핑되는지를 보충 설명한다. LDAP 구현체는 스프링 LDAP을 광범위하게 사용하므로 스프링 LDAP 프로젝트 API에 익숙하면 좀 더 수월할 거다.

#### Defining the LDAP Server using the

#### \<ldap-server\> 

이 요소에는 다른 LDAP 빈에서 사용할 스프링 LDAP `ContextSource`를 설정한다. 이 인터페이스는 LDAP 서버의 위치와 커넥션을 위한 기타 정보를 (익명 접근을 허용하지 않는 경우 사용자 이름과 비밀번호) 정의한다. 테스트용 임베디드 서버를 만드는 데도 사용할 수 있다. 각 옵션에서 사용하는 문법은 [LDAP 챕터](../authentication#101010-ldap-authentication)에서 자세히 다룬다. 실제 `ContextSource` 구현체는 스프링 LDAP의 `LdapContextSource` 클래스를 상속한 `DefaultSpringSecurityContextSource`다. `manager-dn`, `manager-password` 속성은 각각 `DefaultSpringSecurityContextSource`의 `userDn`, `password` 프로퍼티에 매핑된다.

어플리케이션 컨텍스트에 정의한 서버가 하나 뿐일 땐 네임스페이스에서 정의한 다른 LDAP 빈에서 이 LDAP 서버 정보를 자동으로 사용한다. 아니면 요소에 "id" 속성을 부여하면 다른 네임스페이스 빈에서 `server-ref` 속성으로 이 요소를 참조할 수 있다. 다른 전통적인 스프링 빈에서 서버 정보를 사용하려는 경우 실제로는 `ContextSource` 인스턴스의 빈 `id`를 지정한다.

##### \<ldap-server\> Attributes

- **mode** 사용할 ldap 임베디드 서버를 명시적으로 지정한다. 사용할 수 있는 값은 `apacheds`와 `unboundid`다. 디폴트로는 클래스패스에 있는 라이브러리에 따라 설정된다.
- **id** 컨텍스트 내에 있는 다른 빈에서 이 빈을 참조할 때 사용할 빈 식별자.
- **ldif** 임베디드 LDAP 서버로 로드할 ldif 파일 리소스를 명시적으로 지정한다. 스프링 리소스 패턴으로 지정해야 한다 (i.e. classpath:init.ldif). 디폴트는 classpath\*:\*.ldif이다.
- **manager-dn** (임베디드 타입이 아닌) LDAP 서버에 인증할 때 사용할 "manager" 사용자의 Username (DN). 생략하면 익명 접근을 사용한다.
- **manager-password** manager DN의 비밀번호. manager-dn을 지정했다면 필수로 입력해야 한다.
- **port** IP 포트 번호를 지정한다. 예를 들어 임베디드 LDAP 서버를 설정할 때 사용한다. 디폴트는 33389다.
- **root** 임베디드 LDAP 서버에서 사용할 루트 suffix. 생략할 수 있으며 디폴트는 "dc=springframework,dc=org"다.
- **url** 임베디드 LDAP 서버를 사용하지 않을 때 LDAP 서버 URL을 지정한다.

#### \<ldap-authentication-provider\>

이 요소는 `LdapAuthenticationProvider` 인스턴스를 생성하는 약칭이다. 이 요소는 디폴트로  `BindAuthenticator` 인스턴스와 `DefaultAuthoritiesPopulator`로 설정된다. 모든 네임스페이스 인증 provider와 마찬가지로, `authentication-manager` 요소의 자식으로 추가해야 한다.

##### Parent Elements of \<ldap-authentication-provider\>

- [authentication-manager](#authentication-manager)

##### \<ldap-authentication-provider\> Attributes

- **group-role-attribute** 스프링 시큐리티에서 사용할 role 이름을 포함하는 LDAP 속성 이름이다. `DefaultLdapAuthoritiesPopulator`의 `groupRoleAttribute` 프로퍼티에 매핑된다. 디폴트는 "cn"이다.
- **group-search-base** 그룹 멤버십을 검색할 search base. `DefaultLdapAuthoritiesPopulator`의 생성자 인자 `groupSearchBase`에 매핑된다. 디폴트는 ""다 (루트에서 찾는다).
- **group-search-filter** 그룹 검색 필터. `DefaultLdapAuthoritiesPopulator`의 `groupSearchFilter` 프로퍼티에 매핑된다. 디폴트는 `(uniqueMember={0})`이다. 파라미터는 사용자의 DN으로 대체된다.
- **role-prefix** 저장소에서 불러온 role 문자열에 추가할, 비어 있지 않은 문자열 프리픽스다. `DefaultLdapAuthoritiesPopulator`의 `rolePrefix` 프로퍼티에 매핑된다. 디폴트는 "ROLE\_"이다. 디폴트는 빈 문자열이 아니므로 프리픽스를 사용하지 않으려면 “none”으로 지정해라.
- **server-ref** 사용할 서버. 생략할 수 있다. 생략하면 사용할 디폴트 LDAP 서버를 등록한다 (id 없이 \<ldap-server\> 사용).
- **user-context-mapper-ref** 사용자 디렉토리 엔트리에 있는 컨텍스트 정보와 함께 호출할 UserDetailsContextMapper 빈을 지정해서 로드한 사용자 객체를 명시적으로 커스텀할 수 있다.
- **user-details-class** 사용자 엔트리의 objectClass를 지정할 수 있다. 설정하면 프레임워크는 정의한 클래스의 표준 속성을 반환받은 UserDetails 객체로 로드한다.
- **user-dn-pattern** 사용자가 고정된 디렉토리에 있다면 (i.e 디렉토리를 검색하지 않아도 사용자 이름만으로 DN을 알 수 있다면), 이 속성을 DN에 직접 매핑할 수 있다. 이 속성은 `AbstractLdapAuthenticator`의 `userDnPatterns` 프로퍼티로 바로 매핑된다. 속성 값에는 사용자의 DN을 빌드할 때 사용할 패턴을 지정한다 (i.e. `uid={0},ou=people`). `{0}` 키는 반드시 있어야 하며, 이 키는 사용자 이름으로 대체된다.
- **user-search-base** 사용자를 검색하기 위한 search base. 디폴트는 ""다.  항상 'user-search-filter'와 함께 사용한다.<br>디렉토리에서 사용자를 검색해야 할 땐 이 속성들로 검색 조건을 설정할 수 있다. `FilterBasedLdapUserSearch`는 `BindAuthenticator`에 설정되며, 속성에 있는 값은 `FilterBasedLdapUserSearch` 빈 생성자의 맨 앞에 있는 인자 두 개에 바로 매핑된다. 이 속성들을 설정하지 않고, 이를 대체할 수 있는 `user-dn-pattern`도 제공하지 않으면, 디폴트 검색 값으로 `user-search-filter="(uid={0})"`, `user-search-base=""`를 사용한다.
- **user-search-filter** 사용자를 검색할 때 사용할 LDAP 필터 (생략 가능). 예를 들어 `(uid={0})`. 파라미터는 로그인한 사용자 이름으로 대체된다.<br>디렉토리에서 사용자를 검색해야 할 땐 이 속성들로 검색 조건을 설정할 수 있다. `FilterBasedLdapUserSearch`는 `BindAuthenticator`에 설정되며, 속성에 있는 값은 `FilterBasedLdapUserSearch` 빈 생성자의 맨 앞에 있는 인자 두 개에 바로 매핑된다. 이 속성들을 설정하지 않고, 이를 대체할 수 있는 `user-dn-pattern`도 제공하지 않으면, 디폴트 검색 값으로 `user-search-filter="(uid={0})"`, `user-search-base=""`를 사용한다.

##### Child Elements of \<ldap-authentication-provider\>

- [password-compare](#password-compare)

#### \<password-compare\>

`<ldap-provider>` 하위에 이 요소를 사용하면 `BindAuthenticator`에서 `PasswordComparisonAuthenticator`로 인증 전략을 전환한다.

##### Parent Elements of \<password-compare\>

- [ldap-authentication-provider](#ldap-authentication-provider)

##### \<password-compare\> Attributes

- **hash** 사용자 비밀번호에 사용할 해싱 알고리즘을 정의한다. MD4는 매우 약한 해싱 알고리즘이기 때문에 사용하지 않기를 강력히 권고한다.
- **password-attribute** 사용자 비밀번호가 있는 디렉토리의 속성. 디폴트는 "userPassword"다.

##### Child Elements of \<password-compare\>

- [password-encoder](#password-encoder)

#### \<ldap-user-service\>

LDAP `UserDetailsService`를 설정하는 요소다. `FilterBasedLdapUserSearch`와 `DefaultLdapAuthoritiesPopulator`를 조합한 `LdapUserDetailsService` 클래스를 사용한다. 이 클래스가 지원하는 속성은 `<ldap-provider>`와 동일하게 사용할 수 있다.

##### \<ldap-user-service\> Attributes

- **cache-ref** UserDetailsService에서 사용할 캐시에 대한 참조를 정의한다.
- **group-role-attribute** 스프링 시큐리티에서 사용할 role 이름을 포함하는 LDAP 속성 이름이다. 디폴트는 "cn"이다.
- **group-search-base** 그룹 멤버십을 검색할 search base. 디폴트는 ""다 (루트에서 찾는다).
- **group-search-filter** 그룹 검색 필터. 디폴트는 `(uniqueMember={0})`이다. 파라미터는 사용자의 DN으로 대체된다.
- **id** 컨텍스트 내에 있는 다른 빈에서 이 빈을 참조할 때 사용할 빈 식별자.
- **role-prefix** 저장소에서 불러온 role 문자열에 추가할, 비어 있지 않은 문자열 프리픽스다 (e.g. “ROLE\_“). 디폴트는 빈 문자열이 아니므로 프리픽스를 사용하지 않으려면 “none”으로 지정해라.
- **server-ref** 사용할 서버. 생략할 수 있다. 생략하면 사용할 디폴트 LDAP 서버를 등록한다 (id 없이 \<ldap-server\> 사용).
- **user-context-mapper-ref** 사용자 디렉토리 엔트리에 있는 컨텍스트 정보와 함께 호출할 UserDetailsContextMapper 빈을 지정해서 로드한 사용자 객체를 명시적으로 커스텀할 수 있다.
- **user-details-class** 사용자 엔트리의 objectClass를 지정할 수 있다. 설정하면 프레임워크는 정의한 클래스의 표준 속성을 반환받은 UserDetails 객체로 로드한다.
- **user-search-base** 사용자를 검색하기 위한 search base. 디폴트는 ““다. 항상 ‘user-search-filter’와 함께 사용한다.
- **user-search-filter** 사용자를 검색할 때 사용할 LDAP 필터 (생략 가능). 예를 들어 `(uid={0})`. 파라미터는 로그인한 사용자 이름으로 대체된다.
