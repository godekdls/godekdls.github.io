---
title: The Domain Language of Batch
category: Spring Batch
order: 4
permalink: /Spring%20Batch/domainlanguage/
---

> [스프링 배치 공식 reference](https://docs.spring.io/spring-batch/docs/4.2.x/reference/html/index-single.html#domainLanguageOfBatch)를 한글로 번역한 문서입니다.
>
> 전체 목차는 [여기](https://godekdls.github.io/Spring%20Batch/contents/)에 있습니다.

### 목차

- [3.1. Job](#31-job)
  + [3.1.1. JobInstance](#311-jobinstance)
  + [3.1.2. JobParameters](#312-jobparameters)
  + [3.1.3. JobExecution](#313-jobexecution)
- [3.2. Step](#32-step)
  + [3.2.1. StepExecution](#321-stepexecution)
- [3.3. ExecutionContext](#33-executioncontext)
- [3.4. JobRepository](#34-jobrepository)
- [3.5. JobLauncher](#35-joblauncher)
- [3.6. Item Reader](#36-item-reader)
- [3.7. Item Writer](#37-item-writer)
- [3.8. Item Processor](#38-item-processor)

스프링 배치는 전반적으로 배치 설계를 해봤다면 익숙하고 편하게 느껴질만한 컨셉을 사용한다.
Job과 Step, 개발자가 직접 제공해야하는 처리 유닛(`ItemReader` `ItemWriter`)으로 구성되어 있는데,
스프링 패턴, operation, 템플릿, 콜백 및 idiom으로 인한 다음과 같은 차별점이 있다.

- 명확한 관심사 분리
- 인터페이스로 제공하는 명확한 아키텍처 레이어와 서비스
- 빠르게 적용하고 쉽게 응용할 수 있는 간단한 디폴트 구현체
- 크게 향상된 확장성

아래는 수십년간 사용되어온 배치 아키텍처를 간단히 나타낸 다이어그램이다.
배치 프로세싱 도메인 언어를 구성하는 컴포넌트를 개략적으로 설명한다.
이 아키텍처 프레임워크는 지난 몇 세대의 플랫폼(COBOL/Mainframe, C/Unix, and now Java/anywhere)에서 
수십 년에 걸쳐 입증한 청사진이다.
JCL, COBOL 개발자도 C, C#, Java 개발자만큼 이 개념에 익숙 할 것이다.
스프링 배치는 견고하고 유지보수 가능한 시스템에서 일반적으로 사용하는
레이어, 컴포넌트, 기술 서비스의 물리적 구현체를 제공는데,
이를 복잡한 요구사항을 해결하기 위한 인프라와 함께 확장하면,
단순한 배치부터 매우 복잡한 배치 응용 프로그램까지 개발할 수 있다.

![Batch Stereotypes](./../../images/springbatch/batch-stereotypes.png)

이 다이어그램은 스프링 배치의 도메인 언어를 구성하는 핵심 개념을 나타내고 있다.
Job 하나는 1~n개의 step을 가지고 있으며,
각 step은 `ItemReader`, `ItemProcessor`, `ItemWrite`를 딱 한 개 씩 가지고 있다.
각 Job은 `JobLauncher`가 실행하며, 현재 실행중인 프로세스의 메타정보는 `JobRepository`에 저장된다.

## 3.1. Job

여기서는 배치 job과 관련된 개념을 설명한다.
`Job`은 전체 배치 프로세스를 캡슐화한 엔터티다.
다른 스프링 프로젝트와 마찬가지로, `Job`은 XML 기반이나 자바 기반 설정을 둘 다 지원한다.
이 설정은 "job 설정"이라고도 할 수 있지만, `Job`은 아래 다이어그램에서 보여지듯이
전체 계층 구조에서 가장 위에 있는 개념일 뿐이다.

![Job Hierarchy](./../../images/springbatch/job-hierarchy.png)

스프링 배치에서 `Job`은 단순히 `Step` 인스턴스의 컨테이너 개념이다.
논리적으로 한 플로우에 속한 여러 step을 결합하고, 재시작 같은 속성을 전역으로 구성할 수 있다.
다음과 같은 설정으로 job을 구성한다:

- 단순 job의 name
- `Step` 인스턴스 정의와 순서
- job의 재시작 가능 여부

`SimpleJob`은 스프링 배치에서 디폴트로 제공하는 간단한 Job 인터페이스 구현체로, Job의 일부 표준 기능을 구현한다.
아래 예시처럼, 자바 기반으로 설정한다면 기본 제공하는 여러 builder로 `Job`을 초기화할 수 있다.

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
```

### 3.1.1. JobInstance

`JobInstance`는 논리적인 job 실행을 뜻한다.
앞에 있는 다이어그램의 'EndOfDay' `Job`처럼 하루가 끝날 때마다 한번 실행되야하는 배치 job을 생각해보자.
'EndOfDay' job은 하나지만, `Job`을 각각 실행할 때마다 따로 추적할 수 있어야 한다.
이 예시에서는 매일 하나의 논리적인 `JobInstance`가 필요하다.
예를 들어, 1월 1일 실행, 1월 2일 실행, 등등.
1월 1일에 실행한 배치가 실패해서 다음날 다시 실행하는 경우, 1월 1일의 작업과 동일한 작업을 재실행해야 한다 
(보통 처리 날짜와 처리할 데이터가 일치하는데, 1월 1일에 실행하면 1월 1일의 데이터를 처리한다는 뜻이다).
따라서 각 `JobInstance`는 실행 결과를 여럿 가질 수 있고(`JobExecution`은 이 챕터 뒷 부분에 자세히 나온다),
특정 `Job`과 식별가능한 `JobParameters`에 상응하는 `JobInstance`는 단 한 개 뿐이다.

`JobInstance`는 로드되는 데이터와는 아무런 관련이 없다.
데이터가 로드되는 방법은 전적으로 `ItemReader` 구현에 달려있다.
예를 들어 앞에서 나온 EndOfDay 케이스에서는, 데이터에 배치를 실행해야 하는 날짜를 의미하는 컬럼이 있을 것이다.
즉 1월 1일 실행은 1일 데이터만 로드하고, 1월 2일 실행은 2일 데이터만 사용할 것이다.
이러한 결정은 비지니스적 요구사항일 가능성이 높으므로 `ItemReader`가 결정하도록 설계되었다.
그러나 `JobInstance` 재사용 여부는 이전 실행에서 사용된 상태(`ExecutionContext`는 이번 챕터의 뒷부분에 나온다)를 그대로 사용할지 말지를 결정한다.
새 `JobInstance`를 사용한다는 것은 '처음부터 시작'을 의미하고, 이미 있는 instance를 쓴다는 것은 보통 '멈췄던 곳에서부터 시작'을 의미한다.

### 3.1.2. JobParameters

`JobInstance`가 Job과 어떻게 다른지 이야기하다 보면 보통 이런 질문이 나온다:
"`JobInstance`는 다른 JobInstance와 어떻게 구분하지?"
정답은 `JobParameters`다.
`JobParameters`는 배치 job을 시작할 때 사용하는 파라미터 셋을 가지고 있는 객체다.
아래 그림에서 보이듯, 실행 중 job을 식별하거나 참조 데이터로도 사용할 수 있다.

![Job Parameters](./../../images/springbatch/job-parameters.png)

앞에 나온 예시에서는 각 1월 1일, 1월 2일, 총 두 개의 인스턴스가 있는데, `Job`은 하나지만 `JobParameter`가 두 개 있다:
하나는 2017/01/01에 사용된 파라미터, 다른 하나는 2017/01/02에 사용된 파라미터.
따라서 이 공식이 도출된다: `JobInstance` = `Job` + 식별용 `JobParameters`.
덕분에 개발자는 효율적으로 `JobInstance`를 정의할 수 있으며, 거기 사용될 파라미터도 제어할 수 있다.

> 모든 job 파라미터를 `JobInstance`를 식별하는 데 사용하진 않는다.
> 기본적으로는 그렇지만,
> 프레임워크는 `JobInstance` ID에 관여하지 않는 파라미터를 사용할 수도 있다.

### 3.1.3. JobExecution

`JobExecution` 개념은 Job을 한번 실행하려 했다는 것이다.
하나의 실행은 성공하거나 실패하게 되는데, 
실행에 상응하는 `JobInstance`는 실행이 성공적으로
종료되기 전까지는 완료되지 않은 것으로 간주한다.
앞에 나온 EndOfDay `Job`을 실행하고 처음엔 실패한 2017/01/01의
`JobInstance`를 생각해보자.
첫번째 실행(2017/01/01)과 똑같은 job 파라미터로 재실행한다면,
새 `JobExecution`이 생성된다.
반면 `JobInstance`는 여전히 한 개다.

`Job`은 job이 무엇인지와 어떻게 실행되어야 하는지를 설명하고,
`JobInstance`는 주로 올바른 재시작을 위해 실행을 그룹화하는 순수한 구조적 오브젝트다.
반면 `JobExecution`은 실제 실행 중에 필요한
기본 스토리지 메커니즘을 제공하며, 아래 테이블에서 보여지듯 
더 많은 프로퍼티를 관리하고 유지해야 한다.

**Table 1. JobExecution Properties**

| Property 	| Definition 	|
|:-----------------:	|:-------------:	|
|Status|실행 상태를 나타내는 `BatchStatus` 오브젝트. 실행 중일 때는 `BatchStatus#STARTED`. 실패하면 `BatchStatus#FAILED`. 성공적으로 종료되면 `BatchStatus#COMPLETED`|
|startTime|job을 실행할 때의 시스템 시간을 나타내는 `java.util.Date`. 아직 job이 시작되지 않았다면 이 필드는 비어있다.|
|endTime|성공 여부와 상관 없이 실행이 종료될 때의 시스템 시간을 나타내는 `java.util.Date`. 아직 job이 종료되지 않았다면 이 필드는 비어있다.|
|exitStatus|실행 결과를 나타내는 `ExitStatus`. 호출자에게 리턴하는 종료 코드를 포함하기 때문에 가장 중요하다. 자세한 내용은 5장 참고. 아직 job이 종료되지 않았다면 이 필드는 비어있다.|
|createTime|`JobExecution`이 처음 저장될 때의 시스템 시간을 나타내는 `java.util.Date`. job은 시작되지 않았을 수도 있는데(따라서 시작 시간이 없을 수도 있음), createTime은 프레임워크가 job 레벨의 `ExecutionContext`을 관리할 때 사용하기 때문에 항상 존재한다.|
|lastUpdated|`JobExecution`이 저장된 마지막 시간을 나타내는 `java.util.Date`. 아직 job이 시작되지 않았다면 이 필드는 비어있다.|
|executionContext|실행하는 동안 유지해야 하는 모든 사용자 데이터를 담고 있는 "property bag".|
|failureExceptions|`Job` 실행 중 발생한 예외 리스트. `Job`이 실패할 때 둘 이상의 예외가 발생한 경우에 유용하다.|

이 프로퍼티를 저장해 두면 실행 상태를 결정할 수 있으므로 매우 중요하다.
예를 들어, 01-01의 EndOfDay job을 9:00 PM에 실행해서 9:30에 실패했다면,
배치 메타 데이터 테이블에 아래 엔트리들이 저장된다:

**Table 2. BATCH_JOB_INSTANCE**

| JOB_INST_ID 	| JOB_NAME 	|
|:-----------------:	|:-------------:	|
|1|EndOfDayJob|

**Table 3. BATCH_JOB_EXECUTION_PARAMS**

| JOB_EXECUTION_ID 	| TYPE_CD 	|KEY_NAME|DATE_VAL|IDENTIFYING|
|:-----------------:	|:-------------:	||:-----------------:	|:-------------:	|:-------------:	|
|1|DATE|schedule.Date|2017-01-01|TRUE|

**Table 4. BATCH_JOB_EXECUTION**

| JOB_EXEC_ID 	| JOB_INST_ID 	|START_TIME|END_TIME|STATUS|
|:-----------------:	|:-------------:	||:-----------------:	|:-------------:	|:-------------:	|
|1|1|2017-01-01 21:00|2017-01-01 21:30|FAILED|

> 명확하게 하기 위해, 혹은 포맷팅을 위해 축약하거나 제거한 컬럼명도 있다.

job이 실패했고, 밤새도록 문제를 찾느라 '배치 윈도우'가 이제야 닫혔다고 가정해보자.
또한 윈도우는 9:00 PM에 시작하고,
다음날 중단했던 위치에서부터 job을 다시 시작해서 
9:30에 01-01 데이터를 모두 처리했다고 가정해보자.
하루가 지났으므로 01-02 job도 실행해야하는데, 
9시 31분에 바로 시작해서 1시간이 걸려 10시 30분에 정상적으로 종료된 상황이다.
두 job이 동일한 데이터에 접근해서 데이터베이스 레벨에서 잠금 문제를 일으킬 일이 없다면, `JobInstance` 한 개씩 순차적으로 진행할 필요는 없다.
`Job`을 실행할지 말지 결정하는 일은 전적으로 스케줄러에 달려있다.
여기서 두 `JobInstance`는 독립적이므로, 스프링 배치는 동시에 실행한다고 해서 job을 중단시키지 않는다.
(`JobInstance`가 이미 실행 중인데 같은 `JobInstance`를 실행하려고 하면 `JobExecutionAlreadyRunningException`이 발생한다).
아래 표를 보면 이제 `JobInstance` 및 `JobParameters` 테이블에 엔트리 하나씩이 추가됐고, `JobExecution` 테이블에 두 개의 엔트리가 추가됐다.

**Table 5. BATCH_JOB_INSTANCE**

| JOB_INST_ID 	| JOB_NAME 	|
|:-----------------:	|:-------------:	|
|1|EndOfDayJob|
|2|EndOfDayJob|

**Table 6. BATCH_JOB_EXECUTION_PARAMS**

| JOB_EXECUTION_ID 	| TYPE_CD 	|KEY_NAME|DATE_VAL|IDENTIFYING|
|:-----------------:	|:-------------:	||:-----------------:	|:-------------:	|:-------------:	|
|1|DATE|schedule.Date|2017-01-01|TRUE|
|2|DATE|schedule.Date|2017-01-01|TRUE|
|3|DATE|schedule.Date|2017-01-02|TRUE|

**Table 7. BATCH_JOB_EXECUTION**

| JOB_EXEC_ID 	| JOB_INST_ID 	|START_TIME|END_TIME|STATUS|
|:-----------------:	|:-------------:	||:-----------------:	|:-------------:	|:-------------:	|
|1|1|2017-01-01 21:00|2017-01-01 21:30|FAILED|
|2|1|2017-01-02 21:00|2017-01-02 21:30|COMPLETED|
|3|2|2017-01-02 21:31|2017-01-02 22:29|COMPLETED|

> 명확하게 하기 위해, 혹은 포맷팅을 위해 축약하거나 제거한 컬럼명도 있다.

## 3.2. Step

`Step`은 배치 job의 독립적이고 순차적인 단계를 캡슐화한 도메인 객체다.
즉, 모든 Job은 하나 이상의 step으로 구성된다.
`Step`은 실제 배치 처리를 정의하고 컨트롤하는 데 필요한 모든 정보를 가지고 있다.
설명이 모호하게 느껴질 수도 있는데, `Step`의 모든 내용은 `Job`을 만드는 개발자 재량이기 때문에 그렇다.
`Step`은 어떻게 개발하느냐에 따라 간단할 수도 있고 복잡할 수도 있다.
즉, 단순히 데이터베이스에서 파일을 읽는, 코드가 거의 필요없거나 전혀 필요하지 않은(사용한 구현체에 따라 다름) 간단한 작업이 될 수도 있고,
프로세싱의 일부를 처리하는 복잡한 비지니스 로직도 될 수 있다.
아래 그림처럼 `Job`이 고유 `JobExecution`이 있듯, `Step`도 각자의 `StepExecution`이 있다.

![Job Hierarchy With Steps](./../../images/springbatch/job-hierarchy-with-steps.png)

### 3.2.1. StepExecution

`StepExecution`은 한 번의 `Step` 실행 시도를 의미한다.
`StepExecution`은 `JobExecution`과 유사하게 `Step`을 실행할 때마다 생성한다.
하지만 이전 단계 step이 실패해서 step을 실행하지 않았다면 execution을 저장하지 않는다.
`Step`이 실제로 시작됐을 때만 `StepExecution`을 생성한다.

`Step` execution은 `StepExecution` 클래스 객체다.
각 execution은 실행/종료 시간이나 커밋/롤백 횟수를 포함한 해당 step, `JobExecution`, 트랜잭션 관련 데이터를 가지고 있다.
추가로, 각 step execution은 `ExecutionContext`를 가지고 있는데 여기에는 통계나 재시작 시 필요한 상태 정보 등 배치 작업에서 유지해야하는 모든 데이터가 있다.
`StepExecution`의 프로퍼티는 아래 테이블에 있다.

**Table 8. StepExecution Properties**

| Property 	| Definition 	|
|:-----------------:	|:-------------:	|
|Status|실행 상태를 나타내는 `BatchStatus` 객체. 실행 중일 때는 `BatchStatus.STARTED`. 실패하면 `BatchStatus.FAILED`. 성공하면 `BatchStatus.COMPLETED.`|
|startTime|step을 실행할 때의 시스템 시간을 나타내는 `java.util.Date`. 아직 step이 시작되지 않았다면 이 필드는 비어있다.|
|endTime|성공 여부와 상관 없이 실행이 종료될 때의 시스템 시간을 나타내는 `java.util.Date`. 아직 step이 종료되지 않았다면 이 필드는 비어있다.|
|exitStatus|실행 결과를 나타내는 `ExitStatus`. 호출자에게 리턴하는 종료 코드를 포함하기 때문에 가장 중요하다. 자세한 내용은 5장 참고. 아직 job이 종료되지 않았다면 이 필드는 비어있다.|
|executionContext|실행하는 동안 유지해야 하는 모든 사용자 데이터를 담고 있는 “property bag”.|
|readCount|성공적으로 read한 아이템 수.|
|writeCount|성공적으로 write한 아이템 수.|
|commitCount|실행 중에 커밋된 트랜잭션 수.|
|rollbackCount|`Step`에서 처리된 트랜잭션 중 롤백된 횟수.|
|readSkipCount|read에 실패해서 스킵된 횟수.|
|processSkipCount|process에 실패해서 스킵된 횟수.|
|filterCount|`ItemProcessor`에 의해 필터링된 아이템 수.|
|writeSkipCount|write에 실패해서 스킵된 횟수.|

## 3.3 ExecutionContext

`ExecutionContext`는 프레임워크에서 유지/관리하는 키/값 쌍의 컬렉션으로,
`StepExecution` 객체 또는 `JobExecution` 객체에 속하는 상태(state)를 저장한다.
Quartz에 익숙하다면, JobDataMap과 유사하게 느껴질 것이다.
쉽게 말해 재시작을 용이하게 해준다는 건데,
예를 들어 플랫(flat) 파일을 입력으로 받아 각 라인별로 처리한다면
프레임워크는 커밋 지점에 주기적으로 `ExecutionContext`를 저장한다.
이렇게 하면 `ItemReader`는 실행 중 전원이 나가버리는 등의 치명적인 에러가 발생했을 때에도 상태를 저장해둘 수 있다. 
다음 예제와 같이 현재 읽은 라인 수를 컨텍스트에 넣기만 하면 나머지는 프레임워크가 다 처리한다.

```java
executionContext.putLong(getKey(LINES_READ_COUNT), reader.getPosition());
```

`Job`의 개념 설명할 때 예시로 사용한 EndOfDay를 그대로 가져와서, 
데이터베이스에서 파일을 읽는 'loadData' step 하나가 있다고 가정해보자.
첫 실행에 실패한 이후의 메타 데이터 테이블은 아래와 같을 것이다:

**Table 9. BATCH_JOB_INSTANCE**

| JOB_INST_ID 	| JOB_NAME 	|
|:-----------------:	|:-------------:	|
|1|EndOfDayJob|

**Table 10. BATCH_JOB_EXECUTION_PARAMS**

| JOB_INST_ID 	| TYPE_CD 	|KEY_NAME|DATE_VAL|
|:-----------------:	|:-------------:	|:-----------------:	|:-------------:	|
|1|DATE|schedule.Date|2017-01-01|

**Table 11. BATCH_JOB_EXECUTION**

| JOB_EXEC_ID 	| JOB_INST_ID 	|START_TIME|END_TIME|STATUS|
|:-----------------:	|:-------------:	|:-----------------:	|:-------------:	|:-------------:	|
|1|1|2017-01-01 21:00|2017-01-01 21:30|FAILED|

**Table 12. BATCH_STEP_EXECUTION**

| STEP_EXEC_ID 	| JOB_EXEC_ID 	|STEP_NAME|START_TIME|END_TIME|STATUS|
|:-----------------:	|:-------------:	|:-----------------:	|:-------------:	|:-------------:	|
|1|1|loadData|2017-01-01 21:00|2017-01-01 21:30|FAILED|

**Table 13. BATCH_STEP_EXECUTION_CONTEXT**

| STEP_EXEC_ID 	| SHORT_CONTEXT 	|
|:-----------------:	|:-------------:	|
|1|{piece.count=40321}|

위 예시에서 `Step`은 30분 동안 실행됐고, 40,321개의 'peices'(여기서는 이파일의 라인 수를 의미)를 처리했다.
이 값은 프레임워크가 각 커밋 전 업데이트하며, `ExecutionContext` 내 엔터티에 해당하는 여러 row를 포함 할 수 있다.
커밋 전에 통지 받으려면 여러 `StepListener` 구현체(또는 `ItemStream`) 중 하나가 필요한데, 자세한 내용은 이 가이드 뒷부분에 나온다.
이전 예시와 동일하게 다음 날 `Job`을 재실행했다고 가정한다.
재시작할 때 데이터베이스로부터 마지막 실행을 가리키는 `ExecutionContext` 값을 조회한다.
아래 예제처럼, `ItemReader`가 열릴 때 컨텍스트에 저장된 상태가 있는지 확인하고, 있다면 해당 컨텍스트를 참조해서 초기화한다.
  
```java
if (executionContext.containsKey(getKey(LINES_READ_COUNT))) {
    log.debug("Initializing for restart. Restart data is: " + executionContext);

    long lineCount = executionContext.getLong(getKey(LINES_READ_COUNT));

    LineReader reader = getReader();

    Object record = "";
    while (reader.getPosition() < lineCount && record != null) {
        record = readLine();
    }
}
```

위 코드를 실행하면 현재 라인은 40322이므로, 중단됐던 위치부터 `Step`을 다시 실행할 수 있다.
실행 자체에 관한 통계 데이터도 `ExecutionContext`를 활용하면 된다. 
예를 들어, 여러 줄을 한 번에 처리해야하고 그 처리에도 순서가 있다면 몇번째 순서까지 진행했는지도 기록해야한다
(단순히 읽어온 라인 수를 기록하는 것과는 다르다).
따라서 `Step`이 끝날 때 몇 번째 순서까지 진행했는지를 메일로 보낸다고 해보자.
프레임워크는 어떤 `JobInstance`를 사용하냐에 따라 그에 맞는 상태를 저장해주는데, 
이미 있는 `ExecutionContext`를 사용할지 말지 판단하는 일은 쉽지만은 않다.
위에 나온 'EndOfDay'로 예를 들면,
01-01 배치를 두번째로 실행할 때는 동일한 `JobInstance`를 사용하기 때문에 
각 `Step`에서 데이터베이스로부터 `ExecutionContext`를 읽어와 함께 처리한다(`StepExecution`의 일부로).
반대로 01-02 배치에선 다른 `JobInstance`를 사용하므로 `Step`은 빈 컨텍스트를 주입받는다.
프레임워크는 여러 가지 상황을 고려해 job 인스턴스와 컨텍스트를 결정한다.
`StepExecution`이 생길 때 마다 `ExecutionContext`가 하나씩 생긴다는 점도 알아두자.
`ExecutionContext`는 keyspace를 공유하기 때문에 주의해서 사용해야 한다.
즉, 데이터가 겹쳐써지지 않도록 값을 넣을 때 주의해야 한다.
반대로 `Step`은 데이터 저장하지 않으므로 별다른 영향을 주지 않는다.

또한 `JobExecution` 당 `ExecutionContext`가 하나인 것처럼, 모든 `StepExecution` 마다 `ExecutionContext`를 한 개씩 가지고 있다는 점도 잊지 말자. 
예시로 아래 코드를 보자:

```java
ExecutionContext ecStep = stepExecution.getExecutionContext();
ExecutionContext ecJob = jobExecution.getExecutionContext();
//ecStep does not equal ecJob
```

주석에서 말하듯이 `ecStep`과 `ecJob`은 같지 않다.
`ExecutionContext`는 두 종류가 있다.
하나는 `Step` 레벨로 `Step` 내에서 커밋할 때마다 저장하고,
`Job` 레벨의 컨텍스트는 모든 `Step` 실행 사이마다 저장한다.

## 3.4. JobRepository

`JobRepository`는 위에서 언급된 모든 저장(persistence) 메커니즘을 담당한다.
`JobLauncher`, `Job`, `Step` 구현체에 CRUD 기능을 제공한다.
`Job`을 실행할 때 레포지토리에서 `JobExecution`을 조회하고,
실행 중에는 `StepExecution` `JobExecution` 구현체를
레포지토리에 넘겨 저장한다.

자바 기반 설정은
`@EnableBatchProcessing` 애노테이션만 달아주면
`JobRepository`를 자동으로 컴포넌트로 설정한다.

## 3.5. JobLauncher

`JobLauncher`는 아래 코드처럼
주어진 `JobParameters`로 `Job`을 실행하는 간단한 인터페이스다.
 
 ```java
public interface JobLauncher {

public JobExecution run(Job job, JobParameters jobParameters)
            throws JobExecutionAlreadyRunningException, JobRestartException,
                   JobInstanceAlreadyCompleteException, JobParametersInvalidException;
}
```

`JobRepository`에서 유효한 `JobExecution`을 조회하고 `Job`을 실행하는 기능을 구현한다.

## 3.6. Item Reader

`ItemReader`는 `Step`에서 한 번에 아이템을 하나씩 읽어오는 작업을 추상화한 개념이다.
더 이상 읽을 아이템이 없으면 `ItemReader`는 null을 리턴한다.
`ItemReader`에 대한 자세한 설명과 구현체는 [Readers And Writers](https://godekdls.github.io/Spring%20Batch/itemreadersanditemwriters/)를 참조하라.

## 3.7. Item Writer

`ItemWriter`는 `Step`에서 배치나 청크 단위로 아이템을 출력하는 작업을 추상화한다.
보통 `ItemWriter`는 다음에 받을 입력이 무엇인지는 알지 못하며 현재 받은 아이템만 알고 있다.
`ItemWriter`에 대한 자세한 설명과 구현체는 [Readers And Writers](https://godekdls.github.io/Spring%20Batch/itemreadersanditemwriters/)를 참조하라.

## 3.8. Item Processor

`ItemProcessor`는 아이템을 처리하는 비지니스 로직을 나타내는 추상화 개념이다.
`ItemReader`가 아이템을 하나 read하고 `ItemWriter`가 아이템 묶음을 write한다면,
`ItemProcessor`는 데이터 변환이나 다른 비지니스 처리를 담당한다. 
데이터를 처리하던 중 아이템이 유효하지 않다고 판단하면 null을 리턴하는데, 이 아이템은 write되면 안된다는 것을 의미한다.
`ItemProcessor` 인터페이스에 대한 자세한 설명은 [Readers And Writers](https://godekdls.github.io/Spring%20Batch/itemreadersanditemwriters/)를 참조하라.

> 전체 목차는 [여기](https://godekdls.github.io/Spring%20Batch/contents/)에 있습니다.
