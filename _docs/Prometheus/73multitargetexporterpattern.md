---
title: Understanding and using the multi-target exporter pattern
category: Prometheus
order: 73
permalink: /Prometheus/guides.multi-target-exporter/
description: 익스포터로 여러 가지 타겟을 스크랩하는 방법
image: ./../../images/prometheus/logo.png
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/guides/multi-target-exporter/
parent: GUIDES
parentUrl: /Prometheus/guides/
---

---

이 가이드에선 멀티 타겟 익스포터 패턴을 소개하며 다음과 같은 내용들을 실습해본다:

- 멀티 타겟 익스포터 패턴이 무엇인지와, 이 패턴을 사용하는 이유에 대해서 설명한다.
- 이 패턴의 예시로 [blackbox](https://github.com/prometheus/blackbox_exporter) 익스포터를 실행한다.
- blackbox 익스포터에 커스텀 쿼리 모듈을 설정한다.
- blackbox 익스포터를 실행해서 프로메테우스 [웹사이트](https://prometheus.io/)에 기본적인 메트릭들을 질의한다.
- relabeling을 이용해 프로메테우스로 익스포터를 스크랩할 수 있는 인기 패턴 한 가지를 파헤쳐본다.

### 목차

- [The multi-target exporter pattern?](#the-multi-target-exporter-pattern)
- [Running multi-target exporters](#running-multi-target-exporters)
- [Basic querying of multi-target exporters](#basic-querying-of-multi-target-exporters)
- [Configuring modules](#configuring-modules)
- [Querying multi-target exporters with Prometheus](#querying-multi-target-exporters-with-prometheus)

---

## The multi-target exporter pattern?

멀티 타겟 익스포터 패턴는 [익스포터](../exporters)가 다음과 같은 특유의 설계를 가지고 있을 때를 일컫는다:

- 익스포터는 네트워크 프로토콜을 통해 타겟의 메트릭을 가져온다.
- 익스포터를 메트릭을 가져오는 시스템에서 실행할 필요가 없다.
- 익스포터는 프로메테우스의 GET 요청 파라미터에서 타겟과 쿼리 설정 문자열을 가져온다.
- the exporter subsequently starts the scrape after getting Prometheus’ GET requests and once it is done with scraping.
- 익스포터는 프로메테우스의 GET 요청을 받고 진행 중인 스크랩이 없으면 이어서 스크랩을 시작한다.
- 익스포터는 여러 타겟들을 질의할 수 있다.

이 패턴은 [blackbox](https://github.com/prometheus/blackbox_exporter), [SNMP 익스포터](https://github.com/prometheus/snmp_exporter)같은 특정 익스포터들에서만 사용하고 있다.

그 이유는 이런 익스포터는 타겟에서 실행할 수 없기 때문이다. 타겟이 SNMP로 통신하는 네트워크 장비일 수도 있고, 멀리 떨어져 있는 타겟을 모니터링해야할 수도 있다. 예를 들어 [blackbox](https://github.com/prometheus/blackbox_exporter) 익스포터의 일반적인 유스 케이스처럼 네트워크 바깥에 있는 특정 웹사이트에 연결할 수 있는지, 지연 시간은 얼마나 되는지를 측정하고 싶을 수도 있다.

---

## Running multi-target exporters

멀티 타겟 익스포터는 환경에 관해 유연한 편이며, 다양한 방식으로 실행할 수 있다. 일반적인 프로그램이나 백그라운드 서비스로도 실행할 수도 있고, 컨테이너 환경이나 베어메탈, 가상 머신에서도 실행할 수 있다. 네트워크를 통해 질의 요청을 받아 질의를 수행하기 때문에 적절한 포트를 열어줘야 한다. 그 외에는 리소스를 크게 사용할 일은 없다.

이제 직접 멀티 타겟 익스포터 패턴을 사용해보자!

[도커](https://www.docker.com/)를 이용해서 blackbox 익스포터 컨테이너를 시작해보자. 터미널에서 아래 명령어를 실행해라. 시스템 설정에 따라 명령 앞에 `sudo`를 붙여야 할 수도 있다:

```sh
docker run -p 9115:9115 prom/blackbox-exporter
```

로그가 몇 줄에 걸쳐서 출력될 거다. 전부 잘 진행됐다면 마지막 라인에선 다음과 같이 `msg="Listening on address"`를 볼 수 있을 거다.

```sh
level=info ts=2018-10-17T15:41:35.4997596Z caller=main.go:324 msg="Listening on address" address=:9115
```

---

## Basic querying of multi-target exporters

쿼리에는 두 가지 방법이 있다:

1. 익스포터 자체를 질의한다. 익스포터는 자체 메트릭을 가지고 있으며, 보통은 `/metrics`에서 이용할 수 있다.
2. 익스포터가 다른 타겟을 스크랩하도록 질의한다. 보통은 제공하는 엔드포인트 주소 자체에서 동작을 알 수 있다 (`/probe`). 멀티 타겟 익스포터를 사용할 때는 주로 이 엔드포인트를 활용한다.

첫 번째 쿼리 타입은 터미널을 하나 더 열어 직접 curl로 요청해봐도 되고, 이 [링크](http://localhost:9115/metrics)에 접근해봐도 된다:

<span id="query-exporter"></span>

```sh
curl 'localhost:9115/metrics'
```

다음과 같은 응답을 볼 수 있을 거다:

```prometheus
# HELP blackbox_exporter_build_info A metric with a constant '1' value labeled by version, revision, branch, and goversion from which blackbox_exporter was built.
# TYPE blackbox_exporter_build_info gauge
blackbox_exporter_build_info{branch="HEAD",goversion="go1.10",revision="4a22506cf0cf139d9b2f9cde099f0012d9fcabde",version="0.12.0"} 1
# HELP go_gc_duration_seconds A summary of the GC invocation durations.
# TYPE go_gc_duration_seconds summary
go_gc_duration_seconds{quantile="0"} 0
go_gc_duration_seconds{quantile="0.25"} 0
go_gc_duration_seconds{quantile="0.5"} 0
go_gc_duration_seconds{quantile="0.75"} 0
go_gc_duration_seconds{quantile="1"} 0
go_gc_duration_seconds_sum 0
go_gc_duration_seconds_count 0
# HELP go_goroutines Number of goroutines that currently exist.
# TYPE go_goroutines gauge
go_goroutines 9

[…]

# HELP process_cpu_seconds_total Total user and system CPU time spent in seconds.
# TYPE process_cpu_seconds_total counter
process_cpu_seconds_total 0.05
# HELP process_max_fds Maximum number of open file descriptors.
# TYPE process_max_fds gauge
process_max_fds 1.048576e+06
# HELP process_open_fds Number of open file descriptors.
# TYPE process_open_fds gauge
process_open_fds 7
# HELP process_resident_memory_bytes Resident memory size in bytes.
# TYPE process_resident_memory_bytes gauge
process_resident_memory_bytes 7.8848e+06
# HELP process_start_time_seconds Start time of the process since unix epoch in seconds.
# TYPE process_start_time_seconds gauge
process_start_time_seconds 1.54115492874e+09
# HELP process_virtual_memory_bytes Virtual memory size in bytes.
# TYPE process_virtual_memory_bytes gauge
process_virtual_memory_bytes 1.5609856e+07
```

여기서 보이는 메트릭들은 프로메테우스 [포맷](../exposition-formats/#text-format-example)을 사용하고 있다. 이 메트릭들은 익스포터를 [계측<sup>instrumentation</sup>](../practices.instrumentation)한 정보이며, 익스포터가 실행되는 동안 익스포터 자체의 상태 정보를 알려준다. 이런 유형을 화이트박스 모니터링이라고 부르며, 일상적인 서비스 운영에서 매우 유용하다. 궁금한 점이 있다면 [자체 애플리케이션을 계측](../guides.go-application)하는 방법을 안내하는 가이드를 참고해라.

두 번째 유형의 쿼리를 실행하려면, HTTP GET 요청에서 타겟과 모듈을 파라미터로 제공해줘야 한다. 타겟은 URI나 IP로 지정하며, 모듈은 반드시 익스포터의 설정에 정의돼 있어야 한다. blackbox 익스포터 컨테이너에선 활용도 높은 디폴트 설정을 제공하고 있다.<br>여기서는 타겟으로 `prometheus.io`를 사용하고, 미리 정의해둔 모듈 `http_2xx`를 사용해본다. 이 모듈은 브라우저에서 `prometheus.io`로 이동해 [200 OK](https://en.wikipedia.org/wiki/List_of_HTTP_status_codes#2xx_Success) 응답을 받을 때처럼 익스포터도 GET 요청을 만들도록 지시하는 모듈이다.

이제 터미널에서 curl을 이용해서 blackbox 익스포터가 `prometheus.io`를 질의하도록 지시할 수 있다:

```sh
curl 'localhost:9115/probe?target=prometheus.io&module=http_2xx'
```

위 요청을 전송하면 많은 메트릭들이 반환될 거다:

```prometheus
# HELP probe_dns_lookup_time_seconds Returns the time taken for probe dns lookup in seconds
# TYPE probe_dns_lookup_time_seconds gauge
probe_dns_lookup_time_seconds 0.061087943
# HELP probe_duration_seconds Returns how long the probe took to complete in seconds
# TYPE probe_duration_seconds gauge
probe_duration_seconds 0.065580871
# HELP probe_failed_due_to_regex Indicates if probe failed due to regex
# TYPE probe_failed_due_to_regex gauge
probe_failed_due_to_regex 0
# HELP probe_http_content_length Length of http content response
# TYPE probe_http_content_length gauge
probe_http_content_length 0
# HELP probe_http_duration_seconds Duration of http request by phase, summed over all redirects
# TYPE probe_http_duration_seconds gauge
probe_http_duration_seconds{phase="connect"} 0
probe_http_duration_seconds{phase="processing"} 0
probe_http_duration_seconds{phase="resolve"} 0.061087943
probe_http_duration_seconds{phase="tls"} 0
probe_http_duration_seconds{phase="transfer"} 0
# HELP probe_http_redirects The number of redirects
# TYPE probe_http_redirects gauge
probe_http_redirects 0
# HELP probe_http_ssl Indicates if SSL was used for the final redirect
# TYPE probe_http_ssl gauge
probe_http_ssl 0
# HELP probe_http_status_code Response HTTP status code
# TYPE probe_http_status_code gauge
probe_http_status_code 0
# HELP probe_http_version Returns the version of HTTP of the probe response
# TYPE probe_http_version gauge
probe_http_version 0
# HELP probe_ip_protocol Specifies whether probe ip protocol is IP4 or IP6
# TYPE probe_ip_protocol gauge
probe_ip_protocol 6
# HELP probe_success Displays whether or not the probe was a success
# TYPE probe_success gauge
probe_success 0
```

거의 모든 메트릭들의 값이 `0`인 점에 주목해라. 마지막 메트릭도 `probe_success 0`이다. 이 지표는 프로버가 `prometheus.io`에 정상적으로 도달할 수 없었다는 것을 의미한다. 그 이유는 `6`을 값으로 가지고 있는 `probe_ip_protocol` 메트릭에 숨겨져 있다. 기본적으로 프로버는 다른 지시가 없으면 [IPv6](https://en.wikipedia.org/wiki/IPv6)를 사용한다. 하지만 도커 데몬은 다른 지시가 없으면 IPv6를 차단한다. 그렇기 때문에 도커 컨테이너에서 실행하는 blackbox 익스포터는 IPv6를 통해 연결할 수 없다.

이제 도커에서 IPv6를 허용해주거나 blackbox 익스포터에서 IPv4를 사용하게 만들어주면 된다. 현실 세계에선 둘 모두 가능할 수 있기 때문에, "둘 중 뭐를 변경해야 하나요?"라고 묻는다면 "상황에 따라 다르다"는 대답을 줄 수 있다. 이 문서는 익스포터 가이드이기 때문에, 여기서는 커스텀 모듈을 설정해볼 수 있도록 익스포터를 변경할 거다.

---

## Configuring modules

모듈들은 도커 컨테이너 내부에 있는 `config.yml` 파일에 미리 정의돼 있다. 이 파일은 깃허브 레포지토리에 있는 [blackbox.yml](https://github.com/prometheus/blackbox_exporter/blob/master/blackbox.yml)에서 가져온 파일이다.

여기서는 레포지토리에 있는 파일을 복사해서 자체 요구사항에 맞게 [조정](https://github.com/prometheus/blackbox_exporter/blob/master/CONFIGURATION.md)한 다음, 익스포터가 컨테이너에 들어있는 파일 대신 이 설정 파일을 사용하도록 만들어본다.

먼저 curl이나 브라우저를 이용해서 파일을 다운받아라:

```sh
curl -o blackbox.yml https://raw.githubusercontent.com/prometheus/blackbox_exporter/master/blackbox.yml
```

에디터에서 이 파일을 열어봐라. 맨 윗 줄에는 다음과 같은 내용이 담겨 있을 거다:

```yaml
modules:
  http_2xx:
    prober: http
  http_post_2xx:
    prober: http
    http:
      method: POST
```

[YAML](https://en.wikipedia.org/wiki/YAML)은 공백 들여쓰기를 이용해서 계층 구조를 표현한다. 따라서 `http_2xx`와 `http_post_2xx`라는 두 개의 `modules`이 정의돼 있으며, 둘 다 `http` 프로버를 가지고 있고, 하나는 메소드 값을 따로 `POST`로 설정해둔 것을 알 수 있다.<br>
이제 `http` 프로버의 `preferred_ip_protocol`에 `ip4`라는 문자열을 명시해서 `http_2xx` 모듈을 변경해보겠다.

```yaml
modules:
  http_2xx:
    prober: http
    http:
      preferred_ip_protocol: "ip4"
  http_post_2xx:
    prober: http
    http:
      method: POST
```

사용할 수 있는 프로버들과 옵션에 대해 더 알아보고 싶다면 이 [문서](https://github.com/prometheus/blackbox_exporter/blob/master/CONFIGURATION.md)를 확인해봐라.

이제 blackbox 익스포터에서도 새로 변경한 파일을 사용하도록 알려줘야 한다. 이땐 `--config.file="blackbox.yml"` 플래그를 이용하면 된다. 하지만 도커를 사용하고 있기 때문에, 먼저 `--mount` 명령을 통해 컨테이너 내부에서도 이 파일을 [사용할 수 있게](https://docs.docker.com/storage/bind-mounts/) 만들어줘야 한다.

> **참고:** macOS를 사용하고 있다면, 먼저 도커 데몬이 `blackbox.yml`이 들어있는 디렉토리에 액세스할 수 있게 허용해줘야 한다. 메뉴 바에 조그맣게 보이는 도커 고래 아이콘을 클릭한 다음 `Preferences`->`File Sharing`->`+`를 클릭하면 된다. 그런 다음 `Apply & Restart`를 눌러라.

먼저 전에 실행했던 터미널로 돌아가서 `ctrl+c`를 눌러 컨테이너를 중지해라. 그런 다음 아래 명령어를 실행해라. 이 명령어는 `blackbox.yml`이 들어있는 디렉토리에서 실행해야 한다. 명령어가 꽤 길지만 이어서 설명해줄 거다:

<span id="run-exporter"></span>
```sh
docker \
  run -p 9115:9115 \
  --mount type=bind,source="$(pwd)"/blackbox.yml,target=/blackbox.yml,readonly \
  prom/blackbox-exporter \
  --config.file="/blackbox.yml"
```

이 명령어는 `docker`에게 다음과 같은 것들을 지시한다:

1. 컨테이너 외부 `9115` 포트를 컨테이너 내부 `9115` 포트에 매핑해서 컨테이너를 실행<sup>`run`</sup>한다.
2. 현재 디렉토리에 있는 (`$(pwd)`는 작업 디렉토리를 출력한다) `blackbox.yml` 파일을 `readonly` 모드로 `/blackbox.yml`로 마운트<sup>`mount`</sup>한다.
3. [도커 허브](https://hub.docker.com/r/prom/blackbox-exporter/)에 있는 `prom/blackbox-exporter` 이미지를 사용한다.
4. `/blackbox.yml`을 설정 파일로 사용할 수 있도록 `--config.file` 플래그를 이용해 blackbox-exporter를 실행한다.

전부 정확하게 따라했다면 다음과 같은 로그가 보일 거다:

```sh
level=info ts=2018-10-19T12:40:51.650462756Z caller=main.go:213 msg="Starting blackbox_exporter" version="(version=0.12.0, branch=HEAD, revision=4a22506cf0cf139d9b2f9cde099f0012d9fcabde)"
level=info ts=2018-10-19T12:40:51.653357722Z caller=main.go:220 msg="Loaded config file"
level=info ts=2018-10-19T12:40:51.65349635Z caller=main.go:324 msg="Listening on address" address=:9115
```

이제 터미널에서 IPv4를 사용하는 새로운 모듈 `http_2xx`를 사용해볼 수 있다:

```sh
curl 'localhost:9115/probe?target=prometheus.io&module=http_2xx'
```

그러면 다음과 같은 프로메테우스 메트릭들이 보일 거다:

```prometheus
# HELP probe_dns_lookup_time_seconds Returns the time taken for probe dns lookup in seconds
# TYPE probe_dns_lookup_time_seconds gauge
probe_dns_lookup_time_seconds 0.02679421
# HELP probe_duration_seconds Returns how long the probe took to complete in seconds
# TYPE probe_duration_seconds gauge
probe_duration_seconds 0.461619124
# HELP probe_failed_due_to_regex Indicates if probe failed due to regex
# TYPE probe_failed_due_to_regex gauge
probe_failed_due_to_regex 0
# HELP probe_http_content_length Length of http content response
# TYPE probe_http_content_length gauge
probe_http_content_length -1
# HELP probe_http_duration_seconds Duration of http request by phase, summed over all redirects
# TYPE probe_http_duration_seconds gauge
probe_http_duration_seconds{phase="connect"} 0.062076202999999996
probe_http_duration_seconds{phase="processing"} 0.23481845699999998
probe_http_duration_seconds{phase="resolve"} 0.029594103
probe_http_duration_seconds{phase="tls"} 0.163420078
probe_http_duration_seconds{phase="transfer"} 0.002243199
# HELP probe_http_redirects The number of redirects
# TYPE probe_http_redirects gauge
probe_http_redirects 1
# HELP probe_http_ssl Indicates if SSL was used for the final redirect
# TYPE probe_http_ssl gauge
probe_http_ssl 1
# HELP probe_http_status_code Response HTTP status code
# TYPE probe_http_status_code gauge
probe_http_status_code 200
# HELP probe_http_uncompressed_body_length Length of uncompressed response body
# TYPE probe_http_uncompressed_body_length gauge
probe_http_uncompressed_body_length 14516
# HELP probe_http_version Returns the version of HTTP of the probe response
# TYPE probe_http_version gauge
probe_http_version 1.1
# HELP probe_ip_protocol Specifies whether probe ip protocol is IP4 or IP6
# TYPE probe_ip_protocol gauge
probe_ip_protocol 4
# HELP probe_ssl_earliest_cert_expiry Returns earliest SSL cert expiry in unixtime
# TYPE probe_ssl_earliest_cert_expiry gauge
probe_ssl_earliest_cert_expiry 1.581897599e+09
# HELP probe_success Displays whether or not the probe was a success
# TYPE probe_success gauge
probe_success 1
# HELP probe_tls_version_info Contains the TLS version used
# TYPE probe_tls_version_info gauge
probe_tls_version_info{version="TLS 1.3"} 1
```

프로브가 제대로 동작했다는 것을 확인 수 있으며, 단계별 지연 시간, 상태 코드, SSL 상태, 인증서가 만료되는 [Unix 시간](https://en.wikipedia.org/wiki/Unix_time)등을 보여주는 유용한 메트릭들을 조회할 수 있다.<br>
이 외에도 blackbox 익스포터는 [localhost:9115](http://localhost:9115/)에서 최신 프로브 정보 몇 가지와, 로드한 설정, 디버그 정보를 확인할 수 있는 조그만한 웹 인터페이스도 제공한다. `prometheus.io` 프로브로 직접 연결되는 링크도 제공한다. 무언가가 동작하지 않을 땐 이곳에서 쉽게 원인을 찾을 수 있다.

---

## Querying multi-target exporters with Prometheus

지금까지 다 잘 따라왔으니 자랑스럽게 여겨도 좋다. blackbox 익스포터가 정상적으로 동작하고 있으며, 수동으로 리모트 타겟을 질의하도록 만들 수 있다. 이제 거의 다 왔다. 이번에는 이 쿼리를 프로메테우스가 수행하도록 만들어줘야 한다.

아래에 보이는 설정은 프로메테우스에서 필요한 최소한의 설정이다. 이 설정에선 [앞에서](#query-exporter) 직접 `curl 'localhost:9115/metrics'`를 호출했던 것처럼 프로메테우스가 익스포터 자체 데이터를 스크랩하도록 구성하고 있다.

> **참고:** Docker for Mac이나 Docker for Windows를 사용한다면, 마지막 라인에 `localhost:9115`를 사용할 수 없으며, 반드시 `host.docker.internal:9115`를 사용해야 한다. 이 설정은 이런 운영 체제에서 도커를 구현할 때 사용하는 가상 머신과 관련이 있다. 프로덕션에선 이렇게 사용하면 안 된다.

리눅스 전용 `prometheus.yml`:

```yaml
global:
  scrape_interval: 5s

scrape_configs:
- job_name: blackbox # 익스포터 자체에 관한 메트릭을 가져온다
  metrics_path: /metrics
  static_configs:
    - targets:
      - localhost:9115
```

macOS와 Windows 전용 `prometheus.yml`:

```yaml
global:
  scrape_interval: 5s

scrape_configs:
- job_name: blackbox # 익스포터 자체에 관한 메트릭을 가져온다
  metrics_path: /metrics
  static_configs:
    - targets:
      - host.docker.internal:9115
```

이제 프로메테우스 컨테이너를 실행하고 위에 있는 설정 파일을 마운트시켜라. Linux에선 컨테이너에서 호스트 네트워크에 접근할 수 있는 방식을 이용하기 때문에 MacOS, Windows와는 약간 다른 명령어가 필요하다.

리눅스에서 프로메테우스 실행 (프로덕션에선 `--network="host"`를 사용하지 마라):

<span id="run-prometheus"></span>

```sh
docker \
  run --network="host"\
  --mount type=bind,source="$(pwd)"/prometheus.yml,target=/prometheus.yml,readonly \
  prom/prometheus \
  --config.file="/prometheus.yml"
```

MacOS와 Windows에서 프로메테우스 실행:

```sh
docker \
  run -p 9090:9090 \
  --mount type=bind,source="$(pwd)"/prometheus.yml,target=/prometheus.yml,readonly \
  prom/prometheus \
  --config.file="/prometheus.yml"
```

이 명령어는 [설정 파일을 이용해 blackbox 익스포터를 실행](#run-exporter)했을 때와 유사하게 동작한다.

전부 정확하게 따라했다면, [localhost:9090/targets](http://localhost:9090/targets)로 접근해보면 `blackbox` 아래에서 초록색의 `UP` 상태를 가지고 있는 엔드포인트를 볼 수 있을 거다. 빨간색 `DOWN`이 보인다면 [위에서](#run-exporter) 실행했던 blackbox 익스포터가 현재도 실행 중이 맞는지 확인해봐라. 아무 것도 보이지 않거나 노란색 `UNKNOWN`이 보인다면, 너무 빨리 접근했기 때문이니 몇 초만 기다렸다가 브라우저 탭을 다시 로드해봐라.

프로메테우스가 `"localhost:9115/probe?target=prometheus.io&module=http_2xx"`를 질의하도록 만들려면, 프로메테우스 설정 파일 `prometheus.yml`에 스크랩 job `blackbox-http`를 하나 더 추가해야 한다. 이 job에선 `metrics_path`를 `/probe`로 설정하고, `params` 아래에 파라미터들을 지정한다:

<span id="prometheus-config"></span>
```yaml
global:
  scrape_interval: 5s

scrape_configs:
- job_name: blackbox # 익스포터 자체에 관한 메트릭을 가져온다
  metrics_path: /metrics
  static_configs:
    - targets:
      - localhost:9115   # Windows와 macOS에선 host.docker.internal:9115로 바꿔라

- job_name: blackbox-http # 익스포터의 타겟들에 관한 메트릭을 가져온다
  metrics_path: /probe
  params:
    module: [http_2xx]
    target: [prometheus.io]
  static_configs:
    - targets:
      - localhost:9115   # Windows와 macOS에선 host.docker.internal:9115로 바꿔라
```

설정 파일을 저장했다면 프로메테우스 도커 컨테이너를 실행했던 터미널로 돌아가 `ctrl+C`를 눌러 중지시켜라. 그런 다음 기존 [명령어](#run-prometheus)를 다시 한 번 실행해서 설정을 다시 로드해라.

재시작 후엔 터미널에선 `"Server is ready to receive web requests."`라는 메시지를 반환하고, [프로메테우스](http://localhost:9090/graph?g0.range_input=5m&g0.stacked=0&g0.expr=probe_http_duration_seconds&g0.tab=0)에선 몇 초 후부터 형형색색의 그래프가 보이기 시작할 거다.

문제 없이 동작하고 있지만, 사실 여기에는 몇 가지 결점이 있다:

1. 실제 타겟은 param 설정에 들어 있는데, 나중에 보면 이해하기 어려워서 이렇게 사용하는 경우는 많지 않다.
2. `instance` 레이블은 blackbox 익스포터의 주소를 가지고 있다. 기술적으로 보면 맞는 값이지만, 실제로 알고 싶은 값이 아니다.
3. 메트릭을 보고 어떤 URL을 프로빙한 건지 알아낼 수 없다. 실용적이지도 못하고, 여러 가지 URL을 프로빙한다면 성격이 다른 메트릭들이 하나로 섞이게 될 거다.

이 문제를 해결하기 위해 [relabeling](../configuration/#relabel_config)을 사용해볼 거다. 프로메테우스에선 많은 것들을 내부 레이블로 설정하기 때문에 여기에선 relabeling을 활용해줄 수 있다. 상세한 내용은 복잡하기도 하고 이 문서의 범위를 벗어난다. 따라서 여기서는 필요한 것들만 설명한다. 더 자세히 알아보고 싶다면 이 [연설](https://www.youtube.com/watch?v=b5-SvvZ7AwI)을 시청해봐라. 지금으로선 아래 있는 것들만 이해해도 충분하다:

- `__`로 시작하는 모든 레이블들은 스크랩을 완료한 이후에 삭제된다. 내부 레이블은 대부분 `__`로 시작한다.
- `__param_<name>`이라는 내부 레이블을 설정할 수 있다. 이런 레이블들은 스크랩 요청에서 사용하는 URL에 `<name>` 파라미터를 설정해준다.
- 내부 레이블 중엔 `static_configs` 아래에 있는 `targets`로 설정되는 `__address__` 레이블이 있다. 이 레이블엔스크랩을 요청할 호스트명이 담겨있다. 이후 각 메트릭의 출처를 알 수 있도록 메트릭마다 `instance` 레이블을 첨부할 때는 기본적으로 이 레이블을 이용하게 된다.

다음은 relabeling을 위한 설정이다. 한 번에 너무 많은 내용이 나온 것 같이 느껴져도 걱정할 필요 없다. 단계별로 하나씩 파헤쳐볼 거다:

```yaml
global:
  scrape_interval: 5s

scrape_configs:
- job_name: blackbox # 익스포터 자체에 관한 메트릭을 가져온다
  metrics_path: /metrics
  static_configs:
    - targets:
      - localhost:9115   # Windows와 macOS에선 host.docker.internal:9115로 바꿔라

- job_name: blackbox-http # 익스포터의 타겟들에 관한 메트릭을 가져온다
  metrics_path: /probe
  params:
    module: [http_2xx]
  static_configs:
    - targets:
      - http://prometheus.io    # http로 프로빙할 타겟
      - https://prometheus.io   # https로 프로빙할 타겟
      - http://example.com:8080 # 8080 포트에서 http로 프로빙할 타겟
  relabel_configs:
    - source_labels: [__address__]
      target_label: __param_target
    - source_labels: [__param_target]
      target_label: instance
    - target_label: __address__
      replacement: localhost:9115  # blackbox 익스포터의 실제 hostname:port. Windows와 macOS에선 host.docker.internal:9115로 바꿔라
```

[마지막으로 사용했던 설정](#prometheus-config)과 비교하면 어떤 게 달라졌을까?

`params`에는 더 이상 `target`이 들어있지 않다. 대신 `static configs:` `targets` 아래에다가 실제 타겟들을 추가한다. 이번에는 타겟이 여러 개 있어도 상관 없기 때문에 다른 타겟들도 추가했다:

```yaml
  params:
    module: [http_2xx]
  static_configs:
    - targets:
      - http://prometheus.io    # http로 프로빙할 타겟
      - https://prometheus.io   # https로 프로빙할 타겟
      - http://example.com:8080 # 8080 포트에서 http로 프로빙할 타겟
```

`relabel_configs`는 새로운 relabeling rule을 가지고 있다:

```yaml
  relabel_configs:
    - source_labels: [__address__]
      target_label: __param_target
    - source_labels: [__param_target]
      target_label: instance
    - target_label: __address__
      replacement: localhost:9115  # blackbox 익스포터의 실제 hostname:port. Windows와 macOS에선 host.docker.internal:9115로 바꿔라
```

relabeling rule을 적용하기 전에 프로메테우스가 만드는 요청의 URI는 `"http://prometheus.io/probe?module=http_2xx"`와 같이 생겼다. relabeling을 적용한 후에는 `"http://localhost:9115/probe?target=http://prometheus.io&module=http_2xx"`와 같이 바뀌게 된다.

이제 어떻게 이게 가능한건지 rule들을 하나씩 파헤쳐보자:

먼저 `__address__` 레이블을 가져와서 (`targets`에 있는 값들을 가지고 있는 레이블), 프로메테우스 스크랩 요청에서 보내는 `target` 파라미터에 이 값을 추가하도록 `__param_target`이라는 새로운 레이블에 저장한다:

```yaml
  relabel_configs:
    - source_labels: [__address__]
      target_label: __param_target
```

이 rule을 적용하고 나면 타겟 파라미터를 가지고 있는 프로메테우스 요청 URI를 그려볼 수 있다 (`"http://prometheus.io/probe?target=http://prometheus.io&module=http_2xx"`).

그런 다음 이 `__param_target` 레이블을 가져와서, 이 값들로 instance 레이블을 생성한다.

```yaml
  relabel_configs:
    - source_labels: [__param_target]
      target_label: instance
```

여기선 요청은 변경하지 않지만, 요청으로 가지고 오는 메트릭은 이제 `instance="http://prometheus.io"`라는 레이블을 갖게된다.

그 다음엔 `__address__` 레이블에 익스포터 URI `localhost:9115`를 저장한다. 프로메테우스의 스크랩 요청에선 이 값을 호스트명과 포트로 사용한다. 따라서 타겟 URI를 직접 스크랩하지 않고 익스포터를 질의하게 된다.

```yaml
  relabel_configs:
    - target_label: __address__
      replacement: localhost:9115  # blackbox 익스포터의 실제 hostname:port. Windows와 macOS에선 host.docker.internal:9115로 바꿔라
```

이제는 `"localhost:9115/probe?target=http://prometheus.io&module=http_2xx"`와 같은 요청을 생성한다. 이렇게 설정해주면 프로메테우스는 blackbox 익스포터에 요청을 전송하면서도, 실제 타겟들을 `instance` 레이블에 저장할 수 있다.

이 테크닉은 특정 서비스 디스커버리와 결합해서 쓰는 사람들도 많다. 자세한 내용은 [설정 문서](../configuration)를 확인해봐라. `static_configs` 밑에 `targets`를 정의하는 방식 그대로 `__address__` 레이블을 지정해주면 되기 때문에 서비스 디스커버리에서도 이 테크닉을 활용할 수 있다.

이게 전부다. 프로메테우스 도커 컨테이너를 재시작하고 [메트릭](http://localhost:9090/graph?g0.range_input=30m&g0.stacked=0&g0.expr=probe_http_duration_seconds&g0.tab=0)을 확인해봐라. 메트릭을 실제로 수집한 기간을 선택했는지 유의해라.

# SUMMARY

이 가이드에선 멀티 타겟 익스포터 패턴의 동작 방식과, blackbox 익스포터를 커스텀 모듈로 실행하는 방법, relabeling과 프로버 레이블을 이용해 프로메테우스로 메트릭을 스크랩하는 방법을 알아봤다.