---
title: "包管理器常用命令备忘"
date: 2026-03-29T12:00:00+08:00
lastmod: 2026-04-25T12:00:00+08:00
draft: false
description: "npm/pip/apt/winget 等常用包管理器命令速查"
slug: "package-managers"
tags: ["tools"]
categories: ["tools"]

comments: true
math: true
---

# 包管理器常用命令备忘

各平台常用包管理器的命令速查，包括 npm、apt、winget、brew 等。

## 1. 包管理器

### 1.1 npm

```bash
# 初始化项目
npm init                    # 交互式创建 package.json
npm init -y                 # 使用默认值创建

# 安装依赖
npm install                 # 安装 package.json 中的所有依赖
npm install package         # 安装到 dependencies
npm install package@1.2.3   # 安装指定版本
npm install -D package      # 安装到 devDependencies
npm install -g package      # 全局安装

# 卸载
npm uninstall package       # 卸载本地包
npm uninstall -g package    # 卸载全局包

# 更新
npm update                  # 更新所有依赖
npm update package          # 更新指定包
npm outdated                # 查看过时的包

# 查看
npm list                    # 查看已安装的包
npm list -g --depth=0       # 查看全局安装的包
npm view package            # 查看包信息
npm view package versions   # 查看包所有版本

# 运行脚本
npm run script-name         # 运行 package.json 中的脚本
npm start / npm test        # 运行 start/test 脚本

# 清理缓存
npm cache clean --force

# 检查安全问题
npm audit
npm audit fix
```

### 1.2 yarn

```bash
# 安装 yarn
npm install -g yarn

# 初始化
yarn init -y

# 安装依赖
yarn                        # 安装所有依赖
yarn add package            # 安装到 dependencies
yarn add -D package         # 安装到 devDependencies
yarn global add package     # 全局安装

# 卸载
yarn remove package
yarn global remove package

# 更新
yarn upgrade
yarn upgrade package

# 查看
yarn list
yarn info package

# 运行脚本
yarn script-name
yarn run script-name
```

### 1.3 apt (Debian/Ubuntu)

```bash
# 更新软件源
sudo apt update

# 升级已安装的包
sudo apt upgrade            # 升级所有包
sudo apt full-upgrade       # 完整升级（可删除包）
sudo apt install package    # 安装包
sudo apt install package=1.2.3  # 指定版本

# 卸载
sudo apt remove package     # 卸载但保留配置
sudo apt purge package      # 卸载并删除配置
sudo apt autoremove         # 清理不再需要的依赖

# 搜索和查看
apt search keyword
apt show package
apt list --installed
apt list --upgradable

# 清理缓存
sudo apt clean              # 清理下载的 deb 包
sudo apt autoclean          # 清理过期的 deb 包

# 添加 PPA
sudo add-apt-repository ppa:user/ppa-name
sudo apt update
```

### 1.4 winget

```powershell
# 搜索
winget search vscode
winget search --id "Microsoft.VisualStudioCode"

# 安装
winget install Microsoft.VisualStudioCode
winget install --id "Microsoft.VisualStudioCode"
winget install -e --id "Microsoft.VisualStudioCode"  # 精确匹配

# 卸载
winget uninstall "Visual Studio Code"
winget uninstall --id "Microsoft.VisualStudioCode"

# 更新
winget upgrade              # 更新所有
winget upgrade --id "Microsoft.VisualStudioCode"

# 查看已安装
winget list
winget list --name "Visual"

# 导出/导入
winget export -o packages.json
winget import -i packages.json
```

### 1.5 scoop

```powershell
# 安装 scoop
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh | iex

# 安装包
scoop install git
scoop install nodejs
scoop install python

# 卸载
scoop uninstall git

# 更新
scoop update                # 更新 scoop 自身
scoop update *              # 更新所有包
scoop update git            # 更新指定包

# 搜索和查看
scoop search git
scoop list

# 清理旧版本
scoop cleanup *
scoop cache rm *

# 换源
```

#### Scoop 换源

`Scoop` 换源通常分两部分：

1. `Scoop` 自己的仓库地址
2. 已添加 bucket 的 Git 远程地址

只改第 1 部分还不够，因为 `main`、`extras` 这些 bucket 本质上也是单独的 Git 仓库。

查看当前配置：

```powershell
scoop config SCOOP_REPO
scoop bucket list
git -C "$HOME\scoop\apps\scoop\current" remote -v
git -C "$HOME\scoop\buckets\main" remote -v
```

切到 Gitee 镜像：

```powershell
# 1. 修改 Scoop 自身仓库地址
scoop config SCOOP_REPO https://gitee.com/scoop-installer/scoop

# 2. 修改本地 Scoop 仓库的远程地址
git -C "$HOME\scoop\apps\scoop\current" remote set-url origin https://gitee.com/scoop-installer/scoop

# 3. 修改 main bucket 的远程地址
git -C "$HOME\scoop\buckets\main" remote set-url origin https://gitee.com/scoop-installer/Main

# 4. 更新
scoop update
```

如果还加过其他 bucket，例如 `extras`、`versions`，也要分别改：

```powershell
git -C "$HOME\scoop\buckets\extras" remote set-url origin https://gitee.com/scoop-installer/Extras
git -C "$HOME\scoop\buckets\versions" remote set-url origin https://gitee.com/scoop-installer/Versions
```

切回官方 GitHub：

```powershell
scoop config SCOOP_REPO https://github.com/ScoopInstaller/Scoop
git -C "$HOME\scoop\apps\scoop\current" remote set-url origin https://github.com/ScoopInstaller/Scoop
git -C "$HOME\scoop\buckets\main" remote set-url origin https://github.com/ScoopInstaller/Main
scoop update
```

如果 bucket 已经乱了，最直接的办法是删掉再重新添加：

```powershell
scoop bucket rm main
scoop bucket add main https://gitee.com/scoop-installer/Main
```

常用 bucket 重新添加示例：

```powershell
scoop bucket add extras https://gitee.com/scoop-installer/Extras
scoop bucket add versions https://gitee.com/scoop-installer/Versions
```

验证是否生效：

```powershell
scoop config SCOOP_REPO
scoop bucket list
git -C "$HOME\scoop\apps\scoop\current" remote -v
git -C "$HOME\scoop\buckets\main" remote -v
```

本机当前示例：

```powershell
scoop config SCOOP_REPO
# https://gitee.com/scoop-installer/scoop

git -C "$HOME\scoop\buckets\main" remote -v
# origin https://gitee.com/scoop-installer/Main
```

---
