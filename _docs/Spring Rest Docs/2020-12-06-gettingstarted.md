---
title: Getting started
category: Spring REST Docs
order: 3
permalink: /Spring%20REST%20Docs/gettingstarted/
description: 스프링 REST Doc 시작하기 한글 번역
image: ./../../images/springrestdocs/logo.png
lastmod: 2020-12-06T12:00:00+09:00
comments: true
originalRefName: 스프링 REST Docs
originalRefLink: https://docs.spring.io/spring-restdocs/docs/2.0.5.RELEASE/reference/html5/#getting-started
---
<script>defaultLanguages = ['maven', 'mockmvc']</script>

### 목차

- [2.1. Sample Applications](#21-sample-applications)
- [2.2. Requirements](#22-requirements)
- [2.3. Build configuration](#23-build-configuration)
  + [2.3.1. Packaging the Documentation](#231-packaging-the-documentation)
- [2.4. Generating Documentation Snippets](#24-generating-documentation-snippets)
  + [2.4.1. Setting up Your Tests](#241-setting-up-your-tests)
    * [Setting up Your JUnit 4 Tests](#setting-up-your-junit-4-tests)
    * [Setting up Your JUnit 5 Tests](#setting-up-your-junit-5-tests)
    * [Setting up your tests without JUnit](#setting-up-your-tests-without-junit)
  + [2.4.2. Invoking the RESTful Service](#242-invoking-the-restful-service)
- [2.5. Using the Snippets](#25-using-the-snippets)

---

이번 섹션에서는 스프링 REST Doc을 시작하는 방법을 설명한다.

---

## 2.1. Sample Applications

곧바로 시작하고 싶다면, 다양한 샘플 어플리케이션이 준비되어 있다:

*Table 1. MockMvc*

| Sample                                                       | Build system | Description                                                  |
| :----------------------------------------------------------- | :----------- | :----------------------------------------------------------- |
| [Spring Data REST](https://github.com/spring-projects/spring-restdocs/tree/v2.0.5.RELEASE/samples/rest-notes-spring-data-rest) | Maven        | [Spring Data REST](https://projects.spring.io/spring-data-rest/)로 구현한 서비스를 활용해서 시작 가이드와 API 가이드를 만드는 방법을 설명한다. |
| [Spring HATEOAS](https://github.com/spring-projects/spring-restdocs/tree/v2.0.5.RELEASE/samples/rest-notes-spring-hateoas) | Gradle       | [Spring HATEOAS](https://projects.spring.io/spring-hateoas/)로 구현한 서비스를 활용해서 시작 가이드와 API 가이드를 만드는 방법을 설명한다. |


*Table 2. WebTestClient*

| Sample                                                       | Build system | Description                                                  |
| :----------------------------------------------------------- | :----------- | :----------------------------------------------------------- |
| [WebTestClient](https://github.com/spring-projects/spring-restdocs/tree/v2.0.5.RELEASE/samples/web-test-client) | Gradle       | 스프링 웹플럭스의 WebTestClient로 스프링 REST Doc을 활용하는 방법을 설명한다. |

*Table 3. REST Assured*

| Sample                                                       | Build system | Description                                                  |
| :----------------------------------------------------------- | :----------- | :----------------------------------------------------------- |
| [REST Assured](https://github.com/spring-projects/spring-restdocs/tree/v2.0.5.RELEASE/samples/rest-assured) | Gradle       | [REST Assured](http://rest-assured.io/)로 스프링 REST Doc을 활용하는 방법을 설명한다. |

*Table 4. Advanced*

| Sample                                                       | Build system | Description                                                  |
| :----------------------------------------------------------- | :----------- | :----------------------------------------------------------- |
| [Slate](https://github.com/spring-projects/spring-restdocs/tree/v2.0.5.RELEASE/samples/rest-notes-slate) | Gradle       | Markdown과 [Slate](https://github.com/tripit/slate)로 스프링 REST Doc을 활용하는 방법을 설명한다.. |
| [TestNG](https://github.com/spring-projects/spring-restdocs/tree/v2.0.5.RELEASE/samples/testng) | Gradle       | [TestNG](http://testng.org/)로 스프링 REST Doc을 활용하는 방법을 설명한다. |
| [JUnit 5](https://github.com/spring-projects/spring-restdocs/tree/v2.0.5.RELEASE/samples/junit5) | Gradle       | [JUnit 5](https://junit.org/junit5/)로 스프링 REST Doc을 활용하는 방법을 설명한다. |

---

## 2.2. Requirements

스프링 REST Doc은 최소한 다음과 같은 환경이 필요하다:

- 자바 8
- 스프링 프레임워크 5 (5.0.2 이상)

추가로 `spring-restdocs-restassured` 모듈은 REST Assured 3.0이 필요하다.

## 2.3. Build configuration

스프링 REST Doc을 사용하려면 가장 먼저 프로젝트 빌드 환경을 설정해야 한다. [Spring HATEOAS](https://github.com/spring-projects/spring-restdocs/tree/v2.0.5.RELEASE/samples/rest-notes-spring-hateoas)와 [Spring Data REST](https://github.com/spring-projects/spring-restdocs/tree/v2.0.5.RELEASE/samples/rest-notes-spring-data-rest) 샘플에는 각각 `build.gradle`과  `pom.xml` 파일이 있으니 함께 참고해라. 주요 설정 항목은 아래에서 설명한다:

<div class="switch-language-wrapper maven gradle">
<span class="switch-language maven">maven</span>
<span class="switch-language gradle">gradle</span>
</div>
<div class="language-only-for-maven maven gradle"></div>
```xml
<dependency> <!-- (1) -->
	<groupId>org.springframework.restdocs</groupId>
	<artifactId>spring-restdocs-mockmvc</artifactId>
	<version>{project-version}</version>
	<scope>test</scope>
</dependency>

<build>
	<plugins>
		<plugin> <!-- (2) -->
			<groupId>org.asciidoctor</groupId>
			<artifactId>asciidoctor-maven-plugin</artifactId>
			<version>1.5.8</version>
			<executions>
				<execution>
					<id>generate-docs</id>
					<phase>prepare-package</phase> <!-- (3) -->
					<goals>
						<goal>process-asciidoc</goal>
					</goals>
					<configuration>
						<backend>html</backend>
						<doctype>book</doctype>
					</configuration>
				</execution>
			</executions>
			<dependencies>
				<dependency> <!-- (4) -->
					<groupId>org.springframework.restdocs</groupId>
					<artifactId>spring-restdocs-asciidoctor</artifactId>
					<version>{project-version}</version>
				</dependency>
			</dependencies>
		</plugin>
	</plugins>
</build>
```
<div class="language-only-for-gradle maven gradle"></div>
```groovy
plugins { // (1)
	id "org.asciidoctor.convert" version "1.5.9.2"
}

dependencies {
	asciidoctor 'org.springframework.restdocs:spring-restdocs-asciidoctor:{project-version}' // (2)
	testCompile 'org.springframework.restdocs:spring-restdocs-mockmvc:{project-version}' // (3)
}

ext { // (4)
	snippetsDir = file('build/generated-snippets')
}

test { // (5)
	outputs.dir snippetsDir
}

asciidoctor { // (6)
	inputs.dir snippetsDir // (7)
	dependsOn test // (8)
}
```
<div class="description-for-maven maven gradle"></div>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `test` 스코프에 `spring-restdocs-mockmvc` 의존성을 추가한다. MockMvc 대신 `WebTestClient`를 사용하고 싶다면 `spring-restdocs-webtestclient`를, REST Assured를 사용하고 싶다면 `spring-restdocs-restassured` 의존성을 추가해라.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> Asciidoctor 플러그인을 추가한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> `prepare-package`를 사용하면 문서를 [패키지 안에 넣을](#231-packaging-the-documentation) 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> `spring-restdocs-asciidoctor`를 Asciidoctor 플러그인 의존성으로 추가한다. 이렇게하면 `.adoc` 파일에서 사용할 `snippets` 속성이 자동으로 `target/generated-snippets`로 설정된다. 따라서 `operation` 블록 매크로를 사용할 수 있다.</small>

<div class="description-for-gradle maven gradle"></div>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> Asciidoctor 플러그인을 적용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> `asciidoctor` 설정에 `spring-restdocs-asciidoctor` 의존성을 추가한다. 이렇게하면 `.adoc` 파일에서 사용할 `snippets` 속성이 자동으로 `build/generated-snippets`로 설정된다. 따라서 `operation` 블록 매크로를 사용할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> `testCompile` 설정에 `spring-restdocs-mockmv` 의존성을 추가한다. MockMvc 대신 `WebTestClient`를 사용하고 싶다면 `spring-restdocs-webtestclient`를, REST Assured를 사용하고 싶다면 `spring-restdocs-restassured` 의존성을 추가해라.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> 생성된 스니펫의 출력 위치를 가리키는 프로퍼티를 설정한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> `test` 태스크 출력에 스니펫 디렉토리를 추가하도록 설정한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(6)</span>  `asciidoctor` 태스크를 설정한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(7)</span> 스니펫 디렉토리를 입력으로 설정한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(8)</span> 해당 테스크를 테스트 태스크에 의존하도록 만들어, 문서 생성 전 테스트를 실행하도록 한다.</small>

### 2.3.1. Packaging the Documentation

생성한 문서를 프로젝트 jar 파일에 함께 패키징하고 싶을 거다 — 예를 들어 스프링 부트에서 [스태틱 컨텐츠로 서빙](https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/#boot-features-spring-mvc-static-content)하는 식으로. 이렇게 하려먼 프로젝트의 빌드 환경을 다음과 같이 설정해라:

1. jar 빌드 전에 문서를 생성한다.
2. 생성한 문서는 jar에 포함시킨다.

다음은 메이븐과 그래들에서 빌드 환경을 설정하는 예제다:

<div class="switch-language-wrapper maven gradle">
<span class="switch-language maven">maven</span>
<span class="switch-language gradle">gradle</span>
</div>
<div class="language-only-for-maven maven gradle"></div>
```xml
<plugin> <!-- (1) -->
	<groupId>org.asciidoctor</groupId>
	<artifactId>asciidoctor-maven-plugin</artifactId>
	<!-- … -->
</plugin>
<plugin> <!-- (2) -->
	<artifactId>maven-resources-plugin</artifactId>
	<version>2.7</version>
	<executions>
		<execution>
			<id>copy-resources</id>
			<phase>prepare-package</phase>
			<goals>
				<goal>copy-resources</goal>
			</goals>
			<configuration> <!-- (3) -->
				<outputDirectory>
					${project.build.outputDirectory}/static/docs
				</outputDirectory>
				<resources>
					<resource>
						<directory>
							${project.build.directory}/generated-docs
						</directory>
					</resource>
				</resources>
			</configuration>
		</execution>
	</executions>
</plugin>
```
<div class="language-only-for-gradle maven gradle"></div>
```groovy
bootJar {
	dependsOn asciidoctor // (1)
	from ("${asciidoctor.outputDir}/html5") { // (2)
		into 'static/docs'
	}
}
```
<div class="description-for-maven maven gradle"></div>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 기존 Asciidoctor 플러그인 선언.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 이 리소스 플러그인은 동일한 페이즈(`prepare-package`)에 바운드돼 있으므로 Asciidoctor 이후에 선언해야 하며, Asciidoctor 플러그인보다 나중에 실행돼야 문서를 복사하기 전에 미리 생성할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 생성한 문서를 빌드 출력 디렉토리 `static/docs`로 복사한다. 이렇게 하면 jar 파일에 함께 들어간다.</small>

<div class="description-for-gradle maven gradle"></div>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> jar를 빌드하기 전에 문서를 생성해야 한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 생성한 문서를 jar의 `static/docs` 디렉토리로 복사한다.</small>

---

## 2.4. Generating Documentation Snippets

스프링 REST Doc은 스프링 MVC의 [테스트 프레임워크](https://docs.spring.io/spring-framework/docs/5.0.x/spring-framework-reference/testing.html#spring-mvc-test-framework)나 스프링 웹플럭스의 [`WebTestClient`](https://docs.spring.io/spring-framework/docs/5.0.x/spring-framework-reference/testing.html#webtestclient), [REST Assured](http://rest-assured.io/)를 사용해서, 문서화한 서비스로 요청을 보낸다. 그러고 나서 이 요청과 응답 결과로 문서 스니펫을 만든다.

### 2.4.1 Setting up Your Tests

정확한 테스트 설정 방법은 사용하는 테스트 프레임워크에 따라 다르다. 스프링 REST Doc은 일차적으로 JUnit 4와 Junit 5를 지원한다. TestNG같은 다른 프레임워크도 약간의 설정만 있으면 사용할 수 있다.

#### Setting up Your JUnit 4 Tests

JUnit 4에서 문서 스니펫을 만드려면 가장 먼저 `public` `JUnitRestDocumentation` 필드에 JUnit의 `@Rule` 애노테이션을 선언해야 한다. 다음 예제를 보라:

```java
@Rule
public JUnitRestDocumentation restDocumentation = new JUnitRestDocumentation();
```

기본적으로 `JUnitRestDocumentation`은 프로젝트 빌드 툴을 기반으로 출력 디렉토리를 자동 설정한다:

| Build tool | Output directory            |
| :--------- | :-------------------------- |
| Maven      | `target/generated-snippets` |
| Gradle     | `build/generated-snippets`  |

`JUnitRestDocumentation` 인스턴스를 생성할 때 출력 디렉토리를 제공하면 디폴트 설정을 재정의할 수 있다. 다음 예제는 그 방법을 보여준다:

```java
@Rule
public JUnitRestDocumentation restDocumentation = new JUnitRestDocumentation("custom");
```

그 다음 `@Before` 메소드에서 MockMvc 또는 WebTestClient, REST Assured를 설정해야 한다. 다음 예제는 그 방법을 보여준다:

<div class="switch-language-wrapper mockmvc webtestclient restassured">
<span class="switch-language mockmvc">MockMvc</span>
<span class="switch-language webtestclient">WebTestClient</span>
<span class="switch-language restassured">REST Assured</span>
</div>
<div class="language-only-for-mockmvc mockmvc webtestclient restassured"></div>
```java
private MockMvc mockMvc;

@Autowired
private WebApplicationContext context;

@Before
public void setUp() {
	this.mockMvc = MockMvcBuilders.webAppContextSetup(this.context)
			.apply(documentationConfiguration(this.restDocumentation)) // (1)
			.build();
}
```
<div class="language-only-for-webtestclient mockmvc webtestclient restassured"></div>
```java
private WebTestClient webTestClient;

@Autowired
private ApplicationContext context;

@Before
public void setUp() {
	this.webTestClient = WebTestClient.bindToApplicationContext(this.context)
			.configureClient()
			.filter(documentationConfiguration(this.restDocumentation)) // (1)
			.build();
}
```
<div class="language-only-for-restassured mockmvc webtestclient restassured"></div>
```java
private RequestSpecification spec;

@Before
public void setUp() {
	this.spec = new RequestSpecBuilder().addFilter(
			documentationConfiguration(this.restDocumentation)) // (1)
			.build();
}
```
<div class="description-for-mockmvc mockmvc webtestclient restassured"></div>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `MockMvc` 인스턴스에 `MockMvcRestDocumentationConfigurer`를 설정한다. 이 클래스 인스턴스는 <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.mockmvc.MockMvcRestDocumentation</span>에 있는 스태틱 메소드 `documentationConfiguration()`으로 가져올 수 있다.</small>

<div class="description-for-webtestclient mockmvc webtestclient restassured"></div>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `WebTestClient` 인스턴스에 `WebTestclientRestDocumentationConfigurer`를 `ExchangeFilterFunction`으로 추가한다. 이 클래스 인스턴스는 <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.webtestclient.WebTestClientRestDocumentation</span>에 있는 스태틱 메소드 `documentationConfiguration()`으로 가져올 수 있다.</small>

<div class="description-for-restassured mockmvc webtestclient restassured"></div>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> REST Assured에 `RestAssuredRestDocumentationConfigurer`를 `Filter`로 추가한다. 이 클래스 인스턴스는 <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.restassured3</span> 패키지에 있는 `RestAssuredRestDocumentation`의 스태틱 메소드 `documentationConfiguration()`으로 가져올 수 있다.</small>

configurer는 적절한 디폴트 설정을 사용하며, 커스텀 설정을 위한 API도 제공한다. 자세한 설정은 [설정 섹션](../configuration)을 참고해라.

#### Setting up Your JUnit 5 Tests

JUnit 5에서 문서 스니펫을 만드려면 가장 먼저 테스트 클래스에 `RestDocumentationExtension`을 적용해야 한다. 다음 예제를 보라:

```java
@ExtendWith(RestDocumentationExtension.class)
public class JUnit5ExampleTests {
```

전형적인 스프링 어플리케이션을 테스트할 땐 `SpringExtension`도 함께 적용해야 한다:

```java
@ExtendWith({RestDocumentationExtension.class, SpringExtension.class})
public class JUnit5ExampleTests {
```

`RestDocumentationExtension`은 프로젝트 빌드 툴을 기반으로 출력 디렉토리를 자동 설정한다:

| Build tool | Output directory            |
| :--------- | :-------------------------- |
| Maven      | `target/generated-snippets` |
| Gradle     | `build/generated-snippets`  |

JUnit 5.1을 사용한다면, 익스텐션을 테스트 클래스 필드로 등록해 생성 시점에 출력 디렉토리를 제공하면 디폴트 설정을 재정의할 수 있다. 다음 예제는 그 방법을 보여준다:

```java
public class JUnit5ExampleTests {

	@RegisterExtension
	final RestDocumentationExtension restDocumentation = new RestDocumentationExtension ("custom");

}
```

그 다음 `@BeforeEach` 메소드에서 MockMvc 또는 WebTestClient, REST Assured를 설정해야 한다. 다음 예제는 그 방법을 보여준다:

<div class="switch-language-wrapper mockmvc webtestclient restassured">
<span class="switch-language mockmvc">MockMvc</span>
<span class="switch-language webtestclient">WebTestClient</span>
<span class="switch-language restassured">REST Assured</span>
</div>
<div class="language-only-for-mockmvc mockmvc webtestclient restassured"></div>
```java
private MockMvc mockMvc;

@BeforeEach
public void setUp(WebApplicationContext webApplicationContext,
		RestDocumentationContextProvider restDocumentation) {
	this.mockMvc = MockMvcBuilders.webAppContextSetup(webApplicationContext)
			.apply(documentationConfiguration(restDocumentation)) // (1)
			.build();
}
```
<div class="language-only-for-webtestclient mockmvc webtestclient restassured"></div>
```java
private WebTestClient webTestClient;

@BeforeEach
public void setUp(ApplicationContext applicationContext,
		RestDocumentationContextProvider restDocumentation) {
	this.webTestClient = WebTestClient.bindToApplicationContext(applicationContext)
			.configureClient()
			.filter(documentationConfiguration(restDocumentation)) // (1)
			.build();
}
```
<div class="language-only-for-restassured mockmvc webtestclient restassured"></div>
```java
private RequestSpecification spec;

@BeforeEach
public void setUp(RestDocumentationContextProvider restDocumentation) {
	this.spec = new RequestSpecBuilder()
			.addFilter(documentationConfiguration(restDocumentation)) // (1)
			.build();
}
```
<div class="description-for-mockmvc mockmvc webtestclient restassured"></div>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `MockMvc` 인스턴스에 `MockMvcRestDocumentationConfigurer`를 설정한다. 이 클래스 인스턴스는 <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.mockmvc.MockMvcRestDocumentation</span>에 있는 스태틱 메소드 `documentationConfiguration()`으로 가져올 수 있다.</small>

<div class="description-for-webtestclient mockmvc webtestclient restassured"></div>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `WebTestClient` 인스턴스에 `WebTestClientRestDocumentationConfigurer`를 `ExchangeFilterFunction`으로 추가한다. 이 클래스 인스턴스는 <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.webtestclient.WebTestClientRestDocumentation</span>에 있는 스태틱 메소드 `documentationConfiguration()`으로 가져올 수 있다.</small>
<div class="description-for-restassured mockmvc webtestclient restassured"></div>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> REST Assured에 `RestAssuredRestDocumentationConfigurer`를 `Filter`로 추가한다. 이 클래스 인스턴스는 <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.restassured3</span> 패키지에 있는 `RestAssuredRestDocumentation`의 스태틱 메소드 `documentationConfiguration()`으로 가져올 수 있다.</small>

configurer는 적절한 디폴트 설정을 사용하며, 커스텀 설정을 위한 API도 제공한다. 자세한 설정은 [설정 섹션](http://localhost:4000/Spring REST Docs/configuration)을 참고해라.

#### Setting up your tests without JUnit

JUnit을 사용하지 않더라도 설정이 크게 달라지지 않는다. 이번 섹션은 주요 차이점을 설명한다. 여기서 설명하는 내용은 [TestNG 샘플](https://github.com/spring-projects/spring-restdocs/tree/v2.0.5.RELEASE/samples/testng)에서도 확인할 수 있다.

첫 번째 차이점은 `JUnitRestDocumentation` 대신 `ManualRestDocumentation`을 사용한다는 점이다. `@Rule` 애노테이션도 필요가 없다. 다음은 `ManualRestDocumentation`을 사용하는 예제다:

```java
private ManualRestDocumentation restDocumentation = new ManualRestDocumentation();
```

두 번째로는, 반드시 각 테스트 전에 `ManualRestDocumentation.beforeTest(Class, String)`을 호출해야 한다. MockMvc, WebTestClient, REST Assured 모두 설정하는 메소드에서 호출해주면 된다. 다음 예제를 참고해라:

<div class="switch-language-wrapper mockmvc webtestclient restassured">
<span class="switch-language mockmvc">MockMvc</span>
<span class="switch-language webtestclient">WebTestClient</span>
<span class="switch-language restassured">REST Assured</span>
</div>
<div class="language-only-for-mockmvc mockmvc webtestclient restassured"></div>
```java
private MockMvc mockMvc;

@Autowired
private WebApplicationContext context;

@BeforeMethod
public void setUp(Method method) {
	this.mockMvc = MockMvcBuilders.webAppContextSetup(this.context)
			.apply(documentationConfiguration(this.restDocumentation))
			.build();
	this.restDocumentation.beforeTest(getClass(), method.getName());
}
```
<div class="language-only-for-webtestclient mockmvc webtestclient restassured"></div>
```java
private WebTestClient webTestClient;

@Autowired
private ApplicationContext context;

@BeforeMethod
public void setUp(Method method) {
	this.webTestClient = WebTestClient.bindToApplicationContext(this.context)
			.configureClient()
			.filter(documentationConfiguration(this.restDocumentation)) 
			.build();
	this.restDocumentation.beforeTest(getClass(), method.getName());
}
```
<div class="language-only-for-restassured mockmvc webtestclient restassured"></div>
```java
private RequestSpecification spec;

@BeforeMethod
public void setUp(Method method) {
	this.spec = new RequestSpecBuilder().addFilter(
			documentationConfiguration(this.restDocumentation))
			.build();
	this.restDocumentation.beforeTest(getClass(), method.getName());
}
```

마지막 차이점은 각 테스트 후에 `ManualRestDocumentation.afterTest`를 호출해야 한다는 점이다. 다음은 TestNG를 활용하는 예시다:

```java
@AfterMethod
public void tearDown() {
	this.restDocumentation.afterTest();
}
```

### 2.4.2. Invoking the RESTful Service

테스트 프레임워크를 설정했으므로 이제 RESTful 서비스를 실행해서 요청과 응답을 문서화할 수 있다. 다음은 그 방법을 보여준다:

<div class="switch-language-wrapper mockmvc webtestclient restassured">
<span class="switch-language mockmvc">MockMvc</span>
<span class="switch-language webtestclient">WebTestClient</span>
<span class="switch-language restassured">REST Assured</span>
</div>
<div class="language-only-for-mockmvc mockmvc webtestclient restassured"></div>
```java
this.mockMvc.perform(get("/").accept(MediaType.APPLICATION_JSON)) // (1) 
	.andExpect(status().isOk()) // (2)
	.andDo(document("index")); // (3)
```
<div class="language-only-for-webtestclient mockmvc webtestclient restassured"></div>
```java
this.webTestClient.get().uri("/").accept(MediaType.APPLICATION_JSON) // (1)
		.exchange().expectStatus().isOk() // (2)
		.expectBody().consumeWith(document("index")); // (3)
```
<div class="language-only-for-restassured mockmvc webtestclient restassured"></div>
```java
RestAssured.given(this.spec) // (1)
		.accept("application/json") // (2)
		.filter(document("index")) // (3)
		.when().get("/") // (4)
		.then().assertThat().statusCode(is(200)); // (5)
```
<div class="description-for-mockmvc mockmvc webtestclient restassured"></div>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 서비스의 루트(`/`)를 호출하며 `application/json` 응답이 필요하다고 알린다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 서비스가 기대한 결과를 생산했는지를 검증한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 스니펫을 `index`라는 디렉토리(설정한 출력 디렉토리 아래 있는)에 작성해 서비스 호출을 문서화한다. 스니펫은 `RestDocumentationResultHandler`가 작성한다. 이 클래스 인스턴스는 <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.mockmvc.MockMvcRestDocumentation</span>에 있는 스태틱 메소드 `document`로 가져올 수 있다.</small>
<div class="description-for-webtestclient mockmvc webtestclient restassured"></div>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 서비스의 루트(`/`)를 호출하며 `application/json` 응답이 필요하다고 알린다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 서비스가 기대한 결과를 생산했는지를 검증한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 스니펫을 `index`라는 디렉토리(설정한 출력 디렉토리 아래 있는)에 작성해 서비스 호출을 문서화한다. 스니펫은 `ExchangeResult`의 `Consumer`가 작성한다. 이 컨슈머는 <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.webtestclient.WebTestClientRestDocumentation</span>에 있는 스태틱 메소드 `document`로 가져올 수 있다.</small>
<div class="description-for-restassured mockmvc webtestclient restassured"></div>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `@Before` 메소드로 초기화한 스펙을 적용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> `application/json` 응답이 필요하다고 알린다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 스니펫을 `index`라는 디렉토리(설정한 출력 디렉토리 아래 있는)에 작성해 서비스 호출을 문서화한다. 스니펫은  `RestDocumentationFilter`가 작성한다. 이 클래스 인스턴스는 <span style="background-color: #404145; color: #FAFAFA; font-size: 0.85em;">org.springframework.restdocs.restassured3</span> 패키지에 있는 `RestAssuredRestDocumentation`의 스태틱 메소드 `document`로 가져올 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> 서비스의 루트(`/`)를 호출한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> 서비스가 기대한 결과를 생산했는지를 검증한다.</small>

이 코드는 기본적으로 여섯 가지 스니펫을 작성한다:

- `<output-directory>/index/curl-request.adoc`
- `<output-directory>/index/http-request.adoc`
- `<output-directory>/index/http-response.adoc`
- `<output-directory>/index/httpie-request.adoc`
- `<output-directory>/index/request-body.adoc`
- `<output-directory>/index/response-body.adoc`

이 스니펫이나 스프링 REST Doc이 생성하는 다른 스니펫을 자세히 알고 싶다면 [API 문서화하기](../documentingyourapi)를 참고해라.

---

## 2.5. Using the Snippets

생성된 스니펫을 사용하려먼 먼저 `.adoc` 소스 파일을 만들어야 한다. `.adoc`으로 끝나기만 하면 어떤 이름이든지 상관 없다. 만들어지는 HTML 파일도 같은 이름으로 생성되지만 `.html`로 끝난다. 소스 파일과 결과 HTML 파일의 디폴트 경로는 메이븐, 그래들 중 무엇을 사용했느냐에 따라 다르다:

| Build tool | Source files               | Generated files                |
| :--------- | :------------------------- | :----------------------------- |
| Maven      | `src/main/asciidoc/*.adoc` | `target/generated-docs/*.html` |
| Gradle     | `src/docs/asciidoc/*.adoc` | `build/asciidoc/html5/*.html`  |

그런 다음 include 매크로를 사용해 수동으로 만든 Asciidoc 파일(이 섹션 앞에서 설명한)에 생성된 스니펫을 넣을 수 있다. [빌드 설정](#23-build-configuration)에 추가했던 `spring-restdocs-asciidoctor`가 자동으로 스니펫 출력 디렉토리를 참조하는 `snippets` 속성을 추가해주므로, 이 속성을 활용해도 된다. 다음은 그 방법을 보여준다:

```adoc
include::{snippets}/index/curl-request.adoc[]
```