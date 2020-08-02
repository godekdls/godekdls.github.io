---
title: About the Document
category: Reactor Core
order: 2
permalink: /Reactor%20Core/aboutthedocument/
description: 리액터 코어 문서 소개 한글 번역
image: ./../../images/reactorcore/flux.png
lastmod: 2020-07-12T21:00:00+09:00
comments: true
---

> [프로젝트 리액터 코어 공식 reference](https://projectreactor.io/docs/core/release/reference/#about-doc)를 한글로 번역한 문서입니다.
>
> 전체 목차는 [여기](../contents/)에 있습니다.


### 목차

- [1.1. Latest Version & Copyright Notice](#11-latest-version--copyright-notice)
- [1.2. Contributing to the Documentation](#12-contributing-to-the-documentation)
- [1.3. Getting Help](#13-getting-help)
- [1.4. Where to Go from Here](#14-where-to-go-from-here)

---

이번 섹션에서는 리액터 레퍼런스 문서에 대해 간단히 설명한다. 모든 설명을 순서대로 읽을 필요는 없다. 각 내용은 챕터로 나눠서 설명하지만 다른 챕터의 링크를 종종 참조할 것이다.

---

## 1.1. Latest Version & Copyright Notice

리액터 레퍼런스 가이드는 HTML 문서를 제공한다. 최신 버전은 [여기](https://projectreactor.io/docs/core/release/reference/index.html)에서 확인할 수 있다.

이 문서 사본을 직접 만들어서 다른 사람에게 배포할 수 는 있지만, 문서에 대해 비용을 청구해선 안 되며, 배포 형식이 인쇄물이든 디지털 파일이던지 관계없이 저작권 표시를 포함해야 한다.

---

## 1.2. Contributing to the Documentation

레퍼런스 가이드는 [Asciidoc](https://asciidoctor.org/docs/asciidoc-writers-guide/)으로 작성되었으며, 소스 파일은 [여기](https://github.com/reactor/reactor-core/tree/master/docs/asciidoc)에서 확인할 수 있다.

개선할 점이나 제안하고 싶은 게 있다면 언제든지 pull request를 생성해 달라.

레포지토리 로컬 사본을 체크아웃 받아서 `asciidoctor` 그래들 태스크를 실행해 직접 문서를 생성하고 렌더링을 확인해보길 권한다. 일부 섹션은 레포지토리 내 파일을 참조하고 있기 때문에 GitHub 렌더링이 깨질 가능성도 있다.

> 섹션 대부분은 쉽게 수정할 수 있도록 마지막에 해당 섹션의 깃허브 소스 파일을 수정하는 UI 링크가 있다. 이 링크는 HTML5 버전 레퍼런스 가이드에만 있다. 예를 들어: [About the Documentation](https://projectreactor.io/docs/core/release/reference/#about-doc) [수정 제안하기](https://github.com/reactor/reactor-core/edit/master/docs/asciidoc/aboutDoc.adoc).

---

## 1.3. Getting Help

리액터를 사용하다 도움이 필요하다면:

- [Gitter](https://gitter.im/reactor/reactor) 커뮤니티를 이용하라.
- stackoverflow.com([`project-reactor`](https://stackoverflow.com/tags/project-reactor))에 질문해라.
- 버그 리포트는 깃허브 이슈에 올려라. 이 레포지토리는 면밀히 모니터링하고 있다: [reactor-core](https://github.com/reactor/reactor-core/issues) (주요 피쳐 관련 이슈), [reactor-addons](https://github.com/reactor/reactor-addons/issues) (reactor-test와 어댑터 관련 이슈)

> [이 문서를 포함한](https://github.com/reactor/reactor-core/tree/master/docs/asciidoc) 모든 리액터 프로젝트는 오픈 소스다. 문서에 문제가 있거나 개선하고 싶은 점이 있다면 리액터에 [컨트리뷰트](https://github.com/reactor/.github/blob/master/CONTRIBUTING.md)할 수 있다.

---

## 1.4. Where to Go from Here

- 코드로 바로 넘어가고 싶다면 [Getting Started](../gettingstarted)로 이동하라.
- 리액티브 프로그램이 처음이라면 [Introduction to Reactive Programming](../introductiontoreactiveprogramming)부터 시작하라.
- 리액터 개념에 익숙하고 적절한 툴을 찾고 있지만, 관련 오퍼레이터를 잘 모르겠다면 [Which operator do I need?](https://projectreactor.io/docs/core/release/reference/#which-operator) 부록을 참고하라.
- 리액터의 핵심 기능을 자세히 알고 싶다면 [Reactor Core Features](../reactorcorefeatures)로 이동해서 다음을 학습하라:
  - 리액터의 리액티브 타입에 대한 자세한 내용 ([`Flux`, an Asynchronous Sequence of 0-N Items](../reactorcorefeatures#41-flux-an-asynchronous-sequence-of-0-n-items), [`Mono`, an Asynchronous 0-1 Result](../reactorcorefeatures/#42-mono-an-asynchronous-0-1-result) 섹션).
  - [스케줄러](https://projectreactor.io/docs/core/release/reference/#schedulers)로 스레드 컨텍스트를 전환하는 방법.
  - 에러를 핸들링하는 방법 ([Handling Errors](../reactorcorefeatures/#46-handling-errors) 섹션).
- 단위 테스트? `reactor-test` 프로젝트가 있다면 가능하다! [Testing](../testing)을 참고하라.
- [Programmatically creating a sequence](../reactorcorefeatures/#44-programmatically-creating-a-sequence)에서는 리액티브 리소스를 생성하는 고급 방식을 자세히 다룬다.
- 다른 고급 주제는 [Advanced Features and Concepts](../advancedfeaturesandconcepts)에서 다룬다.

"[About the Documentation](https://projectreactor.io/docs/core/release/reference/#about-doc)" [수정 제안하기](https://github.com/reactor/reactor-core/edit/master/docs/asciidoc/aboutDoc.adoc)

---

> 전체 목차는 [여기](../contents/)에 있습니다.

