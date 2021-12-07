---
title: Connect to External Kafka Cluster
navTitle: External Kafka Cluster
category: Spring Cloud Data Flow
order: 90
permalink: /Spring%20Cloud%20Data%20Flow/recipes.kafka.ext-kafka-cluster-cf/
description: 클라우드 파운드리에 애플리케이션을 배포할 때 외부 카프카 설정을 전달하는 방법
image: ./../../images/springclouddataflow/logo.png
lastmod: 2021-12-08T01:00:00+09:00
comments: true
originalRefName: 스프링 클라우드 데이터 플로우
originalRefLink: https://dataflow.spring.io/docs/recipes/kafka/ext-kafka-cluster-cf/
parent: Recipes
parentUrl: /Spring%20Cloud%20Data%20Flow/recipes/
subparent: Apache Kafka
subparentUrl: /Spring%20Cloud%20Data%20Flow/recipes.kafka/
---

---

Pivotal Cloud Foundry에선 아파치 카프카를 마켓플레이스에서 관리하는 서비스로 지원하지 않는다. 하지만 개발자가 외부 카프카 클러스터와 상호 작용하는 애플리케이션을 개발하고 클라우드 파운드리에 배포하는 일은 매우 흔하다. 이 레시피에선 Spring Cloud Stream, Spring Cloud Data Flow, [PCF 전용 Spring Cloud Data Flow](https://network.pivotal.io/products/p-dataflow) 타일<sup>Tile</sup>에서 각각 외부 카프카 클러스터에 연결할 수 있는 방법을 구체적으로 알아본다.

여기서는 클라우드 파운드리에 애플리케이션을 다음과 같이 배포할 때 필요한 Spring Cloud Stream 프로퍼티들과, 이런 프로퍼티들이 애플리케이션으로 어떻게 전달되는지 리뷰한다.

- 독립형 앱 인스턴스로 실행되는 애플리케이션들.
- 오픈 소스 SCDF를 통해 스트리밍 데이터 파이프라인으로 배포한 애플리케이션들.
- [PCF 전용 SCDF](https://network.pivotal.io/products/p-dataflow) 타일<sup>Tile</sup>을 통해 스트리밍 데이터 파이프라인으로 배포한 애플리케이션들.

### 목차

- [Prerequisite](#prerequisite)
- [User-provided Services versus Spring Boot Properties](#user-provided-services-versus-spring-boot-properties)
- [Standalone Streaming Apps](#standalone-streaming-apps)
- [Streaming Data Pipeline in SCDF (Open Source)](#streaming-data-pipeline-in-scdf-open-source)
  + [Global Kafka Connection Configurations](#global-kafka-connection-configurations)
  + [Explicit Stream-level Kafka Connection Configuration](#explicit-stream-level-kafka-connection-configuration)
- [Streaming Data Pipeline in SCDF for PCF Tile](#streaming-data-pipeline-in-scdf-for-pcf-tile)

---

## Prerequisite

먼저 외부 카프카 클러스터의 credential을 준비하는 것부터 시작한다.

일련의 카프카 브로커들을 총칭할 땐 보통 카프카 클러스터라고 한다. 각 브로커들은 외부 IP 주소나 명확한 DNS 라우트(만들어뒀다면)를 통해 서로 접근할 수 있다.

여기에선 DNS 주소로 `foo0.broker.foo`, `foo1.broker.foo`, `foo2.broker.foo`를 사용하는 브로커 3개를 가진 간단한 클러스터 설정만 이용해 실습해본다. 각 브로커의 디폴트 포트는 `9092`이다.

클러스터를 보호하고 있다면 브로커에 적용한 보안 옵션에 따라, 애플리케이션은 다른 프로퍼티를 사용해 외부 클러스터에 연결을 시도한다. 여기서도 간단히 카프카의 `PlainLoginModule`의 [JAAS](https://en.wikipedia.org/wiki/Java_Authentication_and_Authorization_Service) 설정을 이용해 username `test`, password `besttest`로 연결한다.

---

## User-provided Services versus Spring Boot Properties

클라우드 파운드리 개발자가 그 다음으로 마주하는 고민은 카프카 커넥션을 클라우드 파운드리 CUPS<sup>custom user-provided service</sup>로 설정할지, 아니면 단순히 커넥션 credential을 스프링 부트 프로퍼티로 전달할지다.

클라우드 파운드리는 카프카를 위한 [Spring Cloud Connector](https://github.com/spring-cloud/spring-cloud-connectors)나 [CF-JavaEnv](https://github.com/pivotal-cf/java-cfenv)를 지원하지 않으므로, 카프카 CUPS를 애플리케이션과 서비스 바인딩시키는 식으로는 런타임에 자동으로 `VCAP_SERVICES`를 파싱하고 커넥션 credential을 애플리케이션에 전달할 수 *없다*. CUPS를 세팅했라도, `VCAP_SERVICES` JSON을 파싱해서 부트 프로퍼티로 전달하는 건 사용자의 몫이며, 카프카가 자동으로 설정되진 않는다. 궁금하다면 Spring Cloud Data Flow의 [레퍼런스 가이드](https://docs.spring.io/spring-cloud-dataflow/docs/current/reference/htmlsingle/#configuration-cloudfoundry-ups)에 있는 CUPS 사용 예시를 확인해보면 된다.

이번 실습에선 계속 스프링 부트 프로퍼티를 사용한다.

---

## Standalone Streaming Apps

일반적인 애플리케이션을 클라우드 파운드리에 배포할 땐 `manifest.yml` 파일을 사용한다. 소스 애플리케이션 `source-sample`의 전용 파일을 통해 외부 카프카 클러스터에 연결하는 데 필요한 설정을 알아보자:

```yaml
---
applications:
- name: source-sample
  host: source-sample
  memory: 1G
  disk_quota: 1G
  instances: 1
  path: source-sample.jar
env:
    ... # other application properties
    ... # other application properties
    SPRING_APPLICATION_JSON: |-
        {
            "spring.cloud.stream.kafka.binder": {
                "brokers": "foo0.broker.foo,foo1.broker.foo,foo2.broker.foo",
                "jaas.options": {
                    "username": "test",
                    "password":"bestest"
                },
                "jaas.loginModule":"org.apache.kafka.common.security.plain.PlainLoginModule"
            },
            "spring.cloud.stream.bindings.output.destination":"fooTopic"
        }
```

이 설정으로 `source-sample`을 클라우드 파운드리에 배포하면 외부 클러스터에 연결할 수 있을 거다.

`source-sample`의 액추에이터 엔드포인트 `/configprops`에 접근해보면 커넥션 credential을 검증해볼 수 있다. 앱 로그에 출력된 커넥션 credential을 확인해봐도 된다.

> 카프카 커넥션 credential은 Spring Cloud Stream 카프카 바인더 프로퍼티를 통해 제공하며, 여기서는 `spring.cloud.stream.kafka.binder.*` 프리픽스를 사용하는 모든 프로퍼티가 해당된다.
>
> 아니면 이런 프로퍼티들은 `SPRING_APPLICATION_JSON`을 통하는 대신, 일반 환경 변수로 제공해도 된다.

---

## Streaming Data Pipeline in SCDF (Open Source)

SCDF에 스트리밍 데이터 파이프라인을 배포하려면 애플리케이션이 최소 두 개 필요하다. 여기선 기본으로 제공하는 `time` 애플리케이션을 소스로, `log` 애플리케이션을 싱크로 사용한다.

### Global Kafka Connection Configurations

데모 시연으로 넘어가기 전에 먼저 SCDF를 중심으로 [글로벌 프로퍼티](https://docs.spring.io/spring-cloud-dataflow/docs/current/reference/htmlsingle/#spring-cloud-dataflow-global-properties)를 설정하는 방법을 리뷰한다. SCDF를 통해 배포하는 모든 스트림 애플리케이션은 전역으로 정의한 프로퍼티도 전부 자동으로 상속하며, 카프카 커넥션 credential을 설정할 때도 유연하게 활용할 수 있다. 다음은 글로벌 프로퍼티 예시다:

```yaml
---
applications:
  - name: scdf-server
    host: scdf-server
    memory: 2G
    disk_quota: 2G
    timeout: 180
    instances: 1
    path: spring-cloud-dataflow-server-2.9.1.jar
env:
  SPRING_PROFILES_ACTIVE: cloud
  JBP_CONFIG_SPRING_AUTO_RECONFIGURATION: '{enabled: false}'
  SPRING_CLOUD_SKIPPER_CLIENT_SERVER_URI: http://your-skipper-server-uri/api
  SPRING_APPLICATION_JSON: |-
    {
        "spring.cloud": {
            "dataflow.task.platform.cloudfoundry": {
                "accounts": {
                    "foo": {
                        "connection": {
                            "url": <api-url>,
                            "org": <org>,
                            "space": <space>,
                            "domain": <app-domain>,
                            "username": <email>,
                            "password": <password>,
                            "skipSslValidation": true
                        },
                        "deployment": {
                            "services": <comma delimited list of service>"
                        }
                    }
                }
            },
            "stream": {
                "kafka.binder": {
                    "brokers": "foo0.broker.foo,foo1.broker.foo,foo2.broker.foo",
                    "jaas": {
                        "options": {
                            "username": "test",
                            "password":"bestest"
                        },
                        "loginModule":"org.apache.kafka.common.security.plain.PlainLoginModule"
                    }
                },
                "bindings.output.destination":"fooTopic"
            }
        }
    }
services:
  - mysql
```

위 `manifest.yml` 파일을 덕분에 이제 SCDF는 스트림 애플리케이션을 배포할 때마다 자동으로 카프카 커넥션 credential을 전파해준다. 이제 스트림을 생성해보자:

```bash
dataflow:>stream create fooz --definition "time | log"
Created new stream 'fooz'

dataflow:>stream deploy --name fooz
Deployment request has been sent for stream 'fooz'
```

`time`, `log` 애플리케이션을 클라우드 파운드리에 정상적으로 배포하고 기동시키면, 설정해둔 외부 카프카 클러스터에 자동으로 연결될 거다.

`time`, `log`의 액츄에이터 엔드포인트 `/configprops`에 접근해보면 커넥션 credential을 검증해볼 수 있다. 앱 로그에 출력된 커넥션 credential을 확인해봐도 된다.

### Explicit Stream-level Kafka Connection Configuration

아니면 특정 스트림만 외부 카프카 커넥션 credential을 사용하도록 배포하고 싶다면, 스트림을 배포할 때 재정의할 프로퍼티를 명시해주면 된다:

```bash
dataflow:>stream create fooz --definition "time | log"
Created new stream 'fooz'

dataflow:>stream deploy --name fooz --properties "app.*.spring.cloud.stream.kafka.binder.brokers=foo0.broker.foo,foo1.broker.foo,foo2.broker.foo,app.*.spring.cloud.stream.kafka.binder.jaas.options.username=test,app.*.spring.cloud.stream.kafka.binder.jaas.options.password=besttest,app.*.spring.cloud.stream.kafka.binder.jaas.loginModule=org.apache.kafka.common.security.plain.PlainLoginModule"
Deployment request has been sent for stream 'fooz'
```

`time`, `log` 애플리케이션을 클라우드 파운드리에 정상적으로 배포하고 기동시키면, 외부 카프카 클러스터에 자동으로 연결될 거다.

`time`, `log`의 액츄에이터 엔드포인트 `/configprops`에 접근해보면 커넥션 credential을 검증해볼 수 있다. 앱 로그에 출력된 커넥션 credential을 확인해봐도 된다.

---

## Streaming Data Pipeline in SCDF for PCF Tile

[Explicit Stream Configuration](#explicit-stream-level-kafka-connection-configuration) 섹션에서 설명한 배포 옵션은 Spring Cloud Data Flow를 Pivotal Cloud Foundry에서 관리하는 서비스로 실행했을 때도 여전히 동작할 거다.

아니면 PCF 타일<sup>Tile</sup> SCDF의 서비스 인스턴스를 생성할 때 CUPS 프로퍼티로 카프카 커넥션 credential을 제공할 수도 있다:

```bash
cf create-service p-dataflow standard data-flow -c '{"messaging-data-service": { "user-provided": {"brokers":"foo0.broker.foo,foo1.broker.foo,foo2.broker.foo","username":"test","password":"bestest"}}}'
```

이때는 `VCAP_SERVICES`로 감싸져있는 CUPS 프로퍼티를 제공해서 스트림을 배포한다.

```bash
dataflow:>stream create fooz --definition "time | log"
Created new stream 'fooz'

dataflow:>stream deploy --name fooz --properties "app.*.spring.cloud.stream.kafka.binder.brokers=${vcap.services.messaging-<GENERATED_GUID>.credentials.brokers},app.*.spring.cloud.stream.kafka.binder.jaas.options.username=${vcap.services.messaging-<GENERATED_GUID>.credentials.username},app.*.spring.cloud.stream.kafka.binder.jaas.options.password=${vcap.services.messaging-<GENERATED_GUID>.credentials.password},app.*.spring.cloud.stream.kafka.binder.jaas.loginModule=org.apache.kafka.common.security.plain.PlainLoginModule"
Deployment request has been sent for stream 'fooz'
```

`<GENERATED_GUID>`는 생성한 메세징 서비스 인스턴스 이름의 GUID로 변경해라 (ex. `messaging-b3e76c87-c5ae-47e4-a83c-5fabf2fc4f11`). 이 값은  `cf services` 명령어로 찾을 수 있다.

또 다른 방법으로는, SCDF 서비스 앱 인스턴스를 통해 글로벌 설정 프로퍼티를 제공할 수도 있다. SCDF 서비스 인스턴스를 준비했다면 다음과 같이 진행하면 된다.

1. 앱 매니저의 SCDF 서버 앱 인스턴스 UI에서 설정으로 이동한다.

2. “User Provided Environment Variables”에서 SPRING*CLOUD*DATAFLOW*TILE*CONFIGURATION을 선택한다.

3. 다음과 같은 프로퍼티를 입력한다:

   ```json
   {"spring.cloud.dataflow.applicationProperties.stream.spring.cloud.stream.kafka.binder.brokers": <foo0.broker.foo>, "spring.cloud.dataflow.applicationProperties.stream.spring.cloud.stream.kafka.binder.jaas.loginModule": "org.apache.kafka.common.security.plain.PlainLoginModule", "spring.cloud.dataflow.applicationProperties.stream.spring.cloud.stream.kafka.binder.jaas.options.username": "test", "spring.cloud.dataflow.applicationProperties.stream.spring.cloud.stream.kafka.binder.jaas.options.password": "password", "spring.cloud.dataflow.applicationProperties.stream.spring.cloud.stream.kafka.binder.configuration.security.protocol": "SASL_PLAINTEXT", "spring.cloud.dataflow.applicationProperties.stream.spring.cloud.stream.kafka.binder.configuration.sasl.mechanism": "PLAIN" }
   ```

4. 변경 사항을 반영하고 나면, 업데이트 버튼을 클릭하고 CF에 있는 dataflow 서버 애플리케이션을 재시작해야 한다.

> 위 설정에 있는 값들(3번 스텝)은 단순히 예시로 보여주는 값이다. 각자의 환경에 맞는 값으로 수정해야 한다. 이 설정들은 SASL PLAINTEXT로 보호하는 카프카 클러스터를 위한 설정이다.