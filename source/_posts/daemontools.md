---
title: daemontools系列小工具
date: 2017-06-17 14:17:12
tags: [daemontool, FreeBSD, supervisord]
---

# 前言

为什么要讲一个如此"古老"的守护工具？为什么不用supervisord？

`supervisord` 有个问题疼死我了。一远程管理一下它守护下的进程，[CPU就会100%](https://github.com/Supervisor/supervisor/issues/807)。这个问题年久失修。

它的supervisorctl里的指令，常reload一下会让所有的服务死了，自己也死了！也不重启，得手动重启。

更让人揪心的是，当业务负载繁重时，这个工具就成了"仙人掌"，碰不得，前段时间发现一次半夜里无端地持续了2个多小时把CPU提到了100%。

用了它可让阿里云破费了不少短信费。天天有警告！

不得已再花些时间学习了一下其它的守护工具了。这个daemontools偏老，看上去更稳妥。

以下实操基于FreeBSD11（Linux有systend，守护嘎嘎的！）

# 介绍

[Daemontools](http://cr.yp.to/daemontools.html)是管理Unix服务的工具，它提供一组工具来管理一系列用户进程，当进程由于某些原因down掉之后，daemontools会自动重启进程

# 注意

* 被管理的进程不能以daemon形式运行，例如nginx.conf 必须关闭daemon， daemon off;
* 不要在/var/service/建任何目录， /var/service/只存放一些symbol link
* 只需要完成安装 、 配置两步即可

# 安装启动

```bash
pkg install daemontools
echo 'svscan_enable="YES"' > /etc/rc.conf
service svscan start
```
启动成功多出了2个进程：

```text
root  7616   0.0  0.1   8344  1676  -  S    10:28     0:00.04 /usr/local/bin/svscan /var/service
root  7617   0.0  0.1   6240  1616  -  I    10:28     0:00.00 /usr/local/bin/readproctitle service errors: ......................................................................
```
`svscan`启动后监视`/var/service`目录，当这里有服务的软连接时，svscan会为每个服务主恸一个`supervise`服务。
`supervise` 执行服务目录下的`run`，如果服务目录下还有`down`文件存在，就不会自动启动，需人工手动启动此服务。

`supervise`的状态信息以2进制的形式存放在服务目录的`supervise`下面，并且提供了下面的工具来操作：

* svstat： 读取状态信息
* svc： 启动/停止/挂起等
* svok： 检查是否运行成功
* svscan：可靠的启动/var/service目录下的服务。如果某个服务加入后，没有启动，可以调用此命令，强制启动。

# 添加服务
## 普通添加
先创建一个测试用的需要被守护的项目。放到：`/var/server/testprocess/`
```text
root@freebsd:/var/server/testprocess # ll
total 12
-rwxr-xr-x  1 root  wheel  122 Jun 17 10:30 main.py*
-rwxr-xr-x  1 root  wheel  333 Jun 17 10:47 run*
root@freebsd:/var/server/testprocess # cat main.py
#!/usr/local/bin/python2
import time
import logging

while True:
    time.sleep(1)
    logging.warning("sleep 1 second")

root@freebsd:/var/server/testprocess # cat run
#!/bin/sh
exec /usr/local/bin/python2 /var/server/testprocess/main.py >> /tmp/main.py.log 2>&1
```
然后在`/var/service`目录下建立软链接
```bash
root@freebsd:/var/server/testprocess # ln -s /var/server/testprocess /var/service/testprocess
```
这个时候可以检查一下服务是否正在运行：
```test
root  7618  0.0  0.1   6252  1632  -  I    10:28     0:00.00 supervise testprocess
root  7747  0.0  0.4  39308  7416  -  S    10:48     0:00.72 /usr/local/bin/python2 /var/server/testprocess/main.py (python2.7)
```
上面这种方式的坏处是必须以root用户运行，如果想以其他用户运行，则需要做如下改进，假设用户为bluse，id为1001：

## 以指定用户身份运行

改进一下run的执行方式：
```text
root@freebsd:/var/server/testprocess # cat run
#!/bin/sh
who=`id -u`
if [ $who -eq 0 ]; then
    exec /usr/local/bin/setuidgid bluse /usr/local/bin/python2 /var/server/testprocess/main.py >> /tmp/main.py.log 2>&1
elif [ $who -eq 1001 ]; then
    exec /usr/local/bin/python2 /var/server/service/testprocess/main.py >> /tmp/main.py.log 2>&1
else
    echo "neither root or bluse"
fi
```
就可以了

# 管理服务

使用svstat来查看服务
```textmate
root@freebsd:/var/server/testprocess # svstat /var/server/testprocess/
/var/server/testprocess/: up (pid 7747) 2680 seconds
```

使用svc来管理服务
```textmate
NAME
       svc - controls services monitored by supervise(8).

SYNOPSIS
       svc [ -udopchaitkx ] services

DESCRIPTION
       services consists of any number of arguments, each argument naming a
       directory used by supervise(8).

       svc applies all the options to each service in turn.

OPTIONS
       -u     Up. If the service is not running, start it. If the service
              stops, restart it.

       -d     Down. If the service is running, send it a TERM signal and then
              a CONT signal. After it stops, do not restart it.

       -o     Once. If the service is not running, start it. Do not restart it
              if it stops.

       -p     Pause. Send the service a STOP signal.

       -c     Continue. Send the service a CONT signal.

       -h     Hangup. Send the service a HUP signal.

       -a     Alarm. Send the service an ALRM signal.

       -i     Interrupt. Send the service an INT signal.

       -t     Terminate. Send the service a TERM signal.

       -k     Kill. Send the service a KILL signal.

       -x     Exit.  supervise(8) will exit as soon as the service is down. If
              you use this option on a stable system, you're doing something
              wrong; supervise(8) is designed to run forever.
```

# daemontools 中的其它工具

log工具：

* The readproctitle program
* The multilog program
* The tai64n program
* The tai64nlocal program

环境工具：

* The setuidgid program
* The envuidgid program
* The envdir program
* The softlimit program
* The setlock program