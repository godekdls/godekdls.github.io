---
title: DAO Support
category: Spring Data Access
order: 3
permalink: /Spring%20Data%20Access/daosupport/
description: 스프링 프레임워크 DAO의 예외 계층 구조와, 어노테이션으로 레포지토리를 설정하는 방법을 소개합니다. 스프링 DAO 공식 레퍼런스를 한글로 번역한 문서입니다.
image: ./../../images/springdataaccess/DataAccessException.png
lastmod: 2021-01-10T23:00:00+09:00
comments: true
originalRefName: 스프링 프레임워크 데이터 액세스
originalRefLink: https://docs.spring.io/spring-framework/docs/5.3.2/reference/html/data-access.html#dao
---
<script>defaultLanguages = ['java']</script>

### 목차

- [2.1. Consistent Exception Hierarchy](#21-consistent-exception-hierarchy)
- [2.2. Annotations Used to Configure DAO or Repository Classes](#22-annotations-used-to-configure-dao-or-repository-classes)

---

스프링이 데이터 액세스 객체(DAO)를 지원하는 이유는, JDBC, 하이버네이트, JPA같은 데이터 접근 기술을 일관적이면서 쉽게 사용할 수 있도록 만들기 위해서다. 스프링 DAO를 사용하면 지금 언급한 persistence 기술을 전환하기도 상당히 쉬워진다. 게다가 기술마다 제각각인 exception 처리에 대한 걱정 없이 코드를 작성할 수 있다.

---

## 2.1. Consistent Exception Hierarchy

스프링은 `SQLException`같이 특정 기술에서만 사용하는 exception을, `DataAccessException`을 루트로 가지고 있는 자체 exception 클래스 계층 구조로 변환해준다. 변환된 exception은 기존 exception을 래핑한 것이기 때문에, 무엇이 잘못된 건지에 관한 정보를 유실할 가능성은 전혀 없다.

스프링은 JDBC 말고도 JPA, 하이버이트 exception도 래핑해서 자체 계층 구조의 런타임 exception으로 변환해준다. 덕분에 대부분 복구가 불가능한 persistence 예외 때문에 DAO에서 번거롭게 보일러플레이트 catch-and-throw 블록을 선언할 필요 없이, 적절한 레이어에서만 예외를 처리할 수 있다. (물론 원한다면 필요한 곳에서 예외를 잡아 처리할 수는 있다.) 앞서 언급했듯 JDBC 예외(데이터베이스 전용 dialect 포함)도 동일한 계층 구조로 변환되므로, JDBC 연산도 일관적인 프로그래밍 모델로 실행할 수 있다.

여기서 설명하는 기능은 스프링이 지원하는 다양한 ORM 프레임워크 전용 템플릿 클래스에서도 유효하다. 인터셉터 기반 클래스를 사용하는 어플리케이션은 `HibernateExceptions`와 `PersistenceExceptions` 자체 처리는 가급적이면 `SessionFactoryUtils`의 `convertHibernateAccessException(..)`이나 `convertJpaAccessException(..)` 메소드에 위임하는 게 좋다. 이 메소드들은 exception을 `org.springframework.dao` 예외 계층 구조와 호환되는 exception으로 변환한다. 물론 `PersistenceExceptions`는 unchecked exception이기 때문에 이대로 던져버리는 것도 가능하다 (DAO의 exception 추상화를 포기하겠다는 거지만서도).

다음은 스프링이 제공하는 예외 계층 구조를 나타낸 그림이다. (이미지에 보이는 클래스 계층 구조는 전체 `DataAccessException` 계층 구조 중 일부만 나타낸 것이라는 점에 주의.)

![DataAccessException](./../../images/springdataaccess/DataAccessException.png)

---

## 2.2. Annotations Used to Configure DAO or Repository Classes

데이터 액세스 객체(DAO)나 레포지토리가 exception을 변환하도록 설정하는 가장 좋은 방법은 `@Repository` 어노테이션이다. 게다가 이 어노테이션을 사용하면 XML 설정에 엔트리를 추가하지 않아도, 컴포넌트 스캔을 통해 DAO와 레포지토리를 찾아 설정한다. 다음은 `@Repository` 어노테이션 사용 예시다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
@Repository // (1)
public class SomeMovieFinder implements MovieFinder {
    // ...
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
@Repository // (1)
class SomeMovieFinder : MovieFinder {
    // ...
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `@Repository` 어노테이션.</small>

모든 DAO, 레포지토리 구현체는 사용한 persistence 기술에 따라 그에 맞는 리소스에 접근해야 한다. 예를 들어 JDBC 기반 레포지토리는 JDBC `DataSource` 접근 권한이, JPA 기반 레포지토리는 `EntityManager` 접근 권한이 필요하다. 가장 쉽게 해결하는 방법은 `@Autowired`, `@Inject`, `@Resource`, `@PersistenceContext` 어노테이션 중 중 하나로 리소스 의존성을 주입하는 거다. 다음은 JPA 레포지토리 예제다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
@Repository
public class JpaMovieFinder implements MovieFinder {

    @PersistenceContext
    private EntityManager entityManager;

    // ...
}

```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
@Repository
class JpaMovieFinder : MovieFinder {

    @PersistenceContext
    private lateinit var entityManager: EntityManager

    // ...
}
```

전형적인 하이네이트 API를 쓴다면, 다음 예제처럼 `SessionFactory`를 주입할 수 있다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
@Repository
public class HibernateMovieFinder implements MovieFinder {

    private SessionFactory sessionFactory;

    @Autowired
    public void setSessionFactory(SessionFactory sessionFactory) {
        this.sessionFactory = sessionFactory;
    }

    // ...
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
@Repository
class HibernateMovieFinder(private val sessionFactory: SessionFactory) : MovieFinder {
    // ...
}
```

여기서 보여줄 마지막 예제는 전형적인 JDBC 지원을 사용한다. JDBC `DataSource`는 `JdbcTemplate`이나 기타 다른 데이터 접근 지원 클래스(`SimpleJdbcCall` 등)를 만드는 초기화 메소드나 생성자에 주입하면 된다. 다음 예제는 `@Autowired`를 통해 `DataSource`를 자동 주입한다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
@Repository
public class JdbcMovieFinder implements MovieFinder {

    private JdbcTemplate jdbcTemplate;

    @Autowired
    public void init(DataSource dataSource) {
        this.jdbcTemplate = new JdbcTemplate(dataSource);
    }

    // ...
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
@Repository
class JdbcMovieFinder(dataSource: DataSource) : MovieFinder {

    private val jdbcTemplate = JdbcTemplate(dataSource)

    // ...
}
```

> 어플리케이션 컨텍스트에서 `@Repository` 어노테이션을 활성화하는 설정은 해당 persistence 기술 문서를 참고해라.