---
title: Supported Tracers
category: Micrometer Tracing
order: 4
permalink: /Micrometer%20Tracing/tracers/
description: Micrometer Tracing에서 사용할 수 있는 Tracer들
image: ./../../images/micrometer/logo.png
lastmod: 2024-07-14T17:00:00+09:00
comments: true
originalRefName: 마이크로미터 트레이싱
originalRefLink: https://docs.micrometer.io/tracing/reference/tracers.html
originalVersion: 1.3.2
---

Micrometer Tracing은 다음과 같은 트레이서<sup>tracer</sup>를 지원한다.

- [**OpenZipkin Brave**](https://github.com/openzipkin/brave)
- [**OpenTelemetry**](https://opentelemetry.io/)

### 목차

[Installing](#installing)

---

## Installing

다음은 Gradle에서 필요한 의존성을 나타낸 예시다 (Micrometer Tracing BOM을 추가했다고 가정한다):

Brave Tracer

```groovy
implementation 'io.micrometer:micrometer-tracing-bridge-brave'
```

OpenTelemetry Tracer

```groovy
implementation 'io.micrometer:micrometer-tracing-bridge-otel'
```

다음은 Maven에서 필요한 의존성을 나타낸 예시다 (Micrometer Tracing BOM을 추가했다고 가정한다):

Brave Tracer

```xml
<dependency>
    <groupId>io.micrometer</groupId>
    <artifactId>micrometer-tracing-bridge-brave</artifactId>
</dependency>
```

OpenTelemetry Tracer

```xml
<dependency>
    <groupId>io.micrometer</groupId>
    <artifactId>micrometer-tracing-bridge-otel</artifactId>
</dependency>
Copied!
```

> 브릿지는 **하나만** 선택해야 한다는 점을 기억해두자. 클래스패스에 브릿지가 두 개 있어서는 **안 된다**.