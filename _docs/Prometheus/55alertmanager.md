---
title: Alertmanager
category: Prometheus
order: 55
permalink: /Prometheus/alertmanager/
description: Alertmanager의 핵심 기능들
image: ./../../images/prometheus/logo.png
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/alerting/0.23/alertmanager/
parent: ALERTING
parentUrl: /Prometheus/alerting/
---

---

[Alertmanager](https://github.com/prometheus/alertmanager)는 프로메테우스 서버같은 클라이언트 애플리케이션에서 전송한 alert들을 처리한다. 중복을 제거하고, 그룹으로 묶고, 이메일이나 PagerDuty, OpsGenie 등의 적당한 receiver 통합 포인트로 alert를 라우팅하는 일을 담당한다. alert의 silencing과 inhibition도 alertmanager에서 처리한다.

이어서 Alertmanager가 구현하는 핵심 개념들을 설명한다. 자세한 사용법을 알아보려면 [설정 문서](../alerting.configuration)를 읽어봐라.

### 목차

- [Grouping](#grouping)
- [Inhibition](#inhibition)
- [Silences](#silences)
- [Client behavior](#client-behavior)
- [High Availability](#high-availability)

---

## Grouping

Grouping에선 유사한 성격의 alert들을 하나의 notification으로 분류한다. 이 기능은 많은 시스템이 동시에 실패해서 alert가 수백에서 수천 개까지 동시다발적으로 실행될 수도 있는 대규모 정전 상태일 때 특히 유용하다.

**예시:** 어떤 클러스터에서 서비스를 수십, 수백 개를 실행하고 있는데 네트워크 파티션이 발생했다고 해보자. 서비스 인스턴스의 절반은 더 이상 데이터베이스에 접근할 수 없다. 프로메테우스의 alerting rule은 각 서비스 인스턴스가 데이터베이스와 통신할 수 없으면 alert를 전송하도록 설정돼있다. 결과적으로 수백 개의 alert가 Alertmanager로 전송된다.

사용자들은 단일 페이지 내에서 영향을 받은 서비스 인스턴스들을 정확하게 파악할 수 있길 바랄 거다. 이럴 땐 클러스터와 alertname으로 alert들을 묶어 하나의 notification으로 압축해서 전송하도록 Alertmanager를 설정해주면 된다.

alert들을 그룹으로 묶을 기준이나, alert 그룹을 통보<sup>notification</sup>할 타이밍, 통보<sup>notification</sup>를 보낼 receiver는 설정 파일의 라우팅 트리로 구성한다.

---

## Inhibition

Inhibition은 특정한 alert가 이미 시행<sup>firing</sup> 중이라면 특정 alert에 대한 통보<sup>notification</sup>를 억제한다는 개념이다.

**예시:** 클러스터에 통째로 연결할 수 없음을 알리는 alert가 시행<sup>fire</sup> 중이다. Alertmanager는 특정 alert가 시행<sup>fire</sup> 중일 땐 이 클러스터와 관련된 다른 alert는 모두 뮤트<sup>mute</sup>시키도록 설정할 수 있다. 이렇게 하면 실제 문제와는 관련 없는 수백, 수천 개의 alert가 시행<sup>fire</sup>되는 것을 방지할 수 있다.

Inhibition은 Alertmanager의 설정 파일을 통해 구성한다.

---

## Silences

Silence는 말그대로 주어진 시간 동안 alert들을 단순히 뮤트<sup>mute</sup>시킨다. Silence는 라우팅 트리를 매칭하는 방법 그대로 matcher를 통해 설정한다. alert를 전달받으면 활성 silence와 동일한지<sup>equality</sup>, 또는 정규 표현식 matcher와 매칭되는지를 확인해본다. 매칭된다면 해당 alert에 대한 통보<sup>notification</sup>는 전송하지 않는다.

Silence는 Alertmanager의 웹 인터페이스에서 설정한다.

---

## Client behavior

Alertmanager는 클라이언트의 동작에 관해 [특별한 요구 사항](../alerting.clients)을 가지고 있다. 프로메테우스로 alert를 전송하지 않고 직접 전송하는 케이스에서만 확인해보면 된다.

---

## High Availability

Alertmanager는 고가용성을 위한 클러스터를 구성할 수 있는 설정을 지원한다. [\-\-cluster-*](https://github.com/prometheus/alertmanager#high-availability) 플래그를 사용해 설정해주면 된다.

이때 중요한 점은, 프로메테우스와 Alertmanager들 사이 트래픽을 로드 밸런싱하지 않는 거다. 그대신 프로메테우스는 모든 Alertmanager 목록을 가리켜야 한다.