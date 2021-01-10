---
title: Marshalling XML by Using Object-XML Mappers
category: Spring Data Access
order: 8
permalink: /Spring%20Data%20Access/marshallingxmlbyusingobjectxmlmappers/
description: 스프링 프레임워크의 Marshaller, Unmarshaller 인터페이스를 사용한 O-X 매핑을 소개합니다.
image: ./../../images/springdataaccess/oxm-exceptions.png
lastmod: 2021-01-10T23:00:00+09:00
comments: true
originalRefName: 스프링 프레임워크 데이터 액세스
originalRefLink: https://docs.spring.io/spring-framework/docs/5.3.2/reference/html/data-access.html#oxm
---
<script>defaultLanguages = ['java']</script>

### 목차

- [7.1. Introduction](#71-introduction)
  + [7.1.1. Ease of configuration](#711-ease-of-configuration)
  + [7.1.2. Consistent Interfaces](#712-consistent-interfaces)
  + [7.1.3. Consistent Exception Hierarchy](#713-consistent-exception-hierarchy)
- [7.2. Marshaller and Unmarshaller](#72-marshaller-and-unmarshaller)
  + [7.2.1. Understanding Marshaller](#721-understanding-marshaller)
  + [7.2.2. Understanding Unmarshaller](#722-understanding-unmarshaller)
  + [7.2.3. Understanding XmlMappingException](#723-understanding-xmlmappingexception)
- [7.3. Using Marshaller and Unmarshaller](#73-using-marshaller-and-unmarshaller)
- [7.4. XML Configuration Namespace](#74-xml-configuration-namespace)
- [7.5. JAXB](#75-jaxb)
  + [7.5.1. Using Jaxb2Marshaller](#751-using-jaxb2marshaller)
    * [XML Configuration Namespace](#xml-configuration-namespace)
- [7.6. JiBX](#76-jibx)
  + [7.6.1. Using JibxMarshaller](#761-using-jibxmarshaller)
    * [XML Configuration Namespace](#xml-configuration-namespace-1)
- [7.7. XStream](#77-xstream)
  + [7.7.1. Using XStreamMarshaller](#771-using-xstreammarshaller)
    
---

## 7.1. Introduction

이번 챕터는 스프링이 지원하는 Object-XML 매핑 기능을 설명한다. Object-XML 매핑(줄여서 O-X 매핑)은 XML 문서와 객체를 변환하는 작업이다. 이 변환 프로세스는 XML 마샬링이나 XML 직렬화라고 부르기도 한다. 이 챕터에선 두 용어를 같은 의미로 혼용해서 사용한다.

O-X 매핑에서 객체(그래프)를 XML로 직렬화하는 일을 마샬러가 담당한다. 유사하게, 언마샬러는 XML을 객체 그래프로 역직렬화한다. 이 XML은 DOM 문서일 수도 있고, 입출력 스트림이나 SAX 핸들러 형식일 수도 있다.

O/X 매핑에 스프링을 활용하면 다음과 같은 혜택이 따라온다:

- [더 쉬운 설정](#711-ease-of-configuration)
- [일관적인 인터페이스](#712-consistent-interfaces)
- [일관적인 예외 계층 구조](#713-consistent-exception-hierarchy)

### 7.1.1. Ease of configuration

스프링의 빈 팩토리를 사용하면 JAXB 컨텍스트나 JiBX 바인딩 팩토리 없이도 쉽게 마샬러를 설정할 수 있다. 어플리케이션 컨텍스트에 다른 빈을 설정할 때처럼 마샬러도 똑같이 설정하면 된다. 게다가 XML 네임스페이스는 마샬러를 여러 개 설정할 수 있어서 훨씬 간단하다.

### 7.1.2. Consistent Interfaces

스프링의 O-X 매핑은 공통 인터페이스 [`Marshaller`](https://docs.spring.io/spring-framework/docs/5.3.2/javadoc-api/org/springframework/oxm/Marshaller.html), [`Unmarshaller`](https://docs.spring.io/spring-framework/docs/5.3.2/javadoc-api/org/springframework/oxm/Unmarshaller.html)를 사용한다. 이 추상화 덕분에 마샬링을 담당하는 클래스는 거의 변경하지 않고도 O-X 매핑 프레임워크를 비교적 쉽게 전환할 수 있다. 게다가 기존 코드를 어지럽히지 않아도, XML 마샬링 방식을 혼용해서 각 기술의 장점만 취하는 것도 가능하다 (예를 들어, 일부는 JAXB로, 일부는 XStream으로 마샬링).

### 7.1.3. Consistent Exception Hierarchy

스프링은 내부 O-X 매핑 예외를 `XmlMappingException`을 루트로 가지고 있는 자체 예외 계층 구조로 변환해준다. 이 런타임 예외들은 기존 예외를 래핑하기 때문에 기존 예외 정보를 모두 가지고 있다.

---

## 7.2. `Marshaller` and `Unmarshaller`

[소개 섹션](#71-introduction)에서도 말했지만, 마샬러는 객체를 XML로 직렬화하고, 언마샬러는 XML 스트림을 객체로 역직렬화한다. 이번 섹션에선 직렬화, 역직렬화에 사용하는 두 가지 스프링 인터페이스를 설명한다.

### 7.2.1. Understanding `Marshaller`

스프링은 모든 마샬링 연산을 `org.springframework.oxm.Marshaller` 인터페이스로 추상화한다. 다음은 `Marshaller` 인터페이스의 핵심 메소드다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
public interface Marshaller {

    /**
     * Marshal the object graph with the given root into the provided Result.
     */
    void marshal(Object graph, Result result) throws XmlMappingException, IOException;
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
interface Marshaller {

    /**
    * Marshal the object graph with the given root into the provided Result.
    */
    @Throws(XmlMappingException::class, IOException::class)
    fun marshal(
            graph: Any,
            result: Result
    )
}
```

`Marshaller` 인터페이스에는 전달받은 객체를, 전달받은 `javax.xml.transform.Result`로 마샬링하는 메인 메소드가 하나 있다. `Result`는 XML 출력을 추상화한 태그 인터페이스다. 다음 테이블에 나와있듯이, 인터페이스 구현체는 다양한 XML 표현을 감싸고 있다:

| Result implementation | Wraps XML representation                                 |
| :-------------------- | :------------------------------------------------------- |
| `DOMResult`           | `org.w3c.dom.Node`                                       |
| `SAXResult`           | `org.xml.sax.ContentHandler`                             |
| `StreamResult`        | `java.io.File`, `java.io.OutputStream`, `java.io.Writer` |

> 이 `marshal()` 메소드는 첫 번째 파라미터로 일반 객체를 받긴 하지만, `Marshaller` 구현체 대부분이 임의의 객체를 모두 처리할 수 있는 건 아니다. 객체 클래스는 매핑 파일에 매핑돼 있거나, 어노테이션으로 마킹했거나, 마샬러에 등록했거나, 그도 아니면 공통 기본 클래스가 있어야 한다. 사용할 O-X 기술에서 어떻게 마샬링할 클래스를 관리할지를 결정하려면 이 챕터 뒷부분을 참조해라.
>

#### 7.2.2. Understanding `Unmarshaller`

`Marshaller`와 유사하게, 다음과 같은 `org.springframework.oxm.Unmarshaller` 인터페이스도 제공한다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
public interface Unmarshaller {

    /**
     * Unmarshal the given provided Source into an object graph.
     */
    Object unmarshal(Source source) throws XmlMappingException, IOException;
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
interface Unmarshaller {

    /**
    * Unmarshal the given provided Source into an object graph.
    */
    @Throws(XmlMappingException::class, IOException::class)
    fun unmarshal(source: Source): Any
}
```

이 인터페이스도 전달받은 `javax.xml.transform.Source`(XML 입력 추상화)를 읽어 객체를 반환하는 메소드가 하나 있다. `Result`와 마찬가지로 `Source`도 태그 인터페이스다. 구현체는 세 가지가 있으며, 다음 테이블에 나와있듯이, 인터페이스 구현체는 각자 다른 XML 표현을 감싸고 있다:

| Source implementation | Wraps XML representation                                |
| :-------------------- | :------------------------------------------------------ |
| `DOMSource`           | `org.w3c.dom.Node`                                      |
| `SAXSource`           | `org.xml.sax.InputSource`, `org.xml.sax.XMLReader`      |
| `StreamSource`        | `java.io.File`, `java.io.InputStream`, `java.io.Reader` |

마샬링 인터페이스는 두 가지로 나눠져 있지만 (`Marshaller`와 `Unmarshaller`), Spring-WS에 있는 모든 구현체는 클래스 하나로 두 인터페이스를 모두 구현한다. 따라서 마샬러 클래스는 하나만 만들고, `applicationContext.xml`에선 마샬러와 언마샬러 둘다 이 클래스를 참조할 수 있다.

### 7.2.3. Understanding `XmlMappingException`

스프링은 내부 O-X 매핑 툴의 예외를 `XmlMappingException`을 루트로 가진 자체 예외 계층 구조로 변환한다. 이 런타임 예외들은 기존 예외를 래핑하기 때문에 기존 예외 정보를 모두 가지고 있다.

게다가 기존 O-X 매핑 툴은 마샬링과 언마샬 연산을 구분해주지 않지만, `MarshallingFailureException`과 `UnmarshallingFailureException`에선 두 연산을 구분할 수 있다.

다음은 O-X 매핑 예외 계층 구조를 나타낸 이미지다:

![oxm exceptions](./../../images/springdataaccess/oxm-exceptions.png)

---

## 7.3. Using `Marshaller` and `Unmarshaller`

스프링의 OXM은 다양한 상황에 활용할 수 있다. 다음 예제에선 스프링 OXM으로 스프링이 관리하는 어플리케이션 설정을 XML 파일로 마샬링해볼 거다. 간단한 자바빈으로 설정을 표현해보겠다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
public class Settings {

    private boolean fooEnabled;

    public boolean isFooEnabled() {
        return fooEnabled;
    }

    public void setFooEnabled(boolean fooEnabled) {
        this.fooEnabled = fooEnabled;
    }
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
class Settings {
    var isFooEnabled: Boolean = false
}
```

아래 `Application` 클래스는 이 빈 설정을 저장하는 클래스다. 여기에는 메인 메소드 말고도 메소드가 두 개 더 있다. `saveSettings()`는 `settings.xml`이란 파일에 설정 빈을 저장하고, `loadSettings()`는 이 설정을 다시 로드한다. `main()` 메소드에선 스프링 어플리케이션 컨텍스트를 구성하고 이 두 메소드를 호출한다:

<div class="switch-language-wrapper java kotlin">
<span class="switch-language java">java</span>
<span class="switch-language kotlin">kotlin</span>
</div>
<div class="language-only-for-java java kotlin"></div>
```java
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;
import org.springframework.oxm.Marshaller;
import org.springframework.oxm.Unmarshaller;

public class Application {

    private static final String FILE_NAME = "settings.xml";
    private Settings settings = new Settings();
    private Marshaller marshaller;
    private Unmarshaller unmarshaller;

    public void setMarshaller(Marshaller marshaller) {
        this.marshaller = marshaller;
    }

    public void setUnmarshaller(Unmarshaller unmarshaller) {
        this.unmarshaller = unmarshaller;
    }

    public void saveSettings() throws IOException {
        try (FileOutputStream os = new FileOutputStream(FILE_NAME)) {
            this.marshaller.marshal(settings, new StreamResult(os));
        }
    }

    public void loadSettings() throws IOException {
        try (FileInputStream is = new FileInputStream(FILE_NAME)) {
            this.settings = (Settings) this.unmarshaller.unmarshal(new StreamSource(is));
        }
    }

    public static void main(String[] args) throws IOException {
        ApplicationContext appContext =
                new ClassPathXmlApplicationContext("applicationContext.xml");
        Application application = (Application) appContext.getBean("application");
        application.saveSettings();
        application.loadSettings();
    }
}
```
<div class="language-only-for-kotlin java kotlin"></div>
```kotlin
class Application {

    lateinit var marshaller: Marshaller

    lateinit var unmarshaller: Unmarshaller

    fun saveSettings() {
        FileOutputStream(FILE_NAME).use { outputStream -> marshaller.marshal(settings, StreamResult(outputStream)) }
    }

    fun loadSettings() {
        FileInputStream(FILE_NAME).use { inputStream -> settings = unmarshaller.unmarshal(StreamSource(inputStream)) as Settings }
    }
}

private const val FILE_NAME = "settings.xml"

fun main(args: Array<String>) {
    val appContext = ClassPathXmlApplicationContext("applicationContext.xml")
    val application = appContext.getBean("application") as Application
    application.saveSettings()
    application.loadSettings()
}
```

`Application` 클래스엔 `marshaller`와 `unmarshaller` 프로퍼티를 설정해줘야 한다. 이땐 다음 `applicationContext.xml`을 사용하면 된다:

```xml
<beans>
    <bean id="application" class="Application">
        <property name="marshaller" ref="xstreamMarshaller" />
        <property name="unmarshaller" ref="xstreamMarshaller" />
    </bean>
    <bean id="xstreamMarshaller" class="org.springframework.oxm.xstream.XStreamMarshaller"/>
</beans>
```

이 어플리케이션 컨텍스트는 XStream을 사용하지만, 이 챕터 뒤에서 설명하는 다른 마샬러 인스턴스를 사용해도 된다. 하지만 XStream은  기본적으로 다른 설정이 추가로 필요하지 않아서 빈 정의가 비교적 간단하다. 게다가 `XStreamMarshaller`는 `Marshaller`와 `Unmarshaller`를 모두 구현하고 있기 때문에, 어플리케이션 빈의 `marshaller`, `unmarshaller` 프로퍼티 둘다 `xstreamMarshaller` 빈을 참조할 수 있다.

이 샘플 어플리케이션을 실행하면 다음과 같은 `settings.xml` 파일이 만들어진다:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<settings foo-enabled="false"/>
```

---

## 7.4. XML Configuration Namespace

OXM 네임스페이스의 태그를 사용하면 마샬러를 더 간단하게 설정할 수 있다. 이 태그를 사용하려면 먼저 XML 설정 파일 앞에 적절한 스키마를 넣어야 한다. 그 방법은 다음 예제를 참고해라:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:oxm="http://www.springframework.org/schema/oxm" <!-- (1) -->
xsi:schemaLocation="http://www.springframework.org/schema/beans
  https://www.springframework.org/schema/beans/spring-beans.xsd
  http://www.springframework.org/schema/oxm https://www.springframework.org/schema/oxm/spring-oxm.xsd"> <!-- (2) -->
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `oxm` 스키마를 참조시킨다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> `oxm` 스키마 위치를 지정한다.</small>

이 스키마를 선언하면 다음과 같은 요소를 사용할 수 있다:

- [`jaxb2-marshaller`](#75-jaxb)
- [`jibx-marshaller`](#76-jibx)

이 태그는 각 마샬러 전용 섹션에서 따로 설명한다. JAXB2 마샬러로 예를 들자면, 다음 유사하게 설정할 수 있다:

```xml
<oxm:jaxb2-marshaller id="marshaller" contextPath="org.springframework.ws.samples.airline.schema"/>
```

---

## 7.5. JAXB

JAXB 바인딩 컴파일러는 W3C XML 스키마를 하나 이상의 자바 클래스나 `jaxb.properties` 파일, 아니면 몇 가지 리소스 파일로도 변환할 수 있다. JAXB로는 자바 클래스에 어노테이션을 달아 스키마를 생성할 수도 있다.

스프링은 JAXB 2.0 API를 [`Marshaller`와 `Unmarshaller`](#72-marshaller-and-unmarshaller)에서 설명한 `Marshaller`, `Unmarshaller` 인터페이스에 따른 XML 마샬링 전략으로 지원한다. JAXB 통합 클래스는 `org.springframework.oxm.jaxb` 패키지에 있다.

### 7.5.1. Using `Jaxb2Marshaller`

`Jaxb2Marshaller` 클래스는 스프링의 `Marshaller`, `Unmarshaller` 인터페이스를 둘 다 구현하고 있다. 이 클래스를 사용하려면 컨텍스트 경로를 지정해야 한다. 컨텍스트 경로는 `contextPath` 프로퍼티로 설정할 수 있다. 컨텍스트 경로는 스키마로 파생한 클래스를 가지고 있는 자바 패키지명 리스트로,  콜론으로 구분한다. `classesToBeBound` 프로퍼티로 마샬러에서 지원할 클래스 배열을 설정할 수도 있다. 다음 예제와 같이 빈에 스키마 리소스를 하나 이상 지정하면 스키마 유효성 검사를 수행할 수 있다:

```xml
<beans>
    <bean id="jaxb2Marshaller" class="org.springframework.oxm.jaxb.Jaxb2Marshaller">
        <property name="classesToBeBound">
            <list>
                <value>org.springframework.oxm.jaxb.Flight</value>
                <value>org.springframework.oxm.jaxb.Flights</value>
            </list>
        </property>
        <property name="schema" value="classpath:org/springframework/oxm/schema.xsd"/>
    </bean>

    ...

</beans>
```

#### XML Configuration Namespace

`jaxb2-marshaller` 요소는 `org.springframework.oxm.jaxb.Jaxb2Marshaller`를 설정한다:

```xml
<oxm:jaxb2-marshaller id="marshaller" contextPath="org.springframework.ws.samples.airline.schema"/>
```

하위 요소 `class-to-be-bound`를 사용해서 마샬러에 바인딩할 클래스 리스트를 제공할 수도 있다:

```xml
<oxm:jaxb2-marshaller id="marshaller">
    <oxm:class-to-be-bound name="org.springframework.ws.samples.airline.schema.Airport"/>
    <oxm:class-to-be-bound name="org.springframework.ws.samples.airline.schema.Flight"/>
    ...
</oxm:jaxb2-marshaller>
```

다음 테이블은 사용할 수 있는 속성을 나타내고 있다:

| Attribute     | Description        | Required |
| :------------ | :----------------- | :------- |
| `id`          | 마샬러의 ID        | No       |
| `contextPath` | JAXB 컨텍스트 경로 | No       |

---

## 7.6. JiBX

JiBX 프레임워크는 하이버네이트가 ORM에 제공하는 것과 유사한 솔루션을 제공한다. 바인딩 정의로 어떻게 자바 객체와 XML을 상호 변환할지에 대한 규칙을 정의한다. 바인딩 준비를 마치고 클래스를 컴파일한 뒤에 JiBX 바인딩 컴파일러는, 클래스 파일에 클래스 인스턴스와 XML을 상호 변환하는 코드를 추가한다.

JiBX에 대한 자세한 정보는 [JiBX 웹 사이트](http://jibx.sourceforge.net/)에서 확인해라. 스프링 통합 클래스는 `org.springframework.oxm.jibx` 패키지에 있다.

### 7.6.1. Using `JibxMarshaller`

`JibxMarshaller` 클래스는 스프링의 `Marshaller`, `Unmarshaller` 인터페이스를 둘 다 구현하고 있다. 이 클래스를 사용하려면 마샬링할 클래스명을 지정해야 한다. 클래스명은 `targetClass` 프로퍼티로 설정할 수 있다. 원한다면 `bindingName` 프로퍼티로 바인딩할 이름을 지정해도 된다. 다음은 `Flights` 클래스를 바인딩하는 예제다:

```xml
<beans>
    <bean id="jibxFlightsMarshaller" class="org.springframework.oxm.jibx.JibxMarshaller">
        <property name="targetClass">org.springframework.oxm.jibx.Flights</property>
    </bean>
    ...
</beans>
```

`JibxMarshaller`는 단일 클래스 용으로 설정된다. 클래스 여러 개를 마샬링하려면 `JibxMarshaller` 인스턴스를 여러 개 설정하고, `targetClass` 프로퍼티에 각 클래스를 지정해야 한다.

#### XML Configuration Namespace

`jibx-marshaller` 태그는 `org.springframework.oxm.jibx.JibxMarshaller`를 설정한다:

```xml
<oxm:jibx-marshaller id="marshaller" target-class="org.springframework.ws.samples.airline.schema.Flight"/>
```

다음 테이블은 사용할 수 있는 속성을 나타내고 있다:

| Attribute      | Description                 | Required |
| :------------- | :-------------------------- | :------- |
| `id`           | 마샬러의 ID                 | No       |
| `target-class` | 마샬러의 타겟 클래스        | Yes      |
| `bindingName`  | 마샬러가 사용할 바인딩 이름 | No       |

---

## 7.7. XStream

XStream은 객체를 XML로 직렬화하고 다시 객체로 역직렬화할 수 있는 간단한 라이브러리다. 매핑은 따로 필요하지 않으며, 매우 깔끔한 XML을 생성한다.

XStream에 대한 자세한 정보는 [XStream 웹 사이트](https://x-stream.github.io/)에서 확인해라. 스프링 통합 클래스는 `org.springframework.oxm.xstream` 패키지에 있다.

### 7.7.1. Using `XStreamMarshaller`

`XStreamMarshaller`는 별다른 설정이 필요 없으며, 어플리케이션 컨텍스트에 직접 설정할 수 있다. XML을 추가로 커스텀하려면 다음 예제처럼 맵을 사용해 alias 문자열을 클래스에 매핑하면 된다:

```xml
<beans>
    <bean id="xstreamMarshaller" class="org.springframework.oxm.xstream.XStreamMarshaller">
        <property name="aliases">
            <props>
                <prop key="Flight">org.springframework.oxm.xstream.Flight</prop>
            </props>
        </property>
    </bean>
    ...
</beans>
```

> 기본적으로 XStream은 임의의 클래스를 언마샬할 수 있기 때문에, 의도치 않게 신뢰할 수 없는 자바 코드가 실행될 수도 있다. 따라서 외부(웹) XML 소스를 언마샬할 때는 `XStreamMarshaller`를 사용하지 않는 게 좋다. 임의의 외부 소스를 모두 허용하는 건 보안상 취약하다.
>
> `XStreamMarshaller`를 사용해 외부 소스를 XML로 언마샬하기로 했다면, 다음 예제처럼 `XStreamMarshaller`의 `supportedClasses` 프로퍼티를 설정해라:
>
> ```xml
> <bean id="xstreamMarshaller" class="org.springframework.oxm.xstream.XStreamMarshaller">
>  <property name="supportedClasses" value="org.springframework.oxm.xstream.Flight"/>
>  ... </bean>
> ```
>
> 이렇게하면 등록한 클래스만 언마샬할 수 있다.
>
> 지원하는 클래스만 언마샬할 땐 추가로 [커스텀 컨버터](https://docs.spring.io/spring-framework/docs/5.3.2/javadoc-api/org/springframework/oxm/xstream/XStreamMarshaller.html#setConverters(com.thoughtworks.xstream.converters.ConverterMatcher…))를 등록할 수 있다. 지정한 도메인 클래스를 지원하는 컨버터 외에도, `CatchAllConverter`를 컨버터 리스트에 맨 뒤에 추가해도 된다. 이렇게하면 보안에 취약한 디폴트 XStream 컨버터는 우선 순위가 낮아 실행되지 않는다.

> XStream은 데이터 바인딩 라이브러리가 아니라 XML 직렬화 라이브러리라는 점을 명심해라. 그렇기 때문에 네임스페이스 지원엔 제약이 따른다. 따라서 웹 서비스에서 사용하기엔 다소 부적합하다.