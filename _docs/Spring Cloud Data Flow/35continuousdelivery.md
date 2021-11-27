---
title: Continuous Delivery
category: Spring Cloud Data Flow
order: 35
permalink: /Spring%20Cloud%20Data%20Flow/stream-developer-guides.continuous-delivery/
description: 스트리밍 애플리케이션으로 continuous delivery 달성하기
image: ./../../images/springclouddataflow/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 클라우드 데이터 플로우
originalRefLink: https://dataflow.spring.io/docs/stream-developer-guides/continuous-delivery/
parent: Stream Developer guides
parentUrl: /Spring%20Cloud%20Data%20Flow/stream-developer-guides/
subparent: Continuous Delivery
isSubparent: true
subparentUrl: /Spring%20Cloud%20Data%20Flow/stream-developer-guides.continuous-delivery/
priority: 0.3
---

---

이벤트 스트리밍 파이프라인을 구성하는 애플리케이션은 [feature toggle](https://en.wikipedia.org/wiki/Feature_toggle) 활성화나 버그 수정같은 변경 사항을 자율적으로 반영할 수 있다. 중간에 스트림 처리가 중단되지 않게 하려면, 전체 데이터 파이프라인에는 영향을 주지 않으면서 이런 변경 사항들을 필요한 애플리케이션에 업데이트하거나 롤백하는 게 중요하다.

Spring Cloud Data Flow는 이벤트 스트리밍 애플리케이션의 continuous deployment를 기본으로 지원한다. Spring Cloud Data Flow의 애플리케이션 레지스트리를 이용하면, 하나의 이벤트 스트리밍 애플리케이션에 여러 가지 버전을 등록할 수 있다. 덕분에 프로덕션에서 실행 중인 이벤트 스트리밍 파이프라인을 업데이트할 땐, 애플리케이션을 특정 버전으로 전환하거나, 이벤트 스트리밍 파이프라인을 구성하고 있는 애플리케이션들에서 원하는 설정 프로퍼티를 변경할 수 있다.

이번 섹션에선 몇 가지 예를 통해 스트리밍 애플리케이션으로 continuous delivery를 달성하는 법을 다룬다.

> [Continuous Delivery of streaming applications](../stream-developer-guides.continuous-delivery.streaming-applications)
>
> 스트리밍 애플리케이션의 Continuous Delivery