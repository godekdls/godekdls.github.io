---
title: Tracing support
category: Micrometer Tracing
order: 2
permalink: /Micrometer%20Tracing/support/
description: Micrometer Tracing이란
image: ./../../images/micrometer/logo.png
lastmod: 2024-07-14T17:00:00+09:00
comments: true
originalRefName: 마이크로미터 트레이싱
originalRefLink: https://docs.micrometer.io/tracing/reference/index.html
originalVersion: 1.3.2
---

### 목차


- [Purpose](#purpose)
- [Installing](#installing)

---

## Purpose

애플리케이션을 추적하는 이슈는 더 이상 새롭지 않다. 오래 전부터 개발자들은 애플리케이션의 상태를 추적할 수 있는 방법을 고안해 왔다. 하지만 꽤 오랜 기간 동안 개발자가 직접 필요한 트레이싱<sup>tracing</sup> 프레임워크를 만들어야 했었다.

2016년, Spring Cloud 팀은 수 많은 개발자에게 도움이 될 트레이싱<sup>tracing</sup> 라이브러리를 개발했다. 이 라이브러리는 [Spring Cloud Sleuth](https://github.com/spring-cloud/spring-cloud-sleuth)라고 불렸다. 이후 Spring 팀은 이 트레이싱<sup>tracing</sup> 코드들을 Spring Cloud에서 분리할 수 있다는 것을 깨달았고, Micrometer Tracing 프로젝트를 만들었다. Micrometer Tracing 프로젝트는 사실상 Spring에 구애받지 않는, Spring Cloud Sleuth의 복사본이다. Micrometer Tracing은 2022년 11월에 1.0.0 GA 버전이 릴리즈되었으며, 이후로도 꾸준히 개선되고 있다.

[Micrometer Tracing](https://github.com/micrometer-metrics/tracing)은 가장 많이 쓰는 트레이서<sup>tracer</sup> 라이브러리들을 위한 간단한 파사드<sup>facade</sup>를 제공해서, 벤더에 묶이지 않고 JVM 기반 애플리케이션 코드를 계측<sup>instrumentation</sup>할 수 있게 해준다. 트레이싱<sup>tracing</sup> 정보를 수집할 때 오버헤드는 거의 추가하지 않으면서, 쉽게 라이브러리를 교체할 수 있도록 코드의 이식성을 극대화하는 방향으로 설계됐다.

또한, Micrometer의 `ObservationHandler`에 트레이싱<sup>tracing</sup> 데이터를 추가한 하위 클래스를 제공한다 (Micrometer 1.10.0부터). `Observation`을 사용할 때마다 그에 따른 span이 생성되고, 시작, 중지, 보고된다.

---

## Installing

Micrometer Tracing은 모든 프로젝트 버전이 담겨있는 BOM<sup>Bill of Materials</sup>과 함께 제공된다.

다음은 Gradle에서 필요한 의존성을 나타낸 예제다:

```groovy
implementation platform('io.micrometer:micrometer-tracing-bom:latest.release')
implementation 'io.micrometer:micrometer-tracing'
```

다음은 Maven에서 필요한 의존성을 나타낸 예제다:

```xml
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>io.micrometer</groupId>
            <artifactId>micrometer-tracing-bom</artifactId>
            <version>${micrometer-tracing.version}</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>

<dependencies>
    <dependency>
      <groupId>io.micrometer</groupId>
      <artifactId>micrometer-tracing</artifactId>
    </dependency>
</dependencies>
```

`micrometer-tracing-bridge-brave`, `micrometer-tracing-bridge-otel` 같은 트레이싱<sup>tracing</sup> 브릿지와, span exporter/reporter를 추가해야 한다. 브릿지를 추가하면 전의 의존성<sup>transitive dependency</sup>으로 `micrometer-tracing` 라이브러리가 추가된다.