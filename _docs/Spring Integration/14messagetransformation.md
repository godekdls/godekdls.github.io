---
title: Message Transformation
category: Spring Integration
order: 14
permalink: /Spring%20Integration/messaging-transformation/
description: todo
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

> 동일한 `<transformer>` 설정에서 `ref` 속성과 내부 핸들러 정의를 둘 다 사용하는 것은 허용하지 않는다. 둘 다 사용하면 모호한 조건이 만들어져 예외가 발생한다.

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

Beginning with version 4.0, the `ObjectToJsonTransformer` supports the `resultType` property, to specify the node JSON representation. The result node tree representation depends on the implementation of the provided `JsonObjectMapper`. By default, the `ObjectToJsonTransformer` uses a `Jackson2JsonObjectMapper` and delegates the conversion of the object to the node tree to the `ObjectMapper#valueToTree` method. The node JSON representation provides efficiency for using the `JsonPropertyAccessor` when the downstream message flow uses SpEL expressions with access to the properties of the JSON data. See [Property Accessors](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/spel.html#spel-property-accessors) for more information.

Beginning with version 5.1, the `resultType` can be configured as `BYTES` to produce a message with the `byte[]` payload for convenience when working with downstream handlers which operate with this data type.

Starting with version 5.2, the `JsonToObjectTransformer` can be configured with a `ResolvableType` to support generics during deserialization with the target JSON processor. Also this component now consults request message headers first for the presence of the `JsonHeaders.RESOLVABLE_TYPE` or `JsonHeaders.TYPE_ID` and falls back to the configured type otherwise. The `ObjectToJsonTransformer` now also populates a `JsonHeaders.RESOLVABLE_TYPE` header based on the request message payload for any possible downstream scenarios.

Starting with version 5.2.6, the `JsonToObjectTransformer` can be supplied with a `valueTypeExpression` to resolve a `ResolvableType` for the payload to convert from JSON at runtime against the request message. By default it consults `JsonHeaders` in the request message. If this expression returns `null` or `ResolvableType` building throws a `ClassNotFoundException`, the transformer falls back to the provided `targetType`. This logic is present as an expression because `JsonHeaders` may not have real class values, but rather some type ids which have to be mapped to target classes according some external registry.

#### Apache Avro Transformers

Version 5.2 added simple transformers to transform to/from Apache Avro.

They are unsophisticated in that there is no schema registry; the transformers simply use the schema embedded in the `SpecificRecord` implementation generated from the Avro schema.

Messages sent to the `SimpleToAvroTransformer` must have a payload that implements `SpecificRecord`; the transformer can handle multiple types. The `SimpleFromAvroTransformer` must be configured with a `SpecificRecord` class which is used as the default type to deserialize. You can also specify a SpEL expression to determine the type to deserialize using the `setTypeExpression` method. The default SpEL expression is `headers[avro_type]` (`AvroHeaders.TYPE`) which, by default, is populated by the `SimpleToAvroTransformer` with the fully qualified class name of the source class. If the expression returns `null`, the `defaultType` is used.

The `SimpleToAvroTransformer` also has a `setTypeExpression` method. This allows decoupling of the producer and consumer where the sender can set the header to some token representing the type and the consumer then maps that token to a type.

### 9.1.4. Configuring a Transformer with Annotations

You can add the `@Transformer` annotation to methods that expect either the `Message` type or the message payload type. The return value is handled in the exact same way as described earlier [in the section describing the `` element](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/index-single.html#transformer-namespace). The following example shows how to use the `@Transformer` annotation to transform a `String` into an `Order`:

```java
@Transformer
Order generateOrder(String productId) {
    return new Order(productId);
}
```

Transformer methods can also accept the `@Header` and `@Headers` annotations, as documented in `Annotation Support`. The following examples shows how to use the `@Header` annotation:

```java
@Transformer
Order generateOrder(String productId, @Header("customerName") String customer) {
    return new Order(productId, customer);
}
```

See also [Advising Endpoints Using Annotations](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/handler-advice.html#advising-with-annotations).

### 9.1.5. Header Filter

Sometimes, your transformation use case might be as simple as removing a few headers. For such a use case, Spring Integration provides a header filter that lets you specify certain header names that should be removed from the output message (for example, removing headers for security reasons or a value that was needed only temporarily). Basically, the header filter is the opposite of the header enricher. The latter is discussed in [Header Enricher](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/content-enrichment.html#header-enricher). The following example defines a header filter:

```xml
<int:header-filter input-channel="inputChannel"
		output-channel="outputChannel" header-names="lastName, state"/>
```

As you can see, configuration of a header filter is quite simple. It is a typical endpoint with input and output channels and a `header-names` attribute. That attribute accepts the names of the headers (delimited by commas if there are multiple) that need to be removed. So, in the preceding example, the headers named 'lastName' and 'state' are not present on the outbound message.

### 9.1.6. Codec-Based Transformers

See [Codec](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/codec.html#codec).

---

## 9.2. Content Enricher

At times, you may have a requirement to enhance a request with more information than was provided by the target system. The [data enricher](https://www.enterpriseintegrationpatterns.com/DataEnricher.html) pattern describes various scenarios as well as the component (Enricher) that lets you address such requirements.

The Spring Integration `Core` module includes two enrichers:

- [Header Enricher](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/index-single.html#header-enricher)
- [Payload Enricher](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/index-single.html#payload-enricher)

It also includes three adapter-specific header enrichers:

- [XPath Header Enricher (XML Module)](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/xml.html#xml-xpath-header-enricher)
- [Mail Header Enricher (Mail Module)](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/mail.html#mail-namespace)
- [XMPP Header Enricher (XMPP Module)](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/xmpp.html#xmpp-message-outbound-channel-adapter)

See the adapter-specific sections of this reference manual to learn more about those adapters.

For more information regarding expressions support, see [Spring Expression Language (SpEL)](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/spel.html#spel).

### 9.2.1. Header Enricher

If you need do nothing more than add headers to a message and the headers are not dynamically determined by the message content, referencing a custom implementation of a transformer may be overkill. For that reason, Spring Integration provides support for the header enricher pattern. It is exposed through the `<header-enricher>` element. The following example shows how to use it:

```xml
<int:header-enricher input-channel="in" output-channel="out">
    <int:header name="foo" value="123"/>
    <int:header name="bar" ref="someBean"/>
</int:header-enricher>
```

The header enricher also provides helpful sub-elements to set well known header names, as the following example shows:

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

The preceding configuration shows that, for well known headers (such as `errorChannel`, `correlationId`, `priority`, `replyChannel`, `routing-slip`, and others), instead of using generic `<header>` sub-elements where you would have to provide both header 'name' and 'value', you can use convenient sub-elements to set those values directly.

Starting with version 4.1, the header enricher provides a `routing-slip` sub-element. See [Routing Slip](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/router.html#routing-slip) for more information.

#### POJO Support

Often, a header value cannot be defined statically and has to be determined dynamically based on some content in the message. That is why the header enricher lets you also specify a bean reference by using the `ref` and `method` attributes. The specified method calculates the header value. Consider the following configuration and a bean with a method that modifies a `String`:

```xml
<int:header-enricher input-channel="in" output-channel="out">
    <int:header name="something" method="computeValue" ref="myBean"/>
</int:header-enricher>

<bean id="myBean" class="thing1.thing2.MyBean"/>
public class MyBean {

    public String computeValue(String payload){
        return payload.toUpperCase() + "_US";
    }
}
```

You can also configure your POJO as an inner bean, as the following example shows:

```xml
<int:header-enricher  input-channel="inputChannel" output-channel="outputChannel">
    <int:header name="some_header">
        <bean class="org.MyEnricher"/>
    </int:header>
</int:header-enricher>
```

You can similarly point to a Groovy script, as the following example shows:

```xml
<int:header-enricher  input-channel="inputChannel" output-channel="outputChannel">
    <int:header name="some_header">
        <int-groovy:script location="org/SampleGroovyHeaderEnricher.groovy"/>
    </int:header>
</int:header-enricher>
```

#### SpEL Support

In Spring Integration 2.0, we introduced the convenience of the [Spring Expression Language (SpEL)](https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#expressions) to help configure many different components. The header enricher is one of them. Look again at the POJO example shown earlier. You can see that the computation logic to determine the header value is pretty simple. A natural question would be: "Is there an even simpler way to accomplish this?". That is where SpEL shows its true power. Consider the following example:

```xml
<int:header-enricher input-channel="in" output-channel="out">
    <int:header name="foo" expression="payload.toUpperCase() + '_US'"/>
</int:header-enricher>
```

By using SpEL for such simple cases, you no longer have to provide a separate class and configure it in the application context. All you need do is configured the `expression` attribute with a valid SpEL expression. The 'payload' and 'headers' variables are bound to the SpEL evaluation context, giving you full access to the incoming message.

#### Configuring a Header Enricher with Java Configuration

The following two examples show how to use Java Configuration for header enrichers:

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

The first example adds a single literal header. The second example adds two headers, a literal header and one based on a SpEL expression.

#### Configuring a Header Enricher with the Java DSL

The following example shows Java DSL Configuration for a header enricher:

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

Starting with Spring Integration 3.0, a new sub-element `<int:header-channels-to-string/>` is available. It has no attributes. This new sub-element converts existing `replyChannel` and `errorChannel` headers (when they are a `MessageChannel`) to a `String` and stores the channels in a registry for later resolution, when it is time to send a reply or handle an error. This is useful for cases where the headers might be lost — for example, when serializing a message into a message store or when transporting the message over JMS. If the header does not already exist or it is not a `MessageChannel`, no changes are made.

Using this functionality requires the presence of a `HeaderChannelRegistry` bean. By default, the framework creates a `DefaultHeaderChannelRegistry` with the default expiry (60 seconds). Channels are removed from the registry after this time. To change this behavior, define a bean with an `id` of `integrationHeaderChannelRegistry` and configure the required default delay by using a constructor argument (in milliseconds).

Since version 4.1, you can set a property called `removeOnGet` to `true` on the `<bean/>` definition, and the mapping entry is removed immediately on first use. This might be useful in a high-volume environment and when the channel is only used once, rather than waiting for the reaper to remove it.

The `HeaderChannelRegistry` has a `size()` method to determine the current size of the registry. The `runReaper()` method cancels the current scheduled task and runs the reaper immediately. The task is then scheduled to run again based on the current delay. These methods can be invoked directly by getting a reference to the registry, or you can send a message with, for example, the following content to a control bus:

```none
"@integrationHeaderChannelRegistry.runReaper()"
```

This sub-element is a convenience, and is the equivalent of specifying the following configuration:

```xml
<int:reply-channel
    expression="@integrationHeaderChannelRegistry.channelToChannelName(headers.replyChannel)"
    overwrite="true" />
<int:error-channel
    expression="@integrationHeaderChannelRegistry.channelToChannelName(headers.errorChannel)"
    overwrite="true" />
```

Starting with version 4.1, you can now override the registry’s configured reaper delay so that the channel mapping is retained for at least the specified time, regardless of the reaper delay. The following example shows how to do so:

```xml
<int:header-enricher input-channel="inputTtl" output-channel="next">
    <int:header-channels-to-string time-to-live-expression="120000" />
</int:header-enricher>

<int:header-enricher input-channel="inputCustomTtl" output-channel="next">
    <int:header-channels-to-string
        time-to-live-expression="headers['channelTTL'] ?: 120000" />
</int:header-enricher>
```

In the first case, the time to live for every header channel mapping will be two minutes. In the second case, the time to live is specified in the message header and uses an Elvis operator to use two minutes if there is no header.

### 9.2.2. Payload Enricher

In certain situations, the header enricher, as discussed earlier, may not be sufficient and payloads themselves may have to be enriched with additional information. For example, order messages that enter the Spring Integration messaging system have to look up the order’s customer based on the provided customer number and then enrich the original payload with that information.

Spring Integration 2.1 introduced the payload enricher. The payload enricher defines an endpoint that passes a `Message` to the exposed request channel and then expects a reply message. The reply message then becomes the root object for evaluation of expressions to enrich the target payload.

The payload enricher provides full XML namespace support through the `enricher` element. In order to send request messages, the payload enricher has a `request-channel` attribute that lets you dispatch messages to a request channel.

Basically, by defining the request channel, the payload enricher acts as a gateway, waiting for the message sent to the request channel to return. The enricher then augments the message’s payload with the data provided by the reply message.

When sending messages to the request channel, you also have the option to send only a subset of the original payload by using the `request-payload-expression` attribute.

The enriching of payloads is configured through SpEL expressions, providing a maximum degree of flexibility. Therefore, you can not only enrich payloads with direct values from the reply channel’s `Message`, but you can use SpEL expressions to extract a subset from that message or to apply additional inline transformations, letting you further manipulate the data.

If you need only to enrich payloads with static values, you need not provide the `request-channel` attribute.

> Enrichers are a variant of transformers. In many cases, you could use a payload enricher or a generic transformer implementation to add additional data to your message payloads. You should familiarize yourself with all transformation-capable components that are provided by Spring Integration and carefully select the implementation that semantically fits your business case best.

#### Configuration

The following example shows all available configuration options for the payload enricher:

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
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> Channel to which a message is sent to get the data to use for enrichment. Optional.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> Lifecycle attribute signaling whether this component should be started during the application context startup. Defaults to true. Optional.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> ID of the underlying bean definition, which is either an `EventDrivenConsumer` or a `PollingConsumer`. Optional.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> Specifies the order for invocation when this endpoint is connected as a subscriber to a channel. This is particularly relevant when that channel is using a “failover” dispatching strategy. It has no effect when this endpoint is itself a polling consumer for a channel with a queue. Optional.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> Identifies the message channel where a message is sent after it is being processed by this endpoint. Optional.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(6)</span> By default, the original message’s payload is used as payload that is sent to the `request-channel`. By specifying a SpEL expression as the value for the `request-payload-expression` attribute, you can use a subset of the original payload, a header value, or any other resolvable SpEL expression as the basis for the payload that is sent to the request-channel. For the expression evaluation, the full message is available as the 'root object'. For instance, the following SpEL expressions (among others) are possible: `payload.something`, `headers.something`, `new java.util.Date()`, `'thing1' + 'thing2'`</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(7)</span> Channel where a reply message is expected. This is optional. Typically, the auto-generated temporary reply channel suffices. Optional.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(8)</span> The channel to which an `ErrorMessage` is sent if an `Exception` occurs downstream of the `request-channel`. This enables you to return an alternative object to use for enrichment. If it is not set, an `Exception` is thrown to the caller. Optional.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(9)</span> Maximum amount of time in milliseconds to wait when sending a message to the channel, if the channel might block. For example, a queue channel can block until space is available, if its maximum capacity has been reached. Internally, the send timeout is set on the `MessagingTemplate` and ultimately applied when invoking the send operation on the `MessageChannel`. By default, the send timeout is set to '-1', which can cause the send operation on the `MessageChannel`, depending on the implementation, to block indefinitely. Optional.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(10)</span> Boolean value indicating whether any payload that implements `Cloneable` should be cloned prior to sending the message to the request channel for acquiring the enriching data. The cloned version would be used as the target payload for the ultimate reply. The default is `false`. Optional.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(11)</span> Lets you configure a message poller if this endpoint is a polling consumer. Optional.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(12)</span> Each `property` sub-element provides the name of a property (through the mandatory `name` attribute). That property should be settable on the target payload instance. Exactly one of the `value` or `expression` attributes must be provided as well — the former for a literal value to set and the latter for a SpEL expression to be evaluated. The root object of the evaluation context is the message that was returned from the flow initiated by this enricher — the input message if there is no request channel or the application context (using the `@<beanName>.<beanProperty>` SpEL syntax). Starting with version 4.0, when specifying a `value` attribute, you can also specify an optional `type` attribute. When the destination is a typed setter method, the framework coerces the value appropriately (as long as a `PropertyEditor`) exists to handle the conversion. If, however, the target payload is a `Map`, the entry is populated with the value without conversion. The `type` attribute lets you, for example, convert a `String` containing a number to an `Integer` value in the target payload. Starting with version 4.1, you can also specify an optional `null-result-expression` attribute. When the `enricher` returns null, it is evaluated, and the output of the evaluation is returned instead.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(13)</span> Each `header` sub-element provides the name of a message header (through the mandatory `name` attribute). Exactly one of the `value` or `expression` attributes must also be provided — the former for a literal value to set and the latter for a SpEL expression to be evaluated. The root object of the evaluation context is the message that was returned from the flow initiated by this enricher — the input message if there is no request channel or the application context (using the '@<beanName>.<beanProperty>' SpEL syntax). Note that, similarly to the `<header-enricher>`, the `<enricher>` element’s `header` element has `type` and `overwrite` attributes. However, a key difference is that, with the `<enricher>`, the `overwrite` attribute is `true` by default, to be consistent with the `<enricher>` element’s `<property>` sub-element. Starting with version 4.1, you can also specify an optional `null-result-expression` attribute. When the `enricher` returns null, it is evaluated, and the output of the evaluation is returned instead.</small>

#### Examples

This section contains several examples of using a payload enricher in various situations.

> The code samples shown here are part of the Spring Integration Samples project. See [Spring Integration Samples](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/samples.html#samples).

In the following example, a `User` object is passed as the payload of the `Message`:

```xml
<int:enricher id="findUserEnricher"
              input-channel="findUserEnricherChannel"
              request-channel="findUserServiceChannel">
    <int:property name="email"    expression="payload.email"/>
    <int:property name="password" expression="payload.password"/>
</int:enricher>
```

The `User` has several properties, but only the `username` is set initially. The enricher’s `request-channel` attribute is configured to pass the `User` to the `findUserServiceChannel`.

Through the implicitly set `reply-channel`, a `User` object is returned and, by using the `property` sub-element, properties from the reply are extracted and used to enrich the original payload.

#### How Do I Pass Only a Subset of Data to the Request Channel?

When using a `request-payload-expression` attribute, a single property of the payload instead of the full message can be passed on to the request channel. In the following example, the username property is passed on to the request channel:

```xml
<int:enricher id="findUserByUsernameEnricher"
              input-channel="findUserByUsernameEnricherChannel"
              request-channel="findUserByUsernameServiceChannel"
              request-payload-expression="payload.username">
    <int:property name="email"    expression="payload.email"/>
    <int:property name="password" expression="payload.password"/>
</int:enricher>
```

Keep in mind that, although only the username is passed, the resulting message to the request channel contains the full set of `MessageHeaders`.

##### How Can I Enrich Payloads that Consist of Collection Data?

In the following example, instead of a `User` object, a `Map` is passed in:

```xml
<int:enricher id="findUserWithMapEnricher"
              input-channel="findUserWithMapEnricherChannel"
              request-channel="findUserByUsernameServiceChannel"
              request-payload-expression="payload.username">
    <int:property name="user" expression="payload"/>
</int:enricher>
```

The `Map` contains the username under the `username` map key. Only the `username` is passed on to the request channel. The reply contains a full `User` object, which is ultimately added to the `Map` under the `user` key.

#### How Can I Enrich Payloads with Static Information without Using a Request Channel?

The following example does not use a request channel at all but solely enriches the message’s payload with static values:

```xml
<int:enricher id="userEnricher"
              input-channel="input">
    <int:property name="user.updateDate" expression="new java.util.Date()"/>
    <int:property name="user.firstName" value="William"/>
    <int:property name="user.lastName"  value="Shakespeare"/>
    <int:property name="user.age"       value="42"/>
</int:enricher>
```

Note that the word, 'static', is used loosely here. You can still use SpEL expressions for setting those values.

---

## 9.3. Claim Check

In earlier sections, we covered several content enricher components that can help you deal with situations where a message is missing a piece of data. We also discussed content filtering, which lets you remove data items from a message. However, there are times when we want to hide data temporarily. For example, in a distributed system, we may receive a message with a very large payload. Some intermittent message processing steps may not need access to this payload and some may only need to access certain headers, so carrying the large message payload through each processing step may cause performance degradation, may produce a security risk, and may make debugging more difficult.

The [store in library](https://www.enterpriseintegrationpatterns.com/StoreInLibrary.html) (or claim check) pattern describes a mechanism that lets you store data in a well known place while maintaining only a pointer (a claim check) to where that data is located. You can pass that pointer around as the payload of a new message, thereby letting any component within the message flow get the actual data as soon as it needs it. This approach is very similar to the certified mail process, where you get a claim check in your mailbox and then have to go to the post office to claim your actual package. It is also the same idea as baggage claim after a flight or in a hotel.

Spring Integration provides two types of claim check transformers:

- Incoming Claim Check Transformer
- Outgoing Claim Check Transformer

Convenient namespace-based mechanisms are available to configure them.

### 9.3.1. Incoming Claim Check Transformer

An incoming claim check transformer transforms an incoming message by storing it in the message store identified by its `message-store` attribute. The following example defines an incoming claim check transformer:

```xml
<int:claim-check-in id="checkin"
        input-channel="checkinChannel"
        message-store="testMessageStore"
        output-channel="output"/>
```

In the preceding configuration, the message that is received on the `input-channel` is persisted to the message store identified with the `message-store` attribute and indexed with a generated ID. That ID is the claim check for that message. The claim check also becomes the payload of the new (transformed) message that is sent to the `output-channel`.

Now, assume that at some point you do need access to the actual message. You can access the message store manually and get the contents of the message, or you can use the same approach (creating a transformer) except that now you transform the Claim Check to the actual message by using an outgoing claim check transformer.

The following listing provides an overview of all available parameters of an incoming claim check transformer:

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
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> Lifecycle attribute signaling whether this component should be started during application context startup. It defaults to `true`. This attribute is not available inside a `Chain` element. Optional.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> ID identifying the underlying bean definition (`MessageTransformingHandler`). This attribute is not available inside a `Chain` element. Optional.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> The receiving message channel of this endpoint. This attribute is not available inside a `Chain` element. Optional.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> Reference to the `MessageStore` to be used by this claim check transformer. If not specified, the default reference is to a bean named `messageStore`. Optional.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> Specifies the order for invocation when this endpoint is connected as a subscriber to a channel. This is particularly relevant when that channel uses a `failover` dispatching strategy. It has no effect when this endpoint is itself a polling consumer for a channel with a queue. This attribute is not available inside a `Chain` element. Optional.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(6)</span> Identifies the message channel where the message is sent after being processed by this endpoint. This attribute is not available inside a `Chain` element. Optional.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(7)</span> Specifies the maximum amount of time (in milliseconds) to wait when sending a reply message to the output channel. Defaults to `-1` — blocking indefinitely. This attribute is not available inside a `Chain` element. Optional.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(8)</span> Defines a poller. This element is not available inside a `Chain` element. Optional.</small>

### 9.3.2. Outgoing Claim Check Transformer

An outgoing claim check transformer lets you transform a message with a claim check payload into a message with the original content as its payload.

```xml
<int:claim-check-out id="checkout"
        input-channel="checkoutChannel"
        message-store="testMessageStore"
        output-channel="output"/>
```

In the preceding configuration, the message received on the `input-channel` should have a claim check as its payload. The outgoing claim check transformer transforms it into a message with the original payload by querying the message store for a message identified by the provided claim check. It then sends the newly checked-out message to the `output-channel`.

The following listing provides an overview of all available parameters of an outgoing claim check transformer:

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
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> Lifecycle attribute signaling whether this component should be started during application context startup. It defaults to `true`. This attribute is not available inside a `Chain` element. Optional.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> ID identifying the underlying bean definition (`MessageTransformingHandler`). This attribute is not available inside a `Chain` element. Optional.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> The receiving message channel of this endpoint. This attribute is not available inside a `Chain` element. Optional.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> Reference to the `MessageStore` to be used by this claim check transformer. If not specified, the default reference is to a bean named `messageStore`. Optional.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> Specifies the order for invocation when this endpoint is connected as a subscriber to a channel. This is particularly relevant when that channel is using a `failover` dispatching strategy. It has no effect when this endpoint is itself a polling consumer for a channel with a queue. This attribute is not available inside a `Chain` element. Optional.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(6)</span> Identifies the message channel where the message is sent after being processed by this endpoint. This attribute is not available inside a `Chain` element. Optional.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(7)</span> If set to `true`, the message is removed from the `MessageStore` by this transformer. This setting is useful when Message can be “claimed” only once. It defaults to `false`. Optional.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(8)</span> Specifies the maximum amount of time (in milliseconds) to wait when sending a reply message to the output channel. It defaults to `-1` — blocking indefinitely. This attribute is not available inside a `Chain` element. Optional.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(9)</span> Defines a poller. This element is not available inside a `Chain` element. Optional.</small>

### 9.3.3. Claim Once

Sometimes, a particular message must be claimed only once. As an analogy, consider process of handling airplane luggage. You checking in your luggage on departure and claiming it on arrival. Once the luggage has been claimed, it can not be claimed again without first checking it back in. To accommodate such cases, we introduced a `remove-message` boolean attribute on the `claim-check-out` transformer. This attribute is set to `false` by default. However, if set to `true`, the claimed message is removed from the `MessageStore` so that it cannot be claimed again.

This feature has an impact in terms of storage space, especially in the case of the in-memory `Map`-based `SimpleMessageStore`, where failing to remove messages could ultimately lead to an `OutOfMemoryException`. Therefore, if you do not expect multiple claims to be made, we recommend that you set the `remove-message` attribute’s value to `true`. The following example show how to use the `remove-message` attribute:

```xml
<int:claim-check-out id="checkout"
        input-channel="checkoutChannel"
        message-store="testMessageStore"
        output-channel="output"
        remove-message="true"/>
```

### 9.3.4. A Word on Message Store

Although we rarely care about the details of the claim checks (as long as they work), you should know that the current implementation of the actual claim check (the pointer) in Spring Integration uses a UUID to ensure uniqueness.

`org.springframework.integration.store.MessageStore` is a strategy interface for storing and retrieving messages. Spring Integration provides two convenient implementations of it:

- `SimpleMessageStore`: An in-memory, `Map`-based implementation (the default, good for testing)
- `JdbcMessageStore`: An implementation that uses a relational database over JDBC

---

## 9.4. Codec

Version 4.2 of Spring Integration introduced the `Codec` abstraction. Codecs encode and decode objects to and from `byte[]`. They offer an alternative to Java serialization. One advantage is that, typically, objects need not implement `Serializable`. We provide one implementation that uses [Kryo](https://github.com/EsotericSoftware/kryo) for serialization, but you can provide your own implementation for use in any of the following components:

- `EncodingPayloadTransformer`
- `DecodingTransformer`
- `CodecMessageConverter`

### 9.4.1. `EncodingPayloadTransformer`

This transformer encodes the payload to a `byte[]` by using the codec. It does not affect message headers.

See the [Javadoc](https://docs.spring.io/spring-integration/api/org/springframework/integration/transformer/EncodingPayloadTransformer.html) for more information.

### 9.4.2. `DecodingTransformer`

This transformer decodes a `byte[]` by using the codec. It needs to be configured with the `Class` to which the object should be decoded (or an expression that resolves to a `Class`). If the resulting object is a `Message<?>`, inbound headers are not retained.

See the [Javadoc](https://docs.spring.io/spring-integration/api/org/springframework/integration/transformer/DecodingTransformer.html) for more information.

### 9.4.3. `CodecMessageConverter`

Certain endpoints (such as TCP and Redis) have no concept of message headers. They support the use of a `MessageConverter`, and the `CodecMessageConverter` can be used to convert a message to or from a `byte[]` for transmission.

See the [Javadoc](https://docs.spring.io/spring-integration/api/org/springframework/integration/codec/CodecMessageConverter.html) for more information.

### 9.4.4. Kryo

Currently, this is the only implementation of `Codec`, and it provides two kinds of `Codec`:

- `PojoCodec`: Used in the transformers
- `MessageCodec`: Used in the `CodecMessageConverter`

The framework provides several custom serializers:

- `FileSerializer`
- `MessageHeadersSerializer`
- `MutableMessageHeadersSerializer`

The first can be used with the `PojoCodec` by initializing it with the `FileKryoRegistrar`. The second and third are used with the `MessageCodec`, which is initialized with the `MessageKryoRegistrar`.

#### Customizing Kryo

By default, Kryo delegates unknown Java types to its `FieldSerializer`. Kryo also registers default serializers for each primitive type, along with `String`, `Collection`, and `Map`. `FieldSerializer` uses reflection to navigate the object graph. A more efficient approach is to implement a custom serializer that is aware of the object’s structure and can directly serialize selected primitive fields. The following example shows such a serializer:

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

The `Serializer` interface exposes `Kryo`, `Input`, and `Output`, which provide complete control over which fields are included and other internal settings, as described in the [Kryo documentation](https://github.com/EsotericSoftware/kryo).

> When registering your custom serializer, you need a registration ID. The registration IDs are arbitrary. However, in our case, the IDs must be explicitly defined, because each Kryo instance across the distributed application must use the same IDs. Kryo recommends small positive integers and reserves a few ids (value < 10). Spring Integration currently defaults to using 40, 41, and 42 (for the file and message header serializers mentioned earlier). We recommend you start at 60, to allow for expansion in the framework. You can override these framework defaults by configuring the registrars mentioned earlier.

##### Using a Custom Kryo Serializer

If you need custom serialization, see the [Kryo](https://github.com/EsotericSoftware/kryo) documentation, because you need to use the native API to do the customization. For an example, see the [`MessageCodec`](https://github.com/spring-projects/spring-integration/blob/main/spring-integration-core/src/main/java/org/springframework/integration/codec/kryo/MessageCodec.java) implementation.

##### Implementing KryoSerializable

If you have write access to the domain object source code, you can implement `KryoSerializable` as described [here](https://github.com/EsotericSoftware/kryo#kryoserializable). In this case, the class provides the serialization methods itself and no further configuration is required. However benchmarks have shown this is not quite as efficient as registering a custom serializer explicitly. The following example shows a custom Kryo serializer:

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

You can also use this technique to wrap a serialization library other than Kryo.

##### Using the `@DefaultSerializer` Annotation

Kryo also provides a `@DefaultSerializer` annotation, as described [here](https://github.com/EsotericSoftware/kryo#default-serializers).

```java
@DefaultSerializer(SomeClassSerializer.class)
public class SomeClass {
       // ...
}
```

If you have write access to the domain object, this may be a simpler way to specify a custom serializer. Note that this does not register the class with an ID, which may make the technique unhelpful for certain situations.