---
title: How It Works
category: Spring Cloud Gateway
order: 4
permalink: /Spring%20Cloud%20Gateway/how-it-works/
description: 스프링 클라우드 게이트웨이의 동작하는 방식을 개략적으로 설명합니다.
image: ./../../images/springcloudgateway/spring_cloud_gateway_diagram.png
lastmod: 2021-04-06T22:00:00+09:00
comments: true
originalRefName: 스프링 클라우드 게이트웨이
originalRefLink: https://docs.spring.io/spring-cloud-gateway/docs/3.0.2/reference/html/#gateway-how-it-works
---

---

다음은 스프링 클라우드 게이트웨이의 동작 방식을 간단하게 표현한 다이어그램이다:

![Spring Cloud Gateway Diagram](../../images/springcloudgateway/spring_cloud_gateway_diagram.png)

클라이언트에선 스프링 클라우드 게이트웨이에 요청을 전송한다. 게이트웨이 핸들러 매핑은 요청이 라우트와 매칭된다고 판단되면 게이트웨이 웹 핸들러로 전달한다. 이 핸들러에선 요청에 맞는 필터 체인을 통해 요청을 처리한다. 필터를 점선으로 나눈 이유는 필터는 프록시 요청을 전송하기 전과 후에 로직을 실행할 수 있기 때문이다. 먼저 모든 "pre" 필터 로직을 실행한다. 그 다음 프록시 요청을 만든다. 프록시 요청이 이루어진 후엔 "post" 필터 로직을 실행한다.

> 라우트에 URI를 포트 없이 정의했을 땐 HTTP, HTTPS는 각각 디폴트 포트 80, 443을 사용한다.