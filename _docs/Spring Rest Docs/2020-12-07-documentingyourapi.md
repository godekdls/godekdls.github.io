---
title: Documenting your API
category: Spring REST Docs
order: 4
permalink: /Spring%20REST%20Docs/documentingyourapi/
description: 스프링 REST Docs로 API 문서화하기 한글 번역
priority: 0.8
image: ./../../images/springrestdocs/logo.png
lastmod: 2020-12-19T00:00:00+09:00
comments: true
originalRefName: 스프링 REST Docs
originalRefLink: https://docs.spring.io/spring-restdocs/docs/2.0.5.RELEASE/reference/html5/#documenting-your-api
---
<script>defaultLanguages = ['mockmvc']</script>

### 목차

- [3.1. Hypermedia](#31-hypermedia)
  + [3.1.1. Hypermedia Link Formats](#311-hypermedia-link-formats)
  + [3.1.2. Ignoring Common Links](#312-customizing-the-output)
- [3.2. Request and Response Payloads](#32-request-and-response-payloads)
  + [3.2.1. Request and Response Fields](#321-request-and-response-fields)
    * [Fields in JSON Payloads](#fields-in-json-payloads)
    * [XML payloads](#xml-payloads)
    * [Reusing Field Descriptors](#reusing-field-descriptors)
  + [3.2.2. Documenting a Subsection of a Request or Response Payload](#322-documenting-a-subsection-of-a-request-or-response-payload)
    * [Documenting a Subsection of a Request or Response Body](#documenting-a-subsection-of-a-request-or-response-body)
    * [Documenting the Fields of a Subsection of a Request or Response](#documenting-the-fields-of-a-subsection-of-a-request-or-response)
- [3.3. Request Parameters](#33-request-parameters)
- [3.4. Path Parameters](#34-path-parameters)
- [3.5. Request Parts](#35-request-parts)
- [3.6. Request Part Payloads](#36-request-part-payloads)
  + [3.6.1. Documenting a Request Part’s Body](#361-documenting-a-request-parts-body)
  + [3.6.2. Documenting a Request Part’s Fields](#362-documenting-a-request-parts-fields)
- [3.7. HTTP Headers](#37-http-headers)
- [3.8. Reusing Snippets](#38-reusing-snippets)
- [3.9. Documenting Constraints](#39-documenting-constraints)
  + [3.9.1. Finding Constraints](#391-finding-constraints)
  + [3.9.2. Describing Constraints](#392-describing-constraints)
  + [3.9.3. Using Constraint Descriptions in Generated Snippets](#393-using-constraint-descriptions-in-generated-snippets)
- [3.10. Default Snippets](#310-default-snippets)
- [3.11. Using Parameterized Output Directories](#311-hypermedia-link-formats)
- [3.12. Customizing the Output](#312-customizing-the-output)
  + [3.12.1. Customizing the Generated Snippets](#3121-customizing-the-generated-snippets)
  + [3.12.2. Including Extra Information](#3122-including-extra-information)
  
---

이번 섹션에서는 스프링 REST Docs로 API를 문서화하는 방법에 대해 더 자세히 설명한다.

---

## 3.1. Hypermedia

스프링 Rest Docs를 사용하면 [하이퍼미디어 기반](https://en.wikipedia.org/wiki/HATEOAS) API에서의 링크도 문서화할 수 있다. 다음 예제는 그 방법을 보여준다:

<div class="switch-language-wrapper mockmvc webtestclient restassured">
<span class="switch-language mockmvc">MockMvc</span>
<span class="switch-language webtestclient">WebTestClient</span>
<span class="switch-language restassured">REST Assured</span>
</div>
<div class="language-only-for-mockmvc mockmvc webtestclient restassured"></div>
```java
this.mockMvc.perform(get("/").accept(MediaType.APPLICATION_JSON))
	.andExpect(status().isOk())
	.andDo(document("index", links( // (1)
			linkWithRel("alpha").description("Link to the alpha resource"), // (2) 
			linkWithRel("bravo").description("Link to the bravo resource")))); // (3) 
```
<div class="language-only-for-webtestclient mockmvc webtestclient restassured"></div>
```java
this.webTestClient.get().uri("/").accept(MediaType.APPLICATION_JSON).exchange()
	.expectStatus().isOk().expectBody()
	.consumeWith(document("index",links( // (1)
			linkWithRel("alpha").description("Link to the alpha resource"), // (2)
			linkWithRel("bravo").description("Link to the bravo resource")))); // (3)
```
<div class="language-only-for-restassured mockmvc webtestclient restassured"></div>
```java
RestAssured.given(this.spec)
	.accept("application/json")
	.filter(document("index", links( // (1)
			linkWithRel("alpha").description("Link to the alpha resource"), // (2)
			linkWithRel("bravo").description("Link to the bravo resource")))) // (3)
	.get("/").then().assertThat().statusCode(is(200));
```
<div class="description-for-mockmvc mockmvc webtestclient restassured"></div>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 응답에 있는 링크를 설명하는 스니펫을 만들도록 설정한다. <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.hypermedia.HypermediaDocumentation</span>에 있는 스태틱 메소드 `links`를 사용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> `rel`이 `alpha`인 링크가 있는지 검증한다. <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.hypermedia.HypermediaDocumentation</span>에 있는 스태틱 메소드 `linkWithRel`을 사용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> `rel`이 `bravo`인 링크가 있는지 검증한다.</small>

<div class="description-for-webtestclient mockmvc webtestclient restassured"></div>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 응답에 있는 링크를 설명하는 스니펫을 만들도록 설정한다. <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.hypermedia.HypermediaDocumentation</span>에 있는 스태틱 메소드 `links`를 사용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> `rel`이 `alpha`인 링크가 있는지 검증한다. <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.hypermedia.HypermediaDocumentation</span>에 있는 스태틱 메소드 `linkWithRel`을 사용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> `rel`이 `bravo`인 링크가 있는지 검증한다.</small>

<div class="description-for-restassured mockmvc webtestclient restassured"></div>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 응답에 있는 링크를 설명하는 스니펫을 만들도록 설정한다. <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.hypermedia.HypermediaDocumentation</span>에 있는 스태틱 메소드 `links`를 사용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> `rel`이 `alpha`인 링크가 있는지 검증한다. <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.hypermedia.HypermediaDocumentation</span>에 있는 스태틱 메소드 `linkWithRel`을 사용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> `rel`이 `bravo`인 링크가 있는지 검증한다.</small>

코드를 실행하면 `links.adoc`이란 스니펫을 만들며, 이 스니펫은 리소스 링크를 설명하는 테이블을 가지고 있다.

> 응답에서 `title`이 있는 링크는 descriptor 설명을 생략할 수 있으며, 이땐 `title`을 사용한다. `title`이 없는 링크의 설명을 생략하면 실패한다.

링크를 문서화할 땐, 응답에 있는 모든 링크를 작성하지 않으면 테스트는 실패한다. 마찬가지로 문서화한 링크가 응답에 없을 땐, 해당 링크를 선택 사항으로 마킹하지 않았다면 테스트는 실패한다.

링크를 문서화하고 싶지 않다면 무시하도록 마킹해도 된다. 이렇게하면 위에서 언급한 테스트 실패를 방지하고, 만들어진 스니펫에서도 제외할 수 있다.

모든 링크를 문서화하지 않아도 테스트가 실패하지 않도록 완화된 모드로 링크를 문서화할 수도 있다. 이렇게 하려면 <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.hypermedia.HypermediaDocumentation</span>에 있는 `relaxedLinks` 메소드를 사용해라. 일부 링크만 중요한 특정 시나리오를 문서화하기 유용하다.

### 3.1.1. Hypermedia Link Formats

스프링 Rest Docs는 기본적으로 두 가지 형태의 링크를 처리한다:

- Atom: `links`라는 배열에 링크가 있다고 가정한다. 응답 컨텐츠 타입이 `application/json`과 호환되면 디폴트로 이 방식을 사용한다.
- HAL: `_links`라는 맵에 링크가 있다고 가정한다. 응답 컨텐츠 타입이 `application/hal+json`과 호환되면 디폴트로 이 방식을 사용한다.

Atom이나 HAL 형식 링크를 사용하는데 컨텐츠 타입이 다르다면, `links`에 빌트인 `LinkExtractor` 구현체 중 하나를 제공하면 된다. 다음 예제는 그 방법을 보여준다:

<div class="switch-language-wrapper mockmvc webtestclient restassured">
<span class="switch-language mockmvc">MockMvc</span>
<span class="switch-language webtestclient">WebTestClient</span>
<span class="switch-language restassured">REST Assured</span>
</div>
<div class="language-only-for-mockmvc mockmvc webtestclient restassured"></div>
```java
.andDo(document("index", links(halLinks(), // (1)
		linkWithRel("alpha").description("Link to the alpha resource"),
		linkWithRel("bravo").description("Link to the bravo resource"))));
```
<div class="language-only-for-webtestclient mockmvc webtestclient restassured"></div>
```java
.consumeWith(document("index",links(halLinks(), // (1)
		linkWithRel("alpha").description("Link to the alpha resource"),
		linkWithRel("bravo").description("Link to the bravo resource"))));
```
<div class="language-only-for-restassured mockmvc webtestclient restassured"></div>
```java
.filter(document("index", links(halLinks(), // (1)
		linkWithRel("alpha").description("Link to the alpha resource"),
		linkWithRel("bravo").description("Link to the bravo resource"))))
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> HAL 형식 링크를 사용한다고 알려준다. <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.hypermedia.HypermediaDocumentation</span>에 있는 스태틱 메소드 `halLinks`를 사용한다.</small>

API가 Atom도 HAL도 아닌 다른 형식으로 링크를 표현하고 있다면, `LinkExtractor` 인터페이스를 직접 구현해서 응답에서 링크를 추출하면 된다.

### 3.1.2. Ignoring Common Links

HAL을 사용할 땐 `self`, `curies`같이 모든 응답에 들어있는 링크를 문서화하는 대신, 개요 섹션에 한 번만 문서화하고 나머지 API 문서에선 공통 링크를 무시하고 싶을 수 있다. 이럴 때 [스니펫 재사용 기능](#38-reusing-snippets)을 활용하면 미리 특정 링크를 무시하게끔 스니펫을 설정해두고, 필요할 때 링크 descriptor를 추가할 수 있다. 다음 예제를 참고해라:

```java
public static LinksSnippet links(LinkDescriptor... descriptors) {
	return HypermediaDocumentation.links(linkWithRel("self").ignored().optional(),
			linkWithRel("curies").ignored()).and(descriptors);
}
```

---

## 3.2. Request and Response Payloads

[앞서 설명한](#31-hypermedia) 하이퍼미디어 전용 기능 외에도, 일반적인 요청/응답 페이로드 문서도 작성할 수 있다.

기본적으로 스프링 Rest Docs는 요청과 응답 바디를 위한 스니펫을 자동으로 만들어준다. 각 스니펫 이름은 `request-body.adoc`과 `response-body.adoc`이다.

### 3.2.1. Request and Response Fields

요청, 응답 페이로드 문서를 좀 더 자세히 작성하고 싶다면, 페이로드 필드를 문서화할 수 있다.

아래 페이로드를 생각해 보자:

```json
{
	"contact": {
		"name": "Jane Doe",
		"email": "jane.doe@example.com"
	}
}
```

이 예제에 있는 필드는 다음과 같이 문서화할 수 있다:

<div class="switch-language-wrapper mockmvc webtestclient restassured">
<span class="switch-language mockmvc">MockMvc</span>
<span class="switch-language webtestclient">WebTestClient</span>
<span class="switch-language restassured">REST Assured</span>
</div>
<div class="language-only-for-mockmvc mockmvc webtestclient restassured"></div>
```java
this.mockMvc.perform(get("/user/5").accept(MediaType.APPLICATION_JSON))
		.andExpect(status().isOk())
		.andDo(document("index",
				responseFields( // (1)
						fieldWithPath("contact.email")
								.description("The user's email address"), // (2)
				fieldWithPath("contact.name").description("The user's name")))); // (3)
```
<div class="language-only-for-webtestclient mockmvc webtestclient restassured"></div>
```java
this.webTestClient.get().uri("user/5").accept(MediaType.APPLICATION_JSON)
	.exchange().expectStatus().isOk().expectBody()
	.consumeWith(document("user",
		responseFields( // (1)
			fieldWithPath("contact.email").description("The user's email address"), // (2)
			fieldWithPath("contact.name").description("The user's name")))); // (3)
```
<div class="language-only-for-restassured mockmvc webtestclient restassured"></div>
```java
RestAssured.given(this.spec).accept("application/json")
	.filter(document("user", responseFields( // (1)
			fieldWithPath("contact.name").description("The user's name"), // (2)
			fieldWithPath("contact.email").description("The user's email address")))) // (3)
	.when().get("/user/5")
	.then().assertThat().statusCode(is(200));
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 응답 페이로드에 있는 필드를 설명하는 스니펫을 만들도록 설정한다. 요청을 문서화할 땐 `requestFields`를 사용하면 된다. 두 스태틱 메소드는 모두 <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.payload.PayloadDocumentation</span>에 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> `contact.email` 패스에 필드가 있는지 검증한다. <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.payload.PayloadDocumentation</span>에 있는 스태틱 메소드 `fieldWithPath`를 사용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> `contact.name` 패스에 필드가 있는지 검증한다.</small>

결과로 만들어지는 스니펫엔 필드를 설명하는 테이블이 추가된다. 요청 문서에서 해당 스니펫 이름은 `request-fields.adoc`, 응답은 `response-fields.adoc`이다.

필드를 문서화할 땐, 페이로드에 있는 모든 필드를 작성하지 않으면 테스트는 실패한다. 마찬가지로 문서화한 필드가 페이로드에 없을 땐, 해당 필드를 선택 사항으로 마킹하지 않았다면 테스트는 실패한다.

문서에 모든 필드를 상세하게 적고 싶지 않다면 하위 패스를 하나로 묶어서 문서화하는 것도 가능하다. 다음은 그 방법을 보여준다:

<div class="switch-language-wrapper mockmvc webtestclient restassured">
<span class="switch-language mockmvc">MockMvc</span>
<span class="switch-language webtestclient">WebTestClient</span>
<span class="switch-language restassured">REST Assured</span>
</div>
<div class="language-only-for-mockmvc mockmvc webtestclient restassured"></div>
```java
this.mockMvc.perform(get("/user/5").accept(MediaType.APPLICATION_JSON))
		.andExpect(status().isOk())
		.andDo(document("index",
				responseFields( 
						subsectionWithPath("contact")
								.description("The user's contact details")))); // (1)
```
<div class="language-only-for-webtestclient mockmvc webtestclient restassured"></div>
```java
this.webTestClient.get().uri("user/5").accept(MediaType.APPLICATION_JSON)
	.exchange().expectStatus().isOk().expectBody()
	.consumeWith(document("user",
		responseFields(
			subsectionWithPath("contact").description("The user's contact details")))); // (1)
```
<div class="language-only-for-restassured mockmvc webtestclient restassured"></div>
```java
RestAssured.given(this.spec).accept("application/json")
	.filter(document("user", responseFields(
			subsectionWithPath("contact").description("The user's contact details")))) // (1)
	.when().get("/user/5")
	.then().assertThat().statusCode(is(200));
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `contact` 패스 하위 섹션을 문서화한다. 이렇게 하면 `contact.email`과 `contact.name`도 문서화한다고 보면 된다. <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.payload.PayloadDocumentation</span>에 있는 스태틱 메소드 `subsectionWithPath`를 사용한다.</small>

`subsectionWithPath`는 특정 페이로드 섹션에 대한 개요를 제공하는 식으로 활용할 수 있다. 그런 다음 하위 섹션은 별도로 더 자세히 문서화해도 된다. [요청, 응답 페이로드 하위 섹션 문서 작성하기](#322-documenting-a-subsection-of-a-request-or-response-payload)를 참고해라.

필드나 하위 섹션을 아예 문서화하고 싶지 않다면 무시하도록 마킹해도 된다. 이렇게하면 위에서 언급한 테스트 실패를 방지하고, 만들어진 스니펫에서도 제외할 수 있다.

모든 필드를 문서화하지 않아도 테스트가 실패하지 않도록 완화된 모드로 필드를 문서화할 수도 있다. 이렇게 하려면 <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.payload.PayloadDocumentation</span>에 있는 메소드 `relaxedRequestFields`, `relaxedResponseFields`를 사용해라. 페이로드 일부만 중요한 특정 시나리오를 문서화하기 유용하다.

> 스프링 Rest Docs는 디폴트로 문서화하는 페이로드가 JSON이라고 가정한다. XML 페이로드를 문서화하려면 반드시 요청이나 응답 컨텐츠 타입이 `application/xml`과 호환돼야 한다.

#### Fields in JSON Payloads

이번 섹션에선 JSON 페이로드 필드를 다루는 방법을 설명한다.

##### JSON Field Paths

JSON 필드 패스는 점 표기법(dot notation)이나 괄호 표기법(bracket notation)을 사용한다. 점 표기법은 패스 안에서 '.'으로 키를 구분한다 (예를 들어 `a.b`). 괄호 표기법은 각 키를 꺽쇠 괄호와 작은 따옴표로 감싼다 (예를 들어 `['a']['b']`). 두 표기법 모두 배열은 `[]`로 식별한다. 점 표기법이 좀 더 간결하긴 하지만, 괄호 표기법에서도 키 이름 안에선 `.`을 사용해도 된다. 두 가지 표기법을 같이 사용해도 된다 (예를 들어 `a['b']`).

아래 JSON 페이로드를 생각해 보자:

```json
{
	"a":{
		"b":[
			{
				"c":"one"
			},
			{
				"c":"two"
			},
			{
				"d":"three"
			}
		],
		"e.dot" : "four"
	}
}
```

위 JSON 페이로드에는 다음과 같은 패스가 존재한다:

| Path             | Value                               |
| :--------------- | :---------------------------------- |
| `a`              | `b`를 가지고 있는 객체              |
| `a.b`            | 객체 세 개가 들어있는 배열          |
| `['a']['b']`     | 객체 세 개가 들어있는 배열          |
| `a['b']`         | 객체 세 개가 들어있는 배열          |
| `['a'].b`        | 객체 세 개가 들어있는 배열          |
| `a.b[]`          | 객체 세 개가 들어있는 배열          |
| `a.b[].c`        | 문자열 `one`, `two`가 들어있는 배열 |
| `a.b[].d`        | 문자열 `three`                      |
| `a['e.dot']`     | 문자열 `four`                       |
| `['a']['e.dot']` | 문자열 `four`                       |

루트가 배열인 페이로드도 문서화할 수 있다. `[]` 패스가 전체 배열을 가리킨다. 배열 엔트리 내 필드는 괄호나 점 표기법으로 구분하면 된다. 예를 들어 아래 배열에서 `[].id`는 모든 객체의 `id` 필드를 가리킨다:

```json
[
	{
		"id":1
	},
	{
		"id":2
	}
]
```

이름이 다른 필드를 한 번에 매칭하고 싶으면 와일드카드 `*`를 사용할 수 있다. 예를 들어 아래 JSON에서 모든 사용자의 role을 문서화할 땐 `users.*.role`을 사용하면 된다:

```json
{
	"users":{
		"ab12cd34":{
			"role": "Administrator"
		},
		"12ab34cd":{
			"role": "Guest"
		}
	}
}
```

##### JSON Field Types

필드를 문서화할 때 스프링 Rest Docs는 페이로드를 확인해서 필드 타입을 결정한다. 세 가지 필드 타입을 지원한다:

| Type      | Description                                                  |
| :-------- | :----------------------------------------------------------- |
| `array`   | 필드에 사용한 값이 모두 배열일 때                            |
| `boolean` | 필드에 사용한 값이 모두 boolean일 때 (`true`, `false`)       |
| `object`  | 필드에 사용한 값이 모두 객체일 때                            |
| `number`  | 필드에 사용한 값이 모두 숫자일 때                            |
| `null`    | 필드에 사용한 값이 모두 `null`일 때                          |
| `string`  | 필드에 사용한 값이 모두 문자열일 때                          |
| `varies`  | 페이로드 내에서 필드를 각기 다른 타입으로 여러 번 사용하는 경우 |

`FieldDescriptor`의 `type(Object)` 메소드로 직접 타입을 설정해도 된다. 문서화할 땐 넘겨준 `Object`에서 `toString` 메소드를 호출한다. 전형적으로는 `JsonFieldType` enum 값 중 하나를 사용한다. 다음 예제는 그 방법을 보여준다:

<div class="switch-language-wrapper mockmvc webtestclient restassured">
<span class="switch-language mockmvc">MockMvc</span>
<span class="switch-language webtestclient">WebTestClient</span>
<span class="switch-language restassured">REST Assured</span>
</div>
<div class="language-only-for-mockmvc mockmvc webtestclient restassured"></div>
```java
.andDo(document("index",
		responseFields(
				fieldWithPath("contact.email").type(JsonFieldType.STRING) // (1)
						.description("The user's email address"))));
```
<div class="language-only-for-webtestclient mockmvc webtestclient restassured"></div>
```java
.consumeWith(document("user",
	responseFields(
		fieldWithPath("contact.email")
			.type(JsonFieldType.STRING) // (1)
			.description("The user's email address"))));
```
<div class="language-only-for-restassured mockmvc webtestclient restassured"></div>
```java
.filter(document("user", responseFields(
		fieldWithPath("contact.email")
				.type(JsonFieldType.STRING) // (1)
				.description("The user's email address"))))
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 필드 타입을 `String`으로 설정한다.</small>

#### XML payloads

이번 섹션에선 XML 페이로드를 다루는 방법을 설명한다.

##### XML Field Paths

XML 필드 패스는 XPath로 표현한다. 자식 노드로 내려갈 땐 `/`를 사용한다.

##### XML Field Types

XML 페이로드를 문서화할 땐 반드시 `FieldDescriptor`에 있는 `type(Object)` 메소드로 필드 타입을 지정해야 한다. 지정한 타입에서 `toString` 메소드를 호출한 결과로 문서화한다.

#### Reusing Field Descriptors

범용적인 [스니펫 재사용](#38-reusing-snippets) 기능과 더불어, 기존 descriptor에 프리픽스를 추가해서 스니펫을 만들 수도 있다. 이렇게 하면 요청이나 응답 페이로드에서 반복되는 descriptor를 한 번만 생성해 재활용할 수 있다.

책 정보를 반환하는 엔드포인트를 생각해 보자:

```json
{
	"title": "Pride and Prejudice",
	"author": "Jane Austen"
}
```

`title`, `author`의 패스는 각각 `title`과 `author`다.

이제 책 정보 배열을 반환하는 엔드포인트로 넘어가 보자:

```json
[{
	"title": "Pride and Prejudice",
	"author": "Jane Austen"
},
{
	"title": "To Kill a Mockingbird",
	"author": "Harper Lee"
}]
```

`title`, `author`의 패스는 각각 `[].title`과 `[].author`다. 책 한 권과 배열의 유일한 차이점은 이제 필드 패스에 `[].` 프리픽스가 추가됐다는 점이다.

책 정보를 문서화하는 descriptor는 다음과 같이 만들 수 있다:

```java
FieldDescriptor[] book = new FieldDescriptor[] {
		fieldWithPath("title").description("Title of the book"),
		fieldWithPath("author").description("Author of the book") };
```

이제 이걸 사용해서 책 한 권에 대한 API를 문서화하면 된다:

<div class="switch-language-wrapper mockmvc webtestclient restassured">
<span class="switch-language mockmvc">MockMvc</span>
<span class="switch-language webtestclient">WebTestClient</span>
<span class="switch-language restassured">REST Assured</span>
</div>
<div class="language-only-for-mockmvc mockmvc webtestclient restassured"></div>
```java
this.mockMvc.perform(get("/books/1").accept(MediaType.APPLICATION_JSON))
		.andExpect(status().isOk()).andDo(document("book", responseFields(book))); // (1)
```
<div class="language-only-for-webtestclient mockmvc webtestclient restassured"></div>
```java
this.webTestClient.get().uri("/books/1").accept(MediaType.APPLICATION_JSON)
	.exchange().expectStatus().isOk().expectBody()
	.consumeWith(document("book",
		responseFields(book))); // (1)
```
<div class="language-only-for-restassured mockmvc webtestclient restassured"></div>
```java
RestAssured.given(this.spec).accept("application/json")
	.filter(document("book", responseFields(book))) // (1)
	.when().get("/books/1")
	.then().assertThat().statusCode(is(200));
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 기존 descriptor를 사용해서 `title`과 `author`를 문서화한다.</small>

같은 descriptor로 책 배열도 문서화할 수 있다:

<div class="switch-language-wrapper mockmvc webtestclient restassured">
<span class="switch-language mockmvc">MockMvc</span>
<span class="switch-language webtestclient">WebTestClient</span>
<span class="switch-language restassured">REST Assured</span>
</div>
<div class="language-only-for-mockmvc mockmvc webtestclient restassured"></div>
```java
this.mockMvc.perform(get("/books").accept(MediaType.APPLICATION_JSON))
		.andExpect(status().isOk())
		.andDo(document("book",
				responseFields(
						fieldWithPath("[]").description("An array of books")) // (1)
								.andWithPrefix("[].", book))); // (2)
```
<div class="language-only-for-webtestclient mockmvc webtestclient restassured"></div>
```java
this.webTestClient.get().uri("/books").accept(MediaType.APPLICATION_JSON)
	.exchange().expectStatus().isOk().expectBody()
	.consumeWith(document("books",
		responseFields(
			fieldWithPath("[]")
				.description("An array of books")) // (1)
				.andWithPrefix("[].", book))); // (2)
```
<div class="language-only-for-restassured mockmvc webtestclient restassured"></div>
```java
RestAssured.given(this.spec).accept("application/json")
	.filter(document("books", responseFields(
		fieldWithPath("[]").description("An array of books")) // (1)
		.andWithPrefix("[].", book))) // (2)
	.when().get("/books")
	.then().assertThat().statusCode(is(200));
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 배열을 문서화한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 기존 descriptor에 `[].` 프리픽스를 달아 `[].title`과 `[].author`를 문서화한다.</small>

### 3.2.2. Documenting a Subsection of a Request or Response Payload

페이로드가 크거나 구조가 복잡하다면 페이로드를 섹션별로 문서화하는 것도 좋다. Rest Docs를 사용하면 페이로드의 하위 섹션을 추출해서 따로 문서화할 수 있다.

#### Documenting a Subsection of a Request or Response Body

아래 JSON 응답 바디를 생각해 보자:

```json
{
	"weather": {
		"wind": {
			"speed": 15.3,
			"direction": 287.0
		},
		"temperature": {
			"high": 21.2,
			"low": 14.8
		}
	}
}
```

`temperature` 객체를 문서화하는 스니펫은 다음과 같이 만들 수 있다:

<div class="switch-language-wrapper mockmvc webtestclient restassured">
<span class="switch-language mockmvc">MockMvc</span>
<span class="switch-language webtestclient">WebTestClient</span>
<span class="switch-language restassured">REST Assured</span>
</div>
<div class="language-only-for-mockmvc mockmvc webtestclient restassured"></div>
```java
this.mockMvc.perform(get("/locations/1").accept(MediaType.APPLICATION_JSON))
		.andExpect(status().isOk()).andDo(document("location",
				responseBody(beneathPath("weather.temperature")))); // (1)
```
<div class="language-only-for-webtestclient mockmvc webtestclient restassured"></div>
```java
this.webTestClient.get().uri("/locations/1").accept(MediaType.APPLICATION_JSON)
	.exchange().expectStatus().isOk().expectBody()
	.consumeWith(document("temperature",
		responseBody(beneathPath("weather.temperature")))); // (1)
```
<div class="language-only-for-restassured mockmvc webtestclient restassured"></div>
```java
RestAssured.given(this.spec).accept("application/json")
	.filter(document("location", responseBody(beneathPath("weather.temperature")))) // (1)
	.when().get("/locations/1")
	.then().assertThat().statusCode(is(200));
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 응답 바디의 하위 섹션만 가지고 있는 스니펫을 만든다. <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.payload.PayloadDocumentation</span>에 있는 스태틱 메소드 `responseBody`와 `beneathPath`를 사용한다. 요청 바디를 위한 스니펫은 `responseBody` 대신 `requestBody`를 사용하면 된다.</small>

결과로 만들어지는 스니펫은 다음 컨텐츠를 가지고 있다:

```json
{
	"temperature": {
		"high": 21.2,
		"low": 14.8
	}
}
```

스니펫 이름은 하위 섹션 식별자로 구분한다. 기본적으로 `beneath-${path}`를 식별자로 사용한다. 예를 들어 이전 코드는 `response-body-beneath-weather.temperature.adoc`이라는 스니펫을 만든다. 이 식별자는 다음과 같이 `withSubsectionId(String)` 메소드로 커스텀할 수 있다:

```java
responseBody(beneathPath("weather.temperature").withSubsectionId("temp"));
```

이제 `request-body-temp.adoc`이란 스니펫을 만든다.

#### Documenting the Fields of a Subsection of a Request or Response

요청/응답 바디 하위 섹션을 문서화할 수 있듯, 특정 섹션에 있는 필드만 문서화하는 것도 가능하다. `temperature` 객체의 필드(`high`, `low`)를 문서화하는 스니펫은 다음과 같이 만들 수 있다:

<div class="switch-language-wrapper mockmvc webtestclient restassured">
<span class="switch-language mockmvc">MockMvc</span>
<span class="switch-language webtestclient">WebTestClient</span>
<span class="switch-language restassured">REST Assured</span>
</div>
<div class="language-only-for-mockmvc mockmvc webtestclient restassured"></div>
```java
this.mockMvc.perform(get("/locations/1").accept(MediaType.APPLICATION_JSON))
		.andExpect(status().isOk())
		.andDo(document("location",
				responseFields(beneathPath("weather.temperature"), // (1)
						fieldWithPath("high").description(
								"The forecast high in degrees celcius"), // (2) 
				fieldWithPath("low")
						.description("The forecast low in degrees celcius"))));
```
<div class="language-only-for-webtestclient mockmvc webtestclient restassured"></div>
```java
this.webTestClient.get().uri("/locations/1").accept(MediaType.APPLICATION_JSON)
	.exchange().expectStatus().isOk().expectBody()
	.consumeWith(document("temperature",
		responseFields(beneathPath("weather.temperature"), // (1)
			fieldWithPath("high").description("The forecast high in degrees celcius"), // (2) 
			fieldWithPath("low").description("The forecast low in degrees celcius"))));
```
<div class="language-only-for-restassured mockmvc webtestclient restassured"></div>
```java
RestAssured.given(this.spec).accept("application/json")
	.filter(document("location", responseFields(beneathPath("weather.temperature"), // (1)
		fieldWithPath("high").description("The forecast high in degrees celcius"), // (2) 
		fieldWithPath("low").description("The forecast low in degrees celcius"))))
	.when().get("/locations/1")
	.then().assertThat().statusCode(is(200));
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 응답 페이로드에서 `weather.temperature` 패스 밑에 있는 섹션 필드를 설명하는 스니펫을 만든다. <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.payload.PayloadDocumentation</span>에 있는 스태틱 메소드 `beneathPath`를 사용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> `high`와 `low` 필드를 문서화한다.</small>

결과로 만들어지는 스니펫엔 `weather.temperature`의 `high`, `low` 필드를 설명하는 테이블이 있다. 스니펫 이름은 하위 섹션 식별자로 구분한다. 기본적으로 `beneath-${path}`를 식별자로 사용한다. 예를 들어 이전 코드는 `response-fields-beneath-weather.temperature.adoc`이란 스니펫을 만든다.

---

## 3.3. Request Parameters

요청 파라미터는 `requestParameters`로 문서화할 수 있다. 요청 파라미터는 `GET` 요청의 쿼리 스트링으로 추가한다. 다음은 그 방법을 보여준다:

<div class="switch-language-wrapper mockmvc webtestclient restassured">
<span class="switch-language mockmvc">MockMvc</span>
<span class="switch-language webtestclient">WebTestClient</span>
<span class="switch-language restassured">REST Assured</span>
</div>
<div class="language-only-for-mockmvc mockmvc webtestclient restassured"></div>
```java
this.mockMvc.perform(get("/users?page=2&per_page=100")) // (1)
	.andExpect(status().isOk())
	.andDo(document("users", requestParameters( // (2)
			parameterWithName("page").description("The page to retrieve"), // (3)
			parameterWithName("per_page").description("Entries per page") // (4)
	)));
```
<div class="language-only-for-webtestclient mockmvc webtestclient restassured"></div>
```java
this.webTestClient.get().uri("/users?page=2&per_page=100") // (1)
	.exchange().expectStatus().isOk().expectBody()
	.consumeWith(document("users", requestParameters( // (2)
			parameterWithName("page").description("The page to retrieve"), // (3)
			parameterWithName("per_page").description("Entries per page") // (4)
	)));
```
<div class="language-only-for-restassured mockmvc webtestclient restassured"></div>
```java
RestAssured.given(this.spec)
	.filter(document("users", requestParameters( // (1)
			parameterWithName("page").description("The page to retrieve"), // (2)
			parameterWithName("per_page").description("Entries per page")))) // (3)
	.when().get("/users?page=2&per_page=100") // (4)
	.then().assertThat().statusCode(is(200));
```
<div class="description-for-mockmvc mockmvc webtestclient restassured"></div>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 쿼리 스트링에 두 파라미터 `page`, `per_page`를 사용해서 `GET` 요청을 수행한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 요청 파라미터를 설명하는 스니펫을 만들도록 설정한다. <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.request.RequestDocumentation</span>에 있는 스태틱 메소드 `requestParameters`를 사용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> `page` 파라미터를 문서화한다. <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.request.RequestDocumentation</span>에 있는 스태틱 메소드 `parameterWithName`을 사용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> `per_page` 파라미터를 문서화한다.</small>

<div class="description-for-webtestclient mockmvc webtestclient restassured"></div>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 쿼리 스트링에 두 파라미터 `page`, `per_page`를 사용해서 `GET` 요청을 수행한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 요청 파라미터를 설명하는 스니펫을 만들도록 설정한다. <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.request.RequestDocumentation</span>에 있는 스태틱 메소드 `requestParameters`를 사용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> `page` 파라미터를 문서화한다. <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.request.RequestDocumentation</span>에 있는 스태틱 메소드 `parameterWithName`을 사용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> `per_page` 파라미터를 문서화한다.</small>

<div class="description-for-restassured mockmvc webtestclient restassured"></div>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 요청 파라미터를 설명하는 스니펫을 만들도록 설정한다. <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.request.RequestDocumentation</span>에 있는 스태틱 메소드 `requestParameters`를 사용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> `page` 파라미터를 문서화한다. <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.request.RequestDocumentation</span>에 있는 스태틱 메소드 `parameterWithName`을 사용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> `per_page` 파라미터를 문서화한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> 쿼리 스트링에 두 파라미터 `page`, `per_page`를 사용해서 `GET` 요청을 수행한다.</small>

요청 파라미터를 POST 요청 바디에 폼 데이터로 넣어도 된다. 다음은 그 방법을 보여준다:

<div class="switch-language-wrapper mockmvc webtestclient restassured">
<span class="switch-language mockmvc">MockMvc</span>
<span class="switch-language webtestclient">WebTestClient</span>
<span class="switch-language restassured">REST Assured</span>
</div>
<div class="language-only-for-mockmvc mockmvc webtestclient restassured"></div>
```java
this.mockMvc.perform(post("/users").param("username", "Tester")) // (1)
	.andExpect(status().isCreated())
	.andDo(document("create-user", requestParameters(
			parameterWithName("username").description("The user's username")
	)));
```
<div class="language-only-for-webtestclient mockmvc webtestclient restassured"></div>
```java
MultiValueMap<String, String> formData = new LinkedMultiValueMap<>();
formData.add("username", "Tester");
this.webTestClient.post().uri("/users").body(BodyInserters.fromFormData(formData)) // (1)
	.exchange().expectStatus().isCreated().expectBody()
	.consumeWith(document("create-user", requestParameters(
		parameterWithName("username").description("The user's username")
)));
```
<div class="language-only-for-restassured mockmvc webtestclient restassured"></div>
```java
RestAssured.given(this.spec)
	.filter(document("create-user", requestParameters(
			parameterWithName("username").description("The user's username"))))
	.formParam("username", "Tester") // (1)
	.when().post("/users") // (2)
	.then().assertThat().statusCode(is(200));
```
<div class="description-for-mockmvc mockmvc webtestclient restassured"></div>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `username` 파라미터 하나를 사용해 `POST` 요청을 수행한다.</small>
<div class="description-for-webtestclient mockmvc webtestclient restassured"></div>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `username` 파라미터 하나를 사용해 `POST` 요청을 수행한다</small>
<div class="description-for-restassured mockmvc webtestclient restassured"></div>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `username` 파라미터를 설정한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `POST` 요청을 수행한다.</small>

어떤 방법으로 테스트하든, `request-parameters.adoc`이란 스니펫이 만들어지며, 이 스니펫은 리소스가 지원하는 파라미터를 설명하는 테이블을 가지고 있다. 여기서도 마찬가지로 문서화한 요청 파라미터가 실제 요청에 없을 땐, 해당 파라미터를 선택 사항으로 마킹하지 않았다면 테스트는 실패한다.

요청 파라미터를 문서화하고 싶지 않다면 무시하도록 마킹해도 된다. 이렇게하면 위에서 언급한 테스트 실패를 방지하고, 만들어진 스니펫에서도 제외할 수 있다.

모든 요청 파라미터를 문서화하지 않아도 테스트가 실패하지 않도록 완화된 모드로 파라미터를 문서화할 수도 있다. 이렇게 하려면 <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.request.RequestDocumentation</span>에 있는 `relaxedRequestParameters` 메소드를 사용해라. 일부 요청 파라미터만 중요한 특정 시나리오를 문서화하기 유용하다.

---

## 3.4. Path Parameters

요청의 패스 파라미터는 `pathParameters`로 문서화할 수 있다. 다음은 그 방법을 보여준다:

<div class="switch-language-wrapper mockmvc webtestclient restassured">
<span class="switch-language mockmvc">MockMvc</span>
<span class="switch-language webtestclient">WebTestClient</span>
<span class="switch-language restassured">REST Assured</span>
</div>
<div class="language-only-for-mockmvc mockmvc webtestclient restassured"></div>
```java
this.mockMvc.perform(get("/locations/{latitude}/{longitude}", 51.5072, 0.1275)) // (1)
	.andExpect(status().isOk())
	.andDo(document("locations", pathParameters( // (2)
			parameterWithName("latitude").description("The location's latitude"), // (3)
			parameterWithName("longitude").description("The location's longitude") // (4)
	)));
```
<div class="language-only-for-webtestclient mockmvc webtestclient restassured"></div>
```java
this.webTestClient.get().uri("/locations/{latitude}/{longitude}", 51.5072, 0.1275) // (1)
	.exchange().expectStatus().isOk().expectBody()
	.consumeWith(document("locations",
		pathParameters( // (2)
			parameterWithName("latitude").description("The location's latitude"), // (3)
			parameterWithName("longitude").description("The location's longitude")))); // (4)
```
<div class="language-only-for-restassured mockmvc webtestclient restassured"></div>
```java
RestAssured.given(this.spec)
	.filter(document("locations", pathParameters( // (1)
			parameterWithName("latitude").description("The location's latitude"), // (2)
			parameterWithName("longitude").description("The location's longitude")))) // (3)
	.when().get("/locations/{latitude}/{longitude}", 51.5072, 0.1275) // (4)
	.then().assertThat().statusCode(is(200));
```
<div class="description-for-mockmvc mockmvc webtestclient restassured"></div>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 두 패스 파라미터 `latitude`, `longitude`를 사용해서 `GET` 요청을 수행한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 요청 패스 파라미터를 설명하는 스니펫을 만들도록 설정한다. <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.request.RequestDocumentation</span>에 있는 스태틱 메소드 `pathParameters`를 사용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> `latitude` 파라미터를 문서화한다. <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.request.RequestDocumentation</span>에 있는 스태틱 메소드 `parameterWithName`을 사용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> `longitude` 파라미터를 문서화한다.</small>

<div class="description-for-webtestclient mockmvc webtestclient restassured"></div>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 두 패스 파라미터 `latitude`, `longitude`를 사용해서 `GET` 요청을 수행한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 요청 패스 파라미터를 설명하는 스니펫을 만들도록 설정한다. <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.request.RequestDocumentation</span>에 있는 스태틱 메소드 `pathParameters`를 사용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> `latitude` 파라미터를 문서화한다. <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.request.RequestDocumentation</span>에 있는 스태틱 메소드 `parameterWithName`을 사용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> `longitude` 파라미터를 문서화한다.</small>

<div class="description-for-restassured mockmvc webtestclient restassured"></div>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 요청 패스 파라미터를 설명하는 스니펫을 만들도록 설정한다. <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.request.RequestDocumentation</span>에 있는 스태틱 메소드 `pathParameters`를 사용한다.</small>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> `latitude` 파라미터를 문서화한다. <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.request.RequestDocumentation</span>에 있는 스태틱 메소드 `parameterWithName`을 사용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> `longitude` 파라미터를 문서화한다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> 두 패스 파라미터 `latitude`, `longitude`를 사용해서 `GET` 요청을 수행한다.</small>

`path-parameters.adoc`이란 스니펫이 만들어지며, 이 스니펫은 리소스가 지원하는 패스 파라미터를 설명하는 테이블을 가지고 있다.

> MockMvc로 패스 파라미터를 문서화한다면, `MockMvcRequestBuilders` 대신 `RestDocumentationRequestBuilders`에 있는 메소드 중 하나로 요청을 빌드해야 한다.

패스 파라미터를 문서화할 땐, 요청에 있는 모든 패스 파라미터를 작성하지 않으면 테스트는 실패한다. 마찬가지로 문서화한 패스 파라미터가 요청에 없을 땐, 해당 패스 파라미터를 선택 사항으로 마킹하지 않았다면 테스트는 실패한다.

모든 파라미터를 문서화하지 않아도 테스트가 실패하지 않도록 완화된 모드로 패스 파라미터를 문서화할 수도 있다. 이렇게 하려면 <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.request.RequestDocumentation</span>에 있는 `relaxedPathParameters` 메소드를 사용해라. 일부 패스 파라미터만 중요한 특정 시나리오를 문서화하기 유용하다.

패스 파라미터를 문서화하고 싶지 않다면 무시하도록 마킹해도 된다. 이렇게하면 위에서 언급한 테스트 실패를 방지하고, 만들어진 스니펫에서도 제외할 수 있다.

---

## 3.5. Request Parts

멀티파트 요청의 part는 `requestParts`로 문서화할 수 있다. 다음은 그 방법을 보여준다:

<div class="switch-language-wrapper mockmvc webtestclient restassured">
<span class="switch-language mockmvc">MockMvc</span>
<span class="switch-language webtestclient">WebTestClient</span>
<span class="switch-language restassured">REST Assured</span>
</div>
<div class="language-only-for-mockmvc mockmvc webtestclient restassured"></div>
```java
this.mockMvc.perform(multipart("/upload").file("file", "example".getBytes())) // (1)
	.andExpect(status().isOk())
	.andDo(document("upload", requestParts( // (2)
			partWithName("file").description("The file to upload")) // (3)
));
```
<div class="language-only-for-webtestclient mockmvc webtestclient restassured"></div>
```java
MultiValueMap<String, Object> multipartData = new LinkedMultiValueMap<>();
multipartData.add("file", "example".getBytes());
this.webTestClient.post().uri("/upload").body(BodyInserters.fromMultipartData(multipartData)) // (1)
	.exchange().expectStatus().isOk().expectBody()
	.consumeWith(document("upload", requestParts( // (2)
		partWithName("file").description("The file to upload")) // (3)
));
```
<div class="language-only-for-restassured mockmvc webtestclient restassured"></div>
```java
RestAssured.given(this.spec)
	.filter(document("users", requestParts( // (1)
			partWithName("file").description("The file to upload")))) // (2)
	.multiPart("file", "example") // (3)
	.when().post("/upload") // (4)
	.then().statusCode(is(200));
```
<div class="description-for-mockmvc mockmvc webtestclient restassured"></div>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `file`이란 이름을 가진 part 하나로 `POST` 요청을 수행한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 요청의 part를 설명하는 스니펫을 만들도록 설정한다. <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.request.RequestDocumentation</span>에 있는 스태틱 메소드 `requestParts`를 사용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> `file` part를 문서화한다. <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.request.RequestDocumentation</span>에 있는 스태틱 메소드 `partWithName`을 사용한다.</small>
<div class="description-for-webtestclient mockmvc webtestclient restassured"></div>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `file`이란 이름을 가진 part 하나로 `POST` 요청을 수행한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 요청의 part를 설명하는 스니펫을 만들도록 설정한다. <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.request.RequestDocumentation</span>에 있는 스태틱 메소드 `requestParts`를 사용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> `file` part를 문서화한다. <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.request.RequestDocumentation</span>에 있는 스태틱 메소드 `partWithName`을 사용한다.</small>
<div class="description-for-restassured mockmvc webtestclient restassured"></div>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 요청의 part를 설명하는 스니펫을 만들도록 설정한다. <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.request.RequestDocumentation</span>에 있는 스태틱 메소드 `requestParts`를 사용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> `file` part를 문서화한다. <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.request.RequestDocumentation</span>에 있는 스태틱 메소드 `partWithName`을 사용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 요청에 `file`이란 이름을 가진 part를 설정한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> `/upload`로 `POST` 요청을 보낸다.</small>

`request-parts.adoc`이란 스니펫이 만들어지며, 이 스니펫은 리소스가 지원하는 요청 part를 설명하는 테이블을 가지고 있다.

요청 part를 문서화할 땐, 요청에 있는 모든 part를 작성하지 않으면 테스트는 실패한다. 마찬가지로 문서화한 part가 요청에 없을 땐, 해당 part를 선택 사항으로 마킹하지 않았다면 테스트는 실패한다.

모든 part를 문서화하지 않아도 테스트가 실패하지 않도록 완화된 모드로 요청 part를 문서화할 수도 있다. 이렇게 하려면 <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.request.RequestDocumentation</span>에 있는 `relaxedRequestParts` 메소드를 사용해라. 일부 요청 part만 중요한 특정 시나리오를 문서화하기 유용하다.

요청 part를 문서화하고 싶지 않다면 무시하도록 마킹해도 된다. 이렇게하면 위에서 언급한 테스트 실패를 방지하고, 만들어진 스니펫에서도 제외할 수 있다.

---

## 3.6. Request Part Payloads

요청 part의 바디와 해당 필드도 지원하므로, 요청 part의 페이로드도 [요청 페이로드](#32-request-and-response-payloads)와 거의 동일한 방식으로 문서화할 수 있다.

### 3.6.1. Documenting a Request Part’s Body

요청 part 바디를 가진 스니펫은 다음과 같이 만들 수 있다:

<div class="switch-language-wrapper mockmvc webtestclient restassured">
<span class="switch-language mockmvc">MockMvc</span>
<span class="switch-language webtestclient">WebTestClient</span>
<span class="switch-language restassured">REST Assured</span>
</div>
<div class="language-only-for-mockmvc mockmvc webtestclient restassured"></div>
```java
MockMultipartFile image = new MockMultipartFile("image", "image.png", "image/png",
		"<<png data>>".getBytes());
MockMultipartFile metadata = new MockMultipartFile("metadata", "",
		"application/json", "{ \"version\": \"1.0\"}".getBytes());

this.mockMvc.perform(fileUpload("/images").file(image).file(metadata)
			.accept(MediaType.APPLICATION_JSON))
	.andExpect(status().isOk())
	.andDo(document("image-upload", requestPartBody("metadata"))); // (1)
```
<div class="language-only-for-webtestclient mockmvc webtestclient restassured"></div>
```java
MultiValueMap<String, Object> multipartData = new LinkedMultiValueMap<>();
Resource imageResource = new ByteArrayResource("<<png data>>".getBytes()) {

	@Override
	public String getFilename() {
		return "image.png";
	}

};
multipartData.add("image", imageResource);
multipartData.add("metadata", Collections.singletonMap("version",  "1.0"));

this.webTestClient.post().uri("/images").body(BodyInserters.fromMultipartData(multipartData))
	.accept(MediaType.APPLICATION_JSON).exchange()
	.expectStatus().isOk().expectBody()
	.consumeWith(document("image-upload",
			requestPartBody("metadata"))); // (1)
```
<div class="language-only-for-restassured mockmvc webtestclient restassured"></div>
```java
Map<String, String> metadata = new HashMap<>();
metadata.put("version", "1.0");
RestAssured.given(this.spec).accept("application/json")
	.filter(document("image-upload", requestPartBody("metadata"))) // (1)
	.when().multiPart("image", new File("image.png"), "image/png")
			.multiPart("metadata", metadata).post("images")
	.then().assertThat().statusCode(is(200));
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `metadata`란 이름을 가진 요청 part 바디를 스니펫으로 만들도록 설정한다. `PayloadDocumentation`에 있는 스태틱 메소드 `requestPartBody`를 사용한다.</small>

결과로 만들어지는 스니펫은 `request-part-${part-name}-body.adoc`이며, part의 바디를 가지고 있다. 예를 들어 `metadata`란 이름의 part를 문서화하면 `request-part-metadata-body.adoc`이란 스니펫을 만든다.

### 3.6.2. Documenting a Request Part’s Fields

<div class="switch-language-wrapper mockmvc webtestclient restassured">
<span class="switch-language mockmvc">MockMvc</span>
<span class="switch-language webtestclient">WebTestClient</span>
<span class="switch-language restassured">REST Assured</span>
</div>
<div class="language-only-for-mockmvc mockmvc webtestclient restassured"></div>
```java
MockMultipartFile image = new MockMultipartFile("image", "image.png", "image/png",
		"<<png data>>".getBytes());
MockMultipartFile metadata = new MockMultipartFile("metadata", "",
		"application/json", "{ \"version\": \"1.0\"}".getBytes());

this.mockMvc.perform(fileUpload("/images").file(image).file(metadata)
			.accept(MediaType.APPLICATION_JSON))
	.andExpect(status().isOk())
	.andDo(document("image-upload", requestPartFields("metadata", // (1)
			fieldWithPath("version").description("The version of the image")))); // (2)
```
<div class="language-only-for-webtestclient mockmvc webtestclient restassured"></div>
```java
MultiValueMap<String, Object> multipartData = new LinkedMultiValueMap<>();
Resource imageResource = new ByteArrayResource("<<png data>>".getBytes()) {

	@Override
	public String getFilename() {
		return "image.png";
	}

};
multipartData.add("image", imageResource);
multipartData.add("metadata", Collections.singletonMap("version",  "1.0"));
this.webTestClient.post().uri("/images").body(BodyInserters.fromMultipartData(multipartData))
	.accept(MediaType.APPLICATION_JSON).exchange()
	.expectStatus().isOk().expectBody()
	.consumeWith(document("image-upload",
		requestPartFields("metadata", // (1)
			fieldWithPath("version").description("The version of the image")))); // (2)
```
<div class="language-only-for-restassured mockmvc webtestclient restassured"></div>
```java
Map<String, String> metadata = new HashMap<>();
metadata.put("version", "1.0");
RestAssured.given(this.spec).accept("application/json")
	.filter(document("image-upload", requestPartFields("metadata", // (1)
			fieldWithPath("version").description("The version of the image")))) // (2)
	.when().multiPart("image", new File("image.png"), "image/png")
			.multiPart("metadata", metadata).post("images")
	.then().assertThat().statusCode(is(200));
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `metadata`라는 요청 part 페이로드에 있는 필드들을 설명하는 스니펫을 만들도록 설정한다. `PayloadDocumentation`에 있는 스태틱 메소드 `requestPartFields`를 사용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> `version` 패스에 필드가 있는지 검증한다. <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.payload.PayloadDocumentation</span>에 있는 스태틱 메소드 `fieldWithPath`를 사용한다.</small>

결과로 만들어지는 스니펫은 part 필드를 설명하는 테이블을 가지고 있다. 스니펫 이름은 `request-part-${part-name}-fields.adoc`이 된다. 예를 들어 `metadata`란 part를 문서화하면 `request-part-metadata-fields.adoc`이란 스니펫이 생긴다.

필드를 문서화할 땐, part 페이로드에 있는 모든 필드를 작성하지 않으면 테스트는 실패한다. 마찬가지로 문서화한 필드가 part 페이로드에 없을 땐, 해당 필드를 선택 사항으로 마킹하지 않았다면 테스트는 실패한다. 계층 구조를 쓰는 페이로드는 필드 하나만 작성해도 하위 필드도 문서화한 것으로 처리한다.

필드를 문서화하고 싶지 않다면 무시하도록 마킹해도 된다. 이렇게하면 위에서 언급한 테스트 실패를 방지하고, 만들어진 스니펫에서도 제외할 수 있다.

모든 필드를 문서화하지 않아도 테스트가 실패하지 않도록 완화된 모드로 필드를 문서화할 수도 있다. 이렇게 하려면 <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.payload.PayloadDocumentation</span>에 있는 `relaxedRequestPartFields` 메소드를 사용해라. 일부 part 페이로드만 중요한 특정 시나리오를 문서화하기 유용하다.

필드에 대한 설명이나 XML을 쓰는 페이로드 문서화 등에 대한 자세한 정보는 [요청과 응답 페이로드 문서 작성하기 섹션](#32-request-and-response-payloads)을 참고해라.

---

## 3.7. HTTP Headers

요청, 응답 헤더는 `requestHeaders`, `responseHeaders`로 문서화할 수 있다. 다음은 그 방법을 보여준다:

<div class="switch-language-wrapper mockmvc webtestclient restassured">
<span class="switch-language mockmvc">MockMvc</span>
<span class="switch-language webtestclient">WebTestClient</span>
<span class="switch-language restassured">REST Assured</span>
</div>
<div class="language-only-for-mockmvc mockmvc webtestclient restassured"></div>
```java
this.mockMvc
	.perform(get("/people").header("Authorization", "Basic dXNlcjpzZWNyZXQ=")) // (1)
	.andExpect(status().isOk())
	.andDo(document("headers",
			requestHeaders( // (2)
					headerWithName("Authorization").description(
							"Basic auth credentials")), // (3)
			responseHeaders( // (4)
					headerWithName("X-RateLimit-Limit").description(
							"The total number of requests permitted per period"),
					headerWithName("X-RateLimit-Remaining").description(
							"Remaining requests permitted in current period"),
					headerWithName("X-RateLimit-Reset").description(
							"Time at which the rate limit period will reset"))));
```
<div class="language-only-for-webtestclient mockmvc webtestclient restassured"></div>
```java
this.webTestClient
	.get().uri("/people").header("Authorization", "Basic dXNlcjpzZWNyZXQ=") // (1)
	.exchange().expectStatus().isOk().expectBody()
	.consumeWith(document("headers",
		requestHeaders( // (2)
			headerWithName("Authorization").description("Basic auth credentials")), // (3)
		responseHeaders( // (4)
			headerWithName("X-RateLimit-Limit")
				.description("The total number of requests permitted per period"),
			headerWithName("X-RateLimit-Remaining")
				.description("Remaining requests permitted in current period"),
			headerWithName("X-RateLimit-Reset")
				.description("Time at which the rate limit period will reset"))));
```
<div class="language-only-for-restassured mockmvc webtestclient restassured"></div>
```java
RestAssured.given(this.spec)
	.filter(document("headers",
			requestHeaders( // (1)
					headerWithName("Authorization").description(
							"Basic auth credentials")), // (2)
			responseHeaders( // (3)
					headerWithName("X-RateLimit-Limit").description(
							"The total number of requests permitted per period"),
					headerWithName("X-RateLimit-Remaining").description(
							"Remaining requests permitted in current period"),
					headerWithName("X-RateLimit-Reset").description(
							"Time at which the rate limit period will reset"))))
	.header("Authorization", "Basic dXNlcjpzZWNyZXQ=") // (4)
	.when().get("/people")
	.then().assertThat().statusCode(is(200));
```
<div class="description-for-mockmvc mockmvc webtestclient restassured"></div>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> basic 인증을 위한 `Authorization` 헤더를 사용해서 `GET` 요청을 수행한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 요청 헤더를 설명하는 스니펫을 만들도록 설정한다. <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.headers.HeaderDocumentation</span>에 있는 스태틱 메소드 `requestHeaders`를 사용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> `Authorization` 헤더를 문서화한다. <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.headers.HeaderDocumentation</span>에 있는 스태틱 메소드 `headerWithName`을 사용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> 응답 헤더를 설명하는 스니펫을 만든다. <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.headers.HeaderDocumentation</span>에 있는 스태틱 메소드 `responseHeaders`를 사용한다.</small>
<div class="description-for-webtestclient mockmvc webtestclient restassured"></div>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> basic 인증을 위한 `Authorization` 헤더를 사용해서 `GET` 요청을 수행한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 요청 헤더를 설명하는 스니펫을 만들도록 설정한다. <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.headers.HeaderDocumentation</span>에 있는 스태틱 메소드 `requestHeaders`를 사용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> `Authorization` 헤더를 문서화한다. <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.headers.HeaderDocumentation</span>에 있는 스태틱 메소드 `headerWithName`을 사용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> 응답 헤더를 설명하는 스니펫을 만든다. <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.headers.HeaderDocumentation</span>에 있는 스태틱 메소드 `responseHeaders`를 사용한다.</small>
<div class="description-for-restassured mockmvc webtestclient restassured"></div>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 요청 헤더를 설명하는 스니펫을 만들도록 설정한다. <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.headers.HeaderDocumentation</span>에 있는 스태틱 메소드 `requestHeaders`를 사용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> `Authorization` 헤더를 문서화한다. <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.headers.HeaderDocumentation</span>에 있는 스태틱 메소드 `headerWithName`을 사용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 응답 헤더를 설명하는 스니펫을 만든다. <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.headers.HeaderDocumentation</span>에 있는 스태틱 메소드 `responseHeaders`를 사용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> 요청에 basic 인증을 위한 `Authorization` 헤더를 설정한다.</small>

결과로 `request-headers.adoc`과 `response-headers.adoc` 스니펫이 만들어진다. 두 스니펫 모두 헤더를 설명하는 테이블을 가지고 있다.

HTTP 헤더를 문서화할 땐 요청, 응답에 있는 모든 헤더를 작성하지 않으면 테스트는 실패한다.

---

## 3.8. Reusing Snippets

보통 문서화하는 API에는 여러 리소스에서 사용하는 공통 기능이 있기 마련이다. 이런 리소스를 문서화할 땐 공통 요소로 설정한 `Snippet`을 재사용하면 중복 코드를 피할 수 있다.

먼저 공통 요소를 설명하는 `Snippet`을 만들어야 한다. 다음은 그 방법을 보여준다:

```java
protected final LinksSnippet pagingLinks = links(
		linkWithRel("first").optional().description("The first page of results"),
		linkWithRel("last").optional().description("The last page of results"),
		linkWithRel("next").optional().description("The next page of results"),
		linkWithRel("prev").optional().description("The previous page of results"));
```

그 다음엔 이 스니펫을 사용해서 리소스에 특화된 descriptor를 별도로 추가하면 된다. 다음 예제를 참고해라:

<div class="switch-language-wrapper mockmvc webtestclient restassured">
<span class="switch-language mockmvc">MockMvc</span>
<span class="switch-language webtestclient">WebTestClient</span>
<span class="switch-language restassured">REST Assured</span>
</div>
<div class="language-only-for-mockmvc mockmvc webtestclient restassured"></div>
```java
this.mockMvc.perform(get("/").accept(MediaType.APPLICATION_JSON))
	.andExpect(status().isOk())
	.andDo(document("example", this.pagingLinks.and( // (1)
			linkWithRel("alpha").description("Link to the alpha resource"),
			linkWithRel("bravo").description("Link to the bravo resource"))));
```
<div class="language-only-for-webtestclient mockmvc webtestclient restassured"></div>
```java
this.webTestClient.get().uri("/").accept(MediaType.APPLICATION_JSON).exchange()
	.expectStatus().isOk().expectBody()
	.consumeWith(document("example", this.pagingLinks.and( // (1)
		linkWithRel("alpha").description("Link to the alpha resource"),
		linkWithRel("bravo").description("Link to the bravo resource"))));
```
<div class="language-only-for-restassured mockmvc webtestclient restassured"></div>
```java
RestAssured.given(this.spec)
	.accept("application/json")
	.filter(document("example", this.pagingLinks.and( // (1)
			linkWithRel("alpha").description("Link to the alpha resource"),
			linkWithRel("bravo").description("Link to the bravo resource"))))
	.get("/").then().assertThat().statusCode(is(200));
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `pagingLinks` `Snippet`을 재사용하고, 문서화할 리소스에 특화된 descriptor를 `and`로 추가한다.</small>

이 예제를 실행하면 `rel`이  `first`, `last`, `next`, `previous`, `alpha`, `bravo`인 링크를 전부 문서화한다.

---

## 3.9. Documenting Constraints

스프링 Rest Docs는 여러 가지 클래스로 제약 조건 문서화를 돕는다. 클래스 제약 조건 설명은 `ConstraintDescriptions` 인스턴스로 접근할 수 있다. 다음은 그 방법을 보여준다:

```java
public void example() {
	ConstraintDescriptions userConstraints = new ConstraintDescriptions(UserInput.class); // (1)
	List<String> descriptions = userConstraints.descriptionsForProperty("name"); // (2)
}

static class UserInput {

	@NotNull
	@Size(min = 1)
	String name;

	@NotNull
	@Size(min = 8)
	String password;

}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `UserInput` 클래스를 위한 `ConstraintDescriptions` 인스턴스를 생성한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> `name` 프로퍼티의 제약조건 설명을 가져온다. 이 리스트엔 두 가지 설명이 담겨있다: `NotNull` 제약 조건과 `Size` 제약 조건.</small>

이 기능을 활용한 사례는 스프링 HATEOAS 샘플에 있는 [`ApiDocumentation`](https://github.com/spring-projects/spring-restdocs/tree/v2.0.5.RELEASE/samples/rest-notes-spring-hateoas/src/test/java/com/example/notes/ApiDocumentation.java) 클래스를 보면 알 수 있다.

### 3.9.1. Finding Constraints

기본적으로 제약 조건은 Bean Validation `Validator`를 사용해 찾는다. 현재는 프로퍼티 제약조건만 지원한다. 커스텀 `ValidatorConstraintResolver` 인스턴스로 `ConstraintDescriptions`를 만들면 이때 사용할 `Validator`를 커스텀할 수 있다. 제약 조건 resolution을 완전히 제어하고 싶으면 `ConstraintResolver`를 직접 구현하면 된다.

### 3.9.2. Describing Constraints

Bean Validation 2.0에 있는 모든 제약 조건은 디폴트로 설명을 제공한다:

- `AssertFalse`
- `AssertTrue`
- `DecimalMax`
- `DecimalMin`
- `Digits`
- `Email`
- `Future`
- `FutureOrPresent`
- `Max`
- `Min`
- `Negative`
- `NegativeOrZero`
- `NotBlank`
- `NotEmpty`
- `NotNull`
- `Null`
- `Past`
- `PastOrPresent`
- `Pattern`
- `Positive`
- `PositiveOrZero`
- `Size`

Hibernate Validator에 있는 아래 제약 조건에 대한 기본 설명도 함께 지원한다:

- `CodePointLength`
- `CreditCardNumber`
- `Currency`
- `EAN`
- `Email`
- `Length`
- `LuhnCheck`
- `Mod10Check`
- `Mod11Check`
- `NotBlank`
- `NotEmpty`
- `Currency`
- `Range`
- `SafeHtml`
- `URL`

디폴트 설명을 재정의하거나 다른 설명을 사용하고 싶다면, base name이 <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.constraints.ConstraintDescriptions</span>인 리소스 번들을 만들면 된다. [리소스 번들을 사용하는 예시](https://github.com/spring-projects/spring-restdocs/tree/v2.0.5.RELEASE/samples/rest-notes-spring-hateoas/src/test/resources/org/springframework/restdocs/constraints/ConstraintDescriptions.properties)는 스프링 HATEOAS 기반 샘플에서 확인할 수 있다.

리소스 번들에 있는 각 키에 `.description`을 더한 게 제약 조건의 풀 네임이다. 예를 들어 표준 `@NotNull` 제약 조건의 키는 `javax.validation.constraints.NotNull.description`이다.

설명 부분에선 제약 조건의 속성을 가리키는 프로퍼티 플레이스홀더를 사용할 수 있다. 예를 들어 `@Min` 제약 조건의 기본 설명 `Must be at least ${value}`에선 제약 조건의 `value` 속성을 참조하고 있다.

제약 조건 설명 처리를 좀 더 제어하고 싶으면, 커스텀 `ResourceBundleConstraintDescriptionResolver`로 `ConstraintDescriptions`를 만들면 된다. 완전히 제어하려면 커스텀 `ConstraintDescriptionResolver` 구현체로 `ConstraintDescriptions`를 만들어라.

### 3.9.3. Using Constraint Descriptions in Generated Snippets

제약 조건에 대한 설명이 있다면 생성할 스니펫에서 원하는대로 사용할 수 있다. 예를 들어 필드를 설명하면서 제약 조건을 함께 설명하고 싶을 수 있다. 아니면 요청 필드 스니펫 [추가 정보](#3122-including-extra-information)에 제약 조건을 넣을 수도 있다. 스프링 HATEOAS 기반 샘플에 있는 [`ApiDocumentation`](https://github.com/spring-projects/spring-restdocs/tree/v2.0.5.RELEASE/samples/rest-notes-spring-hateoas/src/test/java/com/example/notes/ApiDocumentation.java) 클래스는 후자의 접근 방식을 보여준다.

---

## 3.10. Default Snippets

요청과 응답을 문서화하면 자동으로 여러 가지 스니펫이 만들어 진다.

| Snippet               | Description                                                  |
| :-------------------- | :----------------------------------------------------------- |
| `curl-request.adoc`   | 문서화하는 `MockMvc` 호출과 동일한 [`curl`](https://curl.haxx.se/) 명령어가 있다. |
| `httpie-request.adoc` | 문서화하는 `MockMvc` 호출과 동일한 [`HTTPie`](https://httpie.org/) 명령어가 있다. |
| `http-request.adoc`   | 문서화하는 `MockMvc` 호출과 동일한 HTTP 요청이 있다.         |
| `http-response.adoc`  | 반환된 HTTP 응답이 있다.                                     |
| `request-body.adoc`   | 전송한 요청 바디가 있다.                                     |
| `response-body.adoc`  | 반환된 응답 바디가 있다.                                     |

디폴트로 생성할 스니펫을 설정해도 된다. 자세한 정보는 [설정 섹션](../configuration)을 참고해라.

---

## 3.11. Using Parameterized Output Directories

MockMvc나 REST Assured를 사용할 땐, `document`에서 쓸 출력 디렉토리를 파라미터로 만들 수 있다. `WebTestClient`를 사용할 때는 불가능하다.

다음 파라미터를 지원한다:

| Parameter     | Description                                           |
| :------------ | :---------------------------------------------------- |
| {methodName}  | 테스트 메소드의 원래 이름.                            |
| {method-name} | 캐밥 케이스로 표기한 테스트 메소드 이름.              |
| {method_name} | 스네이크 케이스로 표기한 테스트 메소드 이름.          |
| {ClassName}   | 테스트 클래스의 원래 이름.                            |
| {class-name}  | 캐밥 케이스로 표기한 테스트 클래스의 simple name.     |
| {class_name}  | 스네이크 케이스로 표기한 테스트 클래스의 simple name. |
| {step}        | 현재 테스트에서 서비스를 호출한 횟수.                 |

예를 들어 테스트 클래스가 `GettingStartedDocumentation`이고 테스트 메소드는 `creatingANote`라면,  `document("{class-name}/{method-name}")`은 `getting-started-documentation/creating-a-note`란 디렉토리에 스니펫을 생성한다.

출력 디렉토리를 파라미터로 만드는 건 특히 `@Before` 메소드와 함께 쓸 때 유용하다. 초기 세팅 메소드에서 문서를 한 번만 설정하고, 클래스 내 모든 테스트에 재사용할 수 있기 때문이다. 다음은 그 방법을 보여준다:

<div class="switch-language-wrapper mockmvc restassured">
<span class="switch-language mockmvc">MockMvc</span>
<span class="switch-language restassured">REST Assured</span>
</div>
<div class="language-only-for-mockmvc mockmvc restassured"></div>
```java
@Before
public void setUp() {
	this.mockMvc = MockMvcBuilders.webAppContextSetup(this.context)
			.apply(documentationConfiguration(this.restDocumentation))
			.alwaysDo(document("{method-name}/{step}/")).build();
}
```
<div class="language-only-for-restassured mockmvc restassured"></div>
```java
@Before
public void setUp() {
	this.spec = new RequestSpecBuilder()
			.addFilter(documentationConfiguration(this.restDocumentation))
			.addFilter(document("{method-name}/{step}")).build();
}
```

이렇게 설정해 두면, 다른 설정이 없어도 테스트하는 서비스를 호출할 때마다 [디폴트 스니펫](#310-default-snippets)을 만든다. 사용 사례는 각 샘플 어플리케이션에 있는 `GettingStartedDocumentation` 클래스를 살펴봐라.

---

## 3.12. Customizing the Output

이번 섹션에선 스프링 REST Docs 결과물을 커스텀하는 방법을 설명한다.

### 3.12.1. Customizing the Generated Snippets

스프링 Rest Docs는 [Mustache](https://mustache.github.io/) 템플릿으로 스니펫을 만든다. 스프링 Rest Docs는 생성하는 모든 스니펫마다 [디폴트 템플릿](https://github.com/spring-projects/spring-restdocs/tree/v2.0.5.RELEASE/spring-restdocs-core/src/main/resources/org/springframework/restdocs/templates)을 제공한다. 스니펫 내용을 커스텀하려면 자체 템플릿을 제공하면 된다.

템플릿은 `org.springframework.restdocs.templates` 하위 패키지 클래스패스에서 로드한다. 하위 패키지명은 사용 중인 템플릿 포맷의 ID로 결정한다. 디폴트 템플릿 포맷 Asciidoctor는 ID가 `asciidoctor`이므로, `org.springframework.restdocs.templates.asciidoctor`에서 스니펫을 로드한다. 각 템플릿 이름은 생성할 스니펫 이름에서 따온다. 예를 들어 `curl-request.adoc` 스니펫 템플릿을 재정의하려면, `src/test/resources/org/springframework/restdocs/templates/asciidoctor` 아래 `curl-request.snippet`이란 템플릿을 생성해라.

### 3.12.2. Including Extra Information

스니펫에는 두 가지 방법으로 추가 정보를 넣을 수 있다:

- descriptor의 `attributes` 메소드로 하나 이상의 속성을 추가한다.
- `curlRequest`, `httpRequest`, `httpResponse` 등을 호출할 때 속성을 전달한다. 전체 스니펫과 관련있는 스니펫은 여기로 넘긴다.

이렇게 추가한 속성은 템플릿을 렌더링할 때 접근할 수 있다. 커스텀 스니펫 템플릿을 함께 사용하면 스니펫에 추가 정보를 넣을 수 있다.

구체적으로 예를 들자면, 요청 필드 문서에 제약 조건 컬럼과 제목을 추가할 수 있다. 먼저 문서화할 각 필드에 `constraints` 속성을 주고, `title` 속성도 추가한다. 다음은 그 방법을 보여준다:

<div class="switch-language-wrapper mockmvc webtestclient restassured">
<span class="switch-language mockmvc">MockMvc</span>
<span class="switch-language webtestclient">WebTestClient</span>
<span class="switch-language restassured">REST Assured</span>
</div>
<div class="language-only-for-mockmvc mockmvc webtestclient restassured"></div>
```java
.andDo(document("create-user", requestFields(
		attributes(key("title").value("Fields for user creation")), // (1)
		fieldWithPath("name").description("The user's name")
				.attributes(key("constraints")
						.value("Must not be null. Must not be empty")), // (2)
		fieldWithPath("email").description("The user's email address")
				.attributes(key("constraints")
						.value("Must be a valid email address"))))); // (3)
```
<div class="language-only-for-webtestclient mockmvc webtestclient restassured"></div>
```java
consumeWith(document("create-user",
	requestFields(
		attributes(key("title").value("Fields for user creation")), // (1)
		fieldWithPath("name")
			.description("The user's name")
			.attributes(key("constraints").value("Must not be null. Must not be empty")), // (2)
		fieldWithPath("email")
			.description("The user's email address")
			.attributes(key("constraints").value("Must be a valid email address"))))); // (3)
```
<div class="language-only-for-restassured mockmvc webtestclient restassured"></div>
```java
.filter(document("create-user", requestFields(
		attributes(key("title").value("Fields for user creation")), // (1)
		fieldWithPath("name").description("The user's name")
				.attributes(key("constraints")
						.value("Must not be null. Must not be empty")), // (2)
		fieldWithPath("email").description("The user's email address")
				.attributes(key("constraints")
						.value("Must be a valid email address"))))) // (3)
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 요청 필드 스니펫에 `title` 속성을 설정한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> `name` 필드에 `constraints` 속성을 설정한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> `email` 필드에 `constraints` 속성을 설정한다.</small>

다음 할 일은 만들어진 스니펫 테이블에 필드 제약 조건과 제목을 추가하는 커스텀 템플릿 `request-fields.snippet`을 제공하는 거다. 다음 예제를 참고해라:

```
{% raw %}.{{title}}{% endraw %} // (1)
|===
|Path|Type|Description|Constraints // (2)

{% raw %}{{#fields}}{% endraw %}
|{% raw %}{{path}}{% endraw %}
|{% raw %}{{type}}{% endraw %}
|{% raw %}{{description}}{% endraw %}
|{% raw %}{{constraints}}{% endraw %} // (3)

{% raw %}{{/fields}}{% endraw %}
|===
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 테이블에 제목을 추가한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 새 컬럼 "Constraints"를 추가한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 각 테이블 행에 descriptor의 `constraints` 속성을 넣는다.</small>