---
title: 阿里云 FreeBSD 挂载云盘
date: 2021-08-03 16:02:25
tags: [FreeBSD, mount, 阿里云]
---

添加云盘后，重启ECS。在`/dev`下会多出一个`/dev/vtbd1`

- 分区
``` shell
gpart create -s GPT vtbd1
gpart add -t freebsd-ufs vtbd1
```

- 格式化
``` shell
newfs -U /dev/vtbd1p1
```

- 创建挂载点
``` shell
mkdir /data
```

- 写入`fstab`
``` shell
echo '/dev/vtbd1p1	/data	ufs	rw	2	2' >> /etc/fstab
```

- 手工挂载
``` shell
mount /data
```
