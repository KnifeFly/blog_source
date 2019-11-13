---
title: golang 性能调优
date: 2019-10-15 21:18:39
tags: go
---

## 优化前提

- 基础功能

- 架构设计

- 硬件资源

  

## 基本思路

​    思想同c/c++系统优化基本相同

- CPU密集型/IO密集型

  先分析程序是属于CPU密集型还是IO密集，如果是IO密集型，数据读写是否可使用内存盘、固态盘? 如果是CPU密集型，单线程程序是否可以改造成多线程?  多线程是否存在抢锁，或者同步?  是否可以减小锁粒度设置实现无锁设计

- 函数高频调用

  高频调用的函数性能能有所提升，基本上可直接提升程序的整体性能

- 锁粒度

  对于高性能计算程序，最好不要设计多线程抢锁的程序架构，如果锁设计不可避免那是否可以优化到减小锁粒度? 

- 线程池/协程池

  如果程序中存在大量创建线程的情况，可加一个线程池，减小创建线程的消耗在一定程序上可提高系统吞吐量。在Go中虽然创建协程开销很小，但是系统创建大量程序可能奔溃

- 对象池

  如果程序中不可避免的创建大量小对象，可用对象池来减小GC压力，类似内存池


<!--more-->

## Profiling

   Golang 提供的两个官方包 [runtime/pprof](https://golang.org/pkg/runtime/pprof/)，[net/http/pprof](https://golang.org/pkg/net/http/pprof/) 能方便的采集程序运行的堆栈、goroutine、内存分配和占用、io 等信息的 `.prof` 文件，可以使用 go tool pprof 分析 `.prof` 文件。两个包的作用是一样的，只是使用方式的差异。对于线上服务通常是使用[net/http/pprof](https://golang.org/pkg/net/http/pprof/) 通过暴露外部接口在必要时通过访问接口是profile; runtime/pprof可以在go test压测的时候用。

   通过profile可以查看cpu/heap/gorotinue/stack/threadcreate/block/mutex的信息



#### pprof示例: 

1. runtime pprof

通常用于一次性运行的profile分析

```go
import "runtime/pprof"
// ...

cpuProfile, _ := os.Create("cpu_profile")
pprof.StartCPUProfile(cpuProfile)
defer pprof.StopCPUProfile()

// ...

```



2. go test bench

go bench压测可生成cpu/mem的profile文件，压测时的profile分析

```shell
go test -bench . -benchmem -cpuprofile prof.cpu -memprofile prof.mem
```



3. http pprof

通常用于后台服务的profile分析

```go
package main
import
(
  "log"
  "net/http"
  _"net/http/pprof"
)

func goPprof(b *beat.BeatConfig) {
	go func() {
		if b.GlobalConfig.Port == "" {
			b.GlobalConfig.Port = beat.DefaultPort
		}

		s := fmt.Sprintf("0.0.0.0:%s", b.GlobalConfig.Port)
		http.ListenAndServe(s, nil)
	}()
}

func main()  {
   goPprof(c)
   //... 
}

```



#### pprof 实现

​    pprof不会实时采集程序数据，而是在pprof端口有访问的时候才会开始采集，所以在程序中开启pprof并不会实时采集导致程序性能下降。

1. http路由

```go
// net/http/pprof.go

func init() {
	http.HandleFunc("/debug/pprof/", Index)
	http.HandleFunc("/debug/pprof/cmdline", Cmdline)
	http.HandleFunc("/debug/pprof/profile", Profile)
	http.HandleFunc("/debug/pprof/symbol", Symbol)
	http.HandleFunc("/debug/pprof/trace", Trace)
}
```



2. 各种profile对应的采集方法

```go

// profiles records all registered profiles.
var profiles struct {
	mu sync.Mutex
	m  map[string]*Profile
}

var goroutineProfile = &Profile{
	name:  "goroutine",
	count: countGoroutine,
	write: writeGoroutine,
}

var threadcreateProfile = &Profile{
	name:  "threadcreate",
	count: countThreadCreate,
	write: writeThreadCreate,
}

var heapProfile = &Profile{
	name:  "heap",
	count: countHeap,
	write: writeHeap,
}

var blockProfile = &Profile{
	name:  "block",
	count: countBlock,
	write: writeBlock,
}

var mutexProfile = &Profile{
	name:  "mutex",
	count: countMutex,
	write: writeMutex,
}
```



### Profile 概览

​     通过访问debug/pprof/heap可以大体上掌握程序运行时状态，web访问示例:  http://ip:19194/debug/pprof

```go
/debug/pprof/

profiles:
0	block
345	goroutine
1142	heap
0	mutex
29	threadcreate

full goroutine stack dump
```

 

### pprof 详情

​     使用函数调用图/矢量图/动态top等手段来查看程序当前运行情况

​     [google pprof](<https://github.com/google/pprof>)相比go tool中字段的pprof工具会更好用，相比go tool pprof工具，该工具集成了更好的web功能，方便生成矢量图以及火焰图，如果用go tool pprof工具在生成火焰图时需要手动安装go torch组件

 

1. cpu（CPU Profiling）: `$HOST/debug/pprof/profile`，默认进行 30s 的 CPU Profiling，得到一个分析用的 profile 文件。报告程序的 CPU 使用情况，按照一定频率去采集应用程序在 CPU 和寄存器上面的数据

2. block（Block Profiling）：`$HOST/debug/pprof/block`，查看导致阻塞同步的堆栈跟踪。报告 goroutines 不在运行状态的情况，可以用来分析和查找死锁等性能瓶颈

3. goroutine：`$HOST/debug/pprof/goroutine`，查看当前所有运行的 goroutines 堆栈跟踪

4. heap（Memory Profiling）: `$HOST/debug/pprof/heap`，查看活动对象的内存分配情况

5. mutex（Mutex Profiling）：`$HOST/debug/pprof/mutex`，查看导致互斥锁的竞争持有者的堆栈跟踪

6. threadcreate：`$HOST/debug/pprof/threadcreate`，查看创建新OS线程的堆栈跟踪

   

##### CPU

  CPU: pprof -seconds=60 -http=":8081" ./logbeat http://ip:19194/debug/pprof/profile



  矢量图graph:

![image-20190505234653119](/Users/knife/Library/Application Support/typora-user-images/image-20190505234653119.png)

- flat：给定函数上运行耗时

- flat%：同上的 CPU 运行耗时总比例

- sum%：给定函数累积使用 CPU 总比例

- cum：当前函数加上它之上的调用运行总耗时

- cum%：同上的 CPU 运行耗时总比例

  

![image-20190506112408391](/Users/knife/Library/Application Support/typora-user-images/image-20190506112408391.png)



  CPU火焰图:

![image-20190506112138466](/Users/knife/Library/Application Support/typora-user-images/image-20190506112138466.png)



##### Heap

![image-20190517145840811](/Users/knife/Library/Application Support/typora-user-images/image-20190517145840811.png)





```go
// runtime.MemProfile()

heap profile: 5385: 280442048 [104285541: 1036510626632] @ heap/1048576
1: 115867648 [1: 115867648] @ 0x40a7d2 0x40a950 0x40d34e 0x74f629 0x74d6c6 0x7694ed 0x42dfb2 0x45b781
#	0x74f628	_/tmp/logbeat/beat.(*ConfigMap).load+0x348	/tmp/logbeat/beat/configMap.go:113
#	0x74d6c5	_/tmp/logbeat/beat.(*BeatConfig).Run+0xd5	/tmp/logbeat/beat/beatConfig.go:71
#	0x7694ec	main.main+0x27c					/tmp/logbeat/beat.go:88
#	0x42dfb1	runtime.main+0x211				/usr/local/go/src/runtime/proc.go:198

1: 57933824 [1: 57933824] @ 0x40a7d2 0x40a950 0x40d34e 0x74f629 0x74d6c6 0x7694ed 0x42dfb2 0x45b781
#	0x74f628	_/tmp/logbeat/beat.(*ConfigMap).load+0x348	/tmp/logbeat/beat/configMap.go:113
#	0x74d6c5	_/tmp/logbeat/beat.(*BeatConfig).Run+0xd5	/tmp/logbeat/beat/beatConfig.go:71
#	0x7694ec	main.main+0x27c					/tmp/logbeat/beat.go:88
#	0x42dfb1	runtime.main+0x211				/usr/local/go/src/runtime/proc.go:198

// 每行前几个数字的含义：
// 1: 57933824 [1: 57933824] 分别表示: 当前存活对象的数量: 存活对象已经占用的内存 [分配的总的数量: 所有分配已经占用的内存]

...

// runtime.ReadMemStats()

# runtime.MemStats
# Alloc = 3676961880
# TotalAlloc = 55069863469432
# Sys = 11084658696    //进程从系统获得的内存空间，虚拟地址空间
# Lookups = 6768278
# Mallocs = 99007906159
# Frees = 98982275533
# HeapAlloc = 3676961880 // 进程堆内存分配使用的空间，通常是用户new出来的堆对象，包含未被gc掉的
# HeapSys = 10563321856  // 进程从系统获得的堆内存，底层使用TCmalloc机制，会缓存一部分堆内存，虚拟地址空间
# HeapIdle = 6811181056   
# HeapInuse = 3752140800
# HeapReleased = 4199178240
# HeapObjects = 25630626
# Stack = 2588672 / 2588672
# MSpan = 49810248 / 110379008
# MCache = 10416 / 81920
# BuckHashSys = 1689317
# GCSys = 383721472
# OtherSys = 22876451
# NextGC = 6101847904
# LastGC = 1557067985391699853
# PauseNs = []   // 记录每次gc暂停的时间(纳秒)，最多记录256个最新记录
# PauseEnd = []
# NumGC = 17797  // 记录gc发生的次数
# NumForcedGC = 0
# GCCPUFraction = 0.035383945386859995
# DebugGC = false
```



##### Goroutine

```shell
pprof -seconds=60 -http=":8082" ./logbeat http://ip:19194/debug/pprof/goroutine
```



![image-20190520175255103](/Users/knife/Library/Application Support/typora-user-images/image-20190520175255103.png)



## 优化点

1. 字符串拼接效率低，采用buffer.WriteString
2. time.LoadLocation非常耗时，会打开时区文件进行解析
3. go map/slice 最好可预先分配大小
4. 尽量采用[]byte替代string，减少[]byte和string之间想换转换
5. goroutinue池代替大量创建goroutinue
6. 多用channel实现同步，尽量不用互斥锁



### 优化资料

1. <https://segmentfault.com/blog/qyuhen>
2. <https://segmentfault.com/a/1190000016354883>
3. <http://yangxikun.com/golang/2017/12/24/golang-profiling-optimizing.html>



