---
title: Project Modules
category: Spring Security
order: 7
permalink: /Spring%20Security/projectmodules/
description: 스프링 시큐리티 프로젝트 모듈을 소개합니다.
image: ./../../images/springsecurity/spring-security.png
lastmod: 2020-08-07T10:00:00+09:00
comments: true
completed: false
---

> [스프링 시큐리티 공식 레퍼런스](https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#modules)를 한글로 번역한 문서입니다.
>
> 전체 목차는 [여기](../contents/)에 있습니다.

{% include adsense.html %}

### 목차:

- [6.1. Core — spring-security-core.jar](#61-corespring-security-corejar)
- [6.2. Remoting — spring-security-remoting.jar](#62-remotingspring-security-remotingjar)
- [6.3. Web — spring-security-web.jar](#63-webspring-security-webjar)
- [6.4. Config — spring-security-config.jar](#64-configspring-security-configjar)
- [6.5. LDAP — spring-security-ldap.jar](#65-ldapspring-security-ldapjar)
- [6.6. OAuth 2.0 Core — spring-security-oauth2-core.jar](#66-oauth-20-corespring-security-oauth2-corejar)
- [6.7. OAuth 2.0 Client — spring-security-oauth2-client.jar](#67-oauth-20-clientspring-security-oauth2-clientjar)
- [6.8. OAuth 2.0 JOSE — spring-security-oauth2-jose.jar](#68-oauth-20-josespring-security-oauth2-josejar)
- [6.9. OAuth 2.0 Resource Server — spring-security-oauth2-resource-server.jar](#69-oauth-20-resource-serverspring-security-oauth2-resource-serverjar)
- [6.10. ACL — spring-security-acl.jar](#610-aclspring-security-acljar)
- [6.11. CAS — spring-security-cas.jar](#611-casspring-security-casjar)
- [6.12. OpenID — spring-security-openid.jar](#612-openidspring-security-openidjar)
- [6.13. Test — spring-security-test.jar](#613-testspring-security-testjar)

---

스프링 시큐리티는 3.0 버전에서 코드를 분류해서 기능 범위와 외부 의존성을 좀 더 세분화한 jar를 제공했다. 메이븐으로 프로젝트를 빌드한다면 `pom.xml`에 추가해야 하는 모듈이 더 있다. 메이븐을 사용하지 않더라도 `pom.xml` 파일을 보고 외부 의존성과 버전을 관리하는 방법을 파악해 보길 권한다. 샘플 어플리케이션에 있는 라이브러리를 파악해 보는 것도 좋은 생각이다.

---

## 6.1. Core — `spring-security-core.jar`

이 모듈엔 핵심 인증 기능과 접근 제어를 담당하는 클래스와 인터페이스가 있으며, 원격 지원과 기본적인 프로비저닝 API를 제공한다. 스프링 시큐리티를 사용한다면 반드시 추가해야 한다. standalone 어플리케이션과 리모트 클라이언트, 메소드 시큐리티 (서비스 레이어), JDBC 프로비저닝을 지원한다. 사용하는 상위 패키지는 다음과 같다:

- `org.springframework.security.core`
- `org.springframework.security.access`
- `org.springframework.security.authentication`
- `org.springframework.security.provisioning`

---

## 6.2. Remoting — `spring-security-remoting.jar`

이 모듈은 Spring Remoting과의 통합을 지원한다. Spring Remoting으로 리모트 클라이언트를 만들지 않는다면 추가할 필요 없다. 메인 패키지는 `org.springframework.security.remoting`이다.

---

## 6.3. Web — `spring-security-web.jar`

이 모듈은 필터와 관련 웹 보안 기반 코드를 제공한다. 서블릿 API 종속성이 있는 코드는 전부 여기에 있다. 스프링 시큐리티 웹 인증 서비스나 URL 기반 접근 제어가 필요하다면 이 모듈을 사용해라. 메인 패키지는 `org.springframework.security.web`이다.

---

## 6.4. Config — `spring-security-config.jar`

이 모듈은 보안 네임스페이스를 파싱하는 코드와 자바 설정 코드를 제공한다. 스프링 시큐리티 XML 네임스페이스 설정이나 자바 설정을 사용한다면 이 모듈이 필요할 것이다. 메인 패키지는 `org.springframework.security.config`다. 여기 있는 클래스는 어플리케이션에서 직접 사용하는 용도가 아니다.

---

## 6.5. LDAP — `spring-security-ldap.jar`

이 모듈은 LDAP 인증과 프로비저닝 코드를 제공한다. LDAP 인증을 사용하거나 LDAP 사용자 엔트리를 관리한다면 이 모듈을 사용해라. 상위 패키지는 `org.springframework.security.ldap`이다.

---

## 6.6. OAuth 2.0 Core — `spring-security-oauth2-core.jar`

`spring-security-oauth2-core.jar`에는 OAuth 2.0 프레임워크와 OpenID Connect Core 1.0 지원을 위한 핵심 클래스와 인터페이스가 있다. 클라이언트로써든, 리소스 서버나 authorization 서버로써든, OAuth 2.0이나 OpenID Connect Core 1.0을 사용한다면 이 모듈이 필요할 것이다. 상위 패키지는 `org.springframework.security.oauth2.core`다.

---

## 6.7. OAuth 2.0 Client — `spring-security-oauth2-client.jar`

`spring-security-oauth2-client.jar`는 OAuth 2.0 프레임워크와 OpenID Connect Core 1.0 클라이언트를 지원한다. OAuth 2.0 로그인이나 OAuth 클라이언트를 사용하는 어플리케이션에 필요하다. 상위 패키지는 `org.springframework.security.oauth2.client`다.

---

## 6.8. OAuth 2.0 JOSE — `spring-security-oauth2-jose.jar`

`spring-security-oauth2-jose.jar`는 JOSE (Javascript Object Signing and Encryption) 프레임워크를 지원한다. JOSE 프레임워크는 양단 간 클레임(claim)을 안전하게 전송할 수 있는 방법을 제공하는 프레임워크다. 이는 다음과 같은 스펙으로 구성된다:

- JSON Web Token (JWT)
- JSON Web Signature (JWS)
- JSON Web Encryption (JWE)
- JSON Web Key (JWK)

사용하는 상위 패키지는 다음과 같다:

- `org.springframework.security.oauth2.jwt`
- `org.springframework.security.oauth2.jose`

---

## 6.9. OAuth 2.0 Resource Server — `spring-security-oauth2-resource-server.jar`

`spring-security-oauth2-resource-server.jar`는 OAuth 2.0 리소스 서버를 지원한다. OAuth 2.0 Bearer 토큰으로 API를 보호할 때 사용한다. 상위 패키지는 `org.springframework.security.oauth2.server.resource`다.

---

## 6.10. ACL — `spring-security-acl.jar`

이 모듈은 도메인 객체 ACL 구현에 특화된 구현체를 제공한다. 어플리케이션에 있는 특정 도메인 객체 인스턴스에 보안을 적용할 때 사용한다. 상위 패키지는 `org.springframework.security.acls`다.

---

## 6.11. CAS — `spring-security-cas.jar`

이 모듈은 스프링 시큐리티의 CAS 클라이언트 통합을 지원한다. CAS 통합 인증 (single sign-on) 서버에서 스프링 시큐리티의 웹 인증을 사용할 때 필요하다. 상위 패키지는 `org.springframework.security.cas`다.

---

## 6.12. OpenID — `spring-security-openid.jar`

이 모듈은 OpenID 웹 인증을 지원한다. 외부 OpenID 서버에서 사용자를 인증할 때 사용한다. 상위 패키지는 `org.springframework.security.openid`다. OpenID4Java가 필요하다.

---

## 6.13. Test — `spring-security-test.jar`

이 모듈은 스프링 시큐리티 테스트를 지원한다.

---

전체 목차는 [여기](../contents/)에 있습니다.