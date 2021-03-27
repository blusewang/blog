---
title: linux常用Shell命令
date: 2021-01-18 14:07:48
tags: [shell]
---

- 找出指定文件夹下指定类型的所有文件，并全部删除
```shell
find /home/user/mydir -name *.png | xargs rm -f
```

- `cmake` 安装后,如何卸载
```shell
xargs rm < install_manifest.txt
```

- `tcpdump` 取得HTTP(非HTTPS)的GET请求`header`
```shell
tcpdump -i br-lan tcp and host wechat.xhlroi.com and 'tcp[((tcp[12:1] &0xf0) >> 2):4] = 0x47455420' -vv
```