---
title: Building a Simple Gateway by Using Spring MVC or Webflux
category: Spring Cloud Gateway
order: 19
permalink: /Spring%20Cloud%20Gateway/building-a-simple-gateway-by-using-spring-mvc-or-webflux/
description: 스프링 MVC와 Webflux를 사용해 간단한 게이트웨이 어플리케이션을 만드는 방법 한국어 번역
image: ./../../images/springcloud/logo.jpeg
lastmod: 2021-04-06T22:00:00+09:00
comments: true
originalRefName: 스프링 클라우드 게이트웨이
originalRefLink: https://docs.spring.io/spring-cloud-gateway/docs/3.0.2/reference/html/#building-a-simple-gateway-by-using-spring-mvc-or-webflux
---

---

여기서부턴 또 다른 스타일의 게이트웨이를 설명한다. 이전에 설명했던 내용은 여기서 다루는 스타일에선 적용되지 않는다.

스프링 클라우드 게이트웨이는 `ProxyExchange`라는 유틸리티 객체를 제공한다. 전형적인 스프링 웹 핸들러에서 메소드 파라미터로 사용할 수 있다. HTTP 메소드를 그대로 옮긴 객체 메소드를 통해 기본적인 다운스트림 HTTP exchange를 지원한다. MVC에선 `forward()` 메소드를 통해 로컬 핸들러로도 포워딩할 수 있다. `ProxyExchange`를 사용하려면 클래스패스에 알맞은 모듈을 넣어라 (`spring-cloud-gateway-mvc`나 `spring-cloud-gateway-webflux`).

다음 MVC 예제는 원격 서버에 대한 다운스트림 `/test` 요청을 프록시한다:

```java
@RestController
@SpringBootApplication
public class GatewaySampleApplication {

    @Value("${remote.home}")
    private URI home;

    @GetMapping("/test")
    public ResponseEntity<?> proxy(ProxyExchange<byte[]> proxy) throws Exception {
        return proxy.uri(home.toString() + "/image/png").get();
    }

}
```

다음은 같은 일을 하는 Webflux 예제다:

```java
@RestController
@SpringBootApplication
public class GatewaySampleApplication {

    @Value("${remote.home}")
    private URI home;

    @GetMapping("/test")
    public Mono<ResponseEntity<?>> proxy(ProxyExchange<byte[]> proxy) throws Exception {
        return proxy.uri(home.toString() + "/image/png").get();
    }

}
```

`ProxyExchange`에 있는 간편 메소드를 사용하면, 핸들러 메소드에서 수신한 요청의 URI path를 가져와 변경할 수 있다. 예를 들어 path의 뒤에 나오는 요소들을 추출해서 다운스트림으로 전달할 수 있다:

```java
@GetMapping("/proxy/path/**")
public ResponseEntity<?> proxyPath(ProxyExchange<byte[]> proxy) throws Exception {
  String path = proxy.path("/proxy/path/");
  return proxy.uri(home.toString() + "/foos/" + path).get();
}
```

게이트웨이 핸들러 메소드에선 스프링 MVC와 Webflux의 모든 기능을 사용할 수 있다. 따라서, 요청 헤더와 쿼리 파라미터 등을 주입할 수 있으며, 매핑 어노테이션을 선언해서 수신할 요청 범위를 한정할 수 있다. 이 기능과 관련해서 자세한 내용은 스프링 MVC의 `@RequestMapping` 문서를 참고해라.

다운스트림 응답에 헤더를 추가하려면 `ProxyExchange`의 `header()` 메소드를 사용하면 된다.

더불어 `get()` 메소드에 매퍼를 넘기면 (다른 메소드도 마찬가지), 응답 헤더를 조작할 수 있다 (응답에 있는 다른 모든 항목들도 마찬가지). 매퍼는 전달받은 `ResponseEntity`를 전송할 `ResponseEntity`로 변환하는 `Function`이다.

다운스트림으로 전달되지 않는 "민감한" 헤더와 (디폴트로 `cookie`와 `authorization`), "프록시" (`x-forwarded-*`) 헤더를 최우선으로 지원한다.