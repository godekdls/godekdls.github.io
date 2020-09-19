---
title: Hello Spring Security
category: Spring Security
order: 9
permalink: /Spring%20Security/hellospringsecurity/
description: 서블릿 어플리케이션에서 스프링 시큐리티를 시작하는 방법과 스프링 부트 자동 설정을 설명합니다. 공식 문서에 있는 "hello spring security in servlet application" 챕터를 한글로 번역한 문서입니다.
image: ./../../images/springsecurity/spring-security.png
lastmod: 2020-08-21T21:30:00+09:00
comments: true
boundary: Servlet Applications
originalRefName: 스프링 시큐리티
originalRefLink: https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#servlet-hello
---

### 목차:

- [8.1. Updating Dependencies](#81-updating-dependencies)
- [8.2. Starting Hello Spring Security Boot](#82-starting-hello-spring-security-boot)
- [8.3. Spring Boot Auto Configuration](#83-spring-boot-auto-configuration)

---

스프링 시큐리티는 표준 서블릿 필터로 서블릿 컨테이너와 통합된다. 서블릿 컨테이너에서 실행하는 모든 어플리케이션에서 동작한다는 뜻이기도 하다. 더 구체적으로 말하자면, 서블릿 기반 어플리케이션에서 스프링 시큐리티 때문에 굳이 스프링을 사용할 필요가 없다는 말이다.

---

이번 섹션에선 스프링 부트에서 스프링 시큐리티를 사용하기 위한 최소한의 설정을 다룬다.

> 완성된 어플리케이션 코드는 [samples/boot/helloworld](https://github.com/spring-projects/spring-security/tree/5.3.2.RELEASE/samples/boot/helloworld)에서 찾아볼 수 있다. 좀 더 편리하게는, [여기를 클릭](https://start.spring.io/starter.zip?type=maven-project&language=java&packaging=jar&jvmVersion=1.8&groupId=example&artifactId=hello-security&name=hello-security&description=Hello Security&packageName=example.hello-security&dependencies=web,security)하면 최소 버전의 스프링 부트 + 스프링 시큐리티 어플리케이션을 다운로드할 수 있다.

---

## 8.1. Updating Dependencies

[메이븐](../gettingspringsecurity#421-spring-boot-with-maven)이나 [그래들](../gettingspringsecurity#431-spring-boot-with-gradle)로 의존성만 수정하면 끝이다.

---

## 8.2. Starting Hello Spring Security Boot

이제 메이븐 플러그인의 `run` goal로 [스프링 부트 어플리케이션을 기동](https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/#using-boot-running-with-the-maven-plugin)시킬 수 있다. 실행 방법은 다음을 참고하라 (실행 시 제일 앞에 출력되는 내용도 참고):

**Example 46. Running Spring Boot Application**

```bash
$ ./mvn spring-boot:run
...
INFO 23689 --- [  restartedMain] .s.s.UserDetailsServiceAutoConfiguration :

Using generated security password: 8e557245-73e2-4286-969a-ff57fe326336

...
```

---

## 8.3. Spring Boot Auto Configuration

스프링 부트는 다음과 같은 일을 자동으로 해준다:

- 스프링 시큐리티의 디폴트 설정을 활성화해서 `springSecurityFilterChain`이라는 이름의 서블릿 `Filter` 빈을 생성한다. 이 빈이 어플리케이션 내의 모든 보안 처리를 담당한다 (어플리케이션 URL  보호, 제출한 사용자 이름과 비밀번호 검증, 로그인 폼으로 리다이렉트 등).
- `user`라는 사용자 이름과 콘솔에도 출력되는 랜덤 생성한 비밀번호를 가지고 있는 `UserDetailsService` 빈을 만든다.
- 서블릿 컨테이너에 `springSecurityFilterChain`이란 이름의 `Filter` 빈을 등록해 모든 요청에 적용한다.

스프링 부트 설정은 간단하지만 많은 일을 해준다. 기능을 요약하면 다음과 같다:

- 어플리케이션의 모든 상호작용에 사용자 인증 요구
- 디폴트 로그인 폼 생성
- `user`라는 이름과 콘솔에 출력한 비밀번호를 사용한 폼 기반 인증 지원 (위 예제에서 비밀번호는 `8e557245-73e2-4286-969a-ff57fe326336`이다).
- BCrypt로 저장할 비밀번호 보호
- 사용자 로그아웃 지원
- [CSRF 공격](https://en.wikipedia.org/wiki/Cross-site_request_forgery) 방어
- [Session Fixation](https://en.wikipedia.org/wiki/Session_fixation) 방어
- 보안 헤더 통합
  - [HTTP Strict Transport Security](https://en.wikipedia.org/wiki/HTTP_Strict_Transport_Security)로 요청을 보호
  - [X-Content-Type-Options](https://msdn.microsoft.com/en-us/library/ie/gg622941(v=vs.85).aspx) 통합
  - Cache Control (어플리케이션에서 특정 스태틱 리소스에 캐시를 허용하도록 재정의할 수 있다)
  - [X-XSS-Protection](https://msdn.microsoft.com/en-us/library/dd565647(v=vs.85).aspx) 통합
  - X-Frame-Options 통합으로 [클릭재킹](https://en.wikipedia.org/wiki/Clickjacking) 방어 지원
- 서블릿 API 메소드 통합:
  - [`HttpServletRequest#getRemoteUser()`](https://docs.oracle.com/javaee/6/api/javax/servlet/http/HttpServletRequest.html#getRemoteUser())
  - [`HttpServletRequest.html#getUserPrincipal()`](https://docs.oracle.com/javaee/6/api/javax/servlet/http/HttpServletRequest.html#getUserPrincipal())
  - [`HttpServletRequest.html#isUserInRole(java.lang.String)`](https://docs.oracle.com/javaee/6/api/javax/servlet/http/HttpServletRequest.html#isUserInRole(java.lang.String))
  - [`HttpServletRequest.html#login(java.lang.String, java.lang.String)`](https://docs.oracle.com/javaee/6/api/javax/servlet/http/HttpServletRequest.html#login(java.lang.String, java.lang.String))
  - [`HttpServletRequest.html#logout()`](https://docs.oracle.com/javaee/6/api/javax/servlet/http/HttpServletRequest.html#logout())
