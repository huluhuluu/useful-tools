---
title: "Termux 环境配置备忘"
date: 2026-03-26T17:00:00+08:00
lastmod: 2026-03-26T17:00:00+08:00
draft: false
description: "Android Termux 终端环境配置记录"
slug: "termux-config"
tags: ["Termux", "Android", "移动开发"]
categories: ["实用工具"]
comments: true
math: true
---

# Termux 环境配置备忘

Termux 是 Android 平台上的一个终端模拟器，可以运行 Linux 环境。本文记录 Termux 的基础配置。

## 1. 安装 Termux

从以下渠道下载apk安装：

- [F-Droid](https://f-droid.org/packages/com.termux/)
- [GitHub Releases](https://github.com/termux/termux-app/releases)

## 2. 基础配置

### 2.1 换源 并且安装常用包

```bash
# 自动替换
termux-change-repo
pkg update && pkg upgrade -y
pkg  install zsh gzip pv tmux htop lsof aria2 pigz git-lfs git wget neofetch screenfetch python cmake which clinfo clang netcat-openbsd openssh -y
```

### 2.2 获取存储权限

```bash
termux-setup-storage
# 授权后会创建 ~/storage 目录，可以访问手机存储
```

### 2.3 SSH 配置
```bash
pkg install openssh -y
# 设置自动启动
echo "sshd" > $HOME/.bashrc

# 生成密钥 公钥在目录 ~/.ssh/id_rsa.pub
ssh-keygen

# 启动 SSH 服务
sshd

# 查看用户名 和 ip
whoami
ifconfig

# 设置密码
passwd
```

- 连接到 Termux
    ```bash
    # 默认端口 8022
    ssh -p 8022 <username>@<ip>
    ```

### 2.4 zsh 
```bash
git clone https://gitee.com/mirror-hub/ohmyzsh.git ~/.oh-my-zsh
# 插件
cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
git clone https://gitee.com/mirror-hub/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://gitee.com/mirror-hub/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
# 启用插件
echo "autoload -U compinit && compinit" >> ~/.zshrc
sed -i '/^plugins=/c\plugins=(git sudo z zsh-syntax-highlighting zsh-autosuggestions)' ~/.zshrc
# 自动切换zsh
touch ~/.bash_profile
changeshell="exec $(which zsh) -l"
echo "$changeshell" >> ~/.bash_profile
```

---

## 3. 参考链接

- [Termux Wiki](https://wiki.termux.com/)
- [Termux GitHub](https://github.com/termux)
- [清华大学 Termux 镜像](https://mirrors.tuna.tsinghua.edu.cn/help/termux/)
