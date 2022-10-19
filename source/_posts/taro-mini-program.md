---
title: Taro+VUE+TS+NutUI 开发小程序的体验
date: 2022-10-19 13:07:54
tags: [Taro, VUE, 微信小程序]
---

# NutUI问题

## 小程序支持不整

### 有些组件没有实现
`barrage`弹幕组件，官方演示小程序的`slot`式使用就直接不能正常运行。

使用官方文档，结合演示小程序的源码的写法，在Taro-cli脚手架构建的项目里使用无效，直接用不了。

### nut-form使用报警告
使用`nut-form`后，报：`WXMLRT_$gwx:./base.wxml:template:149:16: Template tmpl_0_view not found.`警告。
功能可以正常使用。

### 强制使用`scss`
我更习惯使用`sass`。

# Taro问题

## CSS不支持`scoped`
官方明说了不支持。

## 缓存与编译器磨合不好
官方文档、使用过得中都提示开发者开启：`config/index.js`中的`cache.enable`，以发挥出`webpack5`的性能优势。
但开启后，在多次执行`yarn dev:weapp`时，有时会出现丢失部分模板。导致小程序无法预览，或预览时部分组件不显示。
且控制台循环报类似：`WXMLRT_$gwx:./base.wxml:template:149:16: Template tmpl_0_view not found.`的警告。
导致不可用。

为了可靠的编译结果。这个cache功能必须关闭。

## 小程序热启动时参数获取不到。
使用官方给出的`getLaunchOptionsSync()`得到的是小程序启动时的参数。

这个问题的解决方案，我在Taro官方文档里没有找到。在社区里找到了答案：使用 `Taro.Current` 它能提供准确的`path`和`query`信息。
