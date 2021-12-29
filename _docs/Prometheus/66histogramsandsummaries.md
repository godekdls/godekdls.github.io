---
title: Histograms and summaries
category: Prometheus
order: 66
permalink: /Prometheus/practices.histograms/
description: Histogram과 summary의 차이점과 각각의 활용법
image: ./../../images/prometheus/logo.png
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/practices/histograms/
parent: BEST PRACTICES
parentUrl: /Prometheus/practices/
---

---

히스토그램과 summary는 다른 메트릭 타입보다 더 복잡하다. 히스토그램이나 summary 하나가 시계열을 여러 개 생성할 뿐 아니라, 이런 메트릭 타입은 올바르게 사용하는 것도 더 어렵다. 이 문서는 유스 케이스에 맞는 메트릭 타입을 선택하고 구성할 수 있도록 가이드라인을 제공한다.

### 목차

- [Library support](#library-support)
- [Count and sum of observations](#count-and-sum-of-observations)
- [Apdex score](#apdex-score)
- [Quantiles](#quantiles)
- [Errors of quantile estimation](#errors-of-quantile-estimation)
- [What can I do if my client library does not support the metric type I need?](#what-can-i-do-if-my-client-library-does-not-support-the-metric-type-i-need)

---

## Library support

가장 먼저 라이브러리가 [히스토그램](../metric-types#histogram)과 [summary](../metric-types#summary)를 어떻게 지원하고 있는지를 확인해봐라.

라이브러리에 따라 두 타입 중 한 가지 타입만 지원할 수도 있고, summary를 제한적으로만 지원하기도 한다 ([quantile 계산](#quantiles) 미지원).

---

## Count and sum of observations

히스토그램과 summary는 모두 관측 결과<sup>observation</sup>를 샘플링한다. 전형적으로 요청 지속 기간이나 응답 크기 같은 것들을 추적한다. 이 타입들은 관측한 횟수와 관측한 값들의 합계를 *함께* 추적하기 때문에, 관측한 값들의 *평균*을 계산할 수 있다. 관측 횟수는 (프로메테우스에서 `_count` suffix가 붙어있는 시계열들) 본질적으로 카운터다 (앞에서 설명했던 것처럼 증가만 가능하다). 관측치의 합계도 (`_sum` suffix가 붙어있는 시계열들) 음수만 없다면 카운터처럼 동작한다. 요청 기간이나 응답 크기는 명백하게 음수가 될 수 없다. 하지만 원칙적으로는 음수 값들을 관측할 때도 summary와 히스토그램을 사용할 수 있다 (ex. 섭씨 온도). 이때는 관측값들의 합계가 줄어들 수 있기 때문에 `rate()`는 더 이상 적용할 수 없다. 드물게 `rate()`를 적용해야 하면서 동시에 음수 값을 피할 수 없는 케이스에선, 데이터가 양수인지 음수인지에 따라 summary를 두 개로 따로 사용하고 (음수 전용 summary에선 부호를 반전시켜서), 이후 필요할 때 적당한 PromQL 표현식으로 결합해주면 된다.

`http_request_duration_seconds`라는 히스토그램이나 summary에서 지난 5분 간의 요청 지속 시간의 평균을 계산하려면 다음 표현식을 사용해라:

```prometheus
  rate(http_request_duration_seconds_sum[5m])
/
  rate(http_request_duration_seconds_count[5m])
```

---

## Apdex score

히스토그램을 (summary는 해당하지 않는다) 간단히 활용하면 특정 버킷에 속하는 관측값들의 갯수를 계산할 수 있다.

예를 들어, SLO가 요청의 95%를 300ms 이내에 처리하는 것일 수도 있다. 이럴 때는 히스토그램에 상한이 0.3초인 버킷을 구성해라. 이렇게 하면 300ms 이내로 서빙한 요청의 상대적인 비율을 표현식으로 바로 만들 수 있으며, 이 수치가 0.95 미만으로 떨어지면 쉽게 알림<sup>alert</sup>을 생성할 수 있다. 아래 있는 표현식은 job마다 지난 5분 간 서빙한 요청을 대상으로 비율을 계산하는 표현식이다. 요청 지속 시간은 `http_request_duration_seconds`라는 히스토그램으로 수집했다.

```prometheus
  sum(rate(http_request_duration_seconds_bucket{le="0.3"}[5m])) by (job)
/
  sum(rate(http_request_duration_seconds_count[5m])) by (job)
```

잘 알려진 [Apdex 점수](https://en.wikipedia.org/wiki/Apdex)도 비슷한 방법으로 근사치를 계산할 수 있다. 목표<sup>satisfied</sup> 요청 지속 시간을 상한으로 갖는 버킷과, 허용할 수 있는<sup>tolerating</sup> 요청 지속 시간을 상한으로 갖는 (보통은 목표 요청 지속 시간의 4배) 버킷을 각각 구성해라. 예를 들어 목표 요청 지속 시간은 300ms라고 해보자. 허용 가능한 요청 지속 시간은 1.2초다. 아래 표현식에선 job마다 지난 5분 간의 Apdex 점수를 산출한다:

```prometheus
(
  sum(rate(http_request_duration_seconds_bucket{le="0.3"}[5m])) by (job)
+
  sum(rate(http_request_duration_seconds_bucket{le="1.2"}[5m])) by (job)
) / 2 / sum(rate(http_request_duration_seconds_count[5m])) by (job)
```

여기서는 두 버킷의 합계를 다시 나누는 것에 주목해라. 이렇게 하는 이유는 히스토그램 버킷들은 [누적되는](https://en.wikipedia.org/wiki/Histogram#Cumulative_histogram) 값이기 때문이다. `le="1.2"` 버킷에는 `le="0.3"` 버킷도 포함돼 있다. 이 문제를 보정하기 위해 2로 나눈다.

어쨌거나 목표치와 허용치를 계산할 땐 오차가 있기 있기 때문에 이 계산식은 전통적인 Apdex 점수와 정확히 일치하진 않는다.

---

## Quantiles

소위말하는 φ-quantile(0 ≤ φ ≤ 1)은 summary와 히스토그램 모두 계산할 수 있다. φ-quantile은 N개의 관측치 중 φ*N번째 순위에 해당하는 관측값을 뜻한다. φ-quantile의 예시로 0.5-quantile은 중앙값<sup>median</sup>으로 알려져 있다. 95-quantile은 95번째 백분위수를 뜻한다.

summary와 히스토그램의 근본적인 차이점은, summary는 φ-quantile을 클라이언트 측에서 스트리밍으로 계산하고 바로 노출하는 반면, 히스토그램은 관찰 횟수를 버킷에 담아 노출한다. 히스토그램 버킷에서 백분위수를 계산할 때는 [`histogram_quantile()` 함수](../querying.functions#histogram_quantile)를 이용해 서버 측에서 계산한다.

두 가지 접근 방식은 여러 가지 의미로 다르다:

|                                               | Histogram                                                    | Summary                                                      |
| :-------------------------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| 필요한 설정                                   | 관측하는 값들의 예상 범위에 맞는 버킷을 선택한다.            | 원하는 φ-quantile과 슬라이딩 윈도우를 선택한다. 선택 후에는 다른 φ-quantile과 슬라이딩 윈도우를 계산할 수 없다. |
| 클라이언트 성능                               | 관측 결과들의 카운터만 늘려주면 되기 때문에 비용이 매우 적다. | 백분위수를 스트리밍으로 계산하기 때문에 관측 비용이 큰 편이다. |
| 서버 성능                                     | 분위수는 서버에서 계산해야 한다. 애드혹 계산이 (대형 대시보드 등에서) 너무 오래 걸린다면 [recording rule](../recording-rules/#recording-rules)을 사용하면 된다. | 서버 측 비용은 크지 않다.                                    |
| 시계열 갯수 (`_sum`, `_count` 시계열 외에)    | 설정한 버킷 당 시계열 하나.                                  | 설정한 quantile 당 시계열 하나.                              |
| 백분위수 오차 (자세한 내용은 아래를 참고해라) | 오차는 버킷의 너비에 따라 관측하는 값들의 범위 내로 제한된다. | 오차는 설정한 값에 따라 φ의 범위 내로 제한된다.              |
| φ-quantile과 슬라이딩 time 윈도우 사양        | [프로메테우스 표현식](../querying.functions#histogram_quantile)을 이용해 애드혹으로 결정. | 클라이언트에서 미리 설정한다.                                |
| 집계                                          | [프로메테우스 표현식](../querying.functions#histogram_quantile)을 이용해 애드혹으로 집계. | 일반적으로 [집계가 불가능하다](https://latencytipoftheday.blogspot.de/2014/06/latencytipoftheday-you-cant-average.html). |

테이블에 있는 마지막 항목은 굉장히 중요하다. 요청의 95%를 300ms 이내에 처리하는 SLO로 돌아가 보자. 이번에는 300ms 이내로 처리한 요청의 비율말고, 그대신 95번째 백분위수, 즉 요청의 95%가 몇 초 이내로 처리되었는지를 표현하고 싶다. 이럴 때는 0.95-quantile과 (예를 들어) 5분짜리 윈도우로 summary를 구성해도 되고, 300ms 근처에 있는 버킷 몇 개로 히스토그램을 구성해도 된다 (ex. `{le="0.1"}`, `{le="0.2"}`, `{le="0.3"}`, `{le="0.45"}`). 그런데 만약에 서비스를 여러 인스턴스로 복제해서 사용하고 있었다면, 각 인스턴스마다 요청 지속 시간을 수집한 다음 전부 하나로 집계해서 95번째 백분위수를 계산해야 한다. 하지만 summary에서 미리 계산돼있는 백분위수를 집계하는 건 의미가 거의 없다. 이 특이 케이스에서 백분위수로 평균을 계산하면 통계적으로 무의미한 값이 나오게 된다.

```prometheus
avg(http_request_duration_seconds{quantile="0.95"}) // BAD!
```

히스토그램을 사용하면 [`histogram_quantile()` 함수](../querying.functions#histogram_quantile)로 완벽하게 집계해낼 수 있다.

```prometheus
histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le)) // GOOD.
```

게다가 SLO가 변경돼서 이제 90번째 백분위수를 구해야 한다거나, 지난 5분이 아닌 마지막 10분 간의 데이터를 계산해야 한다고 하더라도, 위에 있는 표현식만 조정하면 해결되며 클라이언트를 다시 설정할 필요가 없다.

---

## Errors of quantile estimation

분위수는 클라이언트에서 계산했든, 서버에서 계산했든 상관없이 추정치다. 값을 추정할 때 생기는 오차를 이해하는 게 중요하다.

위에서 다뤘던 히스토그램 예제를 계속 이어가보자. 평소 요청 지속 시간이 대부분 220ms에 매우 근접하다고 상상해보자. 즉, "진짜" 히스토그램을 그린다면 220ms에서 매우 급격하게 늘어나는 것을 보게 될 거다. 위에서 설명한 방법대로 프로메테우스 히스토그램 메트릭을 구성하면, 95번째 백분위수를 포함한 대부분의 관측 결과가 `{le="0.3"}` 레이블을 가진 버킷, 즉 200ms에서 300ms 사이에 있는 버킷에 속하게 될 거다. 히스토그램 구현체는 실제 95번째 백분위수가 200ms에서 300ms 사이에 있는 값임을 보장한다. 히스토그램에선 (간격이 아닌) 단일 값을 반환하기 위해 [선형 보간법<sup>linear interpolation</sup>](https://ko.wikipedia.org/wiki/%EC%84%A0%ED%98%95_%EB%B3%B4%EA%B0%84%EB%B2%95)을 적용하며, 이 경우 295ms를 산출한다. 이렇게 계산한 백분위수는 SLO 위반에 가깝다는 인상을 주지만, 실제 95번째 백분위수는 220ms보다 약간 더 클 뿐이며, SLO까지 거리를 안정적으로 유지하고 있다.

이어서 생각해볼 시나리오: 백엔드 라우팅을 변경했더니 모든 요청 지속 시간이 고정적으로 100ms만큼 늘어났다. 이제 요청 지속 시간은  320ms에서 급격히 증가하고 대부분의 관측 결과가 300ms에서 450ms 사이에 있는 버킷에 들어간다. 95번째 백분위수는 442.5ms로 계산되지만 정확한 값은 320ms에 가깝다. SLO를 약간 벗어나긴 했지만, 계산해서 만든 95번째 백분위수는 훨씬 더 나쁜 것처럼 보인다.

summary는 두 경우 모두 아무 문제 없이 정확한 백분위수 값을 계산할 수 있다. 최소한 클라이언트 측에서 적절한 알고리즘만 사용해주면 말이다 ([Go 클라이언트에서 사용하는 알고리즘](http://dimacs.rutgers.edu/~graham/pubs/slides/bquant-long.pdf) 등). 하지만 안타깝게도 여러 인스턴스에서 관측한 값들을 집계해야 할 때는 summary를 사용할 수 없다.

선택한 버킷 경계가 운 좋게 잘 맞아 떨어졌기 때문에, 관찰 측값들의 분포가 매우 급격하게 늘어나는 이 인위적인 예시에서도, 히스토그램으로 현재 SLO 범위 안에 있는지 벗어났는지를 정확하게 식별할 수 있었다. 게다가 실제 백분위수 값이 SLO(다른 말로 하면 우리가 실제로 가장 관심 있는 값)에 가까울수록 계산하는 값도 더 정확해진다.

이번에도 시나리오를 한 번 더 수정해보겠다. 이번 세팅에선 요청 지속 시간의 분포는 여전히 150ms에서 확 늘어나지만, 이전만큼 급증하진 않고 관측 값의 90%만 여기에 분포돼있다. 관측치의 10%는 150ms에서 450ms 사이에서 고르게 퍼져 [롱테일](https://ko.wikipedia.org/wiki/%EA%B8%B4_%EA%BC%AC%EB%A6%AC)을 구성하고 있다. 이 분포에선 95번째 백분위수가 정확히 SLO 지표인 300ms에 위치한다. 우연히 95번째 백분위수 값이 버킷 경계 중 하나와 정확하게 일치했기 때문에, 히스토그램을 사용해 계산하는 값도 정확하게 계산된다. 선형 보간을 적용할 때 정확히 가정하는 것은 버킷들 안에서 데이터들이 (인위적으로) 균등하게 분포돼 있다는 것이기 때문에, 값들이 약간씩 다르게 분포돼있더라도 정확하게 계산될 거다.

이 시나리오에선 summary가 보고하는 백분위수의 오차가 더 흥미롭다. summary에서 백분위수의 오차는 φ 범위 내에서 결정된다. 여기서는 0.95±0.01로 설정했다고 해보자 (즉, 94번째와 96번째 백분위수 사이에 있는 값으로 계산된다). 위에서 다룬 데이터 분포에서 94번째 백분위수는 270ms이고 96번째 백분위수는 330ms였다고 가정한다. summary가 계산해서 보고하는 95번째 백분위수 값은 270ms와 330ms 사이에 있는 값 중 어떤 값도 될 수 있다. 하지만 안타깝게도 이 만큼의 오차로는 명확하게 SLO 범위 안에 들어갔는지 SLO를 벗어났는지를 구분할 수 없다.

요점은 summary를 사용하면 φ 범위로 오차를 제어할 수 있다는 거다. 히스토그램을 사용하면 관측하는 값의 범위로 오차를 제어할 수 있다 (버킷 레이아웃을 적절히 선택해줌으로써). 넓게 퍼져있는 분포에선 φ가 조금만 변해도 관측 값들의 편차가 커지게 된다. 한 쪽에 몰려있는 분포에선 관측 값들이 가까이에 붙어있기 때문에 φ가 달라져도 어느정도는 커버가 가능하다.

경험을 바탕으로 한 두 가지 규칙:

1. 집계가 필요하다면 히스토그램을 선택해라.
2. 그외엔, 관측할 값들의 범위와 분포를 어느 정도 알고 있다면 히스토그램을 선택한다. 범위나 분포에 관계 없이 정확한 백분위수가 필요하다면 summary를 선택해라.

---

## What can I do if my client library does not support the metric type I need?

직접 구현하면 된다! [코드 기여는 언제나 환영이다](https://prometheus.io/community/). 일반적으로는 summary보단 히스토그램이 더 시급할 것으로 본다. 히스토그램은 클라이언트 라이브러리에서 구현하기도 더 쉽기 때문에, 확신이 없다면 히스토그램을 먼저 구현해보는 것을 추천한다.