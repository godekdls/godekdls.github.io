---
title: Using Spring Cloud Sleuth
category: Spring Cloud Sleuth
order: 4
permalink: /Spring%20Cloud%20Sleuth/using-spring-cloud-sleuth/
description: 스프링 클라우드 슬루스 사용 가이드
image: ./../../images/springcloud/logo.jpeg
lastmod: 2024-07-13T14:47:00+09:00
comments: true
originalRefName: 스프링 클라우드 슬루스
originalRefLink: https://docs.spring.io/spring-cloud-sleuth/docs/3.1.11/reference/htmlsingle/#using
originalVersion: 3.1.11
---

이번 섹션에선 Spring Cloud Sleuth 사용법에 대해 좀 더 자세히 설명한다. 여기에서 다루는 주제들 중에는 Spring Cloud Sleuth API나 어노테이션을 이용해 span의 수명 주기를 제어하는 것과 같은 주제도 있다. 또한 Spring Cloud Sleuth와 관련된 몇 가지 모범 사례<sup>best practice</sup>도 함께 다룬다.

Spring Cloud Sleuth가 처음이라면, 이번 섹션을 시작하기 전에 [Getting Started](../getting-started) 가이드를 먼저 읽어보는 것을 추천한다.

### 목차

- [3.1. Span Lifecycle with Spring Cloud Sleuth’s API](#31-span-lifecycle-with-spring-cloud-sleuths-api)
  + [3.1.1. Creating and Ending Spans](#311-creating-and-ending-spans)
  + [3.1.2. Continuing Spans](#312-continuing-spans)
  + [3.1.3. Creating a Span with an explicit Parent](#313-creating-a-span-with-an-explicit-parent)
- [3.2. Naming Spans](#32-naming-spans)
  + [3.2.1. `@SpanName` Annotation](#321-spanname-annotation)
  + [3.2.2. `toString()` Method](#322-tostring-method)
- [3.3. Managing Spans with Annotations](#33-managing-spans-with-annotations)
  + [3.3.1. Creating New Spans](#331-creating-new-spans)
  + [3.3.2. Continuing Spans](#332-continuing-spans)
  + [3.3.3. Advanced Tag Setting](#333-advanced-tag-setting)
    * [Custom Extractor](#custom-extractor)
    * [Resolving Expressions for a Value](#resolving-expressions-for-a-value)
    * [Using The `toString()` Method](#using-the-tostring-method)
- [3.4. What to Read Next](#34-what-to-read-next)

---

## 3.1. Span Lifecycle with Spring Cloud Sleuth’s API

Spring Cloud Sleuth의 핵심 코드는 `api` 모듈에 있는데, 여기에는 트레이서<sup>tracer</sup>가 구현해야 하는 모든 인터페이스가 들어 있다. Spring Cloud Sleuth 프로젝트엔 OpenZipkin Brave 구현체가 포함되어 있다. 트레이서<sup>tracer</sup>가 Sleuth의 API에 어떻게 연결되는지는 `org.springframework.cloud.sleuth.brave.bridge`를 보면 알 수 있다.

가장 많이 사용하는 인터페이스는 다음과 같다:

- `org.springframework.cloud.sleuth.Tracer` - 트레이서<sup>tracer</sup>를 사용하면 요청의 핵심 경로를 포착해서 root span을 생성할 수 있다.
- `org.springframework.cloud.sleuth.Span` - span은 시작하고 종료해줘야 하는 하나의 작업 단위다. 시간 정보와 이벤트 및 태그를 포함한다.

물론 트레이서<sup>tracer</sup> 구현체의 API를 직접 사용할 수도 있다.

이어서 Span 수명 주기에 따른 작업을 살펴보자.

- [start](#311-creating-and-ending-spans): span을 시작할 땐, span의 이름을 지정하고 시작 타임스탬프 값을 기록한다.
- [end](#311-creating-and-ending-spans): span이 종료된다 (span의 종료 시간을 기록한다). span을 샘플링했다면 그대로 수집할 수 있다 (e.g. Zipkin으로).
- [continue](#312-continuing-spans): span이 계속 이어진다 (e.g. 다른 스레드에서).
- [create with explicit parent](#313-creating-a-span-with-an-explicit-parent): span을 새로 하나 만들고 부모 설정을 명시해줄 수 있다.

> `Tracer` 인스턴스는 Spring Cloud Sleuth가 하나 생성해줄 거다. 이 인스턴스를 사용하고 싶다면, 자동 주입<sup>autowire</sup>을 이용하면 된다.

### 3.1.1. Creating and Ending Spans

span은 아래 예제와 같이 `Tracer`를 사용해 직접 생성할 수 있다:

```java
// Start a span. If there was a span present in this thread it will become
// the `newSpan`'s parent.
Span newSpan = this.tracer.nextSpan().name("calculateTax");
try (Tracer.SpanInScope ws = this.tracer.withSpan(newSpan.start())) {
    // ...
    // You can tag a span
    newSpan.tag("taxValue", taxValue);
    // ...
    // You can log an event on a span
    newSpan.event("taxCalculated");
}
finally {
    // Once done remember to end the span. This will allow collecting
    // the span to send it to a distributed tracing system e.g. Zipkin
    newSpan.end();
}
```

앞의 예제에서는 span의 인스턴스를 새로 만드는 방법을 확인할 수 있었다. 현재 스레드에 이미 span이 있는 경우, 기존 span은 새 span의 부모가 된다.

> span을 생성한 다음에는 반드시 정리해줘야 한다.

> span에 50자를 초과하는 이름을 지정하면 50자로 잘리게된다. 이름은 명시적이면서 구체적이어야 한다. 하지만 이름이 너무 길어지면 지연 이슈가 생겨나고 때에 따라 예외가 발생하기도 한다.

### 3.1.2. Continuing Spans

때에 따라서 span을 새로 만들기보단 기존 span을 계속 사용하길 바랄 수도 있다. 예를 들면 다음과 같은 상황이 있을 수 있다:

- **AOP**: aspect에 도달하기 전에 이미 만들어둔 span이 있는 경우, span을 새로 만들고 싶지 않을 수 있다.

span을 계속 이어가려면 아래 예제에서처럼 특정 스레드에 저장한 span을 다른 스레드로 넘겨주면 된다.

```java
Span spanFromThreadX = this.tracer.nextSpan().name("calculateTax");
try (Tracer.SpanInScope ws = this.tracer.withSpan(spanFromThreadX.start())) {
    executorService.submit(() -> {
        // Pass the span from thread X
        Span continuedSpan = spanFromThreadX;
        // ...
        // You can tag a span
        continuedSpan.tag("taxValue", taxValue);
        // ...
        // You can log an event on a span
        continuedSpan.event("taxCalculated");
    }).get();
}
finally {
    spanFromThreadX.end();
}
```

### 3.1.3. Creating a Span with an explicit Parent

span을 새로 시작면서 이 span의 부모를 명시하고 싶을 수도 있다. 예를 들어서 어떤 스레드에서 새 span을 시작하고 싶은데, 다른 스레드에 이 span의 부모가 있다고 가정해 보자. `Tracer.nextSpan()`을 호출하면 언제나 현재 스코프 내에 있는 span을 참조해서 span을 만든다. 다음 예제와 같이 스코프 안에 span을 집어넣은 다음 `Tracer.nextSpan()`을 호출하면 된다:

```java
// let's assume that we're in a thread Y and we've received
// the `initialSpan` from thread X. `initialSpan` will be the parent
// of the `newSpan`
Span newSpan = null;
try (Tracer.SpanInScope ws = this.tracer.withSpan(initialSpan)) {
    newSpan = this.tracer.nextSpan().name("calculateCommission");
    // ...
    // You can tag a span
    newSpan.tag("commissionValue", commissionValue);
    // ...
    // You can log an event on a span
    newSpan.event("commissionCalculated");
}
finally {
    // Once done remember to end the span. This will allow collecting
    // the span to send it to e.g. Zipkin. The tags and events set on the
    // newSpan will not be present on the parent
    if (newSpan != null) {
        newSpan.end();
    }
}
```

> 이렇게 span을 만든 후에는 반드시 완료해줘야 한다. 그렇지 않으면 리포트되지 않는다 (e.g. Zipkin에).

 `Tracer.nextSpan(Span parentSpan)`과 같이 사용하면 부모 span을 직접 명시해줄 수도 있다.

---

## 3.2. Naming Spans

span 이름을 잘 고르는 것은 쉽지만은 않다. span의 이름을 보면 어떤 연산<sup>operation</sup>인지 알 수 있어야 한다. 이름은 카디널리티가 높으면 안 되기 때문에, 식별자를 포함해선 안 된다.

Sleuth에선 굉장히 많은 것들을 계측<sup>instrumentation</sup>하기 때문에, 다소 인위적인 span 이름도 존재한다:

- 요청이 컨트롤러의 `controllerMethodName` 메소드로 전달된 경우 `controller-method-name`.
- `Callable`과 `Runnable` 인터페이스를 감싼 비동기 연산인 경우 `async`.
- `@Scheduled` 어노테이션을 선언한 메소드의 경우 클래스의 simple name.

다행히도 비동기 처리의 경우 이름을 직접 명시할 수 있다.

### 3.2.1. `@SpanName` Annotation

아래 예제와 같이 `@SpanName` 어노테이션을 통해 span의 이름을 직접 지정할 수 있다:

```java
@SpanName("calculateTax")
class TaxCountingRunnable implements Runnable {

    @Override
    public void run() {
        // perform logic
    }

}
```

이 경우, 다음과 같은 방식으로 코드를 실행하면  span의 이름은 `calculateTax`가 된다:

```java
Runnable runnable = new TraceRunnable(this.tracer, spanNamer, new TaxCountingRunnable());
Future<?> future = executorService.submit(runnable);
// ... some additional logic ...
future.get();
```

### 3.2.2. `toString()` Method

`Runnable`이나 `Callable`을 직접 상속해서 별도 클래스를 정의하는 경우는 많지 않다. 보통 필요하면 익명 클래스를 만들어 사용한다. 하지만 익명 클래스에는 어노테이션을 달 수 없다. Sleuth는 이렇게 `@SpanName` 어노테이션이 없을 때는, 해당 클래스가 `toString()` 메소드를 재정의했는지를 확인하기 때문에, 이럴 땐 `toString()` 메소드를 활용하면 된다.

다음과 같은 코드를 실행하면 `calculateTax`라는 이름의 span이 만들어진다:

```java
Runnable runnable = new TraceRunnable(this.tracer, spanNamer, new Runnable() {
    @Override
    public void run() {
        // perform logic
    }

    @Override
    public String toString() {
        return "calculateTax";
    }
});
Future<?> future = executorService.submit(runnable);
// ... some additional logic ...
future.get();
```

---

## 3.3. Managing Spans with Annotations

span을 어노테이션으로 관리하면 좋은 점들이 몇 가지 있다. 예를 들어:

- API에 구애받지 않고 span을 활용할 수 있다. 어노테이션을 이용하면 span API에 대한 라이브러리 의존성 없이도 span을 추가할 수 있다. 덕분에 Sleuth는 핵심 API를 변경하더라도 사용자 코드에 미치는 영향을 최소화할 수 있다.
- 기본적인 span 연산들만 노출해주고, 복잡한 기능은 감출 수 있다. 어노테이션을 지원하지 않으면 span API를 직접 사용해야 하는데, 특히 수명주기와 관련된 명령어는 잘못 사용하기가 쉽다. 스코프, 태그, 로그 기능만 노출해주면 span을 활용하면서 실수로 span 수명주기를 망가트릴 일이 크게 줄어든다.
- 런타임에 생성되는 코드와도 잘 동작한다. Spring Data나 Feign과 같은 라이브러리를 사용하면 런타임에 인터페이스 구현체가 만들어지는데, 이런 객체를 span으로 감싸는 건 꽤나 성가신 작업이었다. 이제는 인터페이스와 인터페이스 인자 위에 어노테이션을 선언하면 된다.

### 3.3.1. Creating New Spans

로컬 span을 직접 생성하고 싶지 않다면 `@NewSpan` 어노테이션을 사용하면 된다. 또한 `@SpanTag` 어노테이션도 제공하고 있으므로, 태그 추가도 자동화할 수 있다.

이제 몇 가지 사용 예시를 살펴보자.

```java
@NewSpan
void testMethod();
```

파라미터가 없는 메소드에 어노테이션을 달면, 해당 메소드와 이름이 동일한 새 span이 생성된다.

```java
@NewSpan("customNameOnTestMethod4")
void testMethod4();
```

어노테이션에 값을 설정해주면 (`name` 파라미터를 명시해도 되고, 생략해도 된다) 이 값을 이름으로 가진 span을 생성한다.

```java
// method declaration
@NewSpan(name = "customNameOnTestMethod5")
void testMethod5(@SpanTag("testTag") String param);

// and method execution
this.testBean.testMethod5("test");
```

이름과 태그를 조합해서 사용할 수도 있다. 태그의 경우, 어노테이션을 선언한 메소드가 런타임에 받은 파라미터 값이 바로 태그의 값이 된다. 위 예제에선 태그의 키는 `testTag`, 태그 값은 `test`다.

```java
@NewSpan(name = "customNameOnTestMethod3")
@Override
public void testMethod3() {
}
```

`@NewSpan` 어노테이션은 클래스 위에도, 인터페이스 위에도 선언할 수 있다. 인터페이스에 있는 메소드를 재정의하고 `@NewSpan` 어노테이션으로 다른 값을 지정했다면, 상속한 쪽에 있는 값을 우선시한다 (위 케이스에선 `customNameOnTestMethod3`로 설정된다).

### 3.3.2. Continuing Spans

기존 span에 태그와 어노테이션을 추가하고 싶다면, 다음과 같이 `@ContinueSpan` 어노테이션을 사용하면 된다:

```java
// method declaration
@ContinueSpan(log = "testMethod11")
void testMethod11(@SpanTag("testTag11") String param);

// method execution
this.testBean.testMethod11("test");
this.testBean.testMethod13();
```

(`@NewSpan` 어노테이션과는 다르게, `log` 파라미터를 이용해 로그를 추가할 수도 있다.)

그러면 기존 span을 계속해서 이어가고,

- `testMethod11.before`와 `testMethod11.after`라는 이름의 로그 엔트리가 생성된다.
- 예외가 발생하면 `testMethod11.afterFailure`라는 로그 엔트리도 생성된다.
- key=`testTag11`, value=`test`인 태그가 생성된다.

### 3.3.3. Advanced Tag Setting

span은 세 가지 방법으로 태그를 추가할 수 있다. 세 가지 방법 모두 `SpanTag` 어노테이션으로 제어하며, 태그 값은 다음과 같은 우선순위를 따른다:

1. `TagValueResolver` 타입 빈이 있다면 `TagValueResolver`를 사용한다.
2. `TagValueResolver` 타입 클래스명을 지정하지 않은 경우 표현식을 평가해 본다. 이땐 `TagValueExpressionResolver` 빈을 찾아본다. 디폴트 구현체는 SPEL 표현식을 해석한다. **(주의)** 이때 SPEL 표현식에서는 프로퍼티 참조만 가능하다. 보안 상의 이유로 메소드 실행은 허용하지 않고있다.
3. 평가할 표현식을 찾지 못하면 파라미터 값으로 `toString()`을 호출한다.

#### Custom Extractor

아래 있는 메소드의 태그 값은 `TagValueResolver` 인터페이스의 구현체로 계산한다. 이 클래스명은 `resolver` 속성 값으로 전달해야 한다.

다음과 같은 메소드에 어노테이션이 선언되어 있다:

```java
@NewSpan
public void getAnnotationForTagValueResolver(
        @SpanTag(key = "test", resolver = TagValueResolver.class) String test) {
}
```

이제 아래 `TagValueResolver` 빈의 구현체를 자세히 살펴보자:

```java
@Bean(name = "myCustomTagValueResolver")
public TagValueResolver tagValueResolver() {
    return parameter -> "Value from myCustomTagValueResolver";
}
```

위 두 코드에서는 태그 값을 `Value from myCustomTagValueResolver`와 같이 세팅하고 있다.

#### Resolving Expressions for a Value

이번엔 메소드에 위에 다음과 같이 어노테이션이 선언되어 있다:

```java
@NewSpan
public void getAnnotationForTagValueExpression(
        @SpanTag(key = "test", expression = "'hello' + ' characters'") String test) {
}
```

별도로 `TagValueExpressionResolver` 구현체를 제공하지 않았다면 SPEL 표현식으로 평가하며, span에는 `hello characters`를 값으로 가진 태그가 세팅된다. 다른 메커니즘으로 표현식을 처리하고 싶다면 빈을 자체적으로 구현하면 된다.

#### Using The `toString()` Method

이제 아래 메소드와 어노테이션을 살펴보자:

```java
@NewSpan
public void getAnnotationForArgumentToString(@SpanTag("test") Long param) {
}
```

위 메소드에 파라미터로 `15`를 넘겨 실행하면 문자열 `"15"`를 값으로 가진 태그가 설정된다.

---

## 3.4. What to Read Next

여기까지 따라왔다면 Spring Cloud Sleuth를 어떻게 사용해야 하는지, 따라야 할 모범 사례<sup>best practice</sup>는 어떤 게 있는지 이해했을 거다. 이제 원하는 [Spring Cloud Sleuth 기능](../features)에 대해 알아보거나, 앞부분은 건너뛰고 [Spring Cloud Sleuth에서 지원하는 여러 가지 통합 기능들](../sleuth-customization)에 관해 읽어봐도 좋다.

