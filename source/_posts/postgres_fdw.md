---
title: PostgreSQL 外部表
date: 2019-09-07 21:31:11
tags: [PostgreSQL, FDW, 外部表]
---

是时候用一下PG外部表了。这些年过去，这功能应该是稳定了的。
## 开启
首先确定contrib是否有安装。如果没有要先安装：
```bash
pkg install postgresql10-contrib
```
然后开启扩展
```sql
CREATE EXTENSION postgres_fdw;
```

## 创建远程服务
```sql
CREATE SERVER server156
  FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host '192.168.1.156',dbname 'bossdb',port '5432');
```
这里有个坑,就是如果192.168.1.156连不上的情况下上面语句也会执行成功.其实真正的连接到远程服务器是要等到后面dml执行时才会连接

## 创建用户映射
```sql
CREATE USER MAPPING FOR postgres
  SERVER server156
  OPTIONS (user 'postgres',password '000000');
```
这里如果输错了也不会知道。

## 创建远程表
```sql
CREATE FOREIGN TABLE if NOT EXISTS qbit_test (
  id INTEGER  ,
  name CHARACTER VARYING(50),
  class CHARACTER VARYING(50),
  time CHARACTER VARYING(50)
)
  SERVER server156
OPTIONS (schema_name 'public',table_name 'qbit_test');
```
