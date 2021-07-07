---
title: Monitoring and Management over JMX
category: Spring Boot
order: 33
permalink: /Spring%20Boot/monitoring-and-management-over-jmx/
description: 스프링 부트 애플리케이션에서 JMX를 통해 애플리케이션 모니터링하기
image: ./../../images/springboot/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 부트
originalRefLink: https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#features.jmx
parent: Spring Boot Features
parentUrl: /Spring%20Boot/spring-boot-features/
---

---

## 7.25. Monitoring and Management over JMX

JMX<sup>Java Management Extensions</sup>는 애플리케이션을 모니터링하고 관리할 수 있는 표준 메커니즘을 제공한다. 스프링 부트는 플랫폼에 가장 적합한 `MBeanServer` 빈을 `mbeanServer`라는 ID로 정의한다. 스프링 JMX 어노테이션(`@ManagedResource`, `@ManagedAttribute`, `@ManagedOperation`)을 선언한 빈은 모두 여기로 노출된다.

스프링 부트는 사용하는 플랫폼이 표준 `MBeanServer`를 제공하면 이를 사용하고, 필요하면 VM `MBeanServer`를 기본값으로 사용한다. 어디에서도 `MBeanServer`를 가져오지 못하면 `MBeanServer`를 새로 생성한다.

자세한 내용은 [`JmxAutoConfiguration`](https://github.com/spring-projects/spring-boot/tree/v2.5.2/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/jmx/JmxAutoConfiguration.java) 클래스를 참고해라.