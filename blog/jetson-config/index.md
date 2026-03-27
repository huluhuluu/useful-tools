---
title: "Jetson 环境配置备忘"
date: 2026-03-26T17:00:00+08:00
lastmod: 2026-03-26T17:00:00+08:00
draft: false
description: "NVIDIA Jetson 开发板环境配置记录"
slug: "jetson-config"
tags: ["Jetson", "NVIDIA", "边缘计算"]
categories: ["实用工具"]
comments: true
math: true
---

# Jetson 环境配置备忘

NVIDIA Jetson 系列 (Nano/Xavier NX/Orin) 边缘计算开发板环境配置记录。

## 1. 系统安装

### 1.1 烧录系统

使用 [NVIDIA SDK Manager](https://developer.nvidia.com/embedded/jetpack) 或 `balenaEtcher` 烧录系统镜像。

**JetPack 组件**：
- L4T (Linux for Tegra)
- CUDA
- cuDNN
- TensorRT
- VisionWorks
- OpenCV

### 1.2 首次启动配置

```bash
# 完成初始化设置
sudo apt update && sudo apt upgrade -y
```

## 2. 基础配置

### 2.1 更换国内源

Jetson 使用 Ubuntu arm64 架构：

```bash
# 备份
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak

# 清华源 (Ubuntu 20.04, arm64)
sudo tee /etc/apt/sources.list << EOF
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ focal main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ focal-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ focal-backports main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ focal-security main restricted universe multiverse
EOF

sudo apt update
```

### 2.2 安装基础工具

```bash
sudo apt install -y \
    build-essential \
    cmake \
    git \
    curl \
    wget \
    vim \
    htop \
    tree
```

### 2.3 扩展 swap 空间

Jetson 内存有限，建议扩展 swap：

```bash
# 创建 8G swap 文件
sudo fallocate -l 8G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# 永久生效
echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab
```

## 3. 性能模式配置

### 3.1 使用 jetson_clocks

```bash
# 启用最大性能模式
sudo jetson_clocks

# 开机自动启用
sudo systemctl enable jetson_clocks
```

### 3.2 电源模式

```bash
# 查看当前模式
sudo nvpmodel -q

# 设置最大性能模式 (15W/30W 取决于设备)
sudo nvpmodel -m 0

# 设置省电模式
sudo nvpmodel -m 1
```

### 3.3 性能监控

```bash
# 实时监控
sudo tegrastats

# 或使用 jtop
sudo pip3 install jetson-stats
sudo jtop
```

## 4. GPU 环境

### 4.1 CUDA 环境变量

JetPack 已预装 CUDA，需配置环境变量：

```bash
echo 'export PATH=/usr/local/cuda/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
source ~/.bashrc

# 验证
nvcc --version
```

### 4.2 TensorRT

JetPack 已安装 TensorRT，测试：

```bash
# 查看版本
dpkg -l | grep nvinfer

# 示例位置
/usr/src/tensorrt/
```

## 5. Python 环境

### 5.1 安装 pip

```bash
sudo apt install -y python3-pip python3-dev
sudo pip3 install --upgrade pip
```

### 5.2 虚拟环境

推荐使用 `virtualenv`：

```bash
sudo pip3 install virtualenv virtualenvwrapper

echo 'export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3' >> ~/.bashrc
echo 'export WORKON_HOME=$HOME/.virtualenvs' >> ~/.bashrc
echo 'source /usr/local/bin/virtualenvwrapper.sh' >> ~/.bashrc
source ~/.bashrc

# 创建虚拟环境
mkvirtualenv myenv
workon myenv
```

### 5.3 常用 Python 库

```bash
# PyTorch for Jetson
# 参考: https://forums.developer.nvidia.com/t/pytorch-for-jetson/72048
wget https://developer.download.nvidia.com/compute/redist/jp/v502/pytorch/torch-2.0.0+nv23.05-cp38-cp38-linux_aarch64.whl
pip3 install torch-2.0.0+nv23.05-cp38-cp38-linux_aarch64.whl

# 其他库
pip3 install numpy opencv-python-headless matplotlib
```

## 6. 深度学习部署

### 6.1 安装 PyCUDA

```bash
pip3 install pycuda
```

### 6.2 ONNX Runtime

```bash
# 安装 ONNX Runtime GPU 版本
pip3 install onnxruntime-gpu
```

### 6.3 模型转换

使用 TensorRT 进行模型优化：

```bash
# ONNX -> TensorRT
trtexec --onnx=model.onnx --saveEngine=model.trt --fp16
```

## 7. 常用配置

### 7.1 开启 VNC 远程桌面

```bash
# 安装 VNC Server
sudo apt install -y vino

# 配置 VNC
gsettings set org.gnome.Vino prompt-enabled false
gsettings set org.gnome.Vino require-encryption false

# 设置密码
sudo apt install -y libvncserver-dev
sudo x11vnc -storepasswd /etc/vncpasswd

# 启动 VNC
/usr/lib/vino/vino-server
```

### 7.2 自动挂载 SD 卡

```bash
# 查看设备
lsblk

# 挂载
sudo mkdir -p /mnt/sdcard
sudo mount /dev/mmcblk1p1 /mnt/sdcard

# 开机自动挂载
echo '/dev/mmcblk1p1 /mnt/sdcard auto defaults 0 2' | sudo tee -a /etc/fstab
```

### 7.3 关闭 GUI (无头模式)

```bash
# 关闭图形界面
sudo systemctl set-default multi-user.target

# 恢复图形界面
sudo systemctl set-default graphical.target
```

---

## 参考链接

- [NVIDIA JetPack](https://developer.nvidia.com/embedded/jetpack)
- [Jetson 开发者论坛](https://forums.developer.nvidia.com/)
- [jetson-stats](https://github.com/rbonghi/jetson_stats)
