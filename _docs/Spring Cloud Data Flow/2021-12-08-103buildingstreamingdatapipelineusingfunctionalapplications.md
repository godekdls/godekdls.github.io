---
title: Building Streaming Data Pipeline using Functional applications
navTitle: Functional Applications
category: Spring Cloud Data Flow
order: 103
permalink: /Spring%20Cloud%20Data%20Flow/recipes.functional-apps.scst-function-bindings/
description: 함수형 애플리케이션으로 스트리밍 데이터 파이프라인 구축하기
image: ./../../images/springclouddataflow/logo.png
lastmod: 2021-12-08T01:00:00+09:00
comments: true
originalRefName: 스프링 클라우드 데이터 플로우
originalRefLink: https://dataflow.spring.io/docs/recipes/functional-apps/scst-function-bindings/
parent: Recipes
parentUrl: /Spring%20Cloud%20Data%20Flow/recipes/
subparent: Functional Applications
subparentUrl: /Spring%20Cloud%20Data%20Flow/recipes.functional-apps/
---

---

이 레시피에선 Spring Cloud Stream을 사용해서 간단한 함수 기반 애플리케이션을 만들고, 함수형 애플리케이션들로 Spring Cloud Data Flow 스트리밍 데이터 파이프라인을 구축하는 방법을 설명한다.

### 목차

- [Overview](#overview)
- [Using Functional Applications with Other Versions of Spring Cloud Stream Applications](#using-functional-applications-with-other-versions-of-spring-cloud-stream-applications)

---

## Overview

여기서는 설정해둔 간격으로 현재 날짜 혹은 타임스탬프를 생성해 메세징 미들웨어로 전송하는 `time-source` 애플리케이션을 만들어본다. 발행한 메세지를 컨슘하는 싱크 `log-sink` 애플리케이션도 함께 만들어본다.

Spring Cloud Stream이 이런 기능을 어떤 식으로 제공하고 있는지는 [Spring Cloud Stream 문서](https://cloud.spring.io/spring-cloud-static/spring-cloud-stream/current/reference/html/spring-cloud-stream.html#spring-cloud-stream-overview-producing-consuming-messages)를 참고해라.

샘플 애플리케이션들은 Spring Cloud Data Flow 샘플 [레포지토리](https://github.com/spring-cloud/spring-cloud-dataflow-samples/tree/master/spring-cloud-stream-function-bindings)에서 확인할 수 있다.

의존성에 Spring Cloud Stream 3.x가 있다면, 다음과 같이 `java.util.function.Supplier`를 이용해 `Source` 애플리케이션을 작성할 수 있다:

```java
package com.example.timesource;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.function.Supplier;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

@SpringBootApplication
public class TimeSourceApplication {

	@Bean
	public Supplier<String> timeSupplier() {
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
		return () -> {
			return sdf.format(new Date());
		};
	}

	public static void main(String[] args) {
		SpringApplication.run(TimeSourceApplication.class, args);
	}

}
```

Spring Cloud Stream은 `Supplier` 함수 `timeSupplier()`를 트리거링하도록 설정할 수 있는 `spring.cloud.stream.poller.DefaultPollerProperties`를 제공한다. 예를 들어 `--spring.cloud.stream.poller.fixed-delay=5000` 프로퍼티를 사용하면 5초마다 이 `Supplier` 함수를 트리거할 수 있다.

마찬가지로, `Sink` 애플리케이션은 다음과 같이 `java.util.function.Consumer`를 사용해서 작성할 수 있다:

```java
package com.example.logsink;

import java.util.function.Consumer;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.integration.dsl.IntegrationFlow;
import org.springframework.integration.dsl.IntegrationFlows;
import org.springframework.integration.handler.LoggingHandler;
import org.springframework.messaging.Message;

@SpringBootApplication
public class LogSinkApplication {

	@Bean
	IntegrationFlow logConsumerFlow() {
		return IntegrationFlows.from(MessageConsumer.class, (gateway) -> gateway.beanName("logConsumer"))
				.handle((payload, headers) -> {
					if (payload instanceof byte[]) {
						return new String((byte[]) payload);
					}
					return payload;
				})
				.log(LoggingHandler.Level.INFO, "log-consumer", "payload")
				.get();
	}

	private interface MessageConsumer extends Consumer<Message<?>> {}

	public static void main(String[] args) {
		SpringApplication.run(LogSinkApplication.class, args);
	}
}
```

`time-source`와 `log-sink` 애플리케이션을 모두 빌드하고, Spring Cloud Data Flow에 등록해주면 된다.

이 애플리케이션들을 사용해서 다음과 같은 스트림을 생성한다고 가정해보자:

```properties
ticktock=time-source | log-sink
```

이런 애플리케이션들은 Spring Cloud Data Flow가 이해할 수 있게 함수 바인딩을 적절한 `output`과 `input` 이름에 매핑해줘야 한다.

따라서 스트림을 배포할 땐 다음과 같은 프로퍼티를 설정해줘야 한다:

```properties
app.time-source.spring.cloud.stream.function.bindings.timeSupplier-out-0=output
app.log-sink.spring.cloud.stream.function.bindings.logConsumer-in-0=input
```

`timeSupplier` 함수의 출력은 Spring Cloud Data Flow가 이해할 수 있는 아웃바운드명 `output`에,  `logConsumer` 함수의 입력은 인바운드명 `input`에 매핑해야 한다.

더불어서 `Supplier` 함수를 트리거할 방법도 제공해야 한다:

```properties
app.time-source.spring.cloud.stream.poller.fixed-delay=5000
```

스트림을 `local` deployer를 사용해 실행할 때는, 애플리케이션들의 로그를 Skipper 서버 로그로 상속해서, `log-sink` 컨슈머가 남기는 `ticktock` 스트림 메세지를 Skipper 서버 로그에서도 확인할 수 있다:

```properties
deployer.*.local.inherit-logging=true
```

---

## Using Functional Applications with Other Versions of Spring Cloud Stream Applications

함수형 애플리케이션은 Spring Cloud Stream 버전이 다른 애플리케이션과도 함께 사용할 수 있다 (ex. `@EnableBinding`을 사용해 인바운드, 아웃바운드 엔드포인트를 명시적으로 선언하는 애플리케이션).

이럴 땐 함수 바인딩은 **함수형 애플리케이션에만** 명시해줘야 한다.

예를 들어서 [stream-app-starters](https://github.com/spring-cloud-stream-app-starters/time/blob/17ce146a0049d0259e12a39a80ae57c4ea148258/spring-cloud-starter-stream-source-time/src/main/java/org/springframework/cloud/stream/app/time/source/TimeSourceConfiguration.java#L36)에 있는 `time` 소스 애플리케이션을 사용한다고 가정해보자. 그러면 `TimeSourceConfiguration` 클래스는 다음과 같이 구성될 거다:

```java
@EnableBinding(Source.class)
@Import({TriggerConfiguration.class, TriggerPropertiesMaxMessagesDefaultOne.class})
public class TimeSourceConfiguration {

	@Autowired
	private TriggerProperties triggerProperties;

	@PollableSource
	public String publishTime() {
		return new SimpleDateFormat(this.triggerProperties.getDateFormat()).format(new Date());
	}

}
```

앞에서 사용했던 `log-sink` 컨슈머 애플리케이션을 함께 사용한다고 생각해보자:

```java
package com.example.logsink;

import java.util.function.Consumer;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.integration.dsl.IntegrationFlow;
import org.springframework.integration.dsl.IntegrationFlows;
import org.springframework.integration.handler.LoggingHandler;
import org.springframework.messaging.Message;

@SpringBootApplication
public class LogSinkApplication {

	@Bean
	IntegrationFlow logConsumerFlow() {
		return IntegrationFlows.from(MessageConsumer.class, (gateway) -> gateway.beanName("logConsumer"))
				.handle((payload, headers) -> {
					if (payload instanceof byte[]) {
						return new String((byte[]) payload);
					}
					return payload;
				})
				.log(LoggingHandler.Level.INFO, "log-consumer", "payload")
				.get();
	}

	private interface MessageConsumer extends Consumer<Message<?>> {}

	public static void main(String[] args) {
		SpringApplication.run(LogSinkApplication.class, args);
	}
}
```

이제 SCDF에서 이 `time`과 `log-sink`를 사용해서 다음과 같은 스트림을 생성한다고 해보자:

```properties
ticktock=time | log-sink
```

이때는 `time` 애플리케이션은 `@EnableBidning`을 사용했기 때문에 바인딩된 `output`이 있으므로, 함수 바인딩은 `log-sink`에만 설정해줘야 한다. 그 방법은 아래 예시를 참고해라:

```properties
app.log-sink.spring.cloud.stream.function.bindings.logConsumer-in-0=input
```