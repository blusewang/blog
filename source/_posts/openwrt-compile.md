---
title: 编译OpenWRT
date: 2020-03-10 16:28:31
tags: [openWRT, 编译]
---


之前编译OpenWRT时有很多顾虑。比如：

- 太多依赖，担心把自己MacOS装太多不明用处的包。将来无法清理
- 担心搞不懂编译过程中遇到的陌生概念。比如：出一个问题，google一下，得到了10个问题！
- 不知道编译结果是什么。如何把编译结果变成指定的系统镜像。不相信`make`能直接出镜像。

事实上，OpenWRT 团队是群非常实在的人！只需要一次`make`多版本的IMG镜像和选中的软件包。全编译出来并打好包，还整理得非常整齐！

[官方的中文编译说明](https://openwrt.org/zh-cn/doc/howto/build)这里展示了准备好后的编译过程。由此文可见，确实不难！当然，仅凭此一文，不足以指导完成编译！

下边记录一下我的编译经历。

# 规划
选择在虚拟机里编译。免得污染OS。
- 虚拟机选择VirtualBox；因为免费稳健。
- 编译OS，选择Alpine Linux；因为它小且便于安装。
    - OpenWRT编译支持几乎所有常见Linux发行版和MacOS。FreeBSD官方文档立了项，但没有写，就此略过。Windows没有看到相关文档。

## 注意事项

- 虚拟机尽量多给几个CPU核心，因为OpenWRT项目相当大！更多的核心能压缩编译时间。
- 虚拟机硬盘给15GB以上，最好20GB以上。
- 给装好的OS建立一个新用户。OpenWRT官方不推荐在`root`账号下编译。
- 源码中依赖的第三方库，多数在海外。一架舒适的小飞机，是理想的选择；甚至是必须！

## 要求
以下要求，不在本文探讨范围。
- 要会用VirtualBox。
- 要会安装Alpine Linux。
- 要会用git。理解分支和标签的概念和用法。
- 自备小飞机。

# 参考文档

- 虚拟机环境准备参考：[Build system – Installation](https://openwrt.org/docs/guide-developer/build-system/install-buildsystem)
- 编译过程及选项参考：[Build system – Usage](https://openwrt.org/docs/guide-developer/build-system/use-buildsystem)

# 重点提示：

- 环境准备，在装完OS后，其实很简单。只要在[Build system – Installation](https://openwrt.org/docs/guide-developer/build-system/install-buildsystem)文章中复制一下对应的安装指令，执行一下；再找个地方clone出源码即可。
- `git tag`查找需要的版本。`git checkout`需要的版本。
- `./scripts/feeds` feeds 指令是管理Apk（OpenWRT上的安装包）的。就像MacOS上的`brew`。在`menuconfig`之前值得更新一下，`./scripts/feeds update -a`。
 - 自己的安装包将来也是在这里创建和管理、编译。
- `make menuconfig` 有UI界面，可在UI界面上选择要编译的镜像的目标设备。如：选择`brcm2708`是`Raspberry Pi`类型的芯片，子类型对应`Raspberry Pi`的不同Model版本，如：`bcm2710`是`Raspberry Pi 3`的芯片型号。
- `make defconfig` 设置默认项
- `make kernel_menuconfig` 望文生义，内核配置，一般不需要。
- `make download` 下载源码编译过程中依赖的工具。
 - 在`make download`前，配置一下`wget`的`http_proxy``https_proxy``ftp_proxy`，并启用`proxy`。`wget`配置文件在：`/etc/wgetrc`
- `make` 
 - 参数`-j3`，就是3个线程并发编译，这个数字取决于CPU。
 - 参数`V=s`，是显示详细。
 - 参数`package/cups/compile`，是编译单个应用。

# 我的编译成果
## 固件特点
- 固件型号：	**Raspberry Pi 4 Model B Rev 1.2**
- 1GB 根空间。
- 镜像内置了USB转rj45驱动
- 默认支持`bbr`
- 支持`v2ray`，在配置好源后，`opkg install v2ray`就能得到。
- 编译了package中部分我认为常用的包。

## 固件源

固件下载、升级：[http://openwrt.mywsy.cn/targets/bcm27xx/bcm2711/](http://openwrt.mywsy.cn/targets/bcm27xx/bcm2711/)

`/etc/opkg/distfeeds.conf` 源配置：
```conf
src/gz jf_core http://openwrt.mywsy.cn/targets/bcm27xx/bcm2711/packages
src/gz jf_base http://openwrt.mywsy.cn/packages/aarch64_cortex-a72/base
src/gz jf_luci http://openwrt.mywsy.cn/packages/aarch64_cortex-a72/luci
src/gz jf_packages http://openwrt.mywsy.cn/packages/aarch64_cortex-a72/packages
src/gz jf_routing http://openwrt.mywsy.cn/packages/aarch64_cortex-a72/routing
src/gz jf_telephony http://openwrt.mywsy.cn/packages/aarch64_cortex-a72/telephony
```
