---
title: Unit Testing
category: Spring Batch
order: 11
permalink: /Spring%20Batch/unittesting/
---

> [스프링 배치 공식 reference](https://docs.spring.io/spring-batch/docs/4.2.x/reference/html/index-single.html#testing) 를 한글로 번역한 문서입니다.
>
> 전체 목차는 [여기](https://godekdls.github.io/Spring%20Batch/contents/) 에 있습니다.

### 목차

- [10.1. Creating a Unit Test Class](#101-creating-a-unit-test-class)
- [10.2. End-To-End Testing of Batch Jobs](#102-end-to-end-testing-of-batch-jobs)
- [10.3. Testing Individual Steps](#103-testing-individual-steps)
- [10.4. Testing Step-Scoped Components](#104-testing-step-scoped-components)
- [10.5. Validating Output Files](#105-validating-output-files)
- [10.6. Mocking Domain Objects](#106-mocking-domain-objects)

다른 어플리케이션과 마찬가지로 배치 job을 구성하는 모든 코드는 반드시 단위 테스트가 필요하다.
스프링 환경 단위 테스트와 통합 테스트를 위한 가이드는
스프링 코어 문서에서 충분히 자세히 다루기 때문에 여기서 반복하진 않겠다.
여기서 다루지는 않지만 배치 job을 '처음부터 끝까지(end to end)' 테스트할
방법을 고민해볼 필요가 있다.
spring-batch-test 프로젝트는 end-to-end 테스트를 도와줄 클래스를 제공한다. 

## 10.1. Creating a Unit Test Class

배치 job을 단위 테스트에서 실행시키려면
프레임워크가 job의 `ApplicationContext`을 로딩시켜야 한다.
이를 위해 두 가지 어노테이션을 사용한다:

- `@RunWith(SpringRunner.class)`: 스프링 JUnit 기능을 사용하겠다는 표시 
- `@ContextConfiguration(…​)`: `ApplicationContext`에 설정할 리소스를 명시

4.1 버전부터 `@SpringBatchTest` 애노테이션을 사용하면
`JobLauncherTestUtils`, `JobRepositoryTestUtils`를 포함한
스프링 배치 테스트 유틸리티를 주입할 수 있다.

아래는 이 애노테이션들을 사용하는 예제 코드다:

```java
@SpringBatchTest
@RunWith(SpringRunner.class)
@ContextConfiguration(classes=SkipSampleConfiguration.class)
public class SkipSampleFunctionalTests { ... }
```

## 10.2. End-To-End Testing of Batch Jobs

'End To End' 테스트는 배치 job을 처음부터 끝까지 완전히 실행시키는 테스트로 정의할 수 있다.
테스트 조건을 설정하고, job을 실행하고, 마지막 결과까지 검증까지 테스트한다.

아래 예시는 데이터베이스에서 데이터를 조회하고 플랫(flat) 파일에 쓰는 배치 job이다.
테스트 메소드는 데이터베이스에 테스트 데이터를 세팅하는 것으로 시작한다.
CUSTOMER 테이블을 비우고, 10개의 레코드를 새로 생성한다.
그 다음 `launchJob()` 메소드로 `Job`을 실행한다. 
`launchJob()` 메소드는 `JobLauncherTestUtils` 클래스가 제공하는 메소드다. 
`JobLauncherTestUtils` 클래스에는 특정 파라미터로 테스트할 수 있는 
`launchJob(JobParameters)` 메소드도 있다.
`launchJob()` 메소드가 리턴하는 `JobExecution` 객체로 `Job`의 상태를 검증할 수 있다.
여기선 `Job`이 "COMPLETED" 상태로 끝나는 걸 검증한다:

```java
@SpringBatchTest
@RunWith(SpringRunner.class)
@ContextConfiguration(classes=SkipSampleConfiguration.class)
public class SkipSampleFunctionalTests {

    @Autowired
    private JobLauncherTestUtils jobLauncherTestUtils;

    private SimpleJdbcTemplate simpleJdbcTemplate;

    @Autowired
    public void setDataSource(DataSource dataSource) {
        this.simpleJdbcTemplate = new SimpleJdbcTemplate(dataSource);
    }

    @Test
    public void testJob() throws Exception {
        simpleJdbcTemplate.update("delete from CUSTOMER");
        for (int i = 1; i <= 10; i++) {
            simpleJdbcTemplate.update("insert into CUSTOMER values (?, 0, ?, 100000)",
                                      i, "customer" + i);
        }

        JobExecution jobExecution = jobLauncherTestUtils.launchJob();


        Assert.assertEquals("COMPLETED", jobExecution.getExitStatus().getExitCode());
    }
}
```

## 10.3. Testing Individual Steps

배치 job이 복잡해지면 end-to-end 테스트로만은 관리할 수 없다.
이 케이스엔 각 step을 따로 테스트하는 게 좋다.
`JobLauncherTestUtils` 클래스에는
step 이름을 받아 그 `Step`을 실행하는 `launchStep` 메소드가 있다.
이 방법을 사용하면 각 step에서 필요한 데이터만 세팅하고 곧바로 검증하는 식으로 테스트할 수 있다.
아래 예제는 `launchStep` 메소드를 사용해 이름으로 `Step`을 로딩하는 예제이다:

```java
JobExecution jobExecution = jobLauncherTestUtils.launchStep("loadFileStep");
``` 

## 10.4. Testing Step-Scoped Components

런타임에 step에 설정하는 컴포넌트는 step 스코프로 선언되어
step이나 job 컨텍스트에 나중에 바인딩(late binding)되는 경우가 있다.
실제로 step이 실행중인 것처럼 컨텍스트를 생성하지 않으면
독립적으로 테스트하기 매우 까다롭다.
스프링 배치에는 이를 위한 두 가지 컴포넌트가 있다:
`StepScopeTestExecutionListener`와 `StepScopeTestUtils`.

아래처럼 이 리스너를 클래스 레벨에 선언하면
각 테스트 메소드마다 step execution 컨텍스트를 만든다:

```java
@ContextConfiguration
@TestExecutionListeners( { DependencyInjectionTestExecutionListener.class,
    StepScopeTestExecutionListener.class })
@RunWith(SpringRunner.class)
public class StepScopeTestExecutionListenerIntegrationTests {

    // This component is defined step-scoped, so it cannot be injected unless
    // a step is active...
    @Autowired
    private ItemReader<String> reader;

    public StepExecution getStepExecution() {
        StepExecution execution = MetaDataInstanceFactory.createStepExecution();
        execution.getExecutionContext().putString("input.data", "foo,bar,spam");
        return execution;
    }

    @Test
    public void testReader() {
        // The reader is initialized and bound to the input data
        assertNotNull(reader.read());
    }

}
```

`TestExecutionListeners`는 두 종류가 있다.
하나는 스프링 테스트 프레임워크에서 제공하는 것으로,
설정된 어플리케이션 컨텍스트로 의존성(dependency)을 관리해 reader를 주입한다.
다른 하나는 스프링 배치에서 제공하는 `StepScopeTestExecutionListener`다.
이 리스너는 팩토리 메소드를 찾아 `StepExecution`을 생성하고,
런타임에 `Step`이 실행됐을 때 처럼, 테스트 메소드의 컨텍스트로 사용할 수 있다.
팩토리 메소드는 각 메소드의 선언을 보고 결정한다 (`StepExecution`을 반환해야 한다).
적절한 팩토리 메소드가 없으면 디폴트 `StepExecution`을 생성한다.

4.1 버전부터 테스트 클래스에 `@SpringBatchTest`를 선언하면 
`StepScopeTestExecutionListener`와 
`JobScopeTestExecutionListener`를 테스트 execution 리스너로 임포트한다.
앞에 나온 예시는 아래처럼 설정할 수 있다: 

```java
@SpringBatchTest
@RunWith(SpringRunner.class)
@ContextConfiguration
public class StepScopeTestExecutionListenerIntegrationTests {

    // This component is defined step-scoped, so it cannot be injected unless
    // a step is active...
    @Autowired
    private ItemReader<String> reader;

    public StepExecution getStepExecution() {
        StepExecution execution = MetaDataInstanceFactory.createStepExecution();
        execution.getExecutionContext().putString("input.data", "foo,bar,spam");
        return execution;
    }

    @Test
    public void testReader() {
        // The reader is initialized and bound to the input data
        assertNotNull(reader.read());
    }

}
```

step scope를 테스트 메소드를 실행하는 동안으로 설정하고 싶다면 리스너를 쓰는게 편리하다.
좀 더 유연하지만, 조금 극단적인 `StepScopeTestUtils`도 있다.
아래 예제는 이전에 사용한 reader로 item 수를 계산한다:

```java
int count = StepScopeTestUtils.doInStepScope(stepExecution,
    new Callable<Integer>() {
      public Integer call() throws Exception {

        int count = 0;

        while (reader.read() != null) {
           count++;
        }
        return count;
    }
});
``` 

## 10.5. Validating Output Files

데이터베이스에 write하는 배치 job이라면
데이터베이스에 질의해서 결과가 기대한 대로인지 쉽게 검증할 수 있다.
하지만 파일에 write하는 배치 job도 결과 파일을 검증하는 일은 똑같이 중요하다.
스프링 배치는 결과 파일을 쉽게 검증할 수 있는 `AssertFile` 클래스를 제공한다.
`assertFileEquals` 메소드는 `File` 객체 두 개 (또는 `Resource` 객체 두 개)를 받아
라인별로 두 파일 내용이 같은지 검증한다.
따라서 아래처럼 예상되는 파일을 만들어서 실제 결과와 비교할 수 있다:

```java
private static final String EXPECTED_FILE = "src/main/resources/data/input.txt";
private static final String OUTPUT_FILE = "target/test-outputs/output.txt";

AssertFile.assertFileEquals(new FileSystemResource(EXPECTED_FILE),
                            new FileSystemResource(OUTPUT_FILE));
```

## 10.6. Mocking Domain Objects

스프링 배치 컴포넌트로 단위 테스트나 통합 테스트를 만들 때 주로 겪는
다른 이슈는 도메인 객체를 어떻게 모킹할지이다.
좋은 예시로 아래 코드에서 보이는 `StepExecutionListener`가 있다:

```java
public class NoWorkFoundStepExecutionListener extends StepExecutionListenerSupport {

    public ExitStatus afterStep(StepExecution stepExecution) {
        if (stepExecution.getReadCount() == 0) {
            return ExitStatus.FAILED;
        }
        return null;
    }
}
```

위 리스너는 프레임워크에서 제공하고 있으며,
read 카운트를 확인해 0이면 step이 수행되지 않은 것으로 표시한다.
위 예제는 간단하지만, 단위 테스트하고자 하는 클래스가
스프링 배치 도메인 객체에서 사용하는 인터페이스를 구현한 클래스일 때
겪을 문제를 보여주기 위해 가져왔다.
앞에 나온 리스너를 위한 단위 테스트를 만든다고 가정해 보자: 

```java
private NoWorkFoundStepExecutionListener tested = new NoWorkFoundStepExecutionListener();

@Test
public void noWork() {
    StepExecution stepExecution = new StepExecution("NoProcessingStep",
                new JobExecution(new JobInstance(1L, new JobParameters(),
                                 "NoProcessingJob")));

    stepExecution.setExitStatus(ExitStatus.COMPLETED);
    stepExecution.setReadCount(0);

    ExitStatus exitStatus = tested.afterStep(stepExecution);
    assertEquals(ExitStatus.FAILED.getExitCode(), exitStatus.getExitCode());
}
```

스프링 배치 도메인은 객체 지향 원칙을 잘 따르기 때문에,
`StepExecution`을 생성하려면 `JobExecution`이 필요하고,
`JobExecution` 은 `JobInstance`와 `JobParameters`가 필요하다.
견고한 도메인 모델로서는 장점일 수 있으나
스텁(stub) 오브젝트가 많아 단위 테스트가 장황해진다.
스프링 배치 테스트 모듈은 이를 위해
도메인 오브젝트를 생성하는 팩토리를 제공한다: `MetaDataInstanceFactory`.
아래 보이는 것처럼, 이 팩토리가 있으면 단위 테스트를 보다 간결하게 작성할 수 있다:

```java
private NoWorkFoundStepExecutionListener tested = new NoWorkFoundStepExecutionListener();

@Test
public void testAfterStep() {
    StepExecution stepExecution = MetaDataInstanceFactory.createStepExecution();

    stepExecution.setExitStatus(ExitStatus.COMPLETED);
    stepExecution.setReadCount(0);

    ExitStatus exitStatus = tested.afterStep(stepExecution);
    assertEquals(ExitStatus.FAILED.getExitCode(), exitStatus.getExitCode());
}
```

위에선 간단한 `StepExecution`을 만드는 메소드를 사용했는데, 
팩토리 내에는 다른 메소드도 많다.
전체 메소드는 [Javadoc](https://docs.spring.io/spring-batch/docs/current/api/org/springframework/batch/test/MetaDataInstanceFactory.html)
에서 확인할 수 있다.

> 전체 목차는 [여기](https://godekdls.github.io/Spring%20Batch/contents/) 에 있습니다.
