---
title: Working with Asciidoctor
category: Spring REST Docs
order: 7
permalink: /Spring%20REST%20Docs/workingwithaciidoctor/
description: 스프링 Rest Docs에서 Asciidoctor 다루기 한글 번역
image: ./../../images/springrestdocs/logo.png
lastmod: 2020-12-19T00:00:00+09:00
comments: true
originalRefName: 스프링 REST Docs
originalRefLink: https://docs.spring.io/spring-restdocs/docs/2.0.5.RELEASE/reference/html5/#working-with-asciidoctor
---

### 목차

- [6.1. Resources](#61-resources)
- [6.2. Including Snippets](#62-including-snippets)
  + [6.2.1. Including Multiple Snippets for an Operation](#621-including-multiple-snippets-for-an-operation)
    * [Section Titles](#section-titles)
  + [6.2.2. Including Individual Snippets](#622-including-individual-snippets)
- [6.3. Customizing Tables](#63-customizing-tables)
  + [6.3.1. Formatting Columns](#631-formatting-columns)
  + [6.3.2. Configuring the Title](#632-configuring-the-title)
  + [6.3.3. Avoiding Table Formatting Problems](#633-avoiding-table-formatting-problems)
  + [6.3.4. Further Reading](#634-further-reading)

---

이번 섹션에선 스프링 REST Docs와 관련해서 필요한 Asciidoctor를 다루는 방법을 설명한다.

> Asciidoc은 문서 포맷이다. Asciidoctor는 Asciidoc 파일로(`.adoc`으로 끝나는) 컨텐츠를(보통 HTML) 만드는 툴이다.

---

## 6.1. Resources

- [문법 간단 설명](https://asciidoctor.org/docs/asciidoc-syntax-quick-reference)
- [사용자 메뉴얼](https://asciidoctor.org/docs/user-manual)

---

## 6.2. Including Snippets

이번 섹션은 Asciidoc 스니펫을 include하는 방법을 다룬다.

### 6.2.1. Including Multiple Snippets for an Operation

`operation` 매크로를 사용하면 특정 연산에 대해 만들어진 스니펫 전체 혹은 일부를 임포트할 수 있다. 프로젝트 [빌드 설정](../gettingstarted#23-build-configuration)에 `spring-restdocs-asciidoctor`를 추가하면 된다.

매크로 타겟은 연산 이름이다. 다음 예제에 보이듯이, 가장 간단하게는 매크로로 특정 연산에 해당하는 모든 스니펫을 추가할 수 있다:

```
operation::index[]
```

operation 매크로는 `snippets` 속성도 지원한다. `snippets` 속성으로는 포함할 스니펫을 선택한다. 속성 값은 쉼표로 구분한다. 리스트의 각 항목은 포함시킬 스니펫 파일 이름이어야 한다 (`.adoc`은 빼고). 예를 들어 다음 예제처럼 curl, HTTP 요청, HTTP 응답 스니펫만 포함할 수 있다:

```
operation::index[snippets='curl-request,http-request,http-response']
```

위 예제는 다음과 동일하다:

```adoc
[[example_curl_request]]
== Curl request

include::{snippets}/index/curl-request.adoc[]

[[example_http_request]]
== HTTP request

include::{snippets}/index/http-request.adoc[]

[[example_http_response]]
== HTTP response

include::{snippets}/index/http-response.adoc[]
```

#### Section Titles

`operation` 매크로로 추가한 각 스니펫에는 제목과 함께 섹션이 만들어진다. 아래 있는 내장 스니펫은 디폴트 제목을 제공한다:

| Snippet           | Title           |
| :---------------- | :-------------- |
| `curl-request`    | Curl Request    |
| `http-request`    | HTTP request    |
| `http-response`   | HTTP response   |
| `httpie-request`  | HTTPie request  |
| `links`           | Links           |
| `request-body`    | Request body    |
| `request-fields`  | Request fields  |
| `response-body`   | Response body   |
| `response-fields` | Response fields |

위 테이블에 없는 스니펫은 `-` 문자를 공백으로, 첫 글자를 대문자로 바꾼 제목이 디폴트다. 예를 들어 `custom-snippet` 스니펫 제목은 "Custom snippet"이 된다.

디폴트 제목은 문서 속성으로 커스텀할 수 있다. 속성명은 `operation-{snippet}-title`이어야 한다. 예를 들어 `curl-request` 스니펫 제목을 "Example request"로 커스텀하려면 아래 속성을 사용하면 된다:

```
:operation-curl-request-title: Example request
```

### 6.2.2. Including Individual Snippets

[include 매크로](https://asciidoctor.org/docs/asciidoc-syntax-quick-reference/#include-files)로는 문서에 스니펫을 개별로 포함시킬 수 있다. 스니펫 출력 디렉토리는 `snippets` 속성으로 ([빌드 설정](../gettingstarted#23-build-configuration)에서 `spring-restdocs-asciidoctor`로 자동 세팅된) 참조할 수 있다. 다음은 그 방법을 보여준다:

```
include::{snippets}/index/curl-request.adoc[]
```

---

## 6.3. Customizing Tables

기본 설정에 테이블이 포함돼 있는 스니펫도 많다. 테이블 외향은 스니펫을 include시킬 때 설정을 추가하거나, 커스텀 스니펫 템플릿을 사용해 커스텀할 수 있다.

### 6.3.1. Formatting Columns

Asciidoctor는 다양한 [테이블 컬럼 포맷팅](https://asciidoctor.org/docs/user-manual/#cols-format)을 지원한다. 다음 예제에서 보이는 것 처럼, 테이블 내 컬럼 너비는 `cols` 속성으로 지정할 수 있다:

```
[cols="1,3"] // (1)
include::{snippets}/index/links.adoc[]
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 테이블 너비는 두 컬럼으로 쪼개지며, 두 번째 컬럼 너비가 첫 번째 컬럼보다 3배 크다.</small>

### 6.3.2. Configuring the Title

테이블 제목은 `.`으로 시작하는 라인으로 지정한다. 다음 예제를 참고해라:

```
.Links // (1)
include::{snippets}/index/links.adoc[]
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 테이블 제목은 `Links`가 된다.</small>

### 6.3.3. Avoiding Table Formatting Problems

Asciidoctor에서 테이블 셀을 구분할 땐 `|` 문자를 사용한다. 때문에 셀 컨텐츠에 `|` 문자를 사용한다면 문제가 될 수 있다. 이 문제는 `|`를 역슬래시로 이스케이프하면 해결된다 — 다시 말해, `|` 대신  `\|`를 사용해라.

모든 디폴트 Asciidoctor 스니펫 템플릿은 `tableCellContent`라는 Mustache 람다를 사용해서 자동으로 이스케이프해준다. 커스텀 템플릿에서도 이 람다를 사용하면 된다. 다음 예제는 셀 안에서 `description` 속성에 있는 `|` 문자를 이스케이프하는 방법을 보여준다:

```
| {% raw %}{{#tableCellContent}}{{description}}{{/tableCellContent}}{% endraw %}
```

### 6.3.4 Further Reading

좀 더 자세한 테이블 커스텀 방법은 [Asciidoctor 사용자 메뉴얼에 있는 테이블 섹션](https://asciidoctor.org/docs/user-manual/#tables)을 참고해라.