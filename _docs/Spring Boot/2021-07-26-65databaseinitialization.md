---
title: Database Initialization
category: Spring Boot
order: 65
permalink: /Spring%20Boot/howto.data-initialization/
description: 데이터베이스 초기화와 관련된 how to 가이드 (스크립트나 설정으로 스키마, 데이터 초기화하기 등)
image: ./../../images/springboot/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 부트
originalRefLink: https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#howto.data-initialization
parent: “How-to” Guides
parentUrl: /Spring%20Boot/how-to-guides/
---
<script>defaultLanguages = ['properties']</script>

### 목차

- [12.9.1. Initialize a Database Using JPA](#1291-initialize-a-database-using-jpa)
- [12.9.2. Initialize a Database Using Hibernate](#1292-initialize-a-database-using-hibernate)
- [12.9.3. Initialize a Database Using Basic SQL Scripts](#1293-initialize-a-database-using-basic-sql-scripts)
- [12.9.4. Initialize a Spring Batch Database](#1294-initialize-a-spring-batch-database)
- [12.9.5. Use a Higher-level Database Migration Tool](#1295-use-a-higher-level-database-migration-tool)
  + [Execute Flyway Database Migrations on Startup](#execute-flyway-database-migrations-on-startup)
  + [Execute Liquibase Database Migrations on Startup](#execute-liquibase-database-migrations-on-startup)
- [12.9.6. Depend Upon an Initialized Database](#1296-depend-upon-an-initialized-database)
  + [Detect a Database Initializer](#detect-a-database-initializer)
  + [Detect a Bean That Depends On Database Initialization](#detect-a-bean-that-depends-on-database-initialization)

---

## 12.9. Database Initialization

SQL 데이터베이스는 스택에 따라 다양한 방식으로 초기화할 수 있다. 물론 데이터베이스를 별도 프로세스로 띄웠다면 수동으로 초기화해도 된다. 단, 스키마를 생성할 때는 단일 메커니즘을 이용하는 걸 권장한다.

### 12.9.1. Initialize a Database Using JPA

JPA에는 DDL 생성 기능이 있어서, 기동 시 데이터베이스에서 DDL을 실행하도록 설정할 수 있다. 이 설정은 두 가지 외부 프로퍼티로 제어한다.

- `spring.jpa.generate-ddl` (boolean): 이 기능을 켜고 끈다. 벤더와 상관 없이 사용할 수 있다.
- `spring.jpa.hibernate.ddl-auto` (enum): 좀 더 세세하게 동작을 제어할 수 있는 Hibernate 기능. 이 기능은 뒤에서 자세히 설명한다.

### 12.9.2. Initialize a Database Using Hibernate

DDL을 자동으로 실행할 때는 `spring.jpa.hibernate.ddl-auto`를 명시해도 된다. 표준 Hibernate 프로퍼티는 `none`, `validate`, `update`, `create`, `create-drop`이다. 데이터베이스가 임베디드 데이터베이스인지에 따라 스프링 부트가 기본값을 선택해줄 거다. 스키마 매니저가 감지되지 않으면 `create-drop`이 기본값이고, 그 외는 모두 `none`이다. 임베디드 데이터베이스는 `Connection` 타입과 JDBC url을 보고 감지한다. 감지할 수 있는 임베디드 데이터베이스 후보는 `hsqldb`, `h2`, `derby`다. 인메모리에서 '실제' 데이터베이스로 전환할 때는, 새 플랫폼에서도 그대로 테이블과 데이터가 존재할 거라고 가정해선 안 된다. `ddl-auto`를 명시하거나, 아니면 다른 메커니즘 중 하나로 데이터베이스를 초기화해야 한다.

> `org.hibernate.SQL` 로거를 활성화하면 스키마 생성 로그를 확인할 수 있다. [디버그 모드](../logging#742-console-output)로 실행하면 자동으로 활성화된다.

추가로, Hibernate로 스키마를 처음부터 생성한다면 (즉, `ddl-auto` 프로퍼티를 `create`나 `create-drop`으로 설정한 경우) 기동 시에 클래스패스 루트에 있는 `import.sql`이란 파일을 실행한다. 주의해서 사용하면 데모나 테스트엔 유용할 수 있지만, 프로덕션 환경에선 클래스패스에 포함시키고 싶지 않은 파일일 거다. 하지만 이 기능은 Hibernate의 기능이다 (스프링과는 아무 상관 없다).

### 12.9.3. Initialize a Database Using Basic SQL Scripts

스프링 부트는 JDBC `DataSource`나 R2DBC `ConnectionFactory`의 스키마(DDL 스크립트)를 자동으로 생성하고 초기화(DML 스크립트)할 수 있다. 클래스패스 루트에 있는 표준 `schema.sql`과 `data.sql`에서 SQL을 로드한다. 스프링 부트에선 `schema-${platform}.sql`, `data-${platform}.sql` 파일도 있으면 처리한다. 여기서 `platform`은 `spring.sql.init.platform` 값이다. 이 프로퍼티를 활용하면 필요 시 데이터베이스 전용 스크립트로 전환할 수 있다. 예를 들어 데이터베이스 벤더 이름을 선택해서 (`hsqldb`, `h2`, `oracle`, `mysql`, `postgresql` 등) 설정할 수 있다. 기본적으로 SQL 데이터베이스 초기화는 임베디드 인메모리 데이터베이스를 사용할 때만 수행한다. 항상 SQL 데이터베이스를 초기화하려면 타입에 관계없이 `spring.sql.init.mode`를 `always`로 설정해라. 마찬가지로 초기화를 비활성화할 때도 `spring.sql.init.mode`를 `never`로 설정해라. 스프링 부트는 스크립트 기반 데이터베이스 이니셜라이저의 fail-fast 기능을 기본으로 활성화한다. 이게 무슨 말이냐 하면, 스크립트에서 예외가 발생하면 애플리케이션 기동에 실패한다는 뜻이다. 이 동작은 `spring.sql.init.continue-on-error`를 설정하면 변경할 수 있다.

스크립트 기반 `DataSource` 초기화는 기본적으로 JPA `EntityManagerFactory` 빈을 생성하기 전에 수행된다. `schema.sql`은 JPA가 관리하는 엔티티를 위한 스키마를 만들 때 사용하고, `data.sql`은 거기에 데이터를 채울 때 사용한다. 데이터소스 초기화 기술을 여러 개 혼합하는 건 권장하지 않긴 하지만, Hibernate가 생성하는 스키마에 이어서 스크립트 기반으로 `DataSource`를 초기화하고 싶다면 `spring.jpa.defer-datasource-initialization`을 `true`로 설정해라. 이렇게 하면 모든 `EntityManagerFactory` 빈을 생성하고 초기화를 마칠 때까지 데이터소스 초기화를 미룬다. 이렇게 설정해줬다면 `schema.sql`을 사용해서 Hibernate가 생성할 스키마를 더 추가할 수 있고, `data.sql`을 사용해 거기다 데이터를 채울 수 있다.

Flyway나 Liquibase같은 [고수준 데이터베이스 마이그레이션 툴](#1295-use-a-higher-level-database-migration-tool)를 사용하고 있다면, 스키마를 생성하고 초기화할 땐 이 마이그레이션 툴만 단독으로 사용해야 한다. 기본적인 `schema.sql`, `data.sql` 스크립트를 Flyway나 Liquibase와 함께 사용하는 건 권장하지 않고 있으며, 향후 릴리즈에서 지원을 중단할 예정이다.

### 12.9.4. Initialize a Spring Batch Database

스프링 배치는 가장 많이 사용하는 데이터베이스 플랫폼용 SQL 초기화 스크립트들과 함께 패키징되어 있다. 스프링 부트는 데이터베이스 타입을 감지해서 기동 시에 해당 플랫폼의 스크립트를 실행할 수 있다. 임베디드 데이터베이스를 사용한다면 스크립트를 기본적으로 실행한다. 다음 예제에서 처럼 임베디드 타입이 아닐 때에도 항상 활성화시킬 수 있다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.batch.jdbc.initialize-schema=always
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  batch:
    jdbc:
      initialize-schema: "always"
```

`spring.batch.jdbc.initialize-schema`를 `never`로 설정하면 명시적으로 초기화를 끌 수도 있다.

### 12.9.5. Use a Higher-level Database Migration Tool

스프링 부트는 두 가지 고수준 마이그레이션 툴, [Flyway](https://flywaydb.org/)와 [Liquibase](https://www.liquibase.org/)를 지원한다.

#### Execute Flyway Database Migrations on Startup

기동 시에 Flyway 데이터베이스 마이그레이션을 자동으로 실행하려면 클래스패스에 `org.flywaydb:flyway-core`를 추가해라.

전형적인 마이그레이션은 `V<VERSION>__<NAME>.sql` 형식의 스크립트로 실행한다 (`<VERSION>`에선 버전을 '1', '2_1'같이 밑줄로 구분한다). 이 스크립트는 기본적으로 `classpath:db/migration`이라는 디렉토리에 두지만, `spring.flyway.locations`를 설정하면 위치를 변경할 수 있다. 여기에는 `classpath:`나 `filesystem:` 위치를 하나 이상 쉼표로 구분해주면 된다. 예를 들어 아래 설정은 기본 클래스패스 상의 디렉토리와 파일시스템의 `/opt/migration` 디렉토리 두 곳에서 스크립트를 검색한다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.flyway.locations=classpath:db/migration,filesystem:/opt/migration
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  flyway:
    locations: "classpath:db/migration,filesystem:/opt/migration"
```

특별한 `{vendor}` 플레이스홀더를 추가해주면 벤더 전용 스크립트도 사용할 수 있다. 아래와 같이 설정했다고 해보자:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.flyway.locations=classpath:db/migration/{vendor}
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  flyway:
    locations: "classpath:db/migration/{vendor}"
```

위 설정에선 `db/migration`을 사용하는 대신 데이터베이스 타입에 따라 사용할 디렉토리를 설정한다 (ex. MySQL에선 `db/migration/mysql`). 지원하는 데이터베이스는 [`DatabaseDriver`](https://github.com/spring-projects/spring-boot/tree/v2.5.2/spring-boot-project/spring-boot/src/main/java/org/springframework/boot/jdbc/DatabaseDriver.java)에서 확인할 수 있다.

마이그레이션은 자바로도 작성할 수 있다. `JavaMigration`을 구현한 빈이 있으면 전부 Flyway에 자동 설정된다.

[`FlywayProperties`](https://github.com/spring-projects/spring-boot/tree/v2.5.2/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/flyway/FlywayProperties.java)는 Flyway 설정을 대부분 지원하며, 얼마 안 되지만 마이그레이션을 비활성화하거나 지정한 위치에 리소스가 있는지 확인하는 동작을 꺼버릴 수 있는 별도 프로퍼티도 함께 제공한다. 다른 것들을 더 커스텀해야 한다면 `FlywayConfigurationCustomizer` 빈을 등록하는 걸 고려해봐라.

스프링 부트는 `Flyway.migrate()`를 호출해서 데이터베이스 마이그레이션을 수행한다. 마이그레이션 동작을 더 제어하고 싶으면 [`FlywayMigrationStrategy`](https://github.com/spring-projects/spring-boot/tree/v2.5.2/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/flyway/FlywayMigrationStrategy.java)를 구현한 `@Bean`을 제공해라.

Flyway는 SQL 콜백과 자바 [콜백](https://flywaydb.org/documentation/concepts/callbacks)을 지원한다. SQL 기반 콜백을 사용하려면 콜백 스크립트를 `classpath:db/migration`에 두면 된다. 자바 기반 콜백을 사용하려면 `Callback`을 구현한 빈을 하나 이상 만들어라. 이런 빈들은 모두 `Flyway`에 자동으로 등록된다. `@Order`를 사용하거나 `Ordered`를 구현하면 순서도 지정할 수 있다. 현재는 deprecated된 `FlywayCallback` 인터페이스를 구현한 빈도 감지할 순 있지만, `Callback` 빈과는 함께 사용할 수 없다.

기본적으로 Flyway는 컨텍스트에 있는 (`@Primary`) `DataSource`를 주입받아 마이그레이션에 사용한다. 다른 `DataSource`를 사용하고 싶다면, `@Bean`을 하나를 만들어 `@FlywayDataSource`로 마킹하면 된다. 이때 데이터소스를 두 개 사용한다면, 빈을 하나 더 만들고 `@Primary`로 마킹하는 걸 잊지마라. 아니면 외부 프로퍼티에 `spring.flyway.[url,user,password]`를 설정해서 Flyway의 네이티브 `DataSource`를 사용해도 된다. `spring.flyway.url`이나 `spring.flyway.user`를 설정하면 Flyway에서 자체 `DataSource`를 사용하게 만들 수 있다. 세 가지 프로퍼티 중 설정하지 않은 값이 있다면 `spring.datasource` 프로퍼티에 있는 값을 사용하게 된다.

Flyway로 특정 시나리오에만 필요한 데이터를 제공할 수도 있다. 예를 들어 테스트 전용 마이그레이션을 `src/test/resources`에 배치할 수 있으며, 여기 있는 스크립트는 테스트로 애플리케이션을 시작할 때만 실행된다. 게다가 프로파일 전용 설정으로 `spring.flyway.locations`를 커스텀해주면, 활성화된 프로파일에 따라 마이그레이션을 실행할 수 있다. 예를 들면 `application-dev.properties`에 다음과 같은 설정을 넣을 수 있다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.flyway.locations=classpath:/db/migration,classpath:/dev/db/migration
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  flyway:
    locations: "classpath:/db/migration,classpath:/dev/db/migration"
```

이렇게 설정하면 `dev/db/migration`에 있는 마이그레이션은 `dev` 프로파일을 활성화했을 때만 실행된다.

#### Execute Liquibase Database Migrations on Startup

기동 시에 Liquibase 데이터베이스 마이그레이션을 자동으로 실행하려면 클래스패스에 `org.liquibase:liquibase-core`를 추가해라.

> 클래스패스에 `org.liquibase:liquibase-core`를 추가하면 기본적으로 애플리케이션을 기동할 때와 테스트를 실행하기 전 모두 데이터베이스 마이그레이션을 실행한다. 이 동작은 `main`과 `test` 설정에서 `spring.liquibase.enabled` 프로퍼티를 다르게 설정해주면 커스텀할 수 있다. 각각을 다른 방법으로 데이터베이스 초기화를 진행하는 건 불가능하다 (e.x. 애플리케이션을 기동할 땐 Liquibase, 테스트 실행에는 JPA).

기본적으로 마스터 change 로그는 `db/changelog/db.changelog-master.yaml`에서 읽어오지만, `spring.liquibase.change-log`를 설정하면 위치를 변경할 수 있다. Liquibase는 YAML 외에도 JSON, XML, SQL 형식의 change 로그도 지원한다.

기본적으로 Liquibase는 컨텍스트에 있는 (`@Primary`) `DataSource`를 주입받아 마이그레이션에 사용한다. 다른 `DataSource`를 사용하고 싶다면, `@Bean`을 하나를 만들어 `@LiquibaseDataSource`로 마킹하면 된다. 이때 데이터소스를 두 개 사용한다면, 빈을 하나 더 만들고 `@Primary`로 마킹하는 걸 잊지마라. 아니면 외부 프로퍼티에 `spring.liquibase.[driver-class-name,url,user,password]`를 설정해서 Liquibase의 네이티브 `DataSource`를 사용해도 된다. `spring.liquibase.url`이나 `spring.liquibase.user`를 설정하면 Liquibase에서 자체 `DataSource`를 사용하게 만들 수 있다. 세 가지 프로퍼티 중 설정하지 않은 값이 있다면 `spring.datasource` 프로퍼티에 있는 값을 사용하게 된다.

컨텍스트, 디폴트 스키마 등과 같은 다른 설정들을 자세히 알고 싶다면 [`LiquibaseProperties`](https://github.com/spring-projects/spring-boot/tree/v2.5.2/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/liquibase/LiquibaseProperties.java)를 확인해봐라.

### 12.9.6. Depend Upon an Initialized Database

데이터베이스 초기화는 애플리케이션이 시작되는 동안 애플리케이션 컨텍스트를 리프레시하면서 진행된다. 기동 중에는 초기화를 마친 데이터베이스에 접근할 수 있도록, 데이터베이스 이니셜라이저 역할을 담당하는 빈과, 해당 데이터베이스 초기화가 완료되길 기다려야 하는 빈들이 자동으로 감지된다. 데이터베이스가 초기화를 마치고 나서야 초기화가 가능한 빈들은, 데이터베이스를 초기화하는 빈들을 의존하도록 설정된다. 기동 중에 애플리케이션이 데이터베이스에 접근하려고 시도했는데 아직 초기화가 완료되지 않았다면, 데이터베이스를 초기화하는 빈과 데이터베이스 초기화가 완료되길 기다려야 하는 빈들을 감지할 수 있는 설정을 추가로 더 넣어주면 된다.

#### Detect a Database Initializer

스프링 부트가 자동으로 감지하는 SQL 데이터베이스를 초기화하는 빈 타입은 다음과 같다:

- `DataSourceScriptDatabaseInitializer`
- `EntityManagerFactory`
- `Flyway`
- `FlywayMigrationInitializer`
- `R2dbcScriptDatabaseInitializer`
- `SpringLiquibase`

데이터베이스 초기화 라이브러리로 써드 파티 스타터를 사용하고 있다면, 다른 타입의 빈들도 자동으로 감지할 수 있게 detector를 제공하고 있을 수도 있다. 다른 빈을 감지하게 만들려면 `META-INF/spring-factories`에 `DatabaseInitializerDetector` 구현체를 등록해라.

#### Detect a Bean That Depends On Database Initialization

스프링 부트가 자동으로 감지하는 데이터베이스 초기화에 의존하는 빈 타입은 다음과 같다:

- `AbstractEntityManagerFactoryBean` (`spring.jpa.defer-datasource-initialization`을 `true`로 설정하지 않았다면)
- `DSLContext` (jOOQ)
- `EntityManagerFactory` (`spring.jpa.defer-datasource-initialization`을 `true`로 설정하지 않았다면)
- `JdbcOperations`
- `NamedParameterJdbcOperations`

써드 파티 스타터 데이터 액세스 라이브러리를 사용하고 있다면, 다른 타입의 빈들도 자동으로 감지할 수 있게 detector를 제공하고 있을 수도 있다. 다른 빈을 감지하게 만들려면 `META-INF/spring-factories`에 `DependsOnDatabaseInitializationDetector` 구현체를 등록해라. 아니면 빈의 클래스나 `@Bean` 메소드에 `@DependsOnDatabaseInitialization` 어노테이션을 추가해라.