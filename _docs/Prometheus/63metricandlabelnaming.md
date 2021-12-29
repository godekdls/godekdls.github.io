---
title: Metric and label naming
category: Prometheus
order: 63
permalink: /Prometheus/practices.naming/
description: 프로메테우스 메트릭, 레이블 이름 컨벤션
image: ./../../images/prometheus/logo.png
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/practices/naming/
parent: BEST PRACTICES
parentUrl: /Prometheus/practices/
---

---

이 문서에서 제시하는 메트릭과 레이블 컨벤션들은 프로메테우스를 사용하는 데 반드시 필요한 건 아니지만 스타일 가이드이자 베스트 프랙티스라고 봐주면 된다. 사용하는 조직에 따라, 이 중 네이밍 컨벤션같은 일부 프랙티스는 다르게 가져갈 수도 있다.

### 목차

- [Metric names](#metric-names)
- [Labels](#labels)
- [Base units](#base-units)

---

## Metric names

메트릭명은...

- ...[데이터 모델](../data-model/#metric-names-and-labels)에서 설명하는 유효한 문자를 사용해야 한다.
- ...메트릭이 속한 도메인과 관련된 애플리케이션 프리픽스가 있어야 한다 (단어 하나). 클라이언트 라이브러리에선 이 프리픽스를 `namespace`라고 부르기도 있다. 애플리케이션에서 전용으로 쓰는 메트릭이라면, 보통 애플리케이션 이름 자체를 프리픽스로 사용한다. 하지만 간혹 클라이언트 라이브러리에서 익스포트하는 표준화된 메트릭들처럼 좀 더 범용적인 메트릭도 있다. 예시:
  - <code class="highlighter-rouge"><strong>prometheus</strong>_notifications_total</code> (프로메테우스 서버 전용)
  - <code class="highlighter-rouge"><strong>process</strong>_cpu_seconds_total</code> (여러 가지 클라이언트 라이브러리에서 익스포트)
  - <code class="highlighter-rouge"><strong>http</strong>_request_duration_seconds</code> (모든 HTTP 요청에서 수집)
- ...반드시 단위를 하나 가지고 있어야 한다 (다시 말해 seconds를 milliseconds나 bytes와 혼용하면 안 된다).
- ...기본 단위를 사용해야 한다 (즉, milliseconds, megabytes, kilometers가 아닌 seconds, bytes, meters). 기본 단위 목록은 [아래](#base-units)를 참고하면 된다.
- ...복수 형태로 단위를 나타내는 suffix가 있어야 한다. 단, 누적 카운트는 `total`을 suffix로 사용하며, 가능하다면 단위도 함께 첨부한다.
  - <code class="highlighter-rouge">http_request_duration_<strong>seconds</strong></code>
  - <code class="highlighter-rouge">node_memory_usage_<strong>bytes</strong></code>
  - <code class="highlighter-rouge">http_requests_<strong>total</strong></code> (단위가 없는 누적 카운트)
  - <code class="highlighter-rouge">process_cpu_<strong>seconds_total</strong></code> (단위가 있는 누적 카운트)
  - <code class="highlighter-rouge">foobar_build<strong>_info</strong></code> (실행 중인 바이너리의 [메타데이터](https://www.robustperception.io/exposing-the-software-version-to-prometheus)를 제공하는 슈도 메트릭<sup>pseudo-metric</sup>)
- ...레이블 차원<sup>dimension</sup> 전체에 걸쳐 논리적으로 동일한 측정 대상을 나타내야 한다.
  - 요청 지속 시간
  - 전송한 데이터 바이트
  - 백분율로 나타낸 순간 리소스 사용량

경험상 모든 차원<sup>dimension</sup>에서 `sum()`이나 `avg()`를 계산했을 때 의미가 있는 (항상 유용한 건 아니지만) 데이터를 하나의 메트릭으로 두는 게 좋다. 계산해도 별 의미가 없다면 데이터를 여러 메트릭으로 분할해라. 예를 들어, 다양한 대기열들의 용량을 하나의 메트릭으로 저장하는 것은 괜찮지만, 현재 대기열에 있는 요소 갯수를 대기열 용량과 같이 저장하는 것은 좋지 않다.

---

## Labels

측정하는 대상의 특성들은 레이블을 이용해 구분해라:

- `api_http_requests_total` - 요청 타입 구분: `operation="create|update|delete"`
- `api_request_duration_seconds` - 요청 단계 구분: `stage="extract|transform|load"`

메트릭명에는 레이블 이름을 넣지 마라. 굳이 중복으로 넣을 필요도 없으며, 레이블들을 모아 집계한다면 오히려 더 혼란스러울 거다.

> **주의:** 고유한 키-값 레이블 쌍 조합마다 다른 시계열을 나타낸다는 점을 기억해두자. 레이블을 어떻게 사용하느냐에 따라 저장하는 데이터 양이 극단적으로 늘어날 수도 있다. 사용자 ID, 이메일 주소같이 값에 제한이 없는 데이터처럼 카디널리티가 매우 높은 (레이블 값이 매우 다양한) 데이터는 레이블을 이용해 차원을 나누면 안 된다.

---

## Base units

프로메테우스는 어떤 단위도 하드 코딩하지 않는다. 호환성을 지키려면 기본 단위를 사용해야 한다. 다음은 기본 단위와 함께 몇 가지 메트릭 패밀리를 정리해둔 테이블이다. 이 목록에 있는 게 전부는 아니다.

| Family           | Base unit | Remark                                                       |
| :--------------- | :-------- | :----------------------------------------------------------- |
| Time             | seconds   |                                                              |
| Temperature      | celsius   | 실용적인 면에서 *켈빈<sup>kelvin</sup>*보단 *섭씨<sup>celsius</sup>*를 선호한다. 색온도같은 특이 케이스나 절대 온도를 측정해야 하는 경우엔 *켈빈*을 기본 단위로 사용할 수 있다. |
| Length           | meters    |                                                              |
| Bytes            | bytes     |                                                              |
| Bits             | bytes     | *비트*가 더 흔히 보인다고 하더라도, 다른 메트릭들을 결합해서 헷갈리는 것 보단, 항상 *바이트*를 사용하는게 좋다. |
| Percent          | ratio     | 값에는 0–1을 사용한다 (0–100이 아니다). `ratio`는 `disk_usage_ratio`같이, 이름의 suffix로만 사용한다. 일반적인 메트릭 이름은 `A_per_B` 패턴을 따른다. |
| Voltage          | volts     |                                                              |
| Electric current | amperes   |                                                              |
| Energy           | joules    |                                                              |
| Power            |           | 카운터는 줄<sup>joule</sup>로 익스포트하고 싶다면, `rate(joules[5m])`을 이용하면 와트 단위 전력을 계산할 수 있다. |
| Mass             | grams     | *kilo*는 프리픽스 문제가 있기 때문에 *kilograms*보단 *grams*를 선호한다. |