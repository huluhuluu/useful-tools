---
title: "Codex CLI 第三方 API 配置备忘"
date: 2026-03-29T11:00:00+08:00
lastmod: 2026-03-29T11:00:00+08:00
draft: false
description: "OpenAI Codex CLI 配置第三方 API 端点记录"
slug: "codex-cli-config"
tags: ["tools"]
categories: ["tools"]

comments: true
math: true
---

# Codex CLI 第三方 API 配置备忘

[Codex CLI](https://github.com/openai/codex) 是 OpenAI 官方推出的终端 AI Agent 工具，支持代码生成、文件操作等。本文记录如何配置第三方 api。

## 1. 安装

```bash
# 使用 npm 安装
npm install -g @openai/codex

# 验证安装
codex --version
# codex-cli 0.117.0 # 输出版本 安装成功
```

## 2. 配置第三方 API
下面使用windows的[cc-switch-cli](https://github.com/SaladDay/cc-switch-cli/releases)作为示例，演示如何配置第三方 API 端点。
```pwsh
# 1. 创建临时目录并下载最新版
$downloadUrl = "https://github.com/SaladDay/cc-switch-cli/releases/latest/download/cc-switch-cli-windows-x64.zip"
$zipPath = "$env:TEMP\cc-switch-cli.zip"
$extractPath = "$env:TEMP\cc-switch-extract"
Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath

# 2. 解压
Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force

# 3. 移动到用户 PATH 目录（无需管理员权限）
$binPath = "$env:LOCALAPPDATA\Microsoft\WindowsApps"
if (!(Test-Path $binPath)) { New-Item -ItemType Directory -Path $binPath -Force }
Copy-Item "$extractPath\cc-switch.exe" -Destination $binPath -Force

# 4. 验证安装
cc-switch --version
# cc-switch 5.2.1 # 输出版本 安装成功
```

### 2.1 设置 API Key
参考[文档](https://github.com/SaladDay/cc-switch-cli) (有[中文版](https://github.com/SaladDay/cc-switch-cli/blob/main/README_ZH.md))，输入对应的模型提供商、URL、模型 ID、接口令牌等信息。**部分自己搭建的第三方api的`base_url`需要加`/v1`，不然请求可能会自动路由到`/login`的返回界面**

```bash
➜  cc-switch --app codex provider add # 添加新供应商 这里需指定app为codex
Add New Provider
==================================================
> Select provider type: Add Third-Party Provider
> Provider Name: example
> Website URL (opt.):
Generated ID: example

Configure Codex Provider:
> OpenAI API Key: sk-abababababababababababababab
> Base URL: http://example.com/v1
> Model: gpt-5.3-codex
> Configure optional fields (notes,  sort index)? No

=== Provider Configuration Summary ===
ID: example
Provider Name:: example

Core Configuration:
  API Key: sk-b...ecdf
  Config (TOML): 10 lines
======================
>
Confirm create this provider? Yes

✓ Successfully added provider 'example' 

# 再查看就有了
➜  cc-switch provider list --app codex # 同样指定codex                                    
┌───┬──────────┬──────────┬────────────────────────────────────┐
│   ┆ ID       ┆ Name     ┆ API URL                            │
╞═══╪══════════╪══════════╪════════════════════════════════════╡
│ ✓ ┆ example  ┆ example  ┆ http://example.com/v1              │
└───┴──────────┴──────────┴────────────────────────────────────┘

ℹ Application: codex
→ Current: example # 当前使用的 example

# 在打开 codex 就可以使用了
➜ codex
```
### 2.2 启动
```bash
# 启动交互模式
codex
```
第一次启动需要选择运行模式，建议使用沙盒模式`Set up default sandbox`，隔离环境更安全。
![选择沙盒模式](./png/sandbox-mode.png)

### 2.3 基本使用

```bash
# 启动交互模式
codex

# 指定模型
codex --model gpt-4o

# 执行单条命令
codex "创建一个 Python 脚本读取 JSON 文件"

# 非交互模式（自动执行）
codex --full-auto "帮我重构这个函数"
```

---

## 参考链接

- [Codex CLI GitHub](https://github.com/openai/codex)
- [OpenAI API 文档](https://platform.openai.com/docs)

