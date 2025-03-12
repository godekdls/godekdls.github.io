---
title: 3.6.9. Generating Stubs at Runtime
navTitle: Generating Stubs at Runtime
category: Spring Cloud Contract
order: 37
permalink: /Spring%20Cloud%20Contract/stub-runner-generate-stubs-at-runtime/
description: 런타임에 스텁 생성하기
image: ./../../images/springcloud/logo.jpeg
lastmod: 2025-03-12T23:34:00+09:00
comments: true
originalRefName: 스프링 클라우드 컨트랙트
originalRefLink: https://docs.spring.io/spring-cloud-contract/reference/4.2.0/project-features-stubrunner/stub-runner-generate-stubs-at-runtime.html
parent: Spring Cloud Contract Features
parentUrl: /Spring%20Cloud%20Contract/features/
subparent: 3.6. Spring Cloud Contract Stub Runner
subparentNavTitle: Spring Cloud Contract Stub Runner
subparentUrl: /Spring%20Cloud%20Contract/features-stubrunner/
---
<script>defaultLanguages = ['annotation']</script>

---

컨슈머 입장에서는 프로듀서가 구현을 완료하고 스텁<sup>stub</sup>을 배포할 때까지 마냥 기다리고 싶진 않을 거다. 이 문제는 스텁<sup>stub</sup>을 런타임에 생성하면 해결된다.

프로듀서가 명세<sup>contract</sup>를 정의할 때는, 자동 생성된 테스트가 통과해야만 스텁<sup>stub</sup>을 배포할 수 있다. 하지만 테스트가 실제로 통과하기 전에 컨슈머에서 스텁<sup>stub</sup>을 조회해갈 수 있게 만들고 싶을 수도 있다. 이럴 땐, 관련 명세<sup>contract</sup>를 개발 중<sup>in-progress</sup>으로 설정해주면 된다. 자세한 내용은 [개발 중인<sup>in-progress</sup> 명세<sup>contract</sup>](../common-top-elements/#contracts-in-progress) 섹션에서 확인할 수 있다. 이렇게 하면 테스트는 생성되지 않고 스텁<sup>stub</sup>만 만들어진다.

컨슈머는 런타임에 스텁<sup>stub</sup>을 생성하도록 스위치를 켜주면 된다. 그러면 Stub Runner는 기존의 모든 스텁<sup>stub</sup> 매핑 정보를 무시하고, 모든 명세<sup>contract</sup> 정의에 대한 스텁<sup>stub</sup>을 새로 생성한다. 아니면 시스템 프로퍼티 `stubrunner.generate-stubs`를 전달해도 된다. 다음은 스위치를 설정하는 예시다:

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
		generateStubs = true)
```
<div class="language-only-for-junit4 annotation junit4 junit5"></div>
```java
@Rule
	public StubRunnerRule rule = new StubRunnerRule()
			.downloadStub("com.example:some-producer")
			.repoRoot("stubs://file://location/to/the/contracts")
			.stubsMode(StubRunnerProperties.StubsMode.REMOTE)
			.withGenerateStubs(true);
```
<div class="language-only-for-junit5 annotation junit4 junit5"></div>
```java
@RegisterExtension
	public StubRunnerExtension stubRunnerExtension = new StubRunnerExtension()
			.downloadStub("com.example:some-producer")
			.repoRoot("stubs://file://location/to/the/contracts")
			.stubsMode(StubRunnerProperties.StubsMode.REMOTE)
			.withGenerateStubs(true);
```