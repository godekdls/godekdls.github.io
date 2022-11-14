---
title: Appendix F. Configuration
category: Spring Integration
order: 29
permalink: /Spring%20Integration/configuration/
description: Spring Integration 설정 가이드
image: ./../../images/springintegration/logo.png
lastmod: 2022-11-14T22:00:00+09:00
comments: true
originalRefName: 스프링 인티그레이션
originalRefLink: https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/index-single.html#configuration
parent: Appendices
parentUrl: /Spring%20Integration/appendices/
---

---

Spring Integration은 매우 다양한 설정 옵션들을 제공한다. 가지고 있는 요구 사항과 선호하는 작업 수준에 따라서 옵션을 선택하면 된다. 스프링 프레임워크를 사용하면 늘 그렇듯이, 당면한 문제에 맞게 다양한 기술들을 원하는 대로 조합할 수 있다. 예를 들어, 대부분의 설정에는 XSD 기반 네임스페이스를 채용하고, 일부 객체만 어노테이션으로 설정할 수도 있다. XML 설정과 어노테이션 설정에선 가능한 한 일관적인 네이밍을 제공하고 있다. XSD 스키마로 정의하는 XML 요소는 어노테이션의 이름과 일치하고, 이 XML 요소의 속성들은 어노테이션 프로퍼티명과 일치한다. API를 직접 사용할 수도 있지만, 특별한 사유가 없다면 고수준 옵션 중에서 하나를 선택하거나, 네임스페이스 기반 설정과 어노테이션 기반 설정을 조합해서 쓰는 것이 좋다.

### 목차

- [F.1. Namespace Support](#f1-namespace-support)
- [F.2. Configuring the Task Scheduler](#f2-configuring-the-task-scheduler)
- [F.3. Global Properties](#f3-global-properties)
- [F.4. Annotation Support](#f4-annotation-support)
  + [F.4.1. Using the @Poller Annotation](#f41-using-the-poller-annotation)
  + [F.4.2. Using @Reactive Annotation](#f42-using-reactive-annotation)
  + [F.4.3. Using the @InboundChannelAdapter Annotation](#f43-using-the-inboundchanneladapter-annotation)
  + [F.4.4. Using the `@MessagingGateway` Annotation](#f44-using-the-messaginggateway-annotation)
  + [F.4.5. Using the @IntegrationComponentScan Annotation](#f45-using-the-integrationcomponentscan-annotation)
- [F.5. Messaging Meta-Annotations](#f5-messaging-meta-annotations)
  + [F.5.1. Annotations on @Bean Methods](#f51-annotations-on-bean-methods)
  + [F.5.2. Creating a Bridge with Annotations](#f52-creating-a-bridge-with-annotations)
  + [F.5.3. Advising Annotated Endpoints](#f53-advising-annotated-endpoints)
- [F.6. Message Mapping Rules and Conventions](#f6-message-mapping-rules-and-conventions)
  + [F.6.1. Sample Scenarios](#f61-sample-scenarios)
  + [F.6.2. Annotation-based Mapping](#f62-annotation-based-mapping)
  + [F.6.3. Complex Scenarios](#f63-complex-scenarios)

---

## F.1. Namespace Support

Spring Integration 구성 요소들을 설정할 때 사용하는 XML 요소들은 엔터프라이즈 통합에서 사용하는 용어/개념과 일맥상통한다. 요소의 이름은 [*Enterprise Integration Patterns*](https://www.enterpriseintegrationpatterns.com/) 서적에 나오는 패턴의 이름과 일치하는 경우가 많다.

스프링 설정 파일 안에서 Spring Integration의 코어 네임스페이스를 이용하려면, 최상위 요소 'beans'에 다음과 같은 네임스페이스 참조와 스키마 매핑 정보를 추가해라:

<div class="language-xml highlighter-rouge"><div class="highlight"><pre class="highlight"><code><span class="nt">&lt;beans</span> <span class="na">xmlns=</span><span class="s">"http://www.springframework.org/schema/beans"</span>
       <span class="na">xmlns:xsi=</span><span class="s">"http://www.w3.org/2001/XMLSchema-instance"</span>
       <span class="na"><strong>xmlns:int=</strong></span><span class="s"><strong>"http://www.springframework.org/schema/integration"</strong></span>
       <span class="na">xsi:schemaLocation=</span><span class="s">"http://www.springframework.org/schema/beans
           https://www.springframework.org/schema/beans/spring-beans.xsd
           <strong>http://www.springframework.org/schema/integration</strong>
           <strong>https://www.springframework.org/schema/integration/spring-integration.xsd"</strong></span><span class="nt">&gt;</span>
</code></pre></div></div>

(Spring Integration과 관련된 라인은 볼드 처리해놨다.)

"xmlns:" 뒤에 나오는 이름은 자유롭게 선택하면 된다. 여기서는 간단명료하게 Integration의 줄임말인 `int`를 사용했지만, 원하는 다른 이름이 있을 수도 있다. 한편, XML 편집기나 IDE에서 자동 완성 기능을 사용하고 있다면, 알아보기 쉽게 조금 더 긴 이름을 사용하라는 안내를 볼 수도 있다. 아니면 다음 예제와 같이 설정 파일 내에서 Spring Integration 스키마를 기본<sup>primary</sup> 네임스페이스로 사용하는 방법도 있다:

<div class="language-xml highlighter-rouge"><div class="highlight"><pre class="highlight"><code><span class="nt"><strong>&lt;beans:beans</strong></span> <span class="na"><strong>xmlns=</strong></span><span class="s"><strong>"http://www.springframework.org/schema/integration"</strong></span>
       <span class="na">xmlns:xsi=</span><span class="s">"http://www.w3.org/2001/XMLSchema-instance"</span>
       <span class="na">xmlns:beans=</span><span class="s">"http://www.springframework.org/schema/beans"</span>
       <span class="na">xsi:schemaLocation=</span><span class="s">"http://www.springframework.org/schema/beans
           https://www.springframework.org/schema/beans/spring-beans.xsd
           <strong>http://www.springframework.org/schema/integration</strong>
           <strong>https://www.springframework.org/schema/integration/spring-integration.xsd"</strong></span><span class="nt">&gt;</span>
</code></pre></div></div>

(Spring Integration과 관련된 라인은 볼드 처리해놨다.)

이 방법을 사용할 때는 Spring Integration 요소에 프리픽스를 붙이지 않아도 된다. 반면, 같은 설정 파일 안에 일반적인 스프링 빈을 정의하려면 bean 요소 앞에 프리픽스를 붙여야 한다 (`<beans:bean …/>`). 일반적으로 설정 파일 자체도 역할이나 아키텍처 레이어를 기준으로 나누는 것이 좋기 때문에, integration에 초첨을 둔 설정 파일에선 이 방법을 사용하는 게 괜찮다고 느껴질 거다. integration 설정 파일에선 일반적인 빈이 거의 필요 없기 때문이다. 따라서 이 문서에서는 integration 네임스페이스가 기본<sup>primary</sup> 네임스페이스라고 가정한다.

Spring Integration은 다른 네임스페이스도 많이 제공한다. 실제로 네임스페이스를 지원하는 모든 어댑터(JMS, 파일 등)는 별도의 스키마 안에서 전용 요소를 정의하고 있다. 이러한 요소를 사용하려면, `xmlns` 항목과 관련 `schemaLocation` 매핑 정보와 함께 필요한 네임스페이스를 추가하면 된다. 예를 들어 아래 보이는 루트 요소는 이러한 네임스페이스 중 몇 가지를 선언하고 있다:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:int="http://www.springframework.org/schema/integration"
  xmlns:int-file="http://www.springframework.org/schema/integration/file"
  xmlns:int-jms="http://www.springframework.org/schema/integration/jms"
  xmlns:int-mail="http://www.springframework.org/schema/integration/mail"
  xmlns:int-rmi="http://www.springframework.org/schema/integration/rmi"
  xmlns:int-ws="http://www.springframework.org/schema/integration/ws"
  xsi:schemaLocation="http://www.springframework.org/schema/beans
    https://www.springframework.org/schema/beans/spring-beans.xsd
    http://www.springframework.org/schema/integration
    https://www.springframework.org/schema/integration/spring-integration.xsd
    http://www.springframework.org/schema/integration/file
    https://www.springframework.org/schema/integration/file/spring-integration-file.xsd
    http://www.springframework.org/schema/integration/jms
    https://www.springframework.org/schema/integration/jms/spring-integration-jms.xsd
    http://www.springframework.org/schema/integration/mail
    https://www.springframework.org/schema/integration/mail/spring-integration-mail.xsd
    http://www.springframework.org/schema/integration/rmi
    https://www.springframework.org/schema/integration/rmi/spring-integration-rmi.xsd
    http://www.springframework.org/schema/integration/ws
    https://www.springframework.org/schema/integration/ws/spring-integration-ws.xsd">
 ...
</beans>
```

이 레퍼런스 매뉴얼에선 다양한 요소들에 필요한 예시를 전용 챕터에서 따로 제공하고 있다. 여기에서 기억해둬야 할 것은, 각 네임스페이스 URI와 스키마 location의 이름을 일관성있게 정의했다는 점이다.

---

## F.2. Configuring the Task Scheduler

Spring Integration에서는 `ApplicationContext`가 메시지 버스의 중심 역할을 담당하고 있기 때문에, 개발자는 몇 가지 설정들만 고려하면 된다. 가장 먼저, 중앙의 `TaskScheduler` 인스턴스를 제어하고 싶을 수 있다. 이때는 `taskScheduler`라는 빈을 하나 제공하면 된다. 이 이름은 다음과 같은 상수로도 정의돼 있다:

```java
IntegrationContextUtils.TASK_SCHEDULER_BEAN_NAME
```

기본적으로 Spring Integration에선 스프링 프레임워크 레퍼런스 매뉴얼의 [태스크 실행과 예약](https://docs.spring.io/spring/docs/current/spring-framework-reference/integration.html#scheduling) 섹션에서 설명하는 `ThreadPoolTaskScheduler` 인스턴스를 사용한다. 디폴트 `TaskScheduler`는 10개의 스레드 풀로 자동 시작되지만, 필요하다면 [글로벌 프로퍼티](#f3-global-properties)를 참고하면 된다. 디폴트 인스턴스를 사용하는 대신 자체 `TaskScheduler` 인스턴스를 제공하는 경우, 'autoStartup' 프로퍼티를 `false`로 설정하거나 풀 사이즈를 직접 지정할 수 있다.

폴링 컨슈머 설정에 태스크 executor 참조를 지정하면, 핸들러 메소드의 호출은 메인 스케줄러 풀이 아닌 해당 executor의 스레드 풀 내에서 일어난다. 하지만 엔드포인트의 폴러에 태스크 executor를 제공하지 않으면, 메인 스케줄러의 스레드 중 하나에서 핸들러 메소드를 호출한다.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>폴러 스레드에선 오랫동안 실행되는 태스크를 실행하면 안 된다. 그대신 태스크 executor를 이용해라. 폴링 엔드포인트가 많을 땐 그만큼 풀 사이즈를 늘려주지 않는다면 스레드 기아 상태<sup> thread starvation</sup>에 빠질 수 있다. 참고로, 폴링 컨슈머의 디폴트 <code class="highlighter-rouge">receiveTimeout</code>은 1초다. 이 시간 동안은 폴러 스레드가 블로킹되므로, 이런 엔드포인트가 많을 때 역시 기아 상태 방지를 위해 태스크 executor를 사용하는 것이 좋다. 아니면 <code class="highlighter-rouge">receiveTimeout</code>을 줄이는 방법도 있다.</p>
</blockquote>


> 엔드포인트의 입력 채널이 큐 기반(즉, pollable) 채널 중 하나라면, 그 엔드포인트는 폴링 컨슈머다. 반면, 이벤트 기반 컨슈머는 대기열이 아닌 디스패처를 가지고 있는(subscribable) 입력 채널을 사용한다. 이런 엔드포인트들은 직접 핸들러를 호출하기 때문에 폴러 설정을 가지고 있지 않다.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>JEE 컨테이너에서 실행할 때는, 디폴트 <code class="highlighter-rouge">taskScheduler</code> 대신 <a href="https://docs.spring.io/spring/docs/current/spring-framework-reference/integration.html#scheduling-task-scheduler-implementations">여기</a>에서 설명하는 스프링의 <code class="highlighter-rouge">TimerManagerTaskScheduler</code>를 사용해야 할 수도 있다. 그러려면 다음과 같이 가지고 있는 환경에 적합한 JNDI 이름을 사용해 빈을 정의해라:</p>
  <div class="language-xml highlighter-rouge"><div class="highlight"><pre class="highlight"><code><span class="nt">&lt;bean</span> <span class="na">id=</span><span class="s">"taskScheduler"</span> <span class="na">class=</span><span class="s">"org.springframework.scheduling.concurrent.DefaultManagedTaskScheduler"</span><span class="nt">&gt;</span>
    <span class="nt">&lt;property</span> <span class="na">name=</span><span class="s">"jndiName"</span> <span class="na">value=</span><span class="s">"tm/MyTimerManager"</span> <span class="nt">/&gt;</span>
    <span class="nt">&lt;property</span> <span class="na">name=</span><span class="s">"resourceRef"</span> <span class="na">value=</span><span class="s">"true"</span> <span class="nt">/&gt;</span>
<span class="nt">&lt;/bean&gt;</span>
</code></pre></div>  </div>
</blockquote>
<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>애플리케이션 컨텍스트에 커스텀 <code class="highlighter-rouge">TaskScheduler</code>를 설정한다면 (위에서 언급한 <code class="highlighter-rouge">DefaultManagedTaskScheduler</code>같이), 프레임워크에서 제공하는 디폴트 <code class="highlighter-rouge">TaskScheduler</code> 빈처럼 에러 채널로 전송되는 <code class="highlighter-rouge">ErrorMessage</code>로 예외를 처리할 수 있도록 <code class="highlighter-rouge">MessagePublishingErrorHandler</code>(<code class="highlighter-rouge">integrationMessagePublishingErrorHandler</code> 빈)를 함께 제공하는 것이 좋다.</p>
</blockquote>


자세한 정보는 [에러 핸들링](../error-handling)을 함께 읽어봐라.

---

## F.3. Global Properties

몇 가지 글로벌 프레임워크 프로퍼티들은 클래스패스에 프로퍼티 파일을 제공하면 재정의할 수 있다.

디폴트 프로퍼티는 `org.springframework.integration.context.IntegrationProperties` 클래스에서 찾을 수 있다. 아래에는 기본값들을 함께 표기해뒀다:

```properties
spring.integration.channels.autoCreate=true  // (1)
spring.integration.channels.maxUnicastSubscribers=0x7fffffff  // (2)
spring.integration.channels.maxBroadcastSubscribers=0x7fffffff  // (3)
spring.integration.taskScheduler.poolSize=10  // (4)
spring.integration.messagingTemplate.throwExceptionOnLateReply=false  // (5)
spring.integration.readOnly.headers=   // (6)
spring.integration.endpoints.noAutoStartup=  // (7)
spring.integration.channels.error.requireSubscribers=true   // (8)
spring.integration.channels.error.ignoreFailures=true  // (9)
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> true일 땐 애플리케이션 컨텍스트에 정의된 게 없다면 `input-channel` 인스턴스는 자동으로 `DirectChannel` 인스턴스로 선언된다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> `DirectChannel` 등에서 허용할 디폴트 구독자 수를 설정한다. 의도치 않게 여러 엔드포인트에서 같은 채널을 구독하는 것을 방지할 수 있다. 개별 채널에선 `max-subscribers` 속성으로 재정의할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 이 프로퍼티는 `PublishSubscribeChannel` 등에 허용할 디폴트 구독자 수를 설정한다. 의도한 것 보다 더 많은 엔드포인트에서 같은 채널을 구독하는 것을 방지할 수 있다. 개별 채널에선 `max-subscribers` 속성을 설정으로 재정의할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> 디폴트 `taskScheduler` 빈에서 사용할 수 있는 스레드 수. [태스크 스케줄러 설정하기](#f2-configuring-the-task-scheduler)를 참고해라.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> `true`일 땐, 전송 스레드에서 타임아웃이 발생했거나 이미 응답을 수신한 다음에 게이트웨이 응답 채널에 메시지가 도착하면 예외를 던진다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(6)</span> `Message` 인스턴스를 복사할 때 함께 복사하면 안 되는 메시지 헤더의 이름들로, 콤마로 구분한다. 이 목록은 `DefaultMessageBuilderFactory` 빈에서 사용하며, `MessageBuilder`([헬퍼 클래스 `MessageBuilder`](../message/#74-the-messagebuilder-helper-class) 참고)를 통해 메시지를 빌드할 때 사용하는 `IntegrationMessageHeaderAccessor` 인스턴스([`MessageHeaderAccessor` API](../message/#721-messageheaderaccessor-api) 참고)로 전파된다. 기본적으로는 `MessageHeaders.ID`와 `MessageHeaders.TIMESTAMP`만 복사하지 않는다. 4.3.2부터 지원한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(7)</span> 애플리케이션을 기동할 때 자동으로 시작해선 안 되는 `AbstractEndpoint` 빈 이름의 패턴들로 (ex. `xxx*`, `*xxx*`, `*xxx`, `xxx*yyy`), 콤마로 구분한다. 이런 엔드포인트들은 이후 원할 때 `Control Bus`를 통한 빈 이름이나 ([컨트롤 버스](../system-management/#135-control-bus) 참고), `SmartLifecycleRoleController`의 role ([엔드포인트 Role](../messaging-endpoints/#102-endpoint-roles) 참고), 또는 `Lifecycle` 빈 주입을 통해 수동으로 시작할 수 있다. 이 글로벌 프로퍼티는 XML 속성 `auto-startup`이나 어노테이션 속성 `autoStartup`을 지정하거나, 빈을 정의하면서 `AbstractEndpoint.setAutoStartup()`을 호출하면 재정의할 수 있다. 4.3.12부터 지원한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(8)</span> 디폴트 글로벌 `errorChannel`을 반드시 `requireSubscribers` 옵션으로 설정해야 한다는 것을 나타내는 boolean 플래그. 5.4.3부터 지원한다. 자세한 내용은 [에러 핸들링](../error-handling)을 참고해라.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(9)</span> 디폴트 글로벌 `errorChannel`이 디스패치 에러를 무시하고 다음 핸들러로 메시지를 전달해야 한다는 걸 나타내는 boolean 플래그. 5.5부터 지원한다.</small>

이 프로퍼티들은 클래스패스에 `/META-INF/spring.integration.properties` 파일을 추가하거나, `org.springframework.integration.context.IntegrationProperties` 인스턴스를`IntegrationContextUtils.INTEGRATION_GLOBAL_PROPERTIES_BEAN_NAME`이란 이름으로 빈에 등록하면 재정의할 수 있다. 모든 프로퍼티를 다 제공할 필요는 없고, 재정의하고 싶은 것들만 제공하면 된다.

5.1 버전부터 `org.springframework.integration` 카테고리의 로그 레벨을 `DEBUG`로 설정해놓으면, 모든 글로벌 프로퍼티들을 병합한 후 애플리케이션 컨텍스트가 시작되면 로그에 출력한다. 예를 들면 다음과 같은 로그를 확인할 수 있다:

```java
Spring Integration global properties:

spring.integration.endpoints.noAutoStartup=fooService*
spring.integration.taskScheduler.poolSize=20
spring.integration.channels.maxUnicastSubscribers=0x7fffffff
spring.integration.channels.autoCreate=true
spring.integration.channels.maxBroadcastSubscribers=0x7fffffff
spring.integration.readOnly.headers=
spring.integration.messagingTemplate.throwExceptionOnLateReply=true
```

---

## F.4. Annotation Support

메시지 엔드포인트를 설정할 땐 XML 네임스페이스 외에도 어노테이션을 사용할 수 있다. 가장 먼저, Spring Integration은 클래스 수준의 스테레오타입 어노테이션 `@MessageEndpoint`를 제공한다. 이 어노테이션 위에는 스프링의 `@Component` 어노테이션이 선언되어 있기 때문에, 스프링의 컴포넌트 스캔에 의해 자동으로 빈 정의로 인식된다.

그보다 더 중요한 것은 메소드 수준의 다양한 어노테이션들이다. 이런 어노테이션이 선언된 메소드는 메시지를 처리할 수 있다는 뜻이다. 다음은 클래스 수준 어노테이션과 메소드 수준 어노테이션을 함께 사용하는 예제다:

```java
@MessageEndpoint
public class FooService {

    @ServiceActivator
    public void processMessage(Message message) {
        ...
    }
}
```

메소드가 메시지를 "처리"한다는 것이 정확히 의미하는 바는 사용한 어노테이션에 따라 다르다. Spring Integration에선 다음과 같은 어노테이션들을 사용할 수 있다:

- `@Aggregator` ([Aggregator](../messaging-routing/#84-aggregator) 참고)
- `@Filter` ([Filter](../messaging-routing/#82-filter) 참고)
- `@Router` ([Routers](../messaging-routing/#81-routers) 참고)
- `@ServiceActivator` ([Service Activator](../messaging-endpoints/#105-service-activator) 참고)
- `@Splitter` ([Splitter](../messaging-routing/#83-splitter) 참고)
- `@Transformer` ([Transformer](../messaging-transformation/#91-transformer) 참고)
- `@InboundChannelAdapter` ([Channel Adapter](../messaging-channels/#63-channel-adapter) 참고)
- `@BridgeFrom` ([자바 코드로 Bridge 설정하기](../messaging-channels/#642-configuring-a-bridge-with-java-configuration) 참고)
- `@BridgeTo` ([자바 코드로 Bridge 설정하기](../messaging-channels/#642-configuring-a-bridge-with-java-configuration) 참고)
- `@MessagingGateway` ([Messaging Gateways](../messaging-endpoints/#104-messaging-gateways) 참고)
- `@IntegrationComponentScan` ([설정과 `@EnableIntegration`](../overview/#55-configuration-and-enableintegration) 참고)

> 어노테이션을 XML 설정과 함께 사용할 때는 `@MessageEndpoint` 어노테이션이 필요하지 않다. POJO를 `<service-activator/>` 요소의 `ref` 속성에서 참조하려는 경우엔, 메소드 수준 어노테이션만 제공해도 된다. `<service-activator/>` 요소에 메소드 수준 속성이 없으면 설정이 불분명해질 수 있는데, 어노테이션을 사용하면 해결된다.

어노테이션을 선언한 핸들러 메소드는 웬만하면 `Message` 타입 파라미터를 직접 받지 않는 게 좋다. 그보단, 다음과 같이 메시지의 페이로드 타입과 일치하는 파라미터 타입을 받을 수 있다:

```java
public class ThingService {

    @ServiceActivator
    public void bar(Thing thing) {
        ...
    }

}
```

메소드 파라미터의 값을 `MessageHeaders`에서 가져와야 할 때는 파라미터에 `@Header` 어노테이션을 사용하는 방법이 있다. 일반적으로 Spring Integration 어노테이션을 선언한 메소드들은 `Message` 자체 뿐 아니라, 메시지 페이로드나 헤더 값(`@Header`로)을 파라미터로 받을 수 있다. 실제로, 다음과 같은 조합으로도 파라미터를 받을 수 있다:

```java
public class ThingService {

    @ServiceActivator
    public void otherThing(String payload, @Header("x") int valueX, @Header("y") int valueY) {
        ...
    }

}
```

다음과 같이 `@Headers` 어노테이션을 이용해 모든 메시지 헤더를 `Map`으로 제공할 수도 있다:

```java
public class ThingService {

    @ServiceActivator
    public void otherThing(String payload, @Headers Map<String, Object> headerMap) {
        ...
    }

}
```

>  `@Header`의 value에는 `someHeader.toUpperCase()`와 같은 SpEL 표현식도 사용할 수 있다. 헤더 값을 주입하기 전에 어떤 조작이 필요한 경우에 사용하면 된다. 또한 헤더 안에 이 속성 값이 반드시 존재해야 하는지를 지정할 수 있는 `required` 프로퍼티를 제공한다. `required` 프로퍼티는 생략할 수 있으며, `true`가 디폴트다.

이런 어노테이션들 중 일부에선, 메시지 처리 메소드가 null이 아닌 값을 반환하면 엔드포인트가 응답 전송을 시도하기도 한다. 엔드포인트의 출력 채널을 사용하고 (있으면) 그 외는 `REPLY_CHANNEL` 메시지 헤더 값으로 폴백한다는 점은 네임스페이스와 어노테이션 설정 모두 동일하다.

> 엔드포인트의 출력 채널과 메시지 헤더 reply channel을 함께 쓰면 파이프라인 방식을 구현할 수 있다. 파이프라인 방식에선 여러 구성 요소가 출력 채널을 가지고, 최종 구성 요소만 응답 채널로 (본래 요청 메시지에 지정해둔) 응답 메시지를 전달할 수 있다. 다른 말로 하면, 최종 구성 요소는 원래 sender가 제공한 정보에 따라 다르게 동작하며, 결과적으로 클라이언트를 원하는 만큼 동적으로 지원할 수 있다. 이는 일종의 [return address](https://www.enterpriseintegrationpatterns.com/ReturnAddress.html) 패턴이다.

여기에서 보여준 예제 말고도, 이런 어노테이션들은 아래 보이는 `inputChannel`, `outputChannel` 프로퍼티도 지원하고 있다:

```java
@Service
public class ThingService {

    @ServiceActivator(inputChannel="input", outputChannel="output")
    public void otherThing(String payload, @Headers Map<String, Object> headerMap) {
        ...
    }

}
```

이런 어노테이션들을 처리할 때도 상응하는 XML 구성 요소와 동일한 빈이 생성된다 — `AbstractEndpoint` 인스턴스와 `MessageHandler` 인스턴스 (또는 인바운드 채널 어댑터의 경우 `MessageSource` 인스턴스). [`@Bean` 메소드 위의 어노테이션들](#f51-annotations-on-bean-methods)을 참고해라. 빈 이름은 `[componentName].[methodName].[decapitalizedAnnotationClassShortName]` 패턴에 따라 만들어진다. 위 예제에선 `AbstractEndpoint`의 빈 이름은 `thingService.otherThing.serviceActivator`이고, `MessageHandler`(`MessageSource`) 빈의 경우 같은 이름에 `.handler`(`.source`) suffix가 붙는다. 이 이름은 메시시 처리 어노테이션과 `@EndpointId` 어노테이션을 함께 사용해서 커스텀할 수 있다. 이 `MessageHandler` 인스턴스(`MessageSource` 인스턴스) 역시 [메시지 히스토리](../system-management/#132-message-history)로 추적할 수 있다.

4.0 버전부터 모든 메시지 처리 어노테이션들은 `SmartLifecycle` 옵션을 제공해서 (`autoStartup` 및 `phase`), 애플리케이션 컨텍스트를 초기화하면서 엔드포인트의 수명 주기 제어할 수 있다. 기본값은 각각 `true`와 `0`이다. 엔드포인트의 상태를 변경하려면 (`start()`, `stop()` 등) `BeanFactory`를 사용해 (또는 자동 주입을 이용해서) 엔드포인트 빈의 참조를 얻어와 메소드를 호출하면 된다. 아니면 `Control Bus`에 커맨드 메시지를 전송해도 된다 ([컨트롤 버스](../system-management/#135-control-bus) 참조). 이때는 바로 윗 단락에서 설명했던 `beanName`을 사용해야 한다.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>여기서 언급한 어노테이션들을 파싱하고 나면 자동으로 생성되는 채널들과 (채널로 사용할 빈을 직접 설정하지 않은 경우) 관련 컨슈머 엔드포인트들은 컨텍스트 초기화가 끝나갈 때쯤 빈으로 등록된다. 이 빈들도 다른 서비스에 <strong>자동 주입할 수 있지만</strong>, 일반 자동 주입 처리 중에는 보통 빈이 정의돼있지 않기 때문에 반드시 <code class="highlighter-rouge">@Lazy</code> 어노테이션으로 마킹해줘야 한다.</p>
  <div class="language-java highlighter-rouge"><div class="highlight"><pre class="highlight"><code><span class="nd">@Autowired</span>
<span class="nd">@Lazy</span>
<span class="nd">@Qualifier</span><span class="o">(</span><span class="s">"someChannel"</span><span class="o">)</span>
<span class="nc">MessageChannel</span> <span class="n">someChannel</span><span class="o">;</span>
<span class="o">...</span>

<span class="nd">@Bean</span>
<span class="nc">Thing1</span> <span class="nf">dependsOnSPCA</span><span class="o">(</span><span class="nd">@Qualifier</span><span class="o">(</span><span class="s">"someInboundAdapter"</span><span class="o">)</span> <span class="nd">@Lazy</span> <span class="nc">SourcePollingChannelAdapter</span> <span class="n">someInboundAdapter</span><span class="o">)</span> <span class="o">{</span>
<span class="o">...</span>
<span class="o">}</span>
</code></pre></div>  </div>
</blockquote>

### F.4.1. Using the `@Poller` Annotation

Spring Integration 4.0 이전에는 메시징 어노테이션의 `inputChannel`에선 `SubscribableChannel`을 참조해야만 했었다. `PollableChannel` 인스턴스의 경우, `<int:poller/>`를 설정하고 복합<sup>composite</sup> 엔드포인트를 `PollingConsumer`로 만들려면 `<int:bridge/>` 요소가 필요했다. 4.0 버전에선 다음과 같이 메시지 처리 어노테이션에서 직접 `poller` 속성을 설정할 수 있도록 `@Poller` 어노테이션을 도입했다:

```java
public class AnnotationService {

    @Transformer(inputChannel = "input", outputChannel = "output",
        poller = @Poller(maxMessagesPerPoll = "${poller.maxMessagesPerPoll}", fixedDelay = "${poller.fixedDelay}"))
    public String handle(String payload) {
        ...
    }
}
```

`@Poller` 어노테이션은 단순히 `PollerMetadata` 옵션만 제공한다. `@Poller` 어노테이션의 속성들은  프로퍼티 플레이스홀더를 통해 설정할 수 있다 (`maxMessagesPerPoll`, `fixedDelay`, `fixedRate`, `cron`). 또한 5.1 버전부터 `PollingConsumer`를 위한 `receiveTimeout` 옵션도 제공한다. 다른 폴링 옵션들도 제공해야 하는 경우 (ex.`transaction`, `advice-chain`, `error-handler` 등), `PollerMetadata`를 일반 빈으로 설정하고 `@Poller`의 `value` 속성에 해당 빈의 이름을 사용하는 것이 좋다. 이 경우 다른 속성은 허용하지 않는다 (전부 `PollerMetadata` 빈에 지정해야 한다). `inputChannel`이 `PollableChannel`인데 `@Poller`를 설정하지 않았다면 디폴트 `PollerMetadata`를 사용한다 (애플리케이션 컨텍스트에 있다면). `@Configuration` 어노테이션을 사용해 디폴트 폴러를 선언하려면 다음과 유사한 코드를 사용하면 된다:

```java
@Bean(name = PollerMetadata.DEFAULT_POLLER)
public PollerMetadata defaultPoller() {
    PollerMetadata pollerMetadata = new PollerMetadata();
    pollerMetadata.setTrigger(new PeriodicTrigger(10));
    return pollerMetadata;
}
```

아래 코드에선 디폴트 폴러를 사용하게 된다:

```java
public class AnnotationService {

    @Transformer(inputChannel = "aPollableChannel", outputChannel = "output")
    public String handle(String payload) {
        ...
    }
}
```

아래 에제에선 폴러의 이름을 지정해서 사용하는 법을 알 수 있다:

```java
@Bean
public PollerMetadata myPoller() {
    PollerMetadata pollerMetadata = new PollerMetadata();
    pollerMetadata.setTrigger(new PeriodicTrigger(1000));
    return pollerMetadata;
}
```

다음은 이 디폴트 폴러를 사용하는 엔드포인트 예시다:

```java
public class AnnotationService {

    @Transformer(inputChannel = "aPollableChannel", outputChannel = "output"
                           poller = @Poller("myPoller"))
    public String handle(String payload) {
         ...
    }
}
```

4.3.3 버전부터 `@Poller` 어노테이션엔 `errorChannel` 속성이 있어서, 내부 `MessagePublishingErrorHandler`를 보다 쉽게 설정할 수 있다. 이 속성은 XML 구성 요소 `<poller>`의 `error-channel`과 동일한 역할을 한다. 자세한 내용은 [엔드포인트 네임스페이스 지원](../messaging-endpoints/#1014-endpoint-namespace-support)을 참고해라.

메시지 처리 어노테이션의 `poller()` 속성은 `reactive()` 속성과는 함께 사용할 수 없다. 자세한 내용은 다음 섹션을 참고해라.

### F.4.2. Using `@Reactive` Annotation

`ReactiveStreamsConsumer`는 5.0부터 있었지만 엔드포인트의 입력 채널이 `FluxMessageChannel`(또는 다른 `org.reactivestreams.Publisher` 구현체들)일 때만 적용됐다. 5.3 버전부터는 입력 채널의 타입과는 상관 없이 타겟 메시지 핸들러가 `ReactiveMessageHandler`일 때도 프레임워크에서 `ReactiveStreamsConsumer`를 생성한다. 5.5부터는, 모든 메시지 처리 어노테이션에 서브 어노테이션 `@Reactive`를 도입했다 (위에서 언급한 `@Poller`와 유사하다). 이 어노테이션은 `Function<? super Flux<Message<?>>, ? extends Publisher<Message<?>>>`의 빈 참조를 받으며, 생략할 수 있다. 입력 채널이나 메시지 핸들러의 타입과는 독립적으로 타겟 엔드포인트를 `ReactiveStreamsConsumer` 인스턴스로 전환해준다. 함수를 지정하면 `Flux.transform()` 연산자에서 이 함수를 사용해서, 입력 채널의 리액티브 스트림 소스를 커스텀할 수 있다  (`publishOn()`, `doOnNext()`, `log()`, `retry()` 등).

다음은 `DirectChannel`의 최종 subscriber, producer와는 관계 없이 입력 채널에서 publishing 스레드를 변경하는 예시다:

```java
@Bean
public Function<Flux<?>, Flux<?>> publishOnCustomizer() {
    return flux -> flux.publishOn(Schedulers.parallel());
}

@ServiceActivator(inputChannel = "directChannel", reactive = @Reactive("publishOnCustomizer"))
public void handleReactive(String payload) {
    ...
}
```

메시지 처리 어노테이션에선 `reactive()` 속성과 `poller()` 속성을 함께 사용할 수 없다. 자세한 내용은 [`@Poller` 어노테이션 사용하기](#f41-using-the-poller-annotation)와 [리액티브 스트림즈 지원](../reactive-streams)을 참고해라.

### F.4.3. Using the `@InboundChannelAdapter` Annotation

4.0 버전에선 메소드 수준 어노테이션 `@InboundChannelAdapter`를 도입했다. 메소드에 이 어노테이션을 선언하면, `MethodInvokingMessageSource`를 기반으로 통합 구성 요소 `SourcePollingChannelAdapter`를 생성한다. 이 어노테이션은 XML 구성 요소 `<int:inbound-channel-adapter>`와 대등하며, 제약 사항 역시 동일하다: 메소드는 파라미터를 가질 수 없으며, 반환 타입이 `void`여선 안 된다. 이 어노테이션은 두 가지 속성을 가진다. 먼저, `value`는 `MessageChannel` 빈의 이름으로, 필수 속성이다. `poller`는 [앞에서 설명한](#f41-using-the-poller-annotation) `@Poller` 어노테이션으로, 생략할 수 있다. 제공해야 하는 `MessageHeaders`가 있다면, 반환 타입을 `Message<?>`로 두고 `MessageBuilder`를 이용해 `Message<?>`를 빌드하면 된다. `MessageBuilder`를 사용하면 `MessageHeaders`를 설정할 수 있다. 다음은 `@InboundChannelAdapter` 어노테이션을 사용하는 예시다:

```java
@InboundChannelAdapter("counterChannel")
public Integer count() {
    return this.counter.incrementAndGet();
}

@InboundChannelAdapter(value = "fooChannel", poller = @Poller(fixed-rate = "5000"))
public String foo() {
    return "foo";
}
```

4.3 버전은 가독성을 위해 `value` 어노테이션 속성에 대한 alias, `channel`을 도입했다. 더불어, `SourcePollingChannelAdapter`의 타겟 `MessageChannel` 빈은 초기화 단계에서 바로 리졸브하지 않고, 처음으로 `receive()`를 호출했을 때 `outputChannelName` 옵션으로 설정한 이름을 통해 리졸브한다. 컨슈머 관점에서 바라보면, 타겟 `MessageChannel` 빈은 `@InboundChannelAdapter` 파싱 단계보다 약간 늦게 생성되고 등록되는 "late binding"이라고 볼 수 있다.

첫 번째 예시에선 애플리케이션 컨텍스트 어딘가에 디폴트 폴러가 선언돼있어야 한다.

### F.4.4. Using the `@MessagingGateway` Annotation

[`@MessagingGateway` 어노테이션](../messaging-endpoints/#1046-messaginggateway-annotation)을 확인해봐라.

### F.4.5. Using the `@IntegrationComponentScan` Annotation

표준 스프링 프레임워크 어노테이션 `@ComponentScan`은 스테레오타입 어노테이션 `@Component`를 선언한 인터페이스는 스캔하지 않는다. Spring Integration에선 이 한계를 뛰어넘어 `@MessagingGateway` 설정을 지원할 수 있도록 ([`@MessagingGateway` 어노테이션](../messaging-endpoints/#1046-messaginggateway-annotation) 참고) `@IntegrationComponentScan` 메커니즘을 도입했다. `@IntegrationComponentScan`은 반드시 `@Configuration` 어노테이션과 함께 배치해야 하며, `basePackages`, `basePackageClasses`와 같은 스캔 옵션을 정의해줘야 한다. 이 경우, `@MessagingGateway` 어노테이션이 달린 인터페이스를 발견하면 전부 파싱해서 `GatewayProxyFactoryBean` 인스턴스로 등록한다. 다른 클래스 기반 구성 요소들은 모두 표준 `@ComponentScan`을 통해 파싱한다.

---

## F.5. Messaging Meta-Annotations

4.0 버전부터 모든 메시지 처리 어노테이션은 메타 어노테이션으로 설정할 수 있으며, 사용자가 정의한 모든 메시지 처리 어노테이션은 동일한 속성을 정의하면 기본값을 재정의할 수 있다. 더불어, 메타 어노테이션은 아래 예제와 같이 계층 구조를 구성할 수 있다:

```java
@Target({ElementType.METHOD, ElementType.ANNOTATION_TYPE})
@Retention(RetentionPolicy.RUNTIME)
@ServiceActivator(inputChannel = "annInput", outputChannel = "annOutput")
public @interface MyServiceActivator {

    String[] adviceChain = { "annAdvice" };
}

@Target({ElementType.METHOD, ElementType.ANNOTATION_TYPE})
@Retention(RetentionPolicy.RUNTIME)
@MyServiceActivator
public @interface MyServiceActivator1 {

    String inputChannel();

    String outputChannel();
}
...

@MyServiceActivator1(inputChannel = "inputChannel", outputChannel = "outputChannel")
public Object service(Object payload) {
   ...
}
```

메타 어노테이션으로 계층 구조를 만들면 다양한 속성에 기본값을 설정할 수 있으며, 자바 코드에 보이는 프레임워크 의존성을 사용자 어노테이션으로 격리시켜서 사용자 클래스에서는 프레임워크 의존성을 숨길 수 있다. 프레임워크에서 메소드에 선언한 사용자 어노테이션이 프레임워크 메타 어노테이션을 가지고 있는 것을 발견하면, 마치 메소드 위에 프레임워크 어노테이션을 직접 선언한 것처럼 처리해준다.

### F.5.1. Annotations on `@Bean` Methods

4.0 버전부터 `@Configuration` 클래스 안에 있는 `@Bean` 메소드 정의 위에 메시지 처리 어노테이션을 선언하면, 메소드가 아닌 빈을 기반으로 메시지 엔드포인트를 생성할 수 있다. `@Bean` 어노테이션으로 "바로 사용할 수 있는" `MessageHandler` 인스턴스(`AggregatingMessageHandler`, `DefaultMessageSplitter` 등), `Transformer` 인스턴스(`JsonToObjectTransformer`, `ClaimCheckOutTransformer` 등), `MessageSource` 인스턴스(`FileReadingMessageSource`, `RedisStoreMessageSource` 등)를 정의할 때 유용할 거다. 다음은 `@Bean` 어노테이션과 메시지 처리 어노테이션을 함께 사용하는 방법을 보여주는 예시다:

```java
@Configuration
@EnableIntegration
public class MyFlowConfiguration {

    @Bean
    @InboundChannelAdapter(value = "inputChannel", poller = @Poller(fixedDelay = "1000"))
    public MessageSource<String> consoleSource() {
        return CharacterStreamReadingMessageSource.stdin();
    }

    @Bean
    @Transformer(inputChannel = "inputChannel", outputChannel = "httpChannel")
    public ObjectToMapTransformer toMapTransformer() {
        return new ObjectToMapTransformer();
    }

    @Bean
    @ServiceActivator(inputChannel = "httpChannel")
    public MessageHandler httpHandler() {
    HttpRequestExecutingMessageHandler handler = new HttpRequestExecutingMessageHandler("https://foo/service");
        handler.setExpectedResponseType(String.class);
        handler.setOutputChannelName("outputChannel");
        return handler;
    }

    @Bean
    @ServiceActivator(inputChannel = "outputChannel")
    public LoggingHandler loggingHandler() {
        return new LoggingHandler("info");
    }

}
```

5.0 버전부터는 POJO나 메시지를 생성하는 `java.util.function.Supplier`를 반환하는 `@Bean`에 `@InboundChannelAdapter` 어노테이션을 선언할 수 있다. 다음은 이 조합을 사용하는 예시다:

```java
@Configuration
@EnableIntegration
public class MyFlowConfiguration {

    @Bean
    @InboundChannelAdapter(value = "inputChannel", poller = @Poller(fixedDelay = "1000"))
    public Supplier<String> pojoSupplier() {
        return () -> "foo";
    }

    @Bean
    @InboundChannelAdapter(value = "inputChannel", poller = @Poller(fixedDelay = "1000"))
    public Supplier<Message<String>> messageSupplier() {
        return () -> new GenericMessage<>("foo");
    }
}
```

메타 어노테이션의 규칙은 `@Bean` 메소드에서도 동일하다 ([앞에서 등장했던](#f5-messaging-meta-annotations) `@MyServiceActivator` 어노테이션 역시 `@Bean` 정의 위에 사용할 수 있다).

> 이런 어노테이션들을 컨슈머 `@Bean` 정의 위에 사용할 때, 적당한 `MessageHandler`를 반환하는 (어노테이션 타입에 따라 다르다) 빈을 정의했다면, `outputChannel`, `requiresReply`, `order` 등과 같은 속성들은 반드시 `MessageHandler` `@Bean` 정의 안에 설정해줘야 한다. 어노테이션 속성은 `adviceChain`, `autoStartup`, `inputChannel`, `phase`, `poller`만 사용하게 된다. 다른 속성들은 전부 핸들러를 위한 설정이다.

> 빈의 이름은 다음과 같은 알고리즘으로 생성한다:

- `MessageHandler`(`MessageSource`) `@Bean`은 메소드명이나 `@Bean`의 `name` 속성에서 고유한 표준 이름을 가져온다. 마치 `@Bean` 메소드 위에 메시지 처리 어노테이션이 없는 것처럼 동작한다.
- `AbstractEndpoint` 빈의 이름은 `[configurationComponentName].[methodName].[decapitalizedAnnotationClassShortName]` 패턴으로 만들어진다. 예를 들어, [앞에서 보여준](#f51-annotations-on-bean-methods) `consoleSource()` 정의로 만들어지는 `SourcePollingChannelAdapter` 엔드포인트는 빈 이름으로 `myFlowConfiguration.consoleSource.inboundChannelAdapter`를 가져온다. [엔드포인트 빈 이름](../overview/#548-endpoint-bean-names)도 함께 참고해라.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>이런 어노테이션들을 <code class="highlighter-rouge">@Bean</code> 정의에서 사용할 때는 반드시 <code class="highlighter-rouge">inputChannel</code>로 선언되어있는 빈을 참조해야 한다. 이런 케이스에선 자동으로 채널을 선언해주지 않는다.</p>
</blockquote>

> 자바 설정에서는 `@Bean` 메소드 위에 `@Conditional`(ex. `@Profile`)을 정의하면 원하는 조건에 따라 빈 등록을 건너뛸 수 있다. 다음 예제를 참고해라:
>
> ```java
> @Bean
> @ServiceActivator(inputChannel = "skippedChannel")
> @Profile("thing")
> public MessageHandler skipped() {
>  return System.out::println;
> }
> ```
>
> 여기서는 기존 스프링 컨테이너 로직과 마찬가지로, `@ServiceActivator` 어노테이션 기반의 메시지 처리 엔드포인트 빈도 등록되지 않는다.

### F.5.2. Creating a Bridge with Annotations

4.0 버전부터 자바 설정에선 `@Bean` 메소드 어노테이션 `@BridgeFrom`, `@BridgeTo`를 사용해 `@Configuration` 클래스에 있는 `MessageChannel` 빈을 마킹할 수 있다. 이 어노테이션들을 이용하면 간편하게 `BridgeHandler`와 그 메시지 엔드포인트 설정을 완성할 수 있다:

```java
@Bean
public PollableChannel bridgeFromInput() {
    return new QueueChannel();
}

@Bean
@BridgeFrom(value = "bridgeFromInput", poller = @Poller(fixedDelay = "1000"))
public MessageChannel bridgeFromOutput() {
    return new DirectChannel();
}
@Bean
public QueueChannel bridgeToOutput() {
    return new QueueChannel();
}

@Bean
@BridgeTo("bridgeToOutput")
public MessageChannel bridgeToInput() {
    return new DirectChannel();
}
```

이 어노테이션들 역시 메타 어노테이션으로 활용할 수 있다.

### F.5.3. Advising Annotated Endpoints

[어노테이션을 이용해 엔드포인트에 어드바이스 적용하기](../messaging-endpoints/#1098-advising-endpoints-using-annotations)를 읽어봐라.

---

## F.6. Message Mapping Rules and Conventions

Spring Integration은 기본 규칙들을 사용하면서 몇 가지 전용 컨벤션을 정의해, 별도 설정을 추가하지 않아도 메소드와 메소드 인자에 유연하게 메시지를 매핑할 수 있게 해준다. 이어지는 섹션에선 예시를 통해 이 규칙들을 설명한다.

### F.6.1. Sample Scenarios

다음 예제는 반환 유형이 void가 아니면서, 유일하게 받는 파라미터(object 혹은 primitive)는 어노테이션도 없고 `Map`이나 `Properties` 객체도 아닌 메소드다:

```java
public String doSomething(Object o);
```

이 입력 파라미터로는 메시지 페이로드를 전달받는다. 파라미터 타입이 메시지 페이로드와 호환되지 않는 경우, 스프링 3.0에서 제공하는 변환 서비스를 사용해 변환을 시도한다. 반환 값은 메시지의 페이로드로 통합된다.

다음은 `Message` 타입을 반환하며, 단일 파라미터(object 혹은 primitive)는 어노테이션도 없고 `Map`이나 `Properties`도 아닌 메소드다:

```java
public Message doSomething(Object o);
```

이 입력 파라미터로는 메시지 페이로드를 전달받는다. 파라미터 타입이 메시지 페이로드와 호환되지 않는 경우, 스프링 3.0에서 제공하는 변환 서비스를 사용해 변환을 시도한다. 반환 값으로 만들어지는 새 메시지는 다음 목적지로 전송된다.

다음은 임의의 개체나 primitive 타입을 반환하며, message 타입 (또는 하위 클래스 중 하나) 파라미터를 하나 받는 메소드다:

```java
public int doSomething(Message msg);
```

여기서는 입력 파라미터 자체가 `Message`다. 반환 값은 다음 목적지로 전송하는 `Message`의 페이로드로 사용한다.

다음은 `Message` 타입(또는 하위 클래스 중 하나)을 반환하면서, `Message` 타입 (또는 하위 클래스 중 하나) 파라미터를 하나 받는 메소드다:

```java
public Message doSomething(Message msg);
```

여기서는 입력 파라미터 자체가 `Message`다. 반환 값으로 만들어지는 새 `Message`는 다음 목적지로 전송된다.

다음은 `Message` 타입을 반환하면서, `Map` 또는 `Properties` 타입 파라미터를 하나 받는 메소드다:

```java
public Message doSomething(Map m);
```

이 메소드는 좀 특이하다. 막상 보면 입력 인자를 간단하게 메시지 헤더로 바로 매핑하는 것처럼 보이지만, 우선순위는 항상 `Message` 페이로드가 가진다. 즉, `Message` 페이로드가 `Map` 타입인 경우, 이 입력 인자는 `Message` 페이로드를 나타낸다. 하지만 `Message` 페이로드가 `Map` 타입이 아닌 경우는, 변환 서비스에서 페이로드 변환을 시도하지 않으며, 입력 인자는 메시지 헤더에 매핑된다.

다음은 두 가지 파라미터를 사용하는 메소드다. 그 중 하나는 `Map`이나 `Properties` 객체가 아닌 임의의 타입(object 혹은 primitive)이고, 다른 하나는 `Map` 또는 `Properties` 타입이다 (반환 값과는 관계없다):

```java
public Message doSomething(Map h, <T> t);
```

이 조합에서는 입력 파라미터가 두 개이고, 그 중 하나는 `Map` 타입이다. `Map`이 아닌 파라미터는 (순서에 관계없이) `Message` 페이로드에 매핑되며, `Map` 혹은 `Properties`는 (순서에 관계없이) 메시지 헤더에 매핑된다. 덕분에 POJO를 사용해서 `Messgae` 구조와 상호 작용할 수 있다.

다음은 파라미터를 받지 않는 메소드다 (반환 값은 상관 없이):

```java
public String doSomething();
```

이 메시지 핸들러의 메소드는, 핸들러에 연결돼 있는 입력 채널로 전송된 메시지를 통해 실행된다. 하지만 `Message` 데이터를 매핑하고 있지 않으므로, `Message`는 이 핸들러를 호출하는 이벤트 혹은 트리거 역할을 한다고 말할 수 있다. 출력은 [앞에서 설명한](#f6-message-mapping-rules-and-conventions) 규칙대로 매핑된다.

다음은 파라미터를 받지 않으며, 반환 타입 역시 void인 메소드다:

```java
public void soSomething();
```

이 예제는 출력을 생성하지 않는다는 점만 빼고는 바로 앞의 메소드와 동일하다.

### F.6.2. Annotation-based Mapping

어노테이션을 사용하면 가장 안전하면서도 명확하게 메소드에 메시지를 매핑할 수 있다. 아래 코드에선 헤더를 매핑할 파라미터를 명확하게 명시하고 있다:

```java
public String doSomething(@Payload String s, @Header("someheader") String b)
```

나중에 알게 되겠지만, 어노테이션이 없었다면 이 메소드 시그니처는 정확한 매핑 규칙을 판단하기 어려웠을 거다. 하지만 첫 번째 인자는 `Message` 페이로드에, 두 번째 인자는 메시지 헤더 `someheader` 값에 매핑한다는 것을 분명하게 표현하고 있다.

아래 보이는 메소드도 위 예제와 거의 동일하다:

```java
public String doSomething(@Payload String s, @RequestParam("something") String b)
```

`@RequestMapping`같이 Spring Integration 전용 매핑 어노테이션이 아닌 것들은 관련이 없기 때문에 무시한다. 따라서 두 번째 파라미터는 매핑되지 않은 상태로 남게된다. 두 번째 파라미터는 페이로드에 매핑될 것 같이 보이지만, 페이로드를 받는 파라미터는 하나만 있을 수 있다. 즉, 이 어노테이션들 덕분에 어떤 것이 페이로드인지 분명하게 알 수 있다.

아래 예제도 역시 어노테이션으로 의도를 명확히 하지 않았다면 매핑할 데이터를 식별하기 어려웠을 또 다른 메소드 예시다:

```java
public String foo(String s, @Header("foo") String b)
```

유일한 차이점은, 첫 번째 인자는 암묵적으로 메시지 페이로드에 매핑된다는 점이다.

다음은 인자가 둘 이상이어서, 어노테이션을 사용하지 않으면 의도를 명확히 알기 어려운 또 다른 메소드 시그니처다:

```java
public String soSomething(@Headers Map m, @Header("something") Map f, @Header("someotherthing") String bar)
```

이 예제는 특히, 두 개의 인자가 `Map` 인스턴스이기 때문에 문제가 발생할 수 있다. 하지만 어노테이션을 기반으로 메시지를 매핑하면, 매핑할 데이터를 명확하게 표현할 수 있다. 이 예제에선 첫 번째 인자에는 모든 메시지 헤더를 매핑하고, 두 번째와 세 번째 인자에는 'something'과 'someotherthing'이라는 메시지 헤더 값을 매핑한다. 페이로드는 어떤 인자에도 매핑되지 않는다.

### F.6.3. Complex Scenarios

아래 나오는 예제에선 파라미터를 여러 개 받는다:

파라미터가 여러 개 일 때는 데이터를 어떻게 매핑할지 결정하기가 어려운 경우가 굉장히 많다. 일반적으로는 메소드 파라미터에 `@Payload`, `@Header`, `@Headers` 어노테이션을 추가하는 것을 가이드하고 있다. 이 섹션에선 매핑할 데이터가 명확하지 않아 예외가 발생하는 예제들을 다룬다.

```java
public String doSomething(String s, int i)
```

두 파라미터의 가중치는 동일하다. 그렇기 때문에 어떤 것이 페이로드인지를 결정할 수 없다.

다음은 세 가지 파라미터를 받는, 유사한 문제를 가진 코드다:

```java
public String foo(String s, Map m, String b)
```

Map은 쉽게 메시지 헤더로 매핑시킬 수 있지만, 두 개의 String 파라미터로는 무엇을 할 지 판단하기 어렵다.

아래 있는 코드 역시 매핑할 데이터를 결정할 수 없는 예시다:

```java
public String foo(Map m, Map f)
```

둘 중 하나는 메시지 페이로드에 매핑하고 다른 하나는 메시지 헤더에 매핑하면 되는 거 아니냐고 생각할 수도 있지만, 단순히 순서만으로 매핑할 데이터를 결정할 수는 없다.

> Map이 아닌 메소드 인자가 두 개 이상 있으면서 어노테이션도 사용하지 않았다면, 매핑할 데이터를 결정할 수 없어 예외가 발생한다.

아래 나오는 예제들은 모두 메소드가 여러 개 있어서 매핑 기준이 애매해지는 코드들이다.

메소드를 여러 개 가진 메시지 핸들러라도, 앞에서 예제를 통해 보여준 규칙 그대로 데이터를 매핑한다. 하지만 그럼에도 불구하고 상황에 따라서 매핑 기준이 명확하지 않은 경우가 있다.

아래 있는 메소드 시그니처는, 메소드가 여러 개이지만 문제가 되진 않는다 (기준에 따라 명확하게 데이터를 매핑할 수 있다):

```java
public class Something {
    public String doSomething(String str, Map m);

    public String doSomething(Map m);
}
```

(두 메소드의 이름이 같건 다르건 상관없다.) `Message`는 두 가지 메소드 중 하나에 매핑할 수 있다. 메시지 페이로드는 `str`에, 메시지 헤더는 `m`에 매핑할 수 있을 땐 첫 번째 메소드를 호출한다.  메시지 헤더만 `m`에 매핑할 수 있을 땐 두 번째 메소드도 후보가 될 수 있다. 하필 여기서는 두 메소드의 이름이 동일한데, 따라서 처음엔 아래 설정을 보면 무엇을 호출할지가 불분명하다고 느껴질 수 있다:

```xml
<int:service-activator input-channel="input" output-channel="output" method="doSomething">
    <bean class="org.things.Something"/>
</int:service-activator>
```

하지만, 메시지를 매핑할 땐 가장 먼저 페이로드를 가지고 매핑해보고, 다른 것들은 전부 그 다음으로 시도해보기 때문에 이 설정을 사용해도 제대로 동작한다. 즉, 첫 번째 인자를 페이로드에 매핑할 수 있는 메소드의 우선 순위가 다른 무엇보다도 가장 높다.

이번엔 정말로 기준이 명확하지 않은, 다른 예제를 살펴보자:

```java
public class Something {
    public String doSomething(String str, Map m);

    public String doSomething(String str);
}
```

두 메소드의 시그니처 모두 메시지 페이로드에 매핑할 수 있다. 메소드의 이름마저 동일하다. 핸들러 메소드를 이렇게 정의하면 예외가 발생한다. 하지만 메소드의 이름이 다르다면, `method` 속성을 통해 실행할 메소드를 알려줄 수 있다 (아래 예제 참고). 다음은 메소드의 이름만 서로 다른, 동일한 예제다:

```java
public class Something {
    public String doSomething(String str, Map m);

    public String doSomethingElse(String str);
}
```

다음은 `method` 속성을 사용해 매핑할 메소드를 지정하는 예제다:

```xml
<int:service-activator input-channel="input" output-channel="output" method="doSomethingElse">
    <bean class="org.bar.Foo"/>
</int:service-activator>
```

이 설정에선 `doSomethingElse` 메소드를 명시했기 때문에, 무엇을 매핑할지 분명히 알 수 있다.