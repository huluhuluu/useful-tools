---
title: "SSH 命令备忘"
date: 2026-03-28T00:00:00+08:00
lastmod: 2026-03-28T00:00:00+08:00
draft: false
description: "SSH 密钥管理、配置文件、端口转发等常用功能"
slug: "ssh-guide"
tags: ["tools"]
categories: ["tools"]

comments: true
math: true
---

# SSH 命令备忘

SSH (Secure Shell) 是远程登录和服务器的标准协议，本文记录密钥管理、配置文件、端口转发等常用功能。

## 1. SSH 配置

### 1.1 安装并启动
```bash
sudo apt install openssh-server -y
sudo systemctl enable ssh
sudo systemctl start ssh
```

### 1.2 生成密钥对
```bash
# 生成密钥
ssh-keygen
```
密钥出现在`~/.ssh`目录下，以`.pub`结尾的是公钥，需要拷贝到对应的服务器的`~/.ssh/authorized_keys`文件中，私钥需要保密。
-  `~/.ssh`目录结构

    ```
    ~/.ssh/
    ├── id_ed25519          # 私钥（绝对保密）
    ├── id_ed25519.pub      # 公钥（可公开，放到服务器）
    ├── id_rsa              # RSA 私钥
    ├── id_rsa.pub          # RSA 公钥
    ├── authorized_keys     # 授权的公钥列表（服务器端）
    ├── known_hosts         # 已知主机
    ├── config              # SSH 客户端配置文件
    ├── known_hosts.old     # known_hosts 的备份
    └── *.pem               # 其他密钥文件（如 AWS）
    ```

## 1.3 SSH 配置文件    

`~/.ssh/config` 文件可以简化 SSH 连接：

```bash
# 基本格式
Host alias-name # 别名
    HostName server.example.com # ip地址或域名
    User username # 登录用户名
    Port 22 # 端口号，默认22
    IdentityFile ~/.ssh/mykey # 私钥路径,  默认是~/.ssh/id_rsa或id_ed25519
```

配置别名后可以直接使用别名连接：
```bash
# 配置后可直接用别名连接
ssh alias-name

# 等价于
ssh -p 22 username@server.example.com -i ~/.ssh/mykey
```

- 跳板机配置，ssh可以通过跳板机连接内网服务器，使用情况：跳板机可以外网访问，内网服务器只能被跳板机访问。此时可以在ssh配置文件中配置跳板机为`ProxyJump`，如：
```bash
    Host jump-host
        HostName jump.example.com
        User jumpuser
        IdentityFile ~/.ssh/jump_key
    Host internal-server
        HostName internal.example.com
        User internaluser
        IdentityFile ~/.ssh/internal_key
        ProxyJump jump-host # 通过jump-host跳转连接internal-server
```
### 1.4 密钥权限设置

```bash
# 私钥权限必须是 600
chmod 600 ~/.ssh/id_ed25519

# 公钥权限
chmod 644 ~/.ssh/id_ed25519.pub

# .ssh 目录权限
chmod 700 ~/.ssh

# authorized_keys 权限
chmod 600 ~/.ssh/authorized_keys
```

## 2. SSH 端口转发

### 2.1 本地端口转发 (Local Forward)

将远程服务的端口映射到本地端口：

```bash
# 基本格式
ssh -L 本地端口:目标主机:目标端口 user@server

# 配置别名后
ssh -L 本地端口:目标主机:目标端口 alias-name
```

### 2.2 远程端口转发 (Remote Forward)

将本地服务的端口暴露到远程服务器端口：

```bash
# 基本格式
ssh -R 远程端口:本地主机:本地端口 user@server
# 配置别名后
ssh -R 远程端口:本地主机:本地端口 alias-name
# 这里远程端口前如果缺远程ip 那么只能在服务器的127.0.0.1访问
# 设置成0.0.0.0则可以在服务器的任意ip访问
```

### 2.3 动态端口转发 (SOCKS 代理)

创建本地 SOCKS 代理，所有流量通过服务器转发：

```bash
# 创建 SOCKS5 代理
ssh -D 1080 user@server

# 设置代理，让流量通过服务器转发
export all_proxy="socks5://127.0.0.1:1080"
```

### 2.4 端口转发汇总

| 类型 | 参数 | 场景 |
|------|------|------|
| 本地转发 | `-L` | 访问远程服务端口 |
| 远程转发 | `-R` | 将本地服务端口暴露给远程 |
| 动态转发 | `-D` | 创建代理，流量全部走服务器 |

### 2.5 socat 远程转发端口

有一个常见限制：

- `机器B` 上跑服务
- `机器A` 是跳板机
- `机器B` 通过 `ssh -R` 把服务转发到 `机器A`
- 但是 `机器A` 上没有 `root`，无法修改 `sshd` 的 `GatewayPorts`

这时即使使用：

```bash
ssh -N -R 0.0.0.0:18009:127.0.0.1:8009 user@machine-a
```

端口通常还是只会绑定在 `127.0.0.1:18009`，外部机器无法直接访问。

如果 `机器A` 上可以运行 `socat`，可以再做一层用户态转发：

```bash
# 机器B：先把本机服务转发到机器A的本地端口
# 注意这里的端口必须设置不同 不然无法被socat转发
ssh -N -R 127.0.0.1:18009:127.0.0.1:8009 user@machine-a
```

```bash
# 机器A：把本地 18009 再监听到 0.0.0.0:8009
socat TCP-LISTEN:8009,bind=0.0.0.0,fork,reuseaddr TCP:127.0.0.1:18009
```

这样访问链路就是：

```text
外部设备 -> 机器A:8009 -> socat -> 机器A:18009 -> ssh -R -> 机器B:8009
```

使用时注意：

- `机器A` 需要已安装 `socat`
- `机器A` 的防火墙需要放行目标端口，例如 `8009`
- 如果目标服务是 `HTTPS`，浏览器访问时要用 `https://机器AIP:8009/`
- 这种方式适合临时暴露服务，长期使用更建议直接配置稳定入口，例如 `Tailscale`、反向代理或域名

---

## 3. 参考链接

- [SSH 官方文档](https://www.openbsd.org/openssh/manuals.html)
- [SSH 配置文件详解](https://linux.die.net/man/5/ssh_config)
- [SSH 端口转发详解](https://www.ssh.com/academy/ssh/tunneling/example)
