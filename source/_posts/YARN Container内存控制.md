---
title: YARN Container 内存控制策略
date: 2019-06-15 10:01:29
tags: 大数据
---

# YARN Container 内存控制

YARN 2.6 版本中对于Container内存控制策略比较单一，程序中有一个监控线程不停地检测各个Container的内存使用情况，只要物理内存或者虚拟内存在超过阈值之后，就会kill该container。有两个配置项与此相关，分别是`yarn.nodemanager.pmem-check-enabled`和`yarn.nodemanager.vmem-check-enabled`，在默认情况下，这两个配置项都为true。

YARN 3.2版本中提供更为精细的三种内存控制策略，主要分为三种：

1. 监控线程定时轮询各个container的内存占用情况，如果超过限制则kill container
2. 使用linux cgroup内核的OOM killer机制，严格控制container内存
3. 弹性内存控制策略，只有当整个系统内存超过限制后才会kill container

第1种内存控制策略比较好理解，就是开一个监控线程不停地监控container的使用情况，遇到阈值超过控制才会kill container，这种监控方式是在应用程序级别进行检测，有一定的延迟性。第2种和第3种内存控制策略使用了linux内核的OOM killer机制，当整个系统内存不足时，内核会选出score分数最高的进程，然后kill，区别在于，前者是严格控制，后者是弹性控制，严格控制指的是只要container内存超过阈值就Kill，后者是只要container的内存使用没有超过系统可使用的内存，则不会被kill。



弹性内存控制策略配置：

```xml
<property>
    <name>yarn.nodemanager.container-executor.class</name>
    <value>org.apache.hadoop.yarn.server.nodemanager.LinuxContainerExecutor</value>
</property>
<property>
    <name>yarn.nodemanager.resource.memory.enabled</name>
    <value>true</value>
</property>
<property>
    <name>yarn.nodemanager.runtime.linux.allowed-runtimes</name>
    <value>default</value>
</property>
<property>
    <name>yarn.nodemanager.vmem-check-enabled</name>
    <value>true</value>
</property>
<property>
    <name>yarn.nodemanager.pmem-check-enabled</name>
    <value>false</value>
</property>
<property>
    <name>yarn.nodemanager.vmem-pmem-ratio</name>
    <value>3.5</value>
</property>
<property>
    <name>yarn.nodemanager.resource.memory.enforced</name>
    <value>false</value>
</property>
<property>
    <name>yarn.nodemanager.elastic-memory-control.enabled</name>
    <value>true</value>
</property>

```

具体配置项参考：[官方文档](https://hadoop.apache.org/docs/current3/hadoop-yarn/hadoop-yarn-site/NodeManagerCGroupsMemory.html)
