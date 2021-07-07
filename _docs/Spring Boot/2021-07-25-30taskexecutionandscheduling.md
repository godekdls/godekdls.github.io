---
title: Task Execution and Scheduling
category: Spring Boot
order: 30
permalink: /Spring%20Boot/task-execution-and-scheduling/
description: 스프링 부트에서 비동기 태스크 실행하고 스케줄링하기
image: ./../../images/springboot/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 부트
originalRefLink: https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#features.task-execution-and-scheduling
parent: Spring Boot Features
parentUrl: /Spring%20Boot/spring-boot-features/
---
<script>defaultLanguages = ['properties']</script>

---

## 7.22. Task Execution and Scheduling

컨텍스트에 `Executor` 빈이 없을 때 스프링 부트는 `ThreadPoolTaskExecutor`를 자동 설정하며, 비동기 태스크를 실행할 때와 (`@EnableAsync`) 스프링 MVC로 비동기 요청을 처리할 때 자동으로 연계시킬 수 있을 만한 기본값들을 사용한다.

> 컨텍스트에 커스텀 `Executor`를 정의했을 땐, 전형적인 태스크를 실행할 땐 (ex. `@EnableAsync`) 투명하게 이 빈을 사용하게 되지만, 스프링 MVC에선 `AsyncTaskExecutor` 구현체(이름은 `applicationTaskExecutor`)가 필요하기 때문에 설정되지 않는다. 이땐 비동기 태스크를 처리하는 방식에 따라 커스텀 `Executor`대신 `ThreadPoolTaskExecutor`를 사용하거나, `ThreadPoolTaskExecutor`와 커스텀 `Executor`를 래핑하는 `AsyncConfigurer`를 둘 다 정의하면 된다.
>
> 자동 설정된 `TaskExecutorBuilder`를 사용하면 자동 설정에서 기본적으로 하는 일을 그대로 수행하는 인스턴스를 쉽게 만들 수 있다.

스레드 풀에선 8개의 코어 스레드를 사용하며, 부하에 따라 늘어나거나 줄어들 수 있다. 이 디폴트 설정은 다음 예제처럼 `spring.task.execution` 네임스페이스를 사용하면 세세하게 변경할 수 있다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.task.execution.pool.max-size=16
spring.task.execution.pool.queue-capacity=100
spring.task.execution.pool.keep-alive=10s
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  task:
    execution:
      pool:
        max-size: 16
        queue-capacity: 100
        keep-alive: "10s"
```

여기에선 스레드 풀이 bounded 큐를 사용하도록 변경되어, 큐가 가득 차면 (100개의 태스크) 최대 스레드 16개까지 풀이 증가한다. 풀 축소는 조금 더 공격적인데, 10초 동안 유휴 상태면 스레드를 회수한다 (기본값은 60초다).

예약된 태스크를 실행할 때도 필요하다면 (ex. `@EnableScheduling`) `ThreadPoolTaskScheduler`도 자동으로 설정할 수 있다. 스레드 풀에선 기본적으로 스레드 하나를 사용하며, 이 설정은 다음 예제처럼 `spring.task.scheduling` 네임스페이스를 통해 세세하게 조정할 수 있다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.task.scheduling.thread-name-prefix=scheduling-
spring.task.scheduling.pool.size=2
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  task:
    scheduling:
      thread-name-prefix: "scheduling-"
      pool:
        size: 2
```

커스텀 executor나 스케줄러를 만들어야 할 땐 `TaskExecutorBuilder`와 `TaskSchedulerBuilder` 모두 컨텍스트에 있는 빈을 이용할 수 있다.