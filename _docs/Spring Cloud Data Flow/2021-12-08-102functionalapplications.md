---
title: Functional Applications
category: Spring Cloud Data Flow
order: 102
permalink: /Spring%20Cloud%20Data%20Flow/recipes.functional-apps/
description: functional 기능 관련 레시피 모음집
image: ./../../images/springclouddataflow/logo.png
lastmod: 2021-12-08T01:00:00+09:00
comments: true
originalRefName: 스프링 클라우드 데이터 플로우
originalRefLink: https://dataflow.spring.io/docs/recipes/functional-apps/
parent: Recipes
parentUrl: /Spring%20Cloud%20Data%20Flow/recipes/
subparent: Functional Applications
isSubparent: true
subparentUrl: /Spring%20Cloud%20Data%20Flow/recipes.functional-apps/
priority: 0.3
---

---

Spring Cloud Stream 3.x부터는 [functional 기능](https://cloud.spring.io/spring-cloud-static/spring-cloud-stream/current/reference/html/spring-cloud-stream.html#spring-cloud-stream-overview-producing-consuming-messages)이 추가돼서, Java Util의 `Supplier`, `Consumer`, `Function` 인터페이스를 구현해주기만 하면 각각 `Source`, `Sink`, `Processor` 애플리케이션을 만들 수 있다.

Spring Cloud Stream은 [피쳐 가이드](../feature-guides.stream.function-composition)에서 설명하고 있는 function composition도 지원한다.

> [Functional Applications](../recipes.functional-apps.scst-function-bindings)
>
> Spring Cloud Stream 함수형 애플리케이션 설정하기