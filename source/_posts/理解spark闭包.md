---
title: 理解Spark闭包
date: 2018-05-21 19:15:39
tags: Spark
---


# 理解spark闭包

什么叫闭包： 跨作用域访问函数变量。又指的一个拥有许多变量和绑定了这些变量的环境的表达式（通常是一个函数），因而这些变量也是该表达式的一部分。

Spark闭包的问题引出： 
在spark中实现统计List(1,2,3)的和。如果使用下面的代码，程序打印的结果不是6，而是0。这个和我们编写单机程序的认识有很大不同。为什么呢？

```
object Test {
  def main(args:Array[String]):Unit = {
      val conf = new SparkConf().setAppName("test");
      val sc = new SparkContext(conf)

      val rdd = sc.parallelize(List(1,2,3))
      var counter = 0
      //warn: don't do this
      rdd.foreach(x => counter += x)
      println("Counter value: "+counter)

      sc.stop()
    }
}1234567891011121314
```

问题分析： 
counter是在foreach函数外部定义的，也就是在driver程序中定义，而foreach函数是属于rdd对象的，rdd函数的执行位置是各个worker节点（或者说worker进程），main函数是在driver节点上（或者说driver进程上）执行的，所以当counter变量在driver中定义，被在rdd中使用的时候，出现了变量的“跨域”问题，也就是闭包问题。

问题解释： 
对于上面程序中的counter变量，由于在`main函数`和在`rdd对象的foreach函数`是属于不同“闭包”的，所以，传进foreach中的counter是一个副本，初始值都为0。foreach中叠加的是counter的副本，不管副本如何变化，都不会影响到main函数中的counter，所以最终打印出来的counter为0.

当用户提交了一个用scala语言写的Spark程序，Spark框架会调用哪些组件呢？首先，这个Spark程序就是一个“Application”，程序里面的mian函数就是“Driver Program”， 前面已经讲到它的作用，只是，dirver程序的可能运行在客户端，也有可有可能运行在spark集群中，这取决于spark作业提交时参数的选定，比如，yarn-client和yarn-cluster就是分别运行在客户端和spark集群中。在driver程序中会有RDD对象的相关代码操作，比如下面代码的newRDD.map()

```
class Test{
  def main(args: Array[String]) {
    val sc = new SparkContext(new SparkConf())
    val newRDD = sc.textFile("")

    newRDD.map(data => {
      //do something
      println(data.toString)
    })
  }
}
```

涉及到RDD的代码，比如上面RDD的map操作，它们是在Worker节点上面运行的，所以spark会透明地帮用户把这些涉及到RDD操作的代码传给相应的worker节点。如果在RDD map函数中调用了在函数外部定义的对象，因为这些对象需要通过网络从driver所在节点传给其他的worker节点，所以要求这些类是可序列化的，比如在Java或者scala中实现Serializable类，除了java这种序列化机制，还可以选择其他方式，使得序列化工作更加高效。worker节点接收到程序之后，在spark资源管理器的指挥下运行RDD程序。不同worker节点之间的运行操作是并行的。

 在worker节点上所运行的RDD中代码的变量是保存在worker节点上面的，在spark编程中，很多时候用户需要在driver程序中进行相关数据操作之后把该数据传给RDD对象的方法以做进一步处理，这时候，spark框架会自动帮用户把这些数据通过网络传给相应的worker节点。除了这种以变量的形式定义传输数据到worker节点之外，spark还另外提供了两种机制，分别是broadcast和accumulator。相比于变量的方式，在一定场景下使用broadcast比较有优势，因为所广播的数据在每一个worker节点上面只存一个副本，而在spark算子中使用到的外部变量会在每一个用到它的task中保存一个副本，即使这些task在同一个节点上面。所以当数据量比较大的时候，建议使用广播而不是外部变量。



**理解闭包**

 

​      Spark中理解起来比较困难的一点是当代码在集群上运行时变量和方法的生命周期和作用域(scope)。当作用于RDD上的操作修改了超出它们作用域范围的变量时，会引起一些混淆。为了说明这个问题，使用下面的例子。该例中使用foreach()，对counter(计数器)进行增加，相同的问题也会发生在其他操作中。

 

 

**例子**

​      下面的例子在以本地模式运行(--master = local[n]) 和将它部署到集群中 (例如通过 spark-submit 提交到 YARN)对比发现会产生不同的结果。

```scala
var counter =  0 
var rdd = sc.parallelize(data)
// 错误,请不要这样做！！
rdd.foreach(x => counter += x)
println( "Counter value: "  + counter)
```



**本地模式 vs. 集群模式**

​      这里主要的挑战是上面代码的行为是有歧义的。以本地模式运行在单个JVM上，上面的代码会将RDD中的值进行累加，并且将它存储到counter中。这是因为RDD和变量counter在driver节点的相同内存空间中。
      然而，以集群模式运行时，会更加复杂，上面的代码的结果也许不会如我们预期的那样。当执行一个作业(job)时,Spark会将RDD分成多个任务(task)--每一个任务都会由一个executor来执行。在执行之前，Spark会计算闭包(closure)。闭包是对executors可见的那部分变量和方法，executors会用闭包来执行RDD上的计算(在这个例子中，闭包是foreach())。这个闭包是被序列化的，并且发送给每个executor。在本地模式中，只有一个executor，所以共享相同的闭包。然而，在集群模式中，就不是这样了。executors会运行在各自的worker节点中，每个executor都有闭包的一个复本。
      发送给每个executor的闭包中的变量其实也是复本。每个foreach函数中引用的counter不再是driver节点上的counter。当然，在driver节点的内存中仍然存在这一个counter，但是这个counter对于executors来说是不可见的。executors只能看到自己的闭包中的复本。这样，counter最后的值仍旧是0，因为所有在counter的操作只引用了序列化闭包中的值。
      为了在这样的场景中，确保这些行为正确，应该使用累加变量(Accumulator)。在集群中跨节点工作时，Spark中的累加变量提供了一种安全的机制来更新变量。所以可变的全局状态应该使用累加变量来定义。

所以上面的例子可以这样写：

```scala
// counter现在是累加变量
var counter = sc.accumulator( 0) 
var rdd = sc.parallelize(data) 
rdd.foreach(x => counter += x) 
println( "Counter value: " + counter)
```

