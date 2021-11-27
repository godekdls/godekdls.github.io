---
title: Running Cloud Foundry Locally
navTitle: Running locally
category: Spring Cloud Data Flow
order: 9
permalink: /Spring%20Cloud%20Data%20Flow/installation.cloudfoundry.local/
description: 로컬에서 실행한 Data Flow, Skipper 서버로 클라우드 파운드리 환경에 배포하기
image: ./../../images/springclouddataflow/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 클라우드 데이터 플로우
originalRefLink: https://dataflow.spring.io/docs/installation/cloudfoundry/cf-local/
parent: Installation
parentUrl: /Spring%20Cloud%20Data%20Flow/installation/
subparent: Cloud Foundry
subparentUrl: /Spring%20Cloud%20Data%20Flow/installation.cloudfoundry/
---

가끔은 디버깅 등이 필요할 때 로컬에서 Data Flow와 Skipper 서버를 실행하고 클라우드 파운드리에 애플리케이션을 배포할 수 있도록 설정해 놓으면 편할 때가 있다.

### 목차

- [Configure Data Flow Server on a Local Machine](#configure-data-flow-server-on-a-local-machine)
- [Configure Skipper Server on Local Machine](#configure-skipper-server-on-local-machine)

---

## Configure Data Flow Server on a Local Machine

로컬에서 (노트북이나 데스크톱에서) Data Flow 서버 애플리케이션을 실행하고 운영 중인 클라우드 파운드리를 타겟으로 지정하려면, 프로퍼티 파일에 (ex. `myproject.properties`) 아래 환경 변수를 통해 Data Flow 서버를 설정해주면 된다:

```properties
spring.profiles.active=cloud
jbp.config.spring.auto.reconfiguration='{enabled: false}'
spring.cloud.dataflow.task.platform.cloudfoundry.accounts[default].connection.url=https://api.run.pivotal.io
spring.cloud.dataflow.task.platform.cloudfoundry.accounts[default].connection.org={org}
spring.cloud.dataflow.task.platform.cloudfoundry.accounts[default].connection.space={space}
spring.cloud.dataflow.task.platform.cloudfoundry.accounts[default].connection.domain=cfapps.io
spring.cloud.dataflow.task.platform.cloudfoundry.accounts[default].connection.username={email}
spring.cloud.dataflow.task.platform.cloudfoundry.accounts[default].connection.password={password}
spring.cloud.dataflow.task.platform.cloudfoundry.accounts[default].connection.skipSslValidation=false
spring.cloud.dataflow.task.platform.cloudfoundry.accounts[default].scheduler.scheduler-url=https://<scheduler.url>
# The following command lets task applications write to their DB.
# Note, however, that when the *server* runs locally, it cannot access that DB.
# In that case, task-related commands that show executions do not work.
spring.cloud.dataflow.task.platform.cloudfoundry.accounts[default].deployment.services=mysqlcups
skipper.client.serverUri=https://<skipper-host-name>/api
```

이 파일을 사용하려면 먼저 `\{org}`, `\{space}`, `\{email}`, `\{password}`를 채워 넣어야 한다.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
 <p><strong>SSL Validation</strong></p>
 <p>클라우드 파운드리 인스턴스에서 자체 서명된<sup>self-signed</sup> 인증서를 사용해서 (아직 개발 중일 때 등) 실행시킬 때에만 <em>Skip SSL Validation</em>을 <code class="highlighter-rouge">true</code>로 설정해라. 프로덕션에선 자체 서명된 인증서를 사용하면 안 된다.</p>
</blockquote>

> Skipper 서버가 실행되는 URI 위치를 설정하려면 먼저 Skipper를 배포해야 한다.

이제 서버 애플리케이션을 시작할 수 있다:

```bash
java -jar spring-cloud-dataflow-server-2.9.1.jar --spring.config.additional-location=<PATH-TO-FILE>/foo.properties
```

---

## Configure Skipper Server on Local Machine

로컬에서 (노트북이나 데스크톱에서) Skipper 애플리케이션을 실행하고 운영 중인 클라우드 파운드리를 타겟으로 지정하려면, 프로퍼티 파일에 (ex. `myproject.properties`) 아래 환경 변수를 통해 Skipper 서버를 설정해주면 된다:

```properties
spring.profiles.active=cloud
jbp.config.spring.auto.reconfiguration='{enabled: false}'
spring.cloud.skipper.server.platform.cloudfoundry.accounts[default].connection.url=https://api.run.pivotal.io
spring.cloud.skipper.server.platform.cloudfoundry.accounts[default].connection.org={org}
spring.cloud.skipper.server.platform.cloudfoundry.accounts[default].connection.space={space}
spring.cloud.skipper.server.platform.cloudfoundry.accounts[default].connection.domain=cfapps.io
spring.cloud.skipper.server.platform.cloudfoundry.accounts[default].connection.username={email}
spring.cloud.skipper.server.platform.cloudfoundry.accounts[default].connection.password={password}
spring.cloud.skipper.server.platform.cloudfoundry.accounts[default].connection.skipSslValidation=false
```

이 파일을 사용하려면 먼저 `\{org}`, `\{space}`, `\{email}`, `\{password}`를 채워 넣어야 한다.

<blockquote style="background-color: #fbebf3; border-color: #d63583;">
 <p><strong>SSL Validation</strong></p>
 <p>클라우드 파운드리 인스턴스에서 자체 서명된<sup>self-signed</sup> 인증서를 사용해서 (아직 개발 중일 때 등) 실행시킬 때에만 <em>Skip SSL Validation</em>을 <code class="highlighter-rouge">true</code>로 설정해라. 프로덕션에선 자체 서명된 인증서를 사용하면 안 된다.</p>
</blockquote>