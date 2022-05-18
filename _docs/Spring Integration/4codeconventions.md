---
title: Code Conventions
category: Spring Integration
order: 4
permalink: /Spring%20Integration/code-conventions/
description: 스프링 인티그레이션 네임스페이스 컨벤션 가이드
image: ./../../images/springintegration/logo.png
lastmod: 2022-01-05T21:30:00+09:00
comments: true
originalRefName: 스프링 인티그레이션
originalRefLink: https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/index-single.html#code-conventions
parent: Preface
parentUrl: /Spring%20Integration/preface/
---

---

스프링 프레임워크 2.0에선 네임스페이스 지원을 도입했다. 덕분에 애플리케이션 컨텍스트 세팅을 위한 XML 설정은 더 단순해지고, Spring Integration에서도 광범위한 네임스페이스를 지원할 수 있게 됐다.

이 레퍼런스 가이드에선, Spring Integration의 코어 네임스페이스 기능에 `int`를 네임스페이스 프리픽스로 사용한다. 각 Spring Integration 어댑터 타입(모듈이라고도 부른다)은 아래 있는 컨벤션을 사용해 구성한 자체 네임스페이스를 제공한다:

다음은 `int`, `int-event`, `int-stream` 네임스페이스를 사용하는 예시다:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:int="http://www.springframework.org/schema/integration"
  xmlns:int-webflux="http://www.springframework.org/schema/integration/webflux"
  xmlns:int-stream="http://www.springframework.org/schema/integration/stream"
  xsi:schemaLocation="
   http://www.springframework.org/schema/beans
   https://www.springframework.org/schema/beans/spring-beans.xsd
   http://www.springframework.org/schema/integration
   https://www.springframework.org/schema/integration/spring-integration.xsd
   http://www.springframework.org/schema/integration/webflux
   https://www.springframework.org/schema/integration/webflux/spring-integration-webflux.xsd
   http://www.springframework.org/schema/integration/stream
   https://www.springframework.org/schema/integration/stream/spring-integration-stream.xsd">
…
</beans>
```

Spring Integration이 지원하는 네임스페이스와 관련된 내용은 [네임스페이스 지원](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/configuration.html#configuration-namespace) 섹션에서 자세히 다룬다.

> 네임스페이스 프리픽스는 자유롭게 선택할 수 있다. 네임스페이스 프리픽스를 아예 사용하지 않는 것도 가능하다. 그렇기 때문에 개발 중인 애플리케이션에 가장 잘 맞는 컨벤션을 적용하는 게 좋다. 단, SpringSource Tool Suite™(STS)에선 Spring Integration 관련 네임스페이스 컨벤션은 이 레퍼런스 가이드에서 사용하는 것과 동일한 컨벤션을 사용한다는 점을 알아두자.
