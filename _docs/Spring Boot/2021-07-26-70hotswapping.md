---
title: Hot Swapping
category: Spring Boot 2.X
order: 70
permalink: /Spring%20Boot/howto.hot-swapping/
description: hot swapping과 관련된 how to 가이드
image: ./../../images/springboot/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 부트
originalRefLink: https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#howto.hotswapping
parent: “How-to” Guides
parentUrl: /Spring%20Boot/how-to-guides/
priority: 0.4
---

### 목차

- [12.14.1. Reload Static Content](#12141-reload-static-content)
- [12.14.2. Reload Templates without Restarting the Container](#12142-reload-templates-without-restarting-the-container)
  + [Thymeleaf Templates](#thymeleaf-templates)
  + [FreeMarker Templates](#freemarker-templates)
  + [Groovy Templates](#groovy-templates)
- [12.14.3. Fast Application Restarts](#12143-fast-application-restarts)
- [12.14.4. Reload Java Classes without Restarting the Container](#12144-reload-java-classes-without-restarting-the-container)

---

## 12.14. Hot Swapping

스프링 부트는 hot swapping을 지원한다. 이번 섹션에선 hot swapping 동작 방식과 관련된 질문들에 답해본다.

### 12.14.1. Reload Static Content

hot reloading에는 몇 가지 옵션이 있다. 그 중에선 [`spring-boot-devtools`](../developing-with-spring-boot/#68-developer-tools)를 사용하는 것을 권장한다. 이 모듈은 빠른 애플리케이션 재시작과 LiveReload 지원같이, 개발 시점에 유용한 기능들과 합리적인 설정(템플릿 캐시 등)을 제공한다. Devtools는 클래스패스의 변경 사항을 모니터링하는 식으로 동작한다. 변경 사항이 반영되려면 스태틱 리소스의 변경 사항을 "빌드"해야 한다는 뜻이다. 이클립스에선 기본적으로 변경 사항을 저장할 때 자동으로 빌드해준다. IntelliJ IDEA에선 Make Project 명령이 필요한 빌드를 트리거해준다. [디폴트 restart excludsions 설정](../developing-with-spring-boot/#excluding-resources)으로 인해 스태틱 리소스를 변경해도 애플리케이션 재시작을 트리거하지 않는다. 그대신 live reload를 트리거한다.

아니면 IDE에서 실행하는 것도 (특히 디버깅을 켠 상태로) 개발하기 좋은 방법이다 (최신 IDE는 모두 스태틱 리소스를 다시 로드할 수 있으며, 보통은 자바 클래스 변경 사항으로도 hot-swapping을 허용한다).

마지막으로 [메이븐과 그래들 플러그인](../build-tool-plugins)을 이용해 소스에서 바로 스태틱 파일들을 다시 로드하도록 설정하면 (`addResources` 프로퍼티 참고), 커맨드라인에서 실행할 때도 지원할 수 있다. 고수준 툴을 사용해 코드를 작성하고 있다면 외부 css/js 컴파일러 프로세스도 함께 사용할 수 있다.

### 12.14.2. Reload Templates without Restarting the Container

스프링 부트에서 지원하는 템플릿 기술은 대부분 캐시를 비활성화하는 설정 옵션을 가지고 있다 (뒤에서 설명한다). `spring-boot-devtools` 모듈을 사용한다면 이런 프로퍼티들은 개발할 때 [자동으로 설정](../developing-with-spring-boot#681-property-defaults)된다.

#### Thymeleaf Templates

Thymeleaf를 사용한다면 `spring.thymeleaf.cache`를 `false`로 설정해라. 다른 Thymeleaf 커스텀 옵션들은 [`ThymeleafAutoConfiguration`](https://github.com/spring-projects/spring-boot/tree/v2.5.2/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/thymeleaf/ThymeleafAutoConfiguration.java)을 참고해라.

#### FreeMarker Templates

FreeMarker를 사용한다면, `spring.freemarker.cache`를 `false`로 설정해라. 다른 FreeMarker 커스텀 옵션들은 [`FreeMarkerAutoConfiguration`](https://github.com/spring-projects/spring-boot/tree/v2.5.2/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/freemarker/FreeMarkerAutoConfiguration.java)을 참고해라.

#### Groovy Templates

Groovy 템플릿을 사용한다면, `spring.groovy.template.cache`를 `false`로 설정해라. 다른 Groovy 커스텀 옵션들은 [`GroovyTemplateAutoConfiguration`](https://github.com/spring-projects/spring-boot/tree/v2.5.2/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/groovy/template/GroovyTemplateAutoConfiguration.java)을  참고해라.

### 12.14.3. Fast Application Restarts

`spring-boot-devtools` 모듈은 자동 애플리케이션 재시작을 지원한다. [JRebel](https://www.jrebel.com/products/jrebel)같은 기술만큼 빠르지는 않지만, 보통은 "cold start"보다는 확실히 빠르다. 뒤에서 설명하는 더 복잡한 reload 옵션을 살펴보기 전에 먼저 시도해 보는 게 좋다.

자세한 내용은 [Developer Tools](../developing-with-spring-boot#68-developer-tools) 섹션을 참고해라.

### 12.14.4. Reload Java Classes without Restarting the Container

최신 IDE(Eclipse, IDEA 등)는 많이들 바이트 코드 hot swapping을 지원한다. 따라서 클래스나 메소드 시그니처에 영향을 주지 않는 변경 사항 정도는 부작용 없이 깔끔하게 다시 로드될 거다.

