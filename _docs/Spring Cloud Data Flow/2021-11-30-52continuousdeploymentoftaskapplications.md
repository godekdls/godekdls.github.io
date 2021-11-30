---
title: Continuous Deployment of Task Applications
category: Spring Cloud Data Flow
order: 52
permalink: /Spring%20Cloud%20Data%20Flow/batch-developer-guides.continuous-deployment.task-applications/
description: 태스크 애플리케이션들의 버전을 관리하고, 중단 없이 배포하고, 스케줄링하기
image: ./../../images/springclouddataflow/scdf-task-default-version.webp
lastmod: 2021-12-02T00:33:00+09:00
comments: true
originalRefName: 스프링 클라우드 데이터 플로우
originalRefLink: https://dataflow.spring.io/docs/batch-developer-guides/continuous-deployment/cd-basics/
parent: Batch Developer guides
parentUrl: /Spring%20Cloud%20Data%20Flow/batch-developer-guides/
subparent: Continuous Deployment
subparentUrl: /Spring%20Cloud%20Data%20Flow/batch-developer-guides.continuous-deployment/
---

---

태스크 애플리케이션이 발전하게 되면 그에 따라 프로덕션에 업데이트를 반영하고 싶을 거다. 여기서 말하는 변경 사항은 태스크 애플리케이션의 버그를 수정한 새 버전이거나, 이전 태스크 실행과는 다른 배포 프로퍼티를 설정하는 걸 수도 있다.

SCDF에 태스크 애플리케이션을 등록하면 일반적으로 버전 하나가 애플리케이션에 연결된다. 태스크 애플리케이션은 여러  가지 버전에 연결될 수 있으며, 그 중 하나는 기본값으로 선택돼 있을 거다. 다음은 여러 가지 버전이 연결된 애플리케이션을 보여주는 이미지다 (timestamp 앱을 주목).

![Registering Task Applications with multiple Versions](./../../images/springclouddataflow/scdf-task-application-versions.webp)

이름과 좌표<sup>coordinates</sup>가 같고 *버전만 다른* 애플리케이션을 여러 번 등록하면, SCDF에서 애플리케이션의 버전들을 관리해준다. 예를 들어, 아래 있는 값을 사용해 애플리케이션을 등록하면 두 가지 버전(2.0.0.RELEASE와 2.1.0.RELEASE)을 갖는 하나의 애플리케이션이 등록된다:

- **Application 1**

  이름: `timestamp`<br>타입: `task`<br>URI: `maven://org.springframework.cloud.task.app:timestamp-task:2.0.0.RELEASE`

- **Application 2**

  이름: `timestamp`<br>타입: `task`<br>
  URI: `maven://org.springframework.cloud.task.app:timestamp-task:2.1.0.RELEASE`

여러 가지 버전을 관리하는 것 외에도, Spring Cloud Data Flow는 다음 실행 시 사용할 버전을 알고 있어야 한다. 다음에 사용할 버전은 디폴트 버전으로 설정하는 식으로 표현한다. 디폴트 버전으로 설정한 태스크 애플리케이션의 버전이 무엇이든 다음 실행 요청에 사용한다. 어떤 버전이 디폴트인지는 UI에서 확인할 수 있다:

![Task Application Default Version](./../../images/springclouddataflow/scdf-task-default-version.webp)

### 목차

- [Task Launch Lifecycle](#task-launch-lifecycle)
  + [Launch a Task With No Changes](#launch-a-task-with-no-changes)
  + [Launch a Task With Changes That Is Not Currently Running](#launch-a-task-with-changes-that-is-not-currently-running)
  + [Launch a Task With Changes While Another Instance Is Running](#launch-a-task-with-changes-while-another-instance-is-running)
  + [Example of Continuous Deployment](#example-of-continuous-deployment)
- [Scheduling Lifecycle](#scheduling-lifecycle)
  + [Scheduling on Cloud Foundry](#scheduling-on-cloud-foundry)
  + [Scheduling on Kubernetes](#scheduling-on-kubernetes)

---

## Task Launch Lifecycle

SCDF에서 태스크의 CD를 지원하기 전에는, Spring Cloud Data Flow는 단순히 태스크 시작 요청을 받으면 (필요 시) 애플리케이션을 배포하고서 실행했다. 애플리케이션을 매번 배포할 필요 없는 플랫폼(ex. Cloud Foundry)에서 실행할 때는 먼저 배포했던 애플리케이션을 사용했다. 이 플로우은 2.3부터 달라졌다. 다음은 태스크 시작 요청을 받으면 현재에는 어떤 일이 일어나는지를 보여주는 이미지다:

![Flow For Launching A Task](./../../images/springclouddataflow/scdf-task-launch-flow.webp)

위 다이어그램에선 세 가지 메인 플로우를 살펴봐야 한다:

- 최초 실행이거나 변경 없이 그대로 실행
- 변경 사항이 있지만 태스크가 이미 실행 중이 아닐 때
- 변경 사항이 있지만 태스크가 이미 실행 중일 때

먼저 변경 사항이 없는 플로우부터 살펴보겠다.

### Launch a Task With No Changes

1. Data Flow에 시작 요청이 들어온다. 변경 사항이 없기 때문에 (마지막 실행 이후 앱 프로퍼티, 배포 프로터티, 버전이 아무것도 변경되지 않음) Data Flow는 업그레이드가 필요하지 않다고 판단한다.
2. 배포된 아티팩트를 캐싱하는 플랫폼에선 (이 글을 쓰는 시점엔 클라우드 파운드리), Data Flow는 애플리케이션이 이전에 배포되었던 적이 있는지 확인한다.
3. 애플리케이션을 배포해야 한다면, Data Flow는 해당 태스크 애플리케이션을 배포한다.
4. Data Flow에서 애플리케이션을 시작한다.

이 플로우는 디폴트 동작으로, 아무 것도 변경되지 않은 채로 요청이 들어올 때마다 일어나는 일이다. 참고로, CD 지원 이전에 Data Flow가 무조건 태스크를 실행시켰을 때와 동일한 플로우다.

### Launch a Task With Changes That Is Not Currently Running

두 번째로 고려해볼 태스크 시작 플로우는 태스크 애플리케이션 버전이나 애플리케이션 프로퍼티, 배포 프로퍼티에 변경 사항이 있는지다. 이럴 땐 아래 플로우대로 진행된다:

1. Data Flow에 시작 요청이 들어온다. 태스크 애플리케이션 버전이나 애플리케이션 프로퍼티, 배포 프로퍼티에 변경 사항이 있으므로 Data Flow는 업그레이드가 필요하다고 판단한다.
2. Data Flow는 해당 태스크 정의를 현재 다른 인스턴스에서 실행 중인지를 확인한다.
3. 해당 태스크 정의에서 현재 실행 중인 다른 인스턴스가 없다면, 이전 배포를 삭제한다.
4. 배포된 아티팩트를 캐싱하는 플랫폼에선 (이 글을 쓰는 시점엔 클라우드 파운드리), Data Flow는 애플리케이션이 이전에 배포된 내역이 있는지 확인한다 (이전 배포는 삭제되었기 때문에 이 플로우에선 `false`로 판단한다).
5. Data Flow는 업데이트된 값(새 애플리케이션 버전, 새로 병합된 프로퍼티, 새로 병합한 배포 프로퍼티)을 사용해 태스크 애플리케이션을 배포한다.
6. Data Flow에서 애플리케이션을 시작한다.

근본적으로 이 플로우 덕분에 Spring Cloud Data Flow에서 continuous deployment가 가능하다.

### Launch a Task With Changes While Another Instance Is Running

마지막 메인 플로우는 Spring Cloud Data Flow에 시작 요청이 들어와 업그레이드가 필요하지만, 태스크 정의가 현재 실행 중인 경우다. 이땐 태스크를 새로 실행하려면 현재 애플리케이션을 삭제해야 하기 때문에 실행을 차단시킨다. 일부 플랫폼에선 (이 글을 쓰는 시점엔 클라우드 파운드리), 애플리케이션을 삭제하면 현재 실행 중인 모든 애플리케이션들이 종료된다. 차단하는 덕분에 이런 상황을 방지할 수 있다. 다른 인스턴스가 실행 중일 때 태스크가 변경되면 아래 프로세스대로 진행된다:

1. Data Flow에 시작 요청이 들어온다. 태스크 애플리케이션 버전이나 애플리케이션 프로퍼티, 배포 프로퍼티에 변경 사항이 있으므로 Data Flow는 업그레이드가 필요하다고 판단한다.
2. Data Flow는 해당 태스크 정의를 현재 다른 인스턴스에서 실행 중인지를 확인한다.
2. Data Flow는 해당 태스크 정의를 다른 인스턴스에서 실행 중이기 때문에 태스크가 시작되지 않도록 막는다.

참고: 요청 시점에 이미 실행 중인 태스크 정의에 업그레이드가 필요한 상항이라면, 현재 실행 중인 태스크들을 삭제해야 하기 때문에, 이런 성격의 실행 요청은 전부 차단한다.

### Example of Continuous Deployment

이제 `timestamp` 애플리케이션을 `2.1.0.RELEASE`, `2.1.1.RELEASE`, 이렇게 두 가지 버전으로 `Application Registry`에 등록했다고 해보자.

```bash
dataflow:>app list --id task:timestamp
╔═══╤══════╤═════════╤════╤═══════════════════════════╗
║app│source│processor│sink│           task            ║
╠═══╪══════╪═════════╪════╪═══════════════════════════╣
║   │      │         │    │> timestamp-2.1.0.RELEASE <║
║   │      │         │    │timestamp-2.1.1.RELEASE    ║
╚═══╧══════╧═════════╧════╧═══════════════════════════╝
```

이 태스크 애플리케이션 `timestamp`는 현재 태스크를 시작할 땐 `2.1.0.RELEASE` 버전을 디폴트로 사용한다.

등록해둔 `timestamp` 애플리케이션을 사용해 `demo1`이라는 태스크를 만들어보자:

```bash
dataflow:>task create demo1 --definition "timestamp"
Created new task 'demo1'
```

배포 프로퍼티를 설정해서 `demo1` 태스크를 시작해보자:

```bash
dataflow:>task launch demo1 --properties "app.timestamp.format=YYYY"
Launched task 'demo1' with execution id 1
```

태스크가 시작되면 `task execution status`로 애플리케이션 버전에 `2.1.0.RELEASE`를 사용했는지를 검증할 수 있다.

```bash
dataflow:>task execution status 1
╔══════════════════════╤═══════════════════════════════════════════════════════════════════════════════════╗
║         Key          │                                       Value                                       ║
╠══════════════════════╪═══════════════════════════════════════════════════════════════════════════════════╣
║Id                    │1                                                                                  ║
║Resource URL          │org.springframework.cloud.task.app:timestamp-task:jar:2.1.0.RELEASE                ║
║Name                  │demo1                                                                              ║
║CLI Arguments         │[--spring.cloud.data.flow.platformname=default, --spring.cloud.task.executionid=1] ║
║App Arguments         │                 timestamp.format = YYYY                                           ║
║                      │       spring.datasource.username = ******                                         ║
║                      │           spring.cloud.task.name = demo1                                          ║
║                      │            spring.datasource.url = ******                                         ║
║                      │spring.datasource.driverClassName = org.h2.Driver                                  ║
║Deployment Properties │app.timestamp.format = YYYY                                                        ║
║Job Execution Ids     │[]                                                                                 ║
║Start Time            │Wed May 20 20:50:40 IST 2020                                                       ║
║End Time              │Wed May 20 20:50:40 IST 2020                                                       ║
║Exit Code             │0                                                                                  ║
║Exit Message          │                                                                                   ║
║Error Message         │                                                                                   ║
║External Execution Id │demo1-87a6e434-33ce-4b09-9f14-6b1892b6c135                                         ║
╚══════════════════════╧═══════════════════════════════════════════════════════════════════════════════════╝
```

이제 `timestamp` 애플리케이션의 디폴트 버전을 `2.1.1.RELEASE`로 변경해보자.

```bash
dataflow:>app default --id task:timestamp --version 2.1.1.RELEASE
New default Application task:timestamp:2.1.1.RELEASE
```

잘 바뀌었는지는 다음과 같이 확인할 수 있다:

```bash
dataflow:>app list --id task:timestamp
╔═══╤══════╤═════════╤════╤═══════════════════════════╗
║app│source│processor│sink│           task            ║
╠═══╪══════╪═════════╪════╪═══════════════════════════╣
║   │      │         │    │timestamp-2.1.0.RELEASE    ║
║   │      │         │    │> timestamp-2.1.1.RELEASE <║
╚═══╧══════╧═════════╧════╧═══════════════════════════╝
```

이제 `timestamp` 애플리케이션의 디폴트 버전은 `2.1.1.RELEASE`를 사용하도록 설정됐다. 즉, 이 시간 이후로 `timestamp` 애플리케이션을 실행하면 이전 디폴트 버전(`2.1.0.RELEASE`)대신 `2.1.1.RELEASE`를 사용한다.

```bash
dataflow:>task launch demo1
Launched task 'demo1' with execution id 2
```

다시 task execution status로 검증해보면 된다:

```bash
dataflow:>task execution status 2
╔══════════════════════╤═══════════════════════════════════════════════════════════════════════════════════╗
║         Key          │                                       Value                                       ║
╠══════════════════════╪═══════════════════════════════════════════════════════════════════════════════════╣
║Id                    │2                                                                                  ║
║Resource URL          │org.springframework.cloud.task.app:timestamp-task:jar:2.1.1.RELEASE                ║
║Name                  │demo1                                                                              ║
║CLI Arguments         │[--spring.cloud.data.flow.platformname=default, --spring.cloud.task.executionid=2 ]║
║App Arguments         │                 timestamp.format = YYYY                                           ║
║                      │       spring.datasource.username = ******                                         ║
║                      │           spring.cloud.task.name = demo1                                          ║
║                      │            spring.datasource.url = ******                                         ║
║                      │spring.datasource.driverClassName = org.h2.Driver                                  ║
║Deployment Properties │app.timestamp.format = YYYY                                                        ║
║Job Execution Ids     │[]                                                                                 ║
║Start Time            │Wed May 20 20:57:21 IST 2020                                                       ║
║End Time              │Wed May 20 20:57:21 IST 2020                                                       ║
║Exit Code             │0                                                                                  ║
║Exit Message          │                                                                                   ║
║Error Message         │                                                                                   ║
║External Execution Id │demo1-aac20c8b-9c80-40dc-ac7d-bb3f4155be41                                         ║
╚══════════════════════╧═══════════════════════════════════════════════════════════════════════════════════╝
```

이제 이전 태스크 실행에 사용했던 배포 프로퍼티와 함께 `timestamp` 애플리케이션의 `2.1.1.RELEASE` 버전을 사용한다는 것을 알 수 있다. 이런 배포 프로퍼티들도 태스크를 실행하면서 재정의해도 된다.

참고: 태스크를 시작할 때 이전에 사용했던 배포 프로퍼티는 전파되지만, 태스크 인자는 전파되지 **않는다**. 태스크 인자는 당시 태스크를 시작할 때에만 유지하고자 함이다.

---

## Scheduling Lifecycle

Spring Cloud Data Flow는 쿠버네티스와 클라우드 파운드리 플랫폼에서 스케줄링을 지원한다. Spring Cloud Data Flow는 두 경우 모두, 아래있는 일을 수행하기 위해 플랫폼에서 제공하는 스케줄링 시스템과 상호 작용한다:

- 스케줄 생성
- 스케줄 삭제
- 사용 가능한 스케줄 조회

태스크 스케줄링은 플랫폼마다 다르게 처리한다. 다음 섹션에선 Spring Cloud Data Flow가 태스크를 예약하는 방법에 대해 설명한다.

### Scheduling on Cloud Foundry

1. Spring Cloud Data Flow에 스케줄링 요청이 들어온다. Spring Cloud Data Flow는 현재 존재하는 애플리케이션인지를 판단한 다음, 존재하지 않으면 클라우드 파운드리 인스턴스에 애플리케이션을 배포한다. 배포 후엔 애플리케이션을 스케줄러에 바인딩한다 (필요한 바인딩도 함께).
2. 애플리케이션이 배포되고 스케줄러에 바인딩되면, 스케줄러는 제공된 스케줄에 따라 애플리케이션을 시작한다.

애플리케이션을 예약하고 나면, 이 애플리케이션의 라이프사이클은 Cloud Foundry Scheduler가 관리하며, 스케줄을 제거하거나 태스크 정의가 삭제되서 스케줄을 지우는 경우를 제외하고는 더 이상 Spring Cloud Data Flow로 관리되지 않는다.

### Scheduling on Kubernetes

1. Spring Cloud Data Flow에 스케줄링 요청이 들어온다. Spring Cloud Data Flow는 플랫폼에서 지정한 네임스페이스와 클러스터에 CronJob을 생성한다.
2. CronJob이 만들어지고 나면, 이 CronJob이 제공된 스케줄에 따라 애플리케이션을 시작한다.

애플리케이션을 예약하고 나면, 애플리케이션의 라이프사이클은 연결되어 있는 CronJob에서 관리한다. 이후 태스크 정의가 삭제되거나 스케줄이 제거되면 Spring Cloud Data Flow가 CronJob을 삭제한다.