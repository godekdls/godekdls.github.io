---
title: Exporters and integrations
category: Prometheus
order: 47
permalink: /Prometheus/exporters/
description: 메트릭을 프로메테우스 지원 포맷으로 노출해주는 익스포터들 정리
image: ./../../images/prometheus/logo.png
lastmod: 2021-05-16T17:00:00+09:00
comments: true
originalRefName: 프로메테우스
originalRefLink: https://prometheus.io/docs/instrumenting/exporters/
parent: INSTRUMENTING
parentUrl: /Prometheus/instrumenting/
---

---

써드 파티 시스템에 있는 기존 메트릭을 프로메테우스 메트릭으로 익스포트하는 일을 도와주는 여러 가지 라이브러리와 서버들이 있다. 프로메테우스 메트릭으로 직접 계측하는 게 불가능한 시스템에서 유용할 거다 (예를 들어 HAProxy나 리눅스 시스템 통계 등).

### 목차

- [Third-party exporters](#third-party-exporters)
  + [Databases](#databases)
  + [Hardware related](#hardware-related)
  + [Issue trackers and continuous integration](#issue-trackers-and-continuous-integration)
  + [Messaging systems](#messaging-systems)
  + [Storage](#storage)
  + [HTTP](#http)
  + [APIs](#apis)
  + [Logging](#logging)
  + [Other monitoring systems](#other-monitoring-systems)
  + [Miscellaneous](#miscellaneous)
- [Software exposing Prometheus metrics](#software-exposing-prometheus-metrics)
- [Other third-party utilities](#other-third-party-utilities)

---

## Third-party exporters

이 익스포터 중 일부는 공식 [프로메테우스 깃허브 organization](https://github.com/prometheus)에서 관리하고 있으며, 이런 것들은 *official*로 표시해뒀다. 나머지는 외부에서 기여한 익스포터들로, 외부에서 유지관리한다.

더 많은 익스포터를 만들기를 권장하고는 있지만, [베스트 프랙티스](../writing-exporters)를 위해 모든 익스포터를 전수조사하지는 않았다. 일반적으로 이런 익스포터들은 프로메테우스 깃허브 organization 외부에서 호스팅하고 있다.

[익스포터 디폴트 포트](https://github.com/prometheus/prometheus/wiki/Default-port-allocations) 위키 페이지는 하나의 익스포터 카탈로그로 자리 잡았으며, 기능이 중복되거나 아직 개발 중인 것도 있기 때문에 여기에서 나열하지 않은 익스포터가 있을 수도 있다.

[JMX 익스포터](https://github.com/prometheus/jmx_exporter)는 [카프카](https://kafka.apache.org/)나 [Cassandra](https://cassandra.apache.org/)같이 다양한 JVM 기반 애플리케이션에서 메트릭을 익스포트할 수 있다.

### Databases

- [Aerospike exporter](https://github.com/aerospike/aerospike-prometheus-exporter)
- [ClickHouse exporter](https://github.com/f1yegor/clickhouse_exporter)
- [Consul exporter](https://github.com/prometheus/consul_exporter) (**official**)
- [Couchbase exporter](https://github.com/blakelead/couchbase_exporter)
- [CouchDB exporter](https://github.com/gesellix/couchdb-exporter)
- [Druid Exporter](https://github.com/opstree/druid-exporter)
- [Elasticsearch exporter](https://github.com/prometheus-community/elasticsearch_exporter)
- [EventStore exporter](https://github.com/marcinbudny/eventstore_exporter)
- [IoTDB exporter](https://github.com/fagnercarvalho/prometheus-iotdb-exporter)
- [KDB+ exporter](https://github.com/KxSystems/prometheus-kdb-exporter)
- [Memcached exporter](https://github.com/prometheus/memcached_exporter) (**official**)
- [MongoDB exporter](https://github.com/dcu/mongodb_exporter)
- [MongoDB query exporter](https://github.com/raffis/mongodb-query-exporter)
- [MSSQL server exporter](https://github.com/awaragi/prometheus-mssql-exporter)
- [MySQL router exporter](https://github.com/rluisr/mysqlrouter_exporter)
- [MySQL server exporter](https://github.com/prometheus/mysqld_exporter) (**official**)
- [OpenTSDB Exporter](https://github.com/cloudflare/opentsdb_exporter)
- [Oracle DB Exporter](https://github.com/iamseth/oracledb_exporter)
- [PgBouncer exporter](https://github.com/prometheus-community/pgbouncer_exporter)
- [PostgreSQL exporter](https://github.com/prometheus-community/postgres_exporter)
- [Presto exporter](https://github.com/yahoojapan/presto_exporter)
- [ProxySQL exporter](https://github.com/percona/proxysql_exporter)
- [RavenDB exporter](https://github.com/marcinbudny/ravendb_exporter)
- [Redis exporter](https://github.com/oliver006/redis_exporter)
- [RethinkDB exporter](https://github.com/oliver006/rethinkdb_exporter)
- [SQL exporter](https://github.com/free/sql_exporter)
- [Tarantool metric library](https://github.com/tarantool/metrics)
- [Twemproxy](https://github.com/stuartnelson3/twemproxy_exporter)

### Hardware related

- [apcupsd exporter](https://github.com/mdlayher/apcupsd_exporter)
- [BIG-IP exporter](https://github.com/ExpressenAB/bigip_exporter)
- [Bosch Sensortec BMP/BME exporter](https://github.com/David-Igou/bsbmp-exporter)
- [Collins exporter](https://github.com/soundcloud/collins_exporter)
- [Dell Hardware OMSA exporter](https://github.com/galexrt/dellhw_exporter)
- [Disk usage exporter](https://github.com/dundee/disk_usage_exporter)
- [Fortigate exporter](https://github.com/bluecmd/fortigate_exporter)
- [IBM Z HMC exporter](https://github.com/zhmcclient/zhmc-prometheus-exporter)
- [IoT Edison exporter](https://github.com/roman-vynar/edison_exporter)
- [InfiniBand exporter](https://github.com/treydock/infiniband_exporter)
- [IPMI exporter](https://github.com/soundcloud/ipmi_exporter)
- [knxd exporter](https://github.com/RichiH/knxd_exporter)
- [Modbus exporter](https://github.com/RichiH/modbus_exporter)
- [Netgear Cable Modem Exporter](https://github.com/ickymettle/netgear_cm_exporter)
- [Netgear Router exporter](https://github.com/DRuggeri/netgear_exporter)
- [Network UPS Tools (NUT) exporter](https://github.com/DRuggeri/nut_exporter)
- [Node/system metrics exporter](https://github.com/prometheus/node_exporter) (**official**)
- [NVIDIA GPU exporter](https://github.com/mindprince/nvidia_gpu_prometheus_exporter)
- [ProSAFE exporter](https://github.com/dalance/prosafe_exporter)
- [Ubiquiti UniFi exporter](https://github.com/mdlayher/unifi_exporter)
- [Waveplus Radon Sensor Exporter](https://github.com/jeremybz/waveplus_exporter)
- [Weathergoose Climate Monitor Exporter](https://github.com/branttaylor/watchdog-prometheus-exporter)
- [Windows exporter](https://github.com/prometheus-community/windows_exporter)

### Issue trackers and continuous integration

- [Bamboo exporter](https://github.com/AndreyVMarkelov/bamboo-prometheus-exporter)
- [Bitbucket exporter](https://github.com/AndreyVMarkelov/prom-bitbucket-exporter)
- [Confluence exporter](https://github.com/AndreyVMarkelov/prom-confluence-exporter)
- [Jenkins exporter](https://github.com/lovoo/jenkins_exporter)
- [JIRA exporter](https://github.com/AndreyVMarkelov/jira-prometheus-exporter)

### Messaging systems

- [Beanstalkd exporter](https://github.com/messagebird/beanstalkd_exporter)
- [EMQ exporter](https://github.com/nuvo/emq_exporter)
- [Gearman exporter](https://github.com/bakins/gearman-exporter)
- [IBM MQ exporter](https://github.com/ibm-messaging/mq-metric-samples/tree/master/cmd/mq_prometheus)
- [Kafka exporter](https://github.com/danielqsj/kafka_exporter)
- [NATS exporter](https://github.com/nats-io/prometheus-nats-exporter)
- [NSQ exporter](https://github.com/lovoo/nsq_exporter)
- [Mirth Connect exporter](https://github.com/vynca/mirth_exporter)
- [MQTT blackbox exporter](https://github.com/inovex/mqtt_blackbox_exporter)
- [MQTT2Prometheus](https://github.com/hikhvar/mqtt2prometheus)
- [RabbitMQ exporter](https://github.com/kbudde/rabbitmq_exporter)
- [RabbitMQ Management Plugin exporter](https://github.com/deadtrickster/prometheus_rabbitmq_exporter)
- [RocketMQ exporter](https://github.com/apache/rocketmq-exporter)
- [Solace exporter](https://github.com/solacecommunity/solace-prometheus-exporter)

### Storage

- [Ceph exporter](https://github.com/digitalocean/ceph_exporter)
- [Ceph RADOSGW exporter](https://github.com/blemmenes/radosgw_usage_exporter)
- [Gluster exporter](https://github.com/ofesseler/gluster_exporter)
- [GPFS exporter](https://github.com/treydock/gpfs_exporter)
- [Hadoop HDFS FSImage exporter](https://github.com/marcelmay/hadoop-hdfs-fsimage-exporter)
- [HPE CSI info metrics provider](https://scod.hpedev.io/csi_driver/metrics.html)
- [HPE storage array exporter](https://hpe-storage.github.io/array-exporter/)
- [Lustre exporter](https://github.com/HewlettPackard/lustre_exporter)
- [NetApp E-Series exporter](https://github.com/treydock/eseries_exporter)
- [Pure Storage exporter](https://github.com/PureStorage-OpenConnect/pure-exporter)
- [ScaleIO exporter](https://github.com/syepes/sio2prom)
- [Tivoli Storage Manager/IBM Spectrum Protect exporter](https://github.com/treydock/tsm_exporter)

### HTTP

- [Apache exporter](https://github.com/Lusitaniae/apache_exporter)
- [HAProxy exporter](https://github.com/prometheus/haproxy_exporter) (**official**)
- [Nginx metric library](https://github.com/knyar/nginx-lua-prometheus)
- [Nginx VTS exporter](https://github.com/hnlq715/nginx-vts-exporter)
- [Passenger exporter](https://github.com/stuartnelson3/passenger_exporter)
- [Squid exporter](https://github.com/boynux/squid-exporter)
- [Tinyproxy exporter](https://github.com/igzivkov/tinyproxy_exporter)
- [Varnish exporter](https://github.com/jonnenauha/prometheus_varnish_exporter)
- [WebDriver exporter](https://github.com/mattbostock/webdriver_exporter)

### APIs

- [AWS ECS exporter](https://github.com/slok/ecs-exporter)
- [AWS Health exporter](https://github.com/Jimdo/aws-health-exporter)
- [AWS SQS exporter](https://github.com/jmal98/sqs_exporter)
- [Azure Health exporter](https://github.com/FXinnovation/azure-health-exporter)
- [BigBlueButton](https://github.com/greenstatic/bigbluebutton-exporter)
- [Cloudflare exporter](https://gitlab.com/gitlab-org/cloudflare_exporter)
- [Cryptowat exporter](https://github.com/nbarrientos/cryptowat_exporter)
- [DigitalOcean exporter](https://github.com/metalmatze/digitalocean_exporter)
- [Docker Cloud exporter](https://github.com/infinityworksltd/docker-cloud-exporter)
- [Docker Hub exporter](https://github.com/infinityworksltd/docker-hub-exporter)
- [Fastly exporter](https://github.com/peterbourgon/fastly-exporter)
- [GitHub exporter](https://github.com/infinityworksltd/github-exporter)
- [Gmail exporter](https://github.com/jamesread/prometheus-gmail-exporter/)
- [InstaClustr exporter](https://github.com/fcgravalos/instaclustr_exporter)
- [Mozilla Observatory exporter](https://github.com/Jimdo/observatory-exporter)
- [OpenWeatherMap exporter](https://github.com/RichiH/openweathermap_exporter)
- [Pagespeed exporter](https://github.com/foomo/pagespeed_exporter)
- [Rancher exporter](https://github.com/infinityworksltd/prometheus-rancher-exporter)
- [Speedtest exporter](https://github.com/nlamirault/speedtest_exporter)
- [Tankerkönig API Exporter](https://github.com/lukasmalkmus/tankerkoenig_exporter)

### Logging

- [Fluentd exporter](https://github.com/V3ckt0r/fluentd_exporter)
- [Google's mtail log data extractor](https://github.com/google/mtail)
- [Grok exporter](https://github.com/fstab/grok_exporter)

### Other monitoring systems

- [Akamai Cloudmonitor exporter](https://github.com/ExpressenAB/cloudmonitor_exporter)
- [Alibaba Cloudmonitor exporter](https://github.com/aylei/aliyun-exporter)
- [AWS CloudWatch exporter](https://github.com/prometheus/cloudwatch_exporter) (**official**)
- [Azure Monitor exporter](https://github.com/RobustPerception/azure_metrics_exporter)
- [Cloud Foundry Firehose exporter](https://github.com/cloudfoundry-community/firehose_exporter)
- [Collectd exporter](https://github.com/prometheus/collectd_exporter) (**official**)
- [Google Stackdriver exporter](https://github.com/frodenas/stackdriver_exporter)
- [Graphite exporter](https://github.com/prometheus/graphite_exporter) (**official**)
- [Heka dashboard exporter](https://github.com/docker-infra/heka_exporter)
- [Heka exporter](https://github.com/imgix/heka_exporter)
- [Huawei Cloudeye exporter](https://github.com/huaweicloud/cloudeye-exporter)
- [InfluxDB exporter](https://github.com/prometheus/influxdb_exporter) (**official**)
- [ITM exporter](https://github.com/rafal-szypulka/itm_exporter)
- [JavaMelody exporter](https://github.com/fschlag/javamelody-prometheus-exporter)
- [JMX exporter](https://github.com/prometheus/jmx_exporter) (**official**)
- [Munin exporter](https://github.com/pvdh/munin_exporter)
- [Nagios / Naemon exporter](https://github.com/Griesbacher/Iapetos)
- [New Relic exporter](https://github.com/mrf/newrelic_exporter)
- [NRPE exporter](https://github.com/robustperception/nrpe_exporter)
- [Osquery exporter](https://github.com/zwopir/osquery_exporter)
- [OTC CloudEye exporter](https://github.com/tiagoReichert/otc-cloudeye-prometheus-exporter)
- [Pingdom exporter](https://github.com/giantswarm/prometheus-pingdom-exporter)
- [Promitor (Azure Monitor)](https://promitor.io/)
- [scollector exporter](https://github.com/tgulacsi/prometheus_scollector)
- [Sensu exporter](https://github.com/reachlin/sensu_exporter)
- [site24x7_exporter](https://github.com/svenstaro/site24x7_exporter)
- [SNMP exporter](https://github.com/prometheus/snmp_exporter) (**official**)
- [StatsD exporter](https://github.com/prometheus/statsd_exporter) (**official**)
- [TencentCloud monitor exporter](https://github.com/tencentyun/tencentcloud-exporter)
- [ThousandEyes exporter](https://github.com/sapcc/1000eyes_exporter)

### Miscellaneous

- [ACT Fibernet Exporter](https://git.captnemo.in/nemo/prometheus-act-exporter)
- [BIND exporter](https://github.com/prometheus-community/bind_exporter)
- [BIND query exporter](https://github.com/DRuggeri/bind_query_exporter)
- [Bitcoind exporter](https://github.com/LePetitBloc/bitcoind-exporter)
- [Blackbox exporter](https://github.com/prometheus/blackbox_exporter) (**official**)
- [BOSH exporter](https://github.com/cloudfoundry-community/bosh_exporter)
- [cAdvisor](https://github.com/google/cadvisor)
- [Cachet exporter](https://github.com/ContaAzul/cachet_exporter)
- [ccache exporter](https://github.com/virtualtam/ccache_exporter)
- [c-lightning exporter](https://github.com/lightningd/plugins/tree/master/prometheus)
- [DHCPD leases exporter](https://github.com/DRuggeri/dhcpd_leases_exporter)
- [Dovecot exporter](https://github.com/kumina/dovecot_exporter)
- [Dnsmasq exporter](https://github.com/google/dnsmasq_exporter)
- [eBPF exporter](https://github.com/cloudflare/ebpf_exporter)
- [Ethereum Client exporter](https://github.com/31z4/ethereum-prometheus-exporter)
- [JFrog Artifactory Exporter](https://github.com/peimanja/artifactory_exporter)
- [Hostapd Exporter](https://github.com/Fundacio-i2CAT/hostapd_prometheus_exporter)
- [IRCd exporter](https://github.com/dgl/ircd_exporter)
- [Linux HA ClusterLabs exporter](https://github.com/ClusterLabs/ha_cluster_exporter)
- [JMeter plugin](https://github.com/johrstrom/jmeter-prometheus-plugin)
- [JSON exporter](https://github.com/prometheus-community/json_exporter)
- [Kannel exporter](https://github.com/apostvav/kannel_exporter)
- [Kemp LoadBalancer exporter](https://github.com/giantswarm/prometheus-kemp-exporter)
- [Kibana Exporter](https://github.com/pjhampton/kibana-prometheus-exporter)
- [kube-state-metrics](https://github.com/kubernetes/kube-state-metrics)
- [Locust Exporter](https://github.com/ContainerSolutions/locust_exporter)
- [Meteor JS web framework exporter](https://atmospherejs.com/sevki/prometheus-exporter)
- [Minecraft exporter module](https://github.com/Baughn/PrometheusIntegration)
- [Minecraft exporter](https://github.com/dirien/minecraft-prometheus-exporter)
- [Nomad exporter](https://gitlab.com/yakshaving.art/nomad-exporter)
- [nftables exporter](https://github.com/Intrinsec/nftables_exporter)
- [OpenStack exporter](https://github.com/openstack-exporter/openstack-exporter)
- [OpenStack blackbox exporter](https://github.com/infraly/openstack_client_exporter)
- [oVirt exporter](https://github.com/czerwonk/ovirt_exporter)
- [Pact Broker exporter](https://github.com/ContainerSolutions/pactbroker_exporter)
- [PHP-FPM exporter](https://github.com/bakins/php-fpm-exporter)
- [PowerDNS exporter](https://github.com/ledgr/powerdns_exporter)
- [Process exporter](https://github.com/ncabatoff/process-exporter)
- [rTorrent exporter](https://github.com/mdlayher/rtorrent_exporter)
- [Rundeck exporter](https://github.com/phsmith/rundeck_exporter)
- [SABnzbd exporter](https://github.com/msroest/sabnzbd_exporter)
- [Script exporter](https://github.com/adhocteam/script_exporter)
- [Shield exporter](https://github.com/cloudfoundry-community/shield_exporter)
- [Smokeping prober](https://github.com/SuperQ/smokeping_prober)
- [SMTP/Maildir MDA blackbox prober](https://github.com/cherti/mailexporter)
- [SoftEther exporter](https://github.com/dalance/softether_exporter)
- [SSH exporter](https://github.com/treydock/ssh_exporter)
- [Teamspeak3 exporter](https://github.com/hikhvar/ts3exporter)
- [Transmission exporter](https://github.com/metalmatze/transmission-exporter)
- [Unbound exporter](https://github.com/kumina/unbound_exporter)
- [WireGuard exporter](https://github.com/MindFlavor/prometheus_wireguard_exporter)
- [Xen exporter](https://github.com/lovoo/xenstats_exporter)

프로메테우스 익스포터를 새로 구현한다면 [익스포터 작성 가이드라인](../writing-exporter)을 따라주길 바란다. [개발 메일링 리스트](https://groups.google.com/forum/#!forum/prometheus-developers)에 연락해보는 것도 함께 고려해주면 좋겠다. 익스포터를 최대한 유용하고 일관성 있게 만들 수 있도록 조언을 아끼지 않겠다.

---

## Software exposing Prometheus metrics

써드 파티 소프트웨어 중에는 프로메테우스 포맷으로 메트릭을 노출하는 소프트웨어도 있다. 여기서는 별도 익스포터가 필요하지 않다:

- [Ansible Tower (AWX)](https://docs.ansible.com/ansible-tower/latest/html/administration/metrics.html)
- [App Connect Enterprise](https://github.com/ot4i/ace-docker)
- [Ballerina](https://ballerina.io/)
- [BFE](https://github.com/baidu/bfe)
- [Caddy](https://caddyserver.com/docs/metrics) (**direct**)
- [Ceph](https://docs.ceph.com/en/latest/mgr/prometheus/)
- [CockroachDB](https://www.cockroachlabs.com/docs/stable/monitoring-and-alerting.html#prometheus-endpoint)
- [Collectd](https://collectd.org/wiki/index.php/Plugin:Write_Prometheus)
- [Concourse](https://concourse-ci.org/)
- [CRG Roller Derby Scoreboard](https://github.com/rollerderby/scoreboard) (**direct**)
- [Diffusion](https://docs.pushtechnology.com/docs/latest/manual/html/administratorguide/systemmanagement/r_statistics.html)
- [Docker Daemon](https://docs.docker.com/engine/reference/commandline/dockerd/#daemon-metrics)
- [Doorman](https://github.com/youtube/doorman) (**direct**)
- [Dovecot](https://doc.dovecot.org/configuration_manual/stats/openmetrics/)
- [Envoy](https://www.envoyproxy.io/docs/envoy/latest/operations/admin.html#get--stats?format=prometheus)
- [Etcd](https://github.com/coreos/etcd) (**direct**)
- [Flink](https://github.com/apache/flink)
- [FreeBSD Kernel](https://www.freebsd.org/cgi/man.cgi?query=prometheus_sysctl_exporter&apropos=0&sektion=8&manpath=FreeBSD+12-current&arch=default&format=html)
- [GitLab](https://docs.gitlab.com/ee/administration/monitoring/prometheus/gitlab_metrics.html)
- [Grafana](https://grafana.com/docs/grafana/latest/administration/view-server/internal-metrics/)
- [JavaMelody](https://github.com/javamelody/javamelody/wiki/UserGuideAdvanced#exposing-metrics-to-prometheus)
- [Kong](https://github.com/Kong/kong-plugin-prometheus)
- [Kubernetes](https://github.com/kubernetes/kubernetes) (**direct**)
- [Linkerd](https://github.com/BuoyantIO/linkerd)
- [mgmt](https://github.com/purpleidea/mgmt/blob/master/docs/prometheus.md)
- [MidoNet](https://github.com/midonet/midonet)
- [midonet-kubernetes](https://github.com/midonet/midonet-kubernetes) (**direct**)
- [MinIO](https://docs.minio.io/docs/how-to-monitor-minio-using-prometheus.html)
- [PATROL with Monitoring Studio X](https://www.sentrysoftware.com/library/swsyx/prometheus/exposing-patrol-parameters-in-prometheus.html)
- [Netdata](https://github.com/firehol/netdata)
- [Pomerium](https://pomerium.com/reference/#metrics-address)
- [Pretix](https://pretix.eu/)
- [Quobyte](https://www.quobyte.com/) (**direct**)
- [RabbitMQ](https://rabbitmq.com/prometheus.html)
- [RobustIRC](https://robustirc.net/)
- [ScyllaDB](https://github.com/scylladb/scylla)
- [Skipper](https://github.com/zalando/skipper)
- [SkyDNS](https://github.com/skynetservices/skydns) (**direct**)
- [Telegraf](https://github.com/influxdata/telegraf/tree/master/plugins/outputs/prometheus_client)
- [Traefik](https://github.com/containous/traefik)
- [Vector](https://vector.dev/)
- [VerneMQ](https://github.com/vernemq/vernemq)
- [Weave Flux](https://github.com/weaveworks/flux)
- [Xandikos](https://www.xandikos.org/) (**direct**)
- [Zipkin](https://github.com/openzipkin/zipkin/tree/master/zipkin-server#metrics)

*direct*로 표시해둔 소프트웨어는 프로메테우스 클라이언트 라이브러리를 통해 직접 계측도 하는 소프트웨어들이다.

---

## Other third-party utilities

이 섹션에는 특정 언어로 코드를 계측하는 일을 도와주는 라이브러리들과 기타 유틸리티들을 정리해뒀다. 이것들은 자체가 프로메테우스 클라이언트 라이브러리는 아니지만, 내부에서 일반적인 프로메테우스 클라이언트 라이브러리 중 하나를 사용하고 있다. 베스트 프랙티스를 위해 독립적으로 관리하는 모든 소프트웨어를 전수조사하진 않았다.

- Clojure: [iapetos](https://github.com/clj-commons/iapetos)
- Go: [go-metrics instrumentation library](https://github.com/armon/go-metrics)
- Go: [gokit](https://github.com/peterbourgon/gokit)
- Go: [prombolt](https://github.com/mdlayher/prombolt)
- Java/JVM: [EclipseLink metrics collector](https://github.com/VitaNuova/eclipselinkexporter)
- Java/JVM: [Hystrix metrics publisher](https://github.com/ahus1/prometheus-hystrix)
- Java/JVM: [Jersey metrics collector](https://github.com/VitaNuova/jerseyexporter)
- Java/JVM: [Micrometer Prometheus Registry](https://micrometer.io/docs/registry/prometheus)
- Python-Django: [django-prometheus](https://github.com/korfuri/django-prometheus)
- Node.js: [swagger-stats](https://github.com/slanatech/swagger-stats)