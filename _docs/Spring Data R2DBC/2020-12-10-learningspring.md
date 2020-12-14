---
title: Learning Spring
category: Spring Data R2DBC
order: 2
permalink: /Spring%20Data%20R2DBC/learningspring/
description: 스프링 데이터 R2DBC를 사용하기 앞서 필요한 스프링 관련 지식
image: ./../../images/spring/logo.png
lastmod: 2020-12-10T12:00:00+09:00
comments: true
boundary: Preface
originalRefName: 스프링 데이터 R2DBC
originalRefLink: https://docs.spring.io/spring-data/r2dbc/docs/1.2.2/reference/html/#get-started:first-steps:spring
---

---

## Preface

스프링 데이터 R2DBC는 관계형 데이터베이스 전용 [R2DBC](https://r2dbc.io/) 드라이버 솔루션에 핵심 스프링 컨셉을 적용해 개발한 프로젝트다. 행을 저장하고 질의하는 로직을 고수준으로 추상화한 `DatabaseClient`를 제공한다.

이 문서는 스프링 데이터 - R2DBC 지원에 대한 레퍼런스 가이드다. R2DBC 모듈 개념과 의미를 설명한다.

이 섹션에선 스프링과 데이터베이스 기본 개념을 소개한다.

---

스프링 데이터는 다음과 같은 스프링 프레임워크 [핵심](https://docs.spring.io/spring/docs/5.3.2/reference/html/core.html) 기능을 사용한다:

- [IoC](https://docs.spring.io/spring/docs/5.3.2/reference/html/core.html#beans) 컨테이너
- [타입 변환 시스템](https://docs.spring.io/spring/docs/5.3.2/reference/html/core.html#validation)
- [expression language](https://docs.spring.io/spring/docs/5.3.2/reference/html/core.html#expressions)
- [JMX 통합](https://docs.spring.io/spring/docs/5.3.2/reference/html/integration.html#jmx)
- [DAO exception 계층구조](https://docs.spring.io/spring/docs/5.3.2/reference/html/data-access.html#dao-exceptions)

스프링 API를 알아야 할 필욘 없지만, 그 뒤에 있는 개념은 알아두는 게 좋다. 최소한 제어의 역전(Inversion of Control, IOC)에 깔려 있는 발상은 이해하고 있어야 하며, 사용하려는 IoC 컨테이너에 익숙해야 한다.

스프링 컨테이너의 IoC 서비스를 실행하지 않고도 R2DBC 핵심 기능을 바로 사용할 수 있다. `JdbcTemplate`을 스프링 컨테이너의 다른 서비스없이 "독립형"으로 사용할 수 있는 것과 매우 유사하다. 레포지토리 지원 등 스프링 데이터 R2DBC의 모든 기능을 사용하려면, 일부 라이브러리는 스프링을 사용하도록 설정해야 한다.

스프링에 대해 자세히 알고 싶다면, 스프링 프레임워크를 포괄적으로 다루는 문서를 찾아봐라. 이 주제와 관련된 아티클과 블로그 문서, 책도 많이 있다. 자세한 정보는 스프링 프레임워크 [홈페이지](https://spring.io/docs)를 참고해라.