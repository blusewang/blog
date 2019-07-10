---
title: 使用 Let's Encrypt 给Nginx网站加密
date: 2017-01-12 16:32:11
tags: [lets-encrypt, ssl, https, nginx]
---

使用[certbot](https://certbot.eff.org/#freebsd-nginx)管理证书。

在FreeBSD中安装：
```text
sudo pkg install certbot
```
获取证书：
```text
certbot certonly --webroot -w /var/www/example -d example.com 
```
完事后，证书在：
```text
/usr/local/etc/letsencrypt/live/example.com/
```
目录中。

配置Nginx 虚拟机：
```text
server{
    listen     80;
    server_name example.com;
    root    /var/www/example;

    add_header Cache-Control no-store;
}

server {
    listen  443 ssl;
    server_name example.com;
    root /var/www/example;


    ssl                  on;

    ssl_certificate /usr/local/etc/letsencrypt/live/example.com/fullchain.pem;
    ssl_certificate_key /usr/local/etc/letsencrypt/live/example.com/privkey.pem;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;
    ssl_ciphers AES256+EECDH:AES256+EDH:!aNULL;

}
```
OK！完事！最后
```text
sudo nginx -t
sudo nginx -s reload
```