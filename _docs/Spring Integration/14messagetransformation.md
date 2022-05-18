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

Message transformers play a very important role in enabling the loose-coupling of message producers and message consumers. Rather than requiring every message-producing component to know what type is expected by the next consumer, you can add transformers between those components. Generic transformers, such as one that converts a `String` to an XML Document, are also highly reusable.

For some systems, it may be best to provide a [canonical data model](https://www.enterpriseintegrationpatterns.com/CanonicalDataModel.html), but Spring Integration’s general philosophy is not to require any particular format. Rather, for maximum flexibility, Spring Integration aims to provide the simplest possible model for extension. As with the other endpoint types, the use of declarative configuration in XML or Java annotations enables simple POJOs to be adapted for the role of message transformers. The rest of this chapter describes these configuration options.

> For the sake of maximizing flexibility, Spring does not require XML-based message payloads. Nevertheless, the framework does provide some convenient transformers for dealing with XML-based payloads if that is indeed the right choice for your application. For more information on those transformers, see [XML Support - Dealing with XML Payloads](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/xml.html#xml).

### 9.1.1. Configuring a Transformer with XML

The `<transformer>` element is used to create a message-transforming endpoint. In addition to `input-channel` and `output-channel` attributes, it requires a `ref` attribute. The `ref` may either point to an object that contains the `@Transformer` annotation on a single method (see [Configuring a Transformer with Annotations](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/index-single.html#transformer-annotation)), or it may be combined with an explicit method name value provided in the `method` attribute.

```xml
<int:transformer id="testTransformer" ref="testTransformerBean" input-channel="inChannel"
             method="transform" output-channel="outChannel"/>
<beans:bean id="testTransformerBean" class="org.foo.TestTransformer" />
```

Using a `ref` attribute is generally recommended if the custom transformer handler implementation can be reused in other `<transformer>` definitions. However, if the custom transformer handler implementation should be scoped to a single definition of the `<transformer>`, you can define an inner bean definition, as the following example shows:

```xml
<int:transformer id="testTransformer" input-channel="inChannel" method="transform"
                output-channel="outChannel">
  <beans:bean class="org.foo.TestTransformer"/>
</transformer>
```

> Using both the `ref` attribute and an inner handler definition in the same `<transformer>` configuration is not allowed, as it creates an ambiguous condition and results in an exception being thrown.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>If the <code class="highlighter-rouge">ref</code> attribute references a bean that extends <code class="highlighter-rouge">AbstractMessageProducingHandler</code> (such as transformers provided by the framework itself), the configuration is optimized by injecting the output channel into the handler directly. In this case, each <code class="highlighter-rouge">ref</code> must be to a separate bean instance (or a <code class="highlighter-rouge">prototype</code>-scoped bean) or use the inner <code class="highlighter-rouge">&lt;bean/&gt;</code> configuration type. If you inadvertently reference the same message handler from multiple beans, you get a configuration exception.</p>
</blockquote>

When using a POJO, the method that is used for transformation may expect either the `Message` type or the payload type of inbound messages. It may also accept message header values either individually or as a full map by using the `@Header` and `@Headers` parameter annotations, respectively. The return value of the method can be any type. If the return value is itself a `Message`, that is passed along to the transformer’s output channel.

As of Spring Integration 2.0, a message transformer’s transformation method can no longer return `null`. Returning `null` results in an exception, because a message transformer should always be expected to transform each source message into a valid target message. In other words, a message transformer should not be used as a message filter, because there is a dedicated `<filter>` option for that. However, if you do need this type of behavior (where a component might return `null` and that should not be considered an error), you could use a service activator. Its `requires-reply` value is `false` by default, but that can be set to `true` in order to have exceptions thrown for `null` return values, as with the transformer.

### 9.1.2. Transformers and Spring Expression Language (SpEL)

Like routers, aggregators, and other components, as of Spring Integration 2.0, transformers can also benefit from [SpEL support](https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#expressions) whenever transformation logic is relatively simple. The following example shows how to use a SpEL expression:

```xml
<int:transformer input-channel="inChannel"
	output-channel="outChannel"
	expression="payload.toUpperCase() + '- [' + T(System).currentTimeMillis() + ']'"/>
```

The preceding example transforms the payload without writing a custom transformer. Our payload (assumed to be a `String`) is upper-cased, concatenated with the current timestamp, and has some formatting applied.

### 9.1.3. Common Transformers

Spring Integration provides a few transformer implementations.

#### Object-to-String Transformer

Because it is fairly common to use the `toString()` representation of an `Object`, Spring Integration provides an `ObjectToStringTransformer` whose output is a `Message` with a String `payload`. That `String` is the result of invoking the `toString()` operation on the inbound Message’s payload. The following example shows how to declare an instance of the object-to-string transformer:

```xml
<int:object-to-string-transformer input-channel="in" output-channel="out"/>
```

A potential use for this transformer would be sending some arbitrary object to the 'outbound-channel-adapter' in the `file` namespace. Whereas that channel adapter only supports `String`, byte-array, or `java.io.File` payloads by default, adding this transformer immediately before the adapter handles the necessary conversion. That works fine as long as the result of the `toString()` call is what you want to be written to the file. Otherwise, you can provide a custom POJO-based transformer by using the generic 'transformer' element shown previously.

> When debugging, this transformer is not typically necessary, since the `logging-channel-adapter` is capable of logging the message payload. See [Wire Tap](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/channel.html#channel-wiretap) for more detail.

> The object-to-string transformer is very simple. It invokes `toString()` on the inbound payload. Since Spring Integration 3.0, there are two exceptions to this rule:
> 
> - If the payload is a `char[]`, it invokes `new String(payload)`.
> - If the payload is a `byte[]`, it invokes `new String(payload, charset)`, where `charset` is UTF-8 by default. The `charset` can be modified by supplying the charset attribute on the transformer.
>
> For more sophistication (such as selection of the charset dynamically, at runtime), you can use a SpEL expression-based transformer instead, as the following example shows:
> 
> ```xml
> <int:transformer input-channel="in" output-channel="out"
       expression="new java.lang.String(payload, headers['myCharset']" />
> ```

If you need to serialize an `Object` to a byte array or deserialize a byte array back into an `Object`, Spring Integration provides symmetrical serialization transformers. These use standard Java serialization by default, but you can provide an implementation of Spring `Serializer` or `Deserializer` strategies by using the `serializer` and `deserializer` attributes, respectively. The following example shows to use Spring’s serializer and deserializer:

```xml
<int:payload-serializing-transformer input-channel="objectsIn" output-channel="bytesOut"/>

<int:payload-deserializing-transformer input-channel="bytesIn" output-channel="objectsOut"
    allow-list="com.mycom.*,com.yourcom.*"/>
```

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>When deserializing data from untrusted sources, you should consider adding a <code class="highlighter-rouge">allow-list</code> of package and class patterns. By default, all classes are deserialized.</p>
</blockquote>

#### `Object`-to-`Map` and `Map`-to-`Object` Transformers

Spring Integration also provides `Object`-to-`Map` and `Map`-to-`Object` transformers, which use the JSON to serialize and de-serialize the object graphs. The object hierarchy is introspected to the most primitive types (`String`, `int`, and so on). The path to this type is described with SpEL, which becomes the `key` in the transformed `Map`. The primitive type becomes the value.

Consider the following example:

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

The two classes in the preceding example are transformed to the following `Map`:

```none
{person.name=George, person.child.name=Jenna, person.child.nickNames[0]=Jen ...}
```

The JSON-based `Map` lets you describe the object structure without sharing the actual types, which lets you restore and rebuild the object graph into a differently typed object graph, as long as you maintain the structure.

For example, the preceding structure could be restored back to the following object graph by using the `Map`-to-`Object` transformer:

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

If you need to create a “structured” map, you can provide the `flatten` attribute. The default is 'true'. If you set it to 'false', the structure is a `Map` of `Map` objects.

Consider the following example:

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

The two classes in the preceding example are transformed to the following `Map`:

```none
{name=George, child={name=Jenna, nickNames=[Bimbo, ...]}}
```

To configure these transformers, Spring Integration provides namespace support for Object-to-Map, as the following example shows:

```xml
<int:object-to-map-transformer input-channel="directInput" output-channel="output"/>
```

You can also set the `flatten` attribute to false, as follows:

```xml
<int:object-to-map-transformer input-channel="directInput" output-channel="output" flatten="false"/>
```

Spring Integration provides namespace support for Map-to-Object, as the following example shows:

```xml
<int:map-to-object-transformer input-channel="input"
                         output-channel="output"
                         type="org.something.Person"/>
```

Alterately, you could use a `ref` attribute and a prototype-scoped bean, as the following example shows:

```xml
<int:map-to-object-transformer input-channel="inputA"
                               output-channel="outputA"
                               ref="person"/>
<bean id="person" class="org.something.Person" scope="prototype"/>
```

> The 'ref' and 'type' attributes are mutually exclusive. Also, if you use the 'ref' attribute, you must point to a 'prototype' scoped bean. Otherwise, a `BeanCreationException` is thrown.

Starting with version 5.0, you can supply the `ObjectToMapTransformer` with a customized `JsonObjectMapper` — for when you need special formats for dates or nulls for empty collections (and other uses). See [JSON Transformers](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/index-single.html#json-transformers) for more information about `JsonObjectMapper` implementations.

#### Stream Transformer

The `StreamTransformer` transforms `InputStream` payloads to a `byte[]`( or a `String` if a `charset` is provided).

The following example shows how to use the `stream-transformer` element in XML:

```xml
<int:stream-transformer input-channel="directInput" output-channel="output"/> <!-- byte[] -->

<int:stream-transformer id="withCharset" charset="UTF-8"
    input-channel="charsetChannel" output-channel="output"/> <!-- String -->
```

The following example shows how to use the `StreamTransformer` class and the `@Transformer` annotation to configure a stream transformer in Java:

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

Spring Integration provides Object-to-JSON and JSON-to-Object transformers. The following pair of examples show how to declare them in XML:

```xml
<int:object-to-json-transformer input-channel="objectMapperInput"/>
<int:json-to-object-transformer input-channel="objectMapperInput"
    type="foo.MyDomainObject"/>
```

By default, the transformers in the preceding listing use a vanilla `JsonObjectMapper`. It is based on an implementation from the classpath. You can provide your own custom `JsonObjectMapper` implementation with appropriate options or based on a required library (such as GSON), as the following example shows:

```xml
<int:json-to-object-transformer input-channel="objectMapperInput"
    type="something.MyDomainObject" object-mapper="customObjectMapper"/>
```

> Beginning with version 3.0, the `object-mapper` attribute references an instance of a new strategy interface: `JsonObjectMapper`. This abstraction lets multiple implementations of JSON mappers be used. Implementation that wraps [Jackson 2](https://github.com/FasterXML) is provided, with the version being detected on the classpath. The class is `Jackson2JsonObjectMapper`, respectively.

You may wish to consider using a `FactoryBean` or a factory method to create the `JsonObjectMapper` with the required characteristics. The following example shows how to use such a factory:

```java
public class ObjectMapperFactory {

    public static Jackson2JsonObjectMapper getMapper() {
        ObjectMapper mapper = new ObjectMapper();
        mapper.configure(JsonParser.Feature.ALLOW_COMMENTS, true);
        return new Jackson2JsonObjectMapper(mapper);
    }
}
```

The following example shows how to do the same thing in XML

```xml
<bean id="customObjectMapper" class="something.ObjectMapperFactory"
            factory-method="getMapper"/>
```

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
  <p>Beginning with version 2.2, the <code class="highlighter-rouge">object-to-json-transformer</code> sets the <code class="highlighter-rouge">content-type</code> header to <code class="highlighter-rouge">application/json</code>, by default, if the input message does not already have that header.</p>
  <p>It you wish to set the <code class="highlighter-rouge">content-type</code> header to some other value or explicitly overwrite any existing header with some value (including <code class="highlighter-rouge">application/json</code>), use the <code class="highlighter-rouge">content-type</code> attribute. If you wish to suppress the setting of the header, set the <code class="highlighter-rouge">content-type</code> attribute to an empty string (<code class="highlighter-rouge">""</code>). Doing so results in a message with no <code class="highlighter-rouge">content-type</code> header, unless such a header was present on the input message.</p>
</blockquote>

Beginning with version 3.0, the `ObjectToJsonTransformer` adds headers, reflecting the source type, to the message. Similarly, the `JsonToObjectTransformer` can use those type headers when converting the JSON to an object. These headers are mapped in the AMQP adapters so that they are entirely compatible with the Spring-AMQP [`JsonMessageConverter`](https://docs.spring.io/spring-amqp/api/).

This enables the following flows to work without any special configuration:

- `…→amqp-outbound-adapter---→`

- `---→amqp-inbound-adapter→json-to-object-transformer→…`

  Where the outbound adapter is configured with a `JsonMessageConverter` and the inbound adapter uses the default `SimpleMessageConverter`.

- `…→object-to-json-transformer→amqp-outbound-adapter---→`

- `---→amqp-inbound-adapter→…`

  Where the outbound adapter is configured with a `SimpleMessageConverter` and the inbound adapter uses the default `JsonMessageConverter`.

- `…→object-to-json-transformer→amqp-outbound-adapter---→`

- `---→amqp-inbound-adapter→json-to-object-transformer→`

  Where both adapters are configured with a `SimpleMessageConverter`.

> When using the headers to determine the type, you should not provide a `class` attribute, because it takes precedence over the headers.

In addition to JSON Transformers, Spring Integration provides a built-in `#jsonPath` SpEL function for use in expressions. For more information see [Spring Expression Language (SpEL)](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/spel.html#spel).

Since version 3.0, Spring Integration also provides a built-in `#xpath` SpEL function for use in expressions. For more information see [#xpath SpEL Function](https://docs.spring.io/spring-integration/docs/5.5.12/reference/html/xml.html#xpath-spel-function).

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