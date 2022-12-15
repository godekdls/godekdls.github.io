---
title: Deploying Spring Boot Applications
category: Spring Boot 2.X
order: 53
permalink: /Spring%20Boot/deploying-spring-boot-applications/
description: 스프링 부트 애플리케이션을 쿠버네티스 등의 클라우드 환경에 배포하는 방법과 linux 서비스로 실행하는 방법
image: ./../../images/springboot/logo.png
lastmod: 2021-07-26T18:30:00+09:00
comments: true
originalRefName: 스프링 부트
originalRefLink: https://docs.spring.io/spring-boot/docs/2.5.2/reference/htmlsingle/#deployment
priority: 0.4
---

### 목차

- [9.1. Deploying to Containers](#91-deploying-to-containers)
- [9.2. Deploying to the Cloud](#92-deploying-to-the-cloud)
  + [9.2.1. Cloud Foundry](#921-cloud-foundry)
    * [Binding to Services](#binding-to-services)
  + [9.2.2. Kubernetes](#922-kubernetes)
    * [Kubernetes Container Lifecycle](#kubernetes-container-lifecycle)
  + [9.2.3. Heroku](#923-heroku)
  + [9.2.4. OpenShift](#924-openshift)
  + [9.2.5. Amazon Web Services (AWS)](#925-amazon-web-services-aws)
    * [AWS Elastic Beanstalk](#aws-elastic-beanstalk)
    * [Summary](#summary)
  + [9.2.6. Boxfuse and Amazon Web Services](#926-boxfuse-and-amazon-web-services)
  + [9.2.7. Azure](#927-azure)
  + [9.2.8. Google Cloud](#928-google-cloud)
- [9.3. Installing Spring Boot Applications](#93-installing-spring-boot-applications)
  + [9.3.1. Supported Operating Systems](#931-supported-operating-systems)
  + [9.3.2. Unix/Linux Services](#932-unixlinux-services)
    * [Installation as an init.d Service (System V)](#installation-as-an-initd-service-system-v)
    * [Installation as a systemd Service](#installation-as-a-systemd-service)
    * [Customizing the Startup Script](#customizing-the-startup-script)
  + [9.3.3. Microsoft Windows Services](#933-microsoft-windows-services)
- [9.4. What to Read Next](#94-what-to-read-next)

---

스프링 부트의 유연한 패키징 옵션덕분에, 애플리케이션을 배포할 때 선택할 수 있는 것들이 매우 다양하다. 스프링 부트 애플리케이션은 다양한 클라우드 플랫폼, 컨테이너 이미지(도커같은), 가상/실제 머신에 배포할 수 있다.

이번 섹션에선 좀 더 일반적인 배포 시나리오들을 몇 가지 다룬다.

---

## 9.1. Deploying to Containers

애플리케이션을 컨테이너에서 실행할 때는 실행 가능한<sup>executable</sup> jar를 사용할 수 있지만, jar를 분해해서 다른 방식으로 실행하면 보통 더 유리하다. PaaS 구현체에 따라서는 아카이브를 실행하기 전에 압축을 풀도록 설정할 수도 있다. 예를 들어 Cloud Foundry가 그렇다. 압축을 푼 아카이브를 실행하는 방법 중 하나는, 다음과 같이 적당한 launcher를 실행시키는 거다:

```shell
$ jar -xf myapp.jar
$ java org.springframework.boot.loader.JarLauncher
```

실제로 이렇게하면 아카이브를 분해하지 않고 바로 실행할 때보다 기동이 약간 더 빨라진다 (jar 크기에 따라 다를 수 있다). 런타임에는 어떤 차이도 기대하면 안 된다.

jar 파일의 압축을 풀었다면, `JarLauncher` 대신 "자연스러운" 메인 메소드로 앱을 실행하면 기동 시간을 조금 더 앞당길 수 있다. 예를 들어:

```shell
$ jar -xf myapp.jar
$ java -cp BOOT-INF/classes:BOOT-INF/lib/* com.example.MyApplication
```

> `JarLauncher`를 사용해 애플리케이션의 메인 메소드를 호출하면 클래스패스 순서를 예측할 수 있다는 이점이 있다. jar에는 `classpath.idx` 파일이 들어있어서 `JarLauncher`는 이 파일을 사용해 클래스패스를 구성한다.

의존성과 애플리케이션 클래스/리소스(보통 더 자주 변경된다)에 [별도의 레이어를 생성](../container-images#dockerfiles)하면 이보다 더 효율적인 컨테이너 이미지도 생성할 수 있다.

---

## 9.2. Deploying to the Cloud

스프링 부트의 실행 가능한<sup>executable</sup> jar는 가장 인기 있는 클라우드 PaaS<sup>Platform-as-a-Service</sup> 제공업체들에서 바로 사용할 수 있는 형태로 만들어진다. 이런 제공업체들은 "bring your own container"를 요구하곤 한다. 제공업체에선 애플리케이션 프로세스(자바 애플리케이션이 아니다)를 관리하기 때문에, *클라우드*의 실행 중인 프로세스라는 개념에 맞게 *우리가 개발하는* 애플리케이션을 조정해줄 중간 레이어가 필요하다.

인기 있는 두 클라우드 제공업체 Heroku와 Cloud Foundry는 "빌드팩" 방식을 채용한다. 빌드팩은 배포된 코드를 애플리케이션을 *시작*하는 데 필요한 게 무엇이든지 그걸로 래핑해준다. JDK라면 `java` 호출일 수도 있고, 임베디드 웹 서버나, 모든 것을 다 갖추고 있는 애플리케이션 서버일 수도 있다. 빌드팩은 원하는 것을 선택해서 사용할 수 있지만, 가능한 한 커스텀은 덜 하고도 이용할 수 있는 게 이상적이다. 이렇게 되면 직접 제어가 불가능한 기능 범위가 줄어들 거고, 개발 환경과 프로덕션 환경 간의 차이를 최소화할 수 있다.

스프링 부트의 실행 가능한<sup>executable</sup> jar같은 애플리케이션은 이론적으로 실행하는 데 필요한 모든 것이 그 안에 패키징돼 있다.

이번 섹션에선 "Getting Started" 섹션에서 [개발했던 애플리케이션](../getting-started#44-developing-your-first-spring-boot-application)을 가져와 클라우드에서 실행하는 방법을 살펴본다.

### 9.2.1. Cloud Foundry

Cloud Foundry는 별다른 빌드팩을 지정하지 않았을 때 시행하는 디폴트 빌드팩을 제공한다. Cloud Foundry [자바 빌드팩](https://github.com/cloudfoundry/java-buildpack)은 스프링 부트를 포함한 스프링 애플리케이션을 아주 잘 지원하고 있다. 전통적인 `.war` 패키징 애플리케이션 뿐 아니라, 독립적으로 실행시킬 수 있는 jar<sup>stand-alone executable jar</sup> 애플리케이션도 배포할 수 있다.

애플리케이션을 빌드했고(ex. `mvn clean package`) [`cf` 커맨드라인 툴을 설치했다면](https://docs.cloudfoundry.org/cf-cli/install-go-cli.html), `cf push` 명령어를 사용해 애플리케이션을 배포해라 (경로는 컴파일된 `.jar` 경로로 바꿔라). 애플리케이션을 푸시하기 전에 [`cf` 커맨드라인 클라이언트를 통해 로그인](https://docs.cloudfoundry.org/cf-cli/getting-started.html#login)해야 한다. 다음은 `cf push` 명령어를 통해 애플리케이션을 배포하는 예시다:

```shell
$ cf push acloudyspringtime -p target/demo-0.0.1-SNAPSHOT.jar
```

> 위 예시에선 `cf`에 지정하는 애플리케이션명에 `acloudyspringtime`을 사용했다.

다른 옵션들은 [`cf push` 문서](https://docs.cloudfoundry.org/cf-cli/getting-started.html#push)를 확인해봐라. 같은 디렉토리에 Cloud Foundry [`manifest.yml`](https://docs.cloudfoundry.org/devguide/deploy-apps/manifest.html) 파일이 있으면 이 파일도 함께 읽어간다.

이 시점에서 `cf`는 애플리케이션 업로드를 시작하고 아래와 유사한 내용을 출력한다:

```sh
Uploading acloudyspringtime... OK
Preparing to start acloudyspringtime... OK
-----> Downloaded app package (8.9M)
-----> Java Buildpack Version: v3.12 (offline) | https://github.com/cloudfoundry/java-buildpack.git#6f25b7e
-----> Downloading Open Jdk JRE 1.8.0_121 from https://java-buildpack.cloudfoundry.org/openjdk/trusty/x86_64/openjdk-1.8.0_121.tar.gz (found in cache)
       Expanding Open Jdk JRE to .java-buildpack/open_jdk_jre (1.6s)
-----> Downloading Open JDK Like Memory Calculator 2.0.2_RELEASE from https://java-buildpack.cloudfoundry.org/memory-calculator/trusty/x86_64/memory-calculator-2.0.2_RELEASE.tar.gz (found in cache)
       Memory Settings: -Xss349K -Xmx681574K -XX:MaxMetaspaceSize=104857K -Xms681574K -XX:MetaspaceSize=104857K
-----> Downloading Container Certificate Trust Store 1.0.0_RELEASE from https://java-buildpack.cloudfoundry.org/container-certificate-trust-store/container-certificate-trust-store-1.0.0_RELEASE.jar (found in cache)
       Adding certificates to .java-buildpack/container_certificate_trust_store/truststore.jks (0.6s)
-----> Downloading Spring Auto Reconfiguration 1.10.0_RELEASE from https://java-buildpack.cloudfoundry.org/auto-reconfiguration/auto-reconfiguration-1.10.0_RELEASE.jar (found in cache)
Checking status of app 'acloudyspringtime'...
  0 of 1 instances running (1 starting)
  ...
  0 of 1 instances running (1 starting)
  ...
  0 of 1 instances running (1 starting)
  ...
  1 of 1 instances running (1 running)

App started
```

축하한다! 이제 애플리케이션이 실행됐다!

애플리케이션을 띄우고 나면 아래 예시처럼 `cf apps` 명령어를 사용해 배포된 애플리케이션의 상태를 확인할 수 있다:

```shell
$ cf apps
Getting applications in ...
OK

name                 requested state   instances   memory   disk   urls
...
acloudyspringtime    started           1/1         512M     1G     acloudyspringtime.cfapps.io
...
```

Cloud Foundry가 애플리케이션 배포가 완료됐다는 것을 승인하고 나면, 지정한 URI에서 애플리케이션을 찾을 수 있을 거다. 위 예시에선 `https://acloudyspringtime.cfapps.io/`에서 찾을 수 있다.

#### Binding to Services

기본적으로 실행 중인 애플리케이션에 대한 메타데이터와 서비스 커넥션 정보는 환경 변수를 통해 애플리케이션에 노출한다 (ex. `$VCAP_SERVICES`). 이렇게 설계된 이유는 Cloud Foundry의 폴리그랏<sup>polyglot</sup>(어떤 언어, 플랫폼이든지 빌드팩으로 지원할 수 있다) 특성때문이다. 프로세스 범위에 있는 환경 변수는 언어에 구애받지 않는다.

환경 변수라고 해서 무조건 API로 사용하기 쉬워지는 건 아닌데, 그래서 스프링 부트는 이 데이터를 자동으로 추출하고 펼쳐서<sup>flatten</sup> 프로퍼티에 추가해준다. 이 프로퍼티는 아래 예제처럼 스프링이 추상화해 놓은 `Environment`를 통해 쉽게 접근할 수 있다:

```java
@Component
public class MyBean implements EnvironmentAware {

    private String instanceId;

    @Override
    public void setEnvironment(Environment environment) {
        this.instanceId = environment.getProperty("vcap.application.instance_id");
    }

    // ...

}
```

모든 Cloud Foundry 프로퍼티는 앞에 `vcap`이 붙는다. `vcap` 프로퍼티를 통해 애플리케이션 정보(ex. 애플리케이션의 public URL)와 서비스 정보(ex. 데이터베이스 credential)에 접근할 수 있다. 자세한 내용은 ['CloudFoundryVcapEnvironmentPostProcessor'](https://docs.spring.io/spring-boot/docs/2.5.2/api/org/springframework/boot/cloud/CloudFoundryVcapEnvironmentPostProcessor.html) Javadoc을 참고해라.

> DataSource 설정같은 작업에는 [자바 CFEnv](https://github.com/pivotal-cf/java-cfenv/) 프로젝트가 더 잘 맞는다.

### 9.2.2. Kubernetes

스프링 부트는 환경 변수에서 `"*_SERVICE_HOST"`와 `"*_SERVICE_PORT"`를 체크해서 쿠버네티스 배포 환경을 자동 감지한다. 이 동작은 설정 프로퍼티 `spring.main.cloud-platform`으로 재정의할 수 있다.

스프링 부트를 사용하면 쉽게 [애플리케이션 상태를 관리](../spring-application#716-application-availability)하고, [액추에이터를 통해 HTTP 쿠버네티스 프로브](../endpoints#829-kubernetes-probes)로 상태를 익스포트할 수 있다.

#### Kubernetes Container Lifecycle

쿠버네티스가 애플리케이션 인스턴스를 삭제할 때 진행하는 셧다운 프로세스는, 여러 가지 하위시스템 작업을 수반한다 (shutdown 훅, 서비스 등록 제외, 로드 밸런서에서 인스턴스 제거 등). 이 셧다운 프로세스는 병렬로 일어나기 때문에 (그리고 분산 시스템의 특성으로 인해), 잠시 동안은 셧다운 프로세스에 들어간 포드로 트래픽을 라우팅할 수도 있다.

preStop 핸들러에 sleep을 걸어주면 요청이 이미 셧다운에 들어간 포드로 라우팅되는 걸 막을 수 있다. sleep 시간은 새로운 요청을 해당 포드로 라우팅하지 않을 만큼 충분히 줘야 하며, 배포 환경에 따라 기준치는 크게 달라진다. preStop 핸들러는 다음과 같이 포드의 설정 파일에 있는 PodSpec을 통해 설정할 수 있다:

```yml
spec:
  containers:
  - name: example-container
    image: example-image
    lifecycle:
      preStop:
        exec:
          command: ["sh", "-c", "sleep 10"]
```

pre-stop 훅이 완료되고 나면 컨테이너로 SIGTERM이 전송되고, [graceful 셧다운](../graceful-shutdown)이 시작돼 아직 진행 중인 요청을 완료할 수 있다.

> 쿠버네티스가 포드에 SIGTERM 신호를 전송할 때는 지정한 시간만큼만 기다리며, 이 시간은 termination grace period라고 부른다 (기본 30초). grace period가 지난 뒤에도 실행 중인 컨테이너에는 SIGKILL 신호를 전송하고 강제로 제거한다. <span class="custom-blockquote">spring.lifecycle.timeout-per-shutdown-phase</span>를 늘렸다거나 하는 등의 이유로 포드를 종료하는 데 30초 이상이 소요된다면, 포드 YAML에서 `terminationGracePeriodSeconds` 옵션을 설정해서 termination grace period를 늘려야 한다.

### 9.2.3. Heroku

Heroku는 또 다른 인기 PaaS 플랫폼이다. Heroku 빌드를 커스텀하려면 애플리케이션 배포에 필요한 명령어를 `Procfile`로 제공해라. Heroku는 자바 애플리케이션에서 사용할 `port`를 할당한 다음 외부 URI로 라우팅되게 만들어준다.

애플리케이션이 올바른 포트에서 수신<sup>listen</sup>할 수 있도록 반드시 포트를 설정해줘야 한다. 다음은 스타터 REST 애플리케이션을 위한 `Procfile` 예시다:

```
web: java -Dserver.port=$PORT -jar target/demo-0.0.1-SNAPSHOT.jar
```

스프링 부트는 `-D` 인자들을 스프링 `Environment` 인스턴스로 접근할 수 있는 프로퍼티로 넣어준다. `server.port` 설정 프로퍼티는 임베디드 Tomcat, Jetty, Undertow 인스턴스가 기동할 때 사용하는 포트다. 환경 변수 `$PORT`는 Heroku PaaS에서 할당한다.

이게 필요한 전부일 거다. Heroku 배포를 위한 가장 일반적인 배포 워크플로우는 아래 예시에서 보이는 것처럼 코드를 프로덕션에 `git push`하는 거다:

```shell
$ git push heroku main
```

그럼 다음과 같은 내용을 볼 수 있을 거다:

```sh
Initializing repository, done.
Counting objects: 95, done.
Delta compression using up to 8 threads.
Compressing objects: 100% (78/78), done.
Writing objects: 100% (95/95), 8.66 MiB | 606.00 KiB/s, done.
Total 95 (delta 31), reused 0 (delta 0)

-----> Java app detected
-----> Installing OpenJDK 1.8... done
-----> Installing Maven 3.3.1... done
-----> Installing settings.xml... done
-----> Executing: mvn -B -DskipTests=true clean install

       [INFO] Scanning for projects...
       Downloading: https://repo.spring.io/...
       Downloaded: https://repo.spring.io/... (818 B at 1.8 KB/sec)
        ....
       Downloaded: https://s3pository.heroku.com/jvm/... (152 KB at 595.3 KB/sec)
       [INFO] Installing /tmp/build_0c35a5d2-a067-4abc-a232-14b1fb7a8229/target/...
       [INFO] Installing /tmp/build_0c35a5d2-a067-4abc-a232-14b1fb7a8229/pom.xml ...
       [INFO] ------------------------------------------------------------------------
       [INFO] BUILD SUCCESS
       [INFO] ------------------------------------------------------------------------
       [INFO] Total time: 59.358s
       [INFO] Finished at: Fri Mar 07 07:28:25 UTC 2014
       [INFO] Final Memory: 20M/493M
       [INFO] ------------------------------------------------------------------------

-----> Discovering process types
       Procfile declares types -> web

-----> Compressing... done, 70.4MB
-----> Launching... done, v6
       https://agile-sierra-1405.herokuapp.com/ deployed to Heroku

To git@heroku.com:agile-sierra-1405.git
 * [new branch]      main -> main
```

이제 Heroku에서 애플리케이션이 실행됐을 거다. 자세한 내용은 [Heroku에 스프링 부트 애플리케이션 배포하기](https://devcenter.heroku.com/articles/deploying-spring-boot-apps-to-heroku)를 참고해라.

### 9.2.4. OpenShift

[OpenShift](https://www.openshift.com/)는 아래 링크를 포함해서, 스프링 부트 애플리케이션을 배포하는 방법을 설명하고 있는 자료가 매우 다양하다:

- [Using the S2I builder](https://blog.openshift.com/using-openshift-enterprise-grade-spring-boot-deployments/)
- [Architecture guide](https://access.redhat.com/documentation/en-us/reference_architectures/2017/html-single/spring_boot_microservices_on_red_hat_openshift_container_platform_3/)
- [Running as a traditional web application on Wildfly](https://blog.openshift.com/using-spring-boot-on-openshift/)
- [OpenShift Commons Briefing](https://blog.openshift.com/openshift-commons-briefing-96-cloud-native-applications-spring-rhoar/)

### 9.2.5. Amazon Web Services (AWS)

아마존 웹 서비스는 전통적인 웹 애플리케이션(war)이나 임베디드 웹 서버를 가지고 있는 실행 가능한<sup>executable</sup> jar 파일을 통해, 스프링 부트 기반 애플리케이션을 인스톨할 수 있는 여러 가지 방법을 제공한다. 여기에는 다음과 같은 옵션이 있다:

- AWS Elastic Beanstalk
- AWS Code Deploy
- AWS OPS Works
- AWS Cloud Formation
- AWS Container Registry

각각은 모두 기능이 다르고, 과금 모델도 다르다. 이 문서에선 AWS Elastic Beanstalk를 통해 접근하는 방법을 설명한다.

#### AWS Elastic Beanstalk

공식 [Elastic Beanstalk 자바 가이드](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/create_deploy_Java.html)에서 설명하고 있는 것처럼, 자바 애플리케이션을 배포하는 데는 메인 옵션이 두 가지가 있다. "톰캣 플랫폼"이나 "자바 SE 플랫폼" 중 하나를 선택할 수 있다.

##### Using the Tomcat Platform

이 옵션은 war 파일을 만드는 스프링 부트 프로젝트에 적용되는 옵션이다. 특별한 설정은 필요하지 않다. 공식 가이드만 잘 따라하면 된다.

##### Using the Java SE Platform

이 옵션은 jar 파일을 만들고 임베디드 웹 컨테이너를 실행하는 스프링 부트 프로젝트에 적용되는 옵션이다. Elastic Beanstalk 환경에선 80 포트에서 nginx 인스턴스를 실행해 5000 포트에서 실행하는 실제 애플리케이션을 프록시한다. 포트를 설정하려면 `application.properties` 파일에 다음 설정을 추가해라:

```properties
server.port=5000
```

> *소스 코드 말고 바이너리 업로드하기*
>
> Elastic Beanstalk에선 기본적으로 소스 코드를 업로드하며, AWS에서 컴파일한다. 하지만 가장 좋은 건 바이너리를 직접 업로드하는 거다. `.elasticbeanstalk/config.yml` 파일에 다음과 유사한 설정을 추가하면 된다:
>
> ```yaml
> deploy:
>     artifact: target/demo-0.0.1-SNAPSHOT.jar
> ```

> *환경 타입을 설정해서 비용 줄이기*
>
> Elastic Beanstalk 환경은 기본적으로 로드 밸런싱을 사용한다. 로드 밸런서에는 상당한 비용이 들어간다. 이게 싫다면 [Amazon 문서](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/environments-create-wizard.html#environments-create-wizard-capacity)에 설명하고 있는 것처럼 환경 타입을 "Single instance"로 설정해라. CLI에서 다음 명령어를 사용해도 단일 인스턴스 환경을 생성할 수 있다.
>
> ```sh
> eb create -s
> ```

#### Summary

여기서 설명한 방식은 가장 쉽게 AWS를 사용할 수 있는 방법 중 하나긴 하지만, Elastic Beanstalk를 CI/CD 툴에 통합하는 방법, CLI 대신 Elastic Beanstalk 메이븐 플러그인을 사용하는 방법 등, 더 다뤄볼 내용이 많이 남아있다. 이런 주제들은 [블로그 게시물](https://exampledriven.wordpress.com/2017/01/09/spring-boot-aws-elastic-beanstalk-example/)에 좀 더 자세히 다루고 있다.

### 9.2.6. Boxfuse and Amazon Web Services

[Boxfuse](https://boxfuse.com/)는 스프링 부트의 실행 가능한<sup>executable</sup> jar나 war를, VirtualBox나 AWS에 그대로 배포할 수 있는 최소한의 VM 이미지로 전환하는 식으로 동작한다. Boxfuse는 스프링 부트와의 긴밀한 통합을 함께 제공하고 있으며, 스프링 부트 설정 파일에 있는 정보를 사용해서 포트와 health check URL을 자동으로 설정한다. Boxfuse는 생성하는 이미지뿐 아니라 프로비저닝하는 모든 리소스(인스턴스, 시큐리티 그룹, elastic 로드 밸런서 등)에 이 정보를 활용한다.

[Boxfuse 계정](https://console.boxfuse.com/)을 만들어 AWS 계정에 연결했고, Boxfuse 클라이언트를 최신 버전으로 설치했고, 애플리케이션을 메이븐이나 그래들로 빌드했다면 (ex. `mvn clean package`), 아래와 유사한 명령어를 통해 스프링 부트 애플리케이션을 AWS에 배포할 수 있다:

```shell
$ boxfuse run myapp-1.0.jar -env=prod
```

다른 옵션들은 [`boxfuse run` 문서](https://boxfuse.com/docs/commandline/run.html)를 참고해라. 현재 디렉토리에 [`boxfuse.conf`](https://boxfuse.com/docs/commandline/#configuration) 파일이 있으면 이 파일도 읽어간다.

> Boxfuse는 기본적으로 기동 시 `boxfuse`라는 스프링 프로파일을 활성화한다. 실행 가능한<sup>executable</sup> jar나 war 파일에 [`application-boxfuse.properties`](https://boxfuse.com/docs/payloads/springboot.html#configuration) 파일이 들어있으면 Boxfuse는 여기에 들어있는 프로퍼티를 기반으로 설정을 만든다.

이 시점에서 `boxfuse`는 애플리케이션을 위한 이미지를 생성해 업로드하고, AWS에서 필요한 리소스를 설정하고 시작해서 다음과 유사한 내용을 출력한다:

```sh
Fusing Image for myapp-1.0.jar ...
Image fused in 00:06.838s (53937 K) -> axelfontaine/myapp:1.0
Creating axelfontaine/myapp ...
Pushing axelfontaine/myapp:1.0 ...
Verifying axelfontaine/myapp:1.0 ...
Creating Elastic IP ...
Mapping myapp-axelfontaine.boxfuse.io to 52.28.233.167 ...
Waiting for AWS to create an AMI for axelfontaine/myapp:1.0 in eu-central-1 (this may take up to 50 seconds) ...
AMI created in 00:23.557s -> ami-d23f38cf
Creating security group boxfuse-sg_axelfontaine/myapp:1.0 ...
Launching t2.micro instance of axelfontaine/myapp:1.0 (ami-d23f38cf) in eu-central-1 ...
Instance launched in 00:30.306s -> i-92ef9f53
Waiting for AWS to boot Instance i-92ef9f53 and Payload to start at https://52.28.235.61/ ...
Payload started in 00:29.266s -> https://52.28.235.61/
Remapping Elastic IP 52.28.233.167 to i-92ef9f53 ...
Waiting 15s for AWS to complete Elastic IP Zero Downtime transition ...
Deployment completed successfully. axelfontaine/myapp:1.0 is up and running at https://myapp-axelfontaine.boxfuse.io/
```

이제 AWS에서 애플리케이션이 실행됐을 거다.

애플리케이션 실행을 위한 메이븐 빌드를 시작하려면 블로그 게시물 [EC2에 스프링 부트 앱 배포하기](https://boxfuse.com/blog/spring-boot-ec2.html)와 [Boxfuse 스프링 부트 통합을 위한 문서](https://boxfuse.com/docs/payloads/springboot.html)를 참고해라.

### 9.2.7. Azure

여기 [Getting Started 가이드](https://spring.io/guides/gs/spring-boot-for-azure/)에서는 스프링 부트 애플리케이션을 [Azure Spring Cloud](https://azure.microsoft.com/en-ca/services/spring-cloud/)나 [Azure App Service](https://docs.microsoft.com/en-ca/azure/app-service/overview)에 배포하는 방법을 안내하고 있다.

### 9.2.8. Google Cloud

구글 클라우드에선 스프링 부트 애플리케이션을 기동시킬 때 사용할 수 있는 몇 가지 옵션이 있다. App Engine이 시작하기 가장 쉽긴 하겠지만, Container Engine을 통해 스프링 부트를 컨테이너에서 실행하거나, Compute Engine을 통해 가상 머신에서 실행하는 방법도 있다.

App Engine에서 실행하려면 먼저 UI에서 프로젝트를 생성하면 되는데, 프로젝트를 만들면 고유 식별자와 HTTP 라우트가 세팅된다. 프로젝트에 자바 앱을 추가하고 비워 둔 다음, [Google Cloud SDK](https://cloud.google.com/sdk/install)를 사용해 커맨드라인이나 CI 빌드에서 스프링 부트 앱을 해당 슬롯으로 푸시해라.

App Engine Standard에선 WAR 패키징을 사용해야 한다. App Engine Standard 애플리케이션을 Google Cloud에 배포하려면 [이 가이드](https://github.com/GoogleCloudPlatform/java-docs-samples/tree/master/appengine-java8/springboot-helloworld/README.md)를 따라하면 된다.

아니면, App Engine Flex에선 앱에서 필요한 리소스를 설명하는 `app.yaml` 파일을 생성해야 한다. 이 파일은 보통 `src/main/appengine`에 추가하며, 아래 파일과 유사할 거다:

```yaml
service: default

runtime: java
env: flex

runtime_config:
  jdk: openjdk8

handlers:
- url: /.*
  script: this field is required, but ignored

manual_scaling:
  instances: 1

health_check:
  enable_health_check: False

env_variables:
  ENCRYPT_KEY: your_encryption_key_here
```

아래 예제처럼 빌드 설정에 프로젝트 ID를 추가해주면 (ex. 메이븐 플러그인으로) 앱을 배포할 수 있다.

```xml
<plugin>
    <groupId>com.google.cloud.tools</groupId>
    <artifactId>appengine-maven-plugin</artifactId>
    <version>1.3.0</version>
    <configuration>
        <project>myproject</project>
    </configuration>
</plugin>
```

이제 `mvn appengine:deploy`를 실행해서 배포해라 (인증이 먼저 필요할 땐 빌드에 실패한다).

---

## 9.3. Installing Spring Boot Applications

`java -jar` 명령어로 스프링 부트 애플리케이션을 실행하는 방법도 있지만, Unix 시스템에선 완전히 실행 가능한<sup>fully executable</sup> 애플리케이션을 만들 수도 있다. 완전히 실행 가능한 jar<sup>fully executable jar</sup>는 실행 가능한 다른 바이너리처럼 바로 실행할 수 있고, [`init.d`나 `systemd`로 등록](#932-unixlinux-services)할 수도 있다. 공통 프로덕션 환경에서 스프링 부트 애플리케이션을 설치하고 관리할 때 사용하기 좋을 거다.

> 완전히 실행 가능한 jar<sup>fully executable jar</sup>는 파일 앞에 별도 스크립트를 임베딩시키는 식으로 동작한다. 현재 일부 툴에선 이 포맷을 허용하지 않고 있기 때문에, 이 기술을 항상 사용할 수 있는 건 아니다. 예를 들어 `jar -xf`에서 완전히 실행 가능하게 만들어진 jar나 war를 추출하는 데 실패할 수도 있다. jar나 war를 완전히 실행 가능하게 빌드하는 옵션은, `java -jar`로 실행하거나 서블릿 컨테이너에 배포할 때 보단, 직접 실행시키고 싶은 경우에만 사용하기를 권장한다.

> zip64 포맷 jar 파일은 완전히 실행 가능하게 만드는 게 불가능하다. 이 파일로 시도하면 직접 실행하거나 `java -jar`로 실행했을 땐 손상된 파일이라는 경고를 보게될 거다. zip64 포맷 jar를 하나 이상 감싸서 표준 포맷 jar 파일을 만들면 완전히 실행 가능하게 만들 수 있다.

메이븐으로 '완전히 실행 가능한<sup>fully executable</sup>' jar를 생성하려면 아래 플러그인 설정을 사용해라:

```xml
<plugin>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-maven-plugin</artifactId>
    <configuration>
        <executable>true</executable>
    </configuration>
</plugin>
```

다음은 위와 동일한 그래들 설정이다:

```gradle
bootJar {
    launchScript()
}
```

이제 `./my-application.jar`를 입력하면 애플리케이션을 실행할 수 있다 (여기서 `my-application`은 아티팩트 이름이다). jar를 가지고 있는 디렉토리는 애플리케이션의 작업 디렉토리로 사용한다.

### 9.3.1. Supported Operating Systems

디폴트 스크립트는 Linux 배포판을 대부분 지원하며, CentOS와 Ubuntu에서 테스트를 마쳤다. OS X나 FreeBSD같은 다른 플랫폼에선 커스텀 `embeddedLaunchScript`가 필요하다.

### 9.3.2. Unix/Linux Services

`init.d`나 `systemd`를 활용하면 스프링 부트 애플리케이션을 Unix/Linux 서비스로 쉽게 기동시킬 수 있다.

#### Installation as an init.d Service (System V)

스프링 부트의 메이븐 플러그인이나 그래들 플러그인을 설정해서 [완전히 실행 가능한 jar<sup>fully executable jar</sup>](#93-installing-spring-boot-applications)를 생성하고, 커스텀 `embeddedLaunchScript`를 사용하지 않는다면 애플리케이션을 `init.d` 서비스로 사용할 수 있다. 표준 `start`, `stop`, `restart`, `status` 명령어를 지원할 수 있도록 jar를 `init.d`로 심볼릭 링크를 걸어주면 된다:

이 스크립트는 아래와 같은 기능들을 지원한다:

- jar 파일을 소유하고 있는 user로 서비스를 시작한다
- `/var/run/<appname>/<appname>.pid`를 사용해서 애플리케이션의 PID를 추적한다
- `/var/log/<appname>.log`에 콘솔 로그를 출력한다

스프링 부트 애플리케이션을 `/var/myapp`에 설치했다고 가정하고, 다음과 같이 심볼릭 링크를 생성하면 스프링 부트 애플리케이션을 `init.d` 서비스로 설치할 수 있다:

```shell
$ sudo ln -s /var/myapp/myapp.jar /etc/init.d/myapp
```

설치를 완료했다면 평소 쓰는 방법으로 서비스를 시작하고 중지할 수 있다. 예를 들어, 데비안 기반 시스템에선 다음 명령어로 기동시킬 수 있다:

```shell
$ service myapp start
```

> 애플리케이션이 기동에 실패한다면, `/var/log/<appname>.log`에 기록되어 있는 로그 파일에서 오류가 있는지 확인해봐라.

표준 운영 체제 툴을 사용해 애플리케이션을 자동으로 시작하는 플래그를 지정할 수도 있다. 예를 들어 데비안에선 다음 명령어를 사용하면 된다:

```shell
$ update-rc.d myapp defaults <priority>
```

##### Securing an init.d Service

> 아래 가이드는 init.d 서비스로 실행되는 스프링 부트 애플리케이션을 보호하는 방법을 설명한다. 여기서 설명하는 내용이 애플리케이션과, 이를 실행하는 환경을 강화하기 위해 필요한 모든 조치를 나타내는 완전한 가이드라곤 할 수 없다.

init.d 서비스를 시작할 때 root를 사용하는 등, 디폴트 실행 스크립트를 root로 실행하면 환경 변수 `RUN_AS_USER`에 지정한 user로 애플리케이션을 실행한다. 환경 변수를 설정하지 않았을 땐 대신 jar 파일을 소유하고 있는 user를 사용한다. 스프링 부트 애플리케이션은 `root`로 실행하면 안 되기 때문에, `RUN_AS_USER`는 root로 설정하면 안 되며, 애플리케이션의 jar 파일을 root가 소유하는 것도 안 된다. 대신 아래 예시처럼 애플리케이션을 실행할 user를 하나 만들어서, 환경 변수 `RUN_AS_USER`를 설정하거나 `chown`을 사용해 이 user를 jar 파일 소유자로 만들어라:

```shell
$ chown bootapp:bootapp your-app.jar
```

이렇게 설정했을 땐 디폴트 실행 스크립트는 `bootapp` user로 애플리케이션을 실행한다.

> 애플리케이션의 user 계정이 손상될 여지를 줄이려면 로그인 쉘 사용을 막는 것도 좋은 방법이다. 예를 들어 해당 계정의 쉘을 `/usr/sbin/nologin`으로 설정할 수 있다.

애플리케이션의 jar 파일이 수정되는 걸 막으려면 또 다른 조치가 필요하다. 먼저 아래 예시처럼 파일 소유자가 수정은 할 수 없고, 읽기나 실행만 가능하도록 퍼미션을 설정해라:

```shell
$ chmod 500 your-app.jar
```

그 다음으로, 애플리케이션이나 애플리케이션을 실행하는 계정이 손상된 경우에 피해를 최소화해주기 위한 조치가 필요하다. 공격자가 접근 권한을 얻게되면 jar 파일을 수정 가능하게 만들어 내용을 변경할 수 있다. 이를 막을 수 있는 방법 중 하나는 다음 예시처럼 `chattr`을 사용해 파일을 변경 불가능하게 만드는 거다:

```shell
$ sudo chattr +i your-app.jar
```

이렇게 하면 root를 포함한 모든 user가 jar를 수정하는 걸 막을 수 있다.

애플리케이션의 서비스를 root로 제어하면서 [`.conf` 파일로](#deployment.installing.nix-services.script-customization.when-running.conf-file) 기동 스크립트를 커스텀한다면, 이 `.conf` 파일은 root user가 읽고 평가한다. 이 파일은 그에 맞게 보호해줘야 한다. 다음 예시처럼 `chmod`를 사용해 파일을 소유자만 읽을 수 있도록 만들고, `chown`을 통해 root를 소유자로 만들어라:

```shell
$ chmod 400 your-app.conf
$ sudo chown root:root your-app.conf
```

#### Installation as a systemd Service

`systemd`는 System V init 시스템의 뒤를 잇는 데몬으로, 현재 많은 최신 Linux 배포판에서 사용하고 있다. `systemd`에서도 `init.d` 스크립트를 계속 사용할 수는 있지만, `systemd` '서비스' 스크립트를 사용해서 스프링 부트 애플리케이션을 기동하는 것도 가능하다.

스프링 부트 애플리케이션을 `/var/myapp`에 설치했다고 가정하고, 스프링 부트 애플리케이션을 `systemd` 서비스로 설치하려면 `myapp.service`라는 스크립트를 하나 만들어 `/etc/systemd/system` 디렉토리 안에 둬라. 다음은 스크립트 예시다:

```
[Unit]
Description=myapp
After=syslog.target

[Service]
User=myapp
ExecStart=/var/myapp/myapp.jar
SuccessExitStatus=143

[Install]
WantedBy=multi-user.target
```

> 애플리케이션에 맞게 `Description`, `User`, `ExecStart` 필드를 변경하는 걸 잊지 마라.

> 여기서 `ExecStart` 필드에는 스크립트 액션 커맨드를 선언하지 않는다. 즉, `run` 명령어를 기본으로 사용한다.

`init.d` 서비스로 실행할 때와 달리, 애플리케이션을 실행하는 user, PID 파일, 콘솔 로그 파일은 `systemd` 자체에서 관리하므로, 반드시 '서비스' 스크립트에서 적절한 필드를 사용해 설정해줘야 한다. 자세한 내용은 [서비스 유닛 설정 구성 매뉴얼 페이지](https://www.freedesktop.org/software/systemd/man/systemd.service.html)를 참고해라.

시스템 부팅 시 자동으로 애플리케이션을 시작하는 플래그를 지정하려면 다음 명령어를 사용해라:

```shell
$ systemctl enable myapp.service
```

자세한 설명이 필요하다면 `man systemctl`을 실행해봐라.

#### Customizing the Startup Script

메이븐 플러그인이나 그래들 플러그인으로 작성한 디폴트 임베디드 기동 스크립트는 여러 가지 방법으로 커스텀할 수 있다. 대부분은 디폴트 스크립트에서 몇 가지만 커스텀해서 쓰면 충분할 거다. 필요한 걸 커스텀할 수 없을 때는 `embeddedLaunchScript` 옵션을 사용해서 자체 파일을 처음부터 작성해라.

##### Customizing the Start Script When It Is Written

기동 스크립트의 요소 중엔 스크립트를 jar 파일에 임베딩시킬 때 커스텀해야 하는 게 있다. 예를 들어, init.d 스크립트는 "description"을 제공할 수 있다. description은 미리 알고 있는 정보기 때문에 (변경할 필요도 없기 때문에) jar를 생성하는 시점에도 제공할 수 있다.

이 요소들을 커스텀하려면 스프링 부트 메이븐 플러그인의 `embeddedLaunchScriptProperties` 옵션이나, [스프링 부트 그래들 플러그인의 `launchScript`에서 `properties`](https://docs.spring.io/spring-boot/docs/2.5.2/gradle-plugin/reference/htmlsingle/#packaging-executable-configuring-launch-script)를 사용해라.

디폴트 스크립트에선 다음과 같은 프로퍼티를 변경할 수 있다:

| Name                       | Description                                                  | Gradle default                                               | Maven default                                                |
| :------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| `mode`                     | 스크립트 모드                                                | `auto`                                                       | `auto`                                                       |
| `initInfoProvides`         | “INIT INFO”의 `Provides` 섹션.                               | `${task.baseName}`                                           | `${project.artifactId}`                                      |
| `initInfoRequiredStart`    | “INIT INFO”의 `Required-Start` 섹션.                         | <span class="custom-blockquote">$remote_fs $syslog $network</span> | <span class="custom-blockquote">$remote_fs $syslog $network</span> |
| `initInfoRequiredStop`     | “INIT INFO”의 `Required-Stop` 섹션.                          | <span class="custom-blockquote">$remote_fs $syslog $network<span class="custom-blockquote"> | <span class="custom-blockquote">$remote_fs $syslog $network</span> |
| `initInfoDefaultStart`     | “INIT INFO”의 `Default-Start` 섹션.                          | `2 3 4 5`                                                    | `2 3 4 5`                                                    |
| `initInfoDefaultStop`      | “INIT INFO”의 `Default-Stop` 섹션.                           | `0 1 6`                                                      | `0 1 6`                                                      |
| `initInfoShortDescription` | “INIT INFO”의 `Short-Description` 섹션.                      | `${project.description}`을 한 줄로 변경 (없을 땐 `${task.baseName}` 사용) | `${project.name}`                                            |
| `initInfoDescription`      | “INIT INFO”의 `Description` 섹션.                            | `${project.description}` (없을 땐 `${task.baseName}` 사용)   | `${project.description}` (없을 땐 `${task.baseName}` 사용)   |
| `initInfoChkconfig`        | “INIT INFO”의 `chkconfig` 섹션.                              | `2345 99 01`                                                 | `2345 99 01`                                                 |
| `confFolder`               | `CONF_FOLDER`의 기본값                                       | jar를 가지고 있는 폴더                                       | jar를 가지고 있는 폴더                                       |
| `inlinedConfScript`        | 디폴트 기동 스크립트에 인라인으로 추가해야 하는 파일 스크립트에 대한 레퍼런스. 다른 외부 컨피그 파일을 로드하기 전에 `JAVA_OPTS`같은 환경 변수를 설정하는 데 활용할 수 있다. |                                                              |                                                              |
| `logFolder`                | `LOG_FOLDER`의 기본값. `init.d` 서비스에만 유효하다          |                                                              |                                                              |
| `logFilename`              | `LOG_FILENAME`의 기본값. `init.d` 서비스에만 유효하다        |                                                              |                                                              |
| `pidFolder`                | `PID_FOLDER`의 기본값. `init.d` 서비스에만 유효하다          |                                                              |                                                              |
| `pidFilename`              | `PID_FOLDER`에 있는 PID 파일 이름에 사용할 기본값. `init.d` 서비스에만 유효하다 |                                                              |                                                              |
| `useStartStopDaemon`       | 가능한 경우 `start-stop-daemon` 명령어를 사용해서 프로세스를 제어해야 하는지 | `true`                                                       | `true`                                                       |
| `stopWaitTime`             | `STOP_WAIT_TIME`의 기본값 (초 단위). `init.d` 서비스에만 유효하다 | 60                                                           | 60                                                           |

##### Customizing a Script When It Runs

jar를 만든 *이후에* 커스텀해야 하는 스크립트 요소들은 환경 변수나 [컨피그 파일](#deployment.installing.nix-services.script-customization.when-running.conf-file)을 사용할 수 있다.

디폴트 스크립트에선 다음과 같은 환경 프로퍼티를 지원한다:

| Variable                | Description                                                  |
| :---------------------- | :----------------------------------------------------------- |
| `MODE`                  | 작동시킬 "모드". 기본값은 jar를 빌드한 방법에 따라 다르지만 보통은 `auto`다 (즉, `init.d`라는 디렉토리에 심볼릭 링크가 걸려있는지 확인해서 init 스크립트인지를 추정한다). `service`로 명시하면 `stop|start|status|restart` 명령어를 작동시킬 수 있으며, 포그라운드에서 스크립트를 실행하고 싶으면 `run`으로 설정해도 된다. |
| `RUN_AS_USER`           | 애플리케이션을 실행할 때 사용할 user. 설정하지 않으면 jar 파일을 소유한 user를 사용한다. |
| `USE_START_STOP_DAEMON` | 가능한 경우 `start-stop-daemon` 명령어를 사용해서 프로세스를 제어해야 하는지. 기본값은 `true`다. |
| `PID_FOLDER`            | pid 폴더의 루트 경로 (디폴트는 `/var/run`).                  |
| `LOG_FOLDER`            | 로그 파일을 저장할 폴더 이름 (디폴트는 `/var/log`).          |
| `CONF_FOLDER`           | .conf 파일을 읽어올 폴더 이름 (기본적으로는 jar 파일과 동일한 폴더 사용). |
| `LOG_FILENAME`          | `LOG_FOLDER`에 있는 로그 파일 이름 (디폴트는 `<appname>.log`). |
| `APP_NAME`              | 앱의 이름. jar가 심볼릭 링크에서 실행되면 스크립트에서 앱 이름을 추측한다. 심볼릭 링크가 아니거나 앱 이름을 명시하고 싶을 때 유용할 거다. |
| `RUN_ARGS`              | 프로그램(스프링 부트 앱)으로 전달할 인자들.                  |
| `JAVA_HOME`             | `java` 실행 파일의 위치는 기본적으로 `PATH`를 통해 찾지만, 실행 파일이 `$JAVA_HOME/bin/java`에 있을 땐 이 값을 명시할 수 있다. |
| `JAVA_OPTS`             | JVM을 띄울 때 JVM으로 전달할 옵션들.                         |
| `JARFILE`               | 스크립트로 실제로 임베딩시키지 않은 jar를 실행하는 경우, jar 파일의 명시적인 위치. |
| `DEBUG`                 | 이 값이 비어 있지 않으면 쉘 프로세스에 `-x` 플래그를 설정해 스크립트 안에 있는 로직을 직접 살펴볼 수 있다. |
| `STOP_WAIT_TIME`        | 애플리케이션을 중지할 때 대기할 시간 (초 단위). 이 시간이 지나면 애플리케이션을 강제로 종료한다 (기본값은 `60`). |

> `PID_FOLDER`, `LOG_FOLDER`, `LOG_FILENAME` 변수는 `init.d` 서비스에만 유효하다. `systemd`에선 'service' 스크립트를 사용해 같은 내용을 커스텀할 수 있다. 자세한 내용은 [서비스 유닛 설정 매뉴얼 페이지](https://www.freedesktop.org/software/systemd/man/systemd.service.html)를 참고해라.

<span id="deployment.installing.nix-services.script-customization.when-running.conf-file">위에 나열한 설정들은 `JARFILE`과 `APP_NAME`을 제외하고는 모두 `.conf` 파일로 설정할 수 있다. 이 파일은 jar 파일과 같은 경로에 있어야 하며, 파일명은 같지만 suffix가 `.jar`이 아닌 `.conf`여야 한다. 예를 들어 jar 파일이 `/var/myapp/myapp.jar`일 땐 다음 예시와 같은 `/var/myapp/myapp.conf` 컨피그 파일을 사용한다:

*myapp.conf*

```properties
JAVA_OPTS=-Xmx1024M
LOG_FOLDER=/custom/log/folder
```

> jar 파일 옆에 컨피그 파일을 두는 게 싫다면 환경 변수 `CONF_FOLDER`를 설정해서 컨피그 파일 위치를 커스텀하면 된다.

이 파일을 적절히 보호할 수 있는 방법이 알고싶다면 [init.d 서비스 보안을 위한 가이드라인](#securing-an-initd-service)을 참고해라.

### 9.3.3. Microsoft Windows Services

[`winsw`](https://github.com/kohsuke/winsw)를 활용하면 스프링 부트 애플리케이션을 Windows 서비스로 시작할 수 있다.

스프링 부트 애플리케이션을 위한 Windows 서비스를 생성하는 방법은 [별도로 관리하고 있는 샘플](https://github.com/snicoll/spring-boot-daemon)에서 단계별로 설명하고 있다.

---

## 9.4. What to Read Next

PaaS가 제공할 수 있는 기능들을 자세히 알고 싶으면 [Cloud Foundry](https://www.cloudfoundry.org/), [Heroku](https://www.heroku.com/), [OpenShift](https://www.openshift.com/), [Boxfuse](https://boxfuse.com/) 웹 사이트를 확인해봐라. 이 네 가지 말고도 인기 있는 자바 PaaS 공급 업체는 얼마든지 많다. 스프링 부트는 클라우드 기반으로 배포하기 매우 적합하기 때문에 다른 공급 업체도 자유롭게 고려해봐도 된다.

다음 섹션에선 *[스프링 부트 CLI](../spring-boot-cli)*를 다룬다. 아니면 CLI는 건너 뛰고 *[빌드 툴 플러그인](../build-tool-plugins)*에 관해 읽어봐도 좋다.