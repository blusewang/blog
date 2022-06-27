---
title: Linux bridge/tun/tap 构建虚拟网络
date: 2022-06-27 10:24:01
tags: [linux, tun, tap, bridge]
---

# 私有网桥，仅 VM 到 VM
用于两个或多个 VM 之间的通信。它们只相互通信，不能访问 Internet 或主机。

> 添加一个名为 Gefyra0 的网桥# 为 VM 添加 2 个 tun/tap 接口# 将 tun/tap 接口与 brigde VM 的 qemu 命令行连接。每个 VM 必须具有不同的分接头接口和 MAC 地址：第 1：第2：在 VM 内部，您可以使用任意子网和每个 VM 在该子网上的 IP 配置网络接口。

```shell
ip link add Gefyra0 type bridge
ip link set Gefyra0 up

ip tuntap add QemuTap0 mode tap user A_Username
ip tuntap add QemuTap1 mode tap user A_Username
ip link set QemuTap0 up
ip link set QemuTap1 up

ip link set QemuTap0 master Gefyra0
ip link set QemuTap1 master Gefyra0
```

---

# 使用路由子网桥接，VM <->主机
在这种情况下，主机和 VM 之间可以互相访问。

> 添加一个名为 Gefyra0 的网桥# 为 VM 添加 2 个 tun/tap 接口# 将 tun/tap 接口与 brigde 连接与之前设置的不同之处在于第二行：将新子网中的 IP 分配给主机的网桥接口。此新子网不得在其他任何地方使用。虚拟机应使用不同的分接头接口和 MAC 地址进行配置（见上文）。每个 VM 的 IP 应与网桥的子网位于同一子网中，以便主机和 VM 进行通信。

```shell
ip link add Gefyra0 type bridge
ip addr add 192.168.223.1/24 dev Gefyra0
ip link set Gefyra0 up

ip tuntap add QemuTap0 mode tap user A_Username
ip tuntap add QemuTap1 mode tap user A_Username
ip link set QemuTap0 up
ip link set QemuTap1 up

ip link set QemuTap0 master Gefyra0
ip link set QemuTap1 master Gefyra0

```
---
# 使用路由子网桥接，VM <-> host-LAN-Internet
是时候让 VM 访问 Internet，你不觉得吗？🙂
> 添加一个名为 Gefyra0 的网桥# 为 VM 添加 2 个 tun/tap 接口# 将 tun/tap 接口与 brigde 连接# 启用路由# -o 将要用于路由的接口作为参数，在本例中为 enp2s0和往常一样，每个VM 必须在配置的网桥子网上有各自的 tap int、mac addr 和分配的 IP；看上面。
```shell
ip link add Gefyra0 type bridge
ip addr add 192.168.223.1/24 dev Gefyra0
ip link set Gefyra0 up

ip tuntap add QemuTap0 mode tap user A_Username
ip tuntap add QemuTap1 mode tap user A_Username
ip link set QemuTap0 up
ip link set QemuTap1 up

ip link set QemuTap0 master Gefyra0
ip link set QemuTap1 master Gefyra0

echo '1' > /proc/sys/net/ipv4/ip_forward

iptables -t nat -A POSTROUTING -o enp2s0 -j MASQUERADE
```
---

# 桥接到第2层 - 将 VM 连接到已连接的交换机主机：
需要更多解释性的标题，欢迎提出建议！

在这种类型的连接中，VM 被插入 - 有点 - 在连接主机的同一交换机上。例如，如果网络上有 DHCP 服务器并且主机从该 DHCP 获取其 IP，则 VM 也将能够从同一 DHCP 获取 IP。这是主要用于生产 ESXi、Xen 或 HyperV 虚拟机的场景。

**警告** 当物理网卡分配给网桥时，它会失去连接。IP必须分配给网桥，而不是主机的物理网络接口。

> 添加一个名为 Gefyra0 的网桥# 添加一个物理接口到网桥，例如 eth0：
```shell
ip link add Gefyra0 type bridge
ip link set Gefyra0 up

ip link set eth0 master Gefyra0
```
> 此时主机上的网络连接丢失。如果要恢复连接：
> dhclient -v Gefyra0 (for dhcp)
> dhclient -v Gefyra0 -r (to release IP)
> ip addr add 192.168.223.1/24 dev Gefyra0 (for static IP)
> add 2 tun/tap虚拟机接口现在可以在虚拟机上配置网络。**注意：**如果主机上使用了network-manager，它可能会干扰。为了安全起见，请在开始之前禁用它：
```shell
ip tuntap add QemuTap0 mode tap user A_Username
ip link set QemuTap0 up
ip link set QemuTap0 master Gefyra0

sudo systemctl stop NetworkManager
pkill nm-applet
```
---

# 其它
- 删除网桥：
`ip link del Gefyra0`

- 删除点击：
`ip tuntap del tap0 mode tap`

- 查看所有 iptables 防火墙规则和 NAT 网络过滤表
`iptables -t nat -vL`

- 没有解析
`iptables -t nat -vL -n`

- 显示行号 - 优先级：
`iptables -t nat -vL --line-number`

- 删除行，使用上面命令显示的数字：
`iptables -t nat -D POSTROUTING {number}`
