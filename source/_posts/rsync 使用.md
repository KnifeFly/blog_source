---
title: Rsync使用
date: 2016-04-15 21:01:29
tags: linux
---

# Rsync 使用

1、服务端与客户端的定义

​    A机器向B机器发送数据，  或者A机器向B机器拉取数据

​    那么A均为客户端， B均为服务端

 

2、是否需要启动rsync服务

​    客户端不需要， 服务端需要

​    启动rsync进程： systemctl start rsyncd

​    设置rsync开机自启动： systemctl enable rsyncd

 

3、rsync相关配置

​    1）模块配置， 固定为/etc/rsyncd.conf, 权限644即可

​    2）用户密码配置， 可以在/etc/rsyncd.conf配置该文件路径， 推荐使用/etc/rsyncd.secret, 权限必须为600

​    3）日志回滚配置 /etc/logrotate.d/rsyncd.rotate， 按需添加

 

4、rsyncd.conf举例说明

> \###全局配置， 生效于每个模块， 并会被模块中相同的配置项覆盖
>
> uid = root
>
> gid = root
>
> use chroot = no
>
> pid file = /var/run/rsyncd.pid
>
> \#设置rsync用户密码配置文件路径
>
> secrets file = /etc/rsyncd.secret
>
> timeout = 300
>
> read only = yes
>
> write only = no
>
> \#设置最大连接数
>
> max connections = 2048
>
> dont compress = *.gz *.tgz *.zip *.z *.Z *.rpm *.deb *.bz2
>
> \#设置rsync日志文件， 若未设置， 则默认将日志写入syslog， 即/var/log/message，  当前版本的rsync不支持关闭日志， 所以若设置了该项， 记得添加日志回滚， 避免日志文件挤爆磁盘
>
> log file = /var/log/rsync.log
>
> syslog facility = local3
>
>  
>
> \###分模块配置， 注意rsync配置时，注释必须另起一行 
>
> \#模块名
>
> [test-module]
>
> \#模块根目录，注意该目录若不存在， rsync不会自动创建， 传输将报错
>
> path = /mylog/test/ori_data/
>
> \#设置为可写
>
> read only = no
>
> \#rsync用户名
>
> auth users = mylog



5、rsyncd.secret举例说明

格式为 用户名:密码 ， 例如

mylog:abc123

mylog2:abc456

 

6、rsync基础命令

在使用rsync传输之前， 需要在本机创建一个密码文件， 名称随意，例如命名为rsync.key， 权限必须是600， 并且内容只包含要使用的密码（例如 abc123）

1. 这条命令， 表示将本机/home/test/目录下的所有内容，使用模块test-module传输到192.168.1.2， 根据模块配置， 这些内容将被传输到/mylog/test/ori_data/目录下

   ```shell
   /bin/rsync-az–timeout=30–contimeout=15–password-file=rsync.key /home/test/ mylog@192.168.1.2::test-module
   ```

   

2. 注意这里/home/test/改为/home/test ， test-module模块名后面添加了一层子目录/test/ ， 这条命令表示将本机的/home/test目录本身， 使用模块test-module传输到192.168.1.2， 根据模块配置， 这些内容将被传输到/mylog/test/ori_data/test/目录下

   ```shell
   /bin/rsync-az–timeout=30–contimeout=15–password-file=rsync.key /home/test mylog@192.168.1.2::test-module/test/
   ```

   

3. 相比于第一条命令， 这里修改了最后两个参数的顺序， 表示从192.168.1.2拉取数据到本机的/home/test/目录下

   ```shell
   /bin/rsync-az–timeout=30–contimeout=15–password-file=rsync.key  mylog@192.168.1.2::test-module /home/test/
   ```