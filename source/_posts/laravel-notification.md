---
title: Laravel Notification 测评
date: 2016-12-15 13:21:15
tags: [laravel, notification]
---

Laravel 5.3 新出了个叫 `Notification` 的消息通知功能！先总，后分吧。

## 适用场景
它相对`event`的优点是：更简单也更好地隔离了不同的业务代码。且一次触发，多种'姿势'运行，不同'姿势'代码独立。

适合于发比较复杂的跨站消息，如：邮件、同步weibo、OA系统、第三方个人笔记Ever-note等。不只适合单发，还适合不同渠道并发。比如：同一个消息同时发送前边列出的所有渠道。

它还有个优点是，也能做一个Log，记录所有的发送结果。还能支持检测并记录：**接收者对消息的查看状态**。

不足的地方是：默认支持的实用工具像`mail`、`nexmo`、`slack`。除了`mail`，其它两个，我天朝子民都用不上。只能用点本地的渠道，如：`database`、`broadcast`。
虽然默认的有点少，但官方还搞了个[第三方消息集合的网站](http://laravel-notification-channels.com/)。在这里能找到一堆奇葩的，常见的，拿来就能用的第三方消息扩展。**但是**，依旧很少有我天朝可以直接用的。乐观地看：给了你我一个完善的机会！悲观的看：自己写才是王道！总之：还是自己写！


## 对象介绍
相关的类有：

`Notification`：发出一个消息后，业务就交给它了。这里生成适合不同渠道的消息，并交给不同渠道去发送。

`Channel`：这里定义这个渠道具体的发送流程

`Message`：这是个格式化不同消息的助手类。如果消息体简单，可以不用它，直接在`Notification`中拼合消息体。如果消息体复杂，就有必要专门为格式化这个消息写一个`Message`Builder Helper。

### 类结构
`Notification` 这个类laravel 的 artisan 有提供make

```text
class DemoNotification extends Notification
{
    use Queueable;
    
    /**
     * Create a new notification instance.
     *
     */
    public function __construct()
    {
        //
    }

    /**
     * 这里返回要发多少个渠道
     *
     * @param  mixed  $notifiable
     * @return array
     */
    public function via($notifiable)
    {
        return [DemoChannel::class];
    }

    /**
     * 后边挨个渠道给生成消息，如有必要，使用Message助手
     * 这里的命名默契地使用 'to' + 渠道名
     */
    
    
    
    public function toDemo($notifiable)
    {
        return (new DemoMessage)
                ->title('这里是标题')
                ->body('这里是消息主体')
                ->from('发送者');
    }
    
    
}
```

`Channel` 每个渠道必须实现一个send($notifiable,Notification $notification) 动作

```text
class DemoChannel
{
    public function send($notifiable,Notification $notification){
        $msg = $notification->toDemo($notifiable);
        // 后边去实现怎么把这个$msg给扔出去！
    }

}
```

`Message` 命名默契地使用'Message'结尾，这个类没有约束，没有继承。完全按需发挥！

```text
class DemoMessage
{
    // 按不同消息的需要自己实现啦，这个类没有约束
    public function title($title)
    {}
    public function body($body)
    {}
}
```