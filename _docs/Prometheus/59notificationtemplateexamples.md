---
title: Notification template examples
category: Prometheus
order: 59
permalink: /Prometheus/notifications-examples/
description: notification 템플릿 예제
image: ./../../images/prometheus/logo.png
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/alerting/0.23/notification_examples/
parent: ALERTING
parentUrl: /Prometheus/alerting/
---

---

여기서는 각기 다른 alert와 Alertmanager 설정 파일(alertmanager.yml) 예제를 다룬다. 모든 예제는 [Go 템플릿](https://golang.org/pkg/text/template/) 시스템을 사용한다.

### 목차

- [Customizing Slack notifications](#customizing-slack-notifications)
- [Accessing annotations in CommonAnnotations](#accessing-annotations-in-commonannotations)
- [Ranging over all received Alerts](#ranging-over-all-received-alerts)
- [Defining reusable templates](#defining-reusable-templates)

---

## Customizing Slack notifications

이 예제에선 전달받은 alert를 처리하는 방법이 나와있는 조직 내 위키를 가리키는 URL을 전송하도록 Slack notification을 커스텀했다.

```yaml
global:
  # 이 URL을 파일에 넣는 것도 가능하다.
  # Ex: `slack_api_url_file: '/etc/alertmanager/slack_url'`
  slack_api_url: '<slack_webhook_url>'

route:
  receiver: 'slack-notifications'
  group_by: [alertname, datacenter, app]

receivers:
- name: 'slack-notifications'
  slack_configs:
  - channel: '#alerts'
    text: 'https://internal.myorg.net/wiki/alerts/{% raw %}{{ .GroupLabels.app }}{% endraw %}/{% raw %}{{ .GroupLabels.alertname }}{% endraw %}'
```

---

## Accessing annotations in CommonAnnotations

이 예제에선 Alertmanager가 전송하는 데이터의 `CommonAnnotations`에 저장돼 있는 `summary`와 `description`을 이용해 Slack receiver로 전송할 텍스트를 또 한번 커스텀한다.

Alert

```yaml
groups:
- name: Instances
  rules:
  - alert: InstanceDown
    expr: up == 0
    for: 5m
    labels:
      severity: page
    # 여기서는 alert의 애노테이션과 레이블 필드에 프로메테우스 템플릿을 적용한다.
    annotations:
      description: '{% raw %}{{ $labels.instance }}{% endraw %} of job {% raw %}{{ $labels.job }}{% endraw %} has been down for more than 5 minutes.'
      summary: 'Instance {% raw %}{{ $labels.instance }}{% endraw %} down'
```

Receiver

```yaml
- name: 'team-x'
  slack_configs:
  - channel: '#alerts'
    # 여기서는 Alertmanager 템플릿을 적용한다.
    text: "<!channel> \nsummary: {% raw %}{{ .CommonAnnotations.summary }}{% endraw %}\ndescription: {% raw %}{{ .CommonAnnotations.description }}{% endraw %}"
```

---

## Ranging over all received Alerts

마지막으로, 이전 예제와 같은 alert를 가정하고, Alertmanager에서 수신한 전체 alert를 범위로 지정해서 각각의 애노테이션 summary와 description을 새로운 라인에 출력하도록 receiver를 커스텀한다.

Receiver

```yaml
- name: 'default-receiver'
  slack_configs:
  - channel: '#alerts'
    title: "{% raw %}{{ range .Alerts }}{% endraw %}{% raw %}{{ .Annotations.summary }}{% endraw %}\n{% raw %}{{ end }}{% endraw %}"
    text: "{% raw %}{{ range .Alerts }}{% endraw %}{% raw %}{{ .Annotations.description }}{% endraw %}\n{% raw %}{{ end }}{% endraw %}"
```

---

## Defining reusable templates

첫 번째 예제로 돌아가서, 여러 줄에 걸쳐 있는 복잡한 템플릿을 사용하는 대신, 전용 이름과 함께 템플릿이 담겨있는 파일을 제공해도 된다. 이 파일은 Alertmanager가 로드해줄 거다. `/alertmanager/template/myorg.tmpl` 아래에 파일을 하나 만들고 "slack.myorg.txt"라는 이름으로 템플릿을 생성해라:

```prometheus
{% raw %}{{ define "slack.myorg.text" }}{% endraw %}https://internal.myorg.net/wiki/alerts/{% raw %}{{ .GroupLabels.app }}{% endraw %}/{% raw %}{{ .GroupLabels.alertname }}{% endraw %}{% raw %}{{ end}}{% endraw %}
```

이제 설정에선 "text" 필드에 템플릿 이름을 지정하고, 커스텀 템플릿 파일의 경로를 제공해주면 된다:

```yaml
global:
  slack_api_url: '<slack_webhook_url>'

route:
  receiver: 'slack-notifications'
  group_by: [alertname, datacenter, app]

receivers:
- name: 'slack-notifications'
  slack_configs:
  - channel: '#alerts'
    text: '{% raw %}{{ template "slack.myorg.text" . }}{% endraw %}'

templates:
- '/etc/alertmanager/templates/myorg.tmpl'
```

이 예제는 이 [블로그 포스트](https://prometheus.io/blog/2016/03/03/custom-alertmanager-templates/)에서 더 자세히 다루고 있다.
