---
title: Cloud Foundry Installation
navTitle: Cloud Foundry CLI
category: Spring Cloud Data Flow
order: 8
permalink: /Spring%20Cloud%20Data%20Flow/installation.cloudfoundry.cli/
description: CLI를 이용해 클라우드 파운드리 환경에 Spring Cloud Data Flow 설치하기
image: ./../../images/springclouddataflow/logo.png
lastmod: 2021-12-02T00:33:00+09:00
comments: true
originalRefName: 스프링 클라우드 데이터 플로우
originalRefLink: https://dataflow.spring.io/docs/installation/cloudfoundry/cf-cli/
parent: Installation
parentUrl: /Spring%20Cloud%20Data%20Flow/installation/
subparent: Cloud Foundry
subparentUrl: /Spring%20Cloud%20Data%20Flow/installation.cloudfoundry/
---

---

이 섹션에선 클라우드 파운드리 환경에 Spring Cloud Data Flow를 설치하는 방법을 설명한다.

### 목차

- [Backing Services](#backing-services)
  + [Provisioning a Rabbit Service Instance](#provisioning-a-rabbit-service-instance)
  + [Provisioning a PostgreSQL Service Instance](#provisioning-a-postgresql-service-instance)
- [Manifest based installation on Cloud Foundry](#manifest-based-installation-on-cloud-foundry)
  + [General Configuration](#general-configuration)
    * [Unique names](#unique-names)
    * [Memory Settings](#memory-settings)
    * [Routing](#routing)
    * [Maven repositories](#maven-repositories)
  + [Installing using a Manifest](#installing-using-a-manifest)
    * [Configuration for Prometheus](#configuration-for-prometheus)
    * [Configuration for Wavefront](#configuration-for-wavefront)
    * [Configuration for InfluxDB](#configuration-for-influxdb)
- [Shell](#shell)
  + [Register prebuilt applications](#register-prebuilt-applications)

---

## Backing Services

Spring Cloud Data Flow가 스트리밍과 태스크/배치를 처리하려면 몇 가지 데이터 서비스가 필요하다. 클라우드 파운드리에서 Spring Cloud Data Flow와 관련 서비스들을 프로비저닝할 땐 두 가지 옵션이 있다:

- 가장 간단한 (자동화된) 방법은 [Spring Cloud Data Flow 전용 PCF 타일<sup>tile</sup>](https://network.pivotal.io/products/p-dataflow)을 사용하는 거다. 이는 Pivotal Cloud Foundry의 전용 타일이다. 이렇게 하면 서버와 필요한 데이터 서비스들을 자동으로 프로비저닝해서 전반적인 시작 경험을 단순화할 수 있다. 이 방법대로 설치하는 자세한 방법은 [여기](https://docs.pivotal.io/scdf/)를 참고해라.
- 다른 방법으로는 모든 컴포넌트들을 수동으로 프로비저닝할 수도 있다.

이어지는 섹션에선 수동으로 설치하는 방법을 상세히 설명한다.

### Provisioning a Rabbit Service Instance

RabbitMQ는 스트리밍 앱 간의 메세징 미들웨어로 사용되며, PCF 타일로 제공된다.

클라우드 파운드리 세부 세팅에 따라 사용할 수 있는 플랜을 알아보려면 `cf marketplace`를 사용하면 된다. 예를 들어 다음과같이 [Pivotal Web Services](https://run.pivotal.io/)를 사용할 수 있다:

```bash
cf create-service cloudamqp lemur rabbit
```

### Provisioning a PostgreSQL Service Instance

RDBMS는 스트림과 태스크 정의, 배포, 실행과 같은 Data Flow 상태를 저장하는 데 사용한다.

클라우드 파운드리 세부 세팅에 따라 사용할 수 있는 플랜을 알아보려면 `cf marketplace`를 사용하면 된다. 예를 들어 다음과같이 [Pivotal Web Services](https://run.pivotal.io/)를 사용할 수 있다:

```bash
cf create-service elephantsql panda my_postgres
```

> **Database Connection Limits**
>
> SCDF에서 배치 job들을 만들어 태스크 파이프라인으로 실행하고자 한다면, 내부에서 사용하는 데이터베이스 인스턴스가 충분한 커넥션 캐파를 가지고 있어야만 배치 job과 태스크, SCDF가 커넥션 제한에 걸리지 않고 같은 데이터베이스 인스턴스에 동시에 연결할 수 있다. 일반적으론 무료 플랜은 사용할 수 없다는 걸 뜻한다.

---

## Manifest based installation on Cloud Foundry

클라우드 파운드리로 설치하려면:

1. Data Flow 서버와 쉘 애플리케이션을 다운로드해라:

   ```bash
   wget https://repo.spring.io/release/org/springframework/cloud/spring-cloud-dataflow-server/2.9.1/spring-cloud-dataflow-server-2.9.1.jar
   wget https://repo.spring.io/release/org/springframework/cloud/spring-cloud-dataflow-shell/2.9.1/spring-cloud-dataflow-shell-2.9.1.jar
   ```

2. Data Flow가 배포, 업그레이드, 롤백과 같은 스트림 라이프사이클 작업을 위임하는 [Skipper](https://cloud.spring.io/spring-cloud-skipper/)를 다운받아라:

   ```bash
   wget https://repo.spring.io/release/org/springframework/cloud/spring-cloud-skipper-server/2.8.1/spring-cloud-skipper-server-2.8.1.jar
   ```

3. 클라우드 파운드리로 Skipper를 푸시해라.

   클라우드 파운드리를 설치했다면 Skipper를 클라우드 파운드리로 푸시할 수 있다. 그러려면 Skipper에 대한 매니페스트를 만들어야 한다.

   아래와 같이 `Skipper Server` 설정에서 "디폴트" 배포 플랫폼 `deployment.services` 설정을 사용하면, Skipper가 RabbitMQ 서비스를 배포된 모든 스트리밍 애플리케이션에 바인딩하도록 구성할 수 있다. 여기서 `rabbitmq`는 서비스 인스턴스의 이름이다.

   다음은 전형적인 Skipper의 매니페스트 예시다:

   ```yml
   ---
   applications:
     - name: skipper-server
       host: skipper-server
       memory: 1G
       disk_quota: 1G
       instances: 1
       timeout: 180
       buildpack: java_buildpack
       path: <PATH TO THE DOWNLOADED SKIPPER SERVER UBER-JAR>
       env:
         SPRING_APPLICATION_NAME: skipper-server
         SPRING_PROFILES_ACTIVE: cloud
         JBP_CONFIG_SPRING_AUTO_RECONFIGURATION: '{enabled: false}'
         SPRING_APPLICATION_JSON: |-
           {
             "spring.cloud.skipper.server" : {
                "platform.cloudfoundry.accounts":  {
                      "default": {
                          "connection" : {
                              "url" : <cf-api-url>,
                              "domain" : <cf-apps-domain>,
                              "org" : <org>,
                              "space" : <space>,
                              "username": <email>,
                              "password" : <password>,
                              "skipSsValidation" : false
                          },
                          "deployment" : {
                              "deleteRoutes" : false,
                              "services" : "rabbitmq",
                              "enableRandomAppNamePrefix" : false,
                              "memory" : 2048
                          }
                     }
                 }
              }
           }
   services:
     - <services>
   ```

   이 명령어들을 실행하기 전에 먼저 `<org>`, `<space>`, `<email>`, `<password>`, `<serviceName>`(RabbitMQ 또는 Apache Kafka)과 `<services>`(ex. PostgresSQL)를 채워 넣어야 한다. `manifest.yml`에 알맞은 설정 값을 채웠다면, `cf push` 명령어를 통해 이 skipper-server를 프로비저닝할 수 있다.

   <blockquote style="background-color: #fbebf3; border-color: #d63583;">
    <p>SSL Validation</p>
    <p>클라우드 파운드리 인스턴스에서 자체 서명<sup>self-signed</sup> 인증서를 사용해서 (아직 개발 중일 때 등) 실행시킬 때에만 <em>Skip SSL Validation</em>을 <code class="highlighter-rouge">true</code>로 설정해라. 프로덕션에선 자체 서명 인증서를 사용하면 안 된다.</p>
   </blockquote>


   > Buildpacks
   >
   > 여기서 보여주는 예시들에서 `buildpack`을 지정할 땐 보통 `java_buildpack`이나 `java_buildpack_offline`을 지정한다. CF 명령어 `cf buildpacks`를 사용하면 해당 환경에서 사용 가능한 관련 빌드팩들을 조회할 수 있다.

4. Data Flow 서버를 설정하고 실행해라.

세부 설정 정보 중 가장 중요한 것 중 하나는 서버가 애플리케이션을 생성할 수 있도록 클라우드 파운드리 인스턴스에 credential을 제공하는 거다. 이땐 스프링 부트 호환 설정 메커니즘이라면 모두 사용할 수 있지만 (프로그램 인자 전달, 애플리케이션 빌드 전 설정 파일 편집, [Spring Cloud Config](https://github.com/spring-cloud/spring-cloud-config) 활용, 환경 변수 설정 등), 클라우드 파운드리에 애플리케이션을 배포할 때 자주 쓰는 방법에 따라 그중에서도 좀더 실용적인 방법이 있기도 하다.

설치하기 전에 앞서 필요에 따라 매니페스트 파일을 업데이트할 수 있으려면 전반적인 세부 설정 정보는 어느정도 알고 있어야 한다.

### General Configuration

이 섹션은 클라우드 파운드리에 설치할 때 알아둬야 하는 사항들을 몇 가지 설명한다.

#### Unique names

애플리케이션에 고유한 이름을 사용해야 한다. 같은 organization에서 이름이 같은 애플리케이션을 배포하면 실패한다.

#### Memory Settings

서버에 권장하는 최소 메모리 설정은 2G다. 게다가 앱을 PCF에 푸시하고 애플리케이션 프로퍼티 메타데이터를 얻기 위해 서버는 로컬 디스크에서 호스팅하는 메이븐 레포지토리에 애플리케이션을 다운로드한다. PCF 설치에선 디스크 공간에 사용할 기본 최대값을 2G까지 지정할 수 있지만, 이 값은 10G까지 늘릴 수 있다. 이 PCF 프로퍼티를 설정하는 방법은 [최대 디스크 할당량](https://bosh.io/jobs/cloud_controller_ng?source=github.com/cloudfoundry/capi-release#p%3dcc.maximum_app_disk_in_mb)에 대해 읽어보면 된다. 추가로, Data Flow 서버 자체는 디스크 공간이 low-water-mark 값 아래로 떨어지면 디스크 공간을 비우도록 Last-Recently-Used 알고리즘을 구현하고 있다.

#### Routing

푸시하려는 공간에 사용자가 여럿 있다면 (ex. PWS에서) 해당 애플리케이션 이름에 쓰려고 한 라우트를 이미 사용했을 수도 있다. `--random-route` 옵션을 사용해 서버 애플리케이션을 푸시하면 충돌을 방지할 수 있다.

#### Maven repositories

메이븐 레포지토리를 여러 개 설정하거나, 프록시나 private 레포지토리 권한<sup>authorization</sup>을 설정해야 할 때는 [메이븐 설정](https://docs.spring.io/spring-cloud-dataflow/docs/current/reference/htmlsingle/#configuration-maven)을 참고해라.

### Installing using a Manifest

환경 변수는 `cf set-env` 명령어로 설정할 수도 있지만, `manifest.yml` 파일에서 모든 관련 환경 변수를 관리하고 `cf push` 명령어를 통해 서버를 프로비저닝할 수도 있다.

다음은 그렇게 설정한 매니페스트 파일 예시다. 이때 `postgresSQL`은 데이터베이스 서비스 인스턴스 이름이다:

```yml
---
applications:
  - name: data-flow-server
    host: data-flow-server
    memory: 2G
    disk_quota: 2G
    instances: 1
    path: { PATH TO SERVER UBER-JAR }
    env:
      SPRING_APPLICATION_NAME: data-flow-server
      SPRING_PROFILES_ACTIVE: cloud
      JBP_CONFIG_SPRING_AUTO_RECONFIGURATION: '{enabled: false}'
      SPRING_CLOUD_SKIPPER_CLIENT_SERVER_URI: https://<skipper-host-name>/api
      SPRING_APPLICATION_JSON: |-
        {
           "maven" : {
               "remoteRepositories" : {
                  "repo1" : {
                    "url" : "https://repo.spring.io/libs-snapshot"
                  }
               }
           },
           "spring.cloud.dataflow" : {
                "task.platform.cloudfoundry.accounts" : {
                    "default" : {
                        "connection" : {
                            "url" : <cf-api-url>,
                            "domain" : <cf-apps-domain>,
                            "org" : <org>,
                            "space" : <space>,
                            "username" : <email>,
                            "password" : <password>,
                            "skipSsValidation" : true
                        },
                        "deployment" : {
                          "services" : "postgresSQL",
                          "scheduler-url" : "<scheduler_url>"
                        },
                    }
                }
           }
        }
services:
  - postgresSQL
```

> Skipper 서버가 실행되는 URI 위치를 설정하려면 먼저 Skipper를 배포해야 한다.

#### Configuration for Prometheus

프로메테우스와 그라파나를 클라우드 파운드리나 다른 클러스터에 별도로 설치했다면, Data Flow 서버의 매니페스트 파일에 있는 환경 변수 `SPRING_APPLICATION_JSON`에, 프로메테우스 RSocket 게이트웨이에 메트릭 데이터를 전송할 모든 서버와 스트림/태스크 애플리케이션을 구성하는 섹션을 추가해라. 다음은 이 설정과 관련된 YAML 스니펫 예시다:

```yml
---
applications:
  - name: data-flow-server
    ...
    env:
      ...
      SPRING_APPLICATION_JSON: |-
        {
           ...
           "management.metrics.export.prometheus": {
              "enabled" : true,
              "rsocket.enabled" : true,
              "rsocket.host" : <prometheus-rsocket-proxy host>,
              "rsocket.port" : <prometheus-rsocket-proxy TCP or Websocket port>
           },
           "spring.cloud.dataflow.metrics.dashboard" : {
              "url": <grafana root URL>
           }
        }
services:
  - postgresSQL
```

#### Configuration for Wavefront

Wavefront SaaS 계정이 있다면 태스크/스트림 메트릭을 활성화할 수 있다. 그러려면 환경 변수 `SPRING_APPLICATION_JSON`에 아래 JSON을 추가하는 식으로 Data Flow 서버 매니페스트를 확장해야 한다:

```yaml
        "management.metrics.export.wavefront": {
                "enabled": true,
                "api-token": "<YOUR API Token>",
                "uri": "<YOUR WAVEFRONT URI>",
                "source": "your-scdf-cf-source-id"
        }
```

`management.metrics.export.wavefront.XXX` 프로퍼티를 통해 지원하는 Wavefront 관련 옵션에 관한 자세한 내용은 [Wavefront 액추에이터](../../Spring%20Boot/metrics#wavefront) 엔드포인트를 확인해봐라.

매니페스트 파일에서 사용할 관련 프로퍼티가 준비되면 이 파일이 저장된 디렉토리에서 `cf push` 명령어를 실행하면 된다.

#### Configuration for InfluxDB

InfluxDB와 그라파나를 클라우드 파운드리나 다른 클러스터에 별도로 설치했다면, 태스크/스트림 메트릭 통합을 활성화하려면 환경 변수 `SPRING_APPLICATION_JSON`에 아래 JSON을 추가하는 식으로 Data Flow 서버 매니페스트를 확장해야 한다:

```json
    "management.metrics.export.influx": {
        "enabled": true,
        "db": "defaultdb",
        "autoCreateDb": false,
        "uri": "https://influx-uri:port",
        "userName": "guest",
        "password": "******"
    },
    "spring.cloud.dataflow.metrics.dashboard.url": "https://grafana-uri:port"
```

`management.metrics.export.influx.XXX` 프로퍼티에 관한 자세한 내용은 [Influx 액추에이터 프로퍼티](https://docs.spring.io/spring-boot/docs/2.2.0.M4/reference/html/#actuator-properties)를 확인해봐라.

매니페스트 파일에서 사용할 관련 프로퍼티가 준비되면 이 파일이 저장된 디렉토리에서 `cf push` 명령어를 실행하면 된다.

---

## Shell

다음은 Data Flow 쉘을 시작하는 방법을 보여주는 예시다:

```bash
java -jar spring-cloud-dataflow-shell-{scdf-core-version}.jar
```

Data Flow 서버와 쉘이 동일한 호스트에서 실행되지 않으므로, 쉘에서 `dataflow config server` 명령어를 사용해서 쉘이 Data Flow 서버 URL을 가리키도록 만들어주면 된다:

```bash
server-unknown:>dataflow config server https://<data-flow-server-route-in-cf>
Successfully targeted https://<data-flow-server-route-in-cf>
```

### Register prebuilt applications

미리 빌드해서 제공하는 스트리밍 애플리케이션들은 모두:

- 아파치 메이븐 아티팩트 또는 도커 이미지로 사용할 수 있다.
- RabbitMQ나 아파치 카프카를 사용한다.
- 프로메테우스와 InfluxDB를 이용한 모니터링을 지원한다.
- UI와 쉘의 코드 자동 완성에 사용되는 애플리케이션 프로퍼티 메타데이터를 가지고 있다.

애플리케이션들은 `app register` 기능을 통해 개별적으로 등록하거나 `app import` 기능을 통해 그룹으로 등록할 수 있다. 특정 릴리즈에 대해 사전에 빌드된 애플리케이션들의 그룹을 나타내는 `dataflow.spring.io` 링크도 준비되어 있어 처음 시작할 때 활용하기 좋다.

애플리케이션은 UI나 쉘로 등록할 수 있다.

클라우드 파운드리 설치 가이드는 RabbitMQ를 메세징 미들웨어로 사용하므로, RabbitMQ를 사용하는 애플리케이션을 등록해야 한다:

```bash
dataflow:>app import --uri https://dataflow.spring.io/rabbitmq-maven-latest
```