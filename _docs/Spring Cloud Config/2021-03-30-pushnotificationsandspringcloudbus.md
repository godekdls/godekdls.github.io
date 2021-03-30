---
title: Push Notifications and Spring Cloud Bus
category: Spring Cloud Config
order: 7
permalink: /Spring%20Cloud%20Config/push-notifications-and-spring-cloud-bus/
description: 웹훅을 통해 설정 레포지토리의 변경 이벤트를 자동으로 전파하기
image: ./../../images/springcloud/logo.jpeg
lastmod: 2021-03-31T22:00:00+09:00
comments: true
originalRefName: 스프링 클라우드 컨피그
originalRefLink: https://docs.spring.io/spring-cloud-config/docs/3.0.3/reference/html/#_push_notifications_and_spring_cloud_bus
---

---

많은 소스 코드 레포지토리 provider는 웹훅을 통해 레포지토리의 변경 사항을 알려준다 (ex. Github, Gitlab, Gitea, Gitee, Gogs, Bitbucket 등). 이런 웹훅은 provider의 사용자 인터페이스를 통해 URL과 관심있는 이벤트 셋으로 구성할 수 있다. 예를 들어 [Github](https://developer.github.com/v3/activity/events/types/#pushevent)는 웹훅에 커밋 목록을 가진 JSON body와 `push`로 설정된 헤더(`X-Github-Event`)를 담아 POST 요청을 보낸다. 컨피그 서버에 `spring-cloud-config-monitor` 라이브러리 의존성을 추가하고 Spring Cloud Bus를 활성화하면 `/monitor` 엔드포인트가 활성화된다.

웹훅을 활성화하면 컨피그 서버는 변경 사항이 생긴 걸로 보이는 어플리케이션을 대상으로 `RefreshRemoteApplicationEvent`를 전송한다. 변경 사항을 감지하는 전략은 요구사항에 따라 커스텀할 수 있다. 하지만 기본적으로는 어플리케이션명과 일치하는 파일에서 변경 사항을 찾는다 (예를 들어 `foo.properties`는 `foo` 어플리케이션이 타겟이고, `application.properties`는 모든 어플리케이션이 타겟이다). 이 동작을 재정의하고 싶다면 요청 헤더와 body를 인자로 받아 변경된 파일 경로 목록을 반환하는 `PropertyPathNotificationExtractor`를 사용하면 된다.

Github, Gitlab, Gitea, Gitee, Gogs, Bitbucket에선 기본 설정을 즉시 사용할 수 있다. Github, Gitlab, Gitee, Bitbucket의 JSON 알림 외에도, `/monitor`에 `path={application}` 패턴으로 form-encoded body 파라미터를 넣어 POST 요청을 보내면 변경 알림을 트리거할 수 있다. 이렇게 하면 `{application}` 패턴과 일치하는 어플리케이션에 브로드캐스트된다 (와일드카드도 사용할 수 있다).

> `RefreshRemoteApplicationEvent`는 컨피그 서버와 클라이언트 어플리케이션 양쪽 다 `spring-cloud-bus`를 활성화했을 때만 전송된다.

> 기본 설정은 로컬 git 레포지토리의 파일시스템 변경도 감지한다. 이땐 웹훅을 사용하지 않는다. 하지만 설정 파일을 편집하는 즉시 refresh를 브로드캐스트한다.
