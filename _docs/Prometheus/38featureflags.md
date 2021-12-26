---
title: Feature flags
category: Prometheus
order: 38
permalink: /Prometheus/feature-flags/
description: 실험적인 기능을 활성화해주는 feature 플래그들
image: ./../../images/prometheus/logo.png
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/prometheus/2.32/feature_flags
parent: PROMETHEUS
parentUrl: /Prometheus/prometheus/
---

---

여기서는 구버전과 호환이 안 되는 변경 사항이거나 실험적인 기능으로 여겨져서 기본적으론 비활성화되는 기능들을 설명한다. 이 기능들의 동작은 향후 릴리즈에서 변경될 수 있으며, [release changelog](https://github.com/prometheus/prometheus/blob/main/CHANGELOG.md)를 통해 알릴 예정이다.

이 기능들은 `--enable-feature` 플래그를 사용해 콤마로 구분해서 나열해주면 활성화할 수 있다. 향후 버전에선 기본적으로 활성화될 수도 있다.

### 목차

- [@ Modifier in PromQL](#-modifier-in-promql)
- [Expand environment variables in external labels](#expand-environment-variables-in-external-labels)
- [Negative offset in PromQL](#negative-offset-in-promql)
- [Remote Write Receiver](#remote-write-receiver)
- [Exemplars storage](#exemplars-storage)
- [Memory snapshot on shutdown](#memory-snapshot-on-shutdown)
- [Extra scrape metrics](#extra-scrape-metrics)
- [New service discovery manager](#new-service-discovery-manager)
- [Prometheus agent](#prometheus-agent)

---

## `@` Modifier in PromQL

```sh
--enable-feature=promql-at-modifier
```

`@` modifier를 사용하면 instant 벡터 셀럭터, range 벡터 셀럭터, 서브 쿼리를 평가할 시간을 지정할 수 있다. 자세한 내용은 [여기](../querying.basics#-modifier)에서 확인할 수 있다.

---

## Expand environment variables in external labels

```sh
--enable-feature=expand-external-labels
```

[`external_labels`](../configuration#configuration-file)에 설정한 값에 있는 `${var}`, `$var`를 현재 환경 변수에 따라 치환한다. 정의되지 않은 변수를 참조하면 빈 문자열로 바뀐다.

---

## Negative offset in PromQL

음수 오프셋은 PromQL이 시간을 미리 내다보고 샘플을 평가하지 않는다는 불변성에 위배되기 때문에 기본적으론 비활성화돼 있다.

```sh
--enable-feature=promql-negative-offset
```

양수 오프셋 modifier과는 달리 음수 오프셋 modifier는 벡터 셀럭터를 미래로 이동시킬 수 있다. 지난 데이터를 검토해서 좀더 최근 데이터와 어떻게 다른지 비교할 때 등에 음수 오프셋이 필요할 거다.

자세한 내용은 [여기](../querying.basics/#offset-modifier)에서 확인할 수 있다.

---

## Remote Write Receiver

```sh
--enable-feature=remote-write-receiver
```

remote write receiver를 사용하면 프로메테우스로 다른 프로메테우스 서버의 remote write 요청을 수락할 수 있다. 자세한 내용은 [여기](../storage/#overview)에서 확인할 수 있다.

---

## Exemplars storage

```sh
--enable-feature=exemplar-storage
```

[OpenMetrics](https://github.com/OpenObservability/OpenMetrics/blob/main/specification/OpenMetrics.md#exemplars)에선 스크랩 타겟이 특정 메트릭에 exemplar를 추가할 수 있는 기능을 소개하고 있다. exemplar는 MetricSet 외부에 있는 데이터에 대한 참조다. 흔하게는 프로그램 트래이스 ID에 사용한다.

Exemplar 스토리지는 사이즈를 고정해둔 원형 버퍼로 구현하며, 모든 시계열의 exemplar를 메모리에 저장한다. 이 기능을 활성화하면 프로메테우스가 스크랩한 exemplar의 스토리지도 활성화한다. exemplar 갯수에 따라 원형 버퍼의 사이즈를 조절하고 싶을 때는 설정 파일 블록 [storage](../configuration/#configuration-file)/[exemplars](../configuration/#exemplars)를 사용하면 된다. `traceID=<jaeger-trace-id>`만 있는 exemplar는 인메모리 exemplar 스토리지를 통해 메모리를 대략 100바이트 정도 사용한다. exemplar 스토리지가 활성화되면 로컬의 지속성<sup>persistence</sup>을 위해 WAL에도 exemplar를 추가한다 (WAL 기간 동안).

---

## Memory snapshot on shutdown

```sh
--enable-feature=memory-snapshot-on-shutdown
```

서버가 종료될 때 시계열 정보와 함께 메모리에 있는 청크들의 스냅샷을 남기고 디스크에 저장한다. WAL 리플레이 없이 이 스냅샷을 이용해 m-map으로 메모리에 청크를 복원할 수 있으므로 기동 시간이 빨라진다.

---

## Extra scrape metrics

```sh
--enable-feature=extra-scrape-metrics
```

활성화하면 프로메테우스는 인스턴스를 스크랩할 때마다 다음과 같은 추가 시계열에 샘플을 저장한다:

- `scrape_timeout_seconds`: 타겟에 설정한 `scrape_timeout`. `scrape_duration_seconds / scrape_timeout_seconds`를 계산해보면 각 타겟들이 타임 아웃에 얼마나 근접해있는지 측정해볼 수 있다.
- `scrape_sample_limit`: 타겟에 설정한 `sample_limit`. `scrape_samples_post_metric_relabeling / scrape_sample_limit`을 계산해보면 각 타겟들이 한계치에 얼마나 근접해있는지 알아낼 수 있다. 따로 제한치를 설정하지 않았다면 `scrape_sample_limit`은 0이 될 수도 있다. 즉, 위 쿼리는 샘플 수에 제한이 없는 타겟에선 `+Inf`를 반환할 수 있다 (0으로 나누기 때문에). 샘플 제한이 있는 타겟에서만 질의하고 싶다면 `scrape_samples_post_metric_relabeling / (scrape_sample_limit > 0)` 쿼리를 사용해라.
- `scrape_body_size_bytes`: 스크랩에 성공한 경우 가장 최근 스크랩 응답의 압축하지 않은 사이즈. `body_size_limit`을 초과해서 스크랩에 실패했다면 `-1`을, 그외 다른 이유로 스크랩에 실패했을 땐 `0`으로 보고한다.

---

## New service discovery manager

```sh
--enable-feature=new-service-discovery-manager
```

활성화하면 프로메테우스는 새로운 서비스 디스커버리 매니저를 사용해서, 설정을 다시 로드할 때 변경되지 않은 디스커버리는 재시작하지 않는다. 따라서 리로드 동작이 좀더 빨라지며, 서비스 디스커버리 소스에 대한 부담이 줄어든다.

이 새 서비스 디스커버리 매니저를 테스트한다면, 발견한 이슈들은 업스트림으로 리포트해주면 좋겠다.

향후 릴리즈에선 이 새 서비스 디스커버리 매니저를 디폴트로 변경하고, 이 피처 플래그는 무시될 예정이다.

---

## Prometheus agent

```sh
--enable-feature=agent
```

활성화하면 프로메테우스는 에이전트 모드로 실행된다. 에이전트 모드에선 디스커버리, 스크랩, remote write로만 제한된다.

에이전트 모드는 프로메테우스 데이터를 로컬에서 질의할 필요 없이, 중앙에 있는 [remote 엔드포인트](https://prometheus.io/docs/operating/integrations/#remote-endpoints-and-storage)에서만 질의하면 될 때 활용할 수 있다.