---
title: Data Access with JDBC
category: Spring Data Access
order: 4
permalink: /Spring%20Data%20Access/dataaccesswithjdbc/
description: 스프링 프레임워크 JDBC 레퍼런스를 한국어로 번역한 문서입니다. 스프링 프레임워크 JDBC 패키지 구조를 간단하게 정리하고, JdbcTemplate, NamedParameterJdbcTemplate, SimpleJdbc, StoredProcedure 등의 사용법을 다룹니다.
image: ./../../images/spring/logo.png
lastmod: 2021-01-10T23:00:00+09:00
comments: true
priority: 0.7
originalRefName: 스프링 프레임워크 데이터 액세스
originalRefLink: https://docs.spring.io/spring-framework/docs/5.3.2/reference/html/data-access.html#jdbc
---
<script>defaultLanguages = ['java']</script>

### 목차

- [3.1. Choosing an Approach for JDBC Database Access](#31-choosing-an-approach-for-jdbc-database-access)
- [3.2. Package Hierarchy](#32-package-hierarchy)
- [3.3. Using the JDBC Core Classes to Control Basic JDBC Processing and Error Handling](#33-using-the-jdbc-core-classes-to-control-basic-jdbc-processing-and-error-handling)
  + [3.3.1. Using JdbcTemplate](#331-using-jdbctemplate)
    * [Querying (SELECT)](#querying-select)
    * [Updating (INSERT, UPDATE, and DELETE) with JdbcTemplate](#updating-insert-update-and-delete-with-jdbctemplate)
    * [Other JdbcTemplate Operations](#other-jdbctemplate-operations)
    * [JdbcTemplate Best Practices](#jdbctemplate-best-practices)
  + [3.3.2. Using NamedParameterJdbcTemplate](#332-using-namedparameterjdbctemplate)
  + [3.3.3. Using SQLExceptionTranslator](#333-using-sqlexceptiontranslator)
  + [3.3.4. Running Statements](#334-running-statements)
  + [3.3.5. Running Queries](#335-running-queries)
  + [3.3.6. Updating the Database](#336-updating-the-database)
  + [3.3.7. Retrieving Auto-generated Keys](#337-retrieving-auto-generated-keys)
- [3.4. Controlling Database Connections](#34-controlling-database-connections)
  + [3.4.1. Using DataSource](#341-using-datasource)
  + [3.4.2. Using DataSourceUtils](#342-using-datasourceutils)
  + [3.4.3. Implementing SmartDataSource](#343-implementing-smartdatasource)
  + [3.4.4. Extending AbstractDataSource](#344-extending-abstractdatasource)
  + [3.4.5. Using SingleConnectionDataSource](#345-using-singleconnectiondatasource)
  + [3.4.6. Using DriverManagerDataSource](#346-using-drivermanagerdatasource)
  + [3.4.7. Using TransactionAwareDataSourceProxy](#347-using-transactionawaredatasourceproxy)
  + [3.4.8. Using DataSourceTransactionManager](#348-using-datasourcetransactionmanager)
- [3.5. JDBC Batch Operations](#35-jdbc-batch-operations)
  + [3.5.1. Basic Batch Operations with JdbcTemplate](#351-basic-batch-operations-with-jdbctemplate)
  + [3.5.2. Batch Operations with a List of Objects](#352-batch-operations-with-a-list-of-objects)
  + [3.5.3. Batch Operations with Multiple Batches](#353-batch-operations-with-multiple-batches)
- [3.6. Simplifying JDBC Operations with the SimpleJdbc Classes](#36-simplifying-jdbc-operations-with-the-simplejdbc-classes)
  + [3.6.1. Inserting Data by Using SimpleJdbcInsert](#361-inserting-data-by-using-simplejdbcinsert)
  + [3.6.2. Retrieving Auto-generated Keys by Using SimpleJdbcInsert](#362-retrieving-auto-generated-keys-by-using-simplejdbcinsert)
  + [3.6.3. Specifying Columns for a SimpleJdbcInsert](#363-specifying-columns-for-a-simplejdbcinsert)
  + [3.6.4. Using SqlParameterSource to Provide Parameter Values](#364-using-sqlparametersource-to-provide-parameter-values)
  + [3.6.5. Calling a Stored Procedure with SimpleJdbcCall](#365-calling-a-stored-procedure-with-simplejdbccall)
  + [3.6.6. Explicitly Declaring Parameters to Use for a SimpleJdbcCall](#366-explicitly-declaring-parameters-to-use-for-a-simplejdbccall)
  + [3.6.7. How to Define SqlParameters](#367-how-to-define-sqlparameters)
  + [3.6.8. Calling a Stored Function by Using SimpleJdbcCall](#368-calling-a-stored-function-by-using-simplejdbccall)
  + [3.6.9. Returning a ResultSet or REF Cursor from a SimpleJdbcCall](#369-returning-a-resultset-or-ref-cursor-from-a-simplejdbccall)
- [3.7. Modeling JDBC Operations as Java Objects](#37-modeling-jdbc-operations-as-java-objects)
  + [3.7.1. Understanding SqlQuery](#371-understanding-sqlquery)
  + [3.7.2. Using MappingSqlQuery](#372-using-mappingsqlquery)
  + [3.7.3. Using SqlUpdate](#373-using-sqlupdate)
  + [3.7.4. Using StoredProcedure](#374-using-storedprocedure)
- [3.8. Common Problems with Parameter and Data Value Handling](#38-common-problems-with-parameter-and-data-value-handling)
  + [3.8.1. Providing SQL Type Information for Parameters](#381-providing-sql-type-information-for-parameters)
  + [3.8.2. Handling BLOB and CLOB objects](#382-handling-blob-and-clob-objects)
  + [3.8.3. Passing in Lists of Values for IN Clause](#383-passing-in-lists-of-values-for-in-clause)
  + [3.8.4. Handling Complex Types for Stored Procedure Calls](#384-handling-complex-types-for-stored-procedure-calls)
- [3.9. Embedded Database Support](#39-embedded-database-support)
  + [3.9.1. Why Use an Embedded Database?](#391-why-use-an-embedded-database)
  + [3.9.2. Creating an Embedded Database by Using Spring XML](#392-creating-an-embedded-database-by-using-spring-xml)
  + [3.9.3. Creating an Embedded Database Programmatically](#393-creating-an-embedded-database-programmatically)
  + [3.9.4. Selecting the Embedded Database Type](#394-selecting-the-embedded-database-type)
    * [Using HSQL](#using-hsql)
    * [Using H2](#using-h2)
    * [Using Derby](#using-derby)
  + [3.9.5. Testing Data Access Logic with an Embedded Database](#395-testing-data-access-logic-with-an-embedded-database)
  + [3.9.6. Generating Unique Names for Embedded Databases](#396-generating-unique-names-for-embedded-databases)
  + [3.9.7. Extending the Embedded Database Support](#397-extending-the-embedded-database-support)
- [3.10. Initializing a DataSource](#310-initializing-a-datasource)
  + [3.10.1. Initializing a Database by Using Spring XML](#3101-initializing-a-database-by-using-spring-xml)
    * [Initialization of Other Components that Depend on the Database](#initialization-of-other-components-that-depend-on-the-database)
    
---

스프링 프레임워크 JDBC 추상화가 제공하는 편의는 아래 테이블에 요약한 작업 시퀀스를 보면 제일 잘 알 수 있을 거다. 이 테이블은 스프링이 처리하는 작업과 직접 처리해야 하는 작업을 나타내고 있다.

**Table 4. Spring JDBC - who does what?**

| Action                                         | Spring | You  |
| :--------------------------------------------- | :----: | :--: |
| 커넥션 파라미터 정의                           |        |  X   |
| 커넥션 오픈                                    |   X    |      |
| SQL 문 지정                                    |        |  X   |
| 파라미터 선언과 파리미터 값 제공               |        |  X   |
| SQL 구문을 준비하고 실행                       |   X    |      |
| (결과가 있다면) 결과를 반복 처리할 반복문 세팅 |   X    |      |
| 각 이터레이션 처리                             |        |  X   |
| 모든 예외 처리                                 |   X    |      |
| 트랜잭션 처리                                  |   X    |      |
| 커넥션, 구문, resultset 종료                   |   X    |      |

스프링 프레임워크는 JDBC에서 필요한, 지루할 수도 있는 저수준 로직을 전부 대신 처리해준다.

---

## 3.1. Choosing an Approach for JDBC Database Access

JDBC 데이터베이스에 접근할 땐 여러 가지 방법 중에서 고를 수 있다. 세 가지 성격의 API를 제공하는 `JdbcTemplate` 외에도, 새로 도입된 `SimpleJdbcInsert`와 `SimpleJdbcCall`은 데이터베이스 메타데이터를 최적화해주며, RDBMS 객체는 JDO 쿼리 디자인과 유사하면서도 더 객체 지향적인 방식으로 접근한다. 이 중 하나를 사용하기로 했더라도 다른 방식에 있는 기능도 함께 조합할 수 있다. 모든 방식에는 JDBC 2.0 호환 드라이버가 필요하며, 일부 고급 기능에는 JDBC 3.0 드라이버가 필요하다.

- `JdbcTemplate`은 스프링 JDBC에서 가장 많이 사용하는 대표적인 클래스다. "가장 저수준"에서 동작하며, 다른 방식에서도 모두 내부에서 `JdbcTemplate`을 사용한다.
- `NamedParameterJdbcTemplate`은 `JdbcTemplate`을 래핑해서 전통적인 JDBC `?` 플레이스홀더를 대신할 수 있는 named 파라미터를 제공한다. SQL 구문에 파라미터가 여러 개 있을 때 `NamedParameterJdbcTemplate`을 사용하면 훨씬 간편하고 문서화하기도 쉽다.
- `SimpleJdbcInsert`와 `SimpleJdbcCall`은 데이터베이스 메타데이터를 최적화해 필요한 설정을 최소화해준다. 코드를 단순화해주기 때문에, 테이블이나 프로시저 이름과 컬럼명과 일치하는 파라미터 맵만 제공하면 된다. 단, 최적화는 데이터베이스가 충분한 메타데이터를 제공하는 경우에만 동작한다. 메타데이터를 제공하지 않는 데이터베이스에선 파라미터 설정을 명시해야 한다.
- RDBMS 객체(`MappingSqlQuery`, `SqlUpdate`, `StoredProcedure`)를 사용하려면 데이터 접근 레이어를 초기화할 때 재사용 가능하고 thread-safe한 객체를 만들어야 한다. 어딘가에 쿼리 문자열을 정의하고, 파라미터를 선언하고, 쿼리를 컴파일하는 JDO 쿼리를 본따온 방법이다. 이렇게하면 `execute(…)`, `update(…)`, `findObject(…)` 메소드를 다양한 파라미터 값으로 여러 번 반복 호출할 수 있다.

---

## 3.2. Package Hierarchy

스프링의 JDBC 추상화 프레임워크엔 네 종류의 패키지가 있다:

- `core`: <span class="custom-blockquote">org.springframework.jdbc.core</span> 패키지엔 `JdbcTemplate` 클래스와, 템플릿에서 사용할 여러 가지 콜백 인터페이스, 이와 관련된 다양한 클래스가 들어있다. 하위 패키지 <span class="custom-blockquote">org.springframework.jdbc.core.simple</span>엔 `SimpleJdbcInsert`와 `SimpleJdbcCall` 클래스가 있다. 또 다른 하위 패키지 <span class="custom-blockquote">org.springframework.jdbc.core.namedparam</span>엔 `NamedParameterJdbcTemplate` 클래스와 관련 클래스가 들어있다. [JDBC 코어 클래스로 기본 JDBC 동작과 에러 처리 제어하기](#33-using-the-jdbc-core-classes-to-control-basic-jdbc-processing-and-error-handling), [JDBC 배치 연산](#35-jdbc-batch-operations), [`SimpleJdbc` 클래스로 JDBC 연산 단순화하기](#36-simplifying-jdbc-operations-with-the-simplejdbc-classes)를 참고해라.
- `datasource`: <span class="custom-blockquote">org.springframework.jdbc.datasource</span> 패키지엔 `DataSource` 접근을 위한 유틸리티 클래스와, JDBC 코드를 수정하지 않고 그대로 Java EE 컨테이너 외부에서 테스트하고 실행할 수 있는 간단한 `DataSource` 구현체가 다양하게 준비돼 있다. 하위 패키지 <span class="custom-blockquote">org.springfamework.jdbc.datasource.embedded</span> 패키지에선 HSQL, H2, Derby같은 자바 데이터베이스 엔진을 사용한 임베디드 데이터베이스 생성을 지원한다. [데이터베이스 커넥션 제어하기](#34-controlling-database-connections)와 [임베디드 데이터베이스 지원](#39-embedded-database-support)을 참고해라.
- `object`: <span class="custom-blockquote">org.springframework.jdbc.object</span> 패키지엔 RDBMS 쿼리, 업데이트, 저장 프로시저를 thread-safe하고 재사용 가능한 객체로 설계할 수 있는 클래스가 들어있다. [JDBC 연산을 자바 객체로 모델링하기](#37-modeling-jdbc-operations-as-java-objects)를 참고해라. JDO에서 본따왔지만, 이때는 쿼리가 객체를 반환하면 저절로 데이터베이스 커넥션이 닫힌다. 여기서 추상화한 JDBC 객체는 좀 더 저수준에 있는 <span class="custom-blockquote">org.springframework.jdbc.core</span> 패키지의 추상화에 의존한다.
- `support`: <span class="custom-blockquote">org.springframework.jdbc.support</span> 패키지는 `SQLException` 변환 기능과 유틸리티 클래스를 몇 가지 제공한다. JDBC 처리 중에 던져진 예외는 <span class="custom-blockquote">org.springframework.dao</span> 패키지에 정의된 예외로 변환된다. 이 말은, 스프링 JDBC 추상화 레이어를 사용하는 코드는 JDBC나 RDBMS 전용 에러 처리를 구현할 필요가 없다는 뜻이다. 변환된 예외는 모두 unchecked exception이므로, 복구할 수 있는 예외만 캐치하고 나머지는 호출한 쪽으로 전파되도록 놔둘 수 있다. [`SQLExceptionTranslator` 사용하기](#333-using-sqlexceptiontranslator)를 참고해라.

---

## 3.3. Using the JDBC Core Classes to Control Basic JDBC Processing and Error Handling

이번 섹션에선 JDBC 코어 클래스로 에러 처리를 포함한 기본 JDBC 동작을 제어하는 방법을 설명한다. 여기서는 다음과 같은 주제를 다룬다:

- [`JdbcTemplate` 사용하기](#331-using-jdbctemplate)
- [`NamedParameterJdbcTemplate` 사용하기](#332-using-namedparameterjdbctemplate)
- [`SQLExceptionTranslator` 사용하기](#333-using-sqlexceptiontranslator)
- [구문 실행하기](#334-running-statements)
- [쿼리 실행하기](#335-running-queries)
- [데이터베이스 업데이트하기](#336-updating-the-database)
- [자동 생성한 키 가져오기](#337-retrieving-auto-generated-keys)

### 3.3.1. Using `JdbcTemplate`

`JdbcTemplate`은 JDBC 코어 패키지의 핵심 클래스다. 리소스 생성과 해제를 알아서 처리해주기 때문에 커넥션 종료를 잊는 등의 흔한 에러를 방지할 수 있다. 코어 JDBC 워크플로우의 기본 작업(구문 생성과 실행같은)을 수행하므로, 어플리케이션 코드에선 SQL을 제공하고 결과를 추출하기만 하면 된다. `JdbcTemplate` 클래스는 다음과 같은 작업을 수행한다:

- SQL 쿼리를 실행한다.
- 구문을 업데이트하고 저장 프로시저를 호출한다.
- `ResultSet` 인스턴스를 반복 처리하고 반환된 파라미터 값을 추출한다.
- JDBC exception을 잡아, `org.springframework.dao` 패키지에 있는 더 많은 정보를 제공하는 범용 exception 계층 구조로 변환한다. ([예외 계층 구조](../daosupport#21-consistent-exception-hierarchy) 참고.)

`JdbcTemplate`을 사용하기로 했다면, 콜백 인터페이스 동작만 정확하게 구현하면 된다. `PreparedStatementCreator` 콜백 인터페이스는 `JdbcTemplate` 클래스가 제공하는 `Connection`을 받아 SQL과 필요한 파라미터를 제공하는 prepared 구문을 만든다. callable 구문을 생성하는 `CallableStatementCreator` 인터페이스도 마찬가지다. `RowCallbackHandler` 인터페이스는 `ResultSet`에 있는 각 row에서 값을 추출한다.

`JdbcTemplate`은 DAO 구현체 안에서도 사용할 수 있다. 이 때는 `DataSource`를 참조해 직접 `JdbcTemplate` 인스턴스를 만들어도 되고, `JdbcTemplate`을 스프링 IoC 컨테이너 빈으로 설정해서 DAO에 주입해도 된다.

> `DataSource`는 항상 스프링 IoC 컨테이너의 빈으로 설정해야 한다. 첫 번째 케이스에선 DAO 서비스에 직접 `DataSource` 빈을 제공하며, 두 번째 케이스에선 `JdbcTemplate` 빈에 `DataSource` 빈을 제공한다.

`JdbcTemplate` 클래스가 발행한 모든 SQL은, 템플릿 인스턴스의 클래스 (보통은 `JdbcTemplate`이지만, `JdbcTemplate` 클래스를 상속한 커스텀 클래스를 사용하는 경우엔 다를 수 있음) 풀 네임에 해당하는 범주 아래 `DEBUG` 레벨 로그를 남긴다.

다음 섹션에선 `JdbcTemplate`을 사용하는 몇 가지 예제를 제공한다. 이 예제에서 보여주는 `JdbcTemplate` 기능이 전부는 아니다. 전체 기능은 [javadoc](https://docs.spring.io/spring-framework/docs/5.3.2/javadoc-api/org/springframework/jdbc/core/JdbcTemplate.html)을 참고해라.

#### Querying (`SELECT`)

아래 쿼리는 테이블의 row 수를 가져온다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
int rowCount = this.jdbcTemplate.queryForObject("select count(*) from t_actor", Integer.class);
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
val rowCount = jdbcTemplate.queryForObject<Int>("select count(*) from t_actor")!!
```

다음은 변수를 바인딩하는 쿼리다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
int countOfActorsNamedJoe = this.jdbcTemplate.queryForObject(
        "select count(*) from t_actor where first_name = ?", Integer.class, "Joe");
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
val countOfActorsNamedJoe = jdbcTemplate.queryForObject<Int>(
        "select count(*) from t_actor where first_name = ?", arrayOf("Joe"))!!
```

다음 쿼리는 `String`을 조회한다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
String lastName = this.jdbcTemplate.queryForObject(
        "select last_name from t_actor where id = ?",
        String.class, 1212L);
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
val lastName = this.jdbcTemplate.queryForObject<String>(
        "select last_name from t_actor where id = ?",
        arrayOf(1212L))!!
```

다음 쿼리는 단건을 조회해 도메인 객체에 값을 채운다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
Actor actor = jdbcTemplate.queryForObject(
        "select first_name, last_name from t_actor where id = ?",
        (resultSet, rowNum) -> {
            Actor newActor = new Actor();
            newActor.setFirstName(resultSet.getString("first_name"));
            newActor.setLastName(resultSet.getString("last_name"));
            return newActor;
        },
        1212L);
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
val actor = jdbcTemplate.queryForObject(
            "select first_name, last_name from t_actor where id = ?",
            arrayOf(1212L)) { rs, _ ->
        Actor(rs.getString("first_name"), rs.getString("last_name"))
    }
```

다음 쿼리는 도메인 객체 리스트에 값을 채운다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
List<Actor> actors = this.jdbcTemplate.query(
        "select first_name, last_name from t_actor",
        (resultSet, rowNum) -> {
            Actor actor = new Actor();
            actor.setFirstName(resultSet.getString("first_name"));
            actor.setLastName(resultSet.getString("last_name"));
            return actor;
        });
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
val actors = jdbcTemplate.query("select first_name, last_name from t_actor") { rs, _ ->
        Actor(rs.getString("first_name"), rs.getString("last_name"))
```

바로 위에 있는 두 코드를 함께 사용한다면 중복 `RowMapper` 람다 표현식을 단일 필드로 빼서, 필요에 따라 DAO 메소드에 넘기는 게 더 바람직하다. 예를 들어, 바로 위 코드는 아래처럼 작성하는 게 낫다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
private final RowMapper<Actor> actorRowMapper = (resultSet, rowNum) -> {
    Actor actor = new Actor();
    actor.setFirstName(resultSet.getString("first_name"));
    actor.setLastName(resultSet.getString("last_name"));
    return actor;
};

public List<Actor> findAllActors() {
return this.jdbcTemplate.query( "select first_name, last_name from t_actor", actorRowMapper);
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
val actorMapper = RowMapper<Actor> { rs: ResultSet, rowNum: Int ->
    Actor(rs.getString("first_name"), rs.getString("last_name"))
}

fun findAllActors(): List<Actor> {
    return jdbcTemplate.query("select first_name, last_name from t_actor", actorMapper)
}
```

#### Updating (`INSERT`, `UPDATE`, and `DELETE`) with `JdbcTemplate`

insert, update, delete 연산은 `update(..)` 메소드를 사용하면 된다. 파라미터 값은 보통 가변 인자나 객체 배열로 제공한다.

다음 예제는 새 엔트리를 삽입한다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
this.jdbcTemplate.update(
        "insert into t_actor (first_name, last_name) values (?, ?)",
        "Leonor", "Watling");
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
jdbcTemplate.update(
        "insert into t_actor (first_name, last_name) values (?, ?)",
        "Leonor", "Watling")
```

다음 예제는 기존 엔트리를 업데이트한다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
this.jdbcTemplate.update(
        "update t_actor set last_name = ? where id = ?",
        "Banjo", 5276L);
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
jdbcTemplate.update(
        "update t_actor set last_name = ? where id = ?",
        "Banjo", 5276L)
```

다음 예제는 엔트리를 삭제한다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
this.jdbcTemplate.update(
        "delete from t_actor where id = ?",
        Long.valueOf(actorId));
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
jdbcTemplate.update("delete from t_actor where id = ?", actorId.toLong())
```

#### Other `JdbcTemplate` Operations

`execute(..)` 메소드로는 모든 SQL을 실행할 수 있다. 그렇기 때문에 DDL 구문에 자주 사용된다. `execute(..)` 메소드는 콜백 인터페이스, 변수 배열 바인딩 등을 받는 오버로드 메소드가 아주 많다. 다음은 테이블을 생성하는 예제다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
this.jdbcTemplate.execute("create table mytable (id integer, name varchar(100))");
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
jdbcTemplate.execute("create table mytable (id integer, name varchar(100))")
```

다음 예제는 저장 프로시저를 실행한다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
this.jdbcTemplate.update(
        "call SUPPORT.REFRESH_ACTORS_SUMMARY(?)",
        Long.valueOf(unionId));
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
jdbcTemplate.update(
        "call SUPPORT.REFRESH_ACTORS_SUMMARY(?)",
        unionId.toLong())
```

저장 프로시저를 더 정교하게 다루는 법은 [뒤에서 다룬다](#374-using-storedprocedure).

#### `JdbcTemplate` Best Practices

`JdbcTemplate` 클래스는 인스턴스를 설정하고나면 thread-safe하다. 여기서 중요한 점은 설정에 `JdbcTemplate` 단일 인스턴스를 추가하고, DAO(또는 레포지토리) 여러 개에 같은 인스턴스 참조를 공유할 수 있다는 거다. `JdbcTemplate`은 `DataSource` 참조를 유지한다는 점에서는 stateful이지만, `DataSource`로 조회하는 커넥션은 스레드마다 독립적이다.

`JdbcTemplate` 클래스(그리고 관련 [`NamedParameterJdbcTemplate`](#332-using-namedparameterjdbctemplate) 클래스)를 사용할 땐 보통 스프링 설정 파일로 `DataSource`를 설정하고, 공유된 `DataSource` 빈을 DAO 클래스에 의존성으로 주입한다. `JdbcTemplate`은 `DataSource` setter에서 만든다. 따라서 DAO는 다음과 유사하게 만들 수 있다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
public class JdbcCorporateEventDao implements CorporateEventDao {

    private JdbcTemplate jdbcTemplate;

    public void setDataSource(DataSource dataSource) {
        this.jdbcTemplate = new JdbcTemplate(dataSource);
    }

    // JDBC-backed implementations of the methods on the CorporateEventDao follow...
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
class JdbcCorporateEventDao(dataSource: DataSource) : CorporateEventDao {

    private val jdbcTemplate = JdbcTemplate(dataSource)

    // JDBC-backed implementations of the methods on the CorporateEventDao follow...
}
```

다음은 이와 동일한 XML 설정 예시다:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:context="http://www.springframework.org/schema/context"
    xsi:schemaLocation="
        http://www.springframework.org/schema/beans
        https://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/context
        https://www.springframework.org/schema/context/spring-context.xsd">

    <bean id="corporateEventDao" class="com.example.JdbcCorporateEventDao">
        <property name="dataSource" ref="dataSource"/>
    </bean>

    <bean id="dataSource" class="org.apache.commons.dbcp.BasicDataSource" destroy-method="close">
        <property name="driverClassName" value="${jdbc.driverClassName}"/>
        <property name="url" value="${jdbc.url}"/>
        <property name="username" value="${jdbc.username}"/>
        <property name="password" value="${jdbc.password}"/>
    </bean>

    <context:property-placeholder location="jdbc.properties"/>

</beans>
```

명시적으로 설정하는 대신 컴포넌트 스캔과 어노테이션을 통해 의존성을 주입해도 된다. 이땐 클래스에 `@Repository` 어노테이션을 달고 (컴포넌트 스캔 후보로 등록), `DataSource` setter 메소드에 `@Autowired`를 선언한다. 다음 예제를 참고해라:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
@Repository // (1)
public class JdbcCorporateEventDao implements CorporateEventDao {

    private JdbcTemplate jdbcTemplate;

    @Autowired // (2)
    public void setDataSource(DataSource dataSource) {
        this.jdbcTemplate = new JdbcTemplate(dataSource); // (3)
    }

    // JDBC-backed implementations of the methods on the CorporateEventDao follow...
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
@Repository // (1)
class JdbcCorporateEventDao(dataSource: DataSource) : CorporateEventDao { // (2)

    private val jdbcTemplate = JdbcTemplate(dataSource) // (3)

    // JDBC-backed implementations of the methods on the CorporateEventDao follow...
}
```
<div class="description-for-java java kotlin"></div>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 클래스에 `@Repository` 어노테이션을 선언한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> `DataSource` setter 메소드에 `@Autowired`를 선언한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> `DataSource`로 `JdbcTemplate`을 생성한다.</small>
<div class="description-for-kotlin java kotlin"></div>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 클래스에 `@Repository` 어노테이션을 선언한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 생성자로 `DataSource`를 주입한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> `DataSource`로 `JdbcTemplate`을 생성한다.</small>

다음은 이와 동일한 XML 설정 예시다:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:context="http://www.springframework.org/schema/context"
    xsi:schemaLocation="
        http://www.springframework.org/schema/beans
        https://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/context
        https://www.springframework.org/schema/context/spring-context.xsd">

    <!-- Scans within the base package of the application for @Component classes to configure as beans -->
    <context:component-scan base-package="org.springframework.docs.test" />

    <bean id="dataSource" class="org.apache.commons.dbcp.BasicDataSource" destroy-method="close">
        <property name="driverClassName" value="${jdbc.driverClassName}"/>
        <property name="url" value="${jdbc.url}"/>
        <property name="username" value="${jdbc.username}"/>
        <property name="password" value="${jdbc.password}"/>
    </bean>

    <context:property-placeholder location="jdbc.properties"/>

</beans>
```

JDBC를 사용할 DAO 클래스에서 스프링의 `JdbcDaoSupport` 클래스를 상속하면, 하위 클래스는 `JdbcDaoSupport` 클래스의 `setDataSource(..)` 메소드를 상속받는다. 이 클래스의 상속 여부는 직접 선택하면 된다. `JdbcDaoSupport` 클래스는 편의상 제공하는 클래스다.

위에서 보여준 템플릿 초기화 스타일 중 어떤 방법을 사용하더라도 (아니면 그 외 다른 방법을 쓰더라도), 웬만해선 SQL을 실행할 때마다 새 `JdbcTemplate` 클래스 인스턴스를 생성할 필요는 없다. `JdbcTemplate` 인스턴스는 설정만 하고나면 thread-safe하다. 단, 데이터베이스 여러 개에 접근하는 어플리케이션이라면 `DataSource`가 여러 개 필요하며, 그에 따라 `JdbcTemplate` 인스턴스를 다르게 설정해야 할 수는 있다.

### 3.3.2. Using `NamedParameterJdbcTemplate`

앞에서는 JDBC 구문을 만들 때 사용할 수 있는 인자는 전형적인 플레이스홀더( `'?'`) 뿐이었지만, `NamedParameterJdbcTemplate` 클래스로는 named 파라미터를 활용할 수 있다. `NamedParameterJdbcTemplate` 클래스는 `JdbcTemplate`을 래핑하며, 많은 동작을 래핑한 `JdbcTemplate`에 위임한다. 이번 섹션에선 `NamedParameterJdbcTemplate`이 `JdbcTemplate`과는 어떻게 다른지, 즉 named 파라미터로는 JDBC 구문을 어떻게 만드는지에 대해서만 설명한다. 다음 예제는 `NamedParameterJdbcTemplate` 사용하는 방법을 보여준다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
// some JDBC-backed DAO class...
private NamedParameterJdbcTemplate namedParameterJdbcTemplate;

public void setDataSource(DataSource dataSource) {
    this.namedParameterJdbcTemplate = new NamedParameterJdbcTemplate(dataSource);
}

public int countOfActorsByFirstName(String firstName) {

    String sql = "select count(*) from T_ACTOR where first_name = :first_name";

    SqlParameterSource namedParameters = new MapSqlParameterSource("first_name", firstName);

    return this.namedParameterJdbcTemplate.queryForObject(sql, namedParameters, Integer.class);
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
private val namedParameterJdbcTemplate = NamedParameterJdbcTemplate(dataSource)

fun countOfActorsByFirstName(firstName: String): Int {
    val sql = "select count(*) from T_ACTOR where first_name = :first_name"
    val namedParameters = MapSqlParameterSource("first_name", firstName)
    return namedParameterJdbcTemplate.queryForObject(sql, namedParameters, Int::class.java)!!
}
```

여기서 주목할 점은, named 파라미터 표기법으로 `sql` 변수와 그에 해당하는 `namedParameters` 변수(`MapSqlParameterSource` 타입)에 값을 할당했다는 점이다.

아니면 `Map`을 사용해서 `NamedParameterJdbcTemplate` 인스턴스에 named 파라미터와 실제 값을 전달할 수도 있다.  나머지 다른 메소드도 거의 비슷한 패턴이며, 여기서는 다루지 않겠다. `NamedParameterJdbcTemplate`이 구현한 메소드들은 `NamedParameterJdbcOperations` 인터페이스에 정의돼 있다.

다음 예제는 `Map`을 사용한다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
// some JDBC-backed DAO class...
private NamedParameterJdbcTemplate namedParameterJdbcTemplate;

public void setDataSource(DataSource dataSource) {
    this.namedParameterJdbcTemplate = new NamedParameterJdbcTemplate(dataSource);
}

public int countOfActorsByFirstName(String firstName) {

    String sql = "select count(*) from T_ACTOR where first_name = :first_name";

    Map<String, String> namedParameters = Collections.singletonMap("first_name", firstName);

    return this.namedParameterJdbcTemplate.queryForObject(sql, namedParameters,  Integer.class);
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
// some JDBC-backed DAO class...
private val namedParameterJdbcTemplate = NamedParameterJdbcTemplate(dataSource)

fun countOfActorsByFirstName(firstName: String): Int {
    val sql = "select count(*) from T_ACTOR where first_name = :first_name"
    val namedParameters = mapOf("first_name" to firstName)
    return namedParameterJdbcTemplate.queryForObject(sql, namedParameters, Int::class.java)!!
}
```

`NamedParameterJdbcTemplate`의 멋진 기능 중 하나는 `SqlParameterSource` 인터페이스다 (동일한 패키지에 있다). 앞에 있는 예제(`SqlParameterSource` 클래스)에서 이미 이 인터페이스 구현체를 하나 봤다. `NamedParameterJdbcTemplate`은 named 파라미터 값을 `SqlParameterSource`에서 가져온다. `MapSqlParameterSource` 클래스는 `java.util.Map`을 둘러싼 어댑터 역할을 수행하는 단순한 구현체다. 이때 `java.util.Map`의 키는 파라미터 이름, 값은 파라미터 값이다.

또다른 `SqlParameterSource` 구현체는 `BeanPropertySqlParameterSource` 클래스다. 이 클래스는 자바빈이라면 어떤 객체든지 랩핑할 수 있으며 (즉, [자바빈 컨벤션](https://www.oracle.com/technetwork/java/javase/documentation/spec-136004.html)을 따르는 클래스의 인스턴스), 랩핑한 자바빈의 프로퍼티로 named 파라미터 값을 만든다.

다음은 전형적인 자바빈 예시다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
public class Actor {

    private Long id;
    private String firstName;
    private String lastName;

    public String getFirstName() {
        return this.firstName;
    }

    public String getLastName() {
        return this.lastName;
    }

    public Long getId() {
        return this.id;
    }

    // setters omitted...

}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
data class Actor(val id: Long, val firstName: String, val lastName: String)
```

다음 예제는 `NamedParameterJdbcTemplate`을 사용해서 앞에 있는 클래스의 회원 수를 반환한다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
// some JDBC-backed DAO class...
private NamedParameterJdbcTemplate namedParameterJdbcTemplate;

public void setDataSource(DataSource dataSource) {
    this.namedParameterJdbcTemplate = new NamedParameterJdbcTemplate(dataSource);
}

public int countOfActors(Actor exampleActor) {

    // notice how the named parameters match the properties of the above 'Actor' class
    String sql = "select count(*) from T_ACTOR where first_name = :firstName and last_name = :lastName";

    SqlParameterSource namedParameters = new BeanPropertySqlParameterSource(exampleActor);

    return this.namedParameterJdbcTemplate.queryForObject(sql, namedParameters, Integer.class);
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
// some JDBC-backed DAO class...
private val namedParameterJdbcTemplate = NamedParameterJdbcTemplate(dataSource)

private val namedParameterJdbcTemplate = NamedParameterJdbcTemplate(dataSource)

fun countOfActors(exampleActor: Actor): Int {
    // notice how the named parameters match the properties of the above 'Actor' class
    val sql = "select count(*) from T_ACTOR where first_name = :firstName and last_name = :lastName"
    val namedParameters = BeanPropertySqlParameterSource(exampleActor)
    return namedParameterJdbcTemplate.queryForObject(sql, namedParameters, Int::class.java)!!
}
```

`NamedParameterJdbcTemplate` 클래스는 전형적인 `JdbcTemplate` 템플릿을 래핑한다는 점을 기억해둬라. `JdbcTemplate` 클래스에만 있는 기능때문에 래핑한 `JdbcTemplate` 인스턴스에 접근해야 한다면 `getJdbcOperations()` 메소드를 사용해라. `getJdbcOperations()` 메소드는 래핑된 `JdbcTemplate`을 `JdbcOperations` 인터페이스로 반환한다.

어플리케이션 컨텍스트에서 `NamedParameterJdbcTemplate` 클래스를 사용하기 위한 가이드라인은 [`JdbcTemplate` Best Practices](#jdbctemplate-best-practices)를 함께 참고해라.

### 3.3.3. Using `SQLExceptionTranslator`

`SQLExceptionTranslator`는 `SQLException`을 스프링의 자체 <span class="custom-blockquote">org.springframework.dao.DataAccessException</span>으로 변환하기 위한 인터페이스로, 데이터 접근 전략과는 무관하다. 구현체에선 범용 에러(JDBC의 SQLState 코드)나 데이터 접근 기술 전용 에러(오라클 에러 코드)를 사용해서 더 정밀한 로직을 실행할 수 있다.

`SQLErrorCodeSQLExceptionTranslator`는 디폴트로 사용하는 `SQLExceptionTranslator` 구현체다. 이 구현체는 벤더 전용 코드를 사용하며, `SQLState` 구현체보다 더 정밀하다. 자바빈 클래스 `SQLErrorCodes`를 기반으로 에러 코드를 전환한다. `SQLErrorCodes`는 (이름에서 알 수 있듯이) 팩토리 클래스 `SQLErrorCodesFactory`가 만들고 값을 채운다. 팩토리 클래스에선 설정 파일 `sql-error-codes.xml`을 참고한다. 이 파일은 벤더 업체 코드로 채워져 있으며, 에러 코드는 `DatabaseMetaData`에서 가져온 `DatabaseProductName`을 기반으로 선택한다. 따라서 실제로 사용 중인 데이터베이스의 코드를 사용하게 된다.

`SQLErrorCodeSQLExceptionTranslator`는 다음 순서에 따라 에러 코드를 매칭한다:

1. 하위 클래스로 만든 커스텀 구현체. 보통은 기본 제공하는 `SQLErrorCodeSQLExceptionTranslator`를 사용하므로, 이 규칙은 적용되지 않는다. 하위 클래스 구현체를 직접 제공했을 때만 적용된다.
2. `SQLErrorCodes` 클래스의 `customSqlExceptionTranslator` 프로퍼티에 설정한 `SQLExceptionTranslator` 인터페이스의 커스텀 구현체.
3. `CustomSQLErrorCodesTranslation` 클래스 인스턴스 리스트(`SQLErrorCodes` 클래스의 `customTranslations` 프로퍼티에 설정)에서 일치하는 에러 코드 검색.
4. 에러 코드 매칭 적용.
5. 폴백 translator 사용. 디폴트 폴백은 `SQLExceptionSubclassTranslator`다. 이 translator로도 불가능한 경우는 그 다음 폴백 `SQLStateSQLExceptionTranslator`를 사용한다.

> `Error` 코드와 커스텀 예외 변환 로직을 정의할 때는 기본적으로 `SQLErrorCodesFactory`를 사용한다. 커스텀 에러 코드는 클래스패스에 있는 `sql-error-codes.xml` 파일에서 조회하며, 매칭한 `SQLErrorCodes`는 사용 중인 데이터베이스의 메타데이터에 있는 데이터베이스 이름을 기반으로 저장한다.

다음 예제처럼 `SQLErrorCodeSQLExceptionTranslator`를 확장할 수도 있다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
public class CustomSQLErrorCodesTranslator extends SQLErrorCodeSQLExceptionTranslator {

    protected DataAccessException customTranslate(String task, String sql, SQLException sqlEx) {
        if (sqlEx.getErrorCode() == -12345) {
            return new DeadlockLoserDataAccessException(task, sqlEx);
        }
        return null;
    }
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
class CustomSQLErrorCodesTranslator : SQLErrorCodeSQLExceptionTranslator() {

    override fun customTranslate(task: String, sql: String?, sqlEx: SQLException): DataAccessException? {
        if (sqlEx.errorCode == -12345) {
                return DeadlockLoserDataAccessException(task, sqlEx)
            }
            return null;
    }
}
```

이 예제에선 특정 에러 코드(`-12345`)만 변환하며, 그외 다른 에러는 디폴트 translator 구현체가 전환하도록 그대로 놔둔다. 이 커스텀 translator를 사용하려면  `JdbcTemplate`에 `setExceptionTranslator` 메소드로 전달해야 하며, 이 로직이 필요한 곳은 모두 이 `JdbcTemplate`으로 데이터에 접근해야 한다. 다음 예제를 참고해라:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
private JdbcTemplate jdbcTemplate;

public void setDataSource(DataSource dataSource) {

    // create a JdbcTemplate and set data source
    this.jdbcTemplate = new JdbcTemplate();
    this.jdbcTemplate.setDataSource(dataSource);

    // create a custom translator and set the DataSource for the default translation lookup
    CustomSQLErrorCodesTranslator tr = new CustomSQLErrorCodesTranslator();
    tr.setDataSource(dataSource);
    this.jdbcTemplate.setExceptionTranslator(tr);

}

public void updateShippingCharge(long orderId, long pct) {
    // use the prepared JdbcTemplate for this update
    this.jdbcTemplate.update("update orders" +
        " set shipping_charge = shipping_charge * ? / 100" +
        " where id = ?", pct, orderId);
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
// create a JdbcTemplate and set data source
private val jdbcTemplate = JdbcTemplate(dataSource).apply {
    // create a custom translator and set the DataSource for the default translation lookup
    exceptionTranslator = CustomSQLErrorCodesTranslator().apply {
        this.dataSource = dataSource
    }
}

fun updateShippingCharge(orderId: Long, pct: Long) {
    // use the prepared JdbcTemplate for this update
    this.jdbcTemplate!!.update("update orders" +
            " set shipping_charge = shipping_charge * ? / 100" +
            " where id = ?", pct, orderId)
}
```

이 커스텀 translator는 데이터 소스에 전달돼 `sql-error-codes.xml`에 있는 에러 코드를 조회한다.

### 3.3.4. Running Statements

SQL 문을 실행할 땐 코드가 거의 필요 없다. `DataSource`와 `JdbcTemplate`과, `JdbcTemplate`이 제공하는 간편한 메소드만 있으면 된다. 다음 예제는 최소한의 코드긴 하지만, 새 테이블을 만드는 완전한 기능을 갖춘 클래스다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
import javax.sql.DataSource;
import org.springframework.jdbc.core.JdbcTemplate;

public class ExecuteAStatement {

    private JdbcTemplate jdbcTemplate;

    public void setDataSource(DataSource dataSource) {
        this.jdbcTemplate = new JdbcTemplate(dataSource);
    }

    public void doExecute() {
        this.jdbcTemplate.execute("create table mytable (id integer, name varchar(100))");
    }
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
import javax.sql.DataSource
import org.springframework.jdbc.core.JdbcTemplate

class ExecuteAStatement(dataSource: DataSource) {

    private val jdbcTemplate = JdbcTemplate(dataSource)

    fun doExecute() {
        jdbcTemplate.execute("create table mytable (id integer, name varchar(100))")
    }
}
```

### 3.3.5. Running Queries

일부 쿼리 메소드는 단일 값을 반환한다. 카운트를 조회하거나 row 하나에 있는 특정 값 하나만 조회하려면 `queryForObject(..)`를 사용해라. 특정 값을 조회할 땐 데이터베이스에서 반환한 JDBC `Type`을, 인자로 전달한 자바 클래스로 변환한다. 타입을 변환할 수 없으면 `InvalidDataAccessApiUsageException`을 던진다. 다음 예제는 두 가지 쿼리 메소드를 사용한다. 하나는 `int`로, 다른 하나는 `String`으로 질의하는 메소드다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
import javax.sql.DataSource;
import org.springframework.jdbc.core.JdbcTemplate;

public class RunAQuery {

    private JdbcTemplate jdbcTemplate;

    public void setDataSource(DataSource dataSource) {
        this.jdbcTemplate = new JdbcTemplate(dataSource);
    }

    public int getCount() {
        return this.jdbcTemplate.queryForObject("select count(*) from mytable", Integer.class);
    }

    public String getName() {
        return this.jdbcTemplate.queryForObject("select name from mytable", String.class);
    }
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
import javax.sql.DataSource
import org.springframework.jdbc.core.JdbcTemplate

class RunAQuery(dataSource: DataSource) {

    private val jdbcTemplate = JdbcTemplate(dataSource)

    val count: Int
        get() = jdbcTemplate.queryForObject("select count(*) from mytable")!!

    val name: String?
        get() = jdbcTemplate.queryForObject("select name from mytable")
}
```

단일 값을 반환하는 쿼리 메소드 외에도, 쿼리가 반환한 row를 담고있는 리스트를 반환하는 메소드도 있다. 가장 범용적인 메소드는 `queryForList(..)`로, `Map`의 `List`를 반환한다. `Map`에는 엔트리 하나가 담기며, 컬럼명을 키로 사용한다. 앞에 있는 예제에 모든 row 리스트를 조회하는 메소드를 추가하면 다음과 같이 바뀐다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
private JdbcTemplate jdbcTemplate;

public void setDataSource(DataSource dataSource) {
    this.jdbcTemplate = new JdbcTemplate(dataSource);
}

public List<Map<String, Object>> getList() {
    return this.jdbcTemplate.queryForList("select * from mytable");
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
private val jdbcTemplate = JdbcTemplate(dataSource)

fun getList(): List<Map<String, Any>> {
    return jdbcTemplate.queryForList("select * from mytable")
}
```

반환하는 값은 아래처럼 생긴 리스트다:

```json
[{name=Bob, id=1}, {name=Mary, id=2}]
```

### 3.3.6. Updating the Database

다음은 기본 키가 일치하는 row의 컬럼을 업데이트하는 예제다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
import javax.sql.DataSource;
import org.springframework.jdbc.core.JdbcTemplate;

public class ExecuteAnUpdate {

    private JdbcTemplate jdbcTemplate;

    public void setDataSource(DataSource dataSource) {
        this.jdbcTemplate = new JdbcTemplate(dataSource);
    }

    public void setName(int id, String name) {
        this.jdbcTemplate.update("update mytable set name = ? where id = ?", name, id);
    }
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
import javax.sql.DataSource
import org.springframework.jdbc.core.JdbcTemplate

class ExecuteAnUpdate(dataSource: DataSource) {

    private val jdbcTemplate = JdbcTemplate(dataSource)

    fun setName(id: Int, name: String) {
        jdbcTemplate.update("update mytable set name = ? where id = ?", name, id)
    }
}
```

이 예제에서 사용한 SQL 구문 row 파라미터엔 플레이스홀더가 있다. 파라미터 값은 객체 가변 인자나 객체 배열로 전달할 수 있다. 따라서 래퍼 클래스를 명시하지 않으면 원시 타입을 자동으로 박싱한다.

### 3.3.7. Retrieving Auto-generated Keys

`update()` 메소드 중에는 데이터베이스가 생성한 기본 키를 간편하게 조회할 수 있는 메소드가 하나 있다. 이 기능은 JDBC 3.0 표준이다. 자세한 스펙은 [13.6 장](#37-modeling-jdbc-operations-as-java-objects)을 참고해라. 이 메소드는 첫 번째 인자로 `PreparedStatementCreator`를 받으며, 이 인자를 통해 원하는 insert 문을 지정할 수 있다. 다른 인자는 `KeyHolder`로, 여기에 업데이트에 성공했을 때 반환하는 기본 키를 저장한다. 모든 상황에 적용되는 `PreparedStatement`를 만드는 단일 표준이란 것은 없다 (그렇기 때문에 메소드 시그니처에 `update()` 메소드가 그렇게 많은 거다). 다음 코드는 오라클 예제로, 다른 플랫폼에서는 동작하지 않을 수 있다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
final String INSERT_SQL = "insert into my_test (name) values(?)";
final String name = "Rob";

KeyHolder keyHolder = new GeneratedKeyHolder();
jdbcTemplate.update(connection -> {
    PreparedStatement ps = connection.prepareStatement(INSERT_SQL, new String[] { "id" });
    ps.setString(1, name);
    return ps;
}, keyHolder);

// keyHolder.getKey() now contains the generated key
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
val INSERT_SQL = "insert into my_test (name) values(?)"
val name = "Rob"

val keyHolder = GeneratedKeyHolder()
jdbcTemplate.update({
    it.prepareStatement (INSERT_SQL, arrayOf("id")).apply { setString(1, name) }
}, keyHolder)

// keyHolder.getKey() now contains the generated key
```

---

## 3.4. Controlling Database Connections

이번 섹션에서 다루는 내용은 다음과 같다:

- [`DataSource` 사용하기](#341-using-datasource)
- [`DataSourceUtils` 사용하기](#342-using-datasourceutils)
- [`SmartDataSource` 구현하기](#343-implementing-smartdatasource)
- [`AbstractDataSource` 확장하기](#344-extending-abstractdatasource)
- [`SingleConnectionDataSource` 사용하기](#345-using-singleconnectiondatasource)
- [`DriverManagerDataSource` 사용하기](#346-using-drivermanagerdatasource)
- [`TransactionAwareDataSourceProxy` 사용하기](#347-using-transactionawaredatasourceproxy)
- [`DataSourceTransactionManager` 사용하기](#348-using-datasourcetransactionmanager)

### 3.4.1. Using `DataSource`

스프링은 `DataSource`를 통해서 데이터베이스 커넥션을 획득한다. `DataSource`는 JDBC 스펙 중 하나로, 커넥션 팩토리를 일반화한 인터페이스다. 덕분에 컨테이너나 프레임워크가 어플리케이션 코드에선 모르게 커넥션 풀링과 트랜잭션 관리 이슈를 처리할 수 있다. 개발자는 데이터베이스에 연결하는 방법에 대해 자세히는 몰라도 된다. 데이터베이스 연결은 `DataSource`를 세팅하는 관리자의 책임이다. 개발과 테스트 코드를 모두 맡았을 가능성이 높지만, 프로덕션 데이터 소스를 설정하는 방법을 반드시 알아야 하는 건 아니다.

스프링의 JDBC 레이어를 사용하면 JNDI로 데이터 소스를 가져오거나, 제 3자가 제공하는 커넥션 풀 구현체로 자체 설정을 만들 수 있다. 보통은 빈 스타일로 `DataSource` 클래스를 제공하는 Apache Commons DBCP나 C3P0를 많이 사용한다. 모던 JDBC 커넥션 풀을 사용하고 싶다면 빌더 스타일 API를 제공하는 HikariCP를 고려해봐라.

> 스프링이 배포하는 `DriverManagerDataSource`, `SimpleDriverDataSource` 클래스는 테스트 용도로만 사용해야 한다! 이 구현체들은 풀링을 제공하지 않으며, 요청 시마다 커넥션을 생성하기 때문에 동시 요청이 몰리면 성능이 크게 떨어진다.

이어지는 섹션에선 스프링의 `DriverManagerDataSource` 구현체를 사용한다. 다른 여러 가지 `DataSource` 구현체는 나중에 다루겠다.

`DriverManagerDataSource`를 설정하려면:

1. 평소 JDBC 커넥션을 획득할 때와 동일하게, `DriverManagerDataSource`로 커넥션을 가져와라.
2. `DriverManager`가 드라이버 클래스를 로드할 수 있게 JDBC 드라이버 클래스의 풀 네임(qualified name)을 지정해라.
3. JDBC 드라이버 전용 URL을 하나 지정해라. (정확한 URL은 사용하는 드라이버 문서를 확인해봐라.)
4. 데이터베이스에 연결하기 위한 username과 password를 제공해라.

다음은 자바로 `DriverManagerDataSource`를 설정하는 예시다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
DriverManagerDataSource dataSource = new DriverManagerDataSource();
dataSource.setDriverClassName("org.hsqldb.jdbcDriver");
dataSource.setUrl("jdbc:hsqldb:hsql://localhost:");
dataSource.setUsername("sa");
dataSource.setPassword("");
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
val dataSource = DriverManagerDataSource().apply {
    setDriverClassName("org.hsqldb.jdbcDriver")
    url = "jdbc:hsqldb:hsql://localhost:"
    username = "sa"
    password = ""
}
```

다음은 위와 동일한 XML 설정이다:

```xml
<bean id="dataSource" class="org.springframework.jdbc.datasource.DriverManagerDataSource">
    <property name="driverClassName" value="${jdbc.driverClassName}"/>
    <property name="url" value="${jdbc.url}"/>
    <property name="username" value="${jdbc.username}"/>
    <property name="password" value="${jdbc.password}"/>
</bean>

<context:property-placeholder location="jdbc.properties"/>
```

아래 있는 두 설정은 DBCP와 C3P0를 사용하는 기본 연결 설정 예시다. 풀링 기능을 제어할 수 있는 다른 옵션을 알고 싶으면 각 커넥션 풀링 구현체 문서를 참고해라.

먼저, DBCP 설정 예시다:

```xml
<bean id="dataSource" class="org.apache.commons.dbcp.BasicDataSource" destroy-method="close">
    <property name="driverClassName" value="${jdbc.driverClassName}"/>
    <property name="url" value="${jdbc.url}"/>
    <property name="username" value="${jdbc.username}"/>
    <property name="password" value="${jdbc.password}"/>
</bean>

<context:property-placeholder location="jdbc.properties"/>
```

다음은 C3P0 설정 예시다:

```xml
<bean id="dataSource" class="com.mchange.v2.c3p0.ComboPooledDataSource" destroy-method="close">
    <property name="driverClass" value="${jdbc.driverClassName}"/>
    <property name="jdbcUrl" value="${jdbc.url}"/>
    <property name="user" value="${jdbc.username}"/>
    <property name="password" value="${jdbc.password}"/>
</bean>

<context:property-placeholder location="jdbc.properties"/>
```

### 3.4.2. Using `DataSourceUtils`

`DataSourceUtils` 클래스는 JNDI에서 커넥션을 얻고, 필요하면 커넥션을 닫을 수 있는 `static` 메소드를 제공하는 간편하면서도 강력한 헬퍼 클래스다. 예를 들어 `DataSourceTransactionManager`에 스레드에 바인딩한 커넥션을 제공한다.

### 3.4.3. Implementing `SmartDataSource`

`SmartDataSource`는 관계형 데이터베이스의 커넥션을 제공할 수 있는 클래스로 구현해야 하는 인터페이스다. `SmartDataSource` 인터페이스는 `DataSource` 인터페이스를 확장해 사용처에서 지정한 연산을 실행한 뒤에 커넥션을 닫아야 하는지를 질의할 수 있는 메소드를 추가했다. 이 기능은 커넥션을 재사용해야 한다는 것을 알고있을 때 유용하다.

### 3.4.4. Extending `AbstractDataSource`

`AbstractDataSource`는 스프링의 `DataSource` 구현을 위한 기반 클래스다. 여기에선 모든 `DataSource` 구현체에 필요한 공통 코드를 구현한다. 자체 `DataSource` 구현체를 만든다면 이 `AbstractDataSource` 클래스를 상속해야 한다.

### 3.4.5. Using `SingleConnectionDataSource`

`SingleConnectionDataSource` 클래스는 `SmartDataSource` 인터페이스 구현체로, 사용 후에도 닫지 않는 단일 `Connection`을 래핑한다. 멀티 스레드는 지원하지 않는다.

커넥션 풀을 가정하고 `close`를 호출하는 코드가 있다면 (persistence 툴을 사용할 때 처럼) `suppressClose` 속성을 `true`로 설정해야 한다. 이 설정은 물리적인 커넥션을 래핑해 `close`를 억제하는 프록시를 만든다. 단, 이렇게 설정하고 나면 더 이상 커넥션을 네이티브 오라클 `Connection`이나 다른 유사한 객체로 캐스팅할 수 없다.

`SingleConnectionDataSource`는 일차적으로는 테스트 클래스다. 일반적으로 어플리케이션 서버 외부에서 간단한 JNDI 환경으로 코드를 쉽게 테스트하는 용도로 사용한다. `DriverManagerDataSource`와는 달리 `SingleConnectionDataSource`는 항상 동일한 커넥션을 재사용하므로, 물리적인 커넥션을 과도하게 생성하지 않도록 방지해준다.

### 3.4.6. Using `DriverManagerDataSource`

`DriverManagerDataSource` 클래스는 표준 `DataSource` 인터페이스 구현체로, 순수 JDBC 드라이버는 빈 프로퍼티로 설정하며, 매번 새 `Connection`을 반환한다.

이 구현체는 스프링 IoC 컨테이너의 `DataSource` 빈이나 간단한 JNDI 환경으로 자바 EE 컨테이너 외부 환경에서 독립적으로 어플리케이션을 실행하고 테스트할 때 유용하다. 커넥션 풀을 가정하고 `Connection.close()`를 호출하는 코드가 있더라도 이땐 커넥션을 닫으므로, `DataSource`를 인식할 수 있는 persistence 코드라면 모두 동작할 거다. 하지만 자바빈 스타일 커넥션 풀(`commons-dbcp` 등)은 테스트 환경에서도 사용하기 매우 쉽기 때문에, 웬만하면 `DriverManagerDataSource`보단 이런 커넥션 풀을 사용하는 게 낫다.

### 3.4.7. Using `TransactionAwareDataSourceProxy`

`TransactionAwareDataSourceProxy`는 `DataSource`를 타겟으로 하는 프록시다. 이 프록시는 타겟 `DataSource`를 래핑해 스프링이 관리하는 트랜잭션을 인식할 수 있게 해준다. 이 특징만 보면 자바 EE 서버가 제공하는 트랜잭션 JNDI `DataSource`와 유사하다.

> 반드시 기존 코드를 호출해서 표준 JDBC `DataSource` 인터페이스 구현체를 전달해야 하는 상황만 아니라면, 이 클래스는 사용하지 않는게 좋다. 필요하면 이 코드를 사용해도 되지만, 스프링이 관리하는 트랜잭션에 관여하게 된다. 가능하면 리소스를 관리하는 자체 코드는 `JdbcTemplate`, `DataSourceUtils`같이 좀 더 상위 수준에 있는 추상화를 사용해서 작성하는 게 좋다.

자세한 내용은 [`TransactionAwareDataSourceProxy`](https://docs.spring.io/spring-framework/docs/5.3.2/javadoc-api/org/springframework/jdbc/datasource/TransactionAwareDataSourceProxy.html) javadoc을 참고해라.

### 3.4.8. Using `DataSourceTransactionManager`

`DataSourceTransactionManager` 클래스는 단일 JDBC 데이터 소스를 사용하는 `PlatformTransactionManager` 구현체다. 지정한 데이터소스의 JDBC 커넥션을 현재 실행 중인 스레드로 바인딩하므로, 데이터소스 당 하나의 스레드 커넥션만 허용하는 것도 가능하다.

어플리케이션 코드에선 자바 EE의 표준 `DataSource.getConnection`이 아닌 `DataSourceUtils.getConnection(DataSource)`로 JDBC 커넥션을 가져와야 한다. 이 메소드는 checked `SQLException` 대신 unchecked <span class="custom-blockquote">org.springframework.dao</span> exception을 던진다. 모든 프레임워크 클래스(`JdbcTemplate` 등)는 암묵적으로 `DataSourceUtils.getConnection(DataSource)`로 커넥션을 조회한다. `DataSourceTransactionManager`를 사용하지 않으면 `DataSourceUtils.getConnection(DataSource)`는 기존 표준 방식대로 커넥션을 조회한다. 따라서 `DataSourceUtils`는 어떤 상황에서도 사용할 수 있다.

`DataSourceTransactionManager` 클래스는 격리 수준과, JDBC 구문 쿼리에 적용할 타임아웃 커스텀을 지원한다. 타임아웃을 커스텀하려면 `JdbcTemplate`을 사용하거나 구문을 만들 때마다 `DataSourceUtils.applyTransactionTimeout(..)`  메소드를 호출해야 한다.

단일 리소스만 사용한다면 컨테이너가 JTA를 지원할 필요가 없기 때문에, `JtaTransactionManager` 대신 이 구현체를 사용하면 된다. 필수 커넥션 조회 패턴만 지켜준다면 설정만으로도 전환할 수 있다. JTA는 커스텀 격리 수준을 지원하지 않는다.

---

## 3.5. JDBC Batch Operations

배치로 같은 prepared 구문을 여러 번 호출하면  JDBC 드라이버 대부분은 더 나은 성능을 보여준다. 업데이트 문을 배치로 묶으면 데이터베이스와 주고받는 요청/응답 왕복 횟수를 줄일 수 있다.

### 3.5.1. Basic Batch Operations with `JdbcTemplate`

`JdbcTemplate`으로 배치를 처리할 때는, 전용 인터페이스 `BatchPreparedStatementSetter`의 두 가지 메소드를 구현하고, 이 구현체를 `batchUpdate` 메소드를 호출할 때 두 번째 파라미터로 전달하면 된다. 현재 배치 사이즈는 `getBatchSize` 메소드로 제공할 수 있다. `setValues` 메소드로는 prepared 구문의 파라미터 값을 설정할 수 있다. 이 메소드는 `getBatchSize`로 지정한 횟수만큼 호출된다. 다음은 리스트 안에 있는 엔트리를 기반으로 `t_actor` 테이블을 업데이트하는 예제인데, 여기선 리스트를 전부 배치로 처리한다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
public class JdbcActorDao implements ActorDao {

    private JdbcTemplate jdbcTemplate;

    public void setDataSource(DataSource dataSource) {
        this.jdbcTemplate = new JdbcTemplate(dataSource);
    }

    public int[] batchUpdate(final List<Actor> actors) {
        return this.jdbcTemplate.batchUpdate(
                "update t_actor set first_name = ?, last_name = ? where id = ?",
                new BatchPreparedStatementSetter() {
                    public void setValues(PreparedStatement ps, int i) throws SQLException {
                        Actor actor = actors.get(i);
                        ps.setString(1, actor.getFirstName());
                        ps.setString(2, actor.getLastName());
                        ps.setLong(3, actor.getId().longValue());
                    }
                    public int getBatchSize() {
                        return actors.size();
                    }
                });
    }

    // ... additional methods
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
class JdbcActorDao(dataSource: DataSource) : ActorDao {

    private val jdbcTemplate = JdbcTemplate(dataSource)

    fun batchUpdate(actors: List<Actor>): IntArray {
        return jdbcTemplate.batchUpdate(
                "update t_actor set first_name = ?, last_name = ? where id = ?",
                object: BatchPreparedStatementSetter {
                    override fun setValues(ps: PreparedStatement, i: Int) {
                        ps.setString(1, actors[i].firstName)
                        ps.setString(2, actors[i].lastName)
                        ps.setLong(3, actors[i].id)
                    }

                    override fun getBatchSize() = actors.size
                })
    }

    // ... additional methods
}
```

원하는 배치 사이즈가 정해져 있을 수 있지만, 업데이트 스트림을 처리하거나 파일을 읽는다면 배치 마지막 단계에서 엔트리 수를 가지고 있지 않을 수도 있다. 이땐 `InterruptibleBatchPreparedStatementSetter` 인터페이스를 사용해 입력 소스를 다 사용하고 나면 배치를 멈출 수 있다. `isBatchExhausted` 메소드로 배치의 종료를 알려주면 된다.

### 3.5.2. Batch Operations with a List of Objects

`JdbcTemplate`, `NamedParameterJdbcTemplate` 모두 배치 업데이트를 실행할 수 있는 다른 방법을 한 가지 더 제공한다. 배치 전용 인터페이스를 구현하는 대신, 모든 파라미터 값을 리스트로 한 번에 전달할 수 있다. 프레임워크 내부에서 `BatchPreparedStatementSetter`를 사용해서 리스트 값을 반복 처리한다. API 사용법은 named 파라미터를 사용했냐에 따라 다르다. named 파라미터를 사용한다면 `SqlParameterSource`의 배열을 제공해야 하며, 엔트리 하나가 배치의 한 사이클을 처리한다. `SqlParameterSource` 배열은 간편하게 `SqlParameterSourceUtils.createBatch` 메소드로 만들 수 있으며, 이 때는 빈 스타일 객체(파라미터에 해당하는 getter 메소드가 있는)나 `String`을 키로 사용하는 `Map` 인스턴스(상응하는 파라미터를 값으로 가진)의 배열을 전달할 수 있으며, 둘을 적절하게 섞어 써도 된다.

다음은 named 파라미터를 사용한 배치 업데이트 예시다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
public class JdbcActorDao implements ActorDao {

    private NamedParameterTemplate namedParameterJdbcTemplate;

    public void setDataSource(DataSource dataSource) {
        this.namedParameterJdbcTemplate = new NamedParameterJdbcTemplate(dataSource);
    }

    public int[] batchUpdate(List<Actor> actors) {
        return this.namedParameterJdbcTemplate.batchUpdate(
                "update t_actor set first_name = :firstName, last_name = :lastName where id = :id",
                SqlParameterSourceUtils.createBatch(actors));
    }

    // ... additional methods
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
class JdbcActorDao(dataSource: DataSource) : ActorDao {

    private val namedParameterJdbcTemplate = NamedParameterJdbcTemplate(dataSource)

    fun batchUpdate(actors: List<Actor>): IntArray {
        return this.namedParameterJdbcTemplate.batchUpdate(
                "update t_actor set first_name = :firstName, last_name = :lastName where id = :id",
                SqlParameterSourceUtils.createBatch(actors));
    }

        // ... additional methods
}
```

전형적인 `?` 플레이스홀더를 사용한 SQL 구문은, 업데이트 값을 가지고 있는 객체 배열을 리스트에 넣어서 전달해라. 이 객체 배열엔 SQL 구문에 있는 각 플레이스홀더를 채울 엔트리가 하나 있어야 하며, SQL 구문에 정의된 순서와 동일해야 한다.

다음 예제는 앞의 예제와 동일하지만, 이번에는 전형적인 JDBC `?` 플레이스홀더를 사용한다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
public class JdbcActorDao implements ActorDao {

    private JdbcTemplate jdbcTemplate;

    public void setDataSource(DataSource dataSource) {
        this.jdbcTemplate = new JdbcTemplate(dataSource);
    }

    public int[] batchUpdate(final List<Actor> actors) {
        List<Object[]> batch = new ArrayList<Object[]>();
        for (Actor actor : actors) {
            Object[] values = new Object[] {
                    actor.getFirstName(), actor.getLastName(), actor.getId()};
            batch.add(values);
        }
        return this.jdbcTemplate.batchUpdate(
                "update t_actor set first_name = ?, last_name = ? where id = ?",
                batch);
    }

    // ... additional methods
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
class JdbcActorDao(dataSource: DataSource) : ActorDao {

    private val jdbcTemplate = JdbcTemplate(dataSource)

    fun batchUpdate(actors: List<Actor>): IntArray {
        val batch = mutableListOf<Array<Any>>()
        for (actor in actors) {
            batch.add(arrayOf(actor.firstName, actor.lastName, actor.id))
        }
        return jdbcTemplate.batchUpdate(
                "update t_actor set first_name = ?, last_name = ? where id = ?", batch)
    }

    // ... additional methods
}
```

앞에서 설명한 배치 업데이트 메소드는 모두 각 배치 엔트리로 수정된 row 수를 담은 `int` 배열을 반환한다. 이 숫자는 JDBC 드라이버가 리포트한다. 카운트를 사용할 수 없으면 JDBC 드라이버는 `-2`를 반환한다.

> 이 시나리오에선 `PreparedStatement`에 값을 자동으로 설정하므로, 각 값에 상응하는 JDBC 타입은 주어진 자바 타입에 따라 만들어진다. 보통은 잘 동작하지만 문제가 발생할 가능성이 전혀 없진 않다 (예를 들어, `null` 값을 가지고 있는 `Map`). 스프링은 이럴때 디폴트로 `ParameterMetaData.getParameterType`을 호출하므로 JDBC 드라이버 연산이 많아질 수 있다. 성능 문제가 발생하면 (오라클 12c, JBoss, PostgreSQL에서 보고된바 있음) 최신 드라이버 버전을 사용하고 `spring.jdbc.getParameterType.ignore` 속성을 `true`로 설정해봐라 (JVM 시스템 프로퍼티나 클래스패스 루트에 있는 `spring.properties` 파일로).
>
> 아니면 JDBC 타입을 직접 지정해도 된다. 이때는 앞에서 설명한 `BatchPreparedStatementSetter`를 사용해도 되고, `List<Object[]>`를 받는 메소드를 호출해 명시적인 타입 배열을 전달하거나, 커스텀 `MapSqlParameterSource` 인스턴스의 `registerSqlType`을 호출해도 좋고, 아니면 null 값마저 처리해서 자바 프로퍼티 타입으로 SQL 타입을 만드는 `BeanPropertySqlParameterSource`를 사용해도 된다.

### 3.5.3. Batch Operations with Multiple Batches

앞에 있는 배치 업데이트 예제에서 다룬 배치는 너무 커서, 좀 더 작은 배치 여러 개로 분할하고 싶을 수도 있다. 앞에서 언급한 메소드만 가지고도 `batchUpdate`를 여러 번 나눠 호출할 수도 있지만, 이제는 좀 더 편리한 메소드가 있다. 이 메소드는 SQL 문 외에도, 파라미터를 담고 있는 객체의 `Collection`, 각 배치에서 수행할 업데이트 횟수, prepared 구문의 파라미터 값을 설정하는 `ParameterizedPreparedStatementSetter`를 받는다. 프레임워크는 업데이트 호출을 지정된 사이즈 배치로 나누고, 건내받은 파라미터 값을 반복 처리한다.

다음은 배치 사이즈를 10으로 설정하는 배치 업데이트 예시다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
public class JdbcActorDao implements ActorDao {

    private JdbcTemplate jdbcTemplate;

    public void setDataSource(DataSource dataSource) {
        this.jdbcTemplate = new JdbcTemplate(dataSource);
    }

    public int[][] batchUpdate(final Collection<Actor> actors) {
        int[][] updateCounts = jdbcTemplate.batchUpdate(
                "update t_actor set first_name = ?, last_name = ? where id = ?",
                actors,
                100,
                (PreparedStatement ps, Actor actor) -> {
                    ps.setString(1, actor.getFirstName());
                    ps.setString(2, actor.getLastName());
                    ps.setLong(3, actor.getId().longValue());
                });
        return updateCounts;
    }

    // ... additional methods
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
class JdbcActorDao(dataSource: DataSource) : ActorDao {

    private val jdbcTemplate = JdbcTemplate(dataSource)

    fun batchUpdate(actors: List<Actor>): Array<IntArray> {
        return jdbcTemplate.batchUpdate(
                    "update t_actor set first_name = ?, last_name = ? where id = ?",
                    actors, 100) { ps, argument ->
            ps.setString(1, argument.firstName)
            ps.setString(2, argument.lastName)
            ps.setLong(3, argument.id)
        }
    }

    // ... additional methods
}
```

이 배치 업데이트 메소드는 `int` 배열의 배열을 반환한다. 각 배열엔 배치마다 수행한 업데이트로 수정된 row 수의 배열이 담겨있다. 바깥쪽 배열의 길이는 실행한 배치 수를 나타내고, 안쪽 배열의 길이는 해당 배치에서 수행한 업데이트 수를 나타낸다. 각 배치의 업데이트 수는 전체 배치에 제공한 배치 사이즈와 같아야 한다 (넘겨준 업데이트 객체의 총 갯수에 따라, 마지막 항목은 더 적을 수도 있음). 각 업데이트 구문의 업데이트 카운트는 JDBC 드라이버가 보고한 것이다. 카운트를 사용할 수 없으면 JDBC 드라이버는 `-2`를 반환한다.

---

## 3.6. Simplifying JDBC Operations with the `SimpleJdbc` Classes

`SimpleJdbcInsert`, `SimpleJdbcCall` 클래스는 JDBC 드라이버를 통해 조회할 수 있는 데이터베이스 메타데이터를 활용해서 설정을 단순화해준다. 덕분에 미리 설정해야 하는 코드가 상대적으로 적다. 물론, 코드에서 직접 모든 세부 정보를 제공하고 싶으면 메타데이터 처리를 재정의하거나 꺼버려도 된다.

### 3.6.1. Inserting Data by Using `SimpleJdbcInsert`

최소한의 설정만 사용하는 `SimpleJdbcInsert` 클래스부터 살펴 보겠다. `SimpleJdbcInsert` 인스턴스는 데이터 접근 레이어의 초기화 메소드에서 만들어야 한다. 이번 예제에서 사용하는 초기화 메소드는 `setDataSource` 메소드다. `SimpleJdbcInsert` 클래스를 상속할 필요는 없다. 그 대신 새 인스턴스를 만들어 `withTableName` 메소드로 테이블 이름을 설정하면 된다. 이 클래스의 설정 메소드는 `fluid` 스타일에 따라 `SimpleJdbcInsert` 인스턴스를 반환하므로, 설정 메소드를 전부 체이닝할 수 있다. 다음 예제에선 설정 메소드를 하나만 사용한다 (메소드 체이닝은 뒤에서 보여준다):

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
public class JdbcActorDao implements ActorDao {

    private SimpleJdbcInsert insertActor;

    public void setDataSource(DataSource dataSource) {
        this.insertActor = new SimpleJdbcInsert(dataSource).withTableName("t_actor");
    }

    public void add(Actor actor) {
        Map<String, Object> parameters = new HashMap<String, Object>(3);
        parameters.put("id", actor.getId());
        parameters.put("first_name", actor.getFirstName());
        parameters.put("last_name", actor.getLastName());
        insertActor.execute(parameters);
    }

    // ... additional methods
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
class JdbcActorDao(dataSource: DataSource) : ActorDao {

    private val insertActor = SimpleJdbcInsert(dataSource).withTableName("t_actor")

    fun add(actor: Actor) {
        val parameters = mutableMapOf<String, Any>()
        parameters["id"] = actor.id
        parameters["first_name"] = actor.firstName
        parameters["last_name"] = actor.lastName
        insertActor.execute(parameters)
    }

    // ... additional methods
}
```

여기서 사용한 `execute` 메소드는 순수 `java.util.Map`을 유일한 파라미터로 받는다. 여기서 기억해야 할 점은 `Map`에 사용하는 키는 데이터베이스에 정의된 테이블의 컬럼명과 일치해야 한다는 거다. 실제 insert 구문을 설정할 때 메타데이터를 조회하기 때문이다.

### 3.6.2. Retrieving Auto-generated Keys by Using `SimpleJdbcInsert`

다음 예제는 이전 예제와 동일한 insert 객체를 사용하지만, 이번에는 `id`를 직접 전달하는 대신 자동 생성된 키를 가져와 새 `Actor` 객체에 설정한다. `SimpleJdbcInsert`를 생성할 땐 테이블 이름과 함께 `usingGeneratedKeyColumns` 메소드로 생성된 키 컬럼명도 지정한다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
public class JdbcActorDao implements ActorDao {

    private SimpleJdbcInsert insertActor;

    public void setDataSource(DataSource dataSource) {
        this.insertActor = new SimpleJdbcInsert(dataSource)
                .withTableName("t_actor")
                .usingGeneratedKeyColumns("id");
    }

    public void add(Actor actor) {
        Map<String, Object> parameters = new HashMap<String, Object>(2);
        parameters.put("first_name", actor.getFirstName());
        parameters.put("last_name", actor.getLastName());
        Number newId = insertActor.executeAndReturnKey(parameters);
        actor.setId(newId.longValue());
    }

    // ... additional methods
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
class JdbcActorDao(dataSource: DataSource) : ActorDao {

    private val insertActor = SimpleJdbcInsert(dataSource)
            .withTableName("t_actor").usingGeneratedKeyColumns("id")

    fun add(actor: Actor): Actor {
        val parameters = mapOf(
                "first_name" to actor.firstName,
                "last_name" to actor.lastName)
        val newId = insertActor.executeAndReturnKey(parameters);
        return actor.copy(id = newId.toLong())
    }

    // ... additional methods
}
```

이렇게 insert를 실행할 때 가장 큰 차이점은 `id`를 `Map`에 추가하지 않았고, `executeAndReturnKey` 메소드를 호출한다는 점이다. 이 메소드는  `java.lang.Number` 객체를 반환하므로 도메인 클래스에서 사용하는 숫자 타입 인스턴스를 만들 수 있다. 이때는 모든 데이터베이스가 원하는 자바 클래스를 반환할 거라 생각하면 안 된다. `java.lang.Number`는 신뢰할 수 있는 기본 클래스라서 가능한 거다. 자동 생성된 컬럼이 여러 개 있거나 생성된 값이 숫자가 아니면 `executeAndReturnKeyHolder` 메소드가 반환하는 `KeyHolder`를 사용하면 된다.

### 3.6.3. Specifying Columns for a `SimpleJdbcInsert`

다음 예제처럼 `usingColumns` 메소드를 사용하면 컬럼명 리스트를 지정해서 insert에 사용할 컬럼을 제한할 수 있다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
public class JdbcActorDao implements ActorDao {

    private SimpleJdbcInsert insertActor;

    public void setDataSource(DataSource dataSource) {
        this.insertActor = new SimpleJdbcInsert(dataSource)
                .withTableName("t_actor")
                .usingColumns("first_name", "last_name")
                .usingGeneratedKeyColumns("id");
    }

    public void add(Actor actor) {
        Map<String, Object> parameters = new HashMap<String, Object>(2);
        parameters.put("first_name", actor.getFirstName());
        parameters.put("last_name", actor.getLastName());
        Number newId = insertActor.executeAndReturnKey(parameters);
        actor.setId(newId.longValue());
    }

    // ... additional methods
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
class JdbcActorDao(dataSource: DataSource) : ActorDao {

    private val insertActor = SimpleJdbcInsert(dataSource)
            .withTableName("t_actor")
            .usingColumns("first_name", "last_name")
            .usingGeneratedKeyColumns("id")

    fun add(actor: Actor): Actor {
        val parameters = mapOf(
                "first_name" to actor.firstName,
                "last_name" to actor.lastName)
        val newId = insertActor.executeAndReturnKey(parameters);
        return actor.copy(id = newId.toLong())
    }

    // ... additional methods
}
```

실행되는 건 메타데이터에 의존해서 사용할 컬럼을 결정했을 때와 똑같다.

### 3.6.4. Using `SqlParameterSource` to Provide Parameter Values

파라미터에 `Map`을 사용해도 되지만 더 쉬운 방법이 있다. 스프링은 `SqlParameterSource` 인터페이스 구현체를 몇 개 더 제공한다. 자바빈과 호환되는 클래스에 값을 담았다면 `BeanPropertySqlParameterSource`가 제일 간편하다. 이 클래스는 getter 메소드로 파라미터 값을 추출한다. 다음은 `BeanPropertySqlParameterSource`를 사용하는 예제다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
public class JdbcActorDao implements ActorDao {

    private SimpleJdbcInsert insertActor;

    public void setDataSource(DataSource dataSource) {
        this.insertActor = new SimpleJdbcInsert(dataSource)
                .withTableName("t_actor")
                .usingGeneratedKeyColumns("id");
    }

    public void add(Actor actor) {
        SqlParameterSource parameters = new BeanPropertySqlParameterSource(actor);
        Number newId = insertActor.executeAndReturnKey(parameters);
        actor.setId(newId.longValue());
    }

    // ... additional methods
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
class JdbcActorDao(dataSource: DataSource) : ActorDao {

    private val insertActor = SimpleJdbcInsert(dataSource)
            .withTableName("t_actor")
            .usingGeneratedKeyColumns("id")

    fun add(actor: Actor): Actor {
        val parameters = BeanPropertySqlParameterSource(actor)
        val newId = insertActor.executeAndReturnKey(parameters)
        return actor.copy(id = newId.toLong())
    }

    // ... additional methods
}
```

또 다른 구현체 `MapSqlParameterSource`는 `Map`과 유사하지만 `addValue` 메소드를 체이닝할 수 있어서 더 편리하다. 다음 예제를 참고해라:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
public class JdbcActorDao implements ActorDao {

    private SimpleJdbcInsert insertActor;

    public void setDataSource(DataSource dataSource) {
        this.insertActor = new SimpleJdbcInsert(dataSource)
                .withTableName("t_actor")
                .usingGeneratedKeyColumns("id");
    }

    public void add(Actor actor) {
        SqlParameterSource parameters = new MapSqlParameterSource()
                .addValue("first_name", actor.getFirstName())
                .addValue("last_name", actor.getLastName());
        Number newId = insertActor.executeAndReturnKey(parameters);
        actor.setId(newId.longValue());
    }

    // ... additional methods
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
class JdbcActorDao(dataSource: DataSource) : ActorDao {

    private val insertActor = SimpleJdbcInsert(dataSource)
            .withTableName("t_actor")
            .usingGeneratedKeyColumns("id")

    fun add(actor: Actor): Actor {
        val parameters = MapSqlParameterSource()
                    .addValue("first_name", actor.firstName)
                    .addValue("last_name", actor.lastName)
        val newId = insertActor.executeAndReturnKey(parameters)
        return actor.copy(id = newId.toLong())
    }

    // ... additional methods
}
```

이미 봐서 알겠지만 설정은 동일하다. 파라미터 클래스를 변경할 땐 실행부만 바꾸면 된다.

### 3.6.5. Calling a Stored Procedure with `SimpleJdbcCall`

`SimpleJdbcCall` 클래스는 데이터베이스의 메타데이터를 사용해서 `in`, `out` 파라미터명을 찾기 때문에 설정을 명시하지 않아도 된다. 물론, 원한다면 파라미터를 선언해도 된다. 반대로 자바 클래스에 자동으로 매핑되지 않는 파라미터(`ARRAY`, `STRUCT` 등)를 사용한다면 파라미터를 선언해야 한다. 첫 번째 예제는 MySQL 데이터베이스에서 `VARCHAR`와 `DATE` 포맷의 스칼라 값만 반환하는 간단한 프로시저를 보여준다. 예제 프로시저는 지정한 actor 엔트리를 읽고 out 파라미터로 `first_name`, `last_name`, `birth_date` 컬럼을 반환한다:

```sql
CREATE PROCEDURE read_actor (
    IN in_id INTEGER,
    OUT out_first_name VARCHAR(100),
    OUT out_last_name VARCHAR(100),
    OUT out_birth_date DATE)
BEGIN
    SELECT first_name, last_name, birth_date
    INTO out_first_name, out_last_name, out_birth_date
    FROM t_actor where id = in_id;
END;
```

`in_id` 파라미터엔 조회하려는 actor의 `id`가 담긴다. `out` 파라미터는 테이블에서 읽어온 데이터를 반환한다.

`SimpleJdbcCall`을 선언하는 방법도 `SimpleJdbcInsert`와 비슷하다. 데이터 접근 레이어의 초기화 메소드에서 클래스 인스턴스를 만들고 설정해야 한다. `StoredProcedure` 클래스와 비교해보면, 하위 클래스를 만들 필요가 없으며, 데이터베이스 메타데이터에서 조회할 수 있는 파라미터는 선언을 생략해도 된다. 다음은 앞에 있는 저장 프로시저를 설정한 `SimpleJdbcCall` 예제다 (`DataSource` 외에 유일한 설정 옵션은 저장 프로시저 이름이다):

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
public class JdbcActorDao implements ActorDao {

    private SimpleJdbcCall procReadActor;

    public void setDataSource(DataSource dataSource) {
        this.procReadActor = new SimpleJdbcCall(dataSource)
                .withProcedureName("read_actor");
    }

    public Actor readActor(Long id) {
        SqlParameterSource in = new MapSqlParameterSource()
                .addValue("in_id", id);
        Map out = procReadActor.execute(in);
        Actor actor = new Actor();
        actor.setId(id);
        actor.setFirstName((String) out.get("out_first_name"));
        actor.setLastName((String) out.get("out_last_name"));
        actor.setBirthDate((Date) out.get("out_birth_date"));
        return actor;
    }

    // ... additional methods
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
class JdbcActorDao(dataSource: DataSource) : ActorDao {

    private val procReadActor = SimpleJdbcCall(dataSource)
            .withProcedureName("read_actor")


    fun readActor(id: Long): Actor {
        val source = MapSqlParameterSource().addValue("in_id", id)
        val output = procReadActor.execute(source)
        return Actor(
                id,
                output["out_first_name"] as String,
                output["out_last_name"] as String,
                output["out_birth_date"] as Date)
    }

        // ... additional methods
}
```

프로시저를 호출할 땐 IN 파라미터를 가진 `SqlParameterSource`를 만드는 코드를 작성하게 된다. 입력 값에 제공한 이름은 저장 프로시저에 선언한 파라미터명과 일치해야 한다. 저장 프로시저에서 참조할 데이터베이스 객체를 결정할 땐 메타데이터를 사용하므로 대소문자는 일치하지 않아도 된다. 저장 프로시저에 지정한 내용이 항상 그대로 데이터베이스에 저장되는 건 아니다. 이름을 모두 대문자로 변환하는 데이터베이스도 있고, 데이터베이스에 따라 소문자를 사용하거나 지정한 대소문자를 유지하기도 한다.

`execute` 메소드는 IN 파라미터를 받아 저장 프로시저에 지정한 모든 `out` 파라미터를 반환한다. 반환 타입은 `Map`으로, 파라미터명을 키로 가지고 있다. 이 예제에선 `out_first_name`, `out_last_name`, `out_birth_date`를 가지고 있다.

`execute` 메소드에선 마지막에, 조회한 데이터를 반환하기 위한 `Actor` 인스턴스를 생성한다. 다시 말하지만, `out` 파라미터 이름은 저장 프로시저에서 선언한대로 사용해야 한다. 추가로, 결과 맵에 저장된 `out` 파라미터 이름은 데이터베이스의 `out` 파라미터명의 대소문자를 따르는데, 이는 데이터베이스마다 다를 수 있다. 데이터베이스 의존성을 줄이려면 직접 대소문자를 무시하고 조회해가거나 스프링이 `LinkedCaseInsensitiveMap`을 사용하도록 만들어야 한다. 후자는 자체 `JdbcTemplate`을 만들고 `setResultsMapCaseInsensitive` 프로퍼티를 `true`로 설정하면 된다. 그런 다음 이 커스텀 `JdbcTemplate` 인스턴스를 `SimpleJdbcCall` 생성자에 전달해라. 다음 예제를 참고해라:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
public class JdbcActorDao implements ActorDao {

    private SimpleJdbcCall procReadActor;

    public void setDataSource(DataSource dataSource) {
        JdbcTemplate jdbcTemplate = new JdbcTemplate(dataSource);
        jdbcTemplate.setResultsMapCaseInsensitive(true);
        this.procReadActor = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("read_actor");
    }

    // ... additional methods
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
class JdbcActorDao(dataSource: DataSource) : ActorDao {

    private var procReadActor = SimpleJdbcCall(JdbcTemplate(dataSource).apply {
        isResultsMapCaseInsensitive = true
    }).withProcedureName("read_actor")

    // ... additional methods
}
```

이러게 하면 더이상 대소문자로 인해 `out` 파라미터 이름이 충돌하지 않는다.

### 3.6.6. Explicitly Declaring Parameters to Use for a `SimpleJdbcCall`

앞에서 메타데이터로 파라미터를 추론하는 법을 설명했지만, 원한다면 파라미터를 명시할 수 있다. 이땐 `SimpleJdbcCall`을 생성하고 설정하면서 여러 가지 `SqlParameter` 객체를 받는 `declareParameters` 메소드를 사용하면 된다. `SqlParameter`를 정의하는 자세한 방법은 [다음 섹션](#367-how-to-define-sqlparameters)을 참고해라.

> 스프링이 지원하지 않는 데이터베이스를 사용한다면 선언을 명시해야 한다. 현재 스프링이 저장 프로시저를 호출할 때 메타데이터를 조회하는 데이터베이스는 아파치 Derby, DB2, MySQL, 마이크로소프트 SQL 서버, 오라클, Sybase다. MySQL, 마이크로소프트 SQL 서버, 오라클에선 저장 함수 메타데이터 조회도 지원한다.

파라미터는 전부 명시해도 되고, 하나나 일부만 명시해도 된다. 명시하지 않은 파라미터는 메타데이터를 사용하게 된다. 파라미터 메타데이터는 조회는 건너뛰고 직접 선언한 파라미터만 사용하고 싶다면, 선언부에서 `withoutProcedureColumnMetaDataAccess` 메소드를 호출하면 된다. 데이터베이스 함수에 서로 다른 호출 시그니처가 둘 이상 있다고 생각해보자. 이럴땐 `useInParameterNames`를 호출해서 주어진 시그니처에 사용할 IN 파라미터 이름 리스트를 지정하면 된다.

다음 예제는 모든 파라미터를 선언한 프로시저 호출을 정의하며, 이전 예제에서 사용했던 정보를 그대로 사용한다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
public class JdbcActorDao implements ActorDao {

    private SimpleJdbcCall procReadActor;

    public void setDataSource(DataSource dataSource) {
        JdbcTemplate jdbcTemplate = new JdbcTemplate(dataSource);
        jdbcTemplate.setResultsMapCaseInsensitive(true);
        this.procReadActor = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("read_actor")
                .withoutProcedureColumnMetaDataAccess()
                .useInParameterNames("in_id")
                .declareParameters(
                        new SqlParameter("in_id", Types.NUMERIC),
                        new SqlOutParameter("out_first_name", Types.VARCHAR),
                        new SqlOutParameter("out_last_name", Types.VARCHAR),
                        new SqlOutParameter("out_birth_date", Types.DATE)
                );
    }

    // ... additional methods
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
class JdbcActorDao(dataSource: DataSource) : ActorDao {

        private val procReadActor = SimpleJdbcCall(JdbcTemplate(dataSource).apply {
            isResultsMapCaseInsensitive = true
        }).withProcedureName("read_actor")
                .withoutProcedureColumnMetaDataAccess()
                .useInParameterNames("in_id")
                .declareParameters(
                        SqlParameter("in_id", Types.NUMERIC),
                        SqlOutParameter("out_first_name", Types.VARCHAR),
                        SqlOutParameter("out_last_name", Types.VARCHAR),
                        SqlOutParameter("out_birth_date", Types.DATE)
    )

        // ... additional methods
}
```

두 예제에서 실행되는 프로시저와 최종 결과는 동일하다. 두 번째 예제에서는 메타데이터에 의존하지 않고 모든 세부 정보를 명시했다.

### 3.6.7. How to Define `SqlParameters`

`SimpleJdbc` 클래스와 RDBMS 연산 클래스([JDBC 연산을 자바 객체로 모델링하기](#37-modeling-jdbc-operations-as-java-objects)에서 다룬다)에서 사용할 파라미터는 `SqlParameter`나 하위 클래스 중 하나로 정의할 수 있다. 이땐 보통 생성자로 파라미터 이름과 SQL 타입을 지정한다. SQL 타입은 `java.sql.Types` 상수로 지정한다. 이 챕터 앞에서 이미 아래와 유사한 코드를 살펴봤었다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
new SqlParameter("in_id", Types.NUMERIC),
new SqlOutParameter("out_first_name", Types.VARCHAR),
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
SqlParameter("in_id", Types.NUMERIC),
SqlOutParameter("out_first_name", Types.VARCHAR),
```

`SqlParameter`가 있는 첫 번째 라인에선 IN 파라미터를 선언한다. IN 파라미터로 저장 프로시저를 호출할 수도 있고, `SqlQuery`과 하위 클래스([`SqlQuery` 이해하기](#371-understanding-sqlquery)에서 다룬다)를 사용해 질의할 수도 있다.

`SqlOutParameter`를 사용한 두 번째 라인에선 저장 프로시저 호출에 사용할 `out` 파라미터를 선언한다. `InOut` 파라미터를 위한 `SqlInOutParameter`도 지원한다 (프로시저에 IN 값을 제공하면서 동시에 값을 반환하는 파라미터).

> 입력 값을 제공할 땐 `SqlParameter`와 `SqlInOutParameter`로 선언한 파라미터만 사용한다.  `StoredProcedure` 클래스와는 동작이 다른데,  `StoredProcedure`는 구버전과의 호환을 위해 `SqlOutParameter`로 선언한 파라미터에 입력 값을 제공할 수 있다.

IN 파라미터에선 이름과 SQL 타입 외에도, 숫자 데이터의 스케일이나 커스텀 데이터베이스 타입 이름을 지정할 수 있다. `out` 파라미터엔 `REF` 커서가 반환한 row를 매핑할 `RowMapper`를 제공할 수 있다. 더불어 `out` 파라미터엔 `SqlReturnType`을 지정해 반환 값 처리 로직을 커스텀할 수 있다.

### 3.6.8. Calling a Stored Function by Using `SimpleJdbcCall`

저장 함수를 호출하는 방법도, 프로시저 이름이 아닌 함수 이름을 제공한다는 점만 빼면 저장 프로시저와 거의 동일하다. 설정부에서 `withFunctionName` 메소드를 사용해 함수를 호출할 것임을 알려주면 함수 호출에 해당하는 문자열을 설정한다. 함수를 실행할 땐 전용 메소드(`executeFunction`)를 사용하며, 이 메소드는 함수의 반환 값을 지정한 객체 타입으로 반환한다. 따라서 반환 값을 맵에서 조회하지 않아도 된다. `out` 파라미터가 하나만 있는 저장 프로시저에서도 유사한 편의 메소드(`executObject`)를 사용할 수 있다. 다음 예제(MySQL)는 actor의 풀 네임을 반환하는 `get_actor_name`이란 저장 함수를 사용한다:

```sql
CREATE FUNCTION get_actor_name (in_id INTEGER)
RETURNS VARCHAR(200) READS SQL DATA
BEGIN
    DECLARE out_name VARCHAR(200);
    SELECT concat(first_name, ' ', last_name)
        INTO out_name
        FROM t_actor where id = in_id;
    RETURN out_name;
END;
```

초기화 메소드에서 이 함수를 호출하는 `SimpleJdbcCall`을 다시 만들어보자:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
public class JdbcActorDao implements ActorDao {

    private JdbcTemplate jdbcTemplate;
    private SimpleJdbcCall funcGetActorName;

    public void setDataSource(DataSource dataSource) {
        this.jdbcTemplate = new JdbcTemplate(dataSource);
        JdbcTemplate jdbcTemplate = new JdbcTemplate(dataSource);
        jdbcTemplate.setResultsMapCaseInsensitive(true);
        this.funcGetActorName = new SimpleJdbcCall(jdbcTemplate)
                .withFunctionName("get_actor_name");
    }

    public String getActorName(Long id) {
        SqlParameterSource in = new MapSqlParameterSource()
                .addValue("in_id", id);
        String name = funcGetActorName.executeFunction(String.class, in);
        return name;
    }

    // ... additional methods
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
class JdbcActorDao(dataSource: DataSource) : ActorDao {

    private val jdbcTemplate = JdbcTemplate(dataSource).apply {
        isResultsMapCaseInsensitive = true
    }
    private val funcGetActorName = SimpleJdbcCall(jdbcTemplate)
            .withFunctionName("get_actor_name")

    fun getActorName(id: Long): String {
        val source = MapSqlParameterSource().addValue("in_id", id)
        return funcGetActorName.executeFunction(String::class.java, source)
    }

    // ... additional methods
}
```

여기서 사용한 `executeFunction` 메소드는 함수 호출이 반환한 값을 가진 `String`을 리턴한다.

### 3.6.9. Returning a `ResultSet` or REF Cursor from a `SimpleJdbcCall`

결과 셋을 반환하는 저장 프로시저나 함수를 호출하는 건 좀 까다롭다. 어떤 데이터베이스는 JDBC 결과 처리 중에 결과 셋을 반환하고, 어떤 데이터베이스엔 타입을 특정한 `out` 파라미터를 등록해야 한다. 두 방법 다 결과 셋을 순회하고 반환된 행을 처리하려면 추가 처리가 필요하다. `SimpleJdbcCall`은 `returningResultSet` 메소드로 특정 파라미터에 사용할 `RowMapper` 구현체를 선언할 수 있다. 결과를 처리하는 도중에 반환된 결과 셋엔 이름이 지정돼 있지 않기 때문에 `RowMapper` 구현체는 반환된 결과와 동일한 순서로 선언해야 한다. 지정한 파라미터 이름은 `execute` 구문이 반환할 결과 맵에 처리한 결과 셋을 저장할 때 이어서 사용한다.

다음 예제(MySQL)는 IN 파라미터를 받지 않고 `t_actor` 테이블의 모든 row를 반환하는 저장 프로시저를 사용한다:

```sql
CREATE PROCEDURE read_all_actors()
BEGIN
 SELECT a.id, a.first_name, a.last_name, a.birth_date FROM t_actor a;
END;
```

이 프로시저를 호출하려면 `RowMapper`를 선언하면 된다. 매핑할 클래스가 자바빈 규칙을 따르기 때문에, `BeanPropertyRowMapper`를 만들어 사용할 수 있다. 이때는 `newInstance` 메소드에 매핑할 클래스를 전달하면 된다. 다음 예제를 참고해라:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
public class JdbcActorDao implements ActorDao {

    private SimpleJdbcCall procReadAllActors;

    public void setDataSource(DataSource dataSource) {
        JdbcTemplate jdbcTemplate = new JdbcTemplate(dataSource);
        jdbcTemplate.setResultsMapCaseInsensitive(true);
        this.procReadAllActors = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("read_all_actors")
                .returningResultSet("actors",
                BeanPropertyRowMapper.newInstance(Actor.class));
    }

    public List getActorsList() {
        Map m = procReadAllActors.execute(new HashMap<String, Object>(0));
        return (List) m.get("actors");
    }

    // ... additional methods
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
class JdbcActorDao(dataSource: DataSource) : ActorDao {

        private val procReadAllActors = SimpleJdbcCall(JdbcTemplate(dataSource).apply {
            isResultsMapCaseInsensitive = true
        }).withProcedureName("read_all_actors")
                .returningResultSet("actors",
                        BeanPropertyRowMapper.newInstance(Actor::class.java))

    fun getActorsList(): List<Actor> {
        val m = procReadAllActors.execute(mapOf<String, Any>())
        return m["actors"] as List<Actor>
    }

    // ... additional methods
}
```

호출하는 프로시저는 파라미터를 받지 않기 때문에 `execute` 메소드엔 비어있는 맵을 전달한다. 그런 다음 결과 맵에서 actor 리스트를 조회해 호출한 쪽으로 넘겨준다.

---

## 3.7. Modeling JDBC Operations as Java Objects

<span class="custom-blockquote">org.springframework.jdbc.object</span> 패키지엔 좀 더 객체 지향적인 방식으로 데이터베이스에 접근할 수 있는 클래스가 들어있다. 예를 들어 쿼리를 실행하고 결과를 가져올 때 관계형 컬럼 데이터를 비즈니스 객체의 프로퍼티에 매핑해, 비즈니스 객체를 리스트에 담아서 가져올 수 있다. 저장 프로시저를 실행하거나 update, delete,  insert 문도 실행할 수 있다.

> 아래에서 설명하는 여러 가지 RDBMS 연산 클래스([StoredProcedure](#374-using-storedprocedure) 클래스 제외)로 하는 일은 보통 `JdbcTemplate`을 직접 호출해도 가능할 거라 믿는다. DAO 메소드에서 직접 `JdbcTemplate` 메소드를 호출하는 게 (쿼리를 온전한 기능을 갖춘 클래스로 캡슐화하는 게 아니라) 더 간단할 때가 많다. 물론 RDBMS 연산 클래스 사용에 충분한 가치가 있다고 느끼면 사용해도 문제는 없다.

### 3.7.1. Understanding `SqlQuery`

`SqlQuery`는 SQL 쿼리를 캡슐화한, 재사용 가능하고 thread-safe한 클래스다. 하위 클래스는 `newRowMapper(..)` 메소드를 구현해 `RowMapper` 인스턴스를 제공해야 한다. `RowMapper`는 쿼리 실행 중에 만든 `ResultSet`을 순회해, row당 객체를 하나 생성한다. 하위 클래스 `MappingSqlQuery`를 사용하면 훨씬 더 편하게 row를 자바 클래스에 매핑할 수 있기 때문에 `SqlQuery` 클래스를 직접 사용하는 경우는 거의 없다. `SqlQuery`를 확장한 다른 구현체로는 `MappingSqlQueryWithParameters`와 `UpdatableSqlQuery`가 있다.

### 3.7.2. Using `MappingSqlQuery`

`MappingSqlQuery`는 재사용 가능한 쿼리로, 하위 클래스로 추상 메소드 `mapRow(..)`를 구현해서, 넘겨받은 `ResultSet`에 있는 각 row를 지정한 객체 타입으로 변환해야 한다. 다음 예제는 `t_actor` 테이블 데이터를 `Actor` 클래스 인스턴스에 매핑하는 커스텀 쿼리다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
public class ActorMappingQuery extends MappingSqlQuery<Actor> {

    public ActorMappingQuery(DataSource ds) {
        super(ds, "select id, first_name, last_name from t_actor where id = ?");
        declareParameter(new SqlParameter("id", Types.INTEGER));
        compile();
    }

    @Override
    protected Actor mapRow(ResultSet rs, int rowNumber) throws SQLException {
        Actor actor = new Actor();
        actor.setId(rs.getLong("id"));
        actor.setFirstName(rs.getString("first_name"));
        actor.setLastName(rs.getString("last_name"));
        return actor;
    }
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
class ActorMappingQuery(ds: DataSource) : MappingSqlQuery<Actor>(ds, "select id, first_name, last_name from t_actor where id = ?") {

    init {
        declareParameter(SqlParameter("id", Types.INTEGER))
        compile()
    }

    override fun mapRow(rs: ResultSet, rowNumber: Int) = Actor(
            rs.getLong("id"),
            rs.getString("first_name"),
            rs.getString("last_name")
    )
}
```

이 클래스는 `Actor` 타입을 파라미터로 사용해 `MappingSqlQuery`를 확장한다. 이 고객 쿼리의 생성자는 `DataSource`를 유일한 파라미터로 받는다. 이 생성자에선 상위 클래스의 생성자를 호출해서 `DataSource`와, row를 조회할 때 실행할 SQL을 넘길 수 있다. 이 SQL로 `PreparedStatement`를 만들기 때문에, 실행 중에 전달할 파라미터를 위한 플레이스홀더도 사용할 수 있다. 각 파라미터는 반드시 `SqlParameter`를 선언해 `declareParameter` 메소드에 전달해야 한다. `SqlParameter`는 파라미터 이름과 `java.sql.Types`에 정의된 JDBC 타입을 받는다. 모든 파라미터를 정의한 후 `compile()` 메소드를 호출하면, 구문이 준비되고 실행 가능한 상태가 된다. 이 클래스는 컴파일하고 나면 thread-safe하기 때문에, DAO를 초기화할 때 쿼리 인스턴스를 만들기만 하면, 인스턴스 변수로 유지하고 재사용할 수 있다. 다음은 쿼리 인스턴스를 변수로 정의한 클래스 예시다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
private ActorMappingQuery actorMappingQuery;

@Autowired
public void setDataSource(DataSource dataSource) {
    this.actorMappingQuery = new ActorMappingQuery(dataSource);
}

public Customer getCustomer(Long id) {
    return actorMappingQuery.findObject(id);
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
private val actorMappingQuery = ActorMappingQuery(dataSource)

fun getCustomer(id: Long) = actorMappingQuery.findObject(id)
```

예제에 있는 메소드는 유일한 파라미터로 전달한 `id`로 고객을 조회한다. 객체를 하나만 조회하려고 간편 메소드 ``findObject`` 메소드에 `id`를 파라미터를 넘겼다. 이와 달리 사용하는 쿼리가 객체 리스트를 반환하고 다른 파라미터도 받는다면, 가변인자로 전달한 파라미터 값의 배열을 사용하는 `execute` 메소드 중 하나를 사용하게 될 거다. 다음은 그 중 하나를 사용하는 예제다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
public List<Actor> searchForActors(int age, String namePattern) {
    List<Actor> actors = actorSearchMappingQuery.execute(age, namePattern);
    return actors;
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
fun searchForActors(age: Int, namePattern: String) =
            actorSearchMappingQuery.execute(age, namePattern)
```

### 3.7.3. Using `SqlUpdate`

`SqlUpdate` 클래스는 SQL 업데이트를 캡슐화한다. 쿼리와 마찬가지로 업데이트 객체는 재사용할 수 있으며, 모든 `RdbmsOperation` 클래스가 그렇듯 업데이트에는 파라미터가 있을 수 있으며 SQL로 정의한다. 이 클래스는 쿼리 객체의 `execute(..)` 메소드와 유사한 여러 가지 `update(..)` 메소드를 제공한다. `SQLUpdate` 클래스는 추상 클래스가 아니다. 필요하면 하위 클래스로 상속해도 된다 — 예를 들어 커스텀 업데이트 메소드를 추가하려면. 하지만 SQL을 설정하고 파라미터를 선언하면 쉽게 쿼리에 파라미터를 만들 수 있기 때문에 굳이 `SqlUpdate` 클래스를 다시 상속할 필욘 없다. 다음 예제에서는 `execute`라는 커스텀 업데이트 메소드를 만든다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
import java.sql.Types;
import javax.sql.DataSource;
import org.springframework.jdbc.core.SqlParameter;
import org.springframework.jdbc.object.SqlUpdate;

public class UpdateCreditRating extends SqlUpdate {

    public UpdateCreditRating(DataSource ds) {
        setDataSource(ds);
        setSql("update customer set credit_rating = ? where id = ?");
        declareParameter(new SqlParameter("creditRating", Types.NUMERIC));
        declareParameter(new SqlParameter("id", Types.NUMERIC));
        compile();
    }

    /**
     * @param id for the Customer to be updated
     * @param rating the new value for credit rating
     * @return number of rows updated
     */
    public int execute(int id, int rating) {
        return update(rating, id);
    }
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
import java.sql.Types
import javax.sql.DataSource
import org.springframework.jdbc.core.SqlParameter
import org.springframework.jdbc.object.SqlUpdate

class UpdateCreditRating(ds: DataSource) : SqlUpdate() {

    init {
        setDataSource(ds)
        sql = "update customer set credit_rating = ? where id = ?"
        declareParameter(SqlParameter("creditRating", Types.NUMERIC))
        declareParameter(SqlParameter("id", Types.NUMERIC))
        compile()
    }

    /**
    * @param id for the Customer to be updated
    * @param rating the new value for credit rating
    * @return number of rows updated
    */
    fun execute(id: Int, rating: Int): Int {
        return update(rating, id)
    }
}
```

### 3.7.4. Using `StoredProcedure`

`StoredProcedure` 클래스는 RDBMS 저장 프로시저를 객체로 추상화한 상위 클래스다. 이 클래스는 `abstract`이며 `protected` 접근 권한을 가지고 있어서, 다양한 `execute(..)` 메소드는 더 엄격한 타이핑을 제공하는 하위 클래스를 통하지 않고는 사용할 수 없다.

상속받은 `sql` 프로퍼티는 RDBMS에 있는 저장 프로시저 이름이다.

`StoredProcedure` 클래스에서 사용할 파라미터를 정의하려면 `SqlParameter`나 하위 클래스 중 하나를 사용하면 된다. 아래 코드에서처럼 생성자로 파라미터 이름과 SQL 타입을 지정해야 한다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
new SqlParameter("in_id", Types.NUMERIC),
new SqlOutParameter("out_first_name", Types.VARCHAR),
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
SqlParameter("in_id", Types.NUMERIC),
SqlOutParameter("out_first_name", Types.VARCHAR),
```

SQL 타입은 `java.sql.Types` 상수로 지정한다.

`SqlParameter`가 있는 첫 번째 라인에선 IN 파라미터를 선언한다. IN 파라미터로 저장 프로시저를 호출할 수도 있고, `SqlQuery`과 하위 클래스([`SqlQuery` 이해하기](#371-understanding-sqlquery)에서 다룬다)를 사용해 질의할 수도 있다.

`SqlOutParameter`를 사용한 두 번째 라인에선 저장 프로시저 호출에 사용할 `out` 파라미터를 선언한다. `InOut` 파라미터를 위한 `SqlInOutParameter`도 지원한다 (프로시저에 `in` 값을 제공하면서 동시에 값을 반환하는 파라미터).

`in` 파라미터에선 이름과 SQL 타입 외에도, 숫자 데이터의 스케일이나 커스텀 데이터베이스 타입 이름을 지정할 수 있다. `out` 파라미터엔 `REF` 커서가 반환한 row를 매핑할 `RowMapper`를 제공할 수 있다. 더불어 `out` 파라미터엔 `SqlReturnType`을 지정해 반환 값 처리 로직을 커스텀할 수 있다.

다음 예제는 `StoredProcedure`를 사용하는 간단한 DAO로, 오라클 데이터베이스가 기본 제공하는 함수(`sysdate()`)를 호출한다. 저장 프로시저 기능을 사용하려면 `StoredProcedure`를 확장한 클래스를 만들어야 한다. 이 예제에선 `StoredProcedure` 클래스는 내부 클래스지만, `StoredProcedure`를 재사용해야 한다면 최상위 클래스로 선언해도 된다. 이 예제는 입력 파라미터는 없지만 출력 파라미터는 `SqlOutParameter` 클래스를 사용해 날짜 타입으로 선언했다. `execute()` 메소드는 프로시저를 실행하고 결과 `Map`에서 반환된 날짜를 추출한다. 결과 `Map`은 선언한 각 출력 파라미터(여기선 딱 하나) 엔트리를 가지고 있으며, 키는 파라미터 이름이다. 이 커스텀 `StoredProcedure` 클래스는 바로 아래에 있다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
import java.sql.Types;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import javax.sql.DataSource;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.SqlOutParameter;
import org.springframework.jdbc.object.StoredProcedure;

public class StoredProcedureDao {

    private GetSysdateProcedure getSysdate;

    @Autowired
    public void init(DataSource dataSource) {
        this.getSysdate = new GetSysdateProcedure(dataSource);
    }

    public Date getSysdate() {
        return getSysdate.execute();
    }

    private class GetSysdateProcedure extends StoredProcedure {

        private static final String SQL = "sysdate";

        public GetSysdateProcedure(DataSource dataSource) {
            setDataSource(dataSource);
            setFunction(true);
            setSql(SQL);
            declareParameter(new SqlOutParameter("date", Types.DATE));
            compile();
        }

        public Date execute() {
            // the 'sysdate' sproc has no input parameters, so an empty Map is supplied...
            Map<String, Object> results = execute(new HashMap<String, Object>());
            Date sysdate = (Date) results.get("date");
            return sysdate;
        }
    }

}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
import java.sql.Types
import java.util.Date
import java.util.Map
import javax.sql.DataSource
import org.springframework.jdbc.core.SqlOutParameter
import org.springframework.jdbc.object.StoredProcedure

class StoredProcedureDao(dataSource: DataSource) {

    private val SQL = "sysdate"

    private val getSysdate = GetSysdateProcedure(dataSource)

    val sysdate: Date
        get() = getSysdate.execute()

    private inner class GetSysdateProcedure(dataSource: DataSource) : StoredProcedure() {

        init {
            setDataSource(dataSource)
            isFunction = true
            sql = SQL
            declareParameter(SqlOutParameter("date", Types.DATE))
            compile()
        }

        fun execute(): Date {
            // the 'sysdate' sproc has no input parameters, so an empty Map is supplied...
            val results = execute(mutableMapOf<String, Any>())
            return results["date"] as Date
        }
    }
}
```

다음 예제에 있는 `StoredProcedure`는 출력 파라미터를 두 개 사용한다 (여기선 오라클 REF 커서):

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
import java.util.HashMap;
import java.util.Map;
import javax.sql.DataSource;
import oracle.jdbc.OracleTypes;
import org.springframework.jdbc.core.SqlOutParameter;
import org.springframework.jdbc.object.StoredProcedure;

public class TitlesAndGenresStoredProcedure extends StoredProcedure {

    private static final String SPROC_NAME = "AllTitlesAndGenres";

    public TitlesAndGenresStoredProcedure(DataSource dataSource) {
        super(dataSource, SPROC_NAME);
        declareParameter(new SqlOutParameter("titles", OracleTypes.CURSOR, new TitleMapper()));
        declareParameter(new SqlOutParameter("genres", OracleTypes.CURSOR, new GenreMapper()));
        compile();
    }

    public Map<String, Object> execute() {
        // again, this sproc has no input parameters, so an empty Map is supplied
        return super.execute(new HashMap<String, Object>());
    }
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
import java.util.HashMap
import javax.sql.DataSource
import oracle.jdbc.OracleTypes
import org.springframework.jdbc.core.SqlOutParameter
import org.springframework.jdbc.object.StoredProcedure

class TitlesAndGenresStoredProcedure(dataSource: DataSource) : StoredProcedure(dataSource, SPROC_NAME) {

    companion object {
        private const val SPROC_NAME = "AllTitlesAndGenres"
    }

    init {
        declareParameter(SqlOutParameter("titles", OracleTypes.CURSOR, TitleMapper()))
        declareParameter(SqlOutParameter("genres", OracleTypes.CURSOR, GenreMapper()))
        compile()
    }

    fun execute(): Map<String, Any> {
        // again, this sproc has no input parameters, so an empty Map is supplied
        return super.execute(HashMap<String, Any>())
    }
}
```

`TitlesAndGenresStoredProcedure` 생성자에서 사용한 오버드딩 메소드 `declareParameter(..)`에 `RowMapper` 구현체 인스턴스를 전달한 방법을 주목해라. 이렇게 하면 간편하면서도 완벽하게 기존 기능을 재사용할 수 있다. 다음 예제에서 이어서 두 가지 `RowMapper` 구현체를 보여주겠다:

`TitleMapper` 클래스는 전달받은 `ResultSet`에 있는 row를 `Title`이란 도메인 객체로 매핑한다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
import java.sql.ResultSet;
import java.sql.SQLException;
import com.foo.domain.Title;
import org.springframework.jdbc.core.RowMapper;

public final class TitleMapper implements RowMapper<Title> {

    public Title mapRow(ResultSet rs, int rowNum) throws SQLException {
        Title title = new Title();
        title.setId(rs.getLong("id"));
        title.setName(rs.getString("name"));
        return title;
    }
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
import java.sql.ResultSet
import com.foo.domain.Title
import org.springframework.jdbc.core.RowMapper

class TitleMapper : RowMapper<Title> {

    override fun mapRow(rs: ResultSet, rowNum: Int) =
            Title(rs.getLong("id"), rs.getString("name"))
}
```

`GenreMapper` 클래스는 전달받은 `ResultSet`에 있는 row를 `Genre`란 도메인 객체로 매핑한다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
import java.sql.ResultSet;
import java.sql.SQLException;
import com.foo.domain.Genre;
import org.springframework.jdbc.core.RowMapper;

public final class GenreMapper implements RowMapper<Genre> {

    public Genre mapRow(ResultSet rs, int rowNum) throws SQLException {
        return new Genre(rs.getString("name"));
    }
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
import java.sql.ResultSet
import com.foo.domain.Genre
import org.springframework.jdbc.core.RowMapper

class GenreMapper : RowMapper<Genre> {

    override fun mapRow(rs: ResultSet, rowNum: Int): Genre {
        return Genre(rs.getString("name"))
    }
}
```

RDBMS 정의 상 하나 이상의 입력 파라미터를 받는 저장 프로시저에 파라미터를 전달하려면, 다음과 같이 타입을 지정한 `execute(..)` 메소드를 만들어 타입이 없는 상위 클래스의 `execute(Map)` 메소드에 위임하면 된다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
import java.sql.Types;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import javax.sql.DataSource;
import oracle.jdbc.OracleTypes;
import org.springframework.jdbc.core.SqlOutParameter;
import org.springframework.jdbc.core.SqlParameter;
import org.springframework.jdbc.object.StoredProcedure;

public class TitlesAfterDateStoredProcedure extends StoredProcedure {

    private static final String SPROC_NAME = "TitlesAfterDate";
    private static final String CUTOFF_DATE_PARAM = "cutoffDate";

    public TitlesAfterDateStoredProcedure(DataSource dataSource) {
        super(dataSource, SPROC_NAME);
        declareParameter(new SqlParameter(CUTOFF_DATE_PARAM, Types.DATE);
        declareParameter(new SqlOutParameter("titles", OracleTypes.CURSOR, new TitleMapper()));
        compile();
    }

    public Map<String, Object> execute(Date cutoffDate) {
        Map<String, Object> inputs = new HashMap<String, Object>();
        inputs.put(CUTOFF_DATE_PARAM, cutoffDate);
        return super.execute(inputs);
    }
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
import java.sql.Types
import java.util.Date
import javax.sql.DataSource
import oracle.jdbc.OracleTypes
import org.springframework.jdbc.core.SqlOutParameter
import org.springframework.jdbc.core.SqlParameter
import org.springframework.jdbc.object.StoredProcedure

class TitlesAfterDateStoredProcedure(dataSource: DataSource) : StoredProcedure(dataSource, SPROC_NAME) {

    companion object {
        private const val SPROC_NAME = "TitlesAfterDate"
        private const val CUTOFF_DATE_PARAM = "cutoffDate"
    }

    init {
        declareParameter(SqlParameter(CUTOFF_DATE_PARAM, Types.DATE))
        declareParameter(SqlOutParameter("titles", OracleTypes.CURSOR, TitleMapper()))
        compile()
    }

    fun execute(cutoffDate: Date) = super.execute(
            mapOf<String, Any>(CUTOFF_DATE_PARAM to cutoffDate))
}

```

---

## 3.8. Common Problems with Parameter and Data Value Handling

파라미터와 데이터 값과 관련된 이슈는, 스프링 프레임워크 JDBC에서 제공하는 기능 곳곳에서 자주들 겪는 문제다. 이번 섹션에선 그 해결 방법을 다룬다.

### 3.8.1. Providing SQL Type Information for Parameters

보통 스프링은 파라미터에 사용할 SQL 타입을, 전달받은 파라미터 타입에 따라 결정한다. 파라미터 값을 설정할 땐 사용할 SQL 타입을 직접 명시하는 것도 가능하다. `NULL` 값을 제대로 설정하려면 이렇게 명시해줘야 할 수도 있다.

SQL 타입 정보는 여러 가지 방법으로 제공할 수 있다:

- `JdbcTemplate`에 있는 여러 가지 업데이트, 쿼리 메소드는 `int` 배열 타입 파라미터를 추가로 받는 메소드가 많다. 이 배열은 `java.sql.Types` 클래스의 상수 값으로, 해당 파라미터의 SQL 타입을 지정할 수 있다. 배열 안에는 파라미터 당 엔트리가 하나 씩 있어야 한다.
- SQL 타입 정보가 필요한 파라미터는 `SqlParameterValue` 클래스로 파라미터 값을 래핑할 수 있다. 먼저, 파라미터마다 새 인스턴스를 만들고, 생성자에 SQL 타입과 파라미터를 전달해라. 필수는 아니지만, 숫자 값에는 `scale` 파라미터를 제공할 수 있다.
- named 파라미터를 사용하는 메소드는 `SqlParameterSource` 구현체 `BeanPropertySqlParameterSource`와 `MapSqlParameterSource`를 사용할 수 있다. 둘 모두 named 파라미터 값에 사용할 SQL 타입을 등록할 수 있는 메소드를 제공한다.

### 3.8.2. Handling BLOB and CLOB objects

데이터베이스에는 이미지같은 바이너리 데이터와 매우 큰 텍스트 청크를 저장할 수 있다. 이렇게 큰 객체는, 바이너리 데이터는 BLOB(Binary Large OBject), 문자 데이터는 CLOB(Character Large OBject)이라고 부른다. 스프링에선 이렇게 큰 객체는 `JdbcTemplate`으로 직접 처리할 수도 있고, 좀 더 고수준으로 추상화한 RDBMS 객체와 `SimpleJdbc` 클래스로도 처리할 수 있다. 실제 LOB(Large OBject) 데이터 관리는 모두 `LobHandler` 인터페이스 구현체를 사용한다. `LobHandler`는 `getLobCreator` 메소드로 `LobCreator` 클래스를 제공한다. `LobCreator` 클래스로는 데이터베이스 저장할 새 LOB 객체를 생성할 수 있다.

`LobCreator`와 `LobHandler`는 다음과 같은 LOB 입출력을 지원한다:

- BLOB
  - `byte[]`: `getBlobAsBytes`, `setBlobAsBytes`
  - `InputStream`: `getBlobAsBinaryStream`, `setBlobAsBinaryStream`
- CLOB
  - `String`: `getClobAsString`, `setClobAsString`
  - `InputStream`: `getClobAsAsciiStream`, `setClobAsAsciiStream`
  - `Reader`: `getClobAsCharacterStream`, `setClobAsCharacterStream`

다음 예제는 BLOB를 만들고 저장하는 방법을 보여준다. 데이터베이스에서 다시 읽어오는 방법은 뒤에서 보여주겠다.

이 예제는 `JdbcTemplate`과 `AbstractLobCreatingPreparedStatementCallback` 구현체를 사용한다. 여기선 `setValues` 메소드 하나만 구현한다. 이 메소드는 SQL insert 문에 LOB 컬럼 값을 설정할 수 있는 `LobCreator`를 제공한다.

여기서는 이미 `DefaultLobHandler` 인스턴스로 설정한 `lobHandler` 변수가 있다고 가정한다. 보통 `lobHandler`는 의존성 주입으로 설정한다.

다음은 BLOB을 만들고 저장하는 예제다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
final File blobIn = new File("spring2004.jpg");
final InputStream blobIs = new FileInputStream(blobIn);
final File clobIn = new File("large.txt");
final InputStream clobIs = new FileInputStream(clobIn);
final InputStreamReader clobReader = new InputStreamReader(clobIs);

jdbcTemplate.execute(
        "INSERT INTO lob_table (id, a_clob, a_blob) VALUES (?, ?, ?)",
        new AbstractLobCreatingPreparedStatementCallback(lobHandler) { // (1)
        protected void setValues(PreparedStatement ps, LobCreator lobCreator) throws SQLException {
            ps.setLong(1, 1L);
            lobCreator.setClobAsCharacterStream(ps, 2, clobReader, (int)clobIn.length()); // (2)
            lobCreator.setBlobAsBinaryStream(ps, 3, blobIs, (int)blobIn.length()); // (3)
        }
    }
);

blobIs.close();
clobReader.close();
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
val blobIn = File("spring2004.jpg")
val blobIs = FileInputStream(blobIn)
val clobIn = File("large.txt")
val clobIs = FileInputStream(clobIn)
val clobReader = InputStreamReader(clobIs)

jdbcTemplate.execute(
        "INSERT INTO lob_table (id, a_clob, a_blob) VALUES (?, ?, ?)",
        object: AbstractLobCreatingPreparedStatementCallback(lobHandler) {  // (1)
            override fun setValues(ps: PreparedStatement, lobCreator: LobCreator) {
                ps.setLong(1, 1L)
                lobCreator.setClobAsCharacterStream(ps, 2, clobReader, clobIn.length().toInt())  // (2)
                lobCreator.setBlobAsBinaryStream(ps, 3, blobIs, blobIn.length().toInt())  // (3)
            }
        }
)
blobIs.close()
clobReader.close()
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `lobHandler`를 넘긴다. 이 예제에선 기본 `DefaultLobHandler`를 사용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> CLOB 컨텐츠는 `setClobAsCharacterStream` 메소드로 전달한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> BLOB 컨텐츠는 `setBlobAsBinaryStream` 메소드로 전달한다.</small>

> `DefaultLobHandler.getLobCreator()`가 반환한 `LobCreator`로 `setBlobAsBinaryStream`이나, `setClobAsAsciiStream`, `setClobAsCharacterStream` 메소드를 호출할 땐 `contentLength` 인자에 음수 값을 지정해도 된다. 컨텐츠 길이를 음수로 지정하면 `DefaultLobHandler`는 length 파라미터를 받지 않는 JDBC 4.0 set-stream 메소드를 사용한다. 그 외는 드라이버에 지정한 길이를 전달한다.
>
> 실제로 컨텐츠 길이 없이도 LOB 스트리밍을 지원하는지는, 사용하는 JDBC 드라이버 문서를 확인해봐야 한다.

이제 데이터베이스에서 LOB 데이터를 읽을와볼 차례다. 여기서도 `DefaultLobHandler`를 참조하는 동일한  `lobHandler` 인스턴스 변수와 `JdbcTemplate`을 사용한다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
List<Map<String, Object>> l = jdbcTemplate.query("select id, a_clob, a_blob from lob_table",
    new RowMapper<Map<String, Object>>() {
        public Map<String, Object> mapRow(ResultSet rs, int i) throws SQLException {
            Map<String, Object> results = new HashMap<String, Object>();
            String clobText = lobHandler.getClobAsString(rs, "a_clob");  // (1)
            results.put("CLOB", clobText);
            byte[] blobBytes = lobHandler.getBlobAsBytes(rs, "a_blob");  // (2)
            results.put("BLOB", blobBytes);
            return results;
        }
    });
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
val l = jdbcTemplate.query("select id, a_clob, a_blob from lob_table") { rs, _ ->
    val clobText = lobHandler.getClobAsString(rs, "a_clob")  // (1)
    val blobBytes = lobHandler.getBlobAsBytes(rs, "a_blob")  // (2)
    mapOf("CLOB" to clobText, "BLOB" to blobBytes)
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> CLOB 컨텐츠는 `getClobAsString` 메소드로 조회한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> BLOB 컨텐츠는 `getBlobAsBytes` 메소드로 조회한다.</small>

### 3.8.3. Passing in Lists of Values for IN Clause

SQL 표준에 따르면 row를 조회하기 위한 표현식엔 변수 값의 리스트를 사용할 수 있다. 대표적인 예를 들면 <span class="custom-blockquote">select * from T_ACTOR where id in (1, 2, 3)</span>을 들 수 있다. 하지만 JDBC 표준 prepared 구문에는 변수 리스트를 바로 사용할 수 없다. 플레이스홀더는 고정된 횟수만 선언할 수 있다. 플레이스홀더 갯수가 다른 구문을 여러 개 준비해두거나, 플레이스홀더가 몇 개 필요한지 알아낸 뒤에 SQL 문자열을 동적으로 생성해야 한다. `NamedParameterJdbcTemplate`, `JdbcTemplate`이 제공하는 named 파라미터 기능에선 후자를 사용한다. 이때는 원시 타입 객체를 `java.util.List`에 담아 전달할 수 있다. 전달한 리스트로 필요한 플레이스홀더를 추가하고, 구문 실행 중에 값을 전달한다.

> 값을 한 번에 많이 전달한다면 주의해야 한다. JDBC 표준에서 보장하는 `in` 표현식 리스트에 사용할 수 있는 값은 100개까지다. 100개보다 더 많이 지원하는 데이터베이스도 많지만, 보통은 허용치를 엄격히 제한한다. 예를 들어 오라클의 상한은 1000이다.

원시 타입의 리스트 말고도 객체 배열의 `java.util.List`도 사용할 수 있다. 객체 배열을 사용하면 <span class="custom-blockquote">select * from T_ACTOR where (id, last_name) in ((1, 'Johnson'), (2, 'Harrop'))</span>과 같이 `in` 절에 표현식을 여럿 정의할 수 있다. 물론, 데이터베이스가 이 구문을 지원해야 가능하다.

### 3.8.4. Handling Complex Types for Stored Procedure Calls

간혹 데이터베이스에 특화된 복잡한 타입을 사용해 저장 프로시저를 호출하기도 한다. 스프링은 저장 프로시저가 이런 타입을 반환할 땐 `SqlReturnType`으로, 저장 프로시저에 파라미터로 전달할 땐 `SqlTypeValue`로 처리한다.

`SqlReturnType` 인터페이스는 한 가지 메소드(`getTypeValue`)만 구현하면 된다. 이 인터페이스는 `SqlOutParameter`를 선언할 때 사용한다. 다음 예제에선 SQL 타입 오라클 `STRUCT`를  커스텀 타입 `ITEM_TYPE`으로 선언하고, 여기에 있는 값을 반환한다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
public class TestItemStoredProcedure extends StoredProcedure {

    public TestItemStoredProcedure(DataSource dataSource) {
        // ...
        declareParameter(new SqlOutParameter("item", OracleTypes.STRUCT, "ITEM_TYPE",
            (CallableStatement cs, int colIndx, int sqlType, String typeName) -> {
                STRUCT struct = (STRUCT) cs.getObject(colIndx);
                Object[] attr = struct.getAttributes();
                TestItem item = new TestItem();
                item.setId(((Number) attr[0]).longValue());
                item.setDescription((String) attr[1]);
                item.setExpirationDate((java.util.Date) attr[2]);
                return item;
            }));
        // ...
    }
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
class TestItemStoredProcedure(dataSource: DataSource) : StoredProcedure() {

    init {
        // ...
        declareParameter(SqlOutParameter("item", OracleTypes.STRUCT, "ITEM_TYPE") { cs, colIndx, sqlType, typeName ->
            val struct = cs.getObject(colIndx) as STRUCT
            val attr = struct.getAttributes()
            TestItem((attr[0] as Long, attr[1] as String, attr[2] as Date)
        })
        // ...
    }
}
```

`SqlTypeValue`를 사용해서 자바 객체(`TestItem`같은)에 있는 값을 저장 프로시저에 전달할 수도 있다. `SqlTypeValue` 인터페이스도 한 가지 메소드(`createTypeValue`)만 구현하면 된다. 이때는 활성 커넥션이 전달되므로, 이 커넥션를 사용해서 `StructDescriptor`나 `ArrayDescriptor` 인스턴스같은 데이터베이스 전용 객체를 만들면된다. 다음 예제는 `StructDescriptor` 인스턴스를 만든다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
final TestItem testItem = new TestItem(123L, "A test item",
        new SimpleDateFormat("yyyy-M-d").parse("2010-12-31"));

SqlTypeValue value = new AbstractSqlTypeValue() {
    protected Object createTypeValue(Connection conn, int sqlType, String typeName) throws SQLException {
        StructDescriptor itemDescriptor = new StructDescriptor(typeName, conn);
        Struct item = new STRUCT(itemDescriptor, conn,
        new Object[] {
            testItem.getId(),
            testItem.getDescription(),
            new java.sql.Date(testItem.getExpirationDate().getTime())
        });
        return item;
    }
};
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
val (id, description, expirationDate) = TestItem(123L, "A test item",
        SimpleDateFormat("yyyy-M-d").parse("2010-12-31"))

val value = object : AbstractSqlTypeValue() {
    override fun createTypeValue(conn: Connection, sqlType: Int, typeName: String?): Any {
        val itemDescriptor = StructDescriptor(typeName, conn)
        return STRUCT(itemDescriptor, conn,
                arrayOf(id, description, java.sql.Date(expirationDate.time)))
    }
}
```

이제 이 `SqlTypeValue`도 저장 프로시저를 호출할 때 사용할 입력 파라미터 맵에 추가할 수 있다.

`SqlTypeValue`는 오라클 저장 프로시저에 값 배열을 전달할 때도 활용할 수 있다. 오라클에는 값 배열에 사용해야 하는 자체 내부 `ARRAY` 클래스가 있으며, 다음 예제처럼 `SqlTypeValue`로 오라클 `ARRAY` 인스턴스를 만들고 자바 `ARRAY`로 값으로 채울 수 있다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
final Long[] ids = new Long[] {1L, 2L};

SqlTypeValue value = new AbstractSqlTypeValue() {
    protected Object createTypeValue(Connection conn, int sqlType, String typeName) throws SQLException {
        ArrayDescriptor arrayDescriptor = new ArrayDescriptor(typeName, conn);
        ARRAY idArray = new ARRAY(arrayDescriptor, conn, ids);
        return idArray;
    }
};
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
class TestItemStoredProcedure(dataSource: DataSource) : StoredProcedure() {

    init {
        val ids = arrayOf(1L, 2L)
        val value = object : AbstractSqlTypeValue() {
            override fun createTypeValue(conn: Connection, sqlType: Int, typeName: String?): Any {
                val arrayDescriptor = ArrayDescriptor(typeName, conn)
                return ARRAY(arrayDescriptor, conn, ids)
            }
        }
    }
}
```

---

## 3.9. Embedded Database Support

<span class="custom-blockquote">org.springframework.jdbc.datasource.embedded</span> 패키지에선 임베디드 자바 데이터베이스 엔진을 지원한다. 기본적으로 [HSQL](http://www.hsqldb.org/), [H2](https://www.h2database.com/), [Derby](https://db.apache.org/derby)를 지원한다. API는 확장이 가능하기 때문에, 그외 다른 임베디드 데이터베이스 타입과 `DataSource` 구현체도 연결할 수 있다.

### 3.9.1. Why Use an Embedded Database?

임베디드 데이터베이스는 경량적이라는 특성덕분에 프로젝트 개발 단계에서 유용하게 쓸 수 있다. 설정이 쉽고, 구동도 빠르며, 테스트하기도 쉽고, 개발 중간에 SQL을 빠르게 변경할 수 있다는 장점이 있다.

### 3.9.2. Creating an Embedded Database by Using Spring XML

임베디드 데이터베이스 인스턴스를 스프링 `ApplicationContext` 빈으로 노출하려면, `spring-jdbc` 네임스페이스의 `embedded-database` 태그를 사용하면 된다:

```xml
<jdbc:embedded-database id="dataSource" generate-name="true">
    <jdbc:script location="classpath:schema.sql"/>
    <jdbc:script location="classpath:test-data.sql"/>
</jdbc:embedded-database>
```

이 설정은 임베디드 HSQL 데이터베이스를 만들어 클래스패스 루트의 `schema.sql`, `test-data.sql`에 있는 SQL로 데이터를 추가한다. 이와 더불어, 베스트 프랙티스에 따라 임베디드 데이터베이스에 유니크한 이름을 만들어 할당한다. 임베디드 데이터베이스는 스프링 컨테이너에 `javax.sql.DataSource` 타입 빈으로 등록되므로, 필요에 따라 데이터 접근 객체에 주입할 수 있다.

### 3.9.3. Creating an Embedded Database Programmatically

`EmbeddedDatabaseBuilder` 클래스는 프로그래밍 방식으로 임베디드 데이터베이스를 만들 수 있는 fluent API를 제공한다. 다음 예제처럼, 독립적인 환경이나 독립 실행형 통합 테스트에서 임베디드 데이터베이스를 생성해야 할 때 활용하면 된다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
EmbeddedDatabase db = new EmbeddedDatabaseBuilder()
        .generateUniqueName(true)
        .setType(H2)
        .setScriptEncoding("UTF-8")
        .ignoreFailedDrops(true)
        .addScript("schema.sql")
        .addScripts("user_data.sql", "country_data.sql")
        .build();

// perform actions against the db (EmbeddedDatabase extends javax.sql.DataSource)

db.shutdown()
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
val db = EmbeddedDatabaseBuilder()
        .generateUniqueName(true)
        .setType(H2)
        .setScriptEncoding("UTF-8")
        .ignoreFailedDrops(true)
        .addScript("schema.sql")
        .addScripts("user_data.sql", "country_data.sql")
        .build()

// perform actions against the db (EmbeddedDatabase extends javax.sql.DataSource)

db.shutdown()
```

지원하는 전체 옵션은 [`EmbeddedDatabaseBuilder` javadoc](https://docs.spring.io/spring-framework/docs/5.3.2/javadoc-api/org/springframework/jdbc/datasource/embedded/EmbeddedDatabaseBuilder.html)을 참고해라.

다음 예제처럼 자바 설정에서도 `EmbeddedDatabaseBuilder`로 임베디드 데이터베이스를 만들 수 있다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
@Configuration
public class DataSourceConfig {

    @Bean
    public DataSource dataSource() {
        return new EmbeddedDatabaseBuilder()
                .generateUniqueName(true)
                .setType(H2)
                .setScriptEncoding("UTF-8")
                .ignoreFailedDrops(true)
                .addScript("schema.sql")
                .addScripts("user_data.sql", "country_data.sql")
                .build();
    }
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
@Configuration
class DataSourceConfig {

    @Bean
    fun dataSource(): DataSource {
        return EmbeddedDatabaseBuilder()
                .generateUniqueName(true)
                .setType(H2)
                .setScriptEncoding("UTF-8")
                .ignoreFailedDrops(true)
                .addScript("schema.sql")
                .addScripts("user_data.sql", "country_data.sql")
                .build()
    }
}
```

### 3.9.4. Selecting the Embedded Database Type

이번 섹션에선 스프링이 지원하는 세 가지 임베디드 데이터베이스 중에서 원하는 데이터베이스를 설정하는 방법을 설명한다. 여기서는 다음과 같은 주제를 다룬다:

- [HSQL 사용하기](#using-hsql)
- [H2 사용하기](#using-h2)
- [Derby 사용하기](#using-derby)

#### Using HSQL

스프링은 HSQL 1.8.0 이상을 지원한다. HSQL은 타입을 직접 명시하지 않았을 때 사용하는 디폴트 임베디드 데이터베이스다. HSQL을 명시적으로 지정하려면 `embedded-database` 태그의 `type` 속성을 `HSQL`로 설정해라. 빌더 API를 사용한다면 `setType(EmbeddedDatabaseType)` 메소드에 `EmbeddedDatabaseType.HSQL`을 전달해라.

#### Using H2

스프링은 H2 데이터베이스를 지원한다. H2를 활성화하려면 `embedded-database` 태그의 `type` 속성을 `H2`로 설정해라. 빌더 API를 사용한다면 `setType(EmbeddedDatabaseType)` 메소드에 `EmbeddedDatabaseType.H2`를 전달해라.

#### Using Derby

스프링은 아파치 Derby 10.5 이상을 지원한다. Derby를 활성화하려면 `embedded-database` 태그의 `type` 속성을 `DERBY`로 설정해라. 빌더 API를 사용한다면 `setType(EmbeddedDatabaseType)` 메소드에 `EmbeddedDatabaseType.DERBY`를 전달해라.

### 3.9.5. Testing Data Access Logic with an Embedded Database

임베디드 데이터베이스를 사용하면 데이터 접근 코드를 경량으로 테스트할 수 있다. 다음 예제는 임베디드 데이터베이스를 사용하는 데이터 접근 통합 테스트 템플릿이다. 이 템플릿은 임베디드 데이터베이스를 테스트 클래스에서 재사용할 필요 없이 한 번만 사용하고 싶을 때 활용하면 된다. 반대로 임베디드 데이터베이스를 테스트 스위트(suite) 내에서 공유하고 싶다면, [스프링 TestContext 프레임워크](https://docs.spring.io/spring-framework/docs/5.3.2/reference/html/testing.html#testcontext-framework)를 참고해, [스프링 XML로 임베디드 데이터베이스 생성하기](#392-creating-an-embedded-database-by-using-spring-xml)와 [프로그래밍 방식으로 임베디드 데이터베이스 생성하기](#393-creating-an-embedded-database-programmatically)에서 설명한대로 임베디드 데이터베이스를 스프링 `ApplicationContext`의 빈으로 만드는 것도 좋다. 테스트 템플릿은 여기에 있다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
public class DataAccessIntegrationTestTemplate {

    private EmbeddedDatabase db;

    @BeforeEach
    public void setUp() {
        // creates an HSQL in-memory database populated from default scripts
        // classpath:schema.sql and classpath:data.sql
        db = new EmbeddedDatabaseBuilder()
                .generateUniqueName(true)
                .addDefaultScripts()
                .build();
    }

    @Test
    public void testDataAccess() {
        JdbcTemplate template = new JdbcTemplate(db);
        template.query( /* ... */ );
    }

    @AfterEach
    public void tearDown() {
        db.shutdown();
    }

}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
class DataAccessIntegrationTestTemplate {

    private lateinit var db: EmbeddedDatabase

    @BeforeEach
    fun setUp() {
        // creates an HSQL in-memory database populated from default scripts
        // classpath:schema.sql and classpath:data.sql
        db = EmbeddedDatabaseBuilder()
                .generateUniqueName(true)
                .addDefaultScripts()
                .build()
    }

    @Test
    fun testDataAccess() {
        val template = JdbcTemplate(db)
        template.query( /* ... */)
    }

    @AfterEach
    fun tearDown() {
        db.shutdown()
    }
}
```

### 3.9.6. Generating Unique Names for Embedded Databases

임베디드 데이터베이스를 사용할 땐, 실수로 같은 테스트 스위트 내에서 같은 데이터베이스 인스턴스를 여러 번 만들어 에러를 만나는 경우가 자주 있다. XML 설정 파일이나 `@Configuration` 클래스로 임베디드 데이터베이스를 만들고, 이 설정을 같은 테스트 스위트 내에 있는 테스트 시나리오 여러 개에서 재사용하면(즉, 동일한 JVM 프로세스 안에서) 꽤 쉽게 재현된다. 예를 들어, 활성 프로파일만 다른 `ApplicationContext` 설정으로 임베디드 데이터베이스를 통합 테스트하는 경우가 그렇다.

이 오류의 근본 원인은 데이터베이스 이름을 별도로 지정하지 않으면 스프링의 `EmbeddedDatabaseFactory`(XML 네임스페이스 `<jdbc:embedded-database>` 요소와 자바 설정 `EmbeddedDatabaseBuilder` 내부에서 사용하는)가 임베디드 데이터베이스 이름을 `testdb`로 설정하기 때문이다. 보통 `<jdbc:embedded-database>`에선 임베디드 데이터베이스에 빈의 `id`와 동일한 이름(보통 `dataSource`같은 이름)을 지정한다. 이렇게하면 이후에 다시 임베디드 데이터베이스를 생성하려고 해도 새 데이터베이스가 만들어지지 않는다. 대신 동일한 JDBC 커넥션 URL을 재사용하며, 동일한 설정에서 만든 기존 임베디드 데이터베이스를 가리키게 된다.

흔히 겪는 이슈기 때문에 스프링 프레임워크 4.2는 임베디드 데이터베이스에 고유한 이름을 생성해준다. 이 기능을 사용하려면 다음 옵션 중 하나를 사용해라.

- `EmbeddedDatabaseFactory.setGenerateUniqueDatabaseName()`
- `EmbeddedDatabaseBuilder.generateUniqueName()`
- `<jdbc:embedded-database generate-name="true" … >`

### 3.9.7. Extending the Embedded Database Support

스프링 JDBC 임베디드 데이터베이스 지원은 두 가지 방법으로 확장할 수 있다:

- `EmbeddedDatabaseConfigurer`를 구현해 새 임베디드 데이터베이스 타입을 지원한다.
- `DataSourceFactory`를 구현해 임베디드 데이터베이스 커넥션 풀을 관리하는 등의 새 `DataSource` 구현체를 지원한다.

[깃허브 이슈](https://github.com/spring-projects/spring-framework/issues)에 있는 스프링 커뮤니티로 익스텐션에 기여하는 건 언제나 환영이다.

---

## 3.10. Initializing a `DataSource`

<span class="custom-blockquote">org.springframework.jdbc.datasource.init</span> 패키지로는 기존 `DataSource`의 초기화 로직을 실행할 수 있다. 임베디드 데이터베이스도 어플리케이션에서 사용할 `DataSource`를 만들고 초기화할 수 있는 한 가지 방법이다. 하지만 간혹 서버에서 실행되는 인스턴스를 어딘가에서 초기화해야 할 때도 있다.

### 3.10.1. Initializing a Database by Using Spring XML

`DataSource` 빈 참조를 제공할 수 있다면 `spring-jdbc` 네임스페이스의 `initialize-database` 태그를 사용해 데이터베이스를 초기화할 수 있다:

```xml
<jdbc:initialize-database data-source="dataSource">
    <jdbc:script location="classpath:com/foo/sql/db-schema.sql"/>
    <jdbc:script location="classpath:com/foo/sql/db-test-data.sql"/>
</jdbc:initialize-database>
```

이 예제는 데이터베이스에 지정한 스크립트 두 개를 실행한다. 첫 번째는 스키마를 생성하는 스크립트고, 두 번째 스크립트에선 테이블에 테스트 데이터 셋을 저장한다. 스크립트 위치는 스프링 리소스에 흔히 사용하는 Ant 스타일 와일드카드 패턴(예를 들어 `classpath*:/com/foo/**/sql/*-data.sql`)을 사용해도 된다. 패턴을 사용하면 URL이나 파일명의 사전 순대로 스크립트를 실행한다.

데이터베이스 이니셜라이저의 기본 동작은 제공한 스크립트를 무조건 실행한다. 경우에 따라서는 의도한 동작이 아닐 수도 있다. 예를 들어 데이터베이스에 이미 테스트 데이터가 있는대도 스크립트를 실행할 수도 있다. 테이블을 먼저 생성한 다음 데이터를 삽입하는 공통 패턴(앞에서 보여준)을 사용하면 실수로 데이터를 삭제할 가능성이 줄어든다. 테이블이 이미 있으면 첫 번째 단계에서 실패한다.

하지만 별도로, XML 네임스페이스는 기존 데이터의 생성, 삭제를 확실히 제어할 수 있는 옵션 몇 가지를 추가로 제공한다. 첫 번째 옵션은 초기화 동작을 끄고 켤 수 있는 플래그다. 플래그는 환경에 따라 설정하면 된다 (시스템 프로퍼티나 environment 빈에서 boolean 값을 가져오는 식으로). 다음 예제는 시스템 프로퍼티에서 값을 가져온다:

```xml
<jdbc:initialize-database data-source="dataSource"
    enabled="#{systemProperties.INITIALIZE_DATABASE}"> <!-- (1) -->
    <jdbc:script location="..."/>
</jdbc:initialize-database>
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 시스템 프로퍼티 `INITIALIZE_DATABASE`에서 `enabled` 값을 가져온다.</small>

두 번째 옵션은 기존 데이터에서 발생하는 상황을 제어할 수 있는 옵션으로, 실패에 대한 내성을 높이는 방법이다. 이때는 다음 예제처럼, 이니셜라이저가 스크립트에서 발생하는 특정 SQL 오류를 무시하도록 만든다:

```xml
<jdbc:initialize-database data-source="dataSource" ignore-failures="DROPS">
    <jdbc:script location="..."/>
</jdbc:initialize-database>
```

이 예제에선, 비어있는 데이터베이스에 스크립트를 실행할 수도 있으므로, `DROP` 구문이 있는 스크립트는 실패할 수도 있다고 미리 설정해둔다. 따라서 SQL `DROP` 문 실패는 무시하지만, 그 외 다른 실패는 예외를 던진다. 테스트 데이터를 다시 만들기 전에 무조건 전부 삭제하고는 싶은데, SQL 방언(dialect)이 `DROP … IF EXISTS`(또는 이와 유사한 기능)를 지원하지 않을 때 유용하다. 이럴땐 보통 첫 번째 스크립트에서 `DROP` 문을 전부 실행하고, 그 다음 `CREATE` 문을 실행한다.

`ignore-failures` 옵션은 `NONE`(디폴트), `DROPS`(drop 실패 무시), `ALL`(모든 실패 무시)로 설정할 수 있다.

각 구문은 `;`로 구분해야 한다. 아니면 스크립트 전체에 `;` 문자를 사용하지 않고 라인을 바꿔서 구분할 수도 있다. 구분자는 다음 예제처럼 전체 스크립트에 지정할 수도 있고, 스크립트별로 따로 변경할 수 있다:

```xml
<jdbc:initialize-database data-source="dataSource" separator="@@"> <!-- (1) -->
    <jdbc:script location="classpath:com/myapp/sql/db-schema.sql" separator=";"/> <!-- (2) -->
    <jdbc:script location="classpath:com/myapp/sql/db-test-data-1.sql"/>
    <jdbc:script location="classpath:com/myapp/sql/db-test-data-2.sql"/>
</jdbc:initialize-database>
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 전체 스크립트의 구분자를 `@@`로 설정한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> `db-schema.sql`의 구분자를 `;`로 설정한다.</small>

이 예제에선 `test-data`  스크립트 두 개만 `@@`로 구문을 구분하고, `db-schema.sql`에선 `;`를 사용한다. 이 설정은 디폴트 구분자를 `@@`로 지정하고, `db-schema` 스크립트에선 구분자를 재정의한다.

XML 네임스페이스가 제공하는 것 이상으로 더 많은 제어가 필요하다면 `DataSourceInitializer`를 직접 사용해 어플리케이션의 컴포넌트로 정의해라.

#### Initialization of Other Components that Depend on the Database

어플리케이션 대부분은(스프링 컨텍스트가 기동될 때까지 데이터베이스를 사용하지 않는 어플리케이션) 어플리케이션을 더 복잡하게 만들 필요 없이 그대로 데이터베이스 이니셜라이저를 사용해도 문제 없다. 하지만 어플리케이션이 이 조건에 해당하지 않는다면 남은 섹션을 읽어봐야 한다.

데이터베이스 이니셜라이저는 `DataSource` 인스턴스에 의존하며, 초기화 콜백으로 제공한 스크립트를 실행한다 (XML 빈 정의에서의 `init-method`, 컴포넌트의 `@PostConstruct` 메소드, `InitializingBean`을 구현한 컴포넌트의 `afterPropertiesSet()` 메소드와 유사함). 초기화 콜백에서 사용하는 데이터소스를 다른 빈에서도 참조한다면, 데이터를 초기화하기 전에 참조해갈 수도 있어 문제의 여지가 있다. 대표적인 예시는 어플리케이션 기동 시 열심히 초기화하고 데이터베이스에서 데이터를 로드하는 캐시다.

이 문제는 두 가지 옵션으로 해결할 수 있다: 캐시 초기화를 나중으로 미루거나, 데이터베이스 이니셜라이저를 먼저 초기화하도록 설정해라.

캐시 초기화 전략을 변경하는 것은 어플리케이션에서 제어할 수만 있다면 쉽게 가능하다. 제안하는 방법은 다음과 같다:

- 캐시를 처음 사용하는 시점까지 초기화를 지연시킨다. 이때는 어플리케이션 기동 시간도 함께 개선된다.
- 캐시를 초기화하는 캐시나 별도 컴포넌트를 만들어 `Lifecycle`나 `SmartLifecycle`을 구현한다. `SmartLifecycle`은 `autoStartup` 플래그를 설정해 어플리케이션 컨텍스트를 구동하면 자동으로 시작할 수 있고, 감싸고 있는 컨텍스트에서 `ConfigurableApplicationContext.start()`를 호출해 수동으로 `Lifecycle`을 시작해도 된다.
- 스프링 `ApplicationEvent`나 유사한 커스텀 옵저버 메커니즘을 사용해 캐시 초기화를 트리거한다. `ContextRefreshedEvent`는 컨텍스트가 준비 되면 (모든 빈을 초기화한 다음) 항상 컨텍스트가 발행하는 이벤트로, 훅으로 활용하기 좋다 (`SmartLifecycle` 기본 동작 방식도 동일하다).

데이터베이스 이니셜 라이저가 먼저 초기화되도록 만드는 것도 간단한다. 제안하는 방법은 다음과 같다:

- 등록한 순서대로 빈을 초기화하는 `BeanFactory`의 기본 동작을 활용한다. 흔히 XML 설정의 `<import/>` 요소 셋으로 어플리케이션 모듈을 정렬할 때처럼, 데이터베이스와 데이터베이스 초기화를 먼저 나열하면 쉽게 순서를 제어할 수 있다.
- `DataSource`와 이를 사용하는 비즈니스 컴포넌트를 분리하고, 별도 `ApplicationContext` 인스턴스에 넣어 기동 순서를 제어해라 (예를 들어 `DataSource`는 상위 컨텍스트에 넣고, 하위 컨텍스트에 비즈니스 컴포넌트들을 넣는 식으로). 이 구조는 스프링 웹 어플리케이션에서 흔히 사용하는 구조지만, 더 넓은 범위에서도 적용할 수 있다.