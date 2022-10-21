---
title: Comparison to alternatives
category: Prometheus
order: 5
permalink: /Prometheus/comparison/
description: 프로메테우스와 다른 모니터링 시스템 비교
image: ./../../images/prometheus/logo.png
lastmod: 2022-01-05T21:30:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/introduction/comparison/
parent: INTRODUCTION
parentUrl: /Prometheus/introduction/
---

### 목차

- [Prometheus vs. Graphite](#prometheus-vs-graphite)
  + [Scope](#scope)
  + [Data model](#data-model)
  + [Storage](#storage)
  + [Summary](#summary)
- [Prometheus vs. InfluxDB](#prometheus-vs-influxdb)
  + [Scope](#scope-1)
  + [Data model / storage](#data-model--storage)
  + [Architecture](#architecture)
  + [Summary](#summary-1)
- [Prometheus vs. OpenTSDB](#prometheus-vs-opentsdb)
  + [Scope](#scope-2)
  + [Data model](#data-model-1)
  + [Storage](#storage-1)
  + [Summary](#summary-2)
- [Prometheus vs. Nagios](#prometheus-vs-nagios)
  + [Scope](#scope-3)
  + [Data model](#data-model-2)
  + [Storage](#storage-2)
  + [Architecture](#architecture-1)
  + [Summary](#summary-3)
- [Prometheus vs. Sensu](#prometheus-vs-sensu)
  + [Scope](#scope-4)
  + [Data model](#data-model-3)
  + [Storage](#storage-3)
  + [Architecture](#architecture-2)
  + [Summary](#summary-4)

---

## Prometheus vs. Graphite

### Scope

[Graphite](https://graphite.readthedocs.org/en/latest/)는 쿼리 언어와 그래프 기능을 갖춘 수동적인 시계열 데이터베이스에 초점을 두고 있다. 그외 다른 관심사는 모두 외부 컴포넌트들로 해결한다.

프로메테우스는 완전한 모니터링 시스템이자 트랜딩 시스템으로, 시계열 데이터를 기반으로 능동적으로 동작하는 스크랩, 저장, 질의, 그래프 추출, 알림 기능을 내장하고 있다. 모니터링 세상이 어떤 모습이어야 하는지를 알고 있으며 (어떤 엔드포인트가 존재해야 하는지, 시계열이 어떤 패턴을 보이면 문제라고 볼 수 있는지 등), 능동적으로 결함을 찾아낸다.

### Data model

Graphite는 프로메테우스와 매우 유사하게, 시계열 이름을 지정해 숫자 샘플들을 저장한다. 하지만 프로메테우스의 메타데이터 모델은 훨씬 더 풍부하다. Graphite의 메트릭명은 구성 요소들을 점으로 연결해서 암암리에 차원을 표현하지만, 프로메테우스는 메트릭에 첨부하는 레이블이란 키-값 쌍으로 차원을 분명하게 나타낸다. 덕분에 쿼리 언어에선 레이블을 이용해 손쉽게 데이터를 필터링하고, 그룹화하고, 매칭시킬 수 있다.

게다가 특히 Graphite를 [StatsD](https://github.com/etsy/statsd/)와 함께 사용할 때는 모니터링하는 모든 인스턴스들을 집계한 데이터만 저장하는 것이 일반적이다. 그렇기 때문에 인스턴스를 차원으로 보존해놓고 문제가 되는 인스턴스를 찾아가긴 어렵다.

예를 들어서, API 서버의 `/tracks` 엔드포인트에 전송한 `POST` 요청에서 `500`으로 응답한 HTTP 요청 수는, Graphite/StatsD에선 보통 다음과 같이 표현한다:

```
stats.api-server.tracks.post.500 -> 93
```

프로메테우스에선 같은 데이터를 다음과 같이 표현할 수 있다 (api-server 인스턴스는 3개라고 가정한다):

```prometheus
api_server_http_requests_total{method="POST",handler="/tracks",status="500",instance="<sample1>"} -> 34
api_server_http_requests_total{method="POST",handler="/tracks",status="500",instance="<sample2>"} -> 28
api_server_http_requests_total{method="POST",handler="/tracks",status="500",instance="<sample3>"} -> 31
```

### Storage

Graphite는 시계열 데이터를 로컬 디스크에 [Whisper](https://graphite.readthedocs.org/en/latest/whisper.html) 포맷으로 저장한다. Whisper는 RRD 스타일의 데이터베이스로, 정해진 간격으로 이곳에 샘플을 저장한다. 모든 시계열은 별도의 파일에 저장되며, 일정 시간이 지나면 새 샘플이 이전 샘플을 덮어쓴다.

프로메테우스도 시계열마다 로컬 파일을 하나씩 생성하지만, 임의의 간격으로 스크랩하거나 rule을 평가하면서 샘플을 저장할 수 있다. 새로운 샘플은 단순히 덧붙여지기 때문에, 오래된 데이터도 마음껏 길게 유지할 수 있다. 게다가 프로메테우스는 수명이 짧고 자주 변경되는 시계열 셋에서도 잘 동작한다.

### Summary

프로메테우스는 실행하기도 쉽고 각자의 환경에 더 쉽게 통합할 수 있을 뿐더러, 더 풍부한 데이터 모델과 쿼리 언어를 제공한다. 과거 데이터를 장기간 보관할 수 있는 클러스터형 솔루션을 원한다면 Graphite가 더 나을 수도 있다.

---

## Prometheus vs. InfluxDB

[InfluxDB](https://influxdata.com/)는 오픈 소스 시계열 데이터베이스로, 스케일링과 클러스터링에는 상용 옵션을 제공한다. InfluxDB 프로젝트는 프로메테우스 개발이 시작된 지 거의 1년 만에 출시했기 때문에, 당시에는 비교 대상으로 고려하지 못 했다. 그럼에도 프로메테우스와 InfluxDB에는 상당한 차이가 존재하며, 두 시스템은 약간씩 다른 유스 케이스에 맞춰져 있다.

### Scope

공정하게 비교하려면 InfluxDB는 [Kapacitor](https://github.com/influxdata/kapacitor)도 함께 고려해봐야 한다. 이 둘을 함께 조합하면 프로메테우스와 Alertmanager가 해주는 것과 같은 일을 처리할 수 있다.

지원 범위의 차이는 [Graphite](#prometheus-vs-graphite)에서 비교했던 내용이 InfluxDB에도 그대로 적용된다. InfluxDB는 추가로 프로메테우스의 recording rule에 상응하는 [continuous queries](https://docs.influxdata.com/influxdb/v1.8/query_language/continuous_queries/)를 제공한다.

Kapacitor의 역할은 프로메테우스의 recording rule, alerting rule, Alertmanager의 통보<sup>notification</sup> 기능의 조합이라고 볼 수 있다. 프로메테우스는 [그래프와 alert에 활용할 수 있는 좀 더 효과적인 쿼리 언어](https://www.robustperception.io/translating-between-monitoring-languages/)를 제공한다. 프로메테우스 Alertmanager는 그룹핑, 중복 제거, silencing 기능을 추가로 제공한다.

### Data model / storage

프로메테우스와 마찬가지로 InfluxDB의 데이터 모델에서도 키-값 쌍을 레이블로 사용하며, InfluxDB에선 태그라고 부른다. 그 외 InfluxDB는 필드라고 부르는 또 다른 수준의 레이블을 지원하는데, 필드는 사용이 좀 더 제한적이다. InfluxDB는 타임스탬프를 최대 나노초까지 지원하며, 그 외 데이터 타입은 float64, int64, bool, string을 지원한다. 그에 반해 프로메테우스는 데이터 타입으로 float64를 지원하며, 문자열과 밀리초 단위 타임스탬프도 제한적으로 지원하고 있다.

InfluxDB 스토리지는 [WAL<sup>write ahead log</sup>을 사용하는 LSMT<sup>log-structured merge tree</sup>](https://docs.influxdata.com/influxdb/v1.7/concepts/storage_engine/)를 약간 변형해서 사용하며, 시간 단위로 샤딩한다. 프로메테우스가 시계열 단위로 append-only 파일을 만드는 것에 비하면 이 구조는 이벤트 로깅에 훨씬 더 적합하다.

이벤트를 로깅하는 것과 메트릭을 기록하는 것의 차이는 [Logs and Metrics and Graphs, Oh My!](https://grafana.com/blog/2016/01/05/logs-and-metrics-and-graphs-oh-my/)에서 설명하고 있다.

### Architecture

프로메테우스 서버는 모두 독립적으로 실행되며, 스크랩, rule 처리, alert같은 핵심 기능에선 오로지 로컬 저장소에만 의존한다. InfluxDB 오픈 소스 버전도 비슷하다.

상용 InfluxDB 제품은 설계상으로 보면 스토리지와 쿼리를 동시에 많은 노드에서 처리하는 분산 스토리지 클러스터다.

따라서 수평적으로 확장하기는 상용 InfluxDB가 더 쉽다고 볼 수 있지만, 분산 스토리지 시스템의 복잡성을 처음부터 가지고 가야 한다는 뜻이기도 하다. 프로메테우스는 더 간단하게 실행할 수 있지만, 어느 시점에는 제품, 서비스, 데이터 센터나 이와 유사한 측면으로 확장할 바운더리를 결정하고 명시적으로 서버를 샤딩해야 한다. 안정성이나 실패 격리를 놓고 보면 서버들을 독립적으로 실행하는 게 더 좋을 수 있다 (병렬로 여러 벌 실행할 수 있다).

Kapacitor의 오픈 소스 릴리즈 버전엔 rule, alert, notification을 위한 분산/이중화 옵션이 들어있지 않다. 프로메테우스와 유사하게, 확장하려면 사용자가 수동으로 샤딩해야 한다. Influx는 alert 시스템의 HA/이중화를 지원하는 [Enterprise Kapacitor](https://docs.influxdata.com/enterprise_kapacitor)를 제공한다.

그에 반해 프로메테우스와 Alertmanager는 이중화 옵션을 완전한 오픈 소스로 제공한다. 프로메테우스는 레플리카를 여러 벌 실행할 수 있으며, Alertmanager에선 [High Availability](https://github.com/prometheus/alertmanager#high-availability) 모드를 이용할 수 있다.

### Summary

두 시스템은 유사한 점이 많다. 둘 모두 레이블(InfluxDB에선 태그라고 부른다)을 사용해 다차원 메트릭을 확실하게 지원한다. 이 둘은 데이터 압축에 기본적으로 동일한 알고리즘을 사용한다. 둘 모두 광범위한 통합을 지원하며, 이 둘을 통합하는 것도 가능하다. 둘 모두 통계 도구에서 데이터를 분석하거나 자동화된 작업을 수행하는 식으로 더 확장할 수 있다.

InfluxDB가 더 적합할 때:

- 이벤트 로그를 남기는 경우.
- InfluxDB 상용 옵션은 클러스터링을 제공하며, 데이터를 장기간 보관한다면 더 좋다.
- 레플리카 간의 데이터를 조회할 때 [eventually consistency](https://ko.wikipedia.org/wiki/%EA%B6%81%EA%B7%B9%EC%A0%81_%EC%9D%BC%EA%B4%80%EC%84%B1)를 보장한다.

프로메테우스가 더 적합할 때:

- 주로 메트릭을 다루는 경우.
- 좀 더 확실한 쿼리 언어와, 알림<sup>alert</sup>, 통보<sup>notification</sup> 기능.
- 그래프와 알림<sup>alert</sup>을 위한 더 뛰어난 가용성과 가동 시간.

InfluxDB는 영리 회사에서 단독으로 관리하고 있으며, 오픈 코어 모델에 따라 폐쇄형<sup>closed-source</sup> 클러스터링, 호스팅, 고객 지원과 같은 프리미엄 기능을 제공한다. 프로메테우스는 [완전한 오픈 소스이자 독립 프로젝트](https://prometheus.io/community/)로, 다양한 기업과 개인들이 관리하고 있으며, 그 중 일부는 상용 서비스와 기술 지원도 제공한다.

---

## Prometheus vs. OpenTSDB

[OpenTSDB](http://opentsdb.net/)는 [하둡](https://hadoop.apache.org/)과 [HBase](https://hbase.apache.org/)를 기반으로 동작하는 분산 시계열 데이터베이스다.

### Scope

지원 범위의 차이는 [Graphite](#prometheus-vs-graphite)에서 비교했던 내용이 여기서도 그대로 적용된다.

### Data model

OpenTSDB의 데이터 모델은 프로메테우스와 거의 동일하다. 시계열은 임의의 키-값 쌍 셋으로 식별한다 (OpenTSDB 태그는 프로메테우스의 레이블이라고 볼 수 있다). 특정 메트릭에 저장하는 데이터는 모두 [함께 저장](http://opentsdb.net/docs/build/html/user_guide/writing/index.html#time-series-cardinality)하기 때문에 메트릭의 카디널리티는 제한적일 수 밖에 없다. 하지만 약간의 차이는 있다. 프로메테우스에선 레이블에 임의의 문자를 사용할 수 있지만 OpenTSDB에선 좀 더 제한적이다. 게다가 OpenTSDB는 전체적인 쿼리 언어가 부족한데, API를 통한 간단한 집계와 수학 연산만 허용한다.

### Storage

[OpenTSDB](http://opentsdb.net/)의 스토리지에선 [하둡](https://hadoop.apache.org/)과 [HBase](https://hbase.apache.org/)를 사용한다. 따라서 OpenTSDB는 수평으로 확장하기는 쉽지만, Hadoop/HBase 클러스터를 운영하기 위해 필요한 전반적인 복잡성을 처음부터 짊어지고 가야 한다.

프로메테우스는 처음에는 더 간단하게 실행할 수 있지만, 단일 노드로 수용할 수 있는 범위를 넘어가면 명시적인 샤딩이 필요하다.

### Summary

프로메테우스는 훨씬 더 풍부한 쿼리 언어를 제공하고, 카디널리티가 더 높은 메트릭을 처리할 수 있으며, 완전한 모니터링 시스템을 구성할 수 있다. 이런 시스템보다는 장기 스토리지가 더 중요하고, 이미 하둡을 운영하고 있다면 OpenTSDB를 선택하는 게 더 나을 수 있다.

---

## Prometheus vs. Nagios

[Nagios](https://www.nagios.org/)는 1990년대에 NetSaint란 이름으로 시작했던 모니터링 시스템이다.

### Scope

Nagios는 주로 스크립트의 종료 코드를 기반으로 alert를 생성하는 것에 집중한다. 이를 "체크"라고 부른다. alert는 개별적으로 silencing 처리를 할 수 있지만, 그룹핑이나, 라우팅, 중복 제거는 지원하지 않는다.

지원하는 플러그인은 매우 다양하다. 예를 들어, 플러그인을 연결하면 수 킬로바이트의 perfData를 [Graphite같은 시계열 데이터베이스로](https://github.com/shawn-sterling/graphios) 전송할 수 있으며, NRPE를 사용하면 [체크를 원격 시스템에서도 실행](https://exchange.nagios.org/directory/Addons/Monitoring-Agents/NRPE--2D-Nagios-Remote-Plugin-Executor/details)할 수 있다.

### Data model

Nagios는 호스트 기반 시스템이다. 각 호스트는 서비스를 하나 이상 가질 수 있으며, 서비스마다 체크를 하나 수행할 수 있다.

레이블이나 쿼리 언어같은 개념은 따로 없다.

### Storage

본래 Nagios는 현재 체크 상태를 넘어서는 데이터를 저장하는 스토리지는 없다. [시각화용 데이터](https://docs.pnp4nagios.org/) 등을 저장할 때는 플러그인을 사용한다.

### Architecture

Nagios 서버는 독립 실행형 서버다. 모든 체크 설정은 파일을 통해 이루어진다.

### Summary

Nagios는 블랙박스 프로빙으로도 충분한 소규모 시스템이나 정적인 시스템에 기초적인 모니터링을 적용할 때 적합하다.

화이트박스 모니터링을 원하거나, 동적인 시스템이나 클라우드 기반 환경을 운영하고 있다면, 프로메테우스를 선택하는 게 더 좋다.

---

## Prometheus vs. Sensu

[Sensu](https://sensu.io/)는 오픈 소스 모니터링 시스템이자 observability 파이프라인으로, 별도로 확장을 위한 기능을 제공하는 상용 버전도 배포하고 있다. Sensu에선 기존 Nagios 플러그인을 재사용할 수 있다.

### Scope

Sensu는 [이벤트](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-events/events/) 스트림으로 observability 데이터를 처리해 alert를 발생시키는 것에 초점을 두고 있는 observability 파이프라인이다. 확장 가능한 프레임워크를 이용해 이벤트를 [필터링](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-filter/), 집계, [변환](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-transform/), [처리](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-process/)할 수 있다. 다른 시스템에 alert를 전송거나 써드 파티 시스템에 이벤트를 저장하는 것도 가능하다. Sensu에서 이벤트를 처리하는 일은 프로메테우스의 alerting rule과 Alertmanager로 처리하는 일과 범위가 비슷하다.

### Data model

Sensu [이벤트](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-events/events/)에선 서비스 상태와 [메트릭](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-events/events/#metric-attributes)을 정형화된 데이터 형식을 통해 표현한다. 이 데이터는 [엔티티](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-entities/entities/) 이름과 (ex. 서버, 클라우드 컴퓨팅 인스턴스, 컨테이너, 서비스), 이벤트 이름, 그리고 "레이블" 또는 "어노테이션"이라고 부르는 생략 가능한 [키-값 메타데이터](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-events/events/#metadata-attributes)로 식별한다. Sensu 이벤트 페이로드는 메트릭 [`point`](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-events/events/#points-attributes)를 하나 이상 가지고 있을 수 있는데, `point`는 `name`, `tags` (키/값 쌍), `timestamp`, `value`(항상 float)를 가지고 있는 JSON 객체로 표현한다.

### Storage

Sensu는 이벤트의 현재/최신 상태 정보와 실시간 인벤토리 데이터를 임베디드 데이터베이스(etcd)나 외부 RDBMS(PostgreSQL)에 저장한다.

### Architecture

Sensu 배포에서 필요한 모든 구성 요소는 클러스터링을 통해 가용성과 이벤트 처리량을 향상시킬 수 있다.

### Summary

Sensu와 프로메테우스는 공통점도 몇 가지 있지만, 모니터링에는 매우 다르게 접근한다. 둘 모두 동적인 클라우드 환경과 ephemeral 컴퓨팅 플랫폼을 위한 확장 가능한 디스커버리 메커니즘을 제공하지만, 내부 메커니즘은 상당히 다르다. 둘 모두 레이블과 어노테이션을 통해 다차원 메트릭 수집을 지원한다. 둘 모두 광범위한 통합을 지원하며, Sensu는 기본적으로 모든 프로메테우스 익스포터에서 메트릭을 수집할 수 있다. 둘 다 써드 파티 데이터 플랫폼(ex. 이벤트 스토리지나 TSDB)에 observability 데이터를 포워딩할 수 있다. Sensu와 프로메테우스가 가장 갈리는 지점은 유스 케이스다.

Sensu가 더 적합할 때:

- 하이브리드 observability 데이터(메트릭 *및 또는* 이벤트를 포함하는)를 수집하고 처리하는 경우
- 여러 가지 모니터링 툴을 통합하고, Nagios 스타일 플러그인이나 체크 스크립트와 메트릭 지원이 *함께* 필요한 경우
- 좀 더 확실한 이벤트 처리 플랫폼

프로메테우스가 더 적합할 때:

- 주로 메트릭을 수집하고 평가하는 경우
- 동일한 쿠버네티스 인프라를 모니터링하는 경우 (모니터링하는 워크로드가 100% 다 K8s에 있다면, 프로메테우스가 K8s 통합을 더 잘 지원한다)
- 좀 더 확실한 쿼리 언어와, 히스토리성 데이터 분석 내장 지원

Sensu는 영리 회사에서 단독으로 관리하고 있으며, 오픈 코어 모델에 따라 폐쇄형<sup>closed-source</sup> 이벤트 correlation, aggregation, federation, 고객 지원과 같은 프리미엄 기능을 제공한다. 프로메테우스는 완전한 오픈 소스이자 독립 프로젝트로, 다양한 기업과 개인들이 관리하고 있으며, 그 중 일부는 상용 서비스와 기술 지원도 제공한다.