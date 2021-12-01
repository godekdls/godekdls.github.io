---
title: Task and Batch Monitoring with Prometheus and InfluxDB
navTitle: Task Monitoring
category: Spring Cloud Data Flow
order: 77
permalink: /Spring%20Cloud%20Data%20Flow/feature-guides.batch.monitoring/
description: 태스크 정의를 구성하는 애플리케이션들의 메트릭을 수집하고 모니터링하기
image: ./../../images/springclouddataflow/SCDF-task-metrics-architecture.webp
lastmod: 2021-12-02T00:33:00+09:00
comments: true
originalRefName: 스프링 클라우드 데이터 플로우
originalRefLink: https://dataflow.spring.io/docs/feature-guides/batch/monitoring/
parent: Feature guides
parentUrl: /Spring%20Cloud%20Data%20Flow/feature-guides/
subparent: Batch Feature Guides
subparentNavTitle: Batch
subparentUrl: /Spring%20Cloud%20Data%20Flow/feature-guides.batch/
---
<script>defaultLanguages = ['prometheus']</script>

---

이 섹션에선 Data Flow의 태스크 정의를 구성하도록 배포한 애플리케이션들을 모니터링하는 방법을 설명한다. 각 플랫폼마다 설정은 다르지만, 전반적인 아키텍처는 모든 플랫폼에서 동일하다.

Data Flow 메트릭 아키텍처는 벤더에 중립적인 애플리케이션 메트릭 파사드인 [Micrometer](https://micrometer.io/) 라이브러리를 중심으로 설계되었다. 가장 많이 사용하는 모니터링 시스템들의 전용 instrumentation 클라이언트를 위한 간단한 파사드를 제공한다. 지원하는 모니터링 시스템 목록은 [Micrometer 문서](https://micrometer.io/docs)를 참고해라. Micrometer는 스프링 부트에서 제공하는 애플리케이션 메트릭을 전달할 수 있는 동력인 instrumentation 라이브러리다. 스프링 배치는 배포한 batch-job 모니터링에 꼭 필요한 태스크  지속 시간, 속도, 에러에 관한 메트릭을 노출할 수 있는 [별도의 통합](../../Spring%20Batch/monitoringandmetrics)을 제공한다.

여기서는 세 가지 시계열 데이터베이스 Wavefront, 프로메테우스, InfluxDB 사용에 초점을 둔다.

[Wavefront](https://docs.wavefront.com/wavefront_introduction.html)는 지표를 3D로 관찰할 수 있는 (메트릭, 히스토그램, trace, span) 고성능 스트리밍 분석 플랫폼이다. 전체 애플리케이션 스택에 걸쳐 있는 수많은 서비스와 소스에서 데이터를 수집하면서, 동시에 매우 빠르게 데이터를 수집<sup>ingestion</sup>하고 동시에 수 많은 질의를 수행하도록 확장할 수 있다.

[프로메테우스](https://prometheus.io/)는 타겟 애플리케이션에 미리 설정해둔 엔드포인트에서 메트릭을 가져오고, 실시간으로 시계열 데이터를 선택하고 집계할 수 있는 쿼리 언어를 제공하는 인기 있는 pull 기반 시계열 데이터베이스다.

[InfluxDB](https://www.influxdata.com/)는 인기 오픈 소스 중 하나로, push 기반 시계열 데이터베이스다. 다운샘플링, 원치 않는 데이터 자동 만료/삭제, 백업/복원을 지원한다. 데이터 분석은 SQL과 유사한 쿼리 언어를 통해 수행한다.

> 태스크 메트릭과 Data Flow를 통합하려면 반드시 필요한 Micrometer 태스크 통합 핵심 로직은 Spring Cloud Task의 2.2.0 릴리즈 라인에서 추가됐다. Spring Cloud Task 2.2+ 버전으로 빌드한 태스크 애플리케이션을 설정해주면, 태스크와 배치 메트릭을 미리 세팅해둔 Micrometer 지원 모니터링 시스템으로 전송할 수 있다.

##### Enable Task Metrics

Data Flow와 태스크 메트릭을 통합하려면 다음과 같이 태스크 애플리케이션에 `spring-boot-starter-actuator`를 추가하고, `spring-cloud-dependencies` BOM을 임포트해야 한다:

```xml
<dependencies>
  <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-actuator</artifactId>
  </dependency>
</dependencies>

<dependencyManagement>
  <dependencies>
      <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-dependencies</artifactId>
        <version>Hoxton.SR6</version>
        <type>pom</type>
        <scope>import</scope>
      </dependency>
  </dependencies>
</dependencyManagement>
```

그런 다음 태스크 POM에 원하는 Micrometer 레지스트리를 의존성으로 넣어줘야 한다:

<div class="switch-language-wrapper prometheus wavefront influxdb">
<span class="switch-language prometheus">Prometheus</span>
<span class="switch-language wavefront">Wavefront</span>
<span class="switch-language influxdb">InfluxDB</span>
</div>
<div class="language-only-for-prometheus prometheus wavefront influxdb"></div>
<div style="border: 1px solid #ddd; padding: 15px; margin-bottom: 20px; background-color: #f9f9f9;">
<p>아래와 같은 의존성을 가지는 <code class="highlighter-rouge">RSocket</code>을 사용해 프로메테우스 메트릭 수집을 활성화한다:</p>
<div class="language-xml highlighter-rouge"><div class="highlight"><pre class="highlight"><code><span class="nt">&lt;dependency&gt;</span>
    <span class="nt">&lt;groupId&gt;</span>io.micrometer.prometheus<span class="nt">&lt;/groupId&gt;</span>
    <span class="nt">&lt;artifactId&gt;</span>prometheus-rsocket-spring<span class="nt">&lt;/artifactId&gt;</span>
<span class="nt">&lt;/dependency&gt;</span>
</code></pre></div></div>
</div>
<div class="language-only-for-wavefront prometheus wavefront influxdb"></div>
<div style="border: 1px solid #ddd; padding: 15px; margin-bottom: 20px; background-color: #f9f9f9;">
<p><code class="highlighter-rouge">micrometer-registry-wavefront</code> 의존성을 추가해 Wavefront 메트릭 수집을 활성화한다:</p>
<div class="language-xml highlighter-rouge"><div class="highlight"><pre class="highlight"><code><span class="nt">&lt;dependency&gt;</span>
    <span class="nt">&lt;groupId&gt;</span>io.micrometer<span class="nt">&lt;/groupId&gt;</span>
    <span class="nt">&lt;artifactId&gt;</span>micrometer-registry-wavefront<span class="nt">&lt;/artifactId&gt;</span>
<span class="nt">&lt;/dependency&gt;</span>
<span class="nt">&lt;dependency&gt;</span>
    <span class="nt">&lt;groupId&gt;</span>com.wavefront<span class="nt">&lt;/groupId&gt;</span>
    <span class="nt">&lt;artifactId&gt;</span>wavefront-sdk-java<span class="nt">&lt;/artifactId&gt;</span>
<span class="nt">&lt;/dependency&gt;</span>
</code></pre></div></div>
<blockquote><p>Micrometer <code class="highlighter-rouge">1.5.3</code> 이상에선 <code class="highlighter-rouge">wavefront-sdk-java</code> 의존성은 제외해야 한다.</p></blockquote>
</div>
<div class="language-only-for-influxdb prometheus wavefront influxdb"></div>
<div style="border: 1px solid #ddd; padding: 15px; margin-bottom: 20px; background-color: #f9f9f9;">
<p>아래 의존성을 추가해 <code class="highlighter-rouge">InfluxDB</code> 메트릭 수집을 활성화한다:</p>
<div class="language-xml highlighter-rouge"><div class="highlight"><pre class="highlight"><code><span class="nt">&lt;dependency&gt;</span>
    <span class="nt">&lt;groupId&gt;</span>io.micrometer<span class="nt">&lt;/groupId&gt;</span>
    <span class="nt">&lt;artifactId&gt;</span>micrometer-registry-influx<span class="nt">&lt;/artifactId&gt;</span>
<span class="nt">&lt;/dependency&gt;</span>
</code></pre></div></div>
</div>


##### Build Docker Image

Docker 이미지를 빌드할 땐 `springcloud/openjdk:latest`를 베이스 이미지로 확장할 수 있다. 예를 들어 태스크 `Dockerfile`은 다음과 같이 시작하면 된다:

```dockerfile
FROM springcloud/openjdk:latest
...
```

Data Flow는 태스크 모니터링을 쉽게 시작할 수 있도록, 필요에 따라 설치하고 커스텀할 수 있는 [그라파나](https://grafana.com/) 대시보드를 제공한다.

다음은 태스크 애플리케이션 모니터링의 전반적인 아키텍처를 나타낸 이미지다:

![Task Monitoring Architecture](./../../images/springclouddataflow/SCDF-task-metrics-architecture.webp)

> 프로메테우스에선 메트릭에 설정된 엔드포인트를 자동으로 알아내기 위해 서비스 디스커버리 컴포넌트가 필요하다. Spring Cloud Data Flow 서버는 서비스 디스커버리 메커니즘에 `rsocket` 프로토콜을 이용하는 [프로메테우스 RSocket Proxy](https://github.com/micrometer-metrics/prometheus-rsocket-proxy)를 사용한다. RSocket 프록시를 사용하기 때문에 short lived에 속하는 태스크와 long-lived 스트림 애플리케이션을 동일한 아키텍처로 모니터링할 수 있다. 자세한 내용은 마이크로미터 문서의 [short lived 태스크와 배치 애플리케이션](https://github.com/micrometer-metrics/prometheus-rsocket-proxy#support-for-short-lived-or-serverless-applications)을 참고해라. 뿐만 아니라, RSocket으로 접근하면 모든 플랫폼에서 동일한 모니터링 아키텍처를 활용할 수 있다. 프로메테우스는 각 프록시 인스턴스를 스크랩하도록 설정된다. 프록시는 돌아가며 이 RSocket 커넥션을 사용해 각 애플리케이션에서 메트릭을 가져온다. 스크랩한 메트릭은 그라파나 대시보드를 통해 조회할 수 있다.

#### Spring Cloud Task Metric Tags

메트릭을 애플리케이션 타입별로, 인스턴스 ID별로, 태스크 이름별로 집계할 수 있도록, Spring Cloud Task 애플리케이션들은 다음 Micrometer 태그를 사용하도록 설정돼 있다:

- `task.name`: 메트릭을 전송하는 애플리케이션들을 가지고 있는 태스크의 이름
- `task.execution.id`: [태스크의 인스턴스 ID](https://docs.spring.io/spring-cloud-task/docs/2.3.3/reference/html/#features-generated_task_id).
- `task.external.execution.id`: 타겟 플랫폼(클라우드 파운드리나 쿠버네티스같은)에 존재하는 [외부 태스크 ID](https://docs.spring.io/spring-cloud-task/docs/2.3.3/reference/html/#features-external_task_id).
- `task.parent.execution.id`: 다른 태스크들을 실행하는 태스크를 식별할 때 사용하는 [부모 태스크 ID](https://docs.spring.io/spring-cloud-task/docs/2.3.3/reference/html/#features-parent_task_id).

그라파나 URL을 가리키는 `spring.cloud.dataflow.metrics.dashboard.url` 프로퍼티를 사용해 Data Flow 서버를 시작하면 그라파나 기능이 활성화되며, Data Flow UI에선 그라파나 버튼을 제공한다. 이 버튼을 클릭하면 주어진 태스크에 대한 대시보드가 열린다.

Wavefront, 프로메테우스, InfluxDB 설치는 실행하는 플랫폼에 따라 다르다. 각 설치 가이드 링크는 아래에서 섹션별로 제공한다.

### 목차

- [Local](#local)
  + [Prometheus](#prometheus)
  + [Wavefront](#wavefront)
  + [InfluxDB](#influxdb)
- [Kubernetes](#kubernetes)
  + [Prometheus](#prometheus-1)
  + [Wavefront](#wavefront-1)
- [Cloud Foundry](#cloud-foundry)
  + [Prometheus](#prometheus-2)
  + [Wavefront](#wavefront-2)
  + [InfluxDB](#influxdb-1)
    
---

## Local

이 섹션에선 로컬 시스템에 있는 프로메테우스나 InfluxDB를 메트릭 저장소로 사용하는 태스크 애플리케이션 메트릭을 조회하는 방법을 설명한다.

### Prometheus

프로메테우스와 그라파나를 설치하려면 Docker Compose 가이드에 있는 [프로메테우스와 그라파나로 모니터링하기](../installation.local-machine.docker-customize#prometheus--grafana)를 따라하면 된다. 가이드대로 따라하면 Spring Cloud Data Flow, Skipper, 아파치 카프카, 프로메테우스와, 기본 제공하는 그라파나 전용 대시보드가 설치된다.

모든 컨테이너를 실행하고 나면 Spring Cloud Data Flow 대시보드는 http://localhost:9393/dashboard에서 확인할 수 있다.

http://localhost:9090/graph, http://localhost:9090/targets에서 프로메테우스 UI에도 붙을 수 있다.

그라파나 대시보드는 http://localhost:3000에서 아래 credential을 통해 액세스할 수 있다:

- user: `admin`
- password: `admin`

이제 커스텀 태스크 애플리케이션(`task-demo-metrics`)을 배포하고 두 가지 태스크(`task1`, `task2`)를 정의해보자:

```bash
dataflow:>app register --name myTask --type task --uri https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow-samples/master/dataflow-website/feature-guides/batch/monitoring/prometheus-task-demo-metrics-0.0.1-SNAPSHOT.jar

dataflow:>task create --name task1 --definition "myTask"
dataflow:>task create --name task2 --definition "myTask"
```

그러면 이 태스크들을 여러 차례 기동해볼 수 있다:

```bash
dataflow:>task launch --name task1
dataflow:>task launch --name task2
```

[DataFlow task execution UI](http://localhost:9393/dashboard/#/tasks/executions)에서 다음과 같은 화면을 볼 수 있을 거다:

![SCDF Tasks](./../../images/springclouddataflow/SCDF-task-metrics-prometheus.webp)

![SCDF Task Execution](./../../images/springclouddataflow/SCDF-task-metrics-executions.webp)

[태스크 전용 그라파나 대시보드에선](http://localhost:3000/d/scdf-tasks/tasks?refresh=10s) 다음과 같은 화면을 볼 수 있을 거다:

![SCDF Task Grafana Prometheus Dashboard](./../../images/springclouddataflow/SCDF-task-metrics-grafana-prometheus-dashboard.webp)

### Wavefront

Data Flow를 Wavefront 지원 기능과 함께 설치하려면 Docker Compose 가이드에 있는 [Wavefront로 모니터링하기](../installation.local-machine.docker-customize#wavefront)를 따라하면 된다. 가이드대로 따라하면 Spring Cloud Data Flow, Skipper, 아파치 카프카가 설치된다. 또한 자동으로 Wavefront Data Flow 통합 타일<sup>Tile</sup>을 가리키고 있을 거다.

Wavefront는 SaaS 기반 플랫폼이다. 먼저 사용자 계정을 생성하고, 이 계정을 사용해서 환경 변수 `WAVEFRONT_KEY`와 `WAVEFRONT_URI`를 설정해야 한다.

아래 이미지와 유사한 대시보드를 볼 수 있을 거다:

![SCDF Wavefront](./../../images/springclouddataflow/SCDF-monitoring-wavefront-task.webp)

### InfluxDB

InfluxDB와 그라파나를 설치하려면 Docker Compose 가이드에 있는 [InfluxDB와 그라파나로 모니터링하기](../installation.local-machine.docker-customize#influxdb--grafana)를 따라하면 된다. 가이드대로 따라하면 Spring Cloud Data Flow, Skipper, 아파치 카프카, InfluxDB와, 기본 제공하는 그라파나 전용 대시보드가 설치된다.

모든 컨테이너를 실행하고 나면 Spring Cloud Data Flow 대시보드는 http://localhost:9393/dashboard에서 확인할 수 있다. 그라파나 대시보드는 http://localhost:3000에서 아래 credential을 통해 액세스할 수 있다:

- user: `admin`
- password: `admin`

이제 커스텀 태스크 애플리케이션(`task-demo-metrics`)을 배포하고 두 가지 태스크(`task1`, `task2`)를 정의해보자:

```bash
dataflow:>app register --name myTask --type task --uri https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow-samples/master/dataflow-website/feature-guides/batch/monitoring/influx-task-demo-metrics-0.0.1-SNAPSHOT.jar

dataflow:>task create --name task1 --definition "myTask"
dataflow:>task create --name task2 --definition "myTask"
```

그러면 이 태스크들을 여러 차례 기동해볼 수 있다:

```bash
dataflow:>task launch --name task1
dataflow:>task launch --name task2
```

[DataFlow task execution UI](http://localhost:9393/dashboard/#/tasks/executions)에서 다음과 같은 화면을 볼 수 있을 거다:

![SCDF Tasks](./../../images/springclouddataflow/SCDF-task-metrics-prometheus.webp)

![SCDF Task Execution](./../../images/springclouddataflow/SCDF-task-metrics-executions.webp)

아래 이미지와 유사한 대시보드를 볼 수 있을 거다:

![SCDF Task Grafana InfluxDB](./../../images/springclouddataflow/SCDF-metrics-grafana-task.webp)

---

## Kubernetes

이 섹션에선 쿠버네티스에 있는 프로메테우스나 InfluxDB를 메트릭 저장소로 사용하는 태스크 애플리케이션 메트릭을 조회하는 방법을 설명한다.

### Prometheus

쿠버네티스 환경에 프로메테우스와 그라파나를 설치하려면 [kubectl을 이용해 설치하기](../installation.kubernetes.kubectl) 가이드대로 따라해라.

> 그라파나 대시보드에 접근할 때 사용하는 주소는 해당 시스템을 배포한 쿠버네티스 플랫폼에 따라 다르다. 예를 들어 GKE를 사용 중이라면 로드 밸런서 주소를 사용한다. 로드 밸런서 구현체를 제공하지 않는 Minikube를 사용하는 경우엔 Minikube의 IP(할당된 포트와 함께)를 사용한다. 아래 예시에선 간단하게 Minikube를 사용한다.

그라파나를 Minikube에 배포할 때는 다음 명령어로 그라파나 UI에 접근할 수 있는 URL을 확인할 수 있다:

```bash
$ minikube service --url grafana
http://192.168.99.100:31595
```

그라파나 대시보드는 http://192.168.99.100:31595에서 아래 credential을 통해 액세스할 수 있다:

- User name: admin
- Password: password

그라파나 인스턴스에는 대시보드가 하나 미리 준비되어 있다:

- Tasks: http://192.168.99.100:31595/d/scdf-tasks/tasks?refresh=10s

메트릭은 태스크별이나 배치별로도 수집할 수 있고, 배포된 모든 애플리케이션에 글로벌로 메트릭 수집을 적용할 수도 있다.

이제 커스텀 태스크 애플리케이션(`task-demo-metrics`)을 배포하고 두 가지 태스크(`task1`, `task2`)를 정의해보자:

```bash
dataflow:>app register --name myTask --type task --uri docker://springcloud/task-demo-metrics:latest

dataflow:>task create --name task1 --definition "myTask"
dataflow:>task create --name task2 --definition "myTask"
```

그러면 이 태스크들을 여러 차례 기동해볼 수 있다:

```bash
dataflow:>task launch --name task1
dataflow:>task launch --name task2
dataflow:>task launch --name task1
dataflow:>task launch --name task2
dataflow:>task launch --name task1
dataflow:>task launch --name task2
```

SCDF를 Minikube에 배포할 때는 다음 명령어로 SCDF에 접근할 수 있는 URL을 확인할 수 있다:

```bash
minikube service --url scdf-server
http://192.168.99.100:32121
```

[DataFlow task execution UI](http://192.168.99.100:32121/dashboard/#/tasks/executions)에서 다음과 같은 화면을 볼 수 있을 거다:

![SCDF Tasks](./../../images/springclouddataflow/SCDF-task-metrics-prometheus.webp)

![SCDF Task Execution](./../../images/springclouddataflow/SCDF-task-metrics-executions.webp)

[태스크 전용 그라파나 대시보드](http://192.168.99.100:31595/d/scdf-tasks/tasks?refresh=10s)를 여러봐라. 다음과 같은 화면이 보일 거다:

![SCDF Task Grafana Prometheus Dashboard](./../../images/springclouddataflow/SCDF-task-metrics-grafana-prometheus-dashboard.webp)

### Wavefront

Wavefront는 SaaS 기반 플랫폼이다. 먼저 사용자 계정을 생성하고, 이 계정에 할당된 `API-KEY`와 `WAVEFRONT-URI`를 알아내야 한다.

통합 가이드 [쿠버네티스에 Data Flow 설치하기](../installation.kubernetes/)에 따라 서버를 준비해라.

그런 다음 Spring Cloud Data Flow 서버 설정(ex. `src/kubernetes/server/server-config.yaml`)에 아래 프로퍼티를 추가해서 Wavefront 통합을 활성화해라:

```yml
management:
  metrics:
    export:
      wavefront:
        enabled: true
        api-token: <YOUR API-KEY>
        uri: <YOUR WAVEFRONT-URI>
        source: demo-scdf-source
```

그러면 Wavefront 포탈에서 아래 이미지와 유사한 대시보드를 볼 수 있을 거다:

![SCDF Wavefront](./../../images/springclouddataflow/SCDF-monitoring-wavefront-task.webp)

---

## Cloud Foundry

이 섹션에선 클라우드 파운드리 환경에 있는 프로메테우스와 InfluxDB를 메트릭 저장소로 사용하는 태스크 애플리케이션 메트릭을 조회하는 방법을 설명한다.

### Prometheus

태스크 애플리케이션의 메트릭 데이터를 프로메테우스 RSocket 게이트웨이로 전송하도록 Data Flow 서버의 매니페스트를 구성하려면 [매니페스트 기반 설치 가이드](../installation.cloudfoundry.cli#configuration-for-prometheus)를 따라해라.

프로메테우스, 그라파나, Spring Cloud Data Flow와 기타 서비스들([Getting Started - 클라우드 파운드리](../installation.cloudfoundry.cli) 섹션에 정의돼 있는)을 모두 띄워 실행 중이라면, 이제 메트릭을 수집할 준비가 됐다.

각자 그라파나를 설치한 위치에서 아래 credential을 통해 그라파나 대시보드에 접근하면 된다:

- User name: admin
- Password: password

그라파나는 이 태스크 대시보드로 프로비저닝해야 한다: [scdf-task-batch.json](https://github.com/spring-cloud/spring-cloud-dataflow/blob/master/src/grafana/prometheus/docker/grafana/dashboards/scdf-task-batch.json)

이제 커스텀 태스크 애플리케이션(`task-demo-metrics`)을 배포하고 두 가지 태스크(`task1`, `task2`)를 정의해보자:

```bash
dataflow:>app register --name myTask --type task --uri https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow-samples/master/dataflow-website/feature-guides/batch/monitoring/prometheus-task-demo-metrics-0.0.1-SNAPSHOT.jar

dataflow:>task create --name task1 --definition "myTask"
dataflow:>task create --name task2 --definition "myTask"
```

그러면 이 태스크들을 여러 차례 기동해볼 수 있다:

```bash
dataflow:>task launch --name task1
dataflow:>task launch --name task2
```

[DataFlow task execution UI](http://localhost:9393/dashboard/#/tasks/executions)에서 다음과 같은 화면을 볼 수 있을 거다:

![SCDF Tasks](./../../images/springclouddataflow/SCDF-task-metrics-prometheus.webp)

![SCDF Task Execution](./../../images/springclouddataflow/SCDF-task-metrics-executions.webp)

[태스크 전용 그라파나 대시보드에선](http://localhost:3000/d/scdf-tasks/tasks?refresh=10s) 다음과 같은 화면을 볼 수 있을 거다:

![SCDF Task Grafana Prometheus Dashboard](./../../images/springclouddataflow/SCDF-task-metrics-grafana-prometheus-dashboard.webp)

### Wavefront

Wavefront는 SaaS 기반 플랫폼이다. 먼저 사용자 계정을 생성하고 이 계정에 할당된 `API-KEY`와 `WAVEFRONT-URI`를 알아내야 한다.

태스크 애플리케이션의 메트릭 데이터를 Wavefront 모니터링 시스템으로 전송하도록 Data Flow 서버를 설정하려면 [매니페스트 기반 Wavefront 설정 가이드](../installation.cloudfoundry.cli#configuration-for-wavefront)를 따라해라.

그러면 Wavefront 포탈에서 아래 이미지와 유사한 대시보드를 볼 수 있을 거다:

![SCDF Wavefront](./../../images/springclouddataflow/SCDF-monitoring-wavefront-task.webp)

### InfluxDB

클라우드 파운드리에 `Skipper`와 `DataFlow`를 설치하려면 통합 가이드 [클라우드 파운드리에 매니페스트 기반으로 설치하기](../installation.cloudfoundry.cli)를 따라하면 된다. 태스크 메트릭 통합을 활성화하려면 [InfluxDB 설정하기](../installation.cloudfoundry.cli#configuration-for-influxdb)를 따라해라.