---
title: PostgreSQL BRIN索引 日志型数据索引神器
date: 2020-06-29 15:25:58
tags: [PostgreSQL,索引]
---

一张随着时间增长的表。当表的体积达到数GB或数十GB后。你会发现BTREE索引也也有数GB或数十GB；BTREE索引有时上是表尺寸的70%左右！

当索引的尺寸接近或超过系统内存一半时。查询使用了索引，速度也会慢到令人无法忍受！

此时一般的想法是：分表！将表按不同时间段拆开。这样查询时就不需要扫描整个索引了！速度就上来了。

其实，此时PostgreSQL还有个更有意思的索引，简直是从根本上重新定义了这个问题！它就是：

## `BRIN`索引
通过[`BRIN`索引的官方介绍](http://postgres.cn/docs/12/brin-intro.html)，得知，它的索引是完成另一种思路：

`BRIN`索引，是按写入磁盘的数据块，做索引的。它记录这张表，索引字段在这个数据块上的最大值与最小值；也叫这个字段的区间。

这就大大减少了索引的复杂度，提高了查询速度。

来具体体验一下：
```sql
cashier=> \dt+ log.table_name
                           关联列表
 架构模式 |    名称    |  类型  |  拥有者  |  大小   |  描述
----------+------------+--------+----------+---------+---------
 log      | table_name | 数据表 | postgres | 6908 MB | gdb应用
(1 行记录)

cashier=> \di+ log.table_name_log_at_idx
                                    关联列表
 架构模式 |         名称          | 类型 |  拥有者  |   数据表   |  大小  | 描述
----------+-----------------------+------+----------+------------+--------+------
 log      | table_name_log_at_idx | 索引 | postgres | table_name | 272 kB |
(1 行记录)

cashier=> explain analyze select count(1) from log.table_name where log_at between '2020-01-01 12:00:00' and '2020-01-01 12:01:00';
                                                                          QUERY PLAN
---------------------------------------------------------------------------------------------------------------------------------------------------------------
 Aggregate  (cost=15547.84..15547.85 rows=1 width=8) (actual time=46.691..46.700 rows=1 loops=1)
   ->  Bitmap Heap Scan on table_name  (cost=109.06..15547.55 rows=116 width=0) (actual time=3.063..46.153 rows=113 loops=1)
         Recheck Cond: ((log_at >= '2020-01-01 12:00:00+08'::timestamp with time zone) AND (log_at <= '2020-01-01 12:01:00+08'::timestamp with time zone))
         Rows Removed by Index Recheck: 124960
         Heap Blocks: lossy=3848
         ->  Bitmap Index Scan on table_name_log_at_idx  (cost=0.00..109.03 rows=4059 width=0) (actual time=1.384..1.389 rows=39680 loops=1)
               Index Cond: ((log_at >= '2020-01-01 12:00:00+08'::timestamp with time zone) AND (log_at <= '2020-01-01 12:01:00+08'::timestamp with time zone))
 Planning Time: 0.106 ms
 Execution Time: 46.797 ms
(9 行记录)

```
可见：在一张6.9GB数据的表上，按创建时间建`BRIN`索引，建成后，索引只有272KB！
在做中远距离的`between`查询。只要`46ms`！
