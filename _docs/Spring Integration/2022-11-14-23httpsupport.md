---
title: HTTP Support
category: Spring Integration
order: 23
permalink: /Spring%20Integration/http/
description: 메시지를 통해 HTTP 요청을 전송하고, HTTP 요청을 받아 메시지 플로우에 연결하기
image: ./../../images/springintegration/http-inbound-gateway.png
lastmod: 2022-11-14T22:00:00+09:00
comments: true
originalRefName: 스프링 인티그레이션
originalRefLink: https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/index-single.html#http
parent: Integration Endpoints
parentUrl: /Spring%20Integration/integration-endpoints/
---
<script>defaultLanguages = ['maven']</script>

---

 Spring Integration은 HTTP를 지원하기 때문에, HTTP 요청을 실행하거나, HTTP 요청을 받아 무언가를 처리할 수 있다. HTTP 지원은 게이트웨이 구현체, `HttpInboundEndpoint`와 `HttpRequestExecutingMessageHandler`로 이루어진다. [WebFlux 지원](../webflux)도 함께 참고해라.

프로젝트에는 아래 의존성을 추가해야 한다:

<div class="switch-language-wrapper maven gradle">
<span class="switch-language maven">Maven</span>
<span class="switch-language gradle">Gradle</span>
</div>
<div class="language-only-for-maven maven gradle"></div>
```xml
<dependency>
    <groupId>org.springframework.integration</groupId>
    <artifactId>spring-integration-http</artifactId>
    <version>5.5.15</version>
</dependency>
```
<div class="language-only-for-gradle maven gradle"></div>
```groovy
compile "org.springframework.integration:spring-integration-http:5.5.15"
```

타겟 서블릿 컨테이너는 반드시 `javax.servlet:javax.servlet-api` 의존성을 가지고 있어야 한다.

### 목차

- [21.1. Http Inbound Components](#211-http-inbound-components)
  + [21.1.1. Payload Validation](#2111-payload-validation)
- [21.2. HTTP Outbound Components](#212-http-outbound-components)
  + [21.2.1. Using HttpRequestExecutingMessageHandler](#2121-using-httprequestexecutingmessagehandler)
  + [21.2.2. Using Cookies](#2122-using-cookies)
- [21.3. HTTP Namespace Support](#213-http-namespace-support)
  + [21.3.1. Inbound](#2131-inbound)
  + [21.3.2. Request Mapping Support](#2132-request-mapping-support)
  + [21.3.3. Cross-origin Resource Sharing (CORS) Support](#2133-cross-origin-resource-sharing-cors-support)
  + [21.3.4. Response Status Code](#2134-response-status-code)
  + [21.3.5. URI Template Variables and Expressions](#2135-uri-template-variables-and-expressions)
  + [21.3.6. Outbound](#2136-outbound)
  + [21.3.7. Mapping URI Variables](#2137-mapping-uri-variables)
  + [21.3.8. Controlling URI Encoding](#2138-controlling-uri-encoding)
- [21.4. Configuring HTTP Endpoints with Java](#214-configuring-http-endpoints-with-java)
- [21.5. Timeout Handling](#215-timeout-handling)
  - [21.5.1. HTTP Outbound Gateway](#2151-http-outbound-gateway)
  - [21.5.2. HTTP Inbound Gateway](#2152-http-inbound-gateway)
- [21.6. HTTP Proxy configuration](#216-http-proxy-configuration)
  + [21.6.1. Standard Java Proxy configuration](#2161-standard-java-proxy-configuration)
  + [21.6.2. Spring’s SimpleClientHttpRequestFactory](#2162-springs-simpleclienthttprequestfactory)
- [21.7. HTTP Header Mappings](#217-http-header-mappings)
- [21.8. Integration Graph Controller](#218-integration-graph-controller)
- [21.9. HTTP Samples](#219-http-samples)
  + [21.9.1. Multipart HTTP Request — RestTemplate (Client) and Http Inbound Gateway (Server)](#2191-multipart-http-requestresttemplate-client-and-http-inbound-gateway-server)

---

## 21.1. Http Inbound Components

HTTP를 통해 메시지를 수신하려면 HTTP 인바운드 채널 어댑터나 HTTP 인바운드 게이트웨이를 이용해야 한다. 그러려면 [Apache Tomcat](https://tomcat.apache.org/)이나 [Jetty](https://www.eclipse.org/jetty/)같은 서블릿 컨테이너 안에 HTTP 인바운드 어댑터를 배포해야 한다. 가장 쉽게는 스프링의 [`HttpRequestHandlerServlet`](https://docs.spring.io/spring/docs/current/javadoc-api/org/springframework/web/context/support/HttpRequestHandlerServlet.html)을 사용해 `web.xml` 파일에 아래와 같이 서블릿을 정의할 수 있다:

```xml
<servlet>
    <servlet-name>inboundGateway</servlet-name>
    <servlet-class>o.s.web.context.support.HttpRequestHandlerServlet</servlet-class>
</servlet>
```

서블릿의 이름이 빈 이름과 일치하는 것에 주목해라. `HttpRequestHandlerServlet`에 대한 자세한 내용은 스프링 프레임워크 레퍼런스 문서에서 [스프링을 이용한 원격 처리와 웹 서비스](https://docs.spring.io/spring/docs/current/spring-framework-reference/html/remoting.html)를 확인해봐라.

스프링 MVC 애플리케이션을 개발하고 있다면, 위에서 보여준대로 서블릿을 직접 정의할 필요는 없다. 이 경우 게이트웨이 빈의 이름은 스프링 MVC 컨트롤러 빈에서처럼 URL 경로로 매칭시킬 수 있다. 자세한 내용은 스프링 프레임워크 레퍼런스 문서에 있는 [웹 MVC 프레임워크](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc)를 참고해라.

> 샘플 애플리케이션과 거기 필요한 설정들은 [Spring Integration Samples](https://github.com/spring-projects/spring-integration-samples) 레포지토리를 참고해라. 이곳에선 Spring Integration의 HTTP 지원을 활용한 [HTTP 샘플](https://github.com/spring-projects/spring-integration-samples/tree/main/basic/http) 애플리케이션도 확인할 수 있다.

다음은 HTTP 인바운드 엔드포인트를 정의하는 빈 예시다:

```xml
<bean id="httpInbound"
  class="org.springframework.integration.http.inbound.HttpRequestHandlingMessagingGateway">
  <property name="requestChannel" ref="httpRequestChannel" />
  <property name="replyChannel" ref="httpReplyChannel" />
</bean>
```

`HttpRequestHandlingMessagingGateway`는 `HttpMessageConverter` 인스턴스 리스트를 설정할 수도 있고, 디폴트 리스트를 사용해도 좋다. 이 컨버터를 사용하면 `HttpServletRequest`로부터 `Message`를 매핑하는 일을 커스텀할 수 있다. 디폴트 컨버터들은 컨텐츠 타입이 `text`로 시작하는 `POST` 요청에 대해 `String` 메시지를 생성하는 간단한 전략들을 캡슐화하고 있다. 좀 더 자세한 내용은 [Javadoc](https://docs.spring.io/spring-integration/api/index.html)을 참고해라. 커스텀 컨버터 뒤에 디폴트 컨버터들도 추가하려면, 커스텀 `HttpMessageConverter` 목록과는 별도로 플래그(`mergeWithDefaultConverters`)를 설정해주면 된다. 이 플래그의 기본값은 `false`로, 커스텀 컨버터를 추가하면 디폴트 목록을 대체해버린다.

메시지를 변환할 때는 (optional) `requestPayloadType` 프로퍼티와 전달받은 `Content-Type` 헤더를 활용한다. 4.3 버전부터는 요청에 컨텐츠 타입 헤더가 없으면 `RFC 2616`에서 권장하는 대로 `application/octet-stream`을 가정한다. 이전에는 이런 메시지에 있는 body는 무시했었다.

Spring Integration 2.0은 멀티파트 파일도 구현하고 있다. 디폴트 컨버터들을 사용할 때 `MultipartHttpServletRequest`로 감싸진 요청을 받으면, 이 요청을 `Message` 페이로드로 변환할 땐 `MultiValueMap`을 생성한다. 이 `MultiValueMap`은 각 파트의 컨텐츠 타입에 따라 바이트 배열이나 문자열, 또는 스프링의 `MultipartFile` 인스턴스를 값으로 가지고 있다.

> HTTP 인바운드 엔드포인트에선 컨텍스트에 이름이 `multipartResolver`인 빈이 있다면 그 빈을 가져온다 (스프링의 `DispatcherServlet`에서 사용하는 이름과 동일하다). 이 빈을 가져오고 나면 인바운드 request 매퍼의 멀티파트 파일 지원이 활성화된다. 멀티파트 파일 지원을 활성화하지 않은 채로 멀티파트 파일 요청을 Spring Integration의 `Message`에 매핑하려고 하면 에러가 발생한다. 스프링의 `MultipartResolver` 지원에 대한 자세한 내용은 [스프링 레퍼런스 매뉴얼](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-multipart)을 참고해라.

> `multipart/form-data` 요청을 다른 서버로 전달만하는 프록시를 원한다면, 원래 형식을 그대로 유지하는 것이 좋다. 그러려면 컨텍스트에 `multipartResolver` 빈을 추가하지 않아야 한다. 엔드포인트에선 `byte[]` 요청을 받도록 구성하고, 메시지 컨버터를 커스텀해 `ByteArrayHttpMessageConverter`를 추가하고, 디폴트 멀티파트 컨버터를 비활성화해라. 응답을 전송하기 위한 다른 컨버터도 필요할 수 있다. 아래 예시를 참고해라:
>
> ```xml
> <int-http:inbound-gateway
>                channel="receiveChannel"
>                path="/inboundAdapter.htm"
>                request-payload-type="byte[]"
>                message-converters="converters"
>                merge-with-default-converters="false"
>                supported-methods="POST" />
> 
> <util:list id="converters">
>  <beans:bean class="org.springframework.http.converter.ByteArrayHttpMessageConverter" />
>  <beans:bean class="org.springframework.http.converter.StringHttpMessageConverter" />
>  <beans:bean class="org.springframework.http.converter.json.MappingJackson2HttpMessageConverter" />
> </util:list>
> ```

클라이언트에 응답을 전송할 때는, 다양한 방법으로 게이트웨이의 동작을 커스텀할 수 있다. 기본적으로 게이트웨이는 status code `200`을 돌려보냄으로써 요청을 잘 받았음을 알린다. 이때 보내는 응답은 스프링 MVC `ViewResolver`로 리졸브하는 'viewName'을 제공해서 커스텀할 수 있다. 게이트웨이가 `Message`를 전송한 뒤 응답을 받아야 한다면, `expectReply` 플래그(생성자 인자)를 설정하면 HTTP 응답을 생성하기 전에 reply `Message`를 기다리게 만들 수 있다. 다음은 view name을 이용해 스프링 MVC 컨트롤러처럼 요청을 서빙하는 게이트웨이를 설정하는 예시다:

```xml
<bean id="httpInbound"
  class="org.springframework.integration.http.inbound.HttpRequestHandlingController">
  <constructor-arg value="true" /> <!-- indicates that a reply is expected -->
  <property name="requestChannel" ref="httpRequestChannel" />
  <property name="replyChannel" ref="httpReplyChannel" />
  <property name="viewName" value="jsonView" />
  <property name="supportedMethodNames" >
    <list>
      <value>GET</value>
      <value>DELETE</value>
    </list>
  </property>
</bean>
```

여기서는 `constructor-arg` 값이 `true`이기 때문에 응답을 기다린다. 위 예제를 보면 게이트웨이에서 허용할 HTTP 메소드를 커스텀하는 방법도 알 수 있다 (기본값은 `POST`와 `GET`이다).

model 맵 안에는 응답 메시지가 담겨있다. 기본적으로 응답 메시지는 'reply'란 키로 저장하지만, 엔드포인트를 구성할 때 'replyKey' 프로퍼티를 설정하면 기본값을 재정의할 수 있다.

### 21.1.1. Payload Validation

5.2 버전부터 HTTP 인바운드 엔드포인트에 `Validator`를 함께 설정하면 채널로 메시지를 전송하기 전에 페이로드를 검증할 수 있다. 이때 페이로드는 `payloadExpression`을 적용해서 변환과 추출을 마친 값으로, 진짜 필요한 데이터만 검증할 수 있다. 유효성 검사에 실패했을 때의 처리 동작은 스프링 MVC의 [에러 핸들링](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-exceptionhandlers)과 완전히 동일하다.

---

## 21.2. HTTP Outbound Components

이번 섹션에선 Spring Integration의 HTTP 아웃바운드 컴포넌트들을 설명한다.

### 21.2.1. Using `HttpRequestExecutingMessageHandler`

`HttpRequestExecutingMessageHandler`를 설정할 땐 다음과 같은 빈을 정의하면 된다:

```xml
<bean id="httpOutbound"
  class="org.springframework.integration.http.outbound.HttpRequestExecutingMessageHandler">
  <constructor-arg value="http://localhost:8080/example" />
  <property name="outputChannel" ref="responseChannel" />
</bean>
```

여기서 정의한 빈은 `RestTemplate`에 HTTP 요청을 위임한다. `RestTemplate`은 가지고 있는 `HttpMessageConverter` 인스턴스 목록에 차례대로 위임해서 `Message` 페이로드로부터 HTTP 요청에 사용할 body를 생성한다. 이때 사용할 컨버터나 `ClientHttpRequestFactory` 인스턴스는 다음과 같이 설정할 수 있다:

```xml
<bean id="httpOutbound"
  class="org.springframework.integration.http.outbound.HttpRequestExecutingMessageHandler">
  <constructor-arg value="http://localhost:8080/example" />
  <property name="outputChannel" ref="responseChannel" />
  <property name="messageConverters" ref="messageConverterList" />
  <property name="requestFactory" ref="customRequestFactory" />
</bean>
```

HTTP 요청은 기본적으로 JDK `HttpURLConnection`을 사용하는 `SimpleClientHttpRequestFactory` 인스턴스를 통해 생성한다. (앞에서 보여준 방법대로) `CommonsClientHttpRequestFactory`를 주입하면 Apache Commons HTTP 클라이언트도 이용할 수 있다.

> 아웃바운드 게이트웨이의 경우, 게이트웨이에서 생성하는 응답 메시지엔 요청 메시지에 존재하는 모든 메시지 헤더가 담긴다.

### 21.2.2. Using Cookies

기본적인 쿠키는 아웃바운드 게이트웨이의 `transfer-cookies` 속성을 통해 지원한다. `true`로 설정하면 (기본값은 `false`다), 서버로부터 수신한 `Set-Cookie` 헤더를 응답 메시지에선 `Cookie`라는 헤더로 변환한다. 이후 메시지를 전송할 때 이 헤더를 활용하면 다음과 같이 간단한 상태를 활용한<sup>stateful</sup> 상호 작용이 가능해진다:

```
…→logonGateway→…→doWorkGateway→…→logoffGateway→…
```

`transfer-cookies`가 `false`이면, 응답 메시지에도 수신한 모든 `Set-Cookie` 헤더가 그대로 남아 있으며, 이후 메시즈를 전송할 때 제거된다.

> <span id="empty-response-bodies"></span>**Empty Response Bodies**
>
> HTTP는 요청-응답 프로토콜이다. 하지만 응답에는 body 없이 헤더만 존재할 수도 있다. 이 경우 `HttpRequestExecutingMessageHandler`는 지정한 `expected-response-type`에 관계없이 `org.springframework.http.ResponseEntity`를 페이로드로 가지고 있는 응답 `Message`를 생성한다. [HTTP RFC 상태 코드 정의](https://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html)에 따르면 응답에 message-body가 포함되지 않아야 하는 상태 코드도 다양하다 (ex. `204 No Content`). 그 외에도, 같은 URL을 호출했을 때 어떨 땐 응답 body를 반환하고 어떨 땐 반환하지 않는 경우도 있다. 예를 들어 특정 HTTP 리소스에 처음으로 요청을 보내면 컨텐츠를 반환하지만 두 번째 요청부턴 컨텐츠를 반환하지 않을 수 있다 (`304 Not Modified`). 하지만 어떤 경우라도 메시지 헤더 `http_statusCode`는 채워진다. HTTP 아웃바운드 게이트웨이 이후 실행하는 라우팅 로직이 있다면 이 값을 활용해도 좋다. `<payload-type-router/>`를 사용하면 `ResponseEntity`를 가지고 있는 메시지를, body가 있는 응답과는 다른 플로우로 라우팅할 수도 있다.

> **expected-response-type**
>
> 앞의 내용에 조금 덧붙이자면, 응답에 body가 포함된 경우엔 반드시 적절한 `expected-response-type` 속성을 제공해야 한다. 그렇지 않으면 body가 없는 `ResponseEntity`를 돌려받게 된다. `expected-response-type`은 반드시 `HttpMessageConverter` 인스턴스(직접 설정했든, 디폴트 컨버터를 사용하던지 관계 없이)와 응답의 `Content-Type` 헤더와 호환돼야 한다. 여기에는 추상 클래스를 사용할 수도 있고, 인터페이스여도 상관 없다 (예를 들어 자바 직렬화와 `Content-Type: application/x-java-serialized-object`를 사용한다면 `java.io.Serializable`일 수 있다).

5.5 버전부터 `HttpRequestExecutingMessageHandler`는 `extractResponseBody` 플래그에 따라 (기본값은 `true`다), `expectedResponseType`과는 상관 없이 응답 메시지 페이로드로 `ResponseEntity`를 통째로 반환하거나, 응답 body만 반환할 수 있다. `ResponseEntity` 안에 body가 없으면 이 플래그는 무시하고 전체 `ResponseEntity`를 반환한다.

---

## 21.3. HTTP Namespace Support

Spring Integration은 `http` 네임스페이스와 전용 스키마 정의를 제공하고 있다. 설정에 포함시키려면 애플리케이션 컨텍스트 설정 파일에 아래와 같은 네임스페이스를 선언해주면 된다:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:int="http://www.springframework.org/schema/integration"
  xmlns:int-http="http://www.springframework.org/schema/integration/http"
  xsi:schemaLocation="
    http://www.springframework.org/schema/beans
    https://www.springframework.org/schema/beans/spring-beans.xsd
    http://www.springframework.org/schema/integration
    https://www.springframework.org/schema/integration/spring-integration.xsd
    http://www.springframework.org/schema/integration/http
    https://www.springframework.org/schema/integration/http/spring-integration-http.xsd">
    ...
</beans>
```

### 21.3.1. Inbound

XML 네임스페이스에선 HTTP 인바운드 요청을 처리하기 위한 두 가지 컴포넌트, `inbound-channel-adapter`와 `inbound-gateway`를 제공한다. 별도 응답을 반환하지 않고 요청을 처리하려면 `inbound-channel-adapter`를 사용해라. 설정 방법은 아래 예시를 참고해라:

```xml
<int-http:inbound-channel-adapter id="httpChannelAdapter" channel="requests"
    supported-methods="PUT, DELETE"/>
```

응답이 필요한 요청을 처리하려면 `inbound-gateway`를 사용해라. 설정 방법은 아래 예시를 참고해라:

```xml
<int-http:inbound-gateway id="inboundGateway"
    request-channel="requests"
    reply-channel="responses"/>
```

### 21.3.2. Request Mapping Support

> Spring Integration 3.0에선 [`IntegrationRequestMappingHandlerMapping`](https://docs.spring.io/spring-integration/api/org/springframework/integration/http/inbound/IntegrationRequestMappingHandlerMapping.html)을 도입해서 REST 지원을 좀 더 개선했다. 이 구현체는 스프링 프레임워크 3.1에서 개선시킨 REST 기능을 이용한다. 

HTTP 인바운드 게이트웨이나 HTTP 인바운드 채널 어댑터를 파싱할 땐, `integrationRequestMappingHandlerMapping` 빈이 등록되어 있지 않으면 [`IntegrationRequestMappingHandlerMapping`](https://docs.spring.io/spring-integration/api/org/springframework/integration/http/inbound/IntegrationRequestMappingHandlerMapping.html) 타입 빈을 하나 등록한다. 이 클래스는 [`HandlerMapping`](https://docs.spring.io/spring/docs/current/javadoc-api/org/springframework/web/servlet/HandlerMapping.html)의 구현체로, [`RequestMappingInfoHandlerMapping`](https://docs.spring.io/spring/docs/current/javadoc-api/org/springframework/web/servlet/mvc/method/RequestMappingInfoHandlerMapping.html)에 로직을 위임한다. 이 구현체는 스프링 MVC의 어노테이션 [`org.springframework.web.bind.annotation.RequestMapping`](https://docs.spring.io/spring/docs/current/javadoc-api/org/springframework/web/bind/annotation/RequestMapping.html)과 유사한 기능을 제공한다.

> 자세한 정보는 [`@RequestMapping`을 통해 요청 매핑하기](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-ann-requestmapping)를 확인해봐라.

Spring Integration 3.0에선 요청 매핑을 위한 `<request-mapping>` 요소를 도입했다. 이 요소는 생략할 수 있으며, `<http:inbound-channel-adapter>`와 `<http:inbound-gateway>`에 추가할 수 있다. 동작할 땐 `path` 속성과 `supported-methods` 속성과 함께 동작한다. 다음은 인바운드 게이트웨이 안에 설정을 추가하는 예시다:

```xml
<inbound-gateway id="inboundController"
    request-channel="requests"
    reply-channel="responses"
    path="/foo/{fooId}"
    supported-methods="GET"
    view-name="foo"
    error-code="oops">
   <request-mapping headers="User-Agent"
     params="myParam=myValue"
     consumes="application/json"
     produces="!text/plain"/>
</inbound-gateway>
```

위 설정에선 네임스페이스 파서는 `IntegrationRequestMappingHandlerMapping`(없으면)과 `HttpRequestHandlingController` 빈 인스턴스를 생성하고 [`RequestMapping`](https://docs.spring.io/spring-integration/api/org/springframework/integration/http/inbound/RequestMapping.html) 인스턴스에 연결한다. 이 `RequestMapping` 인스턴스는 결국 스프링 MVC의 [`RequestMappingInfo`](https://docs.spring.io/spring/docs/current/javadoc-api/org/springframework/web/servlet/mvc/method/RequestMappingInfo.html)로 변환된다.

`<request-mapping>` 요소는 다음과 같은 속성들을 제공한다:

- `headers`
- `params`
- `consumes`
- `produces`

`<http:inbound-channel-adapter>`, `<http:inbound-gateway>`에 `path` 속성과 `supported-methods` 속성을 사용하면, `<request-mapping>` 속성들은 스프링 MVC의 `org.springframework.web.bind.annotation.RequestMapping` 어노테이션이 제공하는 각각의 옵션들로 직접 변환된다.

`<request-mapping>` 요소를 활용하면 여러 개의 Spring Integration HTTP 인바운드 엔드포인트를 동일한 `path`로 구성하고 (심지어는 `supported-methods`도 동일하게), 들어오는 HTTP 요청을 기반으로 서로 다른 다운스트림 메시지 플로우를 제공할 수 있다.

아니면 HTTP 인바운드 엔드포인트는 하나만 선언하고 Spring Integration 플로우 내에서 라우팅과 필터링 로직을 적용해도 같은 결과를 얻을 수 있다. 이렇게 하면 준비되는 즉시 플로우로 `Message`를 가져올 수 있다. 다음은 그 방법을 보여주는 예시다:

```xml
<int-http:inbound-gateway request-channel="httpMethodRouter"
    supported-methods="GET,DELETE"
    path="/process/{entId}"
    payload-expression="#pathVariables.entId"/>

<int:router input-channel="httpMethodRouter" expression="headers.http_requestMethod">
    <int:mapping value="GET" channel="in1"/>
    <int:mapping value="DELETE" channel="in2"/>
</int:router>

<int:service-activator input-channel="in1" ref="service" method="getEntity"/>

<int:service-activator input-channel="in2" ref="service" method="delete"/>
```

핸들러 매핑에 대한 자세한 내용은 [스프링 프레임워크 웹 서블릿 문서](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html)나 [스프링 프레임워크  웹 리액티브 문서](../../Reactive%20Spring/contents/)를 참고해라.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p><code class="highlighter-rouge">IntegrationRequestMappingHandlerMapping</code>은 스프링 MVC의 <code class="highlighter-rouge">RequestMappingHandlerMapping</code> 클래스를 확장한 것이기 때문에, 대부분의 로직을 상속한다. 특히 어떠한 이유로 매핑 정보를 찾을 수 없을 때 <code class="highlighter-rouge">4XX</code> 응답으로 에러를 던지는 <code class="highlighter-rouge">handleNoMatch(Set, String, HttpServletRequest)</code>도 마찬가지다. 그 덕분에 애플리케이션 컨텍스트에 있는 나머지 매핑 핸들러는 호출하지 않는다. 그렇기 때문에 Spring Integration과 스프링 MVC에 동일한 요청 path를 매핑하는 세팅은 지원하지 않는다 (e.g. 하나는 <code class="highlighter-rouge">POST</code>이고 다른 하나는 <code class="highlighter-rouge">GET</code>). 같은 path를 설정했더라도 MVC 매핑 정보는 조회할 수 없을 거다.</p>
</blockquote>


### 21.3.3. Cross-origin Resource Sharing (CORS) Support

4.2 버전부터 `<http:inbound-channel-adapter>`와 `<http:inbound-gateway>`는 `<cross-origin>` 요소를 함께 설정할 수 있다. `<cross-origin>`은 `@Controller` 어노테이션에 사용하는 스프링 MVC의 `@CrossOrigin`과 동일한 옵션을 가지고 있으며, Spring Integration HTTP 엔드포인트에 CORS<sup>Cross-Origin Resource Sharing</sup>를 설정해준다:

- `origin`: 허용할 출처 목록. `*`는 모든 출처를 허용함을 의미한다. 이 값들은 pre-flight 응답과 실제 응답의 `Access-Control-Allow-Origin` 헤더에 배치된다. 기본값은 `*`다.
- `allowed-headers`: 실제 요청에서 사용할 수 있는 요청 헤더를 나타낸다. `*`는 클라이언트가 요청한 모든 헤더를 허용함을 의미한다. 이 프로퍼티에 따라 pre-flight 응답의 `Access-Control-Allow-Headers` 헤더 값이 달라진다. 기본값은 `*`다.
- `exposed-headers`: user-agent에서 클라이언트가 접근할 수 있도록 허용하는 응답 헤더 목록. 이 프로퍼티에 따라 실제 응답의 `Access-Control-Expose-Headers` 헤더 값이 달라진다.
- `method`: 허용할 HTTP 요청 메소드 (`GET`, `POST`, `HEAD`, `OPTIONS`, `PUT`, `PATCH`, `DELETE`, `TRACE`). 여기에 메소드를 지정하면 `supported-methods`에 있는 값을 덮어쓴다.
- `allow-credentials`: 브라우저가 요청 도메인과 관련 있는 쿠키를 포함시켜야 한다면 `true`로, 그렇지 않으면 `false`로 설정한다. 빈 문자열("")은 undefined를 의미한다. `true`로 설정하면 pre-flight 응답에 `Access-Control-Allow-Credentials=true` 헤더가 추가된다. 기본값은 `true`다.
- `max-age`: pre-flight 응답을 캐시에 저장해둘 기간을 지정한다. 이 값을 잘만 설정하면 브라우저에서 요구하는 pre-flight 요청-응답 상호작용 횟수를 줄일 수 있다. 이 프로퍼티에 따라 pre-flight 응답의 `Access-Control-Max-Age` 헤더 값이 달라진다. `-1`은 undefined를 의미한다. 기본값은 1800초다 (30분).

자바에서 CORS 설정은 `org.springframework.integration.http.inbound.CrossOrigin` 클래스로 표현하며, `CrossOrigin` 인스턴스는 `HttpRequestHandlingEndpointSupport` 빈에 주입할 수 있다.

### 21.3.4. Response Status Code

`<http:inbound-channel-adapter>`는 4.1 버전부터 `status-code-expression`을 설정해서 디폴트 `200 OK` status를 재정의할 수 있다. 여기 사용하는 표현식은 반드시 enum `org.springframework.http.HttpStatus`로 변환 가능한 객체를 반환해야 한다. `evaluationContext`는 `BeanResolver`를 가지고 있으며, 5.1부터는 `RequestEntity<?>`를 루트 객체로 함께 제공한다. 표현식을 활용하면 특정 스코프에 속해있는, status code를 반환하는 빈을 런타임에 리졸브할 수 있다. 하지만 보통은 `status-code=expression="204"`(No Content)나 `status-code-expression="T(org.springframework.http.HttpStatus).NO_CONTENT"`와 같이 고정 값을 설정하는 경우가 많다. `status-code-expression`의 기본값은 null로, 일반 '200 OK' 응답을 반환한다. `RequestEntity<?>`를 루트 객체로 사용하면 status code를 요청 메소드, 헤더, URI 컨텐츠, 심지어는 요청 body에 따라서도 다르게 설정할 수 있다. 다음은 status code를 `ACCEPTED`로 설정하는 예시다:

```xml
<http:inbound-channel-adapter id="inboundController"
       channel="requests" view-name="foo" error-code="oops"
       status-code-expression="T(org.springframework.http.HttpStatus).ACCEPTED">
   <request-mapping headers="BAR"/>
</http:inbound-channel-adapter>
```

`<http:inbound-gateway>`는 응답 `Message`에 있는 `http_statusCode` 헤더를 이용해 'status code'를 리졸브한다. 4.2부터 `reply-timeout` 내에 응답을 받지 못하면 `500 Internal Server Error`를 디폴트 응답 status code로 사용한다. 이 동작은 두 가지 방법으로 변경할 수 있다:

- `reply-timeout-status-code-expression`을 추가해라. 인바운드 어댑터의 `status-code-expression`과 같은 방식으로 활용할 수 있다.

- 다음과 같이 `error-channel`을 추가하고 HTTP status code 헤더를 가진 적당한 메시지를 반환해라:

  ```xml
  <int:chain input-channel="errors">
      <int:header-enricher>
          <int:header name="http_statusCode" value="504" />
      </int:header-enricher>
      <int:transformer expression="payload.failedMessage" />
  </int:chain>
  ```

`ErrorMessage`의 페이로드에는 `MessageTimeoutException`이 담긴다. `MessageTimeoutException`은 `String`과 같이 게이트웨이에서 HTTP 응답으로 컨버팅할 수 있는 것으로 변환해야 한다. `expression`을 활용할 때처럼 exception의 message 프로퍼티를 사용하는 것도 좋은 방법이다.

메인 플로우에서 타임아웃이 발생한 다음 에러 플로우 역시 타임아웃되면 `500 Internal Server Error`를 반환하며, `reply-timeout-status-code-expression`이 존재한다면 이 표현식을 평가한다.

> 이전에는 타임아웃이 발생하면 `200 OK`가 디폴트였다. 이때의 동작으로 돌아가려면 `reply-timeout-status-code-expression="200"`을 설정하면 된다.

또한 5.4 버전부터 요청 메시지를 준비하는 동안 에러가 발생하면 에러 채널(제공했다면)로 보내진다. 적당한 예외를 던질지 결정하는 일은 에러 플로우에서 예외를 확인한 뒤 진행하는 것이 좋다. 이전에는 예외가 발생하면 무조건 던져서 HTTP 500에 해당하는 서버 에러로 응답을 전송했지만, 경우에 따라서는 요청 파라미터가 잘못된 것일 수도 있기 때문에 클라이언트 에러 4xx에 해당하는 `ResponseStatusException`을 던져야 할 수도 있다. 자세한 내용은 `ResponseStatusException`을 참고해라. 에러 채널로 전송된 `ErrorMessage`의 페이로드 안에는 기존의 예외가 담겨 있어서 여기서 예외를 분석할 수 있다.

### 21.3.5. URI Template Variables and Expressions

`path` 속성을 `payload-expression` 속성이나 `header` 요소와 함께 사용하면, 인바운드 요청 데이터를 훨씬 더 유연하게 매핑할 수 있다.

아래 설정 예시에선, 다음과 같은 URI로 들어온 요청을 수락하는 인바운드 채널 어댑터를 하나 설정한다:

```none
/first-name/{firstName}/last-name/{lastName}
```

아래와 같이 `payload-expression` 속성을 정의하면, URI 템플릿 변수 `Fisher`는 메시지 헤더 `lname`에 매핑되는 반면, URI 템플릿 변수 `Mark`는 `Message` 페이로드에 매핑되게 만들 수 있다:

```xml
<int-http:inbound-channel-adapter id="inboundAdapterWithExpressions"
    path="/first-name/{firstName}/last-name/{lastName}"
    channel="requests"
    payload-expression="#pathVariables.firstName">
    <int-http:header name="lname" expression="#pathVariables.lastName"/>
</int-http:inbound-channel-adapter>
```

URI 템플릿 변수에 대해 자세히 알아보려면 스프링 레퍼런스 매뉴얼에서 [uri 템플릿 패턴](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-ann-requestmapping-uri-templates)을 찾아 읽어봐라.

페이로드와 헤더 표현식에 사용할 수 있는 기존 변수 `#pathVariables`, `#requestParams` 외에도, Spring Integration 3.0에선 다른 유용한 표현식 변수들을 추가했다:

- `#requestParams`: `ServletRequest` `parameterMap`의 `MultiValueMap`.
- `#pathVariables`: URI 템플릿 플레이스홀더와 그 값들로 만들어진 `Map`.
- `#matrixVariables`: [스프링 MVC 사양](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-ann-matrix-variables)에 따른 `MultiValueMap`의 `Map`. `#matrixVariables`는 스프링 MVC 3.2 이상이 필요하다.
- `#requestAttributes`: 현재 요청에 해당하는 `org.springframework.web.context.request.RequestAttributes`.
- `#requestHeaders`: 현재 요청으로부터 만든 `org.springframework.http.HttpHeaders` 객체.
- `#cookies`: 현재 요청으로부터 만든 `javax.servlet.http.Cookie` 인스턴스들의 `Map<String, Cookie>`.

참고로, 단일 스레드(요청 스레드)로 동작하는 메시지 플로우라면, 이 값들은 모두 다운스트림 플로우의 표현식 내에서 `ThreadLocal` `org.springframework.web.context.request.RequestAttributes` 변수를 통해 액세스할 수 있다. 다음은 `expression` 속성을 사용하는 트랜스포머 설정 예시다:

```xml
<int-:transformer
    expression="T(org.springframework.web.context.request.RequestContextHolder).
                  requestAttributes.request.queryString"/>
```

### 21.3.6. Outbound

아웃바운드 게이트웨이를 설정할 땐 네임스페이스를 이용하면 된다. 다음은 아웃바운드 HTTP 게이트웨이에서 사용할 수 있는 설정 옵션들을 나타낸 코드다:

```xml
<int-http:outbound-gateway id="example"
    request-channel="requests"
    url="http://localhost/test"
    http-method="POST"
    extract-request-payload="false"
    expected-response-type="java.lang.String"
    charset="UTF-8"
    request-factory="requestFactory"
    reply-timeout="1234"
    reply-channel="replies"/>
```

가장 중요한 속성은 'http-method'와 'expected-response-type'이다. 보통은 이 두 가지를 가장 많이 설정한다. 디폴트 `http-method`는 `POST`이며, response type은 null이 디폴트다. response type이 null일 땐 HTTP status가 성공을 나타내기만 한다면 응답 `Message`의 페이로드에 `ResponseEntity`를 담는다 (성공이 아닐 땐 예외를 던진다). `String` 등의 다른 타입을 받아야 하는 경우엔 클래스의 풀 네임<sup>fully qualified name</sup>을 지정해라 (위 예제에선 `java.lang.String`). [HTTP 아웃바운드 컴포넌트](#212-http-outbound-components)에서 다룬 [empty response bodies](#empty-response-bodies)에 대한 내용도 함께 참고해라.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>Spring Integration 2.1부터 HTTP 아웃바운드 게이트웨이의 <code class="highlighter-rouge">request-timeout</code> 속성은, 본래 의도가 더 잘 드러나도록 <code class="highlighter-rouge">reply-timeout</code>으로 이름을 변경했다.</p>
</blockquote>

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>Spring Integration 2.2 이후로 HTTP를 통한 자바 직렬화는 더 이상 기본으로 활성화되지 않는다. 이전에는 <code class="highlighter-rouge">expected-response-type</code> 속성을 <code class="highlighter-rouge">Serializable</code> 객체로 설정하면 <code class="highlighter-rouge">Accept</code> 헤더가 제대로 세팅되지 않았었다. 이제 Spring Integration 2.2부터 <code class="highlighter-rouge">Accept</code> 헤더를 <code class="highlighter-rouge">application/x-java-serialized-object</code>로 설정하도록 <code class="highlighter-rouge">SerializingHttpMessageConverter</code>를 수정했다.</p>
  <p>하지만 이로 인해 기존 애플리케이션과 호환이 안 될 수도 있으므로, 더는 <code class="highlighter-rouge">SerializingHttpMessageConverter</code>를 자동으로 HTTP 엔드포인트에 추가하지 않기로 했다. 자바 직렬화를 사용하고 싶다면 <code class="highlighter-rouge">message-converters</code> 속성이나 (XML 설정) <code class="highlighter-rouge">setMessageConverters()</code> 메소드를 이용해 (자바 설정), 적당한 엔드포인트들에 <code class="highlighter-rouge">SerializingHttpMessageConverter</code>를 추가해주면 된다. 아니면 JSON을 사용하는 것을 검토해봐도 좋다. JSON은 클래스패스에 <a href="https://github.com/FasterXML/jackson">Jackson 라이브러리</a>가 있으면 활성화된다.</p>
</blockquote>

Spring Integration 2.2부터는 SpEL과 `http-method-expression` 속성을 이용해 HTTP 메소드를 동적으로 결정할 수도 있다. 단, 이 속성은 `http-method`와는 함께 사용할 수 없다. `expected-response-type` 대신 `expected-response-type-expression` 속성을 사용해, 응답 타입을 결정할 수 있는 유효한 SpEL 표현식을 제공할 수도 있다. 아래 예시에선 `expected-response-type-expression`을 사용한다:

```xml
<int-http:outbound-gateway id="example"
    request-channel="requests"
    url="http://localhost/test"
    http-method-expression="headers.httpMethod"
    extract-request-payload="false"
    expected-response-type-expression="payload"
    charset="UTF-8"
    request-factory="requestFactory"
    reply-timeout="1234"
    reply-channel="replies"/>
```

아웃바운드 어댑터를 단방향으로 사용한다면 이 대신 `outbound-channel-adapter`를 사용하면 된다. 이땐 성공 응답을 받아도 응답 채널에 메시지를 전송하지 않는다. 응답 status code가 성공이 아닐 땐 예외를 던진다. 설정 자체는 아래 보이는 것처럼 게이트웨이와 매우 유사하다:

```xml
<int-http:outbound-channel-adapter id="example"
    url="http://localhost/example"
    http-method="GET"
    channel="requests"
    charset="UTF-8"
    extract-payload="false"
    expected-response-type="java.lang.String"
    request-factory="someRequestFactory"
    order="3"
    auto-startup="false"/>
```

> URL을 지정할 땐 'url' 이나 'url-expression' 속성을 사용할 수 있다. 'url'에는 간단한 문자열을 지정한다 (URI 변수에는 아래에서 설명하는 플레이스 홀더를 사용한다). 'url-expression'은 `Message`를 루트 객체로 사용하는 SpEL 표현식으로, url을 동적으로 결정할 수 있게 해준다. 표현식을 평가해서 얻은 URL에는 여전히 URI 변수를 위한 플레이스 홀더가 있을 수 있다.
>
> 이전 릴리즈에서는 플레이스 홀더를 이용해 URL 전체를 URI 변수로 치환하는 사용자들도 있었다. 하지만 이제는 스프링 3.1의 변경 사항으로 인해 '?'와 같이 이스케이프가 필요한 문자를 사용하면 문제가 발생할 수 있다. 따라서 런타임에 URL을 통으로 생성하려면 'url-expression' 속성을 사용하는 게 좋다.

### 21.3.7. Mapping URI Variables

사용하는 URL에 URI 변수가 들어있다면, 'uri-variable' 요소를 사용해 변수들을 매핑할 수 있다. 이 요소는 HTTP 아웃바운드 게이트웨이와 HTTP 아웃바운드 채널 어댑터에 사용할 수 있다. 다음은 URI 변수 `zipCode`를 표현식에 매핑하는 예시다:

```xml
<int-http:outbound-gateway id="trafficGateway"
    url="https://local.yahooapis.com/trafficData?appid=YdnDemo&amp;zip={zipCode}"
    request-channel="trafficChannel"
    http-method="GET"
    expected-response-type="java.lang.String">
    <int-http:uri-variable name="zipCode" expression="payload.getZip()"/>
</int-http:outbound-gateway>
```

`uri-variable` 요소에선 `name`과 `expression`이라는 두 가지 속성을 정의한다. `name` 속성으론 URI 변수의 이름을 식별한다면, `expression` 속성은 실제 값을 세팅하는 데 사용한다. `expression` 속성을 사용하면 SpEL<sup>Spring Expression Language</sup>이 가진 모든 기능을 활용할 수 있으며, 완전히 동적으로 메시지 페이로드와 헤더에 접근할 수 있다. 예를 들어, 위 설정에선 `Message`의 페이로드 객체에서 `getZip()` 메소드를 호출하고, 그 실행 결과를 'zipCode'라는 URI 변수 값으로 사용한다.

Spring Integration 3.0부터 HTTP 아웃바운드 엔드포인트들은 `uri-variables-expression` 속성을 지원하므로, 평가하고 싶은 `expression`을 지정할 수 있다. 이 표현식에선 URL 템플릿 내 모든 URI 변수 플레이스 홀더를 가지고 있는 `Map`을 만든다. 덕분에 아웃바운드 메시지에 따라 다양한 변수 표현식을 사용할 수 있다. 이 속성은 `<uri-variable/>` 요소와는 함께 사용할 수 없다. 다음은 `uri-variables-expression` 속성의 사용법을 보여주는 예시다:

```xml
<int-http:outbound-gateway
     url="https://foo.host/{foo}/bars/{bar}"
     request-channel="trafficChannel"
     http-method="GET"
     uri-variables-expression="@uriVariablesBean.populate(payload)"
     expected-response-type="java.lang.String"/>
```

`uriVariablesBean`은 다음과 같이 정의할 수 있다:

```java
public class UriVariablesBean {
    private static final ExpressionParser EXPRESSION_PARSER = new SpelExpressionParser();

    public Map<String, ?> populate(Object payload) {
        Map<String, Object> variables = new HashMap<String, Object>();
        if (payload instanceOf String.class)) {
            variables.put("foo", "foo"));
        }
        else {
            variables.put("foo", EXPRESSION_PARSER.parseExpression("headers.bar"));
        }
        return variables;
    }

}
```

> `uri-variables-expression`은 반드시 `Map`으로 평가되어야 한다. `Map`에 있는 값들은 반드시 `String`이나 `Expression`의 인스턴스여야 한다. 이 `Map`은 `ExpressionEvalMap`에 넘겨서, 아웃바운드 `Message`의 컨텍스트에서 표현식들을 사용해 URI 변수 플레이스 홀더를 리졸브한다.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p><strong>주의 사항</strong></p>
  <p><code class="highlighter-rouge">uriVariablesExpression</code> 프로퍼티를 잘 활용하면 다양한 방법으로 URI 변수를 만들 수 있다. 대부분은 위에 있는 예시처럼 매우 단순한 표현식만 사용할 거다. 하지만 <code class="highlighter-rouge">variables.put("thing1", EXPRESSION_PARSER.parseExpression(message.getHeaders().get() "thing2", String.class)));</code>와 같은 표현식을 map에 담아 반환하고, <code class="highlighter-rouge">"@uriVariablesBean.populate(#root)"</code>와 같이 설정하는 것도 가능하다. 이 표현식은 <code class="highlighter-rouge">thing2</code>라는 메시지 헤더를 통해 동적으로 제공된다. 단, 헤더는 신뢰할 수 없는 소스에서 가져온 값일 수도 있으므로, HTTP 아웃바운드 엔드포인트는 이러한 표현식들을 평가할 때 <code class="highlighter-rouge">SimpleEvaluationContext</code>를 사용한다. <code class="highlighter-rouge">SimpleEvaluationContext</code>는 SpEL 기능의 일부만 사용한다. 메시지의 출처를 신뢰할 수 있으며, 다른 SpEL 기능들을 사용하고 싶다면 아웃바운드 엔드포인트의 <code class="highlighter-rouge">trustedSpel</code> 속성을 <code class="highlighter-rouge">true</code>로 설정해라.</p>
</blockquote>


`url-expression`을 커스텀하면서 유틸리티를 사용해 URL 파라미터를 빌드, 인코딩하면 메시지별로 URI 변수 셋을 각각 동적으로 제공할 수 있다. 그 방법은 아래 예시를 참고해라:

```xml
url-expression="T(org.springframework.web.util.UriComponentsBuilder)
                           .fromHttpUrl('https://HOST:PORT/PATH')
                           .queryParams(payload)
                           .build()
                           .toUri()"
```

`queryParams()` 메소드는 인자로 `MultiValueMap<String, String>`을 받으므로, 요청을 수행하기 전에 미리 실제 URL 쿼리 파라미터 셋을 준비해두면 된다.

전체 `queryString` 역시 다음과 같이 `uri-variable`을 사용해 표현할 수 있다:

```xml
<int-http:outbound-gateway id="proxyGateway" request-channel="testChannel"
              url="http://testServer/test?{queryString}">
    <int-http:uri-variable name="queryString" expression="'a=A&amp;b=B'"/>
</int-http:outbound-gateway>
```

단, 이때는 반드시 직접 URL 인코딩을 수행해야 한다. 예를 들어 여기서는 `org.apache.http.client.utils.URLEncodedUtils#format()`을 사용할 수 있다. 앞에서처럼 `MultiValueMap<String, String>`을 수동으로 빌드했다면, 아래와 같이 자바 스트림을 사용해 `format()` 메소드의 인자 `List<NameValuePair>`로 변환할 수 있다:

```java
List<NameValuePair> nameValuePairs =
    params.entrySet()
            .stream()
            .flatMap(e -> e
                    .getValue()
                    .stream()
                    .map(v -> new BasicNameValuePair(e.getKey(), v)))
            .collect(Collectors.toList());
```

### 21.3.8. Controlling URI Encoding

기본적으로 URL 문자열은 요청을 전송하기 전에 URI 객체로 인코딩된다 ([`UriComponentsBuilder`](https://docs.spring.io/spring/docs/current/javadoc-api/org/springframework/web/util/UriComponentsBuilder.html) 참고). 하지만 비표준 URI(ex. RabbitMQ REST API)를 사용하는 경우 인코딩을 수행하는 걸 바라지 않을 수도 있다. `<http:outbound-gateway/>`와 `<http:outbound-channel-adapter/>`는 `encoding-mode` 속성을 제공한다. URL 인코딩을 비활성화하려면 이 속성을 `NONE`으로 설정하면 된다 (기본값은 `TEMPLATE_AND_VALUES`다). URL의 일부만 인코딩하고 싶다면 다음과 같이 `<uri-variable/>` 안에서 `expression`을 사용해라:

```xml
<http:outbound-gateway url="https://somehost/%2f/fooApps?bar={param}" encoding-mode="NONE">
          <http:uri-variable name="param"
            expression="T(org.apache.commons.httpclient.util.URIUtil)
                                             .encodeWithinQuery('Hello World!')"/>
</http:outbound-gateway>
```

Java DSL에선 `BaseHttpMessageHandlerSpec.encodingMode()`를 통해 이 옵션을 제어할 수 있다. [WebFlux 모듈](../webflux)과 [웹 서비스 모듈](https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/ws.html#ws)에 있는 아웃바운드 구성 요소들에도 같은 설정을 적용할 수 있다. 훨씬 더 복잡한 케이스엔 외부에서 `RestTemplate`을 제공하고 `UriTemplateHandler`를 설정하는 것이 좋다 (WebFlux의 경우 `UriBuilderFactory`와 `WebClient`).

---

## 21.4. Configuring HTTP Endpoints with Java

다음은 Java 코드로 인바운드 게이트웨이를 설정하는 예시다:

**Example 5. 자바 설정을 이용한 인바운드 게이트웨이**

```java
@Bean
public HttpRequestHandlingMessagingGateway inbound() {
    HttpRequestHandlingMessagingGateway gateway =
        new HttpRequestHandlingMessagingGateway(true);
    gateway.setRequestMapping(mapping());
    gateway.setRequestPayloadType(String.class);
    gateway.setRequestChannelName("httpRequest");
    return gateway;
}

@Bean
public RequestMapping mapping() {
    RequestMapping requestMapping = new RequestMapping();
    requestMapping.setPathPatterns("/foo");
    requestMapping.setMethods(HttpMethod.POST);
    return requestMapping;
}
```

다음은 Java DSL을 사용해 인바운드 게이트웨이를 설정하는 예시다:

**Example 6. Java DSL을 이용한 인바운드 게이트웨이**

```java
@Bean
public IntegrationFlow inbound() {
    return IntegrationFlows.from(Http.inboundGateway("/foo")
            .requestMapping(m -> m.methods(HttpMethod.POST))
            .requestPayloadType(String.class))
        .channel("httpRequest")
        .get();
}
```

다음은 Java 코드로 아웃바운드 게이트웨이를 설정하는 예시다:

**Example 7. 자바 설정을 이용한 아웃바운드 게이트웨이**

```java
@ServiceActivator(inputChannel = "httpOutRequest")
@Bean
public HttpRequestExecutingMessageHandler outbound() {
    HttpRequestExecutingMessageHandler handler =
        new HttpRequestExecutingMessageHandler("http://localhost:8080/foo");
    handler.setHttpMethod(HttpMethod.POST);
    handler.setExpectedResponseType(String.class);
    return handler;
}
```

다음은 Java DSL을 사용해 아웃바운드 게이트웨이를 설정하는 예시다:

**Example 8. Java DSL을 이용한 아웃바운드 게이트웨이**

```java
@Bean
public IntegrationFlow outbound() {
    return IntegrationFlows.from("httpOutRequest")
        .handle(Http.outboundGateway("http://localhost:8080/foo")
            .httpMethod(HttpMethod.POST)
            .expectedResponseType(String.class))
        .get();
}
```

---

## 21.5. Timeout Handling

HTTP 구성 요소와 관련해서는 두 가지 타이밍을 고려해봐야 한다:

- Spring Integration 채널과 상호 작용하는 도중 타임아웃 발생
- 원격 HTTP 서버와 상호 작용하는 도중 타임아웃 발생

이 구성 요소들은 메시지 채널과도 상호 작용하는데, 메시지 채널은 타임아웃을 지정할 수 있다. 예를 들어, HTTP 인바운드 게이트웨이는 연결된 HTTP 클라이언트에서 수신한 메시지를 메시지 채널(request 타임아웃 사용)로 전달하고, 그 결과, 응답 채널(reply 타임아웃 사용)에서 HTTP 응답을 생성하는 데 사용하는 응답 메시지를 받아간다. 다음은 이 흐름 시각적으로 나타낸 그림이다:

![http inbound gateway](/images/springintegration/http-inbound-gateway.png){: .center-image }

**Figure 8. HTTP 인바운드 게이트웨이에서 타임아웃 설정이 적용되는 방식**

아웃바운드 엔드포인트의 경우, 원격 서버와 상호 작용하는 동안에 타이밍이 어떻게 동작할지를 생각해봐야 한다. 다음은 이 시나리오를 보여주는 이미지다:

![http outbound gateway](/images/springintegration/http-outbound-gateway.png){: .center-image }

**Figure 9. 아웃바운드 게이트웨이에서 타임아웃 설정이 적용되는 방식**

HTTP 아웃바운드 게이트웨이나 HTTP 아웃바운드 채널 어댑터를 사용해 HTTP 요청을 수행할 때는, HTTP 관련 타임아웃 동작을 설정해주고 싶을 수 있다. 참고로, 이 두 가지는 스프링의 [`RestTemplate`](https://docs.spring.io/spring/docs/current/javadoc-api/org/springframework/web/client/RestTemplate.html)을 사용해 HTTP 요청을 실행한다.

HTTP 아웃바운드 게이트웨이와 HTTP 아웃바운드 채널 어댑터에 타임아웃을 설정하려면 `RestTemplate` 빈을 직접 참조하거나 (`rest-template` 속성) [`ClientHttpRequestFactory`](https://docs.spring.io/spring/docs/current/javadoc-api/org/springframework/http/client/ClientHttpRequestFactory.html) 빈에 대한 참조를 제공하면 된다 (`request-factory` 속성). 스프링은 다음과 같은 `ClientHttpRequestFactory` 인터페이스 구현체들을 제공한다:

- [`SimpleClientHttpRequestFactory`](https://docs.spring.io/spring/docs/current/javadoc-api/org/springframework/http/client/SimpleClientHttpRequestFactory.html): 표준 J2SE 기능을 사용해 HTTP 요청을 생성한다.
- [`HttpComponentsClientHttpRequestFactory`](https://docs.spring.io/spring/docs/current/javadoc-api/org/springframework/http/client/HttpComponentsClientHttpRequestFactory.html): [Apache HttpComponents HttpClient](https://hc.apache.org/httpcomponents-client-ga/)를 사용한다 (스프링 3.1부터).

`request-factory`나 `rest-template` 속성을 명시하지 않으면 디폴트 `RestTemplate` 인스턴스를 생성한다 (디폴트 `RestTemplate`은 `SimpleClientHttpRequestFactory`를 사용한다).

> JVM 구현체에 따라, `URLConnection` 클래스에 의한 타임아웃 처리가 일관적이지 않을 수도 있다.
>
> 예를 들어 Java™ 플랫폼에서 `setConnectTimeout`에 관한 Standard Edition 6 API 스펙을 살펴보면 다음과 같이 설명하고 있다:
>
> - 일부 비표준 구현체에서 이 메소드는 지정된 타임아웃을 무시할 수 있다. 커넥션 타임아웃 세팅을 확인하려면 getConnectTimeout()을 호출해라.
>
> 정확한 요구 사항이 있다면 타임아웃이 잘 동작하는지 테스트해보는 것이 좋다. JVM에서 제공하는 구현체에 의존하기 보다는 [Apache HttpComponents HttpClient](https://hc.apache.org/httpcomponents-client-ga/)를 이용하는 `HttpComponentsClientHttpRequestFactory`를 사용하는 것을 고려해봐라.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>Apache HttpComponents HttpClient를 풀링 커넥션 매니저와 함께 사용한다면, 커넥션 매니저는 기본적으로 주어진 라우트 당 동시 커넥션을 2개 이상으로는 생성하지 않고, 전체 커넥션 수도 20개 이하로 유지한다는 점을 알아둬야 한다. 실제 애플리케이션에 쓰기에는 대부분 너무 과도한 제약일 거다. 이 컴포넌트에 관한 세부 세팅 방법은 <a href="https://hc.apache.org/httpcomponents-client-ga/">Apache 문서</a>를 참고해라.</p>
</blockquote>
다음은 커넥션 타임아웃과 read 타임아웃을 각각 5초로 설정한 `SimpleClientHttpRequestFactory`를 사용해 HTTP 아웃바운드 게이트웨이를 구성하는 예시다:

```xml
<int-http:outbound-gateway url="https://samples.openweathermap.org/data/2.5/weather?q={city}"
                           http-method="GET"
                           expected-response-type="java.lang.String"
                           request-factory="requestFactory"
                           request-channel="requestChannel"
                           reply-channel="replyChannel">
    <int-http:uri-variable name="city" expression="payload"/>
</int-http:outbound-gateway>

<bean id="requestFactory"
      class="org.springframework.http.client.SimpleClientHttpRequestFactory">
    <property name="connectTimeout" value="5000"/>
    <property name="readTimeout"    value="5000"/>
</bean>
```

### 21.5.1. HTTP Outbound Gateway

*HTTP 아웃바운드 게이트웨이*의 경우 XML 스키마는 *reply-timeout*만 정의한다. 이 *reply-timeout*은 *org.springframework.integration.http.outbound.HttpRequestExecutingMessageHandler* 클래스의 *sendTimeout* 프로퍼티에 매핑된다. 더 정확하게는, 이 프로퍼티는 `AbstractReplyProducingMessageHandler`를 상속한 클래스에 세팅돼서, 궁극적으로 `MessagingTemplate`에 있는 프로퍼티에 저장된다.

*sendTimeout* 프로퍼티의 기본값은 "-1"이며, 이 값은 연결돼있는 `MessageChannel`에 적용된다. 즉, 메시지 채널의 구현체에 따라 *send* 메소드가 무한정 블로킹될 수 있다는 뜻이기도 하다. 참고로, *sendTimeout* 프로퍼티는 실제 MessageChannel 구현체에서 메시지 전송이 블로킹되는 경우에만 사용한다 (유한<sup>bounded</sup> QueueChannel이 가득 찬 경우 등).

### 21.5.2. HTTP Inbound Gateway

HTTP 인바운드 게이트웨이의 경우, XML 스키마는 `HttpRequestHandlingMessagingGateway` 클래스(`MessagingGatewaySupport` 클래스를 상속하고 있는)의 `requestTimeout` 속성에 사용되는 `request-timeout` 속성을 정의한다. `reply-timeout` 속성을 사용하면 같은 클래스의 `replyTimeout` 속성도 매핑할 수 있다.

두 타임아웃 프로퍼티의 기본값은 모두 `1000ms`이다 (즉, 1000밀리세컨드=1초). `request-timeout` 프로퍼티는 궁극적으로 `MessagingTemplate` 인스턴스의 `sendTimeout`을 설정하는 데 사용한다. 반면 `replyTimeout` 프로퍼티는 `MessagingTemplate` 인스턴스의 `receiveTimeout` 프로퍼티를 설정하는 데 사용한다.

> 커넥션 타임아웃을 시뮬레이션해보려면, 10.255.255.10과 같이 라우팅이 불가능한 IP 주소에 연결해보면 된다.

---

## 21.6. HTTP Proxy configuration

앞에 프록시가 있어서, HTTP 아웃바운드 어댑터나 게이트웨이에 프록시 설정을 구성해야 하는 경우, 두 가지 방법 중 하나를 적용할 수 있다. 대부분의 경우 프록시 설정을 제어하는 표준 Java 시스템 프로퍼티를 이용하면 된다. 그 외는 HTTP 클라이언트 request 팩토리 인스턴스를 스프링 빈으로 직접 설정해주면 된다.

### 21.6.1. Standard Java Proxy configuration

세 가지 시스템 프로퍼티를 통해 HTTP 프로토콜 핸들러에서 사용할 프록시를 구성할 수 있다:

- `http.proxyHost`: 프록시 서버의 호스트 명.
- `http.proxyPort`: 포트 번호 (디폴트는 `80`).
- `http.nonProxyHosts`: 프록시를 우회해서 직접 도달해야 하는 호스트 목록. 각 패턴은 `|`로 구분한다. 와일드카드를 사용한다면 `*`로 시작하거나 끝나는 패턴일 수도 있다. 이 패턴 중 하나와 매칭되는 모든 호스트는 프록시를 통하는 대신 다이렉트로 커넥션을 맺는다.

HTTPS에는 다음과 같은 프로퍼티들을 사용할 수 있다:

- `https.proxyHost`: 프록시 서버의 호스트 명.
- `https.proxyPort`: 포트 번호. 디폴트는 80이다.

자세한 정보는 [docs.oracle.com/javase/8/docs/technotes/guides/net/proxies.html](https://docs.oracle.com/javase/8/docs/technotes/guides/net/proxies.html)을 확인해봐라.

### 21.6.2. Spring’s `SimpleClientHttpRequestFactory`

프록시를 직접 세팅하고 싶다면 다음과 같이 스프링의 `SimpleClientHttpRequestFactory`를 사용해 `proxy` 프로퍼티를 설정해주면 된다.

```xml
<bean id="requestFactory"
    class="org.springframework.http.client.SimpleClientHttpRequestFactory">
    <property name="proxy">
        <bean id="proxy" class="java.net.Proxy">
            <constructor-arg>
                <util:constant static-field="java.net.Proxy.Type.HTTP"/>
            </constructor-arg>
            <constructor-arg>
                <bean class="java.net.InetSocketAddress">
                    <constructor-arg value="123.0.0.1"/>
                    <constructor-arg value="8080"/>
                </bean>
            </constructor-arg>
        </bean>
    </property>
</bean>
```

---

## 21.7. HTTP Header Mappings

Spring Integration은 HTTP 요청과 HTTP 응답 모두, HTTP 헤더 매핑을 지원한다.

기본적으로, 별도 설정이 없어도 메시지에 있는 모든 표준 [HTTP 헤더](https://en.wikipedia.org/wiki/List_of_HTTP_header_fields)는 HTTP 요청/응답의 헤더로 매핑된다. 하지만 추가적으로 커스텀할 게 있다면, 네임스페이스를 이용해 설정을 추가해주면 된다. 헤더 이름들의 목록을 콤마로 구분해서 제공해주면 되는데, 와일드카드 역할을 하는 '*' 문자가 들어있는 패턴도 사용할 수 있다. 헤더 값을 지정하면 기본 동작을 재정의하게 된다. 이 시점에는 사용자가 모든 것을 직접 제어한다고 가정한다. 하지만 표준 HTTP 헤더도 전부 포함시키고 싶다면 `HTTP_REQUEST_HEADERS`와 `HTTP_RESPONSE_HEADERS`도 함께 패턴으로 정의하면 된다. 다음은 두 가지 설정 예시다 (첫 번째 설정은 와일드카드를 사용한다):

```xml
<int-http:outbound-gateway id="httpGateway"
    url="http://localhost/test2"
    mapped-request-headers="thing1, thing2"
    mapped-response-headers="X-*, HTTP_RESPONSE_HEADERS"
    channel="someChannel"/>

<int-http:outbound-channel-adapter id="httpAdapter"
    url="http://localhost/test2"
    mapped-request-headers="thing1, thing2, HTTP_REQUEST_HEADERS"
    channel="someChannel"/>
```

어댑터와 게이트웨이는 `DefaultHttpHeaderMapper`를 사용하는데, `DefaultHttpHeaderMapper`는 이제 인바운드와 아웃바운드 어댑터를 위한 스태틱 팩토리 메소드를 각각 제공하므로, 각자에 맞는 방향으로 매핑해줄 수 있다 (HTTP 요청/응답을 상황에 맞게 in/out으로 매핑).

다른 것들을 더 커스텀해야 한다면, 별도로 `DefaultHttpHeaderMapper`를 설정해서 `header-mapper` 속성을 통해 어댑터에 주입해주는 것도 가능하다.

`DefaultHttpHeaderMapper`는 5.0 버전 이전에는 사용자가 정의하는 비표준 HTTP 헤더에 `X-`를 디폴트 프리픽스로 사용했었다. 5.0에선 이 디폴트 프리픽스를 비어있는 문자열로 변경했다. [RFC-6648](https://tools.ietf.org/html/rfc6648)에 따르면 이런 프리픽스를 사용하는 것을 이제는 권장하지 않는다고 한다. 물론, `DefaultHttpHeaderMapper.setUserDefinedHeaderPrefix()` 프로퍼티를 설정하면 이 옵션을 커스텀할 수 있다. 다음은 HTTP 게이트웨이를 위한 헤더 매퍼를 설정하는 예시다:

```xml
<int-http:outbound-gateway id="httpGateway"
    url="http://localhost/test2"
    header-mapper="headerMapper"
    channel="someChannel"/>

<bean id="headerMapper" class="o.s.i.http.support.DefaultHttpHeaderMapper">
    <property name="inboundHeaderNames" value="thing1*, *thing2, thing3"/>
    <property name="outboundHeaderNames" value="a*b, d"/>
</bean>
```

현재 필요한 것이 `DefaultHttpHeaderMapper`의 지원 범위를 벗어난다면, 전략 인터페이스 `HeaderMapper`를 직접 구현해서, 구현체에 대한 참조를 제공해주면 된다.

---

## 21.8. Integration Graph Controller

HTTP 모듈은 4.3 버전부터 클래스 설정 어노테이션 `@EnableIntegrationGraphController`와 XML 요소 `<int-http:graph-controller/>`를 통해 REST 서비스로 `IntegrationGraphServer`를 노출해준다. 자세한 내용은 [통합 그래프](../system-management/#137-integration-graph)를 참고해라.

---

## 21.9. HTTP Samples

이번 섹션에선 몇 가지 예제와 함께 Spring Integration의 HTTP 지원에 대한 내용을 마무리하려 한다.

### 21.9.1. Multipart HTTP Request — RestTemplate (Client) and Http Inbound Gateway (Server)

이 예제를 통해, 스프링의 `RestTemplate`을 사용해 HTTP 멀티파트 요청을 보내고 Spring Integration의 HTTP 인바운드 어댑터로 수신하는 것이 얼마나 간단한지를 알아보려 한다. 여기서는 `MultiValueMap`을 생성해 멀티파트 데이터를 채운다. 나머지는 `RestTemplate`이 `MultipartHttpServletRequest`로 변환해서 처리해준다. 이 예제에선, 클라이언트가 회사의 이름과 이미지 파일(회사 로고)이 포함된 HTTP 멀티파트 요청을 전송한다고 가정한다:

```java
RestTemplate template = new RestTemplate();
String uri = "http://localhost:8080/multipart-http/inboundAdapter.htm";
Resource s2logo =
   new ClassPathResource("org/springframework/samples/multipart/spring09_logo.png");
MultiValueMap map = new LinkedMultiValueMap();
map.add("company", "SpringSource");
map.add("company-logo", s2logo);
HttpHeaders headers = new HttpHeaders();
headers.setContentType(new MediaType("multipart", "form-data"));
HttpEntity request = new HttpEntity(map, headers);
ResponseEntity<?> httpResponse = template.exchange(uri, HttpMethod.POST, request, null);
```

클라이언트에서 필요한 건 이게 전부다.

서버 측에선 다음과 같은 설정을 사용할 수 있다:

```xml
<int-http:inbound-channel-adapter id="httpInboundAdapter"
    channel="receiveChannel"
    path="/inboundAdapter.htm"
    supported-methods="GET, POST"/>

<int:channel id="receiveChannel"/>

<int:service-activator input-channel="receiveChannel">
    <bean class="org.springframework.integration.samples.multipart.MultipartReceiver"/>
</int:service-activator>

<bean id="multipartResolver"
    class="org.springframework.web.multipart.commons.CommonsMultipartResolver"/>
```

'httpInboundAdapter'는 요청을 수신해서 `LinkedMultiValueMap`을 페이로드로 갖는 `Message`로 변환한다. 그런 다음엔 아래 보이는 service-activator 'multipartReceiver'에서 페이로드를 파싱한다:

```java
public void receive(LinkedMultiValueMap<String, Object> multipartRequest){
    System.out.println("## Successfully received multipart request ###");
    for (String elementName : multipartRequest.keySet()) {
        if (elementName.equals("company")){
            System.out.println("\t" + elementName + " - " +
                ((String[]) multipartRequest.getFirst("company"))[0]);
        }
        else if (elementName.equals("company-logo")){
            System.out.println("\t" + elementName + " - as UploadedMultipartFile: " +
                ((UploadedMultipartFile) multipartRequest
                    .getFirst("company-logo")).getOriginalFilename());
        }
    }
}
```

다음과 같은 문구가 출력되는 걸 볼 수 있을 거다:

```java
## Successfully received multipart request ###
   company - SpringSource
   company-logo - as UploadedMultipartFile: spring09_logo.png
```