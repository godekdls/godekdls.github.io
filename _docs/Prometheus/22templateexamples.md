---
title: Template examples
category: Prometheus
order: 22
permalink: /Prometheus/template-examples/
description: 프로메테우스 템플릿 예제
image: ./../../images/prometheus/logo.png
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/prometheus/2.32/configuration/template_examples/
parent: PROMETHEUS
parentUrl: /Prometheus/prometheus/
subparent: Configuration
subparentUrl: /Prometheus/config/
---

---

프로메테우스에선 alert의 애노테이션과 레이블에 템플릿을 사용할 수 있으며, 콘솔 페이지들을 서빙해주기도 한다. 템플릿에선 로컬 데이터베이스에 질의하거나, 데이터를 순회하거나, 조건을 추가하고, 데이터 형식을 지정할 수 있다. 프로메테우스의 템플릿 언어는 [Go 템플릿 시스템](https://golang.org/pkg/text/template)을 사용한다.

### 목차

- [Simple alert field templates](#simple-alert-field-templates)
- [Simple iteration](#simple-iteration)
- [Display one value](#display-one-value)
- [Using console URL parameters](#using-console-url-parameters)
- [Advanced iteration](#advanced-iteration)
- [Defining reusable templates](#defining-reusable-templates)

---

## Simple alert field templates

```yaml
alert: InstanceDown
expr: up == 0
for: 5m
labels:
  severity: page
annotations:
  summary: "Instance {% raw %}{{$labels.instance}}{% endraw %} down"
  description: "{% raw %}{{$labels.instance}}{% endraw %} of job {% raw %}{{$labels.job}}{% endraw %} has been down for more than 5 minutes."
```

Alert 필드 템플릿은 alert가 시행<sup>fire</sup>될 때마다 모든 rule을 순회하면서 실행되므로, 여기선 모든 쿼리와 템플릿을 가볍게 유지하는 게 좋다. alert에 좀더 복잡한 템플릿이 필요하다면 콘솔 페이지로 연결하는 것을 권장한다.

---

## Simple iteration

다음은 인스턴스 목록과 작동 여부를 보여주는 템플릿이다:

```prometheus
{% raw %}{{ range query "up" }}{% endraw %}
  {% raw %}{{ .Labels.instance }}{% endraw %} {% raw %}{{ .Value }}{% endraw %}
{% raw %}{{ end }}{% endraw %}
```

변수 앞에 `.`이 있을 땐 조금 특별하게, 루프를 순회하면서 현재의 샘플 값에 접근할 수 있다.

---

## Display one value

```prometheus
{% raw %}{{ with query "some_metric{instance='someinstance'}" }}{% endraw %}
  {% raw %}{{ . | first | value | humanize }}{% endraw %}
{% raw %}{{ end }}{% endraw %}
```

Go와 Go의 템플릿 언어는 모두 strongly typed 언어이기 때문에, 반환된 샘플이 없다면 실행 에러가 발생할 수 있어 주의해야 한다. 예를 들어 아직 스크랩 전이거나, rule을 평가하지 않았을 때, 또는 호스트가 다운됐을 때 실행 에러가 발생할 수 있다.

기본 제공하는 `prom_query_drilldown` 템플릿을 이용하면 이를 알아서 잘 처리해주며, 출력 포맷을 지정하고 [expression 브라우저](../expression-browser)에 연결할 수도 있다.

---

## Using console URL parameters

```prometheus
{% raw %}{{ with printf "node_memory_MemTotal{job='node',instance='%s'}" .Params.instance | query }}{% endraw %}
  {% raw %}{{ . | first | value | humanize1024 }}{% endraw %}B
{% raw %}{{ end }}{% endraw %}
```

이 페이지에 `console.html?instance=hostname`으로 접근하면 `.Params.instance`는 `hostname`으로 평가된다.

---

## Advanced iteration

```html
<table>
{% raw %}{{ range printf "node_network_receive_bytes{job='node',instance='%s',device!='lo'}" .Params.instance | query | sortByLabel "device"}}{% endraw %}
  <tr><th colspan=2>{% raw %}{{ .Labels.device }}{% endraw %}</th></tr>
  <tr>
    <td>Received</td>
    <td>{% raw %}{{ with printf "rate(node_network_receive_bytes{job='node',instance='%s',device='%s'}[5m])" .Labels.instance .Labels.device | query }}{% endraw %}{% raw %}{{ . | first | value | humanize }}{% endraw %}B/s{% raw %}{{end}}{% endraw %}</td>
  </tr>
  <tr>
    <td>Transmitted</td>
    <td>{% raw %}{{ with printf "rate(node_network_transmit_bytes{job='node',instance='%s',device='%s'}[5m])" .Labels.instance .Labels.device | query }}{% endraw %}{% raw %}{{ . | first | value | humanize }}{% endraw %}B/s{% raw %}{{end}}{% endraw %}</td>
  </tr>{% raw %}{{ end }}{% endraw %}
</table>
```

여기서는 모든 네트워크 장비를 순회하며 각각의 네트워크 트래픽을 표기한다.

이때 `range` 작업에서 따로 변수를 명시하지 않았기 때문에, `.`은 이제 루프 변수가 돼서 루프 안에선 `.Params.instance`를 사용할 수 없다.

---

## Defining reusable templates

프로메테우스에선 템플릿들을 정의해놓고 재사용할 수 있다. 특히 템플릿을 모든 콘솔에 공유할 수 있는 [콘솔 라이브러리](../template-reference#console-templates)와 결합할 때 진가를 발휘한다.

```go
{% raw %}{{/* Define the template */}}{% endraw %}
{% raw %}{{define "myTemplate"}}{% endraw %}
  do something
{% raw %}{{end}}{% endraw %}

{% raw %}{{/* Use the template */}}{% endraw %}
{% raw %}{{template "myTemplate"}}{% endraw %}
```

템플릿은 인자 하나로만 제한된다. 여러 인자를 래핑하고 싶다면 `args` 함수를 사용하면 된다.

```go
{% raw %}{{define "myMultiArgTemplate"}}{% endraw %}
  First argument: {% raw %}{{.arg0}}{% endraw %}
  Second argument: {% raw %}{{.arg1}}{% endraw %}
{% raw %}{{end}}{% endraw %}
{% raw %}{{template "myMultiArgTemplate" (args 1 2)}}{% endraw %}
```