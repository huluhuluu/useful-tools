---
title: "Zsh 配置指南"
date: 2026-03-04T12:00:00+08:00
lastmod: 2026-03-04T12:00:00+08:00
draft: true
description: "Zsh 终端配置与优化"
slug: "zsh-config"
tags: ["Zsh", "终端", "Shell"]
categories: ["实用工具"]
comments: true
math: true
---

# Zsh 配置指南备忘

zsh 是一个功能强大的 Unix Shell，具有丰富的自动补全、语法高亮、主题定制等特性。本文将介绍如何安装和配置 zsh，以及一些实用的插件推荐。

## 安装
```bash
sudo apt install zsh -y
```

## 配置自动补全和语法高亮
```bash
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
```

`.zshrc`是`zsh`的配置文件，可以通过修改该文件来配置`zsh`。例如，启用插件、设置主题、配置环境变量等。修改完成后，执行`source ~/.zshrc`命令使配置生效。
## 参考资料

- [Zsh 官方网站](https://www.zsh.org/)
- [Oh My Zsh](https://ohmyz.sh/)
