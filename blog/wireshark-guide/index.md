---
title: "Wireshark 使用备忘"
date: 2026-03-30T10:00:00+08:00
lastmod: 2026-03-30T10:00:00+08:00
draft: false
description: "Wireshark 网络抓包工具常用操作记录"
slug: "wireshark-guide"
tags: ["Wireshark", "网络", "抓包"]
categories: ["实用工具"]
comments: true
math: true
---

# Wireshark 使用备忘

Wireshark 是最流行的网络协议分析工具，用于捕获和分析网络流量。本文记录常用操作和过滤技巧。

## 1. 安装

### 1.1 Windows

```powershell
# 使用 winget 安装
winget install Wireshark

# 或下载安装包
# https://www.wireshark.org/download.html
```

## 2. 基本操作

### 2.1 选择网卡

启动 Wireshark 后，在首页选择要监听的网卡：

- 本地回环：`Loopback: lo0`（捕获本机通信）
- 以太网：`Ethernet` 或 `eth0`
- Wi-Fi：`WLAN` 或 `wlan0`

### 2.2 开始/停止抓包

- 开始：双击网卡或点击蓝色鲨鱼图标
- 停止：点击红色方块按钮 `Ctrl+E`
- 重新开始：点击绿色鲨鱼图标 `Ctrl+R`

### 2.3 保存抓包

```bash
# 保存为 pcapng 文件
文件 -> 保存 (Ctrl+S)

# 导出特定数据包
文件 -> 导出特定数据包

# 另存为 pcap 格式（兼容老版本）
文件 -> 另存为 -> 选择格式
```

## 3. 显示过滤器

### 3.1 协议过滤

```
tcp              # 只显示 TCP 流量
udp              # 只显示 UDP 流量
http             # 只显示 HTTP 流量
dns              # 只显示 DNS 流量
icmp             # 只显示 ICMP 流量（ping）
ssh              # 只显示 SSH 流量
tls || ssl       # 显示 TLS/SSL 流量
```

### 3.2 IP 地址过滤

```
ip.addr == 192.168.1.100      # 源或目的 IP
ip.src == 192.168.1.100       # 源 IP
ip.dst == 192.168.1.100       # 目的 IP
ip.addr == 192.168.1.0/24     # 网段过滤
!(ip.addr == 192.168.1.100)   # 排除某 IP
```

### 3.3 端口过滤

```
tcp.port == 80                # TCP 80 端口（源或目的）
tcp.srcport == 80             # TCP 源端口
tcp.dstport == 80             # TCP 目的端口
udp.port == 53                # UDP 53 端口（DNS）
tcp.port >= 8000 && tcp.port <= 9000  # 端口范围
```

### 3.4 组合过滤

```
# 与
ip.addr == 192.168.1.100 && tcp.port == 80

# 或
tcp.port == 80 || tcp.port == 443

# 非
!(ip.addr == 192.168.1.100)

# 复杂组合
(ip.addr == 192.168.1.100 && tcp.port == 80) || (ip.addr == 192.168.1.200 && tcp.port == 443)
```

### 3.5 HTTP 相关

```
http                          # 所有 HTTP 流量
http.request.method == "GET"  # GET 请求
http.request.method == "POST" # POST 请求
http.request.uri contains "api"  # URL 包含 api
http.response.code == 200     # 响应码 200
http.response.code == 404     # 响应码 404
http.host contains "baidu"    # Host 包含 baidu
```

### 3.6 TCP 相关

```
tcp.flags.syn == 1            # SYN 包
tcp.flags.ack == 1            # ACK 包
tcp.flags.fin == 1            # FIN 包
tcp.flags.reset == 1          # RST 包
tcp.analysis.retransmission   # 重传包
tcp.analysis.duplicate_ack    # 重复 ACK
tcp.analysis.zero_window      # 零窗口
```

### 3.7 DNS 相关

```
dns                           # 所有 DNS 流量
dns.qry.name == "baidu.com"   # 查询指定域名
dns.qry.name contains "baidu" # 查询域名包含 baidu
dns.flags.response == 1       # DNS 响应
dns.flags.response == 0       # DNS 请求
dns.a                         # A 记录查询
dns.aaaa                      # AAAA 记录查询
```

## 4. 抓包过滤器

在开始抓包前设置，减少捕获的数据量：

```
# 语法
host 192.168.1.100            # 指定主机
net 192.168.1.0/24            # 指定网段
port 80                        # 指定端口
src host 192.168.1.100        # 源主机
dst host 192.168.1.100        # 目的主机

# 组合
host 192.168.1.100 && port 80
tcp port 80 || tcp port 443
!(port 22)                     # 排除 SSH
```

## 5. 实用功能

### 5.1 追踪 TCP 流

右键点击数据包 → 追踪流 → TCP 流

可以看到完整的请求和响应内容，适合分析 HTTP 通信。

### 5.2 导出对象

```
文件 -> 导出对象 -> HTTP
# 可以导出图片、文件等
```

### 5.3 统计分析

```
统计 -> 捕获文件属性    # 文件概况
统计 -> 协议分级        # 协议分布
统计 -> 端点           # 通信端点统计
统计 -> 对话           # 通信对话统计
统计 -> I/O 图表       # 流量图表
```

### 5.4 搜索数据包

`Ctrl+F` 打开搜索：

- 显示过滤器：使用过滤语法
- 十六进制值：搜索十六进制
- 字符串：搜索文本内容
- 正则表达式：正则匹配

### 5.5 标记数据包

```
右键 -> 标记/取消标记 (Ctrl+M)
标记的数据包会高亮显示
导出时可选择只导出标记的包
```

## 6. 常用分析场景

### 6.1 分析 HTTP 请求

```
# 过滤器
http.request

# 查看请求详情
点击数据包 -> 展开 Hypertext Transfer Protocol

# 追踪完整请求响应
右键 -> 追踪流 -> TCP 流
```

### 6.2 分析 TCP 三次握手

```
# 过滤器
ip.addr == 目标IP && tcp.flags.syn == 1 || tcp.flags.ack == 1

# 顺序
# 1. SYN (Client -> Server)
# 2. SYN, ACK (Server -> Client)
# 3. ACK (Client -> Server)
```

### 6.3 分析网络延迟

```
# 查看 TCP 握手时间
tcp.flags.syn == 1 || tcp.flags.ack == 1

# 查看 TCP 重传
tcp.analysis.retransmission

# 查看 RTT
统计 -> TCP 流图形 -> 时间序列(Stevens)
```

### 6.4 排查 DNS 问题

```
# 查看 DNS 查询和响应
dns

# 查看响应时间
dns.time

# 查看失败的查询
dns.flags.rcode != 0
```

### 6.5 分析 HTTPS

```
# 解密 HTTPS 流量（需要浏览器导出密钥）
# 设置环境变量
export SSLKEYLOGFILE=/path/to/keylog.txt

# Wireshark 配置
编辑 -> 首选项 -> Protocols -> TLS -> (Pre)-Master-Secret log filename

# 过滤
tls || ssl
```

## 7. 命令行工具

### 7.1 tshark

Wireshark 的命令行版本：

```bash
# 安装
sudo apt install tshark

# 抓包
tshark -i eth0                  # 抓取 eth0 接口
tshark -i eth0 -f "port 80"     # 抓取 80 端口

# 读取文件
tshark -r capture.pcap          # 读取文件
tshark -r capture.pcap -Y "http" # 过滤 HTTP

# 输出格式
tshark -r capture.pcap -T fields -e ip.src -e ip.dst -e frame.protocols

# 统计
tshark -r capture.pcap -q -z conv,tcp    # TCP 会话统计
tshark -r capture.pcap -q -z io,phs       # 协议层级统计

# 写入文件
tshark -i eth0 -w output.pcap -c 1000  # 抓 1000 个包
```

### 7.2 常用 tshark 命令

```bash
# 实时查看 HTTP 请求
tshark -i eth0 -Y "http.request" -T fields -e http.host -e http.request.uri

# 查看 DNS 查询
tshark -i eth0 -Y "dns.qry.name" -T fields -e dns.qry.name

# 统计流量 Top 10
tshark -r capture.pcap -T fields -e ip.src | sort | uniq -c | sort -nr | head -10
```

---

## 参考链接

- [Wireshark 官网](https://www.wireshark.org/)
- [Wireshark 文档](https://www.wireshark.org/docs/)
- [显示过滤器参考](https://www.wireshark.org/docs/dfref/)
