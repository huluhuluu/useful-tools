---
title: "Python 环境配置工具备忘"
date: 2026-03-26T17:00:00+08:00
lastmod: 2026-03-26T17:00:00+08:00
draft: false
description: "Python 环境管理工具介绍与配置"
slug: "python-env"
tags: ["Python", "conda", "pyenv", "venv"]
categories: ["实用工具"]
comments: true
math: true
---

# Python 环境配置工具备忘

Python 环境管理是开发中的重要环节，本文介绍常用的 `miniforge`虚拟环境管理+`uv`包管理工具。

## 1. 版本管理工具

### 1.1 conda

`conda` 是 Anaconda/Miniconda 提供的包和环境管理器。

#### 安装 Miniconda

```bash
# 下载安装脚本
wget https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-x86_64.sh

# 安装
bash Miniconda3-latest-Linux-x86_64.sh

# 初始化
conda init bash
source ~/.bashrc
```

#### 配置镜像源

```bash
# 清华源
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/r
conda config --set show_channel_urls yes
```

#### 常用命令

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

## 2. 虚拟环境工具

### 2.1 venv

Python 内置的虚拟环境工具 

```bash
# 创建虚拟环境
python -m venv myenv

# 激活环境
# Linux/macOS
source myenv/bin/activate

# 退出环境
deactivate

# 删除环境
rm -rf myenv
```


## 3. 包管理工具


---

## 参考链接

- [pyenv GitHub](https://github.com/pyenv/pyenv)
- [Miniconda](https://docs.conda.io/en/latest/miniconda.html)
- [Poetry 文档](https://python-poetry.org/)
- [pipx GitHub](https://github.com/pypa/pipx)
