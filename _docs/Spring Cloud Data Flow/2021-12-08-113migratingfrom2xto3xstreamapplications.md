---
title: Migrating from 2.x to 3.x Stream Applications
navTitle: Migration Guide for Pre-packaged Stream Applications
category: Spring Cloud Data Flow
order: 113
permalink: /Spring%20Cloud%20Data%20Flow/applications.migration/
description: Spring Cloud Stream 애플리케이션 마이그레이션 가이드
image: ./../../images/springclouddataflow/logo.png
lastmod: 2021-12-08T01:00:00+09:00
comments: true
originalRefName: 스프링 클라우드 데이터 플로우
originalRefLink: https://dataflow.spring.io/docs/applications/migration/
parent: Using Applications with Spring Cloud Data Flow
parentNavTitle: Applications
parentUrl: /Spring%20Cloud%20Data%20Flow/applications/
---

---

스프링 팀은 최근에 [미리 패키징해서 제공하는 스트림 애플리케이션들을 재설계](https://spring.io/blog/2020/07/13/introducing-java-functions-for-spring-cloud-stream-applications-part-0)했다. 새로 설계한 애플리케이션들을 배포할 땐 릴리즈 이름에 `2020.0.0-RC2`와 같은 날짜를 사용한다. 이렇게 릴리즈한 스트림 애플리케이션들은 `3.0.0` 버전부터 시작하기 때문에, `3.x`(+) 버전도 참조하고 있다. 여기서는 많은 것들이 개선되면서 `2.x` 라인과는 호환되지 않는 변경 사항이 들어갔다. 따라서 `2.x` 애플리케이션을 기반으로 정의한 기존 Spring Cloud Data Flow 스트림은 `3.x` 애플리케이션으로 바로 전환되지 않는다. `2.x` Spring Cloud Stream 애플리케이션을 `3.x`로 마이그레이션할 때 알아둬야 할 변경점들은 아래에 요약해뒀다:

- 일부 애플리케이션은 이름이 변경됐다.
- 제거되거나, 같은 기능을 제공하는 앱으로 대체되거나, 다른 앱과 결합된 애플리케이션도 있다.
- 프로퍼티 프리픽스가 변경됐다.
- 프로퍼티를 제거하거나 새로 추가한 애플리케이션도 있다.
- 미리 빌드해 제공하는 모든 소스 애플리케이션은 이제 function composition을 지원한다.

`2.x`와 `3.x` 애플리케이션을 혼용하는 파이프라인은 지원하지 않는다. 애플리케이션 버전이 다르면 Spring Cloud Stream 바인더 버전도 다르다. 다른 버전을 결합하려고 하면 간혹 문제가 발생하는 것으로 알려져 있다. 기존 데이터 파이프라인에 `3.x`에서 사용할 수 없는 앱이 필요하다면 업그레이드하지 않는 게 좋다.

### 목차

- [Application changes](#application-changes)
- [Property names](#property-names)
- [Function Composition](#function-composition)

---

## Application changes

아래 있는 애플리케이션은 `3.x` 라인에서 제거하거나, 다른 애플리케이션으로 대체했거나, 이름이 변경된 애플리케이션들이다. replacement 컬럼에 `None`이라고 나와있는 애플리케이션은, 커뮤니티에서 많이 언급되지 않는 이상 지원을 중단한다는 의미다.

| Retired                               | Replacement                                                  |
| ------------------------------------- | ------------------------------------------------------------ |
| counter-processor                     | None                                                         |
| counter-sink                          | analytics-sink                                               |
| gemfire-cq-source                     | geode-source with cq option                                  |
| gemfire-source                        | geode-source                                                 |
| gemfire-sink                          | geode-sink                                                   |
| groovy-filter-processor               | groovy-processor                                             |
| groovy-transform-processor            | groovy-processor                                             |
| grpc-processor                        | None                                                         |
| hdfs-sink                             | None                                                         |
| httpclient-processor                  | http-request-processor                                       |
| loggregator-source                    | None                                                         |
| pmml-processor                        | None                                                         |
| pose-estimation-processor             | None                                                         |
| python-http-processor                 | [Polyglot 레시피](../recipes.polyglot)를 사용해라 |
| python-jython-processor               | [Polyglot 레시피](../recipes.polyglot)를 사용해라 |
| redis-pubsub-sink                     | redis-sink                                                   |
| scriptable-transform-processor        | script-processor                                             |
| sftp-dataflow-source                  | sftp-source with function composition                        |
| task-launcher-dataflow-sink           | tasklauncher-sink                                            |
| tasklaunchrequest-transform-processor | None                                                         |
| tcp-client-processor                  | None                                                         |
| tcp-client-source                     | None                                                         |
| tensorflow-processor                  | Custom app using [tensorflow-common](https://github.com/spring-cloud/stream-applications/blob/master/functions/common/tensorflow-common) function library |
| trigger-source                        | time-source                                                  |
| triggertask-source                    | time-source                                                  |
| twitter-sentiment-processor           | None                                                         |
| twitterstream-source                  | twitter-stream-source                                        |

---

## Property names

아래 있는 애플리케이션들은 `2.x` 애플리케이션과 동일한 이름으로 `3.x` 라인으로 넘어온 애플리케이션들이다. 각 링크를 누르면 해당 애플리케이션에서 사용하는 프로퍼티 키를 상세히 비교해둔 테이블로 이동한다. 이중 일부 앱은 모든 프로퍼티가 달라지지 않고 그대로 넘어갔지만, 참고용으로 함께 정리해뒀다.

| Sources                                                      | Processors                                                   | Sinks                                                        |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| [cdc-debezium-source](https://dataflow.spring.io/docs/applications/migration/cdc-debezium-source/) | [aggregator-processor](https://dataflow.spring.io/docs/applications/migration/aggregator-processor/) | [cassandra-sink](https://dataflow.spring.io/docs/applications/migration/cassandra-sink/) |
| [file-source](https://dataflow.spring.io/docs/applications/migration/file-source/) | [filter-processor](https://dataflow.spring.io/docs/applications/migration/filter-processor/) | [file-sink](https://dataflow.spring.io/docs/applications/migration/file-sink/) |
| [ftp-source](https://dataflow.spring.io/docs/applications/migration/ftp-source/) | [header-enricher-processor](https://dataflow.spring.io/docs/applications/migration/header-enricher-processor/) | [ftp-sink](https://dataflow.spring.io/docs/applications/migration/ftp-sink/) |
| [http-source](https://dataflow.spring.io/docs/applications/migration/http-source/) | [image-recognition-processor](https://dataflow.spring.io/docs/applications/migration/image-recognition-processor/) | [jdbc-sink](https://dataflow.spring.io/docs/applications/migration/jdbc-sink/) |
| [jdbc-source](https://dataflow.spring.io/docs/applications/migration/jdbc-source/) | [object-detection-processor](https://dataflow.spring.io/docs/applications/migration/object-detection-processor/) | [log-sink](https://dataflow.spring.io/docs/applications/migration/log-sink/) |
| [jms-source](https://dataflow.spring.io/docs/applications/migration/jms-source/) | [splitter-processor](https://dataflow.spring.io/docs/applications/migration/splitter-processor/) | [mondodb-sink](https://dataflow.spring.io/docs/applications/migration/mongodb-sink/) |
| [load-generator-source](https://dataflow.spring.io/docs/applications/migration/load-generator-source/) |                                                              | [mqtt-sink](https://dataflow.spring.io/docs/applications/migration/mqtt-sink/) |
| [mail-source](https://dataflow.spring.io/docs/applications/migration/mail-source/) |                                                              | [pgpcopy-sink](https://dataflow.spring.io/docs/applications/migration/pgcopy-sink/) |
| [mongodb-source](https://dataflow.spring.io/docs/applications/migration/mongodb-source/) |                                                              | [rabbit-sink](https://dataflow.spring.io/docs/applications/migration/rabbit-sink/) |
| [mqtt-source](https://dataflow.spring.io/docs/applications/migration/mqtt-source/) |                                                              | [router-sink](https://dataflow.spring.io/docs/applications/migration/router-sink/) |
| [rabbit-source](https://dataflow.spring.io/docs/applications/migration/rabbit-source/) |                                                              | [s3-sink](https://dataflow.spring.io/docs/applications/migration/s3-sink/) |
| [s3-source](https://dataflow.spring.io/docs/applications/migration/s3-source/) |                                                              | [sftp-sink](https://dataflow.spring.io/docs/applications/migration/sftp-sink/) |
| [sftp-source](https://dataflow.spring.io/docs/applications/migration/sftp-source/) |                                                              | [tcp-sink](https://dataflow.spring.io/docs/applications/migration/tcp-sink/) |
| [syslog-source](https://dataflow.spring.io/docs/applications/migration/syslog-source/) |                                                              | [throughput-sink](https://dataflow.spring.io/docs/applications/migration/throughput-sink/) |
| [tcp-source](https://dataflow.spring.io/docs/applications/migration/tcp-source/) |                                                              | [websocket-sink](https://dataflow.spring.io/docs/applications/migration/websocket-sink/) |
| [time-source](https://dataflow.spring.io/docs/applications/migration/time-source/) |                                                              |                                                              |

---

## Function Composition

`3.x` 스트림 애플리케이션들은 함수 기반 애플리케이션이다. 즉, functional 인터페이스를 노출하는 아티팩트 의존성을 가지고 있으며, 대부분의 로직을 이 아티팩트로 제공한다. 이 디자인은 [function composition](https://github.com/spring-cloud/stream-applications/blob/master/docs/FunctionComposition.adoc)에 적합한 설계다. 사실, 미리 패키징해 제공하는 모든 소스 애플리케이션들은 function composition을 지원하는 데 필요한 의존성이 포함돼 있으며, 앱 자체에선 이 의존성을 사용해 필터링, 변환, 헤더 추가<sup>enrichment</sup>, 태스크 시작 요청 생성 등의 로직을 수행한다. 예시가 궁금하다면 [time source 테스트](https://github.com/spring-cloud/stream-applications/blob/master/applications/source/time-source/src/test/java/org/springframework/cloud/stream/app/source/time/TimeSourceTests.java)와 [sftp source 테스트](https://github.com/spring-cloud/stream-applications/blob/master/applications/source/sftp-source/src/test/java/org/springframework/cloud/stream/app/source/sftp/SftpSourceTests.java) 코드를 확인해보면 된다.