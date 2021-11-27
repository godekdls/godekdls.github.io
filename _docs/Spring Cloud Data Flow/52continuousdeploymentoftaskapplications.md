---
title: Continuous Deployment of Task Applications
category: Spring Cloud Data Flow
order: 52
permalink: /Spring%20Cloud%20Data%20Flow/batch-developer-guides.continuous-deployment.task-applications/
description: todo
image: ./../../images/springclouddataflow/logo.png
lastmod: 2021-07-26T18:30:00+09:00
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

SCDF에 태스크 애플리케이션을 등록하면 일반적으로 버전 하나가 애플리케이션에 연결된다. 태스크 애플리케이션은 여러  가지 버전에 연결될 수 있으며, 그 중 하나는 기본값으로 선택돼 있을 거다. 다음은 여러 가지 버전이 연결된 애플리케이션을 보여주는 이미지다 (timestamp 항목을 봐라).

![Registering Task Applications with multiple Versions](./../../images/springclouddataflow/scdf-task-application-versions.webp)

이름과 좌표<sup>coordinates</sup>가 같고 버전만 *다른* 애플리케이션을 여러 번 등록하면, SCDF에서 애플리케이션의 버전을 관리한다. 예를 들어, 아래 있는 값을 사용해 애플리케이션을 등록하면 두 가지 버전(2.0.0.RELEASE와 2.1.0.RELEASE)을 갖는 하나의 애플리케이션이 등록된다:

- **Application 1**

  이름: `timestamp`<br>타입: `task`<br>URI: `maven://org.springframework.cloud.task.app:timestamp-task:2.0.0.RELEASE`

- **Application 2**

  이름: `timestamp`<br>타입: `task`<br>
  URI: `maven://org.springframework.cloud.task.app:timestamp-task:2.1.0.RELEASE`

여러 가지 버전을 가지는 것 외에도, Spring Cloud Data Flow는 다음 실행 시 사용할 버전을 알고 있어야 한다. 다음에 사용할 버전은 디폴트 버전으로 설정하는 식으로 표현한다. 디폴트 버전으로 설정한 태스크 애플리케이션의 버전이 무엇이든 다음 실행 요청에 사용한다. 어떤 버전이 디폴트인지는 UI에서 확인할 수 있다:

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

Before the CD support for Tasks in SCDF, when the request to launch a task was received, Spring Cloud Data Flow would deploy the application (if needed) and run it. If the application was being run on a platform that did not need to have the application deployed every time (Cloud Foundry, for example), the previously deployed application was used. This flow has changed starting from 2.3. The following image shows what happens when a task launch request comes in now:

![Flow For Launching A Task](./../../images/springclouddataflow/scdf-task-launch-flow.webp)

There are three main flows to consider in the preceding diagram:

- Launching the first time or launching with no changes is one
- Launching when there are changes but the task is not running
- Launching when there are changes but the task is running

We look at the flow with no changes first.

### Launch a Task With No Changes

1. A launch request comes into Data Flow. Data Flow determines that an upgrade is not required, since nothing has changed (no properties, deployment properites, or versions have changed since the last execution).
2. On platforms that cache a deployed artifact (Cloud Foundry at the time of this writing), Data Flow checks whether the application was previously deployed.
3. If the application needs to be deployed, Data Flow deploys the task application.
4. Data Flow launches the application.

This flow is the default behavior and, if nothing has changed, occurs every time a request comes in. Note that this is the same flow that Data Flow has always executed for launching tasks.

### Launch a Task With Changes That Is Not Currently Running

The second flow to consider when launching a task is whether there was a change in the task application version, the application properties, or the deployment properties. In this case, the following flow is executed:

1. A launch request comes into Data Flow. Data Flow determines that an upgrade is required, since there was a change in either task application version, application properties, or deployment properties.
2. Data Flow checks to see whether another instance of the task definition is currently running.
3. If there is not another instance of the task definition currently running, the old deployment is deleted.
4. On platforms that cache a deployed artifact (Cloud Foundry at the time of this writing), Data Flow checks whether the application was previously deployed (this check evaluates to `false` in this flow, since the old deployment was deleted).
5. Data Flow does the deployment of the task application with the updated values (new application version, new merged properties, and new merged deployment properties).
6. Data Flow launches the application.

This flow is what fundamentally enables continuous deployment for Spring Cloud Data Flow.

### Launch a Task With Changes While Another Instance Is Running

The last main flow is when a launch request comes to Spring Cloud Data Flow to do an upgrade but the task definition is currently running. In this case, the launch is blocked due to the requirement to delete the current application. On some platforms (Cloud Foundry at the time of this writing), deleting the application causes all currently running applications to be shut down. This feature prevents that from happening. The following process describes what happens when a task changes while another instance is running:

1. A launch request comes into to Data Flow. Data Flow determines that an upgrade is required, since there was a change in any one of task application version, application properties, or deployment properties.
2. Data Flow checks to see whether another instance of the task definition is currently running.
3. Data Flow prevents the launch from happening because other instances of the task definition are running.

NOTE: Any launch that requires an upgrade of a task definition that is running at the time of the request is blocked from executing due to the need to delete any currently running tasks.

### Example of Continuous Deployment

We now have the `timestamp` application registered in the `Application Registry` with two versions: `2.1.0.RELEASE` and `2.1.1.RELEASE`.

```bash
dataflow:>app list --id task:timestamp
╔═══╤══════╤═════════╤════╤═══════════════════════════╗
║app│source│processor│sink│           task            ║
╠═══╪══════╪═════════╪════╪═══════════════════════════╣
║   │      │         │    │> timestamp-2.1.0.RELEASE <║
║   │      │         │    │timestamp-2.1.1.RELEASE    ║
╚═══╧══════╧═════════╧════╧═══════════════════════════╝
```

The task application `timestamp` now uses the version `2.1.0.RELEASE` as the default version when launching the task.

Create a task called `demo1` by using the `timestamp` application registered earlier:

```bash
dataflow:>task create demo1 --definition "timestamp"
Created new task 'demo1'
```

Launch the task `demo1` with the deployment properties set:

```bash
dataflow:>task launch demo1 --properties "app.timestamp.format=YYYY"
Launched task 'demo1' with execution id 1
```

When the task is launched, you can check the task execution `status` and verify that the application version `2.1.0.RELEASE` is used:

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

Now we can try to change the default version of the `timestamp` application to `2.1.1.RELEASE`.

```bash
dataflow:>app default --id task:timestamp --version 2.1.1.RELEASE
New default Application task:timestamp:2.1.1.RELEASE
```

You can verify the change, as follows:

```bash
dataflow:>app list --id task:timestamp
╔═══╤══════╤═════════╤════╤═══════════════════════════╗
║app│source│processor│sink│           task            ║
╠═══╪══════╪═════════╪════╪═══════════════════════════╣
║   │      │         │    │timestamp-2.1.0.RELEASE    ║
║   │      │         │    │> timestamp-2.1.1.RELEASE <║
╚═══╧══════╧═════════╧════╧═══════════════════════════╝
```

Now the default version of `timestamp` application is set to use `2.1.1.RELEASE`. This means that any subsequent launch of `timestamp` application would use `2.1.1.RELEASE` instead of the previous default (`2.1.0.RELEASE`).

```bash
dataflow:>task launch demo1
Launched task 'demo1' with execution id 2
```

You can verify this by using the task execution status, as follows:

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

Note that the `2.1.1.RELEASE` version of the `timestamp` application is now used, along with the deployment properties from the previous task launch. You can override these deployment properties during the task launch as well.

Note: While the deployment properties are propagated between the task launches, the task arguments are **not** propagated.The idea is to keep the arguments only for each task launch.

---

## Scheduling Lifecycle

Spring Cloud Data Flow supports scheduling on 2 platforms: Kubernetes and Cloud Foundry. In both cases Spring Cloud Data Flow interacts with the scheduling system provided by the platform to:

- Create a schedule
- Delete a schedule
- List available schedules Each platform handles scheduling of tasks differently. In the following sections we will discuss how Spring Cloud Data Flow schedules a task.

### Scheduling on Cloud Foundry

1. A scheduling request comes into Spring Cloud Data Flow. Spring Cloud Data Flow determines if the application currently exists, if it isn't present it deploys the application to the Cloud Foundry instance. Then binds the application to the scheduler (along with the required bindings).
2. Once the application has been deployed and bound to the scheduler, the scheduler then launches the application based on the schedule provided.

Once the application has been scheduled, then the lifecycle of the application is managed by the Cloud Foundry Scheduler and is no longer managed by Spring Cloud Data Flow, except when removing the schedule or delete it when the task definition is deleted.

### Scheduling on Kubernetes

1. A scheduling request comes into Spring Cloud Data Flow. Spring Cloud Data Flow creates a CronJob in the namespace and cluster specified by the platform.
2. Once the CronJob has been created, the CronJob then launches the application based on the schedule provided.

Once the application has been scheduled, then the lifecycle of the application is managed by the associated CronJob. Spring Cloud Data Flow then will delete the CronJob when the task definition is deleted or is the schedule is deleted.