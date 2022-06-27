---
title: PostgreSQL跨系统主从后，出现查询时文本类条件无法命中的问题
date: 2022-06-27 10:48:44
tags: [PostgreSQL]
---

# 问题描述
- 当主服务运行在`FreeBSD`上，从服务运行在`Debian`上时，同样的编译参数，且都打开了`--with-icu`支持，连接到`Debian`上查询条件带文本的查询返回空。没有命中数据。
- 主服务调整到`Debian`，从服务调整到`Alpine`上后，表现一样。
- 主服务采用`zh_CN.UTF-8`编码初始化的数据库。配置中`lc`系列也同样使用的`zh_CN.UTF-8`。
`lc`系列配置：
```text
lc_messages = 'zh_CN.UTF-8'			# locale for system error message
					# strings
lc_monetary = 'zh_CN.UTF-8'			# locale for monetary formatting
lc_numeric = 'zh_CN.UTF-8'			# locale for number formatting
lc_time = 'zh_CN.UTF-8'				# locale for time formatting
```

主服务上：
```psql
core=# select openid from wx.fans where openid='oEG8Ss_yCRB315jjLfdTRK-QicdY';
            openid
------------------------------
 oEG8Ss_yCRB315jjLfdTRK-QicdY
(1 行记录)
```
从服务上：
```psql
core=# select openid from wx.fans where openid='oEG8Ss_yCRB315jjLfdTRK-QicdY';
 openid
--------
(0 行记录)
```

# 原因
因为：同样是`zh_CN.UTF-8`在不同`OS`上的`ICU`支持是不一样的。但如果使用`C`一般能避免这个问题。

从服务上没有命中，默认不报任何错误或警告。这个很诡异！如果指定条件的编码问题就能表现出来：
```psql
core=# select openid from wx.fans where openid='oEG8Ss_yCRB315jjLfdTRK-QicdY' COLLATE "zh_CN";
错误：排序规则"zh_CN"没有实际版本，但指定了版本
core=# select openid from wx.fans where openid='oEG8Ss_yCRB315jjLfdTRK-QicdY' COLLATE "C";
            openid
------------------------------
 oEG8Ss_yCRB315jjLfdTRK-QicdY
(1 行记录)
```
至于排序规则与版本之间的关系，我还没有进一步了解。这个问题暂时就研究到这里。
