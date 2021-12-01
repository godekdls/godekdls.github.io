---
title: Labeling Applications
category: Spring Cloud Data Flow
order: 66
permalink: /Spring%20Cloud%20Data%20Flow/feature-guides.stream.labels/
description: 이름이 같은 애플리케이션을 구분하기 위한 레이블 활용법
image: ./../../images/springclouddataflow/stream-labels.webp
lastmod: 2021-12-02T00:33:00+09:00
comments: true
originalRefName: 스프링 클라우드 데이터 플로우
originalRefLink: https://dataflow.spring.io/docs/feature-guides/streams/labels/
parent: Feature guides
parentUrl: /Spring%20Cloud%20Data%20Flow/feature-guides/
subparent: Stream Feature Guides
subparentNavTitle: Streams
subparentUrl: /Spring%20Cloud%20Data%20Flow/feature-guides.stream/
---

---

Stream DSL이나 Batch DSL에선 애플리케이션을 참조하는 대안으로 레이블을 활용할 수 있다. 애플리케이션 이름 앞에 레이블을 추가하면 된다. 레이블은 전체 정의 내에서 고유해야 하며, 뒤에 콜론 `:`을 붙어야 한다.

예를 들어 스트림을 구성하는 앱들 중에 같은 이름을 가진 앱이 있다면, 이 앱들을 고유하게 식별할 수 있도록 레이블로 단서를 줘야 한다.

```bash
stream create --definition "http | firstLabel: transform --expression=payload.toUpperCase() | secondLabel: transform --expression=payload+'!' | log" --name myStreamWithLabels --deploy
```

이 스트림 정의를 그래프로 시각화하면 다음과 같다:

![Stream Labels](./../../images/springclouddataflow/stream-labels.webp)

아니면 레이블을 이용해서 스트림과 배치 job을 좀더 알기 쉽게 시각화할 수도 있다. 샘플 [파이썬 애플리케이션](https://dataflow.spring.io/docs/recipes/polyglot/app/)에 있는 예시를 보면 어떤 스타일로 사용하는 건지 감이 올 거다.