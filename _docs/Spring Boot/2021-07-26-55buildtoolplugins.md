---
title: Build Tool Plugins
category: Spring Boot 2.X
order: 55
permalink: /Spring%20Boot/build-tool-plugins/
description: 스프링 부트 메이븐/그래들 플러그인을 통해 executable jar 생성하기
image: ./../../images/springboot/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 부트
originalRefLink: https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#build-tool-plugins
priority: 0.4
---

### 목차

- [11.1. Spring Boot Maven Plugin](#111-spring-boot-maven-plugin)
- [11.2. Spring Boot Gradle Plugin](#112-spring-boot-gradle-plugin)
- [11.3. Spring Boot AntLib Module](#113-spring-boot-antlib-module)
  + [11.3.1. Spring Boot Ant Tasks](#1131-spring-boot-ant-tasks)
    * [Using the “exejar” Task](#using-the-exejar-task)
    * [Examples](#examples)
  + [11.3.2. Using the “findmainclass” Task](#1132-using-the-findmainclass-task)
    * [Examples](#examples-1)
- [11.4. Supporting Other Build Systems](#114-supporting-other-build-systems)
  + [11.4.1. Repackaging Archives](#1141-repackaging-archives)
  + [11.4.2. Nested Libraries](#1142-nested-libraries)
  + [11.4.3. Finding a Main Class](#1143-finding-a-main-class)
  + [11.4.4. Example Repackage Implementation](#1144-example-repackage-implementation)
- [11.5. What to Read Next](#115-what-to-read-next)

---

스프링 부트는 메이븐과 그래들을 위한 빌드 툴 플러그인을 제공한다. 플러그인에선 실행 가능한<sup>executable</sup> jar 패키징을 포함한 다양한 기능들을 제공한다. 이번 섹션에선 이 두 가지 플러그인을 자세히 살펴보고, 지원되지 않는 빌드 시스템을 확장할 때 필요한 몇 가지 팁을 제공한다. 스프링 부트를 이제 막 시작했다면 “[스프링 부트로 애플리케이션 개발하기](../developing-with-spring-boot)” 섹션에서  “[빌드 시스템](../developing-with-spring-boot#61-build-systems)”을 먼저 읽어보고 오는 게 좋다.

---

## 11.1. Spring Boot Maven Plugin

스프링 부트 메이븐 플러그인은 메이븐으로 스프링 부트 애플리케이션을 개발하는 것을 도와준다. 덕분에 실행 가능한<sup>executable</sup> jar나 war 아카이브를 패키징하고, 애플리케이션을 "그 자리에서" 바로 실행할 수 있다. 이 플러그인을 이용하려면 메이븐 3.2 이상이 필요하다.

좀 더 자세히 알아보려면 플러그인의 문서를 참고해라:

- 레퍼런스 ([HTML](https://docs.spring.io/spring-boot/docs/2.5.2/maven-plugin/reference/htmlsingle/), [PDF](https://docs.spring.io/spring-boot/docs/2.5.2/maven-plugin/reference/pdf/spring-boot-maven-plugin-reference.pdf))
- [API](https://docs.spring.io/spring-boot/docs/2.5.2/maven-plugin/api/)

---

## 11.2. Spring Boot Gradle Plugin

스프링 부트 그래들 플러그인은 그래들로 스프링 부트 애플리케이션을 개발하는 것을 도와준다. 덕분에 실행 가능한<sup>executable</sup> jar나 war 아카이브를 패키징하고, 스프링 부트 애플리케이션을 실행하고, `spring-boot-dependencies`에서 제공하는 의존성 관리를 이용할 수 있다. 이 플러그인을 사용하려면 그래들 6.8이나, 6.9, 7.x가 필요하다. 좀 더 자세히 알아보려면 플러그인의 문서를 참고해라:

- 레퍼런스 ([HTML](https://docs.spring.io/spring-boot/docs/2.5.2/gradle-plugin/reference/htmlsingle/), [PDF](https://docs.spring.io/spring-boot/docs/2.5.2/gradle-plugin/reference/pdf/spring-boot-gradle-plugin-reference.pdf))
- [API](https://docs.spring.io/spring-boot/docs/2.5.2/gradle-plugin/api/)

---

## 11.3. Spring Boot AntLib Module

스프링 부트 AntLib 모듈은 Apache Ant를 위한 기본적인 스프링 부트 기능을 제공한다. 이 모듈을 사용하면 실행 가능한<sup>executable</sup> jar를 생성할 수 있다. 모듈을 사용하려면 아래 예제처럼 `build.xml`에 별도 `spring-boot` 네임스페이스를 선언해야 한다:

```xml
<project xmlns:ivy="antlib:org.apache.ivy.ant"
    xmlns:spring-boot="antlib:org.springframework.boot.ant"
    name="myapp" default="build">
    ...
</project>
```

Ant를 시작할 땐 아래와 같이 `-lib` 옵션을 사용하는 걸 잊지 마라:

```shell
$ ant -lib <directory containing spring-boot-antlib-2.5.2.jar>
```

> "스프링 부트 사용하기" 섹션에선 [`spring-boot-antlib`로 Apache Ant를 사용하는](../developing-with-spring-boot#614-ant) 좀 더 완전한 예제를 제공하고 있다.

### 11.3.1. Spring Boot Ant Tasks

`spring-boot-antlib` 네임스페이스를 선언해줬다면 아래와 같은 태스크를 추가로 사용할 수 있다:

- [“exejar” 태스크 사용하기](#using-the-exejar-task)
- [“findmainclass” 태스크 사용하기](#1132-using-the-findmainclass-task)

#### Using the “exejar” Task

`exejar` 태스크를 사용해서 스프링 부트의 실행 가능한<sup>executable</sup> jar를 생성할 수 있다. 이 태스크에선 다음과 같은 속성들을 지원한다:

| Attribute     | Description                        | Required                                                     |
| :------------ | :--------------------------------- | :----------------------------------------------------------- |
| `destfile`    | 생성할 jar 파일                    | Yes                                                          |
| `classes`     | 자바 클래스 파일들의 루트 디렉토리 | Yes                                                          |
| `start-class` | 실행할 메인 애플리케이션 클래스    | No *(디폴트는 첫 번째로 발견한 `main` 메소드를 선언한 클래스다)* |

이 태스크 안에는 아래와 같은 요소들을 사용할 수 있다:

| Element     | Description                                                  |
| :---------- | :----------------------------------------------------------- |
| `resources` | 만들어지는 jar 파일 컨텐츠에 추가해야 하는 [리소스](https://ant.apache.org/manual/Types/resources.html) 셋을 나타내는 하나 이상의 [리소스 컬렉션](https://ant.apache.org/manual/Types/resources.html#collection). |
| `lib`       | 애플리케이션의 런타임 의존성 클래스패스를 구성하는 jar 라이브러리 셋에 추가해야 하는 하나 이상의 [리소스 컬렉션](https://ant.apache.org/manual/Types/resources.html#collection). |

#### Examples

여기서는 두 가지 Ant 태스크 예시를 보여준다.

*Specify start-class*

```xml
<spring-boot:exejar destfile="target/my-application.jar"
        classes="target/classes" start-class="com.example.MyApplication">
    <resources>
        <fileset dir="src/main/resources" />
    </resources>
    <lib>
        <fileset dir="lib" />
    </lib>
</spring-boot:exejar>
```

*Detect start-class*

```xml
<exejar destfile="target/my-application.jar" classes="target/classes">
    <lib>
        <fileset dir="lib" />
    </lib>
</exejar>
```

### 11.3.2. Using the “findmainclass” Task

`findmainclass` 태스크는 `exejar`에서 내부적으로 `main`을 선언하고 있는 클래스를 찾을 때 사용하는 태스크다. 필요하다면 이 태스크를 빌드에서 직접 사용하는 것도 가능하다. 다음과 같은 속성들을 지원한다:

| Attribute     | Description                                 | Required                                   |
| :------------ | :------------------------------------------ | :----------------------------------------- |
| `classesroot` | 자바 클래스 파일들의 루트 디렉토리          | Yes *(`mainclass`를 지정하지 않았을 때만)* |
| `mainclass`   | `main` 클래스를 검색하는 대신 바로 지정한다 | No                                         |
| `property`    | 결과를 세팅해줄 Ant 프로퍼티                | No *(지정하지 않으면 결과를 로깅한다)*     |

#### Examples

여기서는 `findmainclass`를 사용하는 세 가지 예시를 보여준다.

*Find and log*

```xml
<findmainclass classesroot="target/classes" />
```

*Find and set*

```xml
<findmainclass classesroot="target/classes" property="main-class" />
```

*Override and set*

```xml
<findmainclass mainclass="com.example.MainClass" property="main-class" />
```

---

## 11.4. Supporting Other Build Systems

메이븐이나 그래들, Ant 이외 다른 빌드 툴을 사용하려면 대개는 자체 플러그인을 개발해야 할 거다. 실행 가능한<sup>executable</sup> jar는 정해진 형식을 지켜야 하며, 압축하지 않은 포맷으로 작성해야 하는 항목들도 있다 (자세한 내용은 부록에 있는 "[executable jar 포맷](https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#executable-jar)" 섹션 참고).

스프링 부트 메이븐, 그래들 플러그인은 실제 jar를 생성할 땐 둘 다 `spring-boot-loader-tools`를 사용한다. 필요하다면 이 라이브러리를 직접 사용해도 된다.

### 11.4.1. Repackaging Archives

기존 아카이브를 자립적으로 실행할 수 있는<sup>self-contained</sup> 실행 아카이브로 다시 패키징하려면 `org.springframework.boot.loader.tools.Repackager`를 사용해라. `Repackager` 클래스 생성자에선 기존 jar나 war 아카이브를 참조하는 단일 인자를 받는다. 이 클래스에 있는 두 가지 `repackage()` 메소드 중 하나를 사용해서 원본 파일을 교체하거나 새 경로에 파일을 생성해라. repackager를 실행하기 전에 변경할 수 있는 다양한 설정들도 지원한다.

### 11.4.2. Nested Libraries

아카이브를 다시 패키징할 때는 `org.springframework.boot.loader.tools.Libraries` 인터페이스를 사용해서 의존성 파일에 대한 참조를 포함시킬 수 있다. `Libraries` 구현체는 보통 빌드 시스템마다 다르기 때문에, 실제 구현체는 따로 제공하지 않는다.

아카이브에 이미 라이브러리들이 들어있다면 `Libraries.NONE`을 사용하면 된다.

### 11.4.3. Finding a Main Class

`Repackager.setMainClass()`로 메인 클래스를 지정하지 않았다면, repackager는 [ASM](https://asm.ow2.io/)을 사용해서 클래스 파일들을 읽어 `public static void main(String[] args)` 메소드를 가지고 있는 클래스를 찾아본다. 적당한 후보가 둘 이상일 땐 예외를 던진다.

### 11.4.4. Example Repackage Implementation

다음은 repackage를 구현하는 전형적인 예시다:

```java
public class MyBuildTool {

    public void build() throws IOException {
        File sourceJarFile = ...
        Repackager repackager = new Repackager(sourceJarFile);
        repackager.setBackupSource(false);
        repackager.repackage(this::getLibraries);
    }

    private void getLibraries(LibraryCallback callback) throws IOException {
        // Build system specific implementation, callback for each dependency
        for (File nestedJar : getCompileScopeJars()) {
            callback.library(new Library(nestedJar, LibraryScope.COMPILE));
        }
        // ...
    }

    private List<File> getCompileScopeJars() {
        return ...
    }

}
```

---

## 11.5. What to Read Next

빌드 툴 플러그인의 동작 방식에 관심이 있다면 깃허브에서 [`spring-boot-tools`](https://github.com/spring-projects/spring-boot/tree/v2.5.2/spring-boot-project/spring-boot-tools) 모듈을 찾아보면 된다. 실행 가능한<sup>executable</sup> jar 포맷에 대한 자세한 기술적인 정보는 [부록](https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#executable-jar)에서 다루고 있다.

빌드와 관련해서 따로 궁금한게 있다면 "[how-to](../how-to-guides)" 가이드를 확인해보면 된다.