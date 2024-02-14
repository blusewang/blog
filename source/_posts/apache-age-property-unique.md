---
title: Apache AGE 给顶点的属性添加唯一索引
date: 2024-02-14 19:53:22
tags: [PostgreSQL,AGE,Apache]
---

Apache AGE create 节点时，添加的属性没有主键，只能采用唯一索引来约束数据，以防止重复。

添加方式不易记，特此记录成文章：
```SQL
create unique index on graph_name."label_name" (ag_catalog.agtype_access_operator(properties,'"property_name"'));
```