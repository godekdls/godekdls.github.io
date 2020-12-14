---
title: What is R2DBC?
category: Spring Data R2DBC
order: 3
permalink: /Spring%20Data%20R2DBC/whatisr2dbc/
description: R2DBC 기본 개념
image: ./../../images/spring/logo.png
lastmod: 2020-12-10T12:00:00+09:00
comments: true
originalRefName: 스프링 데이터 R2DBC
originalRefLink: https://docs.spring.io/spring-data/r2dbc/docs/1.2.2/reference/html/#get-started:first-steps:what
---

---

[R2DBC](https://r2dbc.io/)는 Reactive Relational Database Connectivity의 줄임말이다. R2DBC는 드라이버 벤더가 관계형 데이터베이스 접근을 위해 구현해야 할, 리액티브 API를 선언한 API 스펙 이니셔티브다.

R2DBC가 탄생한 이유 중 하나는 적은 스레드로 동시 처리를 제어하고 적은 하드웨어 리소스로 확장하기 위해 논블로킹 어플리케이션 스택이 필요했기 때문이다. 표준화된 관계형 데이터베이스 접근 API는 — 즉, JDBC — 완전한 블로킹 API이므로, JDBC만으로는 이 문제를 해결할 수 없다. `ThreadPool`로 블로킹 동작을 절충하려고 해도 크게 도움이 되지 않는다.

또 다른 이유는 대다수 어플리케이션이 관계형 데이터베이스에 데이터를 저장하기 때문이다. NoSQL 벤더는 많이들 자체 리액티브 데이터베이스 클라이언트를 제공하고 있지만, 대부분 NoSQL로 마이그레이션하긴 힘든 환경이다. 이런 점 때문에 어떤 논블로킹 관계형 데이터베이스 드라이버와도 잘 동작하는 새 공통 API를 만들게 됐다. 오픈 소스 생태계에선 다양한 논블로킹 관계형 데이터베이스 드라이버 구현체를 호스팅하지만, 클라이언트는 벤더별로 다른 API로 제공하기 때문에, 이것만으론 모든 라이브러리 위에서 동작하는 범용 레이어를 만들 순 없다.