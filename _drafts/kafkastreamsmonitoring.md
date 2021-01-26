

### Streams Monitoring

카프카 스트림즈 인스턴스엔 모든 프로듀서와 컨슈머 메트릭뿐 아니라, 스트림즈 전용 추가 메트릭도 있다. 기본적으로 카프카 스트림즈는 `debug`, `info`, 이렇게 두 가지 기록 레벨을 사용한다.

메트릭은 4-layer 계층 구조를 가진다. 최상위에는 기동한 각 카프카 스트림즈 클라이언트에 대한 클라이언트 레벨 메트릭이 있다. 각 클라이언트에는 자체 메트릭을 가지고 있는 스트림 스레드들이 있다. 각 스트림 스레드는 또 자체 메트릭을 가지는 태스크들이 있다. 각 태스크엔 또 다시 자체 메트릭을 가지는 많은 프로세서 노드가 있다. 태스크는 자체 메트릭을 가지는 여러 가지 상태 저장소와 레코드 캐시도 존재한다.

수집할 메트릭을 지정하려면 아래 설정 옵션을 사용해라:

```properties
metrics.recording.level="info"
```

#### Client Metrics

아래 있는 모든 메트릭은 `info` 레벨로 기록한다:

| METRIC/ATTRIBUTE NAME | DESCRIPTION                                                  | MBEAN NAME                                            |
| :-------------------- | :----------------------------------------------------------- | :---------------------------------------------------- |
| version               | 카프카 스트림즈 클라이언트 버전.                             | kafka.streams:type=stream-metrics,client-id=([-.\w]+) |
| commit-id             | 버전이 카프카 스트림즈 클라이언트의 커밋 ID를 제어한다.      | kafka.streams:type=stream-metrics,client-id=([-.\w]+) |
| application-id        | 카프카 스트림즈 클라이언트의 어플리케이션 ID.                | kafka.streams:type=stream-metrics,client-id=([-.\w]+) |
| topology-description  | 카프카 스트림즈 클라이언트에서 실행하는 토폴로지에 대한 설명. | kafka.streams:type=stream-metrics,client-id=([-.\w]+) |
| state                 | 카프카 스트림즈 클라이언트의 상태.                           | kafka.streams:type=stream-metrics,client-id=([-.\w]+) |

#### Thread Metrics

아래 있는 모든 메트릭은 `info` 레벨로 기록한다:

| METRIC/ATTRIBUTE NAME | DESCRIPTION                                                  | MBEAN NAME                                                   |
| :-------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| commit-latency-avg    | 이 스레드에서 실행 중인 모든 태스크의 평균 커밋 실행 시간 (ms). | kafka.streams:type=stream-thread-metrics,thread-id=([-.\w]+) |
| commit-latency-max    | 이 스레드에서 실행 중인 모든 태스크의 최대 커밋 실행 시간 (ms). | kafka.streams:type=stream-thread-metrics,thread-id=([-.\w]+) |
| poll-latency-avg      | 컨슈머 폴링의 평균 실행 시간 (ms).                           | kafka.streams:type=stream-thread-metrics,thread-id=([-.\w]+) |
| poll-latency-max      | 컨슈머 폴링의 최대 실행 시간 (ms).                           | kafka.streams:type=stream-thread-metrics,thread-id=([-.\w]+) |
| process-latency-avg   | process의 평균 실행 시간 (ms).                               | kafka.streams:type=stream-thread-metrics,thread-id=([-.\w]+) |
| process-latency-max   | process의 최대 실행 시간 (ms).                               | kafka.streams:type=stream-thread-metrics,thread-id=([-.\w]+) |
| punctuate-latency-avg | punctuate의 평균 실행 시간 (ms).                             | kafka.streams:type=stream-thread-metrics,thread-id=([-.\w]+) |
| punctuate-latency-max | punctuate의 최대 실행 시간 (ms)                              | kafka.streams:type=stream-thread-metrics,thread-id=([-.\w]+) |
| commit-rate           | 초당 평균 커밋 횟수.                                         | kafka.streams:type=stream-thread-metrics,thread-id=([-.\w]+) |
| commit-total          | 커밋을 호출한 총 횟수.                                       | kafka.streams:type=stream-thread-metrics,thread-id=([-.\w]+) |
| poll-rate             | 초당 평균 컨슈머 poll 호출 횟수.                             | kafka.streams:type=stream-thread-metrics,thread-id=([-.\w]+) |
| poll-total            | 컨슈머 poll을 호출한 총 횟수.                                | kafka.streams:type=stream-thread-metrics,thread-id=([-.\w]+) |
| process-rate          | 초당 처리한 평균 레코드 수.                                  | kafka.streams:type=stream-thread-metrics,thread-id=([-.\w]+) |
| process-total         | 처리한 총 레코드 갯수.                                       | kafka.streams:type=stream-thread-metrics,thread-id=([-.\w]+) |
| punctuate-rate        | 초당 평균 punctuate 호출 횟수.                               | kafka.streams:type=stream-thread-metrics,thread-id=([-.\w]+) |
| punctuate-total       | punctuate를 호출한 총 횟수.                                  | kafka.streams:type=stream-thread-metrics,thread-id=([-.\w]+) |
| task-created-rate     | 초당 생성한 평균 태스크 수.                                  | kafka.streams:type=stream-thread-metrics,thread-id=([-.\w]+) |
| task-created-total    | 생성한 총 태스크 수.                                         | kafka.streams:type=stream-thread-metrics,thread-id=([-.\w]+) |
| task-closed-rate      | 초당 종료한 평균 태스크 수.                                  | kafka.streams:type=stream-thread-metrics,thread-id=([-.\w]+) |
| task-closed-total     | 종료한 총 태스크 수.                                         | kafka.streams:type=stream-thread-metrics,thread-id=([-.\w]+) |

#### Task Metrics

아래 있는 메트릭은 dropped-records-rate와 dropped-records-total을 제외하고는 모두 `debug` 레벨로 기록한다. 이 두 메트릭은 `info`로 기록한다:

| METRIC/ATTRIBUTE NAME     | DESCRIPTION                                                  | MBEAN NAME                                                   |
| :------------------------ | :----------------------------------------------------------- | :----------------------------------------------------------- |
| process-latency-avg       | process의 평균 실행 시간 (ns).                               | kafka.streams:type=stream-task-metrics,thread-id=([-.\w]+),task-id=([-.\w]+) |
| process-latency-max       | process의 평균 최대 시간 (ns).                               | kafka.streams:type=stream-task-metrics,thread-id=([-.\w]+),task-id=([-.\w]+) |
| process-rate              | 이 태스크의 모든 소스 프로세서 노드에서 처리된 초당 평균 레코드 수. | kafka.streams:type=stream-task-metrics,thread-id=([-.\w]+),task-id=([-.\w]+) |
| process-total             | 이 태스크의 모든 소스 프로세서 노드에서 처리된 총 레코드 수. | kafka.streams:type=stream-task-metrics,thread-id=([-.\w]+),task-id=([-.\w]+) |
| commit-latency-avg        | 평균 커밋 실행 시간 (ms).                                    | kafka.streams:type=stream-task-metrics,thread-id=([-.\w]+),task-id=([-.\w]+) |
| commit-latency-max        | 최대 커밋 실행 시간 (ms).                                    | kafka.streams:type=stream-task-metrics,thread-id=([-.\w]+),task-id=([-.\w]+) |
| commit-rate               | 초당 평균 커밋 호출 횟수.                                    | kafka.streams:type=stream-task-metrics,thread-id=([-.\w]+),task-id=([-.\w]+) |
| commit-total              | 커밋을 호출한 총 횟수.                                       | kafka.streams:type=stream-task-metrics,thread-id=([-.\w]+),task-id=([-.\w]+) |
| record-lateness-avg       | 관찰된 평균 레코드 지연 시간 (스트림 시간 - 레코드 타임스탬프). | kafka.streams:type=stream-task-metrics,thread-id=([-.\w]+),task-id=([-.\w]+) |
| record-lateness-max       | 관찰된 최대 레코드 지연 시간 (스트림 시간 - 레코드 타임스탬프). | kafka.streams:type=stream-task-metrics,thread-id=([-.\w]+),task-id=([-.\w]+) |
| enforced-processing-rate  | 초당 평균 강제 처리 횟수.                                    | kafka.streams:type=stream-task-metrics,thread-id=([-.\w]+),task-id=([-.\w]+) |
| enforced-processing-total | 처리를 강제한 총 횟수.                                       | kafka.streams:type=stream-task-metrics,thread-id=([-.\w]+),task-id=([-.\w]+) |
| dropped-records-rate      | 이 태스크 내에서 드랍된 평균 레코드 수.                      | kafka.streams:type=stream-task-metrics,thread-id=([-.\w]+),task-id=([-.\w]+) |
| dropped-records-total     | 이 태스크 내에서 드랍된 레코드의 총 갯수.                    | kafka.streams:type=stream-task-metrics,thread-id=([-.\w]+),task-id=([-.\w]+) |

#### Processor Node Metrics

아래 있는 메트릭들은 특정 타입의 노드에서만 사용할 수 있다. 즉, process-rate와 process-total은 소스 프로세서 노드에서만, suppression-emit-rate와 suppression-emit-total은 suppression operation 노드에서만 수집한다. 모든 메트릭은 `debug` 레벨로 기록한다:

| METRIC/ATTRIBUTE NAME  | DESCRIPTION                                                  | MBEAN NAME                                                   |
| :--------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| process-rate           | 초당 소스 프로세서 노드에서 처리한 평균 레코드 수.           | kafka.streams:type=stream-processor-node-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),processor-node-id=([-.\w]+) |
| process-total          | 초당 소스 프로세서 노드에서 처리한 레코드의 총 갯수.         | kafka.streams:type=stream-processor-node-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),processor-node-id=([-.\w]+) |
| suppression-emit-rate  | suppression operation 노드에서 다운스트림으로 방출한 레코드의 비율. | kafka.streams:type=stream-processor-node-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),processor-node-id=([-.\w]+) |
| suppression-emit-total | suppression operation 노드에서 다운스트림으로 방출한 레코드의 총 갯수. | kafka.streams:type=stream-processor-node-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),processor-node-id=([-.\w]+) |

##### State Store Metrics

아래 있는 모든 메트릭은 `debug` 레벨로 기록한다. 사용자가 커스텀한 상태 저장소에선 `store-scope` 값은 `StoreSupplier#metricsScope()`로 지정된다. 현재 제공하는 빌트인 상태 저장소에선 다음과 같다:

- `in-memory-state`
- `in-memory-lru-state`
- `in-memory-window-state`
- `in-memory-suppression` (suppression 버퍼용)
- `rocksdb-state` (for RocksDB backed key-value store)
- `rocksdb-window-state` (for RocksDB backed window store)
- `rocksdb-session-state` (for RocksDB backed session store)

suppression-buffer-size-avg, suppression-buffer-size-max, suppression-buffer-count-avg, suppression-buffer-count-max 메트릭은 suppression 버퍼에서만 가능하다. suppression 버퍼는 그 외 나머지 모든 메트릭은 사용할 수 없다.

| METRIC/ATTRIBUTE NAME        | DESCRIPTION                                                  | MBEAN NAME                                                   |
| :--------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| put-latency-avg              | 평균 put 실행 시간 (ns).                                     | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+) |
| put-latency-max              | 최대 put 실행 시간 (ns).                                     | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+) |
| put-if-absent-latency-avg    | 평균 put-if-absent 실행 시간 (ns).                           | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+) |
| put-if-absent-latency-max    | 최대 put-if-absent 실행 시간 (ns).                           | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+) |
| get-latency-avg              | 평균 get 실행 시간 (ns).                                     | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+) |
| get-latency-max              | 최대 get 실행 시간 (ns).                                     | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+) |
| delete-latency-avg           | 평균 delete 실행 시간 (ns).                                  | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+) |
| delete-latency-max           | 최대 delete 실행 시간 (ns).                                  | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+) |
| put-all-latency-avg          | 평균 put-all 실행 시간 (ns).                                 | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+) |
| put-all-latency-max          | 최대 put-all 실행 시간 (ns).                                 | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+) |
| all-latency-avg              | 모든 연산의 평균 실행 시간 (ns).                             | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+) |
| all-latency-max              | 모든 연산의 최대 실행 시간 (ns).                             | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+) |
| range-latency-avg            | 평균 range 실행 시간 (ns).                                   | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+) |
| range-latency-max            | 최대 put-all 실행 시간 (ns).                                 | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+) |
| flush-latency-avg            | 평균 flush 실행 시간 (ns).                                   | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+) |
| flush-latency-max            | 최대 flush 실행 시간 (ns).                                   | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+) |
| restore-latency-avg          | 평균 restore 실행 시간 (ns).                                 | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+) |
| restore-latency-max          | 최대 restore 실행 시간 (ns).                                 | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+) |
| put-rate                     | 이 저장소의 평균 put 속도.                                   | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+) |
| put-if-absent-rate           | 이 저장소의 평균 put-if-absent 속도.                         | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+) |
| get-rate                     | 이 저장소의 평균 get 속도.                                   | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+) |
| delete-rate                  | 이 저장소의 평균 delete 속도.                                | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+) |
| put-all-rate                 | 이 저장소의 평균 put-all 속도.                               | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+) |
| all-rate                     | 이 저장소의 모든 연산 평균 속도.                             | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+) |
| range-rate                   | 이 저장소의 평균 range 속도.                                 | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+) |
| flush-rate                   | 이 저장소의 평균 flush 속도.                                 | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+) |
| restore-rate                 | 이 저장소의 평균 restore 속도.                               | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+) |
| suppression-buffer-size-avg  | 샘플링 윈도우동안 버퍼링한 데이터 총 사이즈의 평균치 (바이트). | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),in-memory-suppression-id=([-.\w]+) |
| suppression-buffer-size-max  | 샘플링 윈도우 동안 버퍼링한 데이터 총 사이즈의 최대치 (바이트). | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),in-memory-suppression-id=([-.\w]+) |
| suppression-buffer-count-avg | 샘플링 윈도우 동안 버퍼링한 평균 레코드 수.                  | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),in-memory-suppression-id=([-.\w]+) |
| suppression-buffer-count-max | 샘플링 윈도우 동안 버퍼링한 최대 레코드 수.                  | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),in-memory-suppression-id=([-.\w]+) |

#### RocksDB Metrics

아래 있는 모든 메트릭은 `debug` 레벨로 기록한다. 이 메트릭들은 RocksDB 상태 저장소에서 1분 간격으로 수집한다. 타임 윈도우와 세션 윈도우에 따라 집계할 때처럼, 상태 저장소가 RocksDB 인스턴스로 여러 개로 구성돼 있을 땐, 각 메트릭은 상태 저장소의 RocksDB 인스턴스들에 대한 집계를 보고한다. 현재 빌트인 RocksDB 상태 저장소의 `store-scope`는 다음과 같다:

- `rocksdb-state` (for RocksDB backed key-value store)
- `rocksdb-window-state` (for RocksDB backed window store)
- `rocksdb-session-state` (for RocksDB backed session store)

| METRIC/ATTRIBUTE NAME         | DESCRIPTION                                                  | MBEAN NAME                                                   |
| :---------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| bytes-written-rate            | RocksDB 상태 저장소에 쓰여진 초당 평균 바이트.               | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+) |
| bytes-written-total           | RocksDB 상태 저장소에 쓰여진 총 바이트.                      | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+) |
| bytes-read-rate               | The average number of bytes read per second from the RocksDB state store. | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+) |
| bytes-read-total              | The total number of bytes read from the RocksDB state store. | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+) |
| memtable-bytes-flushed-rate   | The average number of bytes flushed per second from the memtable to disk. | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+) |
| memtable-bytes-flushed-total  | The total number of bytes flushed from the memtable to disk. | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+) |
| memtable-hit-ratio            | The ratio of memtable hits relative to all lookups to the memtable. | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+) |
| block-cache-data-hit-ratio    | The ratio of block cache hits for data blocks relative to all lookups for data blocks to the block cache. | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+) |
| block-cache-index-hit-ratio   | The ratio of block cache hits for index blocks relative to all lookups for index blocks to the block cache. | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+) |
| block-cache-filter-hit-ratio  | The ratio of block cache hits for filter blocks relative to all lookups for filter blocks to the block cache. | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+) |
| write-stall-duration-avg      | The average duration of write stalls in ms.                  | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+) |
| write-stall-duration-total    | The total duration of write stalls in ms.                    | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+) |
| bytes-read-compaction-rate    | 컴팩션에서 초당 읽은 평균 바이트.                            | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+) |
| bytes-written-compaction-rate | 컴팩션에서 초당 쓰여진 평균 바이트.                          | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+) |
| number-open-files             | 현재 열린 파일 수.                                           | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+) |
| number-file-errors-total      | 에러가 발생한 파일의 총 갯수.                                | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+) |

#### Record Cache Metrics

아래 있는 모든 메트릭은 `debug` 레벨로 기록한다:

| METRIC/ATTRIBUTE NAME | DESCRIPTION                                                  | MBEAN NAME                                                   |
| :-------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| hit-ratio-avg         | 전체 캐시 읽기 요청 대비 캐시 히트율로 정의하는 평균 캐시 히트율. | kafka.streams:type=stream-record-cache-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),record-cache-id=([-.\w]+) |
| hit-ratio-min         | 최소 캐시 히트율.                                            | kafka.streams:type=stream-record-cache-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),record-cache-id=([-.\w]+) |
| hit-ratio-max         | 최대 캐시 히트율.                                            | kafka.streams:type=stream-record-cache-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),record-cache-id=([-.\w]+) |



