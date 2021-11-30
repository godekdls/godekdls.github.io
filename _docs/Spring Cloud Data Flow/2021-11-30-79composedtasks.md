---
title: Composed Tasks
category: Spring Cloud Data Flow
order: 79
permalink: /Spring%20Cloud%20Data%20Flow/feature-guides.batch.composed-task/
description: Composed 태스크를 이용해 다양한 플로우를 생성하고 관리하기
image: ./../../images/springclouddataflow/SCDF-composed-task-101.webp
lastmod: 2021-12-02T00:33:00+09:00
comments: true
originalRefName: 스프링 클라우드 데이터 플로우
originalRefLink: https://dataflow.spring.io/docs/feature-guides/batch/composed-task/
parent: Feature guides
parentUrl: /Spring%20Cloud%20Data%20Flow/feature-guides/
subparent: Batch Feature Guides
subparentNavTitle: Batch
subparentUrl: /Spring%20Cloud%20Data%20Flow/feature-guides.batch/
---
<script>defaultLanguages = ['local']</script>

---

composed 태스크는 태스크 애플리케이션을 그래프의 각 노드로 표현하는 유향 그래프<sup>directed graph</sup>다. Spring Cloud Data Flow에선 composed 태스크를 브라우저 기반 UI, 쉘, RESTful API를 통해 생성할 수 있다. 이 섹션에선 composed 태스크를 만들고 관리하는 방법을 보여준다.

### 목차

- [Composed Task 101](#composed-task-101)
- [Configuring Data Flow to Launch the Composed Task Runner](#configuring-data-flow-to-launch-the-composed-task-runner)
- [Registering Sample Applications](#registering-sample-applications)
- [The Transition Sample Project](#the-transition-sample-project)
  + [Getting the Transition Sample Project from Github](#getting-the-transition-sample-project-from-github)
  + [Building the Transition Sample Project](#building-the-transition-sample-project)
  + [Registering the Transition Sample](#registering-the-transition-sample)
- [Conditional Execution](#conditional-execution)
  + [Create Conditional Execution Composed Task Definition](#create-conditional-execution-composed-task-definition)
  + [Launch Conditional Execution Composed Task Definition](#launch-conditional-execution-composed-task-definition)
  + [Check the Status of the Conditional Execution Composed Task Definition](#check-the-status-of-the-conditional-execution-composed-task-definition)
- [Transitional Execution](#transitional-execution)
  + [Create Basic Transition Task Definition](#create-basic-transition-task-definition)
  + [Launch the Composed Task Definition](#launch-the-composed-task-definition)
    * [Are There More States to a Transition?](#are-there-more-states-to-a-transition)
- [Split Execution](#split-execution)
  + [Arguments and Properties](#arguments-and-properties)
  + [Configuring Your Split](#configuring-your-split)
  + [Basic Split Sizing](#basic-split-sizing)
- [Restarting Composed Task Runner when task app fails](#restarting-composed-task-runner-when-task-app-fails)
  + [Detecting a failed composed task](#detecting-a-failed-composed-task)
  + [Example](#example)
- [Passing Properties to Tasks in the Graph](#passing-properties-to-tasks-in-the-graph)
  + [Setting property in the task definition](#setting-property-in-the-task-definition)
  + [Setting Property at Composed Task Launch Time](#setting-property-at-composed-task-launch-time)
- [Setting Arguments at Composed Task Launch Time](#setting-arguments-at-composed-task-launch-time)
- [Passing Properties to Composed Task Runner](#passing-properties-to-composed-task-runner)
- [Launching Composed Task using RESTful API](#launching-composed-task-using-restful-api)
- [Launching a Composed Task When Security is Enabled](#launching-a-composed-task-when-security-is-enabled)
  + [Basic Authentication](#basic-authentication)
  + [Using Your Own Access Token](#using-your-own-access-token)
  + [User Access Token](#user-access-token)
  + [Client Credentials](#client-credentials)
- [Configure the URI for Composed Tasks](#configure-the-uri-for-composed-tasks)

---

## Composed Task 101

composed 태스크를 만들고 관리하는 방법을 알아보기 전에 먼저, 일련의 태스크 정의들을 시작하는 시나리오를 생각해볼 필요가 있다.<br>
이 시나리오에선 `task-a`, `task-b`, `task-c`로 식별하는 태스크 정의들을 시작하려 한다고 가정해보자. 예를 들어서 `task-a`를 실행하고, `task-a`가 정상적으로 완료되면 `task-b`를 실행하려고 한다. `task-b`가 정상적으로 완료되면 `task-c`를 시작할 거다. 현재 상황을 그래프로 나타내면 다음과 같다:

![Composed Task Graph](./../../images/springclouddataflow/SCDF-composed-task-101.webp){: .center-image }

위 다이어그램을 Spring Cloud Data Flow의 태스크 정의 DSL로 표현하면 다음과 같다:

```sh
task-a && task-b && task-c
```

위 DSL에 보이는 `&&`는, `&&` 왼쪽에 있는 태스크 정의를 그 다음 태스크 정의를 시작하기 전에 반드시 성공적으로 완료해야 한다는 의미다.

위 composed 태스크 정의를 만들었다면, 일반 태스크 정의와 동일한 방식으로 실행시킬 수 있다. Spring Cloud Data Flow 내부에선 composed 태스크 그래프의 실행을 관리하기 위해 `Composed Task Runner` 애플리케이션을 시작한다. 이 애플리케이션은 Spring Cloud Data Flow 태스크 정의를 파싱한 다음, 태스크 정의를 시작하기 위한 RESTful API를 Spring Cloud Data Flow 서버에 다시 호출한다. 각 태스크가 완료되면 다음 태스크 정의를 시작한다. 이어지는 섹션에선 자체 composed 태스크 그래프를 생성하는 방법을 소개하면서, composed 태스크 플로우를 생성할 수 있는 다양한 방법들을 알아본다.

---

# Configuring Spring Cloud Data Flow Launch Composed Tasks

앞서 말한대로 `Composed-Task-Runner`는 composed 태스크 그래프에 있는 태스크들의 실행을 관리하는 애플리케이션이다. 따라서 composed 태스크를 생성하려면 먼저 이 Composed Task Runner를 적절히 실행할 수 있도록 Spring Cloud Data Flow를 설정해줘야 한다.

---

## Configuring Data Flow to Launch the Composed Task Runner

Spring Cloud Data Flow는 composed 태스크를 시작할 땐 `Composed-Task-Runner`가 유향 그래프<sup>directed graph</sup>를 적절히 실행할 수 있도록 프로퍼티를 전달해준다. 그러려면 `Composed Task Runner`가 정확한 SCDF 서버에 RESTful API를 호출할 수 있도록 Spring Cloud Data Flow의 `dataflow.server.uri` 프로퍼티를 설정해줘야 한다:

- `dataflow.server.uri`: `Composed Task Runner`가 RESTful API를 호출할 때 사용하는 Spring Cloud Data Flow 서버의 URI. 기본값은 https://localhost:9393이다.

- `spring.cloud.dataflow.task.composedtaskrunner.uri`: Spring Cloud Data Flow가 `Composed Task Runner` 아티팩트를 가져올 위치를 세팅한다. Spring Cloud Data Flow는 `local`과 `Cloud Foundry` 플랫폼에선 기본적으로 Maven Central에서 아티팩트를 조회한다. `Kubernetes`에선 아티팩트를 도커허브에서 가져온다.

  > `spring.cloud.dataflow.task.composed.task.runner.uri`는 Spring Cloud Data Flow 2.7.0에서 deprecated되었으며, 대신 `spring.cloud.dataflow.task.composedtaskrunner.uri`를 사용한다.

- `spring.cloud.dataflow.task.composedtaskrunner.imagePullSecret`: 쿠버네티스 환경에서 실행 중일 때 Composed Task Runner 이미지가 인증을 요구하는 레포지토리에 있다면, 시크릿에 이미지를 가져올 때 사용할 credential을 설정할 수 있다. 먼저 시크릿을 생성한 뒤, 프로퍼티 값에는 이 시크릿의 이름을 넣으면 된다. [프라이빗 레지스트리에서 이미지 가져오기](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/) 가이드에 따라 시크릿을 생성해라.

- `maximumConcurrentTasks` - Spring Cloud Data Flow에선 사용자가 직접 각 설정 플랫폼마다 동시에 실행할 수 있는 최대 태스크 수를 제한해서 IaaS/하드웨어 리소스의 포화를 방지할 수 있다. 디폴트 제한치는 지원 플랫폼 모두 `20`으로 설정된다. 플랫폼 인스턴스에서 동시에 실행 중인 태스크 수가 제한치보다 크거나 같으면, 다음 태스크 실행 요청은 실패하며, RESTful API, 쉘, UI를 통해 에러 메세지를 반환한다. 플랫폼 인스턴스에 이 제한치를 설정할 땐, 해당 플랫폼의 deployer 프로퍼티를 최대 동시 태스크 수로 설정해주면 된다:

  ```properties
  spring.cloud.dataflow.task.platform.<platform-type>.accounts[<account-name>].deployment.maximumConcurrentTasks
  ```

  `<account-name>`은 설정에 있는 플랫폼 계정 이름이다 (계정을 명시해두지 않았다면 `default`). `<platform-type>`은 현재 지원하는 deployer `local`, `cloudfoundry`, `kubernetes` 중 하나를 의미한다.

> 이 프로퍼티를 변경하려면 Spring Cloud Data Flow를 재시작해야 한다.

---

## Registering Sample Applications

밑에서 composed 태스크 샘플을 만들어보려면 먼저, 예제에서 사용할 샘플 애플리케이션들을 등록해야 한다. 따라서 이 가이드를 따라하라면, timestamp 애플리케이션을 `task-a`, `task-b`, `task-c`, `task-d`, `task-e`, `task-f`라는 이름으로 여러 번 재등록해야 한다.

<div class="switch-language-wrapper local cloud-foundry kubernetes">
<span class="switch-language local">Local</span>
<span class="switch-language cloud-foundry">CloudFoundry</span>
<span class="switch-language kubernetes">Kubernetes</span>
</div>
<div class="language-only-for-local local cloud-foundry kubernetes"></div>
<div style="border: 1px solid #ddd; padding: 15px; margin-bottom: 20px; background-color: #f9f9f9;">
<p>Spring Cloud Data Flow는 로컬 배포에는 메이븐, HTTP, 파일, 도커 리소스를 지원한다. 로컬 예제에선 메이븐 리소스를 사용한다. 메이븐 아티팩트 URI는 보통 <code class="highlighter-rouge">maven://&lt;groupId&gt;:&lt;artifactId&gt;:&lt;version&gt;</code> 형식이다. 이 샘플 애플리케이션의 메이븐 URI는 다음과 같다:</p>
<div class="language-text highlighter-rouge"><div class="highlight"><pre class="highlight"><code>maven://org.springframework.cloud.task.app:timestamp-task:2.1.0.RELEASE
</code></pre></div></div>
<p><code class="highlighter-rouge">maven:</code> 프로토콜은 Data Flow 서버에 설정해둔 리모트 혹은 로컬 메이븐 레포지토리를 통해 리졸브하는 메이븐 아티팩트를 지정한다. 애플리케이션을 등록하려면 페이지 왼편에 있는 <strong>Applications</strong> 탭을 클릭해라. 그 다음 <strong>Add Application(s)</strong>과 <strong>Register one or more applications</strong>를 선택해라. 아래 이미지와 같이 양식을 작성하고 <strong>Register the application(s)</strong>을 클릭해 <code class="highlighter-rouge">task-a</code>를 등록한다.</p>
<p><img src="./../../images/springclouddataflow/SCDF-composed-task-register-timestamp-app-maven.webp" alt="Register the  transition sample"></p>
<p>같은 URI를 사용해서 <code class="highlighter-rouge">task-a</code>, <code class="highlighter-rouge">task-b</code>, <code class="highlighter-rouge">task-c</code>, <code class="highlighter-rouge">task-d</code>, <code class="highlighter-rouge">task-e</code>, <code class="highlighter-rouge">task-f</code>를 반복해서 등록해라: <code class="highlighter-rouge">maven://org.springframework.cloud.task.app:timestamp-task:2.1.0.RELEASE</code>.</p>
</div>
<div class="language-only-for-cloud-foundry local cloud-foundry kubernetes"></div>
<div style="border: 1px solid #ddd; padding: 15px; margin-bottom: 20px; background-color: #f9f9f9;">
<p>Spring Cloud Data Flow는 클라우드 파운드리 배포에는 메이븐, HTTP, 도커 리소스를 지원한다. 클라우드 파운드리 예제에선 HTTP(사실상 HTTPS) 리소스를 사용한다. HTTPS 리소스의 URI는 <code class="highlighter-rouge">https://&lt;web-path&gt;/&lt;artifactName&gt;-&lt;version&gt;.jar</code> 형식이다. 이렇게 지정하면 Spring Cloud Data Flow는 이 HTTPS URI에서 아티팩트를 가져온다.</p>
<p>이 샘플 애플리케이션의 HTTPS URI는 다음과 같다:</p>
<div class="language-text highlighter-rouge"><div class="highlight"><pre class="highlight"><code>https://repo.spring.io/libs-snapshot/org/springframework/cloud/task/app/timestamp-task/2.1.0.RELEASE/timestamp-task-2.1.0.RELEASE.jar
</code></pre></div></div>
<p>애플리케이션을 등록하려면 페이지 왼편에 있는 <strong>Applications</strong> 탭을 클릭해라. 그 다음 <strong>Add Applications</strong>과 <strong>Register one or more applications</strong>를 선택해라. 아래 이미지와 같이 양식을 작성하고 <strong>Register the application(s)</strong>을 클릭하면 된다.</p>
<p><img src="./../../images/springclouddataflow/SCDF-composed-task-register-timestamp-app-http.webp" alt="Register the transition sample"></p>
<p>같은 URI를 사용해서 <code class="highlighter-rouge">task-a</code>, <code class="highlighter-rouge">task-b</code>, <code class="highlighter-rouge">task-c</code>, <code class="highlighter-rouge">task-d</code>, <code class="highlighter-rouge">task-e</code>, <code class="highlighter-rouge">task-f</code>를 반복해서 등록해라:</p>
<div class="language-text highlighter-rouge"><div class="highlight"><pre class="highlight"><code>https://repo.spring.io/libs-snapshot/org/springframework/cloud/task/app/timestamp-task/2.1.0.RELEASE/timestamp-task-2.1.0.RELEASE.jar`
</code></pre></div></div>
</div>
<div class="language-only-for-kubernetes local cloud-foundry kubernetes"></div>
<div style="border: 1px solid #ddd; padding: 15px; margin-bottom: 20px; background-color: #f9f9f9;">
<p>Spring Cloud Data Flow는 쿠버네티스 배포에는 도커 리소스를 지원한다. 도커 이미지의 URI는 <code class="highlighter-rouge">docker:&lt;docker-image-path&gt;/&lt;imageName&gt;:&lt;version&gt;</code> 형식이며, Data Flow 태스크 플랫폼에 설정돼있는 도커 레지스트리와 이미지 pull 정책을 사용해 리졸브된다.</p>
<p>샘플 앱의 도커 URI는 다음과 같다:</p>
<div class="language-text highlighter-rouge"><div class="highlight"><pre class="highlight"><code>docker:springcloudtask/timestamp-task:2.1.0.RELEASE
</code></pre></div></div>
<p>애플리케이션을 등록하려면 페이지 왼편에 있는 <strong>Applications</strong> 탭을 클릭해라. 그 다음 <strong>Add Applications</strong>과 <strong>Register one or more applications</strong>를 선택해라. 아래 이미지와 같이 양식을 작성하고 <strong>Register the application(s)</strong>을 클릭하면 된다.</p>
<p><img src="./../../images/springclouddataflow/SCDF-composed-task-register-timestamp-app-docker.webp" alt="Register the transition sample"></p>
<p>같은 URI를 사용해서 <code class="highlighter-rouge">task-a</code>, <code class="highlighter-rouge">task-b</code>, <code class="highlighter-rouge">task-c</code>, <code class="highlighter-rouge">task-d</code>, <code class="highlighter-rouge">task-e</code>, <code class="highlighter-rouge">task-f</code>를 반복해서 등록해라: <code class="highlighter-rouge">docker:springcloudtask/timestamp-task:2.1.0.RELEASE</code>.</p>
</div>


> 환경에 따라 Spring Cloud Data Flow에서 Maven Central이나 DockerHub에 연결할 수 없을 땐, `spring.cloud.dataflow.task.composed.task.runner.uri` 프로퍼티를 사용해 Composed Task Runner를 조회할 다른 URI를 지정할 수 있다.

---

## The Transition Sample Project

composed 태스크 다이어그램을 통해 가능한 몇 가지 플로우들을 탐구해보려면, 기동 시 종료 상태를 설정해줄 수 있는 애플리케이션이 필요하다. 이 `transition-sample`을 이용하면 composed 태스크 다이어그램을 통해 다양한 플로우들을 탐구해볼 수 있다.

### Getting the Transition Sample Project from Github

이 프로젝트는 깃허브에서 받아야 한다:

1. 터미널 세션을 하나 열어라.

2. 프로젝트를 클론하고 싶은 작업 디렉토리를 선택해라.

3. 작업 디렉토리에서 아래 깃 명령어를 실행해라:

   ```sh
   git clone https://github.com/spring-cloud/spring-cloud-dataflow-samples.git
   ```

4. spring-cloud-dataflow-samples/transition-sample 디렉토리로 이동해라.

   ```sh
   cd spring-cloud-dataflow-samples/transition-sample
   ```

### Building the Transition Sample Project

이 애플리케이션을 빌드하려면 아래 명령어를 사용해라:

```sh
./mvnw clean install
```

도커 이미지를 빌드하려면 아래 명령어를 사용해라:

```sh
./mvnw dockerfile:build
```

### Registering the Transition Sample

<div class="switch-language-wrapper local cloud-foundry kubernetes">
<span class="switch-language local">Local</span>
<span class="switch-language cloud-foundry">CloudFoundry</span>
<span class="switch-language kubernetes">Kubernetes</span>
</div>
<div class="language-only-for-local local cloud-foundry kubernetes"></div>
<div style="border: 1px solid #ddd; padding: 15px; margin-bottom: 20px; background-color: #f9f9f9;">
<p>Spring Cloud Data Flow는 로컬 배포에는 메이븐, HTTP, 파일, 도커 리소스를 지원한다. 이 예제에선 메이븐 리소스를 사용한다. 메이븐 아티팩트 URI는 보통 <code class="highlighter-rouge">maven://&lt;groupId&gt;:&lt;artifactId&gt;:&lt;version&gt;</code> 형식이다. 이 샘플 애플리케이션의 메이븐 URI는 다음과 같다:</p>
<div class="language-text highlighter-rouge"><div class="highlight"><pre class="highlight"><code>maven://io.spring:transition-sample:1.0.0.BUILD-SNAPSHOT
</code></pre></div></div>
<p><code class="highlighter-rouge">maven:</code> 프로토콜은 Data Flow 서버에 설정해둔 리모트 혹은 로컬 메이븐 레포지토리를 통해 리졸브하는 메이븐 아티팩트를 지정한다. 애플리케이션을 등록하려면 페이지 왼편에 있는 <strong>Applications</strong> 탭을 클릭해라. 그 다음 <strong>Add Application(s)</strong>과 <strong>Register one or more applications</strong>를 선택해라. 다음 이미지와 같이 양식을 작성하고 <strong>Register the application(s)</strong>를 클릭하면 된다.</p>
<p><img src="./../../images/springclouddataflow/SCDF-composed-task-register-task-app-maven.webp" alt="Register the  transition sample"></p>
</div>
<div class="language-only-for-cloud-foundry local cloud-foundry kubernetes"></div>
<div style="border: 1px solid #ddd; padding: 15px; margin-bottom: 20px; background-color: #f9f9f9;">
<p>Spring Cloud Data Flow는 클라우드 파운드리 배포에는 메이븐, HTTP, 도커 리소스를 지원한다. 이 예제에선 HTTP(사실상 HTTPS) 리소스를 사용한다. HTTPS 리소스의 URI는 <code class="highlighter-rouge">https://&lt;web-path&gt;/&lt;artifactName&gt;-&lt;version&gt;.jar</code> 형식이다. 이렇게 지정하면 Spring Cloud Data Flow는 이 HTTPS URI에서 아티팩트를 가져온다.</p>
<p>이 샘플 앱의 HTTPS URI는 다음과 같다:</p>
<div class="language-text highlighter-rouge"><div class="highlight"><pre class="highlight"><code>http://&lt;path to your jar&gt;:transition-sample:1.0.0.BUILD-SNAPSHOT
</code></pre></div></div>
<p>애플리케이션을 등록하려면 페이지 왼편에 있는 <strong>Applications</strong> 탭을 클릭해라. 그 다음 <strong>Add Application(s)</strong>과 <strong>Register one or more applications</strong>를 선택해라. 다음 이미지와 같이 양식을 작성하고 <strong>Register the application(s)</strong>를 클릭하면 된다.</p>
<p><img src="./../../images/springclouddataflow/SCDF-composed-task-register-task-app-http.webp" alt="Register the transition sample"></p>
</div>
<div class="language-only-for-kubernetes local cloud-foundry kubernetes"></div>
<div style="border: 1px solid #ddd; padding: 15px; margin-bottom: 20px; background-color: #f9f9f9;">
<p>Spring Cloud Data Flow는 쿠버네티스 배포에는 도커 리소스를 지원한다. 도커 이미지의 URI는 <code class="highlighter-rouge">docker:&lt;docker-image-path&gt;/&lt;imageName&gt;:&lt;version&gt;</code> 형식이며, Data Flow 태스크 플랫폼에 설정돼있는 도커 레지스트리와 이미지 pull 정책을 사용해 리졸브된다.</p>
<p>샘플 앱의 도커 URI는 다음과 같다:</p>
<div class="language-text highlighter-rouge"><div class="highlight"><pre class="highlight"><code>docker:springcloud/transition-sample:latest
</code></pre></div></div>
<p>애플리케이션을 등록하려면 페이지 왼편에 있는 <strong>Applications</strong> 탭을 클릭해라. 그 다음 <strong>Add Application(s)</strong>과 <strong>Register one or more applications</strong>를 선택해라. 다음 이미지와 같이 양식을 작성하고 <strong>Register the application(s)</strong>를 클릭하면 된다.</p>
<p><img src="./../../images/springclouddataflow/SCDF-composed-task-register-task-app-docker.webp" alt="Register the transition sample"></p>
</div>


---

# Building a Composed Task

이 섹션에선 Spring Cloud Data Flow에서 지원하는 세 가지 기본 구조에 대해 살펴본다:

- Conditional Execution
- Transitional Execution
- Split Execution

---

## Conditional Execution

Conditional execution은 이중 앰퍼샌드 기호 `&&`를 사용해 표현한다. 이 기호를 사용하면 시퀀스 안에 있는 각 태스크들을, 앞선 태스크가 정상적으로 완료됐을 때만 실행시킬 수 있다.

### Create Conditional Execution Composed Task Definition

Spring Cloud Data Flow UI에서 conditional execution을 생성하려면, 대시보드 왼편에 있는 **Tasks** 탭을 클릭한 다음, 페이지 상단의 **CREATE TASK** 버튼을 눌러라. 이제 아래 표현식을 복사해서 페이지 상단에 위치해 있는 텍스트 상자에 붙여넣어라:

```sh
task-a && task-b
```

대시보드에 아래 이미지와 같은 그래프가 생기는 걸 볼 수 있다:

![Conditional Execution Flow](./../../images/springclouddataflow/SCDF-composed-task-conditional-execution.webp)

> 이 예제에선 `task-a`, `task-b` 레이블을 사용했다. 레이블이 필요한 이유는 하나의 그래프에 timestamp 애플리케이션이 두 개 있기 때문이다.

이제 페이지 하단에 있는 `Create Task` 버튼을 눌러보자. **Confirm Task Creation**을 요구하는 대화 상자가 나타날 거다. 이제 다음 이미지와 같이 `Name` 필드에 composed 태스크 이름으로 `conditional-execution`을 입력하고 **Create the task** 버튼을 클릭한다:

![Conditional Execution Create](./../../images/springclouddataflow/SCDF-composed-task-conditional-execution-create.webp)

이제 Task Definition 페이지가 보이면, 다음 이미지와 같이 세 가지 태스크 정의가 생성된 것을 확인할 수 있다:

![Conditional Execution Task Definition Listing](./../../images/springclouddataflow/SCDF-composed-task-conditional-execution-task-definition.webp)

1. `conditional-execution` 태스크 정의는 유향 그래프<sup>directed graph</sup>의 실행을 관리하는 `Composed-Task-Runner` 애플리케이션이다.
2. `conditional-execution-task-a`는 앞에서 입력한 DSL에 정의돼 있는 `task-a` 앱을 나타내는 태스크 정의다.
3. `conditional-execution-task-b`는 앞에서 입력한 DSL에 정의돼 있는 `task-b` 앱을 나타내는 태스크 정의다.

### Launch Conditional Execution Composed Task Definition

composed 태스크를 시작하려면, 다음 이미지와 같이 `conditional-execution`이라는 태스크 정의 왼쪽에 있는 드롭다운 아이콘을 클릭하고 **Launch** 옵션을 선택해라:

![Conditional Execution Task Definition Launch](./../../images/springclouddataflow/SCDF-composed-task-conditional-execution-launch.webp)

이제 task launch 페이지가 나타날 거다. 앱 기본값만 사용할 거기 때문에, 아래 이미지처럼 **LAUNCH TASK** 버튼만 눌러주면 된다:

![Conditional Execution Task Definition Launch](./../../images/springclouddataflow/SCDF-composed-task-conditional-execution-launch-verify.webp)

`conditional-execution`이라는 composed 태스크를 시작하면, `conditional-execution-task-a` 태스크가 시작되고, 성공적으로 완료되면 `conditional-execution-task-b` 태스크가 시작된다. `conditional-execution-task-a`가 실패했을 때는 `conditional-execution-task-b`는 실행되지 않는다.

### Check the Status of the Conditional Execution Composed Task Definition

`conditional-execution` 태스크 정의를 실행해봤기 때문에, 이제 태스크 실행 상태를 확인해보면 된다. **Tasks** 페이지 상단에 있는 **Executions** 탭을 클릭해보자. 이 탭에선 `conditional-execution`(`Composed-Task-Runner`)이 각 자식 앱들(`conditional-execution-task-a`, `conditional-execution-task-b`)을 성공적으로 실행한 것을 확인할 수 있다:

![Conditional Execution Flow](./../../images/springclouddataflow/SCDF-composed-task-conditional-execution-list.webp)

---

## Transitional Execution

Transition을 사용하면 플로우에서 따라갈 트리를 분기할 수 있다. 태스크 transition은 `->` 기호로 표현한다. 시연을 위해 기본적인 transition 그래프를 만들어보자.

### Create Basic Transition Task Definition

Spring Cloud Data Flow UI에서 기본적인 transition을 생성하려면, 대시보드 왼편에 있는 **Tasks** 탭을 클릭한 다음, 페이지 상단의 **CREATE TASK** 버튼을 눌러라. 이제 아래 표현식을 복사해서 페이지 상단에 위치해 있는 텍스트 상자에 붙여넣어라:

```sh
transition-sample 'FAILED' -> task-a 'COMPLETED' -> task-b
```

다음과 같은 그래프가 보일 거다:

![Transition Execution Flow](./../../images/springclouddataflow/SCDF-composed-task-transition.webp)

> DSL을 직접 입력하는 대신에, Spring Cloud Data Flow UI의 드래그 앤 드롭 기능을 사용해서 그래프를 그릴 수 있다.

이제 그래프가 렌더링됐으므로 세부 정보를 파헤쳐보자. 가장 먼저 실행되는 애플리케이션은 `transition-sample`이다. `transition-sample`은 Spring Cloud Task 애플리케이션이므로, 실행 종료 시에 Spring Cloud Task에서 데이터베이스에 종료 메세지를 기록한다. 이 메세지는 아래 있는 값 중 하나를 가진다:

- `COMPLETED`: 태스크가 성공적으로 완료됐다.
- `FAILED`: 태스크가 실행 중에 실패했다.
- 커스텀 종료 메세지: [Spring Cloud Task 문서](https://docs.spring.io/spring-cloud-task/docs/2.3.3/reference/html/#features-task-execution-listener-exit-messages)에서 설명하고 있는 것 처럼, Spring Cloud Task 애플리케이션은 커스텀 종료 메세지를 반환할 수 있다.

composed task runner는 `transition-sample` 애플리케이션의 실행이 완료되면 `transition-sample`의 종료 메세지를 확인해서 어떤 경로를 따라가야 하는지 판단한다. 이 예제에선 두 가지 경로가 있다 (`->` 연산자로 나타냈던 경로).

- `FAILED`: `transition-sample`이 `FAILED`를 반환하면, `task-a` 레이블을 가지고 있는 `timestamp` 앱을 실행한다.
- `COMPLETED`: `transition-sample`이 `COMPLETED`를 반환하면, `task-b` 레이블을 가지고 있는 `timestamp` 앱을 실행한다.

이제 페이지 하단에 있는 **Create Task** 버튼을 눌러보자. **Confirm Task Creation**을 요구하는 대화 상자가 나타날 거다. 이제 다음 이미지와 같이 `Name` 필드에 composed 태스크 이름으로 `basictransition`을 입력하고 **Create the task** 버튼을 클릭한다:

![Transition Execution Flow](./../../images/springclouddataflow/SCDF-composed-task-transition-create.webp)

### Launch the Composed Task Definition

이제 composed 태스크를 두 번 실행해보면 이 트리를 구성하는 각 경로들을 실습해볼 수 있다.

먼저 종료 메세지를 `FAILED`로 설정하면 어떻게 되는지부터 알아보자. 다음 이미지와 같이 실행할 `basictransition` `Composed Task Runner`를 선택해라:

![Transition Execution Flow Launch](./../../images/springclouddataflow/SCDF-composed-task-transition-launch.webp)

이제 task launch 페이지에서 다음과 같이 값을 설정해준다:

먼저 composed task runner가 실행 결과를 확인할 간격을 1000ms로 설정해라. 아래와 같이 `Global`  컬럼 밑에서 `CTR properties`에 있는 `EDIT` 버튼을 클릭하면 된다:

![Transition Execution Set Interval Time Prop ](./../../images/springclouddataflow/SCDF-composed-task-transition-launch-ctr-prop-edit.webp)

이제 `interval-time-between-checks` 필드에 1000을 입력한다

![Transition Execution Set Interval Time Prop Set](./../../images/springclouddataflow/SCDF-composed-task-transition-launch-ctr-prop-set.webp)

`UPDATE` 버튼을 클릭해라.

이제 transition 앱이 종료 메세지로 `FAILED`를 반환하도록 설정해 보자. `transition-sample` 컬럼 아래에서 `Application properties`에 있는 `EDIT` 버튼을 클릭하면 된다. 업데이트 대화 상자가 나타나면 `exit-message` 행에 아래와 같이 `FAILED`를 입력해라:

![Transition Execution app Prop Set](./../../images/springclouddataflow/SCDF-composed-task-transition-launch-app-prop-set.webp)

`UPDATE` 버튼을 클릭해라.

이번엔 `LAUNCH TASK` 버튼을 클릭한다. 이제 실행이 완료되었으므로, 실제로 `FAILED` 경로대로 따라갔는지 확인해볼 수 있다. task 페이지 왼편에 있는 **Task executions** 탭을 클릭하면 된다:

![Transition Execution Flow Launch-List](./../../images/springclouddataflow/SCDF-composed-task-transition-launch-fail-list.webp)

그러면 composed 태스크의 실행을 제어하는 `Composed Task Runner` `basictransition`과, `transition-sample`이 실행되었음을 확인할 수 있다. 여기서부터는 `basictransition-task-a was launch`를 보면 알 수 있듯이 `FAILED` 브랜치가 실행됐다.

이번엔 `Composed Task Runner`를 다시 실행하고 `exit-message`를 `COMPLETED`로 설정해 다른 브랜치를 실행해보자. 아래 이미지처럼 실행할 `basictransition`을 선택해라:

![Transition Execution Flow Launch](./../../images/springclouddataflow/SCDF-composed-task-transition-launch.webp)

`transition-sample` 컬럼 아래에서 `Application properties`에 있는 `EDIT` 버튼을 클릭하면 된다. 업데이트 대화 상자가 나타나면 `exit-message` 행에 아래와 같이 `COMPLETED`를 입력해라:

![Transition Execution app Prop Set](./../../images/springclouddataflow/SCDF-composed-task-transition-launch-app-prop-set-completed.webp)

`UPDATE` 버튼을 클릭한다.

`LAUNCH TASK` 버튼을 클릭한다.

이제 실행이 완료되었으므로, 실제로 `COMPLETED` 경로대로 따라갔는지 확인해볼 수 있다. 페이지 왼편에 있는 `Task executions` 탭을 누르면 된다:

![Transition Execution Flow Launch-CompleteList](./../../images/springclouddataflow/SCDF-composed-task-transition-launch-completed-list.webp)

#### Are There More States to a Transition?

이제 종료 메세지에 `FOO`를 입력하면 어떻게 될까?

다음 이미지 같이 실행할 `basictransition` `Composed Task Runner`를 선택해보자:

![Transition Execution Flow Launch](./../../images/springclouddataflow/SCDF-composed-task-transition-launch.webp)

launch 페이지가 보이면 `transition-sample` 컬럼 아래에서 `Application properties`에 있는 `EDIT` 버튼을 클릭해라. 업데이트 대화 상자가 나타나면 exit-message 행에 아래와 같이 `FOO`를 입력해라:

![Transition Execution Flow Launch-Config-FOO](./../../images/springclouddataflow/SCDF-composed-task-transition-launch-foo-fail.webp)

`UPDATE` 버튼을 클릭한다.

`LAUNCH TASK` 버튼을 클릭한다.

이제 실행이 완료되었으므로, 실제로 `FOO` 경로대로 따라갔는지 확인해볼 수 있다. 페이지 왼편에 있는 **Task executions** 탭을 누르면 된다:

![Transition Execution Flow Launch-FOO-LIST](./../../images/springclouddataflow/SCDF-composed-task-transition-launch-foo-fail-list.webp)

이번에는 composed 태스크가 `Composed Task Runner`와 transition sample만 실행하고 종료되었음을 확인 수 있다. `FOO`는 대상에 없었기 때문이다. `COMPLETED`, `FAILED`와, 그외 모든 항목을 경로로 가지려면 어떻게 해야 할까?

이번엔 와일드 카드를 사용해서 composed 태스크를 하나 더 만들어보자.

Spring Cloud Data Flow UI에서 기본적인 transition을 생성하려면, 대시보드 왼편에 있는 **Tasks** 탭을 클릭한 다음, 페이지 상단의 **CREATE TASK** 버튼을 눌러라. 이제 아래 표현식을 복사해서 페이지 상단에 위치해 있는 텍스트 상자에 붙여넣어라:

```sh
transition-sample 'FAILED' -> task-a 'COMPLETED' -> task-b '*' -> task-c
```

아래 이미지와 같은 그래프가 생기는 걸 볼 수 있다:

![Transition Execution Foo_Flow](./../../images/springclouddataflow/SCDF-composed-task-foo-transition.webp)

이제 페이지 하단에 있는 **Create Task** 버튼을 눌러보자. **Confirm Task Creation**을 요구하는 대화 상자가 나타날 거다. 이제 다음 이미지와 같이 `Name` 필드에 composed 태스크 이름으로 `anothertransition`을 입력하고 **Create the task** 버튼을 클릭한다:

![Transition Execution Foo_Flow_Create](./../../images/springclouddataflow/SCDF-composed-task-foo-transition-create.webp)

이 태스크를 실행하려면 다음 이미지와 같이 `anothertransition` `Composed Task Runner`를 선택해라:

![Transition Execution Flow Launch-Another](./../../images/springclouddataflow/SCDF-composed-task-transition-launch-another.webp)

이제 task launch 페이지에서 다음과 같이 값을 설정해준다:

Arguments:

```sh
--increment-instance-enabled=true
--interval-time-between-checks=1000
```

Parameters:

```properties
app.anothertransition.transition-sample.taskapp.exitMessage=FOO
```

launch 페이지가 나타나면 `transition-sample` 컬럼 아래에서 `Application properties`에 있는 `EDIT` 버튼을 클릭해라. 업데이트 대화 상자가 나타나면 exit-message 행에 아래와 같이 `FOO`를 입력해라:

![Transition Execution Flow Launch-Config-FOO](./../../images/springclouddataflow/SCDF-composed-task-transition-launch-foo-fail.webp)

`UPDATE` 버튼을 클릭해라.

`LAUNCH TASK` 버튼을 클릭해라.

이제 실제로 `FOO` 경로대로 따라갔는지 확인해보자. task 페이지에서 **Eexecutions** 탭을 누르면 된다:

![Transition Execution Flow Launch-FOO-success-LIST](./../../images/springclouddataflow/SCDF-composed-task-transition-launch-foo-success-list.webp)

이렇게하면 와일드카드가 다른 모든 종료 메세지를 받아낸다는 것을 확인할 수 있다. `anothertransition-task-c`가 실행된 것을 보면 알 수 있다.

---

## Split Execution

동시에 여러 가지 태스크를 실행하고 싶다면 어떨까? Composed Task DSL은 split 개념을 지원하기 때문에 가능하다. 태스크 정의 DSL은 동시에 여러 태스크 앱들을 실행할 수 있는 split 개념을 지원한다. 각 split은 less than `<`, greater than `>`  기호 안에 태스크 리스트를 가지고 있으며, 각 태스크들은 이중 파이프 기호(`||`)로 구분한다.
예를 들어 세 가지 태스크를 동시에 시작할 땐 DSL을 다음과 같이 작성한다:

```sh
<task-a || task-b || task-c>
```

split과 transition을 함께 쓸 수 있다는 것을 보여주기 위해서, 이번에는 split과 transition을 모두 가지는 composed 태스크를 만들어 보겠다. Spring Cloud Data Flow UI에서 split 그래프 샘플을 생성하려면, 대시보드 왼편에 있는 **Tasks** 탭을 클릭한 다음, 페이지 상단의 **CREATE TASK** 버튼을 눌러라. 이제 아래 표현식을 복사해서 페이지 상단에 있는 텍스트 상자에 붙여넣어라:

```sh
<task-a || task-b || task-c>  && transition-sample 'FAILED' -> task-d 'COMPLETED' -> task-e '*' -> task-f
```

아래 이미지와 같은 그래프가 생기는 걸 볼 수 있다:

![Transition Execution Split_Flow](./../../images/springclouddataflow/SCDF-composed-task-split.webp)

이제 페이지 하단에 있는 **Create Task** 버튼을 눌러보자. **Confirm Task Creation**을 요구하는 대화 상자가 나타날 거다. 이제 다음 이미지와 같이 `Name` 필드에 composed 태스크 이름으로 `splitgraph`를 입력하고 **Create the task** 버튼을 클릭한다:

![Transition Execution Split_Flow_Create](./../../images/springclouddataflow/SCDF-composed-task-split-create.webp)

다음 이미지와 같이 실행할 `splitgraph` `Composed Task Runner`를 선택해라:

![Transition Execution Flow SplitLaunch](./../../images/springclouddataflow/SCDF-composed-task-split-launch.webp)

task launch 페이지에서 composed task runner를 설정해보자. 아래와 같이 `Global`  컬럼 밑에서 `CTR properties`에 있는 `EDIT` 버튼을 클릭하면 된다:

![Transition Execution Set Interval Time Prop ](./../../images/springclouddataflow/SCDF-composed-task-transition-launch-ctr-prop-edit.webp)

이번에는:

- `interval-time-between-checks` 필드에 `1000`을 입력한다
- thread-core-pool-size 필드에 `4`를 입력한다
- closecontext-enabled 필드에 `true`를 입력한다

다음과 같이 보이면 된다:

![Transition Execution Set Interval Time Prop Set](./../../images/springclouddataflow/SCDF-composed-task-transition-launch-ctr-prop-set.webp)

`UPDATE` 버튼을 클릭해라.

`transition-sample` 컬럼 아래에서 `Application properties`에 있는 `EDIT` 버튼을 클릭해라. 업데이트 대화 상자가 나타나면 exit-message 행에 아래와 같이 `FOO`를 입력해라:

![Transition Execution Flow Launch-Config-FOO](./../../images/springclouddataflow/SCDF-composed-task-transition-launch-foo-fail.webp)

`UPDATE` 버튼을 클릭한다.

`LAUNCH TASK` 버튼을 클릭한다.

모든 태스크가 실행되었는지와 실제로 `FOO` 경로대로 따라갔는지를 검증해보자. 페이지 왼편에 있는 **Task executions** 탭을 클릭하면 된다:

![Transition Execution Flow Launch-split-LIST](./../../images/springclouddataflow/SCDF-composed-task-split-launch-created-list.webp)

이 예제에선 CTR이 transition 앱을 시작하기 전에 먼저 `splitgraph-task-a`, `splitgraph-task-b`, `splitgraph-task-c`가 동시에 실행되었음을 알 수 있다. 처음보는 인자 `--split-thread-core-pool-size=4`도 추가했었다. 이 인자는 composed task runner는 기본적으로 4개의 앱을 동시에 실행할 수 있다는 뜻이다.

### Arguments and Properties

다시 돌아가서, 커맨드라인에 넣었던 것들은 죄다 뭐였을까? 사실 이 예시에선 커맨드라인 인자와 프로퍼티 사용법을 모두 보여주고 싶었다. `Composed Task Runner`의 프로퍼티를 설정할 땐 아래 인자들을 사용했었다:

1. `interval-time-between-checks=1000`은 `Composed Task Runner`가 태스크가 완료됐는지 확인할 때마다 1초씩 대기한다는 뜻이다 (디폴트는 10초다).
2. `split-thread-core-pool-size=4`는 동시에 최대 4개의 태스크를 실행하고 싶다는 뜻이다.
3. `closecontext-enabled=true`는 `Composed Task Runner`를 실행할 때 스프링 컨텍스트를 close하고 싶다는 뜻이다.

> `split`을 사용할 땐 반드시 위와 같이 `spring.cloud.task.closecontext-enabled` 프로퍼티를 설정해줘야 한다.

### Configuring Your Split

앞 섹션에서 보여준 예제에선 `spring.cloud.task.closecontext-enabled`, `split-thread-core-pool-size` 프로퍼티를 사용해 composed 태스크의 split 동작을 설정했었다. split을 사용할 땐 아래 프로퍼티들도 사용할 수 있다:

- `spring.cloud.task.closecontext-enabled`: split을 사용할 땐 이 프로퍼티는 `true`로 설정해야 한다 (split 지원을 위해 스레드들을 할당했기 때문에). 그렇지 않으면 컨텍스트가 close되지 않는다.
- `split-thread-core-pool-size`: composed 태스크의 split에 필요한 초기 스레드 수를 설정한다. split에 포함된 각 태스크 앱을 실행하려면 스레드가 필요하다. (1이 디폴트)
- `split-thread-max-pool-size`: 최대로 할당할 스레드 수.
- `split-thread-queue-capacity`: 모든 스레드가 사용 중일 때, 새 스레드 할당 전 대기열에 넣어야 하는 태스크 수.

### Basic Split Sizing

가장 간단한 split 설정은 `split-thread-core-pool-size` 프로퍼티를 설정하는 거다. 아마 그래프를 보고 가장 태스크 수가 많은 split의 태스크 수를 세어보고 싶을 거다. 이 숫자가 바로 필요한 스레드 수다. 스레드 수를 설정할 땐 이 `split-thread-core-pool-size` 프로퍼티를 사용한다 (기본값은 1). 예를 들어, `<AAA || BBB || CCC> && <DDD || EEE>`와 같은 정의는 split-thread-core-pool-size 3이 필요하다. 가장 큰 split에 태스크가 3개 있기 때문이다. 2로 설정하게 되면, AAA와 BBB는 병렬로 실행되지만, CCC는 AAA나 BBB가 완료될 때까지 기다릴 거다. 이후 DDD와 EEE는 병렬로 실행된다.

---

## Restarting Composed Task Runner when task app fails

Spring Cloud Data Flow에선 composed 태스크 안에 있는 태스크 앱이 실패하면 composed 태스크를 다시 실행할 수 있다. 워크플로 안에 있는 태스크 애플리케이션이 0이 아닌 `exitCode`를 반환하면 실패한 것으로 간주 한다.

### Detecting a failed composed task

composed 태스크를 기동하면, Composed Task Runner라는 애플리케이션이 composed 태스크의 실행을 관리한다. Composed Task Runner는 스프링 배치를 사용해서 만들었기 때문에, Spring Cloud Data Flow에서 composed 태스크 실행의 성공/실패 여부를 추적할 땐 Job Executions 페이지를 사용한다.

> 워크플로를 관리하는 composed 태스크 job이 실패했을 때는, Command Line Runner에 연결되는 종료 코드는 `0`이 된다. 이는 배치 job의 디폴트 부팅 동작에 해당한다. 하지만 composed job이 실패했을 땐 종료 코드 `1`이 필요하다면, composed task runner에 `spring.cloud.task.batch.fail-on-job-failure` 프로퍼티를 `true`로 설정해라.

### Example

이번에는 conditional execution을 이용한 간단한 composed 태스크를 예시로 다뤄보자:

```sh
task-a && task-b && task-c
```

`my-composed-task`라는 composed 태스크를 생성했고, 이제 UI를 사용해 기동시켜볼 참이라고 해보자:

1. 아래와 같이 `play` 버튼을 눌러 기동시킨다:
   
   ![Restart Composed Task](./../../images/springclouddataflow/SCDF-composed-task-restart.webp)
   
2. launch page가 뜨면 `LAUNCH TASK` 버튼을 누른다.
   
3. `my-composed-task` 실행을 완료했더니, `task-b`에는 애플리케이션이 0 이외의 `exitCode`를 반환했음을 의미하는 `ERROR`가 표시된 게 보인다. 페이지 상단의 **Executions** 탭을 클릭하고 task executions를 보면 확인할 수 있다. `my-composed-task-task-b`는 종료 코드 `1`로 표시돼 있다. 이 태스크 앱이 composed 태스크 실행을 중지하는 0이 아닌 종료 코드를 반환했다는 뜻이다.
   
   ![Restart_Composed_Task_Failed_Child](./../../images/springclouddataflow/SCDF-composed-task-restart-execution-fail.webp)
   
   실패의 원인을 알아내고 문제를 해결했다면 `my-composed-task`를 재시작할 수 있으며, composed task runner는 실패한 태스크 앱을 식별해 다시 실행시킨 다음 해당 지점에서부터 DSL 실행을 이어나간다.
   
4. 페이지 왼편에 위치한 `Jobs` 탭을 눌러보자.
   
5. 이번엔 실패한 `my-composed-task`에서 드롭다운 버튼을 누르고 **Restart the job**을 선택해라:
   
   ![Restart Composed Task Job](./../../images/springclouddataflow/SCDF-composed-task-restart-job.webp)
   
6. composed 태스크가 완료되면 `COMPLETED` 상태를 가지고 있는 새 `my-composed-task` job이 보인다.
   
   ![Restart Composed Task Complete](./../../images/springclouddataflow/SCDF-composed-task-restart-job-complete.webp)
   
7. 이제 페이지 왼편에서 **Tasks** 탭을 클릭하고 Task Definition 페이지가 나타나면 상단의 **Executions** 탭을 클릭해라. `Composed Task Run` 이 두 개 있는 것에 주목해라. 첫 번째는 `task-b`에서 실패했던 실패한 composed 태스크 실행 내역이다. 그 다음 두 번째 실행에선 `my-composed-task` `Composed Task Runner`가 아래 이미지에서처럼 실패한 태스크 앱(`task-b`)에서 그래프를 시작하고 composed 태스크를 완료한 것을 확인할 수 있다:
   
   ![Restart Composed Task Execution](./../../images/springclouddataflow/SCDF-composed-task-restart-exec-complete.webp)

---

# Passing Properties

Spring Cloud Data Flow에선 애플리케이션 프로퍼티와 배포 프로퍼티를 모두 `Composed Task Runner`와 그래프 안에 있는 태스크 앱들에 전달할 수 있다.

---

## Passing Properties to Tasks in the Graph

그래프 안에 있는 태스크에는 다음 두 가지 방법으로 프로퍼티를 설정할 수 있다:

- 태스크를 정의할 때 프로퍼티를 설정한다.
- composed 태스크 실행 시점에 프로퍼티를 설정한다.

### Setting property in the task definition

composed 태스크 정의를 작성할 땐 프로퍼티를 설정할 수 있다. composed 태스크 정의에서 태스크 애플리케이션 이름 오른쪽에 `--` 토큰을 추가해 프로퍼티를 넣어주면 된다. 아래 예제를 참고해라:

```sh
task-a --myproperty=value1 --anotherproperty=value2 && task-b --mybproperty=value3
```

위 예제에선 `task-a`엔 두 가지 프로퍼티를 설정하고, `task-b`엔 한 가지 프로퍼티를 설정하고 있다.

### Setting Property at Composed Task Launch Time

앞 섹션에서 보여줬듯이, 배포 프로퍼티와 애플리케이션 프로퍼티는 task launch 페이지에 있는 `builder` 탭을 이용해 설정할 수 있다. 하지만 프로퍼티를 직접 텍스트로 입력하고 싶다면 `Freetext` 탭을 클릭하면 된다.

프로퍼티는 세 가지 요소로 구성한다:

- 프로퍼티 타입: Spring Cloud Data Flow에 이 프로퍼티가 `deployment` 타입인지, `app` 타입인지를 알려준다.
  - Deployment properties: 태스크 앱 배포를 담당하는 deployer에게 전달할 지시들.
  - App properties: 태스크에 앱에 직접 전달할 프로퍼티들.
- 태스크 앱 이름: 프로퍼티를 적용해야 하는 애플리케이션의 레이블 또는 이름.
- 프로퍼티 키: 설정할 프로퍼티의 키.

다음 dsl로 만든 `my-composed-task` composed 태스크에서, `task-a` 태스크 앱에 `myproperty` 프로퍼티를 설정해보자:

```sh
task-a && task-b
```

이럴 땐 다음과 같이 설정할 수 있다:

![Property Diagram](./../../images/springclouddataflow/SCDF-composed-task-child-property-diagram.webp){: .center-image }

deployer 프로퍼티를 전달할 때도 마찬가지로, 프로퍼티 타입이 `deployer`라는 점만 빼고는 동일한 형식으로 설정한다. 예를 들어, `task-a`에 `kubernetes.limits.cpu`를 설정해야 한다면:

```properties
deployer.task-a.kubernetes.limits.cpu=1000m
```

composed 태스크를 시작하면서 `app`, `deployer` 프로퍼티를 설정하는 일은 모두, 다음과 같이 UI의 `Freetext` 탭을 사용해도 가능하다:

1. 아래 이미지에서처럼, 실행해야 하는 composed 태스크 정의 옆에 있는 `Launch` 항목을 눌러 composed 태스크를 시작한다:
   
   ![Specify Which Composed Task to Launch](./../../images/springclouddataflow/SCDF-composed-task-child-property-example-launch.webp)

2. `Properties` 텍스트 상자에서 다음과 같이 프로퍼티를 설정한다:
   
   ![Launch the Composed Task](./../../images/springclouddataflow/SCDF-composed-task-child-property-launch-props.webp)

3. 이제 **LAUNCH TASK** 버튼을 누른다.

> 기동 시점에 설정한 프로퍼티는 태스크 정의 시점에 설정한 프로퍼티보다 우선 순위가 높다. 예를 들어 composed 태스크 정의에도 `myproperty` 프로퍼티가 설정돼 있고 실행 시점에도 같은 프로퍼티를 설정해준다면, 실행 시 설정한 값을 사용한다.

---

## Setting Arguments at Composed Task Launch Time

앞 섹션에서 보여줬듯이, 인자는 task launch 페이지에 있는 `builder` 탭을 이용해 설정할 수 있다. 하지만 인자를 직접 텍스트로 입력하고 싶다면 `Freetext` 탭을 클릭하면 된다.

세 가지 요소로 프로퍼티를 구성한다:

- 인자 타입: 항상 `app` 타입이다.
- 태스크 앱 이름: 프로퍼티를 적용해야 하는 애플리케이션의 레이블 또는 이름.
- 인덱스: 인자를 추가할 위치 (zero base).

다음 dsl로 만든 `my-composed-task` composed 태스크에서, `task-a` 태스크 앱에 `myargumentA`, `myargumentB` 인자를 설정해보자:

```sh
task-a && task-b
```

이럴 땐 다음과 같이 설정할 수 있다:

![Property Diagram](./../../images/springclouddataflow/SCDF-composed-task-child-argument-diagram.webp){: .center-image }

다음과 같이 UI에서 `Freetext` 탭을 사용하면, composed 태스크를 시작하면서 인자를 설정할 수 있다:

1. 아래 이미지에서처럼, 실행해야 하는 composed 태스크 정의 옆에 있는 `Launch` 항목을 눌러 composed 태스크를 시작한다:
   
   ![Specify Which Composed Task to Launch](./../../images/springclouddataflow/SCDF-composed-task-child-property-example-launch.webp)

2. `Arguments` 텍스트 상자에서 다음과 같이 인자를 설정한다:
   
   ![Launch the Composed Task](./../../images/springclouddataflow/SCDF-composed-task-child-argument-launch.webp)

3. 이제 **LAUNCH TASK** 버튼을 누른다.

---

## Passing Properties to Composed Task Runner

세 가지 요소로 프로퍼티를 구성한다:

- 프로퍼티 타입: Spring Cloud Data Flow에 이 프로퍼티가 `deployment` 타입인지, `app` 타입인지를 알려준다.
  - Deployment properties: 태스크 앱 배포를 담당하는 deployer에게 전달할 지시들.
  - App properties: 태스크에 앱에 직접 전달할 프로퍼티들.
- Composed 태스크 애플리케이션 이름: composed task runner 앱의 이름.
- 프로퍼티 키: 설정할 프로퍼티의 키.

다음 프로퍼티들을 `Composed Task Runner`에 전달하는 composed 태스크를 시작해보자:

- `increment-instance-enabled`: 파라미터 변경이 없이 같은 `Composed Task Runner` 인스턴스를 재실행할 수 있게 해주는 `app` 프로퍼티.
- `kubernetes.limits.cpu`: composed task runner에 쿠버네티스 CPU 제한을 설정하는 `deployer` 프로퍼티. 

UI에서 composed 태스크를 시작하고 `Composed Task Runner`에 `app`, `deployer` 프로퍼티 설정하는 일은 다음과 같이 진행할 수 있다:

- 아래 이미지에서처럼, 실행해야 하는 composed 태스크 정의 옆에 있는 `play` 버튼을 눌러 composed 태스크를 시작한다:

  ![Specify Which Composed Task to Launch](./../../images/springclouddataflow/SCDF-composed-task-child-property-example-launch.webp)

- `properties` 텍스트 상자에서 다음과 같이 프로퍼티를 설정한다:

  ![Launch the Composed Task](./../../images/springclouddataflow/SCDF-composed-task-child-property-launch-ctr-props.webp){: .center-image }

- **LAUNCH TASK** 버튼을 누른다.

---

## Launching Composed Task using RESTful API

이번 섹션에선 composed-task를 생성하고 실행하는 또 다른 방법을 보여준다.

이번에는 다음과 같은 composed 태스크 정의를 사용하는 `my-composed-task`를 만들어보려 한다:

```sh
task-a && task-b
```

`curl` 명령어는 다음과 같다:

```sh
curl 'http://localhost:9393/tasks/definitions' --data-urlencode "name=my-composed-task" --data-urlencode "definition=task-a && task-b"
```

Spring Cloud Data Flow 서버는 다음과 같은 응답을 보낼 거다:

```http
HTTP/1.1 200
Content-Type: application/hal+json
Transfer-Encoding: chunked
Date: Fri, 17 Jan 2020 16:19:04 GMT

{"name":"my-composed-task","dslText":"task-a && task-b","description":"","composed":true,"lastTaskExecution":null,"status":"UNKNOWN","_links":{"self":{"href":"http://localhost:9393/tasks/definitions/my-composed-task"}}}
```

`my-composed-task`가 생성되었는지 검증해보려면, curl 명령어를 다시 날려보면 된다:

```sh
curl 'http://localhost:9393/tasks/definitions?page=0&size=10&sort=taskName' -i -X GET
```

Spring Cloud Data Flow 서버는 다음과 같은 응답을 보낼 거다:

```http
HTTP/1.1 200
Content-Type: application/hal+json
Transfer-Encoding: chunked
Date: Fri, 17 Jan 2020 16:24:39 GMT

{"_embedded":{"taskDefinitionResourceList":[{"name":"my-composed-task","dslText":"task-a && task-b","description":"","composed":true,"lastTaskExecution":null,"status":"UNKNOWN","_links":{"self":{"href":"http://localhost:9393/tasks/definitions/my-composed-task"}}},{"name":"my-composed-task-task-a","dslText":"task-a","description":null,"composed":false,"lastTaskExecution":null,"status":"UNKNOWN","_links":{"self":{"href":"http://localhost:9393/tasks/definitions/my-composed-task-task-a"}}},{"name":"my-composed-task-task-b","dslText":"task-b","description":null,"composed":false,"lastTaskExecution":null,"status":"UNKNOWN","_links":{"self":{"href":"http://localhost:9393/tasks/definitions/my-composed-task-task-b"}}}]},"_links":{"self":{"href":"http://localhost:9393/tasks/definitions?page=0&size=10&sort=taskName,asc"}},"page":{"size":10,"totalElements":3,"totalPages":1,"number":0}}
```

 task-a에 아래와 같은 프로퍼티를 사용해서 `my-composed-task`를 실행해보자:

- `app.task-a.my-prop=good`
- `app.task-b.my-prop=great`

아래 curl 명령어를 실행해 태스크를 실행해라:

```sh
curl 'http://localhost:9393/tasks/executions' -i -X POST -d 'name=my-composed-task&properties=app.task-a.my-prop=good,%20app.task-b.my-prop=great'
```

Spring Cloud Data Flow 서버는 다음과 같은 응답을 보낼 거다:

```http
HTTP/1.1 201
Content-Type: application/json
Transfer-Encoding: chunked
Date: Fri, 17 Jan 2020 16:33:06 GMT
```

`my-composed-task`가 실행되었는지 검증해보려면, curl 명령어를 다시 날려보면 된다:

```sh
curl 'http://localhost:9393/tasks/executions?page=0&size=10' -i -X GET
```

Spring Cloud Data Flow 서버는 다음과 같은 응답을 보낼 거다:

```http
HTTP/1.1 200
Content-Type: application/hal+json
Transfer-Encoding: chunked
Date: Fri, 17 Jan 2020 16:35:42 GMT

{"_embedded":{"taskExecutionResourceList":[{"executionId":285,"exitCode":0,"taskName":"my-composed-task-task-b","startTime":"2020-01-17T11:33:24.000-0500","endTime":"2020-01-17T11:33:25.000-0500","exitMessage":null,"arguments":["--spring.cloud.task.parent-execution-id=283","--spring.cloud.data.flow.platformname=default","--spring.cloud.task.executionid=285"],"jobExecutionIds":[],"errorMessage":null,"externalExecutionId":"my-composed-task-task-b-217b8de4-8877-4350-8cc7-001a4347d3b5","parentExecutionId":283,"resourceUrl":"URL [file:////Users/glennrenfro/project/spring-cloud-dataflow-samples/pauseasec/target/pauseasec-1.0.0.BUILD-SNAPSHOT.jar]","appProperties":{"spring.datasource.username":"******","my-prop":"great","spring.datasource.url":"******","spring.datasource.driverClassName":"org.mariadb.jdbc.Driver","spring.cloud.task.name":"my-composed-task-task-b","spring.datasource.password":"******"},"deploymentProperties":{"app.task-b.my-prop":"great"},"taskExecutionStatus":"COMPLETE","_links":{"self":{"href":"http://localhost:9393/tasks/executions/285"}}},{"executionId":284,"exitCode":0,"taskName":"my-composed-task-task-a","startTime":"2020-01-17T11:33:15.000-0500","endTime":"2020-01-17T11:33:15.000-0500","exitMessage":null,"arguments":["--spring.cloud.task.parent-execution-id=283","--spring.cloud.data.flow.platformname=default","--spring.cloud.task.executionid=284"],"jobExecutionIds":[],"errorMessage":null,"externalExecutionId":"my-composed-task-task-a-0806d01f-b08a-4db5-a4d2-ab819e9df5df","parentExecutionId":283,"resourceUrl":"org.springframework.cloud.task.app:timestamp-task:jar:2.1.0.RELEASE","appProperties":{"spring.datasource.username":"******","my-prop":"good","spring.datasource.url":"******","spring.datasource.driverClassName":"org.mariadb.jdbc.Driver","spring.cloud.task.name":"my-composed-task-task-a","spring.datasource.password":"******"},"deploymentProperties":{"app.task-a.my-prop":"good"},"taskExecutionStatus":"COMPLETE","_links":{"self":{"href":"http://localhost:9393/tasks/executions/284"}}},{"executionId":283,"exitCode":0,"taskName":"my-composed-task","startTime":"2020-01-17T11:33:12.000-0500","endTime":"2020-01-17T11:33:33.000-0500","exitMessage":null,"arguments":["--spring.cloud.data.flow.platformname=default","--spring.cloud.task.executionid=283","--spring.cloud.data.flow.taskappname=composed-task-runner"],"jobExecutionIds":[75],"errorMessage":null,"externalExecutionId":"my-composed-task-7a2ad551-a81c-46bf-9661-f9d5f78b27c4","parentExecutionId":null,"resourceUrl":"URL [file:////Users/glennrenfro/project/spring-cloud-task-app-starters/composed-task-runner/apps/composedtaskrunner-task/target/composedtaskrunner-task-2.1.3.BUILD-SNAPSHOT.jar]","appProperties":{"spring.datasource.username":"******","spring.datasource.url":"******","spring.datasource.driverClassName":"org.mariadb.jdbc.Driver","spring.cloud.task.name":"my-composed-task","composed-task-properties":"app.my-composed-task-task-a.app.task-a.my-prop=good, app.my-composed-task-task-b.app.task-b.my-prop=great","graph":"my-composed-task-task-a && my-composed-task-task-b","spring.datasource.password":"******"},"deploymentProperties":{"app.composed-task-runner.composed-task-properties":"app.my-composed-task-task-a.app.task-a.my-prop=good, app.my-composed-task-task-b.app.task-b.my-prop=great"},"taskExecutionStatus":"COMPLETE","_links":{"self":{"href":"http://localhost:9393/tasks/executions/283"}}}]},"_links":{"self":{"href":"http://localhost:9393/tasks/executions?page=0&size=10"}},"page":{"size":10,"totalElements":3,"totalPages":1,"number":0}}```
```

---

# Configuring Composed Task Runner

이 섹션에선 composed task runner를 설정하는 방법에 대해 설명한다.

---

## Launching a Composed Task When Security is Enabled

Spring Cloud Data Flow 인증을 활성화했을 땐 사용자는 세 가지 옵션으로 composed 태스크를 시작할 수 있다:

- 기본 인증: username과 password를 사용한 인증.
- 사용자가 설정하는 액세스 토큰: composed 태스크를 시작할 때 `dataflow-server-access-token` 프로퍼티로 기동 시 사용할 토큰을 제공한다.
- Data Flow가 제공하는 유저 토큰: `dataflow-server-use-user-access-token` 프로퍼티를 `true`로 설정하면, Spring Cloud Data Flow는 `dataflow-server-access-token` 프로퍼티를 현재 로그인한 사용자의 액세스 토큰으로 자동으로 채워준다.
- 클라이언트 Credentials: composed 태스크를 시작할 때 클라이언트 credential을 통해 액세스 토큰을 획득한다.

### Basic Authentication

사용자가 username과 password를 제공하는 방법으로 composed 태스크를 시작하려면:

1. 아래 이미지에서처럼, 실행할 composed 태스크 정의 옆에 있는 `Launch` 항목을 눌러 composed 태스크를 시작한다:

   ![Set User Access Token](./../../images/springclouddataflow/SCDF-composed-task-user-security-launch.webp)
   
2. 이제 task launch 페이지에서 `dataflow-server-username`, `dataflow-server-password` 필드를 채운다. 아래 보이는 것처럼 `Global` 컬럼 아래에서 `CTR properties`에 있는 `EDIT` 버튼을 클릭하면 된다:

   ![Transition Execution Set Interval Time Prop](./../../images/springclouddataflow/SCDF-composed-task-transition-launch-ctr-prop-edit.webp)

   이제 각 필드에 `dataflow-server-username`과 `dataflow-server-password`를 입력한다

   ![Launch Task](./../../images/springclouddataflow/SCDF-composed-task-user-security-basic-launch.webp)

3. `UPDATE` 버튼을 누른다.

4. **LAUNCH TASK** 버튼을 클릭해 composed 태스크를 시작한다.

### Using Your Own Access Token

composed 태스크를 특정한 액세스 토큰으로 시작해야 한다면, `dataflow-server-access-token` 프로퍼티를 사용해 토큰을 전달해라. 그러려면:

1. 아래 이미지에서처럼, 실행할 composed 태스크 정의 옆에 있는 `Launch` 항목을 눌러 composed 태스크를 시작한다:

   ![Set User Access Token](./../../images/springclouddataflow/SCDF-composed-task-user-security-launch.webp)

2. 이제 task launch 페이지에서 `dataflow-server-use-user-access-token`을 채운다. 아래 보이는 것처럼 `Global` 컬럼 아래에서 `CTR properties`에 있는 `EDIT` 버튼을 클릭하면 된다:

   ![Transition Execution Set Interval Time Prop ](./../../images/springclouddataflow/SCDF-composed-task-transition-launch-ctr-prop-edit.webp)

3. 이제 이 필드에 `dataflow-server-access-token`을 입력해라.
   
   ![Set User Access Token](./../../images/springclouddataflow/SCDF-composed-task-user-security-launch-token.webp)

4. **LAUNCH TASK** 버튼을 클릭해 composed 태스크를 시작한다.

### User Access Token

이번에는 `dataflow-server-use-user-access-token`을 `true`로 설정해서 composed 태스크를 시작해볼 거다. 그러려면:

1. 아래 이미지에서처럼, 실행할 composed 태스크 정의 옆에 있는 `Launch` 항목을 눌러 composed 태스크를 시작한다:

   ![Set User Access Token](./../../images/springclouddataflow/SCDF-composed-task-user-security-launch.webp)

2. 이제 task launch 페이지에서 `Freetext`를 선택하고, arguments 필드에 다음과 같이 `dataflow-server-use-user-access-token`을 입력한다:

   ![Launch Task](./../../images/springclouddataflow/SCDF-composed-task-user-security.webp){: .center-image }

3. `UPDATE` 버튼을 누른다.

4. **LAUNCH TASK** 버튼을 클릭해 composed 태스크를 시작한다.

### Client Credentials

composed 태스크가 OAuth 인증 서비스에서 액세스 토큰을 가져와야 할 땐, 다음 프로퍼티를 사용한다:

- oauth2ClientCredentialsClientId
- oauth2ClientCredentialsClientSecret
- oauth2ClientCredentialsTokenUri
- oauth2ClientCredentialsScopes

그러려면:

1. 아래 이미지에서처럼, 실행할 composed 태스크 정의 옆에 있는 `Launch` 항목을 눌러 composed 태스크를 시작한다:

   ![Set User Access Token](./../../images/springclouddataflow/SCDF-composed-task-user-security-launch.webp)

2. 이제 task launch 페이지에서 OAuth client credential 프로퍼티를 채운다. 아래 보이는 것처럼 `Global` 컬럼 아래에서 `CTR properties`에 있는 `EDIT` 버튼을 클릭하면 된다:
   
   ![Transition Execution Set Interval Time Prop ](./../../images/springclouddataflow/SCDF-composed-task-transition-launch-ctr-prop-edit.webp)

3. 이제 각 필드에 `oauth2ClientCredentialsClientId`, `oauth2ClientCredentialsClientSecret`, `oauth2ClientCredentialsTokenUri`, `oauth2ClientCredentialsScopes`를 입력한다.

   ![Set User Access Token](./../../images/springclouddataflow/SCDF-composed-task-client-credentials.webp)

4. **LAUNCH TASK** 버튼을 클릭해 composed 태스크를 시작한다.

> **참고**: 클라이언트 credential, 그 중에서도 특히 OAuth2 클라이언트 Id를 사용하는 경우, `dataflowServerUsername`, `dataflowServerPassword`, `dataflowServerAccessToken` 프로퍼티는 무시된다.

---

## Configure the URI for Composed Tasks

composed 태스크를 시작하면, Spring Cloud Data Flow는 composed 태스크 그래프의 실행을 관리하기 위해 `Composed Task Runner` 애플리케이션을 시작한다. 이 애플리케이션은 Spring Cloud Data Flow 태스크 정의를 파싱한 다음, 태스크 정의를 시작하기 위한 RESTful API를 Spring Cloud Data Flow 서버에 다시 호출한다. 각 태스크가 완료되면 다음 태스크 정의를 시작한다.  `Composed Task Runner`가 RESTful API를 호출할 때 사용할 URI를 설정하려면, Spring Cloud Data Flow 서버에 `SPRING_CLOUD_DATAFLOW_SERVER_URI` 프로퍼티를 설정해야 한다. 아래에선 두 가지 방법을 보여주고 있다:

- Spring Cloud Data Flow 서버를 위한 쿠버네티스 스펙

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  ...
spec:
  ...
  template:
    ...
    spec:
      containers:
        env:
        ...
        - name: SPRING_CLOUD_DATAFLOW_SERVER_URI
          value: '<URI to your SCDF Server>'
        ...
```

- Spring Cloud Data Flow 서버를 위한 클라우드 파운드리 매니페스트.

```yaml
---
applications:
  ...
  env:
    ...
    SPRING_CLOUD_DATAFLOW_SERVER_URI: <URI to your SCDF Server>
  services:
    ...
```