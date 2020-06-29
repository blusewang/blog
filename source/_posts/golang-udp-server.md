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
- 在`for`循环中不段申请变量`data`并`make`。会产生大量内存消耗
- 收到数据后处理不能在`for`循环内部。这会导致拥塞。若底层缓冲区满了，说不定会丢包。

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

当然是携程内引用`data`导致的。因为在携程执行时，`for`已经进入下一个循环并在`Read`外等待了。此时的`data`经过`make`已经重置数据了。

ok！再来V4！
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
            go func (raw){
                // ... 拿 raw做点什么
                conn.WriteToUDP(raw, remoteAddr)
            }(data[:n])
		}
	}
```

运行起来几乎没啥问题。就是循环`make`依旧存在。