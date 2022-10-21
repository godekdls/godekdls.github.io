---
title: Template reference
category: Prometheus
order: 23
permalink: /Prometheus/template-reference/
description: 프로메테우스 템플릿 가이드
image: ./../../images/prometheus/logo.png
lastmod: 2022-01-05T21:30:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/prometheus/2.32/configuration/template_reference/
parent: PROMETHEUS
parentUrl: /Prometheus/prometheus/
subparent: Configuration
subparentUrl: /Prometheus/config/
---

---

프로메테우스에선 alert의 어노테이션과 레이블에 템플릿을 사용할 수 있으며, 콘솔 페이지들을 서빙해주기도 한다. 템플릿에선 로컬 데이터베이스에 질의하거나, 데이터를 순회하거나, 조건을 추가하고, 데이터 형식을 지정할 수 있다. 프로메테우스의 템플릿 언어는 [Go 템플릿 시스템](https://golang.org/pkg/text/template)을 사용한다.

### 목차

- [Data Structures](#data-structures)
- [Functions](#functions)
  + [Queries](#queries)
  + [Numbers](#numbers)
  + [Strings](#strings)
  + [Others](#others)
- [Template type differences](#template-type-differences)
  + [Alert field templates](#alert-field-templates)
  + [Console templates](#console-templates)

---

## Data Structures

시계열 데이터를 처리할 땐 다음과 같이 정의하는 sample을 기본 데이터 구조로 사용한다:

```go
type sample struct {
        Labels map[string]string
        Value  float64
}
```

샘플의 메트릭명은 `Labels` 맵 안에 특별한 레이블 `__name__`으로 인코딩된다.

`[]sample`은 샘플 목록을 의미한다.

Go의 `interface{}`는 C 언어의 void 포인터와 유사하다.

---

## Functions

프로메테우스는 Go 템플릿에서 제공하는 [디폴트 함수](https://golang.org/pkg/text/template/#hdr-Functions) 외에도, 템플릿에서 쉽게 쿼리 결과를 처리할 수 있도록 도와주는 함수들을 제공한다.

파이프라인 안에서 함수를 사용하면, 마지막 인자로 파이프라인 값을 전달한다.

### Queries

| Name        | Arguments        | Returns  | Notes                                                        |
| :---------- | :--------------- | :------- | :----------------------------------------------------------- |
| query       | query string     | []sample | 데이터베이스에 질의하며, range 벡터 반환은 지원하지 않는다.  |
| first       | []sample         | sample   | `index a 0`과 동일                                           |
| label       | label, sample    | string   | `index sample.Labels label`과 동일                           |
| value       | sample           | float64  | `sample.Value`와 동일                                        |
| sortByLabel | label, []samples | []sample | 주어진 레이블로 샘플을 정렬한다. [stable 정렬](https://pkg.go.dev/sort#Stable)이다. |

`first`, `label`, `value`는 파이프라인 안에서 쿼리 결과를 쉽게 사용할 수 있도록 도와주는 함수다.

### Numbers

| Name               | Arguments        | Returns | Notes                                                        |
| :----------------- | :--------------- | :------ | :----------------------------------------------------------- |
| humanize           | number or string | string  | [메트릭 프리픽스](https://en.wikipedia.org/wiki/Metric_prefix)를 사용해 숫자를 좀 더 읽기 쉬운 포맷으로 변환해준다. |
| humanize1024       | number or string | string  | `humanize`와 유사하지만, 기수에 1000 대신 1024를 사용한다.   |
| humanizeDuration   | number or string | string  | 초 단위 기간을 좀 더 읽기 쉬운 포맷으로 변환해준다.           |
| humanizePercentage | number or string | string  | 비율 값을 백분율로 변환해준다.                               |
| humanizeTimestamp  | number or string | string  | 초 단위 Unix 타임스탬프를 좀 더 읽기 쉬운 포맷으로 변환해준다. |

humanize 함수 시리즈는 데이터를 사람이 알아보기 좋은 포맷으로 바꿔주는 함수이며, 모든 프로메테우스 버전에서 동일한 결과를 보장하진 않는다.

### Strings

| Name         | Arguments                  | Returns | Notes                                                        |
| :----------- | :------------------------- | :------ | :----------------------------------------------------------- |
| title        | string                     | string  | [strings.Title](https://golang.org/pkg/strings/#Title). 각 단어의 첫 글자를 대문자로 변경한다. |
| toUpper      | string                     | string  | [strings.ToUpper](https://golang.org/pkg/strings/#ToUpper). 모든 문자를 대문자로 변환한다. |
| toLower      | string                     | string  | [strings.ToLower](https://golang.org/pkg/strings/#ToLower). 모든 문자를 소문자로 변환한다. |
| match        | pattern, text              | boolean | [regexp.MatchString](https://golang.org/pkg/regexp/#MatchString). 정규 표현식과 매칭되는지 테스트한다. 정규식은 앵커<sup>anchor</sup>로 시작과 끝을 고정하지 않은 정규식이다. |
| reReplaceAll | pattern, replacement, text | string  | [Regexp.ReplaceAllString](https://golang.org/pkg/regexp/#Regexp.ReplaceAllString). 정규표현식에 해당하는 문자열을 치환한다. 정규식은 앵커<sup>anchor</sup>로 시작과 끝을 고정하지 않은 정규식이다. |
| graphLink    | expr                       | string  | [expression 브라우저](../expression-browser)에서 해당 표현식을 조회할 수 있는 그래프 뷰 경로를 반환한다. |
| tableLink    | expr                       | string  | [expression 브라우저](../expression-browser)에서 해당 표현식을 조회할 수 있는 테이블 뷰 경로를 반환한다. |

### Others

| Name     | Arguments             | Returns                | Notes                                                        |
| :------- | :-------------------- | :--------------------- | :----------------------------------------------------------- |
| args     | []interface{}         | map[string]interface{} | 객체 리스트를 arg0, arg1 등의 키를 가지는 맵으로 변환한다. 템플릿에 여러 인자를 전달할 수 있게 해준다. |
| tmpl     | string, []interface{} | nothing                | 내장 `template`과 유사하지만, 이 함수는 템플릿 이름에 non-literal을 허용한다. 출력은 안전한 것으로 간주해서 자동으로 이스케이프되지 않는다는 점에 주의해라. 콘솔에서만 사용할 수 있다. |
| safeHtml | string                | string                 | 문자열을 자동 이스케이프가 필요없는 HTML로 마킹한다.         |

---

## Template type differences

템플릿 타입마다 파라미터로 표현할 수 있는 정보가 조금씩 상이하며, 그 외 다른 차이점도 몇 가지 존재한다.

### Alert field templates

`.Value`, `.Labels`, `.ExternalLabels`, `.ExternalURL`에는 각각 alert 값, alert 레이블, 전역으로 설정한 외부 레이블, 외부 URL(`--web.external-url`로 설정)이 들어있다. 편의를 위해 `$value`, `$labels`, `$externalLabels`, `$externalURL` 변수로도 노출하고 있다.

### Console templates

콘솔 페이지들은 `/consoles/`에서 접근할 수 있으며, `-web.console.templates` 플래그가 가리키는 디렉토리에서 소스를 가져온다.

콘솔 템플릿은 자동 이스케이프를 제공하는 [html/template](https://golang.org/pkg/html/template/)으로 렌더링된다. 자동 이스케이프를 건너뛰고 싶다면 `safe*` 함수 시리즈를 사용하면 된다.

URL 파라미터는 `.Params`에 있는 맵으로 접근할 수 있다. 같은 이름을 가지는 여러 개의 URL 파라미터에 접근할 땐, 각 파라미터 값들을 리스트로 가지고 있는 `.RawParams` 맵을 사용하면 된다. `/consoles/` 프리픽스를 제외한 URL 경로는 `.Path`에서 사용할 수 있다. 전역으로 설정한 외부 레이블은 `.ExternalLabels`로 사용할 수 있다. 네 가지 모두 간편하게 `$rawParams`, `$params`, `$path`, `$externalLabels` 변수로도 이용할 수 있다.

한 발 더 나아가면, `-web.console.libraries` 플래그로 가리키는 디렉토리에 있는 `*.lib` 파일에서 `{% raw %}{{define "templateName"}}...{{end}}{% endraw %}`로 템플릿을 정의해주면, 모든 콘솔에서 접근할 수 있다. 이 디렉토리는 공유 네임스페이스이므로, 다른 사용자와 충돌하지 않도록 주의해야 한다. `prom`, `_prom`, `__`로 시작하는 템플릿 이름은 위에서 보여준 함수들과 마찬가지로 프로메테우스 전용으로 예약돼 있다.