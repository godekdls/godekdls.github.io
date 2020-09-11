---
title: Prerequisites
category: Spring Security
order: 2
permalink: /Spring%20Security/prerequisites/
description: 스프링 시큐리티에서 요구하는 환경을 설명합니다. 공식 문서에 있는 "prerequisites" 챕터를 한글로 번역한 문서입니다.
image: ./../../images/springsecurity/spring-security.png
lastmod: 2020-08-21T21:30:00+09:00
comments: true
boundary: Preface
originalRefName: 스프링 시큐리티
originalRefLink: https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#prerequisites
---

---

스프링 시큐리티를 실행하려면 자바 8 이상의 환경이 필요하다.

스프링 시큐리티는 독립적인 운용을 지향하기 때문에 자바 런타임 환경에 별도의 설정 파일을 추가하지 않아도 된다. 특히, 특정 Java Authentication and Authorization Service (JAAS) 정책 파일을 설정한다거나 공통 클래스패스에 스프링 시큐리티를 추가한다거나 하는 작업은 불필요하다.

유사하게 EJB 컨테이너나 서블릿 컨테이너를 사용하더라도, 설정 파일을 추가하거나 서버 클래스 로더에 스프링 시큐리티를 포함시키지 않아도 된다. 필요한 모든 파일은 어플리케이션에 포함될 것이다.

타겟 아티팩트를 (JAR든 WAR든 EAR이든 간에) 다른 시스템으로 복사하면 즉시 동작하게 설계했기 때문에 배포 시간의 유연성을 극대화할 수 있다.
