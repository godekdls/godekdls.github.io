---
title: Cloud Foundry Support
category: Spring Boot 2.X
order: 51
permalink: /Spring%20Boot/cloud-foundry-support/
description: 클라우드 파운드리에서 지원하는 액추에이터 엔드포인트 소개
image: ./../../images/springboot/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 부트
originalRefLink: https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#actuator.cloud-foundry
parent: Spring Boot Actuator
parentUrl: /Spring%20Boot/spring-boot-actuator/
priority: 0.4
---
<script>defaultLanguages = ['properties']</script>

### 목차

- [8.10.1. Disabling Extended Cloud Foundry Actuator Support](#8101-disabling-extended-cloud-foundry-actuator-support)
- [8.10.2. Cloud Foundry Self-signed Certificates](#8102-cloud-foundry-self-signed-certificates)
- [8.10.3. Custom Context Path](#8103-custom-context-path)

---

## 8.10. Cloud Foundry Support

스프링 부트의 액추에이터 모듈은 호환되는 Cloud Foundry 인스턴스로 배포할 때 활성화되는 별도 기능이 포함돼 있다. `/cloudfoundryapplication` 경로에선 모든 `@Endpoint` 빈들에 보안을 적용해서 라우팅해준다.

스프링 부트 액추에이터 정보를 활용하면 Cloud Foundry management UI(ex. 배포된 애플리케이션을 조회할 때 사용하는 웹 애플리케이션)를 좀 더 개선할 수 있다. 예를 들어, 애플리케이션 상태 페이지에선 전형적인 “running”, “stopped” 상태만 나타내는 대신, 모든 health 정보를 노출할 수 있다.

> 일반 사용자는 `/cloudfoundryapplication` 경로에 직접 접근할 수 없다. 이 엔드포인트를 이용하려면 요청에 유효한 UAA 토큰을 전달해야 한다.

### 8.10.1. Disabling Extended Cloud Foundry Actuator Support

`/cloudfoundryapplication` 엔드포인트를 완전히 비활성화하려면 `application.properties` 파일에 다음 설정을 추가하면 된다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
management.cloudfoundry.enabled=false
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
management:
  cloudfoundry:
    enabled: false
```

### 8.10.2. Cloud Foundry Self-signed Certificates

기본적으로 `/cloudfoundryapplication` 엔드포인트에서 접근 권한을 검사할 땐 다양한 Cloud Foundry 서비스를 SSL로 호출하게 된다. Cloud Foundry UAA나 Cloud Controller 서비스가 자체 서명 인증서를 사용한다면 아래 프로퍼티를 설정해줘야 한다:

<div class="switch-language-wrapper properties yaml">
<span class="switch-language properties">properties</span>
<span class="switch-language yaml">yaml</span>
</div>
<div class="language-only-for-properties properties yaml"></div>
```properties
management.cloudfoundry.skip-ssl-validation=true
```
<div class="language-only-for-yaml properties yaml"></div>
```yaml
management:
  cloudfoundry:
    skip-ssl-validation: true
```

### 8.10.3. Custom Context Path

서버의 컨텍스트 경로가 `/`로 설정돼있지 않다면 Cloud Foundry 엔드포인트는 애플리케이션의 루트에서 사용할 수 없을 거다. 예를 들어 `server.servlet.context-path=/app`으로 설정했다면 Cloud Foundry 엔드포인트는 `/app/cloudfoundryapplication/*`에서 이용할 수 있다.

Cloud Foundry 엔드포인트를 서버의 컨텍스트 경로랑은 상관없이 항상 `/cloudfoundryapplication/*`에서 이용하고 싶다면 애플리케이션에서 직접 설정해줘야 한다. 설정은 사용 중인 웹 서버에 따라 다르다. 톰캣은 아래 설정을 추가해주면 된다:

```java
@Configuration(proxyBeanMethods = false)
public class MyCloudFoundryConfiguration {

    @Bean
    public TomcatServletWebServerFactory servletWebServerFactory() {
        return new TomcatServletWebServerFactory() {

            @Override
            protected void prepareContext(Host host, ServletContextInitializer[] initializers) {
                super.prepareContext(host, initializers);
                StandardContext child = new StandardContext();
                child.addLifecycleListener(new Tomcat.FixContextListener());
                child.setPath("/cloudfoundryapplication");
                ServletContainerInitializer initializer = getServletContextInitializer(getContextPath());
                child.addServletContainerInitializer(initializer, Collections.emptySet());
                child.setCrossContext(true);
                host.addChild(child);
            }

        };
    }

    private ServletContainerInitializer getServletContextInitializer(String contextPath) {
        return (classes, context) -> {
            Servlet servlet = new GenericServlet() {

                @Override
                public void service(ServletRequest req, ServletResponse res) throws ServletException, IOException {
                    ServletContext context = req.getServletContext().getContext(contextPath);
                    context.getRequestDispatcher("/cloudfoundryapplication").forward(req, res);
                }

            };
            context.addServlet("cloudfoundry", servlet).addMapping("/*");
        };
    }

}
```
