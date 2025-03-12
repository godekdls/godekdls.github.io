---
title: 3.6. Spring Cloud Contract Stub Runner
navTitle: Spring Cloud Contract Stub Runner
category: Spring Cloud Contract
order: 28
permalink: /Spring%20Cloud%20Contract/features-stubrunner/
description: Spring Cloud Contract Stub Runner를 사용하는 이유
image: ./../../images/springcloud/logo.jpeg
lastmod: 2025-03-12T23:34:00+09:00
comments: true
originalRefName: 스프링 클라우드 컨트랙트
originalRefLink: https://docs.spring.io/spring-cloud-contract/reference/4.2.0/project-features-stubrunner.html
parent: Spring Cloud Contract Features
parentUrl: /Spring%20Cloud%20Contract/features/
subparent: 3.6. Spring Cloud Contract Stub Runner
subparentNavTitle: Spring Cloud Contract Stub Runner
isSubparent: true
subparentUrl: /Spring%20Cloud%20Contract/features-stubrunner/
---

---

Spring Cloud Contract Verifier를 사용하는 동안 맞닥뜨릴 수 있는 문제 중 하나는, 서버 측에서 자동 생성된 WireMock JSON 스텁<sup>stub</sup>을 클라이언트 측으로 어떻게 전달하는가이다 (심지어 전달받을 클라이언트가 여러 곳일 수도 있다). 클라이언트 측에서 메시지를 처리하면서 스텁<sup>stub</sup>을 생성하더라도 마찬가지다.

단순히 JSON 파일을 복사해 가거나, 클라이언트 측에서 메시지 처리를 위한 설정을 수동으로 세팅하는 것은 논외다. 이러한 이유로 Spring Cloud Contract Stub Runner가 생겨났다. Stub Runner는 자동으로 스텁<sup>stub</sup>을 다운받고 실행해준다.