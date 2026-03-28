---
title: "Python 环境配置工具备忘"
date: 2026-03-26T17:00:00+08:00
lastmod: 2026-03-26T17:00:00+08:00
draft: false
description: "Python 环境管理工具介绍与配置"
slug: "python-env"
tags: ["Python", "conda", "uv"]
categories: ["实用工具"]
comments: true
math: true
---

# Python 环境配置工具备忘

`Python`环境管理是开发中的重要环节，本文介绍常用的 `miniforge`虚拟环境管理+`uv`包管理工具。

## 1. 虚拟环境管理工具 miniforge

[miniforge](https://conda-forge.org/miniforge/) 是 Anaconda/Miniconda 提供的包和环境管理器。

### 安装 miniforge

```bash
# 下载安装脚本
wget https://mirrors.zju.edu.cn/miniforge/Miniforge3-Linux-x86_64.sh

# 安装并且删除
./Miniforge3-Linux-x86_64.sh
rm -rf Miniforge3-Linux-x86_64.sh


# 重新打开终端初始化
conda init bash
source ~/.bashrc
```

### 1.2 配置镜像源

```bash
# 清华源
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/bioconda/
```

### 1.3 常用命令

```bash
# 创建环境
conda create -n myenv python=3.10

# 激活环境
conda activate myenv

# 退出环境
conda deactivate

# 查看环境列表
conda env list

# 删除环境
conda env remove -n myenv

# 导出环境
conda env export > environment.yml

# 从配置文件创建环境
conda env create -f environment.yml
```

## 2. 包管理工具 uv

[uv](https://github.com/astral-sh/uv) 是 Astral 团队开发的极速 Python 包管理器，用 Rust 编写，比 pip 快 10-100 倍。

### 2.1 安装
可以通过`shell`安装或者`pip`安装
```bash
# Linux/macOS
curl -LsSf https://astral.sh/uv/install.sh | sh

# 或通过 pip
pip install uv
```

### 2.2 常用命令

```bash
# 安装包
uv pip install numpy

# 从 requirements.txt 安装
uv pip install -r requirements.txt

# 指定版本
uv pip install numpy==1.26.0

# 卸载包
uv pip uninstall numpy

# 查看已安装包
uv pip list

# 导出依赖
uv pip freeze > requirements.txt
```

### 2.3 配合 conda 使用

推荐组合：conda 管理虚拟环境 + uv 管理包

```bash
# 创建 conda 环境
conda create -n myenv python=3.10
conda activate myenv

# 使用 uv 安装包 (速度更快)
uv pip install torch torchvision
```

---

## 参考链接

- [uv GitHub](https://github.com/astral-sh/uv)
- [uv 官方文档](https://docs.astral.sh/uv/)
- [Miniforge](https://conda-forge.org/miniforge/)
