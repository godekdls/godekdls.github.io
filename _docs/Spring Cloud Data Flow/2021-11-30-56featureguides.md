---
title: Feature guides
category: Spring Cloud Data Flow
order: 56
permalink: /Spring%20Cloud%20Data%20Flow/feature-guides/
description: Data Flow 기능 셋 가이드
image: ./../../images/springclouddataflow/logo.png
lastmod: 2021-12-02T00:33:00+09:00
comments: true
originalRefName: 스프링 클라우드 데이터 플로우
originalRefLink: https://dataflow.spring.io/docs/feature-guides/
parent: Feature guides
isParent: true
parentUrl: /Spring%20Cloud%20Data%20Flow/feature-guides/
priority: 0.3
---

---

Data Flow는 다양한 기능 셋을 제공하기 때문에, 원하는 기능을 선택해 가지고 있는 유스 케이스의 요구 사항을 해결할 수 있다. 이 가이드에선 스트림과 배치 처리에서 가장 흔하게 쓰이는 기능 셋들의 사용법을 다룬다.

### [General](../feature-guides.general)

> [Server Monitoring](../feature-guides.general.server-monitoring)
>
> Data Flow와 Skipper 서버 모니터링하기

### [Streams](../feature-guides.stream)

> [Deployment Properties](../feature-guides.stream.deployment-properties)
>
> 배포 프로퍼티를 재정의해 스트림 배포 시작하기

> [Composing Functions](../feature-guides.stream.function-composition)
>
> 기존 Spring Cloud Stream 애플리케이션에서 데이지 체인<sup>Daisy-chain</sup> 자바 함수 사용하기

> [Named Destinations](../feature-guides.stream.named-destinations)
>
> 목적지에 이름을 지정해서 토픽/큐와 직접 상호 작용하기

> [Stream Monitoring](../feature-guides.stream.monitoring)
>
> 프로메테우스와 InfluxDB를 이용해 스트리밍 데이터 파이프라인 모니터링하기

> [Stream Distributed Tracing](../feature-guides.stream.tracing)
>
> 스트리밍 데이터 파이프라인 추적하기

> [Stream Application DSL](../feature-guides.stream.stream-application-dsl)
>
> 스트림 애플리케이션 DSL 사용 가이드

> [Labeling Applications](../feature-guides.stream.labels)
>
> 상호 작용할 애플리리케이션을 구분하기 위한 스트림 애플리케이션 레이블 활용법

> [Application Count](../feature-guides.stream.application-count)
>
> 여러 개의 애플리케이션 인스턴스로 스트림 배포 시작하기

> [Fan-in and Fan-out](../feature-guides.stream.fanin-fanout)
>
> fan-in, fan-out 기능을 이용해 여러 목적지에 데이터를 게시하고 구독하기

> [Data Partitioning](../feature-guides.stream.partitioning)
>
> stateful 스트리밍 데이터 파이프라인을 구축하기 위한 데이터 파티셔닝 상세 활용 가이드

> [Scaling](../feature-guides.stream.scaling)
>
> Spring Cloud Data Flow로 스트리밍 데이터 파이프라인 확장하기

> [Stream Java DSL](../feature-guides.stream.java-dsl)
>
> 자바 DSL을 이용해서 코드로 스트림 생성하기

> [Tapping a Stream](../feature-guides.stream.taps)
>
> 데이터 처리를 중단하지 않고 특정 스트림에서 다른 스트림 생성하기

### [Batch](../feature-guides.batch)

> [Deployment Properties](../feature-guides.batch.deployment-properties)
>
> 배포 프로퍼티를 재정의해 배치 배포 시작하기

> [Scheduling Batch Jobs](../feature-guides.batch.scheduling)
>
> 배치 Job 스케줄링 가이드

> [Remote Partitioned Batch Job](../feature-guides.batch.partitioning)
>
> 배치 Job을 위한 파티셔닝 상세 가이드

> [Task Monitoring](../feature-guides.batch.monitoring)
>
> InfluxDB를 이용해 태스크 데이터 파이프라인 모니터링하기

> [Restarting Batch Jobs](../feature-guides.batch.restarting)
>
> 배치 Job 재시작 가이드

> [Composed Tasks](../feature-guides.batch.composed-task)
>
> composed 태스크 생성법과 관리 방법 가이드

> [Task Java DSL](../feature-guides.batch.java-dsl)
>
> 자바 DSL을 이용해서 코드로 태스크 생성하기