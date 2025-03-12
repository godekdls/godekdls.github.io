---
title: 3.4.5. Working with Context Paths
navTitle: Working with Context Paths
category: Spring Cloud Contract
order: 23
permalink: /Spring%20Cloud%20Contract/context-paths/
description: Context Path 사용하기
image: ./../../images/springcloud/logo.jpeg
lastmod: 2025-03-12T23:34:00+09:00
comments: true
originalRefName: 스프링 클라우드 컨트랙트
originalRefLink: https://docs.spring.io/spring-cloud-contract/reference/4.2.0/project-features-flows/context-paths.html
parent: Spring Cloud Contract Features
parentUrl: /Spring%20Cloud%20Contract/features/
subparent: 3.4. Spring Cloud Contract Integrations
subparentNavTitle: Spring Cloud Contract Integrations
subparentUrl: /Spring%20Cloud%20Contract/features-integrations/
---
<script>defaultLanguages = ['maven']</script>

---

Spring Cloud Contract는 컨텍스트 패스<sup>context path</sup>를 지원한다.

<blockquote><p>컨텍스트 패스<sup>context path</sup>를 사용할 땐 프로듀서<sup>producer</sup> 쪽만 변경하면 된다. 그리고 explicit 모드로 테스트를 생성해야 한다. 컨슈머<sup>consumer</sup> 쪽은 그대로 나둬도 된다. 참고로, explicit 모드를 사용해야만 자동 생성 테스트가 통과한다. 테스트를 <code class="highlighter-rouge">EXPLICIT</code> 모드로 변경하는 방법은 아래 예제를 참고해라:</p>
<p>
<div class="switch-language-wrapper maven gradle">
<span class="switch-language maven">Maven</span>
<span class="switch-language gradle">Gradle</span>
</div>
<div class="language-only-for-maven maven gradle"></div>
<div class="language-xml highlighter-rouge" style="display: block;"><div class="highlight"><pre class="highlight"><code><span class="nt">&lt;plugin&gt;</span>
    <span class="nt">&lt;groupId&gt;</span>org.springframework.cloud<span class="nt">&lt;/groupId&gt;</span>
    <span class="nt">&lt;artifactId&gt;</span>spring-cloud-contract-maven-plugin<span class="nt">&lt;/artifactId&gt;</span>
    <span class="nt">&lt;version&gt;</span>${spring-cloud-contract.version}<span class="nt">&lt;/version&gt;</span>
    <span class="nt">&lt;extensions&gt;</span>true<span class="nt">&lt;/extensions&gt;</span>
    <span class="nt">&lt;configuration&gt;</span>
        <span class="nt">&lt;testMode&gt;</span>EXPLICIT<span class="nt">&lt;/testMode&gt;</span>
    <span class="nt">&lt;/configuration&gt;</span>
<span class="nt">&lt;/plugin&gt;</span>
</code></pre></div></div>
<div class="language-only-for-gradle maven gradle"></div>
<div class="language-groovy highlighter-rouge" style="display: none;"><div class="highlight"><pre class="highlight"><code><span class="n">contracts</span> <span class="o">{</span>
		<span class="n">testMode</span> <span class="o">=</span> <span class="s1">'EXPLICIT'</span>
<span class="o">}</span>
</code></pre></div></div>
</p></blockquote>

이렇게 하면 MockMvc를 사용하지 않는 테스트를 생성할 수 있다. 즉, 실제로 요청을 전송한다는 뜻으로, 자동 생성 테스트의 베이스 클래스가 실제 소켓으로 동작하도록 설정해줘야 한다.

아래 명세<sup>contract</sup>를 예시로 들어보면:

```groovy
org.springframework.cloud.contract.spec.Contract.make {
	request {
		method 'GET'
		url '/my-context-path/url'
	}
	response {
		status OK()
	}
}
```

다음은 베이스 클래스와 RestAssured를 세팅하는 샘플 코드다:

```groovy
import io.restassured.RestAssured;
import org.junit.Before;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;

@SpringBootTest(classes = ContextPathTestingBaseClass.class, webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class ContextPathTestingBaseClass {
	
	@LocalServerPort int port;
	
	@Before
	public void setup() {
		RestAssured.baseURI = "http://localhost";
		RestAssured.port = this.port;
	}
}
```

이렇게 세팅하면:

- 자동 생성된 테스트에서 모든 요청은 컨텍스트 패스<sup>context path</sup>가 포함된 실제 엔드포인트로 전송한다 (e.g. `/my-context-path/url`).
- 명세<sup>contract</sup>에도 컨텍스트 패스<sup>context path</sup>를 반영했기 때문에, 스텁<sup>stub</sup>을 만들 때에도 이 정보를 반영한다 (예를 들어, 스텁<sup>stub</sup>을 호출할 때도 `/my-context-path/url`을 호출해야 한다).