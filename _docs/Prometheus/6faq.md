---
title: Frequently asked questions
navTitle: FAQ
category: Prometheus
order: 6
permalink: /Prometheus/faq/
description: 프로메테우스와 관련해서 자주 하는 질문들
image: ./../../images/prometheus/logo.png
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/introduction/faq/
parent: INTRODUCTION
parentUrl: /Prometheus/introduction/
---

### 목차

- [General](#general)
  + [프로메테우스가 뭔가요?](#프로메테우스가-뭔가요)
  + [다른 모니터링 시스템과 비교했을 때 프로메테우스는 어떤 점이 다른가요?](#다른-모니터링-시스템과-비교했을-때-프로메테우스는-어떤-점이-다른가요)
  + [프로메테우스는 어떤 시스템에 의존성하나요?](#프로메테우스는-어떤-시스템에-의존성하나요)
  + [프로메테우스로 고가용성을 실현할 수 있나요?](#프로메테우스로-고가용성을-실현할-수-있나요)
  + [프로메테우스는 "확장이 안 된다"고 들었어요.](#프로메테우스는-확장이-안-된다고-들었어요)
  + [프로메테우스는 어떤 언어로 만들어졌나요?](#프로메테우스는-어떤-언어로-만들어졌나요)
  + [프로메테우스 기능과, 저장 포맷, API들은 얼마나 안정적인가요?](#프로메테우스-기능과-저장-포맷-api들은-얼마나-안정적인가요)
  + [왜 push가 아니라 pull인가요?](#왜-push가-아니라-pull인가요)
  + [프로메테우스에 로그를 심으러면 어떻게 해야 하나요?](#프로메테우스에-로그를-심으러면-어떻게-해야-하나요)
  + [프로메테우스는 누가 만들었나요?](#프로메테우스는-누가-만들었나요)
  + [프로메테우스는 어떤 라이센스로 관리되나요?](#프로메테우스는-어떤-라이센스로-관리되나요)
  + [Prometheus의 복수형은 뭔가요?](#prometheus의-복수형은-뭔가요)
  + [프로메테우스 설정을 다시 로드할 수 있나요?](#프로메테우스-설정을-다시-로드할-수-있나요)
  + [알림을 전송할 수 있나요?](#알림을-전송할-수-있나요)
  + [대시보드를 만들 수 있나요?](#대시보드를-만들-수-있나요)
  + [타임존을 바꿀 순 없나요? 왜 전부 UTC인가요?](#타임존을-바꿀-순-없나요-왜-전부-utc인가요)
- [Instrumentation](#instrumentation)
  + [지표 측정을 위한 계측<sup>instrumentation</sup> 라이브러리는 어떤 언어로 제공하나요?](#지표-측정을-위한-계측instrumentation-라이브러리는-어떤-언어로-제공하나요)
  + [장비들을 모니터링할 수 있나요?](#장비들을-모니터링할-수-있나요)
  + [네트워크 장비도 모니터링할 수 있나요?](#네트워크-장비도-모니터링할-수-있나요)
  + [배치 job을 모니터링할 수 있나요?](#배치-job을-모니터링할-수-있나요)
  + [프로메테우스로 곧바로 모니터링해볼 수 있는 어플리케이션은 어떤 게 있나요?](#프로메테우스로-곧바로-모니터링해볼-수-있는-어플리케이션은-어떤-게-있나요)
  + [JMX를 통한 JVM 어플리케이션 모니터링도 가능한가요?](#jmx를-통한-jvm-어플리케이션-모니터링도-가능한가요)
  + [지표 측정이 성능에 끼치는 영향은 어느 정도인가요?](#지표-측정이-성능에-끼치는-영향은-어느-정도인가요)
- [Troubleshooting](#troubleshooting)
  + [프로메테우스 1.x 서버를 사용 중인데, 기동이 너무 오래 걸리고 크래시 복구에 관한 로그가 너무 많이 보입니다.](#프로메테우스-1x-서버를-사용-중인데-기동이-너무-오래-걸리고-크래시-복구에-관한-로그가-너무-많이-보입니다)
  + [프로메테우스 1.x 서버를 사용 중인데, 서버의 메모리가 부족합니다.](#프로메테우스-1x-서버를-사용-중인데-서버의-메모리가-부족합니다)
  + [프로메테우스 1.x 서버를 사용 중인데, "rushed mode" 또는 "storage needs throttling"이라는 로그가 보입니다.](#프로메테우스-1x-서버를-사용-중인데-rushed-mode-또는-storage-needs-throttling이라는-로그가-보입니다)
- [Implementation](#implementation)
  + [왜 모든 샘플 값은 64 비트 부동 소수점인가요? 정수를 사용하고 싶습니다.](#왜-모든-샘플-값은-64-비트-부동-소수점인가요-정수를-사용하고-싶습니다)
  + [프로메테우스 서버 컴포넌트들이 TLS나 인증을 지원하지 않는 이유가 뭔가요? 추가할 순 없나요?](#프로메테우스-서버-컴포넌트들이-tls나-인증을-지원하지-않는-이유가-뭔가요-추가할-순-없나요)

---

## General

### 프로메테우스가 뭔가요?

프로메테우스는 활발한 생태계를 갖춘 오픈 소스 시스템 모니터링, alert 툴킷이다. [overview](../overview) 섹션을 참고해라.

### 다른 모니터링 시스템과 비교했을 때 프로메테우스는 어떤 점이 다른가요?

[comparison](../comparison) 페이지를 확인해봐라.

### 프로메테우스는 어떤 시스템에 의존성하나요?

메인 프로메테우스 서버는 독립형으로 실행되며 외부 의존성은 따로  없다.

### 프로메테우스로 고가용성을 실현할 수 있나요?

그렇다. 별도 장비 둘 이상에서 동일한 프로메테우스 서버를 실행해라. 같은 alert가 중복되면 [Alertmanager](https://github.com/prometheus/alertmanager)가 제거해줄 거다.

[Alertmanager의 고가용성](https://github.com/prometheus/alertmanager#high-availability)은, [Mesh 클러스터](https://github.com/weaveworks/mesh)에 여러 인스턴스를 실행하고 프로메테우스 서버들을 설정해 각 서버에 알림<sup>notification</sup>을 전송하면 된다.

### 프로메테우스는 "확장이 안 된다"고 들었어요.

실제로는 다양한 방법으로 프로메테우스를 확장하고 연합<sup>federation</sup>하게 만들 수 있다. 확장을 시작하려면 Robust Perception 블로그에 있는 [Scaling and Federating Prometheus](https://www.robustperception.io/scaling-and-federating-prometheus/)를 읽어봐라.

### 프로메테우스는 어떤 언어로 만들어졌나요?

프로메테우스 컴포넌트는 대부분 Go로 작성한다. 일부는 Java, Python, Ruby로 만들기도 했다.

### 프로메테우스 기능과, 저장 포맷, API들은 얼마나 안정적인가요?

프로메테우스 깃허브 org에 있는 모든 레포지토리는 1.0.0 버전부터 대체로 [시맨틱 버저닝](http://semver.org/)를 따르고 있다. 큰 변경 사항이 생기면 메이저 버전을 올림으로써 알린다. 실험적인 컴포넌트에선 예외가 있을 수도 있으며, 이땐 확실하게 공지한다.

1.0.0 전 버전이라도 전반적으로는 꽤 안정적이라고 볼 수 있다. 확실한 릴리즈 프로세스를 추구하고 있으며, 궁극적으로 모든 레포지토리에서 1.0.0 버전을 릴리즈하는 걸 목표로 하고 있다. 어떠한 경우에도 큰 변경 사항은 릴리즈 노트에서 언급하고 있으며 (`[CHANGE]`로 마킹), 아직 공식 릴리즈가 없는 컴포넌트에서도 명확하게 알리고 있다.

### 왜 push가 아니라 pull인가요?

HTTP에서 데이터를 pull 방식으로 가져오면 좋은 점이 많이 있다:

- 변경 사항을 개발 중일 때 노트북에서도 모니터링을 실행해볼 수 있다.
- 모니터링 타겟이 다운됐을 때 더 쉽게 알아챌 수 있다.
- 웹 브라우저를 통해 직접 원하는 타겟으로 이동해 상태를 점검할 수 있다.

전반적으로 pulling이 pushing보단 좀 더 낫다고 생각하긴 지만, 모니터링 시스템을 이야기할 때 핵심 요지로 간주하는 건 금물이다.

반드시 push가 필요한 곳을 위해 [Pushgateway](../pushing)를 따로 제공하고 있다.

### 프로메테우스에 로그를 심으러면 어떻게 해야 하나요?

한 줄 요약 : 심지 마라! 대신에 [ELK 스택](https://www.elastic.co/products)같은 걸 사용해라.

더 긴 답변: 프로메테우스는 이벤트 로깅 시스템이 아니라, 메트릭을 수집하고 처리하는 시스템이다. 로그와 메트릭 간의 차이점은 Raintank 블로그 게시물 [Logs and Metrics and Graphs, Oh My!](https://blog.raintank.io/logs-and-metrics-and-graphs-oh-my/)에서 자세히 다루고 있다.

어플리케이션 로그에서 프로메테우스 메트릭을 추출하고 싶다면 구글의 [mtail](https://github.com/google/mtail)이 도움이 될 거다.

### 프로메테우스는 누가 만들었나요?

처음 시작은 [Matt T. Proud](http://www.matttproud.com/)와 [Julius Volz](http://juliusv.com/)가 비공개로 개발을 시작하면서였다. 초기 개발은 대부분 [SoundCloud](https://soundcloud.com/)가 후원했다.

이제는 매우 다양한 기업와 개인들이 관리, 확장시키고 있다.

### 프로메테우스는 어떤 라이센스로 관리되나요?

프로메테우스는 [아파치 2.0](https://github.com/prometheus/prometheus/blob/master/LICENSE) 라이선스에 따라 릴리즈한다.

### Prometheus의 복수형은 뭔가요?

[광범위한 조사](https://youtu.be/B_CDeYrqxjQ) 끝에 'Prometheus'의 올바른 복수형은 'Prometheis'인 것으로 결론났다.

### 프로메테우스 설정을 다시 로드할 수 있나요?

가능하다. 프로메테우스 프로세스에 `SIGHUP`을 전송하거나, `/-/reload` 엔드포인트에 HTTP POST 요청을 보내면 설정 파일을 다시 로드해서 반영한다.  변경 사항 반영에 실패했을 때에도 다양한 컴포넌트들이 적절히<sup>gracefully</sup> 처리를 시도해본다.

### 알림을 전송할 수 있나요?

[Alertmanager](https://github.com/prometheus/alertmanager)를 사용하면 가능하다.

현재 지원하는 외부 시스템은 다음과 같다:

- Email
- Generic Webhooks
- [OpsGenie](https://www.opsgenie.com/)
- [PagerDuty](https://www.pagerduty.com/)
- [Pushover](https://pushover.net/)
- [Slack](https://slack.com/)
- [VictorOps](https://victorops.com/)
- [WeChat](https://www.wechat.com/)

### 대시보드를 만들 수 있나요?

가능하다. 프로덕션에선 [그라파나](../grafana)를 권장한다. [콘솔 템플릿](../console-templates)이란 것도 있다.

### 타임존을 바꿀 순 없나요? 왜 전부 UTC인가요?

타임존 때문에 혼동하는 일이 없도록 (소위 말하는 서머타임이 관련됐을 땐 특히 더) 프로메테우스의 모든 컴포넌트에선, 내부에선 Unix 시간을, 표기 시엔 UTC만을 사용하기로 결정했다. UI에 세심한 타임존 선택 기능이 도입될 수도 있다. 기여는 언제나 환영이다. 이 이슈의 현재 상태는 [issue #500](https://github.com/prometheus/prometheus/issues/500)을 참고해라.

---

## Instrumentation

### 지표 측정을 위한 계측<sup>instrumentation</sup> 라이브러리는 어떤 언어로 제공하나요?

프로메테우스 메트릭으로 서비스 지표를 측정해주는 클라이언트 라이브러리는 여러 가지가 있다. 자세한 내용은 [클라이언트 라이브러리](../clientlibs) 문서를 참고해라.

새로운 언어를 위한 클라이언트 라이브러리에 기여하고 싶다면 [exposition 포맷](../exposition-formats)을 참고해라.

### 장비들을 모니터링할 수 있나요?

가능하다. [노드 익스포터](https://github.com/prometheus/node_exporter)는 리눅스나 다른 유닉스 시스템의 CPU 사용량, 메모리, 디스크/파일 시스템 사용률, 네트워크 대역폭 같이 매우 다양한 장비 수준 메트릭을 노출해준다.

### 네트워크 장비도 모니터링할 수 있나요?

가능하다. [SNMP 익스포터](https://github.com/prometheus/snmp_exporter)를 사용하면 SNMP를 지원하는 장비를 모니터링할 수 있다.

### 배치 job을 모니터링할 수 있나요?

[Pushgateway](../pushing)를 사용하면 가능하다. 배치 job 모니터링을 위한 [베스트 프랙티스](../practices.instrumentation#batch-jobs)도 함께 참고해라.

### 프로메테우스로 곧바로 모니터링해볼 수 있는 어플리케이션은 어떤 게 있나요?

[익스포터와 통합 문서에 있는 리스트](../exporters)를 확인해봐라.

### JMX를 통한 JVM 어플리케이션 모니터링도 가능한가요?

가능하다. 자바 클라이언트로 직접 지표를 측정할 수 없는 어플리케이션은 [JMX 익스포터](https://github.com/prometheus/jmx_exporter)를 별도로 실행하거나 자바 에이전트로 사용하면 된다.

### 지표 측정이 성능에 끼치는 영향은 어느 정도인가요?

클라이언트 라이브러리와 사용하는 언어에 따라 성능은 달라질 수 있다. 자바의 경우 상황에 따라 달라질 순 있지만, [벤치마크](https://github.com/prometheus/client_java/blob/master/benchmarks/README.md)를 보면 자바 클라이언트로 카운터/게이지를 증가시키는 데 12-17ns가 소요됨을 시사하고 있다. 지연 시간에 영향을 제일 많이 받는 코드 외에는 모두 무시해도 되는 수준이다.

---

## Troubleshooting

### 프로메테우스 1.x 서버를 사용 중인데, 기동이 너무 오래 걸리고 크래시 복구에 관한 로그가 너무 많이 보입니다.

이 증상의 원인은 불완전한 종료 때문이다. 프로메테우스는 `SIGTERM`을 받은 뒤 완전히 종료되어야 하며, 사용량이 많은 서버라면 시간이 오래 걸릴 수도 있다. 서버에서 크래시가 발생하거나 강제로 종료되는 경우에는 (ex. 커널에 의한 OOM kill이나, runlevel 시스템이 프로메테우스 종료를 끝까지 기다리지 않았을 때) 크래시 복구를 수행해야 한다. 정상적인 상황에선 1분도 채 걸리지 않으며, 특정 상황에선 길게 이어지기도 한다. 자세한 내용은 [크래시 복구](https://prometheus.io/docs/prometheus/1.8/storage/#crash-recovery)를 참고해라.

### 프로메테우스 1.x 서버를 사용 중인데, 서버의 메모리가 부족합니다.

프로메테우스를 사용 가능한 메모리 양에 맞게 구성하려면 [메모리 사용량에 관한 섹션](https://prometheus.io/docs/prometheus/1.8/storage/#memory-usage)을 참고해라.

### 프로메테우스 1.x 서버를 사용 중인데, "rushed mode" 또는 "storage needs throttling"이라는 로그가 보입니다.

스토리지가 과부하 상태라는 뜻이다. [로컬 스토리지 설정에 관한 섹션](https://prometheus.io/docs/prometheus/1.8/storage/)을 읽고 설정을 바꿔 성능을 개선할 방법을 찾아봐라.

---

## Implementation

### 왜 모든 샘플 값은 64 비트 부동 소수점인가요? 정수를 사용하고 싶습니다.

설계를 단순하게 가기 위해 64 비트 부동 소수점으로 제한을 뒀다. [IEEE 754 배정밀도 이진 부동 소수점 형식](https://en.wikipedia.org/wiki/Double-precision_floating-point_format)은 정수 정밀도를 최대 2<sup>53</sup>까지 지원한다. 네이티브 64 비트 정수를 지원하면 2<sup>53</sup> 이상부터 2<sup>63</sup> 이하까지의 정수 정밀도가 필요한 경우에(만) 도움이 될 거다. 원론적으로 다양한 샘플 값 타입(big integer류나, 64 비트 이상)에 대한 지원도 구현할 수 있지만, 현재로선 우선 순위가 높지 않다. 카운터는 초당 100만 번씩 증가하더라도 정밀도 문제는 285년이 지나고 나서야 발생한다.

### 프로메테우스 서버 컴포넌트들이 TLS나 인증을 지원하지 않는 이유가 뭔가요? 추가할 순 없나요?

다양한 컴포넌트에서 서서히 TLS와 기본 인증을 지원하고 있다. 이를 구현한 컴포넌트가 어떤 게 있는지 알고 싶다면 각 릴리즈 노트와 changelog를 확인해봐라.

현재 TLS와 인증을 지원하는 컴포넌트는 다음과 같다:

- 프로메테우스 2.24.0 이상
- 노드 익스포터 1.0.0 이상

이는 인바운드 커넥션에만 적용된다. 프로메테우스에선 [스크랩 타겟에 TLS와 인증을 활성화](../configuration#scrape_config)할 수 있으며, 아웃바운드 커넥션을 만드는 다른 프로메테우스 컴포넌트도 유사한 기능을 지원한다.