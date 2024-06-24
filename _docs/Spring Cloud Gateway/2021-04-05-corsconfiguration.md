---
title: CORS Configuration
category: Spring Cloud Gateway
order: 15
permalink: /Spring%20Cloud%20Gateway/cors-configuration/
description: 게이트웨이로 CORS 요청 허용하기 한국어 번역
image: ./../../images/springcloud/logo.jpeg
lastmod: 2021-04-06T22:00:00+09:00
comments: true
originalRefName: 스프링 클라우드 게이트웨이
originalRefLink: https://docs.spring.io/spring-cloud-gateway/docs/3.0.2/reference/html/#cors-configuration
---

---

설정만 넣어주면 게이트웨이에서 CORS 동작을 제어할 수 있다. "글로벌" CORS 설정은 URL 패턴을 [스프링 프레임워크 `CorsConfiguration`](https://docs.spring.io/spring/docs/5.0.x/javadoc-api/org/springframework/web/cors/CorsConfiguration.html)로 매핑한 맵으로 표현한다. 다음은 CORS를 설정하는 예시다:

**Example 69. application.yml**

```yaml
spring:
  cloud:
    gateway:
      globalcors:
        cors-configurations:
          '[/**]':
            allowedOrigins: "https://docs.spring.io"
            allowedMethods:
            - GET
```

위 예시에선 모든 GET 요청 path에 대해 `docs.spring.io`에서 시작된 요청에만 CORS를 허용한다.

게이트웨이 route predicate에서 처리하지 않는 요청에 같은 CORS 설정을 제공하려면, `spring.cloud.gateway.globalcors.add-to-simple-url-handler-mapping` 프로퍼티를 `true`로 설정해라. 이 프로퍼티는 CORS preflight 요청을 지원하고 싶은데, route predicate가 HTTP 메소드 `options`를 `true`로 평가하지 않을 때 유용할 거다.