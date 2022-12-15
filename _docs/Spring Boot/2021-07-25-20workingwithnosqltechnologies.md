---
title: Working with NoSQL Technologies
category: Spring Boot 2.X
order: 20
permalink: /Spring%20Boot/working-with-nosql-technologies/
description: 스프링 부트로 Redis, MongoDB, Elasticsearch, Cassandra, influxDB 등의 NOSQL 데이터베이스 접근하기
image: ./../../images/springboot/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 부트
originalRefLink: https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#features.nosql
parent: Spring Boot Features
parentUrl: /Spring%20Boot/spring-boot-features/
priority: 0.4
---
<script>defaultLanguages = ['properties']</script>

### 목차

- [7.12.1. Redis](#7121-redis)
  + [Connecting to Redis](#connecting-to-redis)
- [7.12.2. MongoDB](#7122-mongodb)
  + [Connecting to a MongoDB Database](#connecting-to-a-mongodb-database)
  + [MongoTemplate](#mongotemplate)
  + [Spring Data MongoDB Repositories](#spring-data-mongodb-repositories)
  + [Embedded Mongo](#embedded-mongo)
- [7.12.3. Neo4j](#7123-neo4j)
  + [Connecting to a Neo4j Database](#connecting-to-a-neo4j-database)
  + [Spring Data Neo4j Repositories](#spring-data-neo4j-repositories)
- [7.12.4. Solr](#7124-solr)
  + [Connecting to Solr](#connecting-to-solr)
- [7.12.5. Elasticsearch](#7125-elasticsearch)
  + [Connecting to Elasticsearch using REST clients](#connecting-to-elasticsearch-using-rest-clients)
  + [Connecting to Elasticsearch using Reactive REST clients](#connecting-to-elasticsearch-using-reactive-rest-clients)
  + [Connecting to Elasticsearch by Using Spring Data](#connecting-to-elasticsearch-by-using-spring-data)
  + [Spring Data Elasticsearch Repositories](#spring-data-elasticsearch-repositories)
- [7.12.6. Cassandra](#7126-cassandra)
  + [Connecting to Cassandra](#connecting-to-cassandra)
  + [Spring Data Cassandra Repositories](#spring-data-cassandra-repositories)
- [7.12.7. Couchbase](#7127-couchbase)
  + [Connecting to Couchbase](#connecting-to-couchbase)
  + [Spring Data Couchbase Repositories](#spring-data-couchbase-repositories)
- [7.12.8. LDAP](#7128-ldap)
  + [Connecting to an LDAP Server](#connecting-to-an-ldap-server)
  + [Spring Data LDAP Repositories](#spring-data-ldap-repositories)
  + [Embedded In-memory LDAP Server](#embedded-in-memory-ldap-server)
- [7.12.9. InfluxDB](#7129-influxdb)
  + [Connecting to InfluxDB](#connecting-to-influxdb)

---

## 7.12. Working with NoSQL Technologies

Spring Data는 아래와 같이 다양한 NoSQL 기술에 액세스할 때 활용할 수 있는 별도 프로젝트를 제공한다:

- [MongoDB](https://spring.io/projects/spring-data-mongodb)
- [Neo4J](https://spring.io/projects/spring-data-neo4j)
- [Elasticsearch](https://spring.io/projects/spring-data-elasticsearch)
- [Redis](https://spring.io/projects/spring-data-redis)
- [GemFire](https://spring.io/projects/spring-data-gemfire) 또는 [Geode](https://spring.io/projects/spring-data-geode)
- [Cassandra](https://spring.io/projects/spring-data-cassandra)
- [Couchbase](https://spring.io/projects/spring-data-couchbase)
- [LDAP](https://spring.io/projects/spring-data-ldap)

스프링 부트는 Redis, MongoDB, Neo4j, Solr, Elasticsearch, Cassandra, Couchbase, LDAP, InfluxDB를 위한 자동 설정을 제공한다. 다른 프로젝트를 활용해도 되지만, 그러려면 설정을 직접 세팅해야 한다. [spring.io/projects/spring-data](https://spring.io/projects/spring-data)에서 적당한 레퍼런스를 참고해라.

### 7.12.1. Redis

[Redis](https://redis.io/)는 캐시이자, 메세지 브로커이며, 풍부한 기능을 갖추고 있는 key-value 저장소다. 스프링 부트는 [Lettuce](https://github.com/lettuce-io/lettuce-core/)와 [Jedis](https://github.com/xetorthio/jedis/) 클라이언트 라이브러리와, [Spring Data Redis](https://github.com/spring-projects/spring-data-redis)가 이 라이브러리 위에 구축해 놓은 추상화를 위한 기본적인 자동 설정을 제공한다.

`spring-boot-starter-data-redis` "스타터"는 의존성을 간편하게 수집해준다. 이 스타터는 기본적으론 [Lettuce](https://github.com/lettuce-io/lettuce-core/)를 사용하며, 전통적인 애플리케이션과 리액티브 애플리케이션을 모두 처리해준다.

> 다른 저장소에서 지원하는 리액티브 스타터와의 일관성을 위해 `spring-boot-starter-data-redis-reactive` "스타터"도 제공하고 있다.

#### Connecting to Redis

자동 설정된 `RedisConnectionFactory`나, `StringRedisTemplate`, 순수<sup>vanilla</sup> `RedisTemplate` 인스턴스는 다른 스프링 빈과 똑같이 주입해서 사용할 수 있다. 이 인스턴스는 기본적으로 `localhost:6379`에서 Redis 서버 연결을 시도한다. 다음은 이 인스턴스를 사용하는 빈 예시다:

```java
@Component
public class MyBean {

    private final StringRedisTemplate template;

    public MyBean(StringRedisTemplate template) {
        this.template = template;
    }

    // ...

}
```

> 다른 것들을 좀 더 커스텀하고 싶으면, `LettuceClientConfigurationBuilderCustomizer`를 구현하는 빈을 원하는 만큼 추가해도 된다. Jedis를 위한 `JedisClientConfigurationBuilderCustomizer`도 준비돼 있다.

자동 설정 타입 중 하나를 자체 `@Bean`으로 추가하면 기본값을 대체한다 (`RedisTemplate`은 예외인데, `RedisTemplate`은 빈 타입이 아닌 빈 이름 `redisTemplate` 기반이다).

클래스패스에 `commons-pool2`가 있으면서 [`RedisProperties`](https://github.com/spring-projects/spring-boot/tree/v2.5.2/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/data/redis/RedisProperties.java)의 `Pool` 옵션이 하나라도 설정돼 있으면 커넥션 풀을 지원하는<sup>pooled</sup> 커넥션 팩토리를 자동 설정한다.

### 7.12.2. MongoDB

[MongoDB](https://www.mongodb.com/)는 전통적인 테이블 기반 관계형 데이터 대신 JSON과 유사한 스키마를 사용하는 오픈 소스 NoSQL document 데이터베이스다. 스프링 부트를 사용하면 `spring-boot-starter-data-mongodb`와 `spring-boot-starter-data-mongodb-reactive` "스타터"를 활용하는 등, MongoDB 데이터 작업을 좀 더 수월하게 진행할 수 있다.

#### Connecting to a MongoDB Database

MongoDB 데이터베이스에 접근하려면 자동 설정된 `org.springframework.data.mongodb.MongoDatabaseFactory`를 주입하면 된다. 이 인스턴스는 기본적으로 `mongodb://localhost/test`에서 MongoDB 서버 연결을 시도한다. 다음은 MongoDB 데이터베이스에 연결하는 예시다:

```java
@Component
public class MyBean {

    private final MongoDatabaseFactory mongo;

    public MyBean(MongoDatabaseFactory mongo) {
        this.mongo = mongo;
    }

    // ...

}
```

자체 `MongoClient`를 정의했다면, 자체 정의한 `MongoClient`를 사용해 적합한 `MongoDatabaseFactory`를 자동 설정한다.

자동 설정된 `MongoClient`는 `MongoClientSettings` 빈을 사용해서 만들어진다. 자체 `MongoClientSettings`를 정의했다면 자체 세팅을 수정 없이 그대로 사용하며, `spring.data.mongodb` 프로퍼티는 무시된다. 그 외엔 `spring.data.mongodb` 프로퍼티를 적용해서 `MongoClientSettings`를 자동 설정한다. 두 케이스 모두 `MongoClientSettingsBuilderCustomizer` 빈을 하나 이상 선언해서 `MongoClientSettings` 설정을 세세히 조정할 수 있다. 각 BuilderCustomizer는 `MongoClientSettings` 빌드에 사용하는 `MongoClientSettings.Builder`를 넘겨 순서대로 호출한다.

URL을 변경하거나 *레플리카 셋*같은 다른 설정을 구성할 때는 다음 예제처럼 `spring.data.mongodb.uri` 프로퍼티를 사용해 설정할 수 있다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.data.mongodb.uri=mongodb://user:secret@mongo1.example.com:12345,mongo2.example.com:23456/test
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  data:
    mongodb:
      uri: "mongodb://user:secret@mongo1.example.com:12345,mongo2.example.com:23456/test"
```

아니면 개별적인 프로퍼티로 커넥션 연결 세부 정보를 지정해도 된다. 예를 들어 `application.properties`에 아래 설정을 선언할 수 있다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.data.mongodb.host=mongoserver.example.com
spring.data.mongodb.port=27017
spring.data.mongodb.database=test
spring.data.mongodb.username=user
spring.data.mongodb.password=secret
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  data:
    mongodb:
      host: "mongoserver.example.com"
      port: 27017
      database: "test"
      username: "user"
      password: "secret"
```

> `spring.data.mongodb.port`를 지정하지 않으면 기본값으로 `27017`을 사용한다. 위 예제에선 포트를 생략해도 된다.

> Spring Data MongoDB를 사용하지 않는다면 `MongoDatabaseFactory`를 사용하는 대신 `MongoClient` 빈을 주입하면 된다. MongoDB 커넥션 설정을 전부 직접 제어하고 싶다면 자체 `MongoDatabaseFactory`나 `MongoClient` 빈을 선언해도 된다.

> 리액티브 드라이버를 사용하고 있다면, SSL에는 Netty가 필요하다. Netty를 사용할 수 있고 사용할 팩토리를 이미 커스텀하지 않았다면 이 팩토리를 자동으로 설정한다.

#### MongoTemplate

[Spring Data MongoDB](https://spring.io/projects/spring-data-mongodb)는 스프링의 `JdbcTemplate`과 매우 유사하게 설계된 [`MongoTemplate`](https://docs.spring.io/spring-data/mongodb/docs/3.2. 2/api/org/springframework/data/mongodb/core/MongoTemplate.html) 클래스를 제공한다. 스프링 부트는 `JdbcTemplate`과 마찬가지로 이 템플릿도 주입해서 쓸 수 있도록 자동 설정한다:

```java
@Component
public class MyBean {

    private final MongoTemplate mongoTemplate;

    public MyBean(MongoTemplate mongoTemplate) {
        this.mongoTemplate = mongoTemplate;
    }

    // ...

}
```

자세한 내용은 [`MongoOperations` Javadoc](https://docs.spring.io/spring-data/mongodb/docs/3.2.2/api/org/springframework/data/mongodb/core/MongoOperations.html)을 참고해라.

#### Spring Data MongoDB Repositories

Spring Data는 MongoDB를 위한 레포지토리를 지원한다. 앞에서 설명했던 JPA 레포지토리와 마찬가지로, 쿼리는 메소드명을 기반으로 자동으로 구성된다는 게 기본 원칙이다.

사실 Spring Data JPA와 Spring Data MongoDB는 공통 인프라를 함께 공유한다. 앞에서 보여줬던 JPA 예제는, 이제 `City`는 JPA `@Entity`가 아닌 MongoDB 데이터 클래스라고 가정하면, 여기서도 동일하게 동작한다:

```java
public interface CityRepository extends Repository<City, Long> {

    Page<City> findAll(Pageable pageable);

    City findByNameAndStateAllIgnoringCase(String name, String state);

}
```

> `@EntityScan` 어노테이션을 사용하면 도큐먼트를 스캔할 위치를 커스텀할 수 있다.

> 풍부한 객체 매핑 기술을 활용하는 등, Spring Data MongoDB를 더 자세히 알고 싶다면 [레퍼런스 문서](https://spring.io/projects/spring-data-mongodb)를 참고해라.

#### Embedded Mongo

스프링 부트는 [임베디드 몽고](https://github.com/flapdoodle-oss/de.flapdoodle.embed.mongo) 자동 설정을 제공한다. 스프링 부트 애플리케이션에서 이 자동 설정을 활용하고 싶으면 `de.flapdoodle.embed:de.flapdoodle.embed.mongo` 의존성을 추가해라.

몽고가 수신<sup>listen</sup>할 포트는 `spring.data.mongodb.port` 프로퍼티로 설정할 수 있다. 여유 포트를 임의로 할당하려면 0을 지정해라. `MongoAutoConfiguration`으로 만들어진 `MongoClient`는 임의로 할당한 포트를 사용하도록 자동으로 설정된다.

> 커스텀 포트를 설정하지 않으면 임베디드 몽고는 기본적으로 랜덤 포트를 사용한다 (27017을 사용하지 않는다).

클래스패스에 SLF4J가 있으면 Mongo에서 출력한 내용은 자동으로 `org.springframework.boot.autoconfigure.mongo.embedded.EmbeddedMongo` 로거로 라우팅된다.

자체 `IMongodConfig`와 `IRuntimeConfig` 빈을 선언하면 Mongo 인스턴스 설정과 로그 라우팅을 제어할 수 있다. 다운로드 설정은 `DownloadConfigBuilderCustomizer` 빈을 선언해서 커스텀할 수 있다.

### 7.12.3. Neo4j

[Neo4j](https://neo4j.com/)는 1급<sup>first class</sup> 관계로 연결된 노드들을 데이터 모델로 사용하는 오픈 소스 NoSQL 그래프 데이터베이스로, 전통적인 RDBMS 접근 방식에 비해 서로 연결되어 있는 빅 데이터를 처리하기 적합한 데이터베이스다. 스프링 부트를 사용하면 `spring-boot-starter-data-neo4j` "스타터"를 활용하는 등, Neo4j 데이터 작업을 좀 더 수월하게 진행할 수 있다.

#### Connecting to a Neo4j Database

Neo4j 서버에 접근하려면 자동 설정된 `org.neo4j.driver.Driver`를 주입하면 된다. 이 인스턴스는 기본적으로 `localhost:7687`에서 Bolt 프로토콜을 통해 Neo4j 서버 연결을 시도한다. 다음은 데이터베이스에 접근할 때, 그 중에서도 `Session`에 대한 액세스를 제공하는 Neo4j `Driver`를 주입하는 예시다:

```java
@Component
public class MyBean {

    private final Driver driver;

    public MyBean(Driver driver) {
        this.driver = driver;
    }

    // ...

}
```

드라이버의 다양한 설정들은 `spring.neo4j.*` 프로퍼티로 설정할 수 있다. 다음 예시에선 사용할 uri와 credential을 설정하고 있다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.neo4j.uri=bolt://my-server:7687
spring.neo4j.authentication.username=neo4j
spring.neo4j.authentication.password=secret
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  neo4j:
    uri: "bolt://my-server:7687"
    authentication:
      username: "neo4j"
      password: "secret"
```

자동 설정된 `Driver`는 `ConfigBuilder`를 사용해서 만들어진다. 설정을 세세하게 변경하고 싶다면, `ConfigBuilderCustomizer` 빈을 하나 이상 선언해라. 각 BuilderCustomizer는 `Driver` 빌드에 사용하는 `ConfigBuilder`를 넘겨 순서대로 호출한다.

#### Spring Data Neo4j Repositories

Spring Data는 Neo4j를 위한 레포지토리를 지원한다. Spring Data Neo4j에 관한 자세한 내용은 [레퍼런스 문서](https://docs.spring.io/spring-data/neo4j/docs/6.1.2/reference/html/)를 참고해라.

다른 Spring Data 모듈이 많이들 그러하듯, Spring Data Neo4j는 Spring Data JPA와 공통 인프라를 공유한다. 앞에서 보여줬던 JPA 예제를 그대로 가져와서 `City`를 JPA `@Entity`가 아닌 Spring Data Neo4j `@Node`로 정의하면, 동일하게 레포지토리 추상화를 이용할 수 있다:

```java
public interface CityRepository extends Neo4jRepository<City, Long> {

    Optional<City> findOneByNameAndState(String name, String state);

}
```

`spring-boot-starter-data-neo4j` "스타터"는 레포지토리 기능과 트랜잭션 관리를 가능하게 해준다. 스프링 부트는 `Neo4jTemplate`과 `ReactiveNeo4jTemplate` 빈을 통해 각각 전형적인 Neo4j 레포지토리와 리액티브 Neo4j 레포지토리를 모두 지원한다. 클래스패스에 프로젝트 리액터가 있으면 리액티브 스타일도 자동으로 설정한다.

`@Configuration` 빈에 `@EnableNeo4jRepositories`와 `@EntityScan`을 사용하면 각각 레포지토리와 엔티티를 찾을 위치를 커스텀할 수 있다.

> 리액티브 스타일을 사용하는 애플리케이션에선 `ReactiveTransactionManager`를 자동으로 설정하지 않는다. 트랜잭션 관리를 활성화하려면 설정 안에 다음 빈을 정의해야 한다:
>
> ```java
> @Configuration(proxyBeanMethods = false)
> public class MyNeo4jConfiguration {
> 
>     @Bean
>     public ReactiveNeo4jTransactionManager reactiveTransactionManager(Driver driver,
>             ReactiveDatabaseSelectionProvider databaseNameProvider) {
>         return new ReactiveNeo4jTransactionManager(driver, databaseNameProvider);
>     }
> 
> }
> ```

### 7.12.4. Solr

[Apache Solr](https://lucene.apache.org/solr/)는 검색 엔진이다. 스프링 부트는 Solr 5 클라이언트 라이브러리를 위한 자동 설정을 제공한다.

#### Connecting to Solr

자동 설정된 `SolrClient` 인스턴스는 다른 스프링 빈과 동일하게 주입할 수 있다. 이 인스턴스는 기본적으로 `localhost:8983/solr`에서 서버 연결을 시도한다. 다음은 Solr 빈을 주입하는 예시다:

```java
@Component
public class MyBean {

    private final SolrClient solr;

    public MyBean(SolrClient solr) {
        this.solr = solr;
    }

    // ...

}
```

자체 `SolrClient` `@Bean`을 추가하면 기본 설정을 덮어쓰게 된다.

### 7.12.5. Elasticsearch

[Elasticsearch](https://www.elastic.co/products/elasticsearch)는 오픈 소스, 분산, RESTful 검색/분석 엔진이다. 스프링 부트는 Elasticsearch를 위한 기본적인 자동 설정을 제공한다.

스프링 부트는 몇 가지 클라이언트를 지원한다:

- 공식 자바 "Low Level", "High Level" REST 클라이언트
- Spring Data Elasticsearch가 제공하는 `ReactiveElasticsearchClient`

전용 "스타터" `spring-boot-starter-data-elasticsearch`도 제공한다.

#### Connecting to Elasticsearch using REST clients

Elasticsearch는 클러스터에 질의해볼 수 있는 [두 가지 REST 클라이언트](https://www.elastic.co/guide/en/elasticsearch/client/java-rest/current/index.html), "Low Level" 클라이언트와 "High Level"를 제공한다. 스프링 부트는 <span class="custom-blockquote">org.elasticsearch.client:elasticsearch-rest-high-level-client</span>로 제공하는 "High Level" 클라이언트를 지원한다.

클래스패스에 이 의존성이 있으면 스프링 부트는 기본적으로 `localhost:9200`에 연결하는 `RestHighLevelClient` 빈을 자동으로 설정하고 등록한다. 아래 예제처럼 `RestHighLevelClient`를 구성하는 방식을 좀 더 조정해도 된다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.elasticsearch.rest.uris=https://search.example.com:9200
spring.elasticsearch.rest.read-timeout=10s
spring.elasticsearch.rest.username=user
spring.elasticsearch.rest.password=secret
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  elasticsearch:
    rest:
      uris: "https://search.example.com:9200"
      read-timeout: "10s"
      username: "user"
      password: "secret"
```

다른 것들을 좀 더 커스텀하고 싶으면, `RestClientBuilderCustomizer`를 구현하는 빈을 원하는 만큼 추가해도 된다. 클라이언트를 등록하는 로직을 전부 직접 제어하고 싶으면 `RestClientBuilder` 빈을 정의해라.

> 애플리케이션에서 "Low Level" `RestClient`에 접근해야 한다면 자동 설정된 `RestHighLevelClient`에서 `client.getLowLevelClient()`를 호출하면 된다.

그 외에, `elasticsearch-rest-client-sniffer`가 클래스패스에 있으면, `Sniffer`를 자동 설정해서 실행 중인 Elasticsearch 클러스터에서 노드를 자동으로 발견하고, `RestHighLevelClient` 빈을 설정한다. 아래 예제처럼 `Sniffer`를 구성하는 방식을 좀 더 조정해도 된다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.elasticsearch.rest.sniffer.interval=10m
spring.elasticsearch.rest.sniffer.delay-after-failure=30s
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  elasticsearch:
    rest:
      sniffer:
        interval: 10m
        delay-after-failure: 30s
```

#### Connecting to Elasticsearch using Reactive REST clients

[Spring Data Elasticsearch](https://spring.io/projects/spring-data-elasticsearch)는 리액티브 방식으로 Elasticsearch 인스턴스를 질의할 수 있는 `ReactiveElasticsearchClient`를 제공한다. 웹플럭스의 `WebClient`를 기반으로 개발했기 때문에, 이 기능을 사용할 땐 `spring-boot-starter-elasticsearch`나 `spring-boot-starter-webflux` 둘 다 유용할 거다.

기본적으로 스프링 부트는 `localhost:9200`을 대상으로 갖는 `ReactiveElasticsearchClient` 빈을 자동 설정하고 등록한다. 아래 예제처럼 설정 방식을 좀 더 조정할 수도 있다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.data.elasticsearch.client.reactive.endpoints=search.example.com:9200
spring.data.elasticsearch.client.reactive.use-ssl=true
spring.data.elasticsearch.client.reactive.socket-timeout=10s
spring.data.elasticsearch.client.reactive.username=user
spring.data.elasticsearch.client.reactive.password=secret
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  data:
    elasticsearch:
      client:
        reactive:
          endpoints: "search.example.com:9200"
          use-ssl: true
          socket-timeout: "10s"
          username: "user"
          password: "secret"
```

설정 프로퍼티로는 해결할 수 없는 문제가 있어서 클라이언트 설정을 직접 제어할 때는 커스텀 `ClientConfiguration` 빈을 등록하면 된다.

#### Connecting to Elasticsearch by Using Spring Data

Elasticsearch에 연결하려면 스프링 부트의 자동 설정을 이용하거나 애플리케이션에서 수동으로 설정해서라도, 반드시 `RestHighLevelClient` 빈을 정의해야 한다 (이전 섹션 참고). 제대로 설정해주고 나면 아래처럼 `ElasticsearchRestTemplate`을 다른 스프링 빈처럼 주입해 쓸 수 있다:

```java
@Component
public class MyBean {

    private final ElasticsearchRestTemplate template;

    public MyBean(ElasticsearchRestTemplate template) {
        this.template = template;
    }

    // ...

}
```

`spring-data-elasticsearch`와, `WebClient`를 사용할 때 필요한 의존성이 있으면 (보통 `spring-boot-starter-webflux`) 스프링 부트는 [ReactiveElasticsearchClient](#connecting-to-elasticsearch-using-reactive-rest-clients)와 `ReactiveElasticsearchTemplate`도 빈으로 자동 설정한다. 이 둘은  REST 클라이언트의 리액티브 버전이다.

#### Spring Data Elasticsearch Repositories

Spring Data는 Elasticsearch를 위한 레포지토리를 지원한다. 앞에서 설명했던 JPA 레포지토리와 마찬가지로, 쿼리는 메소드명을 기반으로 자동으로 구성된다는 게 기본 원칙이다.

사실 Spring Data JPA와 Spring Data Elasticsearch 공통 인프라를 함께 공유한다. 앞에서 보여줬던 JPA 예제는, 이제 `City`는 JPA `@Entity`가 아닌 Elasticsearch `@Document` 클래스라고 가정하면, 여기서도 동일하게 동작한다:

> Spring Data Elasticsearch에 대한 자세한 내용은 [레퍼런스 문서](https://docs.spring.io/spring-data/elasticsearch/docs/current/reference/html/)를 참고해라.

스프링 부트는 `ElasticsearchRestTemplate` 혹은 `ReactiveElasticsearchTemplate` 빈을 통해 전형적인 Elasticsearch 레포지토리와 리액티브 Elasticsearch 레포지토리를 모두 지원한다. 이런 빈들은 필요한 의존성이 있을 땐 대부분 자동 설정된다.

Elasticsearch 레포지토리에서 사용할 자체 템플릿을 만들고 싶다면, `ElasticsearchRestTemplate`이나 `ElasticsearchOperations` `@Bean`을 추가하면 되며, 이름이 `"elasticsearchTemplate"`이기만 하면 된다. `ReactiveElasticsearchTemplate`과 `ReactiveElasticsearchOperations`도 동일하며, 이땐 이름이 "reactiveElasticsearchTemplate"이면 된다.

레포지토리 지원을 비활성화하고 싶으면 아래 프로퍼티를 사용하면 된다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.data.elasticsearch.repositories.enabled=false
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  data:
    elasticsearch:
      repositories:
        enabled: false
```

### 7.12.6. Cassandra

[Cassandra](https://cassandra.apache.org/)는 대량의 데이터를 많은 상용 서버에서 처리할 수 있게 설계한 오픈 소스, 분산 데이터베이스 관리 시스템이다. 스프링 부트는 Cassandra와, [Spring Data Cassandra](https://github.com/spring-projects/spring-data-cassandra)가 그 위에 구축해 놓은 추상화를 위한 자동 설정을 제공한다. `spring-boot-starter-data-cassandra` "스타터"는 의존성을 간편하게 수집해준다.

#### Connecting to Cassandra

자동 설정된 `CassandraTemplate`이나 Cassandra `CqlSession` 인스턴스는 다른 스프링 빈과 동일하게 주입해 쓸 수 있다. `spring.data.cassandra.*` 프로퍼티를 사용하면 커넥션을 커스텀할 수 있다. 보통은 아래 예제처럼 `keyspace-name`, `contact-points`와 로컬 데이터센터 이름을 제공한다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.data.cassandra.keyspace-name=mykeyspace
spring.data.cassandra.contact-points=cassandrahost1:9042,cassandrahost2:9042
spring.data.cassandra.local-datacenter=datacenter1
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  data:
    cassandra:
      keyspace-name: "mykeyspace"
      contact-points: "cassandrahost1:9042,cassandrahost2:9042"
      local-datacenter: "datacenter1"
```

모든 접점<sup>contact point</sup>에서 포트가 동일하다면 아래처럼 좀 더 짧게 호스트명만 지정해도 된다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.data.cassandra.keyspace-name=mykeyspace
spring.data.cassandra.contact-points=cassandrahost1,cassandrahost2
spring.data.cassandra.local-datacenter=datacenter1
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  data:
    cassandra:
      keyspace-name: "mykeyspace"
      contact-points: "cassandrahost1,cassandrahost2"
      local-datacenter: "datacenter1"
```

> 이 두 예시는 모두 기본 포트 `9042`를 사용한다. 포트를 설정해야 한다면 `spring.data.cassandra.port`를 사용해라.

> Cassandra 드라이버에는 클래스패스 루트에서 `application.conf`를 로드하는 자체 설정 인프라가 있다.
>
> 기본적으로 스프링 부트는 이런 파일은 찾지 않지만, `spring.data.cassandra.config`를 사용하면 파일을 로드할 수 있다. `spring.data.cassandra.*`와 이 설정 파일에 같은 프로퍼티가 있을 땐 `spring.data.cassandra.*`에 있는 값을 우선한다.
>
> 드라이버를 그 이상으로 커스텀하고 싶으면, `DriverConfigLoaderBuilderCustomizer`를 구현하는 빈을 원하는 만큼 추가해도 된다. `CqlSession`은 `CqlSessionBuilderCustomizer` 타입 빈으로 커스텀할 수 있다.

> `CqlSessionBuilder`로 `CqlSession` 빈을 여러 개 만든다면, 빌더는 변경이 가능하므로<sup>mutable</sup> 각 세션마다 새로운 복사본을 주입해야 한다는 점을 기억해두자.

다음은 Cassandra 빈을 주입하는 예시다:

```java
@Component
public class MyBean {

    private final CassandraTemplate template;

    public MyBean(CassandraTemplate template) {
        this.template = template;
    }

    // ...

}
```

자체 `CassandraTemplate` `@Bean`을 추가하면 기본 설정을 덮어쓰게 된다.

#### Spring Data Cassandra Repositories

Spring Data는 Cassandra를 위한 기본적인 레포지토리를 지원한다. 현재로썬 Cassandra 지원은 앞서 논의한 JPA 레포지토리에 비하면 좀 더 제한적이며, finder 메소드에 `@Query` 어노테이션을 달아줘야 한다.

> Spring Data Cassandra에 대한 자세한 내용은 [레퍼런스 문서](https://docs.spring.io/spring-data/cassandra/docs/)를 참고해라.

### 7.12.7. Couchbase

[Couchbase](https://www.couchbase.com/)는 대화형 애플리케이션<sup>interactive application</sup>에 최적화된 오픈 소스, 분산, multi-model NoSQL 도큐먼트 지향<sup>document-oriented</sup> 데이터베이스다. 스프링 부트는 Couchbase와, [Spring Data Couchbase](https://github.com/spring-projects/spring-data-couchbase)가 그 위에 구축해 놓은 추상화를 위한 자동 설정을 제공한다. `spring-boot-starter-data-couchbase`, `spring-boot-starter-data-couchbase-reactive` "스타터"는 의존성을 간편하게 수집해준다.

#### Connecting to Couchbase

Couchbase SDK와 몇 가지 설정을 추가하면 `Cluster`를 가져올 수 있다. 커넥션을 커스텀할 땐 `spring.couchbase.*` 프로퍼티를 사용한다. 보통은 아래처럼 [커넥션 문자열](https://github.com/couchbaselabs/sdk-rfcs/blob/master/rfc/0011-connection-string.md), username, password를 지정한다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.couchbase.connection-string=couchbase://192.168.1.123
spring.couchbase.username=user
spring.couchbase.password=secret
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  couchbase:
    connection-string: "couchbase://192.168.1.123"
    username: "user"
    password: "secret"
```

일부 `ClusterEnvironment` 설정을 커스텀하는 것도 가능하다. 예를 들어, 아래 설정은 새 `Bucket`을 열 때 사용할 타임아웃을 변경하고 SSL 지원을 활성화한다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.couchbase.env.timeouts.connect=3s
spring.couchbase.env.ssl.key-store=/location/of/keystore.jks
spring.couchbase.env.ssl.key-store-password=secret
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  couchbase:
    env:
      timeouts:
        connect: "3s"
      ssl:
        key-store: "/location/of/keystore.jks"
        key-store-password: "secret"
```

> 자세한 내용은 `spring.couchbase.env.*` 프로퍼티를 확인해봐라. 더 많은 것들을 제어하고 싶다면 `ClusterEnvironmentBuilderCustomizer` 빈을 하나 이상 사용해도 된다.

#### Spring Data Couchbase Repositories

Spring Data는 Couchbase를 위한 레포지토리를 지원한다. Spring Data Couchbase에 대한 자세한 내용은 [레퍼런스 문서](https://docs.spring.io/spring-data/couchbase/docs/4.2.2/reference/html/)를 참고해라.

`CouchbaseClientFactory` 빈이 설정됐다면, 자동 설정된 `CouchbaseTemplate` 인스턴스를 다른 스프링 빈과 마찬가지로 주입해 쓸 수 있다. 위에서 설명한 대로 `Cluster`를 가져올 수 있고 버킷명을 지정했을 때 가능하다.

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.data.couchbase.bucket-name=my-bucket
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  data:
    couchbase:
      bucket-name: "my-bucket"
```

다음은 `CouchbaseTemplate` 빈을 주입하는 방법을 보여주는 예시다:

```java
@Component
public class MyBean {

    private final CouchbaseTemplate template;

    public MyBean(CouchbaseTemplate template) {
        this.template = template;
    }

    // ...

}
```

자체 설정에 정의하면, 자동 설정으로 세팅되는 것들을 재정의할 수 있는 빈이 몇 가지 있다:

- `couchbaseMappingContext`라는 이름을 가진 `CouchbaseMappingContext` `@Bean`.
- `couchbaseCustomConversions`라는 이름을 가진 `CustomConversions` `@Bean`.
- `couchbaseTemplate`이라는 이름을 가진 `CouchbaseTemplate` `@Bean`.

자체 설정에서 이 이름을 하드 코딩하기 싫다면 Spring Data Couchbase에서 제공하는 `BeanNames`를 재사용하면 된다. 예를 들어 다음과 같이 사용할 컨버터를 커스텀할 수 있다:

```java
@Configuration(proxyBeanMethods = false)
public class MyCouchbaseConfiguration {

    @Bean(BeanNames.COUCHBASE_CUSTOM_CONVERSIONS)
    public CouchbaseCustomConversions myCustomConversions() {
        return new CouchbaseCustomConversions(Arrays.asList(new MyConverter()));
    }

}
```

### 7.12.8. LDAP

[LDAP<sup>Lightweight Directory Access Protocol</sup>](https://en.wikipedia.org/wiki/Lightweight_Directory_Access_Protocol)은 IP 네트워크를 통해 분산되어 있는 디렉토리 정보 서비스에 접근하고 관리하기 위한 개방형, 벤더 중립, 산업 표준 애플리케이션 프로토콜이다. 스프링 부트는 호환되는 모든 LDAP 서버를 위한 자동 설정과, [UnboundID](https://ldap.com/unboundid-ldap-sdk-for-java/)의 임베디드 인메모리 LDAP 서버를 지원한다.

LDAP 추상화는 [Spring Data LDAP](https://github.com/spring-projects/spring-data-ldap)에서 제공한다. `spring-boot-starter-data-ldap` "스타터"는 의존성을 간편하게 수집해준다.

#### Connecting to an LDAP Server

LDAP 서버에 연결하려면 `spring-boot-starter-data-ldap` "스타터"나 `spring-ldap-core` 의존성을 선언한 다음, 아래 예제처럼 `application.properties`에 서버 URL을 지정해야 한다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.ldap.urls=ldap://myserver:1235
spring.ldap.username=admin
spring.ldap.password=secret
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  ldap:
    urls: "ldap://myserver:1235"
    username: "admin"
    password: "secret"
```

커넥션 설정을 커스텀해야 한다면 `spring.ldap.base`와 `spring.ldap.base-environment` 프로퍼티를 사용하면 된다.

이 설정들을 기반으로 `LdapContextSource`를 자동 설정한다. `DirContextAuthenticationStrategy` 빈을 사용할 수 있으면 자동 설정된 `LdapContextSource`에 연결된다. `PooledContextSource`를 사용하는 등, `LdapContextSource`를 커스텀할 때도 자동 설정된 `LdapContextSource`를 주입할 수 있다. 주의할 점은, 커스텀한 `ContextSource`에 `@Primary` 플래그를 지정해서 자동 설정된 `LdapTemplate`에서 커스텀 빈을 사용할 수 있도록 해줘야 한다.

#### Spring Data LDAP Repositories

Spring Data는 LDAP을 위한 레포지토리를 지원한다. Spring Data LDAP에 대한 자세한 내용은 [레퍼런스 문서](https://docs.spring.io/spring-data/ldap/docs/1.0.x/reference/html/)를 참고해라.

자동 설정된 `LdapTemplate` 인스턴스도 다른 스프링 빈처럼 주입해 사용할 수 있다:

```java
@Component
public class MyBean {

    private final LdapTemplate template;

    public MyBean(LdapTemplate template) {
        this.template = template;
    }

    // ...

}
```

#### Embedded In-memory LDAP Server

스프링 부트는 테스트를 위한 [UnboundID](https://ldap.com/unboundid-ldap-sdk-for-java/)의 인메모리 LDAP 서버 자동 설정을 지원한다. 이 서버를 구성하려면 `com.unboundid:unboundid-ldapsdk` 의존성을 추가하고, 다음과 같이 `spring.ldap.embedded.base-dn` 프로퍼티를 선언해라:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.ldap.embedded.base-dn=dc=spring,dc=io
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  ldap:
    embedded:
      base-dn: "dc=spring,dc=io"
```

> base-dn에는 값을 여러 개 정의할 수 있지만, DN<sup>distinguished name</sup>에는 보통 쉼표가 들어가기 때문에, 반드시 올바른 표기법으로 작성해야 한다.
>
> yaml 파일에선 yaml 리스트 표기법을 사용하면 된다. properties 파일에선 반드시 프로퍼티 이름에 인덱스를 넣어야 한다:
>
> <div class="switch-language-wrapper properties yaml">
> <span class="switch-language properties">properties</span>
> <span class="switch-language yaml">yaml</span>
> </div>
> <div class="language-only-for-properties properties yaml"></div>
> ```properties
> spring.ldap.embedded.base-dn[0]=dc=spring,dc=io
> spring.ldap.embedded.base-dn[1]=dc=pivotal,dc=io
> ```
> <div class="language-only-for-yaml properties yaml"></div>
> ```yaml
> spring.ldap.embedded.base-dn:
>   - dc=spring,dc=io
>   - dc=pivotal,dc=io
> ```

이 서버는 기본적으로 랜덤 포트에서 시작하고 일반적인 LDAP 지원을 트리거한다. `spring.ldap.urls` 프로퍼티는 지정할 필요 없다.

클래스패스에 `schema.ldif` 파일이 있으면 이 파일을 사용해서 서버를 초기화한다. 초기화 스크립트를 다른 리소스에서 로드하고 싶다면 `spring.ldap.embedded.ldif` 프로퍼티를 사용해도 된다.

기본적으로 `LDIF` 파일은 표준 스키마를 사용해서 검증한다. `spring.ldap.embedded.validation.enabled` 프로퍼티를 설정하면 유효성 검사를 완전히 꺼버릴 수 있다. 커스텀 속성이 있다면 `spring.ldap.embedded.validation.schema`를 통해 커스텀 속성 타입이나 객체 클래스를 정의할 수 있다.

### 7.12.9. InfluxDB

[InfluxDB](https://www.influxdata.com/)는 운영 모니터링, 애플리케이션 메트릭, IOT<sup>Internet-of-Things</sup> 센서 데이터, 실시간 분석과 같은 분야에서 사용하는 시계열 데이터를 빠르게 저장하고 조회할 수 있도록 최적화한 고가용성 오픈 소스 시계열 데이터베이스다.

#### Connecting to InfluxDB

클래스패스에 `influxdb-java` 클라이언트가 있을 때 아래 예시처럼 데이터베이스 URL을 설정하면 스프링 부트는 `InfluxDB` 인스턴스를 자동 설정한다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.influx.url=https://172.0.0.1:8086
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  influx:
    url: "https://172.0.0.1:8086"
```

InfluxDB 커넥션에 user와 password를 사용해야 한다면 `spring.influx.user`와 `spring.influx.password` 프로퍼티를 적절히 설정하면 된다.

InfluxDB는 OkHttp를 사용한다. `InfluxDB` 내부에서 사용하는 http 클라이언트 설정을 조정하고 싶으면 `InfluxDbOkHttpClientBuilderProvider` 빈을 등록하면 된다.

설정을 그 이상으로 제어해야 한다면 `InfluxDbCustomizer` 빈을 등록하는 걸 검토해봐라.
