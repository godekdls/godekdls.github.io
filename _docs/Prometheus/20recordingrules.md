---
title: Recording rules
category: Prometheus
order: 20
permalink: /Prometheus/recording-rules/
description: 프로메테우스 recording rule 설정 가이드
image: ./../../images/prometheus/logo.png
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/prometheus/2.32/configuration/recording_rules/
parent: PROMETHEUS
parentUrl: /Prometheus/prometheus/
subparent: Configuration
subparentUrl: /Prometheus/config/
---

### 목차

- [Configuring rules](#configuring-rules)
- [Syntax-checking rules](#syntax-checking-rules)
- [Recording rules](#recording-rules)
  + [\<rule_group\>](#rule_group)
  + [\<rule\>](#rule)

---

## Configuring rules

프로메테우스에선 recording rule과 [alerting rule](../alerting-rules), 이렇게 두 타입의 rule을 설정한 뒤 일정한 간격으로 평가할 수 있다. 프로메테우스에 rule을 추가할 땐, 필요한 rule 구문을 담고 있는 파일을 만들어 [프로메테우스 설정](../configuration)에서 `rule_files` 필드를 통해 로드하면 된다. Rule 파일은 YAML을 사용한다.

rule 파일은 프로메테우스 프로세스에 `SIGHUP`을 전송하면 런타임에 다시 로드할 수 있다. 모든 rule 파일 포맷에 문제가 없을 때만 변경사항이 반영된다.

---

## Syntax-checking rules

프로메테우스의 커맨드라인 유틸리티 툴 `promtool`을 사용하면, 프로메테우스 서버를 시작해보지 않아도 rule 파일 구문을 바로 검증해볼 수 있다:

```sh
promtool check rules /path/to/example.rules.yml
```

`promtool` 바이너리 파일은 프로젝트 [다운로드 페이지](https://prometheus.io/download/)에서 받을 수 있는 `prometheus` 아카이브에 포함돼 있다.

파일이 구문 상 문제가 없으면 표준 출력에 파싱한 rule들을 텍스트로 찍은 다음 종료 상태 `0`을 리턴하고 종료한다.

구문 오류나 있거나 입력 인자가 올바르지 않으면 stderr에 에러 메시지를 출력하고 종료 상태 `1`과 함께 종료한다.

---

## Recording rules

Recording rule을 사용하면 자주 필요한 표현식이나 계산 비용이 큰 표현식을 미리 계산해서, 그 결과를 별도 시계열 셋으로 저장해둘 수 있다. 미리 결과를 계산해두면 보통은 필요할 때마다 같은 표현식을 매번 실행하는 것보단 훨씬 빠르다. 리프레시할 때마다 같은 표현식을 매번 질의해야 하는 대시보드가 있다면 특히 유용하다.

Recording, alerting rule은 rule 그룹 내에 존재한다. 같은 그룹 내에 있는 rule은 모두 함께 평가되며, 일정한 간격을 두고 순차적으로 실행한다. recording rule의 이름은 [유효한 메트릭 이름](../data-model#metric-names-and-labels)을 사용해야 하며, alerting rule의 이름엔 [유효한 레이블 값](../data-model#metric-names-and-labels)을 사용해야 한다.

rule 파일의 구문 규칙은 다음과 같다:

```yaml
groups:
  [ - <rule_group> ]
```

다음은 간단한 rule 파일 예시다:

```yaml
groups:
  - name: example
    rules:
    - record: job:http_inprogress_requests:sum
      expr: sum by (job) (http_inprogress_requests)
```

### `<rule_group>`

```yaml
# 그룹명. 이 파일 내에서 유니크해야 한다.
name: <string>

# 이 그룹에 있는 rule들을 평가할 간격.
[ interval: <duration> | default = global.evaluation_interval ]

# alerting rule이 생성할 수 있는 alert 갯수와 recording rule이 생성할 수 있는 시계열 갯수를 제한한다.
# 0은 제한이 없음을 의미한다.
[ limit: <int> | default = 0 ]

rules:
  [ - <rule> ... ]
```

### `<rule>`

recording rule의 구문 규칙은 다음과 같다:

```yaml
# 출력할 시계열 데이터 이름. 유효한 메트릭명을 지정해야 한다.
record: <string>

# 평가할 PromQL 표현식.
# 매 평가 주기마다 현재 시간을 기준으로 평가하고 새 시계열 셋에 기록한다.
# 메트릭명은 'record'에 지정한 이름을 사용한다.
expr: <string>

# 결과를 저장하기 전 추가하거나 덮어쓸 레이블.
labels:
  [ <labelname>: <labelvalue> ]
```

alerting rule의 구문 규칙은 다음과 같다:

```yaml
# alert 이름. 유효한 레이블 값을 지정해야 한다.
alert: <string>

# 평가할 PromQL 표현식.
# 매 평가 주기마다 현재 시간을 기준으로 평가하며,
# 평가 결과는 alert 시계열에 보류 (pending) 또는 시행 상태(firing)로 저장한다.
expr: <string>

# 이 기간 중에 alert가 반환됐다면 시행(firing)되는 것으로 간주한다.
# 이 기간이 지났음에도 시행되지 않은 alert는 보류(pending) 중인 것으로 간주한다.
[ for: <duration> | default = 0s ]

# 각 alert에 추가하거나 덮어쓸 레이블.
labels:
  [ <labelname>: <tmpl_string> ]

# 각 alert에 추가할 애노테이션.
annotations:
  [ <labelname>: <tmpl_string> ]
```

---

# LIMITING ALERTS AND SERIES

alerting rule로 만들어지는 alert와 recording rule로 만들어지는 시계열에는 그룹별로 제한치를 설정할 수 있다. 이 제한치를 초과하면 rule로 생성하는 *모든* 시계열을 폐기하며, alerting rule에선 해당 rule로 생성하는 *모든* active, pending, inactive alert를 정리한다. 평가 중에 이 이벤트가 발생하면 에러로 기록되기 때문에 stale 마커도 작성하지 않는다.

