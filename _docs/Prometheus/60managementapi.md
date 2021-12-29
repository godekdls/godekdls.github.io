---
title: Alertmanager Management API
navTitle: Management API
category: Prometheus
order: 60
permalink: /Prometheus/alerting.management-api/
description: Alertmanager management API 가이드
image: ./../../images/prometheus/logo.png
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/alerting/0.23/management_api/
parent: ALERTING
parentUrl: /Prometheus/alerting/
priority: 0.3
---

---

Alertmanager는 자동화나 통합을 도와주는 management API 셋을 제공한다.

### 목차

- [Health check](#health-check)
- [Readiness check](#readiness-check)
- [Reload](#reload)

---

## Health check

```
GET /-/healthy
```

이 엔드포인트는 항상 200을 반환하며, Alertmanager의 상태를 체크하는 용도로 활용하면 된다.

---

## Readiness check

```
GET /-/ready
```

이 엔드포인트는 Alertmanager가 트래픽을 서빙할 준비가 되면 (즉, 쿼리에 응답할 준비가 되면) 200을 반환한다.

---

## Reload

```
POST /-/reload
```

이 엔드포인트는 Alertmanager 설정 파일의 리로드를 트리거한다.

아니면 Alertmanager 프로세스에 `SIGHUP`을 보내도 설정 리로드를 트리거할 수 있다.