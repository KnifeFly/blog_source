---
title: CDH集群部署
date: 2018-05-15 10:01:29
tags: 大数据
---


# CDH集群部署

## 安装步骤

1. 安装JDK

2. host修改

   /etc/hosts配置文件

3. NTP时间同步

4. SSH免秘钥登录

5. 安装mariadb

   yum install install mariadb -y

6. mariadb 建表

   ```mysql
   SET PASSWORD=PASSWORD('xcloud2017');
   grant all privileges on *.* to 'root'@'%' identified by 'xcloud2017' with grant option; flush privileges;
   create database scmdbn DEFAULT CHARSET utf8 COLLATE utf8_general_ci;
   create database hive DEFAULT CHARSET utf8 COLLATE utf8_general_ci;
   create database amon DEFAULT CHARSET utf8 COLLATE utf8_general_ci;
   create database hue DEFAULT CHARSET utf8 COLLATE utf8_general_ci;
   create database monitor DEFAULT CHARSET utf8 COLLATE utf8_general_ci;
   create database report DEFAULT CHARSET utf8 COLLATE utf8_general_ci;
   create database oozie DEFAULT CHARSET utf8 COLLATE utf8_general_ci;
   ```

<!--more-->

7. 安装cloudera-manager

   所有节点都需要安装cloudera-manage，选某个节点安装执行命令如下：

   ```shell
   for i in {53..54}; do scp -P 2223 /usr/local/src/cdh-install.tar.gz root@124.238.237.$i:/root ; done
   for i in {53..54}; do ssh -p 2223 "tar zxvf /usr/local/src/cdh-install.tar.gz -C /usr/local/src/" ; done
   for i in {54..57}; do ssh -p 2223 root@124.238.237.$i "mkdir -p /opt/cloudera-manager" ; done
   for i in {54..57}; do ssh -p 2223 root@124.238.237.$i "tar -axvf /usr/local/src/cdh/cloudera-manager-centos7-cm5.14.3_x86_64.tar.gz -C /opt/cloudera-manager" ; done
   
   每台机器需要执行的操作：
   1.useradd --system --home=/opt/cloudera-manager/cm-5.14.3/run/cloudera-scm-server --no-create-home --shell=/bin/false --comment "Cloudera SCM User" cloudera-scm
   
   #更改manager master机器IP，以及绑定端口号，
   2. vim /opt/cloudera-manager/cm-5.14.3/etc/cloudera-scm-agent/config.ini
   
   #创建必要目录
   3. mkdir -p /opt/cloudera/parcels; chown cloudera-scm:cloudera-scm /opt/cloudera/parcels
   
   主节点机器执行的操作：
   mkdir /var/cloudera-scm-server;
   chown cloudera-scm:cloudera-scm /var/cloudera-scm-server;
   chown cloudera-scm:cloudera-scm /opt/cloudera-manager;
   
   mkdir -p /opt/cloudera/parcel-repo;
   chown cloudera-scm:cloudera-scm /opt/cloudera/parcel-repo;
   cp CDH-5.7.2-1.cdh5.7.2.p0.18-el7.parcel CDH-5.7.2-1.cdh5.7.2.p0.18-el7.parcel.sha manifest.json /opt/cloudera/parcel-repo ;
   ```

8. 启动cloudera组件

   - 启动cloudera-manage

   ```shell
   cp /opt/cloudera-manager/cm-5.14.3/etc/init.d/cloudera-scm-server /etc/init.d/cloudera-scm-server;
   
   chkconfig cloudera-scm-server on;
   
   # 更改CMF_DEFAULTS目录，更改为/opt/cloudera-manager/cm-5.14.3/etc/default
   vi /etc/init.d/cloudera-scm-server
   
   chmod 755 /run/systemd/generator.late/cloudera-scm-*
   
   service cloudera-scm-server start
   
   ##如果启动失败，查看/opt/cloudera-manager/cm-5.14.3/log/cloudera-scm-server/目录
   ```

   - 启动cloudera-agent

   ```shell
   每天机器agent机器执行：
   for i in {53..57}; do ssh -p 2223 root@124.238.237.$i " cp /opt/cloudera-manager/cm-5.14.3/etc/init.d/cloudera-scm-agent /etc/init.d/cloudera-scm-agent" ; done
   
   chkconfig cloudera-scm-agent on
   
   #CMF_DEFAULTS=${CMF_DEFAULTS:-/etc/default}改为=/opt/cloudera-manager/cm-5.14.3/etc/default
   vi /etc/init.d/cloudera-scm-agent
   
   service cloudera-scm-agent start
   
   ##如果启动失败，查看/opt/cloudera-manager/cm-5.14.3/log/cloudera-scm-agent/目录
   ```

----

### Mysql配置文件

```conf
[mysqld]
transaction-isolation = READ-COMMITTED
# Disabling symbolic-links is recommended to prevent assorted security risks;
# to do so, uncomment this line:
# symbolic-links = 0

key_buffer = 16M
key_buffer_size = 32M
max_allowed_packet = 32M
thread_stack = 256K
thread_cache_size = 64
query_cache_limit = 8M
query_cache_size = 64M
query_cache_type = 1

max_connections = 550
#expire_logs_days = 10
#max_binlog_size = 100M

#log_bin should be on a disk with enough free space. Replace '/var/lib/mysql/mysql_binary_log' with an appropriate path for your system
#and chown the specified folder to the mysql user.
log_bin=/var/lib/mysql/mysql_binary_log

binlog_format = mixed

read_buffer_size = 2M
read_rnd_buffer_size = 16M
sort_buffer_size = 8M
join_buffer_size = 8M

# InnoDB settings
innodb_file_per_table = 1
innodb_flush_log_at_trx_commit  = 2
innodb_log_buffer_size = 64M
innodb_buffer_pool_size = 4G
innodb_thread_concurrency = 8
innodb_flush_method = O_DIRECT
innodb_log_file_size = 512M

[mysqld_safe]
log-error=/var/log/mariadb/mariadb.log
pid-file=/var/run/mariadb/mariadb.pid
```

### 组件配置

1. iptables配置

  开启防火墙，避免被提交yarn任务

```shell
  iptables-restore <  /etc/sysconfig/iptables
```

2. kafka配置

   num.partitions 配置为10

   default.replication.factor 配置为3

   其余默认配置即可

3. flume配置

  采集配置demo

```
a1.sources = squid_source squidFlow_source 
a1.sinks = squid_sink squidFlow_sink 
a1.channels = squid_channel 

#################################################################################################
# squid log source
a1.sources.squid_source.selector.type = replicating
a1.sources.squid_source.type = spooldir
a1.sources.squid_source.spoolDir = /xcloud-log/logFlume/squid
a1.sources.squid_source.fileHeader = true
a1.sources.squid_source.deletePolicy = immediate
a1.sources.squid_source.channels = squid_channel
a1.sources.squid_source.inputCharset = ASCII
a1.sources.squid_source.deserializer.inputCharset = ASCII
a1.sources.squid_source.decodeErrorPolicy = REPLACE
a1.sources.squid_source.deserializer.maxLineLength = 10240
a1.sources.squid_source.interceptors = i1
a1.sources.squid_source.interceptors.i1.type = org.apache.flume.sink.solr.morphline.UUIDInterceptor$Builder
a1.sources.squid_source.interceptors.i1.headerName = key
a1.sources.squid_source.interceptors.i1.preserveExisting = false

# squid log channel
a1.channels.squid_channel.type = memory
a1.channels.squid_channel.capacity = 10000
a1.channels.squid_channel.transactionCapacity = 1000


# squid log sinks
a1.sinks.squid_sink.channel = squid_channel
a1.sinks.squid_sink.type = org.apache.flume.sink.kafka.KafkaSink
a1.sinks.squid_sink.kafka.topic = kafka_squidlog_topic
a1.sinks.squid_sink.kafka.bootstrap.servers = 121.9.240.249:9092,121.9.240.250:9092,121.9.240.251:9092,121.9.240.252:9092,121.9.240.253:9092
a1.sinks.squid_sink.kafka.producer.acks = 1
a1.sinks.squid_sink.kafka.flumeBatchSize = 5000

```

