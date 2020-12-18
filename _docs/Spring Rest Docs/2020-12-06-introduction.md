---
title: Introduction
category: Spring REST Docs
order: 2
permalink: /Spring%20REST%20Docs/introduction/
description: 스프링 REST Docs 소개 한글 번역
priority: 0.7
image: ./../../images/springrestdocs/logo.png
lastmod: 2020-12-19T00:00:00+09:00
comments: true
originalRefName: 스프링 REST Docs
originalRefLink: https://docs.spring.io/spring-restdocs/docs/2.0.5.RELEASE/reference/html5/#introduction
---

스프링 Rest Docs는 RESTful 서비스 문서를 정확하면서도 읽기 쉽게 만드는 것을 목표로 한다.

질 좋은 문서를 작성하기란 어려운 일이다. 적합한 도구를 활용하는 것도 어려움을 극복할 수 있는 한 가지 방법이다. 같은 맥락으로 스프링 Rest Docs는 기본적으로 [Asciidoctor](https://asciidoctor.org/)를 사용한다. Asciidoctor는 일반 텍스트를 처리해서 필요에 맞게 스타일과 레이아웃을 지정한 HTML을 만든다. 원한다면 Markdown을 사용하도록 설정할 수도 있다.

스프링 Rest Docs는 스프링 MVC의 [테스트 프레임워크](https://docs.spring.io/spring-framework/docs/5.0.x/spring-framework-reference/testing.html#spring-mvc-test-framework)나, 스프링 웹플럭스의 [WebTestClient](https://docs.spring.io/spring-framework/docs/5.0.x/spring-framework-reference/testing.html#webtestclient), [REST Assured 3](http://rest-assured.io/)로 작성한 테스트 코드를 사용한다. 이렇게 테스트 중심으로 접근하면 서비스 문서의 정확성을 보장하는 데 보탬이 된다. 올바르지 않은 스니펫을 생성한 테스트는 실패하기 때문이다.

RESTful 서비스 문서를 작성한다는 것은 보통 해당 리소스를 설명한다는 뜻이다. 각 리소스 문서에서 핵심은 컨슈밍할 HTTP 요청과 생산하는 HTTP 응답에 대한 디테일이다. 스프링 Rest Docs는 이 리소스와 HTTP 요청, 응답을 사용해서 문서를 작성하면서도, 내부에 있는 상세 구현 정보를 문서에서 가려준다. 이렇게 분리함으로써 서비스 구현보다는 서비스 API 자체를 문서화할 수 있다. 뿐만 아니라 문서를 재작성하지 않고도 실제 구현 코드를 개선할 수도 있다.