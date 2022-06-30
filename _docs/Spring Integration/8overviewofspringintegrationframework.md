---
title: Overview of Spring Integration Framework
category: Spring Integration
order: 8
permalink: /Spring%20Integration/introduction/
description: 스프링 인티그레이션 소개
image: ./../../images/springintegration/logo.png
lastmod: 2022-01-05T21:30:00+09:00
comments: true
originalRefName: 스프링 인티그레이션
originalRefLink: https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/index-single.html#spring-integration-introduction
parent: Overview of Spring Integration Framework
isParent: true
parentUrl: /Spring%20Integration/introduction/
priority: 0.3
---

---

Spring Integration은 스프링 프로그래밍 모델을 확장해서 유명 [엔터프라이즈 통합 패턴들](https://www.enterpriseintegrationpatterns.com/)을 지원한다. 덕분에 스프링 기반 애플리케이션 내에서 경량으로 메시지를 처리할 수 있으며, 어댑터를 선언해 외부 시스템과 통합할 수 있다. 이런 어댑터들은 스프링의 원격 호출, 메시지 처리, 스케줄링 지원보다 한 단계 더 높은 수준으로 추상화되어 있다.

Spring Integration의 주요 목표는 유지보수와 테스트가 가능한 코드를 생산하려면 반드시 필요한 관심사의 분리<sup>separation of concerns</sup>를 그대로 가져가면서, 동시에 엔터프라이즈 통합 솔루션을 구축할 수 있는 간단한 모델을 제공하는 거다.