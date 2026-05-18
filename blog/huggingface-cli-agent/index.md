---
title: "Hugging Face CLI 与 Codex Agent 使用备忘"
date: 2026-05-17T11:38:00+08:00
lastmod: 2026-05-18T11:38:00+08:00
draft: false
description: "Hugging Face hf CLI 的安装、认证、下载上传，以及在 Codex 中通过 Skill 调用的使用记录"
slug: "huggingface-cli-agent"
tags: ["tools", "huggingface", "agent"]
categories: ["tools"]

comments: true
math: true
---

# Hugging Face CLI 与 Codex Agent 使用备忘

本地管理 Hugging Face Hub 上的模型、数据集和 Space 时，`hf` CLI 比在 Python 代码里临时写下载、上传逻辑更直接,包括两类用法：

- 手动在终端里使用 `hf-cli` 进行认证、下载、上传等操作
- 给 Codex 安装 Hugging Face CLI Skill，让 Agent 能按当前机器上的 `hf` 版本调用命令

## 1. 安装

### 1.1 独立安装

Hugging Face 官方现在提供独立安装脚本，安装后会得到 `hf` 命令。

Windows PowerShell：

```powershell
# 安装 hf CLI
powershell -ExecutionPolicy ByPass -c "irm https://hf.co/cli/install.ps1 | iex"

# 验证安装
hf --help
hf version
```

Linux/macOS：

```bash
# 安装 hf CLI
curl -LsSf https://hf.co/cli/install.sh | bash

# 验证安装
hf --help
hf version
```

或者直接在 Python 环境中使用,无需安装：

```bash
# 使用 pip
pip install -U "huggingface_hub[cli]"

# 使用 uv
uv tool install "huggingface_hub[cli]"
```

临时执行一次命令时，可以用 `uvx`，不用把工具长期安装到当前环境：

```bash
uvx hf auth whoami
```

## 2. 认证

下载公开模型通常不需要登录。访问 gated model、私有仓库、上传文件时，需要登录 Hugging Face 账号。

```bash
# 交互式登录，会提示输入 token, token在 `Hugging Face` -> `Settings` -> `Access Tokens` 里创建, 
# 这个token需要有 `read` 权限才能下载，有 `write` 权限才能上传，
# 并且token只在创建时能看到一次，要妥善保管。
hf auth login

# 查看当前登录账号
hf auth whoami

# 登出
hf auth logout
```

在 CI 或服务器上使用时，也可以把 token 放到环境变量里，再让 `hf` 读取：

```bash
export HF_TOKEN="hf_xxx"
hf auth login --token "$HF_TOKEN" --add-to-git-credential
```

`--add-to-git-credential` 会把 token 写入 Git credential store，后续用 `git lfs` 访问 Hugging Face 仓库会更顺手。共享机器上需要注意凭据清理。

## 3. 下载模型和数据集

### 3.1 下载完整仓库

```bash
# 下载模型仓库到默认缓存目录
hf download Qwen/Qwen3-8B

# 下载到指定目录，方便后续从本地路径加载
hf download Qwen/Qwen3-8B --local-dir ./Qwen3-8B
```

`hf download` 默认使用 Hugging Face Hub 缓存。指定 `--local-dir` 后，文件会落到当前项目目录，适合部署脚本或离线机器复用。

### 3.2 只下载部分文件

```bash
# 只下载 config 和 tokenizer
hf download Qwen/Qwen3-8B config.json tokenizer.json --local-dir ./Qwen3-8B

# 只下载 safetensors 权重
hf download Qwen/Qwen3-8B --include "*.safetensors" --local-dir ./Qwen3-8B

# 排除不需要的文件
hf download Qwen/Qwen3-8B --exclude "*.msgpack" "*.h5" --local-dir ./Qwen3-8B
```

只需要检查模型结构时，先拉 `config.json`、`tokenizer.json`、`generation_config.json` 就够了；真正部署再拉权重文件。

### 3.3 下载数据集或 Space

模型仓库可以省略 `--repo-type`，数据集和 Space 需要显式指定：

```bash
# 下载数据集
hf download Salesforce/wikitext --repo-type dataset --local-dir ./wikitext

# 下载 Space
hf download HuggingFaceH4/open_llm_leaderboard --repo-type space --local-dir ./open_llm_leaderboard
```

## 4. 上传和仓库管理

### 4.1 创建仓库

```bash
# 创建公开模型仓库
hf repos create huluhuluu/demo-model --exist-ok

# 创建私有模型仓库
hf repos create huluhuluu/demo-model-private --private --exist-ok

# 创建数据集仓库
hf repos create huluhuluu/demo-dataset --repo-type dataset --exist-ok
```

`--exist-ok` 适合写进脚本，仓库已存在时不会直接失败。

### 4.2 上传文件

```bash
# 上传当前目录到模型仓库根目录
hf upload huluhuluu/demo-model . . --commit-message "upload model files"

# 上传单个文件
hf upload huluhuluu/demo-model ./README.md README.md

# 上传数据集目录
hf upload huluhuluu/demo-dataset ./data . --repo-type dataset --commit-message "upload dataset files"
```

大目录、大量文件或经常断点续传的场景，使用 `upload-large-folder`：

```bash
hf upload-large-folder huluhuluu/demo-model ./Qwen3-8B
```

### 4.3 上传无法直连

国内网络环境下，下载可以通过镜像站解决，但上传需要写入 Hugging Face Hub 官方仓库。代理能解决连通性问题，但大模型上传会消耗大量代理流量，所以更推荐的做法是：

- 小文件用代理验证账号、仓库权限和命令参数
- 大文件放到海外服务器、GitHub Actions、Colab 或其它能稳定访问 Hugging Face 的环境上传

不要把 `HF_ENDPOINT` 指到只支持下载的镜像站后再上传，这类镜像通常不负责写入官方 Hub。

先用小文件验证认证和网络，再上传大文件：

Windows PowerShell：

```powershell
# 按实际代理端口修改，例如 Clash 常见为 7890
$env:HTTPS_PROXY = "http://127.0.0.1:7890"
$env:HTTP_PROXY = "http://127.0.0.1:7890"

# 先确认 token 和网络可用
hf auth whoami

# 用 README.md 做一次小文件上传测试
hf upload huluhuluu/demo-model ./README.md README.md --commit-message "test upload via proxy"
```

Linux/macOS：

```bash
# 按实际代理端口修改
export HTTPS_PROXY="http://127.0.0.1:7890"
export HTTP_PROXY="http://127.0.0.1:7890"

# 先确认 token 和网络可用
hf auth whoami

# 用 README.md 做一次小文件上传测试
hf upload huluhuluu/demo-model ./README.md README.md --commit-message "test upload via proxy"
```

网络不稳定时，大目录不要反复用普通 `hf upload` 从头提交，直接使用可恢复的大目录上传，并适当降低并发。这个方案适合远端机器，不建议在本地长期挂代理跑大文件上传：

```bash
hf upload-large-folder huluhuluu/demo-model ./Qwen3-8B --repo-type model --num-workers 2
```

推荐的远端上传流程是：

```bash
# 1. 在本地把待上传目录同步到远端机器
rsync -avP ./Qwen3-8B user@<server-ip>:~/uploads/Qwen3-8B

# 2. 在远端机器登录 Hugging Face
hf auth login

# 3. 在远端机器上传到 Hugging Face Hub
hf upload-large-folder huluhuluu/demo-model ~/uploads/Qwen3-8B --repo-type model --num-workers 2
```

这样仍然会消耗本地到远端机器的上传带宽，但不会消耗代理订阅流量；真正到 Hugging Face 的大流量发生在远端机器和 Hugging Face 之间。

## 5. Codex + Skill 模式

Hugging Face 提供了面向 Agent 的 `hf skills` 命令。它会根据本机当前安装的 `hf` CLI 版本生成 Skill，让 Codex 这类 Agent 知道应该如何调用 `hf`。

### 5.1 全局安装

```bash
# 安装到全局 Agent skills 目录
hf skills add --global

# 预览将要写入的 Skill 内容
hf skills preview
```

全局安装适合日常开发机，后续在不同项目里打开 Codex 都能使用。

### 5.2 项目内安装

```bash
# 在当前项目写入 .agents/skills
hf skills add
```

项目内安装适合团队仓库或可复现实验环境。Skill 跟着项目走，别人 clone 仓库后能看到相同的 Agent 使用说明。

### 5.3 更新 Skill

`hf` CLI 升级后，重新生成 Skill，避免 Agent 继续使用旧命令说明。

```bash
# 更新全局 Skill
hf skills upgrade --global

# 更新当前项目 Skill
hf skills upgrade
```

### 5.4 在 Codex 中使用

安装完成后，进入需要操作的目录启动 Codex：

```bash
codex
```

可以直接给 Codex 下达和 Hugging Face 相关的任务，例如：

```text
用 hf CLI 下载 Qwen/Qwen3-8B 的 config.json 和 tokenizer.json 到 ./Qwen3-8B
```

或：

```text
检查当前目录，创建 huluhuluu/demo-model 仓库并上传 README.md，不要上传权重文件
```

Agent 执行上传、删除、创建仓库这类会改远端状态的操作前，需要先确认目标仓库名、`repo-type` 和 token 权限。

## 6. 常见命令

| 命令 | 说明 |
|------|------|
| `hf auth login` | 登录 Hugging Face 账号 |
| `hf auth whoami` | 查看当前登录身份 |
| `hf download <repo_id>` | 下载模型仓库 |
| `hf download <repo_id> --repo-type dataset` | 下载数据集仓库 |
| `hf upload <repo_id> <local_path> <path_in_repo>` | 上传文件或目录 |
| `hf upload-large-folder <repo_id> <folder_path>` | 上传大目录 |
| `HTTPS_PROXY=http://127.0.0.1:7890 hf upload ...` | 通过代理上传 |
| `hf repos create <repo_id>` | 创建仓库 |
| `hf cache ls` | 查看本地 Hub 缓存 |
| `hf cache prune` | 清理未引用的缓存 |
| `hf skills add --global` | 给 Codex 等 Agent 安装全局 Skill |
| `hf skills upgrade --global` | 升级全局 Skill |

## 7. 其它补充

- 国内网络环境下，直连 Hugging Face 可能较慢。只做模型下载时，可以继续使用已有的 `hf-mirror` 或 `hfd.sh` 方案。
- `hf upload` 会真实提交到远端仓库。脚本里先用小文件测试，再上传大模型权重。
- gated model 需要先在网页端申请访问权限，即使本地已经 `hf auth login`，没有权限也会下载失败。
- 私有仓库和组织仓库上传失败时，优先检查 token 的 `write` 权限、组织权限、`repo-type` 是否写对。

---

## 参考链接

- [Hugging Face Hub CLI 文档](https://huggingface.co/docs/huggingface_hub/guides/cli)
- [Upload files to the Hub](https://huggingface.co/docs/huggingface_hub/guides/upload)
- [Hugging Face CLI for Agents](https://huggingface.co/docs/hub/agents-cli)
- [huggingface_hub CLI Reference](https://huggingface.co/docs/huggingface_hub/package_reference/cli)
