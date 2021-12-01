---
title: Object Relational Mapping (ORM) Data Access
category: Spring Data Access
order: 7
permalink: /Spring%20Data%20Access/ormdataaccess/
description: 스프링 프레임워크 ORM 레퍼런스를 한글로 번역한 문서입니다. ORM 기술로 데이터에 접근하고 스프링의 트랜잭션을 적용하는 방법을 설명합니다. 하위 섹션에서 하이버네이트, JPA와 관련한 설정을 다룹니다.
image: ./../../images/spring/logo.png
lastmod: 2021-01-10T23:00:00+09:00
comments: true
originalRefName: 스프링 프레임워크 데이터 액세스
originalRefLink: https://docs.spring.io/spring-framework/docs/5.3.2/reference/html/data-access.html#orm
---
<script>defaultLanguages = ['java']</script>

### 목차

- [6.1. Introduction to ORM with Spring](#61-introduction-to-orm-with-spring)
- [6.2. General ORM Integration Considerations](#62-general-orm-integration-considerations)
  + [6.2.1. Resource and Transaction Management](#621-resource-and-transaction-management)
  + [6.2.2. Exception Translation](#622-exception-translation)
- [6.3. Hibernate](#63-hibernate)
  + [6.3.1. SessionFactory Setup in a Spring Container](#631-sessionfactory-setup-in-a-spring-container)
  + [6.3.2. Implementing DAOs Based on the Plain Hibernate API](#632-implementing-daos-based-on-the-plain-hibernate-api)
  + [6.3.3. Declarative Transaction Demarcation](#633-declarative-transaction-demarcation)
  + [6.3.4. Programmatic Transaction Demarcation](#634-programmatic-transaction-demarcation)
  + [6.3.5. Transaction Management Strategies](#635-transaction-management-strategies)
  + [6.3.6. Comparing Container-managed and Locally Defined Resources](#636-comparing-container-managed-and-locally-defined-resources)
  + [6.3.7. Spurious Appl](#637-spurious-application-server-warnings-with-hibernate)
- [6.4. JPA](#64-jpa)
  + [6.4.1. Three Options for JPA Setup in a Spring Environment](#641-three-options-for-jpa-setup-in-a-spring-environment)
    * [Using LocalEntityManagerFactoryBean](#using-localentitymanagerfactorybean)
    * [Obtaining an EntityManagerFactory from JNDI](#obtaining-an-entitymanagerfactory-from-jndi)
    * [Using LocalContainerEntityManagerFactoryBean](#using-localcontainerentitymanagerfactorybean)
    * [Dealing with Multiple Persistence Units](#dealing-with-multiple-persistence-units)
    * [Background Bootstrapping](#background-bootstrapping)
  + [6.4.2. Implementing DAOs Based on JPA: EntityManagerFactory and EntityManager](#642-implementing-daos-based-on-jpa-entitymanagerfactory-and-entitymanager)
  + [6.4.3. Spring-driven JPA transactions](#643-spring-driven-jpa-transactions)
  + [6.4.4. Understanding JpaDialect and JpaVendorAdapter](#644-understanding-jpadialect-and-jpavendoradapter)
  + [6.4.5. Setting up JPA with JTA Transaction Management](#645-setting-up-jpa-with-jta-transaction-management)
  + [6.4.6. Native Hibernate Setup and Native Hibernate Transactions for JPA Interaction](#646-native-hibernate-setup-and-native-hibernate-transactions-for-jpa-interaction)

---

이번 섹션에선 ORM(Object Relational Mapping) 기술을 사용해 데이터에 접근하는 방법을 다룬다.

---

## 6.1. Introduction to ORM with Spring

스프링 프레임워크는 JPA(Java Persistence API)를 통합 지원하며, 네이티브 하이버네이트에서도 스프링을 통해 리소스를 관리하고, 데이터 접근 객체(DAO)를 구현하고, 트랜잭션 전략을 적용할 수 있다. 예를 들어 하이버네이트에선 편리한 IoC 기능 몇 가지를 더해 대표적인 하이버네이트 통합 문제들을 해결해준다. OR(object relational) 매핑 툴에서 쓸 기능은 전부 의존성 주입으로 설정할 수 있다. 지원 클래스들은 스프링이 관리하는 리소스와 트랜잭션을 활용할 수 있으며, 스프링의 범용 트랜잭션과 DAO 예외 계층을 준수한다. 순수 하이버네이트나 JPA API를 노출하기 보단 DAO로 감싸 통합하는 방법을 추천한다.

데이터에 접근하는 어플리케이션은 스프링으로 개발하면 ORM 레이어를 훨씬 더 개선할 수 있다. 스프링 통합 지원은 원하는 만큼 활용할 수 있으며, 통합에 드는 비용은 사내에서 유사한 자체 인프라를 구축하는 데 드는 비용과 리스크를 비교해보면 훨씬 적다. 모든 것을 재사용 가능한 자바빈으로 설계했기 때문에, 기술에 관계없이 ORM 기능 대부분을 라이브러리를 쓰듯이 사용할 수 있다. 스프링 IoC 컨테이너를 사용하면 ORM 설정도 배포도 쉬워진다. 따라서 이 섹션에서 보여주는 예제 대부분은 스프링 컨테이너 설정이다.

스프링 프레임워크를 사용해서 ORM DAO를 만들면 다음과 같은 혜택이 따라온다:

- **더 쉬운 테스트.** 스프링의 IoC에서는 하이버네이트 `SessionFactory` 인스턴스와, JDBC `DataSource` 인스턴스, 트랜잭션 매니저나, 필요하면 매핑한 객체까지도 구현체와 설정 위치를 쉽게 교체할 수 있다. 덕분에 각 persistence 관련 코드를 따로 떼어내 테스트하기가 훨씬 쉽다.
- **공통 데이터 접근 예외.** 스프링은 ORM 툴마다 다른 예외(checked exception일 수도 있는)를 래핑해서 공통 런타임 `DataAccessException` 계층 구조로 변환할 수 있다. 덕분에 대부분 복구가 불가능한 persistence 예외 때문에 DAO에서 번거롭게 보일러플레이트 catch-and-throw 블록을 선언할 필요 없이, 적절한 레이어에서만 예외를 처리할 수 있다. 물론 필요하다면 예외를 잡아 처리해도 되긴한다. JDBC 예외(DB 전용 dialect 포함)도 동일한 계층 구조로 변환되므로, JDBC 연산도 일관적인 프로그래밍 모델로 실행할 수 있다는 점을 기억해두자.
- **범용적인 리소스 관리.** 스프링 어플리케이션 컨텍스트는 하이버네이트 `SessionFactory` 인스턴스와, JPA `EntityManagerFactory` 인스턴스, JDBC `DataSource` 인스턴스와 기타 관련 리소스들의 위치와 설정을 적절히 처리할 수 있다. 따라서 위치와 설정을 쉽게 관리하고 변경할 수 있다. 스프링은 persistence 리소스를 효율적이면서 쉽고, 안전하게 처리해준다. 예를 들어, 하이버네이트를 사용하는 관련 코드에서는 보통 동일한 하이버네이트 `Session`을 사용해야 효율적으로 동작하고 적절한 트랜잭션 처리를 보장할 수 있다. 스프링에선 하이버네이트 `SessionFactory`에서 현재 `Session`을 가져와서, 쉽고 투명하게 `Session`을 만들고 현재 스레드에 바인딩한다. 따라서 스프링을 사용하면 로컬 트랜잭션 환경이나 JTA 트랜잭션 환경에서 `Hibernate`를 사용할 때 겪는 많은 만성적인 문제가 해결된다.
- **트랜잭션 관리 통합.** ORM 코드는 선언적인 AOP(Aspect-Oriented Programming) 스타일 메소드 인터셉터로 감쌀 수 있다. 이때는 `@Transactional` 어노테이션을 선언하거나 XML 설정 파일에 트랜잭션 AOP 어드바이스를 명시하면 된다. 두 방법 모두 트랜잭션 시맨틱스와 예외 처리(롤백 등)를 대신해준다. 트랜잭션 매니저는 [리소스와 트랜잭션 관리](#621-resource-and-transaction-management)에서 설명하는대로, ORM 관련 코드에 영향을 주지 않고도 여러 가지를 교체할 수 있다. 예를 들어, 서비스(선언적인 트랜잭션 등)는 모두 동일하게 두고, 로컬 트랜잭션과 JTA를 번갈아가며 사용해볼 수 있다. 게다가 JDBC 관련 코드에서 필요한 트랜잭션은 ORM에 사용하는 코드와 완전히 통합할 수 있다. ORM엔 적합하지 않은(배치 처리나 BLOB 스트리밍같은) 데이터에 접근할 때도 ORM 연산과 트랜잭션을 공유할 수 있다.

> MongoDB 등의 다른 데이터베이스 기술 지원이나, 다른 포괄적인 ORM 기능은 스프링 데이터 프로젝트 제품군을 확인하는 게 좋다. JPA 사용자라면 [https://spring.io](https://spring.io) 가이드에서 소개하는 [JPA로 데이터 접근 시작하기](https://spring.io/guides/gs/accessing-data-jpa/)가 도움이 될 거다.

---

## 6.2. General ORM Integration Considerations

이번 섹션에선 모든 ORM 기술에서 고려해야 할 점을 정리한다. 더 자세한 정보는 [하이버네이트](#63-hibernate) 섹션에서 제공하며, 이때는 기능과 설정을 구체적으로 보여준다.

스프링의 ORM 통합의 주요 목표는 어플리케이션 계층을 명확히 나누고 (모든 데이터 접근, 트랜잭션 기술 포함), 어플리케이션 결합도를 낮추는 거다 — 비지니스 서비스는 더 이상 데이터 접근 전략이나 트랜잭션 전략에 대한 의존성이 없으며, 리소스 조회 로직을 하드 코딩하는 일이나, 교체하기 어려운 싱글톤과 커스텀 서비스 레지스트리를 만드는 일은 없다. 목표는 간단하면서 통일된 방법으로 어플리케이션 객체를 연결해, 객체를 가능한한 재사용할 수 있게 만들고 컨테이너 의존성을 없애는 거다. 데이터 접근 기능은 모두 자체적으로 사용할 수 있긴 하지만, 스프링의 어플리케이션 컨텍스트 개념과 잘 통합하면, XML 기반으로 굳이 스프링을 인식할 필요가 없는 일반 자바빈 인스턴스를 설정할 수 있으며, 이 인스턴스들을 상호 참조할 수 있다. 전형적인 스프링 어플리케이션이라면 주요 객체가 대부분 자바빈일 거다 (데이터 접근 템플릿, 데이터 접근 객체, 트랜잭션 매니저, 데이터 접근 객체와 트랜잭션 매니저를 사용하는 비즈니스 서비스, 웹 뷰 리졸버, 비즈니스 서비스를 사용하는 웹 컨트롤러 등).

### 6.2.1. Resource and Transaction Management

비즈니스 어플리케이션에 리소스 관리 코드를 여기저기 반복하면 지저분해지기 마련이다. 많은 프로젝트가 자체 솔루션 시도하고 있으며, 간혹 코드 상의 편의를 위해 제대로된 오류 처리를 포기하기도 한다. 스프링은 적절히 리소스를 처리할 수 있는 간단한 솔루션을 내세우고 있다. 예를 들어 JDBC에선 템플릿화를 통해 IoC를 적용하고, ORM 기술엔 AOP 인터셉터를 적용한다.

스프링 인프라는 리소스를 적절하게 처리해주며, API 전용 예외를 적절한 전용 unchecked 예외 계층 구조로 변환해준다. 스프링이 도입한 예외 계층 구조는 모든 데이터 접근 전략에 적용할 수 있다. 직접 JDBC를 사용할 땐, [이전 섹션](../dataaccesswithjdbc#331-using-jdbctemplate)에서 언급한 `JdbcTemplate` 클래스가 커넥션을 처리하고 `SQLException`을 `DataAccessException` 계층 구조로 적절하게 변환한다. 이때는 데이터베이스 전용 SQL 에러 코드를 유의미한 예외 클래스로 변환한다. ORM 기술에서도 똑같이 예외 전환 기능을 활용하는 방법은 [다음 섹션](#622-exception-translation)을 참고해라.

트랜잭션 관리와 관련해서는, `JdbcTemplate` 클래스는 스프링 트랜잭션 지원과 맞물려서 JTA와 JDBC 트랜잭션 모두 각 스프링 트랜잭션 매니저를 통해 지원한다. ORM 기술에서는, 스프링은 하이버네이트 매니저, JPA 트랜잭션 매니저를 통해 하이버네이트와 JPA를 지원하며, JTA 또한 가능하다. 트랜잭션 지원에 대한 자세한 내용은 [트랜잭션 관리](../transactionmanagement) 챕터를 참고해라.

### 6.2.2. Exception Translation

DAO에서 하이버네이트나 JPA를 사용하려면 어떻게 persistence 기술에 있는 네이티브 예외 클래스를 처리할지 정해야 한다. DAO는 사용한 persistence 기술에 따라 `HibernateException`이나 `PersistenceException`의 하위 클래스를 던질 거다. 이 클래스들은 모두 런타임 예외라서 선언하거나 캐치하지 않아도 된다. 던져진 런타임 예외 중에는 `IllegalArgumentException`이나 `IllegalStateException`도 있을 수 있다. 이게 무슨말이냐 하면, DAO를 호출한 쪽에서 persistence 기술 전용 예외 구조를 일일히 잡아 처리할 게 아니라면, 예외 타입을 알아 낼 길이 없어서 모든 예외를 일반적인 치명적인 예외로 처리할 수밖에 없다는 말이다. 호출부를 구현체 전략과 묶지 않으면 원인(낙관적 잠금 실패같은)을 특정하기 어렵다. 완전한 ORM 기반 어플리케이션을 만들거나 특별한 예외 처리가 전혀 필요 없다면 (아니면 둘 다거나) 딱히 상관 없을 수도 있다. 그러나 스프링은 `@Repository` 어노테이션을 통해 투명하게 예외를 전환해준다. 설정 방법은 다음을 참고해라 (하나는 자바 설정이고, 다른 하나는 XML 설정이다):

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
@Repository
public class ProductDaoImpl implements ProductDao {

    // class body here...

}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
@Repository
class ProductDaoImpl : ProductDao {
    // class body here...
}
```

```xml
<beans>

    <!-- Exception translation bean post processor -->
    <bean class="org.springframework.dao.annotation.PersistenceExceptionTranslationPostProcessor"/>

    <bean id="myProductDao" class="product.ProductDaoImpl"/>

</beans>
```

postprocessor는 자동으로 exception translator(`PersistenceExceptionTranslator` 인터페이스 구현체)를 전부 찾아, `@Repository` 어노테이션으로 마킹한 모든 빈에 어드바이스를 적용한다. 덕분에 translator는 던져진 예외를 인터셉트해가 적절히 변환할 수 있다.

요약하면, 일반 persistence 기술 API를 사용해 DAO를 구현하더라도, 어노테이션을 선언하면 스프링이 관리하는 트랜잭션, 의존성 주입을 이용할 수 있으며, 원한다면 예외를 투명하게 스프링의 커스텀 예외 계층 구조로 변환할 수도 있다.

---

## 6.3. Hibernate

스프링 환경에서 [하이버네이트 5](https://hibernate.org/)를 다루는 것부터 시작해서 스프링이 OR 매퍼를 통합하는 방식을 보여주겠다. 이번 섹션에선 여러 가지 방법으로 구현한 DAO 구현체와 트랜잭션 경계를 좀 더 자세히 다룬다. 여기에서 보여주는 패턴은 대부분 지원하는 다른 ORM 툴에도 그대로 적용할 수 있다. 다른 ORM 기술은 이 챕터 뒷부분에서 간단한 예제와 함께 설명하겠다.

> 스프링 프레임워크 5.3을 기준으로 스프링은, 네이티브 하이버네이트 `SessionFactory` 세팅과 스프링의 `HibernateJpaVendorAdapter`에 하이버네이트 ORM 5.2 이상이 필요하다. 어플리케이션을 새로 만들고 있다면 하이버네이트 ORM 5.4를 강력하게 추천한다. `HibernateJpaVendorAdapter`를 함께 사용하려면 하이버네이트 Search를 5.11.6으로 올려야 한다.

### 6.3.1. `SessionFactory` Setup in a Spring Container

하이버네이트 `SessionFactory`나 JDBC `DataSource`같은 리소스를 스프링 컨테이너의 빈으로 정의하면, 리소스를 조회하는 코드를 하드코딩하지 않아도 된다. 빈으로 정의한 어플리케이션 객체는 [다음 섹션](#632-implementing-daos-based-on-the-plain-hibernate-api)에 있는 DAO 정의에서 보이듯이, 미리 정의해둔 빈 인스턴스 참조를 주입받아 리소스에 접근할 수 있다.

다음 설정은 XML 어플리케이션 컨텍스트 정의 일부인데, JDBC `DataSource`를 세팅하고 그 위에 하이버네이트 `SessionFactory`를 설정하는 방법을 보여준다:

```xml
<beans>

    <bean id="myDataSource" class="org.apache.commons.dbcp.BasicDataSource" destroy-method="close">
        <property name="driverClassName" value="org.hsqldb.jdbcDriver"/>
        <property name="url" value="jdbc:hsqldb:hsql://localhost:9001"/>
        <property name="username" value="sa"/>
        <property name="password" value=""/>
    </bean>

    <bean id="mySessionFactory" class="org.springframework.orm.hibernate5.LocalSessionFactoryBean">
        <property name="dataSource" ref="myDataSource"/>
        <property name="mappingResources">
            <list>
                <value>product.hbm.xml</value>
            </list>
        </property>
        <property name="hibernateProperties">
            <value>
                hibernate.dialect=org.hibernate.dialect.HSQLDialect
            </value>
        </property>
    </bean>

</beans>
```

로컬 자카르타 Commons DBCP `BasicDataSource`는 다음 예제처럼 설정만으로 JNDI에 있는 `DataSource`(보통은 어플리케이션 서버에서 관리하는)로 전환할 수 있다:

```xml
<beans>
    <jee:jndi-lookup id="myDataSource" jndi-name="java:comp/env/jdbc/myds"/>
</beans>
```

`JndiObjectFactoryBean` / `<jee:jndi-lookup>`을 사용하면 JNDI에 있는 `SessionFactory`에 접근할 수도 있다. 단, 일반적으로는 `SessionFactory`를 EJB 컨텍스트 밖으로 노출하지 않는다.

> 스프링은 `LocalSessionFactoryBuilder`도 제공하는데, 이 빌더는 `@Bean` 설정 스타일이나 프로그래밍 방식 설정과 매끄럽게 통합된다 (`FactoryBean`은 관여하지 않음).
>
> `LocalSessionFactoryBean`과 `LocalSessionFactoryBuilder` 모두 백그라운드 부트스트랩을 지원한다. 부트스트랩 executor(`SimpleAsyncTaskExecutor` 등)를 받아 어플리케이션 부트스트랩 스레드와 동시에 하이버네이트 초기화를 진행한다. `LocalSessionFactoryBean`에선 `bootstrapExecutor` 프로퍼티로 executor를 지정할 수 있다. 프로그래밍 방식을 사용하는 `LocalSessionFactoryBuilder`는 부트스트랩 executor 인자를 받는 `buildSessionFactory` 메소드를 오버로드하고 있다.
>
> 스프링 프레임워크 5.1기준으로, 이런 네이티브 하이버네이트 설정을 사용하면 네이티브 하이버네이트 방식 외 표준 JPA 방식으로도 상호작용하기 위해 JPA `EntityManagerFactory`를 노출할 수도 있다. 자세한 내용은 [JPA를 위한 네이티브 하이버네이트 설정](#646-native-hibernate-setup-and-native-hibernate-transactions-for-jpa-interaction)을 참고해라.

### 6.3.2. Implementing DAOs Based on the Plain Hibernate API

하이버네이트에는 컨텍스트 세션이라는 기능이 있다. 하이버네이트 자체는 트랜잭션 당 현재 `Session` 하나를 관리한다. 스프링이 트랜잭션 당 하이버네이트 `Session` 하나를 동기화하는 것과 대략 일치한다. 순수 하이버네이트 API를 기반으로 만든 DAO 구현체는 다음 예제와 유사할 거다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
public class ProductDaoImpl implements ProductDao {

    private SessionFactory sessionFactory;

    public void setSessionFactory(SessionFactory sessionFactory) {
        this.sessionFactory = sessionFactory;
    }

    public Collection loadProductsByCategory(String category) {
        return this.sessionFactory.getCurrentSession()
                .createQuery("from test.Product product where product.category=?")
                .setParameter(0, category)
                .list();
    }
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
class ProductDaoImpl(private val sessionFactory: SessionFactory) : ProductDao {

    fun loadProductsByCategory(category: String): Collection<*> {
        return sessionFactory.currentSession
                .createQuery("from test.Product product where product.category=?")
                .setParameter(0, category)
                .list()
    }
}
```

이 코드는 인스턴스 변수에 `SessionFactory`를 가지고 있는 것만 빼면 하이버네이트 레퍼런스 문서에 있는 예제와 비슷하다. 하이버네이트의 CaveatEmptor 샘플 어플리케이션에선 이전 방식 `HibernateUtil` `static` 클래스를 사용하지만, `static` 클래스를 쓰기보단 인스턴스 기반 등의 설정을 권한다. (절대적으로 필요한 게 아니라면 웬만해선 리소스를 `static` 변수에 보관하지 마라.)

앞에 있는 DAO 예제는 의존성을 주입할 수 있는 패턴을 사용했다. 이 DAO도 스프링의 `HibernateTemplate`기반으로 만들었을 때와 마찬가지로 스프링 IoC 컨테이너와 잘 들어맞는다. 이 DAO는 순수한 자바 코드로도 만들 수 있다 (예를 들어 단위 테스트에서). 인스턴스를 만들고 `setSessionFactory(..)`로 원하는 팩토리를 전달하면 된다. DAO를 스프링 빈으로 정의할 땐 다음과 같이 설정하면 된다:

```xml
<beans>

    <bean id="myProductDao" class="product.ProductDaoImpl">
        <property name="sessionFactory" ref="mySessionFactory"/>
    </bean>

</beans>
```

이 스타일로 DAO를 만들었을 때 가장 좋은 점은 하이버네이트 API에만 의존할 수 있다는 거다. 스프링 클래스는 임포트하지 않아도 된다. 외부 의존성이 코드를 침범하지 않는다는 점에서 매력적이며, 하이버네이트 개발자라면 더 자연스럽게 느껴질 거다.

단, 이 DAO는 일반 `HibernateException`을 그대로 던진다. 이 클래스는 unchecked exception이라서 선언하거나 캐치하지 않아도 된다. 그렇기 때문에 DAO를 호출한 쪽에서 persistence 기술 전용 예외 구조를 일일히 잡아 처리할 게 아니라면, 예외 타입을 알아 낼 길이 없어서 모든 예외를 일반적인 치명적인 예외로 처리할 수밖에 없다. 물론, 완전한 ORM 기반 어플리케이션을 만들거나 특별한 예외 처리가 전혀 필요 없다면 (아니면 둘 다거나) 딱히 상관 없을 수도 있다.

다행히도 스프링의 `LocalSessionFactoryBean`을 사용하면 `SessionFactory.getCurrentSession()` 메소드에도 모든 스프링 트랜잭션 전략을 적용할 수 있으며, 현재 스프링이 관리하는 트랜잭션 `Session`을 반환한다. `HibernateTransactionManager`를 사용하더라도 마찬가지다. 진행중인 JTA 트랜잭션이 있으면 이와 연관된 현재 `Session`을 반환하는 표준 동작은 변하지 않는다. 이 동작은 스프링의 `JtaTransactionManager`나, EJB 컨테이너가 관리하는 트랜잭션(CMT), JTA 사용 여부와는 관계없이 적용된다.

요약하면, 평범한 하이버네이트 API를 기반으로 DAO를 구현해도 스프링이 관리하는 트랜잭션에 참여할 수 있다.

### 6.3.3. Declarative Transaction Demarcation

트랜잭션이 필요하다면, 스프링의 선언적 트랜잭션을 활용하는 게 좋다. 선언적 트랜잭션을 사용하면 자바 코드에서 직접 트랜잭션 경계 API 호출하는 대신, AOP 트랜잭션 인터셉터를 활용할 수 있다. 트랜잭션 인터셉터는 자바 어노테이션이나 XML로 스프링 컨테이너에 설정하면 된다. 이 기능을 사용하면 비지니스 서비스에서 매번 트랜잭션 경계 코드를 만들지 않아도 되고, 어플리케이션의 실제 가치인 비즈니스 로직을 추가하는 데 더 집중할 수 있다.

> 계속하기 전에 [선언적인 트랜잭션 관리](../transactionmanagement#14-declarative-transaction-management)를 아직 읽어보지 않았다면 읽고 오길 권한다.

서비스 레이어에 `@Transactional` 어노테이션을 달면, 스프링 컨테이너가 이 어노테이션을 찾아 해당 메소드에 트랜잭션 시맨틱스를 제공한다. 방법은 다음 예제를 참고해라:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
public class ProductServiceImpl implements ProductService {

    private ProductDao productDao;

    public void setProductDao(ProductDao productDao) {
        this.productDao = productDao;
    }

    @Transactional
    public void increasePriceOfAllProductsInCategory(final String category) {
        List productsToChange = this.productDao.loadProductsByCategory(category);
        // ...
    }

    @Transactional(readOnly = true)
    public List<Product> findAllProducts() {
        return this.productDao.findAllProducts();
    }
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
class ProductServiceImpl(private val productDao: ProductDao) : ProductService {

    @Transactional
    fun increasePriceOfAllProductsInCategory(category: String) {
        val productsToChange = productDao.loadProductsByCategory(category)
        // ...
    }

    @Transactional(readOnly = true)
    fun findAllProducts() = productDao.findAllProducts()
}
```

런타임에 `@Transactional`을 처리하려면 컨테이너에 `<tx:annotation-driven/>` 엔트리와 `PlatformTransactionManager` 구현체(빈으로)를 설정해야 한다. 방법은 다음 예제를 참고해라:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:aop="http://www.springframework.org/schema/aop"
    xmlns:tx="http://www.springframework.org/schema/tx"
    xsi:schemaLocation="
        http://www.springframework.org/schema/beans
        https://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/tx
        https://www.springframework.org/schema/tx/spring-tx.xsd
        http://www.springframework.org/schema/aop
        https://www.springframework.org/schema/aop/spring-aop.xsd">

    <!-- SessionFactory, DataSource, etc. omitted -->

    <bean id="transactionManager"
            class="org.springframework.orm.hibernate5.HibernateTransactionManager">
        <property name="sessionFactory" ref="sessionFactory"/>
    </bean>

    <tx:annotation-driven/>

    <bean id="myProductService" class="product.SimpleProductService">
        <property name="productDao" ref="myProductDao"/>
    </bean>

</beans>
```

### 6.3.4. Programmatic Transaction Demarcation

내부에서 데이터에 접근하는 연산이 아무리 많더라도, 어플리케이션 상위 레벨에서 트랜잭션 경계를 정할 수 있다. 비즈니스 서비스를 둘러싼 구현체가 많아도 상관 없다. 필요한 건 스프링 `PlatformTransactionManager` 뿐이다. 다시 말하지만, `PlatformTransactionManager`는 어디에서나 설정할 수 있지만, 가급적이면 `setTransactionManager(..)` 메소드로 빈 참조를 주입하는 게 좋다. 똑같이 `productDAO`도 `setProductDao(..)` 메소드로 설정하는 게 좋다. 다음은 스프링 어플리케이션 컨텍스트의 트랜잭션 매니저, 비즈니스 서비스 정의와, 비즈니스 메소드 구현체 예시다:

```xml
<beans>

    <bean id="myTxManager" class="org.springframework.orm.hibernate5.HibernateTransactionManager">
        <property name="sessionFactory" ref="mySessionFactory"/>
    </bean>

    <bean id="myProductService" class="product.ProductServiceImpl">
        <property name="transactionManager" ref="myTxManager"/>
        <property name="productDao" ref="myProductDao"/>
    </bean>

</beans>
```

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
public class ProductServiceImpl implements ProductService {

    private TransactionTemplate transactionTemplate;
    private ProductDao productDao;

    public void setTransactionManager(PlatformTransactionManager transactionManager) {
        this.transactionTemplate = new TransactionTemplate(transactionManager);
    }

    public void setProductDao(ProductDao productDao) {
        this.productDao = productDao;
    }

    public void increasePriceOfAllProductsInCategory(final String category) {
        this.transactionTemplate.execute(new TransactionCallbackWithoutResult() {
            public void doInTransactionWithoutResult(TransactionStatus status) {
                List productsToChange = this.productDao.loadProductsByCategory(category);
                // do the price increase...
            }
        });
    }
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
class ProductServiceImpl(transactionManager: PlatformTransactionManager,
                        private val productDao: ProductDao) : ProductService {

    private val transactionTemplate = TransactionTemplate(transactionManager)

    fun increasePriceOfAllProductsInCategory(category: String) {
        transactionTemplate.execute {
            val productsToChange = productDao.loadProductsByCategory(category)
            // do the price increase...
        }
    }
}
```

스프링의 `TransactionInterceptor`를 사용하면 콜백 코드로 모든 checked exception을 던질 수 있지만, `TransactionTemplate`의 콜백 내에선 unchecked 예외만 던질 수 있다. `TransactionTemplate`은 unchecked exception을 만나거나, 어플리케이션이 트랜잭션을 롤백 전용으로 마킹했을 때(`TransactionStatus`로 설정) 롤백을 트리거한다. 기본적으로 `TransactionInterceptor`도 동일하게 동작하지만, 메소드별로 롤백 정책을 따로 설정할 수 있다.

### 6.3.5. Transaction Management Strategies

하이버네이트 어플리케이션에선, `TransactionTemplate`과 `TransactionInterceptor` 모두 실제 트랜잭션 처리는 `PlatformTransactionManager` 인스턴스나 `JtaTransactionManager`에 위임한다. `PlatformTransactionManager`는 내부에서 `ThreadLocal` `Session`을 사용하는 하이버네이트의 단일 `SessionFactory` 전용 구현체 `HibernateTransactionManager`일 수 있고, `JtaTransactionManager`는 컨테이너의 JTA 하위 시스템에 위임한다. 커스텀 `PlatformTransactionManager` 구현체도 사용할 수 있다. 네이티브 하이버네이트로 관리하던 트랜잭션을 JTA로 전환할 땐 설정만 바꾸면 된다 (어플리케이션에 분산 트랜잭션이 필요해졌을 때 등). 하이버네이트 트랜잭션 매니저를 스프링의 JTA 트랜잭션 구현체로 바꾸면 된다. 트랜잭션 경계와 데이터에 접근하는 코드는 범용 트랜잭션 관리 API를 사용하기 때문에 변경하지 않아도 잘 동작한다.

하이버네이트 세션 팩토리 여러 개에 걸친 분산 트랜잭션이 필요할 땐, `JtaTransactionManager`를 트랜잭션 전략으로 사용해 `LocalSessionFactoryBean` 정의를 여러 개 결합할 수 있다. 그런 다음 DAO마다 특정 `SessionFactory` 빈 하나를 프로퍼티로 전달하면 된다. 내부 JDBC 데이터소스가 모두 트랜잭션 컨테이너의 데이터소스라면, `JtaTransactionManager`를 트랜잭션 전략으로 사용하기만 하면 비즈니스 서비스는 특별한 코드 없이도 원하는 만큼의 DAO, 세션 팩토리에 걸친 트랜잭션 경계를 정의할 수 있다.

`HibernateTransactionManager`와 `JtaTransactionManager`는 모두 컨테이너 전용 트랜잭션 매니저나 JCA 커넥터를 통하지 않아도 (트랜잭션 초기화에 EJB를 사용하지 않는다면) 하이버네이트로 적절한 JVM 레벨 캐시를 처리할 수 있다.

`HibernateTransactionManager`는 하이버네이트 JDBC `Connection`을 특정 `DataSource`에 접근하는 순수 JDBC 코드에도 전달할 수 있다. 데이터베이스 하나에만 접근한다면, 이 기능을 통해 JTA 없이도 고수준 트랜잭션 경계를 만들어 하이버네이트와 JDBC 데이터 접근 코드를 함께 사용할 수 있다. `SessionFactory`를 만들 때 사용한  `LocalSessionFactoryBean` 클래스의 `dataSource` 프로퍼티로 `DataSource`를 설정했다면, `HibernateTransactionManager`는 자동으로 하이버네이트 트랜잭션을 JDBC 트랜잭션으로 노출한다. 아니면 `HibernateTransactionManager` 클래스의 `dataSource` 프로퍼티에 트랜잭션을 노출할 `DataSource`를 직접 지정해도 된다.

### 6.3.6. Comparing Container-managed and Locally Defined Resources

`SessionFactory`는 컨테이너가 관리하는 JNDI를 사용할 수도 있고, 로컬에 정의할 수도 있다. 두 가지 방법은 어플리케이션 코드를 단 한 줄도 변경하지 않고도 전환할 수 있다. 리소스 정의를 컨테이너에 보관할지 어플리케이션 내에서 로컬로 보관할지는 주로 트랜잭션 전략에 따라 갈린다. 스프링으로 정의한 로컬 `SessionFactory`와 비교했을 때 수동으로 등록하는 JNDI `SessionFactory`는 딱히 더 나은 점이 없다. 하이버네이트의 JCA 커넥터를 통해 `SessionFactory`를 배포하면 자바 EE 서버의 관리 인프라에 참여할 수는 있지만, 그 이상의 실질적인 가치를 더하진 않는다.

스프링의 트랜잭션 기능은 컨테이너에 묶여있지 않다. JTA 외 다른 전략을 설정하면 트랜잭션은 컨테이너 없이 실행해도, 테스트 환경에서도 동작한다. 특히 전형적인 단일 데이터베이스 트랜잭션이라면, 스프링의 단일 리소스 로컬 트랜잭션은 JTA를 대신할 수 있는 가벼우면서도 효과적인 솔루션이다. 로컬 EJB의 stateless 세션 빈으로 트랜잭션을 구동한다면, 아무리 단일 데이터베이스에만 접근하고 stateless 세션 빈만 사용해 컨테이너가 관리하는 선언적인 트랜잭션을 제공하더라도, EJB 컨테이너와 JTA 둘다에 의존할 수밖에 없다. 게다가 코드에서 직접 JTA를 사용하려면 자바 EE 환경도 필요하다. JTA는 JTA 자체에서도, JNDI `DataSource` 인스턴스에서도 컨테이너 의존성만 가지고 있진 않다. 스프링이 아닌 JTA 기반 하이버네이트 트랜잭션에선, JVM 레벨 캐시를 처리하려면 `TransactionManagerLookup`을 설정하고, 하이버네이트 JCA 커넥터나 다른 하이버네이트 트랜잭션 코드를 사용해야 한다.

단일 데이터베이스에 접근한다면 스프링 기반 트랜잭션은, 로컬 JDBC `DataSource`에서 그러하듯, 하이버네이트 `SessionFactory`를 로컬에 정의했을 때도 잘 동작한다. 따라서 분산 트랜잭션이 필요해지면 그때가서 스프링의 JTA 트랜잭션 전략으로만 변경하면 된다. JCA 커넥터는 컨테이너 전용 배포 스텝이 필요하고, (명백히) JCA 지원이 우선되야 한다. 이 구조는 로컬에 리소스를 정의하고 스프링 기반 트랜잭션으로 간단한 웹 어플리케이션을 배포할 때보다 손이 더 많이 간다. 게다가 JCA를 제공하지 않는 WebLogic Express를 사용하는 경우 등 컨테이너의 엔터프라이즈 에디션이 필요한 경우가 종종 있다. 로컬 리소스와 단일 데이터베이스에 걸친 트랜잭션을 사용하는 스프링 어플리케이션은 Tomcat이나 Resin, 순수 Jetty같은 모든 Java EE 웹 컨테이너에서 잘 동작한다 (JTA, JCA, EJB 없이). 더불어 데스크톱 어플리케이션이나 테스트 스위트(suite)에서도 이런 미들 티어를 쉽게 재사용할 수 있다.

EJB를 사용하지 않는다면, 모든 것들을 고려해봤을 때 로컬 `SessionFactory` 설정을 고수하고 스프링의 `HibernateTransactionManager`나 `JtaTransactionManager`를 사용하는 게 좋다. 그러면 컨테이너를 별도로 배포하지 않고도, 적절한 트랜잭션 JVM 레벨 캐싱과 분산 트랜잭션을 포함한 모든 것을 누릴 수 있다. JCA 커넥터를 통해 JNDI에 하이버네이트 `SessionFactory`를 등록하는 건 EJB를 사용할 때만 가치 있다.

### 6.3.7. Spurious Application Server Warnings with Hibernate

매우 엄격한 `XADataSource` 구현체(현재 일부 WebLogic Server, WebSphere 버전)를 사용하는 일부 JTA 환경에선, 하이버네이트를 JTA 환경용 JTA 트랜잭션 매니저와 연결해주지 않으면 어플리케이션 서버 로그에 실제 상황과는 다른 경고 메세지나 예외가 남을 수 있다. 이 메세지는 트랜잭션이 더 이상 활성 상태가 아니라는 등의 이유로 접근 중인 커넥션이나 JDBC 접근이 더 이상 유효하지 않다고 말한다. 다음은 WebLogic에서 실제로 볼 수 있는 예외다:

```java
java.sql.SQLException: The transaction is no longer active - status: 'Committed'. No
further JDBC access is allowed within this transaction.
```

또 다르게는, JTA 트랜잭션을 사용하고 나서 하이버네이트 세션(그리고 내부 JDBC 커넥션까지도)을 제대로 닫지 않아서 커넥션 누수가 발생하는 일도 흔하다.

이런 문제는 하이버네이트가 (스프링이) 동기화할 JTA 트랜잭션 매니저를 인식하게 만들면 해결된다. 여기에는 두 가지 옵션이 있다:

- 스프링 `JtaTransactionManager` 빈을 하이버네이트 설정에 전달해라. 가장 쉬운 방법은 `LocalSessionFactoryBean` 빈의 `jtaTransactionManager` 프로퍼티로 빈을 참조시키는 거다 ([하이버네이트 트랜잭션 설정](../transactionmanagement#121-hibernate-transaction-setup)) 참고). 이렇게하면 스프링이 하이버네이트에서도 해당 JTA 전략을 사용할 수 있게 만든다.
- `LocalSessionFactoryBean`의 "hibernateProperties" 프로퍼티에 하이버네이트의 JTA 관련 프로퍼티를 명시하는 방법도 있다. 예를 들어, "hibernate.transaction.coordinator_class", "hibernate.connection.handling_mode"를, 필요하면 "hibernate.transaction.jta.platform"까지도 설정할 수 있다 (프로퍼티에 대한 자세한 설명은 하이버네이트 매뉴얼 참고).

남은 섹션에선 하이버네이트가 JTA `PlatformTransactionManager`를 인식할 때와 인식하지 못할 때 발생하는 순차적인 이벤트를 설명한다.

하이버네이트가 JTA 트랜잭션 매니저를 인식할 수 있을만한 설정이 없으면, JTA 트랜잭션을 커밋했을 때 다음과 같은 이벤트가 발생한다:

- JTA 트랜잭션을 커밋한다.
- 스프링의 `JtaTransactionManager`는 JTA 트랜잭션에 동기화되기 때문에, JTA 트랜잭션 매니저에 의해 `afterCompletion` 콜백이 호출된다.
- 무엇보다도 이 동기화로 인해 스프링이 하이버네이트의 `afterTransactionCompletion` 콜백(하이버네이트 캐시를 지우는 데 사용함)을 트리거할 수 있으며, 이렇게 되면 하이버네이트 세션에서 `close()`를 명시적으로 호출하고, 그에 따라 JDBC 커넥션 `close()`를 시도하게 된다.
- 일부 환경에선, 트랜잭션이 이미 커밋되었기 때문에 이때 `Connection.close()`을  호출하면 어플리케이션 서버가 더 이상 `Connection`을 사용할 수 없는 것으로 간주하고 경고나 에러를 트리거한다.

하이버네이트가 JTA 트랜잭션 매니저를 인식할 수 있는 설정이 있으면, JTA 트랜잭션을 커밋했을 때 다음과 같은 이벤트가 발생한다:

- JTA 트랜잭션을 커밋할 준비를 마친다.
- 스프링의 `JtaTransactionManager`는 JTA 트랜잭션에 동기화되기 때문에, JTA 트랜잭션 매니저에 의해 트랜잭션의 `beforeCompletion` 콜백이 호출된다.
- 스프링은 하이버네이트 자체는 JTA 트랜잭션에 동기화되는 것을 알고 있으며, 이전 시나리오와 다르게 동작한다. 특히, 이번에는 하이버네이트의 트랜잭션 리소스 관리와 방향이 맞게 처리한다.
- JTA 트랜잭션을 커밋한다.
- 하이버네이트는 JTA 트랜잭션에 동기화되었기 때문에, JTA 트랜잭션 매니저에 의해 트랜잭션 `afterCompletion` 콜백이 호출되고 캐시를 적절히 지울 수 있다.

---

## 6.4. JPA

스프링 JPA는 `org.springframework.orm.jpa` 패키지에 있으며, [Java Persistence API](https://www.oracle.com/technetwork/articles/javaee/jpa-137156.html)를 포괄적으로 지원한다. 지원 방식은 하이버네이트를 통합할 때와 유사하며, 내부 구현체를 인식해 추가 기능을 제공한다.

### 6.4.1. Three Options for JPA Setup in a Spring Environment

어플리케이션에서 엔티티 매니저를 가져올 땐 JPA `EntityManagerFactory`를 사용한다. 스프링 JPA에선 세 가지 방법으로 `EntityManagerFactory`를 설정할 수 있다.

- [`LocalEntityManagerFactoryBean` 사용하기](#using-localentitymanagerfactorybean)
- [JNDI에서 EntityManagerFactory 가져오기](#obtaining-an-entitymanagerfactory-from-jndi)
- [`LocalContainerEntityManagerFactoryBean` 사용하기](#using-localcontainerentitymanagerfactorybean)

#### Using `LocalEntityManagerFactoryBean`

이 옵션은 독립 실행형 어플리케이션이나 통합 테스트같이 단순한 배포 환경에서만 사용할 수 있다.

`LocalEntityManagerFactoryBean`은 JPA만으로 데이터에 접근하는 어플리케이션같이 간단한 배포 환경에 적합한 `EntityManagerFactory`를 만든다. 팩토리 빈은 JPA의 `PersistenceProvider` 자동 감지 메커니즘을 사용하며 (JPA의 자바 SE 환경 부트스트랩 활용), 보통은 persistence 유닛명만 지정하면 된다. 다음 예제는 `LocalEntityManagerFactoryBean`을 설정하는 XML이다:

```xml
<beans>
    <bean id="myEmf" class="org.springframework.orm.jpa.LocalEntityManagerFactoryBean">
        <property name="persistenceUnitName" value="myPersistenceUnit"/>
    </bean>
</beans>
```

이 JPA 배포 형태는 가장 간단하지만, 제약이 제일 많은 방법이기도 하다. 기존 JDBC `DataSource` 빈 정의를 참조할 수 없으며, 글로벌 트랜잭션을 지원하지 않는다. 또한 persistent 클래스의 위빙(바이트 코드 변환)은 provider마다 다르기 때문에, 기동 시 특정 JVM 에이전트를 지정해야 할 때도 종종 있다. 이 옵션은 JPA 스펙으로 설계한 독립형 어플리케이션과 테스트 환경에만 적합하다.

#### Obtaining an EntityManagerFactory from JNDI

이 옵션은 Java EE 서버에 배포할 때 사용할 수 있다. 서버의 기본값과는 다른 provider를 사용하려면, 서버 문서에서 커스텀 JPA provider를 서버에 배포하는 방법을 확인해봐라.

JNDI에서 `EntityManagerFactory`를 가져오려면 (예를 들어 자바 EE 환경에서) 다음 예제처럼 XML 설정만 바꾸면 된다:

```xml
<beans>
    <jee:jndi-lookup id="myEmf" jndi-name="persistence/myPersistenceUnit"/>
</beans>
```

여기서는 표준 자바 EE 부트스트랩을 가정한다. 자바 EE 서버는 persistence 유닛과(사실상 어플리케이션 jar의 `META-INF/persistence.xml` 파일), 자바 EE 배포 서술자(예를 들어 `web.xml`)의 `persistence-unit-ref` 엔트리를 자동 감지하고, 이 persistence 유닛에 대한 환경 네이밍 컨텍스트 위치를 정의한다.

이 시나리오에선 persistent 클래스의 위빙(바이트 코드 변환)을 포함한 전체 persistent 유닛 배포는 자바 EE 서버가 담당한다. JDBC `DataSource`는 `META-INF/persistence.xml` 파일의 JNDI 위치를 통해 정의된다. `EntityManager` 트랜잭션은 서버의 JTA 하위 시스템과 통합된다. 스프링은 단순히 `EntityManagerFactory`를 가져와서, 의존성 주입을 통해 어플리케이션 객체에 전달하고 persistence 유닛에 대한 트랜잭션을 관리한다 (보통은 `JtaTransactionManager`를 통해).

어플리케이션이 persistence 유닛을 여러 개 사용한다면, JNDI에서 가져온 persistence 유닛의 빈 이름은 어플리케이션에서 참조할 때 사용하는 persistence 유닛명과 일치해야 한다 (예를 들어, `@PersistenceUnit`과 `@PersistenceContext` 어노테이션에서).

#### Using `LocalContainerEntityManagerFactoryBean`

이 옵션은 스프링 기반 어플리케이션 환경에서 전체 JPA 기능이 필요할 때 사용할 수 있다. 여기에서 말하는 환경에는 톰캣같은 웹 컨테이너, 독립 실행형 어플리케이션, 정교한 persistence가 필요한 통합 테스트 환경도 포함된다.

> 명시적으로 하이버네이트를 설정하고 싶다면, 가까운 대안으로 일반 JPA `LocalContainerEntityManagerFactoryBean` 대신 네이티브 하이버네이트 `LocalSessionFactoryBean`을 설정해도 된다. 이렇게 하면 JPA 접근 코드 뿐 아니라 네이티브 하이버네이트 접근 코드와도 상호 작용할 수 있다. 자세한 내용은 [JPA 상호 작용을 위한 네이티브 하이버네이트 설정](#646-native-hibernate-setup-and-native-hibernate-transactions-for-jpa-interaction)을 참고해라.
>

`LocalContainerEntityManagerFactoryBean`으로는 `EntityManagerFactory` 설정을 완전히 제어할 수 있어서, 세세한 커스텀이 필요한 환경에 적합하다. `LocalContainerEntityManagerFactoryBean`은 `persistence.xml` 파일과, 지정한 `dataSourceLookup` 전략, `loadTimeWeaver`를 기반으로 `PersistenceUnitInfo` 인스턴스를 만든다. 따라서 JNDI 바깥에서도 커스텀 데이터소스를 사용하고 위빙 프로세스를 제어할 수 있다. 다음 예제는 전형적인 `LocalContainerEntityManagerFactoryBean` 빈 정의다:

```xml
<beans>
    <bean id="myEmf" class="org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean">
        <property name="dataSource" ref="someDataSource"/>
        <property name="loadTimeWeaver">
            <bean class="org.springframework.instrument.classloading.InstrumentationLoadTimeWeaver"/>
        </property>
    </bean>
</beans>
```

다음은 전형적인 `persistence.xml` 파일 예시다:

```xml
<persistence xmlns="http://java.sun.com/xml/ns/persistence" version="1.0">
    <persistence-unit name="myUnit" transaction-type="RESOURCE_LOCAL">
        <mapping-file>META-INF/orm.xml</mapping-file>
        <exclude-unlisted-classes/>
    </persistence-unit>
</persistence>
```

> `<exclude-unlisted-classes/>`는 어노테이션이 달린 엔티티 클래스를 스캔하지 않아야 함을 나타내는 간편한 방법이다. 'true'를 명시해도 (`<exclude-unlisted-classes>true</exclude-unlisted-classes/>`) 동일하다. `<exclude-unlisted-classes>false</exclude-unlisted-classes/>`는 스캔을 트리거한다. 하지만 엔티티 클래스를 스캔하길 원한다면 `exclude-unlisted-classes` 요소를 생략하는 게 더 깔끔하다.

JPA 설정 옵션 중에서도 `LocalContainerEntityManagerFactoryBean`은 어플리케이션 내 로컬 설정을 유연하게 활용할 수 있는 가장 확실한 옵션이다. 기존 JDBC `DataSource`를 참조할 수 있으며, 로컬 트랜잭션과 글로벌 트랜잭션을 모두 지원한다. 단, 바이트 코드 변환이 필요한 persistence provider를 사용한다면, 위빙을 위한 클래스 로더같은 런타임 환경에 대한 요구 사항이 추가될 순 있다.

이 옵션은 자바 EE 서버의 빌트인 JPA 기능과 충돌할 수도 있다. 완전한 자바 EE 환경이라면 JNDI에서 `EntityManagerFactory`를 가져오는 걸 고려해봐라. 아니면 `LocalContainerEntityManagerFactoryBean` 정의에 커스텀 `persistenceXmlLocation`을 지정하고 (예를 들어 META-INF/my-persistence.xml), 어플리케이션 jar 파일에 같은 이름으로 서술자 하나만 포함시켜라. 자바 EE 서버는 디폴트 파일 `META-INF/persistence.xml`만 찾아보기 때문에, 커스텀 persistence 유닛은 무시하므로, 스프링 기반 JPA 설정과의 충돌을 사전에 방지할 수 있다. (Resin 3.1 등에 적용된다.)

> #### 로드 타임 위빙은 언제 필요할까?
>
> 모든 JPA provider에 JVM 에이전트가 필요한 것은 아니다. 하이버네이트도 에이전트가 필요하지 않는 JPA provider 중 하나다. 에이전트가 필요하지 않은 provider를 사용하거나, 커스텀 컴파일러나 Ant 태스크를 통해 빌드 시점에 코드를 수정할 수 있는 다른 방법이 있다면, 로드 타임 위버는 사용하지 않는 게 좋다.
>

스프링이 제공하는 `LoadTimeWeaver` 인터페이스는 실행 환경이 웹 컨테이너인지 어플리케이션 서버인지에 따라 적합한 방법으로 JPA `ClassTransformer` 인스턴스를 연결해준다. [에이전트](https://docs.oracle.com/javase/6/docs/api/java/lang/instrument/package-summary.html)를 통해 `ClassTransformers`를 후킹하는 건 보통 비효율적이다. 에이전트는 가상 머신 전체에 연결해 로드한 모든 클래스를 검사하는데, 보통 프로덕션 서버 환경에서는 바람직하지 않다.

스프링은 다양한 환경을 위한 여러 가지 `LoadTimeWeaver` 구현체를 제공하며, `ClassTransformer` 인스턴스를 각 VM이 아닌 각 클래스 로더에만 추가한다.

`LoadTimeWeaver` 구현체는 범용 구현체와 다양한 플랫폼(Tomcat, JBoss, WebSphere같은)에 맞춰 커스텀한 구현체가 있다. 어떤 것을 사용하던 간에, 각 구현체와 설정을 제대로 이해하고 싶으면 AOP 챕터의 [스프링 설정](https://docs.spring.io/spring-framework/docs/5.3.2/reference/html/core.html#aop-aj-ltw-spring)을 참고해라.

[스프링 설정](https://docs.spring.io/spring-framework/docs/5.3.2/reference/html/core.html#aop-aj-ltw-spring)에서 설명하는대로, XML 요소 `context:load-time-weaver`의 `@EnableLoadTimeWeaving` 어노테이션을 사용하면 컨텍스트 전역에 `LoadTimeWeaver`를 설정할 수 있다. 이렇게하면 모든 JPA `LocalContainerEntityManagerFactoryBean` 인스턴스는 자동으로 이 글로벌 위버를 선택한다. 다음 예제는 로드 타임 위버를 설정하고 자동 감지한 플랫폼(예를 들어 톰캣의 위빙  클래스 로더나 스프링의 JVM 에이전트)을 전달해서, 위버를 인식할 수 있는 모든 빈에 위버를 자동 전파하는 예제다. 보통은 이 방법을 선호한다:

```xml
<context:load-time-weaver/>
<bean id="emf" class="org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean">
    ...
</bean>
```

물론, 필요하면 다음 예제처럼 `loadTimeWeaver` 프로퍼티에 수동으로 전용 위버를 지정할 수도 있다:

```xml
<bean id="emf" class="org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean">
    <property name="loadTimeWeaver">
        <bean class="org.springframework.instrument.classloading.ReflectiveLoadTimeWeaver"/>
    </property>
</bean>
```

이 기술을 사용하면 LTW를 설정한 방법과는 상관 없이 instrumentation에 의존하는 JPA 어플리케이션을 에이전트 없이도 타겟 플랫폼(톰캣 등)에서 실행할 수 있다. JPA transformer는 클래스 로더 수준에서만 적용되고 그에 따라 서로 격리된다. 호스팅하는 어플리케이션이 다른 JPA 구현체에 의존할 때 특히 유용하다.

#### Dealing with Multiple Persistence Units

어플리케이션에서 정의한 persistence 유닛 위치가 여럿이라면 (예를 들어 클래스패스 내에 JAR 여러 개에 나눠 저장) 스프링은 중앙 레포지토리 역할을 수행하는 `PersistenceUnitManager`를 제공한다. 덕분에 무거운 persistence 유닛 디스커버리 프로세스를 방지할 수 있다. 기본 구현체는 위치를 여러 개 지정할 수 있다. 지정한 위치를 파싱해서 나중에 persistence 유닛명을 통해 유닛 정보를 조회해간다. (디폴트로는 클래스패스의 `META-INF/persistence.xml` 파일을 검색한다.) 다음은 유닛 위치를 여러 개 설정하는 예시다:

```xml
<bean id="pum" class="org.springframework.orm.jpa.persistenceunit.DefaultPersistenceUnitManager">
    <property name="persistenceXmlLocations">
        <list>
            <value>org/springframework/orm/jpa/domain/persistence-multi.xml</value>
            <value>classpath:/my/package/**/custom-persistence.xml</value>
            <value>classpath*:META-INF/persistence.xml</value>
        </list>
    </property>
    <property name="dataSources">
        <map>
            <entry key="localDataSource" value-ref="local-db"/>
            <entry key="remoteDataSource" value-ref="remote-db"/>
        </map>
    </property>
    <!-- if no datasource is specified, use this one -->
    <property name="defaultDataSource" ref="remoteDataSource"/>
</bean>

<bean id="emf" class="org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean">
    <property name="persistenceUnitManager" ref="pum"/>
    <property name="persistenceUnitName" value="myCustomUnit"/>
</bean>
```

기본 구현체에서는 `PersistenceUnitInfo` 인스턴스를 커스텀할 수 있다 (JPA provider에 전달하기 전에). 이때는 선언적으로도 (호스팅된 모든 유닛에 적용되는 프로퍼티를 통해), 프로그래밍 방식으로도 (persistence 유닛을 선택할 수 있는 `PersistenceUnitPostProcessor`를 통해) 가능하다. `PersistenceUnitManager`를 지정하지 않으면 `LocalContainerEntityManagerFactoryBean` 내부에서 디폴트 구현체를 만든다.

#### Background Bootstrapping

`LocalContainerEntityManagerFactoryBean`은 다음 예제와 같이 `bootstrapExecutor` 프로퍼티를 통해 백그라운드 부트스트랩을 지원한다:

```xml
<bean id="emf" class="org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean">
    <property name="bootstrapExecutor">
        <bean class="org.springframework.core.task.SimpleAsyncTaskExecutor"/>
    </property>
</bean>
```

실제 JPA provider 부트스트랩은, 지정한 executor로 전달한 다음 어플리케이션 부트스트랩 스레드와 병렬로 실행한다. 노출하고 있는 `EntityManagerFactory` 프록시는 다른 어플리케이션 컴포넌트에 주입할 수 있으며, `EntityManagerFactoryInfo` 설정 검사에도 사용할 수 있다. 하지만 다른 컴포넌트에서 실제 JPA provider에 접근하면 (예를 들어 `createEntityManager` 호출) 백그라운드 부트스트랩이 완료될 때까지 블로킹된다. 특히 스프링 데이터 JPA를 사용한다면 해당 레포지토리에도 부트스트랩 지연 모드를 설정해야 한다.

### 6.4.2. Implementing DAOs Based on JPA: `EntityManagerFactory` and `EntityManager`

> `EntityManagerFactory` 인스턴스는 thread-safe하지만, `EntityManager` 인스턴스는 그렇지 않다. 하지만 JPA `EntityManager`를 주입받으면 JPA 스펙에 정의된대로 어플리케이션 서버의 JNDI 환경에서 가져온 `EntityManager`처럼 동작한다. 모든 요청을 현재 트랜잭션의 `EntityManager`에 (있으면) 위임한다. 그 외는 연산마다 `EntityManager`를 새로 만드는 것으로 폴백해 사실상 thread-safe하게 사용할 수 있다.

`EntityManagerFactory`나 `EntityManager`를 주입받아 스프링 의존성 없이 순수 JPA를 사용하는 코드를 작성할 수도 있다. `PersistenceAnnotationBeanPostProcessor`를 활성화했다면 스프링은 필드와 메소드 레벨에서 `@PersistenceUnit`과 `@PersistenceContext` 어노테이션을 인식한다. 다음 예제는 `@PersistenceUnit` 어노테이션을 사용하는 순수 JPA DAO 구현체다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
public class ProductDaoImpl implements ProductDao {

    private EntityManagerFactory emf;

    @PersistenceUnit
    public void setEntityManagerFactory(EntityManagerFactory emf) {
        this.emf = emf;
    }

    public Collection loadProductsByCategory(String category) {
        try (EntityManager em = this.emf.createEntityManager()) {
            Query query = em.createQuery("from Product as p where p.category = ?1");
            query.setParameter(1, category);
            return query.getResultList();
        }
    }
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
class ProductDaoImpl : ProductDao {

    private lateinit var emf: EntityManagerFactory

    @PersistenceUnit
    fun setEntityManagerFactory(emf: EntityManagerFactory) {
        this.emf = emf
    }

    fun loadProductsByCategory(category: String): Collection<*> {
        val em = this.emf.createEntityManager()
        val query = em.createQuery("from Product as p where p.category = ?1");
        query.setParameter(1, category);
        return query.resultList;
    }
}
```

위에 있는 DAO는 스프링에 의존하진 않지만 스프링 어플리케이션 컨텍스트와 잘 들어맞는다. 게다가 이 DAO는 다음 예제에 있는 빈 정의에서 알 수 있듯이, 어노테이션을 활용해 디폴트 `EntityManagerFactory`를 주입받을 수 있다:

```xml
<beans>

    <!-- bean post-processor for JPA annotations -->
    <bean class="org.springframework.orm.jpa.support.PersistenceAnnotationBeanPostProcessor"/>

    <bean id="myProductDao" class="product.ProductDaoImpl"/>

</beans>
```

`PersistenceAnnotationBeanPostProcessor` 정의를 명시하는 대신 어플리케이션 컨텍스트 설정에 XML 요소 `context:annotation-config`를 사용해도 된다. 이렇게하면 `CommonAnnotationBeanPostProcessor`를 포함한 모든 어노테이션 기반 설정을 위한 스프링 표준 post-processor가 자동으로 등록된다.

아래 예제를 생각해보자:

```xml
<beans>

    <!-- post-processors for all standard config annotations -->
    <context:annotation-config/>

    <bean id="myProductDao" class="product.ProductDaoImpl"/>

</beans>
```

이 DAO의 가장 큰 문제는 항상 팩토리를 통해 새 `EntityManager`를 생성한다는 거다. 팩토리 대신 활성 트랜잭션 내에 있는 `EntityManager`(실제 트랜잭션 EntityManager의 thread-safe한 프록시를 공유하기 때문에 "shared EntityManager"라고도 함)를 주입받으면 이를 방지할 수 있다. 그 방법은 다음 예제를 참고해라:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
public class ProductDaoImpl implements ProductDao {

    @PersistenceContext
    private EntityManager em;

    public Collection loadProductsByCategory(String category) {
        Query query = em.createQuery("from Product as p where p.category = :category");
        query.setParameter("category", category);
        return query.getResultList();
    }
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
class ProductDaoImpl : ProductDao {

    @PersistenceContext
    private lateinit var em: EntityManager

    fun loadProductsByCategory(category: String): Collection<*> {
        val query = em.createQuery("from Product as p where p.category = :category")
        query.setParameter("category", category)
        return query.resultList
    }
}
```

`@PersistenceContext` 어노테이션은 `type`이라는 생략 가능한 속성이 있으며, 기본값은 `PersistenceContextType.TRANSACTION`이다. 기본값을 사용하면 shared `EntityManager` 프록시를 전달받을 수 있다. 또 다른 값으론 `PersistenceContextType.EXTENDED`가 있는데, 이 속성은 이야기가 완전히 달라진다. 이 속성을 사용하면 소위 말해, `EntityManager`를 확장한 thread-safe하지 않은 인스턴스를 만들기 때문에, 스프링이 관리하는 싱글톤 빈과 같이 동시에 접근할 수 있는 컴포넌트에선 사용하면 안된다. 확장한 `EntityManager` 인스턴스는 세션에 상주하는 등의 stateful한 컴포넌트에서만 사용해야 한다. `EntityManager`의 생명 주기는 현재 트랜잭션에 묶이지 않으며 전적으로 어플리케이션에 달려있다.

> #### 메소드 레벨 주입과 필드 레벨 주입
>
> 의존성 주입을 지시하는 어노테이션은 (`@PersistenceUnit`, `@PersistenceContext` 같은) 클래스의 필드나 메소드에 모두 적용할 수 있다. 따라서 "메소드 레벨 주입", "필드 레벨 주입"이라는 표현을 사용한다. 필드 레벨 어노테이션은 간결하고 사용하기도 쉬우며, 메소드 레벨 어노테이션은 주입받은 의존성을 가지고 다른 로직도 함께 실행할 수 있다. 두 케이스 모두 가시성(public, protected, private)은 중요하지 않다.
>
> 그렇다면 클래스 레벨 어노테이션은 어떨까?
>
> 자바 EE 플랫폼에서 클래스 레벨 어노테이션은, 의존성을 선언할 때 사용하며 리소스 주입에는 사용하지 않는다.

주입받은 `EntityManager`는 스프링이 관리한다 (진행중인 트랜잭션을 인식한다). 새로 만든 DAO 구현체는 `EntityManagerFactory` 대신 `EntityManager`를 주입받지만, 어노테이션 때문에 어플리케이션 컨텍스트 XML을 변경할 필요는 없다.

이 스타일로 DAO를 만들었을 때 가장 좋은 점은 Java Persistence API에만 의존할 수 있다는 거다. 스프링 클래스는 임포트하지 않아도 된다. 게다가 스프링 컨테이너는 JPA 어노테이션을 인지하고 자동으로 의존성을 주입해준다. 외부 의존성이 코드를 침범하지 않는다는 점에서 매력적이며, JPA 개발자라면 더 자연스럽게 느껴질 거다.

### 6.4.3. Spring-driven JPA transactions

> [선언적인 트랜잭션 관리](../transactionmanagement#14-declarative-transaction-management)를 아직 읽어보지 않았다면 읽고 오길 권한다. 스프링의 선언적인 트랜잭션 지원을 훨씬 더 자세히 다루고 있다.

JPA에서 권장하는 트랜잭션 전략은 JPA의 네이티브 트랜잭션을 통한 로컬 트랜잭션이다. 스프링의 `JpaTransactionManager`는 모든 표준 JDBC 커넥션 풀에 로컬 JDBC 트랜잭션에서 알려져 있는 많은 기능(트랜잭션 전용 격리 수준과 리소스 레벨 읽기 전용 최적화 등)을 제공한다 (XA는 필요 없음).

게다가 스프링 JPA에선, JDBC `Connection` 조회를 지원하는 `JpaDialect`를 등록하면, 같은 `DataSource`에 JDBC 코드로 접근해도 설정해둔 `JpaTransactionManager`가 JPA 트랜잭션을 노출한다. 스프링은 EclipseLink와 하이버네이트 JPA 구현체를 위한 dialect를 제공한다. `JpaDialect` 메커니즘에 대한 자세한 내용은 [다음 섹션](#644-understanding-jpadialect-and-jpavendoradapter)을 참고해라.

> 가까운 대안으로 스프링의 네이티브 `HibernateTransactionManager`를 사용해도 된다. `HibernateTransactionManager`는 하이버네이트의 세부 스펙을 적용해 JDBC와의 상호 작용을 제공하기 때문에, JPA 접근 코드로도 상호 작용할 수 있다. 특히 `LocalSessionFactoryBean` 설정과 결합했을 때 의미가 생긴다. 자세한 내용은 [JPA 상호 작용을 위한 네이티브 하이버네이트 설정](#646-native-hibernate-setup-and-native-hibernate-transactions-for-jpa-interaction)을 참고해라.
>

### 6.4.4. Understanding `JpaDialect` and `JpaVendorAdapter`

`JpaTransactionManager`와 `AbstractEntityManagerFactoryBean`의 하위 클래스는 커스텀 `JpaDialect`를 `jpaDialect` 빈 프로퍼티에 전달할 수 있다. `JpaDialect` 구현체는 보통 벤더 방식에 따라, 스프링이 지원하는 다음과 같은 고급 기능을 활성화할 수 있다:

- 특정 트랜잭션 시맨틱스 적용 (커스텀 고립 수준이나 트랜잭션 타임아웃 등)
- 활성 트랜잭션 내에 있는 JDBC `Connection` 조회 (JDBC 기반 DAO에서 사용할 수 있음)
- `PersistenceException`을 스프링 `DataAccessException`으로 변환하는 로직 커스텀

트랜잭션 시맨틱스와 예외 변환 처리를 커스텀할 수 있다는 점에서 특히 유용하다. 기본 구현체(`DefaultJpaDialect`)는 특별한 기능을 제공하지 않으며, 앞에 나열한 기능이 필요하다면 적절한 dialect를 지정해야 한다.

> 본래 `JpaVendorAdapter`는 스프링의 모든 기능을 갖춘 `LocalContainerEntityManagerFactoryBean` 설정을 위한 훨씬 더 광범위한 provider 어댑터로, `JpaDialect`의 기능을 다른 provider 전용 기본값과 결합한다. `HibernateJpaVendorAdapter`나 `EclipseLinkJpaVendorAdapter`를 지정하면 각각 하이버네이트와 EclipseLink를 위한 `EntityManagerFactory` 세팅을 가장 쉽게 자동화할 수 있다. 이 provider 어댑터는 일차적으로 스프링 기반으로 트랜잭션을 관리할 때 사용하도록 설계됐다 (즉, `JpaTransactionManager`와 함께 사용한다).
>

[`JpaDialect`](https://docs.spring.io/spring-framework/docs/5.3.2/javadoc-api/org/springframework/orm/jpa/JpaDialect.html), [`JpaVendorAdapter`](https://docs.spring.io/spring-framework/docs/5.3.2/javadoc-api/org/springframework/orm/jpa/JpaVendorAdapter.html)의 자세한 기능과 스프링 JPA에서 사용하는 방법은 각 javadoc을 참고해라.

### 6.4.5. Setting up JPA with JTA Transaction Management

리소스를 여러 개 사용하는 트랜잭션에선, 스프링은 `JpaTransactionManager` 대신 자바 EE 환경이나 Atomikos같은 독립형 트랜잭션 코디네이터와 함께 사용할 수 있는 JTA로 트랜잭션 코디네이션을 지원한다. `JpaTransactionManager` 대신 스프링의 `JtaTransactionManager`를 사용하는 것 외에도 몇 가지가 더 필요하다:

- JDBC 커넥션 풀은 XA가 가능해야 하며, 트랜잭션 코디네이터와 통합해야 한다. JNDI를 통해 다른 `DataSource`를 노출하는 자바 EE 환경에선 보통 간단히 해결된다. 자세한 내용은 어플리케이션 서버 설명서를 참고해라. 유사하게 독립형 트랜잭션 코디네이터는 보통 특별한 XA 통합용 `DataSource`를 함께 제공한다. 역시 문서를 확인해봐라.
- JTA에 JPA `EntityManagerFactory` 설정을 알려줘야 한다. 그 방법은 provider마다 다르지만, 보통은 `LocalContainerEntityManagerFactoryBean`의 `jpaProperties`로 특별한 프로퍼티를 지정한다. 하이버네이트에선 버전마다 프로퍼티가 다르기도 하다. 자세한 내용은 하이버네이트 문서를 참고해라.
- 스프링의 `HibernateJpaVendorAdapter`는 커넥션 릴리즈 모드는 `on-close`로 설정하는 등 몇 가지 스프링의 기본값을 강제하는데, 하이버네이트 5.0에선 하이버네이트의 자체 기본값과 일치하지만, 하이버네이트 5.1+에서는 달라졌다. JTA 설정에선 persistence 유닛 트랜잭션 타입을 "JTA"로 선언해야 한다. 아니면 하이버네이트 5.2의 `hibernate.connection.handling_mode` 프로퍼티를 `DELAYED_ACQUISITION_AND_RELEASE_AFTER_STATEMENT`로 설정해서 하이버네이트의 자체 기본값을 복원해라. 관련해서는 [실제 상황과는 다른 하이버네이트의 어플리케이션 서버 경고](#637-spurious-application-server-warnings-with-hibernate)를 참고해라.
- 아니면 어플리케이션 서버 자체에서 `EntityManagerFactory`를 가져오는 것도 생각해봐라 (즉, 로컬에 `LocalContainerEntityManagerFactoryBean`을 선언하는 대신 JNDI를 통해 조회). 서버가 제공하는 `EntityManagerFactory`는, 서버 설정에 특별한 정의가 필요할 수는 있지만 (배포 의존성이 생긴다), 서버의 JTA 환경에 맞는 `EntityManagerFactory`가 세팅된다.

### 6.4.6. Native Hibernate Setup and Native Hibernate Transactions for JPA Interaction

네이티브 `LocalSessionFactoryBean` 설정을 `HibernateTransactionManager`와 결합하면 `@PersistenceContext`나 다른 JPA 접근 코드와 상호 작용할 수 있다. 하이버네이트 `SessionFactory`는 이제 기본적으로 JPA의 `EntityManagerFactory` 인터페이스를 구현하고 있으며, 하이버네이트 `Session` 처리는 기본적으로 JPA `EntityManager`를 처리하는 게 된다. 스프링의 JPA 기능에선 네이티브 하이버네이트 세션을 자동으로 감지한다.

따라서 이 네이티브 하이버네이트 설정은 많은 시나리오에서 표준 JPA `LocalContainerEntityManagerFactoryBean`과 `JpaTransactionManager` 조합을 대신할 수 있으며, 동일한 로컬 트랜잭션 내에서 `@PersistenceContext` `EntityManager` 뿐 아니라, `SessionFactory.getCurrentSession()`(`HibernateTemplate`까지도)과도 상호 작용할 수 있다. 게다가 이 설정은 JPA 부트스트랩 역할로 제한되지 않기 때문에 더 강력한 하이버네이트 통합과 더 유연한 설정이 가능하다.

스프링의 네이티브 하이버네이트 설정이 훨씬 더 많은 기능을 제공하기 때문에 (예를 들어 커스텀 하이버네이트 Integrator 설정이나, 하이버네이트 5.3 빈 컨테이너 통합, 더 강력한 읽기 전용 트랜잭션 최적화) 이 시나리오에서는 `HibernateJpaVendorAdapter` 설정은 필요없다. 마지막으로 또 한가지, 하이버네이트 설정은 `LocalSessionFactoryBuilder`로도 표현할 수 있으며, `LocalSessionFactoryBuilder`는 `@Bean` 스타일 설정과 원활하게 통합된다 (`FactoryBean`은 관여하지 않음).

> `LocalSessionFactoryBean`과 `LocalSessionFactoryBuilder`는 JPA `LocalContainerEntityManagerFactoryBean`과 동일하게 백그라운드 부트스트랩을 지원한다. 백그라운드 부트스트랩은 [여기](#background-bootstrapping)에서 소개하고 있다.
>
> `LocalSessionFactoryBean`에선 `bootstrapExecutor` 프로퍼티로 executor를 지정할 수 있다. 프로그래밍 방식을 사용하는 `LocalSessionFactoryBuilder`는 부트스트랩 executor 인자를 받는 `buildSessionFactory` 메소드를 오버로드하고 있다.