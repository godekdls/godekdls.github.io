---
title: Quartz Scheduler
category: Spring Boot 2.X
order: 29
permalink: /Spring%20Boot/quartz-scheduler/
description: 스프링 부트에서 Quartz 스케줄러 사용하기
image: ./../../images/springboot/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 부트
originalRefLink: https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#features.quartz
parent: Spring Boot Features
parentUrl: /Spring%20Boot/spring-boot-features/
priority: 0.4
---
<script>defaultLanguages = ['properties']</script>

---

## 7.21. Quartz Scheduler

스프링 부트를 사용하면 `spring-boot-starter-quartz` "스타터"를 활용하는 등, [Quartz 스케줄러](https://www.quartz-scheduler.org/) 작업을 좀 더 수월하게 진행할 수 있다. 클래스패스에 Quartz가 있으면 `Scheduler`를 자동으로 설정한다 (`SchedulerFactoryBean`으로 추상화되어 있다).

아래 타입 빈들은 자동으로 가져와서 `Scheduler`와 연결한다:

- `JobDetail`: 특정 job을 정의한다. `JobDetail` 인스턴스는 `JobBuilder` API로 빌드할 수 있다.
- `Calendar`.
- `Trigger`: 특정 job을 언제 트리거할지를 정의한다.

기본적으로는 인메모리 `JobStore`를 사용한다. 하지만 애플리케이션에서 `DataSource` 빈을 사용할 수 있을 땐, `spring.quartz.job-store-type` 프로퍼티를 그에 맞게 설정해주면 JDBC 기반 저장소를 설정할 수 있다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.quartz.job-store-type=jdbc
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  quartz:
    job-store-type: "jdbc"
```

JDBC 저장소를 사용할 땐, 다음 예제처럼 기동 시에 스키마를 초기화할 수 있다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.quartz.jdbc.initialize-schema=always
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  quartz:
    jdbc:
      initialize-schema: "always"
```

> 기본적으로 데이터베이스를 감지하면 Quartz 라이브러리에서 제공하는 표준 스크립트를 통해 초기화한다. 이런 스크립트들은 기존 테이블을 제거<sup>drop</sup>해서, 결과적으론 재시작할 때마다 모든 트리거를 삭제하게 된다. `spring.quartz.jdbc.schema` 프로퍼티를 설정하면 커스텀 스크립트를 제공할 수도 있다.

Quartz에서 애플리케이션의 메인 `DataSource` 이외의 다른 `DataSource`를 사용하려면, `DataSource` 빈을 선언하고 `@Bean` 메소드에 `@QuartzDataSource` 어노테이션을 달아라. 이렇게 하면 `SchedulerFactoryBean`과 스키마 초기화 모두 Quartz 전용 `DataSource`를 사용한다. 마찬가지로 Quartz에서 애플리케이션의 메인 `TransactionManager` 대신 다른 `TransactionManager`를 사용하려면, `TransactionManager` 빈을 선언하고 `@Bean` 메소드에 `@QuartzTransactionManager` 어노테이션을 선언해라.

기본적으로는 설정에서 만들어지는 job은, 이미 등록돼서 persistent job 저장소에서 읽어오는 job을 덮어쓰지 않는다. 기존 job 정의를 덮어쓰고 싶으면 `spring.quartz.overwrite-existing-jobs` 프로퍼티를 설정해라.

Quartz 스케줄러 설정은 `spring.quartz` 프로퍼티로 커스텀할 수 있으며, 코드로 `SchedulerFactoryBean`을 커스텀할 수 있는 `SchedulerFactoryBeanCustomizer` 빈을 사용해도 된다. 그외 다른 Quartz 전용 고급 설정은 `spring.quartz.properties.*`를 통해 커스텀할 수 있다.

> Quartz에선 `spring.quartz.properties`를 통해 스케줄러를 설정할 수 있기 때문에, 특히 `Executor` 빈을 이 스케줄러와 연계시키진 않는다. task executor를 커스텀해야 한다면 `SchedulerFactoryBeanCustomizer` 구현을 검토해봐라.

Job에는 setter를 정의해서 데이터 맵 프로퍼티를 주입할 수 있다. 다른 평범한 빈들도 비슷한 방법으로 주입할 수 있다:

```java
public class MySampleJob extends QuartzJobBean {

    // fields ...

    // Inject "MyService" bean
    public void setMyService(MyService myService) {
        this.myService = myService;
    }

    // Inject the "name" job data property
    public void setName(String name) {
        this.name = name;
    }

    @Override
    protected void executeInternal(JobExecutionContext context) throws JobExecutionException {
        this.myService.someMethod(context.getFireTime(), this.name);
    }

}
```