---
title: Writing HTTP Service Discovery
navTitle: HTTP SD
category: Prometheus
order: 34
permalink: /Prometheus/http-sd/
description: HTTP 서비스 디스커버리를 이용해 프로메테우스 타겟 등록하기
image: ./../../images/prometheus/logo.png
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/prometheus/2.32/http_sd
parent: PROMETHEUS
parentUrl: /Prometheus/prometheus/
---

---

프로메테우스는 HTTP 엔드포인트를 통해 타겟을 검색할 수 있는 범용적인 [HTTP 서비스 디스커버리](../configuration#http_sd_config)를 제공한다.

HTTP 서비스 디스커버리는 지원하는 다른 서비스 디스커버리 메커니즘을 보완할 수 있는, [파일 기반 서비스 디스커버리](https://prometheus.io/docs/guides/file-sd/#use-file-based-service-discovery-to-discover-scrape-targets)와는 또 다른 범용 디스커버리 메커니즘이다.

### 목차

- [Comparison between File-Based SD and HTTP SD](#comparison-between-file-based-sd-and-http-sd)
- [Requirements of HTTP SD endpoints](#requirements-of-http-sd-endpoints)
- [HTTP_SD format](#http_sd-format)

---

## Comparison between File-Based SD and HTTP SD

다음은 두 가지 범용적인 서비스 디스커버리 구현체를 비교해놓은 테이블이다:

| Item          | File SD               | HTTP SD                                     |
| :------------ | :-------------------- | :------------------------------------------ |
| 이벤트 기반   | Yes (inotify를 통해)  | No                                          |
| 업데이트 주기 | 즉시 (inotify 덕분에) | refresh_interval을 따라간다                 |
| 포맷          | Yaml/JSON             | JSON                                        |
| 전송          | 로컬 파일             | HTTP/HTTPS                                  |
| 보안          | 파일 기반             | TLS, Basic 인증, Authorization 헤더, OAuth2 |

---

## Requirements of HTTP SD endpoints

HTTP SD 엔드포인트를 구현하려면 여기에서 설명하는 요구 사항들을 숙지해야 한다.

응답은 따로 수정하지 않고 그대로 사용한다. 프로메테우스는 리프레시 간격마다 (디폴트 1분) HTTP SD 엔드포인트에 GET 요청을 전송한다. GET 요청에는 HTTP 헤더 `X-Prometheus-Refresh-Interval-Seconds`에 리프레시 간격이 담겨있다.

SD 엔드포인트는 반드시 HTTP 헤더 `Content-Type: application/json`과 함께 HTTP 200으로 응답해야 한다. 응답은 UTF-8 형식을 사용해야 한다. 전달할 타겟이 없을 때도 비어있는 리스트(`[]`)와 함께 HTTP 200을 전송해야 한다. 타겟 리스트에는 순서를 매기지 않는다.

프로메테우스는 타겟 목록을 캐시에 저장한다. 업데이트된 타겟 리스트를 가져오는 동안 에러가 발생하면 프로메테우스는 현재 가지고 있는 타겟 목록을 계속해서 사용한다. 재시작할 때는 타겟 목록을 따로 저장해놓거나 불러오지 않는다.

스크랩할 때마다 매번 전체 타겟 목록을 반환해야 한다. 타겟을 조금씩 추가해가는 것은 불가능하다. 프로메테우스 인스턴스는 호스트명을 따로 전달하지 않기 때문에, SD 엔드포인트에선 이번 SD 요청이 재시작한 뒤에 처음 있는 요청인지 아닌지를 알 수 없다.

HTTP SD에 대한 URL은 시크릿으로 관리하지 않는다. 필요한 인증이나 API 키들은 적절한 인증 메커니즘을 통해 전달해야 한다. 프로메테우스는 TLS 인증, 기본 인증, OAuth2, authorization 헤더를 지원한다.

---

## HTTP_SD format

```js
[
  {
    "targets": [ "<host>", ... ],
    "labels": {
      "<labelname>": "<labelvalue>", ...
    }
  },
  ...
]
```

예시:

```js
[
    {
        "targets": ["10.0.10.2:9100", "10.0.10.3:9100", "10.0.10.4:9100", "10.0.10.5:9100"],
        "labels": {
            "__meta_datacenter": "london",
            "__meta_prometheus_job": "node"
        }
    },
    {
        "targets": ["10.0.40.2:9100", "10.0.40.3:9100"],
        "labels": {
            "__meta_datacenter": "london",
            "__meta_prometheus_job": "alertmanager"
        }
    },
    {
        "targets": ["10.0.40.2:9093", "10.0.40.3:9093"],
        "labels": {
            "__meta_datacenter": "newyork",
            "__meta_prometheus_job": "alertmanager"
        }
    }
]
```
