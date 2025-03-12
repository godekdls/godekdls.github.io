---
title: 3.6.2. Publishing Stubs as JARs
navTitle: Publishing Stubs as JARs
category: Spring Cloud Contract
order: 30
permalink: /Spring%20Cloud%20Contract/stub-runner-publishing-stubs-as-jars/
description: jar안에 스텁 패키징하기
image: ./../../images/springcloud/logo.jpeg
lastmod: 2025-03-12T23:34:00+09:00
comments: true
originalRefName: 스프링 클라우드 컨트랙트
originalRefLink: https://docs.spring.io/spring-cloud-contract/reference/4.2.0/project-features-stubrunner/stub-runner-publishing-stubs-as-jars.html
parent: Spring Cloud Contract Features
parentUrl: /Spring%20Cloud%20Contract/features/
subparent: 3.6. Spring Cloud Contract Stub Runner
subparentNavTitle: Spring Cloud Contract Stub Runner
subparentUrl: /Spring%20Cloud%20Contract/features-stubrunner/
---
<script>defaultLanguages = ['maven']</script>

---

스텁<sup>stub</sup>을 jar에 담아 배포하는 가장 쉬운 방법은 중앙 저장소에 스텁<sup>stub</sup>을 모아 보관하는 것이다. 예를 들면 Maven 레포지토리에 jar로 보관할 수 있다.

> Maven과 Gradle 모두 바로 사용할  수 있는 설정이 준비되어 있다. 하지만 원한다면 커스텀해도 된다.

다음은 스텁<sup>stub</sup>을 jar로 배포하는 예시다:

<div class="switch-language-wrapper maven gradle">
<span class="switch-language maven">Maven</span>
<span class="switch-language gradle">Gradle</span>
</div>
<div class="language-only-for-maven maven gradle"></div>
```xml
<!-- First disable the default jar setup in the properties section -->
<!-- we don't want the verifier to do a jar for us -->
<spring.cloud.contract.verifier.skip>true</spring.cloud.contract.verifier.skip>

<!-- Next add the assembly plugin to your build -->
<!-- we want the assembly plugin to generate the JAR -->
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-assembly-plugin</artifactId>
    <executions>
        <execution>
            <id>stub</id>
            <phase>prepare-package</phase>
            <goals>
                <goal>single</goal>
            </goals>
            <inherited>false</inherited>
            <configuration>
                <attach>true</attach>
                <descriptors>
                    $/tmp/releaser-1706278322902-0/spring-cloud-contract/docs/src/assembly/stub.xml
                </descriptors>
            </configuration>
        </execution>
    </executions>
</plugin>

<!-- Finally setup your assembly. Below you can find the contents of src/main/assembly/stub.xml -->
<assembly
    xmlns="http://maven.apache.org/plugins/maven-assembly-plugin/assembly/1.1.3"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://maven.apache.org/plugins/maven-assembly-plugin/assembly/1.1.3 https://maven.apache.org/xsd/assembly-1.1.3.xsd">
    <id>stubs</id>
    <formats>
        <format>jar</format>
    </formats>
    <includeBaseDirectory>false</includeBaseDirectory>
    <fileSets>
        <fileSet>
            <directory>src/main/java</directory>
            <outputDirectory>/</outputDirectory>
            <includes>
                <include>**com/example/model/*.*</include>
            </includes>
        </fileSet>
        <fileSet>
            <directory>${project.build.directory}/classes</directory>
            <outputDirectory>/</outputDirectory>
            <includes>
                <include>**com/example/model/*.*</include>
            </includes>
        </fileSet>
        <fileSet>
            <directory>${project.build.directory}/snippets/stubs</directory>
            <outputDirectory>META-INF/${project.groupId}/${project.artifactId}/${project.version}/mappings</outputDirectory>
            <includes>
                <include>**/*</include>
            </includes>
        </fileSet>
        <fileSet>
            <directory>$/tmp/releaser-1706278322902-0/spring-cloud-contract/docs/src/test/resources/contracts</directory>
            <outputDirectory>META-INF/${project.groupId}/${project.artifactId}/${project.version}/contracts</outputDirectory>
            <includes>
                <include>**/*.groovy</include>
            </includes>
        </fileSet>
    </fileSets>
</assembly>
```
<div class="language-only-for-gradle maven gradle"></div>
```groovy
ext {
    contractsDir = file("mappings")
    stubsOutputDirRoot = file("${project.buildDir}/production/${project.name}-stubs/")
}

// Automatically added by plugin:
// copyContracts - copies contracts to the output folder from which JAR will be created
// verifierStubsJar - JAR with a provided stub suffix

publishing {
    publications {
        stubs(MavenPublication) {
            artifactId "${project.name}-stubs"
            artifact verifierStubsJar
        }
    }
}
```