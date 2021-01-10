---
title: New & Noteworthy
category: Spring Data R2DBC
order: 10
permalink: /Spring%20Data%20R2DBC/newandnoteworthy/
description: 스프링 데이터 R2DBC 1.X 버전에서 추가된 기능들
image: ./../../images/spring/logo.png
lastmod: 2020-12-19T23:00:00+09:00
comments: true
originalRefName: 스프링 데이터 R2DBC
originalRefLink: https://docs.spring.io/spring-data/r2dbc/docs/1.2.2/reference/html/#new-features
---

### 목차

- [9.1. What’s New in Spring Data R2DBC 1.2.0](#91-whats-new-in-spring-data-r2dbc-120)
- [9.2. What’s New in Spring Data R2DBC 1.1.0](#92-whats-new-in-spring-data-r2dbc-110)
- [9.3. What’s New in Spring Data R2DBC 1.0.0](#93-whats-new-in-spring-data-r2dbc-100)

---

## 9.1. What’s New in Spring Data R2DBC 1.2.0

- 스프링 데이터 R2DBC `DatabaseClient` deprecate, 스프링 R2DBC에서 deprecated API를 제거. 자세한 내용은 [마이그레이션 가이드](https://docs.spring.io/spring-data/r2dbc/docs/1.2.2/reference/html/#upgrading.1.1-1.2) 참고.
- [엔티티 콜백](../r2dbcrepositories#143-entity-callbacks) 지원.
- `@EnableR2dbcAuditing`을 통한 [Auditing](../auditing#152-general-auditing-configuration-for-r2dbc).
- persistence 생성자에 `@Value` 지원.

---

## 9.2. What’s New in Spring Data R2DBC 1.1.0

- 엔티티 기반 연산을 지원하는 `R2dbcEntityTemplate` 도입
- [쿼리 파생(Query derivation)](../r2dbcrepositories#142-query-methods).
- `DatabaseClient.as(…)`를 통한 인터페이스 projection 지원.
- [`DatabaseClient.filter(…)`를 통한 `ExecuteFunction`, `StatementFilterFunction` 지원](https://docs.spring.io/spring-data/r2dbc/docs/1.1.0.RELEASE/reference/html/#r2dbc.datbaseclient.filter).

---

## 9.3. What’s New in Spring Data R2DBC 1.0.0

- R2DBC 0.8.0.RELEASE로 업그레이드.
- 영향 받은 row 카운트를 컨슘하기 위한 쿼리 메소드 어노테이션 `@Modifying`.
- 데이터베이스에 없는 ID를 지정해 레포지토리 `save(…)`를 호출하면 `TransientDataAccessException`으로 종료.
- 커넥션 싱글톤으로 테스트할 수 있는 `SingleConnectionConnectionFactory` 추가.
- `@Query`에서 [SpEL 표현식](https://docs.spring.io/spring/docs/5.3.2/reference/html/core.html#expressions) 지원.
- `AbstractRoutingConnectionFactory`를 통한 `ConnectionFactory` 라우팅.
- `ResourceDatabasePopulator`와 `ScriptUtils`를 이용한 스키마 초기화 유틸리티.
- `TransactionDefinition`을 통한 자동 커밋 전파/리셋과 격리 수준 제어.
- 엔티티 레벨 컨버터 지원.
- reified 제네릭과 [코루틴](../kotlinsupport#175-coroutines)을 위한 코틀린 익스텐션.
- 방언(dialect)을 직접 등록할 수 있는 메커니즘 추가.
- 파라미터 이름 지정 (named 파라미터) 지원.
- `DatabaseClient`를 통한 R2DBC 첫 지원.
- `TransactionalDatabaseClient`를 통한 트랜잭션 첫 지원.
- `R2dbcRepository`를 통한 R2DBC 레포지토리 첫 지원.
- Postgres와 마이크로소프트 SQL 서버 용 방언(Dialect) 최초 지원.