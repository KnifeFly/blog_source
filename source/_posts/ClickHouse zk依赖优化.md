---
title: ClickHouse zk依赖优化
date: 2019-06-15 12:01:54
tags: ClickHouse
---

# ClickHouse zk依赖优化

ClickHouse 集群严重依赖zookeeper，clickhouse集群服务会在zk上存储大量的信息，例如数据库表metadata、blocksr、replicas等信息，znode节点和数据量/数据表呈线性相关。

ClickHouse把zk当做三种服务的结合，协调服务，日志服务、数据表catalog service。同时clickhouse在启动时还会对存在本地表的schema信息和存在zk上的schema信息做校验，如果两者存在差异则启动异常。

当前我们没有能力针对clickhouse做源码定制化，只能通过一些优化手段，让zk不至于成为整个系统的瓶颈。



第一原则是clickhouse依赖的zk不要和其他组件公用，其次是zk的各种参数调优。线上我们有个ClickHouse集群依赖的zk和其他组件公用，并且该zk还数据还存在机械盘上，严重影响到了ClickHouse集群的性能。ClickHouse从老的公用zookeeper中迁移到新的zookeeper的一些流程：

1. 新部署一个zookeeper组件，把zk组件的dataDir和dataLogDir存放固盘，如果条件允许的话这两个目录最好不要存放在同一个固盘;

   

2. 从老Zookeeper中获取最新的snapshot，并且传输到新zookeeper中myid最大的三台机器上(假设zk节点为5);

   

3. 增大新zookeeper的syncLimit和initLimit配置项，避免zookeeper在leader选举时同步snapshot超时，导致leader选举失败，因为clickhouse在zookeeper上创建的节点很多，并且snapshot文件挺大；

   

4. 新zookeeper部署完成后，检测clickhouse在zk上的znode节点是否和老节点一致;

   

5. 更改clickhouse配置文件中zk相关的设置，涉及到的主要配置文件:

   > /etc/clickhouse-server/metrika.xml
   >
   > /etc/clickhouse-server-wingman/metrika.xml
   >
   > /etc/clickhouse-server/config-preprocessed.xml

   

6. 停止入库到clickhouse的程序，例如logkit、zabbix to clickhouse程序

   

7. 停止clickhouse各个分片服务 
   > service clickhouse-server stop
   >
   > service clickhouse-server-wingman stop



其次是zookeeper参数调优，可以参考官方文档：

```toml
# http://hadoop.apache.org/zookeeper/docs/current/zookeeperAdmin.html

# The number of milliseconds of each tick
tickTime=2000
# The number of ticks that the initial
# synchronization phase can take
initLimit=30000
# The number of ticks that can pass between
# sending a request and getting an acknowledgement
syncLimit=10

maxClientCnxns=2000

maxSessionTimeout=60000000
# the directory where the snapshot is stored.
dataDir=/opt/zookeeper/{{ cluster['name'] }}/data
# Place the dataLogDir to a separate physical disc for better performance
dataLogDir=/opt/zookeeper/{{ cluster['name'] }}/logs

autopurge.snapRetainCount=10
autopurge.purgeInterval=1


# To avoid seeks ZooKeeper allocates space in the transaction log file in
# blocks of preAllocSize kilobytes. The default block size is 64M. One reason
# for changing the size of the blocks is to reduce the block size if snapshots
# are taken more often. (Also, see snapCount).
preAllocSize=131072

# Clients can submit requests faster than ZooKeeper can process them,
# especially if there are a lot of clients. To prevent ZooKeeper from running
# out of memory due to queued requests, ZooKeeper will throttle clients so that
# there is no more than globalOutstandingLimit outstanding requests in the
# system. The default limit is 1,000.ZooKeeper logs transactions to a
# transaction log. After snapCount transactions are written to a log file a
# snapshot is started and a new transaction log file is started. The default
# snapCount is 10,000.
snapCount=3000000

# If this option is defined, requests will be will logged to a trace file named
# traceFile.year.month.day.
#traceFile=

# Leader accepts client connections. Default value is "yes". The leader machine
# coordinates updates. For higher update throughput at thes slight expense of
# read throughput the leader can be configured to not accept clients and focus
# on coordination.
leaderServes=yes

standaloneEnabled=false
dynamicConfigFile=/etc/zookeeper-{{ cluster['name'] }}/conf/zoo.cfg.dynamic
```



Java虚拟机参数调优：

```toml
NAME=zookeeper-{{ cluster['name'] }}
ZOOCFGDIR=/etc/$NAME/conf

# TODO this is really ugly
# How to find out, which jars are needed?
# seems, that log4j requires the log4j.properties file to be in the classpath
CLASSPATH="$ZOOCFGDIR:/usr/build/classes:/usr/build/lib/*.jar:/usr/share/zookeeper/zookeeper-3.5.1-metrika.jar:/usr/share/zookeeper/slf4j-log4j12-1.7.5.jar:/usr/share/zookeeper/slf4j-api-1.7.5.jar:/usr/share/zookeeper/servlet-api-2.5-20081211.jar:/usr/share/zookeeper/netty-3.7.0.Final.jar:/usr/share/zookeeper/log4j-1.2.16.jar:/usr/share/zookeeper/jline-2.11.jar:/usr/share/zookeeper/jetty-util-6.1.26.jar:/usr/share/zookeeper/jetty-6.1.26.jar:/usr/share/zookeeper/javacc.jar:/usr/share/zookeeper/jackson-mapper-asl-1.9.11.jar:/usr/share/zookeeper/jackson-core-asl-1.9.11.jar:/usr/share/zookeeper/commons-cli-1.2.jar:/usr/src/java/lib/*.jar:/usr/etc/zookeeper"

ZOOCFG="$ZOOCFGDIR/zoo.cfg"
ZOO_LOG_DIR=/var/log/$NAME
USER=zookeeper
GROUP=zookeeper
PIDDIR=/var/run/$NAME
PIDFILE=$PIDDIR/$NAME.pid
SCRIPTNAME=/etc/init.d/$NAME
JAVA=/usr/bin/java
ZOOMAIN="org.apache.zookeeper.server.quorum.QuorumPeerMain"
ZOO_LOG4J_PROP="INFO,ROLLINGFILE"
JMXLOCALONLY=false
JAVA_OPTS="-Xms{{ cluster.get('xms','128M') }} \
    -Xmx{{ cluster.get('xmx','1G') }} \
    -Xloggc:/var/log/$NAME/zookeeper-gc.log \
    -XX:+UseGCLogFileRotation \
    -XX:NumberOfGCLogFiles=16 \
    -XX:GCLogFileSize=16M \
    -verbose:gc \
    -XX:+PrintGCTimeStamps \
    -XX:+PrintGCDateStamps \
    -XX:+PrintGCDetails
    -XX:+PrintTenuringDistribution \
    -XX:+PrintGCApplicationStoppedTime \
    -XX:+PrintGCApplicationConcurrentTime \
    -XX:+PrintSafepointStatistics \
    -XX:+UseParNewGC \
    -XX:+UseConcMarkSweepGC \
-XX:+CMSParallelRemarkEnabled"
```