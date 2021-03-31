---
title: Serving Plain Text
category: Spring Cloud Config
order: 5
permalink: /Spring%20Cloud%20Config/serving-plain-text/
description: 설정 파일을 Environment에 매핑하는 대신 원하는 파일에 둔 plaintext로 서빙하는 방법
image: ./../../images/springcloud/logo.jpeg
lastmod: 2021-03-31T22:00:00+09:00
comments: true
originalRefName: 스프링 클라우드 컨피그
originalRefLink: https://docs.spring.io/spring-cloud-config/docs/3.0.3/reference/html/#_serving_plain_text
---

### 목차

- [Git, SVN, and Native Backends](#git-svn-and-native-backends)
- [AWS S3](#aws-s3)
- [Decrypting Plain Text](#decrypting-plain-text)

---

`Environment` 클래스를 사용하는 대신 (또는 YAML, properties 형식의 대체 표현), 어플리케이션 환경에 맞게 조절한 일반 plain-text 설정 파일이 필요할 수도 있다. 이 기능은 컨피그 서버의 별도 엔드포인트 `/{application}/{profile}/{label}/{path}`를 통해 제공한다. 여기서 `application`, `profile`, `label`은 전형적인 environment 엔드포인트에서와 의미가 같다. 단, `path`는 파일명을 찾기 위한 경로다 (`log.xml` 등). 여기서도 기존 environment 엔드포인트와 동일한 방식으로 소스 파일을 찾는다. properties와 YAML 파일과 같은 검색 경로를 이용한다. 하지만 매칭되는 모든 리소스를 집계하는 대신 일치하는 첫 번째 리소스만 반환한다.

리소스를 찾은 다음엔 제공한 어플리케이션 이름, 프로파일, 레이블에 해당하는 `Environment`를 사용해 일반적인 폼의 (`${…}`) 플레이스홀더를 리졸브한다. 이렇게 리소스 엔드포인트는 environment 엔드포인트와 긴밀히 통합된다.

> environment 구성을 위한 소스 파일과 마찬가지로, `profile`은 파일명을 리졸브할 때도 사용한다. 따라서 프로파일 별로 파일을 다르게 가려면 `/*/development/*/logback.xml`은 `logback-development.xml`이란 파일로 리졸브할 수 있다 (`logback.xml`보다 우선시된다).

> `label`을 직접 제공하는 대신 서버에서 디폴트 레이블을 사용하도록 하고싶다면, 요청 파라미터에 `useDefaultLabel`을 추가하면 된다. 따라서 앞의 예제에서 `default` 프로파일을 사용하는 경우엔 디폴트 레이블은 `/sample/default/nginx.conf?useDefaultLabel`로 요청할 수 있다.

현재 스프링 클라우드 컨피그는 git, SVN, native 백엔드, AWS S3에서 plaintext를 서빙할 수 있다. git, SVN, native 백엔드에 대한 지원은 동일하다. AWS S3는 약간 다르게 동작한다. 다음 섹션에선 각각의 작동 방식을 설명한다:

- [Git, SVN, and Native Backends](#git-svn-and-native-backends)
- [AWS S3](#aws-s3)

---

## Git, SVN, and Native Backends

GIT, SVN 레포지토리나 native 백엔드에 대한 예시로 아래 예제를 살펴보자:

```
application.yml
nginx.conf
```

`nginx.conf`는 다음과 유사할 거다:

```nginx
server {
    listen              80;
    server_name         ${nginx.server.name};
}
```

`application.yml`은 다음과 유사할 거다:

```yaml
nginx:
  server:
    name: example.com
---
spring:
  profiles: development
nginx:
  server:
    name: develop.com
```

`/sample/default/master/nginx.conf` 리소스는 다음과 같다:

```nginx
server {
    listen              80;
    server_name         example.com;
}
```

`/sample/development/master/nginx.conf`는 다음과 같다:

```nginx
server {
    listen              80;
    server_name         develop.com;
}
```

---

## AWS S3

AWS s3에서 plain text를 서빙하려면 컨피그 서버 어플리케이션에 Spring Cloud AWS 의존성을 추가해야 한다. 의존성을 설정하는 자세한 방법은 [Spring Cloud AWS 레퍼런스 가이드](https://cloud.spring.io/spring-cloud-static/spring-cloud-aws/2.1.3.RELEASE/single/spring-cloud-aws.html#_spring_cloud_aws_maven_dependency_management)를 참고해라. 그런 다음 [Spring Cloud AWS 레퍼런스 가이드](https://cloud.spring.io/spring-cloud-static/spring-cloud-aws/2.1.3.RELEASE/single/spring-cloud-aws.html#_configuring_credentials)에서 설명하는 대로 Spring Cloud AWS를 설정해야 한다.

---

## Decrypting Plain Text

기본적으로 plain text 파일엔 암호화한 값이 있어도 복호화하지 않는다. plain text 파일에서 복호화를 활성화하려면 `bootstrap.[yml|properties]`에 `spring.cloud.config.server.encrypt.enabled=true`와 `spring.cloud.config.server.encrypt.plainTextEncrypt=true`를 설정해라.

> plain text 파일 복호화는 YAML, JSON, properties 파일 확장자만 지원한다.

이 기능을 활성화했더라도 지원되지 않는 파일 확장자를 요청했을 땐, 파일에 있는 어떤 암호화 값도 복호화되지 않는다.