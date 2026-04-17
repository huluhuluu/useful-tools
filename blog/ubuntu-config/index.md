---
title: "Ubuntu 环境配置备忘"
date: 2026-03-26T17:00:00+08:00
lastmod: 2026-03-26T17:00:00+08:00
draft: false
description: "Ubuntu 系统开发环境配置记录"
slug: "ubuntu-config"
tags: ["tools"]
categories: ["tools"]

comments: true
math: true
---

# Ubuntu 环境配置备忘

Ubuntu 开发环境配置记录，包括常用软件安装、开发工具配置等。

## 1. 安装常用包
```bash
# 安装常用工具
sudo apt-get install zsh gzip netcat pv tmux nvtop htop lsof aria2 pigz git-lfs zoxide -y

# 配置 zsh
git clone https://gitee.com/mirror-hub/ohmyzsh.git ~/.oh-my-zsh
# 插件
cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
git clone https://gitee.com/mirror-hub/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://gitee.com/mirror-hub/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
# 启用插件
echo "autoload -U compinit && compinit" >> ~/.zshrc
sed -i '/^plugins=/c\plugins=(git sudo zsh-syntax-highlighting zsh-autosuggestions fzf)' ~/.zshrc
# 自动切换zsh
touch ~/.bash_profile
changeshell="exec $(which zsh) -l"
echo "$changeshell" >> ~/.bash_profile

# zoxide安装
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
echo 'eval "$(zoxide init zsh)"' >> ~/.zshrc
# fzf安装
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all # 运行安装脚本

# ！！重要， 配置CUDA的环境变量
echo 'export PATH="/usr/local/cuda/bin:$PATH"' >> ~/.zshrc
echo 'export LD_LIBRARY_PATH="/usr/local/cuda/lib64:$LD_LIBRARY_PATH"' >> ~/.zshrc
source ~/.zshrc # 使配置生效
```

### 2.1 安装minifoge
```bash
# 下载安装脚本
wget https://mirror.nju.edu.cn/github-release/conda-forge/miniforge/LatestRelease/Miniforge3-Linux-x86_64.sh

# 安装和删除
bash Miniforge3-Linux-x86_64.sh -b
rm -rf Miniforge3-Linux-x86_64.sh
# 设置环境变量
echo 'source ~/miniforge3/etc/profile.d/conda.sh'  >> ~/.zshrc # 这里的路径注意要匹配

# 可执行权限
chmod u+x ~/miniforge3/etc/profile.d/conda.sh

# 初始化并且配置清华源
source ~/.zshrc
conda init zsh
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/bioconda/
```

