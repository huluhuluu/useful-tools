---
title: "Tmux 使用指南"
date: 2026-03-04T12:00:00+08:00
lastmod: 2026-03-26T18:00:00+08:00
draft: false
description: "终端复用器 Tmux 配置与使用"
slug: "tmux-guide"
tags: ["tools"]
categories: ["tools"]

comments: true
math: true
---

# Tmux 使用备忘

[Tmux](https://github.com/tmux/tmux) (Terminal Multiplexer) 是一个终端复用器，允许在一个终端窗口中创建多个会话、窗口和面板，支持会话**持久化**。适合远程连接服务器**运行长时间命令**，并且ssh连接断开后执行的命令不会随着ssh连接断开而结束。

## 1. 安装

```bash
# Ubuntu/Debian
sudo apt install -y tmux

# 验证安装
tmux -V
# tmux 3.2a # 输出版本号表示安装成功

echo 'set -g mouse on' >> ~/.tmux.conf # 开启鼠标模式
```

## 2. 使用

### 2.1 前置键

`tmux` 的快捷键通常都需要先按前置键。默认前置键是 `Ctrl+B`。

例如退出会话但不关闭会话本身，用的是 `Ctrl+B, d`。这里的 `,` 只是表示“分两次按键”，不是同时按下。

### 2.2 常用会话命令

| 操作 | 命令 / 按键 | 说明 |
|------|-------------|------|
| 新建会话 | `tmux` | 新建默认名称会话 |
| 新建指定会话 | `tmux new -s name` | 方便后续重新进入或关闭 |
| 查看会话 | `tmux ls` | 列出当前所有会话 |
| 进入最近会话 | `tmux attach` | 进入最近使用的会话 |
| 进入指定会话 | `tmux attach -t name` | 进入指定名称会话 |
| 简写进入 | `tmux a -t name` | `attach` 的简写 |
| 关闭指定会话 | `tmux kill-session -t name` | 关闭目标会话 |
| 关闭所有会话 | `tmux kill-server` | 关闭整个 `tmux` 服务 |
| 退出但不关闭 | `Ctrl+B, d` | detach 当前会话 |
| 退出并关闭 | `exit` | 结束当前 shell，关闭当前 pane |

### 2.3 Pane 分屏操作

| 操作 | 按键 / 命令 | 说明 |
|------|-------------|------|
| 上下分屏 | `Ctrl+B, %` | 创建上下 pane |
| 左右分屏 | `Ctrl+B, "` | 创建左右 pane |
| 方向切换 pane | `Ctrl+B, ←/↑/↓/→` | 每次切换都要重新按前置键 |
| 数字跳转 pane | `Ctrl+B, q` | 屏幕会显示数字，快速按数字可跳转 |
| 调整 pane 大小 | `Ctrl+B, Ctrl+←/↑/↓/→` | 按方向调整当前 pane 大小 |
| 关闭当前 pane | `Ctrl+B, x` | 按完后输入 `y` 确认 |
| 重命名会话 | `Ctrl+B, :rename-session name` | 进入命令行后执行 |
| 开启鼠标模式 | `Ctrl+B, :set -g mouse on` | 临时开启鼠标支持 |

数字跳转 pane 的效果如下：

![分屏数字标识](./png/pane-jump.png)

关闭 pane 时会出现确认提示：

![关闭分屏确认提示](./png/pane-close.png)

重命名会话时会进入底部命令行：

![重命名会话](./png/rename-session.png)

开启鼠标模式的命令如下：

![开启鼠标模式命令](./png/mouse-mode.png)

---

## 3. 参考链接
- [Tmux GitHub](https://github.com/tmux/tmux)
- [Tmux 参考tutorial](https://www.ruanyifeng.com/blog/2019/10/tmux.html)
- [Tmux 快捷键](https://tmuxcheatsheet.com/)
