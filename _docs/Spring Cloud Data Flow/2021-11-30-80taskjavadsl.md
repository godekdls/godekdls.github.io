---
title: Task & TaskSchedule Java DSL
navTitle: Task Java DSL
category: Spring Cloud Data Flow
order: 80
permalink: /Spring%20Cloud%20Data%20Flow/feature-guides.batch.java-dsl/
description: 태스크를 생성하고 시작할 수 있는 자바 DSL 사용 가이드
image: ./../../images/springclouddataflow/logo.png
lastmod: 2021-12-02T00:33:00+09:00
comments: true
originalRefName: 스프링 클라우드 데이터 플로우
originalRefLink: https://dataflow.spring.io/docs/feature-guides/batch/java-dsl/
parent: Feature guides
parentUrl: /Spring%20Cloud%20Data%20Flow/feature-guides/
subparent: Batch Feature Guides
subparentNavTitle: Batch
subparentUrl: /Spring%20Cloud%20Data%20Flow/feature-guides.batch/
---

---

태스크를 생성하고 실행할 땐 쉘을 이용하는 대신, `spring-cloud-dataflow-rest-client` 모듈이 제공하는 자바 기반 DSL을 사용해도 된다. `Task`와 `TaskSchedule`을 위한 자바 DSL은 코드를 통해 태스크를 생성하고, 실행하고, 스케줄링할 수 있는 `DataFlowTemplate` 클래스를 감싸놓은 간편한 라이브러리다.

자바 DSL을 시작하려면 프로젝트에 아래 의존성을 추가해야 한다:

```xml
<dependency>
	<groupId>org.springframework.cloud</groupId>
	<artifactId>spring-cloud-dataflow-rest-client</artifactId>
	<version>2.9.1</version>
</dependency>
```

자바 DSL에서 핵심 클래스는 `TaskBuilder`, `Task`, `TaskSchedule`, `TaskScheduleBuilder`, `DataFlowTemplate`이다. 태스크 DSL에선 `TaskExecutionResource`, `TaskExecutionStatus`, `JobExecutionResource`, `JobInstanceResource`같은 몇 가지 DataFlowTemplate 클래스들도 함께 사용한다.

`DataFlowTemplate` 인스턴스를 받는 `Task`의 `builder` 메소드나 `TaskSchedule`의 `builder` 메소드로 시작하면 된다.

### 목차

- [Obtain a DataFlowOperations Instance](#obtain-a-dataflowoperations-instance)
- [Task DSL Usage](#task-dsl-usage)
- [TaskSchedule DSL Usage](#taskschedule-dsl-usage)
- [Setting Deployment Properties](#setting-deployment-properties)
  + [Using the DeploymentPropertiesBuilder for Task](#using-the-deploymentpropertiesbuilder-for-task)
  + [Setting Properties for TaskSchedule](#setting-properties-for-taskschedule)

---

## Obtain a DataFlowOperations Instance

`Task`, `TaskSchedule` DSL에선 유효한 `DataFlowOperations` 인스턴스가 필요하다. Spring Cloud Data Flow는 `DataFlowOperations` 인터페이스의 구현체로 `DataFlowTemplate`을 제공한다.

`DataFlowTemplate` 인스턴스를 생성하려면 Data Flow 서버의 `URI`를 제공해야 한다. `DataFlowTemplate`을 위한 스프링 부트 자동 설정도 지원한다. [`DataFlowClientProperties`](https://github.com/spring-cloud/spring-cloud-dataflow/blob/master/spring-cloud-dataflow-rest-client/src/main/java/org/springframework/cloud/dataflow/rest/client/config/DataFlowClientProperties.java)에 있는 프로퍼티를 사용해 Data Flow 서버에 대한 커넥션을 설정하면 된다. 보통은 `spring.cloud.dataflow.client.uri` 프로퍼티로 시작하는 게 좋다.

```java
URI dataFlowUri = URI.create("http://localhost:9393");
DataFlowOperations dataFlowOperations = new DataFlowTemplate(dataFlowUri);
```

---

## Task DSL Usage

`Task.builder(dataFlowOperations)` 메소드에서 반환하는 `TaskBuilder` 클래스를 사용하면 쉽게 새 `Task` 인스턴스를 생성할 수 있다.

새 composed 태스크를 만드는 아래 예제를 살펴보자:

```java
dataFlowOperations.appRegistryOperations().importFromResource(
                     "https://dataflow.spring.io/task-maven-latest", true);

Task task = Task.builder(dataflowOperations)
              .name("myComposedTask")
              .definition("a: timestamp && b:timestamp")
              .description("My Composed Task")
              .build();
```

`build` 메소드는 생성은 되었지만 아직 실행되진 않은 composed 태스크를 나타내는 `Task` 정의 인스턴스를 반환한다. 태스크 정의에서 사용한 `timestamp`는 DataFlow에 등록된 태스크 앱 이름을 나타낸다.

> 태스크를 생성하고 실행하려면 먼저, [배치 개발자 가이드](../batch-developer-guides.batch-development.data-flow-spring-spring#creating-the-task-definition)에서 보여줬듯이, 해당 앱이 Data Flow 서버에 등록돼 있어야 한다.
>
> 알 수 없는 애플리케이션을 포함하는 태스크를 실행하려고 하면 예외가 발생한다. 애플리케이션을 등록하려면 다음과 같이 `DataFlowOperations`를 사용하면 된다:
>
> ```java
> dataFlowOperations.appRegistryOperations().importFromResource(
>          "https://dataflow.spring.io/task-maven-latest", true);
> ```

`TaskBuilder`는 새 태스크를 만드는 것 말고, 기존 Task 인스턴스를 조회할 때도 사용할 수 있다:

```java
Optional<Task> task = Task.builder(dataflowOperations).findByName("myTask");
```

존재하는 모든 태스크 리스트를 가져올 수도 있다:

```java
List<Task> tasks = Task.builder(dataflowOperations).allTasks();
```

`Task` 인스턴스에는 태스크를 `launch`하거나 `destroy`할 수 있는 메소드가 있다. 아래 예시에선 태스크를 실행한다:

```java
long executionId = task.launch();
```

`executionId`는 기동한 태스크를 위한 고유 Task 실행 식별자다. `launch` 메소드는 launch 프로퍼티 `java.util.Map<String, String>`과 커맨드라인 인자 `java.util.List<String>`을 받는 메소드를 오버로드하고 있다.

태스크들은 비동기로 실행된다. 태스크 완료나 다른 태스크 상태를 기다려야 한다면, 다음과 같이 자바 concurrency 유틸리티나 `Awaitility` 라이브러리를 사용하면 된다:

```java
org.awaitility.Awaitility.await().until(
  () -> task.executionStatus(executionId) == TaskExecutionStatus.COMPLETE);
```

`Task` 인스턴스는 태스크를 제어하고 질의할 수 있는 `executionStatus`, `destroy`, `stop` 메소드를 제공한다.

`Collection<TaskExecutionResource> executions()` 메소드는 이 태스크로 실행한 모든 `TaskExecutionResource` 인스턴스들을 반환한다. `executionId`를 사용하면 특정 실행에 대한 `TaskExecutionResource`를 검색할 수 있다(`Optional<TaskExecutionResource> execution(long executionId)`).

마찬가지로 `Collection<JobExecutionResource> jobExecutionResources()`와 `Collection<JobInstanceResource> jobInstanceResources()`를 사용하면 태스크에 속해 있는 모든 스프링 배치 job을 돌아볼 수 있다.

---

## TaskSchedule DSL Usage

새 composed 태스크를 만들고 스케줄링하는 아래 예제를 살펴보자:

```java
Task task = Task.builder(dataflowOperations)
              .name("myTask")
              .definition("timestamp")
              .description("simple task")
              .build();

TaskSchedule schedule = TaskSchedule.builder(dataFlowOperations)
              .scheduleName("mySchedule")
              .task(task)
              .build();
```

`TaskSchedule.builder(dataFlowOperations)` 메소드는 `TaskScheduleBuilder` 클래스를 반환한다.

이 `build` 메소드는 `mySchedule`이라는 `TaskSchedule` 인스턴스를 반환하며, 스케줄 인스턴스 하나가 세팅돼 있다. 이 시점에는 스케줄이 생성되지 않는다.

스케줄을 생성하려면 `schedule()` 메소드를 사용하면 된다:

```java
schedule.schedule("56 20 ? * *", Collections.emptyMap());
```

`unschedule()` 메소드를 사용해 스케줄을 삭제할 수도 있다:

```java
schedule.unschedule();
```

`TaskScheduleBuilder`를 이용해 기존 스케줄러 중 하나를 조회하거나 모두 가져올 수도 있다:

```java
Optional<TaskSchedule> retrievedSchedule =
          taskScheduleBuilder.findByScheduleName(schedule.getScheduleName());

List<TaskSchedule> allSchedulesPerTask = taskScheduleBuilder.list(task);
```

---

## Setting Deployment Properties

이 섹션에선 `Task`와 `TaskScheduler`에 배포 프로퍼티를 설정하는 방법을 다룬다.

### Using the `DeploymentPropertiesBuilder` for `Task`

`launch(Map<String, String> properties, List<String> arguments)` 메소드를 사용하면 태스크를 시작하는 방법을 커스텀할 수 있다. 빌더 스타일을 통해 프로퍼티를 가지고 있는 맵을 더 쉽게 생성할 수도 있고, 일부 프로퍼티에는 스태틱 메소드를 제공하기 때문에 굳이 이런 프로퍼티 이름들을 외우고 있지 않아도 된다.

```java
Map<String, String> taskLaunchProperties = new DeploymentPropertiesBuilder()
		.memory("myTask", 512)
		.put("app.timestamp.timestamp.format", "YYYY")
		.build();

long executionId = task.launch(taskLaunchProperties, Collections.EMPTY_LIST);
```

### Setting Properties for `TaskSchedule`

`TaskSchedule` 인스턴스에도 비슷한 방법으로 배포 프로퍼티를 설정할 수 있다:

```java
Map<String,String> props = new HashMap<>();
props.put("app.timestamp.timestamp.format", "YYYY");
taskSchedule.schedule("*/1 * * * *", props);
```