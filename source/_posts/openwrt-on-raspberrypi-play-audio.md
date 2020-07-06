---
title: OpenWRT 在 RaspberryPI 播放音频
date: 2020-07-06 12:46:57
tags: [OpenWRT, RaspberryPi, 音频]
---

RaspberryPI 不只能满足路由计算需要，还能用于多媒体，如：插上音箱放音乐！

# OpenWrt编译要求
## 内核驱动类要求：
- Kernel modules > Sound Support > kmod-sound-core
- Kernel modules > Sound Support > kmod-sound-arm-bcm2835
## 软件要求
- Sound > alsa-utils
- Sound > madplay

# Raspberry PI 设置
## 开放设备
在 `/boot/config.txt` 里添加如下行：
```text
dtparam=audio=on
```
使Raspberry PI开放音频硬件。不然有驱动程序，但找不到音频设备！
## 设置音频输出
通过`amixer`命令完成：

`$ amixer cset numid=3 1` ：指定音频输出接口为 3.5mm 耳机接口
`$ amixer cset numid=3 2` ：指定音频输出接口为 HDMI

# 使用
```shell script
$ madplay music.mp3
  MPEG Audio Decoder 0.15.2 (beta) - Copyright (C) 2000-2004 Robert Leslie et al.
```
