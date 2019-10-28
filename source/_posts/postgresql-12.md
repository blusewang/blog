---
title: PostgreSQL 12 变更点评
date: 2019-10-28 17:08:33
tags: [PostgreSQL]
---

PostgreSQL 12 于2019年10月3日。之前只阅读了它的[中文概要说明](https://www.postgresql.org/about/press/presskit12/zh/#original_release) 
了解到了很多的性能提升。
 但在阅读[完整发行说明](https://www.postgresql.org/docs/12/release-12.html)后，了解到了更多的有用的变更。
 以下挑选一些我关心的，做一下介绍。

# 流复制和恢复

## 废弃了`recvoery.conf`。
- 将其功能并入了`postgresql.conf`。
- 使用`recovery.signal`或`standby.signal`文件来标记当前实例的状态。
- 使用`promove_trigger_file`参数 替代了旧的 `trigger_file`参数。
- 添加`pg_promote()`函数，可以在不操作文件系统的情况下，将从库，直接升级为主库。

## `pg_basebackup` 操作行为变更
使用`pg_basebackup -R ...`完成基准备份后，在备份好的数据文件夹中，没有了`recovery.conf`。
会多出一个`standby.signal`空文件。且在`postgresql.conf`中找不到 `primary_conninfo`项的配置。
此项配置会自动创建在`postgresql.auto.conf`文件中。


# 默认开启`JIT`

但在`FreeBSD 12.0`上，`pkg`包中，依旧默认选择保守地关闭了`JIT`支持。

# 授权控制

# 支持服务端核验证书域名
在`pg_hba.conf`中通过配置`clientcert=verify-full`实现。这让服务器更安全！完整地实现了SSL安全传输。从源头堵住了第三方通过非法证书连接服务！

# 性能

## `btee`增强
允许较小的多列`btree`索引，多列索引。提高了`btree`的索引性能和空间利用率。减少锁定开销，进一步提高了`btree`插入速度。

## 表分区增强
更好的分表性能

## `reindex` 支持 `concurently`
支持异步重建索引