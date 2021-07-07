---
title: Distributed Transactions with JTA
category: Spring Boot
order: 27
permalink: /Spring%20Boot/distributed-transactions-with-jta/
description: 스프링 부트에서 분산 트랜잭션 사용하기
image: ./../../images/springboot/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 부트
originalRefLink: https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#features.jta
parent: Spring Boot Features
parentUrl: /Spring%20Boot/spring-boot-features/
---

### 목차

- [7.19.1. Using an Atomikos Transaction Manager](#7191-using-an-atomikos-transaction-manager)
- [7.19.2. Using a Java EE Managed Transaction Manager](#7192-using-a-java-ee-managed-transaction-manager)
- [7.19.3. Mixing XA and Non-XA JMS Connections](#7193-mixing-xa-and-non-xa-jms-connections)
- [7.19.4. Supporting an Alternative Embedded Transaction Manager](#7194-supporting-an-alternative-embedded-transaction-manager)

---

## 7.19. Distributed Transactions with JTA

스프링 부트는 [Atomikos](https://www.atomikos.com/) 임베디드 트랜잭션 매니저를 통해 여러 XA 리소스에 걸친 분산 JTA 트랜잭션을 지원한다. 적절한 Java EE 애플리케이션 서버에 배포할 때도 JTA 트랜잭션을 사용할 수 있다.

JTA 환경을 감지하면 스프링의 `JtaTransactionManager`를 사용해서 트랜잭션을 관리한다. 자동 설정된 JMS, DataSource, JPA 빈은 XA 트랜잭션을 지원하도록 업그레이드된다. `@Transactional`같은 표준 스프링 관용구를 사용해서 분산 트랜잭션에 관여할 수도 있다. JTA 환경에 있지만 로컬 트랜잭션을 사용하고 싶을 땐 `spring.jta.enabled` 프로퍼티를 `false`로 설정하면 JTA 자동 설정을 비활성화할 수 있다.

### 7.19.1. Using an Atomikos Transaction Manager

[Atomikos](https://www.atomikos.com/)는 인기 있는 오픈 소스 트랜잭션 매니저중 하나로, 스프링 부트 애플리케이션에 임베딩시킬 수 있다. `spring-boot-starter-jta-atomikos` 스타터를 사용하면 적절한 Atomikos 라이브러리들을 가져온다. 스프링 부트는 Atomikos를 자동으로 설정해주며, 올바른 순서대로 기동하고 종료시킬 수 있도록 스프링 빈에 적절한 `depends-on` 설정을 적용해준다.

기본적으로 Atomikos 트랜잭션 로그는 애플리케이션의 홈 디렉토리(애플리케이션 jar 파일이 들어있는 디렉토리) 안에 있는 `transaction-logs` 디렉토리에 기록한다. `application.properties` 파일에 `spring.jta.log-dir` 프로퍼티를 설정하면 사용할 디렉토리를 커스텀할 수 있다. `spring.jta.atomikos.properties`로 시작하는 프로퍼티를 사용하면 Atomikos의 `UserTransactionServiceImp`를 커스텀할 수도 있다. 자세한 내용은 [`AtomikosProperties` Javadoc](https://docs.spring.io/spring-boot/docs/2.5.2/api/org/springframework/boot/jta/atomikos/AtomikosProperties.html)을 참고해라.

> 여러 트랜잭션 매니저로 같은 리소스 매니저들을 안전하게 조율할 수 있으려면, 반드시 각 Atomikos 인스턴스에 유니크한 ID를 설정해야 한다. ID는 기본적으론 Atomikos를 실행 중인 장비의 IP 주소를 사용한다. 프로덕션에서 중복되지 않도록 보장하려면, 각 애플리케이션 인스턴스마다 `spring.jta.transaction-manager-id` 프로퍼티를 다른 값으로 설정해야 한다.

### 7.19.2. Using a Java EE Managed Transaction Manager

스프링 부트 애플리케이션을 `war`나 `ear` 파일로 패키징해서 Java EE 애플리케이션 서버에 배포할 때는, 애플리케이션 서버에 내장된 트랜잭션 매니저를 사용할 수 있다. 스프링 부트에선 공통 JNDI 위치를 확인해서 (`java:comp/UserTransaction`, `java:comp/TransactionManager` 등) 트랜잭션 매니저를 자동 설정해본다. 애플리케이션 서버에서 제공하는 트랜잭션 서비스를 사용한다면, 보통은 리소스도 전부 이 서버에서 관리하고 JNDI를 통해 노출하고 싶을 거다. 스프링 부트는 JNDI 경로에서  `ConnectionFactory`를 찾아 (`java:/JmsXA` 또는 `java:/XAConnectionFactory`) JMS를 자동 설정해보며, `DataSource`는 [`spring.datasource.jndi-name` 프로퍼티](../working-with-sql-databases#connection-to-a-jndi-datasource)로 설정할 수 있다.

### 7.19.3. Mixing XA and Non-XA JMS Connections

JTA를 사용할 땐, XA를 인식할 수 있고 분산 트랜잭션에 참여하는 JMS `ConnectionFactory` 빈이 primary로 등록된다. 원하는 빈에 주입할 땐 `@Qualifier`를 사용할 필요 없이 바로 주입하면 된다:

```java
public MyBean(ConnectionFactory connectionFactory) {
    // ...
}
```

상황에 따라서는 특정 JMS 메세지를 처리할 땐 XA를 사용하지 않는 `ConnectionFactory`를 이용하고 싶을 수도 있다. 예를 들어 JMS 처리 로직의 실행 시간이 XA 타임아웃을 넘어갈 수도 있다.

XA를 사용하지 않는 `ConnectionFactory`를 원한다면 `nonXaJmsConnectionFactory` 빈을 주입하면 된다:

```java
public MyBean(@Qualifier("nonXaJmsConnectionFactory") ConnectionFactory connectionFactory) {
    // ...
}
```

`jmsConnectionFactory` 빈은 일관성을 위해 빈 alias `xaJmsConnectionFactory`로도 제공한다:

```java
public MyBean(@Qualifier("xaJmsConnectionFactory") ConnectionFactory connectionFactory) {
    // ...
}
```

### 7.19.4. Supporting an Alternative Embedded Transaction Manager

다른 임베디드 트랜잭션 매니저를 지원하고 싶을 땐 [`XAConnectionFactoryWrapper`](https://github.com/spring-projects/spring-boot/tree/v2.5.2/spring-boot-project/spring-boot/src/main/java/org/springframework/boot/jms/XAConnectionFactoryWrapper.java)와 [`XADataSourceWrapper`](https://github.com/spring-projects/spring-boot/tree/v2.5.2/spring-boot-project/spring-boot/src/main/java/org/springframework/boot/jdbc/XADataSourceWrapper.java) 인터페이스를 사용하면 된다. 이 인터페이스들은 `XAConnectionFactory`와 `XADataSource` 빈을 래핑해서, 분산 트랜잭션에 투명하게 등록되는 전형적인 `ConnectionFactory`, `DataSource` 빈으로 노출해주는 역할을 담당한다. `ApplicationContext`에 `JtaTransactionManager` 빈과 적절한 XA 래퍼 빈이 등록돼 있으면, DataSource와 JMS는 JTA 버전으로 자동 설정된다.

[AtomikosXAConnectionFactoryWrapper](https://github.com/spring-projects/spring-boot/tree/v2.5.2/spring-boot-project/spring-boot/src/main/java/org/springframework/boot/jta/atomikos/AtomikosXAConnectionFactoryWrapper.java)와 [AtomikosXADataSourceWrapper](https://github.com/spring-projects/spring-boot/tree/v2.5.2/spring-boot-project/spring-boot/src/main/java/org/springframework/boot/jta/atomikos/AtomikosXADataSourceWrapper.java)에선 XA 래퍼를 작성할 때 참고하기 좋은 예제를 제공하고 있다.