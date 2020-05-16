---
title: Contents
category: Spring Batch
order: 1
---

아래 공식 reference를 한글로 번역한 문서입니다.

https://docs.spring.io/spring-batch/docs/4.2.x/reference/html/index-single.html

> 4.2.x 버전을 기준으로 합니다.
>
> 용이한 검색을 위해 소제목을 포함한 타이틀은 영문을 유지했습니다.
>
> 원활한 번역을 위해 영문 문장과 한글 문장을 1:1로 번역하지 않았습니다.
>
> 한글로 완벽하게 표현할 수 없는 일부 개발 용어는 영문 단어로 유지했습니다.
>
> 오타, 오역은 제보 부탁드립니다 godekdls@hanmail.net

목차:

1. [Spring Batch Introduction](https://godekdls.github.io/Spring%20Batch/introduction/)
 - [1.1 Background](https://godekdls.github.io/Spring%20Batch/introduction/#11-background)
 - [1.2. Usage Scenarios](https://godekdls.github.io/Spring%20Batch/introduction/#12-usage-scenarios)
 - [1.3. Spring Batch Architecture](https://godekdls.github.io/Spring%20Batch/introduction/#13-Spring-batch-architecture)
 - [1.4. General Batch Piplelines and Guidlines](https://godekdls.github.io/Spring%20Batch/introduction/#14-general-batch-piplelines-and-guidlines)
 - [1.5. Batch Processing Strategies](https://godekdls.github.io/Spring%20Batch/introduction/#15-batch-processing-strategies)
2. [What’s New in Spring Batch 4.2](https://godekdls.github.io/Spring%20Batch/whatsnew/)
 - [2.1. Batch metrics with Micrometer](https://godekdls.github.io/Spring%20Batch/whatsnew/#21-batch-metrics-with-micrometer)
 - [2.2. Apache Kafka item reader/writer](https://godekdls.github.io/Spring%20Batch/whatsnew/#22-apache-kafka-item-readerwriter)
 - [2.3. Apache Avro item reader/writer](https://godekdls.github.io/Spring%20Batch/whatsnew/#23-apache-avro-item-readerwriter)
 - [2.4. Documentation updates](https://godekdls.github.io/Spring%20Batch/whatsnew/#24-documentation-updates)
3. [The Domain Language of Batch](https://godekdls.github.io/Spring%20Batch/domainlanguage/)
 - [3.1. Job](https://godekdls.github.io/Spring%20Batch/domainlanguage/#31-job)
  - [3.1.1. JobInstance](https://godekdls.github.io/Spring%20Batch/domainlanguage/#311-jobinstance)
  - [3.1.2. JobParameters](https://godekdls.github.io/Spring%20Batch/domainlanguage/#312-jobparameters)
  - [3.1.3. JobExecution](https://godekdls.github.io/Spring%20Batch/domainlanguage/#313-jobexecution)
 - [3.2. Step](https://godekdls.github.io/Spring%20Batch/domainlanguage/#32-step)
  - [3.2.1. StepExecution](https://godekdls.github.io/Spring%20Batch/domainlanguage/#321-stepexecution)
 - [3.3. ExecutionContext](https://godekdls.github.io/Spring%20Batch/domainlanguage/#33-executioncontext)
 - [3.4. JobRepository](https://godekdls.github.io/Spring%20Batch/domainlanguage/#34-jobrepository)
 - [3.5. JobLauncher](https://godekdls.github.io/Spring%20Batch/domainlanguage/#35-joblauncher)
 - [3.6. Item Reader](https://godekdls.github.io/Spring%20Batch/domainlanguage/#36-item-reader)
 - [3.7. Item Writer](https://godekdls.github.io/Spring%20Batch/domainlanguage/#37-item-writer)
 - [3.8. Item Processor](https://godekdls.github.io/Spring%20Batch/domainlanguage/#38-item-processor)
4. [Configuring and Running a Job](https://godekdls.github.io/Spring%20Batch/configuringandrunningajob/)
 - [4.1. Configuring a Job](https://godekdls.github.io/Spring%20Batch/configuringandrunningajob/#41-configuring-a-job)
  - [4.1.1. Restartability](https://godekdls.github.io/Spring%20Batch/configuringandrunningajob/#411-restartability)
  - [4.1.2. Intercepting Job Execution](https://godekdls.github.io/Spring%20Batch/configuringandrunningajob/#412-intercepting-job-execution)
  - [4.1.4. JobParametersValidator](https://godekdls.github.io/Spring%20Batch/configuringandrunningajob/#414-jobparametersvalidator)
- [4.2. Java Config](https://godekdls.github.io/Spring%20Batch/configuringandrunningajob/#42-java-config)
- [4.3. Configuring a JobRepository](https://godekdls.github.io/Spring%20Batch/configuringandrunningajob/#43-configuring-a-jobrepository)
  - [4.3.1. Transaction Configuration for the JobRepository](https://godekdls.github.io/Spring%20Batch/configuringandrunningajob/#431-transaction-configuration-for-the-jobrepository)
  - [4.3.2. Changing the Table Prefix](https://godekdls.github.io/Spring%20Batch/configuringandrunningajob/#432-changing-the-table-prefix)
  - [4.3.3. In-Memory Repository](https://godekdls.github.io/Spring%20Batch/configuringandrunningajob/#433-in-memory-repository)
  - [4.3.4. Non-standard Database Types in a Repository](https://godekdls.github.io/Spring%20Batch/configuringandrunningajob/#434-non-standard-database-types-in-a-repository)
- [4.4. Configuring a JobLauncher](https://godekdls.github.io/Spring%20Batch/configuringandrunningajob/#44-configuring-a-joblauncher)
- [4.5. Running a Job](https://godekdls.github.io/Spring%20Batch/configuringandrunningajob/#45-running-a-job)
  - [4.5.1. Running Jobs from the Command Line](https://godekdls.github.io/Spring%20Batch/configuringandrunningajob/#451-running-jobs-from-the-command-line)
    - [The CommandLineJobRunner](https://godekdls.github.io/Spring%20Batch/configuringandrunningajob/#the-commandlinejobrunner)
    - [ExitCodes](https://godekdls.github.io/Spring%20Batch/configuringandrunningajob/#exitcodes)
  - [4.5.2. Running Jobs from within a Web Container](https://godekdls.github.io/Spring%20Batch/configuringandrunningajob/#452-running-jobs-from-within-a-web-container)
- [4.6. Advanced Meta-Data Usage](https://godekdls.github.io/Spring%20Batch/configuringandrunningajob/#46-advanced-meta-data-usage)
  - [4.6.1. Querying the Repository](https://godekdls.github.io/Spring%20Batch/configuringandrunningajob/#461-querying-the-repository)
  - [4.6.2. JobRegistry](https://godekdls.github.io/Spring%20Batch/configuringandrunningajob/#462-jobregistry)
  - [4.6.3. JobOperator](https://godekdls.github.io/Spring%20Batch/configuringandrunningajob/#463-joboperator)
  - [4.6.4. JobParametersIncrementer](https://godekdls.github.io/Spring%20Batch/configuringandrunningajob/#464-jobparametersincrementer)
  - [4.6.5. Stopping a Job](https://godekdls.github.io/Spring%20Batch/configuringandrunningajob/#465-stopping-a-job)
  - [4.6.6. Aborting a Job](https://godekdls.github.io/Spring%20Batch/configuringandrunningajob/#466-aborting-a-job)
5. [Configuring a Step](https://godekdls.github.io/Spring%20Batch/configuringastep/)
6. [ItemReaders and ItemWriters](https://godekdls.github.io/Spring%20Batch/itemreadersanditemwriters/)
7. Scaling and Parallel Processing
8. Repeat
9. [Retry](https://godekdls.github.io/Spring%20Batch/retry/)
10. Unit Testing
11. Common Batch Patterns
12. JSR-352 Support
13. Spring Batch Integration
14. Monitoring and metrics
