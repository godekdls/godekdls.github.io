---
title: Pre-packaged Applications
category: Spring Cloud Data Flow
order: 111
permalink: /Spring%20Cloud%20Data%20Flow/applications.pre-packaged/
description: 미리 패키징해 제공하는 스트림 애플리케이션(3.x) 목록과 벌크로 등록하는 방법
image: ./../../images/springclouddataflow/logo.png
lastmod: 2021-12-08T01:00:00+09:00
comments: true
originalRefName: 스프링 클라우드 데이터 플로우
originalRefLink: https://dataflow.spring.io/docs/applications/pre-packaged/
parent: Using Applications with Spring Cloud Data Flow
parentNavTitle: Applications
parentUrl: /Spring%20Cloud%20Data%20Flow/applications/
---

---

> 이 페이지엔 `stream-applications`의 최신 3.x 버전(릴리즈 2020.0.0+)에 관한 정보가 담겨 있으며, 2.x (Einstein) 릴리즈와는 호환되지 않는 새로운 기능과 몇 가지 변경점을 소개한다. 2.x 릴리즈에 대한 정보를 찾고 있다면 [pre-packaged applications 2.x](../applications.pre-packaged2x)를 읽어보면 된다.

스프링 팀은 애플리케이션들을 선별해서 미리 패키징해 제공하고 있기 때문에, 이 애플리케이션들을 이용해 다양한 데이터를 통합하고 파이프라인을 조합해서 프로덕션용 Spring Cloud Data Flow를 개발하고, 학습하고, 실험해볼 수 있다.

### 목차

- [Getting Started](#getting-started)
  + [Kafka](#kafka)
  + [RabbitMQ](#rabbitmq)
- [Stream Applications](#stream-applications)
- [Bulk Registration of Stream Applications](#bulk-registration-of-stream-applications)
- [Supported Spring Cloud Stream Applications](#supported-spring-cloud-stream-applications)
- [Supported Spring Cloud Task and Batch Applications](#supported-spring-cloud-task-and-batch-applications)
- [Previous Releases of Stream Applications (2020)](#previous-releases-of-stream-applications-2020)
- [Previous Releases of Stream Applications (Einstein)](#previous-releases-of-stream-applications-einstein)
- [Previous Releases of Spring Cloud Task and Batch Applications](#previous-releases-of-spring-cloud-task-and-batch-applications)

---

## Getting Started

미리 패키징해서 제공하는 스트리밍 애플리케이션들은 모두:

- 아파치 메이븐 아티팩트 또는 도커 이미지로 사용할 수 있다.
- RabbitMQ나 아파치 카프카를 사용한다.
- [프로메테우스](https://prometheus.io/)와 [InfluxDB](https://www.influxdata.com/)를 이용한 모니터링을 지원한다.
- UI와 쉘의 코드 자동 완성에 사용되는 애플리케이션 프로퍼티 메타데이터를 가지고 있다.

스트림, 태스크 애플리케이션들은  Data Flow UI나 쉘을 사용해서 등록하면 된다.

`app register` 명령어를 사용하면 애플리케이션들을 개별적으로 등록할 수 있고, `app import` 명령어를 사용하면 벌크로 등록할 수 있다. 

스트림 애플리케이션을 등록할 땐, 카프카와 RabbitMQ 중 어떤 것을 사용하는지에 따라 그에 맞는 URL을 사용하면 된다:

### Kafka

- https://dataflow.spring.io/kafka-docker-latest
- https://dataflow.spring.io/kafka-maven-latest

### RabbitMQ

- https://dataflow.spring.io/rabbitmq-docker-latest
- https://dataflow.spring.io/rabbitmq-maven-latest

Data Flow UI에선 아래 이미지에 보이는 것처럼 기본 링크가 미리 채워져 있다:

![Bulk register applications](./../../images/springclouddataflow/bulk-registration.webp)

Data Flow 쉘을 사용한다면, 아래 예시처럼 애플리케이션을 벌크로 임포트하고 등록하면 된다:

```bash
dataflow:>app import --uri https://dataflow.spring.io/kafka-maven-milestone
```

---

## Stream Applications

스프링 팀이 [스트림 애플리케이션](https://spring.io/projects/spring-cloud-stream-applications#learn)을 개발하고 관리할 땐 보통, 주요 스프링 부트 릴리즈나 Spring Cloud Stream 릴리즈에 일정을 맞춰서 진행한다. 이 애플리케이션들은 [스프링 public 메이븐 레포지토리](https://repo.spring.io/release/org/springframework/cloud/stream/app/)와 [도커허브](https://hub.docker.com/u/springcloudstream)에 올라간다. 미리 패키징해서 제공하는 스트림 애플리케이션은 결국 특정한 바인더 구현체를 사용해 빌드한 스프링 부트 executable jar다. 모든 스트림 앱은 RabbitMQ와 카프카를 사용하는 executable 애플리케이션을 별도로 나눠서 제공한다.

다음은 현재 사용할 수 있는 스트림 애플리케이션들을 정리한 테이블이다:

| Source                                                       | Processor                                                    | Sink                                                         |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| [cdc-debezium](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-cdc-debezium-source) | [aggregator](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-aggregator-processor) | [analytics](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-analytics-sink) |
| [file](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-file-source) | [bridge](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-bridge-processor) | [cassandra](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-cassandra-sink) |
| [ftp](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-ftp-source) | [filter](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-filter-processor) | [dataflow-tasklauncher](https://github.com/spring-cloud/spring-cloud-dataflow/blob/main/spring-cloud-dataflow-tasklauncher/spring-cloud-dataflow-tasklauncher-sink/README.adoc) |
| [geode](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-geode-source) | [groovy](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-groovy-processor) | [elasticsearch](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-elasticsearch-sink) |
| [http](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-http-source) | [header-enricher](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-header-enricher-processor) | [file](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-file-sink) |
| [jdbc](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-jdbc-source) | [http-request](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-http-request-processor) | [ftp](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-ftp-sink) |
| [jms](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-jms-source) | [image-recognition](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-image-recognition-processor) | [geode](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-geode-sink) |
| [load-generator](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-load-generator-source) | [object-detection](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-object-detection-processor) | [jdbc](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-jdbc-sink) |
| [mail](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-mail-source) | [semantic-segmentation](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-semantic-segmentation-processor) | [log](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-log-sink) |
| [mongodb](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-mongodb-source) | [script](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-script-processor) | [mongodb](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-mongodb-sink) |
| [mqtt](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-mqtt-source) | [splitter](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-splitter-processor) | [mqtt](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-mqtt-sink) |
| [rabbit](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-rabbit-source) | [transform](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-transform-processor) | [pgcopy](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-pgcopy-sink) |
| [s3](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-s3-source) | [twitter-trend](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-twitter-trend-processor) | [rabbit](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-rabbit-sink) |
| [sftp](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-sftp-source) |                                                              | [redis](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-redis-sink) |
| [syslog](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-syslog-source) |                                                              | [router](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-router-sink) |
| [tcp](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-tcp-source) |                                                              | [rsocket](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-rsocket-sink) |
| [time](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-time-source) |                                                              | [s3](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-s3-sink) |
| [twitter-message](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-twitter-message-source) |                                                              | [sftp](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-sftp-sink) |
| [twitter-search](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-twitter-search-source) |                                                              | [tcp](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-tcp-sink) |
| [twitter-stream](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-twitter-stream-source) |                                                              | [throughput](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-throughput-sink) |
| [websocket](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-websocket-source) |                                                              | [twitter-message](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-twitter-message-sink) |
| [zeromq](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-zeromq-source) |                                                              | [twitter-update](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-twitter-update-sink) |
|                                                              |                                                              | [wavefront](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-wavefront-sink) |
|                                                              |                                                              | [websocket](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-websocket-sink) |
|                                                              |                                                              | [zeromq](https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#spring-cloud-stream-modules-zeromq-sink) |

---

## Bulk Registration of Stream Applications

Spring Cloud Data Flow에선 표준 properties 파일을 이용해 애플리케이션을 벌크 등록할 수 있다. 편의를 위해 기본 제공하는 모든 스트림, 태스크/배치 앱들의 애플리케이션 URI(메이븐이나 도커 전용)를 가지고 있는 스태틱 프로퍼티 파일도 게시하고 있으므로, 바로 활용해도 좋다. 이 파일을 사용하면 모든 애플리케이션 URI를 한 번에 등록할 수 있다. 아니면 개별적으로 등록해도 되고, 필요한 애플리케이션 URI만 들어있는 자체 커스텀 프로퍼티 파일을 만들어도 된다. SCDF를 처음 시작할 때는 앱들을 벌크로 등록해서 쓰면 편리할 거다. 너무 복잡하게 가기보단, 커스텀 프로퍼티 파일을 만들어 필요한 애플리케이션 URI 목록만 "집중해서" 관리하는 것을 권장한다.

---

## Supported Spring Cloud Stream Applications

| Artifact Type                       | Latest Stable Release                             | SNAPSHOT Release                                           |
| ----------------------------------- | ------------------------------------------------- | ---------------------------------------------------------- |
|                                     | spring-cloud-stream 3.1.x spring-boot 2.5.x       |                                                            |
| RabbitMQ + Maven                    | https://dataflow.spring.io/rabbitmq-maven-latest  | https://dataflow.spring.io/rabbitmq-maven-latest-snapshot  |
| RabbitMQ + Docker (Docker Hub)      | https://dataflow.spring.io/rabbitmq-docker-latest | https://dataflow.spring.io/rabbitmq-docker-latest-snapshot |
| RabbitMQ + Docker (Harbor Registry) | https://dataflow.spring.io/rabbitmq-harbor-latest | N/A                                                        |
| Kafka + Maven                       | https://dataflow.spring.io/kafka-maven-latest     | https://dataflow.spring.io/kafka-maven-latest-snapshot     |
| Kafka + Docker                      | https://dataflow.spring.io/kafka-docker-latest    | https://dataflow.spring.io/kafka-docker-latest-snapshot    |
| Kafka + Docker (Harbor Registry)    | https://dataflow.spring.io/kafka-harbor-latest    | N/A                                                        |

---

## Supported Spring Cloud Task and Batch Applications

| Artifact Type | Latest Stable Release                                        | SNAPSHOT Release                                             |
| ------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
|               | spring-cloud-stream 2.1.x spring-boot 2.1.x                  |                                                              |
| Maven         | https://dataflow.spring.io/task-maven-latest | https://dataflow.spring.io/Elston-BUILD-SNAPSHOT-task-applications-maven |
| Docker        | https://dataflow.spring.io/task-docker-latest                | https://dataflow.spring.io/Elston-BUILD-SNAPSHOT-task-applications-docker |

---

여기서 부터 나오는 테이블들은 이전 릴리즈 버전을 정리해둔 건데, 참고만 하도록 하자. 더 이상 지원하지 않을 수도 있으니 주의해야 한다. (ex. EOL 스프링 부트 릴리즈에 따라 다르다).

---

## Previous Releases of Stream Applications (2020)

| Artifact Type                       | Latest Stable Release                                        | SNAPSHOT Release                                             |
| ----------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
|                                     | spring-cloud-stream 3.0.x spring-boot 2.3.x                  |                                                              |
| RabbitMQ + Maven                    | https://dataflow.spring.io/rabbitmq-maven-2020               | %stream-app-rabbit-maven-2020-snapshot"% |
| RabbitMQ + Docker (Docker Hub)      | https://dataflow.spring.io/rabbitmq-docker-2020 | https://dataflow.spring.io/rabbitmq-docker-2020-snapshot |
| RabbitMQ + Docker (Harbor Registry) | https://dataflow.spring.io/rabbitmq-harbor-2020 | N/A                                                          |
| Kafka + Maven                       | https://dataflow.spring.io/kafka-maven-2020                  | https://dataflow.spring.io/kafka-maven-2020-snapshot         |
| Kafka + Docker                      | https://dataflow.spring.io/kafka-docker-2020                 | https://dataflow.spring.io/kafka-docker-2020-snapshot        |
| Kafka + Docker (Harbor Registry)    | https://dataflow.spring.io/kafka-harbor-2020                 | N/A                                                          |

---

## Previous Releases of Stream Applications (Einstein)

| Artifact Type     | Previous Release                                    |
| ----------------- | --------------------------------------------------- |
|                   | spring-cloud-stream 2.0.x spring-boot 2.0.x         |
| RabbitMQ + Maven  | https://dataflow.spring.io/rabbitmq-maven-einstein  |
| RabbitMQ + Docker | https://dataflow.spring.io/rabbitmq-docker-einstein |
| Kafka + Maven     | https://dataflow.spring.io/kafka-maven-einstein     |
| Kafka + Docker    | https://dataflow.spring.io/kafka-docker-einstein    |

---

## Previous Releases of Spring Cloud Task and Batch Applications

| Artifact Type | Previous Release                                             |
| ------------- | ------------------------------------------------------------ |
|               | spring-cloud-stream 2.0.x spring-boot 2.0.x                  |
| Maven         | https://dataflow.spring.io/Dearborn-SR1-task-applications-maven |
| Docker        | https://dataflow.spring.io/Dearborn-SR1-task-applications-docker |