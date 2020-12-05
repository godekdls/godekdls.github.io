---
title: HTTP Server
category: Reactor Netty
order: 6
permalink: /Reactor%20Netty/httpserver/
description: 리액터 네티로 HTTP 서버 설정하기 한글 번역
image: ./../../images/reactornetty/logo.png
lastmod: 2020-12-05T12:00:00+09:00
comments: true
originalRefName: 프로젝트 리액터 네티
originalRefLink: https://projectreactor.io/docs/netty/1.0.1/reference/index.html#http-server
---

### 목차

- [5.1. Starting and Stopping](#51-starting-and-stopping)
  + [5.1.1. Host and Port](#511-host-and-port)
- [5.2. Routing HTTP](#52-routing-http)
  + [5.2.1. SSE](#521-sse)
  + [5.2.2. Static Resources](#522-static-resources)
- [5.3. Writing Data](#53-writing-data)
  + [5.3.1. Adding Headers and Other Metadata](#531-adding-headers-and-other-metadata)
  + [5.3.2. Compression](#532-compression)
- [5.4. Consuming Data](#54-consuming-data)
  + [5.4.1. Reading Headers, URI Params, and other Metadata](#541-reading-headers-uri-params-and-other-metadata)
    * [Obtaining the Remote (Client) Address](#obtaining-the-remote-client-address)
  + [5.4.2. HTTP Request Decoder](#542-http-request-decoder)
- [5.5. TCP-level Configuration](#55-tcp-level-configuration)
  + [5.5.1. Wire Logger](#551-wire-logger)
- [5.6. SSL and TLS](#56-ssl-and-tls)
  + [5.6.1. Server Name Indication](#561-server-name-indication)
- [5.7. HTTP Access Log](#57-http-access-log)
- [5.8. HTTP/2](#58-http2)
  + [5.8.1. Protocol Selection](#581-protocol-selection)
- [5.9. Metrics](#59-metrics)
- [5.10. Unix Domain Sockets](#510-unix-domain-sockets)

---

**리액터 네티**는 사용하기도 설정하기도 쉬운 [`HttpServer`](https://projectreactor.io/docs/netty/release/api/reactor/netty/http/server/HttpServer.html) 클래스를 제공한다. `HttpServer`는 **HTTP** 서버 생성에 필요한 **네티** 기능을 대부분 숨겨주고, **리액티브 스트림** backpressure를 추가해준다.

---

## 5.1. Starting and Stopping

HTTP 서버를 시작하려면 일단 [HttpServer](https://projectreactor.io/docs/netty/release/api/reactor/netty/http/server/HttpServer.html) 인스턴스를 만들어 설정해야 한다. 기본적으로 **호스트**는 모든 로컬 주소로 설정되며, `bind` 연산이 실행될 때 시스템에서 임의의 포트(ephemeral port)를 선택한다. 다음은 `HttpServer` 인스턴스를 생성하고 설정하는 예시다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/http/server/create/Application.java**</small>

```java
import reactor.netty.DisposableServer;
import reactor.netty.http.server.HttpServer;

public class Application {

	public static void main(String[] args) {
		DisposableServer server =
				HttpServer.create()   // (1)
				          .bindNow(); // (2)

		server.onDispose()
		      .block();
	}
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> [HttpServer](https://projectreactor.io/docs/netty/release/api/reactor/netty/http/server/HttpServer.html) 인스턴스를 생성한다. 이제 인스턴스를 설정할 준비가 되었다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 서버를 블로킹 방식으로 시작하고 초기화를 마치길 기다린다.</small>

반환된 [`DisposableServer`](https://projectreactor.io/docs/netty/release/api/reactor/netty/DisposableServer.html)는 블로킹 방식으로 서버를 셧다운 시켜주는 [`disposeNow()`](https://projectreactor.io/docs/netty/release/api/reactor/netty/DisposableChannel.html#disposeNow-java.time.Duration-)를 포함하는, 간단한 서버 API를 제공한다.

### 5.1.1. Host and Port

특정 **호스트**와 **포트**로 서빙하고 싶다면, **HTTP** 서버를 다음과 같이 설정하면 된다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/http/server/address/Application.java**</small>

```java
import reactor.netty.DisposableServer;
import reactor.netty.http.server.HttpServer;

public class Application {

	public static void main(String[] args) {
		DisposableServer server =
				HttpServer.create()
				          .host("localhost") // (1)
				          .port(8080)        // (2)
				          .bindNow();

		server.onDispose()
		      .block();
	}
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> **HTTP** 서버 호스트를 설정한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> **HTTP** 서버 포트를 설정한다.</small>

---

## 5.2. Routing HTTP

**HTTP** 서버에 라우팅을 정의하려면 네티가 제공하는 [`HttpServerRoutes`](https://projectreactor.io/docs/netty/release/api/reactor/netty/http/server/HttpServerRoutes.html) 빌더를 설정해야 한다. 다음 예제는 그 방법을 보여준다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/http/server/routing/Application.java**</small>

```java
import reactor.core.publisher.Mono;
import reactor.netty.DisposableServer;
import reactor.netty.http.server.HttpServer;

public class Application {

	public static void main(String[] args) {
		DisposableServer server =
				HttpServer.create()
				          .route(routes ->
				              routes.get("/hello",        // (1)
				                        (request, response) -> response.sendString(Mono.just("Hello World!")))
				                    .post("/echo",        // (2)
				                        (request, response) -> response.send(request.receive().retain()))
				                    .get("/path/{param}", // (3)
				                        (request, response) -> response.sendString(Mono.just(request.param("param"))))
				                    .ws("/ws",            // (4)
				                        (wsInbound, wsOutbound) -> wsOutbound.send(wsInbound.receive().retain())))
				          .bindNow();

		server.onDispose()
		      .block();
	}
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `/hello`에 `GET` 요청을 서빙하고 `Hello World!`를 반환한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span>  `/echo`에 `POST` 요청을 서빙하고 전송받은 요청 body를 응답으로 반환한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> `/path/{param}`에 `GET` 요청을 서빙하고 패스 파라미터 값을 반환한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> `/ws`로 웹소켓을 서빙하고 수신 데이터를 그대로 보내도록 반환한다.</small>

> 서버 라우팅 정보는 유니크하며, 선언 순서에서 가장 먼저 매칭되는 라우팅만 실행한다.

### 5.2.1. SSE

다음은 **HTTP** 서버가 **서버 전송 이벤트(Server-Sent Event, SSE)**를 서빙하도록 설정하는 코드다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/http/server/sse/Application.java**</small>

```java
import com.fasterxml.jackson.databind.ObjectMapper;
import io.netty.buffer.ByteBuf;
import io.netty.buffer.ByteBufAllocator;
import org.reactivestreams.Publisher;
import reactor.core.publisher.Flux;
import reactor.netty.DisposableServer;
import reactor.netty.http.server.HttpServer;
import reactor.netty.http.server.HttpServerRequest;
import reactor.netty.http.server.HttpServerResponse;

import java.io.ByteArrayOutputStream;
import java.nio.charset.Charset;
import java.time.Duration;
import java.util.function.BiFunction;

public class Application {

	public static void main(String[] args) {
		DisposableServer server =
				HttpServer.create()
				          .route(routes -> routes.get("/sse", serveSse()))
				          .bindNow();

		server.onDispose()
		      .block();
	}

	/**
	 * Prepares SSE response
	 * The "Content-Type" is "text/event-stream"
	 * The flushing strategy is "flush after every element" emitted by the provided Publisher
	 */
	private static BiFunction<HttpServerRequest, HttpServerResponse, Publisher<Void>> serveSse() {
		Flux<Long> flux = Flux.interval(Duration.ofSeconds(10));
		return (request, response) ->
		        response.sse()
		                .send(flux.map(Application::toByteBuf), b -> true);
	}

	/**
	 * Transforms the Object to ByteBuf following the expected SSE format.
	 */
	private static ByteBuf toByteBuf(Object any) {
		ByteArrayOutputStream out = new ByteArrayOutputStream();
		try {
			out.write("data: ".getBytes(Charset.defaultCharset()));
			MAPPER.writeValue(out, any);
			out.write("\n\n".getBytes(Charset.defaultCharset()));
		}
		catch (Exception e) {
			throw new RuntimeException(e);
		}
		return ByteBufAllocator.DEFAULT
		                       .buffer()
		                       .writeBytes(out.toByteArray());
	}

	private static final ObjectMapper MAPPER = new ObjectMapper();
}
```

### 5.2.2. Static Resources

다음은 **HTTP** 서버가 스태틱 리소스를 서빙하도록 설정하는 코드다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/http/server/staticresources/Application.java**</small>

```java
import reactor.netty.DisposableServer;
import reactor.netty.http.server.HttpServer;

import java.net.URISyntaxException;
import java.nio.file.Path;
import java.nio.file.Paths;

public class Application {

	public static void main(String[] args) throws URISyntaxException {
		Path file = Paths.get(Application.class.getResource("/logback.xml").toURI());
		DisposableServer server =
				HttpServer.create()
				          .route(routes -> routes.file("/index.html", file))
				          .bindNow();

		server.onDispose()
		      .block();
	}
}
```

---

## 5.3. Writing Data

연결된 클라이언트에 데이터를 전송하려면 [`handle(…)`](https://projectreactor.io/docs/netty/release/api/reactor/netty/http/server/HttpServer.html#handle-java.util.function.BiFunction-)이나 [`route(…)`](https://projectreactor.io/docs/netty/release/api/reactor/netty/http/server/HttpServer.html#route-java.util.function.Consumer-)를 사용해서 I/O 핸들러를 연결해야 한다. I/O 핸들러는 [`HttpServerResponse`](https://projectreactor.io/docs/netty/release/api/reactor/netty/http/server/HttpServerResponse.html)에 접근할 수 있어 데이터를 write할 수 있다. 다음은 `handle(…)` 메소드를 사용하는 예시다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/http/server/send/Application.java**</small>

```java
import reactor.core.publisher.Mono;
import reactor.netty.DisposableServer;
import reactor.netty.http.server.HttpServer;

public class Application {

	public static void main(String[] args) {
		DisposableServer server =
				HttpServer.create()
				          .handle((request, response) -> response.sendString(Mono.just("hello"))) // (1)
				          .bindNow();

		server.onDispose()
		      .block();
	}
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 연결된 클라이언트에 `hello`라는 문자열을 전송한다.</small>

### 5.3.1. Adding Headers and Other Metadata

연결된 클라이언트에 데이터를 전송할 땐, 별도의 헤더나 쿠키, 상태 코드, 다른 기타 메타데이터를 함께 전송하기도 한다. 이런 별도 메타데이터는 [`HttpServerResponse`](https://projectreactor.io/docs/netty/release/api/reactor/netty/http/server/HttpServerResponse.html)로 제공할 수 있다. 다음 예제는 그 방법을 보여준다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/http/server/send/headers/Application.java**</small>

```java
import io.netty.handler.codec.http.HttpHeaderNames;
import io.netty.handler.codec.http.HttpResponseStatus;
import reactor.core.publisher.Mono;
import reactor.netty.DisposableServer;
import reactor.netty.http.server.HttpServer;

public class Application {

	public static void main(String[] args) {
		DisposableServer server =
				HttpServer.create()
				          .route(routes ->
				              routes.get("/hello",
				                  (request, response) ->
				                      response.status(HttpResponseStatus.OK)
				                              .header(HttpHeaderNames.CONTENT_LENGTH, "12")
				                              .sendString(Mono.just("Hello World!"))))
				          .bindNow();

		server.onDispose()
		      .block();
	}
}
```

### 5.3.2. Compression

**HTTP** 서버는 요청 헤더 `Accept-Encoding`에 따라 응답을 압축해서 전송하도록 설정할 수 있다.

**리액터 네티**는 발송 데이터 압축을 위한 세 가지 전략을 제공한다:

- `compress(boolean)`: 넘겨받은 boolean 값에 따라 압축을 활성화(`true`)하거나 비활성화(`false`)한다.
- `compress(int)`: 응답 사이즈가 넘겨받은 값(바이트)을 초과하면 압축을 수행한다.
- `compress(BiPredicate<HttpServerRequest, HttpServerResponse>)`: predicate가 `true`를 리턴하면 압축을 수행한다.

다음 예제는 `compress` 메소드(`true`로 설정)를 사용해 압축을 활성화한다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/http/server/compression/Application.java**</small>

```java
import reactor.netty.DisposableServer;
import reactor.netty.http.server.HttpServer;

import java.net.URISyntaxException;
import java.nio.file.Path;
import java.nio.file.Paths;

public class Application {

	public static void main(String[] args) throws URISyntaxException {
		Path file = Paths.get(Application.class.getResource("/logback.xml").toURI());
		DisposableServer server =
				HttpServer.create()
				          .compress(true)
				          .route(routes -> routes.file("/index.html", file))
				          .bindNow();

		server.onDispose()
		      .block();
	}
}
```

---

## 5.4. Consuming Data

연결된 클라이언트로부터 데이터를 받으려면 [`handle(…)`](https://projectreactor.io/docs/netty/release/api/reactor/netty/http/server/HttpServer.html#handle-java.util.function.BiFunction-)이나 [`route(…)`](https://projectreactor.io/docs/netty/release/api/reactor/netty/http/server/HttpServer.html#route-java.util.function.Consumer-)를 사용해서 I/O 핸들러를 연결해야 한다. I/O 핸들러는 [`HttpServerRequest`](https://projectreactor.io/docs/netty/release/api/reactor/netty/http/server/HttpServerRequest.html)에 접근할 수 있어 데이터를 읽을 수 있다. 

다음은 `handle(…)` 메소드를 사용하는 예시다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/http/server/read/Application.java**</small>

```java
import reactor.netty.DisposableServer;
import reactor.netty.http.server.HttpServer;

public class Application {

	public static void main(String[] args) {
		DisposableServer server =
				HttpServer.create()
				          .handle((request, response) -> request.receive().then()) // (1)
				          .bindNow();

		server.onDispose()
		      .block();
	}
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 연결된 클라이언트로부터 데이터를 받는다.</small>

### 5.4.1. Reading Headers, URI Params, and other Metadata

연결된 클라이언트로부터 데이터를 수신할 땐, 별도의 헤더, 파라미터나 다른 기타 메타데이터를 확인해야 할 수도 있다. 이런 별도 메타데이터는 [`HttpServerRequest`](https://projectreactor.io/docs/netty/release/api/reactor/netty/http/server/HttpServerRequest.html)로 가져올 수 있다. 다음 예제는 그 방법을 보여준다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/http/server/read/headers/Application.java**</small>

```java
import reactor.core.publisher.Mono;
import reactor.netty.DisposableServer;
import reactor.netty.http.server.HttpServer;

public class Application {

	public static void main(String[] args) {
		DisposableServer server =
				HttpServer.create()
				          .route(routes ->
				              routes.get("/{param}",
				                  (request, response) -> {
				                      if (request.requestHeaders().contains("Some-Header")) {
				                          return response.sendString(Mono.just(request.param("param")));
				                      }
				                      return response.sendNotFound();
				                  }))
				          .bindNow();

		server.onDispose()
		      .block();
	}
}
```

#### Obtaining the Remote (Client) Address

요청 데이터에서 가져올 수 있는 메타데이터 외에도, **호스트(서버)** 주소, **리모트(클라이언트)** 주소, **스킴**을 조회할 수도 있다. 사용하는 팩토리 메소드에 따라 채널에서 직접 정보를 가져올 수도 있고, `Forwarded`나 `X-Forwarded-*` **HTTP** 요청 헤더를 사용할 수도 있다. 다음 예제는 그 방법을 보여준다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/http/server/clientaddress/Application.java**</small>

```java
import reactor.core.publisher.Mono;
import reactor.netty.DisposableServer;
import reactor.netty.http.server.HttpServer;

public class Application {

  public static void main(String[] args) {
    DisposableServer server = 
      HttpServer.create()
        .forwarded(true) // (1)
        .route(routes ->
          routes.get("/clientip",
            (request, response) ->
              response.sendString(Mono.just(request.remoteAddress() // (2)
                                                    .getHostString()))))
        .bindNow();

    server.onDispose()
      .block();
  }
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 가능하다면 `Forwarded`와 `X-Forwarded-*` **HTTP** 요청 헤더에서 커넥션 정보를 가져오도록 지정한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 리모트(클라이언트) 피어의 주소를 반환한다.</small>

`Forwarded`나 `X-Forwarded-*` 헤더 핸들러 동작을 커스텀하는 것도 가능하다. 다음 예제는 그 방법을 보여준다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/http/server/clientaddress/CustomForwardedHeaderHandlerApplication.java**</small>

```java
import java.net.InetSocketAddress;

import reactor.core.publisher.Mono;
import reactor.netty.DisposableServer;
import reactor.netty.http.server.HttpServer;
import reactor.netty.transport.AddressUtils;

public class CustomForwardedHeaderHandlerApplication {

  public static void main(String[] args) {
    DisposableServer server = 
      HttpServer.create()
        .forwarded((connectionInfo, request) -> {  // (1)
          String hostHeader = request.headers().get("X-Forwarded-Host");
          if (hostHeader != null) {
            String[] hosts = hostHeader.split(",", 2);
            InetSocketAddress hostAddress = 
              AddressUtils.createUnresolved(
                hosts[hosts.length - 1].trim(),
                connectionInfo.getHostAddress().getPort());
            connectionInfo = connectionInfo.withHostAddress(hostAddress);
          }
          return connectionInfo;
        })
        .route(routes ->
          routes.get("/clientip",
            (request, response) ->
              response.sendString(Mono.just(request.remoteAddress() // (2)
                                      .getHostString()))))
        .bindNow();

    server.onDispose()
      .block();
  }
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 커스텀 헤더 핸들러를 추가한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 리모트(클라이언트) 피어의 주소를 반환한다.</small>

### 5.4.2. HTTP Request Decoder

기본적으로 **네티**는 요청을 수신할 때 다음과 같은 제약을 설정한다:

- 첫 라인의 최대 길이.
- 전체 헤더의 최대 길이.
- 컨텐츠나 각 청크의 최대 길이.

자세한 정보는 [`HttpRequestDecoder`](https://netty.io/4.1/api/io/netty/handler/codec/http/HttpRequestDecoder.html)와 [`HttpServerUpgradeHandler`](https://netty.io/4.1/api/io/netty/handler/codec/http/HttpServerUpgradeHandler.html)를 참고해라.

**HTTP** 서버는 디폴트로 다음과 같이 세팅된다:

<small>**./../../reactor-netty-http/src/main/java/reactor/netty/http/HttpDecoderSpec.java**</small>

```java
public static final int DEFAULT_MAX_INITIAL_LINE_LENGTH = 4096;
public static final int DEFAULT_MAX_HEADER_SIZE         = 8192;
public static final int DEFAULT_MAX_CHUNK_SIZE          = 8192;
public static final boolean DEFAULT_VALIDATE_HEADERS    = true;
public static final int DEFAULT_INITIAL_BUFFER_SIZE     = 128;
```

<small>**./../../reactor-netty-http/src/main/java/reactor/netty/http/server/HttpRequestDecoderSpec.java**</small>

```java
/**
 * The maximum length of the content of the HTTP/2.0 clear-text upgrade request.
 * By default the server will reject an upgrade request with non-empty content,
 * because the upgrade request is most likely a GET request.
 */
public static final int DEFAULT_H2C_MAX_CONTENT_LENGTH = 0;
```

디폴트 세팅을 바꾸고 싶다면 다음과 같이 **HTTP** 서버를 설정해라:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/http/server/requestdecoder/Application.java**</small>

```java
import reactor.core.publisher.Mono;
import reactor.netty.DisposableServer;
import reactor.netty.http.server.HttpServer;

public class Application {

	public static void main(String[] args) {
		DisposableServer server =
				HttpServer.create()
				          .httpRequestDecoder(spec -> spec.maxHeaderSize(16384)) 
				          .handle((request, response) -> response.sendString(Mono.just("hello")))
				          .bindNow();

		server.onDispose()
		      .block();
	}
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 전체 헤더의 최대 길이는 **16384**가 된다. 이 값을 초과하면 [TooLongFrameException](https://netty.io/4.1/api/io/netty/handler/codec/TooLongFrameException.html)이 발생한다.</small>

---

## 5.5. TCP-level Configuration

TCP 레벨 설정을 바꾸고 싶다면 다음과 같은 코드로 디폴트 **TCP** 서버 설정을 확장하면 된다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/http/server/channeloptions/Application.java**</small>

```java
import io.netty.channel.ChannelOption;
import reactor.netty.DisposableServer;
import reactor.netty.http.server.HttpServer;

public class Application {

	public static void main(String[] args) {
		DisposableServer server =
				HttpServer.create()
				          .option(ChannelOption.CONNECT_TIMEOUT_MILLIS, 10000)
				          .bindNow();

		server.onDispose()
		      .block();
	}
}
```

TCP 레벨 설정에 대한 자세한 정보는 [TCP 서버](../tcpserver)를 참고해라.

### 5.5.1. Wire Logger

**리액터 네티**는 피어 간의 트래픽을 살펴보기 위한 wire 로깅을 제공한다. 기본적으로 wire 로깅은 비활성화돼 있다. 활성화하려면 로거의 `reactor.netty.http.server.HttpServer` 레벨을 `DEBUG`로 설정하고 아래 설정을 적용해야 한다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/http/server/wiretap/Application.java**</small>

```java
import reactor.netty.DisposableServer;
import reactor.netty.http.server.HttpServer;

public class Application {

	public static void main(String[] args) {
		DisposableServer server =
				HttpServer.create()
				          .wiretap(true) // (1)
				          .bindNow();

		server.onDispose()
		      .block();
	}
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> wire 로깅을 활성화한다.</small>

---

## 5.6. SSL and TLS

SSL나 TLS가 필요하다면 아래에 있는 설정을 사용하면 된다. 기본적으로 **OpenSSL**을 사용할 수 있다면, [`SslProvider.OPENSSL`](https://netty.io/4.1/api/io/netty/handler/ssl/SslProvider.html#OPENSSL)을 provider로 선택한다. 그렇지 않으면 [`SslProvider.JDK`](https://netty.io/4.1/api/io/netty/handler/ssl/SslProvider.html#JDK)를 사용한다. [`SslContextBuilder`](https://netty.io/4.1/api/io/netty/handler/ssl/SslContextBuilder.html#sslProvider-io.netty.handler.ssl.SslProvider-)를 사용하거나 `-Dio.netty.handler.ssl.noOpenSsl=true`를 설정하면 provider를 바꿀 수 있다.

다음 예제는 `SslContextBuilder`를 사용한다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/http/server/security/Application.java**</small>

```java
import io.netty.handler.ssl.SslContextBuilder;
import reactor.netty.DisposableServer;
import reactor.netty.http.server.HttpServer;
import java.io.File;

public class Application {

	public static void main(String[] args) {
		File cert = new File("certificate.crt");
		File key = new File("private.key");

		SslContextBuilder sslContextBuilder = SslContextBuilder.forServer(cert, key);

		DisposableServer server =
				HttpServer.create()
				          .secure(spec -> spec.sslContext(sslContextBuilder))
				          .bindNow();

		server.onDispose()
		      .block();
	}
}
```

### 5.6.1. Server Name Indication

**HTTP** 서버는 특정 도메인에 매핑하는 식으로 `SslContext`를 여러 개 설정할 수 있다. `SNI` 매핑은 정확한 도메인명도, 와일드카드가 있는 도메인명도 가능하다.

아래 예제는 와일드카드가 있는 도메인명을 사용한다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/http/server/sni/Application.java**</small>

```java
import io.netty.handler.ssl.SslContext;
import io.netty.handler.ssl.SslContextBuilder;
import reactor.netty.DisposableServer;
import reactor.netty.http.server.HttpServer;

import java.io.File;

public class Application {

	public static void main(String[] args) throws Exception {
		File defaultCert = new File("default_certificate.crt");
		File defaultKey = new File("default_private.key");

		File testDomainCert = new File("default_certificate.crt");
		File testDomainKey = new File("default_private.key");

		SslContext defaultSslContext = SslContextBuilder.forServer(defaultCert, defaultKey).build();
		SslContext testDomainSslContext = SslContextBuilder.forServer(testDomainCert, testDomainKey).build();

		DisposableServer server =
				HttpServer.create()
				          .secure(spec -> spec.sslContext(defaultSslContext)
				                              .addSniMapping("*.test.com",
				                                      testDomainSpec -> testDomainSpec.sslContext(testDomainSslContext)))
				          .bindNow();

		server.onDispose()
		      .block();
	}
}
```

---

## 5.7. HTTP Access Log

현재 로깅은 [기본 로그 포맷](https://en.wikipedia.org/wiki/Common_Log_Format)만 지원한다.

**HTTP** 액세스 로그를 활성화려면 `-Dreactor.netty.http.server.accessLogEnabled=true`를 사용하면 된다. 기본적으로는 비활성화돼 있다.

별도 **HTTP** 액세스 로그 파일은 다음과 같이 설정한다 (로그백 또는 유사한 로깅 프레임워크 용):

```xml
<appender name="accessLog" class="ch.qos.logback.core.FileAppender">
    <file>access_log.log</file>
    <encoder>
        <pattern>%msg%n</pattern>
    </encoder>
</appender>
<appender name="async" class="ch.qos.logback.classic.AsyncAppender">
    <appender-ref ref="accessLog" />
</appender>

<logger name="reactor.netty.http.server.AccessLog" level="INFO" additivity="false">
    <appender-ref ref="async"/>
</logger>
```

---

## 5.8. HTTP/2

기본적으로 **HTTP** 서버는 **HTTP/1.1**을 지원한다. **HTTP/2**가 필요하다면, 설정을 통해 가능하다. 프로토콜 설정 외에도, **H2C(cleartext)**가 아닌 **H2**를 사용해야 한다면 SSL을 함께 설정해야 한다.

> JDK8은 그 자체만으로 Application-Layer Protocol Negotiation(ALPN)을 지원하지는 않기 때문에 (몇몇 벤더들은 JDK8에 ALPN을 추가해서 배포하긴 했지만), 이를 지원하는 네이티브 라이브러리 의존성을 별도로 추가해야 한다 — 예를 들어 [`netty-tcnative-boringssl-static`](https://netty.io/wiki/forked-tomcat-native.html).

다음은 간단한 **H2** 사용 예시다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/http/server/http2/H2Application.java**</small>

```java
import io.netty.handler.ssl.SslContextBuilder;
import reactor.core.publisher.Mono;
import reactor.netty.DisposableServer;
import reactor.netty.http.HttpProtocol;
import reactor.netty.http.server.HttpServer;
import java.io.File;

public class H2Application {

	public static void main(String[] args) {
		File cert = new File("certificate.crt");
		File key = new File("private.key");

		SslContextBuilder sslContextBuilder = SslContextBuilder.forServer(cert, key);

		DisposableServer server =
				HttpServer.create()
				          .port(8080)
				          .protocol(HttpProtocol.H2)    // (1)                      
				          .secure(spec -> spec.sslContext(sslContextBuilder)) // (2)
				          .handle((request, response) -> response.sendString(Mono.just("hello")))
				          .bindNow();

		server.onDispose()
		      .block();
	}
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> **HTTP/2**만 지원하는 서버로 설정한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> **SSL**을 설정한다.</small>

이제 어플리케이션은 다음과 같이 동작한다:

```bash
$ curl --http2 https://localhost:8080 -i
HTTP/2 200

hello
```

다음은 간단한 **H2C** 사용 예시다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/http/server/http2/H2CApplication.java**</small>

```java
import reactor.core.publisher.Mono;
import reactor.netty.DisposableServer;
import reactor.netty.http.HttpProtocol;
import reactor.netty.http.server.HttpServer;

public class H2CApplication {

	public static void main(String[] args) {
		DisposableServer server =
				HttpServer.create()
				          .port(8080)
				          .protocol(HttpProtocol.H2C)
				          .handle((request, response) -> response.sendString(Mono.just("hello")))
				          .bindNow();

		server.onDispose()
		      .block();
	}
}
```

이제 어플리케이션은 다음과 같이 동작한다:

```bash
$ curl --http2-prior-knowledge http://localhost:8080 -i
HTTP/2 200

hello
```

### 5.8.1. Protocol Selection

<small>**./../../reactor-netty-http/src/main/java/reactor/netty/http/HttpProtocol.java**</small>

```java
public enum HttpProtocol {

	/**
	 * The default supported HTTP protocol by HttpServer and HttpClient
	 */
	HTTP11,

	/**
	 * HTTP/2.0 support with TLS
	 * <p>If used along with HTTP/1.1 protocol, HTTP/2.0 will be the preferred protocol.
	 * While negotiating the application level protocol, HTTP/2.0 or HTTP/1.1 can be chosen.
	 * <p>If used without HTTP/1.1 protocol, HTTP/2.0 will always be offered as a protocol
	 * for communication with no fallback to HTTP/1.1.
	 */
	H2,

	/**
	 * HTTP/2.0 support with clear-text.
	 * <p>If used along with HTTP/1.1 protocol, will support H2C "upgrade":
	 * Request or consume requests as HTTP/1.1 first, looking for HTTP/2.0 headers
	 * and {@literal Connection: Upgrade}. A server will typically reply a successful
	 * 101 status if upgrade is successful or a fallback HTTP/1.1 response. When
	 * successful the client will start sending HTTP/2.0 traffic.
	 * <p>If used without HTTP/1.1 protocol, will support H2C "prior-knowledge": Doesn't
	 * require {@literal Connection: Upgrade} handshake between a client and server but
	 * fallback to HTTP/1.1 will not be supported.
	 */
	H2C
}
```

---

## 5.9. Metrics

HTTP 서버는 [**Micrometer**](https://micrometer.io/) 통합 지원을 내장하고 있다. 프리픽스로 `reactor.netty.http.server`를 사용하는 모든 메트릭에 해당한다.

아래 테이블은 HTTP 서버 메트릭에 대한 정보를 담고 있다:

| metric name                                  | type                | description                             |
| :------------------------------------------- | :------------------ | :-------------------------------------- |
| reactor.netty.http.server.data.received      | DistributionSummary | 데이터 수신량 (바이트 단위)             |
| reactor.netty.http.server.data.sent          | DistributionSummary | 데이터 전송량 (바이트 단위)             |
| reactor.netty.http.server.errors             | Counter             | 에러 발생 횟수                          |
| reactor.netty.http.server.data.received.time | Timer               | 수신 데이터를 컨슈밍하는 데 소요된 시간 |
| reactor.netty.http.server.data.sent.time     | Timer               | 발송 데이터를 전송하는 데 소요된 시간   |
| reactor.netty.http.server.response.time      | Timer               | 요청/응답에 걸린 전체 시간              |

추가로 다음 메트릭도 사용할 수 있다:

`ByteBufAllocator` 메트릭

| metric name                                             | type  | description                                                 |
| :------------------------------------------------------ | :---- | :---------------------------------------------------------- |
| reactor.netty.bytebuf.allocator.used.heap.memory        | Gauge | 힙 메모리의 바이트 수                                       |
| reactor.netty.bytebuf.allocator.used.direct.memory      | Gauge | 다이렉트 메모리의 바이트 수                                 |
| reactor.netty.bytebuf.allocator.used.heap.arenas        | Gauge | 힙 arena 수 (`PooledByteBufAllocator`를 사용할 때))         |
| reactor.netty.bytebuf.allocator.used.direct.arenas      | Gauge | 다이렉트 arena 수 (`PooledByteBufAllocator`를 사용할 때))   |
| reactor.netty.bytebuf.allocator.used.threadlocal.caches | Gauge | 스레드 로컬 캐시 수 (`PooledByteBufAllocator`를 사용할 때)) |
| reactor.netty.bytebuf.allocator.used.tiny.cache.size    | Gauge | tiny 캐시 사이즈 (`PooledByteBufAllocator`를 사용할 때))    |
| reactor.netty.bytebuf.allocator.used.small.cache.size   | Gauge | small 캐시 사이즈 (`PooledByteBufAllocator`를 사용할 때))   |
| reactor.netty.bytebuf.allocator.used.normal.cache.size  | Gauge | normal 캐시 사이즈 (`PooledByteBufAllocator`를 사용할 때))  |
| reactor.netty.bytebuf.allocator.used.chunk.size         | Gauge | arena의 청크 사이즈 (`PooledByteBufAllocator`를 사용할 때)) |

다음은 메트릭 통합을 활성화하는 예시다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/http/server/metrics/Application.java**</small>

```java
import io.micrometer.core.instrument.Metrics;
import io.micrometer.core.instrument.config.MeterFilter;
import reactor.core.publisher.Mono;
import reactor.netty.DisposableServer;
import reactor.netty.http.server.HttpServer;

public class Application {

  public static void main(String[] args) {
    Metrics.globalRegistry // (1)
      .config()
      .meterFilter(MeterFilter.maximumAllowableTags("reactor.netty.http.server", "URI", 100, MeterFilter.deny()));

    DisposableServer server =
      HttpServer.create()
        .metrics(true, s -> {
          if (s.startsWith("/stream/")) { // (2)
            return "/stream/{n}";
          }
          else if (s.startsWith("/bytes/")) {
            return "/bytes/{n}";
          }
          return s;
        }) // (3)
        .route(r ->
          r.get("/stream/{n}",
            (req, res) -> res.sendString(Mono.just(req.param("n"))))
                            .get("/bytes/{n}",
            (req, res) -> res.sendString(Mono.just(req.param("n")))))
        .bindNow();

    server.onDispose()
      .block();
  }
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `URI` 태그가 있는 미터에 상한을 적용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 가능하다면 템플릿 URI를 URI 태그 값으로 사용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 빌트인 Micrometer 인테그레이션을 활성화한다.</small>

> 메트릭 활성화로 인한 메모리, CPU 오버헤드를 방지하려면, 가능할 때마다 실제 URI를 템플릿 URI로 변환하는 게 좋다. 템플릿같은 형식으로 변환하지 않고 고유한 URI를 사용하면, 각자 고유한 태그를 생성하게 되고, 메트릭에 많은 메모리를 사용한다.

> URI 태그를 사용하는 미터에는 항상 상한을 정해야 한다. 미터 수에 상한을 설정하면, 실제 URI를 템플릿으로 만들 수 없는 경우 발생할 수 있는 문제를 해결할 수 있다. 자세한 정보는 [`maximumAllowableTags`](https://micrometer.io/docs/concepts#_denyaccept_meters)에서 확인할 수 있다.

**Micrometer** 외에 다른 시스템과 통합해서 HTTP 서버 메트릭을 보고 싶거나, 자체적으로 **Micrometer**를 통합하고 싶다면, 다음과 같이 자체 메트릭 레코더를 제공하면 된다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/http/server/metrics/custom/Application.java**</small>

```java
import reactor.core.publisher.Mono;
import reactor.netty.DisposableServer;
import reactor.netty.channel.ChannelMetricsRecorder;
import reactor.netty.http.server.HttpServer;

import java.net.SocketAddress;
import java.time.Duration;

public class Application {

  public static void main(String[] args) {
    DisposableServer server =
      HttpServer.create()
        .metrics(true, CustomHttpServerMetricsRecorder::new) // (1)
          .route(r ->
            r.get("/stream/{n}",
                (req, res) -> res.sendString(Mono.just(req.param("n"))))
              .get("/bytes/{n}",
                (req, res) -> res.sendString(Mono.just(req.param("n")))))
        .bindNow();

    server.onDispose()
      .block();
  }
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> HTTP 서버 메트릭을 활성화하고 [`HttpServerMetricsRecorder`](https://projectreactor.io/docs/netty/release/api/reactor/netty/http/server/HttpServerMetricsRecorder.html) 구현체를 제공한다.</small>

---

## 5.10. Unix Domain Sockets

native transport를 사용한다면, **HTTP** 서버는 [유닉스 도메인 소켓(UDS)](https://en.wikipedia.org/wiki/Unix_domain_socket)을 지원한다.

다음은 UDS 지원을 사용하는 예제다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/http/server/uds/Application.java**</small>

```java
import io.netty.channel.unix.DomainSocketAddress;
import reactor.netty.DisposableServer;
import reactor.netty.http.server.HttpServer;

public class Application {

	public static void main(String[] args) {
		DisposableServer server =
				HttpServer.create()
				          .bindAddress(() -> new DomainSocketAddress("/tmp/test.sock")) // (1)
				          .bindNow();

		server.onDispose()
		      .block();
	}
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 사용할 `DomainSocketAddress`를 지정한다.</small>

"[HTTP Server](https://projectreactor.io/docs/netty/1.0.1/reference/index.html#http-server)" [수정 제안하기](https://github.com/reactor/reactor-netty/edit/master/docs/asciidoc/http-server.adoc)