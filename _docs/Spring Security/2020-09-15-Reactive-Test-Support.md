---
title: Reactive Test Support
category: Spring Security
order: 33
permalink: /Spring%20Security/reactivetestsupport/
description: 리액티브 환경에서 지원하는 스프링 시큐리티 테스트 기능을 설명합니다. 공식 문서에 있는 "Reactive Test Support" 챕터를 한글로 번역한 문서입니다.
image: ./../../images/springsecurity/spring-security.png
lastmod: 2020-09-15T22:50:00+09:00
comments: true
originalRefName: 스프링 시큐리티
originalRefLink: https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#test-webflux
---

### 목차:

- [30.1. Testing Reactive Method Security](#301-testing-reactive-method-security)
- [30.2. WebTestClientSupport](#302-webtestclientsupport)
  + [30.2.1. Authentication](#3021-authentication)
  + [30.2.2. CSRF Support](#3022-csrf-support)
  + [30.2.3. Testing OAuth 2.0](#3023-testing-oauth-20)
  + [30.2.4. Testing OIDC Login](#3024-testing-oidc-login)
  + [30.2.5. Testing OAuth 2.0 Login](#3025-testing-oauth-20-login)
  + [30.2.6. Testing OAuth 2.0 Clients](#3026-testing-oauth-20-clients)
  + [30.2.7. Testing JWT Authentication](#3027-testing-jwt-authentication)
  + [30.2.8. Testing Opaque Token Authentication](#3028-testing-opaque-token-authentication)

---

## 30.1. Testing Reactive Method Security

[EnableReactiveMethodSecurity](../enablereactivemethodsecurity)에서 다뤘던 예제는 [메소드 시큐리티 테스트](../testing#191-testing-method-security) 섹션에서 사용했던 설정과 애노테이션으로 똑같이 테스트할 수 있다. 여기서는 최소한의 샘플 코드만 보여주겠다:

```java
@RunWith(SpringRunner.class)
@ContextConfiguration(classes = HelloWebfluxMethodApplication.class)
public class HelloWorldMessageServiceTests {
    @Autowired
    HelloWorldMessageService messages;

    @Test
    public void messagesWhenNotAuthenticatedThenDenied() {
        StepVerifier.create(this.messages.findMessage())
            .expectError(AccessDeniedException.class)
            .verify();
    }

    @Test
    @WithMockUser
    public void messagesWhenUserThenDenied() {
        StepVerifier.create(this.messages.findMessage())
            .expectError(AccessDeniedException.class)
            .verify();
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    public void messagesWhenAdminThenOk() {
        StepVerifier.create(this.messages.findMessage())
            .expectNext("Hello World!")
            .verifyComplete();
    }
}
```

---

## 30.2. WebTestClientSupport

스프링 시큐리티는 `WebTestClient` 통합을 지원한다. 기본 설정은 다음과 같다:

```java
@RunWith(SpringRunner.class)
@ContextConfiguration(classes = HelloWebfluxMethodApplication.class)
public class HelloWebfluxMethodApplicationTests {
    @Autowired
    ApplicationContext context;

    WebTestClient rest;

    @Before
    public void setup() {
        this.rest = WebTestClient
            .bindToApplicationContext(this.context)
            // add Spring Security test Support
            .apply(springSecurity())
            .configureClient()
            .filter(basicAuthentication())
            .build();
    }
    // ...
}
```

### 30.2.1. Authentication

`WebTestClient`에 스프링 시큐리티 기능을 추가했으면 애노테이션이나 `mutateWith`를 사용할 수 있다. 예를 들어:

```java
@Test
public void messageWhenNotAuthenticated() throws Exception {
    this.rest
        .get()
        .uri("/message")
        .exchange()
        .expectStatus().isUnauthorized();
}

// --- WithMockUser ---

@Test
@WithMockUser
public void messageWhenWithMockUserThenForbidden() throws Exception {
    this.rest
        .get()
        .uri("/message")
        .exchange()
        .expectStatus().isEqualTo(HttpStatus.FORBIDDEN);
}

@Test
@WithMockUser(roles = "ADMIN")
public void messageWhenWithMockAdminThenOk() throws Exception {
    this.rest
        .get()
        .uri("/message")
        .exchange()
        .expectStatus().isOk()
        .expectBody(String.class).isEqualTo("Hello World!");
}

// --- mutateWith mockUser ---

@Test
public void messageWhenMutateWithMockUserThenForbidden() throws Exception {
    this.rest
        .mutateWith(mockUser())
        .get()
        .uri("/message")
        .exchange()
        .expectStatus().isEqualTo(HttpStatus.FORBIDDEN);
}

@Test
public void messageWhenMutateWithMockAdminThenOk() throws Exception {
    this.rest
        .mutateWith(mockUser().roles("ADMIN"))
        .get()
        .uri("/message")
        .exchange()
        .expectStatus().isOk()
        .expectBody(String.class).isEqualTo("Hello World!");
}
```

### 30.2.2. CSRF Support

`WebTestClient`로 CSRF도 테스트할 수 있다. 예를 들어:

```java
this.rest
    // provide a valid CSRF token
    .mutateWith(csrf())
    .post()
    .uri("/login")
    ...
```

### 30.2.3. Testing OAuth 2.0

OAuth 2.0에 관해서라면, 이전에 다룬 원칙이 그대로 적용된다: 궁극적으로 테스트할 메소드가 `SecurityContextHolder` 안에서 무엇을 사용하냐에 달렸다.

예를 들어 다음과 같은 컨트롤러가 있다면:

```java
@GetMapping("/endpoint")
public Mono<String> foo(Principal user) {
    return Mono.just(user.getName());
}
```

OAuth2에 특화된 코드가 없기 때문에 예상한대로 단순히 [`@WithMockUser`를 사용](#301-testing-reactive-method-security)하면 된다.

하지만 다음처럼 테스트하려는 컨트롤러가 스프링 시큐리티의 OAuth 2.0 기능을 사용한다면:

```java
@GetMapping("/endpoint")
public Mono<String> foo(@AuthenticationPrincipal OidcUser user) {
    return Mono.just(user.getIdToken().getSubject());
}
```

이럴땐 스프링 시큐리티의 테스트 기능이 유용하다.

### 30.2.4. Testing OIDC Login

`WebTestClient`로 위 메소드를 테스트하려면 인가 서버로 일종의 권한 부여 플로우를 시뮬레이션해야 한다. 시뮬레이션은 확실히 벅찬 일이다. 스프링 시큐리티는 이런 보일러플레이트 없이도 테스트할 수 있도록 지원한다.

예를 들어 아래처럼 `SecurityMockServerConfigurers#oidcLogin` 메소드를 사용해서 스프링 시큐리티에 디폴트 `OidcUser`를 추가할 수 있다:

```java
client
    .mutateWith(mockOidcLogin()).get().uri("/endpoint").exchange();
```

이렇게 하면 관련 `MockServerRequest`에, 간단한 `OidcIdToken`과 `OidcUserInfo`, 부여받은 권한 `Collection`을 가지고 있는 `OidcUser`를 설정한다.

특히, `OidcIdToken`에 `user`라는 `sub` 클레임을 추가해 준다:

```java
assertThat(user.getIdToken().getClaim("sub")).isEqualTo("user");
```

클레임 셋이 없는 `OidcUserInfo`도 추가되며:

```java
assertThat(user.getUserInfo().getClaims()).isEmpty();
```

`SCOPE_read` 하나를 가지고 있는 권한 `Collection`도 설정된다:

```java
assertThat(user.getAuthorities()).hasSize(1);
assertThat(user.getAuthorities()).containsExactly(new SimpleGrantedAuthority("SCOPE_read"));
```

스프링 시큐리티는 `OidcUser` 인스턴스를 [`@AuthenticationPrincipal` 애노테이션](../integrations#1563-authenticationprincipal)에서 사용할 수 있도록 필요한 일을 해준다.

게다가 `OidcUser`를 `WebSessionOAuth2ServerAuthorizedClientRepository`에 보관하는 간단한 `OAuth2AuthorizedClient` 인스턴스로 연결해 준다. [`@RegisteredOAuth2AuthorizedClient` 애노테이션을 사용](#3026-testing-oauth-20-clients)해서 테스트할 때 유용하다.

#### Configuring Authorities

많은 경우에 메소드를 필터나 메소드 시큐리티로 보호하고 있으며, 요청을 허용하려면 `Authentication`에 특정 권한을 부여해야 한다.

이럴땐 `authorities()` 메소드로 필요한 권한을 부여할 수 있다:

```java
client
    .mutateWith(mockOidcLogin()
        .authorities(new SimpleGrantedAuthority("SCOPE_message:read"))
    )
    .get().uri("/endpoint").exchange();
```

#### Configuring Claims

권한 부여는 스프링 시큐리티에서 전반적으로 다루고 있지만, OAuth 2.0에는 클레임이란 개념도 있다.

예를 들어 시스템 내 사용자의 ID를 나타내는 `user_id` 클레임이 있다고 해보자. 컨트롤러에서는 다음과 같이 클레임에 접근할 수 있다:

```java
@GetMapping("/endpoint")
public Mono<String> foo(@AuthenticationPrincipal OidcUser oidcUser) {
    String userId = oidcUser.getIdToken().getClaim("user_id");
    // ...
}
```

이럴땐 `idToken()` 메소드로 클레임을 지정할 수 있다:

```java
client
    .mutateWith(mockOidcLogin()
        .idToken(token -> token.claim("user_id", "1234"))
    )
    .get().uri("/endpoint").exchange();
```

이렇게 하면 `OidcUser`는 `OidcIdToken`에서 클레임을 수집할 수 있다.

#### Additional Configurations

다른 메소드로도 인증 정보를 설정할 수 있다. 컨트롤러에서 사용하는 데이터에 따라 필요한 메소드를 사용하면 된다.

- `userInfo(OidcUserInfo.Builder)` - `OidcUserInfo` 인스턴스 설정
- `clientRegistration(ClientRegistration)` - `ClientRegistration`으로 관련 `OAuth2AuthorizedClient` 설정
- `oidcUser(OidcUser)` - 완전한 `OidcUser` 인스턴스 설정

마지막 메소드는 1. `OidcUser` 자체 구현체를 쓰거나, 2. name 속성을 바꿔야 할 때 유용하다.

예를 들어 인가 서버에서 principal 이름을 `sub` 클레임이 아닌 `user_name` 클레임으로 전송한다고 가정해보자. 이럴땐 직접 만든 `OidcUser`를 설정할 수 있다:

```java
OidcUser oidcUser = new DefaultOidcUser(
        AuthorityUtils.createAuthorityList("SCOPE_message:read"),
        Collections.singletonMap("user_name", "foo_user"),
        "user_name");

client
    .mutateWith(mockOidcLogin().oidcUser(oidcUser))
    .get().uri("/endpoint").exchange();
```

### 30.2.5. Testing OAuth 2.0 Login

[OIDC 로그인 테스트](#3024-testing-oidc-login)와 마찬가지로, OAuth 2.0 로그인에서도 유사하게 권한 부여 플로우를 모킹해야 한다. 꽤나 까다로운 일이기 때문에, 스프링 시큐리티는 OIDC 외에 다른 테스트도 지원한다.

로그인한 사용자 정보를 `OAuth2User`로 받는 컨트롤러가 있다고 가정해보자:

```java
@GetMapping("/endpoint")
public Mono<String> foo(@AuthenticationPrincipal OAuth2User oauth2User) {
    return Mono.just(oauth2User.getAttribute("sub"));
}
```

이럴땐 아래처럼 `SecurityMockServerConfigurers#oauth2User` 메소드를 사용해서 스프링 시큐리티에 디폴트 `OAuth2User`를 추가할 수 있다:

```java
client
    .mutateWith(mockOAuth2Login())
    .get().uri("/endpoint").exchange();
```

이렇게 하면 관련 `MockServerRequest`에, 간단한 속성 `Map`과 부여받은 권한 `Collection`을 가지고 있는 `OAuth2User`를 설정한다.

특히, `Map`에 키/값 `sub`/`user`를 추가해 준다:

```java
assertThat((String) user.getAttribute("sub")).isEqualTo("user");
```

`SCOPE_read` 하나를 가지고 있는 권한 `Collection`도 설정된다:

```java
assertThat(user.getAuthorities()).hasSize(1);
assertThat(user.getAuthorities()).containsExactly(new SimpleGrantedAuthority("SCOPE_read"));
```

스프링 시큐리티는 `OAuth2User` 인스턴스를 [`@AuthenticationPrincipal` 애노테이션](../integrations#1563-authenticationprincipal)에서 사용할 수 있도록 필요한 일을 해준다.

게다가 `OAuth2User`를 `WebSessionOAuth2ServerAuthorizedClientRepository`에 보관하는 간단한 `OAuth2AuthorizedClient` 인스턴스로 연결해 준다. [`@RegisteredOAuth2AuthorizedClient` 애노테이션을 사용](#3026-testing-oauth-20-clients)해서 테스트할 때 유용하다.

#### Configuring Authorities

많은 경우에 메소드를 필터나 메소드 시큐리티로 보호하고 있으며, 요청을 허용하려면 `Authentication`에 특정 권한을 부여해야 한다.

이럴땐 `authorities()` 메소드로 필요한 권한을 부여할 수 있다:

```java
client
    .mutateWith(mockOAuth2Login()
        .authorities(new SimpleGrantedAuthority("SCOPE_message:read"))
    )
    .get().uri("/endpoint").exchange();
```

#### Configuring Claims

권한 부여는 스프링 시큐리티에서 전반적으로 다루고 있지만, OAuth 2.0에는 클레임이란 개념도 있다.

예를 들어 시스템 내 사용자의 ID를 나타내는 `user_id` 속성이 있다고 해보자. 컨트롤러에서는 다음과 같이 속성에 접근할 수 있다:

```java
@GetMapping("/endpoint")
public Mono<String> foo(@AuthenticationPrincipal OAuth2User oauth2User) {
    String userId = oauth2User.getAttribute("user_id");
    // ...
}
```

이럴땐 `attributes()` 메소드로 속성을 지정할 수 있다:

```java
client
    .mutateWith(mockOAuth2Login()
        .attributes(attrs -> attrs.put("user_id", "1234"))
    )
    .get().uri("/endpoint").exchange();
```

#### Additional Configurations

다른 메소드로도 인증 정보를 설정할 수 있다. 컨트롤러에서 사용하는 데이터에 따라 필요한 메소드를 사용하면 된다.

- `clientRegistration(ClientRegistration)` - `ClientRegistration`으로 관련 `OAuth2AuthorizedClient` 설정
- `oauth2User(OAuth2User)` - 완전한 `OAuth2User` 인스턴스 설정

마지막 메소드는 1. `OAuth2User` 자체 구현체를 쓰거나, 2. name 속성을 바꿔야 할 때 유용하다.

예를 들어 인가 서버에서 principal 이름을 `sub` 클레임이 아닌 `user_name` 클레임으로 전송한다고 가정해보자. 이럴땐 직접 만든 `OAuth2User`를 설정할 수 있다:

```java
OAuth2User oauth2User = new DefaultOAuth2User(
        AuthorityUtils.createAuthorityList("SCOPE_message:read"),
        Collections.singletonMap("user_name", "foo_user"),
        "user_name");

client
    .mutateWith(mockOAuth2Login().oauth2User(oauth2User))
    .get().uri("/endpoint").exchange();
```

### 30.2.6. Testing OAuth 2.0 Clients

사용자를 인증하는 방법과는 상관 없이, 테스트하고 싶은 요청에서 다른 토큰과 클라이언트 등록 정보를 사용할 수도 있다. 예를 들어 컨트롤러에서 클라이언트에 부여한 credential로 사용자 아무런 연관이 없는 토큰을 가져올 수 있다:

```java
@GetMapping("/endpoint")
public Mono<String> foo(@RegisteredOAuth2AuthorizedClient("my-app") OAuth2AuthorizedClient authorizedClient) {
    return this.webClient.get()
        .attributes(oauth2AuthorizedClient(authorizedClient))
        .retrieve()
        .bodyToMono(String.class);
}
```

인가 서버와의 핸드셰이킹을 시뮬레이션하긴 번거롭다. 대신에 `SecurityMockServerConfigurers#oauth2Client`를 사용해서 `WebSessionOAuth2ServerAuthorizedClientRepository`에 `OAuth2AuthorizedClient`를 추가할 수 있다:

```java
client
    .mutateWith(mockOAuth2Client("my-app"))
    .get().uri("/endpoint").exchange();
```

어플리케이션에서 사용 중인 `WebSessionOAuth2ServerAuthorizedClientRepository`가 없다면 `@TestConfiguration`에 하나를 등록할 수 있다:

```java
@TestConfiguration
static class AuthorizedClientConfig {
    @Bean
    OAuth2ServerAuthorizedClientRepository authorizedClientRepository() {
        return new WebSessionOAuth2ServerAuthorizedClientRepository();
    }
}
```

이렇게 하면 간단한 `ClientRegistration`, `OAuth2AccessToken`, 리소스 소유자 이름을 가지고 있는 `OAuth2AuthorizedClient`를 생성한다.

특히 `ClientRegistration`에 클라이언트 ID "test-client", 클라이언트 secret "test-secret"을 가지고 있는 `ClientRegistration`을 추가해 준다

```java
assertThat(authorizedClient.getClientRegistration().getClientId()).isEqualTo("test-client");
assertThat(authorizedClient.getClientRegistration().getClientSecret()).isEqualTo("test-secret");
```

리소스 소유자 이름 "user"도 추가되며:

```java
assertThat(authorizedClient.getPrincipalName()).isEqualTo("user");
```

`read` 스코프 하나를 가지고 있는 `OAuth2AccessToken`도 설정된다:

```java
assertThat(authorizedClient.getAccessToken().getScopes()).hasSize(1);
assertThat(authorizedClient.getAccessToken().getScopes()).containsExactly("read");
```

스프링 시큐리티는 `OAuth2AuthorizedClient` 인스턴스를 관련 `HttpSession`에서 사용할 수 있도록 필요한 일을 해준다. 덕분에 `WebSessionOAuth2ServerAuthorizedClientRepository`에서 `OAuth2AuthorizedClient`를 조회할 수 있다.

#### Configuring Scopes

OAuth 2.0 액세스 토큰은 흔히 스코프 셋을 함께 제공한다. 컨트롤러에선 다음과 같이 스코프를 참조할 수 있다:

```java
@GetMapping("/endpoint")
public Mono<String> foo(@RegisteredOAuth2AuthorizedClient("my-app") OAuth2AuthorizedClient authorizedClient) {
    Set<String> scopes = authorizedClient.getAccessToken().getScopes();
    if (scopes.contains("message:read")) {
        return this.webClient.get()
            .attributes(oauth2AuthorizedClient(authorizedClient))
            .retrieve()
            .bodyToMono(String.class);
    }
    // ...
}
```

스코프는 `accessToken()` 메소드로 설정할 수 있다:

```java
client
    .mutateWith(mockOAuth2Client("my-app")
        .accessToken(new OAuth2AccessToken(BEARER, "token", null, null, Collections.singleton("message:read"))))
    )
    .get().uri("/endpoint").exchange();
```

#### Additional Configurations

다른 메소드로도 인증 정보를 설정할 수 있다. 컨트롤러에서 사용하는 데이터에 따라 필요한 메소드를 사용하면 된다.

- `principalName(String)` - 리소스 소유자 이름 설정
- `clientRegistration(Consumer<ClientRegistration.Builder>)` - 관련 `ClientRegistration` 설정
- `clientRegistration(ClientRegistration)` - 완전한 `ClientRegistration` 설정

마지막 메소드는 실제 `ClientRegistration`을 사용하고 싶을 때 유용하다.

예를 들어 `application.yml`에 있는 어플리케이션의 `ClientRegistration` 정의 중 하나를 사용하고 싶다고 해보자.

이럴땐 테스트 코드에 `ReactiveClientRegistrationRepository`를 주입하면 필요한 빈을 찾아준다:

```java
@Autowired
ReactiveClientRegistrationRepository clientRegistrationRepository;

// ...

client
    .mutateWith(mockOAuth2Client()
        .clientRegistration(this.clientRegistrationRepository.findByRegistrationId("facebook"))
    )
    .get().uri("/exchange").exchange();
```

### 30.2.7. Testing JWT Authentication

리소스 서버에 권한을 부여받은 요청을 만들려면 bearer 토큰이 필요하다. 리소스 서버를 JWT로 설정했다면 bearer 토큰을 서명한 다음 JWT 스펙에 따라 인코딩해야 한다. 이 모든 일은 꽤나 벅찬 일이며, 특히나 테스트하려는 핵심 로직이 아닐 땐 더 그렇다.

다행히도 테스트 코드에선 bearer 토큰 표현 대신 간단히 인가 로직에만 집중할 수 있는 방법이 많이 있다. 여기서는 두 가지 방법을 살펴보겠다.

#### `mockJwt() WebTestClientConfigurer`

첫 번째 방법은 `WebTestClientConfigurer`를 사용하는 방법이다. 가장 간단하게는 아래처럼 사용할 수 있다:

```java
client
    .mutateWith(mockJwt()).get().uri("/endpoint").exchange();
```

이렇게 하면 관련 목 `Jwt`를 생성해서 인증 API로 넘겨주기 때문에, 인가 메커니즘 검증에 활용할 수 있다.

디폴트 `JWT`는 다음과 같이 생성한다:

```json
{
  "headers" : { "alg" : "none" },
  "claims" : {
    "sub" : "user",
    "scope" : "read"
  }
}
```

테스트를 실행하면 결과적으로 다음과 같은 `Jwt`를 전달한다:

```java
assertThat(jwt.getTokenValue()).isEqualTo("token");
assertThat(jwt.getHeaders().get("alg")).isEqualTo("none");
assertThat(jwt.getSubject()).isEqualTo("sub");
GrantedAuthority authority = jwt.getAuthorities().iterator().next();
assertThat(authority.getAuthority()).isEqualTo("read");
```

물론 이 값들도 설정할 수 있다.

헤더나 클레임은 전용 메소드를 사용해 설정한다:

```java
client
    .mutateWith(mockJwt().jwt(jwt -> jwt.header("kid", "one")
        .claim("iss", "https://idp.example.org")))
    .get().uri("/endpoint").exchange();
client
    .mutateWith(mockJwt().jwt(jwt -> jwt.claims(claims -> claims.remove("scope"))))
    .get().uri("/endpoint").exchange();
```

여기선 일반 bearer 토큰 요청과 동일하게 `scope`, `scp` 클레임을 처리한다. 하지만 테스트에 필요한 `GrantedAuthority` 인스턴스 목록을 제공해서 간단히 재정의할 수 있다:

```java
client
    .mutateWith(jwt().authorities(new SimpleGrantedAuthority("SCOPE_messages")))
    .get().uri("/endpoint").exchange();
```

또는 `Jwt`를 `Collection<GrantedAuthority>`로 변환하는 커스텀 컨버터로도 권한을 생성할 수 있다:

```java
client
    .mutateWith(jwt().authorities(new MyConverter()))
    .get().uri("/endpoint").exchange();
```

`Jwt.Builder`를 사용해서 `Jwt`를 직접 만들 수도 있다:

```java
Jwt jwt = Jwt.withTokenValue("token")
    .header("alg", "none")
    .claim("sub", "user")
    .claim("scope", "read");

client
    .mutateWith(mockJwt().jwt(jwt))
    .get().uri("/endpoint").exchange();
```

#### `authentication()` `WebTestClientConfigurer`

두 번째 방법은 `authentication()` `Mutator`를 사용하는 방법이다. 기본적으로 아래 코드처럼 직접 만든 `JwtAuthenticationToken` 인스턴스를 테스트에 제공할 수 있다:

```java
Jwt jwt = Jwt.withTokenValue("token")
    .header("alg", "none")
    .claim("sub", "user")
    .build();
Collection<GrantedAuthority> authorities = AuthorityUtils.createAuthorityList("SCOPE_read");
JwtAuthenticationToken token = new JwtAuthenticationToken(jwt, authorities);

client
    .mutateWith(authentication(token))
    .get().uri("/endpoint").exchange();
```

이 두 가지 방법 외에도 `@MockBean` 애노테이션으로 `ReactiveJwtDecoder` 빈 자체를 모킹하는 방법도 있다.

### 30.2.8. Testing Opaque Token Authentication

opaque 토큰도 [JWT](#3027-testing-jwt-authentication)와 유사하게 유효성 검증을 위해서는 인가 서버가 필요하므로, 테스트하기가 더 까다롭다. 이를 위해 스프링 시큐리티는 opaque 토큰을 위한 테스트 기능을 지원한다.

`BearerTokenAuthentication`으로 인증 정보를 가져오는 컨트롤러가 있다고 가정해보자:

```java
@GetMapping("/endpoint")
public Mono<String> foo(BearerTokenAuthentication authentication) {
    return Mono.just((String) authentication.getTokenAttributes("sub"));
}
```

이럴땐 아래처럼 `SecurityMockServerConfigurers#opaqueToken` 메소드를 사용해서 스프링 시큐리티에 디폴트 `BearerTokenAuthentication`을 추가할 수 있다:

```java
client
    .mutateWith(mockOpaqueToken())
    .get().uri("/endpoint").exchange();
```

이렇게 하면 관련 `MockHttpServletRequest`에, 간단한 `OAuth2AuthenticatedPrincipal`과, 속성 `Map`, 부여받은 권한 `Collection`을 가지고 있는 `BearerTokenAuthentication`을 설정한다.

특히, `Map`에 키/값 `sub`/`user`를 추가해 준다:

```java
assertThat((String) token.getTokenAttributes().get("sub")).isEqualTo("user");
```

`SCOPE_read` 하나를 가지고 있는 권한 `Collection`도 설정된다:

```java
assertThat(token.getAuthorities()).hasSize(1);
assertThat(token.getAuthorities()).containsExactly(new SimpleGrantedAuthority("SCOPE_read"));
```

스프링 시큐리티는 `BearerTokenAuthentication` 인스턴스를 컨트롤러 메소드에서 사용할 수 있도록 필요한 일을 해준다.

#### Configuring Authorities

많은 경우에 메소드를 필터나 메소드 시큐리티로 보호하고 있으며, 요청을 허용하려면 `Authentication`에 특정 권한을 부여해야 한다.

이럴땐 `authorities()` 메소드로 필요한 권한을 부여할 수 있다:

```java
client
    .mutateWith(mockOpaqueToken()
        .authorities(new SimpleGrantedAuthority("SCOPE_message:read"))
    )
    .get().uri("/endpoint").exchange();
```

#### Configuring Claims

권한 부여는 스프링 시큐리티에서 전반적으로 다루고 있지만, OAuth 2.0에는 속성이란 개념도 있다.

예를 들어 시스템 내 사용자의 ID를 나타내는 `user_id` 속성이 있다고 해보자. 컨트롤러에서는 다음과 같이 속성에 접근할 수 있다:

```java
@GetMapping("/endpoint")
public Mono<String> foo(BearerTokenAuthentication authentication) {
    String userId = (String) authentication.getTokenAttributes().get("user_id");
    // ...
}
```

이럴땐 `attributes()` 메소드로 속성을 지정할 수 있다:

```java
client
    .mutateWith(mockOpaqueToken()
        .attributes(attrs -> attrs.put("user_id", "1234"))
    )
    .get().uri("/endpoint").exchange();
```

#### Additional Configurations

다른 메소드로도 인증 정보를 설정할 수 있다. 컨트롤러에서 사용하는 데이터에 따라 필요한 메소드를 사용하면 된다.

한 가지 메소드는 `BearerTokenAuthentication`에 넣을 `OAuth2AuthenticatedPrincipal` 인스턴스를 직접 설정할 수 있는 `principal(OAuth2AuthenticatedPrincipal)`이다.

이 메소드는 1. `OAuth2AuthenticatedPrincipal` 자체 구현체를 쓰거나, 2. principal 이름을 바꿔야 할 때 유용하다.

예를 들어 인가 서버에서 principal 이름을 `sub` 속성이 아닌 `user_name` 속성으로 전송한다고 가정해보자. 이럴땐 직접 만든 `OAuth2AuthenticatedPrincipal`을 설정할 수 있다:

```java
Map<String, Object> attributes = Collections.singletonMap("user_name", "foo_user");
OAuth2AuthenticatedPrincipal principal = new DefaultOAuth2AuthenticatedPrincipal(
        (String) attributes.get("user_name"),
        attributes,
        AuthorityUtils.createAuthorityList("SCOPE_message:read"));

client
    .mutateWith(mockOpaqueToken().principal(principal))
    .get().uri("/endpoint").exchange();
```

`mockOpaqueToken()`을 사용하는 방법 외에도 `@MockBean` 애노테이션으로 `OpaqueTokenIntrospector` 빈 자체를 모킹하는 방법도 있다.

