---
title: Kafka运营-NotLeaderForPartitionException异常
date: 2019-01-03 12:11:22
tags: kafka
---


## Kafka NotLeaderForPartitionException异常

### 异常分析

1.Kafka日志分析

发现Kafka日志中有比较多的org.apache.kafka.common.errors.NotLeaderForPartitionException异常信息，该异常从字面解释就是某个分区的leader找不到，具体异常信息如下：

```java
2019-01-18 22:01:00,802 ERROR kafka.server.ReplicaFetcherThread: [ReplicaFetcherThread-0-118]: Error for partition [kafka_custflow_topic_test,5] to broker 118:org.apache.kafka.common.errors.NotLeaderForPartitionException: This server is not the leader for that topic-partition.
```

通常来说该异常信息是由于kafka和zk连接存在超时，接着导致Controller重新选举导致获取元数据不正确，timed out的那台Broker所持有的partition就会出现NotLeaderForPartitionException，kafka中连接zk超时日志格式信息如下:

```
2019-01-18 21:59:55,916 WARN org.apache.zookeeper.ClientCnxn: Client session timed out, have not heard from server in 7329ms for sessionid 0x2677edb3ac1f8d5
2019-01-18 21:59:55,916 INFO org.apache.zookeeper.ClientCnxn: Client session timed out, have not heard from server in 7329ms for sessionid 0x2677edb3ac1f8d5, closing socket connection and attempting reconnect
```
```
2019-01-18 21:59:56,075 INFO org.apache.zookeeper.ClientCnxn: Opening socket connection to server mfsmaster/121.9.240.249:2181. Will not attempt to authenticate using SASL (unknown error)
2019-01-18 21:59:56,075 INFO org.apache.zookeeper.ClientCnxn: Socket connection established to mfsmaster/121.9.240.249:2181, initiating session
2019-01-18 21:59:56,080 WARN org.apache.zookeeper.ClientCnxn: Unable to reconnect to ZooKeeper service, session 0x2677edb3ac1f8d5 has expired
2019-01-18 21:59:56,080 INFO org.I0Itec.zkclient.ZkClient: zookeeper state changed (Expired)
2019-01-18 21:59:56,080 INFO org.apache.zookeeper.ClientCnxn: Unable to reconnect to ZooKeeper service, session 0x2677edb3ac1f8d5 has expired, closing socket connection
2019-01-18 21:59:56,080 INFO org.apache.zookeeper.ZooKeeper: Initiating client connection, connectString=SR-CNSX-GDFS-240-251:2181,SR-CNSX-GDFS-240-252:2181,SR-CNSX-GDFS-240-253:2181,mfslogger:2181,mfsmaster:2181/kafka sessionTimeout=6000 watcher=org.I0Itec.zkclient.ZkClient@7957dc72
2019-01-18 21:59:56,080 INFO org.apache.zookeeper.ClientCnxn: EventThread shut down for session: 0x2677edb3ac1f8d5
```

```
2019-01-18 21:59:56,094 INFO org.I0Itec.zkclient.ZkClient: zookeeper state changed (SyncConnected)
2019-01-18 21:59:56,095 INFO kafka.server.KafkaHealthcheck$SessionExpireListener: re-registering broker info in ZK for broker 121
2019-01-18 21:59:56,095 INFO kafka.utils.ZKCheckedEphemeral: Creating /brokers/ids/121 (is it secure? false)
2019-01-18 21:59:56,112 INFO kafka.utils.ZKCheckedEphemeral: Result of znode creation is: OK
2019-01-18 21:59:56,113 INFO kafka.utils.ZkUtils: Registered broker 121 at path /brokers/ids/121 with addresses: EndPoint(SR-CNSX-GDFS-240-252,9092,ListenerName(PLAINTEXT),PLAINTEXT)
2019-01-18 21:59:56,113 INFO kafka.server.KafkaHealthcheck$SessionExpireListener: done re-registering broker
2019-01-18 21:59:56,113 INFO kafka.server.KafkaHealthcheck$SessionExpireListener: Subscribing to /brokers/topics path to watch for new topics
```



2.zk日志分析

同时分析zk日志信息：

```
2019-01-18 21:59:55,961 WARN org.apache.zookeeper.server.NIOServerCnxn: caught end of stream exception
EndOfStreamException: Unable to read additional data from client sessionid 0x2677edb3ac1f8d5, likely client has closed socket
        at org.apache.zookeeper.server.NIOServerCnxn.doIO(NIOServerCnxn.java:231)
        at org.apache.zookeeper.server.NIOServerCnxnFactory.run(NIOServerCnxnFactory.java:208)
        at java.lang.Thread.run(Thread.java:748)
2019-01-18 21:59:55,962 INFO org.apache.zookeeper.server.NIOServerCnxn: Closed socket connection for client /121.9.240.252:40660 which had sessionid 0x2677edb3ac1f8d5
2019-01-18 21:59:56,001 INFO org.apache.zookeeper.server.ZooKeeperServer: Expiring session 0x2677edb3ac1f8d5, timeout of 6000ms exceeded
2019-01-18 21:59:56,001 INFO org.apache.zookeeper.server.PrepRequestProcessor: Processed session termination for sessionid: 0x2677edb3ac1f8d5
```

综合zk和kafka日志信息，可以看出kafka和zk session超时之后，session会被zk主动关闭，之后kafka会重新连接到zk集群，基本是在1s之内kafka新的session已经建立，所以从短时间内kafka服务没问题。



3.gc日志分析

Gc 日志中基本没有Full GC



4.系统资源分析
- 晚上9~10业务晚高峰，数据量通常比较大
- CPU 内存正常
- IO在晚高峰时存在突刺



### 解决方案

1.kafka增大session time out 

当前默认值是6s，可适当加大超时时间

2.增加kafka磁盘

3.增加磁盘IO处理线程数