---
title: 3.3. Dynamic properties
navTitle: Dynamic properties
category: Spring Cloud Contract
order: 17
permalink: /Spring%20Cloud%20Contract/dynamic-properties/
description: 컨트랙트에 동적인 프로퍼티 추가하기
image: ./../../images/springcloud/logo.jpeg
lastmod: 2025-03-12T23:34:00+09:00
comments: true
originalRefName: 스프링 클라우드 컨트랙트
originalRefLink: https://docs.spring.io/spring-cloud-contract/reference/4.2.0/project-features-contract/dsl-dynamic-properties.html
parent: Spring Cloud Contract Features
parentUrl: /Spring%20Cloud%20Contract/features/
subparent: 3.3. Dynamic properties
subparentNavTitle: Dynamic properties
isSubparent: true
subparentUrl: /Spring%20Cloud%20Contract/dynamic-properties/
---
<script>defaultLanguages = ['groovy']</script>

---

명세<sup>contract</sup>는 타임스탬프, ID 같은 동적인 프로퍼티를 가질 수 있다. 타임스탬프 값을 스텁<sup>stub</sup>에 매칭시키겠다는 이유로 매번 컨슈머<sup>consumer</sup>가 시간을 목<sup>mock</sup> 처리해 같은 값을 반환하도록 요구하긴 어렵다.

Groovy DSL의 경우, 명세<sup>contract</sup>에 두 가지 방법으로 동적인 값을 정의할 수 있다. body에 직접 전달하거나, `bodyMatchers`라는 별도 섹션에 설정하면 된다.

> 2.0.0 버전 이전에는 `testMatchers`와 `stubMatchers`를 사용해 설정했었다. 자세한 내용은 [마이그레이션 가이드](https://github.com/spring-cloud/spring-cloud-contract/wiki/Spring-Cloud-Contract-2.0-Migration-Guide)를 참고해라.

YAML에서는 `matchers`만 사용할 수 있다.

> `matchers`로 검증하려는 항목은 반드시 페이로드에 존재하는 요소여야 한다. 자세한 내용은 [이 이슈](https://github.com/spring-cloud/spring-cloud-contract/issues/722)를 참고해라.

### 목차

- [3.3.1. Body 안에 동적인 프로퍼티 정의하기](#331-dynamic-properties-inside-the-body)
- [3.3.2. 정규 표현식](#332-regular-expressions)
  + [제약](#limitations)
- [3.3.3. 생략 가능한 파라미터 전달하기](#333-passing-optional-parameters)
- [3.3.4. 서버에서 커스텀 메소드 호출하기](#334-calling-custom-methods-on-the-server-side)
- [3.3.5. 응답에서 요청 참조하기](#335-referencing-the-request-from-the-response)
- [3.3.6. Matchers 섹션에 동적인 프로퍼티 정의하기](#336-dynamic-properties-in-the-matchers-sections)
  + [프로그래밍 언어 DSL](#coded-dsl)
  + [YAML](#yaml)

### 3.3.1. Dynamic Properties inside the Body

> 이 섹션에서 설명하는 내용은 프로그래밍 언어로 작성한 DSL(Groovy, Java 등)에만 해당하는 내용이다. YAML에서 유사한 기능이 필요하다면 [Matchers 섹션 내에서 동적 프로퍼티 사용하기](#336-dynamic-properties-in-the-matchers-sections)를 참고해라.

body 내부에 있는 프로퍼티는 `value` 메소드를 사용하거나, Groovy의 map 표기법을 사용하는 경우 `$()`를 통해 설정할 수 있다. 다음은 각각을 사용해 동적인 프로퍼티를 설정하는 예시다:

*value 메소드*

```groovy
value(consumer(...), producer(...))
value(c(...), p(...))
value(stub(...), test(...))
value(client(...), server(...))
```

*$()*

```groovy
$(consumer(...), producer(...))
$(c(...), p(...))
$(stub(...), test(...))
$(client(...), server(...))
```

두 방법 모두 똑같이 잘 동작한다. `stub`, `client` 메소드는 `consumer` 메소드 별칭<sup>alias</sup>으로, 사실상 동일하다. 이것들로 뭘 할 수 있는지는 아래에서 더 자세히 설명한다.

### 3.3.2. Regular Expressions

> 이 섹션에서 설명하는 내용은 Groovy DSL에만 해당하는 내용이다. YAML에서 유사한 기능이 필요하다면 [Matchers 섹션 내에서 동적 프로퍼티 사용하기](#336-dynamic-properties-in-the-matchers-sections)를 참고해라.

Contract DSL에 요청을 정의할 땐 정규식을 사용할 수 있다. 정규식은 특정한 패턴에 해당하는 요청이 들어왔을 때, 정해진 응답을 제공해야 하는 경우 특히 유용하다. 또는 클라이언트와 서버 측 테스트 모두 정확한 값이 아닌 패턴을 사용해야 할 때에도 정규식을 활용할 수 있다.

정규식을 사용하면 내부에선 [`Pattern.matches()`](https://docs.oracle.com/javase/8/docs/api/java/util/regex/Matcher.html#matches)를 호출하기 때문에, 전체 시퀀스와 매칭되는 정규식을 작성해야 한다. 예를 들어서, `abc`는 `.abc`와는 매칭되지만 `aabc`와는 매칭되지 않는다. 그 외에 [몇 가지 제약](#limitations)도 알려져 있으니 함께 참고해라.

다음은 정규식을 사용해 요청을 정의하는 예시다:

<div class="switch-language-wrapper groovy java kotlin">
<span class="switch-language groovy">Groovy</span>
<span class="switch-language java">Java</span>
<span class="switch-language kotlin">Kotlin</span>
</div>
<div class="language-only-for-groovy groovy java kotlin"></div>
```groovy
org.springframework.cloud.contract.spec.Contract.make {
	request {
		method('GET')
		url $(consumer(~/\/[0-9]{2}/), producer('/12'))
	}
	response {
		status OK()
		body(
				id: $(anyNumber()),
				surname: $(
						consumer('Kowalsky'),
						producer(regex('[a-zA-Z]+'))
				),
				name: 'Jan',
				created: $(consumer('2014-02-02 12:23:43'), producer(execute('currentDate(it)'))),
				correlationId: value(consumer('5d1f9fef-e0dc-4f3d-a7e4-72d2220dd827'),
						producer(regex('[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}'))
				)
		)
		headers {
			header 'Content-Type': 'text/plain'
		}
	}
}
```
<div class="language-only-for-java groovy java kotlin"></div>
```java
org.springframework.cloud.contract.spec.Contract.make(c -> {
	c.request(r -> {
		r.method("GET");
		r.url(r.$(r.consumer(r.regex("\\/[0-9]{2}")), r.producer("/12")));
	});
	c.response(r -> {
		r.status(r.OK());
		r.body(ContractVerifierUtil.map()
			.entry("id", r.$(r.anyNumber()))
			.entry("surname", r.$(r.consumer("Kowalsky"), r.producer(r.regex("[a-zA-Z]+")))));
		r.headers(h -> {
			h.header("Content-Type", "text/plain");
		});
	});
});
```
<div class="language-only-for-kotlin groovy java kotlin"></div>
```kotlin
contract {
    request {
        method = method("GET")
        url = url(v(consumer(regex("\\/[0-9]{2}")), producer("/12")))
    }
    response {
        status = OK
        body(mapOf(
                "id" to v(anyNumber),
                "surname" to v(consumer("Kowalsky"), producer(regex("[a-zA-Z]+")))
        ))
        headers {
            header("Content-Type", "text/plain")
        }
    }
}
```

컨슈머<sup>consumer</sup>나 프로듀서<sup>producer</sup> 중 한 쪽에만 정규식을 정의하고, 나머지 한 쪽은 비워둘 수도 있다. 이땐 contract 엔진이 정규식과 매칭되는 문자열을 자동으로 생성해준다. 다음 코드는 Groovy를 사용한 예시다:

```groovy
org.springframework.cloud.contract.spec.Contract.make {
	request {
		method 'PUT'
		url value(consumer(regex('/foo/[0-9]{5}')))
		body([
				requestElement: $(consumer(regex('[0-9]{5}')))
		])
		headers {
			header('header', $(consumer(regex('application\\/vnd\\.fraud\\.v1\\+json;.*'))))
		}
	}
	response {
		status OK()
		body([
				responseElement: $(producer(regex('[0-9]{7}')))
		])
		headers {
			contentType("application/vnd.fraud.v1+json")
		}
	}
}
```

위 예시에서 값을 정의하지 않고 비워둔 쪽은, 요청과 응답에 맞는 데이터를 생성하도록 되어 있다.

Spring Cloud Contract는 명세<sup>contract</sup>에서 바로 사용할 수 있도록 다음과 같은 몇 가지 정규 표현식을 미리 정의해뒀다:

```java
public static RegexProperty onlyAlphaUnicode() {
	return new RegexProperty(ONLY_ALPHA_UNICODE).asString();
}

public static RegexProperty alphaNumeric() {
	return new RegexProperty(ALPHA_NUMERIC).asString();
}

public static RegexProperty number() {
	return new RegexProperty(NUMBER).asDouble();
}

public static RegexProperty positiveInt() {
	return new RegexProperty(POSITIVE_INT).asInteger();
}

public static RegexProperty anyBoolean() {
	return new RegexProperty(TRUE_OR_FALSE).asBooleanType();
}

public static RegexProperty anInteger() {
	return new RegexProperty(INTEGER).asInteger();
}

public static RegexProperty aDouble() {
	return new RegexProperty(DOUBLE).asDouble();
}

public static RegexProperty ipAddress() {
	return new RegexProperty(IP_ADDRESS).asString();
}

public static RegexProperty hostname() {
	return new RegexProperty(HOSTNAME_PATTERN).asString();
}

public static RegexProperty email() {
	return new RegexProperty(EMAIL).asString();
}

public static RegexProperty url() {
	return new RegexProperty(URL).asString();
}

public static RegexProperty httpsUrl() {
	return new RegexProperty(HTTPS_URL).asString();
}

public static RegexProperty uuid() {
	return new RegexProperty(UUID).asString();
}

public static RegexProperty uuid4() {
	return new RegexProperty(UUID4).asString();
}

public static RegexProperty isoDate() {
	return new RegexProperty(ANY_DATE).asString();
}

public static RegexProperty isoDateTime() {
	return new RegexProperty(ANY_DATE_TIME).asString();
}

public static RegexProperty isoTime() {
	return new RegexProperty(ANY_TIME).asString();
}

public static RegexProperty iso8601WithOffset() {
	return new RegexProperty(ISO8601_WITH_OFFSET).asString();
}

public static RegexProperty nonEmpty() {
	return new RegexProperty(NON_EMPTY).asString();
}

public static RegexProperty nonBlank() {
	return new RegexProperty(NON_BLANK).asString();
}
```

명세<sup>contract</sup>를 작성할 땐, 다음과 같이 사용하면 된다 (아래 코드는 Groovy DSL을 사용한 예시다):

```groovy
Contract dslWithOptionalsInString = Contract.make {
	priority 1
	request {
		method POST()
		url '/users/password'
		headers {
			contentType(applicationJson())
		}
		body(
				email: $(consumer(optional(regex(email()))), producer('abc@abc.com')),
				callback_url: $(consumer(regex(hostname())), producer('http://partners.com'))
		)
	}
	response {
		status 404
		headers {
			contentType(applicationJson())
		}
		body(
				code: value(consumer("123123"), producer(optional("123123"))),
				message: "User not found by email = [${value(producer(regex(email())), consumer('not.existing@user.com'))}]"
		)
	}
```

한 발 더 나아가 아래 있는 메소드들을 사용하면, 미리 정의된 정규식과 객체 셋을 활용할 수 있다. 이런 메소드들은 모두 다음과 같이 `any`로 시작한다:

```java
T anyAlphaUnicode();

T anyAlphaNumeric();

T anyNumber();

T anyInteger();

T anyPositiveInt();

T anyDouble();

T anyHex();

T aBoolean();

T anyIpAddress();

T anyHostname();

T anyEmail();

T anyUrl();

T anyHttpsUrl();

T anyUuid();

T anyDate();

T anyDateTime();

T anyTime();

T anyIso8601WithOffset();

T anyNonBlankString();

T anyNonEmptyString();

T anyOf(String... values);
```

이 메소드들을 사용하는 방법은 아래 예제를 참고해라:

<div class="switch-language-wrapper groovy kotlin">
<span class="switch-language groovy">Groovy</span>
<span class="switch-language kotlin">Kotlin</span>
</div>
<div class="language-only-for-groovy groovy kotlin"></div>
```groovy
Contract contractDsl = Contract.make {
	name "foo"
	label 'trigger_event'
	input {
		triggeredBy('toString()')
	}
	outputMessage {
		sentTo 'topic.rateablequote'
		body([
				alpha            : $(anyAlphaUnicode()),
				number           : $(anyNumber()),
				anInteger        : $(anyInteger()),
				positiveInt      : $(anyPositiveInt()),
				aDouble          : $(anyDouble()),
				aBoolean         : $(aBoolean()),
				ip               : $(anyIpAddress()),
				hostname         : $(anyHostname()),
				email            : $(anyEmail()),
				url              : $(anyUrl()),
				httpsUrl         : $(anyHttpsUrl()),
				uuid             : $(anyUuid()),
				date             : $(anyDate()),
				dateTime         : $(anyDateTime()),
				time             : $(anyTime()),
				iso8601WithOffset: $(anyIso8601WithOffset()),
				nonBlankString   : $(anyNonBlankString()),
				nonEmptyString   : $(anyNonEmptyString()),
				anyOf            : $(anyOf('foo', 'bar'))
		])
	}
}
```
<div class="language-only-for-kotlin groovy kotlin"></div>
```kotlin
contract {
    name = "foo"
    label = "trigger_event"
    input {
        triggeredBy = "toString()"
    }
    outputMessage {
        sentTo = sentTo("topic.rateablequote")
        body(mapOf(
                "alpha" to v(anyAlphaUnicode),
                "number" to v(anyNumber),
                "anInteger" to v(anyInteger),
                "positiveInt" to v(anyPositiveInt),
                "aDouble" to v(anyDouble),
                "aBoolean" to v(aBoolean),
                "ip" to v(anyIpAddress),
                "hostname" to v(anyAlphaUnicode),
                "email" to v(anyEmail),
                "url" to v(anyUrl),
                "httpsUrl" to v(anyHttpsUrl),
                "uuid" to v(anyUuid),
                "date" to v(anyDate),
                "dateTime" to v(anyDateTime),
                "time" to v(anyTime),
                "iso8601WithOffset" to v(anyIso8601WithOffset),
                "nonBlankString" to v(anyNonBlankString),
                "nonEmptyString" to v(anyNonEmptyString),
                "anyOf" to v(anyOf('foo', 'bar'))
        ))
        headers {
            header("Content-Type", "text/plain")
        }
    }
}
```

#### Limitations

> 문자열 자동 생성을 이용하고 있다면, 정규식에서 문자열을 생성할 때 사용하는 `Xeger` 라이브러리의 제약으로 인해 정규식 안에 `$`, `^` 기호를 사용할 수 없다. [899번 이슈](https://github.com/spring-cloud/spring-cloud-contract/issues/899)를 참고해라.

> `$` 값에는 `LocalDate` 인스턴스를 사용하면 안 된다 (e.g. `$(consumer(LocalDate.now()))`). 안 그러면 `java.lang.StackOverflowError`가 발생한다. 이대신 `$(consumer(LocalDate.now().toString()))`을 사용해라. 자세한 내용은 [900번 이슈](https://github.com/spring-cloud/spring-cloud-contract/issues/900)를 참고해라.

### 3.3.3. Passing Optional Parameters

> 이 섹션에서 설명하는 내용은 Groovy DSL에만 해당하는 내용이다. YAML에서 유사한 기능이 필요하다면 [Matchers 섹션 내에서 동적 프로퍼티 사용하기](#336-dynamic-properties-in-the-matchers-sections)를 참고해라.

명세<sup>contract</sup>에는 생략 가능한 파라미터도 지정할 수 있다. 단, 아래 케이스에서만 가능하다:

- 요청의 STUB 부분
- 응답의 TEST 부분

생략 가능한 파라미터를 제공하는 방법은 아래 예제를 참고해라:

<div class="switch-language-wrapper groovy java kotlin">
<span class="switch-language groovy">Groovy</span>
<span class="switch-language java">Java</span>
<span class="switch-language kotlin">Kotlin</span>
</div>
<div class="language-only-for-groovy groovy java kotlin"></div>
```groovy
org.springframework.cloud.contract.spec.Contract.make {
	priority 1
	name "optionals"
	request {
		method 'POST'
		url '/users/password'
		headers {
			contentType(applicationJson())
		}
		body(
				email: $(consumer(optional(regex(email()))), producer('abc@abc.com')),
				callback_url: $(consumer(regex(hostname())), producer('https://partners.com'))
		)
	}
	response {
		status 404
		headers {
			header 'Content-Type': 'application/json'
		}
		body(
				code: value(consumer("123123"), producer(optional("123123")))
		)
	}
}
```
<div class="language-only-for-java groovy java kotlin"></div>
```java
org.springframework.cloud.contract.spec.Contract.make(c -> {
	c.priority(1);
	c.name("optionals");
	c.request(r -> {
		r.method("POST");
		r.url("/users/password");
		r.headers(h -> {
			h.contentType(h.applicationJson());
		});
		r.body(ContractVerifierUtil.map()
			.entry("email", r.$(r.consumer(r.optional(r.regex(r.email()))), r.producer("abc@abc.com")))
			.entry("callback_url",
					r.$(r.consumer(r.regex(r.hostname())), r.producer("https://partners.com"))));
	});
	c.response(r -> {
		r.status(404);
		r.headers(h -> {
			h.header("Content-Type", "application/json");
		});
		r.body(ContractVerifierUtil.map()
			.entry("code", r.value(r.consumer("123123"), r.producer(r.optional("123123")))));
	});
});
```
<div class="language-only-for-kotlin groovy java kotlin"></div>
```kotlin
contract { c ->
    priority = 1
    name = "optionals"
    request {
        method = POST
        url = url("/users/password")
        headers {
            contentType = APPLICATION_JSON
        }
        body = body(mapOf(
                "email" to v(consumer(optional(regex(email))), producer("abc@abc.com")),
                "callback_url" to v(consumer(regex(hostname)), producer("https://partners.com"))
        ))
    }
    response {
        status = NOT_FOUND
        headers {
            header("Content-Type", "application/json")
        }
        body(mapOf(
                "code" to value(consumer("123123"), producer(optional("123123")))
        ))
    }
}
```

body 일부를 `optional()` 메소드로 감쌌다면, 데이터가 없을 수도 있지만, 만약 데이터가 존재한다면 그 안에 있는 정규 표현식을 따라야 한다.

Spock을 사용한다면, 위 명세<sup>contract</sup>로 다음과 같은 테스트가 만들어진다:

```groovy
import com.jayway.jsonpath.DocumentContext
import com.jayway.jsonpath.JsonPath
import spock.lang.Specification
import io.restassured.module.mockmvc.specification.MockMvcRequestSpecification
import io.restassured.response.ResponseOptions

import static org.springframework.cloud.contract.verifier.assertion.SpringCloudContractAssertions.assertThat
import static org.springframework.cloud.contract.verifier.util.ContractVerifierUtil.*
import static com.toomuchcoding.jsonassert.JsonAssertion.assertThatJson
import static io.restassured.module.mockmvc.RestAssuredMockMvc.*

class FooSpec extends Specification {

	def validate_optionals() throws Exception {
    given:
			MockMvcRequestSpecification request = given()
					.header("Content-Type", "application/json")
					.body('''{"email":"abc@abc.com","callback_url":"https://partners.com"}''')

    when:
			ResponseOptions response = given().spec(request)
					.post("/users/password")

		then:
			response.statusCode() == 404
			response.header("Content-Type") == 'application/json'

		and:
			DocumentContext parsedJson = JsonPath.parse(response.body.asString())
			assertThatJson(parsedJson).field("['code']").matches("(123123)?")
	}

}
```

그리고 아래와 같은 스텁<sup>stub</sup>도 함께 생성된다:

```groovy
					'''
{
  "request" : {
	"url" : "/users/password",
	"method" : "POST",
	"bodyPatterns" : [ {
	  "matchesJsonPath" : "$[?(@.['email'] =~ /([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\\\.[a-zA-Z]{2,6})?/)]"
	}, {
	  "matchesJsonPath" : "$[?(@.['callback_url'] =~ /((http[s]?|ftp):\\\\/)\\\\/?([^:\\\\/\\\\s]+)(:[0-9]{1,5})?/)]"
	} ],
	"headers" : {
	  "Content-Type" : {
		"equalTo" : "application/json"
	  }
	}
  },
  "response" : {
	"status" : 404,
	"body" : "{\\"code\\":\\"123123\\",\\"message\\":\\"User not found by email == [not.existing@user.com]\\"}",
	"headers" : {
	  "Content-Type" : "application/json"
	}
  },
  "priority" : 1
}
'''
```

### 3.3.4. Calling Custom Methods on the Server Side

> 이 섹션에서 설명하는 내용은 Groovy DSL에만 해당하는 내용이다. YAML에서 유사한 기능이 필요하다면 [Matchers 섹션 내에서 동적 프로퍼티 사용하기](#336-dynamic-properties-in-the-matchers-sections)를 참고해라.

테스트 중에 서버 측에서 호출할 메소드를 정의하는 것도 가능하다. 호출할 메소드는 `baseClassForTests`로 설정한 클래스에 추가해주면 된다. 다음은 예시로 사용할 명세<sup>contract</sup>의 일부다:

<div class="switch-language-wrapper groovy java kotlin">
<span class="switch-language groovy">Groovy</span>
<span class="switch-language java">Java</span>
<span class="switch-language kotlin">Kotlin</span>
</div>
<div class="language-only-for-groovy groovy java kotlin"></div>
```groovy
method GET()
```
<div class="language-only-for-java groovy java kotlin"></div>
```java
r.method(r.GET());
```
<div class="language-only-for-kotlin groovy java kotlin"></div>
```kotlin
method = GET
```

다음은 테스트에 사용하는 베이스 클래스의 일부 코드다:

```groovy
abstract class BaseMockMvcSpec extends Specification {

	def setup() {
		RestAssuredMockMvc.standaloneSetup(new PairIdController())
	}

	void isProperCorrelationId(Integer correlationId) {
		assert correlationId == 123456
	}

	void isEmpty(String value) {
		assert value == null
	}

}
```

> `String`과 `execute`를 둘 다 사용해서 연결하는 것은 불가능하다. 예를 들어, `header('Authorization', 'Bearer ' + execute('authToken()'))`과 같이 작성하면 의도대로 동작하지 않는다. 이대신 `authToken()` 메소드가 필요한 전체 문자열을 반환하도록 정의하고, `header('Authorization', execute('authToken()'))`을 호출해야 한다.

JSON에서 읽어온 객체는 JSON 경로에 따라 다음 중 하나의 타입이 될 수 있다:

- `String`: JSON의 `String` 값을 가리키는 경우.
- `JSONArray`: JSON의 `List`를 가리키는 경우 .
- `Map`: JSON의 `Map`을 가리키는 경우.
- `Number`: JSON의 `Integer`, `Double`, 그 외 다른 숫자 타입을 가리키는 경우.
- `Boolean`: JSON의 `Boolean`을 가리키는 경우.

명세<sup>contract</sup>에 요청을 정의할 때, 특정 메소드에서 `body`를 가져오도록 명시할 수 있다.

> 이때, 컨슈머<sup>consumer</sup>와 프로듀서<sup>producer</sup> 값을 모두 지정해야 한다. `execute` 실행 결과는 body의 일부로 사용하지 않으며,  body 전체에 적용된다.

다음은 JSON에서 객체를 읽어오는 예시다:

```groovy
Contract contractDsl = Contract.make {
	request {
		method 'GET'
		url '/something'
		body(
				$(c('foo'), p(execute('hashCode()')))
		)
	}
	response {
		status OK()
	}
}
```

위처럼 명세<sup>contract</sup>를 작성하면, `hashCode()` 메소드를 호출한 결과를 요청 body로 사용한다. 그러면 다음과 유사한 코드가 만들어진다:

```java
// given:
 MockMvcRequestSpecification request = given()
   .body(hashCode());

// when:
 ResponseOptions response = given().spec(request)
   .get("/something");

// then:
 assertThat(response.statusCode()).isEqualTo(200);
```

### 3.3.5. Referencing the Request from the Response

테스트에 필요한 값들은 고정 값을 사용하는 것이 가장 좋지만, 간혹 응답에서 요청을 참조해야 하는 경우가 있다.

Groovy DSL로 명세<sup>contract</sup>를 작성하는 경우, `fromRequest()` 메소드를 사용하면 다양한 HTTP 요청 정보를 참조할 수 있다. 사용할 수 있는 옵션은 다음과 같다:

- `fromRequest().url()`: 요청 URL과 쿼리 파라미터를 반환한다.
- `fromRequest().query(String key)`: 넘겨준 이름에 해당하는 첫 번째 쿼리 파라미터를 반환한다.
- `fromRequest().query(String key, int index)`: 넘겨준 이름에 해당하는 n 번째 쿼리 파라미터를 반환한다.
- `fromRequest().path()`: 전체 path를 반환한다.
- `fromRequest().path(int index)`: n 번째 path를 반환한다.
- `fromRequest().header(String key)`: 넘겨준 이름에 해당하는 첫 번째 헤더를 반환한다.
- `fromRequest().header(String key, int index)`: 넘겨준 이름에 해당하는 n 번째 헤더를 반환한다.
- `fromRequest().body()`: 전체 요청 body를 반환한다.
- `fromRequest().body(String jsonPath)`: 요청 body에서 주어진 JSON Path 표현식에 해당하는 값을 반환한다.

YAML이나 자바로 명세<sup>contract</sup>를 작성하는 경우, [Handlebars](https://handlebarsjs.com/) {% raw %}`{{{ }}}`{% endraw %} 표기와 Spring Cloud Contract의 커스텀 함수를 사용해야 한다. 이 경우 사용할 수 있는 옵션은 다음과 같다:

- {% raw %}`{{{ request.url }}}`{% endraw %}: 요청 URL과 쿼리 파라미터를 반환한다.
- {% raw %}`{{{ request.query.key.[index] }}}`{% endraw %}: 넘겨준 이름에 해당하는 n 번째 쿼리 파라미터를 반환한다. 예를 들어 키가 `thing`이라면, 첫 번째 쿼리 파라미터는 {% raw %}`{{{ request.query.thing.[0] }}}{% endraw %}`으로 표현한다.
- {% raw %}`{{{ request.path }}}`{% endraw %}: 전체 path를 반환한다.
- {% raw %}`{{{ request.path.[index] }}}`{% endraw %}: n 번째 path를 반환한다. 예를 들어, 첫 번째 path는 {% raw %}`{{{ request.path.[0] }}}`{% endraw %}으로 표현한다.
- {% raw %}`{{{ request.headers.key }}}`{% endraw %}: 넘겨준 이름에 해당하는 첫 번째 헤더를 반환한다.
- {% raw %}`{{{ request.headers.key.[index] }}}`{% endraw %}: 넘겨준 이름에 해당하는 n 번째 헤더를 반환한다.
- {% raw %}`{{{ request.body }}}`{% endraw %}: 전체 요청 body를 반환한다.
- {% raw %}`{{{ jsonpath this 'your.json.path' }}}`{% endraw %}: 요청 body에서 주어진 JSON Path 표현식에 해당하는 값을 반환한다. 예를 들어 JSON 경로가 `$.here`라면, {% raw %}`{{{ jsonpath this '$.here' }}}`{% endraw %}를 사용한다.

예시가 필요하다면 아래 명세<sup>contract</sup>를 참고해라:

<div class="switch-language-wrapper groovy yaml java kotlin">
<span class="switch-language groovy">Groovy</span>
<span class="switch-language yaml">YAML</span>
<span class="switch-language java">Java</span>
<span class="switch-language kotlin">Kotlin</span>
</div>
<div class="language-only-for-groovy groovy yaml java kotlin"></div>
```groovy
{% raw %}Contract contractDsl = Contract.make {
	request {
		method 'GET'
		url('/api/v1/xxxx') {
			queryParameters {
				parameter('foo', 'bar')
				parameter('foo', 'bar2')
			}
		}
		headers {
			header(authorization(), 'secret')
			header(authorization(), 'secret2')
		}
		body(foo: 'bar', baz: 5)
	}
	response {
		status OK()
		headers {
			header(authorization(), "foo ${fromRequest().header(authorization())} bar")
		}
		body(
				url: fromRequest().url(),
				path: fromRequest().path(),
				pathIndex: fromRequest().path(1),
				param: fromRequest().query('foo'),
				paramIndex: fromRequest().query('foo', 1),
				authorization: fromRequest().header('Authorization'),
				authorization2: fromRequest().header('Authorization', 1),
				fullBody: fromRequest().body(),
				responseFoo: fromRequest().body('$.foo'),
				responseBaz: fromRequest().body('$.baz'),
				responseBaz2: "Bla bla ${fromRequest().body('$.foo')} bla bla",
				rawUrl: fromRequest().rawUrl(),
				rawPath: fromRequest().rawPath(),
				rawPathIndex: fromRequest().rawPath(1),
				rawParam: fromRequest().rawQuery('foo'),
				rawParamIndex: fromRequest().rawQuery('foo', 1),
				rawAuthorization: fromRequest().rawHeader('Authorization'),
				rawAuthorization2: fromRequest().rawHeader('Authorization', 1),
				rawResponseFoo: fromRequest().rawBody('$.foo'),
				rawResponseBaz: fromRequest().rawBody('$.baz'),
				rawResponseBaz2: "Bla bla ${fromRequest().rawBody('$.foo')} bla bla"
		)
	}
}
Contract contractDsl = Contract.make {
	request {
		method 'GET'
		url('/api/v1/xxxx') {
			queryParameters {
				parameter('foo', 'bar')
				parameter('foo', 'bar2')
			}
		}
		headers {
			header(authorization(), 'secret')
			header(authorization(), 'secret2')
		}
		body(foo: "bar", baz: 5)
	}
	response {
		status OK()
		headers {
			contentType(applicationJson())
		}
		body(''' 
				{
					"responseFoo": "{{{ jsonPath request.body '$.foo' }}}",
					"responseBaz": {{{ jsonPath request.body '$.baz' }}},
					"responseBaz2": "Bla bla {{{ jsonPath request.body '$.foo' }}} bla bla"
				}
		'''.toString())
	}
}{% endraw %}
```
<div class="language-only-for-yaml groovy yaml java kotlin"></div>
```yaml
{% raw %}request:
  method: GET
  url: /api/v1/xxxx
  queryParameters:
    foo:
      - bar
      - bar2
  headers:
    Authorization:
      - secret
      - secret2
  body:
    foo: bar
    baz: 5
response:
  status: 200
  headers:
    Authorization: "foo {{{ request.headers.Authorization.0 }}} bar"
  body:
    url: "{{{ request.url }}}"
    path: "{{{ request.path }}}"
    pathIndex: "{{{ request.path.1 }}}"
    param: "{{{ request.query.foo }}}"
    paramIndex: "{{{ request.query.foo.1 }}}"
    authorization: "{{{ request.headers.Authorization.0 }}}"
    authorization2: "{{{ request.headers.Authorization.1 }}"
    fullBody: "{{{ request.body }}}"
    responseFoo: "{{{ jsonpath this '$.foo' }}}"
    responseBaz: "{{{ jsonpath this '$.baz' }}}"
    responseBaz2: "Bla bla {{{ jsonpath this '$.foo' }}} bla bla"{% endraw %}
```
<div class="language-only-for-java groovy yaml java kotlin"></div>
```java
{% raw %}import java.util.function.Supplier;

import org.springframework.cloud.contract.spec.Contract;

import static org.springframework.cloud.contract.verifier.util.ContractVerifierUtil.map;

class shouldReturnStatsForAUser implements Supplier<Contract> {

	@Override
	public Contract get() {
		return Contract.make(c -> {
			c.request(r -> {
				r.method("POST");
				r.url("/stats");
				r.body(map().entry("name", r.anyAlphaUnicode()));
				r.headers(h -> {
					h.contentType(h.applicationJson());
				});
			});
			c.response(r -> {
				r.status(r.OK());
				r.body(map()
						.entry("text",
								"Dear {{{jsonPath request.body '$.name'}}} thanks for your interested in drinking beer")
						.entry("quantity", r.$(r.c(5), r.p(r.anyNumber()))));
				r.headers(h -> {
					h.contentType(h.applicationJson());
				});
			});
		});
	}

}{% endraw %}
```
<div class="language-only-for-kotlin groovy yaml java kotlin"></div>
```kotlin
import org.springframework.cloud.contract.spec.ContractDsl.Companion.contract

contract {
    request {
        method = method("POST")
        url = url("/stats")
        body(mapOf(
            "name" to anyAlphaUnicode
        ))
        headers {
            contentType = APPLICATION_JSON
        }
    }
    response {
        status = OK
        body(mapOf(
            "text" to "Don't worry $\{fromRequest().body("$.name")} thanks for your interested in drinking beer",
            "quantity" to v(c(5), p(anyNumber))
        ))
        headers {
            contentType = fromRequest().header(CONTENT_TYPE)
        }
    }
}
```

JUnit 테스트를 생성하면, 다음과 유사한 테스트 코드가 만들어진다:

```java
// given:
 MockMvcRequestSpecification request = given()
   .header("Authorization", "secret")
   .header("Authorization", "secret2")
   .body("{\"foo\":\"bar\",\"baz\":5}");

// when:
 ResponseOptions response = given().spec(request)
   .queryParam("foo","bar")
   .queryParam("foo","bar2")
   .get("/api/v1/xxxx");

// then:
 assertThat(response.statusCode()).isEqualTo(200);
 assertThat(response.header("Authorization")).isEqualTo("foo secret bar");
// and:
 DocumentContext parsedJson = JsonPath.parse(response.getBody().asString());
 assertThatJson(parsedJson).field("['fullBody']").isEqualTo("{\"foo\":\"bar\",\"baz\":5}");
 assertThatJson(parsedJson).field("['authorization']").isEqualTo("secret");
 assertThatJson(parsedJson).field("['authorization2']").isEqualTo("secret2");
 assertThatJson(parsedJson).field("['path']").isEqualTo("/api/v1/xxxx");
 assertThatJson(parsedJson).field("['param']").isEqualTo("bar");
 assertThatJson(parsedJson).field("['paramIndex']").isEqualTo("bar2");
 assertThatJson(parsedJson).field("['pathIndex']").isEqualTo("v1");
 assertThatJson(parsedJson).field("['responseBaz']").isEqualTo(5);
 assertThatJson(parsedJson).field("['responseFoo']").isEqualTo("bar");
 assertThatJson(parsedJson).field("['url']").isEqualTo("/api/v1/xxxx?foo=bar&foo=bar2");
 assertThatJson(parsedJson).field("['responseBaz2']").isEqualTo("Bla bla bar bla bla");
```

보다시피, 응답에서 요청 정보를 적절히 참조해서 사용하고 있다.

그리고 다음과 같은 WireMock 스텁<sup>stub</sup>이 만들어진다:

```json
{% raw %}{
  "request" : {
    "urlPath" : "/api/v1/xxxx",
    "method" : "POST",
    "headers" : {
      "Authorization" : {
        "equalTo" : "secret2"
      }
    },
    "queryParameters" : {
      "foo" : {
        "equalTo" : "bar2"
      }
    },
    "bodyPatterns" : [ {
      "matchesJsonPath" : "$[?(@.['baz'] == 5)]"
    }, {
      "matchesJsonPath" : "$[?(@.['foo'] == 'bar')]"
    } ]
  },
  "response" : {
    "status" : 200,
    "body" : "{\"authorization\":\"{{{request.headers.Authorization.[0]}}}\",\"path\":\"{{{request.path}}}\",\"responseBaz\":{{{jsonpath this '$.baz'}}} ,\"param\":\"{{{request.query.foo.[0]}}}\",\"pathIndex\":\"{{{request.path.[1]}}}\",\"responseBaz2\":\"Bla bla {{{jsonpath this '$.foo'}}} bla bla\",\"responseFoo\":\"{{{jsonpath this '$.foo'}}}\",\"authorization2\":\"{{{request.headers.Authorization.[1]}}}\",\"fullBody\":\"{{{escapejsonbody}}}\",\"url\":\"{{{request.url}}}\",\"paramIndex\":\"{{{request.query.foo.[1]}}}\"}",
    "headers" : {
      "Authorization" : "{{{request.headers.Authorization.[0]}}};foo"
    },
    "transformers" : [ "response-template" ]
  }
}{% endraw %}
```

명세<sup>contract</sup>의 `request` 부분에 정의한대로 요청을 전송하면, 다음과 같은 응답 body를 받을 수 있다:

```json
{
  "url" : "/api/v1/xxxx?foo=bar&foo=bar2",
  "path" : "/api/v1/xxxx",
  "pathIndex" : "v1",
  "param" : "bar",
  "paramIndex" : "bar2",
  "authorization" : "secret",
  "authorization2" : "secret2",
  "fullBody" : "{\"foo\":\"bar\",\"baz\":5}",
  "responseFoo" : "bar",
  "responseBaz" : 5,
  "responseBaz2" : "Bla bla bar bla bla"
}
```

> 이 기능은 WireMock 2.5.1 버전 이상에서만 동작한다. Spring Cloud Contract Verifier는 WireMock의 응답 트랜스포머, `response-template`을 사용한다. `response-template`은 Handlebars를 사용해 Mustache {% raw %}`{{{ }}}`{% endraw %} 템플릿을 적절한 값으로 변환한다. 또한 두 가지 헬퍼 함수를 등록한다:
>
> - `escapejsonbody`: 요청 body를 JSON에 포함시킬 수 있는 형식으로 이스케이프 처리한다.
> - `jsonpath`: 요청 body에서 주어진 파라미터에 해당하는 객체를 찾는다.

### 3.3.6. Dynamic Properties in the Matchers Sections

[Pact](https://docs.pact.io/)를 사용 중이라면, 아래 내용이 꽤나 익숙하게 느껴질 거다. Pact 사용자라면 body에서 동적인 부분을 따로 구분해서 명세<sup>contract</sup>를 작성해본 적이 많을 거다.

`bodyMatchers`는 두 가지 목적으로 사용할 수 있다:

- 스텁<sup>stub</sup>에 포함시킬 동적인 값을 정의한다. 이땐 명세<sup>contract</sup>의 `request` 부분에 `bodyMatchers`를 설정한다.
- 테스트 결과를 검증한다. 이땐 명세<sup>contract</sup>의 `response` 또는 `outputMessage`에 `bodyMatchers`를 설정한다.

현재 Spring Cloud Contract Verifier는 JSON 경로 기반 matcher만 지원한다. JSON 경로를 기반으로 다음과 같은 것들을 매칭킬 수 있다:

#### Coded DSL

스텁<sup>stub</sup> (컨슈머<sup>consumer</sup> 측 테스트):

- `byEquality()`: 컨슈머<sup>consumer</sup> 요청에서 지정한 JSON 경로의 값은 명세<sup>contract</sup>에 정의한 값과 같아야 한다.
- `byRegex(…)`: 컨슈머<sup>consumer</sup> 요청에서 지정한 JSON 경로의 값은 정규식과 일치해야 한다. 매칭시킬 값의 예상 타입도 전달할 수도 있다 (e.g. `asString()`, `asLong()` 등).
- `byDate()`: 컨슈머<sup>consumer</sup> 요청에서 지정한 JSON 경로의 값은 ISO Date 값에 대한 정규식과 일치해야 한다.
- `byTimestamp()`: 컨슈머<sup>consumer</sup> 요청의 지정한 JSON 경로의 값은 ISO DateTime 값에 대한 정규식과 일치해야 한다.
- `byTime()`: 컨슈머<sup>consumer</sup> 요청에서 지정한 JSON 경로 경로의 ISO Time 값에 대한 정규식과 일치해야 한다.

검증 (프로듀서<sup>producer</sup> 측 자동 생성 테스트):

- `byEquality()`: 프로듀서<sup>producer</sup> 응답에서 지정한 JSON 경로의 값은 명세<sup>contract</sup>에 정의한 값과 같아야 한다.
- `byRegex(…)`: 프로듀서<sup>producer</sup> 응답에서 지정한 JSON 경로의 값은 정규식과 일치해야 한다.
- `byDate()`: 프로듀서<sup>producer</sup> 응답에서 지정한 JSON 경로의 값은 ISO Date 값에 대한 정규식과 일치해야 한다.
- `byTimestamp()`: 프로듀서<sup>producer</sup> 응답에서 지정한 JSON 경로의 값은 ISO DateTime 값에 대한 정규식과 일치해야 한다.
- `byTime()`: 프로듀서<sup>producer</sup> 응답에서 지정한 JSON 경로의 값은 ISO Time 값에 대한 정규식과 일치해야 한다.
- `byType()`: 프로듀서<sup>producer</sup> 응답에서 지정한 JSON 경로의 값은, 명세<sup>contract</sup>의 응답 body에 정의한 타입과 동일한 타입이어야 한다. `byType`에는 클로저를 넘겨 `minOccurrence`와 `maxOccurrence`를 설정할 수 있다. 요청 측에서 컬렉션의 크기를 검증하려면 클로저를 사용해야 한다. 클로저를 사용하면 평평하게 펼친<sup>flattened</sup> 컬렉션의 사이즈를 검증할 수 있다. 펼쳐놓지 않은 중첩된<sup>unflattened</sup> 컬렉션의 크기를 검증해야 한다면 `byCommand(…)` `testMatcher`와 커스텀 메소드를 사용해라.
- `byCommand(…)`: 여기에 커스텀 메소드를 사용하면, 프로듀서<sup>producer</sup> 응답에서 지정한 JSON 경로에 있는 값을 입력으로 전달한다. 예를 들어 `byCommand('thing($it)')`은 JSON 경로에 매칭되는 값을 넘겨 `thing` 메소드를 호출한다. JSON에서 읽은 객체는 JSON 경로에 따라 다음 중 하나의 타입이 될 수 있다:
  - `String`: `String` 값을 가리킨 경우
  - `JSONArray`: `List`를 가리킨 경우.
  - `Map`: `Map`을 가리킨 경우.
  - `Number`: `Integer`, `Double`, 그 외 다른 숫자를 가리킨 경우.
  - `Boolean`: `Boolean`을 가리킨 경우.
- `byNull()`: 응답 내 지정 JSON 경로 값은 null이어야 한다.

#### YAML

> type에 대한 자세한 설명은 Groovy 섹션을 참고해라.

YAML의 경우, 다음과 같은 구조로 matcher를 정의할 수 있다:

```yml
- path: $.thing1
  type: by_regex
  value: thing2
  regexType: as_string
```

또는 다음과 같이 작성해주면, 미리 정의되어있는 정규 표현식 <span class="custom-blockquote">[only_alpha_unicode, number, any_boolean, ip_address, hostname, email, url, uuid, iso_date, iso_date_time, iso_time, iso_8601_with_offset, non_empty, non_blank]</span> 중 하나를 사용할 수 있다:

```yml
- path: $.thing1
  type: by_regex
  predefined: only_alpha_unicode
```

`type`에 사용할 수 있는 값은 다음과 같다:

- `stubMatchers`:
  - `by_equality`
  - `by_regex`
  - `by_date`
  - `by_timestamp`
  - `by_time`
  - `by_type`
    * 두 가지 필드를 추가로 넘길 수 있다 (`minOccurrenc`, `maxOccurrence`).
- `testMatchers`:
  - `by_equality`
  - `by_regex`
  - `by_date`
  - `by_timestamp`
  - `by_time`
  - `by_type`
    - 두 가지 필드를 추가로 넘길 수 있다 (`minOccurrenc`, `maxOccurrence`).
  - `by_command`
  - `by_null`

정규식이 어떤 타입에 해당하는지도 `regexType` 필드로 정의할 수 있다. 허용하는 정규식 타입은 다음과 같다:

- `as_integer`
- `as_double`
- `as_float`
- `as_long`
- `as_short`
- `as_boolean`
- `as_string`

아래 예시를 한 번 살펴보자:

<div class="switch-language-wrapper groovy yaml">
<span class="switch-language groovy">Groovy</span>
<span class="switch-language yaml">YAML</span>
</div>
<div class="language-only-for-groovy groovy yaml"></div>
```groovy
Contract contractDsl = Contract.make {
	request {
		method 'GET'
		urlPath '/get'
		body([
				duck                : 123,
				alpha               : 'abc',
				number              : 123,
				aBoolean            : true,
				date                : '2017-01-01',
				dateTime            : '2017-01-01T01:23:45',
				time                : '01:02:34',
				valueWithoutAMatcher: 'foo',
				valueWithTypeMatch  : 'string',
				key                 : [
						'complex.key': 'foo'
				]
		])
		bodyMatchers {
			jsonPath('$.duck', byRegex("[0-9]{3}").asInteger())
			jsonPath('$.duck', byEquality())
			jsonPath('$.alpha', byRegex(onlyAlphaUnicode()).asString())
			jsonPath('$.alpha', byEquality())
			jsonPath('$.number', byRegex(number()).asInteger())
			jsonPath('$.aBoolean', byRegex(anyBoolean()).asBooleanType())
			jsonPath('$.date', byDate())
			jsonPath('$.dateTime', byTimestamp())
			jsonPath('$.time', byTime())
			jsonPath("\$.['key'].['complex.key']", byEquality())
		}
		headers {
			contentType(applicationJson())
		}
	}
	response {
		status OK()
		body([
				duck                 : 123,
				alpha                : 'abc',
				number               : 123,
				positiveInteger      : 1234567890,
				negativeInteger      : -1234567890,
				positiveDecimalNumber: 123.4567890,
				negativeDecimalNumber: -123.4567890,
				aBoolean             : true,
				date                 : '2017-01-01',
				dateTime             : '2017-01-01T01:23:45',
				time                 : "01:02:34",
				valueWithoutAMatcher : 'foo',
				valueWithTypeMatch   : 'string',
				valueWithMin         : [
						1, 2, 3
				],
				valueWithMax         : [
						1, 2, 3
				],
				valueWithMinMax      : [
						1, 2, 3
				],
				valueWithMinEmpty    : [],
				valueWithMaxEmpty    : [],
				key                  : [
						'complex.key': 'foo'
				],
				nullValue            : null
		])
		bodyMatchers {
			// asserts the jsonpath value against manual regex
			jsonPath('$.duck', byRegex("[0-9]{3}").asInteger())
			// asserts the jsonpath value against the provided value
			jsonPath('$.duck', byEquality())
			// asserts the jsonpath value against some default regex
			jsonPath('$.alpha', byRegex(onlyAlphaUnicode()).asString())
			jsonPath('$.alpha', byEquality())
			jsonPath('$.number', byRegex(number()).asInteger())
			jsonPath('$.positiveInteger', byRegex(anInteger()).asInteger())
			jsonPath('$.negativeInteger', byRegex(anInteger()).asInteger())
			jsonPath('$.positiveDecimalNumber', byRegex(aDouble()).asDouble())
			jsonPath('$.negativeDecimalNumber', byRegex(aDouble()).asDouble())
			jsonPath('$.aBoolean', byRegex(anyBoolean()).asBooleanType())
			// asserts vs inbuilt time related regex
			jsonPath('$.date', byDate())
			jsonPath('$.dateTime', byTimestamp())
			jsonPath('$.time', byTime())
			// asserts that the resulting type is the same as in response body
			jsonPath('$.valueWithTypeMatch', byType())
			jsonPath('$.valueWithMin', byType {
				// results in verification of size of array (min 1)
				minOccurrence(1)
			})
			jsonPath('$.valueWithMax', byType {
				// results in verification of size of array (max 3)
				maxOccurrence(3)
			})
			jsonPath('$.valueWithMinMax', byType {
				// results in verification of size of array (min 1 & max 3)
				minOccurrence(1)
				maxOccurrence(3)
			})
			jsonPath('$.valueWithMinEmpty', byType {
				// results in verification of size of array (min 0)
				minOccurrence(0)
			})
			jsonPath('$.valueWithMaxEmpty', byType {
				// results in verification of size of array (max 0)
				maxOccurrence(0)
			})
			// will execute a method `assertThatValueIsANumber`
			jsonPath('$.duck', byCommand('assertThatValueIsANumber($it)'))
			jsonPath("\$.['key'].['complex.key']", byEquality())
			jsonPath('$.nullValue', byNull())
		}
		headers {
			contentType(applicationJson())
			header('Some-Header', $(c('someValue'), p(regex('[a-zA-Z]{9}'))))
		}
	}
}
```
<div class="language-only-for-yaml groovy yaml"></div>
```yaml
request:
  method: GET
  urlPath: /get/1
  headers:
    Content-Type: application/json
  cookies:
    foo: 2
    bar: 3
  queryParameters:
    limit: 10
    offset: 20
    filter: 'email'
    sort: name
    search: 55
    age: 99
    name: John.Doe
    email: 'bob@email.com'
  body:
    duck: 123
    alpha: "abc"
    number: 123
    aBoolean: true
    date: "2017-01-01"
    dateTime: "2017-01-01T01:23:45"
    time: "01:02:34"
    valueWithoutAMatcher: "foo"
    valueWithTypeMatch: "string"
    key:
      "complex.key": 'foo'
    nullValue: null
    valueWithMin:
      - 1
      - 2
      - 3
    valueWithMax:
      - 1
      - 2
      - 3
    valueWithMinMax:
      - 1
      - 2
      - 3
    valueWithMinEmpty: []
    valueWithMaxEmpty: []
  matchers:
    url:
      regex: /get/[0-9]
      # predefined:
      # execute a method
      #command: 'equals($it)'
    queryParameters:
      - key: limit
        type: equal_to
        value: 20
      - key: offset
        type: containing
        value: 20
      - key: sort
        type: equal_to
        value: name
      - key: search
        type: not_matching
        value: '^[0-9]{2}$'
      - key: age
        type: not_matching
        value: '^\\w*$'
      - key: name
        type: matching
        value: 'John.*'
      - key: hello
        type: absent
    cookies:
      - key: foo
        regex: '[0-9]'
      - key: bar
        command: 'equals($it)'
    headers:
      - key: Content-Type
        regex: "application/json.*"
    body:
      - path: $.duck
        type: by_regex
        value: "[0-9]{3}"
      - path: $.duck
        type: by_equality
      - path: $.alpha
        type: by_regex
        predefined: only_alpha_unicode
      - path: $.alpha
        type: by_equality
      - path: $.number
        type: by_regex
        predefined: number
      - path: $.aBoolean
        type: by_regex
        predefined: any_boolean
      - path: $.date
        type: by_date
      - path: $.dateTime
        type: by_timestamp
      - path: $.time
        type: by_time
      - path: "$.['key'].['complex.key']"
        type: by_equality
      - path: $.nullvalue
        type: by_null
      - path: $.valueWithMin
        type: by_type
        minOccurrence: 1
      - path: $.valueWithMax
        type: by_type
        maxOccurrence: 3
      - path: $.valueWithMinMax
        type: by_type
        minOccurrence: 1
        maxOccurrence: 3
response:
  status: 200
  cookies:
    foo: 1
    bar: 2
  body:
    duck: 123
    alpha: "abc"
    number: 123
    aBoolean: true
    date: "2017-01-01"
    dateTime: "2017-01-01T01:23:45"
    time: "01:02:34"
    valueWithoutAMatcher: "foo"
    valueWithTypeMatch: "string"
    valueWithMin:
      - 1
      - 2
      - 3
    valueWithMax:
      - 1
      - 2
      - 3
    valueWithMinMax:
      - 1
      - 2
      - 3
    valueWithMinEmpty: []
    valueWithMaxEmpty: []
    key:
      'complex.key': 'foo'
    nulValue: null
  matchers:
    headers:
      - key: Content-Type
        regex: "application/json.*"
    cookies:
      - key: foo
        regex: '[0-9]'
      - key: bar
        command: 'equals($it)'
    body:
      - path: $.duck
        type: by_regex
        value: "[0-9]{3}"
      - path: $.duck
        type: by_equality
      - path: $.alpha
        type: by_regex
        predefined: only_alpha_unicode
      - path: $.alpha
        type: by_equality
      - path: $.number
        type: by_regex
        predefined: number
      - path: $.aBoolean
        type: by_regex
        predefined: any_boolean
      - path: $.date
        type: by_date
      - path: $.dateTime
        type: by_timestamp
      - path: $.time
        type: by_time
      - path: $.valueWithTypeMatch
        type: by_type
      - path: $.valueWithMin
        type: by_type
        minOccurrence: 1
      - path: $.valueWithMax
        type: by_type
        maxOccurrence: 3
      - path: $.valueWithMinMax
        type: by_type
        minOccurrence: 1
        maxOccurrence: 3
      - path: $.valueWithMinEmpty
        type: by_type
        minOccurrence: 0
      - path: $.valueWithMaxEmpty
        type: by_type
        maxOccurrence: 0
      - path: $.duck
        type: by_command
        value: assertThatValueIsANumber($it)
      - path: $.nullValue
        type: by_null
        value: null
  headers:
    Content-Type: application/json
```

위 명세<sup>contract</sup>에선, `matchers` 부분을 보면 동적인 정의를 확인할 수 있다. 요청의 경우 `valueWithoutAMatcher`를 제외한 모든 필드에, 스텁<sup>stub</sup>에 포함시킬 정규 표현식 값을 명시했다. `valueWithoutAMatcher`의 경우, matchers를 사용하지 않았을 때와 동일하게 검증을 수행한다. 즉, 테스트 코드에선 equality 검사를 수행한다.

응답에 있는 `bodyMatchers` 부분에서도 비슷한 방식으로 동적인 필드를 정의하고 있다. 유일한 차이점은 `byType` matcher도 존재한다는 것이다. verifier 엔진은 네 가지 필드를 확인해서, 테스트 응답이 주어진 필드와 일치하는 값을 가지고 있는지, 응답 body에 정의한 타입과 것과 동일한 타입인지, 그리고 (호출하는 메소드에 따라) 다음 검사를 통과하는지 확인한다:

- `$.valueWithTypeMatch`에선 타입이 동일한지 검사한다.
- `$.valueWithMin`에선 타입을 검사하고, 크기가 minimum occurrence보다 크거나 같은지 확인한다.
- `$.valueWithMax`에선 타입을 검사하고, 크기가 maximum occurrence보다 작거나 같은지 확인한다.
- `$.valueWithMinMax`에선 타입을 검사하고, 크기가 minimum~maximum occurrence 사이인지 확인한다.

이에 따라 다음과 유사한 테스트가 만들어진다 (`and`라고 적어둔 주석으로, 기존처럼 자동 생성된 assertion 구문과 matchers로부터 만든 assertion 구문을 구분하고 있다):

```java
// given:
 MockMvcRequestSpecification request = given()
   .header("Content-Type", "application/json")
   .body("{\"duck\":123,\"alpha\":\"abc\",\"number\":123,\"aBoolean\":true,\"date\":\"2017-01-01\",\"dateTime\":\"2017-01-01T01:23:45\",\"time\":\"01:02:34\",\"valueWithoutAMatcher\":\"foo\",\"valueWithTypeMatch\":\"string\",\"key\":{\"complex.key\":\"foo\"}}");

// when:
 ResponseOptions response = given().spec(request)
   .get("/get");

// then:
 assertThat(response.statusCode()).isEqualTo(200);
 assertThat(response.header("Content-Type")).matches("application/json.*");
// and:
 DocumentContext parsedJson = JsonPath.parse(response.getBody().asString());
 assertThatJson(parsedJson).field("['valueWithoutAMatcher']").isEqualTo("foo");
// and:
 assertThat(parsedJson.read("$.duck", String.class)).matches("[0-9]{3}");
 assertThat(parsedJson.read("$.duck", Integer.class)).isEqualTo(123);
 assertThat(parsedJson.read("$.alpha", String.class)).matches("[\\p{L}]*");
 assertThat(parsedJson.read("$.alpha", String.class)).isEqualTo("abc");
 assertThat(parsedJson.read("$.number", String.class)).matches("-?(\\d*\\.\\d+|\\d+)");
 assertThat(parsedJson.read("$.aBoolean", String.class)).matches("(true|false)");
 assertThat(parsedJson.read("$.date", String.class)).matches("(\\d\\d\\d\\d)-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])");
 assertThat(parsedJson.read("$.dateTime", String.class)).matches("([0-9]{4})-(1[0-2]|0[1-9])-(3[01]|0[1-9]|[12][0-9])T(2[0-3]|[01][0-9]):([0-5][0-9]):([0-5][0-9])");
 assertThat(parsedJson.read("$.time", String.class)).matches("(2[0-3]|[01][0-9]):([0-5][0-9]):([0-5][0-9])");
 assertThat((Object) parsedJson.read("$.valueWithTypeMatch")).isInstanceOf(java.lang.String.class);
 assertThat((Object) parsedJson.read("$.valueWithMin")).isInstanceOf(java.util.List.class);
 assertThat((java.lang.Iterable) parsedJson.read("$.valueWithMin", java.util.Collection.class)).as("$.valueWithMin").hasSizeGreaterThanOrEqualTo(1);
 assertThat((Object) parsedJson.read("$.valueWithMax")).isInstanceOf(java.util.List.class);
 assertThat((java.lang.Iterable) parsedJson.read("$.valueWithMax", java.util.Collection.class)).as("$.valueWithMax").hasSizeLessThanOrEqualTo(3);
 assertThat((Object) parsedJson.read("$.valueWithMinMax")).isInstanceOf(java.util.List.class);
 assertThat((java.lang.Iterable) parsedJson.read("$.valueWithMinMax", java.util.Collection.class)).as("$.valueWithMinMax").hasSizeBetween(1, 3);
 assertThat((Object) parsedJson.read("$.valueWithMinEmpty")).isInstanceOf(java.util.List.class);
 assertThat((java.lang.Iterable) parsedJson.read("$.valueWithMinEmpty", java.util.Collection.class)).as("$.valueWithMinEmpty").hasSizeGreaterThanOrEqualTo(0);
 assertThat((Object) parsedJson.read("$.valueWithMaxEmpty")).isInstanceOf(java.util.List.class);
 assertThat((java.lang.Iterable) parsedJson.read("$.valueWithMaxEmpty", java.util.Collection.class)).as("$.valueWithMaxEmpty").hasSizeLessThanOrEqualTo(0);
 assertThatValueIsANumber(parsedJson.read("$.duck"));
 assertThat(parsedJson.read("$.['key'].['complex.key']", String.class)).isEqualTo("foo");
```

> 여기서는 `byCommand` 메소드에서 `assertThatValueIsANumber`를 호출한다. 이 메소드는 테스트 베이스 클래스에 정의한 메소드이거나, 그렇지 않다면 스태틱 임포트를 사용해서 불러와야 한다. `byCommand`를 호출했기 때문에, 이 부분은 `assertThatValueIsANumber(parsedJson.read(“$.duck”));`으로 변환된 것을 확인할 수 있다. 즉, Verifier 엔진이 이 메소드 이름을 가져와, 지정한 JSON 경로 값을 파라미터로 전달한다. 

이에 따라 만들어지는 WireMock 스텁<sup>stub</sup>은 다음과 같다:

```json
					'''
{
  "request" : {
    "urlPath" : "/get",
    "method" : "POST",
    "headers" : {
      "Content-Type" : {
        "matches" : "application/json.*"
      }
    },
    "bodyPatterns" : [ {
      "matchesJsonPath" : "$.['list'].['some'].['nested'][?(@.['anothervalue'] == 4)]"
    }, {
      "matchesJsonPath" : "$[?(@.['valueWithoutAMatcher'] == 'foo')]"
    }, {
      "matchesJsonPath" : "$[?(@.['valueWithTypeMatch'] == 'string')]"
    }, {
      "matchesJsonPath" : "$.['list'].['someother'].['nested'][?(@.['json'] == 'with value')]"
    }, {
      "matchesJsonPath" : "$.['list'].['someother'].['nested'][?(@.['anothervalue'] == 4)]"
    }, {
      "matchesJsonPath" : "$[?(@.duck =~ /([0-9]{3})/)]"
    }, {
      "matchesJsonPath" : "$[?(@.duck == 123)]"
    }, {
      "matchesJsonPath" : "$[?(@.alpha =~ /([\\\\p{L}]*)/)]"
    }, {
      "matchesJsonPath" : "$[?(@.alpha == 'abc')]"
    }, {
      "matchesJsonPath" : "$[?(@.number =~ /(-?(\\\\d*\\\\.\\\\d+|\\\\d+))/)]"
    }, {
      "matchesJsonPath" : "$[?(@.aBoolean =~ /((true|false))/)]"
    }, {
      "matchesJsonPath" : "$[?(@.date =~ /((\\\\d\\\\d\\\\d\\\\d)-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01]))/)]"
    }, {
      "matchesJsonPath" : "$[?(@.dateTime =~ /(([0-9]{4})-(1[0-2]|0[1-9])-(3[01]|0[1-9]|[12][0-9])T(2[0-3]|[01][0-9]):([0-5][0-9]):([0-5][0-9]))/)]"
    }, {
      "matchesJsonPath" : "$[?(@.time =~ /((2[0-3]|[01][0-9]):([0-5][0-9]):([0-5][0-9]))/)]"
    }, {
      "matchesJsonPath" : "$.list.some.nested[?(@.json =~ /(.*)/)]"
    }, {
      "matchesJsonPath" : "$[?(@.valueWithMin.size() >= 1)]"
    }, {
      "matchesJsonPath" : "$[?(@.valueWithMax.size() <= 3)]"
    }, {
      "matchesJsonPath" : "$[?(@.valueWithMinMax.size() >= 1 && @.valueWithMinMax.size() <= 3)]"
    }, {
      "matchesJsonPath" : "$[?(@.valueWithOccurrence.size() >= 4 && @.valueWithOccurrence.size() <= 4)]"
    } ]
  },
  "response" : {
    "status" : 200,
    "body" : "{\\"duck\\":123,\\"alpha\\":\\"abc\\",\\"number\\":123,\\"aBoolean\\":true,\\"date\\":\\"2017-01-01\\",\\"dateTime\\":\\"2017-01-01T01:23:45\\",\\"time\\":\\"01:02:34\\",\\"valueWithoutAMatcher\\":\\"foo\\",\\"valueWithTypeMatch\\":\\"string\\",\\"valueWithMin\\":[1,2,3],\\"valueWithMax\\":[1,2,3],\\"valueWithMinMax\\":[1,2,3],\\"valueWithOccurrence\\":[1,2,3,4]}",
    "headers" : {
      "Content-Type" : "application/json"
    },
    "transformers" : [ "response-template", "spring-cloud-contract" ]
  }
}
'''
```

> `matcher`를 사용하는 경우, 요청과 응답에서 JSON 경로로 `matcher`를 처리하는 부분은, 별도의 assertion 코드를 추가하지 않는다. 컬렉션을 검증해야 한다면, 반드시 컬렉션의 **모든** 요소에 대한 matchers를 생성해야 한다.

아래 코드를 한 번 살펴보자:

```groovy
Contract.make {
    request {
        method 'GET'
        url("/foo")
    }
    response {
        status OK()
        body(events: [[
                                 operation          : 'EXPORT',
                                 eventId            : '16f1ed75-0bcc-4f0d-a04d-3121798faf99',
                                 status             : 'OK'
                         ], [
                                 operation          : 'INPUT_PROCESSING',
                                 eventId            : '3bb4ac82-6652-462f-b6d1-75e424a0024a',
                                 status             : 'OK'
                         ]
                ]
        )
        bodyMatchers {
            jsonPath('$.events[0].operation', byRegex('.+'))
            jsonPath('$.events[0].eventId', byRegex('^([a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12})$'))
            jsonPath('$.events[0].status', byRegex('.+'))
        }
    }
}
```

위 코드로 만들어지는 테스트는 다음과 같다 (assertion 부분만 표기했다):

```java
and:
	DocumentContext parsedJson = JsonPath.parse(response.body.asString())
	assertThatJson(parsedJson).array("['events']").contains("['eventId']").isEqualTo("16f1ed75-0bcc-4f0d-a04d-3121798faf99")
	assertThatJson(parsedJson).array("['events']").contains("['operation']").isEqualTo("EXPORT")
	assertThatJson(parsedJson).array("['events']").contains("['operation']").isEqualTo("INPUT_PROCESSING")
	assertThatJson(parsedJson).array("['events']").contains("['eventId']").isEqualTo("3bb4ac82-6652-462f-b6d1-75e424a0024a")
	assertThatJson(parsedJson).array("['events']").contains("['status']").isEqualTo("OK")
and:
	assertThat(parsedJson.read("\$.events[0].operation", String.class)).matches(".+")
	assertThat(parsedJson.read("\$.events[0].eventId", String.class)).matches("^([a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12})\$")
	assertThat(parsedJson.read("\$.events[0].status", String.class)).matches(".+")
```

assertion이 뭔가 잘못되었다는 걸 알 수 있다. 여기서는 배열 내 첫 번째 요소만 검증하고 있다. 이 문제를 해결하려면 `$.events` 컬렉션 전체에 `byCommand(...)` 메소드를 사용해 assertion을 적용해야 한다.