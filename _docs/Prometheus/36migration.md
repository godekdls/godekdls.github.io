---
title: Prometheus 2.0 Migration Guide
navTitle: Migration
category: Prometheus
order: 36
permalink: /Prometheus/migration/
description: 프로메테우스 1.x -> 2.0 마이그레이션 가이드
image: ./../../images/prometheus/logo.png
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/prometheus/2.32/migration
parent: PROMETHEUS
parentUrl: /Prometheus/prometheus/
---

---

[안정성을 약속](https://prometheus.io/blog/2016/07/18/prometheus-1-0-released/#fine-print)했던 대로, 구버전과 호환되지 않는 여러 가지 변경 사항들은 프로메테우스 2.0 릴리즈에 추가됐다. 이 문서는 프로메테우스 1.8 버전에서 2.0 이상으로 마이그레이션하기 위한 가이드를 제공한다.

### 목차

- [Flags](#flags)
- [Alertmanager service discovery](#alertmanager-service-discovery)
- [Recording rules and alerts](#recording-rules-and-alerts)
- [Storage](#storage)
- [PromQL](#promql)
- [Miscellaneous](#miscellaneous)
  + [Prometheus non-root user](#prometheus-non-root-user)
  + [Prometheus lifecycle](#prometheus-lifecycle)
    
---

## Flags

프로메테우스 커맨드라인 플래그들의 형식이 변경됐다. 모든 플래그에서 이제 단일 대시 대신 이중 대시를 사용한다. 공통 플래그들은 남아 있지만 (`--config.file`, `--web.listen-address`, `--web.external-url`), 스토리지 관련 플래그들은 대부분이 제거됐다.

제거된 플래그 중 주목해서 봐야할 플래그들은 다음과 같다:

- `-alertmanager.url`: 프로메테우스 2.0에선 정적으로 Alertmanager URL을 설정했었던 커맨드라인 플래그가 제거됐다. 이제부턴 Alertmanager는 서비스 디스커버리를 통해 가져와야 한다. [Alertmanager 서비스 디스커버리](#alertmanager-service-discovery)를 참고해라.
- `-log.format`: 프로메테우스 2.0에선 로그는 표준 에러로만 스트리밍할 수 있다.
- `-query.staleness-delta`: `--query.lookback-delta`로 이름이 변경됐다. 프로메테우스 2.0은 staleness 처리를 위한 새로운 메커니즘을 도입했다. [staleness](../querying.basics#staleness)를 참고해라.
- `-storage.local.*`: 프로메테우스 2.0 부터 새로운 스토리지 엔진을 도입했다. 따라서 엔진과 관련있었던 모든 플래그들이 제거됐다. 새로운 엔진에 관한 정보는 [스토리지](#storage)를 참고해라.
- `-storage.remote.*`: 프로메테우스 2.0에선 deprecated됐던 리모트 스토리지 플래그들을 제거했으며, 이런 플래그를 지정하면 실행에 실패한다. InfluxDB, Graphite, OpenTSDB에 데이터를 저장하려면 관련 스토리지 어댑터를 활용해라.

---

## Alertmanager service discovery

Alertmanager 서비스 디스커버리는 프로메테우스 1.4에서 도입했으며, 프로메테우스가 스크랩 타겟을 발견하는 것과 동일한 메커니즘을 이용해 Alertmanager 레플리카를 동적으로 검색할 수 있다. 프로메테우스 2.0에선 Alertmanager static 설정을 위한 커맨드라인 플래그가 제거됐다. 따라서 아래 있는 커맨드라인 플래그는:

```sh
./prometheus -alertmanager.url=http://alertmanager:9093/
```

`prometheus.yml` 설정 파일에서 다음과 같이 대체해줘야 한다:

```yaml
alerting:
  alertmanagers:
  - static_configs:
    - targets:
      - alertmanager:9093
```

게다가 Alertmanager 설정에선 일반적인 프로메테우스 서비스 디스커버리 통합 기능과 relabeling을 전부 다 사용할 수 있다. 아래 있는 설정을 사용하면 프로메테우스는 `default` 네임스페이스에서 `name: alertmanager` 레이블을 가지고 있고 포트가 비어있지 않은 쿠버네티스 포드를 검색한다:

```yaml
alerting:
  alertmanagers:
  - kubernetes_sd_configs:
      - role: pod
    tls_config:
      ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
    bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
    relabel_configs:
    - source_labels: [__meta_kubernetes_pod_label_name]
      regex: alertmanager
      action: keep
    - source_labels: [__meta_kubernetes_namespace]
      regex: default
      action: keep
    - source_labels: [__meta_kubernetes_pod_container_port_number]
      regex:
      action: drop
```

---

## Recording rules and alerts

alerting/recording rule을 설정할 때는 YAML 형식을 사용하도록 변경됐다. 이전에는 recording rule과 alert를 다음과 같이 설정했었다:

```prometheus
job:request_duration_seconds:histogram_quantile99 =
  histogram_quantile(0.99, sum by (le, job) (rate(request_duration_seconds_bucket[1m])))

ALERT FrontendRequestLatency
  IF job:request_duration_seconds:histogram_quantile99{job="frontend"} > 0.1
  FOR 5m
  ANNOTATIONS {
    summary = "High frontend request latency",
  }
```

이제는 다음과 같이 설정한다:

```yaml
groups:
- name: example.rules
  rules:
  - record: job:request_duration_seconds:histogram_quantile99
    expr: histogram_quantile(0.99, sum by (le, job) (rate(request_duration_seconds_bucket[1m])))
  - alert: FrontendRequestLatency
    expr: job:request_duration_seconds:histogram_quantile99{job="frontend"} > 0.1
    for: 5m
    annotations:
      summary: High frontend request latency
```

`promtool` 툴에는 rule을 자동으로 변환해서 마이그레이션을 도와주는 모드가 있다. `.rules` 파일을 지정해주면 새 포맷을 적용한 `.rules.yml` 파일을 만들어준다. 예를 들어:

```sh
$ promtool update rules example.rules
```

이때는 [프로메테우스 2.5](https://github.com/prometheus/prometheus/releases/tag/v2.5.0)의 `promtool`을 사용해야 한다. 이후 버전에선 위와 같은 하위 명령어는 더 이상 들어있지 않다.

---

## Storage

프로메테우스 2.0의 데이터 형식은 완전히 달라졌으며, 1.8이나 이전 버전과는 호환되지 않는다. 기존 모니터링 데이터에 계속해서 액세스하고 싶다면, 따로 스크랩은 하지 않는 최소 1.8.1 버전의 프로메테우스 인스턴스를 프로메테우스 2.0 인스턴스와 병렬로 실행하고, remote read 프로토콜을 통해 새 서버에서 구 서버에 있는 기존 데이터를 읽어오는 것을 권장한다.

이때 프로메테우스 1.8 인스턴스는 아래 있는 플래그들과, `external_labels` 설정(필요하다면)만 들어있는 설정 파일로 시작해야 한다:

```sh
$ ./prometheus-1.8.1.linux-amd64/prometheus -web.listen-address ":9094" -config.file old.yml
```

프로메테우스 2.0은 아래 있는 플래그를 사용해서 (동일한 시스템에서) 시작하면 된다:

```sh
$ ./prometheus-2.0.0.linux-amd64/prometheus --config.file prometheus.yml
```

이때 `prometheus.yml`에는 기존 설정 외에 다음을 추가해준다:

```yaml
remote_read:
  - url: "http://localhost:9094/api/v1/read"
```

---

## PromQL

PromQL에선 다음과 같은 기능들이 제거됐다:

- `drop_common_labels` 함수 - 이 대신 aggregation modifier `without`을 사용해야 한다.
- `keep_common` aggregation modifier - 이 대신 `by` modifier를 사용해야 한다.operations.
- `count_scalar` 함수 - 이 유스 케이스는 `absent()`를 사용하거나, 연산에서 레이블을 적절히 전파해주면 더 잘 처리할 수 있다.

자세한 내용은 [이슈 #3060](https://github.com/prometheus/prometheus/issues/3060)을 확인해봐라.

---

## Miscellaneous

### Prometheus non-root user

프로메테우스 도커 이미지는 이제 [프로메테우스를 root가 아닌 다른 user로 실행](https://github.com/prometheus/prometheus/pull/2859)하도록 빌드했다. 프로메테우스 UI/API가 낮은 포트 번호(ex. 80)에서 수신<sup>listen</sup>하도록 만들고 싶다면 user를 재정의해야 한다. 쿠버네티스에선 아래 YAML을 사용하면 된다:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: security-context-demo-2
spec:
  securityContext:
    runAsUser: 0
...
```

자세한 내용은 [포드나 컨테이너를 위한 Security Context 설정](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)을 참고해라.

도커를 사용한다면 아래 명령어를 사용하면 된다:

```sh
docker run -p 9090:9090 prom/prometheus:latest
```

### Prometheus lifecycle

프로메테우스의 HTTP 엔드포인트 `/-/reload`를 이용해서 [프로메테우스 설정이 변경됐을 때 자동으로 다시 로드](../configuration/)하고 있다면, 이런 류의 엔드포인트들은 프로메테우스 2.0에선 보안상의 이유로 기본적으로 비활성화돼있다. 활성화하려면 `--web.enable-lifecycle` 플래그를 설정해라.

