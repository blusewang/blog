---
title: FFmpeg视频裁剪
date: 2021-02-01 15:51:45
tags: [FFmpeg, 视频剪裁]
---

视频裁剪就是选中你想要的矩形区域并只输出这个区域，去污不残留。裁剪通常和大小调整，填充和其他操作一起使用。

# 基本裁切内容
老版本的FFmpeg有`cropbottom`、`cropleft`、`cropright`、`croptop`几个指令，但是现在过时了。裁剪操作现在使用下表描述的`crop`滤镜。

![image](https://user-images.githubusercontent.com/1764005/106429770-d9b79280-64a5-11eb-9531-c3673b9399bf.png)

`ow`的值能够通过`oh`的值推导得出，反之亦然。但是不能通过`x`和y推导得出，因为它们是在`ow`和`oh`之后进行求值的。另外`x`能够通过`y`推导得出，反之亦然。

好懵逼。先看人家举的栗子：

```shell
ffmpeg -i input -vf crop=iw/3:ih:0:0 output
ffmpeg -i input -vf crop=iw/3:ih:iw/3:0 output
ffmpeg -i input -vf crop=iw/3:ih:iw/3*2:0 output
```
结果还是没明白人家什么意思。再看个图：
![image](https://user-images.githubusercontent.com/1764005/106429885-09669a80-64a6-11eb-9c9c-cc4846b40487.png)

# 中心裁剪
当我们进行中心裁剪操作时，可以跳过`crop`滤镜`x`和`y`参数的输入。默认`x`和`y`的值分别是：`x_default = ( input width - output width)/2，y_default = ( input height - output height)/2`
这意味着中心裁剪时默认值是自动设置的。那么裁剪中心区域的语法是：`ffmpeg -i input_file -vf crop=w:h output_file`
例如`ffmpeg -i input.mpg -vf crop=iw/2:ih/2 output.mp4`表示以中心裁剪的方式裁出宽高为原视频一半的视频。
