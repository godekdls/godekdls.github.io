---
title: Sending Alerts
navTitle: Clients
category: Prometheus
order: 57
permalink: /Prometheus/alerting.clients/
description: Alertmanager v1/v2 api 가이드
image: ./../../images/prometheus/logo.png
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/alerting/0.23/clients/
parent: ALERTING
parentUrl: /Prometheus/alerting/
---

---

**유의 사항: 프로메테우스는 설정에 있는 [alerting rule](../alerting-rules)로 생성되는 alert들을 자동으로 전송해준다. 웬만하면 직접 클라이언트를 구현하기 보단, 프로메테우스에서 시계열 데이터를 기반으로 alerting rule을 설정하기를 적극 권장한다.**

Alertmanager에는 v1과 v2, 이렇게 두 가지의 API가 있으며, 둘 모두 alert를 수신한다. v1과 관련된 스킴은 아래 있는 코드에 잘 나와있다. v2의 스킴은 OpenAPI 스펙으로 지정하며, 이 스펙은 [Alertmanager 레포지토리](https://github.com/prometheus/alertmanager/blob/master/api/v2/openapi.yaml)에서 확인할 수 있다. 클라이언트는 alert가 계속해서 활성 상태라면 (보통은 대략 30초에서 3분 정도) 지속적으로 재전송해야 한다. 클라이언트는 POST 요청을 통해 Alertmanager에 alert 목록을 푸시할 수 있다.

동일한 alert 인스턴스들을 식별하고 중복을 제거할 땐 각 alert가 가지고 있는 레이블들을 이용한다. 애노테이션들은 항상 가장 최근에 수신한 값으로 설정하며, alert를 식별하는 데는 사용하지 않는다.

`startsAt`과 `endsAt` 타임스탬프는 모두 선택 사항이다. `startsAt`을 생략하면 Alertmanager가 현재 시간을 할당한다. `endsAt`는 alert의 종료 시간을 알고 있을 때만 설정한다. 생략하면 alert를 마지막으로 수신한 시간에 타임아웃만큼의 기간을 더해 설정하며, 이 타임아웃 값은 설정으로 수정할 수 있다.

`eneratorURL` 필드는 클라이언트에서 이 alert를 발생시킨 엔티티를 식별하는 고유 백링크다.

```js
[
  {
    "labels": {
      "alertname": "<requiredAlertName>",
      "<labelname>": "<labelvalue>",
      ...
    },
    "annotations": {
      "<labelname>": "<labelvalue>",
    },
    "startsAt": "<rfc3339>",
    "endsAt": "<rfc3339>",
    "generatorURL": "<generator_url>"
  },
  ...
]
```