---
title: 3.4.2. WebFlux with WebTestClient
navTitle: WebFlux with WebTestClient
category: Spring Cloud Contract
order: 20
permalink: /Spring%20Cloud%20Contract/feature-webflux/
description: WebTestClient를 이용해 WebFlux 애플리케이션에 Spring Cloud Contract 적용하기
image: ./../../images/springcloud/logo.jpeg
lastmod: 2025-03-12T23:34:00+09:00
comments: true
originalRefName: 스프링 클라우드 컨트랙트
originalRefLink: https://docs.spring.io/spring-cloud-contract/reference/4.2.0/project-features-flows/feature-webflux.html
parent: Spring Cloud Contract Features
parentUrl: /Spring%20Cloud%20Contract/features/
subparent: 3.4. Spring Cloud Contract Integrations
subparentNavTitle: Spring Cloud Contract Integrations
subparentUrl: /Spring%20Cloud%20Contract/features-integrations/
---
<script>defaultLanguages = ['maven']</script>

---

WebFlux를 사용 중이라면, WebTestClient를 이용하면 된다. 다음은 테스트 모드에 WebTestClient를 설정하는 예시다:

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
        <testMode>WEBTESTCLIENT</testMode>
    </configuration>
</plugin>
```
<div class="language-only-for-gradle maven gradle"></div>
```groovy
contracts {
		testMode = 'WEBTESTCLIENT'
}
```

다음은 WebFlux에서 WebTestClient 베이스 클래스와 RestAssured를 설정하는 방법을 보여주는 코드다:

```java
import io.restassured.module.webtestclient.RestAssuredWebTestClient;
import org.junit.Before;

public abstract class BeerRestBase {

	@Before
	public void setup() {
		RestAssuredWebTestClient.standaloneSetup(
		new ProducerController(personToCheck -> personToCheck.age >= 20));
	}
}
```

> 참고로, `WebTestClient` 모드가 `EXPLICIT` 모드보다 빠르다.