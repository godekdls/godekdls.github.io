---
title: 3.1.8. Common Top-Level Elements
navTitle: Common Top-Level Elements
category: Spring Cloud Contract
order: 15
permalink: /Spring%20Cloud%20Contract/common-top-elements/
description: Contract DSL 최상위 요소들
image: ./../../images/springcloud/logo.jpeg
lastmod: 2025-03-12T23:34:00+09:00
comments: true
originalRefName: 스프링 클라우드 컨트랙트
originalRefLink: https://docs.spring.io/spring-cloud-contract/reference/4.2.0/project-features-contract/common-top-elements.html
parent: Spring Cloud Contract Features
parentUrl: /Spring%20Cloud%20Contract/features/
subparent: 3.1. Contract DSL
subparentNavTitle: Contract DSL
subparentUrl: /Spring%20Cloud%20Contract/features-contract/
---
<script>defaultLanguages = ['groovy']</script>

이번에는 최상위 레벨에 정의하는 요소 중 가장 많이 사용하는 것들을 설명한다:

- [description](#description)
- [이름](#name)
- [Contract 무시하기](#ignoring-contracts)
- [아직 완료되지 않은<sup>in progress</sup> Contract](#contracts-in-progress)
- [파일에 있는 값 가져오기](#passing-values-from-files)
- [메타데이터](#metadata)

### Description

명세<sup>contract</sup>에 `description`을 추가할 수 있다. description은 임의의 텍스트다. 다음 예시를 참고해라:

<div class="switch-language-wrapper groovy yaml java kotlin">
<span class="switch-language groovy">Groovy</span>
<span class="switch-language yaml">YAML</span>
<span class="switch-language java">Java</span>
<span class="switch-language kotlin">Kotlin</span>
</div>
<div class="language-only-for-groovy groovy yaml java kotlin"></div>
```groovy
			org.springframework.cloud.contract.spec.Contract.make {
				description('''
given:
	An input
when:
	Sth happens
then:
	Output
''')
			}
```
<div class="language-only-for-yaml groovy yaml java kotlin"></div>
```yaml
description: Some description
name: some name
priority: 8
ignored: true
request:
  url: /foo
  queryParameters:
    a: b
    b: c
  method: PUT
  headers:
    foo: bar
    fooReq: baz
  body:
    foo: bar
  matchers:
    body:
      - path: $.foo
        type: by_regex
        value: bar
    headers:
      - key: foo
        regex: bar
response:
  status: 200
  headers:
    foo2: bar
    foo3: foo33
    fooRes: baz
  body:
    foo2: bar
    foo3: baz
    nullValue: null
  matchers:
    body:
      - path: $.foo2
        type: by_regex
        value: bar
      - path: $.foo3
        type: by_command
        value: executeMe($it)
      - path: $.nullValue
        type: by_null
        value: null
    headers:
      - key: foo2
        regex: bar
      - key: foo3
        command: andMeToo($it)
```
<div class="language-only-for-java groovy yaml java kotlin"></div>
```java
Contract.make(c -> {
	c.description("Some description");
}));
```
<div class="language-only-for-kotlin groovy yaml java kotlin"></div>
```kotlin
contract {
	description = """
given:
	An input
when:
	Sth happens
then:
	Output
"""
}
```

### Name

명세<sup>contract</sup>의 이름을 제공할 수 있다. `should register a user`라는 이름을 제공한다고 가정해보자. 이렇게 하면 `validate_should_register_a_user`라는 이름을 가진 테스트가 자동으로 만들어진다. 또한 WireMock의 스텁<sup>stub</sup> 이름은 `should_register_a_user.json`이 된다.

> 이름 때문에 자동 생성된 테스트 코드가 컴파일에 실패할 수 있으니 주의하자. 여러 명세<sup>contract</sup>에 같은 이름을 지정했을 때 역시 컴파일에 실패하며, 자동 생성된 스텁<sup>stub</sup>들이 서로를 덮어쓸 수 있다는 점을 기억해두자.

다음은 명세<sup>contract</sup>에 이름을 추가하는 방법을 보여주는 예시다:

<div class="switch-language-wrapper groovy yaml java kotlin">
<span class="switch-language groovy">Groovy</span>
<span class="switch-language yaml">YAML</span>
<span class="switch-language java">Java</span>
<span class="switch-language kotlin">Kotlin</span>
</div>
<div class="language-only-for-groovy groovy yaml java kotlin"></div>
```groovy
org.springframework.cloud.contract.spec.Contract.make {
	name("some_special_name")
}
```
<div class="language-only-for-yaml groovy yaml java kotlin"></div>
```yaml
name: some name
```
<div class="language-only-for-java groovy yaml java kotlin"></div>
```java
Contract.make(c -> {
	c.name("some name");
}));
```
<div class="language-only-for-kotlin groovy yaml java kotlin"></div>
```kotlin
contract {
	name = "some_special_name"
}
```

### Ignoring Contracts

특정 명세<sup>contract</sup>를 무시하고 싶다면, 플러그인 설정에 무시할 명세<sup>contract</sup>를 정의하거나, 컨트랙트 자체에 `ignored` 프로퍼티를 설정하면 된다. 그 방법은 아래 예시를 참고해라:

<div class="switch-language-wrapper groovy yaml java kotlin">
<span class="switch-language groovy">Groovy</span>
<span class="switch-language yaml">YAML</span>
<span class="switch-language java">Java</span>
<span class="switch-language kotlin">Kotlin</span>
</div>
<div class="language-only-for-groovy groovy yaml java kotlin"></div>
```groovy
org.springframework.cloud.contract.spec.Contract.make {
	ignored()
}
```
<div class="language-only-for-yaml groovy yaml java kotlin"></div>
```yaml
ignored: true
```
<div class="language-only-for-java groovy yaml java kotlin"></div>
```java
Contract.make(c -> {
	c.ignored();
}));
```
<div class="language-only-for-kotlin groovy yaml java kotlin"></div>
```kotlin
contract {
	ignored = true
}
```

### Contracts in Progress

명세<sup>contract</sup>를 아직 개발 중<sup>in progress</sup>인 것으로 마킹하면 프로듀서<sup>producer</sup> 측에서 테스트를 생성하지는 않지만 스텁<sup>stub</sup>은 생성할 수 있다.

> 실제로 구현이 완료되지 않은 상태에서 컨슈머<sup>consumer</sup>가 스텁<sup>stub</sup>을 사용할 수 있기 때문에 주의해서 사용해야 한다.

명세<sup>contract</sup>를 개발 중<sup>in progress</sup>으로 마킹하는 방법은 다음을 참고해라:

<div class="switch-language-wrapper groovy yaml java kotlin">
<span class="switch-language groovy">Groovy</span>
<span class="switch-language yaml">YAML</span>
<span class="switch-language java">Java</span>
<span class="switch-language kotlin">Kotlin</span>
</div>
<div class="language-only-for-groovy groovy yaml java kotlin"></div>
```groovy
org.springframework.cloud.contract.spec.Contract.make {
	inProgress()
}
```
<div class="language-only-for-yaml groovy yaml java kotlin"></div>
```yaml
inProgress: true
```
<div class="language-only-for-java groovy yaml java kotlin"></div>
```java
Contract.make(c -> {
	c.inProgress();
}));
```
<div class="language-only-for-kotlin groovy yaml java kotlin"></div>
```kotlin
contract {
	inProgress = true
}
```

Spring Cloud Contract 플러그인의 `failOnInProgress` 프로퍼티를 설정하면, 소스 코드에 아직 개발 중<sup>in progress</sup>인 명세<sup>contract</sup>가 하나라도 남아 있을 시 빌드가 중단되도록 만들 수 있다.

### Passing Values from Files

`1.2.0` 버전부터 파일에 있는 값을 불러와 사용할 수 있다. 프로젝트 내에 다음과 같은 리소스가 있다고 가정해보자:

```bash
└── src
    └── test
        └── resources
            └── contracts
                ├── readFromFile.groovy
                ├── request.json
                └── response.json
```

이어서 명세<sup>contract</sup>는 다음과 같다고 가정한다:

<div class="switch-language-wrapper groovy yaml java kotlin">
<span class="switch-language groovy">Groovy</span>
<span class="switch-language yaml">YAML</span>
<span class="switch-language java">Java</span>
<span class="switch-language kotlin">Kotlin</span>
</div>
<div class="language-only-for-groovy groovy yaml java kotlin"></div>
```groovy
/*
 * Copyright 2013-2020 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import org.springframework.cloud.contract.spec.Contract

Contract.make {
	request {
		method('PUT')
		headers {
			contentType(applicationJson())
		}
		body(file("request.json"))
		url("/1")
	}
	response {
		status OK()
		body(file("response.json"))
		headers {
			contentType(applicationJson())
		}
	}
}
```
<div class="language-only-for-yaml groovy yaml java kotlin"></div>
```yaml
request:
  method: GET
  url: /foo
  bodyFromFile: request.json
response:
  status: 200
  bodyFromFile: response.json
```
<div class="language-only-for-java groovy yaml java kotlin"></div>
```java
import java.util.Collection;
import java.util.Collections;
import java.util.function.Supplier;

import org.springframework.cloud.contract.spec.Contract;

class contract_rest_from_file implements Supplier<Collection<Contract>> {

	@Override
	public Collection<Contract> get() {
		return Collections.singletonList(Contract.make(c -> {
			c.request(r -> {
				r.url("/foo");
				r.method(r.GET());
				r.body(r.file("request.json"));
			});
			c.response(r -> {
				r.status(r.OK());
				r.body(r.file("response.json"));
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
		url = url("/1")
		method = PUT
		headers {
			contentType = APPLICATION_JSON
		}
		body = bodyFromFile("request.json")
	}
	response {
		status = OK
		body = bodyFromFile("response.json")
		headers {
			contentType = APPLICATION_JSON
		}
	}
}
```

JSON 파일은 다음과 같다:

*request.json*

```java
{
  "status": "REQUEST"
}
```

*response.json*

```java
{
  "status": "RESPONSE"
}
```

테스트나 스텁<sup>stub</sup>이 만들어질 땐 `request.json`, `response.json` 파일의 내용이 요청, 응답 body로 전달된다. 이때 파일명은, 명세<sup>contract</sup>가 있는 폴더를 기준으로 상대 경로를 작성해야 한다.

파일 내용을 바이너리 형식으로 전달해야 하는 경우, YAML의 `bodyFromFileAsBytes` 필드를 사용하거나, 그 외 DSL에선 `fileAsBytes` 메소드를 사용하면 된다.

다음은 바이너리 파일을 사용하는 예시다:

<div class="switch-language-wrapper groovy yaml java kotlin">
<span class="switch-language groovy">Groovy</span>
<span class="switch-language yaml">YAML</span>
<span class="switch-language java">Java</span>
<span class="switch-language kotlin">Kotlin</span>
</div>
<div class="language-only-for-groovy groovy yaml java kotlin"></div>
```groovy
import org.springframework.cloud.contract.spec.Contract

Contract.make {
	request {
		url("/1")
		method(PUT())
		headers {
			contentType(applicationOctetStream())
		}
		body(fileAsBytes("request.pdf"))
	}
	response {
		status 200
		body(fileAsBytes("response.pdf"))
		headers {
			contentType(applicationOctetStream())
		}
	}
}
```
<div class="language-only-for-yaml groovy yaml java kotlin"></div>
```yaml
request:
  url: /1
  method: PUT
  headers:
    Content-Type: application/octet-stream
  bodyFromFileAsBytes: request.pdf
response:
  status: 200
  bodyFromFileAsBytes: response.pdf
  headers:
    Content-Type: application/octet-stream
```
<div class="language-only-for-java groovy yaml java kotlin"></div>
```java
import java.util.Collection;
import java.util.Collections;
import java.util.function.Supplier;

import org.springframework.cloud.contract.spec.Contract;

class contract_rest_from_pdf implements Supplier<Collection<Contract>> {

	@Override
	public Collection<Contract> get() {
		return Collections.singletonList(Contract.make(c -> {
			c.request(r -> {
				r.url("/1");
				r.method(r.PUT());
				r.body(r.fileAsBytes("request.pdf"));
				r.headers(h -> {
					h.contentType(h.applicationOctetStream());
				});
			});
			c.response(r -> {
				r.status(r.OK());
				r.body(r.fileAsBytes("response.pdf"));
				r.headers(h -> {
					h.contentType(h.applicationOctetStream());
				});
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
		url = url("/1")
		method = PUT
		headers {
			contentType = APPLICATION_OCTET_STREAM
		}
		body = bodyFromFileAsBytes("contracts/request.pdf")
	}
	response {
		status = OK
		body = bodyFromFileAsBytes("contracts/response.pdf")
		headers {
			contentType = APPLICATION_OCTET_STREAM
		}
	}
}
```

> HTTP 요청을 처리하든 메시지를 처리하든, 둘 모두 바이너리 페이로드가 필요하다면 이 방식을 사용해야 한다.

### Metadata

명세<sup>contract</sup>에 `metadata`를 추가할 수 있다. 메타데이터를 이용하면 추가로 원하는 설정을 전달할 수 있다. 아래에 있는 예시는 `wiremock`을 키로 사용하고 있다. `wiremock` 키에 매핑된 값 역시 map인데, 이 map의 키는 `stubMapping`, 값은 WireMock의 `StubMapping` 객체다. Spring Cloud Contract는 스텁<sup>stub</sup>을 매핑할 때, 일부 정보를 커스텀 코드로 수정할 수 있도록 지원한다. 웹훅이나 커스텀 지연을 추가하거나, 써드 파티 WireMock 익스텐션과 통합할 때 유용하다.

<div class="switch-language-wrapper groovy yaml java kotlin">
<span class="switch-language groovy">groovy</span>
<span class="switch-language yaml">yaml</span>
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-groovy groovy yaml java kotlin"></div>
```groovy
Contract.make {
    request {
        method GET()
        url '/drunks'
    }
    response {
        status OK()
        body([
            count: 100
        ])
        headers {
            contentType("application/json")
        }
    }
    metadata([
        wiremock: [
            stubMapping: '''\
                {
                    "response" : {
                        "fixedDelayMilliseconds": 2000
                    }
                }
            '''
            ]
    ])
}
```
<div class="language-only-for-yaml groovy yaml java kotlin"></div>
```yaml
name: "should count all frauds"
request:
  method: GET
  url: /yamlfrauds
response:
  status: 200
  body:
    count: 200
  headers:
    Content-Type: application/json
metadata:
  wiremock:
    stubMapping: >
      {
        "response" : {
          "fixedDelayMilliseconds": 2000
        }
      }
```
<div class="language-only-for-java groovy yaml java kotlin"></div>
```java
Contract.make(c -> {
    c.metadata(MetadataUtil.map().entry("wiremock", ContractVerifierUtil.map().entry("stubMapping",
            "{ \"response\" : { \"fixedDelayMilliseconds\" : 2000 } }")));
}));
```
<div class="language-only-for-kotlin groovy yaml java kotlin"></div>
```kotlin
contract {
    metadata("wiremock" to ("stubmapping" to """
{
  "response" : {
    "fixedDelayMilliseconds": 2000
  }
}"""))
}
```

지원하는 메타데이터 항목은 이어지는 섹션에서 확인할 수 있다.
