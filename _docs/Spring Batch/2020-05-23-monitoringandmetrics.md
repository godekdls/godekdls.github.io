---
title: Monitoring and metrics
category: Spring Batch
order: 15
permalink: /Spring%20Batch/monitoringandmetrics/
description: 스프링배치 모니터링, 메트릭 수집 한글 번역
image: ./../../images/springbatch/batch-stereotypes.png
lastmod: 2020-06-08T19:00:00+09:00
---

> [스프링 배치 공식 reference](https://docs.spring.io/spring-batch/docs/4.2.x/reference/html/index-single.html#monitoring-and-metrics)를 한글로 번역한 문서입니다.
>
> 전체 목차는 [여기](https://godekdls.github.io/Spring%20Batch/contents/)에 있습니다.

### 목차

- [14.1. Built-in metrics](#141-built-in-metrics)
- [14.2. Custom metrics](#142-custom-metrics)

---

스프링 배치 4.2 버전부터 [Micrometer](https://micrometer.io/) 기반
배치 모니터링과 메트릭을 지원한다.
이번 장에서는 기본으로 제공하는 메트릭과 커스텀 메트릭을 설정하는 법을 설명한다.

---

## 14.1. Built-in metrics

메트릭 수집은 별도 설정이 필요 없다.
스프링이 제공하는 모든 메트릭은 `spring.batch` 프리픽스를 사용해서
[Micrometer’s global registry](https://micrometer.io/docs/concepts#_global_registry)에
등록된다. 
모든 메트릭은 아래 테이블에서 설명한다:

|Metric Name|Type|Description|
|:-----------------:	|:-------------:	|:-------------:	|
|`spring.batch.job`|`TIMER`|job 실행 소요 시간|
|`spring.batch.job.active`|`LONG_TASK_TIMER`|현재 active 상태인 job|
|`spring.batch.step`|`TIMER`|step 실행 소요 시간|
|`spring.batch.item.read`|`TIMER`|아이템을 읽는 데 걸린 시간|
|`spring.batch.item.process`|`TIMER`|아이템을 처리하는 데 걸린 시간|
|`spring.batch.item.write`|`TIMER`|청크를 쓰는 데 걸린 시간|

---

## 14.2. Custom metrics

커스텀 컴포넌트에서 필요한 메트릭을 추가하고 싶다면
Micrometer API를 직접 사용하는 것을 권장한다.
다음은 `Tasklet`에서 걸린 시간을 측정하는 예제다:

```java
import io.micrometer.core.instrument.Metrics;
import io.micrometer.core.instrument.Timer;

import org.springframework.batch.core.StepContribution;
import org.springframework.batch.core.scope.context.ChunkContext;
import org.springframework.batch.core.step.tasklet.Tasklet;
import org.springframework.batch.repeat.RepeatStatus;

public class MyTimedTasklet implements Tasklet {

	@Override
	public RepeatStatus execute(StepContribution contribution, ChunkContext chunkContext) {
		Timer.Sample sample = Timer.start(Metrics.globalRegistry);
		String status = "success";
		try {
			// do some work
		} catch (Exception e) {
			// handle exception
			status = "failure";
		} finally {
			sample.stop(Timer.builder("my.tasklet.timer")
					.description("Duration of MyTimedTasklet")
					.tag("status", status)
					.register(Metrics.globalRegistry));
		}
		return RepeatStatus.FINISHED;
	}
}
```

---

> 전체 목차는 [여기](https://godekdls.github.io/Spring%20Batch/contents/)에 있습니다.
