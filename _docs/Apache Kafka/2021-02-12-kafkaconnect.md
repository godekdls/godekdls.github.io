---
title: Kafka Connect
category: Apache Kafka
order: 16
permalink: /Apache%20Kafka/kafka-connect/
description: 카프카 커넥트 프레임워크 한글 번역. 워커, 싱크/소스 커넥터, 싱크/소스 태스크에 대한 개념을 소개하고 커넥트를 개발하는 방법을 안내합니다.
image: ./../../images/kafka/logo.png
lastmod: 2021-02-14T22:25:00+09:00
comments: true
originalRefName: 아파치 카프카
originalRefLink: https://kafka.apache.org/27/documentation.html#connect
---

### 목차

- [8.1 Overview](#81-overview)
- [8.2 User Guide](#82-user-guide)
  + [Running Kafka Connect](#running-kafka-connect)
  + [Configuring Connectors](#configuring-connectors)
  + [Transformations](#transformations)
    * [Included transformations](#included-transformations)
    * [org.apache.kafka.connect.transforms.InsertField](#orgapachekafkaconnecttransformsinsertfield)
    * [org.apache.kafka.connect.transforms.ReplaceField](#orgapachekafkaconnecttransformsreplacefield)
    * [org.apache.kafka.connect.transforms.MaskField](#orgapachekafkaconnecttransformsmaskfield)
    * [org.apache.kafka.connect.transforms.ValueToKey](#orgapachekafkaconnecttransformsvaluetokey)
    * [org.apache.kafka.connect.transforms.HoistField](#orgapachekafkaconnecttransformshoistfield)
    * [org.apache.kafka.connect.transforms.ExtractField](#orgapachekafkaconnecttransformsextractfield)
    * [org.apache.kafka.connect.transforms.SetSchemaMetadata](#orgapachekafkaconnecttransformssetschemametadata)
    * [org.apache.kafka.connect.transforms.TimestampRouter](#orgapachekafkaconnecttransformstimestamprouter)
    * [org.apache.kafka.connect.transforms.RegexRouter](#orgapachekafkaconnecttransformsregexrouter)
    * [org.apache.kafka.connect.transforms.Flatten](#orgapachekafkaconnecttransformsflatten)
    * [org.apache.kafka.connect.transforms.Cast](#orgapachekafkaconnecttransformscast)
    * [org.apache.kafka.connect.transforms.TimestampConverter](#orgapachekafkaconnecttransformstimestampconverter)
    * [org.apache.kafka.connect.transforms.Filter](#orgapachekafkaconnecttransformsfilter)
    * [Predicates](#predicates)
    * [org.apache.kafka.connect.transforms.predicates.HasHeaderKey](#orgapachekafkaconnecttransformspredicateshasheaderkey)
    * [org.apache.kafka.connect.transforms.predicates.RecordIsTombstone](#orgapachekafkaconnecttransformspredicatesrecordistombstone)
    * [org.apache.kafka.connect.transforms.predicates.TopicNameMatches](#orgapachekafkaconnecttransformspredicatestopicnamematches)
  + [REST API](#rest-api)
  + [Error Reporting in Connect](#error-reporting-in-connect)
- [8.3 Connector Development Guide](#83-connector-development-guide)
  + [Core Concepts and APIs](#core-concepts-and-apis)
    * [Connectors and Tasks](#connectors-and-tasks)
    * [Streams and Records](#streams-and-records)
    * [Dynamic Connectors](#dynamic-connectors)
  + [Developing a Simple Connector](#developing-a-simple-connector)
    * [Connector Example](#connector-example)
    * [Task Example - Source Task](#task-example---source-task)
    * [Sink Tasks](#sink-tasks)
    * [Errant Record Reporter](#errant-record-reporter)
    * [Resuming from Previous Offsets](#resuming-from-previous-offsets)
  + [Dynamic Input/Output Streams](#dynamic-inputoutput-streams)
  + [Connect Configuration Validation](#connect-configuration-validation)
  + [Working with Schemas](#working-with-schemas)
  + [Kafka Connect Administration](#kafka-connect-administration)

---

## 8.1 Overview

카프카 커넥트는 아파치 카프카와 다른 시스템 간에 데이터를 확장 가능하고, 안전한 방법으로 스트리밍하기 위한 도구다. 카프카 커넥트를 사용할 땐, 대규모 데이터 컬렉션을 카프카 안팎으로 이동시키는 *커넥터*를 간단히 정의할 수 있다. 카프카 커넥트는 데이터베이스 전체를 가져오거나, 모든 어플리케이션 서버의 메트릭을 수집해 카프카 토픽으로 보낼 수 있기 때문에, 데이터를 짧은 지연 시간으로 스트림 처리할 수 있다. export job으로는 카프카 토픽의 데이터를 보조 스토리지와 쿼리 시스템이나 오프라인 분석을 위한 배치 시스템으로 전달할 수 있다.

카프카 커넥트의 기능들:

- **카프카 커넥터를 위한 공통 프레임워크** - 카프카 커넥트는 다른 데이터 시스템을 카프카와 통합하는 과정을 표준화해서, 커넥터 개발, 배포, 관리를 단순화해준다.
- **분산 실행 모드와 독립 실행 모드** - 조직 전체를 지원하는 대규모 중앙 관리 서비스로 스케일 업하거나, 개발, 테스트, 소규모 프로덕션 배포로 스케일 다운
- **REST 인터페이스** - 손쉬운 REST API를 통해 카프카 커넥트 클러스터에 커넥터 제출, 관리
- **자동 오프셋 관리** - 카프카 커넥트는 커넥터 정보 약간만으로도 오프셋 커밋 프로세스를 자동으로 관리할 수 있으므로, 커넥터 개발자는 오프셋 커밋과 관련해 에러가 발생하기 쉬운 지점에 대한 걱정 없이 커넥터를 개발할 수 있다.
- **기본으로 지원하는 분산 서비스와 확장성** - 카프카 커넥트는 기존 그룹 관리 프로토콜을 기반으로 동작한다. 워커를 더 추가하면 카프카 커넥트 클러스터를 확장할 수 있다.
- **스트리밍/배치 통합** - 카프카의 기존 기능을 활용하는 카프카 커넥트는 스트리밍, 배치 데이터 시스템을 연결하는 가장 이상적인 솔루션이다.

---

## 8.2 User Guide

[퀵스타트 가이드](https://kafka.apache.org/quickstart)는 독립 실행 버전 카프카 커넥트를 실행하는 방법과 관련한 간단한 예제를 제공한다. 이 섹션에선 카프카 커넥트를 설정하고, 실행하고, 관리하는 방법을 좀 더 자세히 다룬다.

### Running Kafka Connect

현재 카프카 커넥트는 두 가지 실행 모드를 지원한다: 독립 실행 모드(단일 프로세스), 분산 실행 모드.

독립형 모드에선 모든 작업을 단일 프로세스로 수행한다. 이 설정은 세팅하기도, 시작하기도 더 쉬우며, 워커가 하나만 필요할 법한 상황(로그 파일 수집 등)에 유용할 순 있지만, 내결함성같은 일부 카프카 커넥트 기능은 활용할 수 없다. 독립형 프로세스는 다음 명령어로 시작할 수 있다:

```bash
> bin/connect-standalone.sh config/connect-standalone.properties connector1.properties [connector2.properties ...]
```

첫 번째 파라미터는 워커의 설정이다. 여기에는 카프카 커넥션 파라미터, 직렬화 포맷, 오프셋 커밋 주기같은 설정이 담긴다. 이 예제는 기본으로 제공하는 `config/server.properties` 설정으로 실행한 로컬 클러스터에서 잘 작동할 거다. 다른 설정이나 프로덕션 배포와 함께 사용하려면 그에 맞게 바꿔줘야 한다. 모든 워커(독립형, 분산형 모두)에는 몇 가지 설정이 필요하다:

- [`bootstrap.servers`](../kafka-connect-configuration#bootstrapservers) - 카프카로 연결할 커넥션을 부트스트랩할 때 사용할 카프카 서버 리스트
- [`key.converter`](../kafka-connect-configuration#keyconverter) - 카프카 커넥트 포맷과 카프카에 기록한 직렬화된 포맷 간을 변환할 때 사용할 컨버터 클래스. 카프카에서 쓰거나 읽은 메세지 키 포맷은 이 클래스가 제어하며, 컨버터는 커넥터와는 독립적이기 때문에, 사용하는 커넥터와는 무관하게 어떤 직렬화 포맷으로도 작업할 수 있다. 많이 사용하는 포맷으로는 JSON, Avro가 있다.
- [`value.converter`](../kafka-connect-configuration#valueconverter) - 카프카 커넥트 포맷과 카프카에 기록한 직렬화된 포맷 간을 변환할 때 사용할 컨버터 클래스. 카프카에서 쓰거나 읽은 메세지 값 포맷은 이 클래스가 제어하며, 컨버터는 커넥터와는 독립적이기 때문에, 사용하는 커넥터와는 무관하게 어떤 직렬화 포맷으로도 작업할 수 있다. 많이 사용하는 포맷으로는 JSON, Avro가 있다.

독립 실행 모드에서 필요한 중요한 설정 옵션은 다음과 같다:

- `offset.storage.file.filename` - 오프셋 데이터를 저장할 파일

여기서 설정하는 파라미터들은 카프카 커넥트가 프로듀서와 컨슈머를 사용해서 설정, 오프셋, 상태 토픽에 접근하기 위한 파라미터다. 카프카 소스 태스크에서 쓸 프로듀서 설정과, 카프카 싱크 태스크에서 쓸 컨슈머 설정에 같은 파라미터를 사용할 순 있지만, 각각 프리픽스 `producer.`, `consumer.`를 붙여야 한다. 워커 설정을 프리픽스 없이 그대로 상속하는 유일한 카프카 클라이언트 파라미터는 `bootstrap.servers`이다. `bootstrap.servers`는 클러스터 내에서 모든 용도로 자주 사용하기 때문에, 대부분의 케이스엔 이 설정만 상속해도 충분하다. 주의해야 할 예외가 하나 있는데, 보안 클러스터에선 커넥션을 허용하려면 파라미터가 더 있어야 한다. 이런 파라미터들은 관리 액세스용으로 한 번, 카프카 소스용으로 한 번, 카프카 싱크용으로 한 번으로, 워커 설정에 최대 세 번까지 설정해야 한다.

2.3.0부터 커넥터 단위로 클라이언트 설정을 개별적으로 재정의할 수 있다. 카프카 소스엔 `producer.override.`, 카프카 싱크엔 `consumer.override.` 프리픽스를 사용하면 된다. 이렇게 재정의한 설정은 나머지 다른 커넥터 설정 프로퍼티와 함께 추가된다.

남은 파라미터는 커넥터 설정 파일이다. 원하는만큼 추가할 수 있지만, 모두 동일한 프로세스 내에서 (다른 스레드에서) 실행될 거다.

분산 모드는 자동으로 작업을 분산시켜주고, 동적으로 스케일 업(또는 다운)할 수 있으며, 활성 태스크와 설정, 오프셋 커밋 데이터에 내결함성을 제공한다. 실행 방법은 독립 실행 모드와 거의 똑같다:

```
> bin/connect-distributed.sh config/connect-distributed.properties
```

여기서 차이점은, 시작점인 클래스가 다르다는 점과, 카프카 커넥트 프로세스가 설정/오프셋 상태/태스크 상태를 저장할 위치와, 작업을 할당하는 방법을 변경하는 설정 파라미터가 다르다. 분산 모드에선 카프카 커넥트는 오프셋, 설정, 태스크 상태를 카프카 토픽에 저장한다. 이렇게 오프셋, 설정, 상태를 저장할 토픽은 원하는 파티션 수와 replication factor로 직접 생성하는 게 좋다. 카프카 커넥트를 시작할 때 토픽이 아직 생성되지 않았다면, 토픽은 디폴트 파티션 수와 디폴트 replication factor로 자동 생성되며, 이 설정이 카프카 커넥트에 가장 적합한 설정이 아닐 수도 있다.

위에서 언급한 공통 설정 외에도, 특히 다음과 같은 설정 파라미터들도 클러스터를 시작하기 전에 반드시 설정해줘야 한다:

- [`group.id`](../kafka-connect-configuration#groupid) (디폴트 `connect-cluster`) - 커넥트 클러스터 그룹을 구성하는데 사용하는 고유 이름. 단, 컨슈머 그룹 ID와 **충돌하면 안 된다**.
- [`config.storage.topic`](../kafka-connect-configuration#configstoragetopic) (디폴트 `connect-configs`) - 커넥터, 태스크 설정을 저장하는데 사용할 토픽. 이 토픽은 단일 파티션이어야 하며, 복제본이 어느정도 있는, 컴팩트된 토픽이어야 한다. 자동 생성된 토픽은 파티션이 여러 개거나, 컴팩션 대신 삭제시키는 토픽으로 자동 설정될 수 있다. 따라서 적합한 설정을 사용하려면 수동으로 토픽을 생성해야 할 수도 있다.
- [`offset.storage.topic`](../kafka-connect-configuration#offsetstoragetopic) (디폴트 `connect-offsets`) - 오프셋을 저장하는데 사용할 토픽. 이 토픽은 파티션을 많이 나눠야 하며, 복제와 캠팩션을 설정해야 한다.
- [`status.storage.topic`](../kafka-connect-configuration#statusstoragetopic) (디폴트 `connect-status`) - 상태를 저장하는데 사용할 토픽. 이 토픽은 파티션을 많이 나눠도 좋으며, 복제와 컴팩션을 설정해줘야 한다.

분산 모드에선 커넥터 설정을 커맨드라인으로 전달하지 않는다. 커맨드라인 대신 아래에서 설명하는 REST API를 통해 커넥터를 생성, 수정, 제거한다.

### Configuring Connectors

커넥터 설정은 단순한 키-값 매핑이다. 독립 실행 모드에선 커넥터 설정을 프로퍼티 파일로 정의해서, 커맨드라인으로 커넥트 프로세스에 전달한다. 분산 모드에선 JSON 페이로드에 담아 커넥터 생성(또는 수정) 요청을 전달한다.

설정 대부분은 커넥터에 따라 다르기 때문에 여기에서 설명할 순 없다. 하지만 공통 옵션은 몇 가지 있다:

- `name` - 커넥터의 고유한 이름. 같은 이름으로 다시 등록하려고 하면 실패한다.
- `connector.class` - 이 커넥터의 자바 클래스.
- `tasks.max` - 이 커넥터에서 만들어야 하는 최대 태스크 수. 더 이상의 병렬 처리가 힘든 경우엔, 태스크를 더 적게 생성할 수도 있다.
- `key.converter` - (생략 가능) 워커가 설정한 디폴트 키 컨버터를 재정의한다.
- `value.converter` - (생략 가능) 워커가 설정한 디폴트 밸류 컨버터를 재정의한다.

`connector.class` 설정은 여러 가지 포맷을 지원한다: 이 커넥터 클래스의 풀 네임이나, alias를 사용할 수 있다. 커넥터가 org.apache.kafka.connect.file.FileStreamSinkConnector라면, 풀 네임을 그대로 지정해도 되지만, FileStreamSink나 FileStreamSinkConnector를 사용하면 설정을 좀 더 짧게 만들 수 있다.

싱크 커넥터엔 입력 제어를 위한 옵션이 몇 가지 더 있다. 모든 싱크 커넥터는 반드시 다음 중 하나를 설정해야 한다:

- [`topics`](../kafka-connect-configuration#topics) - 이 커넥터의 입력으로 사용할 토픽 리스트. 콤마로 구분한다.
- [`topics.regex`](../kafka-connect-configuration#topicsregex) - 이 커넥터의 입력으로 사용할 토픽의 자바 정규식.

다른 옵션들은 해당 커넥터 문서를 찾아보는 게 좋다.

### Transformations

커넥터에 transformation을 설정하면 한 번에 하나씩 메세지를 간단히 수정할 수 있다. 데이터를 정재하거나 이벤트를 라우팅할 때도 편리하다.

커넥터 설정에 transformation 체인을 지정할 수 있다.

- `transforms` - transformation을 적용할 순서를 지정하는, transformation들의 alias 리스트.
- `transforms.$alias.type` - transformation 클래스의 풀 네임(fully qualified  name).
- `transforms.$alias.$transformationSpecificConfig` - transformation의 설정 프로퍼티들

예시를 위해, 기본 제공하는 파일 소스 커넥터를, 스태틱 필드를 추가하는 transformation과 함께 사용해보자.

이 예제에선 쭉 스키마가 없는 JSON 데이터 포맷을 사용할 거다. 스키마 없는 포맷을 사용하기 위해 `connect-standalone.properties`에서 다음 두 줄을 true에서 false로 변경했다:

```properties
key.converter.schemas.enable
value.converter.schemas.enable
```

파일 소스 커넥터는 각 라인을 문자열로 읽는다. 각 라인을 Map으로 감싸고, 두 번째 필드를 추가해서 이벤트 출처를 식별해보겠다. 이를 위해 두 가지 transformation을 사용한다:

- **HoistField** - 입력 라인을 Map에 넣기 위한 transformation
- **InsertField** - 스태틱 필드를 추가하기 위한 transformation. 이 예시에선 레코드가 파일 커넥터에서 생긴 레코드임을 표기한다.

transformation을 추가한 `connect-file-source.properties` 파일은 다음과 같다:

```properties
name=local-file-source
connector.class=FileStreamSource
tasks.max=1
file=test.txt
topic=connect-test
transforms=MakeMap, InsertSource
transforms.MakeMap.type=org.apache.kafka.connect.transforms.HoistField$Value
transforms.MakeMap.field=line
transforms.InsertSource.type=org.apache.kafka.connect.transforms.InsertField$Value
transforms.InsertSource.static.field=data_source
transforms.InsertSource.static.value=test-file-source
```

`transforms`로 시작하는 라인은 모두 transformation을 위해 추가한 설정이다. 두 가지 transformation을 만든 것을 확인할 수 있다. "InsertSource", "MakeMap"은 transformation 제공을 위해 직접 선택한 alias다. transformation 타입은 아래에서 볼 수 있는, 기본 제공하는 transformation을 기반으로 만든다. 각 transformation은 추가 설정을 가지고 있다. HoistField에는 파일에 있던 기존 문자열을 넣을 맵의 필드명인 "field"라는 설정이 필요하다. InsertField transformation에선 추가할 필드명과 값을 지정할 수 있다.

샘플 파일로 transformation 없이 파일 소스 커넥터를 실행한 다음, `kafka-console-consumer.sh`를 사용해 메세지를 읽은 결과는 다음과 같다:

```bash
"foo"
"bar"
"hello world"
```

이번에는 설정 파일에 transformation을 추가해서 새 파일 커넥터를 만든다. 이번 결과는 다음과 같다:

```bash
{"line":"foo","data_source":"test-file-source"}
{"line":"bar","data_source":"test-file-source"}
{"line":"hello world","data_source":"test-file-source"}
```

우리가 읽은 라인은 이제 JSON 맵에 들어가 있고, 별도 필드 하나가 지정한 스태틱 값으로 추가돼 있는 걸 볼 수 있다. 이건 transformation으로 할 수 있는 한 가지 예시일 뿐이다.

#### Included transformations

카프카 커넥트에는 광범위하게 적용할 수 있는 데이터, 라우팅 transformation이 들어있다:

- InsertField - 스태틱 필드나 레코드 메타데이터를 사용해 필드를 추가한다
- ReplaceField - 필드를 필터링하거나 이름을 변경한다
- MaskField - 필드를 해당 타입에서 유효한 null 값(0, 빈 스트링 등)이나 커스텀 대체값(비어 있지 않은 문자열이나 숫자 값 등)으로 치환한다
- ValueToKey - 레코드 키를, 레코드 값의 일부 필드들로 구성된 새 키로 치환한다
- HoistField - 전체 이벤트를 Struct 또는 Map 내부의 단일 필드로 감싼다
- ExtractField - Struct, Map에서 특정 필드를 추출하고, 결과에 이 필드만 포함시킨다
- SetSchemaMetadata - 스키마 이름이나 버전을 수정한다
- TimestampRouter - 기존 토픽과 타임스탬프를 기반으로 레코드 토픽을 수정한다. 타임스탬프에 따라 다른 테이블이나 인덱스에 기록해야 하는 싱크에서 유용하다
- RegexRouter - 기존 토픽, 대체 문자열, 정규식을 기반으로 레코드 토픽을 수정한다
- Filter - 남은 모든 과정에서 메세지를 제외시킨다. 특정 메세지만 필터링할 수 있도록 [predicate](#predicates)와 함께 사용한다.

각 transformation을 설정하는 방법은 아래에 자세히 정리해뒀다:

#### org.apache.kafka.connect.transforms.InsertField

레코드 메타데이터에 있는 속성이나, 설정한 스태틱 값을 사용해 필드를 삽입한다.

추상 클래스 대신 레코드 키(`org.apache.kafka.connect.transforms.InsertField$Key`), 값(`org.apache.kafka.connect.transforms.InsertField$Value`)을 위한 전용 transformation 타입을 사용해라.

- ##### offset.field

  카프카 오프셋의 필드명 - 싱크 커넥터에만 적용할 수 있다.
  뒤에 `!`를 붙여 필수 필드로 만들거나, `?`를 붙여 옵션 필드(디폴트)로 만들 수 있다.

  |         Type: | string |
  | ------------: | ------ |
  |      Default: | null   |
  | Valid Values: |        |
  |   Importance: | medium |

- ##### partition.field

  카프카 파티션의 필드명. 뒤에 `!`를 붙여 필수 필드로 만들거나, `?`를 붙여 옵션 필드(디폴트)로 만들 수 있다.

  |         Type: | string |
  | ------------: | ------ |
  |      Default: | null   |
  | Valid Values: |        |
  |   Importance: | medium |

- ##### static.field

  스태틱 데이터 필드를 위한 필드명. 뒤에 `!`를 붙여 필수 필드로 만들거나, `?`를 붙여 옵션 필드(디폴트)로 만들 수 있다.

  |         Type: | string |
  | ------------: | ------ |
  |      Default: | null   |
  | Valid Values: |        |
  |   Importance: | medium |

- ##### static.value

  필드명을 설정한 경우에 한한 스태틱 필드 값.

  |         Type: | string |
  | ------------: | ------ |
  |      Default: | null   |
  | Valid Values: |        |
  |   Importance: | medium |

- ##### timestamp.field

  레코드 타임스탬프의 필드명. 뒤에 `!`를 붙여 필수 필드로 만들거나, `?`를 붙여 옵션 필드(디폴트)로 만들 수 있다.

  |         Type: | string |
  | ------------: | ------ |
  |      Default: | null   |
  | Valid Values: |        |
  |   Importance: | medium |

- ##### topic.field

  카프카 토픽의 필드명. 뒤에 `!`를 붙여 필수 필드로 만들거나, `?`를 붙여 옵션 필드(디폴트)로 만들 수 있다.

  |         Type: | string |
  | ------------: | ------ |
  |      Default: | null   |
  | Valid Values: |        |
  |   Importance: | medium |

#### org.apache.kafka.connect.transforms.ReplaceField

필드를 필터링하거나 이름을 변경한다.

추상 클래스 대신 레코드 키(`org.apache.kafka.connect.transforms.ReplaceField$Key`), 값(`org.apache.kafka.connect.transforms.ReplaceField$Value`)을 위한 전용 transformation 타입을 사용해라.

- ##### exclude

  제외할 필드. include 필드보다 우선시한다.

  |         Type: | list   |
  | ------------: | ------ |
  |      Default: | ""     |
  | Valid Values: |        |
  |   Importance: | medium |

- ##### include

  포함시킬 필드. 값을 지정하면 이 필드들만 사용한다.

  |         Type: | list   |
  | ------------: | ------ |
  |      Default: | ""     |
  | Valid Values: |        |
  |   Importance: | medium |

- ##### renames

  변경할 필드명 매핑.

  |         Type: | list                                                  |
  | ------------: | ----------------------------------------------------- |
  |      Default: | ""                                                    |
  | Valid Values: | list of colon-delimited pairs, e.g. `foo:bar,abc:xyz` |
  |   Importance: | medium                                                |

- ##### blacklist

  Deprecated. exclude를 사용해라.

  |         Type: | list |
  | ------------: | ---- |
  |      Default: | null |
  | Valid Values: |      |
  |   Importance: | low  |

- ##### whitelist

  Deprecated. include를 사용해라.

  |         Type: | list |
  | ------------: | ---- |
  |      Default: | null |
  | Valid Values: |      |
  |   Importance: | low  |

#### org.apache.kafka.connect.transforms.MaskField

지정한 필드를 해당 타입에서 유효한 null 값(0, false, 빈 문자열 등)으로 마스킹한다.

숫자, 문자열 필드에선 대체값을 지정할 수도 있으며, 그에 맞는 타입으로 변환된다.

추상 클래스 대신 레코드 키(`org.apache.kafka.connect.transforms.MaskField$Key`), 값(`org.apache.kafka.connect.transforms.MaskField$Value`)을 위한 전용 transformation 타입을 사용해라.

- ##### fields

  마스킹할 필드명.

  |         Type: | list           |
  | ------------: | -------------- |
  |      Default: |                |
  | Valid Values: | non-empty list |
  |   Importance: | high           |

- ##### replacement

  모든 'fields' 값에 적용되는 커스텀 대체값 (숫자나 비어 있지 않은 문자열만 가능하다).

  |         Type: | string           |
  | ------------: | ---------------- |
  |      Default: | null             |
  | Valid Values: | non-empty string |
  |   Importance: | low              |

#### org.apache.kafka.connect.transforms.ValueToKey

레코드 키를, 레코드 값의 일부 필드들로 구성된 새 키로 치환한다.

- ##### fields
  
  레코드 키로 추출할 레코드 값의 필드명.

  |         Type: | list           |
  | ------------: | -------------- |
  |      Default: |                |
  | Valid Values: | non-empty list |
  |   Importance: | high           |

#### org.apache.kafka.connect.transforms.HoistField

지정한 필드명을 사용해서, 스키마가 있으면 Struct로, 스키마가 없으면 Map으로 데이터를 감싼다.

추상 클래스 대신 레코드 키(`org.apache.kafka.connect.transforms.HoistField$Key`), 값(`org.apache.kafka.connect.transforms.HoistField$Value`)을 위한 전용 transformation 타입을 사용해라.

- ##### field

  결과로 만드는 Struct나 Map에 넣을 단일 필드의 필드명.

  |         Type: | string |
  | ------------: | ------ |
  |      Default: |        |
  | Valid Values: |        |
  |   Importance: | medium |

#### org.apache.kafka.connect.transforms.ExtractField

스키마가 있으면 Struct에서, 스키마가 없으면 Map에서 지정한 필드를 추출한다. null 값은 수정하지 않고 그대로 전달한다.

추상 클래스 대신 레코드 키(`org.apache.kafka.connect.transforms.ExtractField$Key`), 값(`org.apache.kafka.connect.transforms.ExtractField$Value`)을 위한 전용 transformation 타입을 사용해라.

- ##### field

  추출할 필드명.

  |         Type: | string |
  | ------------: | ------ |
  |      Default: |        |
  | Valid Values: |        |
  |   Importance: | medium |

#### org.apache.kafka.connect.transforms.SetSchemaMetadata

레코드의 키(`org.apache.kafka.connect.transforms.SetSchemaMetadata$Key`)나 값 (`org.apache.kafka.connect.transforms.SetSchemaMetadata$Value`) 스키마에서 스키마 이름, 버전을 설정한다.

- ##### schema.name

  설정할 스키마 이름.

  |         Type: | string |
  | ------------: | ------ |
  |      Default: | null   |
  | Valid Values: |        |
  |   Importance: | high   |

- ##### schema.version

  설정할 스키마 버전.

  |         Type: | int  |
  | ------------: | ---- |
  |      Default: | null |
  | Valid Values: |      |
  |   Importance: | high |

#### org.apache.kafka.connect.transforms.TimestampRouter

레코드의 토픽 필드를 기존 토픽 값과 레코드 타임스탬프의 함수로 업데이트한다.

토픽 필드는 목적지 시스템에서 토픽에 상응하는 엔티티명(데이터베이스 테이블이나 검색 인덱스 이름)을 결정할 때 자주 사용하기 때문에, 주로 싱크 커넥터에 유용하다.

- ##### timestamp.format

  `java.text.SimpleDateFormat`과 호환되는 타임스탬프의 포맷 스트링.

  |         Type: | string   |
  | ------------: | -------- |
  |      Default: | yyyyMMdd |
  | Valid Values: |          |
  |   Importance: | high     |

- ##### topic.format

  토픽 포맷 스트링. 토픽과 타임스탬프를 위한 플레이스홀더 `${topic}`, `${timestamp}`를 가질 수 있다.

  |         Type: | string                |
  | ------------: | --------------------- |
  |      Default: | ${topic}-${timestamp} |
  | Valid Values: |                       |
  |   Importance: | high                  |

#### org.apache.kafka.connect.transforms.RegexRouter

설정한 정규식과 대체 문자열을 사용해 레코드 토픽을 업데이트한다.

정규식은 내부에서 `java.util.regex.Pattern`으로 컴파일된다. 입력 토픽이 패턴과 매칭되면, 대체 문자열로 `java.util.regex.Matcher#replaceFirst()`를 실행해 새 토픽을 가져온다.

- ##### regex

  매칭에 사용할 정규식.

  |         Type: | string      |
  | ------------: | ----------- |
  |      Default: |             |
  | Valid Values: | valid regex |
  |   Importance: | high        |

- ##### replacement

  대체 문자열.

  |         Type: | string |
  | ------------: | ------ |
  |      Default: |        |
  | Valid Values: |        |
  |   Importance: | high   |

#### org.apache.kafka.connect.transforms.Flatten

중첩된 데이터 구조를 평평하게 만든다. 필드 이름은 각 레벨에 있는 필드명을 구분자 문자로 연결해서 만들며, 구분자는 설정으로 변경할 수 있다. 스키마가 있으면 Struct에, 스키마가 없으면 Map에 적용한다. 디폴트 구분자는 '.'이다.

추상 클래스 대신 레코드 키(`org.apache.kafka.connect.transforms.Flatten$Key`), 값(`org.apache.kafka.connect.transforms.Flatten$Value`)을 위한 전용 transformation 타입을 사용해라.

- ##### delimiter

  출력 레코드의 필드 이름을 생성할때, 입력 레코드의 필드 이름 사이에 넣을 구분자

  |         Type: | string |
  | ------------: | ------ |
  |      Default: | .      |
  | Valid Values: |        |
  |   Importance: | medium |

#### org.apache.kafka.connect.transforms.Cast

필드 혹은 전체 키나 값을 특정 타입으로 캐스팅한다 (ex. 정수 필드를 더 작은 범위로 강제 변환). 단순한 프리미티브 타입만 지원한다 -- integer, float, boolean, string.

추상 클래스 대신 레코드 키(`org.apache.kafka.connect.transforms.Cast$Key`), 값(`org.apache.kafka.connect.transforms.Cast$Value`)을 위한 전용 transformation 타입을 사용해라.

- ##### spec

  field1:type,field2:type 포맷을 사용하는 필드와 캐스팅할 타입 리스트. Map이나 Struct의 필드를 캐스팅한다. 단일 타입만 지정하면, 전체 값을 이 타입으로 캐스팅한다. 유효한 타입은 int8, int16, int32, int64, float32, float64, boolean, string이다.

  |         Type: | list                                                  |
  | ------------: | ----------------------------------------------------- |
  |      Default: |                                                       |
  | Valid Values: | list of colon-delimited pairs, e.g. `foo:bar,abc:xyz` |
  |   Importance: | high                                                  |

#### org.apache.kafka.connect.transforms.TimestampConverter

Unix epoch, 문자열, Connect Date/Timestamp 타입같이 다른 포맷을 사용하는 타임스탬프를 변환한다. 개별 필드나 전체 값에 적용한다.

추상 클래스 대신 레코드 키(`org.apache.kafka.connect.transforms.TimestampConverter$Key`), 값(`org.apache.kafka.connect.transforms.TimestampConverter$Value`)을 위한 전용 transformation 타입을 사용해라.

- ##### target.type

  원하는 타임스탬프 표현: string, unix, Date, Time, Timestamp

  |         Type: | string |
  | ------------: | ------ |
  |      Default: |        |
  | Valid Values: |        |
  |   Importance: | high   |

- ##### field

  타임스탬프를 가진 필드. 전체 값이 타임스탬프면 빈 값

  |         Type: | string |
  | ------------: | ------ |
  |      Default: | ""     |
  | Valid Values: |        |
  |   Importance: | high   |

- ##### format

  SimpleDateFormat과 호환되는 타임스탬프 포맷. type=string인 경우 출력을 만들 때 사용하고, 입력이 문자열일 땐 입력을 파싱하는데 사용한다.

  |         Type: | string |
  | ------------: | ------ |
  |      Default: | ""     |
  | Valid Values: |        |
  |   Importance: | medium |

#### org.apache.kafka.connect.transforms.Filter

모든 레코드를 드랍하고, 체인으로 이어지는 transformation에서 제외시킨다. 조건에 따라 특정 Predicate와 일치하는(또는 일치하지 않는) 레코드를 필터링하기는 식으로 사용한다.

#### Predicates

transformation을 predicate와 함께 사용하면, 어떤 조건을 만족하는 메세지에만 transformation을 적용할 수 있다. 특히 **Filter** transformation과 predicate를 결합하면 특정 메세지만 선별해서 제외시킬 수 있다.

Predicate는 커넥터 설정에 지정한다.

- `predicates` - 일부 transformation에 적용할 predicate들의 alias 셋.
- `predicates.$alias.type` - predicate 클래스의 풀 네임(fully qualified name).
- `predicates.$alias.$predicateSpecificConfig` - predicate의 설정 프로퍼티들.

모든 transformation은 암묵적으로 설정 프로퍼티 `predicate`와 `negate`를 가진다. 특정 predicate를 transformation과 연결하려면, transformation의 `predicate` 설정을 predicate의 alias로 설정하면 된다. predicate 값은 `negate` 설정 프로퍼티를 사용해서 반전시킬 수 있다.

예를 들어, 여러 가지 토픽에 메세지를 생성하는 소스 커넥터를 아래와 같이 구현하고 싶다고 가정해보자:

- 'foo' 토픽에 있는 메세지를 완전히 제외시킨다.
- 토픽 'bar'를 *제외*한 모든 토픽 레코드에, 필드명이 'other_field'인 ExtractField transformation을 적용한다.

이대로 구현하려면 먼저 'foo' 토픽으로 향하는 레코드를 필터링해야 한다. Filter transformation으로 레코드를 남은 프로세스에서 제외시키며, TopicNameMatches predicate를 사용해 특정 정규식과 일치하는 토픽 레코드에만 transformation을 적용할 수 있다. TopicNameMatches의 유일한 설정 프로피터는 토픽명과 매칭하는 자바 정규식 `pattern`이다. 설정은 다음과 같다:

```properties
transforms=Filter
transforms.Filter.type=org.apache.kafka.connect.transforms.Filter
transforms.Filter.predicate=IsFoo

predicates=IsFoo
predicates.IsFoo.type=org.apache.kafka.connect.predicates.TopicNameMatches
predicates.IsFoo.pattern=foo
```

다음으로는, 레코드의 토픽명이 'bar'가 아닐 때만 ExtractField를 적용해야 한다. TopicNameMatches는 이름이 일치하지 *않는* 토픽이 아니라, 일치하는 토픽에 transformation을 적용하기 때문에, TopicNameMatches를 직접 사용할 순 없다. transformation의 암묵적인 `negate` 설정 프로퍼티를 사용하면, predicate와 일치하는 레코드 셋을 반전시킬 수 있다. 이 설정을 앞에 있는 예제에 추가하면 다음과 같이 바뀐다:

```properties
transforms=Filter,Extract
transforms.Filter.type=org.apache.kafka.connect.transforms.Filter
transforms.Filter.predicate=IsFoo

transforms.Extract.type=org.apache.kafka.connect.transforms.ExtractField$Key
transforms.Extract.field=other_field
transforms.Extract.predicate=IsBar
transforms.Extract.negate=true

predicates=IsFoo,IsBar
predicates.IsFoo.type=org.apache.kafka.connect.predicates.TopicNameMatches
predicates.IsFoo.pattern=foo

predicates.IsBar.type=org.apache.kafka.connect.predicates.TopicNameMatches
predicates.IsBar.pattern=bar
```

카프카 커넥트엔 다음과 같은 predicate가 들어있다:

- `TopicNameMatches` - 토픽명이 특정 자바 정규식과 일치하는 레코드를 매칭한다.
- `HasHeaderKey` - 주어진 키를 가진 헤더가 있는 레코드를 매칭한다.
- `RecordIsTombstone` - 톰스톤(tombstone) 레코드, 즉 값이 null인 레코드를 매칭한다.

각 predicate를 설정하는 방법은 아래에 자세히 정리해뒀다:

#### org.apache.kafka.connect.transforms.predicates.HasHeaderKey

레코드에 설정한 이름을 가진 헤더가 하나라도 있으면 true인 predicate.

- ##### name

  헤더명.

  |         Type: | string           |
  | ------------: | ---------------- |
  |      Default: |                  |
  | Valid Values: | non-empty string |
  |   Importance: | medium           |

#### org.apache.kafka.connect.transforms.predicates.RecordIsTombstone

톰스톤(tombstone) 레코드(값이 null인)에서 true인 predicate.

#### org.apache.kafka.connect.transforms.predicates.TopicNameMatches

설정한 정규식과 일치하는 토픽명을 가진 레코드에서 true인 predicate.

- ##### pattern

  레코드의 토픽명과 매칭할 자바 정규식.

  |         Type: | string                        |
  | ------------: | ----------------------------- |
  |      Default: |                               |
  | Valid Values: | non-empty string, valid regex |
  |   Importance: | medium                        |

### REST API

카프카 커넥트는 서비스로 실행되도록 설계했기 때문에, 커넥터 관리를 위한 REST API를 함께 제공한다. REST API 서버는 설정 옵션 [`listeners`](../kafka-connect-configuration#listeners)로 설정할 수 있다. 이 필드에는 `protocol://host:port,protocol2://host2:port2` 형식의 리스너 리스트를 지정해야 한다. 현재 지원하는 프로토콜은 `http`와 `https`다. 예를 들면:

```properties
listeners=http://localhost:8080,https://localhost:8443
```

[`listeners`](../kafka-connect-configuration#listeners)를 지정하지 않으면 기본적으로 REST 서버는 HTTP 프로토콜을 통해 8083 포트로 실행한다. HTTPS를 사용한다면 SSL 설정도 추가해야 한다. 기본적으로 `ssl.*` 설정을 사용한다. REST API에선 카프카 브로커와 연결할 때와는 다른 설정을 사용해야 한다면 필드 앞에 `listeners.https` 프리픽스를 붙이면 된다. 프리픽스를 사용하는 경우엔, 프리픽스가 붙은 옵션만 사용하며, 기본 `ssl.*` 옵션은 무시한다. REST API에 HTTPS를 설정할 땐 다음과 같은 필드를 사용할 수 있다:

- [`ssl.keystore.location`](../kafka-connect-configuration#sslkeystorelocation)
- [`ssl.keystore.password`](../kafka-connect-configuration#sslkeystorepassword)
- [`ssl.keystore.type`](../kafka-connect-configuration#sslkeystoretype)
- [`ssl.key.password`](../kafka-connect-configuration#sslkeypassword)
- [`ssl.truststore.location`](../kafka-connect-configuration#ssltruststorelocation)
- [`ssl.truststore.password`](../kafka-connect-configuration#ssltruststorepassword)
- [`ssl.truststore.type`](../kafka-connect-configuration#ssltruststoretype)
- [`ssl.enabled.protocols`](../kafka-connect-configuration#sslenabledprotocols)
- [`ssl.provider`](../kafka-connect-configuration#sslprovider)
- [`ssl.protocol`](../kafka-connect-configuration#sslprotocol)
- [`ssl.cipher.suites`](../kafka-connect-configuration#sslciphersuites)
- [`ssl.keymanager.algorithm`](../kafka-connect-configuration#sslkeymanageralgorithm)
- [`ssl.secure.random.implementation`](../kafka-connect-configuration#sslsecurerandomimplementation)
- [`ssl.trustmanager.algorithm`](../kafka-connect-configuration#ssltrustmanageralgorithm)
- [`ssl.endpoint.identification.algorithm`](../kafka-connect-configuration#sslendpointidentificationalgorithm)
- [`ssl.client.auth`](../kafka-connect-configuration#sslclientauth)

REST API는 사용자가 카프카 커넥트를 모니터링/관리하는데만 사용하는 게 아니다. 카프카 커넥트의 클러스터 간 통신에서도 사용한다. 팔로워 노드 REST API에서 받은 요청은 리더 노드 REST API로 전달된다. 내부에서 호스트에 도달할 수 있는 URI가 수신(listen)하는 URI와 다른 경우, 설정 옵션 [`rest.advertised.host.name`](../kafka-connect-configuration#restadvertisedhostname), [`rest.advertised.port`](../kafka-connect-configuration#restadvertisedport), [`rest.advertised.listener`](../kafka-connect-configuration#restadvertisedlistener)를 통해 팔로워 노드가 리더와 연결하는데 사용하는 URI를 변경할 수 있다. HTTP, HTTPS 리스너를 모두 사용할 때는 `rest.advertised.listener` 옵션을 사용해 클러스터 간 통신에 사용할 리스너를 정의할 수도 있다. 노드 간 통신에 HTTPS를 사용한다면, 동일한 `ssl.*`이나 `listeners.https` 옵션을 사용해 HTTPS 클라이언트를 설정한다.

현재 지원하는 REST API 엔드포인트는 다음과 같다:

- `GET /connectors` - 활성 커넥터 리스트를 반환한다
- `POST /connectors` - 새 커넥터를 만든다. 요청 바디는 문자열 `name` 필드와, 커넥터 설정 파라미터가 담긴 객체 `config` 필드를 가진 JSON 객체 여야 한다
- `GET /connectors/{name}` - 특정 커넥터의 정보를 조회한다
- `GET /connectors/{name}/config` - 특정 커넥터의 설정 파라미터를 조회한다
- `PUT /connectors/{name}/config` - 특정 커넥터의 설정 파라미터를 업데이트한다
- `GET /connectors/{name}/status` - 커넥터의 현재 상태 조회한다. 실행 중인지, 실패했는지, 중단됐는지 등에 대한 정보와, 할당된 워커, 실패한 경우 오류 정보, 모든 태스크의 상태를 포함한다
- `GET /connectors/{name}/tasks` - 커넥터에서 현재 실행 중인 태스크 리스트를 조회한다
- `GET /connectors/{name}/tasks/{taskid}/status` - 태스크의 현재 상태를 조회한다. 실행 중인지, 실패했는지, 중단됐는지 등의 정보와, 할당된 워커, 실패한 경우 오류 정보를 포함한다
- `PUT /connectors/{name}/pause` - 커넥터와 커넥터의 태스크를 중단시킨다. 커넥터를 다시 재개할 때까지 메세지 처리를 멈춘다
- `PUT /connectors/{name}/resume` - 중단된 커넥터를 재개한다 (커넥터가 중단되지 않았다면 아무 일도 일어나지 않는다)
- `POST /connectors/{name}/restart` - 커넥트를 다시 시작한다 (보통 실패로 인한 재시작)
- `POST /connectors/{name}/tasks/{taskId}/restart` - 태스크를 개별적으로 재시작한다 (보통 실패로 인한 재시작)
- `DELETE /connectors/{name}` - 커넥터를 삭제한다. 모든 태스크가 멈추고 설정이 삭제된다
- `GET /connectors/{name}/topics` - 커넥터를 생성한 후 또는, 활성 토픽 셋 재설정 요청을 발행한 이후에 특정 커넥터가 사용 중인 토픽 셋을 조회한다
- `PUT /connectors/{name}/topics/reset` - 커넥터의 활성 토픽 셋을 비우는 요청을 전송한다

카프카 커넥트는 커넥터 플러그인 정보를 조회할 수 있는 REST API도 제공한다:

- `GET /connector-plugins` - 카프카 커넥트 클러스터에 설치된 커넥터 플러그인 리스트를 반환한다. 이 API는 요청을 처리하는 워커에 있는 커넥터만 확인한다는 점에 주의해라. 특히 새 커넥터 jar를 추가한다면, 순차 업그레이드 동안엔 조회 결과가 일관성이 없을 수도 있다.
- `PUT /connector-plugins/{connector-type}/config/validate` - 제공한 설정 값을 설정 정의와 비교해 유효성을 검증한다. 이 API는 설정 별로 검증을 수행해서, 유효성 검사 중에 발견한 오류 메세지와 제안하는 값을 반환한다.

다음은 최상위 레벨(루트) 엔드포인트에서 지원하는 REST 요청이다:

- `GET /` - REST 요청을 처리하는 커넥트 워커의 버전(소스 코드의 git 커밋 ID 포함)과 연결된 카프카 클러스터 ID같은, 카프카 커넥트 클러스터의 기본 정보를 반환한다.

### Error Reporting in Connect

카프카 커넥트는 다양한 처리 단계에서 발생하는 오류를 핸들링할 수 있도록 에러 리포팅을 제공한다. 커넥터는 기본적으로 메세지 포맷 변환(conversion)이나 transformation 중에 에러를 만나면 실패한다. 각 커넥터는 설정을 통해 이런 오류를 건너 뛰고, 원하면 각 오류와 실패한 작업의 세부 정보, 문제가 있는 레코드(다양한 수준의 세부 정보 포함)를 커넥트 어플리케이션 로그에 기록하는 식으로 오류를 허용할 수도 있다. 싱크 커넥터에선 카프카 토픽에서 컨슘한 메세지를 처리할 때 발생한 오류를 잡아내서, 모든 오류를 설정 가능한 "dead letter queue(DLQ)" 카프카 토픽에 기록할 수도 있다.

커넥터의 컨버터, transform 오류나, 싱크 커넥터의 자체 오류를 로그에 리포팅하려면, 커넥터 설정에 `errors.log.enable=true`를 설정해서 각 오류와 문제 레코드의 토픽, 파티션, 오프셋의 세부 정보를 기록해라. 추가적인 디버깅이 필요하다면, `errors.log.include.messages=true`를 설정해서 문제 레코드 키, 값, 헤더도 로그에 기록해라 (단, 이렇게하면 민감한 정보를 기록할 수도 있다).

커넥터의 컨버터, transform, 싱크 커넥터 자체 오류를 DLQ 토픽에 리포팅하려면, [`errors.deadletterqueue.topic.name`]을 설정하고, 필요하면 `errors.deadletterqueue.context.headers.enable=true`도 설정할 수 있다.

기본적으로 커넥터는 오류나 예외가 발생하는 즉시 "fail fast"로 동작한다. 커넥터 설정에 다음 설정 프로퍼티를 기본 값으로 추가했을 때와 동일하다:

```properties
# disable retries on failure
errors.retry.timeout=0

# do not log the error and their contexts
errors.log.enable=false

# do not record errors in a dead letter queue topic
errors.deadletterqueue.topic.name=

# Fail on first error
errors.tolerance=none
```

이 설정들과, 관련한 다른 커넥터 설정 프로퍼티를 변경하면 다른 동작을 제공할 수 있다. 예를 들어, 다음 설정 프로퍼티를 커넥터 설정에 추가하면, 에러를 여러 번 재시도하고, 어플리케이션 로그와 카프카 토픽 `my-connector-errors`에 로깅하고, 커넥터 태스크를 실패시키지 않고 리포팅하는 식으로 모든 에러를 허용할 수 있다:

```properties
# retry for at most 10 minutes times waiting up to 30 seconds between consecutive failures
errors.retry.timeout=600000
errors.retry.delay.max.ms=30000

# log error context along with application logs, but do not include configs and messages
errors.log.enable=true
errors.log.include.messages=false

# produce error context into the Kafka topic
errors.deadletterqueue.topic.name=my-connector-errors

# Tolerate all errors.
errors.tolerance=all
```

---

## 8.3 Connector Development Guide

이 가이드에선 카프카와 다른 시스템간에 데이터를 이동시키는 카프카 커넥트의 새 커넥터를 개발하는 방법을 설명한다. 핵심 컨셉 몇 가지를 간단하게 리뷰하고, 간단한 커넥터를 생성하는 방법을 설명한다.

### Core Concepts and APIs

#### Connectors and Tasks

카프카와와 다른 시스템간에 데이터를 복사하려면 사용자는 데이터를 pull해오거나 push하려는 시스템을 위한 `Connector`를 만든다. 커넥터는 두 가지 유형이 있다. `SourceConnectors`는 다른 시스템에서 데이터를 import하고 (예를 들어 `JDBCSourceConnector`는 관계형 데이터베이스를 카프카로 import한다), `SinkConnectors`는 데이터를 export한다 (예를 들어 `HDFSSinkConnector`는 카프카 토픽을 HDFS 파일로 export한다).

`Connectors`는 직접 데이터를 복사하진 않는다. 커넥터 설정으로 복사할 데이터를 정의하고, `Connector`는 해당 job을 워커에 분산할 수 있는 `Tasks` 셋으로 분할한다. 이 `Tasks`도 그에 따라 `SourceTask`와 `SinkTask` 두 가지로 나뉜다.

각 `Task`를 할당받으면 데이터의 하위 집합을 카프카로 복사하거나, 카프카에서 복사해가야 한다. 카프카 커넥트에서는 태스크 할당을 항상 일관된 스키마를 가진 레코드로 구성된 입출력 스트림 셋으로 표현할 수 있어야 한다. 매핑이 분명할 때도 있다. 로그 파일 셋에 있는 각 파일은 각 라인의 스트림이라고 간주할 수 있다. 각 라인을 파싱하면 같은 스키마와, 파일에 바이트 오프셋으로 저장한 오프셋으로 레코드를 구성할 수 있다. 이 모델에 매핑하기 더 까다로운 케이스도 있다. JDBC 커넥터는 각 테이블을 스트림으로 매핑할 수 있지만, 오프셋은 덜 명확하다. 타임스탬프 컬럼을 사용해서 매핑을 정의할 수도 있겠다. 새 데이터를 점진적으로 반환하는 쿼리를 생성하고, 마지막으로 질의한 타임스탬프를 오프셋으로 활용할 수 있다.

#### Streams and Records

각 스트림은 키-값 레코드 시퀀스여야 한다. 키와 값 모두 복잡한 구조를 가질 수 있다. 많은 프리미티브 타입을 제공하지만, 배열, 객체 및 중첩 데이터 구조도 표현할 수 있다. 런타임 데이터 포맷은 특정한 직렬화 포맷을 가정하지 않는다. 포맷 변환은 프레임워크 내부에서 처리한다.

레코드(소스에서 생성한 레코드와 싱크로 전달하는 레코드 모두)는 키/값 말고도, 관련 스트림 ID와 오프셋을 가진다. 프레임워크에서 처리를 마친 데이터의 오프셋을 주기적으로 커밋할 때 이 정보를 사용하기 때문에, 실패 시에 마지막으로 커밋한 오프셋에서부터 처리를 재개해 불필요한 재처리 및 이벤트 중복을 방지할 수 있다.

#### Dynamic Connectors

모든 job이 스태틱하진 않기 때문에, `Connector` 구현체는 외부 시스템에서 재설정이 필요할 수도 있는 변경 사항이 있는지도 모니터링해야 한다. `JDBCSourceConnector`로 예를 들면, `Connector`는 각`Task`에 테이블 셋을 할당할 수 있다. 새 테이블이 만들어지면, 이 테이블을 감지해야지만 설정을 업데이트해서 새 테이블을 `Tasks` 중 하나로 할당할 수 있다. 재설정이 필요한 변경(또는 `Tasks` 수 변경)을 발견하면 프레임워크에 이를 알리며, 프레임워크는 그에 따라 `Tasks`를 업데이트하게 된다.

### Developing a Simple Connector

커넥터를 개발하려면 `Connector`와 `Task`, 이 두 가지 인터페이스만 구현하면 된다. 카프카 소스 코드에 있는 `file` 패키지 안에 간단한 예제가 들어있다. 이 커넥터는 독립 실행 모드에서 실행하기 위한 커넥터이며, 파일의 각 라인을 읽고 레코드로 내보내는 `SourceConnector`/`SourceTask` 구현체와, 각 레코드를 파일에 기록하는 `SinkConnector`/`SinkTask`를 구현해놨다.

이어서 몇 가지 코드를 살펴보며 커넥터를 만드는 주요 단계를 시연해 보겠지만, 세부 정보를 많이 생략해 놓았기 때문에, 직접 개발하려면 전체 예제 소스 코드를 함께 살펴보는 게 좋다.

#### Connector Example

간단한 예시로 `SourceConnector`를 다뤄보겠다. `SinkConnector` 구현체도 거의 비슷하다. `SourceConnector`를 상속한 클래스를 만드는 것으로 시작해, 파싱한 설정 정보(읽어올 파일의 이름과 데이터를 전송할 토픽)를 담을 몇 가지 필드를 추가한다:

```java
public class FileStreamSourceConnector extends SourceConnector {
    private String filename;
    private String topic;
}
```

작성하기 제일 쉬운 메소드는 `taskClass()`다. 이 메소드는 실제로 데이터를 읽기 위해 워커 프로세스에서 인스턴스를 만들어야 하는 클래스를 정의한다:

```java
@Override
public Class<? extends Task> taskClass() {
    return FileStreamSourceTask.class;
}
```

`FileStreamSourceTask` 클래스는 아래에서 정의할 거다. 다음은 표준 라이프사이클 메소드 `start()`, `stop()`을 추가한다:

```java
@Override
public void start(Map<String, String> props) {
    // The complete version includes error handling as well.
    filename = props.get(FILE_CONFIG);
    topic = props.get(TOPIC_CONFIG);
}

@Override
public void stop() {
    // Nothing to do since no background monitoring is required.
}

```

마지막으로, 이 구현체의 실질적인 핵심 코드는 `taskConfigs()`에 있다. 여기선 파일 하나만 처리할 거기 때문에, 엔트리를 하나만 가진 리스트를 반환한다. `maxTasks` 인자에 따라 더 많은 태스크를 허용할 수도 있다:

```java
@Override
public List<Map<String, String>> taskConfigs(int maxTasks) {
    ArrayList<Map<String, String>> configs = new ArrayList<>();
    // Only one input stream makes sense.
    Map<String, String> config = new HashMap<>();
    if (filename != null)
        config.put(FILE_CONFIG, filename);
    config.put(TOPIC_CONFIG, topic);
    configs.add(config);
    return configs;
}
```

이 예제에선 사용하지 않았지만, `SourceTask`는 소스 시스템에서 오프셋을 커밋하는 두 가지 API `commit`, `commitRecord`도 제공한다. 이 API는 메세지에 대한 승인(acknowledgement) 메커니즘이 있는 소스 시스템을 위해 제공하는 API다. 이런 메소드들을 재정의하면, 소스 커넥터에서 카프카에 메세지를 기록하고 나면, 소스 시스템 메세지를 벌크로 또는 개별적으로 승인할 수 있다. `commit` API는 `poll`이 반환한 오프셋까지를 소스 시스템에 저장한다. 이 API 구현부는 커밋을 완료할 때까지 블로킹해야 한다. `commitRecord` API는 카프카에 기록한 후 각 `SourceRecord`에 대한 오프셋을 소스 시스템에 저장한다. 카프카 커넥트는 오프셋을 자동으로 기록하기 때문에 오프셋 커밋을 위한 전용 `SourceTask`는 필요하지 않다. 커넥터가 소스 시스템의 메세지를 승인해야 할 때는 보통 이 API들 중 하나만 사용하면 된다.

태스크가 여러 개라고 해도, 보통은 이 메소드 구현부는 매우 간단하다. 데이터를 가져올 원격 서비스에 연결할 입력 태스크의 수를 결정한 다음, 태스크를 분할하면 된다. 태스크를 분할하는 몇 가지 패턴들은 매우 자주 사용하기 때문에, `ConnectorUtils`에서 단순화를 위한 몇 가지 유틸리티를 제공한다.

이 예시에선 다이나믹 입력은 다루지 않는다. 태스크 설정 업데이트를 트리거하는 방법은 아래 섹션을 참고해라.

#### Task Example - Source Task

이어서 이에 따른 `SourceTask` 구현체를 설명하겠다. 구현 코드는 짧지만, 이 가이드에서 전부 다 다루기엔 길다. 구현체 대부분은 슈도 코드를 사용할 거지만, 전체 예제는 소스 코드를 참고하면 된다.

커넥터와 마찬가지로 적절한 베이스 클래스 `Task`를 상속한 클래스를 만들어야 한다. 역시 마찬가지로 표준 라이프사이클 메소드도 가지고 있다:

```java
public class FileStreamSourceTask extends SourceTask {
    String filename;
    InputStream stream;
    String topic;

    @Override
    public void start(Map<String, String> props) {
        filename = props.get(FileStreamSourceConnector.FILE_CONFIG);
        stream = openOrThrowError(filename);
        topic = props.get(FileStreamSourceConnector.TOPIC_CONFIG);
    }

    @Override
    public synchronized void stop() {
        stream.close();
    }
```

조금 단순화한 버전이긴 하지만, 이 코드를 보면 이 메소드들은 상대적으로 간단하며, 수행해야 하는 유일한 작업은 리소스를 할당/해제하는 일이란 걸 알 수 있다. 이 구현체와 관련해서 주의해야 할 사항 두 가지가 있다. 먼저, 아래 섹션에서 다룰 거지만, `start()` 메소드는 아직 이전 오프셋에서부터 재개하는 동작을 처리하지 않는다. 둘째, `stop()` 메소드는 동기화된다. `SourceTasks`는 전용 스레드를 제공받기 때문에 동기화가 필요할 거다. `SourceTasks`는 무기한으로 블로킹할 수 있기 때문에, 중지할 땐 워커 내 다른 스레드로 호출해야 한다.

다음으로는, 태스크의 주요 기능 `poll()` 메소드를 구현한다. 이 메소드는 입력 시스템에서 이벤트를 가져와 `List<SourceRecord>`를 반환한다:

```java
@Override
public List<SourceRecord> poll() throws InterruptedException {
    try {
        ArrayList<SourceRecord> records = new ArrayList<>();
        while (streamValid(stream) && records.isEmpty()) {
            LineAndOffset line = readToNextLine(stream);
            if (line != null) {
                Map<String, Object> sourcePartition = Collections.singletonMap("filename", filename);
                Map<String, Object> sourceOffset = Collections.singletonMap("position", streamOffset);
                records.add(new SourceRecord(sourcePartition, sourceOffset, topic, Schema.STRING_SCHEMA, line));
            } else {
                Thread.sleep(1);
            }
        }
        return records;
    } catch (IOException e) {
        // Underlying stream was killed, probably as a result of calling stop. Allow to return
        // null, and driving thread will handle any shutdown if necessary.
    }
    return null;
}
```

다시 말하지만 일부 디테일은 생략했다. 그래도 중요한 단계들은 확인할 수 있다: `poll()` 메소드는 반복해서 호출될 거며, 호출할 때마다 파일에서 레코드를 읽는 동작을 반복 처리한다. 읽어온 각 라인에선 파일 오프셋도 추적한다. 이 정보를 사용해, 네 가지 정보로 출력 `SourceRecord`를 생성한다: 소스 파티션(파일을 하나만 읽기 때문에 하나만 있음), 소스 오프셋(파일의 바이트 오프셋), 출력 토픽명, 출력 값(파일의 라인, 그리고 이 값은 항상 문자열임을 나타내는 스키마를 추가한다). `SourceRecord`의 다른 생성자에선 특정 출력 파티션, 키, 헤더도 추가할 수 있다.

이 구현체는 일반 자바 `InputStream` 인터페이스를 사용하며, 데이터를 사용할 수 없다면 일시정지(sleep)될 수도 있다. 카프카 커넥트는 각 태스크별로 전용 스레드를 제공하기 때문에 문제는 없다. 태스크 구현체는 기본 `poll()` 인터페이스를 따라야 하지만, 구현 방법에 있어서는 꽤 유연하다. 이 경우 NIO 기반 구현이 더 효율적일 수 있지만, 이 간단한 접근 방식도 제대로 동작하며, 빠르게 구현할 수 있고, 자바 구버전과도 호환된다.

#### Sink Tasks

앞에선 간단한 `SourceTask`를 구현하는 방법을 설명했다. `SourceConnector`와 `SinkConnector`와는 달리, `SourceTask`와 `SinkTask`는 인터페이스가 매우 다르다. `SourceTask`는 pull 인터페이스를, `SinkTask`는 push 인터페이스를 사용하기 때문이다. 둘 다 공통 라이프사이클 메소드를 가지고 있긴 하지만, `SinkTask` 인터페이스는 앞에서 본 인터페이스와는 꽤 다르게 생겼다:

```java
public abstract class SinkTask implements Task {
    public void initialize(SinkTaskContext context) {
        this.context = context;
    }

    public abstract void put(Collection<SinkRecord> records);

    public void flush(Map<TopicPartition, OffsetAndMetadata> currentOffsets) {
    }
```

`SinkTask` 문서에는 설명이 아주 자세히 나와있지만, 인터페이스는 거의 `SourceTask`만큼이나 간단하다. 구현부 대부분은 `put()` 메소드에 담긴다. 이 메소드는 `SinkRecords` 셋을 받아 필요한 변환을 수행하고 목적지 시스템에 저장한다. 이 메소드에선 반환 전에 데이터가 목적지 시스템에 완전히 기록됐는지 확인할 필요 없다. 사실 많은 경우 레코드 배치 전체를 한 번에 전송하면 이벤트를 다운스트림 데이터 저장소에 삽입하는 오버 헤드를 줄일 수 있어서 내부 버퍼링이 유용할 거다. `SinkRecords`는 본질적으로 `SourceRecords`와 동일한 정보를 가진다: 카프카 토픽, 파티션, 오프셋, 이벤트 키/값, 생략 가능한 헤더.

`flush()` 메소드는 오프셋 커밋 처리 중에 사용하므로, 이벤트가 누락되지 않도록 태스크를 실패 지점부터 복구하고 안전한 지점에서 재개할 수 있다. 이 메소드는 아직 처리되지 않는 데이터를 목적지 시스템으로 push한 다음 쓰기가 승인될 때까지 블로킹해야 한다. `offsets` 파라미터는 무시해도 되지만, 구현체에서 exactly-once delivery 제공을 위해 목적지 저장소에 오프셋 정보를 저장하려는 경우에 유용하다. 예를 들어, HDFS 커넥터는 오프셋 정보를 HDS에 저장하며, `flush()` 작업에서 원자적 이동 연산을 사용해 데이터와 오프셋을 HDFS의 최종 위치에 원자적으로 커밋하도록 만든다.

#### Errant Record Reporter

[에러 리포팅](#error-reporting-in-connect)을 활성화하면 커넥터는 `ErrantRecordReporter`를 사용해 싱크 커넥터로 전송된 개별 레코드의 문제를 보고할 수 있다. 아래 예제는 커넥터의 `SinkTask` 하위 클래스에서 `ErrantRecordReporter` 가져와 사용하는 방법과, DLQ를 활성화하지 않았거나 커넥터가 이 리포터 기능이 없는 구버전 커넥트 런타임에 설치된 경우에 null 리포터를 안전하게 처리하는 방법을 보여준다:

```java
private ErrantRecordReporter reporter;

@Override
public void start(Map<String, String> props) {
    ...
    try {
        reporter = context.errantRecordReporter(); // may be null if DLQ not enabled
    } catch (NoSuchMethodException | NoClassDefFoundError e) {
        // Will occur in Connect runtimes earlier than 2.6
        reporter = null;
    }
}

@Override
public void put(Collection<SinkRecord> records) {
    for (SinkRecord record: records) {
        try {
            // attempt to process and send record to data sink
            process(record);
        } catch(Exception e) {
            if (reporter != null) {
                // Send errant record to error reporter
                reporter.report(record, e);
            } else {
                // There's no error reporter, so fail
                throw new ConnectException("Failed on record", e);
            }
        }
    }
}
```

#### Resuming from Previous Offsets

`SourceTask` 구현체에선 각 레코드에 스트림 ID(입력 파일 이름)과 오프셋(파일 상 위치)을 추가했었다. 프레임워크에선 이 정보를 사용해 오프셋을 주기적으로 커밋하므로, 태스크가 실패했을 때 태스크를 복구하고, 재처리로 중복될 수 있는 이벤트 수를 최소화할 수 있다 (또는 카프카 커넥트가 독립 실행 모드나 job 재설정 등으로 정상적으로 중지된 경우 가장 최근 오프셋부터 재개할 수 있다). 이때 커밋 프로세스는 프레임워크가 완전히 자동화해주지만, 입력 스트림의 올바른 위치로 되돌아가 그 위치부터 재개하는 방법은 커넥터만 알고 있다.

기동했을 때 올바른 위치에서부터 다시 시작하려면, 태스크의 `initialize()` 메소드에 전달된 `SourceContext`를 사용해 오프셋 데이터에 접근하면 된다. `initialize()`에 오프셋(있으면)을 읽고 해당 위치를 찾아가는 코드를 좀 더 추가해보겠다:

```java
stream = new FileInputStream(filename);
Map<String, Object> offset = context.offsetStorageReader().offset(Collections.singletonMap(FILENAME_FIELD, filename));
if (offset != null) {
    Long lastRecordedOffset = (Long) offset.get("position");
    if (lastRecordedOffset != null)
        seekToOffset(stream, lastRecordedOffset);
}
```

물론, 각 입력 스트림마다 키를 대량으로 읽어와야 할 수도 있다. `OffsetStorageReader` 인터페이스를 사용하면 벌크 읽기를 발행해, 모든 오프셋을 효율적으로 로드해서 각 입력 스트림의 적절한 위치를 찾아갈 수도 있다.

### Dynamic Input/Output Streams

카프카 커넥트에서 의도한 바는 데이터베이스에 있는 모든 테이블을 복사하는 개별 job을 잔뜩 만드는 게 아니라, 데이터베이스를 통째로 복사하는 것같이 벌크 데이터를 복사하는 job을 정의하는 거다. 이렇게 설계하게 되면, 커넥터의 입출력 스트림 셋이 시간에 따라 달라지기도 한다.

소스 커넥터는 소스 시스템에서 데이터베이스 테이블 추가/삭제와 같은 변경 사항이 있는지 모니터링해야 한다. 변경 사항을 감지하면, `ConnectorContext` 객체를 통해 프레임워크에 재설정이 필요하다는 걸 알려야 한다. 예를 들어 `SourceConnector` 안에서:

```java
if (inputsChanged())
    this.context.requestTaskReconfiguration();
```

프레임워크는 태스크를 재설정하기 전에 진행 상황을 정상적으로 커밋할 수 있게 만들면서, 즉시 새 설정 정보를 요청하고 태스크를 업데이트한다. 단, 현재는 이런 식의 모니터링은 `SourceConnector` 구현체에 맡기고 있다. 모니터링을 위한 별도 스레드가 필요하면 커넥터가 직접 할당해야 한다.

이상적으로는, 변경 사항을 모니터링하는 코드는 `Connector`로 격리될 거고, 태스크에선 변경 사항을 신경쓰지 않아도 된다. 하지만 변경 사항이 태스크에까지도 영향을 미칠 수 있다. 가장 흔하게는, 데이터베이스 테이블을 드랍하는 등, 입력 스트림 중 하나가 입력 시스템에서 없어질 때다. `Connector`가 변경 사항을 폴링하고 있다면 커넥터에선 흔한 일이지만, 커넥터 보다 `Task`가 먼저 이 이슈를 만나면 `Task`가 후속 에러를 처리해야 한다. 다행이도 태스크에선 적절한 예외를 캐치하고 처리하기만 하면 보통은 간단히 해결된다.

`SinkConnectors`에선 보통 스트림에 새 데이터가 추가되는 상황만 처리하면 된다. 이땐 출력에 새 엔트리를 추가하는 것으로 처리할 수 있다 (ex. 새 데이터베이스 테이블). 프레임워크는 정규식으로 토픽을 구독할 때 입력 토픽 셋이 변경되는 등, 카프카 입력에 대한 모든 변경 사항을 관리한다. `SinkTasks`에선 새 입력 스트림을 처리할 수 있어야 하며, 다운스트림 시스템에 새 데이터베이스 테이블같은 새 리소스를 만들어야 할 수도 있다. 이때 처리하기가 가장 까다로운 상황은 아마, 새 입력 스트림을 처음 만나 동시에 새 리소스를 만들려 하는 여러 `SinkTasks` 간의 충돌일 거다. 반면, `SinkConnectors` 일반적으로 다이나믹 스트림 셋 처리를 위한 특별한 코드가 필요하지 않다.

### Connect Configuration Validation

카프카 커넥트에선 실행할 커넥터를 제출하기 전에 커넥터 설정의 유효성을 검사하고 에러와 추천값에 대한 피드백을 제공할 수 있다. 이 기능을 활용하려면 커넥터 개발자는 설정 정의를 프레임워크에 노출해주는 `config()`를 구현해야 한다.

다음 코드는 `FileStreamSourceConnector`에서 설정을 정의하고, 이 설정을 프레임워크에 노출한다.

```java
private static final ConfigDef CONFIG_DEF = new ConfigDef()
    .define(FILE_CONFIG, Type.STRING, Importance.HIGH, "Source filename.")
    .define(TOPIC_CONFIG, Type.STRING, Importance.HIGH, "The topic to publish data to");

public ConfigDef config() {
    return CONFIG_DEF;
}
```

기대하는 설정 셋을 지정할 땐 `ConfigDef` 클래스를 사용한다. 각 설정에 이름, 타입, 기본값, 문서, 그룹 정보, 그룹 순서, 설정 값의 길이(width), UI에 노출할 이름을 지정할 수 있다. 추가로, `Validator` 클래스를 재정의하면 단일 설정 유효성 검사에 사용할 특별한 유효성 검사 로직을 제공할 수 있다. 더 나아가면, 설정 간에도 의존성이 있을 수 있다. 예를 들어서 다른 설정 값이 뭐냐에 따라 유효한 값과 가시성이 변경될 수 있다. `ConfigDef`를 사용하면 설정이 의존하는 항목을 지정할 수 있으며, `Recommender` 구현체를 제공해 현재 설정 값에서 유효한 값을 가져오고 설정의 가시성을 세팅할 수 있다.

`Connector`의 `validate()` 메소드는 기본 유효성 검사 로직도 제공한다. 유효성 검사 로직에선 각 설정의 에러, 권장 값을 담은 허용하는 설정 리스트를 반환한다. 하지만 기본 구현에선 설정 유효성 검사에 권장 값을 사용하지 않는다. 권장 값을 사용하려면, 설정 유효성 검증을 커스텀해 기본 구현체를 재정의하면 된다.

### Working with Schemas

FileStream 커넥터는 간단해서 예시로 사용하기 좋지만, 데이터 구조가 매우 단순하다 -- 각 라인은 단순 문자열일 뿐이다. 실제 커넥터는 거의 다 더 복잡한 데이터 포맷을 가진 스키마가 필요하다.

더 복잡한 데이터를 만들려면 카프카 커넥트 `data` API를 사용해야 한다. 구조화된 레코드는 대부분 프리미티브 타입 말고도, `Schema`와 `Struct`, 이 두 클래스와도 상호 작용해야 한다.

전체 가이드는 API 문서를 보면 되지만, `Schema`와 `Struct`를 만드는 간단한 예시를 보여주겠다:

```java
Schema schema = SchemaBuilder.struct().name(NAME)
    .field("name", Schema.STRING_SCHEMA)
    .field("age", Schema.INT_SCHEMA)
    .field("admin", SchemaBuilder.bool().defaultValue(false).build())
    .build();

Struct struct = new Struct(schema)
    .put("name", "Barbara Liskov")
    .put("age", 75);
```

소스 커넥터를 구현한다면, 스키마를 언제 어떻게 만들 것인지를 결정해야 한다. 가능하면 재계산은 최대한 피하는 게 좋다. 예를 들어, 커넥터에서 스키마를 고정해둘 수 있다면, 스키마를 정적으로 생성해 단일 인스턴스를 재사용해라.

하지만 다이나믹 스키마가 필요한 커넥터도 많다. 간단한 예시는 데이터베이스 커넥터다. 단일 테이블만을 고려하더라도, 스키마는 커넥터 레벨에 미리 정의할 수 없다 (테이블마다 스키마가 다르기 때문에). 게다가 사용자가 `ALTER TABLE` 명령을 실행할 수도 있기 때문에, 커넥터 생명 주기 동안 단일 테이블의 스키마마저 변경될 수도 있다. 커넥터는 이런 변경 사항을 감지하고 적절히 대응할 수 있어야 한다.

싱크 커넥터는 데이터를 컨슘하기 때문에, 스키마를 만들 필요가 없어 보통은 더 간단하다. 하지만 전달받은 데이터의 스키마가 기대한 포맷을 가지고 있는지 검증하는 데에도 그만큼 주의가 필요하다. 스키마가 일치하지 않으면 (보통은 업스트림 프로듀서가 정상적으로 목적지 시스템으로 옮길 수 없는, 유효하지 않은 데이터를 생성했다는 걸 의미한다) 싱크 커넥터는 예외를 던져 이 오류를 시스템에 알려야 한다.

### Kafka Connect Administration

카프카 커넥트의 [REST 레이어](#rest-api)는 클러스터를 관리할 수 있는 API 셋을 제공한다. 커넥터 설정과 해당 태스크의 상태를 조회하고, 현재 동작을 바꿀 수 있는 API(설정을 변경하고 태스크를 재시작하는 등)도 지원한다.

클러스터에 커넥터를 처음 제출하면, 새 커넥터의 태스크 부하를 분산하기 위한 커넥트 워커 간의 리밸런스가 트리거된다. 커넥터가 필요한 태스크 수를 늘리거나 줄일 때, 커넥터의 설정을 변경할 때, 커넥트 클러스터를 업그레이드하는 과정에서 워커가 그룹에 추가/제거될 때, 워커가 실패했을 때 모두 동일한 절차로 리밸런스를 진행한다.

2.3.0 이전 버전에선, 커넥트 워커는 간단히 모든 워커에 대략적으로 같은 작업량을 할당하는 식으로 클러스터의 전체 커넥터 셋과 커넥터의 태스크를 리밸런싱했다. 이 동작은 `connect.protocol=eager`를 설정하면 지금도 활성화할 수 있다.

카프카 커넥트 2.3.0부터는, 디폴트 프로토콜이 커넥트 워커 간의 커넥터, 태스크 균형을 점진적으로 조정하는 [incremental cooperative rebalancing](https://cwiki.apache.org/confluence/display/KAFKA/KIP-415%3A+Incremental+Cooperative+Rebalancing+in+Kafka+Connect)을 수행해서, 새 태스크나, 제거할 태스크, 다른 워커로 이동해야 하는 태스크에만 영향을 준다. 다른 태스크는 구버전 프로토콜에서처럼 리밸런싱 중에 중지했다가 재시작하지 않는다.

커넥트 워커가 의도적으로든 실패 때문이든 그룹에서 나가면, 커넥트는 리밸런스를 트리거하기 전 [`scheduled.rebalance.max.delay.ms`](../kafka-connect-configuration#scheduledrebalancemaxdelayms) 동안 대기한다. 기본 값은 5분(`300000ms`)이다. 제외된 워커의 부하를 즉시 재분배하지 않고, 이 시간 동안은 워커의 실패나 업그레이드를 허용한다. 제외됐던 워커가 설정한 지연 시간 내에 돌아 오면, 이전에 할당됐던 태스크를 전부 가져온다. 하지만 [`scheduled.rebalance.max.delay.ms`](../kafka-connect-configuration#scheduledrebalancemaxdelayms)에 지정한 시간이 경과할 때까진 이 태스크는 어디에도 할당되지 않은 채로 남아있는다는 뜻이기도 하다. 워커가 이 제한 시간 내에 돌아 오지 않으면, 커넥트는 해당 태스크를 커넥트 클러스터에 있는 나머지 워커에 재할당한다.

커넥트 클러스터를 구성하는 모든 워커를 `connect.protocol=compatible`로 설정하면 새 커넥트 프로토콜을 활성화한다. 프로퍼티를 명시하지 않았을 때의 기본값이기도 하다. 따라서 모든 워커를 2.3.0으로 올리면 새 커넥트 프로토콜로 자동으로 업그레이드된다. 커넥트 클러스터를 순차적으로 업그레이드할 땐, 마지막 워커가 2.3.0 버전으로 조인하는 시점에 incremental cooperative rebalancing을 활성화한다.

REST API를 사용해 할당된 워커 ID를 포함한 커넥터와 해당 태스크 현재 상태를 조회할 수 있다. 예를 들어 `GET /connectors/file-source/status` 요청은 `file-source`라는 커넥터의 상태를 보여준다:

```json
{
    "name": "file-source",
    "connector": {
        "state": "RUNNING",
        "worker_id": "192.168.1.208:8083"
    },
    "tasks": [
        {
        "id": 0,
        "state": "RUNNING",
        "worker_id": "192.168.1.209:8083"
        }
    ]
}
```

커넥터와 커넥터의 태스크는 클러스터에 있는 모든 워커가 모니터링하는 공유 토픽([`status.storage.topic`](../kafka-connect-configuration#statusstoragetopic)로 설정)에 상태 업데이트를 발행한다. 워커는 이 토픽을 비동기로 컨슘하기 때문에, 보통은 status API로 상태 변화를 확인할 수 있기까지 (짧은) 지연이 있다. 각 커넥터나 태스크는 다음과 같은 상태를 가질 수 있다:

- **UNASSIGNED:** 커넥터/태스크가 아직 워커에 할당되지 않았다.
- **RUNNING:** 커넥터/태스크가 실행 중이다.
- **PAUSED:** 관리자가 커넥터/태스크를 일시 정지했다.
- **FAILED:** 커넥터/태스크가 실패했다 (보통은 예외가 발생해서. 발생한 예외는 status 출력으로 보고된다).
- **DESTROYED:** 관리자가 커넥터/태스크를 삭제했으며, 커넥트 클러스터에 표시되지 않을 거다.

웬만해선 커넥터와 태스크 상태는 일치하는데, 변경 사항이 생기거나 태스크가 실패한 경우엔 잠깐 동안은 다를 수 있다. 예를 들어 커넥터를 처음 시작했을 땐 커넥터와 해당 태스크가 모두 RUNNING 상태로 전환되기 전에 눈에 띄는 지연이 있을 수 있다. 태스크가 실패했을 땐 커넥트가 자동으로 실패한 태스크를 재시작하지 않기 때문에 상태가 갈라질 수도 있다. 커넥터/태스크를 수동으로 재시작하려면 위에 정리해둔 API를 사용하면 된다. 리밸런싱이 일어나는 동안 태스크를 재시작하려고 하면 커넥트는 409(Conflict) 상태 코드를 반환할 거다. 리밸런스가 완료된 후엔 재시도해도 되지만, 리밸런싱은 사실상 클러스터에 있는 모든 커넥터와 태스크를 재시작하므로 꼭 필요하진 않다.

카프카 커넥트는 2.5.0부터 [`status.storage.topic`](../kafka-connect-configuration#statusstoragetopic)을 통해 각 커넥터가 사용하는 토픽 관련 정보도 저장한다. 커넥트 워커는 이 커넥터별 토픽 상태 업데이트를 사용해, REST 엔드포인트 `GET /connectors/{name}/topics` 요청을 받으면 커넥터가 사용 중인 토픽 이름 셋을 반환한다. REST 엔드포인트 `PUT /connectors/{name}/topics/reset` 요청을 받으면 커넥터의 활성 토픽 셋을 재설정하며, 커넥터의 최신 토픽 사용 패턴을 기반으로 새 셋을 채울 수 있다. 커넥터를 삭제하면 커넥터의 활성 토픽 셋도 삭제된다. 토픽 추적은 기본적으로 활성화돼지만, `topic.tracking.enable=false`를 설정하면 비활성화할 수 있다. 런타임에 커넥터 활성 토픽 재설정 요청을 허용하지 않으려면, 워커 프로퍼티 `topic.tracking.allow.reset=false`를 설정해라.

가끔은 커넥터의 메세지 처리를 일시적으로 중지하는 게 유용하기도 하다. 예를 들어 원격 시스템이 유지 보수 중일 때는, 소스 커넥터가 예외 스팸으로 로그를 가득 채우는 대신, 새 데이터 폴링을 중단하는 게 좋다. 커넥트는 이를 위한 pause/resume API를 제공한다. 소스 커넥터가 일시 정지하는 동안은, 커넥트는 추가적인 레코드 폴링을 멈춘다. 싱크 커넥터가 일시 중지하는 동안은 새 메세지를 더 푸쉬하지 않는다. pause 상태는 지속되기 때문에, 클러스터를 재시작하더라도 커넥터는 태스크를 재개할 때까지 메세지 처리를 다시 시작하지 않는다. 단, 커넥터의 모든 태스크가 PAUSED 상태로 전환되기까지 지연이 있을 수도 있다. 일시 중지하는 동안 처리 중이었던 작업을 모두 끝내는데 시간이 걸릴 수 있기 때문이다. 더불어, 실패한 태스크는 재시작될 때까지 PAUSED 상태로 전환되지 않는다.