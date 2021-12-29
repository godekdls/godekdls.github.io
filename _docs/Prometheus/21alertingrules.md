---
title: Alerting rules
category: Prometheus
order: 21
permalink: /Prometheus/alerting-rules/
description: 프로메테우스 alerting rule 설정 가이드
image: ./../../images/prometheus/logo.png
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/prometheus/2.32/configuration/alerting_rules/
parent: PROMETHEUS
parentUrl: /Prometheus/prometheus/
subparent: Configuration
subparentUrl: /Prometheus/config/
---

### 목차

- [Defining alerting rules](#defining-alerting-rules)
  * [Templating](#templating)
- [Inspecting alerts during runtime](#inspecting-alerts-during-runtime)
- [Sending alert notifications](#sending-alert-notifications)

---

Alerting rule을 사용하면 프로메테우스 표현식 언어를 기반으로 alert 조건을 정의하고, alert가 시행<sup>fire</sup>되면 외부 서비스에 통지<sup>notification</sup>할 수 있다. 특정 시점에 alert 표현식이 벡터 요소를 하나 이상 생성하게 되면, 이 alert는 해당 요소가 가지고 있는 레이블 셋에 대해서 활성 상태로 판단된다.

---

## Defining alerting rules

프로메테우스에 alerting rule을 설정하는 방법은 [recording rule](../recording-rules)을 설정할 때와 동일하다.

alert를 사용하는 rule 파일 예시는 다음과 같다:

```yaml
groups:
- name: example
  rules:
  - alert: HighRequestLatency
    expr: job:request_latency_seconds:mean5m{job="myjob"} > 0.5
    for: 10m
    labels:
      severity: page
    annotations:
      summary: High request latency
```

옵션으로 `for` 절을 지정하면, 프로메테우스는 이 표현식으로 만들어지는 출력 벡터 요소를 처음 발견하고 나서부터, 지정 기간이 지난 뒤에야 해당 alert를 시행<sup>fire</sup>된 것으로 계산한다. 이 예제에선 매 평가마다 10분 동안 alert가 활성<sup>active</sup> 상태로 지속되는지 확인해본 후 alert를 시행<sup>fire</sup>시킨다. 활성 상태이지만 아직 시행<sup>fire</sup>되지 않은 요소들은 보류<sup>pending</sup> 상태로 본다.

`labels` 절로는 alert에 첨부할 별도 레이블 셋을 지정할 수 있다. 기존 레이블과 충돌되는 게 있다면 모두 덮어쓴다. 레이블 값은 템플릿을 사용해 지정할 수 있다.

`annotations` 절은 alert 설명이나 런북<sup>runbook</sup> 링크같이, 좀더 긴 부가 정보를 저장할 수 있는 정보성 레이블 셋을 지정한다. 애노테이션 값은 템플릿을 사용해 지정할 수 있다.

### Templating

레이블과 애노테이션 값은 [콘솔 템플릿](../console-templates)을 이용해 템플릿화할 수 있다. `$labels` 변수는 alert 인스턴스의 레이블 키/값 쌍으로 고정돼 있다. 설정해둔 외부 레이블은 `$externalLabels` 변수를 통해 접근할 수 있다. `$value` 변수는 alert 인스턴스의 평가 값을 가지고 있다.

```prometheus
# 시행 중인 요소의 레이블 값을 삽입하려면:
{% raw %}{{ $labels.<labelname> }}{% endraw %}
# 시행 중인 요소의 표현식 결과값(숫자)을 삽입하려면:
{% raw %}{{ $value }}{% endraw %}
```

예제:

```yaml
groups:
- name: example
  rules:

  # 5분 이상 연결되지 않는 인스턴스를 잡아내는 alert.
  - alert: InstanceDown
    expr: up == 0
    for: 5m
    labels:
      severity: page
    annotations:
      summary: "Instance {% raw %}{{ $labels.instance }}{% endraw %} down"
      description: "{% raw %}{{ $labels.instance }}{% endraw %} of job {% raw %}{{ $labels.job }}{% endraw %} has been down for more than 5 minutes."

  # 요청 지연 시간 중앙값(median)이 1초를 넘는 인스턴스를 잡아내는 alert.
  - alert: APIHighRequestLatency
    expr: api_http_request_latencies_second{quantile="0.5"} > 1
    for: 10m
    annotations:
      summary: "High request latency on {% raw %}{{ $labels.instance }}{% endraw %}"
      description: "{% raw %}{{ $labels.instance }}{% endraw %} has a median request latency above 1s (current value: {% raw %}{{ $value }}{% endraw %}s)"
```

---

## Inspecting alerts during runtime

어떤 alert가 활성 상태인지 (보류<sup>pending</sup> 또는 시행<sup>firing</sup> 상태) 직접 확인하고 싶다면, 프로메테우스 인스턴스에서 "Alerts" 탭으로 이동하면 된다. 이 화면에선 정의된 alert 중에서 현재 활성화돼있는 alert의 정확한 레이블 셋을 확인할 수 있다.

프로메테우스는 보류<sup>pending</sup>나 시행<sup>firing</sup> 중인 alert가 있다면 `ALERTS{alertname="<alert name>", alertstate="<pending or firing>", <additional alert labels>}` 형식으로 별도 시계열을 저장한다. alert가 활성 상태에 있다면 (보류<sup>pending</sup> 또는 시행<sup>firing</sup>) 해당 샘플 값은 `1`로 설정하며, 더 이상 활성 상태가 아니면 stale로 마킹한다.

---

## Sending alert notifications

프로메테우스의 alerting rule은 *지금 당장* 무엇이 고장났는지 파악하기는 좋지만, 완전한 통보<sup>notification</sup> 솔루션이라곤 할 수 없다. 간단한 alert 정의 위에 요약, 통보<sup>notification</sup> 속도 제한, silencing, alert 의존성을 추가하려면 다른 계층이 하나 더 필요하다. 프로메테우스 생태계에서는 [Alertmanager](../alertmanager)가 이 역할을 담당한다. 따라서 프로메테우스는 alert 상태에 대한 정보를 주기적으로 Alertmanager 인스턴스로 보내도록 구성할 수 있으며, 그러면 Alertmanager 인스턴스가 이어서 제대로 된 통지<sup>notification</sup>를 발송한다.<br>프로메테우스는 서비스 디스커버리 통합 기능을 이용해 가능한 Alertmanager 인스턴스를 자동으로 발견하도록 [설정](../configuration)할 수 있다.
