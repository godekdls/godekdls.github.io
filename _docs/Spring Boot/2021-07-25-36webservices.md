---
title: Web Services
category: Spring Boot 2.X
order: 36
permalink: /Spring%20Boot/web-services/
description: 스프링 부트로 웹 서비스 자동 설정하기
image: ./../../images/springboot/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 부트
originalRefLink: https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#features.webservices
parent: Spring Boot Features
parentUrl: /Spring%20Boot/spring-boot-features/
priority: 0.4
---
<script>defaultLanguages = ['properties']</script>

### 목차

- [7.28.1. Calling Web Services with WebServiceTemplate](#7281-calling-web-services-with-webservicetemplate)

---

## 7.28. Web Services

스프링 부트는 웹 서비스 자동 설정을 제공하기 때문에 `Endpoints`를 정의하기만 하면 된다.

[Spring Web Services 기능들은](https://docs.spring.io/spring-ws/docs/3.1.1/reference/html/) `spring-boot-starter-web-services` 모듈로 쉽게 접근할 수 있다.

WSDLs와 XSDs를 사용할 땐 각각 `SimpleWsdl11Definition`과 `SimpleXsdSchema` 빈을 자동으로 생성할 수 있다. 아래 예시처럼 위치를 지정해주면 된다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.webservices.wsdl-locations=classpath:/wsdl
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  webservices:
    wsdl-locations: "classpath:/wsdl"
```

### 7.28.1. Calling Web Services with WebServiceTemplate

애플리케이션에서 원격에 있는 웹 서비스를 호출해야 할 땐 [`WebServiceTemplate`](https://docs.spring.io/spring-ws/docs/3.1.1/reference/html/#client-web-service-template) 클래스를 사용할 수 있다. `WebServiceTemplate` 인스턴스는 사용 전에 커스텀해야 하는 경우가 많기 때문에 스프링 부트는 `WebServiceTemplate` 빈을 단일로 자동 설정해주지 않는다. 하지만 `WebServiceTemplate` 인스턴스를 만들 때 활용할 수 있는 `WebServiceTemplateBuilder`를 자동으로 설정해준다.

다음은 `WebServiceTemplateBuilder`를 활용하는 전형적인 예시다:

```java
@Service
public class MyService {

    private final WebServiceTemplate webServiceTemplate;

    public MyService(WebServiceTemplateBuilder webServiceTemplateBuilder) {
        this.webServiceTemplate = webServiceTemplateBuilder.build();
    }

    public SomeResponse someWsCall(SomeRequest detailsReq) {
        return (SomeResponse) this.webServiceTemplate.marshalSendAndReceive(detailsReq,
                new SoapActionCallback("https://ws.example.com/action"));
    }

}
```

`WebServiceTemplateBuilder`는 기본적으로 클래스패스에서 사용할 수 있는 HTTP 클라이언트 라이브러리를 찾아 적절한 HTTP 기반 `WebServiceMessageSender`를 설정해준다. 다음과 같이 read/connection 타임아웃을 커스텀할 수도 있다:

```java
@Configuration(proxyBeanMethods = false)
public class MyWebServiceTemplateConfiguration {

    @Bean
    public WebServiceTemplate webServiceTemplate(WebServiceTemplateBuilder builder) {
        WebServiceMessageSender sender = new HttpWebServiceMessageSenderBuilder()
                .setConnectTimeout(Duration.ofSeconds(5))
                .setReadTimeout(Duration.ofSeconds(2))
                .build();
        return builder.messageSenders(sender).build();
    }

}
```
