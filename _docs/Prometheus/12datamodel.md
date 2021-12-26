---
title: Data model
category: Prometheus
order: 12
permalink: /Prometheus/data-model/
description: 프로메테우스의 데이터 모델 (시계열, 메트릭명, 레이블)
image: ./../../images/prometheus/logo.png
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/concepts/data_model/
parent: CONCEPTS
parentUrl: /Prometheus/concepts/
---

---

프로메테우스는 근본적으로 모든 데이터를 [*시계열*](https://en.wikipedia.org/wiki/Time_series)로 저장한다. 시계열 데이터는 동일한 메트릭과, 동일한 레이블을 가진 차원 셋에 속하는 시간 상 값들의 스트림이다. 이렇게 저장하는 시계열 데이터 외에도, 프로메테우스는 쿼리 결과로 파생 시계열을 임시로 생성할 수도 있다.

### 목차

- [Metric names and labels](#metric-names-and-labels)
- [Samples](#samples)
- [Notation](#notation)

---

## Metric names and labels

모든 시계열은 *메트릭 이름*과 *레이블*이라 부르는 생략 가능한 키-값 쌍들로 고유하게 식별할 수 있다.

*메트릭 이름*에는 시스템에서 측정할 전반적인 특성을 명시한다 (ex. `http_requests_total` - HTTP 요청을 수신한 총 횟수). 메트릭 이름에는 ASCII 문자와 숫자, 밑줄, 콜론을 사용할 수 있으며, 반드시 정규식 `[a-zA-Z_:][a-zA-Z0-9_:]*`와 매칭돼야 한다.

> 주의: 콜론은 사용자가 정의하는 recording rule 용으로 예약돼 있다. 익스포터나 직접 계측<sup>direct instrumentation</sup>에선 콜론을 사용하면 안 된다.

프로메테우스의 다차원<sup>dimensional</sup> 데이터 모델은 레이블 덕분에 가능하다. 메트릭 이름이 같을 땐 레이블의 조합으로 특정한 차원에 속하는 실제 지표를 식별한다 (예를 들어 `/api/tracks` 핸들러에 `POST`로 보낸 모든 HTTP 요청 등). 쿼리 언어는 이 차원을 기반으로 데이터를 필터링하고 집계한다. 레이블 값을 변경하면 새 시계열 데이터가 생성되며, 레이블을 추가하거나 제거할 때도 마찬가지다.

레이블 이름에는 ASCII 문자와, 숫자, 밑줄을 사용할 수 있으며, 반드시 정규식 `[a-zA-Z_][a-zA-Z0-9_]*`와 매칭돼야 한다. `__`로 시작하는 레이블은 내부 용도로 예약돼 있다.

레이블 값에는 모든 유니 코드 문자를 사용할 수 있다.

레이블 값이 비어 있으면 존재하지 않는 레이블과 동일한 것으로 간주한다.

[메트릭과 레이블 네이밍을 위한 베스트 프랙티스](https://prometheus.io/docs/practices/naming/)도 함께 참고해라.

---

## Samples

샘플들이 모여 실제 시계열 데이터를 형성한다. 각 샘플은 다음과 같이 구성된다:

- float64 값 하나
- 밀리세컨드 단위 타임스탬프 하나

---

## Notation

메트릭 이름과 레이블 셋이 있을 땐, 흔히 아래와 같은 표기법을 통해 시계열 데이터를 식별한다:

```prometheus
<metric name>{<label name>=<label value>, ...}
```

예를 들어, 메트릭 이름은 `api_http_requests_total`이고, `method="POST"`, `handler="/messages"`를 레이블로 가지고 있는 시계열은 다음과 같이 작성할 수 있다:

```prometheus
api_http_requests_total{method="POST", handler="/messages"}
```

이 표기법은 [OpenTSDB](http://opentsdb.net/)에서 사용하는 것과 같은 표기법이다.