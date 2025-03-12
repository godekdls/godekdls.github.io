---
title: 3.1. Contract DSL
category: Spring Cloud Contract
order: 14
permalink: /Spring%20Cloud%20Contract/features-contract/
description: 컨트랙트 정의를 위한 DSL
image: ./../../images/springcloud/logo.jpeg
lastmod: 2025-03-12T23:34:00+09:00
comments: true
originalRefName: 스프링 클라우드 컨트랙트
originalRefLink: https://docs.spring.io/spring-cloud-contract/reference/4.2.0/project-features-contract.html
parent: Spring Cloud Contract Features
parentUrl: /Spring%20Cloud%20Contract/features/
subparent: 3.1. Contract DSL
subparentNavTitle: Contract DSL
isSubparent: true
subparentUrl: /Spring%20Cloud%20Contract/features-contract/
---
<script>defaultLanguages = ['groovy', 'maven']</script>

---

Spring Cloud Contract에선 다음과 같은 언어로 DSL을 작성할 수 있다:

- Groovy
- YAML
- Java
- Kotlin

> Spring Cloud Contract를 사용하면 하나의 파일에 여러 개의 명세<sup>contract</sup>를 정의할 수 있다 (Groovy에서는 단일 명세<sup>contract</sup>가 아닌 리스트를 반환한다).

다음은 명세<sup>contract</sup>를 정의하는 예시다:

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
		method 'PUT'
		url '/api/12'
		headers {
			header 'Content-Type': 'application/vnd.org.springframework.cloud.contract.verifier.twitter-places-analyzer.v1+json'
		}
		body '''\
	[{
		"created_at": "Sat Jul 26 09:38:57 +0000 2014",
		"id": 492967299297845248,
		"id_str": "492967299297845248",
		"text": "Gonna see you at Warsaw",
		"place":
		{
			"attributes":{},
			"bounding_box":
			{
				"coordinates":
					[[
						[-77.119759,38.791645],
						[-76.909393,38.791645],
						[-76.909393,38.995548],
						[-77.119759,38.995548]
					]],
				"type":"Polygon"
			},
			"country":"United States",
			"country_code":"US",
			"full_name":"Washington, DC",
			"id":"01fbe706f872cb32",
			"name":"Washington",
			"place_type":"city",
			"url": "https://api.twitter.com/1/geo/id/01fbe706f872cb32.json"
		}
	}]
'''
	}
	response {
		status OK()
	}
}
```
<div class="language-only-for-yaml groovy yaml java kotlin"></div>
```yml
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
import java.util.Collection;
import java.util.Collections;
import java.util.function.Supplier;

import org.springframework.cloud.contract.spec.Contract;
import org.springframework.cloud.contract.verifier.util.ContractVerifierUtil;

class contract_rest implements Supplier<Collection<Contract>> {

	@Override
	public Collection<Contract> get() {
		return Collections.singletonList(Contract.make(c -> {
			c.description("Some description");
			c.name("some name");
			c.priority(8);
			c.ignored();
			c.request(r -> {
				r.url("/foo", u -> {
					u.queryParameters(q -> {
						q.parameter("a", "b");
						q.parameter("b", "c");
					});
				});
				r.method(r.PUT());
				r.headers(h -> {
					h.header("foo", r.value(r.client(r.regex("bar")), r.server("bar")));
					h.header("fooReq", "baz");
				});
				r.body(ContractVerifierUtil.map().entry("foo", "bar"));
				r.bodyMatchers(m -> {
					m.jsonPath("$.foo", m.byRegex("bar"));
				});
			});
			c.response(r -> {
				r.fixedDelayMilliseconds(1000);
				r.status(r.OK());
				r.headers(h -> {
					h.header("foo2", r.value(r.server(r.regex("bar")), r.client("bar")));
					h.header("foo3", r.value(r.server(r.execute("andMeToo($it)")), r.client("foo33")));
					h.header("fooRes", "baz");
				});
				r.body(ContractVerifierUtil.map().entry("foo2", "bar").entry("foo3", "baz").entry("nullValue", null));
				r.bodyMatchers(m -> {
					m.jsonPath("$.foo2", m.byRegex("bar"));
					m.jsonPath("$.foo3", m.byCommand("executeMe($it)"));
					m.jsonPath("$.nullValue", m.byNull());
				});
			});
		}));
	}

}
```
<div class="language-only-for-kotlin groovy yaml java kotlin"></div>
```kotlin
import org.springframework.cloud.contract.spec.ContractDsl.Companion.contract
import org.springframework.cloud.contract.spec.withQueryParameters

contract {
	name = "some name"
	description = "Some description"
	priority = 8
	ignored = true
	request {
		url = url("/foo") withQueryParameters  {
			parameter("a", "b")
			parameter("b", "c")
		}
		method = PUT
		headers {
			header("foo", value(client(regex("bar")), server("bar")))
			header("fooReq", "baz")
		}
		body = body(mapOf("foo" to "bar"))
		bodyMatchers {
			jsonPath("$.foo", byRegex("bar"))
		}
	}
	response {
		delay = fixedMilliseconds(1000)
		status = OK
		headers {
			header("foo2", value(server(regex("bar")), client("bar")))
			header("foo3", value(server(execute("andMeToo(\$it)")), client("foo33")))
			header("fooRes", "baz")
		}
		body = body(mapOf(
				"foo" to "bar",
				"foo3" to "baz",
				"nullValue" to null
		))
		bodyMatchers {
			jsonPath("$.foo2", byRegex("bar"))
			jsonPath("$.foo3", byCommand("executeMe(\$it)"))
			jsonPath("$.nullValue", byNull)
		}
	}
}
```

> 메이븐에서는 다음 명령어를 사용하면 명세<sup>contract</sup>를 스텁<sup>stub</sup> 매핑 정보로 컴파일할 수 있다:
> 
> ```sh
> mvn org.springframework.cloud:spring-cloud-contract-maven-plugin:convert
> ```

### 목차

- [3.1.1. Groovy로 작성하는 Contract DSL](#311-contract-dsl-in-groovy)
- [3.1.2. Java로 작성하는 Contract DSL](#312-contract-dsl-in-java)
- [3.1.3. Kotlin으로 작성하는 Contract DSL](#313-contract-dsl-in-kotlin)
- [3.1.4. YAML로 작성하는 Contract DSL](#314-contract-dsl-in-yaml)
- [3.1.5. 제약](#315-limitations)
- [3.1.6 파일 하나에 Contract 여러 개 정의하기](#316-multiple-contracts-in-one-file)
- [3.1.7. 상태를 가진<sup>stateful</sup> Contract](#317-stateful-contracts)

---

## 3.1.1. Contract DSL in Groovy

Groovy에 익숙하지 않더라도 걱정할 필요 없다. Groovy DSL 파일에서도 Java 문법을 그대로 사용할 수 있다.

Groovy로 명세<sup>contract</sup>를 작성하기로 결정했다면, Groovy를 사용해 본 적이 없더라도 염려하지 않아도 된다. Contract DSL에선 리터럴, 메소드 호출, 클로저 등 극히 일부 문법만 사용하기 때문에, 언어에 대한 지식은 딱히 필요하지 않다. 게다가 DSL에선 정적인 타입을 사용하기 때문에, DSL 자체에 대한 지식이 전혀 없더라도 개발자라면 충분히 이해할 수 있는 수준이다.

> Groovy 명세<sup>contract</sup> 파일 안에서 `Contract`를 사용할 땐, 클래스의  풀 네임<sup>fully qualified name</sup>을 제공하고  `org.springframework.cloud.spec.Contract.make { … }`와 같이 `make` 메소드를 static 임포트를 해야 한다는 점을 기억해두자. 아니면 `Contract` 클래스를 임포트한 다음 (`import org.springframework.cloud.spec.Contract`), `Contract.make { … }`를 호출해도 좋다.

---

## 3.1.2. Contract DSL in Java

Java로 명세<sup>contract</sup>를 정의할 때는, 단일 명세<sup>contract</sup>는 `Supplier<Contract>` 인터페이스를, 여러 개의 명세<sup>contract</sup>는 `Supplier<Collection<Contract>>`를 구현한 클래스를 만들어야 한다.

`src/test/java` 밑에 명세<sup>contract</sup>를 정의하면 (예를 들면 `src/test/java/contracts`), 프로젝트의 클래스패스를 수정하지 않아도 된다. 이 경우 Spring Cloud Contract 플러그인에 명세<sup>contract</sup>를 정의할 위치를 새로 지정해야 한다.

아래 있는 메이븐, 그래들 예시 모두 `src/test/java` 경로에 명세<sup>contract</sup>를 정의한다:

<div class="switch-language-wrapper maven gradle">
<span class="switch-language maven">Maven</span>
<span class="switch-language gradle">Gradle</span>
</div>
<div class="language-only-for-maven maven gradle"></div>
```xml
<plugin>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-contract-maven-plugin</artifactId>
    <version>${spring-cloud-contract.version}</version>
    <extensions>true</extensions>
    <configuration>
        <contractsDirectory>src/test/java/contracts</contractsDirectory>
    </configuration>
</plugin>
```
<div class="language-only-for-gradle maven gradle"></div>
```groovy
contracts {
	contractsDslDir = new File(project.rootDir, "src/test/java/contracts")
}
```
---

## 3.1.3. Contract DSL in Kotlin

코틀린으로 명세<sup>contract</sup>를 작성하려면 코틀린 스크립트 파일(`.kts`)을 따로 만들어야 한다. Java DSL과 마찬가지로 원하는 경로에 명세<sup>contract</sup>를 추가하면 된다. 기본적으로 메이븐 플러그인은 `src/test/resources/contracts` 디렉토리에서, Gradle 플러그인은 `src/contractTest/resources/contracts` 디렉토리에서 명세<sup>contract</sup>를 찾는다.

> 그래들 플러그인은 3.0.0 버전부터 마이그레이션을 고려해 레거시 디렉토리인 `src/test/resources/contracts`도 함께 조회한다. 빌드 시 이 디렉토리에서 명세<sup>contract</sup>를 발견하면 warning 로그가 남게된다.

프로젝트의 플러그인 설정에 `spring-cloud-contract-spec-kotlin` 의존성을 명시해야 한다. 다음은 메이븐과 그래들을 사용한 예시다:

<div class="switch-language-wrapper maven gradle">
<span class="switch-language maven">Maven</span>
<span class="switch-language gradle">Gradle</span>
</div>
<div class="language-only-for-maven maven gradle"></div>
```xml
<plugin>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-contract-maven-plugin</artifactId>
    <version>${spring-cloud-contract.version}</version>
    <extensions>true</extensions>
    <configuration>
        <!-- some config -->
    </configuration>
    <dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-contract-spec-kotlin</artifactId>
            <version>${spring-cloud-contract.version}</version>
        </dependency>
    </dependencies>
</plugin>

<dependencies>
        <!-- Remember to add this for the DSL support in the IDE and on the consumer side -->
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-contract-spec-kotlin</artifactId>
            <scope>test</scope>
        </dependency>
</dependencies>
```
<div class="language-only-for-gradle maven gradle"></div>
```groovy
buildscript {
    repositories {
        // ...
    }
	dependencies {
		classpath "org.springframework.cloud:spring-cloud-contract-gradle-plugin:$\{scContractVersion}"
	}
}

dependencies {
    // ...

    // Remember to add this for the DSL support in the IDE and on the consumer side
    testImplementation "org.springframework.cloud:spring-cloud-contract-spec-kotlin"
    // Kotlin versions are very particular down to the patch version. The <kotlin_version> needs to be the same as you have imported for your project.
    testImplementation "org.jetbrains.kotlin:kotlin-scripting-compiler-embeddable:<kotlin_version>"
}
```

> Kotlin Script 파일 안에서 `ContractDSL`을 사용할 땐, 클래스의  풀 네임<sup>fully qualified name</sup>을 제공해야 한다는 점을 기억해두자. `contract` 함수는 보통 `org.springframework.cloud.contract.spec.ContractDsl.contract { … }`와 같이 사용한다. 아니면 `contract` 함수를 임포트한 다음 (`import org.springframework.cloud.contract.spec.ContractDsl.Companion.contract`) `contract { … }`를 호출해도 된다.

---

## 3.1.4. Contract DSL in YAML

YAML 명세<sup>contract</sup>의 스키마는 [YML 스키마](../yml-schema) 페이지에서 확인하면 된다.

---

## 3.1.5. Limitations

> JSON 배열의 사이즈 검증 기능은 아직 실험 단계다. 이 기능을 사용하려면 시스템 프로퍼티 `spring.cloud.contract.verifier.assert.size`의 값을 `true`로 설정해라. 기본값은 `false`다. 아니면 플러그인 설정에서 `assertJsonSize` 프로퍼티를 수정할 수도 있다.

> JSON 구조는 어떤 형태든 될 수 있기 때문에, Groovy DSL에서 `GString`의 `value(consumer(...), producer(...))` 표기법을 사용하면 제대로 파싱되지 않을 수 있다. 그렇기 때문에 Groovy Map 표기법을 사용하는 것 이 좋다.

---

## 3.1.6. Multiple Contracts in One File

하나의 파일에 여러 개의 명세<sup>contract</sup>를 정의하는 것도 가능하다. 다음과 같이 작성하면 된다:

<div class="switch-language-wrapper groovy yaml java kotlin">
<span class="switch-language groovy">Groovy</span>
<span class="switch-language yaml">YAML</span>
<span class="switch-language java">JAVA</span>
<span class="switch-language kotlin">Kotlin</span>
</div>
<div class="language-only-for-groovy groovy yaml java kotlin"></div>
```groovy
import org.springframework.cloud.contract.spec.Contract

[
	Contract.make {
		name("should post a user")
		request {
			method 'POST'
			url('/users/1')
		}
		response {
			status OK()
		}
	},
	Contract.make {
		request {
			method 'POST'
			url('/users/2')
		}
		response {
			status OK()
		}
	}
]
```
<div class="language-only-for-yaml groovy yaml java kotlin"></div>
```yaml
---
name: should post a user
request:
  method: POST
  url: /users/1
response:
  status: 200
---
request:
  method: POST
  url: /users/2
response:
  status: 200
---
request:
  method: POST
  url: /users/3
response:
  status: 200
```
<div class="language-only-for-java groovy yaml java kotlin"></div>
```java
class contract implements Supplier<Collection<Contract>> {

	@Override
	public Collection<Contract> get() {
		return Arrays.asList(
            Contract.make(c -> {
            	c.name("should post a user");
                // ...
            }), Contract.make(c -> {
                // ...
            }), Contract.make(c -> {
                // ...
            })
		);
	}

}
```
<div class="language-only-for-kotlin groovy yaml java kotlin"></div>
```kotlin
import org.springframework.cloud.contract.spec.ContractDsl.Companion.contract

arrayOf(
    contract {
        name("should post a user")
        // ...
    },
    contract {
        // ...
    },
    contract {
        // ...
    }
}
```

위 예시에는 `name` 필드를 사용한 명세<sup>contract</sup>와 그렇지 않은 명세<sup>contract</sup>가 하나씩 있다. 이때는 두 개의 테스트가 만들어지게 된다:

```java
import com.example.TestBase;
import com.jayway.jsonpath.DocumentContext;
import com.jayway.jsonpath.JsonPath;
import com.jayway.restassured.module.mockmvc.specification.MockMvcRequestSpecification;
import com.jayway.restassured.response.ResponseOptions;
import org.junit.Test;

import static com.jayway.restassured.module.mockmvc.RestAssuredMockMvc.*;
import static com.toomuchcoding.jsonassert.JsonAssertion.assertThatJson;
import static org.assertj.core.api.Assertions.assertThat;

public class V1Test extends TestBase {

	@Test
	public void validate_should_post_a_user() throws Exception {
		// given:
			MockMvcRequestSpecification request = given();

		// when:
			ResponseOptions response = given().spec(request)
					.post("/users/1");

		// then:
			assertThat(response.statusCode()).isEqualTo(200);
	}

	@Test
	public void validate_withList_1() throws Exception {
		// given:
			MockMvcRequestSpecification request = given();

		// when:
			ResponseOptions response = given().spec(request)
					.post("/users/2");

		// then:
			assertThat(response.statusCode()).isEqualTo(200);
	}

}
```

`name` 필드가 있는 명세<sup>contract</sup>의 경우 `validate_should_post_a_user`라는 테스트 메소드가 만들어진다. `name` 필드가 없는 쪽은 `validate_withList_1`이다. 이는 `WithList.groovy` 파일의 이름과 명세<sup>contract</sup> 목록에서의 인덱스에서 따온 이름이다.

마찬가지로, 다음과 같은 스텁<sup>stub</sup>이 생성된다:

```none
should post a user.json
1_WithList.json
```

첫 번째 파일명은 명세<sup>contract</sup>에 있는 `name` 파라미터에서 따왔다. 두 번째 파일은 명세<sup>contract</sup> 파일 이름(`WithList.groovy`) 앞에 인덱스를 붙인 것을 확인할 수 있다 (파일 내 명세<sup>contract</sup> 목록에서 인덱스가 `1`인 명세<sup>contract</sup>).

> 명세<sup>contract</sup>에 이름을 지정하면 어떤 테스트인지 쉽게 파악할 수 있어 훨씬 더 좋다.

---

## 3.1.7. Stateful Contracts

상태 저장 명세<sup>stateful contract</sup>(시나리오라고도 부른다)는 순서대로 읽어야 하는 명세<sup>contract</sup> 정의다. 이는 다음과 같은 상황에서 유용할 수 있다:

- Spring Cloud Contract를 사용해 상태를 가진<sup>stateful</sup> 애플리케이션을 테스트할 때, 정확하게 정의한 순서대로 명세<sup>contract</sup>를 호출하고 싶은 경우

  > 명세<sup>contract</sup> 테스트는 상태가 없는 것<sup>stateless</sup>이 좋기 때문에, 추천하지는 않는다.

- 동일한 엔드포인트에서 동일한 요청에 대해, 서로 다른 결과를 반환하기를 원하는 경우

상태 저장 명세<sup>stateful contract</sup>(또는 시나리오)를 만들려면, 네이밍 컨벤션을 지켜야 한다. 즉, 순번 뒤에 언더스코어를 달아줘야 한다. 이는 YAML이든 Groovy든 관계없이 동일하다. 예시는 다음을 참고해라:

```none
my_contracts_dir\
  scenario1\
    1_login.groovy
    2_showCart.groovy
    3_logout.groovy
```

이 구조에서 Spring Cloud Contract Verifier는 `scenario1`이라는 WireMock 시나리오를 생성하고 다음 세 단계를 수행한다:

1. `login`을 `Started`로 마킹한다. (다음을 가리키는...)
2. `showCart`를 `Step1`으로 마킹한다.  (다음을 가리키는...)
3. `logout`을 (시나리오를 종료하는) `Step2`로 마킹한다.

WireMock 시나리오에 대한 자세한 내용은 [여기](https://wiremock.org/docs/stateful-behaviour/)를 참고해라.