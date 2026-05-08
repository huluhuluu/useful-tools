---
title: "Ubuntu Proxy Configuration"
date: 2026-04-10T01:30:00+08:00
lastmod: 2026-04-10T01:30:00+08:00
draft: **true**
description: "内网服务器代理配置方案，包括 Clash 内核、SSH 反向端口转发、Tailscale 等方法"
slug: "ubuntu-proxy"
tags: ["tools"]
categories: ["tools"]

comments: true
math: true
---

# Ubuntu Proxy Configuration

内网服务器通常无法直接访问外网，需要通过代理访问。本文介绍三种常用方案：Clash 内核、SSH 反向端口转发、Tailscale 组网。

---

## 方案对比

| 方案 | 优点 | 缺点 | 适用场景 |
|------|------|------|----------|
| **Clash 内核** | 独立运行，不依赖外部 | 需要在服务器上运行代理程序 | 服务器资源充足，长期使用 |
| **SSH 反向转发** | 简单快速，无需额外软件 | 需要 PC 在线，连接可能断开 | 临时使用，PC 和服务器在同一局域网 |
| **Tailscale 组网** | 稳定可靠，跨网络可用 | 需要注册账号，额外安装软件 | 多台设备互联，跨网络访问 |

---

## 方案一：Clash 内核

在服务器上直接运行 Clash 内核，服务器独立使用代理。

### 1.1 下载 Clash 内核

```bash
# 下载 clash 内核（选择对应架构）
# AMD64
wget https://github.com/Dreamacro/clash/releases/download/v1.18.0/clash-linux-amd64-v1.18.0.gz
# ARM64
wget https://github.com/Dreamacro/clash/releases/download/v1.18.0/clash-linux-arm64-v1.18.0.gz

# 解压并安装
gunzip clash-linux-amd64-v1.18.0.gz
mv clash-linux-amd64-v1.18.0 clash
chmod +x clash
sudo mv clash /usr/local/bin/
```

### 1.2 配置 Clash

```bash
# 创建配置目录
mkdir -p ~/.config/clash

# 创建配置文件（从本地 PC 复制或自行编写）
# 将订阅链接或 config.yaml 放入 ~/.config/clash/config.yaml

# 示例：从本地上传配置文件
# 在本地 PC 执行：
scp ~/.config/clash/config.yaml user@server:~/.config/clash/
```

### 1.3 启动 Clash

```bash
# 前台运行（测试用）
clash -d ~/.config/clash

# 后台运行
nohup clash -d ~/.config/clash > ~/.config/clash/clash.log 2>&1 &

# 或使用 systemd 管理（推荐）
sudo tee /etc/systemd/system/clash.service << EOF
[Unit]
Description=Clash Proxy
After=network.target

[Service]
Type=simple
User=$USER
ExecStart=/usr/local/bin/clash -d /home/$USER/.config/clash
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable clash
sudo systemctl start clash
```

### 1.4 设置系统代理

```bash
export http_proxy="http://127.0.0.1:7890"
export https_proxy="http://127.0.0.1:7890"
export all_proxy="socks5://127.0.0.1:7890" # 注意这里是 socks5 协议
```

---

## 方案二：SSH 反向端口转发

通过 SSH 将本地 PC 的代理端口转发到服务器，服务器无需运行代理程序。

### 2.1 原理示意

```
┌─────────┐                      ┌─────────┐
│   PC    │                      │ Server  │
│ (内网)   │                      │ (内网)   │
│         │    SSH 反向隧道        │         │
│ :7890 ←─┼──────────────────────┼─→ :7890 │
│ (Clash) │                      │ (转发)   │
└─────────┘                      └─────────┘
```
### 2.2 从 PC 连接到服务器（更常用）

如果服务器无法直接连接 PC，可以从 PC 连接到服务器：

```bash
# 在 PC 上执行：
ssh -R 7890:127.0.0.1:7890 user@server_ip -N -f

# 此时服务器的 127.0.0.1:7890 会转发到 PC 的 127.0.0.1:7890
```

### 2.3 设置系统代理

```bash
# 在服务器上设置代理
export http_proxy="http://127.0.0.1:7890"
export https_proxy="http://127.0.0.1:7890"
export all_proxy="socks5://127.0.0.1:7890" # 注意这里是 socks5 协议
```

---

## 方案三：Tailscale 组网

使用 Tailscale 等 VPN 工具组建虚拟局域网，PC 和服务器可以互相访问。

### 3.1 安装 Tailscale

**在 PC 和服务器上分别安装：**

```bash
# Ubuntu/Debian
curl -fsSL https://tailscale.com/install.sh | sh
```

### 3.2 登录并组网

```bash
# 登录 Tailscale（在 PC 和服务器上都执行）
sudo tailscale up

# 会输出一个链接，用浏览器打开登录
```

### 3.3 查看组网设备

```bash
# 查看所有设备
tailscale status

# 输出示例：
# 100.64.0.1   mypc        linux  -
# 100.64.0.2   myserver    linux  -

# PC 的 Tailscale IP: 100.64.0.1
# 服务器的 Tailscale IP: 100.64.0.2
```

### 3.4 使用代理

组网后，服务器可以直接访问 PC 的代理端口：

```bash
# 在服务器上设置代理（使用 PC 的 Tailscale IP）
export http_proxy="http://100.64.0.1:7890"
export https_proxy="http://100.64.0.1:7890"
export all_proxy="socks5://100.64.0.1:7890"

# 测试连接
curl -x http://100.64.0.1:7890 https://www.google.com
```

### 3.5 其他组网工具

| 工具 | 特点 |
|------|------|
| **Tailscale** | 基于 WireGuard，简单易用，免费版支持 100 设备 |
| **ZeroTier** | 支持自建控制器，免费版支持 25 设备 |
| **WireGuard** | 轻量高效，需手动配置 |
| **frp** | 内网穿透工具，适合有公网服务器的情况 |

---

## 参考链接

- [Clash 官方文档](https://clash.wiki/)
- [SSH 端口转发详解](https://www.ssh.com/academy/ssh/tunneling/example)
- [Tailscale 官方文档](https://tailscale.com/kb/)
- [ZeroTier 官方文档](https://docs.zerotier.com/)