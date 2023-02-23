---
title: CoreDNS 从零开始配置一个权威域名服务
date: 2023-02-23 06:12:56
tags: [dns, CoreDNS]
---

这里以阿里云为例

# 准备工作

## 购买一个域名

不同的域名在国内的解析速度是不一样的。如`.asia`在国内的解析基本有200ms+的延迟。而`.cn`只会在50ms左右。

实名之类的就不介绍了。

## 安装CoreDNS服务

`CoreDNS`是一个使用`Go`语言写的DNS服务器，它的特色是：一切功能皆插件，这让它特别灵活。

官网：https://coredns.io/

二进制下载：https://github.com/coredns/coredns/releases/latest

Go语言特点：AllInOne！下载下来就能直接运行了！

## 生成 DNSSEC & DS

### 安装`bind9-dnsutils`。

在`debian`上运行：`apt install bind9-dnsutils`即可！

### 创建 DNSSEC KEY

SHELL:

```shell
shell# dnssec-keygen -a RSASHA256 -b 1024 yourdomain.com
Generating key pair.........................................................+++++ .................+++++
Kyourdomain.com.+008+38686
# 这会创建两个文件：Kyourdomain.com.+008+38686.key  Kyourdomain.com.+008+38686.private
```

### 生成 DS

SHELL：

```shell
shell# dnssec-dsfromkey -1 Kyourdomain.com.+008+38686.key
yourdomain.com. IN DS 38686 8 1 AC800C2DA62B5073E2692B46DCDDE829D1B01BD0
# 参数`-1` 是指使用`SHA-1`签名
```

# 配置

## 设置阿里云DNS后台

进入买好的域名管理后台，`DNS管理`菜单下

### 自定义DNS Host

点击`创建DNS服务器`添加两条记录：

| DNS服务器             | 服务器IP地址     |
|--------------------|-------------|
| ns.yourdomain.com  | 88.88.88.88 |
| ns2.yourdomain.com | 99.99.99.99 |

### DNS修改

点击`修改DNS服务器`，添加两个DNS服务器：

- ns.yourdomain.com
- ns2.yourdomain.com

### DNSSEC设置

点击`添加DS记录`。按生成`DNSSEC` & `DS`的操作结果添加一条

| 关键标签  | 加密算法          | 摘要类型    | 摘要                                       |
|-------|---------------|---------|------------------------------------------|
| 38686 | 8-RSA/SHA-256 | 1-SHA-1 | AC800C2DA62B5073E2692B46DCDDE829D1B01BD0 |

## 配置DNS服务

同时在主、备服务器上做相同的配置

### 主配置文件： /etc/dns.conf

```conf
yourdomain.com {
	file /etc/dns/yourdomain.com.dns
	dnssec {
		key file /etc/dns/Kyourdomain.com.+008+38686
	}
	reload
	errors
	log
} 
```

### 域名数据库文件： /etc/dns/yourdomain.com.dns

```conf
$ORIGIN yourdomain.com.
@	3600	IN	SOA	ns.yourdomain.com. master.yourdomain.com. (
				14	;serial
				7200	;refresh
				3600	;retry
				129600	;expire
				3600	;minimum
				)
	3600	IN	NS	ns
	3600	IN	NS	ns2

@	3600	IN	A	8.8.8.8
ns	3600	IN	A	88.88.88.88
ns2	3600	IN	A	99.99.99.99
www	600	    IN	A	8.8.8.8
```

# 启动

## 直接式启动
`nohup coredns -conf /etc/dns.conf > /tmp/dns.log 2>&1 &`

## 配置到 SystemCtl
位置：/lib/systemd/system/coredns.service
```conf
[Unit]
Description=CoreDNS Server
After=network.target

[Service]
Type=simple
Restart=always
User=root
Group=root
RestartSec=3
ExecStart=/usr/local/bin/coredns -conf /etc/dns.conf

[Install]
WantedBy=multi-user.target
```
