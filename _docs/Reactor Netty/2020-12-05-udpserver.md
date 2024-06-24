---
title: UDP Server
category: Reactor Netty
order: 8
permalink: /Reactor%20Netty/udpserver/
description: 리액터 네티로 UDP 서버 설정하기 한국어 번역
image: ./../../images/reactornetty/logo.png
lastmod: 2020-12-19T00:00:00+09:00
comments: true
originalRefName: 프로젝트 리액터 네티
originalRefLink: https://projectreactor.io/docs/netty/1.0.1/reference/index.html#udp-server
---

### 목차

- [7.1. Starting and Stopping](#71-starting-and-stopping)
  + [7.1.1. Host and Port](#711-host-and-port)
- [7.2. Writing Data](#72-writing-data)
- [7.3. Consuming Data](#73-consuming-data)
- [7.4. Lifecycle Callbacks](#74-lifecycle-callbacks)
- [7.5. Connection Configuration](#75-connection-configuration)
  + [7.5.1. Channel Options](#751-channel-options)
  + [7.5.2. Wire Logger](#752-wire-logger)
  + [7.5.3. Event Loop Group](#753-event-loop-group)
- [7.6. Metrics](#76-metrics)

---

리액터 네티를 사용하면 손쉽게 [`UdpServer`](https://projectreactor.io/docs/netty/release/api/reactor/netty/udp/UdpServer.html)를 설정할 수 있다. `UdpServer`는 **UDP** 서버 생성에 필요한 네티 기능을 대부분 숨겨주고, **리액티브 스트림** backpressure를 추가해준다.

---

## 7.1. Starting and Stopping

**UDP** 서버를 시작하려면 일단 [UdpServer](https://projectreactor.io/docs/netty/release/api/reactor/netty/udp/UdpServer.html) 인스턴스를 만들어 설정해야 한다. 기본적으로 호스트는 `localhost`, 포트는 `12012`로 설정된다. 다음은 UDP 서버를 생성하고 시작하는 예시다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/udp/server/create/Application.java**</small>

```java
import reactor.netty.Connection;
import reactor.netty.udp.UdpServer;
import java.time.Duration;

public class Application {

	public static void main(String[] args) {
		Connection server =
				UdpServer.create()                         // (1)
				         .bindNow(Duration.ofSeconds(30)); // (2)

		server.onDispose()
		      .block();
	}
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> [`UdpServer`](https://projectreactor.io/docs/netty/release/api/reactor/netty/udp/UdpServer.html) 인스턴스를 생성한다. 이제 인스턴스를 설정할 준비가 되었다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 서버를 블로킹 방식으로 시작하고 초기화를 마치길 기다린다.</small>

반환된 [`Connection`](https://projectreactor.io/docs/netty/release/api/reactor/netty/Connection.html)은 블로킹 방식으로 서버를 셧다운 시켜주는 [`disposeNow()`](https://projectreactor.io/docs/netty/release/api/reactor/netty/DisposableChannel.html#disposeNow-java.time.Duration-)를 포함하는, 간단한 서버 API를 제공한다.

### 7.1.1. Host and Port

특정 호스트와 포트로 서빙하고 싶다면, **UDP** 서버를 다음과 같이 설정하면 된다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/udp/server/address/Application.java**</small>

```java
import reactor.netty.Connection;
import reactor.netty.udp.UdpServer;
import java.time.Duration;

public class Application {

	public static void main(String[] args) {
		Connection server =
				UdpServer.create()
				         .host("localhost") // (1)
				         .port(8080)        // (2)
				         .bindNow(Duration.ofSeconds(30));

		server.onDispose()
		      .block();
	}
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> **UDP** 서버 호스트를 설정한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> **UDP** 서버 포트를 설정한다.</small>

---

## 7.2. Writing Data

리모트 피어에 데이터를 전송하려면 I/O 핸들러를 연결해야 한다. I/O 핸들러는 [`UdpOutbound`](https://projectreactor.io/docs/netty/release/api/reactor/netty/udp/UdpOutbound.html)에 접근할 수 있어 데이터를 write할 수 있다. 다음은 `hello`를 전송하는 예시다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/udp/server/send/Application.java**</small>

```java
import io.netty.buffer.ByteBuf;
import io.netty.buffer.Unpooled;
import io.netty.channel.socket.DatagramPacket;
import io.netty.util.CharsetUtil;
import reactor.core.publisher.Mono;
import reactor.netty.Connection;
import reactor.netty.udp.UdpServer;

import java.time.Duration;

public class Application {

	public static void main(String[] args) {
		Connection server =
				UdpServer.create()
				         .handle((in, out) ->
				             out.sendObject(
				                 in.receiveObject()
				                   .map(o -> {
				                       if (o instanceof DatagramPacket) {
				                           DatagramPacket p = (DatagramPacket) o;
				                           ByteBuf buf = Unpooled.copiedBuffer("hello", CharsetUtil.UTF_8);
				                           return new DatagramPacket(buf, p.sender()); // (1)
				                       }
				                       else {
				                           return Mono.error(new Exception("Unexpected type of the message: " + o));
				                       }
				                   })))
				         .bindNow(Duration.ofSeconds(30));

		server.onDispose()
		      .block();
	}
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 리모트 피어에 `hello`라는 문자열을 전송한다.</small>

---

## 7.3. Consuming Data

리모트 피어로부터 데이터를 받으려면 I/O 핸들러를 연결해야 한다. I/O 핸들러는 [`UdpInbound`](https://projectreactor.io/docs/netty/release/api/reactor/netty/udp/UdpInbound.html)에 접근할 수 있어 데이터를 읽을 수 있다. 다음은 데이터를 컨슈밍하는 예시다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/udp/server/read/Application.java**</small>

```java
import io.netty.channel.socket.DatagramPacket;
import reactor.core.publisher.Mono;
import reactor.netty.Connection;
import reactor.netty.udp.UdpServer;

import java.time.Duration;

public class Application {

	public static void main(String[] args) {
		Connection server =
				UdpServer.create()
				         .handle((in, out) ->
				             out.sendObject(
				                 in.receiveObject()
				                   .map(o -> {
				                       if (o instanceof DatagramPacket) {
				                           DatagramPacket p = (DatagramPacket) o;
				                           return new DatagramPacket(p.content().retain(), p.sender()); // (1)
				                       }
				                       else {
				                           return Mono.error(new Exception("Unexpected type of the message: " + o));
				                       }
				                   })))
				         .bindNow(Duration.ofSeconds(30));

		server.onDispose()
		      .block();
	}
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 리모트 피어로부터 데이터를 받는다.</small>

---

### 7.4. Lifecycle Callbacks

아래 라이프사이클 콜백을 사용해서 **UDP** 서버를 확장할 수도 있다:

- `doOnBind`: 서버 채널이 바운드되려고 할 때 호출한다.
- `doOnBound`: 서버 채널이 바운드될 때 호출한다.
- `doOnUnbound`: 서버 채널이 언바운드될 때 호출한다.

아래 예제는 `doOnBound` 메소드를 사용한다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/udp/server/lifecycle/Application.java**</small>

```java
import io.netty.handler.codec.LineBasedFrameDecoder;
import reactor.netty.Connection;
import reactor.netty.udp.UdpServer;
import java.time.Duration;

public class Application {

	public static void main(String[] args) {
		Connection server =
				UdpServer.create()
				         .doOnBound(conn -> conn.addHandler(new LineBasedFrameDecoder(8192))) // (1)
				         .bindNow(Duration.ofSeconds(30));

		server.onDispose()
		      .block();
	}
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 서버 채널이 바운드될 때 `LineBasedFrameDecoder`로 **네티** 파이프라인을 확장한다.</small>

---

## 7.5. Connection Configuration

이번 섹션에선 UDP 레벨에서 사용할 수 있는 세 가지 설정에 대해 설명한다.

- [채널 옵션](#751-channel-options)
- [Wire 로거](#752-wire-logger)
- [이벤트 루프 그룹](#753-event-loop-group)

### 7.5.1. Channel Options

**UDP** 서버는 디폴트로 다음과 같은 옵션으로 설정된다:

<small>**./../../reactor-netty-core/src/main/java/reactor/netty/udp/UdpServerBind.java**</small>

```java
UdpServerBind() {
	this.config = new UdpServerConfig(
			Collections.singletonMap(ChannelOption.AUTO_READ, false),
			() -> new InetSocketAddress(NetUtil.LOCALHOST, DEFAULT_PORT));
}
```

다른 옵션이 더 필요하거나 현재 옵션을 바꾸고 싶다면, 다음과 같이 설정할 수 있다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/udp/server/channeloptions/Application.java**</small>

```java
import io.netty.channel.ChannelOption;
import reactor.netty.Connection;
import reactor.netty.udp.UdpServer;
import java.time.Duration;

public class Application {

	public static void main(String[] args) {
		Connection server =
				UdpServer.create()
				         .option(ChannelOption.CONNECT_TIMEOUT_MILLIS, 10000)
				         .bindNow(Duration.ofSeconds(30));

		server.onDispose()
		      .block();
	}
}
```

네티 채널 옵션에 대한 자세한 내용은 아래 링크를 참고하라:

- [`ChannelOption`](https://netty.io/4.1/api/io/netty/channel/ChannelOption.html)
- [소켓 옵션](https://docs.oracle.com/javase/8/docs/technotes/guides/net/socketOpt.html)

### 7.5.2. Wire Logger

리액터 네티는 피어 간의 트래픽을 살펴보기 위한 wire 로깅을 제공한다. 기본적으로 wire 로깅은 비활성화돼 있다. 활성화하려면 로거의 `reactor.netty.udp.UdpServer` 레벨을 `DEBUG`로 설정하고 아래 설정을 적용해야 한다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/udp/server/wiretap/Application.java**</small>

```java
import reactor.netty.Connection;
import reactor.netty.udp.UdpServer;
import java.time.Duration;

public class Application {

	public static void main(String[] args) {
		Connection server =
				UdpServer.create()
				         .wiretap(true) // (1)
				         .bindNow(Duration.ofSeconds(30));

		server.onDispose()
		      .block();
	}
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> wire 로깅을 활성화한다.</small>

### 7.5.3. Event Loop Group

기본적으로 UDP 서버는 “이벤트 루프 그룹”을 사용하며, 워커 스레드는 초기화 시점 런타임에 사용할 수 있는 프로세서 수로 세팅된다 (단, 최소값은 4). 다른 설정이 필요하다면 [LoopResource](https://projectreactor.io/docs/netty/release/api/reactor/netty/resources/LoopResources.html)`#create` 메소드 중 하나를 사용하면 된다.

"이벤트 루프 그룹"의 디폴트 설정은 다음과 같다:

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

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/udp/server/eventloop/Application.java**</small>

```java
import reactor.netty.Connection;
import reactor.netty.resources.LoopResources;
import reactor.netty.udp.UdpServer;
import java.time.Duration;

public class Application {

	public static void main(String[] args) {
		LoopResources loop = LoopResources.create("event-loop", 1, 4, true);

		Connection server =
				UdpServer.create()
				         .runOn(loop)
				         .bindNow(Duration.ofSeconds(30));

		server.onDispose()
		      .block();
	}
}
```

---

## 7.6. Metrics

UDP 서버는 [**Micrometer**](https://micrometer.io/) 통합 지원을 내장하고 있다. 프리픽스로 `reactor.netty.udp.server`를 사용하는 모든 메트릭에 해당한다.

아래 테이블은 UDP 서버 메트릭에 대한 정보를 담고 있다:

| metric name                            | type                | description                 |
| :------------------------------------- | :------------------ | :-------------------------- |
| reactor.netty.udp.server.data.received | DistributionSummary | 데이터 수신량 (바이트 단위) |
| reactor.netty.udp.server.data.sent     | DistributionSummary | 데이터 전송량 (바이트 단위) |
| reactor.netty.udp.server.errors        | Counter             | 에러 발생 횟수              |

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

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/udp/server/metrics/Application.java**</small>

```java
import reactor.netty.Connection;
import reactor.netty.udp.UdpServer;

import java.time.Duration;

public class Application {

	public static void main(String[] args) {
		Connection server =
				UdpServer.create()
				         .metrics(true) // (1)
				         .bindNow(Duration.ofSeconds(30));

		server.onDispose()
		      .block();
	}
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 빌트인 Micrometer 인테그레이션을 활성화한다.</small>

**Micrometer** 외에 다른 시스템과 통합해서 UDP 서버 메트릭을 보고 싶거나, 자체적으로 **Micrometer**를 통합하고 싶다면, 다음과 같이 자체 메트릭 레코더를 제공하면 된다:

<small>**./../../reactor-netty-examples/src/main/java/reactor/netty/examples/documentation/udp/server/metrics/custom/Application.java**</small>

```java
import reactor.netty.Connection;
import reactor.netty.channel.ChannelMetricsRecorder;
import reactor.netty.udp.UdpServer;

import java.net.SocketAddress;
import java.time.Duration;

public class Application {

	public static void main(String[] args) {
		Connection server =
				UdpServer.create()
				         .metrics(true, CustomChannelMetricsRecorder::new) // (1)
				         .bindNow(Duration.ofSeconds(30));

		server.onDispose()
		      .block();
	}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> UDP 서버 메트릭을 활성화하고 [`ChannelMetricsRecorder`](https://projectreactor.io/docs/netty/release/api/reactor/netty/channel/ChannelMetricsRecorder.html) 구현체를 제공한다.</small>

"[UDP Server](https://projectreactor.io/docs/netty/1.0.1/reference/index.html#udp-server)" [수정 제안하기](https://github.com/reactor/reactor-netty/edit/master/docs/asciidoc/udp-server.adoc)