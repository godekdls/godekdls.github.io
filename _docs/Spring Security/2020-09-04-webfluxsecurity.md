---
title: WebFlux Security
category: Spring Security
order: 26
permalink: /Spring%20Security/webfluxsecurity/
description: 웹플럭스 어플리케이션에서 스프링 시큐리티를 시작하는 방법과 스프링 부트 자동 설정을 설명합니다. 공식 문서에 있는 "WebFlux Security" 챕터를 한국어로 번역한 문서입니다.
image: ./../../images/springsecurity/spring-security.png
lastmod: 2020-09-20T23:18:12+09:00
comments: true
originalRefName: 스프링 시큐리티
originalRefLink: https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#jc-webflux
boundary: Reactive Applications
---

### 목차:

- [23.1. Minimal WebFlux Security Configuration](#231-minimal-webflux-security-configuration)
- [23.2. Explicit WebFlux Security Configuration](#232-explicit-webflux-security-configuration)

---

스프링 시큐리티 웹플럭스 기능은 `WebFilter`를 사용하며, 스프링 웹플럭스와 스프링 WebFlux.Fn에서 동일하게 동작한다. 아래에서 설명하는 코드를 사용하는 샘플 어플리케이션을 참고하라:

- Hello WebFlux [hellowebflux](https://github.com/spring-projects/spring-security/tree/5.3.2.RELEASE/samples/boot/hellowebflux)
- Hello WebFlux.Fn [hellowebfluxfn](https://github.com/spring-projects/spring-security/tree/5.3.2.RELEASE/samples/boot/hellowebfluxfn)
- Hello WebFlux Method [hellowebflux-method](https://github.com/spring-projects/spring-security/tree/5.3.2.RELEASE/samples/boot/hellowebflux-method)

---

## 23.1. Minimal WebFlux Security Configuration

다음은 웹플럭스 시큐리티를 위한 최소한의 설정이다:

```java
@EnableWebFluxSecurity
public class HelloWebfluxSecurityConfig {

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

이 설정은 폼 인증과 http 기본 인증을 제공하고, 모든 페이지에 인증한 사용자만 접근할 수 있도록 인가 설정을 만들고, 디폴트 로그인 페이지와 디폴트 로그아웃 페이지를 세팅하며, 보안 관련 HTTP 헤더와 CSRF 방어 등을 설정한다.

---

## 23.2. Explicit WebFlux Security Configuration

최소한의 웹플럭스 시큐리티 설정을 명시적으로 선언하면 다음과 같다:

```java
@Configuration
@EnableWebFluxSecurity
public class HelloWebfluxSecurityConfig {

    @Bean
    public MapReactiveUserDetailsService userDetailsService() {
        UserDetails user = User.withDefaultPasswordEncoder()
            .username("user")
            .password("user")
            .roles("USER")
            .build();
        return new MapReactiveUserDetailsService(user);
    }

    @Bean
    public SecurityWebFilterChain springSecurityFilterChain(ServerHttpSecurity http) {
        http
            .authorizeExchange(exchanges -> exchanges
                .anyExchange().authenticated()
            )
            .httpBasic(withDefaults())
            .formLogin(withDefaults());
        return http.build();
    }
}
```

이 코드는 위에 있는 최소한의 설정과 동일한 설정을 명시적으로 정의한 코드다. 여기에선 디폴트 값을 쉽게 변경할 수 있다.