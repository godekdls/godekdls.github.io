---
title: TLS and SSL
category: Spring Cloud Gateway
order: 10
permalink: /Spring%20Cloud%20Gateway/tls-and-ssl/
description: 게이트웨이를 HTTPS로 listen하는 방법, TLS 관련 클라이언트 타임아웃 설정 한국어 번역
image: ./../../images/springcloud/logo.jpeg
lastmod: 2021-04-06T22:00:00+09:00
comments: true
originalRefName: 스프링 클라우드 게이트웨이
originalRefLink: https://docs.spring.io/spring-cloud-gateway/docs/3.0.2/reference/html/#tls-and-ssl
---

### 목차

- [9.1. TLS Handshake](#91-tls-handshake)

---

게이트웨이는 평상시의 스프링 서버 설정을 사용해서 HTTPS에서 요청을 수신(listen)할 수 있다. 다음은 그 방법을 보여주는 예시다:

**Example 59. application.yml**

```yaml
server:
  ssl:
    enabled: true
    key-alias: scg
    key-store-password: scg1234
    key-store: classpath:scg-keystore.p12
    key-store-type: PKCS12
```

게이트웨이 route를 `HTTP`나, `HTTPS` 백엔드로 라우팅할 수 있다. HTTPS 백엔드로 라우팅하는 경우엔, 다음과 같이 게이트웨이가 모든 다운스트림 인증서를 신뢰하도록 설정할 수 있다:

**Example 60. application.yml**

```yaml
spring:
  cloud:
    gateway:
      httpclient:
        ssl:
          useInsecureTrustManager: true
```

insecure trust manager를 사용하는 건 프로덕션엔 적합하지 않다. 프로덕션 배포에선 다음과 같이 게이트웨이에 신뢰할 수 있는 알려진 인증서 셋을 설정할 수 있다:

**Example 61. application.yml**

```yaml
spring:
  cloud:
    gateway:
      httpclient:
        ssl:
          trustedX509Certificates:
          - cert1.pem
          - cert2.pem
```

스프링 클라우드 게이트웨이가 신뢰할 수 있는 인증서로 프로비저닝되지 않은 경우, 디폴트 trust store를 사용한다 (이 설정은 시스템 프로퍼티 `javax.net.ssl.trustStore`를 설정해 재정의할 수 있다).

---

## 9.1. TLS Handshake

게이트웨이는 백엔드로 라우팅하는 데 사용하는 클라이언트 풀을 유지한다. HTTPS를 통해 통신할 때는 클라이언트에서 TLS 핸드셰이크를 시작한다. 이 핸드셰이크에는 관련된 timeout 값들이 많이 있다. 이런 timeout 값들은 아래와 같이 설정할 수 있다 (기본값을 표기했다).

**Example 62. application.yml**

```yaml
spring:
  cloud:
    gateway:
      httpclient:
        ssl:
          handshake-timeout-millis: 10000
          close-notify-flush-timeout-millis: 3000
          close-notify-read-timeout-millis: 0
```