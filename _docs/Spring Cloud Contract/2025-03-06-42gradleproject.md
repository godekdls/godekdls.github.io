---
title: 5. Gradle Project
navTitle: Gradle Project
category: Spring Cloud Contract
order: 43
permalink: /Spring%20Cloud%20Contract/gradle-project/
description: Gradle로 컨슈머-프로듀서 간 컨트랙트 테스트 자동화하기
image: ./../../images/springcloud/logo.jpeg
lastmod: 2025-03-12T23:34:00+09:00
comments: true
originalRefName: 스프링 클라우드 컨트랙트
originalRefLink: https://docs.spring.io/spring-cloud-contract/reference/4.2.0/gradle-project.html
parent: Build Tools
parentUrl: /Spring%20Cloud%20Contract/build-tools/
---
<script>defaultLanguages = ['ga']</script>

### 목차

- [5.1. 전제 조건](#51-prerequisites)
- [5.2. 그래들 플러그인과 의존성 추가하기](#52-add-gradle-plugin-with-dependencies)
- [5.3. 그래들과 Rest Assured 2.0](#53-gradle-and-rest-assured-20)
- [5.4. 그래들 스냅샷 버전](#54-snapshot-versions-for-gradle)
- [5.5. stub 추가하기](#55-add-stubs)
- [5.6. 플러그인 실행하기](#56-running-the-plugin)
- [5.7. 디폴트 세팅](#57-default-setup)
- [5.8. 플러그인 설정하기](#58-configuring-the-plugin)
- [5.9. 설정 옵션](#59-configuration-options)
- [5.10. 모든 테스트에 공통 베이스 클래스 사용하기](#510-single-base-class-for-all-tests)
- [5.11. Contract마다 다른 베이스 클래스 사용하기](#511-different-base-classes-for-contracts)
  + [5.11.1. 컨벤션 이용](#5111-by-convention)
  + [5.11.2. 매핑 이용](#5112-by-mapping)
- [5.12. 자동 생성 테스트 실행하기](#512-invoking-generated-tests)
- [5.13. 아티팩트 레포지토리에 Stub 배포하기](#513-publishing-stubs-to-artifact-repository)
- [5.14. SCM에 Stub 배포하기](#514-pushing-stubs-to-scm)
- [5.15. 컨슈머 측의 Spring Cloud Contract Verifier](#515-spring-cloud-contract-verifier-on-the-consumer-side)

---

## 5.1. Prerequisites

Spring Cloud Contract Verifier를 WireMock와 함께 사용하려면 Gradle이나 Maven 플러그인을 사용해야 한다.

> 프로젝트 안에서 Spock을 사용하고 싶다면 `spock-core`, `spock-spring` 모듈을 따로따로 추가해야 한다. 자세한 내용은 [Spock 문서](https://spockframework.github.io/)를 참고해라.

---

## 5.2. Add Gradle Plugin with Dependencies

Gradle 플러그인과 의존성을 추가하려면, 다음과 같은 코드를 작성하면 된다:

<div class="switch-language-wrapper ga nonga legacy">
<span class="switch-language ga">Plugin DSL GA versions</span>
<span class="switch-language nonga">Plugin DSL non GA versions</span>
<span class="switch-language legacy">Legacy Plugin Application</span>
</div>
<div class="language-only-for-ga ga nonga legacy"></div>
```groovy
// build.gradle
plugins {
  id "groovy"
  // this will work only for GA versions of Spring Cloud Contract
  id "org.springframework.cloud.contract" version "$\{GAVerifierVersion}"
}

dependencyManagement {
	imports {
		mavenBom "org.springframework.cloud:spring-cloud-contract-dependencies:$\{GAVerifierVersion}"
	}
}

dependencies {
	testImplementation "org.apache.groovy:groovy-all:$\{groovyVersion}"
	// example with adding Spock core and Spock Spring
	testImplementation "org.spockframework:spock-core:$\{spockVersion}"
	testImplementation "org.spockframework:spock-spring:$\{spockVersion}"
	testImplementation 'org.springframework.cloud:spring-cloud-starter-contract-verifier'
}
```
<div class="language-only-for-nonga ga nonga legacy"></div>
```groovy
// settings.gradle
pluginManagement {
	plugins {
		id "org.springframework.cloud.contract" version "$\{verifierVersion}"
	}
    repositories {
        // to pick from local .m2
        mavenLocal()
        // for snapshots
        maven { url "https://repo.spring.io/snapshot" }
        // for milestones
        maven { url "https://repo.spring.io/milestone" }
        // for GA versions
        gradlePluginPortal()
    }
}

// build.gradle
plugins {
  id "groovy"
  id "org.springframework.cloud.contract"
}

dependencyManagement {
	imports {
		mavenBom "org.springframework.cloud:spring-cloud-contract-dependencies:$\{verifierVersion}"
	}
}

dependencies {
	testImplementation "org.apache.groovy:groovy-all:$\{groovyVersion}"
	// example with adding Spock core and Spock Spring
	testImplementation "org.spockframework:spock-core:$\{spockVersion}"
	testImplementation "org.spockframework:spock-spring:$\{spockVersion}"
	testImplementation 'org.springframework.cloud:spring-cloud-starter-contract-verifier'
}
```
<div class="language-only-for-legacy ga nonga legacy"></div>
```groovy
// build.gradle
buildscript {
	repositories {
		mavenCentral()
	}
	dependencies {
		classpath "org.springframework.boot:spring-boot-gradle-plugin:$\{springboot_version}"
		classpath "org.springframework.cloud:spring-cloud-contract-gradle-plugin:$\{verifier_version}"
        // here you can also pass additional dependencies such as Kotlin spec e.g.:
        // classpath "org.springframework.cloud:spring-cloud-contract-spec-kotlin:$\{verifier_version}"
	}
}

apply plugin: 'groovy'
apply plugin: 'org.springframework.cloud.contract'

dependencyManagement {
	imports {
		mavenBom "org.springframework.cloud:spring-cloud-contract-dependencies:$\{verifier_version}"
	}
}

dependencies {
	testImplementation "org.apache.groovy:groovy-all:$\{groovyVersion}"
	// example with adding Spock core and Spock Spring
	testImplementation "org.spockframework:spock-core:$\{spockVersion}"
	testImplementation "org.spockframework:spock-spring:$\{spockVersion}"
	testImplementation 'org.springframework.cloud:spring-cloud-starter-contract-verifier'
}
```

---

## 5.3. Gradle and Rest Assured 2.0

기본적으로 클래스패스에 Rest Assured 3.x가 추가된다. 이대신 Rest Assured 2.x를 사용하고 싶다면, 아래 보이는 것처럼 추가해줄 수 있다:

```groovy
buildscript {
	repositories {
		mavenCentral()
	}
	dependencies {
		classpath "org.springframework.boot:spring-boot-gradle-plugin:$\{springboot_version}"
		classpath "org.springframework.cloud:spring-cloud-contract-gradle-plugin:$\{verifier_version}"
	}
}

dependencies {
    // all dependencies
    // you can exclude rest-assured from spring-cloud-contract-verifier
    testCompile "com.jayway.restassured:rest-assured:2.5.0"
    testCompile "com.jayway.restassured:spring-mock-mvc:2.5.0"
}
```

이렇게 설정해주면 플러그인에서 자동으로 클래스패스에 Rest Assured 2.x가 있는지 확인하고 그에 따라 import 구문을 수정한다.

---

## 5.4. Snapshot Versions for Gradle

`settings.gradle`에 별도 스냅샷 레포지토리를 추가하면, 빌드에 성공할 때마다 스냅샷 버전을 자동으로 업로드할 수 있다.

---

## 5.5. Add stubs

Spring Cloud Contract Verifier는 기본적으로 `src/contractTest/resources/contracts` 디렉토리에서 스텁<sup>stub</sup>을 찾는다. 플러그인에선 호환성을 고려해 `src/test/resources/contracts`에서도 명세<sup>contract</sup>를 찾지만, 이 디렉토리는 Spring Cloud Contract 3.0.0부터 deprecated되었다.

또 하나 주의할 점은, `src/contractTest` 경로를 사용하려면, 명세<sup>contract</sup> 테스트 내에서 사용하는 모든 베이스 클래스를 `src/contractTest/{language}`로 마이그레이션해야 한다. 이때 `{language}`는 사용하는 언어에 따라 Java 또는 Groovy로 대체하면 된다.

스텁<sup>stub</sup> 정의가 담겨있는 디렉토리명을 클래스 이름으로 매핑하며, 각 스텁<sup>stub</sup> 정의는 하나의 테스트로 취급한다. Spring Cloud Contract Verifier는 테스트 클래스 이름으로 사용할 디렉토리가 적어도 한 depth 이상 포함되어 있다고 가정한다. 여러 depth로 중첩된 디렉토리가 존재한다면, 마지막 디렉토리를 제외한 나머지는 패키지 이름으로 사용한다. 예를 들어 아래와 같은 구조를 사용한다면:

```sh
src/contractTest/resources/contracts/myservice/shouldCreateUser.groovy
src/contractTest/resources/contracts/myservice/shouldReturnUser.groovy
```

Spring Cloud Contract Verifier는 위와 같은 구조에선, 아래 두 개의 메소드를 가진 `defaultBasePackage.MyService`라는 테스트 클래스를 생성한다:

- `shouldCreateUser()`
- `shouldReturnUser()`

---

## 5.6. Running the Plugin

그래들 플러그인은 `check` 태스크 전에 실행할 Spring Cloud Contract 관련 태스크를 등록해준다. 즉, 따로 뭘 해주지 않아도 알아서 빌드 프로세스에 포함된다. 테스트만 생성하고 싶다면 `generateContractTests` 태스크를 실행해라.

---

## 5.7. Default Setup

디폴트 그래들 플러그인 세팅에서는 빌드 과정에 다음과 같은 Gradle 설정을 추가한다 (슈도 코드):

```groovy
contracts {
    testFramework ='JUNIT'
    testMode = 'MockMvc'
    generatedTestJavaSourcesDir = project.file("$\{project.buildDir}/generated-test-sources/contractTest/java")
    generatedTestGroovySourcesDir = project.file("$\{project.buildDir}/generated-test-sources/contractTest/groovy")
    generatedTestResourcesDir = project.file("$\{project.buildDir}/generated-test-resources/contracts")
    contractsDslDir = project.file("$\{project.projectDir}/src/contractTest/resources/contracts")
    basePackageForTests = 'org.springframework.cloud.verifier.tests'
    stubsOutputDir = project.file("$\{project.buildDir}/stubs")
    sourceSet = null
}

def verifierStubsJar = tasks.register(type: Jar, name: 'verifierStubsJar', dependsOn: 'generateClientStubs') {
    baseName = project.name
    classifier = contracts.stubsSuffix
    from contractVerifier.stubsOutputDir
}

def copyContracts = tasks.register(type: Copy, name: 'copyContracts') {
    from contracts.contractsDslDir
    into contracts.stubsOutputDir
}

verifierStubsJar.dependsOn copyContracts
```

---

## 5.8. Configuring the Plugin

디폴트 설정을 변경하고 싶다면, 다음과 같이 그래들 설정에 `contracts` 스니펫을 추가해주면 된다:

```groovy
contracts {
	testMode = 'MockMvc'
	baseClassForTests = 'org.mycompany.tests'
	generatedTestJavaSourcesDir = project.file('src/generatedContract')
}
```

원격 소스에서 명세<sup>contract</sup>를 다운받으려면, 필요에 따라 아래 스니펫을 이용하면 된다:

```groovy
contracts {
    // If your contracts exist in a JAR archive published to a Maven repository
    contractDependency {
        stringNotation = ''
        // OR
        groupId = ''
        artifactId = ''
        version = ''
        classifier = ''
    }

    // If your contracts exist in a Git SCM repository
    contractRepository {
        repositoryUrl = ''
        // username = ''
        // password = ''
    }

    // controls the nested location to find the contracts in either the JAR or Git SCM source
    contractsPath = ''
}
```

여기서는 그래들의 Jar 패키징 태스크를 사용하고 있기 때문에, 몇 가지 옵션과 기능을 이용해 `verifierStubsJar`로 생성하는 것을 더 확장할 수 있다. 그래들에서 직접 제공하는 네이티브 메커니즘을 이용해 기존 태스크를 다음과 같이 커스텀하면 된다:

> 여기에선 단순 예시로 `git.properties` 파일을 `verifierStubsJar`에 추가해본다.

```groovy
verifierStubsJar {
    from("$\{buildDir}/resources/main/") {
        include("git.properties")
    }
}
```

추가로, 3.0.0 버전부터 jar 파일을 배포하는 기본 설정이 비활성화되었다는 것도 참고해라. 그렇기 때문에 이제 원하는 이름으로 jar 파일을 생성하고, 평소대로 Gradle 설정 옵션을 통해 배포하면 된다. 즉, jar 파일을 원하는 대로 커스텀해서 빌드하고 jar 레이아웃과 컨텐츠를 완전히 제어해서 배포할 수 있다.

---

## 5.9. Configuration Options

- `testMode`: 인수 테스트<sup>acceptance test</sup> 모드를 정의한다. 디폴트는 스프링의 MockMvc를 기반으로 동작하는 MockMvc다. WebTestClient, JaxRsClient, Explicit(실제 HTTP를 호출할 때)으로도 변경할 수 있다.
- `imports`: 테스트를 자동 생성할 때 포함시킬 import 구분의 배열을 생성한다 (e.g. `['org.myorg.Matchers']`). 기본값은 빈 배열이다.
- `staticImports`: 테스트를 자동 생성할 때 포함시킬 static import 구문의 배열을 생성한다 (e.g. `['org.myorg.Matchers.*']`). 기본값은 빈 배열이다.
- `basePackageForTests`: 자동 생성된 모든 테스트에서 사용할 기본 패키지를 지정한다. 따로 설정하지 않으면 `baseClassForTests`의 패키지나 `packageWithBaseClasses` 값을 사용한다. 이 두 값도 다 지정하지 않았다면 `org.springframework.cloud.contract.verifier.tests`로 설정한다.
- `baseClassForTests`: 자동 생성된 모든 테스트에서 사용할 베이스 클래스를 생성한다. Spock 클래스를 사용하는 경우 기본값은 `spock.lang.Specification`이다.
- `packageWithBaseClasses`: 모든 베이스 클래스가 들어있는 패키지를 정의한다. 이 설정은 `baseClassForTests`보다 우선시된다.
- `baseClassMappings`: 명세<sup>contract</sup> 패키지를 베이스 클래스의 FQN에 명시적으로 매핑한다. 이 설정은 `packageWithBaseClasses`, `baseClassForTests`보다 우선시된다.
- `ignoredFiles`: `Antmatcher`를 사용해 처리를 생략할 스텁<sup>stub</sup> 파일을 정의한다. 디폴트는 빈 배열이다.
- `contractsDslDir`: Groovy DSL로 작성한 명세<sup>contract</sup>가 들어있는 디렉토리를 지정한다. 디폴트는 `$projectDir/src/contractTest/resources/contracts`다.
- `generatedTestSourcesDir`: Groovy DSL로 생성된 테스트를 저장할 테스트 소스 디렉토리를 지정한다. (Deprecrated)
- `generatedTestJavaSourcesDir`: Groovy DSL로 생성된 Java/JUnit 테스트를 저장할 테스트 소스 디렉토리를 지정한다. 디폴트는 `$buildDir/generated-tes-sources/contractTest/java`다.
- `generatedTestGroovySourcesDir`: Groovy DSL로 생성된 Groovy/Spock 테스트를 저장할 테스트 소스 디렉토리를 지정한다. 디폴트는 `$buildDir/generated-test-sources/contractTest/groovy`다.
- `generatedTestResourcesDir`: Groovy DSL로 생성된 테스트에서 사용하는 리소스를 저장할 테스트 리소스 디렉토리를 지정한다. 디폴트는 `$buildDir/generated-test-resources/contractTest`다.
- `stubsOutputDir`: Groovy DSL로 생성된 WireMock 스텁<sup>stub</sup>을 저장할 디렉토리를 지정한다.
- `testFramework`: 사용할 타켓 테스트 프레임워크를 지정한다. 현재 Spock, JUnit 4(`TestFramework.JUNIT`), JUnit 5를 지원하며, JUnit 4가 디폴트다.
- `contractsProperties`: Spring Cloud Contract 컴포넌트에 전달할 프로퍼티가 담긴 맵. 이 프로퍼티들은 빌트인 또는 커스텀 Stub Downloader 등에서 사용할 수 있다.
- `sourceSet`: 명세<sup>contract</sup>가 저장된 소스 셋. 값을 제공하지 않으면 `contractTest`로 가정한다 (예를 들어 JUnit에선 `project.sourceSets.contractTest.java`, Spock에선 `project.sourceSets.contractTest.groovy`).

명세<sup>contract</sup>가 포함된 JAR의 위치를 지정하고 싶다면 아래 프로퍼티들을 사용하면 된다:

- `contractDependency`: `groupid:artifactid:version:classifier`로 의존성을 지정한다. `contractDependency` 클로저를 사용해서 설정할 수 있다.
- `contractsPath`: jar가 있는 경로를 지정한다. 명세<sup>contract</sup> 의존성을 다운받는 경우, 디폴트 경로는 `groupid/artifactid`이며, 이때 `groupid`는 슬래시로 구분한다. 그 외는 지정한 디렉토리에서 명세<sup>contract</sup>를 스캔한다.
- `contractsMode`: 명세<sup>contract</sup>의 다운로드 모드를 지정한다 (JAR를 오프라인에서 사용할 수 있는지, 원격으로 사용할 수 있는지 등).
- `deleteStubsAfterTest`: `false`로 설정하면 다운로드한 명세<sup>contract</sup>를 임시 디렉토리에서 제거하지 않는다.
- `failOnNoContracts`: 활성화하면 명세<sup>contract</sup>를 찾을 수 없을 때 예외를 던진다. 디폴트는 `true`다.
- `failOnInProgress`: `true`로 설정하면 개발 중인<sup>in progress</sup> 명세<sup>contract</sup>를 발견할 시 빌드를 중단한다. 프로듀서<sup>producer</sup> 측에서는 개발 중인<sup>in progress</sup> 명세<sup>contract</sup>가 있다는 사실을 명시해야 하며, 컨슈머<sup>consumer</sup> 쪽에서 테스트가 통과한 것으로 오해할 수 있다는 점을 명심해야 한다. 디폴트는 `true`다.

다음 프로퍼티를 포함하는 `contractRepository { … }` 클로저도 제공한다

- `repositoryUrl`: 명세<sup>contract</sup> 정의가 있는 레포지토리 URL
- `username` : 레포지토리 username
- `password` : 레포지토리 password
- `proxyPort` : 프록시 포트
- `proxyHost` : 프록시 호스트
- `cacheDownloadedContracts` : `true`로 설정하면 스냅샷 외의 명세<sup>contract</sup> 아티팩트를 다운받은 폴더를 캐싱한다. 디폴트는 `true`다.

그래들 플러그인이 제공하는 실험적인 기능들도 사용해볼 수 있다:

- `convertToYaml`: 모든 DSL을 좀 더 선언적인<sup>declarative</sup> YAML 형식으로 변환한다. Groovy DSL에서 외부 라이브러리를 사용할 때 매우 유용할 수 있다. 이 기능을 켜면 (`true`로 설정), 컨슈머<sup>consumer</sup> 측에서 라이브러리 의존성을 추가하지 않아도 된다.
- `assertJsonSize`: 자동 생성한 테스트에서 JSON 배열의 크기를 체크할 수 있다. 이 기능은 기본적으로 비활성화돼 있다.

---

## 5.10. Single Base Class for All Tests

MockMvc에서 Spring Cloud Contract Verifier를 사용하는 경우 (디폴트), 모든 자동 생성 인수 테스트<sup>acceptance test</sup>에서 사용할 베이스 specification을 생성해야 한다. 이 클래스에서 어떤 엔드포인트를 대상으로 테스트를 진행할지를 정의하면 된다. 그 방법은 다음 예제를 참고해라:

```groovy
abstract class BaseMockMvcSpec extends Specification {

	def setup() {
		RestAssuredMockMvc.standaloneSetup(new PairIdController())
	}

	void isProperCorrelationId(Integer correlationId) {
		assert correlationId == 123456
	}

	void isEmpty(String value) {
		assert value == null
	}

}
```

`Explicit` 모드를 사용한다면, 일반적인 통합 테스트에서 흔히 볼 수 있듯이, 베이스 클래스를 통해 테스트하는 애플리케이션 전체를 초기화할 수 있다. `JAXRSCLIENT` 모드를 사용하는 경우, 베이스 클래스에 `protected WebTarget webTarget` 필드도 필요하다. 현재 JAX-RS API를 테스트하려면 웹 서버를 시작하는 방법밖에 없다.

---

## 5.11. Different Base Classes for Contracts

명세<sup>contract</sup>마다 베이스 클래스가 다르다면, 테스트를 자동 생성할 때 어떤 클래스를 상속할지 Spring Cloud Contract 플러그인에 지정할 수 있다. 다음과 같은 두 가지 옵션을 제공한다:

- `packageWithBaseClasses`를 지정해 컨벤션을 따르게 만든다
- `baseClassMappings`를 사용해 매핑 정보를 명시한다

### 5.11.1. By Convention

컨벤션이 뭐냐면, 예를 들어 `src/contractTest/resources/contract/foo/bar/baz/`에 명세<sup>contract</sup>를 저장하고 `packageWithBaseClasses` 프로퍼티 값을 `com.example.base`로 설정했다면, Spring Cloud Contract Verifier는 `com.example.base` 패키지 밑에 `BarBazBase` 클래스가 있다고 가정한다. 즉, 마지막에 두 depth의 디렉토리가 있다면, 이 두 디렉토리 명에 `Base`를 붙인 이름의 클래스를 찾는다. 이 규칙은 `baseClassForTests`보다 우선한다.

### 5.11.2. By Mapping

직접 정규식을 사용해 명세<sup>contract</sup> 패키지를 베이스 클래스의 풀네임<sup>fully qualified name</sup>에 매핑할 수 있다. `baseClassMappings`에는 목록을 지정해야 하는데, `contractPackageRegex`를 `baseClassFQN`에 매핑하는`baseClassMapping` 객체를 추가하면 된다.

다음과 같은 디렉토리에 명세<sup>contract</sup>가 있다고 가정해보자:

- `src/contractTest/resources/contract/com/`
- `src/contractTest/resources/contract/foo/`

매핑에 실패한 경우를 대비해서 폴백으로 `baseClassForTests`를 제공할 수 있다. (`packageWithBaseClasses`를 폴백으로 사용해도 좋다.) 이렇게 하면 `src/contractTest/resources/contract/com/`에 있는 명세<sup>contract</sup>로 생성한 테스트는 `com.example.ComBase`를 상속하고, 나머지 테스트는 `com.example.FooBase`를 상속하게 된다.

---

## 5.12. Invoking Generated Tests

프로듀서<sup>provider</sup>가 명세<sup>contract</sup>를 준수하고 있는지 확인하려면 다음 명령을 실행해라:

```bash
./gradlew contractTest
```

---

## 5.13. Publishing Stubs to Artifact Repository

바이너리 아티팩트 레포지토리에 스텁<sup>stub</sup>을 보관하는 경우, Gradle의 publishing 섹션에 `verifierStubsJar`를 포함시켜야 한다. 아래 설정 예시를 참고해라:

```groovy
apply plugin: 'maven-publish'

publishing {
    publications {
        maven(MavenPublication) {
            // other configuration

            artifact verifierStubsJar
        }
    }
}
```

3.0.0 버전부터 내부 스텁<sup>stub</sup> 배포는 deprecated 되었으며, 기본적으로 비활성화돼 있다. 자체 배포 설정에 `verifierStubsJar`를 추가하는 것을 권장한다.

---

## 5.14. Pushing Stubs to SCM

SCM 레포지토리에 명세<sup>contract</sup>와 스텁<sup>stub</sup>을 보관하는 경우, 스텁<sup>stub</sup>을 레포지토리에 푸시하는 과정을 자동화하고 싶을 수 있다. 이땐 아래 명령어를 실행해 `pushStubsToScm` 태스크를 호출하면 된다:

```bash
$ ./gradlew pushStubsToScm
```

[SCM Stub Downloader 사용하기](../pluggable-architecture/#836-using-the-scm-stub-downloader) 페이지에서는, `contractsProperties` 필드를 이용하는 방법 (e.g. `contracts { contractsProperties = [foo:"bar"] }`), `contractsProperties` 메소드를 이용하는 방법 (e.g. `contracts { contractsProperties([foo:"bar"]) }`), 시스템 프로퍼티나 환경 변수를 통해 전달하는 방법 등, 가능한 모든 설정 방법을 확인할 수 있다.

---

## 5.15. Spring Cloud Contract Verifier on the Consumer Side

컨슈머<sup>consumer</sup> 서비스에서도 프로듀서<sup>provider</sup>와 똑같은 방식으로 Spring Cloud Contract Verifier 플러그인을 구성해야 한다. Stub Runner를 사용하지 않는다면, `src/contractTest/resources/contracts`에 있는 명세<sup>contract</sup>를 복사해간 후 아래 명령어를 실행해 WireMock JSON 스텁<sup>stub</sup>을 생성해야 한다:

```bash
./gradlew generateClientStubs
```

> `stubsOutputDir` 옵션을 설정해야 스텁<sup>stub</sup>이 생성된다.

스텁<sup>stub</sup>이 만들어졌다면, 자동 테스트에서 JSON 스텁<sup>stub</sup>을 사용해 서비스를 컨슘할 수 있다. 다음 예제를 참고해라:

```groovy
@ContextConfiguration(loader == SpringApplicationContextLoader, classes == Application)
class LoanApplicationServiceSpec extends Specification {

 @ClassRule
 @Shared
 WireMockClassRule wireMockRule == new WireMockClassRule()

 @Autowired
 LoanApplicationService sut

 def 'should successfully apply for loan'() {
   given:
 	LoanApplication application =
			new LoanApplication(client: new Client(clientPesel: '12345678901'), amount: 123.123)
   when:
	LoanApplicationResult loanApplication == sut.loanApplication(application)
   then:
	loanApplication.loanApplicationStatus == LoanApplicationStatus.LOAN_APPLIED
	loanApplication.rejectionReason == null
 }
}
```

위 예제에선 `LoanApplication`은 `FraudDetection` 서비스를 호출한다. 이 요청은 Spring Cloud Contract Verifier가 생성한 스텁<sup>stub</sup>으로 구성된 WireMock 서버가 처리한다.