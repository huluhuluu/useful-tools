#!/bin/bash
# =========================================================
# 欧拉系统 (openEuler) 环境初始化脚本
# 包含: Zsh, Oh-My-Zsh, Tmux, Miniforge, htop, zoxide, fzf
# =========================================================

set -e # 遇到错误立即退出

echo "========================================="
echo "开始环境初始化..."
echo "========================================="

# ---------------------------------------------------------
# 1. 基础工具安装 (Zsh, Tmux, 开发工具)
# ---------------------------------------------------------
echo "[1/6] 安装基础依赖包..."
sudo dnf install zsh tmux git wget curl -y
sudo dnf groupinstall "Development Tools" -y
sudo dnf install ncurses-devel autoconf automake libtool -y

# ---------------------------------------------------------
# 2. 配置 Zsh 和 Oh-My-Zsh
# ---------------------------------------------------------
echo "[2/6] 配置 Zsh 环境..."

# 克隆 Oh-My-Zsh (使用 Gitee 镜像加速)
if [ ! -d ~/.oh-my-zsh ]; then
    git clone https://gitee.com/mirror-hub/ohmyzsh.git ~/.oh-my-zsh
fi

# 复制默认配置
cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc

# 安装插件 (语法高亮 & 自动建议)
if [ ! -d ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]; then
    git clone https://gitee.com/mirror-hub/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
fi

if [ ! -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]; then
    git clone https://gitee.com/mirror-hub/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
fi

# 配置插件列表
# 注意：确保 plugins 行只出现一次，这里使用 sed 替换
sed -i '/^plugins=/c\plugins=(git sudo z zsh-syntax-highlighting zsh-autosuggestions fzf)' ~/.zshrc

# 添加 compinit (如果不存在)
grep -q "autoload -U compinit" ~/.zshrc || echo "autoload -U compinit && compinit" >> ~/.zshrc

# 设置默认 Shell 为 Zsh (通过 bash_profile 自动切换)
touch ~/.bash_profile
if ! grep -q "exec.*zsh" ~/.bash_profile; then
    echo 'exec $(which zsh) -l' >> ~/.bash_profile
fi

# ---------------------------------------------------------
# 3. 安装增强工具 (zoxide, fzf)
# ---------------------------------------------------------
echo "[3/6] 安装 zoxide 和 fzf..."

# 安装 zoxide (智能 cd)
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
# 配置 zoxide
grep -q "zoxide init zsh" ~/.zshrc || echo 'eval "$(zoxide init zsh)"' >> ~/.zshrc
# 确保 PATH 包含 local/bin
grep -q ".local/bin" ~/.zshrc || echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc

# 安装 fzf (模糊搜索)
if [ ! -d ~/.fzf ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all
fi

# ---------------------------------------------------------
# 4. 安装 Miniforge (Conda)
# ---------------------------------------------------------
echo "[4/6] 安装 Miniforge..."

# 检测架构并下载对应版本
ARCH=$(uname -m)
if [ "$ARCH" = "aarch64" ]; then
    MINIFORGE_URL="https://mirror.nju.edu.cn/github-release/conda-forge/miniforge/LatestRelease/Miniforge3-Linux-aarch64.sh"
elif [ "$ARCH" = "x86_64" ]; then
    MINIFORGE_URL="https://mirror.nju.edu.cn/github-release/conda-forge/miniforge/LatestRelease/Miniforge3-Linux-x86_64.sh"
else
    echo "不支持的架构: $ARCH"
    exit 1
fi

INSTALLER_FILE="Miniforge3-Installer.sh"
wget "$MINIFORGE_URL" -O "$INSTALLER_FILE"

# 静默安装到 ~/miniforge3
bash "$INSTALLER_FILE" -b -p ~/miniforge3
rm -f "$INSTALLER_FILE"

# 配置 Conda 环境变量
CONDA_INIT_LINE='source ~/miniforge3/etc/profile.d/conda.sh'
grep -qF "$CONDA_INIT_LINE" ~/.zshrc || echo "$CONDA_INIT_LINE" >> ~/.zshrc

# 赋予权限并初始化
chmod u+x ~/miniforge3/etc/profile.d/conda.sh
~/miniforge3/bin/conda init zsh

# ---------------------------------------------------------
# 5. 配置 Python 源与安装 nputop
# ---------------------------------------------------------
echo "[5/6] 配置 Python 源并安装 ascend-nputop..."

# 加载 conda 环境以便使用 pip/uv
source ~/miniforge3/etc/profile.d/conda.sh

# 安装 uv (更快的 pip 替代)
pip install uv -i https://pypi.mirrors.ustc.edu.cn/simple/

# 使用 uv 安装 ascend-nputop
uv tool install ascend-nputop -i https://pypi.mirrors.ustc.edu.cn/simple/

# ---------------------------------------------------------
# 6. 源码编译安装 htop
# ---------------------------------------------------------
echo "[6/6] 源码编译安装 htop..."

mkdir -p ~/code && cd ~/code

# 指定版本号
LATEST_VERSION="3.5.0"
HTOP_TAR="htop-latest.tar.gz"

# 下载 (使用 ghfast.top 加速)
if [ ! -f "$HTOP_TAR" ]; then
    wget "https://ghfast.top/https://github.com/htop-dev/htop/archive/refs/tags/${LATEST_VERSION}.tar.gz" -O "$HTOP_TAR"
fi

# 解压
tar xf "$HTOP_TAR"

# 进入目录并编译
cd htop-*
./autogen.sh
./configure
make -j$(nproc)
sudo make install

# ---------------------------------------------------------
# 完成
# ---------------------------------------------------------
echo ""
echo "========================================="
echo "安装完成！"
echo "请重新登录终端或执行 'exec zsh -l' 以应用所有配置。"
echo "========================================="

# 尝试自动切换当前会话到 zsh (可选，注释掉以防脚本中断)
exec zsh -l