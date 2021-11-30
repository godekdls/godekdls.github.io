---
title: Kubernetes Deployment
category: Spring Cloud Data Flow
order: 30
permalink: /Spring%20Cloud%20Data%20Flow/stream-developer-guides.stream-development.stream-application-deployment.kubernetes/
description: 샘플 스트림 애플리케이션을 쿠버네티스 환경에 수동으로 배포하기
image: ./../../images/springclouddataflow/logo.png
lastmod: 2021-12-02T00:33:00+09:00
comments: true
originalRefName: 스프링 클라우드 데이터 플로우
originalRefLink: https://dataflow.spring.io/docs/stream-developer-guides/streams/deployment/kubernetes/
parent: Stream Developer guides
parentUrl: /Spring%20Cloud%20Data%20Flow/stream-developer-guides/
subparent: Stream Development
subparentUrl: /Spring%20Cloud%20Data%20Flow/stream-developer-guides.stream-development/
navDisplay: false
---

---

[샘플 스트림 애플리케이션들](../stream-developer-guides.stream-development.stream-application-development)을 설정해 빌드하고, 지원하는 메세지 브로커 중에 하나를 골라 함께 실행되도록 설정을 완료했다면, 이 애플리케이션들은 쿠버네티스 클러스터 환경에서 독립형으로 실행할 수 있다.

이번 섹션에선 이 세 가지 Spring Cloud Stream 애플리케이션을 쿠버네티스 환경에 배포하는 방법을 안내한다.

### 목차

- [Setting up the Kubernetes Cluster](#setting-up-the-kubernetes-cluster)
  + [Verifying Minikube is Running](#verifying-minikube-is-running)
  + [Building Docker Images](#building-docker-images)
  + [Installing Message Broker](#installing-apache-kafka)
    * [Installing Apache Kafka](#installing-apache-kafka)
    + [Installing RabbitMQ](#installing-rabbitmq)
  + [Deploying the Stream](#deploying-the-stream)
    * [Deploying the Stream with Apache Kafka](#deploying-the-stream-with-apache-kafka)
    * [Deploying the Stream with RabbitMQ](#deploying-the-stream-with-rabbitmq)
  + [Verifying the Deployment](#verifying-the-deployment)
  + [Clean Up](#clean-up)

---

## Setting up the Kubernetes Cluster

이 예제를 따라해보려면 실행 중인 [쿠버네티스 클러스터](../installation.kubernetes.creatingcluster/)가 필요하다. 여기서는 `minikube`에 배포한다.

### Verifying Minikube is Running

Minikube가 실행되고 있는지 확인하려면 아래 명령어를 실행해라 (Minikube가 실행 중일 때 볼 수 있는 전형적인 출력 결과도 함께 표기했다):

```bash
$minikube status

host: Running
kubelet: Running
apiserver: Running
kubectl: Correctly Configured: pointing to minikube-vm at 192.168.99.100
```

### Building Docker Images

도커 이미지를 빌드할 땐 [스프링 부트 메이븐 플러그인](https://docs.spring.io/spring-boot/docs/current/maven-plugin/reference/htmlsingle/#build-image)을 사용한다.

처음부터 부트 메이븐 플러그인을 사용해 앱을 빌드한다면 디폴트 설정으로 잘 동작할 거다.

이제 메이븐 빌드를 실행해서 `minikube` 도커 레지스트리에 도커 이미지를 생성할 수 있다. 다음 명령어를 실행하면 된다:

```bash
$ eval $(minikube docker-env)
$./mvnw spring-boot:build-image
```

프로젝트 소스를 다운로드받았다면 단일 명령어로 모든 모듈을 빌드할 수 있는 parent pom이 프로젝트에 들어있을 거다. 그 외는 소스, 프로세서, 싱크마다 개별적으로 빌드해라. `eval $(minikube docker-env)`는 각 터미널 세션에서 한 번만 실행하면 된다.

> 프로젝트 소스에서 `-Pkafka`나 `-Prabbit`을 사용해 빌드한다면 해당 바인더 의존성이 이미지에 포함된다. 특정 메세지 브로커를 사용하는 이미지를 빌드하고 싶다면 아래 명령어를 사용해라:
>
> ```sh
> ./mvnw clean spring-boot:build-image -P<broker>
> ```

### Installing Message Broker

#### Installing Apache Kafka

이제 Spring Cloud Data Flow의 디폴트 설정을 사용해 카프카 메세지 브로커를 설치할 차례다. 다음 명령어를 실행하면 된다:

```bash
kubectl apply -f https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow/v2.9.1/src/kubernetes/kafka/kafka-deployment.yaml \
-f https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow/v2.9.1/src/kubernetes/kafka/kafka-svc.yaml \
-f https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow/v2.9.1/src/kubernetes/kafka/kafka-zk-deployment.yaml \
-f https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow/v2.9.1/src/kubernetes/kafka/kafka-zk-svc.yaml
```

#### Installing RabbitMQ

RabbitMQ 메세지 브로커도 Spring Cloud Data Flow의 디폴트 설정을 사용해 설치할 수 있다. 다음 명령어를 실행하면 된다:

```bash
kubectl apply -f https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow/v2.9.1/src/kubernetes/rabbitmq/rabbitmq-deployment.yaml \
-f https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow/v2.9.1/src/kubernetes/rabbitmq/rabbitmq-svc.yaml
```

### Deploying the Stream

#### Deploying the Stream with Apache Kafka

스트림을 배포하려면 먼저 아래 YAML을 `usage-cost-stream.yaml`에 복사해넣고 저장해야 한다:

```yaml
kind: Pod
apiVersion: v1
metadata:
  name: usage-detail-sender
  labels:
    app: usage-cost-stream
spec:
  containers:
    - name: usage-detail-sender
      image: usage-detail-sender:0.0.1-SNAPSHOT
      env:
        - name: SPRING_CLOUD_STREAM_KAFKA_BINDER_BROKERS
          value: kafka
        - name: SPRING_CLOUD_STREAM_BINDINGS_OUTPUT_DESTINATION
          value: user-details
---
kind: Pod
apiVersion: v1
metadata:
  name: usage-cost-processor
  labels:
    app: usage-cost-stream
spec:
  containers:
    - name: usage-cost-processor
      image: usage-cost-processor:0.0.1-SNAPSHOT
      ports:
        - containerPort: 80
          protocol: TCP
      env:
        - name: SPRING_CLOUD_STREAM_KAFKA_BINDER_BROKERS
          value: kafka
        - name: SPRING_CLOUD_STREAM_BINDINGS_INPUT_GROUP
          value: usage-cost-stream
        - name: SPRING_CLOUD_STREAM_BINDINGS_INPUT_DESTINATION
          value: user-details
        - name: SPRING_CLOUD_STREAM_BINDINGS_OUTPUT_DESTINATION
          value: user-cost
---
kind: Pod
apiVersion: v1
metadata:
  name: usage-cost-logger
  labels:
    app: usage-cost-stream
spec:
  containers:
    - name: usage-cost-logger
      image: usage-cost-logger:0.0.1-SNAPSHOT
      env:
        - name: SPRING_CLOUD_STREAM_KAFKA_BINDER_BROKERS
          value: kafka
        - name: SPRING_CLOUD_STREAM_BINDINGS_INPUT_GROUP
          value: usage-cost-stream
        - name: SPRING_CLOUD_STREAM_BINDINGS_INPUT_DESTINATION
          value: user-cost
```

그런 다음 아래 명령어를 실행해 이 앱들을 배포해야 한다:

```bash
kubectl apply -f usage-cost-stream.yaml
```

모두 정상적으로 배포됐다면 아래와 같은 출력을 확인할 수 있을 거다:

```sh
pod/usage-detail-sender created
pod/usage-cost-processor created
pod/usage-cost-logger created
```

위 YAML은 소스, 프로세서, 싱크 애플리케이션을 위한 3개의 포드 리소스를 명시하고 있다. 각 포드는 해당 도커 이미지를 참조하는 단일 컨테이너를 가지고 있다.

카프카 바인딩 파라미터는 환경 변수로 설정한다. 스트림을 연결하려면 입출력 목적지이 이름이 정확해야 한다. 특히, 소스의 출력은 프로세서의 입력과 같아야 하고, 프로세서의 출력은 싱크의 입력과 같아야 한다. 또한 각 애플리케이션이 연결할 수 있게 카프카 브로커에 논리적인 호스트명을 설정했다. 여기서는 카프카 서비스 이름 `kafka`를 사용한다. 이 앱들을 논리적으로 그룹핑할 수 있도록 `app: usage-cost-stream` 레이블을 설정했다.

Spring Cloud Stream 바인딩 파라미터도 환경 변수로 설정한다. 스트림을 연결하려면 입출력 목적지 이름이 정확해야 한다. 특히, 소스의 출력은 프로세서의 입력과 같아야 하고, 프로세서의 출력은 싱크의 입력과 같아야 한다. 입력과 출력은 다음과 같이 설정한다:

- Usage Detail Sender: `SPRING_CLOUD_STREAM_BINDINGS_OUTPUT_DESTINATION=user-details`
- Usage Cost Processor: `SPRING_CLOUD_STREAM_BINDINGS_INPUT_DESTINATION=user-details`, `SPRING_CLOUD_STREAM_BINDINGS_OUTPUT_DESTINATION=user-cost`
- Usage Cost Logger: `SPRING_CLOUD_STREAM_BINDINGS_INPUT_DESTINATION=user-cost`

#### Deploying the Stream with RabbitMQ

스트림을 배포하려면 먼저 아래 YAML을 `usage-cost-stream.yaml`에 복사해넣고 저장해야 한다:

```yaml
kind: Pod
apiVersion: v1
metadata:
  name: usage-detail-sender
  labels:
    app: usage-cost-stream
spec:
  containers:
    - name: usage-detail-sender
      image: usage-detail-sender:0.0.1-SNAPSHOT
      env:
        - name: SPRING_RABBITMQ_ADDRESSES
          value: rabbitmq

---
kind: Pod
apiVersion: v1
metadata:
  name: usage-cost-processor
  labels:
    app: usage-cost-stream
spec:
  containers:
    - name: usage-cost-processor
      image: usage-cost-processor:0.0.1-SNAPSHOT
      env:
        - name: SPRING_RABBITMQ_ADDRESSES
          value: rabbitmq
---
kind: Pod
apiVersion: v1
metadata:
  name: usage-cost-logger
  labels:
    app: usage-cost-stream
spec:
  containers:
    - name: usage-cost-logger
      image: usage-cost-logger:0.0.1-SNAPSHOT
      env:
        - name: SPRING_RABBITMQ_ADDRESSES
          value: rabbitmq
```

그런 다음엔 이 앱들을 배포해야 한다:

```bash
kubectl apply -f usage-cost-stream.yaml
```

모두 정상적으로 배포됐다면 아래와 같은 출력을 확인할 수 있을 거다:

```sh
pod/usage-detail-sender created
pod/usage-cost-processor created
pod/usage-cost-logger created
```

위 YAML은 소스, 프로세서, 싱크 애플리케이션을 위한 3개의 포드 리소스를 명시하고 있다. 각 포드는 각자의 도커 이미지를 참조하는 단일 컨테이너를 가지고 있다.

RabbitMQ 브로커는 앱들이 연결할 수 있도록 논리적인 호스트명을 설정한다. 여기서는 RabbitMQ 서비스 이름(`rabbitmq`)을 사용한다. 또한 앱을 논리적으로 그룹핑할 수 있도록 `app: usage-cost-stream` 레이블을 설정했다.


### Verifying the Deployment

배포가 잘 되었는지 보려면 아래 명령어로 `usage-cost-logger` 싱크 로그를 추적해보면 된다.

```bash
kubectl logs -f usage-cost-logger
```

아래 스트리밍과 유사한 메세지를 볼 수 있을 거다:

```bash
2021-03-05 17:40:52.280  INFO 1 --- [fOjmHePqc5VWA-1] i.s.d.s.u.UsageCostLogger     : {"userId": "user5", "callCost": "28.1", "dataCost": "7.3500000000000005" }
2021-03-05 17:40:53.279  INFO 1 --- [fOjmHePqc5VWA-1] i.s.d.s.u.UsageCostLogger     : {"userId": "user2", "callCost": "21.400000000000002", "dataCost": "22.900000000000002" }
2021-03-05 17:40:54.279  INFO 1 --- [fOjmHePqc5VWA-1] i.s.d.s.u.UsageCostLogger     : {"userId": "user3", "callCost": "0.7000000000000001", "dataCost": "26.35" }
2021-03-05 17:40:55.281  INFO 1 --- [fOjmHePqc5VWA-1] i.s.d.s.u.UsageCostLogger     : {"userId": "user5", "callCost": "17.5", "dataCost": "25.8" }
2021-03-05 17:40:56.286  INFO 1 --- [fOjmHePqc5VWA-1] i.s.d.s.u.UsageCostLogger     : {"userId": "user3", "callCost": "25.3", "dataCost": "3.0" }
2021-03-05 17:40:57.289  INFO 1 --- [fOjmHePqc5VWA-1] i.s.d.s.u.UsageCostLogger     : {"userId": "user4", "callCost": "6.300000000000001", "dataCost": "19.700000000000003" }
2021-03-05 17:40:58.290  INFO 1 --- [fOjmHePqc5VWA-1] i.s.d.s.u.UsageCostLogger     : {"userId": "user4", "callCost": "1.4000000000000001", "dataCost": "19.6" }
```

### Clean Up

스트림을 삭제하려면, 다음과 같이 앞에서 생성한 레이블을 이용하면 된다:

```bash
kubectl delete pod -l app=usage-cost-stream
```

또는

```bash
kubectl delete -f usage-cost-stream.yaml
```

RabbitMQ를 삭제하려면 아래 명령어를 실행해라:

```bash
kubectl delete all -l app=rabbitmq
```

카프카를 삭제하려면 아래 명령어를 실행해라:

```bash
kubectl delete all -l app=kafka
```