---
title: Spark On YARN 资源配置
date: 2018-07-12 19:54:10
tags: 大数据
---

# Spark On YARN 资源配置

## YARN 调度模型

CDH YARN 界面中可以选择调度模型，有三种调度模型可供选择，分别是：Capacity Scheduler、FIFO Scheduler、Fair Scheduler，CDH YARN界面中Scheduler类配置项可以选择：

- org.apache.hadoop.yarn.server.resourcemanager.scheduler.capacity.CapacityScheduler

- org.apache.hadoop.yarn.server.resourcemanager.scheduler.fifo.FifoScheduler

- org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.FairScheduler



FIFO Scheduler:

任务调度先进先出，很好理解，且该调度模式不需要配置，不过它并不适用于共享集群。大的应用可能会占用所有集群资源，小任务有可能会一致阻塞。在共享集群中，更适合采用`Capacity Scheduler`或`Fair Scheduler`，这两个调度器都允许大任务和小任务在提交的同时获得一定的系统资源



Capacity Scheduler

有一个专门的队列用来运行小任务，但是为小任务专门设置一个队列会预先占用一定的集群资源，这就导致大任务的执行时间会落后于使用FIFO调度器时的时间。



Fair Scheduler

在Fair调度器中，不需要预先占用一定的系统资源，Fair调度器会为所有运行的job动态的调整系统资源。需要注意的是，小任务执行完成之后也会释放自己占用的资源，大任务又获得了全部的系统资源。最终的效果就是Fair调度器即得到了高的资源利用率又能保证小任务及时完成。



Spark on YARN跑的任务按照日志业务可划分为访问日志计算任务和流量日志计算任务，希望这两种任务资源尽量能隔离，两者之间不要资源抢占。在默认情况下spark运行在YARN上的所有Application公用一个Queue，Queue采用的调度模型是公平调度模型，这种情况下访问日志业务量突增之后会影响流量日志计算任务。为此设置两个队列，分布运行访问日志计算和流量日志计算。YARN总调度模型采用Fair调度模型，两个队列内部也采用Fair调度模型。



## Capacity Scheduler

Capacity 调度器允许多个组织共享整个集群，每个组织可以获得集群的一部分计算能力。通过为每个组织分配专门的队列，然后再为每个队列分配一定的集群资源，这样整个集群就可以通过设置多个队列的方式给多个组织提供服务了。除此之外，队列内部又可以垂直划分，这样一个组织内部的多个成员就可以共享这个队列资源了，在一个队列内部，资源的调度是采用的是先进先出(FIFO)策略。

在正常的操作中，Capacity调度器不会强制释放Container，当一个队列资源不够用时，这个队列只能获得其它队列释放后的Container资源。当然，我们可以为队列设置一个最大资源使用量，以免这个队列过多的占用空闲资源，导致其它队列无法使用这些空闲资源，这就是”弹性队列”需要权衡的地方。

主要的特点：

- 分级队列--支持队列分级，以确保在允许其他队列使用空闲资源之前，资源在组织的子队列之间共享，从而提供更多的控制和可预测性。
- 容量保证--队列被分配了网格容量的一小部分，即一定容量的资源将由它们支配。提交给队列的所有应用程序都可以访问分配给队列的容量。管理员可以对分配给每个队列的容量配置软限制和可选硬限制。
- 安全性--每个队列都有严格的ACl，控制哪些用户可以向单个队列提交应用程序。此外，还有安全防护措施来确保用户不能查看和/或修改来自其他用户的应用程序。此外，还支持按队列和系统管理员角色。
- 弹性--资源可以分配给超出其容量的任何队列。当未来某个时间点运行在容量不足的队列需要这些资源时，随着这些资源上计划的任务完成，它们将被分配给运行在容量不足的队列上的应用程序(也支持抢占)。这可以确保队列可以以可预测和灵活的方式获得资源，从而防止集群中人为的资源孤岛，这有助于利用率。
- 多租户--提供了一组全面的限制，以防止单个应用程序、用户和队列独占队列或整个集群的资源，从而确保集群不会不堪重负。
- 基于资源的调度--支持资源密集型应用程序，其中应用程序可以选择性地指定比默认更高的资源需求，从而适应具有不同资源需求的应用程序。目前，内存是支持的资源需求。



配置示例：

```xml
<property>
  <name>yarn.scheduler.capacity.root.queues</name>
  <value>a,b,c</value>
  <description>The queues at the this level (root is the root queue).
  </description>
</property>

<property>
  <name>yarn.scheduler.capacity.root.a.queues</name>
  <value>a1,a2</value>
  <description>The queues at the this level (root is the root queue).
  </description>
</property>

<property>
  <name>yarn.scheduler.capacity.root.b.queues</name>
  <value>b1,b2,b3</value>
  <description>The queues at the this level (root is the root queue).
  </description>
</property>
```



## Fair Scheduler 

公平调度是一种将资源分配给应用程序的方法，这样所有应用程序在一段时间内平均获得相同的资源份额。Hadoop NextGen能够调度多种资源类型。默认情况下，公平调度器仅基于内存来调度公平决策。它可以被配置为使用内存和CPU进行调度，使用Ghodsi等人开发的优势资源公平概念。当有一个应用程序运行时，该应用程序使用整个集群。提交其他应用程序时，释放的资源会分配给新应用程序，这样每个应用程序最终获得的资源量大致相同。与默认的Hadoop调度器不同，Hadoop调度器形成了一个应用队列，它允许短应用在合理的时间内完成，而不会耗尽长寿命应用。这也是一种在多个用户之间共享集群的合理方式。最后，公平共享也可以与应用程序优先级一起工作——优先级被用作权重来确定每个应用程序应该获得的总资源的比例。

调度程序将应用程序进一步组织成“队列”，并在这些队列之间公平地共享资源。默认情况下，所有用户共享一个名为“default”的队列。如果某个应用程序在容器资源请求中特别列出了一个队列，该请求将被提交到该队列。也可以通过配置根据请求中包含的用户名分配队列。在每个队列中，调度策略用于在运行的应用程序之间共享资源。默认为基于内存的公平共享，但也可以配置先进先出和具有优势资源公平的多资源。队列可以按层次排列以划分资源，并配置权重以按特定比例共享集群。

除了提供公平共享之外，公平调度器还允许为队列分配有保证的最小共享，这对于确保某些用户、组或生产应用程序始终获得足够的资源非常有用。当一个队列包含应用程序时，它至少会得到它的最小份额，但是当队列不需要它的全部保证份额时，多余的份额会在其他正在运行的应用程序之间分配。这使得调度器能够保证队列的容量，同时在这些队列不包含应用程序时高效地利用资源。

默认情况下，公平调度程序允许所有应用程序运行，但也可以通过配置文件限制每个用户和每个队列运行的应用程序数量。当用户必须一次提交数百个应用程序时，这可能很有用，如果一次运行太多应用程序会导致创建太多中间数据或太多上下文切换，这通常会提高性能。限制应用程序不会导致任何后续提交的应用程序失败，只会在调度程序的队列中等待，直到用户的一些早期应用程序完成。

CDH YARN界面中可以为Fair Scheduler、Capacity Scheduler这两种调度模型分别设置配置，在界面中配置项分别是 **容量调度程序配置高级配置代码段（安全阀)**和 **Fair Scheduler XML 高级配置代码段（安全阀）**, 可选择XML视图。



公平调度XML配置：

```xml
<?xml version="1.0" encoding="utf-8"?>

<allocations> 
  <defaultQueueSchedulingPolicy>fair</defaultQueueSchedulingPolicy>

  <queue name="logAnalysis"> 
    <weight>60</weight> 
    <minResources>80000 mb, 30 vcores</minResources>  
    <maxResources>100000 mb, 70 vcores</maxResources>  
    <maxRunningApps>10</maxRunningApps>  
    <minSharePreemptionTimeout>100</minSharePreemptionTimeout>  
    <aclSubmitApps></aclSubmitApps>  
    <aclAdministerApps></aclAdministerApps>  
  </queue>  

  <queue name="flowAnalysis"> 
    <weight>40</weight> 
    <minResources>10000 mb, 10 vcores</minResources>  
    <maxResources>40000 mb, 30 vcores</maxResources>  
    <maxRunningApps>10</maxRunningApps>  
    <minSharePreemptionTimeout>100</minSharePreemptionTimeout>  
    <aclSubmitApps></aclSubmitApps>  
    <aclAdministerApps></aclAdministerApps> 
  </queue> 

  <user name="root"> 
    <maxRunningApps>10</maxRunningApps> 
  </user>  

  <userMaxAppsDefault>50</userMaxAppsDefault>  
  <fairSharePreemptionTimeout>200</fairSharePreemptionTimeout> 
</allocations>

```

- 设置两个队列，分别是logAnalysis和flowAnalysis，Spark在submit application时需要制定该任务在哪个队列中执行，不然默认情况下会运行在default队列中。Spark制定队列配置项为spark.yarn.queue

- logAnalysis队列和flowAnalysis队列资源权重为6 : 4
- <minResources>和<maxResources>分布配置项设置队列占用最小资源和最大资源，包含CPU核数和内存大小，这两个配置项需要根据Spark执行时设置的executor来设置
- <defaultQueueSchedulingPolicy>配置项设置了调度模型为Fair
- <maxRunningApps> 设置队列可同时执行的Application数量



### 资源抢占

YARN的yarn.scheduler.fair.preemption配置是否**启用 Fair Scheduler 抢占**，如果开启了资源抢占：

- 在资源调度器中，每个队列可设置一个最小资源量和最大资源量，其中，最小资源量是资源紧缺情况下每个队列需保证的资源量，而最大资源量则是极端情况下队列也不能超过的资源使用量
- 开启资源抢占后当某个队列资源不足时，调度器会杀死其他队列的container以释放资源，分给这个队列
- 每个队列都有minShare、fairShare属性。这两个属性是抢占式调度的阈值。当一个队列使用的资源小于fairShare*X（defaultFairSharePreemptionThreshold）、或者小于minShare，并且持续超过一定时间（这两种情况的超时时间不同，可以设置），就会开始抢占式调度
- 具体YARN抢占的算法参考官方文档



## 任务提交

Spark在submit任务时可以用spark.yarn.queue配置项制定把该任务提交到哪个YARN资源队列