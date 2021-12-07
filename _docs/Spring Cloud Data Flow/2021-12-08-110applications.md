---
title: Using Applications with Spring Cloud Data Flow
navTitle: Applications
category: Spring Cloud Data Flow
order: 110
permalink: /Spring%20Cloud%20Data%20Flow/applications/
description: Spring Cloud Data Flow에서 사용하는 애플리케이션들
image: ./../../images/springclouddataflow/logo.png
lastmod: 2021-12-08T01:00:00+09:00
comments: true
originalRefName: 스프링 클라우드 데이터 플로우
originalRefLink: https://dataflow.spring.io/docs/applications/
parent: Using Applications with Spring Cloud Data Flow
parentNavTitle: Applications
isParent: true
parentUrl: /Spring%20Cloud%20Data%20Flow/applications/
priority: 0.3
---

---

Spring Cloud Data Flow에선 [Spring Cloud Stream](https://spring.io/projects/spring-cloud-stream)이나 [Spring Cloud Task](https://spring.io/projects/spring-cloud-task)로 만든 애플리케이션들을 자체적으로 지원하고 있다. Data Flow에서 `http | log`와 같은 스트림을 정의했을 땐, `http`는 **출력** 목적지를 가지고 있는 스트림 소스로 처리한다. 마찬가지로 `log` 싱크는 **입력** 목적지가 설정돼 있을 거다.

이 파이프라인을 Data Flow 없이 실행하려면, 이 애플리케이션들에 직접 [Spring Cloud Stream 바인딩 프로퍼티](https://cloud.spring.io/spring-cloud-static/spring-cloud-stream/3.0.4.RELEASE/reference/html/spring-cloud-stream.html#binding-properties)를 설정해서 다음과 같은 구성을 만들어줘야 한다:

- `http`의 출력은 `log`의 입력과 동일한 목적지를 가지고 있다.
- 애플리케이션들은 동일한 메세지 브로커 커넥션 프로퍼티를 가지고 있다.
- 고유한 컨슈머 그룹을 정의한다.

그러고 나서 이 애플리케이션들을 선택한 플랫폼에 따로따로 배포하면 된다.

Data Flow는 이 모든 것들을 대신 처리해주며, 사실 그 이상을 제공한다.

Data Flow는 태스크 애플리케이션을 실행할 땐 태스크의 실행 상태를 추적할 수 있도록, Spring Cloud Task와 스프링 배치에서 필요한 데이터베이스 스키마를 초기화하고, JDBC 커넥션 프로퍼티들을 제공해준다. Data Flow UI에선 이 정보를 조회할 수 있는 화면도 제공한다.

이후 Data Flow 모델은 불가피하게 표준 컨벤션을 준수하지 않아 수동으로 구성해야 하는 애플리케이션들도 지원할 수 있게 확장됐다. 자세한 내용은 [Application DSL](../feature-guides.stream.stream-application-dsl/) 페이지와 [Polyglot Recipe 페이지](../recipes.polyglot)에서 확인할 수 있다.

---

## Pre-packaged Applications

스프링 팀은 [애플리케이션들을 선별해서 미리 패키징해](../applications.pre-packaged) 제공하고 있기 때문에, 이 애플리케이션들을 이용해 다양한 데이터를 통합하고 파이프라인을 조합해서 프로덕션용 Spring Cloud Data Flow를 개발하고, 학습하고, 실험해볼 수 있다.

---

## Application Registration

Data Flow에서 애플리케이션을 사용하려면 먼저 등록해야 한다. 개별 애플리케이션을 등록하는 방법은 [Data Flow로 스트림 처리하기](../stream-developer-guides.stream-development.stream-processing#application-registration)에서 설명하고 있다. 여기서 말하는 애플리케이션이란, 미리 패키징해 제공하는 애플리케이션<sup>pre-packaged application</sup> 중 하나일 수도 있고, 커스텀한 애플리케이션일 수도 있다.

### Bulk Registration

[pre-packaged applications 페이지](../applications.pre-packaged)에선 미리 패키징해 제공하는 애플리케이션들을 벌크로 등록하는 방법을 다룬다.

자체 애플리케이션을 포함해서 사용할 애플리케이션들만 벌크로 등록하고 싶다면, 다음과 같은 포맷으로 파일을 만들면 된다:

`<type>.<name>=<app-url>`, 여기서 `<type>`은 지원하는 애플리케이션 타입이며 (source, processor, sink, task, app), `<name>`은 등록할 이름, `<app-url>`은 실행할 수 있는 아티팩트의 위치다.

> URL은 아무 표준 URL이나, [Data Flow로 스트림 처리하기](../stream-developer-guides.stream-development.stream-processing#application-registration)에 설명했던 Data Flow `maven://`, `docker://` 형식 중 하나를 사용하면 된다.

성능을 최적화하려면, 노출할 애플리케이션 프로퍼티들의 이름과 설명을 가지고 있는 [애플리케이션 메타데이터](../applications.metadata)를 별도 컴패니언<sup>companion</sup> 아티팩트로 패키징할 수도 있다. 필수는 아니지만, 보통 메타데이터엔 애플리케이션 바이너리보다 먼저 접근하므로, Data Flow를 이용하면서 네트워크 리소스를 좀더 효율적으로 활용할 수 있다. 메타데이터 아티팩트를 사용하기로 했다면, `<type>.<name>.metadata=app-metadata-url`로 등록할 항목을 추가해주면 된다.

다음은 메이븐 아티팩트를 등록할 때 사용하는 벌크 등록 파일의 일부다:

```properties
sink.cassandra=maven://org.springframework.cloud.stream.app:cassandra-sink-rabbit:2.1.2.RELEASE
sink.cassandra.metadata=maven://org.springframework.cloud.stream.app:cassandra-sink-rabbit:jar:metadata:2.1.2.RELEASE
sink.s3=maven://org.springframework.cloud.stream.app:s3-sink-rabbit:2.1.2.RELEASE
sink.s3.metadata=maven://org.springframework.cloud.stream.app:s3-sink-rabbit:jar:metadata:2.1.2.RELEASE
```

애플리케이션들을 벌크로 등록할 땐 Data Flow 쉘을 이용하면 된다:

```bash
dataflow:>app import --uri file://path-to-my-app-registration.properties
```

`--local` 옵션을 전달하면 (디폴트는 `true`), 쉘 프로세스 자체에서 프로퍼티 파일 위치를 리졸브할지를 지정할 수 있다. Data Flow 서버 프로세스에서 리졸브해야 한다면 `--local false`로 명시해라.

> `app register`나 `app import` 명령어에선, 해당 이름, 타입, 버전으로 앱을 이미 등록한 적 있다면, 기본적으로 재정의는 하지 않는다. 기존에 있는 앱 URI나 `metadata-uri` 좌표<sup>coordinates</sup>를 재정의하고 싶다면 `--force` 옵션을 넣어라.
>
> 하지만 주의해야할 점은, 일단 다운받은 애플리케이션은 Data Flow 서버에서 리소스 위치를 기반으로 로컬 캐시에 저장할 수도 있다. 리소스 위치가 바뀌지 않았다면 (실제 리소스 바이트는 다르더라도) 다시 다운로드하지 않는다. 반면 `maven://` 리소스에서 constant 위치를 사용했다면 (`-SNAPSHOT` 버전 사용) 캐시도 우회할 수 있다 .
>
> 한 가지 더 말하자면, 이미 스트림을 배포해서 등록한 앱을 특정 버전으로 사용하고 있다면, 스트림을 다시 배포하기 전까지는 다른 앱을 (강제로) 재등록해도 아무런 효과가 없다.

### [Pre-packaged Applications](../applications.pre-packaged)

> [Pre-packaged Applications](../applications.pre-packaged)
>
> 미리 패키징해 제공하는 스트림 애플리케이션들 (3.x)

### [Pre-packaged Applications 2.x](../applications.pre-packaged2x)

> [Pre-packaged Applications 2.x](../applications.pre-packaged2x)
>
> 미리 패키징해 제공하는 스트림, 태스크 애플리케이션들 (Einstein release)

### [Migration Guide for Pre-packaged Stream Applications](../applications.migration)

> [aggregator-processor Migration](https://dataflow.spring.io/docs/applications/migration/aggregator-processor/)
>
> aggregator-processor 마이그레이션

> [ftp-source Migration](https://dataflow.spring.io/docs/applications/migration/ftp-source/)
>
> ftp-source 마이그레이션

> [header-enricher-processor Migration](https://dataflow.spring.io/docs/applications/migration/header-enricher-processor/)
>
> header-enricher-processor 마이그레이션

> [http-source Migration](https://dataflow.spring.io/docs/applications/migration/http-source/)
>
> http-source 마이그레이션

> [cassandra-sink Migration](https://dataflow.spring.io/docs/applications/migration/cassandra-sink/)
>
> cassandra-sink 마이그레이션

> [image-recognition-processor Migration](https://dataflow.spring.io/docs/applications/migration/image-recognition-processor/)
>
> image-recognition-processor 마이그레이션

> [jdbc-sink Migration](https://dataflow.spring.io/docs/applications/migration/jdbc-sink/)
>
> jdbc-sink 마이그레이션

> [jdbc-source Migration](https://dataflow.spring.io/docs/applications/migration/jdbc-source/)
>
> jdbc-source 마이그레이션

> [jms-source Migration](https://dataflow.spring.io/docs/applications/migration/jms-source/)
>
> jms-source 마이그레이션

> [load-generator-source Migration](https://dataflow.spring.io/docs/applications/migration/load-generator-source/)
>
> load-generator-source 마이그레이션

> [log-sink Migration](https://dataflow.spring.io/docs/applications/migration/log-sink/)
>
> log-sink 마이그레이션

> [mail-source Migration](https://dataflow.spring.io/docs/applications/migration/mail-source/)
>
> mail-source 마이그레이션

> [mongodb-sink Migration](https://dataflow.spring.io/docs/applications/migration/mongodb-sink/)
>
> mongodb-sink 마이그레이션

> [cdc-debezium-source Migration](https://dataflow.spring.io/docs/applications/migration/cdc-debezium-source/)
>
> cdc-debezium-source 마이그레이션

> [mongodb-source Migration](https://dataflow.spring.io/docs/applications/migration/mongodb-source/)
>
> mongodb-source 마이그레이션

> [mqtt-sink Migration](https://dataflow.spring.io/docs/applications/migration/mqtt-sink/)
>
> mqtt-sink 마이그레이션

> [mqtt-source Migration](https://dataflow.spring.io/docs/applications/migration/mqtt-source/)
>
> mqtt-source 마이그레이션

> [object-detection-processor Migration](https://dataflow.spring.io/docs/applications/migration/object-detection-processor/)
>
> object-detection-processor 마이그레이션

> [pgcopy-sink Migration](https://dataflow.spring.io/docs/applications/migration/pgcopy-sink/)
>
> pgcopy-sink 마이그레이션

> [rabbit-sink Migration](https://dataflow.spring.io/docs/applications/migration/rabbit-sink/)
>
> rabbit-sink 마이그레이션

> [rabbit-source Migration](https://dataflow.spring.io/docs/applications/migration/rabbit-source/)
>
> rabbit-source 마이그레이션

> [router-sink Migration](https://dataflow.spring.io/docs/applications/migration/router-sink/)
>
> router-sink 마이그레이션

> [s3-sink Migration](https://dataflow.spring.io/docs/applications/migration/s3-sink/)
>
> s3-sink 마이그레이션

> [s3-source Migration](https://dataflow.spring.io/docs/applications/migration/s3-source/)
>
> s3-source 마이그레이션

> [sftp-sink Migration](https://dataflow.spring.io/docs/applications/migration/sftp-sink/)
>
> sftp-sink 마이그레이션

> [sftp-source Migration](https://dataflow.spring.io/docs/applications/migration/sftp-source/)
>
> sftp-source 마이그레이션

> [splitter-processor Migration](https://dataflow.spring.io/docs/applications/migration/splitter-processor/)
>
> splitter-processor 마이그레이션

> [syslog-source Migration](https://dataflow.spring.io/docs/applications/migration/syslog-source/)
>
> syslog-source 마이그레이션

> [tcp-sink Migration](https://dataflow.spring.io/docs/applications/migration/tcp-sink/)
>
> tcp-sink 마이그레이션

> [tcp-source Migration](https://dataflow.spring.io/docs/applications/migration/tcp-source/)
>
> tcp-source 마이그레이션

> [throughput-sink Migration](https://dataflow.spring.io/docs/applications/migration/throughput-sink/)
>
> throughput-sink 마이그레이션

> [time-source Migration](https://dataflow.spring.io/docs/applications/migration/time-source/)
>
> time-source 마이그레이션

> [file-sink Migration](https://dataflow.spring.io/docs/applications/migration/file-sink/)
>
> file-sink 마이그레이션

> [websocket-sink Migration](https://dataflow.spring.io/docs/applications/migration/websocket-sink/)
>
> websocket-sink 마이그레이션

> [file-source Migration](https://dataflow.spring.io/docs/applications/migration/file-source/)
>
> file-source 마이그레이션

> [filter-processor Migration](https://dataflow.spring.io/docs/applications/migration/filter-processor/)
>
> filter-processor 마이그레이션

> [ftp-sink Migration](https://dataflow.spring.io/docs/applications/migration/ftp-sink/)
>
> ftp-sink 마이그레이션

### [Application Metadata](../applications.metadata)

> [Application Metadata](../applications.metadata)
>
> 애플리케이션 프로퍼티 메타데이터를 생성하고 사용해보기
