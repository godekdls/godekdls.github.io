---
title: Internationalization
category: Spring Boot
order: 13
permalink: /Spring%20Boot/internationalization/
description: 리소스 번들을 사용해서 스프링 부트 메세지 현지화하기
image: ./../../images/springboot/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 부트
originalRefLink: https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#features.internationalization
parent: Spring Boot Features
parentUrl: /Spring%20Boot/spring-boot-features/
---
<script>defaultLanguages = ['properties']</script>

---

## 7.5. Internationalization

스프링 부트에선 지역에 따라 메세지를 현지화할 수 있기 때문에, 애플리케이션에선 사용자의 선호도에 따라 다양한 언어를 제공할 수 있다. 기본적으로 스프링 부트는 클래스패스 루트에서 `messages` 리소스 번들을 찾는다.

> 자동 설정은 설정한 리소스 번들에 properties 파일이 있어야 적용된다 (ex. 디폴트에선 `messages.properties`). 리소스 번들에 특정 언어에 따른 프로퍼티 파일만 들어 있다면 기본값도 추가해줘야 한다. 설정한 base name과 일치하는 properties 파일이 없으면 `MessageSource`를 자동 설정하지 않는다.

리소스 번들의 basename이나 다른 속성들은 다음 예시처럼 `spring.messages` 네임스페이스로 설정할 수 있다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.messages.basename=messages,config.i18n.messages
spring.messages.fallback-to-system-locale=false
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  messages:
    basename: "messages,config.i18n.messages"
    fallback-to-system-locale: false
```

> `spring.messages.basename`엔 여러 가지 location을 콤마로 구분해서 지정할 수 있으며, location엔 패키지 한정자와 클래스패스에 있는 리소스를 사용할 수 있다.

지원하는 다른 옵션들도 알고 싶다면 [`MessageSourceProperties`](https://github.com/spring-projects/spring-boot/tree/v2.5.2/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/context/MessageSourceProperties.java)를 확인해봐라.