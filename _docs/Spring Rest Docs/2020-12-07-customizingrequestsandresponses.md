---
title: Customizing requests and responses
category: Spring REST Docs
order: 5
permalink: /Spring%20REST%20Docs/customizingrequestsandresponses/
description: 스프링 REST Doc으로 요청과 응답 커스텀하기 한글 번역
image: ./../../images/springrestdocs/logo.png
lastmod: 2020-12-07T21:00:00+09:00
comments: true
originalRefName: 스프링 REST Docs
originalRefLink: https://docs.spring.io/spring-restdocs/docs/2.0.5.RELEASE/reference/html5/#customizing-requests-and-responses
---
<script>defaultLanguages = ['mockmvc']</script>

### 목차

- [4.1. Preprocessors](#41-preprocessors)
  + [4.1.1. Pretty Printing](#411-pretty-printing)
  + [4.1.2. Masking Links](#412-masking-links)
  + [4.1.3. Removing Headers](#413-removing-headers)
  + [4.1.4. Replacing Patterns](#414-replacing-patterns)
  + [4.1.5. Modifying Request Parameters](#415-modifying-request-parameters)
  + [4.1.6. Modifying URIs](#416-modifying-uris)
  + [4.1.7. Writing Your Own Preprocessor](#417-writing-your-own-preprocessor)

---

전송한 요청이나 전송받은 응답과 완벽하게 일치하지 않는 문서를 작성하고 싶을 수도 있다. 스프링 REST Doc은 문서 작성 전에 요청과 응답을 수정할 수 있는 여러가지 전처리기를 제공한다.

전처리는 `OperationRequestPreprocessor` 또는 `OperationResponsePreprocessor`와 함께 `document`를 호출해 설정한다. `Preprocessors`에 있는 스태틱 메소드 `preprocessRequest`, `preprocessResponse`로 인스턴스를 가져올 수 있다. 다음은 그 방법을 보여준다:

<div class="switch-language-wrapper mockmvc webtestclient restassured">
<span class="switch-language mockmvc">MockMvc</span>
<span class="switch-language webtestclient">WebTestClient</span>
<span class="switch-language restassured">REST Assured</span>
</div>
<div class="language-only-for-mockmvc mockmvc webtestclient restassured"></div>
```java
this.mockMvc.perform(get("/")).andExpect(status().isOk())
	.andDo(document("index", preprocessRequest(removeHeaders("Foo")), // (1)
			preprocessResponse(prettyPrint()))); // (2)
```
<div class="language-only-for-webtestclient mockmvc webtestclient restassured"></div>
```java
this.webTestClient.get().uri("/").exchange().expectStatus().isOk().expectBody()
	.consumeWith(document("index",
		preprocessRequest(removeHeaders("Foo")), // (1)
		preprocessResponse(prettyPrint()))); // (2)
```
<div class="language-only-for-restassured mockmvc webtestclient restassured"></div>
```java
RestAssured.given(this.spec)
	.filter(document("index", preprocessRequest(removeHeaders("Foo")), // (1)
			preprocessResponse(prettyPrint()))) // (2)
.when().get("/")
.then().assertThat().statusCode(is(200));
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `Foo` 해더를 제거하는 요청 전처리기를 적용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 컨텐츠를 보기좋게 출력해주는(pretty print) 응답 전처러기를 적용한다.</small>

어떨 때는 모든 테스트에 같은 전처리기를 적용하고 싶을 수도 있다. 이땐 `@Before` 메소드에서 `RestDocumentationConfigurer` API를 사용해 전처리기를 설정하면 된다. 예를 들어 모든 요청에서 `Foo` 헤더를 제거하고 모든 요청을 보기좋게 출력하고(pretty print) 싶다면, 다음 방법을 사용해라 (각자의 테스트 환경에 맞게):

<div class="switch-language-wrapper mockmvc webtestclient restassured">
<span class="switch-language mockmvc">MockMvc</span>
<span class="switch-language webtestclient">WebTestClient</span>
<span class="switch-language restassured">REST Assured</span>
</div>
<div class="language-only-for-mockmvc mockmvc webtestclient restassured"></div>
```java
private MockMvc mockMvc;

@Before
public void setup() {
	this.mockMvc = MockMvcBuilders.webAppContextSetup(this.context)
		.apply(documentationConfiguration(this.restDocumentation).operationPreprocessors()
			.withRequestDefaults(removeHeaders("Foo")) // (1)
			.withResponseDefaults(prettyPrint())) // (2)
		.build();
}
```
<div class="language-only-for-webtestclient mockmvc webtestclient restassured"></div>
```java
private WebTestClient webTestClient;

@Before
public void setup() {
	this.webTestClient = WebTestClient.bindToApplicationContext(this.context)
		.configureClient()
		.filter(documentationConfiguration(this.restDocumentation)
			.operationPreprocessors()
				.withRequestDefaults(removeHeaders("Foo")) // (1)
				.withResponseDefaults(prettyPrint())) // (2)
		.build();
}
```
<div class="language-only-for-restassured mockmvc webtestclient restassured"></div>
```java
private RequestSpecification spec;

@Before
public void setup() {
	this.spec = new RequestSpecBuilder()
		.addFilter(documentationConfiguration(this.restDocumentation).operationPreprocessors()
			.withRequestDefaults(removeHeaders("Foo")) // (1)
			.withResponseDefaults(prettyPrint())) // (2)
		.build();
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `Foo` 해더를 제거하는 요청 전처리기를 적용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 컨텐츠를 보기좋게 출력해주는(pretty print) 응답 전처러기를 적용한다.</small>

그 다음 각 테스트에 필요한 설정을  적용하면 된다. 적용 방법은 다음 예제를 참고해라:

<div class="switch-language-wrapper mockmvc webtestclient restassured">
<span class="switch-language mockmvc">MockMvc</span>
<span class="switch-language webtestclient">WebTestClient</span>
<span class="switch-language restassured">REST Assured</span>
</div>
<div class="language-only-for-mockmvc mockmvc webtestclient restassured"></div>
```java
this.mockMvc.perform(get("/"))
		.andExpect(status().isOk())
		.andDo(document("index",
				links(linkWithRel("self").description("Canonical self link"))
		));
```
<div class="language-only-for-webtestclient mockmvc webtestclient restassured"></div>
```java
this.webTestClient.get().uri("/").exchange().expectStatus().isOk()
	.expectBody().consumeWith(document("index",
		links(linkWithRel("self").description("Canonical self link"))));
```
<div class="language-only-for-restassured mockmvc webtestclient restassured"></div>
```java
RestAssured.given(this.spec)
	.filter(document("index",
		links(linkWithRel("self").description("Canonical self link"))))
	.when().get("/")
	.then().assertThat().statusCode(is(200));
```

위에서 보여준 전처리기 외에도 `Preprocessors`에 있는 스태틱 메소드를 통해 다양한 전처리기를 사용할 수 있다. 더 자세한 내용은 [아래](#41-preprocessors)를 참고해라.

---

## 4.1. Preprocessors

### 4.1.1. Pretty Printing

`Preprocessors`에 있는 `prettyPrint`는 요청, 응답 컨텐츠 형식을 읽기 쉽게 바꿔준다.

### 4.1.2. Masking Links

하이퍼미디어 기반 API 문서를 작성한다면 하드 코딩한 URI 대신, 클라이언트가 링크를 통해 API를 탐색하도록 유도하고 싶을 수 있다. 한 가지 방법은 문서 내에 URI를 사용을 제한하는 것이다. `Preprocessors`의 `maskLinks`는 응답에 있는 모든 링크의 `href`를 `…`로 바꾼다. 원한다면 대체할 문자열을 지정할 수도 있다.

### 4.1.3 Removing Headers

`Preprocessors`의 `removeHeaders`는 요청, 응답에서 전달받은 헤더명과 일치하는 모든 헤더를 제거한다.

`Preprocessors`의 `removeMatchingHeaders`는 요청, 응답에서 전달받은 정규식 패턴과 일치하는 모든 헤더를 제거한다.

### 4.1.4. Replacing Patterns

`Preprocessors`의 `replacePattern`은 요청, 응답 컨텐츠를 대체할 수 있는 범용 메커니즘을 제공한다. 정규식과 일치하는 모든 항목을 대체해버린다.

### 4.1.5. Modifying Request Parameters

`Preprocessors`의 `modifyParameters`로는 요청 파라미터를 추가, 설정, 제거할 수 있다.

### 4.1.6. Modifying URIs

> 서버에 바운드되지 않은 MockMvc나 WebTestClient를 사용한다면 [이 설정을 바꿔서](../configuration#51-documented-uris) URI를 커스텀해야 한다.

`Preprocessors`의 `modifyUris`로는 요청, 응답의 모든 URI를 수정할 수 있다. 서버에 바운드된 REST Assured나 WebTestClient를 사용한다면, 서비스 로컬 인스턴스를 테스트하면서 문서에 보이는 URI를 커스텀할 수 있다.

### 4.1.7. Writing Your Own Preprocessor

내장 전처리기로 해결할 수 없는 요구사항이 있다면 `OperationPreprocessor` 인터페이스를 직접 구현하면 된다. 커스텀 전처리기도 다른 내장 전처리기와 똑같이 사용할 수 있다.

요청이나 응답 컨텐츠(바디)만 수정하고 싶다면, `ContentModifier` 인터페이스를 구현해서 내장 `ContentModifyingOperationPreprocessor`와 함께 쓰는 걸 고려해봐라.