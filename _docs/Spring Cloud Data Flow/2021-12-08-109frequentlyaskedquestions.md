---
title: Frequently Asked Questions
category: Spring Cloud Data Flow
order: 109
permalink: /Spring%20Cloud%20Data%20Flow/resources.faq/
description: 자주 하는 질문들
image: ./../../images/springclouddataflow/logo.png
lastmod: 2021-12-08T01:00:00+09:00
comments: true
originalRefName: 스프링 클라우드 데이터 플로우
originalRefLink: https://dataflow.spring.io/docs/resources/faq/
parent: Resources
parentUrl: /Spring%20Cloud%20Data%20Flow/resources/
---

### 목차

- [Application Starters](#application-starters)
- [Data Flow](#data-flow)
- [Streaming](#streaming)
- [Batch](#batch)

---

## Application Starters

<div class="faq">
<p class="question"><span class="question-icon"></span><strong>최신 Spring Cloud Stream/Spring Cloud Task 애플리케이션 스타터는 어디에서 찾을 수 있나요?</strong></p>
<p class="answer" style="display: none;">스트림/태스크 애플리케이션 스타터의 최신 릴리즈는 Maven Central과 Docker Hub에 올라간다. 최신 릴리즈 버전은 프로젝트 사이트 <a href="https://cloud.spring.io/spring-cloud-stream-app-starters/">Spring Cloud Stream App Starters</a>와 <a href="https://cloud.spring.io/spring-cloud-task-app-starters/">Spring Cloud Task App Starters</a> 프로젝트에서 찾을 수 있다.</p>
</div>

<div class="faq">
<p class="question"><span class="question-icon"></span><strong>최신 애플리케이션 릴리즈에 관한 문서는 어디에서 찾을 수 있나요?</strong></p>
<p class="answer" style="display: none;">프로젝트 사이트 <a href="https://cloud.spring.io/spring-cloud-stream-app-starters/">Spring Cloud Stream App Starters</a>, <a href="https://cloud.spring.io/spring-cloud-task-app-starters/">Spring Cloud Task App Starters</a>를 확인해보면 된다.</p>
</div>

<div class="faq">
<p class="question"><span class="question-icon"></span><strong>기본 제공하는 애플리케이션들을 패치하거나 확장할 수 있나요?</strong></p>
<p class="answer" style="display: none;">가능하다. 자세한 내용은 레퍼런스 가이드에 있는 <a href="https://docs.spring.io/stream-applications/docs/2021.0.1/reference/html/#_patching_pre_built_applications">애플리케이션 스타터 패치하기</a> 섹션과 이 문서의 <a href="../feature-guides.stream.function-composition">Functional Composition</a>에서 확인할 수 있다.</p>
</div>

<div class="faq">
<p class="question"><span class="question-icon"></span><strong>새 애플리케이션을 기본 제공하는 애플리케이션과 동일한 구조로 만들 수 있나요?</strong></p>
<p class="answer" style="display: none;">가능하다. 자세한 내용은 Spring Cloud Stream App Starter의 레퍼런스 가이드에 있는 <a href="https://docs.spring.io/spring-cloud-stream-app-starters/docs/current/reference/htmlsingle/#_general_faq_on_spring_cloud_stream_app_starters">FAQ</a> 섹션을 확인해봐라.</p>
</div>

<div class="faq">
<p class="question"><span class="question-icon"></span><strong>최신 애플리케이션들은 어디서 다운받을 수 있나요?</strong></p>
<p class="answer" style="display: none;"><a href="https://cloud.spring.io/spring-cloud-stream-app-starters/#http-repository-location-for-apps">스트림</a>, <a href="https://cloud.spring.io/spring-cloud-task-app-starters/#http-repository-location-for-apps">태스크</a> 애플리케이션 프로젝트 사이트를 확인해봐라.</p>
</div>

<div class="faq">
<p class="question"><span class="question-icon"></span><strong>도커 이미지들은 어디에서 호스팅하나요?</strong></p>
<p class="answer" style="display: none;">도커 허브에서 <a href="https://hub.docker.com/u/springcloudstream">스트림</a>, <a href="https://hub.docker.com/u/springcloudtask">태스크</a> 애플리케이션을 검색해보면 된다.</p>
</div>

---

## Data Flow

<div class="faq">
<p class="question"><span class="question-icon"></span><strong>스트리밍 애플리케이션과 SCDF<sup>Spring Cloud Data Flow</sup>는 무슨 관련이 있나요?</strong></p>
<p class="answer" style="display: none;">스트리밍 애플리케이션은 독립 실행형 애플리케이션으로, RabbitMQ나 아파치 카프카같은 메세지 브로커를 통해 다른 애플리케이션들과 통신한다. 애플리케이션들은 독립적으로 실행되며, SCDF와 런타임 의존성은 없다. 단, SCDF는 사용자의 액션을 기반으로 플랫폼 런타임과 상호 작용해서 현재 실행 중인 애플리케이션을 업데이트하거나, 현재 상태를 질의하거나, 애플리케이션을 중단할 수 있다.</p>
</div>

<div class="faq">
<p class="question"><span class="question-icon"></span><strong>태스크/배치 애플리케이션과 SCDF<sup>Spring Cloud Data Flow</sup>는 무슨 관련이 있나요?</strong></p>
<p class="answer" style="display: none;">배치/태스크 애플리케이션은 독립 실행형 스프링 부트 애플리케이션이지만, 실행 상태를 기록하려면 <em>반드시</em> SCDF와 배치 애플리케이션을 같은 데이터베이스에 연결해야 한다. 그러면 배치 애플리케이션(SCDF로 배포한)들은 각자의 실행 상태를 공유 데이터베이스에 업데이트할 수 있다. SCDF 대시보드에선 이 데이터베이스를 사용해 배치 애플리케이션들의 실행 히스토리와 기타 세부 정보를 보여줄 수 있다. 배치/태스크 애플리케이션에선 SCDF 데이터베이스는 실행 상태를 기록하는 용도로만 연결하고, 실제 작업은 다른 데이터베이스로 진행하도록 구성하는 것도 가능하다.</p>
</div>

<div class="faq">
<p class="question"><span class="question-icon"></span><strong><a href="https://github.com/spring-cloud-task-app-starters/composed-task-runner">Composed Task Runner</a>와 SCDF는 무슨 관계인가요?</strong></p>
<p class="answer" style="display: none;"><a href="https://docs.spring.io/spring-cloud-dataflow/docs/2.9.1/reference/htmlsingle/#spring-cloud-dataflow-composed-tasks">Composed 태스크</a>에선 태스크들의 실행을 Composed Task Runner(CTR)라는 별도 애플리케이션에 위임한다. CTR은 Composed 태스크 그래프에 정의돼 있는 태스크들의 실행을 조율<sup>orchestration</sup>해준다. Composed 태스크를 사용하려면 SCDF, CTR, 배치 애플리케이션들을 같은 데이터베이스에 연결해야 한다. 그래야만 SCDF 대시보드로 모든 실행 히스토리를 추적할 수 있다.</p>
</div>

<div class="faq">
<p class="question"><span class="question-icon"></span><strong>SCDF가 메세지 브로커를 사용하나요?</strong></p>
<p class="answer" style="display: none;">그렇지 않다. Data Flow와 Skipper 서버는 메세지 브로커와는 직접 상호 작용하지 않는다. Data Flow로 배포한 스트리밍 애플리케이션들이 메세지 브로커에 연결해서 메세지를 발행하고 컨슘한다.</p>
</div>

<div class="faq">
<p class="question"><span class="question-icon"></span><strong>SCDF<sup>Spring Cloud Data Flow</sup>에서 Skipper가 담당하는 역할이 뭔가요?</strong></p>
<p class="answer" style="display: none;">SCDF는 스트리밍 애플리케이션들의 라이프사이클 관리는 Skipper로 위임하고 Skipper에 의존한다. Skipper를 사용하면 스트리밍 데이터 파이프라인을 구성하는 애플리케이션들에 버전을 지정할 수 있으며, 새 버전으로 업데이트하거나 (롤링 기반), 이전 버전으로 롤백할 수 있다.</p>
</div>

<div class="faq">
<p class="question"><span class="question-icon"></span><strong>SCDF<sup>Spring Cloud Data Flow</sup>와 상호 작용할 수 있는 툴은 어떤 게 있나요?</strong></p>
<div class="answer" style="display: none;">
<p>Spring Cloud Data Flow는 다음과 같은 툴로 상호 작용할 수 있다:</p>
<ul>
  <li><a href="https://docs.spring.io/spring-cloud-dataflow/docs/2.9.1/reference/htmlsingle/#shell">쉘</a></li>
  <li><a href="https://docs.spring.io/spring-cloud-dataflow/docs/2.9.1/reference/htmlsingle/#dashboard">대시보드</a></li>
  <li><a href="https://docs.spring.io/spring-cloud-dataflow/docs/2.9.1/reference/htmlsingle/#spring-cloud-dataflow-stream-java-dsl">자바 DSL</a></li>
  <li><a href="https://docs.spring.io/spring-cloud-dataflow/docs/2.9.1/reference/htmlsingle/#api-guide-resources">REST-API</a>.</li>
</ul>
</div>
</div>

<div class="faq">
<p class="question"><span class="question-icon"></span><strong>SCDF<sup>Spring Cloud Data Flow</sup>는 왜 Spring Initializr에 없나요?</strong></p>
<p class="answer" style="display: none;">Initializr는 스프링 부트 애플리케이션을 생성할 때 맨 처음 필요한 것들을 제공해주는 용도다. 프로덕션에서 바로 사용할 수 있는 서버 애플리케이션을 만드는 건 Initializr의 목표가 아니다. 과거에는 이 시도도 해봤지만, 의존 라이브러리들을 세밀하게 제어할 필요가 있어서 성공하지 못했다. 그렇기 때문에 대신에 바이너리를 직접 제공한다. 바이너리를 받아 그대로 사용하거나, 확장하고 싶다면 소스 코드를 받아 로컬에서 SCDF를 빌드하면 된다.</p>
</div>

<div class="faq">
<p class="question"><span class="question-icon"></span><strong>SCDF<sup>Spring Cloud Data Flow</sup>를 오라클 데이터베이스와 함께 사용할 수 있나요?</strong></p>
<p class="answer" style="display: none;">가능하다. 자세한 내용은 <a href="https://docs.spring.io/spring-cloud-dataflow/docs/2.9.1/reference/htmlsingle/#configuration-local-rdbms">지원하는 데이터베이스들</a>을 참고해라.</p>
</div>

<div class="faq">
<p class="question"><span class="question-icon"></span><strong>태스크 프로퍼티와 인자는 각각 언제 어디서 사용해야 하나요?</strong></p>
<div class="answer" style="display: none;">
<p>태스크를 실행할 때마다 그대로 사용할 설정들은, 태스크 정의를 생성할 때 프로퍼티로 지정해주면 된다. 그 방법은 아래 예시를 참고해라:</p>
<div class="language-sh highlighter-rouge"><div class="highlight"><pre class="highlight"><code>task create myTaskDefinition <span class="nt">--definition</span> <span class="s2">"timestamp --format='yyyy'"</span>
</code></pre></div></div>
<p>태스크를 실행할 때마다 바뀌는 설정은, 다음 예제와 같이 태스크 기동 시점에 인자로 추가해주면 된다:</p>
<div class="language-sh highlighter-rouge"><div class="highlight"><pre class="highlight"><code>task launch myTaskDefinition <span class="s2">"--server.port=8080"</span>
</code></pre></div></div>
<p>Spring Cloud Data Flow로 스프링 배치를 사용하는 태스크 애플리케이션 실행을 조율<sup>orchestration</sup>할 때는, 배치 job에 필요한 JobParameter는 인자를 사용해서 설정해야 한다.</p>
<p>참고: job 인스턴스를 식별하는 파라미터가 아니라면 <code class="highlighter-rouge">--</code> 뒤에 인자를 사용해라.</p>
</div>
</div>

<div class="faq">
<p class="question"><span class="question-icon"></span><strong>Composed 태스크 그래프에 있는 자식 태스크엔 커맨드라인 인자를 어떻게 전달하나요?</strong></p>
<div class="answer" style="display: none;">
<p>Composed Task Runner의 <code class="highlighter-rouge">composedTaskArguments</code> 프로퍼티를 사용하면 된다.</p>
<p>아래 예시에선, 커맨드라인 인자 <code class="highlighter-rouge">--timestamp.format=YYYYMMDD</code>는 composed 태스크 그래프에 있는 모든 자식 태스크에 적용된다.</p>
<div class="language-sh highlighter-rouge"><div class="highlight"><pre class="highlight"><code>task launch myComposedTask <span class="nt">--arguments</span> <span class="s2">"--composedTaskArguments=--timestamp.format=YYYYMMDD"</span>
</code></pre></div></div>
</div>
</div>

<div class="faq">
<p class="question"><span class="question-icon"></span><strong>리모트 메이븐 레포지토리는 어떻게 설정할 수 있나요?</strong></p>
<div class="answer" style="display: none;">
<p>메이븐 프로퍼티(ex. 로컬 메이븐 레포지토리 위치, 리모트 메이븐 레포지토리, 인증 credential, 프록시 서버 프로퍼티 등)는 Data Flow 서버를 시작할 때 커맨드라인 속성으로 지정하면 된다. 아니면 Data Flow 서버의 환경 변수에 <code class="highlighter-rouge">SPRING_APPLICATION_JSON</code>을 설정해도 된다.</p>
<p>앱들을 메이븐 레포지토리에서 리졸브한다면, <code class="highlighter-rouge">local</code> Data Flow 서버를 제외하고는 리모트 메이븐 레포지토리를 설정에 명시해줘야 한다. 다른 Data Flow 서버 구현체에는 (앱 아티팩트를 메이븐 리소스로 리졸브하는) 리모트 레포지토리에 대한 기본값이 따로 없다. <code class="highlighter-rouge">local</code> 서버는 <code class="highlighter-rouge">https://repo.spring.io/libs-snapshot</code>을 디폴트 리모트 레포지토리로 가지고 있다.</p>
<p>커맨드라인 옵션으로 프로퍼티를 전달하려면, 아래 보이는 명령어처럼 서버를 실행하면 된다:</p>
<div class="language-bash highlighter-rouge"><div class="highlight"><pre class="highlight"><code>java <span class="nt">-jar</span> &lt;dataflow-server&gt;.jar <span class="nt">--maven</span>.localRepository<span class="o">=</span>mylocal
<span class="nt">--maven</span>.remote-repositories.repo1.url<span class="o">=</span>https://repo1
<span class="nt">--maven</span>.remote-repositories.repo1.auth.username<span class="o">=</span>repo1user
<span class="nt">--maven</span>.remote-repositories.repo1.auth.password<span class="o">=</span>repo1pass
<span class="nt">--maven</span>.remote-repositories.repo2.url<span class="o">=</span>https://repo2 <span class="nt">--maven</span>.proxy.host<span class="o">=</span>proxyhost
<span class="nt">--maven</span>.proxy.port<span class="o">=</span>9018 <span class="nt">--maven</span>.proxy.auth.username<span class="o">=</span>proxyuser
<span class="nt">--maven</span>.proxy.auth.password<span class="o">=</span>proxypass
</code></pre></div></div>
<p>환경 변수 <code class="highlighter-rouge">SPRING_APPLICATION_JSON</code>을 설정할 수도 있다:</p>
<div class="language-bash highlighter-rouge"><div class="highlight"><pre class="highlight"><code><span class="nb">export </span><span class="nv">SPRING_APPLICATION_JSON</span><span class="o">=</span><span class="s1">'{ "maven": { "local-repository": "local","remote-repositories": { "repo1": { "url": "https://repo1", "auth": { "username": "repo1user", "password": "repo1pass" } },
"repo2": { "url": "https://repo2" } }, "proxy": { "host": "proxyhost", "port": 9018, "auth": { "username": "proxyuser", "password": "proxypass" } } } }'</span>
</code></pre></div></div>
<p>다음은 같은 내용을 JSON 형식에 맞게 정렬해둔 거다:</p>
<div class="language-sh highlighter-rouge"><div class="highlight"><pre class="highlight"><code><span class="nb">export </span><span class="nv">SPRING_APPLICATION_JSON</span><span class="o">=</span><span class="s1">'{
  "maven": {
    "local-repository": "local",
    "remote-repositories": {
      "repo1": {
        "url": "https://repo1",
        "auth": {
          "username": "repo1user",
          "password": "repo1pass"
        }
      },
      "repo2": {
        "url": "https://repo2"
      }
    },
    "proxy": {
      "host": "proxyhost",
      "port": 9018,
      "auth": {
        "username": "proxyuser",
        "password": "proxypass"
      }
    }
  }
}'</span>
</code></pre></div></div>
<p>Spring Cloud Data Flow 서버 구현체에 따라, 환경 변수는 플랫폼 전용 환경 세팅 기능을 통해서 전달해야 할 거다. 예를 들어, 클라우드 파운드리에서는 <code class="highlighter-rouge">cf set-env &lt;your app&gt; SPRING_APPLICATION_JSON '{...</code>으로 전달한다.</p>
</div>
</div>

<div class="faq">
<p class="question" id="debuglogs"><span class="question-icon"></span><strong>플랫폼 배포 로그를 DEBUG 레벨로 바꾸려면 어떻게 해야 하나요?</strong></p>
<div class="answer" style="display: none;">
<p>Spring Cloud Data Flow는 <a href="https://github.com/spring-cloud/spring-cloud-deployer">Spring Cloud Deployer</a> SPI를 기반으로 동작하며, 각 플랫폼별 dataflow 서버는 각자의 <a href="https://github.com/spring-cloud?utf8=✓&amp;q=spring-cloud-deployer">SPI 구현체</a>를 사용한다. 특히, 네트워크 오류같은 배포 이슈를 트러블슈팅 중이라면, 내부 deployer와 여기서 사용하는 라이브러리에 DEBUG 로그를 활성화해보는 게 좋다.</p>
<p><a href="https://github.com/spring-cloud/spring-cloud-deployer-local">local-deployer</a>의 DEBUG 로그를 활성화하려면 다음과 같이 서버를 시작하면 된다:</p>
<div class="language-bash highlighter-rouge"><div class="highlight"><pre class="highlight"><code>java <span class="nt">-jar</span> &lt;dataflow-server&gt;.jar <span class="nt">--logging</span>.level.org.springframework.cloud.deployer.spi.local<span class="o">=</span>DEBUG
</code></pre></div></div>
<p>(이때 <code class="highlighter-rouge">org.springframework.cloud.deployer.spi.local</code>은 local-deployer와 관련된 모든 것들을 포함하고 있는 글로벌 패키지다.)</p>
<p><a href="https://github.com/spring-cloud/spring-cloud-deployer-cloudfoundry">cloudfoundry-deployer</a>의 DEBUG 로그를 활성화하려면, 환경 변수 <code class="highlighter-rouge">logging.level.cloudfoundry-client</code>를 설정하고 Data Flow 서버를 restage하고 나면, 요청/응답과 관련된 더 상세한 로그와 실패한 지점의 세부 스택 트레이스를 확인할 수 있다. 클라우드 파운드리 deployer는 <a href="https://github.com/cloudfoundry/cf-java-client">cf-java-client</a>를 사용하므로, 이 라이브러리에도 DEBUG 로그를 활성화해야 한다:</p>
<div class="language-bash highlighter-rouge"><div class="highlight"><pre class="highlight"><code>cf set-env dataflow-server JAVA_OPTS <span class="s1">'-Dlogging.level.cloudfoundry-client=DEBUG'</span>
cf restage dataflow-server
</code></pre></div></div>
<p>(이때 <code class="highlighter-rouge">cloudfoundry-client</code>는 <code class="highlighter-rouge">cf-java-client</code>와 관련된 모든 것들을 포함하고 있는 글로벌 패키지다.)</p>
<p><code class="highlighter-rouge">cf-java-client</code>에서 사용하는 리액터 로그도 검토하고 싶다면, 아래 명령어를 실행하면 된다:</p>
<div class="language-bash highlighter-rouge"><div class="highlight"><pre class="highlight"><code>cf set-env dataflow-server JAVA_OPTS <span class="s1">'-Dlogging.level.cloudfoundry-client=DEBUG -Dlogging.level.reactor.ipc.netty=DEBUG'</span>
cf restage dataflow-server
</code></pre></div></div>
<p>(이때 <code class="highlighter-rouge">reactor.ipc.netty</code>는 <code class="highlighter-rouge">reactor-netty</code>와 관련된 모든 것들을 포함하고 있는 글로벌 패키지다.)</p>
<p>위에서 보여준 <code class="highlighter-rouge">local-deployer</code>, <code class="highlighter-rouge">cloudfoundry-deployer</code> 옵션과 유사하게, 쿠버네티스에서도 같은 설정을 추가할 수 있다. 로그를 설정해줘야 하는 패키지 정보는 <a href="https://github.com/orgs/spring-cloud/repositories?q=spring-cloud-deployer">각 deployer SPI 구현체</a>를 참고해라.</p>
</div>
</div>

<div class="faq">
<p class="question"><span class="question-icon"></span><strong>애플리케이션 배포 로그를 DEBUG 레벨로 바꾸려면 어떻게 해야 하나요?</strong></p>
<div class="answer" style="display: none;">
<p>Spring Cloud Data Flow의 스트리밍 애플리케이션은 Spring Cloud Stream 애플리케이션이다. 따라서 스프링 부트 기반이기 때문에, 각자 로그를 독립적으로 세팅할 수 있다.</p>
<p>예를 들어 소스, 프로세서, 싱크 채널을 통해 전달하는 <code class="highlighter-rouge">header</code>, <code class="highlighter-rouge">payload</code>와 관련된 이슈를 트러블슈팅 중이라면, 다음 옵션을 사용해서 스트림을 배포해야 한다:</p>
<div class="language-bash highlighter-rouge"><div class="highlight"><pre class="highlight"><code>dataflow:&gt;stream create foo <span class="nt">--definition</span> <span class="s2">"http --logging.level.org.springframework.integration=DEBUG | transform --logging.level.org.springframework.integration=DEBUG | log --logging.level.org.springframework.integration=DEBUG"</span> <span class="nt">--deploy</span>
</code></pre></div></div>
<p>(이때 <code class="highlighter-rouge">org.springframework.integration</code>은 메세징 채널을 담당하는 Spring Integration과 관련된 모든 것들을 포함하고 있는 글로벌 패키지다)</p>
<p>이런 옵션들은 스트림 배포 시점에 <code class="highlighter-rouge">deployment</code> 프로퍼티로 지정할 수도 있다:</p>
<div class="language-bash highlighter-rouge"><div class="highlight"><pre class="highlight"><code>dataflow:&gt;stream deploy foo <span class="nt">--properties</span> <span class="s2">"app.*.logging.level.org.springframework.integration=DEBUG"</span>
</code></pre></div></div>
</div>
</div>

<div class="faq">
<p class="question" id="remotedebug"><span class="question-icon"></span><strong>배포한 애플리케이션을 원격에서 디버깅하려면 어떻게 해야 하나요?</strong></p>
<div class="answer" style="display: none;">
<p>Data Flow 로컬 서버에선 배포한 애플리케이션들을 디버깅할 수 있다. 다음과 같이 배포 프로퍼티를 통해 JVM의 원격 디버깅 기능을 활성화하면 된다:</p>
<div class="language-bash highlighter-rouge"><div class="highlight"><pre class="highlight"><code>stream deploy <span class="nt">--name</span> mystream <span class="nt">--properties</span> <span class="s2">"deployer.fooApp.local.debugPort=9999"</span>
</code></pre></div></div>
<p>위 예시에선 <code class="highlighter-rouge">fooApp</code> 애플리케이션을 디버그 모드로 시작해서, 원격 디버거가 9999 포트에 연결된다. 이 애플리케이션은 기본적으로  “suspend” 모드에서 시작되며, 원격 디버그 세션이 연결(시작)될 때까지 기다린다. 아니면 <code class="highlighter-rouge">debugSuspend</code> 프로퍼티를 <code class="highlighter-rouge">n</code>으로 추가할 수도 있다.</p>
<p>추가로, 애플리케이션 인스턴스가 둘 이상일 때는, 각 인스턴스의 디버그 포트는 <code class="highlighter-rouge">debugPort</code> + <code class="highlighter-rouge">instanceId</code>가 된다.</p>
<p>각 애플리케이션은 반드시 고유한 디버그 포트를 사용해야 하므로, 다른 프로퍼티와는 달리 애플리케이션 이름에 와일드카드를 사용해선 안 된다.</p>
</div>
</div>

<div class="faq">
<p class="question" id="aggregatelogs"><span class="question-icon"></span><strong>로컬 배포 내역을 단일 로그로 집계할 수 있나요?</strong></p>
<div class="answer" style="display: none;">
<p>각 애플리케이션들이 자체 로그 셋을 가지는 별도의 프로세스라는 점을 감안하면, 개별 로그에 따로따로 접근하는 건 다소 불편한 감이 있다. 특히 로그를 자주 확인해봐야 하는 개발 초기 단계에선 더 그렇다. 로컬 SCDF 서버를 이용해 각 애플리케이션들을 로컬 JVM 프로세스로 배포하고, 로컬 SCDF 서버에 의존하는 건 일반적인 패턴이기도 하다. 그렇기 때문에 배포한 애플리케이션의 stdout과 stdin은 상위 프로세스로 리다이렉트할 수 있다. 따라서 로컬 SCDF 서버를 이용하면, 애플리케이션 로그를, 실행 중인 로컬 SCDF 서버의 로그에서 확인할 수 있다.</p>
<p>일반적으로 스트림을 배포할 땐, 서버 로그에선 다음과 유사한 문구를 보게 된다:</p>
<div class="language-bash highlighter-rouge"><div class="highlight"><pre class="highlight"><code>017-06-28 09:50:16.372  INFO 41161 <span class="nt">---</span> <span class="o">[</span>nio-9393-exec-7] o.s.c.d.spi.local.LocalAppDeployer       : Deploying app with deploymentId mystream.myapp instance 0.
   Logs will be <span class="k">in</span> /var/folders/l2/63gcnd9d7g5dxxpjbgr0trpw0000gn/T/spring-cloud-dataflow-5939494818997196225/mystream-1498661416369/mystream.myapp
</code></pre></div></div>
<p>하지만 배포 프로퍼티에 <code class="highlighter-rouge">local.inheritLogging=true</code>를 설정해주면, 다음과 같은 로그를 볼 수 있다:</p>
<div class="language-bash highlighter-rouge"><div class="highlight"><pre class="highlight"><code>017-06-28 09:50:16.372  INFO 41161 <span class="nt">---</span> <span class="o">[</span>nio-9393-exec-7] o.s.c.d.spi.local.LocalAppDeployer       : Deploying app with deploymentId mystream.myapp instance 0.
   Logs will be inherited.
</code></pre></div></div>
<p>이후 다음과 같이 스트림을 배포하면, 애플리케이션 로그와 서버 로그가 함께 보인다:</p>
<div class="language-bash highlighter-rouge"><div class="highlight"><pre class="highlight"><code>stream deploy <span class="nt">--name</span> mystream <span class="nt">--properties</span> <span class="s2">"deployer.*.local.inheritLogging=true"</span>
</code></pre></div></div>
<p>위 스트림 정의에선 스트림을 구성하는 모든 애플리케이션에 로그 리다이렉션을 활성화한다. 다음 스트림 정의는 <code class="highlighter-rouge">my app</code>이라는 애플리케이션에만 로그 리다이렉션을 활성화한다:</p>
<div class="language-bash highlighter-rouge"><div class="highlight"><pre class="highlight"><code>stream deploy <span class="nt">--name</span> mystream <span class="nt">--properties</span> <span class="s2">"deployer.myapp.local.inheritLogging=true"</span>
</code></pre></div></div>
<p>태스크 애플리케이션을 실행할 때도 마찬가지로 같은 옵션으로 모든 로그를 리다이렉트하고 집계할 수 있다. 태스크에서도 프로퍼티는 동일하다.</p>
<p>참고: 로그 리다이렉트는 <a href="https://github.com/spring-cloud/spring-cloud-deployer-local">local-deployer</a>에서만 지원한다.</p>
</div>
</div>

<div class="faq">
<p class="question"><span class="question-icon"></span><strong>스트리밍 애플리케이션에 대한 고정 라우트나, URL, IP 주소는 어떻게 얻을 수 있나요?</strong></p>
<div class="answer" style="display: none;">
<p>특정 애플리케이션에 대한 고정 IP 주소가 필요하다면, <code class="highlighter-rouge">LoadBalancer</code> 타입 서비스를 직접 정의하고 쿠버네티스의 label selector 기능을 이용해 할당된 고정 IP 주소로 트래픽을 라우팅하면 된다.</p>
<p>다음은 <code class="highlighter-rouge">LoadBalancer</code> deployment 예시다:</p>
<div class="language-yaml highlighter-rouge"><div class="highlight"><pre class="highlight"><code><span class="na">kind</span><span class="pi">:</span> <span class="s">Service</span>
<span class="na">apiVersion</span><span class="pi">:</span> <span class="s">v1</span>
<span class="na">metadata</span><span class="pi">:</span>
  <span class="na">name</span><span class="pi">:</span> <span class="s">foo-lb</span>
  <span class="na">namespace</span><span class="pi">:</span> <span class="s">kafkazone</span>
<span class="na">spec</span><span class="pi">:</span>
  <span class="na">ports</span><span class="pi">:</span>
    <span class="pi">-</span> <span class="na">port</span><span class="pi">:</span> <span class="s">80</span>
      <span class="na">name</span><span class="pi">:</span> <span class="s">http</span>
      <span class="na">targetPort</span><span class="pi">:</span> <span class="s">8080</span>
  <span class="na">selector</span><span class="pi">:</span>
    <span class="na">FOOZ</span><span class="pi">:</span> <span class="s">BAR-APP</span>
  <span class="na">type</span><span class="pi">:</span> <span class="s">LoadBalancer</span>
</code></pre></div></div>
<p>이 deployment는 고정 IP 주소를 생성한다. 예를 들어 <code class="highlighter-rouge">foo-lb</code>의 IP 주소가 “10.20.30.40”이라고 가정해보자.</p>
<p>이제 스트림을 배포할 때 label selector를 원하는 애플리케이션에 연결할 수 있으므로 (예: <code class="highlighter-rouge">deployer.&lt;yourapp&gt;.kubernetes.deploymentLabels=FOOZ: BAR-APP</code>), <code class="highlighter-rouge">10.20. 30.40</code>으로 들어오는 모든 트래픽은 자동으로 <code class="highlighter-rouge">yourapp</code>에서 받게 된다.</p>
<p>이 설정에선 앱을 업그레이드하거나 SCDF에서 스트림을 재배포 또는 업데이트해도, 고정 IP 주소는 변경되지 않고 쭉 유지된다. 따라서 업스트림이나 다운스트림 트래픽에선 이 주소에 의존할 수 있다.</p>
</div>
</div>

---

## Streaming


<div class="faq">
<p class="question"><span class="question-icon"></span><strong>기존 RabbitMQ 큐에 연결할 수 있나요?</strong></p>
<p class="answer" style="display: none;">기존 RabbitMQ 큐에 연결하고 싶다면 <a href="https://cloud.spring.io/spring-cloud-static/spring-cloud-stream-binder-rabbit/2.2.0.RC1/spring-cloud-stream-binder-rabbit.html#_using_existing_queuesexchanges">레퍼런스 가이드</a>에서 설명하는대로 따라하면 된다.</p>
</div>

<div class="faq">
<p class="question"><span class="question-icon"></span><strong>아파치 카프카와 Spring Cloud Stream의 호환성은 어떤가요?</strong></p>
<p class="answer" style="display: none;">위키에 있는 <a href="https://github.com/spring-cloud/spring-cloud-stream/wiki/Kafka-Client-Compatibility">호환성 테이블</a>을 확인해봐라.</p>
</div>

<div class="faq">
<p class="question"><span class="question-icon"></span><strong>바인딩 라이프사이클을 직접 관리할 수 있나요?</strong></p>
<div class="answer" style="display: none;">
<p>기본적으로 애플리케이션이 초기화될 때 자동으로 바인딩을 시작한다. 바인딩에는 스프링의 <code class="highlighter-rouge">SmartLifecycle</code> 인터페이스를 구현해서 사용하고 있다. <code class="highlighter-rouge">SmartLifecycle</code>을 이용하면 빈들을 단계적으로 시작할 수 있다. 프로듀서 바인딩은 초기 단계에서 시작한다 (<code class="highlighter-rouge">Integer.MIN_VALUE + 1000</code>). 컨슈머 바인딩은 거의 마지막 단계에서 시작한다 (<code class="highlighter-rouge">Integer.MAX_VALUE - 1000</code>). 여유를 많이 남겨뒀기 때문에, 커스텀 빈에서 <code class="highlighter-rouge">SmartLifecycle</code>을 구현하면, 프로듀서 바인딩 전과 컨슈머 바인딩 후 어느 시점에서든지 커스텀 빈을 시작하게 만들어줄 수 있다.</p>
<p>컨슈머나 프로듀서의 <code class="highlighter-rouge">autoStartup</code> 프로퍼티를 <code class="highlighter-rouge">false</code>로 설정하면 자동 시작을 비활성화할 수 있다.</p>
<p>부트 액추에이터를 사용하면 바인딩 라이프사이클을 시각화하고 제어할 수도 있다. <a href="https://docs.spring.io/spring-cloud-stream/docs/current/reference/html/spring-cloud-stream.html#binding_visualization_control">바인딩 시각화와 제어</a>를 참고해라.</p>
<p>다음과 같은 코드로도 바인딩 이름을 통해 액추에이터 엔드포인트를 호출할 수 있다:</p>
<div class="language-java highlighter-rouge"><div class="highlight"><pre class="highlight"><code><span class="nd">@Autowired</span>
<span class="kd">private</span> <span class="n">BindingsEndpoint</span> <span class="n">endpoint</span><span class="o">;</span>

<span class="o">...</span>

    <span class="n">bindings</span><span class="o">.</span><span class="na">changeState</span><span class="o">(</span><span class="s">"myFunction-in-0"</span><span class="o">,</span> <span class="n">State</span><span class="o">.</span><span class="na">STARTED</span><span class="o">);</span>
</code></pre></div></div>
<p>위 예시에선 이전에 중지됐던(혹은 <code class="highlighter-rouge">autoStartup=false</code>) <code class="highlighter-rouge">myFunction-in-0</code>이라는 바인딩을 시작한다. 실행 중인 바인딩을 중지할 땐 <code class="highlighter-rouge">State.STOPPED</code>를 사용한다. 카프카같은 일부 바인더에선 컨슈머 바인딩에 <code class="highlighter-rouge">State.PAUSED</code>와 <code class="highlighter-rouge">State.RESUMED</code>도 지원한다.</p>
<p><code class="highlighter-rouge">BindingsEndpoint</code>는 액추에이터 인프라에 속하기 때문에, <a href="https://cloud.spring.io/spring-cloud-static/spring-cloud-stream/current/reference/html/spring-cloud-stream.html#binding_visualization_control">바인딩 시각화와 제어</a>에서 설명하는 대로 액추에이터 지원을 활성화해야 한다.</p>
</div>
</div>

---

## Batch

<div class="faq">
<p class="question"><span class="question-icon"></span><strong>Composed Task Runner (CTR)가 뭔가요?</strong></p>
<p class="answer" style="display: none;">SCDF<sup>Spring Cloud Data Flow</sup>의 <a href="https://docs.spring.io/spring-cloud-dataflow/docs/2.9.1/reference/htmlsingle/#spring-cloud-dataflow-composed-tasks">Composed 태스크</a> 기능에선 composed 태스크 실행을 Composed Task Runner(CTR)라는 별도 애플리케이션에 위임한다. CTR은 태스크 그래프에 정의돼 있는 태스크들의 실행을 조율<sup>orchestration</sup>해준다. CTR은 그래프 DSL을 파싱하고, 그래프의 각 노드마다 지정한 Spring Cloud Data Flow 인스턴스에 RESTful API를 호출해서 관련 태스크 정의를 시작한다. Composed Task Runner는 태스크 정의를 실행할 때마다 데이터베이스를 폴링해서 해당 태스크가 완료됐는지 확인한다. 태스크가 완료되고 나면, Composed Task Runner는 DSL에서 태스크들의 실행 방식을 지정한 방식에 따라 그래프의 다음 태스크를 이어갈 수도 있고 실패로 끝낼 수도 있다.</p>
</div>

<div class="faq">
<p class="question"><span class="question-icon"></span><strong>스프링 배치 Job을 실패한 지점부터가 아니라 아예 처음부터 다시 시작하려면 어떻게 해야 하나요?</strong></p>
<div class="answer" style="display: none;">
<p>간단히 말하면, 태스크 새로 시작하려면 Job 인스턴스를 새로 생성해야 한다. 그러려면 다음번에 태스크를 실행할 때는 기존 식별용 job 파라미터를 하나 변경하거나, 식별용 job 파라미터를 새로 하나 추가해주면 된다. 다음 예시는 태스크를 시작하는 전형적인 명령어다:</p>
<div class="language-sh highlighter-rouge"><div class="highlight"><pre class="highlight"><code>task launch myBatchApp <span class="nt">--arguments</span><span class="o">=</span><span class="s2">"team=yankees"</span>
</code></pre></div></div>
<p>위 태스크가 실행에 실패했다고 가정하고, 이 태스크를 다시 한 번 시작해보자. 아래 예시처럼 <code class="highlighter-rouge">team</code> 파라미터 값을 변경해주면 job 인스턴스가 새로 생성된다:</p>
<div class="language-sh highlighter-rouge"><div class="highlight"><pre class="highlight"><code>task launch myBatchApp <span class="nt">--arguments</span><span class="o">=</span><span class="s2">"team=cubs"</span>
</code></pre></div></div>
<p>하지만 실제로 권장하는 방법은, 태스크나 배치 애플리케이션 자체에서 job 인스턴스를 새로 처리해 재시작하도록 코드를 작성하는 거다. <a href="../..//Spring%20Batch/configuringandrunningajob/#464-jobparametersincrementer">스프링 배치 레퍼런스 가이드</a>에서 설명하는 대로 배치 job에 <code class="highlighter-rouge">JobParamsIncrementer</code>를 설정해줘도 좋다.</p>
</div>
</div>

<div class="faq">
<p class="question"><span class="question-icon"></span><strong>태스크 실행 내역에 종료 시간이 보이지 않는 이유가 뭔가요?</strong></p>
<div class="answer" style="display: none;">
<p>이 문제는 세 가지 이유로 발생할 수 있다:</p>
<ul>
  <li>애플리케이션이 실제로 아직 실행 중일 수도 있다. 태스크의 실행 상태를 확인하려면, task execution detail 페이지에서 태스크 로그를 조회해보면 된다.</li>
  <li>애플리케이션이 SIG-KILL로 종료됐을 수도 있다. 이 경우엔 Spring Cloud Task가 애플리케이션이 종료 중이라는 신호를 받지 못한다. 정확히 말하면 태스크의 프로세스가 종료된다.</li>
  <li>컨텍스트가 계속 열려 있는 Spring Cloud Task 애플리케이션을 실행하고 있을 수도 있다 (ex. <code class="highlighter-rouge">TaskExecutor</code>를 사용 중이라면). 이 경우엔 태스크를 시작할 때 <code class="highlighter-rouge">spring.cloud.task.closecontext_enabled</code> 프로퍼티를 <code class="highlighter-rouge">true</code>로 설정해주면 된다. 이 설정을 추가해주면, 태스크가 완료되고 나서 애플리케이션 컨텍스트가 닫히므로, 애플리케이션을 종료하고 종료 시간을 기록할 수 있다.</li>
</ul>
</div>
</div>

<div class="faq">
<p class="question"><span class="question-icon"></span><strong>Spring Batch Admin을 Spring Cloud Data Flow로 마이그레이션하고 싶어요. 스프링 배치 job에서 사용하던 기존 데이터베이스를 재사용할 수 있나요?</strong></p>
<p class="answer" style="display: none;">불가능하다. Spring Cloud Data Flow는 스프링 배치 테이블을 포함하는 자체 스키마를 생성한다. Spring Cloud Data Flow가 대시보드나 쉘에서 스프링 배치 job 실행 상태를 표시하려면, 스프링 배치 앱들은 Spring Cloud Data Flow와 동일한 “datasource” 설정을 사용해야 한다.</p>
</div>

<script>
 var questions = document.getElementsByClassName("question")
  for (i = 0; i < questions.length; i++) {
    questions[i].addEventListener("click",function(){
    var target = event.target || event.srcElement;
    var answer = target.closest('.faq').querySelector(".answer")
        if (answer.style.display == "none") {
            answer.style.display = "block";
        }
        else {
            answer.style.display = "none";
        }
    });
  }
</script>

<style>
.question,.answer{
    padding-left:20px;
}
.question:before{
    content: '';
    background:url('./../../images/springclouddataflow/arrowright.png');
    background-size:cover;
    position:absolute;
    width:15px;
    height:15px;
    margin-left:-18px;
    margin-top: 6px;
}
</style>