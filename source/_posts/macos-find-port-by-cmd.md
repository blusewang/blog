---
title: MacOS 命令查询网络端口占用情况
date: 2019-07-13 13:59:33
tags: [MacOS, lsof, netstat]
---

## netstat

> netstat -an | grep 80

## lsof

> lsof -i:80

> lsof -c nsqd