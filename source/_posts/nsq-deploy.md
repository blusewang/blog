---
title: NSQ的部署
date: 2019-07-15 21:59:54
tags: [NSQ]
---

## 原料

- 系统：FreeBSD 12


### 安装
```csh
pkg install nsq
```

### 编写配置文件
- NSQ 配置文件样例：https://github.com/nsqio/nsq/tree/master/contrib
- 部署在`/usr/local/etc/`下
    - nsqd.conf
    - nsqlookup.conf
    - nsqadmin.conf

### 应用配置文件
在`/usr/local/etc/rc.d/`下找到对应的服务管理脚本。

会看到下面的头部：
```sh
#!/bin/sh

# $FreeBSD: branches/2019Q2/net/nsq/files/nsqd.in 454856 2017-11-24 23:17:50Z dbaio $
#
# PROVIDE: nsqd
# REQUIRE: LOGIN
# KEYWORD: shutdown

# Add the following lines to /etc/rc.conf to enable nsqd:
# nsqd_enable="YES"
# nsqd_args="<set as needed>"


```
在此将
```sh
# nsqd_enable="YES"
# nsqd_args="<set as needed>"
```
改为：
```sh
nsqd_enable="YES"
nsqd_args="--config=/usr/local/etc/nsqd.conf"
```

### 启动
`service nsqd start`
