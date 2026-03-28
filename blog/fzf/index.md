---
title: "FZF 使用备忘"
date: 2026-03-28T12:30:00+08:00
lastmod: 2026-03-28T12:30:00+08:00
draft: false
description: "命令行模糊搜索工具，提升终端效率"
slug: "fzf"
tags: ["FZF", "终端"]
categories: ["实用工具"]
comments: true
math: true
---

# FZF 使用备忘

[FZF](https://github.com/junegunn/fzf) 是一个通用的命令行模糊搜索工具，可以与多种工具配合使用，例如CRTL+R搜索历史命令、快速打开文件等。用 Go 编写，速度非常快，[教程与效果演示参考](https://yalandhong.github.io/2022/11/03/shell/zsh-fzf)。

## 1. 安装

```bash
# 克隆仓库
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
# 运行安装脚本
~/.fzf/install
```

### 1.1 配置zsh

```bash
# 在 ~/.zshrc 的插件中中添加 fzf，例如下面， 这里的插件使用空格分隔
plugins=(git sudo z zsh-syntax-highlighting zsh-autosuggestions fzf)

# 过程
vim ~/.zshrc
/plugins= # 命令模式直接输入前面字符串 然后回车 表示搜索这个命令
# 在末尾添加 fzf
# 保存退出 (:wq)
source ~/.zshrc # 使配置生效
``` 

## 2. 基本使用

### 2.1 文件搜索

```bash
# 搜索当前目录文件
fzf

# 搜索并打开文件
vim $(fzf)
```

### 2.2 历史命令搜索

按 Ctrl-R 搜索历史命令，输入关键字实时过滤
![Ctrl-R 历史命令搜索](./png/history-search.png)

### 2.3 模糊搜索
在`shell`中，输入`**`再按tab可以进入`fzf`的模糊搜索模式，输入关键字后按回车即可跳转到对应目录。
![模糊搜索模式](./png/fuzzy-search.png)


### 2.4 子目录直达
`Alt+C` 可以进入`fzf`的子目录搜索模式，输入关键字后按回车即可跳转到对应目录。


## 3. 高级用法

### 3.1 搜索语法

在 fzf 搜索框中可以使用特殊语法：

```
abc          # 包含 abc
^abc         # 以 abc 开头
abc$         # 以 abc 结尾
!abc         # 不包含 abc
abc def      # 同时包含 abc 和 def
abc|def      # 包含 abc 或 def
'abc         # 精确匹配 abc（非模糊）
!^abc        # 不以 abc 开头
```

### 3.2 多选模式

```bash
# 多选文件（Tab 选择，Shift-Tab 取消）
fzf --multi
```


---

## 参考链接

- [FZF GitHub](https://github.com/junegunn/fzf)
- [FZF Wiki](https://github.com/junegunn/fzf/wiki)
- [FZF效果](https://yalandhong.github.io/2022/11/03/shell/zsh-fzf)