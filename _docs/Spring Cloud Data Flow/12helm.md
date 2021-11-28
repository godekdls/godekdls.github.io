---
title: Helm Installation
navTitle: Helm
category: Spring Cloud Data Flow
order: 12
permalink: /Spring%20Cloud%20Data%20Flow/installation.kubernetes.helm/
description: 헬름 차트를 사용해 쿠버네티스 환경에 Spring Cloud Data Flow 설치하기
image: ./../../images/springclouddataflow/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 클라우드 데이터 플로우
originalRefLink: https://dataflow.spring.io/docs/installation/kubernetes/helm/
parent: Installation
parentUrl: /Spring%20Cloud%20Data%20Flow/installation/
subparent: Kubernetes
subparentUrl: /Spring%20Cloud%20Data%20Flow/installation.kubernetes/
---
<script>defaultLanguages = ['streams']</script>

### 목차

- [Helm Installation](#helm-installation)
  + [Installing Spring Cloud Data Flow Server and Required Services](#installing-spring-cloud-data-flow-server-and-required-services)
- [TL;DR](#tldr)
- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Installing the Chart](#installing-the-chart)
- [Uninstalling the Chart](#uninstalling-the-chart)
- [Parameters](#parameters)
  + [Global parameters](#global-parameters)
  + [Common parameters](#common-parameters)
  + [Dataflow Server parameters](#dataflow-server-parameters)
  + [Dataflow Skipper parameters](#dataflow-skipper-parameters)
  + [Deployer parameters](#deployer-parameters)
  + [RBAC parameters](#rbac-parameters)
  + [Metrics parameters](#metrics-parameters)
  + [Init Container parameters](#init-container-parameters)
  + [Database parameters](#database-parameters)
  + [RabbitMQ chart parameters](#rabbitmq-chart-parameters)
  + [Kafka chart parameters](#kafka-chart-parameters)
- [Configuration and installation details](#configuration-and-installation-details)
  + [Rolling VS Immutable tags](#rolling-vs-immutable-tags)
  + [Features](#features)
  + [Messaging solutions](#messaging-solutions)
  + [Using an external database](#using-an-external-database)
  + [Adding extra flags](#adding-extra-flags)
  + [Using custom Dataflow configuration](#using-custom-dataflow-configuration)
  + [Using custom Skipper configuration](#using-custom-skipper-configuration)
  + [Sidecars and Init Containers](#sidecars-and-init-containers)
  + [Ingress](#ingress)
    * [Hosts](#hosts)
    * [TLS](#tls)
  + [Setting Pod's affinity](#setting-pods-affinity)
- [Troubleshooting](#troubleshooting)
- [Upgrading](#upgrading)
  + [To 4.0.0](#to-400)
  + [To 3.0.0](#to-300)
  + [To 2.0.0](#to-200)
  + [v0.x.x](#v0xx)
  + [v1.x.x](#v1xx)
- [Notable changes](#notable-changes)
  + [v1.0.0](#v100)
    * [Expected output](#expected-output)
    * [Version Compatibility](#version-compatibility)
- [Registering Prebuilt Applications](#registering-prebuilt-applications)
- [Application and Server Properties](#application-and-server-properties)
  + [Memory and CPU Settings](#memory-and-cpu-settings)
  + [Environment Variables](#environment-variables)
  + [Liveness and Readiness Probes](#liveness-and-readiness-probes)
  + [Using SPRING_APPLICATION_JSON](#using-spring_application_json)
  + [Private Docker Registry](#private-docker-registry)
    * [Volume Mounted Secretes](#volume-mounted-secretes)
  + [Annotations](#annotations)
  + [Entry Point Style](#entry-point-style)
  + [Deployment Service Account](#deployment-service-account)
  + [Image Pull Policy](#image-pull-policy)
  + [Deployment Labels](#deployment-labels)
  + [NodePort](#nodeport)
- [Monitoring](#monitoring)

---

## Helm Installation

> Helm 프로젝트는 2020년 11월을 기준으로 Helm 2에 대한 지원을 종료했다. Spring Cloud Data Flow 2.7.0부터는 Helm 2 차트 지원을 중단하고 Helm 3 기반 차트를 사용한다.
>
> Helm 2는 Helm 3로 마이그레이션해야 한다. 마이그레이션을 준비 중이라면 [Helm v2 to v3 마이그레이션 가이드](https://helm.sh/docs/topics/v2_v3_migration/)를 읽어보는 게 좋다. [마이그레이션 이후 만날 수 있는 문제들](https://docs.bitnami.com/tutorials/resolve-helm2-helm3-post-migration-issues/)이란 아티클도 함께 보면 데이터 마이그레이션과 업그레이드에 관련된 유용한 팁을 얻을 수 있다.
>
> Spring Cloud Data Flow 2.6.1부터 헬름 차트는 Bitnami 팀이 관리하고 있다. 버그를 리포팅하거나 기능을 요청하고 싶다면 [Bitnami 이슈 트래커](https://github.com/bitnami/charts/issues)를 사용하면 된다.

Spring Cloud Data Flow는 쿠버네티스 클러스터에 Spring Cloud Data Flow 서버와 필요한 서비스들을 배포할 수 있는 [헬름 차트](https://bitnami.com/stack/spring-cloud-dataflow/helm)를 제공한다.

이어지는 섹션에선 헬름을 초기화하고 쿠버네티스 클러스터에 Spring Cloud Data Flow를 설치하는 방법을 다룬다.

Minikube를 사용한다면 [Minikube 리소스 설정](../installation.kubernetes.creatingcluster#setting-minikube-resources)에서 CPU와 RAM 리소스 요구 사항에 관한 세부 내용을 확인해봐라.

### Installing Spring Cloud Data Flow Server and Required Services

> 아래 문서를 검토한 후엔 자신의 환경에 맞게 파라미터를 커스텀하고, 혹은 레거시 공식 헬름 차트와 다를 수 있는 부분을 조정해줘야 한다. Bitnami 차트를 마이그레이션하면서 값 이름이나 기본값 등이 변경됐을 수 있다. 더 자세한 정보는 [파라미터](#parameters) 테이블과 [업그레이드하기](#upgrading), [주요 변경 사항](#notable-changes) 섹션에서 확인할 수 있다.

# Spring Cloud Data Flow

[Spring Cloud Data Flow](https://dataflow.spring.io/)는 클라우드 파운드리와 쿠버네티스 환경에서 운영할 수 있는 마이크로서비스 기반 스트리밍/배치 데이터 처리 파이프라인이다.

---

## TL;DR

```sh
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-release bitnami/spring-cloud-dataflow
```

---

## Introduction

이 차트는 [헬름](https://helm.sh/) 패키지 매니저를 사용해 [쿠버네티스](http://kubernetes.io/) 클러스터에서 [Spring Cloud Data Flow](https://github.com/bitnami/bitnami-docker-spring-cloud-dataflow) deployment를 부트스트랩한다.

Bitnami 차트는 [Kubeapps](https://kubeapps.com/)와 함께 사용해 클러스터의 헬름 차트를 배포하고 관리해도 된다.

---

## Prerequisites

- Kubernetes 1.12+
- Helm 3.1.0
- 내부 인프라의 PV provisioner 지원

---

## Installing the Chart

이 차트를 릴리즈 이름 `my-release`로 설치하려면:

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-release bitnami/spring-cloud-dataflow
```

이 명령어는 쿠버네티스 클러스터에 디폴트 설정으로 Spring Cloud Data Flow를 배포한다. 설치할 때 설정할 수 있는 파라미터는 [파라미터](#parameters) 섹션에 정리해뒀다.

> **팁**: `helm list`를 사용하면 모든 릴리즈를 보여준다

---

## Uninstalling the Chart

`my-release` 차트를 언인스톨/삭제하려면:

```bash
helm uninstall my-release
```

---

## Parameters

### Global parameters

| Name                      | Description                                           | Value |
| ------------------------- | ----------------------------------------------------- | ----- |
| `global.imageRegistry`    | 글로벌 도커 이미지 레지스트리                         | `""`  |
| `global.imagePullSecrets` | 글로벌 도커 레지시트리 시크릿 이름 (배열)             | `[]`  |
| `global.storageClass`     | Persistent Volume(s)을 위한 글로벌 StorageClass<br /> | `""`  |

### Common parameters

| Name               | Description                                                  | Value           |
| ------------------ | ------------------------------------------------------------ | --------------- |
| `nameOverride`     | scdf.fullname 템플릿을 부분적으로 재정의하는 문자열 (릴리즈 이름은 그대로 유지한다). | `""`            |
| `fullnameOverride` | scdf.fullname 템플릿을 완전히 재정의하는 문자열              | `""`            |
| `kubeVersion`      | 강제할 타겟 쿠버네티스 버전 (설정하지 않으면 Helm에서 세팅)  | `""`            |
| `clusterDomain`    | 디폴트 쿠버네티스 클러스터 도메인                            | `cluster.local` |
| `extraDeploy`      | 해당 릴리즈와 함께 배포할 추가 오브젝트 배열                 | `[]`            |

### Dataflow Server parameters

| Name                                                         | Description                                                  | Value                                                |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ---------------------------------------------------- |
| `server.image.registry`                                      | Spring Cloud Dataflow 이미지 레지스트리                      | `docker.io`                                          |
| `server.image.repository`                                    | Spring Cloud Dataflow 이미지 레포지토리                      | `bitnami/spring-cloud-dataflow`                      |
| `server.image.tag`                                           | Spring Cloud Dataflow 이미지 태그 (immutable tag 권장)       | `2.9.1-debian-10-r0`                                 |
| `server.image.pullPolicy`                                    | Spring Cloud Dataflow 이미지 pull 정책                       | `IfNotPresent`                                       |
| `server.image.pullSecrets`                                   | 도커 레지스트리 시크릿 이름 (배열)                           | `[]`                                                 |
| `server.image.debug`                                         | 이미지 디버그 모드 활성화                                    | `false`                                              |
| `server.hostAliases`                                         | Deployment pod host aliases                                  | `[]`                                                 |
| <code class="highlighter-rouge">server<br />.composedTaskRunner<br />.image.registry</code> | Spring Cloud Dataflow Composed Task Runner 이미지 레지스트리 | `docker.io`                                          |
| <code class="highlighter-rouge">server<br />.composedTaskRunner<br />.image.repository</code> | Spring Cloud Dataflow Composed Task Runner 이미지 레포지토리 | `bitnami/spring-cloud-dataflow-composed-task-runner` |
| <code class="highlighter-rouge">server<br />.composedTaskRunner<br />.image.tag</code> | Spring Cloud Dataflow Composed Task Runner 이미지 태그 (immutable tag 권장) | `2.9.0-debian-10-r17`                                |
| <code class="highlighter-rouge">server.configuration<br />.streamingEnabled</code> | 스트리밍 데이터 처리를 활성화/비활성화                       | `true`                                               |
| <code class="highlighter-rouge">server.configuration<br />.batchEnabled</code> | 배치 데이터 처리를 활성화/비활성화(태스크와 스케줄링)        | `true`                                               |
| <code class="highlighter-rouge">server.configuration<br />.accountName</code> | 쿠버네티스 플랫폼에 설정할 계정 이름                         | `default`                                            |
| <code class="highlighter-rouge">server.configuration<br />.trustK8sCerts</code> | 쿠버네티스 API에 질의할 때 사용할 Trust K8s 인증서           | `false`                                              |
| <code class="highlighter-rouge">server.configuration<br />.containerRegistries</code> | 컨테이너 레지스트리 설정                                     | `{}`                                                 |
| <code class="highlighter-rouge">server.configuration<br />.grafanaInfo</code> | 그라파나 인스턴스 엔드포인트 (Deprecated: 이 파라미터 대신 metricsDashboard를 사용해라) | `""`                                                 |
| <code class="highlighter-rouge">server.configuration<br />.metricsDashboard</code> | metricsDashboard 인스턴스 엔드포인트                         | `""`                                                 |
| <code class="highlighter-rouge">server<br />.existingConfigmap</code> | Spring Cloud Dataflow 서버 설정을 포함하는 ConfigMap         | `""`                                                 |
| `server.extraEnvVars`                                        | Dataflow 서버 컨테이너에 추가로 설정할 환경 변수             | `[]`                                                 |
| `server.extraEnvVarsCM`                                      | 추가 환경 변수를 가지고 있는 ConfigMap                       | `""`                                                 |
| <code class="highlighter-rouge">server<br />.extraEnvVarsSecret</code> | 추가 환경 변수를 가지고 있는 시크릿                          | `""`                                                 |
| `server.replicaCount`                                        | 배포할 Dataflow 서버 레플리카 수                             | `1`                                                  |
| `server.strategyType`                                        | StrategyType, 기본적으론 RollingUpdate나 Recreate로 설정할 수 있다 | `RollingUpdate`                                      |
| <code class="highlighter-rouge">server<br />.podAffinityPreset</code> | Dataflow 서버 포드 affinity 프리셋. `server.affinity`를 설정하면 무시한다. 허용 값: `soft`, `hard` | `""`                                                 |
| <code class="highlighter-rouge">server<br />.podAntiAffinityPreset</code> | Dataflow 서버 포드 anti-affinity 프리셋. `server.affinity`를 설정하면 무시한다. 허용 값: `soft`, `hard` | `soft`                                               |
| `server.containerPort`                                       | Dataflow 서버 포트                                           | `8080`                                               |
| <code class="highlighter-rouge">server<br />.nodeAffinityPreset<br />.type</code> | Dataflow 서버 노드 affinity 프리셋 타입. `server.affinity`를 설정하면 무시한다. 허용 값: `soft`, `hard` | `""`                                                 |
| <code class="highlighter-rouge">server<br />.nodeAffinityPreset<br />.key</code> | 매칭할 Dataflow 서버 노드 레이블 키. Ignored if `server.affinity`를 설정하면 무시한다. | `""`                                                 |
| <code class="highlighter-rouge">server<br />.nodeAffinityPreset<br />.values</code> | 매칭할 Dataflow 서버 노드 레이블 값. Ignored if `server.affinity`를 설정하면 무시한다. | `[]`                                                 |
| `server.affinity`                                            | 포드 할당을 위한 Dataflow 서버 affinity                       | `{}`                                                 |
| `server.nodeSelector`                                        | 포드 할당을 위한  Dataflow 서버 노드 레이블                   | `{}`                                                 |
| `server.tolerations`                                         | 포드 할당을 위한 Dataflow 서버 tolerations                    | `[]`                                                 |
| `server.podAnnotations`                                      | Dataflow 서버 포드들의 어노테이션                              | `{}`                                                 |
| `server.priorityClassName`                                   | Dataflow 서버 포드들의 우선순위                                | `""`                                                 |
| <code class="highlighter-rouge">server<br />.podSecurityContext<br />.fsGroup</code> | 포드의 볼륨 그룹 ID                                           | `1001`                                               |
| <code class="highlighter-rouge">server<br />.containerSecurityContext<br />.runAsUser</code> | Dataflow 서버 컨테이너의 Security Context runAsUser 설정     | `1001`                                               |
| <code class="highlighter-rouge">server.resources<br />.limits</code> | Dataflow 서버 컨테이너의 resources limits                    | `{}`                                                 |
| <code class="highlighter-rouge">server.resources<br />.requests</code> | Dataflow 서버 컨테이너의 requested resources                 | `{}`                                                 |
| <code class="highlighter-rouge">server.livenessProbe<br />.enabled</code> | livenessProbe 활성화                                         | `true`                                               |
| <code class="highlighter-rouge">server.livenessProbe<br />.initialDelaySeconds</code> | livenessProbe의 initial delay seconds                        | `120`                                                |
| <code class="highlighter-rouge">server.livenessProbe<br />.periodSeconds</code> | livenessProbe의 period seconds                               | `20`                                                 |
| <code class="highlighter-rouge">server.livenessProbe<br />.timeoutSeconds</code> | livenessProbe의 timeout seconds                              | `1`                                                  |
| <code class="highlighter-rouge">server.livenessProbe<br />.failureThreshold</code> | livenessProbe의 failure threshold                            | `6`                                                  |
| <code class="highlighter-rouge">server.livenessProbe<br />.successThreshold</code> | livenessProbe의 success threshold                            | `1`                                                  |
| <code class="highlighter-rouge">server.readinessProbe<br />.enabled</code> | readinessProbe 활성화                                        | `true`                                               |
| <code class="highlighter-rouge">server.readinessProbe<br />.initialDelaySeconds</code> | readinessProbe의 initial delay seconds                       | `120`                                                |
| <code class="highlighter-rouge">server.readinessProbe<br />.periodSeconds</code> | readinessProbe의 period seconds                              | `20`                                                 |
| <code class="highlighter-rouge">server.readinessProbe<br />.timeoutSeconds</code> | readinessProbe의 timeout seconds                             | `1`                                                  |
| <code class="highlighter-rouge">server.readinessProbe<br />.failureThreshold</code> | readinessProbe의 failure threshold                           | `6`                                                  |
| <code class="highlighter-rouge">server.readinessProbe<br />.successThreshold</code> | readinessProbe의 success threshold                           | `1`                                                  |
| <code class="highlighter-rouge">server<br />.customLivenessProbe</code> | 디폴트 liveness probe 재정의                                 | `{}`                                                 |
| <code class="highlighter-rouge">server<br />.customReadinessProbe</code> | 디폴트 readiness probe 재정의                                | `{}`                                                 |
| `server.service.type`                                        | 쿠버네티스 서비스 타입                                       | `ClusterIP`                                          |
| `server.service.port`                                        | 서비스 HTTP 포트                                             | `8080`                                               |
| <code class="highlighter-rouge">server.service<br />.nodePort</code> | LoadBalancer를 위한 nodePort 값과 nodePort 서비스 타입 지정  | `""`                                                 |
| <code class="highlighter-rouge">server.service<br />.clusterIP</code> | Dataflow 서버 서비스 클러스터 IP                             | `""`                                                 |
| <code class="highlighter-rouge">server.service<br />.externalTrafficPolicy</code> | 클라이언트 소스 IP 보존 활성화                               | `Cluster`                                            |
| <code class="highlighter-rouge">server.service<br />.loadBalancerIP</code> | 서비스 타입이 `LoadBalancer`인 경우 Load balancer IP         | `""`                                                 |
| <code class="highlighter-rouge">server.service<br />.loadBalancerSourceRanges</code> | 서비스가 `LoadBalancer`인 경우 허용할 주소                   | `[]`                                                 |
| <code class="highlighter-rouge">server.service<br />.annotations</code> | 추가로 필요할만한 어노테이션 제공. 템플릿으로 evaluate한다.  | `{}`                                                 |
| <code class="highlighter-rouge">server.ingress<br />.enabled</code> | 인그레스 컨트롤러 리소스 활성화                           | `false`                                              |
| <code class="highlighter-rouge">server.ingress<br />.path</code> | WordPress를 가리키는 Path. ALB 인그레스 컨트롤러와 함께 사용하려면 이 값을 '/*'로 설정해야 할 수도 있다. | `/`                                                  |
| <code class="highlighter-rouge">server.ingress<br />.pathType</code> | 인그레스 path 타입                                            | `ImplementationSpecific`                             |
| <code class="highlighter-rouge">server.ingress<br />.hostname</code> | 인그레스 리소스를 위한 디폴트 호스트                        | `dataflow.local`                                     |
| <code class="highlighter-rouge">server.ingress<br />.annotations</code> | 인그레스 리소스를 위한 추가 애노테이션. 인증서 자동 생성을 활성화하려면 여기에 cert-manager 어노테이션을 배치해라. | `{}`                                                 |
| <code class="highlighter-rouge">server.ingress<br />.tls</code> | ingress.hostname 파라미터에 정의된 호스트명에 TLS 설정을 활성화 | `false`                                              |
| <code class="highlighter-rouge">server.ingress<br />.extraHosts</code> | 이 인그레스 레코드로 처리할 추가 호스트명 리스트              | `[]`                                                 |
| <code class="highlighter-rouge">server.ingress<br />.extraTls</code> | 이 인그레스 레코드로 처리할 추가 호스트명에 대한 tls 설정     | `[]`                                                 |
| <code class="highlighter-rouge">server.ingress<br />.secrets</code> | 자체 인증서를 제공할 거라면 인증서를 시크릿으로 추가할 땐 이 파라미터를 사용해라. | `[]`                                                 |
| `server.initContainers`                                      | Dataflow 서버 포드에 init container 추가                      | `[]`                                                 |
| `server.sidecars`                                            | Dataflow 서버 포드에 sidecar 추가                             | `[]`                                                 |
| `server.pdb.create`                                          | Pod Disruption Budget 생성을 활성화/비활성화                 | `false`                                              |
| <code class="highlighter-rouge">server.pdb<br />.minAvailable</code> | 예약된 상태로 유지해야 하는 최소 포드 수/백분율               | `1`                                                  |
| <code class="highlighter-rouge">server.pdb<br />.maxUnavailable</code> | 최대 포드 수/백분율. 사용하지 못할 수도 있다.                 | `""`                                                 |
| <code class="highlighter-rouge">server.autoscaling<br />.enabled</code> | Dataflow 서버에 오토 스케일링 활성화                         | `false`                                              |
| <code class="highlighter-rouge">server.autoscaling<br />.minReplicas</code> | Dataflow 서버의 최수 레플리카 수                             | `""`                                                 |
| <code class="highlighter-rouge">server.autoscaling<br />.maxReplicas</code> | Dataflow 서버의 최대 레플리카 수                             | `""`                                                 |
| <code class="highlighter-rouge">server.autoscaling<br />.targetCPU</code> | 목표 CPU 사용률                                              | `""`                                                 |
| <code class="highlighter-rouge">server.autoscaling<br />.targetMemory</code> | 목표 메모리 사용률                                           | `""`                                                 |
| `server.extraVolumes`                                        | Dataflow 서버 포드에 설정할 추가 볼륨                         | `[]`                                                 |
| `server.extraVolumeMounts`                                   | Dataflow 컨테이너에 설정할 추가 VolumeMounts                 | `[]`                                                 |
| `server.jdwp.enabled`                                        | 자바 디버거를 활성화하려면 true로 설정                       | `false`                                              |
| `server.jdwp.port`                                           | 리모트 디버깅을 위한 포트 지정                               | `5005`                                               |
| `server.proxy`                                               | SCDF 서버를 위한 프록시 설정 추가                            | `{}`                                                 |

### Dataflow Skipper parameters

| Name                                                         | Description                                                  | Value                          |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------ |
| `skipper.enabled`                                            | Spring Cloud Skipper 컴포넌트 활성화                         | `true`                         |
| `skipper.hostAliases`                                        | Deployment pod host aliases                                  | `[]`                           |
| `skipper.image.registry`                                     | Spring Cloud Skipper 이미지 레지스트리                       | `docker.io`                    |
| `skipper.image.repository`                                   | Spring Cloud Skipper 이미지 레포지토리                       | `bitnami/spring-cloud-skipper` |
| `skipper.image.tag`                                          | Spring Cloud Skipper 이미지 태그 (immutable tag 권장)        | `2.8.0-debian-10-r15`          |
| `skipper.image.pullPolicy`                                   | Spring Cloud Skipper 이미지 pull 정책                        | `IfNotPresent`                 |
| `skipper.image.pullSecrets`                                  | 도커 레지스트리 시크릿 이름 (배열)                           | `[]`                           |
| `skipper.image.debug`                                        | 이미지 디버그 모드 활성화                                    | `false`                        |
| <code class="highlighter-rouge">skipper.configuration<br />.accountName</code> | 쿠버네티스 플랫폼에 설정할 계정 이름                         | `default`                      |
| <code class="highlighter-rouge">skipper.configuration<br />.trustK8sCerts</code> | 쿠버네티스 API에 질의할 때 사용할 Trust K8s 인증서           | `false`                        |
| `skipper.existingConfigmap`                                  | Skipper 서버 설정을 포함하는 기존 ConfigMap                  | `""`                           |
| `skipper.extraEnvVars`                                       | Skipper 서버 컨테이너에 추가로 설정할 환경 변수              | `[]`                           |
| `skipper.extraEnvVarsCM`                                     | 추가 환경 변수 가지고 있는 기존 ConfigMap 이름               | `""`                           |
| <code class="highlighter-rouge">skipper<br />.extraEnvVarsSecret</code> | 추가 환경 변수를 가지고 있는 기존 시크릿 이름                | `""`                           |
| `skipper.replicaCount`                                       | 배포할 Skipper 서버 레플리카 수                              | `1`                            |
| `skipper.strategyType`                                       | Deployment Strategy Type                                     | `RollingUpdate`                |
| <code class="highlighter-rouge">skipper<br />.podAffinityPreset</code> | Skipper 포드 affinity 프리셋. 시 허용 값: `soft`, `hard` | `""`                           |
| <code class="highlighter-rouge">skipper<br />.podAntiAffinityPreset</code> | Skipper 포드 anti-affinity 프리셋. `skipper.affinity`를 설정하면 무시한다. 허용 값: `soft`, `hard` | `soft`                         |
| <code class="highlighter-rouge">skipper<br />.nodeAffinityPreset<br />.type</code> | Skipper node affinity 프리셋 타입. `skipper.affinity`를 설정하면 무시한다. 허용 값: `soft`, `hard` | `""`                           |
| <code class="highlighter-rouge">skipper<br />.nodeAffinityPreset<br />.key</code> | 매칭할 Skipper 노드 레이블 키. `skipper.affinity`를 설정하면 무시한다. | `""`                           |
| <code class="highlighter-rouge">skipper<br />.nodeAffinityPreset<br />.values</code> | 매칭할 Skipper 노드 레이블 값. `skipper.affinity`를 설정하면 무시한다. | `[]`                           |
| `skipper.affinity`                                           | 포드 할당을 위한 Skipper affinity                             | `{}`                           |
| `skipper.nodeSelector`                                       | 포드 할당을 위한 Skipper 노드 레이블                          | `{}`                           |
| `skipper.tolerations`                                        | 포드 할당을 위한 Skipper tolerations                          | `[]`                           |
| `skipper.podAnnotations`                                     | Skipper 서버 포드의 어노테이션                                | `{}`                           |
| `skipper.priorityClassName`                                  | Controller priorityClassName                                 | `""`                           |
| <code class="highlighter-rouge">skipper<br />.podSecurityContext<br />.fsGroup</code> | 포드 볼륨의 그룹 ID                                           | `1001`                         |
| <code class="highlighter-rouge">skipper<br />.containerSecurityContext<br />.runAsUser</code> | Dataflow Skipper 컨테이너의 Security Context runAsUser 설정  | `1001`                         |
| <code class="highlighter-rouge">skipper.resources<br />.limits</code> | Skipper 서버 컨테이너의 resources limits                     | `{}`                           |
| <code class="highlighter-rouge">skipper.resources<br />.requests</code> | Skipper 서버 컨테이너의 requested resources                  | `{}`                           |
| <code class="highlighter-rouge">skipper.livenessProbe<br />.enabled</code> | livenessProbe 활성화                                         | `true`                         |
| <code class="highlighter-rouge">skipper.livenessProbe<br />.initialDelaySeconds</code> | livenessProbe의 initial delay seconds                        | `120`                          |
| <code class="highlighter-rouge">skipper.livenessProbe<br />.periodSeconds</code> | livenessProbe의 period seconds                               | `20`                           |
| <code class="highlighter-rouge">skipper.livenessProbe<br />.timeoutSeconds</code> | livenessProbe의 timeout seconds                              | `1`                            |
| <code class="highlighter-rouge">skipper.livenessProbe<br />.failureThreshold</code> | livenessProbe의 failure threshold                            | `6`                            |
| <code class="highlighter-rouge">skipper.livenessProbe<br />.successThreshold</code> | livenessProbe의 success threshold                            | `1`                            |
| <code class="highlighter-rouge">skipper.readinessProbe<br />.enabled</code> | Enable readinessProbe 활성화                                 | `true`                         |
| <code class="highlighter-rouge">skipper.readinessProbe<br />.initialDelaySeconds</code> | readinessProbe의 initial delay seconds                       | `120`                          |
| <code class="highlighter-rouge">skipper.readinessProbe<br />.periodSeconds</code> | readinessProbe의 period seconds                              | `20`                           |
| <code class="highlighter-rouge">skipper.readinessProbe<br />.timeoutSeconds</code> | readinessProbe의 timeout seconds                             | `1`                            |
| <code class="highlighter-rouge">skipper.readinessProbe<br />.failureThreshold</code> | readinessProbe의 failure threshold                           | `6`                            |
| <code class="highlighter-rouge">skipper.readinessProbe<br />.successThreshold</code> | readinessProbe의 success threshold                           | `1`                            |
| <code class="highlighter-rouge">skipper<br />.customLivenessProbe</code> | 디폴트 liveness probe 재정의                                 | `{}`                           |
| <code class="highlighter-rouge">skipper<br />.customReadinessProbe</code> | 디폴트 readiness probe 재정의                                | `{}`                           |
| `skipper.service.type`                                       | 쿠버네티스 서비스 타입                                       | `ClusterIP`                    |
| `skipper.service.port`                                       | 서비스 HTTP 포트                                             | `80`                           |
| `skipper.service.nodePort`                                   | 서비스 HTTP 노드 포트                                        | `""`                           |
| `skipper.service.clusterIP`                                  | Skipper 서버 서비스 클러스터 IP                              | `""`                           |
| <code class="highlighter-rouge">skipper.service<br />.externalTrafficPolicy</code> | 클라이언트 소스 IP 보존 활성화                               | `Cluster`                      |
| <code class="highlighter-rouge">skipper.service<br />.loadBalancerIP</code> | 서비스 타입이 `LoadBalancer`인 경우 Load balancer IP         | `""`                           |
| <code class="highlighter-rouge">skipper.service<br />.loadBalancerSourceRanges</code> | 서비스가 `LoadBalancer`인 경우 허용할 주소                   | `[]`                           |
| <code class="highlighter-rouge">skipper.service<br />.annotations</code> | Skipper 서버 서비스의 애노테이션 service                     | `{}`                           |
| `skipper.initContainers`                                     | Dataflow Skipper 포드에 init container 추가                   | `[]`                           |
| `skipper.sidecars`                                           | Skipper 포드에 사이드카 추가                                  | `[]`                           |
| `skipper.pdb.create`                                         | Pod Disruption Budget 생성 활성/비활성화                     | `false`                        |
| <code class="highlighter-rouge">skipper.pdb<br />.minAvailable</code> | 예약된 상태로 유지해야 하는 최수 포드 수/백분율               | `1`                            |
| <code class="highlighter-rouge">skipper.pdb<br />.maxUnavailable</code> | 최대 포드 수/백분율. 사용하지 못할 수도 있다.                 | `""`                           |
| <code class="highlighter-rouge">skipper.autoscaling<br />.enabled</code> | Skipper 서버에 오토 스케일링 활성화                          | `false`                        |
| <code class="highlighter-rouge">skipper.autoscaling<br />.minReplicas</code> | Skipper 서버의 최소 레플리카 수                              | `""`                           |
| <code class="highlighter-rouge">skipper.autoscaling<br />.maxReplicas</code> | Skipper 서버의 최대 레플리카 수                              | `""`                           |
| <code class="highlighter-rouge">skipper.autoscaling<br />.targetCPU</code> | 목표 CPU 사용률                                              | `""`                           |
| <code class="highlighter-rouge">skipper.autoscaling<br />.targetMemory</code> | 목표 메모리 사용률                                           | `""`                           |
| `skipper.extraVolumes`                                       | Skipper 포드에 설정할 추가 볼륨                               | `[]`                           |
| `skipper.extraVolumeMounts`                                  | Skipper 컨테이너에 설정할 추가 VolumeMounts                  | `[]`                           |
| `skipper.jdwp.enabled`                                       | JDWP<sup>Java Debug Wire Protocol</sup> 활성화               | `false`                        |
| `skipper.jdwp.port`                                          | 리모트 디버깅을 위한 JDWP TCP 포트                           | `5005`                         |
| `externalSkipper.host`                                       | 외부 Skipper 서버의 호스트                                   | `localhost`                    |
| `externalSkipper.port`                                       | 외부 Skipper 서버 포트                                       | `7577`                         |

### Deployer parameters

| Name                                                         | Description                                                  | Value  |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------ |
| <code class="highlighter-rouge">deployer<br />.resources.limits</code> | 스트리밍 애플리케이션 resource limits                        | `{}`   |
| <code class="highlighter-rouge">deployer<br />.resources.requests</code> | 스트리밍 애플리케이션 resource requests                      | `{}`   |
| <code class="highlighter-rouge">deployer.livenessProbe<br />.initialDelaySeconds</code> | livenessProbe의 initial delay seconds                        | `90`   |
| <code class="highlighter-rouge">deployer.readinessProbe<br />.initialDelaySeconds</code> | readinessProbe의 initial delay seconds                       | `120`  |
| `deployer.nodeSelector`                                      | 스트리밍 애플리케이션 배포에 적용할 노드 셀렉터("키:값" 형식) | `""`   |
| `deployer.tolerations`                                       | 스트리밍 애플리케이션 tolerations                            | `{}`   |
| `deployer.volumeMounts`                                      | 스트리밍 애플리케이션의 추가 볼륨 마운트                     | `{}`   |
| `deployer.volumes`                                           | 스트리밍 애플리케이션의 추가 볼륨                            | `{}`   |
| <code class="highlighter-rouge">deployer<br />.environmentVariables</code> | 스트리밍 애플리케이션 환경 변수                              | `""`   |
| <code class="highlighter-rouge">deployer<br />.podSecurityContext<br />.runAsUser</code> | Dataflow Streams 컨테이너의 Security Context runAsUser 설정  | `1001` |

### RBAC parameters

| Name                    | Description                                                  | Value  |
| ----------------------- | ------------------------------------------------------------ | ------ |
| `serviceAccount.create` | Dataflow 서버와 Skipper 서버 포드에 ServiceAccount 생성 활성화 | `true` |
| `serviceAccount.name`   | 생성할 serviceAccount 이름                                   | `""`   |
| `rbac.create`           | RBAC 리소스 생성과 사용 여부                                 | `true` |

### Metrics parameters

| Name                                                         | Description                                                  | Value                              |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ---------------------------------- |
| `metrics.enabled`                                            | 프로메테우스 메트릭 활성화                                   | `false`                            |
| `metrics.image.registry`                                     | 프로메테우스 Rsocket 프록시 이미지 레지스트리                | `docker.io`                        |
| `metrics.image.repository`                                   | 프로메테우스 Rsocket 프록시 이미지 레포지토리                | `bitnami/prometheus-rsocket-proxy` |
| `metrics.image.tag`                                          | 프로메테우스 Rsocket 프록시 이미지 태그 (immutable tag 권장) | `1.3.0-debian-10-r306`             |
| `metrics.image.pullPolicy`                                   | 프로메테우스 Rsocket 프록시 이미지 pull 정책                 | `IfNotPresent`                     |
| `metrics.image.pullSecrets`                                  | 도커 레지스트리 시크릿 이름 (배열)                           | `[]`                               |
| `metrics.resources.limits`                                   | 프로메테우스 Rsocket 프록시 컨테이너의 resources limits      | `{}`                               |
| `metrics.resources.requests`                                 | 프로메테우스 Rsocket 프록시 컨테이너의 requested resources   | `{}`                               |
| `metrics.replicaCount`                                       | 배포할 프로메테우스 Rsocket 프록시 레플리카 수               | `1`                                |
| <code class="highlighter-rouge">metrics<br />.podAffinityPreset</code> | 프로메테우스 Rsocket 프록시 포드 affinity 프리셋. `metrics.affinity`를 설정하면 무시한다. 허용 값: `soft`, `hard` | `""`                               |
| <code class="highlighter-rouge">metrics<br />.podAntiAffinityPreset</code> | 프로메테우스 Rsocket 프록시 포드 anti-affinity 프리셋. `metrics.affinity`를 설정하면 무시한다. 허용 값: `soft`, `hard` | `soft`                             |
| <code class="highlighter-rouge">metrics<br />.nodeAffinityPreset<br />.type</code> | 프로메테우스 Rsocket 프록시 노드 affinity 프리셋 타입. `metrics.affinity`를 설정하면 무시한다. 허용 값: `soft`, `hard` | `""`                               |
| <code class="highlighter-rouge">metrics<br />.nodeAffinityPreset<br />.key</code> | 매칭할 프로메테우스 Rsocket 프록시 노드 레이블 키. `metrics.affinity`를 설정하면 무시한다. | `""`                               |
| <code class="highlighter-rouge">metrics<br />.nodeAffinityPreset<br />.values</code> | 매칭할 프로메테우스 Rsocket 프록시 노드 레이블 값. `metrics.affinity`를 설정하면 무시한다. | `[]`                               |
| `metrics.affinity`                                           | 포드 할당을 위한 프로메테우스 Rsocket 프록시 affinity         | `{}`                               |
| `metrics.nodeSelector`                                       | 포드 할당을 위한 프로메테우스 Rsocket 프록시 노드 레이블      | `{}`                               |
| `metrics.tolerations`                                        | 포드 할당을 위한 프로메테우스 Rsocket 프록시 tolerations      | `[]`                               |
| `metrics.podAnnotations`                                     | 프로메테우스 Rsocket 프록시 포드를 위한 애노테이션            | `{}`                               |
| `metrics.priorityClassName`                                  | 프로메테우스 Rsocket 프록시 포드의 우선순위                   | `""`                               |
| `metrics.service.httpPort`                                   | 프로메테우스 Rsocket 프록시 HTTP 포트                        | `8080`                             |
| <code class="highlighter-rouge">metrics.service<br />.rsocketPort</code> | 프로메테우스 Rsocket 프록시 Rsocket 포트                     | `7001`                             |
| <code class="highlighter-rouge">metrics.service<br />.annotations</code> | 프로메테우스 Rsocket 프록시 서비스를 위한 애노테이션         | `{}`                               |
| <code class="highlighter-rouge">metrics.serviceMonitor<br />.enabled</code> | `true`면 Prometheus Operator ServiceMonitor를 생성한다 (`metrics.enabled`도 `true`로 설정돼 있어야 한다) | `false`                            |
| <code class="highlighter-rouge">metrics.serviceMonitor<br />.extraLabels</code> | prometheus operator를 serviceMonitorSelector로 설정한 경우 ServiceMonitor에 추가할 레이블 | `{}`                               |
| <code class="highlighter-rouge">metrics.serviceMonitor<br />.namespace</code> | ServiceMonitor를 생성하는 네임스페이스 (릴리즈와 다른 경우 ) | `""`                               |
| <code class="highlighter-rouge">metrics.serviceMonitor<br />.interval</code> | 메트릭을 스크랩할 간격                                       | `""`                               |
| <code class="highlighter-rouge">metrics.serviceMonitor<br />.scrapeTimeout</code> | 스크랩을 끝낸 후 타임아웃                                    | `""`                               |
| <code class="highlighter-rouge">metrics.pdb<br />.create</code> | Pod Disruption Budget 생성을 활성/비활성화                   | `false`                            |
| <code class="highlighter-rouge">metrics.pdb<br />.minAvailable</code> | 예약된 상태로 유지해야 하는 최소 포드 수/백분율               | `1`                                |
| <code class="highlighter-rouge">metrics.pdb<br />.maxUnavailable</code> | 최대 포드 수/백분율. 사용하지 못할 수도 있다.                 | `""`                               |
| <code class="highlighter-rouge">metrics.autoscaling<br />.enabled</code> | 프로메테우스 Rsocket 프록시에 오토 스케일링 활성화           | `false`                            |
| <code class="highlighter-rouge">metrics.autoscaling<br />.minReplicas</code> | 프로메테우스 Rsocket 프록시의 최소 레플리카 수               | `""`                               |
| <code class="highlighter-rouge">metrics.autoscaling<br />.maxReplicas</code> | 프로메테우스 Rsocket 프록시의 최대 레플리카 수               | `""`                               |
| <code class="highlighter-rouge">metrics.autoscaling<br />.targetCPU</code> | 목표 CPU 사용률                                              | `""`                               |
| <code class="highlighter-rouge">metrics.autoscaling<br />.targetMemory</code> | 목표 메모리 사용률                                           | `""`                               |

### Init Container parameters

| Name                                                         | Description                                                  | Value                  |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ---------------------- |
| `waitForBackends.enabled`                                    | 스트리밍을 활성화할 때 사용하는 데이터베이스와 다른 서비스들을(Kafka, RabbitMQ같은) 기다린다 | `true`                 |
| <code class="highlighter-rouge">waitForBackends.image.registry</code> | Init container wait-for-backend 이미지 레지스트리            | `docker.io`            |
| <code class="highlighter-rouge">waitForBackends<br />.image.repository</code> | Init container wait-for-backend 이미지 이름                  | `bitnami/kubectl`      |
| <code class="highlighter-rouge">waitForBackends<br />.image.tag</code> | Init container wait-for-backend 이미지 태그                  | `1.19.16-debian-10-r0` |
| <code class="highlighter-rouge">waitForBackends<br />.image.pullPolicy</code> | Init container wait-for-backend 이미지 pull 정책             | `IfNotPresent`         |
| <code class="highlighter-rouge">waitForBackends<br />.image.pullSecrets</code> | 도커 레지스트리 시크릿 이름 (배열)                           | `[]`                   |
| <code class="highlighter-rouge">waitForBackends<br />.resources.limits</code> | Init container wait-for-backend resource limits              | `{}`                   |
| <code class="highlighter-rouge">waitForBackends<br />.resources.requests</code> | Init container wait-for-backend resource requests            | `{}`                   |

### Database parameters

| Name                                                         | Description                                                  | Value        |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------ |
| `mariadb.enabled`                                            | MariaDB 차트 인스톨 활성/비활성화                            | `true`       |
| `mariadb.architecture`                                       | MariaDB 아키텍처. 허용 값: `standalone`, `replication`       | `standalone` |
| `mariadb.auth.rootPassword`                                  | MariaDB `root` user password                                 | `""`         |
| `mariadb.auth.username`                                      | 새로 생성할 user의 username                                  | `dataflow`   |
| `mariadb.auth.password`                                      | 새 사용자의 password                                         | `change-me`  |
| `mariadb.auth.database`                                      | 생성할 데이터베이스 이름                                     | `dataflow`   |
| `mariadb.auth.forcePassword`                                 | 데이터베이스에서 사용자가 필수 암호를 지정하도록 강제한다.   | `false`      |
| `mariadb.auth.usePasswordFiles`                              | credential에 환경 변수를 사용하는 대신 파일로 마운트         | `false`      |
| `mariadb.initdbScripts`                                      | 처음 부팅할 때 실행할 스크립트 딕셔너리 지정                 | `{}`         |
| `flyway.enabled`                                             | 기동 시 Dataflow, Skipper 데이터베이스 생성 스크립트를 실행하는 flyway 활성/비활성화 | `true`       |
| `externalDatabase.host`                                      | 외부 데이터베이스 호스트                                     | `localhost`  |
| `externalDatabase.port`                                      | 외부 데이터베이스 포트 넘버                                  | `3306`       |
| `externalDatabase.driver`                                    | JDBC Driver 클래스의 풀 네임<sup>fully qualified name</sup>  | `""`         |
| `externalDatabase.scheme`                                    | 스킴은 URL의 "jdbc:" 다음에 오는 벤더 전용 혹은 공통 프로토콜 문자열이다. | `""`         |
| `externalDatabase.password`                                  | 위 username의 password                                       | `""`         |
| <code class="highlighter-rouge">externalDatabase<br />.existingPasswordSecret</code> | 데이터베이스 password를 가지고 있는 기존 시크릿              | `""`         |
| <code class="highlighter-rouge">externalDatabase<br />.existingPasswordKey</code> | 데이터베이스 password를 가지고 있는 기존 시크릿의 키. 기본값은 `datasource-password`. | `""`         |
| <code class="highlighter-rouge">externalDatabase<br />.dataflow.url</code> | dataflow 서버의 JDBC URL. 외부 스킴, 호스트, 포트, 데이터베이스, jdbc 파라미터들을 재정의한다. | `""`         |
| <code class="highlighter-rouge">externalDatabase<br />.dataflow.database</code> | Dataflow 서버에서 사용할 기존 데이터베이스 이름              | `dataflow`   |
| <code class="highlighter-rouge">externalDatabase<br />.dataflow.username</code> | Dataflow 서버에서 사용할 외부 db의 기존 username             | `dataflow`   |
| <code class="highlighter-rouge">externalDatabase<br />.skipper.url</code> | skipper의 JDBC URL. 외부 스킴, 호스트, 포트, 데이터베이스, jdbc 파라미터들을 재정의한다. | `""`         |
| <code class="highlighter-rouge">externalDatabase<br />.skipper.database</code> | Skipper 서버에서 사용할 기존 데이터베이스 이름               | `skipper`    |
| <code class="highlighter-rouge">externalDatabase<br />.skipper.username</code> | Skipper 서버에서 사용할 외부 db의 기존 username              | `skipper`    |
| <code class="highlighter-rouge">externalDatabase<br />.hibernateDialect</code> | Dataflow/Skipper 서버에서 사용할 하이버네이트 방언<sup>Dialect</sup> | `""`         |

### RabbitMQ chart parameters

| Name                                                         | Description                                                  | Value       |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ----------- |
| `rabbitmq.enabled`                                           | RabbitMQ 차트 인스톨 활성/비활성화                           | `true`      |
| `rabbitmq.auth.username`                                     | RabbitMQ username                                            | `user`      |
| `externalRabbitmq.enabled`                                   | 외부 RabbitMQ 활성/비활성화                                  | `false`     |
| `externalRabbitmq.host`                                      | 외부 RabbitMQ 호스트                                         | `localhost` |
| `externalRabbitmq.port`                                      | 외부 RabbitMQ 포트 넘버                                      | `5672`      |
| `externalRabbitmq.username`                                  | 외부 RabbitMQ username                                       | `guest`     |
| `externalRabbitmq.password`                                  | 외부 RabbitMQ password. 쿠버네티스 시크릿에 저장된다         | `guest`     |
| `externalRabbitmq.vhost`                                     | 외부 RabbitMQ virtual 호스트. 쿠버네티스 시크릿에 저장된다   | `""`        |
| <code class="highlighter-rouge">externalRabbitmq<br />.existingPasswordSecret</code> | RabbitMQ password를 가지고 있는 기존 시크릿. 쿠버네티스 시크릿에 저장된다 | `""`        |

### Kafka chart parameters

| Name                                  | Description                      | Value            |
| ------------------------------------- | -------------------------------- | ---------------- |
| `kafka.enabled`                       | 카프카 차트 인스톨 활성/비활성화 | `false`          |
| `kafka.replicaCount`                  | 카프카 브로커 수                 | `1`              |
| `kafka.offsetsTopicReplicationFactor` | 카프카 시크릿 키                | `1`              |
| `kafka.zookeeper.replicaCount`        | 주키퍼 레플리카 수               | `1`              |
| `externalKafka.enabled`               | 외부 카프카 활성/비활성화        | `false`          |
| `externalKafka.brokers`               | 외부 카프카 브로커               | `localhost:9092` |
| `externalKafka.zkNodes`               | 외부 주키퍼 노드                 | `localhost:2181` |

각 파라미터는 `helm install`에 `--set key=value[,key=value]` 인자를 사용해서 지정한다. 예를 들어,

```bash
helm install my-release --set server.replicaCount=2 bitnami/spring-cloud-dataflow
```

위 명령어는 Dataflow 서버 레플리카 2개를 갖는 Spring Cloud Data Flow 차트를 설치한다.

아니면 차트를 설치할 때 파라미터 값을 지정해둔 YAML 파일을 제공해도 된다. 예를 들어,

```bash
helm install my-release -f values.yaml bitnami/spring-cloud-dataflow
```

> **팁**: 디폴트 [values.yaml](https://github.com/bitnami/charts/blob/master/bitnami/spring-cloud-dataflow/values.yaml)을 활용해도 된다

---

## Configuration and installation details

### [Rolling VS Immutable tags](https://docs.bitnami.com/containers/how-to/understand-rolling-tags-containers/)

프로덕션 환경에선 웬만하면 immutable 태그를 사용하는 게 좋다. 이렇게 하면 동일한 태그가 다른 이미지로 업데이트돼도 자동으로 배포 내용이 변경되지 않는다.

Bitnami에선 메인 컨테이너의 새 버전이 나오거나, 중요한 변경 사항이 생기거나, 심각한 취약점이 있는 경우 해당 컨테이너를 업데이트하는 새 차트를 릴리즈할 거다.

### Features

태스크와 스케줄만 배포해야 한다면 스트리밍과 Skipper는 비활성화할 수 있다:

```properties
server.configuration.batchEnabled=true
server.configuration.streamingEnabled=false
skipper.enabled=false
rabbitmq.enabled=false
```

스트림만 배포해야 할 때는 태스크와 스케줄을 비활성화할 수 있다:

```properties
server.configuration.batchEnabled=false
server.configuration.streamingEnabled=true
skipper.enabled=true
rabbitmq.enabled=true
```

참고: `server.configuration.batchEnabled`와 `server.configuration.streamingEnabled`를 동시에 `false`로 설정하는 건 안 된다.

### Messaging solutions

이 차트에선 두 가지 메세징 솔루션을 지원한다.

- RabbitMQ (디폴트)
- Kafka

메세징 레이어를 카프카로 변경하려면 아래 파라미터를 사용해라:

```properties
rabbitmq.enabled=false
kafka.enabled=true
```

Only one messaging layer can be used at a given time.

현재로썬 하나의 메세징 레이어만 사용할 수 있다.

### Using an external database

간혹 Spring Cloud 컴포넌트에서 연결할 데이터베이스를 클러스터 내부에 설치하기보단 외부 데이터베이스를 사용하고 싶을 수도 있다. 예를 들어 이미 관리 중인 데이터베이스 서비스를 사용하거나, 데이터베이스 서버를 한 개만 실행해두고 모든 애플리케이션에서 사용하고 싶을 수 있다. 이럴땐 차트의 [`externalDatabase` 파라미터](#database-parameters) 아래에 외부 데이터베이스에 대한 credential을 지정할 수 있다. `mariadb.enabled` 옵션으로 MariaDB 인스톨을 비활성화하는 것도 잊지 말자. 예를 들어 아래 파라미터들로 설정할 수 있다:

```properties
mariadb.enabled=false
externalDatabase.scheme=mariadb
externalDatabase.host=myexternalhost
externalDatabase.port=3306
externalDatabase.password=mypassword
externalDatabase.dataflow.user=mydataflowuser
externalDatabase.dataflow.database=mydataflowdatabase
externalDatabase.dataflow.user=myskipperuser
externalDatabase.dataflow.database=myskipperdatabase
```

참고: 이 차트는 개별 프로퍼티들을 사용하면 (스킴, 호스트, 포트, 데이터베이스, 생략 가능한 jdbcParameters), JDBC URL을 `jdbc:{scheme}://{host}:{port}/{database}{jdbcParameters}` 형식으로 맞춘다. 이 URL 포맷은 MariaDB 데이터베이스 드라이브의 포맷을 따르고 있지만, 다른 데이터베이스 벤더에서는 동작하지 않을 수도 있다.

MariaDB가 아닌 다른 데이터베이스 벤더를 사용하려면 `externalDatabase.dataflow.url`과 `externalDatabase.skipper.url` 프로퍼티를 사용해 dataflow 서버와 skipper에 각각 JDBC URL을 제공하면 된다. 이런 프로퍼티들을 정의하면 개별 프로퍼티보다 우선시된다. 다음은 외부 MS SQL Server 데이터베이스를 설정하는 예시다:

```properties
mariadb.enabled=false
externalDatabase.password=mypassword
externalDatabase.dataflow.url=jdbc:sqlserver://mssql-server:1433
externalDatabase.dataflow.user=mydataflowuser
externalDatabase.skipper.url=jdbc:sqlserver://mssql-server:1433
externalDatabase.skipper.user=myskipperuser
externalDatabase.hibernateDialect=org.hibernate.dialect.SQLServer2012Dialect
```

주의: 위와 같이 MariaDB를 비활성화하는 경우엔 *반드시* `externalDatabase` 커넥션을 위한 값들을 제공해야 한다.

### Adding extra flags

Spring Cloud 컴포넌트에 별도 환경 변수를 추가하려는 경우 `XXX.extraEnvs` 파라미터를 활용할 수 있다. 여기서 XXX는 플레이스홀더를 뜻하며, 실제 컴포넌트로 대체해야 한다. 예를 들어 Spring Cloud Data Flow에 별도 플래그를 추가하려면 다음과 같이 설정해주면 된다:

```yaml
server:
  extraEnvs:
    - name: FOO
      value: BAR
```

### Using custom Dataflow configuration

이 helm 차트는 Dataflow 서버에 대한 커스텀 설정을 지원한다.

Dataflow 서버 설정은 컨피그 파일을 통해 `server.existingConfigmap` 파라미터를 외부 ConfigMap으로 설정해서 지정할 수 있다.

### Using custom Skipper configuration

이 helm 차트는 Skipper 서버에 대한 커스텀 설정을 지원한다.

Skipper 서버 설정은 컨피그 파일을 통해 `skipper.existingConfigmap` 파라미터를 외부 ConfigMap으로 설정해서 지정할 수 있다.

### Sidecars and Init Containers

동일한 포드 내에서 Dataflow나 Skipper 컴포넌트같은 (ex. 추가 메트릭이나 로깅 exporter) 다른 컨테이너를 함께 실행해야 하는 경우 `XXX.sidecars` 파라미터를 통하면 된다. 여기서 XXX는 플레이스홀더로 실제 컴포넌트로 교체해야 한다. 원하는 컨테이너를 쿠버네티스 컨테이너 스펙에 따라 정의하면 된다.

```yaml
server:
  sidecars:
    - name: your-image-name
      image: your-image
      imagePullPolicy: Always
      ports:
        - name: portname
          containerPort: 1234
```

별도의 init 컨테이너도 마찬가지로 `XXX.initContainers` 파라미터를 사용해 추가할 수 있다.

```yaml
server:
  initContainers:
    - name: your-image-name
      image: your-image
      imagePullPolicy: Always
      ports:
        - name: portname
          containerPort: 1234
```

### Ingress

이 차트는 인그레스 리소스를 지원한다. 클러스터에 [nginx-ingress](https://kubeapps.com/charts/stable/nginx-ingress)나 [traefik](https://kubeapps.com/charts/stable/traefik)같은 인그레스 컨트롤러를 이미 설치했다면 해당 인그레스 컨트롤러를 활용해 Spring Cloud Data Flow 서버를 서빙할 수 있다.

인그레스 통합을 활성화하려면 `server.ingress.enabled`를 `true`로 설정해라.

#### Hosts

대부분은 이걸로 설치한 Spring Cloud Data Flow에 매핑되는 호스트명이 하나만 있기를 원할 거다. 이런 경우엔 `server.ingress.hostname` 프로퍼티가 이 값을 설정할 거다. 하지만 호스트를 둘 이상 가지는 경우도 있다. 이럴 땐 `server.ingress.extraHosts` 객체를 배열로 지정할 수 있다. `server.ingress.extraTLS`를 사용해 추가 호스트에 대한 TLS 설정을 추가할 수도 있다.

 `server.ingress.extraHosts`에 명시한 각 호스트마다 `name`, `path`와, 인그레스 컨트롤러에 알려주고 싶은 `annotations`를 지정해라.

애노테이션은 [이 문서](https://github.com/kubernetes/ingress-nginx/blob/master/docs/user-guide/nginx-configuration/annotations.md)를 참고해라.  모든 인그레스 컨트롤러가 애노테이션을 전부 지원하는 건 아니지만, 이 문서는 많이 사용하는 다양한 인그레스 컨트롤러에서 어떤 애노테이션을 지원하는지 잘 보여주고 있다.

#### TLS

이 차트는 인그레스 컨트롤러와 함께 사용할 TLS 시크릿을 쉽게 생성할 수 있도록 도와주지만, 시크릿을 꼭 만들어야 하는 건 아니다. 여기에는 일반적인 네 가지 유스 케이스가 있다:

- Helm은 파라미터를 기반으로 인증서 시크릿을 생성/관리한다.

- 사용자가 별도로 인증서를 생성/관리한다.

- Helm은 자체 서명<sup>self-signed</sup> 인증서를 만들고 인증서 시크릿을 생성/관리한다.

- 부가적인 툴로 애플리케이션의 시크릿을 관리한다 ([cert-manager](https://github.com/jetstack/cert-manager/)같은 툴). 

  처음 두 케이스에선 인증서와 키가 필요하다. 키와 인증서는 아래와 같을 거다. 

  인증서 파일은 다음과 같을 거다 (그리고 인증서 체인을 사용한다면 인증서가 둘 이상 있을 수 있다):

  ```tex]
  -----BEGIN CERTIFICATE-----
  MIID6TCCAtGgAwIBAgIJAIaCwivkeB5EMA0GCSqGSIb3DQEBCwUAMFYxCzAJBgNV
  ...
  jScrvkiBO65F46KioCL9h5tDvomdU1aqpI/CBzhvZn1c0ZTf87tGQR8NK7v7
  -----END CERTIFICATE-----
  ```

  키는 다음과 같을 거다:

  ```text
  -----BEGIN RSA PRIVATE KEY-----
  MIIEogIBAAKCAQEAvLYcyu8f3skuRyUgeeNpeDvYBCDcgq+LsWap6zbX5f8oLqp4
  ...
  wrj2wDbCDCFmfqnSJ+dKI3vFLlEz44sAV8jX/kd4Y6ZTQhlLbYc=
  -----END RSA PRIVATE KEY-----
  ```

- 헬름을 사용해 파라미터 기반으로 인증서를 관리할 생각이라면, 이 값들을 전용 `server.ingress.secrets` 항목의 `certificate`와 `key` 값에 붙여넣어라.

- TLS 시크릿을 별도로 관리할 거라면, TLS 시크릿의 이름은 *INGRESS_HOSTNAME-tls*로 생성해야 한다는 점을 알아두자 (여기서 *INGRESS_HOSTNAME*은 플레이스홀더로 `server.ingress.hostname` 파라미터를 사용해 설정한 호스트명으로 대체해야 한다).

- 헬름에서 생성한 자체 서명<sup>self-signed</sup> 인증서를 사용하려면 `server.ingress.tls`를 `true`로, `server.ingress.certManager`를 `false`로 설정해라.

- 클러스터에 TLS 인증서 관리와 발급을 자동화하는 [cert-manager](https://github.com/jetstack/cert-manager)가 추가돼 있다면 `server.ingress.certManager` boolean을 true로 설정해 cert-manager에 해당하는 애노테이션들을 활성화해라.

### Setting Pod's affinity

이 차트에선 `XXX.affinity` 파라미터를 통해 커스텀 affinity를 설정할 수 있다. 포드의 affinity는 [쿠버네티스 문서](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity)를 참고해라.

아니면 [bitnami/common](https://github.com/bitnami/charts/tree/master/bitnami/common#affinities) 차트에서 제공하는 포드 affinity, 포드 anti-affinity, 노드 affinity 프리셋 설정을 사용해도 된다. 이땐 `XXX.podAffinityPreset`, `XXX.podAntiAffinityPreset`, `XXX.nodeAffinityPreset` 파라미터를 설정하면 된다.

---

## Troubleshooting

Bitnami 헬름 차트와 관련해서 흔히 만나는 에러들을 해결하는 방법은 [여기 트러블슈팅 가이드](https://docs.bitnami.com/general/how-to/troubleshoot-helm-chart-issues)를 살펴봐라.

---

## Upgrading

RabbitMQ 차트를 활성화해 Skipper가 스트리밍 콘텐츠를 관리할 메세징 솔루션으로 RabbitMQ를 사용하도록 했다면, 업그레이드할 땐 `rabbitmq.auth.password`와 `rabbitmq.auth.erlangCookie` 파라미터를 설정해야 readiness/liveness 프로브가 제대로 동작한다. RabbitMQ 시크릿에서 password와 Erlang 쿠키를 가져와 다음 아래에 있는 명령어를 실행하면 차트를 업그레이드할 수 있다:

### To 4.0.0

이 메이저 버전에선 서브 카프카 차트를 최신 메이저 버전 14.0.0으로 업데이트한다. 이 버전에서 새로 도입된 변경 사항들은 [여기](https://github.com/bitnami/charts/tree/master/bitnami/kafka#to-1400)에서 자세히 확인할 수 있다.

### To 3.0.0

이 메이저 버전에선 서브 카프카 차트를 최신 메이저 버전 13.0.0으로 업데이트한다. 이 서브 차트의 메이저 버전에 대한 자세한 내용은 [카프카 업그레이드 노트](https://github.com/bitnami/charts/tree/master/bitnami/kafka#to-1300)를 참고해라.

### To 2.0.0

[2020년 11월 13일에 헬름 v2 지원이 공식적으로 종료됨에 따라](https://github.com/helm/charts#status-of-the-project), 이 메이저 버전은 헬름 v3에 추가된 다양한 기능들을 흡수하고 헬름 v2 EOL과 관련해서 헬름 프로젝트 자체와의 일관성을 유지하록 헬름 차트에 필요한 변경 사항을 적용한 버전이다.

**이 메이저 버전에선 어떤 것들이 바뀌었을까?**

- 전 버전들에선 `apiVersion: v1`을 사용하지만 (헬름 2, 3 모두 설치 가능), 이 헬름 차트는 `apiVersion: v2`로 업데이트됐다 (헬름 3에서만 설치 가능). `apiVersion` 필드에 대한 자세한 정보는 [여기](https://helm.sh/docs/topics/charts/#the-apiversion-field)에서 확인할 수 있다.
- 의존성 정보를 *requirements.yaml*에서 *Chart.yaml*로 이동
- `helm dependency update`를 실행하고 나면 이전 *requirements.lock*에서 사용하던 것과 동일한 구조를 가진 *Chart.lock* 파일이 생성된다.
- 모든 Bitnami 헬름 차트에서 *Chart.yaml* 파일에 있는 여러 가지 필드들을 모두 동일하게 알파벳순으로 정렬했다.

**이 버전으로 업그레이드할 때 주의할 점들**

- 이전 버전을 헬름 v3로 설치했다면 아무 문제 없다.
- 이 버전에선 더 이상 헬름 v2를 지원하지 않기 때문에, 헬름 v2를 사용해서 이 버전으로 올리는 시나리오는 지원하지 않는다.
- 구 버전을 헬름 v2로 설치했고 이 버전으론 헬름 v3를 사용해 올리고 싶다면, 헬름 v2에서 v3으로 마이그레이션하는 방법은 [공식 헬름 문서](https://helm.sh/docs/topics/v2_v3_migration/#migration-use-cases)를 참고해라.

**참고하기 좋은 링크들**

- [https://docs.bitnami.com/tutorials/resolve-helm2-helm3-post-migration-issues/](https://docs.bitnami.com/tutorials/resolve-helm2-helm3-post-migration-issues/)
- [https://helm.sh/docs/topics/v2_v3_migration/](https://helm.sh/docs/topics/v2_v3_migration/)
- [https://helm.sh/blog/migrate-from-helm-v2-to-helm-v3/](https://helm.sh/blog/migrate-from-helm-v2-to-helm-v3/)

### v0.x.x

```bash
helm upgrade my-release bitnami/spring-cloud-dataflow --set mariadb.rootUser.password=[MARIADB_ROOT_PASSWORD] --set rabbitmq.auth.password=[RABBITMQ_PASSWORD] --set rabbitmq.auth.erlangCookie=[RABBITMQ_ERLANG_COOKIE]
```

### v1.x.x

```bash
helm upgrade my-release bitnami/spring-cloud-dataflow --set mariadb.auth.rootPassword=[MARIADB_ROOT_PASSWORD] --set rabbitmq.auth.password=[RABBITMQ_PASSWORD] --set rabbitmq.auth.erlangCookie=[RABBITMQ_ERLANG_COOKIE]
```

---

## Notable changes

### v1.0.0

MariaDB 의존성 버전은 새 메이저 버전에서 도입된 몇 가지 기능들과 호환이 되지 않는 이슈가 있었다. 그렇기 때문에 외부 데이터베이스를 사용하는 게 아니라면 이전 버전과의 호환성을 보장하지 않는다. 자세한 내용은 [MariaDB 업그레이드 노트](https://github.com/bitnami/charts/tree/master/bitnami/mariadb#to-800)를 확인해봐라.

`1.0.0`으로 업그레이드하려면 이전 릴리즈에서 MariaDB 데이터를 보관하는 데 사용한 PVC를 재사용해야 한다. 아래 가이드를 따라하면 된다 (아래 예시에선 릴리즈 이름이 `dataflow`라고 가정한다).

> 주의: 이 작업을 시작하기 전에 미리 데이터베이스 백업을 만들어둬라.

현 릴리즈에서 MariaDB 데이터를 보관하는 데 사용한 PVC의 credential과 이름을 가져와라:


```sh
export MARIADB_ROOT_PASSWORD=$(kubectl get secret --namespace default dataflow-mariadb -o jsonpath="{.data.mariadb-root-password}" | base64 --decode)
export MARIADB_PASSWORD=$(kubectl get secret --namespace default dataflow-mariadb -o jsonpath="{.data.mariadb-password}" | base64 --decode)
export MARIADB_PVC=$(kubectl get pvc -l app=mariadb,component=master,release=dataflow -o jsonpath="{.items[0].metadata.name}")
export RABBITMQ_PASSWORD=$(kubectl get secret --namespace default dataflow-rabbitmq -o jsonpath="{.data.rabbitmq-password}" | base64 --decode)
export RABBITMQ_ERLANG_COOKIE=$(kubectl get secret --namespace default dataflow-rabbitmq -o jsonpath="{.data.rabbitmq-erlang-cookie}" | base64 --decode)
```

현재 릴리즈에서 MariaDB를 비활성화하고 Data Flow 레플리카를 0으로 수정해라 (버전은 유지):

```sh
$ helm upgrade dataflow bitnami/spring-cloud-dataflow --version 0.7.4 \
  --set server.replicaCount=0 \
  --set skipper.replicaCount=0 \
  --set mariadb.enabled=false \
  --set rabbitmq.auth.password=$RABBITMQ_PASSWORD \
  --set rabbitmq.auth.erlangCookie=$RABBITMQ_ERLANG_COOKIE
```

마지막으로, 릴리즈를 1.0.0으로 업그레이드하면서 기존 PVC를 재사용하고 MariaDB를 다시 활성화한다:

```sh
$ helm upgrade dataflow bitnami/spring-cloud-dataflow \
  --set mariadb.primary.persistence.existingClaim=$MARIADB_PVC \
  --set mariadb.auth.rootPassword=$MARIADB_ROOT_PASSWORD \
  --set mariadb.auth.password=$MARIADB_PASSWORD \
  --set rabbitmq.auth.password=$RABBITMQ_PASSWORD \
  --set rabbitmq.auth.erlangCookie=$RABBITMQ_ERLANG_COOKIE
```

MariaDB 컨테이너 로그에서 아래와 같은 출력을 볼 수 있을 거다:

```sh
$ kubectl logs $(kubectl get pods -l app.kubernetes.io/instance=dataflow,app.kubernetes.io/name=mariadb,app.kubernetes.io/component=primary -o jsonpath="{.items[0].metadata.name}")
...
mariadb 12:13:24.98 INFO  ==> Using persisted data
mariadb 12:13:25.01 INFO  ==> Running mysql_upgrade
...
```

#### Expected output

`helm install` 명령어를 실행하고 나면 아래와 유사한 출력을 볼 수 있을 거다:

```console
NAME: my-release
LAST DEPLOYED: Sun Nov 22 21:12:29 2020
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
** Please be patient while the chart is being deployed **
```

Spring Cloud Data Flow 차트는 아래 컴포넌트들을 사용해서 배포했다:

- Spring Cloud Data Flow server
- Spring Cloud Skipper server

클러스터 내에선 Spring Cloud Data Flow에 아래 DNS 네임을 통해 액세스할 수 있다:

```console
my-release-spring-cloud-dataflow-server.default.svc.cluster.local (port 8080)
```

클러스터 외부에서 Spring Cloud Data Flow 대시보드에 액세스하려면 아래 명령어를 실행해라:

1. 아래 명령어를 통해 Data Flow 대시보드 URL를 확인한다:

   ```sh
   export SERVICE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].port}" services my-release-spring-cloud-dataflow-server)
   kubectl port-forward --namespace default svc/my-release-spring-cloud-dataflow-server ${SERVICE_PORT}:${SERVICE_PORT} & echo "http://127.0.0.1:${SERVICE_PORT}/dashboard"
   ```
   
2. 브라우저를 열고 위에서 확인한 URL을 통해 Data Flow 대시보드에 접근한다.

> 원한다면 `helm install`에 아래 `set` 인자를 전달해서 Spring Cloud Data Flow 서비스 타입을 변경해도 된다:
>
> ```bash
> --set server.service.type=ServiceType
> ```
>
> 여기서 `ServiceType`은 유효한 서비스 이름이다 (예를 들어 `LoadBalancer`, `NodePort` 등).
>
> LoadBalancer IP를 사용할 수 있기까지 몇 분 정도 소요될 수 있다. `kubectl get svc -w my-release-spring-cloud-dataflow-server`를 실행하면 서버의 상태를 지켜볼 수 있다.

> 로드 밸런서를 지원하지 않는 Minikube를 사용한다면, 다음 명령어를 통해 서버의 URL을 확인할 수 있다:
>
> ```bash
> minikube service --url my-release-spring-cloud-dataflow-server
> ```

이제 쿠버네티스 클러스터의 디폴트 네임스페이스에 새 릴리즈 생성을 완료했다. 해당 애플리케이션과 필요한 서비스들을 시작하려면 데 몇 분 정도 걸린다. `kubectl get pod -w` 명령어를 실행하면 상태를 확인할 수 있다. 모든 포드의 `READY` 컬럼에 `1/1`이 보일 때까지 기다려야 한다.

모든 포드가 준비되면 `http://<SERVICE_ADDRESS>/dashboard`로 Spring Cloud Data Flow 대시보드에 접근할 수 있다. 여기서 `<SERVICE_ADDRESS>`는 앞에서 보여준 `kubectl`이나 `minikube` 명령어에서 반환하는 주소다.

#### Version Compatibility

다음은 헬름 차트 릴리즈별 Spring Cloud Data Flow의 버전 호환성을 정리한 테이블이다:

> 공식 헬름 레포지토리에서 deprecated된 차트들:

| SCDF Version          | Chart Version |
| --------------------- | ------------- |
| SCDF-K8S-Server 1.7.x | 1.0.x         |
| SCDF-K8S-Server 2.0.x | 2.2.x         |
| SCDF-K8S-Server 2.1.x | 2.3.x         |
| SCDF-K8S-Server 2.2.x | 2.4.x         |
| SCDF-K8S-Server 2.3.x | 2.5.x         |
| SCDF-K8S-Server 2.4.x | 2.6.x         |
| SCDF-K8S-Server 2.5.x | 2.7.x         |
| SCDF-K8S-Server 2.6.x | 2.8.x         |

>  Bitnami 차트들:

| SCDF Version          | Chart Version |
| --------------------- | ------------- |
| SCDF-K8S-Server 2.6.x | 1.1.x         |
| SCDF-K8S-Server 2.7.x | 2.0.x         |

---

## Registering Prebuilt Applications

사전에 빌드된 스트리밍 애플리케이션들은 모두:

- 아파치 메이븐 아티팩트 또는 도커 이미지로 사용할 수 있다.
- RabbitMQ나 아파치 카프카를 사용한다.
- 프로메테우스와 InfluxDB를 이용한 모니터링을 지원한다.
- UI와 쉘의 코드 자동 완성에 사용되는 애플리케이션 프로퍼티 메타데이터를 가지고 있다.

애플리케이션들은 `app register` 기능을 통해 개별적으로 등록하거나 `app import` 기능을 통해 그룹으로 등록할 수 있다. 특정 릴리즈에 대해 사전에 빌드된 애플리케이션들의 그룹을 나타내는 `dataflow.spring.io` 링크도 준비되어 있어 처음 시작할 때 활용하기 좋다.

애플리케이션은 UI나 쉘로 등록할 수 있다. 사전 빌드된 애플리케이션을 두 개만 사용하더라도 사전 빌드 애플리케이션의 풀 셋을 등록한다.

쿠버네티스에서 Data Flow를 설치할 땐 RabbitMQ를 기본 메세징 미들웨어로 사용하는 헬름 차트를 사용하면 가장 쉽다. RabbitMQ 애플리케이션을 임포트하는 명령어는 다음과 같다:

```bash
dataflow:>app import --uri https://dataflow.spring.io/rabbitmq-docker-latest
```

메세징 미들웨어로 카프카를 선택한 뒤 헬름 차트에서 `kafka.enabled=true`를 설정했거나 뒤에 나오는 `kubectl` 기반 수동 설치 가이드대로 따라했다면, 위 URL에서 `rabbitmq`를 `kafka`로 변경해라.

> 쿠버네티스 전용 Data Flow 서버에선 `--uri` 프로퍼티로 도커 리소스를 가리켜 등록한 애플리케이션만 지원한다. 하지만 각 애플리케이션에서 지원하는 프로퍼티를 나열해주는 `--metadata-uri` 프로퍼티에선 메이븐 리소스를 지원한다. 예를 들어 아래와 같이 애플리케이션을 등록할 수 있다:
>
> ```bash
>app register --type source --name time --uri docker://springcloudstream/time-source-rabbit:{docker-time-source-rabbit-version} --metadata-uri maven://org.springframework.cloud.stream.app:time-source-rabbit:jar:metadata:{docker-time-source-rabbit-version}
> ```
> 
> 메이븐, HTTP, File 리소스/executable jar로 등록된 애플리케이션은 모두 ***지원하지 않는다*** (`--uri` 프로퍼티에 `maven://`, `http://`, `file://`을 프리픽스로 사용하는 방식).

---

## Application and Server Properties

이 섹션에선 애플리케이션을 커스텀해서 배포하는 방법을 설명한다. 다양한 프로퍼티를 사용해 배포하는 애플리케이션들의 설정을 변경할 수 있다. 프로퍼티는 애플리케이션별로도 적용할 수 있고, 적당한 서버 설정으로 배포하는 모든 애플리케이션에 적용할 수도 있다.

애플리케이션 단위로 설정한 프로퍼티는 항상 서버 설정으로 들어간 프로퍼티보다 우선시된다. 덕분에 서버 수준 글로벌 프로퍼티를 애플리케이션별로 재정의할 수 있다.

배포된 모든 태스크에 적용할 프로퍼티는 `src/kubernetes/server/server-config.yaml` 파일에 정의하며, 스트림에선 `src/kubernetes/skipper/skipper-config-(binder).yaml`에 정의한다. `(binder)`는 사용 중인 메세징 미들웨어로 변경해라 (ex. `rabbit`, `kafka`).

### Memory and CPU Settings

애플리케이션들은 디폴트 메모리, CPU 설정으로 배포된다. 필요하다면 이 값들은 변경할 수 있다. 다음은 `Limits`는 CPU `1000m`, 메모리 `1024Mi`로, `Requests`는 CPU `800m`, 메모리 `640Mi`로 설정하는 예시다:

```properties
deployer.<app>.kubernetes.limits.cpu=1000m
deployer.<app>.kubernetes.limits.memory=1024Mi
deployer.<app>.kubernetes.requests.cpu=800m
deployer.<app>.kubernetes.requests.memory=640Mi
```

이렇게 세팅하면 컨테이너에선 다음과 같은 설정을 사용하게 된다:

```yaml
Limits:
  cpu: 1
  memory: 1Gi
Requests:
  cpu: 800m
  memory: 640Mi
```

`cpu`와 `memory`를 글로벌하게 설정해주는 디폴트 값도 제어할 수 있다.

다음은 스트림과 테스크에서 CPU, 메모리를 설정하는 예시다:

<div class="switch-language-wrapper streams tasks">
<span class="switch-language streams">Streams</span>
<span class="switch-language tasks">Tasks</span>
</div>
<div class="language-only-for-streams streams tasks"></div>
```yaml
data:
  application.yaml: |-
    spring:
      cloud:
        skipper:
          server:
            platform:
              kubernetes:
                accounts:
                  default:
                    limits:
                      memory: 640mi
                      cpu: 500m
```
<div class="language-only-for-tasks streams tasks"></div>
```yaml
data:
  application.yaml: |-
    spring:
      cloud:
        dataflow:
          task:
            platform:
              kubernetes:
                accounts:
                  default:
                    limits:
                      memory: 640mi
                      cpu: 500m
```

지금까지 사용해본 설정은 컨테이너 설정에만 영향을 준다. 컨테이너의 JVM 프로세스 메모리 설정에는 영향이 없다. JVM 메모리 설정을 변경하고 싶으면 환경 변수를 제공하면 된다. 자세한 내용은 다음 섹션을 참고해라.

### Environment Variables

주어진 애플리케이션의 환경 설정을 변경하려면 depolyer 프로퍼티 `spring.cloud.deployer.kubernetes.environmentVariables`를 활용하면 된다. 예를 들어, 프로덕션 설정에서 흔한 요구 사항은 JVM 메모리 인자를 바꾸는 거다. 이럴땐 다음과 같이 `JAVA_TOOL_OPTIONS` 환경 변수를 사용하면 된다:

```properties
deployer.<app>.kubernetes.environmentVariables=JAVA_TOOL_OPTIONS=-Xmx1024m
```

> `environmentVariables` 프로퍼티는 문자열을 콤마로 구분해서 받는다. 환경 변수에 사용할 값 자체에도 콤마로 구분하는 문자열이 있다면 반드시 작은따옴표로 감싸줘야 한다. 예를 들어,
>
> ```properties
> spring.cloud.deployer.kubernetes.environmentVariables=spring.cloud.stream.kafka.binder.brokers='somehost:9092, anotherhost:9093'
> ```

이렇게 하면 지정한 `<app>`에 대한 JVM 메모리 설정을 재정의한다 (`<app>`은 애플리케이션 이름으로 치환해라).

### Liveness and Readiness Probes

`liveness`와 `readiness` 프로브는 각각 `/health`, `/info`라는 경로를 사용한다. 둘 모두 `delay`는 `10`이고, `period`는 각각 `60`과 `10`이다. deployer 프로퍼티를 사용하면 이 기본값을 변경해서 스트림을 배포할 수 있다. liveness와 readiness 프로브는 스트림에만 적용된다.

다음은 deployer 프로퍼티를 통해 `liveness` 프로브를 변경하는 예시다 (`<app>`은 애플리케이션 이름으로 치환):

```properties
deployer.<app>.kubernetes.livenessProbePath=/health
deployer.<app>.kubernetes.livenessProbeDelay=120
deployer.<app>.kubernetes.livenessProbePeriod=20
```

같은 설정을 다음과 같이 스트림에 대한 서버 글로벌 설정으로도 선언할 수 있다:

```yaml
data:
  application.yaml: |-
    spring:
      cloud:
        skipper:
          server:
            platform:
              kubernetes:
                accounts:
                  default:
                    livenessProbePath: /health
                    livenessProbeDelay: 120
                    livenessProbePeriod: 20
```

디폴트 `readiness` 설정도 마찬가지로 `liveness`대신 `readiness`를 사용해 재정의할 수 있다.

기본적으로 프로브 포트는 8080을 사용한다. `liveness`, `readiness` 프로브의 디폴트 포트는 다음과 같이 deployer 프로퍼티를 통해 변경할 수 있다:

```properties
deployer.<app>.kubernetes.readinessProbePort=7000
deployer.<app>.kubernetes.livenessProbePort=7000
```

같은 설정을 다음과 같이 스트림에 대한 글로벌 설정으로도 선언할 수 있다:

```yaml
data:
  application.yaml: |-
    spring:
      cloud:
        skipper:
          server:
            platform:
              kubernetes:
                accounts:
                  default:
                    readinessProbePort: 7000
                    livenessProbePort: 7000
```

> 기본적으로 `liveness`, `readiness` 프로브 경로는 스프링 부트 2.x+ 액츄에이터 엔드포인트를 사용한다. 스프링 부트 1.x 액츄에이터 엔드포인트 경로를 사용하려면 반드시 다음과 같이 `liveness`, `readiness` 값을 변경해야 한다 (`<app>`은 애플리케이션 이름으로 치환):
>
> ```properties
> deployer.<app>.kubernetes.livenessProbePath=/health
> deployer.<app>.kubernetes.readinessProbePath=/info
> ```

아래 프로퍼티를 설정해주면 지정한 애플리케이션에서 자동으로 `liveness`, `readiness` 엔드포인트를 스프링 부트 1.x 디폴트 경로로 설정한다:

```properties
deployer.<app>.kubernetes.bootMajorVersion=1
```

프로브 엔드포인트를 보호 중이라면 [쿠버네티스 시크릿](https://kubernetes.io/docs/concepts/configuration/secret/)에 저장한 credential을 사용해서 액세스할 수 있다. 시크릿 `data` 블록의 `credentials` 키에 credential이 들어 있기만 하면 기존 시크릿을 사용할 수 있다. 프로브 인증은 애플리케이션 단위로 설정할 수 있다. 인증을 활성화하면 `liveness`, `readiness` 프로브 엔드포인트에 동일한 credential과 인증 유형을 통해 적용된다. 현재는 `Basic`  인증만 지원한다.

시크릿을 새로 생성하려면:

1. 보호 중인 프로브 엔드포인트에 접근할 때 사용할 credential로 base64 문자열을 생성한다.

   Basic 인증은 username과 password를 `username:password` 형식의 base64 문자열로 인코딩한다.

   다음은 base64 문자열을 생성하는 방법을 보여주는 예시다 (출력 결과도 포함되어 있으며, `user`와 `pass`는 가지고 있는 값으로 바꿔야 한다):

   ```bash
   echo -n "user:pass" | base64
   dXNlcjpwYXNz
   ```

2. 이 인코딩된 credential을 사용해 다음 내용을 포함하는 파일을 생성해라 (ex. `myprobesecret.yml`):

   ```yaml
   apiVersion: v1
   kind: Secret
   metadata:
   name:
   myprobesecret type:
   Opaque data:
   credentials: GENERATED_BASE64_STRING
   ```

3. `GENERATED_BASE64_STRING`을 앞에서 만든 base64 인코딩 값으로 바꿔라.

4. 다음과 같이 `kubectl`을 사용해 시크릿을 생성한다:

   ```bash
   kubectl create -f ./myprobesecret.yml
   secret "myprobesecret" created
   ```

5. 프로브 엔드포인트에 액세스할 때 인증을 수행하도록 아래 deployer 프로퍼티를 설정해라:

   ```properties
   deployer.<app>.kubernetes.probeCredentialsSecret=myprobesecret
   ```

   `<app>`은 인증을 적용할 애플리케이션 이름으로 치환해라.

### Using `SPRING_APPLICATION_JSON`

`SPRING_APPLICATION_JSON` 환경 변수를 사용하면 모든 Data Flow 서버 구현체에서 공통으로 사용할 Data Flow 서버 프로퍼티를 설정할 수 있다 (메이븐 레포지토리와 관련된 설정도 포함). 이 설정들은 서버 수준으로 이동해 deployment YAML의 컨테이너 `env` 섹션에 세팅된다. 설정 방법은 다음 예제를 참고해라:

```yaml
env:
  - name: SPRING_APPLICATION_JSON
    value: |-
    {
      "maven": {
        "local-repository": null,
        "remote-repositories": {
          "repo1": {
            "url": "https://repo.spring.io/libs-snapshot"
          }
        }
      }
    }
```

### Private Docker Registry

도커 이미지를 가져올 private 레지스트리는 애플리케이션 단위로 설정할 수 있다. 먼저 클러스터에 시크릿을 생성해야 한다. 시크릿 생성은 [Private 레지스트리에서 이미지 가져오기](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/) 가이드를 보고 따라하면 된다.

시크릿을 만들었다면 다음과 같이 `imagePullSecret` 프로퍼티를 통해 사용할 시크릿을 설정할 수 있다:

```properties
deployer.<app>.kubernetes.imagePullSecret=mysecret
```

`<app>`은 애플리케이션 이름으로, `mysecret`은 앞서 생성한 시크릿 이름으로 치환해라.

이미지 pull 시크릿은 글로벌 서버 수준으로도 설정할 수 있다.

다음은 스트림과 태스크에서 설정하는 예시다:

<div class="switch-language-wrapper streams tasks">
<span class="switch-language streams">Streams (Skipper configuration)</span>
<span class="switch-language tasks">Tasks (DataFlow configuration)</span>
</div>
<div class="language-only-for-streams streams tasks"></div>
```yaml
data:
  application.yaml: |-
    spring:
      cloud:
        skipper:
          server:
            platform:
              kubernetes:
                accounts:
                  default:
                    imagePullSecret: mysecret
```
<div class="language-only-for-tasks streams tasks"></div>
```yaml
data:
  application.yaml: |-
    spring:
      cloud:
        dataflow:
          task:
            platform:
              kubernetes:
                accounts:
                  default:
                    imagePullSecret: mysecret
```

`mysecret`은 앞서 생성한 시크릿 이름으로 치환해라.

#### Volume Mounted Secretes

Data Flow는 컨테이너 이미지 레이블에 저장돼 있는 [애플리케이션 메타데이터](https://dataflow.spring.io/docs/applications/application-metadata/)를 사용한다. private 레지스트리에 있는 메타데이터 레이블에 액세스하려면 Data Flow 배포 설정을 확장해 레지스트리 시크릿을 [Secrets PropertySource](https://cloud.spring.io/spring-cloud-static/spring-cloud-kubernetes/2.0.0.M1/reference/html/#secrets-propertysource)로 마운트해야 한다:

```yaml
    spec:
      containers:
      - name: scdf-server
        ...
        volumeMounts:
          - name: mysecret
            mountPath: /etc/secrets/mysecret
            readOnly: true
        ...
      volumes:
        - name: mysecret
          secret:
            secretName: mysecret
```

### Annotations

애플리케이션 단위로 쿠버네티스 오브젝트에 애노테이션을 추가할 수 있다. 지원하는 오브젝트 타입은 포드 `Deployment`, `Service`, `Job`이다. 애노테이션은 `key:value` 형식으로 정의하며, 여러 가지 애노테이션을 콤마로 구분해서 지정할 수 있다. 애노테이션에 대한 자세한 정보와 유스 케이스는 [Annotations](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/)를 참고해라.

다음은 애플리케이션에서 애노테이션을 사용하도록 설정하는 예시다:

```properties
deployer.<app>.kubernetes.podAnnotations=annotationName:annotationValue
deployer.<app>.kubernetes.serviceAnnotations=annotationName:annotationValue,annotationName2:annotationValue2
deployer.<app>.kubernetes.jobAnnotations=annotationName:annotationValue
```

`<app>`은 애플리케이션 이름으로 바꿔야 하며, 애노테이션 값을 변경해서 사용하면 된다.

### Entry Point Style

엔트리 포인트 스타일에 따라 배포하는 컨테이너에 애플리케이션 프로퍼티를 전달하는 방식이 달라진다. 현재 지원하는 스타일은 세 가지가 있다:

- `exec` (디폴트): 배포 요청에 들어 있는 모든 애플리케이션 프로퍼티와 커맨드라인 인자를 컨테이너 인자로 전달한다. 애플리케이션 프로퍼티는 `--key=value` 형식으로 변환된다.
- `shell`: 모든 애플리케이션 프로퍼티와 커맨드라인 인자를 환경 변수로 전달한다. 각 애플리케이션, 커맨드라인 인자 프로퍼티는 대문자 문자열로 변환되며 `.` 문자는 `_`로 치환한다.
- `boot`: 모든 애플리케이션 프로퍼티를 JSON으로 가지고 있는 `SPRING_APPLICATION_JSON`이란 환경 변수를 생성한다. 배포 요청의 커맨드라인 인자는 컨테이너 인자로 설정된다.

> 컨테이너에서 도커 `shell` 엔트리 포인트 사용할 거라면 [도커 문서](https://docs.docker.com/engine/reference/builder/#entrypoint)에서도 말하고 있듯이 애플리케이션의 SIGTERM에 끼치는 영향을 알고 있어야 한다.

> 세 가지 케이스 모두 서버 수준 설정과 애플리케이션 단위에 정의한 환경 변수는 컨테이너에 그대로 설정된다.

애플리케이션에는 다음과 같이 설정한다:

```properties
deployer.<app>.kubernetes.entryPointStyle=<Entry Point Style>
```

`<app>`은 애플리케이션 이름으로, `<Entry Point Style>`을 원하는 엔트리 포인트 스타일로 교체해라.

글로벌 서버 레벨에도 엔트리 포인트 스타일을 설정할 수 있다.

다음은 스트림을 위한 전역 설정 예시다:

```yaml
data:
  application.yaml: |-
    spring:
      cloud:
        skipper:
          server:
            platform:
              kubernetes:
                accounts:
                  default:
                    entryPointStyle: entryPointStyle
```

다음은 태스크를 위한 전역 설정 예시다:

```yaml
data:
  application.yaml: |-
    spring:
      cloud:
        dataflow:
          task:
            platform:
              kubernetes:
                accounts:
                  default:
                    entryPointStyle: entryPointStyle
```

`entryPointStyle`을 원하는 엔트리 포인트 스타일로 교체해라.

컨테이너의 `Dockerfile`에서 `ENTRYPOINT` 구문을 정의한 방식에 따라 `exec`, `shell` 중 하나의 엔트리 포인트 스타일을 선택해야 한다. `exec`와 `shell`에 관한 자세한 정보와 유스 케이스는 도커 문서에 있는 [ENTRYPOINT](https://docs.docker.com/engine/reference/builder/#entrypoint) 섹션을 참고해라.

`boot` 엔트리 포인트 스타일는 `exec` 스타일 `ENTRYPOINT`를 사용하는 것과 부합한다. 배포 요청에 있는 커맨드라인 인자는, 컨테이너로 전달될 때 애플리케이션 프로퍼티를 커맨드라인 인자가 아닌 환경 변수 `SPRING_APPLICATION_JSON`에 매핑해서 함께 전달된다.

> 스프링 배치/부트 애플리케이션을 기동할 땐 `exec` 엔트리 포인트 스타일을 사용하거나 애플리케이션 자체에서 job 파라미터를 설정하는 자체 방법을 마련하는 게 좋다. `shell` 엔트리 포인트 스타일은 커맨드라인 args를 환경 변수로 변환하기 때문에, 스프링 부트에서 커맨드라인 args로 job 파라미터를 생성할 수 없기 때문이다. 해당 로직은 [여기](https://github.com/spring-projects/spring-boot/blob/master/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/batch/JobLauncherApplicationRunner.java)에서 확인할 수 있다.

> `boot` 엔트리 포인트 스타일을 사용할 땐 `deployer.<app>.kubernetes.environmentVariables` 프로퍼티에 직접  `SPRING_APPLICATION_JSON`을 추가하면 안 된다.

### Deployment Service Account

애플리케이션 배포에 사용할 커스텀 서비스 어카운트는 프로퍼티를 통해 설정할 수 있다. 기존 서비스 어카운트를 사용해도 되고, 어카운트를 새로 하나 만들어도 된다. 서비스 어카운트를 만드는 한 가지 방법은 다음과 같이 `kubectl`을 사용하는 거다:

```sh
kubectl create serviceaccount myserviceaccountname
serviceaccount "myserviceaccountname" created
```

그런 다음 애플리케이션들을 개별적으로 설정해줄 수 있다:

```properties
deployer.<app>.kubernetes.deploymentServiceAccountName=myserviceaccountname
```

`<app>`은 애플리케이션 이름으로, `myserviceaccountname`은 서비스 어카운트 이름으로 치환해라.

서비스 어카운트 이름은 글로벌 서버 수준에서도 설정할 수 있다.

다음은 스트림을 위한 전역 설정 예시다:

```yaml
data:
  application.yaml: |-
    spring:
      cloud:
        skipper:
          server:
            platform:
              kubernetes:
                accounts:
                  default:
                    deploymentServiceAccountName: myserviceaccountname
```

다음은 태스크를 위한 전역 설정 예시다:

```yaml
data:
  application.yaml: |-
    spring:
      cloud:
        dataflow:
          task:
            platform:
              kubernetes:
                accounts:
                  default:
                    deploymentServiceAccountName: myserviceaccountname
```

`myserviceaccountname`은 모든 배포에 적용할 서비스 어카운트 이름으로 치환해라.

### Image Pull Policy

이미지 pull 정책은 도커 이미지를 언제 로컬 레지스트리로 가져올지를 정의한다. 현재 지원하는 정책은 세 가지가 있다:

- `IfNotPresent` (디폴트): 이미지가 이미 존재할 땐 다시 가져오지 않는다.
- `Always`: 이미지의 존재 여부와는 상관 없이 항상 새로 가져온다.
- `Never`: 이미지를 일절 가져오지 않는다. 이미 존재하는 이미지만 사용한다.

다음은 각 애플리케이션을 개별적으로 설정하는 예시다:

```properties
deployer.<app>.kubernetes.imagePullPolicy=Always
```

`<app>`은 애플리케이션 이름으로, `Always`는 원하는 이미지 pull 정책으로 교체해라.

이미지 pull 정책은 글로벌 서버 수준에서도 설정할 수 있다.

다음은 스트림을 위한 전역 설정 예시다:

```yaml
data:
  application.yaml: |-
    spring:
      cloud:
        skipper:
          server:
            platform:
              kubernetes:
                accounts:
                  default:
                    imagePullPolicy: Always
```

다음은 태스크를 위한 전역 설정 예시다:

```yaml
data:
  application.yaml: |-
    spring:
      cloud:
        dataflow:
          task:
            platform:
              kubernetes:
                accounts:
                  default:
                    imagePullPolicy: Always
```

`Always`는 원하는 이미지 pull 정책으로 교체해라.

### Deployment Labels

[Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)와 관련된 오브젝트에는 커스텀 레이블을 설정할 수 있다. 레이블에 대한 자세한 내용은 [Labels](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/)를 참고해라. 레이블은 `key:value` 형식으로 지정한다.

다음은 각 애플리케이션을 개별적으로 설정하는 예시다:

```properties
deployer.<app>.kubernetes.deploymentLabels=myLabelName:myLabelValue
```

`<app>`은 애플리케이션 이름으로, `myLabelName`는 원하는 레이블 이름으로, `myLabelValue`는 원하는 레이블 값으로 교체해라.

추가로 다음과 같이 여러 가지 레이블도 적용할 수 있다:

```properties
deployer.<app>.kubernetes.deploymentLabels=myLabelName:myLabelValue,myLabelName2:myLabelValue2
```

### NodePort

`Service` 타입을 따로 지정하지 않으면 애플리케이션은 쿠버네티스의 디폴트 `Service` 타입 [ClusterIP](https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types)로 배포된다. `ClusterIP` 서비스는 해당 클러스터 안에서만 접근할 수 있다.

배포한 애플리케이션을 외부에서 사용할 수 있도록 노출하는 한 가지 옵션은 `NodePort`를 사용하는 거다. 자세한 내용은 [NodePort](https://kubernetes.io/docs/concepts/services-networking/service/#type-nodeport) 문서를 참고해라.

다음은 각 애플리케이션을 쿠버네티스가 할당하는 포트를 사용해 설정하는 예시다:

```properties
deployer.<app>.kubernetes.createNodePort=true
```

`<app>`은 애플리케이션 이름으로 치환해라.

다음과 같이 `NodePort` `Service`에서 사용할 포트를 정의할 수도 있다:

```properties
deployer.<app>.kubernetes.createNodePort=31101
```

`<app>`은 애플리케이션 이름으로, `31101`는 원하는 포트로 교체해라.

> 포트를 직접 정의할 때는 해당 포트는 반드시 사용 중이지 않아야 하며, 정의된 `NodePort`범위 내에 있어야 한다. [NodePort](https://kubernetes.io/docs/concepts/services-networking/service/#type-nodeport)의 기본 포트 범위는 30000-32767이다.

---

## Monitoring

쿠버네티스에서 실행하는 프로메테우스를 이용한 Data Flow 모니터링 경험에 대해 자세히 알아보려면 [스트림 모니터링](../feature-guides.stream.monitoring#kubernetes) 가이드나 [태스크 모니터링](../feature-guides.batch.monitoring#kubernetes) 가이드를 참고해라.