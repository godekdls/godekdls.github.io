---
title: Debugging Reactor
category: Reactor Core
order: 8
permalink: /Reactor%20Core/debuggingreactor/
description: 리액터 디버깅 한국어 번역
image: ./../../images/reactorcore/flux.png
lastmod: 2020-07-19T15:44:00+09:00
comments: true
originalRefName: 프로젝트 리액터 코어
originalRefLink: https://projectreactor.io/docs/core/3.3.7.RELEASE/reference/index.html#debugging
---

### 목차

- [7.1. The Typical Reactor Stack Trace](#71-the-typical-reactor-stack-trace)
- [7.2. Activating Debug Mode - aka tracebacks](#72-activating-debug-mode---aka-tracebacks)
- [7.3. Reading a Stack Trace in Debug Mode](#73-reading-a-stack-trace-in-debug-mode)
  + [7.3.1. The checkpoint() Alternative](#731-the-checkpoint-alternative)
- [7.4. Production-ready Global Debugging](#74-production-ready-global-debugging)
  + [7.4.1. Limitations](#741-limitations)
  + [7.4.2. Running ReactorDebugAgent as a Java Agent](#742-running-reactordebugagent-as-a-java-agent)
  + [7.4.3. Running ReactorDebugAgent at build time](#743-running-reactordebugagent-at-build-time)
- [7.5. Logging a Sequence](#75-logging-a-sequence)

---

때로는 명령형 동기 프로그래밍에서 리액티브 비동기 프로그래밍 패러다임으로 전환하기 힘들 수 있다. 러닝 커브에서 가장 가파른 단계 중 하나는 무언가 잘못됐을 때 어떻게 분석하고 디버깅할 것인가다.

명령형 세계에서 디버깅은 대부분 직관적이다. stacktrace를 읽고 어디서 문제가 생겼는지 확인하면 된다. 전적으로 작성한 코드의 문제인가? 다른 라이브러리 코드에서 실패했나? 그렇다면 잘못된 파라미터를 넘겨서 궁극적으로 실패하게 만든, 라이브러리를 호출하는 코드는 어디있는가?

---

## 7.1. The Typical Reactor Stack Trace

비동기 코드로 전환하면 훨씬 더 복잡해진다.

아래 stack trace를 한 번 살펴보자:

**Example 20. A typical Reactor stack trace**

```java
java.lang.IndexOutOfBoundsException: Source emitted more than one item
	at reactor.core.publisher.MonoSingle$SingleSubscriber.onNext(MonoSingle.java:129)
	at reactor.core.publisher.FluxFlatMap$FlatMapMain.tryEmitScalar(FluxFlatMap.java:445)
	at reactor.core.publisher.FluxFlatMap$FlatMapMain.onNext(FluxFlatMap.java:379)
	at reactor.core.publisher.FluxMapFuseable$MapFuseableSubscriber.onNext(FluxMapFuseable.java:121)
	at reactor.core.publisher.FluxRange$RangeSubscription.slowPath(FluxRange.java:154)
	at reactor.core.publisher.FluxRange$RangeSubscription.request(FluxRange.java:109)
	at reactor.core.publisher.FluxMapFuseable$MapFuseableSubscriber.request(FluxMapFuseable.java:162)
	at reactor.core.publisher.FluxFlatMap$FlatMapMain.onSubscribe(FluxFlatMap.java:332)
	at reactor.core.publisher.FluxMapFuseable$MapFuseableSubscriber.onSubscribe(FluxMapFuseable.java:90)
	at reactor.core.publisher.FluxRange.subscribe(FluxRange.java:68)
	at reactor.core.publisher.FluxMapFuseable.subscribe(FluxMapFuseable.java:63)
	at reactor.core.publisher.FluxFlatMap.subscribe(FluxFlatMap.java:97)
	at reactor.core.publisher.MonoSingle.subscribe(MonoSingle.java:58)
	at reactor.core.publisher.Mono.subscribe(Mono.java:3096)
	at reactor.core.publisher.Mono.subscribeWith(Mono.java:3204)
	at reactor.core.publisher.Mono.subscribe(Mono.java:3090)
	at reactor.core.publisher.Mono.subscribe(Mono.java:3057)
	at reactor.core.publisher.Mono.subscribe(Mono.java:3029)
	at reactor.guide.GuideTests.debuggingCommonStacktrace(GuideTests.java:995)
```

여기에선 많은 일들이 일어났다. **소스가 아이템을 한 개보다 더 많이 방출했다**고 말해주는 `IndexOutOfBoundsException`이 보인다.

그렇다면 바로 이 소스가 Flux나 Mono라고 생각해 볼 수 있는데, 다음 라인을 보면 `MonoSingle`이 언급돼서 더 확실해졌다. 따라서 `single` 연산자에서 생긴 문제로 보인다.

`Mono#single` 연산자의 Javadoc에 따르면 `single`은 "소스는 반드시 요소 한 개만 방출해야 한다"는 정의가 있다. 데이터 소스가 아이템을 하나보다 더 방출해서 이 규칙을 위반한 것으로 보인다.

더 깊게 들어가서 그 데이터 소스를 알아낼 수 있나? 그 이후 stack trace는 딱히 도움이 되지 않는다. `subscribe`와 `request`를 여러 번 호출하면서 내부 리액티브 체인이 어땠는지에 대한 정보만 보여준다.

stack trace를 훑어보면 최소한 잘못된 체인을 그려보는 것으로 시작할 수는 있다: `MonoSingle`, `FluxFlatMap`, `FluxRange`와 연관된 것으로 보인다 (모두 trace 여러 줄에 걸쳐 있지만, 전반적으로 이 세 클래스와 관련됐다). 그렇다면 `range().flatMap().single()` 체인이었을까?

하지만 어플리케이션이 이 패턴을 많이 사용하고 있다면? 이 또한 많은 것을 알려주지 않으며, 단순히 `single`을 찾는 것만으로는 문제를 알아낼 수 없다. 그런데 마지막 라인에선 우리 코드를 참조하고 있다. 드디어 조금은 가까워졌다.

그래도 잠시만. 소스 파일을 찾아보니 이미 존재하는 `Flux`를 구독하는 게 전부였다:

```java
toDebug.subscribe(System.out::println, Throwable::printStackTrace);
```

이 모든 것은 구독 시간에 발생했지만, `Flux` 자체는 여기에 선언돼있지 않다. 엎친 데 덮친 격으로, 변수가 선언된 곳으로 가보니 다음이 전부다:

```java
public Mono<String> toDebug; //please overlook the public class attribute
```

변수를 선언한 곳에서 초기화하지 않았다. 어플리케이션에서 몇 가지 다른 코드 경로로 이 값을 설정하는 최악의 시나리오도 생각해야 한다. 아직도 여전히 문제를 일으킨 코드가 무엇인지 알 수 없다.

> 이 상황은 컴파일 오류가 아닌, 리액터에서 만날 수 있는 런타임 오류다.

좀 더 쉬운 방법으로 찾아내고자 하는 것은 체인에 연산자가 추가된 위치, 즉 `Flux`를 선언한 곳이다. 보통 이를 Flux의 "어셈블리(assembly)"라고 한다.

---

## 7.2. Activating Debug Mode - aka tracebacks

> 여기서 설명하는 디버깅 활성화는 가장 쉬운 방법이지만, 모든 연산자에서 stacktrace를 수집하기 때문에 가장 느린 방법이기도 하다. 좀 더 세부적으로 디버깅하기 위한 방법은  [The `checkpoint()` Alternative](#731-the-checkpoint-alternative)를, 성능별 고급 설정법은 [Production-ready Global Debugging](#74-production-ready-global-debugging)을 참고하라.

경험이 많다면 stacktrace로도 일부 정보를 파악할 수는 있지만, 고급 사례를 생각해 보면 이 자체로는 이상적이지 않음을 알게 될 것이다.

다행히 리액터는 디버깅을 위해 설계한 어셈블리 타임 [instrumentation](https://ko.wikipedia.org/wiki/인스트루먼테이션)을 제공한다.

어플리케이션을 시작할 때 (아니면 최소한 문제가 있어 보이는 `Flux`나 `Mono`를 초기화하기 전에) 다음과 같이 `Hooks.onOperator` 훅을 커스텀하면 된다:

```java
Hooks.onOperatorDebug();
```

이렇게 하면 연산자 구조를 래핑하고 그 곳의 stack trace를 수집하는 식으로 `Flux` (또는 `Mono`) 연산자 메소드 (체인에 조립된 곳) 호출을 추적한다. 연산자 체인을 정의할 때 실행되기 때문에, 훅은 그 전에 활성화해야 하며, 가장 안전한 방법은 어플리케이션을 기동하는 시점에 활성화하는 것이다.

이후 예외가 발생하면 실패한 연산자는 수집한 내용을 참조해서 stacktrace에 추가할 수 있다. 이 수집한 어셈블리 정보를 **traceback**이라고 한다.

다음 섹션에서는 이 stack trace가 기존과는 어떻게 다른지, 어떻게 해석해야 하는지 알아볼 것이다.

---

## 7.3. Reading a Stack Trace in Debug Mode

처음 사용했던 예제를 `operatorStacktrace` 디버그 기능을 활성화하고 실행하면, stack trace는 다음과 같이 출력된다:

```java
java.lang.IndexOutOfBoundsException: Source emitted more than one item
	at reactor.core.publisher.MonoSingle$SingleSubscriber.onNext(MonoSingle.java:129)
	at reactor.core.publisher.FluxOnAssembly$OnAssemblySubscriber.onNext(FluxOnAssembly.java:375)
... // (1)

... // (2)
	at reactor.core.publisher.Mono.subscribeWith(Mono.java:3204)
	at reactor.core.publisher.Mono.subscribe(Mono.java:3090)
	at reactor.core.publisher.Mono.subscribe(Mono.java:3057)
	at reactor.core.publisher.Mono.subscribe(Mono.java:3029)
	at reactor.guide.GuideTests.debuggingActivated(GuideTests.java:1000)
	Suppressed: reactor.core.publisher.FluxOnAssembly$OnAssemblyException: // (3)
Assembly trace from producer [reactor.core.publisher.MonoSingle] : // (4)
	reactor.core.publisher.Flux.single(Flux.java:6676)
	reactor.guide.GuideTests.scatterAndGather(GuideTests.java:949)
	reactor.guide.GuideTests.populateDebug(GuideTests.java:962)
	org.junit.rules.TestWatcher$1.evaluate(TestWatcher.java:55)
	org.junit.rules.RunRules.evaluate(RunRules.java:20)
Error has been observed by the following operator(s): // (5)
	|_	Flux.single ⇢ reactor.guide.GuideTests.scatterAndGather(GuideTests.java:949) // (6)
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 새로운 정보다: stack을 수집한 래퍼 연산자를 확인할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 그 외 stack trace의 윗 부분은 대부분 동일하며, 연산자 내부 정보만 약간 보여주는 정도다 (따라서 여기 일부분은 생략했다).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 여기서부터 traceback이 보이기 시작한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> 먼저, 연산자를 조립한 곳에 관한 상세 정보를 확인할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> 연산자 체인 처음부터 끝까지 (에러 발생 지점부터 구독 지점까지) 전파된 에러의 traceback 정보도 볼 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(6)</span> 에러를 만난 모든 연산자와, 함께 사용한 사용자 클래스와 라인 정보를 담고 있다.</small>

수집한 stack trace는 기존 에러에 suppressed `OnAssemblyException`으로 덧붙여진다. 이는 두 파트로 나뉘는데, 첫 번째 파트가 가장 흥미롭다. 첫 번째 파트는 예외를 발생시킨 연산자 구성 경로를 보여준다. 여기에선 문제가 됐던 `single`이 `scatterAndGather` 메소드 안에서 생성되었으며, 이는 JUnit으로 실행한 `populateDebug` 메소드 안에서 호출했음을 보여준다.

이제 범인을 찾을 수 있을 만큼의 정보가 있으므로, `scatterAndGather` 메소드를 주의 깊게 살펴볼 수 있다:

```java
private Mono<String> scatterAndGather(Flux<String> urls) {
    return urls.flatMap(url -> doRequest(url))
           .single(); // (1)
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 아니나 다를까 여기에 `single`이 있다.</small><br>

이제 에러의 근본 원인이 `flatMap`이었음을 알 수 있다. flatMap은 몇 가지 URL에 HTTP 요청을 보내는데, 이를 사용하기엔 너무 제한적인 `single`로 연결돼있다. 잠시 `git blame`을 실행하고 이 코드를 작성한 담당자와 빠르게 논의해 보고 나서, 원래 의도한 바는 `take(1)`이었음을 알아냈다.

드디어 문제를 해결했다.

이제 stack trace에 있었던 다음 문장을 살펴보자:

```java
Error has been observed by the following operator(s):
```

이 예시에선 에러가 실제로 체인의 마지막 연산자에서 (`subscribe`와 가까운) 발생했기 때문에, stack trace 두 번째 파트는 딱히 필요 없었다. 확실히 짚고 넘어가기 위해 다른 예제를 살펴보자:

```java
FakeRepository.findAllUserByName(Flux.just("pedro", "simon", "stephane"))
              .transform(FakeUtils1.applyFilters)
              .transform(FakeUtils2.enrichUser)
              .blockLast();
```

이제 `findAllUserByName` 안에 있는 `map`이 실패한다고 가정해 보자. 이 코드는 다음과 같은 traceback을 만나고 종료된다:

```java
Error has been observed by the following operator(s):
	|_	Flux.map ⇢ reactor.guide.FakeRepository.findAllUserByName(FakeRepository.java:27)
	|_	Flux.map ⇢ reactor.guide.FakeRepository.findAllUserByName(FakeRepository.java:28)
	|_	Flux.filter ⇢ reactor.guide.FakeUtils1.lambda$static$1(FakeUtils1.java:29)
	|_	Flux.transform ⇢ reactor.guide.GuideDebuggingExtraTests.debuggingActivatedWithDeepTraceback(GuideDebuggingExtraTests.java:40)
	|_	Flux.elapsed ⇢ reactor.guide.FakeUtils2.lambda$static$0(FakeUtils2.java:30)
	|_	Flux.transform ⇢ reactor.guide.GuideDebuggingExtraTests.debuggingActivatedWithDeepTraceback(GuideDebuggingExtraTests.java:41)
```

이 traceback은 에러를 통지받은 연산자 체인과 일치한다:

1. 첫 번째 `map`에서 예외가 발생한다.
2. 두 번째 `map`도 보인다 (사실 둘 다 `findAllUserByName` 메소드에 해당한다).
3. 그다음 `filter`와 `transform`도 보이므로, 재사용할 수 있는 변환 함수로 체인 일부를 구성했다는 것을 알 수 있다 (여기서는 `applyFilters` 유틸리티 메소드).
4. 마지막으로 `elapsed`와 `transform`도 보인다. 두 번째 변환 함수에서 `elapsed`가 적용됐다.

> traceback은 기존 에러에 suppressed 예외로 덧붙여 지기 때문에, 동일 메커니즘을 사용하는 composite 예외와 혼동할 수도 있다. 이런 예외는 `Exceptions.multiple(Throwable…)`로 직접 만들거나 에러가 발생한 여러 원인을 조인하는 연산자 (`Flux#flatMapDelayError` 같은)로 생성한다. 이는 `Exceptions.unwrapMultiple(Throwable)`을 사용하면 `List`로 풀어낼 수 있으며, 이 경우 traceback은 composite의 컴포넌트로 간주하고 이  `List`에 포함시킨다. 이걸 원하지 않는다면 `Exceptions.isTraceback(Throwable)`로 traceback을 식별할 수 있으며, 대신 `Exceptions.unwrapMultipleExcludingTracebacks(Throwable)`을 사용해서 리스트에서 제외시킬 수 있다.

여기서는 instrumentation의 한 가지 유형을 다뤘으며, stack trace를 생성하는 것은 비용이 큰 작업이다. 그렇기 때문에 이 디버깅 기능은 최후의 수단으로, 통제된 방식으로만 활성화해야 한다.

###  7.3.1. The `checkpoint()` Alternative

이 디버그 모드는 전역으로 적용돼서 어플리케이션 내 `Flux`와 `Mono`에 연결되는 모든 연산자에 영향을 끼친다. 이는 사후 디버깅이 된다는 이점이 있다: 에러가 무엇이든지 간에 디버깅에 필요한 추가 정보를 볼 수 있다:

앞에서 살펴봤듯이, 전역적으로 정보를 수집하면 성능에 영향을 준다 (수집하는 stack trace 수 때문에). 원인일지도 모르는 연산자를 알고 있다면 이 문제는 해결된다. 하지만 보통은 어떤 연산자가 문제인지 알지 못한다. 출시 후 에러가 발생하고 나서 어셈블리 정보가 누락된 것을 발견하고, 어셈블리 추적을 활성화하도록 코드를 수정한 뒤 동일한 에러를 재현하길 바라는 상황이 아니라면.

이런 상황이라면, 디버깅 모드로 전환해서 다음번엔 에러를 잘 살펴볼 수 있도록 모든 추가 정보를 수집하도록 준비해야 한다.

서비스 사용성이 매우 중요한 어플리케이션에서 조립하는 리액티브 체인을 구분해낼 수 있다면, `checkpoint()` 연산자로 두 테크닉을 조합할 수 있다 (성능과 디버깅).

메소드 체인에 이 연산자를 연결하면 된다. `checkpoint`도 역시 훅으로 동작하지만, 연결된 체인만 후킹한다.

`checkpoint(String)` 메소드로는 어셈블리 traceback을 식별하기 위한 유니크한 `String description`을 추가할 수 있다. 이 방법은 stack trace를 생략하기 때문에, 이 문자열로 어셈블리 위치를 식별해야 한다. `checkpoint(String)`은 일반 `checkpoint`보다 비용이 덜 드는 작업이다.

아래처럼 `checkpoint(String)`은 "light"라는 단어를 함께 출력한다 (검색하기 편할 것이다):

```java
...
	Suppressed: reactor.core.publisher.FluxOnAssembly$OnAssemblyException:
Assembly site of producer [reactor.core.publisher.ParallelSource] is identified by light checkpoint [light checkpoint identifier].
```

마지막으로, checkpoint에 사용할 문자열이 좀 일반적인 설명이라서 stack trace로 어셈블리 위치를 찾아야 한다면, `checkpoint("description", true)`로 stack trace 사용을 강제할 수 있다. `description`을 인자로 받는 최초 traceback 메세지로 돌아가 보자:

```java
Assembly trace from producer [reactor.core.publisher.ParallelSource], described as [descriptionCorrelation1234] : // (1)
	reactor.core.publisher.ParallelFlux.checkpoint(ParallelFlux.java:215)
	reactor.core.publisher.FluxOnAssemblyTest.parallelFluxCheckpointDescriptionAndForceStack(FluxOnAssemblyTest.java:225)
Error has been observed by the following operator(s):
	|_	ParallelFlux.checkpoint ⇢ reactor.core.publisher.FluxOnAssemblyTest.parallelFluxCheckpointDescriptionAndForceStack(FluxOnAssemblyTest.java:225)
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `descriptionCorrelation1234`가 `checkpoint`에 사용한 description이다.</small>

description으로는 정적 식별자나, 사용자가 읽을 설명, 또는 다른 연관된 ID를 (예를 들어  HTTP 요청은 헤더에 있는 값) 사용할 수 있다.

>  글로벌 디버깅과 로컬 `checkpoint()`를 모두 활성화하면, 체크포인트의 스냅샷 스택은 연산자 그래프 다음에 선언한 순서대로  suppressed 에러로 덧붙여진다.

---

## 7.4. Production-ready Global Debugging

프로젝트 리액터에는 모든 연산자를 호출할 때마다 stacktrace를 수집하지 않고도 코드를 추적하고 디버깅 정보를 추가해 주는 별도의 자바 에이전트가 있다. [traceback](#72-activating-debug-mode---aka-tracebacks)과 유사하게 동작하지만, 실행 시 성능에 오버헤드가 없다.

이를 사용하려면 의존성을 먼저 추가해야 한다.

다음은 메이븐으로 `reactor-tools` 의존성을 추가하는 예제다:

**Example 21. reactor-tools in Maven, in** `<dependencies>`

```xml
<dependency>
    <groupId>io.projectreactor</groupId>
    <artifactId>reactor-tools</artifactId>
    <!-- (1) -->
</dependency>
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> [BOM](../gettingstarted#24-getting-reactor)을 사용한다면, `<version>`은 명시하지 않아도 된다.</small>

다음은 그래들로 `reactor-tools` 의존성을 추가하는 예제다:

**Example 22. reactor-tools in Gradle, amend the** `dependencies` **block**

```gradle
dependencies {
   compile 'io.projectreactor:reactor-tools'
}
```

또한 명시적으로 에이전트를 초기화해야 한다:

```java
ReactorDebugAgent.init();
```

> 클래스를 로드할 때 추적하기 때문에 이 코드는 main(String[]) 메소드의 첫 라인에 두는 것이 가장 좋다.

```java
public static void main(String[] args) {
    ReactorDebugAgent.init();
    SpringApplication.run(Application.class, args);
}
```

한 번에 초기화할 수 없다면 (테스트 등) 기존 클래스를 다시 처리해야 할 수도 있다:

```java
ReactorDebugAgent.init();
ReactorDebugAgent.processExistingClasses();
```

> 재처리는 로드된 모든 클래스를 순회하고 변환해야 하기 때문에 수초가 걸릴 수 있음을 알아둬라. 추적하지 않은 호출 지점이 있을 때만 사용해라.

### 7.4.1. Limitations

`ReactorDebugAgent`는 자바 에이전트로 구현했으며, 어플리케이션에 붙을 때는 [ByteBuddy](https://bytebuddy.net/#/)를 사용한다. 이 Self-attach는 일부 JVM에서는 동작하지 않을 수도 있으므로, 자세한 정보는 ByteBuddy 문서를 참고하라.

### 7.4.2. Running ReactorDebugAgent as a Java Agent

ByteBuddy의 self-attachment를 지원하지 않는 환경이라면 `reactor-tools`를 자바 에이전트로 실행할 수 있다:

```bash
java -javaagent reactor-tools.jar -jar app.jar
```

### 7.4.3. Running ReactorDebugAgent at build time

`reactor-tools`는 빌드 시점에 실행하는 것도 가능하다. 이때는 플러그인으로 ByteBuddy의 빌드 [instrumentation](https://ko.wikipedia.org/wiki/인스트루먼테이션)을 적용한다.

>  이때는 프로젝트에 속한 클래스만 변환한다. 클래스 패스에 있는 라이브러리는 추적하지 않는다.

**Example 23. reactor-tools with** [ByteBuddy’s Maven plugin](https://github.com/raphw/byte-buddy/tree/byte-buddy-1.10.9/byte-buddy-maven-plugin)

```xml
<dependencies>
	<dependency>
		<groupId>io.projectreactor</groupId>
		<artifactId>reactor-tools</artifactId>
		<!-- (1) -->
		<classifier>original</classifier> <!-- (2) -->
		<scope>runtime</scope>
	</dependency>
</dependencies>

<build>
	<plugins>
		<plugin>
			<groupId>net.bytebuddy</groupId>
			<artifactId>byte-buddy-maven-plugin</artifactId>
			<configuration>
				<transformations>
					<transformation>
						<plugin>reactor.tools.agent.ReactorDebugByteBuddyPlugin</plugin>
					</transformation>
				</transformations>
			</configuration>
		</plugin>
	</plugins>
</build>
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> [BOM](../gettingstarted#24-getting-reactor)을 사용한다면, `<version>`은 명시하지 않아도 된다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 여기 `classifier`가 중요하다.</small>

**Example 24. reactor-tools with** [ByteBuddy’s Gradle plugin](https://github.com/raphw/byte-buddy/tree/byte-buddy-1.10.9/byte-buddy-gradle-plugin)

```gradle
plugins {
	id 'net.bytebuddy.byte-buddy-gradle-plugin' version '1.10.9'
}

configurations {
	byteBuddyPlugin
}

dependencies {
	byteBuddyPlugin(
			group: 'io.projectreactor',
			name: 'reactor-tools',
			// (1)
			classifier: 'original', // (2)
	)
}

byteBuddy {
	transformation {
		plugin = "reactor.tools.agent.ReactorDebugByteBuddyPlugin"
		classPath = configurations.byteBuddyPlugin
	}
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> [BOM](../gettingstarted#24-getting-reactor)을 사용한다면, `<version>`은 명시하지 않아도 된다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 여기 `classifier`가 중요하다.</small>

---

## 7.5. Logging a Sequence

stack trace 디버깅, 분석 외에도 툴킷에 있는 다른 툴을 사용하면 비동기 시퀀스의 이벤트를 추적하고 로깅할 수 있다.

이는 `log()` 연산자로 가능하다. 시퀀스 안으로 연결돼서, 업스트림 `Flux`, `Mono`의 모든 연산자를 확인할 수 있다 (`onNext`, `onError`, `onComplete` 외 구독, 취소, 요청 이벤트 포함).

> <big>**로그 구현체를 사용할 때 주의할 점**</big>
>
> `log` 연산자는 `Loggers` 유틸리티 클래스를 사용하며, 이 클래스는 `SLF4J`와 Log4J/Logback 조합 같은 공통 로깅 프레임워크를 사용한다. SLF4J가 없다면 디폴트로 콘솔에 로깅한다.
>
> 로그 레벨이 `WARN`, `ERROR`일 때 콘솔 fallback은  `System.err`를, 그 외는 모두 `System.out`을 사용한다.
>
> 3.0.x에서처럼 JDK `java.util.logging` fallback을 사용하고 싶다면 시스템 프로퍼티 `reactor.logging.fallback`을 `JDK`로 설정하라.
>
> 무엇을 사용하든 간에, 프로덕션 환경에서 로깅하려면 **이 로깅 프레임워크가 최대한 비동기, 논블로킹 접근법을 사용하도록 신경 써야 한다** — 예를 들어 Logback의 `AsyncAppender` 또는 Log4j 2의 `AsyncLogger`.
>

예를 들어 Logback을 사용하도록 설정했고, `range(1,10).take(3)` 같은 체인이 있다고 가정해보자. 다음과 같이  `take` 앞에 `log()`를 사용하면 어떻게 동작했고 어떤 이벤트를 range 업스트림에 전파시켰는지 알 수 있다:

```java
Flux<Integer> flux = Flux.range(1, 10)
                         .log()
                         .take(3);
flux.subscribe();
```

이 코드는 다음을 출력한다 (로거의 콘솔 어펜더 사용):

```java
10:45:20.200 [main] INFO  reactor.Flux.Range.1 - | onSubscribe([Synchronous Fuseable] FluxRange.RangeSubscription) // (1)
10:45:20.205 [main] INFO  reactor.Flux.Range.1 - | request(unbounded) // (2)
10:45:20.205 [main] INFO  reactor.Flux.Range.1 - | onNext(1) // (3)
10:45:20.205 [main] INFO  reactor.Flux.Range.1 - | onNext(2)
10:45:20.205 [main] INFO  reactor.Flux.Range.1 - | onNext(3)
10:45:20.205 [main] INFO  reactor.Flux.Range.1 - | cancel() // (4)
```
<small>이때는 로거의 기본 포맷터 (시간, 스레드, 레벨, 메세지) 외에 `log()` 연산자가 자체 포맷으로 몇 가지를 더 출력한다:</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 체인 하나에서 이 연산자를 여러 번 사용할 수도 있기 때문에, 이 로그는 자동으로 `reactor.Flux.Range.1`로 분류된다. 이를 통해 어떤 연산자의 이벤트를 로깅한 것인지 구별할 수 있다 (여기선 `range`). `log(String)` 메소드를 사용하면 커스텀해서 분류할 수 있다. 몇 가지 구분자 다음에는 실제 이벤트를 출력했다. 여기서는 `onSubscribe` 한 번, `request` 한 번, `onNext` 세 번, `cancel`  한 번을 호출했다. 첫 번째 줄에 있는 `onSubscribe`에는 `Subscriber` 구현체가 있는데, 이는 연산자마다 있는 일반적인 구현체에 해당한다. 대괄호 사이에는 연산자를 동기나 비동기를 결합했을 때 자동으로 최적화할 수 있는지 여부를 포함한 추가 정보가 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 두 번째 줄을 보면 다운스트림으로부터 언바운드 요청이 전파됐음을 알 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 그다음 range는 연이어 값 세 개를 전송한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> 마지막 줄엔 `cancel()`이 보인다.</small>

(4)의 마지막 줄이 가장 흥미롭다. 여기엔 `take`가 있다. 이 연산자는 방출된 요소가 충분하면 시퀀스를 잘라낸다. 바로 이 `take()`가, 소스가 사용자 요청량만큼 방출한 다음에 `cancel()`하게 만든 것이다.

"[Debugging Reactor](https://projectreactor.io/docs/core/3.3.7.RELEASE/reference/index.html#debugging)" [수정 제안하기](https://github.com/reactor/reactor-core/edit/master/docs/asciidoc/debugging.adoc)
