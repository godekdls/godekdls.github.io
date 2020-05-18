---
title: ItemReaders and ItemWriters
category: Spring Batch
order: 7
---

### 목차

- [6.1. ItemReader](#61-itemreader)
- [6.2. ItemWriter](#62-itemwriter)
- [6.3. ItemProcessor](#63-itemprocessor)
  + [6.3.1. Chaining ItemProcessors](#631-chaining-itemprocessors)
  + [6.3.2. Filtering Records](#632-filtering-records)
  + [6.3.3. Fault Tolerance](#633-fault-tolerance)
- [6.4. ItemStream](#64-itemstream)
- [6.5. The Delegate Pattern and Registering with the Step](#65-the-delegate-pattern-and-registering-with-the-step)
- [6.6. Flat Files](#66-flat-files)
  + [6.6.1. The FieldSet](#661-the-fieldset)
  + [6.6.2. FlatFileItemReader](#662-flatfileitemreader)
    * [LineMapper](#linemapper)
    * [LineTokenizer](#linetokenizer)
    * [FieldSetMapper](#fieldsetmapper)
    * [DefaultLineMapper](#defaultlinemapper)
    * [Simple Delimited File Reading Example](#simple-delimited-file-reading-example)
    * [Mapping Fields by Name](#mapping-fields-by-name)
    * [Automapping FieldSets to Domain Objects](#automapping-fieldsets-to-domain-objects)
    * [Fixed Length File Formats](#fixed-length-file-formats)
    * [Multiple Record Types within a Single File](#multiple-record-types-within-a-single-file)
    * [Exception Handling in Flat Files](#exception-handling-in-flat-files)
  + [6.6.3. FlatFileItemWriter](#663-flatfileitemwriter)
- [6.7. XML Item Readers and Writers](#67-xml-item-readers-and-writers)
  + [6.7.1. StaxEventItemReader](#671-staxeventitemreader)
  + [6.7.2. StaxEventItemWriter](#672-staxeventitemwriter)
- [6.8. JSON Item Readers And Writers](#68-json-item-readers-and-writers)
  + [6.8.1. JsonItemReader](#681-jsonitemreader)
  + [6.8.2. JsonFileItemWriter](#682-jsonfileitemwriter)
- [6.9. Multi-File Input](#69-multi-file-input)
- [6.10. Database](#610-database)
  + [6.10.1. Cursor-based ItemReader Implementations](#6101-cursor-based-itemreader-implementations)
    * [JdbcCursorItemReader](#jdbccursoritemreader)
    * [HibernateCursorItemReader](#hibernatecursoritemreader)
    * [StoredProcedureItemReader](#storedprocedureitemreader)
  + [6.10.2. Paging ItemReader Implementations](#6102-paging-itemreader-implementations)
    * [JdbcPagingItemReader](#jdbcpagingitemreader)
    * [JpaPagingItemReader](#jpapagingitemreader)
  + [6.10.3. Database ItemWriters](#6103-database-itemwriters)
- [6.11. Reusing Existing Services](#611-reusing-existing-services)
- [6.12. Validating Input](#612-validating-input)
- [6.13. Preventing State Persistence](#613-preventing-state-persistence)
- [6.14. Creating Custom ItemReaders and ItemWriters](#614-creating-custom-itemreaders-and-itemwriters)
  + [6.14.1. Custom ItemReader Example](#6141-custom-itemreader-example)
    * [Making the ItemReader Restartable](#making-the-itemreader-restartable)
  + [6.14.2. Custom ItemWriter Example](#6142-custom-itemwriter-example)
    * [Making the ItemWriter Restartable](#making-the-itemwriter-restartable)
- [6.15. Item Reader and Writer Implementations](#615-item-reader-and-writer-implementations)
  + [6.15.1. Decorators](#6151-decorators)
    * [SynchronizedItemStreamReader](#synchronizeditemstreamreader)
    * [SingleItemPeekableItemReader](#singleitempeekableitemreader)
    * [MultiResourceItemWriter](#multiresourceitemwriter)
    * [ClassifierCompositeItemWriter](#classifiercompositeitemwriter)
    * [ClassifierCompositeItemProcessor](#classifiercompositeitemprocessor)
  + [6.15.2. Messaging Readers And Writers](#6152-messaging-readers-and-writers)
    * [AmqpItemReader](#amqpitemreader)
    * [AmqpItemWriter](#amqpitemwriter)
    * [JmsItemReader](#jmsitemreader)
    * [JmsItemWriter](#jmsitemwriter)
    * [KafkaItemReader](#kafkaitemreader)
    * [KafkaItemWriter](#kafkaitemwriter)
  + [6.15.3. Database Readers](#6153-database-readers)
    * [Neo4jItemReader](#neo4jitemreader)
    * [MongoItemReader](#neo4jitemwriter)
    * [HibernateCursorItemReader](#hibernatecursoritemreader)
    * [HibernatePagingItemReader](#hibernatepagingitemreader)
    * [RepositoryItemReader](#repositoryitemreader)
  + [6.15.4. Database Writers](#6154-database-writers)
    * [Neo4jItemWriter](#neo4jitemwriter)
    * [MongoItemWriter](#mongoitemwriter)
    * [RepositoryItemWriter](#repositoryitemwriter)
    * [HibernateItemWriter](#hibernateitemwriter)
    * [JdbcBatchItemWriter](#jdbcbatchitemwriter)
    * [JpaItemWriter](#jpaitemwriter)
    * [GemfireItemWriter](#gemfireitemwriter)
  + [6.15.5. Specialized Readers](#6155-specialized-readers)
    * [LdifReader](#ldifreader)
    * [MappingLdifReader](#mappingldifreader)
    * [AvroItemReader](#avroitemreader)
  + [6.15.6. Specialized Writers](#6156-specialized-writers)
    * [SimpleMailMessageItemWriter](#simplemailmessageitemwriter)
    * [AvroItemWriter](#avroitemwriter)
  + [6.15.7. Specialized Processors](#6157-specialized-processors)
    * [ScriptItemProcessor](#scriptitemprocessor)

모든 배치 처리는 제일 간단하게 설명하면
다량의 데이터를 읽어서 어떤 계산이나 변환을 수행하고 그 결과를 쓰는 작업이다.
스프링배치는 벌크 read와 write을 위한 세 가지 핵심 인터페이스를 제공한다:
`ItemReader`, `ItemProcessor`, `ItemWriter`.

## 6.1. `ItemReader`

`ItemReader`는 간단한 개념이긴 하지만, 매우 다양한 입력으로부터 데이터를 읽는 수단이다.
대부분의 예제는 아래 예시를 포함한다:

- 플랫(Flat) 파일: 플랫 파일 아이템 reader는
일반적으로 필드가 고정된 위치에 있거나 특정한 특수문자(쉼표같은)로 필드를 구분하는 파일을 읽는다.
- XML: XML `ItemReader`는 파싱, 매핑, 검증에 사용되는 기술과는 독립적으로 XML을 처리한다.
입력 데이터 유효성은 XSD 스키마로 검증한다.
- Database: 데이터베이스에 접근해 처리할 객체에 매핑되는 결과 셋(resultset)을 얻어온다.
디폴트 SQL `ItemReader` 구현체는 `RowMapper`를 호출해서
오브젝트를 리턴하고, 재시작을 대비해 현재 로(row)를 추적하고, 기본적인 통계를 저장하며, 
뒤에서 설명할 개선된 트랜잭션을 제공한다.

다른 예시도 많은데, 이번 챕터에서는 가장 기본적인 것들에 집중하겠다.
사용 가능한 모든 `ItemReader` 구현체는 
[Appendix A](https://docs.spring.io/spring-batch/docs/4.2.x/reference/html/index-single.html#listOfReadersAndWriters) 에 있다.

`ItemReader`는 일반적인 입력 작업을 위한 포괄적 인터페이스이다.
아래는 인터페이스 정의다: 

```java
public interface ItemReader<T> {

    T read() throws Exception, UnexpectedInputException, ParseException, NonTransientResourceException;

}
```

`read` 메소드는 `ItemReader`의 가장 본질적인 역할을 정의한다.
이 메소드는 아이템 하나를 리턴하거나 더 이상 아이템이 없는 경우 `null`을 리턴한다.
아이템 하나는 파일의 한 줄을 의미하거나, 데이터베이스의 로(row) 하나가 될 수도 있고,
XML 파일에선 하나의 엘리먼트일 수도 있다.
보통 아이템은 도메인 오브젝트로 매핑되는데 (`Trade`, `Foo` 등),
꼭 그래야한다는 법은 없다.

`ItemReader`의 구현체는 앞에서 뒤로만 읽고 역행하지 말아야한다 (forward only).
그러나 별도의 트랜잭션 처리가 있는 리소스에서 데이터를 읽는다면 (JMS 큐같이)
`read` 메소드는 롤백 후 다시 호출해도 같은 아이템을 리턴해야한다.
`ItemReader`가 더 이상 처리할 아이템이 없어도 예외를 발생시키지 않는다는 점을 알아둘 필요가 있다.
예를 들어 결과가 0개인 쿼리로 설정된 데이터베이스 `ItemReader`는 
read를 처음 호출할 때부터 `null`을 반환한다.

## 6.2. `ItemWriter`

`ItemWriter`는 `ItemReader`와 비슷하지만 하는 일은 정 반대다.
리소스는 여전히 필요하고, 또 열리고 닫혀야 하지만,
`ItemWriter`는 읽는게 아니라 쓴다는 점이 다르다.
데이터베이스나 큐를 사용한다면 이 동작은 insert, update 또는 send일 것이다.
결과물의 직렬화 형식은 각 job마다 다르다.

`ItemReader`처럼 `ItemWriter`도 꽤 포괄적인 인터페이스다.
아래는 인터페이스 정의다:

```java
public interface ItemWriter<T> {

    void write(List<? extends T> items) throws Exception;

}
```

`ItemReader`의 `read` 메소드처럼 `write` 메소드가 `ItemReader`의 가장 본질적인 역할을 정의한다.
리소스가 열려있다면 전달받은 아이템 리스트를 write한다.
일반적으로 아이템은 청크로 묶여서 결과물을 만들기 때문에,
이 인터페이스는 아이템 하나가 아니라 아이템 리스트를 받는다.
리스트를 전부 쓰고난 다음에 필요한 flush 처리는 write 메소드가 결과를 반환하기 전 수행한다.
예를 들어 하이버네이트 DAO로 쓴다면
각 아이템마다 각각, 여러번 write 메소드를 호출한다.
그러면 writer는 결과를 리턴하기 전 하이버네이트 세션에서 `flush`를 호출한다.

## 6.3. `ItemProcessor`

`ItemReader`와 `ItemWriter`는 각자 맡은 작업을 잘 수행하지만,
write 전에 비지니스 로직을 추가하고 싶다면 어떻게 해야 하는가?
한가지 방법은 composite 패턴을 사용하는 것이다:
다른 `ItemWriter`를 포함하고 있는 `ItemWriter`를 만들거나, 반대로
`ItemReader`가 다른 `ItemReader`를 포함하게 만들거나.
아래 코드는 이 패턴을 사용한 예제이다:

```java
public class CompositeItemWriter<T> implements ItemWriter<T> {

    ItemWriter<T> itemWriter;

    public CompositeItemWriter(ItemWriter<T> itemWriter) {
        this.itemWriter = itemWriter;
    }

    public void write(List<? extends T> items) throws Exception {
        //Add business logic here
       itemWriter.write(items);
    }

    public void setDelegate(ItemWriter<T> itemWriter){
        this.itemWriter = itemWriter;
    }
}
```

앞의 클래스는 다른 `ItemWriter` 하나를 포함하고 있는데,
비지니스 로직을 수행하고 나서 write 처리를 위임한다.
이 패턴을 `ItemReader`에도 사용할 수 있는데, 이 경우는
메인 `ItemReader`에서 읽은 데이터에 추가로 다른 참조 데이터를 읽어들일 수 있다.
`write` 메소드 호출을 직접 제어하고 싶을 때도 유용할 것이다.
그렇지만 write 시에 넘겨받은 데이터를 실제로 쓰기 전에 '변환'만 하면 된다면,
굳이 `write`를 직접 제어할 필요 없다.
item을 수정하기만 하면 된다.
이런 경우를 위해 스프링 배치는 `ItemProcessor` 인터페이스를 제공한다.
아래는 인터페이스 정의다:

```java
public interface ItemProcessor<I, O> {

    O process(I item) throws Exception;
}
```

`ItemProcessor`는 간단하다. 객체 하나를 받아 변환한 객체를 반환한다.
새로 반환하는 객체는 같은 타입일 수도 있고 아닐 수도 있다.
핵심은 process 메소드 안에서 비지니스 로직을 처리할 수 있으며,
그 로직을 만드는 일은 전적으로 개발자에 달려있다는 것이다.
`ItemProcessor`는 step에 직접 연결할 수 있다. 
예를 들어 `ItemReader`는 `Foo` 클래스를 리턴하는데 쓰여기지 전에 `Bar` 타입으로 변경해야 한다고 가정해보자.
아래 예제는 `Foo를` `Bar`로 바꾸는 `ItemProcessor`다:

```java
public class Foo {}

public class Bar {
    public Bar(Foo foo) {}
}

public class FooProcessor implements ItemProcessor<Foo,Bar>{
    public Bar process(Foo foo) throws Exception {
        //Perform simple transformation, convert a Foo to a Bar
        return new Bar(foo);
    }
}

public class BarWriter implements ItemWriter<Bar>{
    public void write(List<? extends Bar> bars) throws Exception {
        //write bars
    }
}
```

위 예제에는 `Foo` 클래스와 `Bar` 클래스, `ItemProcessor` 인터페이스를 구현한
`FooProcessor` 클래스가 있다.
여기선 변환 작업 자체가 간단하지만 다른 복잡한 변환도 가능하다.
`BarWriter`는 `Bar` 객체 리스트를 쓰며 다른 타입이 전달되면 예외를 발생시킨다. 
유사하게 `FooProcessor`도 전달받은 객체가 `Foo`가 아니면 예외를 던진다. 
아래 예제처럼 `FooProcessor`는 `Step`에 주입할 수 있다:

```java
@Bean
public Job ioSampleJob() {
	return this.jobBuilderFactory.get("ioSampleJOb")
				.start(step1())
				.end()
				.build();
}

@Bean
public Step step1() {
	return this.stepBuilderFactory.get("step1")
				.<String, String>chunk(2)
				.reader(fooReader())
				.processor(fooProcessor())
				.writer(barWriter())
				.build();
}
```

### 6.3.1. Chaining ItemProcessors

변환 하나로도 충분한 경우도 많지만
여러 `ItemProcessor` 구현체를 '연결(chian')하고 싶으면 어떻게 해야할까?
이전에 언급한 composite 패턴을 사용하면 된다.
아래 예제는 앞서 나온 예제를 수정해
`Foo`를 `Bar`로 변환하고, 다시 `Foobar` 변환해 write한다:

```java
public class Foo {}

public class Bar {
    public Bar(Foo foo) {}
}

public class Foobar {
    public Foobar(Bar bar) {}
}

public class FooProcessor implements ItemProcessor<Foo,Bar>{
    public Bar process(Foo foo) throws Exception {
        //Perform simple transformation, convert a Foo to a Bar
        return new Bar(foo);
    }
}

public class BarProcessor implements ItemProcessor<Bar,Foobar>{
    public Foobar process(Bar bar) throws Exception {
        return new Foobar(bar);
    }
}

public class FoobarWriter implements ItemWriter<Foobar>{
    public void write(List<? extends Foobar> items) throws Exception {
        //write items
    }
}
```

아래 예제에서는
함께 '연결(chained)'된 `FooProcessor`와 `BarProcessor`가 
최종 결과물로 `Foobar`를 만든다: 

```java
CompositeItemProcessor<Foo,Foobar> compositeProcessor =
                                      new CompositeItemProcessor<Foo,Foobar>();
List itemProcessors = new ArrayList();
itemProcessors.add(new FooTransformer());
itemProcessors.add(new BarTransformer());
compositeProcessor.setDelegates(itemProcessors);
```

이전 예제와 같은 방법으로 `Step`에 composite processor를 설정한다:

```java
@Bean
public Job ioSampleJob() {
	return this.jobBuilderFactory.get("ioSampleJob")
				.start(step1())
				.end()
				.build();
}

@Bean
public Step step1() {
	return this.stepBuilderFactory.get("step1")
				.<String, String>chunk(2)
				.reader(fooReader())
				.processor(compositeProcessor())
				.writer(foobarWriter())
				.build();
}

@Bean
public CompositeItemProcessor compositeProcessor() {
	List<ItemProcessor> delegates = new ArrayList<>(2);
	delegates.add(new FooProcessor());
	delegates.add(new BarProcessor());

	CompositeItemProcessor processor = new CompositeItemProcessor();

	processor.setDelegates(delegates);

	return processor;
}
```

### 6.3.2. Filtering Records

item processor는 `ItemWriter`로 데이터를 넘기기 전 필터링하는 데에도 많이 사용된다.
필터링은 스킵과는 다른 액션이다.
스킵은 데이터가 유효하지 않다는 거고,
필터링은 단순히 데이터를 write하지 않겠다는 뜻이다.

예를 들어 세 가지 유형의 파일을 읽어야하는 배치 job을 떠올려봐라:
insert할 데이터, update할 데이터, delete할 데이터.
만약 시스템이 레코드 삭제를 지원하지 않는다면 
`ItemWriter`에 삭제 대상 데이터를 넘기면 안 된다.
그렇지만 이 데이터가 잘못된 데이터는 아니므로 스킵보단 필터링하고 싶을 것이다.
결과적으로 `ItemWriter`는 insert 용과 update 용 데이터만 받는다.

아이템을 필터링하고 싶으면 `ItemProcessor`에서 `null`을 리턴하면 된다.
결과가 `null`이라면 프레임워크가 `ItemWriter`에 전달되는
아이템 리스트에서 제외시킨다.
늘 그렇듯 `ItemProcessor`에서 예외가 발생하면 스킵된다.

### 6.3.3. Fault Tolerance

청크가 롤백되면 데이터를 읽을 때 이미 캐시해둔 아이템이 다시 처리될 수도 있다.
내결함성(fault tolerance)이 있는 step이라면 (보통 skip이나 retry가 설정된)
사용할 모든 `ItemProcessor`는 멱등성(idempotence)을 보장해야한다.
보통은 `ItemProcessor`의 입력 데이터는 바꾸지 않고 결과로 사용할 인스턴스만 바꾸는 식으로 구현한다.

## 6.4. `ItemStream`

`ItemReaders`, `ItemWriters` 모두 맡은 역할은 잘 처리하지만,
둘다 다른 인터페이스가 필요한 경우도 있다.
일반적으로 배치 job의 일환으로 reader와 writer는 리소스를 열고(open) 닫아야(close)하며
상태를 저장하기 위한 메커니즘이 필요하다.
아래 예제에 보이는 `ItemStream` 인터페이스는 그런 역할을 담당한다:

```java
public interface ItemStream {

    void open(ExecutionContext executionContext) throws ItemStreamException;

    void update(ExecutionContext executionContext) throws ItemStreamException;

    void close() throws ItemStreamException;
}
```

각 메소드를 설명하기 전 `ExecutionContext`를 짚고 넘어가자.
`ItemReader`로 `ItemStream`도 구현한다면
`read` 메소드 호출 전에 `open` 메소드를 호출해야 파일이나 커넥션이 필요한 리소스에 접근할 수 있다.
`ItemStream`을 구현한 `ItemWriter`도 마찬가지로 같은 규칙이 적용된다.
2장에서 설명했듯이, `ExecutionContext`에 데이터가 있다면
초기 상태가 아닌(처음 실행하는 게 아닌) `ItemReader`와 `ItemWriter`를 실행할 때 사용한다.
반대로 열려 있는 모든 리소스를 안전하게 닫으려면 `close` 메소드를 호출해야 한다.  
`update` 메소드는 주로 현재까지 진행된 모든 상태를 `ExecutionContext`에 저장할 때 사용한다.
커밋 전 데이터베이스에 현재 상태를 저장하려면 커밋 전에 호출해야 한다.

`ItemStream`이 `Step`인 특이한 케이스에선(스프링 배치 코어에서)
매 `StepExecution` 마다 `ExecutionContext`을 생성해 각 execution 상태를 저장하고,
같은 `JobInstance`가 실행되면 이 값을 넘겨준다.
Quartz에 비유하면 `JobDataMap`와 유사하게 동작한다.

## 6.5. The Delegate Pattern and Registering with the Step

`CompositeItemWriter`는 스프링 배치에서 흔히 쓰는 위임(delegation) 패턴 중 하나다.
위임받는 객체(delegate) 자체가 `StepListener`같은 콜백 인터페이스를 구현하는 경우도 있다.
스프링 배치 코어의 `Step`에서 위임 패턴을 사용한다면 
거의 모든 경우 수동으로 `Step`에 등록해야 한다.
`ItemStream`이나 `StepListener` 인터페이스를
`Step`과 직접 연결하는 reader, writer, processor로 구현하면 자동으로 등록된다.
그러나 `Step`은 위임 객체(delegate)는 알 수 없으므로
아래 보이는 예제처럼 listener 또는 stream으로 (필요하다면 둘 다) 직접 주입해야한다:

```java
@Bean
public Job ioSampleJob() {
	return this.jobBuilderFactory.get("ioSampleJob")
				.start(step1())
				.end()
				.build();
}

@Bean
public Step step1() {
	return this.stepBuilderFactory.get("step1")
				.<String, String>chunk(2)
				.reader(fooReader())
				.processor(fooProcessor())
				.writer(compositeItemWriter())
				.stream(barWriter())
				.build();
}

@Bean
public CustomCompositeItemWriter compositeItemWriter() {

	CustomCompositeItemWriter writer = new CustomCompositeItemWriter();

	writer.setDelegate(barWriter());

	return writer;
}

@Bean
public BarWriter barWriter() {
	return new BarWriter();
}
```

## 6.6. Flat Files

플랫(flat) 파일은 벌크 데이터를 교환할 때 가장 흔히 사용하는 방법 중 하나다.
파일을 구성하는 방법을 정한 표준(XSD)이 있는 XML과는 달리
플랫 파일을 읽으려면 파일의 구조를 알고 있어야만 한다. 
In general, all flat files fall into two types: delimited and fixed length. 
구분자를 사용하는(delimited) 파일은 쉼표같은 구분자로 필드를 구분한다.
고정된 길이를 갖는 파일은 
such as a comma. Fixed Length files have fields that are a set length.

### 6.6.1. The `FieldSet`

스프링 배치에서 플랫(flat) 파일을 다룬다면
입력 데이터든 출력 데이터든 상관 없이 `FieldSet`가 제일 중요한 클래스 중 하나다.
파일을 읽기 위한 추상 클래스를 지원하는 아키텍처나 라이브러리는 많지만
보통 `String`이나 `String` 객체의 배열을 리턴한다.
이건 반만 처리한 거나 마찬가지다.
`FieldSet`은 파일 리소스로부터 필드를 바인딩하기 위해 스프링 배치가 제공하는 인터페이스다.
덕분에 데이터베이스 입력과 매우 유사하게 파일을 처리할 수 있다. 
`FieldSet`은 개념적으로 JDBC `ResultSet`과 유사하다. 
`FieldSet`에 `String` 배열로 토큰을 넘겨주기만 하면 된다.
아래 예제에서 보이는 것처럼,
원한다면 `ResultSet`처럼 필드에 이름을 설정해서 인덱스나 이름으로 필드에 접근할 수 있다.

```java
String[] tokens = new String[]{"foo", "1", "true"};
FieldSet fs = new DefaultFieldSet(tokens);
String name = fs.readString(0);
int value = fs.readInt(1);
boolean booleanValue = fs.readBoolean(2);
```

`FieldSet`는 `Date`, long, `BigDecimal` 등 다른 값도 지원한다.
`FieldSet`의 가장 큰 장점은 일관성이다.
여러 배치 job이 각자의 방법으로 다르게 파싱하는 대신,
포맷 예외로 인한 에러를 처리할 때든 간단한 데이터 변환을 할 때든 모두 같은 방법으로 파싱한다.  

### 6.6.2. `FlatFileItemReader`

플랫(flat) 파일은 최대 2차원(표)으로 표현된 데이터라면 어떤 것이든 가능하다.
스프링 배치 프레임워크에서는 `FlatFileItemReader`로 플랫(flat) 파일을 읽는데,
기본적인 플랫(flat) 파일 읽기와 파싱을 지원한다.
`FlatFileItemReader`를 사용하려면 가장 중요한 `Resource`와 `LineMapper` 두 가지가 필요하다.
`LineMapper` 인터페이스는 다음 섹션에서 더 다룰 것이다.
resource 프로퍼티는 스프링 코어의 `Resource`를 가리킨다.
이 유형의 빈을 만드는 법이 궁금하다면 
[Spring Framework, Chapter 5. Resources](https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#resources) 를 보라.
따라서 이번 가이드에서는 `Resource` 객체를 만드는 방법은 아래 간단한 예제를 끝으로 더 자세히 다루지 않을 것이다.

```java
Resource resource = new FileSystemResource("resources/trades.csv");
```

복잡한 배치 환경에서 디렉토리 구조는 종종 EAI 인프라가 관리하며,
FTP에서 배치 처리로 또는 그 반대로 파일을 이동하기 위해 외부 인터페이스 전용 드롭존(drop zone)을 설정한다.
파일 이동 유틸리티는 스프링 배치 아키텍처를 벗어나는 주제긴 하지만,
step으로 사용하는 경우도 드물지 않다.
배치 아키텍처는 처리할 파일을 어떻게 이동시킬지만 알면 된다.
스프링 배치는 시작점에서 파이프에 데이터 공급(feeding)을 시작한다.
물론 [Spring Integration](https://spring.io/projects/spring-integration)
는 더 많은 서비스 유형을 제공한다.

아래 테이블에 있는 `FlatFileItemReader`의 다른 프로퍼티로
데이터를 어떻게 해석할 지를 더 상세하게 지정할 수 있다:  

**Table 15. `FlatFileItemReader` Properties**

| Property 	| Type 	| Description |
|:-----------------:	|:-------------:	|:-------------:	|
|comments|String[]|행 전체를 주석처리하는 라인 프리픽스.|
|encoding|String|사용할 텍스트 인코딩. 디폴트는 `Charset.defaultCharset()`. |
|lineMapper|`LineMapper`|`String`을 item `Object`로 변환한다.|
|linesToSkip|int|파일 상단에 있는 무시할 라인 수.|
|recordSeparatorPolicy|RecordSeparatorPolicy|라인이 끝나는 지점과, 따옴표로 묶인 문자열 안에서 라인이 끝나면 같은 라인으로 처리할지 등을 결정할 때 사용.|
|resource|`Resource`|읽어야할 리소스.|
|skippedLinesCallback|LineCallbackHandler|
건너뛸 라인의 원래 내용을 전달하는 인터페이스. `linesToSkip`이 2면 이 인터페이스를 두 번 호출한다.|	
|strict|boolean|strict 모드에선 입력 리소스가 없으면 `ExecutionContext`에서 예외를 발생시킨다. 반대 경우는 로그를 남기고 넘어간다.|

#### `LineMapper`

As with `RowMapper`, which takes a low-level construct 
such as `ResultSet` and returns an `Object`, flat file processing requires 
the same construct to convert a `String` line into an `Object`,
as shown in the following interface definition:

#### LineTokenizer
#### FieldSetMapper
#### DefaultLineMapper
#### Simple Delimited File Reading Example
#### Mapping Fields by Name
#### Automapping FieldSets to Domain Objects
#### Fixed Length File Formats
#### Multiple Record Types within a Single File
#### Exception Handling in Flat Files

### 6.6.3. FlatFileItemWriter

## 6.7. XML Item Readers and Writers

### 6.7.1. StaxEventItemReader

### 6.7.2. StaxEventItemWriter

## 6.8. JSON Item Readers And Writers

### 6.8.1. JsonItemReader

### 6.8.2. JsonFileItemWriter

## 6.9. Multi-File Input

## 6.10. Database

### 6.10.1. Cursor-based ItemReader Implementations

#### JdbcCursorItemReader

#### HibernateCursorItemReader

#### StoredProcedureItemReader

### 6.10.2. Paging ItemReader Implementations

#### JdbcPagingItemReader

#### JpaPagingItemReader

### 6.10.3. Database ItemWriters

## 6.11. Reusing Existing Services

## 6.12. Validating Input

## 6.13. Preventing State Persistence

## 6.14. Creating Custom ItemReaders and ItemWriters

### 6.14.1. Custom ItemReader Example

#### Making the ItemReader Restartable

### 6.14.2. Custom ItemWriter Example

#### Making the ItemWriter Restartable

### 6.15. Item Reader and Writer Implementations

### 6.15.1. Decorators

#### SynchronizedItemStreamReader

#### SingleItemPeekableItemReader

#### MultiResourceItemWriter

#### ClassifierCompositeItemWriter

#### ClassifierCompositeItemProcessor

### 6.15.2. Messaging Readers And Writers

#### AmqpItemReader

#### AmqpItemWriter

#### JmsItemReader

#### JmsItemWriter

#### KafkaItemReader

#### KafkaItemWriter

### 6.15.3. Database Readers

#### Neo4jItemReader

#### MongoItemReader

#### HibernateCursorItemReader

#### HibernatePagingItemReader

#### RepositoryItemReader

### 6.15.4. Database Writers

#### Neo4jItemWriter

#### MongoItemWriter

#### RepositoryItemWriter

#### HibernateItemWriter

#### JdbcBatchItemWriter

#### JpaItemWriter

#### GemfireItemWriter

### 6.15.5. Specialized Readers

#### LdifReader

#### MappingLdifReader

#### AvroItemReader

### 6.15.6. Specialized Writers

#### SimpleMailMessageItemWriter

#### AvroItemWriter

### 6.15.7. Specialized Processors

#### ScriptItemProcessor