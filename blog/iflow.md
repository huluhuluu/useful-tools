---
title: "iFlow CLI 配置指南"
date: 2026-01-30T08:00:00+08:00
lastmod: 2026-02-26T18:00:00+08:00
draft: false
description: "阿里推出的终端 Agent 框架配置记录"
slug: "iflow-cli"
tags: ["iFlow", "Agent", "大模型"]
categories: ["实用工具"]
comments: true
---

# iFlow CLI 配置指南

[iFlow](https://platform.iflow.cn/) 是阿里推出的一个在终端中运行的 Agent 框架，可以接入多种大模型 API，目前提供限免的 GLM5.0、Kimi-K2.5、MiniMax-M2.5 等模型。

下面以 Windows 为例，配置记录如下：

## 1. 安装 NodeJS

安装 [NodeJS](https://nodejs.org/en/download)，选择对应系统与指令集的预编译安装包，下载后双击，同意协议并安装。

![安装NodeJS](/png/iflow/install-nodejs.png)

## 2. 安装 iFlow

打开 PowerShell 安装 iFlow：

```powershell
npm install -g @iflow-ai/iflow-cli@latest
iflow --version # 有输出验证安装成功
```

## 3. 登录配置

打开 PowerShell，启动 iFlow 后进入登录界面：

```powershell
iflow
```

共有三个登录方式：

1. **打开网页授权**
2. **使用 API Key**：需要在[心流 API 平台](https://platform.iflow.cn/profile?tab=apiKey)设置，这个 Key 每周会刷新，过期后可以通过 `/auth` 命令刷新
3. **使用 OpenAI 兼容的第三方 API**

![登录界面](/png/iflow/login-page.png)

配置好 Key 后，可以选择使用的模型：

![选择模型](/png/iflow/choose-model.png)

## 4. 常用命令

| 命令 | 说明 |
|------|------|
| `/resume` | 恢复之前的对话，继续之前的上下文 |
| `/clear` | 清除之前的对话上下文，重新开始 |
| `/compress` | 压缩之前的对话上下文，保留关键信息，释放上下文空间 |
| `/init` | 初始化一个新的对话，会在目录下生成 AGENTS.md 文件，记录初始化信息 |
