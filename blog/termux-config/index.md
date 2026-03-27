---
title: "Termux 环境配置备忘"
date: 2026-03-26T17:00:00+08:00
lastmod: 2026-03-26T17:00:00+08:00
draft: true
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

从以下渠道下载安装：

- [F-Droid](https://f-droid.org/packages/com.termux/) (推荐，版本最新)
- [GitHub Releases](https://github.com/termux/termux-app/releases)

**注意**：不要从 Google Play 安装，版本过旧且不再维护。

## 2. 基础配置

### 2.1 更换国内源

```bash
# 自动替换
termux-change-repo

# 手动替换 (清华大学镜像)
sed -i 's@^\(deb.*stable main\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/termux-packages-24 stable main@' $PREFIX/etc/apt/sources.list
sed -i 's@^\(deb.*games stable\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/game-packages-24 games stable@' $PREFIX/etc/apt/sources.list.d/game.list
sed -i 's@^\(deb.*science stable\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/science-packages-24 science stable@' $PREFIX/etc/apt/sources.list.d/science.list

pkg update && pkg upgrade -y
```

### 2.2 安装基础工具

```bash
pkg install -y \
    git \
    curl \
    wget \
    vim \
    tree \
    htop \
    neofetch \
    tmux
```

### 2.3 获取存储权限

```bash
termux-setup-storage
# 授权后会创建 ~/storage 目录，可以访问手机存储
```

## 3. 开发环境

### 3.1 Python 环境

```bash
pkg install -y python python-pip

# 配置 pip 镜像
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

# 常用库
pip install numpy requests beautifulsoup4
```

### 3.2 Node.js 环境

```bash
pkg install -y nodejs

# 配置 npm 镜像
npm config set registry https://registry.npmmirror.com

# 常用工具
npm install -g yarn pnpm
```

### 3.3 Go 环境

```bash
pkg install -y golang

# 配置代理
go env -w GOPROXY=https://goproxy.cn,direct
```

### 3.4 Rust 环境

```bash
pkg install -y rust
```

## 4. SSH 配置

### 4.1 安装并启动 SSH

```bash
pkg install -y openssh

# 生成密钥
ssh-keygen -t rsa -b 4096

# 启动 SSH 服务
sshd

# 查看用户名
whoami

# 设置密码
passwd
```

### 4.2 连接到 Termux

```bash
# 在电脑上连接
# 默认端口 8022
ssh -p 8022 <username>@<phone-ip>
```

### 4.3 开机自启动

安装 [Termux:Boot](https://f-droid.org/packages/com.termux.boot/) 应用，创建启动脚本：

```bash
mkdir -p ~/.termux/boot
echo '#!/data/data/com.termux/files/usr/bin/sh' > ~/.termux/boot/sshd
echo 'sshd' >> ~/.termux/boot/sshd
chmod +x ~/.termux/boot/sshd
```

## 5. 常用工具

### 5.1 代码编辑器

```bash
# Vim
pkg install -y vim

# Neovim
pkg install -y neovim

# Emacs
pkg install -y emacs

# nano
pkg install -y nano
```

### 5.2 版本控制

```bash
pkg install -y git

# 配置 Git
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### 5.3 数据库

```bash
# SQLite
pkg install -y sqlite

# MariaDB
pkg install -y mariadb
mysql_install_db
mysqld -u $(whoami)

# PostgreSQL
pkg install -y postgresql
```

### 5.4 Web 服务器

```bash
# Nginx
pkg install -y nginx
nginx

# Python http server
python -m http.server 8080
```

## 6. 进阶配置

### 6.1 配置 Zsh

```bash
pkg install -y zsh

# Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 或使用国内镜像
sh -c "$(curl -fsSL https://gitee.com/pocmon/ohmyzsh/raw/master/tools/install.sh)"

# 修改主题
vim ~/.zshrc
# ZSH_THEME="agnoster"  # 推荐主题
```

### 6.2 配置 Tmux

```bash
# 创建配置文件
cat > ~/.tmux.conf << EOF
set -g mouse on
set -g prefix C-a
set -g base-index 1
setw -g pane-base-index 1
EOF
```

### 6.3 安装 Linux 发行版 (proot)

使用 `proot-distro` 安装完整的 Linux 发行版：

```bash
pkg install -y proot-distro

# 安装 Ubuntu
proot-distro install ubuntu

# 进入 Ubuntu
proot-distro login ubuntu

# 安装 Alpine
proot-distro install alpine

# 进入 Alpine
proot-distro login alpine
```

## 7. 实用技巧

### 7.1 后台运行

```bash
# 使用 tmux 保持会话
tmux new -s session_name

# 断开: Ctrl+B, D
# 重新连接: tmux attach -t session_name
```

### 7.2 通知提醒

```bash
# 长时间任务完成后通知
termux-notification --title "Task Done" --content "Your task is completed"

# 震动提醒
termux-vibrate
```

### 7.3 访问剪贴板

```bash
# 获取剪贴板内容
termux-clipboard-get

# 设置剪贴板内容
termux-clipboard-set "Hello Termux"
```

### 7.4 分享文件

```bash
# 分享文件
termux-share file.txt

# 分享文本
echo "Hello" | termux-share
```

## 8. 常见问题

### 8.1 无法安装软件包

```bash
pkg update && pkg upgrade -y
```

### 8.2 磁盘空间不足

```bash
# 清理缓存
pkg clean

# 查看磁盘使用
df -h
du -sh ~/.cache
```

### 8.3 杀死后台进程

```bash
# 查找进程
ps aux | grep <process_name>

# 杀死进程
kill <pid>
```

---

## 参考链接

- [Termux Wiki](https://wiki.termux.com/)
- [Termux GitHub](https://github.com/termux)
- [清华大学 Termux 镜像](https://mirrors.tuna.tsinghua.edu.cn/help/termux/)
