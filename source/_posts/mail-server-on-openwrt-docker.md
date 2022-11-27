---
title: 如何在自家的路由器器上部署一个自己的邮箱服务
date: 2022-11-27 22:38:06
tags: [postfix, docker, openwrt]
---

# 背景

- 注册线上的邮箱，对个人信息的绑定越来越多。国内很多邮箱，没有手机号注册不了。公司业务一般需要十几二十多个邮箱用于注册线上账号，这就需要几十个手机号。长年备用。
- 且现在注册邮箱时密码安全等级要求高。密码维护繁琐，一个没记录好。下次登录就很麻烦。
- 邮箱附带更多的广告、平台方各种植入自己的产品。

自建邮箱服务，就成了很好的选择。但搭建邮箱服务过去很困难。配置非常繁杂！

好在时过境迁，如果我们有了Docker，专治繁杂的配置！如今，可以在自己家路由器上，部署一个自己的邮箱服务了。

# 环境

- 路由器系统：OpenWrt 21.02.3
- Docker管理包：[luci-app-dockerman(20.10.17-1)](https://github.com/lisaac/luci-app-dockerman)、docker-compose(1.28.2-1)
- 邮件服务镜像：[docker-mailserver(v11.2.0)](https://github.com/docker-mailserver/docker-mailserver)
- Let's Encrypt 自动签发工具：[acme.sh](https://github.com/acmesh-official/acme.sh)

`docker-mailserver`包下了一套完整的邮件系列服务。其中重点的服务有：

| 服务名                                                           | 简介                  |
|---------------------------------------------------------------|---------------------|
| [Postfix](http://www.postfix.org/)                            | 不错的MTA服务            |
| [Dovecot](https://www.dovecot.org/)                           | 提供IMAP、POP3协议的收邮件服务 |
| [Amavis](https://www.amavis.org/)                             | 高性能内容过滤器            |
| [SpamAssassin](http://spamassassin.apache.org/)               | 垃圾邮件过滤服务            |
| [ClamAV](https://www.clamav.net/)                             | 邮件杀毒服务              |
| [OpenDKIM](http://www.opendkim.org/)                          | DKIM签名服务            |
| [Fail2ban](https://www.fail2ban.org/wiki/index.php/Main_Page) | 防暴力破解服务             |

# 部署

## 域名设置

几点说明：

- 家用动态ADSL，设置不了rDNS。所以略过。
- DNS的SPF记录：将域名标记为发邮件服务。
- DNS的DMARC记录：将域名标记为已受SPF/KDIM等保护。

| 设置      | 记录类型 | 记录名                        | 记录值                                                                                                                                                                        |
|---------|------|----------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 邮件服务    | MX   | home.my.domain.name        | home.ddns.domain                                                                                                                                                           |
| SPF标记   | TXT  | home.my.domain.name        | v=spf1 mx ~all                                                                                                                                                             |
| DMARC标记 | TXT  | _dmarc.home.my.domain.name | v=DMARC1; p=quarantine; rua=mailto:postmaster@home.my.domain.cn; ruf=mailto:postmaster@home.my.domain.cn; fo=0; adkim=r; aspf=r; pct=100; rf=afrf; ri=86400; sp=quarantine |

## 自动签发证书
虽然`docker-mailserver`自己带了`letsencrypt`功能，只要配置好，自动签！但家用宽带没有80端口。只能自己搞定。

采用`acme.sh`自动签发。操作参考[acme说明书](https://github.com/acmesh-official/acme.sh/wiki/%E8%AF%B4%E6%98%8E)
```bash
curl https://get.acme.sh | sh -s email=your@email.com
```
将`acme.sh`安装到`/root/.acme.sh/`下。

先获取到手动验证DNS的challenge值：
```bash
/root/.acme.sh/acme.sh --issue --dns -d home.my.domain.name --yes-I-know-dns-manual-mode-enough-go-ahead-please
```
获取到值后，把challenge值设置到DNS中。如：

| 设置   | 记录类型 | 记录名                                 | 记录值        |
|------|------|-------------------------------------|------------|
| 手动验证 | TXT  | _acme-challenge.home.my.domain.name | challenge值 |

然后通过`renew`生成证书，注意：一定要带上`--server letsencrypt`这个参数。[不然默认连接`acme.zerossl.com`要么超时，要么503](https://github.com/acmesh-official/acme.sh/issues/3775)：
```bash
/root/.acme.sh/acme.sh --renew -d home.my.domain.namen --yes-I-know-dns-manual-mode-enough-go-ahead-please --server letsencrypt
```
最后，通过`crontab`让证书续期自动化
```bash
crontab -e
0 5 * * 1 /root/.acme.sh/acme.sh --renew -d home.my.domain.name --yes-I-know-dns-manual-mode-enough-go-ahead-please --server letsencrypt
```

## 准备环境

将 [docker-mailserver](https://github.com/docker-mailserver/docker-mailserver) 项目中的 `setup.sh`、`docker-compose.yml`、`mailserver.env`下载到本地目录中。通过shell进入目录。

## 配置`docker-compose.yml`

- hostname: home
- domainname: my.domain.name
- volumes中添加： - /root/.acme.sh/home.my.domain.name/:/tmp/cert/

## 配置`mailserver.env`

- POSTMASTER_ADDRESS=postmaster@home.my.domain.name
- SSL_TYPE=manual
- SSL_CERT_PATH=/tmp/cert/home.my.domain.name.cer
- SSL_KEY_PATH=/tmp/cert/home.my.domain.name.key

## 生成`DKIM`签名
```bash
./setup.sh config dkim keysize 2048
[   INF   ]  Creating DKIM private key '/tmp/docker-mailserver/opendkim/keys/home.domain.name/mail.private'
cat ./docker-data/dms/config/opendkim/keys/home.domain.name/mail.txt
mail._domainkey	IN	TXT	( "v=DKIM1; h=sha256; k=rsa; "
	  "p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA8Tr2JFyWXLMKcxY9j/1IjR6me2EjdyI4K97wAGoPUWK9ZmFewpSZ8DAEKphWV79k+w61BwLTLdpDLR6HpqsVOV7tGDGdK8sUG7tqfWQhN4Vudy9VUmQ1WOrcUE3o5nUfeh8jwjiO5/exWBiTmAJ78p54hSkzMalmCOQCXWcCbJbUN+jrmV8WUEHx+6M7MP0Z7KQSJY3bW6ujm9"
	  "3O1yOnzMgJy1VBJvLSbyDrjtxXJGrPbTCRaig09I5WFxZXwROispL1xiTNgUGv9/1fDeUqoIPPXCw6z4l6x20aRl+Sog+WH2qLLyY+PdIFaTfJ8MBysrZF6yhJ5rx4THZmu8CtUQIDAQAB" )  ; ----- DKIM key mail for home.domain.name
```

> 这一般是设置在主域上的。我在这里设置在二级域上，不知道是否有效。不过能确定不太影响功能。

设置DNS：

| 设置   | 记录类型 | 记录名                                 | 记录值                                                                                                                                                                                                                                                                                                                                                                                                                                  |
|------|------|-------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| DKIM | TXT  | mail._domainkey.home.my.domain.name | v=DKIM1; h=sha256; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA8Tr2JFyWXLMKcxY9j/1IjR6me2EjdyI4K97wAGoPUWK9ZmFewpSZ8DAEKphWV79k+w61BwLTLdpDLR6HpqsVOV7tGDGdK8sUG7tqfWQhN4Vudy9VUmQ1WOrcUE3o5nUfeh8jwjiO5/exWBiTmAJ78p54hSkzMalmCOQCXWcCbJbUN+jrmV8WUEHx+6M7MP0Z7KQSJY3bW6ujm93O1yOnzMgJy1VBJvLSbyDrjtxXJGrPbTCRaig09I5WFxZXwROispL1xiTNgUGv9/1fDeUqoIPPXCw6z4l6x20aRl+Sog+WH2qLLyY+PdIFaTfJ8MBysrZF6yhJ5rx4THZmu8CtUQIDAQAB |

## 验证TLS

前往：[checktls](https://www.checktls.com/) 测试一下TLS的支持情况。

## 添加用户

```bash
./setup.sh email add postmaster@home.domain.name "password type here"
```

# 启动
```bash
docker-compose up -d # 启动
docker-compose logs -f # 看日志
```

## 开放端口
进入openwrt后台，在[网络]->[防火墙]->[端口转发]中添加993、645两个端口映射到路由器IP上。

# 参考文档
- https://www.treesir.pub/post/docker-deploy-mailserver/
- https://docker-mailserver.github.io/docker-mailserver/edge/config/setup.sh/
- https://github.com/acmesh-official/acme.sh/wiki/%E8%AF%B4%E6%98%8E
- https://github.com/acmesh-official/acme.sh/issues/3775
