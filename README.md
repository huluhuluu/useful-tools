---
title: "实用工具"
draft: true
---

# 实用工具

开发过程中用到的一些实用小工具配置记录。

## 目录

### VSCode 相关

| 文章 | 说明 | 状态 |
|------|------|------|
| [VSCode Copilot 配置](/p/copilot-config/) | 配置 Copilot Chat 使用本地局域网大模型 API | ✅ 完成 |
| [flash.vscode 插件](/p/flash-vscode/) | 在 VSCode 中快速跳转到屏幕可见的任意一行 | ✅ 完成 |

### AI Agent 框架

| 文章 | 说明 | 状态 |
|------|------|------|
| [Claude Code 配置](/p/claude-code/) | Anthropic 推出的本地运行 Agent 框架 | ✅ 完成 |
| [iFlow CLI 配置](/p/iflow-cli/) | 阿里推出的终端 Agent 框架 | ✅ 完成 |

### 终端工具

| 文章 | 说明 | 状态 |
|------|------|------|
| [Zsh 配置](/p/zsh-config/) | Zsh 终端配置与优化 | 📝 TODO |
| [reptyr 使用](/p/reptyr-guide/) | 将运行中的进程转移到新的终端 | 📝 TODO |
| [Tmux 使用](/p/tmux-guide/) | 终端复用器 Tmux 配置与使用 | 📝 TODO |

---

## 工具概览

### VSCode Copilot

通过配置 `remote.extensionKind` 和 `OAI Compatible Provider for Copilot` 插件，可以让 Copilot Chat 使用第三方大模型 API，如 ModelScope、DeepSeek 等。

### flash.vscode

类似 Vim 的 EasyMotion 插件，通过快捷键快速跳转到屏幕中任意可见的位置，提升编辑效率。

### Claude Code

Anthropic 官方推出的终端 Agent 框架，支持工具调用、Skills 配置，可通过 `cc-switch` 切换不同的大模型后端。

### iFlow CLI

阿里推出的终端 Agent 框架，目前提供限免的 GLM5.0、Kimi-K2.5、MiniMax-M2.5 等模型。

### Zsh

功能强大的 Unix Shell，配合 Oh My Zsh 框架可实现丰富的自动补全、语法高亮等功能。

### reptyr

将已在运行的进程"转移"到另一个终端，适用于将后台进程重新 attach 到前台。

### Tmux

终端复用器，支持会话持久化、窗口分割、面板管理，是远程开发的必备工具。
