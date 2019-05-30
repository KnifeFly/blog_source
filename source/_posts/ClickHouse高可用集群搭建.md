---
title: ClickHouse 高可用集群设计
date: 2019-05-28 19:19:29
tags: NoSQL
---

ClickHouse采用分片 + 副本实现高可用集群，下面以4台服务器为例子，讲述设计一个高可用的分布式集群需要注意的几个地方。

建立可横向扩展的数据服务集群，分片技术通常是必须的，MongoDB提供了原生的数据库分片技术，减小MySQL分库分表带来的麻烦。ClickHouse同样支持分片技术，假设4台机器，每台机器安装一个CH的示例，则表示有4个分片，每个分片的副本设置为1，对于这种集群设置不存在高可用可言，因为如果有一台机器挂了则整个ClickHouse集群不可用。

只有分片 + 副本才可实现高可用集群，可根据集群机器资源情况设置单分片副本数量，本次采用4台机器服务集群搭建，4个分片，每个分片两个副本。需要在每台机器上开启两个ClickHouse示例，注意不同示例需要设置不同的数据目录以及绑定不同的端口。

<!--more-->

## 集群配置

memetrika.xml配置

- internal_replication属性设置为true表示数据在插入到分布式表时，只插入到其中一个数据表，由后台进程同步到其余副本可保证数据一致性；设置为false则表示数据插入到各个数据表，这种方式有可能导致数据不一致，在采用Replicated表引擎时，官方推荐该属性设置为true。
- xcloud_cluster配置项表示集群名称，后续在闯将分布式表时需要制定该集群名称

```xml
<clickhouse_remote_servers>
    <xcloud_cluster>
        <!-- 数据分片1 -->
        <shard>
            <internal_replication>true</internal_replication>
            <replica>
                <host>103.252.235.33</host>
                <port>9000</port>
                <user>xcloud</user>
                <password>Xcloud2018#ZzVv</password>
            </replica>
            <replica>
                <host>103.252.235.34</host>
                <port>9001</port>
                <user>xcloud</user>
                <password>Xcloud2018#ZzVv</password>
            </replica>
        </shard>
        <!-- 数据分片2 -->
        <shard>
            <internal_replication>true</internal_replication>
            <replica>
                <host>103.252.235.34</host>
                <port>9000</port>
                <user>xcloud</user>
                <password>Xcloud2018#ZzVv</password>
            </replica>
            <replica>
                <host>103.252.235.33</host>
                <port>9001</port>
                <user>xcloud</user>
                <password>Xcloud2018#ZzVv</password>
            </replica>
        </shard>
        <!-- 数据分片3 -->
        <shard>
            <internal_replication>true</internal_replication>
            <replica>
                <host>103.252.235.35</host>
                <port>9000</port>
                <user>xcloud</user>
                <password>Xcloud2018#ZzVv</password>
            </replica>
            <replica>
                <host>103.252.235.36</host>
                <port>9001</port>
                <user>xcloud</user>
                <password>Xcloud2018#ZzVv</password>
            </replica>
        </shard>
        <!-- 数据分片4 -->
        <shard>
            <internal_replication>true</internal_replication>
            <replica>
                <host>103.252.235.36</host>
                <port>9000</port>
                <user>xcloud</user>
                <password>Xcloud2018#ZzVv</password>
            </replica>
            <replica>
                <host>103.252.235.35</host>
                <port>9001</port>
                <user>xcloud</user>
                <password>Xcloud2018#ZzVv</password>
            </replica>
        </shard>
    </xcloud_cluster>
</clickhouse_remote_servers>

<zookeeper-servers>
  <node index="1">
    <host>103.252.235.33</host>
    <port>2181</port>
  </node>
  <node index="2">
    <host>103.252.235.34</host>
    <port>2181</port>
  </node>
  <node index="3">
    <host>103.252.235.35</host>
    <port>2181</port>
  </node>
  <node index="4">
    <host>103.252.235.36</host>
    <port>2181</port>
  </node>
</zookeeper-servers>
```



```sql
clickhouse :) select * from system.clusters;

SELECT *
FROM system.clusters

┌─cluster─────────────────────┬─shard_num─┬─shard_weight─┬─replica_num─┬─host_name──────┬─host_address───┬─port─┬─is_local─┬─user────┬─default_database─┐
│ test_shard_localhost        │         1 │            1 │           1 │ localhost      │ ::1            │ 9000 │        1 │ default │                  │
│ test_shard_localhost_secure │         1 │            1 │           1 │ localhost      │ ::1            │ 9440 │        0 │ default │                  │
│ xcloud_cluster              │         1 │            1 │           1 │ 103.252.235.33 │ 103.252.235.33 │ 9000 │        0 │ xcloud  │                  │
│ xcloud_cluster              │         1 │            1 │           2 │ 103.252.235.34 │ 103.252.235.34 │ 9001 │        0 │ xcloud  │                  │
│ xcloud_cluster              │         2 │            1 │           1 │ 103.252.235.34 │ 103.252.235.34 │ 9000 │        1 │ xcloud  │                  │
│ xcloud_cluster              │         2 │            1 │           2 │ 103.252.235.33 │ 103.252.235.33 │ 9001 │        1 │ xcloud  │                  │
│ xcloud_cluster              │         3 │            1 │           1 │ 103.252.235.35 │ 103.252.235.35 │ 9000 │        0 │ xcloud  │                  │
│ xcloud_cluster              │         3 │            1 │           2 │ 103.252.235.36 │ 103.252.235.36 │ 9001 │        0 │ xcloud  │                  │
│ xcloud_cluster              │         4 │            1 │           1 │ 103.252.235.36 │ 103.252.235.36 │ 9000 │        0 │ xcloud  │                  │
│ xcloud_cluster              │         4 │            1 │           2 │ 103.252.235.35 │ 103.252.235.35 │ 9001 │        0 │ xcloud  │                  │
└─────────────────────────────┴───────────┴──────────────┴─────────────┴────────────────┴────────────────┴──────┴──────────┴─────────┴──────────────────┘
```



## 创建分布式表

```sql
CREATE TABLE xcloud.cdn_nginx_log_minute_agg
(
	date Date, 

  timeStamp DateTime,

	channel String, 

	customer String, 

	province String, 

	flow AggregateFunction(sum, Int64), 

	visit AggregateFunction(sum, Int64),  

	download_time AggregateFunction(sum, Int64), 

	response_time AggregateFunction(sum, Int64), 

	upstream_response_time AggregateFunction(sum, Int64), 

	first_byte_time AggregateFunction(sum, Int64), 

	request_time AggregateFunction(sum, Int64), 

	download_flow AggregateFunction(sum, Int64), 

	response_normal AggregateFunction(sum, Int64)
)  
ENGINE = ReplicatedAggregatingMergeTree('{zkpath}', '{replica}')  
PARTITION BY date  ORDER BY (timeStamp, date, channel, customer, province);
```

 

创建完后可在zk上看到表的一些副本信息：

```shell
[zk: localhost:2181(CONNECTED) 5] ls /clickhouse/xcloud/cdn_nginx_log_area_fivemin_shard_

cdn_nginx_log_area_fivemin_shard_4   cdn_nginx_log_area_fivemin_shard_3   cdn_nginx_log_area_fivemin_shard_2
cdn_nginx_log_area_fivemin_shard_1
```

```shell
ls /clickhouse/xcloud/cdn_nginx_log_area_fivemin_shard_1/replicas
[SR-CNSX-TJ-36-90, SR-CNSX-TJ-36-91-wingman]
```

