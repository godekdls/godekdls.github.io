---
title: Working with Markdown
category: Spring REST Docs
order: 8
permalink: /Spring%20REST%20Docs/workingwithmarkdown/
description: 스프링 REST Doc에서 Markdown 다루기 한글 번역
image: ./../../images/springrestdocs/logo.png
lastmod: 2020-12-08T12:00:00+09:00
comments: true
originalRefName: 스프링 REST Docs
originalRefLink: https://docs.spring.io/spring-restdocs/docs/2.0.5.RELEASE/reference/html5/#working-with-markdown
---

### 목차

- [7.1. Limitations](#71-limitations)
- [7.2. Including Snippets](#72-including-snippets)

---

이번 섹션에선 스프링 REST Doc과 관련해서 필요한 Markdown을 다루는 방법을 설명한다.

---

## 7.1. Limitations

Markdown은 본래 웹 전용 문서를 작성하기 위해 설계했기 때문에, Asciidoctor만큼 문서 작성에 적합하진 않다. 보통은 Markdown 위에 다른 툴을 빌드하는 식으로 이 한계를 극복하곤 한다.

Markdown은 공식적으로 테이블을 지원하지 않는다. 스프링 REST Doc의 디폴트 Markdown 스니펫 템플릿에선 [Markdown Extra의 테이블 포맷](https://michelf.ca/projects/php-markdown/extra/#table)을 사용한다.

## 7.2. Including Snippets

Markdown 내장 기능 중에는 Markdown 파일을 다른 파일에 include하는 기능이 없다. 생성한 Markdown 스니펫을 문서에 포함시키려면, 이 기능을 지원하는 다른 툴이 필요하다. API 문서화에 적합한 한 가지 예시로는 [Slate](https://github.com/tripit/slate)가 있다.