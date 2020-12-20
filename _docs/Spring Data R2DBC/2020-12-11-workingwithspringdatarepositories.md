---
title: Working with Spring Data Repositories
category: Spring Data R2DBC
order: 12
permalink: /Spring%20Data%20R2DBC/workingwithspringdatarepositories/
description: 스프링 R2DBC 적용에 앞서 알아둬야 할 스프링 데이터 모듈 기본 개념과 레포지토리 인터페이스 사용법
image: ./../../images/spring/logo.png
lastmod: 2020-12-19T23:00:00+09:00
comments: true
priority: 0.6
originalRefName: 스프링 데이터 R2DBC
originalRefLink: https://docs.spring.io/spring-data/r2dbc/docs/1.2.2/reference/html/#repositories
---

### 목차

- [11.1. Core concepts](#111-core-concepts)
- [11.2. Query Methods](#112-query-methods)
- [11.3. Defining Repository Interfaces](#113-defining-repository-interfaces)
  + [11.3.1. Fine-tuning Repository Definition](#1131-fine-tuning-repository-definition)
  + [11.3.2. Using Repositories with Multiple Spring Data Modules](#1132-using-repositories-with-multiple-spring-data-modules)
- [11.4. Defining Query Methods](#114-defining-query-methods)
  + [11.4.1. Query Lookup Strategies](#1141-query-lookup-strategies)
  + [11.4.2. Query Creation](#1142-query-creation)
  + [11.4.3. Property Expressions](#1143-property-expressions)
  + [11.4.4. Special parameter handling](#1144-special-parameter-handling)
    * [Paging and Sorting](#paging-and-sorting)
  + [11.4.5. Limiting Query Results](#1145-limiting-query-results)
  + [11.4.6. Repository Methods Returning Collections or Iterables](#1146-repository-methods-returning-collections-or-iterables)
    * [Using Streamable as Query Method Return Type](#using-streamable-as-query-method-return-type)
    * [Returning Custom Streamable Wrapper Types](#returning-custom-streamable-wrapper-types)
    * [Support for Vavr Collections](#support-for-vavr-collections)
  + [11.4.7. Null Handling of Repository Methods](#1147-null-handling-of-repository-methods)
    * [Nullability Annotations](#nullability-annotations)
    * [Nullability in Kotlin-based Repositories](#nullability-in-kotlin-based-repositories)
  + [11.4.8. Streaming Query Results](#1148-streaming-query-results)
  + [11.4.9. Asynchronous Query Results](#1149-asynchronous-query-results)
- [11.5. Creating Repository Instances](#115-creating-repository-instances)
  + [11.5.1. XML Configuration](#1151-xml-configuration)
    * [Using Filters](#using-filters)
  + [11.5.2. Java Configuration](#1152-java-configuration)
  + [11.5.3. Standalone Usage](#1153-standalone-usage)
- [11.6. Custom Implementations for Spring Data Repositories](#116-custom-implementations-for-spring-data-repositories)
  + [11.6.1. Customizing Individual Repositories](#1161-customizing-individual-repositories)
    * [Configuration](#configuration)
  + [11.6.2. Customize the Base Repository](#1162-customize-the-base-repository)
- [11.7. Publishing Events from Aggregate Roots](#117-publishing-events-from-aggregate-roots)
- [11.8. Spring Data Extensions](#118-spring-data-extensions)
  + [11.8.1. Querydsl Extension](#1181-querydsl-extension)
  + [11.8.2. Web support](#1182-web-support)
    * [Basic Web Support](#basic-web-support)
    * [Hypermedia Support for Pageables](#hypermedia-support-for-pageables)
    * [Web Databinding Support](#web-databinding-support)
    * [Querydsl Web Support](#querydsl-web-support)
  + [11.8.3. Repository Populators](#1183-repository-populators)

---

스프링 데이터 레포지토리의 추상화 목표는, persistence 저장소마다 데이터 접근 레이어를 구현하는데 필요한 보일러플레이트를 확 줄이는 데에 있다.

> *스프링 데이터 레포지토리 문서와 각자의 스프링 데이터 모듈*
>
> 이 챕터에선 스프링 데이터 레포지토리의 핵심 개념과 인터페이스를 설명한다. 이 챕터에서 다루는 내용은 스프링 데이터 공통 모듈에서 가져왔다. 설정 예제와 샘플 코드는 JPA(Java Persistence API) 모듈을 활용한다. XML 네임스페이스 선언과 타입은 각자 사용하려는 모듈에 맞게 바꿔야 한다. "[[레포지토리 네임스페이스 레퍼런스\]](https://docs.spring.io/spring-data/jdbc/docs/2.1.2/reference/html/#repositories.namespace-reference)"에선 레포지토리 API를 지원하는 모든 스프링 데이터 모듈에서 사용할 수 있는 XML 설정을 다룬다. "[레포지토리 쿼리 키워드](https://docs.spring.io/spring-data/r2dbc/docs/1.2.2/reference/html/#repository-query-keywords)"에선 범용 레포지토리 인터페이스가 지원하는 쿼리 메소드 키워드를 설명한다. 원하는 모듈에 있는 기능을 자세히 알고싶다면 해당 모듈 챕터를 확인해라.

---

## 11.1. Core concepts

스프링 데이터 레포지토리 추상화에 있어 핵심 인터페이스는 `Repository`다. `Repository` 인터페이스는 관리할 도메인 클래스와 도메인 클래스의 ID 타입을 타입 인자로 사용한다. 일종의 마커 인터페이스로, 처리할 타입을 알아내고, 이 인터페이스를 확장한 다른 인터페이스를 발견할 수 있도록 만드는 게 주된 역할이다. [`CrudRepository`](https://docs.spring.io/spring-data/commons/docs/current/api/org/springframework/data/repository/CrudRepository.html) 인터페이스는 관리 중인 엔티티 클래스를 위한 정교한 CRUD 기능을 제공한다.

**Example 3. `CrudRepository` Interface**

```java
public interface CrudRepository<T, ID> extends Repository<T, ID> {

  <S extends T> S save(S entity);      // (1)

  Optional<T> findById(ID primaryKey); // (2)

  Iterable<T> findAll();               // (3)

  long count();                        // (4)

  void delete(T entity);               // (5)

  boolean existsById(ID primaryKey);   // (6)

  // … more functionality omitted.
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 전달받은 엔티티를 저장한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 전달받은 ID로 식별한 엔티티를 반환한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 모든 엔티티를 반환한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> 엔티티 수를 반환한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> 전달받은 엔티티를 삭제한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(6)</span> 전달받은 ID에 해당하는 엔티티가 있는지 알려준다.</small>

> `JpaRepository`, `MongoRepository`같이 persistence 기술에 특화된 인터페이스도 제공한다. 이런 인터페이스들은 `CrudRepository`를 상속하고 있으며,  `CrudRepository`같이 persistence 기술에 구애받지 않는 범용 인터페이스 외에도, persistence 기술에 따른 전용 기능도 노출하고 있다.

`CrudRepository` 위에는, 쉽게 페이지를 처리할 수 있게 메소드를 추가한 [`PagingAndSortingRepository`](https://docs.spring.io/spring-data/commons/docs/current/api/org/springframework/data/repository/PagingAndSortingRepository.html) 인터페이스가 있다:

**Example 4. `PagingAndSortingRepository` interface**

```java
public interface PagingAndSortingRepository<T, ID> extends CrudRepository<T, ID> {

  Iterable<T> findAll(Sort sort);

  Page<T> findAll(Pageable pageable);
}
```

페이지 크기를 20으로 잡고 두 번째 `User` 페이지에 접근하고 싶다면, 다음처럼 코드를 작성하면 된다:

```java
PagingAndSortingRepository<User, Long> repository = // … get access to a bean
Page<User> users = repository.findAll(PageRequest.of(1, 20));
```

쿼리 메소드에선 count와 delete 쿼리를 위한 파생 쿼리(query derivation)도 만들 수 있다. 다음은 count 쿼리를 파생시키는 인터페이스 정의다:

**Example 5. Derived Count Query**

```java
interface UserRepository extends CrudRepository<User, Long> {

  long countByLastname(String lastname);
}
```

이번엔 delete 쿼리를 파생시키는 인터페이스 정의다:

**Example 6. Derived Delete Query**

```java
interface UserRepository extends CrudRepository<User, Long> {

  long deleteByLastname(String lastname);

  List<User> removeByLastname(String lastname);
}
```

---

## 11.2. Query Methods

표준 CRUD를 제공하는 레포지토리는 보통 저장소에 대한 쿼리를 가지고 있다. 스프링 데이터에선 네 단계로 쿼리를 선언하게 된다:

1. 레포지토리나 하위 인터페이스 중 하나를 확장한 인터페이스를 정의하고, 처리할 도메인 클래스와 ID 타입을 지정한다:

   ```java
   interface PersonRepository extends Repository<Person, Long> { … }
   ```

2. 인터페이스에 쿼리 메소드를 정의한다:

   ```java
   interface PersonRepository extends Repository<Person, Long> {
     List<Person> findByLastname(String lastname);
   }
   ```

3. 이 인터페이스를 위한 프록시 인스턴스를 만들도록 스프링 [자바 설정](#1152-java-configuration)이나 [XML 설정](#1151-xml-configuration)을 작성한다.

   a. 자바 설정에선 아래와 유사한 클래스를 만든다:

      ```java
      import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
      
      @EnableJpaRepositories
      class Config { … }
      ```

   b. XML 설정에선 아래와 유사한 빈을 정의한다:

      ```xml
      <?xml version="1.0" encoding="UTF-8"?>
      <beans xmlns="http://www.springframework.org/schema/beans"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xmlns:jpa="http://www.springframework.org/schema/data/jpa"
         xsi:schemaLocation="http://www.springframework.org/schema/beans
           https://www.springframework.org/schema/beans/spring-beans.xsd
           http://www.springframework.org/schema/data/jpa
           https://www.springframework.org/schema/data/jpa/spring-jpa.xsd">
      
         <jpa:repositories base-package="com.acme.repositories"/>
      
      </beans>
      ```

      이 예제에선 JPA 네임스페이스를 사용한다. 다른 저장소 전용 레포지토리 인터페이스를 사용한다면, 저장소 모듈에 맞는 네임스페이스 선언으로 변경해야 한다. 다시 말해 `jpa`를 각자에 맞게, 이를테면 `mongodb` 등으로 바꿔야 한다.

      덧붙이자면, 자바 설정에선 어노테이션을 달아준 클래스가 있는 패키지를 기본으로 사용하기 때문에 패키지를 명시하지 않았다. 스캔할 패키지를 커스텀하고 싶다면, 저장소 전용 레포지토리의 `@Enable${store}Repositories`-어노테이션에 있는 `basePackage…` 속성 중 하나를 사용해라.

4. 사용처에 레포지토리 인스턴스를 주입한다:

   ```java
   class SomeClient {
   
     private final PersonRepository repository;
   
     SomeClient(PersonRepository repository) {
       this.repository = repository;
     }
   
     void doSomething() {
       List<Person> persons = repository.findByLastname("Matthews");
     }
   }
   ```

이어지는 섹션에서 단계별로 하나씩 설명하겠다:

- [레포지토리 인터페이스 정의하기](#113-defining-repository-interfaces)
- [쿼리 메소드 정의하기](#114-defining-query-methods)
- [레포지토리 인스턴스 생성하기](#115-creating-repository-instances)
- [스프링 데이터 레포지토리 커스텀 기능 구현](#116-custom-implementations-for-spring-data-repositories)

---

## 11.3. Defining Repository Interfaces

레포지토리 인터페이스를 정의하려면 먼저, 도메인 클래스 전용 레포지토리 인터페이스부터 정의해야 한다. 이 인터페이스는 반드시 `Repository`를 상속하고, 해당 도메인 클래스와 ID 타입을 지정해야 한다. 도메인 타입에 맞는 CRUD 메소드를 노출하려면 `Repository` 대신 `CrudRepository`를 상속해라.

### 11.3.1. Fine-tuning Repository Definition

보통 레포지토리 인터페이스를 만들 땐 `Repository`나 `CrudRepository`, `PagingAndSortingRepository`를 확장한다. 스프링 데이터 인터페이스를 확장하고 싶지 않다면, 레포지토리 인터페이스에 `@RepositoryDefinition` 어노테이션을 붙여도 된다. `CrudRepository`를 확장하면 엔티티를 조작할 수 있는 완전한 메소드 셋이 생긴다. 그보단 노출할 메소드를 직접 선택하고 싶다면 `CrudRepository`에서 원하는 메소드를 도메인 레포지토리로 복사해가라.

> 이렇게 하면 기본 스프링 데이터 레포지토리 기능 위에 자체 인터페이스를 정의하게 된다.

원하는 CRUD 메소드만 노출하는 방법은 다음 예제를 참고해라 (이 예제에선 `findById`와 `save`):

**Example 7. Selectively exposing CRUD methods**

```java
@NoRepositoryBean
interface MyBaseRepository<T, ID> extends Repository<T, ID> {

  Optional<T> findById(ID id);

  <S extends T> S save(S entity);
}

interface UserRepository extends MyBaseRepository<User, Long> {
  User findByEmailAddress(EmailAddress emailAddress);
}
```

위 예제에선 모든 도메인 레포지토리에 활용할 공통 베이스 인터페이스를 정의하고, `findById(…)`와 `save(…)` 메소드를 노출했다. 이렇게 정의한 메소드들은 `CrudRepository`의 메소드 시그니처와 일치하기 때문에, 스프링 데이터가 제공하는, 각자의 저장소에 맞는 베이스 레포지토리 구현체로 라우팅된다 (예를 들어 JPA를 사용한다면 `SimpleJpaRepository` 구현체). 따라서 이제 `UserRepository`는 사용자를 저장할 수 있고, ID로 각 사용자를 검색할 수 있으며, 이메일 주소로 `Users`를 검색하는 쿼리를 트리거할 수 있다.

> 중간 레포지토리 인터페이스는 `@NoRepositoryBean` 어노테이션이 달려있다. 스프링 데이터가 런타임에 인스턴스를 만들면 안 되는 모든 레포지토리 인터페이스에는 반드시 이 어노테이션을 선언해야 한다.

### 11.3.2. Using Repositories with Multiple Spring Data Modules

어플리케이션에서 사용하는 스프링 데이터 모듈이 하나 뿐이면, 정의한 스코프 내 있는 모든 레포지토리 인터페이스가 해당 스프링 데이터 모듈에 바인딩되기 때문에 별다른 어려움이 없다. 하지만 다른 스프링 데이터 모듈을 동시에 사용하기도 한다. 이럴 땐 반드시 레포지토리 정의로 저장소 persistence 기술을 구분해줘야 한다. 클래스패스에서 레포지토리 팩토리를 여러 개 발견하면, 스프링 데이터는 strict 레포지토리 설정 모드로 진입한다. strict 모드에선 레포지토리나 도메인 클래스의 세부 정보를 확인해 레포지토리가 바인딩할 스프링 데이터 모듈을 결정한다:

1. 정의한 레포지토리가 [모듈 전용 레포지토리를 상속](#repositories.multiple-modules.types)하고 있다면, 해당 스프링 데이터 모듈에 바인딩한다.
2. 도메인 클래스에 [모듈 전용 타입 어노테이션](#repositories.multiple-modules.annotations)이 있다면, 해당 스프링 데이터 모듈에 바인딩한다. 스프링 데이터 모듈은 제 3자의 어노테이션을 수용하기도하고 (JPA의 `@Entity` 같은), 자체 어노테이션을 제공하기도 한다 (스프링 데이터 MongoDB와 스프링 데이터 Elasticsearch을 위한 `@Document` 등).

다음은 모듈 전용 인터페이스를 사용하는 레포지토리 예시다 (여기선 JPA):

<span id="repositories.multiple-modules.types"></span>**Example 8. Repository definitions using module-specific interfaces**

```java
interface MyRepository extends JpaRepository<User, Long> { }

@NoRepositoryBean
interface MyBaseRepository<T, ID> extends JpaRepository<T, ID> { … }

interface UserRepository extends MyBaseRepository<User, Long> { … }
```

`MyRepository`와 `UserRepository`는 타입 계층구조 상 `JpaRepository`를 상속한다. 따라서 두 레포지토리 모두 스프링 데이터 JPA 모듈에 바인딩한다.

다음은 범용 인터페이스를 사용하는 레포지토리 예시다:

**Example 9. Repository definitions using generic interfaces**

```java
interface AmbiguousRepository extends Repository<User, Long> { … }

@NoRepositoryBean
interface MyBaseRepository<T, ID> extends CrudRepository<T, ID> { … }

interface AmbiguousUserRepository extends MyBaseRepository<User, Long> { … }
```

`AmbiguousRepository`와 `AmbiguousUserRepository`는 계층구조에서 `Repository`와 `CrudRepository`만 상속한다. 스프링 데이터 모듈을 하나만 사용한다면 문제 없지만, 모듈이 여러 개면 각 레포지토리가 바인딩할 스프링 데이터를 구분할 수 없다.

다음은 도메인 클래스에 어노테이션을 선언한 레포지토리다:

<span id="repositories.multiple-modules.annotations"></span>**Example 10. Repository definitions using domain classes with annotations**

```java
interface PersonRepository extends Repository<Person, Long> { … }

@Entity
class Person { … }

interface UserRepository extends Repository<User, Long> { … }

@Document
class User { … }
```

`PersonRepository`가 참조하는 `Person`은 JPA `@Entity`  어노테이션을 선언했으므로, 이 레포지토리는 스프링 데이터 JPA에 속한다는 걸 분명히 알 수 있다. `UserRepository`에서 참조하는 `User`는 스프링 데이터 MongoDB의 `@Document` 어노테이션이 달려있다.

다음은 도메인 클래스에서 어노테이션을 섞어 쓰는 잘못된 예시다:

**Example 11. Repository definitions using domain classes with mixed annotations**

```java
interface JpaPersonRepository extends Repository<Person, Long> { … }

interface MongoDBPersonRepository extends Repository<Person, Long> { … }

@Entity
@Document
class Person { … }
```

이 예제의 도메인 클래스는 JPA와 스프링 데이터 MongoDB 어노테이션을 둘 다 사용하고 있다. 그리고 `JpaPersonRepository`, `MongoDBPersonRepository`라는 레포지토리를 두 개 만들었다. 하나는 JPA, 다른 하나는 MongoDB를 의도한 듯하다. 하지만 이렇게 정의하면 스프링 데이터는 레포지토리를 구분할 수 없기 때문에, 정의되지 않은 동작(undefined behavior)을 이끌게 된다.

strict 레포지토리 설정에선 [레포지토리 상세 타입](#repositories.multiple-modules.types)과 [도메인 클래스 어노테이션](#repositories.multiple-modules.annotations)을 비교해서 스프링 데이터 모듈에 사용할 레포지토리 후보를 식별한다. 도메인 타입 하나에 다른 persistence 기술 전용 어노테이션을 여러 개 선언하는 것 자체는 가능한데, 이렇게 하면 도메인 클래스를 여러 persistence 기술에서 재사용할 수 있다. 하지만 스프링 데이터에선 레포지토리를 바인딩할 유일한 모듈을 결정할 수 없다.

레포지토리를 구분할 수 있는 최후의 방법은 레포지토리의 베이스 패키지 범위를 지정하는 거다. 베이스 패키지는 레포지토리 인터페이스를 스캔할 시작점을 정의하며, 그 패키지 안에 레포지토리 정의가 있다는 뜻이기도 하다. 어노테이션 기반 설정은 기본적으로 설정 클래스의 패키지를 사용한다. [XML 기반 설정에선 베이스 패키지](#1151-xml-configuration)는 필수 값이다.

다음은 어노테이션 기반 설정에서 베이스 패키지를 지정하는 예시다:

**Example 12. Annotation-driven configuration of base packages**

```java
@EnableJpaRepositories(basePackages = "com.acme.repositories.jpa")
@EnableMongoRepositories(basePackages = "com.acme.repositories.mongo")
class Configuration { … }
```

---

## 11.4. Defining Query Methods

레포지토리 프록시는 두 가지 방법으로 메소드에 해당하는 저장소 전용 쿼리를 만든다:

- 메소드 이름으로 바로 쿼리 파생.
- 수동으로 정의한 쿼리 사용.

가능한 옵션은 실제 저장소에 따라 다르다. 하지만 실제 쿼리를 생성할 때 사용하는 전략은 동일하다. 다음 섹션에서 가능한 옵션들을 설명한다.

### 11.4.1. Query Lookup Strategies

다음은 레포지토리 인프라가 쿼리를 리졸브할 때 사용할 수 있는 전략들이다. XML 설정을 사용하면 네임스페이스의 `query-lookup-strategy` 속성으로 전략을 설정할 수 있다. 자바 설정에선 `Enable${store}Repositories` 어노테이션의 `queryLookupStrategy` 속성을 사용한다. 일부 전략을 지원하지 않는 저장소도 있을 수 있다.

- `CREATE` 전략은 쿼리 메소드 이름을 사용해 저장소에 맞는 쿼리를 만든다. 보통은 메소드명에서 잘 알려진 프리픽스 셋을 제거하고, 남은 부분을 파싱한다. 자세한 내용은 [쿼리 생성](#1142-query-creation)에서 확인할 수 있다.
- `USE_DECLARED_QUERY`는 선언한 쿼리를 찾아보고, 찾지 못하면 예외를 던지는 전략이다. 쿼리는 어딘가에 어노테이션으로 정의하거나, 다른 방법으로도 선언할 수 있다. 저장소에 맞는 쿼리 선언 방법은 해당 저장소 문서를 참고해라. 부트스트랩 시점에 메소드에 적용할 쿼리 선언을 발견하지 못하면 부트스트랩은 실패한다.
- `CREATE_IF_NOT_FOUND` (디폴트) 전략은 `CREATE`와 `USE_DECLARED_QUERY`를 혼합한 전략이다. 먼저 선언한 쿼리를 찾고, 찾지 못하면 커스텀 메소드 이름을 기반으로 쿼리를 만든다. 기본 loockup 전략이므로 별다른 설정을 만들지 않았다면 이 전략을 사용한다. 이 전략은, 메소드 이름으로 빠르게 쿼리를 정의할 수도 있고, 필요 시엔 쿼리를 선언해서 원하는대로 튜닝할 수도 있는 전략이다.

### 11.4.2. Query Creation

스프링 데이터 레포지토리 인프라엔 쿼리 빌더 메커니즘이 내장돼 있으므로, 레포지토리 엔티티에 사용할 검색 쿼리 조건을 만들 때 유용하게 쓸 수 있다.

아래 예제에선 다양한 쿼리를 만드는 방법을 보여준다:

**Example 13. Query creation from method names**

```java
interface PersonRepository extends Repository<Person, Long> {

  List<Person> findByEmailAddressAndLastname(EmailAddress emailAddress, String lastname);

  // Enables the distinct flag for the query
  List<Person> findDistinctPeopleByLastnameOrFirstname(String lastname, String firstname);
  List<Person> findPeopleDistinctByLastnameOrFirstname(String lastname, String firstname);

  // Enabling ignoring case for an individual property
  List<Person> findByLastnameIgnoreCase(String lastname);
  // Enabling ignoring case for all suitable properties
  List<Person> findByLastnameAndFirstnameAllIgnoreCase(String lastname, String firstname);

  // Enabling static ORDER BY for a query
  List<Person> findByLastnameOrderByFirstnameAsc(String lastname);
  List<Person> findByLastnameOrderByFirstnameDesc(String lastname);
}
```

쿼리 메소드 이름은 주제(subject)와 판단식(predicate)으로 나누어 파싱한다. 앞 부분은 (`find…By`, `exists…By`) 쿼리 주제를 정의하고, 뒷 부분에선 판단식을 만든다. 도입부(주제)엔 추가 표현식이 있을 수도 있다. `find`와 (또는 다른 시작 키워드) `By` 사이에 있는 모든 텍스트는 서술부로 판단한다. 단, 쿼리에 distinct 플래그를 설정하는 `Distinct` 키워드나 [쿼리 결과를 제한하는 `Top`/`First`](#1145-limiting-query-results) 키워드는 예외다.

이 문서는 부록에 [쿼리 메소드 주제 키워드 전체](https://docs.spring.io/spring-data/r2dbc/docs/1.2.2/reference/html/#appendix.query.method.subject)와 [정렬과 대소문자 변형을 포함한 쿼리 메소드 판단식 키워드](https://docs.spring.io/spring-data/r2dbc/docs/1.2.2/reference/html/#appendix.query.method.predicate)를 담고 있다. 단, 첫 번째로 나오는 `By`는 실제 범위 판단식의 시작을 가리키는 구분자다. 범위 판단식을 매우 단순하게 설명하자면, 엔티티 프로퍼티에 대한 조건을 정의하고, 이 조건을 `And`와 `Or`로 연결한다.

실제로 메소드를 파싱한 결과는 쿼리를 사용하는 persistence 저장소에 따라 다르다. 그래도 공통 기능은 알아두면 좋다:

- 표현식에선 보통 가능한 연산자를 프로퍼티와 결합해서 프로퍼티를 순회한다. 프로퍼티 표현식은 `AND`와 `OR`로 결합한다. 프로퍼티 표현식에 사용할 수 있는 연산자 중에는 `Between`, `LessThan`, `GreaterThan`, `Like`도 있다. 저장소마다 지원하는 연산자가 다를 수 있으므로 적당한 레퍼런스 문서 문서를 참고해라.
- 메소드 파서에는 각 프로퍼티별로 (예를 들어 `findByLastnameIgnoreCase(…)`), 또는 전체 프로퍼티 중 가능한 모든 프로퍼티에 (보통 `String` 인스턴스 — 예를 들어 `findByLastnameAndFirstnameAllIgnoreCase(…)`) `IgnoreCase` 플래그를 설정할 수 있다. 역시 저장소별로 다를 수 있으므로, 저장소 레퍼런스 문서를 참고해라.
- 쿼리 메소드에 `OrderBy` 절을 추가해 프로퍼티와 정렬 방향(`Asc`, `Desc`)을 지정하면 정적 정렬을 적용할 수 있다. 동적 정렬을 위한 쿼리는 "[특별한 파라미터 핸들링](#1144-special-parameter-handling)"을 참고해라.

### 11.4.3. Property Expressions

위 예제에서 알 수 있듯, 프로퍼티 표현식은 관리하는 엔티티의 프로퍼티만 참조할 수 있다. [쿼리 생성 섹션](#1142-query-creation)에서 이미, 파싱한 프로퍼티는 관리 중인 도메인 클래스에 있는 프로퍼티라는 점을 익혔다. 하지만 중첩 프로퍼티도 순회할 수 있기 때문에, 엔티티 바로 밑에 있지 않은 프로퍼티도 제약 조건을 정의할 수 있다. 아래 메소드 시그니처를 생각해보자:

```java
List<Person> findByAddressZipCode(ZipCode zipCode);
```

`Person`에는 `Address` 프로퍼티가, `Address`엔 `ZipCode` 프로퍼티가 있다고 해보자. 이 메소드는 `x.address.zipCode` 프로퍼티를 순회한다. 쿼리 리졸브 알고리즘은 먼저 판단식 전체(`AddressZipCode`)를 프로퍼티로 해석해서, 도메인 클래스에 이 이름에 해당하는 프로퍼티가 있는지 확인한다 (앞 글자를 소문자로 바꿔서). 이 알고리즘이 성공하면 해당 프로퍼티를 사용한다. 실패하면 알고리즘은 오른쪽에서부터 카멜 케이스를 헤드와 테일로 분할해 프로퍼티를 찾아본다 — 이 예제에선 `AddressZip`과 `Code`. 헤드와 일치하는 프로퍼티를 찾으면, 테일을 가져 와서 다시 트리를 만들고 방금 설명한 방법으로 테일을 분할한다. 첫 번째 분할한 헤드로 프로퍼티를 찾지 못하면, 분할 포인트를 왼쪽으로 (`Address`, `ZipCode`) 이동해서 같은 알고리즘을 다시 시작한다.

대부분 이 알고리즘으로 필드를 찾을 수 있긴 하지만, 간혹 의도하지 않은 프로퍼티를 선택하곤 한다. `Person` 클래스에 `addressZip` 프로퍼티도 있었다고 생각해보자. 알고리즘에선 첫 번째로 분할해본 헤드로 프로퍼티를 찾을 거고, 이 프로퍼티를 선택해 결국 실패한다 (`addressZip` 타입엔 `code` 프로퍼티가 없을 거기 때문에).

이렇게 필드가 애매할 때는 메소드명 중간에 `_`를 사용해서 직접 순회 포인트를 지정할 수 있다. 위 메소드명은 아래처럼 바뀐다:

```java
List<Person> findByAddress_ZipCode(ZipCode zipCode);
```

스프링 데이터는 `_` 문자를 예약 문자로 처리하므로, 표준 자바 네이밍 컨센션은 반드시 따르는게 좋다 (즉, 프로퍼티 이름엔 언더스코어 대신 카멜 케이스를 사용해라).

### 11.4.4. Special parameter handling

쿼리에 파라미터를 사용하려면 위에서 본 예제처럼 메소드 파라미터를 정의하면 된다. 그 밖에도 인식할 수 있는 특별한 타입이 있는데, `Pageable`과 `Sort`다. 이 파라미터로는 페이지를 처리하고 쿼리를 동적으로 정렬할 수 있다. 아래 예제이서 이 기능을 시연해 보겠다:

**Example 14. Using `Pageable`, `Slice`, and `Sort` in query methods**

```java
Page<User> findByLastname(String lastname, Pageable pageable);

Slice<User> findByLastname(String lastname, Pageable pageable);

List<User> findByLastname(String lastname, Sort sort);

List<User> findByLastname(String lastname, Pageable pageable);
```

> `Sort`와 `Pageable`을 처리하는 API에선 이 값을 모두 non-`null`로 간주한다. 정렬이나 페이징을 사용하지 않을 때는 `Sort.unsorted()`와 `Pageable.unpaged()`를 사용해라.

첫 번째 메소드에선 쿼리 메소드에 <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.data.domain.Pageable</span> 인스턴스를 넘겨 정적으로 정의한 쿼리에 동적인 페이징을 추가있다. `Page` 인터페이스는 전체 요소 갯수와 유효한 페이지 수를 담고있다. 따라서 인프라에서 카운트 쿼리를 트리거해 전체 숫자를 계산한다. 계산 비용이 부담스럽다면 (사용하는 스토어에 따라), `Page` 대신 `Slice`를 리턴해라. `Slice`로는 다음 `Slice`가 있는지만 알 수 있다. 데이터 셋이 매우 크다면 이 정보만으로도 충분할 거다.

`Pageable` 인스턴스는 정렬 옵션도 처리한다. 정렬만 필요하다면 <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.data.domain.Sort</span> 파라미터를 사용해라. 예제에서 보이듯이 `List`를 반환할 수도 있다. `List`를 리턴하면 실제 `Page` 인스턴스를 만들 때 필요한 메타데이터를 만들지 않는다 (다시 말해, 필요할지도 모르는 카운트 쿼리를 추가로 실행하지 않는다). 그보단 주어진 범위 내에 있는 엔티티들만 찾도록 쿼리를 제안하는 역할이라고 보면 된다.

> 쿼리 자체로 온전히 가져올 수 있는 페이지가 몇 개인지 알고싶다면, 카운트 쿼리도 함께 트리거해야 한다. 기본적으로 카운트 쿼리는 실제로 트리거하는 쿼리가 파생시킨다.

#### Paging and Sorting

간단한 정렬 표현식은 프로퍼티명으로 정의할 수 있다. 정렬할 조건이 많다면, 표현식들을 이어 하나의 표현식으로 만들면 된다.

**Example 15. Defining sort expressions**

```java
Sort sort = Sort.by("firstname").ascending()
  .and(Sort.by("lastname").descending());
```

좀 더 안전한 방법으로(type-safe) 정렬 표현식을 정의하려면, 먼저 대상 타입을 가져와 메소드 레퍼런스로 정렬 프로퍼티를 정의해라.

**Example 16. Defining sort expressions by using the type-safe API**

```java
TypedSort<Person> person = Sort.sort(Person.class);

Sort sort = person.by(Person::getFirstname).ascending()
  .and(person.by(Person::getLastname).descending());
```

> `TypedSort.by(…)`는 (보통) CGlib를 사용한 런타임 프록시를 타게 되는데, Graal VM Native같은 툴을 사용하면 네이티브 이미지 컴파일과 충돌할 수도 있다.

Querydsl을 지원하는 저장소를 사용한다면, 만들어진 메타 모델 타입으로도 정렬 표현식을 정의할 수 있다:

**Example 17. Defining sort expressions by using the Querydsl API**

```java
QSort sort = QSort.by(QPerson.firstname.asc())
  .and(QSort.by(QPerson.lastname.desc()));
```

### 11.4.5. Limiting Query Results

쿼리 메소드 결과는 `first`나 `top` 키워드로 제한할 수 있으며, 두 키워드의 의미는 같다. `top`, `first` 뒤에 숫자를 추가하면 결과의 최대 크기를 지정할 수 있다. 숫자를 생략하면 1로 간주한다. 쿼리 사이즈를 제한하는 방법은 다음 예시를 참고해라:

**Example 18. Limiting the result size of a query with `Top` and `First`**

```java
User findFirstByOrderByLastnameAsc();

User findTopByOrderByAgeDesc();

Page<User> queryFirst10ByLastname(String lastname, Pageable pageable);

Slice<User> findTop3ByLastname(String lastname, Pageable pageable);

List<User> findFirst10ByLastname(String lastname, Sort sort);

List<User> findTop10ByLastname(String lastname, Pageable pageable);
```

distinct 쿼리를 지원하는 저장소에 한해 제한 표현식에 `Distinct` 키워드를 사용할 수 있다. 결과 셋을 인스턴스 하나로 제한하는 쿼리라면, 결과를 `Optional`로 감싸도 된다.

결과를 제한하는 동시에 페이징이나 슬라이싱을 적용하면 (유효한 페이지 수를 계산하는), 제한된 결과 내에서만 페이지를 처리한다.

> 결과 제한을 다이나믹 정렬 `Sort` 파라미터와 조합하면, 가장 작은 'K'개와 가장 큰 'K'개를 쿼리 메소드로 표현할 수 있다.

### 11.4.6. Repository Methods Returning Collections or Iterables

결과를 여러 개 리턴하는 쿼리 메소드엔 표준 자바 `Iterable`, `List`, `Set`을 사용할 수 있다. 그 밖에도 [Vavr](https://www.vavr.io/)이 지원하는 컬렉션 타입과, `Iterable`을 커스텀해 확장한 스프링 데이터의 `Streamable`도 지원한다. 지원하는 모든 [쿼리 메소드 리턴 타입](https://docs.spring.io/spring-data/r2dbc/docs/1.2.2/reference/html/#appendix.query.return.types)은 부록을 참고해라.

#### Using Streamable as Query Method Return Type

`Iterable`이나 다른 컬렉션 타입 대신, `Streamable`을 사용해도 된다. `Streamable`로는 쉽게 non-parallel `Stream`에 접근할 수 있고 (`Iterable`엔 없는 기능), 곧바로 `….filter(…)`, `….map(…)`을 사용할 수 있으며, 다른 `Streamable`과도 연결할 수 있다:

**Example 19. Using Streamable to combine query method results**

```java
interface PersonRepository extends Repository<Person, Long> {
  Streamable<Person> findByFirstnameContaining(String firstname);
  Streamable<Person> findByLastnameContaining(String lastname);
}

Streamable<Person> result = repository.findByFirstnameContaining("av")
  .and(repository.findByLastnameContaining("ea"));
```

#### Returning Custom Streamable Wrapper Types

쿼리가 요소를 여러 개 반환하면, 흔히 컬렉션 전용 래퍼 타입을 사용해 API를 만들곤 한다. 컬렉션 전용 래퍼 타입은 자주 쓰는 패턴이다. 보통은 컬렉션 등의 타입을 반환하는 레포지토리 메소드를 호출하고, 수동으로 래퍼 타입 인스턴스를 생성한다. 스프링 데이터는에선 다음 기준을 충족한다면 래퍼 타입을 쿼리 메소드 리턴 타입에 바로 사용할 수 있으므로, 수동으로 쿼리 결과를 래핑하지 않아도 된다:

1. `Streamable`을 구현한 타입.
2. `Streamable`을 인자로 받는 생성자나 스태틱 팩토리 메소드 `of(…)` 또는 `valueOf(…)`를 노출하는 타입.

아래 예제를 참고해라:

```java
class Product {                                         // (1)
  MonetaryAmount getPrice() { … }
}

@RequiredArgConstructor(staticName = "of")
class Products implements Streamable<Product> {         // (2)

  private Streamable<Product> streamable;

  public MonetaryAmount getTotal() {                    // (3)
    return streamable.stream()
      .map(Priced::getPrice)
      .reduce(Money.of(0), MonetaryAmount::add);
  }


  @Override
  public Iterator<Product> iterator() {                 // (4)
    return streamable.iterator();
  }
}

interface ProductRepository implements Repository<Product, Long> {
  Products findAllByDescriptionContaining(String text); // (5)
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 상품 가격에 접근할 수 있는 API를 노출하는 `Product` 엔티티.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> `Products.of(…)`(롬복 어노테이션으로 만들어진 팩토리 메소드)로 생성할 수 있는, `Streamable<Product>`의 래퍼 타입. `Streamable<Product>`를 받는 표준 생성자로도 만들 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 래퍼 타입은 `Streamable<Product>`에 있는 값들을 새로 계산하는 별도 API를 노출한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> `Streamable` 인터페이스를 구현해 실제 결과를 위임한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> 래퍼 타입 `Products`는 쿼리 메소드 리턴 타입에 바로 사용할 수 있다. 레포지토리 클라이언트에서 직접 `Streamable<Product>`를 받아 래핑하지 않아도 된다.</small>

#### Support for Vavr Collections

[Vavr](https://www.vavr.io/)은 자바의 함수형 프로그래밍 개념을 아우르는 라이브러리다. 이 라이브러리가 제공하는 커스텀 컬렉션 타입 셋도 쿼리 메소드 리턴 타입으로 사용할 수 있다. 커스텀 셋은 타임 테이블을 참고해라:

| Vavr collection type     | Used Vavr implementation type      | Valid Java source types |
| :----------------------- | :--------------------------------- | :---------------------- |
| `io.vavr.collection.Seq` | `io.vavr.collection.List`          | `java.util.Iterable`    |
| `io.vavr.collection.Set` | `io.vavr.collection.LinkedHashSet` | `java.util.Iterable`    |
| `io.vavr.collection.Map` | `io.vavr.collection.LinkedHashMap` | `java.util.Map`         |

첫 번째 열에 있는 타입(또는 하위 타입)을 쿼리 메소드 리턴 타입으로 사용할 수 있으며, 그러면 두 번째 열에 있는 구현 타입을 받게된다. 구현 타입은 실제 쿼리 결과의 자바 타입(세 번째 열)에 따라서 달라진다. 아니면 `Traversable`(Vavr 버전의 `Iterable`)을 선언하고, 실제 반환 값을 가지고 구현 클래스를 알아내도 된다. 즉, `java.util.List`는 Vavr `List`나 `Seq`로, `java.util.Set`은 Vavr `LinkedHashSet` `Set`이 되는 식이다.

### 11.4.7. Null Handling of Repository Methods

스프링 데이터 2.0부터, 개별 집계 인스턴스를 반환하는 레포지토리 CRUD 메소드는 자바 8의 `Optional`로 값이 없을 수도 있음을 표현한다. `Optional` 외에 다음 래퍼 타입도 쿼리 메소드 반환 타입으로 지원한다:

- `com.google.common.base.Optional`
- `scala.Option`
- `io.vavr.control.Option`

쿼리 메소드에서 아예 래퍼 타입을 빼도 된다. 이럴 땐 `null`을 리턴하면 쿼리 결과가 없다는 뜻이다. 컬렉션이나 래퍼, 스트림 등을 리턴하는 레포지토리 메소드는 `null`을 리턴하지 않음을 보장하며, 대신 비어 있음을 뜻하는 적절한 인스턴스를 반환한다. 자세한 정보는 [레포지토리 쿼리 리턴 타입](https://docs.spring.io/spring-data/r2dbc/docs/1.2.2/reference/html/#repository-query-return-types)을 참고해라.

#### Nullability Annotations

레포지토리 메소드는 [스프링 프레임워크의 nullability 어노테이션](https://docs.spring.io/spring/docs/5.3.2/spring-framework-reference/core.html#null-safety)으로도 null 가능 여부를 표현할 수 있다. nullability 어노테이션은 사용하기도 편하며, 다음과 같은 런타임 `null` 검사를 지원한다:

- [`@NonNullApi`](https://docs.spring.io/spring/docs/5.3.2/javadoc-api/org/springframework/lang/NonNullApi.html): 파라미터나 반환 값은 디폴트로 `null`이 될 수 없음을 패키지 레벨에 선언.
- [`@NonNull`](https://docs.spring.io/spring/docs/5.3.2/javadoc-api/org/springframework/lang/NonNull.html): 파라미터나 반환 값이 `null`일 수 없을 때 선언 (`@NonNullApi`를 적용했다면 사용할 필요 없음).
- [`@Nullable`](https://docs.spring.io/spring/docs/5.3.2/javadoc-api/org/springframework/lang/Nullable.html): 파라미터나 반환 값이 `null`일 수 있을 때.

스프링 어노테이션엔 [JSR 305](https://jcp.org/en/jsr/detail?id=305) 어노테이션(추가 개발은 진행하지 않지만 많이들 사용하는)이 선언돼 있다. JSR 305 메타 어노테이션 덕분에 툴 벤더([IDEA](https://www.jetbrains.com/help/idea/nullable-and-notnull-annotations.html), [Eclipse](https://help.eclipse.org/oxygen/index.jsp?topic=/org.eclipse.jdt.doc.user/tasks/task-using_external_null_annotations.htm), [Kotlin](https://kotlinlang.org/docs/reference/java-interop.html#null-safety-and-platform-types)같은)는 스프링 어노테이션 전용 하드 코딩 없이, 일반적인 방식으로 null safety를 지원할 수 있다. 런타임에 모든 쿼리 메소드의 nullability 제약 조건을 체크하도록 만들려면, 다음 예제처럼 `package-info.java`에 스프링의 `@NonNullApi`를 선언해 패키지 레벨에서 non-nullability를 활성화해야 한다:

**Example 20. Declaring Non-nullability in `package-info.java`**

```java
@org.springframework.lang.NonNullApi
package com.acme;
```

디폴트로 non-null을 지정하면, 레포지토리 쿼리 메소드를 호출할 때마다 런타임에 null 허용 조건에 대한 유효성을 검사한다. 쿼리 결과가 정의한 제약 조건을 위반하면 예외가 발생한다. non-nullable(레포지토리가 있는 패키지에 정의한 어노테이션의 디폴트 값)로 선언한 메소드가 `null`을 반환했을 때에 해당한다. null이 될 수 있는 결과를 따로 지정하려면 원하는 메소드에 별도로 `@Nullable`을 선언해라. 앞에서 언급했던 결과 래퍼 타입을 사용하면, 예상했겠지만, 결과가 없으면 비어 있음을 나타내는 값으로 변환한다.

다음은 지금까지 설명했던 기법들을 종합한 예제다:

**Example 21. Using different nullability constraints**

```java
package com.acme;                                                       // (1)

import org.springframework.lang.Nullable;

interface UserRepository extends Repository<User, Long> {

  User getByEmailAddress(EmailAddress emailAddress);                    // (2)

  @Nullable
  User findByEmailAddress(@Nullable EmailAddress emailAdress);          // (3)

  Optional<User> findOptionalByEmailAddress(EmailAddress emailAddress); // (4)
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 이 레포지토리는 non-null로 정의했던 패키지(또는 하위 패키지)에 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 쿼리 결과가 없으면 `EmptyResultDataAccessException`을 던진다. 메소드로 전달한 `emailAddress`가 `null`이면 `IllegalArgumentException`을 던진다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 쿼리 결과가 없으면 `null`을 리턴한다. `emailAddress`는 `null`을 허용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> 쿼리 결과가 없으면 `Optional.empty()`를 리턴한다. 메소드로 전달한 `emailAddress`가 `null`이면 `IllegalArgumentException`을 던진다.</small>

#### Nullability in Kotlin-based Repositories

코틀린은 언어 자체에 [nullability 제약 조건](https://kotlinlang.org/docs/reference/null-safety.html) 정의할 수 있다. 코틀린 코드를 바이트 코드로 컴파일하면, 메소드 시그니처대신 컴파일된 메타데이터로 null 허용 여부를 표현한다. 코틀린의 nullability 제약 조건을 검사하려면 프로젝트에 `kotlin-reflect` JAR를 추가해야 한다. 스프링 데이터 레포지토리는 언어 메커니즘을 활용해 다음처럼 제약 조건을 정의하고, 동일하게 런타임에 유효성을 검사한다:

**Example 22. Using nullability constraints on Kotlin repositories**

```kotlin
interface UserRepository : Repository<User, String> {

  fun findByUsername(username: String): User     // (1)

  fun findByFirstname(firstname: String?): User? // (2)
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 이 메소드는 파라미터와 결과 모두 null이 될 수 없는 값으로 정의한다 (코틀린 디폴트). 코틀린 컴파일러가 메소드에 `null`을 넘길 수 없도록 막는다. 쿼리 결과가 없으면 `EmptyResultDataAccessException`을 던진다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 이 메소드는 `firstname` 파라미터에 `null` 값을 허용하고, 쿼리 결과가 없으면 `null`을 리턴한다.</small>

### 11.4.8. Streaming Query Results

리턴 타입에 자바 8 `Stream<T>`을 사용하면 쿼리 메소드 결과를 점진적으로 처리할 수 있다. 쿼리 결과를 직접 `Stream`으로 감싸는 대신, 아래 예제처럼 저장소 전용 메소드로도 스트리밍 처리가 가능하다:

**Example 23. Stream the result of a query with Java 8 `Stream<T>`**

```java
@Query("select u from User u")
Stream<User> findAllByCustomQueryAndStream();

Stream<User> readAllByFirstnameNotNull();

@Query("select u from User u")
Stream<User> streamAllPaged(Pageable pageable);
```

> `Stream`은 본래 저장소 전용 리소스를 래핑한 것이기 때문에, 반드시 사용 후 닫아줘야 한다. `close()` 메소드로 직접 `Stream`을 닫거나, 아래 예제처럼 자바 7 `try-with-resources` 블록을 사용하면 된다:

**Example 24. Working with a `Stream<T>` result in a `try-with-resources` block**

```java
try (Stream<User> stream = repository.findAllByCustomQueryAndStream()) {
  stream.forEach(…);
}
```

> 현재는 모든 스프링 데이터 모듈이 리턴 타입에 `Stream<T>`을 지원하진 않는다.

### 11.4.9. Asynchronous Query Results

[스프링의 비동기 메소드 실행 기능](https://docs.spring.io/spring-framework/docs/5.3.2/reference/html/integration.html#scheduling)을 이용하면 레포지토리 쿼리를 비동기로 실행할 수 있다. 비동기 메소드는 즉시 반환되고, 실제 쿼리는 스프링 `TaskExecutor`로 제출한 태스크가 실행한다. 비동기 쿼리는 리액티브 쿼리와는 다르며 혼용하면 안 된다. 리액티브 지원에 관한 자세한 내용은 저장소 문서를 참고해라. 다음 예제는 다양한 비동기 쿼리를 보여준다:

```java
@Async
Future<User> findByFirstname(String firstname);               // (1)

@Async
CompletableFuture<User> findOneByFirstname(String firstname); // (2)

@Async
ListenableFuture<User> findOneByLastname(String lastname);    // (3)
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">java.util.concurrent.Future</span>를 리턴 타입으로 사용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 자바 8 <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">java.util.concurrent.CompletableFuture</span>를 리턴 타입으로 사용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;"> org.springframework.util.concurrent.ListenableFuture</span>를 리턴 타입으로 사용한다.</small>

---

## 11.5. Creating Repository Instances

이번 섹션에선 지금까지 정의한 레포지토리 인터페이스로 인스턴스를 만들고, 빈을 정의하는 방법에 대해 다룬다. 레포지토리 메커니즘을 지원하는 각 스프링 데이터 모듈이 제공하는 스프링 네임스페이스를 사용할 수도 있지만, 그래도 보통은 자바 설정을 추천한다.

### 11.5.1. XML Configuration

각 스프링 데이터 모듈에 `repositories` 요소를 추가하면 스프링이 스캔할 베이스 패키지를 지정할 수 있다:

**Example 25. Enabling Spring Data repositories via XML**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans:beans xmlns:beans="http://www.springframework.org/schema/beans"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns="http://www.springframework.org/schema/data/jpa"
  xsi:schemaLocation="http://www.springframework.org/schema/beans
    https://www.springframework.org/schema/beans/spring-beans.xsd
    http://www.springframework.org/schema/data/jpa
    https://www.springframework.org/schema/data/jpa/spring-jpa.xsd">

  <repositories base-package="com.acme.repositories" />

</beans:beans>
```

위 예제에선 스프링이 `com.acme.repositories`와 모든 하위 패키지를 스캔해 `Repository`나 하위 인터페이스를 확장한 인터페이스를 찾는다. 인터페이스를 찾을 때마다 persistence 기술 전용 `FactoryBean`을 등록해 쿼리 메소드를 처리할 적당한 프록시를 만든다. 빈 이름은 인터페이스 이름에 따라 등록하므로, `UserRepository` 인터페이스는 `userRepository`로 등록된다. 중첩 레포지토리 인터페이스는 둘러싸고 있는 타입명을 프리픽스로 사용한다. `base-package` 속성은 와일드카드를 허용하므로 스캔할 패키지 패턴을 정의해도 된다.

#### Using Filters

기본적으로 `Repository` 하위 인터페이스를 확장한, 설정한 베이스 패키지 아래 있는 모든 인터페이스로 빈 인스턴스를 생성한다. 반면 어떤 인터페이스로 빈 인스턴스를 만들지 직접 세세하게 제어하고 싶을 수 있다. 이럴 땐 `<repositories />` 요소 안에 `<include-filter />`와 `<exclude-filter />` 요소를 사용하면 된다. 이 요소가 의미하는 바는 스프링 컨텍스트 네임스페이스 요소와 완전히 동일하다. 자세한 내용은 [스프링 레퍼런스 문서](https://docs.spring.io/spring-framework/docs/5.3.2/reference/html/core.html#beans-scanning-filters)를 참고해라.

예를 들어 레포지토리 빈 인스턴스에서 제외할 인터페이스는 아래와 같이 설정한다:

**Example 26. Using exclude-filter element**

```xml
<repositories base-package="com.acme.repositories">
  <context:exclude-filter type="regex" expression=".*SomeRepository" />
</repositories>
```

위 예제는 `SomeRepository`로 끝나는 모든 인터페이스를 인스턴스로 만들지 않는다.

### 11.5.2. Java Configuration

자바 설정 클래스에 저장소별 `@Enable${store}Repositories` 어노테이션을 사용해도 레포지토리 인프라를 트리거할 수 있다. 스프링 컨테이너의 자바 기반 설정은 [스프링 레퍼런스 문서 자바 설정 섹션](https://docs.spring.io/spring-framework/docs/5.3.2/reference/html/core.html#beans-java)에서 소개하고 있다.

스프링 데이터 레포지토리는 아래와 유사한 방식으로 활성화한다:

**Example 27. Sample annotation-based repository configuration**

```java
@Configuration
@EnableJpaRepositories("com.acme.repositories")
class ApplicationConfiguration {

  @Bean
  EntityManagerFactory entityManagerFactory() {
    // …
  }
}
```

> 위 예제에선 JPA 전용 어노테이션을 사용하는데, 실제로 사용하는 저장소 모듈에 맞게 바꿔 사용하면 된다. `EntityManagerFactory` 빈 정의도 마찬가지다. 저장소별 설정을 다루는 섹션을 참고해라.

### 11.5.3. Standalone Usage

레포지토리 인프라를 꼭 스프링 컨테이너 안에서만 사용해야 하는 건 아니다 — 예를 들어 CDI 환경에서도 가능하다. 클래스패스에 일부 스프링 라이브러리가 있어야 하긴 하지만, 일반적으로는 프로그래밍 방식으로 레포지토리를 세팅할 수 있다. 레포지토리를 지원하는 스프링 데이터 모듈은 persistence 기술 전용 `RepositoryFactory`도 제공하므로, 아래 예제처럼 활용하면 된다:

**Example 28. Standalone usage of the repository factory**

```java
RepositoryFactorySupport factory = … // Instantiate factory here
UserRepository repository = factory.getRepository(UserRepository.class);
```

---

## 11.6. Custom Implementations for Spring Data Repositories

이번 섹션에선 레포지토리 커스텀을 다루며, 어떻게 여러 인터페이스 조각을 모아 하나의 레포지토리를 구성하는지를 설명한다.

쿼리 메소드에서 다른 동작을 실행해야 하거나 파생 쿼리로는 구현할 수 없는 동작이 있다면, 커스텀 구현체가 필요하다. 스프링 데이터 레포지토리는 커스텀 레포지토리 코드를, 일반 CRUD 추상화와 쿼리 메소드 기능과 통합해준다.

### 11.6.1. Customizing Individual Repositories

레포지토리에 커스텀 기능을 추가하려면, 우선 인터페이스 조각을 정의하고 커스텀 기능을 구현해야 한다:

**Example 29. Interface for custom repository functionality**

```java
interface CustomizedUserRepository {
  void someCustomMethod(User user);
}
```

**Example 30. Implementation of custom repository functionality**

```java
class CustomizedUserRepositoryImpl implements CustomizedUserRepository {

  public void someCustomMethod(User user) {
    // Your custom implementation
  }
}
```

> 여기 인터페이스 조각을 구현한 클래스 이름에선 `Impl` 접미사가 가장 중요하다.

이 구현체 자체는 스프링 데이터에 의존성이 없으며, 정식 스프링 빈이 될 수 있다. 따라서 표준 의존성 주입을 이용해 다른 빈(`JdbcTemplate` 등)에 참조를 주입할 수 있고, aspect에도 참여할 수 있다.

이제 다음과 같이 레포지토리 인터페이스가 이 조각 인터페이스를 상속하도록 만들 수 있다:

**Example 31. Changes to your repository interface**

```java
interface UserRepository extends CrudRepository<User, Long>, CustomizedUserRepository {

  // Declare query methods here
}
```

인터페이스 조각과 레포지토리 인터페이스를 함께 상속했기 때문에 클라이언트는 CRUD와 커스텀 기능을 모두 사용할 수 있다.

각 인터페이스 조각들이 스프링 데이터 레포지토리를 구현해 하나의 레포지토리를 구성한다. 여기서 인터페이스 조각은 베이스 레포지토리, 함수형 aspect([QueryDsl](#1181-querydsl-extension) 등), 구현체를 가진 커스텀 인터페이스를 뜻한다. 레포지토리 인터페이스에 새 인터페이스를 추가할 때마다, 최종 레포지토리 구성에 조각을 추가해 확장하는 거다. 베이스 레포지토리 구현체와 레포지토리 aspect 구현체는 각 스프링 데이터 모듈이 제공한다.

다음은 커스텀 인터페이스와 그에 따른 구현체 예시다:

**Example 32. Fragments with their implementations**

```java
interface HumanRepository {
  void someHumanMethod(User user);
}

class HumanRepositoryImpl implements HumanRepository {

  public void someHumanMethod(User user) {
    // Your custom implementation
  }
}

interface ContactRepository {

  void someContactMethod(User user);

  User anotherContactMethod(User user);
}

class ContactRepositoryImpl implements ContactRepository {

  public void someContactMethod(User user) {
    // Your custom implementation
  }

  public User anotherContactMethod(User user) {
    // Your custom implementation
  }
}
```

다음은 `CrudRepository`를 확장한 커스텀 레포지토리 인터페이스 예시다:

**Example 33. Changes to your repository interface**

```java
interface UserRepository extends CrudRepository<User, Long>, HumanRepository, ContactRepository {

  // Declare query methods here
}
```

레포지토리는 둘 이상의 커스텀 구현체로 구성할 수 있으며, 커스텀 구현체는 선언한 순서대로 이입된다. 커스텀 구현체는 베이스 구현체와 레포지토리 aspect보다 우선순위가 높다. 이 순서 덕분에 베이스 레포지토리와 aspect 메소드를 재정의할 수 있으며, 두 커스텀 인터페이스가 같은 메소드 시그니처를 사용해도 충돌하지 않는다. 커스텀 레포지토리 조각을 레포지토리 인터페이스 하나에서만 사용해야 한다는 제한은 없다. 같은 인터페이스 조각을 여러 레포지토리에 사용할 수 있으므로, 다른 레포지토리에서 커스텀 기능을 재사용할 수 있다.

다음은 커스텀 레포지토리 조각과 구현체 예시다:

**Example 34. Fragments overriding `save(…)`**

```java
interface CustomizedSave<T> {
  <S extends T> S save(S entity);
}

class CustomizedSaveImpl<T> implements CustomizedSave<T> {

  public <S extends T> S save(S entity) {
    // Your custom implementation
  }
}
```

다음은 위 커스텀 조각을 사용하는 레포지토리다:

**Example 35. Customized repository interfaces**

```java
interface UserRepository extends CrudRepository<User, Long>, CustomizedSave<User> {
}

interface PersonRepository extends CrudRepository<Person, Long>, CustomizedSave<Person> {
}
```

#### Configuration

네임스페이스 설정을 사용한다면, 레포지토리를 발견한 패키지 아래에 있는 클래스를 스캔해 커스텀 구현체 조각을 자동으로 감지한다. 클래스는 네이밍 컨벤션이 있는데, 인터페이스 조각 이름 뒤에 네임스페이스 요소의 `repository-impl-postfix` 속성 값을 붙인 이름을 사용해야 한다. 디폴트 접미사는 `Impl`이다. 다음은 디폴트 접미사를 사용한 레포지토리와, 커스텀 접미사를 사용하는 레포지토리 예시다:

**Example 36. Configuration example**

```xml
<repositories base-package="com.acme.repository" />

<repositories base-package="com.acme.repository" repository-impl-postfix="MyPostfix" />
```

첫 번째 설정은 커스텀 레포지토리 구현체로 <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">com.acme.repository.CustomizedUserRepositoryImpl</span>이란 클래스를 찾는다. 두 번째 예시는 <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">com.acme.repository.CustomizedUserRepositoryMyPostfix</span>를 찾는다.

<span id="repositories.single-repository-behaviour.ambiguity"></span>

##### Resolution of Ambiguity

위 조건에 해당하는 클래스 명을 사용하는 구현체가 다른 패키지에서 동시에 발견된다면, 스프링 데이터는 빈 이름으로 사용할 구현체를 식별한다.

앞에서 보여준 `CustomizedUserRepository`를 구현한 커스텀 구현체가 아래와 같이 두 개 있다면, 첫 번째 구현체를 사용한다. 이 구현체의 빈 이름은 인터페이스 조각(`CustomizedUserRepository`)에 `Impl` 접미사를 더한 `customizedUserRepositoryImpl`이다.

**Example 37. Resolution of ambiguous implementations**

```java
package com.acme.impl.one;

class CustomizedUserRepositoryImpl implements CustomizedUserRepository {

  // Your custom implementation
}
```
```java
package com.acme.impl.two;

@Component("specialCustomImpl")
class CustomizedUserRepositoryImpl implements CustomizedUserRepository {

  // Your custom implementation
}
```

`UserRepository` 인터페이스에 `@Component("specialCustom")` 어노테이션을 달면, 이제 빈 이름에 `Impl`을 더해주면 `com.acme.impl.two`에 있는 레포지토리 구현체와 일치하므로, 첫 번째 구현체 대신 이 구현체를 사용한다.

<span id="repositories.manual-wiring"></span>
##### Manual Wiring

커스텀 구현체가 어노테이션 기반 설정과 자동 주입만 사용하고 있다면, 다른 스프링 빈과 동일하게 처리하기 때문에 위에서 처럼 접근하면 문제 없이 동작한다. 구현체 조각에 특별한 빈을 연결해야 한다면, [앞 섹션](#repositories.single-repository-behaviour.ambiguity)에서 설명한 컨벤션에 따라 빈을 선언하고 이름을 지어주면 된다. 그러면 인프라에선 직접 빈을 만드는 대신, 이름을 통해 수동으로 정의한 빈을 참조한다. 다음 예시는 수동으로 커스텀 구현체를 연결하는 방법을 보여준다:

**Example 38. Manual wiring of custom implementations**

```xml
<repositories base-package="com.acme.repository" />

<beans:bean id="userRepositoryImpl" class="…">
  <!-- further configuration -->
</beans:bean>
```

### 11.6.2. Customize the Base Repository

[이전 섹션](#repositories.manual-wiring)에서 설명한 방법대로면, 베이스 레포지토리를 커스텀해 모든 레포지토리 동작을 바꾸려면 레포지토리 인터페이스를 일일이 커스텀해야 했다. 번거롭게 인터페이스를 전부 커스텀하지 않고도, persistence 기술 전용 레포지토리에 있는 베이스 클래스를 확장한 구현체를 만드는 방법도 있다. 이 커스텀 클래스는 레포지토리 프록시의 베이스 클래스로 활용된다:

**Example 39. Custom repository base class**

```java
class MyRepositoryImpl<T, ID>
  extends SimpleJpaRepository<T, ID> {

  private final EntityManager entityManager;

  MyRepositoryImpl(JpaEntityInformation entityInformation,
                          EntityManager entityManager) {
    super(entityInformation, entityManager);

    // Keep the EntityManager around to used from the newly introduced methods.
    this.entityManager = entityManager;
  }

  @Transactional
  public <S extends T> S save(S entity) {
    // implementation goes here
  }
}
```

> 이 클래스엔 저장소 전용 레포지토리 팩토리 구현체가 사용할 상위 클래스의 생성자가 있어야 한다. 레포지토리 베이스 클래스에 생성자가 여러 개라면, `EntityInformation`과 저장소 전용 인프라 객체(`EntityManager`나 템플릿 클래스같은)를 사용하는 생성자를 재정의해라.

마지막으로 스프링 데이터 인프라에도 커스텀한 레포지토리 베이스 클래스를 알려줘야 한다. 자바 설정에선 다음 예제처럼 `@Enable${store}Repositories` 어노테이션의 `repositoryBaseClass` 속성을 사용한다:

**Example 40. Configuring a custom repository base class using JavaConfig**

```java
@Configuration
@EnableJpaRepositories(repositoryBaseClass = MyRepositoryImpl.class)
class ApplicationConfiguration { … }
```

XML 네임스페이스에도 동일한 속성이 있다:

**Example 41. Configuring a custom repository base class using XML**

```xml
<repositories base-package="com.acme.repository"
     base-class="….MyRepositoryImpl" />
```

---

## 11.7. Publishing Events from Aggregate Roots

레포지토리가 관리하는 엔티티들은 aggregate root다. 도메인 주도 설계 어플리케이션에서 보통 aggregate root는 도메인 이벤트를 발생시킨다. 스프링 데이터는 `@DomainEvents` 어노테이션을 제공하므로, 다음 예제처럼 aggregate root에 있는 메소드에 사용하면 쉽게 이벤트를 발생시킬 수 있다:

**Example 42. Exposing domain events from an aggregate root**

```java
class AnAggregateRoot {

    @DomainEvents // (1)
    Collection<Object> domainEvents() {
        // … return events you want to get published here
    }

    @AfterDomainEventPublication // (2) 
    void callbackMethod() {
       // … potentially clean up domain events list
    }
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `@DomainEvents`를 사용하는 메소드는 단일 이벤트 인스턴스 또는 이벤트 컬렉션을 리턴할 수 있다. 메소드 인자는 받지 않아야 한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 모든 이벤트를 발행하고 난 뒤엔 `@AfterDomainEventPublication` 어노테이션을 활용한다. 발행한 이벤트 리스트를 정리하는 등에 활용할 수 있다.</small>

어노테이션을 선언한 메소드는 스프링 데이터 레포지토리의 `save(…)`, `saveAll(…)`, `delete(…)`, `deleteAll(…)` 메소드를 실행할 때마다 호출된다.

---

## 11.8. Spring Data Extensions

이번 섹션에선 스프링 데이터를 다른 컨텍스트에서도 사용할 수 있게 해주는 여러 가지 스프링 데이터 익스텐션을 설명한다. 현재는 스프링 MVC와의 통합을 주로 사용한다.

### 11.8.1. Querydsl Extension

[Querydsl](http://www.querydsl.com/)은 정적으로 타입을 지정하는 SQL과 유사한 쿼리를 만들 수 있는 API를 제공하는 프레임워크다.

다양한 스프링 데이터 모듈이 아래 `QuerydslPredicateExecutor`를 통한 Querydsl 통합을 지원하고 있다:

**Example 43. QuerydslPredicateExecutor interface**

```java
public interface QuerydslPredicateExecutor<T> {

  Optional<T> findById(Predicate predicate);  // (1)

  Iterable<T> findAll(Predicate predicate);   // (2)

  long count(Predicate predicate);            // (3)

  boolean exists(Predicate predicate);        // (4)

  // … more functionality omitted.
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `Predicate` 조건에 맞는 단일 엔티티를 찾아 리턴한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> `Predicate` 조건에 맞는 모든 엔티티를 찾아 리턴한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> `Predicate` 조건에 맞는 엔티티 수를 반환한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> `Predicate` 조건에 맞는 엔티티 존재 여부를 반환한다.</small>

Querydsl을 사용하려면 다음 예제처럼 레포지토리 인터페이스가 `QuerydslPredicateExecutor`를 상속하도록 만들어라:

**Example 44. Querydsl integration on repositories**

```java
interface UserRepository extends CrudRepository<User, Long>, QuerydslPredicateExecutor<User> {
}
```

이렇게 하면 아래 예제처럼 Querydsl `Predicate` 인스턴스를 사용해 type-safe한 쿼리를 작성할 수 있다:

```java
Predicate predicate = user.firstname.equalsIgnoreCase("dave")
  .and(user.lastname.startsWithIgnoreCase("mathews"));

userRepository.findAll(predicate);
```

### 11.8.2. Web support

> 이 섹션은 스프링 데이터 Commons 현재 버전이 지원하는 스프링 데이터 웹 기능을 설명한다. 새로 도입한 기능으로 많은 것들이 변경됨에 따라 구버전 동작에 대한 문서는 [[web.legacy]](https://docs.spring.io/spring-data/commons/docs/2.0.6.RELEASE/reference/html/#web.legacy)에 남겨놨다.

레포지토리 프로그래밍 모델을 지원하는 스프링 데이터 모듈들은 다양한 웹 기능을 함께 제공한다. 웹 관련 컴포넌트를 사용하려면 클래스패스에 스프링 MVC JAR가 필요하다.  [스프링 HATEOAS](https://github.com/spring-projects/spring-hateoas) 통합을 지원하는 모듈도 있다. 자바 설정을 사용할 땐, 보통 아래 예제처럼 설정 클래스에 `@EnableSpringDataWebSupport` 어노테이션을 선언해 통합 지원을 활성화한다.

**Example 45. Enabling Spring Data web support**

```java
@Configuration
@EnableWebMvc
@EnableSpringDataWebSupport
class WebConfiguration {}
```

`@EnableSpringDataWebSupport` 어노테이션을 선언하면 몇 가지 컴포넌트가 등록된다. 이 컴포넌트들은 뒤에서 설명하겠다. 클래스패스의 스프링 HATEOAS도 감지하며 통합 컴포넌트도 함께 등록된다 (있으면).

XML 설정을 사용한다면, 다음 예제처럼 `SpringDataWebConfiguration`이나 `HateoasAwareSpringDataWebConfiguration`을 스프링 빈으로 등록해라:

**Example 46. Enabling Spring Data web support in XML**

```xml
<bean class="org.springframework.data.web.config.SpringDataWebConfiguration" />

<!-- If you use Spring HATEOAS, register this one *instead* of the former -->
<bean class="org.springframework.data.web.config.HateoasAwareSpringDataWebConfiguration" />
```

#### Basic Web Support

[위에서 본](#1182-web-support) 설정은 몇 가지 컴포넌트를 등록한다:

- [`DomainClassConverter` 클래스](#using-the-domainclassconverter-class)는 스프링 MVC가 요청 파라미터나 path variable을 레포지토리가 관리하는 도메인 클래스 인스턴스로 리졸브할 수 있게 해준다.
- [`HandlerMethodArgumentResolver`](#handlermethodargumentresolvers-for-pageable-and-sort) 구현체는 스프링 MVC가 요청 파라미터를 `Pageable`과 `Sort` 인스턴스로 리졸브할 수 있게 해준다.

##### Using the `DomainClassConverter` Class

`DomainClassConverter` 클래스를 사용하면 도메인 타입을 스프링 MVC 컨트롤러 메소드 시그니처에 바로 사용할 수 있기 때문에, 레포지토리에서 직접 인스턴스를 찾지 않아도 된다. 다음 예제를 참고해라:

**Example 47. A Spring MVC controller using domain types in method signatures**

```java
@Controller
@RequestMapping("/users")
class UserController {

  @RequestMapping("/{id}")
  String showUserForm(@PathVariable("id") User user, Model model) {

    model.addAttribute("user", user);
    return "userForm";
  }
}
```

이 메소드에선 `User` 인스턴스를 직접 받으므로 별도로 인스턴스를 검색할 필요가 없다. 스프링 MVC가 path variable을 도메인 클래스의 `id` 타입으로 변환한 뒤, 도메인 타입을 등록한 레포지토리 인스턴스에서 `findById(…)`를 호출해 인스턴스를 리졸브한다.

> 이 기능은 현재로서는 `CrudRepository`를 구현한 레포지토리만 지원한다.

##### HandlerMethodArgumentResolvers for Pageable and Sort

[앞에서 보여준](#using-the-domainclassconverter-class) 설정은 `PageableHandlerMethodArgumentResolver`와 `SortHandlerMethodArgumentResolver` 인스턴스도 함께 등록한다. 덕분에 컨트롤러 메소드 인자에 `Pageable`과 `Sort`도 사용할 수 있다. 다음 예제를 참고해라:

**Example 48. Using Pageable as a controller method argument**

```java
@Controller
@RequestMapping("/users")
class UserController {

  private final UserRepository repository;

  UserController(UserRepository repository) {
    this.repository = repository;
  }

  @RequestMapping
  String showUsers(Model model, Pageable pageable) {

    model.addAttribute("users", repository.findAll(pageable));
    return "users";
  }
}
```

위 메소드 시그니처를 사용하면 스프링 MVC는 다음과 같은 설정을 통해 요청 파라미터로 `Pageable` 인스턴스를 만든다:

**Table 1. Request parameters evaluated for Pageable instances**

| `page` | 조회할 페이지. 0부터 시작하며, 디폴트도 0이다.      |
| `size` | 조회하고 싶은 페이지 크기. 디폴트는 20이다.       |
| `sort` | 정렬할 프로퍼티들로, `property,property(,ASC|DESC)(,IgnoreCase)` 형식을 사용한다. 디폴트 정렬 방향은 오름차순이며, 대소문자를 구분한다. 프로퍼티별로 방향이나 대소문자 구분 여부를 다르게 지정하고 싶다면 `sort` 파라미터를 여러 개 사용해라.<br> — 예를 들어 <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">?sort=firstname&sort=lastname,asc&sort=city,ignorecase.</span> |

이 설정을 커스텀하려면 `PageableHandlerMethodArgumentResolverCustomizer`나 `SortHandlerMethodArgumentResolverCustomizer` 인스턴스를 구현한 빈을 등록해라. `customize()` 메소드 호출을 통해 설정을 바꿀 수 있다:

```java
@Bean SortHandlerMethodArgumentResolverCustomizer sortCustomizer() {
    return s -> s.setPropertyDelimiter("<-->");
}
```

기존 `MethodArgumentResolver` 프로퍼티를 바꾸는 걸로 충분하지 않다면, `SpringDataWebConfiguration`이나 HATEOAS 활성화에 해당하는 설정 클래스를 상속해 `pageableResolver()`, `sortResolver()` 메소드를 재정의하고, `@Enable` 어노테이션 대신 커스텀 설정 파일을 임포트해라.

단일 요청으로 `Pageable`이나 `Sort` 인스턴스를 여러 개 리졸브해야 한다면, 스프링의 `@Qualifier` 어노테이션으로 구분해줄 수 있다. 이렇게 하면 요청 파라미터에 `${qualifier}_`란 프리픽스가 달린다. 다음은 그에 따른 메소드 시그니처다:

```java
String showUsers(Model model,
      @Qualifier("thing1") Pageable first,
      @Qualifier("thing2") Pageable second) { … }
```

이제 `thing1_page`, `thing2_page` 등의 파라미터를 사용하면 된다.

메소드에 전달하는 `Pageable` 디폴트 값은 `PageRequest.of(0, 20)`인데, `Pageable` 파라미터에 `@PageableDefault` 어노테이션을 달면 커스텀할 수 있다.

#### Hypermedia Support for Pageables

스프링 HATEOAS는 `Page` 인스턴스에 필요한 `Page` 메타데이터와, 클라이언트가 쉽게 페이지를 탐색할 수 있게 링크를 추가해주는 representation 모델 클래스(`PagedResources`)를 제공한다. `Page`를 `PagedResources`로 변환해주는 일은 스프링 HATEOAS `ResourceAssembler` 인터페이스 구현체 `PagedResourcesAssembler`가 담당한다. 다음 예제는 `PagedResourcesAssembler`를 컨트롤러 메소드 인자에 사용하는 방법을 보여준다:

**Example 49. Using a PagedResourcesAssembler as controller method argument**

```java
@Controller
class PersonController {

  @Autowired PersonRepository repository;

  @RequestMapping(value = "/persons", method = RequestMethod.GET)
  HttpEntity<PagedResources<Person>> persons(Pageable pageable,
    PagedResourcesAssembler assembler) {

    Page<Person> persons = repository.findAll(pageable);
    return new ResponseEntity<>(assembler.toResources(persons), HttpStatus.OK);
  }
}
```

위에 있는 설정을 활성화했다면 `PagedResourcesAssembler`를 컨트롤러 메소드 인자에 사용할 수 있다. `toResources(…)`를 호출하면 `PagedResourcesAssembler`는 다음과 같은 처리를 한다:

- `Page`가 담고 있던 정보를 `PagedResources` 인스턴스에 채운다.
- `PagedResources` 객체엔 `PageMetadata` 인스턴스가 있으며, `Page`와 `PageRequest`에 대한 정보로 채워진다.
- 페이지 상태에 따라 `PagedResources`에 `prev`, `next` 링크를 추가한다. 이 링크는 메소드에 매핑된 URI를 가리킨다. 링크에 추가할 페이징 관련 파라미터는, `PageableHandlerMethodArgumentResolver` 설정을 사용해 나중에 리졸브한다.

데이터베이스에 `Person` 인스턴스가 30개 저장돼 있다고 가정해보자. 이제 요청을 보내면 (`GET http://localhost:8080/persons`) 다음과 유사한 응답을 받을 거다:

```json
{ "links" : [ { "rel" : "next",
                "href" : "http://localhost:8080/persons?page=1&size=20" }
  ],
  "content" : [
     … // 20 Person instances rendered here
  ],
  "pageMetadata" : {
    "size" : 20,
    "totalElements" : 30,
    "totalPages" : 2,
    "number" : 0
  }
}
```

assembler는 정확한 URI를 만들었고, 다음 요청에 사용할 파라미터도 이어지는 `Pageable`로 리졸브하기 위해 디폴트 설정을 사용했다. 다시 말해, 해당 설정을 변경하면 링크에도 자동으로 반영된다. 기본적으로 assembler는 실행한 컨트롤러 메소드를 가리키지만, `PagedResourcesAssembler.toResource(…)`의 오버로드 메소드에 링크를 빌드할 기본 커스텀 `Link`를 전달해 변경할 수 있다.

#### Web Databinding Support

스프링 데이터 프로젝션([Projections 섹션](../r2dbcrepositories#1426-projections)에서 설명)을 사용하면, 다음 예제처럼 요청 페이로드를 [JSONPath](https://goessner.net/articles/JsonPath/) 표현식([Jayway JsonPath](https://github.com/json-path/JsonPath) 필요)이나 [XPath](https://www.w3.org/TR/xpath-31/) 표현식([XmlBeam](https://xmlbeam.org/) 필요)으로 바인딩할 수 있다.

**Example 50. HTTP payload binding using JSONPath or XPath expressions**

```java
@ProjectedPayload
public interface UserPayload {

  @XBRead("//firstname")
  @JsonPath("$..firstname")
  String getFirstname();

  @XBRead("/lastname")
  @JsonPath({ "$.lastname", "$.user.lastname" })
  String getLastname();
}
```

이 타입은 스프링 MVC 핸들러 메소드 인자로 사용하거나, `RestTemplate` 메소드에서 `ParameterizedTypeReference`와 함께 사용할 수 있다. 이 메소드 선언대로면 도큐먼트 전체에서 `firstname`을 찾는다. XML은 `lastname`을 문서 최상위 레벨에서 조회한다. JSON도 최상위에서 `lastname`을 먼저 찾아보지만, 못 찾으면 하위 도큐먼트 `user`가 감싸고 있는 `lastname`을 찾는다. 이렇게하면 클라이언트가 노출된 메소드를 호출하지 않아도 (일반적인 클래스 기반 페이로드 바인딩의 단점) 쉽게 도큐먼트 구조 변경에 대응할 수 있다.

[Projections](../r2dbcrepositories#1426-projections)에서도 설명하지만, 중첩 프로젝션(Nested projection)도 지원한다. 메소드가 인터페이스 타입 대신 중첩 타입을 반환하면, Jackson `ObjectMapper`로 최종 값을 매핑한다.

스프링 MVC에선 클래스패스에 필수 의존성이 있다면 `@EnableSpringDataWebSupport`를 활성화하는 즉시 자동으로 필요한 컨버터들을 등록해 준다. `RestTemplate`과 함께 사용하려면 직접 `ProjectingJackson2HttpMessageConverter`(JSON)나 `XmlBeamHttpMessageConverter`를 등록해라.

자세한 내용은 공식 [스프링 데이터 예제 레포지토리](https://github.com/spring-projects/spring-data-examples)에 있는 [웹 프로젝센 예제](https://github.com/spring-projects/spring-data-examples/tree/master/web/projection)를 참고해라.

#### Querydsl Web Support

[QueryDSL](http://www.querydsl.com/) 통합을 지원하는 저장소에선 `Request` 쿼리 스트링에 있는 속성으로 쿼리를 파생시킬 수 있다.

다음과 같은 쿼리 스트링을 생각해 보자:

```
?firstname=Dave&lastname=Matthews
```

위 예제에서 다뤘던 `User` 객체가 있다고 가정하면, `QuerydslPredicateArgumentResolver`를 사용해 쿼리 스트링을 아래 있는 값으로 리졸브할 수 있다:

```java
QUser.user.firstname.eq("Dave").and(QUser.user.lastname.eq("Matthews"))
```

> 이 기능은 클래스패스에 Querydsl이 있고, `@EnableSpringDataWebSupport`를 사용했다면 자동으로 활성화된다.

메소드 시그니처에 `@QuerydslPredicate`를 추가하면 바로 사용할 수 있는 `Predicate`를 제공하므로 `QuerydslPredicateExecutor`를 통해 바로 실행할 수 있다.

> 타입 정보는 보통 메소드 리턴 타입을 통해 결정한다. 도메인 타입이 반드시 리턴 타입과 일치해야 하는건 아니므로, `QuerydslPredicate`의 `root` 속성을 사용해도 좋다.

다음은 메소드 시그니처에 `@QuerydslPredicate`를 사용하는 예제다:

```java
@Controller
class UserController {

  @Autowired UserRepository repository;

  @RequestMapping(value = "/", method = RequestMethod.GET)
  String index(Model model, @QuerydslPredicate(root = User.class) Predicate predicate, // (1)
          Pageable pageable, @RequestParam MultiValueMap<String, String> parameters) {

    model.addAttribute("users", repository.findAll(predicate, pageable));

    return "index";
  }
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 쿼리 스트링 인자로  `User`를 검색할 `Predicate`를 리졸브한다.</small>

디폴트 바인딩 규칙 다음과 같다:

- 단순한 프로퍼티에 `Object`를 사용하면 `eq`.
- 컬렉션같은 프로퍼티에 `Object`를 사용하면 `contains`.
- 단순한 프로퍼티에 `Collection`을 사용하면 `in`.

바인딩 규칙은 `@QuerydslPredicate`의 `bindings` 속성을 사용해서 커스텀할 수 있고, 자바 8 **디폴트 메소드**를 활용해 다음과 같이 레포지토리 인터페이스에 `QuerydslBinderCustomizer` 메소드를 추가해도 된다:

```java
interface UserRepository extends CrudRepository<User, String>,
                                 QuerydslPredicateExecutor<User>,                // (1)
                                 QuerydslBinderCustomizer<QUser> {               // (2)

  @Override
  default void customize(QuerydslBindings bindings, QUser user) {

    bindings.bind(user.username).first((path, value) -> path.contains(value))    // (3)
    bindings.bind(String.class)
      .first((StringPath path, String value) -> path.containsIgnoreCase(value)); // (4)
    bindings.excluding(user.password);                                           // (5)
  }
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `QuerydslPredicateExecutor`가 `Predicate`를 사용하는 검색 메소드를 제공한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 레포지토리 인터페이스에 `QuerydslBinderCustomizer`를 정의하면 자동으로 반영되며, 더 간단하게는 `@QuerydslPredicate(bindings=…)`를 사용해도 된다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> `username` 프로퍼티는 `contains`로 바인딩하도록 정의한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> `String` 프로퍼티는 디폴트로 `contains`로 바인딩하고, 대소문자를 구분하지 않도록 정의한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> `Predicate`를 만들 때 `password` 프로퍼티는 제외한다.</small>

### 11.8.3. Repository Populators

스프링 JDBC 모듈을 사용하고 있다면, SQL 스크립트로 `DataSource`에 데이터를 채우는 작업이 익숙할 거다. 레포지토리 레벨에서도 비슷한 기능을 제공한다. 단, 레포지토리 레벨은 저장소와는 독립적이기 때문에, SQL로 데이터를 정의하지 않는다. 여기서 설명할 populator는 XML(스프링 OXM 사용)과 JSON(Jackson 사용)으로 레포지토리에 저장할 데이터를 정의할 수 있다.

`data.json` 파일에 다음과 컨텐츠가 있다고 해보자:

**Example 51. Data defined in JSON**

```json
[ { "_class" : "com.acme.Person",
 "firstname" : "Dave",
  "lastname" : "Matthews" },
  { "_class" : "com.acme.Person",
 "firstname" : "Carter",
  "lastname" : "Beauford" } ]
```

레포지토리에 데이터를 추가하려면 스프링 데이터 Commons가 제공하는 레포지토리 네임스페이스에 populator 요소를 선언하면 된다. 이 데이터를 `PersonRepository`에 넣으려면 아래와 같은 populator를 선언해라:

**Example 52. Declaring a Jackson repository populator**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:repository="http://www.springframework.org/schema/data/repository"
  xsi:schemaLocation="http://www.springframework.org/schema/beans
    https://www.springframework.org/schema/beans/spring-beans.xsd
    http://www.springframework.org/schema/data/repository
    https://www.springframework.org/schema/data/repository/spring-repository.xsd">

  <repository:jackson2-populator locations="classpath:data.json" />

</beans>
```

이렇게 설정하면 `data.json` 파일을 읽어 Jackson `ObjectMapper`로 역직렬화한다.

JSON 객체를 역직렬화할 타입은 JSON 도큐먼트에 있는 `_class` 속성을 보고 결정한다. 그 다음 역직렬화한 객체를 처리할 적절한 레포지토리를 선택한다.

레포지토리에 저장할 데이터를 XML로 정의하고 싶다면 `unmarshaller-populator` 요소를 사용해라. 스프링 OXM에 있는 XML 마샬러 옵션 중 하나를 사용하면 된다. 자세한 내용은 [스프링 레퍼런스 문서](https://docs.spring.io/spring-framework/docs/5.3.2/reference/html/data-access.html#oxm)를 참고해라. 다음은 JAXB로 언마샬하는 예제다:

**Example 53. Declaring an unmarshalling repository populator (using JAXB)**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:repository="http://www.springframework.org/schema/data/repository"
  xmlns:oxm="http://www.springframework.org/schema/oxm"
  xsi:schemaLocation="http://www.springframework.org/schema/beans
    https://www.springframework.org/schema/beans/spring-beans.xsd
    http://www.springframework.org/schema/data/repository
    https://www.springframework.org/schema/data/repository/spring-repository.xsd
    http://www.springframework.org/schema/oxm
    https://www.springframework.org/schema/oxm/spring-oxm.xsd">

  <repository:unmarshaller-populator locations="classpath:data.json"
    unmarshaller-ref="unmarshaller" />

  <oxm:jaxb2-marshaller contextPath="com.acme" />

</beans>
```