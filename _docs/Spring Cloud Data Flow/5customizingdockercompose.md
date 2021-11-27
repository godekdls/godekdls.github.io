---
title: Customizing Docker Compose
navTitle: Docker Compose Customization
category: Spring Cloud Data Flow
order: 5
permalink: /Spring%20Cloud%20Data%20Flow/installation.local-machine.docker-customize/
description: docker compose 익스텐션 파일을 이용해 스프링 클라우드 데이터 플로우를 커스텀해서 설치하기
image: ./../../images/springclouddataflow/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 클라우드 데이터 플로우
originalRefLink: https://dataflow.spring.io/docs/installation/local/docker-customize/
parent: Installation
parentUrl: /Spring%20Cloud%20Data%20Flow/installation/
subparent: Local Machine
subparentUrl: /Spring%20Cloud%20Data%20Flow/installation.local-machine/
---
<script>defaultLanguages = ['linux-osx']</script>

---

Docker Compose [설치](../installation.local-machine.docker-compose) 가이드에선 [docker-compose.yml](https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow/v2.9.1/src/docker-compose/docker-compose.yml)을 이용해 `Data Flow`, `Skipper`, `Kafka`, `MySQL`을 설치하는 방법을 설명했다. 이 베이직 설정은 기본으로 제공하는 docker-compose 익스텐션 파일을 사용해 확장할 수 있다. 예를 들어 `RabbitMQ`나 `PostgreSQL`을 사용하고 싶거나 Data Flow `모니터링`을 활성화하고 싶다면, 원하는 docker-compose 익스텐션 파일과 결합하면 된다:

<div class="switch-language-wrapper linux-osx windows">
<span class="switch-language linux-osx">Linux / OSX</span>
<span class="switch-language windows">Windows</span>
</div>
<div class="language-only-for-linux-osx linux-osx windows"></div>
```sh
docker-compose -f ./docker-compose.yml \
               -f ./docker-compose-rabbitmq.yml \
               -f ./docker-compose-postgres.yml \
               -f ./docker-compose-influxdb.yml up
```
<div class="language-only-for-windows linux-osx windows"></div>
```sh
docker-compose -f .\docker-compose.yml -f .\docker-compose-rabbitmq.yml -f .\docker-compose-postgres.yml -f .\docker-compose-influxdb.yml up
```

이어지는 섹션에선 `docker-compose.yml` 위에 적용할 수 있는 기본 제공 중인 익스텐션 docker-compose 파일들을 자세히 설명한다. docker-compose 파일을 둘 이상 사용하면 정의된 순서대로 적용된다.

### 목차

- [Prometheus & Grafana](#prometheus--grafana)
- [InfluxDB & Grafana](#influxdb--grafana)
- [Wavefront](#wavefront)
- [Zipkin Server](#zipkin-server)
- [Postgres Instead of MySQL](#postgres-instead-of-mysql)
- [RabbitMQ Instead of Kafka](#rabbitmq-instead-of-kafka)
- [Debugging](#debugging)
  * [Debug Stream Applications](#debug-stream-applications)
  * [Debug Data Flow Server](#debug-data-flow-server)
  * [Debug Skipper Server](#debug-skipper-server)
- [Integration Testing](#integration-testing)
- [Multi-platform Support](#multi-platform-support)

---

## Prometheus & Grafana

[docker-compose-prometheus.yml](https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow/v2.9.1/src/docker-compose/docker-compose-prometheus.yml) 파일은 `docker-compose.yml`의 디폴트 설정을 확장해서 [프로메테우스와 그라파나를 통한 Steam/Task 모니터링](https://dataflow.spring.io/docs//feature-guides/streams/monitoring/#prometheus)을 활성화한다:

<div class="switch-language-wrapper linux-osx windows">
<span class="switch-language linux-osx">Linux / OSX</span>
<span class="switch-language windows">Windows</span>
</div>
<div class="language-only-for-linux-osx linux-osx windows"></div>
```sh
wget -O docker-compose-prometheus.yml https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow/v2.9.1/src/docker-compose/docker-compose-prometheus.yml
docker-compose -f ./docker-compose.yml -f ./docker-compose-prometheus.yml up
```
<div class="language-only-for-windows linux-osx windows"></div>
```sh
curl https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow/v2.9.1/src/docker-compose/docker-compose-prometheus.yml -o docker-compose-prometheus.yml
docker-compose -f .\docker-compose.yml -f .\docker-compose-prometheus.yml up
```

이 확장 설정은 기본 서비스 외에 서비스 디스커버리 위한 `Prometheus`와 `Prometheus-RSocket-Proxy`를 추가하고, 미리 만들어진 Stream, Task 대시보드를 가지고 있는 `Grafana`를 추가한다.

`docker-compose-prometheus.yml` 설정에선 아래에 있는 컨테이너 포트를 호스트 시스템에 노출한다:

| Host ports | Container ports | Description                                                  |
| ---------- | --------------- | ------------------------------------------------------------ |
| 9090       | 9090            | 프로메테우스 서버 포트. 이 포트를 통해 http://localhost:9090에 있는 프로메테우스 웹 콘솔에 접근한다. |
| 3000       | 3000            | 그라파나 서버 포트. 이 포트를 통해 http://localhost:3000에 있는 그라파나 대시보드에 접근한다. |
| 9096       | 9096            | 프로메테우스 RSocket 프록시 (스프링 부트) 서버 포트          |
| 7001       | 7001            | 프로메테우스 RSocket 프록시 TCP accept 포트.  Stream, Task 애플리케이션의 메트릭을 프록시로 리포트할 땐 이 포트를 사용하도록 설정할 수 있다. |
| 8086       | 8086            | 프로메테우스 RSocket 프록시 WebSocket 포트. Stream, Task 애플리케이션의 메트릭을 프록시로 리포트할 땐 이 포트를 사용하도록 설정할 수 있다. |

> `docker-compose-prometheus.yml` 파일에선 Docker 이미지(`springcloud/spring-cloud-dataflow-prometheus-local`, `springcloud/spring-cloud-dataflow-grafana-prometheus`)에 설정한 `DATAFLOW_VERSION` 값과 일치하는 태그가 존재한다고 가정한다.

---

## InfluxDB & Grafana

[docker-compose-influxdb.yml](https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow/v2.9.1/src/docker-compose/docker-compose-influxdb.yml) 파일은 `InfluxDB`와 `그라파나`를 통한 Steam /Task 모니터링을 활성화한다. 그라파나는 미리 만들어진 Stream, Task 대시보드를 가지고 있다:

<div class="switch-language-wrapper linux-osx windows">
<span class="switch-language linux-osx">Linux / OSX</span>
<span class="switch-language windows">Windows</span>
</div>
<div class="language-only-for-linux-osx linux-osx windows"></div>
```sh
wget -O docker-compose-influxdb.yml https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow/v2.9.1/src/docker-compose/docker-compose-influxdb.yml
docker-compose -f ./docker-compose.yml -f ./docker-compose-influxdb.yml up
```
<div class="language-only-for-windows linux-osx windows"></div>
```sh
curl https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow/v2.9.1/src/docker-compose/docker-compose-influxdb.yml -o docker-compose-influxdb.yml
docker-compose -f .\docker-compose.yml -f .\docker-compose-influxdb.yml up
```

`docker-compose-influxdb.yml` 설정에선 아래에 있는 컨테이너 포트를 호스트 시스템에 노출한다:

| Host ports | Container ports | Description                                                  |
| ---------- | --------------- | ------------------------------------------------------------ |
| 8086       | 8086            | Influx DB 서버 포트. Influx DB에 연결할 땐 http://localhost:8086을 사용해라. |
| 3000       | 3000            | 그라파나 서버 포트. 그라파나 대시보드 http://localhost:3000에 접근할 땐 이 포트를 사용해라. |

> `docker-compose-influxdb.yml` 파일에선 Docker 이미지(`springcloud/spring-cloud-dataflow-grafana-influxdb`)에 설정한 `DATAFLOW_VERSION` 값과 일치하는 태그가 존재한다고 가정한다.

---

## Wavefront

[docker-compose-wavefront.yml](https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow/v2.9.1/src/docker-compose/docker-compose-wavefront.yml) 파일은 `Wavefront`를 통한 Steam/Task 모니터링을 활성화하며, Stream, Task 대시보드가 미리 만들어져 있다.

[Wavefront](https://www.wavefront.com/)는 SaaS 기반 플랫폼으로, 먼저 [사용자 계정을 생성](https://www.wavefront.com/sign-up/)하고 이 계정을 사용해 밑에서 설명하는 대로 환경 변수 `WAVEFRONT_KEY`와 `WAVEFRONT_URI`를 설정해야 한다.

<div class="switch-language-wrapper linux-osx windows">
<span class="switch-language linux-osx">Linux / OSX</span>
<span class="switch-language windows">Windows</span>
</div>
<div class="language-only-for-linux-osx linux-osx windows"></div>
```sh
wget -O docker-compose-wavefront.yml https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow/v2.9.1/src/docker-compose/docker-compose-wavefront.yml
docker-compose -f ./docker-compose.yml -f ./docker-compose-wavefront.yml up
```
<div class="language-only-for-windows linux-osx windows"></div>
```sh
curl https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow/v2.9.1/src/docker-compose/docker-compose-wavefront.yml -o docker-compose-wavefront.yml
docker-compose -f .\docker-compose.yml -f .\docker-compose-wavefront.yml up
```

`docker-compose-wavefront.yml`을 설정할 땐 아래에 있는 환경 변수를 사용할 수 있다:

| Variable name      | Default value                | Description                                                  |
| ------------------ | ---------------------------- | ------------------------------------------------------------ |
| `WAVEFRONT_KEY`    | (required)                   | Wavefront user API 키                                        |
| `WAVEFRONT_URI`    | https://vmware.wavefront.com | Wavefront 엔트리 포인트 URI                                  |
| `WAVEFRONT_SOURCE` | scdf-docker-compose          | Data Flow 설치로 들어오는 메트릭을 식별하기 위한 Wavefront의 고유 식별자. |

> Wavefront의 Browse/Source메뉴를 통해 `WAVEFRONT_SOURCE` 소스로부터 들어오는 메트릭을 찾을 수 있다.

---

## Zipkin Server

[docker-compose-zipkin.yml](https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow/v2.9.1/src/docker-compose/docker-compose-zipkin.yml)을 사용하면 `Zipkin Server`로 분산된 스트림 trace를 수집하고 시각화할 수 있다. 배포된 스트리밍 애플리케이션에서 수집된 분산 trace를 확인하려면 http://localhost:9411/zipkin에 있는 Zipkin의 UI를 열면 된다.

모든 Spring Cloud [Stream 애플리케이션들](https://github.com/spring-cloud/stream-applications)은 `Spring Cloud Sleuth`로 미리 설정돼 있어 메세지 분산 트레이싱을 지원한다. 추적한 정보는 외부 시스템으로 전송되서 latency를 시각화한다. Spring Cloud Sleuth는 [Zipkin Server](https://github.com/openzipkin/zipkin/tree/master/zipkin-server)나 [Wavefront Distributed Tracing](https://docs.wavefront.com/tracing_basics.html)과 같은 OpenZipkin 호환 시스템을 지원한다.

Zipkin 분산 트레이싱은 기본적론 비활성화돼 있다. 기본 동작을 변경할 땐 [spring sleuth 프로퍼티](https://cloud.spring.io/spring-cloud-sleuth/reference/html/appendix.html)를 사용한다. 예를 들어 `docker-compose-zipkin.yaml`은 배포된 스트림 애플리케이션들을 위해 SCDF 공통 스트리밍 프로퍼티를 활용해 `spring.zipkin.enabled=true`와 `spring.zipkin.base-url=http://zipkin-server:9411`을 설정한다.

<div class="switch-language-wrapper linux-osx windows">
<span class="switch-language linux-osx">Linux / OSX</span>
<span class="switch-language windows">Windows</span>
</div>
<div class="language-only-for-linux-osx linux-osx windows"></div>
```sh
wget -O docker-compose-zipkin.yml https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow/v2.9.1/src/docker-compose/docker-compose-zipkin.yml
docker-compose -f ./docker-compose.yml -f ./docker-compose-zipkin.yml up
```
<div class="language-only-for-windows linux-osx windows"></div>
```sh
curl https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow/v2.9.1/src/docker-compose/docker-compose-zipkin.yml -o docker-compose-zipkin.yml
docker-compose -f .\docker-compose.yml -f .\docker-compose-zipkin.yml up
```

`docker-compose-zipkin.yml` 설정에선 아래에 있는 컨테이너 포트를 호스트 시스템에 노출한다:

| Host ports | Container ports | Description                                                  |
| ---------- | --------------- | ------------------------------------------------------------ |
| 9411       | 9411            | HTTP API와 웹 UI를 위한 Zipkin 서버 수신<sup>listen</sup> 포트 |

> http://localhost:9411/zipkin에 있는 `Zipkin UI`를 통해 배포돼 있는 스트리밍 애플리케이션들로부터 수집한 분산 트레이스 정보를 탐색할 수 있다.

---

## Postgres Instead of MySQL

[docker-compose-postgres.yml](https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow/v2.9.1/src/docker-compose/docker-compose-postgres.yml) 파일은 Spring Cloud Data Flow와 SKipper 모두 `MySQL` 대신 `PostgreSQL`을 사용하도록 설정한다. 기본 `mysql` 서비스를 비활성화하며, 새로운 `postgres` 서비스를 추가하고 이 `postgres` 서비스를 사용하도록 Data Flow와 Skipper 설정을 재정의한다:

<div class="switch-language-wrapper linux-osx windows">
<span class="switch-language linux-osx">Linux / OSX</span>
<span class="switch-language windows">Windows</span>
</div>
<div class="language-only-for-linux-osx linux-osx windows"></div>
```sh
wget -O docker-compose-postgres.yml https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow/v2.9.1/src/docker-compose/docker-compose-postgres.yml
docker-compose -f ./docker-compose.yml -f ./docker-compose-postgres.yml up
```
<div class="language-only-for-windows linux-osx windows"></div>
```sh
curl https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow/v2.9.1/src/docker-compose/docker-compose-postgres.yml -o docker-compose-postgres.yml
docker-compose -f .\docker-compose.yml -f .\docker-compose-postgres.yml up
```

`docker-compose-postgres.yml` 설정에선 아래에 있는 컨테이너 포트를 호스트 시스템에 노출한다:

| Host ports | Container ports | Description                                                  |
| ---------- | --------------- | ------------------------------------------------------------ |
| 5432       | 5432            | PostgreSql DB 서버 포트. 로컬 머신에서 DB에 연결할 땐 `jdbc:postgresql://localhost:5432/dataflow`를 사용해라. |

---

## RabbitMQ Instead of Kafka

[docker-compose-rabbitmq.yml](https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow/v2.9.1/src/docker-compose/docker-compose-rabbitmq.yml)은 (Kafka 대신) RabbitMQ를 메세지 브로커로 설정한다. 기본 `kafka`, `zookeeper` 서비스를 비활성화하며, 새로운 `rabbitmq` 서비스를 추가하고, `dataflow-server`의 서비스 바인더 설정을 RabbitMQ로 재정의한다 (ex. `spring.cloud.dataflow.applicationProperties.stream.spring.rabbitmq.host=rabbitmq`). 마지막으로, `app-import` 서비스를 재정의해 RabbitMQ 앱을 등록한다:



<div class="switch-language-wrapper linux-osx windows">
<span class="switch-language linux-osx">Linux / OSX</span>
<span class="switch-language windows">Windows</span>
</div>
<div class="language-only-for-linux-osx linux-osx windows"></div>
```sh
wget -O docker-compose-rabbitmq.yml https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow/v2.9.1/src/docker-compose/docker-compose-rabbitmq.yml
docker-compose -f ./docker-compose.yml -f ./docker-compose-rabbitmq.yml up
```
<div class="language-only-for-windows linux-osx windows"></div>
```sh
curl https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow/v2.9.1/src/docker-compose/docker-compose-rabbitmq.yml -o docker-compose-rabbitmq.yml
docker-compose -f .\docker-compose.yml -f .\docker-compose-rabbitmq.yml up
```

---

## Debugging

이어지는 섹션에선 DataFlow(또는 Skipper) 서버와, 해당 서버에서 배포한 Stream 애플리케이션들을 디버깅하는 법을 설명한다.

> 여기서 보여주는 디버그 설정으로 실행이 안 될 땐 `localhost` 이름이 아닌 로컬 머신의 `IP` 주소를 사용해라.

### Debug Stream Applications

스트림 애플리케이션을 디버깅하려면 스트림을 배포할 때 애플리케이션 배포 프로퍼티([deployer..local.debugPort](https://docs.spring.io/spring-cloud-dataflow/docs/current/reference/htmlsingle/#configuration-local-deployer))를 `20000 - 20105` 범위에 있는 값으로 설정해라. 배포 UI 패널에서 직접 수행해도 된다. 아래 예시에선 `debugPort`를 `20075`로 설정한다:

![scdf-set-app-debug-port](./../../images/springclouddataflow/scdf-set-app-debug-port.webp)

IDE에서 스트림 애플리케이션 프로젝트를 열어보자. 그다음 원격 디버그 설정을 위해 `Host:`를 로컬 IP 주소로 설정하고 `Port:`를 위의 배포 프로퍼티에서 사용한 값으로 세팅해라.

![scdf-remote-debugging-stream-apps](./../../images/springclouddataflow/scdf-remote-debugging-stream-apps.webp)

> 반드시 `localhost`가 아닌 IP 주소를 사용해야 한다.

### Debug Data Flow Server

[docker-compose-debug-dataflow.yml](https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow/v2.9.1/src/docker-compose/docker-compose-debug-dataflow.yml) 파일은 Data Flow 서버의 원격 디버깅을 활성화한다. 디버깅을 활성화하려면 다음 명령어를 실행하면 된다:

<div class="switch-language-wrapper linux-osx windows">
<span class="switch-language linux-osx">Linux / OSX</span>
<span class="switch-language windows">Windows</span>
</div>
<div class="language-only-for-linux-osx linux-osx windows"></div>
```sh
wget -O docker-compose-debug-dataflow.yml https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow/v2.9.1/src/docker-compose/docker-compose-debug-dataflow.yml
docker-compose -f ./docker-compose.yml -f ./docker-compose-debug-dataflow.yml up
```
<div class="language-only-for-windows linux-osx windows"></div>
```sh
curl https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow/v2.9.1/src/docker-compose/docker-compose-debug-dataflow.yml -o docker-compose-debug-dataflow.yml
docker-compose -f .\docker-compose.yml -f .\docker-compose-debug-dataflow.yml up
```

`dataflow-server` 서비스는 디버거가 `5005` 포트에 붙어 디버깅을 시작할 때까지 기다린다. 아래 스크린샷은 IntelliJ로 원격 디버깅을 설정하는 법을 보여준다. `Host:`를 로컬 IP 주소로 설정해라. `localhost`는 도커 컨테이너 내부에서 동작하지 않으므로 사용하면 안 된다.

![scdf-remote-debugging](./../../images/springclouddataflow/scdf-remote-debugging.webp)

간혹 디버깅하는 동안 로컬에서 `spring-cloud-dataflow-server:latest` 도커 이미지를 새로 빌드해야 할 때가 있다. 이럴 땐 DataFlow 루트 디렉토리에서 다음 명령어를 실행하면 된다:

```bash
./mvnw clean install -DskipTests
./mvnw docker:build -pl spring-cloud-dataflow-server
```

### Debug Skipper Server

Skipper 서버의 원격 디버깅도 마찬가지로 [docker-compose-debug-skipper.yml](https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow/v2.9.1/src/docker-compose/docker-compose-debug-skipper.yml) 파일을 사용해 활성화할 수 있다:

<div class="switch-language-wrapper linux-osx windows">
<span class="switch-language linux-osx">Linux / OSX</span>
<span class="switch-language windows">Windows</span>
</div>
<div class="language-only-for-linux-osx linux-osx windows"></div>
```sh
wget -O docker-compose-debug-skipper.yml https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow/v2.9.1/src/docker-compose/docker-compose-debug-skipper.yml
docker-compose -f ./docker-compose.yml -f ./docker-compose-debug-skipper.yml up
```
<div class="language-only-for-windows linux-osx windows"></div>
```sh
curl https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow/v2.9.1/src/docker-compose/docker-compose-debug-skipper.yml -o docker-compose-debug-skipper.yml
docker-compose -f .\docker-compose.yml -f .\docker-compose-debug-skipper.yml up
```

`skipper` 서비스는 디버거가 `6006` 포트에 연결될 때까지 기다린다.

---

## Integration Testing

[DataFlowIT.java](https://github.com/spring-cloud/spring-cloud-dataflow/blob/v2.9.1/spring-cloud-dataflow-server/src/test/java/org/springframework/cloud/dataflow/integration/test/DataFlowIT.java) 클래스에 있는 설명을 보면 같은 docker-compose 파일을 재사용해서 DataFlow 통합 테스트와 스모크 테스트를 빌드하는 방법을 알 수 있다.

---

## Multi-platform Support

이 설정은 로컬 `Skipper` 서버를 원격 플랫폼(`쿠버네티스`, `클라우드 파운드리`같은)에 연결해서 이런 플랫폼들에 스트리밍 데이터 파이프라인을 배포할 수 있도록 해준다. 단, 여기서는 원격 플랫폼에 `Apache Kafka`(또는 `RabbitMQ`) 바인더가 미리 준비돼있다는 전제 조건이 있다.

> 태스크와 배치 애플리케이션은 직접 데이터베이스에 접근해야 한다. 하지만 `Data Flow` 서버와 `Database`는 로컬에서 실행되기 때문에 로컬 플랫폼에서만 태스크 애플리케이션을 시작할 수 있다. 또한 Local Deployer는 `Scheduler` 서비스를 지원하지 않기 때문에 docker-compose 설정에서도 지원하지 않는다.

[docker-compose-cf.yml](https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow/v2.9.1/src/docker-compose/docker-compose-cf.yml) 파일은 Data Flow 런타임 플랫폼으로 원격 `클라우드 파운드리` 계정을 `cf`라는 이름으로 추가한다. CF API URL과 액세스 credential을 추가하려면 `docker-compose-cf.yml`을 수정해야 한다.

```bash
wget -O docker-compose-rabbitmq.yml https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow/v2.9.1/src/docker-compose/docker-compose-rabbitmq.yml
wget -O docker-compose-cf.yml https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow/v2.9.1/src/docker-compose/docker-compose-cf.yml
docker-compose -f ./docker-compose.yml -f ./docker-compose-rabbitmq.yml -f ./docker-compose-cf.yml up
```

CF에선 `Kafka`를 지원하지 않으므로 `docker-compose-rabbitmq.yml` 파일을 사용해 `Rabbit`으로 전환도 해야 한다. `docker-compose-cf.yml` 파일에선 타겟 CF 환경에 `rabbit` 서비스가 설정돼 있다고 가정한다.

[docker-compose-k8s.yml](https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow/v2.9.1/src/docker-compose/docker-compose-k8s.yml) 파일은 Data Flow 런타임 플랫폼으로 원격 `Kubernetes` 계정을 `k8s`라는 이름으로 추가한다. Kubernetes 마스터 URL과 액세스 credential을 추가하려면 `docker-compose-k8s.yml`을 수정해야 한다.

```bash
wget -O docker-compose-k8s.yml https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow/v2.9.1/src/docker-compose/docker-compose-k8s.yml
STREAM_APPS_URI=https://dataflow.spring.io/kafka-docker-latest docker-compose -f ./docker-compose.yml -f ./docker-compose-k8s.yml up
```

Kubernetes 환경에선 디폴트 메이븐 기반 앱 스타터를 배포할 수 없다. `STREAM_APPS_URI` 변수를 설정하면 도커 기반 앱 배포로 전환할 수 있다.

`docker-compose-k8s.yml`에선 타겟 Kubernetes 환경에 `kafka-broker` 서비스가 미리 배포돼 있다고 가정한다. `kafka-broker` 서비스를 배포하려면 [메세지 브로커 선택하기](https://dataflow.spring.io/docs/installation/kubernetes/kubectl/#choose-a-message-broker) 가이드를 따라해라.