---
title: Batch Processing with Spring Cloud Task
navTitle: Simple Task
category: Spring Cloud Data Flow
order: 44
permalink: /Spring%20Cloud%20Data%20Flow/batch-developer-guides.batch-development.simple-task/
description: Spring Cloud Task를 이용해 태스크 애플리케이션을 개발하고 수동으로 배포해보기
image: ./../../images/springclouddataflow/CF-task-standalone-initial-push-result.webp
lastmod: 2021-12-02T00:33:00+09:00
comments: true
originalRefName: 스프링 클라우드 데이터 플로우
originalRefLink: https://dataflow.spring.io/docs/batch-developer-guides/batch/spring-task/
parent: Batch Developer guides
parentUrl: /Spring%20Cloud%20Data%20Flow/batch-developer-guides/
subparent: Batch Development
subparentUrl: /Spring%20Cloud%20Data%20Flow/batch-developer-guides.batch-development/
---

---

이 가이드에선 Spring Cloud Task를 사용해서 스프링 부트 애플리케이션을 개발하고 클라우드 파운드리와, 쿠버네티스, 로컬 머신에 배포해본다. [태스크 애플리케이션을 Data Flow로 배포](../batch-developer-guides.batch-development.data-flow-simple-task)하는 방법은 별도 가이드에서 다룬다.

<span id="batch_processing_with_spring_cloud_task"></span>이어지는 섹션에선 이 애플리케이션을 빌드하는 방법을 처음부터 설명한다. 원한다면 이 애플리케이션(`billsetup`) 소스 코드가 담겨있는 zip 파일을 다운받아, 압축을 풀고 [배포](#deployment) 섹션으로 이동해도 좋다.

이 프로젝트는 [브라우저에서 다운](https://github.com/spring-cloud/spring-cloud-dataflow-samples/blob/master/dataflow-website/batch-developer-guides/batch/batchsamples/dist/batchsamples.zip?raw=true)받거나, 커맨드라인에서 아래 명령어를 실행해 받으면 된다:

```bash
wget https://github.com/spring-cloud/spring-cloud-dataflow-samples/blob/master/dataflow-website/batch-developer-guides/batch/batchsamples/dist/batchsamples.zip?raw=true -O batchsamples.zip
```

### 목차

- [Development](#development)
  + [Initializr](#initializr)
  + [Setting up MySql](#setting-up-mysql)
  + [Building the Application](#building-the-application)
  + [Testing](#testing)
- [Deployment](#deployment)
  + [Local](#local)
    * [Viewing the Results of Task Execution in the Database](#viewing-the-results-of-task-execution-in-the-database)
    * [Setting the Application Name for Task Execution](#setting-the-application-name-for-task-execution)
    * [Cleanup](#cleanup)
  + [Cloud Foundry](#cloud-foundry)
    * [Requirements](#requirements)
    * [Building the Application](#building-the-application-1)
    * [Setting up Cloud Foundry](#setting-up-cloud-foundry)
    * [Task Concepts in Cloud Foundry](#task-concepts-in-cloud-foundry)
    * [Running `billsetuptask` on Cloud Foundry](#running-billsetuptask-on-cloud-foundry)
    * [Removing All Task Applications and Services](#removing-all-task-applications-and-services)
  + [Kubernetes](#kubernetes)
    * [Setting up the Kubernetes Cluster](#setting-up-the-kubernetes-cluster)
- [What's Next?](#whats-next)

---

## Development

[Spring Initializr](https://start.spring.io/)에서 Spring Cloud Task 애플리케이션을 만드는 것부터 시작한다.

휴대폰 데이터 제공업체가 고객을 위한 청구서를 작성해야 하는 상황이라고 가정한다. 사용 데이터는 JSON 형식으로 파일 시스템에 저장한다. 이 파일에서 사용 데이터를 가져와 청구 데이터를 생성하고 `BILL_STATEMENTS` 테이블에 저장하는 청구 솔루션이 필요하다.

이 예제에선 솔루션을 두 단계로 나눈다:

1. `billsetuptask`: `billsetuptask` 애플리케이션은 Spring Cloud Task를 사용해 `BILL_STATEMENTS` 테이블을 생성하는 스프링 부트 애플리케이션이다.
2. [`billrun`](../batch-developer-guides.batch-development.spring-batch-jobs): [`billrun`](../batch-developer-guides.batch-development.spring-batch-jobs) 애플리케이션은 Spring Cloud Task와 스프링 배치를 이용해 JSON 파일 row마다 사용 데이터를 읽고, 가격을 계산한 결과를 `BILL_STATEMENTS` 테이블에 넣는 스프링 부트 애플리케이션이다.

이 섹션에선 BillRun 애플리케이션에서 사용할 `BILL_STATEMENTS` 테이블을 생성하는 Spring Cloud Task 및 부트 애플리케이션을 만들어본다. 다음은 `BILL_STATEMENTS` 테이블을 나타내는 이미지다:

![BILL_STATMENTS](./../../images/springclouddataflow/bill_statements.webp){: .center-image }

### Initializr

[Spring Initializr에서 만들어 둔 프로젝트를 바로 다운로드](https://start.spring.io/starter.zip?type=maven-project&language=java&baseDir=billsetuptask&groupId=io.spring&artifactId=billsetuptask&name=Bill Setup Task&description=Bill Setup Task Sample App&packageName=io.spring.billsetuptask&packaging=jar&dependencies=cloud-task&dependencies=h2&dependencies=mysql&dependencies=jdbc)하거나 [Spring Initializr 사이트](https://start.spring.io/)를 방문해서 아래 설명대로 따라하면 된다:

1. [Spring Initialzr 사이트](https://start.spring.io/)에 접속한다.
2. 스프링 부트는 최신 릴리즈를 선택한다.
3. 그룹명은 `io.spring`, 아티팩트명은 `billsetuptask`를 사용해서 새 메이븐 프로젝트를 생성한다.
4. **Dependencies** 텍스트 박스에 `task`를 입력해서 Cloud Task 의존성을 선택한다.
5. **Dependencies** 텍스트 박스에 `jdbc`를 입력해서 JDBC 의존성을 선택한다.
6. **Dependencies** 텍스트 박스에 `h2`를 입력해서 H2 의존성을 선택한다. H2는 단위 테스트에 사용한다.
7. **Dependencies** 텍스트 박스에 `mysql`을 입력해서 MySQL 의존성을 선택한다 (다른 데이터베이스도 괜찮다). MySQL을 런타임 데이터베이스로 사용한다.
8. **Generate Project** 버튼을 클릭한다.

이제 `billsetuptask.zip` 파일을 `unzip`하고 즐겨 사용하는 IDE에서 프로젝트를 임포트하면 된다.

### Setting up MySql

사용할 수 있는 MySQL 인스턴스가 없다면, 아래 가이드에 따라 이 예제에서 사용할 MySQL 도커 이미지를 실행하면 된다:

1. 아래 명령어를 실행해 MySQL 도커 이미지를 가져온다:

   ```bash
   docker pull mysql:5.7.25
   ```

2. 아래 명령어를 실행해 MySQL을 시작한다:

   ```bash
   docker run -p 3306:3306 --name mysql -e MYSQL_ROOT_PASSWORD=password \
   -e MYSQL_DATABASE=task -d mysql:5.7.25
   ```

### Building the Application

이제 이 애플리케이션에 필요한 코드를 만들면 된다. 코드를 작성하려면:

1. `io.spring.billsetuptask.configuration` 패키지를 만들어라.
2. `io.spring.billsetuptask.configuration` 패키지 안에 다음과 유사한 [`TaskConfiguration`](https://github.com/spring-cloud/spring-cloud-dataflow-samples/tree/master/dataflow-website/batch-developer-guides/batch/batchsamples/billsetuptask/src/main/java/io/spring/billsetuptask/configuration/TaskConfiguration.java) 클래스를 생성해라:

```java
@Configuration
@EnableTask
public class TaskConfiguration {

    @Autowired
    private DataSource dataSource;

    @Bean
    public CommandLineRunner commandLineRunner() {
        return args -> {
            JdbcTemplate jdbcTemplate = new JdbcTemplate(dataSource);
            jdbcTemplate.execute("CREATE TABLE IF NOT EXISTS " +
                    "BILL_STATEMENTS ( id int, " +
                    "first_name varchar(50), last_name varchar(50), " +
                    "minutes int,data_usage int, bill_amount double)");
        };
    }
}
```

`@EnableTask` 어노테이션은 태스크 실행에 관한 정보(태스크 시작/종료 시간과 종료 코드같은)를 저장하는 `TaskRepository`를 설정한다.

### Testing

이제 테스트를 만들 수 있다. [`BillsetuptaskApplicationTests.java`](https://github.com/spring-cloud/spring-cloud-dataflow-samples/blob/master/dataflow-website/batch-developer-guides/batch/batchsamples/billsetuptask/src/test/java/io/spring/billsetuptask/BillSetuptaskApplicationTests.java)에 아래 코드를 업데이트해라:

```java
package io.spring.billsetuptask;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jdbc.core.JdbcTemplate;

import javax.sql.DataSource;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
class BillSetupTaskApplicationTests {

	@Autowired
	private DataSource dataSource;

	@Test
	public void testRepository() {
		JdbcTemplate jdbcTemplate = new JdbcTemplate(this.dataSource);
		int result = jdbcTemplate.queryForObject(
				"SELECT COUNT(*) FROM BILL_STATEMENTS", Integer.class);
		assertThat(result).isEqualTo(0);
	}

}
```

IDE에서 이 테스트를 실행해봐라. 스프링 부트의 `spring.datasource` 프로퍼티를 설정하지 않았기 때문에 테스트는 임베디드 H2 데이터베이스에서 실행된다. 다음 단계에선 이 애플리케이션을 배포하고 MySQL 데이터베이스를 타겟으로 지정해본다.

---

## Deployment

이 섹션에선 태스크 애플리케이션을 로컬 머신과 클라우드 파운드리, 쿠버네티스에 배포해본다.

### Local

이제 프로젝트를 빌드할 수 있다. 그러려면:

1. 커맨드라인에서 디렉토리를 프로젝트 위치로 변경한 다음 메이븐 명령어 `./mvnw clean package`를 실행해 프로젝트를 빌드해라.

2. MySQL 데이터베이스에 `BILL_STATEMENTS` 테이블을 생성하게끔, 필요한 설정과 함께 애플리케이션을 실행해라. `billsetuptask` 애플리케이션 실행 방식은 다음 인자들로 설정할 수 있다:

   1. `spring.datasource.url`: URL을 데이터베이스 인스턴스로 설정해라. 아래 샘플에선 로컬 시스템의 3306 포트에 있는 MySQL `task` 데이터베이스에 연결한다.
   2. `spring.datasource.username`: MySQL 데이터베이스에서 사용할 user name. 아래 샘플에선 `root`를 사용한다.
   3. `spring.datasource.password`: MySQL 데이터베이스에서 사용할 password. 아래 샘플에선 `password`를 사용한다.
   4. `spring.datasource.driverClassName`: MySQL 데이터베이스에 연결하는 데 사용할 드라이버. 아래 샘플에선 `com.mysql.cj.jdbc.Driver`를 사용한다.

   다음 명령어는 `billsetuptask` 애플리케이션을 데이터베이스 커넥션 값과 함께 실행한다:

   ```bash
   java -jar target/billsetuptask-0.0.1-SNAPSHOT.jar \
   '--spring.datasource.url=jdbc:mysql://localhost:3306/task?useSSL=false' \
   --spring.datasource.username=root \
   --spring.datasource.password=password \
   --spring.datasource.driverClassName=com.mysql.cj.jdbc.Driver
   ```

   아니면 이 프로퍼티들을 `application.properties`에 배치한 뒤 IDE에서 `BillSetupTaskApplication`을 실행해도 된다.

#### Viewing the Results of Task Execution in the Database

Spring Cloud Task는 모든 태스크 실행 내역을 `TASK_EXECUTION`이란 테이블에 기록한다. Spring Cloud Task가 기록하는 정보 중엔 다음과 같은 정보도 들어있다:

- `START_TIME`: 태스크 실행을 시작한 시간
- `END_TIME`: 태스크 실행을 완료한 시간
- `TASK_NAME`: 태스크 실행과 관련한 이름
- `EXIT_CODE`: 태스크를 실행하고 반환한 종료 코드
- `EXIT_MESSAGE`: 실행 후 반환한 종료 메세지
- `ERROR_MESSAGE`: 실행 후 반환한 에러 메세지 (있다면)
- `EXTERNAL_EXECUTION_ID`: 태스크 실행과 관련한 ID

`TASK_NAME`의 디폴트 값은 `application`이다.

다음 명령어를 통해 `TASK_EXECUTION` 테이블에 질의할 수 있다:

```bash
$ docker exec -it mysql bash -l
# mysql -u root -ppassword
mysql> select * from task.TASK_EXECUTION;
```

다음과 유사한 결과가 출력될 거다:

```sh
| TASK_EXECUTION_ID | START_TIME          | END_TIME            | TASK_NAME       | EXIT_CODE | EXIT_MESSAGE | ERROR_MESSAGE | LAST_UPDATED        | EXTERNAL_EXECUTION_ID | PARENT_EXECUTION_ID |
|-------------------|---------------------|---------------------|-----------------|-----------|--------------|---------------|---------------------|-----------------------|---------------------|
|                 1 | 2019-04-23 18:10:57 | 2019-04-23 18:10:57 | application     |         0 | NULL         | NULL          | 2019-04-23 18:10:57 | NULL                  |                NULL |
```

#### Setting the Application Name for Task Execution

위 테이블에서 `TASK_NAME` 컬럼은 기본값 `application`을 가지고 있다. Spring Cloud Task에선 `spring.cloud.task.name`을 사용해 이 설정을 변경할 수 있다. 다음번에 실행할 땐 아래 예시처럼 이 프로퍼티를 추가해주면 된다:

```bash
java -jar target/billsetuptask-0.0.1-SNAPSHOT.jar \
--spring.datasource.url=jdbc:mysql://localhost:3306/task?useSSL=false \
--spring.datasource.username=root \
--spring.datasource.password=password \
--spring.datasource.driverClassName=com.mysql.cj.jdbc.Driver \
--spring.cloud.task.name=BillSetupTest1
```

이제 테이블에 질의해보면 마지막으로 실행한 태스크 이름은 `BillSetupTest1`인 것을 확인할 수 있다.

#### Cleanup

도커 인스턴스에서 실행 중인 MySQL 컨테이너를 중지하고 제거하려면 다음 명령어를 실행해라:

```bash
docker stop mysql
docker rm mysql
```

### Cloud Foundry

이 가이드에선 간단한 [spring-cloud-task](https://spring.io/projects/spring-cloud-task) 독립형 애플리케이션을 클라우드 파운드리에 배포하고 실행하는 방법을 안내한다.

#### Requirements

로컬 머신에 다음을 설치해야 한다:

- Java
- [Git](https://git-scm.com/)

추가로 [클라우드 파운드리 커맨드라인 인터페이스](https://console.run.pivotal.io/tools)도 설치해야 한다 (이 [문서](https://docs.pivotal.io/application-service/2-11/cf-cli/index.html) 참고).

#### Building the Application

이제 프로젝트를 빌드할 수 있다. 커맨드라인에서 디렉토리를 프로젝트 위치로 변경한 다음 메이븐 명령어 `./mvnw clean package`를 실행해 프로젝트를 빌드해라.

#### Setting up Cloud Foundry

먼저 클라우드 파운드리 계정이 필요하다. [Pivotal Web Services (PWS)](https://run.pivotal.io/)를 사용하면 무료 계정을 만들 수 있다. 이 예시에서도 PWS를 사용한다. 다른 provider를 사용하는 경우는 이 문서와는 약간 다르게 진행해야 할 수도 있다.

[클라우드 파운드리 커맨드라인 인터페이스](https://console.run.pivotal.io/tools)에서 클라우드 파운드리에 로그인하려면 다음 명령어를 실행해라:

```bash
cf login
```

> `-a` 플래그를 사용해 특정 클라운드 파운드리 인스턴스를 타겟으로 지정할 수도 있다 (ex. `cf login -a https://api.run.pivotal.io`).

애플리케이션을 푸시하기 전에 먼저 클라우드 파운드리에 **MySQL 서비스**를 설정했는지도 확인해봐야 한다. 사용 가능한 서비스들은 아래 명령어로 확인할 수 있다:

```bash
cf marketplace
```

[Pivotal Web Services](https://run.pivotal.io/) (PWS)에선 다음 명령어로 MySQL 서비스를 설치할 수 있을 거다:

```bash
cf create-service cleardb spark task-example-mysql
```

MySQL 서비스명은 `task-example-mysql`로 지정해야 한다. 이 예제 뒤에선 이 값을 사용한다.

#### Task Concepts in Cloud Foundry

클라우드 파운드리에 대한 설정 파라미터를 제공할 수 있도록, 각 애플리케이션마다 전용 `manifest` YAML 파일을 생성할 거다.

매니페스트 설정에 대한 추가 정보는 [클라우드 파운드리 문서](https://docs.cloudfoundry.org/devguide/deploy-apps/manifest.html)를 참고해라.

클라우드 파운드리에서 태스크를 실행하려면 두 단계를 거쳐야 한다. 실제로 태스크를 실행하려면, 먼저 실행 중인 인스턴스 없이 런타임 환경을 준비한<sup>staged</sup> 앱을 푸시해야 한다. 각 애플리케이션의 매니페스트 YAML 파일에는 다음과 같은 공통 프로퍼티를 제공할 거다:

```yml
memory: 32M
health-check-type: process
no-route: true
instances: 0
```

핵심은 `instances` 프로퍼티를 `0`으로 설정하는 거다. 이렇게 하면 애플리케이션을 실제로 실행하지는 않고 준비<sup>stage</sup>시킨다. 또한 라우트를 생성할 필요가 없으므로 `no-route`를 `true`로 설정하면 된다.

> 앱을 준비<sup>staged</sup>시키고 실행은 하지 않으면 좋은 점이 또 있다. 이렇게 준비한<sup>staged</sup> 애플리케이션은 이후 태스크를 실행하기 위해서도 필요하지만, 데이터베이스 서비스가 내부에 있다면 (클라우드 파운드리 인스턴스에 속해있다면), 이 애플리케이션을 사용해 관련 MySQL 데이터베이스 서비스에 대한 SSH 터널을 구축해 저장된 데이터를 조회할 수 있다. 자세한 내용은 뒤에서 살펴보겠다.

#### Running `billsetuptask` on Cloud Foundry

첫 번째 태스크 애플리케이션(`billsetuptask`)을 배포하려면 반드시 다음과 같은 내용으로 `manifest-billsetuptask.yml` 파일을 생성해야 한다:

```yaml
applications:
  - name: billsetuptask
    memory: 32M
    health-check-type: process
    no-route: true
    instances: 0
    disk_quota: 1G
    timeout: 180
    buildpacks:
      - java_buildpack
    path: target/billsetuptask-0.0.1-SNAPSHOT.jar
    services:
      - task-example-mysql
```

이제 `cf push -f ./manifest-billsetuptask.yml`을 실행하면 된다. 그러면 애플리케이션이 준비<sup>stage</sup>되서 떠 있을 거다. 애플리케이션이 잘 떠 있는지는 다음과 같이 클라우드 파운드리 대시보드로 확인할 수 있다:

![billsetuptask deployed to Cloud Foundry](./../../images/springclouddataflow/CF-task-standalone-initial-push-result.webp)

이제 태스크를 실행할 수 있다. 그러려면:

```bash
cf run-task billsetuptask ".java-buildpack/open_jdk_jre/bin/java org.springframework.boot.loader.JarLauncher arg1" --name billsetuptask-task
```

> 아래 인자들을 추가로 지정해도 된다:
>
> - `-k` 디스크 제한 (ex. 256M, 1024M, 1G)
> - `-m` 메모리 제한 (ex. 256M, 1024M, 1G)

태스크가 정상적으로 실행돼야 한다. Cloud Foundry 대시보드에서 다음과 같이 **Task** 탭을 클릭하면 결과를 확인할 수 있다:

![Cloud Foundry Dashboard Task Tab](./../../images/springclouddataflow/CF-task-standalone-task1-task-tab.webp)

`Tasks` 테이블에서 `State`가 `Succeeded`인 `billsetuptask` 태스크를 볼 수 있을 거다:

![billsetuptask executed on Cloud Foundry](./../../images/springclouddataflow/CF-task-standalone-task1-execution-result.webp)

#### Removing All Task Applications and Services

이제 이 예제는 마쳤고, 스프링 배치 예제를 따라해볼 계획은 없다면 클라우드 파운드리에서 모든 인스턴스를 제거하고 싶을 거다. 이럴땐 다음 명령어를 실행하면 된다:

```bash
cf delete billsetuptask -f
cf delete-service task-example-mysql -f
```

### Kubernetes

이 가이드에선 간단한 [spring-cloud-task](https://spring.io/projects/spring-cloud-task) 애플리케이션을 쿠버네티스 환경에 배포하고 실행하는 방법을 안내한다.

[billsetuptask](../batch-developer-guides.batch-development.data-flow-spring-spring) 샘플 애플리케이션을 쿠버네티스에 배포해보겠다.

#### Setting up the Kubernetes Cluster

실행 중인 [쿠버네티스 클러스터](../installation.kubernetes.creatingcluster)가 필요하다. 이 예제에선 `minikube`에 배포한다.

##### Verifying that Minikube is Running

Minikube가 실행 중인지 확인하려면 아래 명령어를 실행하면 된다 (출력 문구도 함께 표기했다):

```bash
$ minikube status

host: Running
kubelet: Running
apiserver: Running
kubectl: Correctly Configured: pointing to minikube-vm at 192.168.99.100
```

##### Installing the Database

Spring Cloud Data Flow의 디폴트 설정을 사용해 MySQL 서버를 설치해야 한다. 다음 명령어를 실행해라:

```bash
kubectl apply -f https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow/v2.9.1/src/kubernetes/mysql/mysql-deployment.yaml \
-f https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow/v2.9.1/src/kubernetes/mysql/mysql-pvc.yaml \
-f https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow/v2.9.1/src/kubernetes/mysql/mysql-secrets.yaml \
-f https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow/v2.9.1/src/kubernetes/mysql/mysql-svc.yaml
```

##### Building a Docker image

[`billsetuptask`](#batch_processing_with_spring_cloud_task) 애플리케이션을 위한 도커 이미지를 빌드해야 한다. [jib 메이븐 플러그인](https://github.com/GoogleContainerTools/jib/tree/master/jib-maven-plugin#build-your-image)을 사용해보겠다. [소스 배포판](#batch_processing_with_spring_cloud_task)을 다운로드했다면 이미 jib 플러그인이 설정돼 있을 거다. 앱을 처음부터 직접 빌드했다면 `pom.xml`에서 `plugins` 아래에 다음 설정을 추가해라:

```xml
<plugin>
    <groupId>com.google.cloud.tools</groupId>
    <artifactId>jib-maven-plugin</artifactId>
    <version>0.10.1</version>
    <configuration>
        <from>
            <image>springcloud/openjdk</image>
        </from>
        <to>
            <image>${docker.org}/${project.artifactId}:${docker.version}</image>
        </to>
        <container>
            <useCurrentTimestamp>true</useCurrentTimestamp>
        </container>
    </configuration>
</plugin>
```

그런 다음 `properties` 아래에 참조 프로퍼티를 추가해라. 이 예제에선 다음 프로퍼티를 사용한다:

```xml
<docker.org>springcloudtask</docker.org>
<docker.version>${project.version}</docker.version>
```

이제 `minikube` 도커 레지스트리에 이미지를 추가할 수 있다. 다음 명령어를 실행하면 된다:

```bash
eval $(minikube docker-env)
./mvnw clean package jib:dockerBuild
```

이미지가 잘 추가되었는지는 다음 명령어로 확인할 수 있다 (결과로 보여지는 이미지 목록에서 `springcloudtask/billsetuptask`를 찾으면 된다):

```bash
docker images
```

> Spring Cloud Data Flow는 [스프링 부트의 그래들/메이븐 플러그인](https://spring.io/guides/gs/spring-boot-docker/)과 [jib 메이븐 플러그인](https://github.com/GoogleContainerTools/jib/tree/master/jib-maven-plugin#build-your-image), `docker build` 명령으로 생성한 컨테이너에서 테스트를 마쳤다.

##### Deploying the Application

태스크 애플리케이션을 가장 간단하게 배포하는 방법은 독립형 [Pod](https://kubernetes.io/docs/concepts/workloads/pods/pod/)를 이용하는 거다. 프로덕션 환경에서의 베스트 프랙티스는 태스크를 [Job](https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/)이나 [CronJob](https://kubernetes.io/docs/tasks/job/)으로 배포하는 것이지만, 이 가이드에서 다룰 내용은 아니다.

`task-app.yaml`에 아래 내용을 저장해라:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: billsetuptask
spec:
  restartPolicy: Never
  containers:
    - name: task
      image: springcloudtask/billsetuptask:0.0.1-SNAPSHOT
      env:
        - name: SPRING_DATASOURCE_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql
              key: mysql-root-password
        - name: SPRING_DATASOURCE_URL
          value: jdbc:mysql://mysql:3306/task
        - name: SPRING_DATASOURCE_USERNAME
          value: root
        - name: SPRING_DATASOURCE_DRIVER_CLASS_NAME
          value: com.mysql.cj.jdbc.Driver
  initContainers:
    - name: init-mysql-database
      image: mysql:5.6
      env:
        - name: MYSQL_PWD
          valueFrom:
            secretKeyRef:
              name: mysql
              key: mysql-root-password
      command:
        [
          'sh',
          '-c',
          'mysql -h mysql -u root -e "CREATE DATABASE IF NOT EXISTS task;"',
        ]
```

이제 아래 명령어를 실행해 애플리케이션을 시작하면 된다:

```bash
kubectl apply -f task-app.yaml
```

태스크가 완료되면 아래와 유사한 결과를 확인할 수 있을 거다:

```bash
$ kubectl get pods
NAME                     READY   STATUS      RESTARTS   AGE
mysql-5cbb6c49f7-ntg2l   1/1     Running     0          4h
billsetuptask            0/1     Completed   0          81s
```

결과가 잘 나왔다면 포드를 삭제해도 좋다. 삭제하려면 다음 명령을 실행해라:

```bash
kubectl delete -f task-app.yaml
```

이제 데이터베이스를 통해 애플리케이션의 실행 결과를 확인할 수 있다. `mysql` 컨테이너에 로그인하고 `TASK_EXECUTION` 테이블을 질의해라. MySQL 포드 이름은 앞에서처럼 `kubectl get pods`를 실행해 가져오면 된다. 그런 다음 다음과 같이 로그인해야 한다:

```bash
$ kubectl exec -it mysql-5cbb6c49f7-ntg2l -- /bin/bash
# mysql -u root -p$MYSQL_ROOT_PASSWORD
mysql> select * from task.TASK_EXECUTION;
```

`mysql`을 삭제하려면 다음 명령어를 실행해라:

```bash
kubectl delete all -l app=mysql
```

---

## What's Next?

축하한다! Spring Cloud Task 애플리케이션을 만들어 배포를 완료해봤다. 이제 [다음 섹션](../batch-developer-guides.batch-development.spring-batch-jobs)으로 이동해 스프링 배치 애플리케이션을 생성해보면 된다.

