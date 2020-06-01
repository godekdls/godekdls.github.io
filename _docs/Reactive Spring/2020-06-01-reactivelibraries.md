---
title: Reactive Libraries
category: Reactive Spring
order: 8
permalink: /Reactive%20Spring/reactivelibraries/
---

> [리액티브 스프링 공식 reference](https://docs.spring.io/spring/docs/current/spring-framework-reference/web-reactive.html#webflux-reactive-libraries)를 한글로 번역한 문서입니다.
>
> 전체 목차는 [여기](https://godekdls.github.io/Reactive%20Spring/contents/)에 있습니다.

---

`spring-webflux`는 `reactor-core`를 사용해서
비동기 로직과 리액티브 스트림을 구현한다.
웹플럭스 API는 일반적으로 `Flux`나 `Mono`를 리턴하며(내부에서 사용하기 때문에),
어떤 리액티브 스트림 `Publisher`든 입력으로 받을 수 있다.
`Flux`와 `Mono`는 카디널리티 정보에 도움이 되므로 구분해서 사용해야 한다.
— 예를 들어 비동기 값이 한 개인지 여러 개인지 결정할 수 있다
(HTTP 메세지를 인코딩 또는 디코딩 할 때 등).

컨트롤러에 애노테이션을 선언하면 웹플럭스는
어플리케이션에서 사용하는 리액티브 라이브러리 타입으로 맞춰 준다.
이건 리액티브 라이브러리나 다른 비동기 타입을 플러그인처럼 받아 주는
[`ReactiveAdapterRegistry`](https://docs.spring.io/spring-framework/docs/5.2.6.RELEASE/javadoc-api/org/springframework/core/ReactiveAdapterRegistry.html)가
있어 가능한 일이다.
이 레지스트리는 기본적으로 RxJava와 `CompletableFuture`를
지원하지만, 다른 라이브러리도 등록할 수 있다.

함수형 API([함수형 엔드포인트](https://godekdls.github.io/Reactive%20Spring/springwebflux2/#15-functional-endpoints),
`WebClient` 등)는
일반적인 웹플럭스 API와 룰이 동일하다 —
리액티브 스트림 `Publisher`를 입력으로 받고 `Flux`, `Mono`를 리턴한다. 
다른 라이브러리의 `Publisher`나 커스텀 구현체는
단순히 의미를(0..N) 알 수 없는 스트림으로 처리한다.
하지만 카디널리티를 어떻게 표현하는지 알고 있다면
`Publisher`를 그대로 사용하는 대신 `Flux`나 `Mono.from(Publisher)`로
감쌀 수 있다.

예를 들어 `Mono`가 아닌 `Publisher`가 있다면,
Jackson JSON message writer는 여러 값으로 처리한다.
미디어 타입이 끝을 알 수 없는 스트림이라면(e.g. `application/json+stream`),
따로 따로 write하고 flush한다.
그 외는 버퍼 리스트에 담았다가 JSON 배열로 만든다.

---

> 전체 목차는 [여기](https://godekdls.github.io/Reactive%20Spring/contents/)에 있습니다.
