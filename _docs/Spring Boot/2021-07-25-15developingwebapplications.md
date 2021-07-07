---
title: Developing Web Applications
category: Spring Boot
order: 15
permalink: /Spring%20Boot/developing-web-applications/
description: 스프링 부트로 웹 애플리케이션 개발하기. MVC/웹플럭스 자동 설정, 메세지 컨버터, 스태틱 리소스 서빙, 에러 처리, 템플릿 엔진, 임베디드 컨테이너 등을 설명합니다.
image: ./../../images/springboot/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 부트
originalRefLink: https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#features.developing-web-applications
parent: Spring Boot Features
parentUrl: /Spring%20Boot/spring-boot-features/
---
<script>defaultLanguages = ['properties']</script>

### 목차

- [7.7.1. The “Spring Web MVC Framework”](#771-the-spring-web-mvc-framework)
  + [Spring MVC Auto-configuration](#spring-mvc-auto-configuration)
  + [HttpMessageConverters](#httpmessageconverters)
  + [Custom JSON Serializers and Deserializers](#custom-json-serializers-and-deserializers)
  + [MessageCodesResolver](#messagecodesresolver)
  + [Static Content](#static-content)
  + [Welcome Page](#welcome-page)
  + [Path Matching and Content Negotiation](#path-matching-and-content-negotiation)
  + [ConfigurableWebBindingInitializer](#configurablewebbindinginitializer)
  + [Template Engines](#template-engines)
  + [Error Handling](#error-handling)
    * [Custom Error Pages](#custom-error-pages)
    * [Mapping Error Pages outside of Spring MVC](#mapping-error-pages-outside-of-spring-mvc)
    * [Error handling in a war deployment](#error-handling-in-a-war-deployment)
  + [Spring HATEOAS](#spring-hateoas)
  + [CORS Support](#cors-support)
- [7.7.2. The “Spring WebFlux Framework”](#772-the-spring-webflux-framework)
  + [Spring WebFlux Auto-configuration](#spring-webflux-auto-configuration)
  + [HTTP Codecs with HttpMessageReaders and HttpMessageWriters](#http-codecs-with-httpmessagereaders-and-httpmessagewriters)
  + [Static Content](#static-content-1)
  + [Welcome Page](#welcome-page-1)
  + [Template Engines](#template-engines-1)
  + [Error Handling](#error-handling-1)
    * [Custom Error Pages](#custom-error-pages-1)
  + [Web Filters](#web-filters)
- [7.7.3. JAX-RS and Jersey](#773-jax-rs-and-jersey)
- [7.7.4. Embedded Servlet Container Support](#774-embedded-servlet-container-support)
  + [Servlets, Filters, and listeners](#servlets-filters-and-listeners)
    * [Registering Servlets, Filters, and Listeners as Spring Beans](#registering-servlets-filters-and-listeners-as-spring-beans)
  + [Servlet Context Initialization](#servlet-context-initialization)
    * [Scanning for Servlets, Filters, and listeners](#scanning-for-servlets-filters-and-listeners)
  + [The ServletWebServerApplicationContext](#the-servletwebserverapplicationcontext)
  + [Customizing Embedded Servlet Containers](#customizing-embedded-servlet-containers)
    * [Programmatic Customization](#programmatic-customization)
    * [Customizing ConfigurableServletWebServerFactory Directly](#customizing-configurableservletwebserverfactory-directly)
  + [JSP Limitations](#jsp-limitations)
- [7.7.5. Embedded Reactive Server Support](#775-embedded-reactive-server-support)
- [7.7.6. Reactive Server Resources Configuration](#776-reactive-server-resources-configuration)

---

## 7.7. Developing Web Applications

스프링 부트는 웹 애플리케이션 개발에 활용하기 좋다. 임베디드 Tomcat, Jetty, Undertow, Netty를 사용하면 자립적으로 실행할 수 있는<sup>self-contained</sup> HTTP 서버를 만들 수 있다. 웹 애플리케이션 대부분은 쉽고 빠른 실행을 위해 `spring-boot-starter-web` 모듈을 사용한다. `spring-boot-starter-webflux` 모듈을 사용하면 리액티브 웹 애플리케이션을 빌드할 수도 있다.

아직 스프링 부트 웹 애플리케이션을 개발해본 적이 없다면 *[Getting started](../getting-started#44-developing-your-first-spring-boot-application)* 섹션에 있는 "Hello World!" 예제를 따라해보는 것도 좋다.

### 7.7.1. The “Spring Web MVC Framework”

[스프링 웹 MVC 프레임워크](https://docs.spring.io/spring-framework/docs/5.3.8/reference/html/web.html#mvc)(보통 "스프링 MVC"라고 이야기한다)는 풍부한 "모델 뷰 컨트롤러" 웹 프레임워크다. 스프링 MVC를 사용하면 특별한 `@Controller`, `@RestController` 빈을 만들어서 들어오는 HTTP 요청을 처리할 수 있다. 컨트롤러에 있는 메소드는 `@RequestMapping` 어노테이션을 통해 HTTP에 매핑한다.

아래 코드는 JSON 데이터를 서빙하는 전형적인 `@RestController` 예시다:

```java
@RestController
@RequestMapping("/users")
public class MyRestController {

    private final UserRepository userRepository;

    private final CustomerRepository customerRepository;

    public MyRestController(UserRepository userRepository, CustomerRepository customerRepository) {
        this.userRepository = userRepository;
        this.customerRepository = customerRepository;
    }

    @GetMapping("/{user}")
    public User getUser(@PathVariable Long userId) {
        return this.userRepository.findById(userId).get();
    }

    @GetMapping("/{user}/customers")
    public List<Customer> getUserCustomers(@PathVariable Long userId) {
        return this.userRepository.findById(userId).map(this.customerRepository::findByUser).get();
    }

    @DeleteMapping("/{user}")
    public void deleteUser(@PathVariable Long userId) {
        this.userRepository.deleteById(userId);
    }

}
```

스프링 MVC는 스프링 프레임워크에 속하는 핵심 모듈이며, 자세한 정보는 [레퍼런스 문서](https://docs.spring.io/spring-framework/docs/5.3.8/reference/html/web.html#mvc)에서 확인하면 된다. [spring.io/guides](https://spring.io/guides)에서도 스프링 MVC를 다루는 여러 가지 가이드를 제공하고 있다.

#### Spring MVC Auto-configuration

스프링 부트는 대부분의 애플리케이션에 잘 맞는 스프링 MVC 자동 설정을 제공한다.

스프링의 기본 기능 위에 아래 기능들이 자동 설정으로 추가된다:

- `ContentNegotiatingViewResolver`, `BeanNameViewResolver` 빈 추가.
- WebJars 지원을 포함하는 스태틱 리소스 서빙 기능 ([아래](#static-content)에서 설명).
- `Converter`, `GenericConverter`, `Formatter` 빈 자동 등록.
- `HttpMessageConverters` 지원 ([아래](#httpmessageconverters)에서 설명).
- `MessageCodesResolver` 자동 등록 ([아래](#messagecodesresolver)에서 설명).
- 스태틱 `index.html` 지원.
- `ConfigurableWebBindingInitializer` 빈 자동 사용 ([아래](#configurablewebbindinginitializer)에서 설명).

여기 있는 스프링 부트의 MVC 커스텀은 그대로 활용하면서 [MVC](https://docs.spring.io/spring-framework/docs/5.3.8/reference/html/web.html#mvc)를 조금 더 커스텀하고 싶다면 (인터셉터, 포맷터, 뷰 컨트롤러 등), `WebMvcConfigurer` 타입의 자체 `@Configuration` 클래스를 `@EnableWebMvc` **없이** 추가하면 된다.

스프링 부트 MVC 커스텀은 유지하면서 `RequestMappingHandlerMapping`이나 `RequestMappingHandlerAdapter`, `ExceptionHandlerExceptionResolver`는 커스텀 인스턴스를 사용하고 싶으면, `WebMvcRegistrations` 타입 빈을 선언하고, 이 빈을 통해 이 커스텀한 컴포넌트 인스턴스를 제공하면 된다.

스프링 MVC를 완전히 제어하고 싶다면, `@EnableWebMvc` Javadoc에서 설명하는대로, 자체 `@Configuration`을 만들어 `@EnableWebMvc` 어노테이션을 선언하거나, `DelegatingWebMvcConfiguration`을 직접 만들어 `@Configuration` 어노테이션을 추가하면 된다.

> 스프링 MVC는 `application.properties`나 `application.yaml` 파일에 있는 값을 변환할 때와는 다른 `ConversionService`를 사용한다. 다시 말해 `Period`, `Duration`, `DataSize` 컨버터는 사용할 수 없으며, `@DurationUnit`과 `@DataSizeUnit` 어노테이션은 무시한다.
>
> 스프링 MVC에서 사용하는 `ConversionService`를 커스텀하고 싶으면, `WebMvcConfigurer` 빈을 통해 `addFormatters` 메소드를 구현해라. 이 메소드에서 원하는 컨버터를 등록하거나 `ApplicationConversionService`에 있는 스태틱 메소드에 위임하면 된다.

#### HttpMessageConverters

스프링 MVC는 `HttpMessageConverter` 인터페이스를 사용해서 HTTP 요청과 응답을 변환한다. 자주 쓰는 구현체들은 기본으로 제공한다. 예를 들어 객체를 JSON(Jackson 라이브러리로)이나 XML(가능하면 Jackson XML 익스텐션으로, Jackson XML 익스텐션이 없으면 JAXB로)로 자동으로 변환해준다. 기본적으로 문자열은 `UTF-8`로 인코딩한다.

컨버터를 추가하거나 커스텀해야 한다면 아래 보이는 것처럼 스프링 부트의 `HttpMessageConverters` 클래스를 사용하면 된다:

```java
@Configuration(proxyBeanMethods = false)
public class MyHttpMessageConvertersConfiguration {

    @Bean
    public HttpMessageConverters customConverters() {
        HttpMessageConverter<?> additional = new AdditionalHttpMessageConverter();
        HttpMessageConverter<?> another = new AnotherHttpMessageConverter();
        return new HttpMessageConverters(additional, another);
    }

}
```

컨텍스트에 있는 `HttpMessageConverter` 빈은 모두 자동으로 컨버터 리스트에 추가된다. 디폴트 컨버터를 재정의할 때도 같은 방법을 사용하면 된다.

#### Custom JSON Serializers and Deserializers

JSON 데이터를 Jackson으로 직렬화/역직렬화하는 경우 자체 `JsonSerializer`와 `JsonDeserializer` 클래스를 작성하기도 한다. 커스텀 시리얼 라이저는 보통 [모듈을 통해 Jackson에 등록](https://github.com/FasterXML/jackson-docs/wiki/JacksonHowToCustomSerializers)하지만, 스프링 부트에선 `@JsonComponent` 어노테이션을 통해 좀 더 쉽게 스프링 빈으로 바로 등록할 수 있다.

`@JsonComponent` 어노테이션은 `JsonSerializer`, `JsonDeserializer`, `KeyDeserializer` 구현체에 직접 선언하면 된다. 아래 예제처럼 serializer/deserializer를 내부 클래스로 가지고 있는 클래스에도 사용할 수 있다:

```java
@JsonComponent
public class MyJsonComponent {

    public static class Serializer extends JsonSerializer<MyObject> {

        @Override
        public void serialize(MyObject value, JsonGenerator jgen, SerializerProvider serializers) throws IOException {
            jgen.writeStringField("name", value.getName());
            jgen.writeNumberField("age", value.getAge());
        }

    }

    public static class Deserializer extends JsonDeserializer<MyObject> {

        @Override
        public MyObject deserialize(JsonParser jsonParser, DeserializationContext ctxt)
                throws IOException, JsonProcessingException {
            ObjectCodec codec = jsonParser.getCodec();
            JsonNode tree = codec.readTree(jsonParser);
            String name = tree.get("name").textValue();
            int age = tree.get("age").intValue();
            return new MyObject(name, age);
        }

    }

}
```

`ApplicationContext`에 있는 모든 `@JsonComponent` 빈은 자동으로 Jackson에 등록된다. `@JsonComponent`는 `@Component`를 가지고 있는 메타 어노테이션이기 때문에 일반적인 컴포넌트 스캔 규칙이 그대로 적용된다.

스프링 부트는 객체를 직렬화할 때 표준 jackson 대신 사용할 수 있는 추상 클래스 [`JsonObjectSerializer`](https://github.com/spring-projects/spring-boot/tree/v2.5.2/spring-boot-project/spring-boot/src/main/java/org/springframework/boot/jackson/JsonObjectSerializer.java), [`JsonObjectDeserializer`](https://github.com/spring-projects/spring-boot/tree/v2.5.2/spring-boot-project/spring-boot/src/main/java/org/springframework/boot/jackson/JsonObjectDeserializer.java)도 제공하고 있다. 자세한 내용은 [`JsonObjectSerializer`](https://docs.spring.io/spring-boot/docs/2.5.2/api/org/springframework/boot/jackson/JsonObjectSerializer.html), [`JsonObjectDeserializer`](https://docs.spring.io/spring-boot/docs/2.5.2/api/org/springframework/boot/jackson/JsonObjectDeserializer.html) Javadoc을 확인해봐라.

위에 있는 예제를 `JsonObjectSerializer`/`JsonObjectDeserializer`를 사용해서 다시 작성하면 다음과 같이 변한다:

```java
@JsonComponent
public class MyJsonComponent {

    public static class Serializer extends JsonObjectSerializer<MyObject> {

        @Override
        protected void serializeObject(MyObject value, JsonGenerator jgen, SerializerProvider provider)
                throws IOException {
            jgen.writeStringField("name", value.getName());
            jgen.writeNumberField("age", value.getAge());
        }

    }

    public static class Deserializer extends JsonObjectDeserializer<MyObject> {

        @Override
        protected MyObject deserializeObject(JsonParser jsonParser, DeserializationContext context, ObjectCodec codec,
                JsonNode tree) throws IOException {
            String name = nullSafeValue(tree.get("name"), String.class);
            int age = nullSafeValue(tree.get("age"), Integer.class);
            return new MyObject(name, age);
        }

    }

}
```

#### MessageCodesResolver

스프링 MVC는 바인딩 에러를 가지고 에러 메세지를 렌더링하기 위한 에러 코드 생성 전략으로 `MessageCodesResolver`를 사용한다. `spring.mvc.message-codes-resolver-format` 프로퍼티를 `PREFIX_ERROR_CODE`나 `POSTFIX_ERROR_CODE`로 설정하면 스프링 부트가 `MessageCodesResolver`를 자동으로 만들어준다 ([`DefaultMessageCodesResolver.Format`](https://docs.spring.io/spring-framework/docs/5.3.8/javadoc-api/org/springframework/validation/DefaultMessageCodesResolver.Format.html)에서 enum 참고).

#### Static Content

기본적으로 스프링 부트는 클래스패스의 `/static` (또는 `/public`, `/resources`, `/META-INF/resources`) 디렉토리나 `ServletContext`의 루트에서 스태틱 컨텐츠를 서빙한다. 이땐 스프링 MVC의 `ResourceHttpRequestHandler`를 사용하므로, 자체 `WebMvcConfigurer`를 추가해서 `addResourceHandlers` 메소드를 재정의하면 이 동작을 수정할 수 있다.

독립형 웹 애플리케이션에선 컨테이너의 디폴트 서블릿도 활성화된다. 디폴트 서블릿은 요청을 스프링이 처리하지 않기로 결정했을 때 `ServletContext`의 루트에 있는 컨텐츠를 서빙하는 폴백 역할을 담당한다. 하지만 이런 일은 거의 발생하지 않는데 (디폴트 MVC 설정을 수정하지 않는 한), 스프링은 `DispatcherServlet`을 통해 모든 요청을 처리할 수 있기 때문이다.

기본적으로 리소스는 `/**`에 매핑되지만, `spring.mvc.static-path-pattern` 프로퍼티로 변경할 수 있다. 예를 들어 모든 리소스를 `/resources/**`로 재배치하고 싶으면 다음과 같이 작성하면 된다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.mvc.static-path-pattern=/resources/**
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  mvc:
    static-path-pattern: "/resources/**"
```

`spring.web.resources.static-locations` 프로퍼티로 스태틱 리소스 위치를 커스텀해도 된다 (여기에 디렉토리 위치 리스트를 정의하면 디폴트 값을 대체한다). 루트 서블릿 컨텍스트 path `"/"`는 자동으로 위치 중 하나로 추가된다.

앞에서 언급한 "표준" 스태틱 리소스 위치 외에도 [Webjars 컨텐츠](https://www.webjars.org/)를 위한 특별한 경로가 있다. `/webjars/**` 경로를 사용하는 모든 리소스는, Webjars 형식으로 패키징되어 있다면 jar 파일에서 서빙한다.

> 애플리케이션을 jar로 패키징한다면 `src/main/webapp` 디렉토리는 사용하지 마라. 이 디렉토리는 공통 표준 디렉토리지만, war 패키징**에서만** 동작하며, jar를 생성하면 빌드 툴 대부분이 오류 없이 무시하고 넘어간다.

스프링 부트는 스프링 MVC에서 제공하는 고급 리소스 핸들링 기능도 지원해서, 스태틱 리소스에 캐시 버스팅을 활용할 수 있고, Webjars 버전을 명시하지 않고도 URL을 지정할 수 있다.

URL을 Webjars 버전 없이 사용하고 싶다면 `webjars-locator-core` 의존성을 추가해라. 그런 다음 원하는 Webjar를 선언해라. jQuery로 예를 들면, <span class="custom-blockquote">"/webjars/jquery/jquery.min.js"</span>를 추가하면 <span class="custom-blockquote">"/webjars/jquery/x.y.z/jquery.min.js"</span>로 이어진다. 여기서 `x.y.z`는 Webjar 버전이다.

> JBoss를 사용한다면 `webjars-locator-core` 의존성 대신 `webjars-locator-jboss-vfs`를 선언해야 한다. 그렇지 않으면 모든 Webjars를 `404`로 리졸브한다.

캐시 버스팅을 사용하려면, 아래 설정을 넣으면 모든 스태틱 리소스에 캐시 버스팅 솔루션을 구성해서 URL에 <span class="custom-blockquote">\<link href="/css/spring-2a2d595e6ed9a0b24f027f2b63b134d6.css"/\></span>와 같이 컨텐츠 해시 값을 추가해준다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.web.resources.chain.strategy.content.enabled=true
spring.web.resources.chain.strategy.content.paths=/**
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  web:
    resources:
      chain:
        strategy:
          content:
            enabled: true
            paths: "/**"
```

> 템플릿에서 리소스를 가리키는 링크는 Thymeleaf와 FreeMarker에서 자동 설정되는 `ResourceUrlEncodingFilter` 덕분에 런타임에 재작성된다. JSP를 사용할 때는 이 필터를 수동으로 선언해야 한다. 다른 템플릿 엔진은 현재로썬 자동 설정을 지원하지 않지만, 커스텀 템플릿 매크로/헬퍼와 [`ResourceUrlProvider`](https://docs.spring.io/spring-framework/docs/5.3.8/javadoc-api/org/springframework/web/servlet/resource/ResourceUrlProvider.html)를 사용할 순 있다.

JavaScript 모듈 로더 등으로 리소스를 동적으로 로드할 땐 파일명을 변경할 수가 없다. 그렇기 때문에 다른 전략도 지원하고, 원하는 대로 조합도 가능하다. "fixed" 전략에선 다음 예제처럼 파일명을 변경하지 않고, URL에 정적인 문자열로 버전을 추가한다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.web.resources.chain.strategy.content.enabled=true
spring.web.resources.chain.strategy.content.paths=/**
spring.web.resources.chain.strategy.fixed.enabled=true
spring.web.resources.chain.strategy.fixed.paths=/js/lib/
spring.web.resources.chain.strategy.fixed.version=v12
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  web:
    resources:
      chain:
        strategy:
          content:
            enabled: true
            paths: "/**"
          fixed:
            enabled: true
            paths: "/js/lib/"
            version: "v12"
```

이 설정에선 `"/js/lib/"` 아래 있는 JavaScript 모듈은 버전 관리에 fixed 전략을 사용하지만 (` "/v12/js/lib/mymodule.js"`), 다른 리소스에선 여전히 content 전략을 사용하고 있다 (<span class="custom-blockquote">\<link href="/css/spring-2a2d595e6ed9a0b24f027f2b63b134d6.css"/></span>).

지원하는 다른 옵션들은 [`ResourceProperties`](https://github.com/spring-projects/spring-boot/tree/v2.5.2/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/web/ResourceProperties.java)를 확인해봐라.

> 이 기능은 전용 [블로그 게시물](https://spring.io/blog/2014/07/24/spring-framework-4-1-handling-static-web-resources)과 스프링 프레임워크의 [레퍼런스 문서](https://docs.spring.io/spring-framework/docs/5.3.8/reference/html/web.html#mvc-config-static-resources)에서 상세하게 설명하고 있다.

#### Welcome Page

스프링 부트는 웰컴 페이지를 정적으로도, 템플릿으로도 지원한다. 먼저 설정한 스태틱 컨텐츠 위치에서 `index.html` 파일을 찾아본다. 파일을 찾지 못하면 `index` 템플릿을 찾는다. 둘 중 하나라도 있으면 자동으로 애플리케이션의 웰컴 페이지로 사용한다.

#### Path Matching and Content Negotiation

스프링 MVC에선 요청 경로를 애플리케이션에 정의된 매핑(ex. 컨드롤러 메소드의 `@GetMapping` 어노테이션)과 매칭하는 식으로 들어오는 HTTP 요청을 핸들러에 매핑한다.

스프링 부트는 기본적으로 suffix 패턴 매칭을 비활성화시킨다. 즉, `"GET /projects/spring-boot.json"`과 같은 요청은 `@GetMapping("/projects/spring-boot")` 매핑에 매칭되지 않는다. suffix 패턴 매칭은 사용하지 않는 걸 [스프링 MVC 애플리케이션의 베스트 프랙티스](https://docs.spring.io/spring-framework/docs/5.3.8/reference/html/web.html#mvc-ann-requestmapping-suffix-pattern-match)로 여긴다. 이 기능은 과거에 적절한 "Accept" 요청 헤더를 보내지 않는 HTTP 클라이언트때문에 주로 사용하곤 했다. 이땐 클라이언트에 올바른 Content Type을 전송해주기 위해 필요했다. 하지만 요즘 Content Negotiation은 훨씬 더 안정적이다.

그래도 "Accept" 헤더를 제대로 보내지 않는 HTTP 클라이언트가 있다면 다른 방법으로 해결할 수 있다. suffix 매칭을 사용하는 대신 쿼리 파라미터를 이용해서 `"GET /projects/spring-boot?format=json"`같은 요청을 `@GetMapping("/projects/spring-boot")`에 매핑시켜도 된다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.mvc.contentnegotiation.favor-parameter=true
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  mvc:
    contentnegotiation:
      favor-parameter: true
```

다른 파라미터명을 사용하고 싶다면:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.mvc.contentnegotiation.favor-parameter=true
spring.mvc.contentnegotiation.parameter-name=myparam
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  mvc:
    contentnegotiation:
      favor-parameter: true
      parameter-name: "myparam"
```

표준 media type은 대부분 기본으로 지원하긴 하지만, 다른 media type을 새로 정의할 수도 있다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.mvc.contentnegotiation.media-types.markdown=text/markdown
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
  mvc:
    contentnegotiation:
      media-types:
        markdown: "text/markdown"
```

Suffix 패턴 매칭은 더 이상 사용하지 않으며<sup>deprecated</sup>, 향후 릴리즈에서 제거할 예정이다. 주의 사항은 확인했지만 그래도 애플리케이션에서 suffix 패턴 매칭을 사용하고 싶다면, 아래 설정이 필요하다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.mvc.contentnegotiation.favor-path-extension=true
spring.mvc.pathmatch.use-suffix-pattern=true
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  mvc:
    contentnegotiation:
      favor-path-extension: true
    pathmatch:
      use-suffix-pattern: true
```

아니면 suffix 패턴을 전부 열어주는 대신, 더 안전하게 등록한 suffix 패턴만 지원해도 된다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.mvc.contentnegotiation.favor-path-extension=true
spring.mvc.pathmatch.use-registered-suffix-pattern=true
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  mvc:
    contentnegotiation:
      favor-path-extension: true
    pathmatch:
      use-registered-suffix-pattern: true
```

스프링 프레임워크 5.3부터 스프링 MVC는 요청 경로를 컨트롤러 핸들러에 매칭시키기 위한 여러 구현 전략을 지원한다. 이전에는 `AntPathMatcher` 전략만 지원했지만, 현재는 `PathPatternParser`도 제공한다. 이제 스프링 부트에선 설정 프로퍼티를 통해 새로 도입된 전략을 선택할 수 있다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.mvc.pathmatch.matching-strategy=path-pattern-parser
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  mvc:
    pathmatch:
      matching-strategy: "path-pattern-parser"
```

새로운 구현체를 고려해봐야 하는 이유가 궁금하다면 [전용 블로그 게시물](https://spring.io/blog/2020/06/30/url-matching-with-pathpattern-in-spring-mvc)에서 자세한 내용을 확인해봐라.

> `PathPatternParser`는 최적화된 구현체이긴 하지만, [몇 가지 변형된 path 패턴](https://docs.spring.io/spring-framework/docs/5.3.8/reference/html/web.html#mvc-ann-requestmapping-uri-templates)은 사용할 수 없으며, suffix 패턴 매칭(<span class="custom-blockquote">spring.mvc.pathmatch.use-suffix-pattern</span>, <span class="custom-blockquote">spring.mvc.pathmatch.use-registered-suffix-pattern</span>)이나 서블릿 프리픽스(<span class="custom-blockquote">spring.mvc.servlet.path</span>)를 사용하는 `DispatcherServlet` 매핑과는 호환되지 않는다.

#### ConfigurableWebBindingInitializer

스프링 MVC는 요청을 받으면 `WebBindingInitializer`를 사용해서 `WebDataBinder`를 초기화한다. 자체 `ConfigurableWebBindingInitializer` `@Bean`을 생성하면 스프링 부트는 자동으로 스프링 MVC에서 이 빈을 사용하도록 설정해준다.

#### Template Engines

스프링 MVC를 사용하면 REST 웹 서비스도 가능하지만, 동적인 HTML 컨텐츠도 서빙할 수 있다. 스프링 MVC는 Thymeleaf, FreeMarker, JSP 등 다양한 템플릿 기술을 지원한다. 그외 템플릿 엔진 중에는 자체 스프링 MVC 통합을 지원하는 엔진도 많다.

스프링 부트는 아래 템플릿 엔진을 위한 자동 설정을 지원하고 있다:

- [FreeMarker](https://freemarker.apache.org/docs/)
- [Groovy](https://docs.groovy-lang.org/docs/next/html/documentation/template-engines.html#_the_markuptemplateengine)
- [Thymeleaf](https://www.thymeleaf.org/)
- [Mustache](https://mustache.github.io/)

> 가능하면 JSP는 사용하지 않는게 좋다. 임베디드 서블릿 컨테이너에서 JSP를 사용하게 되면 몇 가지 [제약이 생긴다](#jsp-limitations).

디폴트 설정으로 이 템플릿 엔진 중 하나를 사용하면 자동으로 `src/main/resources/templates`에서 템플릿을 찾아 선택해준다.

> 애플리케이션을 실행하는 방법에 따라 IDE에서 클래스패스를 다르게 정렬하기도 한다. IDE에서 메인 메소드로 애플리케이션을 실행하면, 메이븐이나 그래들로 실행할 때와, 패키징한 jar를 실행할 때와는 순서가 달라진다. 이런 점 때문에 스프링 부트에서 기대하는 템플릿을 찾지 못할 수도 있다. 이 문제가 발생하면 모듈의 클래스와 리소스를 먼저 배치하도록 IDE에서 클래스패스를 재정렬할 수 있다.

#### Error Handling

스프링 부트는 모든 에러를 적당한 방법으로 처리해주는 `/error` 매핑을 기본으로 제공하며, 서블릿 컨테이너에 "글로벌" 에러 페이지로 등록한다. 머신 클라이언트에겐 에러, HTTP 상태, 예외 메세지를 상세히 가지고 있는 JSON 응답을 내려준다. 브라우저 클라이언트에겐 같은 데이터를 HTML 형식으로 렌더링하는 "whitelabel" 에러 뷰를 사용한다 (커스텀하려면 `error`로 리졸브하는 `View`를 추가해라).

기본 에러 처리 동작을 커스텀하고 싶을때는 다양한 `server.error` 프로퍼티를 활용하면 된다. 부록에 있는 ["서버 프로퍼티"](https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#application-properties.server) 섹션을 참고해라.

기본 동작을 완전히 바꾸려면 `ErrorController`를 구현해서 이 타입으로 빈을 등록하고, 기존 메커니즘을 사용하되 내용만 변경하고 싶으면 `ErrorAttributes` 타입의 빈을 추가하면 된다.

> `ErrorController`를 커스텀 할땐 베이스 클래스로 `BasicErrorController`를 활용할 수 있다. 새 컨텐츠 타입을 처리하는 핸들러를 추가한다면 특히 유용할 거다 (디폴트 `ErrorController`는 `text/html` 처리를 위한 메소드를 따로 정의하고, 그외 다른 컨텐츠 타입들을 위한 폴백을 제공하고 있다). `BasicErrorController`를 상속해서 public 메소드를 추하고, `@RequestMapping`에 `produces` 속성을 지정한 다음, 빈으로 정의해주면 된다.

아래 예제처럼 `@ControllerAdvice` 어노테이션을 선언한 클래스를 정의해서 특정 컨트롤러나 예외 타입에서 반환할 JSON 문서를 커스텀할 수도 있다:

```java
@ControllerAdvice(basePackageClasses = SomeController.class)
public class MyControllerAdvice extends ResponseEntityExceptionHandler {

    @ResponseBody
    @ExceptionHandler(MyException.class)
    public ResponseEntity<?> handleControllerException(HttpServletRequest request, Throwable ex) {
        HttpStatus status = getStatus(request);
        return new ResponseEntity<>(new MyErrorBody(status.value(), ex.getMessage()), status);
    }

    private HttpStatus getStatus(HttpServletRequest request) {
        Integer code = (Integer) request.getAttribute(RequestDispatcher.ERROR_STATUS_CODE);
        HttpStatus status = HttpStatus.resolve(code);
        return (status != null) ? status : HttpStatus.INTERNAL_SERVER_ERROR;
    }

}
```

위 예제에선 `SomeController`와 같은 패키지에 정의한 컨트롤러에서 `YourException`이 발생하면, 에러를 `ErrorAttributes`로 표현하지 않고, 그대신 `CustomErrorType` POJO를 JSON으로 표현한다.

경우에 따라서 컨트롤러 레벨에서 처리한 에러는 [메트릭 인프라](../metrics/#spring-mvc-metrics)에 기록하지 않는다. 애플리케이션에서 처리한 예외를 요청 속성으로 설정해주면, 이런 예외도 요청 메트릭과 함께 기록하도록 만들 수 있다:

```java
@Controller
public class MyController {

    @ExceptionHandler(CustomException.class)
    String handleCustomException(HttpServletRequest request, CustomException ex) {
        request.setAttribute(ErrorAttributes.ERROR_ATTRIBUTE, ex);
        return "errorView";
    }

}
```

##### Custom Error Pages

원하는 상태 코드에서 커스텀 HTML 오류 페이지를 노출하려면 `/error` 디렉토리에 파일을 추가하면 된다. 에러 페이지는 정적인 HTML일 수도 있고 (즉, 스태틱 리소스 디렉토리 아래에 추가), 템플릿으로 빌드할 수도 있다. 파일 이름은 정확한 상태 코드를 사용하거나, 시리즈 마스크를 사용해야 한다.

예를 들어서 `404`를 정적인 HTML 파일에 매핑할 때의 디렉토리 구조는 다음과 같다:

```
src/
 +- main/
     +- java/
     |   + <source code>
     +- resources/
         +- public/
             +- error/
             |   +- 404.html
             +- <other public assets>
```

FreeMarker 템플릿으로 모든 `5xx` 에러를 매핑할 때의 디렉토리 구조는 다음과 같다:

```
src/
 +- main/
     +- java/
     |   + <source code>
     +- resources/
         +- templates/
             +- error/
             |   +- 5xx.ftlh
             +- <other templates>
```

매핑이 좀 복잡하다면, 다음 예제처럼 `ErrorViewResolver` 인터페이스를 구현한 빈을 추가해도 된다:

```java
public class MyErrorViewResolver implements ErrorViewResolver {

    @Override
    public ModelAndView resolveErrorView(HttpServletRequest request, HttpStatus status, Map<String, Object> model) {
        // Use the request or status to optionally return a ModelAndView
        if (status == HttpStatus.INSUFFICIENT_STORAGE) {
            // We could add custom model values here
            new ModelAndView("myview");
        }
        return null;
    }

}
```

[`@ExceptionHandler` 메소드](https://docs.spring.io/spring-framework/docs/5.3.8/reference/html/web.html#mvc-exceptionhandlers)나 [`@ControllerAdvice`](https://docs.spring.io/spring-framework/docs/5.3.8/reference/html/web.html#mvc-ann-controller-advice)같은 대표적인 스프링 MVC 기능들도 사용할 수 있다. 이 기능을 사용하면 `ErrorController`에선 처리되지 않은 예외만 처리한다.

##### Mapping Error Pages outside of Spring MVC

스프링 MVC를 사용하지 않는 애플리케이션에선 `ErrorPageRegistrar` 인터페이스를 통해 `ErrorPages`를 직접 등록할 수 있다. 이 인터페이스는 임베디드 서블릿 컨테이너와 직접 동작하며, 스프링 MVC `DispatcherServlet`이 없어도 작동한다.

```java
@Configuration(proxyBeanMethods = false)
public class MyErrorPagesConfiguration {

    @Bean
    public ErrorPageRegistrar errorPageRegistrar() {
        return this::registerErrorPages;
    }

    private void registerErrorPages(ErrorPageRegistry registry) {
        registry.addErrorPages(new ErrorPage(HttpStatus.BAD_REQUEST, "/400"));
    }

}
```

> `Filter`에서 처리하는 경로에 `ErrorPage`를 등록한다면 (`Filter`는 Jersey, Wicket같은 스프링 웹 이외의 프레임워크 일부에서 흔히 사용한다), 아래 예제처럼 `Filter`를 직접 `ERROR` 디스패처로 등록해야 한다:

```java
@Configuration(proxyBeanMethods = false)
public class MyFilterConfiguration {

    @Bean
    public FilterRegistrationBean<MyFilter> myFilter() {
        FilterRegistrationBean<MyFilter> registration = new FilterRegistrationBean<>(new MyFilter());
        // ...
        registration.setDispatcherTypes(EnumSet.allOf(DispatcherType.class));
        return registration;
    }

}
```

디폴트 `FilterRegistrationBean`은 `ERROR` 디스패처 타입을 포함하지 않는다는 점을 참고해라.

##### Error handling in a war deployment

애플리케이션을 서블릿 컨테이너에 배포하면 스프링 부트는 에러 페이지 필터를 사용해서 요청을 에러 상태와 함께 적절한 오류 페이지로 전달한다. 서블릿 사양에선 에러 페이지를 등록하기 위한 API를 제공하지 않기 때문에 에러 페이지 필터가 필요하다. war 파일을 배포하는 컨테이너와 애플리케이션에서 사용하는 기술에 따라 몇 가지 설정이 더 필요할 수도 있다.

에러 페이지 필터에선 응답을 아직 커밋하지 않았을 때에만 요청을 올바른 에러 페이지로 전달할 수 있다. 기본적으로 WebSphere Application Server 8.0 이상은 서블릿의 서비스 메소드가 문제 없이 완료되면 응답을 커밋한다. <span class="custom-blockquote">com.ibm.ws.webcontainer.invokeFlushAfterService</span>를 `false`로 설정해서 이 동작을 비활성화해야 한다.

스프링 시큐리티를 사용 중이며 에러 페이지에서 principal에 액세스하고 싶다면, 에러를 전송할 때 스프링 시큐리티의 필터를 호출하도록 설정해야 한다. <span class="custom-blockquote">spring.security.filter.dispatcher-types</span> 프로퍼티를 <span class="custom-blockquote">async, error, forward, request</span>로 설정하면 된다.

#### Spring HATEOAS

하이퍼미디어를 이용하는 RESTful API를 개발하고 있다면, 스프링 부트는 대부분의 애플리케이션에 잘 맞는 스프링 HATEOAS 자동 설정을 제공한다. 자동 설정을 사용하면 `@EnableHypermediaSupport`를 선언하지 않아도 되고, `LinkDiscoverers`(클라이언트 사이드 기능)와 응답을 원하는 표현으로 적절히 마샬링할 수 있는 `ObjectMapper` 등, 하이퍼미디어 기반 애플리케이션 구축을 도와주는 여러 가지 빈을 등록해준다. `ObjectMapper`는 다양한 `spring.jackson.*` 프로퍼티로 커스텀할 수 있으며, `Jackson2ObjectMapperBuilder` 빈을 등록해서 커스텀할 수도 있다.

스프링 HATEOAS의 설정은 `@EnableHypermediaSupport`를 통해 제어할 수 있다. 이 어노테이션을 선언하면 앞에서 설명한 `ObjectMapper` 커스텀은 비활성화된다.

#### CORS Support

[CORS](https://en.wikipedia.org/wiki/Cross-origin_resource_sharing)<sup>Cross-origin resource sharing</sup>는 [대부분의 브라우저](https://caniuse.com/#feat=cors)에서 구현하고 있는 [W3C 사양](https://www.w3.org/TR/cors/)으로, 허용할 cross-domain 요청을 유연하게 지정할 수 있다. 아이프레임이나 JSONP보다 더 안전하고 확실한 방법이다.

스프링 MVC는 4.2 버전부터 [CORS를 지원한다](https://docs.spring.io/spring-framework/docs/5.3.8/reference/html/web.html#mvc-cors). 스프링 부트 애플리케이션에서 [컨트롤러 메소드 CORS 설정](https://docs.spring.io/spring-framework/docs/5.3.8/reference/html/web.html#mvc-cors-controller)으로 활용할 수 있는 [`@CrossOrigin`](https://docs.spring.io/spring-framework/docs/5.3.8/javadoc-api/org/springframework/web/bind/annotation/CrossOrigin.html) 어노테이션은 별다른 설정을 요구하지 않는다. [글로벌 CORS 설정](https://docs.spring.io/spring-framework/docs/5.3.8/reference/html/web.html#mvc-cors-global)은 아래 보이는 것처럼 `WebMvcConfigurer` 빈을 등록하고 `addCorsMappings(CorsRegistry)` 메소드를 커스텀해서 정의할 수 있다:

```java
@Configuration(proxyBeanMethods = false)
public class MyCorsConfiguration {

    @Bean
    public WebMvcConfigurer corsConfigurer() {
        return new WebMvcConfigurer() {

            @Override
            public void addCorsMappings(CorsRegistry registry) {
                registry.addMapping("/api/**");
            }

        };
    }

}
```

### 7.7.2. The “Spring WebFlux Framework”

스프링 웹플럭스는 스프링 프레임워크 5.0에서 도입한 새로운 리액티브 웹 프레임워크다. 스프링 MVC와는 달리 서블릿 API가 필요 없으며, 완전한 비동기 논블로킹으로 동작하고, [리액터 프로젝트](https://projectreactor.io/)를 통해 [리액티브 스트림즈](https://www.reactive-streams.org/) 사양을 구현한다.

스프링 웹플럭스는 함수형, 어노테이션 기반, 이 두 가지 버전으로 즐길 수 있다. 어노테이션 기반은 아래 예제에서 알 수 있듯이 스프링 MVC 모델과 매우 유사하다:

```java
@RestController
@RequestMapping("/users")
public class MyRestController {

    private final UserRepository userRepository;

    private final CustomerRepository customerRepository;

    public MyRestController(UserRepository userRepository, CustomerRepository customerRepository) {
        this.userRepository = userRepository;
        this.customerRepository = customerRepository;
    }

    @GetMapping("/{user}")
    public Mono<User> getUser(@PathVariable Long userId) {
        return this.userRepository.findById(userId);
    }

    @GetMapping("/{user}/customers")
    public Flux<Customer> getUserCustomers(@PathVariable Long userId) {
        return this.userRepository.findById(userId).flatMapMany(this.customerRepository::findByUser);
    }

    @DeleteMapping("/{user}")
    public void deleteUser(@PathVariable Long userId) {
        this.userRepository.deleteById(userId);
    }

}
```

"WebFlux.fn"은 함수형 버전인데, 아래 예제에서 보이듯 라우팅 설정을 실제 요청 처리 로직과 분리시킨다:

```java
@Configuration(proxyBeanMethods = false)
public class MyRoutingConfiguration {

    private static final RequestPredicate ACCEPT_JSON = accept(MediaType.APPLICATION_JSON);

    @Bean
    public RouterFunction<ServerResponse> monoRouterFunction(MyUserHandler userHandler) {
        return route(
                GET("/{user}").and(ACCEPT_JSON), userHandler::getUser).andRoute(
                GET("/{user}/customers").and(ACCEPT_JSON), userHandler::getUserCustomers).andRoute(
                DELETE("/{user}").and(ACCEPT_JSON), userHandler::deleteUser);
    }

}
```

```java
@Component
public class MyUserHandler {

    public Mono<ServerResponse> getUser(ServerRequest request) {
        ...
    }

    public Mono<ServerResponse> getUserCustomers(ServerRequest request) {
        ...
    }

    public Mono<ServerResponse> deleteUser(ServerRequest request) {
        ...
    }

}
```

웹플럭스는 스프링 프레임워크에 속하며, 자세한 정보는 [레퍼런스 문서](../../Reactive%20Spring/springwebflux2/#15-functional-endpoints)에서 확인하면 된다.

> `RouterFunction` 빈은 라우터 정의를 모듈화하고 싶은 만큼 여러 번 정의해도 된다. 필요하다면 빈에 우선 순위를 적용할 수 있다.

웹플럭스를 시작하려면 애플리케이션에 `spring-boot-starter-webflux` 모듈을 추가해라.

> 애플리케이션에 `spring-boot-starter-web`과 `spring-boot-starter-webflux` 모듈을 둘 다 추가하면, 스프링 부트는 웹플럭스가 아닌 스프링 MVC를 자동 설정한다. 이같이 동작하는 이유는 많은 스프링 개발자들이 스프링 MVC 애플리케션에서 리액티브 `WebClient`를 사용하기 위해 `spring-boot-starter-webflux`를 추가하기 때문이다. <span class="custom-blockquote">SpringApplication.setWebApplicationType(WebApplicationType.REACTIVE)</span>를 설정해주면 사용할 애플리케이션 유형을 강제할 수 있다.

#### Spring WebFlux Auto-configuration

스프링 부트는 대부분의 애플리케이션에 잘 맞는 스프링 웹플럭스 자동 설정을 제공한다.

스프링의 기본 기능 위에 아래 기능들이 자동 설정으로 추가된다:

- `HttpMessageReader`와 `HttpMessageWriter` 인스턴스를 위한 코덱 설정 ([뒤](#http-codecs-with-httpmessagereaders-and-httpmessagewriters)에서 설명).
- WebJars 지원을 포함하는 스태틱 리소스 서빙 기능 ([뒤](#static-content-1)에서 설명).

여기 있는 스프링 부트 웹플럭스 기능은 그대로 활용하면서 다른 [웹플럭스 설정](../../Reactive%20Spring/springwebflux2/#111-webflux-config)을 추가하고 싶다면, `WebFluxConfigurer` 타입의 자체 `@Configuration` 클래스를 `@EnableWebFlux` **없이** 추가하면 된다.

스프링 웹플럭스를 완전히 제어하고 싶다면, 자체 `@Configuration`에 `@EnableWebFlux` 어노테이션을 추가하면 된다.

#### HTTP Codecs with HttpMessageReaders and HttpMessageWriters

스프링 웹플럭스는 `HttpMessageReader`, `HttpMessageWriter` 인터페이스를 통해 HTTP 요청과 응답을 변환한다.   `HttpMessageReader`와 `HttpMessageWriter`는 `CodecConfigurer`가 클래스패스에서 사용 가능한 라이브러리를 살펴본 뒤 합리적인 기본값을 설정해준다.

스프링 부트는 코덱 설정을 위한 전용 프로퍼티 `spring.codec.*`을 제공하며, `CodecCustomizer` 인스턴스를 통해서도 커스텀할 수 있다. 예를 들어 `spring.jackson.*` 설정 키는 Jackson 코덱에 적용된다.

코덱을 추가하거나 커스텀해야 한다면 다음 예제처럼 커스텀 `CodecCustomizer` 컴포넌트를 만들면 된다:

```java
@Configuration(proxyBeanMethods = false)
public class MyCodecsConfiguration {

    @Bean
    public CodecCustomizer myCodecCustomizer() {
        return (configurer) -> {
            configurer.registerDefaults(false);
            configurer.customCodecs().register(new ServerSentEventHttpMessageReader());
            // ...
        };
    }

}
```

[부트의 커스텀 JSON 시리얼라이저와 디시리얼라이저](#custom-json-serializers-and-deserializers)를 활용해도 된다.

#### Static Content

기본적으로 스프링 부트는 클래스패스의 `/static` (또는 `/public`, `/resources`, `/META-INF/resources`) 디렉토리에서 스태틱 컨텐츠를 서빙한다. 이땐 스프링 웹플럭스의 `ResourceWebHandler`를 사용하므로, 자체 `WebFluxConfigurer`를 추가해서 `addResourceHandlers` 메소드를 재정의하면 이 동작을 수정할 수 있다.

기본적으로 리소스는 `/**`에 매핑되지만, `spring.webflux.static-path-pattern` 프로퍼티로 변경할 수 있다. 예를 들어 모든 리소스를 `/resources/**`로 재배치하고 싶으면 다음과 같이 작성하면 된다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.webflux.static-path-pattern=/resources/**
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  webflux:
    static-path-pattern: "/resources/**"
```

`spring.web.resources.static-locations` 프로퍼티로 스태틱 리소스 위치를 커스텀해도 된다. 여기에 디렉토리 위치 리스트를 정의하면 디폴트 값을 대체한다. 이렇게하면 디폴트 웰컴 페이지를 커스텀한 위치에서 찾게된다. 따라서 기동 시 정의한 위치에 `index.html`이 있으면 애플리케이션의 웰컴 페이지로 사용한다.

앞에서 언급한 "표준" 스태틱 리소스 위치 외에도 [Webjars 컨텐츠](https://www.webjars.org/)를 위한 특별한 경로가 있다. `/webjars/**` 경로를 사용하는 모든 리소스는, Webjars 형식으로 패키징되어 있다면 jar 파일에서 서빙한다.

> 스프링 웹플럭스 애플리케이션은 서블릿 API에 절대적으로 의존하지 않기 때문에, war 파일로 배포할 수 없으며, `src/main/webapp` 디렉토리를 사용하지 않는다.

#### Welcome Page

스프링 부트는 웰컴 페이지를 정적으로도, 템플릿으로도 지원한다. 먼저 설정한 스태틱 컨텐츠 위치에서 `index.html` 파일을 찾아본다. 파일을 찾지 못하면 `index` 템플릿을 찾는다. 둘 중 하나라도 있으면 자동으로 애플리케이션의 웰컴 페이지로 사용한다.

#### Template Engines

스프링 웹플럭스를 사용하면 REST 웹 서비스도 가능하지만, 동적인 HTML 컨텐츠도 서빙할 수 있다. 스프링 웹플럭스는 Thymeleaf, FreeMarker, JSP, Mustache 등의 다양한 템플릿 기술을 지원한다.

스프링 부트는 아래 템플릿 엔진을 위한 자동 설정을 지원하고 있다:

- [FreeMarker](https://freemarker.apache.org/docs/)
- [Thymeleaf](https://www.thymeleaf.org/)
- [Mustache](https://mustache.github.io/)

디폴트 설정으로 이 템플릿 엔진 중 하나를 사용하면 자동으로 `src/main/resources/templates`에서 템플릿을 찾아 선택해준다.

#### Error Handling

스프링 부트는 모든 에러를 적당한 방법으로 처리해주는 `WebExceptionHandler`를 제공한다. 처리 순서는 웹플럭스에서 제공하는 핸들러 바로 앞으로, 웹플럭스가 제공하는 핸들러는 가장 마지막에 호출한다. 머신 클라이언트에겐 에러, HTTP 상태, 예외 메세지를 상세히 가지고 있는 JSON 응답을 내려준다. 브라우저 클라이언트에겐 같은 데이터를 HTML 형식으로 렌더링하는 "whitelabel" 에러 뷰를 사용한다. 에러를 노출해줄 자체 HTML 템플릿을 제공해도 된다 ([다음 섹션](#custom-error-pages-1) 참고).

이 기능을 커스텀할 때는 보통 기존 메커니즘을 사용하되, 에러 컨텐츠를 교체하거나 보강하는 것부터 시작한다. 이땐 `ErrorAttributes` 타입 빈을 추가하면 된다.

에러 처리 방식을 바꾸고 싶다면 `ErrorWebExceptionHandler`를 구현해서 이 타입으로 빈을 정의하면 된다. `ErrorWebExceptionHandler`는 꽤 저수준이기 때문에, 스프링 부트는 다음 예제와 같이 웹플럭스의 함수형 버전으로 에러를 처리할 수 있는 간편한 `AbstractErrorWebExceptionHandler`도 제공한다:

```java
@Component
public class MyErrorWebExceptionHandler extends AbstractErrorWebExceptionHandler {

    public MyErrorWebExceptionHandler(ErrorAttributes errorAttributes, Resources resources,
            ApplicationContext applicationContext) {
        super(errorAttributes, resources, applicationContext);
    }

    @Override
    protected RouterFunction<ServerResponse> getRoutingFunction(ErrorAttributes errorAttributes) {
        return RouterFunctions.route(this::acceptsXml, this::handleErrorAsXml);
    }

    private boolean acceptsXml(ServerRequest request) {
        return request.headers().accept().contains(MediaType.APPLICATION_XML);
    }

    public Mono<ServerResponse> handleErrorAsXml(ServerRequest request) {
        BodyBuilder builder = ServerResponse.status(HttpStatus.INTERNAL_SERVER_ERROR);
        // ... additional builder calls
        return builder.build();
    }

}
```

완성도를 높이고 싶으면 `DefaultErrorWebExceptionHandler`를 직접 상속해서 원하는 메소드를 재정의해도 된다.

경우에 따라서 컨트롤러나 핸들러 펑션 레벨에서 처리한 에러는 [메트릭 인프라](../metrics/#spring-webflux-metrics)에 기록하지 않는다. 애플리케이션에서 처리한 예외를 요청 속성으로 설정해주면, 이런 예외도 요청 메트릭과 함께 기록하도록 만들 수 있다:

```java
@Controller
public class MyExceptionHandlingController {

    @GetMapping("/profile")
    public Rendering userProfile() {
        // ...
        throw new IllegalStateException();
    }

    @ExceptionHandler(IllegalStateException.class)
    public Rendering handleIllegalState(ServerWebExchange exchange, IllegalStateException exc) {
        exchange.getAttributes().putIfAbsent(ErrorAttributes.ERROR_ATTRIBUTE, exc);
        return Rendering.view("errorView").modelAttribute("message", exc.getMessage()).build();
    }

}
```

##### Custom Error Pages

원하는 상태 코드에서 커스텀 HTML 오류 페이지를 노출하려면 `/error` 디렉토리에 파일을 추가하면 된다. 에러 페이지는 정적인 HTML일 수도 있고 (즉, 스태틱 리소스 디렉토리 아래에 추가), 템플릿으로 빌드할 수도 있다. 파일 이름은 정확한 상태 코드를 사용하거나, 시리즈 마스크를 사용해야 한다.

예를 들어서 `404`를 정적인 HTML 파일에 매핑할 때의 디렉토리 구조는 다음과 같다:

```
src/
 +- main/
     +- java/
     |   + <source code>
     +- resources/
         +- public/
             +- error/
             |   +- 404.html
             +- <other public assets>
```

Mustache 템플릿으로 모든 `5xx` 에러를 매핑할 때의 디렉토리 구조는 다음과 같다:

```
src/
 +- main/
     +- java/
     |   + <source code>
     +- resources/
         +- templates/
             +- error/
             |   +- 5xx.mustache
             +- <other templates>
```

#### Web Filters

스프링 웹플럭스는 HTTP 요청-응답 exchange를 필터링할 때 구현할 수 있는 `WebFilter` 인터페이스를 제공한다. 애플리케이션 컨텍스트에서 발견한 `WebFilter` 빈은 각 exchange를 필터링할 때 자동으로 쓰인다.

필터의 순서가 중요한다면 `Ordered`를 구현하거나 `@Order` 어노테이션을 달면 된다. 스프링 부트 자동 설정으로 웹 필터를 설정해도 된다. 스프링 부트에선 아래 테이블에 정리된 순서대로 필터를 적용한다:

| Web Filter                              | Order                            |
| :-------------------------------------- | :------------------------------- |
| `MetricsWebFilter`                      | `Ordered.HIGHEST_PRECEDENCE + 1` |
| `WebFilterChainProxy` (스프링 시큐리티) | `-100`                           |
| `HttpTraceWebFilter`                    | `Ordered.LOWEST_PRECEDENCE - 10` |

### 7.7.3. JAX-RS and Jersey

REST 엔드포인트로 JAX-RS 프로그래밍 모델을 선호한다면 스프링 MVC를 대신할 수 있는 구현체를 사용할 수 있다. [Jersey](https://jersey.github.io/)와 [Apache CXF](https://cxf.apache.org/)는 큰 변경 없이도 잘 동작한다. CXF를 사용하려면 애플리케이션 컨텍스트에 `Servlet`이나 `Filter`를 `@Bean`으로 등록해야 한다. Jersey는 자체 스프링 지원을 몇 가지 가지고 있어서, 스프링 부트에서도 스타터와 자동 설정을 지원한다.

Jersey를 시작하려면 `spring-boot-starter-jersey`를 의존성에 추가해라. 그 다음엔 다음 예제와 같이 모든 엔드포인트를 등록하는 `ResourceConfig` 타입 `@Bean` 하나가 필요하다:

```java
@Component
public class MyJerseyConfig extends ResourceConfig {

    public MyJerseyConfig() {
        register(MyEndpoint.class);
    }

}
```

> Jersey는 실행 가능한 아카이브 스캔을 다소 제한적으로 지원한다. 예를 들어 [완전히 실행 가능한 jar<sup>fully executable jar</sup> 파일](../deploying-spring-boot-applications#93-installing-spring-boot-applications)에 있는 패키지의 엔드포인트나, 실행 가능한 war 파일을 실행할 때 쓰는 `WEB-INF/classes`의 엔드포인트를 스캔하지 못한다. 따라서 `packages` 메소드는 사용하지 않는 게 좋으며, 앞의 예제처럼 `register` 메소드를 통해 엔드포인트를 개별적으로 등록해야 한다.

다른 것들을 좀 더 커스텀하고 싶으면, `ResourceConfigCustomizer`를 구현하는 빈을 원하는 만큼 추가해도 된다.

등록한 엔드포인트는 모두 다음 예제처럼 HTTP 리소스 어노테이션(`@GET` 등)을 가지고 있는 `@Component` 여야 한다:

```java
@Component
@Path("/hello")
public class MyEndpoint {

    @GET
    public String message() {
        return "Hello";
    }

}
```

`Endpoint`는 스프링 `@Component`기 때문에, 수명 주기는 스프링에서 관리하며, `@Autowired` 어노테이션을 사용해 의존성을 주입하고 `@Value` 어노테이션으로 외부 설정을 주입할 수 있다. 기본적으로 Jersey 서블릿을 등록해서 `/*`에 매핑한다. `ResourceConfig`에 `@ApplicationPath`를 추가하면 매핑을 변경할 수 있다.

기본적으로 Jersey는 `jerseyServletRegistration`이라는 이름을 가진 `ServletRegistrationBean` 타입 `@Bean`에서 서블릿으로 설정된다. 기본적으로 서블릿은 lazy 방식으로 초기화되지만, <span class="custom-blockquote">spring.jersey.servlet.load-on-startup</span>을 설정하면 커스텀할 수 있다. 같은 이름으로 자체 빈을 작성하면 이 빈을 비활성화하거나 재정의할 수 있다. <span class="custom-blockquote">spring.jersey.type=filter</span>를 설정해서 서블릿 대신 필터를 사용할 수도 있다 (이때는 `jerseyFilterRegistration` `@Bean`으로 대체하거나 재정의할 수 있다). 필터에는 `@Order`가 있어서 <span class="custom-blockquote">spring.jersey.filter.order</span>로 설정해줄 수 있다. Jersey를 필터로 사용하는 경우엔 반드시, Jersey에서 가로채가지 않은 요청을 처리할 Servlet이 있어야 한다. 애플리케이션에 이런 서블릿이 없다면 <span class="custom-blockquote">server.servlet.register-default-servlet</span>을 `true`로 설정해서 디폴트 서블릿을 활성화하는 게 좋다. 서블릿과 필터를 등록할 땐 모두 `spring.jersey.init.*`으로 프로퍼티 맵을 지정해서 init 파라미터를 제공할 수 있다.

### 7.7.4. Embedded Servlet Container Support

스프링 부트는 임베디드 [Tomcat](https://tomcat.apache.org/), [Jetty](https://www.eclipse.org/jetty/), [Undertow](https://github.com/undertow-io/undertow) 서버 지원을 포함한다. 개발자 대부분은 적절한 "스타터"를 사용해서 바로 사용할 수 있게끔 구성된 인스턴스를 가져온다. 임베디드 서버는 기본적으로 `8080` 포트에서 HTTP 요청을 수신<sup>listen</sup>한다.

#### Servlets, Filters, and listeners

임베디드 서블릿 컨테이너를 사용할 땐 스프링 빈을 사용하거나 서블릿 컴포넌트를 스캔하는 식으로 서블릿 사양에 있는 서블릿과 필터와, 모든 리스너(ex. `HttpSessionListener`)를 등록할 수 있다.

##### Registering Servlets, Filters, and Listeners as Spring Beans

스프링 빈 중에 있는 `Servlet`이나 `Filter`, 서블릿 `*Listener` 인스턴스는 임베디드 컨테이너에 등록된다. `application.properties`에 있는 값을 참조해서 설정하고 싶을 때 특히 편리할 거다.

기본적으로 컨텍스트가 단일 서블릿만 가지고 있다면 `/`에 매핑한다. 서블릿 빈이 여러 개일 땐 빈 이름을 경로 프리픽스로 사용한다. 필터는 `/*`에 매핑한다.

컨벤션 기반으로 매핑하기 힘든 경우 `ServletRegistrationBean`, `FilterRegistrationBean`, `ServletListenerRegistrationBean` 클래스를 사용하면 매핑을 완전히 제어할 수 있다.

보통은 필터 빈엔 순서를 두지 않는 게 안전하다. 특정 순서로 실행해야 한다면 `Filter`에 `@Order` 어노테이션을 달거나 `Ordered`를 구현해야 한다. 빈 메소드에는 `@Order` 어노테이션을 달아도 `Filter`의 순서는 바뀌지 않는다. `Filter` 클래스 변경이 어려워서 `@Order`를 추가하거나 `Ordered`를 구현할 수 없는 경우엔, 해당 `Filter`를 위한 `FilterRegistrationBean`을 정의하고 여기에 `setOrder(int)` 메소드로 순서를 설정해야 한다. `Ordered.HIGHEST_PRECEDENCE`로 요청 body를 읽는 필터는 설정하지 마라. 애플리케이션의 문자 인코딩 설정에 위배될 수 있기 때문이다. 서블릿 필터가 요청을 래핑한다면 `OrderedFilter.REQUEST_WRAPPER_FILTER_MAX_ORDER` 보다 작거나 같은 순서로 구성해야 한다.

> 애플리케이션에 있는 모든 `Filter`의 순서를 확인하고 싶다면 `web` [로그 그룹](../logging#746-log-groups)에 디버그 레벨을 활성화해라 (`logging.level.web=debug`). 그러면 애플리케이션 기동 시점에 순서나 URL 패턴을 포함한 등록한 필터들의 세부 정보를 남긴다.

> `Filter` 빈은 애플리케이션 라이프 사이클 중 굉장히 초기에 초기화되기 때문에 주의해서 등록해야 한다. 다른 빈과 상호 작용하는 `Filter`를 등록해야한다면 대신 [`DelegatingFilterProxyRegistrationBean`](https://docs.spring.io/spring-boot/docs/2.5.2/api/org/springframework/boot/web/servlet/DelegatingFilterProxyRegistrationBean.html)을 검토해봐라.

#### Servlet Context Initialization

임베디드 서블릿 컨테이너는 서블릿 3.0+ <span class="custom-blockquote">javax.servlet.ServletContainerInitializer</span> 인터페이스나 스프링의 <span class="custom-blockquote">org.springframework.web.WebApplicationInitializer</span> 인터페이스를 직접 실행하지 않는다. 이 설계는 war에서 실행되도록 설계한 써드 파티 라이브러리가 스프링 부트 애플리케이션을 손상시킬 수 있는 위험을 줄이기위해 의도적으로 내린 결정이다.

스프링 부트 애플리케이션에서 서블릿 컨텍스트를 초기화해야 한다면 <span class="custom-blockquote">org.springframework.boot.web.servlet.ServletContextInitializer</span> 인터페이스를 구현하는 빈을 등록해야 한다. 유일하게 정의해둔 `onStartup` 메소드에선 `ServletContext`에 접근할 수 있게 해주며, 필요 시 간단히 기존 `WebApplicationInitializer`의 어댑터로 활용할 수도 있다.

##### Scanning for Servlets, Filters, and listeners

임베디드 컨테이너를 사용할 때는 `@ServletComponentScan`을 사용하면 `@WebServlet`, `@WebFilter`, `@WebListener` 어노테이션을 선언한 클래스를 자동으로 등록할 수 있다.

> `@ServletComponentScan`은 컨테이너의 내장 디스커버리 메커니즘을 사용하는 독립형 컨테이너에선 아무런 영향을 주지 않는다.

#### The ServletWebServerApplicationContext

스프링 부트 내부에선 임베디드 서블릿 컨테이너 지원을 위해 다른 타입의 `ApplicationContext`를 사용한다. `ServletWebServerApplicationContext`는 `ServletWebServerFactory` 빈을 하나 찾아서 자체적으로 부트스트랩하는 특수한 타입의 `WebApplicationContext`다. 보통 `TomcatServletWebServerFactory`나 `JettyServletWebServerFactory`, `UndertowServletWebServerFactory`는 자동으로 설정된다.

> 보통은 이런 구현체 클래스는 알 필요 없다. 대부분의 애플리케이션은 자동 설정되며, 사용자를 대신해서 적절한 `ApplicationContext`와 `ServletWebServerFactory`를 생성해준다.

#### Customizing Embedded Servlet Containers

공통 서블릿 컨테이너 설정은 스프링 `Environment` 프로퍼티를 통해 설정할 수 있다. 보통은 `application.properties`나 `application.yaml` 파일에서 정의한다.

공통 서버 설정으로는 다음과 같은 설정이 있다:

- 네트워크 설정: 들어오는 HTTP 요청을 수신<sup>listen</sup>할 포트 (`server.port`), `server.address`에 바인딩할 인터페이스 주소 등.
- 세션 설정: 세션을 지속할지 여부 (`server.servlet.session.persistent`), 세션 타임아웃 (`server.servlet.session.timeout`), 세션 데이터 위치 (`server.servlet.session.store-dir`), 세션 쿠키 설정 (`server.servlet.session.cookie.*`).
- 에러 관리: 에러 페이지 위치(`server.error.path`)와 기타 등등.
- [SSL](../howto.embedded-web-servers#1237-configure-ssl)
- [HTTP 압축](../howto.embedded-web-servers#1236-enable-http-response-compression)

스프링 부트는 가능한 한 공통 설정을 노출해주지만, 이게 항상 가능한 건 아니다. 공통 설정으로 커스텀이 불가능한 경우 서버 전용 네임스페이스를 이용하면 된다 (`server.tomcat`, `server.undertow` 참고). 예를 들어 [access log](../howto.embedded-web-servers#12311-configure-access-logging)는 임베디드 서블릿 컨테이너의 전용 기능으로 설정할 수 있다.

> 전체 리스트는 [`ServerProperties`](https://github.com/spring-projects/spring-boot/tree/v2.5.2/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/web/ServerProperties.java) 클래스에서 확인할 수 있다.

##### Programmatic Customization

임베디드 서블릿 컨테이너를 코드로 설정해야 할 땐 `WebServerFactoryCustomizer` 인터페이스를 구현한 스프링 빈을 등록하면 된다. `WebServerFactoryCustomizer`를 사용하면 수많은 커스텀 setter 메소드를 가지고 있는 `ConfigurableServletWebServerFactory`에 접근할 수 있다. 다음은 프로그래밍 방식으로 포트를 설정하는 예시다:

```java
@Component
public class MyWebServerFactoryCustomizer implements WebServerFactoryCustomizer<ConfigurableServletWebServerFactory> {

    @Override
    public void customize(ConfigurableServletWebServerFactory server) {
        server.setPort(9000);
    }

}
```

`TomcatServletWebServerFactory`, `JettyServletWebServerFactory`, `UndertowServletWebServerFactory`는 각각 Tomcat, Jetty, Undertow를 위한 커스텀 setter 메소드를 추가로 가지고 있는 전용 `ConfigurableServletWebServerFactory`다. 다음은 Tomcat 전용 설정 옵션을 사용할 수 있는 `TomcatServletWebServerFactory`를 커스텀하는 예시다:

```java
@Component
public class MyTomcatWebServerFactoryCustomizer implements WebServerFactoryCustomizer<TomcatServletWebServerFactory> {

    @Override
    public void customize(TomcatServletWebServerFactory server) {
        server.addConnectorCustomizers((connector) -> connector.setAsyncTimeout(Duration.ofSeconds(20).toMillis()));
    }

}
```

##### Customizing ConfigurableServletWebServerFactory Directly

`ServletWebServerFactory`로는 해결할 수 없는 기능을 커스텀해야 한다면, `ServletWebServerFactory` 타입 빈을 직접 정의하면 된다.

설정 옵션 대부분에는 Setter를 사용한다. 좀 더 색다른 설정이 필요할 때를 위한 몇 가지 protected 메소드 "훅"도 제공한다. 자세한 내용은 [소스 코드 문서](https://docs.spring.io/spring-boot/docs/2.5.2/api/org/springframework/boot/web/servlet/server/ConfigurableServletWebServerFactory.html)를 참고해라.

> 커스텀 팩토리에도 자동 설정된 customizer가 적용되므로 이 옵션은 신중하게 사용해라.

#### JSP Limitations

임베디드 서블릿 컨테이너를 사용해서 (실행 가능한 아카이브로 패키징한) 스프링 부트 애플리케이션을 실행할 때는 JSP 지원과 관련해서 몇 가지 제약이 있다.

- Jetty와 Tomcat을 사용할 땐 war 패키징을 사용해야 동작한다. 실행 가능한 war<sup>executable war</sup>는 `java -jar`로 기동해야 작동하고, 모든 표준 컨테이너에도 배포할 수 있다. 실행 가능한 jar<sup>executable jar</sup>를 사용할 때는 JSP를 지원하지 않는다.
- Undertow는 JSP를 지원하지 않는다.
- 커스텀 `error.jsp` 페이지를 만들어도 [에러 처리](#error-handling)를 위한 디폴트 뷰를 재정의하지 않는다. 대신에 [커스텀 에러 페이지](#custom-error-pages)를 사용해야 한다.

### 7.7.5. Embedded Reactive Server Support

스프링 부트는 Reactor Netty, Tomcat, Jetty, Undertow같은 임베디드 리액티브 웹 서버 지원을 포함한다. 개발자 대부분은 적절한 "스타터"를 사용해서 바로 사용할 수 있게끔 구성된 인스턴스를 가져온다. 임베디드 서버는 기본적으로 `8080` 포트에서 HTTP 요청을 수신<sup>listen</sup>한다.

### 7.7.6. Reactive Server Resources Configuration

Reactor Netty나 Jetty 서버를 자동 설정하게 되면 스프링 부트는 서버 인스턴스에 HTTP 리소스를 제공할 빈으로 `ReactorResourceFactory`나 `JettyResourceFactory`를 생성한다.

기본적으로 이런 리소스들은 다음 요소를 고려해서, Reactor Netty, Jetty 클라이언트와 공유하고 성능을 최적화한다:

- 서버와 클라이언트에 같은 기술을 사용한다
- 클라이언트 인스턴스를 스프링 부트가 자동 설정해주는 `WebClient.Builder` 빈을 사용해서 빌드한다

커스텀 `ReactorResourceFactory`나 `JettyResourceFactory` 빈을 제공하면 Jetty와 Reactor Netty의 리소스 설정을 재정의할 수 있다. 설정을 재정의하면 클라이언트와 서버에 둘 다 적용된다.

클라이언트 측의 리소스 설정은 [WebClient 런타임 섹션](../calling-rest-services-with-webclient#7161-webclient-runtime)에서 자세히 알아볼 수 있다.
