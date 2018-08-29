---
title: linux 守护进程
date: 2016-01-15 12:11:22
tags: linux
---

# 守护进程
linux 服务端程序很多都是以守护进程的方式对外提供服务, linux 系统本身也有很多守护进程,例如kthreadd用来创建内核进程, kswapd是内存换页守护进程,flush是dump内存中的脏页面到磁盘,jbd提供ext4文件系统的日志日志功能...守护进程命名大部分都是以d结尾. 大部分守护进程都是以root方式运行,没有控制终端,运行在后台. 大部分守护进程都是进程组的组长进程以及会话的首进程,而且是进程组和会话中的唯一进程. 守护进程的父进程一般是系统1号进程,例如initd或者systemd.

# 编程规则
为了让守护进程在后台运行,减少不必要的交互,守护进程的编写有一套编程规则:
- umask将文件模式创建屏蔽字设置一个已知值,通常是0. 由于继承得来的文件模式屏蔽字可能会被设置为拒绝某些权限.
- fork() 然后父进程exit
    - 如果守护进程是以shell命令启动, 父进程exit会让shell认为这条命令已经执行完毕
    - 虽然子进程继承了父进程的进程组ID, 但获得了一个新的进程ID,这保证了子进程不是一个进程组的组长进程  (setid调用的条件)
- 调用setid创建一个新会话, 如果调用setsid的进程不是一个进程组的组长，此函数创建一个新的会话期setid,setid会让子进程执行三个步骤
    - 让子进程成为新会话的首进程
    - 让子进程成为新进程组的组长进程
    - 让子进程没有控制终端,如果在调用setsid前，该进程有控制终端，那么与该终端的联系被解除。 如果该进程是一个进程组的组长，此函数返回错误
    - 为了保证这一点，我们先调用fork()然后exit()，此时只有子进程在运行
- 再次fork, 这个步骤有些守护进程没有. 此时进程已经成为无终端的会话组长,但它可以重新申请打开一个控制终端,为了使进程不再成为会话组长来禁止进程重新打开控制终端, 再次fork然后父进程exit
- 设置工作目录为根目录, 从父进程继承过来的当前工作目录可能在一个挂载的文件系统中
- 关闭不再需要的文件描述符
- 打开/dev/null, 让文件描述符0 1 2都指向/dev/null
- 处理SIGCHLD信号, 处理SIGCHLD信号并不是必须的

<!-- more -->

APUE这本书中一个守护进程编程范例,不过一些程序实现守护进程的方式会省略一些步骤,相比这个范例会简单一些

```
void daemonize(const char *cmd)
{
    int                 i,fd0,fd1,fd2;
    pid_t               pid;
    struct              rlimit rl;
    struct sigaction    sa;

    //设置文件模式屏蔽字
    umask(0);

    if(getrlimit(RLIMIT_NOFILE,&rl)<0)
        err_quit("%s: can't get file limit ",cmd);

    //first blood :fork 一次，使父进程退出，让子进程成为孤儿进程，让子进程成为新会话的手进程，
 
    if ((pid=fork())<0)
        err_quit("%s:can't fork ",cmd);
    else if (pid!=0)
        exit(0);
    setsid();

    sa.sa_handler=SIG_IGN;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags=0;

    if(sigaction(SIGHUP,&sa,NULL)<0)
        err_quit("%s: can't ignore SIGHUP ",cmd);
    if((pid=fork())<0)
        err_quit("%s: fork error ",cmd);
    else if(pid!=0)
        exit(0);

    if(chdir("/")<0)
        err_quit("%s: can;t cahnge directory to /",cmd);

    if(rl.rlim_max==RLIM_INFINITY)
        rl.rlim_max=1024;
    for(i=0;i<rl.rlim_max;i++)
        close(i);

    fd0=open("/dev/null",O_RDWR);
    fd1=dup(0);
    fd2=dup(0);

    openlog(cmd,LOG_CONS,LOG_DAEMON);
    if(fd0!=0||fd1!=1||fd2!=2)
    {
        syslog(LOG_ERR,"unexpected file decription %d %d  %d",fd0,fd1,fd2);
        exit(1);
    }
}
```

Glibc库提供了创建守护进程API daemon, 函数原型为:
``` 
    int daemon(int nochdir, int noclose);
```
