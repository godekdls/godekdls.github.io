---
title: Continuous Deployment
category: Spring Cloud Data Flow
order: 51
permalink: /Spring%20Cloud%20Data%20Flow/batch-developer-guides.continuous-deployment/
description: 태스크 애플리케이션으로 continuous deployment 달성하기
image: ./../../images/springclouddataflow/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 클라우드 데이터 플로우
originalRefLink: https://dataflow.spring.io/docs/batch-developer-guides/continuous-deployment/
parent: Batch Developer guides
parentUrl: /Spring%20Cloud%20Data%20Flow/batch-developer-guides/
subparent: Continuous Deployment
isSubparent: true
subparentUrl: /Spring%20Cloud%20Data%20Flow/batch-developer-guides.continuous-deployment/
priority: 0.3
---

---

Spring Cloud Data Flow는 태스크 애플리케이션의 continuous deployment를 기본으로 지원한다.

Spring Cloud Data Flow의 애플리케이션 레지스트리를 이용하면 하나의 태스크 애플리케이션에 여러 가지 버전을 등록할 수 있다.

태스크 애플리케이션을 기동할 땐 사용하고 싶은 애플리케이션의 버전을 고를 수 있다. 같은 태스크를 이전에 실행했을때 사용했던 배포 프로퍼티를 재사용하거나 업데이트할 수도 있다.

이번 섹션에선 몇 가지 예를 통해 태스크 애플리케이션으로 continuous deployment를 달성하는 법을 다룬다.

> [Continuous Deployment of task applications](../batch-developer-guides.continuous-deployment.task-applications)
>
> SCDF에서 태스크의 Continuous Deployment를 달성하는 방법을 논한다