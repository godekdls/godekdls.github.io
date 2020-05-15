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
