---
title: Securing Prometheus API and UI Endpoints using TLS Encryption
navTitle: TLS encryption
category: Prometheus
order: 78
permalink: /Prometheus/guides.tls-encryption/
description: 프로메테우스 인스턴스에 TLS 암호화 적용하기
image: ./../../images/prometheus/logo.png
lastmod: 2022-01-05T21:30:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/guides/tls-encryption/
parent: GUIDES
parentUrl: /Prometheus/guides/
---

---

프로메테우스는 프로메테우스 인스턴스로 연결하는 커넥션에 [TLS<sup>Transport Layer Security</sup>](https://en.wikipedia.org/wiki/Transport_Layer_Security) 암호화를 지원한다 (expression 브라우저나 [HTTP API](../querying.api) 등에서). 이런 커넥션들에 TLS를 적용하려면 전용 웹 설정 파일을 생성해야 한다.

> **참고:** 이 가이드에선 *프로메테우스 인스턴스에 연결할 때* 사용하는 TLS 커넥션을 다룬다. TLS는 *프로메테우스 인스턴스가 [스크랩 타겟](../configuration/#scrape_config)에* 연결할 때 사용하는 커넥션에서도 지원하고 있다.

### 목차

- [Pre-requisites](#pre-requisites)
- [Prometheus configuration](#prometheus-configuration)
- [Testing](#testing)

---

## Pre-requisites

프로메테우스 인스턴스는 이미 기동해서 실행 중인 상태에서 TLS 세팅을 더 추가한다고 가정한다. 이 가이드에선 초기 프로메테우스 세팅은 다루지 않는다.

`example.com` 도메인(이 도메인을 소유하고 있다고 가정)에서 TLS를 통해 서빙하는 프로메테우스 인스턴스를 실행하려고 한다고 가정해 보겠다.

추가로, [OpenSSL](https://www.digitalocean.com/community/tutorials/openssl-essentials-working-with-ssl-certificates-private-keys-and-csrs)이나 유사한 도구를 이용해 다음과 같은 파일을 생성했다고 가정한다:

- SSL 인증서 (`/home/prometheus/certs/example.com/example.com.crt`)
- SSL 키 (`/home/prometheus/certs/example.com/example.com.key`)

자체 서명<sup>self-signed</sup> 인증서와 개인 키는 다음 명령어로 생성할 수 있다:

```sh
mkdir -p /home/prometheus/certs/example.com && cd /home/prometheus/certs/certs/example.com
openssl req \
  -x509 \
  -newkey rsa:4096 \
  -nodes \
  -keyout example.com.key \
  -out example.com.crt
```

입력창이 보이면 다른 것들은 적절히 입력해주되, `Common Name` 입력창에선 반드시 `example.com`을 입력해야 한다.

---

## Prometheus configuration

다음은 [`web-config.yml`](../https) 설정 파일 예시다. 이 설정을 사용하면 프로메테우스는 모든 엔드포인트를 TLS로 서빙한다:

```yaml
tls_server_config:
  cert_file: /home/prometheus/certs/example.com/example.com.crt
  key_file: /home/prometheus/certs/example.com/example.com.key
```

프로메테우스가 이 설정을 사용하도록 만들어주려면 `--web.config.file` 플래그를 사용해서 호출해줘야 한다:

```sh
prometheus \
  --config.file=/path/to/prometheus.yml \
  --web.config.file=/path/to/web-config.yml \
  --web.external-url=https://example.com/
```

여기서 `--web.external-url=` 플래그는 선택사항이다.

---

## Testing

로컬에서 `example.com` 도메인을 사용해서 TLS를 테스트하고 싶다면, `/etc/hosts` 파일에 `example.com`을 `localhost`로 리라우팅해주는 항목을 추가하면 된다:

```
127.0.0.1     example.com
```

그러면 cURL을 이용해서 로컬 프로메테우스 세팅과 상호 작용해볼 수 있다:

```sh
curl --cacert /home/prometheus/certs/example.com/example.com.crt \
  https://example.com/api/v1/label/job/values
```

`--insecure` 플래그나 `-k` 플래그를 사용하면 인증서를 지정하지 않고 프로메테우스 서버에 연결할 수 있다:

```sh
curl -k https://example.com/api/v1/label/job/values
```