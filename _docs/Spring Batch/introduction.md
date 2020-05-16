---
title: Spring Batch Introduction
category: Spring Batch
order: 2
---

### 목차

- [1.1 Background](#11-background)
- [1.2. Usage Scenarios](#12-usage-scenarios)
- [1.3. Spring Batch Architecture](#13-Spring-batch-architecture)
- [1.4. General Batch Piplelines and Guidlines](#14-general-batch-piplelines-and-guidlines)
- [1.5. Batch Processing Strategies](#15-batch-processing-strategies)

엔터프라이즈 도메인 어플리케이션에선 비지니스 운영에 필수적인 작업을 종종 벌크 프로세싱으로 개발한다. 예를 들어,

- 다량의 정보를 사용자 인터랙션 없이 자동으로, 효율적으로 처리하는 복잡한 프로세싱. 주로 시간 기반 이벤트(월말 정산 처리, 통지 등)

- 매우 큰 데이터 셋을 반복적, 주기적으로 처리하는 어플리케이션(보험 혜택을 정하거나 보험료를 조정하는 일) 

- 내/외부 시스템에서 받은 데이터를 통합하는 일. 보통 포맷팅, 유효성 검사, 트랜젹션 처리가 필요하다. 이미 많은 기업에서 배치 처리로 매일 수십억 건의 트랜잭션을 처리하고 있다.

스프링 배치는 포괄적인 경량 배치 프레임워크로, 엔터프라이즈 시스템 운영에 일상적으로 꼭 필요한 견고한 배치 어플리케이션 개발을 위해 설계되었다. 
스프링 배치는 사람들이 기대하는 Spring Framework의 특성(생산성, POJO기반 접근, 사용 편의성)을 기반으로 만들어져, 
개발자가 다루기 편하며 필요하다면 고급 기술 또한 쉽게 활용할 수 있다. 
스프링 배치는 스케줄링 프레임워크가 아니다. 
상업용이나 오픈 소스로 공개된 엔터프라이즈 레벨의 스케줄러는 여러 가지가 있다.(Quartz, Tivoli, Control-M, 등) 
스프링 배치는 스케줄러를 대체하는 개념이 아니라, 스케줄러와 함께 동작하도록 설계되었다.

스프링 배치는 로깅/추적, 트랜잭션 관리, job 프로세싱 통계, job 재시작, 스킵, 리소스 관리같은 
대용량 데이터 처리에 필수적인 기능들을 재사용할 수 있는 형태로 제공한다. 
다른 고급 기술들도 제공하는데, 최적화나 파티셔닝같은 기법을 사용하면 
극단적으로 큰 데이터 처리나 고성능 배치도 쉽게 구현할 수 있다. 
스프링 배치는 단순한 유스케이스(데이터베이스로 파일을 읽거나 stored procedure를 수행하는 일)와 
복잡한 대용량 처리(데이터베이스간 대용량 데이터를 이동시키고 변형하는 일 등)를 모두 지원한다.
프레임워크를 활용하면 배치 작업을 손쉽게 확장할 수 있으므로 많은 양의 데이터를 처리할 수 있다. 

## 1.1. Background

## 1.2. Usage Scenarios

## 1.3. Spring Batch Architecture

## 1.4. General Batch Piplelines and Guidlines

## 1.5. Batch Processing Strategies
