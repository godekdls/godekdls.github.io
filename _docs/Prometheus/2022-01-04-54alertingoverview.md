---
title: Alerting overview
category: Prometheus
order: 54
permalink: /Prometheus/alerting.overview/
description: 프로메테우스의 알림 시스템 소개
image: ./../../images/prometheus/logo.png
lastmod: 2022-01-05T21:30:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/alerting/0.23/overview/
parent: ALERTING
parentUrl: /Prometheus/alerting/
---

---

프로메테우스에서 알림은 두 파트로 나뉜다. 먼저, 프로메테우스 서버에 설정한 alerting rule들이 Alertmanager로 alert를 전송한다. 그러면 이 alert들은 [Alertmanager](../alertmanager)가 관리해주는데, 여기서는 silencing, inhibition을 처리하며, alert들을 집계하고, 이메일, on-call 통보<sup>notification</sup> 시스템, 채팅 플랫폼 등을 통해 통보해준다<sup>notification</sup>.

alert와 notification을 설정할 때 거치는 주요 단계는 다음과 같다:

- Alertmanager를 세팅하고 [설정](../alerting.configuration) 파일을 작성한다
- Alertmanager와 통신할 수 있도록 [프로메테우스에 설정](../configuration#alertmanager_config)을 추가한다
- 프로메테우스에서 [alerting rule](../alerting-rules)을 생성한다