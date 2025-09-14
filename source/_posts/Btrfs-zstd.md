---
title: Btrfs+zstd压缩太棒了
date: 2025-09-14 13:33:50
tags: [debian, gnome, brtfs, zstd, macbook]
---

旧 `MacBook` 上装`Debian13`+`GNOME48`+`Btrfs`+`zstd` 让旧电脑焕发新机。100G的SSD抵200G用。

# 介绍

## GNOME 48 亮点

多年不用，GNOME 48已经和macOS体验很近了。

### 硬件支持
#### 硬件支持良好
- 蓝牙
- 夜灯
- 暗色样式
- 键盘灯
- 电源管理
- HDMI外接显示器
- 触摸板
  - 操作方式基本与MacBook一致

#### 也有部分支持不好的：
- SD卡槽
- 摄像头


### 系统表现
#### 优点
- wayland版的GNOME-shell，自成一体。让UI用户与OS级功能及数据更有边界。
- 内存占用小，只要1.5G左右内存
- 扩展非常开放
  - dash to dock 扩展，让托盘自由且美观
  - input method panel 扩展，让输入法融入UI
  - System Monitor 扩展，起到了类似鲁大师的监控功能，且成本低廉。
- 自带远程桌面（open RDP）
  - 支持远程连接到已登录的用户
  - 支持远程连接到系统远程登录到指定用户
- 共享
  - 文件共享 GVfsDav GNOME之间文件共享很便捷
  - 媒体共享 DLNA 直接对接到电视
- 截图返璞归真，只要按一下`PrintScreen`键。就能唤起OS级截图软件，截全屏、应用窗口、自定义区域，都行！

#### 不足
- 远程桌面RDP协议不够通用，使用windows自带的RDP可能连接不上，或提示登录失败
  - macOS要远程需要使用openRDP，结合XQuartz远程
- `GVfsDav` 基本算是私有协议，基本起不到通用共享的作用。
  - samba 协议不太符合Wayland哲学。要远程得自己装个webdav
- 休眠起来后常掉内核驱动，导致WIFI蓝牙不可用

# 高效的软件
## 数据时光机
使用`btrfs`+`zstd`压缩，配合`timeshift`应用，让快照非常方便，且基本 ***0成本*** 。`/etc/fstab`如下：
```text
UUID=d646870e-360a-4091-a27d-877d5711547e /               btrfs   noatime,compress=zstd,ssd,subvol=@ 0       0
UUID=d646870e-360a-4091-a27d-877d5711547e /root               btrfs   noatime,compress=zstd,ssd,subvol=@root 0       0
UUID=d646870e-360a-4091-a27d-877d5711547e /home               btrfs   noatime,compress=zstd,ssd,subvol=@home 0       0
UUID=d646870e-360a-4091-a27d-877d5711547e /opt               btrfs   noatime,compress=zstd,ssd,subvol=@opt 0       0
UUID=d646870e-360a-4091-a27d-877d5711547e /tmp               btrfs   noatime,compress=zstd,ssd,subvol=@tmp 0       0
UUID=d646870e-360a-4091-a27d-877d5711547e /var/log               btrfs   noatime,compress=zstd,ssd,subvol=@log 0       0
UUID=d646870e-360a-4091-a27d-877d5711547e /var/lib/postgresql               btrfs   noatime,compress=zstd,ssd,subvol=@pgdata 0       0
# /boot/efi was on /dev/sda1 during installation
UUID=500E-BC9E  /boot/efi       vfat    umask=0077      0       1
# swap was on /dev/sda3 during installation
UUID=6d1e83df-a76c-4a84-8446-8fba5d68f8b5 none            swap    sw              0       0
```
自定义分区，EFI分区只给100MB。少地。zstd压缩的基础上，再加上SSD的优化参数。

装完OS、chrome、docker 等。再跑个40GB的PG数据库。如果不使用btrfs就要占用 ***60GB*** 左右的空间。使用了`btrfs`压缩后。只占用 ***36.9GB***。立省 ***40%*** 空间。

再配合`timeshift`，想怎么折腾就怎么折腾。0成本快照，出问题，随时会滚。再也不怕污染了系统文件！
