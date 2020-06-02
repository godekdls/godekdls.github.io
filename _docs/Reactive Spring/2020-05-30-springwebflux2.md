---
title: Spring WebFlux (2)
category: Reactive Spring
order: 3
permalink: /Reactive%20Spring/springwebflux2/
---

> [리액티브 스프링 공식 reference](https://docs.spring.io/spring/docs/current/spring-framework-reference/web-reactive.html#webflux)를 한글로 번역한 문서입니다.
>
> 전체 목차는 [여기](https://godekdls.github.io/Reactive%20Spring/contents/)에 있습니다.

### 목차

- [1.5. Functional Endpoints](#15-functional-endpoints)
  + [1.5.1. Overview](#151-overview)
  + [1.5.2. HandlerFunction](#152-handlerfunction)
    * [ServerRequest](#serverrequest)
    * [ServerResponse](#serverresponse)
    * [Handler Classes](#handler-classes)
    * [Validation](#validation)
  + [1.5.3. RouterFunction](#153-routerfunction)
    * [Predicates](#predicates)
    * [Routes](#routes)
    * [Nested Routes](#nested-routes)
  + [1.5.4. Running a Server](#154-running-a-server)
  + [1.5.5. Filtering Handler Functions](#155-filtering-handler-functions)
- [1.6. URI Links](#16-uri-links)
  + [1.6.1. UriComponents](#161-uricomponents)
  + [1.6.2. UriBuilder](#162-uribuilder)
  + [1.6.3. URI Encoding](#163-uri-encoding)
- [1.7. CORS](#17-cors)
  + [1.7.1. Introduction](#171-introduction)
  + [1.7.2. Processing](#172-processing)
  + [1.7.3. @CrossOrigin](#173-crossorigin)
  + [1.7.4. Global Configuration](#174-global-configuration)
  + [1.7.5. CORS WebFilter](#175-cors-webfilter)
- [1.8. Web Security](#18-web-security)
- [1.9. View Technologies](#19-view-technologies)
  + [1.9.1. Thymeleaf](#191-thymeleaf)
  + [1.9.2. FreeMarker](#192-freemarker)
    * [View Configuration](#view-configuration)
    * [FreeMarker Configuration](#freemarker-configuration)
    * [Form Handling](#form-handling)
  + [1.9.3. Script Views](#193-script-views)
    * [Requirements](#requirements)
    * [Script Templates](#script-templates)
  + [1.9.4. JSON and XML](#194-json-and-xml)
- [1.10. HTTP Caching](#110-http-caching)
  + [1.10.1. CacheControl](#1101-cachecontrol)
  + [1.10.2. Controllers](#1102-controllers)
  + [1.10.3. Static Resources](#1103-static-resources)
- [1.11. WebFlux Config](#111-webflux-config)
  + [1.11.1. Enabling WebFlux Config](#1111-enabling-webflux-config)
  + [1.11.2. WebFlux config API](#1112-webflux-config-api)
  + [1.11.3. Conversion, formatting](#1113-conversion-formatting)
  + [1.11.4. Validation](#1114-validation)
  + [1.11.5. Content Type Resolvers](#1115-content-type-resolvers)
  + [1.11.6. HTTP message codecs](#1116-http-message-codecs)
  + [1.11.7. View Resolvers](#1117-view-resolvers)
  + [1.11.8. Static Resources](#1118-static-resources)
  + [1.11.9. Path Matching](#1119-path-matching)
  + [1.11.10. Advanced Configuration Mode](#11110-advanced-configuration-mode)
- [1.12. HTTP/2](#112-http2)

---

## 1.5. Functional Endpoints

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#webmvc-fn)

스프링 웹플럭스는 경량화된 함수형 프로그래밍 모델을 지원한다.
WebFlux.fn이라고도 하는 이 모델은,
함수로 요청을 라우팅하고 핸들링하기 때문에 불변성(Immutablility)을 보장한다.
함수형 모델과 애노테이션 모델 중 하나를 선택하면 되는데,
둘 다 [리액티브 코어](https://godekdls.github.io/Reactive%20Spring/springwebflux/#12-reactive-core)
기반이다.

### 1.5.1. Overview

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#webmvc-fn-overview)

WebFlux.fn에선 `HandlerFunction`이 HTTP 요청을 처리한다.
`HandlerFunction`은 `ServerRequest`를 받아
비동기 `ServerResponse`(i.e. `Mono<ServerResponse>`)를 리턴하는 함수다.
요청, 응답 객체 모두 불변(immutable)이기 때문에
JDK 8 방식으로 HTTP 요청, 응답에 접근할 수 있다.
`HandlerFunction` 역할은 애노테이션 프로그래밍 모델로 치면
`@RequestMapping` 메소드가 하던 일과 동일하다.

요청은 `RouterFunction`이 핸들러 펑션에 라우팅한다:
`RouterFunction`은 `ServerRequest`를 받아 
비동기 `HandlerFunction`(i.e. `Mono<HandlerFunction>`)을 리턴하는 함수다.
매칭되는 라우터 펑션이 있으면 핸들러 펑션을 리턴하고 그 외는 비어있는 Mono를 리턴한다.
`RouterFunction`이 하는 일은 `@RequestMapping` 애노테이션과 동일하지만,
라우터 펑션은 데이터 뿐 아니라 행동까지 제공한다는 점이 다르다.

라우터를 만들 때는 아래 예제처럼 `RouterFunctions.route()`가 제공하는
빌더를 사용할 수 있다:

- *java*
    ```java
    import static org.springframework.http.MediaType.APPLICATION_JSON;
    import static org.springframework.web.reactive.function.server.RequestPredicates.*;
    import static org.springframework.web.reactive.function.server.RouterFunctions.route;
    
    PersonRepository repository = ...
    PersonHandler handler = new PersonHandler(repository);
    
    RouterFunction<ServerResponse> route = route()
        .GET("/person/{id}", accept(APPLICATION_JSON), handler::getPerson)
        .GET("/person", accept(APPLICATION_JSON), handler::listPeople)
        .POST("/person", handler::createPerson)
        .build();
    
    
    public class PersonHandler {
    
        // ...
    
        public Mono<ServerResponse> listPeople(ServerRequest request) {
            // ...
        }
    
        public Mono<ServerResponse> createPerson(ServerRequest request) {
            // ...
        }
    
        public Mono<ServerResponse> getPerson(ServerRequest request) {
            // ...
        }
    }
    ```
- *kotlin*
    ```kotlin
    val repository: PersonRepository = ...
    val handler = PersonHandler(repository)
    
    val route = coRouter { // (1)
        accept(APPLICATION_JSON).nest {
            GET("/person/{id}", handler::getPerson)
            GET("/person", handler::listPeople)
        }
        POST("/person", handler::createPerson)
    }
    
    
    class PersonHandler(private val repository: PersonRepository) {
    
        // ...
    
        suspend fun listPeople(request: ServerRequest): ServerResponse {
            // ...
        }
    
        suspend fun createPerson(request: ServerRequest): ServerResponse {
            // ...
        }
    
        suspend fun getPerson(request: ServerRequest): ServerResponse {
            // ...
        }
    }
    ```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 코루틴 라우터 DSL로 라우터를 만든다. 리액티브 방식은 `router { }`를 사용한다.</small>

`RouterFunction`을 실행하는 방법 중 하나는
`HttpHandler`로 변환해
내장된 [서버 어댑터](https://godekdls.github.io/Reactive%20Spring/springwebflux/#121-httphandler)에
등록하는 것이다 :

- `RouterFunctions.toHttpHandler(RouterFunction)`
- `RouterFunctions.toHttpHandler(RouterFunction, HandlerStrategies)`

대부분은 웹플럭스 자바 설정으로 어플리케이션을 실행한다.
[Running a Server](#154-running-a-server)를 참고하라.

### 1.5.2. HandlerFunction

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#webmvc-fn-handler-functions)

`ServerRequest`와 `ServerResponse`는 자바 8 방식으로
HTTP 요청과 응답에 접근할 수 있는 불변(immutable) 인터페이스다.
요청, 응답 body 모두 [리액티브 스트림](https://www.reactive-streams.org/)
back pressure로 처리한다.
request body는 리액터 `Flux`나 `Mono`로 표현한다.
response body는 `Flux`와 `Mono`를 포함한 어떤 리액티브 스트림
`Publisher`든 상관 없다.
자세한 정보는 [Reactive Libraries](https://godekdls.github.io/Reactive%20Spring/reactivelibraries/)를 참고하라.

#### `ServerRequest`

`ServerRequest`로 HTTP 메소드, URI, 헤더, 쿼리 파라미터에 접근할 수 있으며,
body를 추출할 수 있는 메소드를 제공한다.

다음은 request body를 `Mono<String>`으로 추출하는 예제다:

- *java*
```java
Mono<String> string = request.bodyToMono(String.class);
```
- *kotlin*
```kotlin
val string = request.awaitBody<String>()
```

다음 예제는 body를 `Flux<Person>`(코틀린은 `Flow<Person>`)으로 추출한다.
`Person` 객체는 JSON이나 XML같은 직렬화된 데이터로 디코딩한다.

- *java*
```java
Flux<Person> people = request.bodyToFlux(Person.class);
```
- *kotlin*
```kotlin
val people = request.bodyToFlow<Person>()
```

위 예제에서 사용한 메소드는 함수형 인터페이스 `BodyExtractor`를 받는
`ServerRequest.body(BodyExtractor)` 메소드의 축약 버전이다.
`BodyExtractors` 유틸리티 클래스에 있는 인터페이스를 활용해도 된다.
예를 들어 앞의 예제는 다음과 같이 작성할 수도 있다:

- *java*
```java
Mono<String> string = request.body(BodyExtractors.toMono(String.class));
Flux<Person> people = request.body(BodyExtractors.toFlux(Person.class));
```
- *kotlin*
```kotlin
val string = request.body(BodyExtractors.toMono(String::class.java)).awaitFirst()
val people = request.body(BodyExtractors.toFlux(Person::class.java)).asFlow()
```

다음 예제는 form 데이터를 접근하는 방법을 보여준다:

- *java*
```java
Mono<MultiValueMap<String, String> map = request.formData();
```
- *kotlin*
```kotlin
val map = request.awaitFormData()
```

다음은 multipart 데이터를 map으로 가져오는 예제다:

- *java*
```java
Mono<MultiValueMap<String, Part> map = request.multipartData();
```
- *kotlin*
```kotlin
val map = request.awaitMultipartData()
```

다음 예제는 multiparts를 스트리밍 방식으로 한 번에 하나씩 가져온다:

- *java*
```java
Flux<Part> parts = request.body(BodyExtractors.toParts());
```
- *kotlin*
```kotlin
val parts = request.body(BodyExtractors.toParts()).asFlow()
```

#### `ServerResponse`

HTTP 응답은 `ServerResponse`로 접근할 수 있으며,
이 인터페이스는 불변이기 때문에(immutable) `build` 메소드로 생성한다.
빌더로 헤더를 추가하거나, 상태 코드, body를 설정할 수 있다.
다음은 JSON 컨텐츠로 200 (OK) 응답을 만드는 예제다:

- *java*
```java
Mono<Person> person = ...
ServerResponse.ok().contentType(MediaType.APPLICATION_JSON).body(person, Person.class);
```
- *kotlin*
```kotlin
val person: Person = ...
ServerResponse.ok().contentType(MediaType.APPLICATION_JSON).bodyValue(person)
```

다음 예제는 body 없이 Location 헤더로만
201 (CREATED) 응답을 만든다:

- *java*
```java
URI location = ...
ServerResponse.created(location).build();
```
- *kotlin*
```kotlin
val location: URI = ...
ServerResponse.created(location).build()
```

hint 파라미터를 넘기면
사용하는 코덱에 따라 body 직렬화/역직렬화 방식을 커스텀할 수 있다.
예를 들어 [Jackson JSON view](https://www.baeldung.com/jackson-json-view-annotation)를
지정할 수 있다:

- *java*
```java
ServerResponse.ok().hint(Jackson2CodecSupport.JSON_VIEW_HINT, MyJacksonView.class).body(...);
```
- *kotlin*
```kotlin
ServerResponse.ok().hint(Jackson2CodecSupport.JSON_VIEW_HINT, MyJacksonView::class.java).body(...)
```

#### Handler Classes

핸들러 펑션은 다음처럼 람다로 만들수 있다:

- *java*
```java
HandlerFunction<ServerResponse> helloWorld =
  request -> ServerResponse.ok().bodyValue("Hello World");
```
- *kotlin*
```kotlin
val helloWorld = HandlerFunction<ServerResponse> { ServerResponse.ok().bodyValue("Hello World") }
```

편리한 방식이긴 하지만, 펑션을 여러개 사용해야 한다면
인라인 람다로 만들기는 부담스럽다.
이럴 때는 핸들러 클래스로 관련 핸들러 펑션을 묶을 수 있다.
핸들러 클래스는 애노테이션 기반 어플리케이션의 `@Controller`와 비슷하다.
예를 들어 다음 클래스는 리액티브 `Person` 레포지토리와 관련된 요청을 처리한다:

- *java*
    ```java
    import static org.springframework.http.MediaType.APPLICATION_JSON;
    import static org.springframework.web.reactive.function.server.ServerResponse.ok;
    
    public class PersonHandler {
    
        private final PersonRepository repository;
    
        public PersonHandler(PersonRepository repository) {
            this.repository = repository;
        }
    
        public Mono<ServerResponse> listPeople(ServerRequest request) { // (1)
            Flux<Person> people = repository.allPeople();
            return ok().contentType(APPLICATION_JSON).body(people, Person.class);
        }
    
        public Mono<ServerResponse> createPerson(ServerRequest request) { // (2)
            Mono<Person> person = request.bodyToMono(Person.class);
            return ok().build(repository.savePerson(person));
        }
    
        public Mono<ServerResponse> getPerson(ServerRequest request) { // (3)
            int personId = Integer.valueOf(request.pathVariable("id"));
            return repository.getPerson(personId)
                .flatMap(person -> ok().contentType(APPLICATION_JSON).bodyValue(person))
                .switchIfEmpty(ServerResponse.notFound().build());
        }
    }
    ```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `listPeople`은 레포지토리에 있는 모든 `Person` 객체를 JSON으로 반환하는 핸들러 펑션이다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> `createPerson`은 request body에 있는 `Person`을 저장하는 핸들러 펑션이다.<br>
`PersonRepository.savePerson(Person)`은 `Mono<Void>`를 리턴한다는 점에 주의해라. 비어 있는 `Mono`는 요청 데이터를 읽어 저장하고 나면 완료됐다는 신호를 보낸다. 따라서 이 신호를 받았을 때(즉, `Person`이 저장됐을 때) 응답을 보내기 위해 `build(Publisher<Void>)`를 사용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> `getPerson`은 path variable에 있는 `id`로 식별한 person 객체 하나를 리턴하는 핸들러 펑션이다.<br>
레포지토리에서 `Person`을 찾으면 JSON 응답을 만든다. 찾지 못했다면 `switchIfEmpty(Mono<T>)`를 실행해 404 Not Found로 응답한다.</small>
- *kotlin*
    ```kotlin
    class PersonHandler(private val repository: PersonRepository) {
    
        suspend fun listPeople(request: ServerRequest): ServerResponse { // (1) 
            val people: Flow<Person> = repository.allPeople()
            return ok().contentType(APPLICATION_JSON).bodyAndAwait(people);
        }
    
        suspend fun createPerson(request: ServerRequest): ServerResponse { // (2) 
            val person = request.awaitBody<Person>()
            repository.savePerson(person)
            return ok().buildAndAwait()
        }
    
        suspend fun getPerson(request: ServerRequest): ServerResponse { // (3) 
            val personId = request.pathVariable("id").toInt()
            return repository.getPerson(personId)?.let { ok().contentType(APPLICATION_JSON).bodyValueAndAwait(it) }
                    ?: ServerResponse.notFound().buildAndAwait()
    
        }
    }
    ```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `listPeople`은 레포지토리에 있는 모든 `Person` 객체를 JSON으로 반환하는 핸들러 펑션이다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> `createPerson`은 request body에 있는 `Person`을 저장하는 핸들러 펑션이다.<br>`PersonRepository.savePerson(Person)`은 리턴 타입이 없는 suspend 함수라는 점에 주의해라.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> `getPerson`은 path variable에 있는 `id`로 식별한 person 객체 하나를 리턴하는 핸들러 펑션이다.<br>
레포지토리에서 `Person`을 찾으면 JSON 응답을 만든다. 찾지 못했다면 404 Not Found 응답을 리턴한다.</small>

#### Validation

함수형 엔드포인트는 스프링 [validation facilities](https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#validation)를
사용해서 request body를 검증할 수 있다.
다음 예제는 커스텀 스프링 Validator 구현체로 `person`을 검증한다:

- *java*
```java
public class PersonHandler {

    private final Validator validator = new PersonValidator(); // (1) 

    // ...

    public Mono<ServerResponse> createPerson(ServerRequest request) {
        Mono<Person> person = request.bodyToMono(Person.class).doOnNext(this::validate); // (2) 
        return ok().build(repository.savePerson(person));
    }

    private void validate(Person person) {
        Errors errors = new BeanPropertyBindingResult(person, "person");
        validator.validate(person, errors);
        if (errors.hasErrors()) {
            throw new ServerWebInputException(errors.toString()); // (3) 
        }
    }
}
```
- *kotlin*
```kotlin
class PersonHandler(private val repository: PersonRepository) {

    private val validator = PersonValidator() // (1) 

    // ...

    suspend fun createPerson(request: ServerRequest): ServerResponse {
        val person = request.awaitBody<Person>()
        validate(person) // (2)
        repository.savePerson(person)
        return ok().buildAndAwait()
    }

    private fun validate(person: Person) {
        val errors: Errors = BeanPropertyBindingResult(person, "person");
        validator.validate(person, errors);
        if (errors.hasErrors()) {
            throw ServerWebInputException(errors.toString()) // (3) 
        }
    }
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `Validator` 인스턴스를 생성한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 검증 로직을 실행한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> 400으로 응답하는 exception을 발생시킨다.</small>

핸들러에  `LocalValidatorFactoryBean` 기반 글로벌 `Validator`
인스턴스를 주입하면 표준 빈 검증 API(JSR-303)로 유효성을 확인한다.
[Spring Validation](https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#validation-beanvalidation)을
참고하라.

### 1.5.3. RouterFunction

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#webmvc-fn-router-functions)

라우터 펑션은 요청을 그에 맞는 `HandlerFunction`으로 라우팅한다.
라우터 펑션을 직접 만들기보단,
보통 `RouterFunctions` 유틸리티 클래스를 사용한다.
`RouterFunctions.route()`가 리턴하는 빌더를 사용하거나,
`RouterFunctions.route(RequestPredicate, HandlerFunction)`으로
직접 라우터를 만들수 있다.

`route()` 빌더를 사용하면 static 메소드를 직접 임포트하지 않아도 된다.
예를 들어 빌더에는 GET 요청을 매핑할 수 있는
`GET(String, HandlerFunction)` 메소드와,
POST 요청을 매핑하는 `POST(String, HandlerFunction)` 메소드가 있다.

빌더는 HTTP 메소드 외에
다른 조건으로 요청을 매핑할 수는 인터페이스도 제공한다.
각 HTTP 메소드는 `RequestPredicate` 파라미터를 받는
메소드를 오버로딩하고 있기 때문에 다른 조건을 추가할 수 있다.

#### Predicates

`RequestPredicate`를 직접 만들어도 되지만, 
요청 path, HTTP 메소드, 컨텐츠 타입 등 자주 사용하는
구현체는 `RequestPredicates` 유틸리티 클래스에 준비돼 있다.
다음은 유틸리티 클래스로 `Accept` 헤더 조건을 추가하는 예제다:

- *java*
```java
RouterFunction<ServerResponse> route = RouterFunctions.route()
    .GET("/hello-world", accept(MediaType.TEXT_PLAIN),
        request -> ServerResponse.ok().bodyValue("Hello World")).build();
```
- *kotlin*
```kotlin
val route = coRouter {
    GET("/hello-world", accept(TEXT_PLAIN)) {
        ServerResponse.ok().bodyValueAndAwait("Hello World")
    }
}
```

여러 조건을 함께 사용할 수도 있다:

- `RequestPredicate.and(RequestPredicate)` — 둘 다 만족해야 한다.
- `RequestPredicate.or(RequestPredicate)` — 둘 중 하나만 만족하면 된다.

`RequestPredicates`가 제공하는 구현체도 이 조합으로 만든 것이 많다.
예를 들어 `RequestPredicates.GET(String)`은
`RequestPredicates.method(HttpMethod)`와
`RequestPredicates.path(String)` 조합이다.
위에 있는 예제도 빌더 내부에서 `RequestPredicates.GET`을

#### Routes

라우터 펑션은 정해진 순서대로 실행한다:
첫 번째 조건과 일치하지 않으면 두 번째를 실행하는 식이다.
따라서 구체적인 조건을 앞에 선언해야 한다.
애노테이션 프로그래밍 모델에선 자동으로 가장 구체적인 컨트롤러 메소드를
실행하지만, 함수형 모델에선 그렇지 않다 점에 주의해라.

`build()`를 호출하면 빌더에 정의한 모든 라우터 펑션을
`RouterFunction` 한 개로 합친다.
다음 방법으로도 여러 라우터 펑션을 조합할 수 있다:

- `RouterFunctions.route()` 빌더의 `add(RouterFunction)`
- `RouterFunction.and(RouterFunction)`
- `RouterFunction.andRoute(RequestPredicate, HandlerFunction)` — 
`RouterFunctions.route()`를 `RouterFunction.and()`로 감싸고 있는 축약 버전

다음 예제는 라우터 펑션을 4개 사용한다:

- *java*
    ```java
    import static org.springframework.http.MediaType.APPLICATION_JSON;
    import static org.springframework.web.reactive.function.server.RequestPredicates.*;
    
    PersonRepository repository = ...
    PersonHandler handler = new PersonHandler(repository);
    
    RouterFunction<ServerResponse> otherRoute = ...
    
    RouterFunction<ServerResponse> route = route()
        .GET("/person/{id}", accept(APPLICATION_JSON), handler::getPerson) // (1) 
        .GET("/person", accept(APPLICATION_JSON), handler::listPeople) // (2)
        .POST("/person", handler::createPerson) // (3)
        .add(otherRoute) // (4)
        .build();
    ```
- *kotlin*
    ```kotlin
    import org.springframework.http.MediaType.APPLICATION_JSON
    
    val repository: PersonRepository = ...
    val handler = PersonHandler(repository);
    
    val otherRoute: RouterFunction<ServerResponse> = coRouter {  }
    
    val route = coRouter {
        GET("/person/{id}", accept(APPLICATION_JSON), handler::getPerson) // (1) 
        GET("/person", accept(APPLICATION_JSON), handler::listPeople) // (2)
        POST("/person", handler::createPerson) // (3)
    }.and(otherRoute) // (4) 
    ```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `Accept` 헤더가 JSON인 `GET /person/{id}`는 `PersonHandler.getPerson`으로 라우팅한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> `Accept` 헤더가 JSON인 `GET /person`은 `PersonHandler.listPeople`로 라우팅한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> `POST /person`은 다른 조건 없이 `PersonHandler.createPerson`로 라우팅한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> 마지막으로 나머지 요청을 처리할 `otherRoute` 펑션을 route에 추가한다.</small><br>

#### Nested Routes

path가 같으면 대부분 같은 조건을 사용하므로, 라우터 펑션을 그룹핑하는 경우가 많다.
앞의 예제는 라우터 펑션 세 개가 `/person`을 path 조건으로 사용했다.
애노테이션을 사용했다면 클래스 레벨에 `@RequestMapping`을
선언해 중복 코드를 줄였을 거다.
WebFlux.fn에선 빌더의 `path` 메소드로 path 조건을 공유한다.
예를 들어 위 코드는 아래 예제처럼 라우트 펑션을 한번 감싸 개선할 수 있다:

- *java*
```java
RouterFunction<ServerResponse> route = route()
    .path("/person", builder -> builder // (1)
        .GET("/{id}", accept(APPLICATION_JSON), handler::getPerson)
        .GET("", accept(APPLICATION_JSON), handler::listPeople)
        .POST("/person", handler::createPerson))
    .build();
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> `path`의 두번째 파라미터는 라우터 빌더를 받는 컨슈머 인터페이스다.</small>
- *kotlin*
```kotlin
val route = coRouter {
    "/person".nest {
        GET("/{id}", accept(APPLICATION_JSON), handler::getPerson)
        GET("", accept(APPLICATION_JSON), handler::listPeople)
        POST("/person", handler::createPerson)
    }
}
```

path가 가장 흔하긴 하지만,
빌더의 `nest` 메소드는 다른 조건도 감쌀 수 있다.
위 코드는 여전히 `Accept` 헤더가 중복이다.
`nest` 메소드를 함께 사용하면 코드를 한 층 더 개선할 수 있다:

- *java*
```java
RouterFunction<ServerResponse> route = route()
    .path("/person", b1 -> b1
        .nest(accept(APPLICATION_JSON), b2 -> b2
            .GET("/{id}", handler::getPerson)
            .GET("", handler::listPeople))
        .POST("/person", handler::createPerson))
    .build();
```
- *kotlin*
```kotlin
val route = coRouter {
    "/person".nest {
        accept(APPLICATION_JSON).nest {
            GET("/{id}", handler::getPerson)
            GET("", handler::listPeople)
            POST("/person", handler::createPerson)
        }
    }
}
```

### 1.5.4. Running a Server

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#webmvc-fn-running)

HTTP 서버에선 어떻게 라우터 펑션을 실행할까?
간단하게는 다음과 같이 라우터 펑션을 `HttpHandler`로 변환할 수 있다:

- `RouterFunctions.toHttpHandler(RouterFunction)`
- `RouterFunctions.toHttpHandler(RouterFunction, HandlerStrategies)`

리턴받은 `HttpHandler`를 서버 가이드에 따라 
[서버 어댑터](https://godekdls.github.io/Reactive%20Spring/springwebflux/#121-httphandler)와
함께 사용하면 된다.

스프링 부트에서도 사용하는 좀 더 일반적인 옵션은,
[WebFlux Config](#111-webflux-config)로
컴포넌트를 스프링 빈으로 정의하고,
[`DispatcherHandler`](https://godekdls.github.io/Reactive%20Spring/springwebflux/#13-dispatcherhandler)와
함께 실행하는 것이다.
프레임워크는 다음과 같은 컴포넌트로 함수형 엔드포인트를 지원하는데,
웹플럭스 설정을 사용하면 이를 모두 스프링 빈으로 정의한다:

- `RouterFunctionMapping`: 스프링 설정에서
`RouterFunction<?>`을 찾아 `RouterFunction.andOther`로
연결하고, 최종 구성한 `RouterFunction`으로 요청을 라우팅한다.
- `HandlerFunctionAdapter`: 요청에 매핑된 `HandlerFunction`을
`DispatcherHandler`가 실행하게 도와주는 간단한 어댑터.
- `ServerResponseResultHandler`:
`ServerResponse`의 `writeTo` 메소드로
`HandlerFunction` 결과를 처리한다.

위 컴포넌트가 함수형 엔드포인트를 `DispatcherHandler`의
요청 처리 패턴에 맞춰주기 때문에,
애노테이션 컨트롤러와 함께 사용할 수도 있다.
스프링 부트 웹플럭스 스타터도 이 방법으로 함수형 엔드포인트를 지원한다.

다음은 웹플럭스 자바 설정을 사용한 예시다
(실행 방법은 [DispatcherHandler](https://godekdls.github.io/Reactive%20Spring/springwebflux/#13-dispatcherhandler)를
참고하라):

- *java*
    ````java
    @Configuration
    @EnableWebFlux
    public class WebConfig implements WebFluxConfigurer {
    
        @Bean
        public RouterFunction<?> routerFunctionA() {
            // ...
        }
    
        @Bean
        public RouterFunction<?> routerFunctionB() {
            // ...
        }
    
        // ...
    
        @Override
        public void configureHttpMessageCodecs(ServerCodecConfigurer configurer) {
            // configure message conversion...
        }
    
        @Override
        public void addCorsMappings(CorsRegistry registry) {
            // configure CORS...
        }
    
        @Override
        public void configureViewResolvers(ViewResolverRegistry registry) {
            // configure view resolution for HTML rendering...
        }
    }
    ````
- *kotlin*
    ```kotlin
    @Configuration
    @EnableWebFlux
    class WebConfig : WebFluxConfigurer {
    
        @Bean
        fun routerFunctionA(): RouterFunction<*> {
            // ...
        }
    
        @Bean
        fun routerFunctionB(): RouterFunction<*> {
            // ...
        }
    
        // ...
    
        override fun configureHttpMessageCodecs(configurer: ServerCodecConfigurer) {
            // configure message conversion...
        }
    
        override fun addCorsMappings(registry: CorsRegistry) {
            // configure CORS...
        }
    
        override fun configureViewResolvers(registry: ViewResolverRegistry) {
            // configure view resolution for HTML rendering...
        }
    }
    ```

### 1.5.5. Filtering Handler Functions

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#webmvc-fn-handler-filter-function)

핸들러 펑션에 필터를 적용할 땐
라우터 빌더의 `before`, `after`, `filter` 메소드를 사용한다.
이 기능을 애노테이션 모델로 구현한다면 
`@ControllerAdvice`나 `ServletFilter`를 사용했을 것이다.
필터는 빌더의 모든 라우터 펑션에 적용된다.
이 말은 필터를 감싸져 있는 라우터에서 정의하면, 상위 레벨에는 적용되지 않는다는 뜻이다.
예시로 다음 코드를 보라:

- *java*
```java
RouterFunction<ServerResponse> route = route()
    .path("/person", b1 -> b1
        .nest(accept(APPLICATION_JSON), b2 -> b2
            .GET("/{id}", handler::getPerson)
            .GET("", handler::listPeople)
            .before(request -> ServerRequest.from(request) // (1) 
                .header("X-RequestHeader", "Value")
                .build()))
        .POST("/person", handler::createPerson))
    .after((request, response) -> logResponse(response)) // (2) 
    .build();
```
- *kotlin*
```kotlin
val route = router {
    "/person".nest {
        GET("/{id}", handler::getPerson)
        GET("", handler::listPeople)
        before { // (1)
            ServerRequest.from(it)
                    .header("X-RequestHeader", "Value").build()
        }
        POST("/person", handler::createPerson)
        after { _, response -> // (2)
            logResponse(response)
        }
    }
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 커스텀 헤더를 추가하는 `before` 필터는 두 GET 라우터에만 적용된다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 응답을 로깅하는 `after` 필터는 감싸진 라우터를 포함한 모든 라우터에 적용된다.</small>

`filter` 메소드는 `HandlerFilterFunction`을 인자로 받는다.
이 인터페이스는 `ServerRequest`, `HandlerFunction`을 받아
`ServerResponse`를 리턴하는 함수다.
핸들러 펑션 파라미터는 체인에 있는 다음 컴포넌트다.
보통 이 컴포넌트는 라우팅할 핸들러지만,
필터가 여러 개라면 필터일 수도 있다.

이제 path를 보고 요청을 허가할지 말지 결정하는
`SecurityManager`가 있다고 가정하고,
간단한 보안 필터를 라우터에 적용해 보자:

- *java*
    ```java
    SecurityManager securityManager = ...
    
    RouterFunction<ServerResponse> route = route()
        .path("/person", b1 -> b1
            .nest(accept(APPLICATION_JSON), b2 -> b2
                .GET("/{id}", handler::getPerson)
                .GET("", handler::listPeople))
            .POST("/person", handler::createPerson))
        .filter((request, next) -> {
            if (securityManager.allowAccessTo(request.path())) {
                return next.handle(request);
            }
            else {
                return ServerResponse.status(UNAUTHORIZED).build();
            }
        })
        .build();
    ```
- *kotlin*
    ```kotlin
    val securityManager: SecurityManager = ...
    
    val route = router {
            ("/person" and accept(APPLICATION_JSON)).nest {
                GET("/{id}", handler::getPerson)
                GET("", handler::listPeople)
                POST("/person", handler::createPerson)
                filter { request, next ->
                    if (securityManager.allowAccessTo(request.path())) {
                        next(request)
                    }
                    else {
                        status(UNAUTHORIZED).build();
                    }
                }
            }
        }
    ```

위 예제를 보면 `next.handle(ServerRequest)` 호출은 선택이라는 점을 알 수 있다.
여기선 접근을 허가할 때만 실행했다.

빌더의 `filter` 메소드 대신
`RouterFunction.filter(HandlerFilterFunction)`로
필터를 추가하는 방법도 있다.

> 함수형 엔드포인트에서 CORS는
> [`CorsWebFilter`](#175-cors-webfilter)로 지원한다.

---

## 1.6. URI Links

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-uri-building)

이번 섹션에선 스프링 프레임워크에서 URI를 만들 때 사용할 수 있는
여러 가지 옵션을 다룬다.

### 1.6.1. UriComponents

`UriComponentsBuilder`를 사용하면
URI 템플릿과 변수로 쉽게 URI를 만들 수 있다:

- *java*
    ```java
    UriComponents uriComponents = UriComponentsBuilder
            .fromUriString("https://example.com/hotels/{hotel}") // (1)  
            .queryParam("q", "{q}") // (2)
            .encode() // (3)
            .build(); // (4)
    
    URI uri = uriComponents.expand("Westin", "123").toUri(); // (5)  
    ```
- *kotlin*
    ```kotlin
    val uriComponents = UriComponentsBuilder
            .fromUriString("https://example.com/hotels/{hotel}") // (1)  
            .queryParam("q", "{q}") // (2)
            .encode() // (3)
            .build() // (4)
    
    val uri = uriComponents.expand("Westin", "123").toUri() // (5)
    ```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> URI 템플릿을 사용하는 static 팩토리 메소드.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> URI 컴포넌트를 추가하거나 변경한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(3)</span> URI 템플릿과 변수를 인코딩하도록 요청한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(4)</span> `UriComponents`를 빌드한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(5)</span> 템플릿 변수를 치환하고 `URI`를 가져 온다.</small><br>

`buildAndExpand` 메소드로 한 번에 URI를 가져올 수도 있다:

- *java*
```java
URI uri = UriComponentsBuilder
        .fromUriString("https://example.com/hotels/{hotel}")
        .queryParam("q", "{q}")
        .encode()
        .buildAndExpand("Westin", "123")
        .toUri();
```
- *kotlin*
```kotlin
val uri = UriComponentsBuilder
        .fromUriString("https://example.com/hotels/{hotel}")
        .queryParam("q", "{q}")
        .encode()
        .buildAndExpand("Westin", "123")
        .toUri()
```

아래 처럼 바로 URI를 만들면 코드를 더 줄일 수 있다:

- *java*
```java
URI uri = UriComponentsBuilder
        .fromUriString("https://example.com/hotels/{hotel}")
        .queryParam("q", "{q}")
        .build("Westin", "123");
```
- *kotlin*
```kotlin
val uri = UriComponentsBuilder
        .fromUriString("https://example.com/hotels/{hotel}")
        .queryParam("q", "{q}")
        .build("Westin", "123")
```

URI 전체를 템플릿으로 쓰면 코드를 한 번 더 줄일 수 있다:

- *java*
```java
URI uri = UriComponentsBuilder
        .fromUriString("https://example.com/hotels/{hotel}?q={q}")
        .build("Westin", "123");
```
- *kotlin*
```kotlin
val uri = UriComponentsBuilder
        .fromUriString("https://example.com/hotels/{hotel}?q={q}")
        .build("Westin", "123")
```

### 1.6.2. UriBuilder

[`UriComponentsBuilder`](#161-uricomponents)는
`UriBuilder` 인터페이스를 구현하고 있다.
`UriBuilderFactory`로 `UriBuilder`를 만들어도 된다.
`UriBuilderFactory`는 base URL, 인코딩 여부 등의 설정을 공유해서 
`UriBuilder`를 만들기 때문에, URI 템플릿을 플러그인 처럼 꽂아 쓸 수 있다.

`RestTemplate`이나 `WebClient`에
`UriBuilderFactory`를 설정해 놓고 URI를 커스텀할 수도 있다.
`DefaultUriBuilderFactory`는
옵션을 공유해서 `UriComponentsBuilder`를 만드는
`UriBuilderFactory`의 디폴트 구현체다.

다음 예제는 팩토리를 `RestTemplate`에 설정하는 예제다:

- *java*
    ```java
    // import org.springframework.web.util.DefaultUriBuilderFactory.EncodingMode;
    
    String baseUrl = "https://example.org";
    DefaultUriBuilderFactory factory = new DefaultUriBuilderFactory(baseUrl);
    factory.setEncodingMode(EncodingMode.TEMPLATE_AND_VALUES);
    
    RestTemplate restTemplate = new RestTemplate();
    restTemplate.setUriTemplateHandler(factory);
    ```
- *kotlin*
    ```kotlin
    // import org.springframework.web.util.DefaultUriBuilderFactory.EncodingMode
    
    val baseUrl = "https://example.org"
    val factory = DefaultUriBuilderFactory(baseUrl)
    factory.encodingMode = EncodingMode.TEMPLATE_AND_VALUES
    
    val restTemplate = RestTemplate()
    restTemplate.uriTemplateHandler = factory
    ```

다음 예제는 `WebClient`를 설정한다:

- *java*
    ```java
    // import org.springframework.web.util.DefaultUriBuilderFactory.EncodingMode;
    
    String baseUrl = "https://example.org";
    DefaultUriBuilderFactory factory = new DefaultUriBuilderFactory(baseUrl);
    factory.setEncodingMode(EncodingMode.TEMPLATE_AND_VALUES);
    
    WebClient client = WebClient.builder().uriBuilderFactory(factory).build();
    ```

- *kotlin*
    ```kotlin
    // import org.springframework.web.util.DefaultUriBuilderFactory.EncodingMode
    
    val baseUrl = "https://example.org"
    val factory = DefaultUriBuilderFactory(baseUrl)
    factory.encodingMode = EncodingMode.TEMPLATE_AND_VALUES
    
    val client = WebClient.builder().uriBuilderFactory(factory).build()
    ```

`DefaultUriBuilderFactory`로 직접 URI를 만들어도 된다.
`UriComponentsBuilder`를 사용하는 것과 비슷하지만,
팩토리는 스태틱 메소드가 아닌 설정을 가지고 있는 실제 인스턴스다:

- *java*
    ```java
    String baseUrl = "https://example.com";
    DefaultUriBuilderFactory uriBuilderFactory = new DefaultUriBuilderFactory(baseUrl);
    
    URI uri = uriBuilderFactory.uriString("/hotels/{hotel}")
            .queryParam("q", "{q}")
            .build("Westin", "123");
    ```
- *kotlin*
    ```kotlin
    val baseUrl = "https://example.com"
    val uriBuilderFactory = DefaultUriBuilderFactory(baseUrl)
    
    val uri = uriBuilderFactory.uriString("/hotels/{hotel}")
            .queryParam("q", "{q}")
            .build("Westin", "123")
    ```

### 1.6.3. URI Encoding

`UriComponentsBuilder`는 두 가지 인코딩 옵션이 있다:

- [UriComponentsBuilder#encode()](https://docs.spring.io/spring-framework/docs/5.2.6.RELEASE/javadoc-api/org/springframework/web/util/UriComponentsBuilder.html#encode--):
URI 템플릿을 먼저 인코딩하고, 템플릿에 URI 변수를 적용할 때
URI 변수를 엄격하게 인코딩한다.
- [UriComponents#encode()](https://docs.spring.io/spring-framework/docs/5.2.6.RELEASE/javadoc-api/org/springframework/web/util/UriComponents.html#encode--):
URI 변수 적용한 *후에* URI 컴포넌트를 인코딩한다.

두 옵션 모두 ASCII 외의 문자나 허용하지 않는 문자를
옥텟으로 이스케이프한다.
하지만 첫번째 옵션은 URI 변수에 예약된 문자가 있으면 치환해 버린다.

> path에 사용할 순 있지만 예약된 문자인 ";"을 생각해 보자.
> 첫번째 옵션은 URI 변수에 있는 ";"을 "%3B"로 치환하지만,
> URI 템플릿에 있는 문자는 치환하지 않는다.
> 반대로 두번째 옵션에선 ";"은 path에 사용할 수 있는 문자기 때문에
> 절대 치환하지 않는다.

첫번째 옵션은 URI 변수를 불투명한 데이터로 취급해 인코딩하기 때문에,
대부분 첫번째 옵션이 기대와 일치할 것이다.
두번째 옵션은 URI 변수에 의도적으로 예약 문자를 사용할 때만 유용하다.

다음은 첫번째 옵션을 사용하는 예제다:

- *java*
    ```java
    URI uri = UriComponentsBuilder.fromPath("/hotel list/{city}")
            .queryParam("q", "{q}")
            .encode()
            .buildAndExpand("New York", "foo+bar")
            .toUri();
    
    // Result is "/hotel%20list/New%20York?q=foo%2Bbar"
    ```
- *kotlin*
    ```kotlin
    val uri = UriComponentsBuilder.fromPath("/hotel list/{city}")
            .queryParam("q", "{q}")
            .encode()
            .buildAndExpand("New York", "foo+bar")
            .toUri()
    
    // Result is "/hotel%20list/New%20York?q=foo%2Bbar"
    ```

아래 처럼 바로 URI를 만들면 코드를 더 줄일 수 있다:

- *java*
```java
URI uri = UriComponentsBuilder.fromPath("/hotel list/{city}")
        .queryParam("q", "{q}")
        .build("New York", "foo+bar")
```
- *kotlin*
```kotlin
val uri = UriComponentsBuilder.fromPath("/hotel list/{city}")
        .queryParam("q", "{q}")
        .build("New York", "foo+bar")
```

URI 전체를 템플릿으로 쓰면 코드를 한 번 더 줄일 수 있다:

- *java*
```java
URI uri = UriComponentsBuilder.fromPath("/hotel list/{city}?q={q}")
        .build("New York", "foo+bar")
```
- *kotlin*
```kotlin
val uri = UriComponentsBuilder.fromPath("/hotel list/{city}?q={q}")
        .build("New York", "foo+bar")
```

`WebClient`와 `RestTemplate`은 내부에서
`UriBuilderFactory`를 사용해 URI 템플릿을 확장하고 인코딩한다.
아래 예제처럼 둘 다 팩토리 전략을 커스텀할 수 있다:

- *java*
    ```java
    String baseUrl = "https://example.com";
    DefaultUriBuilderFactory factory = new DefaultUriBuilderFactory(baseUrl)
    factory.setEncodingMode(EncodingMode.TEMPLATE_AND_VALUES);
    
    // Customize the RestTemplate..
    RestTemplate restTemplate = new RestTemplate();
    restTemplate.setUriTemplateHandler(factory);
    
    // Customize the WebClient..
    WebClient client = WebClient.builder().uriBuilderFactory(factory).build();
    ```
- *kotlin*
    ```kotlin
    val baseUrl = "https://example.com"
    val factory = DefaultUriBuilderFactory(baseUrl).apply {
        encodingMode = EncodingMode.TEMPLATE_AND_VALUES
    }
    
    // Customize the RestTemplate..
    val restTemplate = RestTemplate().apply {
        uriTemplateHandler = factory
    }
    
    // Customize the WebClient..
    val client = WebClient.builder().uriBuilderFactory(factory).build()
    ```

`DefaultUriBuilderFactory`는 내부에서 
`UriComponentsBuilder`로 URI 템플릿을 확장하고 인코딩한다.
팩토리로 아래 있는 인코딩 모드 중 하나를 설정할 수 있다:

- `TEMPLATE_AND_VALUES`: 위에 있는 첫번째 옵션
`UriComponentsBuilder#encode()`를 사용한다.
URI 템플릿을 먼저 인코딩 한 후 URI 변수를 엄격하게 인코딩한다.
- `VALUES_ONLY`: URI 템플릿은 인코딩하지 않는 대신
URI 변수를 템플릿에 적용하기 전에
`UriUtils#encodeUriUriVariables`로 엄격하게 인코딩한다.
- `URI_COMPONENT`: 위에 있는 두번째 옵션
`UriComponents#encode()`를 사용한다.
템플릿에 URI 변수를 적용하고 난 후에 URI 컴포넌트를 인코딩한다.
- `NONE`: 인코딩을 하지 않는다.

`RestTemplate`은 이전 버전과의 호환을 위해
`EncodingMode.URI_COMPONENT`로 설정돼 있다.
`WebClient`는 `DefaultUriBuilderFactory`의 디폴트 값을 사용하는데,
5.0.x 버전에선 `EncodingMode.URI_COMPONENT`였지만,
5.1 버전에서 `EncodingMode.TEMPLATE_AND_VALUES`로 변경됐다.

---

## 1.7. CORS

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-cors)

스프링 웹플럭스는 CORS(Cross-Origin Resource Sharing)를 지원한다.
이번 섹션에선 CORS 설정 방법을 설명한다.

### 1.7.1. Introduction

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-cors-intro)

보안상 이유로 브라우저는 origin이 다르다면 AJAX 요청을 보낼 수 없게 차단한다. 예를 들어 브라우저 탭 하나에선 은행 계좌 사이트를 보고 있고, 다른 탭에선 evil.com에 접속했다고 해보자. evil.com 사이트에 있는 스크립트는 은행 API에 AJAX 요청을 날릴 수 없다 (계좌 인출 요청 등).

Cross-Origin Resource Sharing(CORS)은 [W3C 스펙](https://www.w3.org/TR/cors/)으로, [브라우저 대부분](https://caniuse.com/#feat=cors)이 지원한다. IFRAME이나 JSONP으로는 한계가 있지만, CORS를 사용하면 원하는 cross-domain 요청만 허가할 수 있다.

### 1.7.2. Processing

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-cors-processing)

CORS 요청은 preflight, simple, 본 요청(actual reqeust)으로 나뉜다. CORS에 관한 글은 아주 많다. CORS 동작 방법이 궁금하다면 [이 문서](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)를 봐도 되고, 자세한 내용은 스펙 문서를 확인해 봐라.

스프링 웹플럭스는 CORS를 지원하는 `HandlerMapping` 구현체를 내장하고 있다. 요청이 핸들러에 매핑되면 `HandlerMapping`이 CORS 설정을 확인하고 다음 처리를 이어간다. Preflight 요청은 바로 처리하고, simple, 본 요청은 가로채서 유효성을 확인한 후에 CORS 응답 헤더를 추가한다.

cross-origin 요청(`Origin` 헤더와 호스트가 다른)을 허용하려면 몇 가지 CORS 설정이 필요하다. 매칭되는 CORS 설정이 없으면 preflight 요청은 거부하고, simple, 본 요청은 CORS 헤더를 추가하지 않으므로 브라우저단에서 요청을 차단한다.

`HandlerMapping`마다 URL 패턴 기반 `CorsConfiguration`을 [설정](https://docs.spring.io/spring-framework/docs/5.2.6.RELEASE/javadoc-api/org/springframework/web/reactive/handler/AbstractHandlerMapping.html#setCorsConfigurations-java.util.Map-)할 수 있다. 보통은 웹플럭스 자바 설정에 글로벌 CORS 매핑을 선언해서 모든 `HandlerMapping` 구현체에 공통으로 적용한다.

각 `HandlerMapping`에 있는 핸들러 레벨 CORS 설정과 글로벌 CORS 설정을 조합해서 쓸 수도 있다. 예를 들어 애노테이션을 선언한 컨트롤러는 클래스 레벨이나 메소드 레벨에 `@CrossOrigin`을 사용할 수 있다 (다른 핸들러는 `CorsConfigurationSource`를 구현할 수 있다).

글로벌 설정과 로컬 설정은 서로 덮어쓰지 않고 합쳐진다(additive). — 예를 들어 글로벌 설정에 있는 origin과 로컬 origin을 모두 더한다. 단, `allowCredentials`, `maxAge`같이 값 하나만 사용하는 속성은 로컬 값이 글로벌 값을 덮어 쓴다. 자세한 내용은 [`CorsConfiguration#combine(CorsConfiguration)`](https://docs.spring.io/spring-framework/docs/5.2.6.RELEASE/javadoc-api/org/springframework/web/cors/CorsConfiguration.html#combine-org.springframework.web.cors.CorsConfiguration-)을 참고하라.

> 소스 코드를 더 자세히 익히고 싶거나 커스텀하고 싶다면 다음을 참고하라:<br>
> - `CorsConfiguration`<br>
> - `CorsProcessor`, `DefaultCorsProcessor`<br>
> - `AbstractHandlerMapping`<br>

### 1.7.3. `@CrossOrigin`

다음과 같이 컨트롤러 메소드에 `@CrossOrigin`을 선언하면 cross-origin 요청을 허용한다:

- *java*
```java
@RestController
@RequestMapping("/account")
public class AccountController {

    @CrossOrigin
    @GetMapping("/{id}")
    public Mono<Account> retrieve(@PathVariable Long id) {
        // ...
    }

    @DeleteMapping("/{id}")
    public Mono<Void> remove(@PathVariable Long id) {
        // ...
    }
}
```
- *kotlin*
```kotlin
@RestController
@RequestMapping("/account")
class AccountController {

    @CrossOrigin
    @GetMapping("/{id}")
    suspend fun retrieve(@PathVariable id: Long): Account {
        // ...
    }

    @DeleteMapping("/{id}")
    suspend fun remove(@PathVariable id: Long) {
        // ...
    }
}
```

`@CrossOrigin`을 사용하면 디폴트로 다음을 허용한다:

- 모든 origin.
- 모든 헤더.
- 컨트롤러 메소드에 매핑된 모든 HTTP 메소드.

`allowedCredentials`는 기본적으로 비활성화 돼있다. 이 헤더를 사용하면 민감한 유저 식별 정보를(쿠키나 CSRF 토큰 같은) 노출하기 때문에 필요한 곳에서만 사용해야 한다.

`maxAge`는 30분으로 설정한다.

`@CrossOrigin`을 클래스 레벨에 사용하면 모든 메소드에 상속한다. 다음은 특정 도메인을 지정하고 `maxAge`를 1시간으로 설정하는 예제다:

- *java*
```java
@CrossOrigin(origins = "https://domain2.com", maxAge = 3600)
@RestController
@RequestMapping("/account")
public class AccountController {

    @GetMapping("/{id}")
    public Mono<Account> retrieve(@PathVariable Long id) {
        // ...
    }

    @DeleteMapping("/{id}")
    public Mono<Void> remove(@PathVariable Long id) {
        // ...
    }
}
```
- *kotlin*
```kotlin
@CrossOrigin("https://domain2.com", maxAge = 3600)
@RestController
@RequestMapping("/account")
class AccountController {

    @GetMapping("/{id}")
    suspend fun retrieve(@PathVariable id: Long): Account {
        // ...
    }

    @DeleteMapping("/{id}")
    suspend fun remove(@PathVariable id: Long) {
        // ...
    }
}
```

아래 예제처럼 `@CrossOrigin`을 클래스 레벨과 메소드 레벨에 동시에 선언해도 된다:

- *java*
```java
@CrossOrigin(maxAge = 3600) // (1)
@RestController
@RequestMapping("/account")
public class AccountController {

    @CrossOrigin("https://domain2.com") // (2)
    @GetMapping("/{id}")
    public Mono<Account> retrieve(@PathVariable Long id) {
        // ...
    }

    @DeleteMapping("/{id}")
    public Mono<Void> remove(@PathVariable Long id) {
        // ...
    }
}
```
- *kotlin*
```kotlin
@CrossOrigin(maxAge = 3600) // (1)
@RestController
@RequestMapping("/account")
class AccountController {

    @CrossOrigin("https://domain2.com") // (2) 
    @GetMapping("/{id}")
    suspend fun retrieve(@PathVariable id: Long): Account {
        // ...
    }

    @DeleteMapping("/{id}")
    suspend fun remove(@PathVariable id: Long) {
        // ...
    }
}
```
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(1)</span> 클래스 레벨에 `@CrossOrigin`을 사용한다.</small><br>
<small><span style="background-color: #a9dcfc; border-radius: 50px;">(2)</span> 메소드 레벨에 `@CrossOrigin`을 사용한다.</small>

### 1.7.4. Global Configuration

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-cors-global)

컨트롤러 메소드에 일일이 설정하는 대신, 어딘가에 공통으로 사용할 CORS 설정을 정의하고 싶을 때도 있다. 모든 `HandlerMapping`은 전용 URL 기반 `CorsConfiguration`을 매핑할 수 있다. 하지만 대부분은 웹플럭스 자바 설정으로 공통 CORS 룰을 적용한다.

글로벌 설정을 사용하면 디폴트로 다음을 허용한다:

- 모든 origin.
- 모든 헤더.
- `GET`, `HEAD`, `POST` 메소드.

`allowedCredentials`는 기본적으로 비활성화 돼있다. 이 헤더를 사용하면 민감한 유저 식별 정보를(쿠키나 CSRF 토큰 같은) 노출하기 때문에 필요한 곳에서만 사용해야 한다.

`maxAge`는 30분으로 설정한다.

웹플럭스 자바 설정으로 CORS를 활성화시키려면 다음 예제처럼 `CorsRegistry` 콜백을 사용한다:

- *java*
```java
@Configuration
@EnableWebFlux
public class WebConfig implements WebFluxConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {

        registry.addMapping("/api/**")
            .allowedOrigins("https://domain2.com")
            .allowedMethods("PUT", "DELETE")
            .allowedHeaders("header1", "header2", "header3")
            .exposedHeaders("header1", "header2")
            .allowCredentials(true).maxAge(3600);

        // Add more mappings...
    }
}
```
- *kotlin*
```kotlin
@Configuration
@EnableWebFlux
class WebConfig : WebFluxConfigurer {

    override fun addCorsMappings(registry: CorsRegistry) {

        registry.addMapping("/api/**")
                .allowedOrigins("https://domain2.com")
                .allowedMethods("PUT", "DELETE")
                .allowedHeaders("header1", "header2", "header3")
                .exposedHeaders("header1", "header2")
                .allowCredentials(true).maxAge(3600)

        // Add more mappings...
    }
}
```

### 1.7.5. CORS `WebFilter`

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-cors-filter)

[함수형 엔드포인트](#15-functional-endpoints)와도 잘 맞는 내장 [`CorsWebFilter`](https://docs.spring.io/spring-framework/docs/5.2.6.RELEASE/javadoc-api/org/springframework/web/cors/reactive/CorsWebFilter.html)로 CORS를 지원할 수도 있다.

> `CorsFilter`를 Spring Security와 함께 사용한다면, Spring Security에는 [CORS 통합 설정](https://docs.spring.io/spring-security/site/docs/current/reference/html5/#cors)이 있다는 것을 기억해 둬라.

필터를 설정하려면, 다음 코드 처럼 `CorsWebFilter` 생성자에 `CorsConfigurationSource`를 주입하고 빈으로 정의한다:

- *java*
```java
@Bean
CorsWebFilter corsFilter() {

    CorsConfiguration config = new CorsConfiguration();

    // Possibly...
    // config.applyPermitDefaultValues()

    config.setAllowCredentials(true);
    config.addAllowedOrigin("https://domain1.com");
    config.addAllowedHeader("*");
    config.addAllowedMethod("*");

    UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
    source.registerCorsConfiguration("/**", config);

    return new CorsWebFilter(source);
}
```
- *kotlin*
```kotlin
@Bean
fun corsFilter(): CorsWebFilter {

    val config = CorsConfiguration()

    // Possibly...
    // config.applyPermitDefaultValues()

    config.allowCredentials = true
    config.addAllowedOrigin("https://domain1.com")
    config.addAllowedHeader("*")
    config.addAllowedMethod("*")

    val source = UrlBasedCorsConfigurationSource().apply {
        registerCorsConfiguration("/**", config)
    }
    return CorsWebFilter(source)
}
```

---

## 1.8. Web Security

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-web-security)

[Spring Security](https://spring.io/projects/spring-security) 
프로젝트는 악의적인 취약점 공격(exploit)으로부터 웹 어플리케이션을 보호해 준다. 다음 Spring Security 레퍼런스 문서를 참고하라:

- [WebFlux Security](https://docs.spring.io/spring-security/site/docs/current/reference/html5/#jc-webflux)
- [WebFlux Testing Support](https://docs.spring.io/spring-security/site/docs/current/reference/html5/#test-webflux)
- [CSRF Protection](https://docs.spring.io/spring-security/site/docs/current/reference/html5/#csrf)
- [Security Response Headers](https://docs.spring.io/spring-security/site/docs/current/reference/html5/#headers)

---

## 1.9. View Technologies

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-view)

스프링 웹플럭스에선 원하는 view 기술을 선택할 수 있다. Thymeleaf든 FreeMarker든, 그외 다른 뷰 기술이든 설정만 바꿔주면 된다. 이번 챕터에서는 스프링 웹플럭스에 통합된 뷰 기술을 다룬다. [View Resolution](https://godekdls.github.io/Reactive%20Spring/springwebflux/#136-view-resolution)은 이미 알고 있다고 가정한다.

### 1.9.1. Thymeleaf

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-view-thymeleaf)

Thymeleaf는 모던 서버사이드 자바 템플릿 엔진이다. 브라우저 더블 클릭만으로 미리보기를 실행할 수 있는 natural HTML 템플릿을 피력하기 때문에, 서버를 실행하지 않고 독립적으로 UI 템플릿을 만들기 좋다(예를 들어 디자이가). Thymeleaf는 제공하는 기능도 아주 많고, 지금도 활발하게 개발되고 있다. 자세한 소개는 [Thymeleaf](https://www.thymeleaf.org/) 프로젝트 홈페이지를 참고하라.

Thymeleaf-스프링 웹플럭스 통합 모듈은 Thymeleaf 프로젝트에서 관리한다. 통합 설정은 `SpringResourceTemplateResolver`, `SpringWebFluxTemplateEngine`, `ThymeleafReactiveViewResolver`같은 몇 가지 빈을 정의한다. 자세한 정보는 [Thymeleaf+Spring](https://www.thymeleaf.org/documentation.html)과 WebFlux 통합 [공지](http://forum.thymeleaf.org/Thymeleaf-3-0-8-JUST-PUBLISHED-td4030687.html)에서 확인할 수 있다.

### 1.9.2. FreeMarker

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-view-freemarker)

[Apache FreeMarker](https://freemarker.apache.org/)는
HTML, 이메일 등의 텍스트를 만들어 주는 템플릿 엔진이다. 스프링 웹플럭스에서 FreeMarker 템플릿을 사용한다면, 스프링 프레임워크가 제공하는 내장 통합 모듈을 사용하면 된다.

#### View Configuration

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-view-freemarker-contextconfig)

다음은 FreeMarker를 설정하는 예제다:

- *java*
```java
@Configuration
@EnableWebFlux
public class WebConfig implements WebFluxConfigurer {

    @Override
    public void configureViewResolvers(ViewResolverRegistry registry) {
        registry.freeMarker();
    }

    // Configure FreeMarker...

    @Bean
    public FreeMarkerConfigurer freeMarkerConfigurer() {
        FreeMarkerConfigurer configurer = new FreeMarkerConfigurer();
        configurer.setTemplateLoaderPath("classpath:/templates/freemarker");
        return configurer;
    }
}
```
- *kotlin*
```kotlin
@Configuration
@EnableWebFlux
class WebConfig : WebFluxConfigurer {

    override fun configureViewResolvers(registry: ViewResolverRegistry) {
        registry.freeMarker()
    }

    // Configure FreeMarker...

    @Bean
    fun freeMarkerConfigurer() = FreeMarkerConfigurer().apply {
        setTemplateLoaderPath("classpath:/templates/freemarker")
    }
}
```

템플릿은 `FreeMarkerConfigurer`에 명시한 디렉토리에 있어야 한다. 위와 같이 설정하면 컨트롤러에서 view name `welcome`을 리턴했을 때 리졸버가 `classpath:/templates/freemarker/welcome.ftl` 템플릿을 찾는다.

#### FreeMarker Configuration

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-views-freemarker)

`FreeMarkerConfigurer` 빈 프로퍼티로 FreeMarker `Configuration` 객체(스프링이 관리하는)에 'Settings', 'SharedVariables' 값을 설정할 수 있다. `freemarkerSettings` 프로퍼티는 `java.util.Properties` 객체를, `freemarkerVariables` 프로퍼티는 `java.util.Map`을 사용한다. 다음은 `FreeMarkerConfigurer`를 사용하는 예제다:

- *java*
```java
@Configuration
@EnableWebFlux
public class WebConfig implements WebFluxConfigurer {

    // ...

    @Bean
    public FreeMarkerConfigurer freeMarkerConfigurer() {
        Map<String, Object> variables = new HashMap<>();
        variables.put("xml_escape", new XmlEscape());

        FreeMarkerConfigurer configurer = new FreeMarkerConfigurer();
        configurer.setTemplateLoaderPath("classpath:/templates");
        configurer.setFreemarkerVariables(variables);
        return configurer;
    }
}
```
- *kotlin*
```kotlin
@Configuration
@EnableWebFlux
class WebConfig : WebFluxConfigurer {

    // ...

    @Bean
    fun freeMarkerConfigurer() = FreeMarkerConfigurer().apply {
        setTemplateLoaderPath("classpath:/templates")
        setFreemarkerVariables(mapOf("xml_escape" to XmlEscape()))
    }
}
```

`Configuration` 객체의 설정값과 변수는 FreeMarker 문서에 자세히 나와 있다.

#### Form Handling

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-view-freemarker-forms)

스프링은 JSP에서 사용하는 `<spring:bind/>` 엘리먼트 등, 다양한 태그 라이브러리를 지원한다. 이 엘리먼트를 사용하면 객체에 form 데이터를 유지하기 때문에, 웹이나 비지니스 레이어 `Validator`에서 유효성 검증에 실패하더라도 사용자가 입력한 데이터를 화면에 그대로 보여줄 수 있다. 스프링은 FreeMarker에서도 같은 기능을 지원하며, form 입력 엘리먼트를 만들어주는 편리한 매크로도 함께 제공한다.

#### The Bind Macros

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-view-bind-macros)

FreeMarker를 위한 표준 매크로 셋은 `spring-webflux.jar` 파일에 들어있기 때문에 어플리케이션에서 적절히 설정해 쓰면 된다.

스프링 템플릿 라이브러리에 있는 일부 매크로는 내부에서만 관리하지만(private), 매크로 정의는 그렇지 않으므로 코드와 템플릿에선 모든 매크로를 사용할 수 있다. 다음 섹션은 템플릿에서 직접 호출하는 매크로에만 집중한다. 매크로 코드가 궁금하다면 `org.springframework.web.reactive.result.view.freemarker` 패키지에 있는 `spring.ftl` 파일을 확인하라.

매크로 바인딩에 대한 자세한 정보는 스프링 MVC의 [Simple Binding](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-view-simple-binding)을 참고하라.

#### Form Macros

스프링이 지원하는 FreeMarker 템플릿용 form 매크로는 아래 있는 스프링 MVC 문서에 자세히 나와 있다.

- [Input Macros](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-views-form-macros)
- [Input Fields](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-views-form-macros-input)
- [Selection Fields](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-views-form-macros-select)
- [HTML Escaping](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-views-form-macros-html-escaping)



### 1.9.3. Script Views

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-view-script)

스프링 프레임워크는 [JSR-223](https://www.jcp.org/en/jsr/detail?id=223) 자바 스크립트 엔진에서 실행할 수 있는 모든 템플릿 라이브러리를 스프링 웹플럭스와 자동으로 통합해 준다. 다음 테이블은 각 스크립트 엔진에서 테스트를 거친 템플릿 라이브러리다:

| Scripting Library                                            | Scripting Engine                                      |
| :----------------------------------------------------------- | :---------------------------------------------------- |
| [Handlebars](https://handlebarsjs.com/)                      | [Nashorn](https://openjdk.java.net/projects/nashorn/) |
| [Mustache](https://mustache.github.io/)                      | [Nashorn](https://openjdk.java.net/projects/nashorn/) |
| [React](https://facebook.github.io/react/)                   | [Nashorn](https://openjdk.java.net/projects/nashorn/) |
| [EJS](https://www.embeddedjs.com/)                           | [Nashorn](https://openjdk.java.net/projects/nashorn/) |
| [ERB](https://www.stuartellis.name/articles/erb/)            | [JRuby](https://www.jruby.org/)                       |
| [String templates](https://docs.python.org/2/library/string.html#template-strings) | [Jython](https://www.jython.org/)                     |
| [Kotlin Script templating](https://github.com/sdeleuze/kotlin-script-templating) | [Kotlin](https://kotlinlang.org/)                     |

> 다른 스크립트 엔진을 통합하려면 반드시 `ScriptEngine` , `Invocable` 인터페이스를 구현해야 한다.

#### Requirements

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-view-script-dependencies)

클래스패스에 스크립트 엔진이 있어야 하며, 각 엔진마다 요구사항이 조금씩 다르다:

- java 8+는 [Nashorn](https://openjdk.java.net/projects/nashorn/) 자바스크립트 엔진을 지원한다. 가장 최근에 업데이트된 버전을 사용하는 게 가장 좋다.
- Ruby를 사용하려면 [JRuby](https://www.jruby.org/) 의존성을 추가해야 한다.
- Python을 사용하려면 [Jython](https://www.jython.org/) 의존성을 추가해야 한다.
- 코틀린 스크립트를 사용하려면
  `org.jetbrains.kotlin:kotlin-script-util` 의존성과, `org.jetbrains.kotlin.script.jsr223.KotlinJsr223JvmLocalScriptEngineFactory` 라인을 포함한  `META-INF/services/javax.script.ScriptEngineFactory` 파일이 필요하다. 자세한 내용은 [이 예제](https://github.com/sdeleuze/kotlin-script-templating)를 참고하라.

스크립트 템플릿 라이브러리가 필요하다. 자바스크립트를 사용하는 한 가지 방법은 [WebJars](https://www.webjars.org/)를 사용하는 것이다.

#### Script Templates

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-view-script-integrate)

`ScriptTemplateConfigurer` 빈으로 실행할 스크립트 엔진과, 로딩할 스크립트 파일, 템플릿을 렌더링할 때 실행할 함수 등을 설정할 수 있다. 다음 예제는 Mustache 템플릿과 Nashorn 자바스크립트 엔진을 사용한다:

- *java*

  ```java
  @Configuration
  @EnableWebFlux
  public class WebConfig implements WebFluxConfigurer {
  
      @Override
      public void configureViewResolvers(ViewResolverRegistry registry) {
          registry.scriptTemplate();
      }
  
      @Bean
      public ScriptTemplateConfigurer configurer() {
          ScriptTemplateConfigurer configurer = new ScriptTemplateConfigurer();
          configurer.setEngineName("nashorn");
          configurer.setScripts("mustache.js");
          configurer.setRenderObject("Mustache");
          configurer.setRenderFunction("render");
          return configurer;
      }
  }
  ```

- *kotlin*

  ```kotlin
  @Configuration
  @EnableWebFlux
  class WebConfig : WebFluxConfigurer {
  
      override fun configureViewResolvers(registry: ViewResolverRegistry) {
          registry.scriptTemplate()
      }
  
      @Bean
      fun configurer() = ScriptTemplateConfigurer().apply {
          engineName = "nashorn"
          setScripts("mustache.js")
          renderObject = "Mustache"
          renderFunction = "render"
      }
  }
  ```

  

### 1.9.4. JSON and XML

---

## 1.10. HTTP Caching

### 1.10.1. CacheControl
### 1.10.2. Controllers
### 1.10.3. Static Resources

---

## 1.11. WebFlux Config

### 1.11.1. Enabling WebFlux Config
### 1.11.2. WebFlux config API
### 1.11.3. Conversion, formatting
### 1.11.4. Validation
### 1.11.5. Content Type Resolvers
### 1.11.6. HTTP message codecs
### 1.11.7. View Resolvers
### 1.11.8. Static Resources
### 1.11.9. Path Matching
### 1.11.10. Advanced Configuration Mode

---

## 1.12. HTTP/2

[Web MVC](https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-http2)

리액터 Netty, 톰캣, Jetty, Undertow는 HTTP/2를 지원한다.
HTTP/2를 사용하려면 몇 가지 서버 설정을 확인해 봐야 한다.
자세한 내용은 [HTTP/2 위키](https://github.com/spring-projects/spring-framework/wiki/HTTP-2-support)를
참조하라.

---

> 전체 목차는 [여기](https://godekdls.github.io/Reactive%20Spring/contents/)에 있습니다.
