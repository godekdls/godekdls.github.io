---
title: 7.16. 컨트랙트나 스텁이 없어도 빌드를 통과시키려면 어떻게 해야 하나요?
navTitle: 컨트랙트나 스텁이 없어도 빌드를 통과시키려면 어떻게 해야 하나요?
category: Spring Cloud Contract
order: 61
permalink: /Spring%20Cloud%20Contract/how-to-use-the-failonnostubs-feature/
description: 컨트랙트나 스텁이 없을 때에도 빌드 통과시키기
image: ./../../images/springcloud/logo.jpeg
lastmod: 2025-03-12T23:34:00+09:00
comments: true
originalRefName: 스프링 클라우드 컨트랙트
originalRefLink: https://docs.spring.io/spring-cloud-contract/reference/4.2.0/howto/how-to-use-the-failonnostubs-feature.html
parent: “How-to” Guides
parentUrl: /Spring%20Cloud%20Contract/howto/
---

---

Stub Runner가 스텁<sup>stub</sup>을 발견하지 못해도 실패로 끝나지 않도록 만들려면, `@AutoConfigureStubRunner` 어노테이션에서 `generateStubs` 프로퍼티를 변경하거나 JUnit Rule/Extension의 `withFailOnNoStubs(false)` 메소드를 호출해라. 자세헨 내용은 [이 섹션](../stub-runner-fail-on-no-stubs/)에서 확인할 수 있다.

플러그인이 명세<sup>contract</sup>를 찾지 못했을 때 빌드에 실패하지 않도록 하려면, Maven에선 `failOnNoStubs` 플래그를 설정하고, Gradle에선 `contractRepository { failOnNoStubs(false) }` 클로저를 호출하면 된다.