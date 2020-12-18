---
title: HTTP Client
category: Reactor Netty
order: 7
permalink: /Reactor%20Netty/httpclient/
description: 리액터 네티로 HTTP 클라이언트 설정하기 한글 번역
image: ./../../images/reactornetty/logo.png
lastmod: 2020-12-19T00:00:00+09:00
comments: true
originalRefName: 프로젝트 리액터 네티
originalRefLink: https://projectreactor.io/docs/netty/1.0.1/reference/index.html#http-client
---

### 목차

- [6.1. Connect](#61-connect)
  + [6.1.1. Host and Port](#611-host-and-port)
  + [6.2.1. Adding Headers and Other Metadata](#621-adding-headers-and-other-metadata)
    * [Compression](#compression)
    * [Auto-Redirect Support](#auto-redirect-support)
- [6.2. Writing Data](#62-writing-data)
- [6.3. Consuming Data](#63-consuming-data)
  + [6.3.1. Reading Headers and Other Metadata](#631-reading-headers-and-other-metadata)
  + [6.3.2. HTTP Response Decoder](#632-http-response-decoder)
- [6.4. TCP-level Configuration](#64-tcp-level-configuration)
  + [6.4.1. Wire Logger](#641-wire-logger)
- [6.5. SSL and TLS](#65-ssl-and-tls)
  + [6.5.1. Server Name Indication](#651-server-name-indication)
- [6.6. Retry Strategies](#66-retry-strategies)
- [6.7. HTTP/2](#67-http2)
  + [6.7.1. Protocol Selection](#671-protocol-selection)
- [6.8. Metrics](#68-metrics)
- [6.9. Unix Domain Sockets](#69-unix-domain-sockets)

---

리액터 네티는 사용하기도 설정하기도 쉬운 [`HttpClient`](https://projectreactor.io/docs/netty/release/api/reactor/netty/http/client/HttpClient.html)를 제공한다. `HttpClient`는 **HTTP** 클라이언트 생성에 필요한 네티 기능을 대부분 숨겨주고, 리액티브 스트림 backpressure를 추가해준다.

---

## 6.1. Connect

**HTTP** 클라이언트를 주어진 **HTTP** 엔드포인트로 연결하려면, 일단 [`HttpClient`](https://projectreactor.io/docs/netty/release/api/reactor/netty/http/client/HttpClient.html) 인스턴스를 만들어 설정해야 한다. 다음은 그 예시다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/http/client/connect/Application.java**</small>

```java
import reactor.netty.http.client.HttpClient;

public class Application {

	public static void main(String[] args) {
		HttpClient client = HttpClient.create();  // (1)

		client.get()                      // (2)
		      .uri("http://example.com/") // (3)
		      .response()                 // (4)
		      .block();
	}
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> [HttpClient](https://projectreactor.io/docs/netty/release/api/reactor/netty/http/client/HttpClient.html) 인스턴스를 생성한다. 이제 인스턴스를 설정할 준비가 되었다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 사용할 `GET` 메소드를 지정한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 패스를 지정한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> [HttpClientResponse](https://projectreactor.io/docs/netty/release/api/reactor/netty/http/client/HttpClientResponse.html) 응답을 가져온다.</small>

다음은 `WebSocket`을 사용하는 예제다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/http/client/websocket/Application.java**</small>

```java
import io.netty.buffer.Unpooled;
import io.netty.util.CharsetUtil;
import reactor.core.publisher.Flux;
import reactor.netty.http.client.HttpClient;

public class Application {

	public static void main(String[] args) {
		HttpClient client = HttpClient.create();

		client.websocket()
		      .uri("wss://echo.websocket.org")
		      .handle((inbound, outbound) -> {
		          inbound.receive()
		                 .asString()
		                 .take(1)
		                 .subscribe(System.out::println);

		          final byte[] msgBytes = "hello".getBytes(CharsetUtil.ISO_8859_1);
		          return outbound.send(Flux.just(Unpooled.wrappedBuffer(msgBytes), Unpooled.wrappedBuffer(msgBytes)))
		                         .neverComplete();
		      })
		      .blockLast();
	}
}
```

### 6.1.1. Host and Port

특정 호스트와 포트로 연결하고 싶다면, **HTTP** 클라이언트를 다음과 같이 설정하면 된다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/http/client/address/Application.java**</small>

```java
import reactor.netty.http.client.HttpClient;

public class Application {

	public static void main(String[] args) {
		HttpClient client =
				HttpClient.create()
				          .host("example.com") // (1)
				          .port(80);           // (2)

		client.get()
		      .uri("/")
		      .response()
		      .block();
	}
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> **HTTP**  호스트를 설정한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> **HTTP** 포트를 설정한다.</small>

---

## 6.2. Writing Data

[`send(Publisher)`](https://projectreactor.io/docs/netty/release/api/reactor/netty/http/client/HttpClient.RequestSender.html#send-org.reactivestreams.Publisher-) 메소드로 `Publisher`를 제공하면 주어진 **HTTP** 엔드포인트에 데이터를 전송할 수 있다. 기본적으로 요청 body가 있는 **HTTP** 메소드엔 `Transfer-Encoding: chunked`를 적용한다. 필요에 따라 요청 헤더에 `Content-Length`를 사용하면 `Transfer-Encoding: chunked`를 비활성화한다. 다음 예제는 `hello`를 전송한다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/http/client/send/Application.java**</small>

```java
import reactor.core.publisher.Mono;
import reactor.netty.ByteBufFlux;
import reactor.netty.http.client.HttpClient;

public class Application {

	public static void main(String[] args) {
		HttpClient client = HttpClient.create();

		client.post()
		      .uri("http://example.com/")
		      .send(ByteBufFlux.fromString(Mono.just("hello"))) // (1)
		      .response()
		      .block();
	}
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> **HTTP** 엔드포인트에 `hello`라는 문자열을 전송한다.</small>

### 6.2.1. Adding Headers and Other Metadata

주어진 **HTTP** 엔드포인트에 데이터를 전송할 땐, 별도의 헤더, 쿠키나 다른 기타 메타데이터를 함께 전송하기도 한다. 이런 별도 메타데이터는 다음과 같이 설정한다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/http/client/send/headers/Application.java**</small>

```java
import io.netty.handler.codec.http.HttpHeaderNames;
import reactor.core.publisher.Mono;
import reactor.netty.ByteBufFlux;
import reactor.netty.http.client.HttpClient;

public class Application {

	public static void main(String[] args) {
		HttpClient client =
				HttpClient.create()
				          .headers(h -> h.set(HttpHeaderNames.CONTENT_LENGTH, 5)); // (1)

		client.post()
		      .uri("http://example.com/")
		      .send(ByteBufFlux.fromString(Mono.just("hello")))
		      .response()
		      .block();
	}
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `Transfer-Encoding: chunked`를 비활성화하고 `Content-Length` 헤더를 제공한다.</small>

#### Compression

**HTTP** 클라이언트에 압축을 활성화할 수도 있다. 이땐 요청 헤더에 `Accept-Encoding` 헤더를 추가한다. 다음은 그 방법을 보여준다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/http/client/compression/Application.java**</small>

```java
import reactor.netty.http.client.HttpClient;

public class Application {

	public static void main(String[] args) {
		HttpClient client =
				HttpClient.create()
				          .compress(true);

		client.get()
		      .uri("http://example.com/")
		      .response()
		      .block();
	}
}
```

#### Auto-Redirect Support

**HTTP** 클라이언트가 자동 리다이렉트 지원하도록 설정할 수 있다.

리액터 네티는 자동 리다이렉트 지원을 위한 두 가지 전략을 제공한다:

- `followRedirect(boolean)`: 상태 코드 `301|302|307|308`에서 HTTP 자동 리다이렉트를 활성화할 지를 지정한다.
- `followRedirect(BiPredicate<HttpClientRequest, HttpClientResponse>)`: predicate가 매칭되면 자동 리다이렉트를 활성화한다.

다음 예제는 `followRedirect(true)`를 사용한다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/http/client/redirect/Application.java**</small>

```java
import reactor.netty.http.client.HttpClient;

public class Application {

	public static void main(String[] args) {
		HttpClient client =
				HttpClient.create()
				          .followRedirect(true);

		client.get()
		      .uri("http://example.com/")
		      .response()
		      .block();
	}
}
```

---

## 6.3. Consuming Data

주어진 **HTTP** 엔드포인트로부터 데이터를 받을 땐 [`HttpClient.ResponseReceiver`](https://projectreactor.io/docs/netty/release/api/reactor/netty/http/client/HttpClient.ResponseReceiver.html) 메소드 중 하나를 사용한다. 다음은 `responseContent` 메소드를 사용하는 예제다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/http/client/read/Application.java**</small>

```java
import reactor.netty.http.client.HttpClient;

public class Application {

	public static void main(String[] args) {
		HttpClient client = HttpClient.create();

		client.get()
		      .uri("http://example.com/")
		      .responseContent() // (1)
		      .aggregate()       // (2)
		      .asString()        // (3)
		      .block();
	}
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 주어진 **HTTP** 엔드포인트로부터 데이터를 받는다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 데이터를 집계한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 데이터를 문자열로 변형한다.</small>

### 6.3.1. Reading Headers and Other Metadata

주어진 **HTTP** 엔드포인트로부터 데이터를 수신할 땐, 응답 헤더, 상태 코드나 다른 기타 메타데이터를 확인해야 할 수도 있다. 이런 별도 메타데이터는 [`HttpClientResponse`](https://projectreactor.io/docs/netty/release/api/reactor/netty/http/client/HttpClientResponse.html)로 가져올 수 있다. 다음 예제는 그 방법을 보여준다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/http/client/read/status/Application.java**</small>

```java
import reactor.netty.http.client.HttpClient;

public class Application {

	public static void main(String[] args) {
		HttpClient client = HttpClient.create();

		client.get()
		      .uri("http://example.com/")
		      .responseSingle((resp, bytes) -> {
		          System.out.println(resp.status()); // (1)
		          return bytes.asString();
		      })
		      .block();
	}
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 상태 코드를 가져온다.</small>

### 6.3.2. HTTP Response Decoder

기본적으로 **네티**는 응답을 수신할 때 다음과 같은 제약을 설정한다:

- 첫 라인의 최대 길이.
- 전체 헤더의 최대 길이.
- 컨텐츠나 각 청크의 최대 길이.

자세한 정보는 [`HttpResponseDecoder`](https://netty.io/4.1/api/io/netty/handler/codec/http/HttpResponseDecoder.html)를 참고해라.

**HTTP** 클라이언트는 디폴트로 다음과 같이 세팅된다:

<small>**./../../reactor-netty-http/src/main/java/reactor/netty/http/HttpDecoderSpec.java**</small>

```java
public static final int DEFAULT_MAX_INITIAL_LINE_LENGTH = 4096;
public static final int DEFAULT_MAX_HEADER_SIZE         = 8192;
public static final int DEFAULT_MAX_CHUNK_SIZE          = 8192;
public static final boolean DEFAULT_VALIDATE_HEADERS    = true;
public static final int DEFAULT_INITIAL_BUFFER_SIZE     = 128;
```

<small>**./../../reactor-netty-http/src/main/java/reactor/netty/http/client/HttpResponseDecoderSpec.java**</small>

```java
public static final boolean DEFAULT_FAIL_ON_MISSING_RESPONSE         = false;
public static final boolean DEFAULT_PARSE_HTTP_AFTER_CONNECT_REQUEST = false;

/**
 * The maximum length of the content of the HTTP/2.0 clear-text upgrade request.
 * By default the client will allow an upgrade request with up to 65536 as
 * the maximum length of the aggregated content.
 */
public static final int DEFAULT_H2C_MAX_CONTENT_LENGTH = 65536;
```

디폴트 세팅을 바꾸고 싶다면 다음과 같이 **HTTP** 클라이언트를 설정해라:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/http/client/responsedecoder/Application.java**</small>

```java
import reactor.netty.http.client.HttpClient;

public class Application {

	public static void main(String[] args) {
		HttpClient client =
				HttpClient.create()
				          .httpResponseDecoder(spec -> spec.maxHeaderSize(16384)); // (1)

		client.get()
		      .uri("http://example.com/")
		      .responseContent()
		      .aggregate()
		      .asString()
		      .block();
	}
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 전체 헤더의 최대 길이는 **16384**가 된다. 이 값을 초과하면 [TooLongFrameException](https://netty.io/4.1/api/io/netty/handler/codec/TooLongFrameException.html)이 발생한다.</small>

---

## 6.4. TCP-level Configuration

TCP 레벨 설정을 바꾸고 싶다면 다음과 같은 코드로 디폴트 **TCP** 클라이언트 설정을 확장하면 된다 (옵션 추가, 주소 바인딩 등):

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/http/client/channeloptions/Application.java**</small>

```java
import io.netty.channel.ChannelOption;
import reactor.netty.http.client.HttpClient;
import java.net.InetSocketAddress;

public class Application {

	public static void main(String[] args) {
		HttpClient client =
				HttpClient.create()
				          .bindAddress(() -> new InetSocketAddress("host", 1234))
				          .option(ChannelOption.CONNECT_TIMEOUT_MILLIS, 10000);

		String response =
				client.get()
				      .uri("http://example.com/")
				      .responseContent()
				      .aggregate()
				      .asString()
				      .block();

		System.out.println("Response " + response);
	}
}
```

TCP 레벨 설정에 대한 자세한 정보는 [TCP 클라이언트](../tcpclient)를 참고해라.

### 6.4.1. Wire Logger

리액터 네티는 피어 간의 트래픽을 살펴보기 위한 wire 로깅을 제공한다. 기본적으로 wire 로깅은 비활성화돼 있다. 활성화하려면 로거의 `reactor.netty.http.client.HttpClient` 레벨을 `DEBUG`로 설정하고 아래 설정을 적용해야 한다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/http/client/wiretap/Application.java**</small>

```java
import reactor.netty.http.client.HttpClient;

public class Application {

	public static void main(String[] args) {
		HttpClient client =
				HttpClient.create()
				          .wiretap(true); // (1)

		client.get()
		      .uri("http://example.com/")
		      .response()
		      .block();
	}
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> wire 로깅을 활성화한다.</small>

---

## 6.5. SSL and TLS

SSL나 TLS가 필요하다면 아래에 있는 설정을 사용하면 된다. 기본적으로 **OpenSSL**을 사용할 수 있다면, [`SslProvider.OPENSSL`](https://netty.io/4.1/api/io/netty/handler/ssl/SslProvider.html#OPENSSL)을 provider로 선택한다. 그렇지 않으면 [`SslProvider.JDK`](https://netty.io/4.1/api/io/netty/handler/ssl/SslProvider.html#JDK)를 사용한다. [`SslContextBuilder`](https://netty.io/4.1/api/io/netty/handler/ssl/SslContextBuilder.html#sslProvider-io.netty.handler.ssl.SslProvider-)를 사용하거나 `-Dio.netty.handler.ssl.noOpenSsl=true`를 설정하면 provider를 바꿀 수 있다. 다음 예제는 `SslContextBuilder`를 사용한다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/http/client/security/Application.java**</small>

```java
import io.netty.handler.ssl.SslContextBuilder;
import reactor.netty.http.client.HttpClient;

public class Application {

	public static void main(String[] args) {
		SslContextBuilder sslContextBuilder = SslContextBuilder.forClient();

		HttpClient client =
				HttpClient.create()
				          .secure(spec -> spec.sslContext(sslContextBuilder));

		client.get()
		      .uri("https://example.com/")
		      .response()
		      .block();
	}
}
```

### 6.5.1. Server Name Indication

**HTTP** 클라이언트는 기본적으로 리모트 호스트명을 `SNI` 서버명으로 전송한다. 이 디폴트 설정을 바꾸려면 다음과 같이 **HTTP** 클라이언트를 설정하면 된다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/http/client/sni/Application.java**</small>

```java
import io.netty.handler.ssl.SslContext;
import io.netty.handler.ssl.SslContextBuilder;
import reactor.netty.http.client.HttpClient;

import javax.net.ssl.SNIHostName;

public class Application {

	public static void main(String[] args) throws Exception {
		SslContext sslContext = SslContextBuilder.forClient().build();

		HttpClient client =
				HttpClient.create()
				          .secure(spec -> spec.sslContext(sslContext)
				                              .serverNames(new SNIHostName("test.com")));

		client.get()
		      .uri("https://127.0.0.1:8080/")
		      .response()
		      .block();
	}
}
```

---

## 6.6. Retry Strategies

기본적으로 **HTTP** 클라이언트는 **TCP** 레벨에서 중단되면 요청을 한 번 재시도한다.

---

## 6.7. HTTP/2

기본적으로 **HTTP** 클라이언트는 **HTTP/1.1**을 지원한다. **HTTP/2**가 필요하다면, 설정을 통해 가능하다. 프로토콜 설정 외에도, **H2C(cleartext)**가 아닌 **H2**를 사용해야 한다면 SSL을 함께 설정해야 한다.

> JDK8은 그 자체만으로 Application-Layer Protocol Negotiation(ALPN)을 지원하지는 않기 때문에 (몇몇 벤더들은 JDK8에 ALPN을 추가해서 배포하긴 했지만), 이를 지원하는 네이티브 라이브러리 의존성을 별도로 추가해야 한다 — 예를 들어 [`netty-tcnative-boringssl-static`](https://netty.io/wiki/forked-tomcat-native.html).

다음은 간단한 **H2** 사용 예시다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/http/client/http2/H2Application.java**</small>

```java
import io.netty.handler.codec.http.HttpHeaders;
import reactor.core.publisher.Mono;
import reactor.netty.http.HttpProtocol;
import reactor.netty.http.client.HttpClient;
import reactor.util.function.Tuple2;

public class H2Application {

	public static void main(String[] args) {
		HttpClient client =
				HttpClient.create()
				          .protocol(HttpProtocol.H2) // (1)
				          .secure();                 // (2)

		Tuple2<String, HttpHeaders> response =
				client.get()
				      .uri("https://example.com/")
				      .responseSingle((res, bytes) -> bytes.asString()
				                                           .zipWith(Mono.just(res.responseHeaders())))
				      .block();

		System.out.println("Used stream ID: " + response.getT2().get("x-http2-stream-id"));
		System.out.println("Response: " + response.getT1());
	}
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> **HTTP/2**만 지원하는 클라이언트로 설정한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> **SSL**을 설정한다.</small>

다음은 간단한 **H2C** 사용 예시다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/http/client/http2/H2CApplication.java**</small>

```java
import io.netty.handler.codec.http.HttpHeaders;
import reactor.core.publisher.Mono;
import reactor.netty.http.HttpProtocol;
import reactor.netty.http.client.HttpClient;
import reactor.util.function.Tuple2;

public class H2CApplication {

	public static void main(String[] args) {
		HttpClient client =
				HttpClient.create()
				          .protocol(HttpProtocol.H2C);

		Tuple2<String, HttpHeaders> response =
				client.get()
				      .uri("http://localhost:8080/")
				      .responseSingle((res, bytes) -> bytes.asString()
				                                           .zipWith(Mono.just(res.responseHeaders())))
				      .block();

		System.out.println("Used stream ID: " + response.getT2().get("x-http2-stream-id"));
		System.out.println("Response: " + response.getT1());
	}
}
```

### 6.7.1. Protocol Selection

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

## 6.8. Metrics

HTTP 클라이언트는 [**Micrometer**](https://micrometer.io/) 통합 지원을 내장하고 있다. 프리픽스로 `reactor.netty.http.client`를 사용하는 모든 메트릭에 해당한다.

아래 테이블은 HTTP 클라이언트 메트릭에 대한 정보를 담고 있다:

| metric name                                  | type                | description                                |
| :------------------------------------------- | :------------------ | :----------------------------------------- |
| reactor.netty.http.client.data.received      | DistributionSummary | 데이터 수신량 (바이트 단위)                |
| reactor.netty.http.client.data.sent          | DistributionSummary | 데이터 전송량 (바이트 단위)                |
| reactor.netty.http.client.errors             | Counter             | 에러 발생 횟수                             |
| reactor.netty.http.client.tls.handshake.time | Timer               | TLS 핸드셰이크에 소요된 시간               |
| reactor.netty.http.client.connect.time       | Timer               | 리모트 주소에 커넥션을 맺을 때 소요된 시간 |
| reactor.netty.http.client.address.resolver   | Timer               | 주소를 리졸브할 때 소요된 시간             |
| reactor.netty.http.client.data.received.time | Timer               | 수신 데이터를 컨슈밍하는 데 소요된 시간    |
| reactor.netty.http.client.data.sent.time     | Timer               | 발송 데이터를 전송하는 데 소요된 시간      |
| reactor.netty.http.client.response.time      | Timer               | 요청/응답에 걸린 전체 시간                 |

추가로 다음 메트릭도 사용할 수 있다:

Pooled `ConnectionProvider` 메트릭

| metric name                                           | type  | description                               |
| :---------------------------------------------------- | :---- | :---------------------------------------- |
| reactor.netty.connection.provider.total.connections   | Gauge | 활성 상태 또는 유휴 상태인 모든 커넥션 수 |
| reactor.netty.connection.provider.active.connections  | Gauge | 획득에 성공한 활성 상태 커넥션 수         |
| reactor.netty.connection.provider.idle.connections    | Gauge | 유휴 커넥션 수                            |
| reactor.netty.connection.provider.pending.connections | Gauge | 커넥션을 기다리고 있는 요청 수            |

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

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/http/client/metrics/Application.java**</small>

```java
import io.micrometer.core.instrument.Metrics;
import io.micrometer.core.instrument.config.MeterFilter;
import reactor.netty.http.client.HttpClient;

public class Application {

	public static void main(String[] args) {
		Metrics.globalRegistry // (1)
		       .config()
		       .meterFilter(MeterFilter.maximumAllowableTags("reactor.netty.http.client", "URI", 100, MeterFilter.deny()));

		HttpClient client =
				HttpClient.create()
				          .metrics(true, s -> {
				              if (s.startsWith("/stream/")) { // (2)
				                  return "/stream/{n}";
				              }
				              else if (s.startsWith("/bytes/")) {
				                  return "/bytes/{n}";
				              }
				              return s;
				          }); // (3)

		client.get()
		      .uri("http://httpbin.org/stream/2")
		      .responseContent()
		      .blockLast();

		client.get()
		      .uri("http://httpbin.org/bytes/1024")
		      .responseContent()
		      .blockLast();
	}
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `URI` 태그가 있는 미터에 상한을 적용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 가능하다면 템플릿 URI를 URI 태그 값으로 사용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 빌트인 Micrometer 인테그레이션을 활성화한다.</small>

> 메트릭 활성화로 인한 메모리, CPU 오버헤드를 방지하려면, 가능할 때마다 실제 URI를 템플릿 URI로 변환하는 게 좋다. 템플릿같은 형식으로 변환하지 않고 고유한 URI를 사용하면, 각자 고유한 태그를 생성하게 되고, 메트릭에 많은 메모리를 사용한다.

> URI 태그를 사용하는 미터에는 항상 상한을 정해야 한다. 미터 수에 상한을 설정하면, 실제 URI를 템플릿으로 만들 수 없는 경우 발생할 수 있는 문제를 해결할 수 있다. 자세한 정보는 [`maximumAllowableTags`](https://micrometer.io/docs/concepts#_denyaccept_meters)에서 확인할 수 있다.

**Micrometer** 외에 다른 시스템과 통합해서 HTTP 클라이언트 메트릭을 보고 싶거나, 자체적으로 **Micrometer**를 통합하고 싶다면, 다음과 같이 자체 메트릭 레코더를 제공하면 된다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/http/client/metrics/custom/Application.java**</small>

```java
import reactor.netty.channel.ChannelMetricsRecorder;
import reactor.netty.http.client.HttpClient;

import java.net.SocketAddress;
import java.time.Duration;

public class Application {

	public static void main(String[] args) {
		HttpClient client =
				HttpClient.create()
				          .metrics(true, CustomHttpClientMetricsRecorder::new); // (1)

		client.get()
		      .uri("https://httpbin.org/stream/2")
		      .response()
		      .block();
	}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> HTTP 클라이언트 메트릭을 활성화하고 [`HttpClientMetricsRecorder`](https://projectreactor.io/docs/netty/release/api/reactor/netty/http/client/HttpClientMetricsRecorder.html) 구현체를 제공한다.</small>

---

## 6.9. Unix Domain Sockets

native transport를 사용한다면, **HTTP** 클라이언트는 [유닉스 도메인 소켓(UDS)](https://en.wikipedia.org/wiki/Unix_domain_socket)을 지원한다.

다음은 UDS 지원을 사용하는 예제다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/http/client/uds/Application.java**</small>

```java
import io.netty.channel.unix.DomainSocketAddress;
import reactor.netty.http.client.HttpClient;

public class Application {

	public static void main(String[] args) {
		HttpClient client =
				HttpClient.create()
				          .remoteAddress(() -> new DomainSocketAddress("/tmp/test.sock")); 

		client.get()
		      .uri("/")
		      .response()
		      .block();
	}
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 사용할 `DomainSocketAddress`를 지정한다.</small>

"[HTTP Client](https://projectreactor.io/docs/netty/1.0.1/reference/index.html#http-client)" [수정 제안하기](https://github.com/reactor/reactor-netty/edit/master/docs/asciidoc/http-client.adoc)