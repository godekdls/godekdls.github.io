---
title: Application Metadata
category: Spring Cloud Data Flow
order: 114
permalink: /Spring%20Cloud%20Data%20Flow/applications.metadata/
description: 애플리케이션 프로퍼티 메타데이터를 생성하고 사용해보기
image: ./../../images/springclouddataflow/logo.png
lastmod: 2021-12-08T01:00:00+09:00
comments: true
originalRefName: 스프링 클라우드 데이터 플로우
originalRefLink: https://dataflow.spring.io/docs/applications/application-metadata/
parent: Using Applications with Spring Cloud Data Flow
parentNavTitle: Applications
parentUrl: /Spring%20Cloud%20Data%20Flow/applications/
---
<script>defaultLanguages = ['jib', 'properties']</script>

---

스프링 부트를 사용하면 툴이나 문서를 만들때 이용하는 애플리케이션의 설정 프로퍼티에 관한 메타데이터를 executable jar 안에 번들링할 수 있다. 이 섹션에선 애플리케이션 설정 메타데이터를 컨테이너 이미지의 레이블로 제공하는 방법을 포함해서, Data Flow와 함께 사용할 애플리케이션을 구성하고 빌드하는 방법에 대해 설명한다.

자체 애플리케이션을 만들 때는, `spring-boot-configuration-processor` 라이브러리를 사용하면 `@ConfigurationProperties` 어노테이션을 선언한 클래스로 애플리케이션 [설정 메타데이터](https://docs.spring.io/spring-boot/docs/current/reference/html/appendix-configuration-metadata.html#configuration-metadata)를 쉽게 [생성](https://docs.spring.io/spring-boot/docs/current/reference/html/appendix-configuration-metadata.html#configuration-metadata-annotation-processor)할 수 있다. 이 라이브러리에는 자바 애노테이션 프로세서가 들어있다. 프로젝트를 컴파일하면 이 프로세서를 호출해서 설정 메타데이터 파일을 생성하며, 이 파일은 uber-jar 안에 `META-INF/spring-configuration-metadata.json`으로 저장된다.

<span id="application-metadata"></span>설정 프로세서를 사용하려면 애플리케이션의 `pom.xml`에 아래 의존성을 추가해라:

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-configuration-processor</artifactId>
    <optional>true</optional>
</dependency>
```

### 목차

- [Exposing Application Properties for Data Flow](#exposing-application-properties-for-data-flow)
  + [Data Flow Configuration Metadata](#data-flow-configuration-metadata)
  + [Packaging Configuration Metadata](#packaging-configuration-metadata)
- [Dedicated Metadata Artifacts](#dedicated-metadata-artifacts)
  + [Creating Metadata Artifacts](#creating-metadata-artifacts)
  + [Metadata Jar File](#metadata-jar-file)
  + [Metadata Container Image Label](#metadata-container-image-label)
    * [Properties Maven Plugin](#properties-maven-plugin)
    * [Container Maven Plugin](#container-maven-plugin)
- [Using Application Metadata](#using-application-metadata)
  + [Using Metadata Jar files](#using-metadata-jar-files)
  + [Using Metadata Container Image Labels](#using-metadata-container-image-labels)
    * [Container Registry Support](#container-registry-support)
    * [Customizations](#customizations)
    
---

## Exposing Application Properties for Data Flow

스트림, 태스크 애플리케이션들은 [부트 공통 애플리케이션 프로퍼티](https://docs.spring.io/spring-boot/docs/current/reference/html/appendix-application-properties.html)와 [Data Flow에서 사용하는 공통 프로퍼티](https://docs.spring.io/spring-cloud-dataflow/docs/current/reference/htmlsingle/#spring-cloud-dataflow-global-properties), 그리고 애플리케이션 의존성에 포함된 다른 프로퍼티들도 함께 제공하는 스프링 부트 애플리케이션이다. 일반 애플리케이션에선 이 전체 프로퍼티 셋을 모두 사용할 수 있다. 하지만 이 프로퍼티들을 Data Flow 툴에 전부 적용하기엔 사용성 문제가 있다. 그렇기 때문에 Data Flow UI와 쉘에서 애플리케이션 설정 기능을 제공할 땐, 별도 설정 프로퍼티 메타데이터를 사용해서 가장 관련성이 높은 프로퍼티들만 포함시킨다 (디폴트로). 이 메타데이터를 통해 사용 가능한 프로퍼티들을 나열해주고, 자동 완성을 처리해주고, 앞 단에서 유효성을 검사하는 등 맥락에 따라 프로퍼티 설정을 도와준다.

### Data Flow Configuration Metadata

Data Flow와 가장 관련있는 애플리케이션 프로퍼티들을 정의하려면, 프로젝트 리소스 디렉토리에 `META-INF/dataflow-configuration-metadata.properties`라는 파일을 생성해라. 이 파일엔 아래 프로퍼티 중 최소 하나는 정의해야 한다:

- `@ConfigurationProperties` 클래스들의 풀네임<sup>fully qualified name</sup>을 콤마로 구분해서 가지고 있는 `configuration-properties.classes`.
- 프로퍼티 이름들을 콤마로 구분해서 가지고 있는 `configuration-properties.names`. 프로퍼티 이름은 `server.port`같이 풀네임일 수도 있고, 관련 프로퍼티들을 모두 포함시킬 땐 `spring.jmx`같은 프리픽스를 사용할 수도 있다.

예제들은 [Spring Cloud Stream applications](https://github.com/spring-cloud/stream-applications) Git 레포지토리에서 많이 찾을 수 있다. 예를 들어 jdbc 싱크의 [dataflow-configuration-metadata.properties](https://github.com/spring-cloud/stream-applications/blob/master/applications/sink/jdbc-sink/src/main/resources/META-INF/dataflow-configuration-metadata.properties) 파일에는 다음과 같은 설정이 들어있다:

```properties
configuration-properties.classes=org.springframework.cloud.fn.consumer.jdbc.JdbcConsumerProperties
configuration-properties.names=\
spring.datasource.url,\
spring.datasource.driver-class-name,\
spring.datasource.username,\
spring.datasource.password,\
spring.datasource.schema,\
spring.datasource.data,\
spring.datasource.initialization-mode
```

여기서는 싱크에서 사용하는 전용 `@ConfigurationProperties`와 함께, JDBC 데이터소스 구성에 필요한 몇 가지 표준 `spring.datasource` 설정 프로퍼티를 노출하고 있다.

### Packaging Configuration Metadata

설정 프로퍼티를 executable jar나 컨테이너 이미지로 패키징하는 일반적인 절차는 다음과 같다:

1. [위](#application-metadata)에서 설명했던 대로 pom.xml에 부트의 설정 프로세서를 추가한다.
2. [위](#data-flow-configuration-metadata)에서 설명한 방법대로 노출하고 싶은 프로퍼티들을 지정한다.
3. 필요하다면 [여기](#creating-metadata-artifacts)에서 설명하는 방법대로 `spring-cloud-app-starter-metadata-maven-plugin`을 설정한다.

애플리케이션 메타데이터를 사용해 컨테이너 이미지에 레이블을 생성할 때는 별도로 다음과 같은 절차를 거친다:

1. [여기](#properties-maven-plugin)에서 설명하는 방법대로 `properties-maven-plugin`을 설정하고 `META-INF/spring-configuration-metadata-encoded.properties`를 메이븐 프로퍼티로 로드한다. 이 단계에서 `org.springframework.cloud.dataflow.spring.configuration.metadata.json` 프로퍼티가 로드될 거다.
2. 필요하다면 [여기](#container-maven-plugin)에서 설명하는 대로 `jib-maven-plugin`(또는 `docker-maven-plugin`) 설정을 확장한다.

---

## Dedicated Metadata Artifacts

uber jar 안에 애플리케이션 메타데이터를 포함시키게 되면, 단순한 메타데이터 점검을 위해 매우 큰 uber jar를 다운받을 수도 있다. 이때 메타데이터가 필요한 Data Flow 작업을 호출하면 눈에 띄게 지연이 발생하기도 한다. 애플리케이션 메타데이터만 가지고 있는 jar를 별도로 생성하면 다음과 같은 면에서 더 좋다:

- 실제 애플리케이션은 메가바이트 단위지만, 메타데이터 아티팩트는 보통 몇 킬로바이트밖에 안 된다. 결과적으로 더 빠르게 다운받을 수 있기 때문에, Data Flow의 UI와 쉘의 응답 시간이 더 빨라진다.
- 보통 로컬 디스크 사이즈를 제한하는 클라우드 파운드리같이 리소스가 제한된 환경이라면, 사이즈가 더 작은게 훨씬 좋다.

> 컨테이너 이미지를 사용하는 환경에선 (ex. 쿠버네티스), Data Flow는 이미지를 다운받을 필요 없이, 설정한 컨테이너 레지스트리에 REST API를 통해 접근해서 메타데이터를 질의한다. 메타데이터 전용 jar도 생성하기로 했다면, Data Flow에서도 이 jar를 사용할 거다.

### Creating Metadata Artifacts

`spring-cloud-app-starter-metadata-maven-plugin`을 사용하면 애플리케이션에 필요한 모든 메타데이터 파일을 쉽게 준비할 수 있다. 메타데이터는 런타임 환경에 따라 별도 컴패니언<sup>companion</sup> 아티팩트 jar나, 애플리케이션의 컨테이너 이미지 내부에 설정 레이블로 패키징된다. 이 플러그인을 사용하려면 `pom.xml`에 아래 설정을 추가해라:

```xml
<plugin>
   <groupId>org.springframework.cloud</groupId>
   <artifactId>spring-cloud-dataflow-apps-metadata-plugin</artifactId>
   <version>1.0.2</version>
   <configuration>
      <storeFilteredMetadata>true</storeFilteredMetadata>
   </configuration>
   <executions>
      <execution>
         <id>aggregate-metadata</id>
         <phase>compile</phase>
         <goals>
            <goal>aggregate-metadata</goal>
         </goals>
      </execution>
   </executions>
</plugin>
```

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
<p>이 플러그인은 반드시 <code class="highlighter-rouge">spring-configuration-metadata.json</code> 파일을 생성하는 <code class="highlighter-rouge">spring-boot-configuration-processor</code>와 함께 사용해야 한다. 둘 모두 설정했는지 다시 한 번 확인해봐라.</p>
</blockquote>

> **참고**: 애플리케이션을 적절하게 설정해주면, 스프링 부트 (*웬만하면 2.4.1+ 버전 권장*) 메이븐 플러그인 [build-image](https://docs.spring.io/spring-boot/docs/current/maven-plugin/reference/htmlsingle/#build-image) goal에서 사용하는 스프링 부트 전용 Cloud Native [빌드팩](https://github.com/paketo-buildpacks/spring-boot/blob/main/README.md)이 이 메타데이터를 자동으로 설정해준다.

### Metadata Jar File

이 플러그인은 uber-jar로 패키징하는 애플리케이션일 때는 메타데이터가 들어있는 컴패니언<sup>companion</sup> 아티팩트를 생성한다. 구체적으로 말하면, 설정 프로퍼티 메타데이터를 가지고 있는 스프링 부트 JSON 파일과, 앞 섹션에서 설명했던 dataflow 설정 메타데이터 파일이 들어 있다. 아래 예시는 기본 log 싱크의 아티팩트 jar에 들어있는 파일들을 보여준다:

```shell
$ jar tvf log-sink-rabbit-3.0.0.BUILD-SNAPSHOT-metadata.jar
373848 META-INF/spring-configuration-metadata.json
   174 META-INF/dataflow-configuration-metadata.properties
```

> `spring-cloud-app-starter-metadata-maven-plugin`은 바로 사용할 수 있는 애플리케이션 `metadata.jar` 아티팩트를 생성해준다. 애플리케이션의 pom.xml에 이 플러그인을 반드시 설정해야 한다.

### Metadata Container Image Label

`spring-cloud-app-starter-metadata-maven-plugin`은 컨테이너 이미지로 패키징하는 애플리케이션일 때는, `spring-configuration-metadata.json` 파일의 내용과 Data Flow에 노출해준 프로퍼티들을 함께 컨테이너 이미지 안에 레이블로 복사한다. 설정 레이블의 키는 `org.springframework.cloud.dataflow.spring.configuration.metadata.json`을 사용한다. 컨테이너 이미지에 모든 설정 메타데이터가 포함돼 있으므로, 컴패니언<sup>companion</sup> 아티팩트는 따로 필요하지 않다.

이 플러그인은 컴파일 타임에 `org.springframework.cloud.dataflow.spring.configuration.metadata.json`이라는 프로퍼티를 딱 하나 가지고 있는 `META-INF/spring-configuration-metadata-encoded.properties` 파일을 생성한다. 프로퍼티 값에는 노출해준 설정 메타데이터 셋을 문자열로 담고있다. 다음은 전형적인 메타데이터 JSON 파일 예시다:

```properties
org.springframework.cloud.dataflow.spring.configuration.metadata.json={\n  \"groups\": [{\n    \"name\": \"log\",\n    \"type\": \"org.springframework.cloud.stream.app.log.sink.LogSinkProperties\",\n    \"sourceType\": \"org.springframework.cloud.stream.app.log.sink.LogSinkProperties\"\n  }],\n  \"properties\": [\n    {\n      \"name\": \"log.expression\",\n      \"type\": \"java.lang.String\",\n      \"description\": \"A SpEL expression (against the incoming message) to evaluate as the logged message.\",\n      \"sourceType\": \"org.springframework.cloud.stream.app.log.sink.LogSinkProperties\",\n      \"defaultValue\": \"payload\"\n    },\n    {\n      \"name\": \"log.level\",\n      \"type\": \"org.springframework.integration.handler.LoggingHandler$Level\",\n      \"description\": \"The level at which to log messages.\",\n      \"sourceType\": \"org.springframework.cloud.stream.app.log.sink.LogSinkProperties\"\n    },\n    {\n      \"name\": \"log.name\",\n      \"type\": \"java.lang.String\",\n      \"description\": \"The name of the logger to use.\",\n      \"sourceType\": \"org.springframework.cloud.stream.app.log.sink.LogSinkProperties\"\n    }\n  ],\n  \"hints\": []\n}
```

#### Properties Maven Plugin

이 프로퍼티를 도커 레이블로 바꾸려면, 먼저 `properties-maven-plugin`을 사용해서 메이븐 프로퍼티로 로드해야 한다:

```xml
<plugin>
    <groupId>org.codehaus.mojo</groupId>
    <artifactId>properties-maven-plugin</artifactId>
    <version>1.0.0</version>
    <executions>
        <execution>
            <phase>process-classes</phase>
            <goals>
                <goal>read-project-properties</goal>
            </goals>
            <configuration>
                <files>
                    <file>${project.build.outputDirectory}/META-INF/spring-configuration-metadata-encoded.properties</file>
                </files>
            </configuration>
        </execution>
    </executions>
</plugin>
```

#### Container Maven Plugin

`fabric8:docker-maven-plugin`이나 `jib` 메이븐 플러그인을 사용해서 `org.springframework.cloud.dataflow.spring.configuration.metadata.json` 프로퍼티를 도커 레이블에 같은 이름으로 삽입해라:

<div class="switch-language-wrapper jib fabric8">
<span class="switch-language jib">Jib Maven plugin</span>
<span class="switch-language fabric8">Fabric8 Maven plugin</span>
</div>
<div class="language-only-for-jib jib fabric8"></div>
```xml
<plugin>
    <groupId>com.google.cloud.tools</groupId>
    <artifactId>jib-maven-plugin</artifactId>
    <version>2.0.0</version>
    <configuration>
        <from>
            <image>springcloud/openjdk</image>
        </from>
        <to>
            <image>springcloudstream/${project.artifactId}</image>
            <tags>
                <tag>3.0.0.BUILD-SNAPSHOT</tag>
            </tags>
        </to>
        <container>
            <creationTime>USE_CURRENT_TIMESTAMP</creationTime>
            <format>Docker</format>
            <labels>
                <org.springframework.cloud.dataflow.spring-configuration-metadata.json>
                    ${org.springframework.cloud.dataflow.spring.configuration.metadata.json}
                </org.springframework.cloud.dataflow.spring-configuration-metadata.json>
            </labels>
        </container>
    </configuration>
</plugin>
```
<div class="language-only-for-fabric8 jib fabric8"></div>
<div style="border: 1px solid #ddd; padding: 15px; margin-bottom: 20px; background-color: #f9f9f9;">
<p>주의: <code class="highlighter-rouge">docker-maven-plugin</code> 버전은 최소 <code class="highlighter-rouge">0.33.0</code> 이상이 필요하다!</p>
<div class="language-xml highlighter-rouge"><div class="highlight"><pre class="highlight"><code><span class="nt">&lt;plugin&gt;</span>
    <span class="nt">&lt;groupId&gt;</span>io.fabric8<span class="nt">&lt;/groupId&gt;</span>
    <span class="nt">&lt;artifactId&gt;</span>docker-maven-plugin<span class="nt">&lt;/artifactId&gt;</span>
    <span class="nt">&lt;version&gt;</span>0.33.0<span class="nt">&lt;/version&gt;</span>
    <span class="nt">&lt;configuration&gt;</span>
        <span class="nt">&lt;images&gt;</span>
            <span class="nt">&lt;image&gt;</span>
                <span class="nt">&lt;name&gt;</span>springcloudstream/${project.artifactId}:2.1.3.BUILD-SNAPSHOT<span class="nt">&lt;/name&gt;</span>
                <span class="nt">&lt;build&gt;</span>
                    <span class="nt">&lt;from&gt;</span>springcloud/openjdk<span class="nt">&lt;/from&gt;</span>
                    <span class="nt">&lt;volumes&gt;</span>
                        <span class="nt">&lt;volume&gt;</span>/tmp<span class="nt">&lt;/volume&gt;</span>
                    <span class="nt">&lt;/volumes&gt;</span>
                    <span class="nt">&lt;labels&gt;</span>
                        <span class="nt">&lt;org.springframework.cloud.dataflow.spring-configuration-metadata.json&gt;</span>
                          ${org.springframework.cloud.dataflow.spring.configuration.metadata.json}
                        <span class="nt">&lt;/org.springframework.cloud.dataflow.spring-configuration-metadata.json&gt;</span>
                    <span class="nt">&lt;/labels&gt;</span>
                    <span class="nt">&lt;entryPoint&gt;</span>
                        <span class="nt">&lt;exec&gt;</span>
                            <span class="nt">&lt;arg&gt;</span>java<span class="nt">&lt;/arg&gt;</span>
                            <span class="nt">&lt;arg&gt;</span>-jar<span class="nt">&lt;/arg&gt;</span>
                            <span class="nt">&lt;arg&gt;</span>/maven/log-sink-kafka.jar<span class="nt">&lt;/arg&gt;</span>
                        <span class="nt">&lt;/exec&gt;</span>
                    <span class="nt">&lt;/entryPoint&gt;</span>
                    <span class="nt">&lt;assembly&gt;</span>
                        <span class="nt">&lt;descriptor&gt;</span>assembly.xml<span class="nt">&lt;/descriptor&gt;</span>
                    <span class="nt">&lt;/assembly&gt;</span>
                <span class="nt">&lt;/build&gt;</span>
            <span class="nt">&lt;/image&gt;</span>
        <span class="nt">&lt;/images&gt;</span>
    <span class="nt">&lt;/configuration&gt;</span>
<span class="nt">&lt;/plugin&gt;</span>
</code></pre></div></div>
</div>


---

## Using Application Metadata

애플리케이션 설정 메타데이터를 만들었다면 (별도 컴패니언<sup>companion</sup> 아티팩트 혹은 애플리케이션 컨테이너 이미지에 설정 레이블로 임베딩), 몇 가지 설정을 추가해서 Data Flow가 메타데이터를 찾을 수 있는 위치를 알려줘야 할 수 있다.

### Using Metadata Jar files

`app register` 명령어로 단일 앱을 등록할 때는, 다음과 같이 쉘의 `--metadata-uri` 옵션을 사용하면 된다:

```shell
dataflow:>app register --name log --type sink
    --uri maven://org.springframework.cloud.stream.app:log-sink:2.1.0.RELEASE
    --metadata-uri maven://org.springframework.cloud.stream.app:log-sink:jar:metadata:2.1.0.RELEASE
```

`app import` 명령어로 파일을 등록할 때는, 파일에 `<type>.<name>` 라인마다 별도로 `<type>.<name>.metadata` 라인도 적어줘야 한다. 엄밀히 말하면 선택 사항이긴 하지만 (메타데이터를 선언한 앱과 선언하지 않은 앱이 같이 있어도 잘 동작한다), 베스트 프랙티스는 모두 선언해주는 거다.

다음은 메타데이터 아티팩트를 메이븐 레포지토리로 호스팅하는 uber jar 앱의 예시다 (`http://`나 `file://`을 통해 가져올 때도 똑같이 작성해주면 된다).

```properties
source.http=maven://org.springframework.cloud.stream.app:log-sink:2.1.0.RELEASE
source.http.metadata=maven://org.springframework.cloud.stream.app:log-sink:jar:metadata:2.1.0.RELEASE
```

### Using Metadata Container Image Labels

`app register` 명령어로 단일 도커 앱을 등록할 때는, Data Flow 서버가 자동으로 설정 레이블 `org.springframework.cloud.dataflow.spring-configuration-metadata.json`에서 메타데이터를 확인한다:

```shell
dataflow:>app register --name log --type sink --uri container:springcloudstream/log-sink-rabbit:2.1.13.RELEASE
```

필요한 설정은 사용하는 컨테이너 레지스트리 provider나 인스턴스에 따라 다르다.

시크릿을 볼륨으로 마운트해서 쓰는 [private 컨테이너 레지스트리](../installation.kubernetes.helm#private-docker-registry)에선, 이 시크릿을 통해 레지스트리 설정을 자동으로 유추한다. `spring.cloud.dataflow.container.registry-configurations` 하위 프로퍼티로는 다음과 같이 다양한 컨테이너 레지스트리 설정을 명시할 수 있다:

#### Container Registry Support

기본적으로 [Harbor](https://goharbor.io/), [Arifactory/JFrog](https://jfrog.com/integration/docker-registry), [Amazon ECR](https://aws.amazon.com/ecr/), [Azure Container Registry](https://azure.microsoft.com/en-us/services/container-registry)와 같은 다양한 온클라우드<sup>on-cloud</sup> 및 온프레미스<sup>on-premise</sup> 컨테이너 레지스트리에 연결할 수 있으며, [자체 private 레지스트리를 호스팅할 수도 있다](https://docs.docker.com/registry/deploying/).

레지스트리마다 인증 스키마가 다를 수 있으므로, 이어지는 섹션에선 레지스트리별로 필요한 세부 설정 정보를 설명한다:

- [Docker Hub](https://hub.docker.com/) - public 도커허브 레지스트리

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">Java properties</span>
<span class="switch-language yaml">Yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
- spring.cloud.dataflow.container.registry-configurations[default].registry-host=registry-1.docker.io
- spring.cloud.dataflow.container.registry-configurations[default].authorization-type=dockeroauth2
- spring.cloud.dataflow.container.registry-configurations[default].extra[registryAuthUri]=https://auth.docker.io/token?service=registry.docker.io&scope=repository:{repository}:pull&offline_token=1&client_id=shell
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  cloud:
    dataflow:
      container:
        registry-configurations:
          default:
            registry-host: registry-1.docker.io
            authorization-type: dockeroauth2
            extra:
              'registryAuthUri': 'https://auth.docker.io/token?service=registry.docker.io&scope=repository:{repository}:pull&offline_token=1&client_id=shell'
```

이미지 이름에 레지스트리 호스트 프리픽스를 제공하지 않으면 이 레지스트리를 디폴트로 사용한다. public 도커허브 레포지토리에선 username과 password 인증이 필요하지 않지만, private 도커허브 레포지토리에는 credential이 필요하다.

- [Harbor Registry](https://goharbor.io/)

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">Java properties</span>
<span class="switch-language yaml">Yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
- spring.cloud.dataflow.container.registry-configurations[harbor].registry-host=demo.goharbor.io
- spring.cloud.dataflow.container.registry-configurations[harbor].authorization-type=dockeroauth2
- spring.cloud.dataflow.container.registry-configurations[harbor].user=admin
- spring.cloud.dataflow.container.registry-configurations[harbor].secret=Harbor12345
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  cloud:
    dataflow:
      container:
        registry-configurations:
          harbor:
            registry-host: demo.goharbor.io
            authorization-type: dockeroauth2
            user: admin
            secret: Harbor12345
```

Harbor 레지스트리 설정은 도커허브와 유사하게 OAuth2 토큰 인증을 사용하지만, `registryAuthUri`는 조금 달라진다. `registryAuthUri`는 이후 부트스트랩할 때 자동으로 리졸브되지만, 다음과 같이 재정의해도 된다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">Java properties</span>
<span class="switch-language yaml">Yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
- spring.cloud.dataflow.container.registry-configurations[harbor].extra[registryAuthUri]=https://demo.goharbor.io/service/token?service=harbor-registry&scope=repository:{repository}:pull
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  cloud:
    dataflow:
      container:
        registry-configurations:
          harbor:
            extra:
              'registryAuthUri': https://demo.goharbor.io/service/token?service=harbor-registry&scope=repository:{repository}:pull
```

- [Arifactory/JFrog Container Registry](https://jfrog.com/integration/docker-registry):

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">Java properties</span>
<span class="switch-language yaml">Yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
- spring.cloud.dataflow.container.registry-configurations[myjfrog].registry-host=springsource-docker-private-local.jfrog.io
- spring.cloud.dataflow.container.registry-configurations[myjfrog].authorization-type=basicauth
- spring.cloud.dataflow.container.registry-configurations[myjfrog].user=[artifactory user]
- spring.cloud.dataflow.container.registry-configurations[myjfrog].secret=[artifactory encrypted password]
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  cloud:
    dataflow:
      container:
        registry-configurations:
          myjfrog:
            registry-host: springsource-docker-private-local.jfrog.io
            authorization-type: basicauth
            user: [artifactory user]
            secret: [artifactory encrypted password]
```

참고: JFrog에선 [암호화된 Password](https://www.jfrog.com/confluence/display/JFROG/Centrally+Secure+Passwords)를 생성해야 한다.

- [Amazon Elastic Container Registry (ECR)](https://aws.amazon.com/ecr/):

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">Java properties</span>
<span class="switch-language yaml">Yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
- spring.cloud.dataflow.container.registry-configurations[myecr].registry-host=283191309520.dkr.ecr.us-west-1.amazonaws.com
- spring.cloud.dataflow.container.registry-configurations[myecr].authorization-type=awsecr
- spring.cloud.dataflow.container.registry-configurations[myecr].user=[your AWS accessKey]
- spring.cloud.dataflow.container.registry-configurations[myecr].secret=[your AWS secretKey]
- spring.cloud.dataflow.container.registry-configurations[myecr].extra[region]=us-west-1
- spring.cloud.dataflow.container.registry-configurations[myecr].extra[registryIds]=283191309520
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  cloud:
    dataflow:
      container:
        registry-configurations:
          myecr:
            registry-host: 283191309520.dkr.ecr.us-west-1.amazonaws.com
            authorization-type: awsecr
            user: [your AWS accessKey]
            secret: [your AWS secretKey]
            extra:
              region: us-west-1
              'registryIds': 283191309520
```

credential 외에도, 별도 프로퍼티로 레지스트리의 `region`을 제공해야 한다 (ex. `.extra[region]=us-west-1`). 필요하다면 `.extra[registryIds]` 프로퍼티는 여러 레지스트리 ID를 콤마로 구분해서 설정할 수 있다.

- [Azure Container Registry](https://azure.microsoft.com/en-us/services/container-registry):

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">Java properties</span>
<span class="switch-language yaml">Yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
- spring.cloud.dataflow.container.registry-configurations[myazurecr].registry-host=tzolovazureregistry.azurecr.io
- spring.cloud.dataflow.container.registry-configurations[myazurecr].authorization-type=basicauth
- spring.cloud.dataflow.container.registry-configurations[myazurecr].user=[your Azure registry username]
- spring.cloud.dataflow.container.registry-configurations[myazurecr].secret=[your Azure registry access password]
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  cloud:
    dataflow:
      container:
        registry-configurations:
          myazurecr:
            registry-host: tzolovazureregistry.azurecr.io
            authorization-type: basicauth
            user: [your Azure registry username]
            secret: [your Azure registry access password]
```

#### Customizations

- Overriding/Augmenting [Volume Mounted Secrets](../installation.kubernetes.helm#volume-mounted-secretes)

프로퍼티를 사용해서 레지스트리 시크릿을 통해 가져온 설정을 재정의하거나 보강할 수 있다. 예를 들어, `my-private-registry:5000`에서 실행 중인 레지스트리에 액세스하기 위한 시크릿을 생성해뒀다면, 다음과 같이 이 레지스트리에 대한 SSL 검증을 비활성화할 수 있다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">Java properties</span>
<span class="switch-language yaml">Yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
- spring.cloud.dataflow.container.registry-configurations[myregistry].registry-host=my-private-registry:5000
- spring.cloud.dataflow.container.registry-configurations[myregistry].disableSslVerification=true
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  cloud:
    dataflow:
      container:
        registry-configurations:
          myregistry:
            registry-host: my-private-registry:5000
            disableSslVerification: true
```

자체 서명<sup>self-signed</sup> 인증서로 레지스트리를 테스트할 때 유용할 거다.

- Connect via Http Proxy

미리 프록시를 구성해뒀다면, 일부 레지스트리 설정을 리다이렉트할 수 있다. 예를 들어, `my-proxy.test:8080`에 설정해둔 프록시를 통해 `my-private-registry:5000`에서 실행 중인 레지스트리에 액세스한다면:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">Java properties</span>
<span class="switch-language yaml">Yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
- spring.cloud.dataflow.container.http-proxy.host=my-proxy.test
- spring.cloud.dataflow.container.http-proxy.port=8080
- spring.cloud.dataflow.container.registry-configurations[myregistrywithproxy].registry-host=my-proxy-registry:5000
- spring.cloud.dataflow.container.registry-configurations[myregistrywithproxy].use-http-proxy=true
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  cloud:
    dataflow:
      container:
        httpProxy:
          host: my-proxy.test
          port: 8080
        registry-configurations:
          myregistrywithproxy:
            registry-host: my-proxy-registry:5000
            use-http-proxy: true
```

`spring.cloud.dataflow.container.http-proxy` 프로퍼티를 사용하면 글로벌 Http 프록시를 구성할 수 있으며, 원하는 레지스트리 설정에 `use-http-proxy` 프로퍼티를 지정해서 프록시를 사용하도록 만들 수 있다. 기본적으로는 프록시를 사용하지 않는다.

