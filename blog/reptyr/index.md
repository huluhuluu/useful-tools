---
title: "reptyr 使用指南"
date: 2026-03-04T12:00:00+08:00
lastmod: 2026-05-14T22:20:00+08:00
draft: false
description: "将运行中的进程转移到新的终端"
slug: "reptyr-guide"
tags: ["tools"]
categories: ["tools"]

comments: true
math: true
---

# reptyr 使用指南

`reptyr` 是一个把已经在运行的程序重新挂到当前终端的工具。最常见的场景是 SSH 连上服务器后启动了一个长任务，结果终端马上要断开，这时可以把它接到新的 `tmux` 或 `screen` 会话里继续跑。

## 1. 安装

Ubuntu / Debian 下直接安装：

```bash
# install reptyr
sudo apt install -y reptyr

# verify installation
➜ ✗ reptyr -v       
This is reptyr version 0.6.2.
```

## 2. 使用

`reptyr` 基本的命令是`reptyr <pid>`, 它会把目标进程的输入输出接到当前终端, 其典型的用途有两个：

- 在普通 SSH 终端里启动了长任务，想把它挂到 `tmux` / `screen`
- 一个进程已经跑起来了，但希望切到另一个终端继续交互

示例流程如下：

```bash
# 1. 启动一个长任务
top

# 2. 先挂起
Ctrl+Z

# 3. 放到后台继续跑
bg

# 4. 查看 PID
jobs -l

# 5. 从当前 shell 里解除作业管理
disown %1

# 6. 启动 tmux
tmux

# 7. 在 tmux 里接管这个进程
reptyr <pid>
```

接管完成后，这个进程就会从新的终端读输入、往新的终端写输出，`Ctrl+C`、`Ctrl+Z` 这类信号也会跟过去。

## 3. 常见问题

### 3.1 `ptrace_scope` 限制

`reptyr` 依赖 `ptrace`。Ubuntu Maverick 及之后的系统，默认可能会限制 `ptrace`。

官方 README 给的临时处理方式是：

```bash
sudo sh -c 'echo 0 > /proc/sys/kernel/yama/ptrace_scope'
```

这个修改是临时的。长期配置需要看系统里的 `/etc/sysctl.d/10-ptrace.conf`。

!!另外`docker` 里默认也限制了 `ptrace`，所以如果在容器里用 `reptyr` 需要启动`docker`时额外配置。

### 3.2 平台支持有限

官方 README 里明确写到：

- `reptyr` 支持 Linux 和 FreeBSD
- FreeBSD 上不是所有功能都完整可用

### 3.3 Shell 作业状态不会完全同步

README 里还提到一个限制：

- 进程接到新终端以后，旧 shell 的作业状态不会自动变干净
- 如果后续还在旧终端里处理前后台，可能还得手动 `bg` 或 `fg`

## 参考资料

- [reptyr GitHub](https://github.com/nelhage/reptyr)