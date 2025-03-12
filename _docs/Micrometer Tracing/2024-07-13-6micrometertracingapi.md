---
title: Using Micrometer Tracing Directly
navTitle: Micrometer Tracing API
category: Micrometer Tracing
order: 6
permalink: /Micrometer%20Tracing/api/
description: Micrometer Tracing API 사용 가이드
image: ./../../images/micrometer/logo.png
lastmod: 2024-07-14T17:00:00+09:00
comments: true
originalRefName: 마이크로미터 트레이싱
originalRefLink: https://docs.micrometer.io/tracing/reference/api.html
originalVersion: 1.3.2
priority: 0.7
---

이번 섹션에선 Micrometer Tracing API를 사용해 직접 span을 생성하고 보고하는 방법에 대해 설명한다.

### 목차

- [Micrometer Tracing Examples](#micrometer-tracing-examples)
- [Micrometer Tracing Brave Setup](#micrometer-tracing-brave-setup)
- [Micrometer Tracing OpenTelemetry Setup](#micrometer-tracing-opentelemetry-setup)
- [Micrometer Tracing Baggage API](#micrometer-tracing-baggage-api)
- [Aspect Oriented Programming](#aspect-oriented-programming)

---

## Micrometer Tracing Examples

다음은 span과 관련된 기본적인 연산들을 사용하는 예시다. 자세한 내용은 코드 안에 있는 주석을 읽어봐라:

```java
// span을 생성한다. 현재 스레드에 span이 존재하면
// 기존 span은 `newSpan`의 부모가 된다.
Span newSpan = this.tracer.nextSpan().name("calculateTax");
// span을 시작하고 scope에 추가한다.
// scope에 추가한다는 것은 해당 span을 thread local에 넣는 것을 의미한다.
// 설정한 경우, MDC에 트레이싱 정보를 담는다.
try (Tracer.SpanInScope ws = this.tracer.withSpan(newSpan.start())) {
    // ...
    // span에 태그를 추가할 수 있다 - 디버깅하기 쉽도록 키 값 쌍을 지정한다.
    newSpan.tag("taxValue", taxValue);
    // ...
    // span에 이벤트를 기록할 수 있다 - 이벤트는 타임스탬프와 함께 기록된다.
    newSpan.event("taxCalculated");
}
finally {
    // 작업을 완료하면 span을 종료하는 것을 잊지 말자.
    // span을 종료하면 해당 span을 수집해서 분산 추적 시스템(e.g. Zipkin)으로 전송할 수 있다.
    newSpan.end();
}
```

다음은 다른 스레드에서 시작한 span을 새로운 스레드에서 계속 이어가는 방법을 보여주는 예제다:

```java
Span spanFromThreadX = this.tracer.nextSpan().name("calculateTax");
try (Tracer.SpanInScope ws = this.tracer.withSpan(spanFromThreadX.start())) {
    executorService.submit(() -> {
        // 스레드 X에서 만든 span을 전달한다
        Span continuedSpan = spanFromThreadX;
        // ...
        // span에 태그를 추가할 수 있다
        continuedSpan.tag("taxValue", taxValue);
        // ...
        // span에 이벤트를 기록할 수 있다
        continuedSpan.event("taxCalculated");
    }).get();
}
finally {
    spanFromThreadX.end();
}
```

다음은 부모 span을 명확히 알고 있을 때 자식 span을 만드는 방법을 보여주는 예시다:

```java
// 현재 스레드는 스레드 Y이고,
// 스레드 X로부터 `initialSpan`을 전달받았다고 가정해 보자.
// `initialSpan`은 `newSpan`의 부모가 된다.
Span newSpan = this.tracer.nextSpan(initialSpan).name("calculateCommission");
// ...
// span에 태그를 추가할 수 있다
newSpan.tag("commissionValue", commissionValue);
// ...
// span에 이벤트를 기록할 수 있다
newSpan.event("commissionCalculated");
// 작업을 완료했다면 span을 종료하는 것을 잊지 말자.
// span을 종료하면 해당 span을 수집해서 Zipkin 등으로 전송할 수 있다.
// newSpan에 설정한 태그와 이벤트는 부모 span에는 존재하지 않는다.
newSpan.end();
```

---

## Micrometer Tracing Brave Setup

이번 섹션에선 Brave로 Micrometer Tracing을 세팅해본다.

다음은 Brave 컴포넌트들을 사용해 완료된 span을 Zipkin으로 전송하는 Micrometer Tracing `Tracer`를 생성하는 예시다:

```java
// [Brave 컴포넌트] SpanHandler 사용 예시.
// SpanHandler는 span을 종료할 때 호출하는 컴포넌트다.
// 여기에선 UrlConnectionSender를 사용해 지정한 위치로 Zipkin 형식의 span을 전송한다
// (<io.zipkin.reporter2:zipkin-sender-urlconnection> 의존성을 통해).
// 테스트가 목적이라면 TestSpanHandler를 사용할 수 있다.
AsyncZipkinSpanHandler spanHandler = AsyncZipkinSpanHandler
    .create(URLConnectionSender.create("http://localhost:9411/api/v2/spans"));

// [Brave 컴포넌트] CurrentTraceContext는 
// 현재 TraceContext를 조회할 수 있는 Brave 컴포넌트다.
ThreadLocalCurrentTraceContext braveCurrentTraceContext = ThreadLocalCurrentTraceContext.newBuilder()
    .addScopeDecorator(MDCScopeDecorator.get()) // Brave의 자동
                                                // MDC 설정 예시
    .build();

// [Micrometer Tracing 컴포넌트] Brave의 CurrentTraceContext를 위한 
// Micrometer Tracing wrapper
CurrentTraceContext bridgeContext = new BraveCurrentTraceContext(this.braveCurrentTraceContext);

// [Brave 컴포넌트] Tracing은 트레이서, 핸들러,
// 컨텍스트 전파 방식 등을 구성할 수 있는 루트 컴포넌트다.
Tracing tracing = Tracing.newBuilder()
    .currentTraceContext(this.braveCurrentTraceContext)
    .supportsJoin(false)
    .traceId128Bit(true)
    // Baggage가 동작하려면 전파할 필드 목록을 제공해야 한다.
    .propagationFactory(BaggagePropagation.newFactoryBuilder(B3Propagation.FACTORY)
        .add(BaggagePropagationConfig.SingleBaggageField.remote(BaggageField.create("from_span_in_scope 1")))
        .add(BaggagePropagationConfig.SingleBaggageField.remote(BaggageField.create("from_span_in_scope 2")))
        .add(BaggagePropagationConfig.SingleBaggageField.remote(BaggageField.create("from_span")))
        .build())
    .sampler(Sampler.ALWAYS_SAMPLE)
    .addSpanHandler(this.spanHandler)
    .build();


// [Brave 컴포넌트] Tracer는 span의 수명 주기를 다루는 컴포넌트다
brave.Tracer braveTracer = this.tracing.tracer();

// [Micrometer Tracing 컴포넌트] Brave의 Tracer를 위한 Micrometer Tracing wrapper
Tracer tracer = new BraveTracer(this.braveTracer, this.bridgeContext, new BraveBaggageManager());
```

---

## Micrometer Tracing OpenTelemetry Setup

이번 섹션에선 OpenTelemetry(OTel)로 Micrometer Tracing을 세팅해본다.

다음은 OTel 컴포넌트들을 사용해 완료된 span을 Zipkin으로 전송하는 Micrometer Tracing `Tracer`를 생성하는 예시다:

```java
// [OTel 컴포넌트] SpanExporter 사용 예시.
// SpanExporter는 span을 종료할 때 호출하는 컴포넌트다.
// 여기에선 UrlConnectionSender를 사용해 지정한 위치로 Zipkin 형식의 span을 전송한다
// (<io.opentelemetry:opentelemetry-exporter-zipkin>과
// <io.zipkin.reporter2:zipkin-sender-urlconnection> 의존성을 통해).
// 테스트가 목적이라면 ArrayListSpanProcessor를 사용할 수 있다.
SpanExporter spanExporter = new ZipkinSpanExporterBuilder()
    .setSender(URLConnectionSender.create("http://localhost:9411/api/v2/spans"))
    .build();

// [OTel 컴포넌트] SdkTracerProvider는 TracerProvider를 위한 SDK 구현체다
SdkTracerProvider sdkTracerProvider = SdkTracerProvider.builder()
    .setSampler(alwaysOn())
    .addSpanProcessor(BatchSpanProcessor.builder(spanExporter).build())
    .build();

// [OTel 컴포넌트] OpenTelemetry의 SDK 구현체
OpenTelemetrySdk openTelemetrySdk = OpenTelemetrySdk.builder()
    .setTracerProvider(sdkTracerProvider)
    .setPropagators(ContextPropagators.create(B3Propagator.injectingSingleHeader()))
    .build();

// [OTel 컴포넌트] Tracer는 span의 수명 주기를 다루는 컴포넌트다
io.opentelemetry.api.trace.Tracer otelTracer = openTelemetrySdk.getTracerProvider()
    .get("io.micrometer.micrometer-tracing");

// [Micrometer Tracing 컴포넌트] OTel을 위한 Micrometer Tracing wrapper
OtelCurrentTraceContext otelCurrentTraceContext = new OtelCurrentTraceContext();

// [Micrometer Tracing 컴포넌트] MDC 설정을 위한 Micrometer Tracing 리스너
Slf4JEventListener slf4JEventListener = new Slf4JEventListener();

// [Micrometer Tracing 컴포넌트] MDC에 Baggage를 설정하기 위한
// Micrometer Tracing 리스너.
// correlation 필드를 넘겨 커스텀할 수 있다 (여기에선 비어있는 리스트를 세팅하고 있다)
Slf4JBaggageEventListener slf4JBaggageEventListener = new Slf4JBaggageEventListener(Collections.emptyList());

// [Micrometer Tracing 컴포넌트] OTel의 Tracer를 위한 Micrometer Tracing wrapper.
// correlation 필드와 remote 필드를 넘겨 baggage 매니저를 커스텀하는 것을 고려해볼 수 있다
// (여기에선 비어있는 리스트를 세팅하고 있다)
OtelTracer tracer = new OtelTracer(otelTracer, otelCurrentTraceContext, event -> {
    slf4JEventListener.onEvent(event);
    slf4JBaggageEventListener.onEvent(event);
}, new OtelBaggageManager(otelCurrentTraceContext, Collections.emptyList(), Collections.emptyList()));
```

---

## Micrometer Tracing Baggage API

트레이스<sup>trace</sup>는 헤더 전파를 통해 애플리케이션을 다른 애플리케이션과 연결해준다. trace 식별자 외에 다른 프로퍼티(`Baggage`라고 부른다)들도 요청과 함께 전달할 수 있다.

다음은 Tracer API를 사용해 baggage를 생성하고 추출하는 방법을 보여주는 예시다:

```java
Span span = tracer.nextSpan().name("parent").start();

// scope에 span이 있다고 가정하면...
try (Tracer.SpanInScope ws = tracer.withSpan(span)) {

    try (BaggageInScope baggageForSpanInScopeOne = tracer.createBaggageInScope("from_span_in_scope 1",
            "value 1")) {
        then(baggageForSpanInScopeOne.get()).as("[In scope] Baggage 1").isEqualTo("value 1");
        then(tracer.getBaggage("from_span_in_scope 1").get()).as("[In scope] Baggage 1").isEqualTo("value 1");
    }

    try (BaggageInScope baggageForSpanInScopeTwo = tracer.createBaggageInScope("from_span_in_scope 2",
            "value 2");) {
        then(baggageForSpanInScopeTwo.get()).as("[In scope] Baggage 2").isEqualTo("value 2");
        then(tracer.getBaggage("from_span_in_scope 2").get()).as("[In scope] Baggage 2").isEqualTo("value 2");
    }
}

// span을 직접 다룰 수 있다고 가정하면
try (BaggageInScope baggageForExplicitSpan = tracer.createBaggageInScope(span.context(), "from_span",
        "value 3")) {
    then(baggageForExplicitSpan.get(span.context())).as("[Span passed explicitly] Baggage 3")
        .isEqualTo("value 3");
    then(tracer.getBaggage("from_span").get(span.context())).as("[Span passed explicitly] Baggage 3")
        .isEqualTo("value 3");
}

// 스코프 안에 span이 없는 경우, baggage 역시 존재하지 않는다 (최신화하더라도)
try (BaggageInScope baggageFour = tracer.createBaggageInScope("from_span_in_scope 1", "value 1");) {
    then(baggageFour.get()).as("[Out of span scope] Baggage 1").isNull();
    then(tracer.getBaggage("from_span_in_scope 1").get()).as("[Out of span scope] Baggage 1").isNull();
}
then(tracer.getBaggage("from_span_in_scope 1").get()).as("[Out of scope] Baggage 1").isNull();
then(tracer.getBaggage("from_span_in_scope 2").get()).as("[Out of scope] Baggage 2").isNull();
then(tracer.getBaggage("from_span").get()).as("[Out of scope] Baggage 3").isNull();

// Baggage는 스코프 내에서만 존재한다
then(tracer.getBaggage("from_span").get(span.context())).as("[Out of scope - with context] Baggage 3").isNull();
```

> Brave의 경우, 코드에서 사용할 baggage 필드들을 `PropagationFactory`에 세팅하는 것을 잊지 말자. 자세한 방법은 아래 예제를 참고해라:

```java
Tracing tracing = Tracing.newBuilder()
    .currentTraceContext(this.braveCurrentTraceContext)
    .supportsJoin(false)
    .traceId128Bit(true)
    // Baggage가 동작하려면 전파할 필드 목록을 제공해야 한다.
    .propagationFactory(BaggagePropagation.newFactoryBuilder(B3Propagation.FACTORY)
        .add(BaggagePropagationConfig.SingleBaggageField.remote(BaggageField.create("from_span_in_scope 1")))
        .add(BaggagePropagationConfig.SingleBaggageField.remote(BaggageField.create("from_span_in_scope 2")))
        .add(BaggagePropagationConfig.SingleBaggageField.remote(BaggageField.create("from_span")))
        .build())
    .sampler(Sampler.ALWAYS_SAMPLE)
    .addSpanHandler(this.spanHandler)
    .build();
```

---

## Aspect Oriented Programming

Micrometer Tracing에는 `@NewSpan`, `@ContinueSpan`, `@SpanTag` 어노테이션이 포함돼있다. 프레임워크에선 이 어노테이션들을 활용해, '웹 요청 엔드포인트를 서빙하는 메소드' 같은 특정 유형의 메소드나, 좀더 일반적으로는 모든 메소드에 대한 span을 생성하거나 커스텀한다.

> Micrometer의 Spring Boot 설정은, 임의의 메소드에서 이 aspect들을 인식하지 *못한다*.

Micrometer Tracing에는 AspectJ aspect가 포함돼 있다. 컴파일/로드 시점에 AspectJ 위빙을 통해 애플리케이션 내에서 활용하거나, Spring AOP 같은 다른 방식으로 AspectJ aspect를 해석하고 타겟 메소드에 프록시를 적용해주는 프레임워크 기능을 통해 활용할 수 있다. 다음은 Spring AOP 설정 샘플이다:

```java
@Configuration
public class SpanAspectConfiguration {

    @Bean
    NewSpanParser newSpanParser() {
        return new DefaultNewSpanParser();
    }

    // 자체 리졸버를 제공할 수 있다. 여기서는 noop 리졸버를 사용한다.
    @Bean
    ValueResolver valueResolver() {
        return new NoOpValueResolver();
    }

    // SpEL 리졸버 예시
    @Bean
    ValueExpressionResolver valueExpressionResolver() {
        return new SpelTagValueExpressionResolver();
    }

    @Bean
    MethodInvocationProcessor methodInvocationProcessor(NewSpanParser newSpanParser, Tracer tracer,
            BeanFactory beanFactory) {
        return new ImperativeMethodInvocationProcessor(newSpanParser, tracer, beanFactory::getBean,
                beanFactory::getBean);
    }

    @Bean
    SpanAspect spanAspect(MethodInvocationProcessor methodInvocationProcessor) {
        return new SpanAspect(methodInvocationProcessor);
    }

}

// SpEL을 사용해 @SpanTag에 있는 표현식을 리졸브하는 예시
static class SpelTagValueExpressionResolver implements ValueExpressionResolver {

    private static final Log log = LogFactory.getLog(SpelTagValueExpressionResolver.class);

    @Override
    public String resolve(String expression, Object parameter) {
        try {
            SimpleEvaluationContext context = SimpleEvaluationContext.forReadOnlyDataBinding().build();
            ExpressionParser expressionParser = new SpelExpressionParser();
            Expression expressionToEvaluate = expressionParser.parseExpression(expression);
            return expressionToEvaluate.getValue(context, parameter, String.class);
        }
        catch (Exception ex) {
            log.error("Exception occurred while tying to evaluate the SpEL expression [" + expression + "]", ex);
        }
        return parameter.toString();
    }

}
```

`SpanAspect`를 적용하면, 아래 예제에서 볼 수 있듯이, AspectJ 프록시 덕분에 임의의 메소드에 `@NewSpan`과 `@ContinueSpan`을 사용할 수 있게 된다:

```java
// Sleuth에서는 @NewSpan과 @ContinueSpan 어노테이션 역시 동작한다.
// Micrometer Tracing에서는 @Aspect의 제약으로 인해 그렇지 않다.
// 반면 @SpanTag 어노테이션은 잘 동작한다.
protected interface TestBeanInterface {

    void testMethod2();

    void testMethod3();

    void testMethod10(@SpanTag("testTag10") String param);

    void testMethod10_v2(@SpanTag("testTag10") String param);

}

// 실제 클래스 예시
protected static class TestBean implements TestBeanInterface {

    @NewSpan
    @Override
    public void testMethod2() {
    }

    @NewSpan(name = "customNameOnTestMethod3")
    @Override
    public void testMethod3() {
    }

    @ContinueSpan(log = "customTest")
    @Override
    public void testMethod10(@SpanTag("customTestTag10") String param) {

    }

    @ContinueSpan(log = "customTest")
    @Override
    public void testMethod10_v2(String param) {

    }

}

// --------------------------
// -------- 사용 예시 ---------
// --------------------------


// 새 span을 생성한다
testBean().testMethod2();
then(createdSpanViaAspect()).isEqualTo("test-method2");

// 어노테이션에 있는 이름을 사용한다
testBean().testMethod3();
then(createdSpanViaAspect()).isEqualTo("custom-name-on-test-method3");

// 이전 span을 이어간다
Span span = this.tracer.nextSpan().name("foo");
try (Tracer.SpanInScope ws = this.tracer.withSpan(span.start())) {

    // 기존 span에 태그와 이벤트를 추가한다
    testBean().testMethod10("tagValue");
    SimpleSpan continuedSpan = modifiedSpanViaAspect();
    then(continuedSpan.getName()).isEqualTo("foo");
    then(continuedSpan.getTags()).containsEntry("customTestTag10", "tagValue");
    then(continuedSpan.getEvents()).extracting("value").contains("customTest.before", "customTest.after");
}
span.end();

// 이전 span을 이어간다
span = this.tracer.nextSpan().name("foo");
try (Tracer.SpanInScope ws = this.tracer.withSpan(span.start())) {

    // 기존 span에 태그와 이벤트를 추가한다 (부모 인터페이스의 설정을 재사용해서)
    testBean().testMethod10_v2("tagValue");
    SimpleSpan continuedSpan = modifiedSpanViaAspect();
    then(continuedSpan.getName()).isEqualTo("foo");
    then(continuedSpan.getTags()).containsEntry("testTag10", "tagValue");
    then(continuedSpan.getEvents()).extracting("value").contains("customTest.before", "customTest.after");
}
span.end();
```