---
title: 8.3. Using the Pluggable Architecture
navTitle: Using the Pluggable Architecture
category: Spring Cloud Contract
order: 66
permalink: /Spring%20Cloud%20Contract/pluggable-architecture/
description: 다른 언어, 다른 stub provider로 Spring Cloud Contract 확장하기
image: ./../../images/springcloud/logo.jpeg
lastmod: 2025-03-12T23:34:00+09:00
comments: true
originalRefName: 스프링 클라우드 컨트랙트
originalRefLink: https://docs.spring.io/spring-cloud-contract/reference/4.2.0/customization/pluggable-architecture.html
parent: Spring Cloud Contract customization
parentUrl: /Spring%20Cloud%20Contract/advanced/
---

---

간혹 명세<sup>contract</sup>를 YAML, RAML, PACT와 같은 다른 포맷으로 정의해둔 경우가 있을 수 있다. 이런 상황이라도 테스트와 스텁<sup>stub</sup>을 자동 생성하고 싶을 수 있다. 원한다면 테스트와 스텁<sup>stub</sup>을 생성하는 자체 구현체를 추가하면 된다. 또한 테스트 생성 방식과 (예를 들면 다른 언어로 테스트 코드를 생성할 수 있다), 스텁<sup>stub</sup> 생성 방식을 커스텀할 수 있다 (예를 들어 다른 HTTP 서버 구현체를 위한 스텁<sup>stub</sup>을 생성할 수 있다).

### 목차

- [8.3.1. 커스텀 Contract Converter](#831-custom-contract-converter)
- [8.3.2. 커스텀 Test Generator 사용하기](#832-using-the-custom-test-generator)
- [8.3.3. 커스텀 Stub Generator 사용하기](#833-using-the-custom-stub-generator)
- [8.3.4. 커스텀 Stub Runner 사용하기](#834-using-the-custom-stub-runner)
- [8.3.5. 커스텀 Stub Downloader 사용하기](#835-using-the-custom-stub-downloader)
- [8.3.6. SCM Stub Downloader 사용하기](#836-using-the-scm-stub-downloader)

### 8.3.1. Custom Contract Converter

`ContractConverter` 인터페이스를 이용하면, 커스텀 컨버터를 등록해 명세<sup>contract</sup> 구조를 원하는 방식으로 변환할 수 있다. 다음은 `ContractConverter` 인터페이스를 보여준다:

```java
import java.io.File;
import java.util.Collection;

/**
 * Converter to be used to convert FROM {@link File} TO {@link Contract} and from
 * {@link Contract} to {@code T}.
 *
 * @param <T> - type to which we want to convert the contract
 * @author Marcin Grzejszczak
 * @since 1.1.0
 */
public interface ContractConverter<T> extends ContractStorer<T>, ContractReader<T> {

	/**
	 * Should this file be accepted by the converter. Can use the file extension to check
	 * if the conversion is possible.
	 * @param file - file to be considered for conversion
	 * @return - {@code true} if the given implementation can convert the file
	 */
	boolean isAccepted(File file);

	/**
	 * Converts the given {@link File} to its {@link Contract} representation.
	 * @param file - file to convert
	 * @return - {@link Contract} representation of the file
	 */
	Collection<Contract> convertFrom(File file);

	/**
	 * Converts the given {@link Contract} to a {@link T} representation.
	 * @param contract - the parsed contract
	 * @return - {@link T} the type to which we do the conversion
	 */
	T convertTo(Collection<Contract> contract);

}
```

구현체에서는 반드시 변환을 시작할 수 있는 조건을 정의해야 한다. 또한 변환 방식은 양방향 모두 정의해야 한다.

> 구현체를 다 만들었다면, `/META-INF/spring.factories` 파일을 만들어 구현체의 풀네임<sup>fully qualified name </sup>을 제공해야 한다.

다음은 전형적인 `spring.factories` 파일 예시다:

```sh
org.springframework.cloud.contract.spec.ContractConverter=\
org.springframework.cloud.contract.verifier.converter.YamlContractConverter
```

### 8.3.2. Using the Custom Test Generator

자바 이외의 언어로 테스트를 생성하고 싶거나, verifier가 자바 테스트를 빌드하는 방식이 마음에 들지 않는디면, 자체 구현체를 등록할 수 있다.

자체 구현체를 등록할 땐 `SingleTestGenerator` 인터페이스를 사용하면 된다. 다음은 `SingleTestGenerator` 인터페이스를 보여준다:

```groovy
import java.nio.file.Path;
import java.util.Collection;

import org.springframework.cloud.contract.verifier.config.ContractVerifierConfigProperties;
import org.springframework.cloud.contract.verifier.file.ContractMetadata;

/**
 * Builds a single test.
 *
 * @since 1.1.0
 */
public interface SingleTestGenerator {

	/**
	 * Creates contents of a single test class in which all test scenarios from the
	 * contract metadata should be placed.
	 * @param properties - properties passed to the plugin
	 * @param listOfFiles - list of parsed contracts with additional metadata
	 * @param generatedClassData - information about the generated class
	 * @param includedDirectoryRelativePath - relative path to the included directory
	 * @return contents of a single test class
	 */
	String buildClass(ContractVerifierConfigProperties properties, Collection<ContractMetadata> listOfFiles,
			String includedDirectoryRelativePath, GeneratedClassData generatedClassData);

	class GeneratedClassData {

		public final String className;

		public final String classPackage;

		public final Path testClassPath;

		public GeneratedClassData(String className, String classPackage, Path testClassPath) {
			this.className = className;
			this.classPackage = classPackage;
			this.testClassPath = testClassPath;
		}

	}

}
```

마찬가지로, 다음과 같은 `spring.factories` 파일을 제공해야 한다:

```none
org.springframework.cloud.contract.verifier.builder.SingleTestGenerator=/
com.example.MyGenerator
```

### 8.3.3. Using the Custom Stub Generator

WireMock 이외의 다른 스텁<sup>stub</sup> 서버를 위한 스텁<sup>stub</sup>을 생성하려면, `StubGenerator` 인터페이스의 자체 구현체를 연결하면 된다. 다음은 `StubGenerator` 인터페이스를 보여준다:

```groovy
import java.io.File;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.cloud.contract.spec.Contract;
import org.springframework.cloud.contract.verifier.file.ContractMetadata;

/**
 * Converts contracts into their stub representation.
 *
 * @param <T> - type of stub mapping
 * @since 1.1.0
 */
public interface StubGenerator<T> {

	/**
	 * @param mapping - potential stub mapping mapping
	 * @return {@code true} if this converter could have generated this mapping stub.
	 */
	default boolean canReadStubMapping(File mapping) {
		return mapping.getName().endsWith(fileExtension());
	}

	/**
	 * @param rootName - root name of the contract
	 * @param content - metadata of the contract
	 * @return the collection of converted contracts into stubs. One contract can result
	 * in multiple stubs.
	 */
	Map<Contract, String> convertContents(String rootName, ContractMetadata content);

	/**
	 * Post process a generated stub mapping.
	 * @param stubMapping - mapping of a stub
	 * @param contract - contract for which stub was generated
	 * @return the converted stub mapping
	 */
	default T postProcessStubMapping(T stubMapping, Contract contract) {
		List<StubPostProcessor> processors = StubPostProcessor.PROCESSORS.stream()
			.filter(p -> p.isApplicable(contract))
			.collect(Collectors.toList());
		if (processors.isEmpty()) {
			return defaultStubMappingPostProcessing(stubMapping, contract);
		}
		T stub = stubMapping;
		for (StubPostProcessor processor : processors) {
			stub = (T) processor.postProcess(stub, contract);
		}
		return stub;
	}

	/**
	 * Stub mapping to chose when no post processors where found on the classpath.
	 * @param stubMapping - mapping of a stub
	 * @param contract - contract for which stub was generated
	 * @return the converted stub mapping
	 */
	default T defaultStubMappingPostProcessing(T stubMapping, Contract contract) {
		return stubMapping;
	}

	/**
	 * @param inputFileName - name of the input file
	 * @return the name of the converted stub file. If you have multiple contracts in a
	 * single file then a prefix will be added to the generated file. If you provide the
	 * {@link Contract#getName} field then that field will override the generated file
	 * name.
	 *
	 * Example: name of file with 2 contracts is {@code foo.groovy}, it will be converted
	 * by the implementation to {@code foo.json}. The recursive file converter will create
	 * two files {@code 0_foo.json} and {@code 1_foo.json}
	 */
	String generateOutputFileNameForInput(String inputFileName);

	/**
	 * Describes the file extension of the generated mapping that this stub generator can
	 * handle.
	 * @return string describing the file extension
	 */
	default String fileExtension() {
		return ".json";
	}

}
```

마찬가지로, 다음과 같은 `spring.factories` 파일을 제공해야 한다:

```none
# Stub converters
org.springframework.cloud.contract.verifier.converter.StubGenerator=\
org.springframework.cloud.contract.verifier.wiremock.DslToWireMockClientConverter
```

디폴트 구현체는 WireMock 스텁<sup>stub</sup>을 생성한다.

> 스텁<sup>stub</sup> generator 구현체는 여러 개 제공할 수도 있다. 예를 들어, 하나의 DSL에서 WireMock 스텁<sup>stub</sup>과 Pact 파일을 둘 다 생성할 수 있다.

### 8.3.4. Using the Custom Stub Runner

스텁<sup>stub</sup> 생성 로직을 커스텀하기로 했다면, 다른 스텁<sup>stub</sup> provider로 스텁<sup>stub</sup>을 실행하도록 커스텀할 수도 있어야 한다.

[Moco](https://github.com/dreamhead/moco)를 사용해 스텁<sup>stub</sup>을 빌드하고, 스텁<sup>stub</sup> generator를 직접 만들어 JAR 파일에 스텁<sup>stub</sup>을 패키징했다고 가정해 보자.

Stub Runner가 이 스텁<sup>stub</sup>을 실행하는 방법을 알 수 있도록, 다음과 같은 HTTP Stub 서버 구현체를 정의해야 한다:

```groovy
import com.github.dreamhead.moco.bootstrap.arg.HttpArgs
import com.github.dreamhead.moco.runner.JsonRunner
import com.github.dreamhead.moco.runner.RunnerSetting
import groovy.transform.CompileStatic
import groovy.util.logging.Commons

import org.springframework.cloud.contract.stubrunner.HttpServerStub
import org.springframework.cloud.contract.stubrunner.HttpServerStubConfiguration

@Commons
@CompileStatic
class MocoHttpServerStub implements HttpServerStub {

	private boolean started
	private JsonRunner runner
	private int port

	@Override
	int port() {
		if (!isRunning()) {
			return -1
		}
		return port
	}

	@Override
	boolean isRunning() {
		return started
	}

	@Override
	HttpServerStub start(HttpServerStubConfiguration configuration) {
		this.port = configuration.port
		return this
	}

	@Override
	HttpServerStub stop() {
		if (!isRunning()) {
			return this
		}
		this.runner.stop()
		return this
	}

	@Override
	HttpServerStub registerMappings(Collection<File> stubFiles) {
		List<RunnerSetting> settings = stubFiles.findAll { it.name.endsWith("json") }
			.collect {
			log.info("Trying to parse [${it.name}]")
			try {
				return RunnerSetting.aRunnerSetting().addStream(it.newInputStream()).
					build()
			}
			catch (Exception e) {
				log.warn("Exception occurred while trying to parse file [${it.name}]", e)
				return null
			}
		}.findAll { it }
		this.runner = JsonRunner.newJsonRunnerWithSetting(settings,
			HttpArgs.httpArgs().withPort(this.port).build())
		this.runner.run()
		this.started = true
		return this
	}

	@Override
	String registeredMappings() {
		return ""
	}

	@Override
	boolean isAccepted(File file) {
		return file.name.endsWith(".json")
	}
}
```

그런 다음, 아래와 같이 `spring.factories` 파일에 등록해주면 된다:

```none
org.springframework.cloud.contract.stubrunner.HttpServerStub=\
org.springframework.cloud.contract.stubrunner.provider.moco.MocoHttpServerStub
```

이제 Moco로 스텁<sup>stub</sup>을 실행할 수 있다.

> 아무 구현체도 제공하지 않으면 디폴트 (WireMock) 구현체를 사용한다. 구현체를 둘 이상 제공하면 리스트 내에서 첫 번째로 있는 구현체를 사용한다.

### 8.3.5. Using the Custom Stub Downloader

다음과 같이 `StubDownloaderBuilder` 인터페이스를 구현하면 스텁<sup>stub</sup>을 다운받는 방식을 커스텀할 수 있다:

```java
class CustomStubDownloaderBuilder implements StubDownloaderBuilder {

	@Override
	public StubDownloader build(final StubRunnerOptions stubRunnerOptions) {
		return new StubDownloader() {
			@Override
			public Map.Entry<StubConfiguration, File> downloadAndUnpackStubJar(
					StubConfiguration config) {
				File unpackedStubs = retrieveStubs();
				return new AbstractMap.SimpleEntry<>(
						new StubConfiguration(config.getGroupId(), config.getArtifactId(), version,
								config.getClassifier()), unpackedStubs);
			}

			File retrieveStubs() {
			    // here goes your custom logic to provide a folder where all the stubs reside
			}
		}
	}
}
```

그런 다음, 아래와 같이 `spring.factories` 파일에 등록해주면 된다:

```none
# Example of a custom Stub Downloader Provider
org.springframework.cloud.contract.stubrunner.StubDownloaderBuilder=\
com.example.CustomStubDownloaderBuilder
```

이제 스텁<sup>stub</sup>이 있는 소스 폴더를 직접 선택할 수 있다.

> 아무 구현체도 제공하지 않으면 디폴트 (클래스패스 스캔) 구현체를 사용한다. `stubsMode = StubRunnerProperties.StubsMode.LOCAL`이나 `stubsMode = StubRunnerProperties.StubsMode.REMOTE`를 설정하면 Aether 구현체를 사용한다. 구현체를 둘 이상 제공하면 리스트 내에서 첫 번째로 있는 구현체를 사용한다.

### 8.3.6. Using the SCM Stub Downloader

`repositoryRoot`가 SCM 프로토콜로 시작한다면 (현재는 `git://`만 지원한다), 스텁<sup>stub</sup> 다운로더는 레포지토리를 클론받으며, 테스트나 스텁<sup>stub</sup>을 생성하기 위한 명세<sup>contract</sup>를 이곳에서 찾는다.

환경 변수, 시스템 프로퍼티, 플러그인/명세<sup>contract</sup> 레포지토리의 설정 프로퍼티를 통해 다운로더의 동작을 변경할 수 있다. 다음은 사용 가능한 프로퍼티들을 정리한 테이블이다:

| Type of a property                                           | Name of the property | Description                                         |
| ------------------------------------------------------------ | -------------------- | --------------------------------------------------- |
| * `git.branch` (plugin prop)<br>* `stubrunner.properties.git.branch` (system prop)<br/>* `STUBRUNNER_PROPERTIES_GIT_BRANCH` (env prop) | master               | 체크아웃 받을 브랜치                                |
| * `git.username` (plugin prop)<br/>* `stubrunner.properties.git.username` (system prop)<br/>* `STUBRUNNER_PROPERTIES_GIT_USERNAME` (env prop) |                      | Git 클론 username                                   |
| * `git.password` (plugin prop)<br/>* `stubrunner.properties.git.password` (system prop)<br/>* `STUBRUNNER_PROPERTIES_GIT_PASSWORD` (env prop) |                      | Git 클론 password                                   |
| * `git.no-of-attempts` (plugin prop)<br/>* `stubrunner.properties.git.no-of-attempts` (system prop)<br/>* `STUBRUNNER_PROPERTIES_GIT_NO_OF_ATTEMPTS` (env prop) | 10                   | 커밋 내역을 `origin`에 push할 때 몇 번까지 시도할지 |
| * `git.wait-between-attempts` (Plugin prop)<br/>* `stubrunner.properties.git.wait-between-attempts` (system prop)<br/>* `STUBRUNNER_PROPERTIES_GIT_WAIT_BETWEEN_ATTEMPTS` (env prop) |                      |                                                     |