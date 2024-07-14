---
title: Configuring with Micrometer Observation
navTitle: Micrometer Observation Configuration
category: Micrometer Tracing
order: 7
permalink: /Micrometer%20Tracing/configuring/
description: Micrometer Tracing과 Micrometer Observation 함께 사용하기
image: ./../../images/micrometer/logo.png
lastmod: 2024-07-14T17:00:00+09:00
comments: true
originalRefName: 마이크로미터 트레이싱
originalRefLink: https://docs.micrometer.io/tracing/reference/configuring.html
originalVersion: 1.3.2
---

### 목차

- [Handler Configuration](#handler-configuration)
  + [Ordered Handler Configuration](#ordered-handler-configuration)
- [Context Propagation with Micrometer Tracing](#context-propagation-with-micrometer-tracing)
- [Exemplars](#exemplars)

---

## Handler Configuration

Micrometer Tracing을 Micrometer Observation과 함께 동작하게 만들려면, 트레이싱<sup>tracing</sup> 관련 로직이 추가된 `ObservationHandler`를 하나 추가해야 한다. 다음은 `DefaultTracingObservationHandler`를 하나 추가해서 사용하는 예시다:

```java
Tracer tracer = Tracer.NOOP; // 실제 tracer는 설정한 tracer
                             // 구현체에 따라 달라진다 (Brave / OTel)
Propagator propagator = Propagator.NOOP; // 실제 propagator는 설정한 tracer
                                         // 구현체에 따라 달라진다 (Brave / OTel)
MeterRegistry meterRegistry = new SimpleMeterRegistry();

ObservationRegistry registry = ObservationRegistry.create();
registry.observationConfig()
    // 클래스패스에 micrometer-core가 있다고 가정한다
    .observationHandler(new DefaultMeterObservationHandler(meterRegistry))
    // span을 생성하는 first matching handler를 설정한다
    // (Micrometer Tracing에 들어있다)
    // 네트워크를 통해 데이터를 송수신하기 위한 span과 디폴트 구현체를 설정한다.
    .observationHandler(new ObservationHandler.FirstMatchingCompositeObservationHandler(
            new PropagatingSenderTracingObservationHandler<>(tracer, propagator),
            new PropagatingReceiverTracingObservationHandler<>(tracer, propagator),
            new DefaultTracingObservationHandler(tracer)));

// `DefaultTracingObservationHandler`를 통해
// 새 observation이 생성되고 시작하면 새 Span을 생성하고 시작한다
Observation observation = Observation.start("my.operation", registry)
    .contextualName("This name is more readable - we can reuse it for e.g. spans")
    .lowCardinalityKeyValue("this.tag", "will end up as a meter tag and a span tag")
    .highCardinalityKeyValue("but.this.tag", "will end up as a span tag only");

// 이렇게 하면 이전에 생성한 Span을 현재 Span으로 만들 수 있다
// (ThreadLocal에 들어있다)
try (Observation.Scope scope = observation.openScope()) {
    // 측정하고 싶은 코드를 실행한다 - 여전히 현재 span이 첨부된다
    // 따라서 로깅 프레임워크 등을 사용 중이라면, MDC 트레이싱 정보 등에 주입할 수 있다.
    yourCodeToMeasure();
}
finally {
    // try-with-resources 블록을 사용했기 때문에 해당 Span은
    // 더 이상 ThreadLocal에 존재하지 않는다 (Observation.Scope는 AutoCloseable이다)
    // Observation을 중지한다
    // 해당 Span 역시 중지되고 외부 시스템에 보고된다
    observation.stop();
}
```

`observe` 메소드를 사용하면 더 적은 코드로도 원하는 로직을 측정할 수 있다:

```java
ObservationRegistry registry = ObservationRegistry.create();

Observation.createNotStarted("my.operation", registry)
    .contextualName("This name is more readable - we can reuse it for e.g. spans")
    .lowCardinalityKeyValue("this.tag", "will end up as a meter tag and a span tag")
    .highCardinalityKeyValue("but.this.tag", "will end up as a span tag only")
    .observe(this::yourCodeToMeasure);
```

그러면 다음과 같은 Micrometer Metric들이 만들어진다:

```java
Gathered the following metrics
    Meter with name <my.operation> and type <TIMER> has the following measurements
        <[
            Measurement{statistic='COUNT', value=1.0},
            Measurement{statistic='TOTAL_TIME', value=1.011949454},
            Measurement{statistic='MAX', value=1.011949454}
        ]>
        and has the following tags <[tag(this.tag=will end up as a meter tag and a span tag)]>
```

그리고 (예를 들면) Zipkin에선 다음과 같은 트레이스<sup>trace</sup> 뷰를 조회할 수 있다:

![Trace Info propagation](./../../images/micrometertracing/zipkin.jpg)

### Ordered Handler Configuration

Micrometer Tracing은 `ObservationHandler` 구현체를 여러 개 제공한다. 순서 개념을 도입하려면 `ObservationHandler.AllMatchingCompositeObservationHandler`를 사용해서 주어진 predicate를 모든 `ObservationHandler`와 매칭시켜보면 된다. predicate와 매칭되는 `ObservationHandler`를 하나만 찾아서 로직을 실행하려면, `FirstMatchingCompositeObservationHandler`를 사용해라. `ObservationHandler.AllMatchingCompositeObservationHandler`는 핸들러들을 묶어서 관리하기 좋고, `FirstMatchingCompositeObservationHandler`는 (예를 들어) 매칭되는 `TracingObservationHandler`를 하나만 실행하고 싶을 때 선택하면 된다.

---

## Context Propagation with Micrometer Tracing

Micrometer Tracing과 함께 [컨텍스트 전파<sup>Context Propagation</sup>](https://docs.micrometer.io/context-propagation/reference/)도 동작하도록 만들려면, 다음과 같이 적당한 `ThreadLocalAccessor`를 직접 등록해줘야 한다:

```java
ContextRegistry.getInstance().registerThreadLocalAccessor(new ObservationAwareSpanThreadLocalAccessor(tracer));
ContextRegistry.getInstance()
    .registerThreadLocalAccessor(new ObservationAwareBaggageThreadLocalAccessor(registry, tracer));
```

(Observation으로 관리하는 span이 아닌) 수동으로 만든 span을 전파하려면 `ObservationAwareSpanThreadLocalAccessor`가 필요하다. 사용자가 만든 baggage를 전파하려면 `ObservationAwareBaggageThreadLocalAccessor`가 필요하다.

Project Reactor를 사용 중이라면, `Observation`이나, `Span`, `BaggageToPropagate`의 값을 다음과 같이 Reactor Context에 설정해줘야 한다:

```java
// 설정 예시
ContextRegistry contextRegistry = ContextRegistry.getInstance();

ObservationAwareSpanThreadLocalAccessor accessor;

ObservationAwareBaggageThreadLocalAccessor observationAwareBaggageThreadLocalAccessor;


accessor = new ObservationAwareSpanThreadLocalAccessor(observationRegistry, getTracer());
observationAwareBaggageThreadLocalAccessor = new ObservationAwareBaggageThreadLocalAccessor(observationRegistry,
        getTracer());
contextRegistry.loadThreadLocalAccessors()
    .registerThreadLocalAccessor(accessor)
    .registerThreadLocalAccessor(observationAwareBaggageThreadLocalAccessor);
Hooks.enableAutomaticContextPropagation();

// 사용 예시
Hooks.enableAutomaticContextPropagation();
Observation observation = Observation.start("parent", observationRegistry);

List<String> hello = Mono.just("hello")
    .subscribeOn(Schedulers.single())
    .flatMap(s -> {
        Mono<List<String>> mono = Mono.defer(() -> Mono.just(Arrays.asList(
            getTracer().getBaggage("tenant").get(),
            getTracer().getBaggage("tenant2").get())
        ));
        return mono.subscribeOn(Schedulers.parallel())
            .contextWrite(ReactorBaggage.append("tenant", s + ":baggage")); // 기존 baggage에 추가한다 (tenant2:baggage2)
    })
    .contextWrite(Context.of(ObservationThreadLocalAccessor.KEY, observation, // Reactor Context에 observation을 추가한다
        ObservationAwareBaggageThreadLocalAccessor.KEY, new BaggageToPropagate("tenant2", "baggage2") // Reactor Context에 baggage를 추가한다
        ))
    .block();
```

---

## Exemplars

`DefaultMeterObservationHandler`를 사용하는 대신 [exemplar](https://grafana.com/docs/grafana/latest/fundamentals/exemplars/)에 대한 지원을 추가하려면 다음과 같이 `TracingAwareMeterObservationHandler`를 사용해야 한다:

```java
ObservationRegistry registry = ObservationRegistry.create();
registry.observationConfig()
    // DefaultMeterObservationHandler를 등록하지 않는다...
    // .observationHandler(new DefaultMeterObservationHandler(meterRegistry))
    // ...그대신 tracing aware 버전을 등록한다
    .observationHandler(new TracingAwareMeterObservationHandler<>(
            new DefaultMeterObservationHandler(meterRegistry), tracer));
```