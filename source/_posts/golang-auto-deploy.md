---
title: golang项目的自动化部署
date: 2021-09-09 17:04:31
tags:[golang,部署]
---

在Go项目中。部署可以使用`Makefile`管理编译脚本、打包上传二进制至服务器的功能。

但在服务器上，如何自动在收到上传后自动停止服务，解压二进制包，替换旧二进制文件，再启动。这是个一直困扰我的问题。

在`Debian`上可以使用`systemd`的`service`脚本，实现守护，并实现启动前的预检测新包功能。

但`service`脚本无法感知到有新版的二进制包被上传。

想了很多办法，但都不如意：

- 采用用`Golang`写一个文件监测服务。杀鸡用了宰牛刀。

- 装自动化CI服务之类的，重且不说，业务分布在不同的主机，挨个安装部署太费精力。

- 装一个`git`服务。利用`git`的`Hook`触发部署。可将源码部署在生产主机上，不合适不说，还是要挨个主机装一个。

# 理想方案
今天偶然想到了`shell`查了一下。结果一下就通了。

首先在`Debian`上安装文件监测工具。`inotify-tools`

### 一个监控脚本：
```shell
#!/bin/bash
filename=$1
inotifywait -mq --format '%f' -e create $filename | while read file
do
	case $file in messager.tgz) service messager restart;;
	esac
	case $file in crmd.tgz) service crmd restart ;;
	esac
done
```

### 为这个监测脚本编写守护服务：
```shell
cat /usr/lib/systemd/system/watchdog.service
[Unit]
Description=Watch dog server

[Service]
Type=simple
Restart=always
User=root
Group=root
RestartSec=3
ExecStart=/usr/local/bin/watchdog /usr/local/bin

[Install]
WantedBy=multi-user.target

```
### 启动它

    `systemctl enable watchdog`
    `service watchdog start`

Done！现在只要在开发环境`make install`。服务器收到了二进制包，就会在无人执守的条件下，自动部署更新包。并重启！
