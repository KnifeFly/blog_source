---
title: Linux信号安全处理
date: 2017-05-15 15:37:21
tags: Linux
---

## 信号处理机制

在 Linux 中，每个进程都拥有两个位向量，这两个位向量共同决定了进程将如何处理信号：
    - 在 Linux 中，每个进程都拥有两个位向量，这两个位向量共同决定了进程将如何处理信号：
    - 在 Linux 中，每个进程都拥有两个位向量，这两个位向量共同决定了进程将如何处理信号：

当内核发送一个信号给进程时，它将会修改进程的pending位向量，譬如说，当内核发送一个SIGINT信号给进程，那么它会将进程的pending[SIGINT]的值设置成 1。同样地，当进程屏蔽掉一个信号时，那么它会修改blocked位向量。当进程屏蔽掉一个信号之后，内核仍然可以发送这个信号给进程(保存在进程的pending位向量中)，但进程不会接收并处理这个信号。只有当进程解除了对这个信号的屏蔽之后，进程才会接收并处理这个信号。

下面的程序一开始就屏蔽了SIGINT信号，所以即使内核发送SIGINT信号给这个程序，这个信号也不会得到处理。而当程序解除了对SIGINT的屏蔽之后，这个SIGINT信号才会得到处理：

<!-- more -->


```c
#include <signal.h>
#include <unistd.h>
#include <string.h>
void sigint_handler(int sig)
{
    const char *message = "handle SIGINT signal\n";
    write(STDOUT_FILENO, message, strlen(message));
}

int main()
{
    signal(SIGINT, sigint_handler);
    sigset_t mask, prev_mask;
    sigemptyset(&mask);
    sigaddset(&mask, SIGINT);
    // 屏蔽掉 SIGINT 信号
    sigprocmask(SIG_BLOCK, &mask, &prev_mask);
    // 假设此时接收到 SIGINT 信号
    sleep(10);
    // 解除对 SIGINT 的屏蔽之后，进程会开始处理 SIGINT 信号
    sigprocmask(SIG_SETMASK, &prev_mask, NULL);
    return 0;
}
```

## 安全处理信号

- 当进程接收到某个信号时，会调用这个信号的 handler，这会中断主程序的执行。
- 当进程在执行某个信号 handler 的过程中，可能会被另一个信号 handler 中断。

上面这两种情况都会带来并发安全的问题，因此在编写信号 handler 时，需要考虑到并发安全的问题。譬如说，由于信号 handler 会中断主程序的执行，如果信号 handler 与主程序共享全局变量，就可能带来并发安全的问题。

信号 handler 与主程序共享全局变量是很常见的。譬如说，当进程在接收到SIGINT时，为了优雅地退出程序，这时可以使用一个全局变量记录是否接收到SIGINT信号。主程序每次进入循环时都会检查这个变量，如果发现进程接收到SIGINT信号，就释放好资源并退出程序

上面的代码并不是并发安全的，可能导致两个问题：
- 现代编译器通常会优化程序对变量的访问。主程序可能会将quit的副本存储在寄存器中，每次访问quit时就从寄存器中访问。那么即使信号 handler 修改了这个quit在内存中的值，主程序也可能不知道。

- 主程序会读取quit的值，信号 handler 会改变quit的值，而这两个操作都不保证是原子的

我们可以这样解决这两个问题：

- 首先将quit声明为volatile变量。volatile可以阻止编译器所做的优化，这样信号 handler 和主程序访问quit时都会从主内存中访问

- 首先将quit声明为volatile变量。volatile可以阻止编译器所做的优化，这样信号 handler 和主程序访问quit时都会从主内存中访问


```c
volatile sig_atomic_t quit = 0;
```

## I/O 多路复用与信号

在 Linux 中处理信号是极为麻烦的事情，正如 Linux 标准指出的，当select()、poll()和epoll_wait()被信号中断之后，它们是决不会重启的，所以说如果这些函数被信号中断，我们只好手动重启它们

```c
while (true) {
    int n = epoll_wait(/** ... **/);
    if (n == -1 && errno == EINTR) {
        continue;
    } else {
        // ...
    }
}
```

所幸的是 Linux 提供了signalfd()函数，signalfd()可以将接收到的信号，转化为文件描述符的可读事件，所以signalfd()可以和 select/poll/epoll 配合使用，大大简化信号处理的难度。

下面的例子将signalfd()与 epoll 配合使用，signalfd()负责将接收到的SIGINT和SIGHUP转换为文件描述符的可读事件：

```c
#include <unistd.h>
#include <string.h>
#include <sys/epoll.h>
#include <signal.h>
#include <sys/signalfd.h>
#include <stdbool.h>
#include <assert.h>
#include <stdio.h>

int main()
{
    // 屏蔽信号 SIGINT 和 SIGHUP
    sigset_t mask;
    sigemptyset(&mask);
    sigaddset(&mask, SIGINT);
    sigaddset(&mask, SIGHUP);
    sigprocmask(SIG_BLOCK, &mask, NULL);
    int signal_fd = signalfd(-1, &mask, SFD_NONBLOCK | SFD_CLOEXEC);
    int epoll_fd = epoll_create1(EPOLL_CLOEXEC);
    struct epoll_event event;
    memset(&event, 0, sizeof(event));
    event.events = EPOLLIN;
    event.data.fd = signal_fd;
    epoll_ctl(epoll_fd, EPOLL_CTL_ADD, signal_fd, &event);
    const int MAX_EVENTS = 64;
    struct epoll_event events[MAX_EVENTS];
    while (true)
    {
        int n = epoll_wait(epoll_fd, &events[0], MAX_EVENTS, 0);
        for (int i = 0; i < n; ++i)
        {
            if (events[i].data.fd == signal_fd)
            {
                struct signalfd_siginfo info;
                ssize_t bytes = read(signal_fd, &info, sizeof(info));
                assert(bytes == sizeof(info));
                if (info.ssi_signo == SIGINT)
                {
                    printf("receive signal SIGINT\n");
                }
                else if (info.ssi_signo == SIGHUP)
                {
                    printf("receive signal SIGHUP\n");
                }
                printf("Program quit!\n");
                return 0;
            }
        }
    }
    return 0;
}
```


参考资料：http://senlinzhan.github.io/2017/03/02/linux-signal/
