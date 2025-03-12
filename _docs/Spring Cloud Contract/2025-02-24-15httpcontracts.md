---
title: 3.2. Contracts for HTTP
navTitle: Contracts for HTTP
category: Spring Cloud Contract
order: 16
permalink: /Spring%20Cloud%20Contract/http/
description: http 요청, 응답 명세 정의하기
image: ./../../images/springcloud/logo.jpeg
lastmod: 2025-03-12T23:34:00+09:00
comments: true
originalRefName: 스프링 클라우드 컨트랙트
originalRefLink: https://docs.spring.io/spring-cloud-contract/reference/4.2.0/project-features-contract/http.html
parent: Spring Cloud Contract Features
parentUrl: /Spring%20Cloud%20Contract/features/
subparent: 3.2. Contracts for HTTP
subparentNavTitle: Contracts for HTTP
isSubparent: true
subparentUrl: /Spring%20Cloud%20Contract/http/
---
<script>defaultLanguages = ['groovy', 'test']</script>

---

Spring Cloud Contract를 사용하면 REST API나 HTTP로 통신하는 애플리케이션을 검증할 수 있다. Spring Cloud Contract는 명세<sup>contract</sup>의 `request` 부분에 써있는 조건과 일치하는 요청을 전송하면, 서버가 명세<sup>contract</sup>의 `response`에 적힌 내용과 일치하는 응답을 보내는지 검증한다. 이어서 이 명세<sup>contract</sup>를 사용해서, 작성한 조건별 요청에 대해 적절한 응답을 제공하는 WireMock 스텁<sup>stub</sup>을 생성한다.

### 목차

- [3.2.1. HTTP 최상위 요소](#321-http-top-level-elements)
- [3.2.2. HTTP 요청](#322-http-request)
- [3.2.3. HTTP 응답](#323-http-response)
- [3.2.4. HTTP에서 XML 사용하기](#324-xml-support-for-http)
  + [XML 네임스페이스 지원](#xml-support-for-namespaces)
- [3.2.5. 비동기 처리 지원](#325-asynchronous-support)

### 3.2.1. HTTP Top-Level Elements

명세<sup>contract</sup>를 정의할 땐 최상위 클로저에서 다음 메소드를 호출할 수 있다:

- `request`: 필수
- `response` : 필수
- `priority`: 생략 가능

다음은 HTTP 요청 명세<sup>contract</sup>를 정의하는 예시다:

<div class="switch-language-wrapper groovy yaml java kotlin">
<span class="switch-language groovy">Groovy</span>
<span class="switch-language yaml">YAML</span>
<span class="switch-language java">Java</span>
<span class="switch-language kotlin">Kotlin</span>
</div>
<div class="language-only-for-groovy groovy yaml java kotlin"></div>
```groovy
org.springframework.cloud.contract.spec.Contract.make {
	// Definition of HTTP request part of the contract
	// (this can be a valid request or invalid depending
	// on type of contract being specified).
	request {
		method GET()
		url "/foo"
		//...
	}

	// Definition of HTTP response part of the contract
	// (a service implementing this contract should respond
	// with following response after receiving request
	// specified in "request" part above).
	response {
		status 200
		//...
	}

	// Contract priority, which can be used for overriding
	// contracts (1 is highest). Priority is optional.
	priority 1
}
```
<div class="language-only-for-yaml groovy yaml java kotlin"></div>
```yml
priority: 8
request:
...
response:
...
```
<div class="language-only-for-java groovy yaml java kotlin"></div>
```java
org.springframework.cloud.contract.spec.Contract.make(c -> {
	// Definition of HTTP request part of the contract
	// (this can be a valid request or invalid depending
	// on type of contract being specified).
	c.request(r -> {
		r.method(r.GET());
		r.url("/foo");
		// ...
	});

	// Definition of HTTP response part of the contract
	// (a service implementing this contract should respond
	// with following response after receiving request
	// specified in "request" part above).
	c.response(r -> {
		r.status(200);
		// ...
	});

	// Contract priority, which can be used for overriding
	// contracts (1 is highest). Priority is optional.
	c.priority(1);
});
```
<div class="language-only-for-kotlin groovy yaml java kotlin"></div>
```kotlin
contract {
    // Definition of HTTP request part of the contract
    // (this can be a valid request or invalid depending
    // on type of contract being specified).
    request {
        method = GET
        url = url("/foo")
        // ...
    }

    // Definition of HTTP response part of the contract
    // (a service implementing this contract should respond
    // with following response after receiving request
    // specified in "request" part above).
    response {
        status = OK
        // ...
    }

    // Contract priority, which can be used for overriding
    // contracts (1 is highest). Priority is optional.
    priority = 1
}
```

> 작성 중인 명세<sup>contract</sup>에 더 높은 우선순위를 부여하고 싶다면, `priority` 태그 혹은 메소드에 더 낮은 숫자를 지정해야 한다. 예를 들어, `priority` 값이 `5`면 `priority` 값이 `10`인 것 보다 우선순위가 더 높다.

### 3.2.2. HTTP Request

HTTP 프로토콜에선 메소드와 URL만 지정하면 요청을 정의할 수 있다. 명세<sup>contract</sup>에 요청을 정의할 때 필수로 필요한 정보 역시 동일하다.

다음은 요청을 정의하는 명세<sup>contract</sup> 예시다:

<div class="switch-language-wrapper groovy yaml java kotlin">
<span class="switch-language groovy">Groovy</span>
<span class="switch-language yaml">YAML</span>
<span class="switch-language java">Java</span>
<span class="switch-language kotlin">Kotlin</span>
</div>
<div class="language-only-for-groovy groovy yaml java kotlin"></div>
```groovy
org.springframework.cloud.contract.spec.Contract.make {
	request {
		// HTTP request method (GET/POST/PUT/DELETE).
		method 'GET'

		// Path component of request URL is specified as follows.
		urlPath('/users')
	}

	response {
		//...
		status 200
	}
}
```
<div class="language-only-for-yaml groovy yaml java kotlin"></div>
```yaml
method: PUT
url: /foo
```
<div class="language-only-for-java groovy yaml java kotlin"></div>
```java
org.springframework.cloud.contract.spec.Contract.make(c -> {
	c.request(r -> {
		// HTTP request method (GET/POST/PUT/DELETE).
		r.method("GET");

		// Path component of request URL is specified as follows.
		r.urlPath("/users");
	});

	c.response(r -> {
		// ...
		r.status(200);
	});
});
```
<div class="language-only-for-kotlin groovy yaml java kotlin"></div>
```kotlin
contract {
    request {
        // HTTP request method (GET/POST/PUT/DELETE).
        method = method("GET")

        // Path component of request URL is specified as follows.
        urlPath = path("/users")
    }
    response {
        // ...
        status = code(200)
    }
}
```

상대 `url` 대신 절대 `url`을 지정할 수도 있지만, 테스트 시 호스트에 영향을 받지 않도록 `urlPath`를 사용하는 것이 좋다.

다음은 `url`을 사용하는 예시다:

<div class="switch-language-wrapper groovy yaml java kotlin">
<span class="switch-language groovy">Groovy</span>
<span class="switch-language yaml">YAML</span>
<span class="switch-language java">Java</span>
<span class="switch-language kotlin">Kotlin</span>
</div>
<div class="language-only-for-groovy groovy yaml java kotlin"></div>
```groovy
org.springframework.cloud.contract.spec.Contract.make {
	request {
		method 'GET'

		// Specifying `url` and `urlPath` in one contract is illegal.
		url('http://localhost:8888/users')
	}

	response {
		//...
		status 200
	}
}
```
<div class="language-only-for-yaml groovy yaml java kotlin"></div>
```yaml
request:
  method: PUT
  urlPath: /foo
```
<div class="language-only-for-java groovy yaml java kotlin"></div>
```java
org.springframework.cloud.contract.spec.Contract.make(c -> {
	c.request(r -> {
		r.method("GET");

		// Specifying `url` and `urlPath` in one contract is illegal.
		r.url("http://localhost:8888/users");
	});

	c.response(r -> {
		// ...
		r.status(200);
	});
});
```
<div class="language-only-for-kotlin groovy yaml java kotlin"></div>
```kotlin
contract {
    request {
        method = GET

        // Specifying `url` and `urlPath` in one contract is illegal.
        url("http://localhost:8888/users")
    }
    response {
        // ...
        status = OK
    }
}
```

`request`에는 (`urlPath`를 사용하는) 아래 예제와 같이 원하는 쿼리 파라미터를 추가할 수 있다:

<div class="switch-language-wrapper groovy yaml java kotlin">
<span class="switch-language groovy">Groovy</span>
<span class="switch-language yaml">YAML</span>
<span class="switch-language java">Java</span>
<span class="switch-language kotlin">Kotlin</span>
</div>
<div class="language-only-for-groovy groovy yaml java kotlin"></div>
```groovy
org.springframework.cloud.contract.spec.Contract.make {
	request {
		//...
		method GET()

		urlPath('/users') {

			// Each parameter is specified in form
			// `'paramName' : paramValue` where parameter value
			// may be a simple literal or one of matcher functions,
			// all of which are used in this example.
			queryParameters {

				// If a simple literal is used as value
				// default matcher function is used (equalTo)
				parameter 'limit': 100

				// `equalTo` function simply compares passed value
				// using identity operator (==).
				parameter 'filter': equalTo("email")

				// `containing` function matches strings
				// that contains passed substring.
				parameter 'gender': value(consumer(containing("[mf]")), producer('mf'))

				// `matching` function tests parameter
				// against passed regular expression.
				parameter 'offset': value(consumer(matching("[0-9]+")), producer(123))

				// `notMatching` functions tests if parameter
				// does not match passed regular expression.
				parameter 'loginStartsWith': value(consumer(notMatching(".{0,2}")), producer(3))
			}
		}

		//...
	}

	response {
		//...
		status 200
	}
}
```
<div class="language-only-for-yaml groovy yaml java kotlin"></div>
```yml
request:
...
queryParameters:
  a: b
  b: c
```
<div class="language-only-for-java groovy yaml java kotlin"></div>
```java
org.springframework.cloud.contract.spec.Contract.make(c -> {
	c.request(r -> {
		// ...
		r.method(r.GET());

		r.urlPath("/users", u -> {

			// Each parameter is specified in form
			// `'paramName' : paramValue` where parameter value
			// may be a simple literal or one of matcher functions,
			// all of which are used in this example.
			u.queryParameters(q -> {

				// If a simple literal is used as value
				// default matcher function is used (equalTo)
				q.parameter("limit", 100);

				// `equalTo` function simply compares passed value
				// using identity operator (==).
				q.parameter("filter", r.equalTo("email"));

				// `containing` function matches strings
				// that contains passed substring.
				q.parameter("gender", r.value(r.consumer(r.containing("[mf]")), r.producer("mf")));

				// `matching` function tests parameter
				// against passed regular expression.
				q.parameter("offset", r.value(r.consumer(r.matching("[0-9]+")), r.producer(123)));

				// `notMatching` functions tests if parameter
				// does not match passed regular expression.
				q.parameter("loginStartsWith", r.value(r.consumer(r.notMatching(".{0,2}")), r.producer(3)));
			});
		});

		// ...
	});

	c.response(r -> {
		// ...
		r.status(200);
	});
});
```
<div class="language-only-for-kotlin groovy yaml java kotlin"></div>
```kotlin
contract {
    request {
        // ...
        method = GET

        // Each parameter is specified in form
        // `'paramName' : paramValue` where parameter value
        // may be a simple literal or one of matcher functions,
        // all of which are used in this example.
        urlPath = path("/users") withQueryParameters {
            // If a simple literal is used as value
            // default matcher function is used (equalTo)
            parameter("limit", 100)

            // `equalTo` function simply compares passed value
            // using identity operator (==).
            parameter("filter", equalTo("email"))

            // `containing` function matches strings
            // that contains passed substring.
            parameter("gender", value(consumer(containing("[mf]")), producer("mf")))

            // `matching` function tests parameter
            // against passed regular expression.
            parameter("offset", value(consumer(matching("[0-9]+")), producer(123)))

            // `notMatching` functions tests if parameter
            // does not match passed regular expression.
            parameter("loginStartsWith", value(consumer(notMatching(".{0,2}")), producer(3)))
        }

        // ...
    }
    response {
        // ...
        status = code(200)
    }
}
```

> 명세<sup>contract</sup>에 쿼리 파라미터를 명시하지 않았다고 해서, 쿼리 파라미터가 없는 요청을 매칭시키지는 않는다. 그보단 오히려 요청을 매칭시키는 데 쿼리 파라미터가 필요하지 않다는 뜻이다.

`request`는 다음과 같이 원하는 요청 헤더도 추가할 수 있다:

<div class="switch-language-wrapper groovy yaml java kotlin">
<span class="switch-language groovy">Groovy</span>
<span class="switch-language yaml">YAML</span>
<span class="switch-language java">Java</span>
<span class="switch-language kotlin">Kotlin</span>
</div>
<div class="language-only-for-groovy groovy yaml java kotlin"></div>
```groovy
org.springframework.cloud.contract.spec.Contract.make {
	request {
		//...
		method GET()
		url "/foo"

		// Each header is added in form `'Header-Name' : 'Header-Value'`.
		// there are also some helper methods
		headers {
			header 'key': 'value'
			contentType(applicationJson())
		}

		//...
	}

	response {
		//...
		status 200
	}
}
```
<div class="language-only-for-yaml groovy yaml java kotlin"></div>
```yml
request:
...
headers:
  foo: bar
  fooReq: baz
```
<div class="language-only-for-java groovy yaml java kotlin"></div>
```java
org.springframework.cloud.contract.spec.Contract.make(c -> {
	c.request(r -> {
		// ...
		r.method(r.GET());
		r.url("/foo");

		// Each header is added in form `'Header-Name' : 'Header-Value'`.
		// there are also some helper methods
		r.headers(h -> {
			h.header("key", "value");
			h.contentType(h.applicationJson());
		});

		// ...
	});

	c.response(r -> {
		// ...
		r.status(200);
	});
});
```
<div class="language-only-for-kotlin groovy yaml java kotlin"></div>
```kotlin
contract {
    request {
        // ...
        method = GET
        url = url("/foo")

        // Each header is added in form `'Header-Name' : 'Header-Value'`.
        // there are also some helper variables
        headers {
            header("key", "value")
            contentType = APPLICATION_JSON
        }

        // ...
    }
    response {
        // ...
        status = OK
    }
}
```

`request`는 다음과 같이 원하는 요청 쿠키도 추가할 수 있다:

<div class="switch-language-wrapper groovy yaml java kotlin">
<span class="switch-language groovy">Groovy</span>
<span class="switch-language yaml">YAML</span>
<span class="switch-language java">Java</span>
<span class="switch-language kotlin">Kotlin</span>
</div>
<div class="language-only-for-groovy groovy yaml java kotlin"></div>
```groovy
org.springframework.cloud.contract.spec.Contract.make {
	request {
		//...
		method GET()
		url "/foo"

		// Each Cookies is added in form `'Cookie-Key' : 'Cookie-Value'`.
		// there are also some helper methods
		cookies {
			cookie 'key': 'value'
			cookie('another_key', 'another_value')
		}

		//...
	}

	response {
		//...
		status 200
	}
}
```
<div class="language-only-for-yaml groovy yaml java kotlin"></div>
```yml
request:
...
cookies:
  foo: bar
  fooReq: baz
```
<div class="language-only-for-java groovy yaml java kotlin"></div>
```java
org.springframework.cloud.contract.spec.Contract.make(c -> {
	c.request(r -> {
		// ...
		r.method(r.GET());
		r.url("/foo");

		// Each Cookies is added in form `'Cookie-Key' : 'Cookie-Value'`.
		// there are also some helper methods
		r.cookies(ck -> {
			ck.cookie("key", "value");
			ck.cookie("another_key", "another_value");
		});

		// ...
	});

	c.response(r -> {
		// ...
		r.status(200);
	});
});
```
<div class="language-only-for-kotlin groovy yaml java kotlin"></div>
```kotlin
contract {
    request {
        // ...
        method = GET
        url = url("/foo")

        // Each Cookies is added in form `'Cookie-Key' : 'Cookie-Value'`.
        // there are also some helper methods
        cookies {
            cookie("key", "value")
            cookie("another_key", "another_value")
        }

        // ...
    }

    response {
        // ...
        status = code(200)
    }
}
```

`request`에는 다음과 같이 원하는 요청 body도 추가할 수 있다:

<div class="switch-language-wrapper groovy yaml java kotlin">
<span class="switch-language groovy">Groovy</span>
<span class="switch-language yaml">YAML</span>
<span class="switch-language java">Java</span>
<span class="switch-language kotlin">Kotlin</span>
</div>
<div class="language-only-for-groovy groovy yaml java kotlin"></div>
```groovy
org.springframework.cloud.contract.spec.Contract.make {
	request {
		//...
		method GET()
		url "/foo"

		// Currently only JSON format of request body is supported.
		// Format will be determined from a header or body's content.
		body '''{ "login" : "john", "name": "John The Contract" }'''
	}

	response {
		//...
		status 200
	}
}
```
<div class="language-only-for-yaml groovy yaml java kotlin"></div>
```yml
request:
...
body:
  foo: bar
```
<div class="language-only-for-java groovy yaml java kotlin"></div>
```java
org.springframework.cloud.contract.spec.Contract.make(c -> {
	c.request(r -> {
		// ...
		r.method(r.GET());
		r.url("/foo");

		// Currently only JSON format of request body is supported.
		// Format will be determined from a header or body's content.
		r.body("{ \"login\" : \"john\", \"name\": \"John The Contract\" }");
	});

	c.response(r -> {
		// ...
		r.status(200);
	});
});
```
<div class="language-only-for-kotlin groovy yaml java kotlin"></div>
```kotlin
contract {
    request {
        // ...
        method = GET
        url = url("/foo")

        // Currently only JSON format of request body is supported.
        // Format will be determined from a header or body's content.
        body = body("{ \"login\" : \"john\", \"name\": \"John The Contract\" }")
    }
    response {
        // ...
        status = OK
    }
}
```

`request`에는 멀티파트와 관련된 스펙도 정의할 수 있다. 다음과 같이 `multipart` 메소드/섹션을 사용하면 된다:

<div class="switch-language-wrapper groovy yaml java kotlin">
<span class="switch-language groovy">Groovy</span>
<span class="switch-language yaml">YAML</span>
<span class="switch-language java">Java</span>
<span class="switch-language kotlin">Kotlin</span>
</div>
<div class="language-only-for-groovy groovy yaml java kotlin"></div>
```groovy
org.springframework.cloud.contract.spec.Contract contractDsl = org.springframework.cloud.contract.spec.Contract.make {
	request {
		method 'PUT'
		url '/multipart'
		headers {
			contentType('multipart/form-data;boundary=AaB03x')
		}
		multipart(
				// key (parameter name), value (parameter value) pair
				formParameter: $(c(regex('".+"')), p('"formParameterValue"')),
				someBooleanParameter: $(c(regex(anyBoolean())), p('true')),
				// a named parameter (e.g. with `file` name) that represents file with
				// `name` and `content`. You can also call `named("fileName", "fileContent")`
				file: named(
						// name of the file
						name: $(c(regex(nonEmpty())), p('filename.csv')),
						// content of the file
						content: $(c(regex(nonEmpty())), p('file content')),
						// content type for the part
						contentType: $(c(regex(nonEmpty())), p('application/json')))
		)
	}
	response {
		status OK()
	}
}
org.springframework.cloud.contract.spec.Contract contractDsl = org.springframework.cloud.contract.spec.Contract.make {
	request {
		method "PUT"
		url "/multipart"
		headers {
			contentType('multipart/form-data;boundary=AaB03x')
		}
		multipart(
				file: named(
						name: value(stub(regex('.+')), test('file')),
						content: value(stub(regex('.+')), test([100, 117, 100, 97] as byte[]))
				)
		)
	}
	response {
		status 200
	}
}
```
<div class="language-only-for-yaml groovy yaml java kotlin"></div>
```yaml
request:
  method: PUT
  url: /multipart
  headers:
    Content-Type: multipart/form-data;boundary=AaB03x
  multipart:
    params:
      # key (parameter name), value (parameter value) pair
      formParameter: '"formParameterValue"'
      someBooleanParameter: true
    named:
      - paramName: file
        fileName: filename.csv
        fileContent: file content
  matchers:
    multipart:
      params:
        - key: formParameter
          regex: ".+"
        - key: someBooleanParameter
          predefined: any_boolean
      named:
        - paramName: file
          fileName:
            predefined: non_empty
          fileContent:
            predefined: non_empty
response:
  status: 200
```
<div class="language-only-for-java groovy yaml java kotlin"></div>
```java
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Supplier;

import org.springframework.cloud.contract.spec.Contract;
import org.springframework.cloud.contract.spec.internal.DslProperty;
import org.springframework.cloud.contract.spec.internal.Request;
import org.springframework.cloud.contract.verifier.util.ContractVerifierUtil;

class contract_multipart implements Supplier<Collection<Contract>> {

	private static Map<String, DslProperty> namedProps(Request r) {
		Map<String, DslProperty> map = new HashMap<>();
		// name of the file
		map.put("name", r.$(r.c(r.regex(r.nonEmpty())), r.p("filename.csv")));
		// content of the file
		map.put("content", r.$(r.c(r.regex(r.nonEmpty())), r.p("file content")));
		// content type for the part
		map.put("contentType", r.$(r.c(r.regex(r.nonEmpty())), r.p("application/json")));
		return map;
	}

	@Override
	public Collection<Contract> get() {
		return Collections.singletonList(Contract.make(c -> {
			c.request(r -> {
				r.method("PUT");
				r.url("/multipart");
				r.headers(h -> {
					h.contentType("multipart/form-data;boundary=AaB03x");
				});
				r.multipart(ContractVerifierUtil.map()
					// key (parameter name), value (parameter value) pair
					.entry("formParameter", r.$(r.c(r.regex("\".+\"")), r.p("\"formParameterValue\"")))
					.entry("someBooleanParameter", r.$(r.c(r.regex(r.anyBoolean())), r.p("true")))
					// a named parameter (e.g. with `file` name) that represents file
					// with
					// `name` and `content`. You can also call `named("fileName",
					// "fileContent")`
					.entry("file", r.named(namedProps(r))));
			});
			c.response(r -> {
				r.status(r.OK());
			});
		}));
	}

}
```
<div class="language-only-for-kotlin groovy yaml java kotlin"></div>
```kotlin
import org.springframework.cloud.contract.spec.ContractDsl.Companion.contract

contract {
    request {
        method = PUT
        url = url("/multipart")
        multipart {
            field("formParameter", value(consumer(regex("\".+\"")), producer("\"formParameterValue\"")))
            field("someBooleanParameter", value(consumer(anyBoolean), producer("true")))
            field("file",
                named(
                    // name of the file
                    value(consumer(regex(nonEmpty)), producer("filename.csv")),
                    // content of the file
                    value(consumer(regex(nonEmpty)), producer("file content")),
                    // content type for the part
                    value(consumer(regex(nonEmpty)), producer("application/json"))
                )
            )
        }
        headers {
            contentType = "multipart/form-data;boundary=AaB03x"
        }
    }
    response {
        status = OK
    }
}
```

위 예제에선 다음과 같은 방법으로 파라미터를 정의하고 있다:

*프로그래밍 언어 DSL*

- map 표기법을 사용해서 동적인 프로퍼티를 직접 추가한다  (e.g. `formParameter: $(consumer(...), producer(...))`).
- 파일 관련 파라미터의 이름<sup>named parameter</sup>을 설정할 땐 `named(...)` 메소드를 사용한다. 이땐 `name`과 `content`를 설정할 수 있다. `named("fileName", "fileContent")`와 같이 메소드에 두 개의 인자를 넘기거나, `named(name: "fileName", content: "fileContent")`와 같이 map 표기법을 사용해 호출할 수 있다.

*YAML*

- 일반적인 멀티파트 파라미터는 `multipart.params` 섹션에 설정한다.
- 파일 관련 파라미터의 이름<sup>named parameter</sup>을 지정할 땐 (해당 파라미터에 대한 `fileName`, `fileContent`), `multipart.named` 섹션에 설정할 수 있다. 이 섹션에는 `paramName`(파라미터 이름), `fileName`(파일 이름), `fileContent`(파일 내용) 필드를 설정할 수 있다.
- `matchers.multipart` 섹션엔 동적인 값도 정의할 수 있다.
  - 일반 폼 파라미터의 경우 `params` 섹션에 정의하면 되고, `regex`나 `predefined` 정규식을 사용할 수 있다.
  - 파일 관련 파라미터의 이름<sup>named parameter</sup>을 설정할 땐 `named` 섹션에 정의하면 된다. 먼저, `paramName`으로 파라미터명을 정의하고, `fileName` 또는 `fileContent`에 `regex`나 `predefined` 정규식을 넘겨 동적인 값을 정의할 수 있다.

> `named(...)` 섹션을 사용할 땐 항상 `value(producer(...), consumer(...))`를 쌍으로 호출해야 한다. 단순히 `value(producer(...))`나 `file(...)`과 같은 DSL 프로퍼티만 설정하면 동작하지 않는다. 자세한 내용은 이 [이슈](https://github.com/spring-cloud/spring-cloud-contract/issues/1886)를 참고해라.

위 명세<sup>contract</sup>로 만들어지는 테스트와 스텁<sup>stub</sup>은 다음과 같다:

<div class="switch-language-wrapper test stub">
<span class="switch-language test">Test</span>
<span class="switch-language stub">Stub</span>
</div>
<div class="language-only-for-test test stub"></div>
```java
// given:
  MockMvcRequestSpecification request = given()
    .header("Content-Type", "multipart/form-data;boundary=AaB03x")
    .param("formParameter", "\"formParameterValue\"")
    .param("someBooleanParameter", "true")
    .multiPart("file", "filename.csv", "file content".getBytes());

 // when:
  ResponseOptions response = given().spec(request)
    .put("/multipart");

 // then:
  assertThat(response.statusCode()).isEqualTo(200);
```
<div class="language-only-for-stub test stub"></div>
```json
			'''
{
  "request" : {
	"url" : "/multipart",
	"method" : "PUT",
	"headers" : {
	  "Content-Type" : {
		"matches" : "multipart/form-data;boundary=AaB03x.*"
	  }
	},
	"bodyPatterns" : [ {
		"matches" : ".*--(.*)\\r?\\nContent-Disposition: form-data; name=\\"formParameter\\"\\r?\\n(Content-Type: .*\\r?\\n)?(Content-Transfer-Encoding: .*\\r?\\n)?(Content-Length: \\\\d+\\r?\\n)?\\r?\\n\\".+\\"\\r?\\n--.*"
  		}, {
    			"matches" : ".*--(.*)\\r?\\nContent-Disposition: form-data; name=\\"someBooleanParameter\\"\\r?\\n(Content-Type: .*\\r?\\n)?(Content-Transfer-Encoding: .*\\r?\\n)?(Content-Length: \\\\d+\\r?\\n)?\\r?\\n(true|false)\\r?\\n--.*"
  		}, {			
	  "matches" : ".*--(.*)\\r?\\nContent-Disposition: form-data; name=\\"file\\"; filename=\\"[\\\\S\\\\s]+\\"\\r?\\n(Content-Type: .*\\r?\\n)?(Content-Transfer-Encoding: .*\\r?\\n)?(Content-Length: \\\\d+\\r?\\n)?\\r?\\n[\\\\S\\\\s]+\\r?\\n--.*"
	} ]
  },
  "response" : {
	"status" : 200,
	"transformers" : [ "response-template", "foo-transformer" ]
  }
}
	'''
```

### 3.2.3. HTTP Response

응답을 정의할 땐 HTTP 상태 코드를 필수로 포함시켜야 하며, 다른 부가 정보도 추가로 정의할 수 있다. 다음은 응답을 정의하는 예시다:

<div class="switch-language-wrapper groovy yaml java kotlin">
<span class="switch-language groovy">Groovy</span>
<span class="switch-language yaml">YAML</span>
<span class="switch-language java">Java</span>
<span class="switch-language kotlin">Kotlin</span>
</div>
<div class="language-only-for-groovy groovy yaml java kotlin"></div>
```groovy
org.springframework.cloud.contract.spec.Contract.make {
	request {
		//...
		method GET()
		url "/foo"
	}
	response {
		// Status code sent by the server
		// in response to request specified above.
		status OK()
	}
}
```
<div class="language-only-for-yaml groovy yaml java kotlin"></div>
```yml
response:
...
status: 200
```
<div class="language-only-for-java groovy yaml java kotlin"></div>
```java
org.springframework.cloud.contract.spec.Contract.make(c -> {
	c.request(r -> {
		// ...
		r.method(r.GET());
		r.url("/foo");
	});
	c.response(r -> {
		// Status code sent by the server
		// in response to request specified above.
		r.status(r.OK());
	});
});
```
<div class="language-only-for-kotlin groovy yaml java kotlin"></div>
```kotlin
contract {
    request {
        // ...
        method = GET
        url =url("/foo")
    }
    response {
        // Status code sent by the server
        // in response to request specified above.
        status = OK
    }
}
```

응답에는 상태 코드 외에도 헤더, 쿠키, body를 정의할 수 있으며, 요청에 정의할 때와 동일한 방법을 사용하면 된다 ([HTTP 요청](#322-http-request) 참고).

> Groovy DSL에서는 단순히 숫자로 상태 코드를 정의하는 대신, `org.springframework.cloud.contract.spec.internal.HttpStatus` 메소드를 참조하면 상태 코드의 의미를 드러낼 수 있다. 예를 들어, 상태 코드 `200`은 `OK()`를, `400`은 `BAD_REQUEST()`를 호출할 수 있다.

### 3.2.4. XML Support for HTTP

HTTP 명세<sup>contract</sup>의 경우, 요청, 응답 body에 XML도 사용할 수 있다. XML body는 `body` 요소 내에 `String`이나 `GString`으로 전달해야 한다. 또한, 요청과 응답 모두 body matcher를 정의할 수 있다. `jsonPath(...)` 메소드 대신 `org.springframework.cloud.contract.spec.internal.BodyMatchers.xPath` 메소드를 사용해야 하며, 첫 번째 인자로 원하는 `xPath`를, 두 번째 인자로 적절한 `MatchingType`을 넘기면 된다. `byType()`을 제외한 모든 body matcher를 지원한다.

다음은 응답 body를 XML로 정의한 명세<sup>contract</sup> 예시다:

<div class="switch-language-wrapper groovy yaml java kotlin">
<span class="switch-language groovy">Groovy</span>
<span class="switch-language yaml">YAML</span>
<span class="switch-language java">Java</span>
<span class="switch-language kotlin">Kotlin</span>
</div>
<div class="language-only-for-groovy groovy yaml java kotlin"></div>
```groovy
					Contract.make {
						request {
							method GET()
							urlPath '/get'
							headers {
								contentType(applicationXml())
							}
						}
						response {
							status(OK())
							headers {
								contentType(applicationXml())
							}
							body """
<test>
<duck type='xtype'>123</duck>
<alpha>abc</alpha>
<list>
<elem>abc</elem>
<elem>def</elem>
<elem>ghi</elem>
</list>
<number>123</number>
<aBoolean>true</aBoolean>
<date>2017-01-01</date>
<dateTime>2017-01-01T01:23:45</dateTime>
<time>01:02:34</time>
<valueWithoutAMatcher>foo</valueWithoutAMatcher>
<key><complex>foo</complex></key>
</test>"""
							bodyMatchers {
								xPath('/test/duck/text()', byRegex("[0-9]{3}"))
								xPath('/test/duck/text()', byCommand('equals($it)'))
								xPath('/test/duck/xxx', byNull())
								xPath('/test/duck/text()', byEquality())
								xPath('/test/alpha/text()', byRegex(onlyAlphaUnicode()))
								xPath('/test/alpha/text()', byEquality())
								xPath('/test/number/text()', byRegex(number()))
								xPath('/test/date/text()', byDate())
								xPath('/test/dateTime/text()', byTimestamp())
								xPath('/test/time/text()', byTime())
								xPath('/test/*/complex/text()', byEquality())
								xPath('/test/duck/@type', byEquality())
							}
						}
					}
					Contract.make {
						request {
							method GET()
							urlPath '/get'
							headers {
								contentType(applicationXml())
							}
						}
						response {
							status(OK())
							headers {
								contentType(applicationXml())
							}
							body """
<ns1:test xmlns:ns1="http://demo.com/testns">
 <ns1:header>
    <duck-bucket type='bigbucket'>
      <duck>duck5150</duck>
    </duck-bucket>
</ns1:header>
</ns1:test>
"""
							bodyMatchers {
								xPath('/test/duck/text()', byRegex("[0-9]{3}"))
								xPath('/test/duck/text()', byCommand('equals($it)'))
								xPath('/test/duck/xxx', byNull())
								xPath('/test/duck/text()', byEquality())
								xPath('/test/alpha/text()', byRegex(onlyAlphaUnicode()))
								xPath('/test/alpha/text()', byEquality())
								xPath('/test/number/text()', byRegex(number()))
								xPath('/test/date/text()', byDate())
								xPath('/test/dateTime/text()', byTimestamp())
								xPath('/test/time/text()', byTime())
								xPath('/test/duck/@type', byEquality())
							}
						}
					}
					Contract.make {
						request {
							method GET()
							urlPath '/get'
							headers {
								contentType(applicationXml())
							}
						}
						response {
							status(OK())
							headers {
								contentType(applicationXml())
							}
							body """
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">
   <SOAP-ENV:Header>
      <RsHeader xmlns="http://schemas.xmlsoap.org/soap/custom">
         <MsgSeqId>1234</MsgSeqId>
      </RsHeader>
   </SOAP-ENV:Header>
</SOAP-ENV:Envelope>
"""
							bodyMatchers {
								xPath('//*[local-name()=\'RsHeader\' and namespace-uri()=\'http://schemas.xmlsoap.org/soap/custom\']/*[local-name()=\'MsgSeqId\']/text()', byEquality())
							}
						}
					}
					Contract.make {
						request {
							method GET()
							urlPath '/get'
							headers {
								contentType(applicationXml())
							}
						}
						response {
							status(OK())
							headers {
								contentType(applicationXml())
							}
							body """
<ns1:customer xmlns:ns1="http://demo.com/customer" xmlns:addr="http://demo.com/address">
	<email>customer@test.com</email>
	<contact-info xmlns="http://demo.com/contact-info">
		<name>Krombopulous</name>
		<address>
			<addr:gps>
				<lat>51</lat>
				<addr:lon>50</addr:lon>
			</addr:gps>
		</address>
	</contact-info>
</ns1:customer>
"""
						}
					}
```
<div class="language-only-for-yaml groovy yaml java kotlin"></div>
```yml
request:
  method: GET
  url: /getymlResponse
  headers:
    Content-Type: application/xml
  body: |
    <test>
    <duck type='xtype'>123</duck>
    <alpha>abc</alpha>
    <list>
    <elem>abc</elem>
    <elem>def</elem>
    <elem>ghi</elem>
    </list>
    <number>123</number>
    <aBoolean>true</aBoolean>
    <date>2017-01-01</date>
    <dateTime>2017-01-01T01:23:45</dateTime>
    <time>01:02:34</time>
    <valueWithoutAMatcher>foo</valueWithoutAMatcher>
    <valueWithTypeMatch>string</valueWithTypeMatch>
    <key><complex>foo</complex></key>
    </test>
  matchers:
    body:
      - path: /test/duck/text()
        type: by_regex
        value: "[0-9]{10}"
      - path: /test/duck/text()
        type: by_equality
      - path: /test/time/text()
        type: by_time
response:
  status: 200
  headers:
    Content-Type: application/xml
  body: |
    <test>
    <duck type='xtype'>123</duck>
    <alpha>abc</alpha>
    <list>
    <elem>abc</elem>
    <elem>def</elem>
    <elem>ghi</elem>
    </list>
    <number>123</number>
    <aBoolean>true</aBoolean>
    <date>2017-01-01</date>
    <dateTime>2017-01-01T01:23:45</dateTime>
    <time>01:02:34</time>
    <valueWithoutAMatcher>foo</valueWithoutAMatcher>
    <valueWithTypeMatch>string</valueWithTypeMatch>
    <key><complex>foo</complex></key>
    </test>
  matchers:
    body:
      - path: /test/duck/text()
        type: by_regex
        value: "[0-9]{10}"
      - path: /test/duck/text()
        type: by_command
        value: "test($it)"
      - path: /test/duck/xxx
        type: by_null
      - path: /test/duck/text()
        type: by_equality
      - path: /test/time/text()
        type: by_time
```
<div class="language-only-for-java groovy yaml java kotlin"></div>
```java
import java.util.function.Supplier;

import org.springframework.cloud.contract.spec.Contract;

class contract_xml implements Supplier<Contract> {

	@Override
	public Contract get() {
		return Contract.make(c -> {
			c.request(r -> {
				r.method(r.GET());
				r.urlPath("/get");
				r.headers(h -> {
					h.contentType(h.applicationXml());
				});
			});
			c.response(r -> {
				r.status(r.OK());
				r.headers(h -> {
					h.contentType(h.applicationXml());
				});
				r.body("<test>\n" + "<duck type='xtype'>123</duck>\n" + "<alpha>abc</alpha>\n" + "<list>\n"
						+ "<elem>abc</elem>\n" + "<elem>def</elem>\n" + "<elem>ghi</elem>\n" + "</list>\n"
						+ "<number>123</number>\n" + "<aBoolean>true</aBoolean>\n" + "<date>2017-01-01</date>\n"
						+ "<dateTime>2017-01-01T01:23:45</dateTime>\n" + "<time>01:02:34</time>\n"
						+ "<valueWithoutAMatcher>foo</valueWithoutAMatcher>\n" + "<key><complex>foo</complex></key>\n"
						+ "</test>");
				r.bodyMatchers(m -> {
					m.xPath("/test/duck/text()", m.byRegex("[0-9]{3}"));
					m.xPath("/test/duck/text()", m.byCommand("equals($it)"));
					m.xPath("/test/duck/xxx", m.byNull());
					m.xPath("/test/duck/text()", m.byEquality());
					m.xPath("/test/alpha/text()", m.byRegex(r.onlyAlphaUnicode()));
					m.xPath("/test/alpha/text()", m.byEquality());
					m.xPath("/test/number/text()", m.byRegex(r.number()));
					m.xPath("/test/date/text()", m.byDate());
					m.xPath("/test/dateTime/text()", m.byTimestamp());
					m.xPath("/test/time/text()", m.byTime());
					m.xPath("/test/*/complex/text()", m.byEquality());
					m.xPath("/test/duck/@type", m.byEquality());
				});
			});
		});
	};

}
```
<div class="language-only-for-kotlin groovy yaml java kotlin"></div>
```kotlin
import org.springframework.cloud.contract.spec.ContractDsl.Companion.contract

contract {
    request {
        method = GET
        urlPath = path("/get")
        headers {
            contentType = APPLICATION_XML
        }
    }
    response {
        status = OK
        headers {
            contentType =APPLICATION_XML
        }
        body = body("<test>\n" + "<duck type='xtype'>123</duck>\n"
                + "<alpha>abc</alpha>\n" + "<list>\n" + "<elem>abc</elem>\n"
                + "<elem>def</elem>\n" + "<elem>ghi</elem>\n" + "</list>\n"
                + "<number>123</number>\n" + "<aBoolean>true</aBoolean>\n"
                + "<date>2017-01-01</date>\n"
                + "<dateTime>2017-01-01T01:23:45</dateTime>\n"
                + "<time>01:02:34</time>\n"
                + "<valueWithoutAMatcher>foo</valueWithoutAMatcher>\n"
                + "<key><complex>foo</complex></key>\n" + "</test>")
        bodyMatchers {
            xPath("/test/duck/text()", byRegex("[0-9]{3}"))
            xPath("/test/duck/text()", byCommand("equals(\$it)"))
            xPath("/test/duck/xxx", byNull)
            xPath("/test/duck/text()", byEquality)
            xPath("/test/alpha/text()", byRegex(onlyAlphaUnicode))
            xPath("/test/alpha/text()", byEquality)
            xPath("/test/number/text()", byRegex(number))
            xPath("/test/date/text()", byDate)
            xPath("/test/dateTime/text()", byTimestamp)
            xPath("/test/time/text()", byTime)
            xPath("/test/*/complex/text()", byEquality)
            xPath("/test/duck/@type", byEquality)
        }
    }
}
```

다음은 응답 body에 있는 XML로 자동 생성된 테스트 예시다:

```java
@Test
public void validate_xmlMatches() throws Exception {
	// given:
	MockMvcRequestSpecification request = given()
				.header("Content-Type", "application/xml");

	// when:
	ResponseOptions response = given().spec(request).get("/get");

	// then:
	assertThat(response.statusCode()).isEqualTo(200);
	// and:
	DocumentBuilder documentBuilder = DocumentBuilderFactory.newInstance()
					.newDocumentBuilder();
	Document parsedXml = documentBuilder.parse(new InputSource(
				new StringReader(response.getBody().asString())));
	// and:
	assertThat(valueFromXPath(parsedXml, "/test/list/elem/text()")).isEqualTo("abc");
	assertThat(valueFromXPath(parsedXml,"/test/list/elem[2]/text()")).isEqualTo("def");
	assertThat(valueFromXPath(parsedXml, "/test/duck/text()")).matches("[0-9]\{3}");
	assertThat(nodeFromXPath(parsedXml, "/test/duck/xxx")).isNull();
	assertThat(valueFromXPath(parsedXml, "/test/alpha/text()")).matches("[\\p\{L}]*");
	assertThat(valueFromXPath(parsedXml, "/test/*/complex/text()")).isEqualTo("foo");
	assertThat(valueFromXPath(parsedXml, "/test/duck/@type")).isEqualTo("xtype");
	}
```

#### XML Support for Namespaces

XML 네임스페이스를 지원한다. 단, XPath 표현식에서 네임스페이스에 속한 컨텐츠를 선택하려면, 표현식도 수정이 필요하다.

네임스페이스를 사용하고 있는 아래 XML 문서를 살펴보자:

```xml
<ns1:customer xmlns:ns1="http://demo.com/customer">
    <email>customer@test.com</email>
</ns1:customer>
```

XPath 표현식으로 이메일 주소를 나타내려면 `/ns1:customer/email/text()`와 같이 작성해야 한다.

> `/customer/email/text()`와 같이 표현식에서 네임스페이스 프리픽스를 생략하면<sup>unqualified namespace</sup> `""`에 매핑되므로 주의해야 한다.

네임스페이스 프리픽스를 생략한 XML 내 요소를 선택하는 경우<sup>unqualified namespace</sup>, 표현식이 더 복잡해진다. 아래 XML 문서로 예를 들면:

```xml
<customer xmlns="http://demo.com/customer">
    <email>customer@test.com</email>
</customer>
```

이제 이메일 주소를 선택하기 위한  XPath 표현식은 다음과 같다:

```none
*/[local-name()='customer' and namespace-uri()='http://demo.com/customer']/*[local-name()='email']/text()
```

> 네임스페이스 프리픽스를 표기하지 않으면<sup>unqualified namespace</sup> (`/customer/email/text()` 또는 `*/[local-name()='customer' and namespace-uri()='http://demo.com/customer']/email/text()`) `""`에 매핑되므로 주의해라. 하위 요소도 `local-name`을 사용해서 참조해야 한다.

##### 네임스페이스 내 노드를 위한 일반적인 표현식 가이드

- 네임스페이스 프리픽스를 선언한<sup>qualified namespace</sup> 노드:

```none
/<node-name>
```

- 네임스페이스를 정의한 노드에서 네임스페이스 프리픽스를 생략하는 경우<sup>unqualified namespace</sup>:

```none
/*[local-name=()='<node-name>' and namespace-uri=()='<namespace-uri>']
```

> 상황에 따라 `namespace_uri` 부분을 생략할 수 있지만 오히려 모호해질 수도 있다.

- 네임스페이스 프리픽스를 생략하는 경우<sup>unqualified namespace</sup> (상위<sup>ancestor</sup> 노드 중 하나가 xmlns 요소를 정의함):

```none
/*[local-name=()='<node-name>']
```

### 3.2.5. Asynchronous Support

서버 측에서 비동기 통신을 사용하는 경우 (컨트롤러에서 `Callable`, `DeferredResult` 등을 반환하는 경우), 명세<sup>contract</sup>의 `response` 섹션에 `async()` 메소드를 제공해야 한다. 다음 예시를 참고해라:

<div class="switch-language-wrapper groovy yaml java kotlin">
<span class="switch-language groovy">Groovy</span>
<span class="switch-language yaml">YAML</span>
<span class="switch-language java">Java</span>
<span class="switch-language kotlin">Kotlin</span>
</div>
<div class="language-only-for-groovy groovy yaml java kotlin"></div>
```groovy
org.springframework.cloud.contract.spec.Contract.make {
    request {
        method GET()
        url '/get'
    }
    response {
        status OK()
        body 'Passed'
        async()
    }
}
```
<div class="language-only-for-yaml groovy yaml java kotlin"></div>
```yml
response:
    async: true
```
<div class="language-only-for-java groovy yaml java kotlin"></div>
```java
class contract implements Supplier<Collection<Contract>> {

	@Override
	public Collection<Contract> get() {
		return Collections.singletonList(Contract.make(c -> {
			c.request(r -> {
				// ...
			});
			c.response(r -> {
				r.async();
				// ...
			});
		}));
	}

}
```
<div class="language-only-for-kotlin groovy yaml java kotlin"></div>
```kotlin
import org.springframework.cloud.contract.spec.ContractDsl.Companion.contract

contract {
    request {
        // ...
    }
    response {
        async = true
        // ...
    }
}
```

스텁<sup>stub</sup>에 지연 시간을 추가하려면 `fixedDelayMilliseconds` 메소드 혹은 프로퍼티를 사용하면 된다. 사용 방법은 아래 예시를 참고해라:

<div class="switch-language-wrapper groovy yaml java kotlin">
<span class="switch-language groovy">Groovy</span>
<span class="switch-language yaml">YAML</span>
<span class="switch-language java">Java</span>
<span class="switch-language kotlin">Kotlin</span>
</div>
<div class="language-only-for-groovy groovy yaml java kotlin"></div>
```groovy
org.springframework.cloud.contract.spec.Contract.make {
    request {
        method GET()
        url '/get'
    }
    response {
        status 200
        body 'Passed'
        fixedDelayMilliseconds 1000
    }
}
```
<div class="language-only-for-yaml groovy yaml java kotlin"></div>
```yml
response:
    fixedDelayMilliseconds: 1000
```
<div class="language-only-for-java groovy yaml java kotlin"></div>
```java
class contract implements Supplier<Collection<Contract>> {

	@Override
	public Collection<Contract> get() {
		return Collections.singletonList(Contract.make(c -> {
			c.request(r -> {
				// ...
			});
			c.response(r -> {
				r.fixedDelayMilliseconds(1000);
				// ...
			});
		}));
	}

}
```
<div class="language-only-for-kotlin groovy yaml java kotlin"></div>
```kotlin
import org.springframework.cloud.contract.spec.ContractDsl.Companion.contract

contract {
    request {
        // ...
    }
    response {
        delay = fixedMilliseconds(1000)
        // ...
    }
}
```