---
title: Stream Developer guides
category: Spring Cloud Data Flow
order: 23
permalink: /Spring%20Cloud%20Data%20Flow/stream-developer-guides/
description: 스트림 개발자 가이드 개요
image: ./../../images/springclouddataflow/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 클라우드 데이터 플로우
originalRefLink: https://dataflow.spring.io/docs/stream-developer-guides/
parent: Stream Developer guides
isParent: true
parentUrl: /Spring%20Cloud%20Data%20Flow/stream-developer-guides/
priority: 0.3
---

---

이번 섹션에는 여러 가지 가이드가 있지만, 일반적으론 다음과 같이 시작하면 된다:

1. **미리 빌드된 애플리케이션들**을 이용해 Data Flow를 사용하는 스트림을 만들고 배포하는 법을 안내하는 Getting Started 가이드를 읽어봐라. 이 가이드를 따라해보고 나면 대시보드를 통해 스트림을 생성하고, 배포하고, 로그를 살펴보는 법을 빠르게 파악할 수 있다.
2. Spring Cloud Stream으로 자체 소스, 프로세서, 싱크 애플리케이션을 개발하고, 플랫폼에 수동으로 배포해본 뒤, 메세지 브로커(RabbitMQ와 Apache Kafka)에서 무슨 일이 일어나고 있는지 자세히 파고들어봐라.
3. 개발한 소스, 프로세서, 싱크 애플리케이션을 가져와서 Data Flow를 사용해 스트림을 생성하고 플랫폼에 배포해봐라. 이렇게 시도해보면 Data Flow가 처리해주는 전체적인 개발/배포 워크플로를 완전히 수동으로 개발/배포하는 방식과 비교할 수 있어 더 명확하게 파악된다.

### [Getting Started](../stream-developer-guides.getting-started)

> [Stream Processing](../stream-developer-guides.getting-started.stream-processing)
> 
> 미리 빌드된 애플리케이션들을 이용해 로컬 머신에서 스트리밍 데이터 파이프라인을 생성하고 배포해본다

### [Stream Development](../stream-developer-guides.stream-development)

> [Stream Application Development](../stream-developer-guides.stream-development.stream-application-development)
>
> 스트림 처리를 위한 자체 마이크로서비스를 생성하고 수동으로 배포해본다

> [Stream Application Deployment](../stream-developer-guides.stream-development.stream-application-deployment)
>
> 샘플 스트림 애플리케이션들을 배포해본다
> 
> - [Deploy sample stream applications to local host](../stream-developer-guides.stream-development.stream-application-deployment.local)<br>스트림 애플리케이션을 로컬 호스트에 배포해본다
> - [Deploy sample stream applications to Kubernetes](../stream-developer-guides.stream-development.stream-application-deployment.kubernetes)<br>스트림 애플리케이션을 쿠버네티스에 배포해본다
>- [Deploy sample stream applications to Cloud Foundry](../stream-developer-guides.stream-development.stream-application-deployment.cloud-foundry)<br>스트림 애플리케이션을 클라우드 파운드리에 배포해본다

> [Stream Processing using Spring Cloud Data Flow](../stream-developer-guides.stream-development.stream-processing)
>
> Spring Cloud Data Flow를 이용해서 스트림 처리 파이프라인을 생성하고 배포해본다

> [Spring Application Development on other Messaging Middleware](../stream-developer-guides.stream-development.stream-other-binders)
>
> Google Pub/Sub, Amazon Kinesis, Solace JMS같은 다른 메세징 미들웨어를 사용해 스트림 처리를 위한 자체 마이크로서비스를 만들어본다

### [Programming Models](../stream-developer-guides.programming-models)

> [Programming Models](../stream-developer-guides.programming-models)
> 
> 프로그래밍 모델

### [Continuous Delivery](../stream-developer-guides.continuous-delivery/)

> [Continuous Delivery of streaming applications](../stream-developer-guides.continuous-delivery.streaming-applications)
>
> 스프리밍 애플리케이션의 Continuous Delivery

### [Troubleshooting](../stream-developer-guides.troubleshooting)

> [Debugging Stream Applications](../stream-developer-guides.troubleshooting.debugging-stream-applications)
> 
> Data Flow 없이 스트림 애플리케이션을 디버깅해본다

> [Debugging Stream applications deployed by Data Flow](../stream-developer-guides.troubleshooting.debugging-stream-applications-in-data-flow)
> 
> Data Flow를 이용한 스트림 배포 절차를 디버깅해본다