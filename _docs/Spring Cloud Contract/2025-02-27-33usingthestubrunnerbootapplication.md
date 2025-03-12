---
title: 3.6.6. Using the Stub Runner Boot Application
navTitle: Using the Stub Runner Boot Application
category: Spring Cloud Contract
order: 34
permalink: /Spring%20Cloud%20Contract/stub-runner-boot/
description: Stub Runner Boot 활용하기
image: ./../../images/springcloud/logo.jpeg
lastmod: 2025-03-12T23:34:00+09:00
comments: true
originalRefName: 스프링 클라우드 컨트랙트
originalRefLink: https://docs.spring.io/spring-cloud-contract/reference/4.2.0/project-features-stubrunner/stub-runner-boot.html
parent: Spring Cloud Contract Features
parentUrl: /Spring%20Cloud%20Contract/features/
subparent: 3.6. Spring Cloud Contract Stub Runner
subparentNavTitle: Spring Cloud Contract Stub Runner
subparentUrl: /Spring%20Cloud%20Contract/features-stubrunner/
---

---

Spring Cloud Contract Stub Runner Boot는 메시지 처리 레이블을 트리거하고 WireMock 서버에 액세스할 수 있는 REST 엔드포인트를 노출하는 스프링 부트 애플리케이션이다.

### 목차

- [Stub Runner Boot와 보안](#stub-runner-boot-security)
- [Stub Runner Server](#stub-runner-server)
- [Stub Runner Server Fat Jar](#stub-runner-server-fat-jar)
- [Spring Cloud CLI](#spring-cloud-cli)
- [엔드포인트](#endpoints)
  + [HTTP](#http)
  + [메세지 처리](#messaging)
- [예제](#example)
- [Stub Runner Boot와 서비스 디스커버리](#stub-runner-boot-with-service-discovery)

### Stub Runner Boot Security

Stub Runner Boot 애플리케이션은 설계상 보안이 적용돼있지 않다. 보안 기능을 추가하려면 모든 스텁<sup>stub</sup>에 보안 관련 코드를 넣어야 하는데, 실제로는 보안이 필요 없는 스텁<sup>stub</sup>도 있을 수 있다. 즉, Stub Runner 부트 애플리케이션은 테스트용 유틸리티이며, 프로덕션 환경에서 사용하는 용도가 **아니다**.

>  **신뢰할 수 있는 클라이언트**만 Stub Runner Boot 서버에 접근할 수 있어야 한다. 신뢰할 수 없는 위치에서 Fat Jar나 [도커 이미지](../docker-project/)로 Stub Runner Boot 서버를 실행해서는 안 된다.

### Stub Runner Server

Stub Runner 서버를 사용하려면 다음 의존성을 추가해라:

```groovy
compile "org.springframework.cloud:spring-cloud-starter-stub-runner"
```

그런 다음 클래스에 `@EnableStubRunnerServer` 어노테이션을 선언하고 fat jar를 빌드하면 준비가 끝난다.

관련 프로퍼티는 [Stub Runner Spring](../stub-runner-junit/#stub-runner-with-spring) 섹션을 참고해라.

### Stub Runner Server Fat Jar

다음 명령어를 실행하면 Maven에서 독립 실행형<sup>standalone</sup> JAR를 다운로드할 수 있다 (예시에선 2.0.1.RELEASE 버전을 다운받는다):

```bash
$ wget -O stub-runner.jar 'https://search.maven.org/remotecontent?filepath=org/springframework/cloud/spring-cloud-contract-stub-runner-boot/2.0.1.RELEASE/spring-cloud-contract-stub-runner-boot-2.0.1.RELEASE.jar'
$ java -jar stub-runner.jar --stubrunner.ids=... --stubrunner.repositoryRoot=...
```

### Spring Cloud CLI

[Spring Cloud CLI](https://cloud.spring.io/spring-cloud-cli) 프로젝트 `1.4.0.RELEASE` 버전부터, `spring cloud stubrunner`를 실행해 Stub Runner Boot를 시작할 수 있다.

설정을 전달하려면, 현재 작업 디렉토리나, 하위 디렉토리 `config`, 또는 `~/.spring-cloud`에 `stubrunner.yml` 파일을 생성하면 된다. 다음은 로컬에 설치한 스텁<sup>stub</sup>을 실행하기 위한 설정 예시다:

*Example 1. stubrunner.yml*

```yml
stubrunner:
  stubsMode: LOCAL
  ids:
    - com.example:beer-api-producer:+:9876
```

이제 터미널에서 `spring cloud stubrunner`를 호출하면 Stub Runner 서버를 시작할 수 있으며, `8750` 포트에서 이용 가능하다.

### Endpoints

Stub Runner Boot는 두 가지 엔드포인트를 제공한다:

- [HTTP](#http)
- [메시지 처리](#messaging)

#### HTTP

HTTP의 경우, Stub Runner Boot에선 다음과 같은 엔드포인트를 이용할 수 있다:

- GET `/stubs`: 실행 중인 모든 스텁<sup>stub</sup>을 `ivy:integer` 형식으로 반환한다
- GET `/stubs/{ivy}`: 주어진 `ivy`에 대한 포트를 반환한다 (이 엔드포인트를 호출할 때는 `artifactId`만으로도 `ivy`를 지정할 수 있다)

#### Messaging

메시지를 처리할 땐 Stub Runner Boot는 다음과 같은 엔드포인트를 만든다:

- GET `/triggers`: 실행 중인 모든 레이블을 `ivy : [ label1, label2 …]` 형식으로 반환한다
- POST `/triggers/{label}`: `label`을 사용해 트리거를 실행한다
- POST `/triggers/{ivy}/{label}`: 주어진 `ivy`에 대한 트리거를 `label`을 사용해 실행한다 (이 엔드포인트를 호출할 때는 `artifactId`만으로도 `ivy`를 지정할 수 있다)

### Example

다음은 Stub Runner Boot를 사용하는 전형적인 예시이다:

```groovy
@SpringBootTest(classes = StubRunnerBoot, properties = "spring.cloud.zookeeper.enabled=false")
@ActiveProfiles("test")
class StubRunnerBootSpec {

	@Autowired
	StubRunning stubRunning

	@BeforeEach
	void setup() {
		RestAssuredMockMvc.standaloneSetup(new HttpStubsController(stubRunning),
				new TriggerController(stubRunning))
	}

	@Test
	void 'should return a list of running stub servers in "full ivy port" notation'() {
		when:
			String response = RestAssuredMockMvc.get('/stubs').body.asString()
		then:
			def root = new JsonSlurper().parseText(response)
			assert root.'org.springframework.cloud.contract.verifier.stubs:bootService:0.0.1-SNAPSHOT:stubs' instanceof Integer
	}

	@Test
	void 'should return a port on which a #stubId stub is running'() {
		given:
		def stubIds = ['org.springframework.cloud.contract.verifier.stubs:bootService:+:stubs',
				   'org.springframework.cloud.contract.verifier.stubs:bootService:0.0.1-SNAPSHOT:stubs',
				   'org.springframework.cloud.contract.verifier.stubs:bootService:+',
				   'org.springframework.cloud.contract.verifier.stubs:bootService',
				   'bootService']
		stubIds.each {
			when:
				def response = RestAssuredMockMvc.get("/stubs/${it}")
			then:
				assert response.statusCode == 200
				assert Integer.valueOf(response.body.asString()) > 0
		}
	}

	@Test
	void 'should return 404 when missing stub was called'() {
		when:
			def response = RestAssuredMockMvc.get("/stubs/a:b:c:d")
		then:
			assert response.statusCode == 404
	}

	@Test
	void 'should return a list of messaging labels that can be triggered when version and classifier are passed'() {
		when:
			String response = RestAssuredMockMvc.get('/triggers').body.asString()
		then:
			def root = new JsonSlurper().parseText(response)
			assert root.'org.springframework.cloud.contract.verifier.stubs:bootService:0.0.1-SNAPSHOT:stubs'?.containsAll(["return_book_1"])
	}

	@Test
	void 'should trigger a messaging label'() {
		given:
			StubRunning stubRunning = Mockito.mock(StubRunning)
			RestAssuredMockMvc.standaloneSetup(new HttpStubsController(stubRunning), new TriggerController(stubRunning))
		when:
			def response = RestAssuredMockMvc.post("/triggers/delete_book")
		then:
			response.statusCode == 200
		and:
			Mockito.verify(stubRunning).trigger('delete_book')
	}

	@Test
	void 'should trigger a messaging label for a stub with #stubId ivy notation'() {
		given:
			StubRunning stubRunning = Mockito.mock(StubRunning)
			RestAssuredMockMvc.standaloneSetup(new HttpStubsController(stubRunning), new TriggerController(stubRunning))
		and:
			def stubIds = ['org.springframework.cloud.contract.verifier.stubs:bootService:stubs', 'org.springframework.cloud.contract.verifier.stubs:bootService', 'bootService']
		stubIds.each {
			when:
				def response = RestAssuredMockMvc.post("/triggers/$it/delete_book")
			then:
				assert response.statusCode == 200
			and:
				Mockito.verify(stubRunning).trigger(it, 'delete_book')
		}

	}

	@Test
	void 'should throw exception when trigger is missing'() {
		when:
		BDDAssertions.thenThrownBy(() -> RestAssuredMockMvc.post("/triggers/missing_label"))
		.hasMessageContaining("Exception occurred while trying to return [missing_label] label.")
		.hasMessageContaining("Available labels are")
		.hasMessageContaining("org.springframework.cloud.contract.verifier.stubs:loanIssuance:0.0.1-SNAPSHOT:stubs=[]")
		.hasMessageContaining("org.springframework.cloud.contract.verifier.stubs:bootService:0.0.1-SNAPSHOT:stubs=")
	}

}
```

### Stub Runner Boot with Service Discovery

Stub Runner Boot는 "스모크 테스트<sup>smoke test</sup>"를 위한 스텁<sup>stub</sup>용 애플리케이션으로도 활용할 수 있다. 무슨 뜻이냐고? 애플리케이션이 잘 동작하는지 확인하기 위해 테스트 환경에 50가지 마이크로서비스를 전부 다 배포하고 싶지는 않을 거다. 빌드 과정에서 이미 일련의 테스트를 실행했지만, 애플리케이션이 잘 패키징되는지 확인하고 싶다고 생각해 보자. 애플리케이션을 배포하고 실행한 뒤, 몇 가지 테스트를 통해 동작 여부를 확인할 수 있다. 이때는 몇 안 되는 일부 테스트 시나리오만 확인하면 되기 때문에, 이러한 테스트를 "스모크 테스트<sup>smoke test</sup>"라고 부른다.

하지만 마이크로서비스 환경이었다면, 서비스 디스커버리 도구도 함께 사용할 가능성이 높다는 문제가 있다. Stub Runner Boot를 사용하면 필요한 스텁<sup>stub</sup>을 시작하고 서비스 디스커버리 도구에 등록하는 식으로 이 문제를 해결할 수 있다.

이제 Stub Runner Boot 애플리케이션을 시작해서 자동으로 스텁<sup>stub</sup>을 등록한다고 가정해 보자. `java -jar ${SYSTEM_PROPS} stub-runner-boot-eureka-example.jar`로 애플리케이션을 실행하면 된다.

이렇게 애플리케이션을 배포하고 시작하면, 서비스 디스커버리를 통해 실행 중인 WireMock 서버로 요청을 보낼 수 있다. 일반적으로 1번에서 3번까지의 설정은 변경될 가능성이 거의 없기 때문에 `application.yml`에 기본값으로 설정할 수 있다. 이렇게 하면 Stub Runner Boot를 시작할 때 다운로드할 스텁<sup>stub</sup> 목록만 제공하면 된다.