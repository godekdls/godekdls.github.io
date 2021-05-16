---
title: RXJAVA2 Getting Started
navTitle: Getting Started
category: Resilience4j
order: 19
permalink: /Resilience4j/rxjava2-getting-started/
description: RxJava2 전용 연산자를 제공하는 resilience4j-rxjava2 모듈 소개
image: ./../../images/resilience4j/logo.png
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: resilience4j
originalRefLink: https://resilience4j.readme.io/v1.7.0/docs/getting-started-2
boundary: RXJAVA2
---

---

Resilience4j는 커스텀 RxJava2 연산자를 전용 모듈로 제공한다. 이 연산자들은 다운스트림 subscriber/observer가 업스트림 Publisher를 구독할 수 있는 권한을 얻을 수 있는지 확인해준다. 리액티브 타입 `Observable`, `Flowable`, `Single`, `Maybe`, `Completable`을 지원한다.

이 모듈은 런타임에 `io.reactivex.rxjava2:rxjava`를 제공해준다고 가정한다. RxJava2는 전이 의존성이 아니다.

```gradle
repositories {
    jCenter()
}

dependencies {
  compile "io.github.resilience4j:resilience4j-rxjava2:${resilience4jVersion}"
}
```