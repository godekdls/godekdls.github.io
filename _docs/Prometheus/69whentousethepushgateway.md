---
title: When to use the Pushgateway
category: Prometheus
order: 69
permalink: /Prometheus/practices.pushing/
description: Pushgateway를 사용해야 하는 곳과 그렇지 않은 곳
image: ./../../images/prometheus/logo.png
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/practices/pushing/
parent: BEST PRACTICES
parentUrl: /Prometheus/practices/
---

---

Pushgateway는 스크랩이 불가능한 job에 있는 메트릭을 푸시할 수 있게 해주는 중개 서비스다. 자세한 내용은 [메트릭 푸시하기](../pushing)를 참고해라.

### 목차

- [Should I be using the Pushgateway?](#should-i-be-using-the-pushgateway)
- [Alternative strategies](#alternative-strategies)

---

## Should I be using the Pushgateway?

**Pushgateway는 특정한 범위에서만 제한적으로 사용하는 게 좋다.** 일반적인 메트릭을 수집할 때 평소대로 프로메테우스의 pull 모델을 이용하지 않고 무턱대고 Pushgateway부터 사용하면 몇 가지 함정에 빠지게 된다:

- 여러 가지 인스턴스들을 하나의 Pushgateway를 통해 모니터링하게 되면, Pushgateway가 단일 장애점<sup>single point of failure</sup>이 됨과 동시에 병목이 될 가능성이 크다.
- `up` 메트릭(스크랩할 때마다 매번 생성되는)을 통해 프로메테우스가 자동으로 인스턴스 상태<sup>health</sup>를 모니터링해주는 기능을 더 이상 이용할 수 없다.
- Pushgateway는 푸시한 시계열를 절대 지우지 않으며, Pushgateway의 API를 통해 수동으로 시계열을 삭제하기 전까진 영원히 프로메테우스에 노출하게 된다.

마지막 항목은 여러 job 인스턴스들이 `instance` 레이블 등을 통해 Pushgateway에 푸시하는 메트릭을 구별할 때와 특히 관련 있다. 이런 상황에선 인스턴스의 이름이 바뀌거나 제거되더라도 Pushgateway엔 해당 인스턴스의 메트릭이 그대로 남아 있게 된다. Pushgateway는 메트릭 캐시로서, 수명 주기가 메트릭을 푸시하는 프로세스들의 수명 주기와는 근본적으로 다르기 때문이다. 프로메테우스의 일반적인 pull 스타일 모니터링과 대비되는 특징이다. 프로메테우스에선 인스턴스가 사라지면 (의도했든 안했든) 관련 메트릭도 자동으로 함께 사라진다. Pushgateway를 사용할 때는 자동으로 사라지지 않으며, 오래된<sup>stale</sup> 메트릭을 수동으로 삭제하거나 직접 수명 주기 동기화를 자동화해야 한다.

**일반적으로 Pushgateway를 사용하는 게 적합한 유일한 유스 케이스는 서비스 수준의 배치 job 결과를 정확하게 가져오는 거다**. "서비스 수준" 배치 job이 의미하는 바는 특정 시스템이나 job 인스턴스와는 관계가 없다는 뜻이다 (ex. 서비스 전체에서 여러 사용자들을 삭제하는 배치 job). 이런 job의 메트릭에는 특정 시스템이나 인스턴스의 수명 주기에 따라 나뉘는 시스템, 인스턴스 레이블을 포함해선 안 된다. 이렇게 하면 Pushgateway에서 정체된<sup>stale</sup> 메트릭을 관리해야 하는 부담을 줄일 수 있다. [배치 job 작업 모니터링을 위한 베스트 프랙티스](../practices.instrumentation/#batch-jobs)도 함께 읽어봐라.

---

## Alternative strategies

인바운드 방화벽이나 NAT때문에 타겟에서 메트릭을 가져올 수 없다면, 프로메테우스 서버도 네트워크 장벽 뒤로 이동하는 게 좋다. 일반적으로 권장하는 것도 모니터링하는 인스턴스와 동일한 네트워크에서 프로메테우스 서버를 실행하는 거다. 아니면 프로메테우스가 방화벽이나 NAT 뒤에 있는 지표를 스크랩할 수 있도록 도와주는 [PushProx](https://github.com/RobustPerception/PushProx)를 검토해봐라.

시스템과 관련있는 배치 job들은 (자동 보안 업데이트 cronjob이나 설정 관리 클라이언트를 실행하는 등) Pushgateway 대신 [노드 익스포터](https://github.com/prometheus/node_exporter)의 [textfile collector](https://github.com/prometheus/node_exporter#textfile-collector)를 이용해 만들어지는 메트릭들을 노출해라.

