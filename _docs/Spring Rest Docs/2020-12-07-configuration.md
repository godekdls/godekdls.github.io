---
title: Configuration
category: Spring REST Docs
order: 6
permalink: /Spring%20REST%20Docs/configuration/
description: 스프링 REST Docs 설정하기 한글 번역
image: ./../../images/springrestdocs/logo.png
lastmod: 2020-12-19T00:00:00+09:00
comments: true
originalRefName: 스프링 REST Docs
originalRefLink: https://docs.spring.io/spring-restdocs/docs/2.0.5.RELEASE/reference/html5/#configuration
---
<script>defaultLanguages = ['mockmvc']</script>

### 목차

- [5.1. Documented URIs](#51-documented-uris)
  + [5.1.1. MockMvc URI Customization](#511-mockmvc-uri-customization)
  + [5.1.2. REST Assured URI Customization](#512-rest-assured-uri-customization)
  + [5.1.3. WebTestClient URI Customization](#513-webtestclient-uri-customization)
- [5.2. Snippet Encoding](#52-snippet-encoding)
- [5.3. Snippet Template Format](#53-snippet-template-format)
- [5.4. Default Snippets](#54-default-snippets)
- [5.5. Default Operation Preprocessors](#55-default-operation-preprocessors)

---

이번 섹션은 스프링 Rest Docs를 설정하는 방법을 다룬다.

---

## 5.1. Documented URIs

이번 섹션은 문서화한 URI 설정을 다룬다.

### 5.1.1. MockMvc URI Customization

MockMvc를 사용하면 스프링 Rest Docs는 다음 디폴트 설정으로 URI를 작성한다:

| Setting | Default     |
| :------ | :---------- |
| Scheme  | `http`      |
| Host    | `localhost` |
| Port    | `8080`      |

이 설정은 `MockMvcRestDocumentationConfigurer`가 적용한다. 디폴트 설정을 필요에 따라 바꾸고 싶다면 이 API를 사용해라. 다음은 그 방법을 보여준다:

```java
this.mockMvc = MockMvcBuilders.webAppContextSetup(this.context)
		.apply(documentationConfiguration(this.restDocumentation).uris()
				.withScheme("https")
				.withHost("example.com")
				.withPort(443))
		.build();
```

> 스킴에 디폴트 포트를 설정하면 (HTTP는 80 포트, HTTPS에선 443 포트), 모든 URI의 포트를 생략해서 스니펫을 만든다.

> 요청의 컨텍스트 패스를 설정하려면 `MockHttpServletRequestBuilder`에 있는 `contextPath` 메소드를 사용해라.

### 5.1.2. REST Assured URI Customization

REST Assured는 실제 HTTP 요청을 통해 서비스를 테스트한다. 따라서 서비스에 연산을 수행하고 나서, 문서를 작성하기 전에 URI를 커스텀해야 한다. 이를 위한 [REST-Assured 전용 전처리기](../customizingrequestsandresponses#416-modifying-uris)를 제공한다.

### 5.1.3. WebTestClient URI Customization

WebTestClient를 사용하면 스프링 Rest Docs는 `http://localhost:8080`을 기본 베이스 URI로 작성한다. URI 베이스는 [`WebTestClient.Builder`에 있는 `baseUrl(String)` 메소드](https://docs.spring.io/spring-framework/docs/5.0.x/javadoc-api/org/springframework/test/web/reactive/server/WebTestClient.Builder.html#baseUrl-java.lang.String-)로 커스텀할 수 있다. 방법은 다음 예제를 참고해라:

```java
@Before
public void setUp() {
	this.webTestClient = WebTestClient.bindToApplicationContext(this.context)
		.configureClient()
		.baseUrl("https://api.example.com") // (1)
		.filter(documentationConfiguration(this.restDocumentation)).build();
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 문서에 작성하는 URI의 base를 `https://api.example.com`으로 설정한다.</small>

---

## 5.2. Snippet Encoding

디폴트 스니펫 인코딩은 `UTF-8`이다. 디폴트 스니펫 인코딩은 `RestDocumentationConfigurer` API로 바꿀 수 있다. 예를 들어 아래 예제는 `ISO-8859-1`을 사용한다:

<div class="switch-language-wrapper mockmvc webtestclient restassured">
<span class="switch-language mockmvc">MockMvc</span>
<span class="switch-language webtestclient">WebTestClient</span>
<span class="switch-language restassured">REST Assured</span>
</div>
<div class="language-only-for-mockmvc mockmvc webtestclient restassured"></div>
```java
this.mockMvc = MockMvcBuilders.webAppContextSetup(this.context)
		.apply(documentationConfiguration(this.restDocumentation)
				.snippets().withEncoding("ISO-8859-1"))
		.build();
```
<div class="language-only-for-webtestclient mockmvc webtestclient restassured"></div>
```java
this.webTestClient = WebTestClient.bindToApplicationContext(this.context).configureClient()
	.filter(documentationConfiguration(this.restDocumentation)
		.snippets().withEncoding("ISO-8859-1"))
	.build();
```
<div class="language-only-for-restassured mockmvc webtestclient restassured"></div>
```java
this.spec = new RequestSpecBuilder()
		.addFilter(documentationConfiguration(this.restDocumentation)
				.snippets().withEncoding("ISO-8859-1"))
		.build();
```

> 스프링 Rest Docs는 `Content-Type` 헤더에 유효한 `charset`이 지정돼 있다면, 이 `charset`을 사용해 응답 컨텐츠를 `String`으로 변환한다. 지정된 `charset`이 없으면 JVM의 디폴트 `charset`을 사용한다. JVM의 디폴트 `charset`은 시스템 프로퍼티 `file.encoding`으로 설정할 수 있다.

---

## 5.3. Snippet Template Format

디폴트 스니펫 템플릿 포맷은 Asciidoctor다. 자체적으로 Markdown도 지원한다. 디폴트 포맷은 `RestDocumentationConfigurer` API로 바꿀 수 있다. 바꾸는 방법은 다음 예제를 참고해라:

<div class="switch-language-wrapper mockmvc webtestclient restassured">
<span class="switch-language mockmvc">MockMvc</span>
<span class="switch-language webtestclient">WebTestClient</span>
<span class="switch-language restassured">REST Assured</span>
</div>
<div class="language-only-for-mockmvc mockmvc webtestclient restassured"></div>
```java
this.mockMvc = MockMvcBuilders.webAppContextSetup(this.context)
		.apply(documentationConfiguration(this.restDocumentation)
				.snippets().withTemplateFormat(TemplateFormats.markdown()))
		.build();
```
<div class="language-only-for-webtestclient mockmvc webtestclient restassured"></div>
```java
this.webTestClient = WebTestClient.bindToApplicationContext(this.context).configureClient()
	.filter(documentationConfiguration(this.restDocumentation)
		.snippets().withTemplateFormat(TemplateFormats.markdown()))
	.build();
```
<div class="language-only-for-restassured mockmvc webtestclient restassured"></div>
```java
this.spec = new RequestSpecBuilder()
		.addFilter(documentationConfiguration(this.restDocumentation)
				.snippets().withTemplateFormat(TemplateFormats.markdown()))
		.build();
```

---

## 5.4. Default Snippets

기본적으로 여섯 가지 스니펫을 만든다:

- `curl-request`
- `http-request`
- `http-response`
- `httpie-request`
- `request-body`
- `response-body`

이 디폴트 스니펫 설정은 `RestDocumentationConfigurer` API로 Rest Docs를 세팅할 때 바꿀 수 있다. 다음 예제는 디폴트로 `curl-request` 스니펫만 만들도록 설정하고 있다:

<div class="switch-language-wrapper mockmvc webtestclient restassured">
<span class="switch-language mockmvc">MockMvc</span>
<span class="switch-language webtestclient">WebTestClient</span>
<span class="switch-language restassured">REST Assured</span>
</div>
<div class="language-only-for-mockmvc mockmvc webtestclient restassured"></div>
```java
this.mockMvc = MockMvcBuilders.webAppContextSetup(this.context)
		.apply(documentationConfiguration(this.restDocumentation).snippets()
				.withDefaults(curlRequest()))
		.build();
```
<div class="language-only-for-webtestclient mockmvc webtestclient restassured"></div>
```java
this.webTestClient = WebTestClient.bindToApplicationContext(this.context)
	.configureClient().filter(
		documentationConfiguration(this.restDocumentation)
			.snippets().withDefaults(curlRequest()))
	.build();
```
<div class="language-only-for-restassured mockmvc webtestclient restassured"></div>
```java
this.spec = new RequestSpecBuilder()
		.addFilter(documentationConfiguration(this.restDocumentation).snippets()
				.withDefaults(curlRequest()))
		.build();
```

---

## 5.5. Default Operation Preprocessors

디폴트 요청/응답 전처리기도 `RestDocumentationConfigurer` API로 Rest Docs를 세팅할 때 설정할 수 있다. 다음 예제는 모든 요청에서 `Foo` 헤더를 제거하고 모든 응답을 보기 좋게 출력(pretty print)하고 있다:

<div class="switch-language-wrapper mockmvc webtestclient restassured">
<span class="switch-language mockmvc">MockMvc</span>
<span class="switch-language webtestclient">WebTestClient</span>
<span class="switch-language restassured">REST Assured</span>
</div>
<div class="language-only-for-mockmvc mockmvc webtestclient restassured"></div>
```java
this.mockMvc = MockMvcBuilders.webAppContextSetup(this.context)
		.apply(documentationConfiguration(this.restDocumentation)
				.operationPreprocessors()
				.withRequestDefaults(removeHeaders("Foo")) // (1)
				.withResponseDefaults(prettyPrint())) // (2)
		.build();
```
<div class="language-only-for-webtestclient mockmvc webtestclient restassured"></div>
```java
this.webTestClient = WebTestClient.bindToApplicationContext(this.context)
	.configureClient()
	.filter(documentationConfiguration(this.restDocumentation)
		.operationPreprocessors()
			.withRequestDefaults(removeHeaders("Foo")) // (1)
			.withResponseDefaults(prettyPrint())) // (2)
	.build();
```
<div class="language-only-for-restassured mockmvc webtestclient restassured"></div>
```java
this.spec = new RequestSpecBuilder()
	.addFilter(documentationConfiguration(this.restDocumentation).operationPreprocessors()
		.withRequestDefaults(removeHeaders("Foo")) // (1)
		.withResponseDefaults(prettyPrint())) // (2)
	.build();
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `Foo` 헤더를 제거하는 요청 전처리기를 적용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 컨텐츠를 보기 좋게 출력해주는 응답 전처리기를 적용한다.</small>