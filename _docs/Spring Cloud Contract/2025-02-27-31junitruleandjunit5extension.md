---
title: 3.6.4. Stub Runner JUnit Rule and Stub Runner JUnit5 Extension
navTitle: Stub Runner JUnit Rule and Stub Runner JUnit5 Extension
category: Spring Cloud Contract
order: 32
permalink: /Spring%20Cloud%20Contract/stub-runner-junit/
description: JUnit Rule, JUnit5 Extension을 통해 스텁 다운받고 실행하기
image: ./../../images/springcloud/logo.jpeg
lastmod: 2025-03-12T23:34:00+09:00
comments: true
originalRefName: 스프링 클라우드 컨트랙트
originalRefLink: https://docs.spring.io/spring-cloud-contract/reference/4.2.0/project-features-stubrunner/stub-runner-junit.html
parent: Spring Cloud Contract Features
parentUrl: /Spring%20Cloud%20Contract/features/
subparent: 3.6. Spring Cloud Contract Stub Runner
subparentNavTitle: Spring Cloud Contract Stub Runner
subparentUrl: /Spring%20Cloud%20Contract/features-stubrunner/
---
<script>defaultLanguages = ['spock']</script>

---

Stub Runner에서는 다음과 같이 JUnit rule을 이용해, 지정한 그룹 ID와 아티팩트 ID에 해당하는 스텁<sup>stub</sup>을 다운로드하고 실행할 수 있다:

```java
@ClassRule
public static StubRunnerRule rule = new StubRunnerRule().repoRoot(repoRoot())
	.stubsMode(StubRunnerProperties.StubsMode.REMOTE)
	.downloadStub("org.springframework.cloud.contract.verifier.stubs", "loanIssuance")
	.downloadStub("org.springframework.cloud.contract.verifier.stubs:fraudDetectionServer");

@BeforeClass
@AfterClass
public static void setupProps() {
	System.clearProperty("stubrunner.repository.root");
	System.clearProperty("stubrunner.classifier");
}
```

JUnit 5를 위한 `StubRunnerExtension` 역시 지원한다. `StubRunnerExtension`의 동작 방식도 `StubRunnerRule`과 매우 유사하다. rule 혹은 extension이 실행되고 나면, Stub Runner는 Maven 레포지토리에 연결해서 지정한 의존성들에 대해 다음과 같은 일들을 시도한다:

- 의존성을 다운받는다
- 로컬 캐시에 저장한다
- 임시 폴더에 압축을 해제한다
- 지정한 포트 범위 내 임의의 포트, 혹은 지정 포트에서 각 Maven 의존성에 대한 WireMock 서버를 시작한다
- WireMock 서버에 유효한 WireMock 정의를 담고 있는 모든 JSON 파일을 공급한다
- 메시지를 전송한다 (`MessageVerifierSender` 인터페이스의 구현체를 전달해야 한다는 것을 잊지말자)

Stub Runner는 [Eclipse Aether](https://wiki.eclipse.org/Aether) 메커니즘을 통해 Maven 의존성을 다운로드한다. 자세한 내용은 [이 문서](https://wiki.eclipse.org/Aether)를 참고해라.

`StubRunnerRule`과 `StubRunnerExtension`은 `StubFinder`를 구현하고 있기 때문에, 아래 보이는 것처럼 실행 중인 스텁<sup>stub</sup> 정보를 조회할 수 있다:

```groovy
import java.net.URL;
import java.util.Collection;
import java.util.Map;

import org.springframework.cloud.contract.spec.Contract;

/**
 * Contract for finding registered stubs.
 *
 * @author Marcin Grzejszczak
 */
public interface StubFinder extends StubTrigger {

	/**
	 * For the given groupId and artifactId tries to find the matching URL of the running
	 * stub.
	 * @param groupId - might be null. In that case a search only via artifactId takes
	 * place
	 * @param artifactId - artifact id of the stub
	 * @return URL of a running stub or throws exception if not found
	 * @throws StubNotFoundException in case of not finding a stub
	 */
	URL findStubUrl(String groupId, String artifactId) throws StubNotFoundException;

	/**
	 * For the given Ivy notation {@code [groupId]:artifactId:[version]:[classifier]}
	 * tries to find the matching URL of the running stub. You can also pass only
	 * {@code artifactId}.
	 * @param ivyNotation - Ivy representation of the Maven artifact
	 * @return URL of a running stub or throws exception if not found
	 * @throws StubNotFoundException in case of not finding a stub
	 */
	URL findStubUrl(String ivyNotation) throws StubNotFoundException;

	/**
	 * @return all running stubs
	 */
	RunningStubs findAllRunningStubs();

	/**
	 * @return the list of Contracts
	 */
	Map<StubConfiguration, Collection<Contract>> getContracts();

}
```

다음은 Stub Runner를 사용하는 좀 더 구체적인 예시다:

<div class="switch-language-wrapper spock junit4 junit5">
<span class="switch-language spock">Spock</span>
<span class="switch-language junit4">Junit 4</span>
<span class="switch-language junit5">Junit 5</span>
</div>
<div class="language-only-for-spock spock junit4 junit5"></div>
```groovy
@ClassRule
@Shared
StubRunnerRule rule = new StubRunnerRule()
		.stubsMode(StubRunnerProperties.StubsMode.REMOTE)
		.repoRoot(StubRunnerRuleSpec.getResource("/m2repo/repository").toURI().toString())
		.downloadStub("org.springframework.cloud.contract.verifier.stubs", "loanIssuance")
		.downloadStub("org.springframework.cloud.contract.verifier.stubs:fraudDetectionServer")
		.withMappingsOutputFolder("target/outputmappingsforrule")


def 'should start WireMock servers'() {
	expect: 'WireMocks are running'
		rule.findStubUrl('org.springframework.cloud.contract.verifier.stubs', 'loanIssuance') != null
		rule.findStubUrl('loanIssuance') != null
		rule.findStubUrl('loanIssuance') == rule.findStubUrl('org.springframework.cloud.contract.verifier.stubs', 'loanIssuance')
		rule.findStubUrl('org.springframework.cloud.contract.verifier.stubs:fraudDetectionServer') != null
	and:
		rule.findAllRunningStubs().isPresent('loanIssuance')
		rule.findAllRunningStubs().isPresent('org.springframework.cloud.contract.verifier.stubs', 'fraudDetectionServer')
		rule.findAllRunningStubs().isPresent('org.springframework.cloud.contract.verifier.stubs:fraudDetectionServer')
	and: 'Stubs were registered'
		"${rule.findStubUrl('loanIssuance').toString()}/name".toURL().text == 'loanIssuance'
		"${rule.findStubUrl('fraudDetectionServer').toString()}/name".toURL().text == 'fraudDetectionServer'
}

def 'should output mappings to output folder'() {
	when:
		def url = rule.findStubUrl('fraudDetectionServer')
	then:
		new File("target/outputmappingsforrule", "fraudDetectionServer_${url.port}").exists()
}
```
<div class="language-only-for-junit4 spock junit4 junit5"></div>
```java
@Test
public void should_start_wiremock_servers() throws Exception {
	// expect: 'WireMocks are running'
	then(rule.findStubUrl("org.springframework.cloud.contract.verifier.stubs", "loanIssuance")).isNotNull();
	then(rule.findStubUrl("loanIssuance")).isNotNull();
	then(rule.findStubUrl("loanIssuance"))
		.isEqualTo(rule.findStubUrl("org.springframework.cloud.contract.verifier.stubs", "loanIssuance"));
	then(rule.findStubUrl("org.springframework.cloud.contract.verifier.stubs:fraudDetectionServer")).isNotNull();
	// and:
	then(rule.findAllRunningStubs().isPresent("loanIssuance")).isTrue();
	then(rule.findAllRunningStubs()
		.isPresent("org.springframework.cloud.contract.verifier.stubs", "fraudDetectionServer")).isTrue();
	then(rule.findAllRunningStubs()
		.isPresent("org.springframework.cloud.contract.verifier.stubs:fraudDetectionServer")).isTrue();
	// and: 'Stubs were registered'
	then(httpGet(rule.findStubUrl("loanIssuance").toString() + "/name")).isEqualTo("loanIssuance");
	then(httpGet(rule.findStubUrl("fraudDetectionServer").toString() + "/name")).isEqualTo("fraudDetectionServer");
}
```
<div class="language-only-for-junit5 spock junit4 junit5 kotlin"></div>
```java
// Visible for Junit
@RegisterExtension
static StubRunnerExtension stubRunnerExtension = new StubRunnerExtension().repoRoot(repoRoot())
	.stubsMode(StubRunnerProperties.StubsMode.REMOTE)
	.downloadStub("org.springframework.cloud.contract.verifier.stubs", "loanIssuance")
	.downloadStub("org.springframework.cloud.contract.verifier.stubs:fraudDetectionServer")
	.withMappingsOutputFolder("target/outputmappingsforrule");

@BeforeAll
@AfterAll
static void setupProps() {
	System.clearProperty("stubrunner.repository.root");
	System.clearProperty("stubrunner.classifier");
}

private static String repoRoot() {
	try {
		return StubRunnerRuleJUnitTest.class.getResource("/m2repo/repository/").toURI().toString();
	}
	catch (Exception e) {
		return "";
	}
}
```

Stub Runner에 글로벌 설정을 적용하는 자세한 방법은 [JUnit과 Spring의 공통 프로퍼티](../stub-runner-common/#common-properties-for-junit-and-spring)를 참고해라.

> 메시지를 처리하면서 JUnit rule이나 JUnit 5 extension을 사용하고 싶다면, rule 빌더에 `MessageVerifierSender`와 `MessageVerifierReceiver` 인터페이스의 구현체를 제공해야 한다 (예를 들어, `rule.messageVerifierSender(new MyMessageVerifierSender())`). 그렇지 않으면 메시지를 전송할 때마다 예외가 발생한다.

### Maven Settings

스텁<sup>stub</sup> 다운로더는 메이븐 설정에 있는 로컬 레포지토리 경로를 따른다. 하지만 현재 레포지토리와 프로파일에 대한 인증 세부 정보는 고려하지 않으므로, 필요하다면 위에서 언급한 프로퍼티를 사용해 인증 정보를 지정해야 한다.

### Providing Fixed Ports

스텁<sup>stub</sup>은 고정 포트에서도 실행할 수 있다. 두 가지 방법으로 가능한데, 프로퍼티로 전달하는 방법과, JUnit rule의 fluent API를 사용하는 방법이 있다.

### Fluent API

`StubRunnerRule`이나 `StubRunnerExtension`을 사용할 땐, 다운로드할 스텁<sup>stub</sup>을 추가한 다음, 바로 위에 정의한 스텁<sup>stub</sup>의 포트를 지정할 수 있다. 그 방법은 아래 예시를 참고해라:

```java
@ClassRule
public static StubRunnerRule rule = new StubRunnerRule().repoRoot(repoRoot())
	.stubsMode(StubRunnerProperties.StubsMode.REMOTE)
	.downloadStub("org.springframework.cloud.contract.verifier.stubs", "loanIssuance")
	.withPort(35465)
	.downloadStub("org.springframework.cloud.contract.verifier.stubs:fraudDetectionServer:35466");

@BeforeClass
@AfterClass
public static void setupProps() {
	System.clearProperty("stubrunner.repository.root");
	System.clearProperty("stubrunner.classifier");
}
```

위 코드에선 다음과 같은 테스트가 유효하다:

```java
then(rule.findStubUrl("loanIssuance")).isEqualTo(URI.create("http://localhost:35465").toURL());
then(rule.findStubUrl("fraudDetectionServer")).isEqualTo(URI.create("http://localhost:35466").toURL());
```

### Stub Runner with Spring

Spring 환경에서 Stub Runner를 사용하면, Stub Runner 프로젝트와 관련된 Spring 설정이 세팅된다.

설정 파일에 스텁<sup>stub</sup> 목록을 제공하면 Stub Runner는 해당 스텁<sup>stub</sup>을 자동으로 다운받고 WireMock에 등록한다.

스텁<sup>stub</sup> 의존성의 URL을 찾고싶다면, 다음과 같이 `StubFinder` 인터페이스를 자동 주입받아 `StubFinder`에 있는 메소드를 사용하면 된다:

```java
@SpringBootTest(classes = Config, properties = [" stubrunner.cloud.enabled=false",
		'foo=${stubrunner.runningstubs.fraudDetectionServer.port}',
		'fooWithGroup=${stubrunner.runningstubs.org.springframework.cloud.contract.verifier.stubs.fraudDetectionServer.port}'])
@AutoConfigureStubRunner(mappingsOutputFolder = "target/outputmappings/",
		httpServerStubConfigurer = HttpsForFraudDetection)
@ActiveProfiles("test")
class StubRunnerConfigurationSpec {

	@Autowired
	StubFinder stubFinder
	@Autowired
	Environment environment
	@StubRunnerPort("fraudDetectionServer")
	int fraudDetectionServerPort
	@StubRunnerPort("org.springframework.cloud.contract.verifier.stubs:fraudDetectionServer")
	int fraudDetectionServerPortWithGroupId
	@Value('${foo}')
	Integer foo

	@BeforeAll
	static void setupSpec() {
		System.clearProperty("stubrunner.repository.root")
		System.clearProperty("stubrunner.classifier")
		WireMockHttpServerStubAccessor.clear()
	}

	@AfterAll
	static void cleanupSpec() {
		setupSpec()
	}

	@Test
	void 'should mark all ports as random'() {
		expect:
		WireMockHttpServerStubAccessor.everyPortRandom()
	}

	@Test
	void 'should start WireMock servers'() {
		expect: 'WireMocks are running'
		assert stubFinder.findStubUrl('org.springframework.cloud.contract.verifier.stubs', 'loanIssuance') != null
		assert stubFinder.findStubUrl('loanIssuance') != null
		assert stubFinder.findStubUrl('loanIssuance') == stubFinder.findStubUrl('org.springframework.cloud.contract.verifier.stubs', 'loanIssuance')
		assert stubFinder.findStubUrl('loanIssuance') == stubFinder.findStubUrl('org.springframework.cloud.contract.verifier.stubs:loanIssuance')
		assert stubFinder.findStubUrl('org.springframework.cloud.contract.verifier.stubs:loanIssuance:0.0.1-SNAPSHOT') == stubFinder.findStubUrl('org.springframework.cloud.contract.verifier.stubs:loanIssuance:0.0.1-SNAPSHOT:stubs')
		assert stubFinder.findStubUrl('org.springframework.cloud.contract.verifier.stubs:fraudDetectionServer') != null
		and:
		assert stubFinder.findAllRunningStubs().isPresent('loanIssuance')
		assert stubFinder.findAllRunningStubs().isPresent('org.springframework.cloud.contract.verifier.stubs', 'fraudDetectionServer')
		assert stubFinder.findAllRunningStubs().isPresent('org.springframework.cloud.contract.verifier.stubs:fraudDetectionServer')
		and: 'Stubs were registered'
		assert "${stubFinder.findStubUrl('loanIssuance').toString()}/name".toURL().text == 'loanIssuance'
		assert "${stubFinder.findStubUrl('fraudDetectionServer').toString()}/name".toURL().text == 'fraudDetectionServer'
		and: 'Fraud Detection is an HTTPS endpoint'
		assert stubFinder.findStubUrl('fraudDetectionServer').toString().startsWith("https")
	}

	@Test
	void 'should throw an exception when stub is not found'() {
		when:
			BDDAssertions.thenThrownBy(() -> stubFinder.findStubUrl('nonExistingService')).isInstanceOf(StubNotFoundException)
		when:
			BDDAssertions.thenThrownBy(() -> stubFinder.findStubUrl('nonExistingGroupId', 'nonExistingArtifactId'))
		.isInstanceOf(StubNotFoundException)
	}

	@Test
	void 'should register started servers as environment variables'() {
		expect:
		assert environment.getProperty("stubrunner.runningstubs.loanIssuance.port") != null
		assert stubFinder.findAllRunningStubs().getPort("loanIssuance") == (environment.getProperty("stubrunner.runningstubs.loanIssuance.port") as Integer)
		and:
		assert environment.getProperty("stubrunner.runningstubs.fraudDetectionServer.port") != null
		assert stubFinder.findAllRunningStubs().getPort("fraudDetectionServer") == (environment.getProperty("stubrunner.runningstubs.fraudDetectionServer.port") as Integer)
		and:
		assert environment.getProperty("stubrunner.runningstubs.fraudDetectionServer.port") != null
		assert stubFinder.findAllRunningStubs().getPort("fraudDetectionServer") == (environment.getProperty("stubrunner.runningstubs.org.springframework.cloud.contract.verifier.stubs.fraudDetectionServer.port") as Integer)
	}

	@Test
	void 'should be able to interpolate a running stub in the passed test property'() {
		given:
		int fraudPort = stubFinder.findAllRunningStubs().getPort("fraudDetectionServer")
		expect:
		assert fraudPort > 0
		assert environment.getProperty("foo", Integer) == fraudPort
		assert environment.getProperty("fooWithGroup", Integer) == fraudPort
		assert foo == fraudPort
	}

//	@Issue("#573")
	@Test
	void 'should be able to retrieve the port of a running stub via an annotation'() {
		given:
		int fraudPort = stubFinder.findAllRunningStubs().getPort("fraudDetectionServer")
		expect:
		assert fraudPort > 0
		assert fraudDetectionServerPort == fraudPort
		assert fraudDetectionServerPortWithGroupId == fraudPort
	}

	@Test
	void 'should dump all mappings to a file'() {
		when:
		def url = stubFinder.findStubUrl("fraudDetectionServer")
		then:
		assert new File("target/outputmappings/", "fraudDetectionServer_${url.port}").exists()
	}

	@Configuration
	@EnableAutoConfiguration
	static class Config {}

	@CompileStatic
	static class HttpsForFraudDetection extends WireMockHttpServerStubConfigurer {

		private static final Log log = LogFactory.getLog(HttpsForFraudDetection)

		@Override
		WireMockConfiguration configure(WireMockConfiguration httpStubConfiguration, HttpServerStubConfiguration httpServerStubConfiguration) {
			if (httpServerStubConfiguration.stubConfiguration.artifactId == "fraudDetectionServer") {
				int httpsPort = TestSocketUtils.findAvailableTcpPort()
				log.info("Will set HTTPs port [" + httpsPort + "] for fraud detection server")
				return httpStubConfiguration
						.httpsPort(httpsPort)
			}
			return httpStubConfiguration
		}
	}
}
```

스텁<sup>stub</sup>을 어떻게 다운받고 어떻게 실행할지는 아래 설정 파일에 따라 달라진다:

```yml
stubrunner:
  repositoryRoot: classpath:m2repo/repository/
  ids:
    - org.springframework.cloud.contract.verifier.stubs:loanIssuance
    - org.springframework.cloud.contract.verifier.stubs:fraudDetectionServer
    - org.springframework.cloud.contract.verifier.stubs:bootService
  stubs-mode: remote
```

프로퍼티 파일을 사용하는 대신 `@AutoConfigureStubRunner` 내부에 프로퍼티를 지정할 수도 있다. 다음은 어노테이션에 값을 설정하는 동일한 코드다:

```java
@AutoConfigureStubRunner(ids = ["org.springframework.cloud.contract.verifier.stubs:loanIssuance",
 "org.springframework.cloud.contract.verifier.stubs:fraudDetectionServer",
 "org.springframework.cloud.contract.verifier.stubs:bootService"] ,
stubsMode = StubRunnerProperties.StubsMode.REMOTE ,
repositoryRoot = "classpath:m2repo/repository/" )
```

Stub Runner Spring은 WireMock 서버를 등록할 때마다 다음과 같은 환경 변수를 함께 등록한다. 다음 예시에선 `com.example:thing1`, `com.example:thing2`라는 Stub Runner ID를 사용하고 있다:

- `stubrunner.runningstubs.thing1.port`
- `stubrunner.runningstubs.com.example.thing1.port`
- `stubrunner.runningstubs.thing2.port`
- `stubrunner.runningstubs.com.example.thing2.port`

이 값은 코드에서도 참조할 수 있다.

`@StubRunnerPort` 어노테이션을 사용하면 실행 중인 스텁<sup>stub</sup>의 포트도 주입받을 수 있다. 어노테이션의 값엔 `groupid:artifactid` 혹은 `artifactid`만 사용할 수 있다. 다음 예시에선 `com.example:thing1`, `com.example:thing2`라는 Stub Runner ID를 사용하고 있다:

```java
@StubRunnerPort("thing1")
int thing1Port;
@StubRunnerPort("com.example:thing2")
int thing2Port;
```