---
title: Storage
category: Prometheus
order: 32
permalink: /Prometheus/storage/
description: 프로메테우스 로컬 스토리지 구조, 리모트 스토리지 통합, 데이터 backfill 가이드
image: ./../../images/prometheus/remote_integrations.png
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/prometheus/2.32/storage
parent: PROMETHEUS
parentUrl: /Prometheus/prometheus/
---

---

프로메테우스는 로컬 디스크 기반 시계열 데이터베이스를 가지고 있지만, 원한다면 원격 스토리지 시스템과 통합하는 것도 가능하다.

### 목차

- [Local storage](#local-storage)
  + [On-disk layout](#on-disk-layout)
- [Compaction](#compaction)
- [Operational aspects](#operational-aspects)
- [Remote storage integrations](#remote-storage-integrations)
  + [Overview](#overview)
  + [Existing integrations](#existing-integrations)
- [Backfilling from OpenMetrics format](#backfilling-from-openmetrics-format)
  + [Overview](#overview-1)
  + [Usage](#usage)
    * [Longer Block Durations](#longer-block-durations)
- [Backfilling for Recording Rules](#backfilling-for-recording-rules)
  + [Overview](#overview-2)
  + [Usage](#usage-1)
  + [Limitations](#limitations)

---

## Local storage

프로메테우스의 로컬 시계열 데이터베이스는 로컬 스토리지에 데이터를 저장하며, 커스텀한 형식을 적용해 저장 효율을 높인다.

### On-disk layout

수집한 샘플들은 2시간 짜리 블록으로 묶인다. 각 블록은 하위 디렉토리 chunks(각 time 윈도우에서 수집한 모든 시계열 샘플이 담겨있다), 메타데이터 파일, 인덱스 파일(메트릭명과 레이블로 chunks 디렉토리에 있는 시계열을 인덱싱하는 파일)이 담겨있는 디렉토리로 구성된다. 청크 디렉토리에 있는 샘플들은 하나 이상의 세그먼트 파일로 묶이며, 기본적으로 각 세그먼트 파일은 최대 512MB를 사용한다. API를 통해 시계열을 삭제하면 별도의 톰스톤<sup>tombstone</sup> 파일에 삭제 레코드를 저장한다 (청크 세그먼트에서 곧바로 데이터를 삭제하지 않는다).

현재 샘플을 수집 중인 블록은 메모리에 유지하며, 완전하게 저장되진<sup>persisted</sup> 않은 상태다. 프로메테우스 서버에서 크래시가 발생해 재시작되면 WAL<sup>write-ahead log</sup>을 리플레이해서 블록을 복구한다. WAL 파일은 `wal` 디렉토리에 128MB 세그먼트들로 나뉘어 저장된다. 이 파일에는 아직 컴팩션<sup>compaction</sup> 과정을 거치지 않은 원시 데이터가 들어있다. 그렇기 때문에 일반적인 블록 파일보다 사이즈가 훨씬 크다. 프로메테우스는 WAL 파일을 최소 3개는 유지한다. 트래픽이 많은 서버는 적어도 2시간짜리 원시 데이터를 유지하기 위해 WAL 파일을 3개 이상 보유할 수도 있다.

프로메테우스 서버의 데이터 디렉토리는 다음과 같이 구성된다:

```
./data
├── 01BKGV7JBM69T2G1BGBGM6KB12
│   └── meta.json
├── 01BKGTZQ1SYQJTR4PB43C8PD98
│   ├── chunks
│   │   └── 000001
│   ├── tombstones
│   ├── index
│   └── meta.json
├── 01BKGTZQ1HHWHV8FBJXW1Y3W0K
│   └── meta.json
├── 01BKGV7JC0RY8A6MACW02A2PJD
│   ├── chunks
│   │   └── 000001
│   ├── tombstones
│   ├── index
│   └── meta.json
├── chunks_head
│   └── 000001
└── wal
    ├── 000000002
    └── checkpoint.00000001
        └── 00000000
```

로컬 스토리지를 이용할 때는 클러스터링이나 복제가 불가능하다는 제약이 있다. 따라서 드라이브나 노드가 중단되면 자체적으로 확장하거나 내구성을 보장할 수 없으며, 단일 노드 데이터베이스처럼 관리해야 한다. 스토리지 가용성을 위해선 RAID를 사용하고, [스냅샷](../querying.api#snapshot)을 통해 백업해두는 걸 권장한다. 적절한 아키텍처만 적용해주면 로컬 스토리지에 수년간의 데이터를 보관할 수 있다.

아니면 [remote read/write API](../integrations#remote-endpoints-and-storage)를 통해 외부 저장소를 사용할 수도 있다. 이런 시스템들은 내구성이나 성능, 효율성 면에서 크게 갈리기 때문에 신중하게 평가해보고 사용해야 한다.

파일 형식에 관한 자세한 내용은 [TSDB 포맷](https://github.com/prometheus/prometheus/blob/release-2.32/tsdb/docs/format/README.md)을 참고해라.

---

## Compaction

처음에 만들었던 2시간짜리 블록은 시간이 지나면 백그라운드에서 좀더 긴 블록으로 압축<sup>compact</sup>된다.

컴팩션<sup>compaction</sup>을 마치면 보존 시간의 10%나 31일 중 더 작은 기간에 속하는 데이터들을 가지는 더 큰 블록이 만들어진다.

---

## Operational aspects

프로메테우스는 로컬 스토리지를 설정할 수 있는 다양한 플래그를 제공한다. 가장 중요한 플래그들은 다음과 같다:

- `--storage.tsdb.path`: 프로메테우스가 데이터베이스를 작성하는 위치. 디폴트는 `data/`다.
- `--storage.tsdb.retention.time`: 오래된 데이터를 제거하는 시점. 디폴트는 `15d`다. 이 플래그를 다른 값으로 설정하면 `storage.tsdb.retention`을 재정의한다.
- `--storage.tsdb.retention.size`: 스토리지 블록들을 최대로 보관할 바이트 수. 가장 오래된 데이터를 먼저 제거한다. 디폴트는 `0`이거나 비활성화돼있다. 지원하는 단위는 B, KB, MB, GB, TB, PB, EB다 (ex. "512MB"). 총 사이즈를 계산할 땐 WAL과 m-map으로 매핑한 청크도 포함시키지만, 보존 정책에 따라 데이터를 지울 때는 영구<sup>persistent</sup> 블록만 삭제한다. 따라서 디스크의 최소 요구 사항은 `wal`(WAL/Checkpoint) 디렉토리와 `chunks_head`(m-map으로 매핑한 헤드 청크) 디렉토리를 합쳤을 때 필요한 최대 공간이다 (2시간마다 최대치에 도달한다).
- `--storage.tsdb.retention`: Deprecated되었으며, `storage.tsdb.retention.time`을 사용한다.
- `--storage.tsdb.wal-compression`: WAL<sup>write-ahead log</sup> 압축을 활성화한다. 데이터에 따라 추가 CPU 부하는 거의 없이 WAL 사이즈가 절반으로 줄어들 수도 있다. 이 플래그는 2.11.0에서 추가됐으며, 2.20.0에선 기본적으로 활성화돼있다. 한 번이라도 활성화했다면 프로메테우스를 2.11.0 버전 미만으로 다운그레이드할 땐 WAL을 삭제해야 한다.

프로메테우스는 데이터를 저장할 때 샘플당 평균 1-2바이트만을 사용한다. 따라서 프로메테우스 서버의 용량을 계획할 땐 아래 있는 대략적인 공식을 활용할 수 있다:

```
needed_disk_space = retention_time_seconds * ingested_samples_per_second * bytes_per_sample
```

샘플의 수집 속도를 늦추려면 스크랩하는 시계열 수를 줄이거나 (타겟을 줄이거나, 타겟당 시계열 수를 줄이거나), 스크랩 간격을 늘리면 된다. 하지만 같은 시계열에 있는 샘플은 압축할 수 있기 때문에 시계열 수를 줄이는 게 효과가 더 좋을 거다.

어떤 이유에서든지 로컬 스토리지가 손상됐다면 가장 확실한 해결법은 프로메테우스를 종료한 다음 스토리지 디렉토리를 통으로 삭제하는 거다. 아니면 블록 디렉토리들을 개별적으로 삭제하거나, WAL 디렉토리를 삭제해봐도 좋다. 블록 디렉토리를 삭제한다면 디렉토리 하나당 대략 2시간의 데이터를 잃게된다. 다시 말하지만, 프로메테우스의 로컬 스토리지가 의도한 건 내구성이 강한 장기 스토리지가 아니다. 좀더 정교한 보존<sup>retention</sup> 정책이나 데이터 내구성은 외부 솔루션으로 제공한다.

> **주의:** POSIX와 호환되지 않는 파일 시스템은 손상됐을 때 복구가 불가능할 수 있으므로 프로메테우스의 로컬 스토리지로 지원하지 않는다. NFS 파일 시스템(AWS의 EFS 포함)은 지원하지 않는다. NFS는 POSIX와 호환은 가능하지만 구현체 대부분은 호환이 되지 않는다. 안정성을 위해선 웬만하면 로컬 파일 시스템을 사용하길 권장한다.

보존 정책에 시간과 사이즈를 모두 지정했을 땐 더 먼저 트리거된 정책을 사용한다.

만료된 블록은 백그라운드에서 정리된다. 만료된 블록을 제거하는 데는 최대 2시간이 소요될 수 있다. 블록은 반드시 완전히 만료된 이후에만 삭제돼야 한다.

---

## Remote storage integrations

프로메테우스는 로컬 스토리지를 사용하기 때문에 단일 노드까지만 확장할 수 있고, 내구성도 그만큼 제한적이다. 프로메테우스는 직접 스토리지를 클러스터링하기보단 원격 스토리지 시스템과 통합할 수 있는 인터페이스 셋을 제공한다.

### Overview

프로메테우스는 아래 있는 세 가지 방법으로 원격 스토리지 시스템과 통합할 수 있다:

- 프로메테우스는 원격 URL을 통해 수집할 샘플을 표준화된 형식으로 전송할 수 있다.
- 프로메테우스는 다른 프로메테우스 서버로부터 표준화된 형식으로 샘플을 받을 수 있다.
- 프로메테우스는 원격 URL에서 표준화된 형식으로 샘플 데이터를 읽어올 수 있다.

![Remote read and write architecture](./../../images/prometheus/remote_integrations.png)

read/write 프로토콜 모두 HTTP를 통해 통신하며, 데이터는 snappy 압축 알고리즘을 사용하는 프로토콜 버퍼로 인코딩한다. 이 프로토콜들은 아직까진 stable API로 여기지 않으며, 앞으로 프로메테우스와 원격 스토리지 사이에 있는 모든 홉에서 HTTP/2를 지원한다고 가정해도 무방하다고 여기지면 HTTP/2를 통해 gRPC를 사용하도록 변경될 수도 있다.

프로메테우스에서 원격 스토리지 설정을 통합하는 자세한 방법은 프로메테우스 설정 문서에서 [remote write](../configuration#remote_write), [remote read](../configuration#remote_read) 섹션을 참고해라.

내장돼있는 remote write receiver는 커맨드라인 플래그 `--enable-feature=remote-write-receiver`를 설정해주면 활성화할 수 있다. 활성화했다면 `/api/v1/write`를 remote write receiver 엔드포인트로 사용할 수 있다.

요청/응답 메세지에 대한 자세한 내용은 [원격 스토리지 프로토콜 버퍼 정의](https://github.com/prometheus/prometheus/blob/main/prompb/remote.proto)를 참고해라.

프로메테우스가 리모트 엔드포인트에서 데이터를 읽어들일 땐 레이블 셀럭터 셋과 시간 범위에 맞는 원시 시계열 데이터만 가져온다. 그렇더라도 이 원시 데이터에 대한 모든 PromQL 평가는 프로메테우스 자체에서 일어난다. 따라서 데이터를 처리하려면 질의하는 주체인 프로메테우스 서버에 필요한 모든 데이터를 먼저 로드해와야 하기 때문에, remote read 쿼리는 확장성 면에서 어느정도 제약이 있음을 의미한다. 그럼에도, PromQL 평가를 완전히 분산 처리하는 것은 당분간은 불가능하다고 판단했다.

### Existing integrations

통합을 지원하고 있는 원격 스토리지 시스템들을 알아보려면 [통합 문서](../integrations#remote-endpoints-and-storage)를 확인해봐라.

---

## Backfilling from OpenMetrics format

### Overview

[OpenMetrics](https://openmetrics.io/) 형식을 사용하는 데이터로 TSDB 블록을 생성하고 싶다면 backfilling을 이용하면 된다. 하지만 backfill은 주의해서 사용해야 하는데, 지난 3시간 가량의 데이터(현재 헤드 블록)는 프로메테우스가 아직 변경 중인 현재 헤드 블록과 겹칠 수 있으므로 이 데이터로 backfill을 진행하는 것은 위험하다. Backfilling은 각각 2시간 분량의 메트릭 데이터를 포함하는 TSDB 블록들을 새로 생성한다. 따라서 블록을 생성할 수 있는 메모리를 제한하게 된다. 2시간짜리 블록을 더 큰 블록으로 압축<sup>compaction</sup>하는 절차는 나중에 프로메테우스 서버 자체에서 진행된다.

대표적인 유스 케이스는 다른 모니터링 시스템이나 다른 시계열 데이터베이스에서 프로메테우스로 메트릭 데이터를 마이그레이션하는 케이스다. 이땐 먼저 소스 데이터를 아래에서 설명하는 backfilling에 필요한 입력 형식인 [OpenMetrics](https://openmetrics.io/) 포맷으로 변환해야 한다.

### Usage

Backfilling은 Promtool 커맨드라인을 통해 진행할 수 있다. Promtool은 블록들을 특정 디렉토리에 기록해준다. 이때 출력 디렉토리는 기본적으로 `./data/`를 사용하며, 변경하고 싶다면 원하는 출력 디렉토리 이름을 하위 명령어의 인자로 넘겨주면 된다.

```sh
promtool tsdb create-blocks-from openmetrics <input file> [<output directory>]
```

블록을 생성했다면 프로메테우스의 데이터 디렉토리로 옮겨라. 프로메테우스에 있는 기존 블록과 겹치는 부분이 있다면 `--storage.tsdb.allow-overlapping-blocks` 플래그를 설정해야 한다. 참고로, backfill로 만든 데이터도 마찬가지로 프로메테우스 서버에 설정해둔 보존<sup>retention</sup> 정책에 따라 관리된다 (시간이나 사이즈 기준으로).

#### Longer Block Durations

기본적으로 promtool은 디폴트 블록 기간(2h)을 사용해서 블록을 생성한다. 이 동작은 적용하기에도 가장 범용적이며, 맞는 정책이기도 하다. 하지만 장기간에 걸친 데이터를 가지고 backfill을 진행할 땐, 블록 기간을 좀더 크게 잡고 backfill을 빠르게 진행하고, 이후 TSDB가 추가로 컴팩션<sup>compaction</sup>을 진행하지 않게 만드는 게 차라리 유리할 수도 있다.

`--max-block-duration` 플래그를 사용하면 직접 블록의 최대 기간을 설정할 수 있다. 그러면 backfilling 툴이 이 값보단 크지 않게 적당한 블록 기간을 선택해줄 거다.

더 큰 블록을 사용하면 대량의 데이터 셋을 backfilling할 때 성능을 개선할 수 있지만 단점도 존재한다. 시간 기반 보존<sup>retention</sup> 정책을 사용한다면 (계속해서 커질 수 있는) 블록의 샘플이 하나라도 보존 정책 내에 들어간다면 전체 블록을 유지해야 한다. 반대로 사이즈 기반 보존<sup>retention</sup> 정책에선 TSDB가 사이즈 제한을 약간만 넘어가더라도 전체 블록을 제거한다.

따라서 블록 기간을 늘려 backfilling으로 블록을 더 적게 만든다면 반드시 주의가 필요하며, 프로덕션 인스턴스에는 권장하지 않는다.

---

## Backfilling for Recording Rules

### Overview

Recording rule을 새로 만들게 되면 이 rule에는 과거 데이터가 존재하지 않는다. Recording rule 데이터는 생성한 시점 이후부터만 존재한다. `promtool`을 사용하면 지난 데이터로 recording rule 데이터를 생성할 수 있다.

### Usage

모든 옵션을 조회해보려면 `$ promtool tsdb create-blocks-from rules --help`를 실행해라.

사용 예시:

```sh
$ promtool tsdb create-blocks-from rules \
    --start 1617079873 \
    --end 1617097873 \
    --url http://mypromserver.com:9090 \
    rules.yaml rules2.yaml
```

이때 제공하는 recording rule 파일은 일반적인 [프로메테우스 rule 파일](../recording-rules)이어야 한다.

`promtool tsdb create-blocks-from rules` 명령어를 실행하면 recording rule 파일들에 있는 모든 rule에 대한 과거 데이터가 담긴 블록들을 가지고 있는 디렉토리를 출력한다. 출력 디렉토리는 기본적으로 `data/`를 사용한다. 새로 만들어진 블록 데이터를 사용하려면 `--storage.tsdb.allow-overlapping-blocks` 플래그를 활성화해서 실행 중인 프로메테우스 인스턴스의 데이터 디렉토리 `storage.tsdb.path`로 블록을 옮겨야 한다. 블록을 옮기고 나면 새 블록들은 다음번 압축<sup>compaction</sup>을 진행할 때 기존 블록들과 병합된다.

### Limitations

- start/end 타임이 겹치는 rule backfiller를 여러 번 실행한다면, rule backfiller가 실행될 때마다 같은 데이터를 가지고 있는 블록들이 만들어진다.
- recording rule 파일에 있는 모든 rule을 평가하게 된다.
- recording rule 파일에 `interval`을 설정했다면, rule backfill 커맨드에서 설정하는 `eval-interval` 플래그보다 우선시한다.
- recording rule 파일에 alert를 정의했더라도 현재로썬 무시한다.
- rule들이 같은 그룹에 속하더라도 앞선 rule들의 결과를 바라볼 수 없다. 즉, rule들은 backfill이 진행 중인 다른 rule을 참조할 수 없다. 이때는 backfill을 여러 번 진행해서 의존 데이터를 먼저 생성하는 식으로 해결해야 한다 (그리고 의존 데이터를 프로메테우스 API에서 접근할 수 있게 프로메테우스 서버 데이터 디렉토리로 이동해줘야 한다).
