---
title: Reactive X.509 Authentication
category: Spring Security
order: 30
permalink: /Spring%20Security/reactivex509authentication/
description: 스프링 시큐리티에서 리액티브로 x509 인증을 적용하는 방법을 설명합니다. 공식 문서에 있는 "Reactive X.509 Authentication" 챕터를 한글로 번역한 문서입니다.
image: ./../../images/springsecurity/spring-security.png
lastmod: 2020-09-15T21:00:00+09:00
comments: true
originalRefName: 스프링 시큐리티
originalRefLink: https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#reactive-x509
---

[서블릿 X.509 인증](../authentication#1018-x509-authentication)과 유사하게, 리액티브 x509 인증 필터로도 클라이언트가 제출한 인증서에서 인증 토큰을 추출할 수 있다.

다음은 리액티브 x509 시큐리티 설정을 사용하는 예시다:

```java
@Bean
public SecurityWebFilterChain securityWebFilterChain(ServerHttpSecurity http) {
    http
        .x509(withDefaults())
        .authorizeExchange(exchanges -> exchanges
            .anyExchange().permitAll()
        );
    return http.build();
}
```

이 설정에선 `principalExtractor`나 `authenticationManager`를 제공하지 않으면 디폴트 객체를 사용한다. 디폴트 principal extractor는 클라이언트가 제공한 인증서에서 CN(common name) 필드를 추출하는`SubjectDnX509PrincipalExtractor`다. 디폴트 인증 매니저는 사용자 계정의 유효성을 검사하는 `ReactivePreAuthenticatedAuthenticationManager`다. 유효성을 검사할 땐 `principalExtractor`에서 추출한 이름을 가진 사용자 계정이 존재하는지, 잠긴 계정이거나 비활성화 또는 만료된 계정은 아닌지를 확인한다.

아래 예시는 이 디폴트 클래스를 재정의하는 방법을 보여준다.

```java
@Bean
public SecurityWebFilterChain securityWebFilterChain(ServerHttpSecurity http) {
    SubjectDnX509PrincipalExtractor principalExtractor =
            new SubjectDnX509PrincipalExtractor();

    principalExtractor.setSubjectDnRegex("OU=(.*?)(?:,|$)");

    ReactiveAuthenticationManager authenticationManager = authentication -> {
        authentication.setAuthenticated("Trusted Org Unit".equals(authentication.getName()));
        return Mono.just(authentication);
    };

    http
        .x509(x509 -> x509
            .principalExtractor(principalExtractor)
            .authenticationManager(authenticationManager)
        )
        .authorizeExchange(exchanges -> exchanges
            .anyExchange().authenticated()
        );
    return http.build();
}
```

이 예시에서는 CN 대신 클라이언트 인증서의 OU 필드에서 사용자 이름을 추출하고, `ReactiveUserDetailsService`를 사용한 계정 조회는 전혀 하지 않는다. 대신에 제공받은 인증서를 발급한 OU가 "Trusted Org Unit"이면 요청을 인증한다.

Netty와 `WebClient`, 또는 `curl` 커맨드 라인 툴을 사용해서 양방향(mutual) TLS로 X.509 인증을 사용하는 예제는 https://github.com/spring-projects/spring-security/tree/master/samples/boot/webflux-x509를 참고해라.