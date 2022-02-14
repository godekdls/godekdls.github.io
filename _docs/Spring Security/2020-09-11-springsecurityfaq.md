---
title: Spring Security FAQ
category: Spring Security
order: 25
permalink: /Spring%20Security/springsecurityfaq/
description: 스프링 시큐리티 관련 FAQ 가이드입니다. 공식 문서에 있는 "Spring Security FAQ" 챕터를 한국어로 번역한 문서입니다.
image: ./../../images/springsecurity/spring-security.png
lastmod: 2020-09-20T23:18:12+09:00
comments: true
originalRefName: 스프링 시큐리티
originalRefLink: https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#appendix-faq
---

### 목차:

- [22.7. Spring Security FAQ](#227-spring-security-faq)
  + [22.7.1. General Questions](#2271-general-questions)
    * [스프링 시큐리티로 내 어플리케이션에서 필요한 모든 보안 처리를 다 할 수 있을까요?](#스프링-시큐리티로-내-어플리케이션에서-필요한-모든-보안-처리를-다-할-수-있을까요)
    * [그냥 web.xml security를 사용하는 것과 뭐가 다른가요?](#그냥-webxml-security를-사용하는-것과-뭐가-다른가요)
    * [자바랑 스프링 프레임워크는 어떤 버전을 사용해야 되나요?](#자바랑-스프링-프레임워크는-어떤-버전을-사용해야-되나요)
    * [스프링 시큐리티는 처음인데, HTTPS에서 CAS 싱글 사인온을 지원하는 어플리케이션을 만들어야 합니다. 특정 URL은 로컬에서 기본 인증을 적용하고, 여러 가지 백엔드 사용자 정보 소스로 (LDAP과 JDBC) 인증하려 합니다. 설정 파일들을 복사해왔는데 동작하지 않습니다.](#스프링-시큐리티는-처음인데-https에서-cas-싱글-사인온을-지원하는-어플리케이션을-만들어야-합니다-특정-url은-로컬에서-기본-인증을-적용하고-여러-가지-백엔드-사용자-정보-소스로-ldap과-jdbc-인증하려-합니다-설정-파일들을-복사해왔는데-동작하지-않습니다)
  + [22.7.2. Common Problems](#2272-common-problems)
    * [로그인하려고 하면 “Bad Credentials”라는 에러 메세지를 반환합니다. 뭐가 문젠가요?](#로그인하려고-하면-bad-credentials라는-에러-메세지를-반환합니다-뭐가-문젠가요)
    * [로그인하려고 하면 어플리케이션이 "무한 루프"에 빠집니다. 무슨 일일까요?](#로그인하려고-하면-어플리케이션이-무한-루프에-빠집니다-무슨-일일까요)
    * [“Access is denied (user is anonymous);”라는 메세지와 함께 예외가 발생합니다. 뭐가 문젠가요?](#access-is-denied-user-is-anonymous라는-메세지와-함께-예외가-발생합니다-뭐가-문젠가요)
    * [어플리케이션에서 로그아웃했는데도 어떻게 보호 중인 페이지를 계속 볼 수 있나요?](#어플리케이션에서-로그아웃했는데도-어떻게-보호-중인-페이지를-계속-볼-수-있나요)
    * ["An Authentication object was not found in the SecurityContext"라는 메세지와 함께 예외가 발생합니다. 뭐가 문젠가요?](#an-authentication-object-was-not-found-in-the-securitycontext라는-메세지와-함께-예외가-발생합니다-뭐가-문젠가요)
    * [LDAP 인증이 동작을 안해요.](#ldap-인증이-동작을-안해요)
    * [Session Management](#session-management)
    * [스프링 시큐리티의 동시 세션 제어 기능을 사용해서 같은 사용자가 동시에 로그인할 수 없도록 제한하려고 합니다.](#스프링-시큐리티의-동시-세션-제어-기능을-사용해서-같은-사용자가-동시에-로그인할-수-없도록-제한하려고-합니다)
    * [스프링 시큐리티로 인증하면 왜 세션 ID가 바뀌나요?](#스프링-시큐리티로-인증하면-왜-세션-id가-바뀌나요)
    * [톰캣을 사용 중인데 (또는 다른 서블릿 컨테이너), 로그인 페이지엔 HTTPS를 적용했고, 이후엔 HTTP를 사용해요.](#톰캣을-사용-중인데-또는-다른-서블릿-컨테이너-로그인-페이지엔-https를-적용했고-이후엔-http를-사용해요)
    * [저는 HTTP와 HTTPS를 전환하지도 않는데 세션이 유실돼요.](#저는-http와-https를-전환하지도-않는데-세션이-유실돼요)
    * [동시 세션 제어 기능을 사용하려는데, 세션 허용치를 초과하지 않았는데도 로그아웃 후에  다시 로그인할 수가 없어요.](#동시-세션-제어-기능을-사용하려는데-세션-허용치를-초과하지-않았는데도-로그아웃-후에--다시-로그인할-수가-없어요)
    * [create-session 속성을 never로 설정했는데도 스프링 시큐리티 어딘가에서 세션을 만들고 있는 것 같아요.](#create-session-속성을-never로-설정했는데도-스프링-시큐리티-어딘가에서-세션을-만들고-있는-것-같아요)
    * [POST 요청을 보내면 403 Forbidden 응답을 받아요.](#post-요청을-보내면-403-forbidden-응답을-받아요)
    * [RequestDispatcher로 요청을 다른 URL로 포워딩하면 보안 제약 조건이 적용되지 않습니다.](#requestdispatcher로-요청을-다른-url로-포워딩하면-보안-제약-조건이-적용되지-않습니다)
    * [어플리케이션 컨텍스트에 스프링 시큐리티 \<global-method-security\> 요소를 추가했는데, 스프링 MVC 컨트롤러 빈에 보안 어노테이션을 달아도 (스트럿츠 action 등) 효과가 없는 것 같아요.](#어플리케이션-컨텍스트에-스프링-시큐리티-global-method-security-요소를-추가했는데-스프링-mvc-컨트롤러-빈에-보안-어노테이션을-달아도-스트럿츠-action-등-효과가-없는-것-같아요)
    * [분명히 사용자를 인증했는데, 요청을 처리하던 중에 SecurityContextHolder에 접근하면 Authentication 객체가 null입니다.](#분명히-사용자를-인증했는데-요청을-처리하던-중에-securitycontextholder에-접근하면-authentication-객체가-null입니다)
    * [JSP authorize 태그에 URL 속성을 사용하면 메소드 시큐리티 어노테이션을 지키지 않아요.](#jsp-authorize-태그에-url-속성을-사용하면-메소드-시큐리티-어노테이션을-지키지-않아요)
  + [22.7.3. Spring Security Architecture Questions](#2273-spring-security-architecture-questions)
    * [클래스 X가 어떤 패키지에 있는지 어떻게 알 수 있나요?](#클래스-x가-어떤-패키지에-있는지-어떻게-알-수-있나요)
    * [네임스페이스 요소는 어떤 방식으로 기존 빈 설정에 매핑되나요?](#네임스페이스-요소는-어떤-방식으로-기존-빈-설정에-매핑되나요)
    * ["ROLE_"이 의미하는 바는 무엇이며, role 이름에 추가해야 하는 이유는 뭔가요?](#role_이-의미하는-바는-무엇이며-role-이름에-추가해야-하는-이유는-뭔가요)
    * [어플리케이션에 스프링 시큐리티를 적용하려면 어떤 의존성이 필요한지는 어떻게 알 수 있나요?](#어플리케이션에-스프링-시큐리티를-적용하려면-어떤-의존성이-필요한지는-어떻게-알-수-있나요)
    * [임베디드 ApacheDS LDAP 서버를 실행하려면 어떤 의존성이 필요한가요?](#임베디드-apacheds-ldap-서버를-실행하려면-어떤-의존성이-필요한가요)
    * [UserDetailsService는 뭐고, 꼭 필요한 건가요?](#userdetailsservice는-뭐고-꼭-필요한-건가요)
  + [22.7.4. Common "Howto" Requests](#2274-common-howto-requests)
    * [로그인할 때 사용자 이름 말고 다른 정보도 함께 사용해야 합니다.](#로그인할-때-사용자-이름-말고-다른-정보도-함께-사용해야-합니다)
    * [요청 URL을 fragment 값으로 구분해서 다른 intercept-url 제약 조건을 적용하려면 어떻게 해야 하나요? (e.g. /foo#bar와  /foo#blah)](#요청-url을-fragment-값으로-구분해서-다른-intercept-url-제약-조건을-적용하려면-어떻게-해야-하나요-eg-foobar와--fooblah)
    * [UserDetailsService에서 사용자의 IP 주소나 다른 웹 요청 데이터에 접근하려면 어떻게 해야 되나요?](#userdetailsservice에서-사용자의-ip-주소나-다른-웹-요청-데이터에-접근하려면-어떻게-해야-되나요)
    * [UserDetailsService에서 HttpSession은 어떻게 접근하나요?](#userdetailsservice에서-httpsession은-어떻게-접근하나요)
    * [UserDetailsService에서 사용자의 비밀번호는 어떻게 접근하나요?](#userdetailsservice에서-사용자의-비밀번호는-어떻게-접근하나요)
    * [어플리케이션에서 보호할 URL을 동적으로 정의하려면 어떻게 해야 하나요?](#어플리케이션에서-보호할-url을-동적으로-정의하려면-어떻게-해야-하나요)
    * [인증은 LDAP으로 하고, 사용자 role은 데이터베이스에서 불러오려면 어떻게 해야 하나요?](#인증은-ldap으로-하고-사용자-role은-데이터베이스에서-불러오려면-어떻게-해야-하나요)
    * [네임스페이스로 생성한 빈의 프로퍼티를 수정하고 싶은데, 지원하는 스키마가 없습니다.](#네임스페이스로-생성한-빈의-프로퍼티를-수정하고-싶은데-지원하는-스키마가-없습니다)

---

## 22.7. Spring Security FAQ

- [흔히 하는 질문들](#2271-general-questions)
- [흔히 겪는 이슈들](#2272-common-problems)
- [스프링 시큐리티 아키텍처 관련 질문](#2273-spring-security-architecture-questions)
- [스프링 시큐리티 사용법 관련 질문](#2274-common-howto-requests)

### 22.7.1. General Questions

1. [스프링 시큐리티로 내 어플리케이션에서 필요한 모든 보안 처리를 다 할 수 있을까요?](#스프링-시큐리티로-내-어플리케이션에서-필요한-모든-보안-처리를-다-할-수-있을까요)
2. [그냥 web.xml security를 사용하는 것과 뭐가 다른가요?](#그냥-webxml-security를-사용하는-것과-뭐가-다른가요)
3. [자바랑 스프링 프레임워크는 어떤 버전을 사용해야 되나요?](#자바랑-스프링-프레임워크는-어떤-버전을-사용해야-되나요)
4. [스프링 시큐리티는 처음인데, HTTPS에서 CAS 싱글 사인온을 지원하는 어플리케이션을 만들어야 합니다. 특정 URL은 로컬에서 기본 인증을 적용하고, 여러 가지 백엔드 사용자 정보 소스로 (LDAP과 JDBC) 인증하려 합니다. 설정 파일들을 복사해왔는데 동작하지 않습니다.](#스프링-시큐리티는-처음인데-https에서-cas-싱글-사인온을-지원하는-어플리케이션을-만들어야-합니다-특정-url은-로컬에서-기본-인증을-적용하고-여러-가지-백엔드-사용자-정보-소스로-ldap과-jdbc-인증하려-합니다-설정-파일들을-복사해왔는데-동작하지-않습니다)

#### 스프링 시큐리티로 내 어플리케이션에서 필요한 모든 보안 처리를 다 할 수 있을까요?

스프링 시큐리티는 인증과 인가를 처리해주는 유연한 프레임워크지만, 이 범위를 벗어난 보안 처리가 필요한 어플리케이션에서는 추가로 고려해야 할 사항이 많이 있다. 웹 어플리케이션은 여러 가지 공격에 취약하며, 가급적 개발을 시작하기 전에 공격 유형을 익혀두면 미리 염두해두고 설계와 코딩을 시작할 수 있다. 웹 어플리케이션 개발자가 주로 겪는 이슈와 그에 따른 해결책을 자세히 알고 싶다면 [OWASP 웹사이트](http://www.owasp.org/)를 검토해 봐라.

#### 그냥 web.xml security를 사용하는 것과 뭐가 다른가요?

스프링 기반 엔터프라이즈 어플리케이션을 개발한다고 생각해보자. 보안과 관련해서 주로 생각해야 하는 주제는 인증, 웹 요청 보안, 서비스 레이어 보안 (i.e. 비지니스 로직을 구현한 메소드), 도메인 객체 인스턴스 보안 (i.e. 도메인 객체별로 permission이 다른 경우), 이렇게 네 가지다. 이 대표 요구사항을 기준으로 바라보면:

1. *인증*: 서블릿 스펙은 인증 방법을 제공한다. 하지만 보통 컨테이너 전용 "realm" 설정을 수정하는 식으로 인증을 설정해야 한다. 따라서 설정을 옮겨오기가 까다로우며, 실제로 자바 클래스로 컨테이너의 인증 인터페이스를 구현하려면 더 어려워진다. 스프링 시큐리티로는 이 한계를 완전히 극복할 수 있다 - 인증 로직을 WAR 레벨에 직접 작성한다. 게다가 스프링 시큐리티에선 프로덕션 레벨에서 입증된 인증 provider와 메커니즘을 선택 사용할 수 있기 때문에 배포 시점에 인증 방법을 전환하는 것도 가능하다. 이 기능은 타겟팅할 환경을 모른 채로 제품을 만들어야 하는 소프트웨어 벤더에 특히 가치있는 기능이다.
2. *웹 요청 보안:* 서블릿 스펙은 요청 URI를 보호할 수 있는 방법을 제시한다. 하지만 서블릿 스펙에 한정된 URI path 형식만 보호할 수 있다. 스프링 시큐리티는 좀 더 종합적인 방법을 제공한다. 예를 들어 Ant path나 정규식을 사용할 수 있으며, 요청 페이지 말고도 URI에 있는 다른 정보도 함께 고려할 수 있으며 (e.g. HTTP GET 파라미터), 설정 데이터를 런타임에 자체 소스에서 불러오도록 구현할 수 있다. 따라서 웹 어플리케이션이 실제로 실행 중일 때도 동적으로 웹 요청 보안 설정을 변경할 수 있다.
3. *서비스 레이어와 도메인 객체 보안:* 서블릿 스펙은 서비스 레이어 보안이나 도메인 객체 인스턴스 보안을 지원하지 않기 때문에 멀티 티어 어플리케이션에서는 불편한 점이 이만저만이 아니다. 보통 이런 요구사항을 무시하거나, MVC 컨트롤러 안에서 (더 최악인 경우 뷰에서) 보안 관련 로직을 구현할 수 밖에 없다. 이 구조에는 심각한 단점이 있다:
   - a. *관심사 분리:* 인가는 횡단 관심사이며, 비지니스 로직과 분리해서 구현해야 한다. MVC 컨트롤러나 뷰에서 인가 코드를 작성하면 컨트롤러와 인가 로직 모두 테스트하기 힘들고, 디버깅하기는 더 어려우며, 중복 코드가 생기기 마련이다.
   - b. *[리치 클라이언트](https://whatis.techtarget.com/definition/rich-client)와 웹 서비스 동시 지원:* 나중에 다른 클라이언트를 지원하게 되면 웹 레이어에 껴넣은 인가 코드를 재사용할 수 없다. 스프링 리모트 exporter는 서비스 레이어 빈만 (MVC 컨트롤러가 아니라) 내보내야 한다. 여러 가지 클라이언트 유형을 지원하려면 인가 로직은 서비스 레이어에 있어야 한다.
   - c. *레이어 설계 이슈:* MVC 컨트롤러나 뷰는, 아키텍처 레이어로써 서비스 레이어 메소드나 도메인 객체 인스턴스에 관한 권한 결정 로직을 구현하기엔 적합하지 않다. 서비스 레이어에 princial을 전달해서 권한을 결정할 순 있지만, 이렇게 하면 모든 서비스 레이어 메소드에 메소드 인자를 추가해야 한다. 좀 더 낫게는 ThreadLocal에 Principal을 저장할 수도 있지만, 결국엔 개발 시간이 늘어나기 때문에 단순히 전용 보안 프레임워크를 사용하는 게 더 경제적이다 (비용 편익 기준).
   - d. *인가 코드 품질:* 웹 프레임워크는 "올바른 일은 더 쉽게, 잘못된 일은 더 어렵게 만든다"는 말이 있다. 보안 프레임워크도 광범위한 목적을 추상화해 설계했기 때문에 마찬가지다. 인가 코드를 직접 처음부터 만들게 되면 프레임워크만큼 꼼꼼하게 설계하기는 어려우며, 사내에서 직접 인증 코드를 구현하면 보통 배포 범위 확장, 동료 리뷰, 버전 업데이트 등에 대한 지원이 부족할 수 밖에 없다.

간단한 어플리케이션이라면 서블릿 보안 스펙만으로도 충분할 수 있다. 하지만 웹 컨테이너 이식성과 설정 요구사항이나, 웹 요청 보안이 유연하지 않고 제한적이라는 점, 서비스 레이어와 도메인 인스턴스 보안이 없다는 점을 고려하면, 많은 개발자가 다른 솔루션을 찾는 이유를 알 수 있다.

#### 자바랑 스프링 프레임워크는 어떤 버전을 사용해야 되나요?

스프링 시큐리티 3.0과 3.1은 최소 JDK 1.5와 스프링 3.0.3 버전 이상이 필요하다. 이슈를 피하고 싶으면 최신 릴리즈 버전을 사용하는 게 좋다.

스프링 시큐리티 2.0.X는 최소한 JDK 1.4버전이 필요하며, 스프링 2.0.X를 사용한다. 스프링 2.5.X를 사용하는 어플리케이션과도 호환될 거다.

#### 스프링 시큐리티는 처음인데, HTTPS에서 CAS 싱글 사인온을 지원하는 어플리케이션을 만들어야 합니다. 특정 URL은 로컬에서 기본 인증을 적용하고, 여러 가지 백엔드 사용자 정보 소스로 (LDAP과 JDBC) 인증하려 합니다. 설정 파일들을 복사해왔는데 동작하지 않습니다.

뭐가 잘못된 걸까?

아니면 다른 복잡한 시나리오가 필요하다면...

현실적으로, 사용하려는 기술을 이해해야만 어플리케이션을 제대로 구축할 수 있다. 보안은 단순하지 않다. 스프링 시큐리티의 네임스페이스로 단순한 로그인 폼과 몇몇 사용자를 하드코딩하면 꽤 간단해진다. 지원하는 JDBC 데이터베이스로 전환하는 것도 쉽게 따라할 수 있다. 하지만 이같은 복잡한 배포 시나리오로 바로 넘어가려고 하면 대부분 좌절스러울 거다. CAS같은 시스템을 세팅하고, LDAP 서버를 설정하고, SSL 인증서를 적절히 설치하려면 필요한 학습 곡선이 가파르게 증가한다. 따라서 한 번에 하나씩 진행해야 한다.

스프링 시큐리티 관점에서 가장 먼저해야 할 일은 웹사이트에 있는 "Getting Started" 가이드를 따라하는 것이다. 이 가이드대로 따라면 몇 가지 단계를 통해 프레임워크의 동작 방식을 이해할 수 있다. 함께 사용하려는 또 다른 기술도 익숙하지 않다면, 복잡한 시스템에 결합하기 전에 앞서 해당 기술을 잘 알아보고 분리해서 사용할 수 있는지를 먼저 확인해야 한다.

### 22.7.2. Common Problems

1. 인증
   1. [로그인하려고 하면 "Bad Credentials"라는 에러 메세지를 반환합니다. 뭐가 문젠가요?](#로그인하려고-하면-bad-credentials라는-에러-메세지를-반환합니다-뭐가-문젠가요)
   2. [로그인하려고 하면 어플리케이션이 "무한 루프"에 빠집니다. 무슨 일일까요?](#로그인하려고-하면-어플리케이션이-무한-루프에-빠집니다-무슨-일일까요)
   3. ["Access is denied (user is anonymous);"라는 메세지와 함께 예외가 발생합니다. 뭐가 문젠가요?](#access-is-denied-user-is-anonymous라는-메세지와-함께-예외가-발생합니다-뭐가-문젠가요)
   4. [어플리케이션에서 로그아웃했는데도 어떻게 보호 중인 페이지를 계속 볼 수 있나요?](#어플리케이션에서-로그아웃했는데도-어떻게-보호-중인-페이지를-계속-볼-수-있나요)
   5. ["An Authentication object was not found in the SecurityContext"라는 메세지와 함께 예외가 발생합니다. 뭐가 문젠가요?](#an-authentication-object-was-not-found-in-the-securitycontext라는-메세지와-함께-예외가-발생합니다-뭐가-문젠가요)
   6. [LDAP 인증이 동작을 안해요.](#ldap-인증이-동작을-안해요)
2. 세션 관리
   1. [스프링 시큐리티의 동시 세션 제어 기능을 사용해서 같은 사용자가 동시에 로그인할 수 없도록 제한하려고 합니다.](#스프링-시큐리티의-동시-세션-제어-기능을-사용해서-같은-사용자가-동시에-로그인할-수-없도록-제한하려고-합니다)
   2. [스프링 시큐리티로 인증하면 왜 세션 ID가 바뀌나요?](#스프링-시큐리티로-인증하면-왜-세션-id가-바뀌나요)
   3. [톰캣을 사용 중인데 (또는 다른 서블릿 컨테이너), 로그인 페이지엔 HTTPS를 적용했고, 이후엔 HTTP를 사용해요.](#톰캣을-사용-중인데-또는-다른-서블릿-컨테이너-로그인-페이지엔-https를-적용했고-이후엔-http를-사용해요)
   4. [저는 HTTP와 HTTPS를 전환하지도 않는데 세션이 유실돼요.](#저는-http와-https를-전환하지도-않는데-세션이-유실돼요)
   5. [동시 세션 제어 기능을 사용하려는데, 세션 허용치를 초과하지 않았는데도 로그아웃 후에  다시 로그인할 수가 없어요.](#동시-세션-제어-기능을-사용하려는데-세션-허용치를-초과하지-않았는데도-로그아웃-후에--다시-로그인할-수가-없어요)
   6. [create-session 속성을 never로 설정했는데도 스프링 시큐리티 어딘가에서 세션을 만들고 있는 것 같아요.](#create-session-속성을-never로-설정했는데도-스프링-시큐리티-어딘가에서-세션을-만들고-있는-것-같아요)
3. 그 외 기타
   1. [POST 요청을 보내면 403 Forbidden 응답을 받아요.](#post-요청을-보내면-403-forbidden-응답을-받아요)
   2. [RequestDispatcher로 요청을 다른 URL로 포워딩하면 보안 제약 조건이 적용되지 않습니다.](#requestdispatcher로-요청을-다른-url로-포워딩하면-보안-제약-조건이-적용되지-않습니다)
   3. [어플리케이션 컨텍스트에 스프링 시큐리티 \<global-method-security\> 요소를 추가했는데, 스프링 MVC 컨트롤러 빈에 보안 어노테이션을 달아도 (스트럿츠 action 등) 효과가 없는 것 같아요.](#어플리케이션-컨텍스트에-스프링-시큐리티-global-method-security-요소를-추가했는데-스프링-mvc-컨트롤러-빈에-보안-어노테이션을-달아도-스트럿츠-action-등-효과가-없는-것-같아요)
   4. [분명히 사용자를 인증했는데, 요청을 처리하던 중에 SecurityContextHolder에 접근하면 Authentication 객체가 null입니다.](#분명히-사용자를-인증했는데-요청을-처리하던-중에-securitycontextholder에-접근하면-authentication-객체가-null입니다)
   5. [JSP authorize 태그에 URL 속성을 사용하면 메소드 시큐리티 어노테이션을 지키지 않아요.](#jsp-authorize-태그에-url-속성을-사용하면-메소드-시큐리티-어노테이션을-지키지-않아요)

#### 로그인하려고 하면 "Bad Credentials"라는 에러 메세지를 반환합니다. 뭐가 문젠가요?

인증에 실패했다는 뜻이다. 공격자가 계정 이름이나 비밀번호를 쉽게 예측할 수 없도록 상세 정보는 반환하지 않는 게 관행이기에, 이유는 말해주지 않는다.

그렇기 때문에 포럼에서 같은 질문을 해도 상세 정보를 주지 않는 한 답을 얻을 수 없을 거다. 다른 이슈와 마찬가지로 출력된 디버그 로그를 확인하고, 예외 스택트레이스와 관련 메시지에 주목해야 한다. 인증에 실패한 위치와 이유를 확인하려면 디버거로 코드를 단계별로 실행해 봐라. 어플리케이션 외부에서 인증 설정을 실행해보는 테스트 케이스를 작성해라. 인증에 실패한 경우 대개는 데이터베이스에 저장된 비밀번호와 사용자가 입력한 비밀번호가 일치하지 않아서다. 비밀번호를 해싱하고 있다면 데이터베이스에 저장된 값이 어플리케이션에 설정한 `PasswordEncoder`로 생성한 값과 *정확히* 일치하는지 확인해 봐라.

#### 로그인하려고 하면 어플리케이션이 "무한 루프"에 빠집니다. 무슨 일일까요?

무한 루프에 빠져서 계속해서 로그인 페이지로 리다이렉트하는 이슈는 보통 실수로 로그인 페이지를 "보호 중인" 리소스로 설정했을 때 발생한다. 로그인 페이지를 보안 필터에서 제외하거나 필요한 role을 ROLE_ANONYMOUS로 변경해서, 익명 상태로도 로그인 페이지에 접근할 수 있도록 설정해라.

AccessDecisionManager에서 AuthenticatedVoter를 사용하고 있다면, "IS_AUTHENTICATED_ANONYMOUSLY" 속성을 사용해도 된다. 이 voter는 표준 네임스페이스 설정을 사용하고 있다면 자동으로 추가된다.

스프링 시큐리티 2.0.1부터는, 네임스페이스 기반 설정을 사용한다면 어플리케이션 컨텍스트를 로드할 때 한 번 체크해서, 로그인 페이지를 보호하도록 설정해 놨으면 경고 메세지를 로깅한다.

#### "Access is denied (user is anonymous);"라는 메세지와 함께 예외가 발생합니다. 뭐가 문젠가요?

익명 사용자가 보호 중인 리소스에 처음으로 접근하려고 할때 발생하는 디버그 레벨 메세지다.

```java
DEBUG [ExceptionTranslationFilter] - Access is denied (user is anonymous); redirecting to authentication entry point
org.springframework.security.AccessDeniedException: Access is denied
at org.springframework.security.vote.AffirmativeBased.decide(AffirmativeBased.java:68)
at org.springframework.security.intercept.AbstractSecurityInterceptor.beforeInvocation(AbstractSecurityInterceptor.java:262)
```

이 메세지는 정상이며 전혀 걱정하지 않아도 된다.

#### 어플리케이션에서 로그아웃했는데도 어떻게 보호 중인 페이지를 계속 볼 수 있나요?

가장 흔한 원인은 브라우저의 캐시로, 브라우저 캐시에서 검색한 페이지 복사본을 보고 있는 것이다. 브라우저가 실제로 요청을 보내고 있는지 확인하면 확실히 알 수 있다 (서버 액세스 로그, 디버그 로그를 확인하거나 파이어폭스의 "Tamper Data"같은 적당한 브라우저 디버깅 플러그인 사용해라). 브라우저 캐시는 스프링 시큐리티와는 아무런 관련이 없으며, 어플리케이션이나 서버에 적절한 `Cache-Control` 응답 헤더를 설정해야 한다. 단, SSL 요청은 캐시하지 않는다.

#### "An Authentication object was not found in the SecurityContext"라는 메세지와 함께 예외가 발생합니다. 뭐가 문젠가요?

익명 사용자가 보호 중인 리소스에 처음으로 접근하려고 할때 발생하는 또 다른 디버그 레벨 메세지다. 이번엔 필터 체인 설정에 `AnonymousAuthenticationFilter`가 없기 때문에 발생한 예외다.

```java
DEBUG [ExceptionTranslationFilter] - Authentication exception occurred; redirecting to authentication entry point
org.springframework.security.AuthenticationCredentialsNotFoundException:
                            An Authentication object was not found in the SecurityContext
at org.springframework.security.intercept.AbstractSecurityInterceptor.credentialsNotFound(AbstractSecurityInterceptor.java:342)
at org.springframework.security.intercept.AbstractSecurityInterceptor.beforeInvocation(AbstractSecurityInterceptor.java:254)
```

이 메세지는 정상이며 전혀 걱정하지 않아도 된다.

#### LDAP 인증이 동작을 안해요.

뭐를 잘못 설정했을까요?

LDAP 디렉토리에 대한 permission은 보통 사용자 비밀번호의 조회 권한을 포함하지 않는다. 따라서 스프링 시큐리티의 [UserDetailsService](#userdetailsservice는-뭐고-꼭-필요한-건가요)로 사용자가 제출한 비밀번호와 저장된 비밀번호를 비교할 수 없다. [LDAP 프로토콜](https://en.wikipedia.org/wiki/Lightweight_Directory_Access_Protocol)이 지원하는 오퍼레이션 중 가장 많이는 LDAP "bind"를 사용한다. 이 오퍼레이션을 사용하면 스프링 시큐리티는 디렉토리로 사용자를 인증해서 비밀번호를 검증한다.

LDAP 인증에서 가장 많이 겪는 이슈는 디렉토리 서버 트리 구조와 설정을 잘 몰라서 발생한다. 구조와 설정은 회사마다 다르기 때문에 직접 확인해야 한다. 어플리케이션에 스프링 시큐리티 LDAP 설정을 추가하기 전에, 표준 자바 LDAP으로 (스프링 시큐리티 없이) 간단한 테스트 코드를 작성해서 먼저 잘 동작하는지 확인하는 게 좋다. 예를 들어 다음 코드를 사용해서 사용자를 인증해봐라:

```java
@Test
public void ldapAuthenticationIsSuccessful() throws Exception {
        Hashtable<String,String> env = new Hashtable<String,String>();
        env.put(Context.SECURITY_AUTHENTICATION, "simple");
        env.put(Context.SECURITY_PRINCIPAL, "cn=joe,ou=users,dc=mycompany,dc=com");
        env.put(Context.PROVIDER_URL, "ldap://mycompany.com:389/dc=mycompany,dc=com");
        env.put(Context.SECURITY_CREDENTIALS, "joespassword");
        env.put(Context.INITIAL_CONTEXT_FACTORY, "com.sun.jndi.ldap.LdapCtxFactory");

        InitialLdapContext ctx = new InitialLdapContext(env, null);

}
```

#### Session Management

포럼에서 흔히 세션 관리와 관련된 이슈를 묻곤 한다. 자바 웹 어플리케이션을 개발한다면 서블릿 컨테이너와 사용자의 브라우저 간 세션이 어떻게 관리되는지 이해해야 한다. 더불어 secure 쿠키와 일반 쿠키의 차이점과, HTTP/HTTPS를 사용하면 어떤게 달라지는지, 이 둘을 전환해가면서 사용하면 어떤 결과가 뒤따르는지도 이해하고 있어야 한다. 세션 관리나 세션 식별자 제공 기능은 스프링 시큐리티와는 무관하다. 이 기능은 전적으로 서블릿 컨테이너가 처리한다.

#### 스프링 시큐리티의 동시 세션 제어 기능을 사용해서 같은 사용자가 동시에 로그인할 수 없도록 제한하려고 합니다.

로그인한 후 브라우저 창을 하나 더 열었는데 로그인이 됩니다. 어떻게 여러 번 로그인할 수 있는건가요?

브라우저는 보통 브라우저 인스턴스 당 세션을 하나만 유지한다. 동시에 별도 세션을 두 개 생성할 수는 없다. 따라서 다른 브라우저 창이나 탭에서 다시 로그인하는 건 단순히 동일한 세션을 다시 인증하는 것이다. 서버에서는 탭이나, 브라우저 창, 브라우저 인스턴스에 관해서는 아무 것도 알 수 없다. 서버에서 알 수 있는 것은 HTTP 요청과, 해당 요청에 있는 JSESSIONID 쿠키에 따라 요청이 연결되어 있는 세션이 전부다. 같은 세션에서 사용자를 인증하면, 스프링 시큐리티의 동시 세션 제어 기능에선 해당 사용자가 *다른 세션으로도 인증했는지*만 확인한다. 동일한 세션에서 이미 인증했더라도, 재인증은 아무런 영향이 없다.

#### 스프링 시큐리티로 인증하면 왜 세션 ID가 바뀌나요?

스프링 시큐리티는 디폴트 설정에 따라 사용자를 인증하면 세션 ID를 변경한다. 서블릿 3.1이나 그 이상의 컨테이너를 사용하고 있다면 단순히 세션 ID만 변경한다. 구 버전 컨테이너에선 스프링 시큐리티는 기존 세션을 무효화하고, 새 새션을 만들어 세션 데이터를 새 세션으로 옮긴다. 이렇게 세션 식별자를 변경하면 "session-fixation" 공격을 방어할 수 있다. 자세한 내용은 웹 사이트를 검색해보거나 레퍼런스 매뉴얼을 참고해라.

#### 톰캣을 사용 중인데 (또는 다른 서블릿 컨테이너), 로그인 페이지엔 HTTPS를 적용했고, 이후엔 HTTP를 사용해요.

제대로 동작하지 않아요. 인증하고 나면 로그인 페이지로 다시 돌아갑니다.

HTTPS에서 생성한 세션은 세션 쿠키를 "secure"로 표기하므로, 이후 HTTP 요청에 사용할 수 없기 때문에 그렇다. 브라우저는 서버로 쿠키를 다시 전송하지 않고, 모든 세션 상태는 유실된다 (보안 컨텍스트 정보도 함께). 먼저 HTTP에서 세션을 만들면 세션 쿠키를 secure로 마킹하지 않기 때문에 제대로 동작할 거다. 하지만 스프링 시큐리티의 [session fixation 방어](../authentication#10113-session-fixation-attack-protection) 기능은 보통 secure 플래그를 가진 새 세션 ID 쿠키를 만들어 사용자의 브라우저로 다시 전송하기 때문에 유효한 것이다. session fixation 방어를 비활성화하면 이 문제를 해결할 순 있지만, 최신 버전 서블릿 컨테이너를 사용하면 세션 쿠키에 secure 플래그를 사용하지 않도록 설정할 수 있다. 하지만 HTTP를 사용하는 모든 어플리케이션은 중간자 공격(Man in the Middle attack)에 취약하기 때문에 HTTP와 HTTPS를 서로 전환하는 건 보통 좋은 방법이 아니다. 정말로 안전하려면 사용자가 처음 첩근하는 사이트도 HTTPS여야하고, 로그아웃할 때까지 계속 HTTPS를 유지해야 한다. 하물며 HTTP로 접근한 페이지에서 HTTPS 링크를 클릭하는 것도 보안 이슈가 잠재한다. 그래도 잘 모르겠다면 [sslstrip](https://directory.fsf.org/wiki/Sslstrip)같은 툴을 확인해 봐라.

#### 저는 HTTP와 HTTPS를 전환하지도 않는데 세션이 유실돼요.

세션은 세션 쿠키를 전달하거나 URL에 `jsessionid` 파라미터를 추가해야 유지된다 (JSTL로 URL을 출력하거나 리다이렉트 전 등에 `HttpServletResponse.encodeUrl`을 호출하면 자동으로 추가된다). 클라이언트에서 쿠키를 비활성화했다면, `jsessionid`를 추가해서 URL을 재작성하지 않으면 세션은 유실된다. 단, 주의할 점은 쿠키를 사용하면 URL에 세션 정보를 노출하지 않으므로, 보안 상으로는 쿠키를 사용하는 게 더 좋다.

#### 동시 세션 제어 기능을 사용하려는데, 세션 허용치를 초과하지 않았는데도 로그아웃 후에  다시 로그인할 수가 없어요.

web.xml 파일에 리스너를 추가했는지 확인해봐라. 세션을 무효화화면 반드시 스프링 시큐리티 세션 레지스트리에 통지해야 한다. 이 리스너를 등록하지 않으면 세션 레지스트리에서 세션 정보를 삭제하지 않는다.

```xml
<listener>
        <listener-class>org.springframework.security.web.session.HttpSessionEventPublisher</listener-class>
</listener>
```

#### create-session 속성을 never로 설정했는데도 스프링 시큐리티 어딘가에서 세션을 만들고 있는 것 같아요.

대개는 어플리케이션 어딘가에서 세션을 만들지만 모르고 있을 뿐이다. 범인은 주로 JSP다. JSP가 디폴트로 세션을 생성한다는 점을 모르고 있는 사람들이 많다. JSP에서 세션을 생성하지 않으려면 페이지 맨 위에 `<%@ page session="false" %>` 지시문을 추가해야 한다.

어디서 세션을 생성하는 건지 못 찾겠다면 디버깅 코드를 심어서 위치를 추적해봐라. 한 가지 방법은 어플리케이션에 `javax.servlet.http.HttpSessionListener`를 추가해서 `sessionCreated` 메소드 안에서 `Thread.dumpStack()`를 호출하는 것이다.

#### POST 요청을 보내면 403 Forbidden 응답을 받아요.

HTTP POST 메소드에서 403 Forbidden을 반환하는데, HTTP GET은 문제 없다면 보통은 [CSRF](../protectionagainstexploits#141-cross-site-request-forgery-csrf-for-servlet-environments) 관련 이슈다. 요청에 CSRF 토큰을 추가하거나, CSRF 방어를 비활성화해라 (이 방법은 추천하지 않는다).

#### RequestDispatcher로 요청을 다른 URL로 포워딩하면 보안 제약 조건이 적용되지 않습니다.

기본적으로 forward나 include에는 필터를 적용하지 않는다. 스프링 시큐리티를 꼭 forward나 include에도 적용해야 한다면, web.xml의 \<filter-mapping\> 하위에 \<dispatcher\> 요소를 사용해서 직접 명시해야 한다.

#### 어플리케이션 컨텍스트에 스프링 시큐리티 \<global-method-security\> 요소를 추가했는데, 스프링 MVC 컨트롤러 빈에 보안 어노테이션을 달아도 (스트럿츠 action 등) 효과가 없는 것 같아요.

스프링 웹 어플리케이션에선 보통, 디스패처 서블릿에서 처리할 스프링 MVC 빈이 있는 어플리케이션 컨텍스트과, 메인 어플리케이션 컨텍스트는 분리돼 있다. 보통 `myapp-servlet.xml`같은 파일로 정의한다. 여기서 "myapp"은 `web.xml`에서 스프링 `DispatcherServlet`에 할당한 이름이다. 어플리케이션은 별도의 어플리케이션 컨텍스트가 있는 `DispatcherServlet`을 여러 개 가질 수 있다. "자식" 컨텍스트에 있는 빈은 어플리케이션의 다른 자식 컨텍스트에선 접근할 수 없다. "부모" 어플리케이션 컨텍스트는 `web.xml`에 정의한 `ContextLoaderListener`가 로드하며, 모든 자식 컨텍스트에서 접근할 수 있다. 보통 이 부모 컨텍스트에 보안 설정을 정의한다 (`<global-method-security>` 요소도 마찬가지다). 결과적으로 `DispatcherServlet` 컨텍스트에서 빈을 볼 수 없기 때문에, 웹 빈의 메소드 적용한 보안 제약 조건은 아무런 효과가 없는 것이다. `<global-method-security>` 선언을 웹 컨텍스트로 옮기거나, 보호하려는 빈을 메인 어플리케이션 컨텍스트로 이동해야 한다.

메소드 시큐리티는 웹 컨트롤러에 각각 적용하기 보단, 서비스 레이어에 적용하기를 권장한다.

#### 분명히 사용자를 인증했는데, 요청을 처리하던 중에 SecurityContextHolder에 접근하면 Authentication 객체가 null입니다.

뭐 때문에 사용자 정보를 조회할 수 없나요?

URL 패턴과 일치하는 `<intercept-url>` 요소에 `filters='none'` 속성을 사용하면, 해당 요청을 보안 필터 체인에서 제외하며, 이때는 `SecurityContextHolder`에 값을 채우지 않는다. 디버그 로그를 통해 요청이 필터 체인에 전달되는 지 확인해 봐라 (디버그 로그는 읽고 있는가?).

#### JSP authorize 태그에 URL 속성을 사용하면 메소드 시큐리티 어노테이션을 지키지 않아요.

메소드 시큐리티는 `<sec:authorize>`에 `url` 속성을 사용하면 링크를 숨기지 않는다. 헤더나 현재 사용자같은 정보를 사용해 컨트롤러가 호출할 메소드를 결정할 수도 있기 때문에, 어떤 URL이 어떤 컨트롤러 엔드포인트에 매핑되는지 쉽게 리버스 엔지니어링할 수 없기 때문이다.

### 22.7.3. Spring Security Architecture Questions

1. [클래스 X가 어떤 패키지에 있는지 어떻게 알 수 있나요?](#클래스-x가-어떤-패키지에-있는지-어떻게-알-수-있나요)
2. [네임스페이스 요소는 어떤 방식으로 기존 빈 설정에 매핑되나요?](#네임스페이스-요소는-어떤-방식으로-기존-빈-설정에-매핑되나요)
3. ["ROLE_"이 의미하는 바는 무엇이며, role 이름에 추가해야 하는 이유는 뭔가요?](#role_이-의미하는-바는-무엇이며-role-이름에-추가해야-하는-이유는-뭔가요)
4. [어플리케이션에 스프링 시큐리티를 적용하려면 어떤 의존성이 필요한지는 어떻게 알 수 있나요?](#어플리케이션에-스프링-시큐리티를-적용하려면-어떤-의존성이-필요한지는-어떻게-알-수-있나요)
5. [임베디드 ApacheDS LDAP 서버를 실행하려면 어떤 의존성이 필요한가요?](#임베디드-apacheds-ldap-서버를-실행하려면-어떤-의존성이-필요한가요)
6. [UserDetailsService는 뭐고, 꼭 필요한 건가요?](#userdetailsservice는-뭐고-꼭-필요한-건가요)

#### 클래스 X가 어떤 패키지에 있는지 어떻게 알 수 있나요?

클래스 찾는 가장 좋은 방법은 IDE에서 스프링 시큐리티 소스를 다운받는 것이다. 프로젝트를 나눈 각 모듈의 소스 jar 파일도 함께 배포한다. 이 jar를 프로젝트 소스 path에 추가하면 스프링 시큐리티 클래스로 직접 이동할 수 있다 (이클립스에선 `Ctrl-Shift-T`). 디버깅도 더 쉬워지고, 트러블슈팅할 때도 예외가 발생한 코드를 직접 보고 무슨 일이 일어나는지 확인할 수 있다.

#### 네임스페이스 요소는 어떤 방식으로 기존 빈 설정에 매핑되나요?

레퍼런스 가이드에는 네임스페이스로 생성하는 빈에 대한 전반적인 개요를 다루는 부록이 있다. [blog.springsource.com](https://spring.io/blog/2010/03/06/behind-the-spring-security-namespace/)에는 "Behind the Spring Security Namespace"라는 자세한 블로그 글도 있다. 세부 사항을 전부 알고 싶다면, 코드는 스프링 시큐리티 3.0 배포판의 `spring-security-config` 모듈에 있다. 먼저 표준 스프링 프레임워크 레퍼런스 문서에서 네임스페이스 파싱 챕터를 읽어야 한다.

#### "ROLE_"이 의미하는 바는 무엇이며, role 이름에 추가해야 하는 이유는 뭔가요?

스프링 시큐리티는 일련의 `AccessDecisionVoter`로 접근을 결정하는, voter 기반 아키텍처를 사용한다. voter는 보호 중인 리소스에 (메소드 호출 등) 지정한 "설정 속성"에 따라 동작한다. 이 아키텍처에선 모든 voter가 모든 속성을 처리하는 것은 아니며, voter는 속성 값을 보고 이 속성을 무시할지 (기권), 또는 접근 권한 부여나 거부에 투표할지를 결정한다. 가장 일반적인 voter는 디폴트로 "ROLE\_" 프리픽스가 있는 속성을 찾으면 투표하는 `RoleVoter`다. `RoleVoter`는 간단히 속성을 ("ROLE_USER" 등) 현재 사용자에게 할당한 권한 이름과 비교한다. 일치하는 항목을 찾으면 ("ROLE_USER"라는 권한이 있으면) 접근 권한 부여에 투표하고, 그렇지 않으면 접근 거부에 투표한다.

프리픽스는 `RoleVoter`의 `rolePrefix` 프로퍼티로 바꿀 수 있다. 어플리케이션 내에서만 role을 사용하고 다른 커스텀 voter는 필요 없다면, 프로픽스를 빈 문자열로 설정해도 된다. 이렇게 하면 `RoleVoter`는 모든 속성을 role로 처리한다.

#### 어플리케이션에 스프링 시큐리티를 적용하려면 어떤 의존성이 필요한지는 어떻게 알 수 있나요?

사용 중인 기능과 개발 중인 어플리케이션에 따라 다르다. 스프링 시큐리티 3.0에서는 명확하게 구분되는 기능별로 프로젝트 jar를 나눠놨기 때문에 어플리케이션 요구사항에 필요한 스프링 시큐리티 jar를 쉽게 파악할 수 있다. `spring-security-core` jar는 모든 어플리케이션에 필요하다. 웹 어플리케이션을 개발한다면 `spring-security-web` jar가 필요하다. 시큐리티 네임스페이스 설정을 사용한다면 `spring-security-config` jar가, LDAP 지원을 위해서는 `spring-security-ldap` jar가 필요한 식이다.

서드 파티 jar는 매번 그렇게 깔끔하게 구분되진 않는다. 미리 빌드된 샘플 어플리케이션 중 하나에서 WEB-INF/lib 디렉토리를 복사해서 시작하는 것도 좋은 방법이다. 기본적인 어플리케이션은 튜토리얼 샘플로 시작할 수 있다. 임베디드 테스트 서버와 LDAP을 사용하려면 LDAP 샘플로 시작해봐라. 레퍼런스 매뉴얼에는 필수, 선택 여부와 함께 각 스프링 시큐리티 모듈의 일차적인 의존성을 정리한 [부록](../springsecuritydependencies#226-spring-security-dependencies)을 함께 제공한다.

프로젝트를 메이븐으로 빌드한다면, pom.xml에 적절한 스프링 시큐리티 모듈 의존성을 추가하면 프레임워크에 필요한 핵심 jar가 자동으로 받아진다. 스프링 시큐리티 POM 파일에서 "optional"로 표시된 모든 의존성은 필요할때 직접 pom.xml 파일에 추가해야 한다.

#### 임베디드 ApacheDS LDAP 서버를 실행하려면 어떤 의존성이 필요한가요?

메이븐을 쓰고 있다면 pom dependencies에 아래 의존성을 추가해야 한다:

```xml
<dependency>
        <groupId>org.apache.directory.server</groupId>
        <artifactId>apacheds-core</artifactId>
        <version>1.5.5</version>
        <scope>runtime</scope>
</dependency>
<dependency>
        <groupId>org.apache.directory.server</groupId>
        <artifactId>apacheds-server-jndi</artifactId>
        <version>1.5.5</version>
        <scope>runtime</scope>
</dependency>
```

이렇게 하면 다른 [전이 의존성](https://en.wikipedia.org/wiki/Transitive_dependency)도 함께 받아진다.

#### UserDetailsService는 뭐고, 꼭 필요한 건가요?

`UserDetailsService`는 사용자 계정에 따른 데이터를 불러오기 위한 DAO 인터페이스다. 사용자 데이터를 불러와서 프레임워크에 있는 다른 컴포넌트에 제공해 주는 기능 외에 다른 기능은 없다. 사용자 인증에는 관여하지 않는다. 가장 일반적인 사용자 이름/비밀번호 조합으로 사용자를 인증할 땐 `DaoAuthenticationProvider`를 사용한다. `DaoAuthenticationProvider`는 `UserDetailsService`를 주입받아 불러온 사용자 비밀번호를 (기타 데이터도 함께) 사용자가 제출한 값과 비교한다. LDAP을 사용한다면 이 방법은 [안 먹힐 거다](#ldap-인증이-동작을-안해요).

인증 처리를 커스텀하고 싶다면 직접 `AuthenticationProvider`를 구현해야 한다. 구글 앱 엔진과 스프링 시큐리티 인증을 통합하는 예제는 이 [블로그 문서](https://spring.io/blog/2010/08/02/spring-security-in-google-app-engine/)를 참고해라.

### 22.7.4. Common "Howto" Requests

1. [로그인할 때 사용자 이름 말고 다른 정보도 함께 사용해야 합니다.](#로그인할-때-사용자-이름-말고-다른-정보도-함께-사용해야-합니다)
2. [요청 URL을 fragment 값으로 구분해서 다른 intercept-url 제약 조건을 적용하려면 어떻게 해야 하나요? (e.g. /foo#bar와  /foo#blah)](#요청-url을-fragment-값으로-구분해서-다른-intercept-url-제약-조건을-적용하려면-어떻게-해야-하나요-eg-foobar와--fooblah)
3. [UserDetailsService에서 사용자의 IP 주소나 다른 웹 요청 데이터에 접근하려면 어떻게 해야 되나요?](#userdetailsservice에서-사용자의-ip-주소나-다른-웹-요청-데이터에-접근하려면-어떻게-해야-되나요)
4. [UserDetailsService에서 HttpSession은 어떻게 접근하나요?](#userdetailsservice에서-httpsession은-어떻게-접근하나요)
5. [UserDetailsService에서 사용자의 비밀번호는 어떻게 접근하나요?](#userdetailsservice에서-사용자의-비밀번호는-어떻게-접근하나요)
6. [어플리케이션에서 보호할 URL을 동적으로 정의하려면 어떻게 해야 하나요?](#어플리케이션에서-보호할-url을-동적으로-정의하려면-어떻게-해야-하나요)
7. [인증은 LDAP으로 하고, 사용자 role은 데이터베이스에서 불러오려면 어떻게 해야 하나요?](#인증은-ldap으로-하고-사용자-role은-데이터베이스에서-불러오려면-어떻게-해야-하나요)
8. [네임스페이스로 생성한 빈의 프로퍼티를 수정하고 싶은데, 지원하는 스키마가 없습니다.](#네임스페이스로-생성한-빈의-프로퍼티를-수정하고-싶은데-지원하는-스키마가-없습니다)

#### 로그인할 때 사용자 이름 말고 다른 정보도 함께 사용해야 합니다.

별도 로그인 필드는 어떻게 추가하나요 (e.g. 회사명)?

이 질문은 스프링 시큐리티 포럼에서 반복되는 질문이므로 아카이브를 (또는 구글로) 검색하면 더 많은 정보를 찾을 수 있다.

제출한 로그인 정보는 `UsernamePasswordAuthenticationFilter` 인스턴스가 처리한다. 다른 데이터 필드도 함께 처리하려면 이 클래스를 커스텀해야 한다. 한 가지 방법은 표준 `UsernamePasswordAuthenticationToken` 대신 커스텀한 인증 토큰 클래스를 사용하는 것이고, 단순히 추가할 필드를 사용자 이름과 연결해서 (예를 들어 ":"를 구분자로 사용해서) `UsernamePasswordAuthenticationToken`의 사용자 이름 프로퍼티에 전달해도 된다.

실제 인증 프로세스도 커스텀해야 한다. 예를 들어 커스텀 인증 토큰 클래스를 사용한다면 이 토큰을 처리하는 `AuthenticationProvider`를 만들어야 한다 (혹은 표준 `DaoAuthenticationProvider` 상속하거나). 필드를 구분자로 연결한다면, 이 필드를 분할해서 인증에 사용할 적절한 사용자 데이터를 불러올 자체 `UserDetailsService`를 구현할 수도 있다.

#### 요청 URL을 fragment 값으로 구분해서 다른 intercept-url 제약 조건을 적용하려면 어떻게 해야 하나요? (e.g. /foo#bar와  /foo#blah)

fragment는 브라우저에서 서버로 전송되는 값이 아니기 때문에 불가능하다. 서버 입장에서는 fragment가 달라도 동일한 URL이다. 이 질문은 GWT 사용자들이 자주 하는 질문이다.

#### UserDetailsService에서 사용자의 IP 주소나 다른 웹 요청 데이터에 접근하려면 어떻게 해야 되나요?

이 인터페이스에 제공하는 유일한 정보는 사용자 이름이기 때문에 당연히 불가능하다 (차선으로 스레드 로컬 변수같은 것을 사용하지 않으면). `UserDetailsService` 대신, `AuthenticationProvider` 자체를 구현해서 전해받은 `Authentication` 토큰에서 정보를 추출해야 한다.

표준 웹 설정에선 `Authentication` 객체의 `getDetails()` 메소드는 `WebAuthenticationDetails` 인스턴스를 반환한다. 다른 정보가 필요하다면 사용 중인 인증 필터에 커스텀 `AuthenticationDetailsSource`를 주입하면 된다. 예를 들어 네임스페이스에서 `<form-login>` 요소를 사용하고 있다면, 이 요소를 제거하고 커스텀 객체를 명시한 `UsernamePasswordAuthenticationFilter`를 가리키는 `<custom-filter>` 선언으로 바꿔야 한다.

#### UserDetailsService에서 HttpSession은 어떻게 접근하나요?

`UserDetailsService`는 서블릿 API에 대한 의존성이 없기 때문에 불가능하다. 커스텀 사용자 데이터를 저장하고 싶다면 `UserDetailsService`가 반환하는 `UserDetails` 객체를 커스텀해야 한다. 이 객체는 스레드 로컬을 사용하는 `SecurityContextHolder`를 통해 어디서든 접근할 수 있다. `SecurityContextHolder.getContext().getAuthentication().getPrincipal()`을 호출하면 커스텀 객체를 리턴할 거다.

그래도 꼭 세션에 접근해야 한다면, 웹 티어를 커스텀해야 한다.

#### UserDetailsService에서 사용자의 비밀번호는 어떻게 접근하나요?

불가능하다 (접근해선 안 된다). 이 인터페이스를 잘못 알고 있는 듯 하다. 위에 있는 "[UserDetailsService는 뭐고, 꼭 필요한 건가요?](#userdetailsservice는-뭐고-꼭-필요한-건가요)"를 읽어 봐라.

#### 어플리케이션에서 보호할 URL을 동적으로 정의하려면 어떻게 해야 하나요?

종종 보호할 URL과 시큐리티 메타데이터 속성의 매핑 정보를 어플리케이션 컨텍스트가 아닌 데이터베이스에 저장하는 방법에 대해 질문하곤 한다.

가장 먼저 이게 정말로 필요한 건지 다시 한 번 생각해 봐라. 어플리케이션을 보호해야 한다면, 정의된 정책을 기반으로 철저히 보안 기능을 테스트해봐야 한다. 프로덕션 환경으로 배포하기 전에 감사와 승인 테스트가 필요할 수도 있다. 보안에 민감한 조직이라면, 설정 데이터베이스에서 한두 행을 변경해서 런타임에 보안 설정을 수정할 수 있도록 만드는 즉시, 애써 일군 테스트 프로세스를 활용할 수 없다는 점을 알아야 한다. 이 점을 고려했는데도 동적인 설정이 필요하다면 (아마도 어플리케이션 내에 보안 레이어를 여러 개 사용하는 경우), 스프링 시큐리티로 보안 메타데이터 소스를 완전히 커스텀하면 된다. 원한다면 완전히 동적으로 만들 수도 있다.

메소드 시큐리티와 웹 보안 모두, `AbstractSecurityInterceptor`를 상속한 클래스가 보호해 준다. 이 인터셉터는 설정해둔 `SecurityMetadataSource`로 특정 메소드나 필터 호출에 대한 메타데이터를 가져온다. 웹 보안에선 인터셉터 클래스는 `FilterSecurityInterceptor`이며, 마커 인터페이스 `FilterInvocationSecurityMetadataSource`를 사용한다. 작동하는 "보호 객체" 타입은 `FilterInvocation`이다. 디폴트로 사용하는 구현체는 (네임스페이스 `<http>`나 명시적으로 인터셉터를 설정했을 때 모두) 인메모리 맵에 URL 패턴 리스트와 그에 해당하는 "설정 속성" (`ConfigAttribute` 인스턴스) 리스트를 저장한다.

다른 소스에서 데이터를 로드하려면 명시적으로 선언한 보안 필터 체인을 (일반적으로 스프링 시큐리티의 `FilterChainProxy`) 사용해서 `FilterSecurityInterceptor` 빈을 커스텀해야 한다. 네임스페이스는 사용할 수 없다. 그다음 `FilterInvocationSecurityMetadataSource`를 구현해서 `FilterInvocation`에 따라 원하는대로 데이터를 불러오면 된다. 기본적인 개요는 다음과 같다:

```java
public class MyFilterSecurityMetadataSource implements FilterInvocationSecurityMetadataSource {

    public List<ConfigAttribute> getAttributes(Object object) {
        FilterInvocation fi = (FilterInvocation) object;
        String url = fi.getRequestUrl();
        String httpMethod = fi.getRequest().getMethod();
        List<ConfigAttribute> attributes = new ArrayList<ConfigAttribute>();

        // Lookup your database (or other source) using this information and populate the
        // list of attributes

        return attributes;
    }

    public Collection<ConfigAttribute> getAllConfigAttributes() {
        return null;
    }

    public boolean supports(Class<?> clazz) {
        return FilterInvocation.class.isAssignableFrom(clazz);
    }
}
```

좀 더 자세한 정보는 `DefaultFilterInvocationSecurityMetadataSource` 코드를 확인해 봐라.

#### 인증은 LDAP으로 하고, 사용자 role은 데이터베이스에서 불러오려면 어떻게 해야 하나요?

`LdapAuthenticationProvider` 빈은 (스프링 시큐리티에서 일반적인 LDAP 인증을 처리하는 빈) 별도의 두 가지 전략 인터페이스로 설정한다. 하나는 인증을 수행하는 `LdapAuthenticator`, 다른 하나는 사용자 권한을 불러오는 `LdapAuthoritiesPopulator`다. `DefaultLdapAuthoritiesPopulator`는 LDAP 디렉토리에서 사용자 권한을 불러오며, 권한을 조회하는 방법을 지정할 수 있는 여러 가지 설정 파라미터를 받는다.

LDAP 디렉토리 대신 JDBC를 사용하라면, 스키마에 필요한 적당한 SQL을 사용해서 이 인터페이스를 직접 구현하면 된다:

```java
public class MyAuthoritiesPopulator implements LdapAuthoritiesPopulator {
    @Autowired
    JdbcTemplate template;

    List<GrantedAuthority> getGrantedAuthorities(DirContextOperations userData, String username) {
        List<GrantedAuthority> = template.query("select role from roles where username = ?",
                                                                                                new String[] {username},
                                                                                                new RowMapper<GrantedAuthority>() {
            /**
             *  We're assuming here that you're using the standard convention of using the role
             *  prefix "ROLE_" to mark attributes which are supported by Spring Security's RoleVoter.
             */
            public GrantedAuthority mapRow(ResultSet rs, int rowNum) throws SQLException {
                return new SimpleGrantedAuthority("ROLE_" + rs.getString(1);
            }
        }
    }
}
```

그다음 이 빈을 어플리케이션 컨텍스트에 추가하고 `LdapAuthenticationProvider`에 주입해라. 이 내용은 레퍼런스 매뉴얼 LDAP 챕터에서 스프링 빈을 명시해서 LDAP을 설정하는 방법을 설명하면서 함께 다룬다. 이때는 네임스페이스로 설정할 수 없다. 관련 클래스와 인터페이스의 Javadoc도 참고해야 한다.

#### 네임스페이스로 생성한 빈의 프로퍼티를 수정하고 싶은데, 지원하는 스키마가 없습니다.

네임스페이스를 포기하고 싶진 않은데, 어떻게 해야 하나요?

네임스페이스 기능은 의도적으로 제한했으며, 일반적인 빈으로 할 수 있는 모든 작업을 지원하진 않는다. 빈을 수정하거나 다른 의존성을 주입하는 것같은 간단한 작업은 설정에 `BeanPostProcessor`를 추가하면 된다. 자세한 정보는 [스프링 레퍼런스 매뉴얼](https://docs.spring.io/spring/docs/3.0.x/spring-framework-reference/htmlsingle/spring-framework-reference.html#beans-factory-extension-bpp)에서 확인할 수 있다. `BeanPostProcessor`를 사용하려면 어떤 빈을 생성하는지도 조금은 알고 있어야 하므로, 위에 있는 질의응답 [네임스페이스 요소는 어떤 방식으로 기존 빈 설정에 매핑되나요?](#네임스페이스-요소는-어떤-방식으로-기존-빈-설정에-매핑되나요)에 있는 블로그 문서도 읽어볼 필요가 있다.

보통은 `BeanPostProcessor`의 `postProcessBeforeInitialization` 메소드에 필요한 기능을 추가한다. `UsernamePasswordAuthenticationFilter`(`form-login` 요소로 생성된)에서 사용하는 `AuthenticationDetailsSource`를 커스텀한다고 가정해 보자. 요청에서 추출한 `CUSTOM_HEADER` 헤더를 사용자 인증에 사용해 보겠다. 이때 processor 클래스는 다음과 같다:

```java
public class BeanPostProcessor implements BeanPostProcessor {

        public Object postProcessAfterInitialization(Object bean, String name) {
                if (bean instanceof UsernamePasswordAuthenticationFilter) {
                        System.out.println("********* Post-processing " + name);
                        ((UsernamePasswordAuthenticationFilter)bean).setAuthenticationDetailsSource(
                                        new AuthenticationDetailsSource() {
                                                public Object buildDetails(Object context) {
                                                        return ((HttpServletRequest)context).getHeader("CUSTOM_HEADER");
                                                }
                                        });
                }
                return bean;
        }

        public Object postProcessBeforeInitialization(Object bean, String name) {
                return bean;
        }
}
```

이제 어플리케이션에 이 빈을 등록하면 된다. 스프링이 알아서 어플리케이션 컨텍스트에 정의한 빈에서 이 데이터소스를 실행한다.