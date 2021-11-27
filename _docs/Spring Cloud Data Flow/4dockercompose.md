---
title: Installing by Using Docker Compose
navTitle: Docker Compose
category: Spring Cloud Data Flow
order: 4
permalink: /Spring%20Cloud%20Data%20Flow/installation.local-machine.docker-compose/
description: docker compose를 통해 로컬 머신에 스프링 클라우드 데이터 플로우 설치하기
image: ./../../images/springclouddataflow/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 클라우드 데이터 플로우
originalRefLink: https://dataflow.spring.io/docs/installation/local/docker/
parent: Installation
parentUrl: /Spring%20Cloud%20Data%20Flow/installation/
subparent: Local Machine
subparentUrl: /Spring%20Cloud%20Data%20Flow/installation.local-machine/
---
<script>defaultLanguages = ['linux-osx', 'wget', 'linux-osx-windows-powershell']</script>

---

Spring Cloud Data Flow에선 Spring Cloud Data Flow, Skipper, MySQL, Apache Kafka를 빠르게 불러올 수 있는 Docker Compose 파일을 제공한다. 기본 설정은 확장할 수 있으며, 별도 [커스텀](../installation.local-machine.docker-customize) 가이드에서 바인더를 RabbitMQ로 전환하는 방법이나, 다른 데이터베이스를 이용하는 방법, 모니터링을 활성화시키는 방법 등을 보여준다.

뿐만 아니라 커스텀 애플리케이션을 개발할 때는, Data Flow와 Skipper 서버를 실행하는 Docker 컨테이너가 로컬의 파일 시스템을 바라보도록 해줘야 한다. 그 방법은 [호스트 파일 시스템에 접근하기](#accessing-the-host-file-system) 챕터에서 알 수 있다.

> `docker`와 `docker-compose`는 [최신](https://docs.docker.com/compose/install/) 버전으로 업그레이드하는 게 좋다. 이 가이드에서 설명하는 내용은 도커 엔진: `19.03.5`와, docker-compose: `1.25.2`로 테스트한 내용이다.

> 도커 데몬의 메모리는 최소한 `8 GB`로 설정해라. Windows나 Mac에서는 Docker Desktop의 `Preferences/Resource/Advanced` 메뉴를 통해 메모리를 설정할 수 있다.

지금 당장 시작해보고 싶다면, 한 줄 짜리 명령어는 다음과 같다:

<div class="switch-language-wrapper linux-osx windows-cmd">
<span class="switch-language linux-osx">Linux / OSX</span>
<span class="switch-language windows-cmd">Windows (Cmd)</span>
</div>
<div class="language-only-for-linux-osx linux-osx windows-cmd"></div>
```sh
wget -O docker-compose.yml https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow/v2.9.1/src/docker-compose/docker-compose.yml; \
DATAFLOW_VERSION=2.9.1 SKIPPER_VERSION=2.8.1 \
docker-compose up
```
<div class="language-only-for-windows-cmd linux-osx windows-cmd"></div>
```sh
curl https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow/v2.9.1/src/docker-compose/docker-compose.yml -o docker-compose.yml & set DATAFLOW_VERSION=2.9.1& set SKIPPER_VERSION=2.8.1& docker-compose up
```

Docker Compose를 이용해 Spring Cloud Data Flow를 설정하고 시작하는 자세한 방법은 이어지는 두 섹션에 나눠서 설명한다.

### 목차

- [Downloading the Docker Compose File](#downloading-the-docker-compose-file)
- [Starting Docker Compose](#starting-docker-compose)
- [Stopping Spring Cloud Data Flow](#stopping-spring-cloud-data-flow)
- [Using the Shell](#using-the-shell)
- [Accessing the Host File System](#accessing-the-host-file-system)
  + [Maven Local Repository Mounting](#maven-local-repository-mounting)
- [Monitoring](#monitoring)
- [Debugging](#debugging)
- [Docker Stream & Task applications](#docker-stream--task-applications)

---

## Downloading the Docker Compose File

설치용 Docker Compose 파일은 [여기를 클릭](https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow/v2.9.1/src/docker-compose/docker-compose.yml)하면 받을 수 있고, [wget](https://www.gnu.org/software/wget/manual/wget.html)이나 [curl](https://curl.haxx.se/) 툴을 이용해 다운받을 수도 있다:

<div class="switch-language-wrapper wget curl">
<span class="switch-language wget">wget</span>
<span class="switch-language curl">curl</span>
</div>
<div class="language-only-for-wget wget curl"></div>
```sh
wget -O docker-compose.yml https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow/v2.9.1/src/docker-compose/docker-compose.yml
```
<div class="language-only-for-curl wget curl"></div>
```sh
curl https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow/v2.9.1/src/docker-compose/docker-compose.yml -o docker-compose.yml
```

[Docker Compose 커스텀](../installation.local-machine.docker-customize) 가이드에선 이 기본 docker-compose.yml과 결합해서 설정을 확장, 변경할 수 있는 파일을 추가로 제공한다.

---

## Starting Docker Compose

`docker-compose.yml` 파일이 들어있는 디렉토리에서 다음 명령어를 실행해라:

<div class="switch-language-wrapper linux-osx windows-cmd windows-powershell">
<span class="switch-language linux-osx">Linux / OSX</span>
<span class="switch-language windows-cmd">Windows (Cmd)</span>
<span class="switch-language windows-powershell">Windows (PowerShell)</span>
</div>
<div class="language-only-for-linux-osx linux-osx windows-cmd windows-powershell"></div>
```sh
export DATAFLOW_VERSION=2.9.1
export SKIPPER_VERSION=2.8.1
docker-compose up
```
<div class="language-only-for-windows-cmd linux-osx windows-cmd windows-powershell"></div>
```sh
set DATAFLOW_VERSION=2.9.1
set SKIPPER_VERSION=2.8.1
docker-compose up
```
<div class="language-only-for-windows-powershell linux-osx windows-cmd windows-powershell"></div>
```sh
$Env:DATAFLOW_VERSION="2.9.1"
$Env:SKIPPER_VERSION="2.8.1"
docker-compose up
```

> Docker Compose는 기본적으로 로컬에 존재하는 이미지를 사용한다. 이미지를 최신 버전으로 받아놓으려면 `docker-compose up`을 실행하기 전에 먼저 `docker-compose pull`을 실행하면 된다.

명령 프롬프트<sup>command prompt</sup>에서 로그 메세지 출력을 멈췄다면 http://localhost:9393/dashboard에서 Spring Cloud Data Flow [Dashboard](https://dataflow.spring.io/docs/concepts/tooling/#dashboard)를 열어봐라. 아니면 [뒤에서](#using-the-shell) 설명하는 대로 쉘을 사용해도 된다.

`docker-compose.yml`을 설정할 땐 아래에 있는 환경 변수를 사용할 수 있다:

| Variable name       | Default value                                                | Description                                                  |
| ------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| `DATAFLOW_VERSION`  | `2.9.1`                                                      | 설치할 Data Flow Server 버전. ex: `2.4.0.RELEASE` 또는 최신 버전의 경우 `2.9.1`. |
| `SKIPPER_VERSION`   | `2.8.1`                                                      | 설치할 Skipper Server 버전. ex: `2.3.0.RELEASE` 또는 최신 버Skipper 버전의 경우 `2.8.1`. |
| `STREAM_APPS_URI`   | https://dataflow.spring.io/kafka-maven-latest (또는 DooD의 경우 https://dataflow.spring.io/kafka-docker-latest) | 사전에 등록된 Stream 애플리케이션들. 사용 가능한 Stream Application Starters 링크는 [여기](https://docs.spring.io/spring-cloud-dataflow/docs/current/reference/htmlsingle/#_spring_cloud_stream_app_starters)에서 확인할 수 있다. |
| `TASK_APPS_URI`     | https://dataflow.spring.io/task-maven-latest (또는 DooD의 경우 https://dataflow.spring.io/task-docker-latest) | 사전에 등록된 Task 애플리케이션들. Task Application Starters 링크는 [여기](https://docs.spring.io/spring-cloud-dataflow/docs/current/reference/htmlsingle/#_spring_cloud_task_app_starters)에서 확인할 수 있다. |
| `HOST_MOUNT_PATH`   | .                                                            | 마운트 시 사용할 호스트 시스템 폴더 경로를 정의한다. 좀더 자세한 내용은 [호스트 파일 시스템에 접근하기](#accessing-the-host-file-system)를 참고해라. |
| `DOCKER_MOUNT_PATH` | `/home/cnb/scdf`                                             | 호스트 폴더를 마운트할 타겟 (컨테이너 내) 경로를 정의한다. 좀더 자세한 내용은 [호스트 파일 시스템에 접근하기](#accessing-the-host-file-system)를 참고해라. |

이 docker-compose.yml 설정에선 아래 포트를 컨테이너에서 호스트 시스템으로 노출한다:

| Host ports  | Container ports | Description                                                  |
| ----------- | --------------- | ------------------------------------------------------------ |
| 9393        | 9393            | Data Flow 서버가 수신<sup>listen</sup>하는 포트. 이 포트를 통해 http://localhost:9393/dashboard에 있는 대시보드나, REST API http://localhost:9393에 접근할 수 있다. |
| 7577        | 7577            | Skipper 서버가 수신<sup>listen</sup>하는 포트. 이 포트를 통해 Skipper REST API http://localhost:7577/api에 접근할 수 있다. |
| 20000-20105 | 20000-20105     | Skipper와 Local Deployer는 배포된 모든 스트림 애플리케이션에서 이 포트 범위를 사용하도록 설정돼 있다. 덕분에 호스트 시스템에서 애플리케이션의 액추에이터 엔드포인트에 접근할 수 있다. 이 포트들은 배포 설정 `server.port`를 통해 재정의할 수 있다. |

> 스트림 애플리케이션에서 노출하고 있는 애플리케이션 포트(`20000-20105`)를 사용하면 호스트 시스템에 특정 포트를 노출할 수 있다. 예를 들어 `http --server.port=20015 | log`와 같이 스트림을 정의하면, 호스트 시스템에서  `20015` 포트를 통해 직접 `http` 소스로 `curl`을 사용하거나 HTTP 메시지를 POST할 수 있다.

---

## Stopping Spring Cloud Data Flow

1. docker-compose 프로세스를 중단하려면 `Ctrl+C`를 눌러라.
2. 아래 명렁어를 실행해 사용한 Docker 컨테이너를 정리해라.

```bash
docker-compose down
```

너무 오래된 컨테이너가 있거나 컨테이너가 응답이 없는 채로<sup>hang</sup> 오류가 발생한다면 모든 컨테이너를 정리해라:


<div class="switch-language-wrapper linux-osx-windows-powershell windows-cmd">
<span class="switch-language linux-osx-windows-powershell">Linux / OSX / Windows (PowerShell)</span>
<span class="switch-language windows-cmd">Windows (Cmd)</span>
</div>
<div class="language-only-for-linux-osx-windows-powershell linux-osx-windows-powershell windows-cmd"></div>
```sh
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
```
<div class="language-only-for-windows-cmd linux-osx-windows-powershell windows-cmd"></div>
```sh
FOR /f "tokens=*" %i IN ('docker ps -aq') DO docker rm %i -f
```

---

## Using the Shell

쉘이 더 편하다면 Spring Cloud Data Flow 대시보드 대신 [Spring Cloud Data Flow Shell](https://dataflow.spring.io/docs/concepts/tooling/#shell)을 사용해도 된다. 이 쉘은 명령어와 애플리케이션 설정 프로퍼티에 대한 탭 자동 완성을 지원한다.

Spring Cloud Data Flow를 Docker Compose를 통해 시작했다면, 쉘은 `springcloud/spring-cloud-dataflow-server` 도커 이미지에도 들어 있다. 이 쉘을 사용하려면 콘솔 창을 하나 더 열고 아래 명령어를 입력해라:

```bash
docker exec -it dataflow-server java -jar shell.jar
```

`java -jar`로 Data Flow 서버를 시작했다면 쉘을 다운받아서 실행하면 된다. Spring Cloud Data Flow Shell 애플리케이션을 다운받으려면 다음 명령어를 실행해라:

<div class="switch-language-wrapper wget curl">
<span class="switch-language wget">wget</span>
<span class="switch-language curl">curl</span>
</div>
<div class="language-only-for-wget wget curl"></div>
```sh
wget -O spring-cloud-dataflow-shell-2.9.1.jar https://repo.spring.io/release/org/springframework/cloud/spring-cloud-dataflow-shell/2.9.1/spring-cloud-dataflow-shell-2.9.1.jar
```
<div class="language-only-for-curl wget curl"></div>
```sh
curl https://repo.spring.io/release/org/springframework/cloud/spring-cloud-dataflow-shell/2.9.1/spring-cloud-dataflow-shell-2.9.1.jar -o spring-cloud-dataflow-shell-2.9.1.jar
```

---

## Accessing the Host File System

로컬 머신에서 커스텀 애플리케이션을 개발한다면 Spring Cloud Data Flow에 해당 애플리케이션을 등록해 줘야 한다. Data Flow 서버는 도커 컨테이너 안에서 실행되기 때문에, 컨테이너가 로컬 파일 시스템에 접근할 수 있도록 설정해 줘야 애플리케이션 등록 레퍼런스를 리졸브할 수 있다. 이런 커스텀 애플리케이션을 배포하려면 Skipper Server도 자체 도커 컨테이너 내에서 애플리케이션에 접근해야 한다.

기본적으로 `docker-compose.yml`은 로컬 호스트 폴더(docker-compose 프로세스를 시작하는 폴더)를 `dataflow-server`와 `skipper` 컨테이너 내부의 `/home/cnb/scdf` 폴더에 마운트한다.

> Data Flow와 Skipper 컨테이너가 **완전히 동일한** 마운트 포인트를 사용하는 게 핵심이다. 그래야만 동일한 레퍼런스를 통해 Data Flow에서 애플리케이션 등록 레퍼런스를 리졸브하고 Skipper에서 이를 배포할 수 있다.

환경 변수 `HOST_MOUNT_PATH`와 `DOCKER_MOUNT_PATH`([설정 테이블](#starting-docker-compose) 참조)를 사용하면 호스트와 컨테이너의 디폴트 경로를 커스텀할 수 있다.

예를 들어 `my-app-1.0.0.RELEASE.jar` 파일이 호스트의 `/tmp/myapps/` 폴더에 저장돼 있다면 (Windows의 경우 `C:\Users\User\MyApps`), `HOST_MOUNT_PATH`를 설정해 `dataflow-server`와 `skipper` 컨테이너에 접근하게 만들 수 있다:

<div class="switch-language-wrapper linux-osx windows-cmd windows-powershell">
<span class="switch-language linux-osx">Linux / OSX</span>
<span class="switch-language windows-cmd">Windows (Cmd)</span>
<span class="switch-language windows-powershell">Windows (PowerShell)</span>
</div>
<div class="language-only-for-linux-osx linux-osx windows-cmd windows-powershell"></div>
```sh
export HOST_MOUNT_PATH=/tmp/myapps
```
<div class="language-only-for-windows-cmd linux-osx windows-cmd windows-powershell"></div>
```sh
set HOST_MOUNT_PATH=C:\Users\User\MyApps
```
<div class="language-only-for-windows-powershell linux-osx windows-cmd windows-powershell"></div>
```sh
$Env:HOST_MOUNT_PATH="C:\Users\User\MyApps"
```

그런 다음 [docker-compose 시작하기](#starting-docker-compose) 가이드에 따라 클러스터를 실행하면 된다.

자세한 설정 정보는 [compose-file 레퍼런스](https://docs.docker.com/compose/compose-file/compose-file-v2/)를 참고해라.

호스트 폴더를 마운트했다면 Data Flow [쉘](https://docs.spring.io/spring-cloud-dataflow/docs/current/reference/htmlsingle/#shell) 또는 [대시보드](https://docs.spring.io/spring-cloud-dataflow/docs/current/reference/htmlsingle/#dashboard-apps)를 사용해 앱 스타터(`/home/cnb/scdf`에 있는)를 등록할 수 있다. 이땐 URI 스키마 `file://`을 사용하면 된다. 그 방법은 다음 예시를 참고해라:

```bash
app register --type source --name my-app --uri file://home/cnb/scdf/my-app-1.0.0.RELEASE.jar
```

>  `/home/cnb/scdf` 폴더에 같은 애플리케이션의 metadata jar가 있다면 선택적으로 `--metadata-uri` 파라미터를 사용할 수 있다.

`docker-compose.yml` 파일에서 `app-import-stream`과 `app-import-task` 설정을 수정하면 직접 앱을 사전에 등록할 수도 있다. 사전에 등록하는 모든 앱 스타터에는 아래 예시처럼 `app-import-stream` 블록 설정에 별도 `wget` 구문을 추가해라:

```yml
app-import-stream:
  image: springcloud/baseimage:1.0.0
  command: >
    /bin/sh -c "
      ....
      wget -qO- 'https://dataflow-server:9393/apps/source/my-app' --post-data='uri=file:/home/cnb/apps/my-app.jar&metadata-uri=file:/home/cnb/apps/my-app-metadata.jar"
```

자세한 내용은 [Data Flow REST API](https://docs.spring.io/spring-cloud-dataflow/docs/current/reference/htmlsingle/#resources-registered-applications)를 참고해라.

### Maven Local Repository Mounting

Data Flow 서버가 실행되는 동안에 애플리케이션을 개발하고 로컬 메이븐 레포지토리에 인스톨할 수 있으며 (`mvn install`), 새롭게 빌드한 애플리케이션에 즉시 액세스할 수 있다.

그러려면 반드시 `/home/cnb/.m2/`라는 볼륨을 사용해서 호스트의 로컬 메이븐 레포지토리를 `dataflow-server`와 `skipper` 컨테이너에 마운트해야 한다. 메이븐 로컬 레포지토리 위치는 Linux와 OSX 시스템에선 `~/.m2`, Windows에선 `C:\Users\{your-username}\.m2`가 디폴트다.

마운트 볼륨은 다음과 같이 `HOST_MOUNT_PATH`와 `DOCKER_MOUNT_PATH` 변수를 활용해 설정할 수 있다:

<div class="switch-language-wrapper linux-osx windows-cmd windows-powershell">
<span class="switch-language linux-osx">Linux / OSX</span>
<span class="switch-language windows-cmd">Windows (Cmd)</span>
<span class="switch-language windows-powershell">Windows (PowerShell)</span>
</div>
<div class="language-only-for-linux-osx linux-osx windows-cmd windows-powershell"></div>
```sh
export HOST_MOUNT_PATH=~/.m2
export DOCKER_MOUNT_PATH=/home/cnb/.m2/
```
<div class="language-only-for-windows-cmd linux-osx windows-cmd windows-powershell"></div>
```sh
set HOST_MOUNT_PATH=%userprofile%\.m2
set DOCKER_MOUNT_PATH=/home/cnb/.m2/
```
<div class="language-only-for-windows-powershell linux-osx windows-cmd windows-powershell"></div>
```sh
$Env:HOST_MOUNT_PATH="~\.m2"
$Env:DOCKER_MOUNT_PATH="/home/cnb/.m2/"
```

참고: 2.8.0-SNAPSHOT 이전 SCDF 도커 이미지의 경우 이대신 `DOCKER_MOUNT_PATH`를 `/root/.m2/`로 설정해야 한다!

그런 다음 [docker-compose 시작하기](#starting-docker-compose) 가이드에 따라 클러스터를 실행하면 된다.

이제 다음과 같이 URI 스키마 `maven://`과 메이븐 좌표<sup>coordinates</sup>를 사용해 호스트의 메이븐 레포지토리에 인스톨된 jar를 리졸브할 수 있다:

```bash
app register --type processor --name pose-estimation --uri maven://org.springframework.cloud.stream.app:pose-estimation-processor-rabbit:2.0.2.BUILD-SNAPSHOT --metadata-uri maven://org.springframework.cloud.stream.app:pose-estimation-processor-rabbit:jar:metadata:2.0.2.BUILD-SNAPSHOT
```

이렇게 하면 호스트 시스템에서 빌드하고 인스톨한 애플리케이션(ex: `mvn clean install`)을 Spring Cloud Data Flow 서버에서 곧바로 사용할 수 있다.

---

## Monitoring

기본 Data Flow docker-compose 설정에선 Stream과 Task 애플리케이션에 대한 모니터링 기능을 활성화하지 않는다. Spring Cloud Data Flow를 위한 모니터링을 활성화하고 설정하는 방법을 알아보려면 커스텀 가이드 [프로메테우스와 그라파나로 모니터링하기](https://dataflow.spring.io/docs/installation/local/docker-customize/#prometheus--grafana) 또는 [InfluxDB와 그라파나로 모니터링하기](https://dataflow.spring.io/docs/installation/local/docker-customize/#influxdb--grafana)를 확인해봐라.

프로메테우스와 InfluxDB를 이용한 Spring Cloud Data Flow 모니터링 경험에 대해 자세히 알아보려면 [스트림 모니터링](https://dataflow.spring.io/docs/feature-guides/streams/monitoring/#local) 기능 가이드를 참고해라.

---

## Debugging

[스트림 애플리케이션 디버깅하기](https://dataflow.spring.io/docs/installation/local/docker-customize/#debug-stream-applications) 가이드에선 Data Flow로 배포한 스트림 애플리케이션에 대한 원격 디버깅을 활성화하는 방법을 안내한다.

[Data Flow Server 디버깅하기](https://dataflow.spring.io/docs/installation/local/docker-customize/#debug-data-flow-server) 가이드에선 docker-compose 설정을 확장해서 IDE(IntelliJ나 Eclipse)를 통한 Data Flow Server 원격 디버깅을 활성화하는 방법을 안내한다.

[Skipper Server 디버깅하기](https://dataflow.spring.io/docs/installation/local/docker-customize/#debug-skipper-server) 가이드에선 docker-compose 설정을 확장해서 IDE(IntelliJ나 Eclipse)를 통한 Skipper Server 원격 디버깅을 활성화하는 방법을 안내한다.

---

## Docker Stream & Task applications

기본 docker-compose 설치는 uber-jar Stream, Task 애플리케이션만 지원한다. Docker는 컨테이너 중첩을 지원하지 않기 때문에 Data Flow와 Skipper 서버의 자체 도커 컨테이너 내에서는 도커 애플리케이션을 실행할 수 없다.

[docker-compose-dood.yml](https://raw.githubusercontent.com/spring-cloud/spring-cloud-dataflow/v2.9.1/src/docker-compose/docker-compose-dood.yml) 익스텐션은 `Docker-out-of-Docker (DooD)` 방식을 사용하기 때문에 Skipper와 Data Flow로 Stream, Task 도커 앱을 배포할 수 있다.

이때 Data Flow와 Skipper 컨테이너에서 생성된 컨테이너들은 형제<sup>sibling</sup> 컨테이너다 (호스트의 도커 데몬이 낳은 컨테이너라고 할 수 있다). 서버의 컨테이너 내부에는 도커 데몬이 없기 때문에 여기선 컨테이너 중첩은 일어나지 않는다.

`docker-compose-dood.yml`은 Data Flow와 Skipper 서버 컨테이너에 도커 CLI를 설치하고 서버의 도커 소켓을 호스트의 소켓에 마운트하는 식으로 `docker-compose.yml`을 확장한다:

<div class="switch-language-wrapper linux-osx windows">
<span class="switch-language linux-osx">Linux / OSX</span>
<span class="switch-language windows">Windows</span>
</div>
<div class="language-only-for-linux-osx linux-osx windows"></div>
```sh
export COMPOSE_PROJECT_NAME=scdf
docker-compose -f ./docker-compose.yml -f ./docker-compose-dood.yml up
```
<div class="language-only-for-windows linux-osx windows"></div>
```sh
set COMPOSE_PROJECT_NAME=scdf
docker-compose -f .\docker-compose.yml -f .\docker-compose-dood.yml up
```

- `COMPOSE_PROJECT_NAME`은 docker-compose 프로젝트 이름을 설정한다. 이 값은 이후에 앱 컨테이너로 전달되는 네트워크 이름을 지정할 때 사용한다.
- 도커 기반 Steam, Task 앱은 `STREAM_APPS_URI`와 `TASK_APPS_URI`를 통해 등록할 수 있다.

> 데이터 파이프라인을 중단하기 전에 docker-compose가 종료되면 컨테이너를 수동으로 정리해야 한다: `docker stop $(docker ps -a -q); docker rm $(docker ps -a -q)`
>
> 로그를 확인할 수 있도록 중단된 도커 컨테이너를 보존하려면 환경 변수 `DOCKER_DELETE_CONTAINER_ON_EXIT`를 `false`로 설정해라: `docker logs <container id>`