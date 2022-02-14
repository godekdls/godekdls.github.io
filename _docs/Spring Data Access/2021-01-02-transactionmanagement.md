---
title: Transaction Management
category: Spring Data Access
order: 2
permalink: /Spring%20Data%20Access/transactionmanagement/
description: 스프링 트랜잭션 관리 공식 문서를 한국어로 번역한 문서입니다. 스프링의 트랜잭션 모델과 기술을 소개하고, 선언적인 방법과 프로그래밍 방식으로 트랜잭션을 관리하는 방법 설명합니다.
image: ./../../images/springdataaccess/tx.png
lastmod: 2021-01-10T23:00:00+09:00
comments: true
priority: 0.8
originalRefName: 스프링 프레임워크 데이터 액세스
originalRefLink: https://docs.spring.io/spring-framework/docs/5.3.2/reference/html/data-access.html#transaction
---
<script>defaultLanguages = ['java']</script>

### 목차

- [1.1. Advantages of the Spring Framework’s Transaction Support Model](#11-advantages-of-the-spring-frameworks-transaction-support-model)
  + [1.1.1. Global Transactions](#111-global-transactions)
  + [1.1.2. Local Transactions](#112-local-transactions)
  + [1.1.3. Spring Framework’s Consistent Programming Model](#113-spring-frameworks-consistent-programming-model)
- [1.2. Understanding the Spring Framework Transaction Abstraction](#12-understanding-the-spring-framework-transaction-abstraction)
  + [1.2.1. Hibernate Transaction Setup](#121-hibernate-transaction-setup)
- [1.3. Synchronizing Resources with Transactions](#13-synchronizing-resources-with-transactions)
  + [1.3.1. High-level Synchronization Approach](#131-high-level-synchronization-approach)
  + [1.3.2. Low-level Synchronization Approach](#132-low-level-synchronization-approach)
  + [1.3.3. TransactionAwareDataSourceProxy](#133-transactionawaredatasourceproxy)
- [1.4. Declarative Transaction Management](#14-declarative-transaction-management)
  + [1.4.1. Understanding the Spring Framework’s Declarative Transaction Implementation](#141-understanding-the-spring-frameworks-declarative-transaction-implementation)
  + [1.4.2. Example of Declarative Transaction Implementation](#142-example-of-declarative-transaction-implementation)
  + [1.4.3. Rolling Back a Declarative Transaction](#143-rolling-back-a-declarative-transaction)
  + [1.4.4. Configuring Different Transactional Semantics for Different Beans](#144-configuring-different-transactional-semantics-for-different-beans)
  + [1.4.5. \<tx:advice/\> Settings](#145-txadvice-settings)
  + [1.4.6. Using @Transactional](#146-using-transactional)
    * [@Transactional Settings](#transactional-settings)
    * [Multiple Transaction Managers with @Transactional](#multiple-transaction-managers-with-transactional)
    * [Custom Composed Annotations](#custom-composed-annotations)
  + [1.4.7. Transaction Propagation](#147-transaction-propagation)
    * [Understanding PROPAGATION_REQUIRED](#understanding-propagation_required)
    * [Understanding PROPAGATION_REQUIRES_NEW](#understanding-propagation_requires_new)
    * [Understanding PROPAGATION_NESTED](#understanding-propagation_nested)
  + [1.4.8. Advising Transactional Operations](#148-advising-transactional-operations)
  + [1.4.9. Using @Transactional with AspectJ](#149-using-transactional-with-aspectj)
- [1.5. Programmatic Transaction Management](#15-programmatic-transaction-management)
  + [1.5.1. Using the TransactionTemplate](#151-using-the-transactiontemplate)
    * [Specifying Transaction Settings](#specifying-transaction-settings)
  + [1.5.2. Using the TransactionOperator](#152-using-the-transactionoperator)
    * [Cancel Signals](#cancel-signals)
    * [Specifying Transaction Settings](#specifying-transaction-settings-1)
  + [1.5.3. Using the TransactionManager](#153-using-the-transactionmanager)
    * [Using the PlatformTransactionManager](#using-the-platformtransactionmanager)
    * [Using the ReactiveTransactionManager](#using-the-reactivetransactionmanager)
- [1.6. Choosing Between Programmatic and Declarative Transaction Management](#16-choosing-between-programmatic-and-declarative-transaction-management)
- [1.7. Transaction-bound Events](#17-transaction-bound-events)
- [1.8. Application server-specific integration](#18-application-server-specific-integration)
  + [1.8.1. IBM WebSphere](#181-ibm-websphere)
  + [1.8.2. Oracle WebLogic Server](#182-oracle-weblogic-server)
- [1.9. Solutions to Common Problems](#19-solutions-to-common-problems)
  + [1.9.1. Using the Wrong Transaction Manager for a Specific DataSource](#191-using-the-wrong-transaction-manager-for-a-specific-datasource)
- [1.10. Further Resources](#110-further-resources)

---

포괄적인 트랜잭션 기능은 스프링 프레임워크를 사용하는 가장 큰 이유 중 하나다. 스프링 프레임워크는 트랜잭션 관리를 일관적으로 추상화해주며, 다음과 같은 차별점이 있다:

- 자바 트랜잭션 API(JTA), JDBC, 하이버네이트, JPA(Java Persistence API) 등 다양한 트랜잭션 API에 일관된 프로그래밍 모델 제공.
- [선언적인 트랜잭션 관리](#14-declarative-transaction-management) 지원.
- JTA 등의 복잡한 트랜잭션 API보다 훨씬 간단한 [프로그래밍 방식](#15-programmatic-transaction-management) 트랜잭션 관리 API.
- 스프링 데이터 액세스 추상화와의 완벽한 통합.

이어지는 섹션에선 스프링 프레임워크의 트랜잭션 기능과 기술을 설명한다:

- [스프링 프레임워크 트랜잭션 모델의 차별점](#11-advantages-of-the-spring-frameworks-transaction-support-model)에선 EJB 컨테이너의 트랜잭션 관리(CMT, Container-Managed Transaction)나 하이버네이트같은 전용 API를 통한 로컬 트랜잭션이 아닌, 스프링 프레임워크의 트랜잭션 추상화를 사용해야 하는 이유를 설명한다.
- [스프링 프레임워크 트랜잭션 추상화 이해하기](#12-understanding-the-spring-framework-transaction-abstraction)에선 핵심 클래스를 간략하게 정리하고, 다양한 소스로 `DataSource`를 설정하고 인스턴스를 가져오는 방법을 설명한다.
- [트랜잭션 리소스 동기화하기](#13-synchronizing-resources-with-transactions)에선 어플리케이션에서 리소스를 올바르게 만들고, 재사용하고, 정리하는 방법을 설명한다.
- [선언적인 트랜잭션 관리](#14-declarative-transaction-management)는 선언적으로 트랜잭션을 관리하는 방법을 설명한다.
- [프로그래밍 방식 트랜잭션 관리](#15-programmatic-transaction-management)에선 프로그래밍 방식으로(즉, 코드로 직접) 트랜잭션을 관리하는 방법을 다룬다.
- [트랜잭션 바운드 이벤트](#17-transaction-bound-events)에선 트랜잭션 내에서 어플리케이션 이벤트를 사용하는 방법을 설명한다.

이 챕터는 베스트 프랙티스, [어플리케이션 서버 통합](#18-application-server-specific-integration), [흔히 겪는 문제에 대한 솔루션](#19-solutions-to-common-problems)도 함께 다룬다.

---

## 1.1. Advantages of the Spring Framework’s Transaction Support Model

지금까지 자바 EE 개발자는 글로벌 트랜잭션이나 로컬 트랜잭션을 활용해 트랜잭션을 관리해왔다. 하지만 두 방법 모두 한계가 많다. 다음 두 섹션에 걸쳐 글로벌과 로컬 트랜잭션 관리를 리뷰하고, 스프링 프레임워크가 어떻게 두 트랜잭션 모델의 한계를 극복해  트랜잭션을 관리하는지 논한다.

### 1.1.1. Global Transactions

글로벌 트랜잭션에선 전형적인 관계형 데이터베이스와 메시지 큐같은 다양한 트랜잭션 리소스를 활용한다. 어플리케이션 서버는 JTA의 복잡한 API(exception 모델 등)를 통해 글로벌 트랜잭션을 관리한다. 게다가 JTA `UserTransaction`은 보통 JNDI를 통해 가져와야 한다. 그렇기 때문에 JTA를 사용하려면 JNDI도 필요하다. JTA는 일반적으로 어플리케이션 서버 환경에서만 사용할 수 있으므로, 글로벌 트랜잭션을 사용하면 어플리케이션 코드를 재사용하기도 어렵다.

과거엔 글로벌 트랜잭션 방식에선 EJB CMT(Container Managed Transaction) 활용을 선호했다. CMT는 선언적으로 트랜잭션을 관리할 수 있는 한 가지 수단이다 (프로그래밍 방식 트랜잭션 관리와 구분되는 방법). EJB 자체는 JNDI가 필요하지만, EJB CMT를 사용하면 직접 JNDI로 트랜잭션 관련 조회를 하지 않아도 된다. 트랜잭션을 제어하기 위한 자바 코드를, 전부는 아니지만 대부분 없애준다. 하지만 CMT는 JTA와 어플리케이션 서버 환경에 너무 묶여있다는 치명적인 단점이 있다. 게다가 EJB에서(아니면 적어도 트랜잭션 EJB 파사드 뒤에서) 비즈니스 로직을 구현해야만 CMT를 활용할 수 있다. 전반적으로 EJB는 단점이 너무 커서, 딱히 매력적인 제안은 아니다. 더군다나 선언적으로 트랜잭션을 관리할 수 있는 다른 괜찮은 대안도 많이 있다.

### 1.1.2. Local Transactions

로컬 트랜잭션은 JDBC 커넥션 등의 전용 리소스를 사용한다. 로컬 트랜잭션은 사용하긴 더 쉬울진 몰라도, 상당한 단점이 있다. 바로, 여러 트랜잭션 리소스에선 유효하지 않다는 점이다. 예를 들어 JDBC 커넥션으로 트랜잭션을 관리하는 코드는 글로벌 JTA 트랜잭션 내에서 실행할 수 없다. 어플리케이션 서버는 트랜잭션 관리에 관여하지 않기 때문에 리소스가 여러 개라면 정확성을 보장할 수 없다. (어플리케이션 대부분이 단일 트랜잭션 리소스를 사용한다는 점은 주목할만하다.) 또 다른 단점은 로컬 트랜잭션이 프로그래밍 모델을 침범한다는 점이다.

### 1.1.3. Spring Framework’s Consistent Programming Model

스프링은 글로벌 트랜잭션과 로컬 트랜잭션의 단점들을 해결해준다. 어플리케이션 개발자는 어떤 환경이라도 일관된 프로그래밍 모델을 사용할 수 있다. 각기 다른 환경에서 다른 트랜잭션 관리 전략을 사용하더라도, 코드는 한 번만 작성하면 된다. 스프링 프레임워크는 선언적인 트랜잭션 관리와, 프로그래밍 방식 트랜잭션 관리를 모두 지원한다. 대부분 선언적인 트랜잭션 관리를 선호하며, 대개 권장하는 방법이기도 하다.

프로그래밍 방식으로 트랜잭션을 관리하면, 개발자는 어떤 트랜잭션 인프라를 기반으로도 실행할 수 있는 스프링 프레임워크의 트랜잭션 인터페이스로 코드를 작성하게 된다. 더 많이 사용하는 선언적 모델에선, 보통 개발자는 트랜잭션 관리와 관련된 코드를 아예 작성하지 않고, 작성한다고 해도 매우 미미하다. 따라서 스프링 프레임워크 트랜잭션 API나 다른 트랜잭션 API에 의존하지 않고 어플리케이션을 개발할 수 있다.

> **트랜잭션 관리를 위한 전용 어플리케이션 서버가 필요한가?**
>
> 기존 엔터프라이즈 자바 어플리케이션에는 별도 어플리케이션 서버가 필요한 순간이 있지만, 트랜잭션을 스프링 프레임워크로 관리하면 이야기가 달라진다.
>
> 특히, EJB를 통한 선언적 트랜잭션을 관리하는 어플리케이션 서버는 필요 없어진다. 강력한 JTA 기능을 제공하는 어플리케이션 서버가 이미 있더라도, 스프링 프레임워크의 선언적 트랜잭션이 EJB CMT보다 더 강력한 기능과 더 생산적인 프로그래밍 모델을 제공한다고 판단할 수도 있다.
>
> 전용 JTA 어플리케이션 서버는 보통 트랜잭션을 여러 리소스에 걸쳐 처리해야 하는 경우에만 필요하다. 여러 리소스에 걸친 트랜잭션이 필요한 경우는 흔치 않다. 고급 어플리케이션에선 대신에 확장성이 뛰어난 단일 데이터베이스(오라클 RAC같은)를 많이들 사용한다. 독립형 트랜잭션 매니저([Atomikos Transactions](https://www.atomikos.com/), [JOTM](http://jotm.objectweb.org/) 등)를 활용할 수도 있다. 물론, 자바 메세지 서비스(JMS), 자바 EE 컨테이너 아키텍처(JCA)같은 용도로 어플리케이션 서버가 필요할 수는 있겠다.
>
> 스프링 프레임워크를 사용하면 필요할 때 어플리케이션을 확장할 수 있다. 로컬 트랜잭션(JDBC 커넥션 기반 등)으로 작성한 코드를 글로벌 트랜잭션 관리 컨테이너로 옮겨야 하는 순간이 오면, EJB CMT나 JTA 없이는 거의 처음부터 다시 만들던 그런 시대는 지나갔다. 스프링 프레임워크를 사용하면 설정 파일에 있는 일부 빈 정의만 변경하면 된다 (코드는 변경하지 않는다).

---

## 1.2. Understanding the Spring Framework Transaction Abstraction

스프링 트랜잭션 추상화에선 트랜잭션 전략이라는 핵심 개념을 사용한다. 트랜잭션 전략은 `TransactionManager`, 그 중에서도 명령형 트랜잭션 관리를 위한 <span class="custom-blockquote">org.springframework.transaction.PlatformTransactionManager</span> 인터페이스와, 반응형 트랜잭션 관리를 위한 <span class="custom-blockquote">org.springframework.transaction.ReactiveTransactionManager</span> 인터페이스가 정의하고 있다. 다음은 `PlatformTransactionManager` API의 정의다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
public interface PlatformTransactionManager extends TransactionManager {

    TransactionStatus getTransaction(TransactionDefinition definition) throws TransactionException;

    void commit(TransactionStatus status) throws TransactionException;

    void rollback(TransactionStatus status) throws TransactionException;
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
interface PlatformTransactionManager : TransactionManager {

    @Throws(TransactionException::class)
    fun getTransaction(definition: TransactionDefinition): TransactionStatus

    @Throws(TransactionException::class)
    fun commit(status: TransactionStatus)

    @Throws(TransactionException::class)
    fun rollback(status: TransactionStatus)
}
```

`PlatformTransactionManager`는 어플리케이션 코드에서 [프로그래밍 방식](#using-the-platformtransactionmanager)으로 활용해도 되지만, 일차적으로 서비스 공급자 인터페이스(SPI)다. `PlatformTransactionManager`는 인터페이스이기 때문에 필요에 따라 쉽게 모킹하거나 스터빙할 수 있다. JNDI같은 조회 전략과는 연관된 게 없다. `PlatformTransactionManager` 구현체는 스프링 프레임워크 IoC 컨테이너의 다른 객체(또는 빈)와 동일하게 정의한다. 이 특징만 놓고봐도 스프링 프레임워크의 트랜잭션 추상화를 사용해야 할 이유는 충분하며, 실제로 JTA로 처리한다고 해도 달라지는 건 없다. 트랜잭션 코드를 테스트하기도 JTA를 직접 사용하는 것보다 훨씬 쉽다.

다시 말하지만, 스프링의 철학에 따라 `PlatformTransactionManager` 인터페이스 메소드에서 던질 수 있는 모든 `TransactionException`은 unchecked exception이다 (즉, `java.lang.RuntimeException` 클래스를 상속하고 있다). 트랜잭션 인프라의 장애는 거의 예외없이 치명적이다. 드물게 어플리케이션 코드로 트랜잭션 실패를 복구할 수 있는 경우라면, 필요할 때 어플리케이션 개발자가 `TransactionException`을 잡아 처리해도 된다. 핵심 포인트는 개발자가 예외를 처리하도록 *강요*하지 않는다는 거다.

`getTransaction(..)` 메소드는 `TransactionDefinition` 파라미터에 따라 `TransactionStatus` 객체를 반환한다. 반환한 `TransactionStatus`는 새 트랜잭션을 나타낼 수도 있고, 현재 호출 스택에 일치하는 트랜잭션이 있다면 기존 트랜잭션을 나타낼 수도 있다. 후자에서 알 수 있는 사실은, `TransactionStatus`는 자바 EE 트랜잭션 컨텍스트와 마찬가지로 실행 스레드와 연관돼 있다는 점이다.

스프링 프레임워크 5.2부터 스프링은 리액티브 타입이나 코틀린 코루틴을 사용하는 리액티브 어플리케이션 전용 트랜잭션 관리 인터페이스도 제공한다. 다음은 <span class="custom-blockquote">org.springframework.transaction.ReactiveTransactionManager</span>에 정의돼 있는 트랜잭션 전략이다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
public interface ReactiveTransactionManager extends TransactionManager {

    Mono<ReactiveTransaction> getReactiveTransaction(TransactionDefinition definition) throws TransactionException;

    Mono<Void> commit(ReactiveTransaction status) throws TransactionException;

    Mono<Void> rollback(ReactiveTransaction status) throws TransactionException;
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
interface ReactiveTransactionManager : TransactionManager {

    @Throws(TransactionException::class)
    fun getReactiveTransaction(definition: TransactionDefinition): Mono<ReactiveTransaction>

    @Throws(TransactionException::class)
    fun commit(status: ReactiveTransaction): Mono<Void>

    @Throws(TransactionException::class)
    fun rollback(status: ReactiveTransaction): Mono<Void>
}
```

리액티브 트랜잭션 매니저는 어플리케이션 코드에서 [프로그래밍 방식](#using-the-reactivetransactionmanager)으로 활용해도 되지만, 일차적으로 서비스 공급자 인터페이스(SPI)다. `ReactiveTransactionManager`는 인터페이스이기 때문에 필요에 따라 쉽게 모킹하거나 스터빙할 수 있다.

`TransactionDefinition` 인터페이스로는 다음을 정의한다:

- 전파(Propagation): 기본적으로 트랜잭션 범위 내에 있는 모든 코드는 해당 트랜잭션에서 실행된다. 단, 트랜잭션 컨텍스트가 이미 있는 상태에서 트랜잭션 메소드를 실행하는 경우엔 동작 방식을 지정할 수 있다. 예를 들어 기존 트랜잭션에서 코드를 계속 실행하거나(일반적임), 기존 트랜잭션을 일시 중단하고 새 트랜잭션을 만들 수 있다. 스프링은 EJB CMT에서 많이 봤던 트랜잭션 전파 옵션을 모두 제공한다. 스프링에서 트랜잭션 전파가 의미하는 바를 알고 싶다면 [트랜잭션 전파](#147-transaction-propagation) 섹션을 참고해라.
- 고립(Isolation): 이 트랜잭션을 다른 트랜잭션 작업과 얼마나 격리할 것인지를 나타내는 척도다. 예를 들어 현재 트랜잭션은 다른 트랜잭션에서 커밋하지 않은 쓰기를 볼 수 있는가?
- 타임 아웃: 트랜잭션을 실행하는 시간으로, 타임 아웃되면 트랜잭션 인프라가 자동으로 롤백한다.
- 읽기 전용(Read-only) 상태: 데이터를 읽기만 하고 수정하지 않는 코드는 읽기 전용 트랜잭션을 사용할 수 있다. 읽기 전용 트랜잭션은 하이버네이트 등 일부 케이스에서 최적화에 활용된다.

이 설정들은 표준 트랜잭션 개념을 반영하고 있다. 필요하다면 트랜잭션 격리 수준과 다른 핵심 트랜잭션 개념을 설명하는 자료들을 참고해라. 이 개념은 스프링 프레임워크나, 다른 어떤 트랜잭션 관리 솔루션을 사용하더라도 반드시 이해해야 하는 개념이다.

`TransactionStatus` 인터페이스를 사용하면 간단한 코드로 트랜잭션 실행을 제어하고 트랜잭션 상태를 질의할 수 있다. 모든 트랜잭션 API에 있는 개념이므로 익숙할 거다. 다음 코드는 `TransactionStatus` 인터페이스다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
public interface TransactionStatus extends TransactionExecution, SavepointManager, Flushable {

    @Override
    boolean isNewTransaction();

    boolean hasSavepoint();

    @Override
    void setRollbackOnly();

    @Override
    boolean isRollbackOnly();

    void flush();

    @Override
    boolean isCompleted();
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
interface TransactionStatus : TransactionExecution, SavepointManager, Flushable {

    override fun isNewTransaction(): Boolean

    fun hasSavepoint(): Boolean

    override fun setRollbackOnly()

    override fun isRollbackOnly(): Boolean

    fun flush()

    override fun isCompleted(): Boolean
}
```

스프링의 선언적 트랜잭션 관리와 프로그래밍 방식 트랜잭션 관리 중 뭘 선택했든 간에, 제일 중요한 건 올바른 `TransactionManager` 구현체를 정의하는 거다. 구현체는 보통 의존성 주입을 통해 정의한다.

보통은 `TransactionManager` 구현체에 JDBC, JTA, 하이버네이트 등의 작동 환경을 알려줘야 한다. 로컬 `PlatformTransactionManager` 구현체를 정의하는 방법은 아래 예제를 보면 알 수 있다 (여기선 순수 JDBC 사용).

JDBC `DataSource`는 아래와 유사한 빈을 만들어 정의할 수 있다:

```xml
<bean id="dataSource" class="org.apache.commons.dbcp.BasicDataSource" destroy-method="close">
    <property name="driverClassName" value="${jdbc.driverClassName}" />
    <property name="url" value="${jdbc.url}" />
    <property name="username" value="${jdbc.username}" />
    <property name="password" value="${jdbc.password}" />
</bean>
```

그런 다음 관련 `PlatformTransactionManager` 빈 정의에 `DataSource` 정의를 참조로 추가한다. 아래 예시와 유사할 거다:

```xml
<bean id="txManager" class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
    <property name="dataSource" ref="dataSource"/>
</bean>
```

자바 EE 컨테이너에서 JTA를 사용한다면, JNDI를 통해 가져온 컨테이너 `DataSource`를 스프링의 `JtaTransactionManager`와 함께 사용해라. 다음은 JTA와 JNDI 조회를 활용하는 예제다:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:jee="http://www.springframework.org/schema/jee"
    xsi:schemaLocation="
        http://www.springframework.org/schema/beans
        https://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/jee
        https://www.springframework.org/schema/jee/spring-jee.xsd">

    <jee:jndi-lookup id="dataSource" jndi-name="jdbc/jpetstore"/>

    <bean id="txManager" class="org.springframework.transaction.jta.JtaTransactionManager" />

    <!-- other <bean/> definitions here -->

</beans>
```

`JtaTransactionManager`는 컨테이너의 글로벌 트랜잭션 관리 인프라를 사용하기 때문에 `DataSource`(또는 다른 전용 리소스)에 대해서는 알 필요가 없다.

> 위에 있는 `dataSource` 빈 정의에선 `jee` 네임스페이스의 `<jndi-lookup/>` 태그를 사용한다. 자세한 내용은 [JEE 스키마](https://docs.spring.io/spring-framework/docs/5.3.2/reference/html/integration.html#xsd-schemas-jee)를 참고해라.

> JTA를 사용한다면, JDBC로 데이터에 접근하든, 하이버네이트 JPA로 접근하든, 그 외 어떤 데이터 접근 기술을 사용하든 트랜잭션 매니저 정의는 동일해야 한다. JTA 트랜잭션은 모든 트랜잭션 리소스를 사용할 수 있는 글로벌 트랜잭션이기 때문이다.

스프링 트랜잭션을 설정할 때는 어플리케이션 코드는 변경할 필요 없다. 트랜잭션 관리 방식은 단순히 설정만 바꿔서 변경할 수 있으며, 로컬에서 글로벌 트랜잭션으로 변경하거나 그 반대 상황이라고 해도 마찬가지다.

### 1.2.1. Hibernate Transaction Setup

다음 예제에서 알 수 있듯이 하이버네이트 로컬 트랜잭션을 사용하는 것도 간단하다. 이때는 어플리케이션 코드에서 하이버네이트 `Session` 인스턴스를 가져올 수 있도록 하이버네이트 `LocalSessionFactoryBean`을 정의해야 한다.

`DataSource` 빈 정의는 앞에서 보여준 로컬 JDBC 예제와 유사하므로 여기에선 생략한다.

> 이때 `DataSource`(JTA 이외의 트랜잭션 매니저가 사용하는)를 JNDI로 조회하고 자바 EE 컨테이너로 관리한다면 `DataSource`엔 트랜잭션이 적용되지 않는다. 트랜잭션은 자바 EE 컨테이너가 아닌 스프링 프레임워크가 관리한다.

여기서 `txManager` 빈 타입은 `HibernateTransactionManager`다. `DataSourceTransactionManager`가 `DataSource`를 참조해야 하는 것처럼 `HibernateTransactionManager`는 `SessionFactory`를 참조해야 한다. 다음은 `sessionFactory`와 `txManager` 빈 선언 예시다:

```xml
<bean id="sessionFactory" class="org.springframework.orm.hibernate5.LocalSessionFactoryBean">
    <property name="dataSource" ref="dataSource"/>
    <property name="mappingResources">
        <list>
            <value>org/springframework/samples/petclinic/hibernate/petclinic.hbm.xml</value>
        </list>
    </property>
    <property name="hibernateProperties">
        <value>
            hibernate.dialect=${hibernate.dialect}
        </value>
    </property>
</bean>

<bean id="txManager" class="org.springframework.orm.hibernate5.HibernateTransactionManager">
    <property name="sessionFactory" ref="sessionFactory"/>
</bean>
```

하이버네이트와 자바 EE 컨테이너가 관리하는 JTA 트랜잭션을 사용한다면, 앞에서 본 JDBC용 JTA 예제에서처럼 `JtaTransactionManager`를 사용해야 한다. 더불어 트랜잭션 코디네이터를 통해 하이버네이트에 JTA를 인지시켜주고, 가능하면 커넥션 릴리즈 모드 설정도 알려주는 게 좋다:

```xml
<bean id="sessionFactory" class="org.springframework.orm.hibernate5.LocalSessionFactoryBean">
    <property name="dataSource" ref="dataSource"/>
    <property name="mappingResources">
        <list>
            <value>org/springframework/samples/petclinic/hibernate/petclinic.hbm.xml</value>
        </list>
    </property>
    <property name="hibernateProperties">
        <value>
            hibernate.dialect=${hibernate.dialect}
            hibernate.transaction.coordinator_class=jta
            hibernate.connection.handling_mode=DELAYED_ACQUISITION_AND_RELEASE_AFTER_STATEMENT
        </value>
    </property>
</bean>

<bean id="txManager" class="org.springframework.transaction.jta.JtaTransactionManager"/>
```

아니면 `LocalSessionFactoryBean`에 `JtaTransactionManager`를 넘겨서 같은 기본값을 사용하게 만들어도 된다:

```xml
<bean id="sessionFactory" class="org.springframework.orm.hibernate5.LocalSessionFactoryBean">
    <property name="dataSource" ref="dataSource"/>
    <property name="mappingResources">
        <list>
            <value>org/springframework/samples/petclinic/hibernate/petclinic.hbm.xml</value>
        </list>
    </property>
    <property name="hibernateProperties">
        <value>
            hibernate.dialect=${hibernate.dialect}
        </value>
    </property>
    <property name="jtaTransactionManager" ref="txManager"/>
</bean>

<bean id="txManager" class="org.springframework.transaction.jta.JtaTransactionManager"/>
```

---

## 1.3. Synchronizing Resources with Transactions

여러 가지 트랜잭션 매니저를 생성하고 트랜잭션에 동기화할 관련 리소스를 연결하는 방법은 이제 명확해졌을 거다 (예를 들어 `DataSourceTransactionManager`에 JDBC `DataSource`를, `HibernateTransactionManager`에 하이버네이트 `SessionFactory` 등등). 이번 섹션에선 어플리케이션 코드로 이 리소스를 제대로 생성하고, 재사용하고, 정리하는 방법을 설명한다 (직접적으로든 간접적으로든 JDBC, 하이버네이트, JPA같은 persistence API를 사용해서). 관련 `TransactionManager`를 통해 트랜잭션 동기화를 트리거하는 방법도 함께 설명한다 (선택 사항).

### 1.3.1. High-level Synchronization Approach

주로 쓰는 방법은 스프링이 제공하는 가장 고수준 템플릿 기반 persistence 통합 API다. 또는 네이티브 ORM API를, 트랜잭션을 인식할 수 있는 팩토리 빈이나, 네이티브 리소스 팩토리를 관리하는 프록시와 함께 쓰기도 한다. 트랜잭션을 인식한다는 말은, 내부에서 리소스를 생성, 재사용, 정리해주고, 리소스 트랜잭션을 동기화하며 (선택), 예외를 매핑해준다는 뜻이다. 덕분에 사용자가 데이터에 접근할 땐 이런 보일러플레이트 코드는 생략하고, 순수한 persistence 로직에만 집중할 수 있다. 보통은 네이티브 ORM API를 사용하거나, `JdbcTemplate`을 통한 템플릿 방식으로 JDBC에 접근한다. 트랜잭션 인식 솔루션은 이 레퍼런스 문서 뒷 섹션에서 자세히 다룬다.

### 1.3.2. Low-level Synchronization Approach

저수준에서 동작하는 클래스에는 `DataSourceUtils`(JDBC 용), `EntityManagerFactoryUtils`(JPA 용), `SessionFactoryUtils`(하이버네이트 용) 등이 있다. 어플리케이션 코드에서 직접 네이티브 persistence API의 리소스 타입을 처리하고 싶으면, 이 클래스들을 사용해서 스프링 프레임워크가 관리하는 적절한 인스턴스를 가져오고, 트랜잭션을 동기화하고 (선택), 처리 중에 발생하는 예외는 [계층 구조](../daosupport#21-consistent-exception-hierarchy) API에 적절히 매핑하면 된다.

예를 들어 JDBC에선 기존처럼 `DataSource`의 `getConnection()` 메소드를 호출하는 대신에 스프링의 <span class="custom-blockquote">org.springframework.jdbc.datasource.DataSourceUtils</span> 클래스를 사용할 수 있다:

```java
Connection conn = DataSourceUtils.getConnection(dataSource);
```

기존 트랜잭션에 이미 동기화된(연결된) 커넥션이 있다면 해당 인스턴스를 반환한다. 그 외에 메소드를 호출하면 새 커넥션 생성을 트리거하는데, 새 커넥션은 기존 트랜잭션에 동기화되며 (선택), 동일 트랜잭션 내에서 재사용할 수 있다. 앞서 언급했듯이 모든 `SQLException`은 스프링 프레임워크의 unchecked `DataAccessException` 타입 계층 구조에 있는 스프링 프레임워크 `CannotGetJdbcConnectionException`으로 래핑된다. 이렇게 하면 `SQLException`에서 얻을 수 있는 정보보다 더 많은 정보를 알 수 있으며, 데이터베이스가 달라도, 심지어 persistence 기술이 달라도 이식성을 보장한다.

이 동작은 스프링 트랜잭션 관리 없이도 유효하므로 (트랜잭션 동기화는 선택이다), 스프링으로 트랜잭션을 관리하는지와는 상관없이 사용할 수 있다.

물론 스프링의 JDBC나 JPA 지원, 하이버네이트 지원을 써보고나면 보통은 `DataSourceUtils`나 다른 헬퍼 클래스 없이 개발하는 형태를 선호한다. 관련 API를 직접 사용하는 것보단 스프링 추상화를 이용하는 게 훨씬 더 만족스러울 거다. 예를 들어, 스프링 `JdbcTemplate`이나 `jdbc.object` 패키지로 JDBC 사용을 단순화하면, 뒷단에서 필요한 커넥션을 가져오기 때문에 특별히 작성해야 할 코드가 없다.

### 1.3.3. `TransactionAwareDataSourceProxy`

가장 저수준에는 `TransactionAwareDataSourceProxy` 클래스가 있다. 이 클래스는 `DataSource`를 타겟으로 하는 프록시로, 타겟 `DataSource`를 래핑해서 스프링이 관리하는 트랜잭션을 인식하게 해준다. 이 특징만 보면 자바 EE 서버가 제공하는 트랜잭션 JNDI `DataSource`와 유사하다.

반드시 기존 코드를 호출해서 표준 JDBC `DataSource` 인터페이스 구현체를 전달해야 하는 상황만 아니라면, 이 클래스는 거의 필요 없거나, 필요하다고 해도 달갑지 않을 거다. 필요하면 이 코드를 사용해도 되지만, 스프링이 관리하는 트랜잭션에 관여하게 된다. 가능하면 앞에서 설명한 좀 더 상위 수준에 있는 추상화를 사용하는 게 좋다.

---

## 1.4. Declarative Transaction Management

> 스프링 프레임워크 사용자 대부분이 선언적 트랜잭션 관리를 선택한다. 이 방식은 어플리케이션 코드에 끼치는 영향이 가장 적기 때문에, 비침습적 경량 컨테이너라는 이상에 가장 알맞다.

스프링 프레임워크의 선언적 트랜잭션 관리는 스프링 AOP(aspect-oriented programming)덕분에 가능하다. 물론 그렇다고 해서 AOP 개념을 이해해야만 트랜잭션 코드를 제대로 사용할 수 있는 건 아니다. 트랜잭션 aspect 코드는 스프링 프레임워크 배포판에서 함께 제공하므로 보일러플레이트 방식으로도 사용할 수도 있다.

스프링 프레임워크의 선언적 트랜잭션 관리는 개별 메소드 레벨까지 트랜잭션 동작을(또는 트랜잭션을 사용하지 않게) 지정할 수 있다는 점에서 EJB CMT와 유사하다. 필요하면 트랜잭션 컨텍스트 내에서 `setRollbackOnly()`를 호출하게 만들 수 있다. 두 가지 트랜잭션 관리 방식의 차이점은 다음과 같다:

- JTA에 매여있는 EJB CMT와는 달리 스프링 프레임워크의 선언적 트랜잭션 관리는 어떤 환경에서도 동작한다. 설정 파일만 잘 맞추면 JTA 트랜잭션도 사용할 수 있고, JDBC나 JPA, 하이버네이트로 로컬 트랜잭션도 사용할 수 있다.
- 스프링 프레임워크 선언적 트랜잭션 관리는 특정 EJB 클래스가 아니어도 적용할 수 있다.
- 스프링 프레임워크에선 EJB엔 없는 [롤백 규칙](#143-rolling-back-a-declarative-transaction)을 선언할 수 있다. 롤백 규칙은 프로그래밍 방식으로도, 선언 방식으로도 정의할 수 있다.
- 스프링 프레임워크에선 AOP로 트랜잭션 동작을 커스텀할 수 있다. 예를 들어 트랜잭션 롤백 시에 커스텀 동작을 실행할 수 있다. 트랜잭션 어드바이스 뿐 아니라 다른 임의의 어드바이스도 추가할 수 있다. EJB CMT였다면 컨테이너의 트랜잭션 관리에 관여하는 방법은 `setRollbackOnly()`를 제외하고는 전무하다.
- 스프링 프레임워크는 고급 어플리케이션 서버에서나 필요할 원격 호출 간 트랜잭션 컨텍스트 전파는 지원하지 않는다. 이 기능이 필요하다면 EJB를 사용하는 게 좋다. 단, 원격 호출에 걸친 트랜잭션은 일반적으로 필요한 게 아니므로, 이런 기능은 신중히 생각해본 뒤에 사용해라.

롤백 규칙은 중요한 개념이다. 롤백 규칙으로는 자동으로 롤백해야 하는 예외(throwable도)를 지정할 수 있다. 예외를 지정할 땐 자바 코드가 아닌 설정 파일에 선언할 수 있다. 트랜잭션 롤백은 `TransactionStatus` 객체의 `setRollbackOnly()` 호출로도 가능하긴 하지만, 웬만한 상황에선 `MyApplicationException`은 항상 롤백해야 한다같은 규칙을 지정할 수 있다. 롤백 규칙으로 트랜잭션 롤백을 제어했을 때의 핵심은, 비즈니스 객체가 트랜잭션 인프라에 의존하지 않는다는 거다. 예를 들어 비지니스 객체에서 스프링 트랜잭션 API나 다른 스프링 API를 임포트하지 않아도 된다.

EJB 컨테이너에선 시스템 exception(보통 런타임 exception)이 발생하면 트랜잭션을 자동으로 롤백하는 게 기본 동작이지만, EJB CMT는 어플리케이션 예외(즉, `java.rmi.RemoteException` 이외의 checked exception)에서는 트랜잭션을 자동으로 롤백하지 않는다. 선언적 트랜잭션 관리에서 스프링 기본 동작은 EJB 규칙을 따르지만 (unchecked exception에서만 자동 롤백), 이 동작은 유용하게 커스텀할 수 있다.

### 1.4.1. Understanding the Spring Framework’s Declarative Transaction Implementation

클래스에 `@Transactional` 어노테이션을 달고 설정에 `@EnableTransactionManagement`를 추가하라고 알려준다고 해서 모든 동작 방식을 이해할 거라 생각지는 않는다. 이번 섹션에선 스프링 프레임워크의 선언적 트랜잭션 인프라를 더 깊이 이해할 수 있도록, 내부에서 어떻게 트랜잭션 관련 이슈를 처리하는지 설명한다.

스프링 프레임워크의 선언적 트랜잭션 지원과 관련해서 가장 먼저 파악해야 할 개념은, 트랜잭션 지원은 [AOP 프록시를 통해](https://docs.spring.io/spring-framework/docs/5.3.2/reference/html/core.html#aop-understanding-aop-proxies) 활성화되며, 트랜잭션 어드바이스는 메타데이터(현재는 XML이나 어노테이션 기반)로 구동된다는 점이다. 트랜잭션 메타데이터를 가지고 만든 AOP 프록시는 `TransactionInterceptor`와 적당한 `TransactionManager` 구현체를 사용해 메소드 호출을 둘러싸고 트랜잭션을 실행한다.

> 스프링 AOP는 [AOP 섹션](https://docs.spring.io/spring-framework/docs/5.3.2/reference/html/core.html#aop)에서 다루고 있다

스프링 프레임워크의 `TransactionInterceptor`는 명령형과 반응형 프로그래밍 모델에 따라 트랜잭션을 관리한다. 이 인터셉터는 메소드 리턴 타입을 검사해 적당한 트랜잭션 관리 방식을 감지한다. `Publisher`나 코틀린 `Flow`(또는 하위 타입)같은 리액티브 타입을 반환하는 메소드는 반응형 트랜잭션 관리에 적합하다. `void`를 포함한 다른 모든 리턴 타입은 명령형 트랜잭션 관리 코드를 탄다.

트랜잭션 관리 방식에 따라 필요한 트랜잭션 매니저도 달라진다. 명령형 트랜잭션은 `PlatformTransactionManager`가 필요하지만, 반응형 트랜잭션은 `ReactiveTransactionManager` 구현체를 사용한다.

> 흔히 `@Transactional`은 `PlatformTransactionManager`가 관리하는, 스레드에 바인딩된 트랜잭션으로 동작하며, 현재 스레드 내에서 실행하는 모든 데이터 접근 연산에 트랜잭션을 노출한다. 주의: 메소드 안에서 새로 시작한 스레드로는 *전파하지 않는다*.
>
> `ReactiveTransactionManager`가 관리하는 반응형 트랜잭션은 스레드 로컬 속성 대신 리액터 컨텍스트를 사용한다. 따라서 모든 데이터 접근 연산은 동일한 리액티브 파이프라인 안에 있는, 동일한 리액터 컨텍스트 내에서 실행해야 한다.

다음은 트랜잭션 프록시를 통한 메소드 호출 개념을 나타낸 이미지다:

![tx](./../../images/springdataaccess/tx.png)

### 1.4.2. Example of Declarative Transaction Implementation

아래 인터페이스와 그에 따른 구현체를 생각해보자. 특정 도메인 모델에 초점을 두지 않고 트랜잭션 사용에만 집중하기 위해 이 예제에선 `Foo`, `Bar` 클래스를 플레이스홀더로 사용한다. 이 예제의 목적에 맞게 `DefaultFooService` 클래스의 각 구현체 메소드 본문에선 `UnsupportedOperationException` 인스턴스를 던지는 게 좋겠다. 이 동작을 통해 트랜잭션을 생성하고 `UnsupportedOperationException` 인스턴스에 따라 롤백되는 걸 확인해보겠다. 다음은 `FooService` 인터페이스다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
// the service interface that we want to make transactional

package x.y.service;

public interface FooService {

    Foo getFoo(String fooName);

    Foo getFoo(String fooName, String barName);

    void insertFoo(Foo foo);

    void updateFoo(Foo foo);

}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
// the service interface that we want to make transactional

package x.y.service

interface FooService {

    fun getFoo(fooName: String): Foo

    fun getFoo(fooName: String, barName: String): Foo

    fun insertFoo(foo: Foo)

    fun updateFoo(foo: Foo)
}
```

다음은 위 인터페이스를 구현한 클래스 예시다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
package x.y.service;

public class DefaultFooService implements FooService {

    @Override
    public Foo getFoo(String fooName) {
        // ...
    }

    @Override
    public Foo getFoo(String fooName, String barName) {
        // ...
    }

    @Override
    public void insertFoo(Foo foo) {
        // ...
    }

    @Override
    public void updateFoo(Foo foo) {
        // ...
    }
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
package x.y.service

class DefaultFooService : FooService {

    override fun getFoo(fooName: String): Foo {
        // ...
    }

    override fun getFoo(fooName: String, barName: String): Foo {
        // ...
    }

    override fun insertFoo(foo: Foo) {
        // ...
    }

    override fun updateFoo(foo: Foo) {
        // ...
    }
}
```

`FooService` 인터페이스의 처음 두 메소드 `getFoo(String)`과 `getFoo(String, String)`은 읽기 전용 시맨틱스를 사용하는 트랜잭션 컨텍스트에서 실행해야 하고, 나머지 `insertFoo(Foo)`와 `updateFoo(Foo)` 메소드는 읽기/쓰기 시맨틱스를 사용하는 트랜잭션 컨텍스트에서 실행해야 한다고 가정해보자. 아래 설정은 여러 단락에 이어서 자세히 설명하겠다:

```xml
<!-- from the file 'context.xml' -->
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

    <!-- this is the service object that we want to make transactional -->
    <bean id="fooService" class="x.y.service.DefaultFooService"/>

    <!-- the transactional advice (what 'happens'; see the <aop:advisor/> bean below) -->
    <tx:advice id="txAdvice" transaction-manager="txManager">
        <!-- the transactional semantics... -->
        <tx:attributes>
            <!-- all methods starting with 'get' are read-only -->
            <tx:method name="get*" read-only="true"/>
            <!-- other methods use the default transaction settings (see below) -->
            <tx:method name="*"/>
        </tx:attributes>
    </tx:advice>

    <!-- ensure that the above transactional advice runs for any execution
        of an operation defined by the FooService interface -->
    <aop:config>
        <aop:pointcut id="fooServiceOperation" expression="execution(* x.y.service.FooService.*(..))"/>
        <aop:advisor advice-ref="txAdvice" pointcut-ref="fooServiceOperation"/>
    </aop:config>

    <!-- don't forget the DataSource -->
    <bean id="dataSource" class="org.apache.commons.dbcp.BasicDataSource" destroy-method="close">
        <property name="driverClassName" value="oracle.jdbc.driver.OracleDriver"/>
        <property name="url" value="jdbc:oracle:thin:@rj-t42:1521:elvis"/>
        <property name="username" value="scott"/>
        <property name="password" value="tiger"/>
    </bean>

    <!-- similarly, don't forget the TransactionManager -->
    <bean id="txManager" class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
        <property name="dataSource" ref="dataSource"/>
    </bean>

    <!-- other <bean/> definitions here -->

</beans>
```

이 설정을 살펴보자. 여기선 서비스 객체 `fooService` 빈에 트랜잭션을 적용하고 싶다고 가정한다. 적용할 트랜잭션 시맨틱스는 `<tx:advice/>`  정의로 감싸져 있다. `<tx:advice/>`  정의를 그대로 읽으면 "`get`으로 시작하는 모든 메소드는 읽기 전용 트랜잭션의 컨텍스트에서, 그 외 모든 메소드는 디폴트 트랜잭션 시맨틱스에서 실행한다"로 읽힌다. `<tx:advice/>`  태그의 `transaction-manager` 속성엔 트랜잭션을 구동할 `TransactionManager` 빈의 이름(여기선 `txManager` 빈)을 설정한다.

> 연결하고자 하는 `TransactionManager` 빈 이름이 `transactionManager`면 트랜잭션 어드바이스(`<tx:advice/>`)의 `transaction-manager` 속성은 생략해도 된다. 반대로, 연결하려는 `TransactionManager` 빈이 다른 이름을 사용한다면 위 예제처럼 반드시 `transaction-manager` 속성을 명시해야 한다.

`<aop:config/>` 정의는 `txAdvice` 빈으로 정의한 트랜잭션 어드바이스를 실행할 적절한 포인트를 설정한다. 먼저 `FooService` 인터페이스에 정의된 모든 연산(`fooServiceOperation`)과 매칭할 포인트컷을 정의한다. 그 다음엔 어드바이저를 사용해 포인트컷을 `txAdvice`와 연관시킨다. 따라서 `fooServiceOperation`을 실행하면 `txAdvice`에 정의한 어드바이스가 실행된다.

`<aop:pointcut/>` 요소 안에서 정의한 표현식은 AspectJ 포인트컷 표현식이다. 스프링의 포인트컷 표현식에 대한 자세한 내용은 [AOP 섹션](https://docs.spring.io/spring-framework/docs/5.3.2/reference/html/core.html#aop)을 참고해라.

서비스 레이어 전체에 트랜잭션을 적용해야 한다는 요구사항도 흔하다. 제일 좋은 방법은 포인트컷 표현식을 서비스 레이어의 모든 연산과 매칭되도록 변경하는 거다. 다음 예제를 참고해라:

```xml
<aop:config>
    <aop:pointcut id="fooServiceMethods" expression="execution(* x.y.service.*.*(..))"/>
    <aop:advisor advice-ref="txAdvice" pointcut-ref="fooServiceMethods"/>
</aop:config>
```

> 이 예제에선 모든 서비스 인터페이스가 `x.y.service` 패키지에 정의돼 있다고 가정한다. 자세한 내용은 [AOP 섹션](https://docs.spring.io/spring-framework/docs/5.3.2/reference/html/core.html#aop)을 참고해라.

여기까지 설정을 분석해봤는데, "그래서 이 전체 설정이 실제로 하는 일은 뭐지?"라는 의문이 들 수 있다.

앞에서 보여준 설정은 `fooService` 빈 정의로 만든 객체를 둘러싼 트랜잭션 프록시를 생성하는 데 사용된다. 프록시는 트랜잭션 어드바이스로 설정되기 때문에, 프록시를 통해 메소드를 호출하면, 이 메소드와 연관된 트랜잭션 설정에 따라 트랜잭션을 시작, 일시 중단하고, 읽기 전용으로 마킹한다. 앞에 있는 설정을 테스트 구동하는 다음 프로그램을 생각해보자:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
public final class Boot {

    public static void main(final String[] args) throws Exception {
        ApplicationContext ctx = new ClassPathXmlApplicationContext("context.xml", Boot.class);
        FooService fooService = (FooService) ctx.getBean("fooService");
        fooService.insertFoo(new Foo());
    }
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
import org.springframework.beans.factory.getBean

fun main() {
    val ctx = ClassPathXmlApplicationContext("context.xml")
    val fooService = ctx.getBean<FooService>("fooService")
    fooService.insertFoo(Foo())
}
```

이 프로그램을 실행하면 출력되는 내용은 다음과 유사할 거다 (단순화를 위해 `DefaultFooService` 클래스의 `insertFoo(..)` 메소드에서 던진 `UnsupportedOperationException`의 Log4J 출력과 스택 트레이스 일부는 생략했다):

```java
<!-- the Spring container is starting up... -->
[AspectJInvocationContextExposingAdvisorAutoProxyCreator] - Creating implicit proxy for bean 'fooService' with 0 common interceptors and 1 specific interceptors

<!-- the DefaultFooService is actually proxied -->
[JdkDynamicAopProxy] - Creating JDK dynamic proxy for [x.y.service.DefaultFooService]

<!-- ... the insertFoo(..) method is now being invoked on the proxy -->
[TransactionInterceptor] - Getting transaction for x.y.service.FooService.insertFoo

<!-- the transactional advice kicks in here... -->
[DataSourceTransactionManager] - Creating new transaction with name [x.y.service.FooService.insertFoo]
[DataSourceTransactionManager] - Acquired Connection [org.apache.commons.dbcp.PoolableConnection@a53de4] for JDBC transaction

<!-- the insertFoo(..) method from DefaultFooService throws an exception... -->
[RuleBasedTransactionAttribute] - Applying rules to determine whether transaction should rollback on java.lang.UnsupportedOperationException
[TransactionInterceptor] - Invoking rollback for transaction on x.y.service.FooService.insertFoo due to throwable [java.lang.UnsupportedOperationException]

<!-- and the transaction is rolled back (by default, RuntimeException instances cause rollback) -->
[DataSourceTransactionManager] - Rolling back JDBC transaction on Connection [org.apache.commons.dbcp.PoolableConnection@a53de4]
[DataSourceTransactionManager] - Releasing JDBC Connection after transaction
[DataSourceUtils] - Returning JDBC Connection to DataSource

Exception in thread "main" java.lang.UnsupportedOperationException at x.y.service.DefaultFooService.insertFoo(DefaultFooService.java:14)
<!-- AOP infrastructure stack trace elements removed for clarity -->
at $Proxy0.insertFoo(Unknown Source)
at Boot.main(Boot.java:11)
```

반응형 트랜잭션 관리를 사용하려면 리액티브 타입으로 코드를 작성해야 한다.

> 스프링 프레임워크는 `ReactiveAdapterRegistry`를 사용해서 메소드 리턴 타입이 리액티브인지를 결정한다.

다음은 앞에서 사용했던 `FooService`를 수정한 코드인데, 이번에는 리액티브 타입을 사용한다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
// the reactive service interface that we want to make transactional

package x.y.service;

public interface FooService {

    Flux<Foo> getFoo(String fooName);

    Publisher<Foo> getFoo(String fooName, String barName);

    Mono<Void> insertFoo(Foo foo);

    Mono<Void> updateFoo(Foo foo);

}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
// the reactive service interface that we want to make transactional

package x.y.service

interface FooService {

    fun getFoo(fooName: String): Flow<Foo>

    fun getFoo(fooName: String, barName: String): Publisher<Foo>

    fun insertFoo(foo: Foo) : Mono<Void>

    fun updateFoo(foo: Foo) : Mono<Void>
}
```

다음은 이 인터페이스의 구현체 예시다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
package x.y.service;

public class DefaultFooService implements FooService {

    @Override
    public Flux<Foo> getFoo(String fooName) {
        // ...
    }

    @Override
    public Publisher<Foo> getFoo(String fooName, String barName) {
        // ...
    }

    @Override
    public Mono<Void> insertFoo(Foo foo) {
        // ...
    }

    @Override
    public Mono<Void> updateFoo(Foo foo) {
        // ...
    }
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
package x.y.service

class DefaultFooService : FooService {

    override fun getFoo(fooName: String): Flow<Foo> {
        // ...
    }

    override fun getFoo(fooName: String, barName: String): Publisher<Foo> {
        // ...
    }

    override fun insertFoo(foo: Foo): Mono<Void> {
        // ...
    }

    override fun updateFoo(foo: Foo): Mono<Void> {
        // ...
    }
}

```

정의한 트랜잭션 경계와 트랜잭션 속성이 의미하는 바는 명령형 트랜잭션 관리에서도, 반응형 트랜잭션 관리에서도 동일하다. 두 트랜잭션의 눈에 띄는 차이점은, 반응형 트랜잭션 관리엔 지연된 특성이 있다는 점이다. `TransactionInterceptor`는 반환된 리액티브 타입을 트랜잭션 연산자로 장식해 트랜잭션을 시작하고 정리한다. 따라서 트랜잭션을 적용한 리액티브 메소드를 호출하면 실제 트랜잭션 관리는 리액티브 타입 처리를 활성화하는 구독 타입으로 연기된다.

반응형 트랜잭션 관리의 또 다른 특징은 데이터 escaping과 관련있는데, 이는 프로그래밍 모델에 따른 자연스러운 결과라고 할 수 있다.

명령형 트랜잭션에서 메소드 반환 값은 메소드가 문제 없이 종료되면 반환되기 때문에, 일부만 실행된 코드가 메소드 클로저를 벗어나는(escape) 일은 없다.

반응형 트랜잭션 메소드는 계산 시퀀스를 나타내는 리액티브 래퍼 유형을 반환하는데, 이는 계산을 시작하고 완료하겠다는 약속이라고 볼 수 있다.

`Publisher`는 트랜잭션이 진행되는 사이 데이터를 방출할 수는 있지만 반드시 트랜잭션이 완료됐다고 볼 순 없다. 따라서 트랜잭션이 완전히 끝나야 하는 메소드는, 완료 여부를 확인하고 호출 결과를 어딘가에 버퍼링해야 한다.

### 1.4.3. Rolling Back a Declarative Transaction

이전 섹션에선 클래스에(보통 서비스 레이어 클래스) 트랜잭션 설정을 선언하는 기본 방법을 소개했다. 이번에는 간단하면서도 선언적인 방식으로 트랜잭션 롤백을 제어하는 방법을 설명한다.

트랜잭션 작업을 롤백해야 함을 스프링 프레임워크 트랜잭션 인프라에 알리는 권장 방법은 트랜잭션 컨텍스트에서 현재 실행 중인 코드로 `Exception`을 던지는 거다. 따로 처리하지 않은 `Exception`은 호출 스택에 쌓이기 때문에, 스프링 프레임워크의 트랜잭션 인프라 코드가 던져진 `Exception`을 잡아 트랜잭션을 롤백으로 마킹할지를 결정하게 된다.

디폴트 설정에서 스프링 프레임워크 트랜잭션 인프라 코드는 런타임, unchecked exception만 트랜잭션을 롤백하도록 마킹한다. 즉, 던져진 예외가 `RuntimeException` 인스턴스나 하위 클래스일 때만이다. (`Error` 인스턴스도 기본적으로 롤백한다). 트랜잭션 메소드에서 checked exception을 던져도 디폴트 설정에선 롤백하지 않는다.

트랜잭션을 롤백으로 마킹할 정확한 `Exception` 타입을 지정하는 것도 가능하다. 당연히 checked exception도 설정할 수 있다. 아래 XML은 어플리케이션 전용 checked `Exception` 타입을 롤백하는 설정이다:

```xml
<tx:advice id="txAdvice" transaction-manager="txManager">
    <tx:attributes>
    <tx:method name="get*" read-only="true" rollback-for="NoProductInStockException"/>
    <tx:method name="*"/>
    </tx:attributes>
</tx:advice>
```

예외를 던져도 롤백하고 싶지 않다면, '롤백 규칙 없음'을 지정할 수도 있다. 다음 예제는 처리되지 않은 `InstrumentNotFoundException`을 발견하더라도 그에 따른 트랜잭션은 커밋한다는 설정이다:

```xml
<tx:advice id="txAdvice">
    <tx:attributes>
    <tx:method name="updateStock" no-rollback-for="InstrumentNotFoundException"/>
    <tx:method name="*"/>
    </tx:attributes>
</tx:advice>
```

스프링 프레임워크의 트랜잭션 인프라가 예외를 캐치하고, 설정에 있는 롤백 규칙을 참고해 트랜잭션 롤백 여부를 결정할 땐, 가장 구체적인 매칭 조건을 우선시한다. 따라서 다음 설정에선 `InstrumentNotFoundException` 외에 다른 예외가 발생하면 트랜잭션을 롤백한다:

```xml
<tx:advice id="txAdvice">
    <tx:attributes>
    <tx:method name="*" rollback-for="Throwable" no-rollback-for="InstrumentNotFoundException"/>
    </tx:attributes>
</tx:advice>
```

코드로 직접 롤백이 필요한 곳을 마킹할 수도 있다. 간단하긴 하지만, 이 방법은 비지니스 로직을 침범하며, 어플리케이션 코드와 스프링 프레임워크의 트랜잭션 인프라의 결합도가 너무 높아진다. 다음은 프로그래밍 방식으로 롤백을 마킹하는 예제다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
public void resolvePosition() {
    try {
        // some business logic...
    } catch (NoProductInStockException ex) {
        // trigger rollback programmatically
        TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
    }
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
fun resolvePosition() {
    try {
        // some business logic...
    } catch (ex: NoProductInStockException) {
        // trigger rollback programmatically
        TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
    }
}
```

가급적이면 롤백은 선언적인 방식을 사용하는 게 좋다. 피치못할 경우엔 프로그래밍 방식으로 롤백을 처리해도 되지만, 결국엔 깔끔한 POJO 기반 아키텍처와의 갈림길에 서게 될거다.

### 1.4.4. Configuring Different Transactional Semantics for Different Beans

서비스 레이어에 객체가 여러 개 있고, 이 객체마다 완전히 다른 트랜잭션 설정을 적용해야 하는 상황이라고 생각해보자. 이럴 때는 `<aop:advisor/>` 요소를 별도로 만들어 각각 `pointcut`과 `advice-ref` 속성을 다르게 설정하면 된다.

비교를 위해 먼저, 서비스 레이어 클래스는 전부 루트 `x.y.service` 패키지에 정의돼 있다고 가정한다. 이 패키지(또는 하위 패키지)에 정의된 클래스의 인스턴스면서 이름이 `Service`로 끝나는 빈은 모두 기본 트랜잭션 설정을 주려면 다음과 같이 작성할 거다:

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

    <aop:config>

        <aop:pointcut id="serviceOperation"
                expression="execution(* x.y.service..*Service.*(..))"/>

        <aop:advisor pointcut-ref="serviceOperation" advice-ref="txAdvice"/>

    </aop:config>

    <!-- these two beans will be transactional... -->
    <bean id="fooService" class="x.y.service.DefaultFooService"/>
    <bean id="barService" class="x.y.service.extras.SimpleBarService"/>

    <!-- ... and these two beans won't -->
    <bean id="anotherService" class="org.xyz.SomeService"/> <!-- (not in the right package) -->
    <bean id="barManager" class="x.y.service.SimpleBarManager"/> <!-- (doesn't end in 'Service') -->

    <tx:advice id="txAdvice">
        <tx:attributes>
            <tx:method name="get*" read-only="true"/>
            <tx:method name="*"/>
        </tx:attributes>
    </tx:advice>

    <!-- other transaction infrastructure beans such as a TransactionManager omitted... -->

</beans>
```

다음 예제에서는 완전히 다른 트랜잭션 설정으로 각기 다른 빈 두 개를 설정한다:

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

    <aop:config>

        <aop:pointcut id="defaultServiceOperation"
                expression="execution(* x.y.service.*Service.*(..))"/>

        <aop:pointcut id="noTxServiceOperation"
                expression="execution(* x.y.service.ddl.DefaultDdlManager.*(..))"/>

        <aop:advisor pointcut-ref="defaultServiceOperation" advice-ref="defaultTxAdvice"/>

        <aop:advisor pointcut-ref="noTxServiceOperation" advice-ref="noTxAdvice"/>

    </aop:config>

    <!-- this bean will be transactional (see the 'defaultServiceOperation' pointcut) -->
    <bean id="fooService" class="x.y.service.DefaultFooService"/>

    <!-- this bean will also be transactional, but with totally different transactional settings -->
    <bean id="anotherFooService" class="x.y.service.ddl.DefaultDdlManager"/>

    <tx:advice id="defaultTxAdvice">
        <tx:attributes>
            <tx:method name="get*" read-only="true"/>
            <tx:method name="*"/>
        </tx:attributes>
    </tx:advice>

    <tx:advice id="noTxAdvice">
        <tx:attributes>
            <tx:method name="*" propagation="NEVER"/>
        </tx:attributes>
    </tx:advice>

    <!-- other transaction infrastructure beans such as a TransactionManager omitted... -->

</beans>
```

### 1.4.5. \<tx:advice/\> Settings

이번 섹션에선 `<tx:advice/>` 태그로 지정할 수 있는 다양한 트랜잭션 설정을 정리한다. 디폴트 `<tx:advice/>` 설정은 다음과 같다:

- [전파(propagation) 설정은](#147-transaction-propagation) `REQUIRED`다.
- 고립 수준(isolation level)은 `DEFAULT`다.
- 트랜잭션은 읽기/쓰기다.
- 트랜잭션 타임아웃 기본값은 트랜잭션 시스템의 디폴트 타임아웃 값을 따르고, 시스템이 타임아웃을 지원하지 않는다면 없음으로 설정된다.
- 모든 `RuntimeException`은 롤백을 트리거하고, 모든 checked `Exception`은 롤백하지 않는다.

이 설정들은 변경할 수 있다. 아래 테이블은 `<tx:advice/>`, `<tx:attributes/>` 태그 안에 사용하는 `<tx:method/>` 태그가 지원하는 여러 가지 속성들을 담고 있다:

**Table 1. \<tx:method/\> settings**

| Attribute         | Required? | Default    | Description                                                  |
| :---------------- | :-------- | :--------- | :----------------------------------------------------------- |
| `name`            | Yes       |            | 트랜잭션 속성을 적용할 메소드 이름. 와일드카드(\*) 문자를 사용하면 같은 트랜잭션 속성 설정을 메소드 여러 개에 적용할 수 있다 (예를 들어 `get*`, `handle*`, `on*Event` 등). |
| `propagation`     | No        | `REQUIRED` | 트랜잭션 전파 동작.                                          |
| `isolation`       | No        | `DEFAULT`  | 트랜잭션 고립 수준. propagation 설정이 `REQUIRED`나 `REQUIRES_NEW`일 때만 적용 가능. |
| `timeout`         | No        | -1         | 트랜잭션 타임아웃 (초 단위). propagation이 `REQUIRED`나 `REQUIRES_NEW`일 때만 적용 가능. |
| `read-only`       | No        | false      | 읽기/쓰기 VS 읽기 전용 트랜잭션. `REQUIRED`나 `REQUIRES_NEW`에만 적용할 것. |
| `rollback-for`    | No        |            | 롤백을 유발할 `Exception` 인스턴스 리스트로, 콤마로 구분한다. 예를 들어 <span class="custom-blockquote">com.foo.MyBusinessException,ServletException</span>. |
| `no-rollback-for` | No        |            | 롤백을 유발하지 않을 `Exception` 인스턴스 리스트로, 콤마로 구분한다. 예를 들어 <span class="custom-blockquote">com.foo.MyBusinessException,ServletException</span>. |

### 1.4.6. Using `@Transactional`

트랜잭션 설정은 XML 선언 말고도, 어노테이션 기반으로도 설정할 수 있다. 자바 소스 코드에 직접 트랜잭션 시맨틱스를 선언하면, 트랜잭션 선언과 그에 따라 트랜잭션이 적용될 코드가 훨씬 가까워진다. 어차피 트랜잭션을 적용할 코드는 웬만해선 다 이런 식으로 배포되기 때문에 결합도에 대해 지나치게 걱정할 필요는 없다.

> 스프링 자체 어노테이션 대신 표준 `javax.transaction.Transactional` 어노테이션을 사용해도 된다. 자세한 내용은 JTA 1.2 문서를 참고해라.

`@Transactional` 어노테이션이 얼마나 편리한지는 이어서 설명하는 아래 예제에서 제일 잘 드러난다. 다음 클래스 정의를 살펴보자:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
// the service class that we want to make transactional
@Transactional
public class DefaultFooService implements FooService {

    Foo getFoo(String fooName) {
        // ...
    }

    Foo getFoo(String fooName, String barName) {
        // ...
    }

    void insertFoo(Foo foo) {
        // ...
    }

    void updateFoo(Foo foo) {
        // ...
    }
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
// the service class that we want to make transactional
@Transactional
class DefaultFooService : FooService {

    override fun getFoo(fooName: String): Foo {
        // ...
    }

    override fun getFoo(fooName: String, barName: String): Foo {
        // ...
    }

    override fun insertFoo(foo: Foo) {
        // ...
    }

    override fun updateFoo(foo: Foo) {
        // ...
    }
}
```

위와 같이 클래스 레벨에 사용하는 어노테이션은, 선언하는 클래스(하위 클래스도)의 모든 메소드에 적용할 기본값을 나타낸다. 물론 메소드마다 개별로 어노테이션을 달아도 된다. 클래스 레벨 어노테이션은 클래스 계층 구조 상 위에 있는 클래스엔 적용되지 않는다는 점에 주의해라. 이런 상황에서 하위 클래스 레벨에 달린 어노테이션을 함께 타려면 메소드를 다시 선언해야 한다.

위와 같은 POJO 클래스를 스프링 컨텍스트 빈으로 정의하고 나면 이제 `@Configuration` 클래스에 `@EnableTransactionManagement` 어노테이션을 달아 빈 인스턴스에 트랜잭션을 적용할 수 있다. 자세한 내용은 [javadoc](https://docs.spring.io/spring-framework/docs/5.3.2/javadoc-api/org/springframework/transaction/annotation/EnableTransactionManagement.html)을 참고해라.

XML 설정에서 사용할 수 있는 유사한 태그는 `<tx:annotation-driven/>`이다:

```xml
<!-- from the file 'context.xml' -->
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

    <!-- this is the service object that we want to make transactional -->
    <bean id="fooService" class="x.y.service.DefaultFooService"/>

    <!-- enable the configuration of transactional behavior based on annotations -->
    <tx:annotation-driven transaction-manager="txManager"/><!-- (1) a TransactionManager is still required --> 

    <bean id="txManager" class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
        <!-- (this dependency is defined somewhere else) -->
        <property name="dataSource" ref="dataSource"/>
    </bean>

    <!-- other <bean/> definitions here -->

</beans>
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 이 설정이 빈 인스턴스에 트랜잭션을 적용한다.</small>

> 연결하고자 하는 `TransactionManager` 빈 이름이 `transactionManager`면 `<tx:annotation-driven/>` 태그의 `transaction-manager` 속성은 생략해도 된다. 반대로, 의존성을 주입하려는 `TransactionManager` 빈이 다른 이름을 사용한다면 위 예제처럼 반드시 `transaction-manager` 속성을 명시해야 한다.

반응형 트랜잭션을 사용할 메소드는 명령형 프로그래밍과는 달리 리액티브 타입을 리턴한다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
// the reactive service class that we want to make transactional
@Transactional
public class DefaultFooService implements FooService {

    Publisher<Foo> getFoo(String fooName) {
        // ...
    }

    Mono<Foo> getFoo(String fooName, String barName) {
        // ...
    }

    Mono<Void> insertFoo(Foo foo) {
        // ...
    }

    Mono<Void> updateFoo(Foo foo) {
        // ...
    }
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
// the reactive service class that we want to make transactional
@Transactional
class DefaultFooService : FooService {

    override fun getFoo(fooName: String): Flow<Foo> {
        // ...
    }

    override fun getFoo(fooName: String, barName: String): Mono<Foo> {
        // ...
    }

    override fun insertFoo(foo: Foo): Mono<Void> {
        // ...
    }

    override fun updateFoo(foo: Foo): Mono<Void> {
        // ...
    }
}
```

여기서 리턴하는 `Publisher`는 리액티브 스트림의 취소 신호와 관련해서 특별히 주의할 점이 있다. 자세한 내용은 "TransactionOperator 사용하기"에 있는 [취소 신호](#cancel-signals) 섹션을 참고해라.

> #### 메소드 가시성과 `@Transactional`
>
> 프록시를 사용할 때는 `@Transactional` 어노테이션은 public 메소드에만 적용해야 한다. protected, private 메소드나 패키지에서만 접근할 수 있는 메소드에 `@Transactional` 어노테이션을 선언한다고 해서 에러가 발생하는 건 아니지만, 이렇게 하면 메소드에 어노테이션을 선언해도 지정한 트랜잭션 설정을 활용하지 못한다. public이 아닌 메소드에 어노테이션을 달아야 한다면 AspectJ(나중에 설명한다)를 사용하는 게 좋다.
>

`@Transactional` 어노테이션은 인터페이스 정의나 인터페이스의 메소드, 클래스 정의, 클래스의 public 메소드에 적용할 수 있다. 하지만 `@Transactional` 어노테이션을 달기만 한다고 트랜잭션이 동작하는 건 아니다. `@Transactional` 어노테이션은 런타임에 `@Transactional`을 인식할 수 있는 인프라가 읽어가는 메타데이터일 뿐이며, 인프라가 이 메타데이터를 사용해 적절한 빈에 트랜잭션 동작을 설정한다. 앞선 예제에서는 `<tx:annotation-driven/>` 요소가 트랜잭션을 활성화한다.

> `@Transactional` 어노테이션은 인터페이스 대신 구체적인 클래스에(그리고 그 클래스 메소드에) 선언하길 권장한다. 인터페이스(또는 인터페이스 메소드)에도 `@Transactional` 어노테이션을 달 수 있는 건 맞지만, 이렇게 하면 인터페이스 기반 프록시를 사용할 때만 의도대로 동작한다. 클래스 기반 프록시(`proxy-target-class="true"`)나 [위빙(weaving)](https://en.wikipedia.org/wiki/Aspect_weaver#Weaving_in_AspectJ) 기반 aspect(`mode="aspectj"`)를 사용하면, 타겟 객체는 트랜잭션 프록시로 감싸지지 않는다. 자바 어노테이션은 인터페이스로 상속되지 않기 때문에, 프록시 인프라와 위빙 인프라는 트랜잭션 설정을 인식하지 못한다.

> 프록시 모드(디폴트)에선 프록시를 통한 메소드 외부 호출만 가로챈다. 다시 말해, 자체 호출(사실상 타겟 객체 메소드에서, 같은 객체에 있는 다른 메소드를 호출하는 경우)은 그 메소드가 `@Transactional`로 마킹돼 있다고 해도 런타임에 실제 트랜잭션으로 이어지지 않는다. 추가로, 프록시는 완전히 초기화돼야 제대로 동작하기 때문에, 초기화 코드(`@PostConstruct`)는 프록시 기능에 의존하면 안 된다.

자체 호출도 트랜잭션으로 감싸고 싶다면 AspectJ 모드(아래 표의 `mode` 속성 참고)를 고려해봐라. 이 모드에선 일단 프록시가 없다. 대신 위빙을 통해(즉, 바이트 코드를 수정해서), `@Transactional`을 타겟 클래스에 있는 모든 메소드의 런타임 동작으로 전환한다.

**Table 2. Annotation driven transaction settings**

| XML Attribute                                                | Annotation Attribute                                         | Default                                                      | Description                                                  |
| :----------------------------------------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| <span class="custom-blockquote">transaction-manager</span> | N/A ([javadoc](https://docs.spring.io/spring-framework/docs/5.3.2/javadoc-api/org/springframework/transaction/annotation/TransactionManagementConfigurer.html) 참고) | <span class="custom-blockquote">transactionManager</span> | 사용할 트랜잭션 매니저 이름. 위 예제처럼 트랜잭션 매니저 이름이 `transactionManager`가 아닐 때만 사용하면 된다. |
| <span class="custom-blockquote">mode</span> | <span class="custom-blockquote">mode</span> | <span class="custom-blockquote">proxy</span> | 디폴트 모드(`proxy`)에선 스프링의 AOP 프레임워크로 어노테이션이 달린 빈에 프록시를 적용한다 (앞에서 설명했던 프록시 시맨틱스대로, 프록시를 통해 메소드를 호출할 때만 유효하다). 다른 모드(`aspectj`)에선 이 대신 스프링의 AspectJ 트랜잭션 aspect로 클래스를 위빙한다. 이때는 타겟 클래스의 바이트 코드를 수정하기 때문에 메소드를 어떻게 호출해도 트랜잭션이 적용된다. AspectJ 위빙은 클래스패스에 `spring-aspects.jar`가 있어야 하며, 로드 타임 위빙(또는 컴파일 타임 위빙)을 활성화해야 한다. (로드 타임 위빙을 설정하는 자세한 방법은 [스프링 설정](https://docs.spring.io/spring-framework/docs/5.3.2/reference/html/core.html#aop-aj-ltw-spring)을 참고해라.) |
| <span class="custom-blockquote">proxy-target-class</span> | <span class="custom-blockquote">proxyTargetClass</span> | <span class="custom-blockquote">false</span> | `proxy` 모드에서만 적용된다. `@Transactional` 어노테이션을 선언한 클래스에 만들 트랜잭션 프록시 타입을 제어한다. `proxy-target-class` 속성을 `true`로 설정하면 클래스 기반 프록시를 만든다. `proxy-target-class`가 `false`이거나 이 속성을 생략하면, 표준 JDK 인터페이스 기반 프록시를 만든다. (두 프록시 타입은 [프록시 메커니즘](https://docs.spring.io/spring-framework/docs/5.3.2/reference/html/core.html#aop-proxying)에서 자세히 설명한다.) |
| <span class="custom-blockquote">order</span> | <span class="custom-blockquote">order</span> | <span class="custom-blockquote">Ordered.<br />LOWEST_PRECEDENCE</span> | `@Transactional` 어노테이션이 있는 빈에 적용할 트랜잭션 어드바이스의 순서를 정의한다. (AOP 어드바이스 순서와 관련한 자세한 규칙은 [어드바이스 순서 정하기](https://docs.spring.io/spring-framework/docs/5.3.2/reference/html/core.html#aop-ataspectj-advice-ordering)를 참고해라.) 순서를 지정하지 않으면 AOP 하위 시스템이 어드바이스 순서를 결정한다. |

> `@Transactional` 어노테이션은 디폴트로 `proxy` 모드로 처리된다. `proxy` 모드에선 메소드 호출은 프록시를 통해야만 가로 챌 수 있다. 같은 클래스 내에서 메소드를 호출하면 프록시로 요청을 가로챌 수 없다. 이런 상황에서도 요청을 가로채야 한다면 컴파일 타임 위빙이나 로드 타임 위빙과 `aspectj` 모드로 전환하는 걸 생각해봐라.

> `proxy-target-class` 속성은 `@Transactional` 어노테이션을 선언한 클래스에 만들 트랜잭션 프록시 타입을 제어한다. `proxy-target-class`를 `true`로 설정하면 클래스 기반 프록시를 만든다. `proxy-target-class`가 `false`이거나 이 속성을 생략하면, 표준 JDK 인터페이스 기반 프록시를 만든다. (두 프록시 타입은 [core.html](https://docs.spring.io/spring-framework/docs/5.3.2/reference/html/core.html#aop-proxying)에서 자세히 설명한다.)

> `@EnableTransactionManagement`, `<tx:annotation-driven/>`은 자신을 정의한 어플리케이션 컨텍스트 안에 있는 빈에서만  `@Transactional`을 찾아본다. 그렇기 때문에 `DispatcherServlet` 전용 `WebApplicationContext`에 이 설정을 추가하면, 서비스 빈이 아닌 컨트롤러 빈에서만 `@Transactional`을 확인한다. 자세한 내용은 [MVC](https://docs.spring.io/spring-framework/docs/5.3.2/reference/html/web.html#mvc-servlet)를 참고해라.

메소드의 트랜잭션 설정을 결정할 땐 구조상 가장 가까운를 설정을 우선시한다. 아래 예제에서 `DefaultFooService` 클래스는 클래스 레벨에서 트랜잭션을 읽기 전용으로 설정하지만, 같은 클래스의 `updateFoo(Foo)` 메소드에 있는 `@Transactional` 어노테이션이 클래스 레벨에 있는 트랜잭션 설정보다 우선 순위가 높다.

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
@Transactional(readOnly = true)
public class DefaultFooService implements FooService {

    public Foo getFoo(String fooName) {
        // ...
    }

    // these settings have precedence for this method
    @Transactional(readOnly = false, propagation = Propagation.REQUIRES_NEW)
    public void updateFoo(Foo foo) {
        // ...
    }
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
@Transactional(readOnly = true)
class DefaultFooService : FooService {

    override fun getFoo(fooName: String): Foo {
        // ...
    }

    // these settings have precedence for this method
    @Transactional(readOnly = false, propagation = Propagation.REQUIRES_NEW)
    override fun updateFoo(foo: Foo) {
        // ...
    }
}
```

#### `@Transactional` Settings

`@Transactional` 어노테이션은 인터페이스나, 클래스, 메소드에 반드시 트랜잭션 시맨틱스가 필요하다는 걸 지정하는 메타데이터다 (예를 들어, "이 메소드를 실행하면, 기존 트랜잭션은 일시 중단하고 읽기 전용 트랜잭션을 새로 시작한다"). 디폴트 `@Transactional` 설정은 다음과 같다:

- 전파(propagation) 설정은 `PROPAGATION_REQUIRED`.
- 고립 수준(isolation level)은 `ISOLATION_DEFAULT`.
- 읽기/쓰기 트랜잭션.
- 트랜잭션 타임아웃 기본값은 트랜잭션 시스템의 디폴트 타임아웃 값을 따르고, 시스템이 타임아웃을 지원하지 않는다면 없음으로 설정된다.
- 모든 `RuntimeException`은 롤백을 트리거하고, 모든 checked `Exception`은 롤백하지 않는다.

이 설정들은 변경할 수 있다. `@Transactional` 어노테이션이 지원하는 여러 가지 프로퍼티는 아래 테이블에 정리했다:

**Table 3. @Transactional Settings**

| Property                                                     | Type                                                         | Description                                                  |
| :----------------------------------------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| [`value`](#multiple-transaction-managers-with-transactional) | `String`                                                     | 사용할 트랜잭션을 지정하는, 생략 가능한 한정자(qualifier).   |
| [`propagation`](#147-transaction-propagation)                | `enum`: `Propagation`                                        | 생략 가능한 전파 설정.                                       |
| `isolation`                                                  | `enum`: `Isolation`                                          | 생략 가능한 고립 수준. propagation이 `REQUIRED`나 `REQUIRES_NEW`일 때만 적용 할 것. |
| `timeout`                                                    | `int` (초 단위)                                              | 생략 가능한 트랜잭션 타임 아웃. propagation이 `REQUIRED`나 `REQUIRES_NEW`일 때만 적용 할 것. |
| `readOnly`                                                   | `boolean`                                                    | 읽기/쓰기 VS 읽기 전용 트랜잭션. `REQUIRED`나 `REQUIRES_NEW`에만 적용 가능. |
| `rollbackFor`                                                | `Throwable`을 상속한 `Class` 객체의 배열.                    | 롤백을 유발해야 하는 exception 클래스 배열로, 생략 가능하다. |
| `rollbackForClassName`                                       | 클래스 이름의 배열. `Throwable`을 상속한 클래스만 가능하다.  | 롤백을 유발해야 하는 exception 클래스 이름의 배열로, 생략 가능하다. |
| `noRollbackFor`                                              | `Throwable`을 상속한 `Class` 객체의 배열.                    | 롤백을 유발하지 않을 exception 클래스 배열로, 생략 가능하다. |
| `noRollbackForClassName`                                     | `Throwable`을 상속한 클래스 이름(`String`)의 배열.           | 롤백을 유발하지 않을 exception 클래스 이름의 배열로, 생략 가능하다. |
| `label`                                                      | 트랜잭션을 나타내는 설명을 추가할 수 있는 `String` 레이블 배열. | 레이블은 트랜잭션 매니저가 평가하며, 구현체에 따라 실제 트랜잭션 동작과 연관시킬 수도 있다. |

현재로써는 트랜잭션 이름을 직접 명시하는 기능은 없다. 여기서 말하는 '이름'이란, 트랜잭션 모니터링과(WebLogic의 트랜잭션 모니터 등) 로그에서 확인할 수 있을만한 트랜잭션 이름을 의미한다. 선언적 트랜잭션에서 트랜잭션 이름은 항상 클래스 풀 네임 + `.` + 트랜잭션 어드바이스를 적용한 클래스의 메소드 이름이다. 예를 들어, `BusinessService` 클래스의 `handlePayment(..)` 메소드가 트랜잭션을 시작했을 때의 트랜잭션 이름은 `com.example.BusinessService.handlePayment`다.

#### Multiple Transaction Managers with `@Transactional`

스프링 어플리케이션 대부분은 트랜잭션 매니저 하나만 있으면 되지만, 단일 어플리케이션 안에서 독립적인 트랜잭션 매니저가 여러 개 필요한 상황도 있을 수 있다. 원한다면 `@Transactional` 어노테이션의 `value`, `transactionManager` 속성으로 사용할 `TransactionManager` 식별자를 지정할 수 있다. 식별자엔 트랜잭션 매니저의 빈 이름이나 한정자(qualifier)를 사용할 수 있다. 예를 들어, 다음 자바 코드는 한정자 표기법을 통해 어플리케이션 컨텍스트에 있는 트랜잭션 매니저 빈을 연결한다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
public class TransactionalService {

    @Transactional("order")
    public void setSomething(String name) { ... }

    @Transactional("account")
    public void doSomething() { ... }

    @Transactional("reactive-account")
    public Mono<Void> doSomethingReactive() { ... }
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
class TransactionalService {

    @Transactional("order")
    fun setSomething(name: String) {
        // ...
    }

    @Transactional("account")
    fun doSomething() {
        // ...
    }

    @Transactional("reactive-account")
    fun doSomethingReactive(): Mono<Void> {
        // ...
    }
}
```

다음은 트랜잭션 매니저 빈들의 선언부다:

```xml
<tx:annotation-driven/>

    <bean id="transactionManager1" class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
        ...
        <qualifier value="order"/>
    </bean>

    <bean id="transactionManager2" class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
        ...
        <qualifier value="account"/>
    </bean>

    <bean id="transactionManager3" class="org.springframework.data.r2dbc.connectionfactory.R2dbcTransactionManager">
        ...
        <qualifier value="reactive-account"/>
    </bean>
```

`TransactionalService`의 각 메소드는 `order`, `account`, `reactive-account` 한정자로 구분되는 별도의 트랜잭션 매니저에서 실행된다. 한정자에 해당하는 `TransactionManager`가 딱히 없을 때도 디폴트 `<tx:annotation-driven>` 타겟 빈 이름인 `transactionManager`를 사용한다.

#### Custom Composed Annotations

동일한 `@Transactional` 속성을 여러 메소드에 반복하고 있다면, [스프링의 메타 어노테이션 기능](https://docs.spring.io/spring-framework/docs/5.3.2/reference/html/core.html#beans-meta-annotations)을 통해 특정 유스 케이스를 커스텀 어노테이션으로 정의할 수 있다. 예를 들어 다음 어노테이션 정의를 생각해보자:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
@Target({ElementType.METHOD, ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Transactional(transactionManager = "order", label = "causal-consistency")
public @interface OrderTx {
}

@Target({ElementType.METHOD, ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Transactional(transactionManager = "account", label = "retryable")
public @interface AccountTx {
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
@Target(AnnotationTarget.FUNCTION, AnnotationTarget.TYPE)
@Retention(AnnotationRetention.RUNTIME)
@Transactional(transactionManager = "order", label = ["causal-consistency"])
annotation class OrderTx

@Target(AnnotationTarget.FUNCTION, AnnotationTarget.TYPE)
@Retention(AnnotationRetention.RUNTIME)
@Transactional(transactionManager = "account", label = ["retryable"])
annotation class AccountTx
```

앞 섹션에서 다뤘던 예제는, 위 어노테이션을 사용하면 이렇게 바뀐다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
public class TransactionalService {

    @OrderTx
    public void setSomething(String name) {
        // ...
    }

    @AccountTx
    public void doSomething() {
        // ...
    }
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
class TransactionalService {

    @OrderTx
    fun setSomething(name: String) {
        // ...
    }

    @AccountTx
    fun doSomething() {
        // ...
    }
}
```

이 예제에선 트랜잭션 매니저 한정자와 트랜잭션 레이블을 정의했지만, 전파 동작, 롤백 규칙, 타임 아웃 등 다른 기능도 얼마든지 넣을 수 있다.

### 1.4.7. Transaction Propagation

이번 섹션에선 트랜잭션 전파가 스프링에서의 의미하는 바를 설명한다. 트랜잭션 전파에 대한 소개 섹션이 아니라는 점을 명심해라. 그보단 트랜잭션 전파와 관련한 스프링의 동작 방식을 설명한다.

스프링에 트랜잭션 관리를 맡기려면, 물리적 트랜잭션과 논리적 트랜잭션의 차이와, 이에 따라 어떻게 전파 설정이 적용되는지를 알아야 한다.

#### Understanding `PROPAGATION_REQUIRED`

![tx prop required](./../../images/springdataaccess/tx_prop_required.png)

`PROPAGATION_REQUIRED`는 트랜잭션이 아직 없다면 현재 스코프에 물리적 트랜잭션을, 더 큰 스코프에 정의된 '외부' 트랜잭션이 있다면 이 트랜잭션에 참여하는 물리적 트랜잭션을 강제한다. 같은 스레드 내에 있는 일반적인 호출 스택에 알맞은 기본 설정이다 (예를 들어, 모든 리소스는 서비스 레벨 트랜잭션에 참여해야 하며, 서비스 파사드가 여러 가지 레포지토리 메소드에 위임하는 구조).

> 기본적으로, 트랜잭션이 외부 스코프에 있는 트랜잭션에 참여하게 되면, 로컬 격리 수준, 타임아웃, 읽기 전용 플래그(있으면)는 묵시적으로 무시하고 외부 스코프의 특성을 조인한다. 격리 수준이 다른 트랜잭션의 참여를 막으려면 트랜잭션 매니저의 `validateExistingTransactions` 플래그를 `true`로 전환하는 게 좋다. 이 비관용 모드에선 읽기 전용 플래그가 일치하지 않을 때도(즉, 읽기 전용 외부 스코프에 읽기/쓰기 트랜잭션이 참여할 때) 트랜잭션 참여를 거부한다.

전파 설정이 `PROPAGATION_REQUIRED`면, 메소드마다 논리적인 트랜잭션 스코프를 생성한다. 내부 트랜잭션 스코프는 외부 트랜잭션 스코프와 논리적으로 독립되기 때문에, 논리적인 트랜잭션 스코프는 개별적으로 롤백 only 상태를 결정할 수 있다. 표준 `PROPAGATION_REQUIRED` 동작에선 모든 논리적 스코프는 동일한 물리적 트랜잭션에 매핑된다. 따라서 내부 트랜잭션 스코프의 롤백 only 마커에 따라 외부 트랜잭션은 실제로 커밋할 수도 있고 커밋하지 않을 수도 있다.

하지만 내부 트랜잭션 스코프에서 롤백 only 마커를 설정하면, 외부 트랜잭션은 스스로 롤백을 결정한게 아니기 때문에 이런 식의 롤백(내부 트랜잭션 스코프에 의해 암암리에 트리거됨)은 외부 트랜잭션 입장에선 예상치 못한 동작이다. 따라서 `UnexpectedRollbackException`이 발생한다. 이는 의도한 것인데, 트랜잭션을 호출한 쪽에서 커밋이 실제로 수행되지 않았는데도 커밋됐다고 오해하지 않기 위함이다. 내부 트랜잭션이 트랜잭션을 롤백 only로 마킹해도 외부에서 알 수 없으면 커밋을 호출할 거다. 롤백했음을 명확히 알리려면 외부 호출자에게 `UnexpectedRollbackException`을 전달해야 한다.

#### Understanding `PROPAGATION_REQUIRES_NEW`

![tx prop required_new](./../../images/springdataaccess/tx_prop_requires_new.png)

`PROPAGATION_REQUIRES_NEW`는 `PROPAGATION_REQUIRED`와 달리, 트랜잭션 스코프마다 항상 독립적인 물리적 트랜잭션을 사용하며, 외부 스코프에 있는 기존 트랜잭션엔 참여하지 않는다. 이렇게 되면 리소스 트랜잭션이 다르기 때문에, 내부 트랜잭션의 롤백 상태와는 상관 없이 내부 트랜잭션이 완료돼 잠금이 해제되는 즉시 외부 트랜잭션을 독립적으로 커밋하거나 롤백할 수 있다. 이렇게 독립적인 내부 트랜잭션은 자체 격리 수준, 타임아웃, 읽기 전용 설정을 선언할 수 있으며 외부 트랜잭션의 특성을 상속하지 않는다.

#### Understanding `PROPAGATION_NESTED`

`PROPAGATION_NESTED`는 롤백할 수 있는 세이브 포인트가 여러 개 있는 단일 물리적 트랜잭션을 사용한다. 이때는 일부만 롤백할 수 있기 때문에, 내부 트랜잭션 스코프는 자신의 스코프에 롤백을 트리거할 수 있으며, 외부 트랜잭션은 일부 연산이 롤백 됐음에도 물리적 트랜잭션을 계속 이어나갈 수 있다. 이 설정은 보통 JDBC 세이브 포인트에 매핑되므로 JDBC 리소스 트랜잭션에서만 동작한다. 스프링의 [`DataSourceTransactionManager`](https://docs.spring.io/spring-framework/docs/5.3.2/javadoc-api/org/springframework/jdbc/datasource/DataSourceTransactionManager.html)를 참고해라.

### 1.4.8. Advising Transactional Operations

트랜잭션 연산과 함께 어떤 기본적인 프로파일링 어드바이스도 실행해야 한다고 생각해보자. `<tx:annotation-driven/>` 컨텍스트 안에는 설정을 어떻게 넣어야 할까?

`updateFoo(Foo)` 메소드를 실행하면 다음 동작이 실행됐으면 한다:

- 설정한 프로파일링 aspect를 시작한다.
- 트랜잭션 어드바이스를 실행한다.
- 어드바이스를 적용한 객체의 메소드를 실행한다.
- 트랜잭션을 커밋한다.
- 프로파일링 aspect가 트랜잭션을 적용한 메소드의 전체 실행 시간을 리포트한다.

> 이 챕터에선 AOP를 자세히 다루진 않을 거다 (트랜잭션에 적용하는 경우만 빼고). 전반적인 AOP와 설정에 대한 자세한 내용은 [AOP](https://docs.spring.io/spring-framework/docs/5.3.2/reference/html/core.html#aop)를 참고해라.

다음은 앞에서 말한 간단한 프로파일링 aspect 코드다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
package x.y;

import org.aspectj.lang.ProceedingJoinPoint;
import org.springframework.util.StopWatch;
import org.springframework.core.Ordered;

public class SimpleProfiler implements Ordered {

    private int order;

    // allows us to control the ordering of advice
    public int getOrder() {
        return this.order;
    }

    public void setOrder(int order) {
        this.order = order;
    }

    // this method is the around advice
    public Object profile(ProceedingJoinPoint call) throws Throwable {
        Object returnValue;
        StopWatch clock = new StopWatch(getClass().getName());
        try {
            clock.start(call.toShortString());
            returnValue = call.proceed();
        } finally {
            clock.stop();
            System.out.println(clock.prettyPrint());
        }
        return returnValue;
    }
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
class SimpleProfiler : Ordered {

    private var order: Int = 0

    // allows us to control the ordering of advice
    override fun getOrder(): Int {
        return this.order
    }

    fun setOrder(order: Int) {
        this.order = order
    }

    // this method is the around advice
    fun profile(call: ProceedingJoinPoint): Any {
        var returnValue: Any
        val clock = StopWatch(javaClass.name)
        try {
            clock.start(call.toShortString())
            returnValue = call.proceed()
        } finally {
            clock.stop()
            println(clock.prettyPrint())
        }
        return returnValue
    }
}
```

어드바이스 순서는 `Ordered` 인터페이스로 제어한다. 어드바이스 순서에 대한 자세한 내용은 [어드바이스 순서 정하기](https://docs.spring.io/spring-framework/docs/5.3.2/reference/html/core.html#aop-ataspectj-advice-ordering)를 참고해라.

다음은 원하는 순서에 따라 프로파일링과 트랜잭션 aspect를 적용한 `fooService` 빈을 만드는 설정이다:

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

    <bean id="fooService" class="x.y.service.DefaultFooService"/>

    <!-- this is the aspect -->
    <bean id="profiler" class="x.y.SimpleProfiler">
        <!-- run before the transactional advice (hence the lower order number) -->
        <property name="order" value="1"/>
    </bean>

    <tx:annotation-driven transaction-manager="txManager" order="200"/>

    <aop:config>
            <!-- this advice runs around the transactional advice -->
            <aop:aspect id="profilingAspect" ref="profiler">
                <aop:pointcut id="serviceMethodWithReturnValue"
                        expression="execution(!void x.y..*Service.*(..))"/>
                <aop:around method="profile" pointcut-ref="serviceMethodWithReturnValue"/>
            </aop:aspect>
    </aop:config>

    <bean id="dataSource" class="org.apache.commons.dbcp.BasicDataSource" destroy-method="close">
        <property name="driverClassName" value="oracle.jdbc.driver.OracleDriver"/>
        <property name="url" value="jdbc:oracle:thin:@rj-t42:1521:elvis"/>
        <property name="username" value="scott"/>
        <property name="password" value="tiger"/>
    </bean>

    <bean id="txManager" class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
        <property name="dataSource" ref="dataSource"/>
    </bean>

</beans>
```

다른 aspect도 이와 유사한 방식으로 얼마든지 추가할 수 있다.

다음 설정도 앞에 있는 두 예제와 동일한 설정이지만, 이번엔 순수 XML 선언 방식을 사용한다:

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

    <bean id="fooService" class="x.y.service.DefaultFooService"/>

    <!-- the profiling advice -->
    <bean id="profiler" class="x.y.SimpleProfiler">
        <!-- run before the transactional advice (hence the lower order number) -->
        <property name="order" value="1"/>
    </bean>

    <aop:config>
        <aop:pointcut id="entryPointMethod" expression="execution(* x.y..*Service.*(..))"/>
        <!-- runs after the profiling advice (c.f. the order attribute) -->

        <aop:advisor advice-ref="txAdvice" pointcut-ref="entryPointMethod" order="2"/>
        <!-- order value is higher than the profiling aspect -->

        <aop:aspect id="profilingAspect" ref="profiler">
            <aop:pointcut id="serviceMethodWithReturnValue"
                    expression="execution(!void x.y..*Service.*(..))"/>
            <aop:around method="profile" pointcut-ref="serviceMethodWithReturnValue"/>
        </aop:aspect>

    </aop:config>

    <tx:advice id="txAdvice" transaction-manager="txManager">
        <tx:attributes>
            <tx:method name="get*" read-only="true"/>
            <tx:method name="*"/>
        </tx:attributes>
    </tx:advice>

    <!-- other <bean/> definitions such as a DataSource and a TransactionManager here -->

</beans>
```

이 설정은 순서에 맞게 프로파일링, 트랜잭션 aspect를 적용한 `fooService` 빈을 만든다. 프로파일링 어드바이스를 트랜잭션 어드바이스 안쪽에서 실행하려면, 프로파일링 aspect 빈의 `order` 프로퍼티를 트랜잭션 어드바이스의 `order` 값보다 큰 값으로 바꾸면 된다.

다른 aspect도 같은 방법으로 설정할 수 있다.

### 1.4.9. Using `@Transactional` with AspectJ

AspectJ aspect를 사용하면 스프링 컨테이너 외부에서도 스프링 프레임워크의 `@Transactional`을 쓸 수 있다. 먼저, 클래스에(필요하면 클래스 메소드에) `@Transactional` 어노테이션을 선언하고, 어플리케이션을 `spring-aspects.jar` 파일에 정의된 <span class="custom-blockquote">org.springframework.transaction.aspectj.AnnotationTransactionAspect</span>에 연결(위빙)해라. aspect엔 트랜잭션 매니저도 설정해야 한다. 스프링 프레임워크의 IoC 컨테이너로 aspect에 의존성을 주입해도 된다. 트랜잭션 관리 aspect를 설정하는 가장 쉬운 방법은 [@Transactional 사용하기](#transactional-settings)에서 설명한대로 `<tx:annotation-driven/>` 요소를 사용해 `mode` 속성을 `aspectj`로 지정하는 거다. 여기서는 스프링 컨테이너 외부에서 실행할 어플리케이션에 초점을 두기 때문에 트랜잭션을 프로그래밍 방식으로 적용하는 방법을 보여주겠다.

> 계속 하기 전에 [`@Transactional` 사용하기](#146-using-transactional)와 [AOP](https://docs.spring.io/spring-framework/docs/5.3.2/reference/html/core.html#aop)를 모두 읽어보면 좀 더 이해하기 쉬울 거다.

다음 예제는 `AnnotationTransactionAspect`가 사용할 트랜잭션 매니저를 만들고 설정하는 방법을 보여준다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
// construct an appropriate transaction manager
DataSourceTransactionManager txManager = new DataSourceTransactionManager(getDataSource());

// configure the AnnotationTransactionAspect to use it; this must be done before executing any transactional methods
AnnotationTransactionAspect.aspectOf().setTransactionManager(txManager);
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
// construct an appropriate transaction manager
val txManager = DataSourceTransactionManager(getDataSource())

// configure the AnnotationTransactionAspect to use it; this must be done before executing any transactional methods
AnnotationTransactionAspect.aspectOf().transactionManager = txManager
```

> AspectJ aspect를 사용하려면 클래스가 구현한 인터페이스(있다면)가 아닌, 구현체 클래스에 어노테이션을 달아야 한다 (또는 해당 클래스의 메소드에 달거나 아니면 둘 다). AspectJ는 인터페이스의 어노테이션은 상속되지 않는다는 자바 규칙을 그대로 따른다.

클래스의 `@Transactional` 어노테이션은 이 클래스에 있는 모든 public 메소드를 실행할 때 적용할 디폴트 트랜잭션 시맨틱스를 지정한다.

클래스 안에 있는 메소드의 `@Transactional` 어노테이션은 클래스 어노테이션(있다면)의 디폴트 트랜잭션 시맨틱스를 재정의한다. 메소드 가시성에 관계없이 모든 메소드에 어노테이션을 선언할 수 있다.

어플리케이션을 `AnnotationTransactionAspect`로 위빙하려면 AspectJ로 어플리케이션을 빌드하거나([AspectJ 개발 가이드](https://www.eclipse.org/aspectj/doc/released/devguide/index.html) 참고), 로드 타임 위빙을 사용해야 한다. AspectJ를 사용한 로드 타임 위빙은 [스프링 프레임워크에서 AspectJ로 로드 타임 위빙 적용하기](https://docs.spring.io/spring-framework/docs/5.3.2/reference/html/core.html#aop-aj-ltw)를 참고해라.

---

## 1.5. Programmatic Transaction Management

스프링 프레임워크는 프로그래밍 방식으로 트랜잭션을 관리할 수 있는 두 가지 수단을 제공한다:

- `TransactionTemplate` 또는 `TransactionalOperator`.
- `TransactionManager` 구현체로 직접.

프로그래밍 방식 트랜잭션 관리에선 일반적으로 명령형 플로우는 `TransactionTemplate`을, 리액티브 코드는 `TransactionalOperator`를 권장한다. 두 번째 방법은 JTA `UserTransaction` API를 사용하는 것과 비슷하지만 예외를 처리하기가 조금 더 쉽다.

### 1.5.1. Using the `TransactionTemplate`

`TransactionTemplate`은 `JdbcTemplate`같은 다른 스프링 템플릿과 사용법이 동일하다. 콜백 방식을 사용하기 때문에 (트랜잭션 리소스를 획득하고 해지하는 보일러플레이트를 없애준다) 어플리케이션 코드에선 의도한 동작에만 집중할 수 있다.

> 다음 예제에서도 알 수 있듯이, `TransactionTemplate`을 사용하면 스프링의 트랜잭션 인프라와 API와의 결합도가 굉장히 올라간다. 프로그래밍 방식 트랜잭션 관리가 개발 요구 사항에 정말 적합한지는 본인의 판단에 맡긴다.

직접 `TransactionTemplate`을 사용해 트랜잭션 컨텍스트에서 실행하는 어플리케이션 코드는 다음 예제처럼 작성한다. 어플리케이션 개발자는 `TransactionCallback` 구현체(보통은 익명 내부 클래스)에 트랜잭션 컨텍스트에서 실행해야 하는 코드를 작성하게 된다. 그런 다음 커스텀 `TransactionCallback` 인스턴스를 `TransactionTemplate`의 `execute(..)` 메소드에 전달하면 된다. 그 방법은 다음 예제를 참고해라:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
public class SimpleService implements Service {

    // single TransactionTemplate shared amongst all methods in this instance
    private final TransactionTemplate transactionTemplate;

    // use constructor-injection to supply the PlatformTransactionManager
    public SimpleService(PlatformTransactionManager transactionManager) {
        this.transactionTemplate = new TransactionTemplate(transactionManager);
    }

    public Object someServiceMethod() {
        return transactionTemplate.execute(new TransactionCallback() {
            // the code in this method runs in a transactional context
            public Object doInTransaction(TransactionStatus status) {
                updateOperation1();
                return resultOfUpdateOperation2();
            }
        });
    }
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
// use constructor-injection to supply the PlatformTransactionManager
class SimpleService(transactionManager: PlatformTransactionManager) : Service {

    // single TransactionTemplate shared amongst all methods in this instance
    private val transactionTemplate = TransactionTemplate(transactionManager)

    fun someServiceMethod() = transactionTemplate.execute<Any?> {
        updateOperation1()
        resultOfUpdateOperation2()
    }
}
```

반환 값이 없다면, 간편하게 `TransactionCallbackWithoutResult` 클래스를 익명 클래스로 활용할 수 있다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
transactionTemplate.execute(new TransactionCallbackWithoutResult() {
    protected void doInTransactionWithoutResult(TransactionStatus status) {
        updateOperation1();
        updateOperation2();
    }
});
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
transactionTemplate.execute(object : TransactionCallbackWithoutResult() {
    override fun doInTransactionWithoutResult(status: TransactionStatus) {
        updateOperation1()
        updateOperation2()
    }
})
```

콜백 안에서 트랜잭션을 롤백하려면, 다음과 같이 전달받은 `TransactionStatus` 객체에서 `setRollbackOnly()` 메소드를 호출하면 된다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
transactionTemplate.execute(new TransactionCallbackWithoutResult() {

    protected void doInTransactionWithoutResult(TransactionStatus status) {
        try {
            updateOperation1();
            updateOperation2();
        } catch (SomeBusinessException ex) {
            status.setRollbackOnly();
        }
    }
});
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
transactionTemplate.execute(object : TransactionCallbackWithoutResult() {

    override fun doInTransactionWithoutResult(status: TransactionStatus) {
        try {
            updateOperation1()
            updateOperation2()
        } catch (ex: SomeBusinessException) {
            status.setRollbackOnly()
        }
    }
})
```

#### Specifying Transaction Settings

`TransactionTemplate`의 트랜잭션 설정은 코드나 설정 파일로 지정할 수 있다 (전파 모드, 격리 수준, 타임아웃 등). 기본적으로 `TransactionTemplate` 인스턴스는 [디폴트 트랜잭션 설정](#145-txadvice-settings)을 가지고 있다. 다음 예제는 `TransactionTemplate`에서 사용할 트랜잭션 설정을 프로그래밍 방식으로 커스텀하고 있다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
public class SimpleService implements Service {

    private final TransactionTemplate transactionTemplate;

    public SimpleService(PlatformTransactionManager transactionManager) {
        this.transactionTemplate = new TransactionTemplate(transactionManager);

        // the transaction settings can be set here explicitly if so desired
        this.transactionTemplate.setIsolationLevel(TransactionDefinition.ISOLATION_READ_UNCOMMITTED);
        this.transactionTemplate.setTimeout(30); // 30 seconds
        // and so forth...
    }
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
class SimpleService(transactionManager: PlatformTransactionManager) : Service {

    private val transactionTemplate = TransactionTemplate(transactionManager).apply {
        // the transaction settings can be set here explicitly if so desired
        isolationLevel = TransactionDefinition.ISOLATION_READ_UNCOMMITTED
        timeout = 30 // 30 seconds
        // and so forth...
    }
}
```

다음 예제는 몇 가지 트랜잭션 설정을 커스텀한 `TransactionTemplate`을 스프링 XML 설정으로 정의한다:

```xml
<bean id="sharedTransactionTemplate"
        class="org.springframework.transaction.support.TransactionTemplate">
    <property name="isolationLevelName" value="ISOLATION_READ_UNCOMMITTED"/>
    <property name="timeout" value="30"/>
</bean>
```

이제 필요한 서비스에 자유롭게 `sharedTransactionTemplate`을 주입하면 된다.

마지막으로, `TransactionTemplate` 클래스 인스턴스는 실행 상태를 유지하지 않기 때문에 thread-safe하다. 단, `TransactionTemplate` 인스턴스는 설정 상태는 유지한다. 따라서 `TransactionTemplate` 인스턴스 하나를 여러 클래스에서 공유해도 좋지만, `TransactionTemplate`을 다른 설정(예를 들어 격리 수준이 다른)으로 사용해야 한다면, `TransactionTemplate` 인스턴스를 별도로 두 개 만들어야 한다.

### 1.5.2. Using the `TransactionOperator`

`TransactionOperator`는 다른 리액티브 연산자와 설계가 유사하다. 콜백 방식을 사용하기 때문에 (트랜잭션 리소스를 획득하고 해지하는 보일러플레이트를 없애준다) 어플리케이션 코드에선 의도한 동작에만 집중할 수 있다.

> 다음 예제에서도 알 수 있듯이, `TransactionOperator`를 사용하면 스프링의 트랜잭션 인프라와 API와의 결합도가 굉장히 올라간다. 프로그래밍 방식 트랜잭션 관리가 개발 요구 사항에 정말 적합한지는 본인의 판단에 맡긴다.

직접 `TransactionOperator`를 사용해 트랜잭션 컨텍스트에서 실행하는 어플리케이션 코드는 다음 예제처럼 작성한다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
public class SimpleService implements Service {

    // single TransactionOperator shared amongst all methods in this instance
    private final TransactionalOperator transactionalOperator;

    // use constructor-injection to supply the ReactiveTransactionManager
    public SimpleService(ReactiveTransactionManager transactionManager) {
        this.transactionOperator = TransactionalOperator.create(transactionManager);
    }

    public Mono<Object> someServiceMethod() {

        // the code in this method runs in a transactional context

        Mono<Object> update = updateOperation1();

        return update.then(resultOfUpdateOperation2).as(transactionalOperator::transactional);
    }
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
// use constructor-injection to supply the ReactiveTransactionManager
class SimpleService(transactionManager: ReactiveTransactionManager) : Service {

    // single TransactionalOperator shared amongst all methods in this instance
    private val transactionalOperator = TransactionalOperator.create(transactionManager)

    suspend fun someServiceMethod() = transactionalOperator.executeAndAwait<Any?> {
        updateOperation1()
        resultOfUpdateOperation2()
    }
}
```

`TransactionalOperator`는 두 가지 스타일로 사용할 수 있다:

- 프로젝트 리액터 타입을 사용한 연산자 스타일 (<span class="custom-blockquote">mono.as(transactionalOperator::transactional)</span>)
- 그 외 타입에선 콜백 스타일 (<span class="custom-blockquote">transactionalOperator.execute(TransactionCallback\<T\>)</span>)

콜백 안에서 트랜잭션을 롤백하려면, 다음과 같이 전달받은 `ReactiveTransaction` 객체에서 `setRollbackOnly()` 메소드를 호출하면 된다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
transactionalOperator.execute(new TransactionCallback<>() {

    public Mono<Object> doInTransaction(ReactiveTransaction status) {
        return updateOperation1().then(updateOperation2)
                    .doOnError(SomeBusinessException.class, e -> status.setRollbackOnly());
        }
    }
});
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
transactionalOperator.execute(object : TransactionCallback() {

    override fun doInTransactionWithoutResult(status: ReactiveTransaction) {
        updateOperation1().then(updateOperation2)
                    .doOnError(SomeBusinessException.class, e -> status.setRollbackOnly())
    }
})
```

#### Cancel Signals

리액티브 스트림에선 `Subscriber`가 `Subscription`을 취소하고 `Publisher`를 멈출 수 있다. 다른 라이브러리와 마찬가지로 프로젝트 리액터에선 `next()`, `take(long)`, `timeout(Duration)`같은 연산자로 취소 신호를 발행할 수 있다. 취소한 이유가 오류 때문인지, 아니며 단순히 더 이상 컨슘하길 원하지 않는 건지 알아낼 방법은 없다. 5.3 버전부터 취소 신호를 받으면 롤백을 진행한다. 그렇기 때문에 트랜잭션 `Publisher`의 다운스트림에선 연산자를 주의해서 사용해야 한다. 특히 `Flux`나 다른 multi-value `Publisher`에선, 트랜잭션을 완료하려면 전체 출력을 컨슘해야 한다.

#### Specifying Transaction Settings

`TransactionalOperator`의 트랜잭션 설정을 직접 지정할 수도 있다 (전파 모드, 격리 수준, 타임아웃 등). 기본적으로 `TransactionalOperator` 인스턴스는 [디폴트 트랜잭션 설정](#145-txadvice-settings)을 가지고 있다. 다음은 `TransactionalOperator`에서 사용할 트랜잭션 설정을 커스텀하는 예제다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
public class SimpleService implements Service {

    private final TransactionalOperator transactionalOperator;

    public SimpleService(ReactiveTransactionManager transactionManager) {
        DefaultTransactionDefinition definition = new DefaultTransactionDefinition();

        // the transaction settings can be set here explicitly if so desired
        definition.setIsolationLevel(TransactionDefinition.ISOLATION_READ_UNCOMMITTED);
        definition.setTimeout(30); // 30 seconds
        // and so forth...

        this.transactionalOperator = TransactionalOperator.create(transactionManager, definition);
    }
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
class SimpleService(transactionManager: ReactiveTransactionManager) : Service {

    private val definition = DefaultTransactionDefinition().apply {
        // the transaction settings can be set here explicitly if so desired
        isolationLevel = TransactionDefinition.ISOLATION_READ_UNCOMMITTED
        timeout = 30 // 30 seconds
        // and so forth...
    }
    private val transactionalOperator = TransactionalOperator(transactionManager, definition)
}
```

### 1.5.3. Using the `TransactionManager`

이어지는 섹션에선 명령형 트랜잭션과 반응형 트랜잭션 매니저를 프로그래밍 방식으로 사용하는 방법을 설명한다.

#### Using the `PlatformTransactionManager`

명령형 트랜잭션에선 <span class="custom-blockquote">org.springframework.transaction.PlatformTransactionManager</span>를 직접 사용해서 트랜잭션을 관리할 수 있다. 트랜잭션이 필요한 빈에 `PlatformTransactionManager` 구현체를 빈 참조로 전달해라. 그러면 `TransactionDefinition`과 `TransactionStatus` 객체를 사용해서 트랜잭션을 시작하고, 롤백하고, 커밋할 수 있다. 사용법은 다음 예제를 참고해라:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
DefaultTransactionDefinition def = new DefaultTransactionDefinition();
// explicitly setting the transaction name is something that can be done only programmatically
def.setName("SomeTxName");
def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRED);

TransactionStatus status = txManager.getTransaction(def);
try {
    // put your business logic here
}
catch (MyException ex) {
    txManager.rollback(status);
    throw ex;
}
txManager.commit(status);
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
val def = DefaultTransactionDefinition()
// explicitly setting the transaction name is something that can be done only programmatically
def.setName("SomeTxName")
def.propagationBehavior = TransactionDefinition.PROPAGATION_REQUIRED

val status = txManager.getTransaction(def)
try {
    // put your business logic here
} catch (ex: MyException) {
    txManager.rollback(status)
    throw ex
}

txManager.commit(status)
```

#### Using the `ReactiveTransactionManager`

반응형 트랜잭션에선 <span class="custom-blockquote">org.springframework.transaction.ReactiveTransactionManager</span>를 직접 사용해서 트랜잭션을 관리할 수 있다. 트랜잭션이 필요한 빈에 `ReactiveTransactionManager` 구현체를 빈 참조로 전달해라. 그러면 `TransactionDefinition`과 `ReactiveTransaction` 객체를 사용해서 트랜잭션을 시작하고, 롤백하고, 커밋할 수 있다. 사용법은 다음 예제를 참고해라:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
DefaultTransactionDefinition def = new DefaultTransactionDefinition();
// explicitly setting the transaction name is something that can be done only programmatically
def.setName("SomeTxName");
def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRED);

Mono<ReactiveTransaction> reactiveTx = txManager.getReactiveTransaction(def);

reactiveTx.flatMap(status -> {

    Mono<Object> tx = ...; // put your business logic here

    return tx.then(txManager.commit(status))
            .onErrorResume(ex -> txManager.rollback(status).then(Mono.error(ex)));
});
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
val def = DefaultTransactionDefinition()
// explicitly setting the transaction name is something that can be done only programmatically
def.setName("SomeTxName")
def.propagationBehavior = TransactionDefinition.PROPAGATION_REQUIRED

val reactiveTx = txManager.getReactiveTransaction(def)
reactiveTx.flatMap { status ->

    val tx = ... // put your business logic here

    tx.then(txManager.commit(status))
            .onErrorResume { ex -> txManager.rollback(status).then(Mono.error(ex)) }
}
```

---

## 1.6. Choosing Between Programmatic and Declarative Transaction Management

프로그래밍 방식 트랜잭션 관리는 보통 트랜잭션 연산이 많이 없을 때만 사용하는 게 좋다. 예를 들어, 특정 업데이트 연산에서만 트랜잭션이 필요한 웹 어플리케이션이라면, 스프링이나 다른 기술로 트랜잭션 프록시를 설정하고 싶지 않을 수도 있다. 이럴 땐 `TransactionTemplate`을 사용하는 게 더 적합할 수 있다. 트랜잭션 이름을 명시적으로 설정하는 것도 프로그래밍 방식으로 트랜잭션을 관리해야만 가능한 일이다.

반면에 어플리케이션에 수 많은 트랜잭션 연산이 필요하다면, 보통은 선언적으로 트랜잭션 관리하는 게 낫다. 선언 방식은 트랜잭션 관리 로직을 비즈니스 로직과 분리해주며, 설정하기도 어렵지 않다. EJB CMT 대신 스프링 프레임워크를 사용하면, 선언적 트랜잭션 관리를 설정하는 데 들어가는 시간도 크게 줄어든다.

---

## 1.7. Transaction-bound Events

스프링 4.2부터 이벤트 리스너를 트랜잭션 단계에 바인딩할 수 있다. 대표적인 예시로, 트랜잭션을 성공적으로 완료했을 때의 이벤트를 처리할 수 있다. 덕분에 트랜잭션 결과가 실제로 리스너에서 처리해야 하는 결과였다면 이벤트를 더 유연하게 활용할 수 있다.

일반적인 이벤트 리스너는 `@EventListener` 어노테이션으로 등록할 수 있다. 리스너를 트랜잭션에 바인딩해야 한다면 `@TransactionalEventListener`를 사용해라. 이렇게 하면 리스너는 디폴트로 트랜잭션 커밋 단계에 바인딩된다.

이 개념은 다음 예제에서 확인할 수 있다. 컴포넌트는 주문 생성 이벤트를 발행한다고 가정하며, 여기서 정의하려는 리스너는 발행 시점의 트랜잭션이 성공적으로 커밋된 경우에만 이벤트를 처리해야 한다고 가정한다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
@Component
public class MyComponent {

    @TransactionalEventListener
    public void handleOrderCreatedEvent(CreationEvent<Order> creationEvent) {
        // ...
    }
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
@Component
class MyComponent {

    @TransactionalEventListener
    fun handleOrderCreatedEvent(creationEvent: CreationEvent<Order>) {
        // ...
    }
}
```

`@TransactionalEventListener` 어노테이션에는 리스너를 바인딩할 트랜잭션 단계를 커스텀할 수 있는 `phase` 속성이 있다. 지원하는 속성 값은 `BEFORE_COMMIT`, `AFTER_COMMIT`(디폴트), `AFTER_ROLLBACK`과, 커밋/롤백을 모두 합친 트랜잭션 완료를 의미하는 `AFTER_COMPLETION`이 있다.

실행 중인 트랜잭션이 없다면 필요한 시맨틱스를 확인할 수 없기 때문에 리스너를 아예 호출하지 않는다. 단, 어노테이션의 `fallbackExecution` 속성을 `true`로 설정하면 이 동작을 재정의할 수 있다.

> `@TransactionalEventListener`는 `PlatformTransactionManager`가 관리하는, 스레드에 바인딩된 트랜잭션에서만 동작한다. `ReactiveTransactionManager`가 관리하는 반응형 트랜잭션은 스레드 로컬 속성 대신 리액터 컨텍스트를 사용하기 때문에, 이벤트 리스너 관점에선 참여할 수 있는 활성 트랜잭션이 없다.

---

## 1.8. Application server-specific integration

스프링의 트랜잭션 추상화는 일반적으로 어플리케이션 서버 종류에 구애받지 않는다. 게다가 스프링의 `JtaTransactionManager` 클래스(원하면 JTA `UserTransaction`과 `TransactionManager` 객체를 JNDI로 조회할 수 있음)는 어플리케이션 서버에 따라 다른 `TransactionManager` 객체 위치를 자동으로 감지한다. JTA `TransactionManager`를 사용하면 향상된 트랜잭션 시맨틱스를 누릴 수 있으며, 특히 트랜잭션을 일시 중단할 수도 있다. 자세한 내용은 [`JtaTransactionManager`](https://docs.spring.io/spring-framework/docs/5.3.2/javadoc-api/org/springframework/transaction/jta/JtaTransactionManager.html) javadoc을 참고해라.

스프링의 `JtaTransactionManager`는 자바 EE 어플리케이션 서버 실행을 위한 표준이며, 자주 쓰는 서버에선 모두 동작하는 것으로 알려져 있다. 많은 서버(GlassFish, JBoss, Geronimo 등)에서 특별한 설정 없이도 트랜잭션 일시 중단같은 고급 기능을 사용할 수 있다. 물론, 트랜잭션 일시 중단과 다른 고급 기능을 완전히 통합 지원하기 위해 스프링에는 WebLogic Server와 WebSphere 전용 어댑터가 포함돼 있다. 이 어댑터는 다음 섹션에서 설명한다.

WebLogic Server와 WebSphere 등의 표준 시나리오에선 간편하게 `<tx:jta-transaction-manager/>` 설정 요소를 사용하는 게 좋다. 이 요소를 설정하고 나면 서버를 자동으로 감지하며, 플랫폼에 적합한 최상의 트랜잭션 매니저를 선택해준다. 즉, 서버 별 어댑터 클래스 설정을 명시할 필요가 없다 (다음 섹션에서 설명하듯). 그보단 자동으로 선택해주며, 표준 `JtaTransactionManager`를 기본 폴백으로 사용한다.

### 1.8.1. IBM WebSphere

WebSphere 6.1.0.9 이상에서 권장하는 스프링 JTA 트랜잭션 매니저는 `WebSphereUowTransactionManager`다. 이 전용 어댑터는 WebSphere 어플리케이션 서버 6.1.0.9 이상에서 지원하는 IBM의 `UOWManager` API를 사용한다. IBM은 공식적으로 이 어댑터를 활용한 스프링 기반 트랜잭션 일시 중지(`PROPAGATION_REQUIRES_NEW`처럼 중지했다가 다시 시작함)를 지원한다.

### 1.8.2. Oracle WebLogic Server

WebLogic Server 9.0 이상에선 보통 표준 `JtaTransactionManager` 클래스 대신 `WebLogicJtaTransactionManager`를 사용한다. 이 클래스는 일반 `JtaTransactionManager`의 WebLogic 전용 하위 클래스로, WebLogic이 관리하는 트랜잭션 환경에서 표준 JTA 시맨틱스 뿐 아니라 스프링의 트랜잭션 정의도 모두 지원한다. 트랜잭션 이름과 트랜잭션 별 격리 수준을 지원하며, 모든 상황에서 적절하게 트랜잭션을 재개할 수 있는 기능도 지원한다.

---

## 1.9. Solutions to Common Problems

이번 섹션에선 흔히 겪는 몇 가지 이슈에 대한 솔루션을 제시한다.

### 1.9.1. Using the Wrong Transaction Manager for a Specific `DataSource`

선택한 트랜잭션 기술과 요구 사항에 맞는 `PlatformTransactionManager` 구현체를 사용해라. 스프링 프레임워크는 간단하고 이식 가능한 추상화를 제공할 뿐이며, 제대로 활용하는 것은 개발자 몫이다. 글로벌 트랜잭션을 사용한다면 모든 트랜잭션 연산에 <span class="custom-blockquote">org.springframework.transaction.jta.JtaTransactionManager</span> 클래스(또는 [어플리케이션 서버 전용 하위 클래스](#18-application-server-specific-integration))를 사용해야 한다. 그렇지 않으면 트랜잭션 인프라는 컨테이너 `DataSource` 인스턴스같은 리소스로 로컬 트랜잭션을 시도한다. 이런 상황에서 로컬 트랜잭션은 앞뒤가 맞지 않으며, 정상적인 어플리케이션 서버라면 이를 오류로 처리할 거다.

---

## 1.10. Further Resources

스프링 프레임워크가 지원하는 트랜잭션 기능을 더 알아보고 싶다면 아래 자료를 참고해라:

- [Distributed transactions in Spring, with and without XA](https://www.javaworld.com/javaworld/jw-01-2009/jw-01-spring-transactions.html)는 스프링의 David Syer의 JavaWorld 프레젠테이션으로, 스프링 어플리케이션에서 분산 트랜잭션에 사용할 수 있는 일곱 가지 패턴을 안내한다. XA를 사용한 세 가지 패턴과, XA를 사용하지 않는 네 가지 패턴을 다룬다.
- [*Java Transaction Design Strategies*](https://www.infoq.com/minibooks/JTDS)는 InfoQ에서 발간한 책으로, 자바의 트랜잭션을 균형있게 소개한다. 트랜잭션 설정과 사용법을 익힐 수 있는 스프링 프레임워크와 EJB3 예제도 나란히 제공한다.