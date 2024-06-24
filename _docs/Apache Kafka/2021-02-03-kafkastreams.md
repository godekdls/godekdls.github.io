---
title: Kafka Streams
category: Apache Kafka
order: 17
permalink: /Apache%20Kafka/kafka-streams/
description: 카프카 스트림즈 소개 한국어 번역
image: ./../../images/kafka/logo.png
lastmod: 2021-02-14T22:25:00+09:00
comments: true
originalRefName: 아파치 카프카
originalRefLink: https://kafka.apache.org/27/documentation.html#streams
---

---

카프카 스트림즈는 카프카에 저장한 데이터를 처리하고 분석하기 위한 클라이언트 라이브러리다. 이벤트 시간과 처리 시간을 적절하게 구분하는 기능이나, windowing 처리, exactly-once 시맨틱스, 간단하면서도 효율적인 어플리케이션 상태 관리같은, 주요 스트림 처리 개념을 중심으로 구축했다.

카프카 스트림즈는 **진입 장벽이 낮다**: 단일 머신 위에서 소규모 POC를 빠르게 작성하고 실행할 수 있다. 대용량 프로덕션 워크로드로 확장할 땐 머신 여러 개에서 어플리케이션 인스턴스를 추가로 실행하기만 하면 된다. 카프카 스트림즈는 카프카의 병렬 처리 모델을 활용해서 멀티 인스턴스로 띄운 어플리케이션의 부하를 투명하게 분산 처리해준다.

카프카 스트림즈에 대해 더 알아보려면 [이 섹션](https://kafka.apache.org/documentation/streams)을 읽어봐라.