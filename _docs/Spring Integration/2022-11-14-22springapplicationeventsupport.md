---
title: Spring ApplicationEvent Support
category: Spring Integration
order: 22
permalink: /Spring%20Integration/applicationevent/
description: ApplicationEvents를 받아 메시지를 전달하고, 메시지를 받아 ApplicationEvents를 전송하는 방법
image: ./../../images/springintegration/logo.png
lastmod: 2022-11-14T22:00:00+09:00
comments: true
originalRefName: 스프링 인티그레이션
originalRefLink: https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/index-single.html#applicationevent
parent: Integration Endpoints
parentUrl: /Spring%20Integration/integration-endpoints/
---

---

Spring Integration은 스프링 프레임워크에 정의돼있는 인바운드/아웃바운드 `ApplicationEvents`를 지원한다. 스프링이 지원하는 이벤트와 리스너에 대한 자세한 내용은 [스프링 레퍼런스 매뉴얼](https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#context-functionality-events)을 참고해라.

프로젝트에는 아래 의존성을 추가해야 한다:

> **Maven**
>
> ```xml
> <dependency>
>     <groupId>org.springframework.integration</groupId>
>     <artifactId>spring-integration-event</artifactId>
 >    <version>5.5.15</version>
> </dependency>
> ```
>
> **Gradle**
>
> ```groovy
> compile "org.springframework.integration:spring-integration-event:5.5.15"
> ```

### 목차

- [16.1. Receiving Spring Application Events](#161-receiving-spring-application-events)
- [16.2. Sending Spring Application Events](#162-sending-spring-application-events)

---

## 16.1. Receiving Spring Application Events

이벤트를 받아 채널로 전송하려면 Spring Integration의 `ApplicationEventListeningMessageProducer` 인스턴스를 정의하면 된다. 이 클래스는 스프링의 `ApplicationListener` 인터페이스를 구현하고 있다. 기본적으로는 전달받은 모든 이벤트를 Spring Integration 메시지로 전달한다. 이벤트 유형에 따라 제한을 두고 싶다면, 'eventTypes' 프로퍼티를 이용해 전달받고 싶은 이벤트 타입 리스트를 설정하면 된다. 수신한 이벤트의 'source'가 `Message` 인스턴스라면 이 `Message`를 그대로 전달한다. 그 외 SpEL 기반 `payloadExpression`을 설정한 경우, `ApplicationEvent` 인스턴스를 가지고 표현식을 평가한다. 이벤트 소스가 `Message` 인스턴스가 아니면서 `payloadExpression`도 지정하지 않은 경우엔 `ApplicationEvent` 자체를 페이로드로 전달한다.

`ApplicationEventListeningMessageProducer`는 4.2 버전부터 `GenericApplicationListener`를 구현해서, `ApplicationEvent` 타입 뿐 아니라 페이로드 이벤트를 처리하는데 필요한 모든 타입을 수용하도록 설정할 수 있다 (스프링 프레임워크 4.2부터 지원). 수락한 이벤트가 `PayloadApplicationEvent` 인스턴스인 경우, 거기 있는 `payload`를 사용해 메시지를 전송한다.

네임스페이스를 활용하면, `inbound-channel-adapter` 요소에서는 다음과 같이 간편하게 `ApplicationEventListeningMessageProducer`를 설정할 수 있다:

```xml
<int-event:inbound-channel-adapter channel="eventChannel"
                                   error-channel="eventErrorChannel"
                                   event-types="example.FooEvent, example.BarEvent, java.util.Date"/>

<int:publish-subscribe-channel id="eventChannel"/>
```

위 예제를 살펴보면, 'event-types'(생략 가능) 속성에 지정한 타입 중 하나와 매칭되는 모든 애플리케이션 컨텍스트 이벤트를 'eventChannel'이라는 메시지 채널에 Spring Integration 메시지로 전달한다. 다운스트림에 있는 구성 요소에서 예외가 발생하면, 실패 메시지와 예외가 담긴 `MessagingException`을 'eventErrorChannel'이란 채널로 전송한다. `error-channel`을 따로 지정하지 않았고 다운스트림 채널이 동기식으로 동작하는 채널이라면 예외를 호출부로 전파한다.

같은 어댑터를 자바를 이용해 설정한다면:

```java
@Bean
public ApplicationEventListeningMessageProducer eventsAdapter(
            MessageChannel eventChannel, MessageChannel eventErrorChannel) {

    ApplicationEventListeningMessageProducer producer =
        new ApplicationEventListeningMessageProducer();
    producer.setEventTypes(example.FooEvent.class, example.BarEvent.class, java.util.Date.class);
    producer.setOutputChannel(eventChannel);
    producer.setErrorChannel(eventErrorChannel);
    return producer;
}
```

Java DSL을 이용할 때는:

```java
@Bean
public ApplicationEventListeningMessageProducer eventsAdapter() {

    ApplicationEventListeningMessageProducer producer =
        new ApplicationEventListeningMessageProducer();
    producer.setEventTypes(example.FooEvent.class, example.BarEvent.class, java.util.Date.class);
    return producer;
}

@Bean
public IntegrationFlow eventFlow(ApplicationEventListeningMessageProducer eventsAdapter,
        MessageChannel eventErrorChannel) {

    return IntegrationFlows.from(eventsAdapter, e -> e.errorChannel(eventErrorChannel))
        .handle(...)
        ...
        .get();
}
```

---

## 16.2. Sending Spring Application Events

스프링의 `ApplicationEvents`를 전송하려면 `ApplicationEventPublishingMessageHandler` 인스턴스를 하나 생성하고 엔드포인트에 등록해주면 된다. 이 구현체는 `MessageHandler` 인터페이스 뿐 아니라 스프링의 `ApplicationEventPublisherAware` 인터페이스도 구현하고 있기 때문에, 결과적으로 보면 Spring Integration 메시지와 `ApplicationEvents`를 이어주는 다리라고 할 수 있다.

네임스페이스를 활용하면, `outbound-channel-adapter` 요소에서는 다음과 같이 간편하게 `ApplicationEventPublishingMessageHandler`를 설정할 수 있다:

```xml
<int:channel id="eventChannel"/>

<int-event:outbound-channel-adapter channel="eventChannel"/>
```

`PollableChannel`을 사용한다면 (ex. `QueueChannel`) `outbound-channel-adapter` 요소 하위에 `poller`를 제공할 수도 있다. 원한다면 폴러에 `task-executor` 참조를 제공해도 된다. 다음은 이 두 가지를 모두 보여주는 예시다:

```xml
<int:channel id="eventChannel">
  <int:queue/>
</int:channel>

<int-event:outbound-channel-adapter channel="eventChannel">
  <int:poller max-messages-per-poll="1" task-executor="executor" fixed-rate="100"/>
</int-event:outbound-channel-adapter>

<task:executor id="executor" pool-size="5"/>
```

위 예제에선, 'eventChannel'로 전송된 모든 메시지를 `ApplicationEvent` 인스턴스로 발행한다. 같은 스프링 `ApplicationContext` 내에 등록되어있는 관련 `ApplicationListener` 인스턴스들은 모두 이 이벤트를 수신할 수 있다. 메시지의 페이로드가 `ApplicationEvent`인 경우 그대로 전달하고, 그 외는 메시지를 `MessagingEvent` 인스턴스로 감싼다.

4.2 버전부터 `ApplicationEventPublishingMessageHandler`(`<int-event:outbound-channel-adapter>`)를 설정할 때 boolean 속성 `publish-payload`를 사용하면 애플리케이션 컨텍스트 `payload`를 `MessagingEvent` 인스턴스로 감싸지 안은 채 그대로 발행할 수 있다.

이 어댑터를 자바를 이용해 설정한다면:

```java
@Bean
@ServiceActivator(inputChannel = "eventChannel")
public ApplicationEventPublishingMessageHandler eventHandler() {
    ApplicationEventPublishingMessageHandler handler =
            new ApplicationEventPublishingMessageHandler();
    handler.setPublishPayload(true);
    return handler;
}
```

Java DSL을 이용할 때는:

```java
@Bean
public ApplicationEventPublishingMessageHandler eventHandler() {
    ApplicationEventPublishingMessageHandler handler =
            new ApplicationEventPublishingMessageHandler();
    handler.setPublishPayload(true);
    return handler;
}

@Bean
// MessageChannel is "eventsFlow.input"
public IntegrationFlow eventsOutFlow(ApplicationEventPublishingMessageHandler eventHandler) {
    return f -> f.handle(eventHandler);
}
```
