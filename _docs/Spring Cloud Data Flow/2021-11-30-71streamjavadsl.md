---
title: Stream Java DSL
category: Spring Cloud Data Flow
order: 71
permalink: /Spring%20Cloud%20Data%20Flow/feature-guides.stream.java-dsl/
description: 스트림을 생성하고 배포할 수 있는 자바 DSL 사용 가이드
image: ./../../images/springclouddataflow/logo.png
lastmod: 2021-12-02T00:33:00+09:00
comments: true
originalRefName: 스프링 클라우드 데이터 플로우
originalRefLink: https://dataflow.spring.io/docs/feature-guides/streams/java-dsl/
parent: Feature guides
parentUrl: /Spring%20Cloud%20Data%20Flow/feature-guides/
subparent: Stream Feature Guides
subparentNavTitle: Streams
subparentUrl: /Spring%20Cloud%20Data%20Flow/feature-guides.stream/
---

---

스트림을 생성하고 배포할 땐 쉘을 이용하는 대신, `spring-cloud-dataflow-rest-client` 모듈이 제공하는 자바 기반 DSL을 사용해도 된다. 자바 DSL은 코드를 통해 스트림을 생성하고 배포할 수 있는 `DataFlowTemplate` 클래스를 감싸놓은 간편한 라이브러리다.

자바 DSL을 시작하려면 프로젝트에 아래 의존성을 추가해야 한다:

```xml
<dependency>
	<groupId>org.springframework.cloud</groupId>
	<artifactId>spring-cloud-dataflow-rest-client</artifactId>
	<version>2.9.1</version>
</dependency>
```

> 전체 샘플은 [Spring Cloud Data Flow 샘플 레포지토리](https://github.com/spring-cloud/spring-cloud-dataflow-samples/tree/master/javadsl)에서 확인할 수 있다.

### 목차

- [Usage](#usage)
- [Java DSL styles](#java-dsl-styles)
- [Using the DeploymentPropertiesBuilder](#using-the-deploymentpropertiesbuilder)
- [Skipper Deployment Properties](#skipper-deployment-properties)

---

## Usage

자바 DSL에서 핵심 클래스는 `StreamBuilder`, `StreamDefinition`, `Stream`, `StreamApplication`, `DataFlowTemplate`이다. 엔트리 포인트는 `DataFlowTemplate` 인스턴스를 받는 `Stream`의 `builder` 메소드다. `DataFlowTemplate` 인스턴스를 생성하려면 Data Flow 서버의 `URI`를 제공해야 한다.

`StreamBuilder`와 `DataFlowTemplate`을 위한 스프링 부트 자동 설정도 지원한다. [`DataFlowClientProperties`](https://github.com/spring-cloud/spring-cloud-dataflow/blob/master/spring-cloud-dataflow-rest-client/src/main/java/org/springframework/cloud/dataflow/rest/client/config/DataFlowClientProperties.java)에 있는 프로퍼티를 사용해 Data Flow 서버에 대한 커넥션을 설정하면 된다. 보통은 `spring.cloud.dataflow.client.uri` 프로퍼티로 시작하는 게 좋다.

`definition` 스타일을 이용하는 아래 예제를 한 번 살펴보자:

```java
URI dataFlowUri = URI.create("http://localhost:9393");
DataFlowOperations dataFlowOperations = new DataFlowTemplate(dataFlowUri);
dataFlowOperations.appRegistryOperations().importFromResource(
                     "https://dataflow.spring.io/rabbitmq-maven-latest", true);
StreamDefinition streamDefinition = Stream.builder(dataFlowOperations)
                                      .name("ticktock")
                                      .definition("time | log")
                                      .create();
```

`create` 메소드는 생성은 되었지만 아직 배포되진 않은 스트림을 나타내는 `StreamDefinition` 인스턴스를 반환한다. 스트림 정의에 단일 문자열을 사용하기 때문에 "definition" 스타일이라고 부른다 (쉘에서와 동일하다). 아직 Data Flow 서버에 등록되지 않은 애플리케이션이라면, `DataFlowOperations` 클래스를 사용해 등록할 수 있다. `StreamDefinition` 인스턴스에는 스트림을 `deploy`하거나 `destroy`할 수 있는 메소드가 있다. 아래 예시에선 스트림을 배포한다:

```java
Stream stream = streamDefinition.deploy();
```

`Stream` 인스턴스는 스트림을 제어하고 질의할 수 있는 `getStatus`, `destroy`, `undeploy` 메소드를 제공한다. 스트림을 바로 배포할 거라면 `StreamDefinition` 인스턴스를 굳이 로컬 변수로 저장하지 않아도 된다. 대신에 다음과 같이 메소드 호출을 체이닝하면 된다:

```java
Stream stream = Stream.builder(dataFlowOperations)
                  .name("ticktock")
                  .definition("time | log")
                  .create()
                  .deploy();
```

`deploy` 메소드는 배포 프로퍼티 `java.util.Map`을 받는 메소드를 오버로드하고 있다.

"fluent" 자바 DSL 스타일에선 `StreamApplication` 클래스를 사용하는데, 다음 섹션에서 설명할 거다. `StreamBuilder` 클래스는 `Stream.builder(dataFlowOperations)` 메소드가 반환한다. 더 복잡한 애플리케이션에선 보통 `StreamBuilder` 인스턴스 하나를 스프링 `@Bean`으로 생성하고 애플리케이션 전체에 공유하는 게 일반적이다.

---

## Java DSL styles

자바 DSL은 스트림을 생성할 수 있는 두 가지 스타일을 제공한다:

- `definition` 스타일은 쉘에서 텍스트 DSL의 파이프와 필터를 사용하는 느낌을 그대로 유지한다. 이 스타일을 사용하려면 스트림 이름을 설정한 뒤에 `definition` 메소드를 사용해라. 
  
  ```java
  Stream.builder(dataFlowOperations).name("ticktock")
    .definition(/* 스트림 정의 자리 */)
  ```
  
- `fluent` 스타일에선 `StreamApplication` 인스턴스를 전달해서 소스, 프로세서, 싱크를 함께 연결할 수 있다. 이 스타일을 사용하려면 스트림 이름을 설정한 뒤에 `source` 메소드를 사용해라. 그런 다음 `processor()`와 `sink()` 메소드를 체이닝해 스트림 정의를 만들면 된다.
  
  ```java
    Stream.builder(dataFlowOperations).name("ticktock")
      .source(/* 스트림 애플리케이션 인스턴스 자리 */)
  ```

두 가지 스타일을 모두 보여주기 위해, 두 방식을 사용해서 간단한 스트림을 만들어보겠다. 전체 샘플은 [Spring Cloud Data Flow 샘플 레포지토리](https://github.com/spring-cloud/spring-cloud-dataflow-samples/tree/master/javadsl)에서 찾을 수 있으므로, 처음 시작할 때 활용해도 좋다.

다음은 definition 방식을 시연하는 예시다:

```java
public void definitionStyle() throws Exception{

  Map<String, String> deploymentProperties = createDeploymentProperties();

  Stream woodchuck = Stream.builder(dataFlowOperations)
          .name("woodchuck")
          .definition("http --server.port=9900 | splitter --expression=payload.split(' ') | log")
          .create()
          .deploy(deploymentProperties);

  waitAndDestroy(woodchuck)
}
```

다음은 fluent 방식을 시연하는 예시다:

```java
private void fluentStyle(DataFlowOperations dataFlowOperations) throws InterruptedException {

  logger.info("Deploying stream.");

  Stream woodchuck = builder
    .name("woodchuck")
    .source(source)
    .processor(processor)
    .sink(sink)
    .create()
    .deploy();

  waitAndDestroy(woodchuck);
}
```

`waitAndDestroy` 메소드에선 `getStatus` 메소드를 사용해 스트림 상태를 폴링한다:

```java
private void waitAndDestroy(Stream stream) throws InterruptedException {

  while(!stream.getStatus().equals("deployed")){
    System.out.println("Wating for deployment of stream.");
    Thread.sleep(5000);
  }

  System.out.println("Letting the stream run for 2 minutes.");
  // Let the stream run for 2 minutes
  Thread.sleep(120000);

  System.out.println("Destroying stream");
  stream.destroy();
}
```

definition 스타일을 사용할 때는 배포 프로퍼티를 쉘에서와 동일한 방식으로 `java.util.Map`에 지정한다. 다음은 `createDeploymentProperties` 메소드를 보여준다:

```java
private Map<String, String> createDeploymentProperties() {
  DeploymentPropertiesBuilder propertiesBuilder = new DeploymentPropertiesBuilder();
  propertiesBuilder.memory("log", 512);
  propertiesBuilder.count("log",2);
  propertiesBuilder.put("app.splitter.producer.partitionKeyExpression", "payload");
  return propertiesBuilder.build();
}
```

여기서는 로그 애플리케이션에 deployer 프로퍼티 `count`를 설정하며, 배포 시점에 애플리케이션 프로퍼티도 재정의하고 있다. Fluent 스타일을 사용할 땐 `addDeploymentProperty` 메소드로 배포 프로퍼티를 추가하며 (ex. `new StreamApplication("log").addDeploymentProperty("count", 2)`), 프로퍼티 앞에 `deployer.<app_name>`를 붙이지 않아도 된다.

> 스트림을 만들고 배포하려면 먼저 해당 앱들이 Data Flow 서버에 등록돼 있는지부터 확인해봐야 한다. 알 수 없는 애플리케이션을 포함하는 스트림을 생성하거나 배포하려고 하면 예외가 발생한다. 애플리케이션을 등록하려면 다음과 같이 `DataFlowTemplate`을 사용하면 된다:
>
> ```java
> dataFlowOperations.appRegistryOperations().importFromResource(
>             "https://dataflow.spring.io/rabbitmq-maven-latest", true);
> ```

스트림 애플리케이션들은 스트림을 생성하는 다른 클래스에 주입되는 애플리케이션 내의 빈일 수도 있다. 스프링 애플리케이션을 구성하는 방법은 여러 가지지만, 한 가지 방법은 `@Configuration` 클래스에서 `StreamBuilder`와 `StreamApplications`를 정의하는 거다:

```java
@Configuration
public class StreamConfiguration {

  @Bean
  public StreamBuilder builder() {
    return Stream.builder(new DataFlowTemplate(URI.create("http://localhost:9393")));
  }

  @Bean
  public StreamApplication httpSource(){
    return new StreamApplication("http");
  }

  @Bean
  public StreamApplication logSink(){
    return new StreamApplication("log");
  }
}
```

그런 다음 다른 클래스에서 이 클래스들을 `@Autowire`한 뒤 스트림을 배포할 수 있다:

```java
@Component
public class MyStreamApps {

  @Autowired
  private StreamBuilder streamBuilder;

  @Autowired
  private StreamApplication httpSource;

  @Autowired
  private StreamApplication logSink;

  public void deploySimpleStream() {
    Stream simpleStream = streamBuilder.name("simpleStream")
                            .source(httpSource)
                            .sink(logSink)
                            .create()
                            .deploy();
  }
}
```

이 스타일에선 여러 스트림에 `StreamApplications`를 공유할 수 있다.

---

## Using the `DeploymentPropertiesBuilder`

선택한 스타일에 관계없이 `deploy(Map<String, String> deploymentProperties)` 메소드를 사용하면 스트림 배포 방식을 커스텀 수 있다. 빌더 스타일을 통해 프로퍼티를 가지고 있는 맵을 더 쉽게 생성할 수도 있고, 일부 프로퍼티에는 스태틱 메소드를 제공하기 때문에 굳이 이런 프로퍼티 이름들을 외우고 있지 않아도 된다. 앞에 있는 `createDeploymentProperties` 예제는 다음과 같이 작성할 수 있다:

```java
private Map<String, String> createDeploymentProperties() {
	return new DeploymentPropertiesBuilder()
		.count("log", 2)
		.memory("log", 512)
		.put("app.splitter.producer.partitionKeyExpression", "payload")
		.build();
}
```

이 유틸리티 클래스는 `Map`을 대신해서 생성해주며, 미리 정의된 프로퍼티들을 쉽게 추가할 수 있는 메소드를 몇 가지 제공한다.

---

## Skipper Deployment Properties

Spring Cloud Data Flow 말고도 타겟 플랫폼과 같은 Skipper 전용 배포 프로퍼티를 전달해야 한다. `SkipperDeploymentPropertiesBuilder`는 `DeploymentPropertiesBuilder`에 있는 모든 프로퍼티를 제공하며, Skipper에 필요한 프로퍼티들을 추가한다. 다음은 `SkipperDeploymentPropertiesBuilder`를 생성하는 예시다:

```java
private Map<String, String> createDeploymentProperties() {
	return new SkipperDeploymentPropertiesBuilder()
		.count("log", 2)
		.memory("log", 512)
		.put("app.splitter.producer.partitionKeyExpression", "payload")
		.platformName("pcf")
		.build();
}
```