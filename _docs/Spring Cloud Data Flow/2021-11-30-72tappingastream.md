---
title: Tapping a Stream
category: Spring Cloud Data Flow
order: 72
permalink: /Spring%20Cloud%20Data%20Flow/feature-guides.stream.taps/
description: 기존 스트림 데이터를 활용해 병렬 스트리밍 데이터 파이프라인 구축하기
image: ./../../images/springclouddataflow/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 클라우드 데이터 플로우
originalRefLink: https://dataflow.spring.io/docs/feature-guides/streams/taps/
parent: Feature guides
parentUrl: /Spring%20Cloud%20Data%20Flow/feature-guides/
subparent: Stream Feature Guides
subparentNavTitle: Streams
subparentUrl: /Spring%20Cloud%20Data%20Flow/feature-guides.stream/
---

---

Spring Cloud Stream 용어에서 [목적지 이름<sup>named destination</sup>](../feature-guides.stream.named-destinations)이라고 하면, 메세징 미들웨어나 스트리밍 플랫폼에 있는 특정한 목적지 이름을 말하는 거다. 목적지 이름은 RabbitMQ의 `exchange`나 아파치 카프카의 `topic`이 될 수 있다. Spring Cloud Data Flow에선 목적지 이름을 publisher 역할인지 컨슈머 역할인지에 따라 직접적인 `source`나 `sink`로 취급할 수 있다. 개발자는 목적지(ex. 카프카 토픽)에서 데이터를 컨슘하거나 목적지(ex. 카프카 토픽)로 데이터를 생성할 수 있다. Spring Cloud Data Flow에선 목적지 이름을 이용해 메세징 미들웨어에 있는 목적지 간의 이벤트 스트리밍 파이프라인을 구축할 수 있다.

스트림 DSL에선 목적지 이름 앞에 콜론(`:`)을 붙여야 한다.

HTTP 웹 엔드포인트에서 사용자 클릭 이벤트를 수집해 `user-click-events`라는 카프카 토픽으로 전송하고 싶다고 해보자. 이 경우엔 Spring Cloud Data Flow의 스트림 DSL은 다음과 같을 거다:

```sh
http > :user-click-events
```

이제 `user-click-events` 카프카 토픽을 HTTP 웹 엔드포인트에서 사용자 클릭 이벤트를 컨슘하도록 설정했음으로, `sink` 역할을 담당한다.

이 사용자 클릭 이벤트를 컨슘하고 RDBMS에 저장하는 다른 이벤트 스트리밍 파이프라인을 생성하고 싶다고 해보자. 이 경우엔 스트림 DSL은 다음과 같을 거다:

```sh
:user-click-events > jdbc
```

이제 카프카 토픽 `user-click-events`는 `jdbc` 애플리케이션을 위한 프로듀서 역할을 담당한다.

primary 스트림 처리 파이프라인의 이벤트 게시자로부터 동일한 데이터를 분기해 병렬 이벤트 스트리밍 파이프라인을 구성하는 건 흔한 유스 케이스다. 아래와 같은 primary 스트림을 생각해보자:

```sh
mainstream=http | filter --expression='payload.userId != null' | transform --expression=payload.sensorValue | log
```

`mainstream`이라는 스트림을 배포하면, Spring Cloud Data Flow는 Spring Cloud Stream을 사용해 각 애플리케이션을 연결하는 카프카 토픽을 자동으로 생성한다. 토픽명은 Spring Cloud Data Flow가 `stream`과 `application` 네이밍 컨벤션에 따라 지정하며, 적절한 Spring Cloud Stream 바인딩 프로퍼티를 사용하면 토픽명을 재정의할 수 있다. 여기서는 세 가지 카프카 토픽이 생성된다:

- `mainstream.http`: HTTP 소스의 출력을 filter 프로세서의 입력으로 연결하는 카프카 토픽
- `mainstream.filter`: filter 프로세서의 출력을 transform 프로세서의 입력으로 연결하는 카프카 토픽
- `mainstream.transform`: transform 프로세서의 출력을 log 싱크의 입력에 연결하는 카프카 토픽

primary 스트림에서 복사본을 수신하는 병렬 스트림 파이프라인을 생성하려면, 이 카프카 토픽명을 사용해 이벤트 스트리밍 파이프라인을 구성해야 한다. 예를 들어 `http` 애플리케이션의 출력을 활용<sup>tap</sup>해, 필터링되지 않은 데이터를 수신하는 이벤트 스트리밍 파이프라인을 새로 구성하고 싶을 수 있다. 스트림 DSL은 다음과 같을 거다:

```sh
unfiltered-http-events=:mainstream.http > jdbc
```

다음과 같이 `filter` 애플리케이션의 출력을 활용<sup>tap</sup>해 필터링된 데이터의 복사본을 얻어, 또 다른 다운스트림에서 데이터를 저장하고 싶을 수도 있다.

```sh
filtered-http-events=:mainstream.filter > mongodb
```

Spring Cloud Data Flow에서 스트림의 이름은 고유하다. 따라서 스트림 이름을 지정한 카프카 토픽을 컨슘하는 애플리케이션의 컨슈머 그룹 이름으로 사용한다. 덕분에 여러 이벤트 스트리밍 파이프라인이 메세지를 놓고 경쟁하는 대신, 동일한 데이터의 복사본을 얻어갈 수 있다.