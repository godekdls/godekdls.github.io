---
title: TCP Server
category: Reactor Netty
order: 4
permalink: /Reactor%20Netty/tcpserver/
description: 리액터 네티로 TCP 서버 설정하기 한글 번역
image: ./../../images/reactornetty/logo.png
lastmod: 2020-12-19T00:00:00+09:00
comments: true
originalRefName: 프로젝트 리액터 네티
originalRefLink: https://projectreactor.io/docs/netty/1.0.1/reference/index.html#tcp-server
---

### 목차

- [3.1. Starting and Stopping](#31-starting-and-stopping)
  + [3.1.1. Host and Port](#311-host-and-port)
- [3.2. Writing Data](#32-writing-data)
- [3.3. Consuming Data](#33-consuming-data)
- [3.4. Lifecycle Callbacks](#34-lifecycle-callbacks)
- [3.5. TCP-level Configurations](#35-tcp-level-configurations)
  + [3.5.1. Setting Channel Options](#351-setting-channel-options)
  + [3.5.2. Using a Wire Logger](#352-using-a-wire-logger)
  + [3.5.3. Using an Event Loop Group](#353-using-an-event-loop-group)
- [3.6. SSL and TLS](#36-ssl-and-tls)
  + [3.6.1. Server Name Indication](#361-server-name-indication)
- [3.7. Metrics](#37-metrics)
- [3.8. Unix Domain Sockets](#38-unix-domain-sockets)

---

**리액터 네티**를 사용하면 손쉽게 [`TcpServer`](https://projectreactor.io/docs/netty/release/api/reactor/netty/tcp/TcpServer.html)를 설정할 수 있다. `TcpServer`는 **TCP** 서버 생성에 필요한 **네티** 기능을 대부분 숨겨주고, **리액티브 스트림** backpressure를 추가해준다.

---

## 3.1. Starting and Stopping

**TCP** 서버를 시작하려면 일단 [`TcpServer`](https://projectreactor.io/docs/netty/release/api/reactor/netty/tcp/TcpServer.html) 인스턴스를 만들어 설정해야 한다. 기본적으로 **호스트**는 모든 로컬 주소로 설정되며, `bind` 연산이 실행될 때 시스템에서 임의의 포트(ephemeral port)를 선택한다. 다음은 `TcpServer` 인스턴스를 생성하고 설정하는 예시다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/tcp/server/create/Application.java**</small>

```java
import reactor.netty.DisposableServer;
import reactor.netty.tcp.TcpServer;

public class Application {

	public static void main(String[] args) {
		DisposableServer server =
				TcpServer.create()   // (1)
				         .bindNow(); // (2)

		server.onDispose()
		      .block();
	}
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> [`TcpServer`](https://projectreactor.io/docs/netty/release/api/reactor/netty/tcp/TcpServer.html) 인스턴스를 생성한다. 이제 인스턴스를 설정할 준비가 되었다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 서버를 블로킹 방식으로 시작하고 초기화를 마치길 기다린다.</small>

반환된 [`DisposableServer`](https://projectreactor.io/docs/netty/release/api/reactor/netty/DisposableServer.html)는 블로킹 방식으로 서버를 셧다운 시켜주는 [`disposeNow()`](https://projectreactor.io/docs/netty/release/api/reactor/netty/DisposableChannel.html#disposeNow-java.time.Duration-)를 포함하는, 간단한 서버 API를 제공한다.

### 3.1.1. Host and Port

특정 **호스트**와 **포트**로 서빙하고 싶다면, **TCP** 서버를 다음과 같이 설정하면 된다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/tcp/server/address/Application.java**</small>

```java
import reactor.netty.DisposableServer;
import reactor.netty.tcp.TcpServer;

public class Application {

	public static void main(String[] args) {
		DisposableServer server =
				TcpServer.create()
				         .host("localhost") // (1)
				         .port(8080)        // (2)
				         .bindNow();

		server.onDispose()
		      .block();
	}
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `TCP` 서버 호스트를 설정한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> `TCP` 서버 포트를 설정한다.</small>

---

## 3.2. Writing Data

연결된 클라이언트에 데이터를 전송하려면 I/O 핸들러를 연결해야 한다. I/O 핸들러는 [`NettyOutbound`](https://projectreactor.io/docs/netty/release/api/reactor/netty/NettyOutbound.html)에 접근할 수 있어 데이터를 write할 수 있다. 다음은 I/O 핸들러를 연결하는 예시다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/tcp/server/send/Application.java**</small>

```java
import reactor.netty.DisposableServer;
import reactor.netty.tcp.TcpServer;

public class Application {

	public static void main(String[] args) {
		DisposableServer server =
				TcpServer.create()
				         .handle((inbound, outbound) -> outbound.sendString(Mono.just("hello"))) // (1)
				         .bindNow();

		server.onDispose()
		      .block();
	}
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 연결된 클라이언트에 `hello`라는 문자열을 전송한다.</small>

---

## 3.3. Consuming Data

연결된 클라이언트로부터 데이터를 받으려면 I/O 핸들러를 연결해야 한다. I/O 핸들러는 [`NettyInbound`](https://projectreactor.io/docs/netty/release/api/reactor/netty/NettyInbound.html)에 접근할 수 있어 데이터를 읽을 수 있다. 다음은 I/O 핸들러를 연결하는 예시다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/tcp/server/read/Application.java**</small>

```java
import reactor.netty.DisposableServer;
import reactor.netty.tcp.TcpServer;

public class Application {

	public static void main(String[] args) {
		DisposableServer server =
				TcpServer.create()
				         .handle((inbound, outbound) -> inbound.receive().then()) // (1)
				         .bindNow();

		server.onDispose()
		      .block();
	}
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 연결된 클라이언트로부터 데이터를 받는다.</small>

---

## 3.4. Lifecycle Callbacks

아래 라이프사이클 콜백을 사용해서 **TCP** 서버를 확장할 수도 있다:

- `doOnBind`: 서버 채널이 바운드되려고 할 때 호출한다.
- `doOnBound`: 서버 채널이 바운드될 때 호출한다.
- `doOnConnection`: 리모트 클라이언트가 연결될 때 호출한다.
- `doOnUnbound`: 서버 채널이 언바운드될 때 호출한다.

아래 예제는 `doOnConnection` 콜백을 사용한다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/tcp/server/lifecycle/Application.java**</small>

```java
import io.netty.handler.timeout.ReadTimeoutHandler;
import reactor.netty.DisposableServer;
import reactor.netty.tcp.TcpServer;
import java.util.concurrent.TimeUnit;

public class Application {

	public static void main(String[] args) {
		DisposableServer server =
				TcpServer.create()
				         .doOnConnection(conn ->
				             conn.addHandler(new ReadTimeoutHandler(10, TimeUnit.SECONDS))) // (1)
				         .bindNow();

		server.onDispose()
		      .block();
	}
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 리모트 클라이언트가 연결될 때 `ReadTimeoutHandler`로 **네티** 파이프라인을 확장한다.</small>

---

## 3.5. TCP-level Configurations

이번 섹션에선 TCP 레벨에서 사용할 수 있는 세 가지 설정에 대해 설명한다.

- [채널 옵션 설정하기](#351-setting-channel-options)
- [Wire 로거 사용하기](#352-using-a-wire-logger)
- [이벤트 루프 그룹 사용하기](#353-using-an-event-loop-group)

### 3.5.1. Setting Channel Options

**TCP** 서버는 디폴트로 다음과 같은 옵션으로 설정된다:

<small>**./../../reactor-netty-core/src/main/java/reactor/netty/tcp/TcpServerBind.java**</small>

```java
TcpServerBind() {
	Map<ChannelOption<?>, Boolean> childOptions = new HashMap<>(2);
	childOptions.put(ChannelOption.AUTO_READ, false);
	childOptions.put(ChannelOption.TCP_NODELAY, true);
	this.config = new TcpServerConfig(
			Collections.singletonMap(ChannelOption.SO_REUSEADDR, true),
			childOptions,
			() -> new InetSocketAddress(DEFAULT_PORT));
}
```

다른 옵션이 더 필요하거나 현재 옵션을 바꾸고 싶다면, 다음과 같이 설정할 수 있다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/tcp/server/channeloptions/Application.java**</small>

```java
import io.netty.channel.ChannelOption;
import reactor.netty.DisposableServer;
import reactor.netty.tcp.TcpServer;

public class Application {

	public static void main(String[] args) {
		DisposableServer server =
				TcpServer.create()
				         .option(ChannelOption.CONNECT_TIMEOUT_MILLIS, 10000)
				         .bindNow();

		server.onDispose()
		      .block();
	}
}
```

**네티** 채널 옵션에 대한 자세한 내용은 아래 링크를 참고하라:

- [`ChannelOption`](https://netty.io/4.1/api/io/netty/channel/ChannelOption.html)
- [소켓 옵션](https://docs.oracle.com/javase/8/docs/technotes/guides/net/socketOpt.html)

### 3.5.2. Using a Wire Logger

리액터 네티는 피어 간의 트래픽을 살펴보기 위한 wire 로깅을 제공한다. 기본적으로 wire 로깅은 비활성화돼 있다. 활성화하려면 로거의 `reactor.netty.tcp.TcpServer` 레벨을 `DEBUG`로 설정하고 아래 설정을 적용해야 한다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/tcp/server/wiretap/Application.java**</small>

```java
import reactor.netty.DisposableServer;
import reactor.netty.tcp.TcpServer;

public class Application {

	public static void main(String[] args) {
		DisposableServer server =
				TcpServer.create()
				         .wiretap(true) 
				         .bindNow();

		server.onDispose()
		      .block();
	}
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> wire 로깅을 활성화한다.
</small>

### 3.5.3. Using an Event Loop Group

기본적으로 **TCP** 서버는 "이벤트 루프 그룹"을 사용하며, 워커 스레드는 초기화 시점 런타임에 사용할 수 있는 프로세서 수로 세팅된다 (단, 최소값은 4). 다른 설정이 필요하다면 [LoopResource](https://projectreactor.io/docs/netty/release/api/reactor/netty/resources/LoopResources.html)`#create` 메소드 중 하나를 사용하면 된다.

**이벤트 루프 그룹**의 디폴트 설정은 다음과 같다:

<small>**./../../reactor-netty-core/src/main/java/reactor/netty/ReactorNetty.java**</small>

```java
/**
 * Default worker thread count, fallback to available processor
 * (but with a minimum value of 4)
 */
public static final String IO_WORKER_COUNT = "reactor.netty.ioWorkerCount";
/**
 * Default selector thread count, fallback to -1 (no selector thread)
 */
public static final String IO_SELECT_COUNT = "reactor.netty.ioSelectCount";
/**
 * Default worker thread count for UDP, fallback to available processor
 * (but with a minimum value of 4)
 */
public static final String UDP_IO_THREAD_COUNT = "reactor.netty.udp.ioThreadCount";
/**
 * Default quiet period that guarantees that the disposal of the underlying LoopResources
 * will not happen, fallback to 2 seconds.
 */
public static final String SHUTDOWN_QUIET_PERIOD = "reactor.netty.ioShutdownQuietPeriod";
/**
 * Default maximum amount of time to wait until the disposal of the underlying LoopResources
 * regardless if a task was submitted during the quiet period, fallback to 15 seconds.
 */
public static final String SHUTDOWN_TIMEOUT = "reactor.netty.ioShutdownTimeout";

/**
 * Default value whether the native transport (epoll, kqueue) will be preferred,
 * fallback it will be preferred when available
 */
```

이 설정을 바꾸려면 다음과 같이 설정해라:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/tcp/server/eventloop/Application.java**</small>

```java
import reactor.netty.DisposableServer;
import reactor.netty.resources.LoopResources;
import reactor.netty.tcp.TcpServer;

public class Application {

	public static void main(String[] args) {
		LoopResources loop = LoopResources.create("event-loop", 1, 4, true);

		DisposableServer server =
				TcpServer.create()
				         .runOn(loop)
				         .bindNow();

		server.onDispose()
		      .block();
	}
}
```

---

## 3.6. SSL and TLS

SSL나 TLS가 필요하다면 아래에 있는 설정을 사용하면 된다. 기본적으로 **OpenSSL**을 사용할 수 있다면, [`SslProvider.OPENSSL`](https://netty.io/4.1/api/io/netty/handler/ssl/SslProvider.html#OPENSSL)을 provider로 선택한다. 그렇지 않으면 [`SslProvider.JDK`](https://netty.io/4.1/api/io/netty/handler/ssl/SslProvider.html#JDK)를 사용한다. [`SslContextBuilder`](https://netty.io/4.1/api/io/netty/handler/ssl/SslContextBuilder.html#sslProvider-io.netty.handler.ssl.SslProvider-)를 사용하거나 `-Dio.netty.handler.ssl.noOpenSsl=true`를 설정하면 provider를 바꿀 수 있다.

다음 예제는 `SslContextBuilder`를 사용한다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/tcp/server/security/Application.java**</small>

```java
import io.netty.handler.ssl.SslContextBuilder;
import reactor.netty.DisposableServer;
import reactor.netty.tcp.TcpServer;
import java.io.File;

public class Application {

	public static void main(String[] args) {
		File cert = new File("certificate.crt");
		File key = new File("private.key");

		SslContextBuilder sslContextBuilder = SslContextBuilder.forServer(cert, key);

		DisposableServer server =
				TcpServer.create()
				         .secure(spec -> spec.sslContext(sslContextBuilder))
				         .bindNow();

		server.onDispose()
		      .block();
	}
}
```

### 3.6.1. Server Name Indication

**TCP** 서버는 특정 도메인에 매핑하는 식으로 `SslContext`를 여러 개 설정할 수 있다. `SNI` 매핑은 정확한 도메인명도, 와일드카드가 있는 도메인명도 가능하다.

아래 예제는 와일드카드가 있는 도메인명을 사용한다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/tcp/server/sni/Application.java**</small>

```java
import io.netty.handler.ssl.SslContext;
import io.netty.handler.ssl.SslContextBuilder;
import reactor.netty.DisposableServer;
import reactor.netty.tcp.TcpServer;

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
				TcpServer.create()
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

## 3.7. Metrics

TCP 서버는 [**Micrometer**](https://micrometer.io/) 통합 지원을 내장하고 있다. 프리픽스로 `reactor.netty.tcp.server`를 사용하는 모든 메트릭에 해당한다.

아래 테이블은 TCP 서버 메트릭에 대한 정보를 담고 있다:

| metric name                                 | type                | description                  |
| :------------------------------------------ | :------------------ | :--------------------------- |
| reactor.netty.tcp.server.data.received      | DistributionSummary | 데이터 수신량 (바이트 단위)  |
| reactor.netty.tcp.server.data.sent          | DistributionSummary | 데이터 전송량 (바이트 단위)  |
| reactor.netty.tcp.server.errors             | Counter             | 에러 발생 횟수               |
| reactor.netty.tcp.server.tls.handshake.time | Timer               | TLS 핸드셰이크에 소요된 시간 |

추가로 다음 메트릭도 사용할 수 있다:

`ByteBufAllocator` 메트릭

| metric name                                             | type  | description                                                |
| :------------------------------------------------------ | :---- | :--------------------------------------------------------- |
| reactor.netty.bytebuf.allocator.used.heap.memory        | Gauge | 힙 메모리의 바이트 수                                      |
| reactor.netty.bytebuf.allocator.used.direct.memory      | Gauge | 다이렉트 메모리의 바이트 수                                |
| reactor.netty.bytebuf.allocator.used.heap.arenas        | Gauge | 힙 arena 수 (`PooledByteBufAllocator`를 사용할 때)         |
| reactor.netty.bytebuf.allocator.used.direct.arenas      | Gauge | 다이렉트 arena 수 (`PooledByteBufAllocator`를 사용할 때)   |
| reactor.netty.bytebuf.allocator.used.threadlocal.caches | Gauge | 스레드 로컬 캐시 수(`PooledByteBufAllocator`를 사용할 때)  |
| reactor.netty.bytebuf.allocator.used.tiny.cache.size    | Gauge | tiny 캐시 사이즈 (`PooledByteBufAllocator`를 사용할 때)    |
| reactor.netty.bytebuf.allocator.used.small.cache.size   | Gauge | small 캐시 사이즈 (`PooledByteBufAllocator`를 사용할 때)   |
| reactor.netty.bytebuf.allocator.used.normal.cache.size  | Gauge | normal 캐시 사이즈 (`PooledByteBufAllocator`를 사용할 때)  |
| reactor.netty.bytebuf.allocator.used.chunk.size         | Gauge | arena의 청크 사이즈 (`PooledByteBufAllocator`를 사용할 때) |

다음은 메트릭 통합을 활성화하는 예시다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/tcp/server/metrics/Application.java**</small>

```java
import reactor.netty.DisposableServer;
import reactor.netty.tcp.TcpServer;

public class Application {

	public static void main(String[] args) {
		DisposableServer server =
				TcpServer.create()
				         .metrics(true) // (1)
				         .bindNow();

		server.onDispose()
		      .block();
	}
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 빌트인 Micrometer 인테그레이션을 활성화한다.
</small>

**Micrometer** 외에 다른 시스템과 통합해서 TCP 서버 메트릭을 보고 싶거나, 자체적으로 **Micrometer**를 통합하고 싶다면, 다음과 같이 자체 메트릭 레코더를 제공하면 된다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/tcp/server/metrics/custom/Application.java**</small>

```java
import reactor.netty.DisposableServer;
import reactor.netty.channel.ChannelMetricsRecorder;
import reactor.netty.tcp.TcpServer;

import java.net.SocketAddress;
import java.time.Duration;

public class Application {

	public static void main(String[] args) {
		DisposableServer server =
				TcpServer.create()
				         .metrics(true, CustomChannelMetricsRecorder::new) // (1)
				         .bindNow();

		server.onDispose()
		      .block();
	}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> TCP 서버 메트릭을 활성화하고 [`ChannelMetricsRecorder`](https://projectreactor.io/docs/netty/release/api/reactor/netty/channel/ChannelMetricsRecorder.html) 구현체를 제공한다.</small>

---

## 3.8. Unix Domain Sockets

native transport를 사용한다면, **TCP** 서버는 [유닉스 도메인 소켓(UDS)](https://en.wikipedia.org/wiki/Unix_domain_socket)을 지원한다.

다음은 UDS 지원을 사용하는 예제다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/tcp/server/uds/Application.java**</small>

```java
import io.netty.channel.unix.DomainSocketAddress;
import reactor.netty.DisposableServer;
import reactor.netty.tcp.TcpServer;

public class Application {

	public static void main(String[] args) {
		DisposableServer server =
				TcpServer.create()
				         .bindAddress(() -> new DomainSocketAddress("/tmp/test.sock")) // (1)
				         .bindNow();

		server.onDispose()
		      .block();
	}
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 사용할 `DomainSocketAddress`를 지정한다.</small>

"[TCP Server](https://projectreactor.io/docs/netty/1.0.1/reference/index.html#tcp-server)" [수정 제안하기](https://github.com/reactor/reactor-netty/edit/master/docs/asciidoc/tcp-server.adoc)