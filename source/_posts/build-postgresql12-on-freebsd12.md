---
title: 在FreeBSD12上编译PostgreSQL12时报"readline header not found"的解决方案
date: 2019-10-23 17:37:40
tags: [FreeBSD, PostgreSQL]
---

## 问题
### 在`PostgreSQL12`源码里运行 `./configure`报：
```bash
checking for readline.h... no
configure: error: readline header not found
```
且`readline`库已经安装过了。
```bash
# pkg info readline
readline-8.0.0
Name           : readline
Version        : 8.0.0
```

原因是：`/usr/local/lib`和`/usr/local/include`不在`configure`脚本的搜索路径中。
可以通过`--with-includes`配置项加入进去就好了。
```bash
./configure --with-includes=/usr/local/include --with-libraries=/usr/local/lib
```

### `llvm-config`找不到
```bash
pkg install llvm90

ln -s /usr/local/bin/llvm-config90 /usr/local/bin/llvm-config
```

## 完整构建
```bash
./configure --prefix=/usr/local/pgsql12 --with-includes=/usr/local/include --with-libraries=/usr/local/lib --with-ossp-uuid --with-llvm --with-openssl --build=amd64-bluse-freebsd12.0
make world
make install-world
```