---
title: Management API
category: Prometheus
order: 35
permalink: /Prometheus/management-api/
description: 프로메테우스 management API 가이드
image: ./../../images/prometheus/logo.png
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/prometheus/2.32/management_api
parent: PROMETHEUS
parentUrl: /Prometheus/prometheus/
---

---

프로메테우스는 자동화나 통합을 도와주는 management API 셋을 제공한다.

### 목차

- [Health check](#health-check)
- [Readiness check](#readiness-check)
- [Reload](#reload)
- [Quit](#quit)

---

## Health check

```
GET /-/healthy
```

이 엔드포인트는 항상 200을 반환하며, 프로메테우스의 상태를 체크하는 용도로 활용하면 된다.

---

## Readiness check

```
GET /-/ready
```

이 엔드포인트는 프로메테우스가 트래픽을 서빙할 준비가 되면 (즉, 쿼리에 응답할 준비가 되면) 200을 반환한다.

---

## Reload

```
PUT  /-/reload
POST /-/reload
```

이 엔드포인트는 프로메테우스 설정 파일과 rule 파일의 리로드를 트리거한다. 기본적으론 비활성화돼 있으며, `--web.enable-lifecycle` 플래그를 통해 활성화할 수 있다.

아니면 프로메테우스 프로세스에 `SIGHUP`을 보내도 설정 리로드를 트리거할 수 있다.

---

## Quit

```
PUT  /-/quit
POST /-/quit
```

이 엔드포인트는 프로메테우스의 graceful shutdown을 트리거한다. 기본적으론 비활성화돼 있으며, `--web.enable-lifecycle` 플래그를 통해 활성화할 수 있다.

아니면 프로메테우스 프로세스에 `SIGTERM`을 보내도 graceful shutdown을 트리거할 수 있다.
