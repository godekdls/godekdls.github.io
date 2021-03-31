---
title: Embedding the Config Server
category: Spring Cloud Config
order: 6
permalink: /Spring%20Cloud%20Config/embedding-the-config-server/
description: 컨피그 서버를 다른 어플리케이션에 임베딩시키기
image: ./../../images/springcloud/logo.jpeg
lastmod: 2021-03-31T22:00:00+09:00
comments: true
originalRefName: 스프링 클라우드 컨피그
originalRefLink: https://docs.spring.io/spring-cloud-config/docs/3.0.3/reference/html/#_embedding_the_config_server
---

---

컨피그 서버는 독립형 어플리케이션으로 실행했을 때가 가장 좋다. 그래도 필요하면 다른 어플리케이션에 임베딩시킬 수 있다. 그러려면 `@EnableConfigServer` 어노테이션을 사용해라. 이땐 비필수 프로퍼티 `spring.cloud.config.server.bootstrap`이 유용할 거다. 이 플래그는 서버가 자체 설정을 자체 리모트 레포지토리에서 가져와야 하는지 여부를 알린다. 이 플래그는 기동을 지연시킬 수 있어 기본적으로는 꺼져 있다. 하지만 다른 어플리케이션에 임베드할 땐 다른 모든 어플리케이션과 동일한 방식으로 초기화하는 게 좋다. `spring.cloud.config.server.bootstrap`을 `true`로 설정한다면 [composite environment repository 설정](../spring-cloud-config-server#composite-environment-repositories)도 사용해야 한다. 예를 들면:

```yaml
spring:
  application:
    name: configserver
  profiles:
    active: composite
  cloud:
    config:
      server:
        composite:
          - type: native
            search-locations: ${HOME}/Desktop/config
        bootstrap: true
```

> bootstrap 플래그를 사용한다면 컨피그 서버의 `bootstrap.yml`에 이름과 레포지토리 URI이 설정돼 있어야 한다.

서버의 엔드포인트 위치를 변경하려면 `spring.cloud.config.server.prefix`(생략 가능)를 (ex. `/config` 등으로) 설정해서 리소스를 해당 프리픽스 아래에서 서빙할 수 있다. 이때 프리픽스는 `/`로 시작하돼, `/`로 끝나서는 안 된다. 이 프리픽스는 컨피그 서버의 `@RequestMappings`에 적용된다 (즉, 스프링 부트 `server.servletPath`와 `server.contextPath` 프리픽스 아래).

백엔드 레포지토리에서 직접 어플리케이션 설정을 읽어가고 싶을 땐 (컨피그 서버를 거치지 않고), 기본적으로 임베디드 컨피그 서버엔 엔드포인트가 필요없다. `@EnableConfigServer` 어노테이션을 사용하지 않으면 엔드포인트를 완전히 꺼버릴 수 있다 (`spring.cloud.config.server.bootstrap=true`를 설정해라).