---
title: HTTP API
category: Prometheus
order: 31
permalink: /Prometheus/querying.api/
description: 프로메테우스 HTTP API 가이드
image: ./../../images/prometheus/logo.png
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/prometheus/2.32/querying/api/
parent: PROMETHEUS
parentUrl: /Prometheus/prometheus/
subparent: Querying
subparentUrl: /Prometheus/querying/
---

---

HTTP API의 현재 stable 버전은 프로메테우스 서버에서 `/api/v1`로 접근할 수 있다. 호환에 문제가 없는 추가 기능은 이 엔드포인트 아래에 추가된다.

### 목차

- [Format overview](#format-overview)
- [Expression queries](#expression-queries)
  + [Instant queries](#instant-queries)
  + [Range queries](#range-queries)
- [Querying metadata](#querying-metadata)
  + [Finding series by label matchers](#finding-series-by-label-matchers)
  + [Getting label names](#getting-label-names)
  + [Querying label values](#querying-label-values)
- [Querying exemplars](#querying-exemplars)
- [Expression query result formats](#expression-query-result-formats)
  + [Range vectors](#range-vectors)
  + [Instant vectors](#instant-vectors)
  + [Scalars](#scalars)
  + [Strings](#strings)
- [Targets](#targets)
- [Rules](#rules)
- [Alerts](#alerts)
- [Querying target metadata](#querying-target-metadata)
- [Querying metric metadata](#querying-metric-metadata)
- [Alertmanagers](#alertmanagers)
- [Status](#status)
  + [Config](#config)
  + [Flags](#flags)
  + [Runtime Information](#runtime-information)
  + [Build Information](#build-information)
  + [TSDB Stats](#tsdb-stats)
  + [WAL Replay Stats](#wal-replay-stats)
- [TSDB Admin APIs](#tsdb-admin-apis)
  + [Snapshot](#snapshot)
  + [Delete Series](#delete-series)
  + [Clean Tombstones](#clean-tombstones)

---

## Format overview

API 응답 형식은 JSON이다. 성공한 API 요청은 모두 상태 코드 `2xx`를 반환한다.

API 핸들러에 잘못된 요청을 보내면 JSON 에러 객체와 함께 아래 HTTP 응답 코드 중 하나를 반환한다:

- 파라미터가 누락됐거나 잘못된 경우 `400 Bad Request`.
- 표현식을 실행할 수 없는 경우 `422 Unprocessable Entity` ([RFC4918](https://tools.ietf.org/html/rfc4918#page-78)).
- 쿼리에서 타임아웃이 발생하거나 중단된 경우 `503 Service Unavailable`.

API 엔드포인트에 도달하기 전에 에러가 발생했을 땐 그외 다른 `2xx` 이외의 코드를 반환할 수도 있다.

오류가 있더라도 요청은 실행됐을 경우 warnings 배열을 반환할 수 있다. 수집을 완료한 모든 데이터는 data 필드에 담겨서 반환된다.

JSON 응답 형식은 다음과 같다:

```js
{
  "status": "success" | "error",
  "data": <data>,

  // status가 "error"일 때만 설정한다.
  // error가 있더라도 data 필드에 데이터를 가지고 있을 수도 있다.
  "errorType": "<string>",
  "error": "<string>",

  // 요청을 실행하는 동안 warning이 생겼을 때만.
  // data 필드에 데이터를 가지고 있을 수도 있다.
  "warnings": ["<string>"]
}
```

공통으로 사용하는 플레이스홀더는 다음과 같다:

- `<rfc3339 | unix_timestamp>`: 입력 타임스탬프는 [RFC3339](https://www.ietf.org/rfc/rfc3339.txt) 형식이나 초 단위 Unix 타임스탬프로 제공할 수 있으며, 초 단위 이하로 정밀도를 가져가고 싶으면 소숫점을 지정해도 된다. 출력 타임스탬프는 항상 초 단위 Unix 타임스탬프로 표시된다.
- `<series_selector>`: `http_requests_total`, `http_requests_total{method=~"(GET|POST)"}`같은 프로메테우스 [시계열 셀렉터](../querying.basics/#time-series-selectors)로, URL 인코딩이 필요하다.
- `<duration>`: [프로메테우스 기간 문자열](../querying.basics/#time-durations). 예를 들어 `5m`은 5분이라는 기간을 의미한다.
- `<bool>`: boolean 값 (문자열 `true`, `false`)

참고: 여러 번 반복할 수 있는 쿼리 파라미터들은 이름이 `[]`로 끝난다.

---

## Expression queries

쿼리 언어 표현식은 특정한 순간<sup>instant</sup>에 평가할 수도 있고, 일정 기간<sup>range of time</sup> 동안 평가할 수도 있다. 아래 섹션에선 각 표현식 쿼리 타입별 API 엔드포인트를 설명한다.

### Instant queries

다음 엔드포인트에선 단일 시점에 instant 쿼리를 평가한다:

```http
GET /api/v1/query
POST /api/v1/query
```

URL 파라미터:

- `query=<string>`: 프로메테우스 표현식 쿼리 문자열.
- `time=<rfc3339 | unix_timestamp>`: 평가 타임스탬프. 생략할 수 있다.
- `timeout=<duration>`: 평가 타임아웃. 생략할 수 있다. 디폴트로는 `-query.timeout` 플래그 값을 사용한다.

`time` 파라미터를 생략하면 현재 서버 시간을 사용한다.

`POST` 메소드와 `Content-Type: application/x-www-form-urlencoded` 헤더를 사용하면 위 파라미터들을 요청 바디에서 바로 URL 인코딩할 수 있다. 서버 측 URL 문자 제한을 위반할 수도 있는 쿼리를 대량으로 지정할 때 유용할 거다.

쿼리 결과에서 `data` 섹션은 다음과 같은 형식을 사용한다:

```js
{
  "resultType": "matrix" | "vector" | "scalar" | "string",
  "result": <value>
}
```

`<value>`는 쿼리의 결과 데이터로, `resultType`에 따라 다양한 형식을 가질 수 있다. [표현식 쿼리 결과 형식](#expression-query-result-formats)을 참고해라.

다음은 `2015-07-01T20:10:51.781Z` 시점의 `up` 표현식을 평가하는 예시다:

```sh
$ curl 'http://localhost:9090/api/v1/query?query=up&time=2015-07-01T20:10:51.781Z'
{
   "status" : "success",
   "data" : {
      "resultType" : "vector",
      "result" : [
         {
            "metric" : {
               "__name__" : "up",
               "job" : "prometheus",
               "instance" : "localhost:9090"
            },
            "value": [ 1435781451.781, "1" ]
         },
         {
            "metric" : {
               "__name__" : "up",
               "job" : "node",
               "instance" : "localhost:9100"
            },
            "value" : [ 1435781451.781, "0" ]
         }
      ]
   }
}
```

### Range queries

다음 엔드포인트에선 일정 기간 동안의 표현식 쿼리를 평가한다:

```http
GET /api/v1/query_range
POST /api/v1/query_range
```

URL 파라미터:

- `query=<string>`: 프로메테우스 표현식 쿼리 문자열.
- `start=<rfc3339 | unix_timestamp>`: 시작 타임스탬프(inclusive).
- `end=<rfc3339 | unix_timestamp>`: 종료 타임스탬프(inclusive).
- `step=<duration | float>`: `duration` 포맷이나, 초 단위를 부동 소수점으로 나타낸 쿼리 리졸브 보폭.
- `timeout=<duration>`: 평가 타임아웃. 생략할 수 있다. 디폴트로는 `-query.timeout` 플래그 값을 사용한다.

`POST` 메소드와 `Content-Type: application/x-www-form-urlencoded` 헤더를 사용하면 위 파라미터들을 요청 바디에서 바로 URL 인코딩할 수 있다. 서버 측 URL 문자 제한을 위반할 수도 있는 쿼리를 대량으로 지정할 때 유용할 거다.

쿼리 결과에서 `data` 섹션은 다음과 같은 형식을 사용한다:

```js
{
  "resultType": "matrix",
  "result": <value>
}
```

`<value>` 플레이스홀더 형식은 [range-vector 결과 형식](#range-vectors)을 참고해라.

다음은 15초의 쿼리 해상도<sup>resolution</sup>로 30초에 걸쳐 `up` 표현식을 평가하는 예시다.

```sh
$ curl 'http://localhost:9090/api/v1/query_range?query=up&start=2015-07-01T20:10:30.781Z&end=2015-07-01T20:11:00.781Z&step=15s'
{
   "status" : "success",
   "data" : {
      "resultType" : "matrix",
      "result" : [
         {
            "metric" : {
               "__name__" : "up",
               "job" : "prometheus",
               "instance" : "localhost:9090"
            },
            "values" : [
               [ 1435781430.781, "1" ],
               [ 1435781445.781, "1" ],
               [ 1435781460.781, "1" ]
            ]
         },
         {
            "metric" : {
               "__name__" : "up",
               "job" : "node",
               "instance" : "localhost:9091"
            },
            "values" : [
               [ 1435781430.781, "0" ],
               [ 1435781445.781, "0" ],
               [ 1435781460.781, "1" ]
            ]
         }
      ]
   }
}
```

---

## Querying metadata

프로메테우스는 시계열과 레이블에 관한 메타데이터를 질의할 수 있는 API 엔드포인트 셋을 제공한다.

**참고:** 이 API 엔드포인트들은 선택한 시간 범위 내에 샘플이 없는 시계열이나, 삭제 API를 통해 샘플이 삭제된 것으로 마킹된 시계열의 메타데이터도 반환할 수 있다. 부가적으로 반환하는 시계열 메타데이터의 정확한 범위는 세부 구현을 따르고 있으며, 향후 변경될 수 있다.

### Finding series by label matchers

다음 엔드포인트에선 특정 레이블 셋과 매칭되는 시계열 목록을 반환한다:

```http
GET /api/v1/series
POST /api/v1/series
```

URL 파라미터:

- `match[]=<series_selector>`: 반환할 시계열을 선택하는 시계열 셀럭터 (여러 개 지정할 수 있다). `match[]` 인자는 최소한 하나는 제공해야 한다.
- `start=<rfc3339 | unix_timestamp>`: 시작 타임스탬프.
- `end=<rfc3339 | unix_timestamp>`: 종료 타임스탬프.

`POST` 메소드와 `Content-Type: application/x-www-form-urlencoded` 헤더를 사용하면 위 파라미터들을 요청 바디에서 바로 URL 인코딩할 수 있다. 서버 측 URL 문자 제한을 위반할 수도 있는 셀렉터를 다량 사용하거나 셀렉터를 동적으로 지정할 때 유용할 거다.

쿼리 결과에 있는 `data` 섹션은 객체 목록으로 구성되며, 각각은 시계열을 식별하는 레이블 이름/값 쌍을 포함하고 있다.

다음은 셀렉터 `up` 또는 `process_start_time_seconds{job="prometheus"}` 중 하나라도 매칭되는 모든 시계열을 반환하는 예시다:

```sh
$ curl -g 'http://localhost:9090/api/v1/series?' --data-urlencode 'match[]=up' --data-urlencode 'match[]=process_start_time_seconds{job="prometheus"}'
{
   "status" : "success",
   "data" : [
      {
         "__name__" : "up",
         "job" : "prometheus",
         "instance" : "localhost:9090"
      },
      {
         "__name__" : "up",
         "job" : "node",
         "instance" : "localhost:9091"
      },
      {
         "__name__" : "process_start_time_seconds",
         "job" : "prometheus",
         "instance" : "localhost:9090"
      }
   ]
}
```

### Getting label names

다음 엔드포인트는 레이블 이름 목록을 반환한다:

```http
GET /api/v1/labels
POST /api/v1/labels
```

URL 파라미터:

- `start=<rfc3339 | unix_timestamp>`: 시작 타임스탬프. 생략할 수 있다.
- `end=<rfc3339 | unix_timestamp>`: 종료 타임스탬프. 생략할 수 있다.
- `match[]=<series_selector>`: 레이블 이름을 읽어올 시계열을 선택하는 시계열 셀럭터 (여러 개 지정할 수 있다). 생략할 수 있다.

문자열로된 레이블 이름 목록은 JSON 응답의 `data` 섹션에 들어있다.

다음은 api 예시다.

```sh
$ curl 'localhost:9090/api/v1/labels'
{
    "status": "success",
    "data": [
        "__name__",
        "call",
        "code",
        "config",
        "dialer_name",
        "endpoint",
        "event",
        "goversion",
        "handler",
        "instance",
        "interval",
        "job",
        "le",
        "listener_name",
        "name",
        "quantile",
        "reason",
        "role",
        "scrape_job",
        "slice",
        "version"
    ]
}
```

### Querying label values

다음 엔드포인트에선 지정한 레이블 이름에 저장돼 있는 레이블 값들의 목록을 반환한다:

```http
GET /api/v1/label/<label_name>/values
```

URL 파라미터:

- `start=<rfc3339 | unix_timestamp>`: 시작 타임스탬프. 생략할 수 있다.
- `end=<rfc3339 | unix_timestamp>`: 종료 타임스탬프. 생략할 수 있다.
- `match[]=<series_selector>`: 레이블 값을 읽어올 시계열을 선택하는 시계열 셀럭터 (여러 개 지정할 수 있다). 생략할 수 있다.

문자열로된 레이블 값 목록은 JSON 응답의 `data` 섹션에 들어있다.

다음은 `job` 레이블에 저장된 모든 값들을 질의하는 예시다:

```sh
$ curl http://localhost:9090/api/v1/label/job/values
{
   "status" : "success",
   "data" : [
      "node",
      "prometheus"
   ]
}
```

---

## Querying exemplars

이 엔드포인트는 **실험적**인 기능으로, 향후 변경될 수 있다. 다음 엔드포인트는 특정한 시간 범위에서 유효한 PromQL 쿼리의 exemplar 목록을 반환한다:

```http
GET /api/v1/query_exemplars
POST /api/v1/query_exemplars
```

URL 파라미터:

- `query=<string>`: 프로메테우스 표현식 쿼리 문자열.
- `start=<rfc3339 | unix_timestamp>`: 시작 타임스탬프.
- `end=<rfc3339 | unix_timestamp>`: 종료 타임스탬프.

```sh
$ curl -g 'http://localhost:9090/api/v1/query_exemplars?query=test_exemplar_metric_total&start=2020-09-14T15:22:25.479Z&end=2020-09-14T15:23:25.479Z'
{
    "status": "success",
    "data": [
        {
            "seriesLabels": {
                "__name__": "test_exemplar_metric_total",
                "instance": "localhost:8090",
                "job": "prometheus",
                "service": "bar"
            },
            "exemplars": [
                {
                    "labels": {
                        "traceID": "EpTxMJ40fUus7aGY"
                    },
                    "value": "6",
                    "timestamp": 1600096945.479,
                }
            ]
        },
        {
            "seriesLabels": {
                "__name__": "test_exemplar_metric_total",
                "instance": "localhost:8090",
                "job": "prometheus",
                "service": "foo"
            },
            "exemplars": [
                {
                    "labels": {
                        "traceID": "Olp9XHlq763ccsfa"
                    },
                    "value": "19",
                    "timestamp": 1600096955.479,
                },
                {
                    "labels": {
                        "traceID": "hCtjygkIHwAN9vs4"
                    },
                    "value": "20",
                    "timestamp": 1600096965.489,
                },
            ]
        }
    ]
}
```

---

## Expression query result formats

표현식 쿼리는 `data` 섹션의 `result` 속성에 다음과 같은 응답 값들을 반환할 수 있다. `<sample_value>` 플레이스홀더는 숫자로 된 샘플 값을 나타낸다. JSON은 `NaN`, `Inf`, `-Inf`같은 특수 float 값을 지원하지 않으므로, 샘플 값은 숫자 그대로 전달하지 않고 따옴표로 감싼 JSON 문자열로 전송한다.

### Range vectors

Range 벡터는 result type을 `matrix`로 반환한다. 이때 `result` 속성에 사용하는 형식은 다음과 같다:

```js
[
  {
    "metric": { "<label_name>": "<label_value>", ... },
    "values": [ [ <unix_time>, "<sample_value>" ], ... ]
  },
  ...
]
```

### Instant vectors

Instant 벡터는 result type을 `vector`로 반환한다. 이때 `result` 속성에 사용하는 형식은 다음과 같다:

```js
[
  {
    "metric": { "<label_name>": "<label_value>", ... },
    "value": [ <unix_time>, "<sample_value>" ]
  },
  ...
]
```

### Scalars

결과가 스칼라일 땐 result type을 `scalar`로 반환한다. 이때 `result` 속성에 사용하는 형식은 다음과 같다:

```js
[ <unix_time>, "<scalar_value>" ]
```

### Strings

결과가 문자열일 땐 result type을 `string`으로 반환한다. 이때 `result` 속성에 사용하는 형식은 다음과 같다:

```js
[ <unix_time>, "<string_value>" ]
```

---

## Targets

다음 엔드포인트는 프로메테우스 타겟 디스커버리의 현재 상태를 요약해서 보여준다:

```http
GET /api/v1/targets
```

기본적으로 활성화된 타겟과 삭제된 타겟 모두 응답에 포함된다. `labels`는 레이블 relabelling을 적용한 이후 설정한 레이블을 나타낸다. `discoveredLabels`는 relabelling을 적용하기 전, 서비스 디스커버리 과정에서 조회한 그대로의 레이블을 나타낸다.

```sh
$ curl http://localhost:9090/api/v1/targets
{
  "status": "success",
  "data": {
    "activeTargets": [
      {
        "discoveredLabels": {
          "__address__": "127.0.0.1:9090",
          "__metrics_path__": "/metrics",
          "__scheme__": "http",
          "job": "prometheus"
        },
        "labels": {
          "instance": "127.0.0.1:9090",
          "job": "prometheus"
        },
        "scrapePool": "prometheus",
        "scrapeUrl": "http://127.0.0.1:9090/metrics",
        "globalUrl": "http://example-prometheus:9090/metrics",
        "lastError": "",
        "lastScrape": "2017-01-17T15:07:44.723715405+01:00",
        "lastScrapeDuration": 0.050688943,
        "health": "up",
        "scrapeInterval": "1m",
        "scrapeTimeout": "10s"
      }
    ],
    "droppedTargets": [
      {
        "discoveredLabels": {
          "__address__": "127.0.0.1:9100",
          "__metrics_path__": "/metrics",
          "__scheme__": "http",
          "__scrape_interval__": "1m",
          "__scrape_timeout__": "10s",
          "job": "node"
        },
      }
    ]
  }
}
```

쿼리 파라미터 `state`를 지정하면 직접 활성 타겟이나 삭제된 타겟만 필터링할 수 있다 (ex. `state=active`, `state=dropped`, `state=any`). 참고로 필터링된 타겟에서도 빈 배열을 그대로 반환한다. 이 세 가지 외 다른 값은 무시한다.

```sh
$ curl 'http://localhost:9090/api/v1/targets?state=active'
{
  "status": "success",
  "data": {
    "activeTargets": [
      {
        "discoveredLabels": {
          "__address__": "127.0.0.1:9090",
          "__metrics_path__": "/metrics",
          "__scheme__": "http",
          "job": "prometheus"
        },
        "labels": {
          "instance": "127.0.0.1:9090",
          "job": "prometheus"
        },
        "scrapePool": "prometheus",
        "scrapeUrl": "http://127.0.0.1:9090/metrics",
        "globalUrl": "http://example-prometheus:9090/metrics",
        "lastError": "",
        "lastScrape": "2017-01-17T15:07:44.723715405+01:00",
        "lastScrapeDuration": 50688943,
        "health": "up"
      }
    ],
    "droppedTargets": []
  }
}
```

---

## Rules

`/rules` API 엔드포인트는 현재 로드돼 있는 alerting/recording rule 목록을 반환한다. alerting rule에선 프로메테우스 인스턴스에서 시행된<sup>fire</sup> 현재 활성 상태인 alert도 함께 반환한다.

`/rules` 엔드포인트는 완전히 새로운 엔드포인트이기 때문에, 전반적인 주요 API v1과 같은 안정성을 보장하지 않는다.

```http
GET /api/v1/rules
```

URL 파라미터:

- `type=alert|record`: alerting rule(`type=alert`) 또는 recording rule(`type=record`)만 반환한다. 파라미터가 없거나 비어 있으면 필터링하지 않는다.

```sh
$ curl http://localhost:9090/api/v1/rules

{
    "data": {
        "groups": [
            {
                "rules": [
                    {
                        "alerts": [
                            {
                                "activeAt": "2018-07-04T20:27:12.60602144+02:00",
                                "annotations": {
                                    "summary": "High request latency"
                                },
                                "labels": {
                                    "alertname": "HighRequestLatency",
                                    "severity": "page"
                                },
                                "state": "firing",
                                "value": "1e+00"
                            }
                        ],
                        "annotations": {
                            "summary": "High request latency"
                        },
                        "duration": 600,
                        "health": "ok",
                        "labels": {
                            "severity": "page"
                        },
                        "name": "HighRequestLatency",
                        "query": "job:request_latency_seconds:mean5m{job=\"myjob\"} > 0.5",
                        "type": "alerting"
                    },
                    {
                        "health": "ok",
                        "name": "job:http_inprogress_requests:sum",
                        "query": "sum by (job) (http_inprogress_requests)",
                        "type": "recording"
                    }
                ],
                "file": "/rules.yaml",
                "interval": 60,
                "name": "example"
            }
        ]
    },
    "status": "success"
}
```

---

## Alerts

`/alerts` 엔드포인트는 활성 상태에 있는 모든 alert 목록을 반환한다.

`/alerts` 엔드포인트는 완전히 새로운 엔드포인트이기 때문에, 전반적인 주요 API v1과 같은 안정성을 보장하지 않는다.

```sh
GET /api/v1/alerts
$ curl http://localhost:9090/api/v1/alerts

{
    "data": {
        "alerts": [
            {
                "activeAt": "2018-07-04T20:27:12.60602144+02:00",
                "annotations": {},
                "labels": {
                    "alertname": "my-alert"
                },
                "state": "firing",
                "value": "1e+00"
            }
        ]
    },
    "status": "success"
}
```

---

## Querying target metadata

다음 엔드포인트는 현재 타겟에서 스크랩한 메트릭에 관한 메타데이터를 반환한다. 이 엔드포인트는 **실험적**인 기능으로, 향후 변경될 수 있다.

```http
GET /api/v1/targets/metadata
```

URL 파라미터:

- `match_target=<label_selectors>`: 레이블 셋을 이용해 타겟을 매칭하는 레이블 셀렉터. 비워 두면 모든 타겟을 선택한다.
- `metric=<string>`: 메타데이터를 검색할 메트릭 명. 비워두면 모든 메트릭 메타데이터를 조회한다.
- `limit=<number>`: 매칭할 최대 타겟 수.

쿼리 결과에 있는 `data` 섹션은 객체 목록으로 구성되며, 각각은 메트릭 메타데이터와 타겟 레이블 셋을 포함하고 있다.

다음은 `job="prometheus"` 레이블을 가지고 있는 처음 두 타겟에서, `go_goroutines` 메트릭에 관한 모든 메타데이터 항목을 반환하는 예시다:

```sh
curl -G http://localhost:9091/api/v1/targets/metadata \
    --data-urlencode 'metric=go_goroutines' \
    --data-urlencode 'match_target={job="prometheus"}' \
    --data-urlencode 'limit=2'
{
  "status": "success",
  "data": [
    {
      "target": {
        "instance": "127.0.0.1:9090",
        "job": "prometheus"
      },
      "type": "gauge",
      "help": "Number of goroutines that currently exist.",
      "unit": ""
    },
    {
      "target": {
        "instance": "127.0.0.1:9091",
        "job": "prometheus"
      },
      "type": "gauge",
      "help": "Number of goroutines that currently exist.",
      "unit": ""
    }
  ]
}
```

다음은 `instance="127.0.0.1:9090` 레이블을 가지고 있는 모든 타겟에서, 모든 메트릭에 대한 메타데이터를 반환하는 예시다:

```sh
curl -G http://localhost:9091/api/v1/targets/metadata \
    --data-urlencode 'match_target={instance="127.0.0.1:9090"}'
{
  "status": "success",
  "data": [
    // ...
    {
      "target": {
        "instance": "127.0.0.1:9090",
        "job": "prometheus"
      },
      "metric": "prometheus_treecache_zookeeper_failures_total",
      "type": "counter",
      "help": "The total number of ZooKeeper failures.",
      "unit": ""
    },
    {
      "target": {
        "instance": "127.0.0.1:9090",
        "job": "prometheus"
      },
      "metric": "prometheus_tsdb_reloads_total",
      "type": "counter",
      "help": "Number of times the database reloaded block data from disk.",
      "unit": ""
    },
    // ...
  ]
}
```

---

## Querying metric metadata

이 엔드포인트는 현재 타겟에서 스크랩한 메트릭에 관한 메타데이터를 반환한다. 하지만 이번엔 타겟 정보는 제공하지 않는다. 이 엔드포인트는 **실험적**인 기능으로, 향후 변경될 수 있다.

```http
GET /api/v1/metadata
```

URL 파라미터:

- `limit=<number>`: 최대로 반환할 메트릭 수.
- `metric=<string>`: 메타데이터를 필터링할 메트릭 명. 비워두면 모든 메트릭 메타데이터를 조회한다.

쿼리 결과에 있는 `data` 섹션은 객체로 구성돼 있다. 이 객체의 키는 메트릭명이고, 값에는 모든 타겟에서 해당 메트릭 이름으로 노출하는 고유한 메타데이터 객체 목록이 담겨있다.

아래 예시에선 두 개의 메트릭을 반환한다. `http_requests_total` 메트릭의 목록에는 객체가 여러 개 들어있다. 최소 하나의 타겟에선 `HELP`에 나머지 타겟과는 일치하지 않는 값을 사용하고 있다는 뜻이다.

```sh
curl -G http://localhost:9090/api/v1/metadata?limit=2

{
  "status": "success",
  "data": {
    "cortex_ring_tokens": [
      {
        "type": "gauge",
        "help": "Number of tokens in the ring",
        "unit": ""
      }
    ],
    "http_requests_total": [
      {
        "type": "counter",
        "help": "Number of HTTP requests",
        "unit": ""
      },
      {
        "type": "counter",
        "help": "Amount of HTTP requests",
        "unit": ""
      }
    ]
  }
}
```

다음 예시는 `http_requests_total` 메트릭에 관한 메타데이터만 반환한다:

```sh
curl -G http://localhost:9090/api/v1/metadata?metric=http_requests_total

{
  "status": "success",
  "data": {
    "http_requests_total": [
      {
        "type": "counter",
        "help": "Number of HTTP requests",
        "unit": ""
      },
      {
        "type": "counter",
        "help": "Amount of HTTP requests",
        "unit": ""
      }
    ]
  }
}
```

---

## Alertmanagers

다음 엔드포인트는 프로메테우스 alertmanager 디스커버리의 현재 상태를 요약해서 보여준다:

```http
GET /api/v1/alertmanagers
```

활성화된 Alertmanager와 삭제된 Alertmanager 모두 응답에 포함된다.

```sh
$ curl http://localhost:9090/api/v1/alertmanagers
{
  "status": "success",
  "data": {
    "activeAlertmanagers": [
      {
        "url": "http://127.0.0.1:9090/api/v1/alerts"
      }
    ],
    "droppedAlertmanagers": [
      {
        "url": "http://127.0.0.1:9093/api/v1/alerts"
      }
    ]
  }
}
```

---

## Status

아래 있는 status 엔드포인트는 현재 프로메테우스 설정을 보여준다.

### Config

다음 엔드포인트는 현재 로드돼있는 설정 파일을 반환한다:

```http
GET /api/v1/status/config
```

설정은 YAML 덤프 파일로 반환한다. YAML 라이브러리의 제약으로 인해 YAML 주석은 포함되지 않는다.

```sh
$ curl http://localhost:9090/api/v1/status/config
{
  "status": "success",
  "data": {
    "yaml": "<content of the loaded config file in YAML>",
  }
}
```

### Flags

다음 엔드포인트는 프로메테우스를 설정한 플래그 값들을 반환한다.

```http
GET /api/v1/status/flags
```

모든 값들의 result type은 `string`이다.

```sh
$ curl http://localhost:9090/api/v1/status/flags
{
  "status": "success",
  "data": {
    "alertmanager.notification-queue-capacity": "10000",
    "alertmanager.timeout": "10s",
    "log.level": "info",
    "query.lookback-delta": "5m",
    "query.max-concurrency": "20",
    ...
  }
}
```

*v2.2에서 추가됐다*

### Runtime Information

다음 엔드포인트는 프로메테우스 서버에 관한 다양한 런타임 정보 프로퍼티를 반환한다:

```http
GET /api/v1/status/runtimeinfo
```

반환하는 값들은 런타임 프로퍼티 특성에 따라 각자 다른 타입을 사용한다.

```sh
$ curl http://localhost:9090/api/v1/status/runtimeinfo
{
  "status": "success",
  "data": {
    "startTime": "2019-11-02T17:23:59.301361365+01:00",
    "CWD": "/",
    "reloadConfigSuccess": true,
    "lastConfigTime": "2019-11-02T17:23:59+01:00",
    "timeSeriesCount": 873,
    "corruptionCount": 0,
    "goroutineCount": 48,
    "GOMAXPROCS": 4,
    "GOGC": "",
    "GODEBUG": "",
    "storageRetention": "15d"
  }
}
```

**참고:** 반환하는 정확한 런타임 프로퍼티들은 프로메테우스 버전이 올라갈 때 별도 공지 없이 변경될 수 있다.

*v2.14에서 추가됐다*

### Build Information

다음 엔드포인트는 프로메테우스 서버에 관한 다양한 빌드 정보 프로퍼티를 반환한다:

```http
GET /api/v1/status/buildinfo
```

모든 값들의 result type은 `string`이다.

```sh
$ curl http://localhost:9090/api/v1/status/buildinfo
{
  "status": "success",
  "data": {
    "version": "2.13.1",
    "revision": "cb7cbad5f9a2823a622aaa668833ca04f50a0ea7",
    "branch": "master",
    "buildUser": "julius@desktop",
    "buildDate": "20191102-16:19:59",
    "goVersion": "go1.13.1"
  }
}
```

**참고:** 반환하는 정확한 빌드 프로퍼티들은 프로메테우스 버전이 올라갈 때 별도 공지 없이 변경될 수 있다.

*v2.14에서 추가됐다*

### TSDB Stats

다음 엔드포인트는 프로메테우스 TSDB의 다양한 카디널리티 관련 통계치를 반환한다:

```http
GET /api/v1/status/tsdb
```

- **headStats**: TSDB의 헤드 블록에 관해서 다음과 같은 데이터를 제공한다:
  - **numSeries**: 시계열 갯수.
  - **chunkCount**: 청크 갯수.
  - **minTime**: 현재 최소 타임스탬프 (milliseconds)
  - **maxTime**: 현재 최대 타임스탬프 (milliseconds)
- **seriesCountByMetricName**: 메트릭명과 각 메트릭의 시계열 갯수를 가지고 있는 목록을 제공한다.
- **labelValueCountByLabelName**: 레이블명과 각 레이블의 값 갯수를 가지고 있는 목록을 제공한다.
- **memoryInBytesByLabelName**: 레이블 목록과 함께 각 레이블별 메모리 사용량(바이트 단위)을 제공한다. 메모리 사용량은 해당 레이블명에 있는 모든 값의 길이를 더해서 계산한다.
- **seriesCountByLabelPair**: 레이블 값 쌍 목록과 함께 각 값 쌍별 시계열 갯수를 제공한다.

```sh
$ curl http://localhost:9090/api/v1/status/tsdb
{
  "status": "success",
  "data": {
    "headStats": {
      "numSeries": 508,
      "chunkCount": 937,
      "minTime": 1591516800000,
      "maxTime": 1598896800143,
    },
    "seriesCountByMetricName": [
      {
        "name": "net_conntrack_dialer_conn_failed_total",
        "value": 20
      },
      {
        "name": "prometheus_http_request_duration_seconds_bucket",
        "value": 20
      }
    ],
    "labelValueCountByLabelName": [
      {
        "name": "__name__",
        "value": 211
      },
      {
        "name": "event",
        "value": 3
      }
    ],
    "memoryInBytesByLabelName": [
      {
        "name": "__name__",
        "value": 8266
      },
      {
        "name": "instance",
        "value": 28
      }
    ],
    "seriesCountByLabelValuePair": [
      {
        "name": "job=prometheus",
        "value": 425
      },
      {
        "name": "instance=localhost:9090",
        "value": 425
      }
    ]
  }
}
```

*v2.15에서 추가됐다*

### WAL Replay Stats

다음 엔드포인트는 WAL 리플레이에 관한 정보를 반환한다:

```http
GET /api/v1/status/walreplay
```

- **read**: 지금까지 리플레이한 세그먼트 수.
- **total**: 리플레이해야 하는 세그먼트의 총 갯수.
- **progress**: 리플레이 진행률 (0 - 100%).
- **state**: 리플레이의 상태. 가능한 상태:
  - **waiting**: 리플레이가 시작하길 기다리는 중.
  - **in progress**: 리플레이가 진행 중.
  - **done**: 리플레이가 종료됨.

```sh
$ curl http://localhost:9090/api/v1/status/walreplay
{
  "status": "success",
  "data": {
    "min": 2,
    "max": 5,
    "current": 40,
    "state": "in progress"
  }
}
```

**참고:** 이 엔드포인트는 서버를 ready 상태로 마킹하 전에도 사용할 수 있으며, WAL 리플레이 진행 상황을 쉽게 모니터링할 수 있도록 실시간으로 업데이트된다.

*v2.28에서 추가됐다*

---

## TSDB Admin APIs

여기서 설명하는 API들은 상급자용 API로, 데이터베이스 기능들을 노출한다. `--web.enable-admin-api`를 설정하지 않았다면 이 API들은 활성화되지 않는다.

### Snapshot

Snapshot은 TSDB의 데이터 디렉토리 밑에 있는 `snapshots/<datetime>-<rand>`에 현재 모든 데이터들의 스냅샷을 생성하며, 이 디렉토리를 응답으로 반환한다. 원한다면 헤드 블록에만 존재하며 아직 디스크에 쓰지 않은 데이터는 스냅샷을 만들지 않고 건너뛸 수 있다.

```http
POST /api/v1/admin/tsdb/snapshot
PUT /api/v1/admin/tsdb/snapshot
```

URL 파라미터:

- `skip_head=<bool>`: 헤드 블록에 있는 데이터는 스킵한다. 생략할 수 있다.

```sh
$ curl -XPOST http://localhost:9090/api/v1/admin/tsdb/snapshot
{
  "status": "success",
  "data": {
    "name": "20171210T211224Z-2be650b6d019eb54"
  }
}
```

이제 스냅샷은 `<data-dir>/snapshots/20171210T211224Z-2be650b6d019eb54`에 저장돼있다.

*v2.1에서 추가됐으며, PUT 메소드는 v2.9부터 지원한다*

### Delete Series

DeleteSeries는 특정 시간 범위에서 선택한 시계열 데이터를 삭제한다. 삭제하더라도 실제 데이터는 디스크에 그대로 존재하며, 향후 디스크 컴팩션<sup>compaction</sup>에서 정리되거나 [Clean Tombstones](#clean-tombstones) 엔드포인트를 요청해 직접 정리할 수 있다.

삭제에 성공하면 `204`를 반환한다.

```http
POST /api/v1/admin/tsdb/delete_series
PUT /api/v1/admin/tsdb/delete_series
```

URL 파라미터:

- `match[]=<series_selector>`: 삭제할 시계열을 선택하는 레이블 매처 (여러 개 지정할 수 있다). `match[]` 인자는 최소한 하나는 제공해야 한다.
- `start=<rfc3339 | unix_timestamp>`: 시작 타임스탬프. 생략할 수 있으며, 기본값은 가능한 최소 시간이다.
- `end=<rfc3339 | unix_timestamp>`: 종료 타임스탬프. 생략할 수 있으며, 기본값은 가능한 최대 시간이다.

시작 시간과 종료 시간을 모두 지정하지 않으면 데이터베이스에서 매칭되는 시계열의 모든 데이터가 지워진다.

예시:

```sh
$ curl -X POST \
  -g 'http://localhost:9090/api/v1/admin/tsdb/delete_series?match[]=up&match[]=process_start_time_seconds{job="prometheus"}'
```

**참고:** 이 엔드포인트는 시계열에 있는 샘플들을 삭제한 것으로 마킹하지만, 영향 범위에 있는 메타데이터를 질의할 땐 관련 시계열 메타데이터가 그대로 반환되는 것을 반드시 막아주진 않는다 (톰스톤<sup>tombstone</sup>을 정리했더라도). 정확한 메타데이터 삭제 범위는 세부 구현을 따르고 있으며, 향후 변경될 수 있다.

*v2.1에서 추가됐으며, PUT 메소드는 v2.9부터 지원한다*

### Clean Tombstones

CleanTombstones는 디스크에서 삭제된 데이터를 제거하고 기존 톰스톤<sup>tombstone</sup>을 정리한다. 시계열을 삭제한 뒤 공간을 확보할 때 사용할 수 있다.

삭제에 성공하면 `204`를 반환한다.

```http
POST /api/v1/admin/tsdb/clean_tombstones
PUT /api/v1/admin/tsdb/clean_tombstones
```

이 API에선 파라미터나 바디를 받지 않는다.

```sh
$ curl -XPOST http://localhost:9090/api/v1/admin/tsdb/clean_tombstones
```

*v2.1에서 추가됐으며, PUT 메소드는 v2.9부터 지원한다*