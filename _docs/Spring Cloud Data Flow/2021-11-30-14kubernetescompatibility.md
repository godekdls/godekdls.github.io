---
title: Kubernetes Compatibility
category: Spring Cloud Data Flow
order: 14
permalink: /Spring%20Cloud%20Data%20Flow/installation.kubernetes.compatibility/
description: 쿠버네티스 버전에 따른 Spring Cloud Data Flow 서버, deployer 호환성
image: ./../../images/springclouddataflow/logo.png
lastmod: 2021-12-02T00:33:00+09:00
comments: true
originalRefName: 스프링 클라우드 데이터 플로우
originalRefLink: https://dataflow.spring.io/docs/installation/kubernetes/compatibility/
parent: Installation
parentUrl: /Spring%20Cloud%20Data%20Flow/installation/
subparent: Kubernetes
subparentUrl: /Spring%20Cloud%20Data%20Flow/installation.kubernetes/
---

---

쿠버네티스 전용 Spring Cloud Data Flow 구현체는 오케스트레이션을 위해 [Spring Cloud Deployer Kubernetes](https://github.com/spring-cloud/spring-cloud-deployer-kubernetes) 라이브러리를 사용한다. 쿠버네티스 클러스터 세팅을 시작하기 전에 먼저 [호환성 매트릭스](https://github.com/spring-cloud/spring-cloud-deployer-kubernetes#kubernetes-compatibility)를 참고해 쿠버네티스 릴리즈 버전별 deployer와 서버 호환성에 대해 자세히 알아봐라.

다음은 쿠버네티스 전용 Spring Cloud Data Flow 서버와 쿠버네티스 버전 간의 호환성을 간략하게 나타낸 테이블이다:

|                                              | k8s 1.11.x | k8s 1.12.x | k8s 1.13.x | k8s 1.14.x | k8s 1.15.x | k8s 1.16.x | k8s 1.17.x | k8s 1.18.x | k8s 1.19.x |
| -------------------------------------------- | ----------------- | ----------------- | ----------------- | ----------------- | ----------------- | ----------------- | ----------------- | ----------------- | ----------------- |
| SCDF K8S Server: 2.8.x<br/>K8S Deployer: 2.6.x | ❌                 | ❌                 | ❌                 | ❌                 | ❌                 | ✅                 | ✅                 | ✅                 | ✅                 |
| SCDF K8S Server: 2.7.x<br/>K8S Deployer: 2.5.x | ❌                 | ❌                 | ❌                 | ❌                 | ❌                 | ✅                 | ✅                 | ✅                 | ✅                 |
| SCDF K8S Server: 2.6.x<br/>K8S Deployer: 2.4.x | ❌                 | ❌                 | ❌                 | ❌                 | ❌                 | ✅                 | ✅                 | ✅                 | ✅                 |
| SCDF K8S Server: 2.5.x<br/>K8S Deployer: 2.3.x | ❌                 | ❌                 | ✅                 | ✅                 | ✅                 | ✅                 | ✅                 | ✅                 | ✅                 |
| SCDF K8S Server: 2.4.x<br/>K8S Deployer: 2.2.x | ❌                 | ❌                 | ✅                 | ✅                 | ✅                 | ❌                 | ❌                 | ❌                 | ❌                 |
| SCDF K8S Server: 2.3.x<br/>K8S Deployer: 2.1.x | ✅                 | ✅                 | ✅                 | ❌                 | ❌                 | ❌                 | ❌                 | ❌                 | ❌                 |
| SCDF K8S Server: 2.2.x<br/>K8S Deployer: 2.0.x | ✅                 | ✅                 | ✅                 | ❌                 | ❌                 | ❌                 | ❌                 | ❌                 | ❌                 |