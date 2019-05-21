---
title: 理解Go Channel
date: 2018-05-23 21:21:46
tags: go
---


## 理解Go Channel

CSP 是 Communicating Sequential Process 的简称，中文可以叫做通信顺序进程，是一种并发编程模型，由 [Tony Hoare](https://en.wikipedia.org/wiki/Tony_Hoare) 于 1977 年提出。简单来说，CSP 模型由并发执行的实体（线程或者进程）所组成，实体之间通过发送消息进行通信，这里发送消息时使用的就是通道，或者叫 channel。CSP 模型的关键是关注 channel，而不关注发送消息的实体。Go 语言实现了 CSP 部分理论，goroutine 对应 CSP 中并发执行的实体，channel 也就对应着 CSP 中的 channel。

### Channel类型

```go
chan T          // 可以接收和发送类型为 T 的数据
chan<- float64  // 只可以用来发送 float64 类型的数据
<-chan int      // 只可以用来接收 int 类型的数据
```

<-总是优先和最左边的类型结合

```go
chan<- chan int    // 等价 chan<- (chan int)
chan<- <-chan int  // 等价 chan<- (<-chan int)
<-chan <-chan int  // 等价 <-chan (<-chan int)
chan (<-chan int)
```



### Channel创建

使用`make`初始化Channel,并且可以设置容量

```go
unBufferChan := make(chan int)  // 1
bufferChan := make(chan int, N) // 2
```

上面的方式 1 创建的是无缓冲 channel，方式 2 创建的是缓冲 channel。如果使用 channel 之前没有 make，会出现 dead lock 错误。

```
fatal error: all goroutines are asleep - deadlock!

goroutine 1 [chan receive (nil chan)]:
main.main()
	/Users/knife/Work/GoWorkplace/src/test/go.go:8 +0x4a

goroutine 4 [chan send (nil chan)]:
main.main.func1(0x0)
	/Users/knife/Work/GoWorkplace/src/test/go.go:6 +0x37
created by main.main
	/Users/knife/Work/GoWorkplace/src/test/go.go:5 +0x3e
exit status 2
```



### Channel发送和接收

```go
ch := make(chan int, 10)

// 读操作
x <- ch

// 写操作
ch <- x
```

channel 分为无缓冲 channel 和有缓冲 channel。

- 无缓冲：发送和接收动作是同时发生的。如果没有 goroutine 读取 channel （<- channel），则发送者 (channel <-) 会一直阻塞
- 缓冲：缓冲 channel 类似一个有容量的队列。当队列满的时候发送者会阻塞；当队列空的时候接收者会阻塞。



### Channel关闭

```go
ch := make(chan int)

// 关闭
close(ch)
```

- 重复关闭 channel 会导致 panic
- 向关闭的 channel 发送数据会 panic
- 从关闭的 channel 读数据不会 panic，读出 channel 中已有的数据之后再读就是 channel 类似的默认值，比如 chan int 类型的 channel 关闭之后读取到的值为 0

```go
ch := make(chan int, 10)
...
close(ch)

// ok-idiom 
val, ok := <-ch
if ok == false {
    // channel closed
}
```



### Channel Range

```go
func consumer(ch chan int) {
    ...
    for x := range ch {
        fmt.Println(x)
        ...
    }
}

func producer(ch chan int) {
  ...
  for _, v := range values {
      ch <- v
  }  
}
```



### Channel Select

select会一致阻塞直到有case满足条件，select通常和for循环一起用。for + select + time.After可以实现超时，time.After返回一个类型为`<-chan Time`的单向的channel

```go
for {
    select {
        case a <- ch1:
        	break
    	case b <- ch2:
        	break
        case <- time.After(2 * time.Second)
        	break
        default:
        	break
    }
}
```



### 参考
1. [Go Concurrency Patterns: Pipelines and cancellation](https://blog.golang.org/pipelines)
1. [Go Channel 详解](https://colobu.com/2016/04/14/Golang-Channels/)
2. [深入理解Go Channel](http://legendtkl.com/2017/07/30/understanding-golang-channel/)