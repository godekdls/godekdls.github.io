---
title: Writing client libraries
category: Prometheus
order: 45
permalink: /Prometheus/writing-clientlibs/
description: 프로메테우스 클라이언트 라이브러리 작성 가이드
image: ./../../images/prometheus/logo.png
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/instrumenting/writing_clientlibs/
parent: INSTRUMENTING
parentUrl: /Prometheus/instrumenting/
---

---

이 문서에선 프로메테우스 클라이언트 라이브러리가 제공해야 하는 기능과 API를 설명한다. 이 가이드를 따라하면 라이브러리 전체에서 일관성을 유지할 수 있기 때문에, 사용하기 좋은 유스 케이스를 손쉽게 만들고, 사용자를 잘못된 길로 인도할만한 기능은 피해갈 수 있다.

이 문서를 작성하는 시점에는 이미 [10개의 언어를 지원](../clientlibs)하고 있으므로, 클라이언트를 어떻게 작성하면 좋을지에 대한 이해도는 충분하다. 이 가이드라인에선 클라이언트 라이브러리를 새로 만드는 작성자가 좋은 라이브러리를 만들 수 있도록 돕는 것을 목표로 한다.

### 목차

- [Conventions](#conventions)
- [Overall structure](#overall-structure)
  + [Naming](#naming)
- [Metrics](#metrics)
  + [Counter](#counter)
  + [Gauge](#gauge)
  + [Summary](#summary)
  + [Histogram](#histogram)
  + [Labels](#labels)
  + [Metric names](#metric-names)
  + [Metric description and help](#metric-description-and-help)
- [Exposition](#exposition)
- [Standard and runtime collectors](#standard-and-runtime-collectors)
  + [Process metrics](#process-metrics)
  + [Runtime metrics](#runtime-metrics)
- [Unit tests](#unit-tests)
- [Packaging and dependencies](#packaging-and-dependencies)
- [Performance considerations](#performance-considerations)

---

## Conventions

여기서 나오는 MUST, MUST NOT, SHOULD, SHOULD NOT, MAY는 [https://www.ietf.org/rfc/rfc2119.txt](https://www.ietf.org/rfc/rfc2119.txt)에서 설명하는 것과 동일한 의미라고 보면 된다.

<span id="ENCOURAGED"></span>추가로 ENCOURAGED는 라이브러리에 있으면 좋은 기능이지만 없어도 괜찮다는 의미다. 다시 말하면 있으면 더 좋다는 뜻이다.

기억해둬야 하는 것들:

- 각 언어가 가지고 있는 기능들을 활용해라.
- 공통 유스 케이스는 쉽게 사용할 수 있어야 한다.
- 어떤 일을 진행할 때는 쉬운 방법이 적합한 방법이어야 한다.
- 좀더 복잡한 유스 케이스도 가능해야 한다.

공통적인 유스 케이스는 다음과 같다 (순서대로):

- 레이블이 없는 카운터는 여러 라이브러리/어플리케이션에 자유롭게 퍼뜨릴 수 있다.
- Summary/Histogram의 함수/코드 블록 시간 측정 기능.
- 특정 지표의 현재 상태(제한치도 함께)를 추적하는 게이지.
- 배치 job 모니터링.

---

## Overall structure

클라이언트 내부에선 반드시 콜백 기반으로 코드를 작성해야 한다<sup>[[1]MUST](https://www.ietf.org/rfc/rfc2119.txt)</sup>. 클라이언트는 대개 여기에서 설명하는 구조를 따라가는 게 좋다<sup>[[3]SHOULD](https://www.ietf.org/rfc/rfc2119.txt)</sup>.

핵심 클래스는 `Collector`다. `Collector`는 0개 이상의 메트릭을 샘플과 함께 반환하는 메소드가 있다 (일반적으로 ‘collect’라고 부른다). `Collector`들은 `CollectorRegistry`에 등록된다. 데이터를 노출할 때는 프로메테우스가 지원하는 형식으로 메트릭을 반환해주는 클래스/메소드/함수 "bridge"에 `CollectorRegistry`를 전달한다. `CollectorRegistry`를 스크랩할 때마다 `CollectorRegistry`는 각 `Collector`의 `collect` 메소드에 콜백해야 한다.

대부분의 사용자가 상호 작용하는 인터페이스는 `Counter`, `Gauge`, `Summary`, `Histogram` Collector들이다. 이 인터페이스들은 하나의 메트릭을 나타내며, 사용자가 자신의 코드를 계측<sup>instrument</sup>하는 유스 케이스 대부분을 커버한다.

좀더 복잡한 유스 케이스에선 (다른 모니터링/계측<sup>instrumentation</sup> 시스템 앞에 프록시를 두는 등) 커스텀 `Collector`를 작성해야 한다. `CollectorRegistry`를 받아 다른 모니터링/계측<sup>instrumentation</sup> 시스템이 이해하는 형식으로 데이터를 생산하는 "bridge"를 만들고 싶은 사람도 있을 거다. 이렇게 하면 사용자들은 하나의 계측<sup>instrumentation</sup> 시스템만 생각하고 코드를 작성할 수 있다.

`CollectorRegistry`는 `register()`/`unregister()` 함수를 제공해야 하며<sup>[[3]SHOULD](https://www.ietf.org/rfc/rfc2119.txt)</sup>, `Collector`는 여러 `CollectorRegistry`들에 등록할 수 있어야 한다<sup>[[3]SHOULD](https://www.ietf.org/rfc/rfc2119.txt)</sup>.

클라이언트 라이브러리는 반드시 스레드로부터 안전해야 한다<sup>[[1]MUST](https://www.ietf.org/rfc/rfc2119.txt)</sup>.

클라이언트 라이브러리는 C언어같은 비 객체지향 언어이더라도 가능한한 이 구조의 취지를 따르는 게 좋다.

### Naming

클라이언트 라이브러리는 이 문서에 언급하는 함수/메소드/클래스 이름을 따라가야 하며<sup>[[3]SHOULD](https://www.ietf.org/rfc/rfc2119.txt)</sup>, 사용하는 언어의 네이밍 컨벤션도 염두에 둬야 한다. 예를 들어 메소드명에 `set_to_current_time()`을 사용하는 건 파이썬에선 바람직하지만, Go에서는 `SetToCurrentTime()`이 더 좋으며, 자바 컨벤션에선 `setToCurrentTime()`이 맞다. 기술적인 이유로 이름을 다르게 가져간다면 (ex. 함수 오버로딩이 불가능한 경우) 문서화나 help 문자열에서도 그에 맞는 이름으로 안내해줘야 한다<sup>[[3]SHOULD](https://www.ietf.org/rfc/rfc2119.txt)</sup>.

함수/메소드/클래스에 여기에서 설명하는 이름이나 비슷한 이름을 사용하면서 시맨틱스만 다르게 제공하는 것은 안 된다<sup>[[2]MUST NOT](https://www.ietf.org/rfc/rfc2119.txt)</sup>.

---

## Metrics

[메트릭 타입](../metric-types) Counter, Gauge, Summary, Histogram은 사용자가 주로 사용하는 기본 인터페이스다.

클라이언트 라이브러리에는 반드시 Counter와 Gauge가 있어야 한다<sup>[[1]MUST](https://www.ietf.org/rfc/rfc2119.txt)</sup>. Summary나 Histogram은 반드시 최소 하나는 가지고 있어야 한다<sup>[[1]MUST](https://www.ietf.org/rfc/rfc2119.txt)</sup>.

이 인터페이스들은 주로 파일 스태틱 변수 즉, 계측<sup>instrument</sup>하는 코드와 같은 파일에 전역 변수로 정의해놓고 사용하는 게 좋다. 클라이언트 라이브러리는 이런 점도 고려해서 개발해야 한다<sup>[[3]SHOULD](https://www.ietf.org/rfc/rfc2119.txt)</sup>. 흔히 어떤 객체의 특정한 인스턴스의 컨텍스트에서 일부 코드를 계측<sup>instrument</sup>하기 보단, 전체적인 코드 조각을 계측한다. 사용자는 메트릭을 코드 전체에 걸쳐 연결한다는 것을 신경쓸 필요 없이 클라이언트 라이브러리가 알아서 담당해줘야 한다 (그렇지 않다면 사용자는 라이브러리를 래퍼로 감싸서 어떻게든 해결해보려 할 거다 - 잘 진행되는 경우는 드물지만).

디폴트 `CollectorRegistry`는 반드시 존재해야 하며<sup>[[1]MUST](https://www.ietf.org/rfc/rfc2119.txt)</sup>, 표준 메트릭은 사용자가 특별한 일을 수행하지 않아도 디폴트 레지스트리에 등록돼야 한다<sup>[[1]MUST](https://www.ietf.org/rfc/rfc2119.txt)</sup>. 배치 job이나 단위 테스트에서도 사용할 수 있도록, 메트릭을 디폴트 `CollectorRegistry`에 등록하지 않을 수 있는 방법도 있어야 한다<sup>[[1]MUST](https://www.ietf.org/rfc/rfc2119.txt)</sup>. 이 점은 커스텀 컬렉터도 지켜주는 게 좋다<sup>[[3]SHOULD](https://www.ietf.org/rfc/rfc2119.txt)</sup>.

메트릭을 생성하는 정확한 방법은 언어에 따라 다르다. 어떤 언어에선 빌더로 접근하는 게 가장 좋은 반면 (자바, Go), 다른 언어에선 (파이썬) 함수 인자들만 활용해도 한 번의 호출로 메트릭을 생성할 수 있다.

예를 들어 자바 Simpleclient에선 다음과 같이 코드를 작성할 수 있다:

```java
class YourClass {
  static final Counter requests = Counter.build()
      .name("requests_total")
      .help("Requests.").register();
}
```

이렇게 작성해주면 디폴트 `CollectorRegistry`로 요청이 등록된다. `register()` 대신 `build()`를 호출하면 메트릭이 등록되지 않으며 (단위 테스트할 때 편하다), `register()`에 `CollectorRegistry`를 넘겨주는 것도 가능하다 (배치 job에 활용할 수 있다).

### Counter

[Counter](../metric-types#counter)는 단순히 증가하는 카운터 하나를 나타낸다. 값이 감소하는 것은 허용하면 안 되지만<sup>[[2]MUST NOT](https://www.ietf.org/rfc/rfc2119.txt)</sup>, 0으로 리셋할 수는 있다<sup>[[5]MAY](https://www.ietf.org/rfc/rfc2119.txt)</sup> (서버 재시작 등에).

카운터는 반드시 다음과 같은 메소드들을 가지고 있어야 한다<sup>[[1]MUST](https://www.ietf.org/rfc/rfc2119.txt)</sup>:

- `inc()`: 카운터를 1씩 증가시킨다
- `inc(double v)`: 주어진 양만큼 카운터를 증가시킨다. v >= 0인지는 반드시 체크해야 한다<sup>[[1]MUST](https://www.ietf.org/rfc/rfc2119.txt)</sup>

카운터에는 다음과 같은 로직도 있으면 좋다<sup>[[6]ENCOURAGED](#ENCOURAGED)</sup>:

주어진 코드 조각에서 예외를 던지거나/발생한 횟수를 계산하는 방법. 옵션으로 특정 타입의 예외만 계산하는 방법. 파이썬에선 count_exceptions가 이 일을 담당한다.

카운터는 반드시 0에서 시작해야 한다<sup>[[1]MUST](https://www.ietf.org/rfc/rfc2119.txt)</sup>.

### Gauge

[Gauge](../metric-types/#gauge)는 올라가거나 내려갈 수 있는 값 하나를 나타낸다.

게이지는 반드시 다음과 같은 메소드들을 가지고 있어야 한다<sup>[[1]MUST](https://www.ietf.org/rfc/rfc2119.txt)</sup>:

- `inc()`: 게이지를 1씩 증가시킨다
- `inc(double v)`: 주어진 양만큼 게이지를 증가시킨다
- `dec()`: 게이지를 1씩 감소시킨다
- `dec(double v)`: 주어진 양만큼 게이지를 감소시킨다
- `set(double v)`: 게이지를 주어진 값으로 설정한다

게이지는 반드시 0에서 시작해야 하며<sup>[[1]MUST](https://www.ietf.org/rfc/rfc2119.txt)</sup>, 다른 숫자에서 게이지를 시작하는 방법을 제공해도 좋다<sup>[[5]MAY](https://www.ietf.org/rfc/rfc2119.txt)</sup>.

게이지는 다음과 같은 메소드도 가지고 있을 수 있다<sup>[[3]SHOULD](https://www.ietf.org/rfc/rfc2119.txt)</sup>:

- `set_to_current_time()`: 게이지를 현재 초 단위 유닉스 시간으로 설정한다.

게이지에는 다음과 같은 로직도 있으면 좋다<sup>[[6]ENCOURAGED](#ENCOURAGED)</sup>:

코드/함수 조각에서 진행 중인 요청을 추적할 수 있는 방법. 파이썬에선 `track_inprogress`가 이 일을 담당한다.

코드 조각에서 시간을 측정해서, 이 코드를 실행하는 데 소요된 시간(초)을 게이지에 설정하는 방법. 이 기능은 배치 job에 유용하다. 자바에선 `startTimer`/`setDuration`이, 파이썬에선 `time()` 데코레이터/컨텍스트 매니저가 이 일을 담당한다. 이때 사용하는 패턴은 Summary/Histogram의 패턴과 일치해야 한다<sup>[[3]SHOULD](https://www.ietf.org/rfc/rfc2119.txt)</sup> (여기선 `observe()`가 아니라 `set()`이긴 하지만).

### Summary

[summary](../metric-types#summary)는 슬라이딩 time 윈도우를 통해 관측 결과<sup>observation</sup>를 샘플링하고 (보통 요청 지속 시간같은 것들), 분포, 빈도, 합계 등을 즉시 간파할 수 있게 해준다.

summary는 사용자가 직접 레이블 이름에 "quantile"을 설정하도록 허용해선 안 된다<sup>[[2]MUST NOT](https://www.ietf.org/rfc/rfc2119.txt)</sup>. 이 이름은 내부에서 summary 분위수<sup>quantile</sup>를 지정할 때 사용한다. summary는 분위수<sup>quantile</sup>를 익스포트로 제공할 수 있다면 좋지만<sup>[[6]ENCOURAGED](#ENCOURAGED)</sup>, 집계하기 어렵고 느린 편이다. summary에선 `_count`/`_sum`만으로도 꽤나 유용하고 이 둘이 기본값이어야 하므로<sup>[[1]MUST](https://www.ietf.org/rfc/rfc2119.txt)</sup>, 분위수<sup>quantile</sup>를 포함하지 않는 것도 허용해야 한다<sup>[[1]MUST](https://www.ietf.org/rfc/rfc2119.txt)</sup>.

summary는 반드시<sup>[[1]MUST](https://www.ietf.org/rfc/rfc2119.txt)</sup> 다음과 같은 메소드를 가지고 있어야 한다:

- `observe(double v)`: 주어진 관측값을 샘플링한다

summary는 다음과 같은 메소드도 가지고 있을 수 있다<sup>[[3]SHOULD](https://www.ietf.org/rfc/rfc2119.txt)</sup>:

사용자의 코드에서 소요된 시간을 초 단위로 측정할 수 있는 방법. 파이썬에선 `time()` 데코레이터/컨텍스트 매니저가 이 일을 담당한다. 자바에선 `startTimer`/`observeDuration`이 담당한다. 초 말고 다른 단위는 제공하면 안 된다<sup>[[2]MUST NOT](https://www.ietf.org/rfc/rfc2119.txt)</sup> (다른 단위를 원한다면 사용자가 직접 측정하면 된다). 이때는 Gauge/Histogram과 동일한 패턴을 따라야 한다.

Summary `_count`/`_sum`은 반드시 0에서 시작해야 한다<sup>[[1]MUST](https://www.ietf.org/rfc/rfc2119.txt)</sup>.

### Histogram

[Histogram](../metric-types#histogram)을 사용하면 요청 지연 시간같은 이벤트들을 집계하고 데이터가 어떻게 분포되어있는지를 관찰할 수 있다. 핵심은 버킷별로 측정하는 카운터다.

히스토그램에선 사용자가 직접 레이블 이름에 `le`를 설정하도록 허용해선 안 된다<sup>[[2]MUST NOT](https://www.ietf.org/rfc/rfc2119.txt)</sup>. 이 이름은 내부에서 버킷을 지정할 때 사용한다. 

히스토그램은 반드시 수동으로 버킷을 선택할 수 있는 방법을 제공해야 한다<sup>[[1]MUST](https://www.ietf.org/rfc/rfc2119.txt)</sup>. 버킷은 `linear(start, width, count)`, `exponential(start, factor, count)` 이 두 가지 방식으로 설정할 수 있으면 좋다<sup>[[3]SHOULD](https://www.ietf.org/rfc/rfc2119.txt)</sup>. 이때 count는 `+Inf` 버킷을 제외한 갯수다<sup>[[1]MUST](https://www.ietf.org/rfc/rfc2119.txt)</sup>.

히스토그램은 다른 클라이언트 라이브러리들과 동일한 디폴트 버킷이 있어야 한다<sup>[[3]SHOULD](https://www.ietf.org/rfc/rfc2119.txt)</sup>. 메트릭을 생성하고 난 뒤에 버킷은 변경할 수 없어야 한다<sup>[[2]MUST NOT](https://www.ietf.org/rfc/rfc2119.txt)</sup>.

히스토그램은 반드시<sup>[[1]MUST](https://www.ietf.org/rfc/rfc2119.txt)</sup> 다음과 같은 메소드를 가지고 있어야 한다:

- `observe(double v)`: 주어진 관측값을 샘플링한다

히스토그램은 다음과 같은 메소드도 가지고 있을 수 있다<sup>[[3]SHOULD](https://www.ietf.org/rfc/rfc2119.txt)</sup>:

사용자의 코드에서 소요된 시간을 초 단위로 측정할 수 있는 방법. 파이썬에선 `time()` 데코레이터/컨텍스트 매니저가 이 일을 담당한다. 자바에선 `startTimer`/`observeDuration`이 담당한다. 초 말고 다른 단위는 제공하면 안 된다<sup>[[2]MUST NOT](https://www.ietf.org/rfc/rfc2119.txt)</sup> (다른 단위를 원한다면 사용자가 직접 측정하면 된다). 이때는 Gauge/Summary와 동일한 패턴을 따라야 한다.

Histogram `_count`/`_sum`과 버킷들은 반드시 0에서 시작해야 한다<sup>[[1]MUST](https://www.ietf.org/rfc/rfc2119.txt)</sup>.

**Further metrics considerations**

사용하는 언어에서 메트릭에 위에서 설명하는 것 이상의 기능을 제공하는 것은 환영이다<sup>[[6]ENCOURAGED](#ENCOURAGED)</sup>.

더 간단하게 만들 수 있는 공통 유스 케이스가 있다면, 바람직하지 않은 동작(ex. 메트릭/레이블 레이아웃 최적화를 피해가거나 클라이언트에서 계산을 수행하는 등)을 조장하지 않는 선에서 진행해도 좋다.

### Labels

레이블은 프로메테우스가 가진 [가장 강력한 측면](https://prometheus.io/docs/practices/instrumentation/#use-labels) 중 하나지만 [남용하기도 굉장히 쉽다](https://prometheus.io/docs/practices/instrumentation/#do-not-overuse-labels). 그렇기 때문에 클라이언트 라이브러리를 만들 땐 사용자에게 레이블을 어떻게 제공하고 있는지에 대해 심의를 기울여야 한다.

클라이언트 라이브러리는 같은 메트릭을 나타내는 Gauge/Counter/Summary/Histogram에 다른 레이블 이름들을 설정하도록 허용해서는 안 된다<sup>[[2]MUST NOT](https://www.ietf.org/rfc/rfc2119.txt)</sup>. 라이브러리에서 제공하는 기타 다른 `Collector`에서도 마찬가지다.

커스텀 컬렉터의 메트릭은 변함없는 레이블 이름들을 가져야 하는게 거의 대부분이다. 그렇지 않은 경우도 드물지만 존재하기 때문에 클라이언트 라이브러리에서 이를 검증해선 안 된다.

레이블은 매우 강력한 기능이지만, 레이블이 없는 메트릭이 대다수다. 따라서 API는 레이블을 허용하되, 강재해서는 안 된다.

클라이언트 라이브러리에선 반드시 Gauge/Counter/Summary/Histogram을 생성하는 시점에 옵션으로 레이블 이름 목록을 지정할 수 있어야 한다<sup>[[1]MUST](https://www.ietf.org/rfc/rfc2119.txt)</sup>. 레이블 이름은 원하는 만큼 지정할 수 있는 게 좋다<sup>[[3]SHOULD](https://www.ietf.org/rfc/rfc2119.txt)</sup>. 클라이언트 라이브러리에선 레이블 이름들이 [문서화해둔 요구 사항](../data-model/#metric-names-and-labels)을 충족하는지도 반드시 검증해야 한다<sup>[[1]MUST](https://www.ietf.org/rfc/rfc2119.txt)</sup>.

레이블로 나눈 메트릭의 차원<sup>dimension</sup>에 접근할 수 있게 해줄 때는 일반적으로, 레이블 값들의 리스트나 레이블 이름으로 레이블 값을 매핑한 맵을 받아 "Child"를 반환하는 `labels()` 메소드를 이용한다. 그러면 Child에선 평소 사용하는 `.inc()`/`.dec()`/`.observe()` 등의 메소드를 호출할 수 있다.

`labels()`로 반환한 Child는 다시 검색할 필요 없이 캐시에 저장할 수 있어야 한다<sup>[[3]SHOULD](https://www.ietf.org/rfc/rfc2119.txt)</sup>. 지연 시간에 영향을 제일 많이 받는 코드라면 특히 더 중요하다.

레이블을 가지고 있는 메트릭은 더 이상 익스포트하지 않을 Child를 제거할 수 있는 `remove()` 메소드와( `labels()`와 동일한 시그니처로), 메트릭에서 모든 Children을 제거하는 `clear()` 메소드를 지원해야 한다<sup>[[3]SHOULD](https://www.ietf.org/rfc/rfc2119.txt)</sup>. 이 메소드들은 Children의 캐시를 무효화한다.

지정한 Child를 기본 값으로 초기화할 수 있는 방법도 존재해야 한다<sup>[[3]SHOULD](https://www.ietf.org/rfc/rfc2119.txt)</sup>. 보통은 `labels()`를 호출하기만 하면 된다. 레이블이 없는 메트릭은 [메트릭이 누락되는 문제](https://prometheus.io/docs/practices/instrumentation/#avoid-missing-metrics)를 피할 수 있도록 항상 초기화돼있어야 한다<sup>[[1]MUST](https://www.ietf.org/rfc/rfc2119.txt)</sup>.

### Metric names

메트릭명은 [이 스펙](../data-model#metric-names-and-labels)을 따라야 한다. 레이블 이름과 마찬가지로 Gauge/Counter/Summary/Histogram과 라이브러리에서 제공하는 기타 다른 컬렉터 모두 충족해야 한다<sup>[[1]MUST](https://www.ietf.org/rfc/rfc2119.txt)</sup>.

이름을 세 파트로 나눠서 세팅할 수 있게 해주는 클라이언트 라이브러리가 많은데, 이땐 `namespace_subsystem_name` 중 `name`만 필수 값이다.

메트릭명을 동적으로 만들거나, 자동으로 생성해주거나, 메트릭 명에 하위 파트를 사용하는 것은 반드시 막는 게 좋다<sup>[[1]MUST](https://www.ietf.org/rfc/rfc2119.txt)</sup>. 다른 계측<sup>instrumentation</sup>/모니터링 시스템 앞에 있는 프록시로 커스텀 `Collector`를 사용할 때는 예외다. 메트릭명을 동적으로 만들거나, 자동으로 생성해야 한다는 것은 레이블이 필요하다는 신호로 볼 수 있다.

### Metric description and help

Gauge/Counter/Summary/Histogram에선 반드시 메트릭 description/help 문자열을 요구해야 한다<sup>[[1]MUST](https://www.ietf.org/rfc/rfc2119.txt)</sup>.

클라이언트 라이브러리에서 커스텀 컬렉터를 제공한다면, 해당 메트릭에 관한 description/help도 반드시 있어야 한다<sup>[[1]MUST](https://www.ietf.org/rfc/rfc2119.txt)</sup>.

description/help 문자열은 필수 인자로 만드는 것을 권장하만, 누군가는 문서 작성을 진짜로 원하지 않을 수 있기 때문에 굳이 설득하기 보단 특정 길이를 만족하는지는 체크하지 않고 넘어가는 게 좋다. 라이브러리와 함께 제공하는 컬렉터는 (사실은 에코시스템 내에서 가능한 모든 곳에) 솔선수범으로 그럴싸한 메트릭 설명을 넣어주길 바란다<sup>[[3]SHOULD](https://www.ietf.org/rfc/rfc2119.txt)</sup>.

---

## Exposition

클라이언트는 반드시 [exposition 포맷](../exposition-formats) 문서에서 설명하는 텍스트 기반 exposition 형식을 구현해야 한다<sup>[[1]MUST](https://www.ietf.org/rfc/rfc2119.txt)</sup>.

Reproducible order of the exposed metrics is ENCOURAGED (especially for human readable formats) if it can be implemented without a significant resource cost.

리소스를 크게 들이지 않고 구현할 수 있다면 (특히 사람이 읽을 수 있는 형식이라면) 노출하는 메트릭들의 순서를 계속해서 유지해도 좋다<sup>[[6]ENCOURAGED](#ENCOURAGED)</sup>.

---

## Standard and runtime collectors

클라이언트 라이브러리는 아래에서 설명하는 표준 익스포트 중 가능한 것들을 제공해야 한다<sup>[[3]SHOULD](https://www.ietf.org/rfc/rfc2119.txt)</sup>.

이런 메트릭은 커스텀 `Collector`로 구현해야 하며, 기본적으로 디폴트 `CollectorRegistry`에 등록돼야 한다<sup>[[3]SHOULD](https://www.ietf.org/rfc/rfc2119.txt)</sup>. 이 기능이 오히려 방해가 되는 틈새 케이스가 있을 수 있기 때문에 비활성화하는 방법도 존재해야 한다<sup>[[3]SHOULD](https://www.ietf.org/rfc/rfc2119.txt)</sup>.

### Process metrics

이 메트릭들은 `process_` 프리픽스를 가진다. 필요한 값을 얻는 데 문제가 있거나 사용하는 언어나 런타임 환경에서 아예 불가능한 경우엔, 클라이언트 라이브러리는 부정확한 더미 값이나 특수 값(ex. `NaN`)을 익스포트하기 보단 해당 메트릭을 생략하는 게 낫다<sup>[[3]SHOULD](https://www.ietf.org/rfc/rfc2119.txt)</sup>. 모든 메모리 값은 바이트 단위이며, 모든 시간 값들은 unixtime/seconds다.

| Metric name                        | Help string                                         | Unit             |
| :--------------------------------- | :-------------------------------------------------- | :--------------- |
| `process_cpu_seconds_total`        | 사용자, 시스템이 CPU를 사용한 총 시간 (초 단위).    | seconds          |
| `process_open_fds`                 | 열려있는 파일 디스크립터 갯수.                      | file descriptors |
| `process_max_fds`                  | 최대로 열 수 있는 파일 디스크립터 수.               | file descriptors |
| `process_virtual_memory_bytes`     | virtual 메모리 사이즈 (바이트 단위).                | bytes            |
| `process_virtual_memory_max_bytes` | 최대로 사용 가능한 virtual 메모리 양 (바이트 단위). | bytes            |
| `process_resident_memory_bytes`    | Resident 메모리 사이즈 (바이트 단위).               | bytes            |
| `process_heap_bytes`               | 프로세스 힙 사이즈 (바이트 단위).                   | bytes            |
| `process_start_time_seconds`       | 프로세스 시작 시간 (unix epoch seconds).            | seconds          |
| `process_threads`                  | 이 프로세스에 있는 OS 스레드 수.                    | threads          |

### Runtime metrics

추가로 클라이언트 라이브러리는 각자의 언어의 런타임 환경에서 의미가 있는 메트릭이라면 (ex. 가비지 컬렉션 통계), `go_`, `hotspot_` 등과 같이 적절한 프리픽스를 사용해서 어떤 것이든 제공해도 좋다<sup>[[6]ENCOURAGED](#ENCOURAGED)</sup>.

---

## Unit tests

클라이언트 라이브러리에는 핵심 계측<sup>instrumentation</sup> 라이브러리와 exposition을 커버하는 단위 테스트가 있어야 한다<sup>[[3]SHOULD](https://www.ietf.org/rfc/rfc2119.txt)</sup>.

클라이언트 라이브러리는 사용자가 작성한 계측<sup>instrumentation</sup> 코드로 쉽게 단위 테스트를 만들 수 있는 방법을 제공할 수 있으면 좋다<sup>[[6]ENCOURAGED](#ENCOURAGED)</sup>. 예를 들어 파이썬에선 `CollectorRegistry.get_sample_value`가 단위 테스트를 도와준다.

---

## Packaging and dependencies

이상적으로는 클라이언트 라이브러리는 어떤 애플리케이션에든 포함시켜서 애플리케이션을 망가트리지 않고 원하는 계측<sup>instrumentation</sup> 코드를 추가할 수 있어야 한다.

그렇기 때문에 클라이언트 라이브러리에 의존성을 추가할 때는 주의가 필요하다. 예를 들어, 특정 라이브러리 x.y 버전이 필요한 프로메테우스 클라이언트를 추가했는데, 애플리케이션이 이미 다른 곳에서 x.z를 사용하고 있다면 애플리케이션에 악영향을 미칠까?

이런 문제가 발생할 수 있다면 핵심 계측<sup>instrumentation</sup> 코드를 해당 포맷의 메트릭 bridges/exposition에서 분리하는 게 좋다. 예를 들어 자바 `simpleclient` 모듈에는 별다른 의존성이 없으며, HTTP 관련 코드는 `simpleclient_servlet`에 들어있다.

---

## Performance considerations

클라이언트 라이브러리는 반드시 thread-safe해야 하므로, 어떤 식으로든 동시성 제어가 필요하며, 멀티 코어 시스템과 애플리케이션의 성능을 고려해줘야 한다.

경험상 성능이 가장 떨어지는 건 뮤텍스였다.

프로세서 atomic operation의 성능은 중간 쯤에 있는 편이기 때문에 대게는 허용할 수 있다.

자바의 simpleclient에 있는 `DoubleAdder`같이, 동일한 RAM 비트를 다른 CPU가 변경하지 못하도록 막는 방식이 가장 잘 먹힌다. 그럼에도 메모리 비용은 있다.

위에서도 언급했듯이 `labels()`의 결과는 캐시에 저장할 수 있어야 한다. 흔히 레이블을 사용하는 메트릭을 저장할 때 쓰는 concurrent map은 상대적으로 느린 편이다. 레이블이 없는 특수한 메트릭을 따로 저장하면 `labels()`와 같은 검색을 피할 수 있어 도움이 많이 된다.

메트릭을 증가/감소/설정할 때 블로킹은 피하는 게 좋다<sup>[[3]SHOULD](https://www.ietf.org/rfc/rfc2119.txt)</sup>. 스크랩을 진행하는 동안 전체 애플리케이션이 지연되는 것은 바람직하지 않다.

레이블을 포함해서 주요 계측<sup>instrumentation</sup> 연산은 벤치마크를 해보는 것을 것은 권장한다<sup>[[6]ENCOURAGED](#ENCOURAGED)</sup>.

exposition을 수행할 때는 소비하는 리소스, 특히 RAM을 염두에 둬야 한다. 수집한 결과를 스트리밍하고 동시에 가능한 스크랩 수를 제한해서 메모리 공간을 줄일 수 있는지 고민해봐라.