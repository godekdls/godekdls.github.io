---
title: Getting started
category: Prometheus
order: 16
permalink: /Prometheus/getting-started/
description: 프로메테우스 시작하기
image: ./../../images/prometheus/logo.png
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/prometheus/2.32/getting_started/
parent: PROMETHEUS
parentUrl: /Prometheus/prometheus/
priority: 0.8
---

---

이 가이드는 간단한 프로메테우스 인스턴스를 설치하고, 설정하고, 사용하는 방법을 보여주는 "Hello World" 스타일의 튜토리얼이다. 프로메테우스를 로컬에 다운받아 실행해보고, 프로메테우스 자체 데이터와 예제 애플리케이션을 스크랩하도록 설정한 다음, 쿼리, rule, 그래프를 사용해 수집한 시계열 데이터를 다뤄볼 거다.

### 목차

- [Downloading and running Prometheus](#downloading-and-running-prometheus)
- [Configuring Prometheus to monitor itself](#configuring-prometheus-to-monitor-itself)
- [Starting Prometheus](#starting-prometheus)
- [Using the expression browser](#using-the-expression-browser)
- [Using the graphing interface](#using-the-graphing-interface)
- [Starting up some sample targets](#starting-up-some-sample-targets)
- [Configure Prometheus to monitor the sample targets](#configure-prometheus-to-monitor-the-sample-targets)
- [Configure rules for aggregating scraped data into new time series](#configure-rules-for-aggregating-scraped-data-into-new-time-series)

---

## Downloading and running Prometheus

사용 중인 플랫폼에 맞는 프로메테우스의 [최신 릴리즈를 다운로드](https://prometheus.io/download) 받고, 압축을 풀어 실행해보자:

```sh
tar xvfz prometheus-*.tar.gz
cd prometheus-*
```

프로메테우스를 시작하기 전에 먼저 설정들을 다뤄보자.

---

## Configuring Prometheus to monitor itself

프로메테우스는 메트릭 HTTP 엔드포인트를 스크랩하는 식으로 *타겟들*의 메트릭을 수집한다. 프로메테우스는 자체 데이터도 같은 방식으로 노출시키기 때문에, 자체 상태도 스크랩하고 모니터링할 수 있다.

프로메테우스 서버로 자체 데이터만 수집하는 건 딱히 효용은 없지만 처음 시작해보기엔 좋은 예시다. 아래 있는 기초 프로메테우스 설정을 `prometheus.yml`이란 파일로 저장해보자:

```yaml
global:
  scrape_interval:     15s # 기본적으로 타겟들을 15초마다 스크랩한다.

  # 외부 시스템(federation, 리모트 스토리지, Alertmanager)과 통신할 때는
  # 모든 시계열, alert에 이 레이블들을 덧붙인다.
  external_labels:
    monitor: 'codelab-monitor'

# 스크랩할 엔드포인트를 딱 하나 가지고 있는 스크랩 설정:
# 여기선 프로메테우스 자체를 스크랩한다.
scrape_configs:
  # 이 설정으로 스크랩한 모든 시계열에 `job=<job_name>` 레이블로 job 이름을 추가한다.
  - job_name: 'prometheus'

    # 글로벌로 설정해둔 기본값을 재정의하며, 이 job에선 타겟을 5초 간격으로 스크랩한다.
    scrape_interval: 5s

    static_configs:
      - targets: ['localhost:9090']
```

전체 설정 옵션 스펙은 [설정 문서](../configuration)를 참고해라.

---

## Starting Prometheus

새로 만든 설정 파일로 프로메테우스를 시작하려면, 프로메테우스 바이너리 파일이 들어 있는 디렉토리로 이동해서 아래 명령어를 실행해라:

```sh
# 프로메테우스를 시작한다.
# 프로메테우스는 기본적으로 ./data 경로 밑에 데이터베이스를 저장한다 (--storage.tsdb.path 플래그).
./prometheus --config.file=prometheus.yml
```

이제 프로메테우스가 시작될 거다. http://localhost:9090에서 프로메테우스 자체의 status 페이지를 둘러볼 수도 있다. 자체 HTTP 메트릭 엔드포인트에서 자신에 대한 데이터를 수집할 수 있도록 몇 초 정도 기다려봐라.

자체 메트릭 엔드포인트(http://localhost:9090/metrics)로 접근하면 프로메테우스가 자체 메트릭을 서빙하고 있는지도 확인해볼 수 있다.

---

## Using the expression browser

프로메테우스가 자체적으로 수집한 데이터를 살펴보도록 하자. 프로메테우스의 내장 expression 브라우저를 사용하려면 http://localhost:9090/graph로 이동해서 "Graph" 탭의 "Console" 뷰를 클릭해라.

http://localhost:9090/metrics에서도 확인할 수 있듯이, 프로메테우스가 자체적으로 내보내는 메트릭에는 `prometheus_target_interval_length_seconds`(실제로 타겟을 스크랩한 간격)라는 메트릭이 있다. 표현식 콘솔에 다음과 같이 입력하고 "Execute"를 클릭해봐라:

```prometheus
prometheus_target_interval_length_seconds
```

이렇게 하면 `prometheus_target_interval_length_seconds`란 이름을 가진 여러 가지 시계열이 반환될 건데, 레이블은 모두 다를 거다 (시계열 데이터마다 최신 기록 값을 가지고 있다). 이 레이블들은 각자 다른 지연 시간 백분위수<sup>percentile</sup>와 타겟 그룹의 interval을 나타낸다.

99번째 백분위수<sup>percentile</sup>에만 관심 있다면 아래 쿼리로 검색하면 된다:

```prometheus
prometheus_target_interval_length_seconds{quantile="0.99"}
```

반환된 시계열의 갯수는 다음과 같이 조회할 수 있다:

```prometheus
count(prometheus_target_interval_length_seconds)
```

표현식 언어에 대한 자세한 내용은 [표현식 언어 문서](../querying.basics)를 참고해라.

---

## Using the graphing interface

표현식을 그래프로 그려보려면 http://localhost:9090/graph로 이동해서 "Graph" 탭을 클릭해라.

예를 들어서 자체로 스크랩한 프로메테우스 지표에서, 생성하는 청크 수를 초 단위로 그려보려면 아래 표현식을 입력해라:

```prometheus
rate(prometheus_tsdb_head_chunks_created_total[1m])
```

그래프 range 파라미터나 다른 설정으로 여러 가지 실험을 해봐도 좋다.

---

## Starting up some sample targets

이번에는 프로메테우스가 스크랩할 타겟을 더 추가해보자.

타겟 예시로 노드 익스포터를 사용할 건데, 자세한 사용법은 [이 가이드를 참고해라](../guides.node-exporter).

```sh
tar -xzvf node_exporter-*.*.tar.gz
cd node_exporter-*.*

# 별도 터미널에서 샘플 타겟을 3벌 시작한다
./node_exporter --web.listen-address 127.0.0.1:8080
./node_exporter --web.listen-address 127.0.0.1:8081
./node_exporter --web.listen-address 127.0.0.1:8082
```

이제 http://localhost:8080/metrics, http://localhost:8081/metrics, http://localhost:8082/metrics에서 수신<sup>listen</sup> 중인 샘플 타겟이 더 생겼다.

---

## Configure Prometheus to monitor the sample targets

이제 프로메테우스가 이 새 타겟들을 스크랩하도록 설정해보겠다. 세 가지 엔드포인트를 모두 `node`라는 하나의 job으로 묶어보자. 처음 두 엔드포인트는 프로덕션 타겟, 세 번째 엔드포인트는 카나리 인스턴스라고 가정하겠다. 프로메테우스에서 이 구조를 모델링할땐, 단일 job에 엔드포인트 그룹을 여러 개 추가하고, 타겟 그룹마다 별도 레이블을 추가해주면 된다. 이 예시에선 첫 번째 타겟 그룹엔 `group="production"` 레이블을, 두 번째 그룹엔 `group="canary"`를 추가할 거다.

`prometheus.yml`에 있는 `scrape_configs` 섹션에 아래 job 정의를 추가하고 프로메테우스 인스턴스를 재시작해라:

```yaml
scrape_configs:
  - job_name:       'node'

    # 글로벌로 설정해둔 기본값을 재정의하며, 이 job에선 타겟을 5초 간격으로 스크랩한다.
    scrape_interval: 5s

    static_configs:
      - targets: ['localhost:8080', 'localhost:8081']
        labels:
          group: 'production'

      - targets: ['localhost:8082']
        labels:
          group: 'canary'
```

expression 브라우저로 돌아가서, 이제 프로메테우스에 이 예제 엔드포인트들에서 노출하는 시계열에 대한 정보가 있는지 확인해봐라 (`node_cpu_seconds_total` 등).

---

## Configure rules for aggregating scraped data into new time series

이 예제에선 별 문제 없지만, 시계열 수천 개를 집계하는 쿼리를 애드혹으로 계산한다면 지연이 생길 수 있다. 프로메테우스에선 설정해둔 *recording rule*을 통해 표현식을 새로운 시계열로 미리 기록하고 저장해둘 수 있어 더 효율적이다. 5분짜리 윈도우로 인스턴스마다 모든 CPU로 평균을 낸 초당 CPU 시간(`node_cpu_seconds_total`)을 기록하고자 한다고 해보자 (단, `job`, `instance`, `mode` 차원은 유지). 이 지표는 다음과 같이 작성할 수 있다:

```prometheus
avg by (job, instance, mode) (rate(node_cpu_seconds_total[5m]))
```

이 표현식으로 그래프를 그려봐라.

이 표현식으로 만들어지는 시계열을 `job_instance_mode:node_cpu_seconds:avg_rate5m`이란 새 메트릭에 기록하려면, 아래 recording rule을 파일을 적고 `prometheus.rules.yml`로 저장해라.

```yaml
groups:
- name: cpu-node
  rules:
  - record: job_instance_mode:node_cpu_seconds:avg_rate5m
    expr: avg by (job, instance, mode) (rate(node_cpu_seconds_total[5m]))
```

새로 만든 이 rule을 프로메테우스에서 사용하도록 만들려면 `prometheus.yml`에 `rule_files` 구문을 추가해라. 이제 설정은 다음과 같이 바뀐다:

```yaml
global:
  scrape_interval:     15s # 기본적으로 타겟을 15초마다 스크랩한다.
  evaluation_interval: 15s # rule을 15초마다 평가한다.

  # 이 프로메테우스 인스턴스가 수집하는 모든 시계열에 이 레이블들을 별도로 첨가한다.
  external_labels:
    monitor: 'codelab-monitor'

rule_files:
  - 'prometheus.rules.yml'

scrape_configs:
  - job_name: 'prometheus'

    # 글로벌로 설정해둔 기본값을 재정의하며, 이 job에선 타겟을 5초 간격으로 스크랩한다.
    scrape_interval: 5s

    static_configs:
      - targets: ['localhost:9090']

  - job_name:       'node'

    # 글로벌로 설정해둔 기본값을 재정의하며, 이 job에선 타겟을 5초 간격으로 스크랩한다.
    scrape_interval: 5s

    static_configs:
      - targets: ['localhost:8080', 'localhost:8081']
        labels:
          group: 'production'

      - targets: ['localhost:8082']
        labels:
          group: 'canary'
```

새 설정으로 프로메테우스를 다시 시작하고, 메트릭 이름이 `job_instance_mode:node_cpu_seconds:avg_rate5m`인 새 시계열 데이터가 있는지 expression 브라우저를 통해 질의해보거나, 그래프로 나타내봐라.