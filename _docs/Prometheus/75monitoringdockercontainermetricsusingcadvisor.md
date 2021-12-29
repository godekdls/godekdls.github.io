---
title: Monitoring Docker container metrics using cAdvisor
category: Prometheus
order: 75
permalink: /Prometheus/guides.cadvisor/
description: cAdvisor를 이용해 도커 컨테이너 메트릭 수집하기
image: ./../../images/prometheus/logo.png
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/guides/cadvisor/
parent: GUIDES
parentUrl: /Prometheus/guides/
---

---

[cAdvisor](https://github.com/google/cadvisor)(**c**ontainer **Advisor**의 약자)는 실행 중인 컨테이너의 리소스 사용량과 데이터를 분석해서 노출해준다. cAdvisor에선 특별한 설정 없이도 프로메테우스 메트릭을 노출할 수 있다. 이 가이드에선 다음과 같은 내용들을 실습해본다:

- 로컬 멀티 컨테이너 [Docker Compose](https://docs.docker.com/compose/) 설치 파일을 만들어본다. 이 파일에는 각각 프로메테우스, cAdvisor, [Redis](https://redis.io/) 서버를 실행하는 컨테이너가 담겨있다.
- Redis 컨테이너에서 만들어지고, cAdvisor에서 수집하고, 프로메테우스로 스크랩하는 컨테이너 메트릭 몇 가지를 파헤쳐본다.

### 목차

- [Prometheus configuration](#prometheus-configuration)
- [Docker Compose configuration](#docker-compose-configuration)
- [Exploring the cAdvisor web UI](#exploring-the-cadvisor-web-ui)
- [Exploring metrics in the expression browser](#exploring-metrics-in-the-expression-browser)
- [Other expressions](#other-expressions)
- [Summary](#summary)

---

## Prometheus configuration

cAdvisor에서 메트릭을 스크랩하려면 먼저 [프로메테우스부터 설정](../configuration)해줘야 한다. `prometheus.yml` 파일을 만들어 아래 있는 설정으로 채워줘라:

```yaml
scrape_configs:
- job_name: cadvisor
  scrape_interval: 5s
  static_configs:
  - targets:
    - cadvisor:8080
```

---

## Docker Compose configuration

이번에는 설치할 컨테이너들과, 각 컨테이너로 노출하는 포트, 사용할 볼륨 등을 지정하는 Docker Compose [설정](https://docs.docker.com/compose/compose-file/)을 만들어야 한다.

[`prometheus.yml`](#prometheus-configuration) 파일을 만들었던 폴더에서 `docker-compose.yml` 파일을 생성하고 아래 있는 Docker Compose 설정으로 채워줘라:

```yaml
version: '3.2'
services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
    - 9090:9090
    command:
    - --config.file=/etc/prometheus/prometheus.yml
    volumes:
    - ./prometheus.yml:/etc/prometheus/prometheus.yml:ro
    depends_on:
    - cadvisor
  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    container_name: cadvisor
    ports:
    - 8080:8080
    volumes:
    - /:/rootfs:ro
    - /var/run:/var/run:rw
    - /sys:/sys:ro
    - /var/lib/docker/:/var/lib/docker:ro
    depends_on:
    - redis
  redis:
    image: redis:latest
    container_name: redis
    ports:
    - 6379:6379
```

Docker Compose에서 이 설정을 사용하면 [Docker](https://docker.com/) 컨테이너에 해당하는 세 가지 서비스가 실행된다:

1. `prometheus` 서비스에선 로컬 `prometheus.yml` 설정 파일을 사용한다 (`volumes` 파라미터를 이용해 컨테이너로 임포트).
2. `cadvisor` 서비스는 8080 포트를 노출하며 (cAdvisor 메트릭의 디폴트 포트), 다양한 로컬 볼륨을 사용한다 (`/`, `/var/run` 등).
3. `redis` 서비스는 일반적인 Redis 서버다. cAdvisor는 별다른 설정 없이도 이 컨테이너에서 컨테이너 메트릭을 자동으로 수집해준다. 

이 설치 파일을 실행하려면:

```sh
docker-compose up
```

Docker Compose가 세 컨테이너를 모두 정상적으로 기동하고 나면 다음과 같은 문구가 출력되는 걸 볼 수 있을 거다:

```sh
prometheus  | level=info ts=2018-07-12T22:02:40.5195272Z caller=main.go:500 msg="Server is ready to receive web requests."
```

[`ps`](https://docs.docker.com/compose/reference/ps/) 명령어를 실행해보면 세 가지 컨테이너가 모두 실행 중인지를 확인해볼 수 있다:

```sh
docker-compose ps
```

다음과 같은 내용이 출력될 거다:

```sh
   Name                 Command               State           Ports
----------------------------------------------------------------------------
cadvisor     /usr/bin/cadvisor -logtostderr   Up      8080/tcp
prometheus   /bin/prometheus --config.f ...   Up      0.0.0.0:9090->9090/tcp
redis        docker-entrypoint.sh redis ...   Up      0.0.0.0:6379->6379/tcp
```

---

## Exploring the cAdvisor web UI

cAdvisor [웹 UI](https://github.com/google/cadvisor/blob/master/docs/web.md)는 `http://localhost:8080`에서 접속할 수 있다. `http://localhost:8080/docker/<container>`에선 설치한 도커 컨테이너들의 통계 지표와 그래프를 살펴볼 수 있다. 예를 들어 Redis 컨테이너 관련 메트릭은 `http://localhost:8080/docker/redis`에서, 프로메테우스 관련 메트릭은 `http://localhost:8080/docker/prometheus`에서 접근할 수 있다.

---

## Exploring metrics in the expression browser

cAdvisor의 웹 UI는 cAdvisor가 모니터링하는 것들을 살펴볼 때는 유용하지만, 컨테이너 *메트릭*을 탐색할 수 있는 인터페이스는 제공하지 않는다. 이럴 때는 프로메테우스 [expression 브라우저](../expression-browser)가 필요할 거다. expression 브라우저는 `http://localhost:9090/graph`에서 이용할 수 있다. 아래와 같이 생긴 입력 창에 프로메테우스 표현식을 입력해보면 된다:

![Prometheus expression bar](./../../images/prometheus/prometheus-expression-bar.png)

컨테이너의 시작 시간(초 단위)을 기록하는 `container_start_time_seconds` 메트릭부터 파헤쳐보자. 특정 컨테이너를 선택하고 싶을 땐 `name="<container_name>"` 표현식을 사용해서 이름을 지정해주면 된다. 컨테이너 이름은 Docker Compose 설정에 있는 `container_name` 파라미터를 의미한다. 예를 들어 [`container_start_time_seconds{name="redis"}`](http://localhost:9090/graph?g0.range_input=1h&g0.expr=container_start_time_seconds%7Bname%3D%22redis%22%7D&g0.tab=1) 표현식은 `redis` 컨테이너의 시작 시간을 보여준다.

> **참고:** cAdvisor가 수집해서 프로메테우스에 노출해주는 전체 컨테이너 메트릭들은 [cAdvisor 문서](https://github.com/google/cadvisor/blob/master/docs/storage/prometheus.md)에서 확인할 수 있다.

---

## Other expressions

다음은 다른 표현식 예시 몇 가지를 정리해둔 테이블이다.

| Expression                                                   | Description                                                  | For              |
| :----------------------------------------------------------- | :----------------------------------------------------------- | :--------------- |
| [`rate(container_cpu_usage_seconds_total{name="redis"}[1m])`](http://localhost:9090/graph?g0.range_input=1h&g0.expr=rate(container_cpu_usage_seconds_total%7Bname%3D%22redis%22%7D%5B1m%5D)&g0.tab=1) | 최근 1분 간의 [cgroup](https://en.wikipedia.org/wiki/Cgroups)의 CPU 사용량 | `redis` 컨테이너 |
| [`container_memory_usage_bytes{name="redis"}`](http://localhost:9090/graph?g0.range_input=1h&g0.expr=container_memory_usage_bytes%7Bname%3D%22redis%22%7D&g0.tab=1) | cgroup의 총 메모리 사용량 (바이트 단위)                      | `redis` 컨테이너 |
| [`rate(container_network_transmit_bytes_total[1m])`](http://localhost:9090/graph?g0.range_input=1h&g0.expr=rate(container_network_transmit_bytes_total%5B1m%5D)&g0.tab=1) | 최근 1분 동안 컨테이너가 네트워크를 통해 전송한 초당 바이트  | 전체 컨테이너    |
| [`rate(container_network_receive_bytes_total[1m])`](http://localhost:9090/graph?g0.range_input=1h&g0.expr=rate(container_network_receive_bytes_total%5B1m%5D)&g0.tab=1) | 최근 1분 동안 컨테이너가 네트워크를 통해 수신한 초당 바이트  | 전체 컨테이너    |

---

## Summary

이 가이드에선 Docker Compose를 이용해 한 번의 설치로 독립적인 세 가지 컨테이너를 실행해봤다. Redis 컨테이너에서 생성한 메트릭은 cAdvisor 컨테이너를 통해 수집하고, 이 메트릭은 이어서 프로메테우스 컨테이너로 스크랩했다. 그런 다음 프로메테우스 expression 브라우저를 이용해 몇 가지 cAdvisor 컨테이너 메트릭을 탐색해봤다.

