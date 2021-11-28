---
title: Server Monitoring with Prometheus and Wavefront
navTitle: Server Monitoring
category: Spring Cloud Data Flow
order: 58
permalink: /Spring%20Cloud%20Data%20Flow/feature-guides.general.server-monitoring/
description: Data Flow와 Skipper 서버 모니터링 가이드
image: ./../../images/springclouddataflow/SCDF-wavefront-servers-dashboard.webp
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 클라우드 데이터 플로우
originalRefLink: https://dataflow.spring.io/docs/feature-guides/general/server-monitoring/
parent: Feature guides
parentUrl: /Spring%20Cloud%20Data%20Flow/feature-guides/
subparent: General Feature Guides
subparentNavTitle: General
subparentUrl: /Spring%20Cloud%20Data%20Flow/feature-guides.general/
---

---

이 섹션에선 Spring Cloud Data Flow 서버와 Spring Cloud Skipper 서버를 모니터링하는 방법을 설명한다. 각 플랫폼마다 설정은 다르지만 전반적인 아키텍처는 모든 플랫폼에서 동일하다.

Data Flow 메트릭 아키텍처는 [Micrometer](https://micrometer.io/) 라이브러리를 중심으로 설계되어, 가장 많이 사용하는 모니터링 시스템들의 전용 instrumentation 클라이언트를 위한 간단한 파사드를 제공한다. 지원하는 모니터링 시스템 목록은 [Micrometer 문서](https://micrometer.io/docs)를 참고해라.

Data Flow와 Skipper 서버엔 가장 흔히 쓰는 두 가지 모니터링 시스템 [프로메테우스](https://prometheus.io/)와 [Wavefront](https://www.wavefront.com/)가 미리 설정돼있다. 배포한 애플리케이션들에서 사용하고 싶은 모니터링 시스템을 선언해주면 된다.

Data Flow는 스트림 모니터링을 쉽게 시작할 수 있도록, 필요에 따라 설치하고 커스텀할 수 있는 프로메테우스 전용 [그라파나](https://grafana.com/) 대시보드를 제공한다. Wavefront에선 Data Flow 통합 타일<sup>tile</sup>을 사용해 메트릭을 다각도로 시각화할 수 있다.

> 프로메테우스에선 메트릭에 설정된 엔드포인트를 자동으로 알아내기 위해 서비스 디스커버리 컴포넌트가 필요하다. Spring Cloud Data Flow 서버는 서비스 디스커버리 메커니즘에 `rsocket` 프로토콜을 이용하는 [프로메테우스 RSocket Proxy](https://github.com/micrometer-metrics/prometheus-rsocket-proxy)를 사용한다. RSocket 프록시를 사용하기 때문에 동일한 아키텍처를 이용해 short lived에 속하는 태스크 뿐 아니라, long-lived 스트림 애플리케이션까지 모니터링할 수 있다. 자세한 내용은 마이크로미터 문서의 [short lived 태스크와 배치 애플리케이션](https://github.com/micrometer-metrics/prometheus-rsocket-proxy#support-for-short-lived-or-serverless-applications)을 참고해라. 뿐만 아니라, RSocket으로 접근하면 모든 플랫폼에서 동일한 모니터링 아키텍처를 활용할 수 있다. 프로메테우스는 각 프록시 인스턴스를 스크랩하도록 설정된다. 프록시는 돌아가며 이 RSocket 커넥션을 사용해 각 애플리케이션에서 메트릭을 가져온다. 스크랩한 메트릭은 그라파나 대시보드를 통해 조회할 수 있다.

다음은 그라파나와 Wavefront 대시보드를 보여주는 이미지다:

![Grafana Servers Dashboard](./../../images/springclouddataflow/SCDF-grafana-servers-dashboard.webp)

![Wavefront Servers Dashboard](./../../images/springclouddataflow/SCDF-wavefront-servers-dashboard.webp)

### 목차

- [Local](#local)
  * [Prometheus](#prometheus)
  * [Wavefront](#wavefront)
- [Kubernetes](#kubernetes)
  * [Prometheus](#prometheus-1)
  * [Wavefront](#wavefront-1)
- [Cloud Foundry](#cloud-foundry)
  * [Prometheus](#prometheus-2)
  * [Wavefront](#wavefront-2)

---

## Local

이 섹션에선 로컬 시스템에서 프로메테우스나 InfluxDB를 메트릭 저장소로 사용할 때 서버 메트릭을 조회하는 방법을 설명한다. Wavefront는 클라우드 기반 플랫폼이긴 하지만, Data Flow를 로컬에 배포한 뒤 클라우드가 관리하는 Wavefront 모니터링 시스템을 가리키게 만들 수 있다.

### Prometheus

프로메테우스와 그라파나를 설치하려면 Docker Compose 가이드에 있는 [프로메테우스와 그라파나로 모니터링하기](../installation.local-machine.docker-customize#prometheus--grafana)를 따라하면 된다. 가이드대로 따라하면 Spring Cloud Data Flow, Skipper, 아파치 카프카, 프로메테우스와, 기본 제공하는 그라파나 전용 대시보드가 설치된다.

모든 컨테이너를 실행하고 나면 Spring Cloud Data Flow 대시보드는 http://localhost:9393/dashboard에서 확인할 수 있다.

http://localhost:9090/graph, http://localhost:9090/targets에서 프로메테우스 UI에도 붙을 수 있다.

그라파나 대시보드는 http://localhost:3000에서 아래 credential을 통해 액세스할 수 있다:

- user: `admin`
- password: `admin`

서버 대시보드는 다음 URL에서 접근할 수 있다: `http://localhost:3000/d/scdf-servers/servers?refresh=10s`

### Wavefront

Data Flow를 Wavefront 지원 기능과 함께 설치하려면 Docker Compose 가이드에 있는 [Wavefront로 모니터링하기](../installation.local-machine.docker-customize#wavefront)를 따라하면 된다. 가이드대로 따라하면 Spring Cloud Data Flow, Skipper, 아파치 카프카가 설치된다. 또한 자동으로 Wavefront Data Flow 통합 타일<sup>Tile</sup>을 가리키고 있을 거다.

Wavefront는 SaaS 기반 플랫폼으로, 먼저 사용자 계정을 생성해야 한다. 이 계정을 사용해 뒤에서 설명하는 대로 환경 변수 `WAVEFRONT_KEY`와 `WAVEFRONT_URI`를 설정하면 된다.

---

## Kubernetes

이 섹션에선 쿠버네티스 환경에서 프로메테우스나 Wavefront를 메트릭 저장소로 사용할 때 스트림 애플리케이션 메트릭을 조회하는 방법을 설명한다.

### Prometheus

쿠버네티스 환경에 프로메테우스와 그라파나를 설치하려면 [kubectl을 이용해 설치하기](../installation.kubernetes.kubectl) 가이드대로 따라해라.

> 그라파나 UI에 접근할 때 사용하는 주소는 해당 시스템을 배포한 쿠버네티스 플랫폼에 따라 다르다. 예를 들어 GKE를 사용 중이라면 로드 밸런서 주소를 사용한다. 로드 밸런서 구현체를 제공하지 않는 Minikube를 사용하는 경우엔 Minikube의 IP(할당된 포트와 함께)를 사용한다. 아래 예시에선 간단하게 Minikube를 사용한다.

그라파나를 Minikube에 배포할 때는 다음 명령어로 그라파나 UI에 접근할 수 있는 URL을 확인할 수 있다:

```bash
$ minikube service --url grafana
http://192.168.99.100:31595
```

그라파나 대시보드는 http://192.168.99.100:31595에서 아래 credential을 통해 액세스할 수 있다:

- User name: admin
- Password: password

서버 대시보드는 http://192.168.99.100:31595/d/scdf-servers/servers?refresh=10s에서 접근할 수 있다.

### Wavefront

Wavefront는 SaaS 기반 플랫폼이다. 먼저 사용자 계정을 생성하고 이 계정에 할당된 `API-KEY`와 `WAVEFRONT-URI`를 알아내야 한다.

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

Spring Cloud Skipper Wavefront 모니터링을 활성화하려면 똑같이 Skipper 서버 설정에도 메트릭 설정을 추가해라 (ex. `src/kubernetes/skipper/skipper-config-kafka.yaml` 또는 `src/kubernetes/skipper/skipper-config-rabbit.yaml`):

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

---

## Cloud Foundry

이 섹션에선 클라우드 파운드리 환경에서 프로메테우스를 메트릭 저장소로 사용할 때 스트림 애플리케이션 메트릭을 조회하는 방법을 설명한다.

### Prometheus

스트림 애플리케이션의 메트릭 데이터를 프로메테우스 RSocket 게이트웨이로 전송하도록 Data Flow 서버의 매니페스트를 구성하려면 [매니페스트 기반 설치 가이드](../installation.cloudfoundry.cli#configuration-for-prometheus)를 따라해라.

프로메테우스, 그라파나, Spring Cloud Data Flow와 [Getting Started - 클라우드 파운드리](../installation.cloudfoundry.cli) 섹션에 정의돼 있는 기타 서비스들을 모두 띄워 실행 중이라면, 이제 메트릭을 수집할 준비가 됐다.

각자 그라파나를 설치한 위치에서 아래 credential을 통해 그라파나 대시보드에 접근하면 된다:

- User name: admin
- Password: password

서버 대시보드는 다음 URL로 접근할 수 있다: http://localhost:3000/d/scdf-servers/servers?refresh=10s

### Wavefront

Wavefront는 SaaS 기반 플랫폼이다. 먼저 사용자 계정을 생성하고 이 계정에 할당된 `API-KEY`와 `WAVEFRONT-URI`를 알아내야 한다.

스트림 애플리케이션의 메트릭 데이터를 Wavefront 모니터링 시스템으로 전송하도록 Data Flow 서버를 설정하려면 [매니페스트 기반 Wavefront 설정 가이드](../installation.cloudfoundry.cli#configuration-for-wavefront)를 따라해라.