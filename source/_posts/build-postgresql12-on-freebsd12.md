---
title: 在FreeBSD12上编译PostgreSQL12
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
./configure --with-libraries=/usr/local/lib --with-includes=/usr/local/include --enable-thread-safety --disable-debug --with-openssl --with-llvm --prefix=/usr/local/pg12 --localstatedir=/var --build=amd64-bluse-freebsd12.0 build_alias=amd64-bluse-freebsd12.0 --with-uuid=bsd --with-icu --enable-nls='zh_CN'
make world
make install-world
```

- `--enable-thread-safety` 线程安全
- `--disable-debug` 禁用debug，该是有助于提升生产时运行性能
- `--with-openssl` 支持加密传输
- `--with-llvm` 支持即时编译，使得在处理复杂任务时，性能有望再提升20%～30%
- `--build` 编译平台，格式：硬件平台-编译方-系统平台。如：“x86_64-myName-freebsd12.0”
- `build_alias` 编译平台别名
- `--with-uuid` 在`FreeBSD`上选择`bsd`应该是最合适的
- `--with-icu` 支持排序
- `--enable-nls` 软件本地化。可指定多种语言。依赖`GNU`的`gettext`