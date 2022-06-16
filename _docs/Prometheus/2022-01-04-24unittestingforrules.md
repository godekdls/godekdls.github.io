---
title: Unit Testing for Rules
category: Prometheus
order: 24
permalink: /Prometheus/unit-testing-rules/
description: alerting rule, recording rule 단위 테스트 가이드
image: ./../../images/prometheus/logo.png
lastmod: 2022-01-05T21:30:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/prometheus/2.32/configuration/unit_testing_rules/
parent: PROMETHEUS
parentUrl: /Prometheus/prometheus/
subparent: Configuration
subparentUrl: /Prometheus/config/
---

---

정의한 rule들은 `promtool`을 이용해 테스트해볼 수 있다.

```sh
# 단일 테스트 파일 테스트.
./promtool test rules test.yml

# 테스트 파일이 여러 개라면 test1.yml,test2.yml,test3.yml이라고 알려주면 된다.
./promtool test rules test1.yml test2.yml test3.yml
```

### 목차

- [Test file format](#test-file-format)
  + [\<test_group\>](#test_group)
  + [\<series\>](#series)
  + [\<alert_test_case\>](#alert_test_case)
  + [\<alert\>](#alert)
  + [\<promql_test_case\>](#promql_test_case)
  + [\<sample\>](#sample)
- [Example](#example)
  + [test.yml](#testyml)
  + [alerts.yml](#alertsyml)

---

## Test file format

```yaml
# 테스트하고 싶은 rule 파일 목록. glob 패턴을 지원한다.
rule_files:
  [ - <file_name> ]

[ evaluation_interval: <duration> | default = 1m ]

# 아래에 그룹명을 나열한 순서대로 rule 그룹들을 평가한다 (정해진 평가 시간에).
# 순서는 아래에서 언급한 그룹들에 대해서만 보장한다.
# 모든 그룹을 전부 다 나열할 필요는 없다.
group_eval_order:
  [ - <group_name> ]

# 여기에 모든 테스트를 나열한다.
tests:
  [ - <test_group> ]
```

### `<test_group>`

```yaml
# 시계열 데이터
interval: <duration>
input_series:
  [ - <series> ]

# 테스트 그룹 이름
[ name: <string> ]

# 위 데이터로 테스트해볼 내용들.

# alerting rule을 위한 단위 테스트들. 입력 파일에서 지정한 alerting rule을 이용해 테스트한다.
alert_rule_test:
  [ - <alert_test_case> ]

# promql 표현식을 위한 단위 테스트들.
promql_expr_test:
  [ - <promql_test_case> ]

# alert 템플릿에서 사용할 수 있는 외부 레이블들.
external_labels:
  [ <labelname>: <string> ... ]

# alert 템플릿에서 사용할 수 있는 외부 URL.
# 보통 --web.external-url로 설정한다.
  [ external_url: <string> ]
```

### `<series>`

```yaml
# 여기서는 평상시 사용하는 시계열 표기법 '<metric name>{<label name>=<label value>, ...}'를 따른다.
# 예시:
#      series_name{label1="value1", label2="value2"}
#      go_goroutines{job="prometheus", instance="localhost:9090"}
series: <string>

# 여기서는 확장 표기법(Expanding notation)을 사용한다.
# 확장 표기법:
#     'a+bxc'는 'a a+b a+(2*b) a+(3*b) … a+(c*b)'와 동일하다
#     'a-bxc'는 'a a-b a-(2*b) a-(3*b) … a-(c*b)'와 동일하다
# 누락된 샘플이나 정체 중인 샘플은 전용 키워드로 표현할 수 있다.
#    '_'은 스크랩 중 누락된 샘플을 나타낸다
#    'stale'은 정체 중인 샘플을 의미한다
# 예시:
#     1. '-2+4x3'은 '-2 2 6 10'과 동일하다
#     2. ' 1-2x4'는 '1 -1 -3 -5 -7'과 동일하다
#     3. ' 1 _x3 stale'은 '1 _ _ _ stale'과 동일하다
values: <string>
```

### `<alert_test_case>`

프로메테우스에선 여러 alerting rule이 동일한 alert 이름을 사용할 수 있다. 따라서 여기에선 특정 alert 이름에서 시행되는 모든 alert를 하나의 `<alert_test_case>`로 통합해서 나열해야 한다.

```yaml
# 0초부터 시작해서 이 시간만큼 경과했을 때의 데이터로 alert를 체크한다.
eval_time: <duration>

# 테스트할 alert 이름
alertname: <string>

# 지정한 평가 시간에 지정한 alert 이름에서 시행할 것으로 예상하는 alert 목록.
# alerting rule이 시행되지 않는 것을 테스트하고 싶다면
# 위 필드들만 지정하고 'exp_alerts'를 비워 두면 된다.
exp_alerts:
  [ - <alert> ]
```

### `<alert>`

```yaml
# 예상 alert에 첨부되는 레이블과 어노테이션들.
# 참고: 레이블은 alert를 활성화한 샘플의 레이블도 포함이다 (`/alerts` 페이지에서 볼 수 있는 레이블과 동일하며, 시계열 `__name__`과 `alertname` 레이블은 제외다).
exp_labels:
  [ <labelname>: <string> ]
exp_annotations:
  [ <labelname>: <string> ]
```

### `<promql_test_case>`

```yaml
# 평가할 표현식
expr: <string>

# 0초부터 시작해서 이 시간만큼 경과했을 때의 데이터로 표현식을 평가한다.
eval_time: <duration>

# 지정한 평가 시간에 예상하는 샘플들.
exp_samples:
  [ - <sample> ]
```

### `<sample>`

```yaml
# 샘플 레이블은 평상시 사용하는 시계열 표기법 '<metric name>{<label name>=<label value>, ...}'를 따른다.
# 예시:
#      series_name{label1="value1", label2="value2"}
#      go_goroutines{job="prometheus", instance="localhost:9090"}
labels: <string>

# PromQL 표현식의 기대값.
value: <number>
```

---

## Example

다음은 통과하는 단위 테스트들을 담고 있는 예제 입력 파일이다. `test.yml`은 위에서 설명한 구문을 따르는 테스트 파일이며, `alerts.yml`에는 alerting rule이담겨 있다.

같은 디렉토리에 `alerts.yml`을 저장하고 `./promtool test rules test.yml`을 실행하면 된다.

### `test.yml`

```yaml
# 이 파일이 단위 테스트에서 메인으로 사용하는 입력 파일이다.
# 커맨드라인 인자로는 이 파일만 전달한다.

rule_files:
    - alerts.yml

evaluation_interval: 1m

tests:
    # Test 1.
    - interval: 1m
      # 시계열 데이터
      input_series:
          - series: 'up{job="prometheus", instance="localhost:9090"}'
            values: '0 0 0 0 0 0 0 0 0 0 0 0 0 0 0'
          - series: 'up{job="node_exporter", instance="localhost:9100"}'
            values: '1+0x6 0 0 0 0 0 0 0 0' # 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0
          - series: 'go_goroutines{job="prometheus", instance="localhost:9090"}'
            values: '10+10x2 30+20x5' # 10 20 30 30 50 70 90 110 130
          - series: 'go_goroutines{job="node_exporter", instance="localhost:9100"}'
            values: '10+10x7 10+30x4' # 10 20 30 40 50 60 70 80 10 40 70 100 130

      # alerting rule을 위한 단위 테스트.
      alert_rule_test:
          # Unit test 1.
          - eval_time: 10m
            alertname: InstanceDown
            exp_alerts:
                # Alert 1.
                - exp_labels:
                      severity: page
                      instance: localhost:9090
                      job: prometheus
                  exp_annotations:
                      summary: "Instance localhost:9090 down"
                      description: "localhost:9090 of job prometheus has been down for more than 5 minutes."
      # promql 표현식을 위한 단위 테스트.
      promql_expr_test:
          # Unit test 1.
          - expr: go_goroutines > 5
            eval_time: 4m
            exp_samples:
                # Sample 1.
                - labels: 'go_goroutines{job="prometheus",instance="localhost:9090"}'
                  value: 50
                # Sample 2.
                - labels: 'go_goroutines{job="node_exporter",instance="localhost:9100"}'
                  value: 50
```

### `alerts.yml`

```yaml
# 이 파일은 rule들을 담고 있는 파일이다.

groups:
- name: example
  rules:

  - alert: InstanceDown
    expr: up == 0
    for: 5m
    labels:
        severity: page
    annotations:
        summary: "Instance {% raw %}{{ $labels.instance }}{% endraw %} down"
        description: "{% raw %}{{ $labels.instance }}{% endraw %} of job {% raw %}{{ $labels.job }}{% endraw %} has been down for more than 5 minutes."

  - alert: AnotherInstanceDown
    expr: up == 0
    for: 10m
    labels:
        severity: page
    annotations:
        summary: "Instance {% raw %}{{ $labels.instance }}{% endraw %} down"
        description: "{% raw %}{{ $labels.instance }}{% endraw %} of job {% raw %}{{ $labels.job }}{% endraw %} has been down for more than 5 minutes."
```