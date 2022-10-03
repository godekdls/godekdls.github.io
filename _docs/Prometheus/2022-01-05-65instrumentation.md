---
title: Instrumentation
category: Prometheus
order: 65
permalink: /Prometheus/practices.instrumentation/
description: 코드 계측을 위한 가이드라인
image: ./../../images/prometheus/logo.png
lastmod: 2022-01-05T21:30:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/practices/instrumentation/
parent: BEST PRACTICES
parentUrl: /Prometheus/practices/
---

---

이 페이지에선 코드 계측<sup>instrument</sup>을 위한 가이드라인을 제공한다.

### 목차

- [How to instrument](#how-to-instrument)
  + [The three types of services](#the-three-types-of-services)
    * [Online-serving systems](#online-serving-systems)
    * [Offline processing](#offline-processing)
    * [Batch jobs](#batch-jobs)
  + [Subsystems](#subsystems)
    * [Libraries](#libraries)
    * [Logging](#logging)
    * [Failures](#failures)
    * [Threadpools](#threadpools)
    * [Caches](#caches)
    * [Collectors](#collectors)
- [Things to watch out for](#things-to-watch-out-for)
  + [Use labels](#use-labels)
  + [Do not overuse labels](#do-not-overuse-labels)
  + [Counter vs. gauge, summary vs. histogram](#counter-vs-gauge-summary-vs-histogram)
  + [Timestamps, not time since](#timestamps-not-time-since)
  + [Inner loops](#inner-loops)
  + [Avoid missing metrics](#avoid-missing-metrics)

---

## How to instrument

결론부터 말하자면 모든 것을 계측해라. 모든 라이브러리, 하위 시스템, 서비스는 각각이 어떻게 동작하고 있는지를 대략적으로 파악할 수 있으려면 최소한의 메트릭은 있어야 한다.

계측 코드는 계측하고자 하는 코드에 함께 넣어야 한다. 메트릭 클래스 인스턴스는 이 인스턴스를 사용하는 파일 안에서 생성해라. 이렇게 하면 에러를 추적할 때 alert에서 콘솔, 코드로 쉽게 이동할 수 있다.

### The three types of services

모니터링할 때는 서비스를 일반적으로 온라인 서비스, 오프라인 처리, 배치 job, 이렇게 세 가지 유형으로 나눌 수 있다. 세 유형 간에는 겹치는 부분도 있지만, 보통 모든 서비스들은 이 카테고리 중 하나에 잘 들어맞는 편이다.

#### Online-serving systems

온라인 서비스 시스템은 사람이나 다른 시스템에 즉각적으로 응답을 주는 시스템이다. 예를 들어, 대부분의 데이터베이스와 HTTP 요청은 이 카테고리로 분류한다.

이런 시스템에선 핵심 메트릭으로 수행한 쿼리 수나, 오류 횟수, 지연 시간을 꼽을 수 있다. 현재 진행 중인 요청 수도 유용할 거다.

쿼리에 실패한 횟수를 계산할 때는 아래 있는 [Failures](#failures) 섹션을 참고해라.

온라인 서비스 시스템은 클라이언트 사이드와 서버 사이드를 모두 모니터링해야 한다. 두 곳에서 보이는 행동이 다르다면, 이 사실마저도 디버깅에 매우 유용한 정보다. 서비스에 붙어있는 클라이언트가 많은 편이라면, 현실적으로 서비스에서 하나하나 추적하는 긴 어려우므로, 클라이언트는 자체 통계를 사용해야 한다.

쿼리를 카운팅할 땐 쿼리를 시작할 때를 기준으로 할지 종료할 때를 기준으로 할지를 명확하게 정해둬라. 추천하는 건 종료 시점이다. 에러, 지연 시간 지표와 함께 놓을 수도 있고 코드 작성도 쉬운 편이다.

#### Offline processing

오프라인 처리에선 아무도 계속해서 응답을 기다리지 않으며, 보통은 일괄로 처리한다. 처리에는 여러 단계가 있을 수도 있다.

각 단계별로 들어온 항목들, 진행 중인 항목 수, 마지막으로 처리한 시간, 발송한 항목 수를 추적해라. 일괄로 처리하는 경우 들어오고 나가는 배치들도 추적해야 한다.

시스템이 무언가를 마지막으로 처리한 시간을 알 수 있다면 시스템이 지연되고 있는지를 알아내는 데 도움이 되지만, 사실 이 정보는 매우 국한적인 정보다. 이때는 시스템을 통해 하트비트를 전송해주는 게 더 좋다: 타임스탬프를 포함하는 아무 더미 데이터를 맨 마지막 단계까지 전달해라. 각 단계에선 가장 최근에 본 하트비트 타임스탬프를 익스포트할 수 있으며, 이를 통해 항목들이 시스템을 통해 전파되는 데 걸리는 시간을 파악할 수 있다. 어떠한 처리도 하지 않는 휴지 기간이 없는 시스템이라면 하트비트가 따로 필요 없을 수도 있다.

#### Batch jobs

오프라인 처리는 배치 job으로도 수행할 수 있기 때문에, 오프라인 처리와 배치 job을 구분하는 경계는 조금 불분명한 감이 있다. 배치 job은 끊임없이 실행되지 않는다는 점으로 구분할 수 있는데, 이런 점 때문에 스크랩하기가 쉽지 않다.

배치 job의 핵심 메트릭은 마지막으로 성공한 시간이다. job을 구성하는 주요 단계별로 소요된 시간이나, 전체적인 실행 시간, 마지막으로 job을 완료한(성공 또는 실패) 시간을 추적하는 것도 유용하다. 이 지표들은 모두 게이지<sup>gauge</sup>이며, [PushGateway로 푸시](../pushing)해줘야 한다. 처리한 총 레코드 수와 같이, 일반적으로 추적하면 유용한 job 전용 통계들도 존재한다.

실행하는 데 몇 분 이상 걸리는 배치 job이라면, pull 기반 모니터링을 이용해 스크랩하는 것도 괜찮다. 데이터를 스크랩한다면 다른 유형들처럼 리소스 사용량이나 다른 시스템과 통신할 때 소요되는 대기 시간같은 메트릭들을 시간의 흐름에 따라 추적할 수 있다. job이 느려지기 시작할 때도 디버깅하기 좋을 거다.

배치 job을 매우 자주 실행한다면 (15분 간격 이하로), 데몬으로 변환하고 오프라인 처리 job으로 다루는 것도 생각해보는 게 좋다.

### Subsystems

세 가지 메인 서비스 유형 외에도, 시스템의 다른 하위 파트들도 모니터링해야 한다.

#### Libraries

라이브러리는 추가적인 설정 없이도 코드를 계측할 수 있어야 한다.

프로세스 바깥에 있는 어떤 리소스(ex. 네트워크, 디스크, IPC)에 접근하는 데 쓰는 라이브러리라면, 전체적인 쿼리 수, 에러(가능하면), 지연 시간을 최소한으로 추적해라.

라이브러리가 얼마나 무거운지에 따라, 라이브러리 자체에 있는 내부 에러와 지연 시간, 그리고 유용할 수 있다고 생각되는 범용적인 통계 지표를 수집해라.

라이브러리는 애플리케이션의 각 독립적인 파트에서 서로 다른 리소스에 사용할 수 있으므로, 적절한 곳에서 레이블로 용도를 구분할 수 있도록 신경써주는 게 좋다. 예를 들어 데이터베이스 커넥션 풀은 붙어있는 데이터베이스를 구별해야 하지만, DNS 클라이언트 라이브러리의 사용자들을 구별할 필요는 없다.

#### Logging

로그를 남기는 코드는 대체로 모든 라인마다 카운터를 증가시켜줘야 한다. 특이한 로그를 발견하면 해당 메세지가 얼마나 자주, 얼마나 오랫동안 발생했는지 확인하고 싶을 거다.

같은 함수 안에 밀접하게 연관된 로그 메세지들이 여러 개 있을 경우 (예를 들어 if 문이나 switch 문의 여러 가지 분기들), 상황에 따라 모든 메세지에서 단일 카운터를 증가시키는 게 맞을 수도 있다.

그외에도 애플리케이션이 전체적으로 기록한 info/error/warning 라인 수의 총계를 익스포트하면, 릴리즈 프로세스에서 로그 수가 크게 차이나는지도 체크해볼 수 있어 유용하다.

#### Failures

실패를 처리하는 방법도 로그와 비슷하다. 무언가가 실패했을 때마다 카운터를 증가시켜야 한다. 단, 로그와 달리 에러는 코드 구조에 따라 좀 더 일반적인 에러 카운터를 같이 증가시키기도 한다.

실패를 리포팅할 때는 보통 총 시도 횟수를 나타내는 다른 메트릭들도 필요하다. 이런 지표들을 함께 수집해주면 실패 비율을 쉽게 계산할 수 있다.

#### Threadpools

어떤 스레드 풀을 사용하던 간에, 핵심 메트릭은 큐에서 대기 중인 요청 수, 사용 중인 스레드 수, 전체 스레드 수, 처리한 태스크 수, 태스크에 소요된 시간이다. 큐에서 대기하는 시간을 추적하는 것도 유용하다.

#### Caches

캐시에서 필요한 핵심 메트릭은 총 질의 횟수, 적중<sup>hit</sup> 횟수, 전반적인 지연 시간과, 캐시 뒤에 있는 온라인 서비스 시스템을 질의한 횟수, 에러, 지연 시간이다.

#### Collectors

중요한 커스텀 메트릭 컬렉터를 구현한다면, 수집하는데 걸린 초 단위 시간과 발생한 에러 수에 대해 각각 게이지<sup>gauge</sup>를 익스포트하길 권장한다.

지속 시간<sup>duration</sup>을  summary나 히스토그램 대신 게이지로 익스포트해도 괜찮은 케이스는 두 가지가 있는데, 바로 이 케이스가 그렇고, 또 다른 하나는 배치 job의 지속 시간이다. 둘 모두 지속 시간을 시간의 흐름에 따라 여러 번 추적하는 것이 아니라, 특정한 푸시/스크랩에 대한 정보를 나타내기 때문이다.

---

## Things to watch out for

무언가를 모니터링할 때는 일반적으로 알아두면 좋은 것들이 있다. 특히 프로메테우스와 관련해서 알아둬야 하는 것들도 있다.

### Use labels

레이블이란 개념을 사용하고 레이블을 활용해서 표현식 언어를 구성하는 모니터링 시스템은 많지 않기 때문에, 레이블에 익숙해지는 데는 시간이 조금 필요하다.

여러 가지 메트릭을 서로 더하고, 평균을 구하고, 합산하고 싶어진다면, 보통 이런 지표들은 여러 메트릭보단, 레이블들을 가지고 있는 하나의 메트릭으로 다루는 게 좋다.

예를 들자면, `http_responses_500_total`과 `http_responses_403_total`로 나누는 대신, `http_responses_total`이라는 단일 메트릭을 만들고 `code` 레이블로 HTTP 응답 코드를 표현해라. 그러면 rule과 그래프에서 이 메트릭 전체를 하나로 처리할 수 있다.

경험상 메트릭명의 어떤 부분도 절차적으로<sup>procedurally</sup> 생성해서는 안 된다 (그대신 레이블을 사용해라). 다른 모니터링/계측 시스템에 있는 메트릭을 프록시해오는 경우는 예외다.

[네이밍](../practices.naming) 섹션도 함께 참고해라.

### Do not overuse labels

모든 레이블 셋마다 시계열이 하나씩 더 생기며, 여기에는 RAM, CPU, 디스크, 네트워크 비용이 들어간다. 오버헤드는 대부분 무시할 수 있는 수준이지만, 서버 수백 대에 걸쳐 메트릭을 대량으로 수집하면서 레이블 셋을 수백 개 사용한다면 오버헤드가 무섭게 늘어날 수 있다.

일반적인 가이드라인으로, 메트릭의 카디널리티는 10 미만으로 유지하고, 전체 시스템에서 소량의 메트릭만 이를 넘길 수 있는 것으로 목표로 잡아라. 메트릭 대부분에는 레이블이 없는 게 맞다.

카디널리티가 100을 넘어가거나 그만큼 커질 가능성이 있는 메트릭이 있다면, 차원<sup>dimension</sup>을 줄이거나 분석 자체를 모니터링이 아니라 범용적인 처리 시스템으로 옮기는 것 등의 대체 솔루션을 검토해봐라.

기준 숫자에 대해 감을 잡을 수 있도록 node_exporter를 예로 들어보자. node_exporter에선 마운트한 모든 파일 시스템의 메트릭을 노출한다. 모든 노드가 `node_filesystem_avail`에 시계열을 수십 개씩 저장한다고 해보자. 노드가 10,000개 있다면 `node_filesystem_avail`에 대략 100,000개의 시계열이 만들어지며, 이 정도는 프로메테우스에서 감당할 수 있는 양이다.

할당량을 계속해서 추가한다고 생각해보자. 10,000개의 노드에 10,000명의 사용자가 있다면 순식간에 천만 개 단위에 도달하게 될 거다. 천 만 단위는 현재 프로메테우스 구현체에선 지나치게 많은 숫자다. 이보다는 좀 더 적다고 해도, 이 시스템은 유용할만한 메트릭을 더이상 추가할 수 없기 때문에 기회 비용이 발생한다.

확신이 없을 땐 레이블 없이 시작하고, 시간이 지남에 따라 구체적인 유스 케이스가 생겼을 때 레이블을 추가해라.

### Counter vs. gauge, summary vs. histogram

메트릭을 수집할 땐 네 가지 메트릭 타입 중 어떤 것을 사용할지 아는 것도 중요하다.

카운터와 게이지 중 하나를 선택할 때는 간단한 법칙이 있다. 값이 내려갈 수 있다면 게이지다.

카운터는 올라가는 것만 가능하다 (참고로 프로세스 재시작 등에선 리셋할 수 있다). 카운터는 이벤트 수를 누적해서 계산하거나, 각 이벤트에서 필요한 수치를 누적할 때 활용한다. 예를 들면 총 HTTP 요청 횟수나, HTTP 요청에서 전송한 총 바이트 수가 있다. 카운터는 자체를 그대로 활용하는 일은 많지 않다. 보통은 `rate()` 함수를 이용해 초당 증가하는 비율을 계산한다.

게이지는 원하는 값으로 설정할 수도 있고, 올라가거나 내려가는 것도 가능하다. 진행 중인 요청이나, 여유 메모리/총 메모리, 온도같은 상태의 스냅샷을 남길 때 활용한다. 게이지에선 `rate()`를 계산하면 안 된다.

summary와 히스토그램 타입은 좀 더 복잡한데, [별도 섹션](../practices.histograms)에서 논의한다.

### Timestamps, not time since

어떤 일이 발생하고 나서 지난 시간을 추적하고 싶다면, 발생한 이후의 시간이 아니라 발생한 시점의 Unix 타임스탬프를 익스포트해라.

발생 시점의 타임스탬프를 익스포트하면, `time() - my_timestamp_metric` 표현식을 이용해 이벤트 이후 경과한 시간을 계산할 수 있다. 이렇게 해주면 업데이트 로직이 필요없기 때문에 업데이트 로직에 갇히게 되는 일은 없다.

### Inner loops

보통은 계측하는데 추가로 들어가는 리소스 비용보단 운영이나 개발 측면에 가져다주는 이점이 훨씬 크다.

하지만 성능에 영향을 제일 많이 받는 코드나, 프로세스 내에서 초당 100,000번 이상 호출하는 코드라면, 업데이트하는 메트릭 수에 대해 약간의 주의가 필요할 수 있다.

자바 카운터는 상황에 따라 달라질 순 있지만, 값을 증가시키는 데 [12-17ns](https://github.com/prometheus/client_java/blob/master/benchmarks/README.md)가 소요된다. 다른 언어도 비슷한 성능을 보인다. 중첩된 루프를 빠르게 실행해야 한다면, 내부 루프 안에서 증가시키는 메트릭 수를 제한하고 가능하면 레이블은 피해라 (아니면 캐시에서 레이블 조회 결과를 가져와라. ex. Go에선 `With()`, 자바에선 `labels()`가 반환하는 값).

현재 시간을 가져올 때는 시스템 호출이 발생할 수 있으므로, 시간이나 기간과 관련된 메트릭을 업데이트할 때도 주의해야 한다. 성능이 핵심인 코드에서 생기는 다른 문제들과 마찬가지로, 업데이트의 영향을 판단할 땐 벤치마크를 참고하는 게 가장 좋다.

### Avoid missing metrics

어떤 일이 발생하기 전까지는 존재하지 않는 시계열은 처리하기가 어렵다. 이런 시계열들은 평소 사용하는 간단한 연산으로 처리할 수 없기 때문이다. 따라서 앞으로 생길 것을 미리 알고 있는 시계열은 `0`과 같은 기본값을 익스포트해야 한다.

대부분의 프로메테우스 클라이언트 라이브러리는 (Go, 자바, 파이썬을 포함해서) 레이블이 없는 메트릭에 자동으로 `0`을 익스포트해줄 거다.