---
title: Querying Prometheus
navTitle: Basics 
category: Prometheus
order: 27
permalink: /Prometheus/querying.basics/
description: PromQL 가이드
image: ./../../images/prometheus/logo.png
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/prometheus/2.32/querying/basics/
parent: PROMETHEUS
parentUrl: /Prometheus/prometheus/
subparent: Querying
subparentUrl: /Prometheus/querying/
---

---

프로메테우스는 사용자가 실시간으로 시계열 데이터를 선택해 집계할 수 있는 PromQL<sup>Prometheus Query Language</sup>이란 함수형 쿼리 언어를 제공한다. 표현식의 결과는 프로메테우스의 expression 브라우저에서 그래프나 테이블 형식으로 조회할 수 있으며, [HTTP API](../querying.api)를 통해 외부 시스템에서도 가져갈 수 있다.

### 목차

- [Examples](#examples)
- [Expression language data types](#expression-language-data-types)
- [Literals](#literals)
  + [String literals](#string-literals)
  + [Float literals](#float-literals)
- [Time series Selectors](#time-series-selectors)
  + [Instant vector selectors](#instant-vector-selectors)
  + [Range Vector Selectors](#range-vector-selectors)
  + [Time Durations](#time-durations)
  + [Offset modifier](#offset-modifier)
  + [@ modifier](#-modifier)
- [Subquery](#subquery)
- [Operators](#operators)
- [Functions](#functions)
- [Comments](#comments)
- [Gotchas](#gotchas)
  + [Staleness](#staleness)
  + [Avoiding slow queries and overloads](#avoiding-slow-queries-and-overloads)
  
---

## Examples

이 문서는 참고용 레퍼런스다. 쿼리를 익히려면 몇 가지 [예제](../querying.examples)로 시작하는 게 좀더 수월할 거다.

---

## Expression language data types

프로메테우스의 표현식 언어에선, 표현식 또는 하위 표현식은 다음 네 가지 타입 중 하나로 평가될 수 있다:

- **Instant vector** - 같은 타임스탬프에 있는 시계열 셋으로, 각 시계열마다 단일 샘플을 가지고 있다.
- **Range vector** - 특정 시간 범위에 있는 시계열 셋으로, 각 시계열마다 시간에 따른 데이터 포인트들을 가지고 있다.
- **Scalar** - 간단한 부동 소수점 숫자
- **String** - 간단한 문자열 값. 현재 사용하지 않는다

표현식을 사용하는 방식에 따라 (ex. 그래프로 나타낼 때 vs. 표현식의 출력을 보여줄 때) 정의할 수 있는 타입은 제한돼있다. 예를 들어, 직접 그래프로 나타낼 수 있는 유일한 타입은 instant 벡터를 반환하는 표현식이다.

---

## Literals

### String literals

리터럴을 작은따옴표나 큰따옴표, 백틱으로 감싸면 문자열을 지정할 수 있다.

PromQL은 [Go와 동일한 이스케이프 규칙](https://golang.org/ref/spec#String_literals)을 따른다. 작은따옴표나 큰따옴표에선 백슬래시 문자로 이스케이프 시퀀스를 시작하며, 슬래시 뒤에는 `a`, `b`, `f`, `n`, `r`, `t`, `v`, `\`가 올 수 있다. 문자를 특정 8진수 값이나(`\nnn`) 16진수 값으로(`\xnn`, `\unnnn`, `\Unnnnnnnn`) 제공할 수도 있다.

백틱 안에선 문자열을 이스케이프하지 않는다. 프로메테우스는 Go와는 달리 백틱 내부에 있는 개행 문자를 버리지 않는다.

예시:

```go
"this is a string"
'these are unescaped: \n \\ \t'
`these are not unescaped: \n ' " \t`
```

### Float literals

스칼라 float 값은 리터럴 정수나 부동 소수점 숫자를 다음과 같은 형식으로 작성하면 된다 (공백은 가독성을 위해 추가한 거다):

```go
[-+]?(
      [0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?
    | 0[xX][0-9a-fA-F]+
    | [nN][aA][nN]
    | [iI][nN][fF]
)
```

예시:

```
23
-2.43
3.4e-9
0x8f
-Inf
NaN
```

---

## Time series Selectors

### Instant vector selectors

Instant 벡터 셀렉터를 사용하면 지정한 타임스탬프(instant)에서 시계열 셋을 선택해 각 시계열마다 단일 샘플 값을 가져올 수 있다. 가장 간단하게는 메트릭 이름만 지정할 수 있다. 이렇게 하면 해당 메트릭명을 가진 모든 시계열의 요소들을 가지고 있는 instant 벡터가 생성된다.

다음 예시는 메트릭명이 `http_requests_total`인 모든 시계열을 선택한다:

```prometheus
http_requests_total
```

중괄호(`{}`) 안에 레이블 matcher들을 콤마로 구분해서 넣어주면, 이 시계열을 좀 더 구체적으로 필터링할 수 있다.

아래 예시에선 메트릭명이 `http_requests_total`인 시계열 중에서, `job` 레이블은 `prometheus`로, `group` 레이블은 `canary`로 설정한 시계열만을 선택한다:

```prometheus
http_requests_total{job="prometheus",group="canary"}
```

일치하지 않는 레이블 값을 찾거나 정규 표현식과 매칭하는 것도 가능하다. 레이블 매칭에는 다음과 같은 연산자를 사용할 수 있다:

- `=`: 지정한 문자열과 정확히 일치하는 레이블을 선택한다.
- `!=`: 지정한 문자열과 일치하지 않는 레이블을 선택한다.
- `=~`: 지정한 문자열과 정규식으로 매칭되는 레이블을 선택한다.
- `!~`: 지정한 문자열과 정규식으로 매칭되지 않는 레이블을 선택한다.

예를 들어 아래 표현식은 `http_requests_total` 시계열 중에서, `staging`, `testing`, `development` 환경에서 `GET` 이외의 HTTP 메소드를 사용하는 모든 시계열을 선택한다.

```prometheus
http_requests_total{environment=~"staging|testing|development",method!="GET"}
```

레이블 matcher로 빈 값을 매칭하면 해당 레이블 셋을 아예 설정하지 않은 시계열만 선택한다. 정규식을 매칭할 땐 앵커<sup>anchor</sup>를 적용해 시작과 끝을 완전히 고정한다. 같은 레이블 이름에 matcher를 여러 개 사용하는 것도 가능하다.

벡터 셀렉터에선 반드시 메트릭명 명시하거나, 아니면 빈 문자열과 매칭하지 않는 레이블 matcher를 최소 하나는 지정해야 한다. 다음과 같은 표현식은 사용할 수 없다:

```prometheus
{job=~".*"} # Bad!
```

반면 아래 표현식들은 셀렉터를 빈 레이블 값에 매칭하지 않으므로 둘 다 유효하다.

```prometheus
{job=~".+"}              # Good!
{job=~".*",method="get"} # Good!
```

레이블 matcher는 내부 `__name__` 레이블과 매칭시킨다면 메트릭 이름에도 사용할 수 있다. 예를 들어 `http_requests_total` 표현식은 `{__name__="http_requests_total"}`과 동일하다. `=` 말고 다른 matcher(`!=`, `=~`, `!~`)도 사용할 수 있다. 아래 표현식은 이름이 `job:`으로 시작하는 모든 메트릭을 선택한다:

```prometheus
{__name__=~"job:.*"}
```

메트릭명엔 `bool`, `on`, `ignoring`, `group_left`, `group_right` 키워드는 사용할 수 없다. 다음과 같은 표현식은 사용할 수 없다:

```prometheus
on{} # Bad!
```

이 제약은 `__name__` 레이블을 사용하는 것으로 풀어나갈 수 있다:

```prometheus
{__name__="on"} # Good!
```

프로메테우스에선 모든 정규 표현식에 [RE2 구문](https://github.com/google/re2/wiki/Syntax)을 사용한다.

### Range Vector Selectors

Range 벡터 리터럴은 현재 instant에서 샘플 범위를 가져온다는 점만 빼면 instant 벡터 리터럴과 유사하게 동작한다. 문법에 대해 설명하자면, 벡터 셀럭터 끝에 대괄호(`[]`)를 사용해 [기간](#time-durations)을 추가해서, 선택한 range 벡터 요소마다 어느 시점부터 데이터를 가져와야 하는지 지정한다.

아래 예시에선 메트릭명이 `http_requests_total`이고 `job` 레이블을 `prometheus`로 설정한 모든 시계열에서, 지난 5분 이내에 기록된 모든 값들을 가져온다:

```prometheus
http_requests_total{job="prometheus"}[5m]
```

### Time Durations

기간은 숫자 바로 뒤에 아래 단위 중 하나를 붙여서 지정한다:

- `ms` - milliseconds
- `s` - seconds
- `m` - minutes
- `h` - hours
- `d` - days - 하루는 무조건 24h라는 가정
- `w` - weeks - 한 주는 무조건 7d라는 가정
- `y` - years - 일 년은 무조건 365d라는 가정

기간은 연결해서 사용할 수도 있다. 이때 단위는 가장 긴 단위부터 가장 짧은 단위 순으로 나열해야 한다. 기간 하나에 같은 단위를 중복해서 사용할 순 없다.

다음은 몇 가지 유효한 기간 예시다:

```
5h
1h30m
5m
10s
```

### Offset modifier

쿼리에서 `offset` modifier를 사용하면 개별 instant, range 벡터의 타임 오프셋을 변경할 수 있다.

예를 들어 아래 표현식은 현재 쿼리 평가 시간을 기준으로 5분 전의 `http_requests_total` 값을 반환한다:

```prometheus
http_requests_total offset 5m
```

`offset` modifier는 항상 셀렉터 바로 뒤에 있어야 한다는 점에 주의하자. 즉, 다음은 올바른 구문이다:

```prometheus
sum(http_requests_total{method="GET"} offset 5m) # GOOD.
```

반면 다음은 *잘못된* 구문을 사용한 표현식이다:

```prometheus
sum(http_requests_total{method="GET"}) offset 5m # INVALID.
```

range 벡터에서도 마찬가지다. 다음 예시는 `http_requests_total`이 일주일 전에 가지고 있었던 데이터로 5분 동안의 초당 요청량을 반환한다:

```prometheus
rate(http_requests_total[5m] offset 1w)
```

시간을 앞으로 이동해서 비교할 때는 음수 오프셋을 지정하면 된다:

```prometheus
rate(http_requests_total[5m] offset -1w)
```

이 기능은 `--enable-feature=promql-negative-offset` 플래그를 설정해서 활성화한다. 자세한 내용은 [피처 플래그](../feature-flags)를 참고해라.

### @ modifier

`@` modifier를 사용하면 쿼리에서 개별 instant, range 벡터를 평가할 시간을 변경할 수 있다. `@` modifier에 지정하는 시간은 유닉스 타임스탬프이며, float 리터럴로 표현한다.

예를 들어 다음 표현식은 `2021-01-04T07:40:00+00:00`의 `http_requests_total` 값을 반환한다:

```prometheus
http_requests_total @ 1609746000
```

`@` modifier는 항상 셀렉터 바로 뒤에 있어야 한다는 점에 주의하자. 즉, 다음은 올바른 구문이다:

```prometheus
sum(http_requests_total{method="GET"} @ 1609746000) # GOOD.
```

반면 다음은 *잘못된* 구문을 사용한 표현식이다:

```prometheus
sum(http_requests_total{method="GET"}) @ 1609746000 # INVALID.
```

range 벡터에서도 마찬가지다. 다음 예시는 `http_requests_total`이 `2021-01-04T07:40:00+00:00`에 가지고 있었던 데이터로 5분 동안의 초당 요청량을 반환한다:

```prometheus
rate(http_requests_total[5m] @ 1609746000)
```

`@` modifier는 위에서 설명한 모든 float 리터럴 표현을  `int64` 범위 내로 지원한다. `offset` modifier와도 함께 사용할 수 있는데, 이땐 어떤 modifier를 먼저 지정했는지에 상관 없이 `@` modifier 시간을 기준으로 오프셋을 적용한다. 아래 두 쿼리는 같은 결과를 생성한다:

```prometheus
# @, offset 순
http_requests_total @ 1609746000 offset 5m
# offset, @ 순
http_requests_total offset 5m @ 1609746000
```

이 modifier는 PromQL이 시간을 미리 내다보고 샘플을 평가하지 않는다는 불변성에 위배되기 때문에 기본적으론 비활성화돼 있다. 활성화할 땐 `--enable-feature=promql-at-modifier` 플래그를 설정하면 된다. 자세한 내용은 [피처 플래그](../feature-flags)를 참고해라.

더 나아가면, `@` modifier 값에는 `start()`, `end()`라는 특수 값을 사용할 수 있다.

range 쿼리에선 각각 range 쿼리의 시작과 끝으로 리졸브되며, 모든 단계에서 동일하게 유지된다.

instant 쿼리에선 `start()`와 `end()`는 모두 평가 시간으로 리졸브된다.

```prometheus
http_requests_total @ start()
rate(http_requests_total[5m] @ end())
```

---

## Subquery

서브 쿼리를 사용하면 지정한 범위와 해상도<sup>resolution</sup>로 instant 쿼리를 실행할 수 있다. 서브 쿼리의 결과는 range 벡터다.

Syntax: `<instant_query> '[' <range> ':' [<resolution>] ']' [ @ <float_literal> ] [ offset <duration> ]`

- `<resolution>`은 생략할 수 있다. 생략하면 글로벌 평가 주기를 사용한다.

---

## Operators

프로메테우스는 다양한 이항 연산자와 집계 연산자를 지원한다. [표현식 언어 연산자](../querying.operators) 페이지에서 자세히 다룬다.

---

## Functions

프로메테우스는 데이터에 적용할 수 있는 다양한 함수들을 지원한다. [표현식 언어 함수](../querying.functions) 페이지에서 자세히 다룬다.

---

## Comments

PromQL에서 `#`으로 시작하는 라인은 주석이다. 예를 들어:

```prometheus
    # This is a comment
```

---

## Gotchas

### Staleness

쿼리를 실행하게 되면, 실제로 존재하는 시계열 데이터와는 별도로, 데이터를 샘플링할 타임스탬프도 선택한다. 이렇게 하는 이유는 주로 `sum`, `avg` 등으로 여러 시계열을 집계했을 때, 시계열들이 시간상으로 정확히 일렬로 정렬되지 않는 경우를 지원하기 위해서다. 시계열마다 가지고 있는 타임스탬프 값이 다르기 때문에, 프로메테우스에선 관련 시계열마다 별도로 선택한 타임스탬프에 값을 할당해야 한다. 사실 간단하게 해당 타임스탬프 이전에 있는 가장 최신 샘플을 가져오고 있다.

타겟 스크랩이나 rule 평가에서 이전에 존재했던 시계열에 대한 샘플을 더 이상 반환하지 않을 때는, 해당 시계열을 stale로 마킹한다. 타겟이 제거되면 이전에 반환했던 시계열은 머지않아 stale로 마킹된다.

샘플링 타임스탬프에서 쿼리를 평가할 때 이미 시계열을 stale로 마킹한 다음이라면, 해당 시계열의 값은 반환하지 않는다. 이후 다시 해당 시계열의 샘플을 새로 수집하면 정상적으로 반환된다.

샘플링 타임스탬프에서 5분(디폴트) 전까지 샘플이 없다면, 이 시점에선 해당 시계열에 대한 값을 반환하지 않는다. 사실상 가장 최근에 수집한 샘플이 5분보다 오래됐거나 이미 stale로 마킹됐다면, 이 시계열은 해당 시점의 그래프에서 "사라진다"는 것을 의미한다.

타임스탬프도 함께 스크랩하는 시계열에는 staleness를 마킹하지 않는다. 이 경우엔 5분이라는 임계치만 적용된다.

### Avoiding slow queries and overloads

쿼리를 통해 대량의 데이터를 연산한다면 그래프를 그리다 타임아웃이 발생하거나, 서버나 브라우저에 과부하가 올 수도 있다. 따라서 미지의 데이터로 쿼리를 구성할 땐, 결과 셋이 나름 합리적일 때까지는 (시계열 수 천개가 아니라 최대 수백 개정도 보일때 까지) 항상 expression 브라우저의 테이블 뷰에서 먼저 실행해보는 게 좋다. 그래프 모드는 데이터를 충분히 필터링했거나 집계했을 때만 전환해라. 그래도 표현식을 그래프로 전환하는 데 시간이 너무 오래 걸린다면 [recording rule](../recording-rules#recording-rules)을 통해 사전에 기록해두는 게 좋다.

쿼리 성능은 특히 프로메테우스의 쿼리 언어와 관련이 깊다. 쿼리 언어에선 `api_http_requests_total`과 같이 아무 matcher도 지정하지 않는 메트릭명 selector도 일이 커지면 다른 레이블을 가진 수천 개의 시계열을 불러올 수 있다. 대량의 시계열을 집계하는 표현식은 출력되는 시계열은 적더라도 서버에 부하를 준다는 점도 유의해야 한다. 관계형 데이터베이스에서 모든 컬럼 값을 합산하면 출력 값은 단일 숫자더라도 속도가 느려지는 것과 같은 이치다.

