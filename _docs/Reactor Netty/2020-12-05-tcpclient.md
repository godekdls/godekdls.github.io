---
title: TCP Client
category: Reactor Netty
order: 5
permalink: /Reactor%20Netty/tcpclient/
description: 리액터 네티로 TCP 클라이언트 설정하기 한글 번역
image: ./../../images/reactornetty/logo.png
lastmod: 2020-12-05T12:00:00+09:00
comments: true
originalRefName: 프로젝트 리액터 네티
originalRefLink: https://projectreactor.io/docs/netty/1.0.1/reference/index.html#tcp-client
---

### 목차

- [4.1. Connect and Disconnect](#41-connect-and-disconnect)
  + [4.1.1. Host and Port](#411-host-and-port)
- [4.2. Writing Data](#42-writing-data)
- [4.3. Consuming Data](#43-consuming-data)
- [4.4. Lifecycle Callbacks](#44-lifecycle-callbacks)
- [4.5. TCP-level Configurations](#45-tcp-level-configurations)
  + [4.5.1. Channel Options](#451-channel-options)
  + [4.5.2. Wire Logger](#452-wire-logger)
  + [4.5.3. Event Loop Group](#453-event-loop-group)
- [4.6. Connection Pool](#46-connection-pool)
  + [4.6.1. Metrics](#461-metrics)
- [4.7. SSL and TLS](#47-ssl-and-tls)
  + [4.7.1. Server Name Indication](#471-server-name-indication)
- [4.8. Proxy Support](#48-proxy-support)
- [4.9. Metrics](#49-metrics)
- [4.10. Unix Domain Sockets](#410-unix-domain-sockets)

---

리액터 네티는 사용하기도 설정하기도 쉬운 [`TcpClient`](https://projectreactor.io/docs/netty/release/api/reactor/netty/tcp/TcpClient.html)를 제공한다. `TcpClient`는 **TCP** 클라이언트 생성에 필요한 네티 기능을 대부분 숨겨주고, 리액티브 스트림 backpressure를 추가해준다.

---

## 4.1. Connect and Disconnect

**TCP** 클라이언트를 주어진 엔드포인트로 연결하려면, 일단 [`TcpClient`](https://projectreactor.io/docs/netty/release/api/reactor/netty/tcp/TcpClient.html) 인스턴스를 만들어 설정해야 한다. 기본적으로 **호스트**는 `localhost`, **포트**는 `12012`로 설정된다. 다음은 `TcpClient` 인스턴스를 생성하는 예시다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/tcp/client/create/Application.java**</small>

```java
import reactor.netty.Connection;
import reactor.netty.tcp.TcpClient;

public class Application {

	public static void main(String[] args) {
		Connection connection =
				TcpClient.create()      // (1)
				         .connectNow(); // (2)

		connection.onDispose()
		          .block();
	}
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> [`TcpClient`](https://projectreactor.io/docs/netty/release/api/reactor/netty/tcp/TcpClient.html) 인스턴스를 생성한다. 이제 인스턴스를 설정할 준비가 되었다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 클라이언트를 블로킹 방식으로 연결하고 초기화를 마치길 기다린다.</small>

반환된 [`Connection`](https://projectreactor.io/docs/netty/release/api/reactor/netty/Connection.html)은 블로킹 방식으로 클라이언트를 셧다운 시켜주는 [`disposeNow()`](https://projectreactor.io/docs/netty/release/api/reactor/netty/DisposableChannel.html#disposeNow-java.time.Duration-)를 포함하는, 간단한 커넥션 API를 제공한다.

### 4.1.1. Host and Port

특정 **호스트**와 **포트**로 연결하고 싶다면, **TCP** 클라이언트를 다음과 같이 설정하면 된다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/tcp/client/address/Application.java**</small>

```java
import reactor.netty.Connection;
import reactor.netty.tcp.TcpClient;

public class Application {

	public static void main(String[] args) {
		Connection connection =
				TcpClient.create()
				         .host("example.com") // (1)
				         .port(80)            // (2)
				         .connectNow();

		connection.onDispose()
		          .block();
	}
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> **TCP** 호스트를 설정한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> **TCP** 포트를 설정한다.</small>

---

## 4.2. Writing Data

주어진 엔드포인트에 데이터를 전송하려면 I/O 핸들러를 연결해야 한다. I/O 핸들러는 [`NettyOutbound`](https://projectreactor.io/docs/netty/release/api/reactor/netty/NettyOutbound.html)에 접근할 수 있어 데이터를 write할 수 있다.

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/tcp/client/send/Application.java**</small>

```java
import reactor.core.publisher.Mono;
import reactor.netty.Connection;
import reactor.netty.tcp.TcpClient;

public class Application {

	public static void main(String[] args) {
		Connection connection =
				TcpClient.create()
				         .host("example.com")
				         .port(80)
				         .handle((inbound, outbound) -> outbound.sendString(Mono.just("hello"))) // (1)
				         .connectNow();

		connection.onDispose()
		          .block();
	}
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 엔드포인트에 `hello`라는 문자열을 전송한다.</small>

---

## 4.3. Consuming Data

주어진 엔드포인트로부터 데이터를 받으려면 I/O 핸들러를 연결해야 한다. I/O 핸들러는 [`NettyInbound`](https://projectreactor.io/docs/netty/release/api/reactor/netty/NettyInbound.html)에 접근할 수 있어 데이터를 읽을 수 있다. 다음은 그 방법을 보여준다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/tcp/client/read/Application.java**</small>

```java
import reactor.netty.Connection;
import reactor.netty.tcp.TcpClient;

public class Application {

	public static void main(String[] args) {
		Connection connection =
				TcpClient.create()
				         .host("example.com")
				         .port(80)
				         .handle((inbound, outbound) -> inbound.receive().then()) // (1)
				         .connectNow();

		connection.onDispose()
		          .block();
	}
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 엔드포인트로부터 데이터를 받는다.</small>

---

## 4.4. Lifecycle Callbacks

아래 라이프사이클 콜백을 사용해서 **TCP** 클라이언트를 확장할 수도 있다:

- `doOnConnect`: 채널이 연결되려고 할 때 호출한다.
- `doOnConnected`: 채널이 연결되고 나면 호출한다.
- `doOnDisconnected`: 채널 연결을 끊고 나면 호출한다.

아래 예제는 `doOnConnected` 콜백을 사용한다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/tcp/client/lifecycle/Application.java**</small>

```java
import io.netty.handler.timeout.ReadTimeoutHandler;
import reactor.netty.Connection;
import reactor.netty.tcp.TcpClient;
import java.util.concurrent.TimeUnit;

public class Application {

	public static void main(String[] args) {
		Connection connection =
				TcpClient.create()
				         .host("example.com")
				         .port(80)
				         .doOnConnected(conn ->
				             conn.addHandler(new ReadTimeoutHandler(10, TimeUnit.SECONDS))) // (1)
				         .connectNow();

		connection.onDispose()
		          .block();
	}
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 채널이 연결되면 `ReadTimeoutHandler`로 **네티** 파이프라인을 확장한다.</small>

---

## 4.5. TCP-level Configurations

이번 섹션에선 TCP 레벨에서 사용할 수 있는 세 가지 설정에 대해 설명한다.

- [채널 옵션](#451-channel-options)
- [Wire 로거](#452-wire-logger)
- [이벤트 루프 그룹](#453-event-loop-group)

### 4.5.1. Channel Options

**TCP** 클라이언트는 디폴트로 다음과 같은 옵션으로 설정된다:

<small>**./../../reactor-netty-core/src/main/java/reactor/netty/tcp/TcpClientConnect.java**</small>

```java
TcpClientConnect(ConnectionProvider provider) {
	this.config = new TcpClientConfig(
			provider,
			Collections.singletonMap(ChannelOption.AUTO_READ, false),
			() -> AddressUtils.createUnresolved(NetUtil.LOCALHOST.getHostAddress(), DEFAULT_PORT));
}
```

다른 옵션이 더 필요하거나 현재 옵션을 바꾸고 싶다면, 다음과 같이 설정할 수 있다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/tcp/client/channeloptions/Application.java**</small>

```java
import io.netty.channel.ChannelOption;
import reactor.netty.Connection;
import reactor.netty.tcp.TcpClient;

public class Application {

	public static void main(String[] args) {
		Connection connection =
				TcpClient.create()
				         .host("example.com")
				         .port(80)
				         .option(ChannelOption.CONNECT_TIMEOUT_MILLIS, 10000)
				         .connectNow();

		connection.onDispose()
		          .block();
	}
}
```

**네티** 채널 옵션에 대한 자세한 내용은 아래 링크를 참고하라:

- [`ChannelOption`](https://netty.io/4.1/api/io/netty/channel/ChannelOption.html)
- [소켓 옵션](https://docs.oracle.com/javase/8/docs/technotes/guides/net/socketOpt.html)

### 4.5.2. Wire Logger

리액터 네티는 피어 간의 트래픽을 살펴보기 위한 wire 로깅을 제공한다. 기본적으로 wire 로깅은 비활성화돼 있다. 활성화하려면 로거의 `reactor.netty.tcp.TcpClient` 레벨을 `DEBUG`로 설정하고 아래 설정을 적용해야 한다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/tcp/client/wiretap/Application.java**</small>

```java
import reactor.netty.Connection;
import reactor.netty.tcp.TcpClient;

public class Application {

	public static void main(String[] args) {
		Connection connection =
				TcpClient.create()
				         .wiretap(true) // (1)
				         .host("example.com")
				         .port(80)
				         .connectNow();

		connection.onDispose()
		          .block();
	}
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> wire 로깅을 활성화한다.</small>

### 4.5.3. Event Loop Group

기본적으로 **TCP** 클라이언트는 “이벤트 루프 그룹”을 사용하며, 워커 스레드는 초기화 시점 런타임에 사용할 수 있는 프로세서 수로 세팅된다 (단, 최소값은 4). 다른 설정이 필요하다면  [LoopResource](https://projectreactor.io/docs/netty/release/api/reactor/netty/resources/LoopResources.html)`#create` 메소드 중 하나를 사용하면 된다.

이벤트 루프 그룹의 디폴트 설정은 다음과 같다:

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

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/tcp/client/eventloop/Application.java**</small>

```java
import reactor.netty.Connection;
import reactor.netty.resources.LoopResources;
import reactor.netty.tcp.TcpClient;

public class Application {

	public static void main(String[] args) {
		LoopResources loop = LoopResources.create("event-loop", 1, 4, true);

		Connection connection =
				TcpClient.create()
				         .host("example.com")
				         .port(80)
				         .runOn(loop)
				         .connectNow();

		connection.onDispose()
		          .block();
	}
}
```

---

## 4.6. Connection Pool

기본적으로 **TCP** 클라이언트는 "고정" 커넥션 풀을 사용하며, 최대 채널 수는 500으로, 팬딩 중인 큐에 보관 등록할 수 있는 최대 요청 수는 1000으로 제한한다 (나머지 설정은 아래 시스템 프로퍼티에서 확인). 즉, 풀에 채널이 없을 때 누군가가 채널을 획득하려고 하면 새 채널을 생성한다. 풀의 최대 채널 수에 도달하면 채널을 다시 풀로 반환할 때까지는 채널 획득이 지연된다.

<small>**./../../reactor-netty-core/src/main/java/reactor/netty/ReactorNetty.java**</small>

```java
/**
 * Default max connections. Fallback to
 * available number of processors (but with a minimum value of 16)
 */
public static final String POOL_MAX_CONNECTIONS = "reactor.netty.pool.maxConnections";
/**
 * Default acquisition timeout (milliseconds) before error. If -1 will never wait to
 * acquire before opening a new
 * connection in an unbounded fashion. Fallback 45 seconds
 */
public static final String POOL_ACQUIRE_TIMEOUT = "reactor.netty.pool.acquireTimeout";
/**
 * Default max idle time, fallback - max idle time is not specified.
 */
public static final String POOL_MAX_IDLE_TIME = "reactor.netty.pool.maxIdleTime";
/**
 * Default max life time, fallback - max life time is not specified.
 */
public static final String POOL_MAX_LIFE_TIME = "reactor.netty.pool.maxLifeTime";
/**
 * Default leasing strategy (fifo, lifo), fallback to fifo.
 * <ul>
 *     <li>fifo - The connection selection is first in, first out</li>
 *     <li>lifo - The connection selection is last in, first out</li>
 * </ul>
 */
```

이 커넥션 풀을 비활성화하려면 다음 설정을 적용해라:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/tcp/client/pool/Application.java**</small>

```java
import reactor.netty.Connection;
import reactor.netty.tcp.TcpClient;

public class Application {

	public static void main(String[] args) {
		Connection connection =
				TcpClient.newConnection()
				         .host("example.com")
				         .port(80)
				         .connectNow();

		connection.onDispose()
		          .block();
	}
}
```

커넥션 풀의 채널에 유휴 시간을 지정해야 한다면 아래 설정을 적용하면 된다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/tcp/client/pool/config/Application.java**</small>

```java
import reactor.netty.Connection;
import reactor.netty.resources.ConnectionProvider;
import reactor.netty.tcp.TcpClient;
import java.time.Duration;

public class Application {

	public static void main(String[] args) {
		ConnectionProvider provider =
				ConnectionProvider.builder("fixed")
				                  .maxConnections(50)
				                  .pendingAcquireTimeout(Duration.ofMillis(30000))
				                  .maxIdleTime(Duration.ofMillis(60))
				                  .build();

		Connection connection =
				TcpClient.create(provider)
				         .host("example.com")
				         .port(80)
				         .connectNow();

		connection.onDispose()
		          .block();
	}
}
```
> 로드가 높을 것으로 예상될 땐, 커넥션 풀의 최대 커넥션 수가 너무 높지 않도록 주의해야 한다. 동시에 너무 많은 커넥션을 열거나/획득하면 근본 원인 "Connect 타임아웃"와 함께 `reactor.netty.http.client.PrematureCloseException` 예외가 발생할 수도 있다.

### 4.6.1. Metrics

pooled `ConnectionProvider`는 [**Micrometer**](https://micrometer.io/) 통합 지원을 내장하고 있다. 프리픽스로 `reactor.netty.connection.provider`를 사용하는 모든 메트릭에 해당한다.

Pooled `ConnectionProvider` 메트릭

| metric name                                           | type  | description                               |
| :---------------------------------------------------- | :---- | :---------------------------------------- |
| reactor.netty.connection.provider.total.connections   | Gauge | 활성 상태 또는 유휴 상태인 모든 커넥션 수 |
| reactor.netty.connection.provider.active.connections  | Gauge | 획득에 성공한 활성 상태 커넥션 수         |
| reactor.netty.connection.provider.idle.connections    | Gauge | 유휴 커넥션 수                            |
| reactor.netty.connection.provider.pending.connections | Gauge | 커넥션을 기다리고 있는 요청 수            |

다음은 메트릭 통합을 활성화하는 예시다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/tcp/client/pool/metrics/Application.java**</small>

```java
import reactor.netty.Connection;
import reactor.netty.resources.ConnectionProvider;
import reactor.netty.tcp.TcpClient;

public class Application {

	public static void main(String[] args) {
		ConnectionProvider provider =
				ConnectionProvider.builder("fixed")
				                  .maxConnections(50)
				                  .metrics(true) // (1)
				                  .build();

		Connection connection =
				TcpClient.create(provider)
				         .host("example.com")
				         .port(80)
				         .connectNow();

		connection.onDispose()
		          .block();
	}
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 빌트인 Micrometer 인테그레이션을 활성화한다.</small>

---

## 4.7. SSL and TLS

SSL나 TLS가 필요하다면 아래에 있는 설정을 사용하면 된다. 기본적으로 **OpenSSL**을 사용할 수 있다면, [`SslProvider.OPENSSL`](https://netty.io/4.1/api/io/netty/handler/ssl/SslProvider.html#OPENSSL)을 provider로 선택한다. 그렇지 않으면 [`SslProvider.JDK`](https://netty.io/4.1/api/io/netty/handler/ssl/SslProvider.html#JDK)를 사용한다.  [`SslContextBuilder`](https://netty.io/4.1/api/io/netty/handler/ssl/SslContextBuilder.html#sslProvider-io.netty.handler.ssl.SslProvider-)를 사용하거나 `-Dio.netty.handler.ssl.noOpenSsl=true`를 설정하면 provider를 바꿀 수 있다.

다음 예제는 `SslContextBuilder`를 사용한다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/tcp/client/security/Application.java**</small>

```java
import io.netty.handler.ssl.SslContextBuilder;
import reactor.netty.Connection;
import reactor.netty.tcp.TcpClient;

public class Application {

	public static void main(String[] args) {
		SslContextBuilder sslContextBuilder = SslContextBuilder.forClient();

		Connection connection =
				TcpClient.create()
				         .host("example.com")
				         .port(443)
				         .secure(spec -> spec.sslContext(sslContextBuilder))
				         .connectNow();

		connection.onDispose()
		          .block();
	}
}
```

### 4.7.1. Server Name Indication

**TCP** 클라이언트는 기본적으로 리모트 호스트명을 `SNI` 서버명으로 전송한다. 이 디폴트 설정을 바꾸려면 다음과 같이 **TCP** 클라이언트를 설정하면 된다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/tcp/client/sni/Application.java**</small>

```java
import io.netty.handler.ssl.SslContext;
import io.netty.handler.ssl.SslContextBuilder;
import reactor.netty.Connection;
import reactor.netty.tcp.TcpClient;

import javax.net.ssl.SNIHostName;

public class Application {

	public static void main(String[] args) throws Exception {
		SslContext sslContext = SslContextBuilder.forClient().build();

		Connection connection =
				TcpClient.create()
				         .host("127.0.0.1")
				         .port(8080)
				         .secure(spec -> spec.sslContext(sslContext)
				                             .serverNames(new SNIHostName("test.com")))
				         .connectNow();

		connection.onDispose()
		          .block();
	}
}
```

---

## 4.8. Proxy Support

네티에서 제공하는 프록시 기능을 TCP 클라이언트에선 [`ProxyProvider`](https://projectreactor.io/docs/netty/release/api/reactor/netty/tcp/ProxyProvider.html) 빌더로 지원하며, "비 프록시 호스트"를 지정하는 방법을 제공한다. 다음은 `ProxyProvider`를 사용하는 예시다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/tcp/client/proxy/Application.java**</small>

```java
import reactor.netty.Connection;
import reactor.netty.transport.ProxyProvider;
import reactor.netty.tcp.TcpClient;

public class Application {

	public static void main(String[] args) {
		Connection connection =
				TcpClient.create()
				         .host("example.com")
				         .port(80)
				         .proxy(spec -> spec.type(ProxyProvider.Proxy.SOCKS4)
				                            .host("proxy")
				                            .port(8080)
				                            .nonProxyHosts("localhost"))
				        .connectNow();

		connection.onDispose()
		          .block();
	}
}
```

---

## 4.9. Metrics

TCP 클라이언트는 [**Micrometer**](https://micrometer.io/) 통합 지원을 내장하고 있다. 프리픽스로 `reactor.netty.tcp.client`를 사용하는 모든 메트릭에 해당한다.

아래 테이블은 TCP 클라이언트 메트릭에 대한 정보를 담고 있다:

| metric name                                 | type                | description                                |
| :------------------------------------------ | :------------------ | :----------------------------------------- |
| reactor.netty.tcp.client.data.received      | DistributionSummary | 데이터 수신량 (바이트 단위)                |
| reactor.netty.tcp.client.data.sent          | DistributionSummary | 데이터 전송량 (바이트 단위)                |
| reactor.netty.tcp.client.errors             | Counter             | 에러 발생 횟수                             |
| reactor.netty.tcp.client.tls.handshake.time | Timer               | TLS 핸드셰이크에 소요된 시간               |
| reactor.netty.tcp.client.connect.time       | Timer               | 리모트 주소에 커넥션을 맺을 때 소요된 시간 |
| reactor.netty.tcp.client.address.resolver   | Timer               | 주소를 리졸브할 때 소요된 시간             |

추가로 다음 메트릭도 사용할 수 있다:

Pooled `ConnectionProvider` 메트릭

| metric name                                           | type  | description                               |
| :---------------------------------------------------- | :---- | :---------------------------------------- |
| reactor.netty.connection.provider.total.connections   | Gauge | 활성 상태 또는 유휴 상태인 모든 커넥션 수 |
| reactor.netty.connection.provider.active.connections  | Gauge | 획득에 성공한 활성 상태 커넥션 수         |
| reactor.netty.connection.provider.idle.connections    | Gauge | 유휴 커넥션 수                            |
| reactor.netty.connection.provider.pending.connections | Gauge | 커넥션을 기다리고 있는 요청 수            |

`ByteBufAllocator` 메트릭

| metric name                                             | type  | description                                                |
| :------------------------------------------------------ | :---- | :--------------------------------------------------------- |
| reactor.netty.bytebuf.allocator.used.heap.memory        | Gauge | 힙 메모리의 바이트 수                                      |
| reactor.netty.bytebuf.allocator.used.direct.memory      | Gauge | 다이렉트 메모리의 바이트 수                                |
| reactor.netty.bytebuf.allocator.used.heap.arenas        | Gauge | 힙 arena 수 (`PooledByteBufAllocator`를 사용할 때)         |
| reactor.netty.bytebuf.allocator.used.direct.arenas      | Gauge | 다이렉트 arena 수 (`PooledByteBufAllocator`를 사용할 때)   |
| reactor.netty.bytebuf.allocator.used.threadlocal.caches | Gauge | 스레드 로컬 캐시 수 (`PooledByteBufAllocator`를 사용할 때) |
| reactor.netty.bytebuf.allocator.used.tiny.cache.size    | Gauge | tiny 캐시 사이즈 (`PooledByteBufAllocator`를 사용할 때)    |
| reactor.netty.bytebuf.allocator.used.small.cache.size   | Gauge | small 캐시 사이즈 (`PooledByteBufAllocator`를 사용할 때)   |
| reactor.netty.bytebuf.allocator.used.normal.cache.size  | Gauge | normal 캐시 사이즈 (`PooledByteBufAllocator`를 사용할 때)  |
| reactor.netty.bytebuf.allocator.used.chunk.size         | Gauge | arena의 청크 사이즈 (`PooledByteBufAllocator`를 사용할 때) |

다음은 메트릭 통합을 활성화하는 예시다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/tcp/client/metrics/Application.java**</small>

```java
import reactor.netty.Connection;
import reactor.netty.tcp.TcpClient;

public class Application {

	public static void main(String[] args) {
		Connection connection =
				TcpClient.create()
				         .host("example.com")
				         .port(80)
				         .metrics(true) // (1)
				         .connectNow();

		connection.onDispose()
		          .block();
	}
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 빌트인 Micrometer 인테그레이션을 활성화한다.</small>

**Micrometer** 외에 다른 시스템과 통합해서 TCP 클라이언트 메트릭을 보고 싶거나, 자체적으로 **Micrometer**를 통합하고 싶다면, 다음과 같이 자체 메트릭 레코더를 제공하면 된다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/tcp/client/metrics/custom/Application.java**</small>

```java
import reactor.netty.Connection;
import reactor.netty.channel.ChannelMetricsRecorder;
import reactor.netty.tcp.TcpClient;

import java.net.SocketAddress;
import java.time.Duration;

public class Application {

	public static void main(String[] args) {
		Connection connection =
				TcpClient.create()
				         .host("example.com")
				         .port(80)
				         .metrics(true, CustomChannelMetricsRecorder::new) // (1)
				         .connectNow();

		connection.onDispose()
		          .block();
	}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> TCP 클라이언트 메트릭을 활성화하고 [`ChannelMetricsRecorder`](https://projectreactor.io/docs/netty/release/api/reactor/netty/channel/ChannelMetricsRecorder.html) 구현체를 제공한다.</small>

---

## 4.10. Unix Domain Sockets

native transport를 사용한다면, **TCP** 클라이언트는 [유닉스 도메인 소켓(UDS)](https://en.wikipedia.org/wiki/Unix_domain_socket)을 지원한다.

다음은 UDS 지원을 사용하는 예제다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/tcp/client/uds/Application.java**</small>

```java
import io.netty.channel.unix.DomainSocketAddress;
import reactor.netty.Connection;
import reactor.netty.tcp.TcpClient;

public class Application {

	public static void main(String[] args) {
		Connection connection =
				TcpClient.create()
				         .remoteAddress(() -> new DomainSocketAddress("/tmp/test.sock")) // (1)
				         .connectNow();

		connection.onDispose()
		          .block();
	}
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 사용할 `DomainSocketAddress`를 지정한다.</small>

"[TCP Client](https://projectreactor.io/docs/netty/1.0.1/reference/index.html#tcp-client)" [수정 제안하기](https://github.com/reactor/reactor-netty/edit/master/docs/asciidoc/tcp-client.adoc)