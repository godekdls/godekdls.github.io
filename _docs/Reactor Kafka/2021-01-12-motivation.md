---
title: Motivation
category: Reactor Kafka
order: 3
permalink: /Reactor%20Kafka/motivation/
description: 리액터 카프카가 주는 차별점, 기존 카프카 API와 다른 점, 그리고 언제 리액터 카프카를 사용해야 하는 지를 설명합니다.
image: ./../../images/reactor/logo.png
lastmod: 2021-01-11T15:00:00+09:00
comments: true
originalRefName: 프로젝트 리액터 카프카
originalRefLink: https://projectreactor.io/docs/kafka/1.3.1/reference/index.html#_motivation
---

### 목차

- [2.1. Functional interface for Kafka](#21-functional-interface-for-kafka)
- [2.2. Non-blocking Back-pressure](#22-non-blocking-back-pressure)
- [2.3. End-to-end Reactive Pipeline](#23-end-to-end-reactive-pipeline)
- [2.4. Comparisons with other Kafka APIs](#24-comparisons-with-other-kafka-apis)
  + [2.4.1. Kafka Producer and Consumer APIs](#241-kafka-producer-and-consumer-apis)
  + [2.4.2. Kafka Connect API](#242-kafka-connect-api)
  + [2.4.3. Kafka Streams API](#243-kafka-streams-api)

---

## 2.1. Functional interface for Kafka

리액터 카프카는 카프카용 자바 함수형 API다. 리액터 카프카 API를 사용하면, 함수형 스타일로 작성한 어플리케이션 로직에 굳이 함수형이 아닌 비동기 프로듀서/컨슈머 API를 넣을 필요 없이, 쉽게 카프카와 통신하는 코드를 통합할 수 있다.

---

## 2.2. Non-blocking Back-pressure

리액터 카프카 API는 리액터가 제공하는 논블로킹 back-pressure를 그대로 활용한다. 예를 들어, 외부 소스(HTTP 프록시 등)에서 가져온 메세지를 카프카에 발행하는 파이프라인에선, 전체 파이프라인에 쉽게 back-pressure를 적용해 in-flight 메세지 양과 메모리 사용량을 제어할 수 있다. 리액터는 유효한 메세지는 파이프라인을 통해 전달하면서도, 필요할 땐 플로우 속도를 제한해 오버플로를 방지하기 때문에, 어플리케이션 로직은 단순하게 유지할 수 있다.

---

## 2.3. End-to-end Reactive Pipeline

카프카를 포함한 다양한 외부 시스템과 상호 작용하는 어플리케이션을, 리소스를 효율적으로 활용하도록 만드는 게 리액터 카프카가 내세우는 가치다. 카프카 리액터로 end-to-end 리액티브 파이프라인을 개발하면, 논블로킹 back-pressure가 적용되며 리소스도 효율적으로 사용할 수 있다. 덕분에 많은 요청을 동시에, 효율적으로 처리할 수 있다. 프로젝트 리액터의 최적화 덕분에 오버헤드가 매우 낮은 리액티브 어플리케이션을 개발할 수 있고, 필요한 리소스도 예측할 수 있기 때문에, 지연 시간은 짧고 처리량은 높은 파이프라인을 제공할 수 있다.

---

## 2.4. Comparisons with other Kafka APIs

리액터 카프카는 기존 카프카 API를 대체하는 개념이 아니다. 그보단 이벤트 기반 리액티브 어플리케이션을 위한 전용 API를 제공한다고 봐야 한다.

### 2.4.1. Kafka Producer and Consumer APIs

블로킹 방식의 어플리케이션에선, 카프카의 프로듀서/컨슈머 API로 카프카에 메세지를 발행하고 카프카 메세지를 컨슘하면 된다. 카프카 API는 지연 시간이 짧은 효율적인 인터페이스를 제공한다.

카프카를 메세지 버스로 활용하는 어플리케이션을 함수형 스타일로 구현했다면, 기존 카프카 API를 리액터 카프카로 전환해볼만 하다.

### 2.4.2. Kafka Connect API

[카프카 커넥트](https://kafka.apache.org/documentation#connect)는 외부 시스템(DB 등)에 있는 데이터를, 하나 이상의 카프카 토픽 메세지로 마이그레이션할 수 있는 간단한 인터페이스를 제공한다. 기존 커넥터를 사용하면 별도 코드를 만들지 않아도 데이터를 마이그레이션할 수 있다.

커넥터 API를 사용하는 어플리케이션 중, 변환하려는 데이터의 외부 시스템이 리액티브 API를 지원한다면 리액터 카프카를 고려해볼 수 있다. 데이터 변환 중에 다른 I/O도 필요하다면 (예를 들어 다른 데이터베이스 데이터를 추가로 조회하는 등), 리액터로 리액티브 파이프라인을 만들면 end-to-end 논블로킹 back-pressure를 활용할 수 있다. 카프카 파티션으로 나눠진 메세지는 병렬로 주고받아 I/O 블로킹 없이 처리량을 끌어올릴 수 있다. 게다가 리액터의 pull 모델은 파이프라인을 통해 흐르는 메세지 속도를 제어한다. 덕분에 어플리케이션에서 직접 오버플로를 처리하지 않아도 스레드와 메모리를 효율적으로 사용할 수 있다.

### 2.4.3. Kafka Streams API

[카프카 스트림즈](https://kafka.apache.org/documentation#streams)는 카프카에 저장된 데이터를, 표준 스트리밍 개념과 기본 변환 인터페이스를 통해 스트림으로 처리하기 위한 API를 제공한다. 간단한 스레딩 모델을 사용하는 스트림 API는 back-pressure 없이도 충분하다. 외부와 상호 작용 없이 데이터를 변환한다면 이 모델도 문제 없이 동작한다.

리액터 카프카는 카프카 데이터 처리 중에 외부와 상호 작용(예를 들어 데이터베이스 레코드에서 데이터를 추가로 조회하는 등)하는 스트림 어플리케이션에 유용하다. 모든 외부 상호 작용에 리액티브 모델을 사용하면, 리액터는 리소스를 더 잘 활용할 뿐더러, end-to-end 논블로킹 back-pressure를 제공한다.