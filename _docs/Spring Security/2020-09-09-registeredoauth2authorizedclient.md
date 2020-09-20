---
title: "@RegisteredOAuth2AuthorizedClient"
category: Spring Security
order: 29
permalink: /Spring%20Security/@registeredoauth2authorizedclient/
description: 스프링 시큐리티에서 @RegisteredOAuth2AuthorizedClient 애노테이션으로 OAuth2AuthorizedClient, 액세스 토큰을 리졸브하는 방법을 설명합니다. 공식 문서에 있는 "@RegisteredOAuth2AuthorizedClient" 챕터를 한글로 번역한 문서입니다.
image: ./../../images/springsecurity/spring-security.png
lastmod: 2020-09-20T23:18:12+09:00
comments: true
originalRefName: 스프링 시큐리티
originalRefLink: https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#webflux-roac
---

스프링 시큐리티에선 `@RegisteredOAuth2AuthorizedClient`를 사용해 액세스 토큰을 리졸브할 수 있다.

> 실제로 동작하는 예제는 [**OAuth 2.0 WebClient WebFlux 샘플**](https://github.com/spring-projects/spring-security/tree/5.3.2.RELEASE/samples/boot/oauth2webclient-webflux)에 있다.

스프링 시큐리티로 [OAuth2 로그인](../oauth2webflux#251-oauth-20-login)이나 [OAuth2 클라이언트](../oauth2webflux#252-oauth2-client)를 설정했다면 다음과 같이 `OAuth2AuthorizedClient`를 리졸브할 수 있다:

```java
@GetMapping("/explicit")
Mono<String> explicit(@RegisteredOAuth2AuthorizedClient("client-id") OAuth2AuthorizedClient authorizedClient) {
    // ...
}
```

스프링 시큐리티와 통합하면 다음과 같은 기능을 제공한다:

- 스프링 시큐리티가 자동으로 만료된 토큰을 갱신한다 (refresh 토큰이 있다면).
- 액세스 토큰을 요청했지만 토큰이 없는 경우, 스프링 시큐리티가 자동으로 액세스 토큰을 요청한다.
  - `authorization_code`에선, 리다이렉션을 수행한 다음 기존 요청을 다시 이어가는 것까지 포함한다.
  - `client_credentials`에선, 단순히 토큰을 요청하고 저장한다.

`oauth2Login()`으로 사용자를 인증했다면 `client-id`를 생략해도 된다. 예를 들어 다음 코드도 동작한다:

```java
@GetMapping("/implicit")
Mono<String> implicit(@RegisteredOAuth2AuthorizedClient OAuth2AuthorizedClient authorizedClient) {
    // ...
}
```

항상 OAuth2 로그인으로 사용자를 인증하고, 동일한 인가 서버의 액세스 토큰만 필요한 경우에 편리하다.