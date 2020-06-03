---
title: WebClient
category: Reactive Spring
order: 4
permalink: /Reactive%20Spring/webclient/

---

> [리액티브 스프링 공식 reference](https://docs.spring.io/spring/docs/current/spring-framework-reference/web-reactive.html#webflux-client)를 한글로 번역한 문서입니다.
>
> 전체 목차는 [여기](https://godekdls.github.io/Reactive%20Spring/contents/)에 있습니다.

### 목차

- [2.1. Configuration](#21-configuration)
  + [2.1.1. MaxInMemorySize](#211-maxinmemorysize)
  + [2.1.2. Reactor Netty](#212-reactor-netty)
    + [Resources](#resources)
    + [Timeouts](#timeouts)
  + [2.1.3. Jetty](#213-jetty)
- [2.2. retrieve()](#22-retrieve)
- [2.3. exchange()](#23-exchange)
- [2.4. Request Body](#24-request-body)
  + [2.4.1. Form Data](#241-form-data)
  + [2.4.2. Multipart Data](#242-multipart-data)
- [2.5. Client Filters](#25-client-filters)
- [2.6. Synchronous Use](#26-synchronous-use)
- [2.7. Testing](#27-testing)

---

Spring WebFlux includes a reactive, non-blocking `WebClient` for HTTP requests. The client has a functional, fluent API with reactive types for declarative composition, see [Reactive Libraries](https://godekdls.github.io/Reactive%20Spring/reactivelibraries/). WebFlux client and server rely on the same non-blocking [코덱](https://godekdls.github.io/Reactive%20Spring/springwebflux/#125-codecs) to encode and decode request and response content.

Internally `WebClient` delegates to an HTTP client library. By default, it uses [Reactor Netty](https://github.com/reactor/reactor-netty), there is built-in support for the Jetty [reactive HttpClient](https://github.com/jetty-project/jetty-reactive-httpclient), and others can be plugged in through a `ClientHttpConnector`.

---

## 2.1. Configuration

The simplest way to create a `WebClient` is through one of the static factory methods:

- `WebClient.create()`
- `WebClient.create(String baseUrl)`

The above methods use the Reactor Netty `HttpClient` with default settings and expect `io.projectreactor.netty:reactor-netty` to be on the classpath.

You can also use `WebClient.builder()` with further options:

- `uriBuilderFactory`: Customized `UriBuilderFactory` to use as a base URL.
- `defaultHeader`: Headers for every request.
- `defaultCookie`: Cookies for every request.
- `defaultRequest`: `Consumer` to customize every request.
- `filter`: Client filter for every request.
- `exchangeStrategies`: HTTP message reader/writer customizations.
- `clientConnector`: HTTP client library settings.

The following example configures [HTTP 코덱](https://godekdls.github.io/Reactive%20Spring/springwebflux/#125-codecs):

- *java*

  ```java
  WebClient client = WebClient.builder()
          .exchangeStrategies(builder -> {
                  return builder.codecs(codecConfigurer -> {
                      //...
                  });
          })
          .build();
  ```

- *kotlin*

  ```kotlin
  val webClient = WebClient.builder()
          .exchangeStrategies { strategies ->
              strategies.codecs {
                  //...
              }
          }
          .build()
  ```

Once built, a `WebClient` instance is immutable. However, you can clone it and build a modified copy without affecting the original instance, as the following example shows:

- *java*

  ```java
  WebClient client1 = WebClient.builder()
          .filter(filterA).filter(filterB).build();
  
  WebClient client2 = client1.mutate()
          .filter(filterC).filter(filterD).build();
  
  // client1 has filterA, filterB
  
  // client2 has filterA, filterB, filterC, filterD
  ```

- *kotlin*

  ```kotlin
  val client1 = WebClient.builder()
          .filter(filterA).filter(filterB).build()
  
  val client2 = client1.mutate()
          .filter(filterC).filter(filterD).build()
  
  // client1 has filterA, filterB
  
  // client2 has filterA, filterB, filterC, filterD
  ```

  

### 2.1.1. MaxInMemorySize

### 2.1.2. Reactor Netty

#### Resources

#### Timeouts

### 2.1.3. Jetty

---

---

## 2.2. retrieve()

---

## 2.3. exchange()

---

## 2.4. Request Body

### 2.4.1. Form Data

### 2.4.2. Multipart Data

---

## 2.5. Client Filters

---

## 2.6. Synchronous Use

---

## 2.7. Testing

---

> 전체 목차는 [여기](https://godekdls.github.io/Reactive%20Spring/contents/)에 있습니다.