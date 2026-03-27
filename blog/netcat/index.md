---
title: "Netcat 不加密传输工具"
date: 2026-03-26T17:00:00+08:00
lastmod: 2026-03-26T17:00:00+08:00
draft: false
description: "Netcat 网络工具在局域网文件传输中的应用"
slug: "netcat"
tags: ["Netcat", "Gzip", "文件传输"]
categories: ["实用工具"]
comments: true
math: true
---

# Netcat 不加密传输工具

[Netcat](https://nmap.org/ncat/) (nc) 是一个功能强大的网络工具，可以在**局域网**中以**不加密**方式进行文件传输，速率大于SCP加密文件传输方式。

## 1 安装

```bash
# Ubuntu/Debian
sudo apt install -y netcat
```

### 1.1 基本参数

| 参数 | 说明 |
|------|------|
| `-l` | 监听模式 |
| `-p` | 指定端口 |
| `-v` | 显示详细信息 |
| `-n` | 不解析 DNS |
| `-w` | 超时时间 (秒) |
| `-q` | 传输完成后等待时间 |
| `-u` | UDP 模式 |

## 2. 文件传输
### 2.1 发送单个文件
可以结合 `pv` (Pipe Viewer) 显示传输进度, 安装 `pv`命令如下
```bash
sudo apt install -y pv
```

- 接收端需要打开端口，并且把接受到的内容保存到文件中, 下面`<port>`表示端口，file表示保存的文件名
    ```bash
    nc -l -p <port> | pv > file
    ```
- 发送端需要向指定的ip和端口发送文件, 下面ip和端口表示**接收端**ip和端口，需要**先启动接收端命令**， file表示发送的文件
    ```bash
    pv file | nc <ip> <port>
    ```

### 2.2 压缩传输

直接传输文件/目录传输量太大，结合 `tar + gzip` 压缩可以减少传输时间：

```bash
# 发送端 (压缩) -p 后面的数字表示线程，
# file.tar.gz表示发送的文件压缩包名，
# path/to/directory 表示发送的文件目录/文件
tar --use-compress-program="pigz -p 8" -cvf file.tar.gz /path/to/directory 

# 接收端 (解压) file.tar.gz表示接收的文件名
tar -xzvf file.tar.gz
```
### 2.3 断点续传

使用 `dd` 和 `seek` 实现简单续传：

```bash
# 查看已接收文件大小
ls -l partial_file

# 接收端 - 从指定位置继续接收
nc -l -p 8888 >> partial_file

# 发送端 - 从指定位置继续发送
dd if=large_file bs=1 skip=<already_sent_bytes> | nc <receiver_ip> 8888
```

### 2.4 测试ip:port连通性
从发送端设备向目标接收端对应的ip+port发送消息，测试连通性
```bash
# 接受端
nc -l -p <port>

# 发送端
echo "hello" | nc <ip> <port>
```

### 2.5 端口扫描

```bash
# 扫描单个端口
nc -zv target_ip 80

# 扫描端口范围
nc -zv target_ip 20-100

# 扫描多个端口
nc -zv target_ip 80 443 8080
```

### 2.6. 注意事项
1. **安全性**：Netcat 传输不加密，敏感数据需要配合加密工具
2. **防火墙**：确保防火墙开放对应端口

---

## 参考链接

- [Netcat Wikipedia](https://en.wikipedia.org/wiki/Netcat)
- [Nmap Ncat](https://nmap.org/ncat/)
- [socat 文档](http://www.dest-unreach.org/socat/)
