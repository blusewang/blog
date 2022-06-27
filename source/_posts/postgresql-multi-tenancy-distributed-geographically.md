---
title: PostgreSQL多租户按地域的分布式架构设计
date: 2022-06-27 11:32:33
tags: [PostgreSQL, 分布式]
---

# 设计目标
- 按用户所在地把用户按区域分组，将同一个区域的用户数据集中在当地的数据库中。
- 数据要按时间分表。能按月或按年，方便地处理数据，也能提高查询效率。
- 数据要集中化管理。不能把业务数据弄到不同的库中。最终要有个库中包括平台的所有数据。

# 设计
## 服务实例设计
```mermaid
graph LR
master[(主库)]
master-standby[(主库后备库)]
bj-item[(北京区域库)]
bj-item-standby[(北京区域后备库)]
sh-item[(上海区域库)]
sh-item-standby[(上海区域后备库)]

master -- 逻辑复制 --> bj-item
master -- 逻辑复制 --> sh-item
master -- 流复制 --> master-standby
bj-item -- 流复制 --> bj-item-standby
sh-item -- 流复制 --> sh-item-standby
```

## 数据库结构设计
```mermaid
graph LR
db[(主数据库)]
db --- public
db --- beijing
db --- shanghai

subgraph schema public
public --- public.table-a
public --- public.table-b
end

subgraph schema bejing
beijing --- beijing.table-a
beijing --- beijing.table-b
beijing.table-a --- beijing.table-a-2020-01
beijing.table-a --- beijing.table-a-2020-02
beijing.table-b --- beijing.table-b-2020-01
beijing.table-b --- beijing.table-b-2020-02
end

subgraph schema shanghai
shanghai --- shanghai.table-a
shanghai --- shanghai.table-b
shanghai.table-a --- shanghai.table-a-2020-01
shanghai.table-a --- shanghai.table-a-2020-02
shanghai.table-b --- shanghai.table-b-2020-01
shanghai.table-b --- shanghai.table-b-2020-02
end

beijing.table-a -. 继承 .-> public.table-a
beijing.table-b -. 继承 .-> public.table-b

shanghai.table-a -. 继承 .-> public.table-a
shanghai.table-b -. 继承 .-> public.table-b

shanghai -. 逻辑复制 .-> sh-db[(上海地域数据库)]
beijing -. 逻辑复制 .-> bj-db[(北京地域数据库)]

sh-db -- 流复制 --> sh-db-standby[(上海区域后备库)]
bj-db -- 流复制 --> bj-db-standby[(北京区域后备库)]
```

## 设计缺陷
- 地域之间的数据迁移
- 地域数据分裂（比如：把上海地区数据库的数据，分裂成：上海、杭州两个子地区）
