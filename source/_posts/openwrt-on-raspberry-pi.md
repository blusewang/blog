---
title: RaspberryPI上安装OpenWRT
date: 2019-12-04 21:20:25
tags: [RaspberryPi, OpenWRT]
---

# 设计
家用网络拓扑设计
![image](https://user-images.githubusercontent.com/1764005/70146001-3e2d6500-16dc-11ea-952c-dda05eb69029.png)

路由器连接RPI由网线接口。RPI连接电视由HDMI接口。

# 配件准备
唯独RPI连接路由器。额外需要一个 USB转网口。
淘宝之：
![image](https://gd4.alicdn.com/imgextra/i4/4282361926/O1CN0184Ycaa1Q69NjPfQVD_!!4282361926.png_400x400.jpg)
[树莓派USB2.0 HUB 网卡加hub 分线器转RJ45外置有线网卡 USB网口](https://item.taobao.com/item.htm?spm=a1z09.2.0.0.2b562e8d64yuA7&id=597724398426&_u=416uj6v1a71)

# 刷OS
OpenWRT 官方提供了详细的解说。
[OpenWrt Project: Raspberry Pi](https://openwrt.org/toh/raspberry_pi_foundation/raspberry_pi)

# 设置
启动后。通过web连接至OpenWRT。

## 设置USTC源
在【系统】-【软件包】-【配置】将软件源全替换为USTC源。
- [USTC配置帮助](https://mirrors.ustc.edu.cn/help/lede.html)
配置效果：
```text
src/gz openwrt_core http://mirrors.ustc.edu.cn/lede/releases/18.06.5/targets/arm_arm1176jzf-s_vfp/packages
src/gz openwrt_base http://mirrors.ustc.edu.cn/lede/releases/18.06.5/packages/arm_arm1176jzf-s_vfp/base
src/gz openwrt_luci http://mirrors.ustc.edu.cn/lede/releases/18.06.5/packages/arm_arm1176jzf-s_vfp/luci
src/gz openwrt_packages http://mirrors.ustc.edu.cn/lede/releases/18.06.5/packages/arm_arm1176jzf-s_vfp/packages
src/gz openwrt_routing http://mirrors.ustc.edu.cn/lede/releases/18.06.5/packages/arm_arm1176jzf-s_vfp/routing
src/gz openwrt_telephony http://mirrors.ustc.edu.cn/lede/releases/18.06.5/packages/arm_arm1176jzf-s_vfp/telephony
```

## 安装需要的包

- 中文语言包：luci-i18n-base-zh-cn
- USB转网口：kmod-usb-net-rtl8152
- 开启BBR：kmod-tcp-bbr

## 编译V2ray
v2ray的arm版对不同版本芯片支持不完整。辣么，自己动手！
查看芯片信息：`cat /proc/cpuinfo`
参考[手工构建](https://www.v2ray.com/developer/intro/compile.html#manualbuild)
参考[golang ARM芯片构建支持情况](https://github.com/golang/go/wiki/GoArm)
- 源码准备：`go get github.com/v2ray/v2ray-core`
- 编译`v2ray`：`GOPROXY=https://goproxy.io CGO_ENABLED=0 GOOS=linux GOARCH=arm GOARM=6 go build -o $HOME/v2ray -ldflags "-s -w"`
- 编译`v2ctl`：`GOPROXY=https://goproxy.io CGO_ENABLED=0 GOOS=linux GOARCH=arm GOARM=6 go build -o $HOME/v2ctl -ldflags "-s -w" -tags confonly `

