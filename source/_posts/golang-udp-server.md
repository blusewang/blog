---
title: golang udp 服务的坑
date: 2020-06-29 14:11:38
tags: [golang, udp]
---

golang udp 服务端演示级的写法一般是：
```golang
    conn, err := net.ListenUDP("udp", &net.UDPAddr{Port: 8866})
	if err != nil {
		log.Fatalf("Udp Service listen report udp fail:%v", err)
	}
	defer conn.Close()
	for {
		data := make([]byte, 1024*4)
		n, remoteAddr, err := conn.ReadFromUDP(data)
		if err == nil {
			// ... 做点什么
            conn.WriteToUDP(data[:n], remoteAddr)
		}
	}
```

这段代码作为教学或演示是没有问题的。但应用于生产时，处在在一个频繁收发报文的中心服务器上，这里就有两个问题了：
- 在`for`循环中不断申请变量`data`并`make`。会产生大量内存消耗。引起频繁GC。
- 收到数据后处理不应该在`for`循环内部。因为如果数据处理时间过长，就会拥塞。拥塞期间若底层缓冲区满了，说不定会丢包。

那么V2版写法来了：
```golang
    conn, err := net.ListenUDP("udp", &net.UDPAddr{Port: 8866})
	if err != nil {
		log.Fatalf("Udp Service listen report udp fail:%v", err)
	}
	defer conn.Close()
    data := make([]byte, 1024*4)
	for {
		n, remoteAddr, err := conn.ReadFromUDP(data)
		if err == nil {
            go func (){
                // ... 拿 data[:n]做点什么
                conn.WriteToUDP(data[:n], remoteAddr)
            }()
		}
	}
```

V2版看上去完美！其实运行结果会完全出人意料！

因为每次`for`循环没有将`data`置0，当传输的是二进制时，会导致上次Read的结果干扰下次Read的结果。导致对数据 `Unmarshal`时随机出错！如果不借助`tcpdump`抓包做位级比对！这会变成一个玄学问题！

ok！再来V3！
```golang
    conn, err := net.ListenUDP("udp", &net.UDPAddr{Port: 8866})
	if err != nil {
		log.Fatalf("Udp Service listen report udp fail:%v", err)
	}
	defer conn.Close()
    var data []byte
	for {
        data = make([]byte, 1024*4)
		n, remoteAddr, err := conn.ReadFromUDP(data)
		if err == nil {
            go func (){
                // ... 拿 data[:n]做点什么
                conn.WriteToUDP(data[:n], remoteAddr)
            }()
		}
	}
```

V3版成功解决了干扰！

但又来了新问题。就是：在协程中处理数据`data[:n]`时总是所有位是`0`的`n`位长的数组。辣么，数据呢？

当然是协程内引用`data`导致的。因为在协程创建完成，开始执行前，`for`已经进入下一个循环并在`Read`处等待了。此时的`data`经过`make`已经重置数据了。

> 这里要介绍一个`golang`的基础功能`copy`
>> `golang` 为了避免每一层的处理数据都要在内存里建立相同数据的副本。采用了引用的方式传递。也就是`slice`的存在的意义！它大量节约了内存！天才般的设计！<br>
>> 这里`conn.ReadFromUDP(data)`后`data`里放的其实是底层缓冲区内的数据引用。操作`data`实际上是在操作底层缓冲区。<br>
>> 所以我们在操作`data`前一定要先将`data`里的数据读入新的变量里，实现`私有化`，再交给协程处理。否则在协程未启动完成前，`data`里的数据可能因为进入新的循环，而被刷新！<br>
>> 不幸的是，简单的`=`是不能将`data` `私有化`的。只能`make`一个空白的`slice`，再将`data`逐个复制进来。这个操作`golang`已为我们封装好了一个函数，它就是：`copy`

ok！再来V4！
```golang
	conn, err := net.ListenUDP("udp", &net.UDPAddr{Port: 8866})
	if err != nil {
		log.Fatalf("Udp Service listen report udp fail:%v", err)
	}
	defer conn.Close()
	var data = make([]byte, 1024*4)
	var raw []byte
	for {
		n, remoteAddr, err := conn.ReadFromUDP(data)
		if err == nil {
			raw = make([]byte,n)
			copy(raw,data[:n])
			go func (){
				// ... 拿 raw 做点什么
				conn.WriteToUDP(raw, remoteAddr)
			}()
		}
	}
```

ok! 运行起来几乎没啥问题。