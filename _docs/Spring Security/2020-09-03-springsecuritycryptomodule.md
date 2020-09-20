---
title: Spring Security Crypto Module
category: Spring Security
order: 21
permalink: /Spring%20Security/springsecuritycryptomodule/
description: 스프링 시큐리티 암호화(Crypto) 모듈을 소개합니다. 공식 문서에 있는 "Spring Security Crypto Module" 챕터를 한글로 번역한 문서입니다.
image: ./../../images/springsecurity/spring-security.png
lastmod: 2020-09-20T23:18:12+09:00
comments: true
originalRefName: 스프링 시큐리티
originalRefLink: https://docs.spring.io/spring-security/site/docs/5.3.2.RELEASE/reference/html5/#crypto
---

### 목차:

- [20.1. Introduction](#201-introduction)
- [20.2. Encryptors](#202-encryptors)
  + [20.2.1. BytesEncryptor](#2021-bytesencryptor)
  + [20.2.2. TextEncryptor](#2022-textencryptor)
- [20.3. Key Generators](#203-key-generators)
  + [20.3.1. BytesKeyGenerator](#2031-byteskeygenerator)
  + [20.3.2. StringKeyGenerator](#2032-stringkeygenerator)
- [20.4. Password Encoding](#204-password-encoding)

---

## 20.1. Introduction

스프링 시큐리티 Crypto 모듈은 대칭 암호화, 키 생성, 비밀번호 인코딩을 지원한다. 코드는 코어 모듈과 함께 배포하지만, 다른 스프링 시큐리티 (또는 스프링) 코드에 대한 의존성이 없다.

---

## 20.2. Encryptors

Encryptors 클래스는 대칭 encryptor를 생성하는 팩토리 메소드를 제공한다. 이 클래스로 데이터를 저수준 byte[] 형식으로 암호화하는 ByteEncryptor를 만들 수 있다. TextEncryptor를 만들어서 텍스트 문자열을 암호화할 수도 있다. Encryptor는 thread-safe하다.

### 20.2.1. BytesEncryptor

BytesEncryptor를 생성할 땐 팩토리 메소드 `Encryptors.stronger`를 사용한다:

```java
Encryptors.stronger("password", "salt");
```

"stronger" 암호화 메소드는 256 비트 AES 암호화 방식과  Galois Counter Mode(GCM)를 사용해서 encryptor를 만든다. 이 클래스는 PKCS #5의 PBKDF2로 비밀키를 생성한다. 이 메소드는 자바 6이 필요하다. 비밀키를 만들 때 사용하는 비밀번호는 안전한 곳에 보관해야 하며 다른 곳에 공유하면 안 된다. 솔트는 암호화한 데이터가 손상됐을 때 키에 대한 사전 공격(dictionary attack)을 방지하기 위해 사용한다. 16 바이트 랜덤 초기화 벡터를 함께 사용하므로 각 암호화된 메세지는 유니크하다.

솔트는 16진수로 인코딩한 랜덤 문자열로 제공해야 하며, 길이는 최소 8 바이트 이상이어야 한다. 솔트는 KeyGenerator로 만들 수 있다:

```java
String salt = KeyGenerators.string().generateKey(); // generates a random 8-byte salt that is then hex-encoded
```

원한다면 Cipher Block Chaining(CBC) 모드에서 256 비트 AES를 사용하는 `standard` 메소드를 사용할 수도 있다. 이 모드는 [인증](https://en.wikipedia.org/wiki/Authenticated_encryption)되지 않았으며 데이터의 진위 여부를 보장하지 않는다. 보다 안전하게 `Encryptors.stronger`를 사용하는 게 좋다.

### 20.2.2. TextEncryptor

표준 TextEncryptor를 생성할 땐 팩토리 메소드 Encryptors.text를 사용한다:

```java
Encryptors.text("password", "salt");
```

TextEncryptor는 표준 BytesEncryptor로 텍스트 데이터를 암호화한다. 암호화한 결과는 파일 시스템이나 데이터베이스에 쉽게 저장할 수 있도록 16진수로 인코딩한 문자열로 반환한다.

"질의할 수 있는" TextEncryptor를 생성할 땐 팩토리 메소드 Encryptors.queryableText를 사용한다:

```java
Encryptors.queryableText("password", "salt");
```

질의할 수 있는 TextEncryptor와 표준 TextEncryptor의 차이는 초기화 벡터(iv) 처리와 관련 있다. 질의할 수 있는 TextEncryptor#encrypt 연산에 사용하는 iv는 공유하거나 고정된 값이며, 무작위로 생성하지 않는다. 즉, 같은 텍스트를 여러 번 암호화하면 항상 동일한 결과를 만든다. 이는 덜 안전하지만 암호화 데이터를 질의해야 할 때 필요하다. 질의 가능한 암호화 텍스트의 예로는 OAuth apiKey가 있다.

---

## 20.3. Key Generators

KeyGenerators 클래스는 다양한 키 generator를 만들 수 있는 여러 가지 편리한 팩토리 메소드를 제공한다. 이 클래스를 사용하면 byte[] 키를 생성하는 BytesKeyGenerator를 만들 수 있다. StringKeyGenerator로 문자열 키를 생성할 수도 있다. KeyGenerator는 thread-safe하다.

### 20.3.1. BytesKeyGenerator

SecureRandom 인스턴스를 사용하는 BytesKeyGenerator를 만들 땐 팩토리 메소드 KeyGenerators.secureRandom을 사용한다:

```java
BytesKeyGenerator generator = KeyGenerators.secureRandom();
byte[] key = generator.generateKey();
```

키 길이는 디폴트로 8 바이트를 사용한다. 키 길이를 지정하고 싶을 땐 다른 KeyGenerators.secureRandom 메소드를 사용하면 된다:

```java
KeyGenerators.secureRandom(16);
```

항상 동일한 키를 리턴하는 BytesKeyGenerator를 만들 땐 팩토리 메소드 KeyGenerators.shared를 사용한다:

```java
KeyGenerators.shared(16);
```

### 20.3.2. StringKeyGenerator

각 키를 16진수 문자열로 인코딩하는 8 바이트 SecureRandom KeyGenerator를 만들 땐 팩토리 메소드 KeyGenerators.string을 사용한다:

```java
KeyGenerators.string();
```

---

## 20.4. Password Encoding

spring-security-crypto 모듈의 password 패키지엔 비밀번호 인코딩을 지원하는 클래스가 있다. 핵심 서비스 인터페이스는 `PasswordEncoder`로, 메소드 시그니처는 다음과 같다:

```java
public interface PasswordEncoder {

String encode(String rawPassword);

boolean matches(String rawPassword, String encodedPassword);
}
```

matches 메소드는 rawPassword를 한 번 인코딩한 값이 encodingPassword와 동일하면 true를 반환한다. 이 메소드는 비밀번호 기반 인증 스킴을 지원하도록 설계했다.

`BCryptPasswordEncoder` 구현체는 널리 사용되고 있는 "bcrypt" 알고리즘으로 비밀번호를 해싱한다. bcrypt는 랜덤 16 바이트 솔트 값을 사용하며, 패스워드 크래킹을 방지하기 위해 의도적으로 느리게 동작하는 알고리즘이다. 작업량은 "strength" 파라미터로 조정할 수 있으며 사용할 수 있는 값은 4~31 사이다. 값이 클수록 해시값 계산을 위해 더 많은 작업을 수행해야 한다. 디폴트는 10이다. 이 값은 인코딩한 해시에 함께 저장되므로 기존에 배포한 시스템에서도 비밀번호에 영향 없이 이 값을 변경할 수 있다.

```java
// Create an encoder with strength 16
BCryptPasswordEncoder encoder = new BCryptPasswordEncoder(16);
String result = encoder.encode("myPassword");
assertTrue(encoder.matches("myPassword", result));
```

`Pbkdf2PasswordEncoder` 구현체는 PBKDF2 알고리즘으로 비밀번호를 해싱한다. PBKDF2는 패스워드 크래킹을 방지하기 위해 의도적으로 느리게 동작하는 알고리즘이며, 시스템에서 비밀번호 하나를 검증하는 데 0.5초가량 걸리도록 설정해야 한다.

```java
// Create an encoder with all the defaults
Pbkdf2PasswordEncoder encoder = new Pbkdf2PasswordEncoder();
String result = encoder.encode("myPassword");
assertTrue(encoder.matches("myPassword", result));
```
