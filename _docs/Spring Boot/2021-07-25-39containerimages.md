---
title: Container Images
category: Spring Boot
order: 39
permalink: /Spring%20Boot/container-images/
description: 스프링 부트 애플리케이션을 실행하기 위한 도커 이미지를 만들고 레이어 최적화 달성하기
image: ./../../images/springboot/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 부트
originalRefLink: https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#features.container-images
parent: Spring Boot Features
parentUrl: /Spring%20Boot/spring-boot-features/
---

### 목차

- [7.31.1. Layering Docker Images](#7311-layering-docker-images)
- [7.31.2. Building Container Images](#7312-building-container-images)
  + [Dockerfiles](#dockerfiles)
  + [Cloud Native Buildpacks](#cloud-native-buildpacks)

---

## 7.31. Container Images

스프링 부트 fat jar는 쉽게 도커 이미지로 패키징할 수 있다. 하지만 도커 이미지 안에 fat jar를 복사해가 실행하게 되면 여러 가지 단점들이 따른다. 언패키징 없이 fat jar를 실행할 땐 항상 일정량의 오버헤드가 발생하며, 컨테이너 환경에선 더 두드러질 수 있다. 한 가지 더, 애플리케이션의 코드와 모든 의존성을 도커 이미지 레이어 하나에 다 넣는 건 최선책이 아니다. 사용하는 스프링 부트 버전을 업그레이드하는 것보단 애플리케이션 코드를 다시 컴파일하는 경우가 더 자주 있기 때문에, 보통은 이 것들을 좀 더 분리해주는 게 좋다. 애플리케이션 클래스들보다 jar 파일을 먼저 레이어에 넣으면, 도커는 보통 맨 아래에 있는 레이어만 변경하면 되고, 다른 레이어들은 캐시에서 가져올 수 있다.

### 7.31.1. Layering Docker Images

스프링 부트에선 jar에 레이어 인덱스 파일을 추가하면 좀 더 쉽게 최적화된 도커 이미지를 만들 수 있다. 스프링 부트는 jar에서 레이어 안에 포함시켜야 하는 것들에 따라 몇 가지 레이어를 제공하고 있다. 인덱스에선 레이어 목록을 Docker/OCI 이미지에 추가해야 하는 순서에 따라 작성한다. 기본적으로 제공하는 레이어들은 다음과 같다:

- `dependencies` (전형적인 릴리즈 의존성 전용)
- `spring-boot-loader` (`org/springframework/boot/loader` 밑에 있는 것들 전용)
- `snapshot-dependencies` (스냅샷 의존성 전용)
- `application` (애플리케이션 클래스와 리소스 전용)

다음은 `layers.idx` 파일 예시다:

```yaml
- "dependencies":
  - BOOT-INF/lib/library1.jar
  - BOOT-INF/lib/library2.jar
- "spring-boot-loader":
  - org/springframework/boot/loader/JarLauncher.class
  - org/springframework/boot/loader/jar/JarEntry.class
- "snapshot-dependencies":
  - BOOT-INF/lib/library3-SNAPSHOT.jar
- "application":
  - META-INF/MANIFEST.MF
  - BOOT-INF/classes/a/b/C.class
```

이 레어어 구조는 애플리케이션을 빌드할 때마다 변경될 가능성이 큰지에 따라 코드를 분리하도록 설계했다. 라이브러리 코드는 빌드할 때마다 변경될 여지가 크지 않기 때문에, 캐시에 있는 레이어를 재사용할 수 있도록 전용 레이어에 배치한다. 애플리케이션 코드는 빌드마다 변경될 가능성이 커서 별도의 레이어로 격리한다.

스프링 부트는 war 파일에서도  `layers.idx`의 도움을 받아 레이어를 분리할 수 있다.

메이븐에서 아카이브에 레이어 인덱스를 추가하는 자세한 방법은 [layered jar 또는 war 패키징하기](https://docs.spring.io/spring-boot/docs/2.5.2/maven-plugin/reference/htmlsingle/#repackage-layers) 섹션을 참고해라. 그래들은 그래들 플러그인 문서에 있는 [layered jar 또는 war 패키징하기](https://docs.spring.io/spring-boot/docs/2.5.2/gradle-plugin/reference/htmlsingle/#packaging-layered-archives) 섹션을 참고해라.

### 7.31.2. Building Container Images

스프링 부트 애플리케이션은 [Dockerfile을 사용하거나](#dockerfiles), [클라우드 네이티브 빌드팩을 사용해서 어디서나 실행할 수 있는 docker 호환 컨테이너 이미지 생성](#cloud-native-buildpacks)하면 컨테이너에 올릴 수 있다.

#### Dockerfiles

Dockerfile에 몇 줄만 추가해주면 스프링 부트 fat jar를 도커 이미지로 변환할 수 있지만, 여기에선 [레이어링 기능](#7311-layering-docker-images)을 활용해서 최적화된 도커 이미지를 이미지를 생성할 거다. 레이어 인덱스 파일을 가지고 있는 jar를 생성하면 jar 의존성에 `spring-boot-jarmode-layertools` jar가 추가될 거다. 클래스패스에 이 jar가 있으면 부트스트랩 코드로 레이어를 추출하는 등, 애플리케이션과는 전혀 다른 것을 실행할 수 있는 특별한 모드로 애플리케이션을 띄울 수 있다.

> `layertools` 모드는 기동 스크립트를 가지고 있는 [완전히 실행 가능한<sup>fully executable jar</sup> 스프링 부트 아카이브](../deploying-spring-boot-applications#93-installing-spring-boot-applications)와는 함께 사용할 수 없다. `layertools`를 활용할 목적으로 jar 파일을 빌드할 땐, 기동 스크립트 설정을 비활성화한다.

`layertools` jar 모드로 jar를 실행하는 방법은 다음과 같다:

```shell
$ java -Djarmode=layertools -jar my-app.jar
```

이 명령어를 실행하면 다음과 같은 내용들이 출력된다:

```
Usage:
  java -Djarmode=layertools -jar my-app.jar

Available commands:
  list     List layers from the jar that can be extracted
  extract  Extracts layers from the jar for image creation
  help     Help about any command
```

`extract` 명령어로는 애플리케이션을 dockerfile에 추가할 레이어들로 쉽게 분할할 수 있다. 다음은 `jarmode`를 사용하는 Dockerfile 예시다:

```dockerfile
FROM adoptopenjdk:11-jre-hotspot as builder
WORKDIR application
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} application.jar
RUN java -Djarmode=layertools -jar application.jar extract

FROM adoptopenjdk:11-jre-hotspot
WORKDIR application
COPY --from=builder application/dependencies/ ./
COPY --from=builder application/spring-boot-loader/ ./
COPY --from=builder application/snapshot-dependencies/ ./
COPY --from=builder application/application/ ./
ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]
```

위에 있는 `Dockerfile`이 현재 디렉토리에 있다고 가정하면, `docker build .`를 사용하거나 아니면 아래 예시처럼 애플리케이션 jar 경로를 지정해서 도커 이미지를 빌드할 수 있다:

```shell
$ docker build --build-arg JAR_FILE=path/to/myapp.jar .
```

여기서 보여준 건 multi-stage dockerfile이다. 빌더 스테이지에선 이후에 필요한 디렉토리를 추출한다. 각 `COPY` 명령어에선 jarmode로 추출한 레이어들을 사용하고 있다.

물론 Dockerfile은 jarmode를 사용하지 않아도 작성할 수 있다. `unzip`과 `mv`를 조합하면 파일들을 그에 맞는 레이어로 이동시킬 수 있지만, jarmode를 사용하면 훨씬 간단하다.

#### Cloud Native Buildpacks

Dockerfile은 도커 이미지를 빌드하는 방법 중 하나일 뿐이다. 도커 이미지를 빌드할 수 있는 또 다른 방법 중 하나는, 메이븐이나 그래들 플러그인에서 직접 빌드팩을 이용하는거다. Cloud Foundry나 Heroku같은 애플리케이션 플랫폼을 사용한 적이 있다면 빌드팩을 사용해봤을 거다. 빌드팩은 플랫폼에 속해있는 팩으로, 애플리케이션을 실제 플랫폼에서 실행할 수 있게 변환해준다. 예를 들어, Cloud Foundry의 자바 빌드팩은 `.jar` 파일을 푸시하면 이를 감지해서 자동으로 관련 JRE를 추가해준다.

클라우드 네이티브 빌드팩을 사용하면 어디서나 실행할 수 있는 도커 호환 이미지를 생성할 수 있다. 스프링 부트에는 메이븐과 그래들에서 직접 사용할 수 있는 빌드팩 지원이 포함되어 있다. 덕분에 명령어 하나만 입력하면 로컬에서 실행 중인 도커 데몬에 적절한 이미지를 빠르게 올릴 수 있다.

[메이븐](https://docs.spring.io/spring-boot/docs/2.5.2/maven-plugin/reference/htmlsingle/#build-image)과 [그래들](https://docs.spring.io/spring-boot/docs/2.5.2/gradle-plugin/reference/htmlsingle/#build-image)에서 빌드팩을 사용하는 방법은 각 플러그인 문서를 참고해라.

> [Paketo 스프링 부트 빌드팩](https://github.com/paketo-buildpacks/spring-boot)도 `layers.idx` 파일을 지원하도록 업데이트되었으며, 여기에 커스텀 로직을 추가하면 이 빌드팩으로 생성하는 이미지에도 반영된다.

> 빌드팩은 동일한 빌드 결과물을 보장하고<sup>[reproducible build](https://en.wikipedia.org/wiki/Reproducible_builds)</sup> 컨테이너 이미지 캐시를 이용하기 위해 애플리케이션 리소스 메타데이터를 조작할 수 있다 (파일의 "last modified" 정보 등). 애플리케이션에선 런타임에 이 메타데이터에 의존하지 않도록 주의해야 한다. 스프링 부트에선 스태틱 리소스를 서빙할 때 이 정보를 사용할 수 있지만, `spring.web.resources.cache.use-last-modified`로 비활성화할 수 있다.
