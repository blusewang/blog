---
title: truss lsof strace ltrace 让你知道系统运行中的进程正在干什么
date: 2017-06-12 16:32:11
tags: [FreeBSD, 运维, 性能]
---
#truss
这个命令一般UNIX平台自带。使用举例：
```text
[bluse@ybcz ~/vhosts/bluse]$ sudo truss -p48932
clock_gettime(4,{334689.597960013 })		 = 0 (0x0)
clock_gettime(4,{334689.598165067 })		 = 0 (0x0)
clock_gettime(4,{334689.598310337 })		 = 0 (0x0)
gettimeofday({1480832080.977889 },0x0)		 = 0 (0x0)
write(14,"*3\r\n$4\r\nhget\r\n$14\r\nstate"...,54) = 54 (0x36)
write(14,"*3\r\n$4\r\nhget\r\n$14\r\nstate"...,52) = 52 (0x34)
write(14,"*3\r\n$4\r\nhget\r\n$14\r\nstate"...,56) = 56 (0x38)
write(14,"*3\r\n$4\r\nhget\r\n$14\r\nstate"...,55) = 55 (0x37)
write(14,"*3\r\n$4\r\nhget\r\n$14\r\nstate"...,50) = 50 (0x32)
write(14,"*3\r\n$4\r\nhget\r\n$14\r\nstate"...,55) = 55 (0x37)
write(14,"*3\r\n$4\r\nhget\r\n$14\r\nstate"...,54) = 54 (0x36)
write(14,"*3\r\n$4\r\nhget\r\n$14\r\nstate"...,47) = 47 (0x2f)
clock_gettime(4,{334689.600967100 })		 = 0 (0x0)
gettimeofday({1480832080.980523 },0x0)		 = 0 (0x0)
gettimeofday({1480832080.980791 },0x0)		 = 0 (0x0)
write(14,"*3\r\n$4\r\nhget\r\n$14\r\nstate"...,52) = 52 (0x34)
write(14,"*3\r\n$4\r\nhget\r\n$14\r\nstate"...,50) = 50 (0x32)
write(14,"*3\r\n$4\r\nhget\r\n$14\r\nstate"...,49) = 49 (0x31)
write(14,"*3\r\n$4\r\nhget\r\n$14\r\nstate"...,46) = 46 (0x2e)
write(14,"*3\r\n$4\r\nhget\r\n$14\r\nstate"...,45) = 45 (0x2d)
write(14,"*3\r\n$4\r\nhget\r\n$14\r\nstate"...,49) = 49 (0x31)
write(14,"*3\r\n$4\r\nhget\r\n$14\r\nstate"...,46) = 46 (0x2e)
write(14,"*3\r\n$4\r\nhget\r\n$14\r\nstate"...,46) = 46 (0x2e)

```
这是实时查看。也可以：
```text
truss -p 48932 -o out.truss
```
把结果输出至文件中。捕获一断时间后再细分析。

这个命令能让你很方便地看清异常位置。如：死循环、某些未写入日志的异常等。

很适合用来解决CPU占用过高、难定位的异常、难重现的异常等 。

#lsof
这个linux/unix都好使。它有两个方面好使。

- 按端口查连接
```text
bluse@bluse-Inspiron-1427:~/www/vhost$ lsof -i:80
COMMAND    PID  USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
cairo-doc 3059 bluse   24u  IPv4  95707      0t0  TCP 192.168.1.102:40728->ec2-35-162-44-96.us-west-2.compute.amazonaws.com:http (ESTABLISHED)
xmradio   3425 bluse   13u  IPv4  96506      0t0  TCP 192.168.1.102:48640->202.108.249.250:http (ESTABLISHED)
xmradio   3425 bluse   14u  IPv4  90643      0t0  TCP 192.168.1.102:57590->140.205.220.98:http (CLOSE_WAIT)
gvfsd-htt 3450 bluse   10u  IPv4  95783      0t0  TCP 192.168.1.102:55522->123.125.7.240:http (ESTABLISHED)
chrome    3967 bluse  162u  IPv4  95526      0t0  TCP 192.168.1.102:58632->128.199.228.91:http (ESTABLISHED)
chrome    3967 bluse  202u  IPv4  95527      0t0  TCP 192.168.1.102:58634->128.199.228.91:http (ESTABLISHED)
chrome    3967 bluse  228u  IPv4  91831      0t0  TCP 192.168.1.102:58714->151.101.52.249:http (ESTABLISHED)
```
- 按进程PID查文件调用
```text
bluse@bluse-Inspiron-1427:~/www/vhost$ lsof -p 3425
COMMAND  PID  USER   FD      TYPE             DEVICE SIZE/OFF     NODE NAME
xmradio 3425 bluse  cwd       DIR                8,1     4096   262146 /home/bluse
xmradio 3425 bluse  rtd       DIR                8,1     4096        2 /
xmradio 3425 bluse  txt       REG                8,1    14664 21375342 /usr/bin/xmradio
xmradio 3425 bluse  mem       REG               0,19 67108904       15 /dev/shm/pulse-shm-1137957205
xmradio 3425 bluse  mem       REG                8,1    10256 21435409 /usr/lib/vlc/plugins/audio_filter/libtrivial_channel_mixer_plugin.so
xmradio 3425 bluse  mem       REG                8,1    34920 21435412 /usr/lib/vlc/plugins/audio_filter/libaudio_format_plugin.so
xmradio 3425 bluse  mem       REG                8,1    10272 21435429 /usr/lib/vlc/plugins/audio_filter/libugly_resampler_plugin.so
xmradio 3425 bluse  mem       REG                8,1    10280 21435410 /usr/lib/vlc/plugins/audio_filter/libdolby_surround_decoder_plugin.so
xmradio 3425 bluse  mem       REG                8,1    10320 21435419 /usr/lib/vlc/plugins/audio_filter/libdtstospdif_plugin.so
xmradio 3425 bluse  mem       REG                8,1    18472 21435431 /usr/lib/vlc/plugins/audio_filter/libsimple_channel_mixer_plugin.so
xmradio 3425 bluse  mem       REG                8,1     6176 21435428 /usr/lib/vlc/plugins/audio_filter/liba52tospdif_plugin.so
xmradio 3425 bluse  mem       REG               0,19 67108904        7 /dev/shm/pulse-shm-3282743321
xmradio 3425 bluse  mem       REG                8,1  4343844 22414964 /usr/share/fonts/truetype/nanum/NanumGothic.ttf
```
#strace
它的用法也差不多：
```text
strace -f -o vim.strace vim： 跟踪vim及其子进程的运行，将输出信息写到文件vim.strace。
```
进程调试
```text
bluse@bluse-Inspiron-1427:~/www/vhost$ sudo strace -o out.strace lsof -p 3425
bluse@bluse-Inspiron-1427:~/www/vhost$ head -10 out.strace 
execve("/usr/bin/lsof", ["lsof", "-p", "3425"], [/* 26 vars */]) = 0
brk(NULL)                               = 0x562c9956b000
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
mmap(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f29b0751000
access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or directory)
open("/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3
fstat(3, {st_mode=S_IFREG|0644, st_size=188234, ...}) = 0
mmap(NULL, 188234, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7f29b0723000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)

```
##htop 中使用 strace
htop中内置了strace

进入`htop`后按上下方向键选择进程，在需要调试的进程上按`s`就能进入 它的strace。`F8`是自动翻页开关！

#ltrace
```text
sudo ltrace -p 3425
--- UNKNOWN_SIGNAL (Unknown signal 32) ---
+++ exited (status 0) +++
+++ exited (status 0) +++
+++ exited (status 0) +++
--- SIGCHLD (Child exited) ---
```

作为系统管理，以上这些用法基本能满足日常所需。更多深度功能得找各自的`man`
