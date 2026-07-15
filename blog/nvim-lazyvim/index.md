---
title: "Neovim + LazyVim 配置备忘"
date: 2026-07-08T20:00:00+08:00
lastmod: 2026-07-11T12:25:00+08:00
draft: false
description: "Windows PowerShell 7 和 Linux 下的 Neovim + LazyVim 配置记录"
slug: "nvim-lazyvim"
tags: ["tools"]
categories: ["tools"]

comments: true
math: true
---

# Neovim + LazyVim 配置备忘

这是 `Neovim + LazyVim` 的跨平台配置记录，主要覆盖两个环境：

- Windows：`PowerShell 7` + `Windows Terminal`
- Linux：Ubuntu / Debian 系发行版，`bash` 或 `zsh`

LazyVim 本质上是基于 `lazy.nvim` 的 Neovim 配置模板，适合直接拿来作为日常编辑器。本文只记录能稳定复用的安装和配置路径，不展开插件机制。

- [Neovim + LazyVim 配置备忘](#neovim--lazyvim-配置备忘)
  - [1. 准备环境](#1-准备环境)
    - [1.1 工具说明](#11-工具说明)
    - [1.2 Windows + PowerShell 7](#12-windows--powershell-7)
    - [1.3 Linux](#13-linux)
  - [2. 安装 LazyVim](#2-安装-lazyvim)
    - [2.1 Windows 路径](#21-windows-路径)
    - [2.2 Linux 路径](#22-linux-路径)
  - [3. 配置文件结构](#3-配置文件结构)
  - [4. 使用方式](#4-使用方式)
    - [4.1 常用模式](#41-常用模式)
    - [4.2 打开项目后的界面](#42-打开项目后的界面)
    - [4.3 左侧目录栏](#43-左侧目录栏)
    - [4.4 右侧编辑区](#44-右侧编辑区)
      - [4.4.1 代码折叠](#441-代码折叠)
      - [4.4.2 编辑区常用模式](#442-编辑区常用模式)
    - [4.5 分屏和窗口移动](#45-分屏和窗口移动)
    - [4.6 呼出终端](#46-呼出终端)
      - [4.6.1 使用 LazyGit](#461-使用-lazygit)
    - [4.7 搜索文件和搜索文本](#47-搜索文件和搜索文本)
      - [4.7.1 在当前打开文件中检索](#471-在当前打开文件中检索)
      - [4.7.2 批量替换](#472-批量替换)
    - [4.8 Buffer、Window、Tab](#48-bufferwindowtab)
      - [4.8.1 切换文件和返回光标位置](#481-切换文件和返回光标位置)
    - [4.9 `which-key` 提示菜单](#49-which-key-提示菜单)
    - [4.10 常用命令速查](#410-常用命令速查)
  - [5. 基础配置](#5-基础配置)
    - [5.1 `options.lua`](#51-optionslua)
    - [5.2 `keymaps.lua`](#52-keymapslua)
    - [5.3 `plugins/snacks.lua`](#53-pluginssnackslua)
    - [5.4 `plugins/core.lua`](#54-pluginscorelua)
    - [5.5 插件和 Extras](#55-插件和-extras)
      - [5.5.1 查看状态和错误](#551-查看状态和错误)
      - [5.5.2 启用和安装 Extra](#552-启用和安装-extra)
      - [5.5.3 安装自己的插件](#553-安装自己的插件)
      - [5.5.4 移除 Extra 或插件](#554-移除-extra-或插件)
    - [5.6 C/C++ 配置 `clangd`](#56-cc-配置-clangd)
      - [5.6.1 CMake 项目](#561-cmake-项目)
      - [5.6.2 Makefile 项目](#562-makefile-项目)
      - [5.6.3 很小的单文件项目](#563-很小的单文件项目)
      - [5.6.4 常见检查点](#564-常见检查点)
      - [5.6.5 给不同项目配置编译数据库](#565-给不同项目配置编译数据库)
    - [5.7 Android NDK 交叉编译项目](#57-android-ndk-交叉编译项目)
      - [5.7.1 先确认要生成什么](#571-先确认要生成什么)
      - [5.7.2 准备 NDK 路径](#572-准备-ndk-路径)
      - [5.7.3 CMake 生成 Android 的 `compile_commands.json`](#573-cmake-生成-android-的-compile_commandsjson)
      - [5.7.4 LazyVim 给 `clangd` 加 `query-driver`](#574-lazyvim-给-clangd-加-query-driver)
      - [5.7.6 验证和常见问题](#576-验证和常见问题)
  - [6. Shell 集成](#6-shell-集成)
    - [6.1 PowerShell 7 Profile](#61-powershell-7-profile)
    - [6.2 Linux Shell](#62-linux-shell)
  - [8. 参考链接](#8-参考链接)

## 1. 准备环境

LazyVim 依赖 `git`、`ripgrep`、`fd`、`lazygit`、`node`、`tree-sitter-cli` 等工具。C/C++ 项目还需要 `clangd` 和能生成编译数据库的构建工具。安装时优先使用包管理器，能一条命令解决就不手动下载安装包。

### 1.1 工具说明

| 工具 | 作用 | LazyVim 中的用途 |
|------|------|------------------|
| `git` | 版本管理工具 | 克隆 LazyVim starter、下载插件、查看 Git 状态 |
| `ripgrep` / `rg` | 高性能文本搜索工具 | 支持 `<Space>/`、`<Space>sg` 等全文搜索 |
| `fd` | 更快更现代的 `find` 替代品 | 支持 Telescope 文件查找和目录扫描 |
| `lazygit` | 终端 Git TUI 工具 | 可选依赖，用于在 Neovim 内打开 Git 面板，处理提交、diff、分支等 |
| `node` / `npm` | JavaScript 运行时和包管理器 | 安装部分 LSP、formatter、`tree-sitter-cli`；Linux 下建议用用户态 Node，不用 `sudo npm` |
| `tree-sitter-cli` | 语法解析器命令行工具 | 配合 Tree-sitter 提供更准确的语法高亮和代码结构解析 |
| `gcc` / `make` | C/C++ 编译工具链 | 编译部分 Neovim 插件或 Tree-sitter parser |
| `clangd` | C/C++ 语言服务器 | 提供 C/C++ 补全、跳转定义、查找引用、诊断 |
| `cmake` / `ninja` / `bear` | 构建辅助工具 | 生成 `compile_commands.json`，让 `clangd` 知道项目怎么编译 |

其中 `ripgrep`、`fd` 会直接影响文件搜索和全文搜索体验；`node`、`tree-sitter-cli`、编译工具链主要影响语言支持和插件安装。`clangd` 是 C/C++ 跳转和补全的核心。

### 1.2 Windows + PowerShell 7

Windows 下最省事的方式是用 `scoop`。这里默认在 `PowerShell 7` 中操作(迁移`pwsh7`可以[参考](../pwsh7-migration/index.md))，如果没有安装 `scoop`，先执行安装命令：

```powershell
# 先检查当前是否已经安装 scoop
scoop -v

# 如果上面命令提示 scoop 不存在，需要安装 scoop
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
    iwr -useb get.scoop.sh | iex
}

# 安装 Neovim 和 LazyVim 常用依赖
# llvm 提供 clangd；cmake/ninja 用来生成 C/C++ 项目的 compile_commands.json
scoop install neovim git ripgrep fd lazygit nodejs-lts gcc llvm cmake ninja
npm install -g tree-sitter-cli

# 验证
nvim --version
git --version
rg --version
fd --version
lazygit --version
node --version
tree-sitter --version
clangd --version
cmake --version
```

如果只想使用 Windows 自带的 `winget`，也可以逐个安装；但命令更长，后续更新也没有 `scoop update *` 便利。

### 1.3 Linux

Ubuntu / Debian 不建议直接依赖包管理器安装(`apt install neovim nodejs npm`)，因为部分源没有最新版`nvim`（例如，Ubuntu 22.04 源里的 `neovim` 可能只有 `v0.6.1`）`。

这里把安装拆成三部分：`apt` 安装系统依赖，Neovim 使用官方 release，Node 使用用户态 `nvm`。

```bash
# 如果源下载慢或 apt update 经常失败，可以先换成清华源；网络正常可以跳过这一段
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
sudo sed -i 's|http://.*archive.ubuntu.com/ubuntu|https://mirrors.tuna.tsinghua.edu.cn/ubuntu|g' /etc/apt/sources.list
sudo sed -i 's|http://.*security.ubuntu.com/ubuntu|https://mirrors.tuna.tsinghua.edu.cn/ubuntu|g' /etc/apt/sources.list

# 系统依赖
sudo apt update
sudo apt install -y git curl ripgrep fd-find gcc g++ make unzip clangd cmake ninja-build

# Ubuntu/Debian 中 fd 的二进制名通常是 fdfind，补一个 fd 软链接
if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
  sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd
fi

# 安装 Neovim 最新版
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
echo 'export PATH="/opt/nvim-linux-x86_64/bin:$PATH"' >> ~/.zshrc
export PATH="/opt/nvim-linux-x86_64/bin:$PATH"

# 如果还没有 nvm，先安装 nvm；这里先取最新 release tag，避免硬编码版本号过期，nvm用于安装 Node.js
NVM_VERSION="$(
  curl -fsSL https://api.github.com/repos/nvm-sh/nvm/releases/latest |
  sed -nE 's/.*"tag_name": "([^"]+)".*/\1/p'
)"
curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash

# 加载 nvm，让当前终端可以直接使用 nvm 命令
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

# 安装 Node LTS，LTS 是长期支持版，不是 Node 最新版
# 如果需要 Node 最新版，把下面两行改成：nvm install node && nvm use node
# 这里使用 nvm 安装 Node LTS
nvm install --lts
nvm use --lts

# 安装 tree-sitter-cli，不要加 sudo
npm install -g tree-sitter-cli

# 验证
nvim --version
git --version
rg --version
fd --version
node --version
tree-sitter --version
clangd --version
cmake --version
```

`lazygit` 在 Ubuntu 22.04 默认源中可能不存在，需要手动安装：

```bash
# x86_64 机器安装 lazygit；arm64 设备需要把 x86_64 改成 arm64
LAZYGIT_VERSION="$(
  curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest |
  sed -nE 's/.*"tag_name": "v([^"]+)".*/\1/p'
)"

curl -Lo lazygit.tar.gz \
  "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"

tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
rm -f lazygit lazygit.tar.gz

lazygit --version
```

## 2. 安装 LazyVim

LazyVim 官方提供了 starter 仓库，直接克隆到 Neovim 配置目录即可。安装前先备份已有配置。

### 2.1 Windows 路径

Windows 下配置目录是 `$env:LOCALAPPDATA\nvim`，插件数据目录是 `$env:LOCALAPPDATA\nvim-data`。

```powershell
# 备份旧配置
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$paths = @(
    "$env:LOCALAPPDATA\nvim",
    "$env:LOCALAPPDATA\nvim-data"
)

foreach ($path in $paths) {
    if (Test-Path $path) {
        Move-Item $path "$path.bak-$timestamp"
    }
}

# 克隆 LazyVim starter
git clone https://github.com/LazyVim/starter $env:LOCALAPPDATA\nvim

# 删除 starter 自带 git 记录，后续可以放进自己的 dotfiles 仓库
Remove-Item $env:LOCALAPPDATA\nvim\.git -Recurse -Force

# 首次启动会自动安装插件
nvim
```

### 2.2 Linux 路径

Linux 下配置目录是 `~/.config/nvim`，插件和状态目录分别在 `~/.local/share/nvim`、`~/.local/state/nvim`、`~/.cache/nvim`。

```bash
# 备份旧配置 若需要
timestamp="$(date +%Y%m%d-%H%M%S)"
for path in ~/.config/nvim ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim; do
  if [ -e "$path" ]; then
    mv "$path" "$path.bak-$timestamp"
  fi
done

# 克隆 LazyVim starter
git clone https://github.com/LazyVim/starter ~/.config/nvim

# 删除 starter 自带 git 记录
rm -rf ~/.config/nvim/.git

# 首次启动会自动安装插件
nvim
```

首次进入后等待插件安装完成，然后执行：

```vim
:LazyHealth
:checkhealth
```

执行方式是在 Neovim 内部输入命令，不是在 shell 里直接输入：

```text
1. 在终端执行 nvim
2. 进入 Neovim 后按 Esc，确保回到 Normal 模式
3. 输入 :LazyHealth，然后按 Enter
4. 检查完成后输入 :checkhealth，然后按 Enter
5. 退出检查页面可以按 q，退出 Neovim 可以输入 :q
```

`LazyHealth` 用来检查 LazyVim 插件环境，`:checkhealth` 用来检查 Neovim 自身和 provider 状态。

## 3. 配置文件结构

LazyVim 的配置文件主要放在 `lua/config` 和 `lua/plugins` 下：

```text
nvim
├── init.lua
└── lua
    ├── config
    │   ├── autocmds.lua
    │   ├── keymaps.lua
    │   ├── lazy.lua
    │   └── options.lua
    └── plugins
        └── *.lua
```

常用路径对照：

| 类型 | Windows | Linux |
|------|---------|-------|
| 配置目录 | `$env:LOCALAPPDATA\nvim` | `~/.config/nvim` |
| 插件数据 | `$env:LOCALAPPDATA\nvim-data` | `~/.local/share/nvim` |
| 缓存目录 | `$env:LOCALAPPDATA\nvim-data` 里由插件管理 | `~/.cache/nvim` |
| shell profile | `$PROFILE` | `~/.zshrc` |

`lua/config/*.lua` 会在合适时机自动加载，`lua/plugins/*.lua` 会被 `lazy.nvim` 自动读取。

## 4. 使用方式

这一节按实际使用顺序整理：先理解模式，再打开项目、操作目录栏和编辑区，最后用终端、搜索和快捷键提示。

### 4.1 常用模式

Neovim 不是一直处在“输入文字”的状态。日常先掌握下面几种模式：

| 模式 | 作用 | 进入方式 | 退出方式 |
|------|------|----------|----------|
| Normal 模式 | 移动光标、执行快捷键、输入 `:w` 这类命令 | 打开文件后默认就是 Normal 模式 | 按 `i` 进入 Insert 模式 |
| Insert 模式 | 输入正文内容 | 在 Normal 模式按 `i` | 按 `Esc` 回到 Normal 模式 |
| Visual 模式 | 选中文本后复制、删除、缩进、注释 | 在 Normal 模式按 `v`，按 `V` 进入行选择 | 按 `Esc` 回到 Normal 模式 |
| Command-line 模式 | 执行 `:w`、`:q`、`:Lazy` 这类命令 | 在 Normal 模式按 `:` | 执行命令后自动返回，或按 `Esc` 取消 |
| Terminal 模式 | 在 Neovim 内部终端输入 shell 命令 | 打开终端后默认进入 | 按 `<Ctrl-\><Ctrl-n>` 回到 Normal 模式 |

`Normal 模式` 可以理解成“操作模式”。执行保存、退出、分屏、跳转、打开文件树之前，先按 `Esc` 回到 Normal 模式，**在左下角可见当前模式。**

还有 Replace、Select、Operator-pending 等模式，但日常写代码和改文档先记住上面这些就够。

执行 `Command-line` 模式的步骤：

```text
1. 按 Esc，确保回到 Normal 模式
2. 输入英文冒号 :
3. 输入 w
4. 按 Enter
```

`:q`、`:wq`、`:Lazy`、`:checkhealth` 都是同样的执行方式。

### 4.2 打开项目后的界面

从项目根目录启动：

```bash
cd <project>
nvim .
```

可以把界面理解成四块：

| 区域 | 作用 | 常用入口 |
|------|------|----------|
| 左侧目录栏 | 浏览项目目录、打开/新建/删除文件 | `<Space>e` |
| 右侧编辑区 | 写代码、改 Markdown、跳转定义 | `i` 进入编辑，`Esc` 回到操作 |
| 底部终端 | 运行 `git`、`npm`、`hugo`、测试命令 | `<Space>ft` |
| 浮动搜索框 | 找文件、全文搜索、查命令 | `<Space><Space>`、`<Space>/`、`<Space>sk` |

其中 `<Space>` 是 leader 键。`<Space>e` 的意思是先按空格，再按 `e`。

### 4.3 左侧目录栏

目录栏适合看项目结构，也可以做少量文件操作。

| 操作 | 键位 |
|------|------|
| 打开 / 关闭目录栏 | `<Space>e` |
| 在目录栏和编辑区移动 | `<Ctrl-h>` / `<Ctrl-l>` |
| 上下移动 | `j` / `k` |
| 展开目录或打开文件 | `Enter` |
| 收起光标所在目录 | `h` |
| 收起全部已展开目录 | `Z` |
| 返回上级目录 | `Backspace` |
| 新建文件或目录 | `a` |
| 删除文件 | `d` |
| 重命名文件 | `r` |
| 刷新目录 | `R` |
| 显示 / 隐藏隐藏文件 | `H` |
| 显示 / 隐藏 `.gitignore` 忽略的文件 | `I` |

`a`、`d`、`r`、`R` 只在目录栏获得焦点时生效。新建目录时路径末尾加 `/`，例如 `src/utils/`；新建文件直接输入路径，例如 `src/main.py`。

要收起当前文件所在的父目录，先按 `<Space>e` 让目录栏获得焦点，用 `j` / `k` 把光标移到父目录那一行，再按 `h`。`h` 只收起当前目录，`Z` 会收起整棵目录树。

目录栏默认可能看不到 `node_modules`、`build`、`dist`、`.venv` 这类目录，因为它们通常写在 `.gitignore` 里。需要临时查看时，先按 `<Space>e` 打开目录栏，再按 `I` 显示 ignored files；如果是 `.env`、`.github` 这类点开头文件，按 `H` 显示 hidden files。

目录栏里的筛选只匹配文件或目录名，不会读取每个文件的正文内容。`I` 也只是目录栏获得焦点后的显示开关，不是打开文件的前置步骤。日常直接搜索后打开文件更快：

| 目标 | 做法 | 会搜索什么 |
|------|------|------------|
| 按文件名打开项目文件 | `<Space><Space>`，输入文件名后按 `Enter` | 文件路径和文件名 |
| 找包含某段文字的文件并打开对应行 | `<Space>/`，输入文字后按 `Enter` | 项目文件正文 |
| 在搜索结果中包含 `.gitignore` 文件 | 打开 picker 后按 `<Alt-i>` | 被忽略文件也会进入搜索范围 |

例如不知道 `foo` 在哪个文件中，用 `<Space>/` 搜 `foo`，选中结果后按 `Enter` 会直接打开那个文件并定位到匹配行；不需要先打开 `<Space>e`。`node_modules`、`build` 等目录会显著拖慢搜索，默认保持排除更合适。

### 4.4 右侧编辑区

右侧编辑区是主要写内容的位置。这里按 `Normal 模式`、`Insert 模式`、`Visual 模式` 分开记。

Normal 模式负责移动、查找、跳转、保存、执行快捷键：

| 操作 | 键位 |
|------|------|
| 进入 Insert 模式 | `i` |
| 保存 | `:w` |
| 退出当前窗口 | `:q` |
| 保存并退出 | `:wq` |
| 撤销 | `u` |
| 重做 | `<Ctrl-r>` |
| 复制当前行 | `yy` |
| 剪切 / 删除当前行 | `dd` |
| 粘贴到光标后 | `p` |
| 粘贴到光标前 | `P` |
| 跳到文件开头 | `gg` |
| 跳到文件末尾 | `G` |
| 跳到当前行第 1 列 / 首个非空白字符 | `0` / `^` |
| 跳到当前行最后一列 / 最后一个非空白字符 | `$` / `g_` |
| 向下 / 向上翻一整页 | `<Ctrl-f>` / `<Ctrl-b>` |
| 向下 / 向上翻半页 | `<Ctrl-d>` / `<Ctrl-u>` |
| 跳到第 N 行 | `Ngg` 或 `:N`，例如 `20gg` / `:20` |
| 当前页快速跳转 | `s`，输入屏幕上出现的跳转标签后跳转 |
| 向下搜索 | `/关键词` 后按 `Enter` |
| 向上搜索 | `?关键词` 后按 `Enter` |
| 下一个 / 上一个搜索结果 | `n` / `N` |
| 注释当前行 | `gcc` |
| 格式化当前文件 | `<Space>cf` |
| 跳转到定义 | `gd` |
| 查找引用 | `gr` |
| 查看悬浮说明 | `K` |
| 重命名符号 | `<Space>cr` |
| 代码操作 | `<Space>ca` |

`s` 是 LazyVim 默认启用的 `flash.nvim` 跳转。它适合“知道目标附近的字符，但不想一格一格移动”的场景：按 `s` 后输入目标字符或短词，匹配位置会出现跳转标签；输入标签字符，光标会立刻移动过去。标签不够区分时继续输入；按 `Esc` 取消。`s` 作用于当前获得焦点的编辑窗口。

这里的“跨屏”不是多个分屏，而是同一个文件比当前编辑器可视区域更长：例如光标在第 20 行，目标文字在第 500 行，必须滚动很多次才能看到。已知文本时，`/关键词` 后按 `Enter` 更适合这种情况；`n` / `N` 继续切换结果。多个并排区域才叫分屏（window），先用 `<Ctrl-h/j/k/l>` 把焦点移到目标窗口，再搜索或跳转。

例如要跳到当前屏幕里的某个 `return`：

```text
Esc -> s -> 输入 return 附近显示的标签
```

#### 4.4.1 代码折叠

代码折叠只影响显示，不会删除内容。先把光标放在函数、类或缩进块内，再使用：

| 操作 | 键位 |
|------|------|
| 折叠当前代码块 | `zc` |
| 展开当前代码块 | `zo` |
| 切换当前代码块的折叠状态 | `za` |
| 折叠当前文件全部代码块 | `zM` |
| 展开当前文件全部代码块 | `zR` |
| 跳到下一个 / 上一个折叠处 | `zj` / `zk` |

`zM` 后只保留顶层结构，适合快速浏览大文件；需要恢复时按 `zR`。Markdown 标题、Python 缩进块、C/C++ 函数是否可折叠取决于当前文件类型和 Tree-sitter 是否正常工作。

#### 4.4.2 编辑区常用模式 
Insert 模式负责输入正文内容：

| 操作 | 键位 |
|------|------|
| 退出 Insert 模式 | `Esc` |
| 换行 | `Enter` |
| 删除前一个字符 | `Backspace` |
| 普通输入 | 直接输入文本 |

Visual 模式负责“先选中，再操作”，最常用在复制、剪切、缩进、注释一段文本：

| 操作 | 键位 |
|------|------|
| 进入字符选择 | `v` |
| 进入整行选择 | `V` |
| 进入块选择 / 列选择 | `<Ctrl-v>` |
| 退出 Visual 模式 | `Esc` |
| 复制选中内容 | `y` |
| 剪切 / 删除选中内容 | `d` |
| 选中后粘贴替换 | `p` |
| 向右缩进选中内容 | `>` |
| 向左缩进选中内容 | `<` |
| 注释选中内容 | `gc` |

复制一段文本的常用流程：

```text
1. 按 Esc 回到 Normal 模式
2. 按 v 进入字符选择，或按 V 进入整行选择
3. 用 h/j/k/l、gg、G、/关键词 移动光标扩大选择范围
4. 按 y 复制，复制后会自动回到 Normal 模式
5. 移动到目标位置，按 p 粘贴到光标后，或按 P 粘贴到光标前
```

复制多行最常用的是 `V`：

```text
V 进入整行选择
j/k 选择多行
y 复制
p 粘贴
```

复制当前行不需要进 Visual 模式，直接在 Normal 模式按：

```text
yy 复制当前行
dd 剪切当前行
p  粘贴到当前行下面
P  粘贴到当前行上面
```

如果已经配置了 `vim.opt.clipboard = "unnamedplus"`，普通的 `y`、`yy`、`p` 会尽量和系统剪贴板打通。Linux 服务器或 SSH 环境下系统剪贴板可能不可用，这时可以先按 `:checkhealth clipboard` 看缺什么。

手动指定系统剪贴板也可以用：

```text
"+y  复制到系统剪贴板
"+p  从系统剪贴板粘贴
```

最常见的编辑流程：

```text
i 输入内容
Esc 回到 Normal 模式
:w 保存
```

搜索一个词的流程：

```text
Esc 回到 Normal 模式
/model 然后按 Enter
n 跳到下一个结果
N 跳到上一个结果
```

LSP 跳转需要当前文件已经有语言服务器接管。下面这些键位默认在 `Normal 模式` 执行；如果正在输入代码，先按 `Esc` 回到 Normal 模式，再按 `gd`、`gr` 这类快捷键。

| 操作 | 键位 | 说明 |
|------|------|------|
| 跳转到定义 | `gd` | 从函数调用跳到函数定义 |
| 跳转到声明 | `gD` | 跳到 declaration，C/C++ 等语言更常用 |
| 查找引用 | `gr` | 查当前函数、变量在哪里被用到 |
| 跳转到实现 | `gI` | 从接口跳到具体实现 |
| 跳转到类型定义 | `gy` | 看变量或函数对应的类型 |
| 查看文档 / 类型提示 | `K` | 在当前位置弹出说明 |
| 函数参数提示 | `gK` | 看函数签名和参数 |
| 重命名变量 / 函数 | `<Space>cr` | 项目内批量改名 |
| 代码操作 | `<Space>ca` | quick fix、导入、修复等 |
| LSP 状态 | `<Space>cl` | 查看当前 buffer 连接了哪些 LSP |

常用流程：

```text
1. 把光标移动到函数名、变量名或类型名上
2. 按 gd 跳到定义
3. 看完后按 <Ctrl-o> 回到跳转前的位置
4. 再按 <Ctrl-i> 可以前进到刚才跳走的位置
```

如果 `gd` 没反应，先检查三件事：

```vim
:Mason
:LazyHealth
:checkhealth vim.lsp
```

常见原因是当前语言的 LSP 没安装、项目根目录识别错了，或者打开的是普通文本文件。比如 Python 需要 `pyright` / `basedpyright`，Lua 需要 `lua-language-server`，前端项目常见的是 `typescript-language-server` 或 `vtsls`。

C/C++ 项目用的是 `clangd`。如果 `gd` 对普通函数有反应，但对项目里的头文件、宏、跨文件函数没反应，通常不是快捷键问题，而是 `clangd` 没拿到正确的编译参数。重点检查项目根目录附近有没有 `compile_commands.json`。

### 4.5 分屏和窗口移动

分屏用于同时看多个文件，例如左边看定义，右边改实现。

| 操作 | 键位 |
|------|------|
| 向下分屏 | `<Space>-` |
| 向右分屏 | `<Space>\|` |
| 移动到左侧窗口 | `<Ctrl-h>` |
| 移动到下方窗口 | `<Ctrl-j>` |
| 移动到上方窗口 | `<Ctrl-k>` |
| 移动到右侧窗口 | `<Ctrl-l>` |
| 关闭当前窗口 | `:q` |
| 当前窗口最大化 / 恢复 | `<Space>wm` |

打开两个文件的常用流程：

```text
1. nvim .
2. <Space>e 打开目录栏
3. 选中文件后按 Enter
4. <Space>| 右侧分屏
5. <Ctrl-h> 回到目录栏
6. 选中第二个文件后按 Enter
7. <Ctrl-h/j/k/l> 在窗口之间移动
```

### 4.6 呼出终端

LazyVim 可以在 Neovim 内打开终端，适合运行 `git status`、`npm run dev`、`hugo server`、`pytest` 等命令。

| 操作 | 键位 |
|------|------|
| 打开项目根目录终端 | `<Space>ft` |
| 打开当前目录终端 | `<Space>fT` |
| 切换终端显示 | `<Ctrl-/>` |
| 终端窗口全屏 / 恢复原布局 | 终端获得焦点后按 `<Space>wm` |
| 从终端输入状态回到 Normal 模式 | 连按 `Esc` 两次（LazyVim） |
| 从终端输入状态回到 Normal 模式 | `<Ctrl-\><Ctrl-n>` |
| 关闭终端窗口 | 回到 Normal 模式后输入 `:q` |
| 向下分屏后开终端 | `<Space>-` 后输入 `:terminal` |
| 向右分屏后开终端 | `<Space>\|` 后输入 `:terminal` |

关闭终端分三步理解：

```text
- <Space> f t：根目录 terminal
- <Space> f T：当前目录 terminal
- 2<Space> f t、3<Space> f t：创建/切换第 2、3 个根目录 terminal
- 对同一个编号重复按会折叠/展开，例如 2<Space> f t
```

打开多个终端的做法：

```text
方式一：重复使用 <Space>ft / <Space>fT 打开终端，再用 <Ctrl-h/j/k/l> 切窗口
方式二：先 <Space>- 或 <Space>| 分屏，再输入 :terminal 创建新的终端窗口
```

终端需要全屏查看日志、运行测试或使用 `lazygit` 时，先让终端获得焦点，在 Terminal 模式连按两次 `Esc` 回到 Normal 模式，再按 `<Space>wm`。当前终端窗口会最大化；再按一次 `<Space>wm` 恢复之前的分屏布局。

“折叠终端”通常指临时隐藏终端窗口，不结束里面的 shell。用 `<Ctrl-/>` 可以切换终端显示，折叠后再次按 `<Ctrl-/>` 会展开同一个终端，原来运行的命令和输出仍会保留。若只是离开终端输入状态，LazyVim 里连按两次 `Esc` 就能回到 Normal 模式。单按一次 `Esc` 会交给终端中的 shell 或程序；原生且通用的写法仍是 `<Ctrl-\><Ctrl-n>`。回到 Normal 模式后再切到其它窗口。

#### 4.6.1 使用 LazyGit

`lazygit` 是 Git 的终端图形界面（TUI）。它把 `git status`、`git diff`、`git add`、`git commit`、分支切换、pull 和 push 放到同一个交互界面；底层仍然执行 Git 命令，不会自动提交或自动推送代码。

在项目根目录的终端启动：

```bash
lazygit
```

在 Neovim 里可以先按 `<Space>ft` 打开项目根目录终端，再输入 `lazygit`。启动后通常会看到文件状态、暂存区、提交历史和 diff 面板。最常用的流程是：

```text
1. 用 j / k 选中有改动的文件，查看 diff
2. 按 Space 暂存或取消暂存选中的文件 / 区块
3. 确认暂存区内容正确后，按 c 输入提交信息并提交
4. 需要同步远端时，从界面中执行 pull 或 push
5. 按 q 退出 LazyGit，回到 Neovim 内的终端
```

任何面板中按 `?` 都能查看当前版本的完整快捷键。提交前重点看暂存区：只有已暂存的内容会进入本次 commit。分支删除、强制推送、reset 等操作仍会影响真实仓库，LazyGit 只是把 Git 命令换成了可视化入口，执行前仍应确认目标分支和改动范围。

### 4.7 搜索文件和搜索文本

不要总是从目录树一层层找文件，搜索更快。

| 目标 | 键位 |
|------|------|
| 查找项目文件 | `<Space><Space>` |
| 查找文件 | `<Space>ff` |
| 最近打开文件 | `<Space>fr` |
| 全文搜索 | `<Space>/` |
| 搜索光标下单词 | `<Space>sw` |
| 搜索快捷键 | `<Space>sk` |

常用流程：

```text
找文件：<Space><Space> -> 输入文件名关键字 -> Enter
搜文本：<Space>/ -> 输入关键字 -> Enter
查快捷键：<Space>sk -> 输入 terminal / file / git 等关键词
```

#### 4.7.1 在当前打开文件中检索

只在当前 buffer 中找文字，最直接的是 Vim 原生搜索：

```text
/关键词 -> Enter -> n / N
```

`/` 会从当前光标向下查找，`?关键词` 向上查找；`n` 到下一个结果，`N` 回到上一个结果。需要模糊地查当前文件的某一行时，按 `<Space>sb` 打开 `Buffer Lines`，输入任意片段后选择结果即可跳到该行。

#### 4.7.2 批量替换

替换当前文件的全部匹配项，在 Normal 模式执行：

```vim
:%s/旧文本/新文本/gc
```

`%` 表示当前文件全部行，`g` 表示每行替换全部匹配，`c` 会逐项确认。确认时按 `y` 替换、`n` 跳过、`a` 替换剩余全部、`q` 退出。确认无误后去掉 `c`：

```vim
:%s/旧文本/新文本/g
```

只替换一段选中文本时，先按 `v` 或 `V` 选中范围，再输入：

```vim
:s/旧文本/新文本/gc
```

Neovim 会自动把命令补成当前选区的范围。项目内跨文件替换使用 `<Space>sr` 打开 `Search and Replace`：输入搜索文本和替换文本，先检查匹配文件与 diff，再执行替换。它适合改变量名、配置键等可审核的批量变更；涉及正则时先在单个文件用 `:%s/.../.../gc` 验证匹配范围。

### 4.8 Buffer、Window、Tab

这三个概念容易混：

| 概念 | 说明 | 常用场景 |
|------|------|----------|
| Buffer | 已打开的文件 | 在多个文件之间切换 |
| Window | 屏幕上的一个编辑窗口 | 分屏同时看多个文件 |
| Tab | 一组窗口布局 | 保存一套工作区布局 |

日常编辑优先用 buffer 和 window，不要把 tab 当成 VSCode 那种文件标签页。

| 操作 | 键位 |
|------|------|
| 上一个 / 下一个 buffer | `<Shift-h>` / `<Shift-l>` |
| buffer 列表 | `<Space>,` |
| 关闭当前 buffer | `<Space>bd` |
| 新建 tab | `<Space><Tab><Tab>` |
| 关闭 tab | `<Space><Tab>d` |

#### 4.8.1 切换文件和返回光标位置

在已经打开的文件之间切换，用 `<Shift-h>` 回到上一个 buffer、`<Shift-l>` 到下一个 buffer；文件较多时按 `<Space>,` 打开 buffer 列表，按文件名筛选后按 `Enter` 进入。这里的 buffer 是已打开文件，不等同于分屏窗口。

“回到刚才光标所在位置”要看刚才发生了什么：

| 场景 | 键位 | 说明 |
|------|------|------|
| 从 `gd`、搜索结果等跳走后返回 | `<Ctrl-o>` | 回到较早的跳转位置，可能同时回到另一个文件 |
| 返回后再前进 | `<Ctrl-i>` | 回到较新的跳转位置 |
| 同一文件内回到上一次跳转前的精确列位置 | &#96;&#96; | 两个反引号，回到上一次跳转前的精确光标位置 |
| 回到上一次编辑的位置 | `g;` | 适合改完一处后继续回看刚才改过的位置 |
| 在修改位置历史中前进 | `g,` | 与 `g;` 相反 |

最常用的是 `<Ctrl-o>` / `<Ctrl-i>`：例如按 `gd` 跳进函数定义后，按 `<Ctrl-o>` 回到调用处；在 buffer 列表里切换文件后，通常还能保留各自上次离开时的光标位置。

### 4.9 `which-key` 提示菜单

按 `<Space>` 后弹出的窗口是 `which-key`。

`<Space>` 是 LazyVim 的前置键，也叫 leader 键。`which-key` 里第一层显示的快捷键都要先按 `<Space>`，再按菜单里显示的键。例如菜单里显示 `e -> Explorer`，实际按法是 `<Space>e`，打开/关闭文件栏；显示 `f -> +file/find`，实际按法是先 `<Space>f`，再根据子菜单继续按后续键。

不是所有快捷键都需要 `<Space>`。普通 Vim 操作直接按，例如 `gg`、`G`、`/关键词`、`n`、`i`、`Esc`、`gd`。

VS Code 的 `Ctrl+Shift+P` 对应的是“按命令名查找并执行命令”。LazyVim 中按 `<Space>sc` 打开 `Commands` picker，输入 `lazy`、`health`、`format` 等关键词后按 `Enter` 执行。想直接输入已知命令时，按 `:` 进入 Neovim 命令行，例如 `:Lazy`、`:checkhealth`、`:w`；按 `<Space>:` 可以查看并重用最近执行过的命令。

这三个入口用途不同：

| 目标 | 入口 |
|------|------|
| 按命令名查找并执行，类似 VS Code 命令面板 | `<Space>sc` |
| 直接输入已知 Neovim 命令 | `:` |
| 查找项目文件 | `<Space><Space>` |
| 查找项目文本 | `<Space>/` |
| 查快捷键映射 | `<Space>sk` |

常见入口：

| 显示 | 说明 |
|------|------|
| `e -> Explorer Snacks (root dir)` | 打开项目根目录栏 |
| `, -> Buffers` | 切换已打开文件 |
| `- -> Split Window Below` | 向下分屏 |
| `\| -> Split Window Right` | 向右分屏 |
| `/ -> Grep (Root Dir)` | 全文搜索 |
| `? -> Buffer Keymaps` | 查看当前窗口可用快捷键 |
| `f -> +file/find` | 文件和查找相关子菜单 |
| `g -> +git` | Git 子菜单 |
| `u -> +ui` | UI 开关 |
| `w -> +windows` | 窗口子菜单 |

带 `+` 的项目表示后面还有一层子菜单。例如按 `<Space>f` 后，会继续显示文件相关命令。

记不住时按这个顺序查：

```text
不知道入口：按 <Space> 看 which-key
不知道关键词：按 <Space>sk 搜 keymaps
不知道当前窗口局部键：按 <Space>? 看 Buffer Keymaps
```

### 4.10 常用命令速查

| 类型 | 操作 |
|------|------|
| 插件管理 | `:Lazy`、`:Lazy sync`、`:Lazy update` |
| 健康检查 | `:LazyHealth`、`:checkhealth` |
| 查看启动报错 | `:messages`、`:LazyHealth`、`:checkhealth` |
| LSP 工具 | `:Mason`、`<Space>cl`、`:checkhealth vim.lsp` |
| 语言扩展 | `:LazyExtras` |
| Git 状态 | `<Space>gs` |
| 当前行诊断 | `<Space>cd` |
| 下一个 / 上一个诊断 | `]d` / `[d` |
| UI 开关 | `<Space>u` 后看 `which-key` 子菜单 |

## 5. 基础配置

### 5.1 `options.lua`

编辑 `lua/config/options.lua`，加入自己需要覆盖的选项：

```lua
-- 行号和滚动
vim.opt.relativenumber = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

-- 编辑体验
vim.opt.wrap = false
vim.opt.confirm = true
vim.opt.clipboard = "unnamedplus"

-- Window下让 Neovim 的 :terminal 和外部命令使用 PowerShell 7
if vim.fn.has("win32") == 1 and vim.fn.executable("pwsh") == 1 then
  vim.opt.shell = "pwsh"
  vim.opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
  vim.opt.shellquote = ""
  vim.opt.shellxquote = ""
end
```

`clipboard = "unnamedplus"` 会让 Neovim 使用系统剪贴板。Linux 服务器没有图形剪贴板时，这一项可能不会生效，按 `:checkhealth clipboard` 的提示补 `xclip`、`xsel` 或 `wl-clipboard`。

### 5.2 `keymaps.lua`

LazyVim 默认快捷键已经够用，个人配置只补少量高频操作。编辑 `lua/config/keymaps.lua`：

```lua
local map = vim.keymap.set

map("n", "<leader>ww", "<cmd>w<cr>", { desc = "Save" })
map("n", "<leader>wq", "<cmd>wq<cr>", { desc = "Save and Quit" })
map("n", "<leader>tn", "<cmd>tabnew<cr>", { desc = "New Tab" })
map("n", "<leader>tc", "<cmd>tabclose<cr>", { desc = "Close Tab" })
```

LazyVim 默认 leader 是空格键。按下 `<Space>` 后会弹出 `which-key` 提示，不需要死记所有快捷键。

### 5.3 `plugins/snacks.lua`

LazyVim 当前默认的目录栏是 `Snacks Explorer`。它会尊重 `.gitignore`，所以一些被 Git 忽略的目录默认不显示。

临时显示 ignored files，直接在目录栏里按 `I`。如果想默认显示，可以新建 `lua/plugins/snacks.lua`：

```lua
return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = {
            -- 默认显示 .gitignore 忽略的文件/目录
            ignored = true,
            -- 默认显示 .env、.github 这类隐藏文件
            hidden = true,
            -- ignored = true 后会看到很多构建产物，这里继续排除特别大的目录
            exclude = {
              "**/.git/**",
              "**/node_modules/**",
              "**/.venv/**",
              "**/__pycache__/**",
            },
          },
        },
      },
    },
  },
}
```

不建议一开始就让搜索也默认扫 ignored files。`node_modules`、`dist`、`build` 这类目录会让文件查找和全文搜索变慢。需要临时在搜索框里显示 ignored files 时，打开 picker 后按 `<Alt-i>` 切换。

如果确实想让文件搜索和全文搜索也默认包含 ignored files，可以继续在同一个文件里加：

```lua
return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          files = {
            ignored = true,
            hidden = true,
            exclude = { "**/.git/**", "**/node_modules/**", "**/.venv/**" },
          },
          grep = {
            ignored = true,
            hidden = true,
            exclude = { "**/.git/**", "**/node_modules/**", "**/.venv/**" },
          },
        },
      },
    },
  },
}
```

实际使用更推荐只改 `explorer`，让左侧目录能看见被忽略目录；搜索仍然保持默认，避免把依赖目录和构建目录都扫进去。

### 5.4 `plugins/core.lua`

颜色主题建议单独放在 `lua/plugins/core.lua`：

```lua
return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },
}
```

切换主题后执行 `:Lazy sync`，再重启 `nvim`。

### 5.5 插件和 Extras

LazyVim 的插件由 `lazy.nvim` 下载、加载和更新。`Extras` 则是 LazyVim 维护好的功能组合：它会一次导入对应语言或工具需要的插件、默认配置和快捷键。日常需要 Python、C/C++、Docker 等支持时，优先启用对应 Extra；只有 Extra 不覆盖的个人需求，才单独写插件配置。

| 概念 | 解决的问题 | 配置位置 |
|------|------------|----------|
| Plugin | 一个独立 Neovim 插件，例如 `gitsigns.nvim`、`nvim-dap` | `lua/plugins/*.lua` 中的 Lua plugin spec |
| Extra | LazyVim 维护的一组插件和默认配置，例如 `lang.clangd` | 由 `:LazyExtras` 写入 LazyVim 的 import 配置 |
| `lazy.nvim` | 插件管理器，负责安装、更新、清理和查看加载错误 | `:Lazy` |

#### 5.5.1 查看状态和错误

先从下面几个命令开始，不要直接删除 `nvim-data` 或重装全部插件：

```vim
:Lazy          " 查看插件状态、更新和加载错误
:LazyHealth    " 检查 lazy.nvim 和插件管理环境
:checkhealth   " 检查 Neovim、provider、LSP 等环境
:messages      " 查看刚刚闪过的 Lua 或插件报错
:Lazy log      " 查看插件管理器的操作日志
```

`:Lazy` 界面中出现红色错误标记时，先查看插件名称和报错路径；`:messages` 通常能看到完整的 Lua 堆栈。启动就报错时，后面的 [7.5 启动时好像有报错，但没看清](#75-启动时好像有报错但没看清) 给出了终端日志的收集方式。

#### 5.5.2 启用和安装 Extra

进入 Neovim 后执行：

```vim
:LazyExtras
```

在列表中启用需要的模块，退出后执行：

```vim
:Lazy sync
```

`sync` 会安装 Extra 引入的新插件、更新锁文件，并移除已经不再配置的插件。常用 Extra 如下：

| 类型 | 建议启用 |
|------|----------|
| Python | `lang.python` |
| Markdown | `lang.markdown` |
| JSON / YAML | `lang.json`、`lang.yaml` |
| Docker | `lang.docker` |
| C / C++ | `lang.clangd` |
| Git | `util.gitui` 或搭配 `lazygit` |

不要同时在 `:LazyExtras` 和多个 `lua/plugins/*.lua` 文件里重复导入同一个 Extra。需要查实际导入了什么时，打开 `lua/config/lazy.lua`，能看到类似下面的 import：

```lua
{ import = "lazyvim.plugins.extras.lang.clangd" },
```

#### 5.5.3 安装自己的插件

新建 `lua/plugins/gitsigns.lua`，每个文件返回一个 plugin spec：

```lua
return {
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
    },
  },
}
```

保存后重启 Neovim，或执行 `:Lazy sync`。LazyVim 会自动读取 `lua/plugins` 下的 Lua 文件；不需要自己调用 `require("lazy").setup()`。

#### 5.5.4 移除 Extra 或插件

移除 Extra 时，打开 `:LazyExtras`，关闭对应模块，再执行：

```vim
:Lazy sync
```

移除手写插件时，删除或注释其 `lua/plugins/*.lua` 中对应的 spec，然后执行：

```vim
:Lazy clean
:Lazy sync
```

`clean` 只会删除已经不再出现在配置中的插件目录，不会修改项目代码。删除前先在 `:Lazy` 中确认目标插件；有些插件可能被其他 Extra 共同依赖，此时不应手动删除其目录。

### 5.6 C/C++ 配置 `clangd`

C/C++ 的 LSP 推荐直接用 `clangd`。它负责补全、跳转定义、查找引用、诊断、重命名等功能。LazyVim 里不要手动从零配置 `lspconfig`，先启用官方 extra。

在 Neovim 内执行：

```vim
:LazyExtras
```

找到并启用：

```text
lang.clangd
```

然后执行：

```vim
:Lazy sync
```

重启 `nvim`，打开一个 `.c`、`.cc`、`.cpp`、`.h`、`.hpp` 文件后，用下面方式确认 `clangd` 是否接管当前文件：

```vim
:checkhealth vim.lsp
```

也可以按：

```text
<Space>cl
```

如果看到当前 buffer 有 `clangd`，说明 LSP 已经启动。

`clangd` 能不能跳得准，关键在 `compile_commands.json`。这个文件记录每个源码文件实际编译时用的参数，例如 `-I` include 路径、`-D` 宏定义、`-std=c++20` 标准版本。没有这些信息，`clangd` 只能按很粗糙的默认方式理解代码。

#### 5.6.1 CMake 项目

CMake 项目最简单。Windows PowerShell 7：

```powershell
# 在项目根目录执行
cmake -S . -B build -G Ninja -DCMAKE_EXPORT_COMPILE_COMMANDS=ON

# Windows 创建软链接可能需要权限，直接复制最省事
Copy-Item build\compile_commands.json . -Force
```

Linux / zsh：

```bash
# 在项目根目录执行
cmake -S . -B build -G Ninja -DCMAKE_EXPORT_COMPILE_COMMANDS=ON

# clangd 可以识别 build/compile_commands.json；放根目录更直观
ln -sf build/compile_commands.json compile_commands.json
```

之后重新打开 C/C++ 文件，或者在 Neovim 里执行：

```vim
:LspRestart clangd
```

#### 5.6.2 Makefile 项目

Makefile 项目本身通常不会直接生成 `compile_commands.json`，可以用 `bear` 包一层：

```bash
# Linux
bear -- make -j"$(nproc)"
```

执行后项目根目录会生成 `compile_commands.json`。Windows 下 Makefile 项目环境差异比较大，如果是在 MSYS2 / WSL 里编译，优先在对应的 Linux-like shell 里生成 `compile_commands.json`，再让 Neovim 打开同一个项目目录。

#### 5.6.3 很小的单文件项目

如果只是几个简单的 `.cpp` 文件，不想上 CMake，可以在项目根目录放一个 `compile_flags.txt`：

```text
-std=c++20
-Iinclude
-Wall
```

这表示所有文件都按这些参数理解。它不如 `compile_commands.json` 精确，但适合小练习项目。

#### 5.6.4 常见检查点

| 现象 | 优先检查 |
|------|----------|
| `gd` 完全没反应 | `:checkhealth vim.lsp`、`<Space>cl`，确认 `clangd` 是否启动 |
| 标准库能跳，项目头文件不能跳 | `compile_commands.json` 里是否有正确的 `-I` 路径 |
| 宏、条件编译识别错 | `compile_commands.json` 里是否有正确的 `-D` 宏定义 |
| C++ 标准报错 | 是否有 `-std=c++17`、`-std=c++20` 等参数 |
| 修改构建参数后仍旧报错 | 重新生成 `compile_commands.json`，再执行 `:LspRestart clangd` |

简单判断：

```bash
# 在项目根目录检查
ls compile_commands.json compile_flags.txt
```

Windows PowerShell 7：

```powershell
Get-ChildItem compile_commands.json, compile_flags.txt -ErrorAction SilentlyContinue
```

#### 5.6.5 给不同项目配置编译数据库

不要在 `lua/plugins/clangd.lua` 或其他全局 Neovim 配置中写某个项目的 `compile_commands.json` 路径。全局配置只负责启动 `clangd`；每个项目自己的 `.clangd` 文件负责告诉 `clangd`“这个项目的编译数据库在哪”。

第一次只需要完成一次的事情：启用 `lang.clangd`，确认 `clangd --version` 正常。之后每新打开一个 C/C++ 项目，只做下面三步：

```text
项目根目录执行 CMake 配置
  -> 生成本项目的 build/nvim/compile_commands.json
  -> 项目根目录新建 .clangd，指向 build/nvim
  -> 在该项目根目录执行 nvim .
```

假设有两个无关项目：

```text
work/
├── project-a/
│   ├── CMakeLists.txt
│   ├── .clangd
│   └── build/nvim/compile_commands.json
└── project-b/
    ├── CMakeLists.txt
    ├── .clangd
    └── build/nvim/compile_commands.json
```

在 `project-a` 根目录执行下面命令：

```bash
cmake -S . -B build/nvim -G Ninja -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
```

然后新建 `project-a/.clangd`：

```yaml
CompileFlags:
  CompilationDatabase: build/nvim
```

接着打开项目：

```bash
cd project-a
nvim .
```

打开任意 `.cpp` 文件后执行 `:LspRestart clangd`，再按 `<Space>cl` 确认当前 buffer 已连接 `clangd`。`project-b` 完全重复这三步，但它使用自己的 `build/nvim` 和自己的 `.clangd`；从 `project-a` 切换到 `project-b` 时，只需：

```bash
cd ../project-b
nvim .
```

不需要改 Nvim 全局配置，也不需要把两个项目的 JSON 复制到同一个位置。`.clangd` 中的 `CompilationDatabase` 写的是“包含 `compile_commands.json` 的目录”，不是 JSON 文件名。只有当数据库放在 `build/nvim` 这类子目录时才需要 `.clangd`；如果项目根目录本来就有 `compile_commands.json`，`clangd` 会自动发现它，不需要额外配置。

`compile_commands.json` 是构建产物，通常不提交；`.clangd` 是项目配置，可以在团队统一使用 `build/nvim` 目录时提交。修改 `CMakeLists.txt`、include 路径、宏、编译器或 C++ 标准后，重新执行同一条 `cmake -S ... -B build/nvim ...` 命令，再执行 `:LspRestart clangd`。

### 5.7 Android NDK 交叉编译项目

Android NDK 项目也遵循上一节的规则：全局只启动一次 `clangd`，项目根目录的 `.clangd` 指向当前 Android ABI 对应的编译数据库。它不是用本机系统头文件和本机编译器，`clangd` 必须拿到正在编辑的 `.cpp` 文件真实使用的 Android 编译命令。这个命令来自 `compile_commands.json`，其中必须包含目标 ABI、API level、NDK sysroot、头文件目录和宏定义。

先记住这条链路：

```text
真实 CMake / Gradle 构建配置
  -> 对应 ABI 的 compile_commands.json
  -> 项目根目录 .clangd 指向该数据库
  -> :LspRestart clangd
  -> gd / gr 使用 Android 头文件和宏
```

同一个工程不要把 `arm64-v8a`、`x86_64` 等 ABI 的编译数据库混在一起。日常编辑哪个 ABI，就让 `.clangd` 指向哪个 ABI 的构建目录；数据库里没有当前 `.cpp` 的条目时，`clangd` 无法猜出它应该使用 Android NDK。

#### 5.7.1 先确认要生成什么

| 项 | 说明 |
|----|------|
| NDK 路径 | 例如 `Android/Sdk/ndk/<version>` |
| 目标 ABI | 例如 `arm64-v8a`、`armeabi-v7a`、`x86_64` |
| Android API level | 例如 `android-24`、`android-28` |

最稳定的做法是让 CMake 使用 NDK 自带的 toolchain file 生成 `compile_commands.json`。NDK 的 toolchain file 路径固定是：

```text
<NDK>/build/cmake/android.toolchain.cmake
```

#### 5.7.2 准备 NDK 路径

Windows PowerShell 7：

```powershell
# 优先使用已有 ANDROID_SDK_ROOT / ANDROID_HOME；没有就使用 Android Studio 默认路径
$SdkRoot = if ($env:ANDROID_SDK_ROOT) {
    $env:ANDROID_SDK_ROOT
} elseif ($env:ANDROID_HOME) {
    $env:ANDROID_HOME
} else {
    "$env:LOCALAPPDATA\Android\Sdk"
}

# 自动选一个已安装的 NDK 版本
$Ndk = Get-ChildItem "$SdkRoot\ndk" -Directory |
    Sort-Object Name -Descending |
    Select-Object -First 1

$env:ANDROID_NDK_HOME = $Ndk.FullName
$env:ANDROID_NDK = $Ndk.FullName

$env:ANDROID_NDK_HOME
Test-Path "$env:ANDROID_NDK_HOME\build\cmake\android.toolchain.cmake"
```

Linux / zsh：

```bash
# 优先使用已有 ANDROID_SDK_ROOT / ANDROID_HOME；没有就使用 Android Studio 默认路径
export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-$HOME/Android/Sdk}}"

# 自动选一个已安装的 NDK 版本
export ANDROID_NDK_HOME="$(
  find "$ANDROID_SDK_ROOT/ndk" -mindepth 1 -maxdepth 1 -type d |
  sort -V |
  tail -n 1
)"
export ANDROID_NDK="$ANDROID_NDK_HOME"

echo "$ANDROID_NDK_HOME"
test -f "$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake"
```

想长期生效就写进 shell profile。Linux 默认写 `~/.zshrc`：

```bash
cat >> ~/.zshrc <<'EOF'
export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$HOME/Android/Sdk}"
export ANDROID_NDK_HOME="$(find "$ANDROID_SDK_ROOT/ndk" -mindepth 1 -maxdepth 1 -type d | sort -V | tail -n 1)"
export ANDROID_NDK="$ANDROID_NDK_HOME"
EOF

source ~/.zshrc
```

Windows 可以写进 PowerShell 7 的 `$PROFILE`，但 NDK 版本经常升级，手动固定版本路径也可以：

```powershell
$env:ANDROID_SDK_ROOT = "$env:LOCALAPPDATA\Android\Sdk"
$env:ANDROID_NDK_HOME = "$env:LOCALAPPDATA\Android\Sdk\ndk\<ndk-version>"
$env:ANDROID_NDK = $env:ANDROID_NDK_HOME
```

#### 5.7.3 CMake 生成 Android 的 `compile_commands.json`

下面以 `arm64-v8a` 和 `android-24` 为例。`ANDROID_ABI` 和 `ANDROID_PLATFORM` 要和实际项目一致。

Windows PowerShell 7：

```powershell
# 在 CMakeLists.txt 所在项目根目录执行
cmake -S . -B build\android-arm64 -G Ninja `
    -DCMAKE_TOOLCHAIN_FILE="$env:ANDROID_NDK_HOME\build\cmake\android.toolchain.cmake" `
    -DANDROID_ABI=arm64-v8a `
    -DANDROID_PLATFORM=android-24 `
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON

# 让项目根目录的 clangd 固定使用 arm64-v8a 构建数据库
@'
CompileFlags:
  CompilationDatabase: build/android-arm64
'@ | Set-Content .clangd -Encoding utf8
```

Linux / zsh：

```bash
# 在 CMakeLists.txt 所在项目根目录执行
cmake -S . -B build/android-arm64 -G Ninja \
  -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake" \
  -DANDROID_ABI=arm64-v8a \
  -DANDROID_PLATFORM=android-24 \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON

# 让项目根目录的 clangd 固定使用 arm64-v8a 构建数据库
cat > .clangd <<'EOF'
CompileFlags:
  CompilationDatabase: build/android-arm64
EOF
```

`.clangd` 要放在项目根目录，和 `CMakeLists.txt` 同级。`CompilationDatabase` 相对 `.clangd` 所在目录计算，因此上例实际使用的是 `build/android-arm64/compile_commands.json`。切换到 `x86_64` 等 ABI 时，重新生成对应构建目录，再把这里改成那个目录；不要复制多个 ABI 的数据库到根目录互相覆盖。

然后检查：

```bash
# Linux
db=build/android-arm64/compile_commands.json
ls -lh "$db"
grep -n "aarch64-linux-android" "$db" | head
```

```powershell
# Windows
$db = "build\android-arm64\compile_commands.json"
Get-Item $db
Select-String -Path $db -Pattern "aarch64-linux-android" | Select-Object -First 5
```

如果能看到 `aarch64-linux-android`、`--target`、`sysroot`、NDK include 路径，说明编译数据库里已经有 Android 交叉编译信息。

#### 5.7.4 LazyVim 给 `clangd` 加 `query-driver`

先完成上一节的编译数据库配置，再处理 `--query-driver`。数据库中已经有 `--target`、`--sysroot`、NDK include 路径时，`clangd` 通常可以直接工作；出现 NDK 标准库或系统头文件找不到时，再添加这个参数。它允许 `clangd` 查询 NDK 自带的 `clang++`，补齐 driver 默认的 target 和系统 include 路径。

新建或编辑 `lua/plugins/clangd.lua`：

```lua
local function android_ndk_query_driver()
  local ndk = vim.env.ANDROID_NDK_HOME or vim.env.ANDROID_NDK
  if not ndk or ndk == "" then
    return nil
  end

  ndk = ndk:gsub("\\", "/")

  local host = "linux-x86_64"
  if vim.fn.has("win32") == 1 then
    host = "windows-x86_64"
  end

  return ndk .. "/toolchains/llvm/prebuilt/" .. host .. "/bin/*clang*"
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}

      local cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--completion-style=detailed",
        "--header-insertion=iwyu",
      }

      local query_driver = android_ndk_query_driver()
      if query_driver then
        table.insert(cmd, "--query-driver=" .. query_driver)
      end

      opts.servers.clangd = vim.tbl_deep_extend("force", opts.servers.clangd or {}, {
        cmd = cmd,
      })
    end,
  },
}
```

重启 `nvim`，或者执行：

```vim
:Lazy sync
:LspRestart clangd
```

确认当前文件由 `clangd` 接管：

```vim
:checkhealth vim.lsp
```

或者按：

```text
<Space>cl
```

#### 5.7.6 验证和常见问题

| 现象 | 原因 | 处理 |
|------|------|------|
| `jni.h` 找不到 | 没用 NDK toolchain 生成 `compile_commands.json` | 用 `android.toolchain.cmake` 重新生成 |
| `.clangd` 不生效 | 路径不是数据库所在目录，或当前文件不在该项目根目录下 | 确认 `CompilationDatabase` 指向含 `compile_commands.json` 的目录 |
| 标准库头文件找不到 | `clangd` 没查到 NDK driver 默认 include | 配置 `--query-driver=<NDK>/toolchains/llvm/prebuilt/.../bin/*clang*` |
| `gd` 能跳当前文件，跨文件不行 | 编译数据库没覆盖对应 `.cpp` | 确认 `compile_commands.json` 里有这个源文件 |
| 宏分支大量报错 | ABI、API level 或 `-D` 宏和真实构建不一致 | 用真实构建命令重新生成 `compile_commands.json` |
| Windows 生成的数据库在 WSL 里用不了 | 路径格式不同 | 在 WSL/Linux 环境重新生成，不要混用 Windows 路径 |

排查时优先看当前文件实际使用的编译命令：

```vim
:LspLog
```

在日志里搜索当前 `.cpp` 文件名，重点看 `compile command`、`query-driver`、`include`、`sysroot` 相关行。

最小验收流程如下：

```text
1. 打开一个确实出现在 compile_commands.json 中的 .cpp 文件
2. 执行 :LspRestart clangd
3. 执行 :checkhealth vim.lsp 或按 <Space>cl，确认 clangd 已附着
4. 执行 :LspLog，搜索该 .cpp 文件，确认命令中有 --target、--sysroot 或 NDK 路径
5. 把光标放在 jni.h、Android 类型或项目内跨文件函数上，按 gd 验证跳转
```

## 6. Shell 集成

### 6.1 PowerShell 7 Profile

查看并编辑 PowerShell 7 的 profile：

```powershell
$PROFILE
New-Item -ItemType Directory -Force (Split-Path $PROFILE)
notepad $PROFILE
```

加入下面配置：

```powershell
Set-Alias vi nvim
Set-Alias vim nvim

$env:EDITOR = "nvim"
$env:VISUAL = "nvim"

function nvconf {
    nvim "$env:LOCALAPPDATA\nvim"
}

function nvdata {
    Set-Location "$env:LOCALAPPDATA\nvim-data"
}
```

重新加载：

```powershell
. $PROFILE
```

之后可以直接用 `vim .` 或 `nvconf` 打开配置目录。

### 6.2 Linux Shell

Linux Shell 配置默认写入 `~/.zshrc`：

```bash
cat >> ~/.zshrc <<'EOF'
alias vi='nvim'
alias vim='nvim'

export EDITOR=nvim
export VISUAL=nvim

alias nvconf='nvim ~/.config/nvim'
EOF

source ~/.zshrc
```

## 8. 参考链接

- [LazyVim Installation](https://www.lazyvim.org/installation)
- [LazyVim Configuration](https://www.lazyvim.org/configuration)
- [LazyVim Keymaps](https://www.lazyvim.org/keymaps)
- [LazyVim Clangd Extra](https://www.lazyvim.org/extras/lang/clangd)
- [Neovim INSTALL.md](https://github.com/neovim/neovim/blob/master/INSTALL.md)
- [Snacks Explorer](https://github.com/folke/snacks.nvim/blob/main/docs/explorer.md)
- [Android NDK CMake](https://developer.android.com/ndk/guides/cmake)
- [clangd Getting Started](https://clangd.llvm.org/installation)
- [clangd Compile Commands](https://clangd.llvm.org/design/compile-commands)
- [clangd Configuration](https://clangd.llvm.org/config)
