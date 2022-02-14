---
title: RSocket Security
category: Spring Security
order: 34
permalink: /Spring%20Security/rsocketsecurity/
description: 스프링 시큐리티와 RSocket을 통합하는 방법을 설명합니다. 공식 문서에 있는 "RSocket Security" 챕터를 한국어로 번역한 문서입니다.
image: ./../../images/springsecurity/spring-security.png
lastmod: 2020-09-20T23:18:12+09:00
comments: true
originalRefName: 스프링 시큐리티
originalRefLink: https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#rsocket
---

### 목차:

- [31.1. Minimal RSocket Security Configuration](#311-minimal-rsocket-security-configuration)
- [31.2. Adding SecuritySocketAcceptorInterceptor](#312-adding-securitysocketacceptorinterceptor)
- [31.3. RSocket Authentication](#313-rsocket-authentication)
  + [31.3.1. Authentication at Setup vs Request Time](#3131-authentication-at-setup-vs-request-time)
  + [31.3.2. Simple Authentication](#3132-simple-authentication)
  + [31.3.3. JWT](#3133-jwt)
- [31.4. RSocket Authorization](#314-rsocket-authorization)

---

스프링 시큐리티의 RSocket 기능에선 `SocketAcceptorInterceptor`를 사용한다. 보안 기능의 주요 진입점은 `PayloadSocketAcceptorInterceptor`에서 확인할 수 있다. `PayloadSocketAcceptorInterceptor`는 `PayloadInterceptor` 구현체를 사용해서 RSocket API에서 `PayloadExchange`를 가로챌 수 있도록 해준다.

아래 코드를 사용하는 샘플 어플리케이션도 제공한다:

- Hello RSocket [hellorsocket](https://github.com/spring-projects/spring-security/tree/5.3.2.RELEASE/samples/boot/hellorsocket)
- [Spring Flights](https://github.com/rwinch/spring-flights/tree/security)

---

## 31.1. Minimal RSocket Security Configuration

다음 코드는 최소한의 RSocket 시큐리티 설정이다:

```java
@Configuration
@EnableRSocketSecurity
public class HelloRSocketSecurityConfig {

    @Bean
    public MapReactiveUserDetailsService userDetailsService() {
        UserDetails user = User.withDefaultPasswordEncoder()
            .username("user")
            .password("user")
            .roles("USER")
            .build();
        return new MapReactiveUserDetailsService(user);
    }
}
```

이 설정은 [simple 인증](#3132-simple-authentication)을 활성화 하고 모든 요청에 사용자 인증을 요구하도록 [rsocket 인가](#314-rsocket-authorization)를 세팅한다.

---

## 31.2. Adding SecuritySocketAcceptorInterceptor

스프링 시큐리티가 동작하려면 `ServerRSocketFactory`에 `SecuritySocketAcceptorInterceptor`를 적용해야 한다. 이를 통해 RSocket 인프라로 만든 `PayloadSocketAcceptorInterceptor`를 연결할 수 있다. 스프링 부트 어플리케이션에선 `RSocketSecurityAutoConfiguration`에 있는 다음 코드가 이를 자동으로 설정해준다.

```java
@Bean
RSocketServerCustomizer springSecurityRSocketSecurity(SecuritySocketAcceptorInterceptor interceptor) {
		return (server) -> server.interceptors((registry) -> registry.forSocketAcceptor(interceptor));
}
```

---

## 31.3. RSocket Authentication

RSocket 인증은 `AuthenticationPayloadInterceptor`가 수행한다. 이 인터셉터는 `ReactiveAuthenticationManager` 인스턴스를 호출하는 컨트롤러 역할을 담당한다.

### 31.3.1. Authentication at Setup vs Request Time

일반적으로 인증은 설정 시점과 요청 시점에 발생할 수 있다.

몇 가지 시나리오에선 설정 시점 인증이 유용할 수 있다. 일반적인 시나리오는 단일 사용자가 (i.e. 모바일 커넥션) RSocket 커넥션을 활용하는 경우다. 이 시나리오에선 사용자 한 명만 커넥션을 활용하므로 커넥션 타임에 한 번만 인증하면 된다.

RSocket 커넥션을 공유하는 시나리오에선, 각 요청마다 credential을 보내야 한다. 예를 들어 RSocket 서버에 다운스트림 서비스로 커넥션을 맺는 웹 에플리케이션은 모든 사용자가 사용할 단일 커넥션을 만든다. 이 경우 RSocket 서버는 요청 시마다 웹 어플리케이션 사용자의 credential을 기반으로 권한을 부여해야 한다.

설정 시점과 요청 시점 인증이 전부 의미 있는 시나리오도 있다. 앞에서 설명한 웹 어플리케이션을 생각해보자. 웹 어플리케이션 자체의 커넥션을 제한해야 한다면, 커넥션을 맺는 시점에 `SETUP` 권한이 있는 credential을 설정할 수 있다. 그러면 사용자마다 권한이 다르더라도 `SETUP` 권한은 모두가 가지고 있다. 즉, 모든 사용자가 요청을 보낼 순 있지만 별도 커넥션을 생성하진 않는다.

### 31.3.2. Simple Authentication

스프링 시큐리티는 [Simple Authentication Metadata Extension](https://github.com/rsocket/rsocket/blob/5920ed374d008abb712cb1fd7c9d91778b2f4a68/Extensions/Security/Simple.md)을 지원한다.

> Basic 인증 초안은 Simple 인증으로 진화했으며, 이전 버전과의 호환성을 위해서만 지원하고 있다. 설정 방법은 `RSocketSecurity.basicAuthentication(Customizer)`를 참고해라.

RSocket receiver는 `AuthenticationPayloadExchangeConverter`를 사용해서 credential을 디코딩할 수 있다. `AuthenticationPayloadExchangeConverter`는 `simpleAuthentication` DSL을 사용하면 자동 설정된다. 명시적인 설정은 아래에 있다.

```java
@Bean
PayloadSocketAcceptorInterceptor rsocketInterceptor(RSocketSecurity rsocket) {
    rsocket
        .authorizePayload(authorize ->
            authorize
                    .anyRequest().authenticated()
                    .anyExchange().permitAll()
        )
        .simpleAuthentication(Customizer.withDefaults());
    return rsocket.build();
}
```

RSocket sender는 `SimpleAuthenticationEncoder`로 credential을 전송할 수 있으며, `SimpleAuthenticationEncoder`는 스프링의 `RSocketStrategies`에 추가할 수 있다.

```java
RSocketStrategies.Builder strategies = ...;
strategies.encoder(new SimpleAuthenticationEncoder());
```

이렇게 하면 설정한 strategies를 사용해서 receiver에게 사용자 이름과 비밀번호를 전송할 수 있다:

```java
MimeType authenticationMimeType =
    MimeTypeUtils.parseMimeType(WellKnownMimeType.MESSAGE_RSOCKET_AUTHENTICATION.getString());
UsernamePasswordMetadata credentials = new UsernamePasswordMetadata("user", "password");
Mono<RSocketRequester> requester = RSocketRequester.builder()
    .setupMetadata(credentials, authenticationMimeType)
    .rsocketStrategies(strategies.build())
    .connectTcp(host, port);
```

전송할 요청에 직접 사용자 이름과 비밀번호를 넣어도 되고, 다른 정보를 추가해도 된다.

```java
Mono<RSocketRequester> requester;
UsernamePasswordMetadata credentials = new UsernamePasswordMetadata("user", "password");

public Mono<AirportLocation> findRadar(String code) {
    return this.requester.flatMap(req ->
        req.route("find.radar.{code}", code)
            .metadata(credentials, authenticationMimeType)
            .retrieveMono(AirportLocation.class)
    );
}
```

### 31.3.3. JWT

스프링 시큐리티는 [Bearer Token Authentication Metadata Extension](https://github.com/rsocket/rsocket/blob/5920ed374d008abb712cb1fd7c9d91778b2f4a68/Extensions/Security/Bearer.md)을 지원한다. 이 기능은 JWT를 인증하고 (JWT가 유효한지 확인), JWT로 권한을 결정하는 방식이다.

RSocket receiver는 `BearerPayloadExchangeConverter`로 credential을 디코딩할 수 있다. `BearerPayloadExchangeConverter`는 `jwt` DSL을 사용하면 자동 설정된다. 다음은 설정 예시이다:

```java
@Bean
PayloadSocketAcceptorInterceptor rsocketInterceptor(RSocketSecurity rsocket) {
    rsocket
        .authorizePayload(authorize ->
            authorize
                .anyRequest().authenticated()
                .anyExchange().permitAll()
        )
        .jwt(Customizer.withDefaults());
    return rsocket.build();
}
```

위에 있는 설정에선 어플리케이션 컨텍스트에 있는 `ReactiveJwtDecoder` `@Bean`을 사용한다. issuer에서 디코더를 생성하는 예시는 다음과 같다.

```java
@Bean
ReactiveJwtDecoder jwtDecoder() {
    return ReactiveJwtDecoders
        .fromIssuerLocation("https://example.com/auth/realms/demo");
}
```

토큰 값은 단순한 문자열이기 때문에 RSocket sender는 특별한 작업 없이도 토큰을 전송할 수 있다. 예를 들어 설정 시점에 있는 토큰을 전송할 수 있다:

```java
MimeType authenticationMimeType =
    MimeTypeUtils.parseMimeType(WellKnownMimeType.MESSAGE_RSOCKET_AUTHENTICATION.getString());
BearerTokenMetadata token = ...;
Mono<RSocketRequester> requester = RSocketRequester.builder()
    .setupMetadata(token, authenticationMimeType)
    .connectTcp(host, port);
```

전송할 요청에 직접 토큰을 추가해도 되고, 다른 토큰를 추가해도 된다.

```java
MimeType authenticationMimeType =
    MimeTypeUtils.parseMimeType(WellKnownMimeType.MESSAGE_RSOCKET_AUTHENTICATION.getString());
Mono<RSocketRequester> requester;
BearerTokenMetadata token = ...;

public Mono<AirportLocation> findRadar(String code) {
    return this.requester.flatMap(req ->
        req.route("find.radar.{code}", code)
            .metadata(token, authenticationMimeType)
            .retrieveMono(AirportLocation.class)
    );
}
```

---

## 31.4. RSocket Authorization

RSocket 인가는 `AuthorizationPayloadInterceptor`가 수행한다. `AuthorizationPayloadInterceptor`는 `ReactiveAuthorizationManager` 인스턴스를 호출하는 컨트롤러 역할을 담당한다. DSL을 사용해서 `PayloadExchange` 기반 권한 인가 규칙을 설정할 수 있다. 설정 예시는 아래에 있다:

```java
rsocket
    .authorizePayload(authorize ->
        authorize
            .setup().hasRole("SETUP") // (1)
            .route("fetch.profile.me").authenticated() // (2)
            .matcher(payloadExchange -> isMatch(payloadExchange)) // (3)
                .hasRole("CUSTOM")
            .route("fetch.profile.{username}") // (4)
                .access((authentication, context) -> checkFriends(authentication, context))
            .anyRequest().authenticated() // (5)
            .anyExchange().permitAll() // (6)
    )
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `ROLE_SETUP` 권한이 있어야 커넥션을 맺을 수 있도록 설정한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 라우팅 정보가 `fetch.profile.me`면 사용자 인증만 요구한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 여기에선 `ROLE_CUSTOM` 권한이 있어야 권한을 인가하도록 커스텀 matcher를 설정한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> 여기선 권한 인가 규칙을 커스텀한다. 이 matcher는 `context`에 있는 username을 변수로 사용한다. 커스텀 인가 규칙은 `checkFriends` 메소드로 제공한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> 여기선 별다른 규칙이 없는 request에서도 사용자를 인증하도록 설정한다. request에는 메타데이터가 있다. request는 별도 페이로드를 포함하지 않는다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(6)</span> 여기선 별다른 규칙이 없는 exchange는 누구나 요청할 수 있도록 허용한다. 이 예시에선 메타데이터가 없는 페이로드에는 인가 규칙이 없다는 뜻이다.</small>

인가 규칙은 순서대로 적용된다는 점을 알고 있어야 한다. 첫 번째로 매칭된 인가 규칙만 적용된다.