---
title: kcptun 服务器配置说明
date: 2019-11-11 11:47:13
tags: [kcp, tun]
---

# 配置样例
```json
{
"listen": ":8888",
"target": "127.0.0.1:1080",
"key": "password",
"crypt": "salsa20",
"mode": "fast",
"mtu": 1400,
"sndwnd": 1024,
"rcvwnd": 1024,
"datashard": 10,
"parityshard": 3,
"dscp": 46,
"nocomp": true,
"acknodelay": false,
"sockbuf": 16777217,
"smuxbuf": 16777217,
"streambuf":16777217,
"smuxver": 2,
"keepalive": 10,
"pprof":false,
"quiet":true,
"tcp":false
}
```

# 配置说明

| 配项 |  值  | 说明 |
| :--- | :--- | :--- |
| listen | ":33523" | kcp server 开放的端口 |
| target | "127.0.0.1:33522"  | 本地shadowsocks 服务监听的端口 |
| key | "igwcwmtd" | |
| crypt | "salsa20" | salsa20对 arm芯片友好 |
| mode | "fast" | 如不是竟技游戏，`fast`足矣 |
| mtu | 1400 | 不重要，copy即可 |
| sndwnd | 1024 | 不要低于512，也不要过高 |
| rcvwnd | 1024 | 同上
| datashard | 10 | `datashard`和`partyshared` 两个数字的比，涉及到纠错理论， 3/10，实测没啥问题。过高的比重会过度放大流量 |
| parityshard | 3 | 同上 |
| dscp | 46 | 46 是紧急指针。让你的流量在网在公网上成为`VIP`|
| nocomp | true |  不压缩 |
| acknodelay | false | 不等待 |
| sockbuf | 16777217 | 以下三个`buf`是缓存，如果是手机，要设置小点，1～2M就好 |
| smuxbuf | 16777217 | 同上 |
| streambuf | 16777217 | 同上 |
| smuxver | 2 | 这里是多路复用的协议版本。选`2`，更优 |
| keepalive | 10 | |
| pprof | false | 这是debug，不需要 |
| quiet | true | 日志不需要太详细 |
| tcp | false | 是否伪装成`tcp`连接 |


## `mode` 特别说明

`mode` 项其实是 `nodelay`、`interval`、`resend`、`nc` 4项的一个组合。它们的对应关系是：

| mode | nodelay | interval | resend | nc |
| :--- | :--- | :--- | :--- | :--- |
| normal | 0 | 40 | 2 | 1 |
| fast | 0 | 30 | 2 | 1 |
| fast1 | 1 | 20 | 2 | 1 |
| fast2 | 1 | 10 | 2 | 1 |

如果不满意于自带的4个`mode`。可以将`mode`设置为`manual`。然后就能手动定制这4项参数了！
