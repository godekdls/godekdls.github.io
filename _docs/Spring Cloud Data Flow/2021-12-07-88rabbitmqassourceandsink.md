---
title: RabbitMQ as Source and Sink
category: Spring Cloud Data Flow
order: 88
permalink: /Spring%20Cloud%20Data%20Flow/recipes.rabbitmq.rabbit-source-sink/
description: RabbitMQ를 소스와 싱크로 사용하면서 동시에 RabbitMQ 바인더 이용하기
image: ./../../images/springclouddataflow/logo.png
lastmod: 2021-12-08T01:00:00+09:00
comments: true
originalRefName: 스프링 클라우드 데이터 플로우
originalRefLink: https://dataflow.spring.io/docs/recipes/rabbitmq/rabbit-source-sink/
parent: Recipes
parentUrl: /Spring%20Cloud%20Data%20Flow/recipes/
subparent: RabbitMQ
subparentUrl: /Spring%20Cloud%20Data%20Flow/recipes.rabbitmq/
---

---

RabbitMQ에서 바로 데이터를 읽고 쓰는 일은 매우 흔히 있는 일이다. 하지만 소스, 싱크 애플리케이션이 이미 Spring Cloud Stream의 RabbitMQ 바인더 구현체를 사용하고 있다면, 설정이 조금 헷갈릴 수 있다. 이 레시피에선 복잡성을 한 단계씩 해소해보겠다.

시작하기 전에 앞서 구현해볼 유스 케이스의 요구 사항을 설명한다.

*사용자로써, 다음과 같은 스트림을 구현하고 싶다:*

- 외부 RabbitMQ 클러스터에서 실행하고 있는 큐에서 `String` 페이로드를 컨슘한다.
- 페이로드를 받을 때마다 `String`을 대문자로 변환하고 싶다.
- 마지막엔 변환한 페이로드를 다른 큐에 게시하고 싶은데, 이번에도 외부 RabbitMQ 클러스터에서 실행 중인 큐다.

흥미를 더하기 위해, 프로세서, 싱크 애플리케이션에선 Spring Cloud Stream의 RabbitMQ 바인더 구현체도 함께 사용해보겠다.

### 목차

- [Configuration](#configuration)
- [Prerequisite](#prerequisite)
- [Deployment](#deployment)
  + [Source](#source)
  + [Processor](#processor)
  + [Sink](#sink)
- [Testing](#testing)
  + [Publish Test Data](#publish-test-data)
  + [Verify Results](#verify-results)

---

## Configuration

이 유스 케이스를 위해선 두 가지 수준의 RabbitMQ 설정이 필요하다.

- RabbitMQ 소스, 싱크 애플리케이션의 외부 RabbitMQ 클러스터 커넥션 설정.
- 소스, 프로세서, 싱크 애플리케이션의 RabbitMQ 바인더 프로퍼티 설정. 바인더에선 로컬에서 실행하는 `127.0.0.1`(일명 `localhost`) RabbitMQ를 사용한다.

---

## Prerequisite

1. [`rabbit-source`](https://github.com/spring-cloud-stream-app-starters/rabbit/blob/master/spring-cloud-starter-stream-source-rabbit/README.adoc), [`transform-processor`](https://github.com/spring-cloud-stream-app-starters/transform/blob/master/spring-cloud-starter-stream-processor-transform/README.adoc), [`rabbit-sink`](https://github.com/spring-cloud-stream-app-starters/rabbit/blob/master/spring-cloud-starter-stream-sink-rabbit/README.adoc) 애플리케이션을 다운로드한다.

   ```bash
   wget https://repo.spring.io/release/org/springframework/cloud/stream/app/rabbit-source-rabbit/2.1.0.RELEASE/rabbit-source-rabbit-2.1.0.RELEASE.jar
   ```

   ```bash
   wget https://repo.spring.io/release/org/springframework/cloud/stream/app/transform-processor-rabbit/2.1.0.RELEASE/transform-processor-rabbit-2.1.0.RELEASE.jar
   ```

   ```bash
   wget https://repo.spring.io/release/org/springframework/cloud/stream/app/rabbit-sink-rabbit/2.1.0.RELEASE/rabbit-sink-rabbit-2.1.0.RELEASE.jar
   ```

2. `127.0.0.1` 로컬에서 RabbitMQ를 시작한다.

3. 외부 RabbitMQ 클러스터를 세팅하고 클러스터 커넥션 credential을 준비한다.

---

## Deployment

앞에서 설명한 준비 작업을 다 완료했다면, 이제 이 세 가지 애플리케이션들을 시작해볼 수 있다.

### Source

소스 애플리케이션을 시작하려면 아래 명령어를 실행해라:

```bash
java -jar rabbit-source-rabbit-2.1.0.RELEASE.jar --server.port=9001 --rabbit.queues=sabbyfooz --spring.rabbitmq.addresses=amqp://<USER>:<PASSWORD>@<HOST>:<PORT> --spring.rabbitmq.username=<USER> --spring.rabbitmq.password=<PASSWORD> --spring.cloud.stream.binders.rabbitBinder.type=rabbit --spring.cloud.stream.binders.rabbitBinder.environment.spring.rabbitmq.addresses=amqp://guest:guest@127.0.0.1:5672 --spring.cloud.stream.bindings.output.destination=rabzysrc
```

> 외부 RabbitMQ 클러스터 credential은 `--spring.rabbitmq.*` 프로퍼티를 통해 제공한다. 바인더 설정은 `--spring.cloud.stream.binders.rabbitBinder.environment.spring.rabbitmq.*` 프로퍼티로 제공한다. `spring.cloud.stream.binders` 프리픽스를 사용하면 바인더 설정 프로퍼티를 이용할 수 있는데, `rabbitBinder`라는 이름은 이 바인더 설정에서 선택한 이름이다. `<USER>`, `<PASSWORD>`, `<HOST>`, `<PORT>`는 외부 클러스터 credential로 교체해야 한다. 같은 애플리케이션에 서로 다른 RabbitMQ credential을 두 개 설정할 땐 이렇게 전달하면 된다. 하나는 실제 데이터를 전달할 때 쓰고, 다른 하나는 바인더 설정에서 사용한다.

> - `sabbyfooz`는 새로운 데이터를 폴링하기 위한 큐다.
> - `rabzysrc`는 폴링한 데이터를 게시할 목적지다.

### Processor

프로세서 애플리케이션을 시작하려면 아래 명령어를 실행해라:

```bash
java -jar transform-processor-rabbit-2.1.0.RELEASE.jar --server.port=9002 --spring.cloud.stream.binders.rabbitBinder.type=rabbit --spring.cloud.stream.binders.rabbitBinder.environment.spring.rabbitmq.addresses=amqp://guest:guest@127.0.0.1:5672 --spring.cloud.stream.bindings.input.destination=rabzysrc --spring.cloud.stream.bindings.output.destination=rabzysink --transformer.expression='''payload.toUpperCase()'''
```

> - `rabzysrc`는 소스 애플리케이션에서 새로운 데이터를 수신할 목적지다.
> - `rabzysink`는 변환한 데이터를 게시할 목적지다.

### Sink

싱크 애플리케이션을 시작하려면 아래 명령어를 실행해라:

```bash
java -jar rabbit-sink-rabbit-2.1.0.RELEASE.jar --server.port=9003 --rabbit.exchange=sabbyexchange --rabbit.routing-key=foo --spring.rabbitmq.addresses=amqp://<USER>:<PASSWORD>@<HOST>:<PORT> --spring.rabbitmq.username=<USER> --spring.rabbitmq.password=<PASSWORD> --spring.cloud.stream.binders.rabbitBinder.type=rabbit --spring.cloud.stream.binders.rabbitBinder.environment.spring.rabbitmq.addresses=amqp://guest:guest@127.0.0.1:5672 --spring.cloud.stream.bindings.input.destination=rabzysink
```

> 외부 RabbitMQ 클러스터 credential은 `--spring.rabbitmq.*` 프로퍼티를 통해 제공한다. 바인더 설정은 `--spring.cloud.stream.binders.rabbitBinder.environment.spring.rabbitmq.*` 프로퍼티로 제공한다. `spring.cloud.stream.binders` 프리픽스를 사용하면 바인더 설정 프로퍼티를 이용할 수 있는데, `rabbitBinder`라는 이름은 이 바인더 설정에서 선택한 이름이다. `<USER>`, `<PASSWORD>`, `<HOST>`, `<PORT>`는 외부 클러스터 credential로 교체해야 한다. 같은 애플리케이션에 서로 다른 RabbitMQ credential을 두 개 설정할 땐 이렇게 전달하면 된다. 하나는 실제 데이터를 전달할 때 쓰고, 다른 하나는 바인더 설정에서 사용한다.

> - `rabzysink`는 변환된 데이터를 받아올 목적지다.
> - 라우팅 키 `foo`를 가지고 있는 `sabbyexchange`는 데이터가 최종적으로 도달하는 곳이다.

---

## Testing

이 섹션에선 스트림을 테스트하는 법을 설명한다.

### Publish Test Data

검증용 테스트 데이터를 게시하려면:

1. 외부 RabbitMQ 클러스터의 management 콘솔에 접속한다.
2. 큐 목록에서 `sabbyfooz` 큐로 이동한다.
3. `Publish message`를 클릭해서 테스트 메세지(`hello, rabbit!`)를 게시한다.

![Publish Test Message](./../../images/springclouddataflow/Publish_Test_Message.webp)

### Verify Results

게시한 데이터를 검증하려면:

1. 외부 RabbitMQ 클러스터의 management 콘솔에 접속한다.

2. 이 샘플에선 라우팅 키 `foo`를 가지고 있는 `sabbyexchange`는 `sabbybaaz` 큐에 바인딩된다. 큐 목록에서 이 큐로 이동하면 된다.
   
   ![Exchange and Queue Binding](./../../images/springclouddataflow/Bind_Exchange_To_Queue.webp)
   
5. `Get message(s)`를 클릭해서 들어온 메세지를 수신한다.

4. 페이로드가 소문자에서 대문자로 변환됐는지 확인해보면 된다 (즉, `HELLO, RABBIT!`).
   
   ![Publish Test Message](./../../images/springclouddataflow/Receive_Test_Message.webp)

이제 다 됐다! 이것으로 시연을 마친다.