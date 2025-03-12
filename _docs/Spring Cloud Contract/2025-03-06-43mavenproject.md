---
title: 6. Maven Project
navTitle: Maven Project
category: Spring Cloud Contract
order: 44
permalink: /Spring%20Cloud%20Contract/maven-project/
description: Maven으로 컨슈머-프로듀서 간 컨트랙트 테스트 자동화하기
image: ./../../images/springcloud/logo.jpeg
lastmod: 2025-03-12T23:34:00+09:00
comments: true
originalRefName: 스프링 클라우드 컨트랙트
originalRefLink: https://docs.spring.io/spring-cloud-contract/reference/4.2.0/maven-project.html
parent: Build Tools
parentUrl: /Spring%20Cloud%20Contract/build-tools/
---

### 목차

- [6.1. 메이븐 플러그인 추가하기](#61-adding-the-maven-plugin)
- [6.2. 메이븐과 Rest Assured 2.0](#62-maven-and-rest-assured-20)
- [6.3. 메이븐 스냅샷 버전과 마일스톤 버전 사용하기](#63-using-snapshot-and-milestone-versions-for-maven)
- [6.4. stub 추가하기](#64-adding-stubs)
- [6.5. 플러그인 실행하기](#65-run-plugin)
- [6.6. 플러그인 설정하기](#66-configure-plugin)
- [6.7. 설정 옵션](#67-configuration-options)
- [6.8. 모든 테스트에 공통 베이스 클래스 사용하기](#68-single-base-class-for-all-tests)
- [6.9. Contract마다 다른 베이스 클래스 사용하기](#69-using-different-base-classes-for-contracts)
  + [6.9.1. 컨벤션 이용](#691-by-convention)
  + [6.9.2. 매핑 이용](#692-by-mapping)
- [6.10. 자동 생성 테스트 실행하기](#610-invoking-generated-tests)
- [6.11. SCM에 Stub 배포하기](#611-pushing-stubs-to-scm)
- [6.12.  메이븐 플러그인과 STS](#612-maven-plugin-and-sts)
- [6.13. 메이븐 플러그인과 Spock 테스트](#613-maven-plugin-with-spock-tests)

---

## 6.1. Adding the Maven Plugin

Spring Cloud Contract BOM을 추가하려면, `pom.xml` 파일에 아래 설정을 추가해라:

```xml
<dependency>
	<groupId>org.springframework.cloud</groupId>
	<artifactId>spring-cloud-contract-dependencies</artifactId>
	<version>${spring-cloud-contract.version}</version>
	<type>pom</type>
	<scope>import</scope>
</dependency>
```

그 다음, 아래와 같이 메이븐 플러그인 `Spring Cloud Contract Verifier`를 추가한다:

```xml
<plugin>
	<groupId>org.springframework.cloud</groupId>
	<artifactId>spring-cloud-contract-maven-plugin</artifactId>
	<version>${spring-cloud-contract.version}</version>
	<extensions>true</extensions>
	<configuration>
		<packageWithBaseClasses>com.example.fraud</packageWithBaseClasses>
	</configuration>
</plugin>
```

자세한 내용은 [Spring Cloud Contract Maven Plugin 문서](https://docs.spring.io/spring-cloud-contract/docs/current/spring-cloud-contract-maven-plugin/index.html)에서 확인할 수 있다.

간혹 사용하는 IDE에 관계없이, IDE의 클래스패스에 `target/generated-test-source` 폴더가 보이지 않을 때가 있다. 이 폴더가 항상 표시되도록 만들려면 `pom.xml`에 아래 설정을 추가하면 된다

```xml
<plugin>
	<groupId>org.codehaus.mojo</groupId>
	<artifactId>build-helper-maven-plugin</artifactId>
	<executions>
		<execution>
			<id>add-source</id>
			<phase>generate-test-sources</phase>
			<goals>
				<goal>add-test-source</goal>
			</goals>
			<configuration>
				<sources>
					<source>${project.build.directory}/generated-test-sources/contracts/</source>
				</sources>
			</configuration>
		</execution>
	</executions>
</plugin>
```

---

## 6.2. Maven and Rest Assured 2.0

기본적으로 클래스패스에 Rest Assured 3.x가 추가된다. 이대신 Rest Assured 2.x를 사용하고 싶다면, 아래 보이는 것처럼 추가해줄 수 있다:

```xml
<plugin>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-contract-maven-plugin</artifactId>
    <version>${spring-cloud-contract.version}</version>
    <extensions>true</extensions>
    <configuration>
        <packageWithBaseClasses>com.example</packageWithBaseClasses>
    </configuration>
    <dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-contract-verifier</artifactId>
            <version>${spring-cloud-contract.version}</version>
        </dependency>
        <dependency>
           <groupId>com.jayway.restassured</groupId>
           <artifactId>rest-assured</artifactId>
           <version>2.5.0</version>
           <scope>compile</scope>
        </dependency>
        <dependency>
           <groupId>com.jayway.restassured</groupId>
           <artifactId>spring-mock-mvc</artifactId>
           <version>2.5.0</version>
           <scope>compile</scope>
        </dependency>
    </dependencies>
</plugin>

<dependencies>
    <!-- all dependencies -->
    <!-- you can exclude rest-assured from spring-cloud-contract-verifier -->
    <dependency>
       <groupId>com.jayway.restassured</groupId>
       <artifactId>rest-assured</artifactId>
       <version>2.5.0</version>
       <scope>test</scope>
    </dependency>
    <dependency>
       <groupId>com.jayway.restassured</groupId>
       <artifactId>spring-mock-mvc</artifactId>
       <version>2.5.0</version>
       <scope>test</scope>
    </dependency>
</dependencies>
```

이렇게 설정해주면 플러그인에서 자동으로 클래스패스에 Rest Assured 2.x가 있는지 확인하고 그에 따라 import 구문을 수정한다.

---

## 6.3. Using Snapshot and Milestone Versions for Maven

스냅샷이나 마일스톤 버전을 사용하고 싶다면, `pom.xml`에 아래 설정을 추가해야 한다:

```xml
<repositories>
	<repository>
		<id>spring-snapshots</id>
		<name>Spring Snapshots</name>
		<url>https://repo.spring.io/snapshot</url>
		<snapshots>
			<enabled>true</enabled>
		</snapshots>
	</repository>
	<repository>
		<id>spring-milestones</id>
		<name>Spring Milestones</name>
		<url>https://repo.spring.io/milestone</url>
		<snapshots>
			<enabled>false</enabled>
		</snapshots>
	</repository>
</repositories>
<pluginRepositories>
	<pluginRepository>
		<id>spring-snapshots</id>
		<name>Spring Snapshots</name>
		<url>https://repo.spring.io/snapshot</url>
		<snapshots>
			<enabled>true</enabled>
		</snapshots>
	</pluginRepository>
	<pluginRepository>
		<id>spring-milestones</id>
		<name>Spring Milestones</name>
		<url>https://repo.spring.io/milestone</url>
		<snapshots>
			<enabled>false</enabled>
		</snapshots>
	</pluginRepository>
</pluginRepositories>
```

---

## 6.4. Adding stubs

Spring Cloud Contract Verifier는 기본적으로 `src/test/resources/contracts` 디렉토리에서 스텁<sup>stub</sup>을 찾는다. 스텁<sup>stub</sup> 정의가 담겨있는 디렉토리명을 클래스 이름으로 매핑하며, 각 스텁<sup>stub</sup> 정의는 하나의 테스트로 취급한다. 테스트 클래스 이름으로 사용할 디렉토리가 적어도 한 depth 이상 포함되어 있다고 가정한다. 여러 depth로 중첩된 디렉토리가 존재한다면, 마지막 디렉토리를 제외한 나머지는 패키지 이름으로 사용한다. 예를 들어 아래와 같은 구조를 사용한다면:

```groovy
src/test/resources/contracts/myservice/shouldCreateUser.groovy
src/test/resources/contracts/myservice/shouldReturnUser.groovy
```

Spring Cloud Contract Verifier는 위와 같은 구조에선, 아래 두 개의 메소드를 가진 `defaultBasePackage.MyService`라는 테스트 클래스를 생성한다:

- `shouldCreateUser()`
- `shouldReturnUser()`

---

## 6.5. Run Plugin

플러그인 goal `generateTests`는 `generate-test-sources` 단계에서 실행되도록 할당된다. 즉, 따로 뭘 해주지 않아도 빌드 프로세스에 포함된다. 테스트만 생성하고 싶다면 `generateTests` goal을 실행해라.

메이븐으로 스텁<sup>stub</sup>을 실행하려면, 다음과 같이 시스템 프로퍼티 `spring.cloud.contract.verifier.stub`으로 실행할 스텁을 지정해 `run` goal을 실행해라:

```sh
mvn org.springframework.cloud:spring-cloud-contract-maven-plugin:run \
  -Dspring.cloud.contract.verifier.stubs="com.acme:service-name"
```

---

## 6.6. Configure plugin

디폴트 설정을 변경하고 싶다면, 다음과 같이 플러그인 정의나 `execution` 정의에 `configuration` 섹션을 추가해주면 된다:

```xml
<plugin>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-contract-maven-plugin</artifactId>
    <executions>
        <execution>
            <goals>
                <goal>convert</goal>
                <goal>generateStubs</goal>
                <goal>generateTests</goal>
            </goals>
        </execution>
    </executions>
    <configuration>
        <basePackageForTests>org.springframework.cloud.verifier.twitter.place</basePackageForTests>
        <baseClassForTests>org.springframework.cloud.verifier.twitter.place.BaseMockMvcSpec</baseClassForTests>
    </configuration>
</plugin>
```

---

## 6.7. Configuration Options

- `testMode`: 인수 테스트<sup>acceptance test</sup> 모드를 정의한다. 디폴트는 스프링의 MockMvc를 기반으로 동작하는 MockMvc다. WebTestClient, JaxRsClient, Explicit(실제 HTTP를 호출할 때)으로도 변경할 수 있다.
- `basePackageForTests`: 자동 생성된 모든 테스트에서 사용할 기본 패키지를 지정한다. 따로 설정하지 않으면 `baseClassForTests`의 패키지나 `packageWithBaseClasses` 값을 사용한다. 이 두 값도 다 지정하지 않았다면 `org.springframework.cloud.contract.verifier.tests`로 설정한다.
- `ruleClassForTests`: 자동 생성 테스트에 추가할 rule을 정의한다.
- `baseClassForTests`: 자동 생성된 모든 테스트에서 사용할 베이스 클래스를 생성한다. Spock 클래스를 사용하는 경우 기본값은 `spock.lang.Specification`이다.
- `contractsDirectory`: Groovy DSL로 작성한 명세<sup>contract</sup>가 들어있는 디렉토리를 지정한다. 디폴트는 `/src/test/resources/contracts`다.
- `generatedTestSourcesDir`: Groovy DSL로 생성된 테스트를 저장할 테스트 소스 디렉토리를 지정한다. 디폴트는 `$buildDir/generated-test-sources/contracts`다.
- `generatedTestResourcesDir`: 자동 생성 테스트에서 사용하는 리소스를 저장할 테스트 리소스 디렉토리를 지정한다.
- `testFramework`: 사용할 타켓 테스트 프레임워크를 지정한다. 현재 Spock, JUnit 4(`TestFramework.JUNIT`), JUnit 5를 지원하며, JUnit 4가 디폴트다.
- `packageWithBaseClasses`: 모든 베이스 클래스가 들어있는 패키지를 정의한다. 이 설정은 `baseClassForTests`보다 우선시된다. 예를 들어, `src/test/resources/contract/foo/bar/baz/`에 명세<sup>contract</sup>를 저장하고 `packageWithBaseClasses` 프로퍼티 값을 `com.example.base`로 설정했다면, Spring Cloud Contract Verifier는 `com.example.base` 패키지 밑에 `BarBazBase` 클래스가 있다고 가정한다. 즉, 마지막에 두 depth의 디렉토리가 있다면, 이 두 디렉토리 명에 `Base`를 붙인 이름의 클래스를 찾는다.
- `baseClassMappings`: `contractPackageRegex`(명세<sup>contract</sup>가 존재하는 패키지에 매칭시킬 정규식)와 `baseClassFQN`(매칭되는 명세<sup>contract</sup>에서 사용할 클래스의 풀 네임<sup>fully qualified name</sup> 매핑)을 제공하는 baseClassMapping 목록을 지정한다. 예를 들어, `src/test/resources/contract/foo/bar/baz/` 밑에 명세<sup>contract</sup>가 있고 `.* → com.example.base.BaseClass`와 같이 매핑하는 경우, 이 명세<sup>contract</sup>로 생성된 테스트 클래스는 `com.example.base.BaseClass`를 상속한다. 이 설정은 `packageWithBaseClasses`, `baseClassForTests`보다 우선시된다.
- `contractsProperties`: Spring Cloud Contract 컴포넌트에 전달할 프로퍼티가 담긴 맵. 이 프로퍼티들은 빌트인 또는 커스텀 Stub Downloader 등에서 사용할 수 있다.
- `failOnNoContracts`: 활성화하면 명세<sup>contract</sup>를 찾을 수 없을 때 예외를 던진다. 디폴트는 `true`다.
- `failOnInProgress`: `true`로 설정하면 개발 중인<sup>in progress</sup> 명세<sup>contract</sup>를 발견할 시 빌드를 중단한다. 프로듀서<sup>producer</sup> 측에서는 개발 중인<sup>in progress</sup> 명세<sup>contract</sup>가 있다는 사실을 명시해야 하며, 컨슈머<sup>consumer</sup> 쪽에서 테스트가 통과한 것으로 오해할 수 있다는 점을 명심해야 한다. 디폴트는 `true`다.
- `incrementalContractTests`: 활성화하면 마지막 빌드 이후 명세<sup>contract</sup>가 변경됐을 때에만 테스트를 생성한다. 디폴트는 `true`다.
- `incrementalContractStubs`: 활성화하면 마지막 빌드 이후 명세<sup>contract</sup>가 변경됐을 때에만 스텁<sup>stub</sup>을 생성한다. 디폴트는 `true`다.
- `incrementalContractStubsJar`: 활성화하면 마지막 빌드 이후 명세<sup>contract</sup>가 변경됐을 때에만 스텁<sup>stub</sup> jar를 생성한다. 디폴트는 `true`다.
- `httpPort` : 스텁<sup>stub</sup>을 서빙하는 WireMock 서버의 HTTP 포트. 현재 `spring.cloud.contract.verifier.http.port` 프로퍼티는 디렉토리에서 스텁<sup>stub</sup>을 서빙할 때에만 동작한다. 그 외에는 스텁<sup>stub</sup> ID를 지정할 때 ID 문자열에 포트를 포함시켜야 한다.
- `skip`: verifier 실행을 바이패스하려면 `true`로 설정해라.
- `skipTestOnly`: verifier의 테스트 생성을 바이패스하려면 `true`로 설정해라.
- `stubs` : 다운받아 실행할 스텁<sup>stub</sup> 목록. 각각은 Ivy 표기법으로 나타내며, 콜론으로 구분한다.
- `minPort` : 스텁<sup>stub</sup>을 실행할 최소 포트를 지정한다.
- `maxPort` : 스텁<sup>stub</sup>을 실행할 최대 포트를 지정한다.
- `waitForKeyPressed` : 스텁<sup>stub</sup>을 시작한 후 사용자가 키를 누를 때까지 기다릴지 여부를 지정한다.
- `stubsClassifier`: 스텁<sup>stub</sup> 아티팩트에서 사용할 classifier를 지정한다.

명세<sup>contract</sup> 정의를 메이븐 레포지토리에서 다운받고 싶다면, 아래 옵션들을 사용할 수 있다:

- `contractDependency`: 패키징된 모든 명세<sup>contract</sup>를 포함하는 명세<sup>contract</sup> 의존성.
- `contractsPath`: 명세<sup>contract</sup>가 패키징된 JAR 파일 내에서 실제로 명세<sup>contract</sup>가 있는 경로. 디폴트는 `groupid/artifactid`이며, 이때 `gropuid`는 슬래시로 구분한다.
- `contractsMode`: 스텁<sup>stub</sup>을 찾고 등록하는 모드를 선택한다.
- `deleteStubsAfterTest`: `false`로 설정하면 다운로드한 명세<sup>contract</sup>를 임시 디렉토리에서 제거하지 않는다.
- `contractsRepositoryUrl`: 명세<sup>contract</sup>를 포함한 아티팩트가 있는 레포지토리 URL. 지정하지 않으면 현재 메이븐 url을 사용한다.
- `contractsRepositoryUsername`: 명세<sup>contract</sup>가 있는 레포에 연결하기 위한 username.
- `contractsRepositoryPassword`: 명세<sup>contract</sup>가 있는 레포에 연결하기 위한 password.
- `contractsRepositoryProxyHost`: 명세<sup>contract</sup>가 있는 레포에 연결하기 위한 프록시 호스트.
- `contractsRepositoryProxyPort`: 명세<sup>contract</sup>가 있는 레포에 연결하기 위한 프록시 포트.

스냅샷이 아닌 버전을 명시한 경우에만 캐시에 저장한다 (예를 들어 `+`나 `1.0.0.BUILD-SNAPSHOT`은 캐싱하지 않는다). 이 기능은 기본적으로 켜져있다.

메이븐 플러그인이 제공하는 실험적인 기능들도 사용해볼 수 있다:

- `convertToYaml`: 모든 DSL을 좀 더 선언적인<sup>declarative</sup> YAML 형식으로 변환한다. Groovy DSL에서 외부 라이브러리를 사용할 때 매우 유용할 수 있다. 이 기능을 켜면 (`true`로 설정), 컨슈머<sup>consumer</sup> 측에서 라이브러리 의존성을 추가하지 않아도 된다.
- `assertJsonSize`: 자동 생성한 테스트에서 JSON 배열의 크기를 체크할 수 있다. 이 기능은 기본적으로 비활성화돼 있다.

---

## 6.8. Single Base Class for All Tests

MockMvc에서 Spring Cloud Contract Verifier를 사용하는 경우 (디폴트), 모든 자동 생성 인수 테스트<sup>acceptance test</sup>에서 사용할 베이스 specification을 생성해야 한다. 이 클래스에서 어떤 엔드포인트를 대상으로 테스트를 진행할지를 정의하면 된다. 그 방법은 다음 예제를 참고해라:

```groovy
import org.mycompany.ExampleSpringController
import com.jayway.restassured.module.mockmvc.RestAssuredMockMvc
import spock.lang.Specification

class MvcSpec extends Specification {
  def setup() {
   RestAssuredMockMvc.standaloneSetup(new ExampleSpringController())
  }
}
```

필요하다면, 다음과 같이 전체 컨텍스트를 세팅할 수도 있다:

```java
import io.restassured.module.mockmvc.RestAssuredMockMvc;
import org.junit.Before;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.web.context.WebApplicationContext;

@RunWith(SpringRunner.class)
@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT, classes = SomeConfig.class, properties="some=property")
public abstract class BaseTestClass {

	@Autowired
	WebApplicationContext context;

	@Before
	public void setup() {
		RestAssuredMockMvc.webAppContextSetup(this.context);
	}
}
```

`Explicit` 모드를 사용한다면, 일반적인 통합 테스트에서 흔히 볼 수 있듯이, 베이스 클래스를 통해 테스트하는 애플리케이션 전체를 초기화할 수 있다. 그 방법은 다음 예제를 참고해라:

```java
import io.restassured.RestAssured;
import org.junit.Before;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.web.server.LocalServerPort;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.web.context.WebApplicationContext;

@RunWith(SpringRunner.class)
@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT, classes = SomeConfig.class, properties="some=property")
public abstract class BaseTestClass {

	@LocalServerPort
	int port;

	@Before
	public void setup() {
		RestAssured.baseURI = "http://localhost:" + this.port;
	}
}
```

`JAXRSCLIENT` 모드를 사용하는 경우, 베이스 클래스에 `protected WebTarget webTarget` 필드도 필요하다. 현재 JAX-RS API를 테스트하려면 웹 서버를 시작하는 방법밖에 없다.

---

## 6.9. Using Different Base Classes for Contracts

명세<sup>contract</sup>마다 베이스 클래스가 다르다면, 테스트를 자동 생성할 때 어떤 클래스를 상속할지 Spring Cloud Contract 플러그인에 지정할 수 있다. 다음과 같은 두 가지 옵션을 제공한다:

- `packageWithBaseClasses`를 지정해 컨벤션을 따르게 만든다
- `baseClassMappings`를 사용해 매핑 정보를 명시한다

### 6.9.1. By Convention

컨벤션이 뭐냐면, 예를 들어 `src/test/resources/contract/foo/bar/baz/`에 명세<sup>contract</sup>를 저장하고 `packageWithBaseClasses` 프로퍼티 값을 `com.example.base`로 설정했다면, Spring Cloud Contract Verifier는 `com.example.base` 패키지 밑에 `BarBazBase` 클래스가 있다고 가정한다. 즉, 마지막에 두 depth의 디렉토리가 있다면, 이 두 디렉토리 명에 `Base`를 붙인 이름의 클래스를 찾는다. 이 규칙은 `baseClassForTests`보다 우선한다. 다음은 `contracts` 클로저에 설정을 추가하는 예시다:

```xml
<plugin>
	<groupId>org.springframework.cloud</groupId>
	<artifactId>spring-cloud-contract-maven-plugin</artifactId>
	<configuration>
		<packageWithBaseClasses>hello</packageWithBaseClasses>
	</configuration>
</plugin>
```

### 6.9.2. By Mapping

직접 정규식을 사용해 명세<sup>contract</sup> 패키지를 베이스 클래스의 풀네임<sup>fully qualified name</sup>에 매핑할 수 있다. `baseClassMappings`에는 목록을 지정해야 하는데, 각각 `contractPackageRegex`를 `baseClassFQN`에 매핑하는`baseClassMapping` 객체를 추가하면 된다. 다음 예제를 살펴보자:

```xml
<plugin>
	<groupId>org.springframework.cloud</groupId>
	<artifactId>spring-cloud-contract-maven-plugin</artifactId>
	<configuration>
		<baseClassForTests>com.example.FooBase</baseClassForTests>
		<baseClassMappings>
			<baseClassMapping>
				<contractPackageRegex>.*com.*</contractPackageRegex>
				<baseClassFQN>com.example.TestBase</baseClassFQN>
			</baseClassMapping>
		</baseClassMappings>
	</configuration>
</plugin>
```

다음과 같은 디렉토리에 명세<sup>contract</sup>가 있다고 가정해보자:

- `src/test/resources/contract/com/`
- `src/test/resources/contract/foo/`

매핑에 실패한 경우를 대비해서 폴백으로 `baseClassForTests`를 제공할 수 있다. (`packageWithBaseClasses`를 폴백으로 사용해도 좋다.) 이렇게 하면 `src/test/resources/contract/com/` 에 있는 명세<sup>contract</sup>로 생성한 테스트는 `com.example.ComBase`를 상속하고, 나머지 테스트는 `com.example.FooBase`를 상속하게 된다.

---

## 6.10. Invoking Generated Tests

Spring Cloud Contract 메이븐 플러그인은 `/generated-test-sources/contractVerifier`라는 디렉토리에 검증 코드를 생성하고, 이 디렉토리를 `testCompile` goal에 첨부한다.

Groovy Spock 코드에선 다음과 같은 설정을 사용할 수 있다:

```xml
<plugin>
	<groupId>org.codehaus.gmavenplus</groupId>
	<artifactId>gmavenplus-plugin</artifactId>
	<version>1.5</version>
	<executions>
		<execution>
			<goals>
				<goal>testCompile</goal>
			</goals>
		</execution>
	</executions>
	<configuration>
		<testSources>
			<testSource>
				<directory>${project.basedir}/src/test/groovy</directory>
				<includes>
					<include>**/*.groovy</include>
				</includes>
			</testSource>
			<testSource>
				<directory>${project.build.directory}/generated-test-sources/contractVerifier</directory>
				<includes>
					<include>**/*.groovy</include>
				</includes>
			</testSource>
		</testSources>
	</configuration>
</plugin>
```

프로듀서<sup>provider</sup>가 명세<sup>contract</sup>를 준수하고 있는지 확인하려면 `mvn generateTest test`를 실행해야 한다.

---

## 6.11. Pushing Stubs to SCM

SCM<sup>Source Control Management</sup> 레포지토리에 명세<sup>contract</sup>와 스텁<sup>stub</sup>을 보관하는 경우, 스텁<sup>stub</sup>을 레포지토리에 푸시하는 과정을 자동화하고 싶을 수 있다. 이땐 `pushStubsToScm` goal을 추가하면 된다. 그 방법은 다음 예시를 참고해라:

```xml
<plugin>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-contract-maven-plugin</artifactId>
    <version>${spring-cloud-contract.version}</version>
    <extensions>true</extensions>
    <configuration>
        <!-- Base class mappings etc. -->

        <!-- We want to pick contracts from a Git repository -->
        <contractsRepositoryUrl>git://https://github.com/spring-cloud-samples/spring-cloud-contract-nodejs-contracts-git.git</contractsRepositoryUrl>

        <!-- We reuse the contract dependency section to set up the path
        to the folder that contains the contract definitions. In our case the
        path will be /groupId/artifactId/version/contracts -->
        <contractDependency>
            <groupId>${project.groupId}</groupId>
            <artifactId>${project.artifactId}</artifactId>
            <version>${project.version}</version>
        </contractDependency>

        <!-- The contracts mode can't be classpath -->
        <contractsMode>REMOTE</contractsMode>
    </configuration>
    <executions>
        <execution>
            <phase>package</phase>
            <goals>
                <!-- By default we will not push the stubs back to SCM,
                you have to explicitly add it as a goal -->
                <goal>pushStubsToScm</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

[SCM Stub Downloader 사용하기](../pluggable-architecture/#836-using-the-scm-stub-downloader) 페이지에서는, `<configuration><contractsProperties>` 맵이나, 시스템 프로퍼티, 환경 변수를 통해 전달할 수 있는 모든 설정 옵션을 확인할 수 있다. 예를 들어, 디폴트 브랜치 대신 checkout할 구체적인 브랜치를 지정할 수 있다.

```xml
<plugin>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-contract-maven-plugin</artifactId>
    <version>${spring-cloud-contract.version}</version>
    <extensions>true</extensions>
    <configuration>
        <!-- Base class mappings etc. -->

        <!-- We want to pick contracts from a Git repository -->
        <contractsRepositoryUrl>git://https://github.com/spring-cloud-samples/spring-cloud-contract-nodejs-contracts-git.git</contractsRepositoryUrl>
	<contractsProperties>
            <git.branch>another_branch</git.branch>
        </contractsProperties>

        <!-- We reuse the contract dependency section to set up the path
        to the folder that contains the contract definitions. In our case the
        path will be /groupId/artifactId/version/contracts -->
        <contractDependency>
            <groupId>${project.groupId}</groupId>
            <artifactId>${project.artifactId}</artifactId>
            <version>${project.version}</version>
        </contractDependency>

        <!-- The contracts mode can't be classpath -->
        <contractsMode>REMOTE</contractsMode>
    </configuration>
    <executions>
        <execution>
            <phase>package</phase>
            <goals>
                <!-- By default we will not push the stubs back to SCM,
                you have to explicitly add it as a goal -->
                <goal>pushStubsToScm</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

---

## 6.12. Maven Plugin and STS

다음은 STS를 사용할 때 만날 수 있는 exception이다:

![STS Exception](https://raw.githubusercontent.com/spring-cloud/spring-cloud-contract/4.2.x/docs/src/main/asciidoc/images/sts_exception.png)

에러 마커를 클릭하면 다음과 같은 내용을 확인할 수 있다:

```java
 plugin:1.1.0.M1:convert:default-convert:process-test-resources) org.apache.maven.plugin.PluginExecutionException: Execution default-convert of goal org.springframework.cloud:spring-
 cloud-contract-maven-plugin:1.1.0.M1:convert failed. at org.apache.maven.plugin.DefaultBuildPluginManager.executeMojo(DefaultBuildPluginManager.java:145) at
 org.eclipse.m2e.core.internal.embedder.MavenImpl.execute(MavenImpl.java:331) at org.eclipse.m2e.core.internal.embedder.MavenImpl$11.call(MavenImpl.java:1362) at
...
 org.eclipse.core.internal.jobs.Worker.run(Worker.java:55) Caused by: java.lang.NullPointerException at
 org.eclipse.m2e.core.internal.builder.plexusbuildapi.EclipseIncrementalBuildContext.hasDelta(EclipseIncrementalBuildContext.java:53) at
 org.sonatype.plexus.build.incremental.ThreadBuildContext.hasDelta(ThreadBuildContext.java:59) at
```

이 이슈를 해결하려면 `pom.xml`에 아래 설정을 추가해야 한다:

```xml
<build>
    <pluginManagement>
        <plugins>
            <!--This plugin's configuration is used to store Eclipse m2e settings
                only. It has no influence on the Maven build itself. -->
            <plugin>
                <groupId>org.eclipse.m2e</groupId>
                <artifactId>lifecycle-mapping</artifactId>
                <version>1.0.0</version>
                <configuration>
                    <lifecycleMappingMetadata>
                        <pluginExecutions>
                             <pluginExecution>
                                <pluginExecutionFilter>
                                    <groupId>org.springframework.cloud</groupId>
                                    <artifactId>spring-cloud-contract-maven-plugin</artifactId>
                                    <versionRange>[1.0,)</versionRange>
                                    <goals>
                                        <goal>convert</goal>
                                    </goals>
                                </pluginExecutionFilter>
                                <action>
                                    <execute />
                                </action>
                             </pluginExecution>
                        </pluginExecutions>
                    </lifecycleMappingMetadata>
                </configuration>
            </plugin>
        </plugins>
    </pluginManagement>
</build>
```

---

## 6.13. Maven Plugin with Spock Tests

명세<sup>contract</sup> 테스트를 자동 생성하고 실행하기 위해 [Spock 프레임워크](http://spockframework.org/)를 선택할 수 있으며, Maven과 Gradle 모두 사용할 수 있다. 단, Gradle에선 간단하지만, Maven에서는 테스트 코드를 적절히 컴파일하고 실행하기 위한 몇 가지 추가 설정이 필요하다.

가장 먼저, 프로젝트에 Groovy를 추가하려면 [GMavenPlus](https://github.com/groovy/GMavenPlus)와 같은 플러그인이 필요하다. GMavenPlus 플러그인에서는 베이스 테스트 클래스를 정의한 경로와 명세<sup>contract</sup> 테스트를 자동 생성할 경로를 포함한 테스트 소스를 명시해야 한다. 그 방법은 다음 예시를 참고해라:

```xml
<plugin>
    <groupId>org.codehaus.gmavenplus</groupId>
    <artifactId>gmavenplus-plugin</artifactId>
    <version>1.13.0</version>
    <executions>
        <execution>
            <goals>
                <goal>addSources</goal>
                <goal>addTestSources</goal>
                <goal>compile</goal>
                <goal>compileTests</goal>
            </goals>
        </execution>
    </executions>
    <configuration>
        <testSources>
            <testSource>
                <directory>${project.basedir}/src/test/groovy</directory>
                <includes>
                    <include>**/*.groovy</include>
                </includes>
            </testSource>
            <testSource>
                <directory>
                    ${project.basedir}/target/generated-test-sources/contracts/com/example/beer
                </directory>
                <includes>
                    <include>**/*.groovy</include>
                    <include>**/*.gvy</include>
                </includes>
            </testSource>
        </testSources>
    </configuration>
```

Spock 컨벤션에 따라 테스트 클래스명이 `Spec`으로 끝나는 경우, 다음과 같이 Maven Surefire 플러그인 설정도 그에 맞게 변경해야 한다:

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-surefire-plugin</artifactId>
    <configuration>
        <detail>true</detail>
        <includes>
            <include>**/*Test.*</include>
            <include>**/*Tests.*</include>
            <include>**/*Spec.*</include>
        </includes>
        <failIfNoTests>true</failIfNoTests>
    </configuration>
</plugin>
```

