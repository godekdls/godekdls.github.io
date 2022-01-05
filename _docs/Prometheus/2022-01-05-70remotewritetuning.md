---
title: Remote write tuning
category: Prometheus
order: 70
permalink: /Prometheus/practices.remote-write/
description: remote write 튜닝 가이드
image: ./../../images/prometheus/logo.png
lastmod: 2022-01-05T21:30:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/practices/remote_write/
parent: BEST PRACTICES
parentUrl: /Prometheus/practices/
---

---

프로메테우스는 remote write에서 나름 함리적인 기본값들을 구현하고 있지만, 사용자에 따라 요구 사항이 다를 수 있으며, 원격 세팅을 직접 최적화하고 싶은 사용자들도 많을 거다.

이 페이지에선 [remote write 설정](../configuration/#remote_write)에서 사용할 수 있는 튜닝용 파라미터들에 관해 설명한다.

### 목차

- [Remote write characteristics](#remote-write-characteristics)
  + [Memory usage](#memory-usage)
- [Parameters](#parameters)
  + [capacity](#capacity)
  + [max_shards](#max_shards)
  + [min_shards](#min_shards)
  + [max_samples_per_send](#max_samples_per_send)
  + [batch_send_deadline](#batch_send_deadline)
  + [min_backoff](#min_backoff)
  + [max_backoff](#max_backoff)

---

## Remote write characteristics

remote write는 모두 WAL<sup>write-ahead log</sup>에서 데이터를 읽어오는 큐에서부터 시작한다. 샘플을 샤드가 소유하는 메모리 큐에 작성한 다음, 설정해둔 엔드포인트에 요청을 전송한다. 데이터의 흐름은 다음과 같다:

```
      |-->  queue (shard_1)   --> remote endpoint
WAL --|-->  queue (shard_...) --> remote endpoint
      |-->  queue (shard_n)   --> remote endpoint
```

샤드 하나라도 큐가 가득차면 프로메테우스는 이 WAL에서 어떤 샤드로도 데이터를 읽어올 수 없게 차단한다. 실패한 내역은 재시도하기 때문에 원격 엔드포인트가 두 시간이 넘게 다운되지만 않는다면 데이터를 유실하지 않는다. 두 시간이 지난 후에 WAL은 압축되며, 아직 전송하지 않은 데이터는 유실된다.

프로메테우스는 중간 중간에 지속적으로 샘플이 입수되는 속도, 전송이 완료되지 않고 남아있는 샘플 수, 각 샘플을 전송하는 데 걸린 시간을 기반으로 사용할 최적의 샤드 수를 계산한다.

### Memory usage

remote write를 사용하면 프로메테우스가 차지하는 메모리 공간이 늘어난다. 대부분의 사용자에 따르면 메모리 사용량이 ~25% 정도 증가한다고 하지만, 이 수치는 데이터 형태에 따라 다르다. remote write 코드에선 WAL 안에 있는 각 시계열마다 시계열 ID를 레이블 값들에 매핑한 값을 캐시에 저장하기 때문에, 시계열을 대량으로 이용하면 메모리 사용량이 크게 증가할 수 있다.

시계열 캐시가 아니더라도, 각 샤드와 샤드의 큐도 메모리 사용량을 증가시킨다. 샤드 메모리는 `number of shards * (capacity + max_samples_per_send)`에 비례한다. 튜닝할 때는 의도치 않게 메모리가 바닥나는 상황을 피하려면, `max_shards`를 줄이게 되면 `capacity`, `max_samples_per_send`를 늘려야할 수 있다는 것을 기억해둬라. 기본값에선 `capacity: 2500`, `max_samples_per_send: 500`으로, 샤드당 메모리 사용량을 500kB 미만으로 제한한다.

---

## Parameters

관련 파라미터들은 전부 [remote write 설정](../configuration/#remote_write)의 `queue_config` 파트에서 찾을 수 있다.

### `capacity`

`capacity`는 샤드당 메모리에 있는 큐에 담을 수 있는 샘플 수를 결정한다. 이 수를 넘어가면 WAL에서 데이터를 읽어가는 것을 차단한다. WAL이 차단되면 어떤 샤드에도 샘플을 추가할 수 없으며 처리량이 멈추게 된다.

대부분의 케이스에선 다른 샤드들을 차단하지 않도록 `capacity`가 충분히 높아야 하지만, 너무 과하면 리샤딩을 진행할 때 메모리 소모량이 과할 정도로 커질 수 있으며, 큐를 비우는 데도 더 오래 걸릴 수 있다. `capacity`는 `max_samples_per_send`의 3~10배 정도로 설정하는 것이 좋다.

### `max_shards`

`max_shards`는 프로메테우스가 각 remote write 큐에 사용할 최대 샤드 수, 즉 병렬 처리를 설정한다. 프로메테우스는 될 수 있으면 샤드를 과하게 사용하지 않지만, 큐가 remote write 컴포넌트보다 뒤처지면 처리량을 끌어올릴 수 있도록 샤드 수를 최대치까지 늘린다. remote write 엔드포인트가 매우 느릴 때를 제외하면 `max_shards`를 기본값 이상으로 늘려야 하는 경우는 많지 않다. 반대로, 샤드 수가 원격 엔드포인트 처리량에 비해 너무 커질 수 있거나, 데이터 백업 시 사용하는 메모리 용량을 줄일 필요가 있을 땐 최대 샤드를 줄여야 할 수 있다.

### `min_shards`

`min_shards`는 프로메테우스에서 최소로 사용하는 샤드 수를 설정하며, remote write를 시작할 때 사용하는 수이기도 하다. remote write가 뒤처지면 프로메테우스가 자동으로 샤드 수를 확장해주기 때문에, 대부분은 이 파라미터 값을 변경할 필요가 없다. 단, 최소 샤드를 늘려주면 프로메테우스가 처음에 필요한 샤드 수를 계산하느라 뒤처지는 일은 방지할 수 있다.

### `max_samples_per_send`

한 번에 전송할 최대 샘플 수는 사용 중인 백엔드에 따라 조정하면 된다. 대부분의 시스템들은 배치당 더 많은 샘플을 전송해도 지연 시간은 크게 늘지 않고 매우 잘 작동한다. 각 요청마다 샘플을 대량으로 보내려고 하면 문제가 생기는 백엔드들도 있다. 대부분의 시스템에서는 기본값은 좀 작은 편이다.

### `batch_send_deadline`

`batch_send_deadline`은 단일 샤드에서 전송 전에 최대로 대기할 수 있는 시간을 설정한다. 이 시간이 지나면 대기 중인 샤드가 `max_samples_per_send`에 도달하지 않았더라도 요청을 전송한다. 볼륨이 크지 않아 대기 시간이 크게 중요하지 않은 시스템에서는 요청 효율을 높이기 위해 `batch_send_deadline`을 늘릴 수 있다.

### `min_backoff`

`min_backoff`는 실패한 요청을 재시도하기 전에 최소한으로 대기하는 시간을 결정한다. 백오프를 늘리면 원격 엔드포인트가 다시 온라인 상태가 될 때까지 요청을 더 오래 기다렸다가 시도해볼 수 있다. 백오프 간격은 요청에 실패했을 때마다 최대 `max_backoff`까지 두 배로 늘어난다.

### `max_backoff`

`max_backoff`는 실패한 요청을 재시도하기 전에 최대로 대기할 수 있는 시간을 결정한다.