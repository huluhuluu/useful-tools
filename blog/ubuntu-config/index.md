---
title: "Ubuntu 环境配置备忘"
date: 2026-03-26T17:00:00+08:00
lastmod: 2026-03-26T17:00:00+08:00
draft: true
description: "Ubuntu 系统开发环境配置记录"
slug: "ubuntu-config"
tags: ["Ubuntu", "Linux", "环境配置"]
categories: ["实用工具"]
comments: true
math: true
---

# Ubuntu 环境配置备忘

Ubuntu 开发环境配置记录，包括常用软件安装、开发工具配置等。

## 1. 系统更新与基础工具

### 1.1 更换国内源 (可选)

```bash
# 备份原有源
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak

# Ubuntu 22.04 清华源
sudo cat > /etc/apt/sources.list << EOF
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-security main restricted universe multiverse
EOF
```

### 1.2 系统更新

```bash
sudo apt update && sudo apt upgrade -y
```

### 1.3 基础工具安装

```bash
sudo apt install -y \
    build-essential \
    cmake \
    git \
    curl \
    wget \
    vim \
    net-tools \
    htop \
    tree \
    zip \
    unzip
```

## 2. 开发环境

### 2.1 Git 配置

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global core.editor vim

# 配置代理 (可选)
git config --global http.proxy http://127.0.0.1:7890
git config --global https.proxy http://127.0.0.1:7890
```

### 2.2 Python 环境

推荐使用 miniconda 或 pyenv 管理 Python 版本：

```bash
# 安装 miniconda
wget https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh

# 配置 conda 镜像源
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free
conda config --set show_channel_urls yes
```

详见 [Python 环境配置](/p/python-env/)。

### 2.3 Node.js 环境

```bash
# 使用 nvm 管理 Node.js
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc

nvm install --lts
nvm use --lts

# 配置 npm 镜像源
npm config set registry https://registry.npmmirror.com
```

### 2.4 Docker 安装

```bash
# 安装依赖
sudo apt install -y ca-certificates curl gnupg lsb-release

# 添加 Docker GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# 添加 Docker 源
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 安装 Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# 将用户加入 docker 组
sudo usermod -aG docker $USER

# 配置 Docker 镜像加速
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": ["https://docker.mirrors.ustc.edu.cn"]
}
EOF

sudo systemctl daemon-reload
sudo systemctl restart docker
```

## 3. GPU 环境

### 3.1 NVIDIA 驱动安装

```bash
# 查看推荐驱动
ubuntu-drivers devices

# 安装推荐驱动
sudo ubuntu-drivers autoinstall

# 或安装指定版本
sudo apt install -y nvidia-driver-535

# 验证安装
nvidia-smi
```

### 3.2 CUDA 安装

从 [NVIDIA CUDA 下载页面](https://developer.nvidia.com/cuda-downloads) 获取安装命令：

```bash
# CUDA 12.x 示例
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt update
sudo apt install -y cuda-toolkit-12-3

# 配置环境变量
echo 'export PATH=/usr/local/cuda/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
source ~/.bashrc
```

### 3.3 cuDNN 安装

```bash
# 下载对应 CUDA 版本的 cuDNN
# https://developer.nvidia.com/cudnn

# 解压并复制
tar -xvf cudnn-linux-x86_64-8.x.x.x_cudaX.Y-archive.tar.xz
cd cudnn-linux-x86_64-8.x.x.x_cudaX.Y-archive
sudo cp include/cudnn*.h /usr/local/cuda/include
sudo cp lib/libcudnn* /usr/local/cuda/lib64
sudo chmod a+r /usr/local/cuda/include/cudnn*.h /usr/local/cuda/lib64/libcudnn*
```

## 4. 常用软件

### 4.1 VSCode 安装

```bash
# 通过 snap 安装
sudo snap install code --classic

# 或下载 deb 包安装
wget -O code.deb 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64'
sudo dpkg -i code.deb
```

### 4.2 其他工具

```bash
# Flameshot 截图
sudo apt install -y flameshot

# Peek 录制 GIF
sudo apt install -y peek

# Syncthing 同步
sudo apt install -y syncthing
```

## 5. 系统优化

### 5.1 关闭自动更新

```bash
sudo sed -i 's/1/0/g' /etc/apt/apt.conf.d/10periodic
sudo sed -i 's/1/0/g' /etc/apt/apt.conf.d/20auto-upgrades
```

### 5.2 SSH 配置

```bash
sudo apt install -y openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh
```

### 5.3 防火墙配置

```bash
sudo ufw enable
sudo ufw allow ssh
sudo ufw allow 80
sudo ufw allow 443
```

---

## 参考链接

- [清华大学开源软件镜像站](https://mirrors.tuna.tsinghua.edu.cn/)
- [NVIDIA CUDA Toolkit](https://developer.nvidia.com/cuda-toolkit)
- [Docker 官方文档](https://docs.docker.com/)
