---
title: Kotlin Support
category: Spring Data R2DBC
order: 18
permalink: /Spring%20Data%20R2DBC/kotlinsupport/
description: 스프링 데이터 R2DBC에서 지원하는 코틀린 전용 API(Null-safety, 익스텐션, 코루틴) 소개
image: ./../../images/spring/logo.png
lastmod: 2020-12-19T23:00:00+09:00
comments: true
originalRefName: 스프링 데이터 R2DBC
originalRefLink: https://docs.spring.io/spring-data/r2dbc/docs/1.2.2/reference/html/#kotlin
---

### 목차

- [17.1. Requirements](#171-requirements)
- [17.2. Null Safety](#172-null-safety)
- [17.3. Object Mapping](#173-object-mapping)
- [17.4. Extensions](#174-extensions)
- [17.5. Coroutines](#175-coroutines)
  + [17.5.1. Dependencies](#1751-dependencies)
  + [17.5.2. How Reactive translates to Coroutines?](#1752-how-reactive-translates-to-coroutines)
  + [17.5.3. Repositories](#1753-repositories)
    
---

[코틀린](https://kotlinlang.org/)은 JVM(혹은 다른 플랫폼)을 위한 정적 타입 언어(statically-typed language)로, 간결하고 우아한 코드를 작성할 수 있으며 기존에 자바로 작성된 라이브러리와도 [잘 동작한다](https://kotlinlang.org/docs/reference/java-interop.html).

스프링 데이터는 코틀린을 최우선으로 지원하고 있으므로, 개발자는 마치 스프링 데이터가 코틀린 네이티브 프레임워크인 것처럼 코틀린 어플리케이션을 작성할 수 있다.

스프링 부트와 [코틀린 전용 기능](../../Spring%20Boot/kotlin-support/)을 활용하면 가장 쉽게 코틀린으로 스프링 어플리케이션을 빌드할 수 있다. 종합 [튜토리얼](https://spring.io/guides/tutorials/spring-boot-kotlin/)에선 [start.spring.io](https://start.spring.io/#!language=kotlin&type=gradle-project)를 활용해 코틀린으로 스프링 부트 어플리케이션을 빌드하는 방법을 안내한다.

---

## 17.1. Requirements

스프링 데이터는 코틀린 1.3을 지원하며, 클래스패스에 [`kotlin-stdlib`](https://bintray.com/bintray/jcenter/org.jetbrains.kotlin%3Akotlin-stdlib)(또는 [`kotlin-stdlib-jdk8`](https://bintray.com/bintray/jcenter/org.jetbrains.kotlin%3Akotlin-stdlib-jdk8)같은 확장 버전)와 [`kotlin-reflect`](https://bintray.com/bintray/jcenter/org.jetbrains.kotlin%3Akotlin-reflect)가 있어야 한다. [start.spring.io](https://start.spring.io/#!language=kotlin&type=gradle-project)에서 코틀린 프로젝트로 만들었다면 기본적으로 포함돼 있다.

---

## 17.2. Null Safety

코틀린의 핵심 기능 중 하나는 [null safety](https://kotlinlang.org/docs/reference/null-safety.html)로, 컴파일 타임에 깔끔하게 `null` 값을 핸들링할 수 있다. `Optional` 같은 래퍼를 사용하지 않고도 널이 될 수 있는지를 선언하고, 값이 있을 때와 없을 때를 구분해서 표현할 수 있어서, 어플리케이션은 더 안전해진다. (코틀린은 함수형 구조에서도 nullable 값을 허용한다. [comprehensive guide to Kotlin null safety](https://www.baeldung.com/kotlin-null-safety)를 참고하라.)

자바의 타입 시스템에서는 null을 안전하게 표현할 수 있는 방법이 없지만, 스프링 데이터 API는 `org.springframework.lang` 패키지에 있는 어노테이션을 사용한다. 여기 있는 어노테이션은 [JSR-305](https://jcp.org/en/jsr/detail?id=305)를 지원하며, 사용하기도 쉽다. 코틀린에서 사용하는 자바 API 타입은 기본적으로 null 체크를 완화시키는 [플랫폼 타입](https://kotlinlang.org/docs/reference/java-interop.html#null-safety-and-platform-types)으로 인지한다. [코틀린은 JSR-305 어노테이션을 지원하며](https://github.com/Kotlin/KEEP/blob/jsr-305/proposals/jsr-305-custom-nullability-qualifiers.md), 스프링 nullability 어노테이션으로 전체 스프링 데이터 API에 대해 null-safety를 제공하고, 코틀린 개발자는 컴파일 타임에 `null` 관련 이슈를 더 잘 처리할 수 있다.

스프링 데이터 레포지토리에 null safety를 적용하는 방법은 [레포지토리 메소드의 Null 처리](../workingwithspringdatarepositories#1147-null-handling-of-repository-methods) 섹션을 참고해라.

> 다음 옵션과 함께 컴파일러 플래그에 `-Xjsr305`를 사용하면 JSR-305를 체크할 수 있다: `-Xjsr305={strict|warn|ignore}`.
>
> 코틀린 1.1+ 버전에선 기본 동작이 `-Xjsr305=warn`과 동일하다. 스프링 데이터 API의 null-safety를 고려하려면 `strict`를 사용해야 한다. 스프링 API에서 코틀린 타입을 추론하지만, 마이너 릴리즈에서도 스프링 API의 nullability 체크가 더 추가될 수 있다는 점을 알고 사용해야 한다.

> 제네릭 타입 인자, 가변 인자, 배열 요소는 아직 Nullability를 지원하지 않지만, 곧 있을 배포에서 지원할 예정이다.

---

## 17.3. Object Mapping

코틀린 객체를 구체화하는 자세한 방식은 [코틀린 지원](../mapping#1614-kotlin-support) 섹션을 참고해라.

---

## 17.4. Extensions

코틀린 [익스텐션](https://kotlinlang.org/docs/reference/extensions.html)을 사용하면 기존 클래스에 새 기능을 추가할 수 있다. 스프링 데이터 코틀린 API에선 익스텐션을 통해 기존 스프링 API에 편리한 코틀린 전용 기능을 추가 제공한다.

> 코틀린 익스텐션을 사용하려면 임포트시켜야 한다는 점을 명심해라. 물론 대부분은 스태틱 임포트처럼 IDE에서 자동으로 임포트를 제안해 줄 거다.

예를 들어 [Kotlin reified type parameters](https://kotlinlang.org/docs/reference/inline-functions.html#reified-type-parameters)로 JVM [generics type erasure](https://docs.oracle.com/javase/tutorial/java/generics/erasure.html)를 해결할 수 있으며, 스프링 데이터는 이 기능을 활용할 수 있도록 몇 가지 익스텐션을 제공한다. 덕분에 더 발전된 코틀린 API를 사용할 수 있다.

자바에서 `SWCharacter` 객체의 리스트를 조회할 땐 보통 다음과 같은 코드를 작성한다:

```java
Flux<SWCharacter> characters = client.select().from(SWCharacter.class).fetch().all();
```

코틀린과 스프링 데이터 익스텐션을 사용하면 다음과 같이 작성할 수 있다:

```kotlin
val characters =  client.select().from<SWCharacter>().fetch().all()
// or (both are equivalent)
val characters : Flux<SWCharacter> = client.select().from().fetch().all()
```

자바와 마찬가지로 코틀린에서도 `characters` 타입을 체크해야 하지만(strongly typed), 코틀린의 똑똑한 타입 추론 덕분에 더 짧은 코드로 구현할 수 있다.

스프링 데이터 R2DBC는 다음과 같은 익스텐션을 제공한다:

- `DatabaseClient`, `Criteria`의 Reified 제네릭 지원.
- `DatabaseClient`의 [코루틴](#175-coroutines) 익스텐션.

---

## 17.5. Coroutines

코틀린 [코루틴](https://kotlinlang.org/docs/reference/coroutines-overview.html)은 논블로킹 코드를 명령적으로(imperatively) 작성할 수 있는 경량 스레드다. 언어 측면에서 보면 `suspend` 함수가 비동기 연산을 추상화해주고, 라이브러리 측면에선 [kotlinx.coroutines](https://github.com/Kotlin/kotlinx.coroutines)가 [`async { }`](https://kotlin.github.io/kotlinx.coroutines/kotlinx-coroutines-core/kotlinx.coroutines/async.html)같은 함수와, [`Flow`](https://kotlin.github.io/kotlinx.coroutines/kotlinx-coroutines-core/kotlinx.coroutines.flow/-flow/index.html)같은 타입을 제공한다.

스프링 데이터 모듈은 이 지원하는 코틀린 범위는 다음과 같다:

- 코틀린 익스텐션에서 리턴 타입에 [Deferred](https://kotlin.github.io/kotlinx.coroutines/kotlinx-coroutines-core/kotlinx.coroutines/-deferred/index.html)와 [Flow](https://kotlin.github.io/kotlinx.coroutines/kotlinx-coroutines-core/kotlinx.coroutines.flow/-flow/index.html) 지원

### 17.5.1. Dependencies

코루틴 지원은 클래스패스에 `kotlinx-coroutines-core`, `kotlinx-coroutines-reactive`, `kotlinx-coroutines-reactor` 의존성이 있을 때 활성화된다:

**Example 88. Dependencies to add in Maven pom.xml**

```xml
<dependency>
  <groupId>org.jetbrains.kotlinx</groupId>
  <artifactId>kotlinx-coroutines-core</artifactId>
</dependency>

<dependency>
  <groupId>org.jetbrains.kotlinx</groupId>
  <artifactId>kotlinx-coroutines-reactive</artifactId>
</dependency>

<dependency>
  <groupId>org.jetbrains.kotlinx</groupId>
  <artifactId>kotlinx-coroutines-reactor</artifactId>
</dependency>
```

> `1.3.0` 버전 이상을 지원한다.

### 17.5.2. How Reactive translates to Coroutines?

반환 값에 사용하는 리액티브 타입은 다음과 같이 코틀린 API로 바꿀 수 있다:

- `fun handler(): Mono<Void>`는 `suspend fun handler()`가 된다.
- `fun handler(): Mono<T>`는 `Mono`가 빈 값이 될 수 있는지에 따라 (더 정적으로 타입을 정할 수 있다) `suspend fun handler(): T`  또는 `suspend fun handler(): T?`가 된다.
- `fun handler(): Flux<T>`는 `fun handler(): Flow<T>`가 된다.

코루틴 세계에서 [`Flow`](https://kotlin.github.io/kotlinx.coroutines/kotlinx-coroutines-core/kotlinx.coroutines.flow/-flow/index.html)는 `Flux`와 동일하며, hot 또는 cold 스트림이나 유한 또는 무한 스트림에 적합하며, 다음과 같은 주요 차이점이 있다:

- `Flux`는 push-pull 하이브리드지만, `Flow`는 push 기반이다.
- Backpressure는 suspend 함수로 구현한다.
- `Flow`는 [suspend 메소드 `collect`](https://kotlin.github.io/kotlinx.coroutines/kotlinx-coroutines-core/kotlinx.coroutines.flow/-flow/collect.html) 하나만 가지고 있으며, 연산자는 [익스텐션](https://kotlinlang.org/docs/reference/extensions.html)으로 구현한다.
- 코루틴 덕분에 [연산자를 구현하기가 쉽다](https://github.com/Kotlin/kotlinx.coroutines/tree/master/kotlinx-coroutines-core/common/src/flow/operators).
- 익스텐션으로 `Flow`에 커스텀 연산자를 추가할 수 있다.
- Collect 연산자는 모두 suspend 함수다.
- [`map` 연산자](https://kotlin.github.io/kotlinx.coroutines/kotlinx-coroutines-core/kotlinx.coroutines.flow/map.html)는 suspend 함수 파라미터를 받기 때문에 비동기 연산을 지원한다 (`flatMap`은 불필요).

코루틴으로 동시에 코드를 실행하는 방법 등 자세한 내용은 블로그 문서 [Going Reactive with Spring, Coroutines and Kotlin Flow](https://spring.io/blog/2019/04/12/going-reactive-with-spring-coroutines-and-kotlin-flow)를 읽어봐라.

### 17.5.3. Repositories

코루틴 레포지토리 예시는 여기에 있다:

```kotlin
interface CoroutineRepository : CoroutineCrudRepository<User, String> {

    suspend fun findOne(id: String): User

    fun findByFirstname(firstname: String): Flow<User>

    suspend fun findAllByFirstname(id: String): List<User>
}
```

코루틴 레포지토리는 리액티브 레포지토리를 기반으로, 코틀린의 코루틴을 통한 논블로킹 데이터 접근 메소드를 정의한다. 코루틴 레포지토리의 메소드는 쿼리 메소드와 커스텀 구현을 둘 다 지원한다. 커스텀 구현체 메소드를 호출하면, 구현 메소드가 `Mono`나 `Flux`같은 리액티브 타입을 반환할 필요 없이 `suspend`할 수 있다면 실제 구현체 메소드로 코루틴 호출을 전파한다.

> 코루틴 레포지토리는 `CoroutineCrudRepository` 인터페이스를 확장해야 감지할 수 있다.