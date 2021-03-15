---
title: MQTT5 协议新特性
date: 2021-03-15 16:03:08
tags: [MQTT, 协议]
---

### MQTT v5 (MQTT 5.0) 新特性介绍

项目中逐步完成了 MQTT 5.0的开发，这里介绍下MQTT 5.0 的一些新特性
MQTT 5.0 规范见：http://docs.oasis-open.org/mqtt/mqtt/v5.0/cos01/mqtt-v5.0-cos01.html#_Toc514847900

### 格式
首先，协议上，增加了一个 Property字段，正是这个字段，使得 MQTT 5.0 可以支持众多的新特性。而在MQTT 3.1.1中，MQTT没有任何可以拓展的地方，限制了MQTT拓展功能的可能性。

## request/response 模式
MQTT 本身是 订阅/推送 模式，不像HTTP那样 请求/响应 模式。那么MQTT是如何在 订阅/推送 模式下支持 request/response 模式呢？
这里简单翻译了 http://docs.oasis-open.org/mqtt/mqtt/v5.0/cos01/mqtt-v5.0-cos01.html#Request/_Response 中举例的场景：

（1）A publish 一个消息，消息topic假设是"topicA"，该消息 通过Property携带了Response Topic，假设该字段是"topicresponse"。
（2）订阅了"topicA"的接收端B（有可能有多个）收到了该消息。
（3）B处理完"topicA"后，会publish 一个 topic 名字是 “topicresponse” 的消息。该消息有可能是A订阅的，也有可能是其他人订阅的。
（4）A publish 的消息，可能还会携带Correlation Data属性，假设其值是"msgresponse"，这样B发publish的消息就是(“topicresponse”, “msgresponse”)。

## Server redirection
Server可以发送 CONNACK 或者 DISCONNECT，其 Reason Codes 可以是0x9c或者0x9d，表示Client需要往另一个Server发送请求。
0x9C 类似 HTTP 的 302, 0x9d 类似 HTTP的 301。
CONNACK 或者 DISCONNECT 可以通过 Property携带Server redirection，其值可以告诉Client往哪个Server发送请求，类似HTTP的"Location"首部。

## AUTH控制报文
MQTT 单纯通过 CONNECT可能无法提供足够的信息给Server进行身份认证，所以 Server 在收到 MQTT 的 CONNECT 后，回复 AUTH控制报文给Client，Client接着也用 AUTH包发送附加信息，Server直到 认证完成后，才会发送 CONNACK。

## Topic Alias
类似HTTP2的头部压缩效果，当然，没有同HPACK那么复杂的东西。

我们知道，PUBLISH消息的时候，需要携带 topic和message，其中topic往往是固定的，那么我们只需要第一次发送完整的 topic，并且通过Property中携带Topic Alias告知对端下次这个PUBLISH的topic会使用Topic Alias中的值代替，Topic Alias的值是一个整数类型的值。

client 通过 CONNECT 中 Topic Alias Maximum 告知 Server自己能处理的最多的 Topic Alias 个数。
Server 通过 CONNACK中 Topic Alias Maximum 告知 Client自己能处理的最多的 Topic Alias 个数。

如果当前PUBLISH消息的topic长度不为0，那么接受方需要解析 Topic Alias 中的值，并且 将topic和该值进行映射。
如果当前PUBLISH消息的topic为0，那么接受方需要解析 Topic Alias 中的值，用该值去查找对应的topic。

## User Property
自定义属性，可以添加两端约定的数据。例如可以加入类似HTTP的 "Header:value"信息。MQTT本身没有类似HTTP的HOST信息，我们可以使用User Property特性让MQTT支持。

## Session Expiry Interval
之前的MQTT版本，当cleansession为0时，server和client会尝试保存session信息（sub信息、PUBLISH状态等），但是有个问题，server 不知道需要保存这个session多久。MQTT 5.0 就 在 Property字段中增加了Session Expiry Interval属性来告知server这个session希望被保存多久。

如果MQTT 5.0 不携带 Session Expiry Interval或者 Session Expiry Interval设置为0，server和client则不会保存session信息。
如果Session Expiry Interval设置为0xffffffff，则表示session永远不会老化。

当然，这个字段是需要配合Clean Start使用的，如果Clean Start为1，那么 Session Expiry Interval设置多大都无意义。

CONNECT、CONNACK、DISCONNECT都会发送 Session Expiry Interval字段。DISCONNECT中携带该字段可以告知Server更新老化时间。
CONNACK中的Session Expiry Interval只有当CONNECT不携带该字段时才有用，当client携带该字段，server发送该字段只是表明自己最大的老化时间，不会强制client必须按照这个值。

## Maximum QoS
Server 可以发送 Maximum QoS属性告知Client自己支持最大的Qos是多少，Client发送的PUBLISH的Qos必然不能大于该值。

## Receive Maximum
告知对方自己希望处理未决的最大的 Qos1 或者 Qos2 PUBLISH消息个数，如果不存在，则默认是65535。
作用：流控。
因为当处理 Qos > 0 的PUBLISH的时候，需要回复对端PUBACK、PUBREC PUBCOMP等。Receive Maximum属性提供了告诉对端发送Qos>0的PUBLISH的速率，对端发现未决PUBLISH个数等于Receive Maximum时，不能再发送Qos > 0 的PUBLISH消息了。

## Maximum Packet Size
顾名思义，单个 MQTT控制报文 的大小，如果不携带，表示不限制。
这个大小指整个 MQTT控制报文 的大小。对端如果发现将发送的包大于该大小，就默默丢弃，不关闭连接。如果自己收到超过自己通告的Maximum Packet Size需要关闭连接。

## Topic Alias Maximum
作用见上文Topic Alias。

## Reason Code
MQTT 3.1.1 只有CONNACK有是否成功还是失败的标志位，现在MQTT 5.0所有的ACK都有该标志位。具体各个ACK中code值得含义在规范中有定义，这里不再列举。
需要注意的是，SUBACK中，MQTT 3.1.1 的 Granted Qos被取代为Reason Code，Reason Code中有状态码表示了具体的Granted Qos。
如果PUBLISH是成功的，其ACK的的Reason Code可以不添加。

## Reason String
所有的ACK以及DISCONNECT 都可以携带 Reason String属性告知对方一些特殊的信息，一般来说是ACK失败的情况下会使用该属性告知对端为什么失败，可用来弥补Reason Code信息不够。

## Clean Start
Clean Start取代了 MQTT3.1.1 中 CleanSession，在协议格式上，直接占用了CleanSession原本的field，这也表示Clean Start语义上和 CleanSession是一样的。

## Payload Format Indicator
指定了PUBLISH 消息的message部分是utf8格式的还是二进制的，接收方必须验证payload是否是该属性定义的格式。
Payload Format Indicator 为 0，表示 是二进制，和不携带该属性的语义是一样的。
Payload Format Indicator 为 1，表示 是utf8编码数据。

## Message Expiry Interval
指定了PUBLISH数据在Server的最长等待时间。超过这个时间，这个数据不能被publish到匹配topic的subscriber

还有其他的细枝末节不再展开了，上述众多属性也有一些细节的地方，可以在原文中搜索就直到了。