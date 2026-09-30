#!/bin/bash
# =========================================================
# 欧拉系统 (openEuler) 环境初始化脚本 v2.2
# 修复: Conda 安装稳定性、Zoxide 环境变量注入、镜像加速
# =========================================================

set -e # 遇到严重错误立即退出

# ------------------- 配置区域 -------------------
GH_PROXY="https://ghfast.top" 
HTOP_VERSION="3.5.0"
CONDA_PATH="$HOME/miniforge3"
# ----------------------------------------------

echo "========================================="
echo "开始环境初始化 (v2.2)..."
echo "========================================="

# ---------------------------------------------------------
# 1. 基础工具安装
# ---------------------------------------------------------
echo "[1/7] 检查并安装基础依赖包..."
sudo dnf install zsh tmux git wget curl -y
sudo dnf groupinstall "Development Tools" -y
sudo dnf install ncurses-devel autoconf automake libtool -y

# ---------------------------------------------------------
# 2. 配置 Zsh 和 Oh-My-Zsh
# ---------------------------------------------------------
echo "[2/7] 配置 Zsh 环境..."

if [ ! -d ~/.oh-my-zsh ]; then
    echo "  -> 克隆 Oh-My-Zsh..."
    git clone ${GH_PROXY}/https://gitee.com/mirror-hub/ohmyzsh.git ~/.oh-my-zsh
else
    echo "  -> Oh-My-Zsh 已存在，跳过。"
fi

if [ ! -f ~/.zshrc ]; then
    cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
fi

PLUGIN_DIR=~/.oh-my-zsh/custom/plugins
if [ ! -d "$PLUGIN_DIR/zsh-syntax-highlighting" ]; then
    git clone ${GH_PROXY}/https://gitee.com/mirror-hub/zsh-syntax-highlighting.git "$PLUGIN_DIR/zsh-syntax-highlighting"
fi
if [ ! -d "$PLUGIN_DIR/zsh-autosuggestions" ]; then
    git clone ${GH_PROXY}/https://gitee.com/mirror-hub/zsh-autosuggestions.git "$PLUGIN_DIR/zsh-autosuggestions"
fi

if ! grep -q "zsh-syntax-highlighting" ~/.zshrc; then
    sed -i '/^plugins=/c\plugins=(git sudo z zsh-syntax-highlighting zsh-autosuggestions fzf)' ~/.zshrc
fi
grep -q "autoload -U compinit" ~/.zshrc || echo "autoload -U compinit && compinit" >> ~/.zshrc

touch ~/.bash_profile
if ! grep -q "exec.*zsh" ~/.bash_profile; then
    echo 'exec $(which zsh) -l' >> ~/.bash_profile
fi

# ---------------------------------------------------------
# 3. 安装增强工具 (zoxide, fzf)
# ---------------------------------------------------------
echo "[3/7] 检查并安装 zoxide 和 fzf..."

# 3.1 安装 zoxide
if ! command -v zoxide &> /dev/null; then
    echo "  -> 安装 zoxide..."
    curl -sSfL ${GH_PROXY}/https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
else
    echo "  -> zoxide 已安装，跳过。"
fi

# 3.2 配置 zoxide 环境变量 (修复点：精确匹配)
ZOXIDE_INIT='eval "$(zoxide init zsh)"'
LOCAL_BIN_EXPORT='export PATH="$HOME/.local/bin:$PATH"'

# 添加 zoxide init
grep -qF "$ZOXIDE_INIT" ~/.zshrc || echo "$ZOXIDE_INIT" >> ~/.zshrc

# 添加 local/bin 到 PATH (修复点：使用 -F 固定字符串匹配，避免正则干扰)
grep -qF "$LOCAL_BIN_EXPORT" ~/.zshrc || echo "$LOCAL_BIN_EXPORT" >> ~/.zshrc


# 3.3 安装 fzf
if [ ! -d ~/.fzf ]; then
    echo "  -> 克隆并安装 fzf..."
    git clone --depth 1 ${GH_PROXY}/https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all
else
    echo "  -> fzf 已存在，跳过。"
fi

# ---------------------------------------------------------
# 4. 安装 Miniforge (Conda) - 修复版
# ---------------------------------------------------------
echo "[4/7] 检查并安装 Miniforge..."

CONDA_INIT_LINE="source $CONDA_PATH/etc/profile.d/conda.sh"

if [ -d "$CONDA_PATH" ]; then
    # 如果目录存在，检查是否已经初始化过环境变量
    if grep -qF "$CONDA_INIT_LINE" ~/.zshrc; then
        echo "  -> Miniforge 已安装且环境变量已配置，跳过。"
    else
        echo "  -> Miniforge 目录存在但未配置环境变量，正在补充配置..."
        echo "$CONDA_INIT_LINE" >> ~/.zshrc
        "$CONDA_PATH/bin/conda" init zsh
    fi
else
    echo "  -> 开始下载并安装 Miniforge..."
    ARCH=$(uname -m)
    if [ "$ARCH" = "aarch64" ]; then
        MINIFORGE_URL="${GH_PROXY}/https://mirror.nju.edu.cn/github-release/conda-forge/miniforge/LatestRelease/Miniforge3-Linux-aarch64.sh"
    elif [ "$ARCH" = "x86_64" ]; then
        MINIFORGE_URL="${GH_PROXY}/https://mirror.nju.edu.cn/github-release/conda-forge/miniforge/LatestRelease/Miniforge3-Linux-x86_64.sh"
    else
        echo "错误: 不支持的架构 $ARCH"
        exit 1
    fi

    INSTALLER_FILE="/tmp/Miniforge3-Installer.sh"
    wget "$MINIFORGE_URL" -O "$INSTALLER_FILE"
    
    # 静默安装
    bash "$INSTALLER_FILE" -b -p "$CONDA_PATH"
    rm -f "$INSTALLER_FILE"
    
    # 配置环境变量
    echo "$CONDA_INIT_LINE" >> ~/.zshrc
    
    # 赋予权限并初始化
    chmod u+x "$CONDA_PATH/etc/profile.d/conda.sh"
    "$CONDA_PATH/bin/conda" init zsh
    echo "  -> Miniforge 安装完成。"
fi

# ---------------------------------------------------------
# 5. 配置 Python 源与安装 nputop
# ---------------------------------------------------------
echo "[5/7] 配置 Python 环境并安装 ascend-nputop..."

# 【关键】加载 Conda 环境
if [ -f "$CONDA_PATH/etc/profile.d/conda.sh" ]; then
    source "$CONDA_PATH/etc/profile.d/conda.sh"
    # 确保激活 base 环境，这样 pip 才会指向 miniforge
    conda activate base
else
    echo "警告: 找不到 Conda 初始化脚本，尝试直接使用系统 pip..."
fi

# 检查并安装 uv
if ! command -v uv &> /dev/null; then
    echo "  -> 安装 uv..."
    pip install uv -i https://pypi.mirrors.ustc.edu.cn/simple/
else
    echo "  -> uv 已存在。"
fi

# 检查并安装 ascend-nputop
if ! command -v ascend-nputop &> /dev/null; then
    echo "  -> 安装 ascend-nputop..."
    uv tool install ascend-nputop -i https://pypi.mirrors.ustc.edu.cn/simple/
else
    echo "  -> ascend-nputop 已存在。"
fi

# ---------------------------------------------------------
# 6. 源码编译安装 htop
# ---------------------------------------------------------
echo "[6/7] 检查并编译 htop ${HTOP_VERSION}..."

mkdir -p ~/code && cd ~/code

HTOP_DIR="htop-${HTOP_VERSION}"
HTOP_TAR="htop-latest.tar.gz"

if command -v htop &> /dev/null; then
    INSTALLED_VER=$(htop --version | head -n1 | awk '{print $2}')
    echo "  -> htop 已安装 (版本: $INSTALLED_VER)，跳过编译。"
else
    echo "  -> htop 未检测到，开始编译..."
    
    if [ ! -f "$HTOP_TAR" ]; then
        echo "  -> 下载源码包..."
        wget "${GH_PROXY}/https://github.com/htop-dev/htop/archive/refs/tags/${HTOP_VERSION}.tar.gz" -O "$HTOP_TAR"
    fi

    if [ ! -d "$HTOP_DIR" ]; then
        echo "  -> 解压源码..."
        tar xf "$HTOP_TAR"
    fi

    cd "$HTOP_DIR"
    ./autogen.sh
    ./configure
    make -j$(nproc)
    sudo make install
    cd ~/code
fi

# ---------------------------------------------------------
# 7. 完成提示
# ---------------------------------------------------------
echo ""
echo "========================================="
echo "✅ 所有步骤执行完毕！"
echo "========================================="
echo "⚠️ 重要提示:"
echo "1. 请关闭当前终端窗口，重新打开以加载 Zsh 和 Conda 配置。"
echo "2. 或者在当前窗口执行: source ~/.zshrc && exec zsh -l"
echo "========================================="