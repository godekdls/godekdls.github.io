---
title: EnableReactiveMethodSecurity
category: Spring Security
order: 32
permalink: /Spring%20Security/enablereactivemethodsecurity/
description: 리액티브 환경에서 스프링 시큐리티의 메소드 시큐리티를 설정하는 방법을 설명합니다. 공식 문서에 있는 "EnableReactiveMethodSecurity" 챕터를 한글로 번역한 문서입니다.
image: ./../../images/springsecurity/spring-security.png
lastmod: 2020-09-15T22:00:00+09:00
comments: true
completed: false
originalRefName: 스프링 시큐리티
originalRefLink: https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#jc-erms
---

스프링 시큐리티의 메소드 시큐리티 기능에 있는 `ReactiveSecurityContextHolder`는 [리액터의 컨텍스트](../../Reactor%20Core/advancedfeaturesandconcepts#98-adding-a-context-to-a-reactive-sequence)를 사용한다. 예를 들어, 아래 예제 코드는 컨텍스트에서 현재 로그인한 사용자의 메세지를 가져오는 방법을 보여준다.

> 컨텍스트를 사용하려면 메소드는 반드시 `Mono`나 `Flux`같은 `org.reactivestreams.Publisher` 타입을 반환해야 한다. 리액터의 `Context`와 통합하려면 필수사항이다.

```java
Authentication authentication = new TestingAuthenticationToken("user", "password", "ROLE_USER");

Mono<String> messageByUsername = ReactiveSecurityContextHolder.getContext()
    .map(SecurityContext::getAuthentication)
    .map(Authentication::getName)
    .flatMap(this::findMessageByUsername)
    // In a WebFlux application the `subscriberContext` is automatically setup using `ReactorContextWebFilter`
    .subscriberContext(ReactiveSecurityContextHolder.withAuthentication(authentication));

StepVerifier.create(messageByUsername)
    .expectNext("Hi user")
    .verifyComplete();
```

`this::findMessageByUsername` 정의는 다음과 같다:

```java
Mono<String> findMessageByUsername(String username) {
    return Mono.just("Hi " + username);
}
```

다음 코드는 리액티브 어플리케이션에서 메소드 시큐리티를 사용하기 위한 최소한의 설정이다:

```java
@EnableReactiveMethodSecurity
public class SecurityConfig {
    @Bean
    public MapReactiveUserDetailsService userDetailsService() {
        User.UserBuilder userBuilder = User.withDefaultPasswordEncoder();
        UserDetails rob = userBuilder.username("rob")
            .password("rob")
            .roles("USER")
            .build();
        UserDetails admin = userBuilder.username("admin")
            .password("admin")
            .roles("USER","ADMIN")
            .build();
        return new MapReactiveUserDetailsService(rob, admin);
    }
}
```

아래 클래스를 생각해 보자:

```java
@Component
public class HelloWorldMessageService {
    @PreAuthorize("hasRole('ADMIN')")
    public Mono<String> findMessage() {
        return Mono.just("Hello World!");
    }
}
```

위에 있는 설정을 함께 사용한다면, `@PreAuthorize("hasRole('ADMIN')")` 덕분에 `ADMIN` role이 있는 사용자만 `findByMessage`를 읽을 수 있게 된다. `@EnableReactiveMethodSecurity`만 추가하면 표준 메소드 시큐리티가 지원하는 모든 표현식을 사용할 수 있다. 단, 현재로서는 `Boolean`이나 `boolean`을 반환하는 표현식만 지원한다. 즉, 표현식에 블록을 사용하면 안 된다.

[웹플럭스 시큐리티](../webFluxsecurity)와 통합하면, 스프링 시큐리티가 자동으로 인증된 사용자에 따라 리액터 컨텍스트를 설정한다.

```java
@EnableWebFluxSecurity
@EnableReactiveMethodSecurity
public class SecurityConfig {

    @Bean
    SecurityWebFilterChain springWebFilterChain(ServerHttpSecurity http) throws Exception {
        return http
            // Demonstrate that method security works
            // Best practice to use both for defense in depth
            .authorizeExchange(exchanges -> exchanges
                .anyExchange().permitAll()
            )
            .httpBasic(withDefaults())
            .build();
    }

    @Bean
    MapReactiveUserDetailsService userDetailsService() {
        User.UserBuilder userBuilder = User.withDefaultPasswordEncoder();
        UserDetails rob = userBuilder.username("rob")
            .password("rob")
            .roles("USER")
            .build();
        UserDetails admin = userBuilder.username("admin")
            .password("admin")
            .roles("USER","ADMIN")
            .build();
        return new MapReactiveUserDetailsService(rob, admin);
    }
}
```

전체 샘플 코드는 [hellowebflux-method](https://github.com/spring-projects/spring-security/tree/5.3.2.RELEASE/samples/boot/hellowebflux-method)에서 확인할 수 있다.