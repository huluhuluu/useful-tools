---
title: "实用工具"
date: 2026-01-30T08:00:00+08:00
lastmod: 2026-03-26T18:00:00+08:00
draft: false
description: "开发过程中用到的一些实用小工具配置记录"
slug: "useful-tools"
tags: ["VSCode", "Copilot", "Claude Code", "iFlow", "终端工具", "环境配置"]
categories: ["实用工具"]
comments: true
math: true
---

# 实用工具

开发过程中用到的一些实用小工具配置记录。

## 目录

### 环境配置

| 文章 | 说明 | 状态 |
|------|------|------|
| [Ubuntu 环境配置](/p/ubuntu-config/) | Ubuntu 系统开发环境配置记录 | ✅ 完成 |
| [Jetson 环境配置](/p/jetson-config/) | NVIDIA Jetson 开发板环境配置记录 | ✅ 完成 |
| [Termux 环境配置](/p/termux-config/) | Android Termux 终端环境配置记录 | ✅ 完成 |
| [Python 环境配置](/p/python-env/) | Python 环境管理工具介绍与配置 | ✅ 完成 |

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
| [Netcat 局域网传输](/p/netcat/) | Netcat 网络工具在局域网文件传输中的应用 | ✅ 完成 |

### 模型下载工具

| 文章 | 说明 | 状态 |
|------|------|------|
| [HuggingFace/ModelScope 下载器](/p/model-downloader/) | HuggingFace 和 ModelScope 模型下载工具介绍 | ✅ 完成 |

---

## 工具概览

### 环境配置

#### Ubuntu

Ubuntu 开发环境配置，包括系统更新、开发工具 (Git/Python/Node.js/Docker)、GPU 环境配置等。

#### Jetson

NVIDIA Jetson 系列边缘计算开发板环境配置，包括系统安装、性能模式、CUDA/TensorRT 配置等。

#### Termux

Android 平台终端环境，可在手机上运行 Linux 环境，支持 Python/Node.js/Go 等开发环境。

#### Python 环境

Python 版本管理 (pyenv/conda) 和虚拟环境工具 (venv/virtualenv/poetry) 的使用。

### VSCode Copilot

通过配置 `remote.extensionKind` 和 `OAI Compatible Provider for Copilot` 插件，可以让 Copilot Chat 使用第三方大模型 API，如 ModelScope、DeepSeek 等。

### flash.vscode

类似 Vim 的 EasyMotion 插件，通过快捷键快速跳转到屏幕中任意可见的位置，提升编辑效率。

### Claude Code

Anthropic 官方推出的终端 Agent 框架，支持工具调用、Skills 配置，可通过 `cc-switch` 切换不同的大模型后端。

### iFlow CLI

阿里推出的终端 Agent 框架，目前提供限免的 GLM5.0、Kimi-K2.5、MiniMax-M2.5 等模型。

### 终端工具

#### Zsh

功能强大的 Unix Shell，配合 Oh My Zsh 框架可实现丰富的自动补全、语法高亮等功能。

#### reptyr

将已在运行的进程"转移"到另一个终端，适用于将后台进程重新 attach 到前台。

#### Tmux

终端复用器，支持会话持久化、窗口分割、面板管理，是远程开发的必备工具。

#### Netcat

"网络界的瑞士军刀"，支持端口扫描、文件传输、简单聊天等功能，适合局域网快速文件传输。

### 模型下载工具

#### HuggingFace/ModelScope 下载器

介绍多种模型下载方法：huggingface-cli、modelscope SDK、hf-transfer 加速、镜像站配置等。