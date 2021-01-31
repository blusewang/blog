---
title: FreeBSD上编译最新版 mosquitto
date: 2021-02-01 00:07:53
tags: [mosquitto, mqtt, PostgreSQL]
---

# MQTT服务器需求
- 支持Websocket
- 支持命令行输出json输出
- 支持通过PostgreSQL认证用户

# 源码

## mosquitto 资源

官网源码包下载地址： https://mosquitto.org/download/
- 当前最新版本2.0.6： https://mosquitto.org/files/source/mosquitto-2.0.6.tar.gz

## 官方推荐认证扩展
https://github.com/iegomez/mosquitto-go-auth

# 编译
## 编译 mosquitto

### 安装依赖：
- `cmake` 编译工具
- `libcjson` 命令行支持json格式输出依赖
- `libwebsockets` websocket依赖

```shell
pkg install cmake libcjson libwebsockets
```

### 解压源码包。配置`config.mk`
- WITH_WEBSOCKETS:=no -> yes
- WITH_CJSON:=yes

### 编译
```shell
gmake CFLAGS="-I/usr/local/include" LDFLAGS="-L/usr/local/lib"
gmake install
```

## 编译 mosquitto-go-auth

### 安装依赖：
- `go` 编译工具，此为`golang`源码

```shell
pkg install go
```

### 配置国内源
```shell
go env -w GO111MODULE=on
go env -w GOPROXY=https://goproxy.cn,direct
```

### 编译
```shell
gmake
```
