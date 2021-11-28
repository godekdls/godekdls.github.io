---
title: Function Composition
navTitle: Composing Functions
category: Spring Cloud Data Flow
order: 61
permalink: /Spring%20Cloud%20Data%20Flow/feature-guides.stream.function-composition/
description: 자바/코틀린 함수로 싱크, 프로세서, 소스를 정의하기하고 결합하기
image: ./../../images/springclouddataflow/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 클라우드 데이터 플로우
originalRefLink: https://dataflow.spring.io/docs/feature-guides/streams/function-composition/
parent: Feature guides
parentUrl: /Spring%20Cloud%20Data%20Flow/feature-guides/
subparent: Stream Feature Guides
subparentNavTitle: Streams
subparentUrl: /Spring%20Cloud%20Data%20Flow/feature-guides.stream/
---

---

Spring Cloud Stream은 Spring Cloud Function의 함수 기반 프로그래밍 모델과 통합할 수 있다. 이 프로그래밍 모델에선 애플리케이션의 비지니스로직을 `java.util.Function`, `java.util.Consumer`, `java.util.Supplier`로 모델링할 수 있으며, 각각은 `Processor`, `Sink`, `Source`의 역할을 표현한다.

[프로그래밍 모델](../stream-developer-guides.programming-models) 가이드에선 `Processor`를 함수형 스타일로 작성하는 방법을 보여주고 있다.

이를 바탕으로 기존 `Source`나 `Sink`의 설정을 가져와 `java.util.Function`을 정의하는 코드를 추가하면 기존 `Source`, `Sink` 애플리케이션을 확장할 수 있다.

아래 스트림을 생각해보자:

```sh
http | transformer --expression=(\"Hello \"+payload.toString().toUpperCase()) | log
```

유스 케이스에 따라, 간단한 페이로드 변환 로직에는 굳이 독립형 애플리케이션이 필요하지 않을 수 있으며, 이 변환 로직을 소스나 싱크에 합치는 게 더 유리할 수도 있다. 예를 들면, 이렇게 조그마한 로직을 위해 애플리케이션을 별도로 배포하고 싶지 않을 수도 있고, 메세징 미들웨어에서 민감 데이터를 전송하는 것을 피하고 싶을 수도 있다.

이럴 때는 `HttpSourceConfiguration`을 가져와 `java.util.Function`을 스프링 빈으로 등록하는 소스 애플리케이션을 새로 하나 만들면 된다. 그러면 기존 소스의 출력 이후에 자동으로 함수를 적용한다. 마찬가지로 `Sink` 인스턴스에선 싱크의 입력 이전에 함수를 적용한다.

게다가 기존 소스나 싱크에는 한 가지 함수만 구성할 수 있는 게 아니라, 여러 가지 함수도 선언적으로 구성할 수 있다.

이 가이드에선 앞에서 정의했던 스트림을 생성한 다음 원래의 transformer expression을 `java.util.Function` 인스턴스 두 개로 캡슐화하는 새로운 `http-transformer` 소스 애플리케이션을 만들어본다. 같은 처리를 위해 스트림을 새로 배포하지만, 이번엔 애플리케이션을 3개가 아닌 2개만 사용한다.

이 가이드에서는 각자 [설치 가이드](../installation)에 설명했던 방법대로 `http`, `transformer`, `log` 애플리케이션을 미리 임포트해서 Spring Cloud Data Flow에 등록했다고 가정한다.

### 목차

- [Using Three Applications](#using-three-applications)
- [Using Two Applications](#using-two-applications)
  + [Building](#building)
  + [Registering the Locally Built Application](#registering-the-locally-built-application)
  + [Registering the Readily Available Application](#registering-the-readily-available-application)
  + [Deploying the Stream](#deploying-the-stream)
  + [Kotlin Support](#kotlin-support)
    * [Building](#building-1)
    * [Registering the Locally Built Application](#registering-the-locally-built-application-1)
    * [Registering the Readily Available Application](#registering-the-locally-built-application-1)
    * [Deploying the Stream](#deploying-the-stream-1)

---

## Using Three Applications

첫 번째 스트림에선 사전에 빌드돼 있는 `http`, `transform`, `log` 애플리케이션을 사용한다.

먼저 아래 스트림을 생성한다:

```sh
stream create hello --definition "http --server.port=9000 | transformer --expression=(\"Hello \"+payload.toString().toUpperCase()) | log"
```

이제 다음과 같이 이 스트림을 배포해보자:

```sh
stream deploy hello
```

이 가이드에선 로컬 설치를 이용했기 때문에, 다음과 같이 localhost 엔드포인트에 데이터를 게시할 수 있다:

```sh
http post --data "friend" --target "http://localhost:9000"
```

`log` 애플리케이션의 로그에 다음과 같은 메세지가 출력되는 걸 볼 수 있다:

```console
[sformer.hello-1] log-sink                                 : Hello FRIEND
```

---

## Using Two Applications

이번에는 이 스트림에 있는 두 애플리케이션(`http | transformer`)의 기능을 하나로 합쳐서 새 소스 애플리케이션을 만들고 등록해본다. 그런 다음 이 스트림을 새로 배포하고 이전 예제와 출력이 똑같은지 검증해본다.

새 소스 애플리케이션 이름은 `http-transformer`로 정한다. 이 애플리케이션에선 `http` 소스 애플리케이션의 설정을 임포트하고 두 가지 `java.util.Function` 인스턴스를 스프링 빈으로 정의한다. 애플리케이션 코드는 다음과 같다:

```java
@SpringBootApplication
@Import(org.springframework.cloud.stream.app.http.source.HttpSourceConfiguration.class)
public class HttpSourceRabbitApplication {

	@Bean
	public Function<String, String> upper() {
		return value -> value.toUpperCase();
	}

	@Bean
	public Function<String, String> concat() {
		return value -> "Hello "+ value;
	}


	public static void main(String[] args) {
		SpringApplication.run(HttpSourceRabbitApplication.class, args);
	}
}
```

Spring Cloud Stream은 `spring.cloud.stream.function.definition`이라는 프로퍼티를 가지고 있다. 이 프로퍼티는 함수 리스트를 파이프나 콤마로 구분해서 받으며, 명시한 순서대로 호출한다.

이 프로퍼티를 설정하면 런타임에 자동으로 functional 빈들을 체이닝한다.

functional composition은 다음과 같은 방식으로 일어난다:

- Spring Cloud Stream 애플리케이션이 `Source` 타입일 땐, composed 함수는 소스 `output` 이후에 적용된다.
- Spring Cloud Stream 애플리케이션이 `Sink` 타입일 땐, composed 함수는 싱크 `input`보다 먼저 적용된다.

`upper` 함수를 적용한 다음에 `concat` 함수를 적용하려면, 프로퍼티를 다음과 같이 설정해야 한다:

```properties
spring.cloud.stream.function.definition=upper|concat
```

> 이 파이프 기호는  Spring Cloud Function에서 같은 JVM에 존재하는 두 개의 함수를 함께 구성할 때 사용한다. 참고로, Spring Cloud Data Flow DSL에선 파이프 기호를 특정 애플리케이션에서 다른 애플리케이션으로 메세징 미들웨어 출력을 연결하는 데 사용한다.

이제 새 소스를 빌드하고, 등록하고, 로컬 머신에 스트림을 배포해보자.

### Building

`http-transformer`를 메이븐 레포지토리와 Dockerhub에서 사용할 수 있게 만들어둔 `maven`, `docker` 리소스 URI로 등록하고 싶다면 이 섹션은 건너뛰어도 좋다.

이 애플리케이션의 소스 코드는 깃허브에서 다운받을 수 있다.

RabbitMQ 바인더를 사용한다면 [http-transformer-with-RabbitMQ-binder](https://github.com/spring-cloud/spring-cloud-dataflow-samples/raw/master/dataflow-website/stream-developer-guides/feature-guides/streams/dist/composed-http-transformer-rabbitmq.zip)를 받으면 된다. 소스 코드를 받아 압축을 푼 다음엔 다음과 같이 메이븐을 사용해 애플리케이션을 빌드하면 된다:

```sh
cd composed-http-transformer-kafka
./mvnw clean install
```

카프카 바인더를 사용한다면 [http-transformer-with-Kafka-binder](https://github.com/spring-cloud/spring-cloud-dataflow-samples/raw/master/dataflow-website/stream-developer-guides/feature-guides/streams/dist/composed-http-transformer-kafka.zip)를 받으면 된다. 소스 코드를 받아 압축을 푼 다음엔 다음과 같이 메이븐을 사용해 애플리케이션을 빌드하면 된다:

```sh
cd composed-http-transformer-rabbitmq
./mvnw clean install
```

### Registering the Locally Built Application

이제 다음과 같이 Data Flow 쉘을 이용해 `http-transformer` 애플리케이션을 등록하면 된다:

```sh
app register --name http-transformer --type source --uri file:///<YOUR-SOURCE-CODE>/target/composed-http-transformer-[kafka/rabbitmq]-0.0.1-SNAPSHOT.jar
```

> `--uri` 옵션의 디렉토리명과 아티팩트 경로는 각자의 시스템에 맞게 바꿔라.

### Registering the Readily Available Application

`Kafka`, `RabbitMQ` 바인더 모두 `http-transformer` 애플리케이션의 메이븐 아티팩트와 도커 아티팩트를 바로 사용할 수 있게 준비돼 있다.

카프카 바인더를 사용하는 메이븐 아티팩트:

```sh
app register --name http-transformer --type source --uri maven://io.spring.dataflow.sample:composed-http-transformer-kafka:0.0.1-SNAPSHOT
```

RabbitMQ 바인더를 사용하는 메이븐 아티팩트:

```sh
app register --name http-transformer --type source --uri maven://io.spring.dataflow.sample:composed-http-transformer-rabbitmq:0.0.1-SNAPSHOT
```

카프카 바인더를 사용하는 도커 아티팩트:

```sh
app register --name http-transformer --type source --uri docker://springcloudstream/composed-http-transformer-kafka:0.0.1-SNAPSHOT
```

RabbitMQ 바인더를 사용하는 도커 아티팩트:

```sh
app register --name http-transformer --type source --uri docker://springcloudstream/composed-http-transformer-rabbitmq:0.0.1-SNAPSHOT
```

### Deploying the Stream

이제 `upper`와 `concat`이라는 이름의 functional 빈을 가지고 있는 `http-transform` 애플리케이션을 사용해서 새 스트림을 배포할 수 있다.

```sh
stream create helloComposed --definition "http-transformer --server.port=9001 | log"
```

이 함수들을 실행할 순서를 정의하려면, `spring.cloud.stream.function.definition` 프로퍼티를 사용해 함수 정의를 만들어줘야 한다. 여기서 함수 정의는 Spring Cloud Function에서 정의하는 functional DSL을 의미한다.

여기서는 다음과 같이 정의할 수있다:

```sh
stream deploy helloComposed --properties "app.http-transformer.spring.cloud.stream.function.definition=upper|concat"
```

위에선 `upper`와 `concat` 함수 빈들을 `http` 소스 애플리케이션으로 구성해서 배포하고 있다.

이제 `http` 애플리케이션에 다음과 같이 페이로드를 전송해보자:

```sh
http post --data "friend" --target "http://localhost:9001"
```

`log` 애플리케이션에선 다음과 같은 메세지가 출력되는 걸 볼 수 있다:

```console
[helloComposed-1] log-sink                                 : Hello FRIEND
```

### Kotlin Support

Spring Cloud Function은 코틀린을 지원한다. 애플리케이션에 코틀린 기반 함수를 빈으로 추가할 수 있으며, 원하는 코틀린 함수 빈을 `Source`나 `Sink` 애플리케이션의 functional compisition에 추가할 수 있다.

동작을 확인해보기 위해 코틀린 함수 빈들을 정의하는 샘플 애플리케이션(`http-transformer-kotlin`)을 또 하나 만들어보자.

코틀린 함수 빈은 `processor`로 설정된다. 여기에선 코틀린 함수 빈은 아래와 같이 정의된 `transform` 함수다:

```kotlin
@Bean
open fun transform(): (String) -> String {
   return { "How are you ".plus(it) }
}
```

이 프로젝트에선 다음과 같이 정의된 `spring-cloud-function-kotlin` 의존성도 추가해서 코틀린 함수를 위한 functional 설정 기능을 적용한다.

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-function-kotlin</artifactId>
    <version>2.0.0.RELEASE</version>
</dependency>
```

#### Building

Spring Cloud Data Flow 서버에 `http-transformer-kotlin`의 `maven` 혹은 `docker` 리소스 URI를 등록하고 싶다면 이 섹션은 건너뛰어도 좋다.

이 애플리케이션의 소스 코드는 깃허브에서 다운받을 수 있다.

RabbitMQ 바인더를 사용한다면 [http-transformer-kotlin-with-RabbitMQ-binder](https://github.com/spring-cloud/spring-cloud-dataflow-samples/raw/master/dataflow-website/stream-developer-guides/feature-guides/streams/dist/composed-http-transformer-kotlin-rabbitmq.zip)를 받으면 된다. 소스 코드를 받아 압축을 푼 다음엔 다음과 같이 메이븐을 사용해 애플리케이션을 빌드하면 된다:

```sh
cd composed-http-transformer-kotlin-kafka
./mvnw clean install
```

카프카 바인더를 사용한다면 [http-transformer-kotlin-with-Kafka-binder](https://github.com/spring-cloud/spring-cloud-dataflow-samples/raw/master/dataflow-website/stream-developer-guides/feature-guides/streams/dist/composed-http-transformer-kotlin-kafka.zip)를 받으면 된다. 소스 코드를 받아 압축을 푼 다음엔 다음과 같이 메이븐을 사용해 애플리케이션을 빌드하면 된다:

```sh
cd composed-http-transformer-kotlin-rabbitmq
./mvnw clean install
```

#### Registering the Locally Built Application

이제 다음과 같이 Data Flow 쉘을 이용해 `http-transformer-kotlin` 애플리케이션을 등록하면 된다:

```sh
app register --name http-transformer-kotlin --type source --uri file:///>YOUR-SOURCE-CODE>/target/composed-http-transformer-kotlin-[kafka/rabbitmq]-0.0.1-SNAPSHOT.jar
```

`--uri` 옵션의 디렉토리명과 아티팩트 경로는 각자의 시스템에 맞는 값으로 바꿔라.

#### Registering the Readily Available Application

`Kafka`, `RabbitMQ` 바인더 모두 `http-transformer` 애플리케이션의 메이븐 아티팩트와 도커 아티팩트를 바로 사용할 수 있게 준비돼 있다.

카프카 바인더를 사용하는 메이븐 아티팩트:

```sh
app register --name http-transformer-kotlin --type source --uri maven://io.spring.dataflow.sample:composed-http-transformer-kotlin-kafka:0.0.1-SNAPSHOT
```

RabbitMQ 바인더를 사용하는 메이븐 아티팩트:

```sh
app register --name http-transformer-kotlin --type source --uri maven://io.spring.dataflow.sample:composed-http-transformer-kotlin-rabbitmq:0.0.1-SNAPSHOT
```

카프카 바인더를 사용하는 도커 아티팩트:

```sh
app register --name http-transformer-kotlin --type source --uri docker://springcloudstream/composed-http-transformer-kotlin-kafka:0.0.1-SNAPSHOT
```

RabbitMQ 바인더를 사용하는 도커 아티팩트:

```sh
app register --name http-transformer-kotlin --type source --uri docker://springcloudstream/composed-http-transformer-kotlin-rabbitmq:0.0.1-SNAPSHOT
```

#### Deploying the Stream

다음 명령어를 실행하면 `http-transformer-kotlin` 애플리케이션을 `Source`로 사용해 스트림을 생성할 수 있다:

```sh
stream create helloComposedKotlin --definition "http-transformer-kotlin --server.port=9002 | log"
```

`http-transformer` 예제에서 했던 것처럼, `spring.cloud.stream.function.definition` 프로퍼티를 사용해 원하는 composed 함수 DSL을 정확히 지정하면 functional composition을 구성할 수 있다. 이번에는 아래 예제처럼 자바 설정에서 등록한 함수 빈과 코틀린 프로세서 설정에 있는 함수 빈을 함께 결합할 수 있다:

```sh
stream deploy helloComposedKotlin --properties "app.http-transformer-kotlin.spring.cloud.stream.function.definition=upper|transform|concat"
```

이때 함수 이름 `transform`은 코틀린 함수 이름에 해당한다.

> **참고:** 코틀린 함수는 내부적으로 `java.util.Function`으로 변환되기 때문에, 코틀린 함수와 자바 함수를 함께 사용할 수 있다.

이제 `http` 애플리케이션에 다음과 같이 페이로드를 전송해보자:

```sh
http post --data "friend" --target "http://localhost:9002"
```

`log` 애플리케이션에선 다음과 같은 메세지가 출력되는 걸 볼 수 있다:

```console
[omposedKotlin-1] log-sink               : Hello How are you FRIEND
```