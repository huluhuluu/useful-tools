---
title: "华为开发板常用命令备忘"
date: 2026-03-29T13:00:00+08:00
lastmod: 2026-03-29T13:00:00+08:00
draft: false
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

### 1.1 新用户
创建新用户并且复制ssh公钥，同时添加到HwHiAiUser分组中
```bash
sudo adduser huluhuluu
# sudo useradd -m huluhuluu
sudo usermod -aG HwHiAiUser,docker huluhuluu
sudo usermod -aG root,wheel huluhuluu # 添加sudo权限 慎重
passwd huluhuluu # 设置密码
sudo su huluhuluu
# 设置公钥
cd ~
mkdir .ssh && cd .ssh
touch authorized_keys && vim authorized_keys # 放入公钥

# 设置权限
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```
- 如果根目录磁盘不够用户可能需要挂载到其他磁盘上，参考流程：
```bash
new_user=huluhuluu
useradd -M -U -d "/home/$new_user" -s /bin/bash "$new_user" # 创建用户
#  在目标目录下初始化家目录 下面是/home/data下初始化 需要自己替换
install -d -m 700 -o "$new_user" -g "$new_user" \
  "/home/data/$new_user"
cp -a /etc/skel/. "/home/data/$new_user/"
chown -R "$new_user:$new_user" "/home/data/$new_user"

# 创建挂载入口；未挂载时仅 root 可访问
install -d -m 700 -o root -g root "/home/$new_user"

# 配置开机挂载，并立即挂载
printf '%s %s none bind,x-systemd.requires-mounts-for=/home/data 0 0\n' \
  "/home/data/$new_user" "/home/$new_user" >> /etc/fstab

findmnt --verify --verbose
systemctl daemon-reload
systemctl start "$(systemd-escape --path --suffix=mount "/home/$new_user")"

# 检查挂载情况
findmnt -M /home/$new_user

sudo usermod -aG HwHiAiUser,docker $new_user
sudo usermod -aG root,wheel $new_user # 添加sudo权限 慎重
```
- 如果是迁移已有用户到新挂载目录(建议逐条执行)：
```bash
# 1. 设置变量、预复制
user=huluhuluu
source_dir="/home/$user" # 原目录
target_dir="/home/data/$user" # 目标目录
stamp="$(date +%Y%m%d-%H%M%S)" # 备份用的目录名
backup_dir="/home/data/backups/${user}-${stamp}" # 备份目录
old_dir="${source_dir}.pre-migration-${stamp}"

# 目录检查 若这里失败，修正 source_dir 后重新执行
test "$source_dir" = "$(getent passwd "$user" | cut -d: -f6)"
test -d "$source_dir"
mountpoint -q /home/data

# 创建迁移目标和临时备份目录
mkdir -p "$target_dir" "$backup_dir"
chmod 700 "$backup_dir"

# 保存原挂载配置，便于恢复
cp -a /etc/fstab "$backup_dir/fstab"
getent shadow "$user" |
  cut -d: -f8 > "$backup_dir/account-expiry"
# 运行期间预复制，减少维护窗口内需要复制的数据
rsync -aHAXx --numeric-ids --info=progress2 \
  "$source_dir/" "$target_dir/"

# 2. 暂停登录、停止任务
pkill -TERM -u "$user" || true # kill执行中的进程
sleep 5
pgrep -a -u "$user" || true  # 列出仍存活的用户进程

# 检查其他账号是否还有进程使用源目录
lsof -nP +D "$source_dir" || true

3. **完整备份、最终同步和切换**
# 复制一份完整临时备份
rsync -aHAXx --numeric-ids --info=progress2 \
  "$source_dir/" "$backup_dir/home/"

# 最终同步到正式目标
rsync -aHAXx --numeric-ids --delete-delay \
  "$source_dir/" "$target_dir/"

# 将原目录改名留存；此时还没有释放系统盘空间
mv -- "$source_dir" "$old_dir"

# 在原路径创建空挂载点
install -d -o root -g root -m 700 "$source_dir"

# 添加开机 bind mount 配置
# 要求 /home/data 挂载完成后，再挂载用户家目录
printf '%s %s none bind,x-systemd.requires-mounts-for=/home/data 0 0\n' \
  "$target_dir" "$source_dir" >> /etc/fstab

# 检查 fstab 配置是否有效
findmnt --verify --verbose

# 让 systemd 重新读取挂载配置
systemctl daemon-reload

# 启动该家目录对应的挂载单元，建立 bind mount
systemctl start "$(systemd-escape --path --suffix=mount "$source_dir")"

# 4. 验证并恢复登录
findmnt -T "$source_dir"

# 比较设备号和 inode
# 两个路径应指向同一个目录；不一致则停止
test "$(stat -Lc '%d:%i' "$source_dir")" = \
     "$(stat -Lc '%d:%i' "$target_dir")"

# 以该用户身份进入家目录，测试创建和删除文件
sudo -u "$user" -H bash -c \
  'cd ~ && touch .migration-test && rm .migration-test'

# 输出正式目录和两份保留数据的位置，方便记录
printf '迁移目标：%s\n临时备份：%s\n原目录：%s\n' \
  "$target_dir" "$backup_dir" "$old_dir"

sudo usermod -aG HwHiAiUser,docker $user
sudo usermod -aG root,wheel $user # 添加sudo权限 慎重
```
- 如果是已有目录但是没有用户，需要创建用户并且绑定目录 然后做目录的挂载绑定：
```bash
# 1. 创建账号、预复制
user=swj
source_dir="/home/$user" # 原目录
target_dir="/home/data/$user" # 目标目录
stamp="$(date +%Y%m%d-%H%M%S)"
backup_dir="/home/data/backups/${user}-${stamp}"
old_dir="${source_dir}.pre-migration-${stamp}"

# 确认绑定位置
mountpoint -q /home/data

# 创建账号，登记已有家目录路径，不自动创建目录
# 暂时设置为过期，迁移完成后再允许登录
useradd -M -U -e 1970-01-02 \
  -d "$source_dir" -s /bin/bash "$user"

mkdir -p "$target_dir" "$backup_dir"
chmod 700 "$backup_dir"
cp -a /etc/fstab "$backup_dir/fstab"

# 预复制，保留文件原来的权限、属主等
rsync -aHAXx --numeric-ids --info=progress2 \
  "$source_dir/" "$target_dir/"

# 2. 查看占用目录的进程
lsof -nP +D "$source_dir" || true
# 手动kill 原进程可能与root有关

# 3. 备份 同步
# 停写后的原始备份，保留原属主
rsync -aHAXx --numeric-ids --info=progress2 \
  "$source_dir/" "$backup_dir/home/"

# 最终同步并按内容校验
rsync -aHAXx --numeric-ids --delete-delay \
  "$source_dir/" "$target_dir/"

# 补齐新用户默认配置，不覆盖已有同名文件
cp -an /etc/skel/. "$target_dir/"

# 将迁移目标交给新用户；原目录和备份保持原属主
chown -R "$user:$user" "$target_dir"
chmod 700 "$target_dir"

# 4. 建立绑定、启用账号
# 保留系统盘原目录
mv -- "$source_dir" "$old_dir"
install -d -o root -g root -m 700 "$source_dir"

# 配置开机绑定
printf '%s %s none bind,x-systemd.requires-mounts-for=/home/data 0 0\n' \
  "$target_dir" "$source_dir" >> /etc/fstab

findmnt --verify --verbose
systemctl daemon-reload
systemctl start "$(systemd-escape --path --suffix=mount "$source_dir")"

# 验证挂载
findmnt -T "$source_dir"
test "$(stat -Lc '%d:%i' "$source_dir")" = \
     "$(stat -Lc '%d:%i' "$target_dir")"

# 取消临时过期设置，并设置登录密码
usermod --expiredate -1 "$user"
passwd "$user"

# 验证新用户可以使用家目录
sudo -u "$user" -H bash -c \
  'cd ~ && pwd && touch .migration-test && rm .migration-test'

printf '备份：%s\n原目录：%s\n' "$backup_dir" "$old_dir"
sudo usermod -aG HwHiAiUser,docker $user
sudo usermod -aG root,wheel $user # 添加sudo权限 慎重
```

### 1.2 配置
欧拉系统，快速配置可直接用当前目录下的安装脚本`bash install-dump.sh`
```bash
[ ~]$ cat /etc/os-release
NAME="Huawei Cloud EulerOS"
VERSION="2.0 (aarch64)"
ID="hce"
VERSION_ID="2.0"
PRETTY_NAME="Huawei Cloud EulerOS 2.0 (aarch64)"
ANSI_COLOR="0;31"

sudo dnf install zsh tmux -y
# 配置 zsh
git clone https://gitee.com/mirror-hub/ohmyzsh.git ~/.oh-my-zsh
# 插件
cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
git clone https://gitee.com/mirror-hub/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://gitee.com/mirror-hub/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
# 启用插件
echo "autoload -U compinit && compinit" >> ~/.zshrc
sed -i '/^plugins=/c\plugins=(git sudo z zsh-syntax-highlighting zsh-autosuggestions fzf)' ~/.zshrc
# 自动切换zsh
touch ~/.bash_profile
changeshell="exec $(which zsh) -l"
echo "$changeshell" >> ~/.bash_profile

# zoxide安装
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc # 根据输出判断
echo 'eval "$(zoxide init zsh)"' >> ~/.zshrc
# fzf安装
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all # 运行安装脚本ps

source ~/.zshrc # 使配置生效

# 切换到zsh
exec zsh -l

echo 'source /usr/local/Ascend/cann-9.0.1/set_env.sh' >> ~/.zshrc # 添加 CANN 环境变量配置
echo 'source /usr/local/Ascend/nnal/atb/set_env.sh' >> ~/.zshrc # 添加 ATB 环境变量配置
sudo dnf install jemalloc -y
echo 'export LD_PRELOAD=/usr/lib64/libjemalloc.so.2:$LD_PRELOAD' >> ~/.zshrc # 添加 jemalloc 预加载配置; 不同系统下位置会有不同
source ~/.zshrc # 使配置生效
```

配置miniforge
```bash
# 下载aarch版安装脚本
wget https://mirror.nju.edu.cn/github-release/conda-forge/miniforge/LatestRelease/Miniforge3-Linux-aarch64.sh
# 安装和删除
bash Miniforge3-Linux-aarch64.sh -b
rm -rf Miniforge3-Linux-aarch64.sh
# 设置环境变量
echo 'source ~/miniforge3/etc/profile.d/conda.sh'  >> -a ~/.zshrc # 这里的路径注意要匹配

# 可执行权限
chmod u+x ~/miniforge3/etc/profile.d/conda.sh
source ~/.zshrc
conda init zsh

# 华为源
# conda config --add channels https://mirrors.huaweicloud.com/anaconda/pkgs/main/
# conda config --add channels https://mirrors.huaweicloud.com/anaconda/pkgs/free/
# conda config --add channels https://mirrors.huaweicloud.com/anaconda/cloud/conda-forge/
# conda config --add channels https://mirrors.huaweicloud.com/anaconda/cloud/bioconda/
# 配置清华源
# conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/ 
# conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/  

# 安装nputop
# 测试华为源不如ustc快 # https://pypi.tuna.tsinghua.edu.cn/simple/
pip install uv -i https://pypi.mirrors.ustc.edu.cn/simple/
uv tool install ascend-nputop -i https://pypi.mirrors.ustc.edu.cn/simple/

# 源码编译 安装htop
sudo dnf groupinstall "Development Tools" -y
sudo dnf install ncurses-devel autoconf automake libtool -y
mkdir code && cd code
# 1. 指定版本号 (使用加速代理)
LATEST_VERSION="3.5.0"
# 2. 下载源码包 (使用加速代理)
wget "https://ghfast.top/https://github.com/htop-dev/htop/archive/refs/tags/${LATEST_VERSION}.tar.gz" -O htop-latest.tar.gz

# 2. 解压
tar xf htop-latest.tar.gz

# 3. 进入目录（注意：解压后的文件夹名是 htop-版本号） 编译
cd htop-*
./autogen.sh && ./configure && make -j$(nproc) && sudo make install
```

### 1.3 查看 NPU 状态

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

### 1.5 重启 NPU 服务

```bash
# 重启驱动服务
sudo service dcgmi restart
# 或
sudo systemctl restart ascend-docker-proxy

# 查看服务状态
sudo systemctl status ascend-docker-proxy
```

### 1.6 启动docker
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

## 2. 环境配置参考

- 硬件环境: `CANN 9.0.1` + ` EulerOS release 2.0`
- 待配置环境：[vllm v23.0](https://github.com/vllm-project/vllm/tree/v0.23.0) + [vllm-ascend v0.23.0rc1](https://github.com/vllm-project/vllm-ascend/tree/v0.23.0rc1) + [TorchNPU v26.0.0](https://www.hiascend.com/developer/software/ai-frameworks/pytorch/download?versionId=172&ids=26958bcc909e4cd48fa56d4c4a43ebec%2C98%2C107%2C1%2C6%2C3%2C)

```bash
# 1. 激活环境变量
source /usr/local/Ascend/cann-9.0.1/set_env.sh  # CANN 环境变量配置
source /usr/local/Ascend/nnal/atb/set_env.sh # ATB 环境变量配置

# 虚拟环境
conda create -n my-vllm python=3.12 pip -y
conda activate my-vllm
pip install uv -i https://pypi.mirrors.ustc.edu.cn/simple/

# 2. 源码安装vllm
git clone -b v0.23.0 https://github.com/vllm-project/vllm.git
cd vllm
VLLM_TARGET_DEVICE=empty uv pip install -e . --index-url https://pypi.tuna.tsinghua.edu.cn/simple
cd ..

# 3. 源码安装vllm-ascend
git clone -b v0.23.0rc1  https://github.com/vllm-project/vllm-ascend.git
cd vllm-ascend
git submodule update --init --recursive
# !!! 源码安装 主要问题来源源码安装的vllm没有版本标记
export VLLM_VERSION=0.23.0
uv pip install -e .  \
  --index-url https://pypi.tuna.tsinghua.edu.cn/simple \
  --extra-index-url https://mirrors.huaweicloud.com/ascend/repos/pypi \
  --extra-index-url https://mirrors.huaweicloud.com/ascend/repos/pypi/variant \
  --index-strategy unsafe-best-match
cd ..
```

---

## 参考链接

- [华为昇腾社区](https://www.hiascend.com/)
- [CANN 开发文档](https://www.hiascend.com/document)
- [Atlas 开发者文档](https://support.huawei.com/enterprise/zh/doc/EDOC1100207487)
- [vllm Ascend 文档](https://docs.vllm.ai/projects/ascend/en/latest/tutorials/models/GLM5.html)

