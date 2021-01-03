---
title: R2DBC support
category: Spring Data R2DBC
order: 14
permalink: /Spring%20Data%20R2DBC/r2dbcsupport/
description: 스프링 R2DBC 모듈 기능 소개 한글 번역
image: ./../../images/spring/logo.png
lastmod: 2020-12-19T23:00:00+09:00
comments: true
priority: 0.7
originalRefName: 스프링 데이터 R2DBC
originalRefLink: https://docs.spring.io/spring-data/r2dbc/docs/1.2.2/reference/html/#r2dbc.core
---

### 목차

- [13.1. Getting Started](#131-getting-started)
- [13.2. Examples Repository](#132-examples-repository)
- [13.3. Connecting to a Relational Database with Spring](#133-connecting-to-a-relational-database-with-spring)
  + [13.3.1. Registering a ConnectionFactory Instance using Java-based Metadata](#1331-registering-a-connectionfactory-instance-using-java-based-metadata)
  + [13.3.2. R2DBC Drivers](#1332-r2dbc-drivers)
- [13.4. R2dbcEntityOperations Data Access API](#134-r2dbcentityoperations-data-access-api)
  + [13.4.1. Methods for Inserting and Updating Entities](#1341-methods-for-inserting-and-updating-entities)
  + [13.4.2. Selecting Data](#1342-selecting-data)
  + [13.4.3. Fluent API](#1343-fluent-api)
    * [Methods for the Criteria Class](#methods-for-the-criteria-class)
  + [13.4.4. Inserting Data](#1344-inserting-data)
  + [13.4.5. Updating Data](#1345-updating-data)
  + [13.4.6. Deleting Data](#1346-deleting-data)

---

R2DBC가 지원하는 기능은 매우 다양하다:

- 자바 기반 `@Configuration` 클래스와 스프링 설정을 이용한 R2DBC 드라이버 인스턴스 세팅.
- row와 POJO 간 객체 매핑으로 공통 R2DBC 연산 생산성을 높이는, 엔티티 바인딩 연산 핵심 클래스 `R2dbcEntityTemplate`.
- 스프링의 Conversion Service와 통합된, 풍부한 기능을 제공하는 객체 매핑.
- 다른 메타데이터 포맷으로 확장할 수 있는 어노테이션 기반 메타데이터.
- 커스텀 쿼리 메소드 기능을 포함한 레포지토리 인터페이스 자동 구현.

웬만한 작업은 `R2dbcEntityTemplate`이나 레포지토리 지원을 사용할 거다. 두 가지 다 풍부한 매핑 기능을 지원한다. `R2dbcEntityTemplate`은 애드혹 CRUD 연산같은 액세스 기능에 적합하다.

---

## 13.1. Getting Started

[start.spring.io](https://start.spring.io/)로 스프링 프로젝트를 만들면 간단하게 환경을 세팅할 수 있다. 그러려면:

1. pom.xml 파일 `dependencies` 요소에 다음을 추가한다:

   ```xml
   <dependencyManagement>
     <dependencies>
       <dependency>
         <groupId>io.r2dbc</groupId>
         <artifactId>r2dbc-bom</artifactId>
         <version>${r2dbc-releasetrain.version}</version>
         <type>pom</type>
         <scope>import</scope>
       </dependency>
     </dependencies>
   </dependencyManagement>
   
   <dependencies>
   
     <!-- other dependency elements omitted -->
   
     <dependency>
       <groupId>org.springframework.data</groupId>
       <artifactId>spring-data-r2dbc</artifactId>
       <version>1.2.2</version>
     </dependency>
   
     <!-- a R2DBC driver -->
     <dependency>
       <groupId>io.r2dbc</groupId>
       <artifactId>r2dbc-h2</artifactId>
       <version>Arabba-SR8</version>
     </dependency>
   
   </dependencies>
   ```

2. pom.xml 스프링 버전을 아래와 같이 변경한다.

   ```xml
   <spring-framework.version>5.3.2</spring-framework.version>
   ```

3. `pom.xml`의 `<dependencies/>` 요소와 동일한 레벨에 메이븐의 스프링 마일스톤 레포지토리를 추가한다.

   ```xml
   <repositories>
     <repository>
       <id>spring-milestone</id>
       <name>Spring Maven MILESTONE Repository</name>
       <url>https://repo.spring.io/libs-milestone</url>
     </repository>
   </repositories>
   ```

마일스톤 레포지토리는 [여기에서도 둘러볼 수 있다](https://repo.spring.io/milestone/org/springframework/data/).

로그 레벨을 `DEBUG`로 설정해 추가 정보를 확인하고 싶을 수 있다. 이럴 땐 `application.properties` 파일에 아래 설정을 추가해라:

```properties
logging.level.org.springframework.r2dbc=DEBUG
```

이제 예시로 `Person` 클래스를 만들어 저장해보자:

```java
public class Person {

  private final String id;
  private final String name;
  private final int age;

  public Person(String id, String name, int age) {
    this.id = id;
    this.name = name;
    this.age = age;
  }

  public String getId() {
    return id;
  }

  public String getName() {
    return name;
  }

  public int getAge() {
    return age;
  }

  @Override
  public String toString() {
    return "Person [id=" + id + ", name=" + name + ", age=" + age + "]";
  }
}
```

그러려면 데이터베이스에 다음과 같은 테이블 구조를 만들어야 한다:

```sql
CREATE TABLE person
  (id VARCHAR(255) PRIMARY KEY,
   name VARCHAR(255),
   age INT);
```

메인 어플리케이션은 다음과 같이 실행해야 한다:

```java
import io.r2dbc.spi.ConnectionFactories;
import io.r2dbc.spi.ConnectionFactory;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import reactor.test.StepVerifier;

import org.springframework.data.r2dbc.core.R2dbcEntityTemplate;

public class R2dbcApp {

  private static final Log log = LogFactory.getLog(R2dbcApp.class);

  public static void main(String[] args) {

    ConnectionFactory connectionFactory = ConnectionFactories.get("r2dbc:h2:mem:///test?options=DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE");

    R2dbcEntityTemplate template = new R2dbcEntityTemplate(connectionFactory);

    template.getDatabaseClient().sql("CREATE TABLE person" +
        "(id VARCHAR(255) PRIMARY KEY," +
        "name VARCHAR(255)," +
        "age INT)")
      .fetch()
      .rowsUpdated()
      .as(StepVerifier::create)
      .expectNextCount(1)
      .verifyComplete();

    template.insert(Person.class)
      .using(new Person("joe", "Joe", 34))
      .as(StepVerifier::create)
      .expectNextCount(1)
      .verifyComplete();

    template.select(Person.class)
      .first()
      .doOnNext(it -> log.info(it))
      .as(StepVerifier::create)
      .expectNextCount(1)
      .verifyComplete();
  }
}
```

위에 있는 메인 프로그램을 실행하면 다음과 유사한 결과를 출력한다:

```java
2018-11-28 10:47:03,893 DEBUG amework.core.r2dbc.DefaultDatabaseClient: 310 - Executing SQL statement [CREATE TABLE person
  (id VARCHAR(255) PRIMARY KEY,
   name VARCHAR(255),
   age INT)]
2018-11-28 10:47:04,074 DEBUG amework.core.r2dbc.DefaultDatabaseClient: 908 - Executing SQL statement [INSERT INTO person (id, name, age) VALUES($1, $2, $3)]
2018-11-28 10:47:04,092 DEBUG amework.core.r2dbc.DefaultDatabaseClient: 575 - Executing SQL statement [SELECT id, name, age FROM person]
2018-11-28 10:47:04,436  INFO        org.spring.r2dbc.example.R2dbcApp:  43 - Person [id='joe', name='Joe', age=34]
```

간단한 예제긴 하지만, 몇 가지 주목할 점이 있다:

- 스프링 데이터 R2DBC의 핵심 헬퍼 클래스(`R2dbcEntityTemplate`) 인스턴스는 표준 `io.r2dbc.spi.ConnectionFactory` 객체로 만들 수 있다.
- 별도 메타데이터를 추가하지 않아도 표준 POJO를 매핑할 수 있다 (물론 원한다면 메타데이터를 제공할 수 있다 — [여기](../mapping) 참고.)
- 매핑 컨벤션은 필드 접근을 사용할 수 있다. 여기에서 사용한 `Person` 클래스는 getter만 가지고 있다는 점에 주목해라.
- 생성자 인자들의 이름이 저장된 row의 컬럼명과 일치하면, 생성자 인자로 인스턴스를 만든다.

---

## 13.2. Examples Repository

[깃허브 레포지토리는 몇 가지 샘플을 제공하니](https://github.com/spring-projects/spring-data-examples) 라이브러리 동작 방식을 익히려면 다운받아 직접 실행해 봐라.

---

## 13.3. Connecting to a Relational Database with Spring

스프링에서 관계형 데이터베이스를 사용할 때 가장 먼저 하는 일은 IoC 컨테이너를 통해 `io.r2dbc.spi.ConnectionFactory` 객체를 생성하는 일이다. 이때 어플리케이션을 기동하려면 [지원하는 데이터베이스와 드라이버](#1332-r2dbc-drivers)를 사용해야 한다.

### 13.3.1. Registering a `ConnectionFactory` Instance using Java-based Metadata

다음 코드는 자바 기반 빈 메타데이터로 `io.r2dbc.spi.ConnectionFactory` 인스턴스를 등록하는 예제다:

**Example 54. Registering a `io.r2dbc.spi.ConnectionFactory` object using Java-based bean metadata**

```java
@Configuration
public class ApplicationConfiguration extends AbstractR2dbcConfiguration {

  @Override
  @Bean
  public ConnectionFactory connectionFactory() {
    return …
  }
}
```

이렇게 스프링 `AbstractR2dbcConfiguration`을 통해 접근하면 표준 `io.r2dbc.spi.ConnectionFactory` 인스턴스를 컨테이너와 함께 사용할 수 있다. `ConnectionFactory` 인스턴스를 직접 등록하는 것과 비교했을 때 스프링 설정 지원을 사용하면 좋은 점은, 컨테이너에 `ExceptionTranslator`를 함께 제공한다는 점이다. `ExceptionTranslator` 구현체는 `@Repository` 어노테이션이 달린 데이터 접근 클래스에서 발생한 R2DBC exception을, 스프링의 이식 가능한 `DataAccessException`의 하위 exception으로 변환해 준다. `DataAccessException` 계층 구조와 `@Repository`는 [스프링의 DAO 지원 기능](https://docs.spring.io/spring/docs/5.3.2/reference/html/data-access.html)에서 설명하고 있다.

`AbstractR2dbcConfiguration`은 데이터베이스 상호작용과 레포지토리 구현에 필요한 `DatabaseClient`도 등록한다.

### 13.3.2. R2DBC Drivers

스프링 데이터 R2DBC는 유연한 R2DBC SPI 메커니즘을 통해 드라이버를 지원한다. R2DBC 스펙을 구현한 드라이버라면 어떤 드라이버든지 사용할 수 있다. 스프링 데이터 R2DBC는 각 데이터베이스에 특화된 기능에도 반응하기 때문에, `Dialect` 구현체가 있어야만 어플리케이션을 기동할 수 있다. 스프링 데이터 R2DBC가 dialect 구현체를 제공하는 드라이버는 다음과 같다:

- [H2](https://github.com/r2dbc/r2dbc-h2) (`io.r2dbc:r2dbc-h2`)
- [MariaDB](https://github.com/mariadb-corporation/mariadb-connector-r2dbc) (`org.mariadb:r2dbc-mariadb`)
- [Microsoft SQL Server](https://github.com/r2dbc/r2dbc-mssql) (`io.r2dbc:r2dbc-mssql`)
- [MySQL](https://github.com/mirromutth/r2dbc-mysql) (`dev.miku:r2dbc-mysql`)
- [jasync-sql MySQL](https://github.com/jasync-sql/jasync-sql) (`com.github.jasync-sql:jasync-r2dbc-mysql`)
- [Postgres](https://github.com/r2dbc/r2dbc-postgresql) (`io.r2dbc:r2dbc-postgresql`)

스프링 데이터 R2DBC는 `ConnectionFactory`를 검사해 데이터베이스를 알아내고, 그에 따라 적절한 데이터베이스 방언(dialect)을 선택한다. 사용하는 드라이버가 아직 스프링 데이터 R2DBC가 알지 못하는 드라이버라면 자체 [`R2dbcDialect`](https://docs.spring.io/spring-data/r2dbc/docs/1.2.2/api/api/org/springframework/data/r2dbc/dialect/R2dbcDialect.html)를 설정해야 한다.

> 방언은 [`DialectResolver`](https://docs.spring.io/spring-data/r2dbc/docs/1.2.2/api/org/springframework/data/r2dbc/dialect/DialectResolver.html)가 `ConnectionFactory`를 통해 리졸브하며, 보통은 `ConnectionFactoryMetadata`를 검사한다. 자체 `R2dbcDialect`은 `META-INF/spring.factories`에 <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.data.r2dbc.dialect.DialectResolver$R2dbcDialectProvider</span>를 구현한 클래스를 동록하면 스프링이 자동으로 발견할 수 있다. `DialectResolver`는 스프링의 `SpringFactoriesLoader`를 사용해서 클래스패스에 있는 dialect 프로바이더 구현체를 찾는다.

---

## 13.4. R2dbcEntityOperations Data Access API

`R2dbcEntityTemplate`은 스프링 데이터 R2DBC의 핵심 진입 포인트다. 데이터 질의, 삽입, 업데이트, 삭제같은 전형적인 애드혹 쿼리를 엔티티로 바로 수행하는, 엔티티 지향 메소드와 보다 세밀하고 유창한 인터페이스를 제공한다.

진입 포인트(`insert()`, `select()`, `update()` 등)는 실행할 연산에 따른 자연스러운 네이밍 스키마를 사용한다. 진입 포인트를 실행하고 나면, SQL 구문을 만들고 실행하는 종료 메소드로 이어지는 컨텍스트 종속 메소드만 제공하도록 설계했다. 스프링 데이터 R2DBC는 `R2dbcDialect` 인터페이스를 사용해 드라이버 자체가 지원하는 바인드 마커, 페이지 처리, 데이터 타입을 결정한다.

> 모든 종료 메소드는 항상 의도한 연산을 나타내는 `Publisher`를 반환한다. 실제 SQL 구문은 구독할 때 데이터베이스로 전달된다.

### 13.4.1. Methods for Inserting and Updating Entities

`R2dbcEntityTemplate`에는 객체를 저장하고 삽입할 수 있는 편리한 메소드가 몇 가지 있다. 변환 처리를 좀 더 세세하게 제어하고 싶다면 `R2dbcCustomConversions`로 스프링 컨버터를 등록해야 한다 — 예를 들어 `Converter<Person, OutboundRow>`와 `Converter<Row, Person>`.

간단히는 POJO로 저장 연산을 실행할 수 있다. 이때 테이블 이름은 클래스 이름으로 결정한다 (패키지명은 빼고). 컬렉션 이름을 지정해서 저장 연산을 호출해도 된다. 매핑 메타데이터로 객체를 저장할 컬렉션을 재정의할 수 있다.

데이터를 삽입하거나 저장할 때 `Id` 프로퍼티를 세팅하지 않으면 데이터베이스가 이 값을 자동 생성한다고 가정한다. 따라서 자동 생성할 클래스는 `Id` 필드 타입을 `Long`이나 `Integer`로 지정해야 한다.

다음은 row 하나를 삽입하고 조회하는 예제다:

**Example 55. Inserting and retrieving entities using the `R2dbcEntityTemplate`**

```java
Person person = new Person("John", "Doe");

Mono<Person> saved = template.insert(person);
Mono<Person> loaded = template.selectOne(query(where("firstname").is("John")),
    Person.class);
```

다음과 같은 삽입, 업데이트 연산을 지원한다:

- `Mono<T>` **insert** `(T objectToSave)`: 디폴트 테이블에 객체를 삽입한다.
- `Mono<T>` **update** `(T objectToSave)`: 디폴트 테이블에 객체를 업데이트한다.

테이블 명은 API로 커스텀할 수 있다.

### 13.4.2. Selecting Data

테이블에서 데이터를 조회할 땐 `R2dbcEntityTemplate`의 `select(…)`, `selectOne(…)` 메소드를 사용한다. 두 메소드 모두 필드 프로젝션과, `WHERE` 절, `ORDER BY` 절, limit/offset 페이징 정보를 정의하는 [Query](#methods-for-the-criteria-class) 객체를 받는다. Limit/offset은 데이터베이스마다 문법이 다르지만 어플리케이션에선 신경쓰지 않아도 된다. [`R2dbcDialect` 인터페이스](#1332-r2dbc-drivers)가 각 SQL 별 차이를 해소해준다.

**Example 56. Selecting entities using the `R2dbcEntityTemplate`**

```java
Flux<Person> loaded = template.select(query(where("firstname").is("John")),
    Person.class);
```

### 13.4.3. Fluent API

이번 섹션에선 fluent API 사용법을 설명한다. 아래 간단한 쿼리를 생각해 보자:

```java
Flux<Person> people = template.select(Person.class) // (1)
    .all(); // (2)
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `Person`을 `from(…)` 메소드와 함께 사용하면 매핑 메타데이터를 기반으로 `FROM` 테이블을 설정한다. 테이블 구조를 사용하는 질의 결과도 `Person` 객체로 매핑한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> `all()` 메소드로 모든 row를 조회하면, 결과 제한 없이 `Flux<Person>`을 반환한다.</small>

다음 예제는 테이블 이름과 `WHERE` 조건, `ORDER BY` 절을 지정하는 더 복잡한 쿼리를 선언하고 있다:

```java
Mono<Person> first = template.select(Person.class)  // (1)
  .from("other_person")
  .matching(query(where("firstname").is("John")     // (2)
    .and("lastname").in("Doe", "White"))
    .sort(by(desc("id"))))                          // (3)
  .one();                                           // (4)
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 지정한 테이블에 select 쿼리를 실행하면 해당 도메인 타입으로 결과를 반환한다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 발행된 쿼리는 `firstname`, `lastname` 컬럼에 `WHERE` 조건을 선언해 결과를 필터링하고 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> `ORDER BY` 절로 지정한 컬럼명으로 결과를 정렬한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> `one()` 메소드를 사용해서 row를 한 개만 조회한다. 이렇게 row를 컨슘하면 반환 결과가 정확히 한 개일 것으로 기대한다. 질의 결과가 둘 이상이라면 `Mono`는 `IncorrectResultSizeDataAccessException`을 방출한다.</small>

> `select(Class<?>)`로 타겟 타입을 제공하면 결과에 바로 [프로젝션](../r2dbcrepositories#1426-projections)을 적용할 수 있다.

다음 종료 메소드를 사용하면 단일 엔티티 조회 또는 여러 엔티티 조회로 전환할 수 있다:

- `first()`: 첫 번째 row만 컨슘하며, `Mono`를 반환한다. 질의 결과가 없으면 `Mono`는 객체를 방출하지 않고 완료한다.
- `one()`: row를 정확히 한 개만 컨슘하며, `Mono`를 반환한다. 질의 결과가 없으면 `Mono`는 객체를 방출하지 않고 완료한다. 질의 결과가 둘 이상이라면 `Mono`는 예외적으로 `IncorrectResultSizeDataAccessException`을 방출하고 종료한다.
- `all()`: 반환한 모든 row를 컨슘하며, `Flux`를 반환한다.
- `count()`: 카운트 프로젝션을 적용하며, `Mono<Long>`을 반환한다.
- `exists()`: 쿼리 결과가 있는지를 알려주며, `Mono<Boolean>`을 반환한다.

`SELECT` 쿼리를 표현하려면 `select()`로 시작하면 된다. `SELECT` 쿼리는 흔히 사용하는 `WHERE`, `ORDER BY` 절과 페이지 처리를 지원한다. Fluent API 스타일 덕분에 여러 메소드를 체이닝할 수 있으며, 코드를 이해하기도 쉽다. 가독성을 높이려면 스태틱 임포트를 사용해 `Criteria` 인스턴스를 만들기 위한 'new' 키워드를 생략해도 좋다.

#### Methods for the Criteria Class

`Criteria` 클래스는 SQL 연산자에 상응하는 메소드를 제공한다:

- `Criteria` **and** `(String column)`: 현재 `Criteria`에 `property`를 지정한 `Criteria`를 연결해 추가하고, 새로 만든 인스턴스를 반환한다.
- `Criteria` **or** `(String column)`: 현재 `Criteria`에 `property`를 지정한 `Criteria`를 연결해 추가하고, 새로 만든 인스턴스를 반환한다.
- `Criteria` **greaterThan** `(Object o)`: `>` 연산자로 판단 기준을 만든다.
- `Criteria` **greaterThanOrEquals** `(Object o)`: `>=` 연산자로 판단 기준을 만든다.
- `Criteria` **in** `(Object… o)`: 가변 인자와 `IN` 연산자로 판단 기준을 만든다.
- `Criteria` **in** `(Collection<?> collection)`: 컬렉션과 `IN` 연산자로 판단 기준을 만든다.
- `Criteria` **is** `(Object o)`: 컬럼 매칭(`property = value`)을 사용해 판단 기준을 만든다.
- `Criteria` **isNull** `()`: `IS NULL` 연산자로 판단 기준을 만든다.
- `Criteria` **isNotNull** `()`: `IS NOT NULL` 연산자로 판단 기준을 만든다.
- `Criteria` **lessThan** `(Object o)`: `<` 연산자로 판단 기준을 만든다.
- `Criteria` **lessThanOrEquals** `(Object o)`: `<=` 연산자로 판단 기준을 만든다.
- `Criteria` **like** `(Object o)`: 이스케이프 문자 처리 없이 `LIKE` 연산자로 판단 기준을 만든다.
- `Criteria` **not** `(Object o)`: `!=` 연산자로 판단 기준을 만든다.
- `Criteria` **notIn** `(Object… o)`: 가변 인자와 `NOT IN` 연산자로 판단 기준을 만든다.
- `Criteria` **notIn** `(Collection<?> collection)`: 컬렉션과 `NOT IN` 연산자로 판단 기준을 만든다.

`Criteria`는 `SELECT`, `UPDATE`, `DELETE` 쿼리에 사용할 수 있다.

### 13.4.4. Inserting Data

데이터를 삽입할 땐 `insert()`로 시작한다.

아래 간단한 타입으로 insert 연산을 실행하는 예제를 보자:

```java
Mono<Person> insert = template.insert(Person.class) // (1)
    .using(new Person("John", "Doe")); // (2)
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `Person`을 `into(…)` 메소드와 함께 사용하면 매핑 메타데이터를 기반으로 `INTO` 테이블을 설정한다. `Person` 객체로 데이터를 삽입할 수 있도록 insert 구문을 준비한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 스칼라 `Person` 객체를 제공한다. 아니면 `Publisher`를 제공해서 `INSERT` 구문의 스트림을 실행해도 된다. 이 메소드는 모든 non-`null` 객체를 추출해 삽입한다.</small>

### 13.4.5. Updating Data

row를 업데이트할 땐 `update()`로 시작한다. 데이터 업데이트는 `Update` 정의 스펙(assignment)을 받아서, 업데이트할 테이블을 지정하는 것으로 시작한다. `WHERE` 절을 만드는 `Query`도 넘길 수 있다.

아래 간단한 타입으로 update 연산을 실행하는 예제를 보자:

```java
Person modified = …

    Mono<Integer> update = template.update(Person.class)  // (1)
        .inTable("other_table")                           // (2)
        .matching(query(where("firstname").is("John")))   // (3)
        .apply(update("age", 42));                        // (4)
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `Person` 객체들을 업데이트하고 매핑 메타데이터 기반 매핑을 적용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> `inTable(…)` 메소드를 호출해 별도 테이블 명을 설정한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> `WHERE` 절로 해석되는 쿼리를 지정한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> `Update` 객체를 적용한다. 여기에선 `age`를 `42`로 설정하고 영향받은 row 수를 반환한다.</small>

### 13.4.6. Deleting Data

row를 삭제할 땐 `delete()`로 시작한다. 데이터를 삭제할 땐 제거 대상이 있는 테이블 스펙으로 시작하며, 원한다면 `Criteria`를 넘겨 `WHERE` 절을 만들 수 있다.

아래 간단한 타입으로 delete 연산을 실행하는 예제를 보자:

```java
    Mono<Integer> delete = template.delete(Person.class)  // (1)
        .from("other_table")                              // (2)
        .matching(query(where("firstname").is("John")))   // (3)
        .all();                                           // (4)
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `Person` 객체들을 삭제하고 매핑 메타데이터 기반 매핑을 적용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> `from(…)` 메소드로 별도 테이블 명을 설정한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> `WHERE` 절로 해석되는 쿼리를 지정한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> 삭제 연산을 적용하고 영향받은 row 수를 반환한다.</small>