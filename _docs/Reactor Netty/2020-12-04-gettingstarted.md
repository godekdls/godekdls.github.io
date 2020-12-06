---
title: Getting Started
category: Reactor Netty
order: 3
permalink: /Reactor%20Netty/gettingstarted/
description: 리액터 네티 시작하기 한글 번역
image: ./../../images/reactornetty/logo.png
lastmod: 2020-12-04T12:00:00+09:00
comments: true
originalRefName: 프로젝트 리액터 네티
originalRefLink: https://projectreactor.io/docs/netty/1.0.1/reference/index.html#getting-started
---

### 목차

- [2.1. Introducing Reactor Netty](#21-introducing-reactor-netty)
- [2.2. Prerequisites](#22-prerequisites)
- [2.3. Understanding the BOM and versioning scheme](#23-understanding-the-bom-and-versioning-scheme)
- [2.4. Getting Reactor Netty](#24-getting-reactor-netty)
  + [2.4.1. Maven Installation](#241-maven-installation)
  + [2.4.2. Gradle Installation](#242-gradle-installation)
  + [2.4.3. Milestones and Snapshots](#243-milestones-and-snapshots)

---

이번 섹션은 **리액터 네티**를 사용하는 데 도움이 될 다음 내용들을 다룬다:

- [리액터 네티 소개](#21-introducing-reactor-netty)
- [필수 조건](#22-prerequisites)
- [BOM과 버전 관리 체계 이해하기](#23-understanding-the-bom-and-versioning-scheme)
- [리액터 네티 추가하기](#24-getting-reactor-netty)

---

## 2.1. Introducing Reactor Netty

마이크로서비스 아키텍처에 적합한 **리액터 네티**는 `HTTP`(웹소켓 포함), `TCP`, `UDP`를 위한 네트워크 엔진을 제공하며, backpressure를 지원한다.

---

## 2.2. Prerequisites

**리액터 네티**는 **자바 8** 이상에서 동작한다.

추가로 다음과 같은 전이 의존성(transitive dependency)이 있다:

- Reactive Streams v1.0.3
- Reactor Core v3.x
- Netty v4.1.x

---

## 2.3. Understanding the BOM and versioning scheme

**리액터 네티**는 **프로젝트 리액터 BOM**의 일부다 (`Aluminium` 릴리즈 트레인 이후부터). 이렇게 큐레이팅한 프로젝트는, 버전 관리 체계가 다를 수 있는 여러 아티팩트 버전을 그룹화해 제공하기 때문에 함께 잘 동작한다.

> 0.9.x와 1.0.x는 다른 버전 관리 체계를 사용한다 (Dysprosium과 Europium).

아티팩트 버저닝은 `MAJOR.MINOR.PATCH-QUALIFIER` 체계를 따르며, BOM은 CalVer에서 따온 `YYYY.MINOR.PATCH-QUALIFIER` 형식으로 버전을 정한다:

- `MAJOR`를 보면 현재 리액터가 몇 세대인 지 알 수 있다. 세대가 바뀔 땐 프로젝트의 근본적인 구조가 바뀔 수도 있다 (마이그레이션이 까다로울 수 있다는 뜻).
- `YYYY`는 릴리즈 사이클 내에서 첫 번째 GA를 릴리즈한 연도를 뜻한다 (1.0.x의 경우 1.0.0).
- `.MINOR`는 0부터 시작하는, 릴리즈 사이클마다 증가하는 숫자다.
  - 프로젝트에선 일반적으로 좀 더 범위가 큰 변경을 의미하며, 그에 따른 마이그레이션 비용이 존재한다.
  - BOM에선 같은 해에 두 번의 릴리즈 사이클 첫 릴리즈가 있을 때, 해당 릴리즈 사이클을 구분하는 역할을 한다.
- `.PATCH`는 0부터 시작하는, 서비스 릴리즈마다 증가하는 숫자다.
- `-QUALIFIER`는 문자로 된 식별자로, GA 릴리즈에선 생략한다 (아래 참고).

이 컨벤션을 따른 첫 번째 릴리즈 사이클은 `2020.0.x`이고, 코드 네임은 `Europium`을 사용한다. 이 체계에선 다음과 같은 순서로 식별자를 사용한다:

- `-M1`..`-M9`: 마일스톤 (서비스 릴리즈 당 9개 이하일 것으로 예상)
- `-RC1`..`-RC9`: 릴리즈 후보 (서비스 릴리즈 당 9개 이하일 것으로 예상)
- `-SNAPSHOT`: 스냅샷
- GA 릴리즈엔 *식별자를 사용하지 않음*

> 위에서 스냅샷을 높은 순서로 표기한 이유는, 개념적으로 스냅샷은 항상 모든 PATCH 중에서 "가장 최신 상태인 사전 릴리즈"를 뜻하기 때문이다. PATCH 사이클 내에서 첫 번째로 배포하는 아티팩트는 항상 비슷하게 -SNAPSHOT으로 명명하더라도, 마일스톤 이후나 릴리즈 후보 사이 등에 더 최신 버전인 스냅샷을 배포할 수도 있다.

모든 릴리즈 사이클엔 이전 사이클의 버저닝 체계와 이어지는 코드 네임이 주어지므로, 다른 비공식 레퍼런스에서도 이를 참고삼아도 좋다 (디스커션이나 블로그 포스트 등에서). 코드 네임은 전통적으로 MAJOR.MINOR 숫자를 나타낸다. (대부분) [원소 주기율표](https://en.wikipedia.org/wiki/Periodic_table#Overview)에서 알파벳 오름차순으로 따온다.

> Dysprosium까지 사용했던 릴리즈 트레인 체계에선 코드명 뒤에 식별자를 붙였었는데, 이 식별자가 약간 달랐다. 예를 들어: Aluminium-RELEASE (첫 번째 GA 릴리즈로, 지금같았으면 YYYY.0.0 식으로 사용했을), Bismuth-M1, Californium-SR1 (현재는 서비스 릴리즈는 YYYY.0.1 등으로 명명), Dysprosium-RC1, Dysprosium-BUILD-SNAPSHOT (각 패치 후에는 동일한 스냅샷 버전으로 돌아간다. 현재는 YYYY.0.X-SNAPSHOT 형식을 사용하므로 PATCH 당 스냅샷이 하나다)

---

## 2.4. Getting Reactor Netty

[앞서 언급](#23-understanding-the-bom-and-versioning-scheme)했듯, **리액터 네티**를 사용하는 가장 쉬운 방법은 **BOM**을 통해 프로젝트에 관련 의존성을 추가하는 것이다. 단, 버전을 생략해야 **BOM**에 정의된 버전이 추가된다는 점에 주의하라.

하지만 특정 아티팩트의 버전을 강제하고 싶다면, 평소에 의존성을 추가할 때처럼 명시하면 된다. **BOM**을 완전히 버리고 원하는 아티팩트 버전으로 의존성을 추가할 수도 있다.

### 2.4.1. Maven Installation

**메이븐**은 자체적으로 **BOM**을 지원한다. 먼저 다음을 `pom.xml`에 추가해서 **BOM**을 임포트해야 한다. 맨 위 요소(`dependencyManagement`)가 pom에 이미 있다면 안에 있는 내용만 넣으면 된다.

```xml
<dependencyManagement> <!-- (1) -->
    <dependencies>
        <dependency>
            <groupId>io.projectreactor</groupId>
            <artifactId>reactor-bom</artifactId>
            <version>Dysprosium-SR10</version> <!-- (2) -->
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `dependencyManagement` 태그에 주목하라. 이는 전형적인 `dependencies` 섹션과는 다른 별개 섹션이다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 이 글을 쓰는 시점에는 `Dysprosium-SR10`이 **BOM**의 가장 최신 버전이다. 업데이트는 [여기](https://github.com/reactor/reactor/releases)에서 확인해라.</small>

그다음, 일반적인 방식에서 `<version>`만 빼서 관련 리액터 프로젝트 의존성을 추가하면 된다:

```xml
<dependencies>
    <dependency>
        <groupId>io.projectreactor.netty</groupId>
        <artifactId>reactor-netty-core</artifactId> <!-- (1) -->
        <!-- (2) -->
    </dependency>
</dependencies>
<dependencies>
    <dependency>
        <groupId>io.projectreactor.netty</groupId>
        <artifactId>reactor-netty-http</artifactId>
    </dependency>
</dependencies>
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> **리액터 네티** 의존성.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 여기엔 version 태그가 없다.</small>

### 2.4.2. Gradle Installation

**BOM** 컨셉은 그래들 5 버전부터 지원한다. **BOM**을 임포트하고 **리액터 네티**에 의존성을 추가하는 방법은 다음과 같다:

```groovy
dependencies {
    // import a BOM
    implementation platform('io.projectreactor:reactor-bom:Dysprosium-SR10') // (1)

    // define dependencies without versions
    implementation 'io.projectreactor.netty:reactor-netty-core' // (2)
    implementation 'io.projectreactor.netty:reactor-netty-http'
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 이 글을 쓰는 시점에는 `Dysprosium-SR10`이 **BOM**의 가장 최신 버전이다. 업데이트는 [여기](https://github.com/reactor/reactor/releases)에서 확인해라.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> </small>`:`<small>로 구분된 섹션 중, 버전을 명시하는 세 번째 자리가 비어있다. 버전은 **BOM**에서 가져온다.</small>

### 2.4.3. Milestones and Snapshots

마일스톤과 개발자 프리뷰는 **메이븐 중앙저장소**가 아닌 **스프링 마일스톤** 레포지토리로 배포한다. 이를 사용하려면 다음을 빌드 설정 파일에 추가해야 한다:

**Milestones in Maven**

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

**Milestones in Gradle**

```xml
repositories {
  maven { url 'https://repo.spring.io/milestone' }
  mavenCentral()
}
```

마찬가지로 스냅샷도 별도의 전용 리포지토리로 제공한다 (메이븐, 그래들 모두):

**-SNAPSHOTs in Maven**

```xml
<repositories>
	<repository>
		<id>spring-snapshots</id>
		<name>Spring Snapshot Repository</name>
		<url>https://repo.spring.io/snapshot</url>
	</repository>
</repositories>
```

**-SNAPSHOTs in Gradle**

```groovy
repositories {
  maven { url 'https://repo.spring.io/snapshot' }
  mavenCentral()
}
```

"[Getting Started](https://projectreactor.io/docs/netty/1.0.1/reference/index.html#getting-started)" [수정 제안하기](https://github.com/reactor/reactor-netty/edit/master/docs/asciidoc/getting-started.adoc)