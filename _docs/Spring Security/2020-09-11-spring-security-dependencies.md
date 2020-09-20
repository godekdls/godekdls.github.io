---
title: Spring Security Dependencies
category: Spring Security
order: 24
permalink: /Spring%20Security/springsecuritydependencies/
description: 스프링 시큐리티가 의존하는 라이브러리를 설명합니다. 공식 문서에 있는 "Spring Security Dependencies" 챕터를 한글로 번역한 문서입니다.
image: ./../../images/springsecurity/spring-security.png
lastmod: 2020-09-20T23:18:12+09:00
comments: true
originalRefName: 스프링 시큐리티
originalRefLink: https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#appendix-dependencies
---

### 목차:

- [22.6. Spring Security Dependencies](#226-spring-security-dependencies)
  + [22.6.1. spring-security-core](#2261-spring-security-core)
  + [22.6.2. spring-security-remoting](#2262-spring-security-remoting)
  + [22.6.3. spring-security-web](#2263-spring-security-web)
  + [22.6.4. spring-security-ldap](#2264-spring-security-ldap)
  + [22.6.5. spring-security-config](#2265-spring-security-config)
  + [22.6.6. spring-security-acl](#2266-spring-security-acl)
  + [22.6.7. spring-security-cas](#2267-spring-security-cas)
  + [22.6.8. spring-security-openid](#2268-spring-security-openid)
  + [22.6.9. spring-security-taglibs](#2269-spring-security-taglibs)

---

## 22.6. Spring Security Dependencies

이 부록에선 스프링 시큐리티의 모듈과, 어플리케이션 실행을 위해 필요한 기타 의존성을 설명한다. 스프링 시큐리티 자체를 빌드하거나 테스트할 때만 사용하는 의존성은 포함하지 않았다. 더불어 외부 라이브러리에서 필요한 전이 의존성(transitive dependencies)도 포함하지 않았다.

필요한 스프링 버전은 프로젝트 웹사이트에 나와 있으므로, 아래에선 스프링 의존성 버전을 생략했다. "optional"로 표기한 의존성 중에는, 스프링 어플리케이션에서 시큐리티 외 다른 기능 때문에 필요한 의존성도 있다. 또한 어플리케이션 대부분이 사용하는 의존성은 아래엔 "optional"로 표기돼 있더라도, 실제 프로젝트의 Maven POM 파일에는 optional로 표기하지 않았을 수도 있다. 특정 기능을 사용하지 않으면 필요하지 않다는 의미에서 "optional"이다.

모듈 하나가 다른 스프링 시큐리티 모듈을 사용하는 경우, 당연히 해당 모듈의 필수 의존성도 필요하며, 별도로 표기하진 않았다.

### 22.6.1. spring-security-core

스프링 시큐리티를 사용하는 모든 프로젝트는 코어 모듈을 추가해야 한다.

| Dependency        | Version | Description                                                  |
| :---------------- | :------ | :----------------------------------------------------------- |
| ehcache           | 1.6.2   | Ehcache 기반 사용자 캐시를 구현하는 경우에 필요하다 (optional). |
| spring-aop        |         | 메소드 시큐리티는 스프링 AOP를 기반으로 동작한다.            |
| spring-beans      |         | 스프링 설정에 필요하다.                                      |
| spring-expression |         | 표현식 기반 메소드 시큐리티에 필요하다 (optional).           |
| spring-jdbc       |         | 데이터베이스로 사용자 데이터를 저장할 때 필요하다 (optional). |
| spring-tx         |         | 데이터베이스로 사용자 데이터를 저장할 때 필요하다 (optional). |
| aspectjrt         | 1.6.10  | AspectJ 기능을 사용할 때 필요하다 (optional).                |
| jsr250-api        | 1.0     | JSR-250 메소드 시큐리티 애노테이션을 사용할 때 필요하다 (optional). |

### 22.6.2. spring-security-remoting

전형적으로 서블릿 API를 사용하는 웹 어플리케이션에 필요한 모듈이다.

| Dependency           | Version | Description                                        |
| :------------------- | :------ | :------------------------------------------------- |
| spring-security-core |         |                                                    |
| spring-web           |         | HTTP 리모트 기능을 사용하는 클라이언트에 필요하다. |

### 22.6.3. spring-security-web

전형적으로 서블릿 API를 사용하는 웹 어플리케이션에 필요한 모듈이다.

| Dependency           | Version | Description                                                  |
| :------------------- | :------ | :----------------------------------------------------------- |
| spring-security-core |         |                                                              |
| spring-web           |         | 스프링 웹 관련 클래스는 광범위하게 사용하고 있다.                  |
| spring-jdbc          |         | JDBC 기반 remember-be 토큰 레포지토리에 필요하다 (optional). |
| spring-tx            |         | remember-me 토큰 레포지토리 구현체에 필요하다 (optional).    |

### 22.6.4. spring-security-ldap

LDAP 인증을 사용할 때만 필요한 모듈이다.

| Dependency           | Version | Description                                                  |
| :------------------- | :------ | :----------------------------------------------------------- |
| spring-security-core |         |                                                              |
| spring-ldap-core     | 1.3.0   | LDAP은 스프링 LDAP을 기반으로 지원한다.                      |
| spring-tx            |         | Data exception 클래스가 필요하다.                            |
| apache-ds            | 1.5.5   | 임베디드 LDAP 서버를 사용할 때 필요하다 (optional).          |
| shared-ldap          | 0.9.15  | 임베디드 LDAP 서버를 사용할 때 필요하다 (optional).          |
| ldapsdk              | 4.1     | Mozilla LdapSDK. 예를 들어 OpenLDAP에서 password-policy 기능을 사용하는 경우 LDAP password policy control을 디코딩하는데 사용한다. |

### 22.6.5. spring-security-config

스프링 시큐리티 네임스페이스 설정을 사용할 때 필요한 모듈이다.

| Dependency             | Version | Description                                                  |
| :--------------------- | :------ | :----------------------------------------------------------- |
| spring-security-core   |         |                                                              |
| spring-security-web    |         | 웹 관련 네임스페이스 설정을 사용할 때 필요하다 (optional).   |
| spring-security-ldap   |         | LDAP 네임스페이스 옵션을 사용할 때 필요하다 (optional).      |
| spring-security-openid |         | OpenID 인증을 사용할 때 필요하다 (optional).                 |
| aspectjweaver          | 1.6.10  | protect-pointcut 네임스페이스 문법을 사용할 때 필요하다 (optional). |

### 22.6.6. spring-security-acl

ACL 모듈.

| Dependency           | Version | Description                                                  |
| :------------------- | :------ | :----------------------------------------------------------- |
| spring-security-core |         |                                                              |
| ehcache              | 1.6.2   | Ehcache 기반 ACL 캐시를 구현하는 경우에 필요하다 (자체 구현체를 사용하는 경우 optional). |
| spring-jdbc          |         | 디폴트 JDBC 기반 AclService를 사용할 때 필요하다 (자체 구현체를 사용하는 경우 optional). |
| spring-tx            |         | 디폴트 JDBC 기반 AclService를 사용할 때 필요하다 (자체 구현체를 사용하는 경우 optional). |

### 22.6.7. spring-security-cas

CAS 모듈은 JA-SIG CAS와의 통합을 지원한다.

| Dependency           | Version | Description                                                  |
| :------------------- | :------ | :----------------------------------------------------------- |
| spring-security-core |         |                                                              |
| spring-security-web  |         |                                                              |
| cas-client-core      | 3.1.12  | JA-SIG CAS 클라이언트. 스프링 시큐리티 통합을 위한 기본 모듈이다. |
| ehcache              | 1.6.2   | Ehcache 기반 ticket 캐시를 사용하는 경우에 필요하다  (optional). |

### 22.6.8. spring-security-openid

OpenID 모듈.

| Dependency           | Version | Description                                                 |
| :------------------- | :------ | :---------------------------------------------------------- |
| spring-security-core |         |                                                             |
| spring-security-web  |         |                                                             |
| openid4java-nodeps   | 0.9.6   | 스프링 시큐리티는 OpenID4Java를 사용해서 OpenID를 통합한다. |
| httpclient           | 4.1.1   | openid4java-nodeps는 HttpClient 4를 사용한다.               |
| guice                | 2.0     | openid4java-nodeps는 Guice 2를 사용한다.                    |

### 22.6.9. spring-security-taglibs

스프링 시큐리티의 JSP 태그 구현체를 제공한다.

| Dependency           | Version | Description                                                  |
| :------------------- | :------ | :----------------------------------------------------------- |
| spring-security-core |         |                                                              |
| spring-security-web  |         |                                                              |
| spring-security-acl  |         | ACL에서 `accesscontrollist` 태그나 `hasPermission()` 표현식을 사용할 때 필요하다 (optional). |
| spring-expression    |         | 태그 접근 제약 조건에 SPEL 표현식을 사용하는 경우에 필요하다. |
