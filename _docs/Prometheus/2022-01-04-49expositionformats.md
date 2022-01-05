---
title: Exposition formats
category: Prometheus
order: 49
permalink: /Prometheus/exposition-formats/
description: 프로메테우스에 메트릭을 노출할 때 사용하는 exposition 포맷
image: ./../../images/prometheus/logo.png
lastmod: 2022-01-05T21:30:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/instrumenting/exposition_formats/
parent: INSTRUMENTING
parentUrl: /Prometheus/instrumenting/
---

---

메트릭을 프로메테우스에 노출할 땐 간단한 [텍스트 기반](#text-based-format) exposition 포맷을 사용하면 된다. 이 포맷을 구현하는 다양한 [클라이언트 라이브러리](../clientlibs)가 준비돼 있다. 원하는 언어에는 클라이언트 라이브러리가 없다면 [직접 라이브러리를 생성](../writing-clientlibs)해도 된다.

> **참고:** 프로메테우스의 일부 구버전에선 현재 사용하는 텍스트 기반 포맷 외에 [프로토콜 버퍼](https://developers.google.com/protocol-buffers/)(일명 Protobuf)를 기반으로 하는 exposition 포맷을 지원했었다. 하지만 프로메테우스 2.0 버전부터는 더 이상 Protobuf 기반 포맷을 지원하지 않는다. 이렇게 변경된 내막은 [이 문서](https://github.com/OpenObservability/OpenMetrics/blob/master/legacy/markdown/protobuf_vs_text.md)에서 확인할 수 있다.

### 목차

- [Text-based format](#text-based-format)
  + [Basic info](#basic-info)
  + [Text format details](#text-format-details)
    * [Line format](#line-format)
    * [Comments, help text, and type information](#comments-help-text-and-type-information)
    * [Grouping and sorting](#grouping-and-sorting)
    * [Histograms and summaries](#histograms-and-summaries)
  + [Text format example](#text-format-example)
- [OpenMetrics Text Format](#openmetrics-text-format)
  + [Exemplars (Experimental)](#exemplars-experimental)
- [Historical versions](#historical-versions)

---

## Text-based format

프로메테우스 2.0 버전부터, 프로메테우스에 메트릭을 노출하는 모든 프로세스는 텍스트 기반 포맷을 사용해야 한다. 이 섹션에선 텍스트 기반 포맷에 대한 몇 가지 [기초 정보](#basic-info)를 정리하고, [자세히 분석](#text-format-details)해 본다.

### Basic info

| Aspect                             | Description                                                  |
| :--------------------------------- | :----------------------------------------------------------- |
| **시작**                           | 2014년 4월                                                   |
| **지원 버전**                      | 프로메테우스 버전 `>=0.4.0`                                  |
| **전송**                           | HTTP                                                         |
| **인코딩**                         | UTF-8, `\n` 라인 인코딩                                      |
| **HTTP `Content-Type`**            | `text/plain; version=0.0.4` (`version` 값이 없으면 가장 최근 텍스트 포맷 버전으로 폴백한다.) |
| **HTTP `Content-Encoding` (옵션)** | `gzip`                                                       |
| **이점**                           | {::nomarkdown}<ul style="line-height: 120%;"><li>사람이 읽을 수 있다</li><li>조합하기 쉬우며, 구문을 최소한으로 유지하면 더 간단하다 (중첩할 필요가 없다)</li><li>라인 단위로 읽을 수 있다 (타입 힌트와 docstring은 예외)</li></ul>{:/} |
| **제약**                           | {::nomarkdown}<ul style="line-height: 120%;"><li>장황해 보일 수 있다</li><li>타입과 docstring은 구문의 필수 요소가 아니기 때문에, 메트릭 인터페이스의 유효성 검사는 거의 없다고 볼 수 있다</li><li>파싱 비용</li></ul>{:/} |
| **지원하는 기본 메트릭 타입**      | {::nomarkdown}<ul style="line-height: 120%;"><li>Counter</li><li>Gauge</li><li>Histogram</li><li>Summary</li><li>Untyped</li></ul>{:/} |

### Text format details

프로메테우스의 텍스트 기반 포맷은 라인 중심 포맷이다. 각 라인은 줄바꿈 문자(`\n`)로 구분한다. 마지막 라인은 줄바꿈 문자로 끝나야 한다. 비어있는 라인은 무시한다.

#### Line format

같은 라인에 있는 토큰들은 원하는 만큼의 공백이나 탭으로 구분할 수 있다 (공백이 하나도 없으면 이전 토큰과 병합돼버린다). 맨 앞에 있는 공백과 맨 뒤에 있는 공백은 무시한다.

#### Comments, help text, and type information

공백을 제외한 첫 번째 문자가 `#`인 라인은 주석이다. `#` 뒤에 나오는 첫 번째 토큰이 `HELP`나 `TYPE`이 아니라면 무시한다. 이 두 토큰이 있는 라인은 다음과 같이 처리된다: 첫 번째 토큰이 `HELP`일 때는 메트릭명을 나타내는 토큰이 하나 더 필요하다. 그외 남아있는 모든 토큰은 해당 메트릭명을 위한 docstring으로 간주한다. `HELP` 라인에는 UTF-8 문자라면 어떤 문자열이든 올 수 있지만 (메트릭명 뒤에), 백슬래시와 줄 바꿈 문자는 각각 `\\`, `\n`으로 이스케이프해야 한다. `HELP` 라인은 메트릭명마다 하나만 존재할 수 있다.

첫 번째 토큰이 `TYPE`일 때는 정확히 두 개의 토큰이 더 필요하다. 첫 번째는 메트릭명이고, 두 번째는 `counter`, `gauge`, `histogram`, `summary`, `untyped` 중 하나로, 해당 메트릭의 타입을 정의한다. `TYPE` 라인은 메트릭명마다 하나만 존재할 수 있다. `TYPE` 라인은 해당 메트릭명을 가진 샘플을 보고하기 전에 먼저 나타나야 한다. `TYPE` 라인이 없으면 해당 메트릭명의 타입은 `untyped`로 설정된다.

남아있는 라인에선 아래있는 구문([EBNF](https://en.wikipedia.org/wiki/Extended_Backus–Naur_form))을 이용해 샘플을 묘사한다 (한 줄에 하나씩):

```go
metric_name [
  "{" label_name "=" `"` label_value `"` { "," label_name "=" `"` label_value `"` } [ "," ] "}"
] value [ timestamp ]
```

샘플 구문은 다음과 같다:

- `metric_name`과 `label_name`은 일반적인 프로메테우스 표현식 언어 제한이 그대로 따른다.
- `label_value`에는 어떤 UTF-8 문자든지 사용할 수 있지만, 백슬래시(`\`), 큰따옴표(`"`), 줄 바꿈(`\n`) 문자는 각각 `\\`, `\"`, `\n`로 이스케이프해야 한다.
- `value`로는 Go의 [`ParseFloat()`](https://golang.org/pkg/strconv/#ParseFloat) 함수에서 요구하는 대로 부동 소수점을 표현한다. 표준 숫자값 외에도 `NaN`, `+Inf`, `-Inf`를 사용할 수 있으며, 각각은 숫자가 아닌 값, 양의 무한대, 음의 무한대를 나타낸다.
- `timestamp`에는 Go의 [`ParseInt()`](https://golang.org/pkg/strconv/#ParseInt) 함수에서 요구하는 대로 `int64`를 표현한다 (epoch 이후 즉, 1970-01-01 00:00:00 UTC 이후 윤초를 제외하고 경과한 밀리초).

#### Grouping and sorting

특정 메트릭을 위한 모든 라인은 반드시 하나의 그룹으로 제공해야 하며, `HELP`, `TYPE` 라인을 사용한다면 이 둘은 제일 앞에 나와야 한다 (이 둘의 순서는 중요하지 않다). 그 외에도 exposition을 반복할 때마다 정렬을 유지해줄 수 있으면 좋지만 필수는 아니다. 다시 말해 계산 비용이 지나치게 크다면 정렬하지 마라.

각 라인은 반드시 고유한 메트릭명과 레이블 조합을 가지고 있어야 한다. 그렇지 않으면 수집 동작을 정의하지 않는다.

#### Histograms and summaries

`histogram`과 `summary` 타입을 텍스트 포맷으로 표현하는 건 좀 더 까다롭다. 여기에는 다음과 같은 컨벤션을 적용한다:

- `x`라는 이름의 summary나 histogram의 합계는 `x_sum`이라는 별도 샘플로 제공한다.
- `x`라는 이름의 summary나 histogram의 샘플 수는 `x_count`라는 별도 샘플로 제공한다.
- `x`라는 이름의 summray의 분위수<sup>quantile</sup>는 `x`라는 동일한 이름을 사용해 `{quantile="y"}` 레이블을 추가한 별도 샘플 라인으로 제공한다.
- `x`라는 histogram의 각 버킷 카운트는 `x_bucket`이란 이름과 `{le="y"}` 레이블을 가지는 별도 샘플 라인으로 제공한다 (`y`는 버킷의 상한을 나타낸다).
- histogram에는 *반드시* `{le="+Inf"}`를 가지고 있는 버킷이 있어야 한다. 그 값은 *반드시* `x_count`의 값과 동일해야 한다.
- histogram의 버킷과 summary의 분위수<sup>quantile</sup>는 반드시 레이블의 숫자 값을 기준으로 오름차순으로 나타나야 한다 (각각 `le` 레이블과 `quantile` 레이블 값).

### Text format example

다음은 완전한 프로메테우스 메트릭 exposition 예시로, 주석, `HELP`/`TYPE` 표현식, histogram, summary, 문자 이스케이프 등을 포함하고 있다:

```prometheus
# HELP http_requests_total The total number of HTTP requests.
# TYPE http_requests_total counter
http_requests_total{method="post",code="200"} 1027 1395066363000
http_requests_total{method="post",code="400"}    3 1395066363000

# Escaping in label values:
msdos_file_access_time_seconds{path="C:\\DIR\\FILE.TXT",error="Cannot find file:\n\"FILE.TXT\""} 1.458255915e9

# Minimalistic line:
metric_without_timestamp_and_labels 12.47

# A weird metric from before the epoch:
something_weird{problem="division by zero"} +Inf -3982045

# A histogram, which has a pretty complex representation in the text format:
# HELP http_request_duration_seconds A histogram of the request duration.
# TYPE http_request_duration_seconds histogram
http_request_duration_seconds_bucket{le="0.05"} 24054
http_request_duration_seconds_bucket{le="0.1"} 33444
http_request_duration_seconds_bucket{le="0.2"} 100392
http_request_duration_seconds_bucket{le="0.5"} 129389
http_request_duration_seconds_bucket{le="1"} 133988
http_request_duration_seconds_bucket{le="+Inf"} 144320
http_request_duration_seconds_sum 53423
http_request_duration_seconds_count 144320

# Finally a summary, which has a complex representation, too:
# HELP rpc_duration_seconds A summary of the RPC duration in seconds.
# TYPE rpc_duration_seconds summary
rpc_duration_seconds{quantile="0.01"} 3102
rpc_duration_seconds{quantile="0.05"} 3272
rpc_duration_seconds{quantile="0.5"} 4773
rpc_duration_seconds{quantile="0.9"} 9001
rpc_duration_seconds{quantile="0.99"} 76656
rpc_duration_seconds_sum 1.7560473e+07
rpc_duration_seconds_count 2693
```

---

## OpenMetrics Text Format

[OpenMetrics](https://github.com/OpenObservability/OpenMetrics)는 프로메테우스 텍스트 포맷을 기반으로 메트릭 와이어 형식을 표준화하려는 결실이다. 이 포맷으로 타겟을 스크랩할 수 있으며, v2.23.0부터는 메트릭을 연합<sup>federation</sup>할 때도 사용할 수 있다.

### Exemplars (Experimental)

OpenMetrics 포맷을 이용하면 [Exemplar](https://github.com/OpenObservability/OpenMetrics/blob/main/specification/OpenMetrics.md#exemplars)를 노출하고 질의할 수 있다. 메트릭 셋은 결국 MetricFamily로 추려지는데, Exemplar는 이 메트릭 셋과 관련된 특정 시점의 스냅샷을 제공한다. 게다가 트레이싱 시스템과 함께 사용할 때는 Trace ID를 첨부해 특정 서비스와 관련해서 좀 더 자세한 정보를 제공할 수 있다.

이 기능은 아직 실험 단계이며, 사용하려면 최소 v2.26.0 버전이 필요하고, 인자에 `--enable-feature=exemplar-storage`를 추가해야 한다.

---

## Historical versions

옛날에 사용했던 포맷 버전들을 자세히 알고 싶다면 레거시 문서 [클라이언트 데이터 Exposition 포맷](https://docs.google.com/document/d/1ZjyKiKxZV83VI9ZKAXRGKaUKK2BIWCT7oiGBKDBpjEY/edit?usp=sharing)을 확인해봐라.