---
title: Instrumenting a Go application for prometheus
navTitle: Instrumenting a Go application
category: Prometheus
order: 76
permalink: /Prometheus/guides.go-application/
description: Go 클라이언트 라이브러리 가이드
image: ./../../images/prometheus/logo.png
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/guides/go-application/
parent: GUIDES
parentUrl: /Prometheus/guides/
---

---

프로메테우스는 Go 애플리케이션을 계측하는 데 사용할 수 있는 공식 [Go 클라이언트 라이브러리](https://github.com/prometheus/client_golang)를 제공한다. 이 가이드에선 HTTP를 통해 프로메테우스 메트릭을 노출하는 간단한 Go 애플리케이션을 만들어본다.

> **참고:** 종합 API 문서는 프로메테우스의 다양한 Go 라이브러리들을 설명하고 있는 [GoDoc](https://godoc.org/github.com/prometheus/client_golang)을 참고하면 된다.

### 목차

- [Installation](#installation)
- [How Go exposition works](#how-go-exposition-works)
- [Adding your own metrics](#adding-your-own-metrics)
- [Other Go client features](#other-go-client-features)
- [Summary](#summary)

---

## Installation

이 가이드에서 필요한 `prometheus`, `promauto`, `promhttp` 라이브러리는 [`go get`](https://golang.org/doc/articles/go_command.html)을 이용해 설치할 수 있다:

```sh
go get github.com/prometheus/client_golang/prometheus
go get github.com/prometheus/client_golang/prometheus/promauto
go get github.com/prometheus/client_golang/prometheus/promhttp
```

---

## How Go exposition works

Go 애플리케이션에서 프로메테우스 메트릭을 노출하려면 `/metrics` HTTP 엔드포인트를 제공해야 한다. 이땐 [`prometheus/promhttp`](https://godoc.org/github.com/prometheus/client_golang/prometheus/promhttp) 라이브러리의 HTTP [`Handler`](https://godoc.org/github.com/prometheus/client_golang/prometheus/promhttp#Handler)를 핸들러 함수로 활용하면 된다.

아래 예시는 `http://localhost:2112/metrics`를 통해 Go 애플리케이션의 디폴트 메트릭을 노출하는 가장 간단한 애플리케이션이다:

```go
package main

import (
        "net/http"

        "github.com/prometheus/client_golang/prometheus/promhttp"
)

func main() {
        http.Handle("/metrics", promhttp.Handler())
        http.ListenAndServe(":2112", nil)
}
```

이 애플리케이션을 시작해보자:

```sh
go run main.go
```

메트릭에 접근하려면:

```sh
curl http://localhost:2112/metrics
```

---

## Adding your own metrics

[위에서 보여준](#how-go-exposition-works) 애플리케이션은 디폴트 Go 메트릭만 노출하고 있다. 애플리케이션 전용으로 사용할 자체 커스텀 메트릭도 등록할 수 있다. 이 예제 애플리케이션은 지금까지 이벤트를 처리한 횟수를 계산한 `myapp_processed_ops_total` [카운터](../metric-types#counter)를 노출한다. 이 카운터는 2초마다 1씩 증가한다.

```go
package main

import (
        "net/http"
        "time"

        "github.com/prometheus/client_golang/prometheus"
        "github.com/prometheus/client_golang/prometheus/promauto"
        "github.com/prometheus/client_golang/prometheus/promhttp"
)

func recordMetrics() {
        go func() {
                for {
                        opsProcessed.Inc()
                        time.Sleep(2 * time.Second)
                }
        }()
}

var (
        opsProcessed = promauto.NewCounter(prometheus.CounterOpts{
                Name: "myapp_processed_ops_total",
                Help: "The total number of processed events",
        })
)

func main() {
        recordMetrics()

        http.Handle("/metrics", promhttp.Handler())
        http.ListenAndServe(":2112", nil)
}
```

이 애플리케이션을 시작해보자:

```sh
go run main.go
```

메트릭에 접근하려면:

```sh
curl http://localhost:2112/metrics
```

메트릭 출력에선 `myapp_processed_ops_total` 카운터의 help 텍스트와 type 정보, 현재 값을 조회할 수 있다:

```prometheus
# HELP myapp_processed_ops_total The total number of processed events
# TYPE myapp_processed_ops_total counter
myapp_processed_ops_total 5
```

프로메테우스에 [설정](../configuration#scrape_config)을 추가하고, 로컬에서 인스턴스를 실행해서 이 애플리케이션의 메트릭을 스크랩해보자. 다음은 `prometheus.yml` 설정 예시다:

```yaml
scrape_configs:
- job_name: myapp
  scrape_interval: 10s
  static_configs:
  - targets:
    - localhost:2112
```

---

## Other Go client features

이 가이드에선 프로메테우스 Go 클라이언트 라이브러리에서 이용할 수 있는 기능 중 극히 일부만 다뤘다. [게이지](https://godoc.org/github.com/prometheus/client_golang/prometheus#Gauge), [히스토그램](https://godoc.org/github.com/prometheus/client_golang/prometheus#Histogram) 등 다른 메트릭 타입들도 노출할 수 있으며, [비전역 레지스트리](https://godoc.org/github.com/prometheus/client_golang/prometheus#Registry), 프로메테우스 [PushGateway](../pushing)에 [메트릭을 푸시](https://godoc.org/github.com/prometheus/client_golang/prometheus/push)하는 함수, 프로메테우스와 [Graphite](https://godoc.org/github.com/prometheus/client_golang/prometheus/graphite)를 연결<sup>bridge</sup>해주는 함수 등, 다른 기능들도 다양하게 지원하고 있다.

---

## Summary

이 가이드에선 프로메테우스에 메트릭을 노출하는 두 가지 Go 샘플 애플리케이션을 만들어봤다. 첫 번째 애플리케이션은 디폴트 Go 메트릭들만 노출했고, 두 번째 애플리케이션은 커스텀 프로메테우스 카운터도 함께 노출했다. 이 애플리케이션들에서 메트릭을 스크랩할 수 있도록 프로메테우스 인스턴스도 함께 설정해봤다.