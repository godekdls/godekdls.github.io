---
title: What’s New in Spring Security 5.3
category: Spring Security
order: 4
permalink: /Spring%20Security/whatsnewinspringsecurity53/
description: 스프링 시큐리티 5.3에서 추가된 내용을 설명합니다. 공식 문서에 있는 "what's new" 챕터를 한글로 번역한 문서입니다.
image: ./../../images/springsecurity/spring-security.png
lastmod: 2020-08-21T21:30:00+09:00
comments: true
completed: false
---

> [스프링 시큐리티 공식 레퍼런스](https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#community)를 한글로 번역한 문서입니다.
>
> 전체 목차는 [여기](../contents/)에 있습니다.

{% include adsense.html %}

### 목차:

- [3.1. Documentation Updates](#31-documentation-updates)
- [3.2. Servlet](#32-servlet)
- [3.3. WebFlux](#33-webflux)
- [3.4. RSocket](#34-rsocket)
- [3.5. Additional Updates](#35-additional-updates)
- [3.6. Build Changes](#36-build-changes)

---

스프링 시큐리티 5.3에선 많은 기능이 추가됐다. 아래는 주요 릴리즈 내용이다. 

---

## 3.1. Documentation Updates

문서를 업데이트는 계속해서 신경쓸 예정이다.

이번 릴리즈에서 보게 될 내용은 다음과 같다:

- [Servlet Security: The Big Picture](../servletsecuritythebigpicture) 섹션 추가
- [Servlet Authentication](../authentication) 섹션 업데이트
  - 재작성
  - [다이어그램](../servletsecuritythebigpicture#servlet-delegatingfilterproxy-figure)을 포함한 작동 방식 설명 추가
- [코틀린 샘플](https://github.com/spring-projects/spring-security/tree/5.3.2.RELEASE/samples/boot/kotlin) 추가
- UI 개선
  - 스크롤 메뉴 추가
  - [토글](../authentication#10107-userdetailsservice) 추가
  - 스타일 업데이트

---

## 3.2. Servlet

- [코틀린 DSL](https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#kotlin-config-httpsecurity) 추가
- OAuth 2.0 클라이언트
  - [OAuth 2.0 클라이언트](https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#testing-oauth2-client), [OAuth 2.0 로그인](https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#testing-oauth2-login), [OIDC 로그인](https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#testing-oidc-login) 테스트 지원 추가
  - [OAuth 2.0 인가 요청 커스텀 기능](https://github.com/spring-projects/spring-security/pull/7748) 개선
  - 향상된 [OIDC logout success handler (`{baseUrl}` 지원)](https://github.com/spring-projects/spring-security/issues/7842)
  - [OAuth2Authorization success/failure handlers](https://github.com/spring-projects/spring-security/issues/7840) 추가
  - [XML 지원](https://github.com/spring-projects/spring-security/issues/5184) 추가
  - [OAuth 2.0 토큰 저장을 위한 JDBC 지원](https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#dbschema-oauth2-client) 추가
  - [OAuth 2.0을 위한 JSON 직렬화 지원](https://github.com/spring-projects/spring-security/issues/4886) 추가
- OAuth 2.0 리소스 서버
  - [multiple issuers](../oauth2#12320-multi-tenancy) 지원 추가
  - [Opaque 토큰 테스트 지원](https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#testing-opaque-token) 추가
  - [종합적인 클레임 validator](../oauth2#configuring-a-custom-validator) 추가
  - [XML 지원](https://github.com/spring-projects/spring-security/issues/5185) 추가
  - JWT와 Opaque 토큰을 위한 [bearer 토큰 에러 핸들링](https://github.com/spring-projects/spring-security/pull/7826) 개선
- SAML 2.0
  - [AuthenticationManager](https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#servlet-saml2-opensamlauthenticationprovider-authenticationmanager) 설정 추가
  - [AuthNRequest signatures](https://github.com/spring-projects/spring-security/issues/7711) 지원 추가
  - [AuthNRequest POST binding](https://github.com/spring-projects/spring-security/pull/7759) 지원 추가

---

## 3.3. WebFlux

- [커스텀 헤더 writers를 위한 DSL 지원](https://github.com/spring-projects/spring-security/issues/7636) 추가
- OAuth 2.0 클라이언트
  - [OAuth 2.0 클라이언트](https://github.com/spring-projects/spring-security/issues/7910), [OAuth 2.0 로그인](https://github.com/spring-projects/spring-security/issues/7828), [OIDC 로그인](https://github.com/spring-projects/spring-security/issues/7680) 테스트 지원 추가
  - 향상된 [OIDC logout success handler (`{baseUrl}` 지원)](https://github.com/spring-projects/spring-security/issues/7842)
  - [OAuth2Authorization success/failure handlers](https://github.com/spring-projects/spring-security/issues/7699) 추가
  - [OAuth 2.0 토큰을 위한 JSON 직렬화 지원](https://github.com/spring-projects/spring-security/issues/4886) 추가
  - [AuthorizedClientService와 ReactiveOAuth2AuthorizedClientManager 통합 지원](https://github.com/spring-projects/spring-security/issues/7569) 추가
- OAuth 2.0 리소스 서버
  - [multiple issuers](https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#webflux-oauth2resourceserver-multitenancy) 지원 추가
  - [Opaque Tokens 테스트 지원](https://github.com/spring-projects/spring-security/issues/7827) 추가
  - JWT와 Opaque 토큰을 위한 [bearer 토큰 에러 핸들링](https://github.com/spring-projects/spring-security/pull/7826) 개선

---

## 3.4. RSocket

- [RSocket Authentication extension](https://github.com/spring-projects/spring-security/issues/7935) 지원 추가

---

## 3.5. Additional Updates

- Authentication 이벤트 Publisher 지원 향상
  - [설정 지원](https://github.com/spring-projects/spring-security/pull/7802) 업데이트
  - [디폴트 이벤트](https://github.com/spring-projects/spring-security/issues/7825)와 [`Map` 기반](https://github.com/spring-projects/spring-security/issues/7824) exception 매핑 추가
- [스프링 데이터 통합](https://github.com/spring-projects/spring-security/issues/7891) 개선
- [BCrypt 바이트 배열 해싱](https://github.com/spring-projects/spring-security/issues/7661) 지원 추가

---

## 3.6. Build Changes

- [버전 범위](https://github.com/spring-projects/spring-security/issues/7788)를 사용해서 빌드하도록 수정
- [Groovy 의존성](https://github.com/spring-projects/spring-security/issues/4939) 제거

---

> 전체 목차는 [여기](../contents/)에 있습니다.