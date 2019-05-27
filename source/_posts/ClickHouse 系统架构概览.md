---

title: ClickHouse系统架构概述
date: 2019-05-27 21:01:29
tags: NoSQL

---

# ClickHouse系统架构概述

## ClickHouse独特功能

### 真正的列式数据库管理系统

在一个真正的列式数据库管理系统中，除了数据本身外不应该存在其他额外的数据。这意味着为了避免在值旁边存储它们的长度“number”，你必须支持固定长度数值类型。例如，10亿个UInt8类型的数据在未压缩的情况下大约消耗1GB左右的空间，如果不是这样的话，这将对CPU的使用产生强烈影响。即使是在未压缩的情况下，紧凑的存储数据也是非常重要的，因为解压缩的速度主要取决于未压缩数据的大小。

这是非常值得注意的，因为在一些其他系统中也可以将不同的列分别进行存储，但由于对其他场景进行的优化，使其无法有效的处理分析查询。例如： HBase，BigTable，Cassandra，HyperTable。在这些系统中，你可以得到每秒数十万的吞吐能力，但是无法得到每秒几亿行的吞吐能力。

需要说明的是，ClickHouse不单单是一个数据库， 它是一个数据库管理系统。因为它允许在运行时创建表和数据库、加载数据和运行查询，而无需重新配置或重启服务。

<!-- more -->

### 数据压缩

在一些列式数据库管理系统中(例如：InfiniDB CE and MonetDB) 不是用数据压缩。但是, 数据压缩在实现优异的存储系统中确实起着关键的作用。



### 数据的磁盘存储

许多的列式数据库(如 SAP HANA, Google PowerDrill)只能在内存中工作，这种方式会造成比实际更多的设备预算。ClickHouse被设计用于工作在传统磁盘上的系统，它提供每GB更低的存储成本，但如果有可以使用SSD和内存，它也会合理的利用这些资源



### 多核心并行处理

大型查询可以以很自然的方式在ClickHouse中进行并行化处理，以此来使用当前服务器上可用的所有资源。



### 多服务器分布式处理

上面提到的列式数据库管理系统中，几乎没有一个支持分布式的查询处理。 在ClickHouse中，数据可以保存在不同的shard上，每一个shard都由一组用于容错的replica组成，查询可以并行的在所有shard上进行处理。这些对用户来说是透明的



### 支持SQL

ClickHouse支持基于SQL的查询语言，该语言大部分情况下是与SQL标准兼容的。 支持的查询包括 GROUP BY，ORDER BY，IN，JOIN以及非相关子查询。 不支持窗口函数和相关子查询。



### 向量引擎

为了高效的使用CPU，数据不仅仅按列存储，同时还按向量(列的一部分)进行处理。



### 实时的数据更新

ClickHouse支持在表中定义主键。为了使查询能够快速在主键中进行范围查找，数据总是以增量的方式有序的存储在MergeTree中。因此，数据可以持续不断高效的写入到表中，并且写入的过程中不会存在任何加锁的行为。



### 索引

按照主键对数据进行排序，这将帮助ClickHouse以几十毫秒的低延迟对数据进行特定值查找或范围查找。



### 适合在线查询

在线查询意味着在没有对数据做任何预处理的情况下以极低的延迟处理查询并将结果加载到用户的页面中。



### 支持近似计算

ClickHouse提供各种各样在允许牺牲数据精度的情况下对查询进行加速的方法：

1. 用于近似计算的各类聚合函数，如：distinct values, medians, quantiles
2. 基于数据的部分样本进行近似查询。这时，仅会从磁盘检索少部分比例的数据。
3. 不使用全部的聚合条件，通过随机选择有限个数据聚合条件进行聚合。这在数据聚合条件满足某些分布条件下，在提供相当准确的聚合结果的同时降低了计算资源的使用。



### 支持数据复制和数据完整性

ClickHouse使用异步的多主复制技术。当数据被写入任何一个可用副本后，系统会在后台将数据分发给其他副本，以保证系统在不同副本上保持相同的数据。在大多数情况下ClickHouse能在故障后自动恢复，在一些复杂的情况下需要少量的手动恢复。



### ClickHouse可以考虑缺点的功能

1. 没有完整的事物支持。
2. 缺少高频率，低延迟的修改或删除已存在数据的能力。仅能用于批量删除或修改数据，但这符合 [GDPR](https://gdpr-info.eu/)。
3. 稀疏索引使得ClickHouse不适合通过其键检索单行的点查询



# ClickHouse性能

根据Yandex的内部测试结果，ClickHouse表现出了比同类可比较产品更优的性能。你可以在 [这里](https://clickhouse.yandex/benchmark.html) 查看具体的测试结果。

许多其他的测试也证实这一点。你可以使用互联网搜索到它们，或者你也可以从 [我们收集的部分相关连接](https://clickhouse.yandex/#independent-benchmarks) 中查看。



## 单个大查询的吞吐量

吞吐量可以使用每秒处理的行数或每秒处理的字节数来衡量。如果数据被放置在page cache中，则一个不太复杂的查询在单个服务器上大约能够以2-10GB／s（未压缩）的速度进行处理（对于简单的查询，速度可以达到30GB／s）。如果数据没有在page cache中的话，那么速度将取决于你的磁盘系统和数据的压缩率。例如，如果一个磁盘允许以400MB／s的速度读取数据，并且数据压缩率是3，则数据的处理速度为1.2GB/s。这意味着，如果你是在提取一个10字节的列，那么它的处理速度大约是1-2亿行每秒。

对于分布式处理，处理速度几乎是线性扩展的，但这受限于聚合或排序的结果不是那么大的情况下。



## 处理短查询的延迟时间

如果一个查询使用主键并且没有太多行(几十万)进行处理，并且没有查询太多的列，那么在数据被page cache缓存的情况下，它的延迟应该小于50毫秒(在最佳的情况下应该小于10毫秒)。 否则，延迟取决于数据的查找次数。如果你当前使用的是HDD，在数据没有加载的情况下，查询所需要的延迟可以通过以下公式计算得知： 查找时间（10 ms） * 查询的列的数量 * 查询的数据块的数量。



## 处理大量短查询的吞吐量

在相同的情况下，ClickHouse可以在单个服务器上每秒处理数百个查询（在最佳的情况下最多可以处理数千个）。但是由于这不适用于分析型场景。因此我们建议每秒最多查询100次。



## 数据的写入性能

我们建议每次写入不少于1000行的批量写入，或每秒不超过一个写入请求。当使用tab-separated格式将一份数据写入到MergeTree表中时，写入速度大约为50到200MB/s。如果您写入的数据每行为1Kb，那么写入的速度为50，000到200，000行每秒。如果您的行更小，那么写入速度将更高。为了提高写入性能，您可以使用多个INSERT进行并行写入，这将带来线性的性能提升。



# Yandex.Metrica的使用案例

ClickHouse最初是为 [Yandex.Metrica](https://metrica.yandex.com/) [世界第二大Web分析平台](http://w3techs.com/technologies/overview/traffic_analysis/all) 而开发的。多年来一直作为该系统的核心组件被该系统持续使用着。目前为止，该系统在ClickHouse中有超过13万亿条记录，并且每天超过200多亿个事件被处理。它允许直接从原始数据中动态查询并生成报告。本文简要介绍了ClickHouse在其早期发展阶段的目标。

Yandex.Metrica基于用户定义的字段，对实时访问、连接会话，生成实时的统计报表。这种需求往往需要复杂聚合方式，比如对访问用户进行去重。构建报表的数据，是实时接收存储的新数据。

截至2014年4月，Yandex.Metrica每天跟踪大约120亿个事件（用户的点击和浏览）。为了可以创建自定义的报表，我们必须存储全部这些事件。同时，这些查询可能需要在几百毫秒内扫描数百万行的数据，或在几秒内扫描数亿行的数据。



## Yandex.Metrica以及其他Yandex服务的使用案例

在Yandex.Metrica中，ClickHouse被用于多个场景中。 它的主要任务是使用原始数据在线的提供各种数据报告。它使用374台服务器的集群，存储了20.3万亿行的数据。在去除重复与副本数据的情况下，压缩后的数据达到了2PB。未压缩前（TSV格式）它大概有17PB。

ClickHouse还被使用在：

- 存储来自Yandex.Metrica回话重放数据。
- 处理中间数据
- 与Analytics一起构建全球报表。
- 为调试Yandex.Metrica引擎运行查询
- 分析来自API和用户界面的日志数据

ClickHouse在其他Yandex服务中至少有12个安装：search verticals, Market, Direct, business analytics, mobile development, AdFox, personal services等。



## 聚合与非聚合数据

有一种流行的观点认为，想要有效的计算统计数据，必须要聚合数据，因为聚合将降低数据量。

但是数据聚合是一个有诸多限制的解决方案，例如：

- 你必须提前知道用户定义的报表的字段列表
- 用户无法自定义报表
- 当聚合条件过多时，可能不会减少数据，聚合是无用的。
- 存在大量报表时，有太多的聚合变化（组合爆炸）
- 当聚合条件有非常大的基数时（如：url），数据量没有太大减少（少于两倍）
- 聚合的数据量可能会增长而不是收缩
- 用户不会查看我们为他生成的所有报告，大部分计算将是无用的
- 各种聚合可能违背了数据的逻辑完整性

如果我们直接使用非聚合数据而不尽兴任何聚合时，我们的计算量可能是减少的。

然而，相对于聚合中很大一部分工作被离线完成，在线计算需要尽快的完成计算，因为用户在等待结果。

Yandex.Metrica 有一个专门用于聚合数据的系统，称为Metrage，它可以用作大部分报表。 从2009年开始，Yandex.Metrica还为非聚合数据使用专门的OLAP数据库，称为OLAPServer，它以前用于报表构建系统。 OLAPServer可以很好的工作在非聚合数据上，但是它有诸多限制，导致无法根据需要将其用于所有报表中。如，缺少对数据类型的支持（只支持数据），无法实时增量的更新数据（只能通过每天重写数据完成）。OLAPServer不是一个数据库管理系统，它只是一个数据库。

为了消除OLAPServer的这些局限性，解决所有报表使用非聚合数据的问题，我们开发了ClickHouse数据库管理系统。



# ClickHouse表引擎

表引擎（即表的类型）决定了：

- 数据的存储方式和位置，写到哪里以及从哪里读取数据
- 支持哪些查询以及如何支持。
- 并发数据访问。
- 索引的使用（如果存在）。
- 是否可以执行多线程请求。
- 数据复制参数。

在读取时，引擎只需要输出所请求的列，但在某些情况下，引擎可以在响应请求时部分处理数据。

对于大多数正式的任务，应该使用MergeTree族中的引擎。



## MergeTree

Clickhouse 中最强大的表引擎当属 `MergeTree` （合并树）引擎及该系列（`*MergeTree`）中的其他引擎。

`MergeTree` 引擎系列的基本理念如下。当你有巨量数据要插入到表中，你要高效地一批批写入数据片段，并希望这些数据片段在后台按照一定规则合并。相比在插入时不断修改（重写）数据进存储，这种策略会高效很多。

主要特点:

- 存储的数据按主键排序。

  这让你可以创建一个用于快速检索数据的小稀疏索引。

- 允许使用分区，如果指定了 [主键](https://clickhouse.yandex/docs/zh/operations/table_engines/custom_partitioning_key/) 的话。

  在相同数据集和相同结果集的情况下 ClickHouse 中某些带分区的操作会比普通操作更快。查询中指定了分区键时 ClickHouse 会自动截取分区数据。这也有效增加了查询性能。

- 支持数据副本。

  `ReplicatedMergeTree` 系列的表便是用于此。更多信息，请参阅 [数据副本](https://clickhouse.yandex/docs/zh/operations/table_engines/replication/) 一节。

- 支持数据采样。

  需要的话，你可以给表设置一个采样方法。

!!! 注意 [Merge](https://clickhouse.yandex/docs/zh/operations/table_engines/merge/) 引擎并不属于 `*MergeTree` 系列。



### 建表

```sql
CREATE TABLE [IF NOT EXISTS] [db.]table_name [ON CLUSTER cluster]
(
    name1 [type1] [DEFAULT|MATERIALIZED|ALIAS expr1],
    name2 [type2] [DEFAULT|MATERIALIZED|ALIAS expr2],
    ...
    INDEX index_name1 expr1 TYPE type1(...) GRANULARITY value1,
    INDEX index_name2 expr2 TYPE type2(...) GRANULARITY value2
) ENGINE = MergeTree()
[PARTITION BY expr]
[ORDER BY expr]
[PRIMARY KEY expr]
[SAMPLE BY expr]
[SETTINGS name=value, ...]
```

请求参数的描述，参考 [请求描述](https://clickhouse.yandex/docs/zh/query_language/create/) 。



示例：

```sql
CREATE TABLE xcloud.cdn_nginx_log_minute_agg
(
	date Date, 

    timeStamp DateTime,

	channel String, 

	customer String, 

	country String, 

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

PARTITION BY date  ORDER BY (timeStamp, date, channel, customer, country);
```



### 数据存储

表由按主键排序的数据 *片段* 组成。

当数据被插入到表中时，会分成数据片段并按主键的字典序排序。例如，主键是 `(CounterID, Date)` 时，片段中数据按 `CounterID` 排序，具有相同 `CounterID` 的部分按 `Date` 排序。

不同分区的数据会被分成不同的片段，ClickHouse 在后台合并数据片段以便更高效存储。不会合并来自不同分区的数据片段。这个合并机制并不保证相同主键的所有行都会合并到同一个数据片段中。

ClickHouse 会为每个数据片段创建一个索引文件，索引文件包含每个索引行（『标记』）的主键值。索引行号定义为 `n * index_granularity` 。最大的 `n` 等于总行数除以 `index_granularity` 的值的整数部分。对于每列，跟主键相同的索引行处也会写入『标记』。这些『标记』让你可以直接找到数据所在的列。

你可以只用一单一大表并不断地一块块往里面加入数据 – `MergeTree` 引擎的就是为了这样的场景。



### 主键和索引在查询中的表现

我们以 `(CounterID, Date)` 以主键。排序好的索引的图示会是下面这样：

```
全部数据  :     [-------------------------------------------------------------------------]
CounterID:      [aaaaaaaaaaaaaaaaaabbbbcdeeeeeeeeeeeeefgggggggghhhhhhhhhiiiiiiiiikllllllll]
Date:           [1111111222222233331233211111222222333211111112122222223111112223311122333]
标记:            |      |      |      |      |      |      |      |      |      |      |
                a,1    a,2    a,3    b,3    e,2    e,3    g,1    h,2    i,1    i,3    l,3
标记号:          0      1      2      3      4      5      6      7      8      9      10
```

如果指定查询如下：

- `CounterID in ('a', 'h')`，服务器会读取标记号在 `[0, 3)` 和 `[6, 8)` 区间中的数据。
- `CounterID IN ('a', 'h') AND Date = 3`，服务器会读取标记号在 `[1, 3)` 和 `[7, 8)` 区间中的数据。
- `Date = 3`，服务器会读取标记号在 `[1, 10]` 区间中的数据。

上面例子可以看出使用索引通常会比全表描述要高效。

稀疏索引会引起额外的数据读取。当读取主键单个区间范围的数据时，每个数据块中最多会多读 `index_granularity * 2` 行额外的数据。大部分情况下，当 `index_granularity = 8192` 时，ClickHouse的性能并不会降级。

稀疏索引让你能操作有巨量行的表。因为这些索引是常驻内存（RAM）的。

ClickHouse 不要求主键惟一。所以，你可以插入多条具有相同主键的行。



### 主键的选择

主键中列的数量并没有明确的限制。依据数据结构，你应该让主键包含多些或少些列。这样可以：

- 改善索引的性能。

  如果当前主键是 `(a, b)` ，然后加入另一个 `c` 列，满足下面条件时，则可以改善性能： - 有带有 `c` 列条件的查询。 - 很长的数据范围（ `index_granularity` 的数倍）里 `(a, b)` 都是相同的值，并且这种的情况很普遍。换言之，就是加入另一列后，可以让你的查询略过很长的数据范围。

- 改善数据压缩。

  ClickHouse 以主键排序片段数据，所以，数据的一致性越高，压缩越好。

- [CollapsingMergeTree](https://clickhouse.yandex/docs/zh/operations/table_engines/collapsingmergetree/#table_engine-collapsingmergetree) 和 [SummingMergeTree](https://clickhouse.yandex/docs/zh/operations/table_engines/summingmergetree/) 引擎里，数据合并时，会有额外的处理逻辑。

  在这种情况下，指定一个跟主键不同的 *排序键* 也是有意义的。

长的主键会对插入性能和内存消耗有负面影响，但主键中额外的列并不影响 `SELECT` 查询的性能。



### 选择跟排序键不一样主键

指定一个跟排序键（用于排序数据片段中行的表达式） 不一样的主键（用于计算写到索引文件的每个标记值的表达式）是可以的。 这种情况下，主键表达式元组必须是排序键表达式元组的一个前缀。

当使用 [SummingMergeTree](https://clickhouse.yandex/docs/zh/operations/table_engines/summingmergetree/) 和 [AggregatingMergeTree](https://clickhouse.yandex/docs/zh/operations/table_engines/aggregatingmergetree/) 引擎时，这个特性非常有用。 通常，使用这类引擎时，表里列分两种：*维度* 和 *度量* 。 典型的查询是在 `GROUP BY` 并过虑维度的情况下统计度量列的值。 像 SummingMergeTree 和 AggregatingMergeTree ，用相同的排序键值统计行时， 通常会加上所有的维度。结果就是，这键的表达式会是一长串的列组成， 并且这组列还会因为新加维度必须频繁更新。

这种情况下，主键中仅预留少量列保证高效范围扫描， 剩下的维度列放到排序键元组里。这样是合理的。

[排序键的修改](https://clickhouse.yandex/docs/zh/query_language/alter/) 是轻量级的操作，因为一个新列同时被加入到表里和排序键后时，已存在的数据片段并不需要修改。由于旧的排序键是新排序键的前缀，并且刚刚添加的列中没有数据，因此在表修改时的数据对于新旧的排序键来说都是有序的。



### 索引和分区在查询中的应用

对于 `SELECT` 查询，ClickHouse 分析是否可以使用索引。如果 `WHERE/PREWHERE` 子句具有下面这些表达式（作为谓词链接一子项或整个）则可以使用索引：基于主键或分区键的列或表达式的部分的等式或比较运算表达式；基于主键或分区键的列或表达式的固定前缀的 `IN` 或 `LIKE` 表达式；基于主键或分区键的列的某些函数；基于主键或分区键的表达式的逻辑表达式。

因此，在索引键的一个或多个区间上快速地跑查询都是可能的。下面例子中，指定标签；指定标签和日期范围；指定标签和日期；指定多个标签和日期范围等运行查询，都会非常快。

要检查 ClickHouse 执行一个查询时能否使用索引，可设置 [force_index_by_date](https://clickhouse.yandex/docs/zh/operations/settings/settings/#settings-force_index_by_date) 和 [force_primary_key](https://clickhouse.yandex/docs/zh/operations/settings/settings/) 。

按月分区的分区键是只能读取包含适当范围日期的数据块。这种情况下，数据块会包含很多天（最多整月）的数据。在块中，数据按主键排序，主键第一列可能不包含日期。因此，仅使用日期而没有带主键前缀条件的查询将会导致读取超过这个日期范围。



### 并发数据访问

应对表的并发访问，我们使用多版本机制。换言之，当同时读和更新表时，数据从当前查询到的一组片段中读取。没有冗长的的锁。插入不会阻碍读取。

对表的读操作是自动并行的。



## 数据副本

只有 MergeTree 系列里的表可支持副本：

- ReplicatedMergeTree
- ReplicatedSummingMergeTree
- ReplicatedReplacingMergeTree
- ReplicatedAggregatingMergeTree
- ReplicatedCollapsingMergeTree
- ReplicatedVersionedCollapsingMergeTree
- ReplicatedGraphiteMergeTree

副本是表级别的，不是整个服务器级的。所以，服务器里可以同时有复制表和非复制表。

副本不依赖分片。每个分片有它自己的独立副本。

对于 `INSERT` 和 `ALTER` 语句操作数据的会在压缩的情况下被复制（更多信息，看 [ALTER](https://clickhouse.yandex/docs/zh/query_language/alter/#query_language_queries_alter) ）。

而 `CREATE`，`DROP`，`ATTACH`，`DETACH` 和 `RENAME` 语句只会在单个服务器上执行，不会被复制。

- `The CREATE TABLE` 在运行此语句的服务器上创建一个新的可复制表。如果此表已存在其他服务器上，则给该表添加新副本。
- `The DROP TABLE` 删除运行此查询的服务器上的副本。
- `The RENAME` 重命名一个副本。换句话说，可复制表不同的副本可以有不同的名称。

要使用副本，需在配置文件中设置 ZooKeeper 集群的地址。

`SELECT` 查询并不需要借助 ZooKeeper ，复本并不影响 `SELECT` 的性能，查询复制表与非复制表速度是一样的。查询分布式表时，ClickHouse的处理方式可通过设置 [max_replica_delay_for_distributed_queries](https://clickhouse.yandex/docs/zh/operations/settings/settings/#settings-max_replica_delay_for_distributed_queries) 和 [fallback_to_stale_replicas_for_distributed_queries](https://clickhouse.yandex/docs/zh/operations/settings/settings/) 修改。

对于每个 `INSERT` 语句，会通过几个事务将十来个记录添加到 ZooKeeper。（确切地说，这是针对每个插入的数据块; 每个 INSERT 语句的每 `max_insert_block_size = 1048576` 行和最后剩余的都各算作一个块。）相比非复制表，写 zk 会导致 `INSERT` 的延迟略长一些。但只要你按照建议每秒不超过一个 `INSERT` 地批量插入数据，不会有任何问题。一个 ZooKeeper 集群能给整个 ClickHouse 集群支撑协调每秒几百个 `INSERT`。数据插入的吞吐量（每秒的行数）可以跟不用复制的数据一样高。

对于非常大的集群，你可以把不同的 ZooKeeper 集群用于不同的分片。然而，即使 Yandex.Metrica 集群（大约300台服务器）也证明还不需要这么做。

复制是多主异步。 `INSERT` 语句（以及 `ALTER` ）可以发给任意可用的服务器。数据会先插入到执行该语句的服务器上，然后被复制到其他服务器。由于它是异步的，在其他副本上最近插入的数据会有一些延迟。如果部分副本不可用，则数据在其可用时再写入。副本可用的情况下，则延迟时长是通过网络传输压缩数据块所需的时间。

默认情况下，INSERT 语句仅等待一个副本写入成功后返回。如果数据只成功写入一个副本后该副本所在的服务器不再存在，则存储的数据会丢失。要启用数据写入多个副本才确认返回，使用 `insert_quorum` 选项。

单个数据块写入是原子的。 INSERT 的数据按每块最多 `max_insert_block_size = 1048576` 行进行分块，换句话说，如果 `INSERT` 插入的行少于 1048576，则该 INSERT 是原子的。

数据块会去重。对于被多次写的相同数据块（大小相同且具有相同顺序的相同行的数据块），该块仅会写入一次。这样设计的原因是万一在网络故障时客户端应用程序不知道数据是否成功写入DB，此时可以简单地重复 `INSERT` 。把相同的数据发送给多个副本 INSERT 并不会有问题。因为这些 `INSERT` 是完全相同的（会被去重）。去重参数参看服务器设置 [merge_tree](https://clickhouse.yandex/docs/zh/operations/server_settings/settings/) 。（注意：Replicated*MergeTree 才会去重，不需要 zookeeper 的不带 MergeTree 不会去重）

在复制期间，只有要插入的源数据通过网络传输。进一步的数据转换（合并）会在所有副本上以相同的方式进行处理执行。这样可以最大限度地减少网络使用，这意味着即使副本在不同的数据中心，数据同步也能工作良好。（能在不同数据中心中的同步数据是副本机制的主要目标。）

你可以给数据做任意多的副本。Yandex.Metrica 在生产中使用双副本。某一些情况下，给每台服务器都使用 RAID-5 或 RAID-6 和 RAID-10。是一种相对可靠和方便的解决方案。

系统会监视副本数据同步情况，并能在发生故障后恢复。故障转移是自动的（对于小的数据差异）或半自动的（当数据差异很大时，这可能意味是有配置错误）。



### 创建复制表

在表引擎名称上加上 `Replicated` 前缀。例如：`ReplicatedMergeTree`。

**Replicated\*MergeTree 参数**

- `zoo_path` — ZooKeeper 中该表的路径。
- `replica_name` — ZooKeeper 中的该表的副本名称。

示例:

```sql
CREATE TABLE table_name
(
    EventDate DateTime,
    CounterID UInt32,
    UserID UInt32
) ENGINE = ReplicatedMergeTree('/clickhouse/tables/{layer}-{shard}/table_name', '{replica}')
PARTITION BY toYYYYMM(EventDate)
ORDER BY (CounterID, EventDate, intHash32(UserID))
SAMPLE BY intHash32(UserID)
```

如上例所示，这些参数可以包含宏替换的占位符，即大括号的部分。它们会被替换为配置文件里 'macros' 那部分配置的值。示例：

```xml
<macros>
    <layer>05</layer>
    <shard>02</shard>
    <replica>example05-02-1.yandex.ru</replica>
</macros>
```

“ZooKeeper 中该表的路径”对每个可复制表都要是唯一的。不同分片上的表要有不同的路径。 这种情况下，路径包含下面这些部分：

`/clickhouse/tables/` 是公共前缀，我们推荐使用这个。

`{layer}-{shard}` 是分片标识部分。在此示例中，由于 Yandex.Metrica 集群使用了两级分片，所以它是由两部分组成的。但对于大多数情况来说，你只需保留 {shard} 占位符即可，它会替换展开为分片标识。

```
table_name` 是该表在 ZooKeeper 中的名称。使其与 ClickHouse 中的表名相同比较好。 这里它被明确定义，跟 ClickHouse 表名不一样，它并不会被 RENAME 语句修改。
*HINT*: you could add a database name in front of `table_name` as well. E.g. `db_name.table_name
```

副本名称用于标识同一个表分片的不同副本。你可以使用服务器名称，如上例所示。同个分片中不同副本的副本名称要唯一。

你也可以显式指定这些参数，而不是使用宏替换。对于测试和配置小型集群这可能会很方便。但是，这种情况下，则不能使用分布式 DDL 语句（`ON CLUSTER`）。

使用大型集群时，我们建议使用宏替换，因为它可以降低出错的可能性。

在每个副本服务器上运行 `CREATE TABLE` 查询。将创建新的复制表，或给现有表添加新副本。

如果其他副本上已包含了某些数据，在表上添加新副本，则在运行语句后，数据会从其他副本复制到新副本。换句话说，新副本会与其他副本同步。

要删除副本，使用 `DROP TABLE`。但它只删除那个 – 位于运行该语句的服务器上的副本。



### 故障恢复

如果服务器启动时 ZooKeeper 不可用，则复制表会切换为只读模式。系统会定期尝试去连接 ZooKeeper。

如果在 `INSERT` 期间 ZooKeeper 不可用，或者在与 ZooKeeper 交互时发生错误，则抛出异常。

连接到 ZooKeeper 后，系统会检查本地文件系统中的数据集是否与预期的数据集（ ZooKeeper 存储此信息）一致。如果存在轻微的不一致，系统会通过与副本同步数据来解决。

如果系统检测到损坏的数据片段（文件大小错误）或无法识别的片段（写入文件系统但未记录在 ZooKeeper 中的部分），则会把它们移动到 'detached' 子目录（不会删除）。而副本中其他任何缺少的但正常数据片段都会被复制同步。

注意，ClickHouse 不会执行任何破坏性操作，例如自动删除大量数据。

当服务器启动（或与 ZooKeeper 建立新会话）时，它只检查所有文件的数量和大小。 如果文件大小一致但中间某处已有字节被修改过，不会立即被检测到，只有在尝试读取 `SELECT` 查询的数据时才会检测到。该查询会引发校验和不匹配或压缩块大小不一致的异常。这种情况下，数据片段会添加到验证队列中，并在必要时从其他副本中复制。

如果本地数据集与预期数据的差异太大，则会触发安全机制。服务器在日志中记录此内容并拒绝启动。这种情况很可能是配置错误，例如，一个分片上的副本意外配置为别的分片上的副本。然而，此机制的阈值设置得相当低，在正常故障恢复期间可能会出现这种情况。在这种情况下，数据恢复则是半自动模式，通过用户主动操作触发。

要触发启动恢复，可在 ZooKeeper 中创建节点 `/path_to_table/replica_name/flags/force_restore_data`，节点值可以是任何内容，或运行命令来恢复所有的可复制表：

```sql
sudo -u clickhouse touch /var/lib/clickhouse/flags/force_restore_data
```

然后重启服务器。启动时，服务器会删除这些标志并开始恢复。



### 在数据完全丢失后的恢复

如果其中一个服务器的所有数据和元数据都消失了，请按照以下步骤进行恢复：

1. 在服务器上安装 ClickHouse。在包含分片标识符和副本的配置文件中正确定义宏配置，如果有用到的话，
2. 如果服务器上有非复制表则必须手动复制，可以从副本服务器上（在 `/var/lib/clickhouse/data/db_name/table_name/` 目录中）复制它们的数据。
3. 从副本服务器上中复制位于 `/var/lib/clickhouse/metadata/` 中的表定义信息。如果在表定义信息中显式指定了分片或副本标识符，请更正它以使其对应于该副本。（另外，启动服务器，然后会在 `/var/lib/clickhouse/metadata/` 中的.sql文件中生成所有的 `ATTACH TABLE` 语句。） 4.要开始恢复，ZooKeeper 中创建节点 `/path_to_table/replica_name/flags/force_restore_data`，节点内容不限，或运行命令来恢复所有复制的表：`sudo -u clickhouse touch /var/lib/clickhouse/flags/force_restore_data`

然后启动服务器（如果它已运行则重启）。数据会从副本中下载。

另一种恢复方式是从 ZooKeeper（`/path_to_table/replica_name`）中删除有数据丢的副本的所有元信息，然后再按照“[创建可复制表](https://clickhouse.yandex/docs/zh/operations/table_engines/replication/#creating-replicated-tables)”中的描述重新创建副本。

恢复期间的网络带宽没有限制。特别注意这一点，尤其是要一次恢复很多副本。



## 自定义分区键

[MergeTree](https://clickhouse.yandex/docs/zh/operations/table_engines/mergetree/) 系列的表（包括 [可复制表](https://clickhouse.yandex/docs/zh/operations/table_engines/replication/) ）可以使用分区。基于 MergeTree 表的 [物化视图](https://clickhouse.yandex/docs/zh/operations/table_engines/materializedview/) 也支持分区。

一个分区是指按指定规则逻辑组合一起的表的记录集。可以按任意标准进行分区，如按月，按日或按事件类型。为了减少需要操作的数据，每个分区都是分开存储的。访问数据时，ClickHouse 尽量使用这些分区的最小子集。

分区是在 [建表](https://clickhouse.yandex/docs/zh/operations/table_engines/mergetree/#table_engine-mergetree-creating-a-table) 的 `PARTITION BY expr` 子句中指定。分区键可以是关于列的任何表达式。例如，指定按月分区，表达式为 `toYYYYMM(date_column)`：

```sql
CREATE TABLE visits
(
    VisitDate Date, 
    Hour UInt8, 
    ClientID UUID
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(VisitDate)
ORDER BY Hour;
```

分区键也可以是表达式元组（类似 [主键](https://clickhouse.yandex/docs/zh/operations/table_engines/mergetree/#primary-keys-and-indexes-in-queries) ）。例如：

```sql
ENGINE = ReplicatedCollapsingMergeTree('/clickhouse/tables/name', 'replica1', Sign)
PARTITION BY (toMonday(StartDate), EventType)
ORDER BY (CounterID, StartDate, intHash32(UserID));
```

上例中，我们设置按一周内的事件类型分区。

新数据插入到表中时，这些数据会存储为按主键排序的新片段（块）。插入后 10-15 分钟，同一分区的各个片段会合并为一整个片段。

**那些有相同分区表达式值的数据片段才会合并。这意味着 你不应该用太精细的分区方案（超过一千个分区）。否则，会因为文件系统中的文件数量和需要找开的文件描述符过多，导致 `SELECT` 查询效率不佳。**



## ReplacingMergeTree 引擎

该引擎和[MergeTree](https://clickhouse.yandex/docs/zh/operations/table_engines/mergetree/)的不同之处在于它会删除具有相同主键的重复项。

数据的去重只会在合并的过程中出现。合并会在未知的时间在后台进行，因此你无法预先作出计划。有一些数据可能仍未被处理。尽管你可以调用 `OPTIMIZE` 语句发起计划外的合并，但请不要指望使用它，因为 `OPTIMIZE` 语句会引发对大量数据的读和写。

因此，`ReplacingMergeTree` 适用于在后台清除重复的数据以节省空间，但是它不保证没有重复的数据出现。



建表:

```sql
CREATE TABLE [IF NOT EXISTS] [db.]table_name [ON CLUSTER cluster]
(
    name1 [type1] [DEFAULT|MATERIALIZED|ALIAS expr1],
    name2 [type2] [DEFAULT|MATERIALIZED|ALIAS expr2],
    ...
) ENGINE = ReplacingMergeTree([ver])
[PARTITION BY expr]
[ORDER BY expr]
[SAMPLE BY expr]
[SETTINGS name=value, ...]
```



## SummingMergeTree 引擎

该引擎继承自 [MergeTree](https://clickhouse.yandex/docs/zh/operations/table_engines/mergetree/)。区别在于，当合并 `SummingMergeTree` 表的数据片段时，ClickHouse 会把所有具有相同主键的行合并为一行，该行包含了被合并的行中具有数值数据类型的列的汇总值。如果主键的组合方式使得单个键值对应于大量的行，则可以显著的减少存储空间并加快数据查询的速度。

我们推荐将该引擎和 `MergeTree` 一起使用。例如，在准备做报告的时候，将完整的数据存储在 `MergeTree` 表中，并且使用 `SummingMergeTree` 来存储聚合数据。这种方法可以使你避免因为使用不正确的主键组合方式而丢失有价值的数据。



建表：

```sql
CREATE TABLE [IF NOT EXISTS] [db.]table_name [ON CLUSTER cluster]
(
    name1 [type1] [DEFAULT|MATERIALIZED|ALIAS expr1],
    name2 [type2] [DEFAULT|MATERIALIZED|ALIAS expr2],
    ...
) ENGINE = SummingMergeTree([columns])
[PARTITION BY expr]
[ORDER BY expr]
[SAMPLE BY expr]
[SETTINGS name=value, ...]
```



当数据被插入到表中时，他们将被原样保存。ClickHouse 定期合并插入的数据片段，并在这个时候对所有具有相同主键的行中的列进行汇总，将这些行替换为包含汇总数据的一行记录。

ClickHouse 会按片段合并数据，以至于不同的数据片段中会包含具有相同主键的行，即单个汇总片段将会是不完整的。因此，聚合函数 [sum()](https://clickhouse.yandex/docs/zh/query_language/agg_functions/reference/#agg_function-sum) 和 `GROUP BY` 子句应该在（`SELECT`）查询语句中被使用，如上文中的例子所述。



列中数值类型的值会被汇总。这些列的集合在参数 `columns` 中被定义。

如果用于汇总的所有列中的值均为0，则该行会被删除。

如果列不在主键中且无法被汇总，则会在现有的值中任选一个。

主键所在的列中的值不会被汇总。



## AggregatingMergeTree 引擎

该引擎继承自 [MergeTree](https://clickhouse.yandex/docs/zh/operations/table_engines/mergetree/)，并改变了数据片段的合并逻辑。 ClickHouse 会将相同主键的所有行（在一个数据片段内）替换为单个存储一系列聚合函数状态的行。

可以使用 `AggregatingMergeTree` 表来做增量数据统计聚合，包括物化视图的数据聚合。

引擎需使用 [AggregateFunction](https://clickhouse.yandex/docs/zh/data_types/nested_data_structures/aggregatefunction/) 类型来处理所有列。

如果要按一组规则来合并减少行数，则使用 `AggregatingMergeTree` 是合适的。



建表：

```sql
CREATE TABLE [IF NOT EXISTS] [db.]table_name [ON CLUSTER cluster]
(
    name1 [type1] [DEFAULT|MATERIALIZED|ALIAS expr1],
    name2 [type2] [DEFAULT|MATERIALIZED|ALIAS expr2],
    ...
) ENGINE = AggregatingMergeTree()
[PARTITION BY expr]
[ORDER BY expr]
[SAMPLE BY expr]
[SETTINGS name=value, ...]
```



插入数据，需使用带有聚合 -State- 函数的 [INSERT SELECT](https://clickhouse.yandex/docs/zh/query_language/insert_into/) 语句。 从 `AggregatingMergeTree` 表中查询数据时，需使用 `GROUP BY` 子句并且要使用与插入时相同的聚合函数，但后缀要改为 `-Merge` 。

在 `SELECT` 查询的结果中，对于 ClickHouse 的所有输出格式 `AggregateFunction` 类型的值都实现了特定的二进制表示法。如果直接用 `SELECT` 导出这些数据，例如如用 `TabSeparated` 格式，那么这些导出数据也能直接用 `INSERT` 语句加载导入



聚合物化视图的示例, 创建一个跟踪 `test.visits` 表的 `AggregatingMergeTree` 物化视图：

```sql
CREATE MATERIALIZED VIEW test.basic
ENGINE = AggregatingMergeTree() PARTITION BY toYYYYMM(StartDate) ORDER BY (CounterID, StartDate)
AS SELECT
    CounterID,
    StartDate,
    sumState(Sign)    AS Visits,
    uniqState(UserID) AS Users
FROM test.visits
GROUP BY CounterID, StartDate;
```

向 `test.visits` 表中插入数据。数据会同时插入到表和视图中，并且视图 `test.basic` 会将里面的数据聚合。

要获取聚合数据，我们需要在 `test.basic` 视图上执行类似 `SELECT ... GROUP BY ...` 这样的查询 ：

```sql
SELECT
    StartDate,
    sumMerge(Visits) AS Visits,
    uniqMerge(Users) AS Users
FROM test.basic
GROUP BY StartDate
ORDER BY StartDate;
```



# 分布式引擎

**分布式引擎本身不存储数据**, 但可以在多个服务器上进行分布式查询。 读是自动并行的。读取时，远程服务器表的索引（如果有的话）会被使用。 分布式引擎参数：服务器配置文件中的集群名，远程数据库名，远程表名，数据分片键（可选）。 示例：

```sql
Distributed(logs, default, hits[, sharding_key])
```

将会从位于“logs”集群中 default.hits 表所有服务器上读取数据。 远程服务器不仅用于读取数据，还会对尽可能数据做部分处理。 例如，对于使用 GROUP BY 的查询，数据首先在远程服务器聚合，之后返回聚合函数的中间状态给查询请求的服务器。再在请求的服务器上进一步汇总数据。

数据库名参数除了用数据库名之外，也可用返回字符串的常量表达式。例如：currentDatabase()。

集群示例配置如下：

```xml
<remote_servers>
    <logs>
        <shard>
            <!-- Optional. Shard weight when writing data. Default: 1. -->
            <weight>1</weight>
            <!-- Optional. Whether to write data to just one of the replicas. Default: false (write data to all replicas). -->
            <internal_replication>false</internal_replication>
            <replica>
                <host>example01-01-1</host>
                <port>9000</port>
            </replica>
            <replica>
                <host>example01-01-2</host>
                <port>9000</port>
            </replica>
        </shard>
        <shard>
            <weight>2</weight>
            <internal_replication>false</internal_replication>
            <replica>
                <host>example01-02-1</host>
                <port>9000</port>
            </replica>
            <replica>
                <host>example01-02-2</host>
                <secure>1</secure>
                <port>9440</port>
            </replica>
        </shard>
    </logs>
</remote_servers>
```

这里定义了一个名为‘logs’的集群，它由两个分片组成，每个分片包含两个副本。 分片是指包含数据不同部分的服务器（要读取所有数据，必须访问所有分片）。 副本是存储复制数据的服务器（要读取所有数据，访问任一副本上的数据即可）。

每个服务器需要指定 `host`，`port`，和可选的 `user`，`password`，`secure`，`compression` 的参数：

- `host` – 远程服务器地址。可以域名、IPv4或IPv6。如果指定域名，则服务在启动时发起一个 DNS 请求，并且请求结果会在服务器运行期间一直被记录。如果 DNS 请求失败，则服务不会启动。如果你修改了 DNS 记录，则需要重启服务。
- `port` – 消息传递的 TCP 端口（「tcp_port」配置通常设为 9000）。不要跟 http_port 混淆。
- `user` – 用于连接远程服务器的用户名。默认值：default。该用户必须有权限访问该远程服务器。访问权限配置在 users.xml 文件中。更多信息，请查看“访问权限”部分。
- `password` – 用于连接远程服务器的密码。默认值：空字符串。
- `secure` – 是否使用ssl进行连接，设为true时，通常也应该设置 `port` = 9440。服务器也要监听 9440 并有正确的证书。
- `compression` - 是否使用数据压缩。默认值：true。

配置了副本，读取操作会从每个分片里选择一个可用的副本。可配置负载平衡算法（挑选副本的方式） - 请参阅“load_balancing”设置。 如果跟服务器的连接不可用，则在尝试短超时的重连。如果重连失败，则选择下一个副本，依此类推。如果跟所有副本的连接尝试都失败，则尝试用相同的方式再重复几次。 该机制有利于系统可用性，但不保证完全容错：如有远程服务器能够接受连接，但无法正常工作或状况不佳。

你可以配置一个（这种情况下，查询操作更应该称为远程查询，而不是分布式查询）或任意多个分片。在每个分片中，可以配置一个或任意多个副本。不同分片可配置不同数量的副本。

可以在配置中配置任意数量的集群。

要查看集群，可使用“system.clusters”表。

通过分布式引擎可以像使用本地服务器一样使用集群。但是，集群不是自动扩展的：你必须编写集群配置到服务器配置文件中（最好，给所有集群的服务器写上完整配置）。

不支持用分布式表查询别的分布式表（除非该表只有一个分片）。或者说，要用分布表查查询“最终”的数据表。

分布式引擎需要将集群信息写入配置文件。配置文件中的集群信息会即时更新，无需重启服务器。如果你每次是要向不确定的一组分片和副本发送查询，则不适合创建分布式表 - 而应该使用“远程”表函数。 请参阅“表函数”部分。

向集群写数据的方法有两种：

一，自已指定要将哪些数据写入哪些服务器，并直接在每个分片上执行写入。换句话说，在分布式表上“查询”，在数据表上 INSERT。 这是最灵活的解决方案 – 你可以使用任何分片方案，对于复杂业务特性的需求，这可能是非常重要的。 这也是最佳解决方案，因为数据可以完全独立地写入不同的分片。

二，在分布式表上执行 INSERT。在这种情况下，分布式表会跨服务器分发插入数据。 为了写入分布式表，必须要配置分片键（最后一个参数）。当然，如果只有一个分片，则写操作在没有分片键的情况下也能工作，因为这种情况下分片键没有意义。

每个分片都可以在配置文件中定义权重。默认情况下，权重等于1。数据依据分片权重按比例分发到分片上。例如，如果有两个分片，第一个分片的权重是9，而第二个分片的权重是10，则发送 9 / 19 的行到第一个分片， 10 / 19 的行到第二个分片。

分片可在配置文件中定义 'internal_replication' 参数。

此参数设置为“true”时，写操作只选一个正常的副本写入数据。如果分布式表的子表是复制表(*ReplicaMergeTree)，请使用此方案。换句话说，这其实是把数据的复制工作交给实际需要写入数据的表本身而不是分布式表。

若此参数设置为“false”（默认值），写操作会将数据写入所有副本。实质上，这意味着要分布式表本身来复制数据。这种方式不如使用复制表的好，因为不会检查副本的一致性，并且随着时间的推移，副本数据可能会有些不一样。

选择将一行数据发送到哪个分片的方法是，首先计算分片表达式，然后将这个计算结果除以所有分片的权重总和得到余数。该行会发送到那个包含该余数的从'prev_weight'到'prev_weights + weight'的半闭半开区间对应的分片上，其中 'prev_weights' 是该分片前面的所有分片的权重和，'weight' 是该分片的权重。例如，如果有两个分片，第一个分片权重为9，而第二个分片权重为10，则余数在 [0,9) 中的行发给第一个分片，余数在 [9,19) 中的行发给第二个分片。

分片表达式可以是由常量和表列组成的任何返回整数表达式。例如，您可以使用表达式 'rand()' 来随机分配数据，或者使用 'UserID' 来按用户 ID 的余数分布（相同用户的数据将分配到单个分片上，这可降低带有用户信息的 IN 和 JOIN 的语句运行的复杂度）。如果该列数据分布不够均匀，可以将其包装在散列函数中：intHash64(UserID)。

这种简单的用余数来选择分片的方案是有局限的，并不总适用。它适用于中型和大型数据（数十台服务器）的场景，但不适用于巨量数据（数百台或更多服务器）的场景。后一种情况下，应根据业务特性需求考虑的分片方案，而不是直接用分布式表的多分片。

SELECT 查询会被发送到所有分片，并且无论数据在分片中如何分布（即使数据完全随机分布）都可正常工作。添加新分片时，不必将旧数据传输到该分片。你可以给新分片分配大权重然后写新数据 - 数据可能会稍分布不均，但查询会正确高效地运行。

下面的情况，你需要关注分片方案：

- 使用需要特定键连接数据（ IN 或 JOIN ）的查询。如果数据是用该键进行分片，则应使用本地 IN 或 JOIN 而不是 GLOBAL IN 或 GLOBAL JOIN，这样效率更高。
- 使用大量服务器（上百或更多），但有大量小查询（个别客户的查询 - 网站，广告商或合作伙伴）。为了使小查询不影响整个集群，让单个客户的数据处于单个分片上是有意义的。或者，正如我们在 Yandex.Metrica 中所做的那样，你可以配置两级分片：将整个集群划分为“层”，一个层可以包含多个分片。单个客户的数据位于单个层上，根据需要将分片添加到层中，层中的数据随机分布。然后给每层创建分布式表，再创建一个全局的分布式表用于全局的查询。

数据是异步写入的。对于分布式表的 INSERT，数据块只写本地文件系统。之后会尽快地在后台发送到远程服务器。你可以通过查看表目录中的文件列表（等待发送的数据）来检查数据是否成功发送：/var/lib/clickhouse/data/database/table/ 。

如果在 INSERT 到分布式表时服务器节点丢失或重启（如，设备故障），则插入的数据可能会丢失。如果在表目录中检测到损坏的数据分片，则会将其转移到“broken”子目录，并不再使用。

启用 max_parallel_replicas 选项后，会在分表的所有副本上并行查询处理。更多信息，请参阅“设置，max_parallel_replicas”部分。