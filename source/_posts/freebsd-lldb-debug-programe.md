---
title: 解决FreeBSD上的程序崩溃
date: 2021-02-27 17:50:34
tags: [FreeBSD, lldb, mosquitto]
---

## 第一步:开启核心转储

```shell
kern.corefile=/var/db/coredump/%N.core
kern.coredump=1
kern.nodump_coredump=1
kern.sugid_coredump=1
```
当前设置,会让进程崩溃后,将核心转储至`/var/db/coredump/`文件夹下.

## 第二步:等待

定期检查`/var/log/message`文件,等待程序崩溃事件的到来.

## 第三步:调试
- 使用`lldb`打开`core`文件
```shell
lldb -c /var/db/coredump/mosquitto.core -- /usr/local/sbin/mosquitto
```
- 打开,进入后执行`bt`就看到详细错误了.非常简单.

过程如图:
![image](https://user-images.githubusercontent.com/1764005/109384031-354e3200-7925-11eb-802d-0ca220e55443.png)

这表明是`libgdb.so`扩展里,调用`strcmp`函数时,参数给错了!

so easy!~