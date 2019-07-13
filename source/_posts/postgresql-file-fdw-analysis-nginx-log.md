---
title: 使用postgresql的file-fdw扩展分析nginx日志
date: 2019-07-10 11:58:16
tags: [PostgreSQL, file-fdw, nginx, log]
---

# 原料

## PostgreSQL 方面
PostgreSQL的file_fdw使用说明：
[file_fdw 中文文档](http://www.postgres.cn/docs/11/file-fdw.html)

## nginx 方面
nginx 部分变量说明：
- $remote_addr  客户端IP
- $time_local   读起来不太舒服的时间
- $time_iso8601 比较舒服的时间
- $request_time 从accept到发完相应数据，耗费的时间，单位：秒
- $upstream_response_time   nginx收到请求交给其它应用处理并得到结果的时间，单位：秒
- $body_bytes_sent  响应包体的尺寸，单位：字节
- $request  请求描述
- $status   响应的状态码

**`$request_time`、`$upstream_response_time`的记录值不一定是数字，有时会是`-`**


# 操作

## Nginx
PostgreSQL对处理CSV比较擅长。所以我们要把nginx的日志定制成CSV的样子。

```conf
log_format  csv_log '$remote_addr, $time_iso8601, $request_time, $upstream_response_time, $body_bytes_sent, $request, $status';
```
在需要的server下应用这个格式，**要确保应用后的日志文件中只有一种格式的日志**。

## PostgreSQL
`psql` 进入

判断是否安装扩展：
```sql
\dx
                                     List of installed extensions
        Name        | Version |   Schema   |                        Description
--------------------+---------+------------+-----------------------------------------------------------
 file_fdw           | 1.0     | public     | foreign-data wrapper for flat file access
 
 
```
安装扩展：
```sql
create extension file_fdw
```
创建服务：
```sql
CREATE SERVER nginx_log FOREIGN DATA WRAPPER file_fdw;
```
创建外部表：
```sql
create foreign table app_log (
 ip inet,
 create_at timestamp with time zone,
 request_cost text,
 stream_cost text,
 body_size integer,
 request text,
 status integer
 ) server nginx_log options ( filename '/your/nginx/log/path/file.log', format 'csv');
```

体验：
```sql
select client_ip,create_at,request_cost,upstream_cost,pg_size_pretty(body_size::bigint) body_length,request from app_log where body_size>1024*1024;

  client_ip  |       create_at        | request_cost | upstream_cost | body_length |                           request
-------------+------------------------+--------------+---------------+-------------+--------------------------------------------------------------
 58.19.94.70 | 2019-07-09 11:05:37+08 |  0.984       |  0.113        | 1470 kB     |  GET /v4.3.1/sync/member_pockets?at=-999&sid=205118 HTTP/2.0
 58.19.94.70 | 2019-07-09 11:05:38+08 |  0.810       |  0.149        | 1470 kB     |  GET /v4.3.1/sync/member_pockets?at=-999&sid=205118 HTTP/2.0
(2 rows)

```
