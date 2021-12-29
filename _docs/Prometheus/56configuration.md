---
title: Alert Configuration
navTitle: Configuration
category: Prometheus
order: 56
permalink: /Prometheus/alerting.configuration/
description: Alertmanager 설정 가이드
image: ./../../images/prometheus/logo.png
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/alerting/0.23/configuration/
parent: ALERTING
parentUrl: /Prometheus/alerting/
---

---

[Alertmanager](https://github.com/prometheus/alertmanager) 설정은 커맨드라인 플래그와 설정 파일을 이용한다. 커맨드라인 플래그들이 변경할 수 없는 시스템 파라미터들을 구성한다면, 설정 파일에선 inhibition rule, notification 라우팅, notification receiver를 정의한다.

라우팅 트리를 구성할 때는 [비주얼 에디터](https://www.prometheus.io/webtools/alerting/routing-tree-editor)가 도움이 될 거다.

`alertmanager -h`를 실행하면 사용할 수 있는 전체 커맨드라인 플래그를 조회해볼 수 있다.

Alertmanager는 런타임에 설정을 다시 로드할 수 있다. 새 설정 파일의 형식이 잘못됐다면 변경 사항을 적용하지 않으며 에러는 로그에 기록된다. 프로세스에 `SIGHUP`을 전송하거나, `/-/reload` 엔드포인트에 HTTP POST 요청을 보내면 설정을 다시 로드할 수 있다.

### 목차

- [Configuration file](#configuration-file)
- [\<route\>](#route)
  + [Example](#example)
- [\<mute_time_interval\>](#mute_time_interval)
- [\<time_interval\>](#time_interval)
- [\<inhibit_rule\>](#inhibit_rule)
- [\<http_config\>](#http_config)
  + [oauth2](#oauth2)
- [\<tls_config\>](#tls_config)
- [\<receiver\>](#receiver)
- [\<email_config\>](#email_config)
- [\<pagerduty_config\>](#pagerduty_config)
  + [\<image_config\>](#image_config)
  + [\<link_config\>](#link_config)
- [\<pushover_config\>](#pushover_config)
- [\<slack_config\>](#slack_config)
  + [\<action_config\>](#action_config)
    * [\<action_confirm_field_config\>](#action_confirm_field_config)
  + [\<field_config\>](#field_config)
- [\<sns_configs\>](#sns_configs)
  + [\<sigv4_config\>](#sigv4_config)
- [\<matcher\>](#matcher)
- [\<opsgenie_config\>](#opsgenie_config)
  + [\<responder\>](#responder)
- [\<victorops_config\>](#victorops_config)
- [\<webhook_config\>](#webhook_config)
- [\<wechat_config\>](#wechat_config)

---

## Configuration file

로드할 설정 파일을 지정할 땐 `--config.file` 플래그를 사용한다.

```sh
./alertmanager --config.file=alertmanager.yml
```

설정 파일은 [YAML 형식](https://en.wikipedia.org/wiki/YAML)으로 작성하며, 아래에서 설명하는 스키마로 정의한다. 대괄호는 파라미터를 생략할 수 있음을 나타낸다. 리스트가 아닌 일반 파라미터들엔 디폴트 값을 명시해놨다.

공통으로 사용하는 플레이스홀더는 다음과 같다:

- `<duration>`: 정규 표현식 `((([0-9]+)y)?(([0-9]+)w)?(([0-9]+)d)?(([0-9]+)h)?(([0-9]+)m)?(([0-9]+)s)?(([0-9]+)ms)?|0)`에 매칭되는 기간. ex) `1d`, `1h30m`, `5m`, `10s`
- `<labelname>`: 정규 표현식 `[a-zA-Z_][a-zA-Z0-9_]*`에 매칭되는 문자열
- `<labelvalue>`: 유니 코드 문자로 이루어진 문자열
- `<filepath>`: 현재 작업 디렉토리 안에 있는 유효한 경로
- `<boolean>`: `true`, `false`를 사용하는 boolean
- `<string>`: 평범한 문자열
- `<secret>`: 비밀번호 같이 평소 시크릿에 사용하는 문자열
- `<tmpl_string>`: 사용 전에 템플릿을 이용해 확장되는 문자열
- `<tmpl_secret>`: 사용 전에 템플릿을 이용해 확장되는 시크릿 문자열
- `<int>`: 정수 값

그 외 다른 플레이스홀더는 별도로 명시했다.

컨텍스트 내에서 사용법을 보여주는 유효한 예제 파일은 [여기](https://github.com/prometheus/alertmanager/blob/main/doc/examples/simple.yml)에서 찾을 수 있다.

글로벌 설정에서 명시한 파라미터들은 모든 설정 컨텍스트에서 유효하다. 나머지 설정 섹션의 디폴트 값 역할도 수행한다.

```yaml
global:
  # 디폴트 SMTP From 헤더 필드.
  [ smtp_from: <tmpl_string> ]
  # 이메일을 보낼 때 사용할 디폴트 SMTP smarthost (포트 번호 포함).
  # TLS를 통한 SMTP(STARTTLS라고도 부른다)에선 보통 포트 번호는 25나 587이다.
  # Example: smtp.example.org:587
  [ smtp_smarthost: <string> ]
  # SMTP 서버에서 클라이언트를 식별하는데 사용할 디폴트 호스트명.
  [ smtp_hello: <string> | default = "localhost" ]
  # CRAM-MD5, LOGIN, PLAIN을 이용하는 SMTP 인증.
  # 비어 있으면 Alertmanager는 SMTP 서버를 인증하지 않는다.
  [ smtp_auth_username: <string> ]
  # LOGIN과 PLAIN을 이용한 SMTP 인증.
  [ smtp_auth_password: <secret> ]
  # PLAIN을 이용한 SMTP 인증.
  [ smtp_auth_identity: <string> ]
  # CRAM-MD5를 이용한 SMTP 인증.
  [ smtp_auth_secret: <secret> ]
  # 디폴트 SMTP TLS 요건.
  # 참고로 Go는 원격 SMTP 엔드포인트에 대한 암호화되지 않은 커넥션을 지원하지 않는다.
  [ smtp_require_tls: <bool> | default = true ]

  # Slack notification에 사용할 API URL.
  [ slack_api_url: <secret> ]
  [ slack_api_url_file: <filepath> ]
  [ victorops_api_key: <secret> ]
  [ victorops_api_url: <string> | default = "https://alert.victorops.com/integrations/generic/20131114/alert/" ]
  [ pagerduty_url: <string> | default = "https://events.pagerduty.com/v2/enqueue" ]
  [ opsgenie_api_key: <secret> ]
  [ opsgenie_api_url: <string> | default = "https://api.opsgenie.com/" ]
  [ wechat_api_url: <string> | default = "https://qyapi.weixin.qq.com/cgi-bin/" ]
  [ wechat_api_secret: <secret> ]
  [ wechat_api_corp_id: <string> ]

  # 디폴트 HTTP 클라이언트 설정
  [ http_config: <http_config> ]

  # ResolveTimeout은 alert에 EndsAt이 들어있지 않을 때 alertmanager에서 사용하는 기본값이다.
  # 이 시간이 지나고 나서도 alert가 업데이트되지 않으면
  # 해당 alert는 해결된 것으로(resolved) 처리할 수 있다.
  # 프로메테우스가 보내는 alert는 항상 EndsAt이 들어있기 때문에 별다른 영향은 없다.
  [ resolve_timeout: <duration> | default = 5m ]

# 커스텀 notification 템플릿 정의를 읽어올 파일들.
# 마지막 구성 요소엔 와일드카드 matcher를 사용할 수 있다 (ex. 'templates/*.tmpl').
templates:
  [ - <filepath> ... ]

# 라우팅 트리의 루트 노드.
route: <route>

# notification receiver 목록.
receivers:
  - <receiver> ...

# inhibition rule 목록.
inhibit_rules:
  [ - <inhibit_rule> ... ]

# 라우트를 뮤트 처리하기 위한 뮤트 타임 인터벌 목록.
mute_time_intervals:
  [ - <mute_time_interval> ... ]
```

---

## `<route>`

라우트 블록에선 라우팅 트리의 노드와 그 자식들을 정의한다. 비필수 설정 파라미터들은 설정하지 않으면 부모 노드에서 상속된다.

모든 alert는 최상위 라우트로 설정해둔 라우팅 트리로 진입하며, 최상위 라우트는 반드시 모든 alert와 매칭돼야 한다 (즉, 따로 matcher를 설정하지 않는다). 루트 진입 후엔 자식 노드들을 순회한다. `continue`를 false로 설정했다면, 첫 번째로 매칭되는 자식 노드를 만나고 나면 순회를 멈춘다. 매칭된 노드에서 `continue`가 true면, alert는 다음에 나오는 형제 노드와의 매칭을 계속 이어간다. alert가 어떤 자식 노드와도 매칭되지 않으면 (매칭되는 자식 노드가 없거나 자식 노드가 존재하지 않는 경우), alert를 현재 노드의 설정 파라미터들을 기반으로 처리한다.

```yaml
[ receiver: <string> ]
# 전달받은 alert들은 이 레이블을 기준으로 함께 묶인다.
# 예를 들어 cluster=A, alertname=LatencyHigh 레이블로 전달한 alert들을
# 하나의 그룹으로 묶어 일괄로 처리할 수 있다.
#
# 특수 값 '...'를 유일한 레이블 이름으로 지정하면 가능한 모든 레이블들로 집계한다.
# for example: group_by: ['...']
# 이렇게 하면 모든 alert를 있는 그대로 전달하기 때문에, 사실상 집계를 완전히 비활성화한다.
# alert 볼륨이 매우 작거나 업스트림 notification 시스템이 자체 그룹핑을 수행하는게 아니라면
# 원하는 동작은 아닐 거다.
[ group_by: [ <labelname>, ... ] ]

# alert를 이어서 나오는 형제 노드들과도 계속해서 매칭시켜야 하는지 여부.
[ continue: <boolean> | default = false ]

# DEPRECATED: 아래 있는 matchers를 사용해라.
# equality matcher 셋. 노드와 매칭되려면 alert는 이 조건을 충족해야 한다.
match:
  [ <labelname>: <labelvalue>, ... ]

# DEPRECATED: 아래 있는 matchers를 사용해라.
# regex-matcher 셋. 노드와 매칭되려면 alert는 이 조건을 충족해야 한다.
match_re:
  [ <labelname>: <regex>, ... ]

# matcher 목록. 노드와 매칭되려면 alert는 이 조건을 충족해야 한다.
matchers:
  [ - <matcher> ... ]

# alert 그룹의 notification을 전송하기 전 초반에 대기하는 시간.
# inhibition 처리된 alert가 더 도착할 때까지 기다릴 수도 있고,
# 같은 그룹에 초기 alert들을 더 수집하도록 기다릴 수도 있다. (보통 0초에서 몇 분 사이.)
[ group_wait: <duration> | default = 30s ]

# notification을 이미 전송한 적이 있는 alert 그룹에 새 alert들이 추가됐을 때,
# 관련 notification을 보내기 전에 대기하는 시간. (보통 5분 이상.)
[ group_interval: <duration> | default = 5m ]

# notification을 이미 보낸적 있는 특정 alert에 대한 
# notification을 다시 보내기까지 대기하는 시간. (보통 3시간 이상).
[ repeat_interval: <duration> | default = 4h ]

# 라우트를 뮤트해둬야 하는 시간.
# 여기에는 mute_time_intervals 섹션에 정의한 인터벌 이름을 지정해야 한다.
# 추가로, 루트 노드는 뮤트 타임을 가질 수 없다.
# 라우트가 뮤트 처리되면 notification은 보내지 않지만, 다른 것들은 정상적으로 동작한다
# ('continue' 옵션을 설정하지 않은 경우 라우트 매칭 프로세스를 끝내는 등).
mute_time_intervals:
  [ - <string> ...]

# 0개 이상의 자식 라우트들.
routes:
  [ - <route> ... ]
```

### Example

```yaml
# 파라미터들을 가지고 있는 루트 라우트.
# 이 파라미터들은 모두 자식 라우트에서 덮어쓰지 않으면 상속된다.
route:
  receiver: 'default-receiver'
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 4h
  group_by: [cluster, alertname]
  # 아래 있는 자식 라우트들과 매칭되지 않는 모든 alert는
  # 루트 노드에 남아 'default-receiver'로 전달된다.
  routes:
  # service=mysql 또는 service=cassandra를 가진
  # 모든 alert는 database pager로 전달된다.
  - receiver: 'database-pager'
    group_wait: 10s
    matchers:
    - service=~"mysql|cassandra"
  # team=frontend 레이블을 가지고 있는 모든 alert는 이 하위 라우트와 매칭된다.
  # alert들은 cluster와 alertname이 아닌 product와 environment로 묶이게 된다.
  - receiver: 'frontend-pager'
    group_by: [product, environment]
    matchers:
    - team="frontend"
```

---

## `<mute_time_interval>`

`mute_time_interval`은 하루 중 특정 시간 동안 원하는 라우트를 뮤트 처리할 수 있다. 라우팅 트리에선 여기에 명시한 인터벌 이름을 참조할 수 있다.

```yaml
name: <string>
time_intervals:
  [ - <time_interval> ... ]
```

---

## `<time_interval>`

실제 시간 간격은 `time_interval`에 정의한다. 여기선 다음과 같은 필드들을 지원한다:

```yaml
- times:
  [ - <time_range> ...]
  weekdays:
  [ - <weekday_range> ...]
  days_of_month:
  [ - <days_of_month_range> ...]
  months:
  [ - <month_range> ...]
  years:
  [ - <year_range> ...]
```

여기 있는 필드들은 전부 리스트다. 비어 있지 않은 리스트에선 요소가 하나라도 충족되면 해당 필드는 일치한다고 판단한다. 비어있는 필드는 전부 매칭되는 것으로 본다. 전체적인 시간 간격에 매칭되려면 모든 필드와 일치해야 한다. 필드에 따라 범위와 음수 인덱스를 지원하는 것도 있으며, 아래에서 자세히 설명한다. 모든 정의는 UTC로 간주하며, 현재 그외 다른 시간대는 지원하지 않는다.

`time_range`는 시작 시간(inclusive)부터 종료 시간(exclusive)까지의 범위를 나타낸다. 시작/종료 시간으로 간단히 시간의 경계를 표현할 수 있다. 예를 들어, *start*time: '17:00 & *end*time: '24:00'은 17:00 정각에 시작해서 24:00 직전에 끝난다. 시작, 종료 시간은 다음과 같이 지정한다:

```yaml
    times:
    - start_time: HH:MM
      end_time: HH:MM
```

`weekday_range`: 일요일로 시작해서 토요일로 끝나는 주중의 요일 목록이다. 요일은 이름으로 지정해야 한다 (ex. ‘Sunday’). 간편하게 `:`를 이용해서 요일의 범위를 표현할 수 있으며, 양 끝 모두 포함이다<sup>inclusive</sup> (ex. `[‘monday:wednesday','saturday', 'sunday']`)

`days_of_month_range`: 특정 달의 날짜 목록 (숫자). 날짜는 1부터 시작한다. 음수 값도 허용하며, 음수는 말일부터 시작한다. 즉, 1월의 -1일은 1월 31일을 나타낸다. 예를 들면 `['1:5', '-3:-1']`처럼 활용할 수 있다. 1일이나 말일을 지나가도록 확장하면 경계에 있는 날짜를 고정해준다. 즉, 2월에 `['1:31']`을 지정하면 윤년에 따라 실제 종료 날짜는 28일이나 29일로 고정된다. 양 끝 모두 포함이다<sup>inclusive</sup>.

`month_range`: 월의 리스트로, 대소문자 상관 없는 이름이나 (ex. ‘January’) 숫자로 식별한다 (1월 = 1). 범위도 허용하며 (ex. `['1:3', 'may:august', 'december']`), 양 끝 모두 포함이다<sup>inclusive</sup>.

`year_range`: 숫자로된 연도 목록이다. 범위를 허용하며 (ex. `['2020:2022', '2030']`), 양 끝 모두 포함이다<sup>inclusive</sup>.

---

## `<inhibit_rule>`

inhibition rule은 특정 matcher 셋과 일치하는 alert(소스)가 존재하면 또 다른 matcher 셋과 일치하는 alert(타겟)를 뮤트<sup>mute</sup>시킨다. 타겟 alert와 소스 alert는 `equal` 목록에 있는 레이블에 반드시 동일한 값을 가지고 있어야 한다.

누락된 레이블과 값이 비어 있는 레이블은 같은 의미로 본다. 따라서 `equal`에 있는 모든 레이블이 소스 alert와 타겟 alert에서 둘다 누락돼 있다면 inhibition rule을 적용한다.

alert가 자체적으로 뮤트<sup>mute</sup>되는 것을 방지하기 위해, 타겟의 규칙과 소스의 규칙에 *둘다* 매칭되는 alert들끼리는 서로간에 (자체 포함) inhibition을 적용할 수 없게 되어있다. 물론, 타겟 matcher와 소스 matcher는 양쪽 모두 alert를 매칭시키지 않도록 선택하길 권장한다. 원인을 파악하기도 훨씬 쉬우며, 이 특이 케이스를 유발하지도 않는다.

```yaml
# DEPRECATED: 아래 있는 target_matchers를 사용해라.
# alert를 뮤트시키려면 이 matcher들을 충족해야 한다.
target_match:
  [ <labelname>: <labelvalue>, ... ]
# DEPRECATED: 아래 있는 target_matchers를 사용해라.
target_match_re:
  [ <labelname>: <regex>, ... ]

# matcher 목록. 타겟 alert를 뮤트시키려면 이 조건을 충족해야 한다.
target_matchers:
  [ - <matcher> ... ]

# DEPRECATED: 아래 있는 source_matchers를 사용해라.
# inhibition을 시행하려면 매칭되는 alert가 하나 이상 존재해야 한다.
source_match:
  [ <labelname>: <labelvalue>, ... ]
# DEPRECATED: 아래 있는 source_matchers를 사용해라.
source_match_re:
  [ <labelname>: <regex>, ... ]

# matcher 목록. inhibition을 시행하려면 매칭되는 alert가 하나 이상 존재해야 한다.
source_matchers:
  [ - <matcher> ... ]

# inhibition을 적용하려면 소스 alert와 타겟 alert가
# 이 레이블들에 동일한 값을 가지고 있어야 한다.
[ equal: '[' <labelname>, ... ']' ]
```

---

## `<http_config>`

`http_config`에선 receiver가 HTTP 기반 API 서비스와 통신하는 데 사용하는 HTTP 클라이언트를 구성한다.

```yaml
# 참고로, `basic_auth`와 `authorization 옵션은 함께 사용할 수 없다.

# 설정한 username과 password로 `Authorization` 헤더를 세팅한다.
# password와 password_file은 함께 사용할 수 없다.
basic_auth:
  [ username: <string> ]
  [ password: <secret> ]
  [ password_file: <string> ]

# `Authorization` 헤더 설정 (Optional).
authorization:
  # 인증 타입을 설정한다.
  [ type: <string> | default: Bearer ]
  # credential을 설정한다.
  # `credentials_file`과는 함께 사용할 수 없다.
  [ credentials: <secret> ]
  # 설정한 파일에서 읽어온 credential을 설정한다.
  # `credentials`와는 함께 사용할 수 없다.
  [ credentials_file: <filename> ]

# OAuth 2.0 설정 (Optional).
# basic_auth나 authorization과는 동시에 사용할 수 없다.
oauth2:
  [ <oauth2> ]

# 프록시 URL (Optional).
[ proxy_url: <string> ]

# HTTP 요청에서 HTTP 3xx 리다이렉트 지시를 따를지 여부를 설정한다.
[ follow_redirects: <bool> | default = true ]

# TLS 설정을 구성한다.
tls_config:
  [ <tls_config> ]
```

### `oauth2`

client credentials grant 타입을 사용하는 OAuth 2.0 인증. Alertmanager는 설정한 클라이언트 액세스 권한과 시크릿 키를 사용해서 지정한 엔드포인트로부터 액세스 토큰을 가져온다.

```yaml
client_id: <string>
[ client_secret: <secret> ]

# 파일에서 클라이언트 시크릿을 읽어온다.
# `client_secret`과는 함께 사용할 수 없다.
[ client_secret_file: <filename> ]

# 토큰 요청에서 사용할 scope들.
scopes:
  [ - <string> ... ]

# 토큰을 가져올 URL.
token_url: <string>

# 토큰 URL에 첨부할 파라미터들 (Optional).
endpoint_params:
  [ <string>: <string> ... ]
```

---

## `<tls_config>`

`tls_config`를 사용하면 TLS 커넥션을 설정할 수 있다.

```yaml
# 서버 인증서를 검증할 CA 인증서.
[ ca_file: <filepath> ]

# 서버로 클라이언트 인증서를 보내 인증하기 위한 인증서 파일과 키 파일.
[ cert_file: <filepath> ]
[ key_file: <filepath> ]

# 서버 이름을 명시할 수 있는 ServerName 익스텐션.
# http://tools.ietf.org/html/rfc4366#section-3.1
[ server_name: <string> ]

# 서버 인증서의 유효성 검사를 비활성화한다.
[ insecure_skip_verify: <boolean> | default = false]
```

---

## `<receiver>`

Receiver는 하나 이상의 notification 통합을 구성하는 설정으로, 이름을 지정해야 한다.

참고: 과거에 새로 지원하려다 중단됐었던 receiver들을 재개하기 일환으로, 기존 요구 사항과 더불어 새 notification 통합을 개발할 땐 푸시 권한이 있는 담당 maintainer를 한 명 요구하는 것으로 합의봤다.

```yaml
# receiver의 고유한 이름.
name: <string>

# 다양한 notification 통합을 위한 설정들.
email_configs:
  [ - <email_config>, ... ]
pagerduty_configs:
  [ - <pagerduty_config>, ... ]
pushover_configs:
  [ - <pushover_config>, ... ]
slack_configs:
  [ - <slack_config>, ... ]
opsgenie_configs:
  [ - <opsgenie_config>, ... ]
webhook_configs:
  [ - <webhook_config>, ... ]
victorops_configs:
  [ - <victorops_config>, ... ]
wechat_configs:
  [ - <wechat_config>, ... ]
```

---

## `<email_config>`

```yaml
# 해소된(resolved) alert도 통보할지 여부.
[ send_resolved: <boolean> | default = false ]

# notification을 전송할 이메일 주소.
to: <tmpl_string>

# 발신자 주소
[ from: <tmpl_string> | default = global.smtp_from ]

# 이메일을 전송해줄 SMTP 호스트.
[ smarthost: <string> | default = global.smtp_smarthost ]

# SMTP 서버에서 클라이언트를 식별할 호스트명.
[ hello: <string> | default = global.smtp_hello ]

# SMTP 인증 정보.
[ auth_username: <string> | default = global.smtp_auth_username ]
[ auth_password: <secret> | default = global.smtp_auth_password ]
[ auth_secret: <secret> | default = global.smtp_auth_secret ]
[ auth_identity: <string> | default = global.smtp_auth_identity ]

# SMTP TLS 요건.
# 참고로 Go는 원격 SMTP 엔드포인트에 대한 암호화되지 않은 커넥션을 지원하지 않는다.
[ require_tls: <bool> | default = global.smtp_require_tls ]

# TLS 설정.
tls_config:
  [ <tls_config> ]

# email notification의 HTML 바디.
[ html: <tmpl_string> | default = {% raw %}{{ template "email.default.html" . }}{% endraw %} ]
# email notification의 텍스트 바디.
[ text: <tmpl_string> ]

# 추가적인 이메일 헤더 키/값 쌍들.
# notification 구현체에서 먼저 설정한 모든 헤더들을 재정의한다.
[ headers: { <string>: <tmpl_string>, ... } ]
```

---

## `<pagerduty_config>`

PagerDuty notification은 [PagerDuty API](https://developer.pagerduty.com/documentation/integration/events)를 통해 전송한다. PagerDuty는 프로메테우스와 통합하는 방법을 [문서](https://www.pagerduty.com/docs/guides/prometheus-integration-guide/)로 제공하고 있다. Alertmanager v0.11과 PagerDuty의 Events API v2로 넘어가면서는 중요한 차이점들이 생겼다.

```yaml
# 해소된(resolved) alert도 통보할지 여부.
[ send_resolved: <boolean> | default = true ]

# 아래 있는 두 옵션은 함께 사용할 수 없다.
# PagerDuty 통합 키 (PagerDuty 통합 타입이 `Events API v2`일 때).
routing_key: <tmpl_secret>
# PagerDuty 통합 키 (PagerDuty 통합 타입이 `Prometheus`일 때).
service_key: <tmpl_secret>

# API 요청을 전송할 URL
[ url: <string> | default = global.pagerduty_url ]

# Alertmanager를 식별하는 클라이언트 이름.
[ client:  <tmpl_string> | default = {% raw %}{{ template "pagerduty.default.client" . }}{% endraw %} ]
# notification 발신자를 확인할 수 있는 백링크.
[ client_url:  <tmpl_string> | default = {% raw %}{{ template "pagerduty.default.clientURL" . }}{% endraw %} ]

# incident에 대한 설명.
[ description: <tmpl_string> | default = {% raw %}{{ template "pagerduty.default.description" .}}{% endraw %} ]

# incident의 심각도.
[ severity: <tmpl_string> | default = 'error' ]

# incident에 추가하고 싶은 세부 정보를 담고있는 임의의 키/값 쌍 셋.
[ details: { <string>: <tmpl_string>, ... } | default = {
  firing:       '{% raw %}{{ template "pagerduty.default.instances" .Alerts.Firing }}{% endraw %}'
  resolved:     '{% raw %}{{ template "pagerduty.default.instances" .Alerts.Resolved }}{% endraw %}'
  num_firing:   '{% raw %}{{ .Alerts.Firing | len }}{% endraw %}'
  num_resolved: '{% raw %}{{ .Alerts.Resolved | len }}{% endraw %}'
} ]

# incident에 첨부할 이미지들.
images:
  [ <image_config> ... ]

# incident에 첨부할 링크들.
links:
  [ <link_config> ... ]

# 문제가 발생한 시스템의 구성 요소.
[ component: <tmpl_string> ]

# 소스들의 클러스터나 그룹.
[ group: <tmpl_string> ]

# 이벤트의 클래스/타입.
[ class: <tmpl_string> ]

# HTTP 클라이언트 설정.
[ http_config: <http_config> | default = global.http_config ]
```

### `<image_config>`

이 필드들은 [PagerDuty API 문서](https://developer.pagerduty.com/docs/events-api-v2/trigger-events/#the-images-property)에서 설명하고 있다.

```yaml
href: <tmpl_string>
source: <tmpl_string>
alt: <tmpl_string>
```

### `<link_config>`

이 필드들은 [PagerDuty API 문서](https://developer.pagerduty.com/docs/events-api-v2/trigger-events/#the-links-property)에서 설명하고 있다.

```yaml
href: <tmpl_string>
text: <tmpl_string>
```

---

## `<pushover_config>`

Pushover notification은 [Pushover API](https://pushover.net/api)를 통해 전송한다.

```yaml
# 해소된(resolved) alert도 통보할지 여부.
[ send_resolved: <boolean> | default = true ]

# 받는 쪽의 user key.
user_key: <secret>

# 등록해둔 애플리케이션의 API (https://pushover.net/apps 참고)
# 여기 있는 프로메테우스 앱을 복제해서 토큰을 등록해도 된다:
# https://pushover.net/apps/clone/prometheus
token: <secret>

# Notification 제목.
[ title: <tmpl_string> | default = {% raw %}{{ template "pushover.default.title" . }}{% endraw %} ]

# Notification 메세지.
[ message: <tmpl_string> | default = {% raw %}{{ template "pushover.default.message" . }}{% endraw %} ]

# 메세지와 함께 보여줄 보조 URL.
[ url: <tmpl_string> | default = {% raw %}{{ template "pushover.default.url" . }}{% endraw %} ]

# 중요도 (https://pushover.net/api#priority 참고).
[ priority: <tmpl_string> | default = {% raw %}{{ if eq .Status "firing" }}{% endraw %}2{% raw %}{{ else }}{% endraw %}0{% raw %}{{ end }}{% endraw %} ]

# Pushover 서버가 사용자에게 같은 notification을 전송하는 주기.
# 최소 30초는 돼야 한다.
[ retry: <duration> | default = 1m ]

# 사용자가 notification을 승인(acknowledge)하지 않으면
# 이 시간 동안은 계속해서 notification을 재전송한다.
[ expire: <duration> | default = 1h ]

# HTTP 클라이언트 설정.
[ http_config: <http_config> | default = global.http_config ]
```

---

## `<slack_config>`

Slack notification은 [Slack 웹훅](https://api.slack.com/incoming-webhooks)을 통해 전송한다. 이때 전송하는 notification에는 [attachment](https://api.slack.com/docs/message-attachments)를 첨부한다.

```yaml
# 해소된(resolved) alert도 통보할지 여부.
[ send_resolved: <boolean> | default = false ]

# Slack 웹훅 URL. api_url이나 api_url_file 중 하나만 설정해야 한다.
# 아무것도 설정하지 않으면 글로벌 설정으로 기본 설정된다.
[ api_url: <secret> | default = global.slack_api_url ]
[ api_url_file: <filepath> | default = global.slack_api_url_file ]

# notification을 전송할 채널이나 유저.
channel: <tmpl_string>

# Slack 웹훅 API에서 정의하는 API 요청 데이터.
[ icon_emoji: <tmpl_string> ]
[ icon_url: <tmpl_string> ]
[ link_names: <boolean> | default = false ]
[ username: <tmpl_string> | default = {% raw %}{{ template "slack.default.username" . }}{% endraw %} ]
# 아래 있는 파라미터들은 attachment를 정의한다.
actions:
  [ <action_config> ... ]
[ callback_id: <tmpl_string> | default = {% raw %}{{ template "slack.default.callbackid" . }}{% endraw %} ]
[ color: <tmpl_string> | default = {% raw %}{{ if eq .Status "firing" }}{% endraw %}danger{% raw %}{{ else }}{% endraw %}good{% raw %}{{ end }}{% endraw %} ]
[ fallback: <tmpl_string> | default = {% raw %}{{ template "slack.default.fallback" . }}{% endraw %} ]
fields:
  [ <field_config> ... ]
[ footer: <tmpl_string> | default = {% raw %}{{ template "slack.default.footer" . }}{% endraw %} ]
[ mrkdwn_in: [ <string>, ... ] | default = ["fallback", "pretext", "text"] ]
[ pretext: <tmpl_string> | default = {% raw %}{{ template "slack.default.pretext" . }}{% endraw %} ]
[ short_fields: <boolean> | default = false ]
[ text: <tmpl_string> | default = {% raw %}{{ template "slack.default.text" . }}{% endraw %} ]
[ title: <tmpl_string> | default = {% raw %}{{ template "slack.default.title" . }}{% endraw %} ]
[ title_link: <tmpl_string> | default = {% raw %}{{ template "slack.default.titlelink" . }}{% endraw %} ]
[ image_url: <tmpl_string> ]
[ thumb_url: <tmpl_string> ]

# HTTP 클라이언트 설정.
[ http_config: <http_config> | default = global.http_config ]
```

### `<action_config>`

이 필들은 Slack API 문서에 있는 [메시지 attachment](https://api.slack.com/docs/message-attachments#action_fields)와 [interactive 메시지](https://api.slack.com/docs/interactive-message-field-guide#action_fields)에서 설명하고 있다.

```yaml
text: <tmpl_string>
type: <tmpl_string>
# Either url or name and value are mandatory.
[ url: <tmpl_string> ]
[ name: <tmpl_string> ]
[ value: <tmpl_string> ]

[ confirm: <action_confirm_field_config> ]
[ style: <tmpl_string> | default = '' ]
```

#### `<action_confirm_field_config>`

이 필들은 [Slack API 문서](https://api.slack.com/docs/interactive-message-field-guide#confirmation_fields)에서 설명하고 있다.

```yaml
text: <tmpl_string>
[ dismiss_text: <tmpl_string> | default '' ]
[ ok_text: <tmpl_string> | default '' ]
[ title: <tmpl_string> | default '' ]
```

### `<field_config>`

이 필들은 [Slack API 문서](https://api.slack.com/docs/message-attachments#fields)에서 설명하고 있다.

```yaml
title: <tmpl_string>
value: <tmpl_string>
[ short: <boolean> | default = slack_config.short_fields ]
```

---

## `<sns_configs>`

```yaml
# 해소된(resolved) alert도 통보할지 여부.
[ send_resolved: <boolean> | default = true ]

# SNS API URL (ex. https://sns.us-east-2.amazonaws.com).
# 지정하지 않으면 SNS SDK에 있는 SNS API URL을 사용한다.
[ api_url: <tmpl_string> ]

# AWS의 Signature Verification 4 서명 프로세스를 설정해서 요청을 서명한다.
sigv4:
  [ <sigv4_config> ]

# SNS 토픽 ARN (ex. arn:aws:sns:us-east-2:698519295917:My-Topic).
# 이 값을 지정하지 않는다면 반드시 phone_number나 target_arn을 지정해야 한다.
# FIFO SNS 토픽을 사용한다면 SNS 디폴트 deduplication 윈도우에서
# 같은 그룹 키를 가진 메세지들이 제거되지 않도록 메세지 그룹 인터벌을 5분 이상으로 설정하는 게 좋다.
[ topic_arn: <tmpl_string> ]

# Subject line when the message is delivered to email endpoints.
[ subject: <tmpl_string> | default = {% raw %}{{ template "sns.default.subject" .}}{% endraw %} ] 

# 메세지를 E.164 형식의 SMS를 통해 전달하는 경우 사용하는 전화번호.
# 이 값을 지정하지 않는다면 반드시 topic_arn이나 target_arn을 지정해야 한다.
[ phone_number: <tmpl_string> ] 

# 메세지를 모바일 notification을 통해 전달하는 경우 사용하는 모바일 플랫폼 엔드포인트 ARN.
# 이 값을 지정하지 않는다면 반드시 topic_arn이나 phone_number를 지정해야 한다.
[ target_arn: <tmpl_string> ] 

# SNS notification의 메세지 내용.
[ message: <tmpl_string> | default = {% raw %}{{ template "sns.default.message" .}}{% endraw %} ] 

# SNS 메세지 속성들.
attributes: 
  [ <string>: <string> ... ]

# HTTP 클라이언트 설정.
[ http_config: <http_config> | default = global.http_config ]
```

### `<sigv4_config>`

```yaml
# AWS region. 비어있으면, 디폴트 credential 체인에 있는 region을 사용한다.
[ region: <string> ]

# AWS API 키. access_key와 secret_key는 모두 제공하거나 아니면 둘 다 비워둬야 한다.
# 비어있으면 환경 변수 `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`를 사용한다.
[ access_key: <string> ]
[ secret_key: <secret> ]

# 인증에 사용할 AWS 프로파일 이름.
[ profile: <string> ]

# AWS API 키 대신 사용할 수 있는 AWS Role ARN.
[ role_arn: <string> ]
```

---

## `<matcher>`

matcher는 PromQL과 OpenMetrics에서 따온 구문을 사용하는 문자열이다. matcher의 구문은 세 가지 토큰으로 구성된다.

- 유효한 프로메테우스 레이블명.
- `=`, `!=`, `=~`, `!~` 중 하나. `=`는 문자열이 같음을, `!=`는 같지 않음을 의미하며, `=~`는 정규 표현식의 일치로, `!~`는 정규 표현식의 불일치로 사용한다. PromQL 셀렉터에서 사용할 때와 같은 의미를 갖는다.
- 큰따옴표로 묶일 수 있는 UTF-8 문자열. 각 토큰 앞뒤엔 공백이 얼마든지 있을 수 있다.

세 번째 토큰엔 빈 문자열도 올 수 있다. 세 번째 토큰 안에선 OpenMetrics의 이스케이프 규칙을 적용한다. 큰따옴표는 `\"`, 줄 바꿈 문자는 `\n`, 백슬래시 자체는 `\\`로 이스케이프한다. 세 번째 토큰 안에는 절대 이스케이프하지 않은 `"`가 있어선 안 된다 (첫 번째나 마지막 문자에서만 사용한다). 단, 뒤에 `\`, `n`, `"`가 없는 단일 `\` 문자나, 줄 바꿈 문자 자체는 허용한다. 이 문자들은 자체 백슬래시 문자로 취급한다.

설정에선 YAML 리스트로 여러 가지 matcher를 조합할 수 있다. 하나의 YAML 문자열로 여러 matcher를 결합하는 것도 가능하며, 이때에도 PromQL에서 따온 구문을 사용한다. 이런 문자열에선 맨 앞에 있는 `{`과 맨 뒤에 있는 `}`는 생략할 수 있으며, 어차피 파싱하기 전에 잘라낸다. 이 문자열에 들어있는 개별 matcher는 따옴표 밖에서 콤마로 구분해준다. 이때 콤마는 공백으로 둘러싸도 된다. 이스케이프하지 않은 큰따옴표로 묶인 문자열 `"..."`은 그 자체를 문자열 인용으로 간주한다 (여기선 콤마가 구분 기호 역할을 하지 않는다). 큰따옴표를 단일 백슬래시 `\`로 이스케이프해주면, 입력 문자열의 따옴표 인용구로 보지 않는다. 맨 뒤에 있는 `}`을 잘라낸 입력 문자열이 콤마로 끝나고 그 뒤에 공백이 있으면, 이 쉼표와 공백도 잘라낸다.

다음은 몇 가지 유효한 string matcher 예시다:

1. 아래 보이는 것들은 긴 형식의 YAML 리스트로 결합한 두 개의 equality matcher다:

```yaml
  matchers:
   - foo = bar
   - dings !=bums 
```

{:start="2"}
1. 1번 예제와 유사하게, 아래에는 짧은 형식의 YAML 리스트로 결합한 두 개의 equality matcher가 보인다:

```yaml
matchers: [ foo = bar, dings != bums ]
```

짧은 형식을 이용할 땐 아래에서 보이는 것처럼, 콤마같은 특수 문자가 꼬이지 않도록 보통은 리스트 요소들을 따옴표로 감싸주는 게 좋다:

```yaml
matchers: [ "foo = bar,baz", "dings != bums" ]
```

{:start="3"}
1. 두 matcher를 하나의 문자열 하나에 넣는 것도 가능하다. 이때는 PromQL과 유사한 문자열을 사용한다. 여기서는 전체 문자열을 작은 따옴표로 감싸주는 게 가장 좋다.

```yaml
matchers: [ '{foo="bar",dings!="bums"}' ]
```

{:start="4"}
1. YAML 문자열의 따옴표, 이스케이프와 혼동하지 않으려면, YAML 블록 인용을 사용하면 된다. 이땐 블록 내에서는 OpenMetrics 이스케이프만 신경써주면 된다. 다음은 레이블 값 안에 복잡한 정규 표현식과 따옴표가 들어있는 예시다:

```yaml
matchers:
  - |
      {quote=~"She said: \"Hi, all!( How're you…)?\""}
```

---

## `<opsgenie_config>`

OpsGenie notification은 [OpsGenie API](https://docs.opsgenie.com/docs/alert-api)를 통해 전송한다.

```yaml
# 해소된(resolved) alert도 통보할지 여부.
[ send_resolved: <boolean> | default = true ]

# OpsGenie API와 통신할 때 사용할 API 키.
[ api_key: <secret> | default = global.opsgenie_api_key ]

# OpsGenie API 요청을 전송할 호스트.
[ api_url: <string> | default = global.opsgenie_api_url ]

# Alert 텍스트는 130자로 제한된다.
[ message: <tmpl_string> ]

# alert에 대한 설명.
[ description: <tmpl_string> | default = {% raw %}{{ template "opsgenie.default.description" . }}{% endraw %} ]

# notification 발신자를 확인할 수 있는 백링크.
[ source: <tmpl_string> | default = {% raw %}{{ template "opsgenie.default.source" . }}{% endraw %} ]

# alert에 추가하고 싶은 세부 정보를 담고있는 임의의 키/값 쌍 셋.
# 공통 레이블들은 전부 디폴트로 포함된다.
[ details: { <string>: <tmpl_string>, ... } ]

# notification을 담당하는 responder 목록.
responders:
  [ - <responder> ... ]

# notification에 첨부할 태그 목록 (콤마로 구분).
[ tags: <tmpl_string> ]

# 부가적인 alert note.
[ note: <tmpl_string> ]

# alert의 우선 순위 레벨. P1, P2, P3, P4, P5를 사용할 수 있다.
[ priority: <tmpl_string> ]

# HTTP 클라이언트 설정.
[ http_config: <http_config> | default = global.http_config ]
```

### `<responder>`

```yaml
# 이 필드 중 하나만 정의해야 한다.
[ id: <tmpl_string> ]
[ name: <tmpl_string> ]
[ username: <tmpl_string> ]

# "team", "user", "escalation", "schedule" 중 하나.
type: <tmpl_string>
```

---

## `<victorops_config>`

VictorOps notification은 [VictorOps API](https://help.victorops.com/knowledge-base/victorops-restendpoint-integration/)를 통해 전송한다.

```yaml
# 해소된(resolved) alert도 통보할지 여부.
[ send_resolved: <boolean> | default = true ]

# VictorOps API와 통신할 때 사용할 API 키.
[ api_key: <secret> | default = global.victorops_api_key ]

# VictorOps API URL.
[ api_url: <string> | default = global.victorops_api_url ]

# alert를 팀에 매핑할 때 사용할 키.
routing_key: <tmpl_string>

# alert 동작에 대한 설명 (CRITICAL, WARNING, INFO).
[ message_type: <tmpl_string> | default = 'CRITICAL' ]

# alert를 발생시킨 문제에 대한 요약 정보.
[ entity_display_name: <tmpl_string> | default = {% raw %}{{ template "victorops.default.entity_display_name" . }}{% endraw %} ]

# alert를 발생시킨 문제에 대한 긴 설명.
[ state_message: <tmpl_string> | default = {% raw %}{{ template "victorops.default.state_message" . }}{% endraw %} ]

# state message를 가지고 온 모니터링 툴.
[ monitoring_tool: <tmpl_string> | default = {% raw %}{{ template "victorops.default.monitoring_tool" . }}{% endraw %} ]

# HTTP 클라이언트 설정.
[ http_config: <http_config> | default = global.http_config ]
```

---

## `<webhook_config>`

웹훅 receiver를 이용하면 범용적인 receiver를 구성할 수 있다.

```yaml
# 해소된(resolved) alert도 통보할지 여부.
[ send_resolved: <boolean> | default = true ]

# HTTP POST 요청을 전송할 엔드포인트.
url: <string>

# HTTP 클라이언트 설정.
[ http_config: <http_config> | default = global.http_config ]

# 웹훅 메세지 하나에 최대로 넣을 수 있는 alert 수.
# 이 임계치를 초과하는 alert들은 잘라낸다.
# 기본값인 0으로 놔두면 모든 alert들을 포함시킨다.
[ max_alerts: <int> | default = 0 ]
```

Alertmanager는 설정한 엔드포인트에 다음과 같은 JSON 형식으로 HTTP POST 요청을 전송한다:

```js
{
  "version": "4",
  "groupKey": <string>,              // alert 그룹을 식별하는 키 (중복 제거 등을 위해)
  "truncatedAlerts": <int>,          // "max_alerts" 때문에 잘려진 alert 수
  "status": "<resolved|firing>",
  "receiver": <string>,
  "groupLabels": <object>,
  "commonLabels": <object>,
  "commonAnnotations": <object>,
  "externalURL": <string>,           // Alertmanager에 대한 백링크.
  "alerts": [
    {
      "status": "<resolved|firing>",
      "labels": <object>,
      "annotations": <object>,
      "startsAt": "<rfc3339>",
      "endsAt": "<rfc3339>",
      "generatorURL": <string>,      // alert를 유발한 엔티티를 식별한다
      "fingerprint": <string>        // alert를 식별하기 위한 fingerprint
    },
    ...
  ]
}
```

이 기능을 지원하는 [통합](../integrations#alertmanager-webhook-receiver) 목록을 참고해라.

---

## `<wechat_config>`

WeChat notification은 [WeChat API](https://admin.wechat.com/wiki/index.php?title=Customer_Service_Messages)를 통해 전송한다.

```yaml
# 해소된(resolved) alert도 통보할지 여부.
[ send_resolved: <boolean> | default = false ]

# WeChat API와 통신할 때 사용할 API 키.
[ api_secret: <secret> | default = global.wechat_api_secret ]

# WeChat API URL.
[ api_url: <string> | default = global.wechat_api_url ]

# 인증에 사용할 corp id.
[ corp_id: <string> | default = global.wechat_api_corp_id ]

# WeChat API에서 정의하는 API 요청 데이터.
[ message: <tmpl_string> | default = {% raw %}{{ template "wechat.default.message" . }}{% endraw %} ]
# 메세지 타입. `text`와 `markdown`을 지원한다.
[ message_type: <string> | default = 'text' ]
[ agent_id: <string> | default = {% raw %}{{ template "wechat.default.agent_id" . }}{% endraw %} ]
[ to_user: <string> | default = {% raw %}{{ template "wechat.default.to_user" . }}{% endraw %} ]
[ to_party: <string> | default = {% raw %}{{ template "wechat.default.to_party" . }}{% endraw %} ]
[ to_tag: <string> | default = {% raw %}{{ template "wechat.default.to_tag" . }}{% endraw %} ]
```