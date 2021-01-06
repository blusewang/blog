---
title: FreeBSD上使用tunnelbroker隧道支持ipv6
date: 2017-03-19 12:11:21
tags: [freebsd, nginx, ipv6, tunnelbroker]
---

# 起源
IOS被拒，原因又是`IPV6 only`网络下访问异常！

于是开始自检！

先检查了代码，没有使用只能用于ipv4的代码。

接口中也没有使用ipv4静态地址的请求。

那就是网络问题了！

先模拟了一下`ipv6`网络。成功配置了mac pro共享网络。访问了一下！没毛病！

那就是`IPV6 only`网络至ipv4，且走国际线路，这个有些特别了！
找了一下发现不少人吐嘈这个事，文章中甚至扬言要投靠`Android`^_^。
且有公司已经把优化国内IPV4至苹果公司的ipv6-only的网络做成服务，当生意做了。

这个问题自己解决就是给自己的服务器上加一个ipv6地址，就OK啦！
但现实太骨感，阿里云没有ipv6。只好通过其它途径了。比较合适的方案就是使用[tunnelbroker](https://tunnelbroker.net/)提供的ipv6隧道了。

# 动手
* 注册账号
* 验证邮箱
完成后，登录进去，在左侧的`User Functions`下`Create Regular Tunnel`创建一个常规的就好。

## 配置
创建完通道后，在`Tunnel Details`下有个`Example Configurations`标签，这里能按你的系统生成配置指令。
进去选择`Freebsd > 4.4`，得到：
```text
ifconfig gif0 create
ifconfig gif0 tunnel [我的IP] 209.51.161.14  #我服务器的IP 帮我转发的ipv4IP
ifconfig gif0 inet6 2001:470:1f06:1458::2 2001:470:1f06:1458::1 prefixlen 128       # 出隧道后，我在公网上的ipv6地址 隧道方的服务ipv6地址
route -n add -inet6 default 2001:470:1f06:1458::1
ifconfig gif0 up
```
进去执行掉
执行完后，`ifconfig`里就会多出来一个gif0设备。

FreeBSD的/etc/rc.conf增加配置，把禁止ipv6的项删去。
```text
# IPv6 Tunnel Client
ipv6_enable="YES"
gif_interfaces="gif0"
gifconfig_gif0="[我的IP] 209.51.161.14"
ipv6_ifconfig_gif0="2001:470:1f06:1458::2 2001:470:1f06:1458::1 prefixlen 128"
ipv6_defaultrouter="2001:470:1f06:1458::1"
 
# IPv6 Gateway
ipv6_config_nfe0="2001:470:1f07:1458::1 prefixlen 64"   #这个是路由地址：在‘Tunnel Details’ 里，是‘Routed IPv6 Prefixes’下的‘Routed /64’项。
ipv6_gateway_enable="YES"
rtadvd_enable="YES"
rtadvd_interfaces="nfe0"
```
这个需要rtadvd服务，`service rtadvd start`。

## nginx
FreeBSD处理ipv4与v6是两条不同的道。
所以在`nginx`里，要加上ipv6的监听，类似：
```text
listen 443 ssl;
listen [::]:443 ssl;
```
再`sysctl net.inet6.ip6.forwarding`一下，看看是否支持转发。
如果是0。就得放开！执行：`sysctl -w net.inet6.ip6.forwarding=1`。

## dns
进入DNSPOD给域名下加一条`AAAA`记录。地址用`2001:470:1f06:1458::2`。

# 检测
没有ipv6-only环境，怎么判断这一切生效了呢？只需打开浏览器访问：[`http://www.wangjunfeng.com.cn.ipv4.sixxs.org`](http://www.wangjunfeng.com.cn.ipv4.sixxs.org)。
这里`www.wangjunfeng.com.cn`就是要支持的网址了。如果正常打开。就OK了！
