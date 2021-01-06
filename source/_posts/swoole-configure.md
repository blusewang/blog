---
title: swoole 编译配置
date: 2017-06-05 13:57:12
tags: [PHP, Swoole]
---


./configure --enable-sockets --enable-openssl --enable-thread --enable-swoole --enable-ringbuffer --with-swoole --enable-picohttpparser --with-openssl-dir=/usr/local --with-jemalloc-dir=/usr/local


https://github.com/jemalloc/jemalloc

./configure --enable-autogen  --with-jemalloc-prefix=je_

make -j

sudo make install_bin install_include install_lib



https://github.com/h2o/picohttpparser

