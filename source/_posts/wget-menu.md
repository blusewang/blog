---
title: wget 的妙用
date: 2022-06-27 10:24:36
tags: [wget]
---
# 将文件下载到特定目录📁
只需将PATH替换为要保存文件的输出目录位置即可。
`wget ‐P <PATH> https://example.com/sitemap.xml`
# 重命名下载的文件📝
要重命名文件，请将FILENAME替换为您想要的名称并运行：
`wget -O <FILENAME.html> https://example.com/file.html`
# 将自己定义为用户代理🧑‍💻
`wget --user-agent=Chrome https://example.com/file.html`
# 限速⏩
wget 可以通过实现--waitand--limit-rate命令来帮助解决这个问题。
```shell
--wait=1 \\ Wait 1 second between extractions.
--limit-rate=10K \\ Limit the download speed (bytes per second)
```
# 提取为 Google bot 🤖
`wget --user-agent="Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.198 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)" https://example.com/path`
# 转换页面上的链接🖇️
将 HTML 中的链接转换为在您的本地版本中仍然有效。（例如 example.com/path -> localhost:8000/path）
`wget --convert-links https://example.com/path`
# 镜像单个网页📑
您可以运行此命令来镜像单个网页以在本地设备上查看它。
`wget -E -H -k -K -p --convert-links https://example.com/path`
# 提取多个 URL 🗂️
首先创建所有需要的 URL 并将其添加到urls.txt文件中。
```text
https://example.com/1
https://example.com/2
https://example.com/3
```
接下来，运行以下命令以提取所有 URL。
`wget -i urls.txt`

# 如何使用 wget 配置代理
## 配置文件
- /usr/local/etc/wgetrc 全局，适用于所有用户
- $HOME/.wgetrc 适用于单个用户
配置：
```text
https_proxy = http://[Proxy_Server]:[port] 
http_proxy = http://[Proxy_Server]:[port]
ftp_proxy = http://[Proxy_Server]:[port]
```
## 设置临时代理变量
```shell
export http_proxy=http://[Proxy_Server]:[port]
export https_proxy=$http_proxy
export ftp_proxy=$http_proxy
```
## 设置到`SHELL`环境变量
> 在 `~/.bash_profile` 或 `/etc/profile` 中添加以下行：
```shell
export http_proxy=http://[Proxy_Server]:[port]
export https_proxy=http://[Proxy_Server]:[port]
export ftp_proxy=http://[Proxy_Server]:[port]
```
