---
title: Roadmap
category: Prometheus
order: 7
permalink: /Prometheus/roadmap/
description: 프로메테우스에서 머지 않아 구현할 예정인 주요 기능들 소개
image: ./../../images/prometheus/logo.png
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/introduction/roadmap/
parent: INTRODUCTION
parentUrl: /Prometheus/introduction/
---

---

아래에서 설명하는 내용은 머지않아 구현할 주요 기능 중 일부만 선정해 놓은 거다. 계획 중인 기능이나 현재 진척 중인 작업들은 각 레포지토리의 이슈 트래커에서 전체적인 개요를 확인할 수 있다 (ex. [프로메테우스 서버](https://github.com/prometheus/prometheus/issues)).

### 목차

- [Server-side metric metadata support](#server-side-metric-metadata-support)
- [Adopt OpenMetrics](#adopt-openmetrics)
- [Retroactive rule evaluations](#retroactive-rule-evaluations)
- [TLS and authentication in HTTP serving endpoints](#tls-and-authentication-in-http-serving-endpoints)
- [Support the Ecosystem](#support-the-ecosystem)

---

## Server-side metric metadata support

현재로썬 메트릭 타입과 다른 메타데이터는 클라이언트 라이브러리와 exposition 형식에서만 사용하고 있으며, 프로메테우스 서버에선 별도로 보관하거나 활용하지 않고 있다. 앞으로는 이 메타데이터를 사용할 계획이다. 첫 단추로는 이 데이터를 프로메테우스 메모리 내에서 집계하고, 실험적인 API 엔드포인트를 통해 제공할 생각이다.

---

## Adopt OpenMetrics

OpenMetrics 실무진들은 메트릭 exposition을 위한 새로운 표준을 개발 중에 있다. 이 포맷은 클라이언트 라이브러리와 프로메테우스 자체에서 지원할 계획이다.

---

## Retroactive rule evaluations

backfill을 이용해 rule을 소급 평가할 수 있는 기능을 추가할 예정이다.

---

## TLS and authentication in HTTP serving endpoints

TLS와 인증은 현재 프로메테우스, Alertmanager, 공식 익스포터에서 배포 중이다. 이 기능을 추가하게 되면 외부 TLS와 인증을 위한 reverse 프록시 없이도 더 쉽게 프로메테우스 컴포넌트들을 안전하게 배포할 수 있다.

---

## Support the Ecosystem

프로메테우스에는 다양한 클라이언트 라이브러리와 익스포터가 존재한다. 앞으로 지원할 수 있는 언어나, 메트릭을 익스포터하는 데 활용할만한 시스템은 항상 더 존재한다. 더 많은 라이브러리와 시스템을 만들고 확장하면서 에코시스템을 지원할 예정이다.