---
title: Calling REST Services with WebClient
category: Spring Boot 2.X
order: 24
permalink: /Spring%20Boot/calling-rest-services-with-webclient/
description: 스프링 부트로 WebClient 자동 설정하고 커스텀하기
image: ./../../images/springboot/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 부트
originalRefLink: https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#features.webclient
parent: Spring Boot Features
parentUrl: /Spring%20Boot/spring-boot-features/
priority: 0.4
---

### 목차

- [7.16.1. WebClient Runtime](#7161-webclient-runtime)
- [7.16.2. WebClient Customization](#7162-webclient-customization)

---

## 7.16. Calling REST Services with WebClient

클래스패스에 스프링 웹플럭스가 있을 땐 `WebClient`로도 원격에 있는 REST 서비스를 호출할 수 있다. 이 클라이언트는 `RestTemplate`에 비하면 좀 더 함수형 느낌에 가까우며, 완전히 리액티브로 동작한다. `WebClient`는 [스프링 프레임워크 문서의 전용 섹션](../../Reactive%20Spring/webclient)에서 자세히 확인할 수 있다.

스프링 부트는 `WebClient.Builder`를 만들어 미리 설정해준다. `WebClient` 인스턴스를 만들 땐 원하는 컴포넌트에 빌더를 주입해서 만드는 게 가장 좋다. 스프링 부트에서 이 빌더를 설정할 땐 HTTP 리소스를 공유하고 코덱 설정 등을 서버와 동일하게 반영한다 ([웹플럭스 HTTP 코덱 자동 설정](../developing-web-applications#http-codecs-with-httpmessagereaders-and-httpmessagewriters)을 참고해라).

다음은 `WebClient.Builder`를 사용하는 전형적인 예시다:

```java
@Service
public class MyService {

    private final WebClient webClient;

    public MyService(WebClient.Builder webClientBuilder) {
        this.webClient = webClientBuilder.baseUrl("https://example.org").build();
    }

    public Mono<Details> someRestCall(String name) {
        return this.webClient.get().uri("/{name}/details", name).retrieve().bodyToMono(Details.class);
    }

}
```

### 7.16.1. WebClient Runtime

스프링 부트는 애플리케이션 클래스패스에 있는 라이브러리에 따라 `WebClient`를 구동할 때 이용할 `ClientHttpConnector`를 자동으로 감지한다. 현재는 Reactor Netty와 Jetty RS 클라이언트를 지원한다.

`spring-boot-starter-webflux` 스타터는 기본적으로 `io.projectreactor.netty:reactor-netty`를 사용하며, 리액터 네티는 서버와 클라이언트 구현체를 모두 제공한다. 리액터 네티대신 Jetty를 리액티브 서버로 사용하기로 했다면, Jetty 리액티브 HTTP 클라이언트 라이브러리 의존성 `org.eclipse.jetty:jetty-reactive-httpclient`를 추가해야 한다. 서버와 클라이언트에 같은 기술을 사용했을 때 좋은 점은, HTTP 리소스를 클라이언트와 서버가 자동으로 공유하게 된다는 점이다.

커스텀 `ReactorResourceFactory`나 `JettyResourceFactory` 빈을 제공하면 Reactor Netty, Jetty에서 사용할 리소스 설정을 재정의할 수 있다. 커스텀하게 되면 클라이언트와 서버에 모두 적용된다.

사용할 클라이언트를 재정의하려면, 자체 `ClientHttpConnector` 빈을 정의하고 클라이언트 설정을 전부 직접 제어하면 된다.

자세한 [`WebClient` 설정 옵션은 스프링 프레임워크 레퍼런스 문서](../../Reactive%20Spring/webclient/#21-configuration)에서 확인할 수 있다.

### 7.16.2. WebClient Customization

`WebClient`를 커스텀하는 방법은, 커스텀을 적용하려는 범위에 따라 세 가지로 나뉜다.

커스텀 범위를 최소한으로 좁히려면 자동 설정된 `WebClient.Builder`를 주입한 다음 필요한 메소드를 호출해라. `WebClient.Builder` 인스턴스는 상태를 가지고 있다<sup>stateful</sup>. 즉, 빌더에 일어나는 모든 변경 사항은 이후에 만드는 클라이언트에도 전부 반영된다. 같은 빌더로 여러 클라이언트를 생성하고 싶으면 `WebClient.Builder other = builder.clone();`을 사용해 빌더를 복제하는 것도 좋다.

`WebClient.Builder` 인스턴스의 커스텀 로직을 애플리케이션 전체에 걸쳐 적용하려면, `WebClientCustomizer` 빈을 선언하고 그 안에서 `WebClient.Builder`를 주입받아 변경하면 된다.

마지막으로, 기존 `WebClient` API로 돌아가 `WebClient.create()`를 사용할 수도 있다. 이땐 자동 설정이나 `WebClientCustomizer`는 적용되지 않는다.