---
title: 3.6.11. Common Properties
navTitle: Common Properties
category: Spring Cloud Contract
order: 39
permalink: /Spring%20Cloud%20Contract/stub-runner-common/
description: 스텁 러너의 공통 프로퍼티들
image: ./../../images/springcloud/logo.jpeg
lastmod: 2025-03-12T23:34:00+09:00
comments: true
originalRefName: 스프링 클라우드 컨트랙트
originalRefLink: https://docs.spring.io/spring-cloud-contract/reference/4.2.0/project-features-stubrunner/stub-runner-common.html
parent: Spring Cloud Contract Features
parentUrl: /Spring%20Cloud%20Contract/features/
subparent: 3.6. Spring Cloud Contract Stub Runner
subparentNavTitle: Spring Cloud Contract Stub Runner
subparentUrl: /Spring%20Cloud%20Contract/features-stubrunner/
---

---

이번 섹션에서는 다음과 같은 공통 프로퍼티를 간략하게 설명한다:

- [JUnit과 스프링의 공통 프로퍼티](#common-properties-for-junit-and-spring)
- [Stub Runner의 Stub ID](#stub-runner-stubs-ids)

### Common Properties for JUnit and Spring

시스템 프로퍼티나 스프링 설정 프로퍼티를 이용해 공통 옵션을 설정할 수 있다. 다음은 프로퍼티명과 디폴트 값을 정리한 테이블이다:

| Property name                 | Default value | Description                                                  |
| :---------------------------- | :------------ | :----------------------------------------------------------- |
| `stubrunner.minPort`          | `10000`       | 스텁<sup>stub</sup>으로 WireMock을 실행할 때 사용할 포트의 최소 값. |
| `stubrunner.maxPort`          | `15000`       | 스텁<sup>stub</sup>으로 WireMock을 실행할 때 사용할 포트의 최대 값. |
| `stubrunner.repositoryRoot`   |               | 메이븐 레포지토리 URL. 비어있으면 메이븐 로컬 레포지토리를 호출한다. |
| `stubrunner.classifier`       | `stubs`       | 스텁<sup>stub</sup> 아티팩트를 위한 디폴트  classifier.      |
| `stubrunner.stubsMode`        | `CLASSPATH`   | 스텁<sup>stub</sup>을 조회하고 등록하는 방법.                |
| `stubrunner.ids`              |               | 다운받을 스텁<sup>stub</sup>의 Ivy 목록.                     |
| `stubrunner.username`         |               | 스텁<sup>stub</sup>을 포함한 JAR를 저장하고 있는 툴에 접근하기 위한 username (생략 가능). |
| `stubrunner.password`         |               | 스텁<sup>stub</sup>을 포함한 JAR를 저장하고 있는 툴에 접근하기 위한 password (생략 가능). |
| `stubrunner.stubsPerConsumer` | `false`       | 모든 컨슈머<sup>consumer</sup>에 대해 스텁<sup>stub</sup> 전체를 일괄로 등록하지 않고, 각 컨슈머<sup>consumer</sup>마다 다른 스텁<sup>stub</sup>을 사용하고 싶다면 `true`로 설정한다. |
| `stubrunner.consumerName`     |               | 각 컨슈머<sup>consumer</sup>마다 전용 스텁<sup>stub</sup>을 사용하고 컨슈머<sup>consumer</sup> 이름을 재정의하고 싶다면 이 값을 변경해라. |

### Stub Runner Stubs IDs

다운받을 스텁<sup>stub</sup>은 시스템 프로퍼티 `stubrunner.ids`에 설정할 수 있다. 여기선 다음과 같은 패턴을 사용한다:

```java
groupId:artifactId:version:classifier:port
```

참고로 `version`, `classifier`, `port`는 생략할 수 있다.

- `port`를 지정하지 않으면 랜덤 포트를 사용한다.
- `classifier`를 지정하지 않으면 디폴트 값을 사용한다. (`groupId:artifactId:version:`과 같이 지정하면 빈 값을 전달할 수 있다).
- `version`을 지정하지 않으면 `+`를 전달하고, 가장 최신 버전을 다운로드한다.

`port`는 WireMock 서버의 포트를 의미한다.

> 1.0.4 버전부터는 Stub Runner에서 선택할 버전의 범위를 지정할 수 있다. Aether 버전 관리 범위에 대한 자세한 내용은 [이곳](https://wiki.eclipse.org/Aether/New_and_Noteworthy#Version_Ranges)을 참고해라.