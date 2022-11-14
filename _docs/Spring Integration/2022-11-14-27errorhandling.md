---
title: Appendix A. Error Handling
category: Spring Integration
order: 27
permalink: /Spring%20Integration/error-handling/
description: Spring Integration 구성 요소에서 발생하는 예외 처리하기
image: ./../../images/springintegration/logo.png
lastmod: 2022-11-14T22:00:00+09:00
comments: true
originalRefName: 스프링 인티그레이션
originalRefLink: https://docs.spring.io/spring-integration/docs/5.5.15/reference/html/index-single.html#error-handling
parent: Appendices
parentUrl: /Spring%20Integration/appendices/
---
<script>defaultLanguages = ['java']</script>

---

이 매뉴얼 맨 앞에 있는 [개요](../overview)에서 설명한 것처럼, Spring Integration과 같은 메시지 지향 프레임워크가 생겨난 주요 원인 중 하나는 구성 요소 간의 느슨한 결합<sup>loose coupling</sup>을 이끌기 위해서다. 메시지 채널은 프로듀서와 컨슈머가 서로를 몰라도 되게끔 만들어주는, 중요한 역할을 맡고 있다. 하지만 이런 장점들 이면에는 몇 가지 단점도 존재한다. 구성 요소들이 느슨하게 결합된 환경에서는 더 복잡해지는 것들이 있는데, 그 중 하나가 에러 처리다.

메시지를 채널에 전송하게 되면, 결국 이 메시지를 처리하는 구성 요소는 sender와 동일한 스레드에서 동작할 수도 있고, 그렇지 않을 수도 있다. 간단히 디폴트 `DirectChannel`을 사용한다면 (`<channel>` 요소에 자식 요소 `<queue>`와 'task-executor' 속성이 없는 경우), 처음에 메시지를 전송한 스레드에서 그대로 메시지를 처리한다. 이때 `Exception`이 발생하면 sender에서 예외를 catch할 수 있다 (또는 `RuntimeException`이어서 따로 catch하지 않았다면 sender를 지나 예외를 전파할 수도 있다). 이때의 동작은 일반적인 Java 호출 스택에서 예외를 던졌을 때와 동일하다.

caller 스레드에서 실행되는 메시지 플로우는 메시징 게이트웨이나 ([Messaging Gateways](../messaging-endpoints/#104-messaging-gateways) 참고) `MessagingTemplate`을 통해 실행될 수 있다 ([`MessagingTemplate`](../messaging-channels/#614-messagingtemplate) 참고). 두 케이스 모두 caller에게 예외를 던지는 게 기본 동작이다. 메시징 게이트웨이에서 예외를 던지는 방법이나, 에러를 던지는 대신 에러 채널로 라우팅하도록 설정하는 자세한 방법은 [에러 처리](../messaging-endpoints/#1049-error-handling)를 참고해라. `MessagingTemplate`을 사용하거나 `MessageChannel`로 직접 메시지를 전송할 때는 항상 caller에게 예외를 던진다.

비동기 처리가 들어가 있다면 좀 더 복잡하다. 예를 들어 'channel' 요소에 자식 요소 'queue'를 제공하지 않았다면 (자바 & 어노테이션 설정에선 `QueueChannel`), 메시지를 처리하는 구성 요소는 sender와는 다른 스레드에서 동작하게 된다. `ExecutorChannel`을 사용할 때도 마찬가지다. sender에선 채널에 `Message`를 떨군 뒤 다른 작업으로 넘어갔을 수도 있다. 표준 방식대로 `Exception`을 던진다면 정확히 sender에게 직접 `Exception`을 다시 던지는 것은 불가능하다. 비동기 프로세스에서 발생하는 에러를 처리하려면 그보단, 에러 처리 메커니즘 역시 비동기일 필요가 있다.

Spring Integration 구성 요소에서 발생하는 에러는 메시지 채널에 게시하는 식으로 처리할 수 있다. 이때는 특별히, 발생한 `Exception`을 Spring Integration `ErrorMessage`의 페이로드로 사용한다. 이후 이 `Message`는, 'replyChannel'과 유사한 방식으로 리졸브하는 메시지 채널로 전송된다. 먼저, `Exception`이 발생했을 때 처리하던 요청 `Message`에 'errorChannel' 헤더가 들어 있다면 (이 헤더의 이름은 `MessageHeaders.ERROR_CHANNEL`이란 상수로 정의돼있다), 해당 채널로 `ErrorMessage`를 전송한다. 그렇지 않으면 에러 핸들러는 `errorChannel`이란 빈 이름을 가지고 있는 "글로벌" 채널로 메시지를 전송한다 (`IntegrationContextUtils.ERROR_CHANNEL_BEAN_NAME`이란 상수로 정의돼있다).

디폴트 `errorChannel` 빈은 프레임워크 내부에서 생성한다. 하지만 설정을 바꾸고 싶다면 직접 정의할 수도 있다. 다음은 capacity가 `500`인 큐를 사용하는 에러 처널을 정의하는 예시다:

<div class="switch-language-wrapper java xml">
<span class="switch-language java">Java</span>
<span class="switch-language xml">XML</span>
</div>
<div class="language-only-for-java java xml"></div>
```java
@Bean
QueueChannel errorChannel() {
    return new QueueChannel(500);
}
```
<div class="language-only-for-xml java xml"></div>
```xml
<int:channel id="errorChannel">
    <int:queue capacity="500"/>
</int:channel>
```

> 디폴트 에러 채널은 `PublishSubscribeChannel`이다.

여기서 짚고 넘어가야 할 가장 중요한 사실은, 메시지를 통한 에러 처리는 `TaskExecutor` 내에서 실행되는 Spring Integration 태스크에서 던진 예외에만 적용된다는 거다. sender와 동일한 스레드에서 실행되는 핸들러에서 던진 예외에는 적용되지 않는다 (예를 들어 앞에서 설명한 `DirectChannel`을 이용하는 경우).

> 예약한 폴러 태스크를 실행하던 중에 예외가 발생하면, 마찬가지로 `ErrorMessage` 인스턴스로 예외를 감싼 뒤 'errorChannel'에 전송한다. 이때는 글로벌 `taskScheduler` 빈에 주입한 `MessagePublishingErrorHandler`를 사용한다. 커스텀 `taskScheduler`를 사용하더라도 표준 'errorChannel' 통합 플로우 로직을 통해 에러를 처리해야 한다면 커스텀 `taskScheduler`에서도 `MessagePublishingErrorHandler`를 사용하는 것이 좋다. 이땐 애플리케이션 컨텍스트에 등록돼있는 `integrationMessagePublishingErrorHandler` 빈을 사용해도 된다.

에러 채널에 핸들러를 등록하면 글로벌 에러 처리를 구현할 수 있다. 예를 들면 Spring Integration의 `ErrorMessageExceptionTypeRouter`를 'errorChannel'을 구독하는 엔드포인트의 핸들러로 설정할 수 있다. 그러면 이 라우터는 `Exception` 타입에 따라 여러 가지 채널로 에러 메시지를 전파할 수 있다.

4.3.10 버전부터 Spring Integration은 `ErrorMessagePublisher`와 `ErrorMessageStrategy`를 제공한다. 이것들은 `ErrorMessage` 인스턴스를 게시하기 위한 범용 메커니즘으로 활용할 수 있다. 에러를 처리하는 시나리오에 따라 호출하고 원하는대로 확장해도 좋다. `ErrorMessageSendingRecoverer`는 이 `ErrorMessagePublisher`를 상속하고 있으며, 동시에 [`RequestHandlerRetryAdvice`](../messaging-endpoints/#retry-advice) 등에서 재시도에 사용할 수 있는 `RecoveryCallback`을 구현하고 있다. `ErrorMessageStrategy`는 전달받은 exception과 `AttributeAccessor` 컨텍스트를 기반으로 `ErrorMessage`를 생성하는데 사용한다. 원하는 `MessageProducerSupport`나 `MessagingGatewaySupport`에 주입하면 된다. `AttributeAccessor` 컨텍스트에는 `ErrorMessageUtils.INPUT_MESSAGE_CONTEXT_KEY` 아래에 `requestMessage`가 담겨있다. `ErrorMessageStrategy`에선 `ErrorMessage`를 생성하면서 `originalMessage` 프로퍼티에 이 `requestMessage`를 담을 수 있다. 사실, `DefaultErrorMessageStrategy`가 하는 일이 정확히 이거다.

5.2 버전부터 프레임워크 구성 요소에서 발생하는 모든 `MessageHandlingException` 인스턴스에는 구성 요소와 관련된 `BeanDefinition` 리소스와, 예외를 발생시킨 설정 코드의 위치를 파악할 수 있는 출처가 담겨있다. XML 설정의 경우, 리소스는 XML 파일의 경로이고 `id` 속성을 가진 XML 태그가 출처다. Java & 어노테이션 설정에선, 리소스는 `@Configuration` 클래스, 출처는 `@Bean` 메소드다. 통합 플로우 솔루션은 대부분 기본 제공하는 구성 요소와 관련 설정 옵션들을 기반으로 동작한다. 런타임에 예외가 발생했다면, 런타임에 실행하는 것은 빈을 설정하는 코드가 아니라 빈 자체이기 때문에, 스택 트레이스에선 엔드 유저의 코드는 찾을 수 없을 거다. 빈 정의와 관련된 리소스와 출처를 알 수 있다면, 어떤 설정에서 실수를 했는지 파악할 수 있어 개발이 좀 더 수월해질 거다.

5.4.3 버전부터 디폴트 에러 채널은 `requireSubscribers = true` 프로퍼티로 설정돼서, 이 채널에 구독자가 없다면 (ex. 애플리케이션 컨텍스트가 중지된 경우) 받은 메시지들을 단순히 무시하지만은 않는다. 이 경우 `MessageDispatchingException`이 발생해서, 향후 재전송이나 다른 조치를 취할 수 있도록 인바운드 채널 어댑터의 클라이언트 콜백을 통해 소스 시스템이 보낸 메시지에 대해 NAK<sup>negative acknowledge</sup>를 전송하거나 롤백할 수 있다. 이전 동작으로 돌아가려면 (에러 메시지를 전달하지 못했다는 에러는 무시하려면) 글로벌 통합 프로퍼티 `spring.integration.channels.error.requireSubscribers`를 `false`로 설정해야 한다. 자세한 내용은 [글로벌 프로퍼티](../configuration/#f3-global-properties)와 [`PublishSubscribeChannel` 설정](../messaging-channels/#publishsubscribechannel-configuration)(글로벌 `errorChannel`을 수동으로 설정하는 경우)을 참고해라.