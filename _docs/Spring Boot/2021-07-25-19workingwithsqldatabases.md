---
title: Working with SQL Databases
category: Spring Boot
order: 19
permalink: /Spring%20Boot/working-with-sql-databases/
description: 스프링 부트로 JPA, JDBC, JOOQ, R2DBC를 활용해 데이터소스, 커넥션 팩토리, 템플릿, 레포지토리 자동 설정하기
image: ./../../images/springboot/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 부트
originalRefLink: https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#features.sql
parent: Spring Boot Features
parentUrl: /Spring%20Boot/spring-boot-features/
priority: 0.6
---
<script>defaultLanguages = ['properties']</script>

### 목차

- [7.11.1. Configure a DataSource](#7111-configure-a-datasource)
  * [Embedded Database Support](#embedded-database-support)
  * [Connection to a Production Database](#connection-to-a-production-database)
  * [DataSource Configuration](#datasource-configuration)
  * [Supported Connection Pools](#supported-connection-pools)
  * [Connection to a JNDI DataSource](#connection-to-a-jndi-datasource)
- [7.11.2. Using JdbcTemplate](#7112-using-jdbctemplate)
- [7.11.3. JPA and Spring Data JPA](#7113-jpa-and-spring-data-jpa)
  * [Entity Classes](#entity-classes)
  * [Spring Data JPA Repositories](#spring-data-jpa-repositories)
  * [Creating and Dropping JPA Databases](#creating-and-dropping-jpa-databases)
  * [Open EntityManager in View](#open-entitymanager-in-view)
- [7.11.4. Spring Data JDBC](#7114-spring-data-jdbc)
- [7.11.5. Using H2’s Web Console](#7115-using-h2s-web-console)
  * [Changing the H2 Console’s Path](#changing-the-h2-consoles-path)
- [7.11.6. Using jOOQ](#7116-using-jooq)
  * [Code Generation](#code-generation)
  * [Using DSLContext](#using-dslcontext)
  * [jOOQ SQL Dialect](#jooq-sql-dialect)
  * [Customizing jOOQ](#customizing-jooq)
- [7.11.7. Using R2DBC](#7117-using-r2dbc)
  * [Embedded Database Support](#embedded-database-support-1)
  * [Using DatabaseClient](#using-databaseclient)
  * [Spring Data R2DBC Repositories](#spring-data-r2dbc-repositories)

---

## 7.11. Working with SQL Databases

[스프링 프레임워크](https://spring.io/projects/spring-framework)는 `JdbcTemplate`을 통한 직접적인 JDBC 접근부터 Hibernate같은 완전한 "객체 관계 매핑<sup>object relational mapping</sup>" 기술까지, SQL 데이터베이스 작업을 위한 광범위한 기능을 지원한다. [스프링 데이터](https://spring.io/projects/spring-data)는 또 다른 수준의 기능을 제공하는데, 인터페이스만 정의하면 곧바로 `Repository` 구현체를 만들고, 메소드명에 컨벤션을 적용해 쿼리를 생성해준다.

### 7.11.1. Configure a DataSource

자바의 `javax.sql.DataSource` 인터페이스는 데이터베이스 커넥션 작업을 위한 표준 메소드를 제공한다. `DataSource`는 보통 `URL`과 몇가지 credential을 사용해서 데이터베이스 커넥션을 구축한다.

> DataSource 설정을 직접 제어하는 방법 등, 더 많은 것들을 커스텀하는 예제는 ["How-to" 섹션](../howto.data-access#1281-configure-a-custom-datasource)을 참고해라.

#### Embedded Database Support

때로는 애플리케이션을 개발하면서 인메모리 임베디드 데이터베이스를 사용하는 게 편리할 때가 있다. 인메모리 데이터베이스는 명백히 영구 저장소를 제공하지 않는다. 애플리케이션을 시작할 때 데이터베이스를 채우고 애플리케이션이 종료되면 데이터를 버릴 준비가 되어있어야 한다.

> [데이터베이스를 초기화하는 방법](../howto.data-initialization)은 "How-to" 섹션에서 다루고 있다.

스프링 부트는 임베디드 [H2](https://www.h2database.com/), [HSQL](http://hsqldb.org/), [Derby](https://db.apache.org/derby/) 데이터를 자동 설정할 수 있다. 커넥션 URL은 설정할 필요 없다. 사용하고 싶은 임베디드 데이터베이스를 위한 빌드 의존성만 추가하면 된다. 클래스패스에 임베디드 데이터베이스가 여러 개 있을 땐 <span class="custom-blockquote">spring.datasource.embedded-database-connection</span> 설정 프로퍼티로 사용할 데이터베이스를 제어해라. 이 프로퍼티를 `none`으로 설정하면 임베디드 데이터베이스 자동 설정을 비활성화한다.

> 이 기능을 테스트에서 사용할 때는 사용 중인 애플리케이션 컨텍스트의 수와는 상관 없이 전체 테스트 스위트에서 같은 데이터베이스를 재사용한다는 걸 알아챈 사람도 있을 거다. 각 컨텍스트마다 별도의 임베디드 데이터베이스를 사용하려면 <span class="custom-blockquote">spring.datasource.generate-unique-name</span>을 `true`로 설정해야 한다.

예를 들어 전형적인 POM 의존성은 다음과 같다:

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-jpa</artifactId>
</dependency>
<dependency>
    <groupId>org.hsqldb</groupId>
    <artifactId>hsqldb</artifactId>
    <scope>runtime</scope>
</dependency>
```

> 임베디드 데이터베이스를 자동 설정하려면 `spring-jdbc` 의존성이 필요하다. 이 예시에선 `spring-boot-starter-data-jpa`를 통해 간접적으로<sup>transitively</sup> 가져오고 있다.

> 어떤 이유에서든지 임베디드 데이터베이스를 위한 커넥션 URL을 설정한다면, 반드시 데이터베이스의 자동 종료를 비활성화했는지 확인해봐야 한다. H2를 사용한다면 `DB_CLOSE_ON_EXIT=FALSE`를 사용해야 한다. HSQLDB를 사용하는 경우엔 `shutdown=true`를 사용해선 안 된다. 데이터베이스의 자동 종료를 비활성화하면 데이터베이스를 닫을 때 스프링 부트에서 제어가 가능해져서, 더 이상 접근할 필요가 없을 때 데이터베이스를 닫을 수 있다.

#### Connection to a Production Database

프로덕션 데이터베이스 커넥션도 풀링 `DataSource`를 사용해서 자동 설정할 수 있다.

#### DataSource Configuration

DataSource 설정은 `spring.datasource.*`에 있는 외부 설정 프로퍼티로 제어한다. 예를 들어 `application.properties`에 아래 설정을 추가할 수 있다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.datasource.url=jdbc:mysql://localhost/test
spring.datasource.username=dbuser
spring.datasource.password=dbpass
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  datasource:
    url: "jdbc:mysql://localhost/test"
    username: "dbuser"
    password: "dbpass"
```

> 최소한 `spring.datasource.url` 프로퍼티로 URL은 지정해야 한다. URL을 설정하지 않으면 스프링 부트에선 임베디드 데이터베이스 자동 설정을 시도한다.

> 스프링 부트는 대부분의 데이터베이스에서 URL을 보고 JDBC 드라이버 클래스를 추론해낸다. 지정하고 싶은 클래스가 따로 있다면 <span class="custom-blockquote">spring.datasource.driver-class-name</span> 프로퍼티를 사용하면 된다.

> 풀링 `DataSource`를 생성하려면 유효한 `Driver` 클래스가 있는지를 확인하는 게 먼저기 때문에, 스프링 부트는 가장 먼저 이것부터 확인한다. 다시말해 <span class="custom-blockquote">spring.datasource.driver-class-name=com.mysql.jdbc.Driver</span>를 설정한다면 이 클래스를 로드할 수 있어야 한다.

지원하는 다른 옵션은 [`DataSourceProperties`](https://github.com/spring-projects/spring-boot/tree/v2.5.2/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/jdbc/DataSourceProperties.java)를 참고해라. 이 옵션들은 [실제 구현체](#supported-connection-pools)와 상관없이 동작하는 표준 옵션이다. 각각의 프리픽스(`spring.datasource.hikari.*`, `spring.datasource.tomcat.*`, `spring.datasource.dbcp2.*`, `spring.datasource.oracleucp.*`)를 사용해서 구현체 전용 설정을 세세히 조정할 수도 있다. 자세한 내용은 사용 중인 커넥션 풀 구현체의 문서를 참고해라.

예를 들어 [톰캣 커넥션 풀](https://tomcat.apache.org/tomcat-9.0-doc/jdbc-pool.html#Common_Attributes)을 사용할 때는 다음과 같은 설정들을 추가로 커스텀할 수 있다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.datasource.tomcat.max-wait=10000
spring.datasource.tomcat.max-active=50
spring.datasource.tomcat.test-on-borrow=true
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  datasource:
    tomcat:
      max-wait: 10000
      max-active: 50
      test-on-borrow: true
```

여기에선 풀에서 커넥션을 이용할 수 없을 땐 예외를 던지기 전에 10000ms를 기다리도록 설정하고 있으며, 커넥션을 최대 50개로 제한하고, 풀에서 커녁센을 빌려오기 전에 커넥션을 검증한다.

#### Supported Connection Pools

스프링 부트는 아래 알고리즘으로 구현체를 선택한다:

1. 성능과 동시성을 고려할 때 [HikariCP](https://github.com/brettwooldridge/HikariCP)를 가장 선호한다. HikariCP를 사용할 수 있으면 무조건 선택한다.
2. 그 외엔 가능하다면 톰캣 풀링 `DataSource`를 사용한다.
3. 그 외엔 가능하다면 [Commons DBCP2](https://commons.apache.org/proper/commons-dbcp/)를 사용한다.
4. HikariCP, Tomcat, DBCP2 중 어떤 것도 사용할 수 없을 땐 가능하다면 Oracle UCP를 사용한다.

> `spring-boot-starter-jdbc`나 `spring-boot-starter-data-jpa` "스타터"를 사용하면 자동으로 `HikariCP` 의존성이 추가된다.

이 알고리즘은 그냥 지나치고, `spring.datasource.type` 프로퍼티를 설정해서 사용할 커넥션 풀을 지정해도 된다. 특히 톰캣 컨테이너에서 애플리케이션을 실행하는 경우 필요할 수 있는데, 톰캣 컨테이너는 기본으로 `tomcat-jdbc`를 제공하기 때문이다.

다른 커넥션 풀은 언제든지 `DataSourceBuilder`를 사용해서 수동으로 설정하면 된다. 자체 `DataSource` 빈을 정의하면 자동 설정은 일어나지 않는다. `DataSourceBuilder`는 다음과 같은 커넥션 풀을 지원한다:

- HikariCP
- 톰캣 풀링 `Datasource`
- Commons DBCP2
- Oracle UCP & `OracleDataSource`
- 스프링 프레임워크의 `SimpleDriverDataSource`
- H2 `JdbcDataSource`
- PostgreSQL `PGSimpleDataSource`

#### Connection to a JNDI DataSource

스프링 부트 애플리케이션을 애플리케이션 서버에 배포할 때는, 애플리케이션 서버에 내장된 기능을 통해 DataSource를 설정, 관리하고, JNDI를 사용해 접근하고 싶을 수도 있다.

특정 JNDI 위치에 있는 `DataSource`는 `spring.datasource.url`, `spring.datasource.username`, `spring.datasource.password` 프로퍼티 대신, `spring.datasource.jndi-name` 프로퍼티를 사용해서 접근할 수 있다. 예를 들어 아래 `application.properties`는 `DataSource`로 정의한 JBoss AS에 접근하는 방법을 보여준다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.datasource.jndi-name=java:jboss/datasources/customers
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  datasource:
    jndi-name: "java:jboss/datasources/customers"
```

### 7.11.2. Using JdbcTemplate

스프링의 `JdbcTemplate`과 `NamedParameterJdbcTemplate` 클래스는 자동으로 설정되며, 아래 예제처럼 자체 빈에 직접 `@Autowire`할 수 있다:

```java
@Component
public class MyBean {

    private final JdbcTemplate jdbcTemplate;

    public MyBean(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public void doSomething() {
        this.jdbcTemplate ...
    }

}
```

다음 예제에서 처럼 `spring.jdbc.template.*` 프로퍼티를 이용해 템플릿의 프로퍼티를 커스텀해도 된다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.jdbc.template.max-rows=500
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  jdbc:
    template:
      max-rows: 500
```

> `NamedParameterJdbcTemplate` 내부에선 같은 `JdbcTemplate` 인스턴스를 재사용한다. 정의한 `JdbcTemplate`이 둘 이상이면서 primary로 지정해준 후보가 없으면 `NamedParameterJdbcTemplate`은 자동 설정되지 않는다.

### 7.11.3. JPA and Spring Data JPA

Java Persistence API는 객체를 관계형 데이터베이스에 "매핑"할 수 있는 표준 기술이다. `spring-boot-starter-data-jpa` POM을 사용하면 빠르게 시작해볼 수 있는데, 아래와 같은 주요 의존성을 제공한다:

- Hibernate: 가장 인기 있는 JPA 구현체 중 하나.
- Spring Data JPA: JPA 기반 레포지토리 구현을 도와준다.
- Spring ORM: 스프링 프레임워크에 있는 코어 ORM 지원.

> 여기서는 JPA나 [Spring Data](https://spring.io/projects/spring-data)에 대한 내용은 자세히 내용은 다루지 않는다. [spring.io](https://spring.io/)에 있는 [“JPA로 데이터 액세스하기”](https://spring.io/guides/gs/accessing-data-jpa/) 가이드를 따라해보거나, [Spring Data JPA](https://spring.io/projects/spring-data-jpa), [Hibernate](https://hibernate.org/orm/documentation/) 레퍼런스 문서를 읽어보는 것도 좋다.

#### Entity Classes

전통적으로 JPA "Entity" 클래스는 `persistence.xml` 파일에 지정한다. 스프링 부트에선 이 파일은 필요하지 않으며, 대신 "엔티티 스캔"을 사용한다. 기본적으로는 메인 설정 클래스 (`@EnableAutoConfiguration`이나 `@SpringBootApplication` 어노테이션을 선언한 클래스) 아래에 있는 모든 패키지를 검색한다.

`@Entity`나 `@Embeddable`, `@MappedSuperclass` 어노테이션을 선언한 모든 클래스를 찾는다. 전형적인 엔티티 클래스는 아래 코드와 유사할 거다:

```java
@Entity
public class City implements Serializable {

    @Id
    @GeneratedValue
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String state;

    // ... additional members, often include @OneToMany mappings

    protected City() {
        // no-args constructor required by JPA spec
        // this one is protected since it shouldn't be used directly
    }

    public City(String name, String state) {
        this.name = name;
        this.state = state;
    }

    public String getName() {
        return this.name;
    }

    public String getState() {
        return this.state;
    }

    // ... etc

}
```

> `@EntityScan` 어노테이션을 사용하면 엔티티를 스캔할 위치를 커스텀할 수 있다. how-to 가이드 “[스프링 설정에서 @Entity 정의 분리하기](../howto.data-access#1284-separate-entity-definitions-from-spring-configuration)”를 참고해라.

#### Spring Data JPA Repositories

[Spring Data JPA](https://spring.io/projects/spring-data-jpa) 레포지토리는 데이터에 액세스할 때 정의하는 인터페이스다. JPA 쿼리는 정의한 메소드 이름에 따라 자동으로 만들어진다. 예를 들어 `CityRepository` 인터페이스에선 `findAllByState(String state)` 메소드를 선언하면 주어진 국가에 해당하는 모든 도시를 찾을 수 있다.

더 복잡한 쿼리는 메소드 위에 스프링 데이터의 [`Query`](https://docs.spring.io/spring-data/jpa/docs/2.5.2/api/org/springframework/data/jpa/repository/Query.html) 어노테이션을 선언하면 된다.

스프링 데이터 레포지토리는 보통 [`Repository`](https://docs.spring.io/spring-data/commons/docs/2.5.2/api/org/springframework/data/repository/Repository.html)나 [`CrudRepository`](https://docs.spring.io/spring-data/commons/docs/2.5.2/api/org/springframework/data/repository/CrudRepository.html) 인터페이스를 상속한다. 자동 설정을 사용할 때는 메인 설정 클래스(`@EnableAutoConfiguration`이나 `@SpringBootApplication` 어노테이션을 선언한 클래스)를 가지고 있는 패키지 아래에서 레포지토리를 찾는다.

다음은 전형적인 스프링 데이터 레포지토리 인터페이스를 정의하는 예시다:

```java
public interface CityRepository extends Repository<City, Long> {

    Page<City> findAll(Pageable pageable);

    City findByNameAndStateAllIgnoringCase(String name, String state);

}
```

스프링 데이터 JPA 레포지토리는 세 가지 부트스트랩 모드 default, deferred, lazy를 지원한다. deferred나 lazy 부트스트랩을 활성화하려면 <span class="custom-blockquote">spring.data.jpa.repositories.bootstrap-mode</span> 프로퍼티를 각각 `deferred`나 `lazy`로 설정한다. deferred나 lazy 부트스트랩을 사용할 때는, 자동 설정된 `EntityManagerFactoryBuilder`에선 컨텍스트에 `AsyncTaskExecutor`가 있으면 이를 bootstrap executor로 사용한다. 둘 이상이 있다면 `applicationTaskExecutor`라는 이름을 가진 빈을 사용한다.

> deferred나 lazy 부트스트랩을 사용하는 경우 애플리케이션 컨텍스트 부트스트랩 단계를 마칠 때까지 JPA 인프라 접근을 미뤄야 한다. JPA 인프라가 필요한 초기화 로직은 `SmartInitializingSingleton`을 통해 실행할 수 있다. 스프링 빈으로 생성한 JPA 컴포넌트가 있다면 (converter 등), `ObjectProvider`를 사용해서 의존성 리졸브 시점을 지연시켜라.

> 여기서는 스프링 데이터 JPA를 겨우 겉핥기식으로만 다뤘다. 자세한 내용은 [스프링 데이터 JPA 레퍼런스 문서](https://docs.spring.io/spring-data/jpa/docs/2.5.2/reference/html)를 확인해라.

#### Creating and Dropping JPA Databases

기본적으로 JPA 데이터베이스는 임베디드 데이터베이스(H2, HSQL 또는 Derby)를 사용할 때**만** 자동으로 생성된다. `spring.jpa.*` 프로퍼티로 JPA 설정을 명시해도 된다. 예를 들어, 테이블을 생성하고 삭제하려면 `application.properties`에 아래 설정을 추가하면 된다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.jpa.hibernate.ddl-auto=create-drop
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  jpa:
    hibernate.ddl-auto: "create-drop"
```

> Hibernate 내부에서 자체적으로 사용하는 프로퍼티명은 (더 잘 기억하게 된다면) `hibernate.hbm2ddl.auto`다. 하이버네이트 네이티브 프로퍼티는 `spring.jpa.properties.*`를 사용해서 설정할 수 있다 (프리픽스는 엔티티 매니저에 추가하기 전에 제거된다). 다음은 Hibernate를 위한 JPA 프로퍼티를 설정하는 예시다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.jpa.properties.hibernate[globally_quoted_identifiers]=true
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  jpa:
    properties:
      hibernate:
        "globally_quoted_identifiers": "true"
```

이 설정에선 Hibernate 엔티티 매니저에 `true` 값을  `hibernate.globally_quoted_identifiers` 프로퍼티로 전달한다.

기본적으로 DDL 실행(혹은 유효성 검사)은 `ApplicationContext`가 시작될 때까지 지연된다. `spring.jpa.generate-ddl` 플래그도 있긴 하지만, `ddl-auto` 설정이 좀 더 세분화돼 있기 때문에 Hibernate 자동 설정을 활성화했을 땐 사용하지 않는다.

#### Open EntityManager in View

웹 애플리케이션을 실행하게 되면 스프링 부트는 기본적으로 [`OpenEntityManagerInViewInterceptor`](https://docs.spring.io/spring-framework/docs/5.3.8/javadoc-api/org/springframework/orm/jpa/support/OpenEntityManagerInViewInterceptor.html)를 등록해서 "Open EntityManager in View" 패턴을 적용하므로, 웹 뷰에서 lazy 로딩를 사용할 수 있다. 이게 싫다면 `application.properties`에서 `spring.jpa.open-in-view`를 `false`로 설정해야 한다.

### 7.11.4. Spring Data JDBC

스프링 데이터는 JDBC를 위한 레포지토리를 지원하고 있으며, `CrudRepository` 메소드에서 사용할 SQL을 자동으로 생성해준다. 좀 더 복잡한 고급 쿼리에는 `@Query` 어노테이션을 제공한다.

스프링 부트는 클래스패스에 필요한 의존성이 있으면 스프링 데이터의 JDBC 레포지토리를 자동 설정한다. JDBC 레포지토리는 `spring-boot-starter-data-jdbc` 의존성만 있으면 추가할 수 있다. 필요하면 애플리케이션에 `@EnableJdbcRepositories` 어노테이션이나 `JdbcConfiguration` 하위 클래스를 작성해서 스프링 데이터 JDBC의 설정을 제어해도 된다.

> 스프링 데이터 JDBC에 관한 자세한 내용은 [레퍼런스 문서](https://docs.spring.io/spring-data/jdbc/docs/2.2.2/reference/html/)를 참고해라.

### 7.11.5. Using H2’s Web Console

[H2 데이터베이스](https://www.h2database.com/)는 [브라우저 기반 콘솔](https://www.h2database.com/html/quickstart.html#h2_console)을 제공하며, 스프링 부트는 자동 설정을 지원한다. 아래 조건이 충족되면 콘솔을 자동으로 설정한다.

- 서블릿 기반 웹 애플리케이션을 개발하고 있다.
- 클래스패스에 `com.h2database:h2`가 있다.
- [스프링 부트의 개발자 도구](../developing-with-spring-boot#68-developer-tools)를 사용 중이다.

> 스프링 부트의 개발자 도구를 사용하진 않아도 H2의 콘솔을 사용하고 싶으면 `spring.h2.console.enabled` 프로퍼티를 `true`로 설정하면 된다.

> H2 콘솔은 개발 중에만 사용하기 위한 것이므로 프로덕션에선 `spring.h2.console.enabled`를 `true`로 설정하지 않도록 주의해야 한다.

#### Changing the H2 Console’s Path

콘솔은 기본적으로 `/h2-console`에서 사용할 수 있다. `spring.h2.console.path` 프로퍼티를 사용하면 콘솔의 경로를 커스텀할 수 있다.

### 7.11.6. Using jOOQ

[jOOQ<sup>jOOQ Object Oriented Querying</sup>](https://www.jooq.org/)는 [Data Geekery](https://www.datageekery.com/)에서 인기 있는 제품으로, 데이터베이스로부터 자바 코드를 생성해주며, fluent API를 통해 type-safe SQL 쿼리를 작성할 수 있게 해준다. 스프링 부트에선 상용 버전과 오픈 소스 에디션을 모두 사용할 수 있다.

#### Code Generation

jOOQ type-safe 쿼리를 이용하려면 데이터베이스 스키마로부터 자바 클래스를 생성해야 한다. [jOOQ 사용자 매뉴얼](https://www.jooq.org/doc/3.14.11/manual-single-page/#jooq-in-7-steps-step3)에 있는 가이드를 따라하면 된다. `jooq-codegen-maven` 플러그인과 함께 `spring-boot-starter-parent` "parent POM"을 사용하는 경우엔 플러그인의 `<version>` 태그를 생략해도 괜찮다. 스프링 부트에서 정의한 버전 변수(ex. `h2.version`)를 사용해서 플러그인의 데이터베이스 의존성을 선언할 수도 있다. 아래 예시를 참고해라:

```xml
<plugin>
    <groupId>org.jooq</groupId>
    <artifactId>jooq-codegen-maven</artifactId>
    <executions>
        ...
    </executions>
    <dependencies>
        <dependency>
            <groupId>com.h2database</groupId>
            <artifactId>h2</artifactId>
            <version>${h2.version}</version>
        </dependency>
    </dependencies>
    <configuration>
        <jdbc>
            <driver>org.h2.Driver</driver>
            <url>jdbc:h2:~/yourdatabase</url>
        </jdbc>
        <generator>
            ...
        </generator>
    </configuration>
</plugin>
```

#### Using DSLContext

jOOQ에서 제공하는 fluent API는 `org.jooq.DSLContext` 인터페이스를 통해 시작한다. 스프링 부트는 `DSLContext`를 스프링 빈으로 자동 설정해서 애플리케이션 `DataSource`에 연결해준다. 다음 예제처럼 `DSLContext`를 주입해서 사용하면 된다:

```java
@Component
public class MyBean {

    private final DSLContext create;

    public MyBean(DSLContext dslContext) {
        this.create = dslContext;
    }


}
```

> jOOQ 매뉴얼에선 `DSLContext`를 보관할 때 `create`라는 변수를 사용하곤 한다.

그런 다음 아래 예제처럼 `DSLContext`를 사용해 쿼리를 구성하면 된다:

```java
public List<GregorianCalendar> authorsBornAfter1980() {
    return this.create.selectFrom(AUTHOR)
            .where(AUTHOR.DATE_OF_BIRTH.greaterThan(new GregorianCalendar(1980, 0, 1)))
            .fetch(AUTHOR.DATE_OF_BIRTH);
```

#### jOOQ SQL Dialect

`spring.jooq.sql-dialect` 프로퍼티를 설정하지 않았다면 스프링 부트가 데이터소스에 사용할 SQL 방언<sup>dialect</sup>을 결정한다. 스프링 부트에서 방언을 감지하지 못하면 `DEFAULT`를 사용한다.

> 스프링 부트에선 jOOQ 오픈 소스 버전에서 지원하는 방언만 자동 설정할 수 있다.

#### Customizing jOOQ

더 많은 것들을 커스텀하고 싶으면 자체 `DefaultConfigurationCustomizer` 빈을 정의하면 된다. 이 빈은 `org.jooq.Configuration` `@Bean`을 생성하기 전에 호출하며, 자동 설정으로 적용된 다른 설정들보다 우선 순위가 높다.

jOOQ 설정을 전부 직접 제어하고 싶다면 자체 `org.jooq.Configuration` `@Bean`을 만들어도 된다.

### 7.11.7. Using R2DBC

[R2DBC<sup>Reactive Relational Database Connectivity</sup>](https://r2dbc.io/) 프로젝트는 관계형 데이터베이스에 리액티브 프로그래밍 API를 도입했다. R2DBC의 `io.r2dbc.spi.Connection`은 논블로킹 데이터베이스 커넥션 작업을 위한 표준 메소드를 제공한다. 커넥션은 jdbc의 `DataSource`와 유사한 `ConnectionFactory`를 통해 제공한다.

`ConnectionFactory` 설정은 `spring.r2dbc.*`에 있는 외부 설정 프로퍼티로 제어한다. 예를 들어 `application.properties`에 아래 설정을 추가할 수 있다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.r2dbc.url=r2dbc:postgresql://localhost/test
spring.r2dbc.username=dbuser
spring.r2dbc.password=dbpass
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  r2dbc:
    url: "r2dbc:postgresql://localhost/test"
    username: "dbuser"
    password: "dbpass"
```

> 스프링 부트는 R2DBC의 Connection Factory 디스커버리를 통해 드라이버를 가져오기 때문에, 드라이버 클래스명을 지정하지 않아도 된다.

> 최소한 URL은 지정해야 한다. URL에 명시한 정보는 개별로 지정한 프로퍼티보다 (`name`, `username`, `password`, 풀링 옵션) 우선순위가 높다.

> [데이터베이스를 초기화하는 방법](../howto.data-initialization#1293-initialize-a-database-using-basic-sql-scripts)은 "How-to" 섹션에서 다루고 있다.

중앙 데이터베이스 설정에 사용하고 싶지 않은 (혹은 설정할 수 없는) 파라미터를 지정하는 등, `ConnectionFactory`로 생성하는 커넥션을 커스텀하고 싶으면 `ConnectionFactoryOptionsBuilderCustomizer` `@Bean`을 사용하면 된다. 다음은 데이터베이스 포트를 수동으로 재정의하면서 나머지 옵션은 애플리케이션 설정에서 가져오는 예시다:

```java
@Configuration(proxyBeanMethods = false)
public class MyR2dbcConfiguration {

    @Bean
    public ConnectionFactoryOptionsBuilderCustomizer connectionFactoryPortCustomizer() {
        return (builder) -> builder.option(ConnectionFactoryOptions.PORT, 5432);
    }

}
```

다음은 PostgreSQL 커넥션 옵션 몇 가지를 설정하는 예시다:

```java
@Configuration(proxyBeanMethods = false)
public class MyPostgresR2dbcConfiguration {

    @Bean
    public ConnectionFactoryOptionsBuilderCustomizer postgresCustomizer() {
        Map<String, String> options = new HashMap<>();
        options.put("lock_timeout", "30s");
        options.put("statement_timeout", "60s");
        return (builder) -> builder.option(PostgresqlConnectionFactoryProvider.OPTIONS, options);
    }

}
```

사용할 수 있는 `ConnectionFactory` 빈이 있을 때는 전형적인 JDBC `DataSource` 자동 설정을 물린다. 리액티브 애플리케이션에서 블로킹 JDBC API를 사용하는 리스크를 감수하고서라도 JDBC `DataSource` 자동 설정을 유지하고 싶다면, `@Configuration` 클래스에 `@Import(DataSourceAutoConfiguration.class)`를 추가해서 다시 활성화시켜라.

#### Embedded Database Support

스프링 부트는 [JDBC 지원](#embedded-database-support)과 마찬가지로 리액티브에서도 임베디드 데이터베이스를 자동으로 설정할 수 이다. 커넥션 URL은 설정할 필요 없다. 아래 예제처럼 사용하고 싶은 임베디드 데이터베이스를 위한 빌드 의존성만 추가하면 된다:

```xml
<dependency>
    <groupId>io.r2dbc</groupId>
    <artifactId>r2dbc-h2</artifactId>
    <scope>runtime</scope>
</dependency>
```

> 이 기능을 테스트에서 사용할 때는 사용 중인 애플리케이션 컨텍스트의 수와는 상관 없이 전체 테스트 스위트에서 같은 데이터베이스를 재사용한다는 걸 알아챈 사람도 있을 거다. 각 컨텍스트마다 별도의 임베디드 데이터베이스를 사용하려면 <span class="custom-blockquote">spring.r2dbc.generate-unique-name</span>을 `true`로 설정해야 한다.

#### Using DatabaseClient

`DatabaseClient` 빈은 자동으로 설정되며, 아래 예제처럼 자체 빈에 직접 `@Autowire`할 수 있다:

```java
@Component
public class MyBean {

    private final DatabaseClient databaseClient;

    public MyBean(DatabaseClient databaseClient) {
        this.databaseClient = databaseClient;
    }

    // ...

}
```

#### Spring Data R2DBC Repositories

[스프링 데이터 R2DBC](https://spring.io/projects/spring-data-r2dbc) 레포지토리는 데이터에 액세스할 때 정의하는 인터페이스다. 쿼리는 정의한 메소드 이름에 따라 자동으로 만들어진다. 예를 들어 `CityRepository` 인터페이스에선 `findAllByState(String state)` 메소드를 선언하면 주어진 국가에 해당하는 모든 도시를 찾을 수 있다.

더 복잡한 쿼리는 메소드 위에 스프링 데이터의 [`Query`](https://docs.spring.io/spring-data/r2dbc/docs/1.3.2/api/org/springframework/data/r2dbc/repository/Query.html) 어노테이션을 선언하면 된다.

스프링 데이터 레포지토리는 보통 [`Repository`](https://docs.spring.io/spring-data/commons/docs/2.5.2/api/org/springframework/data/repository/Repository.html)나 [`CrudRepository`](https://docs.spring.io/spring-data/commons/docs/2.5.2/api/org/springframework/data/repository/CrudRepository.html) 인터페이스를 상속한다. 자동 설정을 사용할 때는 메인 설정 클래스(`@EnableAutoConfiguration`이나 `@SpringBootApplication` 어노테이션을 선언한 클래스)를 가지고 있는 패키지 아래에서 레포지토리를 찾는다.

다음은 전형적인 스프링 데이터 레포지토리 인터페이스를 정의하는 예시다:

```java
public interface CityRepository extends Repository<City, Long> {

    Mono<City> findByNameAndStateAllIgnoringCase(String name, String state);

}
```

> 여기서는 스프링 데이터 R2DBC를 겨우 겉핥기식으로만 다뤘다. 자세한 내용은 [스프링 데이터 R2DBC 레퍼런스 문서](../../Spring%20Data%20R2DBC/introduction)를 확인해라.
