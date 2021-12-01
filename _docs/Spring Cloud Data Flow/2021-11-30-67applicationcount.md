---
title: Application Count
category: Spring Cloud Data Flow
order: 67
permalink: /Spring%20Cloud%20Data%20Flow/feature-guides.stream.application-count/
description: 각 애플리케이션의 인스턴스 수를 지정해서 스트림 배포하기
image: ./../../images/springclouddataflow/logo.png
lastmod: 2021-12-02T00:33:00+09:00
comments: true
originalRefName: 스프링 클라우드 데이터 플로우
originalRefLink: https://dataflow.spring.io/docs/feature-guides/streams/application-count/
parent: Feature guides
parentUrl: /Spring%20Cloud%20Data%20Flow/feature-guides/
subparent: Stream Feature Guides
subparentNavTitle: Streams
subparentUrl: /Spring%20Cloud%20Data%20Flow/feature-guides.stream/
---

---

아래 있는 스트림 파이프라인 예시는 각 애플리케이션의 인스턴스 수를 지정할 수 있다:

```sh
 stream create http-ingest --definition "http --server.port=9000 | log"
```

이 스트림을 배포할 때 다음과 같이 `count`를 지정하면 된다:

```sh
 stream deploy http-ingest "deployer.log.count=3"
```