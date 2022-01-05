---
title: Integrations
category: Prometheus
order: 52
permalink: /Prometheus/integrations/
description: 프로메테우스 통합 포인트 정리
image: ./../../images/prometheus/logo.png
lastmod: 2022-01-05T21:30:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/operating/integrations/
parent: OPERATING
parentUrl: /Prometheus/operating/
---

---

[클라이언트 라이브러리](../clientlibs), [익스포터와 관련 라이브러리](../exporters) 외에도 프로메테우스에는 범용적인 통합 포인트가 아주 다양하다. 이 페이지엔 다양한 통합 포인트들을 몇 가지 정리해뒀다.

기능이 중복되거나 아직 개발 중인 것도 있기 때문에 여기에서 나열하지 않은 통합 기능이 있을 수도 있다. 위키 페이지 [익스포터 디폴트 포트](https://github.com/prometheus/prometheus/wiki/Default-port-allocations)에는 같은 카테고리로 나눌 수 있는 익스포터 외 다른 통합 기능들도 몇 개 포함돼있다.

### 목차

- [File Service Discovery](#file-service-discovery)
- [Remote Endpoints and Storage](#remote-endpoints-and-storage)
- [Alertmanager Webhook Receiver](#alertmanager-webhook-receiver)
- [Management](#management)
- [Other](#other)

---

## File Service Discovery

프로메테우스에서 기본으로 지원하지 않는 서비스 디스커버리 메커니즘의 경우, [파일 기반 서비스 디스커버리](../configuration#file_sd_config)가 통합을 위한 인터페이스를 제공해준다.

- [Kuma](https://github.com/kumahq/kuma/tree/master/app/kuma-prometheus-sd)
- [Lightsail](https://github.com/n888/prometheus-lightsail-sd)
- [Netbox](https://github.com/FlxPeters/netbox-prometheus-sd)
- [Packet](https://github.com/packethost/prometheus-packet-sd)
- [Scaleway](https://github.com/scaleway/prometheus-scw-sd)

---

## Remote Endpoints and Storage

프로메테우스의 [remote write](../configuration#remote_write), [remote read](../configuration#remote_read) 기능을 사용하면 샘플을 투명하게 주고 받을 수 있다. 이 기능은 일차적으로 장기 스토리지를 위한 기능이다. 여기서 사용할 솔루션은 신중하게 평가해보고 예상하는 데이터 볼륨을 처리할 수 있는지를 확인해보는 게 좋다.

- [AppOptics](https://github.com/solarwinds/prometheus2appoptics): write
- [AWS Timestream](https://github.com/dpattmann/prometheus-timestream-adapter): read and write
- [Azure Data Explorer](https://github.com/cosh/PrometheusToAdx): read and write
- [Azure Event Hubs](https://github.com/bryanklewis/prometheus-eventhubs-adapter): write
- [Chronix](https://github.com/ChronixDB/chronix.ingester): write
- [Cortex](https://github.com/cortexproject/cortex): read and write
- [CrateDB](https://github.com/crate/crate_adapter): read and write
- [Elasticsearch](https://www.elastic.co/guide/en/beats/metricbeat/master/metricbeat-metricset-prometheus-remote_write.html): write
- [Gnocchi](https://gnocchi.xyz/prometheus.html): write
- [Google BigQuery](https://github.com/KohlsTechnology/prometheus_bigquery_remote_storage_adapter): read and write
- [Google Cloud Spanner](https://github.com/google/truestreet): read and write
- [Graphite](https://github.com/prometheus/prometheus/tree/main/documentation/examples/remote_storage/remote_storage_adapter): write
- [InfluxDB](https://docs.influxdata.com/influxdb/v1.8/supported_protocols/prometheus): read and write
- [Instana](https://www.instana.com/docs/ecosystem/prometheus/#remote-write): write
- [IRONdb](https://github.com/circonus-labs/irondb-prometheus-adapter): read and write
- [Kafka](https://github.com/Telefonica/prometheus-kafka-adapter): write
- [M3DB](https://m3db.io/docs/integrations/prometheus/): read and write
- [New Relic](https://docs.newrelic.com/docs/set-or-remove-your-prometheus-remote-write-integration): write
- [OpenTSDB](https://github.com/prometheus/prometheus/tree/main/documentation/examples/remote_storage/remote_storage_adapter): write
- [PostgreSQL/TimescaleDB](https://github.com/timescale/promscale): read and write
- [QuasarDB](https://doc.quasardb.net/master/user-guide/integration/prometheus.html): read and write
- [SignalFx](https://github.com/signalfx/metricproxy#prometheus): write
- [Splunk](https://github.com/kebe7jun/ropee): read and write
- [Sysdig Monitor](https://docs.sysdig.com/en/docs/installation/prometheus-remote-write/): write
- [TiKV](https://github.com/bragfoo/TiPrometheus): read and write
- [Thanos](https://github.com/thanos-io/thanos): read and write
- [VictoriaMetrics](https://github.com/VictoriaMetrics/VictoriaMetrics): write
- [Wavefront](https://github.com/wavefrontHQ/prometheus-storage-adapter): write

[Prom-migrator](https://github.com/timescale/promscale/tree/master/cmd/prom-migrator)는 원격 스토리지 시스템 간의 데이터를 마이그레이션해주는 툴이다.

---

## Alertmanager Webhook Receiver

Alertmanager에서 기본으로 지원하지 않는 통보<sup>notification</sup> 메커니즘의 경우, [webhook receiver](../alerting.configuration#webhook_config)가 통합을 도와준다.

- [alertmanager-webhook-logger](https://github.com/tomtom-international/alertmanager-webhook-logger): alert를 로그로 남긴다
- [Alertsnitch](https://gitlab.com/yakshaving.art/alertsnitch): alert를 MySQL 데이터베이스에 저장한다
- [Asana](https://gitlab.com/lupudu/alertmanager-asana-bridge)
- [AWS SNS](https://github.com/DataReply/alertmanager-sns-forwarder)
- [Better Uptime](https://docs.betteruptime.com/integrations/prometheus)
- [Canopsis](https://git.canopsis.net/canopsis-connectors/connector-prometheus2canopsis)
- [DingTalk](https://github.com/timonwong/prometheus-webhook-dingtalk)
- [Discord](https://github.com/benjojo/alertmanager-discord)
- [GitLab](https://docs.gitlab.com/ee/operations/metrics/alerts.html#external-prometheus-instances)
- [Gotify](https://github.com/DRuggeri/alertmanager_gotify_bridge)
- [GELF](https://github.com/b-com-software-basis/alertmanager2gelf)
- [Icinga2](https://github.com/vshn/signalilo)
- [iLert](https://docs.ilert.com/integrations/prometheus)
- [IRC Bot](https://github.com/multimfi/bot)
- [JIRAlert](https://github.com/free/jiralert)
- [Matrix](https://github.com/matrix-org/go-neb)
- [Phabricator / Maniphest](https://github.com/knyar/phalerts)
- [prom2teams](https://github.com/idealista/prom2teams): 통보<sup>notification</sup>를 Microsoft Team으로 포워딩한다
- [Rocket.Chat](https://rocket.chat/docs/administrator-guides/integrations/prometheus/)
- [ServiceNow](https://github.com/FXinnovation/alertmanager-webhook-servicenow)
- [Signal](https://github.com/dgl/alertmanager-webhook-signald)
- [SIGNL4](https://www.signl4.com/blog/portfolio_item/prometheus-alertmanager-mobile-alert-notification-duty-schedule-escalation)
- [SMS](https://github.com/messagebird/sachet): [멀티 provider](https://github.com/messagebird/sachet/blob/master/examples/config.yaml)를 지원한다
- [SNMP traps](https://github.com/maxwo/snmp_notifier)
- [Squadcast](https://support.squadcast.com/docs/prometheus)
- [Telegram bot](https://github.com/inCaller/prometheus_bot)
- [xMatters](https://github.com/xmatters/xm-labs-prometheus)
- [XMPP Bot](https://github.com/jelmer/prometheus-xmpp-alerts)
- [Zenduty](https://docs.zenduty.com/docs/prometheus/)
- [Zoom](https://github.com/Code2Life/nodess-apps/tree/master/src/zoom-alert-2.0)

---

## Management

프로메테우스는 management 기능에 관한 설정이 들어있지 않으므로, 기존 시스템과 통합하거나 그 위에 구축하는 식으로 활용하면 된다.

- [Prometheus Operator](https://github.com/coreos/prometheus-operator): 쿠버네티스 환경에서 프로메테우스를 관리한다
- [Promgen](https://github.com/line/promgen): 프로메테우스, Alertmanager를 위한 웹 UI와 설정 generator

---

## Other

- [karma](https://github.com/prymitive/karma): alert 대시보드
- [PushProx](https://github.com/RobustPerception/PushProx): NAT나 유사한 네트워크 세팅을 가로지르는 프록시
- [Promdump](https://github.com/ihcsim/promdump): 데이터 블록의 덤프를 만들고 복원할 수 있는 kubectl 플러그인
- [Promregator](https://github.com/promregator/promregator): Cloud Foundry 애플리케이션을 위한 디스커버리와 스크래핑
- [pint](https://github.com/cloudflare/pint): 프로메테우스 rule linter
