---
title: Appendix G. Testing support
category: Spring Integration
order: 30
permalink: /Spring%20Integration/testing/
description: 스프링 인티그레이션 테스트 가이드
image: ./../../images/springintegration/logo.png
lastmod: 2022-11-14T22:00:00+09:00
comments: true
originalRefName: 스프링 인티그레이션
originalRefLink: https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/index-single.html#testing
parent: Appendices
parentUrl: /Spring%20Integration/appendices/
---

---

Spring Integration은 애플리케이션 테스트를 도와주는 다양한 유틸리티와 어노테이션을 제공하고 있다. 테스트 지원은 두 가지 모듈을 통해 이루어진다:

- `spring-integration-test-support` : 테스트를 위한 핵심 항목과 공통 유틸리티가 들어있다
- `spring-integration-test` : integration 테스트를 위한 모킹 기능과 애플리케이션 컨텍스트 설정을 제공한다

`spring-integration-test-support`(5.0 버전 이전에는 `spring-integration-test`)는 독립적으로 사용할 수 있는, unit 테스트를 위한 기본적인 유틸리티, rule, matcher를 제공한다. (Spring Integration 자체에 대한 의존성이 없으며, 프레임워크 내부 테스트에서 사용한다). `spring-integration-test`는 integration 테스트 지원을 위한 모듈로, 통합 구성 요소를 모킹하고, 전체 통합 플로우나 일부만 사용해서 개별 구성 요소들의 동작을 검증할 수 있는 종합적인 고수준 API를 제공한다.

엔터프라이즈 환경에서 빈틈없는 테스트를 준비하는 법은 이 레퍼런스 매뉴얼의 범위를 벗어난다. 가지고 있는 통합 솔루션을 테스트하기 위한 원칙이나 아이디어를 얻고자 한다면 Gregor Hohpe와 Wendy Istvanick가 작성한 [“Test-Driven Development in Enterprise Integration Projects”](https://www.enterpriseintegrationpatterns.com/docs/TestDrivenEAI.pdf)를 읽어봐라.

Spring Integration의 테스트 프레임워크와 테스트 유틸리티는 전반적으로 기존의 JUnit, Hamcrest, Mockito같은 라이브러리를 사용한다. 애플리케이션 컨텍스트 상호작용은 [스프링 테스트 프레임워크](https://docs.spring.io/spring-framework/docs/current/spring-framework-reference/testing.html#testing)를 이용한다. 자세한 내용은 해당 프로젝트 문서를 참고해라.

Spring Integration 프레임워크을 이용하면, 표준 EIP 구현과 일급 객체<sup>first-class citizen</sup>(ex. `MessageChannel`, `Endpoint`, `MessageHandler`), 그리고 추상화와 느슨한 결합이라는 원칙 덕분에, 아무리 복잡한 통합 솔루션이라도 쉽게 구현할 수 있다. Spring Integration API를 사용해 플로우를 정의하면, (대부분) 통합 솔루션의 다른 구성 요소에 영향을 주지 않고 일부 플로우를 개선하고, 수정하고, 교체할 수 있다. 하지만 이러한 통합 솔루션을 테스트하는 것은 end-to-end로 접근하든, 별개로 접근하든 여전히 어려운 과제다. 기존에 있는 툴들을 활용하면 몇 가지 통합 프로토콜을 테스트하거나 모킹할 수 있으며, Spring Integration 채널 어댑터와도 잘 동작한다. 예를 들면 다음과 같은 툴을 활용할 수 있다:

- HTTP 테스트에는 스프링 `MockMVC`와 `MockRestServiceServer`를 사용할 수 있다.
- 일부 RDBMS 벤더는 JDBC나 JPA 지원을 위한 임베디드 데이터베이스를 제공한다.
- JMS나 STOMP 프로토콜을 테스트할 땐 ActiveMQ를 임베딩할 수 있다.
- 임베디드 MongoDB와 Redis를 위한 전용 툴이 있다.
- Tomcat과 Jetty는 실제 HTTP나 웹 서비스, WebSocket을 테스트하기 위한 라이브러리를 내장하고 있다.
- Apache Mina 프로젝트의 `FtpServer`, `SshServer`는 FTP와 SFTP 프로토콜을 테스트하는 데 사용할 수 있다.
- Gemfire와 Hazelcast는 테스트 중에 실 데이터 그리드 노드로 실행할 수 있다.
- Curator 프레임워크는 Zookeeper와의 상호작용을 위한 `TestingServer`를 제공한다.
- Apache Kafka는 테스트용 카프카 브로커를 임베딩하기 위한 관리 툴을 제공한다.
- GreenMail은 테스트 목적으로 사용할 수 있는, 직관적이면서 사용하기도 쉬운 오픈 소스 이메일 서버 테스트 라이브러리다.

이런 툴과 라이브러리는 대부분 Spring Integration 테스트에서도 사용하고 있다. 깃허브 [레포지토리](https://github.com/spring-projects/spring-integration)를 보면서 (각 모듈의 `test` 디렉토리), 통합 솔루션을 위한 자체 테스트를 어떻게 구성할지 생각해보는 것도 좋다.

이어서 이 챕터에선 Spring Integration이 제공하는 테스트 도구와 유틸리티에 대해 설명한다.

### 목차

- [G.1. Testing Utilities](#g1-testing-utilities)
  + [G.1.1. TestUtils](#g11-testutils)
  + [G.1.2. Using OnlyOnceTrigger](#g12-using-onlyoncetrigger)
  + [G.1.3. Support Components](#g13-support-components)
  + [G.1.4. JUnit Rules and Conditions](#g14-junit-rules-and-conditions)
  + [G.1.5. Hamcrest and Mockito Matchers](#g15-hamcrest-and-mockito-matchers)
  + [G.1.6. AssertJ conditions and predicates](#g16-assertj-conditions-and-predicates)
- [G.2. Spring Integration and the Test Context](#g2-spring-integration-and-the-test-context)
- [G.3. Integration Mocks](#g3-integration-mocks)
  + [G.3.1. MockIntegration](#g31-mockintegration)
- [G.4. Other Resources](#g4-other-resources)

---

## G.1. Testing Utilities

`spring-integration-test-support` 모듈은 unit 테스트를 위한 유틸리티와 헬퍼 클래스를 제공한다.

### G.1.1. TestUtils

`TestUtils` 클래스는 주로 다음과 같이 JUnit 테스트 안에서 프로퍼티를 검증할 때 사용한다:

```java
@Test
public void loadBalancerRef() {
    MessageChannel channel = channels.get("lbRefChannel");
    LoadBalancingStrategy lbStrategy = TestUtils.getPropertyValue(channel,
                 "dispatcher.loadBalancingStrategy", LoadBalancingStrategy.class);
    assertTrue(lbStrategy instanceof SampleLoadBalancingStrategy);
}
```

`TestUtils.getPropertyValue()`는 스프링의 `DirectFieldAccessor`를 기반으로 동작하며, 타겟 private 프로퍼티의 값을 가져와준다. 앞의 예제와 같이 dot을 사용해 중첩 프로퍼티에도 접근할 수 있다.

팩토리 메소드 `createTestApplicationContext()`는 Spring Integration 환경에 맞는 `TestApplicationContext` 인스턴스를 생성해준다.

이 클래스를 자세히 알아보려면 [Javadoc](https://docs.spring.io/spring-integration/api/org/springframework/integration/test/util/TestUtils.html)에서 다른 `TestUtils` 메소드들을 함께 읽어봐라.

### G.1.2. Using `OnlyOnceTrigger`

[`OnlyOnceTrigger`](https://docs.spring.io/spring-integration/api/org/springframework/integration/test/util/OnlyOnceTrigger.html)는 테스트 메시지를 딱 하나만 생성한 뒤, 이후 메시지에는 영향을 주지 않은 채로 엔드포인트를 폴링하고 동작을 검증해야 하는 경우에 활용할 수 있다. 다음은 `OnlyOnceTrigger`를 설정하는 예시다:

```xml
<bean id="testTrigger" class="org.springframework.integration.test.util.OnlyOnceTrigger" />

<int:poller id="jpaPoller" trigger="testTrigger">
    <int:transactional transaction-manager="transactionManager" />
</int:poller>
```

다음은 앞에서 설정한 `OnlyOnceTrigger`를 사용해 테스트를 진행하는 예시다:

```java
@Autowired
@Qualifier("jpaPoller")
PollerMetadata poller;

@Autowired
OnlyOnceTrigger testTrigger;

@Test
@DirtiesContext
public void testWithEntityClass() throws Exception {
    this.testTrigger.reset();
    ...
    JpaPollingChannelAdapter jpaPollingChannelAdapter = new JpaPollingChannelAdapter(jpaExecutor);

    SourcePollingChannelAdapter adapter = JpaTestUtils.getSourcePollingChannelAdapter(
    		jpaPollingChannelAdapter, this.outputChannel, this.poller, this.context,
    		this.getClass().getClassLoader());
    adapter.start();
    ...
}
```

### G.1.3. Support Components

`org.springframework.integration.test.support` 패키지엔 테스트 코드에서 직접 구현해서 사용해야 하는 다양한 추상 클래스가 담겨있다:

- [`AbstractRequestResponseScenarioTests`](https://docs.spring.io/spring-integration/api/org/springframework/integration/test/support/AbstractRequestResponseScenarioTests.html)
- [`AbstractResponseValidator`](https://docs.spring.io/spring-integration/api/org/springframework/integration/test/support/AbstractResponseValidator.html)
- [`LogAdjustingTestSupport`](https://docs.spring.io/spring-integration/api/org/springframework/integration/test/support/LogAdjustingTestSupport.html) (Deprecated)
- [`MessageValidator`](https://docs.spring.io/spring-integration/api/org/springframework/integration/test/support/MessageValidator.html)
- [`PayloadValidator`](https://docs.spring.io/spring-integration/api/org/springframework/integration/test/support/PayloadValidator.html)
- [`RequestResponseScenario`](https://docs.spring.io/spring-integration/api/org/springframework/integration/test/support/RequestResponseScenario.html)
- [`SingleRequestResponseScenarioTests`](https://docs.spring.io/spring-integration/api/org/springframework/integration/test/support/SingleRequestResponseScenarioTests.html)

### G.1.4. JUnit Rules and Conditions

 JUnit 4의 테스트 rule `LongRunningIntegrationTest`은 환경 변수 또는 시스템 프로퍼티 `RUN_LONG_INTEGRATION_TESTS`가 `true`로 설정돼있으면 테스트를 실행해야 함을 나타내는 rule이다. 그 외에는 테스트를 건너뛴다. 5.1 버전부터 JUnit 5 테스트에도 같은 용도로 사용할 수 있는 조건부 어노테이션 `@LongRunningTest`를 제공한다.

### G.1.5. Hamcrest and Mockito Matchers

`org.springframework.integration.test.matcher` 패키지에는 unit 테스트 안에서 `Message`와 그 프로퍼티들을 검증하기 위한 여러 가지 `Matcher` 구현체가 들어있다. 다음은 matcher 한 가지의 사용법을 보여주는 예시다 (`PayloadMatcher`):

```java
import static org.springframework.integration.test.matcher.PayloadMatcher.hasPayload;
...
@Test
public void transform_withFilePayload_convertedToByteArray() throws Exception {
    Message<?> result = this.transformer.transform(message);
    assertThat(result, is(notNullValue()));
    assertThat(result, hasPayload(is(instanceOf(byte[].class))));
    assertThat(result, hasPayload(SAMPLE_CONTENT.getBytes(DEFAULT_ENCODING)));
}
```

다음과 같이 스터빙<sup>stubbing</sup>을 위한 mock 객체와 검증에는 팩토리 클래스 `MockitoMessageMatchers`를 사용할 수 있다:

```java
static final Date SOME_PAYLOAD = new Date();

static final String SOME_HEADER_VALUE = "bar";

static final String SOME_HEADER_KEY = "test.foo";
...
Message<?> message = MessageBuilder.withPayload(SOME_PAYLOAD)
                .setHeader(SOME_HEADER_KEY, SOME_HEADER_VALUE)
                .build();
MessageHandler handler = mock(MessageHandler.class);
handler.handleMessage(message);
verify(handler).handleMessage(messageWithPayload(SOME_PAYLOAD));
verify(handler).handleMessage(messageWithPayload(is(instanceOf(Date.class))));
...
MessageChannel channel = mock(MessageChannel.class);
when(channel.send(messageWithHeaderEntry(SOME_HEADER_KEY, is(instanceOf(Short.class)))))
        .thenReturn(true);
assertThat(channel.send(message), is(false));
```

### G.1.6. AssertJ conditions and predicates

5.2 버전부터 AssertJ의 `matches()` 검증에 사용할 수 있는 `MessagePredicate`를 도입했다. 이 클래스에선 기대값으로 `Message` 객체가 필요하다. 또한 기대값이나 실제 메시지 검증에서 제외할 헤더를 설정할 수도 있다.

---

## G.2. Spring Integration and the Test Context

일반적으로 스프링 애플리케이션을 테스트할 땐 스프링 테스트 프레임워크를 사용한다. Spring Integration은 스프링 프레임워크가 토대이기 때문에, 스프링 테스트 프레임워크에서 가능한 것은 전부 통합 플로우를 테스트할 때도 적용할 수 있다. `org.springframework.integration.test.context` 패키지는 통합 요구 사항에 맞게 테스트 컨텍스트를 업그레이드해주는 몇 가지 구성 요소들을 제공한다. 우선 다음 예제와 같이 테스트 클래스에 `@SpringIntegrationTest` 어노테이션을 설정해 Spring Integration 테스트 프레임워크를 활성화해주자:

```java
@RunWith(SpringRunner.class)
@SpringIntegrationTest(noAutoStartup = {"inboundChannelAdapter", "*Source*"})
public class MyIntegrationTests {

    @Autowired
    private MockIntegrationContext mockIntegrationContext;

}
```

`@SpringIntegrationTest` 어노테이션은 `MockIntegrationContext` 빈을 등록해주기 때문에, 테스트 클래스에 주입하면 `MockIntegrationContext`의 메소드에 액세스할 수 있다. Spring Integration 테스트 프레임워크는 `noAutoStartup` 옵션을 지정했다면 `autoStartup=true`인 엔드포인트들을 시작하지 않는다. 이 엔드포인트들은 지정한 패턴과 매칭해서 찾는데, `xxx*`, `*xxx*`, `*xxx`, `xxx*yyy`와 같은 간단한 패턴 스타일을 지원한다.

이 옵션은 인바운드 채널 어댑터가 타겟 시스템과 실제로 커넥션을 맺는 것을 원하지 않을 때 유용하다 (ex. AMQP 인바운드 게이트웨이, JDBC 폴링 채널 어댑터, 클라이언트 모드의 WebSocket 메시지 Producer 등).

테스트 케이스에서 실제 애플리케이션 컨텍스트에 있는 빈을 수정해야 할 땐 `MockIntegrationContext`를 사용하면 된다. 예를 들어, `autoStartup`을 `false`로 재정의한 엔드포인트들은 다음과 같이 mock 객체로 대체할 수 있다:

```java
@Test
public void testMockMessageSource() {
    MessageSource<String> messageSource = () -> new GenericMessage<>("foo");

    this.mockIntegrationContext.substituteMessageSourceFor("mySourceEndpoint", messageSource);

    Message<?> receive = this.results.receive(10_000);
    assertNotNull(receive);
}
```

> 여기서 `mySourceEndpoint`는 실제 `MessageSource`를 mock으로 대체하는 `SourcePollingChannelAdapter`의 빈 이름을 나타낸다. 유사하게 `MockIntegrationContext.substituteMessageHandlerFor()`는 `MessageHandler`를 엔드포인트로 래핑하는 `IntegrationConsumer` 빈의 이름을 받는다.

테스트를 수행한 후 `MockIntegrationContext.resetBeans()`를 사용하면 엔드포인트 빈의 상태를 실제 설정으로 복원할 수 있다:

```java
@After
public void tearDown() {
    this.mockIntegrationContext.resetBeans();
}
```

자세한 내용은 [Javadoc](https://docs.spring.io/spring-integration/api/org/springframework/integration/test/context/MockIntegrationContext.html)을 참고해라.

---

## G.3. Integration Mocks

`org.springframework.integration.test.mock` 패키지는 Spring Integration 구성 요소의 움직임을 모킹<sup>mocking</sup>, 스터빙<sup>stubbing</sup>, 검증하기 위한 도구와 유틸리티를 제공한다. 모킹 기능은 유명 테스트 프레임워크 Mockito를 기반으로 동작하며, 완벽하게 호환된다. (현재 Mockito의 전이 의존성<sup>transitive dependency</sup>은 2.5.x 이상을 사용한다.)

### G.3.1. MockIntegration

팩토리 클래스 `MockIntegration`은 통합 플로우를 구성하는 Spring Integration 빈(`MessageSource`, `MessageProducer`, `MessageHandler`, `MessageChannel`)에 대한 mock 객체를 빌드할 수 있는 API를 제공한다. 다음 예제와 같이 설정 단계 뿐 아니라 테스트 메소드 안에서도 mock을 사용해 검증하기 전 실제 엔드포인트 교체할 수 있다:

```xml
<int:inbound-channel-adapter id="inboundChannelAdapter" channel="results">
    <bean class="org.springframework.integration.test.mock.MockIntegration" factory-method="mockMessageSource">
        <constructor-arg value="a"/>
        <constructor-arg>
            <array>
                <value>b</value>
                <value>c</value>
            </array>
        </constructor-arg>
    </bean>
</int:inbound-channel-adapter>
```

다음은 위와 동일한 설정을 구성하는 자바 코드다:

```java
@InboundChannelAdapter(channel = "results")
@Bean
public MessageSource<Integer> testingMessageSource() {
    return MockIntegration.mockMessageSource(1, 2, 3);
}
...
StandardIntegrationFlow flow = IntegrationFlows
        .from(MockIntegration.mockMessageSource("foo", "bar", "baz"))
        .<String, String>transform(String::toUpperCase)
        .channel(out)
        .get();
IntegrationFlowRegistration registration = this.integrationFlowContext.registration(flow)
        .register();
```

그러려면 다음과 같이 앞에서 설명한 `MockIntegrationContext`를 사용해서 테스트해야 한다:

```java
this.mockIntegrationContext.substituteMessageSourceFor("mySourceEndpoint",
        MockIntegration.mockMessageSource("foo", "bar", "baz"));
Message<?> receive = this.results.receive(10_000);
assertNotNull(receive);
assertEquals("FOO", receive.getPayload());
```

Mockito의 `MessageSource` mock 객체와 달리는, `MockMessageHandler`는 메시지를 받아 스터빙 처리하는 체인 API를 가지고 있는 일반적인 `AbstractMessageProducingHandler`의 하위 클래스다. `MockMessageHandler`는 다음 요청 메시지를 받으면 실행할 단방향 스터빙 동작을 지정할 수 있는 `handleNext(Consumer<Message<?>>)`를 제공한다. 이 메소드는 응답을 생성하지 않는 메시지 핸들러를 모킹할 때 사용한다. `handleNextAndReply(Function<Message<?>, ?>)`는 다음 요청 메시지를 받으면 동일하게 스터빙 로직을 실행하고, 이에 대한 응답을 생성한다. 이 메소드들을 체이닝하면 예상할 수 있는 모든 요청 메시지에 대해 임의의 request-reply 시나리오를 시뮬레이션해볼 수 있다. 이러한 컨슈머와 함수는 누적해놨다가 한 번에 하나씩 꺼내서 사용하며, 남은 메시지들엔 전부 마지막 항목을 적용한다. 이 동작은 Mockito의 `Answer`나 `doReturn()` API와 유사하다.

또한 생성자 인자를 통해 `MockMessageHandler`에 Mockito `ArgumentCaptor<Message<?>>`를 제공할 수 있다. 그러면 이 `ArgumentCaptor`는 `MockMessageHandler`에 대한 각 요청 메시지를 포착한다. 테스트 중에 `getValue()`, `getAllValues()` 메소드를 사용하면 해당 요청 메시지를 확인하고 검증할 수 있다.

`MockIntegrationContext`는 테스트 중인 엔드포인트에서 실제로 설정한 `MessageHandler`를 `MockMessageHandler`로 대체할 수 있는 `substituteMessageHandlerFor()` API를 제공한다.

다음은 이를 활용한 전형적인 테스트 시나리오 예시다:

```java
ArgumentCaptor<Message<?>> messageArgumentCaptor = ArgumentCaptor.forClass(Message.class);

MessageHandler mockMessageHandler =
        mockMessageHandler(messageArgumentCaptor)
                .handleNextAndReply(m -> m.getPayload().toString().toUpperCase());

this.mockIntegrationContext.substituteMessageHandlerFor("myService.serviceActivator",
                               mockMessageHandler);
GenericMessage<String> message = new GenericMessage<>("foo");
this.myChannel.send(message);
Message<?> received = this.results.receive(10000);
assertNotNull(received);
assertEquals("FOO", received.getPayload());
assertSame(message, messageArgumentCaptor.getValue());
```

자세한 내용은 [`MockIntegration`](https://docs.spring.io/spring-integration/api/org/springframework/integration/test/mock/MockIntegration.html)과 [`MockMessageHandler`](https://docs.spring.io/spring-integration/api/org/springframework/integration/test/mock/MockMessageHandler.html)의 Javadoc을 참고해라.

---

## G.4. Other Resources

프레임워크 안에 들어있는 테스트 케이스를 탐색해봐도 좋지만, [Spring Integration Samples 레포지토리](https://github.com/spring-projects/spring-integration-samples)에는 `testing-examples`, `advanced-testing-examples`같이 테스트 코드를 보여주기 위해 특별히 만들어둔 샘플 애플리케이션이 포함돼있다. `file-split-ftp` 샘플과 같이, 경우에 따라서 샘플 자체에 종합적인 end-to-end 테스트가 담겨있기도 하다.