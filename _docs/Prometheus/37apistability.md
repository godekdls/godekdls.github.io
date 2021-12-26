---
title: API Stability Guarantees
navTitle: API Stability
category: Prometheus
order: 37
permalink: /Prometheus/stability/
description: 프로메테우스 2.x에서 안정성을 보장하는 api들
image: ./../../images/prometheus/logo.png
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/prometheus/2.32/stability
parent: PROMETHEUS
parentUrl: /Prometheus/prometheus/
---

---

프로메테우스는 같은 메이저 버전에선 API 안정성을 약속하고 있으며, 주요 기능에서 호환에 문제가 되는 변경 사항은 피하기 위해 다분히 애쓰고 있다. 겉치레만 있거나, 아직 개발 중이거나, 써드 파티 서비스에 의존하는 일부 기능들은 여기에 포함되지 않는다.

2.x에서 stable하다고 여기는 것들:

- 쿼리 언어와 데이터 모델
- alerting/recording rule
- ingestion exposition 포맷
- v1 HTTP API (대시보드와 UI에서 사용하는 API)
- 설정 파일 형식 (서비스 디스커버리와 remote read/write는 빼고. 아래 참고)
- rule/alert 파일 형식
- 콘솔 템플릿 구문과 시맨틱스

2.x에서 stable하지 않다고 여기는 것들:

- 다음을 포함해서 실험적이거나 언제든지 변경될 수 있는 기능들:
  - [PromQL `holt_winters` 함수](https://github.com/prometheus/prometheus/issues/2458)
  - Remote read, remote write, remote read 엔드포인트
- 서버 사이드 HTTPS와 기본 인증
- `static_configs`, `file_sd_configs`를 제외한 서비스 디스커버리 통합
- 서버와 같이 들어있는 Go API 패키지들
- 웹 UI에서 생성한 HTML
- 프로메테우스 자체의 /metrics 엔드포인트에 있는 메트릭
- 정확한 디스크 저장 포맷. 물론 앞으로 있을 변경 사항들은 호환이 가능할 것이며, 프로메테우스에서 투명하게 처리해줄 거다.
- 로그 포맷

experimental/unstable로 표시되어있는 기능을 사용하지만 않는다면, 같은 메이저 버전 안에선 보통 운영적인 조치 없이 업그레이드를 진행할 수 있으며 어떤 것이든 손상될 위험은 극히 적다. 바로 호환되지 않은 변경 사항들은 모두 릴리즈 노트에서 `CHANGE`로 표시해줄 거다.