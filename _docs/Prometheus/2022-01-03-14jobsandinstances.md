---
title: Jobs and instances
category: Prometheus
order: 14
permalink: /Prometheus/jobs-instances/
description: job, instance 용어 설명
image: ./../../images/prometheus/logo.png
lastmod: 2022-01-05T21:30:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/concepts/jobs_instances/
parent: CONCEPTS
parentUrl: /Prometheus/concepts/
---

---

프로메테우스 용어에선, 스크랩할 수 있는 엔드포인트를 *인스턴스*라고 말하며, 보통 인스턴스는 단일 프로세스를 나타낸다. 확장성이나 안정성을 위해 복제한 프로세스같이, 같은 목적을 가진 인스턴스 모음은 *job*이라고 한다.

복제된 인스턴스 4개를 가지고 있는 API 서버 job으로 예를 들면:

- job: `api-server`

  - instance 1: `1.2.3.4:5670`
  - instance 2: `1.2.3.4:5671`
  - instance 3: `5.6.7.8:5670`
  - instance 4: `5.6.7.8:5671`

---

## Automatically generated labels and time series

프로메테우스가 타겟을 스크랩할 땐, 타겟을 식별할 수 있도록 스크랩한 시계열 데이터에 몇 가지 레이블들을 자동으로 덧붙인다:

- `job`: 이 타겟이 속해있는 job 이름으로 설정해둔 값.
- `instance`: 스크랩한 타겟의 URL에서 추린 `<host>:<port>`.

스크랩한 데이터가 이 레이블 중 하나라도 이미 가지고 있었을 때는, 설정 옵션 `honor_labels`에 따라 동작이 달라진다. 자세한 내용은 [스크랩 설정 문서](../configuration#scrape_config)를 참고해라.

프로메테우스는 각 인스턴스를 스크랩하면서 다음과 같은 시계열에 [샘플](../glossary#sample)을 하나씩 저장한다:

- `up{job="<job-name>", instance="<instance-id>"}`: 인스턴스가 정상일 땐 (요청 시 응답을 준다면) `1`, 스크랩에 실패하면 `0`.
- `scrape_duration_seconds{job="<job-name>", instance="<instance-id>"}`: 스크랩 지속 기간.
- `scrape_samples_post_metric_relabeling{job="<job-name>", instance="<instance-id>"}`: 메트릭 relabeling을 적용한 이후에 남아있는 샘플 수.
- `scrape_samples_scraped{job="<job-name>", instance="<instance-id>"}`: 이 타겟이 노출한 샘플 수.
- `scrape_series_added{job="<job-name>", instance="<instance-id>"}`: 이 인스턴스를 스크랩하면서 새로 추가한 대략적인 시계열 갯수. *v2.10에서 새로 추가됐다.*

시계열 데이터 `up`은 인스턴스 가용성을 모니터링할 때 유용하다.