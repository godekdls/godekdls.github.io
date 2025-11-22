---
title: Handling Exceptions
category: Spring for Apache Kafka
order: 29
permalink: /Spring for Apache Kafka/annotation-error-handling/
description: 에러 처리하기
image: ./../../images/spring/logo.png
lastmod: 2025-09-12T23:34:00+09:00
comments: true
originalRefName: 스프링 카프카
originalRefLink: https://docs.spring.io/spring-kafka/reference/4.0.0/annotation-error-handling.html
parent: Reference
parentUrl: /Spring for Apache Kafka/reference/
subparent: Using Spring for Apache Kafka
subparentUrl: /Spring for Apache Kafka/kafka/
---

---

이번 섹션에서는 스프링 카프카를 사용하면서 만날 수 있는 다양한 예외를 처리하는 방법을 설명한다.

### 목차

- [Listener Error Handlers](#listener-error-handlers)
- [Container Error Handlers](#container-error-handlers)
- [Back Off Handlers](#back-off-handlers)
- [DefaultErrorHandler](#defaulterrorhandler)
- [Conversion Errors with Batch Error Handlers](#conversion-errors-with-batch-error-handlers)
- [Retrying Complete Batches](#retrying-complete-batches)
- [Container Stopping Error Handlers](#container-stopping-error-handlers)
- [Delegating Error Handler](#delegating-error-handler)
- [Logging Error Handler](#logging-error-handler)
- [Using Different Common Error Handlers for Record and Batch Listeners](#using-different-common-error-handlers-for-record-and-batch-listeners)
- [Common Error Handler Summary](#common-error-handler-summary)
- [Legacy Error Handlers and Their Replacements](#legacy-error-handlers-and-their-replacements)
  + [Migrating Custom Legacy Error Handler Implementations to CommonErrorHandler](#migrating-custom-legacy-error-handler-implementations-to-commonerrorhandler)
- [After Rollback Processor](#after-rollback-processor)
- [Delivery Attempts Header](#delivery-attempts-header)
- [Delivery Attempts Header for batch listener](#delivery-attempts-header-for-batch-listener)
- [Listener Info Header](#listener-error-handlers)
- [Publishing Dead-letter Records](#publishing-dead-letter-records)
- [Managing Dead Letter Record Headers](#managing-dead-letter-record-headers)
- [ExponentialBackOffWithMaxRetries Implementation](#exponentialbackoffwithmaxretries-implementation)

---

## Listener Error Handlers

2.0 버전부터 `@KafkaListener` 어노테이션에 `errorHandler`라는 새로운 속성이 추가됐다.

`errorHandler`에는 `KafkaListenerErrorHandler` 구현체의 빈 이름을 지정하면 된다. `KafkaListenerErrorHandler`는 functional 인터페이스로, 다음과 같이 메소드가 하나 정의돼있다:

```java
@FunctionalInterface
public interface KafkaListenerErrorHandler {

    Object handleError(Message<?> message, ListenerExecutionFailedException exception) throws Exception;

}
```

여기서는 메시지 컨버터로 생성한 spring-messaging의 `Message<?>` 객체와 리스너에서 던진 예외를 래핑한 `ListenerExecutionFailedException`에 접근할 수 있다. 에러 핸들러는 기존 예외를 던지거나 새로운 예외를 던질 수 있으며, 던져진 예외는 컨테이너에 전달된다. 에러 핸들러는 어떤 값을 반환하더라도 반환값을 따로 사용하는 곳은 없다.

2.7 버전부터 `MessagingMessageConverter`와 `BatchMessagingMessageConverter`에 `rawRecordHeader` 프로퍼티를 설정하면, 컨버팅한 `Message<?>`의 `KafkaHeaders.RAW_DATA` 헤더에 원본 `ConsumerRecord`를 추가한다. 리스너 에러 핸들러에서 `DeadLetterPublishingRecoverer`를 사용하는 등의 상황에서 유용할 거다. 실패한 레코드를 여러 번 재시도한 후, 데드 레터 토픽<sup>dead letter topic</sup>에 저장하고, sender에게 실패 결과를 돌려주는 요청/응답 패턴에 활용할 수 있다.

```java
@Bean
public KafkaListenerErrorHandler eh(DeadLetterPublishingRecoverer recoverer) {
    return (msg, ex) -> {
        if (msg.getHeaders().get(KafkaHeaders.DELIVERY_ATTEMPT, Integer.class) > 9) {
            recoverer.accept(msg.getHeaders().get(KafkaHeaders.RAW_DATA, ConsumerRecord.class), ex);
            return "FAILED";
        }
        throw ex;
    };
}
```

하위 인터페이스(`ConsumerAwareListenerErrorHandler`)를 사용하면 다음 메소드를 통해 컨슈머 객체에 접근할 수 있다:

```java
Object handleError(Message<?> message, ListenerExecutionFailedException exception, Consumer<?, ?> consumer);
```

또 다른 하위 인터페이스(`ManualAckListenerErrorHandler`)는 수동 `AckMode` 모드를 사용할 때 `Acknowledgment` 객체에 접근할 수 있게 해준다.

```java
Object handleError(Message<?> message, ListenerExecutionFailedException exception,
			Consumer<?, ?> consumer, @Nullable Acknowledgment ack);
```

어떤 것을 사용하든, 컨슈머의 오프셋을 임의로 되돌리는 것<sup>seek</sup>은 **안 된다**. 컨테이너가 인식할 수 없기 때문이다.

---

## Container Error Handlers

2.8 버전부터 레거시 `ErrorHandler`와 `BatchErrorHandler` 인터페이스는 새로운 `CommonErrorHandler`로 대체됐다. 새 에러 핸들러는 레코드 리스너와 배치 리스너에서 발생한 오류를 모두 처리할 수 있으므로, 하나의 리스너 컨테이너 팩토리로 두 가지 유형의 리스너에 대한 컨테이너를 생성할 수 있다. 기존 프레임워크의 에러 핸들러 구현체 대부분은 기본 제공하는 `CommonErrorHandler` 구현체로  대체할 수 있다.

커스텀 에러 핸들러를 `CommonErrorHandler`로 마이그레이션하는 자세한 방법은 [레거시 에러 핸들러의 커스텀 구현체를 `CommonErrorHandler`로 마이그레이션하기](#migrating-custom-legacy-error-handler-implementations-to-commonerrorhandler)를 참고해라.

트랜잭션을 사용하는 경우 기본적으로 에러 핸들러가 설정되지 않기 때문에, 예외 발생 시 트랜잭션을 롤백한다. 트랜잭션 컨테이너에서 발생한 에러는 [`AfterRollbackProcessor`](#after-rollback-processor)에서 처리한다. 트랜잭션을 사용 중인데 커스텀 에러 핸들러를 지정한 경우, 트랜잭션을 롤백하고 싶다면 반드시 예외를 던져야 한다.

`CommonErrorHandler` 인터페이스에는 `isAckAfterHandle()`이라는 디폴트 메소드가 정의돼 있는데, 에러 핸들러가 예외를 발생시키지 않고 반환되는 경우 컨테이너가 오프셋의 커밋 여부를 결정하기 위해 호출한다. 기본적으로는 `true`를 반환한다.

일반적으로 프레임워크에서 제공하는 에러 핸들러는 에러가 "처리"되지 않았을 때 (e.g. seek 작업 수행 후) 예외를 던진다. 컨테이너는 기본적으로 이러한 예외를 `ERROR` 로그로 남긴다. 프레임워크의 모든 에러 핸들러는 `KafkaExceptionLogLevelAware`를 상속하고 있어서, 이를 통해 예외를 기록할 로그 레벨을 제어할 수 있다.

```java
/**
 * Set the level at which the exception thrown by this handler is logged.
 * @param logLevel the level (default ERROR).
 */
public void setLogLevel(KafkaException.Level logLevel) {
    ...
}
```

컨테이너 팩토리의 모든 리스너에 사용할 글로벌 에러 핸들러도 지정할 수 있다. 지정 방법은 다음 예제를 참고해라:

```java
@Bean
public KafkaListenerContainerFactory<ConcurrentMessageListenerContainer<Integer, String>>
        kafkaListenerContainerFactory() {
    ConcurrentKafkaListenerContainerFactory<Integer, String> factory =
            new ConcurrentKafkaListenerContainerFactory<>();
    ...
    factory.setCommonErrorHandler(myErrorHandler);
    ...
    return factory;
}
```

기본적으로 어노테이션을 선언한 리스너 메소드에서 예외를 던지면, 컨테이너로 예외를 전달하며, 컨테이너 설정에 따라 메시지를 처리한다.

컨테이너는 에러 핸들러를 호출하기 전에 보류 중인 오프셋을 커밋한다.

스프링 부트를 사용하고 있다면, 간단히 에러 핸들러를 `@Bean`으로 추가해주기만 하면 자동 설정된 팩토리에 알아서 추가된다.

---

## Back Off Handlers

[DefaultErrorHandler](#defaulterrorhandler)와 같은 에러 핸들러들은 메시지를 다시 전송해보기 전에 `BackOff`를 통해 대기할 시간을 결정한다. 2.9 버전부터는 커스텀 `BackOffHandler`를 설정할 수 있다. 디폴트 핸들러는 단순히 백오프 시간만큼 (또는 컨테이너가 중지될 때까지) 스레드를 일시 중지한다. 프레임워크는 백오프 시간이 경과할 때까지 리스너 컨테이너를 중단했다가 재개하는 `ContainerPausingBackOffHandler`도 제공하고 있다. 백오프 기능은 지연 시간이 컨슈머 프로퍼티 `max.poll.interval.ms`보다 길 때 유용하다. 실제 백오프 시간은 컨테이너 프로퍼티 `pollTimeout`에 따라 달라질 수 있다.

---

## DefaultErrorHandler

`DefaultErrorHandler`는 한동안 디폴트 에러 핸들러로 사용했었던 `SeekToCurrentErrorHandler`와 `RecoveringBatchErrorHandler`를 대체한다. 한 가지 차이점은 배치 리스너의 폴백 동작(`BatchListenerFailedException` 이외의 예외가 발생했을 때)이 [전체 배치를 재시도](#retrying-complete-batches)하는 것과 동일하다는 거다.

> 2.9 버전부터 `DefaultErrorHandler`는 아래에서 설명하는 것처럼 처리하지 않은 레코드 오프셋으로 돌아가는 것<sup>seek</sup>처럼 동작하도록 구성할수 있지만, 실제로 seek을 호출하는 것은 아니다. 그대신, 리스너 컨테이너가 레코드들을 보관했다가 에러 핸들러가 종료된 후 (그리고 컨슈머를 활성 상태로 유지할 수 있도록 잠시 중단된 `poll()`을 한 번 수행한 후; [논블러킹 재시도](https://docs.spring.io/spring-kafka/reference/retrytopic.html)나 `ContainerPausingBackOffHandler`를 사용하는 경우 여러 번의 poll동안 일시 중지 상태가 이어질 수 있다) 리스너에 다시 전송한다. 에러 핸들러는 현재 실패한 레코드를 다시 제출할 수 있는지, 또는 이미 복구에 성공해 리스너로 다시 전송하지 않을지 여부를 나타내는 결과값을 컨테이너에 반환한다. 이 모드를 활성화하려면 `seekAfterError` 프로퍼티를 `false`로 설정해라.

`DefaultErrorHandler`는 계속해서 실패하는 레코드를 복구(스킵)할 수 있다. 기본적으로 10번 실패하고 나면 `ERROR` 로그에 실패한 레코드를 기록한다. 커스텀 recoverer(`BiConsumer`)와 재시도 횟수 및 지연 시간을 제어하는 `BackOff`도 설정할 수 있다. `FixedBackOff.UNLIMITED_ATTEMPTS`로 설정한 `FixedBackOff`를 사용하면 (실제로) 무한으로 재시도할 수 있다. 다음은 세 번까지 시도해보고 복구하는 설정이다:

```java
DefaultErrorHandler errorHandler =
    new DefaultErrorHandler((record, exception) -> {
        // recover after 3 failures, with no back off - e.g. send to a dead-letter topic
    }, new FixedBackOff(0L, 2L));
```

리스너 컨테이너에 직접 만든 `DefaultErrorHandler` 인스턴스를 설정하려면, 컨테이너 팩토리에 해당 인스턴스를 추가하면 된다.

예를 들어, `@KafkaListener` 컨테이너 팩토리를 사용한다면, 다음과 같이 `DefaultErrorHandler`를 추가할 수 있다:

```java
@Bean
public ConcurrentKafkaListenerContainerFactory<String, String> kafkaListenerContainerFactory() {
    ConcurrentKafkaListenerContainerFactory<String, String> factory = new ConcurrentKafkaListenerContainerFactory<>();
    factory.setConsumerFactory(consumerFactory());
    factory.getContainerProperties().setAckMode(AckMode.RECORD);
    factory.setCommonErrorHandler(new DefaultErrorHandler(new FixedBackOff(1000L, 2L)));
    return factory;
}
```

For a record listener, this will retry a delivery up to 2 times (3 delivery attempts) with a back off of 1 second, instead of the default configuration (`FixedBackOff(0L, 9)`). Failures are simply logged after retries are exhausted.

As an example, if the `poll` returns six records (two from each partition 0, 1, 2) and the listener throws an exception on the fourth record, the container acknowledges the first three messages by committing their offsets. The `DefaultErrorHandler` seeks to offset 1 for partition 1 and offset 0 for partition 2. The next `poll()` returns the three unprocessed records.

If the `AckMode` was `BATCH`, the container commits the offsets for the first two partitions before calling the error handler.

For a batch listener, the listener must throw a `BatchListenerFailedException` indicating which records in the batch failed.

The sequence of events is:

- Commit the offsets of the records before the index.
- If retries are not exhausted, perform seeks so that all the remaining records (including the failed record) will be redelivered.
- If retries are exhausted, attempt recovery of the failed record (default log only) and perform seeks so that the remaining records (excluding the failed record) will be redelivered. The recovered record’s offset is committed.
- If retries are exhausted and recovery fails, seeks are performed as if retries are not exhausted.

> Starting with version 2.9, the `DefaultErrorHandler` can be configured to provide the same semantics as seeking the unprocessed record offsets as discussed above, but without actually seeking. Instead, error handler creates a new `ConsumerRecords<?, ?>` containing just the unprocessed records which will then be submitted to the listener (after performing a single paused `poll()`, to keep the consumer alive). To enable this mode, set the property `seekAfterError` to `false`.

The default recoverer logs the failed record after retries are exhausted. You can use a custom recoverer, or one provided by the framework such as the [`DeadLetterPublishingRecoverer`](https://docs.spring.io/spring-kafka/reference/kafka/annotation-error-handling.html#dead-letters).

When using a POJO batch listener (e.g. `List<Thing>`), and you don’t have the full consumer record to add to the exception, you can just add the index of the record that failed:

```java
@KafkaListener(id = "recovering", topics = "someTopic")
public void listen(List<Thing> things) {
    for (int i = 0; i < things.size(); i++) {
        try {
            process(things.get(i));
        }
        catch (Exception e) {
            throw new BatchListenerFailedException("Failed to process", i);
        }
    }
}
```

When the container is configured with `AckMode.MANUAL_IMMEDIATE`, the error handler can be configured to commit the offset of recovered records; set the `commitRecovered` property to `true`.

See also [Publishing Dead-letter Records](https://docs.spring.io/spring-kafka/reference/kafka/annotation-error-handling.html#dead-letters).

When using transactions, similar functionality is provided by the `DefaultAfterRollbackProcessor`. See [After-rollback Processor](https://docs.spring.io/spring-kafka/reference/kafka/annotation-error-handling.html#after-rollback).

The `DefaultErrorHandler` considers certain exceptions to be fatal, and retries are skipped for such exceptions; the recoverer is invoked on the first failure. The exceptions that are considered fatal, by default, are:

- `DeserializationException`
- `MessageConversionException`
- `ConversionException`
- `MethodArgumentResolutionException`
- `NoSuchMethodException`
- `ClassCastException`

since these exceptions are unlikely to be resolved on a retried delivery.

You can add more exception types to the not-retryable category, or completely replace the map of classified exceptions. See the Javadocs for `DefaultErrorHandler.addNotRetryableException()` and `DefaultErrorHandler.setClassifications()` for more information, as well as those for the `spring-retry` `BinaryExceptionClassifier`.

Here is an example that adds `IllegalArgumentException` to the not-retryable exceptions:

```java
@Bean
public DefaultErrorHandler errorHandler(ConsumerRecordRecoverer recoverer) {
    DefaultErrorHandler handler = new DefaultErrorHandler(recoverer);
    handler.addNotRetryableExceptions(IllegalArgumentException.class);
    return handler;
}
```

The error handler can be configured with one or more `RetryListener`s, receiving notifications of retry and recovery progress. Starting with version 2.8.10, methods for batch listeners were added.

```java
@FunctionalInterface
public interface RetryListener {

    void failedDelivery(ConsumerRecord<?, ?> record, Exception ex, int deliveryAttempt);

    default void recovered(ConsumerRecord<?, ?> record, Exception ex) {
    }

    default void recoveryFailed(ConsumerRecord<?, ?> record, Exception original, Exception failure) {
    }

    default void failedDelivery(ConsumerRecords<?, ?> records, Exception ex, int deliveryAttempt) {
    }

    default void recovered(ConsumerRecords<?, ?> records, Exception ex) {
    }

	default void recoveryFailed(ConsumerRecords<?, ?> records, Exception original, Exception failure) {
	}

}
```

See the JavaDocs for more information.

> If the recoverer fails (throws an exception), the failed record will be included in the seeks. If the recoverer fails, the `BackOff` will be reset by default and redeliveries will again go through the back offs before recovery is attempted again. To skip retries after a recovery failure, set the error handler’s `resetStateOnRecoveryFailure` to `false`.

You can provide the error handler with a `BiFunction<ConsumerRecord<?, ?>, Exception, BackOff>` to determine the `BackOff` to use, based on the failed record and/or the exception:

```java
handler.setBackOffFunction((record, ex) -> { ... });
```

If the function returns `null`, the handler’s default `BackOff` will be used.

Set `resetStateOnExceptionChange` to `true` and the retry sequence will be restarted (including the selection of a new `BackOff`, if so configured) if the exception type changes between failures. When `false` (the default before version 2.9), the exception type is not considered.

Starting with version 2.9, this is now `true` by default.

Also see [Delivery Attempts Header](https://docs.spring.io/spring-kafka/reference/kafka/annotation-error-handling.html#delivery-header).

---

## Conversion Errors with Batch Error Handlers

Starting with version 2.8, batch listeners can now properly handle conversion errors, when using a `MessageConverter` with a `ByteArrayDeserializer`, a `BytesDeserializer` or a `StringDeserializer`, as well as a `DefaultErrorHandler`. When a conversion error occurs, the payload is set to null and a deserialization exception is added to the record headers, similar to the `ErrorHandlingDeserializer`. A list of `ConversionException`s is available in the listener so the listener can throw a `BatchListenerFailedException` indicating the first index at which a conversion exception occurred.

Example:

```java
@KafkaListener(id = "test", topics = "topic")
void listen(List<Thing> in, @Header(KafkaHeaders.CONVERSION_FAILURES) List<ConversionException> exceptions) {
    for (int i = 0; i < in.size(); i++) {
        Foo foo = in.get(i);
        if (foo == null && exceptions.get(i) != null) {
            throw new BatchListenerFailedException("Conversion error", exceptions.get(i), i);
        }
        process(foo);
    }
}
```

---

## Retrying Complete Batches

이제 배치 리스너에서 `BatchListenerFailedException` 이외의 다른 예외가 발생했을 때, `DefaultErrorHandler`의 폴백<sup>fallback</sup> 동작은 전체 배치를 재시도하는 거다.

배치가 다시 전달됐을 때, 배치에 동일한 수의 레코드가 담겨있다거나, 레코드가 동일한 순서로 있다는 보장은 없다. 따라서 배치의 재시도 상태를 유지하기란 쉬운 일이 아니다. `FallbackBatchErrorHandler`는 다음과 같이 문제를 해결한다. 배치 리스너가 `BatchListenerFailedException`이 아닌 예외를 던지면, 메모리에 남아있는 레코드 배치를 대상으로 재시도한다. 재시도가 길어지더라도 리밸런싱이 일어나지 않도록 에러 핸들러는 컨슈머를 일시 중단하고, 백오프 시간 동안 멈추기 전에 한 번 폴링해온 뒤, 재시도할 때마다 리스너를 호출한다. 재시도 횟수를 모두 소진하고나면 배치에 있는 모든 레코드에 대해 `ConsumerRecordRecoverer`를 호출한다. recoverer가 예외를 던지거나 sleep 중에 스레드 인터럽트가 발생하면, 다음 폴링에서 해당 레코드 배치를 다시 전달한다. 결과가 어떻든 간에, 종료 전에 컨슈머를 재개한다.

> 이 에러 처리 방식은 트랜잭션 모드에서는 사용할 수 없다.

`BackOff` 인터벌만큼 기다리는 동안 에러 핸들러는 원하는 지연 시간에 도달할 때까지 짧은 sleep을 반복하면서 컨테이너가 중지되었는지 확인한다. 덕분에 `stop()` 직후 대기 없이 sleep을 곧바로 종료할 수 있다.

---

## Container Stopping Error Handlers

The `CommonContainerStoppingErrorHandler` stops the container if the listener throws an exception. For record listeners, when the `AckMode` is `RECORD`, offsets for already processed records are committed. For record listeners, when the `AckMode` is any manual value, offsets for already acknowledged records are committed. For record listeners, when the `AckMode` is `BATCH`, or for batch listeners, the entire batch is replayed when the container is restarted.

After the container stops, an exception that wraps the `ListenerExecutionFailedException` is thrown. This is to cause the transaction to roll back (if transactions are enabled).

---

## Delegating Error Handler

The `CommonDelegatingErrorHandler` can delegate to different error handlers, depending on the exception type. For example, you may wish to invoke a `DefaultErrorHandler` for most exceptions, or a `CommonContainerStoppingErrorHandler` for others.

All delegates must share the same compatible properties (`ackAfterHandle`, `seekAfterError` …).

---

## Logging Error Handler

The `CommonLoggingErrorHandler` simply logs the exception; with a record listener, the remaining records from the previous poll are passed to the listener. For a batch listener, all the records in the batch are logged.

---

## Using Different Common Error Handlers for Record and Batch Listeners

If you wish to use a different error handling strategy for record and batch listeners, the `CommonMixedErrorHandler` is provided allowing the configuration of a specific error handler for each listener type.

---

## Common Error Handler Summary

- `DefaultErrorHandler`
- `CommonContainerStoppingErrorHandler`
- `CommonDelegatingErrorHandler`
- `CommonLoggingErrorHandler`
- `CommonMixedErrorHandler`

---

## Legacy Error Handlers and Their Replacements

| Legacy Error Handler                     | Replacement                                                  |
| :--------------------------------------- | :----------------------------------------------------------- |
| `LoggingErrorHandler`                    | `CommonLoggingErrorHandler`                                  |
| `BatchLoggingErrorHandler`               | `CommonLoggingErrorHandler`                                  |
| `ConditionalDelegatingErrorHandler`      | `DelegatingErrorHandler`                                     |
| `ConditionalDelegatingBatchErrorHandler` | `DelegatingErrorHandler`                                     |
| `ContainerStoppingErrorHandler`          | `CommonContainerStoppingErrorHandler`                        |
| `ContainerStoppingBatchErrorHandler`     | `CommonContainerStoppingErrorHandler`                        |
| `SeekToCurrentErrorHandler`              | `DefaultErrorHandler`                                        |
| `SeekToCurrentBatchErrorHandler`         | No replacement, use `DefaultErrorHandler` with an infinite `BackOff`. |
| `RecoveringBatchErrorHandler`            | `DefaultErrorHandler`                                        |
| `RetryingBatchErrorHandler`              | No replacements, use `DefaultErrorHandler` and throw an exception other than `BatchListenerFailedException`. |

### Migrating Custom Legacy Error Handler Implementations to `CommonErrorHandler`

Refer to the JavaDocs in `CommonErrorHandler`.

To replace an `ErrorHandler` or `ConsumerAwareErrorHandler` implementation, you should implement `handleOne()` and leave `seeksAfterHandle()` to return `false` (default). You should also implement `handleOtherException()` to handle exceptions that occur outside the scope of record processing (e.g. consumer errors).

To replace a `RemainingRecordsErrorHandler` implementation, you should implement `handleRemaining()` and override `seeksAfterHandle()` to return `true` (the error handler must perform the necessary seeks). You should also implement `handleOtherException()` - to handle exceptions that occur outside the scope of record processing (e.g. consumer errors).

To replace any `BatchErrorHandler` implementation, you should implement `handleBatch()` You should also implement `handleOtherException()` - to handle exceptions that occur outside the scope of record processing (e.g. consumer errors).

---

## After Rollback Processor

When using transactions, if the listener throws an exception (and an error handler, if present, throws an exception), the transaction is rolled back. By default, any unprocessed records (including the failed record) are re-fetched on the next poll. This is achieved by performing `seek` operations in the `DefaultAfterRollbackProcessor`. With a batch listener, the entire batch of records is reprocessed (the container has no knowledge of which record in the batch failed). To modify this behavior, you can configure the listener container with a custom `AfterRollbackProcessor`. For example, with a record-based listener, you might want to keep track of the failed record and give up after some number of attempts, perhaps by publishing it to a dead-letter topic.

Starting with version 2.2, the `DefaultAfterRollbackProcessor` can now recover (skip) a record that keeps failing. By default, after ten failures, the failed record is logged (at the `ERROR` level). You can configure the processor with a custom recoverer (`BiConsumer`) and maximum failures. Setting the `maxFailures` property to a negative number causes infinite retries. The following example configures recovery after three tries:

```java
AfterRollbackProcessor<String, String> processor =
    new DefaultAfterRollbackProcessor((record, exception) -> {
        // recover after 3 failures, with no back off - e.g. send to a dead-letter topic
    }, new FixedBackOff(0L, 2L));
```

When you do not use transactions, you can achieve similar functionality by configuring a `DefaultErrorHandler`. See [Container Error Handlers](https://docs.spring.io/spring-kafka/reference/kafka/annotation-error-handling.html#error-handlers).

Starting with version 3.2, Recovery can now recover (skip) entire batch of records that keeps failing. Set `ContainerProperties.setBatchRecoverAfterRollback(true)` to enable this feature.

> Default behavior, recovery is not possible with a batch listener, since the framework has no knowledge about which record in the batch keeps failing. In such cases, the application listener must handle a record that keeps failing.

See also [Publishing Dead-letter Records](https://docs.spring.io/spring-kafka/reference/kafka/annotation-error-handling.html#dead-letters).

Starting with version 2.2.5, the `DefaultAfterRollbackProcessor` can be invoked in a new transaction (started after the failed transaction rolls back). Then, if you are using the `DeadLetterPublishingRecoverer` to publish a failed record, the processor will send the recovered record’s offset in the original topic/partition to the transaction. To enable this feature, set the `commitRecovered` and `kafkaTemplate` properties on the `DefaultAfterRollbackProcessor`.

> If the recoverer fails (throws an exception), the failed record will be included in the seeks. Starting with version 2.5.5, if the recoverer fails, the `BackOff` will be reset by default and redeliveries will again go through the back offs before recovery is attempted again. With earlier versions, the `BackOff` was not reset and recovery was re-attempted on the next failure. To revert to the previous behavior, set the processor’s `resetStateOnRecoveryFailure` property to `false`.

Starting with version 2.6, you can now provide the processor with a `BiFunction<ConsumerRecord<?, ?>, Exception, BackOff>` to determine the `BackOff` to use, based on the failed record and/or the exception:

```java
handler.setBackOffFunction((record, ex) -> { ... });
```

If the function returns `null`, the processor’s default `BackOff` will be used.

Starting with version 2.6.3, set `resetStateOnExceptionChange` to `true` and the retry sequence will be restarted (including the selection of a new `BackOff`, if so configured) if the exception type changes between failures. By default, the exception type is not considered.

Starting with version 2.3.1, similar to the `DefaultErrorHandler`, the `DefaultAfterRollbackProcessor` considers certain exceptions to be fatal, and retries are skipped for such exceptions; the recoverer is invoked on the first failure. The exceptions that are considered fatal, by default, are:

- `DeserializationException`
- `MessageConversionException`
- `ConversionException`
- `MethodArgumentResolutionException`
- `NoSuchMethodException`
- `ClassCastException`

since these exceptions are unlikely to be resolved on a retried delivery.

You can add more exception types to the not-retryable category, or completely replace the map of classified exceptions. See the Javadocs for `DefaultAfterRollbackProcessor.setClassifications()` for more information, as well as those for the `spring-retry` `BinaryExceptionClassifier`.

Here is an example that adds `IllegalArgumentException` to the not-retryable exceptions:

```java
@Bean
public DefaultAfterRollbackProcessor errorHandler(BiConsumer<ConsumerRecord<?, ?>, Exception> recoverer) {
    DefaultAfterRollbackProcessor processor = new DefaultAfterRollbackProcessor(recoverer);
    processor.addNotRetryableException(IllegalArgumentException.class);
    return processor;
}
```

Also see [Delivery Attempts Header](https://docs.spring.io/spring-kafka/reference/kafka/annotation-error-handling.html#delivery-header).

> With current `kafka-clients`, the container cannot detect whether a `ProducerFencedException` is caused by a rebalance or if the producer’s `transactional.id` has been revoked due to a timeout or expiry. Because, in most cases, it is caused by a rebalance, the container does not call the `AfterRollbackProcessor` (because it’s not appropriate to seek the partitions because we no longer are assigned them). If you ensure the timeout is large enough to process each transaction and periodically perform an "empty" transaction (e.g. via a `ListenerContainerIdleEvent`) you can avoid fencing due to timeout and expiry. Or, you can set the `stopContainerWhenFenced` container property to `true` and the container will stop, avoiding the loss of records. You can consume a `ConsumerStoppedEvent` and check the `Reason` property for `FENCED` to detect this condition. Since the event also has a reference to the container, you can restart the container using this event.

Starting with version 2.7, while waiting for a `BackOff` interval, the error handler will loop with a short sleep until the desired delay is reached, while checking to see if the container has been stopped, allowing the sleep to exit soon after the `stop()` rather than causing a delay.

Starting with version 2.7, the processor can be configured with one or more `RetryListener`s, receiving notifications of retry and recovery progress.

```java
@FunctionalInterface
public interface RetryListener {

    void failedDelivery(ConsumerRecord<?, ?> record, Exception ex, int deliveryAttempt);

    default void recovered(ConsumerRecord<?, ?> record, Exception ex) {
    }

    default void recoveryFailed(ConsumerRecord<?, ?> record, Exception original, Exception failure) {
    }

}
```

See the JavaDocs for more information.

---

## Delivery Attempts Header

The following applies to record listeners only, not batch listeners.

Starting with version 2.5, when using an `ErrorHandler` or `AfterRollbackProcessor` that implements `DeliveryAttemptAware`, it is possible to enable the addition of the `KafkaHeaders.DELIVERY_ATTEMPT` header (`kafka_deliveryAttempt`) to the record. The value of this header is an incrementing integer starting at 1. When receiving a raw `ConsumerRecord<?, ?>` the integer is in a `byte[4]`.

```java
int delivery = ByteBuffer.wrap(record.headers()
    .lastHeader(KafkaHeaders.DELIVERY_ATTEMPT).value())
    .getInt();
```

When using `@KafkaListener` with the `DefaultKafkaHeaderMapper` or `SimpleKafkaHeaderMapper`, it can be obtained by adding `@Header(KafkaHeaders.DELIVERY_ATTEMPT) int delivery` as a parameter to the listener method.

To enable population of this header, set the container property `deliveryAttemptHeader` to `true`. It is disabled by default to avoid the (small) overhead of looking up the state for each record and adding the header.

The `DefaultErrorHandler` and `DefaultAfterRollbackProcessor` support this feature.

---

## Delivery Attempts Header for batch listener

When processing `ConsumerRecord` with the `BatchListener`, the `KafkaHeaders.DELIVERY_ATTEMPT` header can be present in a different way compared to `SingleRecordListener`.

Starting with version 3.3, if you want to inject the `KafkaHeaders.DELIVERY_ATTEMPT` header into the `ConsumerRecord` when using the `BatchListener`, set the `DeliveryAttemptAwareRetryListener` as the `RetryListener` in the `ErrorHandler`.

Please refer to the code below.

```java
final FixedBackOff fixedBackOff = new FixedBackOff(1, 10);
final DefaultErrorHandler errorHandler = new DefaultErrorHandler(fixedBackOff);
errorHandler.setRetryListeners(new DeliveryAttemptAwareRetryListener());

ConcurrentKafkaListenerContainerFactory<String, String> factory = new ConcurrentKafkaListenerContainerFactory<>();
factory.setConsumerFactory(consumerFactory);
factory.setCommonErrorHandler(errorHandler);
```

Then, whenever a batch fails to complete, the `DeliveryAttemptAwareRetryListener` will inject a `KafkaHeaders.DELIVERY_ATTMPT` header into the `ConsumerRecord`.

---

## Listener Info Header

In some cases, it is useful to be able to know which container a listener is running in.

Starting with version 2.8.4, you can now set the `listenerInfo` property on the listener container, or set the `info` attribute on the `@KafkaListener` annotation. Then, the container will add this in the `KafkaListener.LISTENER_INFO` header to all incoming messages; it can then be used in record interceptors, filters, etc., or in the listener itself.

```java
@KafkaListener(id = "something", topics = "topic", filter = "someFilter",
        info = "this is the something listener")
public void listen(@Payload Thing thing,
        @Header(KafkaHeaders.LISTENER_INFO) String listenerInfo) {
    ...
}
```

When used in a `RecordInterceptor` or `RecordFilterStrategy` implementation, the header is in the consumer record as a byte array, converted using the `KafkaListenerAnnotationBeanPostProcessor`'s `charSet` property.

The header mappers also convert to `String` when creating `MessageHeaders` from the consumer record and never map this header on an outbound record.

For POJO batch listeners, starting with version 2.8.6, the header is copied into each member of the batch and is also available as a single `String` parameter after conversion.

```java
@KafkaListener(id = "list2", topics = "someTopic", containerFactory = "batchFactory",
        info = "info for batch")
public void listen(List<Thing> list,
        @Header(KafkaHeaders.RECEIVED_KEY) List<Integer> keys,
        @Header(KafkaHeaders.RECEIVED_PARTITION) List<Integer> partitions,
        @Header(KafkaHeaders.RECEIVED_TOPIC) List<String> topics,
        @Header(KafkaHeaders.OFFSET) List<Long> offsets,
        @Header(KafkaHeaders.LISTENER_INFO) String info) {
            ...
}
```

> If the batch listener has a filter and the filter results in an empty batch, you will need to add `required = false` to the `@Header` parameter because the info is not available for an empty batch.

If you receive `List<Message<Thing>>` the info is in the `KafkaHeaders.LISTENER_INFO` header of each `Message<?>`.

See [Batch Listeners](https://docs.spring.io/spring-kafka/reference/kafka/receiving-messages/listener-annotation.html#batch-listeners) for more information about consuming batches.

---

## Publishing Dead-letter Records

You can configure the `DefaultErrorHandler` and `DefaultAfterRollbackProcessor` with a record recoverer when the maximum number of failures is reached for a record. The framework provides the `DeadLetterPublishingRecoverer`, which publishes the failed message to another topic. The recoverer requires a `KafkaTemplate<Object, Object>`, which is used to send the record. You can also, optionally, configure it with a `BiFunction<ConsumerRecord<?, ?>, Exception, TopicPartition>`, which is called to resolve the destination topic and partition.

> By default, the dead-letter record is sent to a topic named `<originalTopic>-dlt` (the original topic name suffixed with `-dlt`) and to the same partition as the original record. Therefore, when you use the default resolver, the dead-letter topic **must have at least as many partitions as the original topic.** |

If the returned `TopicPartition` has a negative partition, the partition is not set in the `ProducerRecord`, so the partition is selected by Kafka. Starting with version 2.2.4, any `ListenerExecutionFailedException` (thrown, for example, when an exception is detected in a `@KafkaListener` method) is enhanced with the `groupId` property. This allows the destination resolver to use this, in addition to the information in the `ConsumerRecord` to select the dead letter topic.

The following example shows how to wire a custom destination resolver:

```java
DeadLetterPublishingRecoverer recoverer = new DeadLetterPublishingRecoverer(template,
        (r, e) -> {
            if (e instanceof FooException) {
                return new TopicPartition(r.topic() + ".Foo.failures", r.partition());
            }
            else {
                return new TopicPartition(r.topic() + ".other.failures", r.partition());
            }
        });
CommonErrorHandler errorHandler = new DefaultErrorHandler(recoverer, new FixedBackOff(0L, 2L));
```

The record sent to the dead-letter topic is enhanced with the following headers:

- `KafkaHeaders.DLT_EXCEPTION_FQCN`: The Exception class name (generally a `ListenerExecutionFailedException`, but can be others).
- `KafkaHeaders.DLT_EXCEPTION_CAUSE_FQCN`: The Exception cause class name, if present (since version 2.8).
- `KafkaHeaders.DLT_EXCEPTION_STACKTRACE`: The Exception stack trace.
- `KafkaHeaders.DLT_EXCEPTION_MESSAGE`: The Exception message.
- `KafkaHeaders.DLT_KEY_EXCEPTION_FQCN`: The Exception class name (key deserialization errors only).
- `KafkaHeaders.DLT_KEY_EXCEPTION_STACKTRACE`: The Exception stack trace (key deserialization errors only).
- `KafkaHeaders.DLT_KEY_EXCEPTION_MESSAGE`: The Exception message (key deserialization errors only).
- `KafkaHeaders.DLT_ORIGINAL_TOPIC`: The original topic.
- `KafkaHeaders.DLT_ORIGINAL_PARTITION`: The original partition.
- `KafkaHeaders.DLT_ORIGINAL_OFFSET`: The original offset.
- `KafkaHeaders.DLT_ORIGINAL_TIMESTAMP`: The original timestamp.
- `KafkaHeaders.DLT_ORIGINAL_TIMESTAMP_TYPE`: The original timestamp type.
- `KafkaHeaders.DLT_ORIGINAL_CONSUMER_GROUP`: The original consumer group that failed to process the record (since version 2.8).

Key exceptions are only caused by `DeserializationException`s so there is no `DLT_KEY_EXCEPTION_CAUSE_FQCN`.

There are two mechanisms to add more headers.

1. Subclass the recoverer and override `createProducerRecord()` - call `super.createProducerRecord()` and add more headers.
2. Provide a `BiFunction` to receive the consumer record and exception, returning a `Headers` object; headers from there will be copied to the final producer record; also see [Managing Dead Letter Record Headers](https://docs.spring.io/spring-kafka/reference/kafka/annotation-error-handling.html#dlpr-headers). Use `setHeadersFunction()` to set the `BiFunction`.

The second is simpler to implement but the first has more information available, including the already assembled standard headers.

Starting with version 2.3, when used in conjunction with an `ErrorHandlingDeserializer`, the publisher will restore the record `value()`, in the dead-letter producer record, to the original value that failed to be deserialized. Previously, the `value()` was null and user code had to decode the `DeserializationException` from the message headers. In addition, you can provide multiple `KafkaTemplate`s to the publisher; this might be needed, for example, if you want to publish the `byte[]` from a `DeserializationException`, as well as values using a different serializer from records that were deserialized successfully. Here is an example of configuring the publisher with `KafkaTemplate`s that use a `String` and `byte[]` serializer:

```java
@Bean
public DeadLetterPublishingRecoverer publisher(KafkaTemplate<?, ?> stringTemplate,
        KafkaTemplate<?, ?> bytesTemplate) {
    Map<Class<?>, KafkaOperations<?, ?>> templates = new LinkedHashMap<>();
    templates.put(String.class, stringTemplate);
    templates.put(byte[].class, bytesTemplate);
    return new DeadLetterPublishingRecoverer(templates);
}
```

The publisher uses the map keys to locate a template that is suitable for the `value()` about to be published. A `LinkedHashMap` is recommended so that the keys are examined in order.

When publishing `null` values, and there are multiple templates, the recoverer will look for a template for the `Void` class; if none is present, the first template from the `values().iterator()` will be used.

Since 2.7 you can use the `setFailIfSendResultIsError` method so that an exception is thrown when message publishing fails. You can also set a timeout for the verification of the sender success with `setWaitForSendResultTimeout`.

> If the recoverer fails (throws an exception), the failed record will be included in the seeks. Starting with version 2.5.5, if the recoverer fails, the `BackOff` will be reset by default and redeliveries will again go through the back offs before recovery is attempted again. With earlier versions, the `BackOff` was not reset and recovery was re-attempted on the next failure. To revert to the previous behavior, set the error handler’s `resetStateOnRecoveryFailure` property to `false`.

Starting with version 2.6.3, set `resetStateOnExceptionChange` to `true` and the retry sequence will be restarted (including the selection of a new `BackOff`, if so configured) if the exception type changes between failures. By default, the exception type is not considered.

Starting with version 2.3, the recoverer can also be used with Kafka Streams - see [Recovery from Deserialization Exceptions](https://docs.spring.io/spring-kafka/reference/streams.html#streams-deser-recovery) for more information.

The `ErrorHandlingDeserializer` adds the deserialization exception(s) in headers `ErrorHandlingDeserializer.VALUE_DESERIALIZER_EXCEPTION_HEADER` and `ErrorHandlingDeserializer.KEY_DESERIALIZER_EXCEPTION_HEADER` (using Java serialization). By default, these headers are not retained in the message published to the dead letter topic. Starting with version 2.7, if both the key and value fail deserialization, the original values of both are populated in the record sent to the DLT.

If incoming records are dependent on each other, but may arrive out of order, it may be useful to republish a failed record to the tail of the original topic (for some number of times), instead of sending it directly to the dead letter topic. See [this Stack Overflow Question](https://stackoverflow.com/questions/64646996) for an example.

The following error handler configuration will do exactly that:

```java
@Bean
public ErrorHandler eh(KafkaOperations<String, String> template) {
    return new DefaultErrorHandler(new DeadLetterPublishingRecoverer(template,
            (rec, ex) -> {
                org.apache.kafka.common.header.Header retries = rec.headers().lastHeader("retries");
                if (retries == null) {
                    retries = new RecordHeader("retries", new byte[] { 1 });
                    rec.headers().add(retries);
                }
                else {
                    retries.value()[0]++;
                }
                return retries.value()[0] > 5
                        ? new TopicPartition("topic-dlt", rec.partition())
                        : new TopicPartition("topic", rec.partition());
            }), new FixedBackOff(0L, 0L));
}
```

Starting with version 2.7, the recoverer checks that the partition selected by the destination resolver actually exists. If the partition is not present, the partition in the `ProducerRecord` is set to `null`, allowing the `KafkaProducer` to select the partition. You can disable this check by setting the `verifyPartition` property to `false`.

Starting with version 3.1, setting the `logRecoveryRecord` property to `true` will log the recovery record and exception.

---

## Managing Dead Letter Record Headers

Referring to [Publishing Dead-letter Records](https://docs.spring.io/spring-kafka/reference/kafka/annotation-error-handling.html#dead-letters) above, the `DeadLetterPublishingRecoverer` has two properties used to manage headers when those headers already exist (such as when reprocessing a dead letter record that failed, including when using [Non-Blocking Retries](https://docs.spring.io/spring-kafka/reference/retrytopic.html)).

- `appendOriginalHeaders` (default `true`)
- `stripPreviousExceptionHeaders` (default `true` since version 2.8)

Apache Kafka supports multiple headers with the same name; to obtain the "latest" value, you can use `headers.lastHeader(headerName)`; to get an iterator over multiple headers, use `headers.headers(headerName).iterator()`.

When repeatedly republishing a failed record, these headers can grow (and eventually cause publication to fail due to a `RecordTooLargeException`); this is especially true for the exception headers and particularly for the stack trace headers.

The reason for the two properties is because, while you might want to retain only the last exception information, you might want to retain the history of which topic(s) the record passed through for each failure.

`appendOriginalHeaders` is applied to all headers named `**ORIGINAL**` while `stripPreviousExceptionHeaders` is applied to all headers named `**EXCEPTION**`.

Starting with version 2.8.4, you now can control which of the standard headers will be added to the output record. See the `enum HeadersToAdd` for the generic names of the (currently) 10 standard headers that are added by default (these are not the actual header names, just an abstraction; the actual header names are set up by the `getHeaderNames()` method which subclasses can override.

To exclude headers, use the `excludeHeaders()` method; for example, to suppress adding the exception stack trace in a header, use:

```java
DeadLetterPublishingRecoverer recoverer = new DeadLetterPublishingRecoverer(template);
recoverer.excludeHeaders(HeaderNames.HeadersToAdd.EX_STACKTRACE);
```

In addition, you can completely customize the addition of exception headers by adding an `ExceptionHeadersCreator`; this also disables all standard exception headers.

```java
DeadLetterPublishingRecoverer recoverer = new DeadLetterPublishingRecoverer(template);
recoverer.setExceptionHeadersCreator((kafkaHeaders, exception, isKey, headerNames) -> {
    kafkaHeaders.add(new RecordHeader(..., ...));
});
```

Also starting with version 2.8.4, you can now provide multiple headers functions, via the `addHeadersFunction` method. This allows additional functions to apply, even if another function has already been registered, for example, when using [Non-Blocking Retries](https://docs.spring.io/spring-kafka/reference/retrytopic.html).

Also see [Failure Header Management](https://docs.spring.io/spring-kafka/reference/retrytopic/features.html#retry-headers) with [Non-Blocking Retries](https://docs.spring.io/spring-kafka/reference/retrytopic.html).

---

## `ExponentialBackOffWithMaxRetries` Implementation

Spring Framework provides a number of `BackOff` implementations. By default, the `ExponentialBackOff` will retry indefinitely; to give up after some number of retry attempts requires calculating the `maxElapsedTime`. Since version 2.7.3, Spring for Apache Kafka provides the `ExponentialBackOffWithMaxRetries` which is a subclass that receives the `maxRetries` property and automatically calculates the `maxElapsedTime`, which is a little more convenient.

```java
@Bean
DefaultErrorHandler handler() {
    ExponentialBackOffWithMaxRetries bo = new ExponentialBackOffWithMaxRetries(6);
    bo.setInitialInterval(1_000L);
    bo.setMultiplier(2.0);
    bo.setMaxInterval(10_000L);
    return new DefaultErrorHandler(myRecoverer, bo);
}
```

This will retry after `1, 2, 4, 8, 10, 10` seconds, before calling the recoverer.
