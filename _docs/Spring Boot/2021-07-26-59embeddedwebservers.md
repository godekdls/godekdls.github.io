---
title: Embedded Web Servers
category: Spring Boot
order: 59
permalink: /Spring%20Boot/howto.embedded-web-servers/
description: 임베디드 서버와 관련된 how to 가이드 (웹 서버 변경하기, 포트 변경하기, 프록시 헤더 설정하기, 필터 등록하기 등)
image: ./../../images/springboot/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 부트
originalRefLink: https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#howto.webserver
parent: “How-to” Guides
parentUrl: /Spring%20Boot/how-to-guides/
---
<script>defaultLanguages = ['properties']</script>

### 목차

- [12.3.1. Use Another Web Server](#1231-use-another-web-server)
- [12.3.2. Disabling the Web Server](#1232-disabling-the-web-server)
- [12.3.3. Change the HTTP Port](#1233-change-the-http-port)
- [12.3.4. Use a Random Unassigned HTTP Port](#1234-use-a-random-unassigned-http-port)
- [12.3.5. Discover the HTTP Port at Runtime](#1235-discover-the-http-port-at-runtime)
- [12.3.6. Enable HTTP Response Compression](#1236-enable-http-response-compression)
- [12.3.7. Configure SSL](#1237-configure-ssl)
- [12.3.8. Configure HTTP/2](#1238-configure-http2)
  + [HTTP/2 with Tomcat](#http2-with-tomcat)
  + [HTTP/2 with Jetty](#http2-with-jetty)
  + [HTTP/2 with Reactor Netty](#http2-with-reactor-netty)
  + [HTTP/2 with Undertow](#http2-with-undertow)
- [12.3.9. Configure the Web Server](#1239-configure-the-web-server)
- [12.3.10. Add a Servlet, Filter, or Listener to an Application](#12310-add-a-servlet-filter-or-listener-to-an-application)
  + [Add a Servlet, Filter, or Listener by Using a Spring Bean](#add-a-servlet-filter-or-listener-by-using-a-spring-bean)
  + [Add Servlets, Filters, and Listeners by Using Classpath Scanning](#add-servlets-filters-and-listeners-by-using-classpath-scanning)
- [12.3.11. Configure Access Logging](#12311-configure-access-logging)
- [12.3.12. Running Behind a Front-end Proxy Server](#12312-running-behind-a-front-end-proxy-server)
  + [Customize Tomcat’s Proxy Configuration](#customize-tomcats-proxy-configuration)
- [12.3.13. Enable Multiple Connectors with Tomcat](#12313-enable-multiple-connectors-with-tomcat)
- [12.3.14. Use Tomcat’s LegacyCookieProcessor](#12314-use-tomcats-legacycookieprocessor)
- [12.3.15. Enable Tomcat’s MBean Registry](#12315-enable-tomcats-mbean-registry)
- [12.3.16. Enable Multiple Listeners with Undertow](#12316-enable-multiple-listeners-with-undertow)
- [12.3.17. Create WebSocket Endpoints Using @ServerEndpoint](#12317-create-websocket-endpoints-using-serverendpoint)

---

## 12.3. Embedded Web Servers

스프링 부트 웹 애플리케이션엔 임베디드 웹 서버가 포함돼 있다. 이 기능을 사용하다 보면 임베디드 서버를 변경하는 방법은 무엇인지, 임베디드 서버는 어떻게 설정하는지 등, 다양한 질문들이 들어온다. 이번 섹션에선 이런 질문들에 답해보겠다.

### 12.3.1. Use Another Web Server

스프링 부트 스타터 중에는 디폴트 임베디드 컨테이너가 포함돼 있는 스타터가 많이 있다:

- 서블릿 스택 애플리케이션에선 `spring-boot-starter-web`이 `spring-boot-starter-tomcat`을 포함하고 있어서 톰캣이 추가되지만, 톰캣 대신 `spring-boot-starter-jetty`나 `spring-boot-starter-undertow`를 사용해도 된다.
- 리액티브 스택 애플리케이션에선 `spring-boot-starter-webflux`가 `spring-boot-starter-reactor-netty`를 포함하고 있어서 Reactor Netty가 추가되지만, Netty 대신 `spring-boot-starter-tomcat`이나 `spring-boot-starter-jetty`, `spring-boot-starter-undertow`를 사용해도 된다.

다른 HTTP 서버로 전환한다면 디폴트 의존성을 필요한 의존성으로 바꿔줘야 한다. 스프링 부트가 제공하는 별도 HTTP 서버 전용 스타터를 사용하면 쉽게 변경할 수 있다.

다음은 메이븐을 이용해 스프링 MVC에서 톰캣을 제외하고 Jetty를 추가하는 예시다:

```xml
<properties>
    <servlet-api.version>3.1.0</servlet-api.version>
</properties>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
    <exclusions>
        <!-- Exclude the Tomcat dependency -->
        <exclusion>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-tomcat</artifactId>
        </exclusion>
    </exclusions>
</dependency>
<!-- Use Jetty instead -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-jetty</artifactId>
</dependency>
```

> Tomcat 9, Undertow 2와는 달리 Jetty 9.4에선 서블릿 4.0을 지원하지 않으므로 서블릿 API 버전을 재정의했다. 서블릿 4.0을 지원하는 Jetty 10을 사용하고 싶을때는 `servlet-api.version` 프로퍼티가 아닌 `jetty.version` 프로퍼티를 재정의해라.

다음은 그래들을 이용해 필요한 의존성과 [module replacement](https://docs.gradle.org/current/userguide/resolution_rules.html#sec:module_replacement)를 설정하는 예시다. 여기선 스프링 웹플럭스에 들어있는 Reactor Netty 대신 Undertow를 사용한다:

```gradle
dependencies {
    implementation "org.springframework.boot:spring-boot-starter-undertow"
    implementation "org.springframework.boot:spring-boot-starter-webflux"
    modules {
        module("org.springframework.boot:spring-boot-starter-reactor-netty") {
            replacedBy("org.springframework.boot:spring-boot-starter-undertow", "Use Undertow instead of Reactor Netty")
        }
    }
}
```

> `WebClient` 클래스를 사용하려면 `spring-boot-starter-reactor-netty`가 필요하므로, 다른 HTTP 서버를 추가하더라도 Netty 의존성을 유지해야 할 수도 있다.

### 12.3.2. Disabling the Web Server

클래스패스에 웹 서버를 시작할 때 필요한 클래스가 들어 있으면 스프링 부트는 자동으로 웹 서버를 시작한다. 이 동작을 비활성화하려면 아래 예시처럼 `application.properties`에 `WebApplicationType`을 설정해라:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.main.web-application-type=none
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  main:
    web-application-type: "none"
```

### 12.3.3. Change the HTTP Port

독립 실행형 애플리케이션에선 메인 HTTP 포트는 디폴트로 `8080`을 사용하지만 `server.port`로 변경할 수 있다 (`application.properties`나 시스템 프로퍼티 등으로). `Environment` 값은 [완화한 규칙으로 바인딩](../externalized-configuration#relaxed-binding)하는 덕분에 `SERVER_PORT`를 사용해도 된다 (OS 환경 변수 등에).

HTTP 엔드포인트는 완전히 꺼버리고 `WebApplicationContext`만 생성하려면 `server.port=-1`을 사용해라 (테스트에 유용할 거다).

자세한 내용은 '스프링 부트 기능' 섹션에 있는 "[임베디드 서블릿 컨테이너 커스텀하기](../developing-web-applications#customizing-embedded-servlet-containers)"나 [`ServerProperties`](https://github.com/spring-projects/spring-boot/tree/v2.5.2/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/web/ServerProperties.java) 소스 코드를 참고해라.

### 12.3.4. Use a Random Unassigned HTTP Port

놀고 있는 포트를 스캔하려면 (OS 네이티브를 사용해서 충돌 방지) `server.port=0`을 사용해라.

### 12.3.5. Discover the HTTP Port at Runtime

서버를 실행한 포트는 로그를 통해서도 확인할 수 있고, `WebServerApplicationContext`에서 `WebServer`에 접근해도 확인할 수 있다. 컨테이너를 가져와서 초기화를 마쳤는지 확인할 수 있는 가장 좋은 방법은 `ApplicationListener<WebServerInitializedEvent>` 타입 `@Bean`을 추가해서, 이벤트를 게시했을 때 이벤트에서 컨테이너를 꺼내오는 거다.

`@SpringBootTest(webEnvironment=WebEnvironment.RANDOM_PORT)`를 사용하는 테스트에선 아래 예제처럼 `@LocalServerPort` 어노테이션을 통해 필드에 실제 포트를 주입할 수도 있다:

```java
@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
public class MyWebIntegrationTests {

    @LocalServerPort
    int port;

    // ...

}
```

> `@LocalServerPort`는 `@Value("${local.server.port}")`를 선언하고 있는 메타 어노테이션이다. 일반적인 애플리케이션에서 포트를 주입하려고 하면 안 된다. 방금 보았듯이 이 값은 컨테이너가 초기화된 다음에만 설정된다. 애플리케이션 코드 콜백은 테스트와는 다르게 더 일찍 처리된다 (값이 실제로 세팅되기 전에).

### 12.3.6. Enable HTTP Response Compression

HTTP 응답 압축은 Jetty, Tomcat, Undertow에서 지원한다. 다음과 같이 `application.properties`로 활성화할 수 있다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
server.compression.enabled=true
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
server:
  compression:
    enabled: true
```

기본적으로 응답을 압축할 수 있으려면 최소한 2048바이트는 돼야 한다. 이 동작은 `server.compression.min-response-size` 프로퍼티로 설정할 수 있다.

마찬가지로, 기본적으로는 아래와 같은 컨텐츠 타입일 때만 응답을 압축한다:

- `text/html`
- `text/xml`
- `text/plain`
- `text/css`
- `text/javascript`
- `application/javascript`
- `application/json`
- `application/xml`

이 동작은 `server.compression.mime-types` 프로퍼티로 설정할 수 있다.

### 12.3.7. Configure SSL

SSL 설정은 `server.ssl.*` 프로퍼티를 통해 선언할 수 있다. 보통은 `application.properties`, `application.yml`에 선언한다. 다음은 `application.properties`에 SSL 프로퍼티를 설정하는 예시다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
server.port=8443
server.ssl.key-store=classpath:keystore.jks
server.ssl.key-store-password=secret
server.ssl.key-password=another-secret
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
server:
  port: 8443
  ssl:
    key-store: "classpath:keystore.jks"
    key-store-password: "secret"
    key-password: "another-secret"
```

지원하는 전체 프로퍼티가 궁금하다면 [`Ssl`](https://github.com/spring-projects/spring-boot/tree/v2.5.2/spring-boot-project/spring-boot/src/main/java/org/springframework/boot/web/server/Ssl.java)을 참고해라.

위같은 설정을 사용하는 애플리케이션에는 더 이상 8080 포트의 일반 HTTP 커넥터를 지원하지 않는다. 스프링 부트에선 `application.properties`를 통해 HTTP 커넥터와 HTTPS 커넥터를 둘 다 설정하는 건 불가능하다. 둘 다 사용하고 싶다면 둘 중 하나는 코드로 직접 설정해야 한다. 둘 중에서는 HTTP 커넥터가 코드로 설정하기가 좀 더 쉽기 때문에 `application.properties`로는 HTTPS를 설정하는 걸 추천한다.

### 12.3.8. Configure HTTP/2

스프링 부트 애플리케이션에선 설정 프로퍼티 `server.http2.enabled`를 사용하면 HTTP/2 지원을 활성화할 수 있다. `h2`(TLS를 통한 HTTP/2)와 `h2c`(TCP를 통한 HTTP/2)를 둘 다 지원한다. `h2`를 사용하려면 반드시 SSL도 활성화해야 한다. SSL을 활성화하지 않았을 땐 `h2c`를 사용하게 된다. `h2` 프로토콜은 모든 JDK 8 릴리즈에서 기본으로 지원하지 않기 때문에, 실제로 `h2`를 지원하는 세부적인 것들은 선택한 웹 서버와 애플리케이션 환경에 따라 달라진다.

#### HTTP/2 with Tomcat

스프링 부트는 기본적으로 톰캣 9.0.x를 사용한다. 톰캣 9.0.x는 `h2c`를 기본으로 지원하며, JDK 9 이상을 사용할 때는 `h2`도 기본으로 지원한다. 아니면 호스트 운영 체제에 `libtcnative` 라이브러리와 그 의존성들이 설치돼어 있을 땐, JDK 8에서도 `h2`를 사용할 수 있다.

라이브러리 디렉토리를 JVM 라이브러리 경로로 사용할 수 없다면 따로 설정해줘야 한다. `-Djava.library.path=/usr/local/opt/tomcat-native/lib`같은 JVM 인자를 사용하면 된다. 자세한 내용은 [공식 톰캣 문서](https://tomcat.apache.org/tomcat-9.0-doc/apr.html)에 나와있다.

HTTP/2와 SSL을 활성화해서 톰캣 9.0.x을 기동시키는데 네이티브 지원이 없는 JDK 8을 사용하면 다음과 같은 에러 로그가 찍힌다:

```java
ERROR 8787 --- [           main] o.a.coyote.http11.Http11NioProtocol      : The upgrade handler [org.apache.coyote.http2.Http2Protocol] for [h2] only supports upgrade via ALPN but has been configured for the ["https-jsse-nio-8443"] connector that does not support ALPN.
```

큰 문제가 있는 것은 아니며, 에러가 보이더라도 애플리케이션을 시작하면 HTTP/1.1 SSL을 사용할 수 있다.

#### HTTP/2 with Jetty

Jetty에서 HTTP/2를 지원하려면 별도로 `org.eclipse.jetty.http2:http2-server` 의존성이 필요하다. `h2c`를 사용할 때는 다른 의존성은 없어도 된다. `h2`를 사용한다면 배포하는 방식에 따라 아래 의존성 중 하나를 선택해야 한다:

- JDK9+로 실행하는 애플리케이션은 `org.eclipse.jetty:jetty-alpn-java-server`
- JDK8u252+로 실행하는 애플리케이션은 `org.eclipse.jetty:jetty-alpn-openjdk8-server`
- JDK 요구 사항은 없는 `org.eclipse.jetty:jetty-alpn-conscrypt-server`와 [Conscrypt 라이브러리](https://www.conscrypt.org/)

#### HTTP/2 with Reactor Netty

`spring-boot-webflux-starter`는 기본 서버로 Reactor Netty를 사용하고 있다. Reactor Netty에선 다른 의존성이 없이도 JDK 8+를 이용해 `h2c`를 지원한다. JDK 9 이상에선 JDK 지원을 이용해 `h2`를 지원한다. 네이티브 라이브러리로도 `h2`를 지원하고 있기 때문에 JDK 8 환경에서도 사용할 수 있으며, 런타임 성능도 최적화할 수 있다. 대신에 애플리케이션에 별도 의존성은 넣어줘야 한다.

스프링 부트는 모든 플랫폼에서 사용할 수 있는 네티이브 라이브러리가 들어 있는 `io.netty:netty-tcnative-boringssl-static` "uber jar"의 버전을 관리해준다. classifier를 사용하면 필요한 의존성만 선택해서 가져올 수 있다 ([Netty 공식 문서](https://netty.io/wiki/forked-tomcat-native.html) 참고).

#### HTTP/2 with Undertow

Undertow 1.4.0+부터는 JDK8을 사용하면 별도 의존성 없이도 `h2`와 `h2c`를 지원한다.

### 12.3.9. Configure the Web Server

일반적으로 웹 서버를 커스텀할 땐 먼저, 지원하는 키들 중에 필요한 게 있는지 찾아보고, `application.properties`(또는 `application.yml`이나 environment 등. [외부 프로퍼티에 사용할 수 있는 빌트인 옵션 찾기](../howto.properties-and-configuration#1229-discover-built-in-options-for-external-properties) 참고)에 설정을 추가하는 게 좋다. 웹 서버를 설정할 땐 `server.*` 네임스페이스가 매우 유용하며, `server.tomcat.*`, `server.jetty.*` 등과 같은 서버 전용 기능을 위한 별도 네임스페이스도 지원한다. [공통 애플리케이션 프로퍼티](https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#application-properties)에 나와있는 목록을 참고해라.

앞에서 이미 압축, SSL, HTTP/2같이 매우 흔한 유스 케이스들을 다뤘다. 하지만 현재 직면한 요구사항에 맞는 설정 키가 존재하지 않는다면 이제는 [`WebServerFactoryCustomizer`](https://docs.spring.io/spring-boot/docs/2.5.2/api/org/springframework/boot/web/server/WebServerFactoryCustomizer.html)를 살펴봐야 한다. 이 인터페이스를 구현해 컴포넌트로 선언하면 사용 중인 서버 팩토리에 접근할 수 있다. 단, 서버 팩토리는 사용 중인 서버(Tomcat, Jetty, Reactor Netty, Undertow)와 웹 스택(Servlet 또는 Reactive)에 맞는 클래스를 지정해야 한다.

아래 있는 예시는 `spring-boot-starter-web`(서블릿 스택)을 사용하는 톰캣 서버를 커스텀하는 예시다:

```java
@Component
public class MyTomcatWebServerCustomizer implements WebServerFactoryCustomizer<TomcatServletWebServerFactory> {

    @Override
    public void customize(TomcatServletWebServerFactory factory) {
        // customize the factory here
    }

}
```

> 스프링 부트는 서버를 자동 설정할 때도 역시 내부적으로 자동 설정 인프라를 이용한다. 자동 설정된 `WebServerFactoryCustomizer` 빈의 order는 `0`이고, 따로 order를 명시하지 않았다면 사용자가 정의한 다른 customizer보다 먼저 처리된다.

customizer를 사용해서 `WebServerFactory`에 접근했다면, 이 팩토리를 통해 커넥터, 서버 리소스나 서버 자체 설정 같이 서버에 특화된 기능들을 설정할 수 있다. 이때는 전부 서버 전용 API를 사용한다.

스프링 부트는 전용 웹 서버 팩토리들도 제공하고 있다:

| Server   | Servlet stack                     | Reactive stack                     |
| :------- | :-------------------------------- | :--------------------------------- |
| Tomcat   | `TomcatServletWebServerFactory`   | `TomcatReactiveWebServerFactory`   |
| Jetty    | `JettyServletWebServerFactory`    | `JettyReactiveWebServerFactory`    |
| Undertow | `UndertowServletWebServerFactory` | `UndertowReactiveWebServerFactory` |
| Reactor  | N/A                               | `NettyReactiveWebServerFactory`    |

이걸로도 안 된다면 최후의 수단으로 자체 `WebServerFactory` 빈을 선언할 수도 있다. 빈을 직접 선언하면 스프링 부트에서 제공하는 빈은 재정의된다. 이때는 자동 설정된 customizer들까지 커스텀 팩토리에 적용되므로, 이 옵션은 주의해서 사용해야 된다.

### 12.3.10. Add a Servlet, Filter, or Listener to an Application

서블릿 스택 애플리케이션에선, 즉 `spring-boot-starter-web`을 사용할 때는, 두 가지 방법으로 애플리케이션에 `Servlet`, `Filter`, `ServletContextListener`와 서블릿 API가 지원하는 다른 리스너들을 추가할 수 있다:

- [스프링 빈을 이용해 Servlet, Filter, Listener를 하나씩 추가하기](#add-a-servlet-filter-or-listener-by-using-a-spring-bean)
- [클래스패스 스캔을 통해 Servlet, Filter, Listener를 한꺼번에 등록하기](#add-servlets-filters-and-listeners-by-using-classpath-scanning)

#### Add a Servlet, Filter, or Listener by Using a Spring Bean

스프링 빈을 이용해 `Servlet`이나, `Filter`, 서블릿 `*Listener`를 추가하려면 반드시 `@Bean` 정의를 제공해야 한다. 설정이나 의존성을 주입하고 싶을 때 매우 유용할 거다. 하지만 이런 빈들은 애플리케이션 라이프사이클 중 매우 초기에 컨테이너에 넣어지기 때문에, 다른 빈들까지 너무 많이 미리 초기화되버리는 상황을 만들지 않도록 각별히 주의해야 한다. (예를 들어, 이런 빈에선 `DataSource`나 JPA 설정에 의존하는 건 좋은 생각이 아니다.) 이 문제는 빈 초기화를 처음 사용하는 시점으로 미루면 해결할 수 있다.

`Filter`와 `Servlet`의 경우, `FilterRegistrationBean`이나 `ServletRegistrationBean`을 사용하면 url 매핑이나 init 파라미터를 추가할 수도 있다. 기존 컴포넌트 대신 사용할 수도 있고 추가로 함께 사용해도 된다.

> `FilterRegistrationBean`에 `dispatcherType`을 지정하지 않으면 `REQUEST`를 사용한다. 이는 서블릿 사양의 디폴트 디스패처 타입에 맞게 맞춘 거다.

서블릿 필터 빈들도 다른 스프링 빈과 똑같이 순서를 정의할 수 있다. "[서블릿, 필터, 리스너를 스프링 빈으로 등록하기](../developing-web-applications#registering-servlets-filters-and-listeners-as-spring-beans)" 섹션을 꼭 확인해봐라.

##### Disable Registration of a Servlet or Filter

[앞에서 설명했듯이](#add-a-servlet-filter-or-listener-by-using-a-spring-bean) `Servlet`, `Filter` 빈들은 전부 서블릿 컨테이너에 자동으로 등록된다. 등록하고 싶지 않은 `Filter`, `Servlet` 빈이 있다면 다음 예시처럼 registration bean을 생성하고 비활성화로 마킹해라:

```java
@Configuration(proxyBeanMethods = false)
public class MyFilterConfiguration {

    @Bean
    public FilterRegistrationBean<MyFilter> registration(MyFilter filter) {
        FilterRegistrationBean<MyFilter> registration = new FilterRegistrationBean<>(filter);
        registration.setEnabled(false);
        return registration;
    }

}
```

#### Add Servlets, Filters, and Listeners by Using Classpath Scanning

`@Configuration` 클래스에 `@ServletComponentScan` 어노테이션을 달아 등록하고 싶은 컴포넌트가 있는 패키지를 명시하면 `@WebServlet`, `@WebFilter`, `@WebListener` 어노테이션 클래스를 임베디드 서블릿 컨테이너에 자동으로 등록할 수 있다. `@ServletComponentScan`은 기본적으로 이 어노테이션을 선언한 클래스의 패키지에서 스캔을 시작한다.

### 12.3.11. Configure Access Logging

Tomcat, Undertow, Jetty에선 각자의 네임스페이스를 통해 액세스 로그를 설정할 수 있다.

예를 들어 다음 설정은 [커스텀 패턴](https://tomcat.apache.org/tomcat-9.0-doc/config/valve.html#Access_Logging)을 사용해서 Tomcat의 액세스 로그를 기록한다.

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
server.tomcat.basedir=my-tomcat
server.tomcat.accesslog.enabled=true
server.tomcat.accesslog.pattern=%t %a %r %s (%D ms)
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
server:
  tomcat:
    basedir: "my-tomcat"
    accesslog:
      enabled: true
      pattern: "%t %a %r %s (%D ms)"
```

> 기본적으로 로그는 톰켓 베이스 디렉토리 아래에 있는 `logs` 디렉토리에 기록한다. 이 `logs` 디렉토리는 기본적으로 임시 디렉토리기 때문에, 톰캣의 베이스 디렉토리를 수정하거나 절대 경로로 바꿔주는 게 좋다. 위 예시에선 애플리케이션의 작업 디렉토리의 상대 경로인 `my-tomcat/logs`에 로그를 기록한다.

Undertow의 액세스 로그는 다음 예제와 비슷하게 설정하면 된다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
server.undertow.accesslog.enabled=true
server.undertow.accesslog.pattern=%t %a %r %s (%D ms)
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
server:
  undertow:
    accesslog:
      enabled: true
      pattern: "%t %a %r %s (%D ms)"
```

로그는 애플리케이션의 작업 디렉토리 하위에 있는 `logs` 디렉토리에 저장된다. `server.undertow.accesslog.dir` 프로퍼티를 설정하면 이 위치를 커스텀할 수 있다.

마지막으로 Jetty의 액세스 로그도 다음과 같이 설정할 수 있다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
server.jetty.accesslog.enabled=true
server.jetty.accesslog.filename=/var/log/jetty-access.log
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
server:
  jetty:
    accesslog:
      enabled: true
      filename: "/var/log/jetty-access.log"
```

기본적으로 로그는 `System.err`로 리다이렉트된다. 자세한 내용은 Jetty 문서를 참고해라.

### 12.3.12. Running Behind a Front-end Proxy Server

애플리케이션 앞에 프록시나 로드 밸런서를 두거나 클라우드에서 실행한다면, 중간에 요청 정보(호스트, 포트, 스킴 등)가 변경될 수도 있다. 애플리케이션을 `10.10.10.10:8080`에서 실행하더라도, HTTP 클라이언트에선 `example.org`로만 접근해야 하는 경우가 있다.

[RFC7239 "Forwarded Headers"](https://tools.ietf.org/html/rfc7239)에선 `Forwarded` HTTP 헤더를 정의하고 있다. 프록시에선 이 헤더를 통해 기존 요청에 대한 정보를 제공할 수 있다. 링크를 만들어 HTTP 302 응답이나, JSON 도큐먼트, HTML 페이지로 클라이언트한테 전송할 땐, 이 헤더들을 읽어 자동으로 헤더 정보를 이용하게끔 설정할 수 있다. 물론 `X-Forwarded-Host`, `X-Forwarded-Port`, `X-Forwarded-Proto`, `X-Forwarded-Ssl`, `X-Forwarded-Prefix`같은 비표준 헤더도 존재한다.

프록시가 흔히 쓰는 `X-Forwarded-For`, `X-Forwarded-Proto` 헤더를 추가해준다면 `server.forward-headers-strategy`를 `NATIVE`로 설정하기만 하면 된다. 이 옵션을 사용하면 웹 서버 자체에서 네이티브로 이 기능을 지원해줄 거다. 정확한 동작이 궁금하다면 웹 서버 문서를 검색해봐라.

그 외에는 스프링 프레임워크가 제공하는 [ForwardedHeaderFilter](https://docs.spring.io/spring-framework/docs/5.3.8/reference/html/web.html#filters-forwarded-headers)를 사용할 수 있다. `server.forward-headers-strategy`를 `FRAMEWORK`로 설정해주면 이 필터를 애플리케이션의 서블릿 필터로 등록할 수 있다.

> 톰캣을 사용할 때 프록시에서 SSL이 종료되는 경우 `server.tomcat.redirect-context-root`를 `false`로 설정해야 한다. 그래야만 리다이렉션을 수행하기 전에 `X-Forwarded-Proto` 헤더를 사용할 수 있다.

> 애플리케이션을 Cloud Foundry나 Heroku에서 실행한다면 `server.forward-headers-strategy` 프로퍼티는 기본적으로 `NATIVE`로 설정된다. 그외 다른 경우는 모두 `NONE`이 디폴트다.

#### Customize Tomcat’s Proxy Configuration

톰캣을 사용한다면 다음 예제와 같이 "forwarded" 정보를 전달할 때 사용하는 헤더들의 이름을 추가로 설정할 수 있다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
server.tomcat.remoteip.remote-ip-header=x-your-remote-ip-header
server.tomcat.remoteip.protocol-header=x-your-protocol-header
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
server:
  tomcat:
    remoteip:
      remote-ip-header: "x-your-remote-ip-header"
      protocol-header: "x-your-protocol-header"
```

톰캣은 신뢰할 수 있는 내부 프록시를 매칭시키는 디폴트 정규식도 함께 설정된다. 기본적으로 IP 주소 `10/8`, `192.168/16`, `169.254/16`, `127/8`을 신뢰한다. 이 밸브 설정은 아래와 같이 `application.properties`를 통해 커스텀할 수 있다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
server.tomcat.remoteip.internal-proxies=192\\.168\\.\\d{1,3}\\.\\d{1,3}
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
server:
  tomcat:
    remoteip:
      internal-proxies: "192\\.168\\.\\d{1,3}\\.\\d{1,3}"
```

> `internal-proxys`를 공백으로 설정하면 모든 프록시를 신뢰할 수 있다 (단, 프로덕션에선 이렇게 설정하면 안 된다).

자동 설정을 끄고 (`server.forward-headers-strategy=NONE`) `WebServerFactoryCustomizer` 빈으로 새 밸브 인스턴스를 추가하면 톰캣의 `RemoteIpValve` 설정을 전부 제어할 수 있다.

### 12.3.13. Enable Multiple Connectors with Tomcat

`TomcatServletWebServerFactory`는 HTTP, HTTPS 커넥터를 포함해서 커넥터를 여러 개 허용할 수 있다. 이 팩토리에는 다음과 같이 `org.apache.catalina.connector.Connector`를 추가할 수 있다:

```java
@Configuration(proxyBeanMethods = false)
public class MyTomcatConfiguration {

    @Bean
    public WebServerFactoryCustomizer<TomcatServletWebServerFactory> sslConnectorCustomizer() {
        return (tomcat) -> tomcat.addAdditionalTomcatConnectors(createSslConnector());
    }

    private Connector createSslConnector() {
        Connector connector = new Connector("org.apache.coyote.http11.Http11NioProtocol");
        Http11NioProtocol protocol = (Http11NioProtocol) connector.getProtocolHandler();
        try {
            URL keystore = ResourceUtils.getURL("keystore");
            URL truststore = ResourceUtils.getURL("truststore");
            connector.setScheme("https");
            connector.setSecure(true);
            connector.setPort(8443);
            protocol.setSSLEnabled(true);
            protocol.setKeystoreFile(keystore.toString());
            protocol.setKeystorePass("changeit");
            protocol.setTruststoreFile(truststore.toString());
            protocol.setTruststorePass("changeit");
            protocol.setKeyAlias("apitester");
            return connector;
        }
        catch (IOException ex) {
            throw new IllegalStateException("Fail to create ssl connector", ex);
        }
    }

}
```

### 12.3.14. Use Tomcat’s LegacyCookieProcessor

스프링 부트에서 기본으로 사용하는 임베디드 톰캣은 쿠키 포맷 "Version 0"을 지원하지 않기 때문에 다음과 같은 에러를 보게될 수도 있다:

```java
java.lang.IllegalArgumentException: An invalid character [32] was present in the Cookie value
```

가능하면 최신 쿠키 사양과 호환되는 값들만 저장하도록 코드를 수정하는 것도 고려해봐야 한다. 하지만 쿠키를 작성하는 방식을 변경할 수 없을 때는 대신에 톰캣에서 `LegacyCookieProcessor`를 사용하도록 설정해줄 수 있다. `LegacyCookieProcessor`로 전환하려면 다음 예제와 같이 `WebServerFactoryCustomizer`빈을 사용해 `TomcatContextCustomizer`를 추가해라:

```java
@Configuration(proxyBeanMethods = false)
public class MyLegacyCookieProcessorConfiguration {

    @Bean
    public WebServerFactoryCustomizer<TomcatServletWebServerFactory> cookieProcessorCustomizer() {
        return (factory) -> factory
                .addContextCustomizers((context) -> context.setCookieProcessor(new LegacyCookieProcessor()));
    }

}
```

### 12.3.15. Enable Tomcat’s MBean Registry

임베디드 톰캣의 MBean 레지스트리는 기본적으로 비활성화돼 있다. 덕분에 톰캣의 메모리 사용량을 최소화할 수 있다. 톰캣의 MBean을 사용해서 Micrometer 등을 통해 메트릭을 노출하고 싶다면 다음 예제와 같이 `server.tomcat.mbeanregistry.enabled` 프로퍼티를 사용해야 한다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
server.tomcat.mbeanregistry.enabled=true
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
server:
  tomcat:
    mbeanregistry:
      enabled: true
```

### 12.3.16. Enable Multiple Listeners with Undertow

다음 예제와 같이 `UndertowBuilderCustomizer`를 `UndertowServletWebServerFactory`에 추가하고 `Builder`에 리스너를 추가해라:

```java
@Configuration(proxyBeanMethods = false)
public class MyUndertowConfiguration {

    @Bean
    public WebServerFactoryCustomizer<UndertowServletWebServerFactory> undertowListenerCustomizer() {
        return (factory) -> factory.addBuilderCustomizers(this::addHttpListener);
    }

    private Builder addHttpListener(Builder builder) {
        return builder.addHttpListener(8080, "0.0.0.0");
    }

}
```

### 12.3.17. Create WebSocket Endpoints Using @ServerEndpoint

임베디드 컨테이너를 사용하는 스프링 부트 애플리케이션에서 `@ServerEndpoint`를 이용하려면 다음 예제와 같이 반드시 `ServerEndpointExporter` `@Bean`을 하나 선언해야 한다:

```java
@Configuration(proxyBeanMethods = false)
public class MyWebSocketConfiguration {

    @Bean
    public ServerEndpointExporter serverEndpointExporter() {
        return new ServerEndpointExporter();
    }

}
```

위 예제에 있는 빈은 WebSocket 컨테이너에 `@ServerEndpoint` 어노테이션을 선언한 빈들을 등록한다. 독립 실행형 서블릿 컨테이너에 배포할 때는 서블릿 컨테이너 이니셜라이저가 이 역할은 담당하며, 이때는 `ServerEndpointExporter` 빈이 필요하지 않다.
