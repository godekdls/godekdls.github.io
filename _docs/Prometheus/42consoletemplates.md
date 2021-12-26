---
title: Console templates
category: Prometheus
order: 42
permalink: /Prometheus/console-templates/
description: 프로메테우스 콘솔 템플릿 가이드
image: ./../../images/prometheus/logo.png
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/visualization/consoles/
parent: VISUALIZATION
parentUrl: /Prometheus/visualization/
---

---

콘솔 템플릿을 사용하면 [Go 템플릿 언어](https://golang.org/pkg/text/template/)를 통해 원하는대로 콘솔 페이지를 생성할 수 있다. 콘솔 템플릿은 프로메테우스 서버에서 서빙해준다.

소스 제어를 통해 템플릿을 쉽게 관리하려면 콘솔 템플릿을 이용하는 게 가장 효과적이다. 하지만 학습 곡선이 있기 때문에, 이런 스타일의 모니터링을 처음 접하는 사용자는 [그라파나](../grafana)를 먼저 사용해보는 게 좋다.

### 목차

- [Getting started](#getting-started)
- [Example Console](#example-console)
- [Graph Library](#graph-library)

---

## Getting started

프로메테우스는 사용자를 위한 콘솔 예제들을 제공하고 있다. 이 예제들은 프로메테우스를 실행하고 `/consoles/index.html.example`에 접근해보면 확인할 수 있다. 프로메테우스가 `job="node"` 레이블을 사용하는 노드 익스포터를 스크랩하고 있다면 이 화면에 노드 익스포터 콘솔이 보일 거다.

이 예제는 다섯 가지 레이아웃으로 화면을 구성하고 있다:

1. 상단의 네비게이션 바
2. 좌측의 메뉴
3. 하단의 시간 제어 인터페이스
4. 가운데에 있는 메인 컨텐츠 (보통 그래프들)
5. 우측의 테이블

네비게이션 바는 다른 Prometheis<sup>[1](../faq/#prometheus의-복수형은-뭔가요)</sup>나, 문서, 그외 필요한 시스템에 대한 링크를 가지고 있다. 좌측 메뉴는 해당 프로메테우스 서버 내부를 탐색하기 위한 것으로, 정보들의 상관 관계를 찾을 때 다른 탭으로 콘솔을 하나 더 열어놓고 바로바로 비교해볼 수 있어서 매우 유용하다. 두 레이아웃 모두 `console_libraries/menu.lib`에서 설정하고 있다.

시간 제어 인터페이스를 사용하면 그래프의 지속 시간과 범위를 변경할 수 있다. 콘솔 퍼머링크를 공유하면 다른 사용자에게도 같은 그래프를 보여줄 수 있다.

메인 컨텐츠엔 주로 그래프를 표기한다. 프로메테우스로 데이터를 요청하고 [Rickshaw](https://shutterstock.github.io/rickshaw/)를 통해 데이터를 렌더링할 수 있는 자바스크립트 그래프 라이브러리를 제공하고 있다. 그래프 라이브러리에선 원하는 설정을 지정할 수 있다.

마지막으로, 우측에 있는 테이블은 그래프보단 좀더 간결한 형태로 통계 지표를 조회할 때 활용할 수 있다.

---

## Example Console

다음은 아주 기초적인 콘솔 예시다. 우측 테이블에선 태스크 수와 작동 중인 태스크 수, 평균 CPU/메모리 사용량을 보여준다. 메인 콘텐츠엔 초당 쿼리 수를 나타내는 그래프를 표기한다.

```html
{% raw %}{{template "head" .}}{% endraw %}

{% raw %}{{template "prom_right_table_head"}}{% endraw %}
<tr>
  <th>MyJob</th>
  <th>{% raw %}{{ template "prom_query_drilldown" (args "sum(up{job='myjob'})") }}{% endraw %}
      / {% raw %}{{ template "prom_query_drilldown" (args "count(up{job='myjob'})") }}{% endraw %}
  </th>
</tr>
<tr>
  <td>CPU</td>
  <td>{% raw %}{{ template "prom_query_drilldown" (args
      "avg by(job)(rate(process_cpu_seconds_total{job='myjob'}[5m]))"
      "s/s" "humanizeNoSmallPrefix") }}{% endraw %}
  </td>
</tr>
<tr>
  <td>Memory</td>
  <td>{% raw %}{{ template "prom_query_drilldown" (args
       "avg by(job)(process_resident_memory_bytes{job='myjob'})"
       "B" "humanize1024") }}{% endraw %}
  </td>
</tr>
{% raw %}{{template "prom_right_table_tail"}}{% endraw %}


{% raw %}{{template "prom_content_head" .}}{% endraw %}
<h1>MyJob</h1>

<h3>Queries</h3>
<div id="queryGraph"></div>
<script>
new PromConsole.Graph({
  node: document.querySelector("#queryGraph"),
  expr: "sum(rate(http_query_count{job='myjob'}[5m]))",
  name: "Queries",
  yAxisFormatter: PromConsole.NumberFormatter.humanizeNoSmallPrefix,
  yHoverFormatter: PromConsole.NumberFormatter.humanizeNoSmallPrefix,
  yUnits: "/s",
  yTitle: "Queries"
})
</script>

{% raw %}{{template "prom_content_tail" .}}{% endraw %}

{% raw %}{{template "tail"}}{% endraw %}
```

오른쪽 테이블은 `prom_right_table_head`, `prom_right_table_tail` 템플릿으로 감싸고 있다. 이는 선택 사항이다.

`prom_query_drilldown` 템플릿은 전달한 표현식을 평가하고, 출력 포맷을 지정하고, [expression 브라우저](../expression-browser)의 표현식으로 연결해주는 템플릿이다. 첫 번째 인자는 표현식이며, 두 번째 인자는 사용할 단위다. 세 번째 인자로는 출력 형식을 지정한다. 첫 번째 인자만 필수 값이다.

`prom_query_drilldown`의 세 번째 인자에 사용할 수 있는 출력 포맷:

- 지정하지 않음: 디폴트 Go 출력대로 표기한다.
- `humanize`: [메트릭 프리픽스](https://en.wikipedia.org/wiki/Metric_prefix)를 사용해서 결과를 표기한다.
- `humanizeNoSmallPrefix`: 절대값이 1보다 크면 [메트릭 프리픽스](https://en.wikipedia.org/wiki/Metric_prefix)를 사용해 결과를 표기한다. 절대값이 1보다 작을 땐 세 자리 유효 숫자를 표기한다. 초당 쿼리가 밀리단위 일때 `humanize` 대신 이 포맷을 사용할 수 있다.
- `humanize1024`: 기수에 1000 대신 1024를 사용해서 사람이 알아보기 쉬운 형식으로 표기한다. 이 포맷은 보통 두 번재 인자로 `B`를 함께 전달해서 `KiB`, `MiB`같은 단위를 만들 때 사용한다.
- `printf.3g`: 세 자리 유효 숫자를 표기한다.

커스텀 포맷도 정의할 수 있다. 예시는 [prom.lib](https://github.com/prometheus/prometheus/blob/master/console_libraries/prom.lib)를 참고해라.

---

## Graph Library

그래프 라이브러리는 다음과 같이 실행한다:

```html
<div id="queryGraph"></div>
<script>
new PromConsole.Graph({
  node: document.querySelector("#queryGraph"),
  expr: "sum(rate(http_query_count{job='myjob'}[5m]))"
})
</script>
```

필요한 자바스크립트와 CSS는 `head` 템플릿이 로드해준다.

그래프 라이브러리 실행에 사용하는 파라미터들:

| Name            | Description                                                  |
| :-------------- | :----------------------------------------------------------- |
| expr            | 필수. 그래프로 나타낼 표현식. 리스트를 사용할 수 있다.       |
| node            | 필수. 렌더링할 DOM 노드.                                     |
| duration        | 옵션. 그래프에 표기할 기간. 디폴트는 한 시간이다.            |
| endTime         | 옵션. 그래프가 끝나는 Unixtime. 디폴트는 현재 시간이다.      |
| width           | 옵션. 제목을 제외한 그래프의 너비. 디폴트에선 자동 감지를 사용한다. |
| height          | 옵션. 제목과 범례<sup>legend</sup>를 제외한 그래프의 높이. 디폴트는 200픽셀이다. |
| min             | 옵션. x축의 최소값. 디폴트는 가장 낮은 데이터 값을 사용한다. |
| max             | 옵션. y축의 최대값. 디폴트는 가장 높은 데이터 값을 사용한다. |
| renderer        | 옵션. 그래프 타입. `line`과 `area`(누적 그래프<sup>stacked graph</sup>)를 사용할 수 있다. 디폴트는 `line`이다. |
| name            | 범례<sup>legend</sup>와 세부 정보를 보여주는 hover에서 사용할 플롯 제목. 문자열을 전달하면 문자열에 있는 `[[ label ]]`은 해당 레이블 값으로 치환된다. 함수를 전달한다면, 함수에선 레이블 맵을 받아 문자열로 된 이름을 반환해야 한다. 리스트를 사용할 수 있다. |
| xTitle          | 옵션. x축 제목. 디폴트는 `Time`이다.                         |
| yUnits          | 옵션. y축 단위. 기본값은 비어있다.                           |
| yTitle          | 옵션. y축 제목. 기본값은 비어있다.                           |
| yAxisFormatter  | 옵션. y축에서 사용할 number formatter. 기본값은 `PromConsole.NumberFormatter.humanize`다. |
| yHoverFormatter | 옵션. 세부 정보를 보여주는 hover에서 사용할 number formatter. 기본값은 `PromConsole.NumberFormatter.humanizeExact`다. |
| colorScheme     | 옵션. 플롯에서 사용할 color scheme. hex color code 리스트를 사용하거나, Rickshaw에서 지원하는 [color scheme 이름](https://github.com/shutterstock/rickshaw/blob/master/src/js/Rickshaw.Fixtures.Color.js) 중 하나를 사용할 수 있다. 기본값은 `colorwheel`이다. |

`expr`과 `name`에 둘다 리스트를 사용했다면, 둘의 길이가 같아야 한다. 각 표현식마다 같은 순서에 있는 name을 플롯의 제목으로 사용한다.

`yAxisFormatter`와 `yHoverFormatter`에 사용할 수 있는 옵션:

- `PromConsole.NumberFormatter.humanize`: [메트릭 프리픽스](https://en.wikipedia.org/wiki/Metric_prefix)를 사용해서 결과를 표기한다.
- `PromConsole.NumberFormatter.humanizeNoSmallPrefix`: 절대값이 1보다 크면 [메트릭 프리픽스](https://en.wikipedia.org/wiki/Metric_prefix)를 사용해 결과를 표기한다. 절대값이 1보다 작을 땐 세 자리 유효 숫자를 표기한다. 초당 쿼리가 밀리단위 일때 `PromConsole.NumberFormatter.humanize` 대신 이 포맷을 사용할 수 있다.
- `PromConsole.NumberFormatter.humanize1024`: 기수에 1000 대신 1024를 사용해서 사람이 알아보기 쉬운 형식으로 표기한다. 

