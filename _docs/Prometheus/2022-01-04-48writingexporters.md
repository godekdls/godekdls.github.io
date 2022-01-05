---
title: Writing exporters
category: Prometheus
order: 48
permalink: /Prometheus/writing-exporters/
description: 익스포터, 커스텀 컬렉터 작성 가이드
image: ./../../images/prometheus/logo.png
lastmod: 2022-01-05T21:30:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/instrumenting/writing_exporters/
parent: INSTRUMENTING
parentUrl: /Prometheus/instrumenting/
---

---

자체 코드를 계측<sup>instrumentation</sup>한다면 [프로메테우스 클라이언트 라이브러리로 코드를 계측하는 방법에 대한 일반적인 규칙](../practices.instrumentation)을 따라야 한다. 반면, 다른 모니터링 시스템이나 계측 시스템에서 메트릭을 가져올 때는 딱 떨어지지 않는 상황이 많기 때문에 정확하게 흑과 백으로 나누어 설명하기 어렵다.

이 문서에는 익스포터나 커스텀 컬렉터를 작성할 때 고려해야 하는 것들이 담겨있다. 여기서 다루는 이론은 [직접 계측<sup>direct instrumentation</sup>](../glossary#direct-instrumentation)을 수행하는 사람들에게도 도움이 될 거다.

익스포터를 개발하는 중에 이 문서에서 명확하지 않은 것을 발견한다면 IRC(Freenode의 #prometheus)나 [메일링 리스트](https://prometheus.io/community)로 문의줘라.

### 목차

- [Maintainability and purity](#maintainability-and-purity)
- [Configuration](#configuration)
- [Metrics](#metrics)
  + [Naming](#naming)
  + [Labels](#labels)
  + [Target labels, not static scraped labels](#target-labels-not-static-scraped-labels)
  + [Types](#types)
  + [Help strings](#help-strings)
  + [Drop less useful statistics](#drop-less-useful-statistics)
  + [Dotted strings](#dotted-strings)
- [Collectors](#collectors)
  + [Metrics about the scrape itself](#metrics-about-the-scrape-itself)
  + [Machine and process metrics](#machine-and-process-metrics)
- [Deployment](#deployment)
  + [Scheduling](#scheduling)
  + [Pushes](#pushes)
  + [Failed scrapes](#failed-scrapes)
  + [Landing page](#landing-page)
  + [Port numbers](#port-numbers)
- [Announcing](#announcing)

---

## Maintainability and purity

익스포터를 개발할 때는 먼저 완벽한 메트릭을 얻기 위해 어느정도까지 노력할 것인지를 결정해야 한다.

대상 시스템에 있는 메트릭이 많지 않고 거의 변경되지 않는다면, 모든 것을 완벽하게 측정하는기는 어렵지 않다. 이에 대한 좋은 예시는 [HAProxy 익스포터](https://github.com/prometheus/haproxy_exporter)다.

반면 새 버전으로 빈번하게 변경되는 메트릭이 수 백개 있는 시스템에서 모든 것을 완벽하게 만들려고 한다면, 완료되지 않는 많은 작업들에 스스로 묶이게 될 거다. 이 스펙트럼의 끝에는 [MySQL 익스포터](https://github.com/prometheus/mysqld_exporter)가 있다.

[노드 익스포터](https://github.com/prometheus/node_exporter)는 모듈에 따라 복잡성이 다르기 때문에 혼종이라고 볼 수 있다. 예를 들어 `mdadm` 컬렉터는 파일을 수동으로 파싱하고 컬렉터 전용으로 생성한 메트릭을 노출하므로, 메트릭도 정확하게 얻을 수 있다. `meminfo` 컬렉터의 경우 커널 버전에 따라 결과가 다르므로, 결국엔 유효한 메트릭을 생성하려면 그만큼 변환을 수행해야 된다.

---

## Configuration

익스포터는 사용자가 여러 애플리케이션에서 작업할 때 애플리케이션이 위치한 곳을 알려주는 것 외에 다른 커스텀 설정을 필요로 하지 않는 것을 목표로 해야 한다. 대규모 세팅에선 지나치게 세분화돼서 비용이 커지는 메트릭은 필터링하는 기능을 제공해야 할 수도 있다. 예를 들어 [HAProxy 익스포터](https://github.com/prometheus/haproxy_exporter)는 서버 단위 통계 필터링을 허용한다. 유사하게, 비용이 큰 일부 메트릭은 기본적으로 비활성화할 수도 있다.

다른 모니터링 시스템, 프레임워크, 프로토콜과 함께 작업할 때는 프로메테우스에 맞는 메트릭을 생성하려면 별도 설정이나 커스텀을 제공해야 하는 경우가 종종 있을 거다. 모니터링 시스템이 프로메테우스와 어느정도 비슷한 데이터 모델을 사용하는 최상의 시나리오에선 자동으로 메트릭을 변환하는 방법을 결정할 수 있다. [Cloudwatch](https://github.com/prometheus/cloudwatch_exporter), [SNMP](https://github.com/prometheus/snmp_exporter), [collectd](https://github.com/prometheus/collectd_exporter)가 이 케이스에 해당한다. 가장 넓게 보면 사용자가 가져오고 싶은 메트릭을 선택할 수 있는 기능이 필요하다.

그 외에는 사용하는 시스템과 기존 애플리케이션에 따라 시스템의 메트릭이 완전히 비표준인 케이스가 있다. 이럴 때는 사용자가 메트릭을 변환하는 방법을 알려줘야 한다. 이 분야의 최악 케이스는 [JMX 익스포터](https://github.com/prometheus/jmx_exporter)이며, [Graphite](https://github.com/prometheus/graphite_exporter)와 [StatsD](https://github.com/prometheus/statsd_exporter) 익스포터에서도 레이블 추출을 위한 설정이 필요하다.

특별한 설정 없이 익스포터가 바로 작동하는지 확인해보고, 필요한 경우 변환을 위한 설정 예제들을 선별해서 제공하기를 권고한다.

YAML은 표준 프로메테우스 설정 포맷이며, 모든 설정은 기본적으로 YAML을 사용해야 한다.

---

## Metrics

### Naming

[여기있는 메트릭 네이밍 베스트 프랙티스](../practices.naming)를 따라라.

프로메테우스에는 익숙해도 특정 시스템엔 익숙하지 않은 사람도 일반적으로 메트릭 이름을 보면 메트릭이 무엇을 의미하는지를 쉽게 추측할 수 있어야 한다. `http_requests_total`이라는 메트릭은 그렇게까지 유용하진 않다 (이런 메트릭은 도착 즉시 측정하나? 아니면 어떤 필터에서? 그것도 아니면 사용자 코드에 도달할 때?). `requests_total`은 더 별로다 (어떤 유형의 요청인가?).

[직접 계측<sup>direct instrumentation</sup>](../glossary#direct-instrumentation)을 사용한다면 하나의 메트릭은 정확히 하나의 파일 내에 있어야 한다. 마찬가지로 익스포터와 컬렉터 내에서도 메트릭은 정확히 하나의 하위 시스템에 적용하고, 이름도 그에 따라 지정해야 한다.

메트릭 이름은 커스텀 컬렉터나 익스포터를 작성할 때를 제외하고는 절차적으로<sup>procedurally</sup> 생성해서는 안 된다.

애플리케이션을 위한 메트릭에는 보통 앞에 익스포터 이름을 프리픽스로 추가해야 한다 (ex. `haproxy_up`).

메트릭은 반드시 기본 단위를 사용해야 하며 (ex. 초, 바이트), 더 읽기 쉬운 형식으로 변환하는 일은 그래프 툴에 맡겨야 한다. 결국에 어떤 단위를 사용했던 간에, 메트릭 이름에 들어있는 단위는 실제로 사용한 단위와 반드시 일치해야 한다. 마찬가지로 백분율이 아닌 비율을 노출해라. 비율을 계산하는 두 가지 구성 요소에 각각 카운터를 지정할 수 있으면 더 좋다.

메트릭명에는 익스포트할 때 사용하는 레이블이 포함돼있으면 안 된다 (ex. `by_type`). 레이블을 집계하는데 메트릭명에 레이블 이름이 있을 이유가 없다.

한 가지 예외가 있는데, 레이블이 다른 동일한 데이터를 여러 메트릭을 통해 익스포트하는 경우다. 이런 메트릭을 구별할 때는 보통 메트릭명에 레이블을 넣는게 가장 타당하다. 이런 상황은 [직접 계측<sup>direct instrumentation</sup>](../glossary#direct-instrumentation)에선 단일 메트릭으로 모든 레이블이 포함된 데이터를 익스포트하기엔 카디널리티가 너무 높을 때만 발생한다.

프로메테우스 메트릭명과 레이블명은 `snake_case`로 작성한다. `camelCase`는 `snake_case`로 변환하는 것이 바람직하지만, `myTCPExample`이나 `isNaN`과 같은 이름에선 자동 변환이 항상 좋은 결과를 낳지는 않으므로, 때로는 그대로 두는 게 가장 좋을 때도 있다.

노출하는 메트릭에는 콜론이 포함돼있으면 안 된다. 콜론은 집계할 때 사용하는 사용자 정의 recording rule 전용으로 예약돼 있다.

메트릭 명에는 `[a-zA-Z0-9:_]`만 사용할 수 있다.

Summary, Histogram, Counter에선 `_sum`, `_count`, `_bucket`, `_total`을 suffix로 사용한다. 이 중 하나를 만드는 게 아니라면 이런 suffix는 피해라.

`_total`은 카운터에서 쓰는 컨벤션이므로, COUNTER 타입을 사용한다면 컨벤션을 지켜줘야 한다.

`process_`, `scrape_` 프리픽스는 예약돼 있다. [동일한 시맨틱스](https://docs.google.com/document/d/1Q0MXWdwp1mdXCzNRak6bW5LLVylVRXhdi7_21Sg15xQ/edit)를 따르는 경우 여기에 자체 프리픽스를 추가해도 좋다. 예를 들어 프로메테우스에는 스크랩하는데 걸린 시간을 나타내는 `scrape_duration_seconds`가 있는데, 특정 익스포터가 작업을 수행하는 데 걸린 시간을 나타내는 `jmx_scrape_duration_seconds`같이, 익스포터 중심 메트릭도 함께 가져가도 좋다. PID에 접근할 수 있는 환경에서 필요한 프로세스 통계의 경우 Go와 파이썬에서는 전용 컬렉터를 제공한다. 이에 대한 좋은 예시는 [HAProxy 익스포터](https://github.com/prometheus/haproxy_exporter)다.

성공한 요청 수와 실패한 요청 수를 가지고 있다면, 이 지표를 노출할 때는 총 요청에 대한 메트릭과 실패한 요청에 대한 메트릭으로 나누는 게 가장 좋다. 이렇게 하면 실패 비율을 쉽게 계산할 수 있다. 하나의 메트릭을 이용해 레이블로 실패나 성공을 구분하진 마라. 마찬가지로 캐시에 대한 히트<sup>hit</sup>, 미스<sup>miss</sup>를 계산할 때도 총계를 저장하는 메트릭과 히트 횟수를 저장하는 메트릭으로 나누는 것이 좋다.

모니터링을 이용하는 누군가는 코드나 웹에서 메트릭 이름을 검색해볼 수 있다는 점을 기억해두자. 특정 분야에서 메트릭 이름이 매우 잘 정립돼 있고, SNMP나 네트워크 엔지니어와 같이 그런 이름들에 익숙한 사람들 말고는 딱히 외부에서 사용하지 않을 것 같다면 그 이름 그대로 두는 것이 좋다. 물론 이 논리가 모든 익스포터에 적용되는 건 아니다. 예를 들어 MySQL 익스포터 메트릭은 DBA뿐만 아니라 훨씬 더 다양한 사람들이 사용할 수 있다. `HELP` 문자열에 원래 이름을 제공해주면, 거의 원래 이름을 사용하는 것과 같은 효과를 볼 수 있다.

### Labels

레이블에 관한 [일반적인 조언들](../practices.instrumentation#things-to-watch-out-for)을 읽어봐라.

`type`을 레이블 이름으로 사용하진 마라. `type`은 너무 일반적이고 의미가 없을 때가 많다. `region`, `zone`, `cluster`, `availability_zone`, `az`, `datacenter`, `dc`, `owner`, `customer`, `stage`, `service`, `environment`, `env`와 같이 타겟 레이블과 충돌할 가능성이 큰 이름들도 가능한 한 피하는 게 좋다. 만약 애플리케이션이 어떤 리소스를 이런 이름으로 부르고 있다면, 이름을 변경해서 혼란을 줄이는 게 가장 좋다.

프리픽스가 같다는 이유로 하나의 메트릭에 몰아 넣고 싶은 유혹은 뿌리쳐야 한다. 하나의 메트릭일 때 의미가 있다고 확신하는 경우만 아니라면 여러 메트릭이 더 안전하다.

`le` 레이블은 히스토그램에서 특별한 의미를 가지며, Summary에선 `quantile`이 특별한 의미를 갖는다. 일반적으로 이런 레이블들은 피해야 한다.

Read/write나 send/receive는 레이블보단 별도의 메트릭으로 구분하는 게 가장 좋다. 보통은 한 번에 하나씩만 관심을 두는 경우가 많기도 하고, 이렇게 사용하는 게 더 쉽기도 하다.

경험에 의하면 합산하거나 평균을 계산했을 때 의미가 있는 데이터를 하나의 메트릭으로 두는 게 좋다. 익스포터에선 이와는 다른 케이스가 하나 있는데, 여기서는 데이터가 기본적으로 테이블 형식이며, 다른 형태로 이용하려면 사용자가 메트릭 이름에 정규식을 수행해야 한다. 마더보드의 전압 센서들을 생각해보자. 이 데이터에 수학 연산을 수행하는 건 의미 없긴 하지만, 센서별로 메트릭을 나누는 것보단 하나의 메트릭으로 사용하는 게 더 합리적이다. 하나의 메트릭에 있는 모든 값은 (거의) 항상 같은 단위를 가져야 한다. 예를 들어 전압 데이터에 팬 속도가 혼재돼 있고 이 둘을 자동으로 분리할 방법이 없으면 어떻게 될지를 생각해봐라.

메트릭을 다음과 같이 사용하지 마라:

```prometheus
my_metric{label=a} 1
my_metric{label=b} 6
my_metric{label=total} 7
```

다음도 마찬가지다:

```prometheus
my_metric{label=a} 1
my_metric{label=b} 6
my_metric{} 7
```

메트릭에서 `sum()`을 수행하는 사람들은 전자를 이용할 수 없으며, 후자는 sum도 불가능하고 작업하기도 매우 까다롭다. Go 등의 일부 클라이언트 라이브러리는 커스텀 컬렉터에서 메트릭을 후자처럼 만들지 못하도록 적극적으로 막아줄 거며, [직접 계측<sup>direct instrumentation</sup>](../glossary#direct-instrumentation)에선 모든 클라이언트 라이브러리가 후자처럼 메트릭을 만들지 못하도록 막아줄 거다. 이 중 어떤 것도 시도하지 말고 대신에 프로메테우스 집계를 이용해라.

사용하는 모니터링 시스템에서 이와 같은 합계를 노출한다면 그냥 합계를 빼버려라. 개별적으로는 카운팅하지 않은 항목들이 합계에는 들어있는 등, 어떤 이유로 인해 합계를 유지해야 하는 경우 다른 메트릭 이름을 사용해라.

계측 레이블은 최소한으로 유지해야 하며, 다른 별도 레이블은 모두 사용자가 PromQL을 작성할 때 필요하면 추가한다. 따라서 시계열의 고유성을 헤치지 않으면서 제거할 수 있는 계측 레이블은 되도록이면 사용하지 마라. 메트릭에 대한 부가 정보는 info 메트릭을 통해 추가하면 된다. 예시로 아래에서 버전 번호를 처리하는 방법을 참고해라.

하지만 사실상 메트릭을 사용하는 거의 모든 사용자가 부가 정보가 있기를 바랄할 것이 뻔한 경우도 있다. 이런 상황에선 레이블이 고유하지 않더라도, info 메트릭 대신 레이블을 추가하는 게 맞는 솔루션이다. 예를 들어 [mysqld_exporter](https://github.com/prometheus/mysqld_exporter)에서 `mysqld_perf_schema_events_statements_total`의 `digest` 레이블은 전체 쿼리 패턴의 해시값으로, 고유성은 이 레이블만으로 충분하다. 하지만 사람이 읽을 수 있는 `digest_text` 레이블이 없이는 거의 사용하지 않는다. `digest_text` 레이블은 쿼리가 길 땐 쿼리 패턴의 앞 부분만 포함하므로 고유하지 않다. 이런 이유로 가독성을 위한 `digest_text` 레이블과 고유성을 위한 `digest` 레이블 두 가지를 모두 사용하게 됐다.

### Target labels, not static scraped labels

모든 메트릭에 같은 레이블을 적용하고 싶어지는 경우가 있다면 멈추는 게 좋다.

이런 상황에는 보통 두 가지 케이스가 있다.

첫 번째는 소프트웨어의 버전 번호같이 메트릭에 유용할 수 있는 레이블들에 관한 것이다. 이럴 때는 레이블 대신 [https://www.robustperception.io/how-to-have-labels-for-machine-roles/](http://www.robustperception.io/how-to-have-labels-for-machine-roles/)에서 설명하는 방법대로 접근하면 된다.

두 번째 케이스는 레이블이 실제로 타겟 레이블인 경우다. 이런 레이블들은 애플리케이션 자체의 레이블이라기보단, 인프라 세팅에서 오는 region, 클러스터 이름 등과 관련이 있다. 어떤 레이블 값으로 분류해야 하는지는 애플리케이션으로 정해지지 않는다. 레이블을 구성하는 주체는 프로메테우스 서버를 실행하는 사람이며, 같은 애플리케이션을 다른 사람이 모니터링할 때는 다른 이름을 지정할 수도 있다.

그렇기 때문에 이런 레이블들은 사용 중인 서비스 디스커버리를 통해 적용되는 프로메테우스의 스크랩 설정에 속한다고 보는게 맞다. machine role 개념은 여기에도 적용할 수 있다. 적어도 해당 메트릭을 스크랩하는 누군가에겐 유용한 정보일 수 있다.

### Types

메트릭 타입은 되도록이면 프로메테우스 타입과 매치시키는 게 좋다. 보통 프로메테우스 타입이라고 하면 카운터와 게이지를 말하는 거다. summary의 `_count`와 `_sum`도 비교적 흔하며, 한 번씩은 분위수<sup>quantile</sup>를 만날 수도 있다. 히스토그램은 드물긴 하지만, 제공하게 된다면 [exposition 포맷](../exposition-formats)에선 누적 값을 노출한다는 점을 기억해둬라.

간혹 메트릭이 무슨 타입인지 명확하지 않은 경우가 있는데, 특히 메트릭 셋을 자동으로 처리하는 경우가 그렇다. 일반적으로 안전한 기본값은 `UNTYPED`다.

카운터 값은 감소할 수 없으므로, 다른 계측<sup>instrumentation</sup> 시스템에서 감소할 수 있는 카운터 타입을 만나게 된다면 (ex. Dropwizard 메트릭) 해당 타입은 카운터가 아니라 게이지가 맞다. `GAUGE`를 카운터로 사용한다면 오해의 소지가 있을 수 있기 때문에 이런 곳에선 웬만하면 `UNTYPED`를 사용하는 게 가장 좋다.

### Help strings

메트릭을 변환한다면, 사용자가 원본은 무엇이었는지, 그리고 변환을 유발한 rule은 무엇인지를 역으로 추적할 수 있게 해주면 좋다. 컬렉터나 익스포터의 이름, 적용한 rule의 ID, 원래 메트릭의 이름과 세부 정보를 help 문자열에 넣어주면 사용자에게 큰 도움이 될 거다.

프로메테우스는 메트릭 하나에 여러 가지 help 문자열이 있는 것을 좋아하지 않는다. 여러 가지 정보로 하나의 메트릭을 생성한다면, help 문자열에는 그 중 하나만 선택해서 넣어라.

예를 들어 SNMP 익스포터는 OID를 사용하고, JMX 익스포터는 샘플 mBean 이름을 넣는다. [HAProxy 익스포터](https://github.com/prometheus/haproxy_exporter)에는 직접 써넣은 문자열이 있다. [노드 익스포터](https://github.com/prometheus/node_exporter)에서도 다양한 예시를 만나볼 수 있다.

### Drop less useful statistics

계측<sup>instrumentation</sup> 시스템 중에는 최소값, 최대값, 표준 편차와 함께 1m, 5m, 15m 비율과 애플리케이션 기동 후 평균 비율(예를 들어 Dropwizard 메트릭에선 `mean`이라고 부른다)을 노출하는 시스템이 있다.

이런 지표는 그닥 유용하지 않고 혼란만 더하기 때문에 전부 삭제하는 게 좋다. 비율은 프로메테우스 자체에서 계산할 수 있으며, 평균값을 노출하면 기하급수적으로 감소하는 경우가 많기 때문에 보통은 프로메테우스로 계산하는 게 더 정확하다. 최소값이나 최대값은 언제 계산한 값인지를 알 수 없으며, 표준 편차는 통계적으로 무의미하고, 계산이 필요하다고 해도 제곱합, `_sum`, `_count`는 언제든지 노출할 수 있다.

분위수<sup>Quantile</sup>도 비슷한 이슈가 있으므로, 삭제하거나 Summary에 넣어주면 된다.

### Dotted strings

모니터링 시스템 중에는 레이블이 없고 그대신 메트릭을 `my.class.path.mymetric.labelvalue1.labelvalue2.labelvalue3`과 같이 모델링하는 시스템이 많다.

[Graphite](https://github.com/prometheus/graphite_exporter)와 [StatsD](https://github.com/prometheus/statsd_exporter) 익스포터에선 간단한 설정 언어를 공유해서 위 모델을 레이블로 변환하고 있다. 다른 익스포터도 똑같이 구현해줘야 한다. 이 변환 로직은 현재 Go에서만 구현돼 있으며, 따로 빼서 별도 라이브러리로 분리해도 좋을 거다.

---

## Collectors

익스포터를 위한 컬렉터를 구현할 때는 일반적인 [직접 계측<sup>direct instrumentation</sup>](../glossary#direct-instrumentation)처럼 접근해서 스크랩할 때마다 메트릭을 업데이트해선 안 된다.

오히려 매번 새로운 메트릭을 만드는 게 맞다. Go에선 `Collect()` 메소드에서 [MustNewConstMetric](https://godoc.org/github.com/prometheus/client_golang/prometheus#MustNewConstMetric)을 사용하면 된다. 파이썬에선 [https://github.com/prometheus/client_python#custom-collectors](https://github.com/prometheus/client_python#custom-collectors)를 참고하면 되고, 자바는 collect 메소드에서 `List<MetricFamilySamples>`를 생성해라. 예시로 [StandardExports.java](https://github.com/prometheus/client_java/blob/master/simpleclient_hotspot/src/main/java/io/prometheus/client/hotspot/StandardExports.java)를 참고해라.

이렇게 접근하는 이유는 크게 두 가지로 나뉜다. 첫 번째 이유는 동시에 스크랩이 두 번 발생할 수 있기 때문이다. 직접 계측에선 사실상 파일 수준의 전역 변수를 사용하기 때문에 경쟁 조건에 놓이게 될 수 있다. 두 번째 이유는 레이블 값이 사라지더라도 그대로 익스포트될 거기 때문이다.

직접 계측을 통해 익스포터 자체를 계측하는 것은 문제 없다. 예를 들어 모든 스크랩에서 전송한 총 바이트 수나 익스포터가 수행한 호출 수를 측정할 수 있다. [blackbox 익스포터](https://github.com/prometheus/blackbox_exporter)나 [SNMP 익스포터](https://github.com/prometheus/snmp_exporter)같이 단일 타겟으로 묶이지 않는 익스포터의 경우, 이런 메트릭은 특정 타겟을 스크랩할 때가 아닌 순수<sup>vanilla</sup> `/metrics` 호출에서만 노출해줘야 한다.

### Metrics about the scrape itself

간혹 스크랩에 소요된 시간이나 처리한 레코드 수와 같이, 스크랩에 관련된 메트릭을 익스포트하고 싶을 때가 있다.

이런 메트릭은 스크랩 이벤트와 관련이 있기 때문에 게이지로 노출해야 하며, `jmx_scrape_duration_seconds`와 같이 프리픽스로 익스포터 이름이 붙는다. 보통은 `_exporter`는 제외하며, 익스포터를 단순 컬렉터로도 사용할 수 있다면 당연히 제외하는 게 맞다.

### Machine and process metrics

Elasticsearch를 포함해서 CPU, 메모리, 파일 시스템 정보같은 머신 메트릭을 노출하는 시스템이 많이 있다. 이런 정보는 프로메테우스 에코시스템에선 [노드 익스포터](https://github.com/prometheus/node_exporter)가 제공하므로, 이런 메트릭은 삭제해야 한다.

자바 세계에선 다양한 계측<sup>instrumentation</sup> 프레임워크가 CPU, GC같은 프로세스 수준 통계 정보와 JVM 수준 통계 정보를 노출한다. 자바 클라이언트와 JMX 익스포터에선 이미 이런 정보를 [DefaultExports.java](https://github.com/prometheus/client_java/blob/master/simpleclient_hotspot/src/main/java/io/prometheus/client/hotspot/DefaultExports.java)를 통해 선호하는 형태로 수집하고 있으므로, 이 역시 삭제해야 한다.

다른 언어와 프레임워크에서도 마찬가지다.

---

## Deployment

각 익스포터는 정확히 하나의 인스턴스 애플리케이션을 모니터링해야 하며, 가급적이면 동일한 머신에 같이 두는 게 좋다. 즉, HAProxy를 실행할 때마다 `haproxy_exporter` 프로세스를 실행한다. Mesos 워커를 실행하는 모든 머신에는 [Mesos 익스포터](https://github.com/mesosphere/mesos_exporter)를 실행하고, 마스터와 워커가 둘 다 있는 머신에는 마스터용 익스포터를 하나 더 실행한다.

여기의 이면에는 사용자는 [직접 계측<sup>direct instrumentation</sup>](../glossary#direct-instrumentation)을 담당하고, 프로메테우스는 다른 레이아웃에서도 가능한 한 직접 계측과 비슷하게 접근하려고 노력 중이라는 이론이 깔려있다. 즉, 모든 서비스 디스커버리는 익스포터가 아닌 프로메테우스에서 수행한다. 이렇게 하면 사용자가 [blackbox 익스포터](https://github.com/prometheus/blackbox_exporter)로 서비스를 프로빙하는 데 필요한 타겟 정보를 프로메테우스에서 가지고 있다는 이점도 생긴다.

여기에는 두 가지 예외가 있다:

첫 번째는 익스포터를 모니터링하는 애플리케이션 바로 옆에서 실행하는 게 완전히 무의미한 경우다. 이 케이스에 해당하는 대표적인 예시는 SNMP, blackbox, IPMI 익스포터다. IPMI와 SNMP 익스포터는 보통 코드를 실행할 수 없는 블랙박스 장치에 가까우며 (그대신 노드 익스포터를 실행할 수 있다면 더 좋긴하다), blackbox 익스포터는 실행할 것도 없이 DNS 이름같은 것들을 모니터링한다. 이런 경우에도 프로메테우스는 서비스 디스커버리를 수행하고 스크랩할 타겟을 전달할 거다. 예제가 필요하다면 blackbox, SNMP 익스포터를 참고해라.

참고로 현재 이런 타입의 익스포터는 Go, 파이썬, 자바 클라이언트 라이브러리로만 작성할 수 있다.

두 번째 예외는 특정 시스템에 있는 임의의 인스턴스에서 통계 정보를 가져오며, 어떤 인스턴스와 통신하는지는 상관 없는 경우다. MySQL 레플리카 셋에서 어떤 비즈니스 쿼리를 실행하고, 해당 데이터를 익스포트한다고 생각해봐라. 이때는 늘상 사용하는 로드 밸런싱을 이용해 하나의 익스포터로 하나의 레플리카와 통신하는 게 가장 합리적이다.

마스터를 선출하는 시스템을 모니터링하는 경우엔 적용되지 않는다. 이땐 각 인스턴스를 개별적으로 모니터링하고, 프로메테우스에서 "masterness"를 처리해야 한다. 마스터는 항상 정확히 하나만 있는 것은 아니며, 프로메테우스가 관리하는 타겟이 임의로 변경되면 이상한 일이 발생하게 될 거다.

### Scheduling

애플리케이션 메트릭은 프로메테우스가 스크랩할 때만 가져와야 하며, 익스포터 자체에서 타이머 기반으로 스크랩을 수행해선 안 된다. 다시 말해, 모든 스크랩은 동기식으로 동작해야 한다.

따라서 노출하는 메트릭에 타임스탬프를 설정하면 안 되고, 프로메테우스가 알아서 처리하도록 놔둬야 한다. 타임스탬프가 필요하다고 느껴진다면 대신에 [Pushgateway](../pushing)가 필요한 걸 수도 있다.

메트릭을 가져오는데 유독 비용이 많이 드는 메트릭이 있다면 (ex. 1분 이상 소요되는 경우) 캐시에 저장하는 것도 괜찮다. 캐시를 사용한다면 `HELP` 문자열에서 언급해주는 게 좋다.

프로메테우스의 디폴트 스크랩 타임아웃은 10초다. 개발 중인 익스포터에서 이 시간을 넘어갈 것으로 예상된다면, 사용자 문서에 반드시 명시해줘야 한다.

### Pushes

애플리케이션과 모니터링 시스템 중에는 단순히 메트릭을 푸시하는 게 전부인 곳도 있다. 예를 들어 StatsD, Graphite, collectd가 그렇다.

여기서는 두 가지를 고려해봐야 한다.

첫째, 메트릭은 언제 만료시켜야 할까? Collectd나 Graphite와 통신하는 것들은 모두 정기적으로 메트릭을 익스포트하며, 시스템이 중단되면 메트릭 노출도 중단해야 한다. Collectd에는 만료 시간이 포함돼 있으므로 이 정보를 사용하지만, Graphite는 만료 시간이 따로 들어있지 않으므로 익스포터의 플래그로 설정한다.

StatsD는 메트릭이 아닌 이벤트를 다루기 때문에 약간 다르다. 각 애플리케이션마다 바로 옆에 익스포터를 하나씩 실행하고, 애플리케이션이 재시작하면 익스포터도 재시작해서 상태를 비우는 모델이 가장 좋다.

둘째, 이런 류의 시스템에선 보통 사용자가 델타나 원본 카운터를 전송하도록 만들 수 있다. 원본 카운터는 일반적인 프로메테우스 모델이므로, 가능하면 원본 카운터를 최대한 활용하는 게 좋다.

서비스 수준 메트릭의 경우 (ex. 서비스 수준 배치 job), 상태를 직접 처리하기 보단 이벤트 발생 이후에 익스포터가 Pushgateway로 푸시하고 종료하도록 하는 게 좋다. 인스턴스 수준 배치 메트릭의 경우 아직까진 명확한 패턴이 없다. 여기에는 노드 익스포터의 textfile 컬렉터를 가져와 쓰거나, 인 메모리 상태를 이용하거나 (재부팅 후에도 상태를 유지할 필요가 없다면 가장 좋다), textfile 컬렉터와 유사한 기능을 구현하는 옵션이 있다.

### Failed scrapes

현재 통신하는 애플리케이션이 응답하지 않거나, 그외 다른 문제가 있을 때는 스크랩에 실패한다. 스크랩 실패에는 두 가지 패턴이 있다.

첫 번째 패턴에선 5xx 에러를 반환한다.

두 번째 패턴에선 스크랩 동작 여부에 따라 0이나 1을 값으로 가지는 변수 `myexporter_up`을 사용한다 (ex. `haproxy_up`).

후자는 프로세스 통계를 제공하는 HAProxy 익스포터같이, 스크랩에 실패할지라도 유용한 메트릭을 얻을 수 있는 경우에 더 좋다. 전자는 [`up` 메트릭이 평소와 동일하게 동작하기 때문에](../jobs-instances#automatically-generated-labels-and-time-series) 사용자가 다루기엔 좀 더 쉽지만, 익스포터가 다운된 것과 애플리케이션이 다운된 것을 구분할 수 없다.

### Landing page

`http://yourexporter/`를 방문했을 때 익스포터 이름과 `/metrics` 페이지에 대한 링크를 포함한 간단한 HTML 페이지를 볼 수 있다면 더 좋다.

### Port numbers

사용자는  여러 가지 익스포터와 프로메테우스 구성 요소를 동일한 시스템에서 실행할 수도 있으므로, 각각 고유한 포트 번호를 가진다면 좀 더 원활하게 진행할 수 있을 거다.

포트 번호는 [https://github.com/prometheus/prometheus/wiki/Default-port-allocations](https://github.com/prometheus/prometheus/wiki/Default-port-allocations)에서 추적하고 있으며, 누구나 수정할 수 있다.

익스포터를 개발한다면, 가급적이면 외부에 공개하기 전에, 다음 남아있는 포트 번호를 자유롭게 고르면 된다. 아직 출시 준비가 되지 않았다면 username과 WIP만 입력해도 괜찮다.

이 페이지는 특정 익스포터를 개발하겠다는 약속이라기 보단, 사용자의 편의를 위한 레지스트리라고 봐주면 된다. 내부 애플리케이션 전용 익스포터를 만든다면, 디폴트 포트 할당 범위 밖에 있는 포트를 사용하길 권장한다.

---

## Announcing

개발한 익스포터를 세상에 알릴 준비가 됐다면 메일링 리스트에 메일을 보내고, PR을 열어 [사용 가능한 익스포터 목록](https://github.com/prometheus/docs/blob/master/content/docs/instrumenting/exporters.md)에 추가해주길 바란다.
