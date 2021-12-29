---
title: First steps with prometheus
navTitle: First steps
category: Prometheus
order: 4
permalink: /Prometheus/first-steps/
description: 프로메테우스를 설치하고 기본 설정으로 기동해보고, 브라우저를 이용해 메트릭을 모니터링하고 그래프 생성해보기.
image: ./../../images/prometheus/logo.png
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/introduction/first_steps/
parent: INTRODUCTION
parentUrl: /Prometheus/introduction/
---

---

프로메테우스에 온 것을 환영한다! 프로메테우스는 모니터링 대상에서 메트릭 HTTP 엔드포인트를 스크랩해 메트릭을 수집하는 모니터링 플랫폼이다. 이 가이드는 프로메테우스를 설치하는 방법부터 설정하는 방법, 그리고 프로메테우스를 통해 첫 번째 리소스를 모니터링하는 방법을 안내한다. 여기서는 프로메테우스를 다운받고, 설치하고, 실행해볼 거다. 또한 호스트와 서비스에 있는 시계열 데이터를 노출해주는 익스포터도 다운받아 설치하게 된다. 첫 번째로 다뤄볼 익스포터는 프로메테우스 자체로, 메모리 사용량이나 가비지 컬렉션 등에 방대한 호스트 레벨 메트릭을 제공한다.

### 목차

- [Downloading Prometheus](#downloading-prometheus)
- [Configuring Prometheus](#configuring-prometheus)
- [Starting Prometheus](#starting-prometheus)
- [Using the expression browser](#using-the-expression-browser)
- [Using the graphing interface](#using-the-graphing-interface)
- [Monitoring other targets](#monitoring-other-targets)
- [Summary](#summary)

---

## Downloading Prometheus

사용 중인 플랫폼에 맞는 프로메테우스의 [최신 릴리즈를 다운로드](https://prometheus.io/download)받고 다음 압축을 풀어라:

```bash
tar xvfz prometheus-*.tar.gz
cd prometheus-*
```

프로메테우스 서버는 `prometheus`(Microsoft Windows에선 `prometheus.exe`)라는 단일 바이너리 파일로 실행한다. 이 바이너리를 실행할 때 `--help` 플래그를 넘기면 옵션에 관한 도움말을 볼 수 있다.

```bash
./prometheus --help
usage: prometheus [<flags>]

The Prometheus monitoring server

. . .
```

프로메테우스를 시작하기 전에 먼저 설정을 완료해보자.

---

## Configuring Prometheus

프로메테우스는 [YAML](http://www.yaml.org/start.html) 파일로 설정한다. 프로메테우스를 다운받으면 처음 시작해보기 좋은 샘플 설정 파일 `prometheus.yml`이 함께 받아진다.

예제 파일에 있는 주석은 대부분 생략했다 (주석 라인은 앞에 `#`가 달려있다).

```yaml
global:
  scrape_interval:     15s
  evaluation_interval: 15s

rule_files:
  # - "first.rules"
  # - "second.rules"

scrape_configs:
  - job_name: prometheus
    static_configs:
      - targets: ['localhost:9090']
```

이 예제 파일에는 `global`, `rule_files`, `scrape_configs`, 이렇게 세 가지 설정 블록이 있다.

`global` 블록에는 프로메테우스 서버의 글로벌 설정을 지정한다. 여기엔 두 가지 옵션이 있다. 첫 번째 `scrape_interval`은 프로메테우스가 타겟을 스크랩할 간격을 나타낸다. 이 설정은 타겟마다 개별적으로 재정의할 수 있다. 여기서는 15초마다 스크랩하는 게 글로벌 설정이다. `evaluation_interval` 옵션으로는 프로메테우스가 rule을 평가할 주기를 지정한다. 프로메테우스는 rule을 사용해서 새 시계열을 만들고 alert를 생성한다.

`rule_files` 블록은 프로메테우스 서버가 로드할 rule의 위치를 지정한다. 현재는 rule이 없다.

마지막 블록 `scrape_configs`는 프로메테우스가 모니터링할 리소스를 지정한다. 프로메테우스는 자기 자신에 대한 데이터도 HTTP 엔드포인트로 노출하기 하기때문에, 자체 상태도 스크랩하고 모니터링할 수 있다. 이 디폴트 설정에는 프로메테우스 서버가 노출하는 시계열 데이터를 스크랩하는 `prometheus`라는 job 하나가 있다. 이 job은 정적으로 설정해둔 `localhost` `9090` 포트를 타겟으로 하나 가지고 있다. 프로메테우스는 타겟의 `/metrics` 경로에서 메트릭을 조회하려 한다. 따라서 이 디폴트 job은 http://localhost:9090/metrics URL을 통해 스크랩을 진행한다.

여기서 반환하는 시계열 데이터는 프로메테우스 서버의 상태와 성능에 관한 세부 정보를 담고 있다.

전체 설정 옵션 스펙은 [설정 문서](../configuration)를 참고해라.

---

## Starting Prometheus

새로 만든 설정 파일로 프로메테우스를 시작하려면, 프로메테우스 바이너리가 들어 있는 디렉토리로 이동해서 아래 명령어를 실행해라:

```bash
./prometheus --config.file=prometheus.yml
```

이제 프로메테우스가 시작될 거다. http://localhost:9090에서 프로메테우스 자체의 status 페이지를 둘러볼 수도 있다. 자체 HTTP 메트릭 엔드포인트에서 자신에 대한 데이터를 수집할 수 있도록 30초 정도를 기다려봐라.

자체 메트릭 엔드포인트(http://localhost:9090/metrics)로 접근해보면 프로메테우스가 자체 메트릭을 서빙하고 있는지도 확인할 수 있다.

---

## Using the expression browser

프로메테우스가 자체적으로 수집한 데이터를 한 번 살펴봐보자. 프로메테우스의 내장 expression 브라우저를 사용하려면 http://localhost:9090/graph로 이동해서 "Graph" 탭에 있는 "Table" 뷰를 클릭해라.

http://localhost:9090/metrics에서도 확인할 수 있듯이, 프로메테우스가 자체적으로 내보내는 메트릭에는 `promhttp_metric_handler_requests_total`(프로메테우스 서버가 `/metrics` 요청을 서빙한 횟수)이라는 메트릭이 있다. 계속해서 표현식 콘솔에 다음과 같이 입력해봐라:

```prometheus
promhttp_metric_handler_requests_total
```

이렇게 하면 `promhttp_metric_handler_requests_total`이란 이름을 가진 여러 가지 시계열이 반환될 건데, 레이블은 모두 다를 거다 (시계열 데이터마다 최신 기록 값을 가지고 있다). 이 레이블들은 각자 다른 요청 상태를 나타낸다.

HTTP 코드 `200`으로 떨어지는 요청에만 관심 있다면 아래 쿼리로 검색하면 된다:

```prometheus
promhttp_metric_handler_requests_total{code="200"}
```

반환된 시계열의 갯수는 다음과 같이 조회할 수 있다:

```prometheus
count(promhttp_metric_handler_requests_total)
```

표현식 언어에 대한 자세한 내용은 [표현식 언어 문서](../querying.basics)를 참고해라.

---

## Using the graphing interface

표현식을 그래프로 그려보려면 http://localhost:9090/graph로 이동해서 "Graph" 탭을 클릭해라.

예를 들어서 자체로 스크랩한 프로메테우스 지표에서, 상태 코드 200을 반환하는 HTTP 요청 수를 초 단위로 그려보려면 아래 표현식을 입력해라:

```prometheus
rate(promhttp_metric_handler_requests_total{code="200"}[1m])
```

그래프 range 파라미터나 다른 설정으로 여러 가지 실험을 해봐도 좋다.

---

## Monitoring other targets

프로메테우스로 메트릭을 수집해보는 것만으로는 프로메테우스가 가진 모든 기능을 다 알아봤다고 할 수 없다. 프로메테우스로 할 수 있는 일을 더 알아보려면 다른 익스포터 관련 문서를 살펴보는 게 좋다. 처음이라면 [노드 익스포터를 이용해 Linux/macOS 호스트 메트릭 모니터링하기](../guides.node-exporter) 가이드로 시작해보는 것도 좋다.

---

## Summary

이번 가이드에선 프로메테우스를 설치하고, 프로메테우스 인스턴스를 하나 설정해 리소스를 모니터링해보고, 프로메테우스의 expression 브라우저에서 시계열 데이터를 다뤄볼 수 있는 몇 가지 기본기를 익혀봤다. 계속해서 프로메테우스를 알아보려면 [Overview](../overview)에서 앞으로 살펴볼만한 내용을 찾아봐라.