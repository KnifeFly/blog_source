---
title: Kafka 集群扩容
date: 2018-05-20 15:11:39
tags: Kafka
---



# Kafka 集群扩容

kafka 集群在新增机器后是不会把历史已经创建的topic数据信息迁移到新加入集群的机器，只有新创建的topic才会分布到新机器。若想把历史topic数据均匀分布到加入机器后的新集群，需要人为操作，好在kafka提供了相应的工具可简单地完成数据迁移工作。

迁移数据的过程是手动启动的，但是执行过程是完全自动化的。在kafka后台内部中，kafka将添加新的服务器，并作为正在迁移分区的follower，来完全复制该分区现有的数据。当新服务器完全复制该分区的内容并加入同步副本，成为现有副本之一后，就将现有的副本分区上的数据删除。

分区重新分配工具可以用于跨broker迁移分区，理想的分区分配将确保所有的broker数据负载和分区大小。分区分配工具没有自动研究kafka集群的数据分布和迁移分区达到负载分布的能力，因此，管理员要弄清楚哪些topic或分区应该迁移。



## 数据清理

在数据迁移的过程中涉及大量的数据复制，对于数据存储量大的topic，如果历史数据不是必须的，可以适当地删除数据，针对某些topic设置retetion时间，操作成功后无需重启kafka，命令如下：

```shell
./kafka-configs.sh --zookeeper zookeeper:2181/kafka --entity-type topics --entity-name input_kafka_nginxLog_topic --alter --add-config retention.ms=86400000 
```



## 数据分区

分区分配工具的3种模式:

- --**generate**: 这个选项命令，是生成分配规则json文件的，生成“候选人”重新分配到指定的topic的所有parition都移动到新的broker。此选项，仅提供了一个方便的方式来生成特定的topic和目标broker列表的分区重新分配 “计划”。该命令选项会在shell终端输出JSON格式的重新分区后的数据。在使用该选项时，broker选择需要注意加上新机器ID
  
- --**execute**: 这个选项命令，是执行你用--generate 生成的分配规则json文件的，（用--reassignment-json-file 选项），可以是自定义的分配计划，也可以是由管理员或通过--generate选项生成的。
  
- --**verify**: 这个选项命令，是验证执行--execute重新分配后，列出所有分区的状态，状态可以是成功完成，失败或正在进行中的。
   	

### generate

1. 确认需要重新分区的topic名称，并以JSON格式写到文件中，示例：

```JSON
{
  "topics": [{"topic": "input_kafka_nginxLog_topic"}],
  "version": 1
}
```



2. 生成新的分区列表配置， 示例：

```shell
kafka-reassign-partitions --zookeeper zookeeper:2181/kafka/kafka --topics-to-move-json-file ./topic.json --broker-list 117,118,119,120,121 --generate
```

该命令会在shell界面上以JSON格式输出重新分区后的配置，需要手动保存topic_reassgin.json文件中，后续execute会用到



### execute

该命令执行重新分区操作，根据重新分区配置，会更改历史数据，异步操作。该操作存在大量磁盘和网络IO，如果kafka队列中该topic存在大量的数据，执行时间很长

```shell
kafka-reassign-partitions --zookeeper zookeeper:2181/kafka --reassignment-json-file ~/after.json --execute
```



### verify

该命令可以确认第二部操作是否操作完成，如果所有分区数据都为done则表示重分区成功

```shell
)kafka-reassign-partitions --zookeeper zookeeper:2181/kafka --reassignment-json-file ~/after.json --verify
```

