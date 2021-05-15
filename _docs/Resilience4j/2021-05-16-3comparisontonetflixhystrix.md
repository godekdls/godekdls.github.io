---
title: Comparison to Netflix Hystrix
category: Resilience4j
order: 3
permalink: /Resilience4j/comparison-to-netflix-hystrix/
description: resilience4j와 netflix hystrix 비교 한글 번역
image: ./../../images/resilience4j/logo.jpeg
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: resilience4j
originalRefLink: https://resilience4j.readme.io/v1.7.0/docs/comparison-to-netflix-hystrix
---

---

넷플릭스 히스트릭스와 다른점 몇 가지를 요약하자면:

- 히스트릭스에선 외부 시스템을 호출하려면 HystrixCommand로 감싸야 한다. 이와 달리 resilience4j는 Circuit Breaker나 Rate Limiter, Bulkhead를 사용해 모든 함수형 인터페이스나, 람다 표현식, 메소드 참조를 한 단계 더 진전시키는 고차 함수(데코레이터)를 제공한다. 게다가 resilience4j는 실패한 호출을 재시도하거나 호출 결과를 캐시할 수 있는 데코레이터도 제공한다. 함수형 인터페이스나, 람다 표현식, 메소드 참조에는 데코레이터를 둘 이상 포갤 수도 있다. 다시 말해 Bulkhead와, RateLimiter, Retry 데코레이터를 CircuitBreaker 데코레이터와 결합할 수 있다. 덕분에 필요한 데코레이터만 직접 선택할 수 있다. 데코레이터를 적용한 함수는 모두 동기 방식으로 실행할 수 있으며, CompletableFuture나 RxJava를 사용해 비동기로 실행할 수도 있다.
- 너무 많은 호출이 응답 시간 임계치를 초과하면 CircuitBreaker를 열 수 있다. 아직 원격 시스템에서 응답이 없어 예외가 발생하기 전에도 말이다.
- 히스트릭스는 half-open 상태에선 호출을 딱 한 번만 수행해보고 CircuitBreaker를 닫을 지를 결정한다. resilience4j를 사용하면 설정한 횟수만큼 실행한 뒤 그 결과를 설정한 임계치과 비교해서 CircuitBreaker를 닫을 지를 결정할 수 있다.
- resilience4j는 모든 리액티브 타입을 Circuit Breaker나, Bulkhead, Ratelimiter로 데코레이팅할 수 있는 커스텀 Reactor, RxJava 연산자를 제공한다.
- 히스트릭스와 resilience4j는 이벤트 스트림을 방출해서 시스템 운영자가 실행 결과와 지연 시간에 관한 메트릭을 모니터링하기 좋다.