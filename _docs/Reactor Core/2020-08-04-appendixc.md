---
title: Appendix C Reactor-Extra
category: Reactor Core
order: 13
permalink: /Reactor%20Core/appendixcreactorextra/
description: 리액터 유틸리티 모듈 가이드를 한글로 번역했습니다.
image: ./../../images/reactorcore/gs-transform.png
lastmod: 2020-08-04T19:07:00+09:00
comments: true
---

> [프로젝트 리액터 코어 공식 레퍼런스](https://projectreactor.io/docs/core/release/reference/#reactor-extra)를 한글로 번역한 문서입니다.
>
> 전체 목차는 [여기](../contents/)에 있습니다.

{% include adsense.html %}

### 목차

- [C.1. `TupleUtils` and Functional Interfaces](#c1-tupleutils-and-functional-interfaces)
- [C.2. Math Operators With `MathFlux`](#c2-math-operators-with-mathflux)
- [C.3. Repeat and Retry Utilities](#c3-repeat-and-retry-utilities)
- [C.4. Schedulers](#c4-schedulers)

---

`reactor-extra` 아티팩트에는 `reactor-core`를 심도 있게 사용하는 사용자를 위한 추가 연산자와 유틸리티가 있다.

이건 별도의 아티팩트이므로 명시적으로 빌드에 추가해 줘야 한다. 다음은 그래들을 사용한 예제다:

```groovy
dependencies {
     compile 'io.projectreactor:reactor-core'
     compile 'io.projectreactor.addons:reactor-extra' // (1)
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 코어와는 별도로 reactor extra 아티팩트를 추가한다. 메이븐 등에서 BOM을 사용하면 버전을 명시하지 않아도 된다. 자세한 이유는 [Getting Reactor](../gettingstarted#24-getting-reactor)를 참고하라.</small>

---

## C.1. `TupleUtils` and Functional Interfaces

`reactor.function` 패키지에 있는 함수형 인터페이스는 값을 3~8개도 받을 수 있기 때문에 자바 8의 `Function`, `Predicate`, `Consumer` 인터페이스를 보강해 준다.

`TupleUtils`에 있는 스태틱 메소드는 이 함수형 인터페이스를 그에 맞는 `Tuple`의 유사한 인터페이스로 연결해준다.

이를 사용하면 다음 예제처럼 `Tuple` 관련 코드를 생략할 수 있다:

```java
.map(tuple -> {
  String firstName = tuple.getT1();
  String lastName = tuple.getT2();
  String address = tuple.getT3();

  return new Customer(firstName, lastName, address);
});
```

위 코드는 아래처럼 작성할 수 있다:

```java
.map(TupleUtils.function(Customer::new)); // (1)
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> (`Customer` 생성자는 함수형 인터페이스 `Function3`의 시그니처와 일치하므로)</small>

---

## C.2. Math Operators With `MathFlux`

`reactor.math` 패키지엔 `Flux`에 특화된 수학 연산자 `max`, `min`, `sumInt`, `averageDouble` 등을 제공하는 `MathFlux`가 있다.

---

## C.3. Repeat and Retry Utilities

`reactor.retry` 패키지엔 `Flux#repeatWhen`과 `Flux#retryWhen` 함수 작성을 도와주는 유틸리티가 있다. 각 진입점은 `Repeat`과 `Retry` 인터페이스의 팩토리 메소드다.

두 인터페이스는 해당 연산자에서 사용하는 `Function` 시그니처를 구현하고 있기 때문에 상태를 저장하는 빌더로 활용할 수 있다.

3.2.0 버전부터 메인 아티팩트 `reactor-core`에서도 이 유틸리티에서 제공하던 고급 재시도 전략 중 하나를 제공한다. `Flux#retryBackoff` 연산자로 [Exponential backoff](../appendixbfaqbestpracticesandhowdoi/#b5-how-can-i-use-retrywhen-for-exponential-backoff)을 적용할 수 있다.

3.3.4 버전부터는 코어에서  `Retry` 빌더를 제공하며, `RetrySignal` 기반으로 몇 가지를 더 커스텀할 수 있다. `RetrySignal`은 오류 외에도 다른 상태를 더 캡슐화하고 있는 인터페이스다.

---

## C.4. Schedulers

Reactor-extra는 몇 가지 특화된 스케줄러를 제공한다:

- `ForkJoinPoolScheduler` (`reactor.scheduler.forkjoin` 패키지): 태스크를 실행할 때 자바 `ForkJoinPool`을 사용한다.
- `SwingScheduler` (`reactor.swing` 패키지): 태스크를 스윙 UI 이벤트 루프 스레드 `EDT`에서 실행한다.
- `SwtScheduler` (`reactor.swing` 패키지): 태스크를 SWT UI 이벤트 루프 스레드에서 실행한다.

"[Reactor-Extra](https://projectreactor.io/docs/core/release/reference/#reactor-extra)" [수정 제안하기](https://github.com/reactor/reactor-core/edit/master/docs/asciidoc/apdx-reactorExtra.adoc)

---

> 전체 목차는 [여기](../contents/)에 있습니다.

