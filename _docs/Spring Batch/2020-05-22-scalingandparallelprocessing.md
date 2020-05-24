---
title: Scaling and Parallel Processing
category: Spring Batch
order: 8
permalink: /Spring%20Batch/scalingandparallelprocessing/
---

> [스프링 배치 공식 reference](https://docs.spring.io/spring-batch/docs/4.2.x/reference/html/index-single.html#scalability) 를 한글로 번역한 문서입니다.
>
> 전체 목차는 [여기](https://godekdls.github.io/Spring%20Batch/contents/) 에 있습니다.

### 목차

- [7.1. Multi-threaded Step](#71-multi-threaded-step)
- [7.2. Parallel Steps](#72-parallel-steps)
- [7.3. Remote Chunking](#73-remote-chunking)
- [7.4. Partitioning](#74-partitioning)
  + [7.4.1. PartitionHandler](#741-partitionhandler)
  + [7.4.2. Partitioner](#74-partitioning)
  + [7.4.3. Binding Input Data to Steps](#743-binding-input-data-to-steps)

배치는 job 하나를 싱글 쓰레드로 띄워도 충분한 경우가 많기 때문에
더 복잡한 구현을 생각하기 전 싱글 쓰레드를 먼저 고려해보는 게 좋다.
처음엔 간단하게 구현해서 실제 환경에서 job 성능을 테스트해 보고
요구사항을 충족시킬 수 있는지 지 점검해 봐라.
표준 하드웨어만으로 수백 메가 바이트에 달하는 파일을 1분안에 처리할 수 있을 것이다. 

병렬 처리로 job을 개발할 준비가 되었다면,
여기서 다루는 (일부는 다른 곳에서 설명하지만) 스프링 배치의 다양한 옵션이 도움이 될 것이다.
고 수준에서 보면 병렬 처리에는 두 가지 모델이 있다:

- 싱글 프로세스, 멀티 쓰레드
- 멀티 프로세스

이 두 모델은 아래 카테고리로 나뉜다:

- [Multi-threaded Step](#71-multi-threaded-step) (싱글 프로세스)
- [Parallel Steps](#72-parallel-steps) (싱글 프로세스)
- [Remote Chunking of Step](#73-remote-chunking) (멀티 프로세스)
- [Partitioning a Step](#74-partitioning) (싱글 or 멀티 프로세스)

가장 먼저 싱글 프로세스 옵션을 설명한다.
그 다음 멀티 프로세스 옵션을 설명하겠다.

## 7.1. Multi-threaded Step

병렬 처리를 시작하는 가장 쉬운 방법은 step 설정에 `TaskExecutor`를 추가하는 것이다. 

자바 설정을 사용한다면 아래 예시처럼 step에 `TaskExecutor`를 추가할 수 있다:

```java
@Bean
public TaskExecutor taskExecutor(){
    return new SimpleAsyncTaskExecutor("spring_batch");
}

@Bean
public Step sampleStep(TaskExecutor taskExecutor) {
	return this.stepBuilderFactory.get("sampleStep")
				.<String, String>chunk(10)
				.reader(itemReader())
				.writer(itemWriter())
				.taskExecutor(taskExecutor)
				.build();
}
```

메소드에 넘겨준 `taskExecutor`는 빈으로 정의된 `TaskExecutor` 인터페이스 구현체다.
[TaskExecutor](https://docs.spring.io/spring/docs/current/javadoc-api/org/springframework/core/task/TaskExecutor.html)
는 표준 스프링 인터페이스이므로, 구현체 상세 내용은 스프링 유저 가이드를 참고하라.
`SimpleAsyncTaskExecutor`는 가장 간단한 멀티 쓰레드 `TaskExecutor`다.

위에서 설정한 `Step`은 여러 쓰레드를 실행해서
데이터를 읽고, 처리하고, 청크단위로 쓴다 (commit interval 만큼).
처리할 아이템 순서는 고정되어 있지 않으며,
단일 쓰레드일 때처럼 청크에 연속적인 아이템이 들어있지 않다는 것에 주의하라.
task executor에 있는 limit 설정 외에 (쓰레드 풀에 자원을 반환할지 등)
tasklet에도 디폴트 값이 4인 throttle limit이 있다.
쓰레드 풀을 충분히 사용하고 싶으면 이 값을 늘려야 한다.

자바 기반 설정을 사용한다면 빌더로 throttle limit을 수정할 수 있다: 

```java
@Bean
public Step sampleStep(TaskExecutor taskExecutor) {
	return this.stepBuilderFactory.get("sampleStep")
				.<String, String>chunk(10)
				.reader(itemReader())
				.writer(itemWriter())
				.taskExecutor(taskExecutor)
				.throttleLimit(20)
				.build();
}
```

step에 `DataSource`같이 커넥션 풀을 사용하는 리소스가 있다면
동시 처리를 제한 할 수 있다는 점도 주의해라.
이런 리소스 풀은 최소한 step에서 동시에 실행할 쓰레드 수만큼 설정해야 한다.

일반적인 배치를 위해 지원하는 `Step` 구현체를 멀티 쓰레드에서 사용하려면 현실적인 제약이 있다.
`Step`에 참여하는 객체는(reader와 writer같은) 상태가 있는(stateful) 경우도 많다.
상태를 쓰레드 별로 분리하지 않으면 이 컴포넌트를 멀티 쓰레드 `Step`에서 사용할 수 없다.
특히 스프링 배치가 지원하는 reader, writer 대부분은 멀티 쓰레드를 고려해 설계하지 않았다.
하지만 상태가 없거나(stateless) thread safe한 reader와 writer를 사용하면 멀티 쓰레드도 가능하며,
[Spring Batch Samples](https://github.com/spring-projects/spring-batch/tree/master/spring-batch-samples) 에
처리 식별자([Preventing State Persistence](https://godekdls.github.io/Spring%20Batch/itemreadersanditemwriters/#613-preventing-state-persistence) 참고)로
데이터베이스 입력 테이블에서 이미 처리된 아이템을 추적하는 예제(parallelJob)가 있다.

스프링 배치는 많은 `ItemWriter`, `ItemReader`를 제공하는데,
보통은 Javadoc에 해당 클래스가 thread safe한지 아닌지
혹은 동시성 이슈를 피하려면 어떻게 해야하는지 나와있다.
Javadoc에 정보가 없다면 구현체에 상태가 있는지 확인해보면 된다.
thread safe하지 않은 reader는 `SynchronizedItemStreamReader`로 감싸거나
직접 동기화 해주는 객체(delegator)를 만들어 reader에게 위임하면 된다.
`read()` 호출을 동기화하면 되고,
process와 write가 가장 무거운 작업이라면 싱글 쓰레드에서보다 훨씬 빨라질 것이다.

## 7.2. Parallel Steps

병렬 처리가 필요한 어플리케이션 로직은
각 역할을 여러 step으로 나눌 수만 있으면 싱글 프로세스로도 병렬화할 수 있다.
병렬 step은 설정하고 사용하기도 쉽다.

아래 예제처럼 자바 기반 설정을 사용한다면
쉽게 `(step1,step2)`와 `step3`를 병렬로 처리하도록 만들 수 있다:

 ```java
@Bean
public Job job() {
    return jobBuilderFactory.get("job")
        .start(splitFlow())
        .next(step4())
        .build()        //builds FlowJobBuilder instance
        .build();       //builds Job instance
}

@Bean
public Flow splitFlow() {
    return new FlowBuilder<SimpleFlow>("splitFlow")
        .split(taskExecutor())
        .add(flow1(), flow2())
        .build();
}

@Bean
public Flow flow1() {
    return new FlowBuilder<SimpleFlow>("flow1")
        .start(step1())
        .next(step2())
        .build();
}

@Bean
public Flow flow2() {
    return new FlowBuilder<SimpleFlow>("flow2")
        .start(step3())
        .build();
}

@Bean
public TaskExecutor taskExecutor(){
    return new SimpleAsyncTaskExecutor("spring_batch");
}
```

task executor 설정으로 각 flow를 실행할 때 사용할 `TaskExecutor` 구현체를 지정한다.
디폴트는 `SyncTaskExecutor`지만
step을 병렬로 실행하려면 비동기(asynchronous) `TaskExecutor`가 필요하다.
모든 flow는 job이 종료 상태를 집계하고 변경하기 전에 끝나야 한다는 것에 주의하라.

자세한 내용은 [Split Flows](https://godekdls.github.io/Spring%20Batch/configuringastep/#535-split-flows)
를 참고하라.

## 7.3. Remote Chunking

remote chunking은 `Step`을 여러 프로세스로 나눠서 다른 미들웨어로 의사소통한다.
아래 이미지는 이 패턴을 나타내고 있다:

![Remote Chunking](./../../images/springbatch/remote-chunking.png)

매니저 컴포넌트는 싱글 프로세스고 워커는 멀티 리모트 프로세스다. 
이 패턴은 매니저에 병목이 없어야 가장 잘 동작하므로
반드시 process가 read보다 훨씬 무거운 작업일 때 사용해야 한다(현실에서 보통 그러하듯).

매니저는 아이템 청크를 미들웨어에 전송하는
`ItemWriter`로 만든 스프링 배치 `Step`이다.
워커는 어떤 미들웨어에서도 사용할 수 있는 표준 리스너이며
(예를 들어 JMS를 사용한다면 `MesssageListener`를 사용할 수 있다),
`ChunkProcessor` 인터페이스를 통해 표준 `ItemWriter`나
혹은 `ItemWriter`, `ItemProcessor` 조합으로
청크 아이템을 처리한다.
이 패턴을 사용하면 좋은 점은 이미 있는 reader, processor, writer를
사용할 수 있다는 것이다 (로컬에서 step을 실행할 때와 동일하다).
아이템을 동적으로 나누고 미들웨어로 작업을 공유하기 때문에
모든 리스너가 바쁘다면 자동으로 로드 밸런싱한다.

미들웨어는 내구성이 있어야하며, 각 메세지를 컨슈머 하나에 전달한다는 걸 보장해야 한다.
JMS가 가장 좋은 후보지만, 그리드 컴퓨팅이나 공유 메모리 공간에 사용하는
다른 옵션도 있다 (JavaSpaces 같은).

자세한 정보는 
[Spring Batch Integration - Remote Chunking](https://godekdls.github.io/Spring%20Batch/springbatchintegration/#remote-chunking)
르 참조하라.

## 7.4. Partitioning

스프링 배치는 `Step`을 나눠서 원격으로 실행할 수 있는 SPI를 제공한다.
여기선 `Step` 인스턴스를 리모트로 실행하므로,
로컬로 처리할 때 처럼 쉽게 설정할 수 있다.
패턴을 이미지로 나타내면 다음과 같다:

![Partitioning](./../../images/springbatch/partitioning-overview.png)

왼쪽에 있는 `Job`은 일련의 `Step` 인스턴스로 실행되며,
`Step` 중 하나는 매니저라고 표기돼 있다.
모든 워커는 사실상 매니저를 대신해 `Job`과 동일한 결과를 얻는 같은 `Step` 인스턴스다.
전형적인 워커는 원격 서비스지만 로컬 쓰레드로 실행할 수도 있다.
이 패턴에서 매니저가 워커로 보낸 메세지는 내구성이나 전달을 보장하지 않아도 된다.
`JobRepository`에 있는 스프링 배치 메타 데이터가
`Job`을 실행할 때마다 각 워커를 한 번씩만 실행했다는 걸 보장해준다. 

스프링 배치의 SPI는 `Step`의 특별한 구현체(`PartitionStep`)와
특정 환경에 따라 구현해야 하는 두 전략 인터페이스로 구성된다.
전략 인터페이스는 `PartitionHandler`와 `StepExecutionSplitter`이며,
아래 있는 시퀀스 다이어그램에서 그 역할을 알 수 있다:

![Partitioning SPI](./../../images/springbatch/partitioning-spi.png)

여기선 오른쪽에 있는 `Step`이 “remote” 워커이므로 
step에 많은 오브젝트나 프로세스가 있을 것이고,
`PartitionStep`가 실행을 주도한다.

다음은 자바 기반으로 `PartitionStep`을 설정하는 법이다: 

```java
@Bean
public Step step1Manager() {
    return stepBuilderFactory.get("step1.manager")
        .<String, String>partitioner("step1", partitioner())
        .step(step1())
        .gridSize(10)
        .taskExecutor(taskExecutor())
        .build();
}
```

멀티 쓰레드 step의 `throttle-limit`과 유사하게, 
`grid-size` 속성으로 task executor가 하나의 step에
너무 많은 요청을 보내지 않게 만들 수 있다.

[Spring Batch Samples](https://github.com/spring-projects/spring-batch/tree/master/spring-batch-samples/src/main/resources/jobs)
단위 테스트에 간단한 예시가 있으니 복사해 가거나 확장해서 사용해도 된다.
(`Partition*Job.xml` 설정 참고).

스프링 배치는 각 파티션의 step을 "step1:partition0" 등으로 이름을 매긴다. 
일관성을 위해 매니저 step을 "step1:manager"라고 부르기도 한다.
step에 별칭(alias)을 지정할 수도 있다
(`id`대신 `name` 속성을 지정함으로써).

### 7.4.1. PartitionHandler

`PartitionHandler`는 원격이나 그리드 환경 fabric을 처리하기 위한 컴포넌트다.
DTO같은 fabric에서 사용하는 특정 형식으로 감싼 
원격 `Step` 인스턴스로 `StepExecution` 요청을 보낼 수 있다.
이 핸들러는 입력 데이터를 나누는 법이나 각 `Step` 결과를
어떻게 합치는지 알 필요 없다.
복원력(resilience)이나 패일 오버(failover)는 fabric이 지원하기 때문에
핸들러는 대체로 신경 쓰지 않아도 된다.
스프링 배치는 어떤 fabric을 사용하더라도 재시작 가능한 구조를 제공한다.
실패한 `Job`은 항상 재시작할 수 있으며 실패한 `Step`만 재실행한다.

`PartitionHandler` 인터페이스는 fabric 유형에 따라 다양하게 구현할 수 있으며,
fabric 유형은
간단한 RMI 리모팅, EJB 리모팅, 커스텀 웹 서비스, JMS, Java Spaces,
공유 메모리 그리드(Terracotta나 Coherence 같은), 
그리드 execution fabrics (GridGain) 등이 있다.
스프링 배치는 상표가 있는 그리드나 리모팅 fabric 구현체는 제공하지 않는다.

하지만 스프링의 `TaskExecutor` 전략을 사용해 
각 `Step` 인스턴스를 로컬에서 여러 쓰레드로 실행하는
`PartitionHandler` 구현체를 제공한다.
이 구현체는 `TaskExecutorPartitionHandler`다.

아래 보이는 것처럼
자바 설정을 사용해서 명시적으로 `TaskExecutorPartitionHandler`를 지정할 수 있다:

```java
@Bean
public Step step1Manager() {
    return stepBuilderFactory.get("step1.manager")
        .partitioner("step1", partitioner())
        .partitionHandler(partitionHandler())
        .build();
}

@Bean
public PartitionHandler partitionHandler() {
    TaskExecutorPartitionHandler retVal = new TaskExecutorPartitionHandler();
    retVal.setTaskExecutor(taskExecutor());
    retVal.setStep(step1());
    retVal.setGridSize(10);
    return retVal;
}
```

`gridSize` 속성이 step을 몇 개로 나눠 실행할 지 결정하므로
`TaskExecutor`의 쓰레드 풀 사이즈와 맞출 수 있다.
아니면 가능한 쓰레드 수보다 크게 설정해서 워커 블록을 더 작게 만들 수 있다.

`TaskExecutorPartitionHandler`는 다량의 파일을 복사하거나
파일 시스템을 컨텐츠 관리 시스템으로 복제하는 등의
IO 처리가 많은 `Step` 인스턴스에 유용하다.
원격 호출(Spring Remoting 같은)을 하는 프록시로 `Step`을 구현하면
리모트 실행에도 사용할 수 있다.

### 7.4.2. Partitioner

`Partitioner` 역할은 좀 더 간단하다:
다음 step을 실행할 때 입력 파라미터로 사용할 실행 컨텍스트를 만든다
(재시작을 고려할 필요 없다).
파티셔너는 메소드가 한 개뿐이며, 인터페이스 정의는 다음과 같다:

```java
public interface Partitioner {
    Map<String, ExecutionContext> partition(int gridSize);
}
```

이 메소드가 리턴하는 값은 각 step 실행의 유니크한 이름(`String`)을
`ExecutionContext` 입력 파라미터와 매핑한 Map이다.
이 이름은 나중에 배치 메타 데이터에서
나눠져 있는 각 `StepExecution`의 step 이름으로 확인할 수 있다.
`ExecutionContext`는 단순히 키/값 쌍을 저장하므로
primary key 범위나, 라인 넘버, 입력 파일 위치같은 정보를 담을 수 있다.
리모트 `Step`은 다음 섹션에서 설명하긴 하지만,
입력 컨텍스트와 바인딩할 때 `#{…​}` 플레이스홀더(step scope에서 나중에 바인딩된다)를 사용한다.

step 실행의 이름(`Partitioner`가 리턴하는 `Map`의 키)은
`Job` 안에서 step을 실행할 때 마다 유일해야 한다는 것 말고는 제약이 없다.
이를 지키기 위한 가장 쉬운 방법은 (그리고 이름이 의미를 담고 있게 하려면)
실행할 step 이름(`Job` 안에서 이미 유니크하다)을 프리픽스로,
숫자(카운터)를 suffix로 사용하는 prefix+suffix 네이밍 컨벤션을 사용하는 것이다.
프레임워크는 이 컨벤션을 사용하는 `SimplePartitioner`를 제공한다.

`PartitionNameProvider` 인터페이스를 추가로 구현하면
각 파티션의 이름을 제공할 수 있으며, 필수는 아니다. 
`Partitioner`가 이 인터페이스를 구현하면 재시작 할 때
다시 파티셔닝하지 않고 이름으로 파티션을 조회해 재사용한다.
파티셔닝이 무거운 작업이라면 최적화 용으로 유용하다.
`PartitionNameProvider`가 제공하는 이름은 `Partitioner`가 제공하는 이름과
반드시 일치해야 한다.

### 7.4.3. Binding Input Data to Steps

`PartitionHandler`가 실행하는 step 설정은 동일하게 유지하고,
런타임에 `ExecutionContext`로부터 입력 파라미터를 받을 수 있다면 가장 효율적일 것이다.
스프링 배치의 StepScope를 사용하면 쉽게 가능하다
([Late Binding](https://godekdls.github.io/Spring%20Batch/configuringastep/#54-late-binding-of-job-and-step-attributes) 섹션에서 자세히 다뤘다). 
예를 들어 `Partitioner`가 `ExecutionContext`을 만들 때
각 step에서 사용할 다른 파일(혹은 디렉토리)을 가리키는 fileName을 저장한다면,
`Partitioner`의 결과값은 아래 테이블과 유사할 것이다:

**Table 17. 타겟 디렉토리 처리를 위해 `Partitioner`가 제공하는 step 실행 이름과 실행 컨텍스트 예시**

|Step Execution Name (key)|ExecutionContext (value)|
|:-----------------:	|:-------------:	|
|filecopy:partition0|fileName=/home/data/one|
|filecopy:partition1|fileName=/home/data/two|
|filecopy:partition2|fileName=/home/data/three|

이렇게 하면 아래 예제에 보이는 것처럼
파일 이름을 step 실행 컨텍스트에 나중에 바인딩할 수 있다:

```java
@Bean
public MultiResourceItemReader itemReader(
	@Value("#{stepExecutionContext['fileName']}/*") Resource [] resources) {
	return new MultiResourceItemReaderBuilder<String>()
			.delegate(fileReader())
			.name("itemReader")
			.resources(resources)
			.build();
}
```

> 전체 목차는 [여기](https://godekdls.github.io/Spring%20Batch/contents/) 에 있습니다.
