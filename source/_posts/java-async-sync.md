---
title: Java多个异步任务转同步
date: 2020-03-10 15:12:39
tags: [Java, kotlin, async]
---

Java[kotlin]对于异步的网络请求，一般采用回调来实现异步！
虽然，像`OkHttp`库，已经支持到了同步，但偶尔还是会碰到两种绕不过的情况：
- 依然有很多必然是异步的场景无法绕过。如：Android的请求权限、调用相机等等。
- 多任务并发控制。
    - 并发。如：N个线程并发执行任务。当N个任务全部执行完后，再执行后续逻辑。
    - 可控的并发。如：有N个任务，在M个线程中并发执行。

> 这里我要绕开“线程同步锁”方案。这东西写法纷繁冗长，且考验“智商”。

# 异步

 单个异步不会让代码书写得多么考验智商。当数量变成：`x`后。问题就变得不一样了。如：

- 假设一个前提：某业务必须使用回调来完成一次请求，现有`n`个请求，逐个完成。

异步实现的代码：

```kotlin
class Worker{
    private var isSync = false
    fun sync(completion: () -> Unit) {
        if (!isSync) {
            isSync = true
            val lastId = database.table("msgs").getLast()?.msg_id ?: ""
            Thread(Runnable {
                try {
                       fetchNext(lastId, completion)
                } catch (e: Exception) {
                       e.printStackTrace()
                       isSync = false
                }
            }, "SyncWorker").start()
        }
    }

    private fun fetchNext(lastId: String, completion: () -> Unit) {
        val req = NewRequest()
        req.query.msgId = lastId
        Client.send(req.build()) { r, ok ->
            if (ok) {
                if (!r.hasNext) {
                    // 数据已取完
                    completion()
                    isSync = false
                } else {
                    // 未取完，继续循环
                    val msg = NewMsgRow(r.body)
                    database.table("msgs").insert(msg)
                    fetchNext(m.msgId, completion)
                }
            } else {
                // 请求出错，整个放弃!
                completion()
                isSync = false
            }
        }
    }
}

```

## 异步的缺点
- 烧脑，也是培养Bug的温床！
- 容易滋生Bug，自然难于调试。且难以确保没有bug！
- 递归导致调用栈过深，吃不必要的内存！

如果是同步的情况下，代码会很优雅。

同步代码对比：

```kotlin
class Worker{
    private var isSync = false
    fun sync() {
        isSync = true
        var ok = false
        while(!ok){
            try{
                val rs = NewReuest().query("msgId",id).send()
                val msg = NewMsgRow(rs.body)
                database.table("msgs").insert(msg)
            }catch(e:Exception){
                ok = true
            }
        }
    }
}

```

## 异步转同步
一般情况下，操作系统还有个概念可用，那就是：“信号和量”。Java的`Semaphore`，在使用 `await`时，需要调整JVM的option。
不是个好选择。
但Java还提供了另一个东西：`CountDownLatch`。它的`await`就可以正常使用。

用法举例：
```kotlin

class Worker{

    // 异步转同步
    @Throws(Exception::class)
    fun req(id:String):Body{
        // 创建一个只要一个信号的锁
        val c = CountDownLatch(1)
        var e:Exception? = null
        var rs:Body = EmptyBody()

        Client.send(NewRequest()) { r, err ->
            if(err) e = err
            else rs = r.body
            // 释放锁
            c.countDown()
        }
        // 等待信号
        c.await()
        if (e != null) throw e!!
        return rs!!
    }
}
```

# 异步并发控制
这个信号和量可以适用了。

用法举例：20个任务，5个并发
```kotlin

class Worker{
    fun mutiTask(){
        // 创建5个车道
        val s = Semaphore(5)
        for (i in 0..20){
            // 等绿灯
            s.acquire()
            Client.req(NewRequest()){rs,err ->
                // 处理rs,err....
                
                // 通过后释放车道
                s.release()
            }
        }
    }
}
```
