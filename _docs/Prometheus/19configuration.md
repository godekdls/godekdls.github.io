---
title: Configuration
category: Prometheus
order: 19
permalink: /Prometheus/configuration/
description: 프로메테우스 스크랩 설정 가이드
image: ./../../images/prometheus/logo.png
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/prometheus/2.32/configuration/configuration/
parent: PROMETHEUS
parentUrl: /Prometheus/prometheus/
subparent: Configuration
subparentUrl: /Prometheus/config/
priority: 0.7
---

---

프로메테우스 설정은 커맨드라인 플래그와 설정 파일을 이용한다. 커맨드라인 플래그로는 변하지 않는<sup>immutable</sup> 시스템 파라미터들을 설정하고 (스토리지 위치, 디스크나 메모리에 보관할 데이터 양 등), 설정 파일에는 스크랩할 [job, 인스턴스](../jobs-instances)와 관련된 모든 정보들과 [로드할 rule 파일들](../recording-rules#configuring-rules)을 정의한다.

`./prometheus -h`를 실행하면 사용할 수 있는 전체 커맨드라인 플래그를 조회해볼 수 있다.

프로메테우스는 런타임에 설정을 다시 로드할 수 있다. 새 설정 파일의 형식이 잘못됐다면 변경 사항을 적용하지 않는다. 프로메테우스 프로세스에 `SIGHUP`을 전송하거나, `/-/reload` 엔드포인트에 HTTP POST 요청을 보내면 (`--web.enable-lifecycle` 플래그를 활성화한 경우) 설정을 다시 로드할 수 있다. 이렇게하면 설정해둔 rule 파일도 전부 다시 로드한다.


### 목차

- [Configuration file](#configuration-file)
  + [\<scrape_config\>](#scrape_config)
  + [\<tls_config\>](#tls_config)
  + [\<oauth2\>](#oauth2)
  + [\<azure_sd_config\>](#azure_sd_config)
  + [\<consul_sd_config\>](#consul_sd_config)
  + [\<digitalocean_sd_config\>](#digitalocean_sd_config)
  + [\<docker_sd_config\>](#docker_sd_config)
  + [\<dockerswarm_sd_config\>](#dockerswarm_sd_config)
    * [services](#services)
    * [tasks](#tasks)
    * [nodes](#nodes)
  + [\<dns_sd_config\>](#dns_sd_config)
  + [\<ec2_sd_config\>](#ec2_sd_config)
  + [\<openstack_sd_config\>](#openstack_sd_config)
    * [hypervisor](#hypervisor)
    * [instance](#instance)
  + [\<puppetdb_sd_config\>](#puppetdb_sd_config)
  + [\<file_sd_config\>](#file_sd_config)
  + [\<gce_sd_config\>](#gce_sd_config)
  + [\<hetzner_sd_config\>](#hetzner_sd_config)
  + [\<http_sd_config\>](#http_sd_config)
  + [\<kubernetes_sd_config\>](#kubernetes_sd_config)
    * [node](#node)
    * [service](#service)
    * [pod](#pod)
    * [endpoints](#endpoints)
    * [endpointslice](#endpointslice)
    * [ingress](#ingress)
  + [\<kuma_sd_config\>](#kuma_sd_config)
  + [\<lightsail_sd_config\>](#lightsail_sd_config)
  + [\<linode_sd_config\>](#linode_sd_config)
  + [\<marathon_sd_config\>](#marathon_sd_config)
  + [\<nerve_sd_config\>](#nerve_sd_config)
  + [\<serverset_sd_config\>](#serverset_sd_config)
  + [\<triton_sd_config\>](#triton_sd_config)
    * [container](#container)
    * [cn](#cn)
  + [\<eureka_sd_config\>](#eureka_sd_config)
  + [\<scaleway_sd_config\>](#scaleway_sd_config)
    * [Instance role](#instance-role)
    * [Baremetal role](#baremetal-role)
  + [\<uyuni_sd_config\>](#uyuni_sd_config)
  + [\<static_config\>](#static_config)
  + [\<relabel_config\>](#relabel_config)
  + [\<metric_relabel_configs\>](#metric_relabel_configs)
  + [\<alert_relabel_configs\>](#alert_relabel_configs)
  + [\<alertmanager_config\>](#alertmanager_config)
  + [\<remote_write\>](#remote_write)
  + [\<remote_read\>](#remote_read)
  + [\<exemplars\>](#exemplars)

---

## Configuration file

로드할 설정 파일을 지정할 땐 `--config.file` 플래그를 사용한다.

설정 파일은 [YAML 형식](https://en.wikipedia.org/wiki/YAML)으로 작성하며, 아래에서 설명하는 스키마로 정의한다. 대괄호는 파라미터를 생략할 수 있음을 나타낸다. 리스트가 아닌 일반 파라미터들엔 디폴트 값을 명시해놨다.

공통으로 사용하는 플레이스홀더는 다음과 같다:

- `<boolean>`: `true`, `false`를 사용하는 boolean
- `<duration>`: 정규 표현식 `((([0-9]+)y)?(([0-9]+)w)?(([0-9]+)d)?(([0-9]+)h)?(([0-9]+)m)?(([0-9]+)s)?(([0-9]+)ms)?|0)`에 매칭되는 기간. ex) `1d`, `1h30m`, `5m`, `10s`
- `<filename>`: 현재 작업 디렉토리 안에 있는 유효한 경로
- `<host>`: 호스트명이나 IP로 구성된 유효한 문자열 (뒤에 포트 번호가 있을 수도 있음)
- `<int>`: 정수 값
- `<labelname>`: 정규 표현식 `[a-zA-Z_][a-zA-Z0-9_]*`에 매칭되는 문자열
- `<labelvalue>`: 유니 코드 문자로 이루어진 문자열
- `<path>`: 유효한 URL path
- `<scheme>`: `http`나 `https`를 사용할 수 있는 문자열
- `<secret>`: 비밀번호 같이 평소 시크릿에 사용하는 문자열
- `<string>`: 평범한 문자열
- `<size>`: 바이트로 표현하는 사이즈. ex. `512MB`. 단위를 명시해야 한다. 지원하는 단위: B, KB, MB, GB, TB, PB, EB.
- `<tmpl_string>`: 사용 전에 템플릿을 이용해 확장되는 문자열

그 외 다른 플레이스홀더는 별도로 명시했다.

유효한 예제 파일은 [여기](https://github.com/prometheus/prometheus/blob/release-2.32/config/testdata/conf.good.yml)에서 찾을 수 있다.

글로벌 설정에서 명시한 파라미터들은 모든 설정 컨텍스트에서 유효하다. 나머지 설정 섹션의 디폴트 값 역할도 수행한다.

```yaml
global:
  # 기본적으로 타겟을 스크랩할 간격.
  [ scrape_interval: <duration> | default = 1m ]

  # 스크랩 요청을 언제 타임 아웃시킬지.
  [ scrape_timeout: <duration> | default = 10s ]

  # rule들을 평가하는 주기.
  [ evaluation_interval: <duration> | default = 1m ]

  # 외부 시스템(federation, 리모트 스토리지, Alertmanager)과 통신할 때
  # 모든 시계열, alert에 추가할 레이블들.
  external_labels:
    [ <labelname>: <labelvalue> ... ]

  # PromQL 쿼리 로그를 남길 파일.
  # 설정을 다시 로드하면 이 파일도 다시 연다.
  [ query_log_file: <string> ]

# Rule files에선 glob 패턴 리스트를 지정한다.
# 매칭되는 모든 파일에서 rules와 alerts를 읽어들인다.
rule_files:
  [ - <filepath_glob> ... ]

# 스크랩 설정 목록.
scrape_configs:
  [ - <scrape_config> ... ]

# Alerting에선 Alertmanager와 관련된 설정들을 지정한다.
alerting:
  alert_relabel_configs:
    [ - <relabel_config> ... ]
  alertmanagers:
    [ - <alertmanager_config> ... ]

# remote write 기능과 관련된 설정들.
remote_write:
  [ - <remote_write> ... ]

# remote read 기능과 관련된 설정들.
remote_read:
  [ - <remote_read> ... ]
  
# 런타임에 다시 로드할 수 있는 스토리지 관련 설정들.
storage:
  [ - <exemplars> ... ]  
```

### `<scrape_config>`

`scrape_config` 섹션엔 스크랩할 타겟들과, 스크랩할 방법을 묘사하는 파라미터들을 지정한다. 보통은 스크랩 설정 하나로 job 하나를 지정한다. 복잡한 설정을 추가할 땐 달라질 수 있다.

스크랩 타겟은 `static_configs` 파라미터를 통해 정적으로 설정할 수도 있고, 지원하는 서비스 디스커버리 메커니즘 중 하나를 이용해 동적으로 잡아낼 수도 있다.

이 밖에도, `relabel_configs`를 사용하면 스크랩하기 전에 모든 타겟과 레이블들을 더 수정할 수 있다.

```yaml
# 스크랩한 메트릭에 기본적으로 할당하는 job 이름
job_name: <job_name>

# 이 job에서 타겟들을 스크랩할 간격.
[ scrape_interval: <duration> | default = <global_config.scrape_interval> ]

# 이 job을 스크랩할 때마다 사용할 타임 아웃.
[ scrape_timeout: <duration> | default = <global_config.scrape_timeout> ]

# 타겟들에서 메트릭을 가져올 때 사용할 HTTP 리소스 경로
[ metrics_path: <path> | default = /metrics ]

# honor_labels는 프로메테우스가 서버 사이드에서 첨부하는 레이블과
# ("job"/"instance" 레이블, 수동으로 설정한 타겟 레이블, 서비스 디스커버리 구현체가 생성한 레이블)
# 스크랩한 데이터에 이미 있는 레이블이 충돌하면 프로메테우스에서 어떻게 처리할지를 결정한다.
#
# honor_labels를 "true"로 설정하면, 스크랩한 데이터에 있는 레이블을 유지하고
# 충돌하는 서버 사이드 레이블을 무시하는 식으로 충돌을 해소한다.
#
# honor_labels를 "false"로 설정하면, 스크랩한 데이터에서 충돌하는 레이블들의 이름을
# "exported_<original-label>"로 변경한 다음 (ex. "exported_instance", "exported_job")
# 서버 사이드 레이블들을 첨부하는 식으로 충돌을 해소한다.
#
# 타겟에 지정한 모든 레이블을 보존해야 하는 federation과 Pushgateway 스크랩 등을 사용할 땐
# honor_labels를 "true"로 설정해주면 된다.
#
# 참고로, 글로벌로 설정한 "external_labels"는 이 설정에 영향 받지 않는다. 
# 외부 시스템과 통신할 때는 항상, 시계열에 주어진 레이블이 이미 없을 때에만 적용하며, 그 외는 무시한다.
[ honor_labels: <boolean> | default = false ]

# honor_timestamps는 프로메테우스가 스크랩한 데이터에 있는 타임스탬프를 그대로 따를지 여부를 결정한다.
#
# honor_timestamps를 "true"로 설정하면, 타겟이 노출한 메트릭의 타임스탬프를 사용한다.
#
# honor_timestamps를 "false"로 설정하면, 타겟이 노출한 메트릭의 타임스탬프는 무시한다.
[ honor_timestamps: <boolean> | default = true ]

# 요청에 사용할 프로토콜 스킴을 설정한다.
[ scheme: <scheme> | default = http ]

# HTTP URL 파라미터들 (Optional).
params:
  [ <string>: [<string>, ...] ]

# 설정한 username과 password로 모든 스크랩 요청에 'Authorization' 헤더를 세팅한다.
# password와 password_file은 함께 사용할 수 없다.
basic_auth:
  [ username: <string> ]
  [ password: <secret> ]
  [ password_file: <string> ]

# 설정한 credential로 모든 스크랩 요청에 'Authorization' 헤더를 세팅한다.
authorization:
  # 요청에서 사용할 인증 타입을 설정한다.
  [ type: <string> | default: Bearer ]
  # 요청에서 사용할 credential을 설정한다.
  # `credentials_file`과는 함께 사용할 수 없다.
  [ credentials: <secret> ]
  # 요청에서 사용할 credential은 설정한 파일에서 읽어온 credential로 설정한다.
  # `credentials`와는 함께 사용할 수 없다.
  [ credentials_file: <filename> ]

# OAuth 2.0 설정 (Optional).
# basic_auth나 authorization과는 동시에 사용할 수 없다.
oauth2:
  [ <oauth2> ]

# 스크랩 요청에서 HTTP 3xx 리다이렉트 지시를 따를지 여부를 설정한다.
[ follow_redirects: <bool> | default = true ]

# 스크랩 요청에서 사용할 TLS 설정을 구성한다.
tls_config:
  [ <tls_config> ]

# 프록시 URL (Optional).
[ proxy_url: <string> ]

# Azure 서비스 디스커버리 설정 목록.
azure_sd_configs:
  [ - <azure_sd_config> ... ]

# Consul 서비스 디스커버리 설정 목록.
consul_sd_configs:
  [ - <consul_sd_config> ... ]

# DigitalOcean 서비스 디스커버리 설정 목록.
digitalocean_sd_configs:
  [ - <digitalocean_sd_config> ... ]

# Docker 서비스 디스커버리 설정 목록.
docker_sd_configs:
  [ - <docker_sd_config> ... ]

# Docker Swarm 서비스 디스커버리 설정 목록.
dockerswarm_sd_configs:
  [ - <dockerswarm_sd_config> ... ]

# DNS 서비스 디스커버리 설정 목록.
dns_sd_configs:
  [ - <dns_sd_config> ... ]

# EC2 서비스 디스커버리 설정 목록.
ec2_sd_configs:
  [ - <ec2_sd_config> ... ]

# Eureka 서비스 디스커버리 설정 목록.
eureka_sd_configs:
  [ - <eureka_sd_config> ... ]

# file 서비스 디스커버리 설정 목록.
file_sd_configs:
  [ - <file_sd_config> ... ]

# GCE 서비스 디스커버리 설정 목록.
gce_sd_configs:
  [ - <gce_sd_config> ... ]

# Hetzner 서비스 디스커버리 설정 목록.
hetzner_sd_configs:
  [ - <hetzner_sd_config> ... ]

# HTTP 서비스 디스커버리 설정 목록.
http_sd_configs:
  [ - <http_sd_config> ... ]

# Kubernetes 서비스 디스커버리 설정 목록.
kubernetes_sd_configs:
  [ - <kubernetes_sd_config> ... ]

# Kuma 서비스 디스커버리 설정 목록.
kuma_sd_configs:
  [ - <kuma_sd_config> ... ]

# Lightsail 서비스 디스커버리 설정 목록.
lightsail_sd_configs:
  [ - <lightsail_sd_config> ... ]

# Linode 서비스 디스커버리 설정 목록.
linode_sd_configs:
  [ - <linode_sd_config> ... ]

# Marathon 서비스 디스커버리 설정 목록.
marathon_sd_configs:
  [ - <marathon_sd_config> ... ]

# AirBnB의 Nerve 서비스 디스커버리 설정 목록.
nerve_sd_configs:
  [ - <nerve_sd_config> ... ]

# OpenStack 서비스 디스커버리 설정 목록.
openstack_sd_configs:
  [ - <openstack_sd_config> ... ]

# PuppetDB 서비스 디스커버리 설정 목록.
puppetdb_sd_configs:
  [ - <puppetdb_sd_config> ... ]

# Scaleway 서비스 디스커버리 설정 목록.
scaleway_sd_configs:
  [ - <scaleway_sd_config> ... ]

# Zookeeper Serverset 서비스 디스커버리 설정 목록.
serverset_sd_configs:
  [ - <serverset_sd_config> ... ]

# Triton 서비스 디스커버리 설정 목록.
triton_sd_configs:
  [ - <triton_sd_config> ... ]

# Uyuni 서비스 디스커버리 설정 목록.
uyuni_sd_configs:
  [ - <uyuni_sd_config> ... ]

# 이 job으로 분류할 타겟 목록을 정적으로 설정한다.
static_configs:
  [ - <static_config> ... ]

# 타겟 relabel 설정 목록.
relabel_configs:
  [ - <relabel_config> ... ]

# 메트릭 relabel 설정 목록.
metric_relabel_configs:
  [ - <relabel_config> ... ]

# 압축하지 않은 응답 바디가 이 사이즈를 넘어가면 스크랩에 실패한다.
# 0은 제한이 없음을 의미한다. ex: 100MB.
# 이 설정은 실험적인 기능으로, 향후 동작이 변경되거나 제거될 수 있다.
[ body_size_limit: <size> | default = 0 ]

# 스크랩 단위로 허용할 샘플 수를 제한한다.
# 메트릭 relabeling을 적용한 후에 샘플 수가 이 숫자보다 많으면
# 스크랩 자체를 실패한 것으로 처리한다. 0은 제한이 없음을 의미한다.
[ sample_limit: <int> | default = 0 ]

# 스크랩 단위로 샘플 하나에서 허용할 레이블 수를 제한한다.
# 메트릭 relabeling을 적용한 후에 레이블 수가 이 숫자보다 많으면
# 스크랩 자체를 실패한 것으로 처리한다. 0은 제한이 없음을 의미한다.
[ label_limit: <int> | default = 0 ]

# 스크랩 단위로 샘플에서 허용할 레이블명의 길이를 제한한다.
# 메트릭 relabeling을 적용한 후에 레이블명이 이 숫자보다 길면
# 스크랩 자체를 실패한 것으로 처리한다. 0은 제한이 없음을 의미한다.
[ label_name_length_limit: <int> | default = 0 ]

# 스크랩 단위로 샘플에서 허용할 레이블 값의 길이를 제한한다.
# 메트릭 relabeling을 적용한 후에 레이블 값이 이 숫자보다 길면
# 스크랩 자체를 실패한 것으로 처리한다. 0은 제한이 없음을 의미한다.
[ label_value_length_limit: <int> | default = 0 ]

# 스크랩 단위로 설정할 수 있는 고유 타겟 수를 제한한다.
# 타겟 relabeling을 적용한 후에 타겟이 이 숫자보다 많으면,
# 프로메테우스는 타겟들을 스크랩하지 않고 실패한 것으로 마킹한다.
# 0은 제한이 없음을 의미한다.
# 이 설정은 실험적인 기능으로, 향후 동작이 변경될 수 있다.
[ target_limit: <int> | default = 0 ]
```

여기서 `<job_name>`은 전체 스크랩 설정에서 유니크한 값이어야 한다.

### `<tls_config>`

`tls_config`를 사용하면 TLS 커넥션을 설정할 수 있다.

```yaml
# API 서버 인증서를 검증할 CA 인증서.
[ ca_file: <filename> ]

# 서버로 클라이언트 인증서를 보내 인증하기 위한 인증서 파일과 키 파일.
[ cert_file: <filename> ]
[ key_file: <filename> ]

# 서버 이름을 명시할 수 있는 ServerName 익스텐션.
# https://tools.ietf.org/html/rfc4366#section-3.1
[ server_name: <string> ]

# 서버 인증서의 유효성 검사를 비활성화한다.
[ insecure_skip_verify: <boolean> ]
```

### `<oauth2>`

client credentials grant 타입을 사용하는 OAuth 2.0 인증. 프로메테우스는 설정한 클라이언트 액세스 권한과 시크릿 키를 사용해서 지정한 엔드포인트로부터 액세스 토큰을 가져온다.

```yaml
client_id: <string>
[ client_secret: <secret> ]

# 파일에서 클라이언트 시크릿을 읽어온다.
# `client_secret`과는 함께 사용할 수 없다.
[ client_secret_file: <filename> ]

# 토큰 요청에서 사용할 scope들.
scopes:
  [ - <string> ... ]

# 토큰을 가져올 URL.
token_url: <string>

# 토큰 URL에 첨부할 파라미터들 (Optional).
endpoint_params:
  [ <string>: <string> ... ]

# 토큰 요청에서 사용할 TLS 설정을 구성한다.
tls_config:
  [ <tls_config> ]
```

### `<azure_sd_config>`

Azure SD 설정을 사용하면 Azure VM에서 스크랩 타겟을 가져올 수 있다.

[relabeling](#relabel_config) 동안에는 잠시 타겟에 아래와 같은 메타 레이블들이 추가된다:

- `__meta_azure_machine_id`: 머신 ID
- `__meta_azure_machine_location`: 머신을 실행하는 위치
- `__meta_azure_machine_name`: 머신 이름
- `__meta_azure_machine_computer_name`: 머신 컴퓨터 이름
- `__meta_azure_machine_os_type`: 머신 운영 체제
- `__meta_azure_machine_private_ip`: 머신의 private IP
- `__meta_azure_machine_public_ip`: 머신의 public IP (있다면)
- `__meta_azure_machine_resource_group`: 머신의 리스소 그룹
- `__meta_azure_machine_tag_<tagname>`: 머신의 각 태그 값
- `__meta_azure_machine_scale_set`: vm이 속해있는 스케일 셋의 이름 ([스케일 셋](https://docs.microsoft.com/en-us/azure/virtual-machine-scale-sets/)을 사용하는 경우만)
- `__meta_azure_subscription_id`: subscription ID
- `__meta_azure_tenant_id`: tenant ID

Azure 디스커버리 설정 옵션은 아래를 참고해라:

```yaml
# Azure API에 접근하기 위한 정보.
# Azure 환경.
[ environment: <string> | default = AzurePublicCloud ]

# 인증 방식. OAuth, ManagedIdentity 중 하나.
# https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview 참고
[ authentication_method: <string> | default = OAuth]
# subscription ID. 항상 필요하다.
subscription_id: <string>
# tenant ID (Optional). authentication_method가 OAuth일 때만 필요하다.
[ tenant_id: <string> ]
# 클라이언트 ID (Optional). authentication_method가 OAuth일 때만 필요하다.
[ client_id: <string> ]
# 클라이언트 시크릿 (Optional). authentication_method가 OAuth일 때만 필요하다.
[ client_secret: <secret> ]

# 인스턴스 목록을 다시 읽어오기 위한 리프레시 간격.
[ refresh_interval: <duration> | default = 300s ]

# 메트릭을 스크랩할 포트.
# public IP를 사용한다면, 이 곳이 아닌 relabeling rule에서 지정해야 한다.
[ port: <int> | default = 80 ]

# Azure 서버에 인증할 때 사용하는 인증 정보.
# 참고로, `basic_auth`와 `authorization`, `oauth2`는 함께 사용할 수 없다.
# `password`와 `password_file`도 함께 사용할 수 없다.

# HTTP 기본 인증 정보 (Optional). 현재 Azure에서 지원하지 않는다.
basic_auth:
  [ username: <string> ]
  [ password: <secret> ]
  [ password_file: <string> ]

# `Authorization` 헤더 설정 (Optional). 현재 Azure에서 지원하지 않는다.
authorization:
  # 인증 타입을 설정한다.
  [ type: <string> | default: Bearer ]
  # credential을 설정한다.
  # `credentials_file`과는 함께 사용할 수 없다.
  [ credentials: <secret> ]
  # 설정한 파일에서 읽어온 credential을 설정한다.
  # `credentials`와는 함께 사용할 수 없다.
  [ credentials_file: <filename> ]

# OAuth 2.0 설정 (Optional). 현재 Azure에서 지원하지 않는다.
oauth2:
  [ <oauth2> ]

# 프록시 URL (Optional).
[ proxy_url: <string> ]

# HTTP 요청에서 HTTP 3xx 리다이렉트 지시를 따를지 여부를 설정한다.
[ follow_redirects: <bool> | default = true ]

# TLS 설정.
tls_config:
  [ <tls_config> ]
```

### `<consul_sd_config>`

Consul SD 설정을 사용하면 [Consul의](https://www.consul.io/) Catalog API로 스크랩 타겟을 가져올 수 있다.

[relabeling](#relabel_config) 동안에는 잠시 타겟에 아래와 같은 메타 레이블들이 추가된다:

- `__meta_consul_address`: 타겟의 주소
- `__meta_consul_dc`: 타겟의  데이터센터 이름
- `__meta_consul_health`: 서비스의 health status
- `__meta_consul_metadata_<key>`: 타겟의 각 노드 메타데이터 키 값
- `__meta_consul_node`: 타겟에 정의한 노드명
- `__meta_consul_service_address`: 타겟의 서비스 주소
- `__meta_consul_service_id`: 타겟의 서비스 ID
- `__meta_consul_service_metadata_<key>`: 타겟의 각 서비스 메타데이터 키 값
- `__meta_consul_service_port`: 타겟의 서비스 포트
- `__meta_consul_service`: 타겟이 속해있는 서비스 이름
- `__meta_consul_tagged_address_<key>`: 타겟의 각 노드에 태깅한 주소 키 값
- `__meta_consul_tags`: 타겟의 태그 목록 (구분 기호로 연결)

```yaml
# Consul API에 접근하기 위한 정보.
# Consul 문서에서 요구하는 대로 정의해야 한다.
[ server: <host> | default = "localhost:8500" ]
[ token: <secret> ]
[ datacenter: <string> ]
# 네임스페이스는 Consul Enterprise에서만 지원한다.
[ namespace: <string> ]
[ scheme: <string> | default = "http" ]
# username과 password 필드는 deprecated 되었으며, basic_auth 설정으로 대신한다.
[ username: <string> ]
[ password: <secret> ]

# 타겟을 조회할 서비스 목록.
# 생략하면 모든 서비스를 스크랩한다.
services:
  [ - <string> ]

# 사용할 수 있는 필터에 대한 자세한 내용은 https://www.consul.io/api/catalog.html#list-nodes-for-service를 참고해라.

# 주어진 서비스에서 노드를 필터링할 때 사용할 태그 리스트 (optional).
# 서비스들은 이 목록에 있는 태그를 전부 가지고 있어야 한다.
tags:
  [ - <string> ]

# 주어진 서비스에서 노드를 필터링하기 위한 노드 메타데이터 키/값 쌍.
[ node_meta:
  [ <string>: <string> ... ] ]

# Consul 태그들을 하나의 태그 레이블로 합칠 때 사용할 문자열.
[ tag_separator: <string> | default = , ]

# Consul의 stale read 모드를 허용한다 (https://www.consul.io/api/features/consistency.html 참고).
# Consul 부하를 줄여준다.
[ allow_stale: <boolean> | default = true ]

# 주어진 이름들을 리프레시할 시간.
# 대규모 세팅에선 카탈로그가 언제든지 변경될 수 있으므로 이 값은 크게 잡아주는 게 좋다.
[ refresh_interval: <duration> | default = 30s ]

# consul 서버에 인증할 때 사용하는 인증 정보.
# 참고로, `basic_auth`와 `authorization`, `oauth2` 옵션은 함께 사용할 수 없다.
# `password`와 `password_file`도 함께 사용할 수 없다.

# HTTP 기본 인증 정보 (Optional).
basic_auth:
  [ username: <string> ]
  [ password: <secret> ]
  [ password_file: <string> ]

# `Authorization` 헤더 설정 (Optional).
authorization:
  # 인증 타입을 설정한다.
  [ type: <string> | default: Bearer ]
  # credential을 설정한다.
  # `credentials_file`과는 함께 사용할 수 없다.
  [ credentials: <secret> ]
  # 설정한 파일에서 읽어온 credential을 설정한다.
  # `credentials`와는 함께 사용할 수 없다.
  [ credentials_file: <filename> ]

# OAuth 2.0 설정 (Optional).
oauth2:
  [ <oauth2> ]

# 프록시 URL (Optional).
[ proxy_url: <string> ]

# HTTP 요청에서 HTTP 3xx 리다이렉트 지시를 따를지 여부를 설정한다.
[ follow_redirects: <bool> | default = true ]

# TLS 설정.
tls_config:
  [ <tls_config> ]
```

타겟을 스크랩할 때 사용하는 IP 번호와 포트는 `<__meta_consul_address>:<__meta_consul_service_port>`로 조합한다. 하지만 Consul 세팅에 따라, 관련 주소가 `__meta_consul_service_address`에 들어있을 때도 있다. 이럴 때는 [relabel](#relabel_config) 기능을 사용해 전용 레이블 `__address__`를 교체해주면 된다.

원하는 레이블들을 사용해서 서비스나 서비스의 노드들을 필터링하고 싶다면, [relabeling 단계](#relabel_config)를 이용하는 게 좀더 효과적으로 필터링할 수도 있고, 권장하는 방법이기도 하다. 단, 수천 개의 서비스를 사용하고 있다면, 기본적인 노드 필터링을 지원하는 (현재는 노드 메타데이터와 단일 태그로 필터링) Consul API를 직접 사용하는 게 더 효율적일 수도 있다.

### `<digitalocean_sd_config>`

DigitalOcean SD 설정을 사용하면 [DigitalOcean의](https://www.digitalocean.com/) Droplets API로 스크랩 타겟을 가져올 수 있다. 이때 서비스 디스커버리는 기본적으로 public IPv4 주소를 사용하며, [이 프로메테우스 digitalocean-sd 설정 파일](https://github.com/prometheus/prometheus/blob/release-2.32/documentation/examples/prometheus-digitalocean.yml)에서 보여주는 것처럼 relabelling을 통해 변경할 수 있다.

[relabeling](#relabel_config) 동안에는 잠시 타겟에 아래와 같은 메타 레이블들이 추가된다:

- `__meta_digitalocean_droplet_id`: droplet의 id
- `__meta_digitalocean_droplet_name`: droplet의 이름
- `__meta_digitalocean_image`: droplet 이미지의 slug
- `__meta_digitalocean_image_name`: droplet 이미지의 표기명
- `__meta_digitalocean_private_ipv4`: droplet의 private IPv4
- `__meta_digitalocean_public_ipv4`: droplet의 public IPv4
- `__meta_digitalocean_public_ipv6`: droplet의 public IPv6
- `__meta_digitalocean_region`: droplet의 region
- `__meta_digitalocean_size`: droplet 사이즈
- `__meta_digitalocean_status`: droplet의 status
- `__meta_digitalocean_features`: droplet의 목록 (콤마로 구분)
- `__meta_digitalocean_tags`: droplet의 태그 목록 (콤마로 구분)
- `__meta_digitalocean_vpc`: droplet의 VPC id

```yaml
# API 서버에 인증할 때 사용하는 인증 정보.
# 참고로, `basic_auth`와 `authorization` 옵션은 함께 사용할 수 없다.
# password와 password_file도 함께 사용할 수 없다.

# HTTP 기본 인증 정보 (Optional). 현재 DigitalOcean에서 지원하지 않는다.
basic_auth:
  [ username: <string> ]
  [ password: <secret> ]
  [ password_file: <string> ]

# `Authorization` 헤더 설정 (Optional).
authorization:
  # 인증 타입을 설정한다.
  [ type: <string> | default: Bearer ]
  # credential을 설정한다.
  # `credentials_file`과는 함께 사용할 수 없다.
  [ credentials: <secret> ]
  # 설정한 파일에서 읽어온 credential을 설정한다.
  # `credentials`와는 함께 사용할 수 없다.
  [ credentials_file: <filename> ]

# OAuth 2.0 설정 (Optional).
# basic_auth나 authorization과는 동시에 사용할 수 없다.
oauth2:
  [ <oauth2> ]

# 프록시 URL (Optional).
[ proxy_url: <string> ]

# HTTP 요청에서 HTTP 3xx 리다이렉트 지시를 따를지 여부를 설정한다.
[ follow_redirects: <bool> | default = true ]

# TLS 설정.
tls_config:
  [ <tls_config> ]

# 메트릭을 스크랩할 포트.
[ port: <int> | default = 80 ]

# droplet들을 리프레시할 시간.
[ refresh_interval: <duration> | default = 60s ]
```

### `<docker_sd_config>`

도커 SD 설정을 사용하면 [도커 엔진](https://docs.docker.com/engine/) 호스트에서 스크랩 타겟을 가져올 수 있다.

이 설정에선 "컨테이너들"을 찾아내서, 컨테이너에서 노출한 각 네트워크 IP와 포트로 타겟을 생성한다.

사용하는 메타 레이블들:

- `__meta_docker_container_id`: 컨테이너 id
- `__meta_docker_container_name`: 컨테이너 이름
- `__meta_docker_container_network_mode`: 컨테이너의 네트워크 모드
- `__meta_docker_container_label_<labelname>`: 컨테이너의 각 레이블
- `__meta_docker_network_id`: 네트워크 ID
- `__meta_docker_network_name`: 네트워크 이름
- `__meta_docker_network_ingress`: ingress 네트워크인지
- `__meta_docker_network_internal`: internal 네트워크인지
- `__meta_docker_network_label_<labelname>`: 네트워크의 각 레이블
- `__meta_docker_network_scope`: 네트워크의 스코프
- `__meta_docker_network_ip`: 이 네트워크에 있는 컨테이너의 IP
- `__meta_docker_port_private`: 컨테이너 포트
- `__meta_docker_port_public`: 포트를 매핑했다면 경우 외부 포트
- `__meta_docker_port_public_ip`: 포트를 매핑했다면 public IP

도커 디스커버리 설정 옵션은 아래를 참고해라:

```yaml
# 도커 데몬의 주소.
host: <string>

# 프록시 URL (Optional).
[ proxy_url: <string> ]

# TLS 설정.
tls_config:
  [ <tls_config> ]

# 메트릭을 스크랩할 포트.
# `role`이 nodes거나, 발행한 포트가 없는 태스크와 서비스를 발견했을 때 사용.
[ port: <int> | default = 80 ]

# 컨테이너가 호스트 네트워킹 모드에 있는 경우 사용할 호스트.
[ host_networking_host: <string> | default = "localhost" ]

# 디스커버리 프로세스를 일부 리소스로만 제한하는 필터 (Optional).
# 사용 가능한 필터틀은 도커 문서에 나와있다:
# 서비스: https://docs.docker.com/engine/api/v1.40/#operation/ServiceList
# 태스크: https://docs.docker.com/engine/api/v1.40/#operation/TaskList
# 노드: https://docs.docker.com/engine/api/v1.40/#operation/NodeList
[ filters:
  [ - name: <string>
      values: <string>, [...] ]

# 컨테이너들을 리프레시할 시간.
[ refresh_interval: <duration> | default = 60s ]

# 도커 데몬에 인증할 때 사용하는 인증 정보.
# 참고로, `basic_auth`와 `authorization`은 함께 사용할 수 없다.
# password와 password_file도 함께 사용할 수 없다.

# HTTP 기본 인증 정보 (Optional).
basic_auth:
  [ username: <string> ]
  [ password: <secret> ]
  [ password_file: <string> ]

# `Authorization` 헤더 설정 (Optional).
authorization:
  # 인증 타입을 설정한다.
  [ type: <string> | default: Bearer ]
  # credential을 설정한다.
  # `credentials_file`과는 함께 사용할 수 없다.
  [ credentials: <secret> ]
  # 설정한 파일에서 읽어온 credential을 설정한다.
  # `credentials`와는 함께 사용할 수 없다.
  [ credentials_file: <filename> ]

# OAuth 2.0 설정 (Optional).
# basic_auth나 authorization과는 동시에 사용할 수 없다.
oauth2:
  [ <oauth2> ]

# HTTP 요청에서 HTTP 3xx 리다이렉트 지시를 따를지 여부를 설정한다.
[ follow_redirects: <bool> | default = true ]
```

컨테이너들을 필터링할 땐 [relabeling 단계](#relabel_config)를 이용하는 게 좀더 효과적이며, 권장하는 방법이기도 하다. 단, 수천 개의 컨테이너를 사용하고 있다면, 기본적인 컨테이너 필터링을 지원하는 (`filters` 이용) Docker API를 직접 사용하는 게 더 효율적일 수도 있다.

도커 엔진을 위한 구체적인 프로메테우스 설정 예시는 [이 프로메테우스 샘플 설정 파일](https://github.com/prometheus/prometheus/blob/release-2.32/documentation/examples/prometheus-docker.yml)을 참고해라.

### `<dockerswarm_sd_config>`

도커 스웜 SD 설정을 사용하면 [도커 스웜](https://docs.docker.com/engine/swarm/) 엔진에서 스크랩 타겟을 가져올 수 있다.

타겟 디스커버리에는 아래 있는 role 중 하나를 설정할 수 있다:

#### `services`

`services` role은 모든 [스웜 서비스](https://docs.docker.com/engine/swarm/key-concepts/#services-and-tasks)를 찾아내서 해당 포트를 타겟으로 노출한다. 서비스에서 발행한 각 포트마다 타겟을 하나씩 생성한다. 발행한 포트가 없는 서비스는, SD 설정에 정의한 `port` 파라미터를 사용해 서비스마다 타겟을 하나씩 생성한다.

사용하는 메타 레이블들:

- `__meta_dockerswarm_service_id`: 서비스 id
- `__meta_dockerswarm_service_name`: 서비스명
- `__meta_dockerswarm_service_mode`: 서비스 모드
- `__meta_dockerswarm_service_endpoint_port_name`: 엔드포인트 포트명 (있다면)
- `__meta_dockerswarm_service_endpoint_port_publish_mode`: 엔드포인트 포트의 publish 모드
- `__meta_dockerswarm_service_label_<labelname>`: 서비스의 각 레이블
- `__meta_dockerswarm_service_task_container_hostname`: 타겟의 컨테이너 호스트명 (있다면)
- `__meta_dockerswarm_service_task_container_image`: 타겟의 컨테이너 이미지
- `__meta_dockerswarm_service_updating_status`: 서비스의 status (가능하면)
- `__meta_dockerswarm_network_id`: 네트워크 ID
- `__meta_dockerswarm_network_name`: 네트워크 이름
- `__meta_dockerswarm_network_ingress`: ingress 네트워크인지
- `__meta_dockerswarm_network_internal`: internal 네트워크인지
- `__meta_dockerswarm_network_label_<labelname>`: 네트워크의 각 레이블
- `__meta_dockerswarm_network_scope`: 네트워크의 스코프

#### `tasks`

`tasks` role은 모든 [스웜 태스크](https://docs.docker.com/engine/swarm/key-concepts/#services-and-tasks)를 찾아내서 해당 포트를 타겟으로 노출한다. 태스크에서 발행한 각 포트마다 타겟을 하나씩 생성한다. 발행한 포트가 없는 태스크는, SD 설정에 정의한 `port` 파라미터를 사용해 태스크마다 타겟을 하나씩 생성한다.

사용하는 메타 레이블들:

- `__meta_dockerswarm_task_id`: 태스크 id
- `__meta_dockerswarm_task_container_id`: 태스크의 컨테이너 id
- `__meta_dockerswarm_task_desired_state`: 태스크의 desired state
- `__meta_dockerswarm_task_label_<labelname>`: 태스크의 각 레이블
- `__meta_dockerswarm_task_slot`: 태스크의 slot
- `__meta_dockerswarm_task_state`: 태스크의 state
- `__meta_dockerswarm_task_port_publish_mode`: 태스크 포트의 publish 모드
- `__meta_dockerswarm_service_id`: 서비스 id
- `__meta_dockerswarm_service_name`: 서비스 이름
- `__meta_dockerswarm_service_mode`: 서비스 모드
- `__meta_dockerswarm_service_label_<labelname>`: 서비스의 각 레이블
- `__meta_dockerswarm_network_id`: 네트워크 ID
- `__meta_dockerswarm_network_name`: 네트워크 이름
- `__meta_dockerswarm_network_ingress`: ingress 네트워크인지
- `__meta_dockerswarm_network_internal`: internal 네트워크인지
- `__meta_dockerswarm_network_label_<labelname>`: 네트워크의 각 레이블
- `__meta_dockerswarm_network_label`: 네트워크의 각 레이블
- `__meta_dockerswarm_network_scope`: 네트워크의 스코프
- `__meta_dockerswarm_node_id`: 노드 ID
- `__meta_dockerswarm_node_hostname`: 노드의 호스트명
- `__meta_dockerswarm_node_address`: 노드의 주소
- `__meta_dockerswarm_node_availability`: 노드의 가용성
- `__meta_dockerswarm_node_label_<labelname>`: 노드의 각 레이블
- `__meta_dockerswarm_node_platform_architecture`: 노드의 아키텍처
- `__meta_dockerswarm_node_platform_os`: 노드의 운영체제
- `__meta_dockerswarm_node_role`: 노드의 role
- `__meta_dockerswarm_node_status`: 노드의 status

`mode=host`로 발행한 포트로는 메타 레이블 `__meta_dockerswarm_network_*` 류를 채우지 않는다.

#### `nodes`

`nodes` role은 모든 [스웜 노드](https://docs.docker.com/engine/swarm/key-concepts/#nodes)를 찾을 때 사용한다.

사용하는 메타 레이블들:

- `__meta_dockerswarm_node_address`: 노드의 주소
- `__meta_dockerswarm_node_availability`: 노드의 가용성
- `__meta_dockerswarm_node_engine_version`: 노드 엔진 버전
- `__meta_dockerswarm_node_hostname`: 노드의 호스트명
- `__meta_dockerswarm_node_id`: 노드 ID
- `__meta_dockerswarm_node_label_<labelname>`: 노드의 각 레이블
- `__meta_dockerswarm_node_manager_address`: 노드의 매니저 컴포넌트 주소
- `__meta_dockerswarm_node_manager_leader`: 매니저 컴포넌트의 리더 여부 (true/false)
- `__meta_dockerswarm_node_manager_reachability`: 매니저 컴포넌트에 접근할 수 있는지
- `__meta_dockerswarm_node_platform_architecture`: 노드의 아키텍처
- `__meta_dockerswarm_node_platform_os`: 노드의 운영체제
- `__meta_dockerswarm_node_role`: 노드의 role
- `__meta_dockerswarm_node_status`: 노드의 status

도커 스웜 디스커버리 설정 옵션은 아래를 참고해라:

```yaml
# 도커 데몬의 주소.
host: <string>

# 프록시 URL (Optional).
[ proxy_url: <string> ]

# TLS 설정.
tls_config:
  [ <tls_config> ]

# 조회할 타겟의 role. `services`, `tasks`, `nodes` 중 하나여야 한다.
role: <string>

# 메트릭을 스크랩할 포트.
# `role`이 nodes거나, 발행한 포트가 없는 태스크와 서비스를 발견했을 때 사용.
[ port: <int> | default = 80 ]

# 디스커버리 프로세스를 일부 리소스로만 제한하는 필터 (Optional).
# 사용 가능한 필터틀은 도커 문서에 나와있다:
# https://docs.docker.com/engine/api/v1.40/#operation/ContainerList
[ filters:
  [ - name: <string>
      values: <string>, [...] ]

# 서비스 디스커버리 데이터를 리프레시할 시간.
[ refresh_interval: <duration> | default = 60s ]

# 도커 데몬에 인증할 때 사용하는 인증 정보.
# 참고로, `basic_auth`와 `authorization`은 함께 사용할 수 없다.
# password와 password_file도 함께 사용할 수 없다.

# HTTP 기본 인증 정보 (Optional).
basic_auth:
  [ username: <string> ]
  [ password: <secret> ]
  [ password_file: <string> ]

# `Authorization` 헤더 설정 (Optional).
authorization:
  # 인증 타입을 설정한다.
  [ type: <string> | default: Bearer ]
  # credential을 설정한다.
  # `credentials_file`과는 함께 사용할 수 없다.
  [ credentials: <secret> ]
  # 설정한 파일에서 읽어온 credential을 설정한다.
  # `credentials`와는 함께 사용할 수 없다.
  [ credentials_file: <filename> ]

# OAuth 2.0 설정 (Optional).
# basic_auth나 authorization과는 동시에 사용할 수 없다.
oauth2:
  [ <oauth2> ]

# HTTP 요청에서 HTTP 3xx 리다이렉트 지시를 따를지 여부를 설정한다.
[ follow_redirects: <bool> | default = true ]
```

태스크나 서비스, 노드를 필터링할 땐 [relabeling 단계](#relabel_config)를 이용하는 게 좀더 효과적이며, 권장하는 방법이기도 하다. 단, 수천 개의 태스크를 사용하고 있다면, 기본적인 노드 필터링을 지원하는 (`filters` 이용) Swarm API를 직접 사용하는 게 더 효율적일 수도 있다.

도커 스웜을 위한 구체적인 프로메테우스 설정 예시는 [이 프로메테우스 샘플 설정 파일](https://github.com/prometheus/prometheus/blob/release-2.32/documentation/examples/prometheus-dockerswarm.yml)을 참고해라.

### `<dns_sd_config>`

DNS 기반 서비스 디스커버리 설정을 사용하면, 주기적으로 지정한 DNS 도메인 이름 셋을 질의해서 타겟 목록을 가져올 수 있다. 접근할 DNS 서버는 `/etc/resolv.conf`에서 읽어온다.

이 설정에선 기본적인 DNS A, AAAA, SRV 레코드 질의만 지원하며, [RFC6763](https://tools.ietf.org/html/rfc6763)에 명시된 고급 DNS-SD 방식은 지원하지 않는다.

[relabeling](#relabel_config) 동안에는 잠시 타겟에 아래와 같은 메타 레이블들이 추가된다:

- `__meta_dns_name`: 발견한 타겟을 생성한 레코드 이름.
- `__meta_dns_srv_record_target`:SRV 레코드의 타겟 필드
- `__meta_dns_srv_record_port`: SRV 레코드의 포트 필드

```yaml
# 질의할 DNS 도메인 이름 목록
names:
  [ - <string> ]

# 수행할 DNS 질의 타입. SRV, A, AAAA 중 하나.
[ type: <string> | default = 'SRV' ]

# 질의 타입이 SRV가 아닐 때 사용하는 포트 번호.
[ port: <int>]

# 가져온 이름들을 리프레시할 시간.
[ refresh_interval: <duration> | default = 30s ]
```

### `<ec2_sd_config>`

EC2 SD 구성을 설정을 AWS EC2 인스턴스에서 스크랩 타겟을 가져올 수 있다. 기본적으로는 private IP 주소를 사용하지만, relabeling을 이용해서 public IP 주소로 변경할 수도 있다.

[relabeling](#relabel_config) 동안에는 잠시 타겟에 아래와 같은 메타 레이블들이 추가된다:

- `__meta_ec2_ami`: EC2 아마존 머신 이미지
- `__meta_ec2_architecture`: 인스턴스의 아키텍처
- `__meta_ec2_availability_zone`: 인스턴스가 실행되고 있는 availability zone
- `__meta_ec2_availability_zone_id`: 인스턴스가 실행되고 있는 [availability zone ID](https://docs.aws.amazon.com/ram/latest/userguide/working-with-az-ids.html) (`ec2:DescribeAvailabilityZones` 필요)
- `__meta_ec2_instance_id`: EC2 인스턴스 ID
- `__meta_ec2_instance_lifecycle`: EC2 인스턴스의 라이프사이클. 'spot', 'scheduled' 인스턴스에서만 설정하며, 그 외는 레이블을 생성하지 않는다.
- `__meta_ec2_instance_state`: EC2 인스턴스의 state
- `__meta_ec2_instance_type`: EC2 인스턴스의 타입
- `__meta_ec2_ipv6_addresses`: 인스턴스의 네트워크 인터페이스에 할당된 IPv6 주소 목록 (콤마로 구분) (있으면)
- `__meta_ec2_owner_id`: EC2 인스턴스를 소유하고 있는 AWS 계정 ID
- `__meta_ec2_platform`: 운영 체제 플랫폼. Windows 서버에서 'windows'로 설정하며, 그 외는 레이블을 생성하지 않는다.
- `__meta_ec2_primary_subnet_id`: 프라이머리 네트워크 인터페이스의 서브넷 ID (있으면)
- `__meta_ec2_private_dns_name`: 인스턴스의 private DNS 이름 (있으면)
- `__meta_ec2_private_ip`: 인스턴스의 private IP 주소 (있으면)
- `__meta_ec2_public_dns_name`: 인스턴스의 public DNS 이름 (있으면)
- `__meta_ec2_public_ip`: 인스턴스의 public IP 주소 (있으면)
- `__meta_ec2_subnet_id`: 인스턴스가 실행되고 있는 서브넷 ID 목록(콤마로 구분) (있으면)
- `__meta_ec2_tag_<tagkey>`: 인스턴스의 각 태그 값
- `__meta_ec2_vpc_id`: 인스턴스가 실행되고 있는 VPC의 ID (있으면)

EC2 디스커버리 설정 옵션은 아래를 참고해라:

```yaml
# EC2 API에 접근할 때 사용할 정보.

# AWS region. 비어있으면 인스턴스 메타데이터에 있는 region을 사용한다.
[ region: <string> ]

# 사용할 커스텀 엔드포인트.
[ endpoint: <string> ]

# AWS API 키. 비어있으면 환경 변수
# `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`를 사용한다.
[ access_key: <string> ]
[ secret_key: <secret> ]
# API에 연결할 때 사용할 AWS 프로파일 이름.
[ profile: <string> ]

# AWS API 키 대신 사용할 수 있는 AWS Role ARN.
[ role_arn: <string> ]

# 인스턴스 목록을 다시 읽어올 리프레시 간격.
[ refresh_interval: <duration> | default = 60s ]

# 메트릭을 스크랩할 포트.
# public IP를 사용한다면, 이 곳이 아닌 relabeling rule에서 지정해야 한다.
[ port: <int> | default = 80 ]

# 필터를 사용하면 인스턴스 목록을 다른 기준으로 필터링할 수 있다 (optional).
# 사용할 수 있는 필터 기준은 아래에서 찾을 수 있다:
# https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeInstances.html
# Filter API 문서: https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_Filter.html
filters:
  [ - name: <string>
      values: <string>, [...] ]
```

임의의 레이블 조합으로 타겟을 필터링할 땐 [relabeling 단계](#relabel_config)를 이용하는 게 좀더 효과적이며, 권장하는 방법이기도 하다. 단, 수천 개의 인스턴스를 사용하고 있다면, 인스턴스 필터링을 지원하는 EC2 API를 직접 사용하는 게 더 효율적일 수도 있다.

### `<openstack_sd_config>`

OpenStack SD 설정을 사용하면 OpenStack Nova 인스턴스에서 스크랩 타겟을 가져올 수 있다.

타겟 디스커버리에는 아래 있는 `<openstack_role>` 타입 중 하나를 설정할 수 있다:

#### `hypervisor`

`hypervisor` role은 Nova 하이퍼바이저 노드마다 타겟을 하나씩 검색한다. 타겟 주소는 기본적으로 하이퍼바이저의 `host_ip` 속성으로 설정된다.

[relabeling](#relabel_config) 동안에는 잠시 타겟에 아래와 같은 메타 레이블들이 추가된다:

- `__meta_openstack_hypervisor_host_ip`: 하이퍼바이저 노드의 IP 주소.
- `__meta_openstack_hypervisor_id`: 하이퍼바이저 노드 ID.
- `__meta_openstack_hypervisor_name`: 하이퍼바이저 노드 이름.
- `__meta_openstack_hypervisor_state`: 하이퍼바이저 노드의 state.
- `__meta_openstack_hypervisor_status`: 하이퍼바이저 노드의 status.
- `__meta_openstack_hypervisor_type`: 하이퍼바이저 노드 타입.

#### `instance`

`instance` role은 Nova 인스턴스의 네트워크 인터페이스마다 타겟을 하나씩 검색한다. 타겟 주소는 기본적으로 네트워크 인터페이스의 private IP 주소로 설정된다.

[relabeling](#relabel_config) 동안에는 잠시 타겟에 아래와 같은 메타 레이블들이 추가된다:

- `__meta_openstack_address_pool`: private IP pool.
- `__meta_openstack_instance_flavor`: OpenStack 인스턴스 사양<sup>flavor</sup>
- `__meta_openstack_instance_id`: OpenStack 인스턴스 ID.
- `__meta_openstack_instance_name`: OpenStack 인스턴스 이름.
- `__meta_openstack_instance_status`: OpenStack 인스턴스의 status.
- `__meta_openstack_private_ip`: OpenStack 인스턴스의 private IP.
- `__meta_openstack_project_id`: 이 인스턴스를 소유하고 있는 프로젝트(tenant).
- `__meta_openstack_public_ip`: OpenStack 인스턴스의 public IP.
- `__meta_openstack_tag_<tagkey>`: 인스턴스의 각 태그 값.
- `__meta_openstack_user_id`: 이 tenant를 소유하고 있는 사용자 계정.

OpenStack 디스커버리 설정 옵션은 아래를 참고해라:

```yaml
# OpenStack API에 접근하기 위한 정보.

# 검색할 엔티티들의 OpenStack role.
role: <openstack_role>

# OpenStack Region.
region: <string>

# identity_endpoint엔 사용할 Identity API 버전에 맞는 HTTP 엔드포인트를 지정한다.
# 궁극적으로 엔드포인트는 모든 identity 서비스에서 필요한 것은 맞지만,
# 공급업체에서 지원하는 기능으로 채워지는 경우도 많다.
[ identity_endpoint: <string> ]

# Identity V2 API를 사용하는 경우엔 username이 필요하다.
# 사용하는 계정의 username은 공급업체의 설정 화면에서 찾으면 된다.
# Identity V3에서는 userid나 username/domain_id 조합, 또는 username/domain_name 조합이 필요하다.
[ username: <string> ]
[ userid: <string> ]

# Identity V2/V3 API에서 사용할 password.
# 사용하는 계정에 적합한 인증 방법은 공급업체의 설정 화면에서 알아보면 된다.
[ password: <secret> ]

# Identity V3에서 username을 사용한다면 
# 반드시 domain_id와 domain_name 중 하나만 제공해야 한다. 
# 그 외는 둘 모두 선택 사항이다.
[ domain_name: <string> ]
[ domain_id: <string> ]

# project_id, project_name 필드는 Identity V2 API에선 선택 사항이다.
# 일부 공급업체에선 project_id 대신 project_name을 지정해도 된다.
# 공급업체에 따라 둘 다 필요할 수도 있다. 
# 이 필드들이 인증에 끼치는 영향은 공급업체의 인증 정책에 따라 달라진다.
[ project_name: <string> ]
[ project_id: <string> ]

# 애플리케이션 credential을 사용해 인증한다면
# application_credential_id나 application_credential_name 필드가 필요하다.
# 일부 공급업체에선 password가 아닌 애플리케이션 credential을 만들어 인증할 수 있다.
[ application_credential_name: <string> ]
[ application_credential_id: <string> ]

# 애플리케이션 credential을 사용해 인증한다면
# application_credential_secret 필드가 필요하다.
[ application_credential_secret: <secret> ]

# 서비스 디스커버리에서 모든 프로젝트의 인스턴스들을 전부 나열해야 하는지 여부.
# 'instance' role에만 해당되며 일반적으론 어드민 권한이 필요하다.
[ all_tenants: <boolean> | default: false ]

# 인스턴스 목록을 다시 읽어오기 위한 리프레시 간격.
[ refresh_interval: <duration> | default = 60s ]

# 메트릭을 스크랩할 포트.
# public IP를 사용한다면, 이 곳이 아닌 relabeling rule에서 지정해야 한다.
[ port: <int> | default = 80 ]

# 연결할 엔드포인트의 availability. public, admin, internal 중 하나여야 한다.
[ availability: <string> | default = "public" ]

# TLS 설정.
tls_config:
  [ <tls_config> ]
```

### `<puppetdb_sd_config>`

PuppetDB SD 설정을 사용하면 [PuppetDB](https://puppet.com/docs/puppetdb/latest/index.html) 리소스에서 스크랩 타겟을 가져올 수 있다.

이 설정에선 리소스를 검색하고 API에서 반환한 리소스마다 타겟을 생성한다.

리소스 주소는 리소스의 `certname`이며 [relabeling](#relabel_config) 중에 변경될 수 있다.

[relabeling](#relabel_config) 동안에는 잠시 타겟에 아래와 같은 메타 레이블들이 추가된다:

- `__meta_puppetdb_certname`: 리소스에 연결돼있는 노드 이름
- `__meta_puppetdb_resource`: 식별을 위한 리소스 타입, 제목, 파라미터의 SHA-1 해시값
- `__meta_puppetdb_type`: 리소스 타입
- `__meta_puppetdb_title`: 리소스 제목
- `__meta_puppetdb_exported`: 리소스가 익스포트되었는지 여부 (`"true"`/`"false"`)
- `__meta_puppetdb_tags`: 리소스 태그 리스트 (콤마로 구분)
- `__meta_puppetdb_file`: 리소스를 선언한 매니페스트 파일
- `__meta_puppetdb_environment`: 리소스와 연결돼있는 노드의 환경
- `__meta_puppetdb_parameter_<parametername>`: 리소스 파라미터들

PuppetDB 디스커버리 설정 옵션은 아래를 참고해라:

```yaml
# PuppetDB 루트 쿼리 엔드포인트 URL.
url: <string>

# Puppet Query Language (PQL) 쿼리. 리소스만 지원한다.
# https://puppet.com/docs/puppetdb/latest/api/query/v4/pql.html
query: <string>

# 메타 레이블에 파라미터들을 추가할지 여부.
# 파라미터 타입과 프로메테우스 레이블의 차이때문에 일부 파라미터가 렌더링되지 않을 수도 있다.
# 파라미터 형식은 향후 릴리즈에서도 변경될 수 있다.
#
# 주의: 이 기능을 활성화하면 프로메테우스 UI와 API에서 파라미터들이 노출된다.
# 이 기능을 활성화한다면 시크릿을 파라미터로 노출하고 있진 않은지 반드시 확인해봐라.
[ include_parameters: <boolean> | default = false ]

# 리소스 목록을 다시 읽어오기 위한 리프레시 간격.
[ refresh_interval: <duration> | default = 60s ]

# 메트릭을 스크랩할 포트.
[ port: <int> | default = 80 ]

# PuppetDB에 연결할 때 사용할 TLS 설정.
tls_config:
  [ <tls_config> ]

# basic_auth, authorization, oauth2는 함께 사용할 수 없다.

# HTTP 기본 인증 정보 (Optional).
basic_auth:
  [ username: <string> ]
  [ password: <secret> ]
  [ password_file: <string> ]

# `Authorization` HTTP 헤더 설정.
authorization:
  # 인증 타입을 설정한다.
  [ type: <string> | default: Bearer ]
  # credential을 설정한다.
  # `credentials_file`과는 함께 사용할 수 없다.
  [ credentials: <secret> ]
  # 설정한 파일에서 읽어온 credential을 설정한다.
  # `credentials`와는 함께 사용할 수 없다.
  [ credentials_file: <filename> ]

# OAuth 2.0 설정 (Optional).
# basic_auth나 authorization과는 동시에 사용할 수 없다.
oauth2:
  [ <oauth2> ]

# 프록시 URL (Optional).
[ proxy_url: <string> ]

# HTTP 요청에서 HTTP 3xx 리다이렉트 지시를 따를지 여부를 설정한다.
[ follow_redirects: <bool> | default = true ]
```

PuppetDB를 위한 구체적인 프로메테우스 설정 예시는 [이 프로메테우스 샘플 설정 파일](https://github.com/prometheus/prometheus/blob/release-2.32/documentation/examples/prometheus-puppetdb.yml)을 참고해라.

### `<file_sd_config>`

파일 기반 서비스 디스커버리는 타겟을 정적으로 구성할 수 있는 좀더 범용적인 방법을 제공하며, 동시에 커스텀 서비스 디스커버리 메커니즘을 연결하기 위한 인터페이스 역할을 담당한다.

여기서는 0개 이상의 `<static_config>` 목록을 가지고 있는 파일 셋을 읽어들인다. 정의한 모든 파일들의 변경 사항은 디스크 감시를 통해 감지할 수 있으며, 즉시 적용된다. 파일은 YAML이나 JSON 형식으로 제공할 수 있다. 변경 사항은 생성하는 타겟 그룹의 형식이 올바를 때만 반영된다.

파일 안에는 다음과 같은 포맷을 사용하는 스태틱 설정 목록이 들어있어야 한다:

**JSON** `json [ { "targets": [ "<host>", ... ], "labels": { "<labelname>": "<labelvalue>", ... } }, ... ]`

**YAML** `yaml - targets: [ - '<host>' ] labels: [ <labelname>: <labelvalue> ... ]`

폴백으로 사용할 파일 내용도 지정한 리프레시 간격대로 주기적으로 다시 읽어온다.

[relabeling](#relabel_config) 동안에는 잠시 타겟마다 `__meta_filepath`란 메타 레이블이 추가된다. 레이블 값에는 타겟을 추출한 파일 경로를 저장한다.

이 서비스 메커니즘에서 지원하는 [통합](../integrations#file-service-discovery) 목록을 참고해라.

```yaml
# 타겟 그룹들을 추출할 파일 패턴.
files:
  [ - <filename_pattern> ... ]

# 파일들을 다시 읽어올 리프레시 간격.
[ refresh_interval: <duration> | default = 5m ]
```

이때 `<filename_pattern>`에는 `.json`, `.yml`, `.yaml`로 끝나는 경로를 사용할 수 있다. 마지막 경로 세그먼트는 모든 문자 시퀀스와 매칭되는 `*`를 하나 가지고 있어도 된다 (ex. `my/path/tg_*.json`).

### `<gce_sd_config>`

[GCE](https://cloud.google.com/compute/) SD 설정을 사용하면 GCP GCE 인스턴스에서 스크랩 타겟을 가져올 수 있다. 기본적으로는 private IP 주소를 사용하지만, relabeling을 이용해서 public IP 주소로 변경할 수도 있다.

[relabeling](#relabel_config) 동안에는 잠시 타겟에 아래와 같은 메타 레이블들이 추가된다:

- `__meta_gce_instance_id`: 인스턴스의 숫자 id
- `__meta_gce_instance_name`: 인스턴스 이름
- `__meta_gce_label_<labelname>`:인스턴스의 각 GCE 레이블
- `__meta_gce_machine_type`: 인스턴스 머신 타입의 전체 URL 혹은 부분 URL
- `__meta_gce_metadata_<name>`: 인스턴스의 각 메타데이터 항목
- `__meta_gce_network`: 인스턴스의 네트워크 URL
- `__meta_gce_private_ip`: 인스턴스의 private IP 주소
- `__meta_gce_interface_ipv4_<name>`: 인터페이스 이름별 IPv4 주소
- `__meta_gce_project`: 인스턴스가 실행되고 있는 GCP 프로젝트
- `__meta_gce_public_ip`: 인스턴스의 public IP 주소 (있으면)
- `__meta_gce_subnetwork`: 인스턴스의 서브네트워크 URL
- `__meta_gce_tags`: 인스턴스 태그 리스트 (콤마로 구분)
- `__meta_gce_zone`: 인스턴스가 실행되고 있는 GCE zone URL

GCE 디스커버리 설정 옵션은 아래를 참고해라:

```yaml
# GCE API에 접근할 때 사용할 정보.

# GCP 프로젝트
project: <string>

# 스크랩 타겟 zone.
# zone이 여러 개 필요하다면 gce_sd_config를 여러 번 선언하면 된다.
zone: <string>

# 필터를 사용하면 인스턴스 목록을 다른 기준으로 필터링할 수 있다 (optional).
# 필터 문자열에 사용하는 문법은 아래 링크에서 필터 쿼리 파라미터 섹션을 확인해보면 된다:
# https://cloud.google.com/compute/docs/reference/latest/instances/list
[ filter: <string> ]

# 인스턴스 목록을 다시 읽어올 리프레시 간격.
[ refresh_interval: <duration> | default = 60s ]

# 메트릭을 스크랩할 포트.
# public IP를 사용한다면, 이 곳이 아닌 relabeling rule에서 지정해야 한다.
[ port: <int> | default = 80 ]

# 태그를 연결할 때 사용할 태그 구분 기호.
[ tag_separator: <string> | default = , ]
```

Credential은 Google Cloud SDK 디폴트 클라이언트를 이용해 아래와 같은 위치에서 찾아오며, 첫 번째로 발견한 위치를 채택한다:

1. 환경 변수 `GOOGLE_APPLICATION_CREDENTIALS`로 지정한 JSON 파일
2. 지정된 경로에 있는 JSON 파일 `$HOME/.config/gcloud/application_default_credentials.json`
3. GCE 메타데이터 서버에서 조회

프로메테우스를 GCE 내에서 실행하고 있다면, 실행 중인 인스턴스와 연계되는 서비스 계정은 최소한 컴퓨팅 리소스에 대한 read-only 권한은 가지고 있어야 한다. GCE 외부에서 실행할 때는, 적당한 서비스 계정을 하나 만들고 지정 위치 중 하나에 credential 파일을 저장해야 한다.

### `<hetzner_sd_config>`

Hetzner SD 설정을 사용하면 [Hetzner](https://www.hetzner.com/) [Cloud](https://www.hetzner.cloud/) API와 [Robot](https://docs.hetzner.com/robot/) API로 스크랩 타겟을 가져올 수 있다. 이때 서비스 디스커버리는 기본적으로 public IPv4 주소를 사용하며, [이 프로메테우스 hetzner-sd 설정 파일](https://github.com/prometheus/prometheus/blob/release-2.32/documentation/examples/prometheus-hetzner.yml)에서 보여주는 것처럼 relabelling을 통해 변경할 수 있다.

[relabeling](#relabel_config) 동안에는 잠시 모든 타겟에 아래와 같은 메타 레이블들이 추가된다:

- `__meta_hetzner_server_id`: 서버 ID
- `__meta_hetzner_server_name`: 서버 이름
- `__meta_hetzner_server_status`: 서버의 status
- `__meta_hetzner_public_ipv4`: 서버의 public ipv4 주소
- `__meta_hetzner_public_ipv6_network`: 서버의public ipv6 네트워크 (/64)
- `__meta_hetzner_datacenter`: 서버의 데이터센터

아래 있는 레이블들은 `role`을 `hcloud`로 설정한 타겟에서만 볼 수 있다:

- `__meta_hetzner_hcloud_image_name`: 서버의 이미지 이름
- `__meta_hetzner_hcloud_image_description`: 서버 이미지의 description
- `__meta_hetzner_hcloud_image_os_flavor`: 서버 이미지의 OS 사양<sup>flavor</sup>
- `__meta_hetzner_hcloud_image_os_version`: 서버 이미지의 OS 버전
- `__meta_hetzner_hcloud_datacenter_location`: 서버 위치
- `__meta_hetzner_hcloud_datacenter_location_network_zone`: 서버의 네트워크 존
- `__meta_hetzner_hcloud_server_type`: 서버 타입
- `__meta_hetzner_hcloud_cpu_cores`: 서버의 CPU 코어 갯수
- `__meta_hetzner_hcloud_cpu_type`: 서버의 CPU 타입 (shared/dedicated)
- `__meta_hetzner_hcloud_memory_size_gb`: 서버의 메모리 양 (GB 단위)
- `__meta_hetzner_hcloud_disk_size_gb`: 서버의 디스크 사이즈 (GB 단위)
- `__meta_hetzner_hcloud_private_ipv4_<networkname>`: 주어진 네트워크 내에서 사용하는 서버의 private ipv4 주소
- `__meta_hetzner_hcloud_label_<labelname>`: 서버의 각 레이블
- `__meta_hetzner_hcloud_labelpresent_<labelname>`: 서버의 각 레이블마다 `true`

아래 있는 레이블들은 `role`을 `robot`으로 설정한 타겟에서만 볼 수 있다:

- `__meta_hetzner_robot_product`: 서버의 product
- `__meta_hetzner_robot_cancelled`: 서버 cancellation status

```yaml
# 검색할 엔티티들의 Hetzner role.
# robot, hcloud 중 하나.
role: <string>

# API 서버에 인증할 때 사용하는 인증 정보.
# 참고로, `basic_auth`와 `authorization` 옵션은 함께 사용할 수 없다.
# password와 password_file도 함께 사용할 수 없다.

# HTTP 기본 인증 정보 (Optional).
# role이 robot일 때 필요하며, hcloud role은 기본 인증을 지원하지 않는다.
basic_auth:
  [ username: <string> ]
  [ password: <secret> ]
  [ password_file: <string> ]

# `Authorization` 헤더 설정 (Optional).
# role이 hcloud일 때 필요하며, robot role은 bearer 토큰 인증을 지원하지 않는다.
authorization:
  # 인증 타입을 설정한다.
  [ type: <string> | default: Bearer ]
  # credential을 설정한다.
  # `credentials_file`과는 함께 사용할 수 없다.
  [ credentials: <secret> ]
  # 설정한 파일에서 읽어온 credential을 설정한다.
  # `credentials`와는 함께 사용할 수 없다.
  [ credentials_file: <filename> ]

# OAuth 2.0 설정 (Optional).
# basic_auth나 authorization과는 동시에 사용할 수 없다.
oauth2:
  [ <oauth2> ]

# 프록시 URL (Optional).
[ proxy_url: <string> ]

# HTTP 요청에서 HTTP 3xx 리다이렉트 지시를 따를지 여부를 설정한다.
[ follow_redirects: <bool> | default = true ]

# TLS 설정.
tls_config:
  [ <tls_config> ]

# 메트릭을 스크랩할 포트.
[ port: <int> | default = 80 ]

# 서버들을 리프레시할 시간.
[ refresh_interval: <duration> | default = 60s ]
```

### `<http_sd_config>`

HTTP 기반 서비스 디스커버리는 타겟을 정적으로 구성할 수 있는 좀더 범용적인 방법을 제공하며, 동시에 커스텀 서비스 디스커버리 메커니즘을 연결하기 위한 인터페이스 역할을 담당한다.

여기서는 0개 이상의 `<static_config>` 목록을 반환하는 HTTP 엔드포인트에서 타겟을 가져온다. 타겟은 반드시 HTTP 200 응답을 반환해야 한다. HTTP 헤더 `Content-Type`은 `application/json`이어야 하며, 바디에는 유효한 JSON이 담겨 있어야 한다.

응답 바디 예시:

```json
[
  {
    "targets": [ "<host>", ... ],
    "labels": {
      "<labelname>": "<labelvalue>", ...
    }
  },
  ...
]
```

지정한 리프레시 간격대로 주기적으로 엔드포인트에 질의를 보낸다.

[relabeling](#relabel_config) 동안에는 잠시 타겟마다 `__meta_url`이란 메타 레이블이 추가된다. 레이블 값에는 타겟을 추출한 URL을 저장한다.

```yaml
# 타겟들을 가져올 URL
url: <string>

# 엔드포인트에 다시 질의를 보내기 위한 리프레시 간격.
[ refresh_interval: <duration> | default = 60s ]

# API 서버에 인증할 때 사용하는 인증 정보.
# 참고로, `basic_auth`와 `authorization`, `oauth2` 옵션은 함께 사용할 수 없다.
# password와 password_file도 함께 사용할 수 없다.

# HTTP 기본 인증 정보 (Optional).
basic_auth:
  [ username: <string> ]
  [ password: <secret> ]
  [ password_file: <string> ]

# `Authorization` 헤더 설정 (Optional).
authorization:
  # 인증 타입을 설정한다.
  [ type: <string> | default: Bearer ]
  # credential을 설정한다.
  # `credentials_file`과는 함께 사용할 수 없다.
  [ credentials: <secret> ]
  # 설정한 파일에서 읽어온 credential을 설정한다.
  # `credentials`와는 함께 사용할 수 없다.
  [ credentials_file: <filename> ]

# OAuth 2.0 설정 (Optional).
oauth2:
  [ <oauth2> ]

# 프록시 URL (Optional).
[ proxy_url: <string> ]

# HTTP 요청에서 HTTP 3xx 리다이렉트 지시를 따를지 여부를 설정한다.
[ follow_redirects: <bool> | default = true ]

# TLS 설정.
tls_config:
  [ <tls_config> ]
```

### `<kubernetes_sd_config>`

쿠버네티스 SD 설정을 사용하면 [쿠버네티스의](https://kubernetes.io/) REST API로 스크랩 타겟을 가져올 수 있으며, 항상 클러스터 상태와 동기화된 상태를 유지할 수 있다.

타겟 디스커버리에는 아래 있는 `role` 중 하나를 설정할 수 있다:

#### `node`

`node` role은 기본적으로 Kubelet의 HTTP 포트를 사용해서 클러스터 노드마다 타겟을 하나씩 검색한다. 타겟 주소의 기본값에는 쿠버네티스 노드 오브젝트의 기존 주소를 사용하는데, 각각 `NodeInternalIP`, `NodeExternalIP`, `NodeLegacyHostIP`, `NodeHostName`에서 첫 번째로 발견한 주소를 사용한다.

사용하는 메타 레이블들:

- `__meta_kubernetes_node_name`: 노트 오브젝트 이름.
- `__meta_kubernetes_node_label_<labelname>`: 노드 오브젝트의 각 레이블.
- `__meta_kubernetes_node_labelpresent_<labelname>`: 노드오브젝트의 각 레이블마다 `true`.
- `__meta_kubernetes_node_annotation_<annotationname>`: 노드 오브젝트의 각 애노테이션.
- `__meta_kubernetes_node_annotationpresent_<annotationname>`: 노드 오브젝트의 각 애노테이션마다 `true`.
- `__meta_kubernetes_node_address_<address_type>`: 각 노드 주소 타입의 첫 번째 주소 (존재하면).

그 외 API 서버에서 가져온 노드 이름을 노드의 `instance` 레이블에 저장한다.

#### `service`

`service` role은 각 서비스의 서비스 포트마다 타겟을 검색한다. 보통 서비스에 블랙박스 모니터링을 적용할 때 유용하다. 주소는 서비스의 쿠버네티스 DNS 이름과 각 서비스 포트로 설정된다.

사용하는 메타 레이블들:

- `__meta_kubernetes_namespace`: 서비스 오브젝트의 네임스페이스.
- `__meta_kubernetes_service_annotation_<annotationname>`: 서비스 오브젝트의 각 애노테이션.
- `__meta_kubernetes_service_annotationpresent_<annotationname>`: 서비스 오브젝트의 각 애노테이션마다 "true".
- `__meta_kubernetes_service_cluster_ip`: 서비스의 클러스터 IP 주소. (ExternalName 타입 서비스엔 적용되지 않는다)
- `__meta_kubernetes_service_external_name`: 서비스의 DNS 이름. (ExternalName 타입 서비스에 적용된다)
- `__meta_kubernetes_service_label_<labelname>`: 서비스 오브젝트의 각 레이블.
- `__meta_kubernetes_service_labelpresent_<labelname>`: 서비스 오브젝트의 각 레이블마다 `true`.
- `__meta_kubernetes_service_name`: 서비스 오브젝트 이름
- `__meta_kubernetes_service_port_name`: 해당 타겟의 서비스 포트 이름.
- `__meta_kubernetes_service_port_protocol`: 해당 타겟의 서비스 포트 프로토콜.
- `__meta_kubernetes_service_type`: 서비스 타입

#### `pod`

`pod` role은 모든 포드를 검색해서 거기 있는 컨테이너들을 타겟으로 노출한다. 컨테이너에 선언한 포트마다 타겟이 하나씩 생성된다. 컨테이너에 지정한 포트가 없을 땐, relabeling을 통해 수동으로 포트를 추가할 수 있도록 컨테이너마다 포트가 없는 타겟을 하나씩 생성한다.

사용하는 메타 레이블들:

- `__meta_kubernetes_namespace`: 포드 오브젝트의 네임스페이스.
- `__meta_kubernetes_pod_name`: 포드 오브젝트 이름.
- `__meta_kubernetes_pod_ip`: 포드 오브젝트의 포드 IP.
- `__meta_kubernetes_pod_label_<labelname>`: 포드 오브젝트의 각 레이블.
- `__meta_kubernetes_pod_labelpresent_<labelname>`: 포드 오브젝트의 각 레이블마다 `true`.
- `__meta_kubernetes_pod_annotation_<annotationname>`: 포드 오브젝트의 각 애노테이션.
- `__meta_kubernetes_pod_annotationpresent_<annotationname>`: 포드 오브젝트의 각 애노테이션마다 `true`.
- `__meta_kubernetes_pod_container_init`: 컨테이너가 [InitContainer](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/)일 때 `true`
- `__meta_kubernetes_pod_container_name`: 타겟 주소가 가리키는 컨테이너 이름.
- `__meta_kubernetes_pod_container_port_name`: 컨테이너 포트 이름.
- `__meta_kubernetes_pod_container_port_number`: 컨테이너 포트 숫자.
- `__meta_kubernetes_pod_container_port_protocol`: 컨테이너 포트의 프로토콜.
- `__meta_kubernetes_pod_ready`: 포드가 준비됐는지에 따라 `true`나 `false`로 설정.
- `__meta_kubernetes_pod_phase`: [라이프사이클](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#pod-phase) 단계 `Pending`, `Running`, `Succeeded`, `Failed`, `Unknown` 중 하나를 설정.
- `__meta_kubernetes_pod_node_name`: 포드가 예약된 노드 이름.
- `__meta_kubernetes_pod_host_ip`: 포드 오브젝트의 현재 호스트 IP.
- `__meta_kubernetes_pod_uid`: 포드 오브젝트의 UID.
- `__meta_kubernetes_pod_controller_kind`: 포드 컨트롤러의 오브젝트 종류.
- `__meta_kubernetes_pod_controller_name`: 포드 컨트롤러 이름.

#### `endpoints`

`endpoints` role은 서비스에 나열된 엔드포인트들에서 타겟을 검색한다. 엔드포인트 주소마다 각 포트 단위로 타겟을 하나씩 검색한다. 엔드포인트가 포드에 연결됐을 때는, 해당 포드에 있지만 엔드포인트 포트에 바인딩되지 않은 다른 컨테이너 포트들도 모두 함께 타겟으로 가져온다.

사용하는 메타 레이블들:

- `__meta_kubernetes_namespace`: 엔드포인트 오브젝트의 네임스페이스.
- `__meta_kubernetes_endpoints_name`: 엔드포인트 오브젝트 이름들.

엔드포인트 목록에서 직접 가져오는 타겟에는 (연결된 포드에서 유추해서 추가로 가져온 타겟들 말고) 모두 아래와 같은 레이블이 첨부된다:

- `__meta_kubernetes_endpoint_hostname`: 엔드포인트의 호스트명.
- `__meta_kubernetes_endpoint_node_name`: 엔드포인트를 호스팅하는 노드의 이름.
- `__meta_kubernetes_endpoint_ready`: 엔드포인트가 준비됐는지에 따라 `true`나 `false`로 설정.
- `__meta_kubernetes_endpoint_port_name`: 엔드포인트 포트 이름.
- `__meta_kubernetes_endpoint_port_protocol`: 엔드포인트 포트의 프로토콜.
- `__meta_kubernetes_endpoint_address_target_kind`: 엔드포인트 주소 타겟의 종류.
- `__meta_kubernetes_endpoint_address_target_name`: 엔드포인트 주소 타겟의 이름.

엔드포인트가 서비스에 속하는 경우엔 `role: service` 디스커버리의 레이블들도 모두 첨부된다.

포드에 연결된 타겟들은 전부 `role: pod` 디스커버리의 레이블들도 첨부된다.

#### `endpointslice`

`endpointslice` role은 기존 엔드포인트슬라이스에서 타겟을 가져온다. 엔드포인트슬라이스 오브젝트에서 참조하는 엔드포인트 주소마다 타겟을 하나씩 검색한다. 엔드포인트가 포드에 연결됐을 때는, 해당 포드에 있지만 엔드포인트 포트에 바인딩되지 않은 다른 컨테이너 포트들도 모두 함께 타겟으로 가져온다.

사용하는 메타 레이블들: 

- `__meta_kubernetes_namespace`: 엔드포인트 오브젝트의 네임스페이스.
- `__meta_kubernetes_endpointslice_name`: 엔드포인트슬라이스 오브젝트 이름.

엔드포인트슬라이스 목록에서 직접 가져오는 타겟에는 (연결된 포드에서 유추해서 추가로 가져온 타겟들 말고) 모두 아래와 같은 레이블이 첨부된다:

- `__meta_kubernetes_endpointslice_address_target_kind`: 참조하는 오브젝트의 종류.
- `__meta_kubernetes_endpointslice_address_target_name`: 참조하는 오브젝트의 이름.
- `__meta_kubernetes_endpointslice_address_type`: 주소 타겟의 ip 프로토콜 체계<sup>protocol family</sup>.
- `__meta_kubernetes_endpointslice_endpoint_conditions_ready`: 엔드포인트가 준비됐는지에 따라 `true`나 `false`로 설정.
- `__meta_kubernetes_endpointslice_endpoint_topology_kubernetes_io_hostname`: 참조하는 엔드포인트를 호스팅하는 노드의 이름.
- `__meta_kubernetes_endpointslice_endpoint_topology_present_kubernetes_io_hostname`: 참조한 오브젝트에 kubernetes.io/hostname 애노테이션이 있는지를 나타내는 플래그. 
- `__meta_kubernetes_endpointslice_port`: 참조하는 엔드포인트의 포트.
- `__meta_kubernetes_endpointslice_port_name`: 참조하는 엔드포인트의 포트 이름.
- `__meta_kubernetes_endpointslice_port_protocol`: 참조하는 엔드포인트의 프로토콜. 

엔드포인트가 서비스에 속하는 경우엔 `role: service` 디스커버리의 레이블들도 모두 첨부된다.

포드에 연결된 타겟들은 전부 `role: pod` 디스커버리의 레이블들도 첨부된다.

#### `ingress`

`ingress` role은 각 인그레스의 경로마다 타겟을 검색한다. 보통 인그레스에 블랙박스 모니터링을 적용할 때 유용하다. 주소는 인그레스 스펙에 명시한 호스트로 설정된다.

사용하는 메타 레이블들:

- `__meta_kubernetes_namespace`: 인그레스 오브젝트의 네임스페이스.
- `__meta_kubernetes_ingress_name`: 인그레스 오브젝트 이름.
- `__meta_kubernetes_ingress_label_<labelname>`: 인그레스 오브젝트의 각 레이블.gress object.
- `__meta_kubernetes_ingress_labelpresent_<labelname>`: 인그레스 오브젝트의 각 레이블마다 `true`.
- `__meta_kubernetes_ingress_annotation_<annotationname>`: 인그레스 오브젝트의 각 애노테이션.
- `__meta_kubernetes_ingress_annotationpresent_<annotationname>`: 인그레스 오브젝트의 각 애노테이션마다 `true`.
- `__meta_kubernetes_ingress_class_name`: 인그레스 스펙에 있는 클래스명 (있다면).
- `__meta_kubernetes_ingress_scheme`: 인그레스의 프로토콜 스킴. TLS 설정을 구성했다면 `https`. 디폴트는 `http`다.
- `__meta_kubernetes_ingress_path`: 인그레스 스펙에 있는 경로. 디폴트는 `/`다.

쿠버네티스 디스커버리 설정 옵션은 아래를 참고해라:

```yaml
# 쿠버네티스 API에 접근할 때 사용할 정보.

# 비워두면 프로메테우스는 같은 클러스터 안에서 실행하는 것으로 가정하고
# API 서버를 자동으로 검색하며, /var/run/secrets/kubernetes.io/serviceaccount/에 있는
# 포드의 CA 인증서와 bearer 토큰 파일을 사용한다.
[ api_server: <host> ]

# 검색할 엔티티들의 쿠버네티스 role.
# endpoints, service, pod, node, ingress 중 하나.
role: <string>

# kubeconfig 파일 경로 (Optional).
# 참고로, api_server와 kube_config는 함께 사용할 수 없다.
[ kubeconfig_file: <filename> ]

# API 서버에 인증할 때 사용하는 인증 정보 (Optional).
# 참고로, `basic_auth`와 `authorization` 옵션은 함께 사용할 수 없다.
# password와 password_file도 함께 사용할 수 없다.

# HTTP 기본 인증 정보 (Optional).
basic_auth:
  [ username: <string> ]
  [ password: <secret> ]
  [ password_file: <string> ]

# `Authorization` 헤더 설정 (Optional).
authorization:
  # 인증 타입을 설정한다.
  [ type: <string> | default: Bearer ]
  # credential을 설정한다.
  # `credentials_file`과는 함께 사용할 수 없다.
  [ credentials: <secret> ]
  # 설정한 파일에서 읽어온 credential을 설정한다.
  # `credentials`와는 함께 사용할 수 없다.
  [ credentials_file: <filename> ]

# OAuth 2.0 설정 (Optional).
# basic_auth나 authorization과는 동시에 사용할 수 없다.
oauth2:
  [ <oauth2> ]

# 프록시 URL (Optional).
[ proxy_url: <string> ]

# HTTP 요청에서 HTTP 3xx 리다이렉트 지시를 따를지 여부를 설정한다.
[ follow_redirects: <bool> | default = true ]

# TLS 설정.
tls_config:
  [ <tls_config> ]

# 네임스페이스 디스커버리 (Optional). 생략하면 모든 네임스페이스를 사용한다.
namespaces:
  names:
    [ - <string> ]

# 디스커버리 프로세스를 일부 리소스로만 제한하는 레이블과 필드 셀렉터 (Optional).
# 사용 가능한 필터틀은 아래 문서를 참고해라:
# https://kubernetes.io/docs/concepts/overview/working-with-objects/field-selectors/
# https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/
# Endpoints role은 포드, 서비스, 엔드포인트 셀럭터를 지원하며,
# 다른 role들은 role 자체와 일치하는 셀렉터만 지원한다 (ex. node role은 노드 셀렉터만 설정할 수 있다).

# 주의: 필드/레이블 셀렉터를 사용하기로 했다면 과연 최선의 선택인지 다시 한 번 생각해봐라.
# 이 설정을 추가하면 프로메테우스가 모든 스크랩 설정에 LIST/WATCH를 재사용할 수 없다.
# 각 셀렉터 조합마다 별도로 LIST/WATCH를 사용하기 때문에, 쿠버네티스 API에 더 큰 부하를 줄 수 있다.
# 반면 대규모 클러스터에 있는 일부 소량의 포드만 모니터링하고 싶을 때는 셀렉터를 사용하는 게 좋다.
# 셀렉터를 사용해야 할지 말지는 주어진 상황에 따라 다르다.
[ selectors:
  [ - role: <string>
    [ label: <string> ]
    [ field: <string> ] ]]
```

쿠버네티스를 위한 구체적인 프로메테우스 설정 예시는 [이 프로메테우스 샘플 설정 파일](https://github.com/prometheus/prometheus/blob/release-2.32/documentation/examples/prometheus-kubernetes.yml)을 참고해라.

쿠버네티스 환경에서 프로메테우스 세팅을 자동화해주는 써드 파티 [Prometheus Operator](https://github.com/coreos/prometheus-operator)를 검토해보는 것도 좋다.

### `<kuma_sd_config>`

Kuma SD 설정을 사용하면 [Kuma](https://kuma.io/) Control Plane에서 스크랩 타겟을 가져올 수 있다.

이 설정에선 MADS v1<sup>Monitoring Assignment Discovery Service</sup> xDS API를 통해 Kuma [Dataplane Proxies](https://kuma.io/docs/latest/documentation/dps-and-data-model)를 기반으로 "monitoring assignments"을 검색하고, 각 프록시마다 프로메테우스에서 활성화한 mesh 내부에 타겟을 생성한다.

타겟마다 아래와 같은 메타 레이블들이 추가된다:

- `__meta_kuma_mesh`: 프록시의 Mesh 이름
- `__meta_kuma_dataplane`: 프록시 이름
- `__meta_kuma_service`: 프록시에 연결된 서비스 이름
- `__meta_kuma_label_<tagname>`: 프록시의 각 태그

Kuma MonitoringAssignment 디스커버리 설정 옵션은 아래를 참고해라:

```yaml
# Kuma Control Plane의 MADS xDS 서버 주소.
server: <string>

# 업데이트 요청을 폴링할 때마다 대기할 시간.
[ refresh_interval: <duration> | default = 30s ]

# monitoring assignments를 리프레시할 시간.
[ fetch_timeout: <duration> | default = 2m ]

# 프록시 URL (Optional).
[ proxy_url: <string> ]

# TLS 설정.
tls_config:
  [ <tls_config> ]

# 도커 데몬에 인증할 때 사용하는 인증 정보.
# 참고로, `basic_auth`와 `authorization`은 함께 사용할 수 없다.
# password와 password_file도 함께 사용할 수 없다.

# HTTP 기본 인증 정보 (Optional).
basic_auth:
  [ username: <string> ]
  [ password: <secret> ]
  [ password_file: <string> ]

# `Authorization` 헤더 설정 (Optional).
authorization:
  # 인증 타입을 설정한다.
  [ type: <string> | default: Bearer ]
  # credential을 설정한다.
  # `credentials_file`과는 함께 사용할 수 없다.
  [ credentials: <secret> ]
  # 설정한 파일에서 읽어온 credential을 설정한다.
  # `credentials`와는 함께 사용할 수 없다.
  [ credentials_file: <filename> ]

# OAuth 2.0 설정 (Optional).
# basic_auth나 authorization과는 동시에 사용할 수 없다.
oauth2:
  [ <oauth2> ]

# HTTP 요청에서 HTTP 3xx 리다이렉트 지시를 따를지 여부를 설정한다.
[ follow_redirects: <bool> | default = true ]
```

프록시와 사용자 정의 태그를 필터링할 땐 [relabeling 단계](#relabel_config)를 이용하는 게 좀더 효과적이며, 권장하는 방법이기도 하다.

### `<lightsail_sd_config>`

Lightsail SD 설정을 사용하면 [AWS Lightsail](https://aws.amazon.com/lightsail/) 인스턴스에서 스크랩 타겟을 가져올 수 있다.기본적으로는 private IP 주소를 사용하지만, relabeling을 이용해서 public IP 주소로 변경할 수도 있다.

[relabeling](#relabel_config) 동안에는 잠시 타겟에 아래와 같은 메타 레이블들이 추가된다:

- `__meta_lightsail_availability_zone`: 인스턴스가 실행되고 있는 availability zone
- `__meta_lightsail_blueprint_id`: Lightsail blueprint ID
- `__meta_lightsail_bundle_id`: Lightsail bundle ID
- `__meta_lightsail_instance_name`: Lightsail 인스턴스 이름
- `__meta_lightsail_instance_state`: Lightsail 인스턴스의 state
- `__meta_lightsail_instance_support_code`: Lightsail 인스턴스의 지원 코드
- `__meta_lightsail_ipv6_addresses`: 인스턴스의 네트워크 인터페이스에 할당된 IPv6 주소 목록 (콤마로 구분) (있다면)
- `__meta_lightsail_private_ip`: 인스턴스의 private IP 주소
- `__meta_lightsail_public_ip`: 인스턴스의 public IP 주소 (있다면)
- `__meta_lightsail_tag_<tagkey>`: 인스턴스의 각 태그 값

Lightsail 디스커버리 설정 옵션은 아래를 참고해라:

```yaml
# Lightsail API에 접근할 때 사용할 정보.

# AWS region. 비어있으면 인스턴스 메타데이터에 있는 region을 사용한다.
[ region: <string> ]

# 사용할 커스텀 엔드포인트.
[ endpoint: <string> ]

# AWS API 키. 비어있으면 환경 변수
# `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`를 사용한다.
[ access_key: <string> ]
[ secret_key: <secret> ]
# API에 연결할 때 사용할 AWS 프로파일 이름.
[ profile: <string> ]

# AWS API 키 대신 사용할 수 있는 AWS Role ARN.
[ role_arn: <string> ]

# 인스턴스 목록을 다시 읽어올 리프레시 간격.
[ refresh_interval: <duration> | default = 60s ]

# 메트릭을 스크랩할 포트.
# public IP를 사용한다면, 이 곳이 아닌 relabeling rule에서 지정해야 한다.
[ port: <int> | default = 80 ]
```

### `<linode_sd_config>`

Linode SD 설정을 사용하면 [Linode의](https://www.linode.com/) Linode APIv4로 스크랩 타겟을 가져올 수 있다. 이때 서비스 디스커버리는 기본적으로 public IPv4 주소를 사용하며, [이 프로메테우스 linode-sd 설정 파일](https://github.com/prometheus/prometheus/blob/release-2.32/documentation/examples/prometheus-linode.yml)에서 보여주는 것처럼 relabelling을 통해 변경할 수 있다.
[relabeling](#relabel_config) 동안에는 잠시 타겟에 아래와 같은 메타 레이블들이 추가된다:

- `__meta_linode_instance_id`: linode 인스턴스 id
- `__meta_linode_instance_label`: linode 인스턴스 레이블
- `__meta_linode_image`: linode 인스턴스 이미지의 slug
- `__meta_linode_private_ipv4`: linode 인스턴스의 private IPv4
- `__meta_linode_public_ipv4`: linode 인스턴스의 public IPv4
- `__meta_linode_public_ipv6`: linode 인스턴스의 public IPv6
- `__meta_linode_region`: linode 인스턴스의 region
- `__meta_linode_type`: linode 인스턴스 타입
- `__meta_linode_status`: linode 인스턴스의 status
- `__meta_linode_tags`: 태그 구분 기호로 연결한 linode 인스턴스의 태그 목록
- `__meta_linode_group`: linode 인스턴스가 속해있는 display 그룹
- `__meta_linode_hypervisor`: linode 인스턴스를 구동하는 가상화 소프트웨어
- `__meta_linode_backups`: linode 인스턴스의 백업 서비스 status
- `__meta_linode_specs_disk_bytes`: linode 인스턴스가 액세스할 수 있는 스토리지 공간 용량
- `__meta_linode_specs_memory_bytes`: linode 인스턴스가 액세스할 수 있는 RAM 용량
- `__meta_linode_specs_vcpus`: 이 linode가 액세스할 수 있는 VCPU 갯수
- `__meta_linode_specs_transfer_bytes`: 매월 할당되는 linode 인스턴스의 네트워크 전송량
- `__meta_linode_extra_ips`: linode 인스턴스에 할당된 모든 추가 IPv4 주소 목록 (태그 구분 기호로 연결)

```yaml
# API 서버에 인증할 때 사용하는 인증 정보.
# 참고로, `basic_auth`와 `authorization` 옵션은 함께 사용할 수 없다.
# password와 password_file도 함께 사용할 수 없다.
# 참고: Linode APIv4 토큰은 'linodes:read_only', 'ips:read_only', 'events:read_only' 스코프로 생성해야 한다.

# HTTP 기본 인증 정보 (Optional). 현재 Linode APIv4에서 지원하지 않는다.
basic_auth:
  [ username: <string> ]
  [ password: <secret> ]
  [ password_file: <string> ]

# `Authorization` 헤더 설정 (Optional).
authorization:
  # 인증 타입을 설정한다.
  [ type: <string> | default: Bearer ]
  # credential을 설정한다.
  # `credentials_file`과는 함께 사용할 수 없다.
  [ credentials: <secret> ]
  # 설정한 파일에서 읽어온 credential을 설정한다.
  # `credentials`와는 함께 사용할 수 없다.
  [ credentials_file: <filename> ]

# OAuth 2.0 설정 (Optional).
# basic_auth나 authorization과는 동시에 사용할 수 없다.
oauth2:
  [ <oauth2> ]

# 프록시 URL (Optional).
[ proxy_url: <string> ]

# HTTP 요청에서 HTTP 3xx 리다이렉트 지시를 따를지 여부를 설정한다.
[ follow_redirects: <bool> | default = true ]

# TLS 설정.
tls_config:
  [ <tls_config> ]

# 메트릭을 스크랩할 포트.
[ port: <int> | default = 80 ]

# Linode 인스턴스 태그들을 연결해서 태그 레이블에 저장할 때 사용할 문자열.
[ tag_separator: <string> | default = , ]

# linode 인스턴스들을 리프레시할 시간.
[ refresh_interval: <duration> | default = 60s ]
```

### `<marathon_sd_config>`

Marathon SD 설정을 사용하면 [Marathon](https://mesosphere.github.io/marathon/) REST API로 스크랩 타겟을 가져올 수 있다. 프로메테우스는 REST 엔드포인트로 현재 실행 중인 태스크들을 주기적으로 확인해서, 정상적인 태스크가 하나라도 있는 앱마다 타겟 그룹을 하나씩 생성한다.

[relabeling](#relabel_config) 동안에는 잠시 타겟에 아래와 같은 메타 레이블들이 추가된다:

- `__meta_marathon_app`: 앱 이름 (슬래시는 대시로 치환)
- `__meta_marathon_image`: 사용한 도커 이미지 이름 (있으면)
- `__meta_marathon_task`: Mesos 태스크 ID
- `__meta_marathon_app_label_<labelname>`: 앱에 첨부된 모든 Marathon 레이블
- `__meta_marathon_port_definition_label_<labelname>`: 포트 정의 레이블들
- `__meta_marathon_port_mapping_label_<labelname>`: 포트 매핑 레이블들
- `__meta_marathon_port_index`: 포트 인덱스 넘버 (ex. `PORT1`에선 `1`)

Marathon 디스커버리 설정 옵션은 아래를 참고해라:

```yaml
# Marathon 서버에 접속할 때 사용할 URL 목록.
# 최소한 서버 URL 하나는 제공해야 한다.
servers:
  - <string>

# Polling interval
[ refresh_interval: <duration> | default = 30s ]

# 토큰 기반 인증을 위한 인증 정보 (Optional)
# https://docs.mesosphere.com/1.11/security/ent/iam-api/#passing-an-authentication-token
# 이 설정은 `auth_token_file`이나 다른 인증 메커니즘과는 함께 사용할 수 없다.
[ auth_token: <secret> ]

# 토큰 기반 인증을 위한 인증 정보 (Optional)
# https://docs.mesosphere.com/1.11/security/ent/iam-api/#passing-an-authentication-token
# 이 설정은 `auth_token`이나 다른 인증 메커니즘과는 함께 사용할 수 없다.
[ auth_token_file: <filename> ]

# 설정한 username과 password로 모든 요청에 `Authorization` 헤더를 세팅한다.
# 이 설정은 다른 인증 메커니즘과는 함께 사용할 수 없다.
# password와 password_file도 함께 사용할 수 없다.
basic_auth:
  [ username: <string> ]
  [ password: <secret> ]
  [ password_file: <string> ]

# `Authorization` 헤더 설정 (Optional).
# 참고: 현재 DC/OS marathon 버전(v1.11.0)은 표준 `Authentication` 헤더를 지원하지 않는다.
# 이 설정 대신 `auth_token`이나 `auth_token_file`을 사용해라.
authorization:
  # 인증 타입을 설정한다.
  [ type: <string> | default: Bearer ]
  # credential을 설정한다.
  # `credentials_file`과는 함께 사용할 수 없다.
  [ credentials: <secret> ]
  # 설정한 파일에서 읽어온 credential을 설정한다.
  # `credentials`와는 함께 사용할 수 없다.
  [ credentials_file: <filename> ]

# OAuth 2.0 설정 (Optional).
# basic_auth나 authorization과는 동시에 사용할 수 없다.
oauth2:
  [ <oauth2> ]

# HTTP 요청에서 HTTP 3xx 리다이렉트 지시를 따를지 여부를 설정한다.
[ follow_redirects: <bool> | default = true ]

# marathon 서버에 연결하기 위한 TLS 설정
tls_config:
  [ <tls_config> ]

# 프록시 URL (Optional).
[ proxy_url: <string> ]
```

프로메테우스는 기본적으로 Marathon에 있는 모든 앱을 스크랩한다. 모든 서비스가 프로메테우스 메트릭을 제공하진 않는다면, Marathon 레이블과 프로메테우스 relabeling을 이용해서 실제로 스크랩할 인스턴스들을 조절해주면 된다. Marathon 앱과 프로메테우스 설정을 위한 실전 예시는 [이 프로메테우스 marathon-sd 설정 파일](https://github.com/prometheus/prometheus/blob/release-2.32/documentation/examples/prometheus-marathon.yml)을 참고해라.

기본적으론 모든 앱이 프로메테우스의 단일 job으로 표시되며 (설정 파일에서 사용하는 job), 역시 relabeling을 통해 변경할 수 있다.

### `<nerve_sd_config>`

Nerve SD 설정을 사용하면 [AirBnB의 Nerve](https://github.com/airbnb/nerve)에서 [Zookeeper](https://zookeeper.apache.org/)에 저장돼 있는 스크랩 타겟을 가져올 수 있다.

[relabeling](#relabel_config) 동안에는 잠시 타겟에 아래와 같은 메타 레이블들이 추가된다:

- `__meta_nerve_path`: Zookeeper에 등록된 엔드포인트 노드의 전체 경로
- `__meta_nerve_endpoint_host`: 엔드포인트 호스트
- `__meta_nerve_endpoint_port`: 엔드포인트 포트
- `__meta_nerve_endpoint_name`: 엔드포인트 이름

```yaml
# Zookeeper 서버들.
servers:
  - <host>
# 경로에선 단일 서비스나 서비스 트리의 루트를 가리킬 수 있다.
paths:
  - <string>
[ timeout: <duration> | default = 10s ]
```

### `<serverset_sd_config>`

Serverset SD 설정을 사용하면 [Serversets](https://github.com/twitter/finagle/tree/master/finagle-serversets)에서 [Zookeeper](https://zookeeper.apache.org/)에 저장돼 있는 스크랩 타겟을 가져올 수 있다. Serverset은 흔히 [Finagle](https://twitter.github.io/finagle/)과 [Aurora](https://aurora.apache.org/)에서 사용한다.

[relabeling](#relabel_config) 동안에는 잠시 타겟에 아래와 같은 메타 레이블들이 추가된다:

- `__meta_serverset_path`: Zookeeper에 등록된 serverset 멤버 노드의 전체 경로
- `__meta_serverset_endpoint_host`: 디폴트 엔드포인트 호스트
- `__meta_serverset_endpoint_port`: 디폴트 엔드포인트 포트
- `__meta_serverset_endpoint_host_<endpoint>`: 주어진 엔드포인트의 호스트
- `__meta_serverset_endpoint_port_<endpoint>`: 주어진 엔드포인트의 포트
- `__meta_serverset_shard`: 멤버의 샤드 수
- `__meta_serverset_status`: 멤버의 status

```yaml
# Zookeeper 서버들.
servers:
  - <host>
# 경로에선 단일 serverset이나나 serversets 트리의 루트를 가리킬 수 있다.
paths:
  - <string>
[ timeout: <duration> | default = 10s ]
```

Serverset 데이터는 반드시 JSON 형식을 따라야 하며, Thrift 형식은 현재 지원하지 않는다.

### `<triton_sd_config>`

[Triton](https://github.com/joyent/triton) SD 설정을 사용하면 [Container Monitor](https://github.com/joyent/rfd/blob/master/rfd/0027/README.md) 디스커버리 엔드포인트에서 스크랩 타겟을 가져올 수 있다.

타겟 디스커버리에는 아래 있는 `<triton_role>` 타입 중 하나를 설정할 수 있다:

#### `container`

`container` role은`account`가 소유하고 있는 "가상 머신"마다 타겟을 하나씩 검색한다. 가상 머신은 SmartOS zone이나 lx/KVM/bhyve branded zone이다.

[relabeling](#relabel_config) 동안에는 잠시 타겟에 아래와 같은 메타 레이블들이 추가된다:

- `__meta_triton_groups`: 타겟에 속하는 그룹 목록 (콤마로 연결)
- `__meta_triton_machine_alias`: 타겟 컨테이너의 alias
- `__meta_triton_machine_brand`: 타겟 컨테이너의 brand
- `__meta_triton_machine_id`: 타겟 컨테이너의 UUID
- `__meta_triton_machine_image`: 타겟 컨테이너의 이미지 타입
- `__meta_triton_server_id`: 타겟 컨테이너가 실행되고 있는 서버 UUID

#### `cn`

`cn` role은 Triton 인프라를 구성하는 컴퓨팅 노드("서버" 또는 "글로벌 zone"이라도 부른다)마다 타겟을 하나씩 검색한다. 이때 `account`는 반드시 Triton operator여야 하며, 현재 `container`를 최소 1개는 소유하고 있어야 한다.

[relabeling](#relabel_config) 동안에는 잠시 타겟에 아래와 같은 메타 레이블들이 추가된다:

- `__meta_triton_machine_alias`: 타겟의 호스트명 (triton-cmon 1.7.0 이상이 필요하다)
- `__meta_triton_machine_id`: 타겟의 UUID

Triton 디스커버리 설정 옵션은 아래를 참고해라:

```yaml
# Triton 디스커버리 API에 접근하기 위한 정보.

# 새 타겟을 검색할 때 사용할 계정.
account: <string>

# 검색할 타겟 타입은 다음과 같이 설정할 수 있다:
# * "container": Triton에서 실행하는 가상 머신(SmartOS zone, lx/KVM/bhyve branded zones)들을 검색
# * "cn":  Triton 인프라를 구성하는 컴퓨팅 노드(서버/글로벌 zone)를 검색
[ role : <string> | default = "container" ]

# 타겟에 적용할 DNS suffix.
dns_suffix: <string>

# Triton 디스커버리 엔드포인트 (ex. 'cmon.us-east-3b.triton.zone').
# 보통 dns_suffix와 동일한 값을 사용한다.
endpoint: <string>

# 타겟을 조회할 그룹 목록. `role` == `container`일 때만 지원한다.
# 생략하면 요청 계정이 소유한 모든 컨테이너를 스크랩한다.
groups:
  [ - <string> ... ]

# 디스커버리와 메트릭 스크랩에 이용할 포트.
[ port: <int> | default = 9163 ]

# 타겟 리프레시에 사용할 간격.
[ refresh_interval: <duration> | default = 60s ]

# Triton 디스커버리 API 버전.
[ version: <int> | default = 1 ]

# TLS 설정.
tls_config:
  [ <tls_config> ]
```

### `<eureka_sd_config>`

Eureka SD 설정을 사용하면 [Eureka](https://github.com/Netflix/eureka) REST API로 스크랩 타겟을 가져올 수 있다. 프로메테우스는 REST 엔드포인트를 주기적으로 확인해서, 앱 인스턴스마다 타겟을 하나씩 생성한다.

[relabeling](#relabel_config) 동안에는 잠시 타겟에 아래와 같은 메타 레이블들이 추가된다:

- `__meta_eureka_app_name`: 앱 이름
- `__meta_eureka_app_instance_id`: 앱 인스턴스 ID
- `__meta_eureka_app_instance_hostname`: 인스턴스 호스트명
- `__meta_eureka_app_instance_homepage_url`: 앱 인스턴스의 홈페이지 url
- `__meta_eureka_app_instance_statuspage_url`: 앱 인스턴스의 status 페이지 url
- `__meta_eureka_app_instance_healthcheck_url`: 앱 인스턴스의 헬스체크 url
- `__meta_eureka_app_instance_ip_addr`: 앱 인스턴스의 IP 주소
- `__meta_eureka_app_instance_vip_address`: 앱 인스턴스의 VIP 주소
- `__meta_eureka_app_instance_secure_vip_address`: 앱 인스턴스의 secure VIP 주소
- `__meta_eureka_app_instance_status`: 앱 인스턴스의 status
- `__meta_eureka_app_instance_port`: 앱 인스턴스의 포트
- `__meta_eureka_app_instance_port_enabled`: 앱 인스턴스에서 활성화한 포트
- `__meta_eureka_app_instance_secure_port`: 앱 인스턴스의 secure 포트 주소
- `__meta_eureka_app_instance_secure_port_enabled`: 앱 인스턴스의 secure 포트
- `__meta_eureka_app_instance_country_id`: 앱 인스턴스의 국가 ID
- `__meta_eureka_app_instance_metadata_<metadataname>`: 앱 인스턴스 메타데이터
- `__meta_eureka_app_instance_datacenterinfo_name`: 앱 인스턴스의 데이터센터 이름
- `__meta_eureka_app_instance_datacenterinfo_<metadataname>`: 데이터센터 메타데이터

Eureka 디스커버리 설정 옵션은 아래를 참고해라:

```yaml
# Eureka 서버 연결할 때 사용할 URL. 
server: <string>

# 설정한 username과 password로 모든 요청에 `Authorization` 헤더를 세팅한다.
# password와 password_file은 함께 사용할 수 없다.
basic_auth:
  [ username: <string> ]
  [ password: <secret> ]
  [ password_file: <string> ]

# `Authorization` 헤더 설정 (Optional).
authorization:
  # 인증 타입을 설정한다.
  [ type: <string> | default: Bearer ]
  # credential을 설정한다.
  # `credentials_file`과는 함께 사용할 수 없다.
  [ credentials: <secret> ]
  # 설정한 파일에서 읽어온 credential을 설정한다.
  # `credentials`와는 함께 사용할 수 없다.
  [ credentials_file: <filename> ]

# OAuth 2.0 설정 (Optional).
# basic_auth나 authorization과는 동시에 사용할 수 없다.
oauth2:
  [ <oauth2> ]

# 스크랩 요청에서 사용할 TLS 설정을 구성한다.
tls_config:
  [ <tls_config> ]

# 프록시 URL (Optional).
[ proxy_url: <string> ]

# HTTP 요청에서 HTTP 3xx 리다이렉트 지시를 따를지 여부를 설정한다.
[ follow_redirects: <bool> | default = true ]

# 앱 인스턴스 목록을 다시 읽어오기 위한 리프레시 간격.
[ refresh_interval: <duration> | default = 30s ]
```

Eureka 앱과 프로메테우스 설정을 위한 실전 예시는 [이 프로메테우스 eureka-sd 설정 파일](https://github.com/prometheus/prometheus/blob/release-2.32/documentation/examples/prometheus-eureka.yml)을 참고해라.

### `<scaleway_sd_config>`

Scaleway SD 설정을 사용하면 [Scaleway 인스턴스](https://www.scaleway.com/en/virtual-instances/)와 [베어메탈<sup>baremetal</sup> 서비스](https://www.scaleway.com/en/bare-metal-servers/)에서 스크랩 타겟을 가져올 수 있다.

[relabeling](#relabel_config) 동안에는 잠시 타겟에 아래와 같은 메타 레이블들이 추가된다:

#### Instance role

- `__meta_scaleway_instance_boot_type`: 서버의 부트 타입
- `__meta_scaleway_instance_hostname`: 서버 호스트명
- `__meta_scaleway_instance_id`: 서버 ID
- `__meta_scaleway_instance_image_arch`: 서버 이미지 arch
- `__meta_scaleway_instance_image_id`: 서버 이미지 ID
- `__meta_scaleway_instance_image_name`: 서버 이미지 이름
- `__meta_scaleway_instance_location_cluster_id`: 서버가 위치해 있는 클러스터 ID
- `__meta_scaleway_instance_location_hypervisor_id`: 서버가 위치해 있는 hypervisor ID
- `__meta_scaleway_instance_location_node_id`: 서버가 위치해 있는 노드 ID
- `__meta_scaleway_instance_name`: 서버 이름
- `__meta_scaleway_instance_organization_id`: 서버 organization
- `__meta_scaleway_instance_private_ipv4`: 서버의 private IPv4 주소
- `__meta_scaleway_instance_project_id`: 서버의 프로젝트 id
- `__meta_scaleway_instance_public_ipv4`: 서버의 public IPv4 주소
- `__meta_scaleway_instance_public_ipv6`: 서버의 public IPv6 주소
- `__meta_scaleway_instance_region`: 서버의 region
- `__meta_scaleway_instance_security_group_id`: 서버의 시큐리티 그룹 ID
- `__meta_scaleway_instance_security_group_name`: 서버의 시큐리티 그룹 이름
- `__meta_scaleway_instance_status`: 서버의 status
- `__meta_scaleway_instance_tags`: 서버의 태그 목록 (태그 구분 기호로 연결)
- `__meta_scaleway_instance_type`: 서버의 commercial 타입
- `__meta_scaleway_instance_zone`: 서버의 zone (ex: `fr-par-1`, 전체 목록은 [여기](https://developers.scaleway.com/en/products/instance/api/#introduction)에서 확인할 수 있다)

이 role에선 기본적으로 private IPv4 주소를 사용하며, [이 프로메테우스 scaleway-sd 설정 파일](https://github.com/prometheus/prometheus/blob/release-2.32/documentation/examples/prometheus-scaleway.yml)에서 보여주는 것처럼 relabelling을 통해 변경할 수 있다.

#### Baremetal role

- `__meta_scaleway_baremetal_id`: 서버 ID
- `__meta_scaleway_baremetal_public_ipv4`: 서버의 public IPv4 주소
- `__meta_scaleway_baremetal_public_ipv6`: 서버의 public IPv6 주소
- `__meta_scaleway_baremetal_name`: 서버 이름
- `__meta_scaleway_baremetal_os_name`: 서버의 운영 체제 이름
- `__meta_scaleway_baremetal_os_version`: 서버의 운영 체제 버전
- `__meta_scaleway_baremetal_project_id`: 서버의 프로젝트 ID
- `__meta_scaleway_baremetal_status`: 서버의 status
- `__meta_scaleway_baremetal_tags`: 서버의 태그 목록 (태그 구분 기호로 연결)
- `__meta_scaleway_baremetal_type`: 서버의 commercial 타입
- `__meta_scaleway_baremetal_zone`: 서버의 zone (ex: `fr-par-1`, 전체 목록은 [여기](https://developers.scaleway.com/en/products/instance/api/#introduction)에서 확인할 수 있다)

이 role에선 기본적으로 public IPv4 주소를 사용하며, [이 프로메테우스 scaleway-sd 설정 파일](https://github.com/prometheus/prometheus/blob/release-2.32/documentation/examples/prometheus-scaleway.yml)에서 보여주는 것처럼 relabelling을 통해 변경할 수 있다.

Scaleway 디스커버리 설정 옵션은 아래를 참고해라:

```yaml
# 사용할 액세스 키. https://console.scaleway.com/project/credentials
access_key: <string>

# 타겟 목록 요청에 사용할 시크릿 키. https://console.scaleway.com/project/credentials
# `secret_key_file`과는 함께 사용할 수 없다.
[ secret_key: <secret> ]

# 설정한 파일에서 읽어온 credential로 시크릿 키를 설정한다.
# `secret_key`와는 함께 사용할 수 없다.
[ secret_key_file: <filename> ]

# 타겟들의 프로젝트 ID.
project_id: <string>

# 타겟을 조회할 role. `instance`, `baremetal` 중 하나여야 한다.
role: <string>

# 메트릭을 스크랩할 포트.
[ port: <int> | default = 80 ]

# 서버 목록을 요청할 때 사용할 API URL.
[ api_url: <string> | default = "https://api.scaleway.com" ]

# Zone에는 타겟의 availability zone 설정한다 (ex. fr-par-1).
[ zone: <string> | default = fr-par-1 ]

# NameFilter는 서버 목록 요청에 적용할 이름 필터(LIKE로 동작)를 지정한다.
[ name_filter: <string> ]

# TagsFilter는 서버 목록 요청에 적용할 태그 필터를 지정한다 (서버 하나에 정의한 모든 태그가 있어야 한다).
tags_filter:
[ - <string> ]

# 타겟 목록을 다시 읽어오기 위한 리프레시 간격.
[ refresh_interval: <duration> | default = 60s ]

# HTTP 요청에서 HTTP 3xx 리다이렉트 지시를 따를지 여부를 설정한다.
[ follow_redirects: <bool> | default = true ]

# 프록시 URL (Optional).
[ proxy_url: <string> ]

# TLS 설정.
tls_config:
  [ <tls_config> ]
```

### `<uyuni_sd_config>`

Uyuni SD 설정을 사용하면 [Uyuni](https://www.uyuni-project.org/)를 통해 관리하는 시스템에서 스크랩 타겟을 가져올 수 있다.

[relabeling](#relabel_config) 동안에는 잠시 타겟에 아래와 같은 메타 레이블들이 추가된다:

- `__meta_uyuni_endpoint_name`: 애플리케이션 엔드포인트 이름
- `__meta_uyuni_exporter`: 타겟의 메트릭을 노출해주는 익스포터
- `__meta_uyuni_groups`: 타겟의 시스템 그룹들
- `__meta_uyuni_metrics_path`: 타겟의 메트릭 경로
- `__meta_uyuni_minion_hostname`: Uyuni 클라이언트의 호스트명
- `__meta_uyuni_primary_fqdn`: 클라이언트의 primary FQDN
- `__meta_uyuni_proxy_module`: 타겟에 *익스포터* 프록시가 설정돼있다면 해당 모듈 이름
- `__meta_uyuni_scheme`: 요청에 사용한 프로토콜 스킴
- `__meta_uyuni_system_id`: 클라이언트의 시스템 ID

Uyuni 디스커버리 설정 옵션은 아래를 참고해라:

```yaml
# Uyuni 서버에 연결하기 위한 URL.
server: <string>

# Uyuni API에 대한 요청을 인증할 때 사용할 credential.
username: <string>
password: <secret>

# 자격이 되는 시스템을 필터링하기 위한 entitlement 문자열.
[ entitlement: <string> | default = monitoring_entitled ]

# Uyuni 그룹명들을 하나의 groups 레이블로 합칠 때 사용할 문자열.
[ separator: <string> | default = , ]

# 관리 중인 타겟 목록을 다시 읽어오기 위한 리프레시 간격.
[ refresh_interval: <duration> | default = 60s ]

# HTTP 기본 인증 정보 (Optional). 현재 Uyuni에서 지원하지 않는다.
basic_auth:
  [ username: <string> ]
    [ password: <secret> ]
    [ password_file: <string> ]

# `Authorization` 헤더 설정 (Optional). 현재 Uyuni에서 지원하지 않는다.
authorization:
  # 인증 타입을 설정한다.
    [ type: <string> | default: Bearer ]
    # credential을 설정한다.
    # `credentials_file`과는 함께 사용할 수 없다.
    [ credentials: <secret> ]
    # 설정한 파일에서 읽어온 credential을 설정한다.
    # `credentials`와는 함께 사용할 수 없다.
    [ credentials_file: <filename> ]

# OAuth 2.0 설정 (Optional). 현재 Uyuni에서 지원하지 않는다.
# basic_auth나 authorization과는 동시에 사용할 수 없다.
oauth2:
  [ <oauth2> ]

# 프록시 URL (Optional).
  [ proxy_url: <string> ]

# HTTP 요청에서 HTTP 3xx 리다이렉트 지시를 따를지 여부를 설정한다.
  [ follow_redirects: <bool> | default = true ]

# TLS 설정.
tls_config:
  [ <tls_config> ]
```

Uyuni 프로메테우스 설정을 위한 실전 예시는 [이 프로메테우스 uyuni-sd 설정 파일](https://github.com/prometheus/prometheus/blob/release-2.32/documentation/examples/prometheus-uyuni.yml)을 참고해라.

### `<static_config>`

`static_config`를 사용하면 타겟 목록과, 공통으로 사용할 레이블 셋을 지정할 수 있다. 스크랩 컨피그에서 타겟을 정적으로 지정하는 표준 설정이다.

```yaml
# 이 스태틱 컨피그에서 지정하는 타겟들
targets:
  [ - '<host>' ]

# 타겟들에서 스크랩한 모든 메트릭에 할당할 레이블들.
labels:
  [ <labelname>: <labelvalue> ... ]
```

### `<relabel_config>`

Relabeling은 타겟을 스크랩하기 전에 동적으로 레이블 셋을 재작성할 수 있는 아주 유용한 기능이다. relabeling은 각 스크랩 설정마다 여러 단계로 등록할 수 있다. 타겟마다 설정 파일에 명시한 순서대로 레이블 셋에 반영된다.

타겟별로 설정한 레이블을 반영하기 전엔 가장 먼저, 스크랩 설정마다 가지고 있는 `job_name`의 값을 타겟의 `job` 레이블로 세팅한다. 타겟의 `<host>:<port>` 주소는 `__address__` 레이블에 저장한다. relabeling 동안에 `instance` 레이블이 설정되지 않았다면,  relabeling을 마친 후에 디폴트로 `__address__`에 있는 값을 설정한다. `__scheme__`, `__metrics_path__` 레이블은 각각 타겟의 스킴과 메트릭 경로로 설정된다. `__param_<name>` 레이블에는 `<name>`이라는 이름으로 전달하는 첫번째 URL 파라미터 값을 설정한다.

`__scrape_interval__`과 `__scrape_timeout__`에는 타겟의 인터벌과 타임아웃을 설정한다. 이 레이블은 **실험 단계**에 있으며, 향후 변경될 수 있다.

relabeling 진행 중에는 `__meta_` 프리픽스가 달려 있는 별도 레이블을 사용할 수도 있다. 타겟을 제공한 서비스 디스커버리 메커니즘으로 설정되며, 설정하는 값은 메커니즘마다 다르다.

타겟 relabeling이 완료된 후엔 `__`로 시작하는 레이블들은 레이블 셋에서 제거된다.

relabeling 단계에서 레이블을 임시로 저장해야 한다면 (그 다음 relabeling 단계에서 사용할 용도로) 레이블 이름 앞에 `__tmp`를 붙여라. 이 프리픽스를 달아주면 프로메테우스 자체에선 절대 사용하지 않는다.

```yaml
# 소스 레이블에 레이블명을 지정하면 기존 레이블들에서 값을 가져온다.
# 레이블들의 값은 설정한 구분 기호를 통해 연결되며,
# 이후 replace, keep, drop 작업에서 설정해둔 정규식과 매칭시켜 본다.
[ source_labels: '[' <labelname> [, ...] ']' ]

# 소스 레이블 값 사이사이에 연결할 구분 기호.
[ separator: <string> | default = ; ]

# replace 작업에서 결과 값을 기록할 레이블.
# replace 작업에선 반드시 지정해야 한다. Regex capture group을 사용할 수 있다.
[ target_label: <labelname> ]

# 추출한 값을 매칭시켜볼 정규 표현식.
[ regex: <regex> | default = (.*) ]

# 소스 레이블 값의 해시를 사용하는 나머지 연산.
[ modulus: <int> ]

# replace 작업에서 정규 표현식과 매칭됐을 때 사용할 대체 값.
# Regex capture group을 사용할 수 있다.
[ replacement: <string> | default = $1 ]

# 정규식을 매칭해서 수행할 작업.
[ action: <relabel_action> | default = replace ]
```

`<regex>`엔 유효한 [RE2 정규식](https://github.com/google/re2/wiki/Syntax)을 작성해주면 된다. `replace`, `keep`, `drop`, `labelmap`,`labeldrop`, `labelkeep` 작업에 필요하다. 정규식은 앵커<sup>anchor</sup>를 사용해 시작과 끝을 고정한다. 양 끝을 고정하는 게 싫다면 `.*<regex>.*`를 사용해라.

`<relabel_action>`은 수행할 relabeling 작업을 결정한다:

- `replace`: 구분자로 연결한 `source_labels`에 `regex`를 매칭시켜 본다. 매칭되면 `replacement`의 match 그룹 레퍼런스(`${1}`, `${2}`, ...)를 해당 값들로 대체한 다음 `target_label`에 저장한다. `regex`가 매칭되지 않으면 값을 대체하지 않는다.
- `keep`: 구분자로 연결한 `source_labels`가  `regex`에 매칭되지 않으면 타겟을 제외시킨다.
- `drop`: 구분자로 연결한 `source_labels`가  `regex`에 매칭되면 타겟을 제외시킨다.
- `hashmod`: 구분자로 연결한 `source_labels`의 해시값에 나머지 연산<sup>modulus</sup>을 수행한 결과를 `target_label`에 저장한다.
- `labelmap`: 모든 레이블 이름에 `regex`를 매칭시켜 본다. 레이블 이름이 일치하면, `replacement`의 match 그룹 레퍼런스(`${1}`, `${2}`, ...)를 해당 값으로 대체해서 만든 이름에 레이블 값을 복사한다.
- `labeldrop`: 모든 레이블 이름에 `regex`를 매칭시켜 본다. 일치하는 모든 레이블을 레이블 셋에서 제거한다.
- `labelkeep`: 모든 레이블 이름에 `regex`를 매칭시켜 본다. 일치하지 않는 모든 레이블을 레이블 셋에서 제거한다.

`labeldrop`과 `labelkeep`을 사용할 땐, 레이블을 제거한 후에도 메트릭에 고유한 레이블이 남아있을 수 있도록 주의해야 한다.

### `<metric_relabel_configs>`

메트릭 relabeling은 샘플에 적용되는 기능으로, 샘플을 수집하기 전 마지막 단계에서 반영한다. 설정 형식이나 수행하는 작업은 타겟 relabeling과 동일하다. 메트릭 relabeling은 `up`과 같이 자동으로 생성되는 시계열엔 적용되지 않는다.

이 기능은 수집하기엔 비용이 너무 큰 시계열을 제외시키는 용도 등으로 활용할 수 있다.

### `<alert_relabel_configs>`

Alert relabeling은 alert에 적용되는 기능으로, alert를 Alertmanager로 전송하기 전에 반영한다. 설정 형식이나 수행하는 작업은 타겟 relabeling과 동일하다. Alert relabeling은 외부 레이블들을 반영한 이후에 적용된다.

이 기능은 프로메테우스 서버 HA 쌍이 외부 레이블이 다르더라도 동일한 alert를 보내도록 만드는 등에 활용할 수 있다.

### `<alertmanager_config>`

`alertmanager_config` 섹션엔 프로메테우스 서버가 alert를 전송하는 Alertmanager 인스턴스를 지정한다. Alertmanager와 통신하는 방법을 설정하는 파라미터도 함께 제공한다.

Alertmanager는 `static_configs` 파라미터를 통해 정적으로 설정할 수도 있고, 지원하는 서비스 디스커버리 메커니즘 중 하나를 이용해 동적으로 잡아낼 수도 있다.

이 밖에도, `relabel_configs`를 사용하면 발견한 엔티티 중에서 Alertmanager를 선별할 수 있으며, `__alerts_path__`로 노출되는 레이블을 이용해 사용할 API 경로를 더 수정할 수도 있다.

```yaml
# 타겟별로 alert를 전송할 때 사용할 Alertmanager 타임 아웃.
[ timeout: <duration> | default = 10s ]

# Alertmanager api 버전.
[ api_version: <string> | default = v2 ]

# alert를 전송할 때 사용할 HTTP 경로의 프리픽스
[ path_prefix: <path> | default = / ]

# 요청에 사용할 프로토콜 스킴을 설정한다.
[ scheme: <scheme> | default = http ]

# 설정한 username과 password로 모든 요청에 `Authorization` 헤더를 세팅한다.
# password와 password_file은 함께 사용할 수 없다.
basic_auth:
  [ username: <string> ]
  [ password: <secret> ]
  [ password_file: <string> ]

# `Authorization` 헤더 설정 (Optional).
authorization:
  # 인증 타입을 설정한다.
  [ type: <string> | default: Bearer ]
  # credential을 설정한다.
  # `credentials_file`과는 함께 사용할 수 없다.
  [ credentials: <secret> ]
  # 설정한 파일에서 읽어온 credential을 설정한다.
  # `credentials`와는 함께 사용할 수 없다.
  [ credentials_file: <filename> ]

# OAuth 2.0 설정 (Optional).
# basic_auth나 authorization과는 동시에 사용할 수 없다.
oauth2:
  [ <oauth2> ]

# 스크랩 요청에서 사용할 TLS 설정을 구성한다.
tls_config:
  [ <tls_config> ]

# 프록시 URL (Optional).
[ proxy_url: <string> ]

# HTTP 요청에서 HTTP 3xx 리다이렉트 지시를 따를지 여부를 설정한다.
[ follow_redirects: <bool> | default = true ]

# Azure 서비스 디스커버리 설정 목록.
azure_sd_configs:
  [ - <azure_sd_config> ... ]

# Consul 서비스 디스커버리 설정 목록.
consul_sd_configs:
  [ - <consul_sd_config> ... ]

# DNS 서비스 디스커버리 설정 목록.
dns_sd_configs:
  [ - <dns_sd_config> ... ]

# EC2 서비스 디스커버리 설정 목록.
ec2_sd_configs:
  [ - <ec2_sd_config> ... ]

# Eureka 서비스 디스커버리 설정 목록.
eureka_sd_configs:
  [ - <eureka_sd_config> ... ]

# file 서비스 디스커버리 설정 목록.
file_sd_configs:
  [ - <file_sd_config> ... ]

# DigitalOcean 서비스 디스커버리 설정 목록.
digitalocean_sd_configs:
  [ - <digitalocean_sd_config> ... ]

# Docker 서비스 디스커버리 설정 목록.
docker_sd_configs:
  [ - <docker_sd_config> ... ]

# Docker Swarm 서비스 디스커버리 설정 목록.
dockerswarm_sd_configs:
  [ - <dockerswarm_sd_config> ... ]

# GCE 서비스 디스커버리 설정 목록.
gce_sd_configs:
  [ - <gce_sd_config> ... ]

# Hetzner 서비스 디스커버리 설정 목록.
hetzner_sd_configs:
  [ - <hetzner_sd_config> ... ]

# HTTP 서비스 디스커버리 설정 목록.
http_sd_configs:
  [ - <http_sd_config> ... ]

# Kubernetes 서비스 디스커버리 설정 목록.
kubernetes_sd_configs:
  [ - <kubernetes_sd_config> ... ]

# Lightsail 서비스 디스커버리 설정 목록.
lightsail_sd_configs:
  [ - <lightsail_sd_config> ... ]

# Linode 서비스 디스커버리 설정 목록.
linode_sd_configs:
  [ - <linode_sd_config> ... ]

# Marathon 서비스 디스커버리 설정 목록.
marathon_sd_configs:
  [ - <marathon_sd_config> ... ]

# AirBnB's Nerve 서비스 디스커버리 설정 목록.
nerve_sd_configs:
  [ - <nerve_sd_config> ... ]

# OpenStack 서비스 디스커버리 설정 목록.
openstack_sd_configs:
  [ - <openstack_sd_config> ... ]

# PuppetDB 서비스 디스커버리 설정 목록.
puppetdb_sd_configs:
  [ - <puppetdb_sd_config> ... ]

# Scaleway 서비스 디스커버리 설정 목록.
scaleway_sd_configs:
  [ - <scaleway_sd_config> ... ]

# Zookeeper Serverset 서비스 디스커버리 설정 목록.
serverset_sd_configs:
  [ - <serverset_sd_config> ... ]

# Triton 서비스 디스커버리 설정 목록.
triton_sd_configs:
  [ - <triton_sd_config> ... ]

# Uyuni 서비스 디스커버리 설정 목록.
uyuni_sd_configs:
  [ - <uyuni_sd_config> ... ]

# Alertmanager 목록을 레이블과 함께 정적으로 설정한다.
static_configs:
  [ - <static_config> ... ]

# Alertmanager relabel 설정 목록.
relabel_configs:
  [ - <relabel_config> ... ]
```

### `<remote_write>`

`write_relabel_configs`는 샘플을 원격 엔드포인트로 전송하기 전에 relabeling을 적용해준다. Write relabeling은 외부 레이블을 반영한 이후에 적용된다. 이 기능은 전송할 샘플을 제한하는 식으로 활용할 수 있다.

이 기능을 사용하는 방법을 보여주는 [조그마한 데모](https://github.com/prometheus/prometheus/blob/release-2.32/documentation/examples/remote_storage)를 제공하고 있다.

```yaml
# 샘플을 전송할 엔드포인트 URL.
url: <string>

# remote write 엔드포인트 대한 요청에서 사용할 타임 아웃.
[ remote_timeout: <duration> | default = 30s ]

# remote write 요청을 보낼 때마다 함께 전송할 커스텀 HTTP 헤더.
# 프로메테우스 자체에서 설정하는 헤더는 덮어쓸 수 없다는 점에 주의해라.
headers:
  [ <string>: <string> ... ]

# remote write relabel 설정 목록.
write_relabel_configs:
  [ - <relabel_config> ... ]

# remote write 설정 이름.
# 이름을 지정하려면 모든 remote write 설정에서 고유한 이름으로 설정해야 한다.
# 이름을 지정하면 메트릭과 로그에 자동 생성값 대신 이 이름을 사용하기 때문에 쉽게 remote write 설정을 구별할 수 있다.
[ name: <string> ]

# remote write를 통한 exemplar 전송을 활성화한다.
# exemplar를 스크랩하려면 먼저 exemplar 스토리지 자체부터 활성화해야 한다는 것을 유념해라.
[ send_exemplars: <boolean> | default = false ]

# 설정한 username과 password로
# 모든 remote write 요청에 `Authorization` 헤더를 세팅한다.
# password와 password_file은 함께 사용할 수 없다.
basic_auth:
  [ username: <string> ]
  [ password: <secret> ]
  [ password_file: <string> ]

# `Authorization` 헤더 설정 (Optional).
authorization:
  # 인증 타입을 설정한다.
  [ type: <string> | default: Bearer ]
  # credential을 설정한다.
  # `credentials_file`과는 함께 사용할 수 없다.
  [ credentials: <secret> ]
  # 설정한 파일에서 읽어온 credential을 설정한다.
  # `credentials`와는 함께 사용할 수 없다.
  [ credentials_file: <filename> ]

# AWS의 Signature Verification 4 서명 프로세스를 설정해서 요청을 서명한다 (Optional).
# basic_auth나 authorization, oauth2와는 동시에 사용할 수 없다.
# AWS SDK의 디폴트 credential을 사용하려면 `sigv4: {}`로 설정해라.
sigv4:
  # AWS region.
  # 비어있으면, 디폴트 credential 체인에 있는 region을 사용한다.
  [ region: <string> ]

  # AWS API 키. 비어있으면 환경 변수
  # `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`를 사용한다.
  [ access_key: <string> ]
  [ secret_key: <secret> ]

  # 인증에 사용할 AWS 프로파일 이름.
  [ profile: <string> ]

  # AWS API 키 대신 사용할 수 있는 AWS Role ARN.
  [ role_arn: <string> ]

# OAuth 2.0 설정 (Optional).
# basic_auth나 authorization, sigv4와는 동시에 사용할 수 없다.
oauth2:
  [ <oauth2> ]

# remote write 요청에서 사용할 TLS 설정을 구성한다.
tls_config:
  [ <tls_config> ]

# 프록시 URL (Optional).
[ proxy_url: <string> ]

# HTTP 요청에서 HTTP 3xx 리다이렉트 지시를 따를지 여부를 설정한다.
[ follow_redirects: <bool> | default = true ]

# 리모트 스토리지에 데이터를 저장할 때 사용할 큐를 세팅한다.
queue_config:
  # 샤드당 버퍼링할 샘플 갯수. 이 수를 넘어가면 WAL에서 샘플 읽기를 차단한다.
  # 한 번씩 원격 요청 처리가 느릴 때도 처리량을 유지하려면,
  # 여러 요청을 버퍼링할 수 있도록 각 샤드에 충분한 용량을 두는 게 좋다.
  [ capacity: <int> | default = 2500 ]
  # 최대 샤드 수. 즉 동시에 실행할 양.
  [ max_shards: <int> | default = 200 ]
  # 최소 샤드 수. 즉 동시에 실행할 양.
  [ min_shards: <int> | default = 1 ]
  # 한 번에 전송할 최대 샘플 수.
  [ max_samples_per_send: <int> | default = 500]
  # 샘플이 버퍼에서 최대로 대기할 수 있는 시간.
  [ batch_send_deadline: <duration> | default = 5s ]
  # 초기 재시도 지연 시간. 재시도할 때마다 두 배로 늘어난다.
  [ min_backoff: <duration> | default = 30ms ]
  # 최대 재시도 지연 시간.
  [ max_backoff: <duration> | default = 100ms ]
  # remote-write 스토리지에서 상태 코드 429를 받았을 때 재시도할지 여부.
  # 이 설정은 실험적인 기능으로, 향후 동작이 변경될 수 있다.
  [ retry_on_http_429: <boolean> | default = false ]

# 시계열 메타데이터를 리모트 스토리지로 전송하도록 설정한다.
# 메타데이터 설정은 언제든지 변경될 수 있으며,
# 향후 릴리즈에서 제거될 수도 있다.
metadata_config:
  # 메트릭 메타데이터를 리모트 스토리지로 전송할지 여부.
  [ send: <boolean> | default = true ]
  # 메트릭 메타데이터를 리모트 스토리지로 전송할 간격.
  [ send_interval: <duration> | default = 1m ]
  # 한 번에 전송할 최대 샘플 수.
  [ max_samples_per_send: <int> | default = 500]
```

이 기능을 지원하는 [통합](../integrations#remote-endpoints-and-storage) 목록을 참고해라.

### `<remote_read>`

```yaml
# 질의를 보낼 엔드포인트 URL.
url: <string>

# remote read 설정 이름.
# 이름을 지정하려면 모든 remote read 설정에서 고유한 이름으로 설정해야 한다.
# 이름을 지정하면 메트릭과 로그에 자동 생성값 대신 이 이름을 사용하기 때문에 쉽게 remote read 설정을 구별할 수 있다.
[ name: <string> ]

# selector에 이 equality matcher 목록이 있을 때만
# remote read 엔드포인트에 질의를 보낸다 (optional).
required_matchers:
  [ <labelname>: <labelvalue> ... ]

# remote read 엔드포인트 대한 요청에서 사용할 타임 아웃.
[ remote_timeout: <duration> | default = 1m ]

# remote read 요청을 보낼 때마다 함께 전송할 커스텀 HTTP 헤더.
# 프로메테우스 자체에서 설정하는 헤더는 덮어쓸 수 없다는 점에 주의해라.
headers:
  [ <string>: <string> ... ]

# 로컬 스토리지에 완전한 데이터가 들어있는 시간 범위에서도 read 쿼리를 수행해야 하는지 여부.
[ read_recent: <boolean> | default = false ]

# 설정한 username과 password로
# 모든 remote read 요청에 `Authorization` 헤더를 세팅한다.
# password와 password_file은 함께 사용할 수 없다.
basic_auth:
  [ username: <string> ]
  [ password: <secret> ]
  [ password_file: <string> ]

# `Authorization` 헤더 설정 (Optional).
authorization:
  # 인증 타입을 설정한다.
  [ type: <string> | default: Bearer ]
  # credential을 설정한다.
  # `credentials_file`과는 함께 사용할 수 없다.
  [ credentials: <secret> ]
  # 설정한 파일에서 읽어온 credential을 설정한다.
  # `credentials`와는 함께 사용할 수 없다.
  [ credentials_file: <filename> ]

# OAuth 2.0 설정 (Optional).
# basic_auth나 authorization과는 동시에 사용할 수 없다.
oauth2:
  [ <oauth2> ]

# remote read 요청에서 사용할 TLS 설정을 구성한다.
tls_config:
  [ <tls_config> ]

# 프록시 URL (Optional).
[ proxy_url: <string> ]

# HTTP 요청에서 HTTP 3xx 리다이렉트 지시를 따를지 여부를 설정한다.
[ follow_redirects: <bool> | default = true ]
```

이 기능을 지원하는 [통합](../integrations#remote-endpoints-and-storage) 목록을 참고해라.

### `<exemplars>`

exemplar 스토리지는 아직까진 실험적인 기능으로 여기며, 사용하려면 반드시 `--enable-feature=exemplar-storage`를 통해 활성화해야 한다.

```yaml
# 모든 시계열에 대한 exemplar를 저장하는 데 사용할 원형 버퍼의 최대 사이즈를 설정한다.
# 사이즈는 런타임에 변경할 수 있다.
[ max_exemplars: <int> | default = 100000 ]
```