---
title: Creating a Cluster
category: Spring Cloud Data Flow
order: 11
permalink: /Spring%20Cloud%20Data%20Flow/installation.kubernetes.creatingcluster/
description: 쿠버네티스 클러스터 생성하기
image: ./../../images/springclouddataflow/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 클라우드 데이터 플로우
originalRefLink: https://dataflow.spring.io/docs/installation/kubernetes/creating-a-cluster/
parent: Installation
parentUrl: /Spring%20Cloud%20Data%20Flow/installation/
subparent: Kubernetes
subparentUrl: /Spring%20Cloud%20Data%20Flow/installation.kubernetes/
---

---

쿠버네티스엔 여러 가지 옵션이 있지만, [알맞은 솔루션 고르기](https://kubernetes.io/docs/setup/#production-environment) 가이드를 보면 원하는 옵션을 선택할 수 있을 거다. 가장 사용하기 편한 것을 선택하면 된다.

모든 테스트는 [Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine/)과 [Pivotal Container Service](https://pivotal.io/platform/pivotal-container-service/)에서 진행했다. 이 섹션에선 GKE를 타겟 플랫폼으로 사용한다.

---

## Setting Minikube Resources

우리는 [Minikube](https://kubernetes.io/docs/getting-started-guides/minikube/)를 사용해 배포를 마쳐봤다. Minikube에 배포할 때 조정해야 하는 부분을 짚어보겠다.

Minikube를 시작할 땐 여러 가지 서비스를 배포할 거기 때문에 별도로 리소스를 더 할당해야 한다. 처음엔 `minikube start --cpus=4 --memory=8192`로 시작하면 된다. Minikube VM에 할당된 메모리와 CPU는 스트림이나 태스크에 배포하는 애플리케이션 수만큼 사용하게 된다. 애플리케이션을 더 추가할수록 더 많은 VM 리소스가 필요하다.

이후에는 쿠버네티스 클러스터와 `kubectl` 커맨드라인 유틸리티가 동작하고 있다고 가정한다. 설치 가이드가 필요하다면 [kubectl 설치와 세팅](https://kubernetes.io/docs/user-guide/prereqs/)을 참고해라.

