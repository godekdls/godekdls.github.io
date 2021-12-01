---
title: Batch Processing
category: Spring Cloud Data Flow
order: 20
permalink: /Spring%20Cloud%20Data%20Flow/concepts.batch-processing/
description: 배치 처리를 위한 프레임워크 Spring Cloud Task 소개
image: ./../../images/springclouddataflow/SCDF-task-orchestration.webp
lastmod: 2021-12-02T00:33:00+09:00
comments: true
originalRefName: 스프링 클라우드 데이터 플로우
originalRefLink: https://dataflow.spring.io/docs/concepts/batch-jobs/
parent: Concepts
parentUrl: /Spring%20Cloud%20Data%20Flow/concepts/
---

---

배치 처리는 상호 작용이나 개입 없이 유한한 양의 데이터를 처리하는 것으로 정의된다. 배치 처리를 구현한 애플리케이션은 ephemeral 또는 short-lived 앱이라고 일컫는다. 배치 처리를 예로 들면 청구 애플리케이션이 있다. 다음은 이 배치 애플리케이션을 도식화한 이미지다:

![Batch App Flow](./../../images/springclouddataflow/batch-app-flow.webp)

이 애플리케이션은 밤마다 flat 파일에서 고객의 사용 데이터를 읽어와 가격 정보를 생성하고 청구 정보를 청구 테이블에 삽입한다. 이 앱은 사용 데이터를 모두 읽고 가격을 책정해 그 결과를 청구 테이블에 삽입하고 나면 중지된다.

꽤 간단한듯 보이지만 데이터베이스의 테이블 공간이 부족해서 6시간 동안 실행돼야 하는 배치 앱이 4시간만에 실패한다면 어떻게 될지도 생각해봐야 한다. 테이블 공간을 더 추가한 뒤에는 배치 처리를 맨처음부터 다시 시작하고 싶진 않을 거다. 따라서 청구 애플리케이션에는 중단됐던 곳에서부터 재시작할 수 있는 기능이 필요하다.

### 목차

- [Spring Batch](#spring-batch)
- [Running Batch Apps in the Cloud](#running-batch-apps-in-the-cloud)
- [Orchestrating Batch apps](#orchestrating-batch-apps)
- [Next Steps](#next-steps)

---

## Spring Batch

앞에서는 배치 청구 애플리케이션에 필요한 최소한의 요구 사항만 언급했다. 하지만 재시작 기능이나 reader와 writer를 만들기 전에 먼저 스프링 배치를 살펴보는 게 좋다. 스프링 배치는 로깅, 트레이싱, 트랜잭션 관리, job 처리 통계, job 재시작, 스킵, 리소스 관리를 포함하는 대용량 레코드 처리에 필수적인 기능들을 재사용할 수 있는 형태로 제공한다. 스프링 배치에선 `Batch Job` 재시작 로직을 처리해주고, `FlatFileItemReader`와 `JdbcBatchItemWriter`를 제공하기 때문에 이런 보일러플레이트 코드를 직접 작성할 필요가 없다. 덕분에 사용 데이터로 가격을 책정한다는 비즈니스 로직에 집중할 수 있다.

---

## Running Batch Apps in the Cloud

이제 스프링 배치를 이용하면 배치 애플리케이션을 매우 간단하게 작성할 수 있다는 건 알게 됐는데, 배치 애플리케이션을 클라우드 환경에서 실행할 땐 또 어떨까? 클라우드 파운드리와 쿠버네티스에는 애플리케이션을 ephemeral(short-lived) 형식으로 실행한다는 개념이 있다. 클라우드 파운드리에선 이런 ephemeral 앱을 태스크로, 쿠버네티스는 job으로 표현한다. 하지만 클라우드 환경에서 ephemeral 앱을 실행하려면 몇 가지 기본 기능들이 필요하다:

- 애플리케이션이 시작한 시각과 중지된 시각을 기록한다.
- 애플리케이션의 종료 코드를 기록한다.
- 애플리케이션이 반환한 종료 메세지나 에러 메세지를 기록한다.
- 이미 실행 중인 애플리케이션은 실행을 방지할 수 있다.
- 애플리케이션이 특정한 처리 단계에 들어갔음을 다른 앱들에 통지할 수 있다.

꽤 일이 많은 것처럼 들리겠지만, Spring Cloud Task는 여기 있는 것들을 전부 다 해준다. Spring Cloud Task를 사용하면 short-lived 마이크로서비스들을 개발하고 로컬이나 클라우드 환경에서 실행할 수 있다. 개발자는 `@EnableTask` 애노테이션을 추가하는 게 전부다.

---

## Orchestrating Batch apps

다음은 Data Flow Server가 여러 가지 앱들을 여러 클라우드에서 관리하는 방법을 알 수 있는 이미지다:

![Data Flow Task Orchestration](./../../images/springclouddataflow/SCDF-task-orchestration.webp)

스프링 배치나 Spring Cloud Task로 배치 애플리케이션을 작성했다면, 이제 애플리케이션 실행은 어떻게 오케스트레이션할 수 있을까? Spring Cloud Data Flow가 도움을 줄 수 있는 지점이 바로 여기다. Spring Cloud Data Flow를 사용하면 애드혹 요청이나 배치 job 스케줄러를 통해 배치 애플리케이션을 시작할 수 있다. 또한 배치 애플리케이션은 아래와 같은 플랫폼에서 시작할 수 있다:

- 클라우드 파운드리
- 쿠버네티스
- 로컬 서버

Spring Cloud Data Flow를 통하면 UI나 RESTful API, Spring Cloud Data Flow 쉘을 통해 배치 앱을 실행하거나 실행을 예약할 수 있다.

---

## Next Steps

미리 빌드돼 있는 애플리케이션을 사용해 배치 처리 데이터 파이프라인을 생성하는데 관심이 있다면 [배치 시작 가이드](../batch-developer-guides.getting-started)를 읽어봐라.

첫 번째 커스텀 배치 애플리케이션을 작성하고 배포해보고 싶다면 [배치 개발자 가이드](../batch-developer-guides.batch-development)를 읽어봐라.