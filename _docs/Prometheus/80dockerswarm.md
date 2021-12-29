---
title: Docker Swarm
category: Prometheus
order: 80
permalink: /Prometheus/guides.dockerswarm/
description: 도커 스웜 서비스 디스커버리 가이드
image: ./../../images/prometheus/logo.png
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/guides/dockerswarm/
parent: GUIDES
parentUrl: /Prometheus/guides/
---

---

프로메테우스는 v2.20.0부터 [Docker Swarm](https://docs.docker.com/engine/swarm/) 클러스터에서 타겟을 가져올 수 있다. 이 문서에선 도커 스웜 서비스 디스커버리 메커니즘을 사용하는 방법을 안내한다.

### 목차

- [Docker Swarm service discovery architecture](#docker-swarm-service-discovery-architecture)
- [Setting up Prometheus](#setting-up-prometheus)
- [Monitoring Docker daemons](#monitoring-docker-daemons)
- [Monitoring Containers](#monitoring-containers)
- [Discovered labels](#discovered-labels)
  + [Scraping metrics via a certain network only](#scraping-metrics-via-a-certain-network-only)
  + [Scraping global tasks only](#scraping-global-tasks-only)
  + [Adding a docker_node label to the targets](#adding-a-docker_node-label-to-the-targets)
- [Connecting to the Docker Swarm](#connecting-to-the-docker-swarm)
- [Conclusion](#conclusion)

---

## Docker Swarm service discovery architecture

[도커 스웜 서비스 디스커버리](../configuration/#dockerswarm_sd_config)에선 nodes, tasks, services라는 3가지 role이 있다.

첫 번째 role **nodes**는 스웜 클러스터에 있는 호스트들을 나타낸다. 스웜 호스트에서 실행하는 도커 데몬이나 노드 익스포터를 자동으로 모니터링할 때 활용할 수 있다.

두 번째 role **tasks**는 스웜에 배포한 개별적인 컨테이너들을 나타낸다. 각 태스크는 연결된 서비스 레이블들을 가져온다. 하나의 서비스는 태스크를 여러 개 가질 수 있다.

세 번째 role **services**는 스웜에 배포한 서비스를 검색한다. 이때는 서비스에서 노출한 포트들을 검색한다. 보통은 서비스 role보단 태스크 role이 필요할 거다.

프로메테우스는 포트를 노출하는 태스크와 서비스만 검색한다.

> **주의:** 여기서부터는 스웜을 실행 중이라고 가정한다.

---

## Setting up Prometheus

이 가이드를 따라하려면 [프로메테우스를 세팅](../getting-started)해야 한다. 여기서는 프로메테우스를 도커 스웜 매니저 노드에서 실행하고 도커 소켓 `/var/run/docker.sock`에 액세스할 수 있다고 가정한다.

---

## Monitoring Docker daemons

서비스 디스커버리를 자세히 파헤쳐보자.

도커 자체는 데몬으로서 프로메테우스 서버에서 수집할 수 있는 [메트릭](https://docs.docker.com/config/daemon/prometheus/)을 노출해준다.

메트릭은 `/etc/docker/daemon.json`을 수정해 아래 프로퍼티를 설정해주면 활성화할 수 있다:

```js
{
  "metrics-addr" : "0.0.0.0:9323",
  "experimental" : true
}
```

`0.0.0.0` 대신 도커 스웜 노드의 IP를 설정하면 된다.

새 설정을 적용하려면 데몬을 재시작해야 한다.

관련 정보는 [도커 문서](https://docs.docker.com/config/daemon/prometheus/)에서 더 자세히 설명하고 있다.

그런 다음 아래 있는 `prometheus.yml` 파일을 이용해 도커 데몬을 스크랩하도록 프로메테우스를 설정해주면 된다:

```yaml
scrape_configs:
  # 프로메테우스가 자체 메트릭을 수집하도록 만든다.
  - job_name: 'prometheus'
    static_configs:
    - targets: ['localhost:9090']

  # 도커 데몬을 위한 job을 생성한다.
  - job_name: 'docker'
    dockerswarm_sd_configs:
      - host: unix:///var/run/docker.sock
        role: nodes
    relabel_configs:
      # 9323 포트에서 메트릭을 가져온다.
      - source_labels: [__meta_dockerswarm_node_address]
        target_label: __address__
        replacement: $1:9323
      # 호스트명을 instance 레이블로 설정한다.
      - source_labels: [__meta_dockerswarm_node_hostname]
        target_label: instance
```

nodes role을 사용할 땐 `dockerswarm_sd_configs` 밑에 `port` 파라미터를 선언할 수도 있다. 하지만 프로메테우스가 도커 스웜 설정에서 같은 API를 동일하게 재사용할 수 있도록 `relabel_configs`를 사용하는 것을 권장한다.

---

## Monitoring Containers

이번에는 스웜에 서비스를 배포해보자. 컨테이너 리소스 메트릭을 노출해주는 [cadvisor](https://github.com/google/cadvisor)를 배포해보겠다.

```sh
docker service create --name cadvisor -l prometheus-job=cadvisor \
    --mode=global --publish target=8080,mode=host \
    --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock,ro \
    --mount type=bind,src=/,dst=/rootfs,ro \
    --mount type=bind,src=/var/run,dst=/var/run \
    --mount type=bind,src=/sys,dst=/sys,ro \
    --mount type=bind,src=/var/lib/docker,dst=/var/lib/docker,ro \
    google/cadvisor -docker_only
```

다음은 이 서비스를 모니터링하는데 필요한 최소한의 설정을 추가한 `prometheus.yml` 파일이다:

```yaml
scrape_configs:
  # 프로메테우스가 자체 메트릭을 수집하도록 만든다.
  - job_name: 'prometheus'
    static_configs:
    - targets: ['localhost:9090']

  # 도커 스웜 컨테이너들을 위한 job을 생성한다.
  - job_name: 'dockerswarm'
    dockerswarm_sd_configs:
      - host: unix:///var/run/docker.sock
        role: tasks
    relabel_configs:
      # 실행 중이여야 하는 컨테이너들만 남긴다.
      - source_labels: [__meta_dockerswarm_task_desired_state]
        regex: running
        action: keep
      # `prometheus-job` 레이블을 가지고 있는 컨테이너만 남긴다.
      - source_labels: [__meta_dockerswarm_service_label_prometheus_job]
        regex: .+
        action: keep
      # 이 prometheus-job 스웜 레이블을 프로메테우스 job 레이블로 사용한다.
      - source_labels: [__meta_dockerswarm_service_label_prometheus_job]
        target_label: job
```

[relabel 설정](../configuration#relabel_config)을 하나씩 분석해보자.

```yaml
- source_labels: [__meta_dockerswarm_task_desired_state]
  regex: running
  action: keep
```

도커 스웜은 API를 통해 [태스크의 desired state](https://docs.docker.com/engine/swarm/how-swarm-mode-works/swarm-task-states/)를 노출한다. 이 예제에선 실행 중이어야 하는 타겟만 **유지**한다. 덕분에 종료돼야 하는 태스크들은 모니터링하지 않는다.

```yaml
- source_labels: [__meta_dockerswarm_service_label_prometheus_job]
  regex: .+
  action: keep
```

cadvisor를 배포할 때는 `prometheus-job=cadvisor`라는 레이블을 추가했었다. 프로메테우스는 태스크 레이블들을 가져오기 때문에, `prometheus-job` 레이블을 가지고 있는 타겟들**만** 남기도록 설정해줄 수 있다.

```yaml
- source_labels: [__meta_dockerswarm_service_label_prometheus_job]
  target_label: job
```

마지막 설정에선 태스크의 `prometheus-job` 레이블을 가져와 타겟 레이블로 전환하며, 스크랩 설정에서 가져온 디폴트 job 레이블 `dockerswarm`을 덮어쓴다.

---

## Discovered labels

전체 레이블 목록은 [프로메테우스 문서](../configuration/#docker_sd_config)에 나와있지만, 여기서는 유용하게 활용할 수 있는 relabel 설정들을 보여준다.

### Scraping metrics via a certain network only

```yaml
- source_labels: [__meta_dockerswarm_network_name]
  regex: ingress
  action: keep
```

### Scraping global tasks only

글로벌 태스크들은 모든 데몬에서 실행된다.

```yaml
- source_labels: [__meta_dockerswarm_service_mode]
  regex: global
  action: keep
- source_labels: [__meta_dockerswarm_task_port_publish_mode]
  regex: host
  action: keep
```

### Adding a docker_node label to the targets

```yaml
- source_labels: [__meta_dockerswarm_node_hostname]
  target_label: docker_node
```

---

## Connecting to the Docker Swarm

위에 있는 `dockerswarm_sd_configs` 항목에선 host 필드를 사용했었다:

```yaml
host: unix:///var/run/docker.sock
```

이 설정에선 도커 소켓을 사용한다. 유닉스 소켓보단 HTTP와 HTTPS를 사용해 스웜에 연결하는 것을 선호한다면, 프로메테우스는 [다른 설정 옵션들](../configuration/#dockerswarm_sd_config)도 제공하고 있다.

---

## Conclusion

모니터링할 타겟과 방식을 결정할 때 활용할 수 있는 디스커버리 레이블들은 매우 다양하다. 태스크에서 이용할 수 있는 레이블만 해도 25가지가 넘어간다. 검색한 모든 레이블들을 조회하고 싶다면, 언제든지 프로메테우스 서버의 "Service Discovery" 페이지를 확인해보면 된다 ("Status" 메뉴 아래에서).

서비스 디스커버리는 스웜 스택에 대해 어떠한 가정도 하지 않으므로, 적절한 설정만 제공해주면 가지고 있는 스택에 연결할 수 있을 거다.