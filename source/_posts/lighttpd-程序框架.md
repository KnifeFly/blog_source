---
title: lighttpd 程序框架
date: 2016-10-15 11:37:28
tags: lighttpd
---

由于历史的原因，公司部门在多个组件中使用了lighttpd，具体为何当时技术选型的时候没选nginx而选择lighttpd就不得而知了。lighttpd的社区相对nginx差距还是很大的，明显nginx的社区更活跃。lighttpd网上的资料以及第三方模块相对比较少，学习的成本会相对高一点。不过lighttpd的源码相对nginx会少一点，毕竟lighttpd比较轻量级，功能上没nginx那么多。网上nginx/lighttpd/appache 三种web server的测试结果，lighttpd占用内存最小，请求响应时间中等，apache最差。

## 进程模型
lighttpd采用master-worker进程模型，master进程主要负责加载配置、fork worker进程、管理worker进程，worker进程主要负责接收请求、处理请求、返回请求结果，worker进程个数可以在配置文件中配置，master进程会根据配置的个数，fork worker进程

<!-- more -->

master进程的主要逻辑：
- 根据命令行完成各种初始化工作
- daemonize
- fork 
- wait子进程(当子进程退出时，再fork出一个子进程)

主要逻辑代码：

```
num_childs = srv->srvconf.max_worker;
if (num_childs > 0) {
    int child = 0;
    //master进程上下文
    while (!child && !srv_shutdown && !graceful_shutdown) {
        if (num_childs > 0) {
            switch (fork()) {
            case -1:
                return -1;
            case 0:
                //worker进程在这里退出，执行后面的程序逻辑
                child = 1;
                break;
            default:
                num_childs--;
                break;
            }
        } else {
            int status;

            // master进程在这里阻塞等待，回收worker进程
            if (-1 != wait(&status)) {
                //如果一个worker进程挂了，master进程会重新fork一个worker进程
                num_childs++;
            } else {
                switch (errno) {
                case EINTR:
                    if (handle_sig_hup) {
                        handle_sig_hup = 0;

                        log_error_cycle(srv);
                        if (!forwarded_sig_hup && 0 != srv->srvconf.max_worker) {
                            forwarded_sig_hup = 1;
                            kill(0, SIGHUP);
                        }
                    }
                    break;
                default:
                    break;
                }
            }
        }
    }

    //master 进程在这里退出
    if (!child) {
        /** 
            * kill all children too 
            */
        if (graceful_shutdown) {
            kill(0, SIGINT);
        } else if (srv_shutdown) {
            kill(0, SIGTERM);
        }

        remove_pid_file(srv, &pid_fd);
        log_error_close(srv);
        network_close(srv);
        connections_free(srv);
        plugins_free(srv);
        server_free(srv);
        return 0;
    }
```

mater 进程的主要工作逻辑还是非常清晰的，简单的说就是早fork完子进程后，阻塞，监控子进程

worker进程的主要逻辑：
- 初始化event模型(select/poll/pselect...)
- 设置监听listen的套接字，注册listen套接字读写的回调函数
- while(1)大循环：
    1. 判断server服务是否终止,如果服务终止，删除pid文件、写日志、日志关闭、网络关闭等清理工作，然后程序退出;
    2. 如果server服务未终止，先判断是否存在SIGHUP信号，调用各个插件的handle_sighup函数;
    3. 判断是否产生了SIGALARM信号，若是执行各个插件的handle_trigger函数，再判断各个连接的超时;( 程序在处理连接超时的时候是每一秒中轮询所有的连接，判断其是否超时，这个效率其实低了);
    4. 判断连接是否失效以及服务是否过载;
    5. 启动事件轮询，等待各种IO事件的发生，包括文件读写，socket请求等，一旦有事件发生，调用相应的处理函数进行处理，这也是整个server逻辑最复杂的地方，根据连接状态机处理socket读写事件,lighttpd的事件模型以及插件模型需要再另外写篇文章来分析

主要逻辑代码：

```
    //启动事件轮询,等待各种IO时间的发生,包括文件读写，socket请求等
    if ((n = fdevent_poll(srv->ev, 1000)) > 0) {
        /* n is the number of events */
        int revents;
        int fd_ndx;
        last_active_ts = srv->cur_ts;
        fd_ndx = -1;
        do {
            fdevent_handler handler;
            void *context;

            fd_ndx  = fdevent_event_next_fdndx (srv->ev, fd_ndx);
            if (-1 == fd_ndx) break; /* not all fdevent handlers know how many fds got an event */

            revents = fdevent_event_get_revent (srv->ev, fd_ndx);
            fd      = fdevent_event_get_fd     (srv->ev, fd_ndx);
            handler = fdevent_get_handler(srv->ev, fd);
            context = fdevent_get_context(srv->ev, fd);

            //一旦有事件发生，调用相应的处理函数进行处理。
            if (NULL != handler) {
                (*handler)(srv, context, revents);
            }
        } while (--n > 0);
        fdevent_sched_run(srv, srv->ev);
    }
```
