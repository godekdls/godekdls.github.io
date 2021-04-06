---
title: How to Include Spring Cloud Gateway
category: Spring Cloud Gateway
order: 2
permalink: /Spring%20Cloud%20Gateway/how-to-include-spring-cloud-gateway/
description: 프로젝트에 스프링 클라우드 게이트웨이를 추가하는 방법 한글 번역
image: ./../../images/springcloud/logo.jpeg
lastmod: 2021-04-06T22:00:00+09:00
comments: true
originalRefName: 스프링 클라우드 게이트웨이
originalRefLink: https://docs.spring.io/spring-cloud-gateway/docs/3.0.2/reference/html/#gateway-starter
---

---

프로젝트에 스프링 클라우드 게이트웨이를 추가하려면 그룹 ID `org.springframework.cloud`, 아티팩트 ID `spring-cloud-starter-gateway`인 스타터를 사용하면 된다. 현재 스프링 클라우드 릴리즈 트레인으로 빌드 시스템을 설정하는 자세한 방법은 [스프링 클라우드 프로젝트 페이지](https://projects.spring.io/spring-cloud/)를 참고해라.

스타터를 추가하돼 게이트웨이를 활성화하고 싶지 않다면 `spring.cloud.gateway.enabled=false`를 설정해라.

> 스프링 클라우드 게이트웨이는 [스프링 부트 2.x](https://spring.io/projects/spring-boot#learn), [스프링 웹플럭스](../../Reactive%20Spring/contents/), [프로젝트 리액터](https://projectreactor.io/docs) 기반이다. 그렇기 때문에 이미 익숙한 동기식 라이브러리(스프링 데이터, 스프링 시큐리티 등)나 알만한 패턴들은 스프링 클라우드 게이트웨이를 썼을 땐 적용이 안 될 수도 있다. 이런 프로젝트에 익숙하지 않다면, 스프링 클라우드 게이트웨이로 작업하기 전에 먼저 관련 문서를 읽는 것부터 시작해 새로운 개념들을 익히고 오는 게 좋다.

> 스프링 클라우드 게이트웨이는 스프링 부트와 스프링 웹플럭스에서 제공하는 Netty 런타임이 필요하다. 기존의 서블릿 컨테이너를 쓰거나 어플리케이션을 WAR로 빌드했을 땐 동작하지 않는다.