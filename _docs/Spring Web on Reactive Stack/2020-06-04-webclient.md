---
title: WebClient
category: Spring Web on Reactive Stack
order: 4
permalink: /Reactive%20Spring/webclient/
description: 스프링5 웹 리액티브 스택 WebClient 한글 번역
image: ./../../images/reactivespring/spring-mvc-and-webflux-venn.png
lastmod: 2020-07-12T16:00:00+09:00
---
<script>var switchLanguage=true</script>

> [리액티브 스프링 공식 reference](https://docs.spring.io/spring/docs/current/spring-framework-reference/web-reactive.html#webflux-client)를 한글로 번역한 문서입니다.
>
> 전체 목차는 [여기](https://godekdls.github.io/Reactive%20Spring/contents/)에 있습니다.

### 목차

- [2.1. Configuration](#21-configuration)
  + [2.1.1. MaxInMemorySize](#211-maxinmemorysize)
  + [2.1.2. Reactor Netty](#212-reactor-netty)
    + [Resources](#resources)
    + [Timeouts](#timeouts)
  + [2.1.3. Jetty](#213-jetty)
- [2.2. retrieve()](#22-retrieve)
- [2.3. exchange()](#23-exchange)
- [2.4. Request Body](#24-request-body)
  + [2.4.1. Form Data](#241-form-data)
  + [2.4.2. Multipart Data](#242-multipart-data)
- [2.5. Client Filters](#25-client-filters)
- [2.6. Synchronous Use](#26-synchronous-use)
- [2.7. Testing](#27-testing)

---

스프링 웹플럭스는 리액티브, 논블로킹 HTTP 요청을 위한 `WebClient`를 제공한다. 웹 클라이언트는 리액티브 타입을 사용하는 함수형 API기 때문에 선언적인(declarative) 프로그래밍이 가능하다([리액티브 라이브러리](https://godekdls.github.io/Reactive%20Spring/reactivelibraries/) 참고). 웹플럭스 클라이언트와 서버는 동일한 논블로킹 [코덱](https://godekdls.github.io/Reactive%20Spring/springwebflux/#125-codecs)으로 요청/응답을 인코딩/디코딩한다.

`WebClient` 내부에선 HTTP 클라언트 라이브러리에 처리를 위임한다. 디폴트는 [Reactor Netty](https://github.com/reactor/reactor-netty)를 사용하고, Jetty [reactive HttpClient](https://github.com/jetty-project/jetty-reactive-httpclient)를 기본으로 제공하며, 다른 라이브러리는 `ClientHttpConnector`에 등록할 수 있다.

---

## 2.1. Configuration

`WebClient`는 가장 간단하게는 스태틱 팩토리 메소드로 만들 수 있다:

- `WebClient.create()`
- `WebClient.create(String baseUrl)`

위 메소드는 디폴트 세팅으로 Reactor Netty `HttpClient`를 사용하므로, 클래스패스에 `io.projectreactor.netty:reactor-netty`가 있어야 한다.

다른 옵션을 사용하려면 `WebClient.builder()`를 사용한다:

- `uriBuilderFactory`: base URL을 커스텀한 `UriBuilderFactory`.
- `defaultHeader`: 모든 요청에 사용할 헤더.
- `defaultCookie`: 모든 요청에 사용할 쿠키.
- `defaultRequest`: 모든 요청을 커스텀할 `Consumer`.
- `filter`: 모든 요청에 사용할 클라이언트 필터.
- `exchangeStrategies`: HTTP 메세지 reader/writer 커스텀.
- `clientConnector`: HTTP 클라이언트 라이브러리 세팅.

다음 예제는 [HTTP 코덱](https://godekdls.github.io/Reactive%20Spring/springwebflux/#125-codecs)을 설정한다:

<div class="switch-language-wrapper">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java"></div>
```java
WebClient client = WebClient.builder()
      .exchangeStrategies(builder -> {
              return builder.codecs(codecConfigurer -> {
                  //...
              });
      })
      .build();
```
<div class="language-only-for-kotlin"></div>
```kotlin
val webClient = WebClient.builder()
      .exchangeStrategies { strategies ->
          strategies.codecs {
              //...
          }
      }
      .build()
```

`WebClient`는 한 번 빌드하고 나면 상태를 변경할 수 없다(immutable). 단, 다음 예제처럼 원본 인스턴스는 그대로 두고 복사해 와서 설정을 추가할 수는 있다:

<div class="switch-language-wrapper">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java"></div>
```java
WebClient client1 = WebClient.builder()
      .filter(filterA).filter(filterB).build();

WebClient client2 = client1.mutate()
      .filter(filterC).filter(filterD).build();

// client1 has filterA, filterB

// client2 has filterA, filterB, filterC, filterD
```
<div class="language-only-for-kotlin"></div>
```kotlin
val client1 = WebClient.builder()
      .filter(filterA).filter(filterB).build()

val client2 = client1.mutate()
      .filter(filterC).filter(filterD).build()

// client1 has filterA, filterB

// client2 has filterA, filterB, filterC, filterD
```

### 2.1.1. MaxInMemorySize

스프링 웹플럭스는 어플리케이션 메모리 이슈를 방지하기 위해 코덱의 메모리 버퍼 사이즈를 [제한](https://godekdls.github.io/Reactive%20Spring/springwebflux/#limits)한다. 디폴트는 256KB로 설정돼 있는데, 버퍼가 부족하면 다음과 같은 에러가 보일 것이다:

```
org.springframework.core.io.buffer.DataBufferLimitException: Exceeded limit on max bytes to buffer
```

다음 코드를 사용하면 모든 디폴트 코덱의 최대 버퍼 사이즈를 조절할 수 있다:

<div class="switch-language-wrapper">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java"></div>
```java
WebClient webClient = WebClient.builder()
      .exchangeStrategies(builder ->
          builder.codecs(codecs ->
              codecs.defaultCodecs().maxInMemorySize(2 * 1024 * 1024)
          )
      )
      .build();
```
<div class="language-only-for-kotlin"></div>
```kotlin
val webClient = WebClient.builder()
  .exchangeStrategies { builder ->
          builder.codecs {
              it.defaultCodecs().maxInMemorySize(2 * 1024 * 1024)
          }
  }
  .build()
```

### 2.1.2. Reactor Netty

`HttpClient`는 Reactor Netty 설정을 커스텀할 수 있는 간단한 설정 프리셋을 가지고 있다:

<div class="switch-language-wrapper">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java"></div>
```java
HttpClient httpClient = HttpClient.create().secure(sslSpec -> ...);

WebClient webClient = WebClient.builder()
      .clientConnector(new ReactorClientHttpConnector(httpClient))
      .build();
```
<div class="language-only-for-kotlin"></div>
```kotlin
val httpClient = HttpClient.create().secure { ... }

val webClient = WebClient.builder()
  .clientConnector(ReactorClientHttpConnector(httpClient))
  .build()
```

#### Resources

기본적으로 `HttpClient`는 `reactor.netty.http.HttpResources`에 묶여 있는 Reactor Netty의 글로벌 리소스를 사용한다. 이는 이벤트 루프 쓰레드와 커넥션 풀도 포함한다. 이벤트 루프로 동시성을 제어하려면 공유 리소스를 고정해 놓고 사용하는 게 좋기 때문에 권장하는 모드다. 이 모드에선 프로세스가 종료될 때까지 공유 자원을 active상태로 유지한다.

서버가 프로세스와 함께 중단된다면 명시적으로 리소스를 종료시킬 필요는 없다. 하지만 프로세스 내에서 서버를 시작하거나 중단할 수 있다면(e.g. WAR로 배포한 스프링 MVC 어플리케이션), 다음 예제처럼 스프링이 관리하는 `ReactorResourceFactory`빈을 `globalResources=true`(디폴트)로 선언해야 스프링 `ApplicationContext`를 닫을 때 Reactor Netty 글로벌 리소스도 종료한다:

<div class="switch-language-wrapper">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java"></div>
```java
@Bean
public ReactorResourceFactory reactorResourceFactory() {
  return new ReactorResourceFactory();
}
```
<div class="language-only-for-kotlin"></div>
```kotlin
@Bean
fun reactorResourceFactory() = ReactorResourceFactory()
```

원한다면 글로벌 Reactor Netty 리소스를 사용하지 않게 만들 수도 있다. 하지만 이 모드에선, 다음 예제처럼 직접 모든 Reactor Netty 클라이언트와 서버 인스턴스가 공유 자원을 사용하게 만들어야 한다.

<div class="switch-language-wrapper">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java"></div>
```java
@Bean
public ReactorResourceFactory resourceFactory() {
  ReactorResourceFactory factory = new ReactorResourceFactory();
  factory.setUseGlobalResources(false); // (1)
  return factory;
}

@Bean
public WebClient webClient() {

  Function<HttpClient, HttpClient> mapper = client -> {
      // Further customizations...
  };

  ClientHttpConnector connector =
          new ReactorClientHttpConnector(resourceFactory(), mapper); // (2)

  return WebClient.builder().clientConnector(connector).build(); // (3)
}
```
<div class="language-only-for-kotlin"></div>
```kotlin
@Bean
fun resourceFactory() = ReactorResourceFactory().apply {
  isUseGlobalResources = false // (1)
}

@Bean
fun webClient(): WebClient {

  val mapper: (HttpClient) -> HttpClient = {
      // Further customizations...
  }

  val connector = ReactorClientHttpConnector(resourceFactory(), mapper) // (2)

  return WebClient.builder().clientConnector(connector).build() // (3)
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 글로벌 리소스와는 독립적인 리소스를 만든다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 리소스 팩토리로 `ReactorClientHttpConnector`를 만든다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 커넥터를 `WebClient.Builder`에 주입한다.</small>

#### Timeouts

다음은 커넥션 타임아웃을 설정하는 코드다:

<div class="switch-language-wrapper">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java"></div>
```java
import io.netty.channel.ChannelOption;

HttpClient httpClient = HttpClient.create()
      .tcpConfiguration(client ->
              client.option(ChannelOption.CONNECT_TIMEOUT_MILLIS, 10000));
```
<div class="language-only-for-kotlin"></div>
```kotlin
import io.netty.channel.ChannelOption

val httpClient = HttpClient.create()
      .tcpConfiguration { it.option(ChannelOption.CONNECT_TIMEOUT_MILLIS, 10000)}
```

다음은 read/write 타임아웃을 설정한다:

<div class="switch-language-wrapper">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java"></div>
```java
import io.netty.handler.timeout.ReadTimeoutHandler;
import io.netty.handler.timeout.WriteTimeoutHandler;

HttpClient httpClient = HttpClient.create()
      .tcpConfiguration(client ->
              client.doOnConnected(conn -> conn
                      .addHandlerLast(new ReadTimeoutHandler(10))
                      .addHandlerLast(new WriteTimeoutHandler(10))));
```
<div class="language-only-for-kotlin"></div>
```kotlin
import io.netty.handler.timeout.ReadTimeoutHandler
import io.netty.handler.timeout.WriteTimeoutHandler

val httpClient = HttpClient.create().tcpConfiguration {
  it.doOnConnected { conn -> conn
          .addHandlerLast(ReadTimeoutHandler(10))
          .addHandlerLast(WriteTimeoutHandler(10))
  }
}
```

### 2.1.3. Jetty

다음은 Jetty `HttpClient` 설정을 커스텀하는 예제다:

<div class="switch-language-wrapper">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java"></div>
```java
HttpClient httpClient = new HttpClient();
httpClient.setCookieStore(...);
ClientHttpConnector connector = new JettyClientHttpConnector(httpClient);

WebClient webClient = WebClient.builder().clientConnector(connector).build();
```
<div class="language-only-for-kotlin"></div>
```kotlin
val httpClient = HttpClient()
httpClient.cookieStore = ...
val connector = JettyClientHttpConnector(httpClient)

val webClient = WebClient.builder().clientConnector(connector).build();
```

`HttpClient`는 전용 리소스(`Executor`, `ByteBufferPool`, `Scheduler`)를 생성해서 기본적으로 프로세스가 종료되거나 `stop()`을 호출할 때 까지 유지한다.

다음 예제처럼 스프링이 관리하는 `JettyResourceFactory` 빈을 정의하면, 여러 Jetty 클라이언트(그리고 서버도) 인스턴스에서 리소스를 공유할 수 있고, 스프링 `ApplicationContext`를 닫을 때 리소스도 종료시킬 수 있다:

<div class="switch-language-wrapper">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java"></div>
```java
@Bean
public JettyResourceFactory resourceFactory() {
  return new JettyResourceFactory();
}

@Bean
public WebClient webClient() {

  HttpClient httpClient = new HttpClient();
  // Further customizations...

  ClientHttpConnector connector =
          new JettyClientHttpConnector(httpClient, resourceFactory()); // (1)

  return WebClient.builder().clientConnector(connector).build(); // (2)
}
```
<div class="language-only-for-kotlin"></div>
```kotlin
@Bean
fun resourceFactory() = JettyResourceFactory()

@Bean
fun webClient(): WebClient {

  val httpClient = HttpClient()
  // Further customizations...

  val connector = JettyClientHttpConnector(httpClient, resourceFactory()) // (1)

  return WebClient.builder().clientConnector(connector).build() // (2)
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 리소스 팩토리로 `JettyClientHttpConnector`를 만든다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 커넥터를 `WebClient.Builder`에 주입한다.</small>

---

## 2.2. `retrieve()`

`retrieve()`는 response body를 받아 디코딩하는 가장 간단한 메소드다. 사용 방법은 다음 예제에 있다:

<div class="switch-language-wrapper">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java"></div>
```java
WebClient client = WebClient.create("https://example.org");

Mono<Person> result = client.get()
      .uri("/persons/{id}", id).accept(MediaType.APPLICATION_JSON)
      .retrieve()
      .bodyToMono(Person.class);
```
<div class="language-only-for-kotlin"></div>
```kotlin
val client = WebClient.create("https://example.org")

val result = client.get()
      .uri("/persons/{id}", id).accept(MediaType.APPLICATION_JSON)
      .retrieve()
      .awaitBody<Person>()
```

다음 예제처럼 응답을 객체 스트림으로도 디코딩할 수 있다:

<div class="switch-language-wrapper">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java"></div>
```java
Flux<Quote> result = client.get()
      .uri("/quotes").accept(MediaType.TEXT_EVENT_STREAM)
      .retrieve()
      .bodyToFlux(Quote.class);
```
<div class="language-only-for-kotlin"></div>
```kotlin
val result = client.get()
      .uri("/quotes").accept(MediaType.TEXT_EVENT_STREAM)
      .retrieve()
      .bodyToFlow<Quote>()
```

4xx, 5xx 응답 코드를 받으면 디폴트는 `WebClientResponseException` 또는 각 HTTP 상태에 해당하는 `WebClientResponseException.BadRequest`, `WebClientResponseException.NotFound` 등의 하위 exception을 던진다. 다음 예제처럼 `onStatus` 메소드로 상태별 exception을 커스텀할 수도 있다:

<div class="switch-language-wrapper">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java"></div>
```java
Mono<Person> result = client.get()
      .uri("/persons/{id}", id).accept(MediaType.APPLICATION_JSON)
      .retrieve()
      .onStatus(HttpStatus::is4xxClientError, response -> ...)
      .onStatus(HttpStatus::is5xxServerError, response -> ...)
      .bodyToMono(Person.class);
```
<div class="language-only-for-kotlin"></div>
```kotlin
val result = client.get()
      .uri("/persons/{id}", id).accept(MediaType.APPLICATION_JSON)
      .retrieve()
      .onStatus(HttpStatus::is4xxClientError) { ... }
      .onStatus(HttpStatus::is5xxServerError) { ... }
      .awaitBody<Person>()
```

`onStatus`를 사용할 땐, response에 body가 있다면 `onStatus` 콜백에서 소비해야 한다. 그렇지 않으면 리소스 반환을 위해 body를 자동으로 비운다.

---

## 2.3. `exchange()`

`exchange()` 메소드는 `retrieve`보다 더 많은 기능을 제공한다. 다음 예제는 `retrieve()` 예제와 동일하지만, `ClientResponse`에 접근한다:

<div class="switch-language-wrapper">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java"></div>
```java
Mono<Person> result = client.get()
      .uri("/persons/{id}", id).accept(MediaType.APPLICATION_JSON)
      .exchange()
      .flatMap(response -> response.bodyToMono(Person.class));
```
<div class="language-only-for-kotlin"></div>
```kotlin
val result = client.get()
      .uri("/persons/{id}", id).accept(MediaType.APPLICATION_JSON)
      .awaitExchange()
      .awaitBody<Person>()
```

같은 레벨에서 `ResponseEntity`를 만들 수도 있다:

<div class="switch-language-wrapper">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java"></div>
```java
Mono<ResponseEntity<Person>> result = client.get()
      .uri("/persons/{id}", id).accept(MediaType.APPLICATION_JSON)
      .exchange()
      .flatMap(response -> response.toEntity(Person.class));
```
<div class="language-only-for-kotlin"></div>
```kotlin
val result = client.get()
      .uri("/persons/{id}", id).accept(MediaType.APPLICATION_JSON)
      .awaitExchange()
      .toEntity<Person>()
```

`exchange()`는 `retrieve()`와는 달리 4xx, 5xx 응답을 자동으로 에러로 처리해주지 않는다. 직접 상태 코드를 확인하고 어떻게 처리할지 결정해야 한다.

>  `retrieve()`와는 다르게 `exchange()`는 모든 시나리오에서(성공, 오류, 예기치 못한 데이터 등) 어플리케이션이 직접 response body를 consume해야 한다. 그렇지 않으면 메모리 릭이 발생할 수 있다. `ClientResponse` javadoc에 body를 consume할 수 있는 모든 옵션이 나와 있다. `exchange()`를 사용해서 응답 코드나 헤더를 봐야 로직을 결정할 수 있다거나, 아니면 직접 응답을 consume해야 한다거나 하는 특별한 이유가 없다면 `retrieve()`를 쓰는 게 좋다.

---

## 2.4. Request Body

request body는 `Mono`, 코틀린 코루틴 `Deferred` 등 `ReactiveAdapterRegistry`에 등록한 모든 비동기 타입으로 인코딩할 수 있다:

<div class="switch-language-wrapper">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java"></div>
```java
Mono<Person> personMono = ... ;

Mono<Void> result = client.post()
      .uri("/persons/{id}", id)
      .contentType(MediaType.APPLICATION_JSON)
      .body(personMono, Person.class)
      .retrieve()
      .bodyToMono(Void.class);
```
<div class="language-only-for-kotlin"></div>
```kotlin
val personDeferred: Deferred<Person> = ...

client.post()
      .uri("/persons/{id}", id)
      .contentType(MediaType.APPLICATION_JSON)
      .body<Person>(personDeferred)
      .retrieve()
      .awaitBody<Unit>()
```

다음 예제처럼 객체 스트림으로도 인코딩할 수 있다:
<div class="switch-language-wrapper">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java"></div>
```java
Flux<Person> personFlux = ... ;

Mono<Void> result = client.post()
      .uri("/persons/{id}", id)
      .contentType(MediaType.APPLICATION_STREAM_JSON)
      .body(personFlux, Person.class)
      .retrieve()
      .bodyToMono(Void.class);
```
<div class="language-only-for-kotlin"></div>
```kotlin
val people: Flow<Person> = ...

client.post()
      .uri("/persons/{id}", id)
      .contentType(MediaType.APPLICATION_JSON)
      .body(people)
      .retrieve()
      .awaitBody<Unit>()
```

비동기 타입이 아닌 실제 값을 가지고 있다면 `bodyValue`를 사용한다:

<div class="switch-language-wrapper">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java"></div>
```java
Person person = ... ;

Mono<Void> result = client.post()
      .uri("/persons/{id}", id)
      .contentType(MediaType.APPLICATION_JSON)
      .bodyValue(person)
      .retrieve()
      .bodyToMono(Void.class);
```
<div class="language-only-for-kotlin"></div>
```kotlin
val person: Person = ...

client.post()
      .uri("/persons/{id}", id)
      .contentType(MediaType.APPLICATION_JSON)
      .bodyValue(person)
      .retrieve()
      .awaitBody<Unit>()
```

### 2.4.1. Form Data

form 데이터를 보내려면 `MultiValueMap<String, String>`을 body로 사용해야 한다. 이때는 `FormHttpMessageWriter`가 자동으로 content-type을 `application/x-www-form-urlencoded`로 설정한다. 다음은 `MultiValueMap<String, String>`을 사용하는 예제다:

<div class="switch-language-wrapper">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java"></div>
```java
MultiValueMap<String, String> formData = ... ;

Mono<Void> result = client.post()
      .uri("/path", id)
      .bodyValue(formData)
      .retrieve()
      .bodyToMono(Void.class);
```
<div class="language-only-for-kotlin"></div>
```kotlin
val formData: MultiValueMap<String, String> = ...

client.post()
      .uri("/path", id)
      .bodyValue(formData)
      .retrieve()
      .awaitBody<Unit>()
```

`BodyInserters`를 사용하면 인라인으로 form 데이터를 만들 수 있다:

<div class="switch-language-wrapper">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java"></div>
```java
import static org.springframework.web.reactive.function.BodyInserters.*;

Mono<Void> result = client.post()
      .uri("/path", id)
      .body(fromFormData("k1", "v1").with("k2", "v2"))
      .retrieve()
      .bodyToMono(Void.class);
```
<div class="language-only-for-kotlin"></div>
```kotlin
import org.springframework.web.reactive.function.BodyInserters.*

client.post()
      .uri("/path", id)
      .body(fromFormData("k1", "v1").with("k2", "v2"))
      .retrieve()
      .awaitBody<Unit>()
```

### 2.4.2. Multipart Data

multipart 데이터를 보낼 때는 `MultiValueMap<String, ?>`을 사용해서, 각 value에 part 컨텐츠를 나타내는 `Object` 인스턴스나, part의 컨텐츠와 헤더를 나타내는 `HttpEntity`를 담아야 한다. `MultipartBodyBuilder`를 사용하면 좀 더 편리하다. 다음은 `MultiValueMap<String, ?>`을 만드는 예제다:

<div class="switch-language-wrapper">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java"></div>
```java
MultipartBodyBuilder builder = new MultipartBodyBuilder();
builder.part("fieldPart", "fieldValue");
builder.part("filePart1", new FileSystemResource("...logo.png"));
builder.part("jsonPart", new Person("Jason"));
builder.part("myPart", part); // Part from a server request

MultiValueMap<String, HttpEntity<?>> parts = builder.build();
```
<div class="language-only-for-kotlin"></div>
```kotlin
val builder = MultipartBodyBuilder().apply {
  part("fieldPart", "fieldValue")
  part("filePart1", new FileSystemResource("...logo.png"))
  part("jsonPart", new Person("Jason"))
  part("myPart", part) // Part from a server request
}

val parts = builder.build()
```

일반적인 경우엔 파트마다 `Content-Type`을 명시하지 않아도 된다. Content type은 직렬화할 때 쓰는 `HttpMessageWriter`나, `Resource`의 경우 파일 확장자에 따라 자동으로 결정한다. 필요하다면, 빌더 `part` 메소드 중 `MediaType`을 받는 메소드를 사용하면 된다.

`MultiValueMap`을 만들었으면, 가장 간단하게는 다음 예제처럼 `body` 메소드로 `WebClient`에 넘길 수 있다:

<div class="switch-language-wrapper">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java"></div>
```java
MultipartBodyBuilder builder = ...;

Mono<Void> result = client.post()
      .uri("/path", id)
      .body(builder.build())
      .retrieve()
      .bodyToMono(Void.class);
```
<div class="language-only-for-kotlin"></div>
```kotlin
val builder: MultipartBodyBuilder = ...

client.post()
      .uri("/path", id)
      .body(builder.build())
      .retrieve()
      .awaitBody<Unit>()
```

`MultiValueMap`에 전형적인 form 데이터(`application/x-www-form-urlencoded`) 등  `String`이 아닌 값이 하나라도 들어있다면, `Content-Type`을 `multipart/form-data`로 설정하지 않아도 된다. `MultipartBodyBuilder`를 사용하면 항상 `HttpEntity`로 감싸주기 때문이다.

`MultipartBodyBuilder`대신 `BodyInserters`를 사용하면 인라인으로 multipart 컨텐츠를 만들 수 있다:

<div class="switch-language-wrapper">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java"></div>
```java
import static org.springframework.web.reactive.function.BodyInserters.*;

Mono<Void> result = client.post()
      .uri("/path", id)
      .body(fromMultipartData("fieldPart", "value").with("filePart", resource))
      .retrieve()
      .bodyToMono(Void.class);
```
<div class="language-only-for-kotlin"></div>
```kotlin
import org.springframework.web.reactive.function.BodyInserters.*

client.post()
      .uri("/path", id)
      .body(fromMultipartData("fieldPart", "value").with("filePart", resource))
      .retrieve()
      .awaitBody<Unit>()
```

---

## 2.5. Client Filters

`WebClient.Builder`로 클라이언트 필터(`ExchangeFilterFunction`)를 등록하면, 요청을 처리하기 전에 가로채서 수정할 수 있다:

<div class="switch-language-wrapper">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java"></div>
```java
WebClient client = WebClient.builder()
      .filter((request, next) -> {

          ClientRequest filtered = ClientRequest.from(request)
                  .header("foo", "bar")
                  .build();

          return next.exchange(filtered);
      })
      .build();
```
<div class="language-only-for-kotlin"></div>
```kotlin
val client = WebClient.builder()
      .filter { request, next ->

          val filtered = ClientRequest.from(request)
                  .header("foo", "bar")
                  .build()

          next.exchange(filtered)
      }
      .build()
```

필터는 인증 처리 같은 횡단 관심사(cross-cutting concerns)를 처리할 때 유용하다. 다음 예제는 스태틱 팩토리 메소드를 사용해서 기본 인증 필터를 추가한다:

<div class="switch-language-wrapper">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java"></div>
```java
import static org.springframework.web.reactive.function.client.ExchangeFilterFunctions.basicAuthentication;

WebClient client = WebClient.builder()
      .filter(basicAuthentication("user", "password"))
      .build();
```
<div class="language-only-for-kotlin"></div>
```kotlin
import org.springframework.web.reactive.function.client.ExchangeFilterFunctions.basicAuthentication

val client = WebClient.builder()
      .filter(basicAuthentication("user", "password"))
      .build()
```

필터는 모든 요청에 전역으로 적용된다. 필터에서 특정 요청만 처리하고 싶다면, 다음 예제처럼 `ClientRequest`에 request attribute를 추가하고, 필터에서 이 attribute에 접근하면 된다:

<div class="switch-language-wrapper">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java"></div>
```java
WebClient client = WebClient.builder()
      .filter((request, next) -> {
          Optional<Object> usr = request.attribute("myAttribute");
          // ...
      })
      .build();

client.get().uri("https://example.org/")
      .attribute("myAttribute", "...")
      .retrieve()
      .bodyToMono(Void.class);

  }
```
<div class="language-only-for-kotlin"></div>
```kotlin
val client = WebClient.builder()
          .filter { request, _ ->
      val usr = request.attributes()["myAttribute"];
      // ...
  }.build()

  client.get().uri("https://example.org/")
          .attribute("myAttribute", "...")
          .retrieve()
          .awaitBody<Unit>()
```

`WebClient`를 복제해서 필터를 추가하거나 삭제하는 것도 가능하다. 다음 예제는 첫 번째 위치에 인증 필터를 추가한다:

<div class="switch-language-wrapper">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java"></div>
```java
import static org.springframework.web.reactive.function.client.ExchangeFilterFunctions.basicAuthentication;

WebClient client = webClient.mutate()
      .filters(filterList -> {
          filterList.add(0, basicAuthentication("user", "password"));
      })
      .build();
```
<div class="language-only-for-kotlin"></div>
```kotlin
val client = webClient.mutate()
      .filters { it.add(0, basicAuthentication("user", "password")) }
      .build()
```

---

## 2.6. Synchronous Use

`WebClient`는 마지막에 결과를 블로킹하면 동기로(synchronous) 결과를 가져온다:

<div class="switch-language-wrapper">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java"></div>
```java
Person person = client.get().uri("/person/{id}", i).retrieve()
  .bodyToMono(Person.class)
  .block();

List<Person> persons = client.get().uri("/persons").retrieve()
  .bodyToFlux(Person.class)
  .collectList()
  .block();
```
<div class="language-only-for-kotlin"></div>
```kotlin
val person = runBlocking {
  client.get().uri("/person/{id}", i).retrieve()
          .awaitBody<Person>()
}

val persons = runBlocking {
  client.get().uri("/persons").retrieve()
          .bodyToFlow<Person>()
          .toList()
}
```

하지만 API 호출을 여러번 한다면, 각 응답을 따로 블로킹하기보단 전체 결과를 합쳐서 기다리는 게 더 효율적이다:

<div class="switch-language-wrapper">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java"></div>
```java
Mono<Person> personMono = client.get().uri("/person/{id}", personId)
      .retrieve().bodyToMono(Person.class);

Mono<List<Hobby>> hobbiesMono = client.get().uri("/person/{id}/hobbies", personId)
      .retrieve().bodyToFlux(Hobby.class).collectList();

Map<String, Object> data = Mono.zip(personMono, hobbiesMono, (person, hobbies) -> {
          Map<String, String> map = new LinkedHashMap<>();
          map.put("person", person);
          map.put("hobbies", hobbies);
          return map;
      })
      .block();
```
<div class="language-only-for-kotlin"></div>
```kotlin
val data = runBlocking {
      val personDeferred = async {
          client.get().uri("/person/{id}", personId)
                  .retrieve().awaitBody<Person>()
      }

      val hobbiesDeferred = async {
          client.get().uri("/person/{id}/hobbies", personId)
                  .retrieve().bodyToFlow<Hobby>().toList()
      }

      mapOf("person" to personDeferred.await(), "hobbies" to hobbiesDeferred.await())
  }
```

위 코드는 단지 한가지 예시일 뿐이다. 요청이 끝날 때까지 블로킹하지 않고, 리액티브 파이라인을 구축해서 상호 독립적으로 원격 호출을 여러번 실행하는(보통 감싸진 경우가 많다) 다른 패턴과 연산자도 많다.

> 스프링 MVC나 웹플럭스 컨트롤러에서 `Flux`나 `Mono`를 사용한다면 블로킹할 필요가 없다. 단순히 컨트롤러 메소드에서 리액티브 타입을 리턴하기만 하면 된다. 코틀린 코루틴과 스프링 웹플럭스에서도 마찬가지다. 컨트롤러 메소드에서 suspend 함수를 사용하거나 `Flow`를 리턴하면 된다.

---

## 2.7. Testing

`WebClient`를 사용한 코드는 [OkHttp MockWebServer](https://github.com/square/okhttp#mockwebserver)같은 mock 웹 서버로 테스트할 수 있다. 예제 코드는 스프링 프레임워크 테스트 코드에 있는 [`WebClientIntegrationTests`](https://github.com/spring-projects/spring-framework/blob/master/spring-webflux/src/test/java/org/springframework/web/reactive/function/client/WebClientIntegrationTests.java)나, OkHttp 레포지토리에 있는 [`static-server`](https://github.com/square/okhttp/tree/master/samples/static-server)를 확인해 봐라.

---

> 전체 목차는 [여기](https://godekdls.github.io/Reactive%20Spring/contents/)에 있습니다.

