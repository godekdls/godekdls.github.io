---
title: WebSockets
category: Spring Web on Reactive Stack
order: 5
permalink: /Reactive%20Spring/websockets/
description: 스프링5 웹 리액티브 스택 웹소켓 한글 번역
image: ./../../images/reactivespring/spring-mvc-and-webflux-venn.png
lastmod: 2020-07-12T16:00:00+09:00
---
<script>var switchLanguage=true</script>

> [리액티브 스프링 공식 reference](https://docs.spring.io/spring/docs/current/spring-framework-reference/web-reactive.html#webflux-websocket)를 한글로 번역한 문서입니다.
>
> 전체 목차는 [여기](https://godekdls.github.io/Reactive%20Spring/contents/)에 있습니다.

### 목차

- [3.1. Introduction to WebSocket](#31-Introduction-to-websocket)
  + [3.1.1. HTTP Versus WebSocket](#311-http-versus-websocket)
  + [3.1.2. When to Use WebSockets](#312-when-to-use-websockets)
- [3.2. WebSocket API](#32-websocket-api)
  + [3.2.1. Server](#321-server)
  + [3.2.2. WebSocketHandler](#322-websockethandler)
  + [3.2.3. DataBuffer](#323-databuffer)
  + [3.2.4. Handshake](#324-handshake)
  + [3.2.5. Server Configration](#325-server-configration)
  + [3.2.6. CORS](#326-cors)
  + [3.2.7. Client](#327-client)

---

[서블릿 스택과 동일함](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#websocket)<br>이번 섹션에서는 리액티브 스택의 웹소켓 메세지 처리를 다룬다.

---

## 3.1. Introduction to WebSocket

웹소켓 프로토콜([RFC 6455](https://tools.ietf.org/html/rfc6455))은 TCP 커넥션 하나로 클라이언트와 서버 사이 양방향 통신을 지원하는 표준 프로토콜이다. HTTP와는 또 다른 TCP 프로토콜이지만, HTTP와 동일한 80, 443 포트로 접속하기 때문에 방화벽을 새로 만들지 않아도 된다.

웹소켓 통신이 가능해진 건 HTTP 요청의 프로토콜을 업그레이드해 주는 `Ugrade` 헤더 덕분이다. 이 헤더를 사용하면 웹 소켓 프로토콜로 전환할 수 있다. 다음은 웹소켓 프로토콜을 사용한 통신 예시다:

```yaml
GET /spring-websocket-portfolio/portfolio HTTP/1.1
Host: localhost:8080
Upgrade: websocket # (1)
Connection: Upgrade # (2)
Sec-WebSocket-Key: Uc9l9TMkWGbHFD2qnFHltg==
Sec-WebSocket-Protocol: v10.stomp, v11.stomp
Sec-WebSocket-Version: 13
Origin: http://localhost:8080
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `Upgrade` 헤더.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> `Upgrade` 커넥션을 사용한다.</small>

웹소켓으로 통신하는 서버는 200 상태 코드 대신, 아래와 유사한 방식으로 응답할 수 있다:

```yaml
HTTP/1.1 101 Switching Protocols # (1)
Upgrade: websocket
Connection: Upgrade
Sec-WebSocket-Accept: 1qVdfYHU9hPOl4JYYNXF623Gzn0=
Sec-WebSocket-Protocol: v10.stomp
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 프로토콜 전환.</small>

HTTP 업그레이드 요청을 보내면, 핸드셰이킹을 완료한 다음에도 클라이언트와 서버 양쪽에서 TCP 소켓을 유지하기 때문에 메세지를 계속해서 주고받을 수 있다.

웹소켓 동작 방식을 다 설명하기에는 이 문서 범위를 벗어난다. HTML5의 웹소켓 챕터(RFC 6455)를 봐도 좋고, 다른 소개글이나 튜토리얼 페이지도 많이 있다.

웹소켓 서버를 웹 서버에서(e.g. nginx) 실행한다면, 웹소켓 업그레이드 요청을 웹소켓 서버로 전달하기 위한 설정이 필요하다. 마찬가지로 클라우드 환경에서 어플리케이션을 실행한다면, 클라우드 제공 업체 문서에서 웹소켓 지원 내용을 확인해 봐라.

### 3.1.1. HTTP Versus WebSocket

웹소켓은 HTTP와 호환되도록 설계됐고 HTTP 요청으로 통신을 시작하지만, 이 두 프로토콜은 아키텍처나 어플리케이션 프로그래밍 모델에 많은 영향을 끼친다. 

HTTP/REST 방식을 사용하는 어플리케이션은 URL을 굉장히 많이 설계한다. 클라이언트는 이 URL에 접근해서 어플리케이션과 요청/응답을 주고받는다. 서버는 HTTP URL, 메소드, 헤더에 맞는 핸들러에 요청을 라우팅한다.

반대로 웹소켓은 보통 커넥션을 맺기 위한 URL 하나만 사용한다. 커넥션을 맺고 나면 모든 메세지를 같은 TCP 커넥션으로 통신한다. 이는 기존과는 완전히 다른, 비동기 이벤트 지향 메세지 아케턱처다.

웹소켓은 HTTP와는 달리, 메세지 내용에 규격이 없는 저수준 통신 프로토콜이다. 이 말은, 클라이언트와 서버가 미리 같은 메세지 규약을 설계해 놓지 않으면 메세지를 라우팅하고 처리할 수 없다는 뜻이다.

HTTP 핸드셰이크 요청에 `Sec-WebSocket-Protocol` 헤더를 추가하면 웹소켓 클라이언트/서버도 고수준 메세지 프로토콜(e.g. STOMP)로 통신할 수 있다. 그렇지 않으면 자체 컨벤션을 만들어야 한다.

### 3.1.2. When to Use WebSockets

웹소켓으로도 웹 페이지에서 동적인 인터랙션을 사용할 수 있다. 하지만 대부분은 Ajax와 HTTP 스트리밍 조합이나 long polling으로 더 간단하게 해결할 수 있다.

예를 들어 뉴스, 메일, 소셜 피드는 동적으로 업데이트해야 하지만 몇 분에 한 번씩 갱신해도 아무 문제없다. 반대로 협업툴이나, 게임, 금융 앱은 훨씬 더 실시간에 가까워야 한다.

지연 시간 하나만으로 결정하진 않는다. 메세지 크기가 상대적으로 작다면(e.g. 네트워크 오류 모니터링) HTTP 스트리밍이나 폴링만으로 충분하다. 웹소켓이 필요할 때는 적은 지연으로, 자주, 큰 데이터를 전송해야 할 때다.

인터넷을 벗어나서 직접 컨트롤할 수 없는 프록시가 웹소켓 통신을 차단할 수도 있다. `Ugrade` 헤더를 전달하도록 설정되지 않았거나, idle로 보이는 오래된 커넥션을 닫아 버릴 수도 있다. 즉, 방화벽 내부에서만 사용하는 게 아니라 외부에 공개된 어플리케이션이라면, 웹소켓을 사용하기 전 좀 더 고민해봐야 한다는 뜻이다.

---

## 3.2. WebSocket API

[서블릿 스택과 동일함](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#websocket-server)

스프링 프레임워크는 웹소켓 메세지를 처리를 위한 웹소켓 API를 제공한다. 웹소켓 API는 클라이언트/서버 사이드 모두 사용할 수 있다.

### 3.2.1. Server

[서블릿 스택과 동일함](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#websocket-server-handler)

웹소켓 서버를 만들려면 먼저 `WebSocketHandler`가 필요하다. 다음은 웹소켓 핸들러를 만드는 예제다:

<div class="switch-language-wrapper">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java"></div>
```java
import org.springframework.web.reactive.socket.WebSocketHandler;
import org.springframework.web.reactive.socket.WebSocketSession;

public class MyWebSocketHandler implements WebSocketHandler {

  @Override
  public Mono<Void> handle(WebSocketSession session) {
      // ...
  }
}
```
<div class="language-only-for-kotlin"></div>
```kotlin
import org.springframework.web.reactive.socket.WebSocketHandler
import org.springframework.web.reactive.socket.WebSocketSession

class MyWebSocketHandler : WebSocketHandler {

  override fun handle(session: WebSocketSession): Mono<Void> {
      // ...
  }
}
```

그다음엔 핸들러를 URL에 매핑하고 `WebSocketHandlerAdapter`를 추가해야 한다:

<div class="switch-language-wrapper">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java"></div>
```java
@Configuration
class WebConfig {

  @Bean
  public HandlerMapping handlerMapping() {
      Map<String, WebSocketHandler> map = new HashMap<>();
      map.put("/path", new MyWebSocketHandler());
      int order = -1; // before annotated controllers

      return new SimpleUrlHandlerMapping(map, order);
  }

  @Bean
  public WebSocketHandlerAdapter handlerAdapter() {
      return new WebSocketHandlerAdapter();
  }
}
```
<div class="language-only-for-kotlin"></div>
```kotlin
@Configuration
class WebConfig {

  @Bean
  fun handlerMapping(): HandlerMapping {
      val map = mapOf("/path" to MyWebSocketHandler())
      val order = -1 // before annotated controllers

      return SimpleUrlHandlerMapping(map, order)
  }

  @Bean
  fun handlerAdapter() =  WebSocketHandlerAdapter()
}
```

### 3.2.2. `WebSocketHandler`

`WebSocketHandler`의 `handle` 메소드는 `WebSocketSession`을 받아 `Mono<Void>`를 리턴함으로써 세션 처리가 끝났다는 것을 알려준다. 세션은 인바운드 메세지와 아웃바운드 메세지를 각 스트림을 통해 처리한다. 스트림을 처리하는 메소드는 두 가지가 있다:

| `WebSocketSession` method                      | Description                                                  |
| :--------------------------------------------- | :----------------------------------------------------------- |
| `Flux<WebSocketMessage> receive()`             | 인바운드 메세지 스트림에 접근하고 커넥션을 닫으면 완료한다.  |
| `Mono<Void> send(Publisher<WebSocketMessage>)` | 전송할 메세지를 받아 메세지를 쓰고, 처리를 완료하면 `Mono<Void>`를 리턴한다. |

`WebSocketHandler`는 반드시 인바운드, 아웃바운드 스트림을 하나의 플로우로 구성하고, 플로우 처리를 완료하면 `Mono<Void>`를 리턴해야 한다. 어플리케이션 요구사항에 따라 플로우는 다음 상황에 완료된다:

- 인바운드, 아웃바운드 메세지 스트림 중 하나가 완료됐을 때.
- 아웃바운드 스트림이 무한 스트림이고, 인바운드 스트림이 완료됐을 때(즉 커넥션을 닫았을 때).
- `WebSocketSession`의 `close` 메소드를 호출했을 때.

인바운드와 아웃바운드 메세지 스트림을 함께 구성할 때는 리액티브 스티림이 종료 시점을 알려주기 때문에 커넥션이 열려있는지 확인하지 않아도 된다. 인바운드 스트림은 완료나 에러 신호를 받고, 아웃바운드 스트림은 취소 신호를 받는다.

가장 간단한 구현체는 인바운드 스트림을 처리하는 핸들러다:

<div class="switch-language-wrapper">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java"></div>
```java
class ExampleHandler implements WebSocketHandler {

  @Override
  public Mono<Void> handle(WebSocketSession session) {
      return session.receive()  // (1)       
              .doOnNext(message -> {
                  // ...        // (2)      
              })
              .concatMap(message -> {
                  // ...        // (3)          
              })
              .then();          // (4)    
  }
}
```
<div class="language-only-for-kotlin"></div>
```kotlin
class ExampleHandler : WebSocketHandler {

  override fun handle(session: WebSocketSession): Mono<Void> {
      return session.receive() // (1)
              .doOnNext {
                  // ...       // (2)           
              }
              .concatMap {
                  // ...       // (3)         
              }
              .then()          // (4)       
  }
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 인바운드 메세지 스트림에 접근한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 각 메세지에 원하는 처리를 한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 감싸진 형태로(nested) 메세지 컨텐츠에 비동기 연산을 수행한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> 수신을 완료하면 `Mono<Void>`를 리턴한다.</small>

>  pooled data buffer를 사용하는 서버에서(e.g. Netty) 비동기 연산을 감싸서(nested) 사용한다면, `message.retain()`을 호출해야 하는 경우도 있다. 그렇지 않으면 데이터를 읽기도 전에 버퍼가 비워질 수 있다. 상세 배경은 [Data Buffers and Codecs](https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#databuffers)를 참고하라.

다음 예제는 인바운드, 아웃바운드 스트림을 함께 처리한다:

<div class="switch-language-wrapper">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java"></div>
```java
class ExampleHandler implements WebSocketHandler {

  @Override
  public Mono<Void> handle(WebSocketSession session) {

      Flux<WebSocketMessage> output = session.receive()            // (1)
              .doOnNext(message -> {
                  // ...
              })
              .concatMap(message -> {
                  // ...
              })
              .map(value -> session.textMessage("Echo " + value)); // (2)

      return session.send(output);                                 // (3)
  }
}
```
<div class="language-only-for-kotlin"></div>
```kotlin
class ExampleHandler : WebSocketHandler {

  override fun handle(session: WebSocketSession): Mono<Void> {

      val output = session.receive()                   // (1)
              .doOnNext {
                  // ...
              }
              .concatMap {
                  // ...
              }
              .map { session.textMessage("Echo $it") } // (2)

      return session.send(output)                      // (3)
  }
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 인바운드 메세지 스트림을 처리한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 아웃바운드 메세지를 생성해서 단일 플로우로 통합한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 메세지를 받는 동안은 처리를 완료하지 않는 `Mono<Void>`를 리턴한다.</small>

인바운드, 아웃바운드 스트림을 독립적으로 처리하고 완료됐을 때 합칠 수도 있다:

<div class="switch-language-wrapper">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java"></div>
```java
class ExampleHandler implements WebSocketHandler {

  @Override
  public Mono<Void> handle(WebSocketSession session) {

      Mono<Void> input = session.receive()                                // (1)
              .doOnNext(message -> {
                  // ...
              })
              .concatMap(message -> {
                  // ...
              })
              .then();

      Flux<String> source = ... ;
      Mono<Void> output = session.send(source.map(session::textMessage)); // (2)

      return Mono.zip(input, output).then();                              // (3)
  }
}
```
<div class="language-only-for-kotlin"></div>
```kotlin
class ExampleHandler : WebSocketHandler {

  override fun handle(session: WebSocketSession): Mono<Void> {

      val input = session.receive()                               // (1)
              .doOnNext {
                  // ...
              }
              .concatMap {
                  // ...
              }
              .then()

      val source: Flux<String> = ...
      val output = session.send(source.map(session::textMessage)) // (2)

      return Mono.zip(input, output).then()                       // (3)
  }
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 인바운드 메세지 스트림을 처리한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 메세지를 전송한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 스트림을 합쳐서 모두 완료되면 종료하는 `Mono<Void>`를 리턴한다.</small>

### 3.2.3. `DataBuffer`

웹플럭스에선 바이트 버퍼를 `DataBuffer`클래스로 표현한다. 이 클래스는 스프링 코어 문서 [Data Buffers and Codecs](https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#databuffers) 섹션에서 자세히 다룬다.
핵심은 Netty같은 일부 서버에선 메모리 풀을 사용해서 바이트 버퍼를 처리하고 레퍼런스를 카운팅하므로, 메모리 릭을 방지하려면 컨슈밍하고 나서 버퍼 메모리를 반환해야 한다는 것이다.

어플리케이션을 Netty에서 실행한다면, 입력 버퍼에 데이터를 유지해야 할 땐 반드시 `DataBufferUtils.retain(dataBuffer)`를 사용하고, 버퍼에 있는 데이터를 다 사용하고 나면 `DataBufferUtils.release(dataBuffer)`를 호출해야 한다.

### 3.2.4. Handshake

[서블릿 스택과 동일함](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#websocket-server-handshake)

`WebSocketHandlerAdapter`는 `WebSocketService`에 처리를 위임한다. 디폴트 구현체 `HandshakeWebSocketService`는 웹소켓 요청에 대한 기본 검사를 수행한 뒤 사용 중인 서버에 `RequestUpgradeStrategy`를 적용한다. 현재는 리액터 Netty, 톰캣, Jetty, Undertow를 기본으로 지원한다.

`HandshakeWebSocketService`로 `Predicate<String> sessionAttributePredicate` 프로퍼티에 접근할 수 있다. 이 프로퍼티로 `WebSession` attribute를 추출해서 `WebSocketSession` attribute에 추가한다.

### 3.2.5. Server Configration

[서블릿 스택과 동일함](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#websocket-server-runtime-configuration)

각 서버의 `RequestUpgradeStrategy` 구현체로 웹소켓 엔진 관련 옵션을 설정할 수 있다. 다음은 톰캣에서 사용할 웹소켓 옵션을 설정하는 예제다:

<div class="switch-language-wrapper">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java"></div>
```java
@Configuration
class WebConfig {

  @Bean
  public WebSocketHandlerAdapter handlerAdapter() {
      return new WebSocketHandlerAdapter(webSocketService());
  }

  @Bean
  public WebSocketService webSocketService() {
      TomcatRequestUpgradeStrategy strategy = new TomcatRequestUpgradeStrategy();
      strategy.setMaxSessionIdleTimeout(0L);
      return new HandshakeWebSocketService(strategy);
  }
}
```
<div class="language-only-for-kotlin"></div>
```kotlin
@Configuration
class WebConfig {

  @Bean
  fun handlerAdapter() =
          WebSocketHandlerAdapter(webSocketService())

  @Bean
  fun webSocketService(): WebSocketService {
      val strategy = TomcatRequestUpgradeStrategy().apply {
          setMaxSessionIdleTimeout(0L)
      }
      return HandshakeWebSocketService(strategy)
  }
}
```

사용 중인 서버에서 지원하는 업데이트 전략 옵션을 확인해 봐라. 현재는 톰캣과 Jetty만 옵션을 설정할 수 있다.

### 3.2.6. CORS

[서블릿 스택과 동일함](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#websocket-server-allowed-origins)

CORS를 설정하고 웹소켓 엔드포인트 접근을 제한하는 가장 쉬운 방법은 `WebSocketHandler`로 `CorsConfigurationSource`를 구현하고, 허용할 origin, 헤더 등을 설정한 `CorsConfiguraiton`을 리턴하는 것이다. 아니면 `SimpleUrlHandler`의 `corsConfigurations` 프로퍼티에 URL 패턴별 CORS 설정을 넣어줘도 된다. 둘 다 사용했다면 `CorsConfiguration`의 `combine` 메소드에서 합쳐진다.

### 3.2.7. Client

스프링 웹플럭스는 `WebSocketClient` 인터페이스와 리액터 Netty, 톰캣, Jetty, Undertow, 표준 자바(SJR-356) 구현체를 제공한다.

>  톰캣 클라이언트는 자바 표준 클라이언트를 확장해서 `WebSocketSession`에 몇 가지 기능을 추가했다. back pressure 목적으로 메세지 전송을 일시중단하는 톰캣 전용 API 기능이 들어있다.

클라이언트 인스턴스를 생성해서 `execute` 메소드를 실행하면 웹소켓 세션을 시작한다:

<div class="switch-language-wrapper">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java"></div>
```java
WebSocketClient client = new ReactorNettyWebSocketClient();

URI url = new URI("ws://localhost:8080/path");
client.execute(url, session ->
      session.receive()
              .doOnNext(System.out::println)
              .then());
```
<div class="language-only-for-kotlin"></div>
```kotlin
val client = ReactorNettyWebSocketClient()

      val url = URI("ws://localhost:8080/path")
      client.execute(url) { session ->
          session.receive()
                  .doOnNext(::println)
          .then()
      }
```

Jetty같이 `Lifecycle` 인터페이스를 구현하고 있는 일부 클라이언트는 사용하기 전에 stop/start 메소드를 호출해야 한다. 모든 클라이언트는 각 웹소켓 클라이언트 관련 옵션을 설정할 수 있는 생성자를 가지고 있다.

---

> 전체 목차는 [여기](https://godekdls.github.io/Reactive Spring/contents/)에 있습니다.