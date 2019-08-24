---
title: ClickHouse 运营总结
date: 2019-08-24 11:37:28
tags: ClickHouse
---

# ClickHouse 运营总结

## 概述
ClickHouse 是俄罗斯 Yandex 公司所开源的一款用于大数据实时分析的列式数据库管理系统，采用 C++ 编写，对于百亿级数据的查询聚合能达到秒级返回。

ClickHouse 的主要优点有：
1. 为了高效的使用CPU，数据不仅仅按列存储，同时还按向量进行处理；
2. 数据压缩空间大，减少io；处理单查询高吞吐量每台服务器每秒最多数十亿行；
3. 索引非B树结构，不需要满足最左原则；只要过滤条件在索引列中包含即可；即使在使用的数据不在索引中，由于各种并行处理机制ClickHouse全表扫描的速度也很快；
4. 写入速度非常快，50-200M/s，对于大量的数据更新非常适用。

而为了达到“快”的效果，ClickHouse 付出了如下的代价：
1. 不支持事务，不支持真正的删除/更新；
2. 不支持高并发，官方建议 QPS 为100，可以通过修改配置文件增加连接数，但是在服务器足够好的情况下；
3. SQL 满足日常使用80%以上的语法，join 写法比较特殊；最新版已支持类似 SQL 的 join，但性能不好；
4. 尽量做1000条以上批量的写入，避免逐行 insert 或小批量的 insert，update，delete 操作，因为 ClickHouse 底层会不断的做异步的数据合并，会影响查询性能，这个在做实时数据写入的时候要尽量避开；
5. ClickHouse 快是因为采用了并行处理机制，即使一个查询，也会用服务器一半的cpu去执行，所以 ClickHouse 不能支持高并发的使用场景，默认单查询使用cpu核数为服务器核数的一半，安装时会自动识别服务器核数，可以通过配置文件修改该参数。

<!-- more -->

## 集群部署

目前 ClickHouse 集群在线上机器使用的是手动部署方式，后续可考虑改用 Puppet 进行自动化部署，以适应大规模安装需求。集群部署的关键点在于配置文件，尤其是 `metrika.xml` 文件（一般位于 /etc/clickhouse-server/metrika.xml）

### 软件安装

起初，ClickHouse 官方只提供 deb 包，随着使用者的日益增多，自 2018 年起官方已提供了 [yum](http://repo.yandex.ru/clickhouse/rpm/stable/x86_64/) 源。因此，我们在加入 yum repo 后(目前内部 yum 源 XCloud 已包含 clickhouse 相关 rpm 包)，可直接使用以下命令安装 clickhouse-server 和 clickhouse-client。

```bash
yum install clickhouse-server clickhouse-client
```

> PS. ClickHouse 版本更新速度极快，每次发布会经常会引入一堆新功能，以及新的Bug。。。 ㄟ( ▔, ▔ )ㄏ 因此，不要盲目追新，想升级一个大版本之前，需在内网及备集群中至少观察两周，回归测试线上用到的功能。目前，线上使用的是2018年的最后一个稳定版本 `v18.6.1` 

目前，我们线上的每个集群包含四台机器。为了充分利用四台机器的算力，并最大程度上保障数据的冗余度，我们采用了4机器8实例的部署方式，即每台机器开两个 clickhouse-server 进程，每张数据表分4个分片(shard)，每个分片有额外一个副本(replica)，即数据冗余度为2。之所以采用单机双实例而非三实例，是因为 ClickHouse 在进行查询时对 CPU 和内存都会有较大的消耗，过多的实例反而会相互抢占资源。

![](media/15470094472107/15661851386817.jpg)

在机器资源充足的情况下，首选三副本部署方式，这种交叉式互备的好处在于，在一台机器宕机的情况下，集群能够正常对外提供服务；在两台机器宕机的情况下，集群有50%的概率能够正常对外提供服务，另外50%的概率查询结果会损失50%的数据。例如，在A和C同时宕机的情况下，由于B和D拥有四个分片的一个副本，因此无论向B或D查询，都能获得完整的数据集；而在A和B同时宕机时，由于C和D只拥有分片3和分片4的副本，因此查询时将丢失分片1和分片2的数据。

另外一种部署方式如下：

![](media/15470094472107/15661851120200.jpg)

该方式也能容忍一台机器宕机，但一旦有两台或以上宕机，查询所得的数据结果将一定会有损。因此我们**没有**采用这种部署方式。

对于单机双实例方式的部署，我们在使用 yum 安装 ClickHouse 后，需要做一些额外的设置动作，以下流程以线上生产环境为例，所涉及的配置内容范本可在[这里](https://gitlab.onewocloud.net/logflow/clickhouse-helper/tree/master/docs/example-configs/)查看。

```bash
# 新建作为第二实例的 ClickHouse Server 启动脚本，我们称之为 Wingman(僚机)
vi /etc/init.d/clickhouse-server-wingman
# 粘贴 clickhouse-server init.d 脚本内容，见附件
chmod +x /etc/init.d/clickhouse-server-wingman

# 线上环境中，我们以 /cache2 作为 ClickHouse Server 主实例数据存放盘，以 /cache1 作为 ClickHouse Server Wingman 实例数据存放盘，注意这两个盘都是 SSD。此外，为了统一配置，我们将数据盘上的目录建立软链接至根目录下
/usr/bin/mkdir /cache2/clickhouse;
chown clickhouse:clickhouse /cache2/clickhouse
ln -s /cache2/clickhouse /clickhouse;

/usr/bin/mkdir /cache1/clickhouse-wingman;
chown clickhouse:clickhouse /cache1/clickhouse-wingman;
ln -s /cache1/clickhouse-wingman /clickhouse-wingman;

# 根据附件配置样例，分别编辑 /etc/clickhouse-server 下的三个配置文件
vi /etc/clickhouse-server/config.xml
vi /etc/clickhouse-server/users.xml
vi /etc/clickhouse-server/metrika.xml

# 拷贝一份作为 ClickHouse Server Wingman 的配置
cp -a /etc/clickhouse-server/ /etc/clickhouse-server-wingman
# 编辑 wingman 的 config.xml 和 metrika.xml，配置与主实例相区别的主机名

# 手动命令行启动 ClickHouse Server 主实例，让它自动生成相关数据文件
clickhouse-server  --pid-file=/var/run/clickhouse-server/clickhouse-server.pid --config-file=/etc/clickhouse-server/config.xml
# 成功启动后，Control-C 结束进程
# 更改目录下数据文件拥有者，很重要！
chown -R clickhouse:clickhouse /clickhouse/

# 手动命令行启动 ClickHouse Server Wingman 实例，让它自动生成相关数据文件
clickhouse-server  --pid-file=/var/run/clickhouse-server-wingman/clickhouse-server-wingman.pid --config-file=/etc/clickhouse-server-wingman/config.xml
# 成功启动后，Control-C 结束进程
# 更改目录下数据文件拥有者，很重要！
chown -R clickhouse:clickhouse /clickhouse-wingman/

# 一切无误后，可先后启动两个实例的后台服务进行观察
service clickhouse-server start
service clickhouse-server-wingman start

# 启动后，server 会绑定若干个端口，可能需要等待几分钟，可以使用如下命令查看
# 以目前的配置，两个实例分别占用了三个端口，总共有：9000, 9001, 9009, 9019, 8823, 8833
netstat -nltp|grep clickhouse

# 另可使用客户端命令分别登录两个实例查看
clickhouse-client --host=${HOST}  --port ${PORT} -d ${DATABASE} -u ${USER} --password ${PASSWORD} -m
```

待服务稳定运行后，软件安装部分完成。

### 数据表初始化

ClickHouse 建表操作大体与 MySQL 类似，均可通过客户端执行 SQL 语句完成。有所区别的地方在于，一旦需要在集群中使用 `Replicated*MergeTree`，则在建表语句中需包含与分片相关的 Zookeeper 路径，这个路径对于不同表、不同分片的实例来说是唯一的。

自动化的集群化建表，可使用 [clickhouse-helper](https://gitlab.onewocloud.net/logflow/clickhouse-helper) 工具，配合 [chutil.py](https://gitlab.onewocloud.net/logflow/clickhouse-helper/blob/master/scripts/chutil.py) 脚本，实现批量表操作。

## 数据流

ClickHouse 支持丰富的数据输入接口，主要的数据流入模式分为如下几类：

| 输入模式 | 接口 |
| --- | --- |
| 推 | TCP |
|  | HTTP |
| 拉 | Kafka Engine |
|  | MySQL Engine |

在我们的生产环境中，主要使用的是 TCP + HTTP 接口。日志处理的流程中，我们的数据经由 Spark 进行处理后，进入 Kafka 消息队列，而后被 [Logkit](https://gitlab.onewocloud.net/logflow/logkit) 组件消费，发送至 ClickHouse。在这个过程中，Logkit 将 Kafka Topic 中的数据以一定的时间周期，先保存至本地文件（默认放置于 /var/log/logkit_ck/ 目录下），再调用 clickhouse-client 的文件处理模式，批量导入至 ClickHouse Server 中。clickhouse-client 使用的是 TCP 接口导入，并且这种通过文件导入的方式，规避了一条条插入数据的操作，提升了插入效率。

这里的 Logkit 版本相比 github 上的原生版本，新增了 ClickHouse sender 模块，由于其依赖了 ClickHouse Client，使用上具有特殊性，因此我们没将这部分源码申请合并到开源主干中。注意新版本开发及打包时，需要基于 Gitlab 中的 [ClickHouse 相关分支](https://gitlab.onewocloud.net/logflow/logkit/tree/clickhouse-1.5.3)。 

鉴于目前线上的问题经常出在 Spark 任务不稳定，经常导致高延迟或者任务挂掉，后续可考虑使用上述`拉`模式下的 `Kafka Engine` 来直接消费原始日志数据，并利用 [`Materialized View`](https://clickhouse.yandex/docs/en/operations/table_engines/materializedview/) 来实现数据计算流程，以期缩短数据链路，减少维护的组件，提升计算稳定性。

## 数据备份与同步

我们利用自己开发的 [clickhouse-helper](https://gitlab.onewocloud.net/logflow/clickhouse-helper/blob/master/main.go) 工具来实现集群间的数据同步以及定期的备份。使用方式详见工具调用说明。

另外，由于 ClickHouse 集群目前高度依赖于 Zookeeper，因此，有必要经常性地对 Zookeeper 的 ClickHouse 数据进行导出备份。

## 监控

大致的思路是利用 [clickhouse_exporter](https://gitlab.onewocloud.net/logflow/clickhouse-exporter) 导出 ClickHouse Server 的性能数据，通过 Prometheus 进行汇集，然后在 Grafana 上进行展示，并设置相关的告警。

线上集群机器中，该工具位于 `/usr/local/bin/clickhouse_exporter` 路径下，我们需能够访问本地的 ClickHouse HTTP 端口以获取实例的数据，在每个实例下运行命令如下
```bash
nohup /usr/local/bin/clickhouse_exporter -scrape_uri=http://127.0.0.1:8823/ > /var/log/clickhouse_exporter.log 2>&1 &
```

ClickHouse Exporter 默认通过 `9116` 端口对外提供 metrics，我们可通过 Prometheus 订阅该 metrics，对 ClickHouse Server 进行监控。

## 负载均衡

对于来自于 HTTP 的请求，我们可以在 ClickHouse 集群前面加一个 [`CHProxy`](https://github.com/Vertamedia/chproxy) 中间件，既可为集群进行负载均衡，又可实现集群实例的高可用，我们为 CHProxy 源码增加了 RPM 打包，详见该 [Repo](https://gitlab.onewocloud.net/logflow/chproxy-rpm)。

CHProxy 可以在设置中新建对外的分账号，指定该账号的读写权限以及连接并发数，并将其映射到数据库的真实账号中。通过这种机制，我们无需对 ClickHouse 集群本身进行任何配置修改，同时也隐藏了真实的账号，不必担心相关泄露的危险。CHProxy 还有很多值得探究的特性，详情可见其功能列表。

目前 CHProxy 暂不支持对于 TCP 连接方式的负载均衡，因此该中间件的服务场景仅限于 HTTP 的连接，在生产环境中，主要由 `Grafana`，`Redash`，`Superset`，`ClickHouse JDBC` 等组件进行使用。**对外（外部系统）暴露的数据库查询服务，最好都通过 CHProxy 账号的方式提供，可以此限制其并发查询数，避免集群被这些系统的查询所拖垮。**

## 优化

### 操作系统设置

ClickHouse 对服务器 CPU 和 IO 的要求都很高，因此有必要对操作系统进行相应的设置，以最大限度提升 ClickHouse 对服务器资源的利用率。Yandex 官方提供了[这方面的设置参考](https://clickhouse.yandex/docs/en/operations/tips/)，目前生产环境的服务器大体参照这份文档进行服务器配置修改。

### ClickHouse 设置

#### 磁盘

将数据存放于**固态硬盘**相较于机械硬盘对 ClickHouse 的查询性能提升十分明显。但由于固盘容量相对较小，因此有条件的情况下，可以采用 Raid10 对磁盘进行扩容。

此外，由于 ClickHouse 未支持对多磁盘的利用，对于一些冷数据，我们可以将其放到机械硬盘中，再通过软链接的方式链接到 /clickhouse/data/ 目录下。

### 数据导入方式

ClickHouse 的数据表在我们的生产环境中一般是以本地表配合分布式表的方式进行使用，其中本地表是每个实例真正用于存放数据的地方；分布式表类似于一个视图，用以聚合各个实例中本地表的数据，它并不会真正存放数据。 对于集群内数据的读操作，基本都是通过分布式表进行查询；但对于写操作，就存在两种不同的方式，其优劣如下表所示。

| 表类型 | 优势 | 劣势 |
| --- | --- | --- |
| 分布式表 | 利用分布式表的数据均摊机制，将插入数据均匀分配到各个分片中 | 数据均摊过程中将产生集群内部的数据流动，消耗一定的集群 IO，可能对正在执行的查询语句产生性能上的影响，同时会对 Zookeeper 的稳定性造成影响 |
| 本地表 | 每次插入后，数据将直接被保存在插入实例所对应的数据分片中，这部分数据只会同步到对应的副本分片实例上，而不会扩散到整个集群内 | 需要手动控制数据的均摊，否则将造成一个数据表内各个分片的数据量不均匀 |

经过生产环境的实践，对于大数据量的导入，我们现在基本采用写入本地表的方式进行。Zookeeper 是分布式表插入的主要瓶颈所在，我们遇到过 Zookeeper 在大量数据插入分布式表过程中，负载飙高使集群瘫痪的情况。

## 高级用法

### 字典数据导入
在 OLAP 的很多场景中，我们需要关联查询来自外部系统的一些数据类配置文件，如服务器-机房-View映射列表等，这些数据不宜直接存放在 ClickHouse 的表中，因为它们会经常被变动更新。但如果无法直接在 SQL 语句中查询这些数据，我们就要针对这些场景单独写程序去关联 ClickHouse 的数据与配置文件数据，过程变得极为繁琐。ClickHouse 提供了 [Dictionary](https://clickhouse.yandex/docs/en/operations/table_engines/dictionary/) 引擎，让我们可以在 ClickHouse 集群中加载这些数据，同时在适当的时候更新之。

生产环境中，我们在 ClickHouse 集群中加载来自 OSS 的配置文件，这些配置文件多为行列式，我们需要对它进行适当的列变换，将一些需要用到的查询列提前作为主键，转换为需要的文件视图，再通过 ClickHouse 去加载它。需要注意的是，这些操作需要在每个 ClickHouse 服务器上部署，同时考虑到文件的更新时效性，需要用 crontab 定期去执行该操作。因此后续可将这类操作放在 Puppet 上进行管理。

具体用法如下，任意一台 ClickHouse 服务器上，我们新增了 `/etc/cron.d/clickhouse-dict.cron` 文件，其内容如下：

```
1 * * * * root sed -e '$ d' /xcloud-log/conf/machineID.info|awk '{score=$NF; $NF="";print score,$0}'|awk '{$1=$1;print}'|sed -e 's/ /,/g' > /xcloud-log/clickhouse/machineID.csv 2>&1
2 * * * * root sed -e 's/\s\+/,/g' /xcloud-log/conf/domainMap.conf > /xcloud-log/clickhouse/domainMap.csv 2>&1
3 * * * * root /usr/bin/sed -e 's/ /,/g' /xcloud-log/conf/channel.info > /xcloud-log/clickhouse/customerMap.csv 2>&1
```

以上述的第一个操作为例，它定时将 `/xcloud-log/conf/machineID.info` 文件变换后放置于 `/xcloud-log/clickhouse/machineID.csv`。同时，我们在 `/etc/clickhouse-server/oss_meta_dictionary.xml` 文件中定义如下：

```xml
<dictionaries>
    <dictionary>
        <name>ext_meta_machineInfo</name>
        <source>
            <file>
                <path>/xcloud-log/clickhouse/machineID.csv</path>
                <format>CSV</format>
            </file>
        </source>
        <layout>
            <complex_key_hashed />
        </layout>
        <structure>
            <key>
                <attribute>
                    <name>serviceGroupId</name>
                    <type>String</type>
                </attribute>
            </key>
            <attribute>
                <name>deviceID</name>
                <type>String</type>
                <null_value></null_value>
            </attribute>
            <attribute>
                <name>serverGroup</name>
                <type>String</type>
                <null_value></null_value>
            </attribute>
            <attribute>
                <name>idc</name>
                <type>String</type>
                <null_value></null_value>
            </attribute>
            <attribute>
                <name>appType</name>
                <type>String</type>
                <null_value></null_value>
            </attribute>
            <attribute>
                <name>isp</name>
                <type>String</type>
                <null_value></null_value>
            </attribute>
            <attribute>
                <name>serverType</name>
                <type>String</type>
                <null_value></null_value>
            </attribute>
            <attribute>
                <name>area</name>
                <type>String</type>
                <null_value></null_value>
            </attribute>
            <attribute>
                <name>ip</name>
                <type>String</type>
                <null_value></null_value>
            </attribute>
        </structure>
        <lifetime>
            <min>120</min>
            <max>1000</max>
        </lifetime>
    </dictionary>
</dictionaries>
```

向 ClickHouse 声明了这个文件的结构以及其相关的键值，待 ClickHouse 加载了该文件后，我们就可以 `serviceGroupId` 为主键查询到其他的键值信息，从而在一个 SQL 中实现所有数据的关联查询。

### 流式计算
ClickHouse 通过 Materialized View (MV) 实现了类似流式计算的功能，即我们以某个原始表为数据源 T1，在这个表上建立一个 MV1，定义原始表中某些字段的聚合操作，并将结果插入至下一个层级的表 T2 中，这时每当有新增数据进入 T1，这些数据就会持续地被 MV1 定义的计算逻辑所聚合，然后流入到 T2，从而形成完整的流式计算链。

在生产环境，这个方式被用于业务告警的方案中，具体见[该文章](http://tech.onewocloud.net/?p=1908)。**值得注意的是，使用 MV 是存在风险的，一旦 MV 的计算失败了，那数据插入到数据源中也会失败。因此，建立一个 MV 需要经过严格的测试。**

## 一些坑

- 新增字段，`v18.6.1` 及以上版本支持对数据表新增字段，但实践过程中，对于新增主键或排序字段都导致过数据表冲突的问题，因此对于字段的增减操作，需谨慎操作。可在最新版本中试验字段变更功能是否稳定
