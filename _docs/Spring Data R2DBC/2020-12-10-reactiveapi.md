---
title: Reactive API
category: Spring Data R2DBC
order: 5
permalink: /Spring%20Data%20R2DBC/reactiveapi/
description: 스프링 데이터 R2DBC가 채택한 리액티브 API, 프로젝트 리액터 소개
image: ./../../images/spring/logo.png
lastmod: 2020-12-10T12:00:00+09:00
comments: true
originalRefName: 스프링 데이터 R2DBC
originalRefLink: https://docs.spring.io/spring-data/r2dbc/docs/1.2.2/reference/html/#get-started:first-steps:reactive-api
---

---

리액티브 스트림은 컴포넌트 상호 작용에서 중요한 역할을 한다. 하지만 이건 라이브러리와 기반 구조에 사용되는 컴포넌트엔 유용해도, 어플리케이션 API에서 다루기엔 너무 저수준이다. 어플리케이션은 비동기 로직을 만들기 위한 풍부한 고수준 함수형 API가 필요하다 (자바 8 스트림 API와 비슷하지만 테이블만을 위한 게 아니다). 이게 바로 리액티브 라이브러리가 하는 일이다.

[프로젝트 리액터](https://github.com/reactor/reactor)는 스프링 데이터 R2DBC가 선택한 리액티브 라이브러리다. 리액터는 [`Mono`](https://projectreactor.io/docs/core/release/api/reactor/core/publisher/Mono.html)와 [`Flux`](https://projectreactor.io/docs/core/release/api/reactor/core/publisher/Flux.html) API 타입을 제공한다. ReactiveX [vocabulary of operators](http://reactivex.io/documentation/operators.html)에 정리된 풍부한 연산자를 사용해 데이터 시퀀스를 **0~1**개는 `Mono`, **0~N**개는 `Flux`로 표현할 수 있다. 리액터는 리액티브 스트림 라이브러리이기 때문에 모든 연산자는 논블로킹 back pressure를 지원한다. 리액터는 특히 서버 사이드 자바에 초점을 두고 스프링과 긴밀히 협력해서 개발됐다.

스프링 데이터 R2DBC는 프로젝트 리액터를 핵심 라이브러리로 사용하지만, 다른 리액티브 라이브러리를 써도 리액티브 스트림 스펙으로 상호작용할 수 있다. 스프링 데이터 R2DBC 레포지토리의 일반적인 룰은, 순수한 `Publisher`를 입력으로 받아 내부적으로 리액터 타입으로 맞추고, 이걸 사용해서 `Mono`나  `Flux`를 반환한다. 따라서 어떤 `Publisher`든 입력으로 전달하고 연산할 수 있지만, 다른 리액티브 라이브러리를 사용하려면 출력 형식을 맞춰줘야 한다. 스프링 데이터는 가능만 하다면 투명한 방식으로 RxJava나 다른 리액티브 라이브러리에 맞게 바꿔준다.