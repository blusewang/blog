---
title: Ubuntu 上安装 PostgreSQL 10
date: 2018-04-09 17:46:11
tags: [Ubuntu, PostgreSQL, initdb]
---

## 目标
* 支持中文
* 自定义日志
* 初始密码

## 安装
先按[PostgreSQL](https://www.postgresql.org/download/linux/ubuntu/)官方指引在Ubuntu上安装好源
```bash
sudo apt install language-pack-zh-hans postgresql-10 postgresql-server-dev-10
sudo vim /etc/default/locale
# + LANG=zh_CN.utf8
sudo su - postgres
initdb data10 -E utf8 --locale=zh_CN.UTF-8
vim data10/postgresql.conf
```

