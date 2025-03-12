---
title: 3.6.3. Stub Runner Core
navTitle: Stub Runner Core
category: Spring Cloud Contract
order: 31
permalink: /Spring%20Cloud%20Contract/stub-runner-core/
description: Stub Runner의 핵심 기능과 사용 방법
image: ./../../images/springcloud/logo.jpeg
lastmod: 2025-03-12T23:34:00+09:00
comments: true
originalRefName: 스프링 클라우드 컨트랙트
originalRefLink: https://docs.spring.io/spring-cloud-contract/reference/4.2.0/project-features-stubrunner/stub-runner-core.html
parent: Spring Cloud Contract Features
parentUrl: /Spring%20Cloud%20Contract/features/
subparent: 3.6. Spring Cloud Contract Stub Runner
subparentNavTitle: Spring Cloud Contract Stub Runner
subparentUrl: /Spring%20Cloud%20Contract/features-stubrunner/
---
<script>defaultLanguages = ['maven']</script>

Stub Runner 코어는 연동 서비스를 위한 스텁<sup>stub</sup>을 실행해준다. 스텁<sup>stub</sup>을 단순한 테스트용 응답이 아닌 서비스 명세<sup>contract</sup>로 취급한다면, stub-runner를 이용해 [CDC<sup>Consumer-driven Contracts</sup>](https://martinfowler.com/articles/consumerDrivenContracts.html)를 실천할 수도 있다.

Stub Runner는 의존성으로 추가한 스텁<sup>stub</sup>을 자동으로 다운받고 (또는 클래스패스에서 가져온다), 적절한 스텁<sup>stub</sup> 정의를 사용해 WireMock 서버를 시작해준다. 메시지를 처리하는 경우 특별한 스텁<sup>stub</sup> 라우트를 정의해준다.

### 목차

- [Stub 가져오기](#retrieving-stubs)
  + [Stub 다운받기](#downloading-stubs)
  + [클래스패스 스캔하기](#classpath-scanning)
  + [HTTP Server Stub 설정하기](#configuring-http-server-stubs)
- [Stub 실행하기](#running-stubs)
  + [HTTP Stub](#http-stubs)
  + [등록된 매핑 정보 조회하기](#viewing-registered-mappings)
  + [메시지 처리 Stub](#messaging-stubs)

### Retrieving stubs

스텁<sup>stub</sup>은 다음과 같은 방법으로 가져올 수 있다:

- Artifactory나 Nexus에서 스텁<sup>stub</sup>이 포함된 JAR를 다운로드하는 Aether 기반 솔루션
- 클래스패스에서 패턴을 검색해 스텁<sup>stub</sup>을 찾는 클래스패스 스캔 솔루션
- `org.springframework.cloud.contract.stubrunner.StubDownloaderBuilder`를 직접 구현해 전부 커스텀하는 방법

마지막 방법의 경우 [커스텀 Stub Runner](../pluggable-architecture/#834-using-the-custom-stub-runner) 섹션에서 예제를 다루고 있다.

#### Downloading Stubs

스텁<sup>stub</sup>을 다운로드하는 방식은 `stubsMode` 스위치로 제어할 수 있다. 여기에는 `StubRunnerProperties.StubsMode` 값 중 하나를 지정한다. 다음과 같은 옵션을 사용할 수 있다:

- `StubRunnerProperties.StubsMode.CLASSPATH` (디폴트): 클래스패스에서 스텁<sup>stub</sup>을 가져온다
- `StubRunnerProperties.StubsMode.LOCAL`: 로컬 스토리지에서 스텁<sup>stub</sup>을 가져온다 (e.g. `.m2`)
- `StubRunnerProperties.StubsMode.REMOTE`: 리모트 스토리지에서 스텁<sup>stub</sup>을 가져온다

다음은 로컬에서 스텁<sup>stub</sup>을 가져오는 예시다:

```java
@AutoConfigureStubRunner(repositoryRoot="https://foo.bar", ids = "com.example:beer-api-producer:+:stubs:8095", stubsMode = StubRunnerProperties.StubsMode.LOCAL)
```

#### Classpath scanning

`stubsMode` 프로퍼티를 `StubRunnerProperties.StubsMode.CLASSPATH`로 설정하면 (`CLASSPATH`가 기본값이어서 아무것도 설정하지 않았을 때와 동일하다) 클래스패스를 스캔한다. 아래 예시를 참고해라:

```java
@AutoConfigureStubRunner(ids = {
    "com.example:beer-api-producer:+:stubs:8095",
    "com.example.foo:bar:1.0.0:superstubs:8096"
})
```

클래스패스에는 다음과 같이 의존성을 추가할 수 있다:

<div class="switch-language-wrapper maven gradle">
<span class="switch-language maven">Maven</span>
<span class="switch-language gradle">Gradle</span>
</div>
<div class="language-only-for-maven maven gradle"></div>
```xml
<dependency>
    <groupId>com.example</groupId>
    <artifactId>beer-api-producer-restdocs</artifactId>
    <classifier>stubs</classifier>
    <version>0.0.1-SNAPSHOT</version>
    <scope>test</scope>
    <exclusions>
        <exclusion>
            <groupId>*</groupId>
            <artifactId>*</artifactId>
        </exclusion>
    </exclusions>
</dependency>
<dependency>
    <groupId>com.example.thing1</groupId>
    <artifactId>thing2</artifactId>
    <classifier>superstubs</classifier>
    <version>1.0.0</version>
    <scope>test</scope>
    <exclusions>
        <exclusion>
            <groupId>*</groupId>
            <artifactId>*</artifactId>
        </exclusion>
    </exclusions>
</dependency>
```
<div class="language-only-for-gradle maven gradle"></div>
```groovy
testCompile("com.example:beer-api-producer-restdocs:0.0.1-SNAPSHOT:stubs") {
    transitive = false
}
testCompile("com.example.thing1:thing2:1.0.0:superstubs") {
    transitive = false
}
```

그러면 클래스패스에서 지정한 위치를 스캔한다. 예를 들어 `com.example:beer-api-producer-restdocs`의 경우, 다음과 같은 경로를 스캔한다:

- /META-INF/com.example/beer-api-producer-restdocs/\*\*/\*\.\*
- /contracts/com.example/beer-api-producer-restdocs/\*\*/\*\.\*
- /mappings/com.example/beer-api-producer-restdocs/\*\*/\*\.\*

`com.example.thing1:thing2`에선 아래 경로를 스캔한다:

- /META-INF/com.example.thing1/thing2/\*\*/\*\.\*
- /contracts/com.example.thing1/thing2/\*\*/\*\.\*
- /mappings/com.example.thing1/thing2/\*\*/\*\.\*

> 프로듀서<sup>producer</sup> 스텁<sup>stub</sup>을 패키징할 땐 그룹 ID와 아티팩트 ID를 명시해야 한다.

스텁<sup>stub</sup>을 적절히 패키징하려면, 프로듀서<sup>producer</sup>는 다음과 같은 구조로 명세<sup>contract</sup>를 세팅한다:

```bash
└── src
    └── test
        └── resources
            └── contracts
                └── com.example
                    └── beer-api-producer-restdocs
                        └── nested
                            └── contract3.groovy
```

[Maven `assembly` 플러그인](https://github.com/spring-cloud-samples/spring-cloud-contract-samples/blob/main/producer_with_restdocs/pom.xml)이나 [Gradle Jar](https://github.com/spring-cloud-samples/spring-cloud-contract-samples/blob/main/producer_with_restdocs/build.gradle) 태스크를 사용하려면, 스텁<sup>stub</sup> jar를 다음과 같은 구조로 생성해야 한다:

```bash
└── META-INF
    └── com.example
        └── beer-api-producer-restdocs
            └── 2.0.0
                ├── contracts
                │   └── nested
                │       └── contract2.groovy
                └── mappings
                    └── mapping.json
```

이 구조를 유지하면 아티팩트를 다운받을 필요 없이 클래스패스를 스캔해서 스텁<sup>stub</sup>으로 메시지나 HTTP 요청을 처리할 수 있다.

#### Configuring HTTP Server Stubs

Stub Runner에서는 `HttpServerStub`이란 인터페이스로 HTTP 서버의 기본적인 동작을 추상화한다 (WireMock은 구현체 중 하나다). 간혹 스텁<sup>stub</sup> 서버를 추가적으로 튜닝(주어진 상황에 맞게 구현)해야 하는 경우가 있다. Stub Runner는 이를 위한 `httpServerStubConfigurer` 프로퍼티를 제공한다. 이 프로퍼티는 어노테이션과 JUnit rule에서 사용할 수 있으며, 시스템 프로퍼티를 통해 액세스할 수 있다. 이곳에 `org.springframework.cloud.contract.stubrunner.HttpServerStubConfigurer` 인터페이스의 구현체를 제공하면 된다. 구현체에선 전달받은 HTTP 서버 스텁<sup>stub</sup>에 대한 설정 파일을 수정할 수 있다.

Spring Cloud Contract Stub Runner는 WireMock용으로 확장할 수 있는 구현체인 `org.springframework.cloud.contract.stubrunner.provider.wiremock.WireMockHttpServerStubConfigurer`를 기본으로 제공한다. `configure` 메소드에서 전달받은 스텁<sup>stub</sup>에 대한 커스텀 설정을 제공할 수 있다. 예를 들어 원하는 아티팩트 ID에 대해 HTTPS 포트에서 WireMock을 시작하는 식으로 활용할 수 있다. 그 방법은 다음 예제를 참고해라:

*Example 1. WireMockHttpServerStubConfigurer 구현체*

```java
@CompileStatic
static class HttpsForFraudDetection extends WireMockHttpServerStubConfigurer {

	private static final Log log = LogFactory.getLog(HttpsForFraudDetection)

	@Override
	WireMockConfiguration configure(WireMockConfiguration httpStubConfiguration, HttpServerStubConfiguration httpServerStubConfiguration) {
		if (httpServerStubConfiguration.stubConfiguration.artifactId == "fraudDetectionServer") {
			int httpsPort = TestSocketUtils.findAvailableTcpPort()
			log.info("Will set HTTPs port [" + httpsPort + "] for fraud detection server")
			return httpStubConfiguration
					.httpsPort(httpsPort)
		}
		return httpStubConfiguration
	}
}
```

이제 다음과 같이 `@AutoConfigureStubRunner` 어노테이션에서 이 클래스를 재사용할 수 있다:

```java
@AutoConfigureStubRunner(mappingsOutputFolder = "target/outputmappings/",
		httpServerStubConfigurer = HttpsForFraudDetection)
```

이제 HTTPS 포트를 발견하면 HTTP 포트보다 먼저 사용한다.

### Running stubs

이제 스텁<sup>stub</sup>을 실행하는 방법에 대해 설명한다. 여기서는 아래 세 가지 주제를 다룬다:

- [HTTP 스텁<sup>stub</sup>](#http-stubs)
- [등록된 매핑 정보 확인하기](#viewing-registered-mappings)
- [메시지 처리 스텁<sup>stub</sup>](#messaging-stubs)

#### HTTP Stubs

스텁<sup>stub</sup>은 JSON 문서로 정의하며, 문법은 [WireMock 문서](http://wiremock.org/stubbing.html)를 참고하면 된다.

다음은 JSON으로 스텁<sup>stub</sup>을 정의하는 예시다:

```json
{
    "request": {
        "method": "GET",
        "url": "/ping"
    },
    "response": {
        "status": 200,
        "body": "pong",
        "headers": {
            "Content-Type": "text/plain"
        }
    }
}
```

#### Viewing Registered Mappings

모든 스텁<sup>stub</sup>은 정의되어있는 매핑 정보를 `__/admin/` 엔드포인트로 노출한다.

`mappingsOutputFolder` 프로퍼티를 사용하면 매핑 정보를 파일에 저장할 수도 있다. 어노테이션을 사용한다면 다음과 같이 설정해주면 된다:

```java
@AutoConfigureStubRunner(ids="a.b.c:loanIssuance,a.b.c:fraudDetectionServer",
mappingsOutputFolder = "target/outputmappings/")
```

JUnit을 사용한다면 다음과 같이 설정한다:

```java
@ClassRule @Shared StubRunnerRule rule = new StubRunnerRule()
			.repoRoot("https://some_url")
			.downloadStub("a.b.c", "loanIssuance")
			.downloadStub("a.b.c:fraudDetectionServer")
			.withMappingsOutputFolder("target/outputmappings")
```

그런 다음 `target/outputmappings` 폴더를 확인해보면 다음과 같은 구조를 볼 수 있다;

```bash
.
├── fraudDetectionServer_13705
└── loanIssuance_12255
```

여기서는 두 개의 스텁<sup>stub</sup>이 등록됐다는 것을 알 수 있다. `fraudDetectionServer`는 `13705` 포트에, `loanIssuance`는 `12255` 포트에 등록됐다. 파일 하나를 열어보면, 해당 서버에서 사용하는 매핑 정보를 확인할 수 있다 (여기서는 WireMock 정보):

```json
[{
  "id" : "f9152eb9-bf77-4c38-8289-90be7d10d0d7",
  "request" : {
    "url" : "/name",
    "method" : "GET"
  },
  "response" : {
    "status" : 200,
    "body" : "fraudDetectionServer"
  },
  "uuid" : "f9152eb9-bf77-4c38-8289-90be7d10d0d7"
},
...
]
```

#### Messaging Stubs

추가한 Stub Runner 의존성과 DSL에 따라서 메시지 처리를 위한 라우트가 자동으로 세팅된다.