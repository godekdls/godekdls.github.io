---
title: Batch Development
category: Spring Cloud Data Flow
order: 43
permalink: /Spring%20Cloud%20Data%20Flow/batch-developer-guides.batch-development/
description: Spring Cloud Task, Spring Batch 애플리케이션을 개발하고 Spring Cloud Data Flow를 이용해 배포해보기
image: ./../../images/springclouddataflow/logo.png
lastmod: 2021-12-02T00:33:00+09:00
comments: true
originalRefName: 스프링 클라우드 데이터 플로우
originalRefLink: https://dataflow.spring.io/docs/batch-developer-guides/batch/
parent: Batch Developer guides
parentUrl: /Spring%20Cloud%20Data%20Flow/batch-developer-guides/
subparent: Batch Development
isSubparent: true
subparentUrl: /Spring%20Cloud%20Data%20Flow/batch-developer-guides.batch-development/
priority: 0.3
---

---

이번 섹션에선 Spring Cloud Task 애플리케이션과 스프링 배치 애플리케이션을 만들기 위한 기본기를 다룬다 (이 애플리케이션들은 독립형으로 배포하거나 Spring Cloud Data Flow를 이용해 클라우드 파운드리나, 쿠버네티스, 로컬 인스턴스에 배포할 수 있다).

이 섹션에선 애플리케이션을 실행해 고객을 위한 청구서를 생성해야 하는 휴대폰 회사를 샘플 비즈니스 사례로 다룬다. 이 비지니스 사례를 두 가지 애플리케이션, 데이터베이스를 준비하는 애플리케이션과 청구서를 생성하는 애플리케이션으로 다뤄보겠다.

> [Simple Task](../batch-developer-guides.batch-development.simple-task)
>
> Spring Cloud Task를 이용해 간단한 스프링 부트 애플리케이션을 만들어본다

> [Spring Batch Jobs](../batch-developer-guides.batch-development.spring-batch-jobs)
>
> 스프링 배치 Job을 만들어본다

> [Register and Launch a Spring Cloud Task application using Data Flow](../batch-developer-guides.batch-development.data-flow-simple-task)
>
> Data Flow를 이용해 Spring Cloud Task 애플리케이션을 등록하고 기동시켜본다

> [Register and launch a Spring Batch application using Data Flow](../batch-developer-guides.batch-development.data-flow-spring-spring)
>
> Data Flow를 이용해 스프링 배치 애플리케이션을 등록하고 기동시켜본다

> [Create and launch a Composed Task using Data Flow](../batch-developer-guides.batch-development.data-flow-composed-task)
>
> Data Flow를 이용해 Composed Task를 생성하고 기동시켜본다

> [Deploying a task application on Kubernetes with Data Flow](../batch-developer-guides.batch-development.data-flow-simple-task-kubernetes)
>
> Spring Cloud Data Flow를 이용해 쿠버네티스에 spring-cloud-stream-task 애플리케이션을 배포하는 방법을 가이드한다

> [Deploying a task application on Cloud Foundry using Spring Cloud Data Flow](../batch-developer-guides.batch-development.data-flow-simple-task-cloudfoundry)
>
> Spring Cloud Data Flow를 이용해 클라우드 파운드리에 spring-cloud-stream-task 애플리케이션을 배포하는 방법을 가이드한다