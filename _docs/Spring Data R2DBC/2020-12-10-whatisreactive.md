---
title: What is Reactive?
category: Spring Data R2DBC
order: 4
permalink: /Spring%20Data%20R2DBC/whatisreactive/
description: 스프링 데이터 R2DBC를 사용하기 앞서 필요한 리액티브 기본 개념
image: ./../../images/spring/logo.png
lastmod: 2020-12-19T23:00:00+09:00
comments: true
originalRefName: 스프링 데이터 R2DBC
originalRefLink: https://docs.spring.io/spring-data/r2dbc/docs/1.2.2/reference/html/#get-started:first-steps:reactive
---

---

“리액티브”라는 용어는 변화, 가용성, 처리 가능 상태(processability)에 반응하는 것을 중심에 두고 만든 프로그래밍 모델을 의미한다 (I/O 이벤트에 반응하는 네트워크 컴포넌트, 마우스 이벤트에 반응하는 UI 컨트롤러, 가용성을 확보하는 리소스 등). 논블로킹은 작업을 기다리기보단 완료되거나 데이터를 사용할 수 있게 되면 반응하므로, 이 말대로면 논블로킹도 리액티브다.

스프링은 “리액티브”와 관련한 중요한 메커니즘이 하나 더 있는데, 논블로킹 back pressure다. 동기식 명령형(imperative) 코드에서 블로킹 호출은 호출자를 강제로 기다리게 하는 일종의 back pressure다. 논블로킹 코드에선, 프로듀셔 속도가 컨슈머 속도를 압도하지 않도록 이벤트 속도를 제어한다.

[리액티브 스트림은 간단한 스펙](https://github.com/reactive-streams/reactive-streams-jvm/blob/v1.0.3/README.md#specification)으로, back pressure를 통한 비동기 컴포넌트 간의 상호작용을 정의한다 ([자바 9에서도 채택했다](https://docs.oracle.com/javase/9/docs/api/java/util/concurrent/Flow.html)). 예를 들어 데이터 레포지토리([`Publisher`](https://www.reactive-streams.org/reactive-streams-1.0.3-javadoc/org/reactivestreams/Publisher.html) 역할)가 데이터를 만들고, HTTP 서버([`Subscriber`](https://www.reactive-streams.org/reactive-streams-1.0.3-javadoc/org/reactivestreams/Subscriber.html`) 역할)로 이 데이터로 요청을 처리할 수 있다. 리액티브 스트림을 쓰는 주목적은 subscriber가 publisher의 데이터 생산 속도를 제어하는 것이다.