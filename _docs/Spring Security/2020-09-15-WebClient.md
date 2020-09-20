---
title: WebClient
category: Spring Security
order: 31
permalink: /Spring%20Security/webclient/
description: 스프링 시큐리티로 WebClient를 통합해서, 액세스 토큰을 자동으로 설정하는 방법을 설명합니다. 공식 문서에 있는 "WebClient" 챕터를 한글로 번역한 문서입니다.
image: ./../../images/springsecurity/spring-security.png
lastmod: 2020-09-15T22:00:00+09:00
comments: true
completed: false
originalRefName: 스프링 시큐리티
originalRefLink: https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#webclient
---

### 목차:

- [28.1. WebClient OAuth2 Setup](#281-webclient-oauth2-setup)
- [28.2. Implicit OAuth2AuthorizedClient](#282-implicit-oauth2authorizedclient)
- [28.3. Explicit OAuth2AuthorizedClient](#283-explicit-oauth2authorizedclient)
- [28.4. clientRegistrationId](#284-clientregistrationid)

---

> 이 문서에서 설명하는 내용은 리액티브 환경을 기준으로 설명한다. 서블릿 환경은 [서블릿 환경에서 WebClient 통합하기](../oauth2#1224-webclient-integration-for-servlet-environments) 섹션을 참고해라.

스프링 프레임워크는 기본적으로 bearer 토큰 설정을 지원한다.

```java
webClient.get()
    .headers(h -> h.setBearerAuth(token))
    ...
```

스프링 시큐리티는 이 기능을 기반으로 아래와 같은 기능을 추가 지원한다:

- 스프링 시큐리티가 자동으로 만료된 토큰을 갱신한다 (refresh 토큰이 있다면).
- 액세스 토큰을 요청했지만 토큰이 없는 경우, 스프링 시큐리티가 자동으로 액세스 토큰을 요청한다.
  - `authorization_code`에선, 리다이렉션을 수행한 다음 기존 요청을 다시 이어가는 것까지 포함한다.
  - `client_credentials`에선, 단순히 토큰을 요청하고 저장한다.
- 현재 사용자의 OAuth 토큰을 그대로 사용하거나, 사용할 토큰을 직접 명시할 수 있다.

---

## 28.1. WebClient OAuth2 Setup

가장 먼저 `WebClient`를 적절하게 설정해야 한다. 아래 코드는 완전한 리액티브 환경에서 `WebClient`를 설정하는 예시다:

```java
@Bean
WebClient webClient(ReactiveClientRegistrationRepository clientRegistrations,
        ServerOAuth2AuthorizedClientRepository authorizedClients) {
    ServerOAuth2AuthorizedClientExchangeFilterFunction oauth =
            new ServerOAuth2AuthorizedClientExchangeFilterFunction(clientRegistrations, authorizedClients);
    // (optional) explicitly opt into using the oauth2Login to provide an access token implicitly
    // oauth.setDefaultOAuth2AuthorizedClient(true);
    // (optional) set a default ClientRegistration.registrationId
    // oauth.setDefaultClientRegistrationId("client-registration-id");
    return WebClient.builder()
            .filter(oauth)
            .build();
}
```

---

## 28.2. Implicit OAuth2AuthorizedClient

위 설정에서 `defaultOAuth2AuthorizedClient`를 `true`로 설정했다면, oauth2Login(i.e. OIDC)으로 인증한 현재 사용자의 인증 정보를 사용해서 자동으로 액세스 토큰을 공급한다. 또는 `defaultClientRegistrationId`를 유효한 `ClientRegistration` id로 설정했다면, 클라이언트 등록 정보를 사용해서 액세스 토큰을 공급한다. 이 방식은 편리하긴 하지만, 모든 엔드포인트에서 액세스 토큰이 필요한 게 아니라면 위험한 방법이다 (액세스 토큰이 필요 없는 엔드포인트에 액세스 토큰을 전송할 수 있다).

```java
Mono<String> body = this.webClient
        .get()
        .uri(this.uri)
        .retrieve()
        .bodyToMono(String.class);
```

---

## 28.3. Explicit OAuth2AuthorizedClient

필요할 때만 요청 속성에 `OAuth2AuthorizedClient`를 명시하는 것도 가능하다. 아래 예제에선 스프링 웹플럭스나 스프링 MVC의 메소드 인자 리졸버로 `OAuth2AuthorizedClient`를 리졸브한다. 물론 `OAuth2AuthorizedClient`를 리졸브하는 방식이 중요한 건 아니다.

```java
@GetMapping("/explicit")
Mono<String> explicit(@RegisteredOAuth2AuthorizedClient("client-id") OAuth2AuthorizedClient authorizedClient) {
    return this.webClient
            .get()
            .uri(this.uri)
            .attributes(oauth2AuthorizedClient(authorizedClient))
            .retrieve()
            .bodyToMono(String.class);
}
```

---

## 28.4. clientRegistrationId

아니면  요청 속성에 `clientRegistrationId`를 지정하는 것도 가능한데, 이렇게 하면 `WebClient`가 `OAuth2AuthorizedClient`를 찾아 바인딩한다. 해당 클라이언트를 찾을 수 없다면 자동으로 하나를 선택한다.

```java
Mono<String> body = this.webClient
        .get()
        .uri(this.uri)
        .attributes(clientRegistrationId("client-id"))
        .retrieve()
        .bodyToMono(String.class);
```