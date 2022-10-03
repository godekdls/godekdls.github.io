---
title: What’s New in Spring Integration 5.5?
category: Spring Integration
order: 7
permalink: /Spring%20Integration/whats-new-55/
description: 스프링 인티그레이션 5.5에서 새로 추가된 기능들
image: ./../../images/springintegration/logo.png
lastmod: 2022-01-05T21:30:00+09:00
comments: true
originalRefName: 스프링 인티그레이션
originalRefLink: https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/index-single.html#whats-new
parent: What’s New?
parentUrl: /Spring%20Integration/whats-new/
---

---

좀 더 자세한 내용이 알고 싶다면, 5.5 개발 프로세스에서 해결 처리된 Issue Tracker 티켓들을 참고해라.

### 목차

- [4.1. New Components](#41-new-components)
  + [4.1.1. File Aggregator](#411-file-aggregator)
  + [4.1.2. MQTT v5 Support](#412-mqtt-v5-support)
- [4.2. General Changes](#42-general-changes)
  + [4.2.1. Integration Flows Composition](#421-integration-flows-composition)
  + [4.2.2. AMQP Changes](#422-amqp-changes)
  + [4.2.3. Redis Changes](#423-redis-changes)
  + [4.2.4. HTTP Changes](#424-http-changes)
  + [4.2.5. File/FTP/SFTP Changes](#425-fileftpsftp-changes)
  + [4.2.6. MongoDb Changes](#426-mongodb-changes)
  + [4.2.7. WebSockets Changes](#427-websockets-changes)
  + [4.2.8. JPA Changes](#428-jpa-changes)
  + [4.2.9. Gateway Changes](#429-gateway-changes)

---

## 4.1. New Components

### 4.1.1. File Aggregator

`CorrelationStrategy`, `ReleaseStrategy`, `MessageGroupProcessor`의 `FileSplitter.FileMaker` 기반 구현체 `FileAggregator`를 도입했다. 자세한 내용은 [File Aggregator](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/file.html#file-aggregator)를 참고해라.

### 4.1.2. MQTT v5 Support

MQTT v5 프로토콜 통신 지원을 위해 `Mqttv5PahoMessageDrivenChannelAdapter`, `Mqttv5PahoMessageHandler`(각각의 `MqttHeaderMapper`도 포함해서)를 도입했다. 자세한 내용은 [MQTT v5 지원](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/mqtt.html#mqtt-v5)을 참고해라.

---

## 4.2. General Changes

모든 영구<sup>persistent</sup> `MessageGroupStore` 구현체는 타겟 데이터베이스의 스트리밍 API를 기반으로 `streamMessagesForGroup(Object groupId)` 인터페이스를 구현한다. 자세한 내용은 [메시지 스토어](../system-management/#133-message-store)를 참고해라.

`integrationGlobalProperties` 빈은 (선언했다면) 이제 반드시 `java.util.Properties` 대신 `org.springframework.integration.context.IntegrationProperties`의 인스턴스여야 한다. `java.util.Properties`는 이전 버전과의 호환성을 위해 deprecated되었다. 글로벌 디폴트 `errorChannel`을 반드시 `requireSubscribers` 옵션으로 설정해야 하는지 여부를 표현하는 글로벌 프로퍼티 `spring.integration.channels.error.requireSubscribers=true`가 추가됐다. 글로벌 디폴트 `errorChannel`이 반드시 디스패칭 에러를 무시하고 다음 핸들러로 메시지를 전달해야 하는지 여부를 표현하는 글로벌 프로퍼티 `spring.integration.channels.error.ignoreFailures=true`를 추가했다. 자세한 내용은 [글로벌 프로퍼티](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/configuration.html#global-properties)를 참고해라.

`AbstractPollingEndpoint`(소스 폴링 채널 어댑터와 폴링 컨슈머)는 `maxMessagesPerPoll == 0`을 소스 호출을 건너뛰라는 의미로 받아들인다. 이 값은 나중에 컨트롤 버스 등을 통해 다른 값으로 변경할 수 있다. 자세한 내용은 [폴링 컨슈머](../messaging-endpoints/#1013-polling-consumer)를 참고해라.

`ConsumerEndpointFactoryBean`은 이제 입력 채널로 사용하는 리액티브 스트림 소스를 위한 `reactiveCustomizer` `Function`을 받으며, 내부에선 `ReactiveStreamsConsumer`를 사용한다. 이 기능은 Java DSL의 `ConsumerEndpointSpec.reactive()` 옵션과 메시지 처리 어노테이션에 중첩해서 쓰는 `@Reactive` 어노테이션으로 커버한다. 자세한 내용은 [리액티브 스트림즈 지원](../reactive-streams)을 참고해라.

correlation 메시지 핸들러(`Aggregator`와 `Resequencer`)의 `groupTimeoutExpression`은 이제 `java.util.Date`로 평가해서 스케줄링 정책을 세세하게 조정할 수 있다. 또한 `AbstractCorrelatingMessageHandler`에는 `BiFunction groupConditionSupplier` 옵션이 추가돼서, 그룹에 추가하는 메시지를 보고 `MessageGroup` condition을 제공할 수 있다. 자세한 내용은 [Aggregator](../messaging-routing/#84-aggregator)를 참고해라.

`MessageGroup` 인터페이스를 `condition`과 함께 제공하면, 이후 이 condition을 평가해 그 그룹에 대한 결정을 내릴 수 있다. 자세한 내용은 [메시지 그룹 Condition](../system-management/#1333-message-group-condition)을 참고해라.

### 4.2.1. Integration Flows Composition

팩토리 메소드 `IntegrationFlows.from(IntegrationFlow)`가 새로 추가되어 기존 플로우의 출력에서부터 현재 `IntegrationFlow`를 시작할 수 있다. 또한 `IntegrationFlowDefinition`엔 터미널 연산자 `to(IntegrationFlow)`가 추가돼서, 다른 플로우의 입력 채널에서 현재 플로우를 이어갈 수 있다. 자세한 내용은 [통합 플로우 조립](../java-dsl/#1124-integration-flows-composition)을 참고해라.

### 4.2.2. AMQP Changes

`AmqpInboundChannelAdapter`와 `AmqpInboundGateway`는 (그리고 각각의 Java DSL 빌더도) 이제 범용 `RecoveryCallback` 대신 쓸 수 있는 AMQP 전용 `org.springframework.amqp.rabbit.retry.MessageRecoverer`를 지원한다. 자세한 내용은 [AMQP 지원](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/amqp.html#amqp)을 참고해라.

### 4.2.3. Redis Changes

`ReactiveRedisStreamMessageProducer`는 이제 `onErrorResume` 함수를 비롯한 모든 `StreamReceiver.StreamReceiverOptionsBuilder` 옵션을 위한 setter를 가지고 있다. 자세한 내용은 [Redis 지원](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/redis.html#redis)을 참고해라.

### 4.2.4. HTTP Changes

`HttpRequestExecutingMessageHandler`는 더 이상 컨텐츠 타입 `application/x-java-serialized-object`로 폴백하지 않으며, `RestTemplate`이 설정에 있는 `HttpMessageConverter`를 기반으로 요청 바디를 어떻게 변환할지 최종적으로 결정한다. 또한 `HttpRequestExecutingMessageHandler`는 이제 `extractResponseBody` 플래그를 가져서 (디폴트는 `true`다), 설정한 `expectedResponseType`과는 상관 없이 응답 바디만 반환하거나 전체 `ResponseEntity`를 응답 메시지 페이로드로 반환할 수 있다. `WebFluxRequestExecutingMessageHandler`도 동일한 옵션을 제공한다. 자세한 내용은 [HTTP 지원](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/http.html#http)을 참고해라.

### 4.2.5. File/FTP/SFTP Changes

영구<sup>persistent</sup> 파일 리스트 필터는 이제 boolean 프로퍼티 `forRecursion`을 가진다. 이 프로퍼티를 `true`로 설정하면 `alwaysAcceptDirectories`도 함께 세팅된다. 즉, 아웃바운드 게이트웨이에 대한 재귀 연산은 (`ls`, `mget`) 이제 매번 전체 디렉토리 트리를 순회한다. 이는 디렉토리 트리 깊은 곳에서 발생한 변경 사항을 감지하지 못하는 문제를 해결하기 위한 것이다. 또한 `forRecursion=true`를 설정하면 파일의 전체 경로를 메타데이터 스토어 키로 사용하게 된다. 덕분에 여러 디렉토리에 같은 이름을 가진 파일이 여러 개 있을 때 필터가 제대로 동작하지 않던 문제가 해결된다. 주의해야 할 점은, 최상위 디렉토리 밑에 있는 파일에선 영구<sup>persistent</sup> 메타데이터 스토어에 있던 기존 키를 찾을 수 없게 된다. 이러한 이유로 이 프로퍼티의  기본값은 `false`다. 향후 릴리즈에선 변경될 수 있다.

`FileInboundChannelAdapterSpec`에는 이제 `recursive(boolean)` 옵션이 있어서  `RecursiveDirectoryScanner`에 대한 참조를 명시하지 않아도 된다.

이제 `mv` 커맨드에서 간편하게 `remoteDirectoryExpression`을 사용할 수 있다.

### 4.2.6. MongoDb Changes

MongoDd Java DSL에 `MongoDbMessageSourceSpec`이 추가됐다. 이제 `update` 옵션을 `MongoDbMessageSource`와 `ReactiveMongoDbMessageSource` 구현체 모두에서 사용할 수 있다.

자세한 내용은 [MongoDb 지원](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/mongodb.html#mongodb)을 참고해라.

### 4.2.7. WebSockets Changes

이제 `ServerWebSocketContainer`를 기반으로 동작하는 웹소켓 채널 어댑터를 런타임에 등록하고 제거할 수 있다.

자세한 내용은 [WebSockets 지원](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/web-sockets.html#web-sockets)을 참고해라.

### 4.2.8. JPA Changes

`JpaOutboundGateway`는 이제 `PersistMode.DELETE`를 위한 `Iterable` 메시지 페이로드를 지원한다.

자세한 내용은 [아웃바운드 채널 어댑터](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/jpa.html#jpa-outbound-channel-adapter)를 참고해라.

### 4.2.9. Gateway Changes

이전에는 XML 설정을 사용할 땐, 인자가 없는 메소드에선 `@Gateway.payloadExpression`을 무시했었다. 한 가지 큰 변화가 있는데, 이전에는 메소드에 `@Payload`와 `@Gateway` 어노테이션을 함께 선언했다면 (다른 표현식을 사용해서) `@Payload`가 적용됐지만, 이제는 `@Gateway.payloadExpression`이 적용된다. 자세한 내용은 [어노테이션과 XML을 이용해 게이트웨이 설정하기](../messaging-endpoints/#1044-gateway-configuration-with-annotations-and-xml)와 [인자를 받지 않는 메소드 호출하기](../messaging-endpoints/#1047-invoking-no-argument-methods)를 참고해라.