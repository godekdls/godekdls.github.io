---
title: 8.2. WireMock Customization
navTitle: WireMock Customization
category: Spring Cloud Contract
order: 65
permalink: /Spring%20Cloud%20Contract/wiremock-customization/
description: WireMock을 커스텀해 스텁 서버 동작 변경하기
image: ./../../images/springcloud/logo.jpeg
lastmod: 2025-03-12T23:34:00+09:00
comments: true
originalRefName: 스프링 클라우드 컨트랙트
originalRefLink: https://docs.spring.io/spring-cloud-contract/reference/4.2.0/customization/wiremock-customization.html
parent: Spring Cloud Contract customization
parentUrl: /Spring%20Cloud%20Contract/advanced/
---

---

이번 섹션에선 [WireMock](https://wiremock.org/)의 동작 방식을 커스텀하는 방법을 설명한다.

### 목차

- [8.2.1. 자체 WireMock 익스텐션 등록하기](#821-registering-your-own-wiremock-extension)
- [8.2.2. WireMock 설정 커스텀하기](#822-customization-of-wiremock-configuration)
- [8.2.3. 메타데이터로 WireMock 커스텀하기](#823-customization-of-wiremock-via-metadata)
- [8.2.4. 메타데이터와 커스텀 프로세서로 WireMock 커스텀하기](#824-customization-of-wiremock-via-metadata-and-a-custom-processor)

### 8.2.1. Registering Your Own WireMock Extension

WireMock을 사용할 땐 커스텀 익스텐션을 등록할 수 있다. Spring Cloud Contract는 기본적으로 응답에서 요청을 참조할 수 있게 해주는 트랜스포머를 등록한다. 자체 익스텐션을 사용하고 싶다면, `org.springframework.cloud.contract.verifier.dsl.wiremock.WireMockExtensions` 인터페이스의 구현체를 등록하면 된다. 익스텐션을 적용할 땐 `spring.factories`를 활용하므로, `META-INF/spring.factories` 파일에 다음과 같은 설정을 추가해줘야 한다:

```sh
org.springframework.cloud.contract.verifier.dsl.wiremock.WireMockExtensions=\
org.springframework.cloud.contract.stubrunner.provider.wiremock.TestWireMockExtensions
org.springframework.cloud.contract.spec.ContractConverter=\
org.springframework.cloud.contract.stubrunner.TestCustomYamlContractConverter
```

다음은 커스텀 익스텐션 예시다:

*Example 3. TestWireMockExtensions.groovy*

```groovy
import com.github.tomakehurst.wiremock.extension.Extension

/**
 * Extension that registers the default transformer and the custom one
 */
class TestWireMockExtensions implements WireMockExtensions {
	@Override
	List<Extension> extensions() {
		return [
				new DefaultResponseTransformer(),
				new CustomExtension()
		]
	}
}

class CustomExtension implements Extension {

	@Override
	String getName() {
		return "foo-transformer"
	}
}
```

> 원하는 곳에만 변환 로직을 적용하려면 `applyGlobally()` 메소드를 재정의해 `false`로 설정해라.

### 8.2.2. Customization of WireMock Configuration

`org.springframework.cloud.contract.wiremock.WireMockConfigurationCustomizer` 타입 빈을 등록하면 WireMock 설정을 커스텀 수 있다 (예를 들면 커스텀 트랜스포머를 추가할 수 있다). 다음 예제를 참고해라:

```java
		@Bean
		WireMockConfigurationCustomizer optionsCustomizer() {
			return new WireMockConfigurationCustomizer() {
				@Override
				public void customize(WireMockConfiguration options) {
// perform your customization here
				}
			};
		}
```

### 8.2.3. Customization of WireMock via Metadata

3.0.0 버전에서는 명세<sup>contract</sup>에 `metadata`를 설정할 수 있다. `wiremock` 키 아래에, WireMock의 유효한 `StubMapping` JSON/map이나 실제 `StubMapping` 객체를 설정하면, Spring Cloud Contract는 스텁<sup>stub</sup>을 커스텀 정의에 맞게 수정한다. 다음 예제를 살펴보자

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

`metadata` 섹션을 보면, `wiremock` 키 아래에 스텁<sup>stub</sup>의 지연을 추가하는 JSON `StubMapping` 항목을 정의했다. 이렇게 작성하면, WireMock JSON 스텁<sup>stub</sup>은 다음과 같이 병합된다.

```json
{
  "id" : "ebae49e2-a2a3-490c-a57f-ba28e26b81ea",
  "request" : {
    "url" : "/yamlfrauds",
    "method" : "GET"
  },
  "response" : {
    "status" : 200,
    "body" : "{\"count\":200}",
    "headers" : {
      "Content-Type" : "application/json"
    },
    "fixedDelayMilliseconds" : 2000,
    "transformers" : [ "response-template" ]
  },
  "uuid" : "ebae49e2-a2a3-490c-a57f-ba28e26b81ea"
}
```

현재는 스텁<sup>stub</sup> 쪽만 조작할 수 있게 구현돼있다 (자동 생성 테스트는 변경하지 않는다). 또한 요청 전체와, 응답의 body 및 헤더는 변경하지 않는다.

### 8.2.4. Customization of WireMock via Metadata and a Custom Processor

WireMock의 `StubMapping` 후처리<sup>post processing</sup>를 커스텀하려면, `META-INF/spring.factories`에 `org.springframework.cloud.contract.verifier.converter.StubProcessor` 키로 스텁 프로세서의 자체 구현체를 등록하면 된다. 편의를 위한 WireMock 전용 인터페이스 `org.springframework.cloud.contract.verifier.wiremock.WireMockStubPostProcessor`도 제공하고 있다.

메소드 구현부에서는 현재 포스트 프로세서가 주어진 명세<sup>contract</sup>에 적용 가능한지와, 후처리<sup>post processing</sup>로 어떤 로직을 실행할지 Spring Cloud Contract에 알려줘야 한다.

> 컨슈머<sup>consumer</sup> 측에서 Stub Runner를 사용할 땐, 원하는 커스텀 익스텐션을 등록할 `HttpServerStubConfigurer` 구현체(e.g. `WireMockHttpServerStubConfigurer`를 상속한 구현체)를 전달해야 한다는 것을 기억해두자. 그렇지 않으면 클래스패스에 커스텀 WireMock 익스텐션이 있더라도 WireMock은 이를 인식하지 못하고, 지정한 익스텐션을 찾을 수 없다는 warning 로그를 출력한다.

