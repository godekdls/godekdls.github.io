---
title: Sending Email
category: Spring Boot
order: 26
permalink: /Spring%20Boot/sending-email/
description: 스프링 부트로 JavaMailSender 자동 설정하고 커스텀하기
image: ./../../images/springboot/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 부트
originalRefLink: https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#features.email
parent: Spring Boot Features
parentUrl: /Spring%20Boot/spring-boot-features/
---
<script>defaultLanguages = ['properties']</script>

---

## 7.18. Sending Email

스프링 프레임워크는 `JavaMailSender` 인터페이스를 통해 이메일 전송 로직을 추상화해주며, 스프링 부트는 이를 위한 자동 설정과 스타터 모듈을 제공한다.

> `JavaMailSender` 사용법에 대한 자세한 내용은 [레퍼런스 문서](https://docs.spring.io/spring-framework/docs/5.3.8/reference/html/integration.html#mail)를 참고해라.

`spring.mail.host`와 관련 라이브러리(`spring-boot-starter-mail`로 정의해 뒀다)가 있을 땐, `JavaMailSender`가 없으면 디폴트 `JavaMailSender`를 생성한다. sender는 `spring.mail` 네임스페이스를 통해 설정을 좀 더 커스텀할 수 있다. 자세한 내용은 [`MailProperties`](https://github.com/spring-projects/spring-boot/tree/v2.5.2/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/mail/MailProperties.java)를 참고해라.

특히, 디폴트 타임아웃 값들은 무제한으로 설정돼 있으며, 다음 예제처럼 메일 서버에서 응답이 없을 때 스레드가 블로킹되지 않도록 변경해두는 게 좋다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.mail.properties[mail.smtp.connectiontimeout]=5000
spring.mail.properties[mail.smtp.timeout]=3000
spring.mail.properties[mail.smtp.writetimeout]=5000
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  mail:
    properties:
      "[mail.smtp.connectiontimeout]": 5000
      "[mail.smtp.timeout]": 3000
      "[mail.smtp.writetimeout]": 5000
```

JNDI에 있는 기존 `Session`으로도 `JavaMailSender`를 설정할 수 있다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
spring.mail.jndi-name=mail/Session
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
spring:
  mail:
    jndi-name: "mail/Session"
```

`jndi-name`을 설정하게 되면, 다른 모든 Session 관련 설정보다 우선시한다.