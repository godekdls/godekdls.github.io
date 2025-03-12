---
title: “How-to” Guides
category: Spring Cloud Sleuth
order: 6
permalink: /Spring%20Cloud%20Sleuth/howto/
description: 스프링 클라우드 슬루스 how-to 가이드
image: ./../../images/springcloud/logo.jpeg
lastmod: 2024-07-13T14:47:00+09:00
comments: true
originalRefName: 스프링 클라우드 슬루스
originalRefLink: https://docs.spring.io/spring-cloud-sleuth/docs/3.1.11/reference/htmlsingle/#howto
originalVersion: 3.1.11
---
<script>defaultLanguages = ['maven']</script>

이번 섹션은 Spring Cloud Sleuth를 사용할 때 자주 묻곤 하는 "어떻게 해야 하나요...?" 류의 질문들에 답해본다. 모든 질문에 답해주진 않지만, 꽤 많은 내용을 다루고 있다.

현재 직면한 문제를 이 문서에서 다루지 않았다면, [stackoverflow.com](https://stackoverflow.com/tags/spring-cloud-sleuth)에서도 찾아봐라. 이미 다른 사람이 답변해 두었을 수도 있다. 스택 오버플로는 질문을 새로 올리기에도 아주 좋은 곳이다 (`spring-cloud-sleuth` 태그를 달아달라).

이 섹션에 내용을 추가하는 것 또한 환영한다. “how-to” 가이드를 추가하고 싶다면 [풀 리퀘스트](https://github.com/spring-cloud/spring-cloud-sleuth/tree/3.1.x)를 만들면 된다.

### 목차

- [5.1. Sleuth를 Brave와 함께 사용하려면 어떻게 설정해야 하나요?](#51-sleuth를-brave와-함께-사용하려면-어떻게-설정해야-하나요)
- [5.2. Sleuth를 Brave, Zipkin과 함께 사용하면서 HTTP로 통신하려면 어떻게 설정해야 하나요?](#52-sleuth를-brave-zipkin과-함께-사용하면서-http로-통신하려면-어떻게-설정해야-하나요)
- [5.3. Sleuth를 Brave, Zipkin과 함께 사용하면서 메시지를 통해 통신하려면 어떻게 설정해야 하나요?](#53-sleuth를-brave-zipkin과-함께-사용하면서-메시지를-통해-통신하려면-어떻게-설정해야-하나요)
- [5.4. Span이 외부 시스템에 전달되지 않을 땐 어떻게 하나요?](#54-span이-외부-시스템에-전달되지-않을-땐-어떻게-하나요)
  + [5.4.1. Span이 샘플링되지 않고 있는 경우](#541-span이-샘플링되지-않고-있는-경우)
  + [5.4.2. 의존성이 추가되지 않은 경우](#542-의존성이-추가되지-않은-경우)
  + [5.4.3. 커넥션 설정 오류](#543-커넥션-설정-오류)
- [5.5. RestTemplate, WebClient 등이 계측되지 않을 땐 어떻게 하나요?](#55-resttemplate-webclient-등이-계측되지-않을-땐-어떻게-하나요)
- [5.6. HTTP 서버 응답에 헤더는 어떻게 추가하나요?](#56-http-서버-응답에-헤더는-어떻게-추가하나요)
- [5.7. HTTP 클라이언트 Span을 커스텀하려면 어떻게 해야 하나요?](#57-http-클라이언트-span을-커스텀하려면-어떻게-해야-하나요)
- [5.8. HTTP 서버 Span을 커스텀하려면 어떻게 해야 하나요?](#58-http-서버-span을-커스텀하려면-어떻게-해야-하나요)
- [5.9. 로그에 애플리케이션 이름을 추가하려면 어떻게 해야 하나요?](#59-로그에-애플리케이션-이름을-추가하려면-어떻게-해야-하나요)
- [5.10. 컨텍스트 전파 메커니즘<sup>Context Propagation Mechanism</sup>은 어떻게 변경하나요?](#510-컨텍스트-전파-메커니즘context-propagation-mechanism은-어떻게-변경하나요)
- [5.11. 트레이서<sup>Tracer</sup>를 직접 구현하려면 어떻게 해야 하나요?](#511-트레이서tracer를-직접-구현하려면-어떻게-해야-하나요)

---

## 5.1. Sleuth를 Brave와 함께 사용하려면 어떻게 설정해야 하나요?

클래스패스에 Sleuth starter를 추가해라.

<div class="switch-language-wrapper maven gradle">
<span class="switch-language maven">Maven</span>
<span class="switch-language gradle">Gradle</span>
</div>
<div class="language-only-for-maven maven gradle"></div>
```xml
<dependencyManagement>
      <dependencies>
          <dependency>
              <groupId>org.springframework.cloud</groupId>
              <artifactId>spring-cloud-dependencies</artifactId>
              <version>${release.train-version}</version>
              <type>pom</type>
              <scope>import</scope>
          </dependency>
      </dependencies>
</dependencyManagement>

<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-sleuth</artifactId>
</dependency>
```
<div class="language-only-for-gradle maven gradle"></div>
```groovy
dependencyManagement {
    imports {
        mavenBom "org.springframework.cloud:spring-cloud-dependencies:${releaseTrainVersion}"
    }
}

dependencies {
    implementation "org.springframework.cloud:spring-cloud-starter-sleuth"
}
```

---

## 5.2. Sleuth를 Brave, Zipkin과 함께 사용하면서 HTTP로 통신하려면 어떻게 설정해야 하나요?

클래스패스에 Sleuth starter와 Zipkin을 추가해라.

<div class="switch-language-wrapper maven gradle">
<span class="switch-language maven">Maven</span>
<span class="switch-language gradle">Gradle</span>
</div>
<div class="language-only-for-maven maven gradle"></div>
```xml
<dependencyManagement>
      <dependencies>
          <dependency>
              <groupId>org.springframework.cloud</groupId>
              <artifactId>spring-cloud-dependencies</artifactId>
              <version>${release.train-version}</version>
              <type>pom</type>
              <scope>import</scope>
          </dependency>
      </dependencies>
</dependencyManagement>

<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-sleuth</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-sleuth-zipkin</artifactId>
</dependency>
```
<div class="language-only-for-gradle maven gradle"></div>
```groovy
dependencyManagement {
    imports {
        mavenBom "org.springframework.cloud:spring-cloud-dependencies:${releaseTrainVersion}"
    }
}

dependencies {
    implementation "org.springframework.cloud:spring-cloud-starter-sleuth"
    implementation "org.springframework.cloud:spring-cloud-sleuth-zipkin"
}
```

---

## 5.3. Sleuth를 Brave, Zipkin과 함께 사용하면서 메시지를 통해 통신하려면 어떻게 설정해야 하나요?

HTTP 대신 RabbitMQ나 Kafka, ActiveMQ를 사용하려면 `spring-rabbit`, `spring-kafka`, `org.apache.activemq:activemq-client` 의존성 중 필요한 의존성을 추가해라. 디폴트 목적지<sup>destination</sup> 이름은 `Zipkin`이다.

카프카를 사용한다면, 반드시 카프카 의존성을 추가해줘야 한다.

<div class="switch-language-wrapper maven gradle">
<span class="switch-language maven">Maven</span>
<span class="switch-language gradle">Gradle</span>
</div>
<div class="language-only-for-maven maven gradle"></div>
```xml
<dependencyManagement>
      <dependencies>
          <dependency>
              <groupId>org.springframework.cloud</groupId>
              <artifactId>spring-cloud-dependencies</artifactId>
              <version>${release.train-version}</version>
              <type>pom</type>
              <scope>import</scope>
          </dependency>
      </dependencies>
</dependencyManagement>

<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-sleuth</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-sleuth-zipkin</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.kafka</groupId>
    <artifactId>spring-kafka</artifactId>
</dependency>
```
<div class="language-only-for-gradle maven gradle"></div>
```groovy
dependencyManagement {
    imports {
        mavenBom "org.springframework.cloud:spring-cloud-dependencies:${releaseTrainVersion}"
    }
}

dependencies {
    implementation "org.springframework.cloud:spring-cloud-starter-sleuth"
    implementation "org.springframework.cloud:spring-cloud-sleuth-zipkin"
    implementation "org.springframework.kafka:spring-kafka"
}


```

추가로, `spring.zipkin.sender.type` 프로퍼티도 맞는 값으로 설정해 줘야 한다:

```yaml
spring.zipkin.sender.type: kafka
```

Sleuth를 RabbitMQ와 연동하려면 `spring-cloud-starter-sleuth`, `spring-cloud-sleuth-zipkin`, `spring-rabbit` 의존성을 추가해라.

<div class="switch-language-wrapper maven gradle">
<span class="switch-language maven">Maven</span>
<span class="switch-language gradle">Gradle</span>
</div>
<div class="language-only-for-maven maven gradle"></div>
```xml
<dependencyManagement>
      <dependencies>
          <dependency>
              <groupId>org.springframework.cloud</groupId>
              <artifactId>spring-cloud-dependencies</artifactId>
              <version>${release.train-version}</version>
              <type>pom</type>
              <scope>import</scope>
          </dependency>
      </dependencies>
</dependencyManagement>

<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-sleuth</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-sleuth-zipkin</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.amqp</groupId>
    <artifactId>spring-rabbit</artifactId>
</dependency>
```
<div class="language-only-for-gradle maven gradle"></div>
```groovy
dependencyManagement {
    imports {
        mavenBom "org.springframework.cloud:spring-cloud-dependencies:${releaseTrainVersion}"
    }
}

dependencies {
    implementation "org.springframework.cloud:spring-cloud-starter-sleuth"
    implementation "org.springframework.cloud:spring-cloud-sleuth-zipkin"
    implementation "org.springframework.amqp:spring-rabbit"
}
```

Sleuth를 ActiveMQ와 연동하려면 `spring-cloud-starter-sleuth`, `spring-cloud-sleuth-zipkin`, `activemq-client` 의존성을 추가해라.

<div class="switch-language-wrapper maven gradle">
<span class="switch-language maven">Maven</span>
<span class="switch-language gradle">Gradle</span>
</div>
<div class="language-only-for-maven maven gradle"></div>
```xml
<dependencyManagement>
      <dependencies>
          <dependency>
              <groupId>org.springframework.cloud</groupId>
              <artifactId>spring-cloud-dependencies</artifactId>
              <version>${release.train-version}</version>
              <type>pom</type>
              <scope>import</scope>
          </dependency>
      </dependencies>
</dependencyManagement>

<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-sleuth</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-sleuth-zipkin</artifactId>
</dependency>
<dependency>
    <groupId>org.apache.activemq</groupId>
    <artifactId>activemq-client</artifactId>
</dependency>
```
<div class="language-only-for-gradle maven gradle"></div>
```groovy
dependencyManagement {
    imports {
        mavenBom "org.springframework.cloud:spring-cloud-dependencies:${releaseTrainVersion}"
    }
}

dependencies {
    implementation "org.springframework.cloud:spring-cloud-starter-sleuth"
    implementation "org.springframework.cloud:spring-cloud-sleuth-zipkin"
    implementation "org.apache.activemq:activemq-client"
}
```

또한, `spring.zipkin.sender.type` 프로퍼티도 그에 맞게 설정해줘야 한다:

```yaml
spring.zipkin.sender.type: activemq
```

---

## 5.4. Span이 외부 시스템에 전달되지 않을 땐 어떻게 하나요?

Zipkin 등의 외부 시스템에 span이 리포트되지 않는다면, 보통은 아래와 같은 문제일 가능성이 크다:

- [Span이 샘플링되지 않고 있는 경우](#541-span이-샘플링되지-않고-있는-경우)
- [외부 시스템에 리포트할 때 필요한 의존성을 추가하는 것을 잊은 경우 (e.g. `spring-cloud-sleuth-zipkin`)](#542-의존성이-추가되지-않은-경우)
- [외부 시스템의 커넥션 정보를 잘못 설정한 경우](#543-커넥션-설정-오류)

### 5.4.1. Span이 샘플링되지 않고 있는 경우

span이 샘플링되고 있는지 여부를 체크하려면, 플래그 값만 확인해주면 된다. 아래 예시를 살펴보자:

```java
2020-10-21 12:01:16.285  INFO [backend,0b6aaf642574edd3,0b6aaf642574edd3,true] 289589 --- [nio-9000-exec-1] Example              : Hello world!
```

위에 출력된 `[backend,0b6aaf642574edd3,0b6aaf642574edd3,true]` 안에 있는 boolean 값이 `true`이면, 이 span은 샘플링하고 있으며 리포트된다는 걸 의미한다.

### 5.4.2. 의존성이 추가되지 않은 경우

Sleuth 3.0.0 이전엔 `spring-cloud-starter-zipkin` 의존성에 `spring-cloud-starter-sleuth`와 `spring-cloud-sleuth-zipkin`이 포함돼 있었다. 3.0.0에서는 `spring-cloud-starter-zipkin`이 제거됐으므로, `spring-cloud-sleuth-zipkin`으로 변경해줘야 한다.

### 5.4.3. 커넥션 설정 오류

원격 시스템의 주소를 제대로 설정했는지 (e.g. `spring.zipkin.baseUrl`), 브로커를 이용해 통신한다면 브로커 커넥션 정보를 제대로 설정했는지 다시 한 번 확인해봐라.

---

## 5.5. RestTemplate, WebClient 등이 계측되지 않을 땐 어떻게 하나요?

트레이싱<sup>tracing</sup> 컨텍스트가 전파되지 않는다면, 다음과 같은 이유가 있을 수 있다:

- 주어진 라이브러리 계측<sup>instrumentation</sup>을 지원하지 않는 경우
- 라이브러리 계측<sup>instrumentation</sup>은 지원하지만 설정이 잘못된 경우

계측<sup>instrumentation</sup>을 지원하지 않는 라이브러리를 사용하고 있다면, [이슈](https://github.com/spring-cloud/spring-cloud-sleuth/issues)를 등록해 계측<sup>instrumentation</sup> 기능 추가를 요청해달라.

설정이 잘못된 경우라면, 통신에 사용 중인 클라이언트가 스프링 빈이 맞는지 확인해봐라. `new` 연산자를 통해 클라이언트를 직접 생성한다면 계측<sup>instrumentation</sup> 기능이 동작하지 않는다.

다음은 계측<sup>instrumentation</sup> 기능이 동작하는 예시다:

```java
@Configuration(proxyBeanMethods = false)
class MyConfiguration {
    @Bean RestTemplate myRestTemplate() {
        return new RestTemplate();
    }
}

@Service
class MyService {
    private final RestTemplate restTemplate;

    MyService(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    String makeACall() {
        return this.restTemplate.getForObject("http://example.com", String.class);
    }

}
```

다음은 계측<sup>instrumentation</sup> 기능이 동작하지 **않는** 예시다:

```java
@Service
class MyService {

    String makeACall() {
        // This will not work because RestTemplate is not a bean
        return new RestTemplate().getForObject("http://example.com", String.class);
    }

}
```

---

## 5.6. HTTP 서버 응답에 헤더는 어떻게 추가하나요?

서버 응답을 세팅할 필터를 등록해라.

```java
@Configuration(proxyBeanMethods = false)
class MyConfig {

        // Example of a servlet Filter for non-reactive applications
        @Bean
        Filter traceIdInResponseFilter(Tracer tracer) {
            return (request, response, chain) -> {
                Span currentSpan = tracer.currentSpan();
                if (currentSpan != null) {
                    HttpServletResponse resp = (HttpServletResponse) response;
                    // putting trace id value in [mytraceid] response header
                    resp.addHeader("mytraceid", currentSpan.context().traceId());
                }
                chain.doFilter(request, response);
            };
        }

        // Example of a reactive WebFilter for reactive applications
        @Bean
        WebFilter traceIdInResponseFilter(Tracer tracer) {
            return (exchange, chain) -> {
                Span currentSpan = tracer.currentSpan();
                if (currentSpan != null) {
                    // putting trace id value in [mytraceid] response header
                    exchange.getResponse().getHeaders().add("mytraceid", currentSpan.context().traceId());
                }
                return chain.filter(exchange);
            };
        }
}
```

---

## 5.7. HTTP 클라이언트 Span을 커스텀하려면 어떻게 해야 하나요?

요청하는 쪽을 커스텀하려면 `HttpRequestParser` 타입 빈을 `HttpClientRequestParser.NAME`이란 이름으로 등록해라. 응답하는 쪽을 커스텀하려면 `HttpResponseParser` 타입 빈을 `HttpClientRequestParser.NAME`이라는 이름으로 등록해라.

```java
@Configuration(proxyBeanMethods = false)
public static class ClientParserConfiguration {

    // example for Feign
    @Bean(name = HttpClientRequestParser.NAME)
    HttpRequestParser myHttpClientRequestParser() {
        return (request, context, span) -> {
            // Span customization
            span.name(request.method());
            span.tag("ClientRequest", "Tag");
            Object unwrap = request.unwrap();
            if (unwrap instanceof feign.Request) {
                feign.Request req = (feign.Request) unwrap;
                // Span customization
                span.tag("ClientRequestFeign", req.httpMethod().name());
            }
        };
    }

    // example for Feign
    @Bean(name = HttpClientResponseParser.NAME)
    HttpResponseParser myHttpClientResponseParser() {
        return (response, context, span) -> {
            // Span customization
            span.tag("ClientResponse", "Tag");
            Object unwrap = response.unwrap();
            if (unwrap instanceof feign.Response) {
                feign.Response resp = (feign.Response) unwrap;
                // Span customization
                span.tag("ClientResponseFeign", String.valueOf(resp.status()));
            }
        };
    }

}
```

> 이 parser가 동작하려면 span을 샘플링해야 한다. 즉, Zipkin 등으로 span을 내보낼 수 있어야 한다.

---

## 5.8. HTTP 서버 Span을 커스텀하려면 어떻게 해야 하나요?

요청하는 쪽을 커스텀하려면 `HttpRequestParser` 타입 빈을 `HttpServerRequestParser.NAME`이란 이름으로 등록해라. 응답하는 쪽을 커스텀하려면 `HttpResponseParser` 타입 빈을 `HttpServerResponseParser.NAME`이라는 이름으로 등록해라.

```java
@Configuration(proxyBeanMethods = false)
public static class ServerParserConfiguration {

    @Bean(name = HttpServerRequestParser.NAME)
    HttpRequestParser myHttpRequestParser() {
        return (request, context, span) -> {
            // Span customization
            span.tag("ServerRequest", "Tag");
            Object unwrap = request.unwrap();
            if (unwrap instanceof HttpServletRequest) {
                HttpServletRequest req = (HttpServletRequest) unwrap;
                // Span customization
                span.tag("ServerRequestServlet", req.getMethod());
            }
        };
    }

    @Bean(name = HttpServerResponseParser.NAME)
    HttpResponseParser myHttpResponseParser() {
        return (response, context, span) -> {
            // Span customization
            span.tag("ServerResponse", "Tag");
            Object unwrap = response.unwrap();
            if (unwrap instanceof HttpServletResponse) {
                HttpServletResponse resp = (HttpServletResponse) unwrap;
                // Span customization
                span.tag("ServerResponseServlet", String.valueOf(resp.getStatus()));
            }
        };
    }

    @Bean
    Filter traceIdInResponseFilter(Tracer tracer) {
        return (request, response, chain) -> {
            Span currentSpan = tracer.currentSpan();
            if (currentSpan != null) {
                HttpServletResponse resp = (HttpServletResponse) response;
                resp.addHeader("mytraceid", currentSpan.context().traceId());
            }
            chain.doFilter(request, response);
        };
    }

}
```

> 이 parser가 동작하려면 span을 샘플링해야 한다. 즉, Zipkin 등으로 span을 내보낼 수 있어야 한다.

---

## 5.9. 로그에 애플리케이션 이름을 추가하려면 어떻게 해야 하나요?

디폴트 로그 포맷을 변경하지 않았다는 가정 하에, `application.yml`이 아닌 `bootstrap.yml`에 `spring.application.name` 프로퍼티를 설정해라.

> Spring Cloud의 새로운 설정 부트스트랩 기능에서는 더 이상 부트스트랩 컨텍스트가 존재하지 않으므로, 이 작업은 더 이상 필요하지 않다.

---

## 5.10. 컨텍스트 전파 메커니즘<sup>Context Propagation Mechanism</sup>은 어떻게 변경하나요?

기본으로 제공하는 메커니즘을 통해 헤더를 전파<sup>propagation</sup>하려면 `spring.sleuth.propagation.type` 프로퍼티를 변경해주면 된다. 값을 여러 개 지정하면 더 다양한 트레이싱<sup>propagation</sup> 헤더를 전파한다.

Brave의 경우 전파<sup>propagation</sup> 타입으로 `AWS`, `B3`, `W3C`를 지원한다.

커스텀 전파<sup>propagation</sup> 메커니즘을 사용하려면, `spring.sleuth.propagation.type` 프로퍼티를 `CUSTOM`으로 설정하고 자체 빈을 구현해라 (Brave의 경우 `Propagation.Factory`). 샘플 코드는 아래에서 확인할 수 있다:

```java
@Component
class CustomPropagator extends Propagation.Factory implements Propagation<String> {

    @Override
    public List<String> keys() {
        return Arrays.asList("myCustomTraceId", "myCustomSpanId");
    }

    @Override
    public <R> TraceContext.Injector<R> injector(Setter<R, String> setter) {
        return (traceContext, request) -> {
            setter.put(request, "myCustomTraceId", traceContext.traceIdString());
            setter.put(request, "myCustomSpanId", traceContext.spanIdString());
        };
    }

    @Override
    public <R> TraceContext.Extractor<R> extractor(Getter<R, String> getter) {
        return request -> TraceContextOrSamplingFlags.create(TraceContext.newBuilder()
                .traceId(HexCodec.lowerHexToUnsignedLong(getter.get(request, "myCustomTraceId")))
                .spanId(HexCodec.lowerHexToUnsignedLong(getter.get(request, "myCustomSpanId"))).build());
    }

    @Override
    public Propagation<String> get() {
        return this;
    }

}
```

---

## 5.11. 트레이서<sup>Tracer</sup>를 직접 구현하려면 어떻게 해야 하나요?

Spring Cloud Sleuth API에는 트레이서<sup>tracer</sup>가 구현해야 하는 모든 인터페이스가 포함돼 있다. Spring Cloud Sleuth 프로젝트는 OpenZipkin Brave 구현체와 함께 제공된다. 두 트레이서<sup>tracer</sup>가 Sleuth API에 어떻게 연결되는지는 `org.springframework.cloud.sleuth.brave.bridge` 모듈을 보면 확인할 수 있다.