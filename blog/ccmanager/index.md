---
title: "ccmanager 使用备忘"
date: 2026-05-14T19:05:00+08:00
lastmod: 2026-05-14T19:50:00+08:00
draft: false
description: "基于 ccmanager 官方 README 整理一篇多 Agent 会话管理与 Git worktree 协作备忘"
slug: "ccmanager"
tags: ["tools", "agent", "git"]
categories: ["tools"]

comments: true
math: true
---

# ccmanager 使用备忘

[ccmanager](https://github.com/kbwo/ccmanager) 是一个 `AI Agent Session Manager`，核心目标是把 `Claude Code`、`Codex CLI`、`Gemini CLI`、`Cursor Agent` 这类终端 Agent 会话统一管理，适合“多 Agent 会话 + 多分支并行开发”的场景，可以做到在多个分支`Agent`会话之间快速切换。

## 1. 安装和启动

通过`npm`进行安装：

```bash
# 全局安装
npm install -g ccmanager

# 直接运行
ccmanager
```

### 1.1 配置

README 里默认快捷键有两个(快捷键可以在 CLI/`config.json`修改)：

- `Ctrl+E`：从活跃会话返回菜单，可以在`Configure Shortcuts`里修改
- `Escape`：取消或返回

通过CLI界面配置`codex`的启动: 选择`Configure Command Presets` -> ` Select preset before session start: ❌ Disabled` 设置为Enabled 随后 `Add New Preset` -> 选择`Codex`，然后设置命令为`codex`，参数为`-a on-request` -> `Set as Default`设置成默认启动项。
```bash
➜ ✗ ccmanager     
CCManager - Claude Code Worktree Manager v4.1.15

Select a worktree to start or resume a Claude Code session:

  0 ❯ master (main)  +26            3w ago
  ────────────── Other ──────────────
  N ⊕ New Worktree
  M ⇄ Merge Worktree
  D ✕ Delete Worktree
  P ⌨ Project Configuration
❯ C ⌨ Global Configuration # 选择全局配置
  Q ⏻ Exit

➜ ✗ 
Select a configuration option:

  S ⌨  Configure Shortcuts # 这里可以配置快捷键 ctrl+e 会被vscode 吞掉 需要自己设置
  H 🔧  Configure Status Hooks
  T 🔨  Configure Worktree Hooks
  W 📁  Configure Worktree Settings
❯ C 🚀  Configure Command Presets # 选择配置命令
  M 🔀  Configure Merge/Rebase
  O 🧪  Other & Experimental
  B ← Back to Main Menu

➜ ✗ 
Configure command presets for running code sessions

  Main (default)
      Command: claude
      Detection: Claude
  ─────────────────────────
  Select preset before session start: ❌ Disabled
  ─────────────────────────
❯ Add New Preset # 选择添加新的命令预设
  ← Cancel

Press ↑↓ to navigate, Enter to select, Esc to exit

➜ ✗ 
Choose the state detection strategy for this preset:

The command will be auto-set based on the strategy (can be changed later)

  Claude
  Gemini
❯ Codex # 选择codex
  Cursor Agent
  GitHub Copilot CLI
  Cline
  OpenCode
  Kimi

Press Enter to select, Esc to cancel

➜ ✗ 
Enter command (default set by strategy, can be modified):

Auto-filled from your strategy selection. You can change this if needed.

codex # 这里会默认填充codex enter确认

Press Enter to continue, Esc to cancel

➜ ✗
Enter command arguments (space-separated):

-a on-request # 这里可以配置启动参数 如果不配置可以不适用 -a on-request是模型自动判断执行命令是否需要权限

Press Enter to continue, Esc to cancel

➜ ✗ # 后面的fallback可以默认设空 present name根据需要写 写完后如下继续选择
Configure command presets for running code sessions

  Main (default)
      Command: claude
      Detection: Claude
❯ Codex
      Command: codex
      Args: -a on-request
      Detection: Codex
  ─────────────────────────
  Select preset before session start: ❌ Disabled  # 把这里设置成enabled
  ─────────────────────────
  Add New Preset
  ← Cancel

➜ ✗ # 把codex设置为默认启动项
  Name: Codex
  Command: codex
  Arguments: -a on-request
  Fallback Arguments: (none)
  Detection Strategy: Codex
  ─────────────────────────
❯ Set as Default
  Delete Preset
  ─────────────────────────
  ← Back to List

Press ↑↓ to navigate, Enter to edit/select, Esc to go back
```

### 1.2 使用

适合同一个项目的多个分支的同步开发，通过`New Worktree`新建一个工作树，`Merge Worktree`可以把当前工作树的修改合并到另一个工作树，`Delete Worktree`可以删除一个工作树。

```bash
➜ ✗ ccmanager     
CCManager - Claude Code Worktree Manager v4.1.15

Select a worktree to start or resume a Claude Code session:

  0 ❯ master (main)  +26            3w ago
  ────────────── Other ──────────────
❯ N ⊕ New Worktree # 选择新建一个工作树
  M ⇄ Merge Worktree
  D ✕ Delete Worktree
  P ⌨ Project Configuration
  C ⌨ Global Configuration 
  Q ⏻ Exit
```

## 参考链接

- [ccmanager GitHub](https://github.com/kbwo/ccmanager)
