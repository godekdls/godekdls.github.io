---
title: Configuring a Step
category: Spring Batch
order: 6
---

[domain](https://godekdls.github.io/Spring%20Batch/domainlanguage/) 챕터에서 이야기한 대로,
`Step`은 batch job의 독립적으로 실행되는 순차적인 단계를 캡슐화한 도메인 오브젝트이며
실제 배치 처리를 정의하고 컨트롤하는 데 필요한 모든 정보를 가지고 있다.
설명이 모호하게 느껴질 수도 있는데, 주어진 `Step`의 모든 내용은 `Job`을 만드는 개발자의 재량이기 때문에 그렇다.
`Step`은 어떻게 개발하느냐에 따라 간단할 수도 있고 복잡할 수도 있다.
아래 그림에서 표현하는 `Step`은 단순히 데이터베이스에서 파일을 읽는, 코드가 거의 필요없거나 전혀 필요하지 않은(사용한 구현체에 따라 다름) 간단한 작업이 될 수도 있고,
프로세싱의 일부를 처리하는 복잡한 비지니스 로직도 될 수 있다.

![Step](./../../images/springbatch/step.png)

## 5.1. Chunk-oriented Processing

스프링 배치 구현체의 대부분은 '청크 지향'으로 개발되었다.
청크 지향 프로세싱이란 한 번에 데이터를 하나씩 읽어와서 트랜잭션 경계 내에서 쓰여질 '청크'를 만드는 걸 뜻한다.
`ItemReader`가 item 하나를 읽으면 데이터는 `ItemProcessor`에 넘겨지고 결국엔 합쳐진다.
읽어온 item 수가 commit interval과 같아지면 `ItemWriter`가 청크 전체를 write하고, 트랜잭션이 커밋된다.
아래는 이 절차를 도식화한 그림이다:

![Chunk-oriented Processing](./../../images/springbatch/chunk-oriented-processing.png)

같은 개념을 코드로 나타내면 다음과 같다:

```java
List items = new Arraylist();
for(int i = 0; i < commitInterval; i++){
    Object item = itemReader.read()
    Object processedItem = itemProcessor.process(item);
    items.add(processedItem);
}
itemWriter.write(items);
```

### 5.1.1. Configuring a `Step`

`Step`은 요구하는 의존성(dependency)이 상대적으로 적은 편이지만,
많은 collaborator를 포함할 수 있는 매우 복잡한 클래스다.

자바 기반 설정을 사용한다면 아래 예제처럼 스프링 배치 빌더를 사용한다:

```java
/**
 * Note the JobRepository is typically autowired in and not needed to be explicitly
 * configured
 */
@Bean
public Job sampleJob(JobRepository jobRepository, Step sampleStep) {
    return this.jobBuilderFactory.get("sampleJob")
    			.repository(jobRepository)
                .start(sampleStep)
                .build();
}

/**
 * Note the TransactionManager is typically autowired in and not needed to be explicitly
 * configured
 */
@Bean
public Step sampleStep(PlatformTransactionManager transactionManager) {
	return this.stepBuilderFactory.get("sampleStep")
				.transactionManager(transactionManager)
				.<String, String>chunk(10)
				.reader(itemReader())
				.writer(itemWriter())
				.build();
}
```

위 설정은 item 지향 step을 생성하는데 필수적인 의존성(dependency)만 보여주고 있다.

- `reader`: 처리할 아이템을 제공하는 `ItemReader`
- `writer`: `ItemReader`에게 제공받은 아이템을 처리할 `ItemWriter`
- `transactionManager`: 트랜잭션을 시작하고 커밋하는 스프링의 `PlatformTransactionManager`
- `repository`: `StepExecution`과 `ExecutionContext`를 주기적으로(커밋 직전) 저장하는 `JobRepository`
- `chunk`: 트랜잭션을 커밋하기 전까지 처리할 아이템 수로, item 기반 step이라는 걸 보여줌

디톨트 레포지토리는 `jobRepository`, 디폴트 트랜잭션 매니저는 `transactionManger`라는 걸 명심해라
(모두 `@EnableBatchProcessing`를 통해 제공됨).
아이템은 아무런 처리 없이 reader에서 writer로 바로 전달될 수도 있기 때문에 `ItemProcessor`는 옵션이다.

### 5.1.3. The Commit Interval

앞에서 말했듯이 step은 아이템을 읽고 쓰면서 설정된 `PlatformTransactionManager`를 사용해 주기적으로 커밋한다.
`commit-interval`이 1이면 각 아이템을 write할 때마다 커밋한다.
트랜잭션을 시작하고 커밋하는 건 소모적인 작업이므로 보통 이렇게 사용하진 않는다.
보통은 한 트랜잭션에서 가능한 많은 아이템을 처리하는데,
처리되는 데이터 타입과 step이 상호작용하는 리소스에 따라 천차만별이다.
그렇기 때문에 한 커밋에서 처리할 아이템 수를 직접 설정할 수 있다.
아래 예제는 `tasklet`의 `commit-interval`이 10인 step을 사용한다.

```java
@Bean
public Job sampleJob() {
    return this.jobBuilderFactory.get("sampleJob")
                     .start(step1())
                     .end()
                     .build();
}

@Bean
public Step step1() {
	return this.stepBuilderFactory.get("step1")
				.<String, String>chunk(10)
				.reader(itemReader())
				.writer(itemWriter())
				.build();
}
```

앞의 예제에서는 한 트랜잭션에 아이템 10개씩 처리한다.
데이터 처리 전에 트랜잭션이 시작된다.
`ItemReader`에서 `read` 메소드가 호출될 때마다 카운터가 증가한다.
카운터가 10이되면 합쳐진 아이템 리스트는 `ItemWriter`로 넘겨지고 트랜잭션이 커밋된다.

### 5.1.4. Configuring a Step for Restart

[Configuring and Running a Job](https://godekdls.github.io/Spring%20Batch/configuringandrunningajob/) 섹션에서
`Job`을 재시작하는 방법을 다뤘다.
재시작은 step에도 큰 영향을 주므로 몇몇 설정이 필요하다.

#### Setting a Start Limit

종종 `Step`의 실행 횟수를 조정하고 싶을 때가 있을 것이다.
예를 들어, 다시 실행하기 전에 수동으로 수정해야만하는 일부 자원을 무효화시키는 `Step`이 있다면
한 번만 실행되도록 설정해야 한다.
step마다 요구사항이 다르므로 step 레벨에서 이를 설정할 수 있다.
하나의 `Job`에 한 번만 실행해야 하는 `Step`과 그렇지 않은 `Step`이 같이 있는 경우도 있다.
아래는 start limit을 설정하는 샘플 코드다:

```java
@Bean
public Step step1() {
	return this.stepBuilderFactory.get("step1")
				.<String, String>chunk(10)
				.reader(itemReader())
				.writer(itemWriter())
				.startLimit(1)
				.build();
}
```

위의 step은 한 번만 실행할 수 있다.
다시 실행하려고 하면 `StartLimitExceededException`이 발생한다.
start-limit의 디폴트 값은 `Integer.MAX_VALUE`이다.

#### Restarting a Completed `Step`

재시작 가능한 job이라면 첫 실행에서 성공했는지와는 상관없이 항상 실행해야하는 step도 있을 수 있다.
유효성 검증 스텝이나 배치 전 리소스를 정리하는 `Step`이 그렇다.
재시작된 job을 처리하는 동안에는 'COMPLETED' 상태를 가진, 즉 이미 성공적으로 완료된 step은 스킵한다.
아래 예제처럼 `allow-start-if-complete`를 "true"로 설정하면 해당 스텝은 항상 실행된다:

```java
@Bean
public Step step1() {
	return this.stepBuilderFactory.get("step1")
				.<String, String>chunk(10)
				.reader(itemReader())
				.writer(itemWriter())
				.allowStartIfComplete(true)
				.build();
}
```

#### `Step` Restart Configuration Example

아래 예제에서는 job에 재시작 가능한 step을 설정한다:

```java
       @Bean
       public Job footballJob() {
       	return this.jobBuilderFactory.get("footballJob")
       				.start(playerLoad())
       				.next(gameLoad())
       				.next(playerSummarization())
       				.end()
       				.build();
       }

       @Bean
       public Step playerLoad() {
       	return this.stepBuilderFactory.get("playerLoad")
       			.<String, String>chunk(10)
       			.reader(playerFileItemReader())
       			.writer(playerWriter())
       			.build();
       }

       @Bean
       public Step gameLoad() {
       	return this.stepBuilderFactory.get("gameLoad")
       			.allowStartIfComplete(true)
       			.<String, String>chunk(10)
       			.reader(gameFileItemReader())
       			.writer(gameWriter())
       			.build();
       }

       @Bean
       public Step playerSummarization() {
       	return this.stepBuilderFactor.get("playerSummarization")
       			.startLimit(2)
       			.<String, String>chunk(10)
       			.reader(playerSummarizationSource())
       			.writer(summaryWriter())
       			.build();
       }
```

위 예제는 축구 게임 정보를 읽어와서 요약하는 job을 설정하고 있다.
`playerLoad`, `gameLoad`, and `playerSummarization` 세 가지 step이 있다.
`playerLoad` step은 플랫한 파일에서 선수 정보를 읽어오고, `gameLoad` step은 같은 방법으로 게임 정보를 읽어온다.
마지막 `playerSummarization` step은 읽어온 게임 정보를 참고해서 각 선수에 대한 통계를 추출한다.
`playerLoad`에서 읽는 파일은 한 번에 로드해야 하지만,
`gameLoad`는 특정 디렉토리 아래 있는 어떤 게임 파일이라도 읽을 수 있으며
성공적으로 데이터베이스에 저장한 다음에는 파일을 지운다고 가정한다.
따라서 `playerLoad`는 몇번이고 실행되도 괜찮고, 이미 완료됐다면 스킵해도 좋기 때문에 별다른 설정이 없다.
그러나 `gameLoad` step은 이전에 실행된 이후 파일이 추가되었을 수도 있으므로 매번 실행할 필요가 있다.
항상 실행될 수 있도록 'allow-start-if-complete'를 'true'로 설정했다.
(게임을 저장하는 데이터베이스에는 실행을 식별할 수 있는 값이 있어서,
summarization step에서 게임이 새로 추가된 게임인지를 알 수 있다고 가정한다.)
가장 중요한 summarization step은 start limit을 2로 설정했다.
step이 계속해서 실패하면 새 종료코드가 리턴되므로
job 운영자가 수동 처리가 필요하다는 걸 인지할 수 있다.

> 이 job은 이 문서의 예시일 뿐이며 샘플 프로젝트에 있는 `footballJob` 동일하지 않다.

여기서부터 `footballJob` 예제를 세 번 실행했을 때의 각 동작을 설명하겠다.

Run 1:

1. `playerLoad`이 실행되고 정상적으로 완료되어 'PLAYERS' 테이블에 400명의 선수 정보를 추가한다.
2. `gameLoad`이 실행되고 게임 데이터에 해당하는 11개의 파일을 처리해 'GAMES' 테이블에 저장한다.
3. `playerSummarization`이 시작하고 5분 뒤에 실패한다.

Run 2:

1. `playerLoad`는 이전에 이미 성공했고 `allow-start-if-complete`이 'false'(디폴트)이므로 실행되지 않는다.
2. `gameLoad`는 다시 실행되어 다른 2개의 파일을 처리하고 마찬가지로 'GAMES' 테이블에 저장한다 (실행을 식별할 수 있는 값과 함께 저장).
3. `playerSummarization`은 남은 모든 데이터를 처리하고 (실행을 식별할 수 있는 값으로 필터링함) 30분 뒤 다시 실패한다.

Run 3:

1. `playerLoad`는 이전에 이미 성공했고 `allow-start-if-complete`이 'false'(디폴트)이므로 실행되지 않는다.
2. `gameLoad`는 다시 실행되어 다른 2개의 파일을 처리하고 마찬가지로 'GAMES' 테이블에 저장한다 (실행을 식별할 수 있는 값과 함께 저장).
3. `playerSummarization`을 실행하지 않은 채로 job은 즉시 종료된다. `playerSummarization`을 세 번째 실행하는 건데, 두 번으로 제한되어있기 때문이다. 이 제한을 바꾸던가 `Job`을 새 `JobInstance`로 실행해야 한다.

### 5.1.5. Configuring Skip Logic

