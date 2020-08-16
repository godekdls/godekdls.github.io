---
title: Appendix A Which operator do I need
category: Reactor Core
order: 11
permalink: /Reactor%20Core/appendixawhichoperatordoineed/
description: 리액터의 연산자 선택 가이드를 한글로 번역했습니다.
image: ./../../images/reactorcore/gs-transform.png
lastmod: 2020-08-03T21:29:00+09:00
comments: true
---

> [프로젝트 리액터 코어 공식 reference](https://projectreactor.io/docs/core/release/reference/#which-operator)를 한글로 번역한 문서입니다.
>
> 전체 목차는 [여기](../contents/)에 있습니다.

{% include adsense.html %}

### 목차

- [A.1. Creating a New Sequence…](#a1-creating-a-new-sequence)
- [A.2. Transforming an Existing Sequence](#a2-transforming-an-existing-sequence)
- [A.3. Peeking into a Sequence](#a3-peeking-into-a-sequence)
- [A.4. Filtering a Sequence](#a4-filtering-a-sequence)
- [A.5. Handling Errors](#a5-handling-errors)
- [A.6. Working with Time](#a6-working-with-time)
- [A.7. Splitting a `Flux`](#a7-splitting-a-flux)
- [A.8. Going Back to the Synchronous World](#a8-going-back-to-the-synchronous-world)
- [A.9. Multicasting a `Flux` to several `Subscribers`](#a9-multicasting-a-flux-to-several-subscribers)

---

이번 섹션에서 설명하는 연산자 중, `Flux`나 `Mono` 둘 중 하나에서만 제공하는 연산자는 앞에 해당 타입을 명시했다. 공통 연산자는 리액터 타입을 표기하지 않았다. 연산자 조합은 점과 괄호로 묶인 파라미터를 사용해서 메소드 호출로 표현했다 (ex.  `.methodCall(parameter)`).

여기서는 다음과 같은 내용을 다룬다:

- [새 시퀀스 생성하기](#a1-creating-a-new-sequence)
- [기존 시퀀스 변형하기](#a2-transforming-an-existing-sequence)
- [시퀀스 들여다보기](#a3-peeking-into-a-sequence)
- [시퀀스 필터링하기](#a4-filtering-a-sequence)
- [에러 처리하기](#a5-handling-errors)
- [시간을 함께 처리하기](#a6-working-with-time)
- [`Flux` 나누기](#a7-splitting-a-flux)
- [동기 세계로 돌아가기](#a8-going-back-to-the-synchronous-world)
- [여러 `Subscriber`에게 `Flux` 멀티캐스트하기](#a9-multicasting-a-flux-to-several-subscribers)

{% include adsense.html %}

---

## A.1. Creating a New Sequence…

- 소스는 있고, `T` 타입을 방출하는 시퀀스가 필요할 때: `just`
  - 소스가 `Optional<T>`일 때: `Mono#justOrEmpty(Optional<T>)`
  - 소스가 `null`이 될 수도 있는 T일 때: `Mono#justOrEmpty(T)`
- `T`를 리턴하는 메소드로 시퀀스를 만들고 싶을 때: 이때도 `just`
  - 단, 데이터를 lazy 방식으로 수집하고 싶다면: `Mono#fromSupplier`를 사용하거나 `just`를 `defer`로 감싸기
- 명시적으로 열거할 수 있는 `T` 여러 개를 방출하는 시퀀스를 만들고 싶을 때: `Flux#just(T…)`
- 다음을 통해 반복되는 요소로 시퀀스를 만들고 싶을 때:
  - 배열: `Flux#fromArray`
  - 컬렉션이나 이터러블: `Flux#fromIterable`
  - 정수 범위: `Flux#range`
  - 구독마다 제공하는 `Stream`: `Flux#fromStream(Supplier<Stream>)`
- 다음과 같은 단일 값 소스로 시퀀스를 만들고 싶을 때:
  - `Supplier<T>`: `Mono#fromSupplier`
  - 태스크: `Mono#fromCallable`, `Mono#fromRunnable`
  - `CompletableFuture<T>`: `Mono#fromFuture`
- 완료하는 시퀀스를 만들고 싶을 때: `empty`
- 즉시 에러를 발생시키는 시퀀스를 만들고 싶을 때: `error`
  - 단, `Throwable`을 lazy 방식으로 만들고 싶다면: `error(Supplier<Throwable>)`
- 아무것도 하지 않는 시퀀스를 만들고 싶을 때: `never`
- 구독 시점에 정해지는 시퀀스를 만들고 싶을 때: `defer`
- 반환해야 하는 리소스를(disposable resource) 사용하는 시퀀스를 만들 때: `using`
- 프로그래밍 방식으로 이벤트를 생산하는 시퀀스를 만들고 싶을 때 (상태를 가질 수 있다):
  - 동기식으로 한 번에 하나씩: `Flux#generate`
  - 비동기로 (동기도 가능함), 한 번에 여러 개를 방출해야 한다면: `Flux#create` (`Mono#create`도 가능하며, 이땐 단일 값만 방출할 수 있다)

---

## A.2. Transforming an Existing Sequence

- 기존 데이터를 변형하고 싶을 때:
  - 1:1로 변형한다면 (eg. 문자열을 문자열 길이로): `map`
    - 단순히 캐스팅만: `cast`
    - 각 소스 값의 인덱스도 함께 필요하다면: `Flux#index`
  - 1:n으로 변형한다면 (eg. 문자열을 문자셋으로): `flatMap` + 팩토리 메소드
  - 프로그래밍 방식으로, 각 소스 요소와 (또는) 상태로 1:n 변형을 한다면: `handle`
  - 각 소스 아이템으로 비동기 태스크를 실행한다면: `flatMap` + 비동기 `Publisher`를 반환하는 메소드
    - 일부 데이터를 무시해야 한다면: flatMap 람다에서 조건에 따라 `Mono.empty()`를 리턴
    - 기존 시퀀스 순서를 유지해야 한다면: `Flux#flatMapSequential` (즉시 비동기 처리를 트리거하지만 결과를 재정렬한다)
    - 비동기 태스크가 값을 여러 개 리턴하고, 소스는 `Mono`라면: `Mono#flatMapMany`
- 기존 시퀀스에 요소를 추가하고 싶을 때:
  - 시퀀스 앞에: `Flux#startWith(T…)`
  - 시퀀스 뒤에: `Flux#concatWith(T…)`
- `Flux`를 집계하고 싶을 때: (앞에 `Flux#`가 있다고 가정)
  - List로: `collectList`, `collectSortedList`
  - Map으로: `collectMap`, `collectMultiMap`
  - 임의의 컨테이너로: `collect`
  - 시퀀스 크기로: `count`
  - 요소 중간 중간에 함수를 적용한다면 (eg. sum 실행): `reduce`
    - 단, 단계마다 중간 결과값을 방출해야 한다면: `scan`
  - predicate를 사용해서 boolean 값으로:
    - 모든 값에 (AND 조건): `all`
    - 최소한 값 한 개에 (OR 조건): `any`
    - 여러 값 중 하나라도 있는지 확인: `hasElements`
    - 특정 값이 있는지 확인: `hasElement`
- publisher 여러 개를 조합하고 싶을 때
  - 순차적으로: `Flux#concat` 또는 `.concatWith(other)`
    - 단, 남은 publisher가 모두 값을 방출할 때까지 에러를 지연시켜야 한다면: `Flux#concatDelayError`
    - 단, 기다리지 않고 바로 다음 publisher를 구독하고 싶다면: `Flux#mergeSequential`
  - 방출 순서로 (방출한 아이템이 도착하는 대로 조합): `Flux#merge` / `.mergeWith(other)`
    - publisher마다 아이템 타입이 다르다면 (변환해서 머지): `Flux#zip` / `Flux#zipWith`
  - 값 여러 개를 짝을 맞춰서:
    - Mono 두 개를 `Tuple2`로: `Mono#zipWith`
    - Mono n개를 완료했을 때: `Mono#zip`
  - 종료 신호를 조정해서:
    - Mono 1개를 다른 소스와 조합해서 `Mono<Void>`로: `Mono#and`
    - n개의 소스가 완료됐을 때: `Mono#when`
    - 임의의 컨테이너 타입으로:
      - 모든 publisher가 값을 방출할 때마다: `Flux#zip` (최소 카디널리티까지만)
      - publisher 중 하나에 새 값이 도착할 때마다: `Flux#combineLatest`
  - 첫 번째로 방출하는 시퀀스만 고려해서: `Flux#first`, `Mono#first`, `mono.or (otherMono).or(thirdMono)`, `flux.or(otherFlux).or(thirdFlux)`
  - 소스 시퀀스 안에 있는 요소마다 트리거해서: `switchMap` (소스의 각 요소가 Publisher에 매핑된다)
  - 다음 publisher가 시작될 때 트리거해서: `switchOnNext`
- 기존 시퀀스를 반복하고 싶을 때: `repeat`
  - 단, 시간 간격을 둔다면: `Flux.interval(duration).flatMap(tick → myExistingPublisher)`
- 빈 시퀀스가 있을 때:
  - 다른 값으로 바꾸고 싶다면: `defaultIfEmpty`
  - 다른 시퀀스로 바꾸고 싶다면: `switchIfEmpty`
- 시퀀스가 있지만 값에는 관심 없을 때: `ignoreElements`
  - `Mono`를 완료로 표현하고 싶다면: `then`
  - 마지막에 다른 태스크가 완료되길 기다려야 한다면: `thenEmpty`
  - 마지막에 다른 `Mono`로 전환해야 한다면: `Mono#then(mono)`
  - 마지막에 값 하나를 방출해야 한다면: `Mono#thenReturn(T)`
  - 마지막에 `Flux`로 전환하고 싶다면: `thenMany`
- Mono의 완료를 연기하고 싶을 때:
  - 이 값으로 생성하는 다른 publisher가 완료될 때까지 연기한다면: `Mono#delayUntil(Function)`
- 요소를 재귀적으로 확장해서 시퀀스 그래프로 만들고, 그 조합을 방출하고 싶을 때
  - 그래프를 너비 우선 탐색으로 확장한다면: `expand(Function)`
  - 깊이 우선 탐색으로 확장한다면: `expandDeep(Function)`

---

## A.3. Peeking into a Sequence

- 최종 시퀀스를 수정하지 않고,
  - 다음을 통지받거나 / 다른 로직을 실행하고 싶을 때 ("부수 효과"라고들 하는):
    - 방출: `doOnNext`
    - 완료: `Flux#doOnComplete`, `Mono#doOnSuccess` (값이 있다면 그 값도 포함)
    - 에러 종료: `doOnError`
    - 취소: `doOnCancel`
    - 시퀀스 "시작": `doFirst`
      - 이땐 `Publisher#subscribe(Subscriber)`에 연결된다
    - 구독 이후 : `doOnSubscribe`
      - `subscribe` 이후 `Subscription`을 승인하는 것 같이
      - 이땐 `Subscriber#onSubscribe(Subscription)`에 연결된다
    - 요청: `doOnRequest`
    - 완료 또는 에러: `doOnTerminate` (Mono에선 값이 있다면 그 값을 포함)
      - 단, 다운스트림에 전파된 **이후**에 필요하다면: `doAfterTerminate`
    - `Signal`로 표현되는 모든 신호 타입: `Flux#doOnEach`
    - 모든 종료 조건 (완료, 에러, 취소): `doFinally`
  - 내부에서 일어나는 일을 로깅하고 싶다면: `log`
- 모든 이벤트를 알고 싶을 때:
  - 모든 이벤트를 `Signal` 객체로 표현해서:
    - 시퀀스 바깥에 있는 콜백 안에서 `Signal` 객체 사용: `doOnEach`
    - 기존 onNext 방출 대신 `Signal` 객체를 방출: `materialize`
      - 다시 onNext로 돌아갈 때는: `dematerialize`
  - 로그 한 줄로 보고 싶을 때: `log`

---

## A.4. Filtering a Sequence

- 시퀀스를 필터링하고 싶을 때:
  - 임의의 기준을 사용해서: `filter`
    - 비동기로 계산해야 한다면: `filterWhen`
  - 방출한 객체의 타입을 제한: `ofType`
  - 모든 값을 무시: `ignoreElements`
  - 중복 값을 무시:
    - 전체 시퀀스에서 (논리적으로 중복이 없는 set): `Flux#distinct`
    - 같은 값을 연이어 방출할 때 (중복 제거): `Flux#distinctUntilChanged`
- 시퀀스의 일부만 유지하고 싶을 때:
  - 요소 N개를 선택해서:
    - 시퀀스 앞에서부터: `Flux#take(long)`
      - 지속 시간 기준으로: `Flux#take(Duration)`
      - 첫 번째 요소만, `Mono`로: `Flux#next()`
      - 취소하는 대신 `request(N)`을 사용해서: `Flux#limitRequest(long)`
    - 시퀀스 마지막에서부터: `Flux#takeLast`
    - 기준이 충족될 때까지 (경계값 포함): `Flux#takeUntil` (predicate 기반), `Flux#takeUntilOther` (companion publisher 기반)
    - 기준에 만족하는 동안만 (경계값 미포함): `Flux#takeWhile`
  - 최대 1개를 선택해서:
    - 특정 위치에서: `Flux#elementAt`
    - 마지막에서: `.takeLast(1)`
      - 비어 있는 경우 에러를 방출해야 한다면: `Flux#last()`
      - 비어 있는 경우 디폴트 값을 방출해야 한다면: `Flux#last(T)`
  - 요소를 건너뛰어서:
    - 시퀀스 앞에서: `Flux#skip(long)`
      - 지속 시간 기준으로: `Flux#skip(Duration)`
    - 시퀀스 마지막에서: `Flux#skipLast`
    - 기준이 충족될 때까지 (경계값 포함): `Flux#skipUntil` (predicate 기반), `Flux#skipUntilOther` (companion publisher 기반)
    - 기준에 만족하는 동안만 (경계값 미포함): `Flux#skipWhile`
  - 아이템을 샘플링해서:
    - 지속 시간 기준으로: `Flux#sample(Duration)`
      - 윈도우를 샘플링할 때 마지막 요소가 아닌 첫 번째 요소를 유지하고 싶다면: `sampleFirst`
    - publisher 기반 윈도우로: `Flux#sample(Publisher)`
    - publisher "타임아웃" 기반으로: `Flux#sampleTimeout` (각 요소가 트리거한 publisher와 다음 publisher가 오버랩되지 않으면 방출한다)
- 요소가 최대 1개이길 원할 때 (하나보다 많으면 에러)
  - 시퀀스가 비었을 때도 에러로 처리하고 싶다면: `Flux#single()`
  - 시퀀스가 비었을 땐 디폴트 값을 사용하고 싶다면: `Flux#single(T)`
  - 빈 시퀀스도 허용하고 싶다면: `Flux#singleOrEmpty`

---

## A.5. Handling Errors

- 에러를 발생시키는 시퀀스를 만들고 싶을 때: `error`
  - `Flux`가 성공적으로 완료하면 에러 발생: `.concat(Flux.error(e))`
  - Mono가 **방출**에 성공하면 에러 발생: `.then(Mono.error(e))`
  - onNext 사이 소요 시간이 너무 길면 에러 발생: `timeout`
  - Lazy 방식으로: `error(Supplier<Throwable>)`
- try/catch와 동일한 처리를 하고 싶을 때:
  - exception 던지기: `error`
  - exception 캐치:
    - 디폴트 값으로 폴백: `onErrorReturn`
    - 다른 `Flux`나 `Mono`로 폴백: `onErrorResume`
    - 감싸서 다시 던지기: `.onErrorMap(t → new RuntimeException(t))`
  - finally 블록: `doFinally`
  - 자바 7의 using 패턴: 팩토리 메소드 `using`
- 에러를 복구하고 싶을 때
  - 폴백:
    - 값으로: `onErrorReturn`
    - 에러에 따라 다른 `Publisher`나 `Mono`: `Flux#onErrorResume`, `Mono#onErrorResume`
  - 재시도
    - 간단한 정책을 사용해서 (최대 시도 횟수): `retry()`, `retry(long)`
    - companion control Flux로 트리거해서: `retryWhen`
    - 표준 백오프 전략을 사용해서 (jitter를 사용한 [exponential backoff](../appendixbfaqbestpracticesandhowdoi/#b5-how-can-i-use-retrywhen-for-exponential-backoff)): `retryWhen(Retry.backoff(…))` (`Retry`에 있는 다른 팩토리 메소드도 참고)
- backpressure "에러"를 처리하고 싶을 때 (업스트림의 최대치를 요청하고, 다운스트림이 그만큼 요청을 생산하지 못하면 적용할 전략)
  - 특별한 `IllegalStateException` 던지기: `Flux#onBackpressureError`
  - 수용할 수 없는 값을 드랍: `Flux#onBackpressureDrop`
    - 가장 마지막에 받은 아이템은 남겨두고: `Flux#onBackpressureLatest`
  - 수용할 수 없는 값을 버퍼링 (bounded 또는 unbounded): `Flux#onBackpressureBuffer`
    - bounded 버퍼가 가득 찼을 때에도 전략을 적용하고 싶다면: `Flux#onBackpressureBuffer`와 `BufferOverflowStrategy`

---

## A.6. Working with Time

- 측정 시간을 함께 방출하고 싶을 때 (`Tuple2<Long, T>`)
  - 구독 시점부터: `elapsed`
  - 태초부터 (즉, 시스템 시간): `timestamp`
- 방출 사이에 지연이 너무 길다면 시퀀스를 중단하고 싶을 때: `timeout`
- 일정한 간격으로 시간 값을 방출하고 싶을 때: `Flux#interval`
- 초기 지연 시간 이후에 단일 값 `0`을 방출하고 싶을 때: 스태틱 메소드 `Mono.delay`.
- 지연을 추가하고 싶을 때:
  - onNext 신호 사이사이마다: `Mono#delayElement`, `Flux#delayElements`
  - 구독 전에: `delaySubscription`

---

## A.7. Splitting a `Flux`

- 경계를 정해서 `Flux<T>`를 `Flux<Flux<T>>`로 분할하고 싶을 때:
  - 사이즈 경계: `window(int)`
    - 일부 요소를 오버랩하거나 드랍하고 싶다면: `window(int, int)`
  - 시간 경계: `window(Duration)`
    - 일부 요소를 오버랩하거나 드랍하고 싶다면: `window(Duration, Duration)`
  - 사이즈 또는 시간 경계 (원하는 갯수가 되거나 타임아웃에 도달하면 윈도우를 닫는다): `windowTimeout(int, Duration)`
  - predicate 기반: `windowUntil`
    - 경계를 나눈 요소를 다음 윈도우에 넣고 싶다면 (`cutBefore` 변수): `.windowUntil(predicate, true)`
    - 요소가 predicate에 매치하는 동안은 윈도우를 열어두고 싶다면: `windowWhile` (매치하지 않는 요소는 방출하지 않는다)
  - control publisher의 onNext 신호에서 임의의 경계를 정해서: `window(Publisher)`, `windowWhen`
- 경계를 정해서 `Flux<T>`를 버퍼에 나눠 담고 싶을 때
  - `List`로:
    - 사이즈 경계: `buffer(int)`
      - 일부 요소를 오버랩하거나 드랍하고 싶다면: `buffer(int, int)`
    - 지속 시간 경계: `buffer(Duration)`
      - 일부 요소를 오버랩하거나 드랍하고 싶다면: `buffer(Duration, Duration)`
    - 사이즈 또는 지속 시간 경계: `bufferTimeout(int, Duration)`
    - 임의의 기준으로: `bufferUntil(Predicate)`
      - 경계를 나눈 요소를 다음 버퍼에 넣고 싶다면: `.bufferUntil(predicate, true)`
      - predicate에 매치하는 동안은 버퍼링하고, 경계를 나눈 요소는 드랍하고 싶다면: `bufferWhile(Predicate)`
    - control publisher의 onNext 신호에서 임의의 경계를 정해서: `buffer(Publisher)`, `bufferWhen`
  - 임의의 "컬렉션" 타입 `C`로: `buffer(int, Supplier<C>)`같은 오버로딩 메소드 사용
- `Flux<T>`를 분할하면서, 같은 특성을 가진 요소는 동일한 하위 flux로 분리하고 싶을 때: `groupBy(Function<T,K>)` 팁: 이땐 `Flux<GroupedFlux<K, T>>`를 리턴하며, 안에 있는 각 `GroupedFlux`는 동일한 `K` 키를 공유한다. 이 키는 `key()`로 접근할 수 있다.

---

## A.8. Going Back to the Synchronous World

주의: "논블로킹 only"로 마킹된 `Scheduler`에서 (디폴트는 `parallel()`, `single()`) 이 메소드를 호출하면 `Mono#toFuture`만 제외하고 모두 `UnsupportedOperatorException`을 던진다.

- `Flux<T>`로:
  - 첫 번째 요소를 얻을 때까지 블로킹하고 싶다면: `Flux#blockFirst`
    - 타임아웃을 주려면: `Flux#blockFirst(Duration)`
  - 마지막 요소를 (비어 있다면 null) 얻을 때까지 블로킹하고 싶다면: `Flux#blockLast`
    - 타임아웃을 주려면: `Flux#blockLast(Duration)`
  - 동기로 `Iterable<T>`로 전환: `Flux#toIterable`
  - 동기로 자바 8 `Stream<T>`으로 전환: `Flux#toStream`
- `Mono<T>`로:
  - 값을 받을 때까지 블로킹하고 싶다면: `Mono#block`
    - 타임아웃을 주려면: `Mono#block(Duration)`
  - `CompletableFuture<T>`: `Mono#toFuture`

---

## A.9. Multicasting a `Flux` to several `Subscribers`

- 여러 `Subscriber`를 `Flux` 하나에 연결하고 싶을 때:
  - `connect()`로 소스를 트리거하는 시점을 결정: `publish()` (`ConnectableFlux`를 리턴함)
  - 소스를 즉시 트리거 (이후 구독자는 이후 데이터만 받음): `share()`
  - 원하는 만큼의 구독자를 등록하면 영구적으로 소스를 연결: `.publish().autoConnect(n)`
  - 구독자 수가 임계치를 넘거나/넘지 못하면 소스를 자동으로 연결/취소: `.publish().refCount(n)`
    - 취소하기 전 새 구독자가 등록될 수 있게 유예 시간을 추가하려면: `.publish().refCountGrace(n, Duration)`
- `Publisher`의 데이터를 캐시해 두고 이후 다른 구독자에 재전송하고 싶을 때:
  - 요소 `n`개까지: `cache(int)`
  - `Duration` (Time-To-Live) 내에 받은 최신 요소를 캐시: `cache(Duration)`
    - 단, 최대 `n`개만 유지하고 싶다면: `cache(int, Duration)`
  - 소스를 즉시 트리거하지 않고: `Flux#replay` (`ConnectableFlux`를 리턴함)

"[Which operator do I need?](https://projectreactor.io/docs/core/release/reference/#which-operator)" [수정 제안하기](https://github.com/reactor/reactor-core/edit/master/docs/asciidoc/apdx-operatorChoice.adoc)

---

> 전체 목차는 [여기](../contents/)에 있습니다.