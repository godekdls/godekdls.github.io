---
title: Calling REST Services with RestTemplate
category: Spring Boot
order: 23
permalink: /Spring%20Boot/calling-rest-services-with-resttemplate/
description: 스프링 부트로 RestTemplate 자동 설정하고 커스텀하기
image: ./../../images/springboot/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 부트
originalRefLink: https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#features.resttemplate
parent: Spring Boot Features
parentUrl: /Spring%20Boot/spring-boot-features/
---

### 목차

- [7.15.1. RestTemplate Customization](#7151-resttemplate-customization)

---

## 7.15. Calling REST Services with RestTemplate

애플리케이션에서 원격에 있는 REST 서비스를 호출해야 할 땐 스프링 프레임워크의 [`RestTemplate`](https://docs.spring.io/spring-framework/docs/5.3.8/javadoc-api/org/springframework/web/client/RestTemplate.html) 클래스를 사용할 수 있다. `RestTemplate` 인스턴스는 사용 전에 커스텀해야 하는 경우가 많기 때문에 스프링 부트는 `RestTemplate` 빈을 단일로 자동 설정해주지 않는다. 하지만 `RestTemplate` 인스턴스를 만들 때 활용할 수 있는 `RestTemplateBuilder`를 자동으로 설정한다. 자동 설정된 `RestTemplateBuilder`는 `RestTemplate` 인스턴스에 적당한 `HttpMessageConverters`를 적용해준다.

다음은 `RestTemplateBuilder`를 활용하는 전형적인 예시다:

```java
@Service
public class MyService {

    private final RestTemplate restTemplate;

    public MyService(RestTemplateBuilder restTemplateBuilder) {
        this.restTemplate = restTemplateBuilder.build();
    }

    public Details someRestCall(String name) {
        return this.restTemplate.getForObject("/{name}/details", Details.class, name);
    }

}
```

> `RestTemplateBuilder`는 `RestTemplate`을 빠르게 설정할 수 있는 유용한 메소드를 많이 가지고 있다. 예를 들어, BASIC 인증을 추가하고 싶을 땐 `builder.basicAuthentication("user", "password").build()`를 사용하면 된다.

### 7.15.1. RestTemplate Customization

`RestTemplate`을 커스텀하는 방법은, 커스텀을 적용하려는 범위에 따라 세 가지로 나뉜다.

커스텀 범위를 최소한으로 좁히려면 자동 설정된 `RestTemplateBuilder`를 주입한 다음 필요한 메소드를 호출해라. 메소드를 호출할 때마다 새 `RestTemplateBuilder` 인스턴스를 반환하므로, 그 빌더를 사용하는 곳에만 커스텀이 적용된다.

애플리케이션 전체에 걸쳐 커스텀 로직을 첨가하려면 `RestTemplateCustomizer` 빈을 사용해라. 이런 빈들은 전부 자동 설정된 `RestTemplateBuilder`에 저절로 등록되며, `RestTemplateBuilder`로 빌드하는 모든 템플릿에 적용된다.

다음은 `192.168.0.5`를 제외한 모든 호스트에 프록시를 설정하는 customizer 예시다:

```java
public class MyRestTemplateCustomizer implements RestTemplateCustomizer {

    @Override
    public void customize(RestTemplate restTemplate) {
        HttpRoutePlanner routePlanner = new CustomRoutePlanner(new HttpHost("proxy.example.com"));
        HttpClient httpClient = HttpClientBuilder.create().setRoutePlanner(routePlanner).build();
        restTemplate.setRequestFactory(new HttpComponentsClientHttpRequestFactory(httpClient));
    }

    static class CustomRoutePlanner extends DefaultProxyRoutePlanner {

        CustomRoutePlanner(HttpHost proxy) {
            super(proxy);
        }

        @Override
        public HttpHost determineProxy(HttpHost target, HttpRequest request, HttpContext context) throws HttpException {
            if (target.getHostName().equals("192.168.0.5")) {
                return null;
            }
            return super.determineProxy(target, request, context);
        }

    }

}
```

마지막 방법은 자체 `RestTemplateBuilder` 빈을 생성하는 거다. `RestTemplateBuilder` 자동 설정은 그대로 사용면서 `RestTemplateCustomizer` 빈 사용을 전부 막으려면, `RestTemplateBuilderConfigurer`를 통해 커스텀 인스턴스를 설정해야 한다. 다음 예제는 커스텀 connect, read 타임아웃만 직접 지정하고 나머지는 스프링 부트로 자동 설정하는 `RestTemplateBuilder`를 정의한다:

```java
@Configuration(proxyBeanMethods = false)
public class MyRestTemplateBuilderConfiguration {

    @Bean
    public RestTemplateBuilder restTemplateBuilder(RestTemplateBuilderConfigurer configurer) {
        return configurer.configure(new RestTemplateBuilder()).setConnectTimeout(Duration.ofSeconds(5))
                .setReadTimeout(Duration.ofSeconds(2));
    }

}
```

가장 극단적인 옵션은 (거의 사용하지 않는다) configurer 없이 자체 `RestTemplateBuilder` 빈을 생성하는 거다. 이렇게 하면 `RestTemplateBuilder` 자동 설정은 비활성화되며, `RestTemplateCustomizer` 빈도 사용하지 않게 된다.
