---
title: Stream Application Development
category: Spring Cloud Data Flow
order: 27
permalink: /Spring%20Cloud%20Data%20Flow/stream-developer-guides.stream-development.stream-application-development/
description: Spring Cloud Stream을 이용해 source, processor, sink 애플리케이션 개발하기
image: ./../../images/springclouddataflow/logo.png
lastmod: 2021-12-02T00:33:00+09:00
comments: true
originalRefName: 스프링 클라우드 데이터 플로우
originalRefLink: https://dataflow.spring.io/docs/stream-developer-guides/streams/standalone-stream-sample/
parent: Stream Developer guides
parentUrl: /Spring%20Cloud%20Data%20Flow/stream-developer-guides/
subparent: Stream Development
subparentUrl: /Spring%20Cloud%20Data%20Flow/stream-developer-guides.stream-development/
---
<script>defaultLanguages = ['kafka']</script>

---

이 가이드에선 Spring Cloud Stream을 사용해 세 가지 스프링 부트 애플리케이션을 개발하고, 클라우드 파운드리, 쿠버네티스, 로컬 머신에 배포해본다. [Data Flow를 사용해서 이 애플리케이션들을 배포](../stream-developer-guides.stream-development.stream-processing)하는 일은 별도 가이드 문서에서 다룬다. 애플리케이션을 직접 수동으로 배포해보면 Data Flow가 자동화해주는 일들을 더 깊게 이해할 수 있다.

이어지는 섹션에선 이 애플리케이션들을 빌드하는 방법부터 설명한다.

원한다면 이 애플리케이션들의 소스 코드를 가지고 있는 zip 파일을 다운받아, 압축을 풀고 빌드해서 [배포](#deployment) 섹션으로 이동해도 좋다.

이 세 가지 애플리케이션이 전부 들어있는 [프로젝트는 브라우저에서 다운받을 수 있다](https://github.com/spring-cloud/spring-cloud-dataflow-samples/blob/master/dataflow-website/stream-developer-guides/streams/standalone-stream-sample/dist/usage-cost-stream-sample.zip?raw=true). 아래 예시처럼 커맨드라인을 사용해도 된다:

```bash
wget https://github.com/spring-cloud/spring-cloud-dataflow-samples/blob/master/dataflow-website/stream-developer-guides/streams/standalone-stream-sample/dist/usage-cost-stream-sample.zip?raw=true -O usage-cost-stream-sample.zip
```

---

# Building the downloaded sample

스트림 앱은 공통 코드 베이스는 유지하면서, 카프카 브로커나 RabbitMQ와 함께 실행하도록 설정할 수 있다. 유일한 차이점은 executable jar 파일에 있다. 카프카 브로커와 함께 동작하려면 카프카 바인더 의존성이 필요하다 (디폴트로 활성화된다). RabbitMQ에선 Rabbit 바인더가 필요하다.

> Kafka Streams, Amazon Kinesis, Google PubSub (partner maintained), Solace PubSub+ (partner maintained), Azure Event Hubs (partner maintained)를 지원하는 Spring Cloud Stream 바인더 구현체도 있다. 바인더는 빌드 시점에 선택한다. 샘플 프로젝트는 메이븐 프로파일을 사용해 적당한 바인더를 활성화한다.

<div class="switch-language-wrapper kafka rabbitmq">
<span class="switch-language kafka">Kafka</span>
<span class="switch-language rabbitmq">RabbitMQ</span>
</div>
<div class="language-only-for-kafka kafka rabbitmq"></div>
<div style="border: 1px solid #ddd; padding: 15px; margin-bottom: 20px; background-color: #f9f9f9;">
<p>카프카 전용 샘플 스트림 앱을 빌드하려면 프로젝트 루트 디렉토리에서 아래 명령어를 실행해라:</p>
<div class="language-bash highlighter-rouge" style="display: block;"><div class="highlight"><pre class="highlight"><code><span class="nv">$.</span>/mvnw clean package <span class="nt">-Pkafka</span>
</code></pre></div></div>
</div>
<div class="language-only-for-rabbitmq kafka rabbitmq"></div>
<div style="border: 1px solid #ddd; padding: 15px; margin-bottom: 20px; background-color: #f9f9f9;">
<p>RabbitMQ 전용 샘플 스트림 앱을 빌드하려면 프로젝트 루트 디렉토리에서 아래 명령어를 실행해라:</p>
<div class="language-sh highlighter-rouge" style="display: block;"><div class="highlight"><pre class="highlight"><code><span class="nv">$.</span>/mvnw clean package <span class="nt">-Prabbit</span>
</code></pre></div></div>
</div>


---

# Development

설정한 바인더를 사용해서 통신하는 Spring Cloud Stream 애플리케이션을 세 가지 만들어보겠다.

이번 시나리오는 고객을 위한 청구서를 만드는 휴대폰 회사다. 사용자가 통화를 할 때마다 `duration`과 통화 중에 사용한 `data` 양이 정해진다. 청구서를 만드는 프로세스에선 원래의 통화 데이터를, 통화 시간 동안의 비용과 사용한 데이터 양에 대한 비용으로 변환해야 한다.

통화 내역은 해당 통화의 `duration`과 통화 중 사용한 `data` 양을 가지고 있는 `UsageDetail` 클래스로 모델링한다. 청구서는 통화 비용(`costCall`)과 데이터 비용(`costData`)을 가지고 있는 `UsageCostDetail` 클래스로 모델링한다. 각 클래스는 전화를 건 사람을 식별할 수 있는 ID(`userId`)를 포함한다.

이번에 만들어볼 세 가지 스트리밍 애플리케이션은 다음과 같다:

- `Source` 애플리케이션(`UsageDetailSender`로 명명)은 각 `userId`마다 사용자의 통화 `duration`과 사용한 `data` 양을 만들어내고, `UsageDetail` 객체를 포함하는 메세지를 JSON으로 전송한다.
- `Processor` 애플리케이션(`UsageCostProcessor`라 명명)은 이 `UsageDetail`을 컨슘하고 `userId`당 통화 비용과 데이터 비용을 계산한다. `UsageCostDetail` 객체를 JSON으로 전송한다.
- `Sink` 애플리케이션(`UsageCostLogger`로 명명)은 `UsageCostDetail` 객체를 컨슘하고 통화 및 데이터 비용을 기록한다.

### 목차

- [Source](#source)
  + [Business Logic](#business-logic)
  + [Configuration](#configuration)
  + [Building](#building)
  + [Testing](#testing)
- [Processor](#processor)
  + [Business Logic](#business-logic-1)
  + [Configuration](#configuration-1)
  + [Building](#building-1)
  + [Testing](#testing-1)
- [Sink](#sink)
  + [Business Logic](#business-logic-2)
  + [Configuration](#configuration-2)
  + [Building](#building-2)
  + [Testing](#testing-2)

---

## Source

여기서는 `UsageDetailSender` 소스를 생성한다.

<div class="switch-language-wrapper kafka rabbitmq">
<span class="switch-language kafka">Kafka</span>
<span class="switch-language rabbitmq">RabbitMQ</span>
</div>
<div class="language-only-for-kafka kafka rabbitmq"></div>
<div style="border: 1px solid #ddd; padding: 15px; margin-bottom: 20px; background-color: #f9f9f9;">
<p><a href="https://start.spring.io/#!type=maven-project&amp;language=java&amp;platformVersion=2.4.3.RELEASE&amp;packaging=jar&amp;jvmVersion=1.8&amp;groupId=io.spring.dataflow.sample&amp;artifactId=usage-detail-sender-kafka&amp;name=usage-detail-sender-kafka&amp;description=Demo project for Spring Boot&amp;packageName=io.spring.dataflow.sample.usagedetailsender&amp;dependencies=cloud-stream,actuator,kafka">Spring Initializr에서 만들어 둔 프로젝트를 바로 다운로드</a>하거나</p>
<p><a href="https://start.spring.io/">Spring Initializr 사이트</a>를 방문해서 아래 설명대로 따라하면 된다:</p>
<ol>
  <li>그룹명은 <code class="highlighter-rouge">io.spring.dataflow.sample</code>, 아티팩트명은 <code class="highlighter-rouge">usage-detail-sender-kafka</code>, 패키지는 <code class="highlighter-rouge">o.spring.dataflow.sample.usagedetailsender</code>를 사용해서 새 메이븐 프로젝트를 생성한다.</li>
  <li><strong>Dependencies</strong> 텍스트 박스에 <code class="highlighter-rouge">Kafka</code>를 입력해서 카프카 바인더 의존성을 선택한다.</li>
  <li><strong>Dependencies</strong> 텍스트 박스에 <code class="highlighter-rouge">Cloud Stream</code>을 입력해서 Spring Cloud Stream 의존성을 선택한다.</li>
  <li><strong>Dependencies</strong> 텍스트 박스에 <code class="highlighter-rouge">Actuator</code>를 입력하고 스프링 부트 액추에이터 의존성을 선택한다.</li>
  <li><strong>Generate Project</strong> 버튼을 클릭한다.</li>
</ol>
<p>이제 <code class="highlighter-rouge">usage-detail-sender-kafka.zip</code> 파일을 <code class="highlighter-rouge">unzip</code>하고 즐겨 사용하는 IDE에서 프로젝트를 임포트하면 된다.</p>
<p>카프카를 메세지 브로커로 사용할 때는 다양한 설정 옵션들을 선택해 확장하거나 재정의해서 원하는 런타임 동작을 완성할 수 있다. 카프카 바인더 설정 프로퍼티들은 <a href="https://docs.spring.io/spring-cloud-stream-binder-kafka/docs/current/reference/html/spring-cloud-stream-binder-kafka.html#_configuration_options">카프카 바인더 문서</a>에 정리되어 있다.</p>
</div>
<div class="language-only-for-rabbitmq kafka rabbitmq"></div>
<div style="border: 1px solid #ddd; padding: 15px; margin-bottom: 20px; background-color: #f9f9f9;">
<p><a href="https://start.spring.io/#!type=maven-project&language=java&platformVersion=2.4.3.RELEASE&packaging=jar&jvmVersion=1.8&groupId=io.spring.dataflow.sample&artifactId=usage-detail-sender-rabbit&name=usage-detail-sender-rabbit&description=Demo project for Spring Boot&packageName=io.spring.dataflow.sample.usagedetailsender&dependencies=cloud-stream,actuator,amqp">Spring Initializr에서 만든 프로젝트를 바로 다운로드</a>하거나</p>
<p><a href="https://start.spring.io/">Spring Initializr 사이트</a>를 방문해서 아래 설명대로 따라하면 된다:</p>
  <ol>
  <li>그룹명은 <code class="highlighter-rouge">io.spring.dataflow.sample</code>, 아티팩트명은 <code class="highlighter-rouge">usage-detail-sender-rabbit</code>, 패키지는 <code class="highlighter-rouge">o.spring.dataflow.sample.usagedetailsender</code>를 사용해서 새 메이븐 프로젝트를 생성한다.</li>
  <li><strong>Dependencies</strong> 텍스트 박스에 <code class="highlighter-rouge">RabbitMQ</code>를 입력해서 RabbitMQ 바인더 의존성을 선택한다.</li>
  <li><strong>Dependencies</strong> 텍스트 박스에 <code class="highlighter-rouge">Cloud Stream</code>을 입력해서 Spring Cloud Stream 의존성을 선택한다.</li>
  <li><strong>Dependencies</strong> 텍스트 박스에 <code class="highlighter-rouge">Actuator</code>를 입력하고 스프링 부트 액추에이터 의존성을 선택한다.</li>
  <li><strong>Generate Project</strong> 버튼을 클릭한다.</li>
</ol>
<p>이제 <code class="highlighter-rouge">usage-detail-sender-rabbit.zip</code> 파일을 <code class="highlighter-rouge">unzip</code>하고 즐겨 사용하는 IDE에서 프로젝트를 임포트하면 된다.</p>
<h2 id="durable-queues">Durable Queues</h2>
<p>Spring Cloud Stream 컨슈머 애플리케이션은 기본적으로 <code class="highlighter-rouge">anonymous</code> auto-delete 큐를 생성한다. 그렇기 때문에 producer 애플리케이션이 컨슈머 애플리케이션보다 먼저 기동됐다면, producer가 메세지를 저장하고 전달하지 못하는 메세지가 생길 수 있다. exchange를 durable로 설정했다 하더라도 이후에도 컨슘할 수 있게 메세지를 저장하려면 exchange에 바인딩할 <code class="highlighter-rouge">durable</code> 큐가 필요하다. 이런한 까닭으로 메세지 전달을 보장하기 위해서는 <code class="highlighter-rouge">durable</code> 큐가 필요하다.
  </p>
<p>durable 큐를 미리 생성하고 exchange에 바인딩하려면 producer 애플리케이션에 아래 프로퍼티를 설정해야 한다:</p>
<div class="language-properties highlighter-rouge"><div class="highlight"><pre class="highlight"><code><span class="err">spring.cloud.stream.bindings.&lt;channelName&gt;.producer.requiredGroups</span>
</code></pre></div></div>
<p>이 <code class="highlighter-rouge">requiredGroups</code> 프로퍼티는 producer가 메세지 전달을 보장해야 하는 그룹들을 콤마로 구분해서 받는다. 이 프로퍼티를 설정하면 <code class="highlighter-rouge">&lt;exchange&gt;.&lt;requiredGroup&gt;</code> 형식을 통해 durable 큐가 생성된다.</p>
<p>RabbitMQ를 메세지 브로커로 사용할 때는 다양한 설정 옵션들을 선택해 확장하거나 재정의해서 원하는 런타임 동작을 완성할 수 있다. RabbitMQ 바인더 설정 프로퍼티들은 <a href="https://cloud.spring.io/spring-cloud-static/spring-cloud-stream-binder-rabbit/current/reference/html/spring-cloud-stream-binder-rabbit.html#_configuration_options">RabbitMQ 바인더 문서</a>에 정리되어 있다.</p>
</div>


### Business Logic

이제 이 애플리케이션에 필요한 코드를 만들면 된다. 비지니스 로직을 작성하려면:

1. `io.spring.dataflow.sample.usagedetailsender` 패키지에 [UsageDetail.java](https://github.com/spring-cloud/spring-cloud-dataflow-samples/blob/master/dataflow-website/stream-developer-guides/streams/standalone-stream-sample/usage-detail-sender/src/main/java/io/spring/dataflow/sample/usagedetailsender/UsageDetail.java)와 같은 `UsageDetail` 클래스를 생성한다. `UsageDetail` 클래스에는 `userId`, `data`, `duration` 프로퍼티가 담겨있다.
2. `io.spring.dataflow.sample.usagedetailsender` 패키지에 `UsageDetailSender` 클래스를 생성한다. 이 클래스는 아래 코드와 비슷하게 만들어야 한다:

```java
package io.spring.dataflow.sample.usagedetailsender;

import java.util.Random;
import java.util.function.Supplier;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class UsageDetailSender {

	private String[] users = {"user1", "user2", "user3", "user4", "user5"};

	@Bean
	public Supplier<UsageDetail> sendEvents() {
		return () -> {
			UsageDetail usageDetail = new UsageDetail();
			usageDetail.setUserId(this.users[new Random().nextInt(5)]);
			usageDetail.setDuration(new Random().nextInt(300));
			usageDetail.setData(new Random().nextInt(700));
			return usageDetail;
		};
	}
}
```

`sendEvents` Supplier는 `UsageDetail` 객체에 랜덤 값을 채워 제공한다. Spring Cloud Stream은 자동으로 이 함수를 바인딩해서 해당 데이터를 설정해둔 출력 목적지로 전송한다. Spring Cloud Stream은 모든 Supplier에 디폴트 폴러도 설정하는데, 기본적으로 1초 간격으로 함수를 호출하게 된다.

### Configuration

`source` 애플리케이션을 설정할 때는, producer가 데이터를 게시할 `output` 바인딩 목적지를 설정해야 한다 (RabbitMQ exchange나 카프카 토픽의 이름).

'`sendEvents` 함수의 첫 번째 출력 파라미터'에 해당하는 출력은, 함수 출력 바인딩 이름으로 표현하면 `sendEvents-out-0`이다. 편의상 이 `sendEvents-out-0`을 논리적인 이름 `output`으로 alias를 지정하겠다. alias를 사용하지 않고 출력 바인딩 이름을 직접 사용해도 된다 (`spring.cloud.stream.bindings.sendEvents-out-0.destination=usage-detail`). 자세한 설명은 [Functional Binding Names](https://docs.spring.io/spring-cloud-stream/docs/current/reference/html/spring-cloud-stream.html#_functional_binding_names)을 참고해라.

`src/main/resources/application.properties`에 아래 프로퍼티를 추가해라:

```properties
spring.cloud.stream.function.bindings.sendEvents-out-0=output
spring.cloud.stream.bindings.output.destination=usage-detail
# Spring Boot will automatically assign an unused http port. This may be overridden using external configuration.
server.port=0
```

### Building

이제 이 Usage Detail Sender 애플리케이션을 빌드하면 된다.

메이븐으로 프로젝트를 빌드하려면 `usage-detail-sender` 루트 디렉토리에서 아래 명령어를 실행해라:

```bash
./mvnw clean package
```

### Testing

Spring Cloud Stream은 Spring Cloud Stream 애플리케이션을 테스트할 수 있는 test jar를 제공한다:

```xml
<dependency>
	<groupId>org.springframework.cloud</groupId>
	<artifactId>spring-cloud-stream</artifactId>
	<type>test-jar</type>
	<classifier>test-binder</classifier>
	<scope>test</scope>
</dependency>
```

`TestChannelBinderConfiguration`에선 메세지 브로커 바인더 구현체 대신, 애플리케이션의 아웃바운드와 인바운드 메세지를 추적하고 테스트하는할 수 있는 인메모리 바인더 구현체를 제공한다. 테스트 설정에는 메세지를 보내고 받기 위한 `InputDestination`과 `OutputDestination` 빈이 들어있다. `UsageDetailSender` 애플리케이션을 단위 테스트하려면 `UsageDetailSenderApplicationTests` 클래스에 아래 코드를 추가해라:

```java
package io.spring.dataflow.sample.usagedetailsender;

import org.junit.jupiter.api.Test;

import org.springframework.boot.WebApplicationType;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.cloud.stream.binder.test.OutputDestination;
import org.springframework.cloud.stream.binder.test.TestChannelBinderConfiguration;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.messaging.Message;
import org.springframework.messaging.converter.CompositeMessageConverter;
import org.springframework.messaging.converter.MessageConverter;

import static org.assertj.core.api.Assertions.assertThat;

public class UsageDetailSenderApplicationTests {

	@Test
	public void contextLoads() {
	}

	@Test
	public void testUsageDetailSender() {
		try (ConfigurableApplicationContext context = new SpringApplicationBuilder(
				TestChannelBinderConfiguration
						.getCompleteConfiguration(UsageDetailSenderApplication.class))
				.web(WebApplicationType.NONE)
				.run()) {

			OutputDestination target = context.getBean(OutputDestination.class);
			Message<byte[]> sourceMessage = target.receive(10000);

			final MessageConverter converter = context.getBean(CompositeMessageConverter.class);
			UsageDetail usageDetail = (UsageDetail) converter
					.fromMessage(sourceMessage, UsageDetail.class);

			assertThat(usageDetail.getUserId()).isBetween("user1", "user5");
			assertThat(usageDetail.getData()).isBetween(0L, 700L);
			assertThat(usageDetail.getDuration()).isBetween(0L, 300L);
		}
	}
}
```

- `contextLoads` 테스트 케이스에선 애플리케이션을 정상적으로 기동할 수 있는지 검증한다.
- `testUsageDetailSender` 테스트 케이스에선 `OutputDestination`을 사용해 `UsageDetailSender`가 전송한 메세지를 받아 검증한다.

> 이 인메모리 테스트 바인더는 다른 메세지 브로커 바인더 구현체가 동작하는 방식과 그대로다. 특히, Spring Cloud Stream 애플리케이션에선 기본적으로 메세지 페이로드는 항상 JSON으로 인코딩한 바이트 배열이다. 컨슘하는 애플리케이션은 입력 채널에서 바이트를 수신하고, 컨텐츠 타입에 따라 적절한 `MessageConverter`에 자동으로 위임해서 바이트를 컨슈밍 함수의 인자 타입인 `UsageDetail`에 맞게 변환한다. 테스트를 위해서는 이 단계를 명시적으로 수행해야 한다. 아니면 `MessageConverter`를 사용하는 대신에 JSON 파서를 직접 호출해도 된다.

---

## Processor

이번에는 `UsageCostProcessor` 프로세서를 생성한다.

<div class="switch-language-wrapper kafka rabbitmq">
<span class="switch-language kafka">Kafka</span>
<span class="switch-language rabbitmq">RabbitMQ</span>
</div>
<div class="language-only-for-kafka kafka rabbitmq"></div>
<div style="border: 1px solid #ddd; padding: 15px; margin-bottom: 20px; background-color: #f9f9f9;">
<p><a href="https://start.spring.io/#!type=maven-project&amp;language=java&amp;platformVersion=2.4.3.RELEASE&amp;packaging=jar&amp;jvmVersion=1.8&amp;groupId=io.spring.dataflow.sample&amp;artifactId=usage-cost-processor-kafka&amp;name=usage-cost-processor-kafka&amp;description=Demo project for Spring Boot&amp;packageName=io.spring.dataflow.sample.usagecostprocessor&amp;dependencies=cloud-stream,actuator,kafka">Spring Initializr에서 만들어 둔 프로젝트를 바로 다운로드</a>하거나</p>
<p><a href="https://start.spring.io/">Spring Initializr 사이트</a>를 방문해서 아래 설명대로 따라하면 된다:</p>
<ol>
  <li>그룹명은 <code class="highlighter-rouge">io.spring.dataflow.sample</code>, 아티팩트명은 <code class="highlighter-rouge">usage-cost-processor-kafka</code>, 패키지는 <code class="highlighter-rouge">o.spring.dataflow.sample.usagecostprocessor</code>를 사용해서 새 메이븐 프로젝트를 생성한다.</li>
  <li><strong>Dependencies</strong> 텍스트 박스에 <code class="highlighter-rouge">Kafka</code>를 입력해서 카프카 바인더 의존성을 선택한다.</li>
  <li><strong>Dependencies</strong> 텍스트 박스에 <code class="highlighter-rouge">Cloud Stream</code>을 입력해서 Spring Cloud Stream 의존성을 선택한다.</li>
  <li><strong>Dependencies</strong> 텍스트 박스에 <code class="highlighter-rouge">Actuator</code>를 입력하고 스프링 부트 액추에이터 의존성을 선택한다.</li>
  <li><strong>Generate Project</strong> 버튼을 클릭한다.</li>
</ol>
<p>이제 <code class="highlighter-rouge">usage-cost-processor-kafka.zip</code> 파일을 <code class="highlighter-rouge">unzip</code>하고 즐겨 사용하는 IDE에서 프로젝트를 임포트하면 된다.</p>
</div>
<div class="language-only-for-rabbitmq kafka rabbitmq"></div>
<div style="border: 1px solid #ddd; padding: 15px; margin-bottom: 20px; background-color: #f9f9f9;">
<p><a href="https://start.spring.io/#!type=maven-project&amp;language=java&amp;platformVersion=2.4.3.RELEASE&amp;packaging=jar&amp;jvmVersion=1.8&amp;groupId=io.spring.dataflow.sample&amp;artifactId=usage-cost-processor-rabbit&amp;name=usage-cost-processor-rabbit&amp;description=Demo project for Spring Boot&amp;packageName=io.spring.dataflow.sample.usagecostprocessor&amp;dependencies=cloud-stream,actuator,amqp">Spring Initializr에서 만들어 둔 프로젝트를 바로 다운로드</a>하거나</p>
<p><a href="https://start.spring.io/">Spring Initializr 사이트</a>를 방문해서 아래 설명대로 따라하면 된다:</p>
<ol>
  <li>그룹명은 <code class="highlighter-rouge">io.spring.dataflow.sample</code>, 아티팩트명은 <code class="highlighter-rouge">usage-cost-processor-rabbit</code>, 패키지는 <code class="highlighter-rouge">o.spring.dataflow.sample.usagecostprocessor</code>를 사용해서 새 메이븐 프로젝트를 생성한다.</li>
  <li><strong>Dependencies</strong> 텍스트 박스에 <code class="highlighter-rouge">RabbitMQ</code>를 입력해서 RabbitMQ 바인더 의존성을 선택한다.</li>
  <li><strong>Dependencies</strong> 텍스트 박스에 <code class="highlighter-rouge">Cloud Stream</code>을 입력해서 Spring Cloud Stream 의존성을 선택한다.</li>
  <li><strong>Dependencies</strong> 텍스트 박스에 <code class="highlighter-rouge">Actuator</code>를 입력하고 스프링 부트 액추에이터 의존성을 선택한다.</li>
  <li><strong>Generate Project</strong> 버튼을 클릭한다.</li>
</ol>
<p>이제 <code class="highlighter-rouge">usage-cost-processor-rabbit.zip</code> 파일을 <code class="highlighter-rouge">unzip</code>하고 즐겨 사용하는 IDE에서 프로젝트를 임포트하면 된다.</p>
</div>




### Business Logic

이제 이 애플리케이션에 필요한 코드를 만들면 된다. 비지니스 로직을 작성하려면:

1. `io.spring.dataflow.sample.usagecostprocessor` 패키지에 `UsageDetail` 클래스를 생성한다. 클래스 내용물은 [UsageDetail.java](https://github.com/spring-cloud/spring-cloud-dataflow-samples/blob/master/dataflow-website/stream-developer-guides/streams/standalone-stream-sample/usage-cost-processor/src/main/java/io/spring/dataflow/sample/usagecostprocessor/UsageDetail.java)와 비슷하다. `UsageDetail` 클래스에는 `userId`, `data`, `duration` 프로퍼티가 담겨있다.
2. `io.spring.dataflow.sample.usagecostprocessor` 패키지에 `UsageCostDetail` 클래스를 생성한다. 내용물은 [UsageCostDetail.java](https://github.com/spring-cloud/spring-cloud-dataflow-samples/blob/master/dataflow-website/stream-developer-guides/streams/standalone-stream-sample/usage-cost-processor/src/main/java/io/spring/dataflow/sample/usagecostprocessor/UsageCostDetail.java)와 비슷하다. `UsageCostDetail` 클래스에는 `userId`, `callCost`, `dataCost` 프로퍼티가 담겨있다.
3. `UsageDetail` 메세지를 받아 통화 및 데이터 비용을 계산하고 `UsageCostDetail` 메세지를 전송할 `UsageCostProcessor` 클래스를 `io.spring.dataflow.sample.usagecostprocessor` 패키지에 생성해라. 소스 코드는 다음과 같다:

```java
package io.spring.dataflow.sample.usagecostprocessor;

import java.util.function.Function;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class UsageCostProcessor {

	private double ratePerSecond = 0.1;

	private double ratePerMB = 0.05;

	@Bean
	public Function<UsageDetail, UsageCostDetail> processUsageCost() {
		return usageDetail -> {
			UsageCostDetail usageCostDetail = new UsageCostDetail();
			usageCostDetail.setUserId(usageDetail.getUserId());
			usageCostDetail.setCallCost(usageDetail.getDuration() * this.ratePerSecond);
			usageCostDetail.setDataCost(usageDetail.getData() * this.ratePerMB);
			return usageCostDetail;
		};
	}
}
```

위 애플리케이션에선 `UsageDetail`을 받아 `UsageCostDetail`을 반환하는 `Function` 빈을 선언하고 있다. Spring Cloud Stream은 이 함수를 찾아 해당 입출력을 메세징 미들웨어에 설정된 목적지에 바인딩한다. 앞 섹션에서 설명했듯이 Spring Cloud Stream은 적절한 `MessageConverter`를 사용해 메세지를 필요한 타입으로 변환해준다.

### Configuration

`processor` 애플리케이션을 설정할 땐 아래 프로퍼티들을 설정해야 한다:

- 이 애플리케이션이 구독하는 `input` 바인딩 목적지 (카프카 토픽이나 RabbitMQ exchange).
- producer가 데이터를 게시할 `output`바인딩 목적지.

> 프로덕션 애플리케이션에선 `spring.cloud.stream.bindings.input.group`을 설정해서 이 컨슈머 애플리케이션이 속해있는 컨슈머 그룹을 지정하는 게 좋다. 이렇게 하면 추가적인 컨슈머 애플리케이션들도 각자 고유 그룹 id로 식별하면서 모든 메세지를 수신할 수 있다. 각 컨슈머 그룹은 여러 개의 인스턴스로 확장해서 작업 부하를 분산할 수 있다. Spring Cloud Stream은 RabbitMQ나 기타 다른 바인더 구현체로 확장할 수 있도록 카프카가 가진 이 고유의 기능을 추상화한다.

`src/main/resources/application.properties`에 아래 프로퍼티들을 추가해라:

```properties
spring.cloud.stream.function.bindings.processUsageCost-in-0=input
spring.cloud.stream.function.bindings.processUsageCost-out-0=output
spring.cloud.stream.bindings.input.destination=usage-detail
spring.cloud.stream.bindings.output.destination=usage-cost
# Spring Boot will automatically assign an unused http port. This may be overridden using external configuration.
server.port=0
```

편의상 함수 바인딩 이름 `processUsageCost-in-0`과 `processUsageCost-out-0`을 각각 `input`, `output`으로 alias를 지정한다.

- `spring.cloud.stream.bindings.input.destination` 프로퍼티는 `UsageCostProcessor` 객체의 `input`을 `usage-detail` 목적지에 바인딩한다.
- `spring.cloud.stream.bindings.output.destination` 프로퍼티는 `UsageCostProcessor` 객체의 출력을 `usage-cost` 목적지에 바인딩한다.

> 입력 목적지는 반드시 소스 애플리케이션의 출력 목적지와 동일해야 한다. 마찬가지로 출력 목적지는 아래에 나오는 싱크의 입력 목적지와 동일해야 한다.

### Building

이제 이 Usage Cost Processor 애플리케이션을 빌드하면 된다. `usage-cost-processor` 루트 디렉토리에서 아래 명령어를 실행해 메이븐으로 프로젝트를 빌드해라:

```sh
./mvnw clean package
```

### Testing

앞에서도 말했지만, Spring Cloud Stream은 Spring Cloud Stream 애플리케이션을 테스트할 수 있는 test jar를 제공한다:

```xml
<dependency>
	<groupId>org.springframework.cloud</groupId>
	<artifactId>spring-cloud-stream</artifactId>
	<type>test-jar</type>
	<classifier>test-binder</classifier>
	<scope>test</scope>
</dependency>
```

`TestChannelBinderConfiguration`은 애플리케이션의 아웃바운드와 인바운드 메세지를 추적하고 테스트할 수 있는 인메모리 바인더 구현체를 제공한다. 테스트 설정에는 메세지를 보내고 받기 위한 `InputDestination`과 `OutputDestination` 빈이 들어있다. `UsageCostProcessor` 애플리케이션을 단위 테스트하려면 `UsageCostProcessorApplicationTests` 클래스에 다음 코드를 추가해라:

```java
package io.spring.dataflow.sample.usagecostprocessor;

import java.util.HashMap;
import java.util.Map;

import org.junit.jupiter.api.Test;

import org.springframework.boot.WebApplicationType;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.cloud.stream.binder.test.InputDestination;
import org.springframework.cloud.stream.binder.test.OutputDestination;
import org.springframework.cloud.stream.binder.test.TestChannelBinderConfiguration;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageHeaders;
import org.springframework.messaging.converter.CompositeMessageConverter;
import org.springframework.messaging.converter.MessageConverter;

import static org.assertj.core.api.Assertions.assertThat;

public class UsageCostProcessorApplicationTests {

	@Test
	public void contextLoads() {
	}

	@Test
	public void testUsageCostProcessor() {
		try (ConfigurableApplicationContext context = new SpringApplicationBuilder(
				TestChannelBinderConfiguration.getCompleteConfiguration(
						UsageCostProcessorApplication.class)).web(WebApplicationType.NONE)
				.run()) {

			InputDestination source = context.getBean(InputDestination.class);

			UsageDetail usageDetail = new UsageDetail();
			usageDetail.setUserId("user1");
			usageDetail.setDuration(30L);
			usageDetail.setData(100L);

			final MessageConverter converter = context.getBean(CompositeMessageConverter.class);
			Map<String, Object> headers = new HashMap<>();
			headers.put("contentType", "application/json");
			MessageHeaders messageHeaders = new MessageHeaders(headers);
			final Message<?> message = converter.toMessage(usageDetail, messageHeaders);

			source.send(message);

			OutputDestination target = context.getBean(OutputDestination.class);
			Message<byte[]> sourceMessage = target.receive(10000);

			final UsageCostDetail usageCostDetail = (UsageCostDetail) converter
					.fromMessage(sourceMessage, UsageCostDetail.class);

			assertThat(usageCostDetail.getCallCost()).isEqualTo(3.0);
			assertThat(usageCostDetail.getDataCost()).isEqualTo(5.0);
		}
	}
}
```

- `contextLoads` 테스트 케이스에선 애플리케이션을 정상적으로 기동할 수 있는지 검증한다.
- `testUsageCostProcessor` 테스트 케이스에선 `InputDestination`을 사용해 메세지를 보내고, `OutputDestination`을 사용해 이 메세지를 받아 검증한다.

---

## Sink

이번에는 `UsageCostLogger` 싱크를 생성한다.

<div class="switch-language-wrapper kafka rabbitmq">
<span class="switch-language kafka">Kafka</span>
<span class="switch-language rabbitmq">RabbitMQ</span>
</div>
<div class="language-only-for-kafka kafka rabbitmq"></div>
<div style="border: 1px solid #ddd; padding: 15px; margin-bottom: 20px; background-color: #f9f9f9;">
<p><a href="https://start.spring.io/#!type=maven-project&amp;language=java&amp;platformVersion=2.4.3.RELEASE&amp;packaging=jar&amp;jvmVersion=1.8&amp;groupId=io.spring.dataflow.sample&amp;artifactId=usage-cost-logger-kafka&amp;name=usage-cost-logger-kafka&amp;description=Demo project for Spring Boot&amp;packageName=io.spring.dataflow.sample.usagecostlogger&amp;dependencies=cloud-stream,actuator,kafka">Spring Initializr에서 만들어 둔 프로젝트를 바로 다운로드</a>받아 <strong>Generate Project</strong>를 클릭하거나</p>
<p><a href="https://start.spring.io/">Spring Initializr 사이트</a>를 방문해서 아래 설명대로 따라하면 된다:</p>
<ol>
  <li>그룹명은 <code class="highlighter-rouge">io.spring.dataflow.sample</code>, 아티팩트명은 <code class="highlighter-rouge">usage-cost-logger-kafka</code>, 패키지는 <code class="highlighter-rouge">o.spring.dataflow.sample.usagecostlogger</code>를 사용해서 새 메이븐 프로젝트를 생성한다.</li>
  <li><strong>Dependencies</strong> 텍스트 박스에 <code class="highlighter-rouge">Kafka</code>를 입력해서 카프카 바인더 의존성을 선택한다.</li>
  <li><strong>Dependencies</strong> 텍스트 박스에 <code class="highlighter-rouge">Cloud Stream</code>을 입력해서 Spring Cloud Stream 의존성을 선택한다.</li>
  <li><strong>Dependencies</strong> 텍스트 박스에 <code class="highlighter-rouge">Actuator</code>를 입력하고 스프링 부트 액추에이터 의존성을 선택한다.</li>
  <li><strong>Generate Project</strong> 버튼을 클릭한다.</li>
</ol>
<p>이제 <code class="highlighter-rouge">usage-cost-logger-kafka.zip</code> 파일을 <code class="highlighter-rouge">unzip</code>하고 즐겨 사용하는 IDE에서 프로젝트를 임포트하면 된다.</p>
</div>
<div class="language-only-for-rabbitmq kafka rabbitmq"></div>
<div style="border: 1px solid #ddd; padding: 15px; margin-bottom: 20px; background-color: #f9f9f9;">
<p><a href="https://start.spring.io/#!type=maven-project&amp;language=java&amp;platformVersion=2.4.3.RELEASE&amp;packaging=jar&amp;jvmVersion=1.8&amp;groupId=io.spring.dataflow.sample&amp;artifactId=usage-cost-logger-rabbit&amp;name=usage-cost-logger-rabbit&amp;description=Demo project for Spring Boot&amp;packageName=io.spring.dataflow.sample.usagecostlogger&amp;dependencies=cloud-stream,actuator,amqp">Spring Initializr에서 만들어 둔 프로젝트를 바로 다운로드</a>받아 <strong>Generate Project</strong>를 클릭하거나</p>
<p><a href="https://start.spring.io/">Spring Initializr 사이트</a>를 방문해서 아래 설명대로 따라하면 된다:</p>
<ol>
  <li>그룹명은 <code class="highlighter-rouge">io.spring.dataflow.sample</code>, 아티팩트명은 <code class="highlighter-rouge">usage-cost-logger-rabbit</code>, 패키지는 <code class="highlighter-rouge">o.spring.dataflow.sample.usagecostlogger</code>를 사용해서 새 메이븐 프로젝트를 생성한다.</li>
  <li><strong>Dependencies</strong> 텍스트 박스에 <code class="highlighter-rouge">RabbitMQ</code>를 입력해서 RabbitMQ 바인더 의존성을 선택한다.</li>
  <li><strong>Dependencies</strong> 텍스트 박스에 <code class="highlighter-rouge">Cloud Stream</code>을 입력해서 Spring Cloud Stream 의존성을 선택한다.</li>
  <li><strong>Dependencies</strong> 텍스트 박스에 <code class="highlighter-rouge">Actuator</code>를 입력하고 스프링 부트 액추에이터 의존성을 선택한다.</li>
  <li><strong>Generate Project</strong> 버튼을 클릭한다.</li>
</ol>
<p>이제 <code class="highlighter-rouge">usage-cost-logger-rabbit.zip</code> 파일을 <code class="highlighter-rouge">unzip</code>하고 즐겨 사용하는 IDE에서 프로젝트를 임포트하면 된다.</p>
</div>



### Business Logic

비지니스 로직을 작성하려면:

1. `io.spring.dataflow.sample.usagecostlogger` 패키지에 `UsageCostDetail` 클래스를 생성한다. 클래스 내용물은 [UsageCostDetail.java](https://github.com/spring-cloud/spring-cloud-dataflow-samples/blob/master/dataflow-website/stream-developer-guides/streams/standalone-stream-sample/usage-cost-logger/src/main/java/io/spring/dataflow/sample/usagecostlogger/UsageCostDetail.java)와 비슷하다. `UsageCostDetail` 클래스에는 `userId`, `callCost`, `dataCost` 프로퍼티가 담겨있다.
3. `UsageCostDetail` 메세지를 받아 로그를 남기는 `UsageCostLogger` 클래스를 `io.spring.dataflow.sample.usagecostlogger` 패키지에 생성해라. 소스 코드는 다음과 같다:

```java
package io.spring.dataflow.sample.usagecostlogger;

import java.util.function.Consumer;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class UsageCostLogger {

	private static final Logger logger = LoggerFactory.getLogger(UsageCostLoggerApplication.class);

	@Bean
	public Consumer<UsageCostDetail> process() {
		return usageCostDetail -> {
			logger.info(usageCostDetail.toString());
		};
	}
}
```

위 애플리케이션에선 `UsageCostDetail`을 받는 `Consumer` 빈을 선언하고 있다. Spring Cloud Stream은 이 함수를 찾아 해당 입력을 메세징 미들웨어에 설정된 입력 목적지에 바인딩한다. 앞 섹션에서 설명했듯이 Spring Cloud Stream은 컨슈머를 실행하기 전에 적절한 `MessageConverter`를 사용해 메세지를 필요한 타입으로 변환해준다.

### Configuration

`sink` 애플리케이션을 설정할 땐 아래 프로퍼티들을 설정해야 한다:

- 이 애플리케이션이 구독하는 `input` 바인딩 목적지 (카프카 토픽이나 RabbitMQ exchange).
- 이 컨슈머 애플리케이션이 속해있는 컨슈머 그룹을 지정하는 `group` (생략 가능).

편의상 함수 바인딩 이름 `process-in-0`을 `input`으로 alias를 지정한다.

`src/main/resources/application.properties`에 아래 프로퍼티들을 추가해라:

```properties
spring.cloud.stream.function.bindings.process-in-0=input
spring.cloud.stream.bindings.input.destination=usage-cost
# Spring Boot will automatically assign an unused http port. This may be overridden using external configuration.
server.port=0
```

### Building

이제 이 Usage Cost Logger 애플리케이션을 빌드하면 된다. `usage-cost-logger` 루트 디렉토리에서 아래 명령어를 실행해 메이븐으로 프로젝트를 빌드해라:

```sh
./mvnw clean package
```

### Testing

`UsageCostLogger`를 테스트하려면 `UsageCostLoggerApplicationTests` 클래스를 만들어 다음 코드를 추가해라:

```java
package io.spring.dataflow.sample.usagecostlogger;

import java.util.HashMap;
import java.util.Map;

import org.awaitility.Awaitility;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;

import org.springframework.boot.WebApplicationType;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.test.system.CapturedOutput;
import org.springframework.boot.test.system.OutputCaptureExtension;
import org.springframework.cloud.stream.binder.test.InputDestination;
import org.springframework.cloud.stream.binder.test.TestChannelBinderConfiguration;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageHeaders;
import org.springframework.messaging.converter.CompositeMessageConverter;
import org.springframework.messaging.converter.MessageConverter;

@ExtendWith(OutputCaptureExtension.class)
public class UsageCostLoggerApplicationTests {

	@Test
	public void contextLoads() {
	}

	@Test
	public void testUsageCostLogger(CapturedOutput output) {
		try (ConfigurableApplicationContext context = new SpringApplicationBuilder(
				TestChannelBinderConfiguration
						.getCompleteConfiguration(UsageCostLoggerApplication.class))
				.web(WebApplicationType.NONE)
				.run()) {

			InputDestination source = context.getBean(InputDestination.class);

			UsageCostDetail usageCostDetail = new UsageCostDetail();
			usageCostDetail.setUserId("user1");
			usageCostDetail.setCallCost(3.0);
			usageCostDetail.setDataCost(5.0);

			final MessageConverter converter = context.getBean(CompositeMessageConverter.class);
			Map<String, Object> headers = new HashMap<>();
			headers.put("contentType", "application/json");
			MessageHeaders messageHeaders = new MessageHeaders(headers);
			final Message<?> message = converter.toMessage(usageCostDetail, messageHeaders);

			source.send(message);

			Awaitility.await().until(output::getOut, value -> value.contains("{\"userId\": \"user1\", \"callCost\": \"3.0\", \"dataCost\": \"5.0\" }"));
		}
	}
}
```

`pom.xml`에 `awaitility` 의존성을 추가해라:

```xml
<dependency>
    <groupId>org.awaitility</groupId>
    <artifactId>awaitility</artifactId>
    <scope>test</scope>
</dependency>
```

- `contextLoads` 테스트 케이스에선 애플리케이션을 정상적으로 기동할 수 있는지 검증한다.
- `testUsageCostLogger` 테스트 케이스에선 스프링 부트의 테스트 프레임워크에서 `OutputCaptureExtension`을 사용해 `UsageCostLogger`의 `process` 메소드를 호출하는지 검증한다.

# Deployment

다음에 해볼 일은 이 애플리케이션들에 설정해둔 메세지 브로커를 사용해서, [지원하는 플랫폼 중 하나에 애플리케이션들을 배포](../stream-developer-guides.stream-development.stream-application-deployment)해보는 거다.