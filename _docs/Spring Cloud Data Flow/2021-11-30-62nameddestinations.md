---
title: Named Destinations
category: Spring Cloud Data Flow
order: 62
permalink: /Spring%20Cloud%20Data%20Flow/feature-guides.stream.named-destinations/
description: 스트림을 생성할 때 애플리케이션 이름 대신 목적지 이름을 지정해 바이패스하기
image: ./../../images/springclouddataflow/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 클라우드 데이터 플로우
originalRefLink: https://dataflow.spring.io/docs/feature-guides/streams/named-destinations/
parent: Feature guides
parentUrl: /Spring%20Cloud%20Data%20Flow/feature-guides/
subparent: Stream Feature Guides
subparentNavTitle: Streams
subparentUrl: /Spring%20Cloud%20Data%20Flow/feature-guides.stream/
---

---

스트림은 소스나 싱크 애플리케이션을 참조하는 대신, 직접 목적지의 이름을 사용할 수 있다. 목적지 이름은 미들웨어 브로커(RabbitMQ, 카프카 등)에 있는 특정 목적지 이름에 해당한다. 애플리케이션들은 `|` 기호를 사용하면 Data Flow 서버에서 만든 메시징 미들웨어 목적지 이름으로 서로 연결된다. 유닉스식 표현에 따라 less-than(`<`), greater-than(`>`) 문자를 사용하면 표준 입출력을 리다이렉트할 수 있다. 목적지의 이름을 지정하려면 앞에 콜론(`:`)을 붙여라. 예를 들어 아래 스트림은 `source` 자리에 목적지 이름을 가지고 있다.

```sh
stream create --definition ":myDestination > log" --name ingest_from_broker --deploy
```

이 스트림은 브로커에 위치한 `myDestination`이라는 목적지로부터 메세지를 받아 log 애플리케이션에 연결한다. 같은 목적지에서 데이터를 컨슘하는 스트림을 추가로 더 생성할 수도 있다.

아래 스트림은 `sink` 자리에 목적지 이름을 사용한다:

```sh
stream create --definition "http > :myDestination" --name ingest_to_broker --deploy
```

아래 예시처럼 하나의 스트림에서 브로커의 다른 두 가지 목적지를 연결할 수도 있다 (소스와 싱크 자리에):

```sh
stream create --definition ":destination1 > :destination2" --name bridge_destinations --deploy
```

위 스트림에 있는 두 목적지 모두 (`destination1`과 `destination2`) 브로커에 위치한다. 메세지는 소스와 싱크를 연결하는 `bridge` 애플리케이션을 통해 소스 목적지에서 싱크 목적지로 흐른다.