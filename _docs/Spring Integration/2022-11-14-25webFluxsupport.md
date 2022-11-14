---
title: WebFlux Support
category: Spring Integration
order: 25
permalink: /Spring%20Integration/webflux/
description: 리액티브 방식으로 메시지 처리와 HTTP 처리 통합하기
image: ./../../images/springintegration/http-inbound-gateway.png
lastmod: 2022-11-14T22:00:00+09:00
comments: true
originalRefName: 스프링 인티그레이션
originalRefLink: https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/index-single.html#webflux
parent: Integration Endpoints
parentUrl: /Spring%20Integration/integration-endpoints/
---
<script>defaultLanguages = ['maven', 'java-dsl']</script>

---

Spring Integration의 WebFlux 모듈(`spring-integration-webflux`)을 사용하면 리액티브 방식으로 HTTP 요청을 실행하고, HTTP 요청을 받아 무언가를 처리할 수 있다.

프로젝트에는 아래 의존성을 추가해야 한다:

<div class="switch-language-wrapper maven gradle">
<span class="switch-language maven">Maven</span>
<span class="switch-language gradle">Gradle</span>
</div>
<div class="language-only-for-maven maven gradle"></div>
```xml
<dependency>
    <groupId>org.springframework.integration</groupId>
    <artifactId>spring-integration-webflux</artifactId>
    <version>5.5.15</version>
</dependency>
```
<div class="language-only-for-gradle maven gradle"></div>
```groovy
compile "org.springframework.integration:spring-integration-webflux:5.5.15"
```

서블릿 기반이 아닌 서버를 설정한다면 반드시 `io.projectreactor.netty:reactor-netty` 의존성을 추가해야 한다.

WebFlux 지원은 게이트웨이 구현체, `WebFluxInboundEndpoint`와 `WebFluxRequestExecutingMessageHandler`로 이루어진다. 여기서는 거의 대부분이 스프링 [웹플럭스](../../Reactive%20Spring/contents)와 [프로젝트 리액터](https://projectreactor.io/)를 활용한다. 리액티브 구성 요소와 일반 HTTP 구성 요소는 공통으로 사용하는 옵션들이 아주 많기 때문에, 자세한 내용은 [HTTP 지원](../http)을 참고하면 된다.

### 목차

- [39.1. WebFlux Namespace Support](#391-webflux-namespace-support)
- [39.2. WebFlux Inbound Components](#392-webflux-inbound-components)
  + [39.2.1. Payload Validation](#3921-payload-validation)
- [39.3. WebFlux Outbound Components](#393-webflux-outbound-components)
- [39.4. WebFlux Header Mappings](#394-webflux-header-mappings)

---

## 39.1. WebFlux Namespace Support

Spring Integration은 `webflux` 네임스페이스와 전용 스키마 정의를 제공하고 있다. 설정에 포함시키려면 애플리케이션 컨텍스트 설정 파일에 아래와 같은 네임스페이스를 선언해주면 된다:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:int="http://www.springframework.org/schema/integration"
  xmlns:int-webflux="http://www.springframework.org/schema/integration/webflux"
  xsi:schemaLocation="
    http://www.springframework.org/schema/beans
    https://www.springframework.org/schema/beans/spring-beans.xsd
    http://www.springframework.org/schema/integration
    https://www.springframework.org/schema/integration/spring-integration.xsd
    http://www.springframework.org/schema/integration/webflux
    https://www.springframework.org/schema/integration/webflux/spring-integration-webflux.xsd">
    ...
</beans>
```

---

## 39.2. WebFlux Inbound Components

5.0 버전부터 `WebHandler`를 구현한 `WebFluxInboundEndpoint`를 제공한다. 이 클래스는 MVC 기반의  `HttpRequestHandlingEndpointSupport`와 유사한데, 공통으로 사용하는 옵션들은 따로 빼서 상위 클래스 `BaseHttpInboundEndpoint`에 담아놨다. MVC가 아닌 스프링 WebFlux, 즉 리액티브 환경에선 `WebFluxInboundEndpoint`를 사용하면 된다. 다음은 WebFlux 엔드포인트를 사용하는 간단한 예시다:

<div class="switch-language-wrapper java-dsl kotlin-dsl java xml">
<span class="switch-language java-dsl">Java DSL</span>
<span class="switch-language kotlin-dsl">Kotlin DSL</span>
<span class="switch-language java">Java</span>
<span class="switch-language xml">XML</span>
</div>
<div class="language-only-for-java-dsl java-dsl kotlin-dsl java xml"></div>
```java
@Bean
public IntegrationFlow inboundChannelAdapterFlow() {
    return IntegrationFlows
        .from(WebFlux.inboundChannelAdapter("/reactivePost")
            .requestMapping(m -> m.methods(HttpMethod.POST))
            .requestPayloadType(ResolvableType.forClassWithGenerics(Flux.class, String.class))
            .statusCodeFunction(m -> HttpStatus.ACCEPTED))
        .channel(c -> c.queue("storeChannel"))
        .get();
}
```
<div class="language-only-for-kotlin-dsl java-dsl kotlin-dsl java xml"></div>
```kotlin
@Bean
fun inboundChannelAdapterFlow() =
    integrationFlow(
        WebFlux.inboundChannelAdapter("/reactivePost")
            .apply {
                requestMapping { m -> m.methods(HttpMethod.POST) }
                requestPayloadType(ResolvableType.forClassWithGenerics(Flux::class.java, String::class.java))
                statusCodeFunction { m -> HttpStatus.ACCEPTED }
            })
    {
        channel { queue("storeChannel") }
    }
```
<div class="language-only-for-java java-dsl kotlin-dsl java xml"></div>
```java
@Configuration
@EnableWebFlux
@EnableIntegration
public class ReactiveHttpConfiguration {

    @Bean
    public WebFluxInboundEndpoint simpleInboundEndpoint() {
        WebFluxInboundEndpoint endpoint = new WebFluxInboundEndpoint();
        RequestMapping requestMapping = new RequestMapping();
        requestMapping.setPathPatterns("/test");
        endpoint.setRequestMapping(requestMapping);
        endpoint.setRequestChannelName("serviceChannel");
        return endpoint;
    }

    @ServiceActivator(inputChannel = "serviceChannel")
    String service() {
        return "It works!";
    }

}
```
<div class="language-only-for-xml java-dsl kotlin-dsl java xml"></div>
```xml
<int-webflux:inbound-gateway request-channel="requests" path="/sse">
    <int-webflux:request-mapping produces="text/event-stream"/>
</int-webflux:inbound-gateway>
```

이 설정은 `@EnableWebFlux`를 사용해 통합 애플리케이션에 WebFlux 인프라를 추가한다는 점만 제외하면 앞에서 언급한 `HttpRequestHandlingEndpointSupport`와 유사하다. 또한 `WebFluxInboundEndpoint`는 리액티브 HTTP 서버 구현체에서 제공하는 back-pressure, 온 디맨드 기반 기능들을 사용해 다운스트림 플로우를 향해 `sendAndReceive` 연산을 수행한다.

> reply 역시 논블로킹으로 처리하며, 내부에서 사용하는 `FutureReplyChannel`은 온 디맨드로 응답을 가져올 수 있도록 reply `Mono`로 변환<sup>flat-map</sup>된다.

`WebFluxInboundEndpoint`를 설정할 땐 `ServerCodecConfigurer`나 `RequestedContentTypeResolver`, 심지어 `ReactiveAdapterRegistry`까지도 커스텀할 수 있다. `ReactiveAdapterRegistry`를 활용하면 Reactor `Flux`, RxJava `Observable`, `Flowable` 등 원하는 리액티브 타입으로 반환할 수 있다. 다음 예제와 같이 Spring Integration 구성 요소들을 사용해 `WebFluxInboundEndpoint`를 설정하면 [Server Sent Events](https://en.wikipedia.org/wiki/Server-sent_events)도 구현할 수 있다:

<div class="switch-language-wrapper java-dsl kotlin-dsl java xml">
<span class="switch-language java-dsl">Java DSL</span>
<span class="switch-language kotlin-dsl">Kotlin DSL</span>
<span class="switch-language java">Java</span>
<span class="switch-language xml">XML</span>
</div>
<div class="language-only-for-java-dsl java-dsl kotlin-dsl java xml"></div>
```java
@Bean
public IntegrationFlow sseFlow() {
    return IntegrationFlows
            .from(WebFlux.inboundGateway("/sse")
                    .requestMapping(m -> m.produces(MediaType.TEXT_EVENT_STREAM_VALUE)))
            .handle((p, h) -> Flux.just("foo", "bar", "baz"))
            .get();
}
```
<div class="language-only-for-kotlin-dsl java-dsl kotlin-dsl java xml"></div>
```kotlin
@Bean
fun sseFlow() =
     integrationFlow(
            WebFlux.inboundGateway("/sse")
                       .requestMapping(m -> m.produces(MediaType.TEXT_EVENT_STREAM_VALUE)))
            {
                 handle { (p, h) -> Flux.just("foo", "bar", "baz") }
            }
```
<div class="language-only-for-java java-dsl kotlin-dsl java xml"></div>
```java
@Bean
public WebFluxInboundEndpoint webfluxInboundGateway() {
    WebFluxInboundEndpoint endpoint = new WebFluxInboundEndpoint();
    RequestMapping requestMapping = new RequestMapping();
    requestMapping.setPathPatterns("/sse");
    requestMapping.setProduces(MediaType.TEXT_EVENT_STREAM_VALUE);
    endpoint.setRequestMapping(requestMapping);
    endpoint.setRequestChannelName("requests");
    return endpoint;
}
```
<div class="language-only-for-xml java-dsl kotlin-dsl java xml"></div>
```xml
<int-webflux:inbound-channel-adapter id="reactiveFullConfig" channel="requests"
                               path="test1"
                               auto-startup="false"
                               phase="101"
                               request-payload-type="byte[]"
                               error-channel="errorChannel"
                               payload-expression="payload"
                               supported-methods="PUT"
                               status-code-expression="'202'"
                               header-mapper="headerMapper"
                               codec-configurer="codecConfigurer"
                               reactive-adapter-registry="reactiveAdapterRegistry"
                               requested-content-type-resolver="requestedContentTypeResolver">
            <int-webflux:request-mapping headers="foo"/>
            <int-webflux:cross-origin origin="foo" method="PUT"/>
            <int-webflux:header name="foo" expression="'foo'"/>
</int-webflux:inbound-channel-adapter>
```

다른 설정 옵션들은 [Request 매핑 지원](../http/#2132-request-mapping-support)과 [CORS<sup>Cross-Origin Resource Sharing</sup>) 지원](../http/#2133-cross-origin-resource-sharing-cors-support)을 참고해라.

요청 body가 비어 있거나 `payloadExpression`이 `null`을 반환하면, 처리할 메시지의 `payload`에 요청 파라미터(`MultiValueMap<String, String>`)를 사용한다.

### 39.2.1. Payload Validation

`WebFluxInboundEndpoint`는 5.2 버전부터 `Validator`를 설정할 수 있다. [HTTP 지원](../http/#2111-payload-validation)에서 설명했던 MVC의 유효성 검사와는 달리, WebFlux에선 `HttpMessageReader`가 요청을 변환해서 만드는, 폴백이나 `payloadExpression`을 적용하기 전 상태의 `Publisher` 요소들의 유효성을 검사한다. 최종 페이로드 값을 빌드하고 나서는 `Publisher` 객체가 너무 복잡해질 수 있기 때문이다. 꼭 최종 페이로드(또는 페이로드의 `Publisher` 요소)에 대한 유효성을 검사해야 한다면, 유효성 검사 로직을 WebFlux 엔드포인트에 두지 말고, 다운스트림으로 이동시켜야 한다. 자세한 정보는 스프링 웹플럭스 [문서](../../Reactive%20Spring/springwebflux2/#validation)를 참고해라. 유효하지 않은 페이로드는 모든 validation `Errors`를 담고있는 `IntegrationWebExchangeBindException`(`WebExchangeBindException`을 상속한 클래스)을 통해 거절한다. 유효성 검사에 대한 자세한 내용은 스프링 프레임워크 [레퍼런스 매뉴얼](https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#validation)을 참고해라.

---

## 39.3. WebFlux Outbound Components

`WebFluxRequestExecutingMessageHandler`(5.0 부터)는 `HttpRequestExecutingMessageHandler`와 유사하다. 이 구현체는 스프링 프레임워크 WebFlux 모듈의 `WebClient`를 사용한다. 이 클래스를 설정하려면 아래와 비슷하게 빈을 정의하면 된다:

<div class="switch-language-wrapper java-dsl kotlin-dsl java xml">
<span class="switch-language java-dsl">Java DSL</span>
<span class="switch-language kotlin-dsl">Kotlin DSL</span>
<span class="switch-language java">Java</span>
<span class="switch-language xml">XML</span>
</div>
<div class="language-only-for-java-dsl java-dsl kotlin-dsl java xml"></div>
```java
@Bean
public IntegrationFlow outboundReactive() {
    return f -> f
        .handle(WebFlux.<MultiValueMap<String, String>>outboundGateway(m ->
                UriComponentsBuilder.fromUriString("http://localhost:8080/foo")
                        .queryParams(m.getPayload())
                        .build()
                        .toUri())
                .httpMethod(HttpMethod.GET)
                .expectedResponseType(String.class));
}
```
<div class="language-only-for-kotlin-dsl java-dsl kotlin-dsl java xml"></div>
```kotlin
@Bean
fun outboundReactive() =
    integrationFlow {
        handle(
            WebFlux.outboundGateway<MultiValueMap<String, String>>({ m ->
                UriComponentsBuilder.fromUriString("http://localhost:8080/foo")
                    .queryParams(m.getPayload())
                    .build()
                    .toUri()
            })
                .httpMethod(HttpMethod.GET)
                .expectedResponseType(String::class.java)
        )
    }
```
<div class="language-only-for-java java-dsl kotlin-dsl java xml"></div>
```java
@ServiceActivator(inputChannel = "reactiveHttpOutRequest")
@Bean
public WebFluxRequestExecutingMessageHandler reactiveOutbound(WebClient client) {
    WebFluxRequestExecutingMessageHandler handler =
        new WebFluxRequestExecutingMessageHandler("http://localhost:8080/foo", client);
    handler.setHttpMethod(HttpMethod.POST);
    handler.setExpectedResponseType(String.class);
    return handler;
}
```
<div class="language-only-for-xml java-dsl kotlin-dsl java xml"></div>
```xml
<int-webflux:outbound-gateway id="reactiveExample1"
    request-channel="requests"
    url="http://localhost/test"
    http-method-expression="headers.httpMethod"
    extract-request-payload="false"
    expected-response-type-expression="payload"
    charset="UTF-8"
    reply-timeout="1234"
    reply-channel="replies"/>

<int-webflux:outbound-channel-adapter id="reactiveExample2"
   url="http://localhost/example"
   http-method="GET"
   channel="requests"
   charset="UTF-8"
   extract-payload="false"
   expected-response-type="java.lang.String"
   order="3"
   auto-startup="false"/>
```

`WebClient`의 `exchange()`는 `Mono<ClientResponse>`를 반환하고, 이 반환값은 `WebFluxRequestExecutingMessageHandler`가 출력하는 `AbstractIntegrationMessageBuilder`에 매핑된다 (`Mono.map()`을 여러 번 거쳐서). `ReactiveChannel`을 `outputChannel`로 함께 사용하면 다운스트림에서 구독이 일어날 때까지 `Mono<ClientResponse>`의 평가를 연기한다. 그 외는 `async` 모드로 처리하며, `Mono` 응답을 `SettableListenableFuture`로 조정해서 `WebFluxRequestExecutingMessageHandler`의 비동기 응답을 처리한다. 출력 메시지로 사용할 페이로드는 `WebFluxRequestExecutingMessageHandler`의 설정에 따라 달라진다. `setExpectedResponseType(Class<?>)`나 `setExpectedResponseTypeExpression(Expression)`으로는 응답 body로 변환할 대상 타입을 지정한다. `replyPayloadToFlux`를 `true`로 설정하면 응답 body는 지정한 `expectedResponseType`의 `Flux`로 변환되고, 이 `Flux`를 다운스트림 페이로드로 전송한다. 이후 [splitter](../messaging-routing/#83-splitter)를 사용하면 이 `Flux`를 리액티브 방식으로 순회할 수 있다.

추가로, `expectedResponseType`이나 `replyPayloadToFlux` 프로퍼티 대신 `WebFluxRequestExecutingMessageHandler`에 `BodyExtractor<?, ClientHttpResponse>`를 주입해도 된다. `BodyExtractor<?, ClientHttpResponse>`를 사용하면 `ClientHttpResponse`를 저수준으로 접근해 처리하고, body와 HTTP 헤더 변환을 좀 더 원하는대로 조정할 수 있다. Spring Integration은 identity 함수 `ClientHttpResponseBodyExtractor`를 제공하므로, `ClientHttpResponse` 자체를 직접 생성하거나, 기타 다른 커스텀 로직을 만들 수 있다 (다운스트림).

5.2 버전부터 `WebFluxRequestExecutingMessageHandler`는 요청 메시지 페이로드로 리액티브 `Publisher`, `Resource`, `MultiValueMap` 타입을 지원한다. `WebClient.RequestBodySpec`에 값을 채울 때는 내부적으로 각자에 맞는 `BodyInserter`를 사용한다. 페이로드가 리액티브 `Publisher`인 경우, 설정해둔 `publisherElementType`이나 `publisherElementTypeExpression`을 사용해서 publisher의 요소 타입을 결정할 수 있다. 이때 표현식은 반드시 대상 `Class<?>`나 `String`(`Class<?>`로 치환된다), 또는 `ParameterizedTypeReference`로 리졸브되어야 한다.

5.5 버전부터 `WebFluxRequestExecutingMessageHandler`는 `expectedResponseType`이나 `replyPayloadToFlux` 설정에 관계 없이, 응답 메시지 페이로드로 단순히 응답 body를 반환하거나 `ResponseEntity`를 통으로 반환할 수 있는 플래그 `extractResponseBody`를 제공한다 (디폴트는 `true`다). `ResponseEntity` 안에 body가 없으면 이 플래그는 무시하고 전체 `ResponseEntity`를 반환한다.

다른 설정 옵션들은  [HTTP 아웃바운드 구성 요소](../http/#212-http-outbound-components)를 참고해라.

---

## 39.4. WebFlux Header Mappings

WebFlux 구성 요소들은 전적으로 HTTP 프로토콜을 기반으로 동작하기 때문에, HTTP 헤더 매핑 역시 동일하다. 헤더 매핑에 사용할 수 있는 다른 옵션이나 구성 요소는 [HTTP 헤더 매핑](../http/#217-http-header-mappings)을 참고해라.