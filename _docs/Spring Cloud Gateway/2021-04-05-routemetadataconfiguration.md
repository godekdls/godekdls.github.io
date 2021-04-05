---
title: Route Metadata Configuration
category: Spring Cloud Gateway
order: 12
permalink: /Spring%20Cloud%20Gateway/route-metadata-configuration/
description: 게이트웨이 route에 메타데이터를 설정하고 exchange로 조회하는 방법 한글 번역
image: ./../../images/springcloud/logo.jpeg
lastmod: 2021-04-06T22:00:00+09:00
comments: true
originalRefName: 스프링 클라우드 게이트웨이
originalRefLink: https://docs.spring.io/spring-cloud-gateway/docs/3.0.2/reference/html/#route-metadata-configuration
---

---

모든 route에는 다음과 같이 메타데이터를 통해 별도의 파라미터를 설정할 수 있다:

**Example 65. application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: route_with_metadata
        uri: https://example.org
        metadata:
          optionName: "OptionValue"
          compositeObject:
            name: "value"
          iAmNumber: 1
```

모든 메타데이터 프로퍼티는 다음과 같이 exchange에서 가져올 수 있다:

```java
Route route = exchange.getAttribute(GATEWAY_ROUTE_ATTR);
// get all metadata properties
route.getMetadata();
// get a single metadata property
route.getMetadata(someKey);
```