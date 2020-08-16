---
title: Introduction to Reactive Programming
category: Reactor Core
order: 4
permalink: /Reactor%20Core/introductiontoreactiveprogramming/
description: 리액터 리액티브 프로그래밍 소개 한글 번역
image: ./../../images/reactorcore/flux.png
lastmod: 2020-07-15T00:00:00+09:00
comments: true
---

> [프로젝트 리액터 코어 공식 레퍼런스](https://projectreactor.io/docs/core/release/reference/#intro-reactive)를 한글로 번역한 문서입니다.
>
> 전체 목차는 [여기](../contents/)에 있습니다.

{% include adsense.html %}

### 목차

- [3.1. Blocking Can Be Wasteful](#31-blocking-can-be-wasteful)
- [3.2. Asynchronicity to the Rescue?](#32-asynchronicity-to-the-rescue)
- [3.3. From Imperative to Reactive Programming](#33-from-imperative-to-reactive-programming)
  + [3.3.1. Composability and Readability](#331-composability-and-readability)
  + [3.3.2. The Assembly Line Analogy](#332-the-assembly-line-analogy)
  + [3.3.3. Operators](#333-operators)
  + [3.3.4. Nothing Happens Until You subscribe()](#334-nothing-happens-until-you-subscribe)
  + [3.3.5. Backpressure](#335-backpressure)
  + [3.3.6. Hot vs Cold](#336-hot-vs-cold)

---

리액터는 리액티브 프로그래밍 패러다임의 구현체다. 리액티브 프로그래밍은 다음과 같이 요약할 수 있다:

> 리액티브 프로그래밍은 데이터 스트림과 변경 사항 전파에 초점을 둔 비동기 프로그래밍 패러다임이다. 이는 정적(e.g. 배열) 혹은 동적(e.g. 이벤트 발생기) 데이터 스트림을 손쉽게 원하는 프로그래밍 언어로 표현할 수 있다는 뜻이다.
>
> 
>
> — https://en.wikipedia.org/wiki/Reactive_programming

마이크로소프트가 닷넷(.NET) 생태계에 만든 Reactive Extension(Rx) 라이브러리가 반응형 프로그래밍의 출발점이었다. 이후 RxJava는 JVM 위에서 실행하는 리액티브 프로그래밍을 구현했다. 시간이 지남에 따라, 리액티브 스트림 표준화의 일환으로 JVM 위에서 동작하는 리액티브 라이브러리의 인터페이스 셋과 상호작용 규칙을 정의한 자바 표준이 등장했다. 이 인터페이스들은 자바 9의 `Flow` 클래스로 통합됐다.

리액티브 프로그래밍 패러다임은 객체 지향 언어에서 종종 옵저버 디자인 패턴의 확장으로 사용되기도 한다. 메인 리액티브 스트림 패턴을 익숙한 이터레이터 디자인 패턴과 비교해 볼 수도 있다. 리액티브 스트림을 구현한 모든 라이브러리는 `Iterable`-`Iterator` 쌍과 성격이 유사하다. 주요 차이점 중 하나는 이터레이터는 pull 기반, 리액티브 스트림은 push 기반이라는 것이다.

이터레이터를 사용한다는 것은, 값에 접근하는 건 전적으로 `Iterable` 책임이라고 하지만, 어쨌든 명령형 프로그래밍 패턴이다. 사실상 데이터 시퀀스에서 `next()` 아이템에 접근하는 것은 개발자에 달려 있다. 리액티브 스트림에선 `Publisher-Subscriber` 쌍이 이를 대신한다. 단, *새로운 데이터가 있음*을 `Publisher`가 Subscriber에게 통지하며, 이런 push 방식이 리액티브의 핵심이다. 또한, push 받은 데이터에 적용할 연산은 명령형이 아닌 선언형으로 표현한다: 프로그래머는 정확한 제어 흐름을 작성하는 대신 계산 논리를 표현한다.

리액티브 스트림은 데이터를 push하는 것 외에 에러 처리와 완료 처리도 잘 정의하고 있다. `Publisher`는 `Subscriber`에 새 값을 푸쉬할 수 있을 뿐 아니라(`onNext` 호출함으로써), 에러(`onError` 호출)나 완료(`onComplete` 호출) 신호를 보낼 수도 있다. 에러, 완료 신호 모두 시퀀스를 종료한다. 이는 다음과 같이 요약된다:

```
onNext x 0..N [onError | onComplete]
```

이 접근법은 굉장히 유연하다. 값이 없거나, 하나거나, n개일 때를(연속적인 시간 값 같은 무한 시퀀스도 포함) 모두 커버한다.

그렇지만 애초에 이런 비동기 리액티브 라이브러리가 필요한 이유는 무엇일까?

---

## 3.1. Blocking Can Be Wasteful

최신 어플리케이션은 수많은 동시 사용자의 요청을 처리하고 있으며, 하드웨어 처리량이 계속 개선되고는 있지만 소프트웨어 성능은 여전히 주요 관심사다.

프로그램의 성능을 끌어 올리는 방법은 크게 두 가지가 있다:

- 더 많은 스레드와 하드웨어 리소스를 사용해 **병렬 처리**한다.
- 현재 사용 중인 리소스를 더 **효율적으로 사용**할 방법을 찾는다.

자바 개발자는 보통 블로킹 코드로 프로그램을 작성한다. 성능에 병목이 생기지만 않는다면 이 방법도 괜찮다. 이때까진 유사한 블로킹 코드를 실행할 스레드를 늘리면 된다. 하지만 이 방식은 리소스를 더 사용하는 쪽으로 확장하기 때문에 경합이나 동시성 이슈가 발생하기 쉽다.

더 큰 문제는 블로킹은 리소스를 낭비한다는 점이다. 자세히 관찰해보면, 대기 시간이 필요한 요청을 처리하기 시작하면(주로 데이터베이스 요청이나 네트워크 호출 같은 I/O), 스레드는(아마 꽤 많은 양이) 데이터를 기다리는 동안 아무 일도 하지 않는다.

따라서 병렬 처리는 만능 해결책이 아니다. 가능한 한 하드웨어 리소스를 전부 사용하는 게 좋지만, 리소스를 낭비하는 경우는 생각보다 많으며 원인을 알아내는 것은 복잡한 일이다.

---

## 3.2. Asynchronicity to the Rescue?

위에서 언급한 두 번째 방식대로, 리소스 효율적으로 사용할 방법을 찾는다면 리소스를 낭비하지 않을 수 있다. 비동기, 논블로킹 코드를 작성하면 동일 리소스를 사용하는 또 하나의 활성 태스크로 실행을 전환하고, 비동기 처리를 완료하면 현재 프로세스로 돌아올 수 있다.

그렇다면 JVM 위에서 동작하는 비동기 코드는 어떻게 만드는 걸까? 자바는 비동기 프로그래밍을 위한 두 가지 모델을 제공한다:

- **Callbacks**: 리턴 값은 없지만 결과를 받으면 호출할 `callback` 파라미터를(람다나 익명 클래스) 추가로 받는 비동기 메소드. 스윙의 `EventListener` 계층 구조로 잘 알려져 있다.
- **Futures**: *곧바로* `Future<T>`를 반환하는 비동기 메소드. 비동기 프로세스는 `T` 값을 계산하고, 이를 래핑한 `Future` 객체로 접근한다. 이 값은 즉시 사용할 수 있는 상태는 아니며, 사용이 가능해질 때까지 객체를 폴링할 수 있다. 예를 들어, `ExecutorService`는 `Callable<T>` 태스크를 실행할 때  `Future` 객체를 사용한다.

이 기법으로 충분할까? 이 또한 모든 사례를 해결해주진 못하며, 두 방법 다 제약이 있다.

콜백은 조합하기가 까다롭기 때문에, 읽기도 유지 보수하기도 어려운 코드를 만들어 내기 쉽다(일명 "콜백 지옥").

예를 들어 사용자의 상위 즐겨찾기 5개를, 혹은 즐겨 찾기가 없다면 추천 정보를 UI에 노출하는 경우를 생각해 보자. 이는 다음과 같이 세 종류의 서비스를 거친다(즐겨 찾기 ID 조회, 즐겨 찾기 상세 정보 조회, 추천 정보 조회)

**Example 5. Example of Callback Hell**
```java
userService.getFavorites(userId, new Callback<List<String>>() { // (1)
  public void onSuccess(List<String> list) { // (2)
    if (list.isEmpty()) { // (3)
      suggestionService.getSuggestions(new Callback<List<Favorite>>() {
        public void onSuccess(List<Favorite> list) { // (4)
          UiUtils.submitOnUiThread(() -> { // (5)
            list.stream()
                .limit(5)
                .forEach(uiList::show); // (6)
            });
        }

        public void onError(Throwable error) { // (7)
          UiUtils.errorPopup(error);
        }
      });
    } else {
      list.stream() // (8)
          .limit(5)
          .forEach(favId -> favoriteService.getDetails(favId, // (9)
            new Callback<Favorite>() {
              public void onSuccess(Favorite details) {
                UiUtils.submitOnUiThread(() -> uiList.show(details));
              }

              public void onError(Throwable error) {
                UiUtils.errorPopup(error);
              }
            }
          ));
    }
  }

  public void onError(Throwable error) {
    UiUtils.errorPopup(error);
  }
});
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 콜백 기반 서비스: `Callback` 인터페이스는 비동기 처리가 성공하면 실행할 메소드와 실패하면 호출할 메소드를 가지고 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 첫 번째 서비스는 즐겨 찾기 ID 리스트를 가져오면 콜백을 실행한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 이 리스트가 비어 있다면, `suggestionService`로 넘어가야 한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> `suggestionService`는  두 번째 콜백에 `List<Favorite>`를 전달한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> UI를 처리하고 있기 때문에, UI 스레드에서 데이터를 소비해야 한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(6)</span> 자바 8 `Stream`을 사용해 추천 조회를 다섯 번으로 제한하고, UI 그래픽 리스트에 보여준다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(7)</span> 모든 레벨에서 동일한 방식으로 에러를 처리한다: 팝업을 띄운다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(8)</span> 즐겨찾기 ID로 돌아와서, 서비스에서 비어있지 않은 리스트를 리턴하면, `favoriteService`로 `Favorite` 객체를 조회한다. 5개만 있으면 되기 때문에 먼저 ID 리스트 스트림을 5로 제한한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(9)</span> 여기서도 또 한 번 콜백. 이번엔 UI 스레드에서 바로 UI에 노출할 `Favorite` 객체를 조회한다.</small>

이 코드는 양이 많아 따라가기 어렵고, 반복되는 부분도 많다. 이 코드를 리액터로 작성하면 다음과 같다:

**Example 6. Example of Reactor code equivalent to callback code**

```java
userService.getFavorites(userId) // (1)
           .flatMap(favoriteService::getDetails) // (2)
           .switchIfEmpty(suggestionService.getSuggestions()) // (3)
           .take(5) // (4)
           .publishOn(UiUtils.uiThreadScheduler()) // (5)
           .subscribe(uiList::show, UiUtils::errorPopup); // (6) 
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 즐겨찾기 ID 리스트로 플로우를 시작한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> ID 리스트를 *비동기로* `Favorite` 객체로 변환한다(`flatMap`). 이제 플로우는 `Favorite`을 갖고 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> `Favorite` 플로우가 비었다면, `suggestionService`를 호출해 fallback 값으로 전환한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> flow는 최대 5개만 있으면 된다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> 마지막은 UI 스레드로 각 데이터를 처리한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(6)</span> 최종 데이터로 할 일과(UI 리스트 노출) 에러가 발생하면 할일을(팝업 노출) 지정해 플로우를 트리거링한다.</small>

즐겨 찾기 ID를 조회하는 시간을 800ms 미만으로 제한하고, 그 이상은 캐시에서 조회하려면 어떻게 해야 할까? 콜백 기반 코드에선 꽤 복잡한 작업이다. 리액터라면 문제가 쉬워지는데, 다음과 같이 체인에 타임 아웃 연산자를 추가하기만 하면 된다:

**Example 7. Example of Reactor code with timeout and fallback**

```java
userService.getFavorites(userId)
           .timeout(Duration.ofMillis(800)) // (1)
           .onErrorResume(cacheService.cachedFavoritesFor(userId)) // (2)
           .flatMap(favoriteService::getDetails) // (3)
           .switchIfEmpty(suggestionService.getSuggestions())
           .take(5)
           .publishOn(UiUtils.uiThreadScheduler())
           .subscribe(uiList::show, UiUtils::errorPopup);
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 이 전 코드에서 800ms 내로 값을 내보내지 않으면 에러를 전파시킨다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 에러 발생 시엔 `cacheService`로 대응한다(fallback).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 나머지 체인은 이전 예제와 유사하다.</small>

`Future` 객체는 콜백보다 여러 면으로 더 낫고 자바 8 `CompletableFuture`로 좀 더 개선되기도 했지만, 조합해서 쓰긴 여전히 어렵다. `Future` 객체 여러 개를 조율하기란 가능은 하지만 쉽지 않다. `Future`는 다른 문제도 있다:

- `Future` 객체는 `get()` 메소드를 호출하면 결국 블로킹된다.
- 지연 연산(lazy computation)을 지원하지 않는다.
- 멀티 밸류에 대한 지원이 부족하며, 에러 처리를 커스텀하기 어렵다.

다른 예제를 살펴보자: 이름과 통계정보를 쌍으로 조회하고 싶은 데이터의 ID 리스트를 가져오고, 모든 동작을 비동기로 처리한다고 생각해보자. 다음 예제는 `CompletableFuture` 타입의 리스트를 사용한다:

**Example 8. Example of `CompletableFuture` combination**

```java
CompletableFuture<List<String>> ids = ifhIds(); // (1)

CompletableFuture<List<String>> result = ids.thenComposeAsync(l -> { // (2)
	Stream<CompletableFuture<String>> zip =
			l.stream().map(i -> { // (3)
				CompletableFuture<String> nameTask = ifhName(i); // (4)
				CompletableFuture<Integer> statTask = ifhStat(i); // (5)

				return nameTask.thenCombineAsync(statTask, (name, stat) -> "Name " + name + " has stats " + stat); // (6)
			});
	List<CompletableFuture<String>> combinationList = zip.collect(Collectors.toList()); // (7)
	CompletableFuture<String>[] combinationArray = combinationList.toArray(new CompletableFuture[combinationList.size()]);

	CompletableFuture<Void> allDone = CompletableFuture.allOf(combinationArray); // (8)
	return allDone.thenApply(v -> combinationList.stream()
			.map(CompletableFuture::join) // (9)
			.collect(Collectors.toList()));
});

List<String> results = result.join(); // (10)
assertThat(results).contains(
		"Name NameJoe has stats 103",
		"Name NameBart has stats 104",
		"Name NameHenry has stats 105",
		"Name NameNicole has stats 106",
		"Name NameABSLAJNFOAJNFOANFANSF has stats 121");
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 처리할 `id` 리스트를 가져오는 future로 시작한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> `id` 리스트를 가져오고 나면 좀 더 복잡한 비동기 처리를 시작한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 리스트에 있는 각 요소에 대해:</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> 비동기로 관련 이름을 조회한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> 비동기로 관련 태스크를 구한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(6)</span> 두 결과를 합친다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(7)</span> 이제 모든 태스크의 조합을 의미하는 future 리스트를 수집했다. 이 태스크를 수행하려면 리스트를 배열로 변환해야 한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(8)</span> 배열을 `CompletableFuture.allOf`로 넘겨 모든 태스크가 완료돼야 완료하는 `Future` 객체를 얻는다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(9)</span> 이 부분은 좀 번거로운데, `allOf`은 `CompletableFuture<Void>`를 리턴하므로, 또 한 번 future 리스트를 순회해서 `join()`으로 결과를 수집해야 한다 (이 경우엔 `allOf`가 모든 future가 완료되었음을 보장하기 때문에 블로킹이 아니다).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(10)</span> 모든 비동기 파이프라인을 트리거링하고 나면, 처리를 완료하고 결과 리스트를 반환할 때까지 기다렸다가 검증할 수 있다.</small>

리액터는 조합을 위한 연산자가 훨씬 많기 때문에 더 간단해진다:

**Example 9. Example of Reactor code equivalent to future code**
```java
Flux<String> ids = ifhrIds(); // (1)

Flux<String> combinations =
		ids.flatMap(id -> { // (2)
			Mono<String> nameTask = ifhrName(id); // (3)
			Mono<Integer> statTask = ifhrStat(id); // (4)

			return nameTask.zipWith(statTask, // (5)
					(name, stat) -> "Name " + name + " has stats " + stat);
		});

Mono<List<String>> result = combinations.collectList(); // (6)

List<String> results = result.block(); // (7)
assertThat(results).containsExactly( // (8)
		"Name NameJoe has stats 103",
		"Name NameBart has stats 104",
		"Name NameHenry has stats 105",
		"Name NameNicole has stats 106",
		"Name NameABSLAJNFOAJNFOANFANSF has stats 121"
);
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 이번에는 비동기로 제공하는 `ids` 시퀀스로 시작한다 (`Flux<String>`).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 시퀀스 내 각 요소에 대해 두 번의 비동기 처리를 수행한다 (`flatMap` 내부  함수에서).</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 관련 이름을 조회한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> 관련 통계 정보를 조회한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> 두 값을 비동기로 조합한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(6)</span> 모든 조합을 가져오고 나면 값을 `List`로 합친다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(7)</span> 프로덕션 코드라면 `Flux`로 다른 비동기 처리를 이어가거나 결과를 구독했을 것이다. 아마도 `Mono result`를 리턴했을 것이다. 테스트 중이므로 그 대신 블로킹해서, 처리를 끝내고 리스트 자체를 리턴할  때까지 기다린다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(8)</span> 결과를 검증한다.</small><br>

콜백과 `Future` 객체의 한계는 유사하며, 바로 이 점이 리액티브 프로그래밍에서 `Publisher-Subscriber` 쌍으로 해결하고자 하는 점이다.

---

## 3.3. From Imperative to Reactive Programming

리액터 같은 리액티브 라이브러리의 목적은 JVM의 "고전적인" 비동기 접근법의 문제를 해결하는 것이며, 다음과 같은 특징이 있다:

- **쉽게 구성**할 수 있고, **가독성** 있다
- 데이터는 풍부한 **연산자**로 조작할 수 있는 **플로우**로 표현한다
- **구독**하기 전까진 아무 일도 일어나지 않는다
- **Backpressure** 즉, *컨슈머가 프로듀서에 데이터 생산 속도가 너무 빠르는 신호를 보낼 수 있다*
- **고수준**이면서도 *동시성에 구애받지 않을 정도의*  **높은 수준**으로 추상화한다

### 3.3.1. Composability and Readability

"쉽게 구성할 수 있다"는 것은 여러 비동기 태스크를 조율할 수 있다는 것이다. 이전 태스크의 결과는 다음 태스크의 입력으로 사용한다. 또는 포크-조인 스타일로 여러 태스크를 실행할 수도 있다. 추가로, 고수준 시스템에선 비동기 태스크를 별개의 컴포넌트로 재사용할 수 있다.

여러 태스크를 조율하는 능력은 코드 가독성과 유지보수성에 직결된다. 비동기 처리 레이어가 늘어나고 복잡해지면서, 코드를 구성하고 읽기가 점점 더 어려워지고 있다. 콜백 모델은 간단하지만 위에서 살펴봤듯이, 처리가 복잡해지면 콜백에서 또다시 콜백을 실행하고, 그 안에 또 다른 콜백을 감싸야 하는 큰 단점이 있다. 이는 "콜백 지옥"으로 잘 알려져 있다. 짐작할 수 있듯 (혹은 경험을 통해 알 수 있듯), 이런 코드는 흐름을 따라가 무언가를 추론해내기가 매우 어렵다.

리액터는 추상적인 처리 흐름을 반영할 수 있는 풍부한 구성 옵션을 제공하며, 이를 사용하면 코드를 최대한 동일 레벨로 유지할 수 있다 (중첩을 최소화한다).

### 3.3.2. The Assembly Line Analogy

리액티브 어플리케이션에서 처리하는 데이터는 공장 조립 라인을 통해 이동한다고 생각해 볼 수 있다. 리액터는 컨베이어 벨트이자 워크스테이션이다. 공급원(`Publisher`)이 제공한 원료를 소비자(`Subscriber`)에게 전달할 수 있는 완제품으로 만든다.

원료는 변형 등의 중간 단계 여럿을 거칠 수 있고, 중간 단계 재료를 모으는 더 큰 조립 라인의 일부일 수도 있다. 중간에 결함이 생기거나 막힌다면 (제품을 포장하는 데 시간이 너무 오래 걸린다든가), 문제가 있는 워크스테이션이 신호를 거슬러 보내(업스트림) 원료 흐름을 제한할 수 있다.

### 3.3.3. Operators

리액터에서 연산자는 조립 라인으로 비유하자면 워크스테이션이다. 각 연산자는 `Publisher`에 동작을 추가하고, 이전 단계의 `Publisher`를 새 인스턴스로 래핑한다. 따라서 전체 체인이 연결돼고, 최초 `Publisher`에서 시작된 데이터를 변환해서 다음 체인으로 이동시킨다. 마지막엔 `Subscriber`가 처리를 종료한다. 곧 언급하겠지만, `Subscriber`가 `Publisher`를 구독하기 전까진 아무 일도 일어나지 않는다는 점을 기억하라.

> 흔히들 하는 실수로, 종종 체인에 사용한 연산자가 적용되지 않는다는 오해를 하곤 한다. 연산자가 새 인스턴스를 만든다는 것을 이해하고 나면, 무엇이 문제인지 알 수 있을 것이다. FAQ의 이 [항목](../appendixbfaqbestpracticesandhowdoi/#b2-i-used-an-operator-on-my-flux-but-it-doesnt-seem-to-apply-what-gives)을 참고하라.

리액티브 스트림 스펙은 연산자를 정의하고 있지 않지만, 리액터 같은 리액티브 라이브러리의 가장 좋은 점 중 하나는 풍부한 연산자를 제공한다는 것이다. 이 연산자로 간단한 변환이나 필터링에서부터 복잡한 조율과 에러 처리까지 할 수 있다.

### 3.3.4. Nothing Happens Until You `subscribe()`

리액터에선 `Publisher` 체인을 작성한다고 해서 바로 데이터를 공급하지 않는다. 대신에 비동기 처리를 위한 추상적인 흐름을 작성해야 한다 (재사용과 플로우 구성에 도움이 될 것이다).

**구독**을 해야 `Publisher`와 `Subscriber`가 연결되고, 전체 체인에 데이터 흐름이 트리거된다. 내부적으로는 `Subscriber`의 단일 **요청** 신호가 업스트림으로 전파돼 구독 중인 `Publisher`로 전달된다.

### 3.3.5. Backpressure

**backpressure**를 구현할 때도 신호를 업스트림으로 전파한다. 위에서 조립 라인에 비유할 때 언급했던, 워크스테이션이 상위 워크스테이션보다 처리가 느릴 때 피드백으로 보낸다던 신호가 바로 backpressure다.

이 비유는 실제로 리액티브 스트림 스펙에 정의된 메커니즘과 매우 유사하다: 구독자는 *언바운드* 모드로 데이터 소스로부터 발생하는 모든 데이터를 제일 빠른 속도로 푸시 받거나, `request` 메커니즘으로 최대 `n`개를 처리할 준비가 되었다는 신호를 보낸다.

중간 연산자로 전송 중인 요청을 변경할 수도 있다. 10개의 배치 데이터를 그룹화하는 `buffer` 연산자를 생각해 보자. 구독자가 버퍼 하나를 요청하면, 데이터 소스는 데이터 10개를 생산할 수 있다. 일부 연산자는 **prefetching** 전략을 구현하는데, 이는 불필요한 `request(1)` 왕복을 방지하며, 요청 전 미리 데이터를 생성해 두는 비용이 크지 않다면 더 유리하다.

이는 푸시 모델 대신 **push-pull 하이브리드** 모델을 사용하는데, 데이터가 있다면 다운스트림이 업스트림에 데이터 n개를 pull할 수 있다. 하지만 데이터가 준비되지 않은 경우엔 데이터를 생산했을 때 업스트림이 push한다.

### 3.3.6. Hot vs Cold

리액티브 Rx 라이브러리들은 리액티브 시퀀스를 크게 **hot**과 **cold**로 나눈다. 이는 주로 리액티브 스트림이 구독자에게 반응하는 방식으로 구분한다.

- **Cold** 시퀀스는 각 `Subscriber`마다 데이터 소스를 포함해서 새로 시작한다. 예를 들어, 데이터 소스가 HTTP 호출을 래핑하고 있다면, 구독할 때마다 HTTP 요청을 새로 만든다.
- **Hot** 시퀀스는 `Subscriber`마다 매번 처음부터 만들지 않는다. 그보단 나중에 구독한 구독자는 구독 *이후* 생산한 신호를 받는다. 단, 일부 hot 리액티브 스트림은 생산 데이터 전체 혹은 일부를 캐시해 두거나 이전 데이터를 재사용할 수 있다. 일반적인 관점으로 보면, hot 시퀀스는 구독자가 없을 때도 발생할 수 있다 (이때는 예외적으로 "구독하기 전에 아무 일도 일어나지 않는다"는 규칙이 적용되지 않는다).

리액터에서의 hot vs cold 개념에 대해 자세히 알고 싶다면, [여기 리액터 전용 섹션](../advancedfeaturesandconcepts#92-hot-versus-cold)을 참고하라.

"[Introduction to Reactive Programming](https://projectreactor.io/docs/core/release/reference/#intro-reactive)" [수정 제안하기](https://github.com/reactor/reactor-core/edit/master/docs/asciidoc/reactiveProgramming.adoc)

---

> 전체 목차는 [여기](../contents/)에 있습니다.