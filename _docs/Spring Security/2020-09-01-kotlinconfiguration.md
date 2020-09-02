---
title: Kotlin Configuration
category: Spring Security
order: 18
permalink: /Spring%20Security/kotlinconfiguration/
description: 코틀린 코드로 스프링 시큐리티를 설정하는 방법을 설명합니다. 공식 문서에 있는 "Kotlin Configuration" 챕터를 한글로 번역한 문서입니다.
image: ./../../images/springsecurity/spring-security.png
lastmod: 2020-09-01T21:30:00+09:00
comments: true
completed: false
originalRefName: 스프링 시큐리티
originalRefLink: https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#kotlin-config
---

### 목차:

- [17.1. HttpSecurity](#171-httpsecurity)
- [17.2. Multiple HttpSecurity](#172-multiple-httpsecurity)

---

스프링 시큐리티 코틀린 설정은 스프링 스큐리티 5.3부터 지원했다. 네이티브 코틀린 DSL로 손쉽게 스프링 시큐리티 설정을 만들 수 있다.

---

> 스프링 시큐리티는 코틀린 설정을 사용하는 [많은 샘플 어플리케이션](https://github.com/spring-projects/spring-security/tree/master/samples/boot/kotlin)을 제공한다.

---

## 17.1. HttpSecurity

스프링 시큐리티는 모든 사용자를 인증해야 한다는 걸 어떻게 알 수 있을까? 폼 기반 인증을 지원해야 한다는 것은 또 어떻게 알까? 사실은 뒷단에서 실행하는 `WebSecurityConfigurerAdapter`라는 설정 클래스가 있다. 이 클래스는 디폴트로 아래와 같이 구현돼 있는 `configure`라는 메소드가 있다:

```kotlin
fun configure(http: HttpSecurity) {
   http {
        authorizeRequests {
            authorize(anyRequest, authenticated)
        }
       formLogin { }
       httpBasic { }
    }
}
```

이 디폴트 설정은:

- 어플리케이션의 모든 요청은 인증한 사용자만 사용할 수 있음을 보장한다.
- 폼 기반 로그인 인증을 지원한다.
- HTTP 기본 인증을 지원한다.

이 설정은 XML 네임스페이스 설정과도 매우 유사하다는 것을 알 수 있다:

```xml
<http>
    <intercept-url pattern="/**" access="authenticated"/>
    <form-login />
    <http-basic />
</http>
```

---

## 17.2. Multiple HttpSecurity

`<http>` 블록을 여러 개 만들 수 있듯이, HttpSecurity 인스턴스도 여러 개 설정할 수 있다. 핵심은 `WebSecurityConfigurerAdapter`를 여러 번 상속하는 것이다. 예를 들어 다음 예제에선 `/api/`로 시작하는 URL은 다른 설정을 사용한다:

```kotlin
@EnableWebSecurity
class MultiHttpSecurityConfig {
    @Bean                                                           // (1)
    public fun userDetailsService(): UserDetailsService {
        val users: User.UserBuilder = User.withDefaultPasswordEncoder()
        val manager = InMemoryUserDetailsManager()
        manager.createUser(users.username("user").password("password").roles("USER").build())
        manager.createUser(users.username("admin").password("password").roles("USER","ADMIN").build())
        return manager
    }

    @Configuration
    @Order(1)                                                        // (2)
    class ApiWebSecurityConfigurationAdapter: WebSecurityConfigurerAdapter() {
        override fun configure(http: HttpSecurity) {
            http {
                securityMatcher("/api/**")                           // (3)
                authorizeRequests {
                    authorize(anyRequest, hasRole("ADMIN"))
                }
                httpBasic { }
            }
        }
    }

    @Configuration                                                   // (4)
    class FormLoginWebSecurityConfigurerAdapter: WebSecurityConfigurerAdapter() {
        override fun configure(http: HttpSecurity) {
            http {
                authorizeRequests {
                    authorize(anyRequest, authenticated)
                }
                formLogin { }
            }
        }
    }
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 평소처럼 인증을 설정한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> `WebSecurityConfigurerAdapter` 인스턴스를 생성하고, `@Order`를 명시해서 가장 우선시할 `WebSecurityConfigurerAdapter`로 설정한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> `http.antMatcher`는 이 `HttpSecurity`는 `/api/`로 시작하는 URL에만 적용한다고 말하고 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> 다른 `WebSecurityConfigurerAdapter` 인스턴스를 생성한다. `/api/`로 시작하지 않는 URL은 이 설정을 사용한다. 이 설정은 `1`보다 큰 `@Order` 값을 가지므로 `ApiWebSecurityConfigurationAdapter` 이후에 사용한다 (기본적으로 `@Order`를 생략하면 마지막이 된다).</small>