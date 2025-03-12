---
title: "3.6.7. Consumer-Driven Contracts: Stubs Per Consumer"
navTitle: "Consumer-Driven Contracts: Stubs Per Consumer"
category: Spring Cloud Contract
order: 35
permalink: /Spring%20Cloud%20Contract/stub-runner-stubs-per-consumer/
description: 컨슈머별로 스텁을 분리해서 컨트랙트 충돌 방지하기
image: ./../../images/springcloud/logo.jpeg
lastmod: 2025-03-12T23:34:00+09:00
comments: true
originalRefName: 스프링 클라우드 컨트랙트
originalRefLink: https://docs.spring.io/spring-cloud-contract/reference/4.2.0/project-features-stubrunner/stub-runner-stubs-per-consumer.html
parent: Spring Cloud Contract Features
parentUrl: /Spring%20Cloud%20Contract/features/
subparent: 3.6. Spring Cloud Contract Stub Runner
subparentNavTitle: Spring Cloud Contract Stub Runner
subparentUrl: /Spring%20Cloud%20Contract/features-stubrunner/
---

---

엔드포인트 하나를 컨슘하는 컨슈머<sup>consumer</sup>가 둘인데, 양쪽이 원하는 응답 형태가 서로 다를 수 있다.

> 여기서 설명하는 방법을 사용하면 어떤 컨슈머<sup>consumer</sup>가 API의 어떤 부분을 사용하는지 즉시 확인할 수 있다. API 응답 중 일부를 제거하고서 자동 생성된 테스트 중 실패하는게 있는지 확인해보면 된다. 실패한 테스트가 하나도 없다면, 사용하는 곳이 없다는 뜻이므로 관련 응답 필드를 안전하게 삭제할 수 있다.

다음은 프로듀서 `foo`에 대해 정의한 명세<sup>contract</sup> 예시다. 이 프로듀서는 두 개의 컨슈머(`foo-consumer`, `bar-consumer`)를 가지고 있다:

*Consumer `foo-service`*

```groovy
request {
   url '/foo'
   method GET()
}
response {
    status OK()
    body(
       foo: "foo"
    }
}
```

*Consumer `bar-service`*

```groovy
request {
   url '/bar'
   method GET()
}
response {
    status OK()
    body(
       bar: "bar"
    }
}
```

요청이 같은데 두 가지 다른 응답을 생성할 수는 없다. 그렇기 때문에 명세<sup>contract</sup>를 적절한 경로에 패키징해서 `stubsPerConsumer` 기능을 활용하는 게 좋다.

`stubsPerConsumer` 기능을 사용하면, 컨슈머<sup>consumer</sup>는 프로듀서<sup>producer</sup> 측에 있는 명세<sup>contract</sup> 중, 자신과 관련된 명세<sup>contract</sup>가 포함된 폴더만 참조할 수 있다. `stubrunner.stubs-per-consumer` 플래그를 `true`로 설정하면 더 이상 모든 스텁<sup>stub</sup>을 등록하지 않고, 컨슈머<sup>consumer</sup> 애플리케이션 이름에 해당하는 스텁<sup>stub</sup>만 등록한다. 즉, 모든 스텁<sup>stub</sup>의 경로를 스캔해서, 컨슈머<sup>consumer</sup> 이름을 가진 하위 폴더가 있을 때에만 스텁<sup>stub</sup>을 등록한다.

`foo` 프로듀서<sup>producer</sup> 측에 있는 명세<sup>contract</sup>는 다음과 같다:

```bash
.
└── contracts
    ├── bar-consumer
    │   ├── bookReturnedForBar.groovy
    │   └── shouldCallBar.groovy
    └── foo-consumer
        ├── bookReturnedForFoo.groovy
        └── shouldCallFoo.groovy
```

`bar-consumer` 컨슈머<sup>consumer</sup>는 `spring.application.name` 또는 `stubrunner.consumer-name`을 `bar-consumer`로 설정하거나, 아니면 테스트를 다음과 같이 설정하면 된다:

```java
@SpringBootTest(classes = Config, properties = ["spring.application.name=bar-consumer",
		"stubrunner.jms.enabled=false"])
@AutoConfigureStubRunner(ids = "org.springframework.cloud.contract.verifier.stubs:producerWithMultipleConsumers",
		repositoryRoot = "classpath:m2repo/repository/",
		stubsMode = StubRunnerProperties.StubsMode.REMOTE,
		stubsPerConsumer = true)
@ActiveProfiles("streamconsumer")
class StubRunnerStubsPerConsumerSpec {
...
}
```

이렇게 설정하면 `bar-consumer`라는 폴더가 포함된 경로에 등록한 스텁<sup>stub</sup>만 참조할 수 있다 (즉, `src/test/resources/contracts/bar-consumer/some/contracts/...` 안에 있는 스텁<sup>stub</sup>).

다음과 같이 컨슈머<sup>consumer</sup> 이름을 직접 명시하는 것도 가능하다:

```java
@SpringBootTest(classes = Config, properties = "stubrunner.jms.enabled=false")
@AutoConfigureStubRunner(ids = "org.springframework.cloud.contract.verifier.stubs:producerWithMultipleConsumers",
        repositoryRoot = "classpath:m2repo/repository/",
        consumerName = "foo-consumer",
        stubsMode = StubRunnerProperties.StubsMode.REMOTE,
        stubsPerConsumer = true)
@ActiveProfiles("streamconsumer")
class StubRunnerStubsPerConsumerWithConsumerNameSpec {
...
}
```

이렇게 설정하면 `foo-consumer`라는 폴더가 포함된 경로에 등록한 스텁<sup>stub</sup>만 참조할 수 있다 (즉, `src/test/resources/contracts/foo-consumer/some/contracts/…` 안에 있는 스텁<sup>stub</sup>).

이 기능이 생기게 된 자세한 히스토리가 궁금하다면 [224번 이슈](https://github.com/spring-cloud/spring-cloud-contract/issues/224)를 확인해봐라.