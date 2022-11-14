---
title: Appendix C. Message Publishing
category: Spring Integration
order: 28
permalink: /Spring%20Integration/message-publishing/
description: 동기/비동기로 메시지를 발행하는 방법과, 주기적으로 메시지 발행을 스케줄링하는 방법
image: ./../../images/springintegration/logo.png
lastmod: 2022-11-14T22:00:00+09:00
comments: true
originalRefName: 스프링 인티그레이션
originalRefLink: https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/index-single.html#message-publishing
parent: Appendices
parentUrl: /Spring%20Integration/appendices/
---

---

AOP<sup>Aspect-oriented Programming</sup>를 이용해 메시지 발행하면 메소드 호출에 따른 부산물로 메시지를 구성하고 전송할 수 있다. 예를 들어 어떤 구성 요소의 상태가 변경될 때마다 메시지를 통해 통보받고 싶다고 생각해보자. 뭔가를 통보하는 가장 쉬운 방법은 전용 채널에 메시지를 전송하는 것인데, 객체의 상태를 변경하는 메소드가 실행되면 어떻게 메시지 전송 프로세스에 연결할 수 있을까? 또, 통보용 메시지는 어떻게 구성해야 할까? 이런 것들은 AOP를 통해 메시지를 발행하면 알아서 처리해주며, 설정을 통해 변경할 수도 있다.

### 목차

- [C.1. Message Publishing Configuration](#c1-message-publishing-configuration)
  + [C.1.1. Annotation-driven Configuration with the @Publisher Annotation](#c11-annotation-driven-configuration-with-the-publisher-annotation)
  + [C.1.2. XML-based Approach with the \<publishing-interceptor\> element](#c12-xml-based-approach-with-the-publishing-interceptor-element)
    * [Asynchronous Publishing](#asynchronous-publishing)
  + [C.1.3. Producing and Publishing Messages Based on a Scheduled Trigger](#c13-producing-and-publishing-messages-based-on-a-scheduled-trigger)

---

## C.1. Message Publishing Configuration

Spring Integration은 XML 설정과 어노테이션 기반(Java) 설정을 제공한다.

### C.1.1. Annotation-driven Configuration with the `@Publisher` Annotation

어노테이션을 이용해 설정할 때는 원하는 메소드에 `@Publisher` 어노테이션을 달아 'channel' 속성을 지정해주면 된다. 5.1 버전부터는 이 기능을 사용하려면 `@Configuration` 클래스 위에 반드시 `@EnablePublisher` 어노테이션을 선언해야 한다. 자세한 내용은 [설정과 `@EnableIntegration`](../overview/#55-configuration-and-enableintegration)을 참고해라. 메소드가 반환 값으로 메시지를 구성하며, 'channel' 속성에 명시한 채널로 메시지를 전송한다. 메시지 구조를 좀 더 수정하고 싶다면 `@Payload`와 `@Header` 어노테이션을 조합해서 사용할 수도 있다.

Spring Integration에서 내부적으로 메시지를 게시할 땐 `PublisherAnnotationAdvisor` 정의를 통한 Spring AOP와 SpEL<sup>Spring Expression Language</sup>을 모두 사용하므로, 게시할 `Message`의 구조를 여러 가지 방법으로 조정할 수 있다.

`PublisherAnnotationAdvisor`는 다음과 같은 변수들을 정의하고 바인딩한다:

- `#return`: 반환 값에 바인딩되서, 반환 값이나 반환 값에 있는 속성을 참조할 수 있다 (ex. `#return`에 바인딩된 객체의 속성이 'something'이라면, `#return.something`).
- `#exception`: 메소드 실행 중 던져진 예외가 있다면 예외에 바인딩된다
- `#args`: 메소드 인자에 바인딩되서, 이름을 통해 개별 인자를 추출할 수 있다 (ex. `#args.fname`).

아래 예제를 한 번 살펴보자:

```java
@Publisher
public String defaultPayload(String fname, String lname) {
  return fname + " " + lname;
}
```

위 예제에선 다음과 같은 구조로 메시지를 구성한다:

- 메소드의 반환 타입과 값 그대로 메시지 페이로드를 구성한다. 기본 동작이다.
- 새로 생성한 메시지는 어노테이션 post processor(뒤에서 다룬다)로 설정한 디폴트 publisher 채널로 전송된다.

아래 예제는 디폴트 채널에 개시하지 않는다는 점을 제외하면 앞의 예제와 동일하다:

```java
@Publisher(channel="testChannel")
public String defaultPayload(String fname, @Header("last") String lname) {
  return fname + " " + lname;
}
```

여기서는 디폴트 publisher 채널을 사용하는 대신, `@Publisher` 어노테이션의 'channel' 속성을 통해 메시지를 게시할 채널을 지정하고 있다. 또한 `@Header` 어노테이션을 추가해서, 메소드 파라미터 'lname'과 동일한 값을 갖는 'last'라는 메시지 헤더를 생성한다. 이 헤더는 새로 만드는 메시지에 추가된다.

아래 코드도 앞의 예제와 거의 동일하다:

```java
@Publisher(channel="testChannel")
@Payload
public String defaultPayloadButExplicitAnnotation(String fname, @Header String lname) {
  return fname + " " + lname;
}
```

유일한 차이점은 메소드 위에 `@Payload` 어노테이션을 사용해서, 이 메소드의 반환 값을 메시지의 페이로드로 사용해야 함을 명시적으로 나타냈다는 점이다.

다음은 `@Payload` 어노테이션에 SpEL<sup>Spring Expression Language</sup>을 사용해서, 메시지를 구성하는 방법을 구체적으로 지시하도록 이전 설정을 확장한 코드다:

```java
@Publisher(channel="testChannel")
@Payload("#return + #args.lname")
public String setName(String fname, String lname, @Header("x") int num) {
  return fname + " " + lname;
}
```

위 예제에선 메소드가 반환한 값과 입력 인자 'lname'을 연결한 값을 메시지로 사용한다. 'x'라는 메시지 헤더 값은 입력 인자 'num'으로 결정된다. 이 헤더는 새로 만드는 메시지에 추가된다.

```java
@Publisher(channel="testChannel")
public String argumentAsPayload(@Payload String fname, @Header String lname) {
  return fname + " " + lname;
}
```

위 예제에선 `@Payload` 어노테이션의 또 다른 사용법을 볼 수 있다. 여기서는 메소드 인자에 어노테이션을 선언해서, 이 인자가 새로 만드는 메시지의 페이로드가 된다.

스프링에 있는 다른 어노테이션 기반 기능들이 대부분 그렇듯, post-processor(`PublisherAnnotationBeanPostProcessor`)를 하나 등록해줘야 한다. 그 방법은 아래를 참고해라:

```xml
<bean class="org.springframework.integration.aop.PublisherAnnotationBeanPostProcessor"/>
```

다음과 같이 네임스페이스를 이용하면 좀 더 간단하게 설정을 추가할 수 있다:

```xml
<int:annotation-config>
    <int:enable-publisher default-publisher-channel="defaultChannel"/>
</int:annotation-config>
```

자바 설정에선 다음과 같이 `@EnablePublisher` 어노테이션을 사용해야 한다:

```java
@Configuration
@EnableIntegration
@EnablePublisher("defaultChannel")
public class IntegrationConfiguration {
    ...
}
```

5.1.3 버전부터 `<int:enable-publisher>` 구성 요소와 `@EnablePublisher` 어노테이션은 `ProxyFactory` 설정을 조정할 수 있는 `proxy-target-class`, `order` 속성을 가지고 있다.

다른 스프링 어노테이션들과 마찬가지로 (`@Component`, `@Scheduled` 등), `@Publisher`는 메타 어노테이션으로도 사용할 수 있다. 즉, `@Publisher`와 동일하게 처리되는 자체 어노테이션을 정의할 수 있다는 뜻이다. 그 방법은 아래를 참고해라:

```java
@Target({ElementType.METHOD, ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Publisher(channel="auditChannel")
public @interface Audit {
...
}
```

위에서 정의한 `@Audit` 어노테이션에는 자체적으로 `@Publisher`가 선언되어 있다. 참고로, 메타 어노테이션에 `channel` 속성을 정의하면, 메시지를 전송할 위치를 이 어노테이션 안에 캡슐화할 수 있다. 이제 다음과 같이 원하는 메소드에 `@Audit` 어노테이션을 선언할 수 있다:

```java
@Audit
public String test() {
    return "Hello";
}
```

위 예제에선 `test()` 메소드를 호출할 때마다 반환 값을 페이로드로 가지는 메시지가 만들어진다. 각 메시지는 `auditChannel`이란 채널로 전송된다. 이 테크닉을 이용하면 여러 어노테이션에 같은 채널 이름을 반복하지 않아도 된다. 또한 도메인에 국한될 가능성이 높은 자체 어노테이션과 프레임워크에서 제공하는 어노테이션 사이에 중간 완충제를 두는 효과도 누릴 수 있다.

다음과 같이 이 어노테이션을 클래스에 선언하면, 그 클래스에 있는 모든 public 메소드에 어노테이션의 프로퍼티를 적용할 수 있다:

```java
@Audit
static class BankingOperationsImpl implements BankingOperations {

  public String debit(String amount) {
     . . .

  }

  public String credit(String amount) {
     . . .
  }

}
```

### C.1.2. XML-based Approach with the `<publishing-interceptor>` element

XML 설정에서는 네임스페이스를 이용해 `MessagePublishingInterceptor`를 구성해서, 동일하게 AOP 기반으로 메시지를 게시할 수 있다. 어노테이션 방식보다 확실히 좋은 점이 몇 가지 있는데, AOP 포인트컷 표현식을 사용할 수 있어서, 한 번에 여러 메소드를 가로채거나 소스 코드가 없는 메소드를 가로채고 게시할 수 있다.

XML 설정을 이용해 메시지를 게시하려면, 아래 있는 두 가지만 추가해주면 된다:

- XML 요소 `<publishing-interceptor>`를 사용해서 `MessagePublishingInterceptor`를 위한 설정을 제공한다.
- 관리 중인 객체에 `MessagePublishingInterceptor`를 적용하기 위한 AOP 설정을 제공한다.

다음은 `publishing-interceptor` 요소를 설정하는 예시다:

```xml
<aop:config>
  <aop:advisor advice-ref="interceptor" pointcut="bean(testBean)" />
</aop:config>
<publishing-interceptor id="interceptor" default-channel="defaultChannel">
  <method pattern="echo" payload="'Echoing: ' + #return" channel="echoChannel">
    <header name="things" value="something"/>
  </method>
  <method pattern="repl*" payload="'Echoing: ' + #return" channel="echoChannel">
    <header name="things" expression="'something'.toUpperCase()"/>
  </method>
  <method pattern="echoDef*" payload="#return"/>
</publishing-interceptor>
```

`<publishing-interceptor>` 설정은 어노테이션 설정 방식과 다소 비슷해 보이는데, SpEL<sup>Spring Expression Language</sup>도 활용할 수 있다.

위 예제에선 `testBean`의 `echo` 메소드를 실행하면 다음과 같은 구조의 `Message`가 만들어진다:

- `Message` 페이로드는 `Echoing: [value]`를 담고있는 `String` 타입이다. 여기서 `value`는 실행한 메소드가 반환한 값이다.
- 이 `Message`는 `things`라는 헤더에 `something`이라는 값을 가지고 있다.
- 이 `Message`는 `echoChannel`로 전송된다.

두 번째 method는 첫 번째 method와 매우 유사하다. 여기에서는 'repl'로 시작하는 모든 메소드가 다음과 같은 구조로 `Message`를 생성한다:

- `Message` 페이로드는 이전 샘플과 동일하다.
- 이 `Message`는 `things`라는 헤더에 SpEL 표현식 `something'.toUpperCase()`의 결과 값을 가지고 있다.
- 이 `Message`는 `echoChannel`로 전송된다.

`echoDef`로 시작하는 모든 메소드가 실행되면 매핑되는 세 번째 method는 다음과 같은 구조의 `Message`를 생성한다:

- `Message` 페이로드는 실행한 메소드가 반환한 값이다.
- `channel` 속성을 제공하지 않기 때문에, 이 `Message`는 `publisher`가 정의하는 `defaultChannel`로 전송된다.

간단한 매핑 규칙이라면 다음과 같이 `publisher`의 기본값들을 사용해도 된다:

```xml
<publishing-interceptor id="anotherInterceptor"/>
```

위 예제는 pointcut 표현식과 매칭되는 모든 메소드의 반환 값을 페이로드에 매핑하고, `default-channel`로 전송한다. `defaultChannel`을 지정하지 않았다면 (위 예제에서처럼) 글로벌 `nullChannel`로 메시지를 전달한다 (`/dev/null`과 같은 개념이라고 보면 된다).

#### Asynchronous Publishing

메시지를 게시할 땐 구성 요소를 실행한 스레드와 같은 스레드에서 게시한다. 따라서 동기식 전송이 디폴트라고 할 수 있다. publisher의 플로우가 완료될 때까지 메시지 플로우 전체가 기다려야 한다는 뜻이기도 하다. 하지만 완전히 반대의 상황이 필요할 때도 있다. 즉, 메시지를 게시함으로써 비동기 플로우를 시작해야 할 수도 있다. 예를 들어서, 원격 요청을 수신하는 서비스를 호스팅한다고 해보자 (HTTP, WS 등). 내부에서 이 요청을 받으면 시간이 꽤 걸릴 수 있는 프로세스로 요청을 보내야 수도 있다. 하지만 사용자에게는 즉시 응답을 보내기를 바랄 수도 있다. 따라서, 평소대로 인바운드 요청을 처리하기 위해 출력 채널로 전송하는 대신, message-publisher 기능을 통해 복잡한 플로우를 시작하는 동시에 'output-channel'이나 'replyChannel' 헤더를 사용해 caller에게 간단한 승인<sup>acknowledgment</sup>같은 응답을 보낼 수 있다.

아래 있는 서비스는 복잡한 페이로드를 수신하지만 (다른 곳에 또 보내서 처리를 이어가야 한다), caller에겐 간단한 승인<sup>acknowledgment</sup>을 보내줘야 한다:

```java
public String echo(Object complexPayload) {
     return "ACK";
}
```

따라서 출력 채널로 복잡한 플로우를 연결하는 대신 message-publishing 기능을 사용한다. 메시지를 생성할 땐 서비스 메소드의 입력 인자를 사용하도록 설정하고 (이전 예제 참고), 생성한 메시지는 'localProcessChannel'로 전송할 거다. 이 플로우를 비동기로 만들고 싶다면 원하는 비동기 채널에 전송해주기만 하면 된다 (아래 예제에선 `ExecutorChannel`). 다음은 비동기 `publishing-interceptor`를 사용하는 예시다:

```xml
<int:service-activator  input-channel="inputChannel" output-channel="outputChannel" ref="sampleservice"/>

<bean id="sampleservice" class="test.SampleService"/>

<aop:config>
  <aop:advisor advice-ref="interceptor" pointcut="bean(sampleservice)" />
</aop:config>

<int:publishing-interceptor id="interceptor" >
  <int:method pattern="echo" payload="#args[0]" channel="localProcessChannel">
    <int:header name="sample_header" expression="'some sample value'"/>
  </int:method>
</int:publishing-interceptor>

<int:channel id="localProcessChannel">
  <int:dispatcher task-executor="executor"/>
</int:channel>

<task:executor id="executor" pool-size="5"/>
```

이런 상황은 wire-tap으로도 해결할 수 있다. [Wire Tap](../messaging-channels/#wire-tap)을 참고해라.

### C.1.3. Producing and Publishing Messages Based on a Scheduled Trigger

앞에서는 메소드 호출에 따른 부산물로 메시지를 구성하고 게시하는 message-publishing 기능을 살펴봤다. 하지만 이 기능을 사용하더라도, 메소드는 사용자가 직접 호출해야 한다. Spring Integration 2.0에선 'inbound-channel-adapter' 요소에 `expression` 속성을 추가해서, 이제 메시지 producer와 publisher를 스케줄링할 수 있다. 여러 가지 트리거를 활용할 수 있으며, 이 중 하나를 'poller' 요소에 설정해주면 된다. 현재는 `cron`, `fixed-rate`, `fixed-delay`를 지원하며, 그 외 직접 구현한 커스텀 트리거를 'trigger' 속성 값으로 참조할 수도 있다.

producer와 publisher를 스케줄링하려면 앞에서 언급한 XML 요소 `<inbound-channel-adapter>`를 이용하면 된다. 다음 예를 살펴보자:

```xml
<int:inbound-channel-adapter id="fixedDelayProducer"
       expression="'fixedDelayTest'"
       channel="fixedDelayChannel">
    <int:poller fixed-delay="1000"/>
</int:inbound-channel-adapter>
```

위 예제에서 만드는 인바운드 채널 어댑터는, `expression` 속성에 정의한 표현식의 결과를 페이로드로 가지는 `Message`를 구성한다. 이땐 매번 `fixed-delay` 속성에 명시한 delay만큼의 시간이 경과하면 메시지를 생성해 전송한다.

아래 코드는 `fixed-rate` 속성을 사용한다는 점만 제외하면 앞의 예제와 거의 동일하다:

```xml
<int:inbound-channel-adapter id="fixedRateProducer"
       expression="'fixedRateTest'"
       channel="fixedRateChannel">
    <int:poller fixed-rate="1000"/>
</int:inbound-channel-adapter>
```

`fixed-rate` 속성을 사용하면 고정 속도로 메시지를 전송할 수 있다 (각 태스크의 시작 시간부터 측정 시작).

다음은 `cron` 속성에 지정한 값으로 Cron 트리거를 적용하는 예제다:

```xml
<int:inbound-channel-adapter id="cronProducer"
       expression="'cronTest'"
       channel="cronChannel">
    <int:poller cron="7 6 5 4 3 ?"/>
</int:inbound-channel-adapter>
```

다음 예제는 메시지에 별도 헤더를 추가하는 방법을 보여준다:

```xml
<int:inbound-channel-adapter id="headerExpressionsProducer"
       expression="'headerExpressionsTest'"
       channel="headerExpressionsChannel"
       auto-startup="false">
    <int:poller fixed-delay="5000"/>
    <int:header name="foo" expression="6 * 7"/>
    <int:header name="bar" value="x"/>
</int:inbound-channel-adapter>
```

별도로 추가하는 메시지 헤더는 스칼라 값이나 스프링의 표현식을 평가한 값을 사용할 수 있다.

자체 커스텀 트리거를 구현해야 한다면, `org.springframework.scheduling.Trigger` 인터페이스를 구현한 클래스를 스프링 빈으로 설정하고 `trigger` 속성으로 참조시켜주면 된다. 다음 예제를 참고해라:

```xml
<int:inbound-channel-adapter id="triggerRefProducer"
       expression="'triggerRefTest'" channel="triggerRefChannel">
    <int:poller trigger="customTrigger"/>
</int:inbound-channel-adapter>

<beans:bean id="customTrigger" class="o.s.scheduling.support.PeriodicTrigger">
    <beans:constructor-arg value="9999"/>
</beans:bean>
```