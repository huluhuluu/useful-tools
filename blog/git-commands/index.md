---
title: "Git 命令备忘"
date: 2026-03-27T23:00:00+08:00
lastmod: 2026-03-27T23:00:00+08:00
draft: false
description: "Git 常用命令速查"
slug: "git-commands"
tags: ["tools"]
categories: ["tools"]

comments: true
math: true
---

# Git 命令备忘

Git 日常开发中常用的命令速查，包括分支管理、合并、暂存、版本回退等场景。
- 保存`git`凭证： ```git config --global credential.helper store```
## 1. 分支管理

### 1.1 查看分支

```bash
git branch              # 查看本地分支
git branch -a           # 查看所有分支（含远程）
git branch -r           # 只查看远程分支
```

### 1.2 创建/切换分支

```bash
git branch feature-x    # 创建分支
git checkout feature-x  # 切换分支
git checkout -b feature-x    # 创建并切换（简写）
git switch feature-x    # 切换分支（新语法）
git switch -c feature-x # 创建并切换（新语法）
```

### 1.3 删除分支

```bash
git branch -d feature-x     # 删除已合并的分支
git branch -D feature-x     # 强制删除（未合并也删）
git push origin --delete feature-x  # 删除远程分支
```

### 1.4 重命名分支

```bash
git branch -m old-name new-name  # 重命名当前分支
git branch -m new-name           # 重命名当前分支
```

## 2. 合并与变基

### 2.1 merge

```bash
git merge feature-x    # 合并指定分支到当前分支
git merge --abort      # 取消合并（冲突时）
```

### 2.2 rebase

```bash
git rebase main        # 将当前分支变基到 main
git rebase -i HEAD~3   # 交互式变基最近 3 个提交（把最近三个提交变成一个）
git rebase --abort     # 取消变基
git rebase --continue  # 解决冲突后继续
```

**注意**：不要对已推送到远程的提交执行 rebase，会导致历史混乱。

### merge vs rebase
merge 和 rebase 的主要区别是：rebase 会将 feature 分支的提交历史重写，而 merge 不会。
操作前
```bash
      A---B---C  (feature 分支)
     /
D---E---F---G    (main 分支)
```
merge后
```bash
      A---B---C
     /         \
D---E---F---G---M  (M 是新的合并提交)
```
rebase后
```bash
              A'--B'--C' (feature 分支，提交哈希变了)
             /
D---E---F---G            (main 分支)
```

## 3. 暂存工作区

适用场景：正在开发中，临时需要切换分支处理其他事情。

```bash
git stash              # 暂存当前修改
git stash save "描述"   # 暂存并添加描述
git stash list         # 查看暂存列表
git stash pop          # 恢复最近一次暂存并删除记录
git stash apply        # 恢复最近一次暂存（保留记录）
git stash apply stash@{2}  # 恢复指定暂存
git stash drop stash@{0}   # 删除指定暂存
git stash clear        # 清空所有暂存
```

## 4. 版本回退与恢复

### 4.1 查看历史

```bash
git log --oneline      # 简洁查看提交历史
git log --oneline -10  # 最近 10 条
git log --oneline --graph  # 带分支图
git reflog             # 查看所有操作记录（含已删除的提交）
```

### 4.2 回退版本

```bash
git reset --soft commit-hash    # 回退到指定提交，保留修改在暂存区
git reset --mixed commit-hash   # 回退到指定提交，保留修改在工作区（默认）
git reset --hard commit-hash    # 回退到指定提交，丢弃所有修改（危险）
```

### 4.3 从某个版本恢复文件

```bash
# 从指定提交恢复某个文件
git checkout commit-hash -- path/to/file
```

### 4.4 撤销某次提交

```bash
git revert commit-hash   # 创建新提交来撤销指定提交（不改变历史）
git revert -n commit-hash  # 撤销但不自动提交
```

**reset vs revert**：
- `reset`：回退历史，适合未推送的提交
- `revert`：新增一个撤销提交，适合已推送的提交

## 5. 远程操作

```bash
git remote -v                    # 查看远程仓库
git remote add origin <url>      # 添加远程仓库
git fetch origin                 # 获取远程更新（不合并）
git pull origin main             # 拉取并合并
git push origin main             # 推送到远程
git push -u origin feature-x     # 推送并设置上游分支
git push -f origin main          # 强制推送（危险）
```

## 6. 子模块

```bash
git submodule add <url> path/to/submodule  # 添加子模块
git submodule update --init --recursive    # 初始化并拉取子模块
git submodule update --remote              # 更新子模块到最新
git submodule foreach git pull origin main # 批量更新所有子模块
```

## 7. 其他常用

```bash
git status             # 查看状态
git diff               # 查看未暂存的修改
git diff --staged      # 查看已暂存的修改
git diff commit-hash   # 与指定版本对比

git cherry-pick commit-hash  # 将指定提交应用到当前分支
git blame path/to/file       # 查看文件每行的修改记录

# 只提交部分文件
git add -p             # 交互式选择部分修改暂存
```

## 8. 常见`git commit`备注
| 类型 | 含义 | 示例 |
| :--- | :--- | :--- |
| `feat` | 新功能 (Feature) | `feat: add user login module` |
| `fix` | 修复 Bug | `fix: resolve null pointer exception` |
| `docs` | 文档变更 | `docs: update API README` |
| `style` | 代码格式 (不影响逻辑) | `style: remove trailing whitespaces` |
| `refactor` | 重构 (既非新功能也非修bug) | `refactor: simplify database connection logic` |
| `perf` | 性能优化 | `perf: improve image loading speed` |
| `test` | 测试相关 | `test: add unit tests for payment` |
| `chore` | 构建/辅助工具变动 | `chore: update dependencies` |
| `ci` | CI/CD 配置变更 | `ci: update GitHub Actions workflow` |

---

## 参考链接

- [Git 官方文档](https://git-scm.com/doc)
- [Pro Git 电子书](https://git-scm.com/book/zh/v2)

