---
title: Spring WebFlux (1)
category: Reactive Spring
order: 2
permalink: /Reactive%20Spring/springwebflux/
---

> [리액티브 스프링 공식 reference](https://docs.spring.io/spring/docs/current/spring-framework-reference/web-reactive.html#webflux)를 한글로 번역한 문서입니다.
>
> 전체 목차는 [여기](https://godekdls.github.io/Reactive%20Spring/contents/)에 있습니다.

### 목차

- [1.1. Overview](#11-overview)
  + [1.1.1. Define “Reactive”](#111-define-reactive)
  + [1.1.2. Reactive API](#112-reactive-api)
  + [1.1.3. Programming Models](#113-programming-models)
  + [1.1.4. Applicability](#114-applicability)
  + [1.1.5. Servers](#115-servers)
  + [1.1.6. Performance](#116-performance)
  + [1.1.7. Concurrency Model](#117-concurrency-model)
- [1.2. Reactive Core](#12-reactive-core)
  + [1.2.1. HttpHandler](#121-httphandler)
  + [1.2.2. WebHandler API](#122-webhandler-api)
    * [Special bean types](#special-bean-types)
    * [Form Data](#form-data)
    * [Multipart Data](#multipart-data)
    * [Forwarded Headers](#forwarded-headers)
  + [1.2.3. Filters](#123-filters)
    * [CORS](#cors)
  + [1.2.4. Exceptions](#124-exceptions)
  + [1.2.5. Codecs](#125-codecs)
    * [Jackson JSON](#jackson-json)
    * [Form Data](#form)
    * [Multipart](#multipart)
    * [Limits](#limits)
    * [Streaming](#streaming)
    * [DataBuffer](#databuffer)
  + [1.2.6. Logging](#126-logging)
    * [Log Id](#log-id)
    * [Sensitive Data](#sensitive-data)
    * [Custom codecs](#custom-codecs)
- [1.3. DispatcherHandler](#13-dispatcherhandler)
  + [1.3.1. Special Bean Types](#131-special-bean-types)
  + [1.3.2. WebFlux Config](#132-webflux-config)
  + [1.3.3. Processing](#133-processing)
  + [1.3.4. Result Handling](#134-result-handling)
  + [1.3.5. Exceptions](#135-exceptions)
  + [1.3.6. View Resolution](#136-view-resolution)
    * [Handling](#handling)
    * [Redirecting](#redirecting)
    * [Content Negotiation](#content-negotiation)
- [1.4. Annotated Controllers](#14-annotated-controllers)
  + [1.4.1. @Controller](#141-controller)
  + [1.4.2. Request Mapping](#142-request-mapping)
    * [URI Patterns](#uri-patterns)
    * [Pattern Comparison](#pattern-comparison)
    * [Consumable Media Types](#consumable-media-types)
    * [Producible Media Types](#producible-media-types)
    * [Parameters and Headers](#parameters-and-headers)
    * [HTTP HEAD, OPTIONS](#http-head-options)
    * [Custom Annotations](#custom-annotations)
    * [Explicit Registrations](#explicit-registrations)
  + [1.4.3. Handler Methods](#143-handler-methods)
    * [Method Arguments](#method-arguments)
    * [Return Values](#return-values)
    * [Type Conversion](#type-conversion)
    * [Matrix Variables](#matrix-variables)
    * [@RequestParam](#requestparam)
    * [@RequestHeader](#requestheader)
    * [@CookieValue](#cookievalue)
    * [@ModelAttribute](#modelattribute)
    * [@SessionAttributes](#sessionattributes)
    * [@SessionAttribute](#sessionattribute)
    * [@RequestAttribute](#requestattribute)
    * [Multipart Content](#multipart-content)
    * [@RequestBody](#requestbody)
    * [HttpEntity](#httpentity)
    * [@ResponseBody](#responsebody)
    * [ResponseEntity](#responseentity)
    * [Jackson JSON](#jackson-json)
  + [1.4.4. Model](#144-model)
  + [1.4.5. DataBinder](#145-databinder)
  + [1.4.6. Managing Exceptions](#146-managing-exceptions)
    * [REST API exceptions](#rest-api-exceptions)
  + [1.4.7. Controller Advice](#147-controller-advice)

스프링 프레임워크, 스프링 웹 MVC를 포함한 기존 웹 프레임워크는
서블릿 API와 서블릿 컨테이너를 위해 개발됐다.
리액티브 스택 웹 프레임워크인 스프링 웹플럭스는 5.0 버전에 추가됐다.
완전하게 논블로킹으로 동작하며, 
[Reactive Streams](https://www.reactive-streams.org/)
back pressure를 지원하고,
Netty, Undertow, 서블릿 3.1+ 컨테이너 서버에서 동작한다.

두 웹 프레임워크 모두 소스 모듈 이름과 동일하며
([spring-webmvc](https://github.com/spring-projects/spring-framework/tree/master/spring-webmvc),
[spring-webflux](https://github.com/spring-projects/spring-framework/tree/master/spring-webflux)),
스프림 프레임워크에 공존한다.
원하는 모듈을 선택하면 된다.
둘 중 하나를 사용해 어플리케이션을 개발할 수 있고,
둘 다 사용할 수도 있다(예를 들어, 리액티브 `WebClient`를 사용하는 스프링 MVC 컨트롤러). 

## 1.1. Overview

스프링 웹플럭스는 왜 만들었나?

웹플럭스가 탄생한 이유 중 하나는
적은 쓰레드로 동시 처리를 제어하고 적은 하드웨어 리소스로 확장하기 위해
논블로킹 웹 스택이 필요했기 때문이다.
이전에도 서블릿 3.1은 논블로킹 I/O를 위한 API를 제공했다.
하지만 서블릿으로 논블로킹을 구현하려면 다른
동기 처리나(`Filter`, `Servlet`) 블로킹 방식(`getParameter`, `getPart`)을 쓰는
API를 사용하기 어렵다.
이런 점때문에 어떤 논블로킹 런타임과도 잘 동작하는 새 공통 API를 만들게 됐다.
이미 비동기 논블로킹 환경에서 자리를 잡은 서버(e.g. Netty)때문에라도 새 API가 필요했다.

또 다른 이유는 함수형 프로그래밍이다.
자바 5의 애노테이션 등장으로 선택의 폭이 넓어진 것처럼
(애노테이션을 선언한 REST 컨트롤러나 유닛 테스트 등),
자바 8에서 추가된 람다 표현식덕분에 자바에서도 함수형 API를 작성할 수 있게 됐다.
이 기능은 논블로킹 어플리케이션을 만들 때도 요긴하게 쓰이며,
이제는 continuation-style API(`CompletableFuture`와 [ReactiveX](http://reactivex.io/)로 대중화된)로
비동기 로직을 선언적으로 작성할 수 있다.
프로그래밍 모델 관점에서 보면, 
애노테이션을 선언한 컨트롤러와 웹플럭스를 웹 엔드포인트로 사용할 수 있는 건 자바 8덕분이다.

### 1.1.1. Define “Reactive”

이제 "논블로킹"과 "함수형"이 뭔지 알게 되었는데, 그러면 리액티브는 무슨 뜻일까?

"리액티브"라는 용어는 변화에 반응하는 것을 중심에 두고 만든 프로그래밍 모델을 의미한다
(I/O 이벤트에 반응하는 네트워크 컴포넌트, 마우스 이벤트에 반응하는 UI 컨트롤러 등).
논블로킹은 작업을 기다리기보단 완료되거나 데이터를 사용할 수 있게 되면 반응하므로,
이 말대로면 논블로킹도 리액티브다.

스프링은 "리액티브"와 관련한 중요한 메커니즘이 하나 더 있는데, 논블로킹 back pressure다.
동기식 명령형(imperative) 코드에서 블로킹 호출은 호출자를 강제로 기다리게 하는 일종의 back pressure다.
논블로킹 코드에선, 
프로듀셔 속도가 컨슈머 속도를 압도하지 않도록 이벤트 속도를 제어한다.

리액티브 스트림은 back pressure를 통한 비동기 컴포넌트간의 상호작용을 정의한
[간단한 스펙](https://github.com/reactive-streams/reactive-streams-jvm/blob/master/README.md#specification)이다
(자바 9에서도 채택했다). 
예를 들어 데이터 레포지토리([Publisher](https://www.reactive-streams.org/reactive-streams-1.0.1-javadoc/org/reactivestreams/Publisher.html) 역할)가
데이터를 만들고, HTTP 서버([Subscriber](https://www.reactive-streams.org/reactive-streams-1.0.1-javadoc/org/reactivestreams/Subscriber.html) 역할)로
이 데이터로 요청을 처리할 수 있다.
리액티브 스트림을 쓰는 주목적은 subscriber가 publisher의 데이터 생산 속도를 제어하는 것이다.

> **자주 묻는 질문: publisher 속도를 늦출 수 없으면 어떻게 할까?**
>
> 리액티브 스트림의 목적은 메커니즘과 경계를 확립하는 것이다.
> publisher가 속도를 늦출 수 없다면 버퍼에 담을지, 데이터를 날릴지,
> 실패로 처리할지 결정해야 한다.

### 1.1.2. Reactive API

리액티브 스트림은 컴포넌트 상호 작용에서 중요한 역할을 한다.
하지만 이건 라이브러리와 기반 구조에 사용되는 컴포넌트엔 유용해도,
어플리케이션 API에서 다루기엔 너무 저수준이다.
어플리케이션은 비동기 로직을 만들기 위한 풍부한 고수준 함수형 API가 필요하다.
(자바 8 스트림 API와 비슷하지만 collection만을 위한게 아니다).
이게 바로 리액티브 라이브러리가 하는 일이다.

[Reactor](https://github.com/reactor/reactor)는
스프링 웹플럭스가 선택한 리액티브 라이브러리다.
리액터는 [`Mono`](https://projectreactor.io/docs/core/release/api/reactor/core/publisher/Mono.html)와
[`Flux`](https://projectreactor.io/docs/core/release/api/reactor/core/publisher/Flux.html)
API 타입을 제공한다.
ReactiveX [vocabulary of operators](http://reactivex.io/documentation/operators.html)에 정리된
풍부한 연산자를 사용해 데이터 시퀀스를 0~1개는 `Mono`, 0~N개는 `Flux`로 표현할 수 있다.
리액터는 리액티브 스트림 라이브러리이기 때문에
모든 연산자는 논블로킹 back pressure를 지원한다.
리액터는 특히 서버 사이드 자바에 초점을 두고 스프링과 긴밀히 협력해서 개발됐다.

웹플럭스는 리액터를 핵심 라이브러리로 사용하지만,
다른 리액티브 라이브러리를 써도 리액티브 스트림으로 상호작용 할 수 있다.
웹플럭스 API의 일반적인 룰은,
순수한 `Publisher`를 입력으로 받아 내부적으로 리액터 타입으로 맞추고,
이걸 사용해서 `Flux`나 `Mono`를 반환한다.
따라서 어떤 `Publisher`든 입력으로 전달하고 연산할 수 있지만,
다른 리액티브 라이브러리를 사용하려면 출력 형식을 맞춰줘야 한다.
웹플럭스는 가능만 하다면(e.g. 애노테이션을 선언한 컨트롤러)
투명한 방식으로 RxJava나 다른 리액티브 라이브러리에 맞게 바꿔준다. 
자세한 내용은 [Reactive Libraries](https://godekdls.github.io/Reactive%20Spring/reactivelibraries/)를 참고하라.

> 리액티브 API와는 별개로 
> WebFlux는 코틀린의 [코루틴](https://docs.spring.io/spring/docs/current/spring-framework-reference/languages.html#coroutines)
> API와도 사용할 수 있는데,
> 이를 사용하면 좀 더 명령적(imperative)인 프로그래밍이 가능하다.
> 아래 나오는 코틀린 코드 샘플은 코루틴 API를 사용할 것이다.

### 1.1.3. Programming Models

`spring-web` 모듈에 있는 웹플럭스는,
여러 서버를 지원하기위한 
HTTP 추상화와 리액티브 스트림 [어댑터](#121-httphandler),
[코덱](#125-codecs),
Servlet API에 상응하는 코어 [`WebHandler` API](#122-webhandler-api)를
아우르는 개념이며, 이는 모두 논블로킹이다.

스프링 웹플럭스는 두 가지 프로그래밍 모델을 지원한다:

- [Annotated Controllers](#14-annotated-controllers):
스프링 MVC와 동일하며 `spring-web` 모듈에 있는 같은 애노테이션을 사용한다.
스프링 MVC와 웹플럭스 컨트롤러 모두 리액티브(Reactor, RxJava) 리턴 타입을
지원하기때문에 이 둘을 구분하기 어렵다.
한 가지 눈에 띄는 차이는 웹플럭스에선
`@RequestBody`로 리액티브 인자를 받을 수 있다는 것이다.
- [Functional Endpoints](https://godekdls.github.io//Reactive%20Spring/springwebflux2/#15-functional-endpoints):
경량화된 람다 기반 함수형 프로그래밍 모델.
요청을 라우팅해주는 조그만한 라이브러리나 유틸리티 모음이라고 생각하면 된다.
annotated controller와 다른 점은
애노테이션으로 의도를 선언해서 콜백받기보단
요청을 어플리케이션이 처음부터 끝까지 다 제어한다는 것이다.

### 1.1.4. Applicability

스프링 MVC냐 웹플럭스냐?

많이들 하는 질문이지만 이분법적 사고는 좋지 않다.
둘 모두 사용해서 선택의 폭을 넓힌다고 보는게 맞다.
이 둘은 지속성과 일관성을 위해 설계했으며,
함께 사용할 수 있고, 각자의 피드백이 서로에게 도움이 된다.
다음은 둘은 어떤 관련이 있는지,
공통점이 무엇이고 한쪽에서만 지원하는 게 무엇인지 나타낸 다이어그램이다:

![Spring MVC VS WebFlux](./../../images/reactivespring/spring-mvc-and-webflux-venn.png)

먼저 다음 제안을 고려해 보라:

- 이미 잘 동작하고 있는 스프링 MVC 어플리케이션이 있다면, 굳이 바꿀 필요 없다.
명령적(Imperative) 프로그래밍은 작성하기도, 이해하기도, 디버깅하기도 가장 쉽다.
지금까지 대부분이 블로킹 방식을 사용했기 때문에,
사용할 수 있는 라이브러리가 가장 풍부하다.
- 이미 논블로킹 웹 스택을 알아보고 있다면,
스프링 웹플럭스는 다른 웹 스택과 같은 실행 환경을 제공하면서도,
다양한 서버(Netty, Tomcat, Jetty, Undertow, 서블릿 3.1+ 컨테이너)와
여러 리액티브 라이브러리(리액터, JxJava 등)를 지원하며,
두 가지 프로그래밍 모델(애노테이션을 선언한 컨트롤러와 함수형 웹 엔드포인트)을 사용할 수 있다.
- 자바 8 람다나 코틀린으로 개발할 수 있는
경량의 함수형 웹 프레임워크를 찾고 있다면,
스프링 웹플럭스의 함수형 웹 엔드포인트를 사용하면 된다.
로직을 투명하게 제어할 수 있기 때문에
요구사항이 덜 복잡한 소규모 어플리케이션이나 마이크로서비스에서도
좋은 선택이 될 것이다.
- 마이크로 아키텍처에선 스프링 MVC로 만든 어플리케이션과,
스프링 웹플럭스 컨트롤러나 함수형 엔트포인트를 사용한
어플리케이션을 조합할 수 있다.
두 프레임워크 모두 애노테이션 기반 프로그래밍 모델을 지원하기 때문에
새로 학습할 필요 없이 각자에 맞는 툴을 선택할 수 있다.
- 간단하게는 어플리케이션 의존성(dependency)을 확인해봐도 좋다.
블로킹 방식의 영속성 API(JPA, JDBC)나 네트워크 API를 사용하고 있다면
스프링 MVC가 최소한 아키텍처를 통일할 수 있으므로 가장 좋은 선택이다.
리액터나 RxJava로도 각 쓰레드에서 블로킹 API를 호출할 수 있지만,
이렇게 하면 논블로킹 웹 스택을 거의 활용하기 어렵다.
- 스프링 MVC 어플리케이션에서 외부 서비스를 호출한다면
한번 리액티브 `WebClient`를 사용해봐라.
스프링 MVC 컨트롤러 메소드에서도
리액티브 타입(Reactor, RxJava나 [그 외](https://godekdls.github.io/Reactive%20Spring/reactivelibraries))을
반환할 수 있다.
서비스 호출에 지연이 있거나 여러 서비스가 엮여 있는 API라면
효과가 더 좋을 것이다.
물론 다른 리액티브 컴포넌트도 스프링 MVC 컨트롤러에서 호출할 수 있다.
- 팀 규모가 크다면 논블로킹, 함수형, 선언적 프로그래밍은
러닝커브가 높다는 점도 고려해야 한다.
한 번에 전환하지 않고 리액티브 `WebClient`부터 적용해보는 것도 좋은 방법이다.
작은 것부터 시작해서 변화가 있는지 확인해 봐라.
굳이 전환할 필요가 없는 경우도 많을 것이다.
어떤 변화를 확인해야 할지 감이 오지 않는다면,
논블로킹 I/O 동작 방식과 효과를 학습하는 것부터 시작해라
(예를 들어 싱글 쓰레드 기반 Node.js의 동시 처리).

### 1.1.5. Servers

스프링 웹플럭스는 톰캣, Jetty, 서블릿 3.1+ 컨테이너에서도,
서블릿 기반이 아닌 Netty나 Undertow에서도 잘 동작한다.
저수준 [공통 API](#121-httphandler)로 서버를 추상화하기 때문에
모든 서버에
고수준 [프로그래밍 모델](#113-programming-models)을 적용할 수 있다.

스프링 웹플럭스엔 서버 기동이나 중단을 위한 내장 기능은 없다.
하지만 스프링 설정과 [웹플럭스 구조](https://godekdls.github.io//Reactive%20Spring/springwebflux2/#111-webflux-config)를
[조립](#122-webhandler-api)해
적은 코드로 손쉽게 어플리케이션을 [실행](#121-httphandler)할 수 있다.

스프링 부트에선 웹플럭스 스타터가 이 단계를 자동화해준다.
스타터는 기본으로 Netty를 사용하지만,
메이븐이나 그래들 dependency만 수정하면 톰캣이나 Jetty, Undertow로 쉽게 교체할 수 있다.
스프링 부트가 Netty를 디폴트로 사용하는 이유는
보통 비동기 논블로킹에 많이 사용하기도 하고,
클라이언트와 서버가 리소스를 공유할 수 있어서다.

톰캣과 Jetty는 스프링 MVC, 웹플럭스 모두 사용할 수 있다.
하지만 동작 방식이 다르다는 점에 주의하라.
스프링 MVC는 서블릿의 블로킹 I/O를 사용하며,
어플리케이션에서 필요하면 서블릿 API를 직접 사용할 수 있다.
스프링 웹플럭스는 서블릿 3.1 논블로킹 I/O로 동작하며,
서블릿 API는 저수준 어댑터에서 사용하기 때문에 노출돼 있지 않다.

스프링 웹플럭스에서 Undertow를 사용할 때는 서블릿 API가 아닌
Undertow API를 사용한다.

### 1.1.6. Performance

성능은 여러 의미로 해석할 수 있다.
리액티브랑 논블로킹을 사용한다고 해서 바로 어플리케이션이 빨라지는 건 아니다.
물론 빨라질 수도 있다
(예를 들어 WebClient를 사용해서 외부 서비스 호출을 병렬로 처리한다면).
전반적으로 보면 논블로킹 방식이 처리할 일이 더 많다보니
처리 시간이 약간 더 길어질 수 있다.

리액티브와 논블로킹의 주된 이점은
고정된 적은 쓰레드와 적은 메모리로도 확장할 수 있다는 것이다.
예측할 수 있는 방법으로 확장하기 때문에
부하 속에서도 어플리케이션 복원 능력은 더 좋아진다.
하지만 이를 확인하려면 약간의 대기 시간이 필요하다
(느리고 예측 불가능한 네트워크 I/O 시간을 포함해서).
바로 여기서 리액티브 스택이 강점을 드러내며, 그 차이는 엄청나다.

### 1.1.7. Concurrency Model

스프링 MVC와 스프링 웹플럭스 둘 다 annotated controller를
사용할 수 있다는 점은 동일해도,
동시성 모델과 블로킹/쓰레드 기본 전략이 다르다.

스프링 MVC는 (그리고 일반적인 서블릿 어플리케이션이라면)
어플리케이션이 처리 중인 쓰레드가 잠시 중단될 수 있다
(예를 들어 외부 서비스를 호출하면).
그렇기 때문에 서블릿 컨테이너는
이 블로킹을 대비에 큰 쓰레드 풀로 요청을 처리한다.

스프링 웹플럭스는 (그리고 일반적인 논블로킹 서버라면)
실행 중인 쓰레드가 중단되지 않는다는 전제가 있다.
따라서 논블로킹 서버는 작은 쓰레드 풀(이벤트 루프 워커)을 고정해놓고
요청을 처리한다.

> "확장"과 "적은 쓰레드"가 모순처럼 들릴지도 모르지만,
> 쓰레드를 중단하지 않는다는 건(그리고 콜백에 처리를 맡기는 건)
> 요청을 처리할 다른 쓰레드가 필요 없고, 그렇기 때문에
> 블로킹을 대비할 필요가 없다는 뜻이다.

**Invoking a Blocking API**

블로킹 라이브러리를 사용해야 한다면 어떻게 해야 할까?
리액터, RxJava 모두 다른 쓰레드로 요청을 처리해 주는
`publishOn` 오퍼레이터를 지원한다.
블로킹을 쉽게 피해갈 수 있다는 말이긴 하지만,
블로킹 API자체가 동시성 모델에 적합하지 않다는 걸 유념하라.

**Mutable State**

리액터와 RxJava에서 로직은 연산자로 표현한다.
연산자를 사용하면 런타임에 분리된 환경에서 리액티브 파이프라인을 만들고,
각 파이프라인에서 데이터를 순차적으로 처리한다.
파이프라인 안에 있는 코드는 절대 동시에 실행되지 않으므로
더 이상 상태 공유(mutable state)를 신경쓰지 않아도 된다.

**Threading Model**

스프링 웹플럭스를 사용하는 어플리케이션은
어떤 쓰레드를 얼마나 실행할까?

- 최소한의 설정으로 스프링 웹 플럭스 서버를 띄우면
(예를 들어 데이터 접근이나 다른 dependency가 없는),
서버는 쓰레드 한 개로 운영하고, 소량의 쓰레드로 요청을 처리할 수 있다
(보통은 CPU 코어 수만큼).
하지만 서블릿 컨테이너는 서블릿 블로킹 I/O와
서블릿 3.1 논블로킹 I/O를 모두 지원하기 때문에
더 많은 쓰레드를 실행할 것이다 (예를 들어 톰캣은 10개).
- 리액티브 `WebClient`는 이벤트 루프 방식이다.
따라서 적은 쓰레드를 고정해 두고 쓴다
(예를 들어 리액터 Netty 커넥터를 쓴다면 `reactor-http-nio-`로 시작하는 쓰레드를 확인할 수 있다).
단, 클라이언트와 서버에서 모두 리액터 Netty를 사용하면
디폴트로 이벤트 루프 리소스를 공유한다.
- 리액터와 RxJava는 스케줄러라는 추상화된 쓰레드 풀 전략을 제공한다.
`publishOn` 연산자가 나머지 연산을 다른 쓰레드 풀로 전환할 때도
이 스케줄러를 사용한다.
스케줄러는 이름을 보면 동시 처리 전략을 알 수 있다.
예를 들어, 제한된 쓰레드로 CPU 연산이 많은 처리를 할 때는 “parallel”,
여러 쓰레드로 I/O가 많은 처리를 할 때는 "elastic"이다.
이런 쓰레드를 본다면
코드 어딘가에서 그 이름에 해당하는 쓰레드 풀 `Scheduler` 전략을 사용하고 있다는 뜻이다.
- 데이터에 접근하는 라이브러리나 다른 외부 dependency에서
쓰레드를 따로 실행하는 경우도 있다.

**Configuring**

스프링 프레임워크에서 [서버](#115-servers)를 직접 실행시키거나 중단할 수는 없다.
서버의 쓰레드 모델 바꾸고 싶다면
각 서버에 맞는 설정 API를 참고하거나,
아니면 스프링 부트를 써서 각 서버에 맞는 스프링 부트 옵션을 설정하면 된다.
`WebClient`는 코드로 직접 [설정](https://godekdls.github.io/Reactive%20Spring/webclient/#21-configuration)할
수 있다.
다른 라이브러리는 해당 라이브러리 문서를 확인하라.

## 1.2. Reactive Core

`spring-web`을 사용하면 다음과 같은 방법으로 리액티브 웹 어플리케이션을 만들 수 있다:

- 서버 쪽 요청은 저수준과 고수준으로 나눠서 처리한다.  
  + [HttpHandler](#121-httphandler): 논블로킹 I/O와 리액티브 스트림 back pressure로 HTTP 요청을 처리한다. 리액터 Netty, Undertow, 톰캣, Jetty, 서블릿 3.1+ 컨테이너 어댑터와 함께 사용한다.
  + [`WebHandler` API](#122-webhandler-api): 약간 더 고수준으로, 애노테이션을 선언한 컨트롤러나 함수형 엔드포인트같이 구체적인 프로그래밍 모델로 작성하는 범용 웹 API다.
- 클라이언트 사이드에서는 기본적으로 `ClientHttpConnector`가
논블로킹 I/O와 리액티브 스트림 back pressure로
HTTP 요청을 처리한다.
[Reactor Netty](https://github.com/reactor/reactor-netty),
리액티브 [Jetty HttpClient](https://github.com/jetty-project/jetty-reactive-httpclient)
어댑터와 함께 사용하며,
어플리케이션에서 사용하는 고수준 [WebClient](https://godekdls.github.io/Reactive%20Spring/webclient/)는
이를 기반으로 동작한다. 
- 클라이언트와 서버 사이드 모두, [코덱](#125-codecs)으로
HTTP 요청과 응답 컨텐츠를 직렬화/역직렬화힌다.

### 1.2.1. `HttpHandler`

[HttpHandler](https://docs.spring.io/spring-framework/docs/5.2.6.RELEASE/javadoc-api/org/springframework/http/server/reactive/HttpHandler.html)는
요청과 응답을 처리하는 메소드를 하나만 가지고 있다.
의도한 유일한 역할은 여러 HTTP 서버 API를 추상화하는 것이다.

지원하는 서버 API는 아래 표에 나타냈다:

|서버 이름|사용하는 Server API|리액티브 스트림 지원|
|:-----------------:	|:-------------:	|:-------------:	|
|Netty|Netty API|[Reactor Netty](https://github.com/reactor/reactor-netty)|
|Undertow|Undertow API|spring-web: Undertow to 리액티브 스트림 브릿지|
|톰캣|서블릿 3.1 논블로킹 I/O; ByteBuffers로 byte[]를 읽고 쓰는 톰캣 API|spring-web: 서블릿 3.1 논블로킹 I/O to 리액티브 스트림 브릿지|
|Jetty|서블릿 3.1 논블로킹 I/O; ByteBuffers로 byte[]를 쓰는 Jetty API|spring-web: 서블릿 3.1 논블로킹 I/O to 리액티브 스트림 브릿지|
|서블릿 3.1 컨테이너|서블릿 3.1 논블로킹 I/O|spring-web: 서블릿 3.1 논블로킹 I/O to 리액티브 스트림 브릿지|

서버 dependency는 아래 테이블에 있다
([지원 버전](https://github.com/spring-projects/spring-framework/wiki) 참고):

|서버 이름|Group id|Artifact name|
|:-----------------:	|:-------------:	|:-------------:	|
|리액터 Netty|io.projectreactor.netty|reactor-netty|
|Undertow|io.undertow|undertow-core|
|톰캣|org.apache.tomcat.embed|tomcat-embed-core|
|Jetty|org.eclipse.jetty|jetty-server, jetty-servlet|

다음은 각 서버 API 어댑터를 활용하는 `HttpHandler` 코드다:

**리액터 Netty**
- *java*
```java
HttpHandler handler = ...
ReactorHttpHandlerAdapter adapter = new ReactorHttpHandlerAdapter(handler);
HttpServer.create().host(host).port(port).handle(adapter).bind().block();
```
- *kotlin*
```kotlin
val handler: HttpHandler = ...
val adapter = ReactorHttpHandlerAdapter(handler)
HttpServer.create().host(host).port(port).handle(adapter).bind().block()
```

**Undertow**
- *java*
```java
HttpHandler handler = ...
UndertowHttpHandlerAdapter adapter = new UndertowHttpHandlerAdapter(handler);
Undertow server = Undertow.builder().addHttpListener(port, host).setHandler(adapter).build();
server.start();
```
- *kotlin*
```kotlin
val handler: HttpHandler = ...
val adapter = UndertowHttpHandlerAdapter(handler)
val server = Undertow.builder().addHttpListener(port, host).setHandler(adapter).build()
server.start()
```

**Tomcat**
- *java*<br>
    ```java
    HttpHandler handler = ...
    Servlet servlet = new TomcatHttpHandlerAdapter(handler);
    
    Tomcat server = new Tomcat();
    File base = new File(System.getProperty("java.io.tmpdir"));
    Context rootContext = server.addContext("", base.getAbsolutePath());
    Tomcat.addServlet(rootContext, "main", servlet);
    rootContext.addServletMappingDecoded("/", "main");
    server.setHost(host);
    server.setPort(port);
    server.start();
    ```
- *kotlin*<br>
    ```kotlin
    val handler: HttpHandler = ...
    val servlet = TomcatHttpHandlerAdapter(handler)
    
    val server = Tomcat()
    val base = File(System.getProperty("java.io.tmpdir"))
    val rootContext = server.addContext("", base.absolutePath)
    Tomcat.addServlet(rootContext, "main", servlet)
    rootContext.addServletMappingDecoded("/", "main")
    server.host = host
    server.setPort(port)
    server.start()
    ```

**Jetty**

- *java*<br>
    ```java
    HttpHandler handler = ...
    Servlet servlet = new JettyHttpHandlerAdapter(handler);
    
    Server server = new Server();
    ServletContextHandler contextHandler = new ServletContextHandler(server, "");
    contextHandler.addServlet(new ServletHolder(servlet), "/");
    contextHandler.start();
    
    ServerConnector connector = new ServerConnector(server);
    connector.setHost(host);
    connector.setPort(port);
    server.addConnector(connector);
    server.start();
    ```
- *kotlin*
    ```kotlin
    val handler: HttpHandler = ...
    val servlet = JettyHttpHandlerAdapter(handler)
    
    val server = Server()
    val contextHandler = ServletContextHandler(server, "")
    contextHandler.addServlet(ServletHolder(servlet), "/")
    contextHandler.start();
    
    val connector = ServerConnector(server)
    connector.host = host
    connector.port = port
    server.addConnector(connector)
    server.start()
    ```

**서블릿 3.1+ 컨테이너**

서블릿 3.1+ 컨테이너에 WAR를 배포하려면
WAR에 [`AbstractReactiveWebInitializer`](https://docs.spring.io/spring-framework/docs/5.2.6.RELEASE/javadoc-api/org/springframework/web/server/adapter/AbstractReactiveWebInitializer.html)를
확장해서 추가하면 된다.
이 클래스는 `HttpHandler`, `ServletHttpHandlerAdapter`를 감싸고 있으며,
이 핸들러를 `Servlet`으로 등록한다.

### 1.2.2. `WebHandler` API

`org.springframework.web.server` 패키지를 보면, [`HttpHandler`](#121-httphandler)가
[`WebHandler`](https://docs.spring.io/spring-framework/docs/5.2.6.RELEASE/javadoc-api/org/springframework/web/server/WebHandler.html)와,
여러 [`WebExceptionHandler`](https://docs.spring.io/spring-framework/docs/5.2.6.RELEASE/javadoc-api/org/springframework/web/server/WebExceptionHandler.html),
[`WebFilter`](https://docs.spring.io/spring-framework/docs/5.2.6.RELEASE/javadoc-api/org/springframework/web/server/WebFilter.html)로
체인을 형성해 요청을 처리하는 범용 웹 API를 제공한다.
`WebHttpHandlerBuilder`에 컴포넌트를 등록하거나,
스프링 `ApplicationContext` 위치만 알려주면
[자동으로](#special-bean-types) 
컴포넌트를 체인에 추가한다.

`HttpHandler`는 서로 다른 HTTP 서버를 쓰기 위한 추상화가 전부인 반면,
`WebHandler` API는 아래와 같이 웹 어플리케이션에서
흔히 쓰는 광범위한 기능을 제공한다:

- User session과 Session attributes.
- Request attributes.
- `Locale`, `Principal` 리졸브
- form 데이터 파싱, 캐시 조회.
- multipart 데이터 추상화.
- 기타 등등

#### Special bean types

다음은 `WebHttpHandlerBuilder`에 직접 등록하거나
어플리케이션 컨텍스트에서 자동으로 주입받을 수 있는 컴포넌트다:

|Bean name|Bean type|Count|Description|
|:-----------------:	|:-------------:	|:-------------:	|:-------------:	|
|\<any\>|`WebExceptionHandler`|0..N|`WebFilter` 체인과 `WebHandler`에서 발생한 예외를 처리한다. 자세한 내용은 [Exceptions](#124-exceptions)를 참고하라.|
|\<any\>|`WebFilter`|0..N|다른 필터 체인과 `WebHandler` 전후에 요청을 가로채 원하는 로직을 넣을 수 있다. 자세한 내용은 [Filters](#123-filters)를 참고하라.|
|`webHandler`|`WebHandler`|1|요청을 처리하는 핸들러.|
|`webSessionManager`|`WebSessionManager`|0..1|`WebSession`의 매니저. `WebSession`은 `ServerWebExchange`로 접근할 수 있다. 디폴트는 `DefaultWebSessionManager`다.|
|`serverCodecConfigurer`|`ServerCodecConfigurer`|0..1|form 데이터나 multipart 데이터를 파싱하는 `HttpMessageReader`를 설정하기 위한 인터페이스. 이 데이터는 `ServerWebExchange`로 접근할 수 있다. 디폴트는 `ServerCodecConfigurer.create()`를 사용한다.|
|`localeContextResolver`|`LocaleContextResolver`|0..1|`LocaleContext` 리졸버. `LocaleContext`는 `ServerWebExchange`로 접근한다. 디폴트 리졸버는 `AcceptHeaderLocaleContextResolver`다.|
|`forwardedHeaderTransformer`|`ForwardedHeaderTransformer`|0..1|forwarded 헤더를 파싱해서 추출 후 제거하거나, 제거만 하고 헤더 정보를 무시할수도 있다. 디폴트는 사용하지 않는 것이다.|

#### Form Data

`ServerWebExchange`는 form 데이터(`application/x-www-form-urlencoded`)에 접근할 수 있는 다음 메소드를 제공한다:

- *java*
```java
Mono<MultiValueMap<String, String>> getFormData();
```
- *kotlin*
```kotlin
suspend fun getFormData(): MultiValueMap<String, String>
```

`DefaultServerWebExchange`는 설정에 있는 `HttpMessageReader`를 사용해
form 데이터를 `MultiValueMap`으로 파싱한다.
디폴트로 사용하는 리더는 `ServerCodecConfigurer` 빈에 있는 `FormHttpMessageReader`다
([Web Handler API](#122-webhandler-api) 참고).

#### Multipart Data

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-multipart)

`ServerWebExchange`는 multipart 데이터에 접근할 수 있는 다음 메소드를 제공한다:

- *java*
```java
Mono<MultiValueMap<String, Part>> getMultipartData();
```
- *kotlin*
```kotlin
suspend fun getMultipartData(): MultiValueMap<String, Part>
```

`DefaultServerWebExchange`는 설정에 있는 `HttpMessageReader<MultiValueMap<String, Part>>`를 사용해
`multipart/form-data` 컨텐츠를 `MultiValueMap`으로 파싱한다.
현재로서는 [Synchronoss NIO Multipart](https://github.com/synchronoss/nio-multipart)가
유일하게 지원하는 서드파티 라이브러리이며, 논블로킹으로 multipart 요청을 파싱하는 유일한 라이브러리다.
`ServerCodecConfigurer` 빈으로 활성화할 수 있다. 
([Web Handler API](#122-webhandler-api) 참고).

스트리밍 방식으로 multipart 데이터를 파싱하려면
`HttpMessageReader<Part>`가 리턴하는 `Flux<Part>`를 사용하면 된다.
예를 들어 컨트롤러에서 `@RequestPart`를 선언하면
`Map`처럼 이름으로 각 파트에 접근하겠다는 뜻이므로,
multipart 데이터를 한 번에 파싱해야 한다.
반대로 `Flux<Part>`타입에 `@RequestBody`를 사용하면
컨텐츠를 디코딩할 때 `MultiValueMap`에 수집하지 않는다.

#### Forwarded Headers

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#filters-forwarded-headers)

프록시를 경유한 요청은(e.g. 로드 밸런서) 호스트, 포트, 스키마가 변경될 수 있기 때문에,
클라이언트 입장에서는 원래 url 정보를 알아내기 어렵다.

[RFC 7239](https://tools.ietf.org/html/rfc7239)에 따르면
Forwarded `HTTP` 헤더는 프록시가 원래 요청에 대한 정보를 추가하는 헤더다.
물론 `X-Forwarded-Host`, `X-Forwarded-Port`, `X-Forwarded-Proto`, 
`X-Forwarded-Ssl`, `X-Forwarded-Prefix`같은
비 표준 헤더도 있다.

`ForwardedHeaderTransformer`는 forwarded 헤더를 보고
요청의 호스트, 포트, 스키마를 바꿔준 다음, 헤더를 제거하는 컴포넌트다.
`forwardedHeaderTransformer`라는 이름으로 빈을 정의하면
자동으로 [체인에 추가](#special-bean-types)된다.

forwarded 헤더는 보안에 신경써야 할 요소가 있는데,
프록시가 헤더를 추가한 건지, 클라이언트가 악의적으로 추가한 것인지
어플리케이션에서는 알 수 없기 때문이다.
이 때문에 외부에서 들어오는 신뢰할 수 없는 프록시 요청을 제거하고 싶을 수도 있다.
`ForwardedHeaderTransformer`를 `removeOnly=true`로 설정하면
헤더 정보를 사용하지 않고 제거해 준다.

> 5.1 버전 부터 `ForwardedHeaderFilter`는 제거 대상에 올랐으며(deprecated),
> `ForwardedHeaderTransformer`로 대신한다.
> 따라서 exchange(http 요청/응답과 세션 정보 등의 컨테이너)를
> 만들 기 전에 forwarded 헤더를 처리할 수 있다.
> 필터로 설정하면 전체 필터 리스트에서 제외되고
> 대신 `ForwardedHeaderTransformer`를 사용한다.

### 1.2.3. Filters

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#filters)

[`WebHandler` API](#122-webhandler-api)에선 `WebFilter`를 사용하면,
다른 필터 체인과 `WebHandler` 전후에 요청을 가로채 원하는 로직을 넣을 수 있다.
`WebFilter`를 등록하려면 스프링 빈으로 만들어 원한다면 빈 위에 `@Order`를 선언하거나
`Ordered`를 구현해 순서를 정해도 되고,
[WebFlux Config](https://godekdls.github.io//Reactive%20Spring/springwebflux2/#111-webflux-config)를 사용해도 그만큼 간단하다.

#### CORS

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#filters-cors)

CORS는 컨트롤러에 애노테이션을 선언하는 것만으로 잘 동작한다.
하지만 Spring Security와 함께 사용한다면,
내장 `CorsFilter`를 사용해서 Spring Security의 필터 체인보다
먼저 처리되도록 해야 한다.

자세한 내용은 [CORS](https://godekdls.github.io//Reactive%20Spring/springwebflux2/#17-cors)와 [CORS webfilter](https://godekdls.github.io//Reactive%20Spring/springwebflux2/#175-cors-webfilter)를 참고하라.

### 1.2.4. Exceptions

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-ann-customer-servlet-container-error-page)

[`WebHandler` API](#122-webhandler-api)는
`WebFilter` 체인과 `WebHandler`에서 발생한 예외를 `WebExceptionHandler`로 처리한다.
`WebExceptionHandler`를 등록하려면 스프링 빈으로 만들어 원한다면
빈 위에 `@Order`를 선언하거나 `Ordered`를 구현해 순서를 정해도 되고,
[WebFlux Config](https://godekdls.github.io//Reactive%20Spring/springwebflux2/#111-webflux-config)를 사용해도 그만큼 간단하다.

다음은 바로 사용할 수 있는 `WebExceptionHandler` 구현체다:

|Exception Handler|Description|
|:-----------------:	|:-------------:	|
|`ResponseStatusExceptionHandler`|HTTP status code를 지정할 수 있는 [`ResponseStatusException`](https://docs.spring.io/spring-framework/docs/5.2.6.RELEASE/javadoc-api/org/springframework/web/server/ResponseStatusException.html)을 처리한다.|
|`WebFluxResponseStatusExceptionHandler`|`ResponseStatusExceptionHandler`를 확장한 것으로, 다른 exception 타입도 `@ResponseStatus`를 선언해서 HTTP staus code를 정할 수 있다.<br><br>이 핸들러는 [WebFlux Config](#111-webflux-config) 안에 선언 돼 있다.|

### 1.2.5. Codecs

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/integration.html#rest-message-conversion)

`spring-web`, `spring-core` 모듈을 사용하면
리액티브 논블로킹 방식으로
byte 컨텐츠를 고수준 객체로 직렬화, 역직렬화할 수 있다.
다음과 같은 내용을 지원 한다:

- [`Encoder`](https://docs.spring.io/spring-framework/docs/5.2.6.RELEASE/javadoc-api/org/springframework/core/codec/Encoder.html),
[`Decoder`](https://docs.spring.io/spring-framework/docs/5.2.6.RELEASE/javadoc-api/org/springframework/core/codec/Decoder.html)는 
HTTP와는 관계 없는 컨텐츠를 인코딩, 디코딩한다.
- [`HttpMessageReader`](https://docs.spring.io/spring-framework/docs/5.2.6.RELEASE/javadoc-api/org/springframework/http/codec/HttpMessageReader.html),
[`HttpMessageWriter`](https://docs.spring.io/spring-framework/docs/5.2.6.RELEASE/javadoc-api/org/springframework/http/codec/HttpMessageWriter.html)는
HTTP 메세지를 인코딩, 디코딩한다.
- 웹 어플리케이션에선 `Encoder`를 감싸고 있는 `EncoderHttpMessageWriter`와
`Decoder`를 감싸고 있는 `DecoderHttpMessageReader`를 사용할 수 있다.
- 모든 코덱은 라이브러리마다 다른 byte 버퍼(e.g. Netty `ByteBuf`, `java.nio.ByteBuffer` 등)를
추상화한 [`DataBuffer`](https://docs.spring.io/spring-framework/docs/5.2.6.RELEASE/javadoc-api/org/springframework/core/io/buffer/DataBuffer.html)로
처리한다. 자세한 내용은 스프링 코어의 [Data Buffers and Codecs](https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#databuffers)를
참고하라.

`spring-core` 모듈에는 `byte[]`, `ByteBuffer`,
`DataBuffer`, `Resource`, `String` 인코더/디코더 구현체가 있다. 
`spring-web` 모듈은 Jackson JSON, 
Jackson Smile, JAXB2, Protocol Buffers 등의 인코더/디코더와,
form 데이터, multipart 데이터, 서버 전송 이벤트(SSE) 등을 처리하는
웹 전용 HTTP 메세지 reader/writer를 제공한다.

`ClientCodecConfigurer`와 `ServerCodecConfigurer`로
기본 코덱을 설정하거나 커스텀 코덱을 등록할 수 있다.
[HTTP message codecs](https://godekdls.github.io//Reactive%20Spring/springwebflux2/#1116-http-message-codecs)를 참고하라.

#### Jackson JSON

JSON, binary JSON([Smile](https://github.com/FasterXML/smile-format-specification))
모두 Jackson 라이브러리 디펜던시가 있으면 추가된다.

`Jackson2Decoder`는 다음과 같이 동작한다:

- Jackson의 비동기, 논블로킹 파서가 `TokenBuffer`로 바이트 청크 스트림을 모아 JSON 객체로 변환한다.
- 각 `TokenBuffer`는 Jackson의 `ObjectMapper`로 넘겨져 고수준 객체를 만든다.
- single-value publisher(e.g. `Mono`)를 디코딩 할때는 `TokenBuffer`가 하나 뿐이다.
- multi-value publisher(e.g. `Flux`)를 디코딩 할때는, 각 `TokenBuffer`에
객체를 구성할 수 있을 만큼 바이트가 모이면 그때그때 `ObjectMapper`로 전달한다.
입력 컨텐츠는 JSON 배열이거나, 컨텐츠 타입이 `application/stream+json`이라면
[line-delimited JSON](https://en.wikipedia.org/wiki/JSON_streaming)일 수도 있다.

`Jackson2Encoder`는 다음과 같이 동작한다:

- single-value publisher(e.g. `Mono`)는 바로 `ObjectMapper`에서 직렬화한다.
- multi-value publisher를 `application/json`로 직렬화할 땐
기본적으로 `Flux#collectToList()`로 값을 수집한 다음 그 컬렉션을 직렬화한다.
- `application/stream+json`, `application/stream+x-jackson-smile`같은
스트리밍 타입을 값이 여러 개인 publisher로 직렬화하면
[line-delimited JSON](https://en.wikipedia.org/wiki/JSON_streaming) 포맷으로
따로따로 인코딩하고, write, flush한다.
- SSE라면 이벤트가 발생할 때 마다 `Jackson2Encoder`를 호출하고 바로 flush한다.

> 기본적으로 `Jackson2Encoder`, `Jackson2Decoder` 모두
> `String`을 객체로 사용할 수 없다. 
> 대신 string이나 string 시퀀스는 `CharSequenceEncoder`로 만들 수 있는
> 직렬화된 JSON 컨텐츠로 간주한다.
> `Flux<String>`으로 JSON 배열을 만들고 싶다면
> `Flux#collectToList()`를 사용해서 `Mono<List<String>>`을 인코딩하라.

#### Form

`FormHttpMessageReader`, `FormHttpMessageWriter`는
`application/x-www-form-urlencoded` 컨텐츠를 인코딩/디코딩한다.

form 데이터는 어플리케이션에서 여러번 접근하는 경우가 많기 때문에,
`ServerWebExchange`는
`FormHttpMessageReader`로 컨텐츠를 파싱한 뒤 캐시된 데이터를 반환하는
`getFormData()` 메소드를 제공한다.
[`Handler` API](#122-webhandler-api) 섹션의 [Form Data](#form-data)를 참고하라.

`getFormData()`를 한번 호출하고 나면 원본 컨텐츠는 다시 읽을 수 없다.
때문에 그 다음부터는 request body가 아닌 `ServerWebExchange`로 캐시된 데이터를 조회해야 한다.

#### Multipart

`MultipartHttpMessageReader`, `MultipartHttpMessageWriter`는
"multipart/form-data" 컨텐츠를 인코딩/디코딩한다.
사실 `MultipartHttpMessageReader`는 다른 `HttpMessageReader`에 파싱을 위임하고,
돌려받은 `Flux<Part>`를 `MultiValueMap`에 수집하는 역할만 한다.
실제 파싱은 [Synchronoss NIO Multipart](https://github.com/synchronoss/nio-multipart)를
사용한다.

multipart form 데이터는 어플리케이션에서 여러번 접근하는 경우가 많기 때문에,
`ServerWebExchange`는 `MultipartHttpMessageReader`로
컨텐츠를 파싱한 뒤 캐시된 데이터를 반환하는 `getMultipartData()` 메소드를 제공한다.
[`WebHandler` API](#122-webhandler-api) 섹션의 [Multipart Data](#multipart-data)를 참고하라.

`getMultipartData()`를 한번 호출하고 나면 원본 컨텐츠는 다시 읽을 수 없다.
때문에 그 다음부터는 request body 대신,
Map을 리턴하는 `getMultipartData()`를 사용해야 한다.
그게 아니라면 `SynchronossPartHttpMessageReader`를 사용해
매번 파싱해야한다.

#### Limits

`Decoder`나 `HttpMessageReader`처럼 입력 스트림을 버퍼링한다면,
메모리 버퍼 용량을 제한할 수 있다.
버퍼는 객체를 만들려면 입력을 어딘가에 모아놔야 해서 필요할 때도 있고,
(예를 들어 `@RequestBody byte[]`나 `x-www-form-urlencoded` 데이터를 받는 컨트롤러 메소드 등),
입력을 나눠서 스트리밍할 때도 버퍼링이 필요하다
(구분자를 사용하는(delimited) 텍스트나, JSON 객체 스트림 등).
스트리밍은 보통 객체 하나를 담을 수 있는 바이트 수로 제한한다.

버퍼 사이즈를 변경하고 싶으면 먼저 
`Decoder`나 `HttpMessageReader`에 `maxInMemorySize` 프로퍼티가
노출돼 있는지 확인해보고, 만약 그렇다면 Javadoc에 자세한 정보가 있을 것이다.
서버 사이드에선 모든 코덱은 `ServerCodecConfigurer`에 설정하면 된다
([HTTP message codecs](https://godekdls.github.io//Reactive%20Spring/springwebflux2/#1116-http-message-codecs) 참고). 
클라이언트 사이드에선 [WebClient.Builder](https://godekdls.github.io/Reactive%20Spring/webclient/#211-maxinmemorysize)로
코덱의 최대 버퍼 사이즈를 수정할 수 있다.

[Multipart 데이터를 파싱](#multipart)할 때는,
먼저 파일이 아닌 part가 사용할 메모리 크기는 `maxInMemorySize` 프로퍼티로 제한한다.
파일 part라면 이 프로퍼티는 디스크 크기를 제한한다.
이 때는 `maxDiskUsagePerPart`로 part 별 디스크 크기도 제한할 수 있다.
multipart 요청에 사용할 전체 part 수를 제한하는 `maxParts`도 있다.
웹플럭스에서 이같은 설정을 사용하려면
`ServerCodecConfigurer`에 `MultipartHttpMessageReader` 인스턴스가
설정돼 있어야 한다.

#### Streaming

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-ann-async-http-streaming)

HTTP 응답을 스트리밍할 땐
(예를 들어 `text/event-stream`, `application/stream+json`),
클라이언트 연결이 끊기면 가능한 빨리 알아챌 수 있도록
주기적으로 데이터를 보내는 게 좋다.
이 때 보내는 하트비트는 짧은 문자열이나, 비어있는 SSE 이벤트나,
"no-op"를 나타내는 데이터라면 어떤 것이든 사용할 수 있다.

#### `DataBuffer`

웹플럭스 코드에서 바이트 버퍼는 `DataBuffer`로 표현한다.
스프링 코어 문서를 보면
[Data Buffers and Codecs](https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#databuffers)에
더 자세한 내용이 나와있다.
핵심은 Netty같은 일부 서버에선 메모리 풀을 사용해서 바이트 버퍼를 처리하고
레퍼런스를 카운팅하므로, 메모리 릭을 방지하려면
컨슈밍하고 나서 버퍼 메모리를 반환해야 한다는 것이다.

코덱을 쓰는 대신 버퍼를 직접 처리하거나, 코덱을 커스텀하지만 않는다면
WebFlux 애플리케이션은
이런 이슈는 신경쓰지 않아도 된다.
예외 케이스에 해당한다면 [Data Buffers and Codecs](https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#databuffers)를
참고하라. 특히 [DataBuffer](https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#databuffers-using)
섹션을 유심히 봐라.

### 1.2.6. Logging

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-logging)

스프링 웹플럭스는 `DEBUG` 레벨 로그에 꼭 필요한 정보만 최소한으로 담았기 때문에 읽기 편할 것이다.
어떤 이슈에서도 유용할만한 가치있는 정보만 추렸다.

`TRACE` 레벨도 `DEBUG`와 원론적으로 동일하지만
(예를 들어 `TRACE`도 불필요한 정보를 잔뜩 쏟아내선 안된다),
이슈를 디버깅할 때 좀 더 유용할 만한 정보를 담았다.
일부 `TRACE`, `DEBUG` 레벨 로그는 디테일한 정도가 다를 것이다.

어떤 로그가 좋은 로그인지는 사용해 봐야 알 수 있다.
각 레벨과 어울리지 않는 로그를 발견하면 재보 바란다.

#### Log Id

웹플럭스에선 요청 하나를 여러 쓰레드로 처리할 수 있기 때문에,
쓰레드 ID만 보고는 어떤 요청인지 파악하기 어렵다.
그렇기 때문에 웹플럭스는 기본적으로
로그 메세지마다 앞에 요청 ID를 붙인다.

서버 사이드에선 이 로그 ID를 
`ServerWebExchange` attribute([`LOG_ID_ATTRIBUTE`](https://docs.spring.io/spring-framework/docs/5.2.6.RELEASE/javadoc-api/org/springframework/web/server/ServerWebExchange.html#LOG_ID_ATTRIBUTE))에
저장하며, `ServerWebExchange#getLogPrefix()`로 포맷팅된 로그 프리픽스를 확인할 수 있다.

`WebClient`에선
`ClientRequest` attribute ([`LOG_ID_ATTRIBUTE`](https://docs.spring.io/spring-framework/docs/5.2.6.RELEASE/javadoc-api/org/springframework/web/reactive/function/client/ClientRequest.html#LOG_ID_ATTRIBUTE))에
저장하고 포맷팅된 로그 프리픽스는 `ClientRequest#logPrefix()`로 확인할 수 있다.

#### Sensitive Data

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-logging-sensitive-data)

`DEBUG`, `TRACE` 로그는 민감한 정보를 포함할 수 있다.
따라서 form 파라미터와 헤더를 로깅하지 않는게 디폴트며,
원한다면 직접 활성화시켜야 한다.

다음은 서버 로그를 활성화 시키는 코드다:

- *java*
```java
@Configuration
@EnableWebFlux
class MyConfig implements WebFluxConfigurer {

    @Override
    public void configureHttpMessageCodecs(ServerCodecConfigurer configurer) {
        configurer.defaultCodecs().enableLoggingRequestDetails(true);
    }
}
```
- *kotlin*
```kotlin
@Configuration
@EnableWebFlux
class MyConfig : WebFluxConfigurer {

    override fun configureHttpMessageCodecs(configurer: ServerCodecConfigurer) {
        configurer.defaultCodecs().enableLoggingRequestDetails(true)
    }
}
```

다음은 클라이언트 로그를 활성화 시키는 코드다:

- *java*<br>
    ```java
    Consumer<ClientCodecConfigurer> consumer = configurer ->
            configurer.defaultCodecs().enableLoggingRequestDetails(true);
    
    WebClient webClient = WebClient.builder()
            .exchangeStrategies(strategies -> strategies.codecs(consumer))
            .build();
    ```
- *kotlin*<br>
    ```kotlin
    val consumer: (ClientCodecConfigurer) -> Unit  = { configurer -> configurer.defaultCodecs().enableLoggingRequestDetails(true) }
    
    val webClient = WebClient.builder()
            .exchangeStrategies({ strategies -> strategies.codecs(consumer) })
            .build()
    ```

#### Custom codecs

다른 미디어 타입이나 디폴트 코덱이 지원하지 않는 기능을 추가하고 싶으면
커스텀 코덱을 사용한다.

커스텀 코덱에서도 [버퍼 제한](#limits)이나 [form 데이터/헤더 로깅](#sensitive-data)같은
설정을 그대로 사용하고 싶을 수 있는데,
그럴 땐 디폴트 코덱에 설정한 일부 옵션을 재사용할 수 있다.

다음은 클라이언트 사이드 예제로,
커스텀 코덱에 디폴트 코덱 설정을 등록한다:

- *java*
```java
WebClient webClient = WebClient.builder()
        .codecs(configurer -> {
                CustomDecoder decoder = new CustomDecoder();
                configurer.customCodecs().registerWithDefaultConfig(decoder);
        })
        .build();
```
- *kotlin*
```kotlin
val webClient = WebClient.builder()
        .codecs({ configurer ->
                val decoder = CustomDecoder()
                configurer.customCodecs().registerWithDefaultConfig(decoder)
         })
        .build()
```

## 1.3. DispatcherHandler

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-servlet)

스프링 웹플럭스도 스프링 MVC와 유사한 프론트 컨트롤러 패턴을 사용한다.
중앙 `WebHandler`가 요청을 받아, 실제 처리는
다른 컴포넌트에 위임하는데, `DispatcherHandler`가 바로 이 중앙 `WebHandler`다.
이 모델덕분에 다양한 워크플로우를 지원할 수 있다.

`DispatcherHandler`는 스프링 설정에 따라 그에 맞는 컴포넌트로 위임한다.
`DispatcherHandler`도 스프링 빈이며, `ApplicationContextAware` 인터페이스를 구현했기 때문에
실행 중인 컨텍스트에 접근할 수 있다.
`DispatcherHandler` 빈을 `webHandler`란 이름으로 정의하면
[`WebHttpHandlerBuilder`](https://docs.spring.io/spring-framework/docs/5.2.6.RELEASE/javadoc-api/org/springframework/web/server/adapter/WebHttpHandlerBuilder.html)가
이를 감지하고, [`WebHandler` API](#122-webhandler-api)에서
설명했던 체인에 추가한다.

웹플럭스 어플리케이션에서 사용하는 일반적인
스프링 설정은 다음과 같다:

- `webHandler`란 이름의 `DispatcherHandler` 빈
- `WebFilter`, `WebExceptionHandler` 빈
- [그 외 `DispatcherHandler`가 사용하는 빈](#131-special-bean-types)
- 기타 등등

아래 코드에서 보이는 것처럼,
`WebHttpHandlerBuilder`가 체인을 만들 땐 이 설정을 사용한다.

- *java*
```java
ApplicationContext context = ...
HttpHandler handler = WebHttpHandlerBuilder.applicationContext(context).build();
```
- *kotlin*
```kotlin
val context: ApplicationContext = ...
val handler = WebHttpHandlerBuilder.applicationContext(context).build()
```

이땐 리턴된 `HttpHandler`는 [서버 어댑터](#121-httphandler)와 함께 요청을 처리한다.

### 1.3.1. Special Bean Types

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-servlet-special-bean-types)

`DispatcherHandler`는 요청을 처리하고
그에 맞는 응답을 만들 때 사용하는 특별한 빈이 있다.
"특별한 빈"이란, 웹플럭스 프레임워크가 동작하는데 필요한,
스프링이 관리하는 `Object` 인스턴스를 말한다. 
이 빈들은 기본적으로 내장돼 있지만,
프로퍼티를 수정해서 확장하거나 커스텀 빈으로 대체할 수도 있다.

`DispatcherHandler`는 다음과 같은 빈을 감지한다.
저수준에서 동작하는 다른 빈도 자동으로 추가될 수 있다는 점에 주의하라
(Web Handler API 섹션의 [Special bean types](#special-bean-types) 참고).

|Bean type|Explanation|
|:-----------------:	|:-------------:	|
|`HandlerMapping`|요청을 핸들러에 매핑한다. 매핑 기준은 `HandlerMapping` 구현체마다 다르다 (애노테이션을 선언한 컨트롤러, URL 패턴 매칭 등).<br><br>주로 쓰는 구현체는 `@RequestMapping`을 선언한 메소드를 찾는 `RequestMappingHandlerMapping`, 함수형 엔드포인트를 라우팅하는 `RouterFunctionMapping`, URI path 패턴으로 `WebHandler`를 찾는 `SimpleUrlHandlerMapping` 등이 있다.|
|`HandlerAdapter`|`HandlerAdapter`가 핸들러를 실행하는 방법을 알고 있기 때문에, `DispatcherHandler`는 어떤 핸들러든지 받아 처리할 수 있다. 예를 들어 애노테이션을 선언한 컨트롤러를 실행하려면 리졸버가 필요한데, `HandlerAdapter`를 사용하면 `DispatcherHandler`는 이런 디테일을 몰라도 된다.|
|`HandlerResultHandler`|핸들러가 건내준 결과를 처리하고 응답을 종료한다. [Result Handling](#134-result-handling)를 참고하라.|

### 1.3.2. WebFlux Config

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-servlet-config)

프레임워크 내부에서 사용하는 빈([Web Handler API](#special-bean-types)에 있는 리스트와 [`DispatcherHandler`](#131-special-bean-types))도
어플리케이션에서 직접 정의할 수 있다.
하지만 특별한 이유가 없다면 [WebFlux Config](https://godekdls.github.io//Reactive%20Spring/springwebflux2/#111-webflux-config)로
시작하는게 가장 좋다.
웹플럭스 config는 필요한 빈을 알아서 만들어주고,
쉽게 설정을 커스텀할 수 있는 콜백 API를 제공한다.

> 스프링부트를 사용해도 이 웹플러스 config로 초기화하며,
> 부트가 제공하는 옵션으로 좀 더 편리하게 설정을 관리할 수 있다.

### 1.3.3. Processing

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-servlet-sequence)

`DispatcherHandler`는 다음과 같이 요청을 처리한다:

- `HandlerMapping`을 뒤져 매칭되는 핸들러를 찾는다. 첫번째로 매칭된 핸들러를 사용한다.
- 핸들러를 찾으면 적당한 `HandlerAdapter`를 사용해 핸들러를 실행하고,
`HandlerResult`를 돌려 받는다.
- `HandlerResult`를 적절한 `HandlerResultHandler`로 넘겨
바로 응답을 만들거나 뷰로 렌더링하고 처리를 완료한다.

### 1.3.4. Result Handling

`HandlerAdapter`는 핸들러 실행을 완료하고 나면,
실행 결과와 컨텍스트 정보를 감싸고 있는 `HandlerResult`를 반환한다.
이 `HandlerResult`는 `HandlerResultHandler`가 받아서 요청을 완료한다.
다음은 [WebFlux Config](https://godekdls.github.io//Reactive%20Spring/springwebflux2/#111-webflux-config)에 정의돼 있는 `HandlerResultHandler` 구현체다:

|Result Handler Type|Return Values|Default Order|
|:-----------------:	|:-------------:	|:-------------:	|
|`ResponseEntityResultHandler`|`ResponseEntity`, 보통 `@Controller`에서 사용.|0|
|`ServerResponseResultHandler`|`ServerResponse`, 보통 함수형 엔드포인트에서 사용.|0|
|`ResponseBodyResultHandler`|`@ResponseBody` 메소드나 `@RestController`에서 리턴한 값을 처리.|100|
|`ViewResolutionResultHandler`|`CharSequence`, `View`, [Model](https://docs.spring.io/spring-framework/docs/5.2.6.RELEASE/javadoc-api/org/springframework/ui/Model.html), `Map`, [Rendering](https://docs.spring.io/spring-framework/docs/5.2.6.RELEASE/javadoc-api/org/springframework/web/reactive/result/view/Rendering.html)이나 다른 `Object`를 model attribute로 처리.<br><br>[View Resolution](#136-view-resolution) 참고.|`Integer.MAX_VALUE`|

### 1.3.5. Exceptions

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-exceptionhandlers)

`HandlerAdapter`가 리턴한 `HandlerResult`는
핸들러마다 다른 에러 처리 함수에 넘겨진다.
이 함수는 이럴 때 호출된다:

- 핸들러 실행에 실패한 경우 (예를 들어 `@Controller`에서).
- `HandlerResultHandler`가 핸들러가 리턴한 값을 처리하는 데 실패한 경우.

핸들러가 리턴한 리액티브 타입이 데이터를 produce하기 전에
에러를 알아차릴 수만 있으면,
이 함수로 응답을 변경할 수 있다(예를 들어 에러 status로).

이 덕분에 `@Controller` 클래스의 특정 메소드에 `@ExceptionHandler`를 선언할
수 있는 것이다. 
스프링 MVC에선 `HandlerExceptionResolver`가 이 역할을 담당한다.
여기서 중요한 건 MVC가 아니지만,
웹플럭스에선 핸들러를 선택하기 전 발생한 exception은
`@ControllerAdvice`로 처리할 수 없다는 것에 주의하라.

“Annotated Controller” 섹션의 [Managing Exceptions](#146-managing-exceptions)이나 
WebHandler API 섹션의 [Exceptions](#124-exceptions)을 참고하라.

### 1.3.6. View Resolution

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-viewresolver)

View resolution은 특정 view 기술에 얽매이지않고
HTML 템플릿이나 모델을 사용해 브라우저에 렌더링하는 기법을 말한다.
Spring 웹플럭스에선 [HandlerResultHandler](#134-result-handling)가
`ViewResolver` 인스턴스를 사용해
view의 논리적인 이름을 가리키는 String과 `View` 인스턴스를 매핑한다.
이 `View`는 응답을 만들 때 사용된다.

#### Handling

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-handling)

`ViewResolutionResultHandler`로 넘겨진 `HandlerResult`는
핸들러가 리턴한 값과,
요청을 처리하면서 추가한 attribute를 포함한 model을 가지고 있다.
리턴값은 다음 중 하나로 사용된다:

- `String`, `CharSequence`: `ViewResolver`로 `View`를 만들 때 사용할 view의 논리적인 이름
- `void`: 요청 path에 맞는 디폴트 view name을 앞뒤 슬래쉬를 제거해서 `View`로 리졸브한다.
view name이 제공되지 않았을 때나(e.g. model attribute를 리턴한 경우)
비동기 리턴값일 때도(e.g. `Mono`가 비어있을 때)
동일하게 처리한다.
- [Rendering](https://docs.spring.io/spring-framework/docs/5.2.6.RELEASE/javadoc-api/org/springframework/web/reactive/result/view/Rendering.html):
여러 가지 view resolution 시나리오를 위한 API.
IDE 자동 완성으로 옵션을 확인해봐라.
- `Model`, `Map`: model에 추가로 넣을 model attributes
- 그외: 그외 다른 리턴값은([BeanUtils#isSimpleProperty](https://docs.spring.io/spring-framework/docs/5.2.6.RELEASE/javadoc-api/org/springframework/beans/BeanUtils.html#isSimpleProperty-java.lang.Class-)가
true를 리턴하는 값은 예외) model에 추가할 model attribute로 간주한다.
`@ModelAttribute` 애노테이션이 없으면
[conventions](https://docs.spring.io/spring-framework/docs/5.2.6.RELEASE/javadoc-api/org/springframework/core/Conventions.html)와
클래스명으로 attribute name을 결정한다.

모델에는 비동기 리액티브 타입도 있을 수 있다(e.g. 리액터나 RxJava가 리턴한 값).
이런 model attribute는 `AbstractView`가 렌더링하기 전에 실제 값으로 바꿔준다.
single-value 리액티브 타입은 비어있지 않다면 값 하나로 리졸브 되고,
multi-value 리액티브 타입(e.g. `Flux<T>`)은
`List<T>`로 수집한다.

view resolution은 스프링 설정에
`ViewResolutionResultHandler`만 추가하면 된다.
[WebFlux Config](https://godekdls.github.io//Reactive%20Spring/springwebflux2/#1117-view-resolvers)는
view resolution을 위한 설정 API를 제공한다.

스프링 웹플럭스에 통합된 view 기술은
[View Technologies](https://godekdls.github.io//Reactive%20Spring/springwebflux2/#19-view-technologies)에서 자세히 설명한다.

#### Redirecting

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-redirecting-redirect-prefix)

리다이렉트는 view name에 `redirect:`를 프리픽스로 붙이기만 하면 된다.
`UrlBasedViewResolver`(하위 클래스도 포함)가
이를 리다이렉트 요청으로 판단한다.
프리픽스를 제외한 나머지 view name은 리다이렉트 URL로 사용한다.
동작 자체는 컨트롤러가 `RedirectView`나 
`Rendering.redirectTo("abc").build()`를 리턴했을 때와 동일하지만,
이 방법을 사용하면 컨트롤러가 직접 view name을 보고 처리한다.
`redirect:/some/resource`같은 값은
현재 어플리케이션에서 이동할 페이지를 찾고,
`redirect:https://example.com/arbitrary/path`같이 사용하면
해당 URL로 리다이렉트한다.

#### Content Negotiation

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-multiple-representations)

content negotiation은 `ViewResolutionResultHandler`가 담당한다.
요청 미디어 타입과 `View`가 지원하는 미디어 타입을 비교해서,
첫번째로 찾은 `View`를 사용한다.

스프링 웹플럭스는 [HttpMessageWriter](#125-codecs)로
JSON, XML같은 미디어 타입을 만드는 `HttpMessageWriterView`를 지원한다.
보통은 [WebFlux 설정](https://godekdls.github.io//Reactive%20Spring/springwebflux2/#1117-view-resolvers)을 통해
`HttpMessageWriterView`를 디폴트 view로 사용한다.
디폴트 뷰는 요청 미디어 타입과 일치하기만 하면 항상 사용되는 뷰다.

## 1.4. Annotated Controllers

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-controller)

스프링 웹플럭스는 애노테이션 기반 프로그래밍 모델을 지원하기 때문에,
`@Controller`, `@RestController` 컴포넌트로
요청을 매핑하고, 입력을 받고, exception을 처리할 수 있다.
컨트롤러는 메소드를 여러가지로 활용할 수 있어서
클래스를 상속하거나 인터페이스를 구현하지 않아도 된다.

다음은 아주 기본적인 예제다:

- *java*
```java
@RestController
public class HelloController {

    @GetMapping("/hello")
    public String handle() {
        return "Hello WebFlux";
    }
}
```
- *kotlin*
```kotlin
@RestController
class HelloController {

    @GetMapping("/hello")
    fun handle() = "Hello WebFlux"
}
```

위 코드에선 response body에 쓸 `String`을 리턴한다.

### 1.4.1. @Controller

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-ann-controller)

컨트롤러는 표준 스프링 빈으로 정의한다.
`@Controller` 애노테이션을 달면 스프링이 클래스패스
내 다른 `@Component` 클래스처럼 자동으로 스캔하고 빈으로 등록한다.
이 애노테이션을 선언하면 그 클래스가 web 컴포넌트라는 뜻이기도 하다.

`@Controller` 빈을 자동으로 등록하려면
다음 예제처럼 컴포넌트 스캔을 위한 설정이 필요하다:

- *java*
```java
@Configuration
@ComponentScan("org.example.web") // (1)
public class WebConfig {

    // ...
}
```
- *kotlin*
```kotlin
@Configuration
@ComponentScan("org.example.web") // (1)
class WebConfig {

    // ...
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `org.example.web` 패키지를 스캔한다.</small>

`@RestController`는 자체에
`@Controller`, `@ResponseBody`를 선언하고 있어서,
컨트롤러 내 모든 메소드에 `@ResponseBody`를 상속한다.
따라서 리턴한 값으로 view를 만들지 않고 response body에 바로 쓴다.

### 1.4.2. Request Mapping

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-ann-requestmapping)

컨트롤러 메소드에 요청을 매핑할 때는 `@RequestMapping`을 사용한다.
이 애노테이션에 있는 attribute로
URL, HTTP 메소드, 요청 파라미터, 헤더, 미디어 타입을 매칭할 수 있다.
메소드에 선언하거나, 모든 메소드에서 공유하고 싶을 땐 클래스 레벨에 선언한다.

HTTP 메소드를 바로 지정할 수 있는 애노테이션도 있다:

- `@GetMapping`
- `@PostMapping`
- `@PutMapping`
- `@DeleteMapping`
- `@PatchMapping`

위 애노테이션은,
컨트롤러 메소드는 거의 대부분이 HTTP 메소드 하나만 담당하기 때문에
지원하는 일종의 [커스텀 애노테이션](#custom-annotations)이다.
하지만 위 애노테이션을 선언하더라도,
다른 매핑 조건을 공통으로 사용하려면 클래스 레벨에 `@RequestMapping`을 선언해야 한다.

다음 예제도 클래스와 메소드에 모두 매핑 애노테이션을 선언했다:

- *java*
```java
@RestController
@RequestMapping("/persons")
class PersonController {

    @GetMapping("/{id}")
    public Person getPerson(@PathVariable Long id) {
        // ...
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public void add(@RequestBody Person person) {
        // ...
    }
}
```
- *kotlin*
```kotlin
@RestController
@RequestMapping("/persons")
class PersonController {

    @GetMapping("/{id}")
    fun getPerson(@PathVariable id: Long): Person {
        // ...
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    fun add(@RequestBody person: Person) {
        // ...
    }
}
```

#### URI Patterns

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-ann-requestmapping-uri-templates)

URI로 요청을 매핑할 때는 glob 패턴이나 와일드카드를 사용할 수 있다:

|Pattern|Description|Example|
|:-----------------:	|:-------------:	|:-------------:	|
|`?`|문자 하나|`"/pages/t?st.html"`은 `"/pages/test.html"`, `"/pages/t3st.html"` 둘 다 매칭된다|
|`*`|path segment 안에 있는 0개 이상의 문자|`"/resources/*.png"`는 `"/resources/file.png"`와 매칭된다.<br><br>`"/projects/*/versions"`는 `"/projects/spring/versions"`와는 매칭되지만 `"/projects/spring/boot/versions"`과는 매칭되지 않는다.|
|`**`|path 마지막에 있는 0개 이상의 path segment|`"/resources/**"`는 `"/resources/file.png"`, `"/resources/images/file.png"`와 매칭된다.<br><br>`"**"`는 path 마지막에서만 사용할 수 있기 때문에 `"/resources/**/file.png"`는 사용할 수 없다.|
|`{name}`|path segment 하나와 매칭되며, 이 segment를 "name"이라는 변수에 저장한다.|`"/projects/{project}/versions"`를 `"/projects/spring/versions"`와 매칭하면 `project` 변수는 `spring`이다.|
|`{name:[a-z]+}`|정규식 `"[a-z]+"`과 매칭되는 값을 "name"이라는 변수에 저장한다.|`"/projects/{project:[a-z]+}/versions"`는 `"/projects/spring/versions"`와는 매칭되지만 `"/projects/spring1/versions"`랑은 매칭되지 않는다.|
|`{*path}`|path 마지막에 있는 0개 이상의 path segment를 나타내며, "path"라는 변수에 이 값을 저장한다.|`/resources/{*file}`은 `"/resources/images/file.png"`와 매칭되고 `file` 변수는 `/images/file.png`가 된다.|

여기서 저장한 URI 변수는 아래 예제처럼
`@PathVariable`로 접근할 수 있다:

- *java*
```java
@GetMapping("/owners/{ownerId}/pets/{petId}")
public Pet findPet(@PathVariable Long ownerId, @PathVariable Long petId) {
    // ...
}
```
- *kotlin*
```kotlin
@GetMapping("/owners/{ownerId}/pets/{petId}")
fun findPet(@PathVariable ownerId: Long, @PathVariable petId: Long): Pet {
    // ...
}
```

아래 보이는 것처럼 URI 변수는 클래스와 메소드에 모두 선언할 수 있다:

- *java*
```java
@Controller
@RequestMapping("/owners/{ownerId}") // (1)
public class OwnerController {

    @GetMapping("/pets/{petId}") // (2) 
    public Pet findPet(@PathVariable Long ownerId, @PathVariable Long petId) {
        // ...
    }
}
```
- *kotlin*
```kotlin
@Controller
@RequestMapping("/owners/{ownerId}") // (1)
class OwnerController {

    @GetMapping("/pets/{petId}") // (2)
    fun findPet(@PathVariable ownerId: Long, @PathVariable petId: Long): Pet {
        // ...
    }
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 클래스 레벨 URI 매핑.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 메소드 레벨 URI 매핑.</small>

URI 변수는 자동으로 선언한 타입으로 변환되는데,
변환이 불가능하다면 `TypeMismatchException`이 발생한다. 
기본적인 타입(`int`, `long`, `Date` 등)은 대부분 지원하고 있으며,
컨트롤러에서 그외 데이터 타입을 사용하려면 바인더를 등록하면 된다.
[Type Conversion](#type-conversion)과 [`DataBinder`](#145-databinder)를
참고하라.

URI 변수에 이름을 지정할 수 있지만(`@PathVariable("customId")`),
파라미터 이름과 동일하다면 생략해도 된다.
단, 컴파일할때 디버그 정보도 포함시키거나(`-g`)
자바 8의 `-parameters` 플래그를 사용해야 한다.

`{*varName}`은 가장 뒤에 있는 0개 이상의 path segment를 나타내는 URI 변수다.
예를 들어 `/resources/{*path}`처럼 사용하면 `/resources/` 내
모든 파일과 매칭되며, `"path"` 변수엔 하위 경로를 포함한 상대 경로가 저장된다.

`{varName:regex}`는 `{변수명:정규식}`과 같이 표현하는 URI 변수다.
예를 들어 URL이 `/spring-web-3.0.5 .jar`라면,
다음 예제처럼 정규식으로 이름, 버전, 파일 확장자를 추출할 수 있다.

- *java*
```java
@GetMapping("/{name:[a-z-]+}-{version:\\d\\.\\d\\.\\d}{ext:\\.[a-z]+}")
public void handle(@PathVariable String version, @PathVariable String ext) {
    // ...
}
```
- *kotlin*
```kotlin
@GetMapping("/{name:[a-z-]+}-{version:\\d\\.\\d\\.\\d}{ext:\\.[a-z]+}")
fun handle(@PathVariable version: String, @PathVariable ext: String) {
    // ...
}
```

URI path 패턴에도 `${…​}` 플레이스홀더를 사용할 수 있다.
서버가 기동될 때 `PropertyPlaceHolderConfigurer`가
로컬, 시스템, 환경변수를 참고해 플레이스홀더를 치환한다.
플레이스홀더를 사용하면 환경마다 달라지는 base URL을 외부 설정으로 관리할 수 있다.

> 웹 어플리케이션은 URI path를 런타임에 패턴으로 매칭하는 경우가 많다.
> 스프링 웹플럭스는 `spring-web` 모듈에 들어있는
> `PathPattern`과 `PathPatternParser`로 패턴 매칭을 지원한다.

스프링 MVC에선 `/person`은 `/person.*`과도 매칭되지만,
스프링 웹플럭스는 이런 suffix 패턴은 지원하지 않는다.
URL 기반 content negotiation이 하고 싶다면,
더 쉽고 명시적이면서 보안에도 덜 취약한 쿼리 파라미터를 권장한다.

#### Pattern Comparison

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-ann-requestmapping-pattern-comparison)

URL과 매칭되는 패턴이 여러 개라면,
`PathPattern.SPECIFICITY_COMPARATOR`로 각 패턴을 비교해서
가장 구체적인 패턴을 선택한다.

패턴을 비교할 땐 URI 변수와 와일드카드 수를 기반으로 점수를 계산한다.
URI 변수가 와일드카드 보다 점수가 낮으며,
점수가 가장 낮은 패턴을 선택한다.
두 패턴이 점수가 같다면 더 긴 패턴을 사용한다.

어떤 URL과도 매칭되는 패턴은(e.g. `**`, `{*varName}`)
점수 계산에서 제외되며, 마지막 순위로 밀린다.
이런 패턴이 여러 개라면 가장 긴 패턴을 선택한다.

#### Consumable Media Types

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-ann-requestmapping-consumes)

다음 예제처럼 요청 `Content-Type`으로 매칭되는 범위를 줄일 수 있다.

- *java*
```java
@PostMapping(path = "/pets", consumes = "application/json")
public void addPet(@RequestBody Pet pet) {
    // ...
}
```
- *kotlin*
```kotlin
@PostMapping("/pets", consumes = ["application/json"])
fun addPet(@RequestBody pet: Pet) {
    // ...
}
```

consumes attribute는 부정 표현식을 지원한다.
예를 들어 `!text/plain`은 `text/plain`을 제외한 모든 컨텐츠 타입을 의미한다.

클래스 레벨에 `consumes` attribute를 지정해서 클래스 전체에서
공유할 수도 있다.
단, request mapping attribute는 대부분 클래스 레벨에 선언한 값을
확장해 쓰지만, `consumes` attribute는 덮어 쓴다.

> 자주 사용하는 미디어 타입은 `MediaType`에 상수로 선언돼 있다.
> (e.g. `APPLICATION_JSON_VALUE`, `APPLICATION_XML_VALUE`).

#### Producible Media Types

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-ann-requestmapping-produces)

다음 예제처럼, `Accept` 요청 헤더와 컨트롤러 메소드가 지원하는 컨텐츠 타입으로
매칭 범위를 줄일 수 있다:

- *java*
```java
@GetMapping(path = "/pets/{petId}", produces = "application/json")
@ResponseBody
public Pet getPet(@PathVariable String petId) {
    // ...
}
```
- *kotlin*
```kotlin
@GetMapping("/pets/{petId}", produces = ["application/json"])
@ResponseBody
fun getPet(@PathVariable String petId): Pet {
    // ...
}
```

미디어 타입에 캐릭터셋을 지정해도 된다.
produces 역시 부정 표현식을 지원한다.
예를 들어 `!text/plain`은 `text/plain`을 제외한 모든 컨텐츠 타입이다.

클래스 레벨에 `produces` attribute를 지정해서 클래스 전체에서
공유할 수도 있다.
단, request mapping attribute는 대부분 클래스 레벨에 선언한 값을
확장해 쓰지만, `produces` attribute는 덮어 쓴다.

> 자주 사용하는 미디어 타입은 `MediaType`에 상수로 선언돼 있다.
> (e.g. `APPLICATION_JSON_VALUE`, `APPLICATION_XML_VALUE`).

#### Parameters and Headers

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-ann-requestmapping-params-and-headers)

쿼리 파라미터 조건을 사용할 수도 있다.
쿼리 파라미터가 있는지(myParam), 혹은 없는지(!myParam),
아니면 특정 값을 가지고 있는지(myParam=myValue) 검증할 수 있다.
다음은 파라미터 값을 검사하는 예제다:

- *java*
```java
@GetMapping(path = "/pets/{petId}", params = "myParam=myValue") // (1) 
public void findPet(@PathVariable String petId) {
    // ...
}
```
- *kotlin*
```kotlin
@GetMapping("/pets/{petId}", params = ["myParam=myValue"]) // (1) 
fun findPet(@PathVariable petId: String) {
    // ...
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `myParam`이 `myValue`인지 확인한다.</small>

다음 예제처럼 요청 헤더를 검증할 수도 있다:

- *java*
```java
@GetMapping(path = "/pets", headers = "myHeader=myValue") // (1)
public void findPet(@PathVariable String petId) {
    // ...
}
```
- *kotlin*
```kotlin
@GetMapping("/pets", headers = ["myHeader=myValue"]) // (1)
fun findPet(@PathVariable petId: String) {
    // ...
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `myHeader`가 `myValue`인지 확인한다.</small>

#### HTTP HEAD, OPTIONS

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-ann-requestmapping-head-options)

`@GetMapping`과 `@RequestMapping(method=HttpMethod.GET)`은
HTTP HEAD도 처리해 준다. 컨트롤러 메소드를 변경할 필요는 없다.
`HttpHandler` 서버 어답터가 응답을 래핑해서
실제로 body에 쓰지는 않고, 바이트 수만 `Content-Length` 헤더에 넣어 준다.

HTTP OPTIONS 요청은 기본적으로
URL 패턴이 매칭되는 모든 `@RequestMapping` 메소드를 찾아,
지원하는 HTTP 메소드를 전부 `Allow` 응답 헤더에 추가한다.

HTTP 메소드를 선언하지 않은 `@RequestMapping`이 있다면
`Allow` 헤더는 `GET,HEAD,POST,PUT,PATCH,DELETE,OPTIONS`로 설정한다.
컨트롤러 메소드는 항상 지원하는 HTTP 메소드를 선언하는 게 좋다
(예를 들어 HTTP 메소드별 애노테이션 `@GetMapping`, `@PostMapping` 등등).

`@RequestMapping`에 직접 HTTP HEAD나 OPTIONS 메소드를 지정할 순 있지만,
특별한 이유가 없다면 명시하지 않아도 된다.

#### Custom Annotations

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-ann-requestmapping-composed)

스프링 웹플럭스에선 [composed annotation](https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#beans-meta-annotations)으로
요청을 매핑할 수 있다.
이 애노테이션은 자체에 `@RequestMapping`이 선언돼 있고,
`@RequestMapping` attibute 일부를(혹은 전체를) 다시 지정할 수 있다.

`@GetMapping`, `@PostMapping`, `@PutMapping`, `@DeleteMapping`, 
`@PatchMapping`이 그 예시이다.
`@RequestMapping`은 HTTP 메소드를 지정하지 않으면 모든 메소드와 매칭되는데,
컨트롤러 메소드는 왠만하면 HTTP 메소드를 하나만 지정해서 써야한다.
그렇기 때문에 이 애노테이션을 따로 지원한다.
예제가 필요하다면, 애노테이션이 어떻게 선언되어 있는지 확인해 봐라.

커스텀 attribute로 직접 매핑 로직을 구현할 수도 있다.
그러려면 `RequestMappingHandlerMapping`을 상속해서,
`getCustomMethodCondition` 메소드에서
커스텀 attribute를 검사하고 직접 만든 `RequestCondition`을 리턴해야 한다.

#### Explicit Registrations

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-ann-requestmapping-registration)

코드로도 핸들러 메소드를 등록할 수 있다.
이 방법을 사용하면 핸들러 메소드를 동적으로 등록하거나,
URL이 다르면 같은 핸들러의 다른 인스턴스를 사용할 수도 있다.
다음은 핸들러 메소드를 등록하는 방법이다:

- *java*
```java
    @Configuration
    public class MyConfig {
    
        @Autowired // (1)
        public void setHandlerMapping(RequestMappingHandlerMapping mapping, UserHandler handler) 
                throws NoSuchMethodException {
            // (2)
            RequestMappingInfo info = RequestMappingInfo
                    .paths("/user/{id}").methods(RequestMethod.GET).build();
            // (3)
            Method method = UserHandler.class.getMethod("getUser", Long.class);
            // (4)
            mapping.registerMapping(info, handler, method);
        }
    
    }
    ```
- *kotlin*
    ```kotlin
    @Configuration
    class MyConfig {
    
        @Autowired // (1)
        fun setHandlerMapping(mapping: RequestMappingHandlerMapping, handler: UserHandler) {
            // (2)
            val info = RequestMappingInfo.paths("/user/{id}").methods(RequestMethod.GET).build()
            // (3)
            val method = UserHandler::class.java.getMethod("getUser", Long::class.java)
            // (4)
            mapping.registerMapping(info, handler, method)
        }
    }
    ```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 컨트롤러에서 사용할 타겟 핸들러와 핸들러 매핑을 주입한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 요청을 매핑하기 위한 메타 데이터를 준비한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 핸들러 메소드를 가져온다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> 핸들러 매핑에 등록한다.</small>

### 1.4.3. Handler Methods

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-ann-methods)

`@RequestMapping` 핸들러는 다양한 컨트롤러 메소드 인자와 리턴값을 지원하므로
원하는 것을 선택하면 된다.

#### Method Arguments

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-ann-arguments)

컨트롤러 메소드에서 사용할 수 있는 인자는 아래 테이블에 있다.

블로킹 I/O로 받는 인자는(예를 들어 request body를 읽는 경우)
리액티브 타입(리액터, RxJava, [그 외](https://godekdls.github.io/Reactive%20Spring/reactivelibraries/))을
사용할 수 있다.
이런 타입은 Description 컬럼에 명시해 뒀다.
블로킹이 없는 인자는 리액티브 타입을 사용하지 않는다.

일부 애노테이션은(e.g. `@RequestParam`, `@RequestHeader` 등) `required` attribute로
필수 여부를 지정할 수 있으며,
JDK 1.8의 `java.util.Optional`을 사용해도 된다.
효과는 `required=false`와 동일하다.

|Controller method argument|Description|
|:-----------------:	|:-------------:	|
|`ServerWebExchange`|`ServerWebExchange`는 HTTP 요청, 응답, request attributes, session attributes를 모두 포함하고 있는 컨테이너다. `checkNotModified` 메소드도 지원한다.|
|`ServerHttpRequest`, `ServerHttpResponse`|HTTP 요청과 응답에 접근할 수 있다.|
|`WebSession`|세션에 접근할 수 있다. 세션에 접근해도 attribute를 추가하지 않으면 새 세션을 열지 않는다. 리액티브 타입을 지원한다.|
|`java.security.Principal`|현재 인증된 유저 — `Principal` 구현체가 있다면 구현체를 리졸브한다. 리액티브 타입을 지원한다.|
|`org.springframework.http.HttpMethod`|요청 HTTP 메소드|
|`java.util.Locale`|요청의 locale 정보. `LocaleResolver`가 가장 구체적인 locale을 리졸브한다. — 사실상 `LocaleResolver`/`LocaleContextResolver` 설정이 결정한다.|
|`java.util.TimeZone` + `java.time.ZoneId`|요청에 사용된 타임존. `LocaleContextResolver`가 결정한다.|
|`@PathVariable`|URI 템플릿 변수에 접근하는 용도. [URI Patterns](#uri-patterns) 참고.|
|`@MatrixVariable`|URI path segment를 name/value 쌍으로 접근하는 용도. [Matrix Variables](#matrix-variables) 참고.|
|`@RequestParam`|서블릿 request 파라미터에 접근할 수 있다. 파라미터 값은 메소드에 선언한 인자 타입으로 변환된다. [`@RequestParam`](#requestparam) 참고.<br><br>`@RequestParam`은 생략해도 된다. — 예를 들어 애노테이션을 생략하고, 파라미터 대신 attribute를 매핑할 수도 있다. 테이블 마지막에 나오는 “Any other argument” 참고.|
|`@RequestHeader`|요청 헤더에 접근하는 용도. 헤더 값은 메소드에 선언한 인자 타입으로 변환된다. [@RequestHeader](#requestheader) 참고.|
|`@CookieValue`|쿠키에 접근하는 용도. 쿠기 값은 메소드에 선언한 인자 타입으로 변환된다. [@CookieValue](#cookievalue) 참고.|
|`@RequestBody`|HTTP request body에 접근하는 용도. `HttpMessageReader`가 body를 메소드에 선언한 인자 타입으로 변환한다. 리액티브 타입을 지원한다. [@RequestBody](#requestbody) 참고.|
|`HttpEntity<B>`|요청 헤더와 body에 접근하는 용도. `HttpMessageReader`가 body를 변환한다. 리액티브 타입을 지원한다. [HttpEntity](#httpentity) 참고.|
|`@RequestPart`|`multipart/form-data` 요청에서 part에 접근하는 용도. 리액티브 타입을 지원한다. [Multipart Content](#multipart-content), [Multipart Data](#multipart-data) 참고.|
|`java.util.Map`, `org.springframework.ui.Model`, `org.springframework.ui.ModelMap`|HTML 컨트롤러가 템플릿으로 뷰를 렌더링할 때 사용하는 모델에 접근할 수 있다.|
|`@ModelAttribute`|model에 있는 attribute에 접근할 수 있다(attribute가 없다면 model 초기화만 한다). 이 때 데이터를 바인딩하면서 유효성도 함께 검사한다. [`@ModelAttribute`](#modelattribute), [Model](#144-model), [DataBinder](#145-databinder) 참고.<br><br>`@ModelAttribute`는 생략해도 된다. 이 테이블 마지막에 나오는 “Any other argument”를 참고하라.|
|`Errors`, `BindingResult`|커맨드 객체를 메소드 인자에 바인딩할 땐 유효성을 검증 할 수 있는데(e.g. `@ModelAttribute`), 이 때 발생한 에러에 접근하는 용도로 사용한다. `Errors`, `BindingResult` 인자는 유효성을 검증하는 인자 바로 뒤에 사용해야 한다.|
|`SessionStatus` + 클래스 레벨 `@SessionAttributes`|`@SessionAttributes` 애노테이션을 클래스에 선언하면 세션에 attribute를 저장하는데, `SessionStatus`를 인자로 받아 session 처리가 완료됐다고 알려주면 session attribute를 지운다. 자세한 내용은 [`@SessionAttributes`](#sessionattribute) 참고.|
|`UriComponentsBuilder`|요청 호스트, 포트, 스키마, path로 URL을 만들 수 있다. [URI Links](https://godekdls.github.io//Reactive%20Spring/springwebflux2/#161-uricomponents) 참고.|
|`@SessionAttribute`|session attribute에 접근하는 용도. 클래스 레벨에 `@SessionAttributes`를 선언하면 세션에 model attribute를 저장하지만, 메소드 인자에 `@SessionAttribute`를 선언하면 session attribute에 접근할 수 있다. 자세한 내용은 [`@SessionAttribute`](#sessionattribute) 참고.|
|`@RequestAttribute`|request attribute에 접근하는 용도. 자세한 내용은 [`@RequestAttribute`](#requestattribute) 참고.|
|Any other argument|그 외 타입을 메소드 인자로 선언하면 [BeanUtils#isSimpleProperty](https://docs.spring.io/spring-framework/docs/5.2.6.RELEASE/javadoc-api/org/springframework/beans/BeanUtils.html#isSimpleProperty-java.lang.Class-) 결과가 true인 경우엔 `@RequestParam`에, 그 외는 `@ModelAttribute`로 리졸브한다.|

#### Return Values

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-ann-return-types)

컨트롤러 메소드에서 리턴할 수 있는 값은 아래 테이블에 있다.
모두 리액터, RxJava나 [그 외](https://godekdls.github.io/Reactive%20Spring/reactivelibraries/)
리액티브 라이브러리가 사용하는 리액티브 타입을 지원한다.

|Controller method return value|Description|
|:-----------------:	|:-------------:	|
|`@ResponseBody`|리턴한 값을 `HttpMessageWriter`로 인코딩해서 body에 쓴다. [`@ResponseBody`](#responsebody) 참고.|
|`HttpEntity<B>`, `ResponseEntity<B>`|HTTP 헤더를 포함해서 response를 직접 지정할 수 있다. body는 `HttpMessageWriter`로 인코딩한다. [`ResponseEntity`](#responseentity) 참고.|
|`HttpHeaders`|body 없이 헤더로만 응답하는 용도.|
|`String`|`ViewResolver`에서 사용하는 view name으로, 커맨드 객체와 `@ModelAttribute` 메소드로 만든 모델과 함께 사용한다. 핸들러 메소드에서도 `Model`을 인자로 받아 attribute를 추가할 수 있다([앞에서](#handling) 설명했다).|
|`View`|커맨드 객체와 `@ModelAttribute` 메소드로 만든 모델과 함께 렌더링하는 `View` 인스턴스. 핸들러 메소드에서도 `Model`을 인자로 받아 attribute를 추가할 수 있다([앞에서](#handling) 설명했다).|
|`java.util.Map`, `org.springframework.ui.Model`|모델에 attribute를 추가할 수 있다. view name은 요청 path로 결정한다.
|`@ModelAttribute`|모델에 attribute를 추가할 수 있다. view name은 요청 path로 결정한다.<br><br>`@ModelAttribute`는 생략해도 된다. 이 테이블 마지막에 나오는 “Any other return value”를 참고하라.|
|`Rendering`|model과 view를 만드는 API.|
|`void`|void 메소드는 비동기 값(`Mono<Void>`)이나 null을 리턴한 경우도 포함이다. 이 때는 `ServerHttpResponse`, `ServerWebExchange` 인자가 있거나, `@ResponseStatus` 애노테이션을 선언했다면 요청을 완료한 것으로 간주한다. ETag나 `lastModified` 헤더로 클라이언트 캐시가 최신이라고 판단했을 때도 동일하다. 자세한 내용은 [Controllers](https://godekdls.github.io//Reactive%20Spring/springwebflux2/#1102-controllers)를 참조하라.<br><br>그 외엔 REST 컨트롤러에선 "response body가 없음"을 의미하고, HTML 컨트롤러에선 디폴트 view name을 선택한다.|
|`Flux<ServerSentEvent>`, `Observable<ServerSentEvent>`, or other reactive type|서버 전송 이벤트(SSE)를 발생시킨다. 데이터만 전송하면 된다면 `ServerSentEvent` 래퍼는 생략해도 된다(단, 헤더에 `text/event-stream`을 사용하거나, `produces` attribute로 매핑해야 한다).|
|Any other return value|`String`은 view name으로 사용하고, `void`면 디폴트 view name을 사용한다. 그 외에는 [BeanUtils#isSimpleProperty](https://docs.spring.io/spring-framework/docs/5.2.6.RELEASE/javadoc-api/org/springframework/beans/BeanUtils.html#isSimpleProperty-java.lang.Class-) 결과가 false면 모델 attribute로 사용하고, true면 리졸브하지 못한다.|

#### Type Conversion

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-ann-typeconversion)

컨트롤러 메소드에 사용하는 일부 인자는
String으로 요청한 값을 매핑하기 때문에(`@RequestParam`, `@RequestHeader`, `@PathVariable`, `@MatrixVariable`, `@CookieValue` 등)
`String`이 아닌 다른 타입으로 선언했다면 타입을 변환해야한다.

이런 경우엔 설정한 컨버터가 자동으로 변환해 준다.
기본적인 타입은(`int`, `long`, `Date` 등) 디폴트로 지원한다.
직접 타입을 변환하고 싶으면
`WebDataBinder`([`DataBinder`](#145-databinder) 참고)를 만들거나
`FormattingConversionService`에 `Formatters`를 등록하면 된다 
([Spring Field Formatting](https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#format) 참고).

#### Matrix Variables

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-ann-matrix-variables)

[RFC 3986](https://tools.ietf.org/html/rfc3986#section-3.3)에 따르면
path segment에 name/value 쌍 변수를 사용할 수 있다.
스프링 웹플럭스에선 Tim Berners-Lee가 오래 전 작성한 [문서](https://www.w3.org/DesignIssues/MatrixURIs.html)를
따라 이를 “메트릭스 변수”라고 부르는데, URI path 파라미터라고도 한다.

메트릭스 변수는 path segment 어디에든 사용할 수 있다.
각 변수는 세미콜론(`;`)으로 구분하고 값이 여러 개라면 콤마(`,`)로 구분한다
(e.g. `"/cars;color=red,green;year=2012"`).
값이 여러 개일 땐 변수 이름을 반복해도 된다 
(e.g. `"color=red;color=green;color=blue"`).

스프링 MVC와는 다르게 웹플럭스에선
메트릭스 변수가 있다고 해서 request 매핑이 달라지지 않는다.
다시 말해 URI 변수로 지정하지 않아도 된다는 뜻이다.
즉, 컨트롤러 메소드에서 메트릭스 변수에 접근하고 싶을 때만
해당하는 path segment에 URI 변수를 추가하면 된다.
다음은 메트릭스 변수를 사용하는 예제다:

- *java*
    ```java
    // GET /pets/42;q=11;r=22
    
    @GetMapping("/pets/{petId}")
    public void findPet(@PathVariable String petId, @MatrixVariable int q) {
    
        // petId == 42
        // q == 11
    }
    ```
- *kotlin*
    ```kotlin
    // GET /pets/42;q=11;r=22
    
    @GetMapping("/pets/{petId}")
    fun findPet(@PathVariable petId: String, @MatrixVariable q: Int) {
    
        // petId == 42
        // q == 11
    }
    ```

메트릭스 변수를 여러 path segment에서 사용한다면,
아래 예제처럼 메트릭스 변수가 어떤 path에 있는지 명시하면 된다:

- *java*
    ```java
    // GET /owners/42;q=11/pets/21;q=22
    
    @GetMapping("/owners/{ownerId}/pets/{petId}")
    public void findPet(
            @MatrixVariable(name="q", pathVar="ownerId") int q1,
            @MatrixVariable(name="q", pathVar="petId") int q2) {
    
        // q1 == 11
        // q2 == 22
    }
    ```
- *kotlin*
    ```kotlin
    // GET /owners/42;q=11/pets/21;q=22
    
    @GetMapping("/owners/{ownerId}/pets/{petId}")
    fun findPet(
            @MatrixVariable(name = "q", pathVar = "ownerId") q1: Int,
            @MatrixVariable(name = "q", pathVar = "petId") q2: Int) {
    
        // q1 == 11
        // q2 == 22
    }
    ```

아래 예제처럼 필수 여부와 디폴트 값을 지정할 수도 있다:

- *java*
    ```java
    // GET /pets/42
    
    @GetMapping("/pets/{petId}")
    public void findPet(@MatrixVariable(required=false, defaultValue="1") int q) {
    
        // q == 1
    }
    ```
- *kotlin*
    ```kotlin
    // GET /pets/42
    
    @GetMapping("/pets/{petId}")
    fun findPet(@MatrixVariable(required = false, defaultValue = "1") q: Int) {
    
        // q == 1
    }
    ```

`MultiValueMap`에 모든 매트릭 변수를 담을 수도 있다:

- *java*
    ```java
    // GET /owners/42;q=11;r=12/pets/21;q=22;s=23
    
    @GetMapping("/owners/{ownerId}/pets/{petId}")
    public void findPet(
            @MatrixVariable MultiValueMap<String, String> matrixVars,
            @MatrixVariable(pathVar="petId") MultiValueMap<String, String> petMatrixVars) {
    
        // matrixVars: ["q" : [11,22], "r" : 12, "s" : 23]
        // petMatrixVars: ["q" : 22, "s" : 23]
    }
    ```
- *kotlin*
    ```kotlin
    // GET /owners/42;q=11;r=12/pets/21;q=22;s=23
    
    @GetMapping("/owners/{ownerId}/pets/{petId}")
    fun findPet(
            @MatrixVariable matrixVars: MultiValueMap<String, String>,
            @MatrixVariable(pathVar="petId") petMatrixVars: MultiValueMap<String, String>) {
    
        // matrixVars: ["q" : [11,22], "r" : 12, "s" : 23]
        // petMatrixVars: ["q" : 22, "s" : 23]
    }
    ```

#### `@RequestParam`

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-ann-requestparam)

`@RequestParam` 애노테이션은 쿼리 파라미터를 컨트롤러 메소드 인자로 바인딩한다.
다음은 이 애노테이션을 사용하는 예제다:

- *java*
```java
@Controller
@RequestMapping("/pets")
public class EditPetForm {

    // ...

    @GetMapping
    public String setupForm(@RequestParam("petId") int petId, Model model) { // (1)
        Pet pet = this.clinic.loadPet(petId);
        model.addAttribute("pet", pet);
        return "petForm";
    }

    // ...
}
```
- *kotlin*
    ```kotlin
    import org.springframework.ui.set
    
    @Controller
    @RequestMapping("/pets")
    class EditPetForm {
    
        // ...
    
        @GetMapping
        fun setupForm(@RequestParam("petId") petId: Int, model: Model): String { // (1) 
            val pet = clinic.loadPet(petId)
            model["pet"] = pet
            return "petForm"
        }
    
        // ...
    }
    ```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `@RequestParam`을 사용한다.</small>

> 서블릿 API에선 “요청 파라미터”는
> 쿼리 파라미터, form 데이터, multiparts 데이터를 모두 포함하는 개념이다.
> 하지만 웹플럭스에선 `ServerWebExchange`를 사용해 각각 따로 접근하며,
> `@RequestParam`은 쿼리 파라미터만 바인딩한다.
> 쿼리 파라미터, form 데이터, multiparts를 모두 사용하려면
> [커맨드 객체](#modelattribute)로 바인딩하면 된다.

`@RequestParam`을 선언한 파라미터는 디폴트가 필수값이며,
변경하려면 `required` attribute를 `false`로 지정하거나
인자를 `java.util.Optional`로 감싸야 한다.

메소드 파라미터가 `String`이 아니라면 자동으로 타입을 변환한다.
[Type Conversion](#type-conversion)을 참고하라.

`Map<String, String>`이나 `MultiValueMap<String, String>`에 
`@RequestParam`을 선언하면 map에 모든 쿼리 파라미터를 추가한다.

`@RequestParam`은 생략해도 된다. 
예를 들어 애노테이션을 생략하고, 파라미터 대신 attribute를 매핑할 수도 있다.
적당한 리졸버가 없고
[BeanUtils#isSimpleProperty](https://docs.spring.io/spring-framework/docs/5.2.6.RELEASE/javadoc-api/org/springframework/beans/BeanUtils.html#isSimpleProperty-java.lang.Class-)
결과가 true면 `@RequestParam`을 선언한 것과 동일하게 처리한다.

#### `@RequestHeader`

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-ann-requestheader)

`@RequestHeader` 애노테이션은 요청 헤더를 컨트롤러 메소드 인자로 바인딩한다.

다음은 요청 헤더 예시다:

```
Host                    localhost:8080
Accept                  text/html,application/xhtml+xml,application/xml;q=0.9
Accept-Language         fr,en-gb;q=0.7,en;q=0.3
Accept-Encoding         gzip,deflate
Accept-Charset          ISO-8859-1,utf-8;q=0.7,*;q=0.7
Keep-Alive              300
```

다음은 `Accept-Encoding`, `Keep-Alive` 헤더 값을 바인딩하는 코드다:

- *java*
```java
@GetMapping("/demo")
public void handle(
        @RequestHeader("Accept-Encoding") String encoding, // (1) 
        @RequestHeader("Keep-Alive") long keepAlive) { // (2)
    //...
}
```
- *kotlin*
```kotlin
@GetMapping("/demo")
fun handle(
        @RequestHeader("Accept-Encoding") encoding: String, // (1)
        @RequestHeader("Keep-Alive") keepAlive: Long) { // (2)
    //...
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `Accept-Encoging` 헤더 값을 가져온다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> `Keep-Alive` 헤더 값을 가져온다.</small>

메소드 파라미터가 `String`이 아니라면 자동으로 타입을 변환한다. 
[Type Conversion](#type-conversion)을 참고하라.

`Map<String, String>`, `MultiValueMap<String, String>`,
`HttpHeaders`에
`@RequestHeader`를 선언하면 map에 모든 헤더를 추가한다.

> 콤마(`,`)로 구분하는 문자열은 String 배열이나 컬렉션 등으로 자동으로
> 변환해 준다. 예를 들어 `@RequestHeader("Accept")`는
> `String` 인자 외에도 `String[]`이나 `List<String>`에
> 선언할 수 있다.

#### `@CookieValue`

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-ann-cookievalue)

`@CookieValue` 애노테이션은 HTTP 쿠키를 컨트롤러 메소드 인자로 바인딩한다.

다음은 쿠키 예시다:

```
JSESSIONID=415A4AC178C59DACE0B2C9CA727CDD84
```

다음은 쿠키 값을 바인딩하는 코드다:

- *java*
```java
@GetMapping("/demo")
public void handle(@CookieValue("JSESSIONID") String cookie) { // (1) 
    //...
}
```
- *kotlin*
```kotlin
@GetMapping("/demo")
fun handle(@CookieValue("JSESSIONID") cookie: String) { // (1)
    //...
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 쿠키 값을 가져온다.</small>

메소드 파라미터가 `String`이 아니라면 자동으로 타입을 변환한다. 
[Type Conversion](#type-conversion)을 참고하라.

#### `@ModelAttribute`

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-ann-modelattrib-method-args)

메소드 인자에 `@ModelAttribute` 애노테이션을 사용하면
model attribute에 접근할 수 있으며, attribute가 없더라도 model을 생성해 준다.
쿼리 파라미터나 form 데이터 필드명이 객체 필드명과 일치한다면
model attribute에 추가된다.
따라서 쿼리 파라미터나 form 필드를 일일이 파싱하지 않아도 되며,
이를 데이터 바인딩이라고 한다.

다음은 `Pet` 인스턴스로 바인딩하는 예제다:

- *java*
```java
@PostMapping("/owners/{ownerId}/pets/{petId}/edit")
public String processSubmit(@ModelAttribute Pet pet) { } // (1)
```
- *kotlin*
```kotlin
@PostMapping("/owners/{ownerId}/pets/{petId}/edit")
fun processSubmit(@ModelAttribute pet: Pet): String { } // (1)
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `Pet` 인스턴스에 바인딩한다.</small>

다음과 같은 방법으로 `Pet` 인스턴스를 리졸브한다:

- [`Model`](#144-model) attribute가 있다면 model을 통해서.
- [`@SessionAttributes`](#sessionattributes)에 값이 있다면 HTTP 세션을 통해서.
- 기본 생성자를 통해서.
- 쿼리 파라미터나 form 필드와 일치하는 인자를 받는 "첫 번째 생성자"를 통해서.
인자 이름은 자바빈 `@ConstructorProperties`로 지정하지 않으면
런타임에 바이트 코드에 있는 파라미터 명을 사용한다.

데이터 바인딩은 model attribute 인스턴스를 생성한 다음 진행한다.
`WebExchangeDataBinder`가 쿼리 파라미터와 form 필드 이름을
바인딩할 `Object` 필드명과 비교한다.
필요하다면 필드 매칭 전 타입을 변환한다.
데이터 바인딩과 유효성 검증에 대한 자세한 정보는
[Validation](https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#validation)을
참고하라.
데이터 바인딩을 커스텀하고 싶다면 [DataBinder](#145-databinder)를 참고하라.

데이터 바인딩에 실패하면 기본적으로 `WebExchangeBindException`이 발생한다.
컨트롤러 메소드에서 에러를 처리하고 싶다면 
다음 예제처럼 `@ModelAttribute` 인자 바로 다음에 `BindingResult`를
받으면 된다:

- *java*
```java
@PostMapping("/owners/{ownerId}/pets/{petId}/edit")
public String processSubmit(@ModelAttribute("pet") Pet pet, BindingResult result) { // (1) 
    if (result.hasErrors()) {
        return "petForm";
    }
    // ...
}
```
- *kotlin*
```kotlin
@PostMapping("/owners/{ownerId}/pets/{petId}/edit")
fun processSubmit(@ModelAttribute("pet") pet: Pet, result: BindingResult): String { // (1) 
    if (result.hasErrors()) {
        return "petForm"
    }
    // ...
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `BindingResult`를 추가한다.</small>

`javax.validation.Valid`나 스프링의 `@Validated` 애노테이션을
선언하면, 데이터를 바인딩 한 후 자동으로 유효성을 검증한다
([Bean Validation](https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#validation-beanvalidation),
[Spring validation](https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#validation) 참고).
다음 예제는 `@Valid` 애노테이션을 사용한다:

- *java*
```java
@PostMapping("/owners/{ownerId}/pets/{petId}/edit")
public String processSubmit(@Valid @ModelAttribute("pet") Pet pet, BindingResult result) { 
    if (result.hasErrors()) {
        return "petForm";
    }
    // ...
}
```
- *kotlin*
```kotlin
@PostMapping("/owners/{ownerId}/pets/{petId}/edit")
fun processSubmit(@Valid @ModelAttribute("pet") pet: Pet, result: BindingResult): String { 
    if (result.hasErrors()) {
        return "petForm"
    }
    // ...
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> model attribute 인자에 `@Valid`를 선언한다.</small>

스프링 웹플럭스는 스프링 MVC와는 달리 모델에 리액티브 타입을 사용할 수 있다
(e.g. `Mono<Account>`, `io.reactivex.Single<Account>`).
리액티브 타입으로 `@ModelAttribute` 인자를 감싸는 것은 선택 사항이며,
상황에 따라 필요하다면 실제 값을 리졸브한다.
하지만 `BindingResult`를 인자로 받으려면 위 예시처럼
리액티브 타입으로 감싸지 않은 `@ModelAttribute` 인자가 바로 앞에 있어야 한다.
아니면 다음 예제처럼 리액티브 타입으로 에러를 처리해도 된다:

- *java*
```java
@PostMapping("/owners/{ownerId}/pets/{petId}/edit")
public Mono<String> processSubmit(@Valid @ModelAttribute("pet") Mono<Pet> petMono) {
    return petMono
        .flatMap(pet -> {
            // ...
        })
        .onErrorResume(ex -> {
            // ...
        });
}
```
- *kotlin*
```kotlin
@PostMapping("/owners/{ownerId}/pets/{petId}/edit")
fun processSubmit(@Valid @ModelAttribute("pet") petMono: Mono<Pet>): Mono<String> {
    return petMono
            .flatMap { pet ->
                // ...
            }
            .onErrorResume{ ex ->
                // ...
            }
}
```

`@ModelAttribute`는 생략해도 된다.
예를 들어 애노테이션을 생략하고, 파라미터 대신 attribute를 매핑할 수도 있다.
적당한 리졸버가 없고 [BeanUtils#isSimpleProperty](https://docs.spring.io/spring-framework/docs/5.2.6.RELEASE/javadoc-api/org/springframework/beans/BeanUtils.html#isSimpleProperty-java.lang.Class-)
결과가 false면 `@ModelAttribute`를 선언한 것과 동일하게 처리한다.

#### `@SessionAttributes`

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-ann-sessionattributes)

`@SessionAttributes`는 model attribute를 요청이 끝나도 유지되는 
`WebSession`에 저장한다.
[type 레벨](https://docs.oracle.com/javase/8/docs/api/java/lang/annotation/ElementType.html#TYPE) 애노테이션으로,
컨트롤러에서 사용할 session attributes를 지정할 수 있다.
보통 세션에 넣어놓고 다음 요청에서도 이어서 접근하는
model attributes 이름이나 타입 리스트를 명시한다.

다음 예제를 보라:

- *java*
```java
@Controller
@SessionAttributes("pet") // (1)
public class EditPetForm {
    // ...
}
```
- *kotlin*
```kotlin
@Controller
@SessionAttributes("pet") // (1)
class EditPetForm {
    // ...
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `@SessionAttributes`를 사용한다.</small>

model에 `pet`이란 attribute를 한 번 저장하고 나면
자동으로 `WebSession`에 추가된다.
이 값은 다음 예제처럼 컨트롤러 메소드에서 `SessionStatus`를 인자로 받아
지우기 전까지 유된한다:

- *java*
```java
@Controller
@SessionAttributes("pet") // (1)
public class EditPetForm {

    // ...

    @PostMapping("/pets/{id}")
    public String handle(Pet pet, BindingResult errors, SessionStatus status) { // (2) 
        if (errors.hasErrors()) {
            // ...
        }
            status.setComplete();
            // ...
        }
    }
}
```
- *kotlin*
```kotlin
@Controller
@SessionAttributes("pet") // (1)
class EditPetForm {

    // ...

    @PostMapping("/pets/{id}")
    fun handle(pet: Pet, errors: BindingResult, status: SessionStatus): String { // (2) 
        if (errors.hasErrors()) {
            // ...
        }
        status.setComplete()
        // ...
    }
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `@SessionAttributes`를 사용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `SessionStatus`를 인자로 받는다.</small>

#### @SessionAttribute

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-ann-sessionattribute)

전역에서 관리하는(필터같이 컨트롤러 밖에 있는 컴포넌트에서)
session attribute에 접근하고 싶다면,
다음 예제처럼 메소드 파라미터에 `@SessionAttribute`를 사용한다:

- *java*
```java
@GetMapping("/")
public String handle(@SessionAttribute User user) { // (1)
    // ...
}
```
- *kotlin*
```kotlin
@GetMapping("/")
fun handle(@SessionAttribute user: User): String { // (1)
    // ...
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `@SessionAttribute`를 사용한다.</small>

session attribute를 추가하거나 제거하고 싶다면
컨트롤러 메소드에서 `WebSession`을 주입받으면 된다.

컨트롤러에서 model attribute를 임시로 세션에 저장해야 한다면 앞에서 설명한
[`@SessionAttributes`](#sessionattributes)를 활용하면 된다.

#### `@RequestAttribute`

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-ann-requestattrib)

`@SessionAttribute`와 유사하게 `@RequestAttribute` 애노테이션으로
컨트롤러에 진입하기 전에 만든(e.g. `WebFilter`)
request attributes에 접근할 수 있다: 

- *java*
```java
@GetMapping("/")
public String handle(@RequestAttribute Client client) { // (1)
    // ...
}
```
- *kotlin*
```kotlin
@GetMapping("/")
fun handle(@RequestAttribute client: Client): String { // (1)
    // ...
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `@RequestAttribute`를 사용한다.</small>

#### Multipart Content

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-multipart-forms)

[Multipart Data](#multipart-data)에서 설명했듯이,
multipart 컨텐츠는 `ServerWebExchange`로 접근할 수 있다.
컨트롤러에서 파일 업로드 form을(e.g. 브라우저가 보낸) 처리하는 가장 좋은 방법은
다음 예제처럼 [커맨드 객체](#modelattribute)에 바인딩하는 것이다:

- *java*
    ```java
    class MyForm {
    
        private String name;
    
        private MultipartFile file;
    
        // ...
    
    }
    
    @Controller
    public class FileUploadController {
    
        @PostMapping("/form")
        public String handleFormUpload(MyForm form, BindingResult errors) {
            // ...
        }
    
    }
    ```
- *kotlin*
    ```kotlin
    class MyForm(
            val name: String,
            val file: MultipartFile)
    
    @Controller
    class FileUploadController {
    
        @PostMapping("/form")
        fun handleFormUpload(form: MyForm, errors: BindingResult): String {
            // ...
        }
    
    }
    ```

RESTful 서비스로
브라우저 이외의 클라이언트가 보내는 mutipart 요청도
처리할 수 있다.
다음 예제는 JSON으로 파일을 전송한다:

```
POST /someUrl
Content-Type: multipart/mixed

--edt7Tfrdusa7r3lNQc79vXuhIIMlatb7PQg7Vp
Content-Disposition: form-data; name="meta-data"
Content-Type: application/json; charset=UTF-8
Content-Transfer-Encoding: 8bit

{
    "name": "value"
}
--edt7Tfrdusa7r3lNQc79vXuhIIMlatb7PQg7Vp
Content-Disposition: form-data; name="file-data"; filename="file.properties"
Content-Type: text/xml
Content-Transfer-Encoding: 8bit
... File Data ...
```

각 part는 `@RequestPart`로 접근할 수 있다:

- *java*
```java
@PostMapping("/")
public String handle(@RequestPart("meta-data") Part metadata, // (1) 
        @RequestPart("file-data") FilePart file) { // (2)
    // ...
}
```
- *kotlin*
```kotlin
@PostMapping("/")
fun handle(@RequestPart("meta-data") Part metadata, // (1)
        @RequestPart("file-data") FilePart file): String { // (2)
    // ...
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `@RequestPart`로 메타 데이터를 가져온다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> `@RequestPart`로 파일을 가져온다.</small>

다음 예제처럼
part 데이터를 `Part`대신 원하는 `Object`로 바인딩할 수도 있다
(JSON을 `@RequestBody`로 역직렬화하는 것과 유사하다):

- *java*
```java
@PostMapping("/")
public String handle(@RequestPart("meta-data") MetaData metadata) { 
    // ...
}
```
- *kotlin*
```kotlin
@PostMapping("/")
fun handle(@RequestPart("meta-data") metadata: MetaData): String { 
    // ...
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `@RequestPart`로 메타 데이터를 가져온다.</small>

`@RequestPart`도
`javax.validation.Valid`나 스프링의 `@Validated` 애노테이션을 붙이면
표준 빈 검증 방식으로 유효성을 확인한다.
유효성 검증에 실패하면 `WebExchangeBindException`이 발생하고
400(BAD_REQUEST)으로 응답한다.
exception은 상세 정보를 확인할 수 있는 `BindingResult`를 가지고 있다.
메소드 인자를 비동기 타입으로 감싸면 연산자로 에러를 처리할 수 있다:

- *java*
```java
@PostMapping("/")
public String handle(@Valid @RequestPart("meta-data") Mono<MetaData> metadata) {
    // use one of the onError* operators...
}
```
- *kotlin*
```kotlin
@PostMapping("/")
fun handle(@Valid @RequestPart("meta-data") metadata: MetaData): String {
    // ...
}
```

`MultiValueMap`으로 multipart 데이터 전체에 접근하려면
다음 예제처럼 `@RequestBody`를 사용하면 된다:

- *java*
```java
@PostMapping("/")
public String handle(@RequestBody Mono<MultiValueMap<String, Part>> parts) { // (1) 
    // ...
}
```
- *kotlin*
```kotlin
@PostMapping("/")
fun handle(@RequestBody parts: MultiValueMap<String, Part>): String { // (1) 
    // ...
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `@RequestBody`를 사용한다.</small>

스트리밍 방식으로 multipart 데이터에 순차적으로 접근하고 싶을 땐
`@RequestBody`와 `Flux<Part>`를(코틀린은 `Flow<Part>`) 사용한다: 

- *java*
```java
@PostMapping("/")
public String handle(@RequestBody Flux<Part> parts) { // (1) 
    // ...
}
```
- *kotlin*
```kotlin
@PostMapping("/")
fun handle(@RequestBody parts: Flow<Part>): String { // (1)
    // ...
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `@RequestBody`를 사용한다.</small>

#### `@RequestBody`

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-ann-requestbody)

`@RequestBody` 애노테이션을 붙이면 [HttpMessageReader](#125-codecs)가
request body를 `Object`로 역직렬화한다.
다음은 `@RequestBody` 예제다:

- *java*
```java
@PostMapping("/accounts")
public void handle(@RequestBody Account account) {
    // ...
}
```
- *kotlin*
```kotlin
@PostMapping("/accounts")
fun handle(@RequestBody account: Account) {
    // ...
}
```

스프링 MVC와는 달리 웹플럭스는 리액티브 타입을 지원한다.
리액티브 타입에 `@RequestBody`를 사용하면
완전한 논블로킹 방식으로 스트리밍한다(클라이언트 to 서버).

- *java*
```java
@PostMapping("/accounts")
public void handle(@RequestBody Mono<Account> account) {
    // ...
}
```
- *kotlin*
```kotlin
@PostMapping("/accounts")
fun handle(@RequestBody accounts: Flow<Account>) {
    // ...
}
```

메세지 리더 설정은
[WebFlux Config](https://godekdls.github.io//Reactive%20Spring/springwebflux2/#111-webflux-config)의
[HTTP message codecs](https://godekdls.github.io//Reactive%20Spring/springwebflux2/#1116-http-message-codecs)
옵션으로 바꿀 수 있다.

`@RequestBody`도
`javax.validation.Valid`나 스프링의 `@Validated` 애노테이션을 붙이면
표준 빈 검증 방식으로 유효성을 확인한다.
유효성 검증에 실패하면 `WebExchangeBindException`이 발생하고
400(BAD_REQUEST)으로 응답한다.
exception은 상세 정보를 확인할 수 있는 `BindingResult`를 가지고 있다.
메소드 인자를 비동기 타입으로 감싸면 연산자로 에러를 처리할 수 있다:

- *java*
```java
@PostMapping("/accounts")
public void handle(@Valid @RequestBody Mono<Account> account) {
    // use one of the onError* operators...
}
```
- *kotlin*
```kotlin
@PostMapping("/accounts")
fun handle(@Valid @RequestBody account: Mono<Account>) {
    // ...
}
```

#### `HttpEntity`

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-ann-httpentity)

`HttpEntity`는 [`@RequestBody`](#requestbody)와 유사하지만
request 헤더와 body를 감싸는 컨테이너 객체다.
다음은 `HttpEntity` 예제다:

- *java*
```java
@PostMapping("/accounts")
public void handle(HttpEntity<Account> entity) {
    // ...
}
```
- *kotlin*
```kotlin
@PostMapping("/accounts")
fun handle(entity: HttpEntity<Account>) {
    // ...
}
```

#### `@ResponseBody`

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-ann-responsebody)

메소드에 `@ResponseBody`를 선언하면
[HttpMessageWriter](#125-codecs)가 리턴한 값을 response body로
직렬화한다.
다음은 사용 예시다:

- *java*
```java
@GetMapping("/accounts/{id}")
@ResponseBody
public Account handle() {
    // ...
}
```
- *kotlin*
```kotlin
@GetMapping("/accounts/{id}")
@ResponseBody
fun handle(): Account {
    // ...
}
```

`@ResponseBody`를 클래스 레벨에 선언하면 컨트롤러 내 모든 메소드에 상속한다.
`@RestController`를 사용해도 효과는 동일하다.
`@RestController`는 단순히 `@Controller`, `@ResponseBody`를 가지고 있는
메타 애노테이션이다.

`@ResponseBody`는 리액티브 타입을 지원하므로
리액터나 RxJava 타입을 리턴하면 비동기로 응답을 만든다.
자세한 내용은 [Streaming](#streaming)과 
[JSON rendering](#jackson-json)을 참고하라.

`@ResponseBody`는 JSON 뷰와 함께 쓸 수 있다.
자세한 내용은 [Jackson JSON](#jackson-json)을 참고하라.

메세지 writer 설정은
[WebFlux Config](https://godekdls.github.io//Reactive%20Spring/springwebflux2/#111-webflux-config)의
[HTTP message codecs](https://godekdls.github.io//Reactive%20Spring/springwebflux2/#1116-http-message-codecs)
옵션으로 바꿀 수 있다.

#### `ResponseEntity`

`ResponseEntity`는 [`@ResponseBody`](#responsebody)와 유사하지만
상태 코드와 헤더를 함께 설정할 수 있다:

- *java*
```java
@GetMapping("/something")
public ResponseEntity<String> handle() {
    String body = ... ;
    String etag = ... ;
    return ResponseEntity.ok().eTag(etag).build(body);
}
```
- *kotlin*
```kotlin
@GetMapping("/something")
fun handle(): ResponseEntity<String> {
    val body: String = ...
    val etag: String = ...
    return ResponseEntity.ok().eTag(etag).build(body)
}
```

웹플럭스에선 single value
[리액티브 타입](https://godekdls.github.io/Reactive%20Spring/reactivelibraries/)으로
`ResponseEntity`를 비동기로 만들 수도 있고,
body를 single, multi-value 리액티브 타입으로 만들어도 된다.

#### Jackson JSON

스프링은 Jackson JSON 라이브러리를 지원한다.

#### JSON Views

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-ann-jackson)

스프링 웹플럭스는 기본적으로 
[Jackson’s Serialization Views](https://www.baeldung.com/jackson-json-view-annotation)를
지원하기 때문에 `Object` 필드 일부만 렌더링할 수 있다.
`@ResponseBody`나 `ResponseEntity`와 함께 사용하려면
아래 예제처럼 Jackson의 `@JsonView` 애노테이션으로
사용할 view 클래스를 명시하면 된다:

- *java*
    ```java
    @RestController
    public class UserController {
    
        @GetMapping("/user")
        @JsonView(User.WithoutPasswordView.class)
        public User getUser() {
            return new User("eric", "7!jd#h23");
        }
    }
    
    public class User {
    
        public interface WithoutPasswordView {};
        public interface WithPasswordView extends WithoutPasswordView {};
    
        private String username;
        private String password;
    
        public User() {
        }
    
        public User(String username, String password) {
            this.username = username;
            this.password = password;
        }
    
        @JsonView(WithoutPasswordView.class)
        public String getUsername() {
            return this.username;
        }
    
        @JsonView(WithPasswordView.class)
        public String getPassword() {
            return this.password;
        }
    }
    ```
- *kotlin*
    ```kotlin
    @RestController
    class UserController {
    
        @GetMapping("/user")
        @JsonView(User.WithoutPasswordView::class)
        fun getUser(): User {
            return User("eric", "7!jd#h23")
        }
    }
    
    class User(
            @JsonView(WithoutPasswordView::class) val username: String,
            @JsonView(WithPasswordView::class) val password: String
    ) {
        interface WithoutPasswordView
        interface WithPasswordView : WithoutPasswordView
    }
    ```

> `@JsonView`는 뷰 클래스 배열도 받지만,
> 컨트롤러 메소드 당 하나만 지정할 수 있다.
> 뷰를 여러개 사용하려면 compiste 인터페이스를 만들어라.

### 1.4.4. Model

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-ann-modelattrib-methods)

`@ModelAttribute` 애노테이션은 다음과 같이 사용할 수 있다:

- `@RequestMapping` 메소드 [인자](#modelattribute)에 선언해서
model을 생성, 접근하고 `WebDataBinder`로 객체에 바인딩한다.
- `@Controller`나 `@ControllerAdvice` 클래스 메소드에 선언해서
다른 `@RequestMapping` 메소드를 실행하기 전 모델을 초기화한다.
- `@RequestMapping` 메소드에서 리턴하는 값을 model attribute로 만든다.

이번 섹션에서는 두번째에 있는 `@ModelAttribute` 메소드를 설명한다.
`@ModelAttribute` 메소드는 컨트롤러 안에 몇 개든지 만들 수 있다.
이 메소드는 같은 컨트롤러에 있는 `@RequestMapping` 메소드를 실행 하기 전
전부 실행된다.
모든 컨트롤러에서 공유하려면 `@ControllerAdvice`에 만들면 된다.
자세한 내용은 [Controller Advice](#147-controller-advice) 섹션을 참고하라.

`@ModelAttribute` 메소드는 여러가지 방법으로 활용할 수 있다.
지원하는 인자는 대부분 `@RequestMapping` 메소드와 동일하다
(`@ModelAttribute` 자체와 reqeust body랑 관련된 것만 빼고).

다음은 `@ModelAttribute` 메소드 사용 예시다:

- *java*
```java
@ModelAttribute
public void populateModel(@RequestParam String number, Model model) {
    model.addAttribute(accountRepository.findAccount(number));
    // add more ...
}
```
- *kotlin*
```kotlin
@ModelAttribute
fun populateModel(@RequestParam number: String, model: Model) {
    model.addAttribute(accountRepository.findAccount(number))
    // add more ...
}
```

attribute 한 개를 추가할 땐 다음과 같이 사용할 수도 있다:

- *java*
```java
@ModelAttribute
public Account addAccount(@RequestParam String number) {
    return accountRepository.findAccount(number);
}
```
- *kotlin*
```kotlin
@ModelAttribute
fun addAccount(@RequestParam number: String): Account {
    return accountRepository.findAccount(number);
}
```

> attribute 이름을 명시하지 않으면 타입별 디폴트 이름을 사용한다
> ([`Conventions`](https://docs.spring.io/spring-framework/docs/5.2.6.RELEASE/javadoc-api/org/springframework/core/Conventions.html)
> javadoc 참고).
> 이름을 지정하려면 attributeName을 인자로 받는 `Model#addAttribute` 메소드를 사용하거나,
> `@ModelAttribute`의 name attribute에 명시하면 된다 (이땐 리턴하는 값을 value로 사용한다).

스프링 웹플럭스는 스프링 MVC와 달리
모델에 리액티브 타입을 저장할 수 있다
(e.g. `Mono<Account>`, `io.reactivex.Single<Account>`).
이런 비동기 model attribute는
`@RequestMapping`을 실행할 때 실제 값을 리졸브하며 (모델도 함께 업데이트한다),
`@ModelAttribute` 인자는 리액티브 타입으로 감싸지 않아도 된다:

- *java*
    ```java
    @ModelAttribute
    public void addAccount(@RequestParam String number) {
        Mono<Account> accountMono = accountRepository.findAccount(number);
        model.addAttribute("account", accountMono);
    }
    
    @PostMapping("/accounts")
    public String handle(@ModelAttribute Account account, BindingResult errors) {
        // ...
    }
    ```
- *kotlin*
    ```kotlin
    import org.springframework.ui.set
    
    @ModelAttribute
    fun addAccount(@RequestParam number: String) {
        val accountMono: Mono<Account> = accountRepository.findAccount(number)
        model["account"] = accountMono
    }
    
    @PostMapping("/accounts")
    fun handle(@ModelAttribute account: Account, errors: BindingResult): String {
        // ...
    }
    ```

만약 model attribute를 리액티브 타입으로 감쌌다면
뷰를 만들기 직전에 리졸브한다(역시 모델도 함께 업데이트한다).

`@ModelAttribute`를 `@RequestMapping` 메소드 위에 선언하면
이 메소드가 리턴하는 값을 model attribute로 해석한다.
HTML 컨트롤러에서는 `String`만 view name으로 사용하고, 나머지는
모두 model attribute로 처리하므로 생략할 수 있다.
다음 예제처럼 `@ModelAttribute`로 attribute 이름을 지정할 수도 있다:

- *java*
```java
@GetMapping("/accounts/{id}")
@ModelAttribute("myAccount")
public Account handle() {
    // ...
    return account;
}
```
- *kotlin*
```kotlin
@GetMapping("/accounts/{id}")
@ModelAttribute("myAccount")
fun handle(): Account {
    // ...
    return account
}
```

### 1.4.5. `DataBinder`

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-ann-initbinder)

`WebDataBinder`는 `@Controller`, `@ControllerAdvice` 클래스에서
`@InitBinder` 메소드로 초기화할 수 있다.
`@InitBinder` 메소드는 다음과 같이 활용할 수 있다:

- 요청 파라미터(form 데이터나 쿼리 파라미터)를 model에 바인딩한다.
- String으로 요청한 값을(파라미터, path variable, 헤더, 쿠키 등)
컨트롤러 메소드 인자 타입으로 변환한다.
- HTML을 렌더링할 때 model 값을 `String`으로 변환한다.

`@InitBinder` 메소드로 컨트롤러별
`java.bean.PropertyEditor`나 스프링 `Converter`, `Formatter`를
등록할 수 있다.
`FormattingConversionService`에서 전역으로 사용하는 
`Converter`, `Formatter`는 [웹플럭스 설정](https://godekdls.github.io/Reactive%20Spring/springwebflux2/#1113-conversion-formatting)으로
등록한다.

`@InitBinder` 메소드가 지원하는 인자는 `@ModelAttribute` (커맨드 객체)만 제외하고
대부분 `@RequestMapping` 메소드와 동일하다.
보통은 `WebDataBinder`를 인자로 받아 컴포넌트를 등록하고 `void`를 리턴한다.
다음은 `@InitBinder` 애노테이션을 사용하는 예제다:

- *java*
```java
@Controller
public class FormController {

    @InitBinder // (1)
    public void initBinder(WebDataBinder binder) {
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
        dateFormat.setLenient(false);
        binder.registerCustomEditor(Date.class, new CustomDateEditor(dateFormat, false));
    }

    // ...
}
```
- *kotlin*
```kotlin
@Controller
class FormController {

    @InitBinder // (1)
    fun initBinder(binder: WebDataBinder) {
        val dateFormat = SimpleDateFormat("yyyy-MM-dd")
        dateFormat.isLenient = false
        binder.registerCustomEditor(Date::class.java, CustomDateEditor(dateFormat, false))
    }

    // ...
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `@InitBinder` 애노테이션을 사용한다.</small>

아니면 같은 방법으로
`FormattingConversionService`에서 사용하는 
`Formatter` 인스턴스를 컨트롤러 전용으로 등록해도 된다:

- *java*
```java
@Controller
public class FormController {

    @InitBinder
    protected void initBinder(WebDataBinder binder) {
        binder.addCustomFormatter(new DateFormatter("yyyy-MM-dd")); // (1) 
    }

    // ...
}
```
- *kotlin*
```kotlin
@Controller
class FormController {

    @InitBinder
    fun initBinder(binder: WebDataBinder) {
        binder.addCustomFormatter(DateFormatter("yyyy-MM-dd")) // (1) 
    }

    // ...
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 커스텀 포맷터를 등록한다 (여기선 `DateFormatter`).</small>

### 1.4.6. Managing Exceptions

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-ann-exceptionhandler)

`@Controller`, [@ControllerAdvice](#147-controller-advice) 클래스 메소드에
`@ExceptionHandler`를 선언하면
컨트롤러에서 발생한 예외를 처리할 수 있다.
다음은 예외를 처리하는 메소드 예시다:

- *java*
```java
@Controller
public class SimpleController {

    // ...

    @ExceptionHandler // (1)
    public ResponseEntity<String> handle(IOException ex) {
        // ...
    }
}
```
- *kotlin*
```kotlin
@Controller
class SimpleController {

    // ...

    @ExceptionHandler // (1)
    fun handle(ex: IOException): ResponseEntity<String> {
        // ...
    }
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `@ExceptionHandler`를 선언한다.</small>

최초에 전파된 exception과(예를 들어 `IOException`)
제일 바깥에서 감싸고 있는 exception(`IOException`를 감싸고 있는 `IllegalStateException`) 
모두 매칭된다.

가급적이면 위 예시처럼 메소드 인자로 원하는 예외 타입을 지정하는 게 좋다.
아니면 애노테이션에 지정해도 된다.
메소드 인자는 최대한 구체적으로 지정하고,
우선순위를 정한 `@ControllerAdvice`에서
루트 exception을 처리해라.
자세한 내용은 [MVC 섹션](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-ann-exceptionhandler)을 참고하라.

> request body나 `@ModelAttribute`와 관려된 인자만 제외하면,
> `@RequestMapping` 메소드가 지원하는 모든 인자와 리턴값을
> `@ExceptionHandler` 메소드에서도 사용할 수 있다.

스프링 웹플럭스에선 `@RequestMapping` 메소드를
실행하는 `HandlerAdapter`가 `@ExceptionHandler` 메소드를 처리한다.
자세한 내용은 [`DispatcherHandler`](#13-dispatcherhandler)를 참고하라.

#### REST API exceptions

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-ann-rest-exceptions)

REST 서비스에선 보통 에러 정보를 response body에 담는다.
에러 정보를 표현하는 방식은 어플리케이션마다 다르기 때문에
스프링 프레임워크가 자동으로 해주지는 않는다.
하지만 `@RestController` 메소드에 `@ExceptionHandler`를 선언하고,
`ResponseEntity`로 상태 코드와 body를 정할 수는 있다.
`@ControllerAdvice`에 만들어 어플리케이션 전체에 적용할 수도 있다.

> 스프링 웹플럭스는 MVC의 `ResponseEntityExceptionHandler`에 상응하는 핸들러가 없다.
> 스프링 웹플럭스에서 발생하는 모든 예외는 `ResponseStatusException`(혹은 상속한 클래스)이기 때문에
> exception마다 HTTP 상태 코드를 지정할 필요가 없다.

### 1.4.7. Controller Advice

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-ann-controller-advice)

`@ExceptionHandler`, `@InitBinder`, `@ModelAttribute` 메소드는
선언한 `@Controller` 클래스(혹은 상속한 클래스)에 적용된다.
모든 컨트롤러에 적용하고 싶다면
`@ControllerAdvice`나 `@RestControllerAdvice`를 선언한
클래스 안에 만들어야 한다.

`@ControllerAdvice`는 `@Component` 애노테이션이 선언돼 있기 때문에
[컴포넌트 스캔](https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#beans-java-instantiating-container-scan)으로
스프링 빈에 등록할 수 있다.
`@RestControllerAdvice`는 `@ControllerAdvice`와 `@ResponseBody`가
둘 다 선언되어 있어서, `@ExceptionHandler` 메소드에서 리턴한 값은
메세지 변환을 통해 response body로 렌더링한다
(view를 만들거나 템플릿을 렌더링하는 대신).

어플리케이션을 기동하면 프레임워크 내부에서 `@ControllerAdvice`를 선언한 스프링 빈을 찾아
`@RequestMapping`과 `@ExceptionHandler` 메소드를 적용한다.
전역에 설정한 `@ExceptionHandler` 메소드(`@ControllerAdvice`에 있는)는
`@Controller` 메소드 다음에 적용한다.
반대로 전역 `@ModelAttribute`, `@InitBinder` 메소드는
`@Controller` 메소드 전에 적용한다.

기본적으로 `@ControllerAdvice` 메소드는 모든 요청에 적용되지만(즉, 모든 컨트롤러에),
다음 예제처럼 애노테이션 attribute로 컨트롤러를 지정할 수 있다:

- *java*
    ```java
    // Target all Controllers annotated with @RestController
    @ControllerAdvice(annotations = RestController.class)
    public class ExampleAdvice1 {}
    
    // Target all Controllers within specific packages
    @ControllerAdvice("org.example.controllers")
    public class ExampleAdvice2 {}
    
    // Target all Controllers assignable to specific classes
    @ControllerAdvice(assignableTypes = {ControllerInterface.class, AbstractController.class})
    public class ExampleAdvice3 {}
    ```
- *kotlin*
    ```kotlin
    // Target all Controllers annotated with @RestController
    @ControllerAdvice(annotations = [RestController::class])
    public class ExampleAdvice1 {}
    
    // Target all Controllers within specific packages
    @ControllerAdvice("org.example.controllers")
    public class ExampleAdvice2 {}
    
    // Target all Controllers assignable to specific classes
    @ControllerAdvice(assignableTypes = [ControllerInterface::class, AbstractController::class])
    public class ExampleAdvice3 {}
    ```

이 예제처럼 컨트롤러를 지정하면 런타임에 비교하기때문에,
과도한 사용은 성능에 좋지 않다.
자세한 내용은 [`@ControllerAdvice`](https://docs.spring.io/spring-framework/docs/5.2.6.RELEASE/javadoc-api/org/springframework/web/bind/annotation/ControllerAdvice.html)
javadoc을 참고하라.

> 전체 목차는 [여기](https://godekdls.github.io/Reactive%20Spring/contents/)에 있습니다.
