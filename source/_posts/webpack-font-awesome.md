---
title: 使用 webpack 打包 font-awesome
date: 2017-02-21 21:09:46
tags: [webpack, font-awesome]
---
当 `npm install font-awesome --save` 后在主scss文件中：
`@import ~font-awesome` 会报很多问题

问题主要是两方面：
* 路径
* 加载器

## 路径

```text
@import "~font-awesome/scss/variables";
$fa-font-path: "~font-awesome/fonts";
@import "~font-awesome/scss/font-awesome";
```
## 加载器
```text

  module: {
    rules: [
      {test: /\.eot(\?v=\d+.\d+.\d+)?$/, loader: 'file-loader'},
      {test: /\.woff(2)?(\?v=[0-9]\.[0-9]\.[0-9])?$/, loader: 'url-loader?limit=10000&mimetype=application/font-woff'},
      {test: /\.(ttf|eot|svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/, loader: "file-loader?limit=10000"},
    ]
  }
```
