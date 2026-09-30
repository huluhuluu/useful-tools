---
title: "fauxnix 使用备忘"
date: 2026-09-30T10:30:00+08:00
lastmod: 2026-09-30T10:30:00+08:00
draft: false
description: "在 Windows 上原生运行 Linux 风格命令，无需 WSL 和虚拟机"
slug: "fauxnix"
tags: ["tools"]
categories: ["tools"]

comments: true
math: true
---

# fauxnix 使用备忘

[fauxnix](https://github.com/20000419/fauxnix) 是一个 bash → PowerShell 的翻译层，让 Windows 能原生执行 Linux 风格命令，**不需要 WSL，也不需要虚拟机**。它的定位很明确：为 AI Agent 服务——让 Agent 继续写它最熟悉的 bash，由 fauxnix 确定性地翻译成 PowerShell 执行，再把结果按 GNU 风格返回。用 TypeScript 编写，运行时零 LLM 调用。

## 1. 它解决什么问题

LLM Agent 在 bash 上的能力远强于 PowerShell——bash 占据了绝大部分训练数据。所以在 Windows 上，模型经常会写出「看起来对、跑起来错」的命令：引号转义不对、`curl` 不是真的 curl、代码页不匹配导致乱码、以及 PowerShell 那一大堆 `CategoryInfo` 报错。

|  | fauxnix | Git Bash | WSL | 原生 PowerShell |
|---|---|---|---|---|
| Agent 写标准 bash | ✓ | ✓ | ✓ | ✗ |
| 只需 Node（无需 bash 工具链/虚拟机） | ✓ | ✗ | ✗（虚拟机，数 GB） | ✓ |
| 原生 Windows 文件系统与环境 | ✓ | 大部分 | ✗（9P 桥接） | ✓ |
| GNU 级输出，经差分验证 | ✓ 253 例 | ✓（本身就是 GNU） | ✓ | ✗ |
| CRLF / UTF-8 / GBK 陷阱处理 | ✓ | 依赖 locale | ✓ | ✗ |

需要注意：**如果 Git Bash 已经满足需求，那就继续用**。fauxnix 的差分测试本身就是拿 Git Bash 当基准的。它适用于不方便或不想装 bash 工具链的场景：Agent 集群、CI runner、受限机器，或者单纯觉得 `npm install -g` 比装一整套工具链省事。

官方给出的实测数据（同一模型、同一 5 个任务、同一台 Windows 机器）：

| | PowerShell | **fauxnix** | Git Bash |
|---|---|---|---|
| 工具调用 / 意外错误 | 14 / 9 | **7 / 0** | 4 / 0 |
| 耗时（T1–T4） | 163s | **66s** | 57s |

## 2. 安装

依赖 **Windows + PowerShell 5.1+（系统自带）和 Node.js ≥ 18**。

```bash
# 全局安装
npm install -g fauxnix-cli

# 验证
fauxnix doctor
```

`fauxnix doctor` 会检查编码、harness 配置和 MCP 往返通信是否正常。

> 注意 npm 包名是 `fauxnix-cli`，而 `fauxnix` 这个名字在 npm 上属于一个 2015 年的无关 websocket 库；安装后的命令是 `fauxnix`。

如果只想试用，可以免安装直接跑：

```bash
npx fauxnix-cli@latest "ls -la src | head -3"
npx fauxnix-cli@latest translate "find . -name '*.log' -mtime +7 -delete"
```

## 3. 基本使用

```bash
# 直接执行 bash 命令
fauxnix "ls -la src | head -2"

# 只翻译不执行，用来确认生成结果
fauxnix translate "find . -name '*.ts' | wc -l"

# 查看命令元数据
fauxnix list --json
```

输出示例：

```bash
$ fauxnix "ls -la src | head -2"
-rw-r--r-- 1 me me 1204 Aug 16 09:12 ast.ts
-rw-r--r-- 1 me me 8192 Aug 16 09:12 cli.ts

$ fauxnix "cat nope.txt"
cat: nope.txt: No such file or directory        # 而不是 PowerShell 堆栈报错
```

可以看到错误信息也是 bash 风格的，而不是 PowerShell 的异常堆栈。

## 4. 接入 AI Agent

官方提供一条命令接入主流 Agent 框架，**幂等**，并且会打印具体改动了什么：

```bash
fauxnix install --claude     # 或 --codex / --opencode / --kimi / --qwen
fauxnix doctor               # 验证编码、配置和 MCP 往返
```

如果想自己改配置文件，手动配置如下。

### 4.1 Claude Code

```bash
claude mcp add fauxnix -- fauxnix mcp
```

### 4.2 Codex

写入 `~/.codex/config.toml`，或执行 `codex mcp add fauxnix -- fauxnix mcp`：

```toml
[mcp_servers.fauxnix]
command = "fauxnix"
args = ["mcp"]
```

注意：在非交互的 `codex exec` 模式下，MCP 工具调用会被审批层自动拒绝，需要加 `--dangerously-bypass-approvals-and-sandbox`，或者交互式运行并手动批准一次。

### 4.3 OpenCode

在 `opencode.json` 中：

```json
{
  "mcp": {
    "fauxnix": { "type": "local", "command": ["fauxnix", "mcp"] }
  }
}
```

### 4.4 Kimi Code

MCP 配置在独立的 JSON 文件里，不是 TOML 配置。写入 `~/.kimi-code/mcp.json`：

```json
{
  "mcpServers": {
    "fauxnix": { "command": "fauxnix", "args": ["mcp"] }
  }
}
```

### 4.5 Qwen Code

```bash
fauxnix install --qwen
```

安装器会保留 `settings.json` 的其余内容，并写入一个绝对路径的 Node + 包入口启动器，这样 Qwen 启动时不依赖工作目录或 `PATH` 顺序。

### 4.6 任意 MCP 客户端

stdio server 形式：`fauxnix mcp`。工具名是 `bash`（可用 `FAUXNIX_TOOL_NAME` 覆盖）。工具描述里已经说明了支持的子集，因此不需要改 system prompt。

MCP 会话会持久化 `cwd`、环境变量、`export`/`unset`、`cd -`/OLDPWD 以及位置参数（`set --` / `$1` / `"$@"`），行为像一个已登录的 shell，而不是无状态的 `exec`。

### 4.7 批量执行 bash_batch

对于命令已经确定的流程，MCP server 还提供 `bash_batch`：它会在执行前编译所有步骤，在一个会话中原子性地运行整个计划，并在一次 MCP 往返中返回每步的结构化结果（默认遇到第一个非零退出码就停止）。

```json
{
  "steps": [
    { "id": "write", "command": "printf 'a\\r\\nb' > data.txt" },
    { "id": "measure", "command": "wc -c data.txt" }
  ]
}
```

## 5. 支持的命令范围

共 **109 个命令**，开发期间在 Windows 上以 Git Bash 的真实 GNU coreutils 为基准做了输出比对：

- **文件**：`ls cp mv rm mkdir rmdir touch mktemp ln readlink realpath basename dirname stat file du df find chmod chown diff`
- **文本过滤**：`grep egrep sed awk sort uniq cut tr`
- **文本 I/O**：`echo printf cat head tail wc tee nl tac md5sum sha1sum sha256sum base64 seq yes xargs`
- **shell/系统**：`cd pwd export unset env printenv ps kill pkill pgrep sleep which type whoami id groups date uname hostname uptime free nproc clear true false test [ [[ : pushd popd dirs sudo timeout man history less more source . eval exit alias set shift`
- **网络**：`curl wget ping netstat ss ip ifconfig nslookup dig host`
- **压缩包**：`tar gzip gunzip zcat zip unzip`

其中精选的 **agent-daily 60** 带有 `CommandSpec`：未知选项会以 GNU 风格的 usage 错误失败，而不是被静默忽略。`sed`/`awk` 脚本在生成可执行计划时会被解析，不支持的构造会抛出具名错误，不会静默地错误执行。

另外还支持这些 shell 语法：管道、`&&` / `||` / `;`、重定向（`> >> 2> 2>&1 < &>`、`/dev/null`）、引号、`$VAR` `$1` `$#` `"$@"` `set --` `shift`、`${name:-word}` `${name//pat/str}` `${name:off:len}`、`A=(x y z)` 数组赋值、`$(...)` 命令替换、`VAR=x cmd` 前缀、`~` 展开，以及 POSIX 风格路径规范化（`/tmp`、`/d/foo` → `D:\foo`）。

退出码遵循 bash 约定：0 成功，1 失败，2 用法错误，127 命令未找到，124 超时。

未识别的命令（`git`、`node`、`npm`、`python`、`cargo`、`gh`、`docker` 等）会以 argv 风格引号**原生透传**执行。

## 6. 工作原理

```
bash command ──parser──▶ AST ──translator──▶ PowerShell script ──executor──▶ 选定的 PowerShell
                                                                              │
agent ◀── GNU 风格输出、bash 风格错误 ◀── UTF-8 帧协议 ◀──────────────────────┘
```

- 运行时**确定性翻译，零 LLM 调用**。
- 每个命令映射到一个生成器，输出自包含的 PowerShell 代码块，遵循 "Fauxnix contract"。
- executor 在每个脚本外层做 UTF-8 强制，在进程边界按 UTF-8（或 `ansi` 模式下的 GBK(936)）解码原生输出，剥离 CLIXML 序列化和 PowerShell 噪声，并把常见的 PowerShell 报错（包括 zh-CN 本地化消息）改写成 bash 措辞。
- 脚本通过 `-EncodedCommand`（UTF-16LE）运行，超出 32 KB 命令行限制时自动回退到临时 `.ps1` 文件。

PowerShell 7 是可选且经过 CI 测试的层级，启动 fauxnix 或其 MCP harness 前设置环境变量即可：

```powershell
$env:FAUXNIX_PS = 'pwsh'
```

默认使用 Windows PowerShell 5.1，非法值会直接报错而不是静默回退。

## 7. 已知偏差（官方诚实清单）

fauxnix 优先保证 Agent 实际会用的命令正确，以下是明确记录的偏差：

- `X=1` 这种独立赋值遵循 `export` 语义（整个会话共用一个环境），bash 中 shell 变量与导出变量的区别在这里不存在。
- `yes` 上限为 65536 行——PS 5.1 管道无法通知上游生产者停止，否则 `yes | head` 会挂死。
- `tail -f`、`eval`、`alias`、heredoc、`env -i`、后台 `&`，以及非管道末尾阶段的输出/fd 重定向，都会被拒绝并给出具体的可操作错误信息，而不是错误执行。
- `chmod` 只映射只读位，执行位在 Windows 上是空操作；`chown` 是静默空操作（与 Git Bash 一致）。
- `ps aux` 的列是近似值（没有逐进程 CPU% 统计，USER 显示 `?`）。
- `gzip -c`/管道 stdin 是文本保真的，不是字节保真的；文件模式的 `gzip f` 是字节精确的。
- `curl`/`wget` 会拒绝回环/私有/保留地址（localhost、127.x、::1、10.x、172.16–31.x、192.168.x、169.254.x），这是面向 Agent 驱动 HTTP 的默认安全策略。
- **原生工具管道与编码**：PS 5.1 只有一个控制台编码开关，所以本地化的管理工具（ipconfig、tasklist，zh-CN 下是 GBK）和 UTF-8 原生的开发工具（node、curl）无法在管道中同时正确解码。默认偏向 UTF-8 开发工具；当你需要 Agent grep 原生 Windows 管理工具的中文输出时，设置 `FAUXNIX_NATIVE_ENCODING=ansi`。

## 8. 注意事项

- 仅支持 Windows 平台，需要 PowerShell 5.1+ 与 Node.js ≥ 18。
- 网络类命令有回环/私有地址防护，本地调试服务时要注意这一默认行为。
- `sed`/`awk` 只支持常见子集，hold space、标签、数组、循环会在翻译期抛出 "not supported" 错误。
- 中文输出场景下如果遇到乱码，优先考虑 `FAUXNIX_NATIVE_ENCODING=ansi` 与 `FAUXNIX_PS` 这两个环境变量。

---

## 参考链接

- [fauxnix GitHub](https://github.com/20000419/fauxnix)
- [fauxnix npm](https://www.npmjs.com/package/fauxnix-cli)
- [命令规格列表](https://github.com/20000419/fauxnix/blob/main/docs/command-specs.md)
- [PowerShell 7 支持](https://github.com/20000419/fauxnix/blob/main/docs/powershell-7.md)
- [安全模型](https://github.com/20000419/fauxnix/blob/main/SECURITY.md)
