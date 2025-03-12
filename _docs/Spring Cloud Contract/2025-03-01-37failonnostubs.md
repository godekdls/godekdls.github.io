---
title: 3.6.10. Fail On No Stubs
navTitle: Fail On No Stubs
category: Spring Cloud Contract
order: 38
permalink: /Spring%20Cloud%20Contract/stub-runner-fail-on-no-stubs/
description: 스텁 없이 Stub Runner 띄우기
image: ./../../images/springcloud/logo.jpeg
lastmod: 2025-03-12T23:34:00+09:00
comments: true
originalRefName: 스프링 클라우드 컨트랙트
originalRefLink: https://docs.spring.io/spring-cloud-contract/reference/4.2.0/project-features-stubrunner/stub-runner-fail-on-no-stubs.html
parent: Spring Cloud Contract Features
parentUrl: /Spring%20Cloud%20Contract/features/
subparent: 3.6. Spring Cloud Contract Stub Runner
subparentNavTitle: Spring Cloud Contract Stub Runner
subparentUrl: /Spring%20Cloud%20Contract/features-stubrunner/
---
<script>defaultLanguages = ['annotation']</script>

---

기본적으로 Stub Runner는 스텁<sup>stub</sup>을 찾지 못하면 실패한다. 이 동작을 변경하고 싶다면, 어노테이션 내 `failOnNoStubs` 프로퍼티를 `false`로 설정하거나, JUnit Rule 또는 Extension에서 `withFailOnNoStubs(false)` 메소드를 호출해라. 예제는 다음을 참고해라:

<div class="switch-language-wrapper annotation junit4 junit5">
<span class="switch-language annotation">Annotation</span>
<span class="switch-language junit4">JUnit 4 Rule</span>
<span class="switch-language junit5">JUnit 5 Extension</span>
</div>
<div class="language-only-for-annotation annotation junit4 junit5"></div>
```java
@AutoConfigureStubRunner(
stubsMode = StubRunnerProperties.StubsMode.REMOTE,
		repositoryRoot = "stubs://file://location/to/the/contracts",
		ids = "com.example:some-producer",
		failOnNoStubs = false)
```
<div class="language-only-for-junit4 annotation junit4 junit5"></div>
```java
@Rule
	public StubRunnerRule rule = new StubRunnerRule()
			.downloadStub("com.example:some-producer")
			.repoRoot("stubs://file://location/to/the/contracts")
			.stubsMode(StubRunnerProperties.StubsMode.REMOTE)
			.withFailOnNoStubs(false);
```
<div class="language-only-for-junit5 annotation junit4 junit5"></div>
```java
@RegisterExtension
	public StubRunnerExtension stubRunnerExtension = new StubRunnerExtension()
			.downloadStub("com.example:some-producer")
			.repoRoot("stubs://file://location/to/the/contracts")
			.stubsMode(StubRunnerProperties.StubsMode.REMOTE)
			.withFailOnNoStubs(false);
```