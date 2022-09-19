---
title: Message Transformation
category: Spring Integration
order: 14
permalink: /Spring%20Integration/messaging-transformation/
description: 트랜스포머 인터페이스와 구현체들
image: ./../../images/springintegration/logo.png
lastmod: 2022-01-05T21:30:00+09:00
comments: true
originalRefName: 스프링 인티그레이션
parent: Core Messaging
originalRefLink: https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/index-single.html#messaging-transformation-chapter
parentUrl: /Spring%20Integration/core-messaging/
---

### 목차

- [9.1. Transformer](#91-transformer)
  + [9.1.1. Configuring a Transformer with XML](#911-configuring-a-transformer-with-xml)
  + [9.1.2. Transformers and Spring Expression Language (SpEL)](#912-transformers-and-spring-expression-language-spel)
  + [9.1.3. Common Transformers](#913-common-transformers)
    * [Object-to-String Transformer](#object-to-string-transformer)
    * [Object-to-Map and Map-to-Object Transformers](#object-to-map-and-map-to-object-transformers)
    * [Stream Transformer](#stream-transformer)
    * [JSON Transformers](#json-transformers)
    * [Apache Avro Transformers](#apache-avro-transformers)
  + [9.1.4. Configuring a Transformer with Annotations](#914-configuring-a-transformer-with-annotations)
  + [9.1.5. Header Filter](#915-header-filter)
  + [9.1.6. Codec-Based Transformers](#916-codec-based-transformers)
- [9.2. Content Enricher](#92-content-enricher)
  + [9.2.1. Header Enricher](#921-header-enricher)
    * [POJO Support](#pojo-support)
    * [SpEL Support](#spel-support)
    * [Configuring a Header Enricher with Java Configuration](#configuring-a-header-enricher-with-java-configuration)
    * [Configuring a Header Enricher with the Java DSL](#configuring-a-header-enricher-with-the-java-dsl)
    * [Header Channel Registry](#header-channel-registry)
  + [9.2.2. Payload Enricher](#922-payload-enricher)
    * [Configuration](#configuration)
    * [Examples](#examples)
    * [How Do I Pass Only a Subset of Data to the Request Channel?](#how-do-i-pass-only-a-subset-of-data-to-the-request-channel)
    * [How Can I Enrich Payloads that Consist of Collection Data?](#how-can-i-enrich-payloads-that-consist-of-collection-data)
    * [How Can I Enrich Payloads with Static Information without Using a Request Channel?](#how-can-i-enrich-payloads-with-static-information-without-using-a-request-channel)
- [9.3. Claim Check](#93-claim-check)
  + [9.3.1. Incoming Claim Check Transformer](#931-incoming-claim-check-transformer)
  + [9.3.2. Outgoing Claim Check Transformer](#932-outgoing-claim-check-transformer)
  + [9.3.3. Claim Once](#933-claim-once)
  + [9.3.4. A Word on Message Store](#934-a-word-on-message-store)
- [9.4. Codec](#94-codec)
  + [9.4.1. EncodingPayloadTransformer](#941-encodingpayloadtransformer)
  + [9.4.2. DecodingTransformer](#942-decodingtransformer)
  + [9.4.3. CodecMessageConverter](#943-codecmessageconverter)
  + [9.4.4. Kryo](#944-kryo)
    * [Customizing Kryo](#customizing-kryo)

---

## 9.1. Transformer

메시지 트랜스포머는 메시지 프로듀서와 메시지 컨슈머가 느슨한 결합을 유지하는 데 매우 중요한 역할을 한다. 메시지를 생산하는 구성 요소들이 전부 다음 컨슈머가 기대하는 타입을 알아야 하기보단, 중간에 트랜스포머를 추가해주면 된다. `String`을 XML 문서로 변환하는 트랜스포머 등, 범용 트랜스포머도 쉽게 재사용할 수 있다.

시스템에 따라 [표준<sup>canonical</sup> 데이터 모델](https://www.enterpriseintegrationpatterns.com/CanonicalDataModel.html)을 제공하는 게 가장 좋을 수도 있지만, Spring Integration의 전반적인 철학은 특정한 형식을 요구하지 않는 것이다. Spring Integration은 그보단 확장해서 쓸 수 있도록 최대한 간단한 모델을 제공해서 유연성을 극대화하는 것을 목표로 삼는다. 다른 엔드포인트 유형과 마찬가지로 XML이나 Java 어노테이션 설정을 선언해주면 단순한 POJO를 메시지 트랜스포머의 역할에 맞게 조정할 수 있다. 이 챕터에선 관련 설정 옵션들에 대해 설명한다.

> 스프링은 XML 기반 메시지 페이로드를 요구하지 않는다. 유연성을 끌어올리려는 목적이지만, 그럼에도 불구하고 스프링 프레임워크는 XML 기반 페이로드를 처리할 수 있는 간편한 트랜스포머를 몇 개 제공한다. 따라서 애플리케이션에 필요하다고 판단되면 직접 선택할 수 있다. 관련 트랜스포머 대한 정보는 [XML 지원 - XML 페이로드 처리하기](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/xml.html#xml)를 참고해라.

### 9.1.1. Configuring a Transformer with XML

메시지를 변환하는 엔드포인트를 생성할 때는 `<transformer>` 요소를 사용한다. 이 요소에선 `input-channel`과 `output-channel` 속성 외에도 `ref` 속성이 필요하다. `ref`는 하나의 메소드에 `@Transformer` 어노테이션을 선언하고 있는 객체를 가리키거나 ([어노테이션을 사용해 트랜스포머 설정하기](#914-configuring-a-transformer-with-annotations) 참고), `method` 속성에 메소드명을 함께 명시할 수도 있다.

```xml
<int:transformer id="testTransformer" ref="testTransformerBean" input-channel="inChannel"
             method="transform" output-channel="outChannel"/>
<beans:bean id="testTransformerBean" class="org.foo.TestTransformer" />
```

커스텀 트랜스포머 핸들러 구현체를 다른 `<transformer>` 정의에서 재사용할 수 있다면 일반적으로 `ref` 속성을 사용하는 것이 좋다. 하지만 커스텀 트랜스포머 핸들러 구현체의 스코프를 단일 `<transformer>` 단일 정의 내로 한정하고 싶다면, 다음 예제와 같이 내부 빈 정의를 제공해도 된다:

```xml
<int:transformer id="testTransformer" input-channel="inChannel" method="transform"
                output-channel="outChannel">
  <beans:bean class="org.foo.TestTransformer"/>
</transformer>
```

> 동일한 `<transformer>` 설정에서 `ref` 속성과 내부 핸들러 정의를 둘 다 사용하는 것은 허용하지 않는다. 둘 다 사용하면 조건이 모호해져 예외가 발생한다.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p><code class="highlighter-rouge">ref</code> 속성으로 <code class="highlighter-rouge">AbstractMessageProducingHandler</code>를 상속한 빈을 참조하는 경우 (프레임워크에서 자체적으로 제공하는 트랜스포머들), 출력 채널을 핸들러에 직접 주입하는 식으로 최적화된다. 이때는 각 <code class="highlighter-rouge">ref</code> 속성마다 별도 빈 인스턴스(또는 <code class="highlighter-rouge">prototype</code> 스코프 빈)를 참조하거나, 내부 <code class="highlighter-rouge">&lt;bean/&gt;</code> 설정을 이용해야 한다. 무심코 여러 빈에서 동일한 메시지 핸들러를 참조하면 설정 예외를 만나게될 거다.</p>
</blockquote>
POJO를 사용할 때는, 변환에 사용할 메소드는 인바운드 메시지의 `Message` 타입을 받을 수도 있고, 페이로드 타입을 받을 수도 있다. 또한 파라미터 어노테이션 `@Header`를 사용하면 메시지 헤더들을 개별적으로 받을 수 있고, `@Headers`를 이용하면 전체 헤더가 들어있는 맵을 받을 수 있다. 메소드의 반환 값은 어떤 타입이어도 상관 없다. `Message` 자체를 반환하면 트랜스포머의 출력 채널로 그대로 전달된다.

메시지 트랜스포머의 변환 메소드는 Spring Integration 2.0부터 더 이상 `null`을 반환할 수 없다. 메시지 트랜스포머는 항상 각 소스 메시지를 유효한 타겟 메시지로 변환해야 하기 때문에, `null`을 반환하면 예외가 발생한다. 다른 말로 하면 메시지 트랜스포머를 메시지 필터로 사용해선 안 된다는 뜻이다. 전용 `<filter>` 옵션이 따로 있기도 하다. 하지만 이런 식의 동작이 필요하다면 (구성 요소가 `null`을 반환할 수 있고, 에러로 간주해서는 안 된다면), 서비스 activator를 활용하면 된다. 서비스 activator의 `requires-reply` 값은 기본적으로 `false`이지만, `true`로 설정하면 트랜스포머에서처럼 `null` 반환 시 예외를 발생시킬 수 있다.

### 9.1.2. Transformers and Spring Expression Language (SpEL)

라우터, 애그리게이터나 다른 구성 요소들과 마찬가지로 Spring Integration 2.0에선 트랜스포머의 변환 로직이 비교적 단순하다면 언제든지 [SpEL 기능](https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#expressions)을 활용할 수 있다. 다음은 SpEL 표현식을 사용하는 방법을 보여주는 예시다:

```xml
<int:transformer input-channel="inChannel"
	output-channel="outChannel"
	expression="payload.toUpperCase() + '- [' + T(System).currentTimeMillis() + ']'"/>
```

위 예시에선 커스텀 트랜스포머를 작성하지 않고도 페이로드를 변환한다. 여기서 페이로드(`String`으로 가정한다)는 대문자로 변환되고, 포맷에 맞게 현재 타임스탬프와 연결한다.

### 9.1.3. Common Transformers

Spring Integration은 몇 가지 트랜스포머 구현체를 제공한다.

#### Object-to-String Transformer

`Object`를 `toString()`으로 변환하는 일은 꽤 흔하기 때문에 Spring Integration은 String `payload`를 가진 `Message`를 출력하는 `ObjectToStringTransformer`를 제공한다. 이때 `String`은 인바운드 메시지의 페이로드에서 `toString()` 연산을 호출한 결과다. 다음은 object-to-string 트랜스포머 인스턴스를 선언하는 방법을 보여주는 예시다:

```xml
<int:object-to-string-transformer input-channel="in" output-channel="out"/>
```

이 트랜스포머는 `file` 네임스페이스의 'outbound-channel-adapter'에 임의의 객체를 전송할 때도 활용할 수 있다. 이 채널 어댑터는 기본적으로 `String`, 바이트 배열, `java.io.File` 페이로드만 지원하지만, 어댑터가 데이터를 변환하기 직전에 이 트랜스포머를 추가한다. `toString()`을 호출한 결과가 파일에 쓰고자한 것과 같다면 문제 없이 잘 동작한다. 그렇지 않다면 앞에서 설명한 범용 'transformer' 요소를 사용해 커스텀 POJO 기반 트랜스포머를 제공하면 된다.

> 디버깅을 진행할 때라면 `logging-channel-adapter`가 메시지 페이로드를 기록할 수 있기 때문에 일반적으로 이 트랜스포머는 필요하지 않다. 자세한 내용은 [Wire Tap](../messaging-channels/#wire-tap)을 참고해라.

> object-to-string 트랜스포머는 매우 간단하다. 단순히 인바운드 페이로드에서 `toString()`을 호출한다. Spring Integration 3.0부터는 이 규칙에 두 가지 예외가 따른다:
>
> - 페이로드가 `char[]`라면 `new String(payload)`을 실행한다.
> - 페이로드가 `byte[]`라면, `new String(payload, charset)`을 실행하며, 여기서 `charset`은 기본적으로 UTF-8이다. `charset`은 트랜스포머에 charset 속성을 제공하면 수정할 수 있다.
>
> 좀더 정교한 동작이 필요하다면 (런타임에 charset을 동적으로 선택하는 등) object-to-string 트랜스포머 대신, 다음 예제와 같이 SpEL 표현식 기반 트랜스포머를 사용하면 된다:
>
> ```xml
> <int:transformer input-channel="in" output-channel="out"
>      expression="new java.lang.String(payload, headers['myCharset']" />
> ```

`Object`를 바이트 배열로 직렬화하거나, 바이트 배열을 다시 `Object`로 역직렬화해야 하는 경우, Spring Integration은 직렬화 트랜스포머를 각각 제공하며, 이 둘은 서로 대칭적으로 동작한다. 이 구현체들은 기본적으로 표준 자바 직렬화를 사용하지만, `serializer`와 `deserializer` 속성을 사용해 스프링 `Serializer`와 `Deserializer` 전략 구현체를 제공할 수 있다. 다음은 스프링의 serializer와 deserializer를 사용하는 예시다:

```xml
<int:payload-serializing-transformer input-channel="objectsIn" output-channel="bytesOut"/>

<int:payload-deserializing-transformer input-channel="bytesIn" output-channel="objectsOut"
    allow-list="com.mycom.*,com.yourcom.*"/>
```

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>신뢰할 수 없는 소스에서 받은 데이터를 역직렬화한다면, 패키지와 클래스 패턴으로 <code class="highlighter-rouge">allow-list</code>를 추가하는 것을 고려해봐야 한다. 기본적으로는 모든 클래스로 역직렬화할 수 있다.</p>
</blockquote>

#### `Object`-to-`Map` and `Map`-to-`Object` Transformers

Spring Integration은 JSON을 사용해 객체 그래프를 직렬화, 역직렬화하는 `Object`-to-`Map` / `Map`-to-`Object` 트랜스포머도 제공한다. 객체 계층 구조는 가장 원시적인<sup>primitive</sup> 타입(`String`, `int` 등)으로 분석된다. 이 타입까지의 경로는 SpEL로 묘사하며, 이 경로가 바로 변환을 마친 `Map`의 `key`가 된다. primitive 타입은 값이 된다.

아래 예시를 생각해보자:

```java
public class Parent{
    private Child child;
    private String name;
    // setters and getters are omitted
}

public class Child{
    private String name;
    private List<String> nickNames;
    // setters and getters are omitted
}
```

위 예시에 있는 두 클래스는 아래와 같은 `Map`으로 변환된다:

```none
{person.name=George, person.child.name=Jenna, person.child.nickNames[0]=Jen ...}
```

JSON 기반의 `Map`을 사용하면 실제 타입을 공유하지 않아도 객체 구조를 설명할 수 있기 때문에, 구조만 유지해준다면 객체 그래프를 복원하고 또 다른 유형의 객체 그래프로 재구성할 수 있다.

예를 들면, 위 구조는 `Map`-to-`Object` 트랜스포머를 사용해 다음과 같은 객체 그래프로 재복원할 수 있다:

```java
public class Father {
    private Kid child;
    private String name;
    // setters and getters are omitted
}

public class Kid {
    private String name;
    private List<String> nickNames;
    // setters and getters are omitted
}
```

"구조화된<sup>structured</sup>" 맵을 생성해야 한다면 `flatten` 속성을 지정해주면 된다. 기본값은 'true'다. 'false'로 변경하면 `Map` 객체들을 가지고 있는 `Map`을 구성한다.

아래 예시를 생각해보자:

```java
public class Parent {
	private Child child;
	private String name;
	// setters and getters are omitted
}

public class Child {
	private String name;
	private List<String> nickNames;
	// setters and getters are omitted
}
```

위 예시에 있는 두 클래스는 아래와 같은 `Map`으로 변환된다:

```none
{name=George, child={name=Jenna, nickNames=[Bimbo, ...]}}
```

이 트랜스포머를 설정하려면 다음과 같이 Spring Integration이 제공하는 Object-to-Map 전용 네임스페이스를 사용하면 된다:

```xml
<int:object-to-map-transformer input-channel="directInput" output-channel="output"/>
```

`flatten` 속성을 설정할 땐 다음과 같이 해주면 된다:

```xml
<int:object-to-map-transformer input-channel="directInput" output-channel="output" flatten="false"/>
```

Spring Integration은 다음과 같은 Map-to-Object 전용 네임스페이스도 지원한다:

```xml
<int:map-to-object-transformer input-channel="input"
                         output-channel="output"
                         type="org.something.Person"/>
```

아니면 다음 예제같이 `ref` 속성과 프로토타입 스코프 빈을 사용하는 방법도 있다:

```xml
<int:map-to-object-transformer input-channel="inputA"
                               output-channel="outputA"
                               ref="person"/>
<bean id="person" class="org.something.Person" scope="prototype"/>
```

> 'ref' 속성과 'type' 속성은 함께 사용할 수 없다. 또한 'ref' 속성을 사용하는 경우, 반드시 'prototype' 스코프에 있는 빈을 가리켜야 한다. 그렇지 않으면 `BeanCreationException`이 발생한다.

5.0 버전부터 `ObjectToMapTransformer`는 커스텀 `JsonObjectMapper`를 지정할 수 있다. 날짜에 특별한 포맷이 필요하거나, 빈 컬렉션에 null이 필요한 경우 등에 활용할 수 있다 (다른 용도로도 활용 가능). `JsonObjectMapper` 구현체에 대한 자세한 내용은 [JSON 트랜스포머](#json-transformers)를 참고해라.

#### Stream Transformer

`StreamTransformer`는 `InputStream` 페이로드를 `byte[]`로 변환해준다 (`charset`을 제공한 경우는 `String`으로).

다음은  XML에서 `stream-transformer` 요소를 사용하는 방법을 보여주는 예시다:

```xml
<int:stream-transformer input-channel="directInput" output-channel="output"/> <!-- byte[] -->

<int:stream-transformer id="withCharset" charset="UTF-8"
    input-channel="charsetChannel" output-channel="output"/> <!-- String -->
```

다음은 `StreamTransformer` 클래스와 `@Transformer` 어노테이션을 이용해 자바 코드로 스트림 트랜스포머를 설정하는 예시다:

```java
@Bean
@Transformer(inputChannel = "stream", outputChannel = "data")
public StreamTransformer streamToBytes() {
    return new StreamTransformer(); // transforms to byte[]
}

@Bean
@Transformer(inputChannel = "stream", outputChannel = "data")
public StreamTransformer streamToString() {
    return new StreamTransformer("UTF-8"); // transforms to String
}
```

#### JSON Transformers

Spring Integration은 Object-to-JSON / JSON-to-Object 트랜스포머를 제공한다. 아래 두 예시에선 XML로 이 트랜스포머를 선언하고 있다:

```xml
<int:object-to-json-transformer input-channel="objectMapperInput"/>
```

```xml
<int:json-to-object-transformer input-channel="objectMapperInput"
    type="foo.MyDomainObject"/>
```

기본적으로 위에 있는 트랜스포머들은 순수<sup>vanilla</sup> `JsonObjectMapper`를 사용한다. 이땐 클래스패스에 있는 구현체를 기반으로 동작한다. 다음과 같이 적절한 옵션을 사용하거나 필요한 라이브러리(ex. GSON)를 추가해 커스텀 `JsonObjectMapper` 구현체를 제공할 수도 있다:

```xml
<int:json-to-object-transformer input-channel="objectMapperInput"
    type="something.MyDomainObject" object-mapper="customObjectMapper"/>
```

> 3.0 버전부터 `object-mapper` 속성은 새로운 전략 인터페이스 `JsonObjectMapper`의 인스턴스를 참조한다. 이렇게 추상화한 덕분에 여러 가지 JSON 매퍼 구현체를 사용할 수 있다. [Jackson 2](https://github.com/FasterXML)를 감싸고 있는 구현체를 제공하며, 버전은 클래스패스에서 감지한다. 구현 클래스의 이름은 `Jackson2JsonObjectMapper`다.

`JsonObjectMapper`를 필요한 특성에 맞게 생성하기 위해 `FactoryBean`이나 팩토리 메소드를 사용하는 것을 검토하고 있을 수도 있다. 다음은 이러한 팩토리를 사용하는 예시다:

```java
public class ObjectMapperFactory {

    public static Jackson2JsonObjectMapper getMapper() {
        ObjectMapper mapper = new ObjectMapper();
        mapper.configure(JsonParser.Feature.ALLOW_COMMENTS, true);
        return new Jackson2JsonObjectMapper(mapper);
    }
}
```

다음은 XML을 이용한 동일한 설정이다:

```xml
<bean id="customObjectMapper" class="something.ObjectMapperFactory"
            factory-method="getMapper"/>
```

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>2.2 버전부터 <code class="highlighter-rouge">object-to-json-transformer</code>는 입력 메시지에 <code class="highlighter-rouge">content-type</code> 헤더가 없으면 기본적으로 <code class="highlighter-rouge">application/json</code>으로 설정한다.</p>
  <p><code class="highlighter-rouge">content-type</code> 헤더를 다른 값으로 설정하거나 기존 헤더를 원하는 값(<code class="highlighter-rouge">application/json</code>도 포함해서)으로 명시적으로 재정의하고 싶다면 <code class="highlighter-rouge">content-type</code> 속성을 사용해라. 헤더 설정을 못하게 막고 싶다면 <code class="highlighter-rouge">content-type</code> 속성을 빈 문자열(<code class="highlighter-rouge">""</code>)로 설정해라. 이렇게 하면 입력 메시지에 이미 <code class="highlighter-rouge">content-type</code> 헤더가 있던게 아니라면 메시지에 이 헤더가 생기지 않는다.</p>
</blockquote>

3.0 버전부터 `ObjectToJsonTransformer`는 메시지에 소스 타입을 반영한 헤더를 추가한다. 마찬가지로 `JsonToObjectTransformer`는 JSON을 객체로 변환할 때 이 타입 헤더들을 활용할 수 있다. 이 헤더들은 AMQP 어댑터에 매핑되므로 Spring-AMQP [`JsonMessageConverter`](https://docs.spring.io/spring-amqp/api/)와 완전하게 호환된다.

덕분에 특별한 설정 없이도 다음과 같은 플로우를 동작시킬 수 있다:

- `…→amqp-outbound-adapter---→`
- `---→amqp-inbound-adapter→json-to-object-transformer→…`<br>아웃바운드 어댑터가 `JsonMessageConverter`로 설정돼있고, 인바운드 어댑터는 디폴트 `SimpleMessageConverter`를 사용하는 경우.
- `…→object-to-json-transformer→amqp-outbound-adapter---→`
- `---→amqp-inbound-adapter→…`<br>아웃바운드 어댑터가 `SimpleMessageConverter`로 설정돼있고, 인바운드 어댑터는 디폴트 `JsonMessageConverter`를 사용하는 경우.
- `…→object-to-json-transformer→amqp-outbound-adapter---→`
- `---→amqp-inbound-adapter→json-to-object-transformer→`<br>두 어댑터 모두 `SimpleMessageConverter`로 설정돼있는 경우.

> 헤더를 사용해 타입을 결정할 때는 `class` 속성을 제공해선 안 된다. 이 속성을 헤더보다 우선시하기 때문이다.

JSON 트랜스포머 외에도 Spring Integration은 표현식에서 사용할 수 있는 내장 `#jsonPath` SpEL 함수를 제공한다. 자세한 내용은 [스프링 표현식 언어(SpEL<sup>Spring Expression Language</sup>)](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/spel.html#spel)를 참고해라.

3.0 버전부터는 표현식에서 사용할 수 있는 `#xpath` SpEL 함수도 제공한다. 자세한 내용은 [#xpath SpEL 함수](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/xml.html#xpath-spel-function)를 참고해라.

4.0 버전 부터 `ObjectToJsonTransformer`는 노드 JSON을 표현하는 방법을 지정할 수 있도록 `resultType` 프로퍼티를 지원한다. 만들어지는 노드 트리는 사용하는 `JsonObjectMapper` 구현체에 따라 다르게 표현된다. 기본적으로 `ObjectToJsonTransformer`는 `Jackson2JsonObjectMapper`를 사용하며, 객체를 노드 트리로 변환하는 일은 `ObjectMapper#valueToTree` 메소드에 위임한다. 이후 다운스트림에선 SpEL 표현식 안에서도 JSON 데이터 프로퍼티에 액세스할 수 있는데, 이때 노드 JSON 표현을 잘 활용하면 `JsonPropertyAccessor`를 효율적으로 사용할 수 있다. 자세한 내용은 [프로퍼티 접근자](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/spel.html#spel-property-accessors)를 참고해라.

5.1 버전부터 이 `resultType`을 `BYTES`로 설정해 `byte[]` 페이로드를 가진 메시지를 생성할 수 있다. `byte[]`  로 동작하는 다운스트림 핸들러를 다룰 때 편리할 거다.

5.2 버전부터 `JsonToObjectTransformer`는 `ResolvableType`을 함께 설정하면 타겟 JSON 프로세서로 역직렬화할 때 제네릭을 지원할 수 있다. 또한 이제는 요청 메시지 헤더에 `JsonHeaders.RESOLVABLE_TYPE`이나 `JsonHeaders.TYPE_ID`가 있는지를 먼저 확인해보고 없으면 설정한 타입으로 폴백한다. `ObjectToJsonTransformer`는 이제 다운스트림에서 쉽게 대응할 수 있도록 요청 메시지의 페이로드를 기반으로 `JsonHeaders.RESOLVABLE_TYPE` 헤더를 채운다.

5.2.6 버전부터 `JsonToObjectTransformer`는 `valueTypeExpression`을 제공하면 런타임에 요청 메시지를 가지고 JSON으로부터 변환할 페이로드의 `ResolvableType`을 확인할 수 있다. 기본적으론 요청 메시지에 있는 `JsonHeaders`를 참조한다. 이 표현식이 `null`을 반환하거나 `ResolvableType`을 평가할 때 `ClassNotFoundException`이 발생하면, 트랜스포머는 지정한 `targetType`으로 폴백한다. 표현식을 사용하는 이유는 `JsonHeaders`가 실제 클래스 값이 아니라, 어떤 외부 레지스트리에 따라 타겟 클래스에 매핑시켜야 하는 특정 타입 ID를 가질 수 있기 때문이다.

#### Apache Avro Transformers

5.2 버전에선 Apache Avro를 변환하는 간단한 트랜스포머가 추가됐다.

스키마 레지스트리가 없기 때문에 그렇게까지 정교하진 않다. 이 트랜스포머는 단순히 Avro 스키마로 생성한 `SpecificRecord` 구현체에 임베딩된 스키마를 사용한다.

`SimpleToAvroTransformer`로 전송된 메시지엔 반드시 `SpecificRecord`를 구현한 페이로드가 있어야 한다. 이 트랜스포머는 여러 가지 타입을 처리할 수 있다. `SimpleFromAvroTransformer`를 설정할 땐 반드시 역직렬화할 디폴트 타입으로 쓸 `SpecificRecord` 클래스를 지정해야 한다. 또한 `setTypeExpression` 메소드를 사용하면 SpEL 표현식을 통해 역직렬화할 타입을 결정할 수 있다. 디폴트 SpEL 표현식은 `headers[avro_type]` (`AvroHeaders.TYPE`)으로, `SimpleToAvroTransformer`는 기본적으로 소스 클래스의 풀 네임<sup>fully qualified name</sup>으로 이 값을 채운다. 이 표현식이 `null`을 반환하면 `defaultType`을 사용한다.

`SimpleToAvroTransformer` 역시 `setTypeExpression` 메소드를 가지고 있다. 덕분에 sender는 타입을 나타내는 특정 토큰으로 헤더를 세팅할 수 있고, 컨슈머는 이 토큰을 타입에 매핑할 수 있어, 프로듀서와 컨슈머가 분리된다.

### 9.1.4. Configuring a Transformer with Annotations

`Message` 타입이나 메시지 페이로드 타입을 받는 메소드에 `@Transformer` 어노테이션을 추가해주면 된다. 이 메소드가 반환한 값은 [`<transformer>` 요소를 설명할 때](#911-configuring-a-transformer-with-xml) 말한 것과 똑같은 방식으로 처리된다. 다음은 `@Transformer` 어노테이션을 사용해 `String`을 `Order`로 변환하는 방법을 보여주는 예시다:

```java
@Transformer
Order generateOrder(String productId) {
    return new Order(productId);
}
```

트랜스포머 메소드는 어노테이션 지원 섹션에서 설명하는 것처럼 `@Header`, `@Headers` 어노테이션도 받을 수 있다. 다음은 `@Header` 어노테이션을 사용하는 예시다:

```java
@Transformer
Order generateOrder(String productId, @Header("customerName") String customer) {
    return new Order(productId, customer);
}
```

[어노테이션을 이용해 엔드포인트에 어드바이스 체인 적용하기](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/handler-advice.html#advising-with-annotations)도 함께 참고해라.

### 9.1.5. Header Filter

간혹 헤더 몇 개를 제거하는 것처럼 변환 로직이 매우 간단할 때가 있다. Spring Integration은 출력 메시지에서 제거해야 하는 헤더 이름들을 지정할 수 있는 헤더 필터를 제공한다 (예를 들어 보안 이슈로 헤더를 제거하거나, 임시로 사용한 값을 제거하는 등에 활용할 수 있다). 헤더 필터는 헤더 enricher와 정반대 개념이다. 헤더 enricher는 [여기](#921-header-enricher)에서 설명한다. 아래 설정은 헤더 필터를 정의하는 예시다:

```xml
<int:header-filter input-channel="inputChannel"
		output-channel="outputChannel" header-names="lastName, state"/>
```

보다시피 헤더 필터 설정은 매우 간단하다. 헤더 필터는 입출력 채널과 `header-names` 속성을 하나 가지고 있는 전형적인 엔드포인트다. 이 속성으론 제거해야 하는 헤더 이름들을 받는다 (여러 개일 땐 콤마로 구분한다). 즉, 위 예시에선 'lastName'과 'state'라는 헤더는 아웃바운드 메시지에 존재하지 않는다.

### 9.1.6. Codec-Based Transformers

[코덱](#94-codec)을 읽어봐라.

---

## 9.2. Content Enricher

때로는 요청에 타겟 시스템에서 제공한 정보보다 더 많은 정보를 담아야 할 때가 있다. [데이터 enricher](https://www.enterpriseintegrationpatterns.com/DataEnricher.html) 패턴에선 이러한 요구 사항을 해결할 수 있는 구성 요소(Enricher)와 다양한 시나리오를 함께 설명하고 있다.

Spring Integration `Core` 모듈에는 두 가지 enricher가 들어있다:

- [Header Enricher](#921-header-enricher)
- [Payload Enricher](#922-payload-enricher)

또한 어댑터 전용 헤더 enricher 세 가지도 함께 들어있다:

- [XPath Header Enricher (XML 모듈)](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/xml.html#xml-xpath-header-enricher)
- [Mail Header Enricher (Mail 모듈)](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/mail.html#mail-namespace)
- [XMPP Header Enricher (XMPP 모듈)](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/xmpp.html#xmpp-message-outbound-channel-adapter)

이 어댑터들을 자세히 알아보려면 이 레퍼런스 메뉴얼에 있는 어댑터 전용 섹션을 참고해라.

표현식 지원에 대한 자세한 설명은 [스프링 표현식 언어(SpEL<sup>Spring Expression Language</sup>)](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/spel.html#spel)를 확인해봐라.

### 9.2.1. Header Enricher

만약 메시지에 헤더를 추가하는 것 외에 다른 작업은 필요하지 않고, 메시지 내용을 통해 동적으로 헤더를 결정하는 것도 아니라면, 트랜스포머를 직접 구현해 사용하는 것은 조금 과하다고 할 수 있다. Spring Integration은 이럴 때 활용할 수 있는 헤더 enricher 패턴을 지원한다. 이 패턴은 `<header-enricher>` 요소로 이용할 수 있다. 다음은 사용법을 보여주는 예시다:

```xml
<int:header-enricher input-channel="in" output-channel="out">
    <int:header name="foo" value="123"/>
    <int:header name="bar" ref="someBean"/>
</int:header-enricher>
```

헤더 enricher는 다음 예제와 같이, 많이 사용하는 헤더를 설정할 때 유용한 하위 요소도 지원하고 있다:

```xml
<int:header-enricher input-channel="in" output-channel="out">
    <int:error-channel ref="applicationErrorChannel"/>
    <int:reply-channel ref="quoteReplyChannel"/>
    <int:correlation-id value="123"/>
    <int:priority value="HIGHEST"/>
    <routing-slip value="channel1; routingSlipRoutingStrategy; request.headers[myRoutingSlipChannel]"/>
    <int:header name="bar" ref="someBean"/>
</int:header-enricher>
```

범용 하위 요소 `<header>`를 사용할 땐 헤더 '이름'과 '값'을 둘 다 지정해야 하지만, 위 설정에선 자주 사용하는 헤더들(`errorChannel`, `correlationId`, `priority`, `replyChannel`, `routing-slip` 등)을 위해 따로 제공하는 하위 요소를 이용해 값을 바로 지정하고 있다.

4.1 버전부터 헤더 enricher는 `routing-slip`이란 하위 요소를 제공한다. 자세한 내용은 [라우팅 슬립](../messaging-routing/#routing-slip)을 참고해라.

#### POJO Support

헤더 값은 항상 정적으로 정의할 수 있는 것은 아니며, 메시지 내용을 기반으로 동적으로 결정해야 할 때가 있다. 이러한 이유로 헤더 enricher에선 `ref`와 `method` 속성을 통해 빈을 하나 참조할 수 있다. 지정한 메소드에선 헤더 값을 계산한다. 아래 설정에서 사용하는 빈은 `String`을 수정하는 메소드를 가지고 있다:

```xml
<int:header-enricher input-channel="in" output-channel="out">
    <int:header name="something" method="computeValue" ref="myBean"/>
</int:header-enricher>

<bean id="myBean" class="thing1.thing2.MyBean"/>
```

```java
public class MyBean {

    public String computeValue(String payload){
        return payload.toUpperCase() + "_US";
    }
}
```

아래 예제처럼 POJO를 내부 빈으로 설정할 수도 있다:

```xml
<int:header-enricher  input-channel="inputChannel" output-channel="outputChannel">
    <int:header name="some_header">
        <bean class="org.MyEnricher"/>
    </int:header>
</int:header-enricher>
```

유사하게 Groovy 스크립트를 가리킬 수 있도 있다:

```xml
<int:header-enricher  input-channel="inputChannel" output-channel="outputChannel">
    <int:header name="some_header">
        <int-groovy:script location="org/SampleGroovyHeaderEnricher.groovy"/>
    </int:header>
</int:header-enricher>
```

#### SpEL Support

Spring Integration 2.0에선 [스프링 표현식 언어(SpEL<sup>Spring Expression Language</sup>)](https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#expressions)를 도입했기 때문에 다양한 구성 요소에 활용할 수 있다. 헤더 enricher도 마찬가지다. 앞에서 다룬 POJO 예제를 다시 살펴보자. 가만보면 헤더 값을 결정하는 계산 로직은 꽤나 간단하다는 것을 알 수 있다. 더 간단한 방법은 없을지가 궁금할 거다. SpEL의 진정한 힘은 여기서 드러난다. 다음 예제를 살펴보자:

```xml
<int:header-enricher input-channel="in" output-channel="out">
    <int:header name="foo" expression="payload.toUpperCase() + '_US'"/>
</int:header-enricher>
```

이런 간단한 케이스에선 SpEL을 사용하면 더 이상 별도 클래스를 만들어 애플리케이션 컨텍스트에 설정하지 않아도 된다. `expression` 속성에 유효한 SpEL 표현식을 설정해주기만 하면 된다. SpEL 평가 컨텍스트엔 'payload'와 'headers' 변수가 바인딩되므로, 전달받은 메시지에 전부 접근할 수 있다.

#### Configuring a Header Enricher with Java Configuration

아래 두 예시에선 자바 코드를 통해 헤더 enricher를 설정하고 있다:

```java
@Bean
@Transformer(inputChannel = "enrichHeadersChannel", outputChannel = "emailChannel")
public HeaderEnricher enrichHeaders() {
    Map<String, ? extends HeaderValueMessageProcessor<?>> headersToAdd =
            Collections.singletonMap("emailUrl",
                      new StaticHeaderValueMessageProcessor<>(this.imapUrl));
    HeaderEnricher enricher = new HeaderEnricher(headersToAdd);
    return enricher;
}

@Bean
@Transformer(inputChannel="enrichHeadersChannel", outputChannel="emailChannel")
public HeaderEnricher enrichHeaders() {
    Map<String, HeaderValueMessageProcessor<?>> headersToAdd = new HashMap<>();
    headersToAdd.put("emailUrl", new StaticHeaderValueMessageProcessor<String>(this.imapUrl));
    Expression expression = new SpelExpressionParser().parseExpression("payload.from[0].toString()");
    headersToAdd.put("from",
               new ExpressionEvaluatingHeaderValueMessageProcessor<>(expression, String.class));
    HeaderEnricher enricher = new HeaderEnricher(headersToAdd);
    return enricher;
}
```

첫 번째 예시에선 헤더에 단순한 문자열을 하나 추가한다. 두 번째 예시에선 문자열 헤더 하나와, SpEL 표현식 기반 헤더를 추가하고 있다.

#### Configuring a Header Enricher with the Java DSL

다음은 Java DSL로 header enricher를 설정하는 예시다:

```java
@Bean
public IntegrationFlow enrichHeadersInFlow() {
    return f -> f
                ...
                .enrichHeaders(h -> h.header("emailUrl", this.emailUrl)
                                     .headerExpression("from", "payload.from[0].toString()"))
                .handle(...);
}
```

#### Header Channel Registry

Spring Integration 3.0부터 새로운 하위 요소 `<int:header-channels-to-string/>`을 사용할 수 있다. 이 요소에는 속성이 없다. 이 요소는 기존 `replyChannel`, `errorChannel` 헤더를 (`MessageChannel`이라면) `String`으로 변환하고, 응답을 전송하거나 에러를 처리할 때가 되면 채널을 사용할 수 있도록 레지스트리에 따로 저장한다. 이 기능은 메시지를 메시지 스토어로 직렬화하거나, 메시지를 JMS로 전송하는 등, 헤더가 손실될 수 있는 경우에 활용할 수 있다. 헤더가 존재하지 않거나 `MessageChannel`이 아니라면 아무것도 달라지지 않는다.

이 기능을 사용하려면 `HeaderChannelRegistry` 빈이 있어야 한다. 프레임워크는 기본적으로 디폴트 만료 시간(60초)으로 `DefaultHeaderChannelRegistry`를 하나 생성한다. 이 시간이 지나면 레지스트리에서 채널들이 제거된다. 이 동작을 변경하고 싶다면 `integrationHeaderChannelRegistry`라는 `id`로 빈을 정의하고, 원하는 디폴트 지연시간을 생성자 인자(밀리세컨드 단위)로 넘겨주면 된다.

4.1 버전부터는 `<bean/>` 정의에서 `removeOnGet`이란 속성을 `true`로 설정할 수 있으며, 그러면 매핑 항목을 처음 사용하는 즉시 제거한다. 이 속성은 reaper가 채널을 지울 때까지 기다리기보단, 채널을 한 번씩만 사용하는 대용량 환경에서 유용하다.

`HeaderChannelRegistry`는 레지스트리의 현재 사이즈를 결정하는 `size()` 메소드를 가지고 있다. `runReaper()` 메소드는 현재 예약된 태스크를 취소하고 reaper를 즉시 실행한다. 그런 다음 현재 지연 시간을 기반으로 다시 태스크를 예약한다. 이 메소들은 레지스트리에 대한 참조를 가져와 직접 호출해도 좋고, 메시지에 아래 예시와 같은 내용을 담아 컨트롤 버스에 전송할 수도 있다:

```none
"@integrationHeaderChannelRegistry.runReaper()"
```

이 하위 요소를 이용하면 간편하지만, 아래 설정을 지정해도 효과는 동일하다:

```xml
<int:reply-channel
    expression="@integrationHeaderChannelRegistry.channelToChannelName(headers.replyChannel)"
    overwrite="true" />
<int:error-channel
    expression="@integrationHeaderChannelRegistry.channelToChannelName(headers.errorChannel)"
    overwrite="true" />
```

4.1 버전부터는 레지스트리에 설정한 리퍼 지연 시간을 재정의해서, 리퍼 지연 시간에 관계없이 최소한 지정한 시간 동안은 채널 매핑을 유지하도록 만들 수 있다. 그 방법은 다음 예시를 참고해라:

```xml
<int:header-enricher input-channel="inputTtl" output-channel="next">
    <int:header-channels-to-string time-to-live-expression="120000" />
</int:header-enricher>

<int:header-enricher input-channel="inputCustomTtl" output-channel="next">
    <int:header-channels-to-string
        time-to-live-expression="headers['channelTTL'] ?: 120000" />
</int:header-enricher>
```

첫 번째 예시에선 모든 헤더 채널의 매핑 정보 TTL<sup>Time to Live</sup>이 2분이다. 두 번째 예시에선 TTL을 메시지 헤더에 지정하며, 헤더가 없는 경우 엘비스 연산자<sup>Elvis operator</sup>를 이용해 2분으로 설정한다.

### 9.2.2. Payload Enricher

상황에 따라서는 앞에서 설명한 헤더 enricher만으로는 부족하고, 페이로드 자체에 정보를 더 담아야 할 수도 있다. Spring Integration 메시징 시스템에 전달된 주문 메시지로 예를 들면, 메시지에 담긴 고객 번호를 기반으로 주문한 고객을 찾아, 기존 페이로드에 고객 정보를 채워야 할 수 있다.

Spring Integration 2.1에선 페이로드 enricher를 도입했다. 페이로드 enricher는 정의해둔 요청 채널에 `Message`를 전달하고 응답 메시지를 받는 엔드포인트다. 타겟 페이로드에 정보를 추가할 땐, 이 응답 메시지를 루트 객체로 사용해 표현식을 평가한다.

페이로드 enricher가 제공하는 기능은 전부 XML 네임스페이스의 `enricher` 요소를 통해 이용할 수 있다. 페이로드 enricher는 요청 메시지를 전송해야 하기 때문에, 요청 채널에 메시지를 전달할 수 있는 `request-channel` 속성을 가지고 있다.

페이로드 enricher는 요청 채널을 정의하기 때문에, 본질적으로 요청 채널로 전송한 메시지가 반환되기를 기다리는 게이트웨이 역할을 담당한다. 응답 메시지를 받으면 enricher는 응답 메시지에 있는 데이터로 메시지의 페이로드를 보강한다.

요청 채널에 메시지를 보낼 때 `request-payload-expression` 속성을 사용하면 기존 페이로드의 일부만 전송할 수도 있다.

페이로드 enricher는 SpEL 표현식을 통해 설정하기 때문에 매우 유연한 편이다. 따라서 응답 채널의 `Message`에 있는 값을 그대로 페이로드에 추가하는 것 뿐 아니라, SpEL 표현식을 이용해 해당 메시지에서 일부 정보만 추출하거나, 표현식 내에서 인라인으로 데이터를 좀 조작하고 변형할 수도 있다.

단순히 정적인 값만으로 페이로드를 보강할 수 있다면 `request-channel` 속성을 지정하지 않아도 된다.

> Enricher도 일종의 트랜스포머라고 할 수 있다. 메시지 페이로드에 데이터를 추가할 때 페이로드 enricher나 일반 트랜스포머 구현체 중, 어떤 것을 사용해도 상관 없는 경우가 많다. Spring Integration이 제공하는 변환용 구성 요소들에 전부 익숙해지는 것이 좋으며, 의미상 비즈니스 사례에 가장 적합한 구현체를 신중히 선택하면 된다.

#### Configuration

아래 예제는 페이로드 enricher에서 설정할 수 있는 모든 옵션을 보여주고 있다:

```xml
<int:enricher request-channel=""                           <!-- (1) -->
              auto-startup="true"                          <!-- (2) -->
              id=""                                        <!-- (3) -->
              order=""                                     <!-- (4) -->
              output-channel=""                            <!-- (5) -->
              request-payload-expression=""                <!-- (6) -->
              reply-channel=""                             <!-- (7) -->
              error-channel=""                             <!-- (8) -->
              send-timeout=""                              <!-- (9) -->
              should-clone-payload="false">                <!-- (10) -->
    <int:poller></int:poller>                              <!-- (11) -->
    <int:property name="" expression="" null-result-expression="'Could not determine the name'"/>   <!-- (12) -->
    <int:property name="" value="23" type="java.lang.Integer" null-result-expression="'0'"/>
    <int:header name="" expression="" null-result-expression=""/>   <!-- (13) -->
    <int:header name="" value="" overwrite="" type="" null-result-expression=""/>
</int:enricher>
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 메시지를 전송할 채널. 이 곳에서 페이로드를 보강할 데이터를 가져온다.<br>생략할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 애플리케이션 컨텍스트를 기동하면서 이 컴포넌트를 시작해야 하는지 여부를 나타내는 라이프사이클 속성.<br>기본값은 true다.<br>생략할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 내부에 정의하는 빈 ID로, `EventDrivenConsumer` 또는 `PollingConsumer`다.<br>생략할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> 이 엔드포인트가 어떤 채널의 구독자로서 연결돼있을 때 호출할 순서를 지정한다.<br>특히 연결된 채널이 "failover" 디스패치 전략을 사용할 때 활용하곤 한다.<br>이 엔드포인트 자체가 큐를 가진 채널의 폴링 컨슈머인 경우엔 아무런 효과가 없다.<br>생략할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> 이 엔드포인트에서 처리를 마친 메시지를 전송할 메시지 채널을 식별한다.<br>생략할 수 있다. </small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(6)</span> 기본적으로 `request-channel`로 메시지를 전송할 땐 원본 메시지에 있는 페이로드를 사용한다.<br>`request-payload-expression` 속성에 SpEL 표현식을 지정하면 기존 페이로드의 일부나, 헤더 값만 보내는 것도 가능하다. 요청 채널로 전송하는 페이로드를 가지고 만들 수 있는 SpEL 표현식이라면 어떤 것도 가능하다.<br>표현식에선 전체 메시지를 '루트 객체'로 사용할 수 있다.<br>예를 들면 다음과 같은 SpEL 표현식이 가능하다: `payload.something`, `headers.something`, `new java.util.Date()`, `'thing1' + 'thing2'`</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(7)</span> 응답 메시지를 받을 채널.<br>이 속성은 생략할 수 있다.<br>일반적으론 자동으로 생성된 임시 채널로도 충분하다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(8)</span> `request-channel`의 다운스트림에서 `Exception`이 발생하면 `ErrorMessage`를 전송할 채널.<br>이 채널을 통해 페이로드 보강에 사용할 대체 객체를 반환할 수 있다.<br>설정하지 않았다면 호출자 쪽으로 `Exception`을 던진다.<br>생략할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(9)</span> 블로킹될 수 있는 채널인 경우, 채널에 메시지를 전송하면서 최대로 대기할 시간 (밀리세컨드 단위).<br>예를 들어 큐 채널은 최대 용량을 다 사용하고 나면 여유 공간이 생길 때까지 블로킹된 있다.<br>이 타임아웃 값은 내부적으로 `MessagingTemplate`에 설정되며, 궁극적으로 `MessageChannel`에서 전송 작업을 진행할 때 적용된다.<br>기본적으론 `-1`로 설정돼서 구현체에 따라 `MessageChannel`의 전송 작업이 무한정 블로킹될 수 있다.<br>생략할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(10)</span> 요청 채널에 메시지를 전송해 보충할 데이터를 획득하기 전에, `Cloneable`을 구현한 페이로드를 복제해야 하는지 여부를 나타내는 boolean 값.<br>복제한 객체를 최종 응답의 타겟 페이로드로 사용한다. 기본값은 `false`다.<br>생략할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(11)</span> 이 엔드포인트가 폴링 컨슈머일 땐 메시지 폴러를 설정할 수 있다.<br>생략할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(12)</span> 하위 요소 `property`엔 프로퍼티명을 하나씩 지정한다 (필수 속성 `name`을 통해).<br>이 프로퍼티는 타겟 페이로드 인스턴스에 설정할 수 있어야 한다.<br>반드시 `value`나 `expression` 속성 중 하나를 함께 제공해야 한다 — 전자로는 리터럴 값을 설정할 수 있고, 후자로는 평가할 SpEL 표현식을 설정할 수 있다.<br>평가 컨텍스트의 루트 객체는 이 enricher로 시작된 플로우에서 반환한 메시지다 — 요청 채널이 없는 경우 입력 메시지나, 애플리케이션 컨텍스트를 루트 객체로 사용한다 (SpEL 구문 `@<beanName>.<beanProperty>` 사용).<br>4.0 버전부터는 `value` 속성을 지정할 때 `type` 속성을 함께 지정할 수 있다 (optional). 타입이 지정된 setter 메소드를 호출해야 한다면 프레임워크가 데이터를 변환할 수 있도록 값을 적절히 처리해준다 (`PropertyEditor`만 있다면).<br>반면 타겟 페이로드가 `Map`인 경우 변환 없이 엔트리에 그 값을 채운다.<br>예를 들어 `type` 속성을 사용하면 숫자를 담고있는 `String`을 타겟 페이로드에선 `Integer` 값으로 변환할 수 있다.<br>4.1 버전부터는 `null-result-expression` 속성도 지정할 수 있다 (optional).<br>`enricher`가 null을 반환하면 이 표현식을 평가해서 그 결과를 대신 반환한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(13)</span> 하위 요소 `header`엔 메시지 헤더명을 하나씩 지정한다 (필수 속성 `name`을 통해).<br>반드시 `value`나 `expression` 속성 중 하나를 함께 제공해야 한다 — 전자로는 리터럴 값을 설정할 수 있고, 후자로는 평가할 SpEL 표현식을 설정할 수 있다.<br>평가 컨텍스트의 루트 객체는 이 enricher로 시작된 플로우에서 반환한 메시지다 — 요청 채널이 없는 경우 입력 메시지나, 애플리케이션 컨텍스트를 루트 객체로 사용한다 (SpEL 구문 '@\<beanName\>.\<beanProperty\>' 사용).<br>`<header-enricher>`와 유사하게 `<enricher>`의 `header` 요소에도 `type`과 `overwrite` 속성이 있다.<br>하지만 `<enricher>`의 경우, `<enricher>`의 다른 하위 요소 `<property>`와의 통일감을 위해 `overwrite` 속성의 기본값이 `true`라는 차이점이 있다.<br>4.1 버전부터 `null-result-expression` 속성도 지정할 수 있다 (optional).<br>`enricher`가 null을 반환하면 이 표현식을 평가해서 그 결과를 대신 반환한다.</small>

#### Examples

이 섹션에선 다양한 상황에 페이로드 enricher를 활용하는 예제들을 몇 가지다룬다.

> 여기에서 보여주는 코드 외에도 다른 Spring Integration 샘플들을 제공하고 있다. [Spring Integration Samples](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/samples.html#samples)를 확인해봐라.

아래 예제에선 `User` 객체를 `Message`의 페이로드로 전달한다:

```xml
<int:enricher id="findUserEnricher"
              input-channel="findUserEnricherChannel"
              request-channel="findUserServiceChannel">
    <int:property name="email"    expression="payload.email"/>
    <int:property name="password" expression="payload.password"/>
</int:enricher>
```

`User`에는 여러 가지 프로퍼티들이 있지만 처음엔 `username`만 설정돼있다. enricher의 `request-channel` 속성은 `User`를 `findUserServiceChannel`에 전달하도록 설정돼있다.

내부에서 설정한 `reply-channel`을 통해 `User` 객체가 반환되며, 하위 요소 `property`를 이용해 응답에서 프로퍼티들을 추출하고, 기존 페이로드에 이 정보를 채운다.

#### How Do I Pass Only a Subset of Data to the Request Channel?

`request-payload-expression` 속성을 사용하면 전체 메시지가 아닌, 페이로드에 있는 한 가지 프로퍼티를 요청 채널로 전달할 수 있다. 아래 예제에선 username 프로퍼티를 요청 채널에 전달한다:

```xml
<int:enricher id="findUserByUsernameEnricher"
              input-channel="findUserByUsernameEnricherChannel"
              request-channel="findUserByUsernameServiceChannel"
              request-payload-expression="payload.username">
    <int:property name="email"    expression="payload.email"/>
    <int:property name="password" expression="payload.password"/>
</int:enricher>
```

username만을 전달하더라도, 요청 채널로 보내는 메시지엔 `MessageHeaders` 전체 셋이 담겨있다는 점에 주의하자.

#### How Can I Enrich Payloads that Consist of Collection Data?

아래 예제에선 `User` 객체 대신 `Map`을 전달한다:

```xml
<int:enricher id="findUserWithMapEnricher"
              input-channel="findUserWithMapEnricherChannel"
              request-channel="findUserByUsernameServiceChannel"
              request-payload-expression="payload.username">
    <int:property name="user" expression="payload"/>
</int:enricher>
```

이 `Map`에는 `username`이란 키로 username이 담겨있다. 요청 채널에는 이 `username`만 전달한다. 응답으로는 완전한 `User` 객체를 받으며, 궁극적으로 이 객체를 `user`라는 키로 `Map`에 추가한다.

#### How Can I Enrich Payloads with Static Information without Using a Request Channel?

아래 예제에선 요청 채널은 아예 사용하지 않고, 메시지 페이로드에 정적인<sup>static</sup> 값들을 채운다:

```xml
<int:enricher id="userEnricher"
              input-channel="input">
    <int:property name="user.updateDate" expression="new java.util.Date()"/>
    <int:property name="user.firstName" value="William"/>
    <int:property name="user.lastName"  value="Shakespeare"/>
    <int:property name="user.age"       value="42"/>
</int:enricher>
```

여기서 '정적<sup>static</sup>'이라는 단어는 좀 막연히 사용한 감이 있이다. 고정된 값만을 의미하는 것은 아니며, SpEL 표현식도 물론 사용할 수 있다.

---

## 9.3. Claim Check

앞 섹션에선 메시지에 필요한 데이터가 일부 들어있지 않은 상황을 해결할 수 있는 컨텐츠 enricher 두 가지를 다뤘다. 또한 메시지에서 원하는 데이터를 제거할 수 있는 컨텐츠 필터링에 대해서도 설명했었다. 하지만 데이터를 일시적으로 숨겨야 할 때가 있다. 예를 들어서, 분산 시스템에선 페이로드가 매우 큰 메시지를 수신할 수도 있다. 메시지 처리 단계 중에는, 이 페이로드에 접근할 필요가 없는 단계도 있을 수 있고,  특정 헤더만 접근하면 되는 단계도 있을 수 있다. 이런 상황에서 모든 처리 단계마다 거대한 메시지 페이로드를 같이 넘기면 성능 문제도 발생할 수 있으며, 보안에도 좋지 않고, 디버깅이 더 어려워질 수 있다.

[store in library](https://www.enterpriseintegrationpatterns.com/StoreInLibrary.html) 패턴은 (클레임 체크<sup>claim check</sup> 패턴이라고도 한다) 데이터를 원하는 저장소에 저장해두고, 데이터가 있는 곳을 가리키는 포인터(클레임 체크)만 유지할 수 있는 메커니즘을 다룬다. 이 포인터를 페이로드로 가진 메시지를 만들어 전달할 수 있으므로, 메시지 플로우에 있는 어떤 구성 요소라도 필요하다면 곧바로 실제 데이터를 가져올 수 있다. 이 방식은 우편함으로 수화물 인환증<sup>claim check</sup>을 받은 다음 우체국에 방문해 다음 실제 패키지를 받아와야 하는 등기 우편 프로세스와 매우 유사하다. 비행기에서 내린 다음이나 호텔에 가서 수하물 찾는 것과도 같은 개념이다.

Spring Integration은 두 가지 유형의 클레임 체크 트랜스포머를 제공한다:

- Incoming Claim Check Transformer
- Outgoing Claim Check Transformer

클레임 체크 트랜스포머를 설정할 땐 간편하게 네임스페이스를 활용하면 된다.

### 9.3.1. Incoming Claim Check Transformer

incoming 클레임 체크 트랜스포머는 전달받은 메시지를 `message-store` 속성으로 식별하는 메시지 스토어에 저장하고 변환한다. 다음은 incoming 클레임 체크 트랜스포머를 정의하는 예시다:

```xml
<int:claim-check-in id="checkin"
        input-channel="checkinChannel"
        message-store="testMessageStore"
        output-channel="output"/>
```

위 설정에선 `input-channel`로 받은 메시지는 메시지 스토어에 보관한다. 이 메시지 스토어는 `message-store` 속성으로 식별하며, 자동으로 만들어진 ID로 메시지를 인덱싱한다. 이 ID가 바로 해당 메시지에 대한 클레임 체크다. 클레임 체크는 `output-channel`로 전송되는 새로운(변환을 마친) 메시지의 페이로드로도 사용한다.

이제 실제 메시지에 접근해야 하는 때가 왔다고 생각해보자. 메시지 스토어에 직접 접근해서 메시지를 가져와도 좋고, 똑같이 트랜스포머를 하나 만들어서 (이번엔 outgoing 클레임 체크 트랜스포머다) 클레임 체크를 실제 메시지로 변환할 수도 있다.

다음은 incoming 클레임 체크 트랜스포머에서 사용 가능한 모든 파라미터를 나타낸 예시다:

```xml
<int:claim-check-in auto-startup="true"             <!-- (1) -->
                    id=""                           <!-- (2) -->
                    input-channel=""                <!-- (3) -->
                    message-store="messageStore"    <!-- (4) -->
                    order=""                        <!-- (5) -->
                    output-channel=""               <!-- (6) -->
                    send-timeout="">                <!-- (7) -->
    <int:poller></int:poller>                       <!-- (8) -->
</int:claim-check-in>
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 애플리케이션 컨텍스트를 기동하면서 이 컴포넌트를 시작해야 하는지 여부를 나타내는 라이프사이클 속성.<br>기본값은 `true`다.<bR>이 속성은 `Chain` 요소 안에선 사용할 수 없다.<br>생략할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 내부 빈 정의를 식별하는 ID (`MessageTransformingHandler`).<br>이 속성은 `Chain` 요소 안에선 사용할 수 없다.<br>생략할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 이 엔드포인트가 메시지를 수신할 채널.<br>이 속성은 `Chain` 요소 안에선 사용할 수 없다.<br>생략할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> 이 클레임 체크 트랜스포머에서 사용할 `MessageStore`에 대한 참조.<br>따로 지정하지 않으면 기본적으로 `messageStore`라는 이름의 빈을 참조한다.<br>생략할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> 이 엔드포인트가 어떤 채널의 구독자로서 연결돼있을 때 호출할 순서를 지정한다.<br>특히 연결된 채널이 `failover` 디스패치 전략을 사용할 때 활용하곤 한다.<br>이 엔드포인트 자체가 큐를 가진 채널의 폴링 컨슈머인 경우엔 아무런 효과가 없다.<br>이 속성은 `Chain` 요소 안에선 사용할 수 없다.<br>생략할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(6)</span> 이 엔드포인트에서 처리를 마친 메시지를 전송할 메시지 채널을 식별한다.<br>이 속성은 `Chain` 요소 안에선 사용할 수 없다.<br>생략할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(7)</span> 출력 채널에 응답 메시지를 전송할 때 최대로 대기할 시간을 지정한다 (밀리세컨드 단위).<br>기본값은 `-1`로, 무한정 블로킹된다.<br>이 속성은 `Chain` 요소 안에선 사용할 수 없다.<br>생략할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(8)</span> 폴러를 하나 정의한다.<br>이 요소는 `Chain` 안에선 사용할 수 없다.<br>생략할 수 있다.</small>

### 9.3.2. Outgoing Claim Check Transformer

outgoing 클레임 체크 트랜스포머를 사용하면 클레임 체크를 페이로드로 가지고 있는 메시지를, 본래 컨텐츠를 페이로드로 가진 메시지로 변환할 수 있다.

```xml
<int:claim-check-out id="checkout"
        input-channel="checkoutChannel"
        message-store="testMessageStore"
        output-channel="output"/>
```

위 설정에선, `input-channel`로 받은 메시지는 클레임 체크를 페이로드로 가지고 있어야 한다. outgoing 클레임 체크 트랜스포머는 메시지 스토어에서 전달받은 클레임 체크로 메시지를 식별해서 질의하고, 원래의 페이로드를 가지고 있는 메시지로 변환한다. 그런 다음 새롭게 체크아웃한 메시지를 `output-channel`로 전송한다.

다음은 outgoing 클레임 체크 트랜스포머에서 사용 가능한 모든 파라미터를 나타낸 예시다:

```xml
<int:claim-check-out auto-startup="true"             <!-- (1) -->
                     id=""                           <!-- (2) -->
                     input-channel=""                <!-- (3) -->
                     message-store="messageStore"    <!-- (4) -->
                     order=""                        <!-- (5) -->
                     output-channel=""               <!-- (6) -->
                     remove-message="false"          <!-- (7) -->
                     send-timeout="">                <!-- (8) -->
    <int:poller></int:poller>                        <!-- (9) -->
</int:claim-check-out>
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 애플리케이션 컨텍스트를 기동하면서 이 컴포넌트를 시작해야 하는지 여부를 나타내는 라이프사이클 속성.<br>기본값은 `true`다.<bR>이 속성은 `Chain` 요소 안에선 사용할 수 없다.<br>생략할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 내부 빈 정의를 식별하는 ID (`MessageTransformingHandler`).<br>이 속성은 `Chain` 요소 안에선 사용할 수 없다.<br>생략할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 이 엔드포인트가 메시지를 수신할 채널.<br>이 속성은 `Chain` 요소 안에선 사용할 수 없다.<br>생략할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> 이 클레임 체크 트랜스포머에서 사용할 `MessageStore`에 대한 참조.<br>따로 지정하지 않으면 기본적으로 `messageStore`라는 이름의 빈을 참조한다.<br>생략할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> 이 엔드포인트가 어떤 채널의 구독자로서 연결돼있을 때 호출할 순서를 지정한다.<br>특히 연결된 채널이 `failover` 디스패치 전략을 사용할 때 활용하곤 한다.<br>이 엔드포인트 자체가 큐를 가진 채널의 폴링 컨슈머인 경우엔 아무런 효과가 없다.<br>이 속성은 `Chain` 요소 안에선 사용할 수 없다.<br>생략할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(6)</span> 이 엔드포인트에서 처리를 마친 메시지를 전송할 메시지 채널을 식별한다.<br>이 속성은 `Chain` 요소 안에선 사용할 수 없다.<br>생략할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(7)</span> `true`로 설정하면 트랜스포머는 `MessageStore`에서 메시지를 제거한다.<br>메시지를 단 한 번만 "요청<sup>claim</sup>"할 수 있는 케이스에 활용하면 된다.<br>디폴트는 `false`다.<br>생략할 수 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(8)</span> 출력 채널에 응답 메시지를 전송할 때 최대로 대기할 시간을 지정한다 (밀리세컨드 단위).<br>기본값은 `-1`로, 무한정 블로킹된다.<br>이 속성은 `Chain` 요소 안에선 사용할 수 없다.<br>생략할 수 있다.</small><br><small><span style="background-color: #a9dcfc; border-radius: 50px;">(9)</span> 폴러를 하나 정의한다.<br>이 요소는 `Chain` 안에선 사용할 수 없다.<br>생략할 수 있다.</small>

### 9.3.3. Claim Once

간혹 특정 메시지는 딱 한 번만 요청<sup>claim</sup>을 받아야 할 때가 있다. 비유로 비행기 수하물을 처리하는 과정을 생각해보자. 공항에서 출발할 땐 수하물을 체크인하고, 도착 시에 청구<sup>claim</sup>한다. 수하물을 청구하고 나면, 다시 수하물을 체크인한 게 아니라면 다시 청구할 수 없다. 이런 케이스를 지원하기 위해 `claim-check-out` 트랜스포머는 `remove-message`라는 boolean 속성을 도입했다. 이 속성은 기본적으로 `false`로 설정된다. 하지만 `true`로 설정하면 요청된 메시지는 `MessageStore`에서 제거되어 다시 요청할 수 없게 된다.

이 기능은 저장 공간에 영향을 끼치는데, 특히 인메모리 `Map` 기반 `SimpleMessageStore`라면 더욱더 그렇다. 메시지 제거에 실패하면 종국엔 `OutOfMemoryException`이 발생할 수 있다. 따라서 메시지를 여러 번 요청하는 게 아니라면 `remove-message` 속성을 `true`로 설정해주는 게 좋다. `remove-message` 속성을 사용하는 방법은 아래 예제를 참고해라:

```xml
<int:claim-check-out id="checkout"
        input-channel="checkoutChannel"
        message-store="testMessageStore"
        output-channel="output"
        remove-message="true"/>
```

### 9.3.4. A Word on Message Store

클레임 체크의 세부 구현 스펙을 신경 쓰는 일은 거의 없지만 (제대로 동작만 한다면), Spring Integration에서 현재 사용하는 실제 클레임 체크(포인터) 구현체는 고유성을 보장을 위해 UUID를 사용한다는 것을 알아두면 좋다.

`org.springframework.integration.store.MessageStore`는 메시지를 저장하고 검색하기 위한 전략 인터페이스다. Spring Integration은 두 가지 구현체를 제공하고 있다:

- `SimpleMessageStore`: 인메모리, `Map` 기반 구현체 (디폴트, 테스트하기 좋다)
- `JdbcMessageStore`: JDBC를 통해 관계형 데이터베이스를 사용하는 구현체

---

## 9.4. Codec

Spring Integration 4.2에선 `Codec`이라는 인터페이스를 도입했다. 코덱은 객체와 `byte[]` 사이를 인코딩하고 디코딩하는 역할을 담당한다. 자바 직렬화 대신 사용할 수 있으며, 일반적으로 `Serializable`을 구현한 객체가 아니어도 된다는 장점이 있다. [Kryo](https://github.com/EsotericSoftware/kryo)를 이용해 직렬화하는 구현체를 하나 제공하지만, 아래 컴포넌트들에서 사용할 자체 구현체를 제공해도 된다:

- `EncodingPayloadTransformer`
- `DecodingTransformer`
- `CodecMessageConverter`

### 9.4.1. `EncodingPayloadTransformer`

이 트랜스포머는 코덱을 사용해 페이로드를 `byte[]`로 인코딩한다. 메시지 헤더에는 아무런 영향을 끼치지 않는다.

자세한 내용은 [Javadoc](https://docs.spring.io/spring-integration/api/org/springframework/integration/transformer/EncodingPayloadTransformer.html)을 참고해라.

### 9.4.2. `DecodingTransformer`

이 트랜스포머는 코덱을 사용해 `byte[]`를 디코딩한다. 디코딩해야 하는 `Class`(또는 `Class`로 리졸브되는 표현식)를 설정해줘야 한다. `Message<?>` 객체를 생성할 땐 인바운드 헤더는 보존하지 않는다.

자세한 내용은 [Javadoc](https://docs.spring.io/spring-integration/api/org/springframework/integration/transformer/DecodingTransformer.html)을 참고해라.

### 9.4.3. `CodecMessageConverter`

어떤 엔드포인트들은 (ex. TCP, Redis) 메시지 헤더라는 개념이 없다. 이런 엔드포인트에선 `MessageConverter`를 지원하는데, `byte[]`와 메시지 사이를 변환해 전송할 땐 `CodecMessageConverter`를 사용할 수 있다.

자세한 내용은 [Javadoc](https://docs.spring.io/spring-integration/api/org/springframework/integration/codec/CodecMessageConverter.html)을 참고해라.

### 9.4.4. Kryo

현재 유일하게 제공하는 `Codec`의 구현체로, 두 종류의 `Codec`이 있다:

- `PojoCodec`: 트랜스포머에서 사용
- `MessageCodec`: `CodecMessageConverter`에서 사용

스프링은 커스텀 시리얼라이저를 몇 가지 제공한다:

- `FileSerializer`
- `MessageHeadersSerializer`
- `MutableMessageHeadersSerializer`

첫 번째 시리얼라이저는 `FileKryoRegistrar`를 생성할 때 초기화되며, `PojoCodec`에 넘겨 함께 사용할 수 있다. 두 번째와 세 번째 시리얼라이저는 `MessageKryoRegistrar`로 초기화하는 `MessageCodec`과 함께 사용한다.

#### Customizing Kryo

Kryo는 기본적으로 알지 못하는 자바 타입은 `FieldSerializer`에 위임한다. 그리고 Kryo는 `String`, `Collection`, `Map` 등의 primitive 타입을 위한 디폴트 시리얼라이저들을 등록한다. `FieldSerializer`는 리플렉션을 사용해 객체 그래프를 탐색한다. 물론, 객체의 구조를 인식해서 선택한 primitive 필드들을 직접 직렬화할 수 있는 커스텀 시리얼라이저를 구현하면 더 효율적이다. 아래 보이는 예제처럼 말이다:

```java
public class AddressSerializer extends Serializer<Address> {

    @Override
    public void write(Kryo kryo, Output output, Address address) {
        output.writeString(address.getStreet());
        output.writeString(address.getCity());
        output.writeString(address.getCountry());
    }

    @Override
    public Address read(Kryo kryo, Input input, Class<Address> type) {
        return new Address(input.readString(), input.readString(), input.readString());
    }
}
```

[Kryo 문서](https://github.com/EsotericSoftware/kryo)에서도 설명하고 있지만, `Serializer` 인터페이스에선 `Kryo`, `Input`, `Output`을 받아 포함시킬 필드나 다른 내부 설정들을 조절할 수 있다.

> 커스텀 시리얼라이저를 등록한다면 registration ID가 필요하다. registration ID는 임의로 정할 수 있다. 하지만 여기선 분산 애플리케이션마다 있는 Kryo 인스턴스에서 동일한 ID를 사용해야 하기 때문에, 반드시 ID를 명시해야 한다. Kryo는 작은 양의 정수 값을 권장하고 있으며, 일부 id는 예약되어 있다 (value < 10). 현재 Spring Integration은 디폴트로 40, 41, 42를 사용한다 (앞에서 언급한 파일 시리얼라이저와, 메시지 헤더 시리얼라이저에). 스프링에서 향후 다른 값도 사용할 수 있으므로, 60에서부터 시작하는 것을 권장한다. 앞에서 언급한 registrar를 설정하면 이러한 프레임워크 기본값을 재정의할 수 있다.

##### Using a Custom Kryo Serializer

시리얼라이즈 로직을 커스텀해야 한다면, 커스텀엔 네이티브 API를 사용해야 하므로 [Kryo](https://github.com/EsotericSoftware/kryo) 문서를 참조해라. 예시로 [`MessageCodec`](https://github.com/spring-projects/spring-integration/blob/main/spring-integration-core/src/main/java/org/springframework/integration/codec/kryo/MessageCodec.java) 구현체를 확인해봐라.

##### Implementing KryoSerializable

도메인 객체 코드를 직접 수정할 수 있는 경우, [여기](https://github.com/EsotericSoftware/kryo#kryoserializable)에서 설명하는 것처럼 `KryoSerializable`을 구현해도 된다. 이 방식에선 클래스 자체가 직렬화 메소드 제공하며, 다른 설정은 필요하지 않다. 하지만 벤치마크에 따르면 커스텀 시리얼라이저를 명시적으로 등록하는 것만큼 효율적이진 않다. 다음은 커스텀 Kryo 시리얼라이저 예시다:

```java
public class Address implements KryoSerializable {
    ...

    @Override
    public void write(Kryo kryo, Output output) {
        output.writeString(this.street);
        output.writeString(this.city);
        output.writeString(this.country);
    }

    @Override
    public void read(Kryo kryo, Input input) {
        this.street = input.readString();
        this.city = input.readString();
        this.country = input.readString();
    }
}
```

이 테크닉을 이용해서 Kryo가 아닌 다른 직렬화 라이브러리를 래핑하는 것도 가능하다.

##### Using the `@DefaultSerializer` Annotation

[여기](https://github.com/EsotericSoftware/kryo#default-serializers)에서도 설명하고 있지만, Kryo는 `@DefaultSerializer` 어노테이션도 제공하고 있다.

```java
@DefaultSerializer(SomeClassSerializer.class)
public class SomeClass {
       // ...
}
```

도메인 객체를 직접 수정할 수 있는 경우, 이 방법으로 커스텀 시리얼라이저를 지정하는 게 더 간단할 수 있다. 단, 이 클래스는 ID와 함께 등록되지 않으므로, 상황에 따라 이 테크닉을 이용하기 어려울 수도 있다.