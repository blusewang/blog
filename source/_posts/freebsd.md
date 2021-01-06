---
title: FreeBSD 的日常
date: 2017-07-22 19:48:11
tags: [FreeBSD]
---

# 查看当前内核，编译时的参数

`sysctl kern.conftxt`

# 配置并编译新内核

```bash
cd /usr/src/sys/amd64/conf/
ee GENERIC
config GENERIC
cd ../compile/GENERIC/
make cleandepend && make depend
make
make install
```
# 从低版本内核升级至高版本

```bash
setenv UNAME_r "10.3-RELEASE"
freebsd-update -r 11.0-RELEASE upgrade
freebsd-update insatll
reboot
freebsd-update insatll
```
- 注册不能跨大版本。如：从10.1 -> 11.0 中间要经过10.3。 10.1 -> 10.3 -> 11.0
- 如果有定义自己内核，需先升级，再编译自己的配置。

# 给内核打补丁
```bash
freebsd-update fetch
freebsd-update install
```