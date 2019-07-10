---
title: PostgreSQL 性能优化
date: 2016-12-15 13:21:15
tags: [PostgreSQL, 性能优化]
---

    PostgreSQL 一个连接一个进程，应用给WEB服务就压力山大了。
    备点货以备山洪来临！


*以下整理自：[Sense's Blog](http://blog.gdsyzx.edu.cn/sense/?p=460#content)*


# 服务器参数配置

配置文件postgres.conf中的很多设置都会影响性能，

## shared_buffers

这是最重要的参数，postgresql通过shared_buffers和内核/磁盘打交道。

因此应该尽量大，让更多的数据缓存在shared_buffers中，通常设置为实际RAM的10％是合理的，比如50000(400M)

## work_mem

在pgsql 8.0之前叫做sort_mem。postgresql在执行排序操作时，

会根据work_mem的大小决定是否将一个大的结果集拆分为几个小的和work_mem查不多大小的临时文件。

显然拆分的结果是降低了排序的速度。因此增加work_mem有助于提高排序的速度。通常设置为实际RAM的2%-4%，根据需要排序结果集的大小而定，比如81920(80M)
## effective_cache_size

是postgresql能够使用的最大缓存，
这个数字对于独立的pgsql服务器而言应该足够大，比如4G的内存，可以设置为3.5G(437500)

## maintence_work_mem

这里定义的内存只是在CREATE INDEX, VACUUM等时用到，因此用到的频率不高，但是往往这些指令消耗比较多的资源，

因此应该尽快让这些指令快速执行完毕：给maintence_work_mem大的内存，比如512M(524288)

## max_connections

通常，max_connections的目的是防止max_connections * work_mem超出了实际内存大小。

比如，如果将work_mem设置为实际内存的2%大小，则在极端情况下，如果有50个查询都有排序要求，而且都使用2％的内存，则会导致swap的产生，系统性能就会大大降低。

当然，如果有4G的内存，同时出现50个如此大的查询的几率应该是很小的。不过，要清楚max_connections和work_mem的关系。

有关参数的解释可见： http://www.postgres.cn/docs/9.5/runtime-config.html

## 硬件的选择

由于计算机硬件大多数是兼容的，人们总是倾向于相信所有计算机硬件质量也是相同的。

事实上不是， ECC RAM（带奇偶校验的内存），SCSI （硬盘）和优质的主板比一些便宜货要更加可靠且具有更好的性能。

PostgreSQL几乎可以运行在任何硬件上，但如果可靠性和性能对你的系统很重要，你就需要全面的研究一下你的硬件配置了。

计算机硬件对性能的影响可浏览 http://candle.pha.pa.us/main/writings/pgsql/hw_performance/index.html 和 http://www.powerpostgresql.com/PerfList/。

## 连接时收到“Sorry, too many clients”消息？

这表示你已达到缺省100个并发后台进程数的限制，

你需要通过修改postgresql.conf文件中的max_connections值来 增加postmaster的后台并发处理数，修改后需重新启动postmaster。


# SQL查询

检查数据检索的索引是否建立，凡是需要查找的字段尽量建立索引，甚至是联合索引；

创建索引，包括表达式和部分索引；

使用COPY语句代替多个Insert语句；

将多个SQL语句组成一个事务以减少提交事务的开销；

从一个索引中提取多条记录时使用CLUSTER；

从一个查询结果中取出部分记录时使用LIMIT；

使用预编译式查询（Prepared Query)；

使用ANALYZE以保持精确的优化统计；

定期使用 VACUUM 或 pg_autovacuum

进行大量数据更改时先删除索引（然后重建索引）

# 程序经验

检查程序，是否使用了连接池，如果没有使用，尽快使用吧；

继续检查程序，连接使用后，是否交还给了连接池；

