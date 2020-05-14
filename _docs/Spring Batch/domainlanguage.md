---
title: The Domain Language of Batch
category: Spring Batch
order: 4
---

스프링 배치에서 전반적으로 사용되는 배치 처리 컨셉은 배치 설계를 해본 사람이라면 익숙하고 편하게 느껴질 것이다.
Job과 Step, 그리고 개발자가 직접 제공해야하는 `ItemReader` `ItemWriter`라고 불리는 처리 유닛으로 구성되어 있는데,
스프링 패턴, 작업, 템플릿, 콜백 및 idiom으로 인한 다음과 같은 차이점이 있다.

- 명확한 관심사 분리에 기초한 개선
- 인터페이스로 제공되는 명확하게 기술된 아키텍처 레이어와 서비스
- 빠르게 적용하고 쉽게 바꿀 수 있는 간단한 디폴트 구현체
- 크게 향상된 확장성

아래는 수십년간 사용되온 배치 아키텍처를 간단히 나타낸 다이어그램이다.
배치 프로세싱에 사용되는 도메인 언어를 구성하는 컴포넌트를 개략적으로 설명한다.
이 아키텍처 프레임워크는 지난 몇 세대의 플랫폼(COBOL/Mainframe, C/Unix, and now Java/anywhere)에서 수십 년에 걸친 구현을 통해 입증 된 청사진이다.
JCL 및 COBOL 개발자는 C, C # 및 Java 개발자와 같은 개념에 익숙 할 것이다.
스프링 배치는 견고하고 유지보수 가능한 시스템에서 일반적으로 사용하는 레이어, 컴포넌트, 기술 서비스의 물리적인 구현체를 제공하는데,
이는 매우 복잡한 요구사항을 해결하기 위한 인프라와 확장을 통해, 단순한 배치부터 복잡한 배치 응용 프로그램까지 사용된다.

![Batch Stereotypes](./../../images/springbatch/batch-stereotypes.png)


이 다이어그램은 스프링 배치의 도메인 언어를 구성하는 핵심 컨셉을 나타내고 있다. Job 하나는 1~n개의 step을 가지고 있으며,
각 step은 `ItemReader`, `ItemProcessor`, `ItemWrite`를 정확하게 한 개 씩 가지고 있다.
각 Job은 `JobLauncher`에 의해 실행되어야 하며, 현재 실행중인 프로세스의 메타정보는 `JobRepository`에 저장된다.


3.1. Job

여기서는 배치 잡 컨셉과 관련있는 개념을 설명한다.
`Job`은 전체 배치 프로세스를 캡슐화한 엔터티다. 다른 스프링 프로젝트와 마찬가지로, `Job`은 XML 기반이나 자바 기반 설정을 둘 다 지원한다. 이 설정은 "job configuration"이라고도 할 수 있지만, `Job`은 아래 다이어그램에서 보여지듯이 전체 hierarchy의 가장 위에 있을 뿐이다.

![Batch Stereotypes](./../../images/springbatch/job-hierarchy.png)

스프링 배치에서, `Job`은 단순히 `Step` 인스턴스의 컨테이너 개념이다.
논리적으로 한 플로우에 속한 여러 스텝을 결합하고 재시작과 같은 속성값을 전역으로 구성할 수 있다.
job configuration은 다음과 같은 값이 있다:

- 단순 job의 name
- `Step` 인스턴스의 정의와 순서
- job의 재시작 가능/불가능 여부

`SimpleJob`는 스프링 배치에서 디폴트로 제공하는 간단한 Job 인터페이스의 구현체로, Job의 일부 표준 기능을 구현한다.
아래 예시처럼, 자바 기반으로 설정하는 경우에는 제공되는 여러 builder를 통해 `Job`의 초기화할 수 있다.
아래 예시처럼, 자바 기반으로 설정하는 경우에는 제공되는 여러 builder를 통해 `Job`의 초기화할 

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

3.1.1. JobInstance


`JobInstance`는 논리적인 job 실행을 나타내는 개념이다.
앞에 있는 다이어그램의 'EndOfDay' `Job`처럼 하루가 끝날 때마다 한번 실행되야하는 배치 잡을 생각해보자.
'EndOfDay' job은 하나지만, `Job`을 각각 실행할 때마다 따로 추적할 수 있어야 한다. 이 예시에서는, 매일 하나의 논리적인 `JobInstance`가 필요하다.
예를 들어, 1월 1일 실행, 1월 2일 실행, 등등.
1월 1일 실행한 배치가 실패하고 다음날 다시 실행되어야 하는 경우에, 재실행 되어도 1월 1일 작업이다. (보통 처리할 데이터와도 일치하는데, 1월 1일에 실행하면 1월 1일의 데이터를 처리한다는 뜻이다)
따라서 각 `JobInstance`는 여러 개의 실행결과를 가질 수 있고(`JobExecution`은 이 챕터 뒷 부분에 자세히 나온다), 특정 `Job`과 식별가능한 `JobParameters`에 상응하는 `JobInstance`는 단 한 개 뿐이다.

`JobInstance` 정의는 로드되는 데이터와는 아무런 관련이 없다. 데이터가 로드되는 방법은 전적으로 `ItemReader` 구현에 달려있다.
예를 들어, 앞에서 나온 EndOfDay 시나리오에서는, 데이터가 속하는 시행일이나 스케줄 날짜를 나타내는 컬럼이 있을 것이다.
즉, 1월 1일 실행은 1일 데이터만 로드하고, 1월 2일 실행은 2일 데이터만 사용할 것이다.
이러한 걸 결정은 비지니스적 요구사항일 가능성이 높으므로, `ItemReader`가 결정하도록 설계되었다.
그러나 `JobInstance` 재사용 여부는 이전 실행에서 사용된 상태(state, `ExecutionContext`는 이번 챕터의 뒷부분에 나온다)를 그대로 사용할지 말지를 결정한다.
새 `JobInstance`를 사용한다는 것은 '처음부터 시작'을 의미하고 이미 있는 instance를 쓴다는 것은 보통 '멈췄던 곳에서부터 시작'을 의미한다.

3.1.2. JobParameters

`JobInstance`가 Job과 어떻게 다른지 이야기하다 보면 보통 이런 질문이 나온다: "`JobInstance`는 다른 JobInstance와 어떻게 구분하지?"
정답은 `JobParameters`다.
`JobParameters`는 배치 잡을 시작할 때 사용되는 파라미터 셋을 가지고 있는 오브젝트다.
아래 이미지에서 보이듯, 실행 중 식별이나 참조 데이터로도 사용될 수 있다.

![Batch Stereotypes](./../../images/springbatch/job-parameters.png)

앞에 나온 예시에서는 각 1월 1일, 1월 2일, 총 두 개의 인스턴스가 있는데, `Job`은 하나지만 `JobParameter`가 두 개 있다: 하나는 2017/01/01에 사용된 파라미터, 다른 하나는 2017/01/02에 사용된 파라미터.
따라서, 이 공식이 도출된다: `JobInstance` = `Job` + identifying `JobParameters`.
덕분에 개발자는 효율적으로 `JobInstance`를 정의할 수 있으며, 거기 사용될 파라미터도 컨트롤할 수 있다.

3.1.3. JobExecution

`JobExecution`은 Job 실행을 한번 시도했다는 기술적인 개념을 나타낸다.
하나의 execution은 성공하거나 실패하게 되는데, execution에 상응하는 `JobInstance`는 해당 execution이 성공적으로 종료되기 전까지는 완료되지 않은 것으로 간주한다.
앞에서 설명 된 EndOfDay `Job`을 사용하여 처음 실행될 때 실패한 2017/01/01의 `JobInstance`를 생각해보자.
첫번째 실행(2017/01/01)과 같은 job parameter를 사용해서 재실행한다면, 새 `JobExecution`이 생성된다.
그러나 `JobInstance`는 여전히 한 개다.

`Job`은 job이 무엇인지와 어떻게 실행되어야 하는 지를 설명하고, `JobInstance`는 주로 올바른 재시작을 위해 execution을 그룹화하는 순수한 구조적인 오브젝트이다.
반대로 `JobExecution`은 실제 실행 중에 발생한 작업에 대한 기본 스토리지 메커니즘을 제공하며, 아래 테이블에서 보여지듯, 관리하고 유지해야하는 더 많은 프로퍼티를 가지고있다.

**Table 1. JobExecution Properties**
| Property 	| Definition 	|
|:-----------------:	|:-------------:	|
|Status||
|startTime||
|endTime||
|exitStatus||
|createTime||
|lastUpdated||
|executionContext||
|failureExceptions||
