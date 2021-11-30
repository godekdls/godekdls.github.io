---
title: Batch Job Restart
navTitle: Restarting Batch Jobs
category: Spring Cloud Data Flow
order: 78
permalink: /Spring%20Cloud%20Data%20Flow/feature-guides.batch.restarting/
description: Spring Cloud Data Flow 대시보드에서 스프링 배치 job 재시작하기
image: ./../../images/springclouddataflow/SCDF-job-restart.webp
lastmod: 2021-12-02T00:33:00+09:00
comments: true
originalRefName: 스프링 클라우드 데이터 플로우
originalRefLink: https://dataflow.spring.io/docs/feature-guides/batch/restarting/
parent: Feature guides
parentUrl: /Spring%20Cloud%20Data%20Flow/feature-guides/
subparent: Batch Feature Guides
subparentNavTitle: Batch
subparentUrl: /Spring%20Cloud%20Data%20Flow/feature-guides.batch/
---

---

Spring Cloud Data Flow를 사용하면 스프링 배치 Job을 재시작할 수 있다. 예를 들어 스프링 배치 Job이 실행에 실패하면 SCDF 대시보드에서 재시작해서 중단됐던 곳부터 Batch-job을 재개할 수 있다. 이 섹션에선 배치 job을 재시작하는 방법을 보여준다.

### 목차

- [Restarting a Batch Job](#restarting-a-batch-job)

---

## Restarting a Batch Job

스프링 배치 Job을 다시 시작하려면 UI 왼쪽에 있는 **Jobs** 탭을 클릭해서 Jobs 페이지로 이동해라.

![Create Schedule](./../../images/springclouddataflow/SCDF-job-page.webp)

이제 재시작할 job을 식별해보자. 이 예시에선 (아래 이미지 참고) `job1`이 `FAILED` 상태를 가지고 있다. 따라서 UI에선 이 배치 job을 재시작할 수 있는 옵션이 보인다. 재시작을 진행하려면, `job1`과 연결된 드롭다운 버튼을 클릭하고 **Restart**를 선택해라:

![Create Schedule](./../../images/springclouddataflow/SCDF-job-restart.webp)

이제 대화 상자가 나타나 job을 재시작할 것인지를 물어볼 거다. **RESTART** 버튼을 클릭해라.

![Create Schedule](./../../images/springclouddataflow/SCDF-job-restart-verify.webp)

이 시점에 Spring Cloud Data Flow는 이 스프링 배치 Job을 위한 태스크를 다시 기동시킨다. Job이 에러 없이 작동을 마치고 나면 `job1`이 정상적으로 완료되었다는 것을 확인 수 있다.

![Create Schedule](./../../images/springclouddataflow/SCDF-job-page-after-restart.webp)