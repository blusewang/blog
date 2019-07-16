---
title: Android 指定 DNS （为什么新用户安装完你的App后，与Api服务连接失败？）
date: 2019-07-16 21:54:30
tags: [Android, DNS]
---

> 过去一直有个问题：发现我的新用户在安装完App后，打开时提示没有网络（连接到我的Api服务器失败）<br>
> 直到今天翻qiniu的SDK时才明白过来，问题可能在**DNS**<br>
> 七牛的SDK一直使用了一个叫`HappyDNS`的一个库。我一直以为这是“脱裤子放屁”。<br>
> 直到今天才明白这中间的“中国特色”

# Android

## 环境

- 开发工具：Android Studio
- 语言：Kotlin
- 依赖包：
    - com.squareup.okhttp3:okhttp:3.14.2
    - com.qiniu:happy-dns:0.2.13

## 关键代码

```kotlin
val client = OkHttpClient.Builder()
                             .dns {
                                 if (it == "my.api.host.domain.name") {
                                     InetAddress.getAllByName(Config.SERVER_IP).toMutableList()
                                 }else{
                                     try{
                                         val resolvers = mutableListOf<IResolver>()
                                         try{
                                             resolvers.add(Resolver(InetAddress.getByName("119.29.29.29")))
                                         }catch (e:Exception){}
                                         try{
                                             resolvers.add(Resolver(InetAddress.getByName("114.114.114.114")))
                                         }catch (e:Exception){}
                                         try{
                                             resolvers.add(Resolver(InetAddress.getByName("8.8.8.8")))
                                         }catch (e:Exception){}
                                         if (resolvers.size == 0) throw UnknownHostException("$it resolver fail")
                                         DnsManager(NetworkInfo.normal,resolvers.toTypedArray()).queryInetAdress(Domain(it)).toMutableList()
                                     }catch (e:Exception){
                                         Dns.SYSTEM.lookup(it)
                                     }
                                 }
                             }.build()
```
