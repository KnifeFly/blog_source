---
title: nginx 系统框架
date: 2017-07-15 20:35:19
tags: nginx
---

#  Nginx 进程模型

Nginx 进程模型采用master/worker进程模型，一个master进程，多个worker进程。master进程主要工作就是重载配置文件、监听信号(重载配置文件/重新打开日志文件等)、监控worker，而worker进程核心就是处理网络事件以及定时相关操作，maser和worker之间通信机制采用socketpair + 共享内存 + 信号，worker和worker之间通信机制采用socketpair通信。

---

## 1. Nginx启动流程

- 命令行参数解析，获取主配置文件路径等，ngx_process_options
- 各种初始化工作，调用各个模块create_conf和init_conf方法、创建pid文件、创建共享内存、监听套接字、调用各个模块init_module方法...，初始化工作主要在ngx_init_cycle这个函数中完成
- 注册各种信号处理函数，主要在ngx_init_signals函数中完成，在signals全局数组中保存了各种信号以及相应的信号处理函数
- 创建后台daemon进程
- 创建pid文件
- 根据启动参数判断启动哪种模式，master/worker进程模式则进入ngx_master_process_cycle函数

<!-- more -->

---

## 2. master进程

master进程的主要工作逻辑是在ngx_master_process_cycle函数中执行，大概的执行步骤：

- 阻塞各种信号，Nginx中有用到的信号基本都先屏蔽，目的主要是为了防止master在fork worker进程时受到干扰
- 按照配置文件中worker进程个数，fork相应个数的worker进程，每fork一个worker进程会向所有woker进程广播当前worker进程的进程信息(pid、socketfd)
- master进程进入主循环，sigsuspend挂起进程等待处理各种信号事件，主要处理以下事件：
  - 收到SIGCHLD信号，有worker进程异常退出，则重启之
  - 收到SIGTERM信号或者SIGINT信号，则通知所有worker退出，并且等待worker退出
  - 收到了SIGHUP信号, 重载配置文件
  - 收到SIGUSR1信号，重新打开log文件
  - 收到SIGUSR2信号，热代码替换
  - 收到SIGWINCH信号，不再接收请求，worker退出，master不退出

---

## 3.worker进程

worker进程主要工作逻辑在ngx_worker_process_cycle函数中完成，大概的执行步骤：

- woker初始化工作，根据全局的配置信息设置执行环境、优先级、限制、setgid、setuid、信号初始化等，在fork子进程之前，信号都被屏蔽了，所以在worker初始化时需要解除阻塞
- 调用所有模块的init_process钩子函数
- 关闭不会使用到的socket，关闭当前worker的channel[0]句柄和其他worker的channel[1]句柄。(当前worker会使用其他worker的channel[0]句柄发送消息，使用当前worker的channel[1]句柄监听可读事件)
- worker进程进入主循环
  - 判断是否关闭worker进程
  - 处理事件和定时器事件，ngx_process_events_and_timers()，worker核心部分
  - 处理maser进程发给worker进程的命令，master在收到信号后会给worker进程发送命令
    - 判断是否强制关闭进程(SIGTERM信号)
    - 判断是否优雅地关闭进程(SIGQUIT信号)
    - 判断是否重新打开文件(切换日志文件)(SIGUSR1信号)

----

## 4.master和worker通信

master和worker之间通信方式有channel机制  + 共享内存机制，master进程向worker发送命令采用的是无名管道的channel机制，这里简要介绍无名管道机制。

`int socketpair(int domain, int type, int protocol, int sv[2])`

无名管道机制是双工的，socketpair创建了一对无名的套接字描述符描述符存储于一个二元数组s[2] ，这对套接字可以进行双工通信，每一个描述符既可以读也可以写。这个在同一个进程中也可以进行通信，向s[0]中写入，就可以从s[1]中读取（只能从s[1]中读取），也可以在s[1]中写入，然后从s[0]中读取；但是，若没有在0端写入，而从1端读取，则1端的读取操作会阻塞，即使在1端写入，也不能从1读取，仍然阻塞，反之亦然......

在master进程fork worker进程的时候，也把这个套接字传给了worker，也就是说在master向worker的sv[0]写数据，那么worker便可以在自己的s[1]中读到数据。Nginx中主要是master向管道中写命令，worker从管道中读，命令主要有：

- NGX_CMD_QUIT
- NGX_CMD_TERMINATE
- NGX_CMD_REOPEN
- NGX_CMD_OPEN_CHANNEL
- NGX_CMD_CLOSE_CHANNEL
- NGX_CMD_PIPE_BROKEN

