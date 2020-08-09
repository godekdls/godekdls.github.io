---
title: Appendix B FAQ, Best Practices, and How do I
category: Reactor Core
order: 12
permalink: /Reactor%20Core/appendixbfaqbestpracticesandhowdoi/
description: 리액터 FAQ, best practice 가이드를 한글로 번역했습니다.
image: ./../../images/reactorcore/gs-transform.png
lastmod: 2020-08-04T00:47:00+09:00
comments: true
---

> [프로젝트 리액터 코어 공식 레퍼런스](https://projectreactor.io/docs/core/release/reference/index.html#faq)를 한글로 번역한 문서입니다.
>
> 전체 목차는 [여기](../contents/)에 있습니다.

### 목차

- [B.1. How Do I Wrap a Synchronous, Blocking Call?](#b1-how-do-i-wrap-a-synchronous-blocking-call)
- [B.2. I Used an Operator on my `Flux` but it Doesn’t Seem to Apply. What Gives?](#b2-i-used-an-operator-on-my-flux-but-it-doesnt-seem-to-apply-what-gives)
- [B.3. My `Mono` `zipWith` or `zipWhen` is never called](#b3-my-mono-zipwith-or-zipwhen-is-never-called)
- [B.4. How to Use retryWhen to Emulate retry(3)?](#b4-how-to-use-retrywhen-to-emulate-retry3)
- [B.5. How can I use `retryWhen` for Exponential Backoff?](#b5-how-can-i-use-retrywhen-for-exponential-backoff)
- [B.6. How Do I Ensure Thread Affinity when I Use `publishOn()`?](#b6-how-do-i-ensure-thread-affinity-when-i-use-publishon)
- [B.7. What Is a Good Pattern for Contextual Logging? (MDC)](#b7-what-is-a-good-pattern-for-contextual-logging-mdc)

---

이번 섹션에선 다음과 같은 내용을 다룬다:

- [동기 방식 블로킹 호출은 어떻게 감싸야 하나요?](#b1-how-do-i-wrap-a-synchronous-blocking-call)
- [내 `Flux`에 연산자를 사용했는데 적용되지 않는 것 같아요. 왜 그런가요?](#b2-i-used-an-operator-on-my-flux-but-it-doesnt-seem-to-apply-what-gives)
- [내가 만든 `Mono` `zipWith` 또는 `zipWhen`이 호출되지 않아요](#b3-my-mono-zipwith-or-zipwhen-is-never-called)
- [`retry(3)`을 `retryWhen`으로 구현하려면 어떻게 하나요?](#b4-how-to-use-retrywhen-to-emulate-retry3)
- [`retryWhen`으로 Exponential Backoff은 어떻게 설정하나요?](#b5-how-can-i-use-retrywhen-for-exponential-backoff)
- [`publishOn()`을 사용할 땐 Thread Affinity를 어떻게 보장하나요?](#b6-how-do-i-ensure-thread-affinity-when-i-use-publishon)
- [컨텍스트 로그를 남길만한 괜찮은 패턴이 있나요? (MDC)](#b7-what-is-a-good-pattern-for-contextual-logging-mdc)

---

## B.1. How Do I Wrap a Synchronous, Blocking Call?

데이터 소스가 동기식이고, 블로킹인 경우도 흔히 있다. 리액터 어플리케이션에서 이런 소스를 다룬다면 아래와 같은 패턴을 적용해라:

```java
Mono blockingWrapper = Mono.fromCallable(() -> { // (1)
    return /* make a remote synchronous call */ // (2)
});
blockingWrapper = blockingWrapper.subscribeOn(Schedulers.boundedElastic()); // (3)
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `fromCallable`로 새 `Mono`를 만든다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 블로킹 리소스를 비동기로 반환한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 구독은 `Schedulers.boundedElastic()`에서 지정한 싱글 스레드 워커에서 일어나게 만든다.</small>

이 소스는 값 하나를 리턴하기 때문에 `Mono`를 사용했다. `Schedulers.boundedElastic`은 다른 논블로킹 처리에 영향을 주지 않으면서 블로킹 리소스를 기다릴 전용 스레드를 생성해주며, 생성할 수 있는 스레드 수에 제한을 두기 때문에 요청이 몰렸을 때 블로킹 태스크를 큐에 넣어 연기시킬 수 있다.

`subscribeOn`은 `Mono`를 구독하는 게 아니라는 점에 주의해라. subscribe를 호출했을 때 사용할 `Scheduler`를 지정하는 것이다.

---

## B.2. I Used an Operator on my `Flux` but it Doesn’t Seem to Apply. What Gives?

`.subscribe()`하려는 변수는 반드시 적용하고 싶은 연산자의 영향 아래 있어야 한다.

리액터 연산자는 데코레이터다. 기존 시퀀스를 감싼 새 인스턴스를 리턴하고 행동을 추가한다. 그렇기 때문에 연산자를 적용할 땐 메소드 *체이닝*을 사용하는 게 좋다.

아래 두 예제를 비교해 보자:

**Example 25. without chaining (incorrect)**

```java
Flux<String> flux = Flux.just("something", "chain");
flux.map(secret -> secret.replaceAll(".", "*")); // (1)
flux.subscribe(next -> System.out.println("Received: " + next));
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 여기가 잘 못 됐다. 결과는 `Flux` 변수에 담기지 않는다.</small>

**Example 26. without chaining (correct)**

```java
Flux<String> flux = Flux.just("something", "chain");
flux = flux.map(secret -> secret.replaceAll(".", "*"));
flux.subscribe(next -> System.out.println("Received: " + next));
```

아래는 더 좋은 예시다 (더 간단함):

**Example 27. with chaining (best)**

```java
Flux<String> secrets = Flux
  .just("something", "chain")
  .map(secret -> secret.replaceAll(".", "*"))
  .subscribe(next -> System.out.println("Received: " + next));
```

첫 번째 예제는 다음을 출력한다:

```
Received: something
Received: chain
```

나머지 두 예제는 아래와 같이 의도한 값을 출력한다:

```
Received: *********
Received: *****
```

---

## B.3. My `Mono` `zipWith` or `zipWhen` is never called

다음 예제를 살펴보자:

```java
myMethod.process("a") // this method returns Mono<Void>
        .zipWith(myMethod.process("b"), combinator) //this is never called
        .subscribe();
```

소스 `Mono`가 `empty`거나 `Mono<Void>`라면 (`Mono<Void>`도 사실상 비어 있다), 이런 조합 메소드는 호출되지 않는다.

정의에 따르면 변환 연산자는 각 소스에서 요소를 받아야 결과를 생산할 수 있기 때문에, `zip` 스태틱 메소드나 `zipWith`, `zipWhen` 연산자를 사용하더라도 이는 동일하다.

`zip`으로 생성한 소스에 데이터를 없애는 연산자를 적용하면 문제가 될 수 있다. 데이터를 없애는 연산자는  `then()`, `thenEmpty(Publisher<Void>)`, `ignoreElements()`, `ignoreElement()`, `when(Publisher…)` 등이 있다.

유사하게, `flatMap`같이 `Function<T,?>`으로 행동을 정의하는 연산자는, 이 `Function`을 실제로 적용하려면 요소를 최소 1개는 방출해야 한다. 비어 있는 (또는 `<Void>`) 시퀀스에 이 연산자를 적용하면 요소를 생산하지 않는다.

이런 상황을 피하려면, `.defaultIfEmpty(T)`와 `.switchIfEmpty(Publisher<T>)`를 사용해서 비어있는 `T` 시퀀스를 디폴트 값이나 폴백 `Publisher<T>`로 대치하면 된다. 단, `Flux<Void>`/`Mono<Void>` 소스는 해당하지 않는다. 전환하더라도 여전히 비어있는 `Publisher<Void>`로만 전환할 수 있기 때문이다. 다음 예제는 `defaultIfEmpty`를 사용한다:

**Example 28. use `defaultIfEmpty` before `zipWhen`**

```java
myMethod.emptySequenceForKey("a") // this method returns empty Mono<String>
        .defaultIfEmpty("") // this converts empty sequence to just the empty String
        .zipWhen(aString -> myMethod.process("b")) //this is called with the empty String
        .subscribe();
```

---

## B.4. How to Use retryWhen to Emulate retry(3)?

`retryWhen` 연산자는 꽤 복잡할 수 있다. `retry(3)`과 동일한 동작을 구현하는 다음 코드가 이해하는 데 도움이 되길 바란다:

```java
AtomicInteger errorCount = new AtomicInteger();
Flux<String> flux =
		Flux.<String>error(new IllegalArgumentException())
				.doOnError(e -> errorCount.incrementAndGet())
				.retryWhen(Retry.from(companion -> // (1)
						companion.map(rs -> { // (2)
							if (rs.totalRetries() < 3) return rs.totalRetries(); // (3)
							else throw Exceptions.propagate(rs.failure()); // (4)
						})
				));
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 특정 클래스를 제공하는 대신, `Function` 람다로 `Retry`를 커스텀한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> companion은 지금까지의 재시도 몇 번과 마지막 실패를 담고 있는 `RetrySignal` 객체를 방출한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 재시도를 세 번 허용하기 위해, 인덱스가 3보다 작으면 값을 방출한다 (여기선 단순히 인덱스를 리턴한다).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> 세 번 재시도한 다음은, 시퀀스를 에러로 종료하도록 기존 예외를 던진다.</small>

---

## B.5. How can I use `retryWhen` for Exponential Backoff?

Exponential backoff은 소스 시스템에 과부하가 걸려 전체가 크래쉬나지 않도록, 매번 지연 시간을 늘려가며 재시도하는 방법이다. 소스에서 에러를 생산하면, 이미 불안정한 상태이고 즉각적으로 복구할 수는 없을 것이라는 논리에 따른다. 즉, 무턱대고 즉각 재시도하면 또다시 에러를 생산할 가능성이 높으며, 더 불안정해질 수 있다고 가정한다.

`3.3.4.RELEASE`부터 리액터는 이럴 때 `Flux#retryWhen`과 함께 사용할 수 있는 빌더를 제공한다: `Retry.backoff`.

다음 예제는 빌더를 사용해서 간단하게 재시도 전후에 로그를 남기는 훅을 등록한다. 재시도를 지연시키며, 새로 시도할 때마다 더 오래 지연시킨다 (슈도코드: delay = attempt number * 100 milliseconds):

```java
AtomicInteger errorCount = new AtomicInteger();
Flux<String> flux =
Flux.<String>error(new IllegalStateException("boom"))
		.doOnError(e -> { // (1)
			errorCount.incrementAndGet();
			System.out.println(e + " at " + LocalTime.now());
		})
		.retryWhen(Retry
				.backoff(3, Duration.ofMillis(100)).jitter(0d) // (2)
				.doAfterRetry(rs -> System.out.println("retried at " + LocalTime.now())) // (3)
				.onRetryExhaustedThrow((spec, rs) -> rs.failure()) // (4)
		);
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 소스가 방출한 에러 시간을 로깅하고, 에러 횟수를 계산한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 최대 3번 재시도하고, jitter는 사용하지 않는 exponential backoff 재시도를 설정한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 재시도할 때도 시간을 로깅한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> 디폴트로는 마지막 `failure()`를 원인으로 가지고 있는 `Exceptions.retryExhausted` 예외를 던진다. 여기선 원인을 바로 `onError`로 방출하도록 커스텀한다.</small>

구독하면 시퀀스는 실패하고, 다음을 출력하고 종료한다:

```java
java.lang.IllegalArgumentException at 18:02:29.338
retried at 18:02:29.459 // (1)
java.lang.IllegalArgumentException at 18:02:29.460
retried at 18:02:29.663 // (2)
java.lang.IllegalArgumentException at 18:02:29.663
retried at 18:02:29.964 // (3)
java.lang.IllegalArgumentException at 18:02:29.964
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 처음엔 100ms 후에 재시도한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 두 번째는 200ms 후에 재시도한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 세 번째는 300ms 후에 재시도한다.</small>

---

##  B.6. How Do I Ensure Thread Affinity when I Use `publishOn()`?

[Schedulers](../reactorcorefeatures#45-threading-and-schedulers)에서 설명했듯이, `publishOn()`은 실행 컨텍스트를 전환한다. `publishOn` 연산자를 만나면 다른 `publishOn`을 만나기 전까지, 아래 있는 나머지 연산자 체인을 실행할 스레드 컨텍스트가 바뀐다. 그렇기 때문에 `publishOn`을 어디에 두느냐가 중요하다.

다음 예제를 생각해 보자:

```java
EmitterProcessor<Integer> processor = EmitterProcessor.create();
processor.publishOn(scheduler1)
         .map(i -> transform(i))
         .publishOn(scheduler2)
         .doOnNext(i -> processNext(i))
         .subscribe();
```

`map()` 안에 있는 `transform` 함수는 `scheduler1`의 워커에서,`doOnNext()` 안에 있는 `processNext` 메소드는 `scheduler2`의 워커에서 실행한다. 구독마다 각자의 워커를 할당하므로, 해당 구독자에게 전달된 모든 요소는 동일한 `Thread`에서 publish된다.

체인에 있는 여러 단계나, 여러 구독자에서 thread affinity를 보장하고 싶다면 싱글 스레드 스케줄러를 사용하면 된다.

---

## B.7. What Is a Good Pattern for Contextual Logging? (MDC)

로깅 프레임워크는 대부분 컨텍스트 로깅을 지원하므로, 사용자는 MDC("Mapped Diagnostic Contex")로 불리는 `Map`을 사용해서 로그 패턴에 있는 변수를 저장할 수 있다. 자바의 `ThreadLocal`을 반복 사용하는 케이스 중 하나로, 이 패턴은 결과적으로 로그를 남기는 코드와 `Thread` 사이에 1:1 관계를 형성한다.

자바 8 이전에는 문제없었지만, 자바 언어에 함수형 프로그래밍이 도입되고 나서는 상황이 조금 달라졌다.

템플릿 메소드 패턴을 사용하는 명령형 API를 함수형 스타일로 전환한다고 생각해 보자. 이 API는 템플릿 메소드 패턴으로 상속을 구현했다. 이제 함수형으로 접근해서, 알고리즘의 "단계"를 정의한 고차 함수를 넘길 것이다. 이제는 명령형이라기보단 좀 더 선언적이며, 라이브러리가 각 단계를 실행할 위치를 결정할 수 있다. 예를 들어, 병렬화할 수 있는 알고리즘 단계를 알면, 라이브러리는 `ExecutorService`를 사용해서 일부 단계를 병렬로 실행할 수 있다.

함수형 API의 구체적인 예시를 들자면, 자바 8에서 소개된 `Stream` API와 `parallel()`이 있다. 병렬 `Stream`에서 MDC로 로그를 남기는 일은 공짜가 아니다: MDC를 획득해서 각 단계마다 다시 적용해야 한다.

함수형 스타일은 스레드에 독립적이며 [참조에 투명](https://ko.wikipedia.org/wiki/참조_투명성)하기 때문에 이런 식의 최적화는 가능하지만, MDC가 싱글 `Thread`라는 가정은 더 이상 유효하지 않다. 모든 단계에서 컨텍스트 정보를 사용하는 가장 관용적인 방법은 조합 체인을 통해 컨텍스트를 전달하는 것이다. 리액터를 개발할 때도 동일한 이슈를 겪었지만, 이렇게 직접적인 방법은 피하고 싶었다. 따라서 `Context`를 도입했다: 리턴 값으로 `Flux`나 `Mono`를 사용하면 실행 체인을 통해 전파되며, 각 단계(연산자)에선 다운스트림 단계에 있는 `Context`에 접근할 수 있다. 즉, 리액터는 `ThreadLocal`을 사용하는 대신, 이 map과 유사한 객체를 제공하며, 이는 `Thread`가 아닌 `Subscription`에 연결된다.

지금까지 선언적 API에선 MDC가 "정상 작동"한다고 해서 되는 게 아니라는 것을 알아봤는데, 리액티브 스트림의 이벤트와 (`onNext`, `onError`, `onComplete`) 관련된 컨텍스트 상의 로그는 어떻게 남기는 걸까?

이 FAQ 항목은 이러한 신호 관련 로그를 간단하고 명시적으로 남길 수 있는 솔루션이기도 하다. 미리 [Adding a Context to a Reactive Sequence](../advancedfeaturesandconcepts#98-adding-a-context-to-a-reactive-sequence) 섹션을 읽어보고, 특히 위에 있는 연산자에 컨텍스트를 전달하려면 연산자 체인 아래에서 어떻게 쓰기가 일어나야 하는지 확인해라.

컨텍스트 정보를 `Context`에서 MDC로 옮기는 가장 쉬운 방법은 로그 구문을 약간의 보일러플레이트와 함께 `doOnEach` 연산자로 감싸는 것이다. 선택하는 로깅 프레임워크/추상화와 MDC에 넣을 정보에 따라 달라지는 부분이 있기 때문에 보일러플레이트가 필요하다.

다음 코드는 MDC 변수 하나를 사용하는 헬퍼 함수 예시로, 자바 9에서 추가된 `Optional` API를 사용해 `onNext` 이벤트를 로깅한다:

```java
public static <T> Consumer<Signal<T>> logOnNext(Consumer<T> logStatement) {
	return signal -> {
		if (!signal.isOnNext()) return; // (1)
		Optional<String> toPutInMdc = signal.getContext().getOrEmpty("CONTEXT_KEY"); // (2)

		toPutInMdc.ifPresentOrElse(tpim -> {
			try (MDC.MDCCloseable cMdc = MDC.putCloseable("MDC_KEY", tpim)) { // (3)
				logStatement.accept(signal.get()); // (4)
			}
		},
		() -> logStatement.accept(signal.get())); // (5)
	};
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `doOnEach` 신호는 `onComplete`과 `onError`를 포함한다. 이 예제에선 `onNext`만 로깅한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 리액터 `Context`에서 원하는 값을 추출한다 ([The `Context` API](../advancedfeaturesandconcepts#981-the-context-api) 섹션 참고).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 이 예제에선 SLF4J 2의 `MDCCloseable`을 try-with-resource 문법과 함께 사용해서, 로그 구문을 실행한 다음 자동으로 MDC를 비운다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> 적당한 로그 구문은 호출자가 `Consumer<T>`로 제공한다 (onNext 값의 컨슈머).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> `Context`에 원하는 키가 세팅되지 않았다면 MDC에 값을 추가하지 않는다.</small>

이 보일러플레이트 코드는 MDC를 올바른 방식으로 사용하고 있다: 로그 구문을 실행하기 직전 키를 세팅하고, 실행 직후 제거한다. 다음 로그 구문에서 사용할 MDC를 오염시킬 가능성은 없다.

물론 이건 예시일 뿐이다. `Context`에서 값을 여러 개 추출하거나, `onError`일 때 로그를 남기고 싶을 수도 있다. 이땐 케이스별 헬퍼 메소드를 만들거나, 람다를 사용하는 범용 메소드를 만들고 싶을 것이다.

어쨌거나, 위 헬퍼 메소드를 사용한다면 아래 있는 리액티브 웹 컨트롤러와 유사한 코드를 작성할 것이다:

```java
@GetMapping("/byPrice")
public Flux<Restaurant> byPrice(@RequestParam Double maxPrice, @RequestHeader(required = false, name = "X-UserId") String userId) {
	String apiId = userId == null ? "" : userId; // (1)

	return restaurantService.byPrice(maxPrice))
			   .doOnEach(logOnNext(r -> LOG.debug("found restaurant {} for ${}", // (2)
					r.getName(), r.getPricePerPerson())))
			   .subscriberContext(Context.of("CONTEXT_KEY", apiId)); // (3)
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 요청 헤더에서 `Context`에 담을 컨텍스트 정보를 얻는다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 여기서 `doOnEach`를 사용해서  `Flux`에 앞에서 만든 헬퍼 메소드를 적용한다. 연산자는 밑에서 정의한 `Context` 값을 볼 수 있다는 점을 기억하라.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> `Context`에 `CONTEXT_KEY`라는 키로 헤더 값을 담는다.</small>

이렇게 설정하면 `restaurantService`가 공유 스레드에서 데이터를 방출하더라도, 로그는 요청에 있는 정확한 `X-UserId`를 참조한다.

완성도를 높이기 위해 에러 로그 헬퍼 예시도 살펴보겠다:

```java
public static Consumer<Signal<?>> logOnError(Consumer<Throwable> errorLogStatement) {
	return signal -> {
		if (!signal.isOnError()) return;
		Optional<String> toPutInMdc = signal.getContext().getOrEmpty("CONTEXT_KEY");

		toPutInMdc.ifPresentOrElse(tpim -> {
			try (MDC.MDCCloseable cMdc = MDC.putCloseable("MDC_KEY", tpim)) {
				errorLogStatement.accept(signal.getThrowable());
			}
		},
		() -> errorLogStatement.accept(signal.getThrowable()));
	};
}
```

`Signal`이 실제로 `onError`인지 확인하고 해당 에러 (`Throwable`)를 로그 구문 람다에 제공한다는 점만 빼면 이전과 크게 다르지 않다.

이 헬퍼를 컨트롤러에 적용하는 것도 위에서 본 것과 매우 유사하다:

```java
@GetMapping("/byPrice")
public Flux<Restaurant> byPrice(@RequestParam Double maxPrice, @RequestHeader(required = false, name = "X-UserId") String userId) {
	String apiId = userId == null ? "" : userId;

	return restaurantService.byPrice(maxPrice))
			   .doOnEach(logOnNext(v -> LOG.info("found restaurant {}", v))
			   .doOnEach(logOnError(e -> LOG.error("error when searching restaurants", e)) // (1)
			   .subscriberContext(Context.of("CONTEXT_KEY", apiId));
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `restaurantService`가 에러를 방출하면 여기에서 MDC 컨텍스트에 로깅한다.
</small>

"[FAQ, Best Practices, and "How do I…?"](https://projectreactor.io/docs/core/release/reference/index.html#faq)" [수정 제안하기](https://github.com/reactor/reactor-core/edit/master/docs/asciidoc/faq.adoc) 

---

> 전체 목차는 [여기](../contents/)에 있습니다.