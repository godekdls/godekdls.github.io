---
title: Spring Cloud Config Server
category: Spring Cloud Config
order: 3
permalink: /Spring%20Cloud%20Config/spring-cloud-config-server/
description: 스프링 클라우드 컨피그 서버를 한글로 번역한 문서입니다. 컨피그 서버 설정 방법, environment repository(git, vault 등), 암호화 등을 설명합니다.
image: ./../../images/springcloud/logo.jpeg
lastmod: 2021-03-31T22:00:00+09:00
comments: true
originalRefName: 스프링 클라우드 컨피그
originalRefLink: https://docs.spring.io/spring-cloud-config/docs/3.0.3/reference/html/#_spring_cloud_config_server
---

### 목차

- [Environment Repository](#environment-repository)
  + [Git Backend](#git-backend)
    * [Skipping SSL Certificate Validation](#skipping-ssl-certificate-validation)
    * [Setting HTTP Connection Timeout](#setting-http-connection-timeout)
    * [Placeholders in Git URI](#placeholders-in-git-uri)
    * [Pattern Matching and Multiple Repositories](#pattern-matching-and-multiple-repositories)
    * [Authentication](#authentication)
    * [Authentication with AWS CodeCommit](#authentication-with-aws-codecommit)
    * [Authentication with Google Cloud Source](#authentication-with-google-cloud-source)
    * [Git SSH configuration using properties](#git-ssh-configuration-using-properties)
    * [Placeholders in Git Search Paths](#placeholders-in-git-search-paths)
    * [Force pull in Git Repositories](#force-pull-in-git-repositories)
    * [Git Refresh Rate](#git-refresh-rate)
  + [Version Control Backend Filesystem Use](#version-control-backend-filesystem-use)
  + [File System Backend](#file-system-backend)
  + [Vault Backend](#vault-backend)
    * [Multiple Properties Sources](#multiple-properties-sources)
  + [Accessing Backends Through a Proxy](#accessing-backends-through-a-proxy)
  + [Sharing Configuration With All Applications](#sharing-configuration-with-all-applications)
    * [File Based Repositories](#file-based-repositories)
    * [Vault Server](#vault-server)
    * [CredHub Server](#credhub-server)
  + [JDBC Backend](#jdbc-backend)
  + [Redis Backend](#redis-backend)
  + [AWS S3 Backend](#aws-s3-backend)
  + [CredHub Backend](#credhub-backend)
    * [OAuth 2.0](#oauth-20)
  + [Composite Environment Repositories](#composite-environment-repositories)
    * [Custom Composite Environment Repositories](#custom-composite-environment-repositories)
  + [Property Overrides](#property-overrides)
- [Health Indicator](#health-indicator)
- [Security](#security)
- [Encryption and Decryption](#encryption-and-decryption)
- [Key Management](#key-management)
- [Creating a Key Store for Testing](#creating-a-key-store-for-testing)
- [Using Multiple Keys and Key Rotation](#using-multiple-keys-and-key-rotation)
- [Serving Encrypted Properties](#serving-encrypted-properties)

---

스프링 클라우드 컨피그 서버는 외부 설정(이름-값 쌍이나 이와 상응하는 YAML 콘텐츠)을 조회할 수 있는 HTTP 리소스 기반 API를 제공한다. `@EnableConfigServer` 어노테이션을 사용하면 스프링 부트 어플리케이션에 컨피그 서버를 내장시킬 수 있다. 따라서 아래 어플리케이션은 컨피그 서버라고 할 수 있다:

**ConfigServer.java**

```java
@SpringBootApplication
@EnableConfigServer
public class ConfigServer {
  public static void main(String[] args) {
    SpringApplication.run(ConfigServer.class, args);
  }
}
```

모든 스프링 부트 어플리케이션이 그렇듯 기본적으로 8080 포트에서 실행되지만, 여러 가지 방법으로 좀 더 통념적인 8888 포트로 전환할 수 있다. 가장 쉬운 방법은 `spring.config.name=configserver`(컨피그 서버 jar에는 `configserver.yml`이 내장돼있다)로 기동시키 거다. 이땐 기본 설정 레포지토리도 함께 설정된다. 아니면 다음 예제처럼 자체 `application.properties`를 사용할 수도 있다:

**application.properties**

```properties
server.port: 8888
spring.cloud.config.server.git.uri: file://${user.home}/config-repo
```

여기서 `${user.home}/config-repo`는 YAML과 properties 파일들을 가지고 있는 git 레포지토리다.

> Windows에선 파일 URL이 드라이브 프리픽스가 있는 절대경로라면, 별도로 "/"가 하나 더 필요하다 (예를 들어 `file:///${user.home}/config-repo`).

> 다음은 앞의 예제에서 사용하는 git 레포지토리를 생성할 수 있는 레시피다:
>
> ```bash
> $ cd $HOME 
> $ mkdir config-repo 
> $ cd config-repo 
> $ git init . 
> $ echo info.foo: bar > application.properties 
> $ git add -A . 
> $ git commit -m "Add application.properties"
> ```

> git 레포지토리에 로컬 파일시스템을 쓰는 건 단지 테스트를 위해서다. 프로덕션에서 설정 레포지토리를 호스팅하려면 서버를 사용해야 한다.

> 설정 레포지토리에 텍스트 파일만 보관하고 있다면 초기 clone은 빠르고 효율적일 거다. 바이너리 파일, 특히 용량이 큰 파일을 저장하고 있다면, 첫 번째 설정 요청에서 지연이 생기거나 서버에서 out of memory 에러가 발생할 수도 있다.

---

## Environment Repository

컨피그 서버로 서빙할 설정 데이터는 어디에 저장해야 할까? 이 동작은 `Environment` 객체를 제공하는 `EnvironmentRepository`로 제어한다. 이 `Environment`는 스프링 `Environment`(주요 기능으로 `propertySources` 포함)의 도메인의 얕은 복사본이다. `Environment` 리소스는 다음 세 가지 변수로 파라미터를 매길 수 있다:

- `{application}` : 클라이언트 측의 `spring.application.name`에 매핑된다.
- `{profile}` : 클라이언트의 `spring.profiles.active`에 매핑된다 (콤마로 구분하는 리스트).
- `{label}` : "버전을 매긴" 설정 파일 셋에 레이블을 지정하는 서버 측 기능.

일반적으로 레포지토리 구현체는 스프링 부트 어플리케이션처럼 동작해서, `{application}` 파라미터와 일치하는 `spring.config.name`과, `{profiles}` 파라미터와 일치하는 `spring.profiles.active`에서 설정 파일을 불러온다. 프로파일과 관련한 우선 순위 규칙도 전형적인 스프링 부트 어플리케이션에서와 동일하다: 활성 프로파일이 기본값보다 우선시되며, 프로파일이 여러 개라면 마지막 프로파일이 이긴다 (`Map`에 엔트리를 추가하는 것과 비슷하다).

아래 샘플 클라이언트 어플리케이션은 이 부트스트랩 설정을 가진다:

```yaml
spring:
  application:
    name: foo
  profiles:
    active: dev,mysql
```

(보통 스프링 어플리케이션이 그렇듯, 이런 프로퍼티들은 환경 변수나 커맨드라인 인자로도 설정할 수 있다).

레포지토리가 파일 기반이라면 서버는 `application.yml`(모든 클라이언트에 공유된다)과, `foo.yml`(`foo.yml`이 우선시된다)에서 `Environment`를 생성한다. YAML 파일 안에 스프링 프로파일을 가리키는 도큐먼트가 있다면 더 높은 우선 순위로 적용된다 (나열한 프로파일 순서대로). 프로파일 별 YAML(또는 properties) 파일이 있다면 기본값보다 우선 순위가 높게 적용된다. 우선 순위가 더 높으면 `Environment`의 `PropertySource` 리스트의 앞쪽에 추가된다. (독립 실행형 스프링 부트 어플리케이션에도 이와 동일한 규칙이 적용된다.)

spring.cloud.config.server.accept-empty를 false로 설정해주면 어플리케이션을 찾을 수 없을 땐 서버에서 HTTP 상태 코드 404를 반환한다. 이 플래그는 기본적으로 true로 설정된다.

### Git Backend

`EnvironmentRepository`의 기본 구현체는 버전업이나 실제 환경을 관리하고, 변경 사항을 알아내기 매우 편리한 Git 백엔드를 사용한다. 레포지토리 위치를 변경하려면 컨피그 서버에서 `spring.cloud.config.server.git.uri` 설정 프로퍼티를 설정하면 된다 (ex. `application.yml`). `file:` 프리픽스를 사용해서 설정하면 로컬 레포지토리에서 설정을 가져오기 때문에, 서버없이 쉽고 빠르게 시작해볼 수 있다. 하지만 이땐 서버는 레포지토리를 클론하지 않고 로컬 레포지토리에서 직접 동작한다 (컨피그 서버는 "리모트" 레포지토리를 변경하지 않기 때문에, bare 레포지토리가 아니어도 상관 없다). 컨피그 서버를 확장해 가용성을 높이기 위해선 서버의 모든 인스턴스가 같은 레포지토리를 가리켜야 하므로, 공유 파일시스템이 필요하다. 단, 이때도 공유 파일시스템 레포지토리에 `ssh:` 프로토콜을 사용해 서버가 레포지토리를 클론하고 로컬 복사본을 캐시로 사용하도록 두는 게 좋다.

이 레포지토리 구현체는 HTTP 리소스의 `{label}` 파라미터를 git 레이블(커밋 id나 브랜치 이름 또는 태그)에 매핑한다. git 브랜치나 태그명에 슬래시(`/`)가 있다면 HTTP URL에선 레이블에 슬래시 대신 특수 문자열 `(_)`을 명시해야 한다 (그래야 다른 URL 경로와 구분된다). 예를 들어 레이블이 `foo/bar`라면, 슬래시를 치환하면 `foo(_)bar`가 된다. 특수 문자열 `(_)`은 `{application}` 파라미터에도 적용할 수 있다. curl같은 커맨드라인 클라이언트에선 URL에 있는 괄호 사용에 주의해라 — 쉘에선 작은 따옴표('')를 사용해 이스케이프해야 한다.

#### Skipping SSL Certificate Validation

설정 서버에서 `git.skipSslValidation` 프로퍼티를 `true`(기본값은 `false`)로 설정하면, Git 서버의 SSL 인증서 유효성 검사를 비활성화할 수 있다.

```yaml
spring:
  cloud:
    config:
      server:
        git:
          uri: https://example.com/my/repo
          skipSslValidation: true
```

#### Setting HTTP Connection Timeout

설정 서버가 HTTP 커넥션 획득을 위해 대기할 시간(초 단위)을 설정할 수 있다. `git.timeout` 프로퍼티를 사용한다.

```yaml
spring:
  cloud:
    config:
      server:
        git:
          uri: https://example.com/my/repo
          timeout: 4
```

#### Placeholders in Git URI

스프링 클라우드 컨피그 서버는 git 레포지토리 URL에 `{application}`과 `{profile}`을 위한 (필요하다면 `{label}`도 가능하지만, 어쨌거나 레이블은  git 레이블로 적용된다는 점을 명심해라) 플레이스홀더를 지원한다. 따라서 아래과 유사한 구조를 사용하면, "어플리케이션 당 하나의 레포지토리"라는 정책을 지원할 수 있다:

```yaml
spring:
  cloud:
    config:
      server:
        git:
          uri: https://github.com/myorg/{application}
```

유사한 패턴에 `{profile}`을 사용하면 "프로파일 당 하나의 레포지토리" 정책도 지원할 수 있다.

더 나아가, 아래 예제처럼 `{application}` 파라미터 내에 특수 문자열 "(\_)"을 사용하면 여러 organization을 지원하는 것도 가능하다:

```yaml
spring:
  cloud:
    config:
      server:
        git:
          uri: https://github.com/{application}
```

여기서 `{application}`은 요청 시점에 `organization(_)application` 형식으로 제공된다.

#### Pattern Matching and Multiple Repositories

스프링 클라우드 컨피그에선 어플리케이션이나 프로파일명에 패턴을 매칭해 좀 더 복잡한 요구 사항도 지원할 수 있다. 패턴 형식은 다음 예제에 보이듯, 와일드카드를 가진 (와일드카드로 시작하는 패턴은 따옴표로 묶어야 할 수도 있다는 것에 주의) `{application}/{profile}` 이름 리스트로, 콤마로 구분한다.

```yaml
spring:
  cloud:
    config:
      server:
        git:
          uri: https://github.com/spring-cloud-samples/config-repo
          repos:
            simple: https://github.com/simple/config-repo
            special:
              pattern: special*/dev*,*special*/dev*
              uri: https://github.com/special/config-repo
            local:
              pattern: local*
              uri: file:/home/configsvc/config-repo
```

`{application}/{profile}`이 어떤 패턴과도 매칭되지 않으면 `spring.cloud.config.server.git.uri`에 정의된 디폴트 URI를 사용한다. 위에 보이는 예제에선 "simple" 레포지토리에서의 패턴은 `simple/*`이다 (모든 프로파일이 `simple`이란 이름의 어플리케이션 하나로 매칭된다). "local" 레포지토리에선 모든 프로파일에서 `local`로 시작하는 모든 어플리케이션명과 매칭된다 (프로파일 matcher가 없는 패턴엔 `/*` suffix가 자동으로 추가된다).

> 이 예제에 있는 "simple"은 프로퍼티를 간단히 한 줄로만 표현했는데, 설정할 유일한 프로퍼티가 URI일 때만 가능하다. 다른 항목(credentials, pattern 등)을 설정해야 한다면 전체 양식을 사용해야 한다.

repo의 `pattern` 프로퍼티는 실제론 배열이므로, YAML 배열(또는 properties 파일에서의 `[0]`, `[1]` 등의 suffix)을 통해 여러 개의 패턴을 바인딩할 수 있다. 다음 예제처럼 여러 프로파일로 앱을 실행하려 한다면 이 방법이 필요할 거다:

```yaml
spring:
  cloud:
    config:
      server:
        git:
          uri: https://github.com/spring-cloud-samples/config-repo
          repos:
            development:
              pattern:
                - '*/development'
                - '*/staging'
              uri: https://github.com/development/config-repo
            staging:
              pattern:
                - '*/qa'
                - '*/production'
              uri: https://github.com/staging/config-repo
```

> 스프링 클라우드는 패턴에 있는 프로파일이 `*`로 끝나지 않으면, 이 패턴으로 시작하는 프로파일 리스트를 매칭하고자 한 것으로 짐작한다 (따라서 `*/staging`은 `["*/staging", "*/staging,*"]` 등의 간소화된 표현이다). 프로파일별 매칭은 어플리케이션을 "development" 프로파일에선 로컬로, "cloud" 프로파일에선 리모트로 실행해야 하는 경우 등에 흔히 사용한다.
>

모든 레포지토리는 원한다면 설정 파일을 하위 디렉토리에도 저장할 수 있으며, 해당 디렉토리를 검색하기 위한 패턴은 `searchPaths`로 지정할 수 있다. 다음 예제는 최상위 레벨에 있는 설정 파일을 보여준다:

```yaml
spring:
  cloud:
    config:
      server:
        git:
          uri: https://github.com/spring-cloud-samples/config-repo
          searchPaths: foo,bar*
```

위 예제에서 서버는 최상위 레벨과, 하위 디렉토리 `foo/`, 그리고 `bar`로 시작하는 모든 하위 디렉토리에서 설정 파일을 검색한다.

서버는 기본적으로 설정을 처음 요청할 때 리모트 레포지토리를 클론한다. 다음 최상위 레벨 예제와 같이, 기동 시 레포지토리를 클론하도록 서버를 설정할 수 있다:

```yaml
spring:
  cloud:
    config:
      server:
        git:
          uri: https://git/common/config-repo.git
          repos:
            team-a:
                pattern: team-a-*
                cloneOnStart: true
                uri: https://git/team-a/config-repo.git
            team-b:
                pattern: team-b-*
                cloneOnStart: false
                uri: https://git/team-b/config-repo.git
            team-c:
                pattern: team-c-*
                uri: https://git/team-a/config-repo.git
```

위 예제에서 서버는 요청을 수락하기 전 먼저, 기동 시 team-a의 config-repo를 클론한다. 그 외 다른 모든 레포지토리는 해당 레포지토리로 설정을 요청할 때까진 클론하지 않는다.

> 컨피그 서버를 기동할 때 클론할 레포지토리를 설정한다면, 기동 시점에 잘못 지정한 설정 소스(유효하지 않은 레포지토리 URI 등)를 빠르게 식별할 수 있다. 설정 소스에 `cloneOnStart`를 활성화하지 않았다면, 컨피그 서버는 잘못 설정했거나 유효하지 않은 설정 소스가 있어도 기동에 성공할 수 있으며, 어플리케이션이 해당 설정 소스로 설정을 요청하기 전엔 오류를 감지하지 못할 거다.

#### Authentication

리모트 레포지토리에서 HTTP 기본 인증을 사용하려면, 다음 예제와 같이 `username`과 `password` 프로퍼티를 별도로 추가해라 (URL 안에 넣는 게 아니다):

```yaml
spring:
  cloud:
    config:
      server:
        git:
          uri: https://github.com/spring-cloud-samples/config-repo
          username: trolley
          password: strongpassword
```

HTTPS와 user credential을 사용하지 않을 땐, 디폴트 디렉토리(`~/.ssh`)에 키를 저장하고, URI가 `git@github.com:configuration/cloud-configuration`같은 SSH 위치를 가리키면 SSH도 바로 사용할 수 있다. 단, Git 서버에 대한 항목이 `~/.ssh/known_hosts` 파일에 `ssh-rsa` 포맷으로 존재해야 한다. 다른 포맷(`ecdsa-sha2-nistp256` 등)은 지원하지 않는다.  `known_hosts` 파일에 Git 서버에 대한 항목은 하나만 있고, 컨피그 서버에 제공한 URL과 일치하는지 먼저 확인하는 게 좋다. URL에 호스트명을 사용한다면 `known_hosts` 파일에 IP가 아닌 정확한 호스트명이 있어야 한다. 레포지토리는 JGit을 사용해 액세스하므로, 해당 레포지토리에 있는 문서는 모두 적용할 수 있다. HTTPS 프록시 설정은 `~/.git/config`나 (다른 JVM 프로세스와 동일한 방식으로) 시스템 프로퍼티(`-Dhttps.proxyHost`와 `-Dhttps.proxyPort`)로 설정할 수 있다.

> `~/.git` 디렉토리가 어디 있는지 모르겠다면, `git config --global`을 사용해 설정을 다룰 수 있다 (예를 들어 `git config --global http.sslVerify false`).

JGit은 PEM 형식의 RSA 키가 필요하다. 다음은 알맞은 포맷으로 키를 생성해주는 ssh-keygen (openssh로) 명령어 예시다:

```bash
ssh-keygen -m PEM -t rsa -b 4096 -f ~/config_server_deploy_key.rsa
```

주의: SSH 키를 사용하려면 ssh private-key는 `-----BEGIN RSA PRIVATE KEY-----`로 시작해야 한다. 이 키가 `-----BEGIN OPENSSH PRIVATE KEY-----`로 시작하면 spring-cloud-config 서버는 기동 시 RSA 키를 로드하지 않는다. 이때 에러는 다음과 같다:

```java
- Error in object 'spring.cloud.config.server.git': codes [PrivateKeyIsValid.spring.cloud.config.server.git,PrivateKeyIsValid]; arguments [org.springframework.context.support.DefaultMessageSourceResolvable: codes [spring.cloud.config.server.git.,]; arguments []; default message []]; default message [Property 'spring.cloud.config.server.git.privateKey' is not a valid private key]
```

위 에러를 해결하려면 반드시 RSA 키를 PEM 형식으로 변환해야 한다. 적절한 형식으로 새 키를 생성하는 법은 위에 있는 openssh를 사용하는 예제를 참고해라.

#### Authentication with AWS CodeCommit

스프링 클라우드 컨피그 서버는 [AWS CodeCommit](https://docs.aws.amazon.com/codecommit/latest/userguide/welcome.html) 인증도 지원한다. 커맨드라인에서 Git을 사용할 때 AWS CodeCommit은 인증 헬퍼를 사용한다. JGit 라이브러리는 이 헬퍼를 직접 지원하지 않기 때문에, Git URI가 AWS CodeCommit 패턴과 매칭되면 AWS CodeCommit을 위한 JGit CredentialProvider가 하나 만들어진다. AWS CodeCommit URI는 이 패턴을 따른다:

```bash
https//git-codecommit.${AWS_REGION}.amazonaws.com/v1/repos/${repo}.
```

AWS CodeCommit URI와 함께 username과 password를 제공할 거라면, 이 값은 반드시 이 레포지토리에 대한 액세스를 제공하는 [AWS accessKeyId와 secretAccessKey](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSGettingStartedGuide/AWSCredentials.html)여야 한다. username과 password를 지정하지 않으면 [AWS 디폴트 Credential Provider 체인](https://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/credentials.html)을 사용해 accessKeyId와 secretAccessKey를 가져온다.

> `aws-java-sdk-core` jar는 필수 의존성은 아니다. 클래스패스에 `aws-java-sdk-core` jar가 없으면, git 서버 URI에 관계없이 AWS Code Commit credential provider를 생성하지 않는다.

#### Authentication with Google Cloud Source

스프링 클라우드 컨피그 서버는 [Google Cloud Source](https://cloud.google.com/source-repositories/) 레포지토리를 위한 인증도 지원한다.

Git URI가 `http`나 `https` 프로토콜을 사용하면서 도메인명이 `source.developers.google.com`라면 Google Cloud Source credentials provider를 사용한다. Google Cloud Source 레포지토리 URI 포맷은 `https://source.developers.google.com/p/${GCP_PROJECT}/r/${REPO}`다. 레포지토리의 URI를 얻으려면 Google Cloud Source UI에서 "Clone"을 클릭하고, "Manually generated credentials"를 선택해라. credential은 생성하지 말고, 표기된 URI를 복사하기만 하면 된다.

Google Cloud Source credentials provider는 구글 클라우드 플랫폼 어플리케이션 디폴트 credentials를 사용한다. 시스템의 어플리케이션 디폴트 credential을 만드는 방법은 [Google Cloud SDK 문서](https://cloud.google.com/sdk/gcloud/reference/auth/application-default/login)를 참고해라. 이 방식은 개발 환경의 사용자 계정과 프로덕션 환경의 서비스 계정에서 동작한다.

> `com.google.auth:google-auth-library-oauth2-http`는 필수 의존성은 아니다. 클래스패스에  `google-auth-library-oauth2-http` jar가 없으면, git 서버 URI에 관계없이 Google Cloud Source credential provider를 생성하지 않는다.

#### Git SSH configuration using properties

스프링 클라우드 컨피그 서버에서 사용하는 JGit 라이브러리는 기본적으로 SSH URI로 Git 레포지토리에 접속할 땐 `~/.ssh/known_hosts`, `/etc/ssh/ssh_config`같은 SSH 설정 파일을 사용한다. 하지만 Cloud Foundry같은 클라우드 환경에선 로컬 파일 시스템은 일시적(ephemeral)이거나, 쉽게 액세스할 수 없을 거다. 이럴땐 자바 프로퍼티를 통해 SSH 설정을 세팅할 수 있다. 프로퍼티 기반 SSH 설정을 활성화하려면, 다음 예제처럼 `spring.cloud.config.server.git.ignoreLocalSshSettings` 프로퍼티를 `true`로 설정해야 한다:

```yaml
spring:
  cloud:
    config:
      server:
        git:
          uri: git@gitserver.com:team/repo1.git
          ignoreLocalSshSettings: true
          hostKey: someHostKey
          hostKeyAlgorithm: ssh-rsa
          privateKey: |
                       -----BEGIN RSA PRIVATE KEY-----
                       MIIEpgIBAAKCAQEAx4UbaDzY5xjW6hc9jwN0mX33XpTDVW9WqHp5AKaRbtAC3DqX
                       IXFMPgw3K45jxRb93f8tv9vL3rD9CUG1Gv4FM+o7ds7FRES5RTjv2RT/JVNJCoqF
                       ol8+ngLqRZCyBtQN7zYByWMRirPGoDUqdPYrj2yq+ObBBNhg5N+hOwKjjpzdj2Ud
                       1l7R+wxIqmJo1IYyy16xS8WsjyQuyC0lL456qkd5BDZ0Ag8j2X9H9D5220Ln7s9i
                       oezTipXipS7p7Jekf3Ywx6abJwOmB0rX79dV4qiNcGgzATnG1PkXxqt76VhcGa0W
                       DDVHEEYGbSQ6hIGSh0I7BQun0aLRZojfE3gqHQIDAQABAoIBAQCZmGrk8BK6tXCd
                       fY6yTiKxFzwb38IQP0ojIUWNrq0+9Xt+NsypviLHkXfXXCKKU4zUHeIGVRq5MN9b
                       BO56/RrcQHHOoJdUWuOV2qMqJvPUtC0CpGkD+valhfD75MxoXU7s3FK7yjxy3rsG
                       EmfA6tHV8/4a5umo5TqSd2YTm5B19AhRqiuUVI1wTB41DjULUGiMYrnYrhzQlVvj
                       5MjnKTlYu3V8PoYDfv1GmxPPh6vlpafXEeEYN8VB97e5x3DGHjZ5UrurAmTLTdO8
                       +AahyoKsIY612TkkQthJlt7FJAwnCGMgY6podzzvzICLFmmTXYiZ/28I4BX/mOSe
                       pZVnfRixAoGBAO6Uiwt40/PKs53mCEWngslSCsh9oGAaLTf/XdvMns5VmuyyAyKG
                       ti8Ol5wqBMi4GIUzjbgUvSUt+IowIrG3f5tN85wpjQ1UGVcpTnl5Qo9xaS1PFScQ
                       xrtWZ9eNj2TsIAMp/svJsyGG3OibxfnuAIpSXNQiJPwRlW3irzpGgVx/AoGBANYW
                       dnhshUcEHMJi3aXwR12OTDnaLoanVGLwLnkqLSYUZA7ZegpKq90UAuBdcEfgdpyi
                       PhKpeaeIiAaNnFo8m9aoTKr+7I6/uMTlwrVnfrsVTZv3orxjwQV20YIBCVRKD1uX
                       VhE0ozPZxwwKSPAFocpyWpGHGreGF1AIYBE9UBtjAoGBAI8bfPgJpyFyMiGBjO6z
                       FwlJc/xlFqDusrcHL7abW5qq0L4v3R+FrJw3ZYufzLTVcKfdj6GelwJJO+8wBm+R
                       gTKYJItEhT48duLIfTDyIpHGVm9+I1MGhh5zKuCqIhxIYr9jHloBB7kRm0rPvYY4
                       VAykcNgyDvtAVODP+4m6JvhjAoGBALbtTqErKN47V0+JJpapLnF0KxGrqeGIjIRV
                       cYA6V4WYGr7NeIfesecfOC356PyhgPfpcVyEztwlvwTKb3RzIT1TZN8fH4YBr6Ee
                       KTbTjefRFhVUjQqnucAvfGi29f+9oE3Ei9f7wA+H35ocF6JvTYUsHNMIO/3gZ38N
                       CPjyCMa9AoGBAMhsITNe3QcbsXAbdUR00dDsIFVROzyFJ2m40i4KCRM35bC/BIBs
                       q0TY3we+ERB40U8Z2BvU61QuwaunJ2+uGadHo58VSVdggqAo0BSkH58innKKt96J
                       69pcVH/4rmLbXdcmNYGm6iu+MlPQk4BUZknHSmVHIFdJ0EPupVaQ8RHT
                       -----END RSA PRIVATE KEY-----
```

다음은 SSH 설정 프로퍼티를 설명하는 테이블이다.

| Property Name                | Remarks                                                      |
| :--------------------------- | :----------------------------------------------------------- |
| **ignoreLocalSshSettings**   | `true`일 땐 파일 기반 SSH 설정 대신 프로퍼티 기반 설정을 사용한다. 레포지토리 정의 내부가 **아니라** `spring.cloud.config.server.git.ignoreLocalSshSettings`로 설정해야 한다. |
| **privateKey**               | 유효한 SSH private 키. `ignoreLocalSshSettings`를 true로 설정했고 Git URI가 SSH 형식이라면 반드시 설정해야 한다. |
| **hostKey**                  | 유효한 SSH 호스트 키. `hostKeyAlgorithm`도 설정했다면 반드시 설정해야 한다. |
| **hostKeyAlgorithm**         | `ssh-dss`, `ssh-rsa`, `ecdsa-sha2-nistp256`, `ecdsa-sha2-nistp384`, `ecdsa-sha2-nistp521` 중 하나. `hostKey`도 설정했다면 반드시 설정해야 한다. |
| **strictHostKeyChecking**    | `true` 또는 `false`. false라면 호스트 키 관련 에러는 무시한다. |
| **knownHostsFile**           | 커스텀 `.known_hosts` 파일 위치.                             |
| **preferredAuthentications** | 서버 인증 방식의 순서를 재정의한다. 서버가 `publickey` 방식에 앞서 keyboard-interactive 인증을 가지고 있다면 로그인 프롬프트를 회피할 수 있도록 만들어야 한다. |

#### Placeholders in Git Search Paths

스프링 클라우드 컨피그 서버는 다음 예제와 같이, 검색 경로에도 `{application}`과 `{profile}`을 위한 (필요하다면 `{label}`도) 플레이스홀더를 지원한다:

```yaml
spring:
  cloud:
    config:
      server:
        git:
          uri: https://github.com/spring-cloud-samples/config-repo
          searchPaths: '{application}'
```

위 예제는 레포지토리에서 이름이 동일한 디렉토리에 있는 파일을 찾는다 (최상위 레벨도 함께). 검색 경로에서 플레이스홀더를 쓸 땐 와일드카드도 사용할 수 있다 (매칭되는 모든 디렉토리를 검색한다).

#### Force pull in Git Repositories

앞서 언급했듯, 스프링 클라우드 컨피그 서버는 리모트 git 레포지토리를 클론해온다. 하지만 로컬 복사본이 오염된다면 리모트 레포지토리로 로컬 복사본을 업데이트하지 못할 수도 있다 (예를 들어, OS 프로세스에 의해 폴더 내용이 변경될 수 있다).

이 문제는 다음 예제에 보이는 `force-pull` 프로퍼티로 해결할 수 있다. 이 프로퍼티는 로컬 복사본이 오염되면 스프링 클라우드 컨피그 서버가 리모트 레포지토리에서 강제로 pull받게 만든다:

```yaml
spring:
  cloud:
    config:
      server:
        git:
          uri: https://github.com/spring-cloud-samples/config-repo
          force-pull: true
```

레포지토리 설정이 여러 개라면, 다음 예제처럼 레포지토리 단위에 `force-pull` 프로퍼티를 설정할 수 있다:

```yaml
spring:
  cloud:
    config:
      server:
        git:
          uri: https://git/common/config-repo.git
          force-pull: true
          repos:
            team-a:
                pattern: team-a-*
                uri: https://git/team-a/config-repo.git
                force-pull: true
            team-b:
                pattern: team-b-*
                uri: https://git/team-b/config-repo.git
                force-pull: true
            team-c:
                pattern: team-c-*
                uri: https://git/team-a/config-repo.git
```

> `force-pull` 프로퍼티의 기본값은 `false`다.

#### Deleting untracked branches in Git Repositories

브랜치를 로컬 레포지토리로 체크 아웃하고 나면 (레이블을 통해 프로퍼티를 조회했을 때 등), 스프링 클라우드 컨피그 서버엔 리모트 git 레포지토리의 복사본이 생기게 되므로, 이 브랜치는 영원히 남아있거나, 다음 서버 재기동 때까지 (새 로컬 레포지토리를 생성할 때까지) 유지된다. 그렇기 때문에 리모트 브랜치는 삭제되도 로컬 복사본에선 여전히 조회되는 상황이 발생할 수 있다. 이 상황에서 스프링 클라우드 컨피그 서버의 클라이언트 서비스를 `--spring.cloud.config.label=deletedRemoteBranch,master`로 기동하면, 프로퍼티를 로컬 브랜치 `deletedRemoteBranch`에서 가져오고, `master`에서는 가져 오지 않게된다.

`deleteUntrackedBranches` 프로퍼티를 설정하면 로컬 레포지토리 브랜치를 리모트 레포지토리와 같은 깨끗한 상태로 유지할 수 있다. 이렇게 하면 스프링 클라우드 컨피그 서버는 로컬 레포지토리에서 추적되지 않는(untracked) 브랜치를 **강제로** 삭제한다:

```yaml
spring:
  cloud:
    config:
      server:
        git:
          uri: https://github.com/spring-cloud-samples/config-repo
          deleteUntrackedBranches: true
```

> `deleteUntrackedBranches` 프로퍼티의 기본값은 `false`다.

#### Git Refresh Rate

컨피그 서버가 Git 백엔드에서 업데이트된 설정 데이터를 가져오는 간격은 `spring.cloud.config.server.git.refreshRate`로 제어할 수 있다. 이 프로퍼티 값은 초 단위로 지정한다. 기본값은 0으로, 컨피그 서버는 요청 시마다 Git 저장소에서 업데이트된 설정을 가져온다.

### Version Control Backend Filesystem Use

> VCS 기반 백엔드(git, svn)를 사용하면, 파일들을 로컬시스템에 체크 아웃받거나 복제하게 된다. 기본적으로는 `config-repo-` 프리픽스와 함께 시스템 임시 디렉토리에 저장된다. 예를 들어 리눅스에서는 `/tmp/config-repo-<randomid>` 등에 저장된다. 하지만 일부 운영 체제는 [정기적으로 임시 디렉토리를 정리](https://serverfault.com/questions/377348/when-does-tmp-get-cleared/377349#377349)한다. 이로 인해 프로퍼티가 유실되는 등 예기치 못한 상황이 발생할 수 있다. 이 문제를 방지하려면 `spring.cloud.config.server.git.basedir` 또는 `spring.cloud.config.server.svn.basedir`을 시스템 임시 구조에 속하지 않는 디렉토리로 설정해, 컨피그 서버에서 사용할 디렉토리를 변경해라.

### File System Backend

컨피그 서버에는 Git을 사용하지 않지만, 로컬 클래스패스나 파일시스템에서 (`spring.cloud.config.server.native.searchLocations`로 가리키는 모든 정적 URL) 설정 파일을 로드하는 "native" 프로파일도 존재한다. 이 native 프로파일을 사용하려면 컨피그 서버를 `spring.profiles.active=native`로 시작해라.

> 파일 리소스엔 `file:` 프리픽스를 추가하는 걸 잊지마라 (프리픽스가 없을 때 기본값은 보통 클래스패스다). 다른 스프링 부트 설정과 마찬가지로 `${}` 스타일의 environment 플레이스홀더를 포함할 수 있지만, Windows의 절대 경로에는 `/`가 추가로 하나 더 필요하다 (예를 들어 `file:///${user.home}/config-repo`).

> `searchLocations`의 기본값은 로컬 스프링 부트 어플리케이션과 동일하다 (즉, `[classpath:/, classpath:/config, file:./, file:./config]`). 이때 서버에 존재하는 모든 프로퍼티 소스는 클라이언트로 전송하기 전에 제거하기 때문에, 서버의 `application.properties`는 클라이언트에 노출되지 않는다.

> 파일시스템 백엔드는 빠르게 시작하고 테스트해보는 데 적합하다. 프로덕션에서 사용하려면 신뢰할 수 있으며, 모든 컨피그 서버 인스턴스에 공유할 수 있는 파일시스템인지 확인해볼 필요가 있다.

`searchLocations`엔 `{application}`, `{profile}`, `{label}`을 위한 플레이스홀더를 사용할 수 있다. 플레이스홀더를 잘 활용하면 경로 내 디렉토리를 분리하고, 요구사항에 맞는 적합한 전략을 취할 수 있다 (어플리케이션 단위나 프로파일 단위로 하위 디렉토리를 구분하는 등).

이 레포지토리는 `searchLocations`에 플레이스홀더를 사용 않을 땐 HTTP 리소스의 `{label}` 파라미터를 검색 경로 suffix에 함께 추가한다. 따라서 모든 검색 위치와, 레이블과 이름이 같은 하위 디렉토리에서도 **함께** 프로퍼티 파일을 찾아 로드한다 (스프링 Environment에선 레이블된 프로퍼티를 우선시한다). 따라서 플레이스홀더가 없을 때의 기본 동작은 `/{label}/`로 끝나는 검색 위치를 추가했을 때와 동일하다. 예를 들어 `file:/tmp/config`는 `file:/tmp/config,file:/tmp/config/{label}`과 동일하다. 이 동작은 `spring.cloud.config.server.native.addLabelLocations=false`를 설정하면 비활성화할 수 있다.

### Vault Backend

스프링 클라우드 컨피그 서버는 백엔드로 [Vault](https://www.vaultproject.io/)도 지원한다.

> Vault는 시크릿에 안전하게 액세스할 수 있게 도와주는 툴이다. 시크릿은 API 키, 비밀번호, 인증서나 다른 민감한 정보 등, 접근을 엄격하게 제어하길 원하는 것이라면 어떤 것이든 될 수 있다. Vault는 모든 시크릿에 대한 통합 인터페이스를 제공하며, 동시에 접근을 엄격히 제어할 수 있으며, 상세한 감사 로그를 기록해준다.

Vault에 대한 자세한 정보는 [Vault 퀵스타트 가이드](https://learn.hashicorp.com/vault/?track=getting-started#getting-started)를 참고해라.

컨피그 서버에서 Vault 백엔드를 사용하려면 vault 프로파일을 사용해 컨피그 서버를 실행하면 된다. 예를 들어서, 컨피그 서버의 `application.properties`에 `spring.profiles.active=vault`를 추가하면 된다.

컨피그 서버는 기본적으로 Vault 서버를 `http://127.0.0.1:8200`에서 실행한다고 가정한다. 또한 백엔드 이름은 `secret`, 키는 `application`이라고 가정한다. 이런 기본값들은 모두 컨피그 서버의 `application.properties`로 설정할 수 있다. 다음은 설정이 가능한 Vault 프로퍼티들을 담고있는 테이블이다:

| Name              | Default Value |
| :---------------- | :------------ |
| host              | 127.0.0.1     |
| port              | 8200          |
| scheme            | http          |
| backend           | secret        |
| defaultKey        | application   |
| profileSeparator  | ,             |
| kvVersion         | 1             |
| skipSslValidation | false         |
| timeout           | 5             |
| namespace         | null          |

> 이 테이블에 있는 모든 프로퍼티는 `spring.cloud.config.server.vault`로 시작해야 한다. 혹은 composite 설정을 사용한다면 적절한 Vault 섹션에 배치해야 한다.
>

설정가능한 모든 프로퍼티는 `org.springframework.cloud.config.server.environment.VaultEnvironmentProperties`에서 확인할 수 있다.

> Vault 0.10.0은 이전 버전과는 다른 API를 노출하는, 버전화된 key-value 백엔드(k/v 백엔드 버전 2)를 도입했다. 이제 마운트 경로와 실제 컨텍스트 경로 사이에 `data/`가 필요하며, 시크릿을 `data` 객체에 래핑한다. `spring.cloud.config.server.vault.kv-version=2`를 설정하면 이를 반영해준다.

원한다면 Vault 엔터프라이즈 `X-Vault-Namespace` 헤더에 대한 지원을 활용할 수 있다. Vault로 이 헤더를 보내려면 `namespace` 프로퍼티를 설정해라.

컨피그 서버가 실행 중이라면, 서버에 HTTP 요청을 보내 Vault 백엔드로부터 값을 조회할 수 있다. 이렇게 하려면 Vault 서버용 토큰이 필요하다.

먼저, 다음 예제처럼 Vault에 몇 가지 데이터를 배치한다:

```sh
$ vault kv put secret/application foo=bar baz=bam
$ vault kv put secret/myapp foo=myappsbar
```

그 다음, 다음 예제처럼 컨피그 서버에 HTTP 요청을 보내 이 값들을 조회한다:

```bash
$ curl -X "GET" "http://localhost:8888/myapp/default" -H "X-Config-Token: yourtoken"
```

그러면 아래와 유사한 응답을 볼 수 있을 거다:

```json
{
   "name":"myapp",
   "profiles":[
      "default"
   ],
   "label":null,
   "version":null,
   "state":null,
   "propertySources":[
      {
         "name":"vault:myapp",
         "source":{
            "foo":"myappsbar"
         }
      },
      {
         "name":"vault:application",
         "source":{
            "baz":"bam",
            "foo":"bar"
         }
      }
   ]
}
```

컨피그 서버가 Vault와 통신할 수 있도록, 클라이언트에서 필요한 인증을 제공하는 기본 방법은 X-Config-Token 헤더 설정이다. 물론 이 방법 대신, 스프링 클라우드 볼트와 동일한 설정 프로퍼티를 사용해 서버에다 인증을 설정하면, 클라이언트에선 헤더를 생략할 수 있다. 설정해야 하는 프로퍼티는 `spring.cloud.config.server.vault.authentication`이다. 이 프로퍼티엔 지원되는 인증 방법 중 하나를 설정해야 한다. 사용하는 인증 방법에 따라 별도 전용 프로퍼티를 설정해야 할 수도 있다. 이땐 `spring.cloud.vault`에 문서화된 것과 동일한 프로퍼티명을 사용하돼, `spring.cloud.config.server.vault` 프리픽스를 사용한다. 자세한 내용은 [스프링 클라우드 볼트 레퍼런스 가이드](https://cloud.spring.io/spring-cloud-vault/reference/html/#vault.config.authentication) 참고해라.

> X-Config-Token 헤더를 생략하고 서버 프로퍼티를 통해 인증을 설정하는 경우엔, 컨피그 서버 어플리케이션에서 추가 인증 옵션을 활성화하려면 Spring Vault 의존성이 별도로 필요하다. 의존성을 추가하는 방법은 [Spring Vault 레퍼런스 가이드](https://docs.spring.io/spring-vault/docs/current/reference/html/#dependencies)를 참고해라.

#### Multiple Properties Sources

Vault를 사용할 땐 어플리케이션에 여러 가지 프로퍼티 소스를 제공할 수 있다. 예를 들어 Vault에서 아래와 같은 경로에 데이터를 기록했다고 가정해보자:

```
secret/myApp,dev
secret/myApp
secret/application,dev
secret/application
```

`secret/application`에 기록한 프로퍼티는 [컨피그 서버를 사용하는 모든 어플리케이션](#vault-server)에서 사용할 수 있다. 이름이 `myApp`인 어플리케이션은 `secret/myApp`과 `secret/application`에 기록된 모든 프로퍼티를 조회할 수 있다. `myApp`에서 `dev` 프로파일을 활성화하면, 위에 있는 모든 경로에 기록한 프로퍼티를 활용할 수 있으며, `secret/myApp,dev`에 있는 프로퍼티를 제일 우선시한다.

### Accessing Backends Through a Proxy

컨피그 서버는 Git, Vault 백엔드에 접근할 때 HTTP나 HTTPS 프록시를 경유할 수 있다. 이 동작은 Git이나 Vault에서 `proxy.http`, `proxy.https`를 설정해 제어한다. 이 설정들은 레포지토리별로 적용되므로, [composite environment repository](#composite-environment-repositories)를 사용한다면 각 백엔드마다 개별로 프록시 설정을 구성해야 한다. HTTP, HTTPS URL에 별도 프록시 서버가 필요한 네트워크를 사용하고 있다면, 단일 백엔드에 HTTP와 HTTPS 프록시 설정을 모두 구성할 수 있다.

다음은 HTTP 및 HTTPS 프록시와 관련한 프록시 설정 프로퍼티를 담고있는 테이블이다. 이 프로퍼티들은 모두 `proxy.http` 또는 `proxy.https`로 시작해야 한다.

| Property Name     | Remarks                                                      |
| :---------------- | :----------------------------------------------------------- |
| **host**          | 프록시 호스트.                                               |
| **port**          | 프록시에 접근할 때 사용할 포트.                              |
| **nonProxyHosts** | 설정 서버가 프록시 없이 접근해야 하는 모든 호스트. `proxy.http.nonProxyHosts`와 `proxy.https.nonProxyHosts`를 둘 다 사용하면 `proxy.http`에 있는 값을 사용한다. |
| **username**      | 프록시에 인증할 때 사용할 username. `proxy.http.username`과 `proxy.https.username`을 둘 다 사용하면 `proxy.http`에 있는 값을 사용한다. |
| **password**      | 프록시에 인증할 때 사용할 password. `proxy.http.password`와 `proxy.https.password`를 둘 다 사용하면 `proxy.http`에 있는 값을 사용한다. |

아래 설정은 HTTPS 프록시를 사용해 Git 레포지토리에 접근한다.

```yaml
spring:
  profiles:
    active: git
  cloud:
    config:
      server:
        git:
          uri: https://github.com/spring-cloud-samples/config-repo
          proxy:
            https:
              host: my-proxy.host.io
              password: myproxypassword
              port: '3128'
              username: myproxyusername
              nonProxyHosts: example.com
```

### Sharing Configuration With All Applications

모든 어플리케이션에 설정을 공유하는 건 아래 토픽에서도 설명하지만, 사용하는 백엔드에 따라 달라진다:

- [파일 기반 레포지토리](#file-based-repositories)
- [Vault 서버](#vault-server)
- [CredHub 서버](#credhub-server)

#### File Based Repositories

파일 기반(git, svn, native) 레포지토리를 사용할 땐, 파일 이름이 `application*`(`application.properties`, `application.yml`, `application-*.properties` 등) 중 하나면 해당 리소스는 모든 클라이언트 어플리케이션에 공유된다. 이런 파일명을 가진 리소스를 활용하면 전역 기본값을 구성하고, 필요에 따라 어플리케이션 전용 파일로 재정의할 수 있다.

[프로퍼티 overrides](#property-overrides) 기능도 전역 기본값을 설정할 때 활용할 수 있으며, 어플리케이션에선 플레이스홀더를 통해 로컬 값을 재정의할 수 있다.

> "native" 프로파일(로컬 파일 시스템 백엔드)을 사용하는 경우, 서버 자체 설정에 속하지 않는 검색 위치를 명시해야 한다. 기본 검색 위치에 있는 `application*` 리소스는 서버의 일부이기 때문에 제거돼 공유되지 않는다.

#### Vault Server

Vault를 백엔드로 사용할 때는 `secret/application`에 배치한 설정은 모든 어플리케이션에 공유할 수 있다. 예를 들어서, 아래 Vault 명령어를 실행하면 컨피그 서버를 사용하는 모든 어플리케이션이 `foo`, `baz` 프로퍼티를 사용할 수 있다:

```sh
$ vault write secret/application foo=bar baz=bam
```

#### CredHub Server

CredHub를 백엔드로 사용할 때는 설정을 `/application/`에 두거나, 어플리케이션의 `default` 프로파일에 배치해서 모든 어플리케이션과 설정을 공유할 수 있다. 예를 들어 다음 CredHub 명령어를 실행하면 컨피그 서버를 사용하는 모든 어플리케이션이 `shared.color1`, `shared.color2` 프로퍼티를 사용할 수 있다:

```sh
$ credhub set --name "/application/profile/master/shared" --type=json \
   value: {"shared.color1": "blue", "shared.color2": "red"}
$ credhub set --name "/my-app/default/master/more-shared" --type=json \
   value: {"shared.word1": "hello", "shared.word2": "world"}
```

### JDBC Backend

스프링 클라우드 컨피그 서버는 설정 속성의 백엔드로 JDBC(관계형 데이터베이스)를 지원한다. 이 기능은 클래스패스에 `spring-jdbc`를 추가하고 `jdbc` 프로파일을 사용하거나, `JdbcEnvironmentRepository` 타입 빈을 추가하면 활성화할 수 있다. 클래스패스에 정확한 의존성을 포함시키면 (자세한 내용은 사용자 가이드 참조) 스프링 부트는 데이터 소스를 설정한다.

`JdbcEnvironmentRepository`에 대한 autoconfiguration은 `spring.cloud.config.server.jdbc.enabled` 프로퍼티를 `false`로 설정하면 비활성화할 수 있다.

데이터베이스에는 `PROPERTIES`라는 테이블이 있어야 하며, `APPLICATION`, `PROFILE`, `LABEL`과 (`Environment`에서 사용하는 것과 동일한 의미), `Properties` 스타일의 키/값 쌍을 위한 `KEY`, `VALUE` 컬럼이 필요하다. 모든 필드는 자바의 String 타입이므로, 원하는 길이의 `VARCHAR`로 만들 수 있다. 프로퍼티 값은 `{application}-{profile}.properties` 포맷의 스프링 부트 properties 파일에서 값을 가져올 때와 동일하게 동작한다. post-processing 단계로 적용되는 모든 암호화, 복호화도 마찬가지다 (즉, 레포지토리 구현체에서 직접 적용하는 게 아니다).

### Redis Backend

스프링 클라우드 컨피그 서버는 설정 속성의 백엔드로 Redis를 지원한다. 이 기능은 [Spring Data Redis](https://spring.io/projects/spring-data-redis) 의존성을 추가해서 활성화할 수 있다.

**pom.xml**

```xml
<dependencies>
	<dependency>
		<groupId>org.springframework.boot</groupId>
		<artifactId>spring-boot-starter-data-redis</artifactId>
	</dependency>
</dependencies>
```

다음 설정은 스프링 데이터 `RedisTemplate`을 사용해 Redis에 액세스한다. `spring.redis.*` 프로퍼티를 통해 기본 커넥션 설정을 재정의할 수 있다.

```yaml
spring:
  profiles:
    active: redis
  redis:
    host: redis
    port: 16379
```

이 프로퍼티들은 하나의 해시에 속한 필드로 저장해야 한다. 해시명은 `spring.application.name` 프로퍼티나 `spring.application.name`, `spring.profiles.active[n]` 조합과 동일해야 한다.

```sh
HMSET sample-app server.port "8100" sample.topic.name "test" test.property1 "property1"
```

위에 보이는 명령어를 실행하고 나면 해시에는 다음과 같은 값을 갖는 키가 생길 거다:

```sh
HGETALL sample-app
{
  "server.port": "8100",
  "sample.topic.name": "test",
  "test.property1": "property1"
}
```

> 프로파일을 명시하지 않으면 `default`를 사용한다.

### AWS S3 Backend

스프링 클라우드 컨피그 서버는 설정 속성의 백엔드로 AWS S3를 지원한다. 이 기능은 [Amazon S3 용 AWS 자바 SDK](https://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/examples-s3.html) 의존성을 추가해서 활성화할 수 있다.

**pom.xml**

```xml
<dependencies>
	<dependency>
		<groupId>com.amazonaws</groupId>
		<artifactId>aws-java-sdk-s3</artifactId>
	</dependency>
</dependencies>
```

다음 설정은 AWS S3 클라이언트를 사용해 설정 파일에 액세스한다. `spring.awss3.*` 프로퍼티를 통해 설정을 저장할 버킷을 선택할 수 있다.

```yaml
spring:
  profiles:
    active: awss3
  cloud:
    config:
      server:
        awss3:
          region: us-east-1
          bucket: bucket1
```

`spring.awss3.endpoint`로 AWS URL을 지정해서 S3 서비스의 [표준 엔드포인트를 재정의](https://aws.amazon.com/blogs/developer/using-new-regions-and-endpoints/)하는 것도 가능하다. 이 프로퍼티를 통해 S3의 베타 리전과 기타 S3 호환 스토리지 API를 지원할 수 있다.

Credential은 [기본 AWS Credential Provider 체인](https://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/credentials.html)을 사용해 찾는다. 추가 설정 없이도 버킷 버저닝과 암호화를 지원한다.

설정 파일은 버킷 안에 `{application}-{profile}.properties`,나 `{application}-{profile}.yml` 또는 `{application}-{profile}.json`으로 저장된다. 원한다면 레이블을 제공해서 파일에 대한 디렉토리 경로를 지정할 수 있다.

> 프로파일을 명시하지 않으면 `default`를 사용한다.

### CredHub Backend

스프링 클라우드 컨피그 서버는 설정 속성의 백엔드로 [CredHub](https://docs.cloudfoundry.org/credhub)를 지원한다. 이 기능은 [Spring CredHub](https://spring.io/projects/spring-credhub) 의존성을 추가해서 활성화할 수 있다.

**pom.xml**

```xml
<dependencies>
	<dependency>
		<groupId>org.springframework.credhub</groupId>
		<artifactId>spring-credhub-starter</artifactId>
	</dependency>
</dependencies>
```

다음 설정은 mutual TLS를 사용해 CredHub에 액세스한다:

```yaml
spring:
  profiles:
    active: credhub
  cloud:
    config:
      server:
        credhub:
          url: https://credhub:8844
```

프로퍼티는 다음과 같은 JSON으로 저장해야 한다:

```sh
$ credhub set --name "/demo-app/default/master/toggles" --type=json \
   value: {"toggle.button": "blue", "toggle.link": "red"}
$ credhub set --name "/demo-app/default/master/abs" --type=json \
   value: {"marketing.enabled": true, "external.enabled": false}
```

`spring.cloud.config.name=demo-app`을 이름으로 가진 모든 클라이언트 어플리케이션은 다음 프로퍼티를 사용할 수 있다:

```json
{
    toggle.button: "blue",
    toggle.link: "red",
    marketing.enabled: true,
    external.enabled: false
}
```

> 프로파일을 지정하지 않으면 `default`를 사용하며, 레이블을 지정하지 않으면 기본값으로 `master`를 사용한다. 주의: `application`에 추가한 값은 모든 어플리케이션에 공유된다.

#### OAuth 2.0

[UAA](https://docs.cloudfoundry.org/concepts/architecture/uaa.html)를 provider로 사용하면 [OAuth 2.0](https://oauth.net/2/)으로 인증할 수 있다.

**pom.xml**

```xml
<dependencies>
	<dependency>
		<groupId>org.springframework.security</groupId>
		<artifactId>spring-security-config</artifactId>
	</dependency>
	<dependency>
		<groupId>org.springframework.security</groupId>
		<artifactId>spring-security-oauth2-client</artifactId>
	</dependency>
</dependencies>
```

다음 설정은 OAuth 2.0과 UAA를 사용해서 CredHub에 액세스한다:

```yaml
spring:
  profiles:
    active: credhub
  cloud:
    config:
      server:
        credhub:
          url: https://credhub:8844
          oauth2:
            registration-id: credhub-client
  security:
    oauth2:
      client:
        registration:
          credhub-client:
            provider: uaa
            client-id: credhub_config_server
            client-secret: asecret
            authorization-grant-type: client_credentials
        provider:
          uaa:
            token-uri: https://uaa:8443/oauth/token
```

> 여기서 사용한 UAA client-id는 `credhub.read`를 scope로 가져야 한다.

### Composite Environment Repositories

어떤 상황에선 설정 데이터를 여러 environment repository에서 가져와야 할 수도 있다. 이럴땐 컨피그 서버의 application properties나 YAML 파일에 `composite` 프로파일을 활성화하면 된다. 예를 들어 Subversion 레포지토리 하나와 Git 레포지토리 두 개에서 설정 데이터를 가져오고 싶을 땐, 컨피그 서버 프로퍼티를 아래와 같이 설정해주면 된다:

```yaml
spring:
  profiles:
    active: composite
  cloud:
    config:
      server:
        composite:
        -
          type: svn
          uri: file:///path/to/svn/repo
        -
          type: git
          uri: file:///path/to/rex/git/repo
        -
          type: git
          uri: file:///path/to/walter/git/repo
```

이 설정에선 `composite` 키 아래 레포지토리를 나열한 순서에 따라 우선 순위가 결정된다. 위 예제를 보면 Subversion 레포지토리를 제일 먼저 선언했기 때문에, Subversion 레포지토리에서 가져온 값은 Git 레포지토리 중에 동일한 프로퍼티가 있다면 그 값을 재정의하게 된다. `rex` Git 레포지토리에서 찾은 값은 `walter` Git 레포지토리에 동일한 프로퍼티가 있어도 우선 사용한다.

설정을 가져오려는 레포지토리가 모두 타입이 다르다면, 컨피그 서버의 application properties나 YAML 파일에서 `composite` 프로파일 대신 그에 상응하는 프로파일을 활성화할 수 있다. 예를 들어서 단일 Git 레포지토리와 단일 HashiCorp Vault 서버에서 설정 데이터를 가져온다면, 컨피그 서버에 아래와 같은 프로퍼티를 설정하면 된다:

```yaml
spring:
  profiles:
    active: git, vault
  cloud:
    config:
      server:
        git:
          uri: file:///path/to/git/repo
          order: 2
        vault:
          host: 127.0.0.1
          port: 8200
          order: 1
```

이 설정에선 `order` 프로퍼티로 우선 순위를 결정할 수 있다. `order` 프로퍼티를 통해 모든 레포지토리에 대한 우선 순위를 지정할 수 있다. `order` 프로퍼티의 숫자 값이 낮을수록 우선 순위가 높다. 레포지토리의 우선 순위를 정해두면, 여러 레포지토리에 동일한 프로퍼티 값이 들어갔을 때 발생할 수 있는 충돌을 해결할 수 있다.

> 앞의 예제처럼 composite environment에 Vault 서버도 있다면, 컨피그 서버에 보내는 모든 요청에 Vault 토큰을 추가해야 한다. [Vault 백엔드](#vault-backend)를 참고해라.

> environment repository에서 값을 가져올 때 에러가 발생하면 에러 타입이 관계 없이 전체 composite environment 실패로 이어진다.

> composite environment를 사용한다면 모든 레포지토리에 동일한 레이블이 있어야 한다. 앞선 예제와 유사한 환경에서 `master` 레이블로 설정 데이터를 요청하는데, Subversion 레포지토리에 `master`라는 브랜치가 없다면 전체 요청이 실패한다.

#### Custom Composite Environment Repositories

composite environment를 이용할 땐 스프링 클라우드의 environment repository 중 하나를 사용해도 되지만, 자체 `EnvironmentRepository` 빈을 제공할 수도 있다. 자체로 제공할 빈은 `EnvironmentRepository` 인터페이스를 구현해야 한다. 커스텀 `EnvironmentRepository`의 composite environment 내 우선 순위를 제어하려면 `Ordered` 인터페이스도 구현해서 `getOrdered` 메소드를 재정의해야 한다. `Ordered` 인터페이스를 구현하지 않으면 해당 `EnvironmentRepository`는 가장 낮은 우선 순위를 부여받는다.

### Property Overrides

컨피그 서버에는 운영자가 모든 어플리케이션에 설정 프로퍼티를 제공할 수 있는 "overrides" 기능이 있다. 재정의된 프로퍼티는 정상적인 스프링 부트 훅을 사용하는 어플리케이션이라면 불시에 변경할 수 없다. overrides를 선언하려면 다음 예제와 같이 `spring.cloud.config.server.overrides`에 이름-값 쌍의 맵을 추가해라:

```yaml
spring:
  cloud:
    config:
      server:
        overrides:
          foo: bar
```

이 예제에선 모든 컨피그 클라이언트 어플리케이션이 자체 설정과는 관계없이 `foo=bar`를 읽어가도록 한다.

> 설정 시스템이 어플리케이션이 특정 방식으로 설정 데이터를 사용하도록 강제할 순 없다. 그렇기 때문에 overrides는 설정 데이터를 강제할 수 있는 건 아니다. 하지만 스프링 클라우드 컨피그 클라이언트에 기본 동작을 제공해준다.
>

> 일반적으로 `${}`를 사용하는 스프링 environment 플레이스홀더는 백 슬래시(`\`)를 사용해 `$`나 `{`을 이스케이프하고 클라이언트에 리졸브할 수 있다. 예를 들어 앱이 자체 `app.foo`를 제공하지 않는 한 `\${app.foo:bar}`는 `bar`로 리졸브된다.
>

> YAML에선 백 슬래시 자체를 이스케이프할 필요 없다. 하지만 서버의 properties 파일에 overrides를 정의할 땐 백 슬래시를 이스케이프해야 한다.
>

리모트 레포지토리에 `spring.cloud.config.overrideNone=true` 플래그(기본값은 false)를 설정하면, 클라이언트에서 모든 overrides의 우선 순위가 좀 더 기본값답게 바뀐다. 이땐 어플리케이션이 자체 값을 환경 변수나 시스템 프로퍼티로 제공할 수 있다.

---

## Health Indicator

컨피그 서버는 설정한 `EnvironmentRepository`의 동작 여부를 확인하는 Health Indicator를 함께 제공한다. Health Indicator는 기본적으로 `EnvironmentRepository`에 `app`이란 이름의 어플리케이션, `default` 프로파일, `EnvironmentRepository` 구현체가 제공하는 기본 레이블을 요청한다.

Health Indicator는 다음 예제처럼 커스텀 프로파일이나 커스텀 레이블같이 다른 어플리케이션 상태도 함께 확인하도록 설정할 수 있다:

```yaml
spring:
  cloud:
    config:
      server:
        health:
          repositories:
            myservice:
              label: mylabel
            myservice-dev:
              name: myservice
              profiles: development
```

Health Indicator는 `management.health.config.enabled=false`로 설정하면 비활성화할 수 있다.

---

## Security

보안과 관련해서는 스프링 시큐리티와 스프링 부트가 지원하는 게 많기 때문에, 컨피그 서버는 어떤 방식으로든 (물리적인 네트워크 보안에서 OAuth2 bearer 토큰까지) 요구사항에 맞게 보호할 수 있다.

스프링 부트에서 기본으로 설정되는 HTTP 기본 인증을 사용하려면 클래스패스에 스프링 시큐리티를 추가해라 (ex. `spring-boot-starter-security`). username의 기본값은 `user`이고, password는 랜덤하게 만들어진다. 랜덤 password는 실환경에는 적합하지 않으므로, 설정에 password를 추가하고하고 (`spring.security.user.password`) 암호화하는 게 좋다 (암호화하는 방법은 아래 가이드 참고).

---

## Encryption and Decryption

> 암호화/복호화 기능을 사용하려면 JVM에 full-strength JCE가 설치돼있어야 한다 (기본 설치에선 포함돼 있지 않다). 오라클에서 "Java Cryptography Extension (JCE) Unlimited Strength Jurisdiction Policy Files"를 다운로드받고 설치 가이드를 따라해라 (JRE lib/security 디렉토리에 있는 두 policy 파일을 다운받은 파일로 교체해야 한다).

리모트 프로퍼티 소스가 암호화한 컨텐츠(`{cipher}`로 시작하는 값)를 가지고 있다면, HTTP를 통해 클라이언트로 전송하기 전에 복호화한다. 이렇게 했을 때 제일 좋은 점은 프로퍼티 값을 "사용하지 않을 때" (ex. git 레포지토리 안에) 굳이 일반 텍스트로 저장해두지 않아도 된다는 거다. 값을 복호화할 수 없는 경우에는 프로퍼티 소스에서 제거되며, 같은 키에 `invalid` 프리픽스를 달고 "적용할 수 없음(not applicable)"을 의미하는 값(보통 `<n/a>`)으로 별도 프로퍼티를 추가한다. 주로 cipher 텍스트를 password로 사용해 의도치않게 유출되는 걸 방지하기 위해서다.

컨피그 클라이언트 어플리케이션을 위한 리모트 컨피그 레포지토리를 세팅한다면 다음과 유사한 `application.yml`을 가질 수 있다:

**application.yml**

```yaml
spring:
  datasource:
    username: dbuser
    password: '{cipher}FKSAJDFGYOS8F7GLHAKERGFHLSAJ'
```

`application.properties` 파일에선 암호화한 값은 따옴표로 감싸면 안 된다. 따옴표로 감싸게 되면 값을 복호화하지 않는다. 다음은 제대로 동작하는 값 예시다:

**application.properties**

```properties
spring.datasource.username: dbuser
spring.datasource.password: {cipher}FKSAJDFGYOS8F7GLHAKERGFHLSAJ
```

이 일반 텍스트는 공유 git 레포지토리로 푸시해도 안전하며, secret password는 보호된다.

서버는 `/encrypt`와 `/decrypt` 엔드포인트도 노출한다 (보안 설정을 통해 권한을 부여받은 에이전트만 접근한다는 가정하에). 리모트 설정 파일을 편집할 땐 다음 예제처럼 `/encrypt` 엔드포인트에 POST 요청을 보내 컨피그 서버를 통해 값을 암호화할 수 있다:

```bash
$ curl localhost:8888/encrypt -s -d mysecret
682bc583f4641835fa2db009355293665d2647dade3375c0ee201de2a49f7bda
```

> 데이터에 특수문자가 있을 때 ( '+'는 특히 까다롭다) curl로 테스트하고 있다면, `-d` 대신 `--data-urlencode`를 사용하고 암호화할 값에 `=`를 프리픽스로 지정하거나 (curl에서 필요), `Content-Type: text/plain`을 명시해야 제대로 인코딩된다.

> 암호화된 값을 가져갈 때, curl 명령어에서 출력하는 진행 내역까지 복사해가지 않도록 주의해라. 이 때문에 예제에서도 `-s` 옵션을 사용해 진행 내역을 출력하지 않는 거다. 값을 파일로 출력하면 이 문제를 피할 수 있다.

반대 연산도 다음 예제처럼 `/decrypt`를 통해 수행할 수 있다 (서버를 대칭 키나 전체 키 쌍으로 설정했다면):

```bash
$ curl localhost:8888/decrypt -s -d 682bc583f4641835fa2db009355293665d2647dade3375c0ee201de2a49f7bda
mysecret
```

암호화된 값을 가져와 커밋 후 리모트 레포지토리(안전하지 않을 수 있는)에 푸시하기 전에 먼저, YAML이나 properties 파일에 `{cipher}` 프리픽스를 달아 추가해라.

`/encrypt`와 `/decrypt` 엔드포인트는 둘 다 `/*/{application}/{profiles}` 경로로도 요청을 받기 때문에, 클라이언트에서 메인 environment 리소스로 호출하는 경우엔 어플리케이션(이름)이나 프로파일 별로 암호화를 제어할 수 있다.

> 이렇게 암호화를 세분화해서 제어하려면 반드시 이름과 프로파일 별로 다른 encryptor를 생성하는 `TextEncryptorLocator` 타입 `@Bean`도 제공해야 한다. 기본으로 제공하는 빈은 세분화해주진 않는다 (모두 동일한 키로 암호화한다).

다음 예제처럼 `spring` 커맨드라인 클라이언트로도 암호화/복호화할 수 있다 (Spring Cloud CLI 익스텐션을 설치했다면):

```bash
$ spring encrypt mysecret --key foo
682bc583f4641835fa2db009355293665d2647dade3375c0ee201de2a49f7bda
$ spring decrypt --key foo 682bc583f4641835fa2db009355293665d2647dade3375c0ee201de2a49f7bda
mysecret
```

파일에 있는 키(암호화를 위한 RSA 공개 키 등)를 사용하려면, 다음 예제처럼 키 값 앞에 "@"를 붙이고 파일 경로를 제공해라:

```bash
$ spring encrypt mysecret --key @${HOME}/.ssh/id_rsa.pub
AQAjPgt3eFZQXwt8tsHAVv/QHiY5sI2dRcR+...
```

> `--key` 인자는 필수 인자다 (`--` 프리픽스가 있긴하지만).

---

## Key Management

컨피그 서버는 대칭 (공유) 키나 비대칭 키(RSA 키 쌍)를 사용할 수 있다. 비대칭 키는 보안 측면에선 우수하지만, 대칭키는 `bootstrap.properties`에 단일 프로퍼티 값을 설정하면 되기 때문에 보통 더 간편하다.

대칭 키를 설정하려면 `encrypt.key`를 secret String으로 설정해야 한다 (아니면 일반 텍스트 설정 파일에서 제외시키려면 `ENCRYPT_KEY` 환경 변수를 사용하거나).

> 비대칭 키는 `encrypt.key`로 설정할 수 없다.

비대칭 키를 설정하려면 keystore를 사용해라 (ex. JDK와 함께 제공하는 `keytool` 유틸리티로 생성할 수 있다). keystore 프로퍼티는 `encrypt.keyStore.*`로, `*`는 다음과 같다:

|          Property           |               Description               |
| :-------------------------: | :-------------------------------------: |
| `encrypt.keyStore.location` |           `Resource` location           |
| `encrypt.keyStore.password` |      keystore를 unlock할 password       |
|  `encrypt.keyStore.alias`   |     저장소에서 사용할 키를 식별한다     |
|   `encrypt.keyStore.type`   | 생성할 KeyStore 타입. 기본값은 `jks`다. |

암호화는 공개 키로 이루어지며, 복호화엔 개인 키가 필요하다. 따라서 원칙적으로는 서버에서 암호화만 하려는 경우엔 (로컬에서 직접 개인 키로 값을 복호화할 수 있다면) 공개 키만 설정해놓으면 된다. 하지만 이렇게하면 키 관리 프로세스를 서버에 집중시키기 보단 모든 클라이언트에 분산되기 때문에, 실 환경에선 로컬 복호화가 꺼려질 수 있다. 하지만 컨피그 서버가 상대적으로 안전하지 않고 몇 안 되는 클라이언트에만 프로퍼티를 암호화해서 전달하면 되는 상황에선 유용할 거다. 

---

## Creating a Key Store for Testing

테스트 용 keystore는 다음과 유사한 명령어를 통해 생성할 수 있다:

```bash
$ keytool -genkeypair -alias mytestkey -keyalg RSA \
  -dname "CN=Web Server,OU=Unit,O=Organization,L=City,S=State,C=US" \
  -keypass changeme -keystore server.jks -storepass letmein
```

> JDK 11 이상에서 위 명령어를 사용하면 다음과 같은 경고를 만날 수 있다. 그럴 땐 `keypass`와 `storepass` 값이 일치하는지 확인해봐야 할 거다.

```sh
Warning:  Different store and key passwords not supported for PKCS12 KeyStores. Ignoring user-specified -keypass value.
```

컨피그 서버 클래스패스(예를 들어서)에 `server.jks` 파일을 넣은 다음 `bootstrap.yml`에 다음과 같은 설정을 만들어라:

```yaml
encrypt:
  keyStore:
    location: classpath:/server.jks
    password: letmein
    alias: mytestkey
    secret: changeme
```

---

## Using Multiple Keys and Key Rotation

컨피그 서버는 암호화한 프로퍼티 값에선, cipher 텍스트의 앞에 있는 `{cipher}` 프리픽스 외에도 0개 이상의 (Base64로 인코딩한) `{name:value}` 프리픽스를 찾는다. 이 키들은 해당 cipher를 위한 `TextEncryptor`를 찾는 데 필요한 로직을 수행할 수 있는 `TextEncryptorLocator`에 전달된다. keystore를 설정했다면 (`encrypt.keystore.location`) 디폴트 locator는 다음과 유사한 cipher 텍스트에서 `key` 프리픽스로 제공한 alias를 가진 키를 찾는다:

```yaml
foo:
  bar: `{cipher}{key:testkey}...`
```

이 locator에선 "testkey"란 키를 찾는다. 프리픽스에 `{secret:…}`을 추가해 secret을 제공할 수도 있다. 하지만 secret을 제공하지 않으면 기본으로 keystore password를 사용한다 (keystore를 빌드하고 secret을 지정하지 않았을 때 얻게되는 password). secret을 제공한다면 커스텀  `SecretLocator`를 사용해서 secret도 암호화해야 한다.

키를 몇 바이트 짜리 설정 데이터를 암호화할 때만 사용한다면 (즉, 다른 곳에선 사용하지 않는다면) 키 회전은 거의 필요없다. 하지만 가끔은 키를 변경해야 할 수도 있다 (예를 들어 보안 사고로). 이땐 모든 클라이언트에서 소스 설정 파일(git 등)을 변경하고, 모든 cipher에 `{key:…}` 프리픽스를 새 값으로 바꿔야 한다. 클라이언트에선 먼저 컨피그 서버 keystore에서 키 alias를 사용할 수 있는지부터 확인해봐야 한다.

> 컨피그 서버에서 모든 암호화와 복호화를 처리하고 싶으면 `{name:value}` 프리픽스를 `/encrypt` 엔드포인트에 게시하는 일반 텍스트로 추가할 수도 있다.

---

## Serving Encrypted Properties

간혹 설정 복호화를 서버에서 수행하는 대신 클라이언트가 로컬에서 수행하고 싶을 수도 있다. `encrypt.*` 설정을 제공해 키를 찾는다면 이때도 `/encrypt`, `/decrypt` 엔드포인트를 이용할 수 있지만, `bootstrap.[yml|properties]`에 `spring.cloud.config.server.encrypt.enabled=false`를 명시해 프로퍼티를 복호화해 클라이언트로 전송하는 기능을 꺼야 한다. 엔드포인트는 딱히 신경 쓰지 않는다면, 키를 설정하지 않았거나 플래그를 활성화하지 않았다면 제대로 동작할 거다.