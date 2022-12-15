---
title: HTTP Clients
category: Spring Boot 2.X
order: 62
permalink: /Spring%20Boot/howto.http-clients/
description: HTTP 클라이언트와 관련된 how to 가이드 (RestTemplate에 프록시 설정하기, TcpClient 커스텀하기 등)
image: ./../../images/springboot/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 부트
originalRefLink: https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#howto.http-clients
parent: “How-to” Guides
parentUrl: /Spring%20Boot/how-to-guides/
priority: 0.4
---

### 목차

- [12.6.1. Configure RestTemplate to Use a Proxy](#1261-configure-resttemplate-to-use-a-proxy)
- [12.6.2. Configure the TcpClient used by a Reactor Netty-based WebClient](#1262-configure-the-tcpclient-used-by-a-reactor-netty-based-webclient)

---

## 12.6. HTTP Clients

스프링 부트가 제공하는 스타터 중에는 HTTP 클라이언트와 함께 동작하는 스타터가 많다. 이번 섹션에선 HTTP 클라이언트를 사용할 때 궁금해하는 질문들에 답해본다.

### 12.6.1. Configure RestTemplate to Use a Proxy

[RestTemplate 커스텀하기](../calling-rest-services-with-resttemplate#7151-resttemplate-customization)에서도 설명했지만, `RestTemplateCustomizer`를 이용해 `RestTemplateBuilder`를 사용하면 커스텀 로직을 적용한 `RestTemplate`을 빌드할 수 있다. 프록시 설정이 들어있는 `RestTemplate`을 생성할 때도 권장하는 방법이다.

정확한 프록시 설정은 사용 중인 기본 클라이언트 request 팩토리에 따라 다르다.

### 12.6.2. Configure the TcpClient used by a Reactor Netty-based WebClient

클래스패스에 Reactor Netty가 있을 때는 Reactor Netty 기반 `WebClient`를 자동 설정한다. 이 클라이언트의 네트워크 커넥션 처리 로직을 커스텀하려면 `ClientHttpConnector` 빈을 정의해라. 아래 예제에선 커넥션 타임아웃을 60초로 설정하고 `ReadTimeoutHandler`를 추가하고 있다:

```java
@Configuration(proxyBeanMethods = false)
public class MyReactorNettyClientConfiguration {

    @Bean
    ClientHttpConnector clientHttpConnector(ReactorResourceFactory resourceFactory) {
        HttpClient httpClient = HttpClient.create(resourceFactory.getConnectionProvider())
                .runOn(resourceFactory.getLoopResources())
                .option(ChannelOption.CONNECT_TIMEOUT_MILLIS, 60000)
                .doOnConnected((connection) -> connection.addHandlerLast(new ReadTimeoutHandler(60)));
        return new ReactorClientHttpConnector(httpClient);
    }

}
```

> 커넥션 provider와 이벤트 루프 리소스에 `ReactorResourceFactory`를 사용한 걸 주목해라. 이렇게 하면 요청을 받는 서버와 요청을 전송하는 클라이언트에서 리소스를 효율적으로 공유할 수 있다.
