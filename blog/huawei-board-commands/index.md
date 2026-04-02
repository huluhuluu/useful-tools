---
title: "华为开发板常用命令备忘"
date: 2026-03-29T13:00:00+08:00
lastmod: 2026-03-29T13:00:00+08:00
draft: true
description: "华为 Atlas/Ascend 开发板常用命令速查"
slug: "huawei-board-commands"
tags: ["tools"]
categories: ["tools"]

comments: true
math: true
---

# 华为开发板常用命令备忘

华为 Atlas/Ascend 系列开发板（如 Atlas 200 DK、Atlas 300I）基于昇腾 NPU，用于 AI 推理和边缘计算。本文记录常用命令。

## 1. NPU 设备管理

## 1.1 新用户
创建新用户并且复制ssh公钥，同时添加到HwHiAiUser分组中
```bash
sudo adduser huluhuluu
# sudo useradd -m huluhuluu
sudo usermod -aG HwHiAiUser, docker huluhuluu
sudo usermod -aG root, wheel huluhuluu # 添加sudo权限 慎重
passwd huluhuluu # 设置密码
sudo su huluhuluu
# 设置公钥
cd /home/huluhuluu
mkdir .ssh && cd .ssh
touch authorized_keys && vim authorized_keys

# 设置权限
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys

```

### 1.2 查看 NPU 状态

```bash
# 查看 NPU 设备
npu-smi info
# 查看详细芯片信息
npu-smi info -t board -i 0  # 设备 0
# 查看设备映射信息
npu-smi info -m

# 实时监控
watch -n 1 npu-smi info
```

### 1.3 nputop
[nputop](https://github.com/youyve/nputop)是一个交互式命令行工具，专门用于监视和管理Ascend NPU上运行的进程,  但是依赖`python`环境

```bash
# 安装uv
wget -sL https://mirrors.ustc.edu.cn/github-release/astral-sh/uv/LatestRelease/uv-installer.sh | sh

# 通过uv安装nputop
# echo 'alias nputop="uvx --from ascend-nputop nputop"' >> ~/.zshrc # 每次临时使用
uv tool install ascend-nputop # 永久安装，更加建议

# 设置uv源为华为云镜像
echo 'export UV_INDEX_URL= https://repo.huaweicloud.com/repository/pypi/simple' >> ~/.zshrc
# ustc源: https://mirrors.ustc.edu.cn/pypi/simple
# 激活配置
source ~/.zshrc
# 运行 nputop：
nputop
```

### 1.4 重启 NPU 服务

```bash
# 重启驱动服务
sudo service dcgmi restart
# 或
sudo systemctl restart ascend-docker-proxy

# 查看服务状态
sudo systemctl status ascend-docker-proxy
```

### 1.5 启动docker
```bash
# export IMAGE=quay.io/ascend/vllm-ascend:v0.13.0-a3
export IMAGE=quay.io/ascend/vllm-ascend:v0.17.0rc1 # 这里的版本需要根据实际情况调整，建议使用最新版本
docker run --privileged \
    --name vllm-ascend-huluhulu \
    --shm-size=1g \
    --net=host \
    --device /dev/davinci0 \
    --device /dev/davinci1 \
    --device /dev/davinci2 \
    --device /dev/davinci3 \
    --device /dev/davinci4 \
    --device /dev/davinci5 \
    --device /dev/davinci6 \
    --device /dev/davinci7 \
    --device /dev/davinci_manager \
    --device /dev/devmm_svm \
    --device /dev/hisi_hdc \
    -v /usr/local/dcmi:/usr/local/dcmi \
    -v /usr/local/Ascend/driver/tools/hccn_tool:/usr/local/Ascend/driver/tools/hccn_tool \
    -v /usr/local/sbin/npu-smi:/usr/local/sbin/npu-smi \
    -v /usr/local/Ascend/driver/lib64/:/usr/local/Ascend/driver/lib64/ \
    -v /usr/local/Ascend/driver/version.info:/usr/local/Ascend/driver/version.info \
    -v /etc/ascend_install.info:/etc/ascend_install.info \
    -v /root/.cache:/root/.cache \
    -it $IMAGE bash -c "source /usr/local/Ascend/ascend-toolkit/set_env.sh && source /usr/local/Ascend/nnal/atb/set_env.sh && /bin/bash"
```

## 2. 安装常用包
```bash
# 换apt源
# sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup # 备份

# 写入配置（注意：必须用 sudo sh -c 包裹整个重定向）
sh -c 'echo "deb https://mirrors.ustc.edu.cn/ubuntu-ports/ jammy main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu-ports/ jammy-updates main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu-ports/ jammy-backports main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu-ports/ jammy-security main restricted universe multiverse" > /etc/apt/sources.list'
# 更新软件包列表
apt-get update

# 安装常用工具
apt-get install sudo zsh gzip netcat pv tmux htop lsof aria2 pigz git-lfs -y

# 配置 zsh
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

# 切换到zsh
exec zsh -l
```

### 2.1 安装minifoge
```bash
# 下载aarch版安装脚本
wget https://mirror.nju.edu.cn/github-release/conda-forge/miniforge/LatestRelease/Miniforge3-Linux-aarch64.sh
# 安装和删除
bash Miniforge3-Linux-aarch64.sh -b
rm -rf Miniforge3-Linux-aarch64.sh
# 设置环境变量
echo 'source ~/miniforge3/etc/profile.d/conda.sh' >> ~/.zshrc # 这里的路径注意要匹配

# 可执行权限
chmod u+x ~/miniforge3/etc/profile.d/conda.sh
source ~/.zshrc # 使配置生效

# 初始化并且配置清华源
conda init zsh && source ~/.zshrc
# 配置ustc源
conda config --add channels https://mirrors.ustc.edu.cn/anaconda/pkgs/main/
conda config --add channels https://mirrors.ustc.edu.cn/anaconda/pkgs/free/
conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/conda-forge/
conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/bioconda/
```

## 2. CANN 环境

CANN (Compute Architecture for Neural Networks) 是华为 AI 异构计算架构。

### 2.1 环境变量

```bash
# 设置 CANN 环境变量
source /usr/local/Ascend/ascend-toolkit/set_env.sh
source /usr/local/Ascend/nnal/atc/set_env.sh

# 查看环境变量
echo $ASCEND_HOME
echo $LD_LIBRARY_PATH
```

---

## 参考链接

- [华为昇腾社区](https://www.hiascend.com/)
- [CANN 开发文档](https://www.hiascend.com/document)
- [Atlas 开发者文档](https://support.huawei.com/enterprise/zh/doc/EDOC1100207487)
- [vllm Ascend 文档](https://docs.vllm.ai/projects/ascend/en/latest/tutorials/models/GLM5.html)

