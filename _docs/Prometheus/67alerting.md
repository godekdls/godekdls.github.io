---
title: Alerting
category: Prometheus
order: 67
permalink: /Prometheus/practices.alerting/
description: 알림을 만드는 기준에 대한 가이드라인
image: ./../../images/prometheus/logo.png
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/practices/alerting/
parent: BEST PRACTICES
parentUrl: /Prometheus/practices/
---

---

Rob Ewaschuk이 구글에서 경험한 것들을 바탕으로 작성한 [알림에 과한 나의 철학](https://docs.google.com/a/boxever.com/document/d/199PqyG3UsyXlwieHaqbGiWVa8eMWi8zzAn0YfcApr8Q/edit)을 읽어보기를 권장한다.

요약하자면: 알림은 단순하게 유지하고, 원인보단 증상을 경고해야 하며, 콘솔에선 원인을 정확히 파악할 수 있어야 하고, 할 수 있는게 아무것도 없는 알림은 만들지마라.

### 목차

- [What to alert on](#what-to-alert-on)
  + [Online serving systems](#online-serving-systems)
  + [Offline processing](#offline-processing)
  + [Batch jobs](#batch-jobs)
  + [Capacity](#capacity)
  + [Metamonitoring](#metamonitoring)
    
---

## What to alert on

사용자를 괴롭힐 수 있는 가능한 모든 경로를 잡아내려고 하지 말고, 엔드 유저가 겪을 수 있는 증상들에 대해 알림을 만들어서, alert는 가능한 한 적게 만드는 것을 목표로 해라. 알림에선 관련 콘솔들에 연결시켜줘야 하며, 어떤 구성 요소에 결함이 있는지 쉽게 파악할 수 있어야 한다.

일시적으로 발생하는 사소한 문제들은 넘어갈 수 있으려면 알림을 지나치게 깐깐하게 잡지 않는 게 좋다.

### Online serving systems

전형적으로 알림이 필요한 곳은 스택 곳곳에서 지연 시간이 늘어나고 에러 발생률이 높아질 때다.

지연 시간 알림은 같은 스택에선 한 지점에서만 알림을 전송해라. 하위 구성 요소에선 예상보단 느리더라도 전반적인 사용자 대기 시간이 괜찮은 수준이라면 굳이 알림을 전송할 필요는 없다.

에러 발생률은 사용자에게 드러나는 에러를 기준으로 알림을 전송해라. 이런 문제를 일으킬 수 있는 에러가 스택 아래쪽에 더 분포돼있더라도 별도로 나눠서 알림을 보낼 필요는 없다. 하지만 사용자에게 드러나진 않지만, 다른 면에서 사람의 개입이 필요할 정도로 심각한 문제라면 (ex. 금전적인 면에서 손해가 큰 경우) 이런 에러들에 대비하는 알림도 추가해라.

요청 타입마다 특성이 다르거나, 트래픽이 적은 요청 타입에 문제가 있어도 트래픽이 높은 요청 때문에 가려질 수 있는 상황이라면, 알림을 요청 타입별로 나눠서 만들어야 수도 있다.

### Offline processing

오프라인 처리 시스템에선 데이터를 다 처리하는데 걸리는 시간이 핵심 메트릭이므로, 이 지표가 사용자에게 영향을 줄 정도로 커진다면 알림을 전송해라.

### Batch jobs

배치 job에선 job이 계속 멈춰있으면 사용자에게 문제가 드러날 수도 있기 때문에 최근에 성공한 배치 job 내역이 없으면 알림을 전송하는 것이 타당하다.

여기서 최근이라 함은 보통, 배치 job을 처음부터 끝까지 최소 2회는 실행할 수 있는 시간이어야 한다. 예를 들어 1시간이 소요되는 job을 4시간 간격으로 실행한다면, 10시간 정도를 적정한 임계치로 정할 수 있다. 실행에 한 번 실패해도 그냥 넘어가선 안 된다면, 매번 사람이 개입할 필요가 없게 job을 더 자주 실행해라.

### Capacity

수용할 수 있는 용량의 한계치에 가까워지고 있을 때는, 곧바로 사용자에게 영향을 주는 문제는 아니더라도, 서비스가 중단되는 것을 막으려면 머지않아 사람의 개입이 필요한 경우가 많다.

### Metamonitoring

모니터링이 제대로 동작하고 있다는 확신을 갖는 것 또한 중요하다. 따라서 프로메테우스 서버, Alertmanager, PushGateway, 기타 모니터링 인프라들이 잘 떠있는지와 정상적으로 실행되고 있는지를 확인할 수 있는 알림을 만들어라.

항상 그렇듯이 원인보다는 증상을 경고할 수 있다면 노이즈를 최소화할 수 있을 거다. 예를 들어 각 시스템별로 알림을 만드는 것보단, [블랙박스 검사](https://ko.wikipedia.org/wiki/%EB%B8%94%EB%9E%99%EB%B0%95%EC%8A%A4_%EA%B2%80%EC%82%AC)를 통해 PushGateway에서 프로메테우스, Alertmanager, 이메일까지 알림이 잘 전송되는지 검증해보는 게 더 좋다.

프로메테우스의 화이트박스 모니터링을 외부 블랙박스 모니터링으로 보완해준다면, 보이지 않던 문제들을 포착할 수도 있으며, 내부 시스템들이 전부 다운되는 경우를 대비<sup>fallback</sup>할 수도 있다.