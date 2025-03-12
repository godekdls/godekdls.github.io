---
title: 3.4.3. WebFlux with Explicit Mode
navTitle: WebFlux with Explicit Mode
category: Spring Cloud Contract
order: 21
permalink: /Spring%20Cloud%20Contract/feature-webflux-explicit/
description: WebFlux 애플리케이션에서 explicit 모드로 테스트 자동 생성하기
image: ./../../images/springcloud/logo.jpeg
lastmod: 2025-03-12T23:34:00+09:00
comments: true
originalRefName: 스프링 클라우드 컨트랙트
originalRefLink: https://docs.spring.io/spring-cloud-contract/reference/4.2.0/project-features-flows/feature-webflux-explicit.html
parent: Spring Cloud Contract Features
parentUrl: /Spring%20Cloud%20Contract/features/
subparent: 3.4. Spring Cloud Contract Integrations
subparentNavTitle: Spring Cloud Contract Integrations
subparentUrl: /Spring%20Cloud%20Contract/features-integrations/
---
<script>defaultLanguages = ['maven']</script>

---

WebFlux를 사용 중이라면, explicit 모드로도 테스트를 자동 생성할 수 있다. 다음은 explicit 모드를 설정하는 예시다:

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
        <testMode>EXPLICIT</testMode>
    </configuration>
</plugin>
```
<div class="language-only-for-gradle maven gradle"></div>
```groovy
contracts {
		testMode = 'EXPLICIT'
}
```

WebFlux에서 테스트용 베이스 클래스와 RestAssured를 세팅하는 방법은 아래 코드를 참고해라:

```java
@SpringBootTest(classes = BeerRestBase.Config.class,
        webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
        properties = "server.port=0")
public abstract class BeerRestBase {

    // your tests go here

    // in this config class you define all controllers and mocked services
    @Configuration
    @EnableAutoConfiguration
    static class Config {

        @Bean
        PersonCheckingService personCheckingService()  {
            return personToCheck -> personToCheck.age >= 20;
        }

        @Bean
        ProducerController producerController() {
            return new ProducerController(personCheckingService());
        }
    }

}
```