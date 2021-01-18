---
title: linux常用Shell命令
date: 2021-01-18 14:07:48
tags: [shell]
---

- 找出指定文件夹下指定类型的所有文件，并全部删除
```shell
find /home/user/mydir -name *.png | xargs rm -f
```
