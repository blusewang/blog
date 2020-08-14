---
title: postgreSQL起步的最佳分布式：Citus
date: 2020-08-14 12:23:02
tags: [PostgreSQL, Citus]
---

对于一直工作在关系型数据库，且功能强大的PostgreSQL的开发者来说。
Citus 无疑是给他们插上了一对火箭！让关系型数据库的用户，也能翱翔在大数据的时代。

Citus 正在被很多大数据机构使用，日均更新5～10亿记录，甚至有在70个节点上，运行数据规模达1.4PB！

Citus 适用于多租户、实时分析场景。（这也正是我迫切需要的！）

下边介绍Citus的上手经历。

# 准备主机
分布式，至少两台以上主机。
- 协调节点，负责统筹。主机名：citus0
- 工作节点，负责存储计算。主机名：citus1、citus2

# 编译安装
在每一台机器上，按以下操作同样参数安装。
## 版本
- OS：FreeBSD-12.1-RELEASE-AMD64
-- https://www.freebsd.org/releases/12.1R/announce.html
- PostgreSQL：12.3
-- https://www.postgresql.org/ftp/source/v12.3/
- Citus：9.4.0
-- https://github.com/citusdata/citus/releases/tag/v9.4.0

## 编译参数
### PostgreSQL 12.3 编译
编译：
```shell script
kg install llvm90 gettext curl gmake
./configure '--with-libraries=/usr/local/lib' '--with-includes=/usr/local/include' '--enable-thread-safety' '--disable-debug' '--enable-nls' '--without-pam' '--with-openssl' '--without-llvm' '--without-gssapi' '--prefix=/usr/local' '--localstatedir=/var' '--mandir=/usr/local/man' '--infodir=/usr/local/share/info/' '--build=amd64-portbld-freebsd12.1' 'build_alias=amd64-portbld-freebsd12.1' 'CC=cc' 'CFLAGS=-O2 -pipe  -fstack-protector-strong -fno-strict-aliasing ' 'LDFLAGS= -L/usr/local/lib -lpthread -L/usr/local/lib  -fstack-protector-strong ' 'LIBS=' 'CPPFLAGS=-I/usr/local/include' 'CXX=c++' 'CXXFLAGS=-O2 -pipe -fstack-protector-strong -fno-strict-aliasing  ' 'CPP=cpp' 'PKG_CONFIG=pkgconf' 'LDFLAGS_SL='
make world
make install-world
adduser postgres
```

### Citus 9.4.0 编译
编译
```shell script
./configure 'LDFLAGS= -L/usr/local/lib -lpthread -L/usr/local/lib  -fstack-protector-strong ' CPPFLAGS=-I/usr/local/include
gmake
gmake install
```

# 设置并启用Citus
## 所有主机上的共同操作
注意：***以下所有操作都在要每个节点主机上完整操作完。包括建库和启用`citus`。且一定是先建库，进入`main`库后再启动`citus`扩展***
- 初始化数据库
```shell script
su postgres
initdb data
```
- 配置`postgresql.conf`
> listen_addresses = '*'
>
> port = 5432
>
>shared_buffers = 256MB # 按需调节
>
>shared_preload_libraries = 'citus' # 关键配置
>
- 配置`pg_hba.conf`
>host    all             all             192.168.1.1/24          trust  # 开放内网访问
>
- 启动PostgreSQL
```shell script
pg_ctl -D data start
```
- 建库并启用Citus
```shell script
psql
create database main;
\c main
create extension citus;
```

## 协调节点上的操作
```shell script
psql main
select master_add_node('citus1',5432);
select master_add_node('citus2',5432);

main=# select master_get_active_worker_nodes();
 master_get_active_worker_nodes
--------------------------------
 (citus1,5432)
 (citus2,5432)
(2 行记录)
```

# 使用Citus
现在只要在协调节点`citus0`上的`main`库中建表。所有工作节点都会自动创建分表。

在协调节点上存储会将数据分发到不同的工作节点上。查询也是在多个工作节点上分布查询了。