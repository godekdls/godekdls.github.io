---
title: Expression browser
category: Prometheus
order: 40
permalink: /Prometheus/expression-browser/
description: 프로메테우스 expression 브라우저 소개
image: ./../../images/prometheus/logo.png
lastmod: 2021-05-16T17:00:00+09:00
comments: 프로메테우스의 expression 브라우저 소개
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/visualization/browser/
parent: VISUALIZATION
parentUrl: /Prometheus/visualization/
---

---

프로메테우스 서버의 `/graph` 경로에서 이용할 수 있는 expression 브라우저에선, 입력한 모든 표현식의 결과를 테이블이나 시간에 따른 그래프로 확인해볼 수 있다.

expression 브라우저는 주로 애드혹 쿼리나 디버깅에 활용한다. 그래프를 그려보고 싶다면 [그라파나](../grafana) 또는 [콘솔 템플릿](../console-templates)을 사용해라.