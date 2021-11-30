---
title: Fan-in and Fan-out
category: Spring Cloud Data Flow
order: 68
permalink: /Spring%20Cloud%20Data%20Flow/feature-guides.stream.fanin-fanout/
description: fan-in, fan-out 기능을 이용해 여러 목적지에 데이터를 게시하고 구독하기
image: ./../../images/springclouddataflow/fan-in-fan-out.webp
lastmod: 2021-12-02T00:33:00+09:00
comments: true
originalRefName: 스프링 클라우드 데이터 플로우
originalRefLink: https://dataflow.spring.io/docs/feature-guides/streams/fanin-fanout/
parent: Feature guides
parentUrl: /Spring%20Cloud%20Data%20Flow/feature-guides/
subparent: Stream Feature Guides
subparentNavTitle: Streams
subparentUrl: /Spring%20Cloud%20Data%20Flow/feature-guides.stream/
---

---

fan-in과 fan-out 유스 케이스는 [목적지 이름<sup>named destination</sup>](../feature-guides.stream.named-destinations)을 지정해서 구현할 수 있다. Fan-in 유스 케이스는 아래 예시와 같이 여러 소스가 모두 같은 목적지로 데이터를 전송하는 경우다:

```
s3 > :data
ftp > :data
http > :data
```

위 예제에선 Amazon S3, FTP, HTTP 소스의 데이터 페이로드를 `data`라는 같은 목적지<sup>named destination</sup>로 전송한다. 그런 다음 아래 DSL 표현식으로 생성한 별도 스트림에서, 이 세 가지 소스로부터 받은 데이터를 전부 파일 싱크로 전송할 거다:

```
:data > file
```

fan-in을 그래픽으로 표현하면 다음과 같다:

![Fan-in](./../../images/springclouddataflow/fan-in-fan-out.webp)

fan-out 유스 케이스는 스트림의 목적지를 런타임에만 알 수 있는 몇 가지 정보들을 통해 결정하는 경우다. 이럴 땐 [라우터 애플리케이션](https://github.com/spring-cloud/stream-applications/blob/v2021.0.1/applications/sink/router-sink/README.adoc)을 사용해 수신한 메세지를 N개의 목적지<sup>named destination</sup> 중 하나로 전송하는 방법을 지정할 수 있다.

Fan-in과 Fan-out 동작은 [이 동영상](https://youtu.be/l8SgHtP5QCI)을 참고해도 좋다.