---
title: 9.2. Configuration Properties
navTitle: Configuration Properties
category: Spring Cloud Contract
order: 69
permalink: /Spring%20Cloud%20Contract/configprops/
description: Spring Cloud Contract 설정 프로퍼티 정리
image: ./../../images/springcloud/logo.jpeg
lastmod: 2025-03-12T23:34:00+09:00
comments: true
originalRefName: 스프링 클라우드 컨트랙트
originalRefLink: https://docs.spring.io/spring-cloud-contract/reference/4.2.0/configprops.html
parent: Common application properties
parentUrl: /Spring%20Cloud%20Contract/appendix/
---

---

아래에 설정 프로퍼티를 정리해뒀다.

| Name                                       | Default | Description                                                  |
| :----------------------------------------- | :------ | :----------------------------------------------------------- |
| stubrunner.amqp.enabled                    | `false` | Stub Runner와 AMQP 지원을 활성화할지.                        |
| stubrunner.amqp.mockCOnnection             | `true`  | Stub Runner와 AMQP mock 커넥션 팩토리 지원을 활성화할지.     |
| stubrunner.classifier                      | `stubs` | 스텁<sup>stub</sup> ivy에서 기본으로 사용할 classifier.      |
| stubrunner.cloud.consul.enabled            | `true`  | Consul에 스텁<sup>stub</sup>을 등록할지.                     |
| stubrunner.cloud.delegate.enabled          | `true`  | DiscoveryClient의 Stub Runner 구현체를 활성화할지 여부.      |
| stubrunner.cloud.enabled                   | `true`  | Spring Cloud의 Stub Runner 지원을 활성화할지 여부.           |
| stubrunner.cloud.eureka.enabled            | `true`  | Eureka에 스텁<sup>stub</sup>을 등록할지.                     |
| stubrunner.cloud.loadbalancer.enabled      | `true`  | Stub Runner의 Spring Cloud Load Balancer 통합을 활성화할지.  |
| stubrunner.cloud.stubbed.discovery.enabled | `true`  | Stub Runner에서 서비스 디스커버리를 스텁<sup>stub</sup>으로 처리할지 여부. false로 설정하면 실제 서비스 디스커버리에 스텁<sup>stub</sup>을 등록한다. |
| stubrunner.cloud.zookeeper.enabled         | `true`  | Zookeeper에 스텁<sup>stub</sup>을 등록할지.                  |
| stubrunner.consumer-name                   |         | 여기에 값을 설정하면 디폴트 `spring.application.name`을 재정의할 수 있다. |
| stubrunner.delete-stubs-after-test         | `true`  | `false`로 설정하면 테스트를 실행하고 나서 임시 폴더에서 스텁<sup>stub</sup>을 삭제하지 **않는다**. |
| stubrunner.fail-on-no-stubs                | `true`  | 활성화하면, Stub Runner는 스텁<sup>stub</sup> / 명세<sup>contract</sup>를 찾지 못하면 예외를 던진다. |
| stubrunner.generate-stubs                  | `false` | 활성화하면, Stub Runner는 미리 만들어진 스텁<sup>stub</sup>을 로드하는 대신, 런타임에 발견한 명세<sup>contract</sup>를 스텁<sup>stub</sup> 포맷으로 변환해 실행한다. |
| stubrunner.http-server-stub-configurer     |         | HTTP 서버 스텁<sup>stub</sup>을 위한 설정.                   |
| stubrunner.ids                             | `[]`    | 실행할 스텁<sup>stub</sup> id 목록 ("ivy" 표기법으로 표기. e.g. `[groupId]:artifactId:[version]:[classifier][:port]`).  `groupId`, `classifier`, `version`, `port`는 생략할 수 있다. |
| stubrunner.ids-to-service-ids              |         | Ivy 표기법에 따라 표기한 id를 애플리케이션 내부에서 사용하는  서비스 id에 매핑한다. e.g. “a:b” → “myService” “artifactId” → “myOtherService” |
| stubrunner.integration.enabled             | `true`  | Stub Runner와 Spring Integration의 통합을 활성화할지.        |
| stubrunner.jms.enabled                     | `true`  | Stub Runner와 Spring JMS의 통합을 활성화할지.                |
| stubrunner.kafka.enabled                   | `true`  | Stub Runner와 Spring Kafka의 통합을 활성화할지.              |
| stubrunner.kafka.initializer.enabled       | `true`  | Stub Runner가 KafkaStubMessages 컴포넌트 대신 메시지를 폴링하도록 허용할지. KafkaStubMessages 컴포넌트는 프로듀서<sup>producer</sup>에서만 사용해야 한다. |
| stubrunner.mappings-output-folder          |         | 각 HTTP 서버의 매핑 정보를 선택한 폴더에 저장한다.           |
| stubrunner.max-port                        | `15000` | WireMock 서버를 자동 시작할 때 사용할 최대 포트 값.          |
| stubrunner.min-port                        | `10000` | WireMock 서버를 자동 시작할 때 사용할 최소 포트 값.          |
| stubrunner.password                        |         | 레포지토리 password.                                         |
| stubrunner.properties                      |         | 커스텀 [`org.springframework.cloud.contract.stubrunner.StubDownloaderBuilder`](https://github.com/spring-cloud/spring-cloud-contract/blob/main/spring-cloud-contract-stub-runner/src/main/java/org/springframework/cloud/contract/stubrunner/StubDownloaderBuilder.java)에 전달할 수 있는 프로퍼티 맵. |
| stubrunner.proxy-host                      |         | 레포지토리 프록시 호스트.                                    |
| stubrunner.proxy-port                      |         | 레포지토리 프록시 포트.                                      |
| stubrunner.server-id                       |         |                                                              |
| stubrunner.stream.enabled                  | `true`  | Stub Runner와 Spring Cloud Stream의 통합을 활성화할지.       |
| stubrunner.stubs-mode                      |         | 스텁<sup>stub</sup>을 어디서 가져올지 선택한다.              |
| stubrunner.stubs-per-consumer              | `false` | HTTP 서버 스텁<sup>stub</sup>에 현재 컨슈머<sup>consumer</sup>와 관련있는 스텁<sup>stub</sup>만 등록해야 하는지. |
| stubrunner.username                        |         | 레포지토리 username.                                         |
| wiremock.placeholders.enabled              | `true`  | wiremock 스텁<sup>stub</sup>의 http URL을 필터링해서, 포트에 플레이스홀더를 추가하거나 동적인 포트를 리졸브해야 함을 나타내는 플래그. |
| wiremock.reset-mappings-after-each-test    | `false` |                                                              |
| wiremock.rest-template-ssl-enabled         | `false` |                                                              |
| wiremock.server.files                      | `[]`    |                                                              |
| wiremock.server.https-port                 | `-1`    |                                                              |
| wiremock.server.https-port-dynamic         | `false` |                                                              |
| wiremock.server.port                       | `8080`  |                                                              |
| wiremock.server.port-dynamic               | `false` |                                                              |
| wiremock.server.stubs                      | `[]`    |                                                              |