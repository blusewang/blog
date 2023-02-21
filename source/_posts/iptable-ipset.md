---
title: 使用ipset配合iptable实现多IP段白名单式开放端口
date: 2023-02-22 00:53:06
tags: [iptable, ipset]
---

### 需求
总有海外及国内IDC机房的IP来源来骚扰我的数据库服务。
虽然配置了完善的`pg_hba.conf`规则，及要求了跨公网一律 `TLS` 安全传输。
但不断的来自公网的端口嗅探和骚扰。为了防止万一，这次打算通过`iptable`一次从根上解决！

### 安装
```bash
apt install ipset
```

### 配置
```bash
# 创建集合
ipset create cnip hash:net

# 添加IP或IP段
ipset add cnip 114.240.0.0/12

# 配置防护规则
## 如果有安装docker：
iptable -I DOCKER -m set ! --match-set cnip -p tcp --dport 5432 -j REJECT
## 如果没有安装docker
iptable -I INPUT -m set ! --match-set cnip -p tcp --dport 5432 -j REJECT

# 查看集合
ipset list cnip

# 删除集合
ipset desdroy cnip

# 删除集合中的项
ipset del cnip 114.240.0.0/12

# 查看集合中的项
ipset list cnip
```

### 附加资源
如果要按国家地区建立集合。各国的IP段数据源：

https://www.ipdeny.com/ipblocks/
