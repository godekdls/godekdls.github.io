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

This section describes stereotypes relating to the concept of a batch job. A Job is an entity that encapsulates an entire batch process. As is common with other Spring projects, a Job is wired together with either an XML configuration file or Java-based configuration. This configuration may be referred to as the "job configuration". However, Job is just the top of an overall hierarchy, as shown in the following diagram: