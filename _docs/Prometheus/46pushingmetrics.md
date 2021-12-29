---
title: Pushing metrics
category: Prometheus
order: 46
permalink: /Prometheus/pushing/
description: 각 언어별 Pushgateway 활용 방법 가이드
image: ./../../images/prometheus/logo.png
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/instrumenting/pushing/
parent: INSTRUMENTING
parentUrl: /Prometheus/instrumenting/
---

---

가끔은 스크랩이 불가능한 컴포넌트들을 모니터링해야 할 때가 있다. [프로메테우스 Pushgateway](https://github.com/prometheus/pushgateway)를 사용하면 [서비스 레벨에 있는 short-lived job](../practices.pushing)에서 프로메테우스가 스크랩할 수 있는 중간 job으로 시계열을 푸시할 수 있다. 프로메테우스의 간단한 텍스트 기반 exposition 형식과 결합하면, 클라이언트 라이브러리 없이 쉘 스크립트도 간단하게 계측<sup>instrument</sup>해낼 수 있다.

- Pushgateway 사용법과 Unix 쉘에서 이용하는 자세한 방법은 프로젝트의 [README.md](https://github.com/prometheus/pushgateway/blob/master/README.md)를 참고해라.
- 자바에서 이용할 때는 [PushGateway](https://prometheus.github.io/client_java/io/prometheus/client/exporter/PushGateway.html) 클래스를 참고해라.
- Go에서 이용할 때는 [Push](https://godoc.org/github.com/prometheus/client_golang/prometheus/push#Pusher.Push)와 [Add](https://godoc.org/github.com/prometheus/client_golang/prometheus/push#Pusher.Add) 메소드를 참고해라.
- 파이썬에서 이용할 때는 [Pushgateway로 익스포트하기](https://github.com/prometheus/client_python#exporting-to-a-pushgateway)를 참고해라.
- Ruby에서 이용할 때는 [이 Pushgateway 문서](https://github.com/prometheus/client_ruby#pushgateway)를 참고해라.
- [프로메테우스 프로젝트 외부에서 관리하는 클라이언트 라이브러리들](../clientlibs)이 Pushgateway를 어떻게 지원하는지 알아보려면 각각의 문서를 참고해라.