---
title: Serving Alternative Formats
category: Spring Cloud Config
order: 4
permalink: /Spring%20Cloud%20Config/serving-alternative-formats/
description: 스프링 클라우드 컨피그에서 설정 정보를 디폴트 Json(Environment) 타입 외 yaml, properties 포맷으로 서빙하기
image: ./../../images/springcloud/logo.jpeg
lastmod: 2021-03-31T22:00:00+09:00
comments: true
originalRefName: 스프링 클라우드 컨피그
originalRefLink: https://docs.spring.io/spring-cloud-config/docs/3.0.3/reference/html/#_serving_alternative_formats
---

---

environment 엔드포인트에서 사용하는 디폴트 JSON 포맷은 `Environment` 클래스에 직접 매핑되기 때문에, 스프링 어플리케이션에서 사용하기에 최적이다. 하지만 원한다면 리소스 패스에 suffix(".yml", ".yaml", ".properties" 등)를 추가해서 YAML이나 자바 프로퍼티 데이터를 그대로 컨슘할 수 있다. JSON 엔드포인트 구조나 엔드포인트에서 추가로 제공하는 메타데이터는 관심 없는 어플리케이션에선 요긴할 거다 (예를 들어, 스프링을 사용하지 않는 어플리케이션은 이 방식을 쓰는게 더 간단하다).

YAML과 properties 표현에는 렌더링하기 전 가능한 곳에서 소스 document에 있는 플레이스홀더(표준 스프링 `${…}` 형식)를 리졸브해서 출력해야 함을 알리는 별도의 플래그가 있다 (`resolvePlaceholders`라는 boolean 쿼리 파라미터로 제공한다). 스프링 플레이스홀더 컨벤션을 알지 못하는 컨슈머에 유용할 거다.

> YAML이나 properties 포맷을 사용할 땐 제약이 따르는데, 주로 메타데이터 손실과 관련해서다. 예를 들어 JSON 구조에선 프로퍼티 소스를 소스와 관련있는 name과 함께 정렬해서 응답한다. 하지만 YAML과 properties 형식에선 값들의 출처 소스가 여러 개라 하더라도 단일 맵으로 통합돼서 원본 소스의 파일명을 알아낼 수 없다. 더불어 YAML 표현이 뒷단의 레포지토리에 있는 YAML 소스를 그대로 표현했다는 보장은 없다. YAML 표현은 flat 프로퍼티 소스 리스트를 가지고 구성되며, flat한 키 형태를 가정하고 만들어진다.
