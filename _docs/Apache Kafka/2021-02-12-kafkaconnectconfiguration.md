---
title: Kafka Connect Configuration
category: Apache Kafka
order: 8
permalink: /Apache%20Kafka/kafka-connect-configuration/
description: 아파치 카프카 공식 문서에 있는 카프카 커넥트 설정을 한글로 번역한 문서입니다.
image: ./../../images/kafka/logo.png
lastmod: 2021-02-14T22:25:00+09:00
comments: true
originalRefName: 아파치 카프카
originalRefLink: https://kafka.apache.org/27/documentation.html#connectconfigs
---

### 목차

- [3.5 Kafka Connect Configs](#35-kafka-connect-configs)
  + [3.5.1 Source Connector Configs](#351-source-connector-configs)
  + [3.5.2 Sink Connector Configs](#352-sink-connector-configs)

---

## 3.5 Kafka Connect Configs

다음은 카프카 커넥트 프레임워크의 설정이다.

- #### config.storage.topic

  커넥터 설정을 저장할 카프카 토픽명

  |         Type: | string |
  | ------------: | ------ |
  |      Default: |        |
  | Valid Values: |        |
  |   Importance: | high   |

- #### group.id

  이 워커가 속한 커넥트 클러스터 그룹을 식별하는 고유 문자열.

  |         Type: | string |
  | ------------: | ------ |
  |      Default: |        |
  | Valid Values: |        |
  |   Importance: | high   |

- #### key.converter

  카프카 커넥트 포맷과 카프카에 기록한 직렬화된 포맷 간을 변환할 때 사용할 컨버터 클래스. 카프카에서 쓰거나 읽은 메세지 키 포맷은 이 클래스가 제어하며, 컨버터는 커넥터와는 독립적이기 때문에, 사용하는 커넥터와는 무관하게 어떤 직렬화 포맷으로도 작업할 수 있다. 많이 사용하는 포맷으로는 JSON, Avro가 있다.

  |         Type: | class |
  | ------------: | ----- |
  |      Default: |       |
  | Valid Values: |       |
  |   Importance: | high  |

- #### offset.storage.topic

  커넥터 오프셋을 저장할 카프카 토믹명

  |         Type: | string |
  | ------------: | ------ |
  |      Default: |        |
  | Valid Values: |        |
  |   Importance: | high   |

- #### status.storage.topic

  커넥터와 태스크 상태를 저장할 카프카 토픽명

  |         Type: | string |
  | ------------: | ------ |
  |      Default: |        |
  | Valid Values: |        |
  |   Importance: | high   |

- #### value.converter

  카프카 커넥트 포맷과 카프카에 기록한 직렬화된 포맷 간을 변환할 때 사용할 컨버터 클래스. 카프카에서 쓰거나 읽은 메세지 값 포맷은 이 클래스가 제어하며, 컨버터는 커넥터와는 독립적이기 때문에, 사용하는 커넥터와는 무관하게 어떤 직렬화 포맷으로도 작업할 수 있다. 많이 사용하는 포맷으로는 JSON, Avro가 있다.

  |         Type: | class |
  | ------------: | ----- |
  |      Default: |       |
  | Valid Values: |       |
  |   Importance: | high  |

- #### bootstrap.servers

  카프카 클러스터에 대한 초기 커넥션을 구축하는 데 사용할 호스트/포트 쌍 리스트. 클라이언트가 부트스트랩될 땐 여기에 지정한 서버랑은 상관 없이 모든 서버를 사용하게 된다 — 이 리스트에 따라 전체 서버 셋을 발견하기 위한 초기 호스트만 달리질 뿐이다. 리스트엔 `host1:port1,host2:port2,...` 포맷을 사용해야 한다. 이 서버들은 전체 클러스터 멤버십(동적으로 변경될 수 있음)을 발견하기 위한 초기 커넥션에만 사용하기 때문에, 모든 서버를 다 넣어야 하는 건 아니다 (단, 서버 하나가 다운됐다면 최소 두 개가 필요할 순 있다).

  |         Type: | list           |
  | ------------: | -------------- |
  |      Default: | localhost:9092 |
  | Valid Values: |                |
  |   Importance: | high           |

- #### heartbeat.interval.ms

  카프카의 그룹 관리 기능을 사용할 때, 그룹 코디네이터에 보내는 하트비트의 예상 시간 간격. 하트비트를 이용해 워커의 세션이 활성 상태인지 확인하고, 그룹에 새 멤버가 들어오거나 나갈 때 리밸런스를 촉진한다. [`session.timeout.ms`](#sessiontimeoutms)보다 낮게 설정해야 하지만, 보통은 이 값의 1/3 이하로 설정하는 게 좋다. 일반적인 리밸런스 시간을 제어하려면 더 낮게 조정할 수도 있다.

  |         Type: | int              |
  | ------------: | ---------------- |
  |      Default: | 3000 (3 seconds) |
  | Valid Values: |                  |
  |   Importance: | high             |

- #### rebalance.timeout.ms

  리밸런스가 시작된 후 각 워커가 그룹에 조인할 수 있는 최대 허용 시간. 개념적으로는 모든 태스크에서 펜딩되고 있는 데이터를 플러시하고 오프셋을 커밋하는데 필요한 시간 제한이다. 타임 아웃을 초과하면, 이 워커는 그룹에서 제거돼 오프셋 커밋에 실패하게 된다.

  |         Type: | int              |
  | ------------: | ---------------- |
  |      Default: | 60000 (1 minute) |
  | Valid Values: |                  |
  |   Importance: | high             |

- #### session.timeout.ms

  워커의 실패를 감지할 때 사용할 타임아웃. 워커는 주기적으로 브로커에 하트 비트를 보내 살아 있음을 알린다. 이 세션 타임아웃이 만료되기 전까지 브로커가 하트 비트를 받지 못하면, 브로커는 그룹에서 이 워커를 제외시키고 리밸런스를 시작한다. 단, 이 값은 브로커 설정에 있는 [`group.min.session.timeout.ms`](../broker-configuration#groupminsessiontimeoutms)와 [`group.max.session.timeout.ms`](../broker-configuration#groupmaxsessiontimeoutms)로 정한 허용 범위 내에 있어야 한다.

  |         Type: | int                |
  | ------------: | ------------------ |
  |      Default: | 10000 (10 seconds) |
  | Valid Values: |                    |
  |   Importance: | high               |

- #### ssl.key.password

  keystore 파일의 개인키 또는 [`ssl.keystore.key`](#sslkeystorekey)에 지정한 PEM 키의 패스워드. 클라이언트에선 양방향 인증을 설정했을 때만 필요하다.

  |         Type: | password |
  | ------------: | -------- |
  |      Default: | null     |
  | Valid Values: |          |
  |   Importance: | high     |

- #### ssl.keystore.certificate.chain

  '[ssl.keystore.type](#sslkeystoretype)'에 지정한 포맷을 사용한 인증서 체인. 디폴트 SSL 엔진 팩토리는 X.509 인증서 리스트를 가진 PEM 형식만 지원한다.

  |         Type: | password |
  | ------------: | -------- |
  |      Default: | null     |
  | Valid Values: |          |
  |   Importance: | high     |

- #### ssl.keystore.key

  '[ssl.keystore.type](#sslkeystoretype)'에 지정한 포맷을 사용한 개인키. 디폴트 SSL 엔진 팩토리는 PKCS#8 키를 가진 PEM 형식만 지원한다. 키가 암호화됐다면 '[ssl.key.password](#sslkeypassword)'를 통해 키 비밀번호를 지정해야 한다.

  |         Type: | password |
  | ------------: | -------- |
  |      Default: | null     |
  | Valid Values: |          |
  |   Importance: | high     |

- #### ssl.keystore.location

  keystore 파일의 위치. 클라이언트에선 선택 사항이다. 클라이언트에선 양방향 인증에 사용할 수 있다.

  |         Type: | string |
  | ------------: | ------ |
  |      Default: | null   |
  | Valid Values: |        |
  |   Importance: | high   |

- #### ssl.keystore.password

  keystore 파일의 저장소 패스워드. 클라이언트에선 선택 사항이며, '[ssl.keystore.location](#sslkeystorelocation)'을 설정했을 때만 필요하다. PEM 형식에는 keystore 패스워드를 지원하지 않는다.

  |         Type: | password |
  | ------------: | -------- |
  |      Default: | null     |
  | Valid Values: |          |
  |   Importance: | high     |

- #### ssl.truststore.certificates

  '[ssl.truststore.type](#ssltruststoretype)'에 지정한 포맷을 사용한 신뢰할 수 있는 인증서. 디폴트 SSL 엔진 팩토리는 X.509 인증서를 가진 PEM 형식만 지원한다.

  |         Type: | password |
  | ------------: | -------- |
  |      Default: | null     |
  | Valid Values: |          |
  |   Importance: | high     |

- #### ssl.truststore.location

  truststore 파일의 위치.

  |         Type: | string |
  | ------------: | ------ |
  |      Default: | null   |
  | Valid Values: |        |
  |   Importance: | high   |

- #### ssl.truststore.password

  truststore 파일의 패스워드. 패스워드를 설정하지 않으면 설정한 truststore 파일을 사용할 순 있지만 무결성 검사는 비활성화된다. PEM 형식에는 truststore 패스워드를 지원하지 않는다.

  |         Type: | password |
  | ------------: | -------- |
  |      Default: | null     |
  | Valid Values: |          |
  |   Importance: | high     |

- #### client.dns.lookup

  클라이언트가 DNS lookup을 사용하는 방법을 제어한다. `use_all_dns_ips`로 설정하면, 연결에 성공할 때까지 반환된 각 IP 주소에 순서대로 연결한다. 연결이 끊어지면 다음 IP를 사용한다. 모든 IP를 한 번씩 사용하고나면 클라이언트는 호스트명으로 IP(s)를 다시 리졸브한다 (단, JVM, OS 모두 DNS name lookup을 캐시해둔다). `resolve_canonical_bootstrap_servers_only`로 설정하면, 각 부트스트랩 주소를 canonical name 리스트로 리졸브한다. 부트스트랩 단계 이후에는 `use_all_dns_ips`와 동일하게 동작한다. `default` (deprecated)로 설하면, lookup에서 IP 주소를 여러 개 반환하더라도, 첫 번째로 반환된 IP 주소에 연결을 시도한다.

  |         Type: | string                                                       |
  | ------------: | ------------------------------------------------------------ |
  |      Default: | use_all_dns_ips                                              |
  | Valid Values: | [default, use_all_dns_ips, resolve_canonical_bootstrap_servers_only] |
  |   Importance: | medium                                                       |

- #### connections.max.idle.ms

  유휴 커넥션은 이 설정에 지정한 시간(밀리세컨드)이 지나면 종료한다.

  |         Type: | long               |
  | ------------: | ------------------ |
  |      Default: | 540000 (9 minutes) |
  | Valid Values: |                    |
  |   Importance: | medium             |

- #### connector.client.config.override.policy

  `ConnectorClientConfigOverridePolicy` 구현체의 클래스명 또는 alias. 커넥터가 재정의할 수있는 클라이언트 설정을 정의한다. 디폴트 구현체는 `None`이다. 프레임워크에서 제공하는 다른 정책은 `All`, `Principal`이 있다.

  |         Type: | string |
  | ------------: | ------ |
  |      Default: | None   |
  | Valid Values: |        |
  |   Importance: | medium |

- #### receive.buffer.bytes

  데이터를 읽을 때 사용하는 TCP 수신 버퍼(SO_RCVBUF)의 크기. 값이 -1이면 OS 기본값을 사용한다.

  |         Type: | int                  |
  | ------------: | -------------------- |
  |      Default: | 32768 (32 kibibytes) |
  | Valid Values: | [0,...]              |
  |   Importance: | medium               |

- #### request.timeout.ms

  이 설정은 클라이언트가 응답을 기다릴 최대 시간을 제어한다. 클라이언트는 타임 아웃될 때까지 응답을 받지 못하면, 필요한 경우 요청을 재전송할 수 있으며, 재시도 횟수를 모두 소진하면 요청은 실패로 끝난다.

  |         Type: | int                |
  | ------------: | ------------------ |
  |      Default: | 40000 (40 seconds) |
  | Valid Values: | [0,...]            |
  |   Importance: | medium             |

- #### sasl.client.callback.handler.class

  AuthenticateCallbackHandler 인터페이스를 구현한 SASL 클라이언트 콜백 핸들러 클래스의 풀 네임(fully qualified name).

  |         Type: | class  |
  | ------------: | ------ |
  |      Default: | null   |
  | Valid Values: |        |
  |   Importance: | medium |

- #### sasl.jaas.config

  JAAS 설정 파일 포맷에 있는, SASL 연결을 위한 JAAS 로그인 컨텍스트 파라미터. JAAS 설정 파일 포맷은 여기에서 설명하고 있다. 이 값에 사용하는 포맷은 ‘loginModuleClass controlFlag (optionName=optionValue)*;‘이다. 브로커에선 앞에 listener와 소문자로된 SASL 메커니즘 이름을 지정해야 한다. 예를 들어, listener.name.sasl_ssl.scram-sha-256.sasl.jaas.config=com.example.ScramLoginModule required;

  |         Type: | password |
  | ------------: | -------- |
  |      Default: | null     |
  | Valid Values: |          |
  |   Importance: | medium   |

- #### sasl.kerberos.service.name

  카프카가 실행되는 커버로스 principal 이름. 카프카의 JAAS 설정으로도 정의할 수 있고, 카프카 설정에서도 정의할 수 있다.

  |         Type: | string |
  | ------------: | ------ |
  |      Default: | null   |
  | Valid Values: |        |
  |   Importance: | medium |

- #### sasl.login.callback.handler.class

  AuthenticateCallbackHandler 인터페이스를 구현한 SASL 로그인 콜백 핸들러 클래스의 풀 네임(fully qualified name). 브로커에선 앞에 listener와 소문자로된 SASL 메커니즘 이름을 지정해야 한다. 예를 들면, listener.name.sasl_ssl.scram-sha-256.sasl.login.callback.handler.class=com.example.CustomScramLoginCallbackHandler

  |         Type: | class  |
  | ------------: | ------ |
  |      Default: | null   |
  | Valid Values: |        |
  |   Importance: | medium |

- #### sasl.login.class

  Login 인터페이스를 구현한 클래스의 풀 네임(fully qualified name). 브로커에선 앞에 listener와 소문자로된 SASL 메커니즘 이름을 지정해야 한다. 예를 들어, listener.name.sasl_ssl.scram-sha-256.sasl.login.class=com.example.CustomScramLogin

  |         Type: | class  |
  | ------------: | ------ |
  |      Default: | null   |
  | Valid Values: |        |
  |   Importance: | medium |

- #### sasl.mechanism

  클라이언트 커넥션에 사용할 SASL 메커니즘. 시큐리티 프로바이더를 사용할 수 있는 메커니즘이라면 다 가능하다. GSSAPI가 디폴트 메커니즘이다.

  |         Type: | string |
  | ------------: | ------ |
  |      Default: | GSSAPI |
  | Valid Values: |        |
  |   Importance: | medium |

- #### security.protocol

  브로커와 통신할 때 사용하는 프로토콜. 유효한 값은 PLAINTEXT, SSL, SASL_PLAINTEXT, SASL_SSL이다.

  |         Type: | string    |
  | ------------: | --------- |
  |      Default: | PLAINTEXT |
  | Valid Values: |           |
  |   Importance: | medium    |

- #### send.buffer.bytes

  데이터를 전송할 때 사용하는 TCP 전송 버퍼(SO_SNDBUF)의 크기. 값이 -1이면 OS 기본값을 사용한다.

  |         Type: | int                    |
  | ------------: | ---------------------- |
  |      Default: | 131072 (128 kibibytes) |
  | Valid Values: | [0,...]                |
  |   Importance: | medium                 |

- #### ssl.enabled.protocols

  SSL 커넥션에 활성화할 프로토콜 리스트. 자바 11 이상에서 실행하면 기본값은 'TLSv1.2,TLSv1.3'이며, 그 외는 'TLSv1.2'다. 자바 11 기본값에선 클라이언트와 서버 둘 다 지원한다면 TLSv1.3을, 그외는 TLSv1.2로 폴백한다 (둘 다 최소 TLSv1.2는 지원한다고 가정). 대부분은 이 기본값으로도 충분하다. [`ssl.protocol`](#sslprotocol) 설정도 참고해라.

  |         Type: | list    |
  | ------------: | ------- |
  |      Default: | TLSv1.2 |
  | Valid Values: |         |
  |   Importance: | medium  |

- #### ssl.keystore.type

  keystore 파일의 파일 포맷. 클라이언트에선 선택 사항이다.

  |         Type: | string |
  | ------------: | ------ |
  |      Default: | JKS    |
  | Valid Values: |        |
  |   Importance: | medium |

- #### ssl.protocol

  SSLContext를 생성할 때 사용할 SSL 프로토콜. 자바 11 이상에서 실행하면 기본값은 'TLSv1.3'이며, 그 외는 'TLSv1.2'다. 대부분은 이 기본값으로도 충분하다. 최신 JVM에서 허용하는 값은 'TLSv1.2'과 'TLSv1.3'이다. 구버전 JVM에선 'TLS', 'TLSv1.1', 'SSL', 'SSLv2', 'SSLv3'을 지원할 수도 있지만, 보안 취약점이 알려져 있어서 사용하지 않는 게 좋다. 이 설정과 '[ssl.enabled.protocols](#sslenabledprotocols)'에 기본값을 사용하면, 서버가 'TLSv1.3'을 지원하지 않는 경우엔 클라이언트는 'TLSv1.2'로 다운그레이드된다. 이 설정을 'TLSv1.2'로 지정하면, [ssl.enabled.protocols](#sslenabledprotocols)에 'TLSv1.3'이 있고 서버는 'TLSv1.3'만 지원하더라도, 클라이언트는 'TLSv1.3'을 사용하지 않는다.

  |         Type: | string  |
  | ------------: | ------- |
  |      Default: | TLSv1.2 |
  | Valid Values: |         |
  |   Importance: | medium  |

- #### ssl.provider

  SSL 커넥션에 사용할 시큐리티 프로바이더 이름. 기본값은 JVM의 디폴트 시큐리티 프로바이더다.

  |         Type: | string |
  | ------------: | ------ |
  |      Default: | null   |
  | Valid Values: |        |
  |   Importance: | medium |

- #### ssl.truststore.type

  truststore 파일의 파일 포맷.

  |         Type: | string |
  | ------------: | ------ |
  |      Default: | JKS    |
  | Valid Values: |        |
  |   Importance: | medium |

- #### worker.sync.timeout.ms

  워커가 다른 워커와 동기화되지 않으며, 설정을 다시 동기화해야 할 땐, 이 시간까지 기다렸다가 포기하고 그룹을 나간다. 다시 참여하기 전엔 백오프 기간 동안 기다린다.

  |         Type: | int              |
  | ------------: | ---------------- |
  |      Default: | 3000 (3 seconds) |
  | Valid Values: |                  |
  |   Importance: | medium           |

- #### worker.unsync.backoff.ms

  워커가 다른 워커와 동기화되지 않으며, [worker.sync.timeout.ms](#workersynctimeoutms) 내에 따라 잡지 못하면, 다시 참여하기 전에 이 시간 동안 커넥트 클러스터를 그대로 놔둔다.

  |         Type: | int                |
  | ------------: | ------------------ |
  |      Default: | 300000 (5 minutes) |
  | Valid Values: |                    |
  |   Importance: | medium             |

- #### access.control.allow.methods

  Access-Control-Allow-Methods 헤더를 통해 cross origin 요청에서 지원할 메소드를 설정한다. Access-Control-Allow-Methods 헤더 기본값에선 GET, POST, HEAD에 대해 cross origin 요청을 허용한다.

  |         Type: | string |
  | ------------: | ------ |
  |      Default: | ""     |
  | Valid Values: |        |
  |   Importance: | low    |

- #### access.control.allow.origin

  REST API 요청에서 Access-Control-Allow-Origin 헤더에 설정할 값. cross origin 액세스를 활성화하려면, API 접근을 허가할 어플리케이션의 도메인으로 설정해라. 모든 도메인의 액세스를 허용하려면 '*'를 설정해라. 기본값은 REST API 도메인에서의 접근만 허용한다.

  |         Type: | string |
  | ------------: | ------ |
  |      Default: | ""     |
  | Valid Values: |        |
  |   Importance: | low    |

- #### admin.listeners

  Admin REST API가 수신(listen)할 URI 리스트. 콤마로 구분한다. 지원하는 프로토콜은 HTTP와 HTTPS다. 빈 문자열이나 공백으로만 구성된 문자열은 이 기능을 비활성화한다. 기본 동작은 일반 리스너('[listeners](#listeners)' 프로퍼티로 지정한)를 사용하는 거다.

  |         Type: | list                                                         |
  | ------------: | ------------------------------------------------------------ |
  |      Default: | null                                                         |
  | Valid Values: | org.apache.kafka.connect.runtime.WorkerConfig$AdminListenersValidator@7b1d7fff |
  |   Importance: | low                                                          |

- #### client.id

  요청을 보낼 때 서버에 전달할 문자열 id. id를 사용하는 목적은 서버 측 요청 로그에 논리적인 어플리케이션명을 추가해서, IP/포트를 외로도 요청 주체를 추적할 수 있도록 하기 위함이다.

  |         Type: | string |
  | ------------: | ------ |
  |      Default: | ""     |
  | Valid Values: |        |
  |   Importance: | low    |

- #### config.providers

  지정한 순서대로 로드해서 사용하는 `ConfigProvider` 클래스명 리스트. 쉼표로 구분한다. 인터페이스 `ConfigProvider`를 구현하면 커넥터 설정의 변수 레퍼런스를 외부에서 보관하는 시크릿 등으로 대체할 수 있다.

  |         Type: | list |
  | ------------: | ---- |
  |      Default: | ""   |
  | Valid Values: |      |
  |   Importance: | low  |

- #### config.storage.replication.factor

  설정을 저장하는 토픽을 생성할 때 사용할 replication factor

  |         Type: | short                                                        |
  | ------------: | ------------------------------------------------------------ |
  |      Default: | 3                                                            |
  | Valid Values: | Positive number not larger than the number of brokers in the Kafka cluster, or -1 to use the broker's default |
  |   Importance: | low                                                          |

- #### connect.protocol

  카프카 커넥트 프로토콜의 호환 모드

  |         Type: | string                         |
  | ------------: | ------------------------------ |
  |      Default: | sessioned                      |
  | Valid Values: | [eager, compatible, sessioned] |
  |   Importance: | low                            |

- #### header.converter

  카프카 커넥트 포맷과 카프카에 기록한 직렬화된 포맷 간을 변환할 때 사용할 HeaderConverter 클래스. 카프카에서 쓰거나 읽은 메세지의 헤더 값 포맷은 이 클래스가 제어하며, 컨버터는 커넥터와는 독립적이기 때문에, 사용하는 커넥터와는 무관하게 어떤 직렬화 포맷으로도 작업할 수 있다. 많이 사용하는 포맷으로는 JSON, Avro가 있다. 기본적으로는 헤더 값을 문자열로 직렬화하고, 스키마를 추론해서 역직렬화하는 SimpleHeaderConverter를 사용한다.

  |         Type: | class                                                  |
  | ------------: | ------------------------------------------------------ |
  |      Default: | org.apache.kafka.connect.storage.SimpleHeaderConverter |
  | Valid Values: |                                                        |
  |   Importance: | low                                                    |

- #### inter.worker.key.generation.algorithm

  내부 요청 키를 생성할 때 사용할 알고리즘

  |         Type: | string                                                 |
  | ------------: | ------------------------------------------------------ |
  |      Default: | HmacSHA256                                             |
  | Valid Values: | Any KeyGenerator algorithm supported by the worker JVM |
  |   Importance: | low                                                    |

- #### inter.worker.key.size

  내부 요청 서명에 사용할 키의 사이즈 (bit). null일 땐 키 생성 알고리즘의 디폴트 키 사이즈를 사용한다.

  |         Type: | int  |
  | ------------: | ---- |
  |      Default: | null |
  | Valid Values: |      |
  |   Importance: | low  |

- #### inter.worker.key.ttl.ms

  내부 요청 유효성 검사를 위해 만든 세션 키의 TTL (밀리세컨드)

  |         Type: | int                |
  | ------------: | ------------------ |
  |      Default: | 3600000 (1 hour)   |
  | Valid Values: | [0,...,2147483647] |
  |   Importance: | low                |

- #### inter.worker.signature.algorithm

  내부 요청을 서명할 때 사용할 알고리즘

  |         Type: | string                                        |
  | ------------: | --------------------------------------------- |
  |      Default: | HmacSHA256                                    |
  | Valid Values: | Any MAC algorithm supported by the worker JVM |
  |   Importance: | low                                           |

- #### inter.worker.verification.algorithms

  내부 요청 검증에 허용하는 알고리즘 리스트

  |         Type: | list                                                         |
  | ------------: | ------------------------------------------------------------ |
  |      Default: | HmacSHA256                                                   |
  | Valid Values: | A list of one or more MAC algorithms, each supported by the worker JVM |
  |   Importance: | low                                                          |

- #### internal.key.converter

  카프카 커넥트 포맷과 카프카에 기록한 직렬화된 포맷 간을 변환할 때 사용할 컨버터 클래스. 카프카에서 쓰거나 읽은 메세지 키 포맷은 이 클래스가 제어하며, 컨버터는 커넥터와는 독립적이기 때문에, 사용하는 커넥터와는 무관하게 어떤 직렬화 포맷으로도 작업할 수 있다. 많이 사용하는 포맷으로는 JSON, Avro가 있다. 설정, 오프셋같이 프레임워크 내부에서 사용하는 기록용 데이터 포맷을 제어하므로, 보통은 잘 동작하는 컨버터라면 어떤 구현체를 사용해도 상관 없다. Deprecated; 향후 버전에선 제거될 예정이다.

  |         Type: | class                                       |
  | ------------: | ------------------------------------------- |
  |      Default: | org.apache.kafka.connect.json.JsonConverter |
  | Valid Values: |                                             |
  |   Importance: | low                                         |

- #### internal.value.converter

  카프카 커넥트 포맷과 카프카에 기록한 직렬화된 포맷 간을 변환할 때 사용할 컨버터 클래스. 카프카에서 쓰거나 읽은 메세지 값 포맷은 이 클래스가 제어하며, 컨버터는 커넥터와는 독립적이기 때문에, 사용하는 커넥터와는 무관하게 어떤 직렬화 포맷으로도 작업할 수 있다. 많이 사용하는 포맷으로는 JSON, Avro가 있다. 설정, 오프셋같이 프레임워크 내부에서 사용하는 기록용 데이터 포맷을 제어하므로, 보통은 잘 동작하는 컨버터라면 어떤 구현체를 사용해도 상관 없다. Deprecated; 향후 버전에선 제거될 예정이다.

  |         Type: | class                                       |
  | ------------: | ------------------------------------------- |
  |      Default: | org.apache.kafka.connect.json.JsonConverter |
  | Valid Values: |                                             |
  |   Importance: | low                                         |

- #### listeners

  REST API가 수신(listen)할 URI 리스트로, 콤마로 구분한다.<br>
  모든 인터페이스에 바인드하려면 호스트명을 0.0.0.0으로 지정해라.<br>
  디폴트 인터페이스와 바인드하려면 호스트명을 비워둬라.<br>
  허용하는 리스너 리스트 예시: `HTTP://myhost:8083,HTTPS://myhost:8084`

  |         Type: | list |
  | ------------: | ---- |
  |      Default: | null |
  | Valid Values: |      |
  |   Importance: | low  |

- #### metadata.max.age.ms

  새로운 브로커나 파티션을 사전에 발견할 수 있도록, 파티션 리더십이 변경되지 않아도 메타데이터를 강제로 리프레시할 간격 (밀리세컨드).

  |         Type: | long               |
  | ------------: | ------------------ |
  |      Default: | 300000 (5 minutes) |
  | Valid Values: | [0,...]            |
  |   Importance: | low                |

- #### metric.reporters

  메트릭 리포터로 사용할 클래스 리스트. `org.apache.kafka.common.metrics.MetricsReporter` 인터페이스를 구현하면 새 메트릭을 생성을 통지 받을 클래스를 연결할 수 있다. JMX 통계를 등록하는 JmxReporter는 항상 추가된다.

  |         Type: | list |
  | ------------: | ---- |
  |      Default: | ""   |
  | Valid Values: |      |
  |   Importance: | low  |

- #### metrics.num.samples

  메트릭 계산을 위해 유지할 샘플 수.

  |         Type: | int     |
  | ------------: | ------- |
  |      Default: | 2       |
  | Valid Values: | [1,...] |
  |   Importance: | low     |

- #### metrics.recording.level

  메트릭을 기록할 제일 높은 레벨.

  |         Type: | string        |
  | ------------: | ------------- |
  |      Default: | INFO          |
  | Valid Values: | [INFO, DEBUG] |
  |   Importance: | low           |

- #### metrics.sample.window.ms

  메트릭 샘플을 계산할 시간 윈도우.

  |         Type: | long               |
  | ------------: | ------------------ |
  |      Default: | 30000 (30 seconds) |
  | Valid Values: | [0,...]            |
  |   Importance: | low                |

- #### offset.flush.interval.ms

  태스크에서 오프셋 커밋을 시도하는 간격.

  |         Type: | long             |
  | ------------: | ---------------- |
  |      Default: | 60000 (1 minute) |
  | Valid Values: |                  |
  |   Importance: | low              |

- #### offset.flush.timeout.ms

  레코드를 플러시하고 파티션 오프셋 데이터를 오프셋 스토리지에 커밋할 때까지 기다리는 최대 시간 (밀리세컨드). 이 시간이 지나면 프로세스를 취소하고 향후에 커밋할 오프셋 데이터를 복원한다. 

  |         Type: | long             |
  | ------------: | ---------------- |
  |      Default: | 5000 (5 seconds) |
  | Valid Values: |                  |
  |   Importance: | low              |

- #### offset.storage.partitions

  오프셋을 저장하는 토픽을 만들 때 사용할 파티션 수

  |         Type: | int                                                |
  | ------------: | -------------------------------------------------- |
  |      Default: | 25                                                 |
  | Valid Values: | Positive number, or -1 to use the broker's default |
  |   Importance: | low                                                |

- #### offset.storage.replication.factor

  오프셋을 저장하는 토픽을 생성할 때 사용할 replication factor

  |         Type: | short                                                        |
  | ------------: | ------------------------------------------------------------ |
  |      Default: | 3                                                            |
  | Valid Values: | Positive number not larger than the number of brokers in the Kafka cluster, or -1 to use the broker's default |
  |   Importance: | low                                                          |

- #### plugin.path

  플러그인(커넥터, 컨버터, transformation)이 들어있는 path 리스트. 콤마(,)로 구분한다. 이 리스트는 다음 조합을 가지고 있는 최상위 디렉토리로 구성해야 한다:<br>
  a) 바로 아래에, 플러그인과 의존성을 포함하고 있는 jar가 있는 디렉토리<br>
  b) 플러그인과 의존성을 묶은 uber-jars<br>
  c) 바로 아래에, 플러그인 클래스의 패키지 디렉토리 구조와 의존성이 있는 디렉토리<br>
  참고: 의존성이나 플러그인을 찾을 땐 심볼릭 링크를 따른다.<br>
  예시: plugin.path=/usr/local/share/java,/usr/local/share/kafka/plugins,/opt/connectors<br>
  이 프로퍼티에 설정 provider 변수를 사용하면 안 된다. 설정 provider를 초기화하고 변수를 치환하기 전에, 워커의 스캐너가 이 raw path를 먼저 사용한다.

  |         Type: | list |
  | ------------: | ---- |
  |      Default: | null |
  | Valid Values: |      |
  |   Importance: | low  |

- #### reconnect.backoff.max.ms

  브로커에 연결을 반복해서 실패했을 때, 다시 연결해보기까지 대기하는 최대 시간 (밀리세컨드). 연이어서 커넥션 연결에 실패하면 매번 실패할 때마다 호스트 당 백오프 값이 늘어나, 순식간에 이 최대값까지 커질 수 있다. 커넥션 폭풍을 방지하기 위해 백오프 증가값을 계산한 후에 20% 랜덤 지터를 추가한다.

  |         Type: | long            |
  | ------------: | --------------- |
  |      Default: | 1000 (1 second) |
  | Valid Values: | [0,...]         |
  |   Importance: | low             |

- #### reconnect.backoff.ms

  주어진 호스트에 연결을 다시 시도하기 전 대기하는 기본 시간. 리소스를 차지한채 반복문으로 계속해서 같은 호스트에 연결하는 것을 방지한다. 이 백오프는 클라이언트가 브로커에 연결을 시도하는 모든 곳에 적용된다.

  |         Type: | long    |
  | ------------: | ------- |
  |      Default: | 50      |
  | Valid Values: | [0,...] |
  |   Importance: | low     |

- #### response.http.headers.config

  REST API의 HTTP 응답 헤더 룰

  |         Type: | string                                                       |
  | ------------: | ------------------------------------------------------------ |
  |      Default: | ""                                                           |
  | Valid Values: | Comma-separated header rules, where each header rule is of the form '[action] [header name]:[header value]' and optionally surrounded by double quotes if any part of a header rule contains a comma |
  |   Importance: | low                                                          |

- #### rest.advertised.host.name

  설정한다면, 이 값이 다른 워커가 연결하도록 제공하는 호스트명이 된다.

  |         Type: | string |
  | ------------: | ------ |
  |      Default: | null   |
  | Valid Values: |        |
  |   Importance: | low    |

- #### rest.advertised.listener

  다른 워커에게 제공할 advertised 리스너(HTTP 또는 HTTPS)를 설정한다.

  |         Type: | string |
  | ------------: | ------ |
  |      Default: | null   |
  | Valid Values: |        |
  |   Importance: | low    |

- #### rest.advertised.port

  설정한다면, 이 값이 다른 워커가 연결하도록 제공하는 포트가 된다.

  |         Type: | int  |
  | ------------: | ---- |
  |      Default: | null |
  | Valid Values: |      |
  |   Importance: | low  |

- #### rest.extension.classes

  `ConnectRestExtension` 클래스들의 이름. 콤마로 구분하며, 지정한 순서대로 로드하고 호출한다. `ConnectRestExtension` 인터페이스 구현체는 필터같은 커넥트의 REST API 사용자 정의 리소스에 추가할 수 있다. 일반적으로 로깅, 보안 등의 커스텀 기능을 추가할 때 사용한다.

  |         Type: | list |
  | ------------: | ---- |
  |      Default: | ""   |
  | Valid Values: |      |
  |   Importance: | low  |

- #### rest.host.name

  REST API의 호스트명. 값을 설정하면 이 인터페이스에만 바인딩한다.

  |         Type: | string |
  | ------------: | ------ |
  |      Default: | null   |
  | Valid Values: |        |
  |   Importance: | low    |

- #### rest.port

  REST API에서 수신(listen)할 포트.

  |         Type: | int  |
  | ------------: | ---- |
  |      Default: | 8083 |
  | Valid Values: |      |
  |   Importance: | low  |

- #### retry.backoff.ms

  주어진 토픽 파티션에 실패한 요청을 재시도하기 전 대기하는 시간. 일부 실패 시나리오에서 리소스를 차지한채 반복문으로 계속해서 요청을 보내는 것을 방지한다.

  |         Type: | long    |
  | ------------: | ------- |
  |      Default: | 100     |
  | Valid Values: | [0,...] |
  |   Importance: | low     |

- #### sasl.kerberos.kinit.cmd

  커버로스 kinit 커맨드 경로.

  |         Type: | string         |
  | ------------: | -------------- |
  |      Default: | /usr/bin/kinit |
  | Valid Values: |                |
  |   Importance: | low            |

- #### sasl.kerberos.min.time.before.relogin

  리프레시 시도 간격 (로그인 스레드 sleep 시간).

  |         Type: | long  |
  | ------------: | ----- |
  |      Default: | 60000 |
  | Valid Values: |       |
  |   Importance: | low   |

- #### sasl.kerberos.ticket.renew.jitter

  갱신 시간에 추가되는 랜덤 지터 백분율.

  |         Type: | double |
  | ------------: | ------ |
  |      Default: | 0.05   |
  | Valid Values: |        |
  |   Importance: | low    |

- #### sasl.kerberos.ticket.renew.window.factor

  로그인 스레드는 마지막 갱신 시각부터 티켓 만료 시간까지 남은 시간이, 지정한 지정한 윈도우 팩터만큼 지날 때까지 일시정지하며(sleep), 윈도우 팩터에 도달하면 티켓 갱신을 시도한다.

  |         Type: | double |
  | ------------: | ------ |
  |      Default: | 0.8    |
  | Valid Values: |        |
  |   Importance: | low    |

- #### sasl.login.refresh.buffer.seconds

  credential을 리프레시할 때, credential을 만료하기 전 유지할 버퍼 시간 (초 단위). 리프레시하려던 시간이 버퍼 시간보다 늦다면, 리프레시 시간을 앞당겨 가능한 한 버퍼 시간을 유지한다. 유효한 값은 0에서 3600(1시간) 사이다. 값을 지정하지 않으면 기본값 300(5분)을 사용한다. 이 값과 [sasl.login.refresh.min.period.seconds](#saslloginrefreshminperiodseconds)의 합이 credential의 남은 수명을 넘어가면 둘다 무시된다. 현재는 OAUTHBEARER에만 적용된다.

  |         Type: | short        |
  | ------------: | ------------ |
  |      Default: | 300          |
  | Valid Values: | [0,...,3600] |
  |   Importance: | low          |

- #### sasl.login.refresh.min.period.seconds

  credential을 리프레시하기 전에 로그인 리프레시 스레드가 대기할 최소 시간 (초 단위). 유효한 값은 0에서 900(15분) 사이다. 값을 지정하지 않으면 기본값 60(1분)을 사용한다. 이 값과 [sasl.login.refresh.buffer.seconds](#saslloginrefreshbufferseconds)의 합이 credential의 남은 수명을 넘어가면 둘다 무시된다. 현재는 OAUTHBEARER에만 적용된다.

  |         Type: | short       |
  | ------------: | ----------- |
  |      Default: | 60          |
  | Valid Values: | [0,...,900] |
  |   Importance: | low         |

- #### sasl.login.refresh.window.factor

  로그인 리프레시 스레드는 credential의 수명이 지정한 윈도우 팩터만큼 지날 때까지 일시정지하며(sleep), 윈도우 팩터에 도달하면 credential 리프레시를 시도한다. 유효한 값은 0.5(50%)에서 1.0(100%) 사이다. 값을 지정하지 않으면 기본값 0.8(80%)을 사용한다. 현재는 OAUTHBEARER에만 적용된다.

  |         Type: | double        |
  | ------------: | ------------- |
  |      Default: | 0.8           |
  | Valid Values: | [0.5,...,1.0] |
  |   Importance: | low           |

- #### sasl.login.refresh.window.jitter

  로그인 리프레시 스레드의 sleep 시간에 추가되는, credential의 수명 계산에 사용할 랜덤 지터의 최대 크기. 유효한 값은 0부터 0.25(25%) 이하다. 값을 지정하지 않으면 기본값 0.05(5%)를 사용한다. 현재는 OAUTHBEARER에만 적용된다.

  |         Type: | double         |
  | ------------: | -------------- |
  |      Default: | 0.05           |
  | Valid Values: | [0.0,...,0.25] |
  |   Importance: | low            |

- #### scheduled.rebalance.max.delay.ms

  워커가 하나 이상 제외되면 리밸런싱을 통해 커넥터, 태스크를 그룹에 재할당하기 전에, 제외된 워커가 돌아오기를 기다릴 최대 지연 시간. 이 기간 동안은 제외된 워커의 커넥터와 태스크는 할당되지 않은 상태로 남아 있는다

  |         Type: | int                |
  | ------------: | ------------------ |
  |      Default: | 300000 (5 minutes) |
  | Valid Values: | [0,...,2147483647] |
  |   Importance: | low                |

- #### socket.connection.setup.timeout.max.ms

  클라이언트가 소켓 커넥션이 구축될 때까지 기다릴 최대 시간. 연이어서 커넥션 연결에 실패하면 매번 실패할 때마다 커넥션 세팅 타임아웃이 늘어나, 순식간에 이 최대값까지 커질 수 있다. 커넥션 폭풍을 방지하기 위해 타임아웃에 랜덤화 계수 0.2를 적용해, 계산된 값보다 20% 아래 ~ 20% 위까지의 랜덤 범위를 만든다.

  |         Type: | long                 |
  | ------------: | -------------------- |
  |      Default: | 127000 (127 seconds) |
  | Valid Values: | [0,...]              |
  |   Importance: | low                  |

- #### socket.connection.setup.timeout.ms

  클라이언트가 소켓 커넥션이 구축될 때까지 기다리는 시간. 타임아웃되기 전에 커넥션이 구축되지 않으면 클라이언트는 소켓 채널을 닫는다.

  |         Type: | long               |
  | ------------: | ------------------ |
  |      Default: | 10000 (10 seconds) |
  | Valid Values: | [0,...]            |
  |   Importance: | low                |

- #### ssl.cipher.suites

  암호화 스위트 리스트. 암호와 스위트는 TLS나 SSL 네트워크 프로토콜로 네트워크 커넥션 보안 설정을 협상하는 데 사용되는 인증, 암호화, MAC, 키 교환 알고리즘을 하나로 조합해놓은 집합이다. 기본적으로는 가능한 모든 암호화 스위트를 지원한다.

  |         Type: | list |
  | ------------: | ---- |
  |      Default: | null |
  | Valid Values: |      |
  |   Importance: | low  |

- #### ssl.client.auth

  카프카 브로커가 클라이언트 인증을 요청하도록 설정한다. 다음 설정이 일반적이다:

  - `ssl.client.auth=required` required로 설정하면 클라이언트 인증을 요구한다.
  - `ssl.client.auth=requested` 클라이언트 인증은 옵션이란 뜻이다. required와는 달리 클라이언트가 인증 정보를 제공할지를 자체적으로 선택할 수 있다.
  - `ssl.client.auth=none` 클라이언트 인증이 필요 없다는 뜻이다.

  |         Type: | string |
  | ------------: | ------ |
  |      Default: | none   |
  | Valid Values: |        |
  |   Importance: | low    |

- #### ssl.endpoint.identification.algorithm

  서버 인증서를 사용해 서버 호스트명을 검증하는 엔드포인트 식별 알고리즘.

  |         Type: | string |
  | ------------: | ------ |
  |      Default: | https  |
  | Valid Values: |        |
  |   Importance: | low    |

- #### ssl.engine.factory.class

  SSLEngine 객체를 제공하는 org.apache.kafka.common.security.auth.SslEngineFactory 타입 클래스. 기본값은 org.apache.kafka.common.security.ssl.DefaultSslEngineFactory다.

  |         Type: | class |
  | ------------: | ----- |
  |      Default: | null  |
  | Valid Values: |       |
  |   Importance: | low   |

- #### ssl.keymanager.algorithm

  SSL 커넥션에서 키 매니저 팩토리가 사용할 알고리즘. 기본값은 자바 가상 머신에 설정된 키 매니저 팩토리 알고리즘이다.

  |         Type: | string  |
  | ------------: | ------- |
  |      Default: | SunX509 |
  | Valid Values: |         |
  |   Importance: | low     |

- #### ssl.secure.random.implementation

  SSL 암호화 연산에 사용할 SecureRandom PRNG 구현체.

  |         Type: | string |
  | ------------: | ------ |
  |      Default: | null   |
  | Valid Values: |        |
  |   Importance: | low    |

- #### ssl.trustmanager.algorithm

  SSL 커넥션에서 trust 매니저 팩토리가 사용할 알고리즘. 기본값은 자바 가상 머신에 설정된 trust 매니저 팩토리 알고리즘이다.

  |         Type: | string |
  | ------------: | ------ |
  |      Default: | PKIX   |
  | Valid Values: |        |
  |   Importance: | low    |

- #### status.storage.partitions

  상태를 저장하는 토픽을 만들 때 사용할 파티션 수

  |         Type: | int                                                |
  | ------------: | -------------------------------------------------- |
  |      Default: | 5                                                  |
  | Valid Values: | Positive number, or -1 to use the broker's default |
  |   Importance: | low                                                |

- #### status.storage.replication.factor

  상태를 저장하는 토픽을 생성할 때 사용할 replication factor

  |         Type: | short                                                        |
  | ------------: | ------------------------------------------------------------ |
  |      Default: | 3                                                            |
  | Valid Values: | Positive number not larger than the number of brokers in the Kafka cluster, or -1 to use the broker's default |
  |   Importance: | low                                                          |

- #### task.shutdown.graceful.timeout.ms

  태스크를 정상적으로 종료하기를 기다릴 시간. 태스크 당 시간이 아니라 총 시간이다. 모든 태스크의 종료를 순차적으로 트리거하고 대기한다.

  |         Type: | long             |
  | ------------: | ---------------- |
  |      Default: | 5000 (5 seconds) |
  | Valid Values: |                  |
  |   Importance: | low              |

- #### topic.creation.enable

  소스 커넥터에서 `topic.creation.` 프로퍼티를 설정했을 때, 소스 커넥터에서 사용하는 토픽의 자동 생성을 허용할지 여부. 각 태스크는 어드민 클라이언트를 사용해 토픽을 생성하며, 자동으로 토픽을 만들 때 카프카 브로커에 의존하지 않는다.

  |         Type: | boolean |
  | ------------: | ------- |
  |      Default: | true    |
  | Valid Values: |         |
  |   Importance: | low     |

- #### topic.tracking.allow.reset

  true로 설정하면, 커넥터별 활성 토픽 셋을 재설정하는 요청을 허용한다.

  |         Type: | boolean |
  | ------------: | ------- |
  |      Default: | true    |
  | Valid Values: |         |
  |   Importance: | low     |

- #### topic.tracking.enable

  런타임에 커넥터별 활성 토픽 셋 추적을 활성화한다.

  |         Type: | boolean |
  | ------------: | ------- |
  |      Default: | true    |
  | Valid Values: |         |
  |   Importance: | low     |

### 3.5.1 Source Connector Configs

다음은 소스 커넥터의 설정이다.

- #### name

  전역에서 고유한, 이 커넥터에 사용할 이름.

  |         Type: | string                                          |
  | ------------: | ----------------------------------------------- |
  |      Default: |                                                 |
  | Valid Values: | non-empty string without ISO control characters |
  |   Importance: | high                                            |

- #### connector.class

  이 커넥터의 클래스명 또는 alias. org.apache.kafka.connect.connector.Connector의 하위 클래스만 가능하다. 커넥터가 org.apache.kafka.connect.file.FileStreamSinkConnector라면, 풀 네임을 그대로 지정해도 되지만, "FileStreamSink"나 "FileStreamSinkConnector"를 사용해 설정을 좀 더 짧게 만들 수도 있다.

  |         Type: | string |
  | ------------: | ------ |
  |      Default: |        |
  | Valid Values: |        |
  |   Importance: | high   |

- #### tasks.max

  이 커넥터에서 사용할 최대 태스크 수.

  |         Type: | int     |
  | ------------: | ------- |
  |      Default: | 1       |
  | Valid Values: | [1,...] |
  |   Importance: | high    |

- #### key.converter

  카프카 커넥트 포맷과 카프카에 기록한 직렬화된 포맷 간을 변환할 때 사용할 컨버터 클래스. 카프카에서 쓰거나 읽은 메세지 키 포맷은 이 클래스가 제어하며, 컨버터는 커넥터와는 독립적이기 때문에, 사용하는 커넥터와는 무관하게 어떤 직렬화 포맷으로도 작업할 수 있다. 많이 사용하는 포맷으로는 JSON, Avro가 있다.

  |         Type: | class |
  | ------------: | ----- |
  |      Default: | null  |
  | Valid Values: |       |
  |   Importance: | low   |

- #### value.converter

  카프카 커넥트 포맷과 카프카에 기록한 직렬화된 포맷 간을 변환할 때 사용할 컨버터 클래스. 카프카에서 쓰거나 읽은 메세지 값 포맷은 이 클래스가 제어하며, 컨버터는 커넥터와는 독립적이기 때문에, 사용하는 커넥터와는 무관하게 어떤 직렬화 포맷으로도 작업할 수 있다. 많이 사용하는 포맷으로는 JSON, Avro가 있다.

  |         Type: | class |
  | ------------: | ----- |
  |      Default: | null  |
  | Valid Values: |       |
  |   Importance: | low   |

- #### header.converter

  카프카 커넥트 포맷과 카프카에 기록한 직렬화된 포맷 간을 변환할 때 사용할 HeaderConverter 클래스. 카프카에서 쓰거나 읽은 메세지의 헤더 값 포맷은 이 클래스가 제어하며, 컨버터는 커넥터와는 독립적이기 때문에, 사용하는 커넥터와는 무관하게 어떤 직렬화 포맷으로도 작업할 수 있다. 많이 사용하는 포맷으로는 JSON, Avro가 있다. 기본적으로는 헤더 값을 문자열로 직렬화하고, 스키마를 추론해서 역직렬화하는 SimpleHeaderConverter를 사용한다.

  |         Type: | class |
  | ------------: | ----- |
  |      Default: | null  |
  | Valid Values: |       |
  |   Importance: | low   |

- #### config.action.reload

  외부 설정 provider의 변경으로 커넥터의 설정 프로퍼티가 변경되었을 때 커넥트가 이 커넥터에 수행해야 하는 작업. 'none'은 커넥트가 아무 작업도 수행하지 않음을 의미한다. 'restart'는 커넥트가 업데이트된 설정 프로퍼티로 커넥터를 재시작/재로드해야 함을 의미한다. 외부 설정 provider가 설정 값이 향후에 만료된다고 표기한 경우엔 실제 재시작이 나중으로 스케줄링될 수 있다.

  |         Type: | string          |
  | ------------: | --------------- |
  |      Default: | restart         |
  | Valid Values: | [none, restart] |
  |   Importance: | low             |

- #### transforms

  레코드에 적용할 transformation들의 alias.

  |         Type: | list                                           |
  | ------------: | ---------------------------------------------- |
  |      Default: | ""                                             |
  | Valid Values: | non-null string, unique transformation aliases |
  |   Importance: | low                                            |

- #### predicates

  transformation에서 사용할 predicate들의 alias.

  |         Type: | list                                      |
  | ------------: | ----------------------------------------- |
  |      Default: | ""                                        |
  | Valid Values: | non-null string, unique predicate aliases |
  |   Importance: | low                                       |

- #### errors.retry.timeout

  실패한 작업을 다시 시도해볼 최대 기간 (밀리세컨드). 기본값은 0이며, 재시도하지 않음을 의미한다. 무한으로 재시도하려면 -1을 사용해라.

  |         Type: | long   |
  | ------------: | ------ |
  |      Default: | 0      |
  | Valid Values: |        |
  |   Importance: | medium |

- #### errors.retry.delay.max.ms

  이어서 재시도하기 전에 기다릴 최대 기간 (밀리세컨드). 이 제한 시간에 도달하면, 지연 시간에 지터를 추가해서 thundering herd issue를 방지한다.

  |         Type: | long             |
  | ------------: | ---------------- |
  |      Default: | 60000 (1 minute) |
  | Valid Values: |                  |
  |   Importance: | medium           |

- #### errors.tolerance

  커넥터 작업 중 발생하는 오류를 허용하는 동작 방식. 기본 값은 'none'이며, 어떤 에러라도 발생하는 즉시 커넥터 작업이 실패한다는 뜻이다. 'all'은 문제가 있는 레코드를 건너뛰도록 동작을 변경한다.

  |         Type: | string      |
  | ------------: | ----------- |
  |      Default: | none        |
  | Valid Values: | [none, all] |
  |   Importance: | medium      |

- #### errors.log.enable

  true일 땐, 모든 오류와 실패한 작업의 세부 정보, 문제가 있는 레코드를 커넥트 어플리케이션 로그에 기록한다. 이 설정은 'false'가 디폴트기 때문에, 허용되지 않는 오류만 보고한다.

  |         Type: | boolean |
  | ------------: | ------- |
  |      Default: | false   |
  | Valid Values: |         |
  |   Importance: | medium  |

- #### errors.log.include.messages

  실패를 초래한 커넥트 레코드를 로그에 포함시킬지 여부. 이 설정은 'false'가 디폴트이며, 이때는 로그 파일에 레코드 키, 값, 헤더는 기록하지 않지만, 토픽, 파티션 번호같은 일부 정보는 로깅한다.

  |         Type: | boolean |
  | ------------: | ------- |
  |      Default: | false   |
  | Valid Values: |         |
  |   Importance: | medium  |

- #### topic.creation.groups

  소스 커넥터에서 생성할 토픽의 설정 그룹

  |         Type: | list                                          |
  | ------------: | --------------------------------------------- |
  |      Default: | ""                                            |
  | Valid Values: | non-null string, unique topic creation groups |
  |   Importance: | low                                           |

### 3.5.2 Sink Connector Configs

다음은 싱크 커넥터의 설정이다.

- #### name

  전역에서 고유한, 이 커넥터에 사용할 이름.

  |         Type: | string                                          |
  | ------------: | ----------------------------------------------- |
  |      Default: |                                                 |
  | Valid Values: | non-empty string without ISO control characters |
  |   Importance: | high                                            |

- #### connector.class

  이 커넥터의 클래스명 또는 alias. org.apache.kafka.connect.connector.Connector의 하위 클래스만 가능하다. 커넥터가 org.apache.kafka.connect.file.FileStreamSinkConnector라면, 풀 네임을 그대로 지정해도 되지만, "FileStreamSink"나 "FileStreamSinkConnector"를 사용해 설정을 좀 더 짧게 만들 수도 있다.

  |         Type: | string |
  | ------------: | ------ |
  |      Default: |        |
  | Valid Values: |        |
  |   Importance: | high   |

- #### tasks.max

  이 커넥터에서 사용할 최대 태스크 수.

  |         Type: | int     |
  | ------------: | ------- |
  |      Default: | 1       |
  | Valid Values: | [1,...] |
  |   Importance: | high    |

- #### topics

  컨슘할 토픽 리스트. 콤마로 구분한다.

  |         Type: | list |
  | ------------: | ---- |
  |      Default: | ""   |
  | Valid Values: |      |
  |   Importance: | high |

- #### topics.regex

  컨슘할 토픽을 나타내는 정규식. 정규식은 내부에서 `java.util.regex.Pattern`으로 컴파일된다. topics, topics.regex 중 하나만 지정해야 한다.

  |         Type: | string      |
  | ------------: | ----------- |
  |      Default: | ""          |
  | Valid Values: | valid regex |
  |   Importance: | high        |

- #### key.converter

  카프카 커넥트 포맷과 카프카에 기록한 직렬화된 포맷 간을 변환할 때 사용할 컨버터 클래스. 카프카에서 쓰거나 읽은 메세지 키 포맷은 이 클래스가 제어하며, 컨버터는 커넥터와는 독립적이기 때문에, 사용하는 커넥터와는 무관하게 어떤 직렬화 포맷으로도 작업할 수 있다. 많이 사용하는 포맷으로는 JSON, Avro가 있다.

  |         Type: | class |
  | ------------: | ----- |
  |      Default: | null  |
  | Valid Values: |       |
  |   Importance: | low   |

- #### value.converter

  카프카 커넥트 포맷과 카프카에 기록한 직렬화된 포맷 간을 변환할 때 사용할 컨버터 클래스. 카프카에서 쓰거나 읽은 메세지 값 포맷은 이 클래스가 제어하며, 컨버터는 커넥터와는 독립적이기 때문에, 사용하는 커넥터와는 무관하게 어떤 직렬화 포맷으로도 작업할 수 있다. 많이 사용하는 포맷으로는 JSON, Avro가 있다.

  |         Type: | class |
  | ------------: | ----- |
  |      Default: | null  |
  | Valid Values: |       |
  |   Importance: | low   |

- #### header.converter

  카프카 커넥트 포맷과 카프카에 기록한 직렬화된 포맷 간을 변환할 때 사용할 HeaderConverter 클래스. 카프카에서 쓰거나 읽은 메세지의 헤더 값 포맷은 이 클래스가 제어하며, 컨버터는 커넥터와는 독립적이기 때문에, 사용하는 커넥터와는 무관하게 어떤 직렬화 포맷으로도 작업할 수 있다. 많이 사용하는 포맷으로는 JSON, Avro가 있다. 기본적으로는 헤더 값을 문자열로 직렬화하고, 스키마를 추론해서 역직렬화하는 SimpleHeaderConverter를 사용한다.

  |         Type: | class |
  | ------------: | ----- |
  |      Default: | null  |
  | Valid Values: |       |
  |   Importance: | low   |

- #### config.action.reload

  외부 설정 provider의 변경으로 커넥터의 설정 프로퍼티가 변경되었을 때 커넥트가 이 커넥터에 수행해야 하는 작업. 'none'은 커넥트가 아무 작업도 수행하지 않음을 의미한다. 'restart'는 커넥트가 업데이트된 설정 프로퍼티로 커넥터를 재시작/재로드해야 함을 의미한다. 외부 설정 provider가 설정 값이 향후에 만료된다고 표기한 경우엔 실제 재시작이 나중으로 스케줄링될 수 있다.

  |         Type: | string          |
  | ------------: | --------------- |
  |      Default: | restart         |
  | Valid Values: | [none, restart] |
  |   Importance: | low             |

- #### transforms

  레코드에 적용할 transformation들의 alias.

  |         Type: | list                                           |
  | ------------: | ---------------------------------------------- |
  |      Default: | ""                                             |
  | Valid Values: | non-null string, unique transformation aliases |
  |   Importance: | low                                            |

- #### predicates

  transformation에서 사용할 predicate들의 alias.

  |         Type: | list                                      |
  | ------------: | ----------------------------------------- |
  |      Default: | ""                                        |
  | Valid Values: | non-null string, unique predicate aliases |
  |   Importance: | low                                       |

- #### errors.retry.timeout

  실패한 작업을 다시 시도해볼 최대 기간 (밀리세컨드). 기본값은 0이며, 재시도하지 않음을 의미한다. 무한으로 재시도하려면 -1을 사용해라.

  |         Type: | long   |
  | ------------: | ------ |
  |      Default: | 0      |
  | Valid Values: |        |
  |   Importance: | medium |

- #### errors.retry.delay.max.ms

  이어서 재시도하기 전에 기다릴 최대 기간 (밀리세컨드). 이 제한 시간에 도달하면, 지연 시간에 지터를 추가해서 thundering herd issue를 방지한다.

  |         Type: | long             |
  | ------------: | ---------------- |
  |      Default: | 60000 (1 minute) |
  | Valid Values: |                  |
  |   Importance: | medium           |

- #### errors.tolerance

  커넥터 작업 중 발생하는 오류를 허용하는 동작 방식. 기본 값은 'none'이며, 어떤 에러라도 발생하는 즉시 커넥터 작업이 실패한다는 뜻이다. 'all'은 문제가 있는 레코드를 건너뛰도록 동작을 변경한다.

  |         Type: | string      |
  | ------------: | ----------- |
  |      Default: | none        |
  | Valid Values: | [none, all] |
  |   Importance: | medium      |

- #### errors.log.enable

  true일 땐, 모든 오류와 실패한 작업의 세부 정보, 문제가 있는 레코드를 커넥트 어플리케이션 로그에 기록한다. 이 설정은 'false'가 디폴트기 때문에, 허용되지 않는 오류만 보고한다.

  |         Type: | boolean |
  | ------------: | ------- |
  |      Default: | false   |
  | Valid Values: |         |
  |   Importance: | medium  |

- #### errors.log.include.messages

  실패를 초래한 커넥트 레코드를 로그에 포함시킬지 여부. 이 설정은 'false'가 디폴트이며, 이때는 로그 파일에 레코드 키, 값, 헤더는 기록하지 않지만, 토픽, 파티션 번호같은 일부 정보는 로깅한다.

  |         Type: | boolean |
  | ------------: | ------- |
  |      Default: | false   |
  | Valid Values: |         |
  |   Importance: | medium  |

- #### errors.deadletterqueue.topic.name

  이 싱크 커넥터나 커넥터의 transformation, 컨버터에서 처리 중 오류가 발생한 메세지의 DLQ(dead letter queue)로 사용할 토픽명. 토픽명은 공백이 기본값이며, DLQ에 메세지를 기록하지 않음을 의미한다.

  |         Type: | string |
  | ------------: | ------ |
  |      Default: | ""     |
  | Valid Values: |        |
  |   Importance: | medium |

- #### errors.deadletterqueue.topic.replication.factor

  DLQ(dead letter queue) 토픽이 존재하지 않는 경우, 이 토픽을 생성할 때 사용할 replication factor

  |         Type: | short  |
  | ------------: | ------ |
  |      Default: | 3      |
  | Valid Values: |        |
  |   Importance: | medium |

- #### errors.deadletterqueue.context.headers.enable

  true일 땐 DLQ(dead letter queue)에 기록하는 메세지에 에러 컨텍스트를 가진 헤더를 추가한다. 기존 레코드 헤더와의 충돌을 피하기 위해, 모든 에러 컨텍스트 헤더 키는 `__connect.errors.`로 시작한다.

  |         Type: | boolean |
  | ------------: | ------- |
  |      Default: | false   |
  | Valid Values: |         |
  |   Importance: | medium  |
