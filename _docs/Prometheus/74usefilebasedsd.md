---
title: Use file-based service discovery to discover scrape targets
category: Prometheus
order: 74
permalink: /Prometheus/guides.file-sd/
description: 파일 기반 서비스 디스커비리 사용 가이드
image: ./../../images/prometheus/logo.png
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/guides/file-sd/
parent: GUIDES
parentUrl: /Prometheus/guides/
---

---

프로메테우스는 [쿠버네티스](../configuration#kubernetes_sd_config), [Consul](../configuration#consul_sd_config) 등, 스크랩 타겟을 검색해올 수 있는 다양한 [서비스 디스커비리 옵션들](https://github.com/prometheus/prometheus/tree/main/discovery)을 제공한다. 현재 지원하지 않는 서비스 디스커버리 시스템을 사용해야 한다면, 프로메테우스의 [파일 기반 서비스 디스커버리](../configuration/#file_sd_config) 메커니즘을 이용하는 게 가장 좋을 거다. 이 메커니즘에선 JSON 파일에 스크랩 타겟들을 지정할 수 있다 (타겟들의 메타데이터도 함께).

이 가이드에선 다음과 같은 내용들을 실습해본다:

- 로컬 환경에서 프로메테우스 [노트 익스포터](../guides.node-exporter)를 설치하고 실행한다
- `targets.json` 파일을 만들어 노트 익스포터의 호스트 정보와 포트 정보를 지정한다
- 프로메테우스를 설치하고, 이 `targets.json` 파일을 사용해서 노드 익스포터를 검색하도록 설정한 뒤 인스턴스를 실행한다

### 목차

- [Installing and running the Node Exporter](#installing-and-running-the-node-exporter)
- [Installing, configuring, and running Prometheus](#installing-configuring-and-running-prometheus)
- [Exploring the discovered services' metrics](#exploring-the-discovered-services-metrics)
- [Changing the targets list dynamically](#changing-the-targets-list-dynamically)
- [Summary](#summary)

---

## Installing and running the Node Exporter

[노드 익스포터를 이용해 리눅스 호스트 메트릭 모니터링하기](../guides.node-exporter) 가이드에서 [이 섹션](../guides.node-exporter#installing-and-running-the-node-exporter)을 참고해서 세팅을 완료해라. 노드 익스포터는 9100 포트에서 실행된다. 노드 익스포터가 메트릭을 노출하고 있는지 검증해보려면:

```sh
curl http://localhost:9100/metrics
```

다음과 같은 메트릭들이 출력될 거다:

```prometheus
# HELP go_gc_duration_seconds A summary of the GC invocation durations.
# TYPE go_gc_duration_seconds summary
go_gc_duration_seconds{quantile="0"} 0
go_gc_duration_seconds{quantile="0.25"} 0
go_gc_duration_seconds{quantile="0.5"} 0
...
```

---

## Installing, configuring, and running Prometheus

프로메테우스도 노드 익스포터와 마찬가지로 tarball을 통해 설치할 수 있는 하나의 스태틱 바이너리 파일이다. 플랫폼에 맞는 [최신 릴리즈를 다운받아](https://prometheus.io/download#prometheus) 압축을 풀어라:

```sh
wget https://github.com/prometheus/prometheus/releases/download/v*/prometheus-*.*-amd64.tar.gz
tar xvf prometheus-*.*-amd64.tar.gz
cd prometheus-*.*
```

압축을 해제한 디렉토리에는 설정 파일 `prometheus.yml`이 들어있다. 이 파일의 내용을 다음과 같이 변경해라:

```yaml
scrape_configs:
- job_name: 'node'
  file_sd_configs:
  - files:
    - 'targets.json'
```

이 설정에선 `node`라는 job을 지정했다 (노드 익스포터 전용). 이 job은 `targets.json` 파일에서 노드 익스포터 인스턴스의 호스트 정보와 포트 정보를 가져온다.

이번에는 `targets.json` 파일을 만들고 다음과 같은 내용을 추가해라:

```js
[
  {
    "labels": {
      "job": "node"
    },
    "targets": [
      "localhost:9100"
    ]
  }
]
```

> **참고:** 이 가이드에선 간단히 수동으로 JSON 서비스 디스커버리 설정을 만들었다. 보통은 JSON 생성 프로세스나 도구같은 걸 이용하길 권장한다.

이 설정에선 `localhost:9100` 타겟을 하나 가지고 있는 `node` job을 명시했다.

이제 프로메테우스를 시작해보자:

```sh
./prometheus
```

프로메테우스가 정상적으로 기동되면 다음과 같은 로그를 확인할 수 있다:

```sh
level=info ts=2018-08-13T20:39:24.905651509Z caller=main.go:500 msg="Server is ready to receive web requests."
```

---

## Exploring the discovered services' metrics

프로메테우스를 띄워 실행중일 때는 프로메테우스의 [expression 브라우저](../expression-browser)를 이용해 이 `node` 서비스가 노출한 메트릭을 살펴볼 수 있다. 예를 들어 [`up{job="node"}`](http://localhost:9090/graph?g0.range_input=1h&g0.expr=up%7Bjob%3D%22node%22%7D&g0.tab=1)을 조회해보면, 노드 익스포터를 적절하게 검색하고 있음을 알 수 있다.

---

## Changing the targets list dynamically

프로메테우스의 파일 기반 서비스 디스커버리 메커니즘을 사용할 때는, 프로메테우스 인스턴스가 파일의 변경 사항을 수신<sup>listen</sup>하고 있기 때문에 인스턴스를 재시작할 필요 없이 자동으로 스크랩 타겟 목록을 업데이트할 수 있다. 시연을 위해 9200 포트에서 두 번째 노드 익스포터 인스턴스를 기동해보자. 먼저 터미널 창을 하나 더 열고, 노드 익스포터 바이너리가 들어있는 디렉토리로 이동해서 다음 명령어를 실행해라:

```sh
./node_exporter --web.listen-address=":9200"
```

이제 `targets.json`을 수정해서 노드 익스포터 항목을 새로 추가해보자:

```js
[
  {
    "targets": [
      "localhost:9100"
    ],
    "labels": {
      "job": "node"
    }
  },
  {
    "targets": [
      "localhost:9200"
    ],
    "labels": {
      "job": "node"
    }
  }
]
```

변경 사항을 저장하면 프로메테우스는 새 타겟 목록을 자동으로 통지받는다. [`up{job="node"}`](http://localhost:9090/graph?g0.range_input=1h&g0.expr=up%7Bjob%3D%22node%22%7D&g0.tab=1) 메트릭을 조회하면 두 가지 인스턴스가 보이고, 각각의 `instance` 레이블은 `localhost:9100`, `localhost:9200`으로 설정돼있을 거다.

---

## Summary

이 가이드에선 프로메테우스 노드 익스포터를 설치하고 실행해봤으며, 프로메테우스에 파일 기반 서비스 디스커버리를 설정해서 노드 익스포터를 검색하고 메트릭을 스크랩했다.
