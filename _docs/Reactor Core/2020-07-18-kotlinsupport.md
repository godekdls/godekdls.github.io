---
title: Kotlin support
category: Reactor Core
order: 6
permalink: /Reactor%20Core/kotlinsupport/
description: 리액터 코틀린 지원 한글 번역
image: ./../../images/reactorcore/flux.png
lastmod: 2020-07-18T10:51:00+09:00
---

> [프로젝트 리액터 코어 공식 reference](https://projectreactor.io/docs/core/release/reference/#kotlin)를 한글로 번역한 문서입니다.
>
> 전체 목차는 [여기](../contents/)에 있습니다.

### 목차

- [5.1. Requirements](#51-requirements)
- [5.2. Extensions](#52-extensions)
- [5.3. Null Safety](#53-null-safety)

---

[코틀린](https://kotlinlang.org/)은 JVM (혹은 다른 플랫폼)을 위한 정적 타입 언어(statically-typed language)로, 간결하고 우아한 코드를 작성할 수 있으며 기존에 자바로 작성된 라이브러리와도 잘 동작한다.

이번 섹션에선 리액터가 지원하는 코틀린에 대해 설명한다.

---

## 5.1. Requirements

리액터는 코틀린 1.1+을 지원하며 [`kotlin-stdlib`](https://bintray.com/bintray/jcenter/org.jetbrains.kotlin%3Akotlin-stdlib) (또는 [`kotlin-stdlib-jre7`](https://bintray.com/bintray/jcenter/org.jetbrains.kotlin%3Akotlin-stdlib-jre7)이나 [`kotlin-stdlib-jre8`](https://bintray.com/bintray/jcenter/org.jetbrains.kotlin%3Akotlin-stdlib-jre8) 버전 중 하나)가 필요하다.

---

## 5.2. Extensions

> `Dysprosium-M1` (ie. `reactor-core 3.3.0.M1`) 이후로 코틀린 익스텐션은 전용 [`reactor-kotlin-extensions`](https://github.com/reactor/reactor-kotlin-extensions) 모듈로 옮겨졌으며, 패키지명은 `reactor`에서 `reactor.kotlin`으로 변경됐다.
>
> 따라서 `reactor-core` 모듈에 있는 코틀린 익스텐션은 제거될 예정이다(deprecated). 새 의존성 groupId와 artifactId는 다음과 같다:
>
> ```groovy
> io.projectreactor.kotlin:reactor-kotlin-extensions
> ```


뛰어난 [자바와의 상호 운용성](https://kotlinlang.org/docs/reference/java-interop.html)과 [코틀린 익스텐션](https://kotlinlang.org/docs/reference/extensions.html)덕분에, 리액터 코틀린 API는 전형적인 자바 API를 그대로 사용하면서도 리액터 아티팩트에서만 가능한 몇 가지 코틀린 전용 API를 추가로 활용할 수 있다.

> 코틀린 익스텐션을 사용하려면 임포트시켜야 한다는 점을 명심해라. 예를 들어 코틀린 익스텐션 `throwable.toFlux`는 `import reactor.kotlin.core.publisher.toFlux`를 임포트해야 사용할 수 있다. 물론 대부분은 스태틱 임포트처럼 IDE에서 자동으로 임포트를 제안해 줄 것이다.

예를 들어 [Kotlin reified type parameters](https://kotlinlang.org/docs/reference/inline-functions.html#reified-type-parameters)로 JVM [generics type erasure](https://docs.oracle.com/javase/tutorial/java/generics/erasure.html)를 해결할 수 있으며, 리액터는 이 기능을 활용할 수 있도록 몇 가지 확장 기능을 제공한다.

아래 테이블은 자바로 리액터를 사용할 때와, 코틀린 확장 버전으로 리액터를 사용할 때를 비교하고 있다:

| **Java**                                     | **Kotlin with extensions**                          |
| -------------------------------------------- | --------------------------------------------------- |
| `Mono.just("foo")`                           | `"foo".toMono()`                                    |
| `Flux.fromIterable(list)`                    | `list.toFlux()`                                     |
| `Mono.error(new RuntimeException())`         | `RuntimeException().toMono()`                       |
| `Flux.error(new RuntimeException())`         | `RuntimeException().toFlux()`                       |
| `flux.ofType(Foo.class)`                     | `flux.ofType<Foo>()` 또는 `flux.ofType(Foo::class)` |
| `StepVerifier.create(flux).verifyComplete()` | `flux.test().verifyComplete()`                      |

사용할 수 있는 모든 코틀린 익스텐션은 [Reactor KDoc API](https://projectreactor.io/docs/kotlin/release/kdoc-api/)에 있다.

---

## 5.3. Null Safety

코틀린의 핵심 기능 중 하나는 [null safety](https://kotlinlang.org/docs/reference/null-safety.html)로, 런타임에 그 유명한 `NullPointerException`을 만나는 대신 컴파일 타임에 깔끔하게 `null` 값을 핸들링할 수 있다. `Optional`같은 래퍼를 사용하지 않고도 널이 될 수 있는지를 선언하고, 값이 있을 때와 없을 때를 구분해서 표현할 수 있어서, 어플리케이션은 더 안전해진다. (코틀린은 함수형 구조에서도 nullable 값을 허용한다. [comprehensive guide to Kotlin null-safety](https://www.baeldung.com/kotlin-null-safety)를 참고하라.)

자바의 타입 시스템에서는 널을 안전하게 표현할 수 있는 방법이 없지만, 리액터는 `reactor.util.annotation`  패키지에 사용하기 편한 애노테이션이 있기 때문에, 이제는 전체 리액터 API에서 [null safety를 지원한다](../advancedfeaturesandconcepts#910-null-safety). 코틀린에서 사용하는 자바 API 타입은 기본적으로 널 체크를 완화시키는 [플랫폼 타입](https://kotlinlang.org/docs/reference/java-interop.html#null-safety-and-platform-types)으로 인지한다. [코틀린은 JSR 305 애노테이션을 지원하며](https://github.com/Kotlin/KEEP/blob/jsr-305/proposals/jsr-305-custom-nullability-qualifiers.md), 리액터 nullability 애노테이션으로 전체 리액터 API에 대해 null-safety를 제공하고,  코틀린 개발자는 컴파일 타임에 `null` 관련 이슈를 더 잘 처리할 수 있다.

다음 옵션과 함께 컴파일러 플래그에 `-Xjsr305`를 사용하면 JSR 305를 체크할 수 있다: `-Xjsr305={strict|warn|ignore}`.

코틀린 1.1.50+ 버전에선 기본 동작이 `-Xjsr305=warn`과 동일하다. 리액터 API 전체의 null-safety를 고려하면  `strict`를 사용해야 하지만, 마이너 릴리즈에서도 리액터 API의 nullability 체크가 더 추가될 수 있기 때문에 아직 실험 단계다.

> 제네릭 타입 인자, 가변 인자, 배열 요소는 아직 Nullability를 지원하지 않지만, 곧 있을 배포에서 지원할 예정이다. 최신 정보는 [여기 논의](https://github.com/Kotlin/KEEP/issues/79)를 참고하라.

"[Kotlin support](https://projectreactor.io/docs/core/release/reference/#kotlin)" [수정 제안하기](https://github.com/reactor/reactor-core/edit/master/docs/asciidoc/kotlin.adoc)

---

> 전체 목차는 [여기](../contents/)에 있습니다.