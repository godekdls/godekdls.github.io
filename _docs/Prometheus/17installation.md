---
title: Installation
category: Prometheus
order: 17
permalink: /Prometheus/installation/
description: 프로메테우스 설치 가이드
image: ./../../images/prometheus/logo.png
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/prometheus/2.32/getting_started/
parent: PROMETHEUS
parentUrl: /Prometheus/prometheus/
---

### 목차

- [Using pre-compiled binaries](#using-pre-compiled-binaries)
- [From source](#from-source)
- [Using Docker](#using-docker)
  + [Volumes & bind-mount](#volumes--bind-mount)
  + [Custom image](#custom-image)
- [Using configuration management systems](#using-configuration-management-systems)
  + [Ansible](#ansible)
  + [Chef](#chef)
  + [Puppet](#puppet)
  + [SaltStack](#saltstack)
    
---

## Using pre-compiled binaries

공식 프로메테우스 컴포넌트는 대부분 미리 컴파일해둔 바이너리 파일을 제공한다. 다운받을 수 있는 전체 버전은 [다운로드 페이지](https://prometheus.io/download)을 확인해봐라.

---

## From source

소스 코드로 프로메테우스 컴포넌트를 빌드하려면 각 저장소에 있는 `Makefile` 타겟을 확인해봐라.

---

## Using Docker

모든 프로메테우스 서비스는 [Quay.io](https://quay.io/repository/prometheus/prometheus)나 [Docker Hub](https://hub.docker.com/r/prom/prometheus)에 있는 도커 이미지로도 이용할 수 있다.

도커에서 프로메테우스를 실행하는 건 `docker run -p 9090:9090 prom/prometheus` 명령어가 전부다. 이 명령어는 샘플 설정으로 프로메테우스를 시작하고 9090 포트로 노출해준다.

프로메테우스 이미지는 실제 메트릭을 저장할 땐 볼륨을 사용한다. 프로덕션 배포에선 [named volume](https://docs.docker.com/storage/volumes/)을 사용하는 게 프로메테우스를 업그레이드하더라도 데이터를 쉽게 관리할 수 있다.

자체 설정을 제공하고 싶다면, 몇 가지 옵션이 있다. 여기선 두 가지 예시를 보여주겠다.

### Volumes & bind-mount

아래 명령어를 실행해서 호스트에 있는 `prometheus.yml`을 바인드 마운트시킨다:

```sh
docker run \
    -p 9090:9090 \
    -v /path/to/prometheus.yml:/etc/prometheus/prometheus.yml \
    prom/prometheus
```

아니면 다음 명령어로 `prometheus.yml`이 들어 있는 디렉토리를 `/etc/prometheus`에 바인드 마운트한다:

```sh
docker run \
    -p 9090:9090 \
    -v /path/to/config:/etc/prometheus \
    prom/prometheus
```

### Custom image

파일을 호스트에서 관리하고 바인드 마운트를 사용하는 게 싫다면, 설정 자체를 이미지에 실어버릴 수 있다. 설정 자체가 고정돼있고 모든 환경에서 동일하다면 이 방법도 괜찮다.

디렉토리를 하나 새로 만들어서, 프로메테우스 설정과 다음과 같은 `Dockerfile`을 추가해라:

```dockerfile
FROM prom/prometheus
ADD prometheus.yml /etc/prometheus/
```

이제 빌드해서 실행해보자:

```sh
docker build -t my-prometheus .
docker run -p 9090:9090 my-prometheus
```

더 나아가면 몇 가지 툴을 활용해 기동 시 설정을 동적으로 렌더링하거나, 데몬을 이용해 설정을 주기적으로 업데이트할 수도 있다.

---

## Using configuration management systems

따로 설정 관리 시스템을 두는 것을 선호한다면, 아래 써드 파티에 기여에도 관심이 있을 수 있겠다:

### Ansible

- [Cloud Alchemy/ansible-prometheus](https://github.com/cloudalchemy/ansible-prometheus)

### Chef

- [rayrod2030/chef-prometheus](https://github.com/rayrod2030/chef-prometheus)

### Puppet

- [puppet/prometheus](https://forge.puppet.com/puppet/prometheus)

### SaltStack

- [saltstack-formulas/prometheus-formula](https://github.com/saltstack-formulas/prometheus-formula)