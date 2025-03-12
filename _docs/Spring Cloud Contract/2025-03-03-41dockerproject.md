---
title: 4. Docker Project
navTitle: Docker Project
category: Spring Cloud Contract
order: 42
permalink: /Spring%20Cloud%20Contract/docker-project/
description: Spring Cloud Contract Docker로 마이크로서비스 통합 테스트 자동화하기
image: ./../../images/springcloud/logo.jpeg
lastmod: 2025-03-12T23:34:00+09:00
comments: true
originalRefName: 스프링 클라우드 컨트랙트
originalRefLink: https://docs.spring.io/spring-cloud-contract/reference/4.2.0/docker-project.html
parent: Build Tools
parentUrl: /Spring%20Cloud%20Contract/build-tools/
---
<script>defaultLanguages = ['groovy']</script>

이번 섹션에선 테스트를 자동 생성하고, 실행 중인 애플리케이션을 호출해 `EXPLICIT` 모드로 테스트를 실행하는 도커 이미지 `springcloud/spring-cloud-contract`를 사용해본다.

> `EXPLICIT` 모드는 명세<sup>contract</sup>로부터 자동 생성한 테스트에서 요청을 모킹하지 않고 실제 요청을 전송한다는 의미다.

또한 Stub Runner를 독립 실행형<sup>standalone</sup>으로 시작하는 도커 이미지 `spring-cloud/spring-cloud-contract-stub-runner`도 제공하고 있다.

### 목차

- [4.1. 메이븐, JAR, 바이너리 스토리지 간단 요약](#41-a-short-introduction-to-maven-jars-and-binary-storage)
- [4.2. 프로듀서 측에서 테스트 자동 생성하기](#42-generating-tests-on-the-producer-side)
  + [4.2.1. 환경 변수](#421-environment-variables)
  + [4.2.2. 그래들 빌드 커스텀하기](#422-customizing-the-gradle-build)
  + [4.2.3. HTTP 사용 예시](#423-example-of-usage-via-http)
  + [4.2.4. 메시지 사용 예시](#424-example-of-usage-via-messaging)
    * [메시지 처리 Contract 예시](#example-of-a-messaging-contract)
    * [메시지를 트리거하는 HTTP 엔드포인트](#http-endpoint-to-trigger-a-message)
    * [프로듀서 측에서 메시지 테스트 실행하기](#running-message-tests-on-the-producer-side)
- [4.3. 컨슈머 측에서 Stub 실행하기 Side](#43-running-stubs-on-the-consumer-side)
  + [4.3.1. 보안](#431-security)
  + [4.3.2. 환경 변수](#432-environment-variables)
  + [4.3.3. 사용 예시](#433-example-of-usage)
  + [4.3.4. 메시지 사용 예시](#434-example-of-usage-with-messaging)
- [4.4. 기존 미들웨어로 Contract 테스트 실행하기](#44-running-contract-tests-against-existing-middleware)
  + [4.4.1. Spring Cloud Contract Docker와 실행 중인 미들웨어](#441-spring-cloud-contract-docker-and-running-middleware)
  + [4.4.2. Stub Runner Docker와 실행 중인 미들웨어](#442-stub-runner-docker-and-running-middleware)


---

## 4.1. A Short Introduction to Maven, JARs, and Binary Storage

JVM이 아닌 프로젝트에서도 도커 이미지를 사용할 수 있기 때문에, Spring Cloud Contract가 기본적으로 제공하는 패키징 방식 뒤에 깔려있는 기본 용어들을 짚고 넘어가는 것이 좋다.

아래 있는 정의 중 일부는 [메이븐 용어집](https://maven.apache.org/glossary.html)에서 가져왔다:

- `Project`: 메이븐은 프로젝트 관점에서 생각한다. 프로젝트는 당신이 빌드하는 모든 것을 뜻한다. 이러한 프로젝트는 잘 정의된 “프로젝트 객체 모델”을 따른다. 프로젝트는 다른 프로젝트에 의존할 수 있으며, 이 경우 후자를 “의존성”이라고 부른다. 하나의 프로젝트는 여러 개의 하위 프로젝트로 구성될 수 있다. 각각의 하위 프로젝트 역시 동일하게 하나의 프로젝트로 취급한다.
- `Artifact`: 아티팩트란 프로젝트에서 생성하거나 사용되는 것을 말한다. 예를 들어, 메이븐이 프로젝트에 생성해주는 JAR 파일과 소스, 바이너리 배포분 역시 아티팩트다. 각 아티팩트는 그룹 ID와 아티팩트 ID로 식별하며, 아티팩트 ID는 그룹 내에서 유일하다.
- `JAR`: JAR는 Java ARchive의 약자다. JAR 포맷은 ZIP 파일 포맷에 기반한다. Spring Cloud Contract는 명세<sup>contract</sup>와 자동 생성된 스텁<sup>stub</sup>을 JAR 파일로 패키징한다.
- `GroupId`: 그룹 ID는 프로젝트에서 사용하는 보편적인 고유 식별자다. 보통 프로젝트 이름을 그대로 사용하는 경우가 많지만 (e.g. `commons-collections`), 비슷한 이름을 가진 다른 프로젝트와 구별하기 쉽도록, 패키지의 풀 네임<sup>fully-qualified package name</sup>을 사용하는 것도 좋다 (e.g. `org.apache.maven`). 일반적으로 아티팩트 매니저에 아티팩트를 배포할 땐, `GroupId`를 슬래시로 구분해서 URL 일부를 구성한다. 예를 들어, 그룹 ID가 `com.example`, 아티팩트 ID가 `application`이라면 `/com/example/application/`인 식이다.
- `Classifier`: 메이븐 의존성은 `groupId:artifactId:version:classifier` 형식으로 표기한다. classifier는 의존성에 전달하는 추가적인 suffix다 (e.g. `stub` 또는 `sources`). 동일한 의존성(e.g. `com.example:application`)에 classifier를 사용하면 서로 다른 아티팩트를 여러 개 생성할 수 있다.
- `Artifact manager`: 바이너리, 소스 코드, 패키지를 생성할 때 다른 사람이 다운로드받아 참조하거나 재사용할 수 있길 바랄 수 있다. 일반적으로 JVM 세계에선 이러한 아티팩트는 JAR로 만들어진다. 마찬가지로, Ruby에선 gem, Docker에선 Docker 이미지다. 이런 아티팩트는 매니저에 저장할 수 있다. 매니저의 예시로 [Artifactory](https://jfrog.com/artifactory/)와 [Nexus](https://www.sonatype.org/nexus/)가 있다.

---

## 4.2. Generating Tests on the Producer Side

도커 이미지에선 `/contracts` 폴더에서 명세<sup>contract</sup>를 검색한다. 테스트를 실행한 결과는 `/spring-cloud-contract/build` 폴더에서 확인할 수 있다 (디버깅할 때 유용하다).

도커 컨테이너를 실행할 땐, 명세<sup>contract</sup>를 마운트하고 환경 변수를 전달할 수 있다. 그러면 도커 이미지는:

- 명세<sup>contract</sup> 테스트를 생성한다
- 지정한 URL에 대해 테스트를 실행한다
- [WireMock](https://github.com/tomakehurst/wiremock) 스텁<sup>stub</sup>을 생성한다
- 아티팩트 매니저에 스텁<sup>stub</sup>을 배포한다<sup>publish</sup> (생략 가능 — 기본적으로 활성화돼 있다)

### 4.2.1. Environment Variables

Docker 이미지를 사용하려면 실행 중인 애플리케이션나 아티팩트 매니저 인스턴스를 가리키는 등, 몇 가지 환경 변수가 필요하다. 다음은 환경 변수를 정리한 테이블이다:

| Name                                           | Description                                                  | Default                                       |
| ---------------------------------------------- | ------------------------------------------------------------ | --------------------------------------------- |
| ADDITIONAL_FLAGS                               | (도커 이미지에만 해당) 그래들 빌드에 전달할 추가 플래그      |                                               |
| DEBUG                                          | (도커 이미지에만 해당) 도커 이미지에 사용할 수 있다 - 그래들 빌드에 디버그 모드를 활성화한다 | false                                         |
| EXTERNAL_CONTRACTS_ARTIFACT_ID                 | 명세<sup>contract</sup>를 가진 프로젝트의 아티팩트 ID        |                                               |
| EXTERNAL_CONTRACTS_CLASSIFIER                  | 명세<sup>contract</sup>를 가진 프로젝트의 classifier         |                                               |
| EXTERNAL_CONTRACTS_GROUP_ID                    | 명세<sup>contract</sup>를 가진 프로젝트의 그룹 ID            | com.example                                   |
| EXTERNAL_CONTRACTS_PATH                        | 특정 프로젝트 내에서 명세<sup>contract</sup>가 포함된 경로. `EXTERNAL_CONTRACTS_GROUP_ID`를 슬래시로 구분하고, `/`와 `EXTERNAL_CONTRACTS_ARTIFACT_ID`를 연결한 값을 디폴트로 사용한다. 예를 들어, 그룹 ID가 `cat.dog`, 아티팩트 ID가 `fish`인 경우, 명세<sup>contract</sup> 경로는 `cat/dog/fish`가 된다. |                                               |
| EXTERNAL_CONTRACTS_REPO_WITH_BINARIES_PASSWORD | (생략 가능) `EXTERNAL_CONTRACTS_REPO_WITH_BINARIES_URL`이 인증<sup>authentication</sup>을 필요로 하는 경우 password를 지정한다. 기본적으로 `REPO_WITH_BINARIES_PASSWORD` 값을 사용하며, 여기에 값을 따로 설정하지 않은 경우 기본값은 `password`다. |                                               |
| EXTERNAL_CONTRACTS_REPO_WITH_BINARIES_URL      | 아티팩트 매니저의 URL. 기본적으로 환경 변수 `REPO_WITH_BINARIES_URL` 값을 사용하며, 따로 설정하지 않은 경우 기본값은 `localhost:8081/artifactory/libs-release-local`이다. |                                               |
| EXTERNAL_CONTRACTS_REPO_WITH_BINARIES_USERNAME | (생략 가능) `EXTERNAL_CONTRACTS_REPO_WITH_BINARIES_URL`이 인증<sup>authentication</sup>을 필요로 하는 경우 username를 지정한다. 기본적으로 `REPO_WITH_BINARIES_USERNAME` 값을 사용하며, 따로 설정하지 않은 경우 기본값은 `admin`이다. |                                               |
| EXTERNAL_CONTRACTS_VERSION                     | 명세<sup>contract</sup>를 가진 프로젝트의 버전. 기본적으로는 최신 버전을 선택한다. | +                                             |
| EXTERNAL_CONTRACTS_WORK_OFFLINE                | `true`로 설정하면 컨테이너의 `.m2`에서 명세<sup>contract</sup>를 가진 아티팩트를 검색한다. 로컬 `.m2`를 컨테이너의 `/root/.m2` 경로에서 사용 가능한 볼륨으로 마운트하는 식으로 활용할 수 있다. | false                                         |
| FAIL_ON_NO_CONTRACTS                           | 명세<sup>contract</sup>가 없는 경우 빌드가 실패해야 하는지?  | false                                         |
| MESSAGING_TYPE                                 | 메시지 처리 타입. [rabbit] 혹은 [kafka]를 사용할 수 있다.    |                                               |
| PRODUCER_STUBS_CLASSIFIER                      | 자동 생성 프로듀서<sup>producer</sup> 스텁<sup>stub</sup>에서 사용할 아카이브 classifier | stubs                                         |
| PROJECT_GROUP                                  | 현재 프로젝트의 그룹 ID                                      | com.example                                   |
| PROJECT_NAME                                   | 현재 프로젝트의 아티팩트 id                                  | example                                       |
| PROJECT_VERSION                                | 현재 프로젝트의 version                                      | 0.0.1-SNAPSHOT                                |
| PUBLISH_ARTIFACTS                              | `true`로 설정하면 아티팩트를 바이너리 스토리지로 배포한다    | true                                          |
| PUBLISH_ARTIFACTS_OFFLINE                      | `true`로 설정하면 아티팩트를 로컬 m2로 배포한다              | false                                         |
| PUBLISH_STUBS_TO_SCM                           | `true`로 설정하면 스텁<sup>stub</sup>을 scm에 배포하는 태스크를 실행한다 | false                                         |
| REPO_ALLOW_INSECURE_PROTOCOL                   | (생략 가능) `true`로 설정하면 아티팩트를 안전하지 않은 HTTP를 통해 아티팩트 매니저로 배포할 수 있다 | false                                         |
| REPO_WITH_BINARIES_PASSWORD                    | (생략 가능) 아티팩트 매니저를 보호 중일 때 사용할 수 있는 password | password                                      |
| REPO_WITH_BINARIES_URL                         | 아티팩트 매니저의 URL (기본적으로 로컬에서 실행 중인 [아티팩토리](https://jfrog.com/artifactory/)의 디폴트 URL을 사용한다) | localhost:8081/artifactory/libs-release-local |
| REPO_WITH_BINARIES_USERNAME                    | (생략 가능) 아티팩트 매니저를 보호 중일 때 사용할 수 있는 username | admin                                         |
| STANDALONE_PROTOCOL                            | 별도 프로토콜을 추가해야 하는 독립 실행 버전 전용            |                                               |

테스트를 실행할 땐 다음과 같은 환경 변수를 사용한다:

| Name                              | Description                                                  | Default |
| --------------------------------- | ------------------------------------------------------------ | ------- |
| APPLICATION_BASE_URL              | 애플리케이션이 실행되고 있는 URL.                            |         |
| APPLICATION_PASSWORD              | 애플리케이션에 접근하기 위한 password (생략 가능).           |         |
| APPLICATION_USERNAME              | 애플리케이션에 접근하기 위한 username (생략 가능).           |         |
| MESSAGING_TRIGGER_CONNECT_TIMEOUT | 메시지를 트리거하기 위해 애플리케이션에 연결할 때 사용할 타임아웃. | 5000    |
| MESSAGING_TRIGGER_READ_TIMEOUT    | 메시지를 트리거하기 위해 애플리케이션의 응답을 읽어들일 때 설정할 타임아웃. | 5000    |
| MESSAGING_TYPE                    | 메시지 처리 타입. [rabbit] 혹은 [kafka]를 지정할 수 있다.    |         |
| MESSAGING_TYPE                    | 메시지 기반 명세<sup>contract</sup>를 처리할 때 메시지 처리 타입을 정의한다. |         |
| SPRING_KAFKA_BOOTSTRAP_SERVERS    | 카프카 전용 - 브로커 주소.                                   |         |
| SPRING_RABBITMQ_ADDRESSES         | RabbitMQ 전용 - 브로커 주소.                                 |         |

### 4.2.2. Customizing the gradle build

컨테이너에서 실행할 `gradle.build`를 커스텀하고 싶다면, 컨테이너를 띄울 때 커스텀한 빌드 파일을 볼륨으로 마운트하면 된다:

```bash
$ docker run -v <absolute-path-of-your-custom-file>:/spring-cloud-contract/build.gradle springcloud/spring-cloud-contract:<version>
```

### 4.2.3. Example of Usage via HTTP

이번에는 간단한 MVC 애플리케이션을 다뤄본다. 가장 먼저 다음 명령어를 실행해 아래 git 레포지토리를 클론받고, 현재 작업 디렉토리를 변경해보자:

```bash
$ git clone https://github.com/spring-cloud-samples/spring-cloud-contract-nodejs
$ cd bookstore
```

명세<sup>contract</sup>는 `/contracts` 폴더에 정의돼 있다.

테스트를 실행해보려면 아래 명령어를 실행하면 된다:

```bash
$ npm test
```

하지만 이번엔 설명을 위해, 다음과 같이 여러 단계로 나누어 진행해본다:

```bash
# Stop docker infra (nodejs, artifactory)
$ ./stop_infra.sh
# Start docker infra (nodejs, artifactory)
$ ./setup_infra.sh

# Kill & Run app
$ pkill -f "node app"
$ nohup node app &

# Prepare environment variables
$ SC_CONTRACT_DOCKER_VERSION="..."
$ APP_IP="192.168.0.100"
$ APP_PORT="3000"
$ ARTIFACTORY_PORT="8081"
$ APPLICATION_BASE_URL="http://${APP_IP}:${APP_PORT}"
$ ARTIFACTORY_URL="http://${APP_IP}:${ARTIFACTORY_PORT}/artifactory/libs-release-local"
$ CURRENT_DIR="$( pwd )"
$ CURRENT_FOLDER_NAME=${PWD##*/}
$ PROJECT_VERSION="0.0.1.RELEASE"

# Run contract tests
$ docker run  --rm -e "APPLICATION_BASE_URL=${APPLICATION_BASE_URL}" -e "PUBLISH_ARTIFACTS=true" -e "PROJECT_NAME=${CURRENT_FOLDER_NAME}" -e "REPO_WITH_BINARIES_URL=${ARTIFACTORY_URL}" -e "PROJECT_VERSION=${PROJECT_VERSION}" -v "${CURRENT_DIR}/contracts/:/contracts:ro" -v "${CURRENT_DIR}/node_modules/spring-cloud-contract/output:/spring-cloud-contract-output/" springcloud/spring-cloud-contract:"${SC_CONTRACT_DOCKER_VERSION}"

# Kill app
$ pkill -f "node app"
```

이 bash 스크립트를 실행하면 다음과 같은 일이 일어난다:

- 몽고DB와 아티팩토리같은 인프라를 세팅한다. 실제 상황이라면 목 데이터베이스로 NodeJS 애플리케이션을 실행할 거다. 이 예제에서는 Spring Cloud Contract를 활용해 아주 빠르게 환경을 세팅하는 방법을 보여주려 한다.
- 이러한 제약으로 인해, 명세<sup>contract</sup> 역시 상태 저장이 필요한<sup>stateful</sup> 상황이다.
  - 첫 번째 요청은 `POST` 요청으로, 데이터베이스에 데이터를 insert한다.
  - 두 번째 요청은 `GET` 요청으로, 앞에서 insert한 요소를 한 개 가지고 있는 리스트를 반환한다.
- NodeJS 애플리케이션을 시작한다 (`3000` 포트에서).
- 도커를 이용해 명세<sup>contract</sup> 테스트를 생성하고, 실행 중인 애플리케이션에 대해 테스트를 실행한다.
  - 명세<sup>contract</sup>는 `/contracts` 폴더에서 가져온다.
  - 테스트 결과는 `node_modules/spring-cloud-contract/output`에서 확인할 수 있다.
- 아티팩토리에 스텁<sup>stub</sup>을 업로드한다. 업로드한 아티팩트는 [localhost:8081/artifactory/libs-release-local/com/example/bookstore/0.0.1.RELEASE/](localhost:8081/artifactory/libs-release-local/com/example/bookstore/0.0.1.RELEASE/)에서 확인할 수 있다. 스텁<sup>stub</sup>은 [localhost:8081/artifactory/libs-release-local/com/example/bookstore/0.0.1.RELEASE/bookstore-0.0.1.RELEASE-stubs.jar](localhost:8081/artifactory/libs-release-local/com/example/bookstore/0.0.1.RELEASE/bookstore-0.0.1.RELEASE-stubs.jar)에 올라가있다.

### 4.2.4. Example of Usage via Messaging

도커 이미지를 통해 Spring Cloud Contract로 메시지를 처리하고 싶다면 (e.g. 애플리케이션마다 사용하는 프로그래밍 언어가 다른 경우 등), 다음과 같은 전제가 필요하다:

- 테스트를 생성하려먼 먼저 RabbitMQ나 Kafka같은 미들웨어가 실행중이어야 한다
- 명세<sup>contract</sup>에서는, 명세<sup>contract</sup>의 `label`과 동일한 `String` 파라미터로 `triggerMessage(...)` 메소드를 호출해야 한다.
- 애플리케이션에는 메시지를 트리거할 수 있는 HTTP 엔드포인트가 존재해야 한다
  - 이 엔드포인트는 프로덕션 환경에선 사용할 수 없어야 한다 (환경 변수를 통해 활성화할 수 있다)

#### Example of a Messaging Contract

명세<sup>contract</sup>에선 `triggerMessage(...)` 메소드를 호출해야 한다. 이 메소드는 도커 이미지에서 모든 테스트에 사용하는 베이스 클래스에 미리 정의되어 있으며, 프로듀서<sup>producer</sup> 측의 HTTP 엔드포인트로 요청을 전송해준다. 이러한 명세<sup>contract</sup>의 예시는 아래를 참고하면 된다.

<div class="switch-language-wrapper groovy yaml">
<span class="switch-language groovy">Groovy</span>
<span class="switch-language yaml">YAML</span>
</div>
<div class="language-only-for-groovy groovy yaml"></div>
```groovy
import org.springframework.cloud.contract.spec.Contract

Contract.make {
    description 'Send a pong message in response to a ping message'
    label 'ping_pong'
    input {
        // You have to provide the `triggerMessage` method with the `label`
        // as a String parameter of the method
        triggeredBy('triggerMessage("ping_pong")')
    }
    outputMessage {
        sentTo('output')
        body([
            message: 'pong'
        ])
    }
    metadata(
        [amqp:
         [
           outputMessage: [
               connectToBroker: [
                   declareQueueWithName: "queue"
               ],
                messageProperties: [
                    receivedRoutingKey: '#'
                ]
           ]
         ]
        ])
}
```
<div class="language-only-for-yaml groovy yaml"></div>
```yaml
description: 'Send a pong message in response to a ping message'
label: 'ping_pong'
input:
    # You have to provide the `triggerMessage` method with the `label`
    # as a String parameter of the method
    triggeredBy: 'triggerMessage("ping_pong")'
outputMessage:
    sentTo: 'output'
    body:
        message: 'pong'
metadata:
    amqp:
        outputMessage:
            connectToBroker:
                declareQueueWithName: "queue"
            messageProperties:
                receivedRoutingKey: '#'
```

#### HTTP Endpoint to Trigger a Message

이런 엔드포인트는 왜 개발해야 하는 걸까? Spring Cloud Contract가 브로커에 메시지를 전송하는 프로덕션 코드를 트리거할 수 있으려면, 다양한 언어로 코드를 생성해야 한다 (자바 코드를 생성하듯이). 이런 코드를 생성하지 않는다면 어떻게든 메시지를 트리거할 수 있어야 하는데, HTTP 엔드포인트를 이용하면 사용자가 원하는 언어를 사용해 엔드포인트를 준비하면 된다.

엔드포인트는 다음과 같이 설정돼 있어야 한다:

- URL: `/springcloudcontract/{label}` (`label`은 자유롭게 선택할 수 있다)
- 메소드: `POST`
- `label`을 기반으로, 명세<sup>contract</sup>에 정의한 목적지로 전송할 메시지를 생성한다.

아래 코드는 이러한 엔드포인트의 예시다. 사용 중인 언어로 예제 코드를 작성하는 데 관심이 있다면, 주저하지 말고 [Spring Cloud Contract Github 레포지토리](https://github.com/spring-cloud/spring-cloud-contract/issues/new?assignees=&labels=&template=feature_request.md&title=New+Polyglot+Sample+of+a+HTTP+controller)에 이슈를 등록해달라.

<span class="switch-language python">Python</span>

```python
#!/usr/bin/env python

from flask import Flask
from flask import jsonify
import pika
import os

app = Flask(__name__)

# Production code that sends a message to RabbitMQ
def send_message(cmd):
    connection = pika.BlockingConnection(pika.ConnectionParameters(host='localhost'))
    channel = connection.channel()
    channel.basic_publish(
        exchange='output',
        routing_key='#',
        body=cmd,
        properties=pika.BasicProperties(
            delivery_mode=2,  # make message persistent
        ))
    connection.close()
    return " [x] Sent via Rabbit: %s" % cmd

# This should be ran in tests (shouldn't be publicly available)
if 'CONTRACT_TEST' in os.environ:
    @app.route('/springcloudcontract/<label>', methods=['POST'])
    def springcloudcontract(label):
        if label == "ping_pong":
            return send_message('{"message":"pong"}')
        else:
            raise ValueError('No such label expected.')
```

#### Running Message Tests on the Producer Side

이제 명세<sup>contract</sup>로부터 테스트를 생성해서 프로듀서<sup>producer</sup>의 동작을 테스트해 보자. bash 코드를 통해 명세<sup>contract</sup>를 첨부해 도커 이미지를 시작하되, 이번에는 메시지를 처리하는 코드가 동작할 수 있도록 몇 가지 변수를 추가해본다. 명세<sup>contract</sup>는 Git 레포지토리에 보관하고 있다고 가정한다.

```bash
#!/bin/bash
set -x

CURRENT_DIR="$( pwd )"

export SC_CONTRACT_DOCKER_VERSION="${SC_CONTRACT_DOCKER_VERSION:-4.0.1-SNAPSHOT}"
export APP_IP="$( ./whats_my_ip.sh )"
export APP_PORT="${APP_PORT:-8000}"
export APPLICATION_BASE_URL="http://${APP_IP}:${APP_PORT}"
export PROJECT_GROUP="${PROJECT_GROUP:-group}"
export PROJECT_NAME="${PROJECT_NAME:-application}"
export PROJECT_VERSION="${PROJECT_VERSION:-0.0.1-SNAPSHOT}"
export PRODUCER_STUBS_CLASSIFIER="${PRODUCER_STUBS_CLASSIFIER:-stubs}"
export FAIL_ON_NO_CONTRACTS="${FAIL_ON_NO_CONTRACTS:-false}"
# In our Python app we want to enable the HTTP endpoint
export CONTRACT_TEST="true"
# In the Verifier docker container we want to add support for RabbitMQ
export MESSAGING_TYPE="rabbit"

# Let's start the infrastructure (e.g. via Docker Compose)
yes | docker-compose kill || echo "Nothing running"
docker-compose up -d

echo "SC Contract Version [${SC_CONTRACT_DOCKER_VERSION}]"
echo "Application URL [${APPLICATION_BASE_URL}]"
echo "Project Version [${PROJECT_VERSION}]"

# Let's run python app
gunicorn -w 4 --bind 0.0.0.0 main:app &
APP_PID=$!

# Generate and run tests
docker run  --rm \
                --name verifier \
                # For the image to find the RabbitMQ running in another container
                -e "SPRING_RABBITMQ_ADDRESSES=${APP_IP}:5672" \
                # We need to tell the container what messaging middleware we will use
                -e "MESSAGING_TYPE=${MESSAGING_TYPE}" \
                -e "PUBLISH_STUBS_TO_SCM=false" \
                -e "PUBLISH_ARTIFACTS=false" \
                -e "APPLICATION_BASE_URL=${APPLICATION_BASE_URL}" \
                -e "PROJECT_NAME=${PROJECT_NAME}" \
                -e "PROJECT_GROUP=${PROJECT_GROUP}" \
                -e "PROJECT_VERSION=${PROJECT_VERSION}" \
                -e "EXTERNAL_CONTRACTS_REPO_WITH_BINARIES_URL=git://https://github.com/marcingrzejszczak/cdct_python_contracts.git" \
                -e "EXTERNAL_CONTRACTS_ARTIFACT_ID=${PROJECT_NAME}" \
                -e "EXTERNAL_CONTRACTS_GROUP_ID=${PROJECT_GROUP}" \
                -e "EXTERNAL_CONTRACTS_VERSION=${PROJECT_VERSION}" \
                -v "${CURRENT_DIR}/build/spring-cloud-contract/output:/spring-cloud-contract-output/" \
                springcloud/spring-cloud-contract:"${SC_CONTRACT_DOCKER_VERSION}"

kill $APP_PID

yes | docker-compose kill
```

그러면 다음과 같은 일이 일어난다:

- Git에서 가져온 명세<sup>contract</sup>로부터 테스트를 생성한다
- 명세<sup>contract</sup>에 `declareQueueWithName`이란 메타데이터 항목을 정의했기 때문에, 메시지를 트리거하는 요청을 전송하기 **전에** 주어진 이름으로 RabbitMQ에 큐를 생성한다
- `triggerMessage("ping_pong")` 메소드를 통해 파이썬 애플리케이션의 `/springcloudcontract/ping_pong` 엔드포인트에 POST 요청을 전송한다
- 파이썬 애플리케이션은 JSON `'{"message":"pong"}'`을 생성하고, RabbitMQ를 통해 `output`이란 exchange로 전송한다
- 자동 생성된 테스트는 `output` exchange로 전송되는 메시지를 폴링한다
- 메시지를 수신하면 메시지 내용을 검증한다

테스트가 통과했다면, 파이썬 애플리케이션에서 RabbitMQ로 메시지를 제대로 전송했다고 볼 수 있다.

---

## 4.3. Running Stubs on the Consumer Side

이번 섹션에선 컨슈머<sup>consumer</sup> 측에서 도커를 통해 스텁<sup>stub</sup>을 가져오고 실행하는 방법을 설명한다.

Spring Cloud Contract는 Stub Runner를 독립 실행형<sup>standalone</sup>으로 시작하는 도커 이미지 `spring-cloud/spring-cloud-contract-stub-runner`를 제공하고 있다.

### 4.3.1. Security

Spring Cloud Contract Stub Runner의 도커 이미지는 Stub Runner를 독립 실행형<sup>standalone</sup>으로 실행하기 때문에, 보안과 관련해서 생각해봐야 하는 것 역시 동일하다. 이에 대한 자세한 내용은 [이곳](../stub-runner-boot/#stub-runner-boot-security)에서 확인할 수 있다.

### 4.3.2. Environment Variables

도커 이미지를 실행할 땐 [JUnit과 스프링의 공통 프로퍼티](../stub-runner-common)를 환경 변수로 전달할 수 있다. 모든 문자는 대문자를 사용해야 하며, 점(`.`)은 밑줄(`_`)로 변경해야 한다. 예를 들어, `stubrunner.repositoryRoot` 프로퍼티는 환경 변수로 사용할 땐 `STUBRUNNER_REPOSITORY_ROOT`로 표기해야 한다.

그 외에도 다음과 같은 변수를 설정할 수 있다:

- `MESSAGING_TYPE` - 메시지를 처리하는 시스템 (현재 `rabbit`과 `kafka`를 지원한다)
- `ADDITIONAL_OPTS` - 애플리케이션에 전달하고 싶은 모든 프로퍼티

### 4.3.3. Example of Usage

이 [[도커 서버 예시]](#423-example-of-usage-via-http)에서 생성했던 스텁<sup>stub</sup>을 사용해보려고 한다. 스텁<sup>stub</sup>은 `9876` 포트에서 실행해볼 거다. 레포지토리를 클론받고 아래 명령어대로 현재 작업 디렉토리를 변경하면 NodeJS 코드를 확인할 수 있다:

```bash
$ git clone https://github.com/spring-cloud-samples/spring-cloud-contract-nodejs
$ cd bookstore
```

이제 다음 명령어를 실행하면, 이 스텁<sup>stub</sup>을 사용해 Stub Runner 부트 애플리케이션을 실행할 수 있다:

```bash
# Provide the Spring Cloud Contract Docker version
$ SC_CONTRACT_DOCKER_VERSION="..."
# The IP at which the app is running and Docker container can reach it
$ APP_IP="192.168.0.100"
# Spring Cloud Contract Stub Runner properties
$ STUBRUNNER_PORT="8083"
# Stub coordinates 'groupId:artifactId:version:classifier:port'
$ STUBRUNNER_IDS="com.example:bookstore:0.0.1.RELEASE:stubs:9876"
$ STUBRUNNER_REPOSITORY_ROOT="http://${APP_IP}:8081/artifactory/libs-release-local"
# Run the docker with Stub Runner Boot
$ docker run  --rm \
    -e "STUBRUNNER_IDS=${STUBRUNNER_IDS}" \
    -e "STUBRUNNER_REPOSITORY_ROOT=${STUBRUNNER_REPOSITORY_ROOT}" \
    -e "STUBRUNNER_STUBS_MODE=REMOTE" \
    -p "${STUBRUNNER_PORT}:${STUBRUNNER_PORT}" \
    -p "9876:9876" \
    springcloud/spring-cloud-contract-stub-runner:"${SC_CONTRACT_DOCKER_VERSION}"
```

위 명령어를 실행하면,

- 독립 실행형<sup>standalone</sup> Stub Runner 애플리케이션을 시작한다.
- 이 애플리케이션은 `com.example:bookstore:0.0.1.RELEASE:stubs`에 있는 스텁<sup>stub</sup>을 다운로드한다.
- 다운로드는 `192.168.0.100:8081/artifactory/libs-release-local`에서 실행 중인 아티팩토리에서 받는다.
- 잠시 후 `8083` 포트에서 Stub Runner를 실행한다.
- 스텁<sup>stub</sup>은 `9876` 포트에서 실행한다.

서버 측에서는 빌드한 스텁<sup>stub</sup>은 상태를 가지고 있었다<sup>stateful</sup>. curl을 통해 스텁<sup>stub</sup>이 제대로 설정됐는지 확인할 수 있다. 다음 명령어를 실행해보자:

```bash
# let's run the first request (no response is returned)
$ curl -H "Content-Type:application/json" -X POST --data '{ "title" : "Title", "genre" : "Genre", "description" : "Description", "author" : "Author", "publisher" : "Publisher", "pages" : 100, "image_url" : "https://d213dhlpdb53mu.cloudfront.net/assets/pivotal-square-logo-41418bd391196c3022f3cd9f3959b3f6d7764c47873d858583384e759c7db435.svg", "buy_url" : "https://pivotal.io" }' http://localhost:9876/api/books
# Now time for the second request
$ curl -X GET http://localhost:9876/api/books
# You will receive contents of the JSON
```

> 호스트 로컬에서 빌드한 스텁<sup>stub</sup>을 사용하고 싶다면, 환경 변수 `-e STUBRUNNER_STUBS_MODE=LOCAL`을 설정하고 로컬 m2의 볼륨을 마운트해야 한다 (`-v "${HOME}/.m2/:/home/scc/.m2:rw"`).

### 4.3.4. Example of Usage with Messaging

메시지를 처리하려면 환경 변수 `MESSAGING_TYPE`으로 `kafka`나 `rabbit`을 전달해주기만 하면 된다. 그러면 Stub Runner 부트 도커 이미지를 설정하면서 브로커에 연결하는 데 필요한 의존성이 세팅된다.

커넥션 관련 프로퍼티를 설정하려면, Spring Cloud Stream 프로퍼티 페이지를 참고해 적절한 환경 변수를 넘기면 된다.

- [스프링 부트 통합 프로퍼티](https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/#integration-properties)
  - `spring.rabbitmq.xxx`나 `spring.kafka.xxx` 프로퍼티를 찾아보면 된다
- [Stream 전용 RabbitMQ 프로퍼티](https://docs.spring.io/spring-cloud-stream-binder-rabbit/docs/3.1.0.M1/reference/html/index.html#_configuration_options)
- [Stream 전용 Kafka 프로퍼티](https://docs.spring.io/spring-cloud-stream-binder-kafka/docs/3.1.0.M1/reference/html/index.html#_configuration_options)

실행 중인 미들웨어의 위치를 지정하는 프로퍼티를 가장 많이 사용할 거다. 설정할 프로퍼티 이름이 `spring.rabbitmq.addresses`, `spring.kafka.bootstrap-servers`라면, 환경 변수 이름은 각각 `SPRING_RABBITMQ_ADDRESSES`, `SPRING_KAFKA_BOOTSTRAP_SERVERS`로 지정해야 한다.

---

## 4.4. Running Contract Tests against Existing Middleware

상황에 따라 기존 미들웨어를 그대로 사용해 명세<sup>contract</sup> 테스트를 실행해야 할 수 있다. 테스트 프레임워크에 따라서, 빌드 중에 실행한 테스트는 통과하고, 프로덕션 환경에서는 통신에 실패할 수도 있기 때문이다.

Spring Cloud Contract 도커 이미지에서는 기존에 가지고 있는 미들웨어에 연결할 수 있는 옵션을 제공한다. 앞에서도 언급한 대로, Kafka와 RabbitMQ를 기본으로 지원한다. 하지만 [Apache Camel Components](https://camel.apache.org/components/latest/index.html)를 이용하면 다른 미들웨어도 사용할 수 있다. Apache Camel을 사용하는 아래 예시를 함께 살펴보자.

### 4.4.1. Spring Cloud Contract Docker and running Middleware

임의의 미들웨어에 연결할 수 있도록, contract 부분에 메타데이터 `standalone`을 정의한다.

```yaml
description: 'Send a pong message in response to a ping message'
label: 'standalone_ping_pong' # (1)
input:
  triggeredBy: 'triggerMessage("ping_pong")' # (2)
outputMessage:
  sentTo: 'rabbitmq:output' # (3)
  body: # (4)
    message: 'pong'
metadata:
  standalone: # (5)
    setup: # (6)
      options: rabbitmq:output?queue=output&routingKey= # (7)
    outputMessage: # (8)
      additionalOptions: routingKey=#&queue=output # (9) 
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> Stub Runner를 통해 메시지를 트리거할 수 있도록 레이블을 지정한다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 앞에서 보여준 메시지 처리 예제와 마찬가지로, 지정한 프로토콜에 따라 메시지를 전송할 수 있도록, 실행 중인 애플리케이션의 HTTP 엔드포인트를 트리거해야 한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> Apache Camel에서 요구하는 `protocol:destination` 형식</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> 출력 메시지의 body</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> 메타데이터 standalone</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(6)</span> setup 부분에는 명세<sup>contract</sup> 테스트를 실행하려면, 실행 중인 애플리케이션의 HTTP 엔드포인트를 실제로 호출하기 전에 어떤 준비가 필요한지에 대한 정보가 담겨있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(7)</span> setup 단계에서 호출할 Apache Camel URI. 여기선 `output` exchange에서 메시지를 폴링하려고 할 것이며, `queue=output`과 `routingKey=`를 정의했으므로 `output`이라는 이름의 큐가 설정되고 라우팅 키 <code class="highlighter-rouge">&nbsp;</code>로 `output` exchange에 바인딩된다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(8)</span> (3)번에 정의한 `protocol:destination`에 추가할 별도 옵션 (좀 더 기술적인 옵션). 여기에 정의한 옵션을 결합하면 `rabbitmq:output?routingKey=#&queue=output` 형식이 된다.</small>

명세<sup>contract</sup> 테스트를 통과시키려면, 여러 프로그래밍 언어가 공존하는 환경에서 늘 그렇듯, 애플리케이션과 미들웨어가 실행 중이어야 한다. 이번에는 Spring Cloud Contract 도커 이미지에 다른 환경 변수를 설정해본다.

```bash
#!/bin/bash
set -x

# Setup
# Run the middleware
docker-compose up -d rabbitmq # (1)

# Run the python application
gunicorn -w 4 --bind 0.0.0.0 main:app & # (2)
APP_PID=$!

docker run  --rm \
                --name verifier \
                -e "STANDALONE_PROTOCOL=rabbitmq" \ # (3)
                -e "CAMEL_COMPONENT_RABBITMQ_ADDRESSES=172.18.0.1:5672" \ # (4) 
                -e "PUBLISH_STUBS_TO_SCM=false" \
                -e "PUBLISH_ARTIFACTS=false" \
                -e "APPLICATION_BASE_URL=172.18.0.1" \
                -e "PROJECT_NAME=application" \
                -e "PROJECT_GROUP=group" \
                -e "EXTERNAL_CONTRACTS_ARTIFACT_ID=application" \
                -e "EXTERNAL_CONTRACTS_GROUP_ID=group" \
                -e "EXTERNAL_CONTRACTS_VERSION=0.0.1-SNAPSHOT" \
                -v "${CURRENT_DIR}/build/spring-cloud-contract/output:/spring-cloud-contract-output/" \
                springcloud/spring-cloud-contract:"${SC_CONTRACT_DOCKER_VERSION}"


# Teardown
kill $APP_PID
yes | docker-compose kill
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 먼저 미들웨어가 실행 중이어야 한다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 애플리케이션이 떠서 실행 중이어야 한다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 환경 변수 `STANDALONE_PROTOCOL`을 통해 [Apache Camel Component](https://camel.apache.org/components/latest/index.html)를 가져온다. 여기서 가져올 아티팩트는 `org.apache.camel.springboot:camel-${STANDALONE_PROTOCOL}-starter`다. 즉, `STANDALONE_PROTOCOL`이 Camel의 컴포넌트와 매칭된다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> Camel의 스프링 부트 스타터를 활용해 주소를 설정하고 있다 (credential도 설정할 수 있다). Apache Camel의 RabbitMQ [스프링 부트 자동 설정](https://camel.apache.org/components/latest/rabbitmq-component.html#_spring_boot_auto_configuration) 예제를 참고해라.</small>

### 4.4.2. Stub Runner Docker and running Middleware

실행 중인 미들웨어로 스텁<sup>stub</sup> 메시지를 트리거하고 싶다면, 다음과 같은 방식으로 Stub Runner 도커 이미지를 실행하면 된다.

*Example of usage*

```bash
$ docker run \
    -e "CAMEL_COMPONENT_RABBITMQ_ADDRESSES=172.18.0.1:5672" \ # (1)
    -e "STUBRUNNER_IDS=group:application:0.0.1-SNAPSHOT" \ # (2)
    -e "STUBRUNNER_REPOSITORY_ROOT=git://https://github.com/marcingrzejszczak/cdct_python_contracts.git" \ # (3) 
    -e ADDITIONAL_OPTS="--thin.properties.dependencies.rabbitmq=org.apache.camel.springboot:camel-rabbitmq-starter:3.4.0" \ # (4) 
    -e "STUBRUNNER_STUBS_MODE=REMOTE" \ # (5)
    -v "${HOME}/.m2/:/home/scc/.m2:rw" \ # (6)
    -p 8750:8750 \ # (7) 
    springcloud/spring-cloud-contract-stub-runner:3.0.4-SNAPSHOT # ( 8) 
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> [Apache Camel의 스프링 부트 자동 설정](https://camel.apache.org/components/latest/rabbitmq-component.html#_spring_boot_auto_configuration)을 이용해 RabbitMQ의 주소를 주입하고 있다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> Stub Runner에 어떤 스텁<sup>stub</sup>을 다운받을지 알려준다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 스텁<sup>stub</sup>을 받을 외부 저장소를 제공한다 (Git 레포지토리)</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> `ADDITIONAL_OPTS=--thin.properties.dependencies.XXX=GROUP:ARTIFACT:VERSION` 프로퍼티를 통해 Stub Runner가 런타임에 가져올 추가 의존성을 알려준다. 이 경우 `camel-rabbitmq-starter`를 가져오려고 하는데, `XXX`는 임의의 문자열이고, `org.apache.camel.springboot:camel-rabbitmq-starter` 아티팩트는 `3.4.0` 버전을 가져오려고 한다.
</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> Git을 사용하기 때문에, 스텁<sup>stub</sup>을 가져오는 옵션으로 remote를 설정해야 한다</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(6)</span> Stub Runner의 기동 속도를 높이기 위해 메이븐 로컬 레포지토리 `.m2`를 볼륨으로 마운트한다. 볼륨에 데이터가 생기지 않는다면 읽기 전용 `:ro`가 아닌 `:rw`를 명시해 쓰기 권한을 설정했는지 확인해봐라.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(7)</span> Stub Runner가 실행 중인 `8750` 포트를 노출한다.<br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(8)</span> Stub Runner 도커 이미지의 좌표<sup>coordinates</sup>.</small>

잠시 후 콘솔에 다음과 같은 로그가 찍히는데, 이는 Stub Runner가 요청을 수락할 준비가 되었다는 뜻이다.

```java
o.a.c.impl.engine.AbstractCamelContext   : Apache Camel 3.4.3 (camel-1) started in 0.007 seconds
o.s.c.c.s.server.StubRunnerBoot          : Started StubRunnerBoot in 14.483 seconds (JVM running for 18.666)
o.a.c.c.C.[Tomcat].[localhost].[/]       : Initializing Spring DispatcherServlet 'dispatcherServlet'
o.s.web.servlet.DispatcherServlet        : Initializing Servlet 'dispatcherServlet'
o.s.web.servlet.DispatcherServlet        : Completed initialization in 2 ms
```

트리거 목록을 조회하고 싶다면 `localhost:8750/triggers` 엔드포인트로 HTTP GET 요청을 보내보면 된다. 스텁<sup>stub</sup> 메시지를 트리거하려면 `localhost:8750/triggers/standalone_ping_pong`으로 HTTP POST 요청을 보내면 된다. 그러면 콘솔에서 다음과 같은 정보를 확인할 수 있다:

```java
o.s.c.c.v.m.camel.CamelStubMessages      : Will send a message to URI [rabbitmq:output?routingKey=#&queue=output]
```

RabbitMQ management 콘솔을 확인해보면, `output` 큐에 1개의 메시지가 존재하는 것을 확인할 수 있다.