---
title: Getting Started
category: Apache Kafka
order: 2
permalink: /Apache%20Kafka/getting-started/
description: 카프카에 대한 기본적인 소개, 사용 사례, 퀵스타트 가이드
image: ./../../images/kafka/streams-and-tables-p1_p4.png
lastmod: 2021-02-14T22:25:00+09:00
comments: true
originalRefName: 아파치 카프카
originalRefLink: https://kafka.apache.org/27/documentation.html#gettingStarted
---

### 목차

- [1.1 Introduction](#11-introduction)
  + [What is event streaming?](#what-is-event-streaming)
  + [What can I use event streaming for?](#what-can-i-use-event-streaming-for)
  + [Apache Kafka® is an event streaming platform. What does that mean?](#apache-kafka-is-an-event-streaming-platform-what-does-that-mean)
  + [How does Kafka work in a nutshell?](#how-does-kafka-work-in-a-nutshell)
  + [Main Concepts and Terminology](#main-concepts-and-terminology)
  + [Kafka APIs](#kafka-apis)
  + [Where to go from here](#where-to-go-from-here)
- [1.2 Use Cases](#12-use-cases)
  + [Messaging](#messaging)
  + [Website Activity Tracking](#website-activity-tracking)
  + [Metrics](#metrics)
  + [Log Aggregation](#log-aggregation)
  + [Stream Processing](#stream-processing)
  + [Event Sourcing](#event-sourcing)
  + [Commit Log](#commit-log)
- [1.3 Quick Start](#13-quick-start)
  + [STEP 1: GET KAFKA](#step-1-get-kafka)
  + [STEP 2: START THE KAFKA ENVIRONMENT](#step-2-start-the-kafka-environment)
  + [STEP 3: CREATE A TOPIC TO STORE YOUR EVENTS](#step-3-create-a-topic-to-store-your-events)
  + [STEP 4: WRITE SOME EVENTS INTO THE TOPIC](#step-4-write-some-events-into-the-topic)
  + [STEP 5: READ THE EVENTS](#step-5-read-the-events)
  + [STEP 6: IMPORT/EXPORT YOUR DATA AS STREAMS OF EVENTS WITH KAFKA CONNECT](#step-6-importexport-your-data-as-streams-of-events-with-kafka-connect)
  + [STEP 7: PROCESS YOUR EVENTS WITH KAFKA STREAMS](#step-7-process-your-events-with-kafka-streams)
  + [STEP 8: TERMINATE THE KAFKA ENVIRONMENT](#step-8-terminate-the-kafka-environment)
  + [CONGRATULATIONS!](#congratulations)
- [1.4 Ecosystem](#14-ecosystem)

---

## 1.1 Introduction

### What is event streaming?

이벤트 스트리밍은 인체로 치면 중추 신경계에 해당한다. 비즈니스를 점점 소프트웨어로 정의해 자동화하고, 그 사용자마저 소프트웨어인 경우가 많은 'always-on' 세계의 기술적인 근간이다.

기술적으로 말하면, 이벤트 스트리밍은 데이터베이스, 센서, 모바일 기기, 클라우드 서비스, 소프트웨어 어플리케이션같은 이벤트 소스에서 데이터를 실시간으로 이벤트 스트림 형식으로 잡아내는 관행이다. 이런 이벤트 스트림은 나중에 조회해갈 수 있게 안전한 곳에 저장하고, 실시간 이벤트 스트림에 즉시 반응하거나 모아서 처리할 수도 있다. 필요에 따라 이벤트 스트림을 다른 기술로 라우팅하기도 한다. 이벤트 스트리밍은 이처럼 데이터의 지속적인 플로우를 이어주며, 덕분에 데이터를 끊김 없이 해석해 적시에 적절한 정보를 적절한 장소에 제공할 수 있다.

### What can I use event streaming for?

이벤트 스트리밍은 수 많은 산업과 조직에 걸쳐 [매우 폭 넓은 사례](https://kafka.apache.org/powered-by)에 활용되고 있다.

- 증권 거래소, 은행, 보험 등에서 실시간 지불 처리와 기타 금융 거래 처리.
- 물류, 자동차 산업 등에서 자동차, 트럭, 차량, 화물을 실시간으로 추적하고 모니터링.
- 공장, 풍력 단지 등에서 IoT 기기나 기타 장비의 센서 데이터를 지속적으로 수집하고 분석.
- 소매, 호텔 및 여행 산업, 모바일 어플리케이션 등에서 고객 상호 작용과 주문 이벤트를 수집하고 즉각 대응.
- 병원 진료 중 환자를 모니터링하고 상태 변화를 예측해 응급 상황 발생 시 적시에 치료.
- 사내 여러 부서에서 생산한 데이터를 연결, 저장하고, 사용 가능하도록 구성.
- 데이터 플랫폼, 이벤트 기반 아키텍처, 마이크로 서비스의 기초 토대로 활용.

### Apache Kafka® is an event streaming platform. What does that mean?

카프카는 세 가지 핵심 기능을 갖추고 있기 때문에, 현장에서 검증된 단일 솔루션을 통해 [원하는 사례](https://kafka.apache.org/powered-by)를 이벤트 스트리밍 end-to-end로 구현할 수 있다:

1. 이벤트 스트림을 **발행**(write)하고 **구독**(read)하며, 다른 시스템에 있는 데이터를 끊임 없이 import/export할 수 있다.
2. 이벤트 스트림을 원하는 기간 동안 안전하고 신뢰할 수 있는 곳에 **저장**한다.
3. 이벤트 발생 즉시 스트림을 **처리**하거나 모아서 처리한다.

게다가 이 모든 기능은 분산 서비스가 가능하고, 확장성 또한 뛰어나며, 탄력적이고 내결함성이 있는 안전한 방식으로 제공된다. 카프카는 베어 메탈 하드웨어, 가상 머신, 컨테이너에 배포할 수 있으며, 클라우드나 온 프레미스 환경에도 배포할 수 있다. 카프카 환경을 직접 관리해도 되고, 다양한 벤더가 제공하는 완전 관리형 서비스를 사용해도 좋다.

### How does Kafka work in a nutshell?

카프카는 고성능 [TCP 네트워크 프로토콜](https://kafka.apache.org/protocol.html)로 통신하는 **서버**와 **클라이언트**로 구성된 분산 시스템이다. 카프카는 베어 메탈 하드웨어, 가상 머신, 컨테이너에 배포할 수 있으며, 클라우드나 온 프레미스 환경에도 배포할 수 있다.

**서버**: 카프카는 서버 하나 이상을 가진 클러스터로 실행하며, 각 서버는 여러 데이터센터나 클라우드 지역에 걸쳐있을 수 있다. 일부 서버는 브로커라고 일컫는 스토리지 레이어를 구성한다. 또 다른 서버는 [카프카 커넥트](../kafka-connect)를 실행해 데이터를 끊임 없이 이벤트 스트림으로 import/export하는 식으로, 카프카를 다른 카프카 클러스터나 관계형 데이터베이스 등의 기존 시스템과 통합한다. 서비스 운영에 필수적인 유스 케이스를 구현할 수 있도록 카프카 클러스터는 뛰어난 확장성과 내결함성을 제공한다: 서버 중 하나에 장애가 발생하면 다른 서버에서 이어받아, 데이터 유실 없이 지속적인 운영을 보장한다.

**클라이언트**: 카프카 클라이언트로는 네트워크 문제나 장비 장애가 발생하더라도 내결함성을 유지하면서, 대규모 이벤트 스트림을 읽고, 쓰고, 처리하는 분산 어플리케이션과 마이크로 서비스를 만들 수 있다. 카프카는 카프카 커뮤니티에서 제공하는 [수십 개의 클라이언트](https://cwiki.apache.org/confluence/display/KAFKA/Clients)로 보강한, 몇 가지 클라이언트를 함께 제공한다. 클라이언트는 자바, 스칼라에서 사용할 수 있으며, REST API나 Go, 파이썬, C/C ++ 등 다양한 프로그래밍 언어 용 고수준 [카프카 스트림즈](https://kafka.apache.org/documentation/streams/) 라이브러리도 함께 제공한다.

### Main Concepts and Terminology

**이벤트**는 이벤트는 세계에서나 비즈니스 환경에서 "무언가가 발생했다"는 사실을 기록한다. 이 문서에서는 레코드 혹은 메세지라고도 부른다. 카프카에서 데이터를 읽거나 쓸 땐 이벤트 형식으로 진행하게 된다. 개념적으로 이벤트는 키, 값, 타임스탬프를 가지고 있으며, 옵션으로 메타데이터 헤더도 있을 수 있다. 다음은 이벤트의 예시다:

- 이벤트 키: "Alice"
- 이벤트 값: "Made a payment of $200 to Bob"
- 이벤트 타임스탬프: "Jun. 25, 2020 at 2:06 p.m."

**프로듀서**는 카프카에 이벤트를 발행(write)하는 클라이언트 어플리케이션을 뜻하며, **컨슈머**는 이 이벤트를 구독(read and process)하는 어플리케이션을 뜻한다. 카프카에서 프로듀서와 컨슈머는 완전히 분리되어 있으며, 각자는 서로의 세부 구현을 알 필요 없이 독립적으로 동작한다. 프로듀서와 컨슈머를 분리한 것은 카프카에서 잘 알려진 높은 확장성을 달성해준 핵심 설계 요소다. 예를 들어 프로듀서는 컨슈머를 기다려야 할 필요가 전혀 없다. 카프카는 이벤트를 정확히 한 번만 처리하는 등의 여러 가지 시맨틱스를 보장한다.

이벤트는 **토픽**으로 구성돼 안전하게 저장된다. 매우 단순하게 설명하면, 토픽은 파일 시스템의 폴더와 유사하며, 이벤트는 이 폴더 안에 있는 파일이라고 볼 수 있다. 예제 토픽 이름은 "payments"가 될 수 있다. 카프카의 토픽은 언제나 멀티 프로듀서와 멀티 컨슈머가 접근할 수 있다: 단일 토픽에 이벤트를 작성하는 프로듀서가 0, 1, 또는 그 이상 있을 수 있으며, 이 이벤트를 구독하는 컨슈머도 0, 1, 또는 그 이상일 수 있다. 토픽의 이벤트는 필요한 만큼 재차 읽어갈 수 있다 — 기존 메세징 시스템과 달리 이벤트를 컨슘한 후 삭제하지 않는다. 대신 토픽별 설정으로 카프카가 이벤트를 보존할 기간을 정의하고, 오래된 이벤트를 폐기한다. 사실상 카프카의 성능은 데이터 크기가 크더라도 일정하므로 장기간 데이터를 저장해도 전혀 문제 없다.

토픽은 **파티셔닝**된다. 즉, 토픽은 서로 다른 카프카 브로커에 있는 여러 "버킷"으로 분산된다. 이렇게 데이터를 분산해 저장하는 것은 확장성을 위해서다. 덕분에 클라이언트 어플리케이션은 동시에 여러 브로커에서 데이터를 읽고 쓸 수 있다. 토픽에 새 이벤트를 발행하면 실제로는 토픽의 파티션 중 하나에 추가된다. 이벤트 키(고객 ID나 차량 ID 등)가 동일한 이벤트는 같은 파티션에 기록되며, 카프카에선 하나의 토픽-파티션을 컨슘하는 모든 컨슈머는 항상 기록한 순서와 정확히 같은 순서로 해당 파티션 이벤트를 읽어간다는 걸 보장한다.

![streams-and-tables-p1_p4](../../images/kafka/streams-and-tables-p1_p4.png)

*Figure: 이 예제 토픽엔 4개의 파티션 P1–P4가 있다. 서로 다른 두 프로듀서 클라이언트가 네트워크를 통해 이 토픽의 파티션에 이벤트를 작성해, 독립적으로 토픽에 이벤트를 발행한다. 키가 동일한 (이 이미지에선 색상으로 표기) 이벤트는 같은 파티션에 기록된다. 따라서 두 프로듀서가 같은 파티션에 쓸 수도 있다.*

내결함성, 고가용성 있는 데이터를 만들기 위해 모든 토픽은 **복제**할 수 있으며, 지리적으로나 분산시키거나 데이터센터에 걸쳐서도 가능하다. 따라서 혹시 모를 문제를 대비하거나 브로커 유지 관리 등을 위해, 항상 데이터 복제본을 가진 멀티 브로커가 존재하게 된다. 보통 프로덕션 환경에선 replication factor를 3으로 설정한다. 이렇게 하면 항상 데이터 복제본이 3개 존재하게 된다. 데이터 복제는 토픽-파티션 레벨에서 이루어진다.

이 기본 지침으로도 소개는 충분히 됐을 거다. 이 문서의 [설계](../design) 섹션에선 카프카의 다양한 개념들을 자세히 설명하므로, 관심있다면 살펴보도록 해라.

### Kafka APIs

카프카는 몇 가지 관리 작업과 어드민 성 작업을 위한 커맨드라인 툴 외에도, 자바와 스칼라를 위한 핵심 API 다섯 가지를 제공한다:

- 토픽, 브로커나, 다른 카프카 오브젝트를 관리하고 점검할 수 있는 [어드민 API](../apis#25-admin-api).
- 하나 이상의 카프카 토픽에 이벤트 스트림을 발행(write)할 수 있는 [프로듀서 API](../apis#21-producer-api).
- 하나 이상의 토픽을 구독하고 해당 토픽에 생성한 이벤트 스트림을 처리할 수 있는 [컨슈머 API](../apis#22-consumer-api).
- 스트림 처리 어플리케이션과 마이크로 서비스를 구현할 수 있는 [카프카 스트림즈 API](https://kafka.apache.org/documentation/streams). 카프카 스트림즈 API는 데이터 변환이나, 집계나 조인같은 stateful 연산, windowing, 이벤트 시간 기반 처리 등, 이벤트 스트림을 처리하는 고급 기능을 제공한다. 하나 이상의 토픽에서 읽은 데이터를 입력으로 받아, 하나 이상의 토픽에 쓸 출력을 만들 수 있다. 즉, 입력 스트림을 출력 스트림으로 효과적으로 변환한다.
- 재사용 가능한 데이터 import/export 커넥터를 만들고 실행할 수 있는 [카프카 커넥터 API](../kafka-connect). 커넥터는 외부 시스템과 어플리케이션 간의 이벤트 스트림을 컨슘(read)하고 생산(write)할 수 있기 때문에, 외부 시스템을 카프카와 통합할 수 있다. 예를 들어 PostgreSQL같은 관계형 데이터베이스를 연결해주는 커넥터로는, 테이블 셋에 생기는 모든 변경 사항을 잡아낼 수 있다. 물론, 카프카 커뮤니티에는 즉시 사용할 수 있는 커넥터가 이미 수백 개 가량 준비돼 때문에, 실제로 자체 커넥터를 구현할 일은 거의 없다.

### Where to go from here

- 카프카를 직접 다뤄보려면 [Quickstart](https://kafka.apache.org/quickstart)를 따라해봐라.
- 카프카를 자세히 이해하고 싶다면 이 [문서](../contents)를 읽어봐라. [카프카 관련 책이나 학술 문서](https://kafka.apache.org/books-and-papers)를 참고해도 좋다.
- 전 세계 커뮤니티에서 어떻게 카프카를 활용하고 있는지 알고 싶다면 [유스 케이스](https://kafka.apache.org/powered-by)를 둘러봐라.
- [현지 카프카 밋업 그룹](https://kafka.apache.org/events)에 참여하고, 카프카 커뮤니티의 메인 컨퍼런스, [카프카 서밋의 강연](https://kafka-summit.org/past-events/)을 들어봐라.

---

## 1.2 Use Cases

여기서는 아파치 카프카®의 대표적인 유스 케이스를 몇 가지 설명한다. 각 도메인에 대한 개요는 [이 블로그 게시글](https://engineering.linkedin.com/distributed-systems/log-what-every-software-engineer-should-know-about-real-time-datas-unifying/)을 참고해라.

### Messaging

카프카는 다른 전통적인 메세지 브로커를 대체할 수 있다. 메세지 브로커는 다양한 목적으로 활용한다 (데이터 처리 로직을 프로듀서와 분리하거나, 처리되지 않은 메세지를 버퍼에 담는 등). 카프카를 다른 메세징 시스템과 비교해보면, 보통 더 나은 처리량을 보여주고, 파티셔닝 기능이 내장돼 있으며, 복제와 내결함성을 제공하므로 대규모 메세지 처리 어플리케이션의 솔루션으로 적합하다.

경험상 메세징 시스템은 비교적 처리량이 낮더라도, 보통 end-to-end 지연 시간이 짧아야 하며, 카프카가 보장하는 강력한 내구성이 필요하곤 하다.

이 도메인에서 카프카 역할은 [ActiveMQ](http://activemq.apache.org/)나 [RabbitMQ](https://www.rabbitmq.com/)같은 전통적인 메세징 시스템과 유사하다.

### Website Activity Tracking

원래 카프카의 유스 케이스는 사용자의 활동을 추적하는 파이프라인을, 실시간 publish-subscribe 피드 셋으로 재구성하는 것이었다. 다시 말해, 사이트 활동(페이지 조회, 검색 등 사용자가 취할 수 있는 활동)은 활동 타입마다 그에 해당하는 하나의 중앙 토픽으로 발행된다. 실시간 처리, 실시간 모니터링, 오프라인 처리와 보고를 위해 하둡이나 다른 오프라인 데이터 웨어하우스 시스템에 로드하는 등 다양한 유스 케이스에 따라 이 피드를 구독할 수 있다.

각 사용자가 페이지를 조회할 때마다 방대한 활동 메세지가 만들어지기 때문에, 사용자 활동을 추적할 땐 보통 대용량 데이터를 생성하게 된다.

### Metrics

카프카는 운영 모니터링 데이터에서도 자주 활용한다. 여기에는 분산 어플리케이션의 통계 데이터를 집계해, 운영 데이터의 중앙 집중식 피드를 구성하는 것도 포함된다.

### Log Aggregation

많은 곳에서 로그 집계 솔루션 대신 카프카를 사용하고 있다. 로그 집계는 보통 서버에서 물리적인 로그 파일을 수집해서, 향후에 로그를 처리할 수 있게 중앙 저장소(파일 서버나 HDFS)에 저장하는 것을 말한다. 카프카는 파일의 상세 정보를 추상화하며, 로그나 이벤트 데이터를 메세지 스트림으로 더 깔끔하게 추상화해준다. 이를 통해 처리 지연 시간을 줄일 수 있으며, 더 쉽게 멀티 데이터 소스와 분산 데이터 컨슈밍을 지원할 수 있다. 카프카를 Scribe나 Flume같은 로그 중심 시스템과 비교해보면, 똑같이 좋은 성능을 보여주며, 복제로 인한 더 강력한 내구성과, 훨씬 낮은 end-to-end 지연 시간을 제공한다.

### Stream Processing

많은 사용자들이 카프카 토픽에서 원본 입력 데이터를 컨슘해, 새 토픽으로 집계, 보강, 변환해서 추가 컨슈밍이나 후속 처리를 진행하는 멀티 스텝으로 구성된 파이프라인으로 데이터를 처리하고 있다. 예를 들어, 뉴스 기사 추천을 위한 처리 파이프라인은 RSS 피드에서 기사 컨텐츠를 크롤링해 "articles" 토픽에 발행할 수 있다. 후속 처리 단계에선 이 컨텐츠를 정규화하거나 중복을 제거해 정리된 기사 컨텐츠를 새 토픽에 발행할 수 있다. 최종 처리 단계에선 이 컨텐츠를 사용자에게 추천하는 식으로 말이다. 이런 데이터 처리 파이프라인은 각 토픽을 기반으로 실시간 데이터 플로우 그래프를 생성한다. 0.10.0.0부터 아파치 카프카는 [카프카 스트림즈](https://kafka.apache.org/documentation/streams)라는 가볍지만 강력한 스트림 처리 라이브러리를 제공하므로 앞에서 설명한 방식대로 데이터를 처리할 수 있다. 카프카 스트림즈 외에도 이를 대체할 수 있는 오픈 소스 스트림 처리 툴로는 [Apache Storm](https://storm.apache.org/), [Apache Samza](http://samza.apache.org/)가 있다.

### Event Sourcing

[이벤트 소싱](http://martinfowler.com/eaaDev/EventSourcing.html)은 상태 변경을 시간 순서에 따라 레코드 시퀀스로 기록하는 어플리케이션 설계 방식이다. 카프카엔 매우 큰 로그 데이터도 저장할 수 있기 때문에, 이벤트 소싱 스타일로 구축한 어플리케이션에 사용하기에 딱 들어맞는 백엔드 시스템이다.

### Commit Log

카프카는 분산 시스템에서 외부 로그를 커밋하는 용도로 사용할 수 있다. 로그는 노드 간에 데이터를 복제하는 데 활용할 수 있으며, 실패한 노드가 데이터를 복구할 수 있도록 재 동기화 메커니즘 역할을 수행해준다. 카프카의 [로그 컴팩션](../design#48-log-compaction) 기능도 유용하다. 이 유스 케이스에서 카프카는 [Apache BookKeeper](https://bookkeeper.apache.org/) 프로젝트와 유사하다.

---

## 1.3 Quick Start

### STEP 1: GET KAFKA

최신 카프카 릴리즈를 [다운로드](https://www.apache.org/dyn/closer.cgi?path=/kafka/2.7.0/kafka_2.13-2.7.0.tgz) 받고 압축을 풀어라:

```bash
$ tar -xzf kafka_2.13-2.7.0.tgz
$ cd kafka_2.13-2.7.0
```

### STEP 2: START THE KAFKA ENVIRONMENT

주의: 로컬 환경에 자바 8+ 이상이 설치돼 있어야 한다.

아래 명령어들을 따라해 전체 서비스를 올바른 순서대로 시작해라:

```bash
# Start the ZooKeeper service
# Note: Soon, ZooKeeper will no longer be required by Apache Kafka.
$ bin/zookeeper-server-start.sh config/zookeeper.properties
```

터미널 세션을 또 하나 열어서 다음을 실행해라:

```bash
# Start the Kafka broker service
$ bin/kafka-server-start.sh config/server.properties
```

모든 서비스를 성공적으로 기동시켰다면, 카프카 기본 환경과 사용 준비를 마친 거다.

### STEP 3: CREATE A TOPIC TO STORE YOUR EVENTS

카프카는 여러 시스템에 걸쳐 [*이벤트*](../implementation#52-messages)(이 문서에선 *레코드* 또는 *메세지*라고도 하는)를 읽고, 쓰고, 저장하고, 처리할 수 있는 분산 *이벤트 스트리밍 플랫폼*이다.

이벤트의 예를 들면 지급 거래, 휴대폰의 위치 정보 업데이트, 주문 배송, IoT 장치나 의료 장비 센서의 데이터 측정 등이 있다. 이런 이벤트는 토픽 안에 구성되고 저장된다. 매우 간단하게 말하면, 토픽은 파일 시스템의 폴더와 유사하며, 이벤트는 폴더 안에 들어있는 파일이라고 할 수 있다.

따라서 이벤트를 작성하려면 먼저 토픽을 하나 만들어야 한다. 터미널 세션을 또 하나 열어 다음을 실행해라:

```bash
$ bin/kafka-topics.sh --create --topic quickstart-events --bootstrap-server localhost:9092
```

카프카의 모든 커맨드라인 툴은 별도의 옵션을 가지고 있다: 예를 들어, 아무 인자 없이 `kafka-topics.sh` 명령어를 실행하면 사용 정보를 출력해준다. 같은 명령어로 새 토픽의 파티션 카운트같은 세부 정보도 확인할 수 있다:

```bash
$ bin/kafka-topics.sh --describe --topic quickstart-events --bootstrap-server localhost:9092
Topic:quickstart-events  PartitionCount:1    ReplicationFactor:1 Configs:
    Topic: quickstart-events Partition: 0    Leader: 0   Replicas: 0 Isr: 0
```

### STEP 4: WRITE SOME EVENTS INTO THE TOPIC

카프카 클라이언트는 이벤트 쓰기(또는 읽기)를 위해 네트워크를 통해 카프카 브로커와 통신한다. 브로커는 일단 이벤트를 받으면 필요한 기간 동안 내구성 있고 내결함성 있는 방식으로 이벤트를 저장하며, 영구적으로 저장하는 것도 가능하다.

콘솔 프로듀서 클라이언트를 실행해서 토픽에 몇 가지 이벤트를 작성해보자. 기본적으로 라인을 입력할 때마다 토픽에 별도의 이벤트로 작성된다.

```bash
$ bin/kafka-console-producer.sh --topic quickstart-events --bootstrap-server localhost:9092
This is my first event
This is my second event
```

프로듀서 클라이언트는 언제든지 `Ctrl-C`로 중지할 수 있다.

### STEP 5: READ THE EVENTS

터미널 세션을 하나 더 열어서, 콘솔 컨슈머 클라이언트를 실행해 방금 만든 이벤트를 읽어보자:

```bash
$ bin/kafka-console-consumer.sh --topic quickstart-events --from-beginning --bootstrap-server localhost:9092
This is my first event
This is my second event
```

컨슈머 클라이언트는 언제든지 `Ctrl-C`로 중지할 수 있다.

원하는 대로 자유롭게 실험해봐라: 예를 들어, 프로듀서 터미널(이전 스텝)로 다시 돌아가서 다른 이벤트를 작성하고, 컨슈머 터미널에서 이 이벤트가 어떻게 곧바로 나타나는지 확인해봐라.

이벤트는 카프카에 지속적으로 저장되기 때문에, 필요한 만큼의 컨슈머로, 원하는 횟수만큼 읽어갈 수 있다. 터미널 세션을 별도로 열어 이전 명령어를 다시 실행해보면 쉽게 확인할 수 있다.

### STEP 6: IMPORT/EXPORT YOUR DATA AS STREAMS OF EVENTS WITH KAFKA CONNECT

관계형 데이터베이스나 전통적인 메세징 시스템같은 기존 시스템에 데이터가 많다면, 이미 다수의 어플리케이션에서 이 시스템을 사용하고 있을 수도 있다. [카프카 커넥트](../kafka-connect)를 사용하면 외부 시스템 데이터를 카프카로 끊임 없이 수집할 수 있으며 그 반대도 마찬가지다. 이 덕분에 매우 쉽게 기존 시스템을 카프카와 통합할 수 있다. 손쉽게 사용할 수 있는 커넥터가 수백 개에 달하기 때문에, 통합 프로세스는 더욱 쉬워진다.

[카프카 커넥트 섹션](../kafka-connect)을 살펴보고 데이터를 지속적으로 카프카로 import/export하는 방법에 대해 자세히 알아봐라.

### STEP 7: PROCESS YOUR EVENTS WITH KAFKA STREAMS

데이터를 카프카에 이벤트로 저장하고 나면, 자바/스칼라 용 [카프카 스트림즈](https://kafka.apache.org/documentation/streams) 클라이언트 라이브러리를 사용해 데이터를 처리할 수 있다. 이렇게 하면 입출력 데이터를 카프카 토픽에 저장하는, 서비스 운영에 필수적인 실시간 어플리케이션과 마이크로 서비스를 구현할 수 있다. 카프카 스트림즈는 카프카의 서버 사이드 클러스터 기술에, 표준 자바/스칼라 클라이언트 사이드 어플리케이션을 작성하고 배포하는 단순성을 더해, 스트리밍 어플리케이션의 확장성과, 탄력성, 내결함성, 분산성을 높여준다. 카프카 스트림즈 라이브러리는 exactly-once 처리, stateful 연산 및 집계, windowing, 조인, 이벤트 시간 기반 처리 등을 지원한다.

카프카 스트림즈를 처음 접하는 사람들을 위해, 여기서는 많이 사용하는 `WordCount` 알고리즘 구현 방법을 보여주겠다:

```java
KStream<String, String> textLines = builder.stream("quickstart-events");

KTable<String, Long> wordCounts = textLines
            .flatMapValues(line -> Arrays.asList(line.toLowerCase().split(" ")))
            .groupBy((keyIgnored, word) -> word)
            .count();

wordCounts.toStream().to("output-topic"), Produced.with(Serdes.String(), Serdes.Long()));
```

[카프카 스트림즈 데모](https://kafka.apache.org/25/documentation/streams/quickstart)와 [앱 개발 튜토리얼](https://kafka.apache.org/25/documentation/streams/tutorial)에선 스트리밍 어플리케이션을 만들고 실행하는 모든 절차를 안내하고 있다.

### STEP 8: TERMINATE THE KAFKA ENVIRONMENT

여기까지 퀵스타트는 모두 마쳤다. 카프카 환경을 다시 없애도 좋고, 계속 해서 여러 가지 기능을 테스트해봐도 좋다.

1. 프로듀서와 컨슈머 클라이언트를 중단하지 않았다면 `Ctrl-C`로 중지해라.
2. 카프카 브로커를 `Ctrl-C`로 중지해라.
3. 마지막으로 `Ctrl-C`로 주키퍼를 중단해라.

앞에서 생성한 이벤트 등 로컬 카프카 환경에 있는 모든 데이터도 삭제하고 싶다면 다음 명령어를 실행해라:

```bash
$ rm -rf /tmp/kafka-logs /tmp/zookeeper
```

### CONGRATULATIONS!

아파치 카프카 퀵스타트를 모두 성공적으로 마쳤다.

계속해서 카프카를 알아보려면:

- 간략한 [소개글](https://kafka.apache.org/intro)을 읽고 카프카가 고수준에서 작동하는 방식이나, 주요 개념을 익히고, 다른 기술과는 어떻게 비교되는지 알아봐라. 카프카를 더 자세히 이해하려면 [이 문서](../contents)를 더 읽어봐라.
- 전 세계 커뮤니티에 있는 사용자가 어떻게 카프카를 활용하고 있는지 알고 싶다면 [유스 케이스](https://kafka.apache.org/powered-by)를 둘러봐라.
- [현지 카프카 밋업 그룹](https://kafka.apache.org/events)에 참여하고, 카프카 커뮤니티의 메인 컨퍼런스, [카프카 서밋의 강연](https://kafka-summit.org/past-events/)을 들어봐라.

---

## 1.4 Ecosystem

메인 배포판 외에도, 카프카와 통합할 수 있는 도구는 무수히 많다. [에코시스템 페이지](https://cwiki.apache.org/confluence/display/KAFKA/Ecosystem)엔 스트림 처리 시스템, 하둡 통합, 모니터링, 배포 도구를 비롯한 많은 툴이 정리돼 있다.
