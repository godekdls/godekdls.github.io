---
title: 7.8. WireMock의 요청, 매핑, 응답 정보는 어떻게 디버깅하나요?
navTitle: WireMock의 요청, 매핑, 응답 정보는 어떻게 디버깅하나요?
category: Spring Cloud Contract
order: 53
permalink: /Spring%20Cloud%20Contract/how-to-debug-wiremock/
description: WireMock의 요청, 매핑, 응답 정보 디버깅하기
image: ./../../images/springcloud/logo.jpeg
lastmod: 2025-03-12T23:34:00+09:00
comments: true
originalRefName: 스프링 클라우드 컨트랙트
originalRefLink: https://docs.spring.io/spring-cloud-contract/reference/4.2.0/howto/how-to-debug-wiremock.html
parent: “How-to” Guides
parentUrl: /Spring%20Cloud%20Contract/howto/
---

---

`1.2.0` 버전부터 WireMock 로그 레벨은 `info`로 설정하고, WireMock notifier를 상세히 확인할 수 있도록 변경했다. 이제 WireMock 서버에서 어떤 요청을 수신하고 어떤 응답 정의를 매칭시켰는지 정확히 파악할 수 있다.

이 기능을 끄려면 다음과 같이 WireMock 로그 레벨을 `ERROR`로 설정해라:

```properties
logging.level.com.github.tomakehurst.wiremock=ERROR
```