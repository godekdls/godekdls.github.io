---
title: Stream Application Deployment
category: Spring Cloud Data Flow
order: 28
permalink: /Spring%20Cloud%20Data%20Flow/stream-developer-guides.stream-development.stream-application-deployment/
description: 샘플 스트림 애플리케이션을 수동으로 배포하기
image: ./../../images/springclouddataflow/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 클라우드 데이터 플로우
originalRefLink: https://dataflow.spring.io/docs/stream-developer-guides/streams/deployment/
parent: Stream Developer guides
parentUrl: /Spring%20Cloud%20Data%20Flow/stream-developer-guides/
subparent: Stream Development
subparentUrl: /Spring%20Cloud%20Data%20Flow/stream-developer-guides.stream-development/
---

---

이번 섹션에선 [샘플 스트림 애플리케이션](../stream-developer-guides.stream-development.stream-application-development)을 로컬 호스트나 쿠버네티티스, 클라우드 파운드리 환경에 독립 실행형 애플리케이션으로 배포하는 방법을 알아본다.

> 이 섹션에서 설명하는 내용은 분산 스트리밍 파이프라인을 선택한 플랫폼의 전용 유틸리티들만 사용해 독립 실행형으로 배포하는 방법이다. 이런 단계들은 건너뛰고 Spring Cloud DataFlow를 사용해 배포하고 싶다면 [Spring Cloud Data Flow를 이용한 스트림 처리](../stream-developer-guides.stream-development.stream-processing)를 읽어봐라.

이 세 가지 애플리케이션(`UsageDetailSender`, `UsageCostProcessor`, `UsageCostLogger`)을 배포하면 만들어지는 파이프라인에선 다음과 같은 메시지 플로우를 가진다:

```text
UsageDetailSender -> UsageCostProcessor -> UsageCostLogger
```

`UsageDetailSender` 소스 애플리케이션의 `Supplier` 출력은 `UsageCostProcessor` 프로세서 애플리케이션의 `Function` 입력에 연결된다. `UsageCostProcessor` 애플리케이션의 `Function` 출력은 `UsageCostLogger` 싱크 애플리케이션의 `Consumer` 입력에 연결된다.

이 애플리케이션들을 실행하면, 설정해둔 메세지 바인더가 설정 입출력을 메세지 브로커의 설정 목적지(exchange, 큐, 토픽)에 바인딩한다. 이때 반드시 메세지 브로커는 실행 중이어서 애플리케이션 런타임 환경에 액세스할 수 있어야 한다. Spring Cloud Stream은 기존 리소스를 사용하거나 필요하다면 리소스를 프로그래밍 방식으로 생성한다.

자세한 배포 가이드를 확인하려면 아래 배포 플랫폼 중 하나를 선택해라:

- [로컬](../stream-developer-guides.stream-development.stream-application-deployment.local)
- [쿠버네티스](../stream-developer-guides.stream-development.stream-application-deployment.kubernetes)
- [클라우드 파운드리](../stream-developer-guides.stream-development.stream-application-deployment.cloud-foundry)
