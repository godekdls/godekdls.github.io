---
title: Exposing Reactor metrics
category: Reactor Core
order: 9
permalink: /Reactor%20Core/exposingreactormetrics/
description: 리액터 메트릭 한글 번역
image: ./../../images/reactorcore/flux.png
lastmod: 2020-07-19T16:40:00+09:00
comments: true
originalRefName: 프로젝트 리액터 코어
originalRefLink: https://projectreactor.io/docs/core/release/reference/#metrics
---

### 목차

- [8.1. Scheduler metrics](#81-scheduler-metrics)
- [8.2. Publisher metrics](#82-publisher-metrics)
  + [8.2.1. Common tags](#821-common-tags)
  + [8.2.2. Custom tags](#822-custom-tags)

---

프로젝트 리액터는 리소스를 더 잘 활용해서 성능을 끌어 올리기 위한 라이브러리다. 그래도 시스템 성능을 제대로 이해하려면 다양한 컴포넌트를 모니터링할 수 있는 게 가장 좋다.

리액터가 기본으로 [Micrometer](https://micrometer.io/) 통합을 지원하는 이유다.

> Micrometer가 클래스 패스에 없다면 메트릭은 동작하지 않는다.

---

## 8.1. Scheduler metrics

리액터에서 동작하는 모든 비동기 연산은 [Threading and Schedulers](../reactorcorefeatures#45-threading-and-schedulers)에서 설명한 스케줄러로 추상화한다. 때문에 스케줄러를 모니터링하고, 의심되는 핵심 메트릭에 집중해서 그에 맞게 대응하는 것이 중요하다.

스케줄러 메트릭을 활성화하려면 다음 메소드를 호출해야 한다:

```java
Schedulers.enableMetrics();
```

> 스케줄러를 생성할 때 메트릭 수집을 시작한다. 이 메소드는 가능한 한 빨리 호출하는 것이 좋다.

> 스프링 부트를 사용하고 있다면, 이 코드를 `SpringApplication.run(Application.class, args)` 앞에 두는 게 좋다.

스케줄러 메트릭을 활성화했고 클래스 패스에 Micrometer가 있다면, 리액터는 Micrometer를 사용해서 스케줄러 대부분이 사용하는 executor를 추적한다.

아래 있는 메트릭 정보는 [Micrometer 문서](http://micrometer.io/docs/ref/jvm)를 참고하라:

- executor_active_threads
- executor_completed_tasks_total
- executor_pool_size_threads
- executor_queued_tasks
- executor_secounds_{count, max, sum}

스케줄러 하나에 여러 executor가 있을 수도 있기 때문에, 모든 executor 메트릭엔 `reactor_scheduler_id` 태그가 있다.

> 그라파나 + 프로메테우스 사용자는 스레드, 완료된 태스크, 태스크 큐 등의 편리한 메트릭을 제공하는 [빌트인 대시보드](https://raw.githubusercontent.com/reactor/reactor-monitoring-demo/master/dashboards/schedulers.json)를 활용할 수 있다.

---

## 8.2. Publisher metrics

리액티브 파이프라인의 특정 단계에서 메트릭을 기록하는 게 유용할 때도 있다.

한 가지 방법은 원하는 메트릭을 백엔드로 직접 푸쉬하는 것이다. 다른 방법은 `Flux`/`Mono`를 위한 리액터의 빌트인 메트릭 통합을 활용하는 것이다.

아래 파이프라인을 생각해 보자:

```java
listenToEvents()
    .doOnNext(event -> log.info("Received {}", event))
    .delayUntil(this::processEvent)
    .retry()
    .subscribe();
```

이 소스 `Flux` (`listenToEvents()`가 리턴하는)의 메트릭을 활성화하려면 이름을 지정하고 메트릭을 수집하면 된다:

```java
listenToEvents()
    .name("events") // (1)
    .metrics() // (2)
    .doOnNext(event -> log.info("Received {}", event))
    .delayUntil(this::processEvent)
    .retry()
    .subscribe();
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 이 단계의 모든 메트릭은 "events"로 식별한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> `Flux#metrics`  연산자는 메트릭 수집을 활성화하고 파이프라인 위에서 마지막으로 설정한 이름을 사용한다.</small>

이 연산자 두 개만 추가하면 이 많은 유용한 메트릭이 전부 추가된다!

| metric name              | type                | description                                                  |
| :----------------------- | :------------------ | :----------------------------------------------------------- |
| reactor.subscribed       | Counter             | 리액터 시퀀스를 구독한 횟수                                  |
| reactor.malformed.source | Counter             | 잘못된 소스로부터 받은 이벤트 수 (i.e. onComplete 다음 onNext) |
| reactor.requested        | DistributionSummary | 최소 한 번 언바운드 요청을 받기 전까지, 모든 구독자가 지정한 `Flux`에 요청을 보낸 횟수 |
| reactor.onNext.delay     | Timer               | onNext 신호 사이 지연 시간 (또는 onSubscribe와 첫 번째 onNext 사이 간격) |
| reactor.flow.duration    | Timer               | 구독 후 시퀀스 종료나 취소까지 소요된 시간. 타이머를 종료한 이벤트를 (`onComplete`, `onError`, `cancel`) 알 수 있는 상태 태그를 추가한다. |

### 8.2.1. Common tags

모든 메트릭은 다음 공통 태그를 가지고 있다:

| tag name | description                      | example  |
| :------- | :------------------------------- | :------- |
| type     | Publisher 타입                   | "Mono"   |
| flow     | 연산자로 설정한 현재 플로우 이름 | "events" |

### 8.2.2. Custom tags

리액티브 체인에 커스텀 태그를 추가할 수도 있다:

```java
listenToEvents()
    .tag("source", "kafka") // (1)
    .name("events")
    .metrics() // (2)
    .doOnNext(event -> log.info("Received {}", event))
    .delayUntil(this::processEvent)
    .retry()
    .subscribe();
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> "source"라는 커스텀 태그 값을 "kafka"로 설정한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 모든 메트릭은 위에서 다룬 공통 태그 외에 `source=kafka` 태그가 있다.</small>

"[Exposing Reactor metrics](https://projectreactor.io/docs/core/release/reference/#metrics)" [수정 제안하기](https://github.com/reactor/reactor-core/edit/master/docs/asciidoc/metrics.adoc)
