---
title: Log Structured Merge Trees 概述
date: 2019-10-17 13:01:29
tags: NoSQL
---



# Log Structured Merge Trees 概述

ClickHouse数据存储原理采用的思想和LSM基本一致，本文主要讲述LSM数据存储的设计思想和基本原理。本文部分内容来自网上一篇译文，原文地址已找不到。

具体十年前，谷歌发表了 BigTable”的论文，提出了一种数据存储的方法叫Log Structured-Merge Tree，简称LSM。现在LSM已被用在许多产品的文件结构策略：HBase、 Cassandra、 LevelDB、RocksDB，包括刚开源不久的ClickHouse数据库的存储引擎也采用的是类似LSM原理。



## 背景知识

简单地说，LSM的设计主要是为了解决随机写的效率问题而采用的顺序写，可大大提升数据读写性能而提出的。当前大家都知道磁盘随机读写速度慢，顺序写可大大提升读写吞吐量。这种采用顺序写而提升系统吞吐量比较出名的开源组件是消息中间件Kafka，Kafka采用offset + 追加写具备很高的读写性能，也是目前大数据平台必备组件之一。

但是对于数据存储系统，采用顺序追加写可解决写性能问题，对于读主要有几种设计方向：

1. 二分查找：将文件数据有序保存，使用二分查找来完成特定key的查找。
2. 哈希：用哈希将数据分割为不同的bucket
3. B+树：使用B+树 或者 ISAM 等方法，可以减少外部文件的读取
4. 外部文件： 将数据保存为日志，并创建一个hash或者查找树映射相应的文件。

所有的方法都可以有效的提高了读操作的性能（最少提供了O(log(n)) )，但是，却丢失了日志的写性能。上面这些方法，都强加了总体的结构信息在数据上，数据被按照特定的方式放置，所以可以很快的找到特定的数据，但是却对写操作不友善，让写操作性能下降。更糟糕的是，当我们需要更新hash或者B+树的结构时，需要同时更新文件系统中特定的部分，这就是上面说的比较慢的随机读写操作。**这种随机的操作要尽量减少**。

所以这就是 LSM 被设计的原因， LSM 使用一种不同于上述四种的方法，保持了日志文件写性能，以及微小的读操作性能损失。本质上就是让所有的操作顺序化，而不是像散弹枪一样随机读写。

<!--more-->



## The Base LSM Algorithm

从概念上说，最基本的LSM是很简单的 。将之前使用一个大的查找结构（造成随机读写，影响写性能），变换为将写操作顺序的保存到一些相似的有序文件（也就是sstable)中。所以每个文件包含短时间内的一些改动。因为文件是有序的，所以之后查找也会很快。文件是不可修改的，他们永远不会被更新，新的更新操作只会写到新的文件中。通过周期性的合并这些文件来减少文件个数。

[![basic lsm](https://camo.githubusercontent.com/1218b935160a7a0f9afa1c5bd6774c195dc44ea8/687474703a2f2f7777772e62656e73746f70666f72642e636f6d2f77702d636f6e74656e742f75706c6f6164732f323031352f30322f4a6f75726e616c362d31303234783530332e706e67)](https://www.open-open.com/misc/goto?guid=4959627134618001462)



让我们更具体的看看，当一些更新操作到达时，他们会被写到内存缓存（也就是memtable）中，memtable使用树结构来保持key的有序，在大部分的实现中，memtable会通过写WAL的方式备份到磁盘，用来恢复数据，防止数据丢失。当memtable数据达到一定规模时会被刷新到磁盘上的一 个新文件，重要的是系统只做了顺序磁盘读写，因为没有文件被编辑，新的内容或者修改只用简单的生成新的文件。

所以越多的数据存储到系统中，就会有越多的不可修改的，顺序的sstable文件被创建，它们代表了小的，按时间顺序的修改。

因为比较旧的文件不会被更新，重复的纪录只会通过创建新的纪录来覆盖，这也就产生了一些冗余的数据。

所以系统会周期的执行合并操作（compaction)。 合并操作选择一些文件，并把他们合并到一起，移除重复的更新或者删除纪录，同时也会删除上述的冗余。更重要的是，通过减少文件个数的增长，保证读操作的性 能。因为sstable文件都是有序结构的，所以合并操作也是非常高效的。

当一个读操作请求时，系统首先检查内存数据(memtable)，如果没有找到这个key，就会逆序的一个一个检查sstable文件，直到key 被找到。因为每个sstable都是有序的，所以查找比较高效(O(logN))，但是读操作会变的越来越慢随着sstable的个数增加，因为每一个 sstable都要被检查。（O(K log N), K为sstable个数， N 为sstable平均大小）。

所以，读操作比其它本地更新的结构慢，幸运的是，有一些技巧可以提高性能。最基本的的方法就是页缓存（也就是leveldb的 TableCache，将sstable按照LRU缓存在内存中）在内存中，减少二分查找的消耗。LevelDB 和 BigTable 是将 block-index 保存在文件尾部，这样查找就只要一次IO操作，如果block-index在内存中。一些其它的系统则实现了更复杂的索引方法。

即使有每个文件的索引，随着文件个数增多，读操作仍然很慢。通过周期的合并文件，来保持文件的个数，因些读操作的性能在可接收的范围内。即便有了合 并操作，读操作仍然会访问大量的文件，大部分的实现通过布隆过滤器来避免大量的读文件操作，布隆过滤器是一种高效的方法来判断一个sstable中是否包含一个特定的key。（如果bloom说一个key不存在，就一定不存在，而当bloom说一个文件存在是，可能是不存在的，只是通过概率来保证）

所有的写操作都被分批处理，只写到顺序块上。另外，合并操作的周期操作会对IO有影响，读操作有可能会访问大量的文件（散乱的读）。这简化了算法工作的方法，我们交换了读和写的随机IO。这种折衷很有意义，我们可以通过软件实现的技巧像布隆过滤器或者硬件（大文件cache）来优化读性能。

[![read](https://camo.githubusercontent.com/f10b4934a0ae982b9b87054ed7fe93e150f8d4ad/687474703a2f2f7777772e62656e73746f70666f72642e636f6d2f77702d636f6e74656e742f75706c6f6164732f323031352f30322f4a6f75726e616c33312d31303234783632392e706e67)](https://www.open-open.com/misc/goto?guid=4959627134703828845)



## Basic Compaction

为了保持LSM的读操作相对较快，维护并减少sstable文件的个数是很重要的，所以让我们更深入的看一下合并操作。这个过程有一点儿像一般垃圾回收算法。

当一定数量的sstable文件被创建，例如有5个sstable，每一个有10行，他们被合并为一个50行的文件（或者更少的行数）。这个过程一直持续着，当更多的有10行的sstable文件被创建，当产生5个文件时，它们就被合并到50行的文件。最终会有5个50行的文件，这时会将这5个50 行的文件合并成一个250行的文件。这个过程不停的创建更大的文件。像下图：
[![compaction](https://camo.githubusercontent.com/208bbe1a5cdb8f235c32edf72568fc2e58af15a0/687474703a2f2f7777772e62656e73746f70666f72642e636f6d2f77702d636f6e74656e742f75706c6f6164732f323031352f30322f4a6f75726e616c322e35312d31303234783531342e706e67)](https://www.open-open.com/misc/goto?guid=4959627134781764374)

上述的方案有一个问题，就是大量的文件被创建，在最坏的情况下，所有的文件都要搜索。



## Levelled Compaction

更新的实现，像 LevelDB 和 Cassandra解决这个问题的方法是：实现了一个分层的，而不是根据文件大小来执行合并操作。这个方法可以减少在最坏情况下需要检索的文件个数，同时也减少了一次合并操作的影响。

按层合并的策略相对于上述的按文件大小合并的策略有二个关键的不同：

1. 每一层可以维护指定的文件个数，同时保证不让key重叠。也就是说把key分区到不同的文件。因此在一层查找一个key，只用查找一个文件。第一层是特殊情况，不满足上述条件，key可以分布在多个文件中。
2. 每次，文件只会被合并到上一层的一个文件。当一层的文件数满足特定个数时，一个文件会被选出并合并到上一层。这明显不同与另一种合并方式：一些相近大小的文件被合并为一个大文件。

这些改变表明按层合并的策略减小了合并操作的影响，同时减少了空间需求。除此之外，它也有更好的读性能。但是对于大多数场景，总体的IO次数变的更多，一些更简单的写场景不适用。



## Write Operation

当应用写入一条 key-value 记录的时候，LevelDB 会先往磁盘上的**日志文件**里写入，成功后将记录插进内存中的 **memtable** 中，这样基本就算完成了写入操作，因为一次写入操作只涉及一次磁盘顺序写和一次内存写入，这是 LevelDB写入速度极快的主要原因。

一旦 memtable 满了之后，LevelDB 会生成新的 memtable 和日志文件来处理用户接下来的请求。在后台，之前的 memtable 被转换成 **immutable memtable**，顾名思义，就是说这个 memtable 的内容是不可更改的，只能读不能写入或者删除，一个合并的线程会将它里面的内容刷新到磁盘上，产生一个大约 2M 大小的 **SSTable** 文件，并将其放在 level 0 层。



## Read Operation

对于读操作，LevelDB 首先会查询 memtable，接下来是 immutable memtable，然后依次查询 Level 中每一层的文件。确定一个随机的 key 的位置而需要搜索文件的次数的上界是由最大的层数来决定的，因为除了L0之外，每一层的所有文件中key的范围都是没有重叠的。 由于L0中文件的key的范围是有重叠的，所以在L0中进行查询时，可能会查询多个文件。为了降低查询操作的延迟，当L0层的文件数量超过8时，LevelDB 就会降低前台写操作的速度，这是为了等待合并线程将L0中的文件合并到L1中。



# 总结

所以， LSM 是日志和传统的单文件索引（B+ tree，Hash Index）的中立，他提供一个机制来管理更小的独立的索引文件(sstable)。

通过管理一组索引文件而不是单一的索引文件，LSM 将B+树等结构昂贵的随机IO变的更快，而代价就是读操作要处理大量的索引文件(sstable)而不是一个，另外还是一些IO被合并操作消耗。



## 延伸阅读

- There is a nice introductory post [here](https://www.open-open.com/misc/goto?guid=4959618820879705586).
- The LSM description in this [paper](https://www.open-open.com/misc/goto?guid=4959627135144797386) is great and it also discusses interesting extensions.
- These three posts provide a holistic coverage of the algorithm: [here](https://www.open-open.com/misc/goto?guid=4959627134870208906), [here](https://www.open-open.com/misc/goto?guid=4958194564427775209) and [here](https://www.open-open.com/misc/goto?guid=4959627135247720077).
- The original Log Structured Merge Tree paper [here](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.44.2782&rep=rep1&type=pdf). It is a little hard to follow in my opinion.
- The Big Table paper [here](https://www.open-open.com/misc/goto?guid=4958873484458891766) is excellent.
- [LSM vs Fractal Trees](https://www.open-open.com/misc/goto?guid=4959627135502848254) on High Scalability.
- Recent work on [Diff-Index](https://www.open-open.com/misc/goto?guid=4959627135592994533) which builds on the LSM concept.
- [Jay](https://www.open-open.com/misc/goto?guid=4959627135670624691) on SSDs and the benefits of LSM