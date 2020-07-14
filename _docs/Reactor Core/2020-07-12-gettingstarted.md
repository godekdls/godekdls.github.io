---
title: Getting Started
category: Reactor Core
order: 3
permalink: /Reactor%20Core/gettingstarted/
description: 리액터 시작하기 한글 번역
image: ./../../images/reactorcore/flux.png
lastmod: 2020-07-12T21:00:00+09:00
---

> [프로젝트 리액터 코어 공식 reference](https://projectreactor.io/docs/core/release/reference/#getting-started)를 한글로 번역한 문서입니다.
>
> 전체 목차는 [여기](../contents/)에 있습니다.

### 목차

- [2.1. Introducing Reactor](#21-introducing-reactor)
- [2.2. Prerequisites](#22-prerequisites)
- [2.3. Understanding the BOM](#23-understanding-the-bom)
- [2.4. Getting Reactor](#24-getting-reactor)
  + [2.4.1. Maven Installation](#241-maven-installation)
  + [2.4.2. Gradle Installation](#242-gradle-installation)
  + [2.4.3. Milestones and Snapshots](#243-milestones-and-snapshots)

---

이번 섹션은 리액터를 사용하는 데 도움이 될 다음 내용들을 다룬다:

- [리액터 소개](#21-introducing-reactor)
- [필수 조건](#22-prerequisites)
- [BOM 이해하기](#23-understanding-the-bom)
- [리액터 추가하기](#24-getting-reactor)

---

## 2.1. Introducing Reactor

리액터는 JVM 위에서 동작하는, 완전한 논블로킹 리액티브 프로그래밍을 위한 기반 라이브러리로, 요구(demand)를 효율적으로 관리해 준다("backpressure"를 관리하는 방식으로). 리액터는 자바 8의 함수형 API를(주로 `CompletableFuture`, `Stream`, `Duration`) 직접 통합한다. 이를 통해 비동기 시퀀스 API(`Flux` - N개의 요소, `Mono` - 0 혹은 1개의 요소)를 구성하고, [리액티브 스트림](https://www.reactive-streams.org/) 스펙을 폭넓게 구현한다.

리액터를 사용하면 `reactor-netty` 프로젝트 프로세스와 논블로킹 방식으로 통신할 수 있다. 리액터 네티는 마이크로서비스 아키텍처에 적합한, backpressure를 지원하는 HTTP(웹소켓 포함), TCP, UDP 네트워크 엔진을 제공한다. 완전한 리액티브 방식 인코딩과 디코딩을 지원한다.

---

## 2.2. Prerequisites

리액터 코어는 **자바 8** 이상에서 동작한다.

`org.reactivestreams:reactive-streams:1.0.3`에 전이 의존성(transitive dependency)이 있다.

> **안드로이드 지원**
>
> - 안드로이드는 리액터 3의 공식 지원 대상이 아니다 (꼭 필요하다면 RxJava 2 사용을 고려해 봐라).
> - 하지만 안드로이드 SDK 26과(안드로이드 O) 이후 버전에서는 문제 없이 동작할 것이다.
> - 안드로이드 지원을 최선으로 고려하고 있지만, 보장할 순 없다. 모든 것은 그때 그때 상황에 맞게 결정한다.

---

## 2.3. Understanding the BOM

리액터 3는 BOM(Bill Of Materials) 모델을 사용한다(`reactor-core 3.0.4`에서 `Aluminium` 릴리즈 트레인을 사용한 이후부터). 이를 통해 각 아티팩트의 버전 관리 체계가 다르더라도, 함께 잘 동작하는 아티팩트 그룹을 엄선해서 관련 버전을 함께 제공한다.

BOM 자체는 코드명과 식별용 수식어(qualifier)를 사용하는 릴리즈 트레인 체계로 버전을 정한다. 예를 들어 다음과 같다:

*Aluminium-RELEASE*<br>
*Californium-BUILD-SNAPSHOT*<br>
*Aluminium-SR1*<br>
*Bismuth-RELEASE*<br>
*Californium-SR32*<br>

코드명은 전통적으로 MAJOR.MINOR 번호를 나타낸다. 대부분 [주기율표](https://en.wikipedia.org/wiki/Periodic_table#Overview)에서 알파벳 오름차순으로 따왔다.

각 식별용 수식어는 다음과 같다 (일어나는 시간순):

- `BUILD-SNAPSHOT`: 개발과 테스트를 위한 빌드.
- `M1`..`N`: 마일스톤이나 개발자 프리뷰.
- `RELEASE`: 코드명 시리즈에서 첫 번째 GA (General Availability) 릴리즈.
- `SR1`..`N`: 이어지는 코드명 시리즈 GA 릴리즈들 — PATCH 번호와 동일함. (SR은 “Service Release”를 뜻한다).

---

## 2.4. Getting Reactor

[앞서 언급](#23-understanding-the-bom)했듯, 리액터를 사용하는 가장 쉬운 방법은 BOM을 통해 프로젝트에 관련 의존성을 추가하는 것이다. 단, 버전을 생략해야 BOM에 정의된 버전이 추가된 다는 점에 주의하라.

하지만 특정 아티팩트의 버전을 강제로 지정하고 싶다면, 보통 의존성을 추가할 때처럼 명시하면 된다. BOM을 완전히 버리고 원하는 아티팩트 버전으로 의존성을 추가할 수도 있다.

### 2.4.1. Maven Installation

메이븐은 자체적으로 BOM을 지원한다. 먼저 다음을 `pom.xml`에 추가해서 BOM을 임포트해야 한다:

```xml
<dependencyManagement> <!-- (1) -->
    <dependencies>
        <dependency>
            <groupId>io.projectreactor</groupId>
            <artifactId>reactor-bom</artifactId>
            <version>Bismuth-RELEASE</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `dependencyManagement` 태그에 주목하라. 이는 전형적인 `dependencies` 섹션과는 다른 별개 섹션이다.</small>

상위 섹션(`dependencyManagement`)이 이미 pom에 있다면 안 쪽 컨텐츠만 추가하라.

그 다음, 일반적인 방식에서 `<version>`만 빼고 리액터 프로젝트 의존성을 추가한다:

```xml
<dependencies>
    <dependency>
        <groupId>io.projectreactor</groupId>
        <artifactId>reactor-core</artifactId> <!-- (1) -->
        <!-- (2) -->
    </dependency>
    <dependency>
        <groupId>io.projectreactor</groupId>
        <artifactId>reactor-test</artifactId> <!-- (3) -->
        <scope>test</scope>
    </dependency>
</dependencies>
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 코어 라이브러리 의존성.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 여기엔 version 태그가 없다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> `reactor-test`는 리액티브 스트림의 단위 테스트를 도와준다.</small>

### 2.4.2. Gradle Installation

그래들 5.0 이전 버전은 메이븐 BOM을 지원하지 않지만, 스프링의 [gradle-dependency-management](https://github.com/spring-gradle-plugins/dependency-management-plugin) 플러그인을 사용하면 된다.

먼저 다음과 같이 그래들 플러그인 포탈로 부터 플러그인을 적용한다:

```groovy
plugins {
    id "io.spring.dependency-management" version "1.0.7.RELEASE" // (1)
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 이 문서를 작성하는 시점에는 1.0.7.RELEASE가 플러그인의 최신 버전이다. 업데이트를 확인해 보라.</small>

그 다음 BOM을 임포트한다:

```groovy
dependencyManagement {
     imports {
          mavenBom "io.projectreactor:reactor-bom:Bismuth-RELEASE"
     }
}
```

마지막으로 다음과 같이 버전은 생략하고 의존성을 추가한다:

```groovy
dependencies {
     implementation 'io.projectreactor:reactor-core' // (1)
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> </small>`:`<small>로 구분된 섹션에서 버전을 명시하는 세 번째 자리가 비어있다. 버전은 BOM에서 가져온다.</small>

그래들 5.0부터는 그래들 자체에서 BOM을 지원한다:

```groovy
dependencies {
     implementation platform('io.projectreactor:reactor-bom:Bismuth-RELEASE')
     implementation 'io.projectreactor:reactor-core' 
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> </small>`:`<small>로 구분된 섹션에서 버전을 명시하는 세 번째 자리가 비어있다. 버전은 BOM에서 가져온다.</small>

### 2.4.3. Milestones and Snapshots

마일스톤과 개발자 프리뷰는 메이븐 중앙저장소가 아닌 스프링 마일스톤 레포지토리로 배포한다. 이를 사용하려면 다음을 빌드 설정 파일에 추가해야 한다:

**Example 1. Milestones in Maven**

```xml
<repositories>
	<repository>
		<id>spring-milestones</id>
		<name>Spring Milestones Repository</name>
		<url>https://repo.spring.io/milestone</url>
	</repository>
</repositories>
```

그래들은 다음과 같이 작성하라:

**Example 2. Milestones in Gradle**

```xml
repositories {
  maven { url 'https://repo.spring.io/milestone' }
  mavenCentral()
}
```

마찬가지로 스냅샷도 별도의 전용 리포지토리로 제공한다:

**Example 3. BUILD-SNAPSHOTs in Maven**

```xml
<repositories>
	<repository>
		<id>spring-snapshots</id>
		<name>Spring Snapshot Repository</name>
		<url>https://repo.spring.io/snapshot</url>
	</repository>
</repositories>
```

**Example 4. BUILD-SNAPSHOTs in Gradle**

```xml
repositories {
  maven { url 'https://repo.spring.io/snapshot' }
  mavenCentral()
}
```

"[Getting Started](https://projectreactor.io/docs/core/release/reference/#getting-started)" [수정 제안하기](https://github.com/reactor/reactor-core/edit/master/docs/asciidoc/gettingStarted.adoc)

---

> 전체 목차는 [여기](../contents/)에 있습니다.