---
title: plan 9 效应 - 为什么功能没坏，你就不该去重构它！
date: 2019-08-05 21:27:46
tags: [plan9, 架构]
---
Plan-9是一个很棒的、很先进的，而且完全是全新实现的Unix系统，它的目的就是要最终解决Unix最初的诺言：一切皆为文件。你听说过这套系统吗？没有？那好，下面就是为什么。

我十分确信你不知道Plan-9是什么东西，并且很有可能你还是第一次听说这个名字。

Plan-9是一款神奇的新版Unix，几乎是由70年代当初开发Unix系统的同一个团队开发的。它的确是一款非常酷的操作系统。它跟Unix非常相似，但它不是Unix，它纠正了Unix系统里很多不一致的、古怪的、至今仍然存在的特性。

Unix在当初立项时有个这样的许诺：系统里任何的东西都是‘文件’——根据某些文件的定义。例如，sockets，也许称作网络连接更合适，它们就不是文件，进程也不是文件。

在Plan-9中，所有的这些问题都解决了！先进的9P虚拟文件系统协议最终让所有东西都成为了文件。目录变成了“命名空间”，资源被映射成了文件。多么神奇！现在，你可以通过对/proc目录(现在应该成其为一个命名空间)里的一个文件使用“cat”命令来查看进程的情况。同样，打开一个网络连接的方式变成了打开/net/tcp目录里的一个文件，这就是它。”iotcl”系统调用在这个系统里完全被根除了，因为基于操作系统上的现代文件形式中的这种怪胎已经不再需要了。

## 那么，为什么你从来没有听说过这样一款神奇的操作系统呢？

你从来没有听说过它的原因是，它并不是一款成功的操作系统。这怎么可能呢？是这样的，是因为Plan-9实际上没有解决任何问题。在Unix世界里，从来没有人抱怨说Unix没有兑现当初关于文件抽象的诺言。

在随后的日子里，Plan-9里的/proc文件系统概念被人移植到到了Solaris等很多其他商业版Unix系统里(Linux也采用了它)。 Plan-9里另外一个非常著名的首创——UTF-8——被迅速的被众多其它操作系统采用，不仅仅是Unix家族。在所有的操作系统里，即使存在一些由于各种原因没有采用UTF-8的，它们也开发出来将UTF-8和本地编码转换的程序库。

Plan-9的对于网络通信的特殊的处理方式需要在这里特别的说明一下。虽然用基于命名空间/文件系统的方式来代替专用API来处理网络操作，听起来很吸引人，但是整个Unix世界，不仅所有人都已经接受了使用伯克利Socket API做为标准方式来进行网络编程，甚至Windows平台也实现了几乎相同的API里简化各种网络应用向Windows上移植——虽然存在一些小问题。

更重要的是，Plan-9发明的这种与众不同的网络编程编程方式在诞生之日就注定了毫无用处。因为在当时，大部分做网络编程的人都已经转向了更高的网络抽象层。RPC和Corba已经诞生，所有的需要跟远程服务器通信的应用全都转向了它们。程序员为了跟远程服务通信时需要打开sockets的机会越来越少，所有的他们都已经习惯了使用Berkeley API。(旁注：曾经有一个POSIX模拟层，叫做APE“ANSI/POSIX Environment”，试图将Plan-9上的某些功能映射到POSIX对应的功能上。这个模拟层一直都没实现，因为一些应用——例如X11——的迁移过于复杂，不可能完成。“维持它正确运行的工作量太过巨大”——维基百科。)

Plan-9的一个最主要的问题出在AT&T和Unix幕后的这群人身上，尽管他们都是才华横溢的科学家和程序员，但他们不懂得如何去开发商业软件，而AT&T也从来没打算进入软件业。这些，我承认听起来有些大不敬，但事实就是这样。他们使用软件，他们喜欢开发内部软件来运行他们的高端网络设备，但是他们却从来不去开发要卖给别人的软件，而且跟Sun，IBM，微软等商业公司不一样，这从来不是他们的资金的主要来源。这就意味着他们不需要有外部世界需要什么样的软件的意识。举个例子，Sun公司就需要这样的意识，所以他们开发出了RPC。他们认识到人们在进行网络编程时很痛苦，他们看到了创建一个网络抽象层的商业机会：“嗨，大伙们，SunOS有一个很酷的东西，让我们能够不直接跟sockets打交道就可以开发出网络应用！你绝对应该使用SunOS”。

还有，在Plan-9中，很多“好的老的东西”被删除了，大量的跟其它Unix不兼容的东西被加入了系统。这几乎打消了众多公司试图将他们的应用迁移到Plan-9的念头。如果你不知道这样一个新系统是否能够获得成功，那为什么要耗费了大量的工作把自己的应用迁移到这个新平台上呢？这就是典型的鸡生蛋蛋生鸡问题：一个操作系统的价值就在于上面有大量应用可运行，无它。如果一个系统很新，你要做的是必须发展一个能够支持各种应用的生态系统，通过它们让这个系统变得有价值。只有两条路能做到这样。第一个就是让这个系统跟目前现存的系统保持最大的兼容，也就是Unix， POSIX 和 Motif 这些系统。第二个就是创建自己的生态系统，以此来提升新系统的价值，微软Windows和Office办公系统软件就是典型例子。

## 我们应该从Plan-9的历史教训中总结出一些经验吗？
当然，我们至少可以获得下面这些：

- 首先是，不要试图去修改那些没有坏或你认为不够好的东西，如果要修，只去修改出问题的部分，不要去修改看起来很笨——但事实上是在按要求工作的东西。例如，UTF-8是个非常棒的创意，你需要它，但你可以用程序库或子系统实现它，这样其它系统也能使用它，而不是去基于这个编码开发出一套全新的操作系统。
- 第二个是，在开发一个你的系统前，先去搞清楚它是否有市场，或者人们是否需要这个东西。例如，/net/tcp文件系统绝对是一个精彩的纯学术课题，如果是早几年，它一定能完胜Berkeley sockets，但不应该是在直接使用Socket的人群已经没剩几个的时候。
- 第三，要么完全的独立自主，要么跟现有的系统保持最大兼容。但Plan-9却处在它完全不应该的位置：中间。这套系统既不跟现有的所有Unix系统兼容，同时也不提供其它Unix系统中都有的、必要的工具。没有高级文本编辑器、表格软件、CAD程序和服务器软件。它就是一个神奇的空盒子，却没有提供任何方法让人们容易的把东西放进去。

这些看起来都是一些非常高层的东西，并不是特别跟程序员的日常开发相关。看起来是这样，但事实远非如此。现如今，你可以很容易的开创自己的事业，开始向用户提供某种的服务。然而，你的服务是一个有价值的产品？还是变成了另外一个Plan-9传奇？这并不是很容易判断的事。例如，你的打算开发一个报表系统，来展现监控数据或其它任何可视的状态，如果你没有提供用它将这些报表导入到Excel的功能，那你在写第一行代码前就输了。如果你打算开发一个新的Web社交应用，而你没有提供使用Fackbook、Twitter或LinkedIn登录的方式，那你在搭建WEB服务器前就输了。如果你web服务中信息的导出方式没有采用RSS或ATOM，而是采用了一种全新的格式，猜会怎么样？你在吸引到第一个用户前就输了。但是，比着一切更重要的是：你的产品真正的解决了一个现实存在的问题吗？

翻译自：[The Plan-9 Effect or why you should not fix it if it ain't broken](http://www.di.unipi.it/~nids/docs/the_plan-9_effect.html)