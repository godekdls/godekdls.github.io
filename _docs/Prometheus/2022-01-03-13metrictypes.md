---
title: Metric types
category: Prometheus
order: 13
permalink: /Prometheus/metric-types/
description: 프로메테우스의 메트릭 타입 (Counter, Gauge, Histogram, Summary)
image: ./../../images/prometheus/logo.png
lastmod: 2022-01-05T21:30:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/concepts/metric_types/
parent: CONCEPTS
parentUrl: /Prometheus/concepts/
---

---

프로메테우스 클라이언트 라이브러리는 네 가지 핵심 메트릭 타입을 제공한다. 이 타입들은 현재 클라이언트 라이브러리와 (사용하는 타입에 맞는 API를 제공하는 용도), 와이어 프로토콜에서만 구분하고 있다. 프로메테우스 서버는 아직까진 타입 정보를 사용하지 않으며, 모든 데이터를 타입이 없는 시계열로 펼처버린다<sup>flatten</sup>. 향후엔 변경될 수도 있다.

### 목차

- [Counter](#counter)
- [Gauge](#gauge)
- [Histogram](#histogram)
- [Summary](#summary)

---

## Counter

*카운터<sup>counter</sup>*는 누적되는 메트릭으로, 값이 커지거나 재시작 시 0으로 리셋하는 것만 가능한, [단순히 증가하는 카운터](https://en.wikipedia.org/wiki/Monotonic_function) 하나를 나타낸다. 예를 들어 카운터를 사용해 서빙한 요청 수나, 완료된 태스크 수, 에러 횟수 등을 표현할 수 있다.

감소할 수도 있는 값을 표현할 땐 카운터를 사용하면 안 된다. 예를 들면, 현재 실행 중인 프로세스 수엔 카운터가 아니라 게이지<sup>gauge</sup>를 사용해야 한다.

카운터 관련 클라이언트 라이브러리 사용 가이드:

- [Go](https://godoc.org/github.com/prometheus/client_golang/prometheus#Counter)
- [Java](https://github.com/prometheus/client_java#counter)
- [Python](https://github.com/prometheus/client_python#counter)
- [Ruby](https://github.com/prometheus/client_ruby#counter)

---

## Gauge

*게이지<sup>gauge</sup>*는 임의대로 올라가거나 내려갈 수 있는 단일 숫자 값을 나타내는 메트릭이다.

전형적으로 게이지는 온도나 현재 메모리 사용량같은 지표를 측정할 때 사용하지만, 동시 요청 수와 같이 증가할 수도 감소할 수도 있는 "횟수"에도 사용한다.

게이지 관련 클라이언트 라이브러리 사용 가이드:

- [Go](https://godoc.org/github.com/prometheus/client_golang/prometheus#Gauge)
- [Java](https://github.com/prometheus/client_java#gauge)
- [Python](https://github.com/prometheus/client_python#gauge)
- [Ruby](https://github.com/prometheus/client_ruby#gauge)

---

## Histogram

*히스토그램<sup>histogram</sup>*은 관측 결과<sup>observation</sup>를 (보통 요청 지속 시간이나 응답 크기같은 것들) 샘플링해서 설정한 버킷들에 카운팅한다. 관찰한 모든 값들의 합계도 함께 제공한다.

히스토그램을 스크랩하면 여러 가지 시계열을 노출하게 된다. `<basename>`을 메트릭 이름으로 가진 히스토그램은 다음과 같은 데이터를 노출한다:

- `<basename>_bucket{le="<upper inclusive bound>"}`로 노출하는, 관측 버킷들에 대한 누적 카운터
- `<basename>_sum`으로 노출하는, 모든 관측 값들의 **총합**
- `<basename>_count`로 노출하는, 관찰한 이벤트들의 **갯수** (위에 있는 `<basename>_bucket{le="+Inf"}`와 동일)

[`histogram_quantile()` 함수](../querying.functions#histogram_quantile)를 사용하면 히스토그램이나 히스토그램 집계에서도 분위수<sup>quantile</sup>를 계산할 수 있다. 히스토그램은 [Apdex 점수](https://en.wikipedia.org/wiki/Apdex)를 계산할 때도 적합하다. 버킷을 통해 작업한다면 히스토그램은 [누적](https://en.wikipedia.org/wiki/Histogram#Cumulative_histogram)된다는 것을 기억해둬라. 상세 히스토그램 사용법과 [summary](#summary)와의 차이점은 [histograms and summaries](../practices.histograms)를 참고해라.

히스토그램 관련 클라이언트 라이브러리 사용 가이드:

- [Go](https://godoc.org/github.com/prometheus/client_golang/prometheus#Histogram)
- [Java](https://github.com/prometheus/client_java#histogram)
- [Python](https://github.com/prometheus/client_python#histogram)
- [Ruby](https://github.com/prometheus/client_ruby#histogram)

---

## Summary

*히스토그램*과 유사하게 *summary*도 관측 결과<sup>observation</sup>를 샘플링한다 (보통 요청 지속 시간이나 응답 크기같은 것들). 마찬가지로 총 관측 횟수와 관찰한 모든 값들의 합계를 제공하지만, summary는 슬라이딩 time 윈도우를 통해 설정해둔 분위수를 계산한다.

summary를 스크랩하면 여러 가지 시계열을 노출하게 된다. `<basename>`을 메트릭 이름으로 가진 summary는 다음과 같은 데이터를 노출한다:

- `<basename>{quantile="<φ>"}`로 노출하는, 관찰한 이벤트들의 스트리밍 **φ-quantiles** (0 ≤ φ ≤ 1)
- `<basename>_sum`으로 노출하는, 모든 관측 값들의 **총합**
- `<basename>_count`로 노출하는, 관찰한 이벤트의 **갯수**

φ-quantiles와 summary 사용법, [히스토그램](#histogram)과의 차이점은 [histograms and summaries](../practices.histograms)에서 자세히 다루고 있다.

summary 관련 클라이언트 라이브러리 사용 가이드:

- [Go](https://godoc.org/github.com/prometheus/client_golang/prometheus#Summary)
- [Java](https://github.com/prometheus/client_java#summary)
- [Python](https://github.com/prometheus/client_python#summary)
- [Ruby](https://github.com/prometheus/client_ruby#summary)