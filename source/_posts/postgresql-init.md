---
title: FreeBSD 上初始化 PostgreSQL 96
date: 2017-07-12 16:32:11
tags: [FreeBSD, PostgreSQL, initdb]
---

## 疼点
* `postgres` 这个用户名，打起来麻烦，不及`pgsql`方便。
* `initdb` 出来的库默认是英文的

## 设置

```bash
ee /etc/csh.cshrc

alias ll	ls -lAF
alias ls	ls -FG


setenv LANG         zh_CN.UTF-8
setenv LC_CTYPE     zh_CN.UTF-8
setenv LC_ALL       zh_CN.UTF-8
```

`adduser` pgsql

```bash
su pgsql
initdb data96 -E utf8 --locale=zh_CN.UTF-8
```

注：`pg_upgrade -d main/ -D /var/db/postgres/data96/ -b /var/server/pgsql94/bin/ -B /usr/local/bin/ -U pgsql`

这是一个成功率低、操作复杂、过程繁琐、环境要求高 的事情。

如果升级数据库，还是`pg_dump` `pg_restore`来得方便。

对于复杂关系的库，`pg_upgrade`也会出现主键丢失之类的奇怪事情。