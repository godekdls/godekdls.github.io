---
title: Reference Documentation
category: Spring Cloud Data Flow
order: 107
permalink: /Spring%20Cloud%20Data%20Flow/resources.reference-docs/
description: Spring Cloud Data Flow 관련 레퍼런스 가이드 모음
image: ./../../images/springclouddataflow/logo.png
lastmod: 2021-12-08T01:00:00+09:00
comments: true
originalRefName: 스프링 클라우드 데이터 플로우
originalRefLink: https://dataflow.spring.io/docs/resources/reference-docs/
parent: Resources
parentUrl: /Spring%20Cloud%20Data%20Flow/resources/
---

---

Data Flow 사용법을 익히려면 이 페이지에서 시작하면 된다. 각 레퍼런스 가이드는 다양한 Data Flow 관련 분야(ex. 보안)를 사용하고 설정하는 방법을 자세히 담고 있다.

이 페이지에서도 원하는 정보를 찾지 못했다면 [Spring Cloud Data Flow 레퍼런스 가이드](https://docs.spring.io/spring-cloud-dataflow/docs/current/reference/htmlsingle/)를 확인해봐라.

아래 프로젝트들은 스트리밍/배치 데이터 처리 유스 케이스를 처리하는 데 필요한 핵심 프로젝트들이다. 이 프로젝트들은 모두 백로그와, 우선 순위, 릴리즈 케이던스<sup>cadence</sup>를 따로 관리하며, 개별적으로 업데이트된다. 하지만 Spring Cloud Data Flow는 하나의 제품으로서, 이 프로젝트들을 함께 모아 개발자 경험을 한 곳으로 통합한다. 따라서 이 프로젝트들을 광범위하게 지칭할 땐 "Spring Cloud Data Flow Ecosystem"이라고 부른다.

| Name                                                         | Description                                                  | Documentation                                                |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| [Spring Cloud Stream](https://spring.io/projects/spring-cloud-stream) | 메세징 미들웨어를 통해 서로 통신하는, 이벤트 기반 스프링 부트 마이크로서비스. | [레퍼런스 가이드](https://cloud.spring.io/spring-cloud-static/spring-cloud-stream/2.2.1.RELEASE/home.html) |
| [Spring Cloud Task](https://spring.io/projects/spring-cloud-task) | 데이터베이스에 태스크 실행 정보를 저장하는 short-lived 스프링 부트 마이크로서비스. | [레퍼런스 가이드](https://docs.spring.io/spring-cloud-task/docs/2.3.3/reference/html) |
| [Spring Cloud Skipper](https://cloud.spring.io/spring-cloud-skipper/) | 다양한 클라우드 플랫폼에서 Spring Cloud Stream 애플리케이션의 blue/green 배포를 관리한다. | [레퍼런스 가이드](https://docs.spring.io/spring-cloud-skipper/docs/2.8.1/reference/htmlsingle/#getting-started) |
| [Spring Cloud Stream App Starters](https://cloud.spring.io/spring-cloud-stream-app-starters/) | 흔히 필요한 실시간 스트리밍 유스 케이스들을 위한 Spring Cloud Stream 기반 애플리케이션 모음. | [레퍼런스 가이드](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/) |
| [Spring Cloud Task App Starters](https://cloud.spring.io/spring-cloud-task-app-starters/) | 흔히 필요한 배치 유스 케이스들을 위한 Spring Cloud Task 기반 애플리케이션 모음. | [레퍼런스 가이드](https://docs.spring.io/spring-cloud-task-app-starters/docs/Elston.RELEASE/reference/htmlsingle/) |