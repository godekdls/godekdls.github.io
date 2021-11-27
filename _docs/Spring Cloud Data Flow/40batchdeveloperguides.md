---
title: Batch Developer guides
category: Spring Cloud Data Flow
order: 40
permalink: /Spring%20Cloud%20Data%20Flow/batch-developer-guides/
description: 배치 개발자 가이드 개요
image: ./../../images/springclouddataflow/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 클라우드 데이터 플로우
originalRefLink: https://dataflow.spring.io/docs/batch-developer-guides/
parent: Batch Developer guides
isParent: true
parentUrl: /Spring%20Cloud%20Data%20Flow/batch-developer-guides/
priority: 0.3
---

---

이번 섹션에는 여러 가지 가이드가 있지만, 일반적으론 다음과 같이 시작하면 된다:

1. Spring Cloud Data Flow를 이용해 **미리 빌드된 애플리케이션**들로 태스크를 만들고 배포하는 법을 안내하는 Getting Started 가이드를 읽어봐라. 이 가이드를 따라해보고 나면 대시보드를 통해 태스크를 생성하고, 실행하고, 로그를 살펴보는 법을 빠르게 파악할 수 있다.
2. Spring Cloud Task로 자체 태스크를 개발하고, 플랫폼에 수동으로 배포해본 뒤, 그 플랫폼에서 무슨 일이 일어나고 있는지 자세히 파고들어봐라.
4. 개발한 태스크 애플리케이션을 가져와 Spring Cloud Data Flow에 등록하고 플랫폼에 배포해봐라.

### [Getting Started](../batch-developer-guides.getting-started)

> [Task Processing](../batch-developer-guides.getting-started.task-processing)
>
> 미리 빌드된 태스크 애플리케이션을 이용해 로컬 머신에서 간단한 태스크 파이프라인을 생성하고 배포해본다

### [Batch Development](../batch-developer-guides.batch-development)

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

### [Continuous Deployment](../batch-developer-guides.continuous-deployment)

> [Continuous Deployment of task applications](../batch-developer-guides.continuous-deployment.task-applications)
>
> SCDF에서 태스크의 Continuous Deployment를 달성하는 방법을 논한다

### [Troubleshooting](../batch-developer-guides.troubleshooting)

> [Debugging Batch applications](../batch-developer-guides.troubleshooting.task-apps)
>
> 배치 애플리케이션을 디버깅해본다

> [Debugging Batch applications deployed by Data Flow](../batch-developer-guides.troubleshooting.scdf-tasks)
>
> Data Flow로 배포한 배치 애플리케이션을 디버깅해본다
