---
title: OpenWRT实现内网tcp连接请求整形 搭建逼真开发环境
date: 2020-08-04 17:20:41
tags: [ip6tables, ipv6, OpenWRT]
---

# 开发环境
## 头疼的配置
开发者本地开发一款网络应用时，一般是在测试时，使用测试域名/IP。发布时使用正式域名/IP。

看似简单的小操作。但在多轮迭代时，这个小操作一但出错，会出大问题。

如果开发环境配置与生产环境完全一样，那就省事许多。

在有自己可控的内网路由情况下，实现起来，一般有两种方式：DNS劫持、IP劫持。

## DNS劫持
只需在登入OpenWRT后，把域名新的解析写入 `/etc/hosts` 。再 `/etc/init.d/dnsmasq reload` 重载一下`dnsmasq`就好了。简单好用！

## IP劫持
这个相对复杂一些。因为在OpenWRT的 `网络 - 防火墙 - NAT 规则` 只支持重写源地址，不支持重写目标地址。

这就得手动写`网络 - 防火墙 - 自定义规则`了！
### IPv4劫持
IPv4的规则直接写就可以，例如：
```shell script
iptables -t nat -A PREROUTING -i br-lan -d 1.2.3.4 -p tcp -m tcp --dport 443 -m comment --comment "dev" -j DNAT --to-destination 192.168.1.2:443
```

### IPv6劫持
IPv6就麻烦些了。因为IPv6设计目标就是弃用`NAT`（因为有几乎无穷的地址资源）。
虽然按标准应该不用，但依旧有`热心人`对它进行了实现。

在`系统 - 软件包`里搜索并安装：`kmod-ipt-nat` `ip6tables-mod-nat`。这就具备了对IPv6进行`NAT`的能力了！

但不能直接写规则；需先开启发住内网的v6的伪装。例如：
```shell script
ip6tables -t nat -I POSTROUTING -o br-lan -j MASQUERADE
```
再给从内网发出的包写具体规则；例如：
```shell script
ip6tables -t nat -A PREROUTING -i br-lan -d 2408:4002:xx::xx -p tcp -m tcp --dport 443 -m comment --comment "dev" -j DNAT --to-destination [2408:8207:xx:xx::2]:443
```
