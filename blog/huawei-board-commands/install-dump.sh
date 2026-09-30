#!/bin/bash
# =========================================================
# 欧拉系统 (openEuler) 环境初始化脚本 v2.4
# 修复: Conda 安装稳定性、Zoxide 环境变量注入、镜像加速
# 新增: Ascend CANN / ATB / jemalloc 环境变量配置
# v2.4: 修正代理前缀误用、htop 包名版本化、CANN 路径自动探测、
#       LD_PRELOAD 幂等且无尾部冒号、uv 安装后 PATH 生效
# =========================================================

set -e # 遇到严重错误立即退出
set -u # 引用未定义变量时报错

# ------------------- 配置区域 -------------------
GH_PROXY="https://ghfast.top"          # 仅用于 github.com / raw.githubusercontent.com
HTOP_VERSION="3.5.0"
CONDA_PATH="$HOME/miniforge3"

ASCEND_ROOT="/usr/local/Ascend"
CANN_FALLBACK_VERSION="9.0.1"          # 探测不到时使用的默认版本
JEMALLOC_SO="/usr/lib64/libjemalloc.so.2"
# ----------------------------------------------

echo "========================================="
echo "开始环境初始化 (v2.4)..."
echo "========================================="

# ---------------------------------------------------------
# 1. 基础工具安装
# ---------------------------------------------------------
echo "[1/8] 检查并安装基础依赖包..."
sudo dnf install zsh tmux git wget curl -y
sudo dnf groupinstall "Development Tools" -y
sudo dnf install ncurses-devel autoconf automake libtool -y
sudo dnf install jemalloc -y 

# ---------------------------------------------------------
# 2. 配置 Zsh 和 Oh-My-Zsh
# ---------------------------------------------------------
echo "[2/8] 配置 Zsh 环境..."

# 注意: gitee.com 是国内镜像，不能加 GitHub 加速前缀（加了会 403）
if [ ! -d ~/.oh-my-zsh ]; then
    echo "  -> 克隆 Oh-My-Zsh..."
    git clone https://gitee.com/mirror-hub/ohmyzsh.git ~/.oh-my-zsh
else
    echo "  -> Oh-My-Zsh 已存在，跳过。"
fi

# 模板缺失时退化为空文件，避免 cp 失败触发 set -e 终止脚本
if [ ! -f ~/.zshrc ]; then
    if [ -f ~/.oh-my-zsh/templates/zshrc.zsh-template ]; then
        cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
    else
        echo "  -> 警告: 未找到 zshrc 模板，创建空 ~/.zshrc"
        touch ~/.zshrc
    fi
fi

PLUGIN_DIR=~/.oh-my-zsh/custom/plugins
if [ ! -d "$PLUGIN_DIR/zsh-syntax-highlighting" ]; then
    git clone https://gitee.com/mirror-hub/zsh-syntax-highlighting.git "$PLUGIN_DIR/zsh-syntax-highlighting"
fi
if [ ! -d "$PLUGIN_DIR/zsh-autosuggestions" ]; then
    git clone https://gitee.com/mirror-hub/zsh-autosuggestions.git "$PLUGIN_DIR/zsh-autosuggestions"
fi

# 插件行: 不存在则追加，存在但内容不符则替换（可修复被手改过的行）
PLUGINS_LINE='plugins=(git sudo z zsh-syntax-highlighting zsh-autosuggestions fzf)'
if grep -q '^plugins=' ~/.zshrc; then
    grep -qF "$PLUGINS_LINE" ~/.zshrc || sed -i "/^plugins=/c\\$PLUGINS_LINE" ~/.zshrc
else
    echo "$PLUGINS_LINE" >> ~/.zshrc
fi

grep -q "autoload -U compinit" ~/.zshrc || echo "autoload -U compinit && compinit" >> ~/.zshrc

touch ~/.bash_profile
if ! grep -q "exec.*zsh" ~/.bash_profile; then
    echo 'exec $(which zsh) -l' >> ~/.bash_profile
fi

# ---------------------------------------------------------
# 3. 安装增强工具 (zoxide, fzf)
# ---------------------------------------------------------
echo "[3/8] 检查并安装 zoxide 和 fzf..."

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
# 4. 配置 Ascend CANN / ATB 环境变量
# ---------------------------------------------------------
echo "[4/8] 配置 Ascend CANN / ATB 环境变量..."

# 4.1 探测 CANN set_env.sh (优先默认版本，否则取第一个 cann-*)
CANN_SET_ENV=""
if [ -f "$ASCEND_ROOT/cann-${CANN_FALLBACK_VERSION}/set_env.sh" ]; then
    CANN_SET_ENV="$ASCEND_ROOT/cann-${CANN_FALLBACK_VERSION}/set_env.sh"
else
    for _cand in "$ASCEND_ROOT"/cann-*/set_env.sh; do
        if [ -f "$_cand" ]; then
            CANN_SET_ENV="$_cand"
            break
        fi
    done
fi

if [ -n "$CANN_SET_ENV" ]; then
    CANN_INIT_LINE="source $CANN_SET_ENV"
    grep -qF "$CANN_INIT_LINE" ~/.zshrc || echo "$CANN_INIT_LINE" >> ~/.zshrc
    echo "  -> CANN: $CANN_SET_ENV"
else
    echo "  -> 警告: 未找到 $ASCEND_ROOT/cann-*/set_env.sh，跳过 CANN 配置。"
fi

# 4.2 ATB 环境变量
ATB_SET_ENV="$ASCEND_ROOT/nnal/atb/set_env.sh"
if [ -f "$ATB_SET_ENV" ]; then
    ATB_INIT_LINE="source $ATB_SET_ENV"
    grep -qF "$ATB_INIT_LINE" ~/.zshrc || echo "$ATB_INIT_LINE" >> ~/.zshrc
    echo "  -> ATB: $ATB_SET_ENV"
else
    echo "  -> 警告: 未找到 $ATB_SET_ENV，跳过 ATB 配置。"
fi

# 4.3 jemalloc 预加载
# 旧写法 'export LD_PRELOAD=...:$LD_PRELOAD' 在 LD_PRELOAD 为空时会留下尾部冒号，
# 等于把当前目录加入动态库搜索路径；这里改为幂等且无尾部冒号的写法。
JEMALLOC_LINE="case \":\${LD_PRELOAD:-}:\" in *\":$JEMALLOC_SO:\"*) ;; *) export LD_PRELOAD=\"$JEMALLOC_SO\${LD_PRELOAD:+:\$LD_PRELOAD}\";; esac"
# 清理历史遗留的旧写法
sed -i '\|^export LD_PRELOAD=.*libjemalloc|d' ~/.zshrc
if [ -f "$JEMALLOC_SO" ]; then
    grep -qF "$JEMALLOC_LINE" ~/.zshrc || echo "$JEMALLOC_LINE" >> ~/.zshrc
    echo "  -> jemalloc: $JEMALLOC_SO"
else
    echo "  -> 警告: 未找到 $JEMALLOC_SO，跳过 jemalloc 预加载。"
fi

# ---------------------------------------------------------
# 5. 安装 Miniforge (Conda) - 修复版
# ---------------------------------------------------------
echo "[5/8] 检查并安装 Miniforge..."

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
    # 注意: mirror.nju.edu.cn 已是国内镜像，不能加 GitHub 加速前缀（加了会 403）
    if [ "$ARCH" = "aarch64" ]; then
        MINIFORGE_URL="https://mirror.nju.edu.cn/github-release/conda-forge/miniforge/LatestRelease/Miniforge3-Linux-aarch64.sh"
    elif [ "$ARCH" = "x86_64" ]; then
        MINIFORGE_URL="https://mirror.nju.edu.cn/github-release/conda-forge/miniforge/LatestRelease/Miniforge3-Linux-x86_64.sh"
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
# 6. 配置 Python 源与安装 nputop
# ---------------------------------------------------------
echo "[6/8] 配置 Python 环境并安装 ascend-nputop..."

# 【关键】加载 Conda 环境
if [ -f "$CONDA_PATH/etc/profile.d/conda.sh" ]; then
    source "$CONDA_PATH/etc/profile.d/conda.sh"
    # 确保激活 base 环境，这样 pip 才会指向 miniforge
    conda activate base
else
    echo "警告: 找不到 Conda 初始化脚本，尝试直接使用系统 pip..."
fi

# uv / uv tool 的可执行文件位于 ~/.local/bin，必须让当前 shell 立刻可见，
# 否则下面的 command -v 检测不到，重复执行时会反复安装。
export PATH="$HOME/.local/bin:$PATH"

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
# 7. 源码编译安装 htop
# ---------------------------------------------------------
echo "[7/8] 检查并编译 htop ${HTOP_VERSION}..."

mkdir -p ~/code && cd ~/code

HTOP_DIR="htop-${HTOP_VERSION}"
# 包名带版本号，避免残留旧版本的 htop-latest.tar.gz 导致解压目录与 HTOP_DIR 不匹配
HTOP_TAR="htop-${HTOP_VERSION}.tar.gz"

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

    if [ -d "$HTOP_DIR" ]; then
        cd "$HTOP_DIR"
        ./autogen.sh
        ./configure
        make -j"$(nproc)"
        sudo make install
        cd ~/code
    else
        echo "错误: 解压后未找到目录 $HTOP_DIR，跳过 htop 编译。"
    fi
fi

# ---------------------------------------------------------
# 8. 完成提示
# ---------------------------------------------------------
echo ""
echo "========================================="
echo "✅ 所有步骤执行完毕！"
echo "========================================="
echo "⚠️ 重要提示:"
echo "1. 请关闭当前终端窗口，重新打开以加载 Zsh 和 Conda 配置。"
echo "2. 或者在当前窗口执行: source ~/.zshrc && exec zsh -l"
echo "========================================="
