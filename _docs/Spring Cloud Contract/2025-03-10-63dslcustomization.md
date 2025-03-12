---
title: 8.1. DSL Customization
navTitle: DSL Customization
category: Spring Cloud Contract
order: 64
permalink: /Spring%20Cloud%20Contract/dsl-customization/
description: DSL에서 커스텀 함수 사용하기
image: ./../../images/springcloud/logo.jpeg
lastmod: 2025-03-12T23:34:00+09:00
comments: true
originalRefName: 스프링 클라우드 컨트랙트
originalRefLink: https://docs.spring.io/spring-cloud-contract/reference/4.2.0/customization/dsl-customization.html
parent: Spring Cloud Contract customization
parentUrl: /Spring%20Cloud%20Contract/advanced/
---
<script>defaultLanguages = ['maven']</script>

---

이번 섹션에서 설명하는 내용은 Groovy DSL에만 해당하는 내용이다.

이곳에선 DSL을 확장해서 Spring Cloud Contract Verifier를 커스텀하는 방법을 설명한다.

### 목차

- [8.1.1. DSL 확장하기](#811-extending-the-dsl)
- [8.1.2. 공통 JAR](#812-common-jar)
- [8.1.3. 프로젝트 의존성에 테스트 의존성 추가하기](#813-adding-a-test-dependency-in-the-projects-dependencies)
- [8.1.4. 플러그인 의존성에 테스트 의존성 추가하기](#814-adding-a-test-dependency-in-the-plugins-dependencies)
- [8.1.5. DSL 안에서 클래스 참조하기](#815-referencing-classes-in-dsls)

### 8.1.1. Extending the DSL

DSL에서는 자체 정의한 함수를 호출할 수 있다. 이땐 컴파일 타임에 호환성<sup>static compatibility</sup>이 유지되기만 하면 된다. 아래에선 다음과 같은 예시를 살펴본다:

- 공통 로직을 담은<sup>reusable</sup> 클래스를 JAR에 함께 패키징한다.
- DSL에서 이 클래스를 참조한다.

전체 예제는 [이곳](https://github.com/spring-cloud-samples/spring-cloud-contract-samples)에서 확인할 수 있다.

### 8.1.2. Common JAR

다음은 DSL 안에서 재사용할 용도로 만든 세 가지 클래스를 보여준다.

`PatternUtils`에는 컨슈머<sup>consumer</sup>와 프로듀서<sup>producer</sup> 양쪽 모두 사용하는 함수가 들어 있다:

```java
package com.example;

import java.util.regex.Pattern;

/**
 * If you want to use {@link Pattern} directly in your tests
 * then you can create a class resembling this one. It can
 * contain all the {@link Pattern} you want to use in the DSL.
 *
 * <pre>
 * {@code
 * request {
 *     body(
 *         [ age: $(c(PatternUtils.oldEnough()))]
 *     )
 * }
 * </pre>
 *
 * Notice that we're using both {@code $()} for dynamic values
 * and {@code c()} for the consumer side.
 *
 * @author Marcin Grzejszczak
 */
//tag::impl[]
public class PatternUtils {

    public static String tooYoung() {

        return "[0-1][0-9]";

    }

    public static Pattern oldEnough() {

        return Pattern.compile("[2-9][0-9]");

    }

    /**
     * Makes little sense but it's just an example ;)
     */
    public static Pattern ok() {

        return Pattern.compile("OK");

    }
}
//end::impl[]
```

`ConsumerUtils`에는 컨슈머가 사용할 함수가 들어 있다:

```java
package com.example;

import org.springframework.cloud.contract.spec.internal.ClientDslProperty;

/**
 * DSL Properties passed to the DSL from the consumer's perspective.
 * That means that on the input side {@code Request} for HTTP
 * or {@code Input} for messaging you can have a regular expression.
 * On the {@code Response} for HTTP or {@code Output} for messaging
 * you have to have a concrete value.
 *
 * @author Marcin Grzejszczak
 */
//tag::impl[]
public class ConsumerUtils {
    /**
     * Consumer side property. By using the {@link ClientDslProperty}
     * you can omit most of boilerplate code from the perspective
     * of dynamic values. Example
     *
     * <pre>
     * {@code
     * request {
     *     body(
     *         [ age: $(ConsumerUtils.oldEnough())]
     *     )
     * }
     * </pre>
     *
     * That way it's in the implementation that we decide what value we will pass to the consumer
     * and which one to the producer.
     *
     * @author Marcin Grzejszczak
     */
    public static ClientDslProperty oldEnough() {

        // this example is not the best one and
        // theoretically you could just pass the regex instead of `ServerDslProperty` but
        // it's just to show some new tricks :)
        return new ClientDslProperty(PatternUtils.oldEnough(), 40);

    }

}
//end::impl[]
```

`ProducerUtils`에는 프로듀서<sup>producer</sup>가 사용할 함수가 들어 있다:

```java
package com.example;

import org.springframework.cloud.contract.spec.internal.ServerDslProperty;

/**
 * DSL Properties passed to the DSL from the producer's perspective.
 * That means that on the input side {@code Request} for HTTP
 * or {@code Input} for messaging you have to have a concrete value.
 * On the {@code Response} for HTTP or {@code Output} for messaging
 * you can have a regular expression.
 *
 * @author Marcin Grzejszczak
 */
//tag::impl[]
public class ProducerUtils {

    /**
     * Producer side property. By using the {@link ProducerUtils}
     * you can omit most of boilerplate code from the perspective
     * of dynamic values. Example
     *
     * <pre>
     * {@code
     * response {
     *     body(
     *         [ status: $(ProducerUtils.ok())]
     *     )
     * }
     * </pre>
     *
     * That way it's in the implementation that we decide what value we will pass to the consumer
     * and which one to the producer.
     */
    public static ServerDslProperty ok() {
        // this example is not the best one and
        // theoretically you could just pass the regex instead of `ServerDslProperty` but
        // it's just to show some new tricks :)
        return new ServerDslProperty( PatternUtils.ok(), "OK");
    }
}
//end::impl[]
```

### 8.1.3. Adding a Test Dependency in the Project’s Dependencies

프로젝트의 의존성에 테스트 의존성을 추가해야 한다. 먼저, 공통 jar를 테스트 의존성으로 추가한다. 명세<sup>contract</sup> 파일은 테스트 리소스 경로에 있기 때문에, 테스트 의존성만 추가하면 Groovy 파일에서 공통 jar 클래스를 사용할 수 있다. 다음은 테스트 의존성을 추가하는 예시다:

<div class="switch-language-wrapper maven gradle">
<span class="switch-language maven">Maven</span>
<span class="switch-language gradle">Gradle</span>
</div>
<div class="language-only-for-maven maven gradle"></div>
```xml
<dependency>
    <groupId>com.example</groupId>
    <artifactId>beer-common</artifactId>
    <version>${project.version}</version>
    <scope>test</scope>
</dependency>
```
<div class="language-only-for-gradle maven gradle"></div>
```groovy
testImplementation("com.example:beer-common:0.0.1-SNAPSHOT")
```

### 8.1.4. Adding a Test Dependency in the Plugin’s Dependencies

이제 런타임에 호출할 수 있도록, 플러그인에도 의존성을 추가해야 한다.

<div class="switch-language-wrapper maven gradle">
<span class="switch-language maven">Maven</span>
<span class="switch-language gradle">Gradle</span>
</div>
<div class="language-only-for-maven maven gradle"></div>
```xml
<plugin>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-contract-maven-plugin</artifactId>
    <version>${spring-cloud-contract.version}</version>
    <extensions>true</extensions>
    <configuration>
        <testFramework>JUNIT5</testFramework>
        <packageWithBaseClasses>com.example</packageWithBaseClasses>
        <baseClassMappings>
            <baseClassMapping>
                <contractPackageRegex>.*intoxication.*</contractPackageRegex>
                <baseClassFQN>com.example.intoxication.BeerIntoxicationBase</baseClassFQN>
            </baseClassMapping>
        </baseClassMappings>
    </configuration>
    <dependencies>
        <dependency>
            <groupId>com.example</groupId>
            <artifactId>beer-common</artifactId>
            <version>${project.version}</version>
            <scope>compile</scope>
        </dependency>
    </dependencies>
</plugin>
```
<div class="language-only-for-gradle maven gradle"></div>
```groovy
classpath "com.example:beer-common:0.0.1-SNAPSHOT"
```

### 8.1.5. Referencing Classes in DSLs

이제 다음과 같이 직접 만든 클래스를 DSL에서 참조할 수 있다:

{% raw %}
<div class="language-groovy highlighter-rouge"><div class="highlight"><pre class="highlight"><code><span class="kn">package</span> <span class="nn">contracts.beer.rest</span>

<span class="kn">import</span> <span class="nn">com.example.ConsumerUtils</span>
<span class="kn">import</span> <span class="nn">com.example.ProducerUtils</span>
<span class="kn">import</span> <span class="nn">org.springframework.cloud.contract.spec.Contract</span>

<span class="n">Contract</span><span class="o">.</span><span class="na">make</span> <span class="o">{</span>
    <span class="n">description</span><span class="o">(</span><span class="s2">"""
Represents a successful scenario of getting a beer

```
given:
    client is old enough
when:
    he applies for a beer
then:
    we'll grant him the beer
```

"""</span><span class="o">)</span>
    <span class="n">request</span> <span class="o">{</span>
        <span class="n">method</span> <span class="s1">'POST'</span>
        <span class="n">url</span> <span class="s1">'/check'</span>
        <span class="n">body</span><span class="o">(</span>
                <span class="nl">age:</span> <span class="n">$</span><span class="o">(</span><span class="n">ConsumerUtils</span><span class="o">.</span><span class="na">oldEnough</span><span class="o">())</span>
        <span class="o">)</span>
        <span class="n">headers</span> <span class="o">{</span>
            <span class="n">contentType</span><span class="o">(</span><span class="n">applicationJson</span><span class="o">())</span>
        <span class="o">}</span>
    <span class="o">}</span>
    <span class="n">response</span> <span class="o">{</span>
        <span class="n">status</span> <span class="mi">200</span>
        <span class="nf">body</span><span class="o">(</span><span class="s2">"""
            {
                "status": "${value(ProducerUtils.ok())}"
            }
            """</span><span class="o">)</span>
        <span class="n">headers</span> <span class="o">{</span>
            <span class="n">contentType</span><span class="o">(</span><span class="n">applicationJson</span><span class="o">())</span>
        <span class="o">}</span>
    <span class="o">}</span>
<span class="o">}</span>
</code></pre></div></div>
{% endraw %}

> Spring Cloud Contract 플러그인을 세팅할 때 `convertToYaml`을 `true`로 설정해도 된다. 이렇게 하면 컨슈머<sup>consumer</sup> 측에선 Groovy가 아닌 YAML 명세<sup>contract</sup>를 사용하기 때문에, 컨슈머<sup>consumer</sup> 쪽에는 커스텀 함수 의존성을 추가하지 않아도 된다.