---
title: Design Documents
category: Prometheus
order: 8
permalink: /Prometheus/design-doc/
description: 프로메테우스 설계 문서 목록
image: ./../../images/prometheus/logo.png
lastmod: 2022-01-05T21:30:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/introduction/design-doc/
parent: INTRODUCTION
parentUrl: /Prometheus/introduction/
---

---

개인이나 그룹이 큰 변화나 작은 기능을 추가해 프로메테우스 생태계에 기여할 땐 설계 문서를 작성한다. 커뮤니티에 검토나 승인을 요청할 땐 이 문서를 통해 제안한다.

이 페이지엔 현재 알고 있는 설계 문서들의 목록을 정리해뒀다. 설계 문서를 새로 만들거나 리스트에 없는 문서가 있다면 [풀 리퀘스트](https://github.com/prometheus/docs/)를 열어 목록에 추가해주면 좋겠다.

설계 문서가 구현된 내용을 항상 정확하게 반영하고 있지는 않으며, 세부 구현 내용은 기능을 머지한 이후에 달라질 수도 있다. 설계 문서를 문서화로 간주하진 않으며 표준을 정해놓는 것도 불가능하다.

`TODO` 상태에 있는 설계 문서를 작성하고 싶거나, 제안돼 있는 설계 문서 중 하나를 구현하고 싶다면, 먼저 [개발자 메일링 리스트](https://prometheus.io/community)에 연락해서 이미 다른 사람이 해당 태스크를 작업 중이진 않은지, 설계 문서가 승인돼서 현재에도 유의미한 문서인지 확인해보는 게 좋다.

| Document                                                     | Initial date | Status                | Pull requests                                                |
| :----------------------------------------------------------- | :----------- | :-------------------- | :----------------------------------------------------------- |
| [Secure Alertmanager cluster traffic](https://github.com/prometheus/alertmanager/blob/master/doc/design/secure-cluster-traffic.md) | 2019‑02‑21   | Approved              | [alertmanager#2237](https://github.com/prometheus/alertmanager/pull/2237) |
| TSDB Head Improvements ([part1](https://docs.google.com/document/d/184urkLQnM7rqLmGvS66I15jU2pyPk_qwd8v_qDlXczo/edit) - [part 2](https://docs.google.com/document/d/1pnEsxB0CDLOxQipGw_vhkJpoDZfZPs_KjqCriumDAXQ/edit)) | 2019‑12‑09   | Partially implemented |                                                              |
| [Persist Retroactive Rules](https://docs.google.com/document/d/16s_-RxYwQYcb4G4mvpmjPolEbD24o54a1LPqJ538Vhc/edit) | 2020‑06‑12   | Partially implemented | [#7675](https://github.com/prometheus/prometheus/pull/7675)  |
| [topk/bottomk aggregation over time](https://docs.google.com/document/d/1uSbD3T2beM-iX4-Hp7V074bzBRiRNlqUdcWP6JTDQSs/edit) | 2020‑09‑30   | Implemented           | [#8121](https://github.com/prometheus/prometheus/pull/8121) [#8425](https://github.com/prometheus/prometheus/pull/8425) |
| [http_sd_configs](https://docs.google.com/document/d/1tVeuzjpU4-TiYPNWJXKmcyIuZF6A2tUq270RbBT5zho/edit) | 2021‑02‑26   | Under review          | [#8839](https://github.com/prometheus/prometheus/pull/8839)  |
| [prometheus/client_java & micrometer](https://docs.google.com/document/d/1vROky2aIw3kAllfi95gwDJy5P2DyWnCihsjPXGpLwwo/edit) | 2021‑02‑26   | Under review          |                                                              |
| [First-class network monitoring support in the Prometheus & Grafana ecosystem](https://docs.google.com/document/d/1oEpjiWfTHF352NCAOGolwij3EIkrprCkdQmaQMpjg4M/edit) | 2021‑02‑25   | Under review          |                                                              |
| [Configuration handling in exporters and Prometheus 3.x](https://docs.google.com/document/d/1BK_Gc3ixoWyxr9F5qGC07HEcfDPtb6z96mfqoGyz52Y/edit) | 2021‑03‑29   | Under review          |                                                              |
| [Prometheus Agent](https://docs.google.com/document/d/1cCcoFgjDFwU2n823tKuMvrIhzHty4UDyn0IcfUHiyyI/edit) | 2021‑01‑27   | Approved              | [#8785](https://github.com/prometheus/prometheus/pull/8785)  |
| [Sparse high-resolution histograms](https://docs.google.com/document/d/1cLNv3aufPZb3fNfaJgdaRBZsInZKKIHo9E6HinJVbpM/edit) | 2021‑02‑10   | Approved              |                                                              |
| [Prometheus timezones support](https://docs.google.com/document/d/1xfw1Lb1GIRZB_-4iFVGkgwnpwuBemWfxYqFdBm7APsE/edit) | 2021‑05‑29   | Proposed              |                                                              |
| [Moving to goreleaser](https://docs.google.com/document/d/16LOT2wK-jntlU-EFADfaEF3YbKH81U9Zl_PvSu4qVwo/edit) | 2021‑06‑05   | Proposed              |                                                              |
| [Alertmanager Log Receiver](https://docs.google.com/document/d/1Oevu2stHVGAupzmc9C7_wW5nTb_CJ6Ut72viXfve6zI/edit) | 2021‑06‑10   | Proposed              |                                                              |
| [Extra HTTP parameters in the blackbox exporter](https://docs.google.com/document/d/1VwqXi2TOb5KXaZY6Iio7411x64pJao3GusX8MqYsJ2g/edit) | 2021‑06‑23   | Proposed              |                                                              |
| [Making durations and number literals the same](https://docs.google.com/document/d/1LaZfknXuuRWGtQSbULoMtclQhuLUMrdwg15wMvoBvCQ/edit) | 2021‑07‑26   | In progress           | [#9138](https://github.com/prometheus/prometheus/pull/9138)  |
| [Metadata](https://docs.google.com/document/d/1XiZePSjwU4X5iaIgCIvLzljJzl8lRAdvputuborUcaQ/edit) |              | TODO                  |                                                              |
| OpenMetrics transition                                       |              | TODO                  |                                                              |
| Semantics of muting in Alertmanager                          |              | TODO                  |                                                              |
| [Extrapolation in range selectors (xrate)](https://docs.google.com/document/d/1y2Mp041_2v0blnKnZk7keCnJZICeK2YWUQuXH_m4DVc/edit#) |              | Under review          |                                                              |
| Serverless, MQTT, and IoT use cases in the Prometheus ecosystem |              | TODO                  |                                                              |
| Static arithmetic for timestamps and durations               |              | TODO                  |                                                              |

---

# PROBLEM STATEMENTS AND EXPLORATORY DOCUMENTS

가끔은 훨씬 더 나중을 생각해보기도 한다. 여기 있는 문서들은 대체로 탐구에 가까운 문서다. 이 문서들은 실체가 있거나 무언가 정해졌다기 보단, 다 함께 생각했던 내용을 공유하는 문서로 받아들여야 한다.

| Document                                                     | Initial date |
| :----------------------------------------------------------- | :----------- |
| [Prometheus is not feature complete](https://docs.google.com/document/d/1lEP7pGYM2-5GT9fAIDqrOecG86VRU8-1qAV8b6xZ29Q) | 2020-05      |
| [Thoughts about timestamps and durations in PromQL](#)       | 2020-10      |
| [Prometheus, OpenMetrics & OTLP](https://docs.google.com/document/d/1hn-u6WKLHxIsqYT1_u6eh94lyQeXrFaAouMshJcQFXs) | 2021-03      |
| [Prometheus Sparse Histograms and PromQL](https://docs.google.com/document/d/1ch6ru8GKg03N02jRjYriurt-CZqUVY09evPg6yKTA1s/edit) | 2021-10      |