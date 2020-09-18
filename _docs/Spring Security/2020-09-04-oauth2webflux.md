---
title: OAuth2 WebFlux
category: Spring Security
order: 28
permalink: /Spring%20Security/oauth2webflux/
description: 웹플럭스 어플리케이션에서 스프링 시큐리티로 OAuth2를 적용하는 방법을 설명합니다. 공식 문서에 있는 "OAuth2 WebFlux" 챕터를 한글로 번역한 문서입니다.
image: ./../../images/springsecurity/spring-security.png
lastmod: 2020-09-04T20:00:00+09:00
comments: true
completed: false
originalRefName: 스프링 시큐리티
originalRefLink: https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#webflux-oauth2
---

### 목차:

- [25.1. OAuth 2.0 Login](#251-oauth-20-login)
  + [25.1.1. Spring Boot 2.0 Sample](#2511-spring-boot-20-sample)
    * [Initial setup](#initial-setup)
    * [Setting the redirect URI](#setting-the-redirect-uri)
    * [Configure application.yml](#configure-applicationyml)
    * [Boot up the application](#boot-up-the-application)
  + [25.1.2. Using OpenID Provider Configuration](#2512-using-openid-provider-configuration)
  + [25.1.3. Explicit OAuth2 Login Configuration](#2513-explicit-oauth2-login-configuration)
- [25.2. OAuth2 Client](#252-oauth2-client)
- [25.3. OAuth 2.0 Resource Server](#253-oauth-20-resource-server)
  + [25.3.1. Dependencies](#2531-dependencies)
  + [25.3.2. Minimal Configuration for JWTs](#2532-minimal-configuration-for-jwts)
    * [Specifying the Authorization Server](#specifying-the-authorization-server)
    * [Startup Expectations](#startup-expectations)
    * [Runtime Expectations](#runtime-expectations)
    * [Specifying the Authorization Server JWK Set Uri Directly](#specifying-the-authorization-server-jwk-set-uri-directly)
    * [Overriding or Replacing Boot Auto Configuration](#overriding-or-replacing-boot-auto-configuration)
  + [25.3.3. Configuring Trusted Algorithms](#2533-configuring-trusted-algorithms)
    * [Via Spring Boot](#via-spring-boot)
    * [Using a Builder](#using-a-builder)
    * [Trusting a Single Asymmetric Key](#trusting-a-single-asymmetric-key)
    * [Trusting a Single Symmetric Key](#trusting-a-single-symmetric-key)
    * [Configuring Authorization](#configuring-authorization)
    * [Configuring Validation](#configuring-validation)
    * [Minimal Configuration for Introspection](#minimal-configuration-for-introspection)
    * [Looking Up Attributes Post-Authentication](#looking-up-attributes-post-authentication)
    * [Overriding or Replacing Boot Auto Configuration](#overriding-or-replacing-boot-auto-configuration-1)
    * [Configuring Authorization](#configuring-authorization-1)
    * [Using Introspection with JWTs](#using-introspection-with-jwts)
    * [Calling a /userinfo Endpoint](#calling-a-userinfo-endpoint)
  + [25.3.4. Multi-tenancy](#2534-multi-tenancy)
    * [Resolving the Tenant By Claim](#resolving-the-tenant-by-claim)
  + [25.3.5. Bearer Token Propagation](#2535-bearer-token-propagation)

---

스프링 시큐리티는 리액티브 어플리케이션을 위한 OAuth2와 웹플럭스 통합을 지원한다.

---

## 25.1. OAuth 2.0 Login

OAuth 2.0 로그인 기능을 사용하면 어플리케이션의 사용자를 외부 OAuth 2.0 Provider나 (e.g. 깃허브) OpenID Connect 1.0 Provider (구글) 계정으로 로그인할 수 있다. “구글 계정으로 로그인”, “깃허브 계정으로 로그인”은 바로 이 OAuth 2.0 로그인을 구현한 것이다.

> OAuth 2.0 로그인은 [OAuth 2.0 인가 프레임워크](https://tools.ietf.org/html/rfc6749#section-4.1)와 [OpenID Connect Core 1.0](https://openid.net/specs/openid-connect-core-1_0.html#CodeFlowAuth)에 명시된 대로 **인가 코드 부여 (Authorization Code Grant)** 방식을 사용한다.

### 25.1.1. Spring Boot 2.0 Sample

스프링 부트 2.0은 OAuth 2.0 로그인을 완전히 자동화한다.

이번 섹션에선 *구글*을 *인증 provider*로 사용하는 [**OAuth 2.0 로그인 웹플럭스 샘플**](https://github.com/spring-projects/spring-security/tree/5.3.2.RELEASE/samples/boot/oauth2login-webflux) 설정을 구성하는 방법을 설명하며, 다음 주제를 다룬다:

- [초기 세팅](#initial-setup)
- [리다이렉트 URL 설정하기](#setting-the-redirect-uri)
- [`application.yml` 설정](#configure-applicationyml)
- [어플리케이션 기동하기](#boot-up-the-application)

#### Initial setup

구글의 OAuth 2.0 인증 시스템으로 로그인하려면 구글 API 콘솔에 프로젝트를 만들고 OAuth 2.0 credential을 받아야 한다.

> [구글의 OAuth 2.0 인증](https://developers.google.com/identity/protocols/OpenIDConnect)은 [OpenID Connect 1.0](https://openid.net/connect/) 스펙을 준수하며 [OpenID 인증을 받았다](https://openid.net/certification/).

[OpenID Connect](https://developers.google.com/identity/protocols/OpenIDConnect) 페이지에 있는 첫 번째 섹션 “Setting up OAuth 2.0” 가이드대로 따라해 봐라.

“Obtain OAuth 2.0 credentials” 섹션까지 마쳤다면, Client ID와 Client Secret으로 구성된 credential과 신규 OAuth 클라이언트가 생겼을 것이다.

#### Setting the redirect URI

리다이렉트 URL은, 구글로 인증을 마친 최종 사용자가 동의 페이지에서 Oauth 클라이언트에 *([전 단계에서 생성한](#initial-setup))* 접근 권한을 부여하면, 이 사용자의 user-agent가 다시 되돌아가야 할 어플리케이션 path를 의미한다.

“Set a redirect URI” 섹션에선 **승인된 리다이렉트 URL** 필드를 `http://localhost:8080/login/oauth2/code/google`로 설정해야 한다.

> 디폴트 리다이렉트 URL 템플릿은 `{baseUrl}/login/oauth2/code/{registrationId}`다. ***registrationId***는 [ClientRegistration](../oauth2/#clientregistration)을 식별하는 유니크한 값이다. 예를 들어 `registrationId`는 `google`이다.

> OAuth 클라이언트 앞단에 프록시 서버를 둔다면 어플리케이션 설정에 문제가 없도록 [프록시 서버 설정](../features#proxy-server-configuration)을 확인해보길 권한다. `redirect-uri`에 사용할 수 있는 [`URI` 템플릿 변수](../oauth2/#oauth2Client-auth-code-redirect-uri)도 참고하면 좋다.

#### Configure `application.yml`

이제 구글의 새 OAuth 클라이언트가 준비됐음으로, 어플리케이션의 *인증 플로우*에서 이 OAuth 클라이언트를 사용하도록 설정해줘야 한다. 이를 위해선:

- 1\. `application.yml`로 가서 다음 설정을 변경해라:

  ```yaml
  spring:
    security:
      oauth2:
        client:
          registration:   # (1)
            google:       # (2)
              client-id: google-client-id
              client-secret: google-client-secret
  ```

  **Example 194. OAuth Client properties**<br>
  <small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `spring.security.oauth2.client.registration`은 Oauth 클라이언트 프로퍼티의 기본 프리픽스다.</small><br>
  <small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 기본 프리픽스 뒤에는 구글 같은 [ClientRegistration](../oauth2#clientregistration) ID가 온다.</small>

- 2\. `client-id`, `client-secret` 프로퍼티를 앞에서 만든 OAuth 2.0 credential로 변경해라.

#### Boot up the application

스프링 부트 2.0 샘플을 기동한 뒤 `http://localhost:8080`에 접속해보자. 그러면 구글로 가는 링크가 있는, *자동 생성된* 디폴트 로그인 페이지로 이동할 거다.

링크를 클릭하면 구글로 이동해서 인증을 시작한다.

구글 계정 credential로 인증한 다음에 보이는 페이지는 동의 스크린이다. 이 페이지는 이전에 생성한 OAuth 클라이언트에 접근 권한을 줄건지 말건지를 묻는다. **Allow**를 클릭해서 OAuth 클라이언트가 이메일 주소와 기본적인 프로필 정보에 접근할 수 있게 해주자.

그러면 OAuth 클라이언트는 [UserInfo 엔드포인트](https://openid.net/specs/openid-connect-core-1_0.html#UserInfo)로부터 이메일 주소와 기본적인 프로필 정보를 가져오며, 인증된 세션을 시작한다.

### 25.1.2. Using OpenID Provider Configuration

스프링 시큐리티는 잘 알려진 일부 OAuth 인가 Provider 설정에 필요한 디폴트 값을 제공한다. [OpenID Provider 설정](https://openid.net/specs/openid-connect-discovery-1_0.html#ProviderConfig)이나 [인가 서버 메타데이터](https://tools.ietf.org/html/rfc8414#section-3)를 지원하는 자체 인가 Provider를 사용한다면, [OpenID Provider 설정 응답](https://openid.net/specs/openid-connect-discovery-1_0.html#ProviderConfigurationResponse)의 `issuer-uri`로 어플리케이션을 설정할 수 있다.

```yml
spring:
  security:
    oauth2:
      client:
        provider:
          keycloak:
            issuer-uri: https://idp.example.com/auth/realms/demo
        registration:
          keycloak:
            client-id: spring-security
            client-secret: 6cea952f-10d0-4d00-ac79-cc865820dc2c
```

`issuer-uri`를 사용하면 스프링 시큐리티는 엔드포인트 `https://idp.example.com/auth/realms/demo/.well-known/openid-configuration`, `https://idp.example.com/.well-known/openid-configuration/auth/realms/demo`, `https://idp.example.com/.well-known/oauth-authorization-server/auth/realms/demo`에 순서대로 질의해서 설정을 찾는다.

> 스프링 시큐리티는 각 엔드포인트를 하나씩 질의해서 처음 200 응답을 받으면 멈춘다.

`keycloak`은 provider와 registration 모두에서 사용하므로 `client-id`와 `client-secret`은 provider에 연결된다.

### 25.1.3. Explicit OAuth2 Login Configuration

다음은 최소한의 OAuth2 로그인 설정이다:

```java
@Bean
ReactiveClientRegistrationRepository clientRegistrations() {
    ClientRegistration clientRegistration = ClientRegistrations
            .fromIssuerLocation("https://idp.example.com/auth/realms/demo")
            .clientId("spring-security")
            .clientSecret("6cea952f-10d0-4d00-ac79-cc865820dc2c")
            .build();
    return new InMemoryReactiveClientRegistrationRepository(clientRegistration);
}

@Bean
SecurityWebFilterChain springSecurityFilterChain(ServerHttpSecurity http) {
    http
        // ...
        .oauth2Login(withDefaults());
    return http.build();
}
```

다른 설정 옵션은 아래에서 확인할 수 있다:

```java
@Bean
SecurityWebFilterChain springSecurityFilterChain(ServerHttpSecurity http) {
    http
        // ...
        .oauth2Login(oauth2 -> oauth2
            .authenticationConverter(converter)
            .authenticationManager(manager)
            .authorizedClientRepository(authorizedClients)
            .clientRegistrationRepository(clientRegistrations)
        );
    return http.build();
}
```

---

## 25.2. OAuth2 Client

스프링 시큐리티의 OAuth 기능을 사용하면 인증 없이 액세스 토큰을 가져올 수 있다. 스프링 부트의 기본 설정은 다음과 같다:

```yml
spring:
  security:
    oauth2:
      client:
        registration:
          github:
            client-id: replace-with-client-id
            client-secret: replace-with-client-secret
            scope: read:user,public_repo
```

`client-id`, `client-secret`은 깃허브에 등록한 값으로 변경해야 한다.

그 다음엔 액세스 토큰을 얻을 수 있도록 스프링 시큐리티를 OAuth2 클라이언트로 동작하게 만들어야 한다.

```java
@Bean
SecurityWebFilterChain configure(ServerHttpSecurity http) throws Exception {
    http
        // ...
        .oauth2Client(withDefaults());
    return http.build();
}
```

이제 스프링 시큐리티의 [WebClient](../webclient)나 [@RegisteredOAuth2AuthorizedClient](../@registeredoauth2authorizedclient)를 사용해서 액세스 토큰을 가져와서 사용할 수 있다.

---

## 25.3. OAuth 2.0 Resource Server

스프링 시큐리티는 OAuth 2.0 [Bearer 토큰](https://tools.ietf.org/html/rfc6750.html) 두 종류로 엔드포인트를 보호해 준다:

- [JWT](https://tools.ietf.org/html/rfc7519)
- Opaque 토큰

이 기능은 어플리케이션의 권한 관리를 별도 [인가 서버](https://tools.ietf.org/html/rfc6749)에 (ex. Okta, Ping Identity) 위임하는 경우에 사용할 수 있다. 리소스 서버는 요청을 인가할 때 이 인가 서버에 물어볼 수 있다.

> [스프링 시큐리티 레포지토리](https://github.com/spring-projects/spring-security/tree/5.3.2.RELEASE/samples)엔 [JWT](https://github.com/spring-projects/spring-security/tree/5.3.2.RELEASE/samples/boot/oauth2resourceserver-webflux)를 사용하는 실전 예제가 모두 있다.

### 25.3.1. Dependencies

리소스 서버를 지원하는 코드는 대부분 `spring-security-oauth2-resource-server`에 들어있다. 하지만 JWT를 디코딩하고 검증하는 로직은 `spring-security-oauth2-jose`에 있다. 따라서 리소스 서버가 사용할 Bearer 토큰을 JWT로 인코딩한다면 두 모듈이 모두 필요하다.

### 25.3.2. Minimal Configuration for JWTs

[스프링 부트](https://spring.io/projects/spring-boot)를 사용한다면 두 가지만으로 어플리케이션을 리소스 서버로 설정할 수 있다. 필요한 의존성을 추가하고, 인가 서버 위치를 알려주면 된다.

#### Specifying the Authorization Server

스프링 부트에서 사용할 인가 서버는 간단하게 지정할 수 있다:

```yml
spring:
  security:
    oauth2:
      resourceserver:
        jwt:
          issuer-uri: https://idp.example.com/issuer
```

여기서 `https://idp.example.com/issuer`는 인가 서버가 발급할 JWT 토큰의 `iss` 클레임에 추가되는 값이다. 리소스 서버는 자체 설정에도 이 속성을 사용하며, 이 속성으로 인가 서버의 공개키를 찾고, 건내 받은 JWT의 유효성을 검사한다.

> `issuer-uri` 프로퍼티를 사용하려면 인가 서버가 지원하는 엔드포인트는 반드시 `https://idp.example.com/issuer/.well-known/openid-configuration`, `https://idp.example.com/.well-known/openid-configuration/issuer`, `https://idp.example.com/.well-known/oauth-authorization-server/issuer` 셋 중 하나여야 한다. 이 엔드포인트는 [Provider 설정](https://openid.net/specs/openid-connect-discovery-1_0.html#ProviderConfig) 엔드포인트 또는 [인가 서버 메타데이터](https://tools.ietf.org/html/rfc8414#section-3) 엔드포인트라고 한다.

이게 전부다!

#### Startup Expectations

이 프로퍼티와 의존성을 사용하면 JWT로 인코딩한 Bearer 토큰을 검증하는 리소스 서버가 자동으로 설정된다.

결정적으로 기동 시점에 아래와 같은 처리를 하기 때문이다:

1. Provider 설정 엔드포인트 또는 인가 서버 메타데이터 엔드포인트를 찔러서 응답으로 `jwks_url` 프로퍼티를 처리한다.
2. `jwks_url`에 유효한 공개키를 질의하기 위한 검증 전략을 설정한다.
3. `https://idp.example.com`에 대한 각 JWT `iss` 클레임을 검증할 전략을 설정한다.

이 프로세스대로 리소스 서버를 기동하려면 반드시 인가 서버가 기동돼서 요청을 받을 수 있는 상태여야 한다.

> 리소스 서버가 질의할 때 인가 서버가 다운돼 있으면 (적절한 타임아웃이 있으면) 기동에 실패한다.

#### Runtime Expectations

어플리케이션이 기동되고 나면, 리소스 서버는 `Authorization: Bearer` 헤더를 포함한 모든 요청을 처리한다:

```http
GET / HTTP/1.1
Authorization: Bearer some-token-value # Resource Server will process this
```

이 스킴만 명시하면 리소스 서버는 Bearer 토큰 스펙에 따라 요청을 처리한다.

JWT 형식에 이상이 없으면 리소스 서버는:

1. 기동 시 `jwks_url` 엔드포인트에서 가져와 JWT 헤더로 매칭한 공개키로 서명을 검증한다.
2. JWT에 있는 `exp`, `nbf` 타임스탬프, `iss` 클레임을 검증하고,
3. 각 scope를 `SCOPE_` 프리픽스를 달아 권한에 매핑한다.

> 인가 서버가 새로운 키를 만들면 스프링 시큐리티는 자동으로 JWT 토큰 검증에 사용할 키를 교체한다.

기본적으로 `Authentication#getPrincipal` 결과는 스프링 시큐리티의 `Jwt` 객체이며, `Authentication#getName`은 JWT의 `sub` 프로퍼티 값이 있으면 이 값을 사용한다.

여기서부턴 바로 다음 챕터로 넘어가도 좋다:

[인가 서버 가용성과는 상관없이 리소스 서버를 기동하게 만드는 설정](#specifying-the-authorization-server-jwk-set-uri-directly)

[스프링 부트 없이 설정하기](#overriding-or-replacing-boot-auto-configuration)

#### Specifying the Authorization Server JWK Set Uri Directly

인가 서버가 설정 엔드포인트를 전부 지원하지 않거나, 인가 서버와는 독립적으로 리소스 서버를 실행해야 하는 상황이라면, 다음과 같이 `jwk-set-uri` 프로퍼티를 설정해라:

```yaml
spring:
  security:
    oauth2:
      resourceserver:
        jwt:
          issuer-uri: https://idp.example.com
          jwk-set-uri: https://idp.example.com/.well-known/jwks.json
```

> JWK Set uri는 표준은 아니지만, 보통 인가 서버 문서에 나와있긴 하다.

이렇게 하면 리소스 서버를 기동할 때 인가 서버를 찔러보지 않는다. 인가 서버가 전달받은 JWT에 있는 `iss` 클레임을 검증할 수 있도록 `issuer-uri`는 남겨놨다.

> [DSL](#using-jwkseturi)로 직접 프로퍼티를 설정하는 방법도 있다.

#### Overriding or Replacing Boot Auto Configuration

스프링 부트가 리소스 서버에 생성하는 `@Bean`은 두 가지가 있다.

하나는 어플리케이션을 리소스 서버로 설정해주는 `SecurityWebFilterChain`이다. `spring-security-oauth2-jose` 모듈이 있다면 `WebSecurityConfigurerAdapter`는 다음과 같이 설정된다:

```java
@Bean
SecurityWebFilterChain springSecurityFilterChain(ServerHttpSecurity http) {
    http
        .authorizeExchange(exchanges -> exchanges
            .anyExchange().authenticated()
        )
        .oauth2ResourceServer(OAuth2ResourceServerSpec::jwt)
    return http.build();
}
```

어플리케이션에서 따로 정의한 `SecurityWebFilterChain` 빈이 없다면 스프링 부트가 위에 있는 디폴트 빈을 등록한다.

빈을 바꾸려면 어플리케이션에 빈을 정의하기만 하면 되다:

```java
@Bean
SecurityWebFilterChain springSecurityFilterChain(ServerHttpSecurity http) {
    http
        .authorizeExchange(exchanges -> exchanges
            .pathMatchers("/message/**").hasAuthority("SCOPE_message:read")
            .anyExchange().authenticated()
        )
        .oauth2ResourceServer(oauth2 -> oauth2
            .jwt(withDefaults())
        );
    return http.build();
}
```

위 설정에선 `/messages/`로 시작하는 모든 URL은 `message:read` scope가 있어야 접근할 수 있다.

`oauth2ResourceServer` DSL 메소드로도 자동 설정을 재정의하거나 아예 바꿔버릴 수 있다.

예를 들어 스프링 부트가 생성하는 두 번째 `@Bean`은 `ReactiveJwtDecoder`인데, 이 빈은 `String` 토큰을 검증된 `Jwt` 인스턴스로 디코딩한다:

```java
@Bean
public ReactiveJwtDecoder jwtDecoder() {
    return ReactiveJwtDecoders.fromIssuerLocation(issuerUri);
}
```

> `ReactiveJwtDecoders#fromIssuerLocation`을 호출하면 Provider 설정 또는 인가 서버 메타데이터 엔드포인트로 JWK 셋 Uri를 요청한다. 어플리케이션에서 따로 정의한 `ReactiveJwtDecoder` 빈이 없다면 스프링 부트가 위에 있는 디폴트 빈을 등록한다.

이 설정은 `jwkSetUri()`로 재정의하거나 `decoder()`로 바꿀 수 있다.

##### Using `jwkSetUri()`

인가 서버의 JWK 셋 Uri는 [설정 프로퍼티](#specifying-the-authorization-server-jwk-set-uri-directly)나 DSL로 지정할 수 있다.

```java
@Bean
SecurityWebFilterChain springSecurityFilterChain(ServerHttpSecurity http) {
    http
        .authorizeExchange(exchanges -> exchanges
            .anyExchange().authenticated()
        )
        .oauth2ResourceServer(oauth2 -> oauth2
            .jwt(jwt -> jwt
                .jwkSetUri("https://idp.example.com/.well-known/jwks.json")
            )
        );
    return http.build();
}
```

`jwkSetUri()`가 설정 프로퍼티보다 우선시된다.

##### Using `decoder()`

`jwkSetUri()` 대신 `decoder()`를 사용하면 부트의 `JwtDecoder` 자동 설정을 완전히 바꿔버릴 수 있다:

```java
@Bean
SecurityWebFilterChain springSecurityFilterChain(ServerHttpSecurity http) {
    http
        .authorizeExchange(exchanges -> exchanges
            .anyExchange().authenticated()
        )
        .oauth2ResourceServer(oauth2 -> oauth2
            .jwt(jwt -> jwt
                .decoder(myCustomDecoder())
            )
        );
    return http.build();
}
```

이 방식을 사용하면 [검증](#configuring-validation)같이 좀 더 세세한 설정을 쉽게 바꿀 수 있다.

##### Exposing a `ReactiveJwtDecoder` `@Bean`

`ReactiveJwtDecoder` `@Bean`을 정의하는 것도 `decoder()`와 동일한 효과가 있다:

```java
@Bean
public ReactiveJwtDecoder jwtDecoder() {
    return NimbusReactiveJwtDecoder.withJwkSetUri(jwkSetUri).build();
}
```

### 25.3.3. Configuring Trusted Algorithms

디폴트로 `NimbusReactiveJwtDecoder`를 사용하기 때문에 리소스 서버는 `RS256`을 사용한 토큰만 신뢰하고 이 토큰만 검증할 수 있다.

알고리즘은 [스프링 부트](#via-spring-boot)나 [NimbusJwtDecoder 빌더](#using-a-builder)로 커스텀할 수 있다.

#### Via Spring Boot

알고리즘을 변경하는 가장 쉬운 방법은 스프링 부트 프로퍼티 설정이다:

```yaml
spring:
  security:
    oauth2:
      resourceserver:
        jwt:
          jws-algorithm: RS512
          jwk-set-uri: https://idp.example.org/.well-known/jwks.json
```

#### Using a Builder

하지만 `NimbusReactiveJwtDecoder` 빌더를 사용하면 다른 것도 가능하다:

```java
@Bean
ReactiveJwtDecoder jwtDecoder() {
    return NimbusReactiveJwtDecoder.fromJwkSetUri(this.jwkSetUri)
            .jwsAlgorithm(RS512).build();
}
```

`jwsAlgorithm`을 여러 번 호출하면 `NimbusReactiveJwtDecoder`는 이 알고리즘을 전부 신뢰할 수 있는 알고리즘으로 판단한다:

```java
@Bean
ReactiveJwtDecoder jwtDecoder() {
    return NimbusReactiveJwtDecoder.fromJwkSetUri(this.jwkSetUri)
            .jwsAlgorithm(RS512).jwsAlgorithm(EC512).build();
}
```

아니면 `jwsAlgorithms` 메소드를 사용해도 된다:

```java
@Bean
ReactiveJwtDecoder jwtDecoder() {
    return NimbusReactiveJwtDecoder.fromJwkSetUri(this.jwkSetUri)
            .jwsAlgorithms(algorithms -> {
                    algorithms.add(RS512);
                    algorithms.add(EC512);
            }).build();
}
```

#### Trusting a Single Asymmetric Key

리소스 서버에 JWK 셋 엔드포인트를 설정하는 것 보다 RSA 공개키를 하드코딩하는 게 더 간단한다. 공개키는 [스프링 부트](#via-spring-boot-1)나 [빌더](#using-a-builder-1)로 설정할 수 있다.

##### Via Spring Boot

스프링 부트에 키를 명시하는 건 꽤 간단하다. 다음과 같이 키 위치를 지정할 수 있다:

```yaml
spring:
  security:
    oauth2:
      resourceserver:
        jwt:
          public-key-location: classpath:my-key.pub
```

좀 더 정교한 방법으로 공개키를 찾아야 한다면, `RsaKeyConversionServicePostProcessor`에 후처리를 추가하면 된다:

```java
@Bean
BeanFactoryPostProcessor conversionServiceCustomizer() {
    return beanFactory ->
        beanFactory.getBean(RsaKeyConversionServicePostProcessor.class)
                .setResourceLoader(new CustomResourceLoader());
}
```

키가 있는 곳을 명시해라:

```yaml
key.location: hfds://my-key.pub
```

그 다음 그 값을 주입해라:

```java
@Value("${key.location}")
RSAPublicKey key;
```

##### Using a Builder

간단하게 다음과 같이 `NimbusReactiveJwtDecoder` 빌더로 직접 `RSAPublicKey`를 주입할 수도 있다:

```java
@Bean
public ReactiveJwtDecoder jwtDecoder() {
    return NimbusReactiveJwtDecoder.withPublicKey(this.key).build();
}
```

#### Trusting a Single Symmetric Key

대칭키 사용도 간단하다. 단순히 `SecretKey`를 로드해서 `NimbusReactiveJwtDecoder` 빌더에 넣어주면 된다:

```java
@Bean
public ReactiveJwtDecoder jwtDecoder() {
    return NimbusReactiveJwtDecoder.withSecretKey(this.key).build();
}
```

#### Configuring Authorization

OAuth 2.0 인가 서버가 발급한 JWT에는 보통 부여한 scope(권한)를 나타내는 `scope`나 `scp` 속성이 있다. 예를 들어:

```json
{ …, "scope" : "messages contacts"}
```

이런 경우 리소스 서버는 각 스코프에 “SCOPE_” 프리픽스를 달아 승인된 권한 리스트를 만든다.

즉, JWT의 scope로 특정 엔드포인트나 메소드를 보호하려면, 프리픽스를 포함한 적절한 표현식을 사용해야 한다:

```java
@Bean
SecurityWebFilterChain springSecurityFilterChain(ServerHttpSecurity http) {
    http
        .authorizeExchange(exchanges -> exchanges
            .mvcMatchers("/contacts/**").hasAuthority("SCOPE_contacts")
            .mvcMatchers("/messages/**").hasAuthority("SCOPE_messages")
            .anyExchange().authenticated()
        )
        .oauth2ResourceServer(OAuth2ResourceServerSpec::jwt);
    return http.build();
}
```

메소드 시큐리티도 비슷하다:

```java
@PreAuthorize("hasAuthority('SCOPE_messages')")
public Flux<Message> getMessages(...) {}
```

##### Extracting Authorities Manually

하지만 이 디폴트 동작으로 해결되지 않는 상황도 많다. 예를 들어 일부 인증 서버는 `scope` 속성 대신 자체 커스텀 속성을 사용한다. 또는 리소스 서버에서 속성 또는 속성 조합을 내부 권한에 맞게 조정해야 할 수도 있다.

DSL엔 이럴 때 사용할 수 있는 `jwtAuthenticationConverter()` 메소드가 있다:

```java
@Bean
SecurityWebFilterChain springSecurityFilterChain(ServerHttpSecurity http) {
    http
        .authorizeExchange(exchanges -> exchanges
            .anyExchange().authenticated()
        )
        .oauth2ResourceServer(oauth2 -> oauth2
            .jwt(jwt -> jwt
                .jwtAuthenticationConverter(grantedAuthoritiesExtractor())
            )
        );
    return http.build();
}

Converter<Jwt, Mono<AbstractAuthenticationToken>> grantedAuthoritiesExtractor() {
    JwtAuthenticationConverter jwtAuthenticationConverter =
            new JwtAuthenticationConverter();
    jwtAuthenticationConverter.setJwtGrantedAuthoritiesConverter
            (new GrantedAuthoritiesExtractor());
    return new ReactiveJwtAuthenticationConverterAdapter(jwtAuthenticationConverter);
}
```

이 메소드로는 `Jwt`를 `Authentication`으로 변환하는 컨버터를 설정한다. 먼저, `Jwt`를 승인된 권한 `Collection`으로 변환하는 하위 컨버터를 설정할 수 있다. 

최종 컨버터는 아래 `GrantedAuthoritiesExtractor`같은 형태로 사용한다:

```java
static class GrantedAuthoritiesExtractor
        implements Converter<Jwt, Collection<GrantedAuthority>> {

    public Collection<GrantedAuthority> convert(Jwt jwt) {
        Collection<?> authorities = (Collection<?>)
                jwt.getClaims().getOrDefault("mycustomclaim", Collections.emptyList());

        return authorities.stream()
                .map(Object::toString)
                .map(SimpleGrantedAuthority::new)
                .collect(Collectors.toList());
    }
}
```

좀 더 유연하게는, DSL로 기존 컨버터를 `Converter<Jwt, Mono<AbstractAuthenticationToken>>`을 구현하는 다른 클래스로 바꿀 수 있다:

```java
static class CustomAuthenticationConverter implements Converter<Jwt, Mono<AbstractAuthenticationToken>> {
    public AbstractAuthenticationToken convert(Jwt jwt) {
        return Mono.just(jwt).map(this::doConversion);
    }
}
```

#### Configuring Validation

[스프링 부트 최소 설정](#2532-minimal-configuration-for-jwts)으로 인가 서버의 issuer uri를 지정하면, 리소스 서버는 기본적으로 `iss` 클레임과 `exp`, `nbf` 타임스템프 클레임을 검증한다.

리소스 서버가 사용하는 표준 validator는 두 가지가 있는데, 커스텀 `OAuth2TokenValidator` 인스턴스도 허용하므로 검증 로직을 커스텀할 수 있다.

##### Customizing Timestamp Validation

JWT는 보통 `nbf` 클레임으로 시작하고 `exp` 클레임으로 끝나는 유효 기간(validity window)이 있다.

하지만 모든 서버는 [클럭 드리프트](https://ko.wikipedia.org/wiki/클럭_드리프트)가 발생할 수 있으므로, 서버 하나에선 토큰이 만료되지만 다른 서버에선 아닐 수도 있다. 따라서 분산 시스템에 있는 서버가 많아지면 문제가 될 수 있다.

리소스 서버는 `JwtTimestampValidator`로 토큰의 유효 기간을 검증하며, `clockSkew`를 설정하면 이 문제를 어느정도 해결할 수 있다:

```java
@Bean
ReactiveJwtDecoder jwtDecoder() {
     NimbusReactiveJwtDecoder jwtDecoder = (NimbusReactiveJwtDecoder)
             ReactiveJwtDecoders.fromIssuerLocation(issuerUri);

     OAuth2TokenValidator<Jwt> withClockSkew = new DelegatingOAuth2TokenValidator<>(
            new JwtTimestampValidator(Duration.ofSeconds(60)),
            new IssuerValidator(issuerUri));

     jwtDecoder.setJwtValidator(withClockSkew);

     return jwtDecoder;
}
```

> 리소스 서버는 디폴트로 `clockSkew`를 30초로 설정한다 (30초 이상 차이나야 만료된 것으로 판단한다).

##### Configuring a Custom Validator

`aud` 클레임 체크는 `OAuth2TokenValidator` API로 간단하게 추가할 수 있다:

```java
public class AudienceValidator implements OAuth2TokenValidator<Jwt> {
    OAuth2Error error = new OAuth2Error("invalid_token", "The required audience is missing", null);

    public OAuth2TokenValidatorResult validate(Jwt jwt) {
        if (jwt.getAudience().contains("messaging")) {
            return OAuth2TokenValidatorResult.success();
        } else {
            return OAuth2TokenValidatorResult.failure(error);
        }
    }
}
```

그러고 커스텀 구현체를 리소스 서버에 추가하려면 `ReactiveJwtDecoder` 인스턴스에 명시하기만 하면 된다:

```java
@Bean
ReactiveJwtDecoder jwtDecoder() {
    NimbusReactiveJwtDecoder jwtDecoder = (NimbusReactiveJwtDecoder)
            ReactiveJwtDecoders.fromIssuerLocation(issuerUri);

    OAuth2TokenValidator<Jwt> audienceValidator = new AudienceValidator();
    OAuth2TokenValidator<Jwt> withIssuer = JwtValidators.createDefaultWithIssuer(issuerUri);
    OAuth2TokenValidator<Jwt> withAudience = new DelegatingOAuth2TokenValidator<>(withIssuer, audienceValidator);

    jwtDecoder.setJwtValidator(withAudience);

    return jwtDecoder;
}
```

#### Minimal Configuration for Introspection

opaque 토큰은 보통 인가 서버에서 호스트하는 [OAuth 2.0 Introspection 엔드포인트](https://tools.ietf.org/html/rfc7662)로 검증한다. 이 엔드포인트는 토큰을 취소해야 할 때 유용하다.

[스프링 부트](https://spring.io/projects/spring-boot)를 사용하면 두 가지만으로 어플리케이션을 introspection을 사용하는 인가 서버가로 만들 수 있다. 먼저 필요한 의존성을 추가하고, 그 다음 introspection 엔드포인트 상세 정보를 설정한다.

##### Specifying the Authorization Server

introspection 엔드포인트 위치는 간단하게 다음과 같이 등록한다:

```yaml
security:
  oauth2:
    resourceserver:
      opaque-token:
        introspection-uri: https://idp.example.com/introspect
        client-id: client
        client-secret: secret
```

`https://idp.example.com/introspect`는 인가 서버가 호스트하는 introspection 엔드포인트이며, `client-id`와 `client-secret`은 엔드포인트 요청에 사용할 credential이다.

리소스 서버는 이 프로퍼티로 자체 설정을 만들어 이후 전달받은 JWT를 검증할 때 사용한다

> introspection을 사용한다면, 인가 서버의 말이 곧 법이다. 인가 서버가 토큰이 유효하다고 응답한다면 유효한 것이다.

이게 전부다!

##### Startup Expectations

이 프로퍼티와 의존성을 사용하면 Opaque Bearer 토큰을 검증하는 리소스 서버가 자동으로 설정된다.

기동 프로세스는 엔드포인트를 찾거나 검증 룰을 추가하는 작업이 없기 때문에 JWT보다 훨씬 간단하다.

##### Runtime Expectations

어플리케이션이 기동되고 나면, 리소스 서버는 `Authorization: Bearer` 헤더를 포함한 모든 요청을 처리한다:

```http
GET / HTTP/1.1
Authorization: Bearer some-token-value # Resource Server will process this
```

이 스킴만 명시하면 리소스 서버는 Bearer 토큰 스펙에 따라 요청을 처리한다.

Opaque 토큰이 있으면 리소스 서버는:

1. credential과 토큰으로 설정에 있는 introspection 엔드포인트에 질의한다.
2. 응답에서 `{ 'active' : true }` 속성을 찾는다.
3. 각 scope를 `SCOPE_` 프리픽스를 달아 권한에 매핑한다.

기본적으로 `Authentication#getPrincipal` 결과는 스프링 시큐리티의 `OAuth2AuthenticatedPrincipal` 객체이며, `Authentication#getName`은 토큰의 `sub` 프로퍼티 값이 있으면 이 값을 사용한다.

여기서부턴 바로 다음 챕터로 넘어가도 좋다:

- [인증 후 속성 검색하기](#looking-up-attributes-post-authentication)
- [수동으로 권한 추출하기](#extracting-authorities-manually-1)
- [JWT로 Introspection 사용하기](#using-introspection-with-jwts)

#### Looking Up Attributes Post-Authentication

토큰을 인증하고 나면 `SecurityContext`에 `BearerTokenAuthentication`이 세팅된다.

즉, 설정에 `@EnableWebFlux`를 추가한 `@Controller` 메소드에서 이 값을 사용할 수 있다:

```java
@GetMapping("/foo")
public Mono<String> foo(BearerTokenAuthentication authentication) {
    return Mono.just(authentication.getTokenAttributes().get("sub") + " is the subject");
}
```

`BearerTokenAuthentication`엔 `OAuth2AuthenticatedPrincipal`이 있기 때문에 이 값도 컨트롤러 메소드에서 사용할 수 있다:

```java
@GetMapping("/foo")
public Mono<String> foo(@AuthenticationPrincipal OAuth2AuthenticatedPrincipal principal) {
    return Mono.just(principal.getAttribute("sub") + " is the subject");
}
```

##### Looking Up Attributes Via SpEL

당연히 SpEL로도 속성에 접근할 수 있다.

예를 들어 `@EnableReactiveMethodSecurity`를 사용한다면 아래처럼 `@PreAuthorize` 애노테이션을 사용할 수 있다:

```java
@PreAuthorize("principal?.attributes['sub'] == 'foo'")
public Mono<String> forFoosEyesOnly() {
    return Mono.just("foo");
}
```

#### Overriding or Replacing Boot Auto Configuration

스프링 부트가 리소스 서버에 생성하는 `@Bean`은 두 가지가 있다.

하나는 어플리케이션을 리소스 서버로 설정해주는 `SecurityWebFilterChain`이다. Opaque 토큰을 사용한다면 `SecurityWebFilterChain`은 다음과 같이 설정된다:

```java
@Bean
SecurityWebFilterChain springSecurityFilterChain(ServerHttpSecurity http) {
    http
        .authorizeExchange(exchanges -> exchanges
            .anyExchange().authenticated()
        )
        .oauth2ResourceServer(ServerHttpSecurity.OAuth2ResourceServerSpec::opaqueToken)
    return http.build();
}
```

어플리케이션에서 따로 정의한 `SecurityWebFilterChain` 빈이 없다면 스프링 부트가 위에 있는 디폴트 빈을 등록한다.

빈을 바꾸려면 어플리케이션에 빈을 정의하기만 하면 되다:

```java
@EnableWebFluxSecurity
public class MyCustomSecurityConfiguration {
    @Bean
    SecurityWebFilterChain springSecurityFilterChain(ServerHttpSecurity http) {
        http
            .authorizeExchange(exchanges -> exchanges
                .pathMatchers("/messages/**").hasAuthority("SCOPE_message:read")
                .anyExchange().authenticated()
            )
            .oauth2ResourceServer(oauth2 -> oauth2
                .opaqueToken(opaqueToken -> opaqueToken
                    .introspector(myIntrospector())
                )
            );
        return http.build();
    }
}
```

위 설정에선 `/messages/`로 시작하는 모든 URL은 `message:read` scope가 있어야 접근할 수 있다.

`oauth2ResourceServer` DSL 메소드로도 자동 설정을 재정의하거나 아예 바꿔버릴 수 있다.

예를 들어 스프링 부트가 생성하는 두 번째 `@Bean`은 `ReactiveOpaqueTokenIntrospector`인데, 이 빈은 `String` 토큰을 검증된 `OAuth2AuthenticatedPrincipal` 인스턴스로 디코딩한다:

```java
@Bean
public ReactiveOpaqueTokenIntrospector introspector() {
    return new NimbusReactiveOpaqueTokenIntrospector(introspectionUri, clientId, clientSecret);
}
```

어플리케이션에서 따로 정의한 `ReactiveOpaqueTokenIntrospector` 빈이 없다면 스프링 부트가 위에 있는 디폴트 빈을 등록한다.

이 설정은 `introspectionUri()`와 `introspectionClientCredentials()`로 재정의하거나 `introspector()`로 바꿀 수 있다.

##### Using `introspectionUri()`

인가 서버의 Introspection Uri는 [설정 프로퍼티](#specifying-the-authorization-server-1)나 DSL로 지정할 수 있다:

```java
@EnableWebFluxSecurity
public class DirectlyConfiguredIntrospectionUri {
    @Bean
    SecurityWebFilterChain springSecurityFilterChain(ServerHttpSecurity http) {
        http
            .authorizeExchange(exchanges -> exchanges
                .anyExchange().authenticated()
            )
            .oauth2ResourceServer(oauth2 -> oauth2
                .opaqueToken(opaqueToken -> opaqueToken
                    .introspectionUri("https://idp.example.com/introspect")
                    .introspectionClientCredentials("client", "secret")
                )
            );
        return http.build();
    }
}
```

`introspectionUri()`가 설정 프로퍼티보다 우선시된다.

##### Using `introspector()`

`introspectionUri()` 대신 `introspector()`를 사용하면 부트의 `ReactiveOpaqueTokenIntrospector` 자동 설정을 완전히 바꿔버릴 수 있다:

```java
@EnableWebFluxSecurity
public class DirectlyConfiguredIntrospector {
    @Bean
    SecurityWebFilterChain springSecurityFilterChain(ServerHttpSecurity http) {
        http
            .authorizeExchange(exchanges -> exchanges
                .anyExchange().authenticated()
            )
            .oauth2ResourceServer(oauth2 -> oauth2
                .opaqueToken(opaqueToken -> opaqueToken
                    .introspector(myCustomIntrospector())
                )
            );
        return http.build();
    }
}
```

이 방식을 사용하면 [권한 매핑](#extracting-authorities-manually-1), [JWT 취소](#using-introspection-with-jwts) 등 좀 더 세세한 설정을 쉽게 바꿀 수 있다.

##### Exposing a `ReactiveOpaqueTokenIntrospector` `@Bean`

`ReactiveOpaqueTokenIntrospector` `@Bean`을 정의하는 것도 `introspector()`와 동일한 효과가 있다:

```java
@Bean
public ReactiveOpaqueTokenIntrospector introspector() {
    return new NimbusOpaqueTokenIntrospector(introspectionUri, clientId, clientSecret);
}
```

#### Configuring Authorization

OAuth 2.0 Introspection 엔드포인트는 보통 부여한 scope(권한)를 나타내는 `scope` 속성을 반환한다. 예를 들어:

```json
{ …, "scope" : "messages contacts"}
```

이런 경우 리소스 서버는 각 스코프에 “SCOPE_” 프리픽스를 달아 승인된 권한 리스트를 만든다.

즉, Opaque 토큰의 scope로 특정 엔드포인트나 메소드를 보호하려면, 프리픽스를 포함한 적절한 표현식을 사용해야 한다:

```java
@EnableWebFluxSecurity
public class MappedAuthorities {
    @Bean
    SecurityWebFilterChain springSecurityFilterChain(ServerHttpSecurity http) {
        http
            .authorizeExchange(exchange -> exchange
                .pathMatchers("/contacts/**").hasAuthority("SCOPE_contacts")
                .pathMatchers("/messages/**").hasAuthority("SCOPE_messages")
                .anyExchange().authenticated()
            )
            .oauth2ResourceServer(ServerHttpSecurity.OAuth2ResourceServerSpec::opaqueToken);
        return http.build();
    }
}
```

메소드 시큐리티도 비슷하다:

```java
@PreAuthorize("hasAuthority('SCOPE_messages')")
public Flux<Message> getMessages(...) {}
```

##### Extracting Authorities Manually

기본적으로 Opaque 토큰을 지원할 땐 introspection 응답에서 각 scope 클레임을 추출해서 `GrantedAuthority` 인스턴스로 파싱한다.

예를 들어 introspection 응답이 다음과 같다면:

```json
{
    "active" : true,
    "scope" : "message:read message:write"
}
```

리소스 서버는 `message:read`, `message:write` 두 가지 권한을 가진 `Authentication`을 생성한다.

물론 `ReactiveOpaqueTokenIntrospector`를 커스텀하면 속성 셋 중 원하는 값을 변환할 수 있다:

```java
public class CustomAuthoritiesOpaqueTokenIntrospector implements ReactiveOpaqueTokenIntrospector {
    private ReactiveOpaqueTokenIntrospector delegate =
            new NimbusReactiveOpaqueTokenIntrospector("https://idp.example.org/introspect", "client", "secret");

    public Mono<OAuth2AuthenticatedPrincipal> introspect(String token) {
        return this.delegate.introspect(token)
                .map(principal -> new DefaultOAuth2AuthenticatedPrincipal(
                        principal.getName(), principal.getAttributes(), extractAuthorities(principal)));
    }

    private Collection<GrantedAuthority> extractAuthorities(OAuth2AuthenticatedPrincipal principal) {
        List<String> scopes = principal.getAttribute(OAuth2IntrospectionClaimNames.SCOPE);
        return scopes.stream()
                .map(SimpleGrantedAuthority::new)
                .collect(Collectors.toList());
    }
}
```

그 다음 간단히 커스텀 구현체를 `@Bean`으로 정의하면 된다:

```java
@Bean
public ReactiveOpaqueTokenIntrospector introspector() {
    return new CustomAuthoritiesOpaqueTokenIntrospector();
}
```

#### Using Introspection with JWTs

흔히들 introspection을 JWT와 사용할 수 있는지 묻곤 한다. 스프링 시큐리티의 Opaque 토큰 기능은 토큰 형식과는 상관없이 설계했다. 즉 설정에 있는 introspection 엔드포인트엔 어떤 토큰이든 전달할 수 있다.

JWT가 취소되면 모든 요청을 인가 서버로 검증해야 하는 요구사항이 있다고 가정해보자.

토큰은 JWT 형식이더라도 검증 방법은 introspection이기 때문에 다음 설정이 필요하다:

```yaml
spring:
  security:
    oauth2:
      resourceserver:
        opaque-token:
          introspection-uri: https://idp.example.org/introspection
          client-id: client
          client-secret: secret
```

이 경우 `Authentication`은 `BearerTokenAuthentication`이 될 것이다. 이에 해당하는 `OAuth2AuthenticatedPrincipal`에 있는 모든 속성은 introspection 엔드포인트가 반환한 값이다.

이번에는 이상하긴 하지만, introspection 엔드포인트가 토큰이 활성 상태인지 아닌지만 반환한다고 가정해보자. 이제 어떡할까?

이럴 때는 엔드포인트에 요청하긴 하지만 반환할 principal 속성을 JWT 클레임으로 업데이트하는 커스텀 `ReactiveOpaqueTokenIntrospector`를 만들 수 있다:

```java
public class JwtOpaqueTokenIntrospector implements ReactiveOpaqueTokenIntrospector {
    private ReactiveOpaqueTokenIntrospector delegate =
            new NimbusReactiveOpaqueTokenIntrospector("https://idp.example.org/introspect", "client", "secret");
    private ReactiveJwtDecoder jwtDecoder = new NimbusReactiveJwtDecoder(new ParseOnlyJWTProcessor());

    public Mono<OAuth2AuthenticatedPrincipal> introspect(String token) {
        return this.delegate.introspect(token)
                .flatMap(principal -> this.jwtDecoder.decode(token))
                .map(jwt -> new DefaultOAuth2AuthenticatedPrincipal(jwt.getClaims(), NO_AUTHORITIES));
    }

    private static class ParseOnlyJWTProcessor implements Converter<JWT, Mono<JWTClaimsSet>> {
        public Mono<JWTClaimsSet> convert(JWT jwt) {
            try {
                return Mono.just(jwt.getJWTClaimsSet());
            } catch (Exception e) {
                return Mono.error(e);
            }
        }
    }
}
```

그 다음 간단히 커스텀 구현체를 `@Bean`으로 정의하면 된다:

```java
@Bean
public ReactiveOpaqueTokenIntrospector introspector() {
    return new JwtOpaqueTokenIntropsector();
}
```

#### Calling a `/userinfo` Endpoint

일반적으로 리소스 서버는 사용자가 아닌 부여한 권한에만 신경 쓴다.

그렇긴 해도 어쩔땐 인가한 권한을 다시 사용자와 연결하는 게 유용할 때도 있다.

`spring-security-oauth2-client` 모듈을 사용 중이고, 어플리케이션에 적당한 `ClientRegistrationRepository`도 설정돼 있다면, 쉽게 커스텀 `OpaqueTokenIntrospector`를 만들 수 있다. 이 구현체는 다음 세 가지 일을 한다:

- introspection 엔드포인트에 토큰의 유효성 검증을 위임한다
- `/userinfo` 엔드포인트와 관련있는 적절한 클라이언트 등록 정보를 검색한다
- `/userinfo` 엔드포인트를 실행해서 결과를 반환한다

```java
public class UserInfoOpaqueTokenIntrospector implements ReactiveOpaqueTokenIntrospector {
    private final ReactiveOpaqueTokenIntrospector delegate =
            new NimbusReactiveOpaqueTokenIntrospector("https://idp.example.org/introspect", "client", "secret");
    private final ReactiveOAuth2UserService<OAuth2UserRequest, OAuth2User> oauth2UserService =
            new DefaultReactiveOAuth2UserService();

    private final ReactiveClientRegistrationRepository repository;

    // ... constructor

    @Override
    public Mono<OAuth2AuthenticatedPrincipal> introspect(String token) {
        return Mono.zip(this.delegate.introspect(token), this.repository.findByRegistrationId("registration-id"))
                .map(t -> {
                    OAuth2AuthenticatedPrincipal authorized = t.getT1();
                    ClientRegistration clientRegistration = t.getT2();
                    Instant issuedAt = authorized.getAttribute(ISSUED_AT);
                    Instant expiresAt = authorized.getAttribute(OAuth2IntrospectionClaimNames.EXPIRES_AT);
                    OAuth2AccessToken accessToken = new OAuth2AccessToken(BEARER, token, issuedAt, expiresAt);
                    return new OAuth2UserRequest(clientRegistration, accessToken);
                })
                .flatMap(this.oauth2UserService::loadUser);
    }
}
```

`spring-security-oauth2-client` 모듈을 사용하지 않아도 어렵지 않다. `WebClient` 인스턴스를 만들어서 `/userinfo`를 실행하면 된다:

```java
public class UserInfoOpaqueTokenIntrospector implements ReactiveOpaqueTokenIntrospector {
    private final ReactiveOpaqueTokenIntrospector delegate =
            new NimbusReactiveOpaqueTokenIntrospector("https://idp.example.org/introspect", "client", "secret");
    private final WebClient rest = WebClient.create();

    @Override
    public Mono<OAuth2AuthenticatedPrincipal> introspect(String token) {
        return this.delegate.introspect(token)
                .map(this::makeUserInfoRequest);
    }
}
```

어떤 방법을 사용했든, `ReactiveOpaqueTokenIntrospector`를 만들었다면 `@Bean`으로 등록해야 디폴트 빈을 재정의한다:

```java
@Bean
ReactiveOpaqueTokenIntrospector introspector() {
    return new UserInfoOpaqueTokenIntrospector(...);
}
```

### 25.3.4. Multi-tenancy

테넌트 식별자에 따라 bearer 토큰을 검증하는 전략이 다르다면 리소스 서버를 멀티 테넌트로 간주한다.

예를 들어 리소스 서버가 두 개의 다른 인가 서버에서 bearer 토큰을 받을 수도 있다. 아니면 인가 서버에 issuer가 여러 개 있을 수도 있다.

이럴 때 할 수 있는 일은 두 가지가 있으며, 선택하는 방법에 따라 장단점이 있다:

1. 테넌트 리졸브
2. 테넌트 전파

#### Resolving the Tenant By Claim

테넌트를 구별하는 한 가지 방법은 issuer 클레임이다. issuer 클레임은 서명한 JWT를 수반하므로 다음과 같이 `JwtIssuerReactiveAuthenticationManagerResolver`로 테넌트를 구분할 수 있다:

```java
JwtIssuerReactiveAuthenticationManagerResolver authenticationManagerResolver = new JwtIssuerReactiveAuthenticationManagerResolver
    ("https://idp.example.org/issuerOne", "https://idp.example.org/issuerTwo");

http
    .authorizeRequests(authorize -> authorize
        .anyRequest().authenticated()
    )
    .oauth2ResourceServer(oauth2 -> oauth2
        .authenticationManagerResolver(authenticationManagerResolver)
    );
```

이 방법은 issuer 엔드포인트를 lazy 방식으로 로드한다는 장점이 있다. 실제로 `JwtReactiveAuthenticationManager` 인스턴스는 해당하는 issuer가 최초 요청을 받아야만 만든다. 따라서 인가 서버의 기동 여부나 가용성과는 상관 없이 어플리케이션을 기동할 수 있다.

##### Dynamic Tenants

물론 새 테넌트를 추가할 때마다 어플리케이션을 재기동시키는 게 싫을 수도 있다. 이런 경우엔 `JwtIssuerReactiveAuthenticationManagerResolver`를, 런타임에 수정할 수 있는 `ReactiveAuthenticationManager` 인스턴스 저장소와 함께 설정하면 된다:

```java
private Mono<ReactiveAuthenticationManager> addManager(
        Map<String, ReactiveAuthenticationManager> authenticationManagers, String issuer) {

    return Mono.fromCallable(() -> ReactiveJwtDecoders.fromIssuerLocation(issuer))
            .subscribeOn(Schedulers.boundedElastic())
            .map(JwtReactiveAuthenticationManager::new)
            .doOnNext(authenticationManager -> authenticationManagers.put(issuer, authenticationManager));
}

// ...

JwtIssuerReactiveAuthenticationManagerResolver authenticationManagerResolver =
        new JwtIssuerReactiveAuthenticationManagerResolver(authenticationManagers::get);

http
    .authorizeRequests(authorize -> authorize
        .anyRequest().authenticated()
    )
    .oauth2ResourceServer(oauth2 -> oauth2
        .authenticationManagerResolver(authenticationManagerResolver)
    );
```

여기선 `JwtIssuerReactiveAuthenticationManagerResolver`에 issuer에 따라 `ReactiveAuthenticationManager`를 선택하는 전략을 설정한다. 이렇게 하면 런타임에 저장소에서 (위 코드에선 `Map`으로 나타냄) 요소를 추가하고 제거할 수 있다.

> 단순히 issuer를 가져와서 바로 `ReactiveAuthenticationManager`를 구성하는 건 안전한 방법이 아니다. issuer는 화이트리스트같은 신뢰할 수 있는 출처에서 가져오고, 코드에서 이를 검증할 수 있어야 한다.

### 25.3.5. Bearer Token Propagation

이제 bearer이 있으므로, 다운스트림 서비스로 편하게 넘겨도 된다. 다음 예제처럼 `ServerBearerExchangeFilterFunction`을 사용하면 매우 간단해진다.

```java
@Bean
public WebClient rest() {
    return WebClient.builder()
            .filter(new ServerBearerExchangeFilterFunction())
            .build();
}
```

위에 있는 `WebClient`로 요청을 수행하면 스프링 시큐리티는 현재 `Authentication`을 조회하고 `AbstractOAuth2Token` credential을 추출한다. 그런 다음 이 토큰을 `Authorization` 헤더에 전파한다.

예를 들어:

```java
this.rest.get()
        .uri("https://other-service.example.com/endpoint")
        .retrieve()
        .bodyToMono(String.class)
```

이 코드는 `https://other-service.example.com/endpoint`에 요청을 보내며, beaer 토큰 `Authorization` 헤더를 추가한다.

이 동작을 재정의하고 싶다면, 아래처럼 직접 헤더를 지정하기만 하면 된다:

```java
this.rest.get()
        .uri("https://other-service.example.com/endpoint")
        .headers(headers -> headers.setBearerAuth(overridingToken))
        .retrieve()
        .bodyToMono(String.class)
```

이 경우 이 필터는 폴백되고 나머지 웹 필터 체인으로 요청을 전달한다.

> 이 필터는 [OAuth 2.0 클라이언트 필터 펑션](https://docs.spring.io/spring-security/site/docs/current/api/org/springframework/security/oauth2/client/web/reactive/function/client/ServletOAuth2AuthorizedClientExchangeFilterFunction.html)과는 달리, 토큰이 만료돼도 갱신하지 않는다. 이 기능이 필요하다면 OAuth 2.0 클라이언트 필터를 사용해라.