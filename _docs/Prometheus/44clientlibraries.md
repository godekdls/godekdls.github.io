---
title: Client libraries
category: Prometheus
order: 44
permalink: /Prometheus/clientlibs/
description: 지표 측정을 위한 프로메테우스 클라이언트 라이브러리 소개
image: ./../../images/prometheus/logo.png
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/instrumenting/clientlibs/
parent: INSTRUMENTING
parentUrl: /Prometheus/instrumenting/
---

---

서비스를 모니터링하려면 먼저 프로메테우스 클라이언트 라이브러리 중 하나를 골라 계측<sup>instrumentation</sup> 코드를 추가해야 한다. 이 라이브러리들은 프로메테우스의 [메트릭 타입](../metric-types)을 구현하고 있다.

프로메테우스 클라이언트 라이브러리는 애플리케이션을 작성한 언어와 같은 언어로 선택해라. 라이브러리를 통해 내부 메트릭을 정의하고, 애플리케이션 인스턴스의 HTTP 엔드포인트로 노출해줄 수 있다:

- [Go](https://github.com/prometheus/client_golang)
- [Java/Scala](https://github.com/prometheus/client_java)
- [Python](https://github.com/prometheus/client_python)
- [Ruby](https://github.com/prometheus/client_ruby)

비공식 써드 파티 클라이언트 라이브러리들:

- [Bash](https://github.com/aecolley/client_bash)
- [C](https://github.com/digitalocean/prometheus-client-c)
- [C++](https://github.com/jupp0r/prometheus-cpp)
- [Common Lisp](https://github.com/deadtrickster/prometheus.cl)
- [Dart](https://github.com/tentaclelabs/prometheus_client)
- [Elixir](https://github.com/deadtrickster/prometheus.ex)
- [Erlang](https://github.com/deadtrickster/prometheus.erl)
- [Haskell](https://github.com/fimad/prometheus-haskell)
- [Lua](https://github.com/knyar/nginx-lua-prometheus) (Nginx)
- [Lua](https://github.com/tarantool/metrics) (Tarantool)
- [.NET / C#](https://github.com/prometheus-net/prometheus-net)
- [Node.js](https://github.com/siimon/prom-client)
- [OCaml](https://github.com/mirage/prometheus)
- [Perl](https://metacpan.org/pod/Net::Prometheus)
- [PHP](https://github.com/promphp/prometheus_client_php)
- [R](https://github.com/cfmack/pRometheus)
- [Rust](https://github.com/tikv/rust-prometheus)

프로메테우스가 인스턴스의 HTTP 엔드포인트를 스크랩하면, 클라이언트 라이브러리는 추적 중인 모든 메트릭의 현재 상태를 서버로 전달해준다.

현재 사용 중인 언어에 맞는 클라이언트 라이브러리가 없거나 의존성을 추가하고 싶지 않다면, 지원하는 [exposition 포맷](../exposition-formats)  중 하나를 직접 구현해서 메트릭을 노출해줘도 된다.

프로메테우스 클라이언트 라이브러리를 새로 구현한다면 [클라이언트 라이브러리 작성 가이드라인](../writing-clientlibs)을 따라주길 바란다. 단, 이 문서는 아직 작성 중에 있다는 것을 참고해라. [개발 메일링 리스트](https://groups.google.com/forum/#!forum/prometheus-developers)에 연락해보는 것도 함께 고려해주면 좋겠다. 라이브러리를 최대한 유용하고 일관성 있게 만들 수 있도록 조언을 아끼지 않겠다.

