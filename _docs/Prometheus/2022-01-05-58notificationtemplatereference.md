---
title: Notification template reference
category: Prometheus
order: 58
permalink: /Prometheus/notifications/
description: notification 템플릿 가이드
image: ./../../images/prometheus/logo.png
lastmod: 2022-01-05T21:30:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/alerting/0.23/notifications/
parent: ALERTING
parentUrl: /Prometheus/alerting/
---

---

프로메테우스는 alert를 생성해서 Alertmanager로 보내며, Alertmanager는 이어서 alert들의 레이블을 기반으로 각기 다른 receiver들에게 통보<sup>notification</sup>해준다. receiver는 다양한 통합 기능 중에서 선택할 수 있으며, 이 중에는 Slack, PagerDuty, 이메일도 있고, 범용적인 웹훅 인터페이스를 통해 커스텀할 수도 있다.

receiver에게 보내는 통지<sup>notification</sup>는 템플릿을 통해 구성된다. Alertmanager는 디폴트 템플릿을 함께 제공하지만 커스텀도 가능하다. Alertmanager의 템플릿은 [프로메테우스의 템플릿](../template-reference)과는 다르니 혼동하지 말자. 여기서 말하는 프로메테우스 템플릿은 alert rule의 레이블/애노테이션 템플릿도 포함이다.

Alertmanager의 notification 템플릿은 [Go 템플릿](https://golang.org/pkg/text/template) 시스템을 기반으로 작성한다. 텍스트로 평가되는 필드도 있고, 이스케이프에 영향을 주는 HTML로 평가되는 필드도 있으니 주의해라.

### 목차

- [Data](#data)
- [Alert](#alert)
- [KV](#kv)
  + [KV methods](#kv-methods)
- [Strings](#strings)

---

# DATA STRUCTURES

---

## Data

`Data`는 notification 템플릿과 웹훅 푸시로 전달되는 구조체다.

| Name              | Type            | Notes                                                        |
| :---------------- | :-------------- | :----------------------------------------------------------- |
| Receiver          | string          | notification을 전송할 receiver의 이름을 정의한다 (slack, 이메일 등). |
| Status            | string          | alert가 하나라도 시행 중이면 firing으로 정의하고, 그 외는 resolved로 정의한다. |
| Alerts            | [Alert](#alert) | 이 그룹에 속하는 모든 alert 객체 목록 ([아래 참고](#alert)). |
| GroupLabels       | [KV](#kv)       | 이 alert들을 그룹으로 묶은 레이블들.                         |
| CommonLabels      | [KV](#kv)       | 모든 alert에 공통으로 사용할 레이블들.                       |
| CommonAnnotations | [KV](#kv)       | 모든 alert에 공통으로 사용할 애노테이션셋. alert에 좀 더 긴 부가 정보 문자열을 추가할 때 사용한다. |
| ExternalURL       | string          | notification을 전송한 Alertmanager에 대한 백링크.            |

`Alerts` 타입에선 alert 필터링 함수들을 제공한다:

- `Alerts.Firing`: 이 그룹에서 현재 시행<sup>firing</sup> 중인 alert 객체 목록을 반환한다
- `Alerts.Resolved`: 이 그룹에서 현재 해소된<sup>resolved</sup> alert 객체 목록을 반환한다

---

## Alert

`Alert`는 notification 템플릿에서 사용할 하나의 alert를 가지고 있다.

| Name         | Type      | Notes                                                        |
| :----------- | :-------- | :----------------------------------------------------------- |
| Status       | string    | alert가 해소되었는지<sup>resolved</sup> 또는 현재 시행<sup>firing</sup> 중인지 여부를 정의한다. |
| Labels       | [KV](#kv) | alert에 첨부할 레이블 셋.                                    |
| Annotations  | [KV](#kv) | alert의 애노테이션 셋.                                       |
| StartsAt     | time.Time | alert가 시행<sup>firing</sup>되기 시작한 시간. 생략하면 Alertmanager가 현재 시간을 할당한다. |
| EndsAt       | time.Time | alert의 종료 시간을 알고 있을 때만 설정한다. 생략하면 마지막 alert를 수신한 시간에 타임아웃만큼의 기간을 더해 설정하며, 이 타임아웃 값은 설정으로 수정할 수 있다. |
| GeneratorURL | string    | 이 alert를 발생시킨 엔티티를 식별하는 백링크.                |
| Fingerprint  | string    | alert를 식별하는데 사용하는 fingerprint.                     |

---

## KV

`KV`는 레이블과 애노테이션을 표현할 때 사용하는 키/값 문자열 쌍의 셋이다.

```go
type KV map[string]string
```

아래 예시는 두 개의 애노테이션을 가지고 있다:

```js
{
  summary: "alert summary",
  description: "alert description",
}
```

KV로 저장한 데이터(레이블과 애노테이션)는 직접 액세스할 수 있으며, 그 외에도 LabelSet을 정렬, 제거, 조회할 수 있는 메소드를 제공한다:

### KV methods

| Name        | Arguments | Returns                          | Notes                                            |
| :---------- | :-------- | :------------------------------- | :----------------------------------------------- |
| SortedPairs | -         | Pairs (키/값 문자열 쌍의 리스트) | 키/값 쌍을 정렬한 목록을 반환한다.               |
| Remove      | []string  | KV                               | 주어진 키를 제외한 키/값 맵의 복사본을 반환한다. |
| Names       | -         | []string                         | LabelSet에 있는 레이블 이름들의 목록을 반환한다. |
| Values      | -         | []string                         | LabelSet에 있는 값들의 목록을 반환한다.          |

---

# FUNCTIONS

Go 템플릿에서 제공하는 [디폴트 함수들](https://golang.org/pkg/text/template/#hdr-Functions)도 사용할 수 있으니 참고해라.

---

## Strings

| Name         | Arguments                  | Returns                                                      | Notes |
| :----------- | :------------------------- | :----------------------------------------------------------- | :---- |
| title        | string                     | [strings.Title](https://golang.org/pkg/strings/#Title). 각 단어의 첫 글자를 대문자로 변경한다. |       |
| toUpper      | string                     | [strings.ToUpper](https://golang.org/pkg/strings/#ToUpper). 모든 문자를 대문자로 변환한다. |       |
| toLower      | string                     | [strings.ToLower](https://golang.org/pkg/strings/#ToLower). 모든 문자를 소문자로 변환한다. |       |
| match        | pattern, string            | [Regexp.MatchString](https://golang.org/pkg/regexp/#MatchString). 문자열을 정규식으로 매칭한다. |       |
| reReplaceAll | pattern, replacement, text | [Regexp.ReplaceAllString](https://golang.org/pkg/regexp/#Regexp.ReplaceAllString). 정규식에 해당하는 문자열을 치환한다. 정규식은 앵커<sup>anchor</sup>로 시작과 끝을 고정하지 않은 정규식이다. |       |
| join         | sep string, s []string     | [strings.Join](https://golang.org/pkg/strings/#Join). s에 있는 요소들을 연결해서 하나의 문자열을 만든다. 결과로 만들어지는 문자열에는 요소 사이사이에 구분자 문자열 sep가 들어있다. (참고: 템플릿에서 파이프라인을 쉽게 구성할 수 있도록 인자 순서를 뒤바꿨다.) |       |
| safeHtml     | text string                | [html/template.HTML](https://golang.org/pkg/html/template/#HTML). 문자열을 자동 이스케이프가 필요없는 HTML로 마킹한다. |       |
| stringSlice  | ...string                  | 전달한 문자열들을 문자열 목록으로 반환한다.                  |       |