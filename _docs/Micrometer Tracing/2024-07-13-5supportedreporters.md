---
title: Supported Reporters
category: Micrometer Tracing
order: 5
permalink: /Micrometer%20Tracing/reporters/
description: Micrometer Tracing에서 사용할 수 있는 Reporter들
image: ./../../images/micrometer/logo.png
lastmod: 2024-07-14T17:00:00+09:00
comments: true
originalRefName: 마이크로미터 트레이싱
originalRefLink: https://docs.micrometer.io/tracing/reference/reporters.html
originalVersion: 1.3.2
---

Micrometer Tracing은 다음과 같은 리포터<sup>Reporter</sup>를 직접 지원한다.

- [**Tanzu Observability by Wavefront**](https://tanzu.vmware.com/observability)
- [**OpenZipkin Zipkin**](https://zipkin.io/)


### 목차

[Installing](#installing)

---

## Installing

다음은 Gradle에서 필요한 의존성을 나타낸 예시다 (Micrometer Tracing BOM을 추가했다고 가정한다):

Tanzu Observability by Wavefront

```groovy
implementation 'io.micrometer:micrometer-tracing-reporter-wavefront'
```

OpenZipkin Zipkin with Brave

```groovy
implementation 'io.zipkin.reporter2:zipkin-reporter-brave'
```

OpenZipkin Zipkin with OpenTelemetry

```groovy
implementation 'io.opentelemetry:opentelemetry-exporter-zipkin'
```

`URLConnectionSender`를 통해 Zipkin으로 span을 전송하는 OpenZipkin URL sender 의존성

```groovy
implementation 'io.zipkin.reporter2:zipkin-sender-urlconnection'
```

다음은 Maven에서 필요한 의존성을 나타낸 예시다 (Micrometer Tracing BOM을 추가했다고 가정한다):

Tanzu Observability by Wavefront

```xml
<dependency>
    <groupId>io.micrometer</groupId>
    <artifactId>micrometer-tracing-reporter-wavefront</artifactId>
</dependency>
```

OpenZipkin Zipkin with Brave

```xml
<dependency>
    <groupId>io.zipkin.reporter2</groupId>
    <artifactId>zipkin-reporter-brave</artifactId>
</dependency>
```

OpenZipkin Zipkin with OpenTelemetry

```xml
<dependency>
    <groupId>io.opentelemetry</groupId>
    <artifactId>opentelemetry-exporter-zipkin</artifactId>
</dependency>
```

`URLConnectionSender`를 통해 Zipkin으로 span을 전송하는 OpenZipkin URL sender 의존성

```xml
<dependency>
    <groupId>io.zipkin.reporter2</groupId>
    <artifactId>zipkin-sender-urlconnection</artifactId>
</dependency>
```

> Brave는 기본적으로 Zipkin을 의존성에 추가한다는 점을 기억해두자. Spring Boot와 같이 클래스패스에 있는 의존성으로 실행 환경을 구성하는 경우, Wavefront만 사용하고 싶다면, Brave에서 Zipkin에 대한 전이 의존성<sup>transitive dependency</sup>을 제외해줘야 할 수도 있다 (예를 들어, `io.zipkin.reporter2` 그룹을 제외하는 식으로).