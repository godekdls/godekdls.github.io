---
title: Recording rules
category: Prometheus
order: 68
permalink: /Prometheus/practices.rules/
description: Recording rule의 네이밍 컨벤션과 집계 시 유의점
image: ./../../images/prometheus/logo.png
lastmod: 2022-01-05T21:30:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/practices/rules/
parent: BEST PRACTICES
parentUrl: /Prometheus/practices/
---

---

[recording rule](../recording-rules)에 일관적인 네이밍 체계를 사용하면 rule이 의미하는 바를 한 눈에 쉽게 파악할 수 있다. 뿐만 아니라 정확하지 않은 계산이나 무의미한 계산식도 눈에 들어오게 되서 실수를 방지할 수 있다.

이 페이지는 데이터를 올바르게 집계하는 방법을 정리한 문서이며, 한 가지 네이밍 컨벤션을 제안한다.

### 목차

- [Naming and aggregation](#naming-and-aggregation)
- [Examples](#examples)

---

## Naming and aggregation

Recording rule은 일반적인 포맷 `level:metric:operations`를 따라야 한다. `level`은 집계 수준, 즉 rule에서 출력하는 레이블들을 나타낸다. `metric`은 메트릭 이름으로, 카운터에서 `rate()`나 `irate()`을 사용할 때 `_total`을 잘라내는 것 외에는 변경하지 않는다. `operations`는 이 메트릭에 적용한 연산 목록이며, 나중에 적용하는 연산을 앞에 표기한다.

메트릭 이름을 변경하지 않고 그대로 유지하면, 이 메트릭이 무엇인지도 파악하기 쉽고 코드에서도 쉽게 찾을 수 있다.

표현식에 `sum()`과 같은 연산을 사용할 때는 `operations`에선 `_sum`을 생략해서 깔끔하게 유지한다. 연계되는 연산들은 하나로 합칠 수 있다 (ex. `min_min`은 `min`과 동일하다).

어떤 연산을 사용할지 잘 모르겠다면 `sum`을 사용해라. 무언가를 나눠서 비율을 계산하는 경우 메트릭 이름 사이엔 `_per_`를 넣고, `operations`에는 `ratio`를 넣어라.

비율을 집계할 때는 분자와 분모를 따로따로 합산한 다음에 나눠야 한다. 미리 계산한 비율이나 평균을 가지고 평균을 다시 계산해선 안 된다. 이는 통계적으로 유효하지 않다.

Summary에서 관측한 크기의 평균값을 계산하기 위해 `_count`와 `_sum`을 집계하고 나눠줄 땐 비율로 취급하긴 힘들 거다. 그보단 메트릭 이름에선 `_count`나 `_sum` suffix를 제외하고 operation의 `rate`를 `mean`으로 바꿔라. 이렇게하면 해당 기간 동안에 관측한 평균 크기를 나타낼 수 있다.

전부 하나로 집계해버리는 레이블들에는 전부 `without` 절을 지정해라. 이렇게 하면 `job`과 같은 다른 레이블들은 모두 보존할 수 있기 때문에, 충돌은 최소화하고 더 유용한 메트릭과 alert를 제공할 수 있다.

---

## Examples

*들여쓰기 스타일 중 두 벡터 사이에서 자체적으로 줄을 바꾸고 연산자를 내어쓰기한 스타일에 유의해라. Yaml에선 이 스타일을 가능하게 하기 위해 [들여쓰기 지시자<sup>indentation indicator</sup>를 이용한 블록 인용구](https://yaml.org/spec/1.2/spec.html#style/block/scalar)를 사용한다 (ex. `|2`).*

`path` 레이블을 가지고 있는 요청들을 초단위로 집계한다.

```yaml
- record: instance_path:requests:rate5m
  expr: rate(requests_total{job="myjob"}[5m])

- record: path:requests:rate5m
  expr: sum without (instance)(instance_path:requests:rate5m{job="myjob"})
```

요청에 실패한 비율을 계산하고, job 레벨까지 실패 비율을 집계한다:

```yaml
- record: instance_path:request_failures:rate5m
  expr: rate(request_failures_total{job="myjob"}[5m])

- record: instance_path:request_failures_per_requests:ratio_rate5m
  expr: |2
      instance_path:request_failures:rate5m{job="myjob"}
    /
      instance_path:requests:rate5m{job="myjob"}

# 분자와 분모를 각각 합산한 다음 나눠서 path 레벨의 비율을 계산한다.
- record: path:request_failures_per_requests:ratio_rate5m
  expr: |2
      sum without (instance)(instance_path:request_failures:rate5m{job="myjob"})
    /
      sum without (instance)(instance_path:requests:rate5m{job="myjob"})

# 계측 레이블이나 인스턴스를 구별하는 레이블들은 남아있지 않으므로
# level에는 'job'을 사용한다.
- record: job:request_failures_per_requests:ratio_rate5m
  expr: |2
      sum without (instance, path)(instance_path:request_failures:rate5m{job="myjob"})
    /
      sum without (instance, path)(instance_path:requests:rate5m{job="myjob"})
```

Summary에서 일정 기간 동안 관측한 지연 시간의 평균을 계산한다:

```yaml
- record: instance_path:request_latency_seconds_count:rate5m
  expr: rate(request_latency_seconds_count{job="myjob"}[5m])

- record: instance_path:request_latency_seconds_sum:rate5m
  expr: rate(request_latency_seconds_sum{job="myjob"}[5m])

- record: instance_path:request_latency_seconds:mean5m
  expr: |2
      instance_path:request_latency_seconds_sum:rate5m{job="myjob"}
    /
      instance_path:request_latency_seconds_count:rate5m{job="myjob"}

# 분자와 분모를 각각 합산한 다음 나눈다.
- record: path:request_latency_seconds:mean5m
  expr: |2
      sum without (instance)(instance_path:request_latency_seconds_sum:rate5m{job="myjob"})
    /
      sum without (instance)(instance_path:request_latency_seconds_count:rate5m{job="myjob"})
```

전체 인스턴스와 path의 평균 쿼리 비율은 `avg()` 함수를 이용해 계산한다:

```yaml
- record: job:request_latency_seconds_count:avg_rate5m
  expr: avg without (instance, path)(instance:request_latency_seconds_count:rate5m{job="myjob"})
```

입력 메트릭명과 출력 메트릭명을 비교해보면, 집계할 땐 `without` 절에 있는 레이블들은 출력 메트릭의 `level`에선 제거된다는 점을 알 수 있다. 따로 집계하지 않을 땐 입출력 메트릭의 `level`은 항상 동일하다. 그렇지 않은 경우 rule을 만들 때 실수했을 가능성이 크다.

