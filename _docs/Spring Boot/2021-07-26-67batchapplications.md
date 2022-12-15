---
title: Batch Applications
category: Spring Boot 2.X
order: 67
permalink: /Spring%20Boot/howto.batch-applications/
description: 스프링 배치와 관련된 how to 가이드 (데이터소스 지정하기, 실행할 job 이름/파라미터 설정하기 등)
image: ./../../images/springboot/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 부트
originalRefLink: https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#howto.batch
parent: “How-to” Guides
parentUrl: /Spring%20Boot/how-to-guides/
priority: 0.4
---

### 목차

- [12.11.1. Specifying a Batch Data Source](#12111-specifying-a-batch-data-source)
- [12.11.2. Running Spring Batch Jobs on Startup](#12112-running-spring-batch-jobs-on-startup)
- [12.11.3. Storing the Job Repository](#12113-storing-the-job-repository)

---

## 12.11. Batch Applications

스프링 부트 애플리케이션 내에서 스프링 배치를 사용할 때는 많은 질문들을 하곤 한다. 이번 섹션에선 이 질문들에 답해보겠다.

### 12.11.1. Specifying a Batch Data Source

기본적으로 배치 애플리케이션은 job의 세부정보를 저장할 `DataSource`가 필요하다. 스프링 배치는 기본적으로 단일 `DataSource`를 찾는다. 애플리케이션의 메인 `DataSource`가 아닌 다른 `DataSource`를 사용하려면, `DataSource` 빈을 선언하고 `@Bean` 메소드에 `@BatchDataSource` 어노테이션을 추가해라. 이때 데이터소스를 두 개 사용한다면, 다른 하나를 `@Primary`로 마킹하는 걸 잊지마라. 다른 것들을 더 커스텀하고 싶다면 `BatchConfigurer`를 구현해라. 자세한 내용은 [`@EnableBatchProcessing`의 Javadoc](https://docs.spring.io/spring-batch/docs/4.3.3/api/org/springframework/batch/core/configuration/annotation/EnableBatchProcessing.html)을 참고해라.

스프링 배치를 자세히 알고 싶다면 [스프링 배치 프로젝트 페이지](https://spring.io/projects/spring-batch)를 방문해봐라.

### 12.11.2. Running Spring Batch Jobs on Startup

스프링 배치 자동 설정은 `@Configuration` 클래스 중 하나에 `@EnableBatchProcessing`을 추가하면 활성화된다.

기본적으로 애플리케이션을 기동하게 되면 애플리케이션 컨텍스트에 있는 **모든** `Job`을 실행한다 (자세한 내용은 [`JobLauncherApplicationRunner`](https://github.com/spring-projects/spring-boot/tree/v2.5.2/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/batch/JobLauncherApplicationRunner.java) 참고). `spring.batch.job.names`를 지정하면 실행할 job들의 범위를 좁힐 수 있다 (job 네임 패턴을 콤마로 구분해서 설정).

자세한 내용은 [BatchAutoConfiguration](https://github.com/spring-projects/spring-boot/tree/v2.5.2/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/batch/BatchAutoConfiguration.java)과 [@EnableBatchProcessing](https://docs.spring.io/spring-batch/docs/4.3.3/api/org/springframework/batch/core/configuration/annotation/EnableBatchProcessing.html)을 참고해라.

커맨드라인에서 스프링 부트를 실행하면 `--`로 시작하는 모든 커맨드라인 인자를 프로퍼티로 변환해서 `Environment`에 추가한다 ([커맨드라인 프로퍼티에 접근하기](../externalized-configuration#721-accessing-command-line-properties) 참고). 배치 job에 전달하는 인자에는 이 포맷을 사용하면 안 된다. 커맨드라인에서 배치 인자를 지정하려면 아래 예시와 같이 평소 쓰던 형식을 사용해야 한다 (`--` 없이):

```shell
$ java -jar myapp.jar someParameter=someValue anotherParameter=anotherValue
```

커맨드라인에 `Environment` 프로퍼티를 지정해도 job에서는 무시한다. 아래 명령어를 생각해보자:

```shell
$ java -jar myapp.jar --server.port=7070 someParameter=someValue
```

여기서는 배치 job에 유일한 인자 `someParameter=someValue`만 제공한다.

### 12.11.3. Storing the Job Repository

스프링 배치에선 `Job` 레포지토리에 사용할 데이터 저장소가 필요하다. 스프링 부트를 사용한다면, 반드시 실제 데이터베이스를 사용해야 한다. 인메모리 데이터베이스가 될 수도 있다는 점에 주의해라 ([Job 레포지토리 설정하기](../../Spring%20Batch/configuringandrunningajob/#43-configuring-a-jobrepository) 참고).
