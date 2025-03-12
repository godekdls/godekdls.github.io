---
title: 3.6.5. Stub Runner Spring Cloud
navTitle: Stub Runner Spring Cloud
category: Spring Cloud Contract
order: 33
permalink: /Spring%20Cloud%20Contract/stub-runner-cloud/
description: Stub Runner와 Spring Cloud 통합하기
image: ./../../images/springcloud/logo.jpeg
lastmod: 2025-03-12T23:34:00+09:00
comments: true
originalRefName: 스프링 클라우드 컨트랙트
originalRefLink: https://docs.spring.io/spring-cloud-contract/reference/4.2.0/project-features-stubrunner/stub-runner-cloud.html
parent: Spring Cloud Contract Features
parentUrl: /Spring%20Cloud%20Contract/features/
subparent: 3.6. Spring Cloud Contract Stub Runner
subparentNavTitle: Spring Cloud Contract Stub Runner
subparentUrl: /Spring%20Cloud%20Contract/features-stubrunner/
---

---

Stub Runner는 Spring Cloud와 통합할 수 있다.

실생활의 예시는 다음을 참고해라:

- [프로듀서<sup>producer</sup> 애플리케이션 샘플](https://github.com/spring-cloud-samples/spring-cloud-contract-samples/tree/main/producer)
- [컨슈머<sup>consumer</sup>  애플리케이션 샘플](https://github.com/spring-cloud-samples/spring-cloud-contract-samples/tree/main/consumer_with_discovery)

### 목차

- [서비스 디스커버리에 스텁<sup>stub</sup> 적용하기](#stubbing-service-discovery)
  + [테스트 프로파일과 서비스 디스커버리](#test-profiles-and-service-discovery)
- [부가 설정들](#additional-configuration)

### Stubbing Service Discovery

`Stub Runner Spring Cloud`의 가장 중요한 특징은 아래 두 가지를 위한 스텁<sup>stub</sup>을 생성한다는 점이다:

- `DiscoveryClient`
- `ReactorServiceInstanceLoadBalancer`

즉, Zookeeper, Consul, Eureka, 또는 다른 어떤 것을 사용하더라도 테스트 환경에선 필요하지 않다. `Stub Runner Spring Cloud`는 추가한 의존성에 맞게 WireMock 인스턴스를 시작하고 있으며, `Feign`을 사용할 때마다 애플리케이션이 실제 서비스 디스커버리 도구를 호출하는 대신 각 서비스에서 필요한 `RestTemplate`이나 `DiscoveryClient`를 직접 로드해 스텁<sup>stub</sup> 서버를 호출하도록 지시한다.

#### Test Profiles and Service Discovery

일반적으로 통합 테스트에선 디스커버리 서비스(e.g. Eureka)나 컨피그 서버를 호출하고 싶지는 않을 거다. 따라서 관련 기능을 비활성화할 수 있는 테스트 설정을 추가해야 한다.

관련해서는 [`spring-cloud-commons`](https://github.com/spring-cloud/spring-cloud-commons/issues/156)에 제약이 있기 때문에, 다음 예제와 같이 스태틱 블록에서 관련 프로퍼티들을 비활성화해줘야 한다 (예제에선 Eureka를 비활성화한다):

```java
    //Hack to work around https://github.com/spring-cloud/spring-cloud-commons/issues/156
    static {
        System.setProperty("eureka.client.enabled", "false");
        System.setProperty("spring.cloud.config.failFast", "false");
    }
```

### Additional Configuration

`stubrunner.idsToServiceIds` 맵을 사용하면 스텁<sup>stub</sup>의 `artifactId`를 애플리케이션의 이름과 매칭시킬 수 있다.

> 기본적으로 모든 서비스 디스커버리는 스텁<sup>stub</sup>으로 처리된다. 다시 말해, 기존에 `DiscoveryClient`가 있더라도 무시한다. 하지만 기존 것을 재사용하고 싶은 경우, `stubrunner.cloud.delegate.enabled`를 `true`로 설정하면 기존 `DiscoveryClient`의 결과와 스텁<sup>stub</sup> 처리한 결과를 병합한다.

Stub Runner에서 쓰는 디폴트 Maven 설정은 아래 시스템 프로퍼티를 사용하거나, 관련 환경 변수를 통해 변경할 수 있다:

- `maven.repo.local`: 커스텀 메이븐 로컬 레포지토리 경로
- `org.apache.maven.user-settings`: 커스텀 메이븐 user settings 경로
- `org.apache.maven.global-settings`: 메이븐 global settings 경로