---
title: R2DBC Repositories
category: Spring Data R2DBC
order: 15
permalink: /Spring%20Data%20R2DBC/r2dbcrepositories/
description: 스프링 데이터 R2DBC 레포지토리 공식 레퍼런스를 한글로 번역한 문서입니다.
image: ./../../images/spring/logo.png
lastmod: 2020-12-19T23:00:00+09:00
comments: true
priority: 0.8
originalRefName: 스프링 데이터 R2DBC
originalRefLink: https://docs.spring.io/spring-data/r2dbc/docs/1.2.2/reference/html/#r2dbc.repositories
---

### 목차

- [14.1. Usage](#141-usage)
- [14.2. Query Methods](#142-query-methods)
  + [14.2.1. Modifying Queries](#1421-modifying-queries)
  + [14.2.2. Queries with SpEL Expressions](#1422-queries-with-spel-expressions)
  + [14.2.3. Entity State Detection Strategies](#1423-entity-state-detection-strategies)
  + [14.2.4. ID Generation](#1424-id-generation)
  + [14.2.5. Optimistic Locking](#1425-optimistic-locking)
  + [14.2.6. Projections](#1426-projections)
    * [Interface-based Projections](#interface-based-projections)
    * [Class-based Projections (DTOs)](#class-based-projections-dtos)
    * [Dynamic Projections](#dynamic-projections)
    * [Result Mapping](#result-mapping)
- [14.3. Entity Callbacks](#143-entity-callbacks)
  + [14.3.1. Implementing Entity Callbacks](#1431-implementing-entity-callbacks)
  + [14.3.2. Registering Entity Callbacks](#1432-registering-entity-callbacks)
  + [14.3.3. Store specific EntityCallbacks](#1433-store-specific-entitycallbacks)
- [14.4. Working with multiple Databases](#144-working-with-multiple-databases)

---

이번 챕터에선 R2DBC 레포지토리 지원 기능을 설명한다. 여기서 다루는 내용들은 [스프링 데이터 레포지토리 다루기](../workingwithspringdatarepositories)에서 설명했던 핵심 레포지토리 기능을 기반으로 이루어져 있다. 따라서 이 챕터를 읽기 전에, 먼저 설명했던 기본 개념들을 제대로 이해하고 있어야 한다.

---

## 14.1. Usage

정교한 레포지토리 지원 기능을 사용하면 관계형 데이터베이스에 저장된 도메인 엔티티에 접근할 수 있으며, 구현하기도 매우 쉽다. 먼저, 레포지토리에 사용할 인터페이스를 만들어라. 다음 `Person` 클래스를 생각해보자:

**Example 57. Sample Person entity**

```java
public class Person {

  @Id
  private Long id;
  private String firstname;
  private String lastname;

  // … getters and setters omitted
}
```

다음은 이 `Person` 클래스를 위한 레포지토리 인터페이스다:

**Example 58. Basic repository interface to persist Person entities**

```java
public interface PersonRepository extends ReactiveCrudRepository<Person, Long> {

  // additional custom query methods go here
}
```

R2DBC 레포지토리를 설정하려면 `@EnableR2dbcRepositories` 어노테이션을 사용해야 한다. 베이스 패키지를 설정하지 않으면 어노테이션이 달린 설정 클래스의 패키지를 스캔한다. 다음은 자바 설정을 사용한 레포지토리 설정 예시다:

**Example 59. Java configuration for repositories**

```java
@Configuration
@EnableR2dbcRepositories
class ApplicationConfig extends AbstractR2dbcConfiguration {

  @Override
  public ConnectionFactory connectionFactory() {
    return …
  }
}
```

위에서 만든 도메인 레포지토리가 `ReactiveCrudRepository`를 확장하고 있기 때문에, 리액티브 CRUD 연산을 사용해 엔티티에 접근할 수 있다. `ReactiveCrudRepository` 위에는, `PagingAndSortingRepository`와 유사한 정렬 기능을 추가로 지원하는 `ReactiveSortingRepository`도 있다. 이제 클라이언트에 의존성만 주입하면 바로 이 레포지토리 인스턴스를 사용할 수 있다. 따라서 아래 코드로 모든 `Person` 객체를 조회할 수 있다:

**Example 60. Paging access to Person entities**

```java
@ExtendWith(SpringExtension.class)
@ContextConfiguration
class PersonRepositoryTests {

  @Autowired
  PersonRepository repository;

  @Test
  void readsAllEntitiesCorrectly() {

    repository.findAll()
      .as(StepVerifier::create)
      .expectNextCount(1)
      .verifyComplete();
  }

  @Test
  void readsEntitiesByNameCorrectly() {

    repository.findByFirstname("Hello World")
      .as(StepVerifier::create)
      .expectNextCount(1)
      .verifyComplete();
  }
}
```

위 예제는 테스트 케이스에 어노테이션 기반으로 의존성을 주입해주는, 스프링의 단위 테스트 기능을 이용해 어플리케이션 컨텍스트를 생성한다. 테스트 메소드 안에선 레포지토리를 사용해 데이터베이스에 질의한다. 검증은 `StepVerifier`의 도움을 받아 테스트 결과를 기대치와 비교한다.

---

## 14.2. Query Methods

일반적으로 레포지토리로 트리거하는 데이터 접근 연산은 대부분 데이터베이스에 질의를 수행한다. 아래 예제에 보이듯이, 이런 쿼리는 레포지토리 인터페이스에 메소드를 선언하는 것만으로 정의할 수 있다:

**Example 61. PersonRepository with query methods**

```java
interface ReactivePersonRepository extends ReactiveSortingRepository<Person, Long> {

  Flux<Person> findByFirstname(String firstname);                                   // (1)

  Flux<Person> findByFirstname(Publisher<String> firstname);                        // (2)

  Flux<Person> findByFirstnameOrderByLastname(String firstname, Pageable pageable); // (3)

  Mono<Person> findByFirstnameAndLastname(String firstname, String lastname);       // (4)

  Mono<Person> findFirstByLastname(String lastname);                                // (5)

  @Query("SELECT * FROM person WHERE lastname = :lastname")
  Flux<Person> findByLastname(String lastname);                                     // (6)

  @Query("SELECT firstname, lastname FROM person WHERE lastname = $1")
  Mono<Person> findFirstByLastname(String lastname);                                // (7)
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 이 메소드는 주어진 `lastname`을 가진 모든 사람을 질의하는 쿼리를 만든다. 쿼리는 메소드 이름에서 `And`와 `Or`로 연결된 제약 조건을 파싱해서 만든다. 따라서 이 메소드 이름을 쿼리로 바꾸면 <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">SELECT … FROM person WHERE firstname = :firstname</span>으로 표현된다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 이 메소드는 주어진 `Publisher`가 `firstname`을 방출하면, 이 `firstname`에 해당하는 모든 사람을 질의하는 쿼리를 만든다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> `Pageable`로 데이터베이스에 오프셋과 정렬 파라미터를 전달한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> 주어진 조건에 맞는 단일 엔티티를 찾는다. 결과가 하나가 아니면 `IncorrectResultSizeDataAccessException`으로 끝난다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> \<4\>번과는 다르게 결과가 더 있어도 항상 첫 번째 엔티티만 방출한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(6)</span> `findByLastname` 메소드는 주어진 성을 가진 모든 사람을 질의하는 쿼리를 만든다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(7)</span> `firstname`과 `lastname` 컬럼만 프로젝션하는 단일 `Person` 엔티티를 조회하는 쿼리를 만든다. 어노테이션에 있는 쿼리는 네이티브 바인드 마커를 사용하며, 이 예제에서는 Postgres 바인드 마커를 사용한다.</small>

다음 테이블은 쿼리 메소드에서 지원하는 키워드들을 담고 있다:

**Table 2. Supported keywords for query methods**

| Keyword                              | Sample                                      | Logical result                       |
| :----------------------------------- | :------------------------------------------ | :----------------------------------- |
| `After`                              | `findByBirthdateAfter(Date date)`           | `birthdate > date`                   |
| `GreaterThan`                        | `findByAgeGreaterThan(int age)`             | `age > age`                          |
| `GreaterThanEqual`                   | `findByAgeGreaterThanEqual(int age)`        | `age >= age`                         |
| `Before`                             | `findByBirthdateBefore(Date date)`          | `birthdate < date`                   |
| `LessThan`                           | `findByAgeLessThan(int age)`                | `age < age`                          |
| `LessThanEqual`                      | `findByAgeLessThanEqual(int age)`           | `age <= age`                         |
| `Between`                            | `findByAgeBetween(int from, int to)`        | `age BETWEEN from AND to`            |
| `NotBetween`                         | `findByAgeNotBetween(int from, int to)`     | `age NOT BETWEEN from AND to`        |
| `In`                                 | `findByAgeIn(Collection<Integer> ages)`     | `age IN (age1, age2, ageN)`          |
| `NotIn`                              | `findByAgeNotIn(Collection ages)`           | `age NOT IN (age1, age2, ageN)`      |
| `IsNotNull`, `NotNull`               | `findByFirstnameNotNull()`                  | `firstname IS NOT NULL`              |
| `IsNull`, `Null`                     | `findByFirstnameNull()`                     | `firstname IS NULL`                  |
| `Like`, `StartingWith`, `EndingWith` | `findByFirstnameLike(String name)`          | `firstname LIKE name`                |
| `NotLike`, `IsNotLike`               | `findByFirstnameNotLike(String name)`       | `firstname NOT LIKE name`            |
| `Containing` (String)                | `findByFirstnameContaining(String name)`    | `firstname LIKE '%' + name +'%'`     |
| `NotContaining` (String)             | `findByFirstnameNotContaining(String name)` | `firstname NOT LIKE '%' + name +'%'` |
| `(No keyword)`                       | `findByFirstname(String name)`              | `firstname = name`                   |
| `Not`                                | `findByFirstnameNot(String name)`           | `firstname != name`                  |
| `IsTrue`, `True`                     | `findByActiveIsTrue()`                      | `active IS TRUE`                     |
| `IsFalse`, `False`                   | `findByActiveIsFalse()`                     | `active IS FALSE`                    |

### 14.2.1. Modifying Queries

이전 섹션에선 엔티티나 엔티티 컬렉션에 접근하기 위한 쿼리를 선언하는 방법을 설명했다. 위 테이블에 있는 키워드를 `delete…By`나 `remove…By`와 조합하면 일치하는 row를 삭제하는 파생 쿼리를 만들 수 있다:

**Example 62. `Delete…By` Query**

```java
interface ReactivePersonRepository extends ReactiveSortingRepository<Person, String> {

  Mono<Integer> deleteByLastname(String lastname);            // (1)

  Mono<Void> deletePersonByLastname(String lastname);         // (2)

  Mono<Boolean> deletePersonByLastname(String lastname);      // (3)
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 영향받은 row 수를 반환하는 `Mono<Integer>`를 리턴 타입으로 사용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 결과를 방출하지 않고 row를 삭제하는 데 성공했는지만 알려주는 `Void`를 사용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 최소한 하나는 삭제했는지를 알 수 있는 `Boolean`을 사용한다.</small>

커스텀 기능도 동일하게 접근해서, 다음 예제처럼 쿼리 메소드에 `@Modifying` 어노테이션을 달아 파라미터만 바인딩하면 되는 쿼리를 만들 수 있다:

```java
@Modifying
@Query("UPDATE person SET firstname = :firstname where lastname = :lastname")
Mono<Integer> setFixedFirstnameFor(String firstname, String lastname);
```

수정 쿼리 결과에는 다음 타입을 사용할 수 있다:

- 업데이트 카운트를 날리고 완료를 기다리는 `Void` (또는 코틀린 `Unit`).
- 영향받은 row 카운트를 방출하는 `Integer`나 다른 숫자 타입.
- 업데이트된 row가 있는지 여부를 방출하는 `Boolean`.

`@Modifying` 어노테이션은 `@Query` 어노테이션과 함께 쓸 때만 의미가 있다. 위에서 봤던 [파생 쿼리 메소드](#142-query-methods)에는 `@Modifying`을 선언할 필요 없다.

아니면 [스프링 데이터 레포지토리 커스텀 구현](../workingwithspringdatarepositories#116-custom-implementations-for-spring-data-repositories) 섹션에서 설명한 기능을 활용해서 커스텀 수정 동작을 추가해도 된다.

### 14.2.2. Queries with SpEL Expressions

쿼리를 직접 정의할 때 SpEL 표현식을 사용하면 런타임에 동적인 쿼리를 만들 수 있다. SpEL 표현식으로는 판단식 값을 쿼리 실행 직전에 제공해 런타임에  표현식을 평가할 수 있다.

표현식에선 메소드 인자를, 모든 인자를 담고 있는 배열로 표현한다. 아래 쿼리는 `lastname`에 해당하는 판단식 값을 `[0]`으로 선언했다 (`:lastname` 파라미터 바인딩과 동일):

```java
@Query("SELECT * FROM person WHERE lastname = :#{[0]}")
Flux<Person> findByQueryWithExpression(String lastname);
```

SpEL을 사용하면 쿼리를 다각도로 확장할 수 있다. 하지만 원치 않는 인자를 잔뜩 받을 수도 있다. 의도치않게 쿼리가 변경되는 걸 피하고 싶다면, 인자들을 전달하기 전에 불필요한 문자열을 제거해야 한다.

표현식은 쿼리 SPI로 확장할 수 있다: <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.data.spel.spi.EvaluationContextExtension</span>. 쿼리 SPI는 프로퍼티와 펑션을 제공하고, 루트 객체를 커스텀할 수 있다. 익스텐션은 쿼리를 빌드하면서 SpEL을 평가할 때 어플리케이션 컨텍스트를 통해 조회한다.

> SpEL 표현식을 일반 파라미터와 함께 사용한다면, 네이티브 바인드 마커 대신 파라미터 이름 표기법(named parameter)을 사용해야 바인딩 순서가 꼬이지 않는다.

### 14.2.3. Entity State Detection Strategies

아래 테이블에서는 엔티티가 DB엔 없는 새 엔티티인지를 판단하는 스프링 데이터 전략을 설명한다:

**Table 3. Options for detection whether an entity is new in Spring Data R2DBC**

| Id-프로퍼티 검사 (디폴트)  | 기본적으로 `save()` 메소드는 전달받은 엔티티의 식별자 프로퍼티를 검사한다. 식별자 프로퍼티가 `null`이면 새 엔티티로 가정한다. 그 외는 데이터베이스에 존재하는 엔티티라고 판단한다. |
| `Persistable` 구현           | 엔티티가 `Persistable`을 구현했다면, 스프링 데이터 R2DBC는 엔티티의 `isNew(…)` 메소드로 판단을 위임한다. 자세한 내용은 [Javadoc](https://docs.spring.io/spring-data/data-commons/docs/current/api/index.html?org/springframework/data/domain/Persistable.html)을 확인해라. |
|`@Version`을 사용한 낙관적 잠금 | 엔티티가 낙관적 잠금을 사용하면 (버전 프로퍼티에 `@Version` 어노테이션을 달아서), 스프링 데이터 R2DBC는 이 버전 프로퍼티가 자바의 디폴트 초기값과 같은지를 검사해서 새 엔티티인지 확인한다. 원시 타입은 `0`, 래퍼 타입은 `null`이 초기값이다. |
| `EntityInformation` 구현     | `SimpleR2dbcRepository`가 사용하는 `EntityInformation` 인터페이스는, `R2dbcRepositoryFactory` 하위 클래스를 만들어 `getEntityInformation(…)`을 재정의하는 식으로 커스텀할 수 있다. 그러려면 커스텀 `R2dbcRepositoryFactory` 구현체를 스프링 빈으로 등록해야 한다. 이 방법이 필요한 경우는 매우 드물다. 자세한 내용은 [Javadoc](https://docs.spring.io/spring-data/r2dbc/docs/1.2.2/api/org/springframework/data/r2dbc/repository/support/R2dbcRepositoryFactory.html)을 확인해라. |

### 14.2.4. ID Generation

스프링 데이터 R2DBC는 ID로 엔티티를 식별한다. 엔티티 ID엔 반드시 스프링 데이터의 [`@Id`](https://docs.spring.io/spring-data/commons/docs/current/api/org/springframework/data/annotation/Id.html) 어노테이션을 선언해야 한다.

ID 컬럼에 auto-increment를 사용하는 데이터베이스에선, DB에 데이터를 새로 저장한 후에 생성된 값이 엔티티에 세팅된다.

스프링 데이터 R2DBC는 엔티티가 DB엔 없는 새 엔티티이면서 식별자가 디폴트 초기값이면, DB 저장 시 식별자 컬럼에 따로 값을 추가하지 않는다. 여기서 디폴트 초기값은 원시 타입에선 `0`, `Long` 등의 숫자 래퍼 타입에선 `null`을 뜻한다.

한 가지 중요한 제약 사항이 있는데, 엔티티를 저장한 후에는 더 이상 새 엔티티로 취급하지 않는다는 점이다. 새 엔티티라는 말은 엔티티의 상태를 나타내는 말이기도 하다. auto-increment 컬럼에선 스프링 데이터가 auto-increment된 컬럼 값을 ID에 세팅하기 때문에 자동적으로 새 엔티티 상태를 벗어난다.

### 14.2.5. Optimistic Locking

`@Version` 어노테이션은 R2DBC 컨텍스트에 JPA와 유사한 문법을 제공하며, 버전이 일치하는 row에만 변경사항이 반영되도록 보장해준다. 업데이트 쿼리에 버전 프로퍼티의 실제 값을 추가하기 때문에, 같은 row를 동시에 수정해도 업데이트가 반영되지 않는다. 이럴 때는 `OptimisticLockingFailureException`을 던진다. 아래 예제를 참고해라:

```java
@Table
class Person {

  @Id Long id;
  String firstname;
  String lastname;
  @Version Long version;
}

R2dbcEntityTemplate template = …;

Mono<Person> daenerys = template.insert(new Person("Daenerys"));                      // (1)

Person other = template.select(Person.class)
                 .matching(query(where("id").is(daenerys.getId())))
                 .first().block();                                                    // (2)

daenerys.setLastname("Targaryen");
template.update(daenerys);                                                            // (3)

template.update(other).subscribe(); // emits OptimisticLockingFailureException        // (4)
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> row를 처음으로 추가한다. `version`은 `0`으로 세팅된다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 방금 삽입한 row를 로드한다. 이 때도 `vesion`은 `0`이다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> `version = 0`인 row를 업데이트 한다. `lastname`을 수정하고 `version`을 1로 올린다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> `version = 0`인, 먼저 로드해왔던 row를 업데이트해본다. 하지만 현재 `version`은 `1`이기 때문에 `OptimisticLockingFailureException`과 함께 실패한다.</small>

### 14.2.6. Projections

스프링 데이터 쿼리 메소드는 보통 레포지토리가 관리하는 집계 루트 인스턴스 하나 또는 여러 개를 반환한다. 하지만 어떨 땐 타입의 일부 속성만 정해서 프로젝션을 만드는 게 더 적합할 때도 있다. 스프링 데이터를 사용하면 전용 리턴 타입을 모델링해서 선택한 타입 일부만 조회할 수 있다.

다음과 같은 레포지토리와 집계 루트 타입이 있다고 상상해 보자:

**Example 63. A sample aggregate and repository**

```java
class Person {

  @Id UUID id;
  String firstname, lastname;
  Address address;

  static class Address {
    String zipCode, city, street;
  }
}

interface PersonRepository extends Repository<Person, UUID> {

  Flux<Person> findByLastname(String lastname);
}
```

이번엔 인물의 이름만 조회하고 싶다고 해보자. 스프링은 어떤 방법으로 이 문제를 해결해 줄까? 이제 이 챕터 남은 부분에선 이 질문에 대해 답할 거다.

#### Interface-based Projections

쿼리 결과를 이름으로만 제한하는 가장 쉬운 방법은, 다음 예제처럼 인터페이스를 선언해서 조회할 프로퍼티 전용 접근자 메소드를 노출하는 거다:

**Example 64. A projection interface to retrieve a subset of attributes**

```java
interface NamesOnly {

  String getFirstname();
  String getLastname();
}
```

여기서 중요한 건, 지금 정의한 프로퍼티는 집계 루트에 있는 프로퍼티와 완벽히 일치한다는 점이다. 따라서 다음과 같은 쿼리 메소드를 추가할 수 있다:

**Example 65. A repository using an interface based projection with a query method**

```java
interface PersonRepository extends Repository<Person, UUID> {

  Flux<NamesOnly> findByLastname(String lastname);
}
```

쿼리 실행 엔진은 런타임에 반환된 각 요소에 이 인터페이스의 프록시 인스턴스를 만들고, 노출한 메소드 호출을 타겟 객체로 전달한다.

프로젝션은 재귀적으로 사용할 수 있다. 일부 `Address` 정보도 포함시키려면, 아래 예제처럼 전용 프로젝션 인터페이스를 만들고 `getAddress()`에서 이 인터페이스를 반환해라:

**Example 66. A projection interface to retrieve a subset of attributes**

```java
interface PersonSummary {

  String getFirstname();
  String getLastname();
  AddressSummary getAddress();

  interface AddressSummary {
    String getCity();
  }
}
```

메소드를 실행하면 타겟 인스턴스의 `address` 프로퍼티를 가져와 차례대로 프로젝션 프록시로 감싼다.

##### Closed Projections

접근자 메소드가 모두 타겟 집계 타입의 프로퍼티와 일치하는 프로젝션 인터페이스는 닫힌 프로젝션으로 간주한다. 다음 예제는 (앞에서도 사용했던 예제) 닫힌 프로젝션이다:

**Example 67. A closed projection**

```java
interface NamesOnly {

  String getFirstname();
  String getLastname();
}
```

닫힌 프로젝션을 사용한다면, 스프링 데이터는 프로젝션 프록시에 필요한 속성을 전부 알 수 있기 때문에 쿼리 실행을 최적화할 수 있다. 자세한 내용은 모듈 전용 레퍼런스 문서를 참고해라.

##### Open Projections

프로젝션 인터페이스의 접근자 메소드는 아래 예제처럼 `@Value` 어노테이션으로 새 값을 계산하는 데에도 활용할 수 있다:

**Example 68. An Open Projection**

```java
interface NamesOnly {

  @Value("#{target.firstname + ' ' + target.lastname}")
  String getFullName();
  …
}
```

프로젝션에 사용할 집계 루트는 `target` 변수로 접근할 수 있다. `@Value`를 사용한 프로젝션 인터페이스는 열린 프로젝션이다. SpEL 표현식에선 집계 루트에 있는 어떤 속성이든지 전부 다 참조할 수 있기 때문에 스프링 데이터가 쿼리 실행을 최적화하지 못한다.

`@Value` 안에 있는 표현식이 너무 복잡해선 안 된다 — `String` 변수들로 프로그래밍긴 싫을 거다. 매우 간단한 표현식이라면, 다음 예제처럼 자바 8에서 소개된 디폴트 메소드를 빌려오는 것도 좋은 방법이다:

**Example 69. A projection interface using a default method for custom logic**

```java
interface NamesOnly {

  String getFirstname();
  String getLastname();

  default String getFullName() {
    return getFirstname().concat(" ").concat(getLastname());
  }
}
```

디폴트 메소드를 사용하려면, 프로젝션 인터페이스로 노출한 접근자 메소드만으로 순수하게 로직을 구현할 수 있어야 한다. 더 유연한 두 번째 옵션은 다음 예제처럼 스프링 빈으로 커스텀 로직을 구현한 다음 SpEL 표현식에서 이 빈을 호출하는 거다:

<span id="projections.interfaces.open.bean-reference"></span>

**Example 70. Sample Person object**

```java
@Component
class MyBean {

  String getFullName(Person person) {
    …
  }
}

interface NamesOnly {

  @Value("#{@myBean.getFullName(target)}")
  String getFullName();
  …
}
```

SpEL 표현식이 `myBean`을 참조해 `getFullName(…)` 메소드를 호출하고, 프로젝션 타겟을 메소드 파라미터로 전달하는 방법에 주목해라. 메소드 파라미터가 있어도 SpEL 표현식으로 평가할 수 있으며, 표현식에서도 이 파라미터를 참조할 수 있다. 메소드 파라미터는 `args`라는 `Object` 배열로 접근한다. 다음 예제는 `args` 배열에서 메소드 파라미터를 가져오는 방법을 보여준다:

**Example 71. Sample Person object**

```java
interface NamesOnly {

  @Value("#{args[0] + ' ' + target.firstname + '!'}")
  String getSalutation(String prefix);
}
```

다시 말하지만, 더 복잡한 표현식은 [앞에서 설명](#projections.interfaces.open.bean-reference)했듯이 스프링 빈을 사용하고, 표현식에선 빈 메소드를 호출해야 한다.

##### Nullable Wrappers

프로젝션 인터페이스의 getter 메소드에 nullable 래퍼를 사용하면 null-safety를 개선할 수 있다. 현재 지원하는 래퍼 타입은 다음과 같다:

- `java.util.Optional`
- `com.google.common.base.Optional`
- `scala.Option`
- `io.vavr.control.Option`

**Example 72. A projection interface using nullable wrappers**

```java
interface NamesOnly {

  Optional<String> getFirstname();
}
```

getter 메소드는 프로젝션 값이 `null`이 아니면 이 값을 래퍼 타입으로 감싸서 반환한다. 프로젝션 값이 `null`이라면 빈 값을 표현하는 래퍼 타입을 반환한다.

#### Class-based Projections (DTOs)

프로젝션을 정의하는 또 한 가지 방법은 조회할 필드만 프로퍼티로 가지고 있는 DTO(Data Transfer Objects)를 만드는 방법이다. DTO 타입은 프록시를 사용하지 않고 중첩 프로젝션을 적용할 수 없다는 점만 제외하면, 프로젝션 인터페이스와 동일하게 사용할 수 있다.

저장소가 로드할 필드를 제한해서 쿼리 실행을 최적화할 땐, 노출한 생성자의 파라미터 이름을 보고 로드할 필드를 결정한다.

다음은 프로젝션 DTO 예시다:

**Example 73. A projecting DTO**

```java
class NamesOnly {

  private final String firstname, lastname;

  NamesOnly(String firstname, String lastname) {

    this.firstname = firstname;
    this.lastname = lastname;
  }

  String getFirstname() {
    return this.firstname;
  }

  String getLastname() {
    return this.lastname;
  }

  // equals(…) and hashCode() implementations
}
```

> **프로젝션 DTO의 보일러플레이트 코드 줄이기**
>
> [프로젝트 롬복](https://projectlombok.org/)을 사용하면 DTO 코드가 드라마틱하게 단순해진다. 롬복은 `@Value` 어노테이션을 제공한다 (이전에 인터페이스 예제에서 보여줬던 스프링의 `@Value` 어노테이션과 헷갈리지 말 것). 위에 있는 샘플 DTO에 롬복 `@Value` 어노테이션을 사용하면 코드는 다음과 같이 바뀐다:
>
> ```java
> @Value
> class NamesOnly {
> String firstname, lastname;
> }
> ```
> 디폴트로 필드는 `private final`이 되고, 클래스는 모든 필드를 받는 생성자를 노출하며, 자동으로 `equals(…)`와 `hashCode()` 메소드가 구현된다.

#### Dynamic Projections

지금까지는 반환 타입이나 컬렉션 요소 타입만 프로젝션 타입으로 사용했다. 하지만 실행 시점에 (즉, 동적으로) 사용할 타입을 선택하는 것도 가능하다. 다이나믹 프로젝션을 적용하려면 다음 예제와 같은 쿼리 메소드를 사용해라:

**Example 74. A repository using a dynamic projection parameter**

```java
interface PersonRepository extends Repository<Person, UUID> {

  <T> Flux<T> findByLastname(String lastname, Class<T> type);
}
```

이 메소드로는 있는 그대로의 집계나 프로젝션을 적용한 집계를 조회할 수 있다:

**Example 75. Using a repository with dynamic projections**

```java
void someMethod(PersonRepository people) {

  Flux<Person> aggregates =
    people.findByLastname("Matthews", Person.class);

  Flux<NamesOnly> aggregates =
    people.findByLastname("Matthews", NamesOnly.class);
}
```

#### Result Mapping

인터페이스 또는 DTO 프로젝션을 반환하는 쿼리 메소드는 실제 쿼리가 생산한 결과가 뒷받침한다. 인터페이스 프로젝션은 보통 도메인 타입에 매핑된 결과를 먼저 참고해 `@Column` 타입 매핑을 살펴보고, 실제 프로젝션 프록시가 부분적으로나마 미리 실체화된 엔티티를 사용해서 프로젝션 데이터를 노출한다.

DTO 프로젝션은 실제 쿼리 타입에 따라 다르게 매핑된다. 파생 쿼리는 도메인 타입에 결과를 매핑한 다음, 스프링 데이터가 도메인 타입에서 가능한 프로퍼티만 가져와 DTO 인스턴스를 만든다. 도메인 타입에 없는 프로퍼티는 DTO에 선언할 수 없다.

문자열로 직접 지정한 쿼리에선 실제 쿼리, 특히 필드 프로젝션과 결과 타입 선언이 가까운 곳에 있기 때문에 다르게 접근한다. `@Query` 어노테이션이 달린 쿼리 메소드에 DTO 프로젝션을 사용하면, 쿼리 결과를 DTO 타입에 직접 매핑한다. 도메인 타입에는 필드를 매핑하지 않는다. DTO 타입을 직접 사용하기 때문에, 쿼리 메소드가 도메인 모델에 제약을 받지 않아 보다 동적인 프로젝션이 가능하다.

---

## 14.3. Entity Callbacks

스프링 데이터 인프라는 특정 메소드를 호출하기 전후에 엔티티를 수정할 수 있는 훅을 제공한다. 이른바 `EntityCallback` 인스턴스는, 콜백 스타일로 엔티티를 확인하고, 원하면 엔티티를 수정할 수도 있는 편리한 방법을 제공한다.

`EntityCallback`은 특화된 `ApplicationListener`와 매우 유사해 보인다. 일부 스프링 데이터 모듈은 전달받은 엔티티를 수정할 수 있는 저장소 전용 이벤트(`BeforeSaveEvent` 등)를 발행하기도 한다. 불변(immutable) 타입으로 작업할 때 등 일부 상황에선 이 이벤트가 문제를 일으킬 수 있다. 게다가 이벤트 발행은 `ApplicationEventMulticaster`에 의존한다. 이벤트를 비동기 `TaskExecutor`로 설정했다면 이벤트 처리 로직이 스레드로 갈라질 수 있어 결과를 예측하기 어렵다.

엔티티 콜백은 동기 API와 리액티브 API를 통합해, 프로세싱 체인 내에 잘 정의된 체크포인트를 순차로 실행함을 보장하고, (수정했다면) 수정된 엔티티나 리액티브 래퍼 타입을 반환한다.

엔티티 콜백은 전형적으로 API 타입에 따라 구분한다. 이 말은 동기 API는 동기 엔티티 콜백만, 리액티브 구현체는 리액티브 엔티티 콜백만 고려한다는 뜻이다.

> 엔티티 콜백 API는 스프링 데이터 Commons 2.2에서 도입됐다. 엔티티를 수정할 때 사용을 권장하는 API다. 기존 저장소 전용 `ApplicationEvents`도 등록한 `EntityCallback` 인스턴스를 실행한 **다음에** 발행된다.

### 14.3.1. Implementing Entity Callbacks

`EntityCallback`은 제네릭 타입 인자를 통해 도메인 타입과 직접 연결된다. 보통 스프링 데이터 모듈은 엔티티 라이프 사이클을 다루는 `EntityCallback` 인터페이스 셋을 미리 정의해두고 모듈과 함께 제공한다.

**Example 76. Anatomy of an `EntityCallback`**

```java
@FunctionalInterface
public interface BeforeSaveCallback<T> extends EntityCallback<T> {

  /**
   * Entity callback method invoked before a domain object is saved.
   * Can return either the same or a modified instance.
   *
   * @return the domain object to be persisted.
   */
  T onBeforeSave(T entity <2>, String collection <3>); // (1)
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 엔티티를 저장하기 전에 호출하는 전용 메소드 `BeforeSaveCallback`. 인스턴스를 수정해서 리턴할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 영속화하기 직전 엔티티.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 엔티티를 영속화할 *컬렉션* 등의 다양한 저장소 전용 인자.</small>

**Example 77. Anatomy of a reactive `EntityCallback`**

```java
@FunctionalInterface
public interface ReactiveBeforeSaveCallback<T> extends EntityCallback<T> {

  /**
   * Entity callback method invoked on subscription, before a domain object is saved.
   * The returned Publisher can emit either the same or a modified instance.
   *
   * @return Publisher emitting the domain object to be persisted.
   */
  Publisher<T> onBeforeSave(T entity <2>, String collection <3>); // (1)
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 구독 시 엔티티를 저장하기 전에 호출하는 전용 메소드 `BeforeSaveCallback`. 인스턴스를 수정해서 방출할 수 있다.</small><br><small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 영속화하기 직전 엔티티.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 엔티티를 영속화할 *컬렉션* 등의 다양한 저장소 전용 인자.</small>

> 추가로 필요한 엔티티 콜백 파라미터는 스프링 데이터 모듈 구현체에서 정의하며, `EntityCallback.callback()`을 호출할 때 파라미터를 추론한다.

아래 예제처럼 어플리케이션 요구사항에 맞게 인터페이스를 구현하면 된다:

**Example 78. Example `BeforeSaveCallback`**

```java
class DefaultingEntityCallback implements BeforeSaveCallback<Person>, Ordered {      // (2)

  @Override
  public Object onBeforeSave(Person entity, String collection) {                   // (1)

    if(collection == "user") {
        return // ...
    }

    return // ...
  }

  @Override
  public int getOrder() {
    return 100;                                                                  // (2)
  }
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 요구사항에 따른 콜백 구현.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 같은 도메인 타입에 엔티티 콜백이 여러 개일 때를 대비해 엔티티 콜백의 우선순위를 정한다. 숫자가 낮을수록 우선순위가 높다.</small>

### 14.3.2. Registering Entity Callbacks

`EntityCallback` 빈들은 `ApplicationContext`에 등록해주면 저장소 전용 구현체가 가져와 설정한다. 템플릿 API는 대부분 `ApplicationContextAware`를 구현하고 있으므로 `ApplicationContext`에 접근할 수 있다.

다음은 엔티티 콜백을 등록하는 유효한 방법들을 모아놓은 예제다:

**Example 79. Example `EntityCallback` Bean registration**

```java
@Order(1)                                                           // (1)
@Component
class First implements BeforeSaveCallback<Person> {

  @Override
  public Person onBeforeSave(Person person) {
    return // ...
  }
}

@Component
class DefaultingEntityCallback implements BeforeSaveCallback<Person>,
                                                           Ordered { // (2)

  @Override
  public Object onBeforeSave(Person entity, String collection) {
    // ...
  }

  @Override
  public int getOrder() {
    return 100;                                                  // (2)
  }
}

@Configuration
public class EntityCallbackConfiguration {

    @Bean
    BeforeSaveCallback<Person> unorderedLambdaReceiverCallback() {   // (3)
        return (BeforeSaveCallback<Person>) it -> // ...
    }
}

@Component
class UserCallbacks implements BeforeConvertCallback<User>,
                                        BeforeSaveCallback<User> {   // (4)

  @Override
  public Person onBeforeConvert(User user) {
    return // ...
  }

  @Override
  public Person onBeforeSave(User user) {
    return // ...
  }
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `@Order` 어노테이션으로 우선순위를 할당하는 `BeforeSaveCallback`.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> `Ordered` 인터페이스를 구현해서 우선순위를 할당하는 `BeforeSaveCallback`.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 람다 표현식을 사용하는 `BeforeSaveCallback`. 기본적으로 우선 순위를 할당하지 않고 마지막에 실행된다. 람다 표현식으로 구현한 콜백은 타입 정보를 노출하지 않으므로, 할당할 수 없는 엔티티로 콜백을 실행하면 콜백 throughput에 영향을 끼친다는 점에 주의해라. 콜백 빈에서 `class`나 `enum`을 사용해 타입을 필터링해라.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> 여러 콜백 인터페이스를 결합해 단일 클래스로 구현한다.</small>

### 14.3.3. Store specific EntityCallbacks

스프링 데이터 R2DBC는 `EntityCallback` API를 사용해 감사(auditing)를 지원하며, 다음과 같은 콜백에 반응한다.

**Table 4. Supported Entity Callbacks**

| Callback               | Method                                                       | Description                                                  | Order                       |
| :--------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- | :-------------------------- |
| BeforeConvertCallback  | `onBeforeConvert(T entity, SqlIdentifier table)`             | 도메인 객체가 `OutboundRow`로 변환되기 전에 실행된다.        | `Ordered.LOWEST_PRECEDENCE` |
| AfterConvertCallback   | `onAfterConvert(T entity, SqlIdentifier table)`              | 도메인 객체를 로드한 다음에 실행된다. row에서 데이터를 읽어온 후에 도메인 객체를 수정할 수 있다. | `Ordered.LOWEST_PRECEDENCE` |
| AuditingEntityCallback | `onBeforeConvert(T entity, SqlIdentifier table)`             | 감사 중인 엔티티를 *created* 또는 *modified*로 마킹한다.     | 100                         |
| BeforeSaveCallback     | `onBeforeSave(T entity, OutboundRow row, SqlIdentifier table)` | 도메인 객체를 저장하기 전에 실행된다. 모든 엔티티 매핑 정보를 가지고 있는, 영속화할 타겟 `OutboundRow`를 수정할 수 있다. | `Ordered.LOWEST_PRECEDENCE` |
| AfterSaveCallback      | `onAfterSave(T entity, OutboundRow row, SqlIdentifier table)` | 도메인 객체를 저장한 후에 실행된다. 모든 엔티티 매핑 정보를 가지고 있는 `OutboundRow`를 저장한 후에 반환할 도메인 객체를 수정할 수 있다. | `Ordered.LOWEST_PRECEDENCE` |

---

## 14.4. Working with multiple Databases

여러 데이터베이스를 동시에 사용하는 어플리케이션은 또다른 설정이 필요하다. 기본 제공하는 서포트 클래스 `AbstractR2dbcConfiguration`은 `ConnectionFactory`가 하나일 것으로 가정하고, 따라서 `Dialect`도 하나만 선택한다. 그렇기 때문에 데이터베이스를 여러 개 사용하려면 스프링 데이터 R2DBC 설정을 위한 몇 가지 빈을 직접 정의해야 한다.

R2DBC 레포지토리를 구현하려면 `R2dbcEntityOperations`가 필요하다. `AbstractR2dbcConfiguration` 없이 레포지토리를 스캔하는 간단한 설정은 다음과 같다:

```java
@Configuration
@EnableR2dbcRepositories(basePackages = "com.acme.mysql", entityOperationsRef = "mysqlR2dbcEntityOperations")
static class MySQLConfiguration {

    @Bean
    @Qualifier("mysql")
    public ConnectionFactory mysqlConnectionFactory() {
        return …
    }

    @Bean
    public R2dbcEntityOperations mysqlR2dbcEntityOperations(@Qualifier("mysql") ConnectionFactory connectionFactory) {

        DatabaseClient databaseClient = DatabaseClient.create(connectionFactory);

        return new R2dbcEntityTemplate(databaseClient, MySqlDialect.INSTANCE);
    }
}
```

`@EnableR2dbcRepositories`는 `databaseClientRef`, `entityOperationsRef` 두 가지로 설정할 수 있다는 점에 주목하자. 동일한 타입을 여러 데이터베이스에 연결할 땐 `DatabaseClient` 빈을 여러 개 사용하는 게 유용하다. 방언(dialect)이 서로 다른 데이터베이스 시스템을 이용하는 경우라면 대신에 `@EnableR2dbcRepositories(entityOperationsRef = …)`를 사용해라.