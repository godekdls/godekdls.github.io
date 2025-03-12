---
title: 7.7. 자동 생성된 테스트 코드에서 클라이언트가 보내는 요청/응답은 어떻게 디버깅하나요?
navTitle: 자동 생성된 테스트 코드에서 클라이언트가 보내는 요청/응답은 어떻게 디버깅하나요?
category: Spring Cloud Contract
order: 52
permalink: /Spring%20Cloud%20Contract/how-to-debug/
description: 자동 생성된 테스트 코드에서 클라이언트가 보내는 요청/응답 디버깅하기
image: ./../../images/springcloud/logo.jpeg
lastmod: 2025-03-12T23:34:00+09:00
comments: true
originalRefName: 스프링 클라우드 컨트랙트
originalRefLink: https://docs.spring.io/spring-cloud-contract/reference/4.2.0/howto/how-to-debug.html
parent: “How-to” Guides
parentUrl: /Spring%20Cloud%20Contract/howto/
---

---

자동 생성된 테스트는 결국 어떤 형식으로든 RestAssured를 사용한다. RestAssured는 [Apache HttpClient](https://hc.apache.org/httpcomponents-client-ga/)에 의존하는데, HttpClient에는 [wire logging](https://hc.apache.org/httpcomponents-client-ga/logging.html#Wire_Logging)이라는 기능이 있어서, 요청과 응답을 전부 로그에 기록한다. 스프링 부트는 로그를 위한 [공통 애플리케이션 프로퍼티](https://docs.spring.io/spring-boot/appendix/application-properties/index.html)를 제공한다. 로그를 남기려면 애플리케이션 프로퍼티에 다음 설정을 추가해라:

```properties
logging.level.org.apache.http.wire=DEBUG
```