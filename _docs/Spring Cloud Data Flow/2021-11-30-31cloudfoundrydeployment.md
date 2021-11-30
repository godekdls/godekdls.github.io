---
title: Cloud Foundry Deployment
category: Spring Cloud Data Flow
order: 31
permalink: /Spring%20Cloud%20Data%20Flow/stream-developer-guides.stream-development.stream-application-deployment.cloud-foundry/
description: 샘플 스트림 애플리케이션을 클라우드 파운드리 환경에 수동으로 배포하기
image: ./../../images/springclouddataflow/logo.png
lastmod: 2021-12-02T00:33:00+09:00
comments: true
originalRefName: 스프링 클라우드 데이터 플로우
originalRefLink: https://dataflow.spring.io/docs/stream-developer-guides/streams/deployment/cloudfoundry/
parent: Stream Developer guides
parentUrl: /Spring%20Cloud%20Data%20Flow/stream-developer-guides/
subparent: Stream Development
subparentUrl: /Spring%20Cloud%20Data%20Flow/stream-developer-guides.stream-development/
navDisplay: false
---

---

[샘플 스트림 애플리케이션들](../stream-developer-guides.stream-development.stream-application-development)을 설정해 빌드하고, 지원하는 메세지 브로커 중에 하나를 골라 함께 실행되도록 설정을 완료했다면, 이 애플리케이션들은 클라우드 파운드리 환경에서 독립형으로 실행할 수 있다.

이번 섹션에선 이 세 가지 Spring Cloud Stream 애플리케이션을 클라우드 파운드리 환경에 배포하는 방법을 안내한다.

### 목차

- [Deploy with Apache Kafka](#deploy-with-apache-kafka)
  + [Create deployment manifests](#create-deployment-manifests)
- [Deploy with RabbitMQ](#deploy-with-rabbitmq)
  + [Create a RabbitMQ service](#create-a-rabbitmq-service)
  + [Create deployment manifests](#create-deployment-manifests-1)
- [Clean Up](#clean-up)

---

## Deploy with Apache Kafka

이 글을 쓰는 시점에는, 카프카는 반드시 클라우드 파운드리 환경에 액세스할 수 있는 외부 서비스로 관리해야 한다.

### Create deployment manifests

각 애플리케이션마다 외부 카프카 브로커에 연결하도록 설정하는 CF 매니페스트를 생성해라.

`UsageDetailSender`는 `usage-detail-sender.yml`이란 CF 매니페스트 YAML 파일을 생성한다:

```yaml
applications:
- name: usage-detail-sender
  timeout: 120
  path: ./target/usage-detail-sender-0.0.1-SNAPSHOT.jar
  memory: 1G
  buildpack: java_buildpack
  env:
    SPRING_CLOUD_STREAM_KAFKA_BINDER_BROKERS: [Kafka_Service_IP_Address:Kafka_Service_Port]
    SPRING_CLOUD_STREAM_KAFKA_BINDER_ZKNODES: [ZooKeeper_Service_IP_Address:ZooKeeper_Service_Port]
```

`UsageCostProcessor`는 `usage-cost-processor.yml`이란 CF 매니페스트 YAML 파일을 생성한다:

```yaml
applications:
- name: usage-cost-processor
  timeout: 120
  path: ./target/usage-cost-processor-0.0.1-SNAPSHOT.jar
  memory: 1G
  buildpack: java_buildpack
  env:
    SPRING_CLOUD_STREAM_KAFKA_BINDER_BROKERS: [Kafka_Service_IP_Address:Kafka_Service_Port]
    SPRING_CLOUD_STREAM_KAFKA_BINDER_ZKNODES: [ZooKeeper_Service_IP_Address:ZooKeeper_Service_Port]
```

`UsageCostLogger`는 `usage-cost-logger.yml`이란 CF 매니페스트 YAML 파일을 생성한다:

```yaml
applications:
- name: usage-cost-logger
  timeout: 120
  path: ./target/usage-cost-logger-0.0.1-SNAPSHOT.jar
  memory: 1G
  buildpack: java_buildpack
  env:
    SPRING_CLOUD_STREAM_KAFKA_BINDER_BROKERS: [Kafka_Service_IP_Address:Kafka_Service_Port]
    SPRING_CLOUD_STREAM_KAFKA_BINDER_ZKNODES: [ZooKeeper_Service_IP_Address:ZooKeeper_Service_Port]
```

---

## Deploy with RabbitMQ

### Create a RabbitMQ service

CF 마켓 플레이스에서 사용 가능한 RabbitMQ 서비스 플랜 중 하나로 `rabbitmq`라는 RabbitMQ 서비스 인스턴스를 생성해라. 예를 들어 서비스 플랜 `p.rabbitmq` `single-node`의 경우 아래 명령어를 사용한다:

```bash
cf create-service p.rabbitmq single-node rabbitmq
```

### Create deployment manifests

각 애플리케이션마다 이 `rabbitmq` 서비스에 바인딩하도록 설정하는 CF 매니페스트를 생성해라.

`UsageDetailSender`는 `usage-detail-sender.yml`이란 CF 매니페스트 YAML 파일을 생성한다:

```yaml
applications:
- name: usage-detail-sender
  timeout: 120
  path: ./target/usage-detail-sender-rabbit-0.0.1-SNAPSHOT.jar
  memory: 1G
  buildpack: java_buildpack
  services:
    - rabbitmq
```

`UsageCostProcessor`는 `usage-cost-processor.yml`이란 CF 매니페스트 YAML 파일을 생성한다:

```yaml
applications:
- name: usage-cost-processor
  timeout: 120
  path: ./target/usage-cost-processor-0.0.1-SNAPSHOT.jar
  memory: 1G
  buildpack: java_buildpack
  services:
    - rabbitmq
```

`usage-cost-logger.yml`이란 CF 매니페스트 YAML 파일을 생성한다:

```yaml
applications:
- name: usage-cost-logger
  timeout: 120
  path: ./target/usage-cost-logger-0.0.1-SNAPSHOT.jar
  memory: 1G
  buildpack: java_buildpack
  services:
    - rabbitmq
```

`UsageDetailSender` 애플리케이션을 해당 매니페스트를 사용해 푸시해라:

```sh
cf push -f usage-detail-sender.yml
```

`UsageCostProcessor` 애플리케이션을 해당 매니페스트를 사용해 푸시해라:

```sh
cf push -f usage-cost-processor.yml
```

`UsageCostLogger` 애플리케이션을 해당 매니페스트를 사용해 푸시해라:

```sh
cf push -f usage-cost-logger.yml
```

이 애플리케이션들은 아래 예시처럼 `cf apps` 명령어를 실행해 확인할 수 있다 (출력 문구도 같이 표기했다):

```sh
cf apps
```

```console
name                   requested state   instances   memory   disk   urls
usage-cost-logger      started           1/1         1G       1G     usage-cost-logger.cfapps.io
usage-cost-processor   started           1/1         1G       1G     usage-cost-processor.cfapps.io
usage-detail-sender    started           1/1         1G       1G     usage-detail-sender.cfapps.io
```

배포가 잘 되었는지 보려면 `usage-cost-logger` 애플리케이션 로그를 추적하면 된다.

```sh
cf logs usage-cost-logger
```

아래와 유사한 로그를 볼 수 있을 거다:

```bash
   2019-05-13T23:23:33.36+0530 [APP/PROC/WEB/0] OUT 2019-05-13 17:53:33.362  INFO 15 --- [e-cost.logger-1] i.s.d.s.u.UsageCostLogger     : {"userId": "user5", "callCost": "1.0", "dataCost": "12.350000000000001" }
   2019-05-13T23:23:33.46+0530 [APP/PROC/WEB/0] OUT 2019-05-13 17:53:33.467  INFO 15 --- [e-cost.logger-1] i.s.d.s.u.UsageCostLogger     : {"userId": "user1", "callCost": "19.0", "dataCost": "10.0" }
   2019-05-13T23:23:34.46+0530 [APP/PROC/WEB/0] OUT 2019-05-13 17:53:34.466  INFO 15 --- [e-cost.logger-1] i.s.d.s.u.UsageCostLogger     : {"userId": "user4", "callCost": "2.2", "dataCost": "5.15" }
   2019-05-13T23:23:35.46+0530 [APP/PROC/WEB/0] OUT 2019-05-13 17:53:35.469  INFO 15 --- [e-cost.logger-1] i.s.d.s.u.UsageCostLogger     : {"userId": "user3", "callCost": "21.0", "dataCost": "17.3" }
```

### Clean Up

애플리케이션 인스턴스들을 삭제하려면:

```bash
cf d -f usage-detail-sender
cf d -f usage-cost-processor
cf d -f usage-cost-logger
```

RabbitMQ를 사용한다면 서비스 인스턴스를 삭제해야할 수도 있다:

```sh
cf ds -f rabbitmq
```