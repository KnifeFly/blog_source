---
title: nginx 信号处理
date: 2017-09-15 11:37:28
tags: nginx
---

​	因为Nginx是利用信号来实现平滑升级、更换日志文件、配置文件实时生效、重启服务等功能的，所以在Nginx的启动过程中会向操作系统内核注册所使用到的信号，其代码实现如下

```c
int ngx_cdecl
main(int argc, char *const *argv)
{
    ……
    // 初始化信号
    if (ngx_init_signals(cycle->log) != NGX_OK) {
        return 1;
    }
    ……
}
```

<!-- more -->

​	signals是一个全局数组，保存的是ngx_signal_t数据类型，定义了各种信号信息以及处理函数，ngx_init_signals在程序main入口处调用，注册各种信号，ngx_init_signals()实现如下：

```c
ngx_int_t
ngx_init_signals(ngx_log_t *log)
{
    ngx_signal_t      *sig;
    struct sigaction   sa;  

    // 遍历signals数组，注册各种信号处理函数
    for (sig = signals; sig->signo != 0; sig++) {
        ngx_memzero(&sa, sizeof(struct sigaction));
        sa.sa_handler = sig->handler;  
        sigemptyset(&sa.sa_mask);
        //向内核注册信号的回调方法
        if (sigaction(sig->signo, &sa, NULL) == -1) {
			……
        }
    }
    return NGX_OK;
}
```

​	Nginx采用ngx_signal_t结构体来保存信号id 信号名称 信号处理函数，signals是一个ngx_signal_t类型的全局数组，用来保存各个信号的信息，不同信号的处理函数都是ngx_signal_handler，**ngx_signal_handler函数的逻辑主要是根据信号类型来设置不同的全局标志变量，ngx_terminate等全局标志变量都是sig_atomic_t数据类型，sig_atomic_t可以在操作系统层面提供的读写原子性，保证在对ngx_terminate变量的读的时候不会被信号中断，不过比较奇怪的是ngx_terminate变量没有添加volatile关键字，编译器会对优化变量的访问方式，如果ngx_terminate的赋值只是更改了寄存器中变量的值，而主循环中读的却是内存中的变量值，岂不是出问题？**

```c
// ngx_terminate的声明：
sig_atomic_t  ngx_sigalrm;
sig_atomic_t  ngx_terminate;
sig_atomic_t  ngx_quit;
....

// 信号处理函数大概逻辑
switch (signo) {
    case ngx_signal_value(NGX_SHUTDOWN_SIGNAL):
        ngx_quit = 1;
        action = ", shutting down";
        break;

    case ngx_signal_value(NGX_TERMINATE_SIGNAL):
    case SIGINT:
        ngx_terminate = 1;
        action = ", exiting";
        break;
    ...
    break;
```
​	nginx命令行启动中提供了参数-s参数来搞一些事情，例如stop/quit/reopen/reload，如果nginx进程已经起来了，则可以通过-s参数来给master进程发送信号来控制nginx。ngx_signal_process函数主要是读master进程的pid文件，获取进程的pid，最后给master进程发送相关信号。

```c
// 如果启动的进程，有信号相关的参数，则像已经存在的masrer进程发送信号，然后自己退出
if (ngx_signal) {
    return ngx_signal_process(cycle, ngx_signal);
}
```

​	在初始化流程中设置好了信号相关处理函数。**master进程在派生出worker进程之前会屏蔽一大堆信号，例如SIGCHLD/SIGALRM/SIGINT等，防止在创建worker进程时受到干扰，worker进程的ngx_worker_process_init初始化函数中会重新设置worker进程的信号屏蔽字，把屏蔽字设置为空以便worker进程也可以正常处理各种信号**。

​	master进程的主循环会在调用sigsuspend(&set)函数时阻塞，sigsuspend函数的功能主要是先用已经被清空的信号集代替当前进程中的信号集，然后阻塞等待信号，等信号处理函数返回之后会用老的信号屏蔽字替换新的信号屏蔽字。

​	master进程对信号的设置大概如下：

```c
// ngx_master_process_cycle 函数
...
sigemptyset(&set);
sigaddset(&set, SIGCHLD);
sigaddset(&set, SIGALRM);
sigaddset(&set, SIGIO);
sigaddset(&set, SIGINT);
sigaddset(&set, ngx_signal_value(NGX_RECONFIGURE_SIGNAL));
sigaddset(&set, ngx_signal_value(NGX_REOPEN_SIGNAL));
sigaddset(&set, ngx_signal_value(NGX_NOACCEPT_SIGNAL));
sigaddset(&set, ngx_signal_value(NGX_TERMINATE_SIGNAL));
sigaddset(&set, ngx_signal_value(NGX_SHUTDOWN_SIGNAL));
sigaddset(&set, ngx_signal_value(NGX_CHANGEBIN_SIGNAL));

//上面屏蔽一系列的信号，以防创建worker进程时，被打扰。
if (sigprocmask(SIG_BLOCK, &set, NULL) == -1) {
    ngx_log_error(NGX_LOG_ALERT, cycle->log, ngx_errno,
                  "sigprocmask() failed");
}
//清空信号集
sigemptyset(&set);
...
for(;;) {
	...        
	sigsuspend(&set); // 阻塞等待信号
}
```

​	worker进程对信号设置大概如下：

```c
// ngx_worker_process_cycle() -> ngx_worker_process_init()

// ngx_worker_process_init函数
...
// worker进程对从父进程继承而来的信号屏蔽字重新设置为空，以可以处理各种信号
sigemptyset(&set);

if (sigprocmask(SIG_SETMASK, &set, NULL) == -1) {
    ngx_log_error(NGX_LOG_ALERT, cycle->log, ngx_errno,
                  "sigprocmask() failed");
}
...
```

​	worker进程的主循环也会不停地检测各种信号全局标志变量，具体可参考nginx程序框架部分
