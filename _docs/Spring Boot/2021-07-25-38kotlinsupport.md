---
title: Kotlin support
category: Spring Boot
order: 38
permalink: /Spring%20Boot/kotlin-support/
description: 스프링 부트와 코틀린을 사용해 애플리케이션 개발하기
image: ./../../images/springboot/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 부트
originalRefLink: https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#features.kotlin
parent: Spring Boot Features
parentUrl: /Spring%20Boot/spring-boot-features/
---

### 목차

- [7.30.1. Requirements](#7301-requirements)
- [7.30.2. Null-safety](#7302-null-safety)
- [7.30.3. Kotlin API](#7303-kotlin-api)
  + [Extensions](#extensions)
- [7.30.4. Dependency management](#7304-dependency-management)
- [7.30.5. @ConfigurationProperties](#7305-configurationproperties)
- [7.30.6. Testing](#7306-testing)
- [7.30.7. Resources](#7307-resources)
  + [Further reading](#읽을-거리)
  + [Examples](#예제)

---

##  7.30. Kotlin support

[코틀린](https://kotlinlang.org/)은 JVM(혹은 다른 플랫폼)을 위한 정적 타입 언어<sup>statically-typed language</sup>로, 간결하고 우아한 코드를 작성할 수 있으며 기존에 자바로 작성된 라이브러리와도 뛰어난 [상호 운용성](https://kotlinlang.org/docs/reference/java-interop.html)을 자랑하는 언어다.

스프링 부트에서도 코틀린을 사용할 수 있으며, 스프링 프레임워크, 스프링 데이터, 리액터 같은 다른 스프링 프로젝트에서 지원하는 코틀린 지원 기능을 그대로 활용한다. 자세한 내용은 [스프링 프레임워크의 코틀린 지원 문서](https://docs.spring.io/spring-framework/docs/5.3.8/reference/html/languages.html#kotlin)를 참고해라.

[여기 있는 포괄적인 튜토리얼](https://spring.io/guides/tutorials/spring-boot-kotlin/)을 따라하면 스프링 부트와 코틀린을 가장 쉽게 시작해볼 수 있다. 코틀린 프로젝트를 새로 만들 때는 [start.spring.io](https://start.spring.io/#!language=kotlin)를 활용해도 된다. [Kotlin Slack](https://slack.kotlinlang.org/)의 #spring 채널에는 자유롭게 참여할 수 있으며, 지원이 필요하다면 [Stack Overflow](https://stackoverflow.com/questions/tagged/spring+kotlin)에 `spring`, `kotlin` 태그를 달아 질문을 올려도 좋다.

### 7.30.1. Requirements

스프링 부트에선 최소한 코틀린 1.3.x가 필요하며, dependency management를 통해 코틀린 버전을 적절히 관리한다. 코틀린을 사용하려면 클래스패스에 반드시 `org.jetbrains.kotlin:kotlin-stdlib`와 `org.jetbrains.kotlin:kotlin-reflect`가 있어야 한다. `kotlin-stdlib`의 다른 버전인 `kotlin-stdlib-jdk7`과 `kotlin-stdlib-jdk8`을 사용해도 된다.

[코틀린 클래스는 기본이 final](https://discuss.kotlinlang.org/t/classes-final-by-default/166)이기 때문에, 스프링 어노테이션을 선언한 클래스를 프록시 처리하려면 자동으로 open으로 변경할 수 있도록 [kotlin-spring](https://kotlinlang.org/docs/reference/compiler-plugins.html#spring-support) 플러그인을 설정해야 할 거다.

[Jackson의 코틀린 모듈](https://github.com/FasterXML/jackson-module-kotlin)은 코틀린에서 JSON 데이터를 직렬화/역직렬화할 때 필요하다. 클래스패스에서 발견되면 자동으로 등록한다. Jackson과 코틀린은 있지만 Jackson 코틀린 모듈이 없을 땐 경고 메세지를 출력한다.

> [start.spring.io](https://start.spring.io/#!language=kotlin)에서 코틀린 프로젝트를 부트스트랩하면 이런 의존성과 플러그인들을 기본으로 제공한다.

### 7.30.2. Null-safety

코틀린의 핵심 기능 중 하나를 꼽자면 [null safety](https://kotlinlang.org/docs/reference/null-safety.html)다. 런타임까지 문제를 미루다가 `NullPointerException`을 만나는 대신, 컴파일 타임에 `null` 값을 핸들링할 수 있다. 덕분에 `Optional`같은 래퍼를 감수하지 않고도 흔한 버그의 원인을 제거할 수 있다. 게다가 코틀린은, [코트린의 null-safety 종합 가이드](https://www.baeldung.com/kotlin-null-safety)에서도 설명하고 있지만, 함수형 구조에서도 nullable 값을 활용할 수 있다.

자바의 타입 시스템에서는 null을 안전하게 표현할 수 있는 방법이 없지만, 스프링 프레임워크, 스프링 데이터, 리액터는 이제 사용하기 편한 어노테이션들을 통해 null-safety를 지원한다. 코틀린에서 사용하는 자바 API 타입은 기본적으로 null 체크를 완화시키는 [플랫폼 타입](https://kotlinlang.org/docs/reference/java-interop.html#null-safety-and-platform-types)으로 인지한다. [코틀린은 JSR 305 어노테이션을 지원하는데](https://kotlinlang.org/docs/reference/java-interop.html#jsr-305-support), nullability 어노테이션과 결합하면 코틀린을 사용하는 관련 스프링 API에 null-safety를 제공할 수 있다.

`-Xjsr305={strict|warn|ignore}` 옵션과 함께 컴파일러 플래그에 `-Xjsr305`를 사용하면 JSR 305를 체크할 수 있다. 기본 동작은 `-Xjsr305=warn`과 동일하다. 스프링 API에서 코틀린 타입을 추론할 때 null-safety를 고려하려면 `strict`를 사용해야 하지만, 스프링 API nullability 선언은 마이너 릴리즈에서도 더 추가될 수 있고, 향후엔 더 많은 검사가 추가될 수도 있다는 점을 유념하고 사용해야 한다.

> 제네릭 타입 인자, 가변 인자, 배열 요소는 아직 nullability를 지원하지 않는다. 최신 정보는 [SPR-15942](https://jira.spring.io/browse/SPR-15942)를 참고해라. 스프링 부트의 자체 API에는 [아직 어노테이션이 없다는 점](https://github.com/spring-projects/spring-boot/issues/10712)도 알아둬라.

### 7.30.3. Kotlin API

스프링 부트는 다음 예제와 같이 좀 더 자연스럽게 애플리케이션을 실행시킬 수 있는 `runApplication<MyApplication>(*args)`를 제공한다:

```kotlin
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class MyApplication

fun main(args: Array<String>) {
    runApplication<MyApplication>(*args)
}
```

이 코드로는 아무런 사이드 이팩트 없이 `SpringApplication.run(MyApplication::class.java, *args)`를 대체할 수 있다<sup>[drop-in replacement](https://en.wikipedia.org/wiki/Drop-in_replacement)</sup>. 아래처럼 애플리케이션을 커스텀할 수도 있다:

```kotlin
runApplication<MyApplication>(*args) {
    setBannerMode(OFF)
}
```

#### Extensions

코틀린 [익스텐션](https://kotlinlang.org/docs/reference/extensions.html)을 사용하면 기존에 있는 클래스를 확장해서 추가 기능을 넣을 수 있다. 스프링 부트 코틀린 API는 기존 API에 이 익스텐션을 적용해서, 코틀린 전용 API들을 추가로 활용할 수 있게 해준다.

스프링 프레임워크가 `RestOperations`를 위한 익스텐션을 제공하는 것처럼, 스프링 부트도 이와 유사한 `TestRestTemplate` 익스텐션을 제공한다. 무엇보다 이 익스텐션을 사용하면 [Kotlin reified type parameters](https://kotlinlang.org/docs/reference/inline-functions.html#reified-type-parameters)를 활용할 수 있다.

### 7.30.4. Dependency management

클래스패스에 버전이 서로 다른 코틀린 의존성이 섞이지 않도록, 스프링 부트는 코틀린 BOM을 임포트한다.

메이븐에선 `kotlin.version` 프로퍼티를 통해 코틀린 버전을 커스텀할 수 있으며, `kotlin-maven-plugin`을 위한 plugin management를 제공한다. 그래들에선 스프링 부트 플러그인이 자동으로 `kotlin.version`을 코틀린 플러그인 버전과 맞춰준다.

스프링 부트는 코틀린 코루틴 BOM을 임포트해서 코루틴 의존성 버전도 관리하고 있다. 이 버전은 `kotlin-coroutines.version` 프로퍼티를 통해 커스텀할 수 있다.

> [start.spring.io](https://start.spring.io/#!language=kotlin)에서 프로젝트를 부트스트랩할 땐 리액티브 의존성이 최소 하나라도 있으면 기본으로 `org.jetbrains.kotlinx:kotlinx-coroutines-reactor` 의존성을 제공한다.

### 7.30.5. @ConfigurationProperties

`@ConfigurationProperties`를 [`@ConstructorBinding`](../externalized-configuration/#constructor-binding)과 함께 사용하면 다음 예제처럼 클래스에 불변<sup>immutable</sup> `val` 프로퍼티를 선언할 수 있다:

```kotlin
@ConstructorBinding
@ConfigurationProperties("example.kotlin")
data class KotlinExampleProperties(
        val name: String,
        val description: String,
        val myService: MyService) {

    data class MyService(
            val apiToken: String,
            val uri: URI
    )
}
```

> 어노테이션 프로세서를 사용해 [자체 메타데이터](https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#configuration-metadata.annotation-processor)를 생성하려면 `spring-boot-configuration-processor` 의존성을 통해 [`kapt`를 설정해줘야 한다](https://kotlinlang.org/docs/reference/kapt.html). kapt에서 제공하는 모델의 제약으로 인해 일부 기능(ex. 기본값이나 deprecated된 항목 감지)은 동작하지 않는다는 점에 주의해라.

### 7.30.6. Testing

코틀린 코드는 JUnit 4로도 테스트할 수 있지만, 기본적으론 JUnit 5를 제공하며 권장하는 버전이기도 하다. JUnit 5를 사용하면 테스트 클래스 인스턴스를 한 번만 만들고 그 클래스에 있는 모든 테스트에 재사용할 수 있다. 덕분에 non-static 메소드에 `@BeforeAll`과 `@AfterAll` 어노테이션을 사용할 수 있으며, 코틀린에서 사용하기에도 적합하다.

코틀린 클래스를 모킹할 때는 [MockK](https://mockk.io/)를 권장한다. Mockito 전용 [`@MockBean`, `@SpyBean` 어노테이션](../testing#mocking-and-spying-beans)을 대신할 수 있는 `Mockk`를 찾고 있다면, 유사한 `@MockkBean`, `@SpykBean` 어노테이션을 제공하는 [SpringMockK](https://github.com/Ninja-Squad/springmockk)를 사용할 수 있다.

### 7.30.7. Resources

#### 읽을 거리

- [코틀린 언어 레퍼런스](https://kotlinlang.org/docs/reference/)
- [코틀린 슬랙](https://kotlinlang.slack.com/) (전용 #spring 채널)
- [Stackoverflow (`spring`, `kotlin` 태그)](https://stackoverflow.com/questions/tagged/spring+kotlin)
- [브라우저에서 코틀린 코드 작성하고 실행해보기](https://try.kotlinlang.org/)
- [코틀린 블로그](https://blog.jetbrains.com/kotlin/)
- [Awesome Kotlin](https://kotlin.link/)
- [튜토리얼: 스프링 부트와 코틀린으로 웹 애플리케이션 만들기](https://spring.io/guides/tutorials/spring-boot-kotlin/)
- [코틀린으로 스프링 부트 애플리케이션 개발하기](https://spring.io/blog/2016/02/15/developing-spring-boot-applications-with-kotlin)
- [코틀린, 스프링 부트, PostgreSQL을 사용하는 위치 기반 메신저](https://spring.io/blog/2016/03/20/a-geospatial-messenger-with-kotlin-spring-boot-and-postgresql)
- [스프링 프레임워크 5.0의 코틀린 지원 소개](https://spring.io/blog/2017/01/04/introducing-kotlin-support-in-spring-framework-5-0)
- [스프링 프레임워크 5 함수형 코틀린 API](https://spring.io/blog/2017/08/01/spring-framework-5-kotlin-apis-the-functional-way)

#### 예제

- [spring-boot-kotlin-demo](https://github.com/sdeleuze/spring-boot-kotlin-demo): 전형적인 스프링 부트 + 스프링 데이터 JPA 프로젝트
- [mixit](https://github.com/mixitconf/mixit): 스프링 부트 2 + 웹플럭스 + 리액티브 스프링 데이터 MongoDB
- [spring-kotlin-fullstack](https://github.com/sdeleuze/spring-kotlin-fullstack): JavaScript나 TypeScript 대신 프론트엔드 전용 Kotlin2js를 사용하는 웹플럭스 코틀린 풀스택 예제
- [spring-petclinic-kotlin](https://github.com/spring-petclinic/spring-petclinic-kotlin): 코틀린으로 만들어보는 스프링 동물 병원 샘플 애플리케이션
- [spring-kotlin-deepdive](https://github.com/sdeleuze/spring-kotlin-deepdive): 부트 1.0 + 자바에서 부트 2.0 + 코틀린으로 가는 단계별 마이그레이션 과정
- [spring-boot-coroutines-demo](https://github.com/sdeleuze/spring-boot-coroutines-demo): 코루틴 샘플 프로젝트

