---
title: "Ubuntu Proxy Configuration"
date: 2026-04-10T01:30:00+08:00
lastmod: 2026-05-18T13:10:00+08:00
draft: false
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

在服务器上直接运行 Clash 内核，服务器独立使用代理, 当前[clash-for-linux](https://github.com/wnlen/clash-for-linux)项目提供了更加完整、更优雅的 Linux Clash / Mihomo 运行平台。

### 1.1 下载使用

项目提供的脚本可以一键安装配置，手动提供代理链接即可：

```bash
> git clone --branch master --depth 1 https://ghfast.top/https://github.com/wnlen/clash-for-linux.git
> cd clash-for-linux
> bash install.sh
Cloning into 'clash-for-linux'...
remote: Enumerating objects: 44, done.
remote: Counting objects: 100% (44/44), done.
remote: Compressing objects: 100% (37/37), done.
remote: Total 44 (delta 1), reused 31 (delta 1), pack-reused 0 (from 0)
Receiving objects: 100% (44/44), 12.85 MiB | 5.95 MiB/s, done.
Resolving deltas: 100% (1/1), done.
⏳ 正在下载：Country.mmdb [gh-proxy]
######################################################################## 100.0%
⏳ 正在下载：geoip.metadb [gh-proxy]
######################################################################## 100.0%
⏳ 正在下载：GeoLite2-ASN.mmdb [gh-proxy]
######################################################################## 100.0%
⏳ 正在下载：GeoIP.dat [gh-proxy]
######################################################################## 100.0%
⏳ 正在下载：GeoSite.dat [gh-proxy]
######################################################################## 100.0%
⏳ 正在下载：mihomo（可在 .env 中设置 MIHOMO_DOWNLOAD_BASE / MIHOMO_DOWNLOAD_URL） [gh-proxy]
######################################################################## 100.0%
⏳ 正在下载：yq [gh-proxy]
######################################################################## 100.0%
⏳ 正在下载：subconverter [gh-proxy]
######################################################################## 100.0%
🎯 端口冲突：[mixed-port] 7890 🎲 随机分配：7892
🎯 端口冲突：[external-controller] 0.0.0.0:9090 🎲 随机分配：0.0.0.0:9091

🚀 请输入订阅链接
> http://example.com/subscription
⏳ 正在下载：subscription
######################################################################## 100.0%
✨ 订阅已生效

🎉 安装完成

🚀 当前内核：mihomo
🧬 系统架构：amd64
💻 环境模式：容器
📁 安装路径：/root/clash-for-linux
👤 安装方式：root / system
🔧 运行后端：script
📦 订阅：已配置
🔢 节点数量：46

╔════════════════════════════════════════════════╗
║                 🐱 Web 控制台                  ║
╠════════════════════════════════════════════════╣
║                                                ║
║      🔓 注意放行端口：9091                      ║
║      📶 状态：可访问                            ║
║      🏠 内网：http://127.0.0.1:9091/ui         ║
║      📡 公共：http://board.example.com         ║
║      🔑 密钥：ababaabababababa                 ║
║                                                ║
╚════════════════════════════════════════════════╝

〽️ 常用命令
  clashon            🚀 开启代理
  clashoff           ⛔ 关闭代理
  clashctl select    💫 选择节点
🕹️  控制台
  clashui            🕹️  查看 Web 控制台
  clashsecret        🔑 查看或设置 Web 密钥
📦 订阅
  clashctl add       ➕ 添加订阅
  clashctl add local ➕ 从 runtime/subscriptions 导入本地订阅
  clashctl use       💱 切换订阅
  clashctl ls        📜 查看订阅列表
📌 高级
  clashctl lan       🏠 局域网代理管理
  clashctl tun       🧪 Tun 模式管理
  clashctl mixin     🧩 Mixin 配置管理
  clashctl sub       🧩 订阅高级管理（启用 / 禁用 / 重命名 / 删除）
  clashctl upgrade   🚀 升级当前或指定内核
  clashctl update    🔄 更新项目代码
  clashctl completion 💡 导出 Bash / Zsh 补全脚本
📜 日志
  clashctl doctor    🩺 诊断面板
  clashctl log/logs  📜 查看日志

💡 显示更多帮助命令：clashctl -h

💡 clashon / clashoff 为 shell 快捷入口；新终端会自动生效
💡 当前终端若暂不可用，请先使用 clashctl on / clashctl off
```
### 1.2 配置代理

这里的`Web 控制台`提供本地和公共两个版本，公共控制台只是前端页面访问需要配合密钥使用和端口转发，这里可以手动设置节点/模式，侧栏提供监控面板监控内存使用/上传速度/下载速度等信息。

### 1.3 使用代理

注意这里的端口会主动解决端口冲突，安装完成后会输出实际使用的端口号，例如上面的 `7892`。设置系统环境变量让应用走代理：

```bash
export http_proxy="http://127.0.0.1:7892" && export https_proxy="http://127.0.0.1:7892"
export all_proxy="socks5://127.0.0.1:7892" # 注意这里是 socks5 协议
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
### 2.2 从 PC 连接到服务器

从 PC 连接到服务器搭建端口转发隧道，这里的本地端口要对应代理软件端口(可以在设置中查看)：

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
- Linux：`Tailscale` 内核模式依赖 `TUN`，通常需要宿主机管理员权限，联系服务器管理员或者使用无TUN模式。
    ```bash
    curl -fsSL https://tailscale.com/install.sh | sh
    # 启动服务
    sudo tailscale up
    # 接着会输出一个登录链接，复制到浏览器里登录后服务器就加入了你的 tailnet
    ```
  - 无 `TUN` 模式：
  ```bash
    curl -fsSL https://tailscale.com/install.sh | sh
    # 安装完后分别在两个 shell 执行
    tailscaled \
        --tun=userspace-networking \
        --socks5-server=127.0.0.1:1055 \
        --outbound-http-proxy-listen=127.0.0.1:1055
    tailscale up
    # 接着会输出一个登录链接，复制到浏览器里登录后服务器就加入了你的 tailnet

    # 无 TUN 模式下，应用不会自动走 Tailscale，要显式走代理
    # 例如
    export HTTP_PROXY=http://127.0.0.1:1055
    export HTTPS_PROXY=http://127.0.0.1:1055
    ```
- Windows：
  - 直接从 [Tailscale 官网](https://tailscale.com/download/windows) 下载 Windows 安装包，安装后登录即可。

- Android：
  - Google Play 可用：直接从 `Google Play` 安装 Android 客户端。
  - Google Play 不可用：从 [Tailscale](https://github.com/tailscale/tailscale-android) 官方提供的 [Android APK](https://pkgs.tailscale.com/stable/#android) 手动安装。

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

Tailscale 有 TUN 模式和无 TUN 模式，两种情况下使用 PC 代理的方式不同。

#### 3.4.1 有 TUN 模式

服务器有正常的 Tailscale 网卡和路由时，可以直接访问 PC 的 Tailscale IP。PC 代理软件需要开启“**允许局域网连接**”功能。

```bash
# 在服务器上设置代理（使用 PC 的 Tailscale IP）
export http_proxy="http://100.64.0.1:7890"
export https_proxy="http://100.64.0.1:7890"
export all_proxy="socks5://100.64.0.1:7890"

# 测试连接
curl -x http://100.64.0.1:7890 https://www.google.com
```

#### 3.4.2 无 TUN 模式

无 TUN 模式下，服务器不会得到一个正常的 Tailscale 网卡，也不会自动拥有到 `100.64.0.0/10` 的系统路由。

`tailscaled` 提供的 `127.0.0.1:1055` 是一个本地代理入口。它的作用是：让服务器上的应用通过这个入口访问 tailnet 里的设备，例如 PC 的 `100.64.0.1`。

要让服务器使用 PC 上的 Clash / Mihomo 代理，实际链路分成两段：

```text
Server app
  -> 127.0.0.1:1055  # server 上的 Tailscale userspace proxy
  -> 100.64.0.1:7890 # PC 上的 Clash / Mihomo 代理端口
  -> Internet
```

PC 端代理软件仍然需要开启“允许局域网连接”或等价的 `allow-lan` 配置， 先用 `curl` 做单次测试。`curl` 支持 `--preproxy`，可以显式表达这条两级代理链：

```bash
curl \
  --preproxy socks5h://127.0.0.1:1055 \
  -x http://100.64.0.1:7890 \
  https://www.google.com
```

这里两个参数的含义是：

- `--preproxy socks5h://127.0.0.1:1055`：先通过服务器本机的 Tailscale userspace proxy 进入 tailnet
- `-x http://100.64.0.1:7890`：再使用 PC 上的 HTTP 代理端口访问目标网站

不要把环境变量直接写成下面这样：

```bash
export http_proxy="http://127.0.0.1:1055"
export https_proxy="http://127.0.0.1:1055"
```

这样只是让应用把请求交给 Tailscale userspace proxy，不等价于使用 PC 上的 Clash / Mihomo 出网。

通用命令行工具通常只支持一个代理地址，没法只靠 `HTTP_PROXY` / `HTTPS_PROXY` 表达两级代理链。其它应用按下面三类处理：

| 应用能力 | 做法 |
|----------|------|
| 支持 `preproxy` / 代理链 | 直接按应用自己的代理链配置填写 `127.0.0.1:1055 -> 100.64.0.1:7890` |
| 只支持一个 `HTTP_PROXY` / `HTTPS_PROXY` | 在服务器本地起一个代理转发器，把两级代理链封装成本地单端口 |
| 完全不支持代理 | 优先用 SSH 反向端口转发，或者改用支持代理的下载/上传工具 |

例如用第二类，可以使用 `gost` 在服务器上起一个本地 HTTP 代理，把后面的两级链路封装起来：

```bash
gost \
  -L http://127.0.0.1:7891 \
  -F socks5://127.0.0.1:1055 \
  -F http://100.64.0.1:7890
```

之后其它应用只需要配置一个普通代理地址：

```bash
export http_proxy="http://127.0.0.1:7891"
export https_proxy="http://127.0.0.1:7891"

curl https://www.google.com
```

这时链路变成：

```text
Other app
  -> 127.0.0.1:7891 # server 上的 gost 本地代理
  -> 127.0.0.1:1055 # server 上的 Tailscale userspace proxy
  -> 100.64.0.1:7890 # PC 上的 Clash / Mihomo 代理端口
  -> Internet
```

#### 3.4.3 使用出口节点做ip转发
参考[官方教程](https://tailscale.com/docs/concepts/userspace-networking)，可以使用同一组网内的其它机器作为出口节点，做 ip 转发。
```bash
# 存放有关文件 避免与主tail实例冲突
mkdir -p ~/tail_exit/tail_exit_1
tailscaled \
  --tun=userspace-networking \
  --state=$HOME/tail_exit/tail_exit_1/state \
  --socket=$HOME/tail_exit/tail_exit_1/tailscaled.sock \
  --socks5-server=0.0.0.0:10551 
  --outbound-http-proxy-listen=0.0.0.0:10551

# 启动 hostname是显示的实例的名称 exit-node是出口节点的名称
tailscale --socket=$HOME/tail_exit/tail_exit_1/tailscaled.sock up
```
!!!上面是`linux`的示例，`windows`版的`pwsh`关闭tail服务命令有差异，
```powershell
# Stop the normal Tailscale service if it is running.
Stop-Service Tailscale -ErrorAction SilentlyContinue

Start-Sleep 2

# Kill leftover tailscaled processes to avoid pipe/port conflicts.
Get-Process tailscaled -ErrorAction SilentlyContinue | Stop-Process -Force

Start-Sleep 2

# Start tailscaled in userspace mode with local SOCKS5 and HTTP proxy.
Start-Process `
  -FilePath "C:\Program Files\Tailscale\tailscaled.exe" `
  -ArgumentList "--tun=userspace-networking --socks5-server=localhost:10551 --outbound-http-proxy-listen=localhost:10551" `
  -WindowStyle Hidden

Start-Sleep 5

# Bring Tailscale online.
tailscale up --reset
```
可以做成开机自启动命令
```powershell
# 管理员 PowerShell 执行下面这整段
# 需要把上面的命令包装成一个脚本文件，例如 `start-tailscale-proxy.ps1`，内容如下：
$ScriptPath = "path\to\start-tailscale-proxy.ps1"

$Action = New-ScheduledTaskAction `
  -Execute "powershell.exe" `
  -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`""

$Trigger = New-ScheduledTaskTrigger -AtLogOn

$Principal = New-ScheduledTaskPrincipal `
  -UserId "$env:USERDOMAIN\$env:USERNAME" `
  -RunLevel Highest

Register-ScheduledTask `
  -TaskName "Tailscale Userspace Proxy" `
  -Action $Action `
  -Trigger $Trigger `
  -Principal $Principal `
  -Force

# 手动运行测试
Start-ScheduledTask -TaskName "Tailscale Userspace Proxy"

# 查看端口
netstat -ano | findstr 10551
# 看到类似输出： TCP    127.0.0.1:10551    0.0.0.0:0    LISTENING
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

- [clash-for-linux](https://github.com/wnlen/clash-for-linux)
- [SSH 端口转发详解](https://www.ssh.com/academy/ssh/tunneling/example)
- [Tailscale 官方文档](https://tailscale.com/kb/)
- [ZeroTier 官方文档](https://docs.zerotier.com/)
- [GOST 转发链文档](https://gost.run/concepts/chain/)
