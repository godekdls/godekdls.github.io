---
title: System Management
category: Spring Integration
order: 18
permalink: /Spring%20Integration/system-management/
description: 메트릭 수집, 히스토리 기록, 메타데이터 보관, 컨트롤 버스 등 통합 애플리케이션의 운영과 관리에 필요한 기능들
image: ./../../images/springintegration/logo.png
lastmod: 2022-10-21T13:30:00+09:00
comments: true
originalRefName: 스프링 인티그레이션
parent: Core Messaging
originalRefLink: https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/index-single.html#system-management-chapter
parentUrl: /Spring%20Integration/core-messaging/
---
<script>defaultLanguages = ['java']</script>

---

## 목차

- [13.1. Metrics and Management](#131-metrics-and-management)
  + [13.1.1. Legacy Metrics](#1311-legacy-metrics)
  + [13.1.2. Disabling Logging in High Volume Environments](#1312-disabling-logging-in-high-volume-environments)
  + [13.1.3. Micrometer Integration](#1313-micrometer-integration)
    * [Overview](#overview)
    * [Disabling Meters](#disabling-meters)
  + [13.1.4. Spring Integration JMX Support](#1314-spring-integration-jmx-support)
- [13.2. Message History](#132-message-history)
  + [13.2.1. Message History Configuration](#1321-message-history-configuration)
- [13.3. Message Store](#133-message-store)
  + [13.3.1. Using MessageGroupFactory](#1331-using-messagegroupfactory)
  + [13.3.2. Persistent MessageGroupStore and Lazy-load](#1332-persistent-messagegroupstore-and-lazy-load)
  + [13.3.3. Message Group Condition](#1333-message-group-condition)
- [13.4. Metadata Store](#134-metadata-store)
  + [13.4.1. Idempotent Receiver and Metadata Store](#1341-idempotent-receiver-and-metadata-store)
  + [13.4.2. MetadataStoreListener](#1342-metadatastorelistener)
- [13.5. Control Bus](#135-control-bus)
- [13.6. Orderly Shutdown](#136-orderly-shutdown)
- [13.7. Integration Graph](#137-integration-graph)
  + [13.7.1. Graph Runtime Model](#1371-graph-runtime-model)
- [13.8. Integration Graph Controller](#138-integration-graph-controller)

---

## 13.1. Metrics and Management

이번 섹션에선 Spring Integration과 관련된 메트릭을 수집하는 방법을 설명한다. 최신 버전에선 이전 대비 Micrometer에 좀 더 의존하고 있으며 ([micrometer.io](https://micrometer.io/) 참고), 향후 릴리즈에선 지금보다도 Micrometer를 더 많이 사용할 계획이다.

### 13.1.1. Legacy Metrics

레거시 메트릭들은 5.4 버전에서 제거했다. 아래 [마이크로미터 통합](#1313-micrometer-integration)을 참고해라.

### 13.1.2. Disabling Logging in High Volume Environments

메인 메시지 플로우에서 남기는 디버그 로그는 설정으로 제어할 수 있다. 대용량 애플리케이션에서 `isDebugEnabled()`를 호출하면 사용하는 로그 시스템에 따라 비용이 상당히 커질 수 있다. 모든 로그를 비활성화하면 이런 오버헤드를 피할 수 있다. 예외 로깅(디버그 레벨이나 다른 레벨 모두)은 이 설정에 영향 받지 않는다.

다음은 로그를 제어할 때 사용할 수 있는 옵션을 보여주는 코드다:

<div class="switch-language-wrapper java xml">
<span class="switch-language java">Java</span>
<span class="switch-language xml">XML</span>
</div>
<div class="language-only-for-java java xml"></div>
```java
@Configuration
@EnableIntegration
@EnableIntegrationManagement(
    defaultLoggingEnabled = "true") // (1)

public static class ContextConfiguration {
...
}
```
<div class="language-only-for-xml java xml"></div>
```xml
<int:management default-logging-enabled="true"/> <!-- (1) -->
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 로그 시스템의 카테고리 설정에 상관 없이, 메인 메시지 플로우의 모든 로그를 비활성화하려면 `false`로 설정해라. 디버그 로그를 활성화하려면 'true'로 설정해라 (하위 로그 시스템에서도 활성화했다면). 빈 정의에 따로 명시하지 않았을 때에만 적용된다. 디폴트는 `true`다.</small>

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p><code class="highlighter-rouge">defaultLoggingEnabled</code>는 빈을 정의할 때 이 설정을 명시하지 않았을 때에만 적용된다.</p>
</blockquote>

### 13.1.3. Micrometer Integration

#### Overview

5.0.3 버전부터 애플리케이션 컨텍스트에 [마이크로미터](https://micrometer.io/) `MeterRegistry`가 있으면 마이크로미터 메트릭과 관련된 기능들이 활성화된다.

마이크로미터를 사용하려면 애플리케이션 컨텍스트에 `MeterRegistry` 빈 중 하나를 추가해라.

`MessageHandler`와 `MessageChannel`에는 각각 타이머가, 각 `MessageSource`에는 카운터가 등록된다.

단, `AbstractMessageHandler`, `AbstractMessageChannel`, `AbstractMessageSource`를 상속한 객체에만 해당하는 사실이다 (프레임워크 구성 요소는 대부분 이 객체들을 상속하고 있긴 하다).

메시지 채널에 메시지를 전송할 때 사용하는 `Timer` Meter는 다음과 같은 이름과 태그를 가지고 있다:

- `name`: `spring.integration.send`
- `tag`: `type:channel`
- `tag`: `name:<componentName>`
- `tag`: `result:(success|failure)`
- `tag`: `exception:(none|exception simple class name)`
- `description`: `Send processing time`

(result는 `failure`, exception은 `none`이라면, 해당 채널의 `send()` 작업이 `false`를 반환했다는 뜻이다.)

pollable 메시지 채널에서 메시지를 수신할 때 사용하는 `Counter` Meter는 다음과 같은 이름과 태그를 가지고 있다:

- `name`: `spring.integration.receive`
- `tag`: `type:channel`
- `tag`: `name:<componentName>`
- `tag`: `result:(success|failure)`
- `tag`: `exception:(none|exception simple class name)`
- `description`: `Messages received`

메시지 핸들러 작업을 위한 `Timer` Meter는 다음과 같은 이름과 태그를 가지고 있다:

- `name`: `spring.integration.send`
- `tag`: `type:handler`
- `tag`: `name:<componentName>`
- `tag`: `result:(success|failure)`
- `tag`: `exception:(none|exception simple class name)`
- `description`: `Send processing time`

메시지 소스의 `Counter` Meter는 다음과 같은 이름과 태그를 가지고 있다:

- `name`: `spring.integration.receive`
- `tag`: `type:source`
- `tag`: `name:<componentName>`
- `tag`: `result:success`
- `tag`: `exception:none`
- `description`: `Messages received`

그 외에도 세 가지 `Gauge` Meter가 존재한다:

- `spring.integration.channels`: 애플리케이션에 있는 `MessageChannel` 갯수.
- `spring.integration.handlers`: 애플리케이션에 있는 `MessageHandler` 갯수.
- `spring.integration.sources`: 애플리케이션에 있는 `MessageSource` 갯수.

`MicrometerMetricsCaptor`를 상속하면 통합 구성 요소로 생성된 `Meter`의 이름과 태그를 커스텀할 수 있다. 커스텀하는 방법은 [MicrometerCustomMetricsTests](https://github.com/spring-projects/spring-integration/blob/main/spring-integration-core/src/test/java/org/springframework/integration/support/management/micrometer/MicrometerCustomMetricsTests.java)에 있는 간단한 테스트 케이스를 참고하면 된다. Meter를 조금 더 커스텀하고 싶다면 서브클래스 빌더의 `build()` 메소드를 오버로드하면 된다.

5.1.13 버전부터 `QueueChannel`은 큐 사이즈와 남은 용량을 보여주는 마이크로미터 게이지<sup>gauge</sup>를 노출한다:

- `name`: `spring.integration.channel.queue.size`
- `tag`: `type:channel`
- `tag`: `name:<componentName>`
- `description`: `The size of the queue channel`

and

- `name`: `spring.integration.channel.queue.remaining.capacity`
- `tag`: `type:channel`
- `tag`: `name:<componentName>`
- `description`: `The remaining capacity of the queue channel`

#### Disabling Meters

[레거시 메트릭](#1311-legacy-metrics)(현재는 제거됐다)을 사용하면 메트릭을 수집할 통합 구성 요소를 직접 지정할 수 있었다. 기본적으로 모든 meter는 처음 사용할 때 등록되는데, 이제는 Micrometer를 활용해서 `MeterRegistry`에 `MeterFilter`를 추가하면 일부나 전체를 등록하지 않을 수 있다. 즉, 원하는 프로퍼티를 설정해서 (`name`, `tag`) meter를 필터링해버릴 수 있다 (deny). 자세한 내용은 Micrometer 문서에 있는 [Meter 필터](https://micrometer.io/docs/concepts#_meter_filters)를 참고해라.

예를 들어 아래와 같은 채널이 있을 땐:

```java
@Bean
public QueueChannel noMeters() {
    return new QueueChannel(10);
}
```

이 채널과 관련된 meter는 다음 코드로 억제할 수 있다:

```java
registry.config().meterFilter(MeterFilter.deny(id ->
        "channel".equals(id.getTag("type")) &&
        "noMeters".equals(id.getTag("name"))));
```

### 13.1.4. Spring Integration JMX Support

[JMX 지원](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/jmx.html#jmx)을 함께 읽어봐라.

---

## 13.2. Message History

메시징 아키텍처의 핵심 포인트는 느슨한 결합<sup>loose coupling</sup>으로, 메시지 처리에 참여하는 구성 요소들이 계속해서 서로를 인식하지 않아도 되게끔 만들어준다. 이 사실 하나만으로도 애플리케이션은 매우 유연해질 수 있으며, 나머지 플로우에 영향을 주지 않으면서 구성 요소를 변경하거나, 메시지 처리 경로를 바꾸고, 메시지 컨슈밍 스타일을 변경할 수 있다 (폴링 vs 이벤트 기반). 하지만 이런 소박한 스타일의 아키텍처에선, 문제가 생기고 나서야 놓치고 있던 것을 발견하곤 한다. 예를 들어 코드를 디버깅할 때를 생각해보면, 메시지에 관한 정보가 최대한 많이 남아있길 바랄 거다 (어디서 온 메시지인지, 어떤 채널들을 통해 도착했는지 등).

메시지 히스토리는 개발을 도와주는 패턴 중 하나로, 메시지 경로에 대한 정보를 일정 수준 유지할 수 있는 방법을 제공한다. 디버깅에 활용하거나 감사<sup>audit</sup> 기록을 유지하는 용도로 활용할 수 있다. Spring integration의 메시지 플로우에선 생각보다 쉽게 메시지 히스토리를 유지하도록 만들어줄 수 있다. Spring integration은 메시지에 헤더를 추가해서, 메시지가 추적 중인 구성 요소를 통과할 때마다 이 헤더를 업데이트한다.

### 13.2.1. Message History Configuration

메시지 히스토리를 활성화할 땐, 다음과 같이 설정 안에 `message-history` 요소(또는 `@EnableMessageHistory`)를 정의해주기만 하면 된다:

<div class="switch-language-wrapper java xml">
<span class="switch-language java">Java</span>
<span class="switch-language xml">XML</span>
</div>
<div class="language-only-for-java java xml"></div>
```java
@Configuration
@EnableIntegration
@EnableMessageHistory
```
<div class="language-only-for-xml java xml"></div>
```xml
<int:message-history/>
```

이제 이름을 가지고 있는 모든 컴포넌트(`id`를 정의한 컴포넌트)들을 추적한다. 프레임워크는 메시지 안에 'history' 헤더를 세팅한다. 헤더의 값은 `List<Properties>`다.

아래 샘플 설정을 살펴보자:

<div class="switch-language-wrapper java xml">
<span class="switch-language java">Java</span>
<span class="switch-language xml">XML</span>
</div>
<div class="language-only-for-java java xml"></div>
```java
@MessagingGateway(defaultRequestChannel = "bridgeInChannel")
public interface SampleGateway {
   ...
}

@Bean
@Transformer(inputChannel = "enricherChannel", outputChannel="filterChannel")
HeaderEnricher sampleEnricher() {
   HeaderEnricher enricher =
      new HeaderEnricher(Collections.singletonMap("baz", new StaticHeaderValueMessageProcessor("baz")));
   return enricher;
}
```
<div class="language-only-for-xml java xml"></div>
```xml
<int:gateway id="sampleGateway"
    service-interface="org.springframework.integration.history.sample.SampleGateway"
    default-request-channel="bridgeInChannel"/>

<int:header-enricher id="sampleEnricher" input-channel="enricherChannel" output-channel="filterChannel">
    <int:header name="baz" value="baz"/>
</int:header-enricher>
```

위 설정에서 만들어지는 메시지 히스토리의 구조는 매우 단순하며, 다음과 유사하다:

```json
[{name=sampleGateway, type=gateway, timestamp=1283281668091},
 {name=sampleEnricher, type=header-enricher, timestamp=1283281668094}]
```

메시지 히스토리에 접근하는 방법은 단순히 `MessageHistory` 헤더에 접근하는 게 전부다. 아래 예제를 참고해라:

```java
Iterator<Properties> historyIterator =
    message.getHeaders().get(MessageHistory.HEADER_NAME, MessageHistory.class).iterator();
assertTrue(historyIterator.hasNext());
Properties gatewayHistory = historyIterator.next();
assertEquals("sampleGateway", gatewayHistory.get("name"));
assertTrue(historyIterator.hasNext());
Properties chainHistory = historyIterator.next();
assertEquals("sampleChain", chainHistory.get("name"));
```

모든 컴포넌트를 추적하고 싶은 건 아닐 수도 있다. 히스토리를 남길 컴포넌트들만 따로 지정하고싶다면, `tracked-components` 속성에 추적하고 싶은 컴포넌트의 이름이나, 매칭할 수 있는 패턴 목록을 지정해라. 각각은 콤마로 구분한다. 다음 예제를 참고해라:

<div class="switch-language-wrapper java xml">
<span class="switch-language java">Java</span>
<span class="switch-language xml">XML</span>
</div>
<div class="language-only-for-java java xml"></div>
```java
@Configuration
@EnableIntegration
@EnableMessageHistory("*Gateway", "sample*", "aName")
```
<div class="language-only-for-xml java xml"></div>
```xml
<int:message-history tracked-components="*Gateway, sample*, aName"/>
```

위 설정에선 'Gateway'로 끝나거나, 'sample'로 시작하거나, 이름이 정확하게 'aName'인 구성 요소에 대해서만 메시지 히스토리를 관리한다.

추가로, 이제 `IntegrationMBeanExporter`가 `MessageHistoryConfigurer` 빈을 JMX MBean으로 노출해주기 때문에 ([MBean 익스포터](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/jmx.html#jmx-mbean-exporter) 참고), 런타임에 이 패턴을 변경할 수 있다. 하지만 패턴을 변경하려면 해당 빈을 반드시 중단해야 한다 (메시지 히스토리 기능 비활성화). 이 기능을 활용하면 시스템 분석이 필요할 때 잠시 동안만 히스토리를 남길 수 있다. 이 MBean의 객체 이름은 `<domain>:name=messageHistoryConfigurer,type=MessageHistoryConfigurer`다.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>컴포넌트를 추적하도록 설정할 땐, <code class="highlighter-rouge">@EnableMessageHistory</code>(혹은 <code class="highlighter-rouge">&lt;message-history/&gt;</code>)는 애플리케이션 컨텍스트 내 단일 소스로 딱 한 번만 선언해야 한다. <code class="highlighter-rouge">MessageHistoryConfigurer</code>를 일반적인 빈처럼 정의하면 안 된다.</p>
</blockquote>


> 정의에 따르면, 메시지 히스토리 헤더는 변경할 수 없는 값이다<sup>immutable</sup> (히스토리를 다시 쓸 수 없다). 따라서 메시지 히스토리 값을 작성할 땐, 컴포넌트에서 메시지를 새로 생성하거나 (이 컴포넌트에서 메시지를 시작하는 경우), 요청 메시지로부터 히스토리를 복사해 값을 수정하고 응답 메시지에 새 리스트를 세팅한다. 두 경우 모두, 메시지가 다른 스레드에서 출발했더라도 상관 없이 값을 추가할 수 있다. 이는 비동기 메시지 플로우에서 히스토리를 잘 활용하면 디버깅이 매우 쉬워질 수 있음을 의미한다.

---

## 13.3. Message Store

[*Enterprise Integration Patterns*](https://www.enterpriseintegrationpatterns.com/)(EIP)라는 책에선 메시지를 버퍼링하는 기능을 갖춘 여러 가지 패턴들을 정의한다. 예를 들어, aggregator는 메시지를 놓아주기<sup>release</sup> 전까지 메시지를 버퍼링하고, `QueueChannel`은 컨슈머가 이 채널에서 메시지를 직접 받아갈 때까지 메시지를 버퍼링한다. 하지만 에러는 메시지 플로우 내 어느 지점에서나 발생할 수 있기 때문에, 메시지를 버퍼링하는 EIP 구성 요소들은 메시지를 잃어버릴 가능성도 존재한다.

메시지의 손실 가능성을 줄이기 위해 EIP는, EIP 구성 요소들이 메시지를 저장할 수 있게 만들어주는 (보통 RDBMS같은 영구<sup>persistenet</sup> 스토어에) [메시지 스토어](https://www.enterpriseintegrationpatterns.com/MessageStore.html) 패턴을 정의한다.

Spring Integration은 다음과 같이 메시지 스토어 패턴을 지원하고 있다:

- 전략 인터페이스 `org.springframework.integration.store.MessageStore`를 정의
- 이 인터페이스의 여러 가지 구현체를 제공
- 메시지 버퍼링 기능을 가진 모든 구성 요소에, `MessageStore` 인터페이스를 구현한 인스턴스를 주입할 수 있는 `message-store` 속성을 정의.

특정 메시지 스토어 구현체를 설정하는 방법이나, `MessageStore` 구현체를 특정 버퍼링 구성 요소에 주입하는 자세한 방법은 이 매뉴얼 곳곳에서 설명하고 있다 ([QueueChannel](../messaging-channels/#queuechannel-configuration), [Aggregator](../messaging-routing/#84-aggregator), [Delayer](../messaging-endpoints/#106-delayer)같은 실제 구성 요소들을 확인해봐라). 아래 있는 두 예제에선 `QueueChannel`과 aggregator에 메시지 스토어 참조를 추가한다:

**Example 3. QueueChannel**

```xml
<int:channel id="myQueueChannel">
    <int:queue message-store="refToMessageStore"/>
<int:channel>
```

**Example 4. Aggregator**

```xml
<int:aggregator … message-store="refToMessageStore"/>
```

메시지들은 기본적으로 `MessageStore`의 인 메모리 구현체인 `o.s.i.store.SimpleMessageStore`를 사용해서 저장한다. 이 구현체는 영구 저장할 필요가 없는<sup>non-persistent</sup> 메시지들이라, 잃어버려도 딱히 문제될 게 없는 개발 환경이나 소규모 환경에 적합하다. 하지만 일반적인 프로덕션 애플리케이션은 메시지 손실 위험도 줄이고, 메모리 고갈 상태도 미연에 방지하려면 다른 방법이 필요하다. 그렇기 때문에 spring integration에선 다양한 데이터 저장소를 위한 `MessageStore` 구현체들을 함께 제공하고 있다. 지원하는 구현체는 다음과 같다:

- [JDBC 메시지 스토어](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/jdbc.html#jdbc-message-store): RDBMS를 사용해 메시지를 저장한다
- [Redis 메시지 스토어](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/redis.html#redis-message-store): key/value 데이터스토어 Redis를 사용해 메시지를 저장한다
- [MongoDB 메시지 스토어](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/mongodb.html#mongodb-message-store): 도큐먼트 기반 저장소 MongoDB를 사용해 메시지를 저장한다
- [Gemfire 메시지 스토어](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/gemfire.html#gemfire-message-store): 분산 캐시 Gemfire를 사용해 메시지를 저장한다

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>하지만 <code class="highlighter-rouge">MessageStore</code>의 persistent 구현체를 사용하려면 몇 가지 제약을 숙지해둬야 한다.</p>
  <p>메시지 데이터(페이로드와 헤더)는 <code class="highlighter-rouge">MessageStore</code> 구현체에 따라 다양한 직렬화 전략을 통해 직렬화/역직렬화된다. 예를 들어 <code class="highlighter-rouge">JdbcMessageStore</code>를 사용할 땐 기본적으로 <code class="highlighter-rouge">Serializable</code> 데이터만 저장하게 된다. 이 경우 데이터를 직렬화하기 전에 Serializable이 아닌 헤더들을 제거한다. 또한 전송 어댑터(ex. FTP, HTTP, JMS 등)에서 추가하는 프로토콜별 헤더도 알아둘 필요가 있다. 예를 들어 <code class="highlighter-rouge">&lt;http:inbound-channel-adapter/&gt;</code>는 HTTP 헤더를 메시지 헤더에 매핑하는데, 그 중에는 serializable이 아닌 <code class="highlighter-rouge">org.springframework.http.MediaType</code> 인스턴스의 <code class="highlighter-rouge">ArrayList</code>가 있다. 하지만 일부 <code class="highlighter-rouge">MessageStore</code> 구현체들은 (ex. <code class="highlighter-rouge">JdbcMessageStore</code>) <code class="highlighter-rouge">Serializer</code>와 <code class="highlighter-rouge">Deserializer</code> 전략 인터페이스의 구현체를 주입해주면 직렬화/역직렬화 동작을 변경할 수 있다.</p>
  <p>헤더가 특정 유형의 데이터를 나타낼 때는 특히 더 주의해야 한다. 예를 들어 헤더에 어떤 스프링 빈의 인스턴스가 담겨 있다면, 역직렬화하고 나면 같은 빈의 다른 인스턴스가 얻어질 수 있는데, 이렇게 되면 프레임워크 내부에서 생성하는 일부 헤더에 직접적인 영향을 미친다 (<code class="highlighter-rouge">REPLY_CHANNEL</code>이나 <code class="highlighter-rouge">ERROR_CHANNEL</code>같은 헤더). 현재로썬 이런 헤더들은 직렬화할 수 없으며, 가능하다고 해도 역직렬화한 채널은 원하는 인스턴스가 아닐 거다.</p>
  <p>Spring Integration 3.0부터 이 문제는 <code class="highlighter-rouge">HeaderChannelRegistry</code>에 채널을 등록한 후 헤더 enricher로 관련 헤더를 이름을 나타내는 문자열로 교체해주면 해결할 수 있다.</p>
  <p>이번에는 [게이트웨이 → 큐 채널(영구<sup>persistent</sup> 메시지 스토어 사용) → 서비스 activator]와 같이 메시지 플로우를 구성하면 어떤 일이 벌어질지 생각해보자. 이 게이트웨이는 임시 응답 채널을 생성하는데, 이 채널은 서비스 activator의 폴러가 큐에서 메시지를 읽어가는 시점에는 남아있지 않다. 다시 한 번 더 설명하자면, 헤더 enricher를 사용하면 이 헤더를 <code class="highlighter-rouge">String</code>으로 교체할 수 있다.</p>
  <p>자세한 내용은 <a href="../messaging-transformation/#921-header-enricher">Header Enricher</a>를 참고해라.</p>
</blockquote>

Spring Integration 4.0에선 두 가지 인터페이스가 새로 추가됐다:

- `ChannelMessageStore`: `QueueChannel` 인스턴스에 특화된 작업들을 구현하는 용도
- `PriorityCapableChannelMessageStore`: `MessageStore` 구현체를 `PriorityChannel` 인스턴스에서 사용하는 용도로 마킹하고, 저장 중인 메시지에 우선 순위를 제공한다.

실제 동작은 구현체마다 다르다. `QueueChannel`과 `PriorityChannel`에서 영구<sup>persistent</sup> `MessageStore`로 사용할 수 있는 구현체들은 다음과 같다:

- [Redis Channel Message Stores](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/redis.html#redis-cms)
- [MongoDB Channel Message Store](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/mongodb.html#mongodb-priority-channel-message-store)
- [Backing Message Channels](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/jdbc.html#jdbc-message-store-channels)

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
    <p><code class="highlighter-rouge">SimpleMessageStore</code><Strong>에서 주의할 점</Strong></p>
    <p><code class="highlighter-rouge">SimpleMessageStore</code>는 4.1 버전부터 더 이상 <code class="highlighter-rouge">getMessageGroup()</code>을 호출할 때 메시지 그룹을 복사하지 않는다. 메시지 그룹의 크기가 큰 경우 심각한 성능 저하가 있었기 때문이다. 4.0.1에선 이 동작을 제어할 수 있는 boolean 프로퍼티 <code class="highlighter-rouge">copyOnGet</code>을 도입했다. <code class="highlighter-rouge">SimpleMessageStore</code>를 aggregator 내부에서 사용할 때는 성능 향상을 위해 이 프로퍼티를 <code class="highlighter-rouge">false</code>로 설정했었다. 현재는 기본값이 <code class="highlighter-rouge">false</code>다.</p>
    <p>aggregator 등의 구성 요소 바깥에서 그룹 스토어에 접근한다면, 이제 복사본이 아닌 aggregator가 실제 사용하는 그룹에 대한 참조값을 얻게된다. aggregator 밖에서 이 그룹을 조작한다면 예상치 못한 일이 발생할 수도 있다.</p>
    <p>위와 같은 이유로 그룹을 직접 조작하거나 <code class="highlighter-rouge">copyOnGet</code> 프로퍼티를 <code class="highlighter-rouge">true</code>로 설정하는 것은 지양해야 한다.</p>
</blockquote>

### 13.3.1. Using `MessageGroupFactory`

4.3 버전부터 일부 `MessageGroupStore` 구현체들은 `MessageGroupStore`에서 사용하는 `MessageGroup` 인스턴스를 만들고 커스텀할 수 있는 `MessageGroupFactory` 전략을 주입할 수 있다. 디폴트로 사용하는 `SimpleMessageGroupFactory`는 내부 컬렉션으로 `GroupType.HASH_SET`(`LinkedHashSet`)을 사용하는 `SimpleMessageGroup` 인스턴스를 생성한다. 다른 옵션으론 `SYNCHRONISED_SET`과 `BLOCKING_QUEUE`가 있는데, `BLOCKING_QUEUE`를 사용하면 이전 `SimpleMessageGroup` 동작으로 돌아갈 수 있다. 그 외 `PERSISTENT` 옵션도 사용할 수 있다. 자세한 내용은 다음 섹션을 참고해라. 5.0.1 버전부터는, 그룹 내에서 메시지의 순서나 고유성이 중요하지 않을 땐 `LIST` 옵션도 사용할 수 있다.

### 13.3.2. Persistent `MessageGroupStore` and Lazy-load

4.3 버전부터 모든 영구<sup>persistent</sup> `MessageGroupStore` 인스턴스는 저장소에서 `MessageGroup` 인스턴스와 거기 있는 `message`들을 조회할 때 lazy-load 방식을 채택한다. correlation `MessageHandler` 인스턴스는 대부분 ([Aggregator](../messaging-routing/#84-aggregator), [Resequencer](../messaging-routing/#85-resequencer)), correlation 연산마다 저장소에서 `MessageGroup`을 통으로 로드하면 오버헤드가 생길 수 있어 lazy-load 방식을 활용하는 게 좋다.

설정에서 `AbstractMessageGroupStore.setLazyLoadMessageGroups(false)` 옵션을 사용하면 lazy-load 동작을 끌 수 있다.

MongoDB `MessageStore`([MongoDB Message Store](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/mongodb.html#mongodb-message-store))와 `<aggregator>`([Aggregator](../messaging-routing/#84-aggregator))에서 다음과 유사한 커스텀 `release-strategy`를 사용해 lazy-load 관련 성능 테스트를 진행해봤다:

```xml
<int:aggregator input-channel="inputChannel"
                output-channel="outputChannel"
                message-store="mongoStore"
                release-strategy-expression="size() == 1000"/>
```

간단한 메시지 1000개로 테스트해보면 다음과 같은 결과가 나온다:

```none
...
StopWatch 'Lazy-Load Performance': running time (millis) = 38918
-----------------------------------------
ms     %     Task name
-----------------------------------------
02652  007%  Lazy-Load
36266  093%  Eager
...
```

하지만 5.5 버전부터 모든 영구<sup>persistent</sup> `MessageGroupStore` 구현체는 타겟 데이터베이스의 스트리밍 API를 기반으로 동작하는 `streamMessagesForGroup(Object groupId)` 인터페이스를 제공한다. 이 메소드를 이용하면 저장소에 있는 그룹이 매우 클 때 리소스를 효율적으로 활용할 수 있다. 프레임워크 내부에선 (예를 들면) [Delayer](../messaging-endpoints/#106-delayer)에서 기동 시 저장돼있는 메시지들을 다시 예약할 때 이 API를 사용한다. 반환된 `Stream<Message<?>>`는 처리가 끝나면 반드시 닫아야 한다 (`try-with-resources`를 통한 auto-close 등으로). `PersistentMessageGroup`을 사용할 때마다 `streamMessages()`에선 `MessageGroupStore.streamMessagesForGroup()`에 동작을 위임한다.

### 13.3.3. Message Group Condition

`MessageGroup` 인터페이스는 5.5 버전부터 string 옵션 `condition`을 제공한다. 이 옵션에 넣는 값은, 나중에 파싱해서 그룹에 대한 어떤 결정을 내릴 수만 있다면 자유롭게 선택할 수 있다. 예를 들어서 [correlation 메시지 핸들러](../messaging-routing/#842-programming-model)의 `ReleaseStrategy`는 그룹 안에 있는 모든 메시지를 순회하는 대신 그룹에서 이 프로퍼티를 바로 참조할 수 있다. `MessageGroupStore`엔 `setGroupCondition(Object groupId, String condition)` 메소드가 정의돼있다. 이 메소드를 활용할 수 있도록 `AbstractCorrelatingMessageHandler`에는 `setGroupConditionSupplier(BiFunction<Message<?>, String, String>)` 옵션을 추가해뒀다. 이 함수는 각 메시지를 그룹에 추가한 뒤에, 그룹이 가진 기존 condition을 넘겨 실행한다. 함수 로직에선 새로운 값을 반환하거나, 기존 값을 반환하거나, 그도 아니면 타겟 condition을 `null`로 재설정하면 된다. 이 `condition` 값은 문자열로 직렬화하고 이후에 파싱할 수 있다면, JSON이든, SpEL 표현식이든, 숫자든, 무엇이든지 될 수 있다. 예를 들어, [File Aggregator](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/file.html#file-aggregator)의 `FileMarkerReleaseStrategy`는 `FileSplitter.FileMarker.Mark.END`에 해당하는 메시지의 `FileHeaders.LINE_COUNT` 헤더를 그룹의 condition으로 저장고, `canRelease()`에서 이 condition 값과 그룹 사이즈를 비교한다. 이렇게 하면 `FileHeaders.LINE_COUNT` 헤더를 가진 `FileSplitter.FileMarker.Mark.END` 메시지를 찾기 위해 그룹의 메시지들을 전부 순회하지 않아도 된다. 뿐만 아니라 멀티 스레드 환경에서 하나의 파일을 처리할 때에도, end 마커가 다른 레코드들보다 가장 먼저 aggregator에 도착하게 만들 수 있다.

그 외에도, 더 편하게 설정을 추가할 수 있도록 `GroupConditionProvider` 인터페이스를 도입했다. `AbstractCorrelatingMessageHandler`는 설정해둔 `ReleaseStrategy`가 이 인터페이스를 구현했는지 확인한 뒤, 이후 그룹 condition을 평가할 때 사용할 수 있도록 `conditionSupplier`를 추출해둔다.

---

## 13.4. Metadata Store

외부 시스템이나, 외부 서비스, 리소스 중에는 트랜잭션을 지원하지 않는 것들이 많으며 (Twitter, RSS, 파일 시스템 등), 데이터를 읽은 것으로 마킹할 수 있는 방법을 제공하지 않는 것들도 많다. 간혹 통합 솔루션에 따라 엔터프라이즈 통합 패턴 [idempotent receiver](https://www.enterpriseintegrationpatterns.com/IdempotentReceiver.html)를 구현해야 할 때도 있는데, 이런 상황에선 spring integration의 메타데이터 저장소 `org.springframework.integration.metadata.MetadataStore`를 활용하면, 외부 시스템과의 상호작용을 계속해서 이어가거나 다음 메시지를 처리하기 전에, 엔드포인트의 이전 상태를 저장해둘 수 있다. 이 인터페이스는 일반적인 키-값을 사용하는 인터페이스다.

메타데이터 스토어에 저장할 수 있는 메타데이터는 아주 범용적이라서, 메타데이터 스토어를 활용하면 피드 어댑터 등의 컴포넌트에서 쉽게 중복을 처리할 수 있다 (예를 들어 마지막으로 처리한 피드 항목의 게시 날짜 등을 저장할 수 있다). 컴포넌트가 직접 `MetadataStore`를 참조하고 있지 않은 경우, 다음과 같은 알고리즘을 통해 메타데이터 스토어를 찾는다: 먼저 애플리케이션 컨텍스트에서 ID가 `metadataStore`인 빈을 검색한다. 하나를 발견하면 그대로 사용한다. 그 외는 `SimpleMetadataStore` 인스턴스를 새로 만든다. 이 인스턴스는 현재 실행 중인 애플리케이션 컨텍스트의 라이프사이클 내에서만 메타데이터를 유지하는 인 메모리 구현체다. 즉, 애플리케이션을 재시작한다면 중복되는 항목이 생길 수도 있다.

애플리케이션 컨텍스트를 다시 시작해도 메타데이터를 유지해야 한다면, 아래 있는 영구<sup>persistent</sup> `MetadataStore`를 활용하면 된다:

- `PropertiesPersistingMetadataStore`
- [Gemfire 메타데이터 스토어](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/gemfire.html#gemfire-metadata-store)
- [JDBC 메타데이터 스토어](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/jdbc.html#jdbc-metadata-store)
- [MongoDB 메타데이터 스토어](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/mongodb.html#mongodb-metadata-store)
- [Redis 메타데이터 스토어](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/redis.html#redis-metadata-store)
- [Zookeeper 메타데이터 스토어](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/zookeeper.html#zk-metadata-store)

`PropertiesPersistingMetadataStore`는 프로퍼티 파일과 [`PropertiesPersister`](https://docs.spring.io/spring/docs/current/javadoc-api/org/springframework/util/PropertiesPersister.html)를 사용해 데이터를 저장한다.

`PropertiesPersistingMetadataStore`는 기본적으로 애플리케이션 컨텍스트가 정상적으로 닫힐 때에만 파일에 상태를 남긴다. `Flushable`을 구현하고 있어서 파일에 상태를 남기고 싶을 때마다 `flush()`를 호출하면 된다. 다음은 XML을 이용해 `PropertiesPersistingMetadataStore`를 설정하는 예시다:

```xml
<bean id="metadataStore"
    class="org.springframework.integration.metadata.PropertiesPersistingMetadataStore"/>
```

아니면 `MetadataStore` 인터페이스의 자체 구현체(ex. `JdbcMetadataStore`)를 애플리케이션 컨텍스트 빈으로 설정해도 된다.

4.0 버전부터 `SimpleMetadataStore`, `PropertiesPersistingMetadataStore`, `RedisMetadataStore`는 `ConcurrentMetadataStore`를 구현한다. 덕분에 원자적<sup>atominc</sup> 업데이트가 가능하며, 멀티 컴포넌트나 멀티 애플리케이션 인스턴스에도 활용할 수 있다.

### 13.4.1. Idempotent Receiver and Metadata Store

메타데이터 스토어는 EIP [idempotent receiver](https://www.enterpriseintegrationpatterns.com/IdempotentReceiver.html) 패턴을 구현할 때 유용하게 활용할 수 있다. 전달 받은 메시지들 중 이미 처리한 메시지는 필터링하고, 그대로 폐기하거나<sup>discard</sup> 다른 로직을 실행할 수 있다. 예시는 아래를 참고해라:

```xml
<int:filter input-channel="serviceChannel"
			output-channel="idempotentServiceChannel"
			discard-channel="discardChannel"
			expression="@metadataStore.get(headers.businessKey) == null"/>

<int:publish-subscribe-channel id="idempotentServiceChannel"/>

<int:outbound-channel-adapter channel="idempotentServiceChannel"
                              expression="@metadataStore.put(headers.businessKey, '')"/>

<int:service-activator input-channel="idempotentServiceChannel" ref="service"/>
```

idempotent 항목의 `value`엔 만료 날짜 등을 사용할 수 있다. 이런 경우, 이 날짜가 지나면 reaper를 스케줄링해서 메타데이터 스토어에서 제거해줘야 한다.

[엔터프라이즈 통합 패턴 Idempotent Receiver](../messaging-endpoints/#10911-idempotent-receiver-enterprise-integration-pattern)도 함께 읽어봐라.

### 13.4.2. `MetadataStoreListener`

일부 메타데이터 스토어는 항목이 변경되면 이벤트를 수신할 수 있는 리스너를 등록할 수 있다 (현재는 zookeeper만 지원한다).

```java
public interface MetadataStoreListener {

	void onAdd(String key, String value);

	void onRemove(String key, String oldValue);

	void onUpdate(String key, String newValue);
}
```

자세한 내용은 [Javadoc](https://docs.spring.io/spring-integration/api/org/springframework/integration/metadata/MetadataStoreListenerAdapter.html)을 읽어봐라. 모든 이벤트에 다 관심이 있는게 아니라면 `MetadataStoreListenerAdapter`를 상속해도 된다.

---

## 13.5. Control Bus

[*Enterprise Integration Patterns*](https://www.enterpriseintegrationpatterns.com/)(EIP) 서적에서 설명하는 대로, 컨트롤 버스에 깔려있는 아이디어는 "애플리케이션 수준"에서 메시지를 처리할 때 사용하는 메시징 시스템을 그대로 활용해서 프레임워크 내에 있는 구성 요소들을 모니터링하고 관리하겠다는 거다. Spring Integration은 앞서 다뤘던 어탭터들을 기반으로 움직이기 때문에, 정의된 작업을 호출하는 수단으로 메시지를 전송할 수 있다.

다음은 XML을 이용해 컨트롤 버스를 설정하는 예시다:

```xml
<int:control-bus input-channel="operationChannel"/>
```

컨트롤 버스는 입력 채널이 있어서, 이 입력 채널을 통해 애플리케이션 컨텍스트에 있는 빈으로 특정 작업을 실행할 수 있다. 또한 service activating 핸들러가 가지고 있는 공통 프로퍼티를 모두 가지고 있다. 예를 들어서, 작업을 실행하고 반환 받은 값을 다운스트림 채널로 전송하고 싶다면 출력 채널을 지정할 수 있다.

컨트롤 버스는 입력 채널에서 메시지를 받아 SpEL<sup>Spring Expression Language</sup> 표현식을 통해 로직을 실행한다. 메시지를 하나 받아서 메시지 본문을 표현식으로 컴파일하고, 컨텍스트를 추가한 다음 바로 실행한다. 디폴트 컨텍스트에선 `@ManagedAttribute`나 `@ManagedOperation`을 선언한 모든 메소드를 지원한다. 또한 스프링의 `Lifecycle` 인터페이스에 있는 메소드들 역시 지원하고 있으며 (5.2 버전부터 이를 상속한 `Pausable`에 있는 메소드들도), 일부 `TaskExecutor`, `TaskScheduler` 구현체를 설정할 때 사용하는 메소드들도 지원한다. 직접 만든 메소드를 컨트롤 버스에서 사용할 수 있도록 만들려면 가장 간단하게 `@ManagedAttribute`나 `@ManagedOperation` 어노테이션을 선언해주면 된다. 이 어노테이션들은 JMX MBean 레지스트리에 메소드를 노출하는 데도 사용하는 어노테이션이기 때문에, 좋은 점이 하나 더 있다. 즉, 컨트롤 버스에서 이용하려는 작업들은 보통 JMX를 통해 노출하기에도 적합할 거다. 애플리케이션 컨텍스트 안에 있는 특정 인스턴스를 리졸브하는 일은 일반적인 SpEL 구문을 활용한다. 이땐 빈 이름에 빈의 SpEL 프리픽스(`@`)를 붙여서 사용하면 된다. 예를 들어, 스프링 빈의 메소드를 실행하려면, operation 채널에 다음과 같은 메시지를 전송하면 된다:

```java
Message operation = MessageBuilder.withPayload("@myServiceBean.shutdown()").build();
operationChannel.send(operation)
```

`Message` 자체가 표현식의 컨텍스트 루트이기 때문에, 표현식 안에서 `payload`와 `headers`에도 변수로 접근할 수 있다. 이 점은 표현식을 지원하는 다른 Spring Integration 엔드포인트들과 동일하다.

자바 어노테이션을 이용할 때는 다음과 같이 컨트롤 버스를 설정할 수 있다:

```java
@Bean
@ServiceActivator(inputChannel = "operationChannel")
public ExpressionControlBusFactoryBean controlBus() {
    return new ExpressionControlBusFactoryBean();
}
```

유사하게 Java DSL에선 다음과 같이 플로우를 정의할 수 있다:

```java
@Bean
public IntegrationFlow controlBusFlow() {
    return IntegrationFlows.from("controlBus")
              .controlBus()
              .get();
}
```

람다를 사용해서 `DirectChannel`을 자동으로 생성하는 걸 더 선호한다면, 다음과 같이 컨트롤 버스를 정의하면 된다:

```java
@Bean
public IntegrationFlow controlBus() {
    return IntegrationFlowDefinition::controlBus;
}
```

이 경우 채널의 이름은 `controlBus.input`이다.

---

## 13.6. Orderly Shutdown

"[MBean Exporter](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/jmx.html#jmx-mbean-exporter)"에서 설명하는 대로, MBean 익스포터는 `stopActiveComponents`라는 JMX 연산을 제공한다. 이 연산은 애플리케이션을 정해진 순서대로 중지하는 데 사용한다. 이 연산은 단일 파라미터 `Long`을 사용한다. 이 파라미터는 현재 처리 중인 메시지를 완료할 때까지 대기하는 시간을 나타낸다 (밀리세컨드). 이 연산은 다음과 같이 동작한다:

1. `OrderlyShutdownCapable`을 구현하는 모든 빈에서 `beforeShutdown()`을 호출한다.

   그러면 이 컴포넌트들은 셧다운을 진행할 준비를 할 수 있다. 이 인터페이스를 구현하고 있는 컴포넌트로는, 리스너 컨테이너를 중지하는 JMS 및 AMQP message-driven 어댑터, 새로운 커넥션 수락을 중단하는 TCP 서버 커넥션 팩토리 (기존 커넥션은 열린 상태로 유지한다), (log) 새로 수신한 모든 메시지를 버리는 TCP 인바운드 엔드포인트, 요청이 새로 들어오면 `503 - Service Unavailable`을 반환하는 HTTP 인바운드 엔드포인트가 있다.

2. JMS나 AMQP를 이용하는 채널 등, 모든 활성 채널을 중지한다.

3. 모든 `MessageSource` 인스턴스들을 중지한다.

4. 모든 인바운드 `MessageProducer`(`OrderlyShutdownCapable`이 아닌)를 중지한다.

5. 남은 시간 동안 대기한다 (실행 시 전달한 `Long` 파라미터 값에 정의된대로).

   그러면 아직 처리 중인 메시지들을 모두 완료할 수 있다. 그렇기 때문에 이 연산을 호출할 때는 적절한 타임아웃 시간을 선택하는 게 중요하다.

6. 모든 `OrderlyShutdownCapable` 컴포넌트에서 `afterShutdown()`을 호출한다.

   그러면 이 컴포넌트들은 최종 셧다운 태스크들을 진행할 수 있다 (열려 있는 소켓들을 전부 닫는 등).

[Orderly Shutdown Managed Operation](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/jmx.html#jmx-mbean-shutdown)에서 설명하는 것처럼 이 연산은 JMX를 사용해 실행할 수 있다. 코드 안에서 메소드를 호출하고 싶다면 `IntegrationMBeanExporter`에 대한 참조를 주입하거나 다른 곳에서 가져와야 한다. 하지만 `<int-jmx:mbean-export/>` 정의에 `id` 속성을 제공하지 않았다면 빈 이름을 자동으로 생성한다. JVM 하나에 Spring Integration 컨텍스트가 여러 개 있는 경우 (`MBeanServer`), 이 이름에는 `ObjectName` 충돌을 피하기 위한 랜덤 문자열이 포함된다.

위와 같은 이유로, 코드로 직접 메소드를 호출하려면, 애플리케이션 컨텍스트에서 쉽게 액세스할 수 있도록 익스포터에 `id` 속성을 지정하는 게 좋다.

마지막으로, 이 연산은 `<control-bus>` 요소를 사용해 실행할 수 있다. 자세한 내용은 [Spring Integration 샘플 애플리케이션 모니터링하기](https://github.com/spring-projects/spring-integration-samples/tree/main/intermediate/monitoring)를 참고해라.

> 앞에서 설명한 알고리즘은 4.1 버전에서 개선되었다. 이전에는 모든 태스크 executor와 스케줄러를 중단했었다. 이로 인해 `QueueChannel` 인스턴스에 중간 플로우의 메시지들이 남아있을 수 있었다. 이제는 애플리케이션을 종료해도 이런 메시지들을 비우고 처리할 수 있도록 폴러를 실행 중인 채로 남겨둔다.

---

## 13.7. Integration Graph

Spring Integration은 4.3 버전부터 애플리케이션의 런타임 객체 모델에 접근할 수 있게 해주는데, 원한다면 컴포넌트 메트릭에도 접근할 수 있다. 메트릭은 그래프로 노출되어서, 이를 활용해 통합 애플리케이션의 현재 상태를 시각화할 수 있다. `o.s.i.support.management.graph` 패키지에는 Spring Integration 컴포넌트의 런타임 상태를 하나의 트리와 유사한 `Graph` 객체로 수집, 빌드, 렌더링하는 데 필요한 모든 클래스가 포함돼 있다. `Graph` 객체를 빌드, 조회, 리프레시하려면 `IntegrationGraphServer`를 빈으로 선언해야 한다. `Graph` 객체는 원하는 포맷으로 직렬화할 수 있는데, 그 중에서도 JSON은 유연하기도 하고 클라이언트 측에서 간편하게 파싱하고 표현할 수 있다. 디폴트 컴포넌트들만 가지고 있는 Spring Integration 애플리케이션은 다음과 같은 그래프를 노출한다:

```json
{
  "contentDescriptor" : {
    "providerVersion" : "5.5.15",
    "providerFormatVersion" : 1.2,
    "provider" : "spring-integration",
    "name" : "myAppName:1.0"
  },
  "nodes" : [ {
    "nodeId" : 1,
    "componentType" : "null-channel",
    "integrationPatternType" : "null_channel",
    "integrationPatternCategory" : "messaging_channel",
    "properties" : { },
    "sendTimers" : {
      "successes" : {
        "count" : 1,
        "mean" : 0.0,
        "max" : 0.0
      },
      "failures" : {
        "count" : 0,
        "mean" : 0.0,
        "max" : 0.0
      }
    },
    "receiveCounters" : {
      "successes" : 0,
      "failures" : 0
    },
    "name" : "nullChannel"
  }, {
    "nodeId" : 2,
    "componentType" : "publish-subscribe-channel",
    "integrationPatternType" : "publish_subscribe_channel",
    "integrationPatternCategory" : "messaging_channel",
    "properties" : { },
    "sendTimers" : {
      "successes" : {
        "count" : 1,
        "mean" : 7.807002,
        "max" : 7.807002
      },
      "failures" : {
        "count" : 0,
        "mean" : 0.0,
        "max" : 0.0
      }
    },
    "name" : "errorChannel"
  }, {
    "nodeId" : 3,
    "componentType" : "logging-channel-adapter",
    "integrationPatternType" : "outbound_channel_adapter",
    "integrationPatternCategory" : "messaging_endpoint",
    "properties" : { },
    "output" : null,
    "input" : "errorChannel",
    "sendTimers" : {
      "successes" : {
        "count" : 1,
        "mean" : 6.742722,
        "max" : 6.742722
      },
      "failures" : {
        "count" : 0,
        "mean" : 0.0,
        "max" : 0.0
      }
    },
    "name" : "errorLogger"
  } ],
  "links" : [ {
    "from" : 2,
    "to" : 3,
    "type" : "input"
  } ]
}
```

> [메트릭 관리](#131-metrics-and-management)에서 설명한대로 5.2 버전에선 레거시 메트릭들을 deprecated하였고, Micrometer meter로 그 자리를 대신한다. 이 레거시 메트릭들은 5.4에서 제거되었으며 더 이상 그래프에 나타나지 않는다.

위 예제에 있는 그래프는 세 가지 최상위 요소로 이루어져 있다.

그래프 요소 `contentDescriptor`는 데이터를 제공하는 애플리케이션에 대한 일반적인 정보가 담겨있다. `name`은 `IntegrationGraphServer` 빈이나 애플리케이션 컨텍스트 환경 프로퍼티 `spring.application.name`으로 커스텀할 수 있다. 다른 프로퍼티들은 프레임워크에서 제공하며, 이 정보들을 통해 유사하지만 다른 모델을 구별할 수 있다.

그래프 요소 `links`는 또 다른 그래프 요소 `nodes`에 있는 노드 간의 연결 정보를 가지고 있으며, 따라서 이 정보의 출처인 Spring Integration 애플리케이션이 가지고 있는 통합 구성 요소 간의 연결을 나타낸다고 할 수 있다. 예를 들어서, `MessageChannel`에서 어떤 `MessageHandler`를 가지고 있는 `EventDrivenConsumer`로, 또는 `AbstractReplyProducingMessageHandler`에서 `MessageChannel`로의 연결을 나타낼 수 있다. 이 모델은 링크의 목적을 알 수 있는 `type` 속성을 함께 담고 있다. 가능한 타입은 다음과 같다:

- `input`: `MessageChannel`에서 엔드포인트나 `inputChannel`, 또는 `requestChannel` 프로퍼티까지의 방향을 나타낸다
- `output`: `MessageHandler` 또는 `MessageProducer`, `SourcePollingChannelAdapter`에서 `outputChannel`이나 `replyChannel`을 통한 `MessageChannel`로의 방향
- `error`: `PollingConsumer`의 `MessageHandler`나, `MessageProducer` 또는 `SourcePollingChannelAdapter`에서 `errorChannel` 프로퍼티를 통해 `MessageChannel`로;
- `discard`: `DiscardingMessageHandler`(`MessageFilter`같은)에서 `errorChannel` 프로퍼티를 통해 `MessageChannel`로.
- `route`: `AbstractMappingMessageRouter`(ex. `HeaderValueRouter`)에서 `MessageChannel`로. `output`과 유사하지만 런타임에 결정된다는 특징이 있다. 채널의 매핑 정보를 미리 설정해둘 수도 있고, 동적으로 리졸브할 수도 있다. 라우터는 이럴 때 사용할 동적인 라우팅 정보는 보통 최대 100개까지만 유지하는데, `dynamicChannelLimit` 프로퍼티를 설정하면 이 값을 변경할 수 있다.

시각화 도구에서 `links`에 있는 정보를 사용하면, 그래프 요소 `nodes`에 있는 노드 간의 연결 상태를 렌더링할 수 있다. 여기서 `from`과 `to`에 있는 숫자는 연결된 노드의 `nodeId` 프로퍼티 값을 의미한다. 예를 들어 `link` 요소를 통해 타겟 노드에서 사용할 적당한 `port`를 결정할 수 있다.

아래 "텍스트 이미지"는 타입 간의 관계를 나타내고 있다:

```
              +---(discard)
              |
         +----o----+
         |         |
         |         |
         |         |
(input)--o         o---(output)
         |         |
         |         |
         |         |
         +----o----+
              |
              +---(error)
```

그래프 요소 중엔 아마 `nodes`에 가장 관심이 갈 거다. 여기에는 런타임 구성 요소가 `componentType` 인스턴스, `name` 값과 함께 담겨있을 뿐더러, 이 구성 요소가 노출하는 메트릭이 담겨있을 수도 있기 때문이다. 노드 요소에 담겨 있는 여러 가지 프로퍼티들은 대부분 따로 설명하지 않아도 이해할 수 있을 거다. 예를 들어 표현식 기반 구성 요소는 표현식을 문자열로 나타낸 `expression` 프로퍼티를 가지고 있다. 메트릭을 활성화하려면 `@Configuration` 클래스에 `@EnableIntegrationManagement`를 추가하거나 XML 설정에 `<int:management/>` 요소를 추가해라. 세부 정보는 [메트릭과 관리](#131-metrics-and-management)를 확인해보면 된다.

`nodeId`는 각각의 구성 요소를 구별하기 위한 고유 식별자로, 점점 증가하는 값<sup>incremental</sup>이다. `links` 요소에서 구성 요소 간의 관계(연결)를 나타낼 때도 (있다면) 이 `nodeId`를 사용한다. `input`, `output`은 `AbstractEndpoint`, `MessageHandler`, `SourcePollingChannelAdapter`, `MessageProducerSupport`의 `inputChannel`, `outputChannel` 프로퍼티를 위한 속성이다. 자세한 내용은 다음 섹션을 참고해라.

5.1 버전부터 `IntegrationGraphServer`는 `Function<NamedComponent, Map<String, Object>> additionalPropertiesCallback`을 받아서, 특정 `NamedComponent`에 대한 `IntegrationNode`에 별도 프로퍼티를 추가할 수 있다. 예를 들면 타겟 그래프에 `SmartLifecycle` `autoStartup`과 `running` 프로퍼티를 노출할 수 있다:

```java
server.setAdditionalPropertiesCallback(namedComponent -> {
            Map<String, Object> properties = null;
            if (namedComponent instanceof SmartLifecycle) {
                SmartLifecycle smartLifecycle = (SmartLifecycle) namedComponent;
                properties = new HashMap<>();
                properties.put("auto-startup", smartLifecycle.isAutoStartup());
                properties.put("running", smartLifecycle.isRunning());
            }
            return properties;
        });
```

### 13.7.1. Graph Runtime Model

Spring Integration 컴포넌트들은 저마다 복잡도가 다르다. 예를 들어, `MessageSource`를 폴링할 땐 `SourcePollingChannelAdapter`와 소스 데이터로부터 받은 메시지를 주기적으로 전송할 `MessageChannel`도 함께 따라온다. 미들웨어 request-reply 컴포넌트는 (ex. `JmsOutboundGateway`), `requestChannel`(`input`)의 메시지를 구독(또는 폴링)하는 `AbstractEndpoint`와 응답 메시지를 만들어 다운스트림으로 전송하기 위한 `replyChannel`(`output`)이 따라온다. 한편, `MessageProducerSupport` 구현체는 (ex. `ApplicationEventListeningMessageProducer`) 특정 소스 프로토콜 수신 로직을 감싸 `outputChannel`에 메시지를 전송한다.

Spring Integration 구성 요소들을 그래프로 표현할 땐 `o.s.i.support.management.graph` 패키지에서 찾을 수 있는 `IntegrationNode` 클래스의 계층 구조를 사용한다. 예를 들어 `AggregatingMessageHandler`엔 `ErrorCapableDiscardingMessageHandlerNode`를 사용할 수 있으며 (`AggregatingMessageHandler`는 `discardChannel` 옵션이 있기 때문), 에러는 `PollingConsumer`를 사용해 `PollableChannel`을 컨슘할 때 발생할 수 있다. 또 다른 예시로는 `EventDrivenConsumer`를 사용해 `SubscribableChannel`을 구독할 때 `MessageHandlerChain`을 나타내는 `CompositeMessageHandlerNode`가 있다.

> `@MessagingGateway`([Messaging Gateways](../messaging-endpoints/#104-messaging-gateways) 참고)는 각 메소드마다 노드를 제공한다. 이때 `name` 속성은 게이트웨이의 빈 이름과 짧은 메소드 시그니처를 기반으로 만들어진다. 아래 게이트웨이 예시를 살펴보자:

```java
@MessagingGateway(defaultRequestChannel = "four")
public interface Gate {

	void foo(String foo);

	void foo(Integer foo);

	void bar(String bar);

}
```

위 게이트웨이는 다음과 유사한 노드를 생성한다:

```json
{
  "nodeId" : 10,
  "name" : "gate.bar(class java.lang.String)",
  "stats" : null,
  "componentType" : "gateway",
  "integrationPatternType" : "gateway",
  "integrationPatternCategory" : "messaging_endpoint",
  "output" : "four",
  "errors" : null
},
{
  "nodeId" : 11,
  "name" : "gate.foo(class java.lang.String)",
  "stats" : null,
  "componentType" : "gateway",
  "integrationPatternType" : "gateway",
  "integrationPatternCategory" : "messaging_endpoint",
  "output" : "four",
  "errors" : null
},
{
  "nodeId" : 12,
  "name" : "gate.foo(class java.lang.Integer)",
  "stats" : null,
  "componentType" : "gateway",
  "integrationPatternType" : "gateway",
  "integrationPatternCategory" : "messaging_endpoint",
  "output" : "four",
  "errors" : null
}
```

클라이언트 측에서 이 `IntegrationNode` 계층 구조를 잘 활용하면 그래프 모델을 파싱해 전반적인 Spring Integration의 런타임 동작을 이해할 수 있다. [프로그래밍 팁과 요령](../overview/#57-programming-tips-and-tricks)도 함께 참고하면 좋다.

5.3 버전에선 `IntegrationPattern` 인터페이스를 도입했다. 엔터프라이즈 통합 패턴<sup>Enterprise Integration Pattern; EIP</sup>을 나타내는 spring integration의 모든 구성 요소들은 이 인터페이스를 구현하고 있으며, `IntegrationPatternType` enum 값을 제공한다. 타겟 애플리케이션에서 구성 요소들을 분류하는 로직이 있다면 이 정보를 활용할 수 있으며, 이 정보를 그래프 노드에 노출시키면 UI에서 구성 요소를 그리는 방법을 결정하는 데 참고할 수 있다.

---

## 13.8. Integration Graph Controller

웹 기반 애플리케이션을 개발할 때는 (또는 스프링 부트에서 임베디드 웹 컨테이너를 사용하고 있다면), 클래스패스에 Spring Integration HTTP 혹은 WebFlux 모듈이 있다면 (각각 [HTTP 지원](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/http.html#http)과 [WebFlux 지원](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/webflux.html#webflux) 참고) `IntegrationGraphController`를 사용해 `IntegrationGraphServer` 기능을 REST 서비스로 노출할 수 있다. HTTP 모듈에선 클래스 어노테이션 `@EnableIntegrationGraphController`, `@Configuration`과 XML 요소 `<int-http:graph-controller/>`를 이용하면 된다. 이 설정을 `@EnableWebMvc` 어노테이션(XML로 정의할 땐 `<mvc:annotation-driven/>`)과 함께 사용하면 `@RestController` `IntegrationGraphController`가 등록된다. 이 컨트롤러의 `@RequestMapping.path`는 `@EnableIntegrationGraphController` 어노테이션이나 `<int-http:graph-controller/>` 요소로 설정할 수 있다. 디폴트 경로는 `/integration`이다.

`@RestController` `IntegrationGraphController`는 다음과 같은 서비스를 제공한다:

- `@GetMapping(name = "getGraph")`: 마지막으로 `IntegrationGraphServer`를 리프레시한 이후 Spring Integration 컴포넌트들의 상태를 조회한다. 이 REST 서비스는 `@ResponseBody`로 `o.s.i.support.management.graph.Graph`를 반환한다.
- `@GetMapping(path = "/refresh", name = "refreshGraph")`: 현재 `Graph`를 실제 런타임 상태로 리프레시하고 REST 응답을 반환한다. 메트릭을 확인할 땐 그래프를 리프레시할 필요 없이 실시간으로 제공한다. 마지막으로 그래프를 조회한 이후 애플리케이션 컨텍스트가 수정된 경우 리프레시를 호출할 수 있다. 이 경우 처음부터 그래프를 다시 만든다.

스프링 시큐리티와 스프링 MVC 프로젝트에서 제공하는 표준 설정 옵션과 컴포넌트들을 사용해 `IntegrationGraphController`에 보안 정책과 cross-origin 제약을 설정할 수 있다. 예를 들어:

```xml
<mvc:annotation-driven />

<mvc:cors>
	<mvc:mapping path="/myIntegration/**"
				 allowed-origins="http://localhost:9090"
				 allowed-methods="GET" />
</mvc:cors>

<security:http>
    <security:intercept-url pattern="/myIntegration/**" access="ROLE_ADMIN" />
</security:http>


<int-http:graph-controller path="/myIntegration" />
```

다음은 자바 코드로 동일한 설정을 만드는 예시다:

```java
@Configuration
@EnableWebMvc // or @EnableWebFlux
@EnableWebSecurity // or @EnableWebFluxSecurity
@EnableIntegration
@EnableIntegrationGraphController(path = "/testIntegration", allowedOrigins="http://localhost:9090")
public class IntegrationConfiguration extends WebSecurityConfigurerAdapter {

    @Override
    protected void configure(HttpSecurity http) throws Exception {
	    http
            .authorizeRequests()
               .antMatchers("/testIntegration/**").hasRole("ADMIN")
            // ...
            .formLogin();
    }

    //...

}
```

간편하게 `@EnableIntegrationGraphController` 어노테이션에 있는 `allowedOrigins` 속성을 사용한 것에 주목하자. 이 속성에 지정한 `path`는 `GET` 메소드에만 적용된다. 좀 더 세세한 설정이 필요하다면 표준 스프링 MVC 메커니즘을 사용해 CORS 설정을 매핑해주면 된다.
