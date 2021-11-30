---
title: Deploying a task application on Kubernetes with Data Flow
category: Spring Cloud Data Flow
order: 49
permalink: /Spring%20Cloud%20Data%20Flow/batch-developer-guides.batch-development.data-flow-simple-task-kubernetes/
description: 쿠버네티스 환경에서 Data Flow를 이용해 Spring Cloud Task 애플리케이션을 배포하고 실행해보기
image: ./../../images/springclouddataflow/logo.png
lastmod: 2021-12-02T00:33:00+09:00
comments: true
originalRefName: 스프링 클라우드 데이터 플로우
originalRefLink: https://dataflow.spring.io/docs/batch-developer-guides/batch/data-flow-simple-task-kubernetes/
parent: Batch Developer guides
parentUrl: /Spring%20Cloud%20Data%20Flow/batch-developer-guides/
subparent: Batch Development
subparentUrl: /Spring%20Cloud%20Data%20Flow/batch-developer-guides.batch-development/
---

---

이 가이드에선 쿠버네티스 환경에서 Spring Cloud Data Flow를 이용해 간단한 [spring-cloud-task](https://spring.io/projects/spring-cloud-task) 애플리케이션을 배포하고 실행하는 방법을 안내한다.

샘플 [billsetuptask](../batch-developer-guides.batch-development.simple-task) 애플리케이션을 쿠버네티스에 배포해본다.

### 목차

- [Setting up SCDF the Kubernetes Cluster](#setting-up-scdf-the-kubernetes-cluster)
  + [Verifying that Spring Cloud Data Flow is Running](#verifying-that-spring-cloud-data-flow-is-running)
  + [Building a Docker Image for the Sample Task Application](#building-a-docker-image-for-the-sample-task-application)
  + [Registering, Creating, and Launching the Task by Using Data Flow](#registering-creating-and-launching-the-task-by-using-data-flow)

---

## Setting up SCDF the Kubernetes Cluster

이 가이드에선 [Spring Cloud Data Flow를 배포해서 실행 중인 쿠버네티스 클러스터](../installation.kubernetes)가 필요하다. 여기 예제에선 `minikube`를 사용한다.

### Verifying that Spring Cloud Data Flow is Running

쿠버네티스에서 SCDF가 실행 중이라면 `Running` 상태에 있는 `scdf-server` 포드와 관련 서비스가 만들어진 것을 볼 수 있을 거다. `scdf-server`는 다음 명령어로 조회할 수 있다 (전형적인 출력 문구도 함께 표기했다):

```bash
$ kubectl get all -l app=scdf-server
NAME                              READY   STATUS    RESTARTS   AGE
pod/scdf-server-65789665d-79hrz   1/1     Running   0          5m39s

NAME                  TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
service/scdf-server   LoadBalancer   10.109.181.91   <pending>     80:30403/TCP   5m39s

NAME                          READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/scdf-server   1/1     1            1           5m39s

NAME                                    DESIRED   CURRENT   READY   AGE
replicaset.apps/scdf-server-65789665d   1         1         1       5m39s
```

> *참고*: Minikube에선 `service`에 `EXTERNAL-IP = <pending>`이 보이는 건 정상이다.

### Building a Docker Image for the Sample Task Application

`billsetuptask` 앱은 설정돼 있는 [jib 메이븐 플러그인](https://github.com/GoogleContainerTools/jib/tree/master/jib-maven-plugin#build-your-image)으로 빌드한다. 그러려면:

1. 태스크 샘플 git repo를 클론받거나 다운로드받아 `billsetuptask` 디렉토리로 이동한다.

2. 아래 명령어를 실행해 도커 이미지를 빌드한다:

   ```bash
   $ eval $(minikube docker-env)
   $ ./mvnw clean package jib:dockerBuild
   ```

   이 명령어들은 `minikube` 도커 레지스트리에 이미지를 추가한다.

3. 이미지가 잘 추가되었는지 검증하려면, 다음 명령어를 실행해서 보여지는 이미지 목록에서 `springcloudtask/billsetuptask`가 있는지 확인하면 된다.

   ```bash
   $ docker images
   ```

### Registering, Creating, and Launching the Task by Using Data Flow

`Data Flow Dashboard`를 사용해 `billsetuptask` 애플리케이션을 세팅하고 기동시켜보자.

먼저, 다음 명령어를 통해 SCDF 서버 URL을 가져와야 한다 (출력 문구도 함께 표기했다):

```bash
$ minikube service --url scdf-server
http://192.168.99.100:30403
```

이제 애플리케이션 등록을 위해 방금 빌드한 도커 이미지를 사용해서, 가이드를 따라 [Data Flow를 이용해서 태스크 애플리케이션을 등록하고 시작](../batch-developer-guides.batch-development.data-flow-simple-task)하면 된다.