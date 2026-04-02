---
title: "Linux 常用命令备忘"
date: 2026-03-27T23:30:00+08:00
lastmod: 2026-03-27T23:30:00+08:00
draft: false
description: "Linux 日常开发常用命令速查"
slug: "linux-commands"
tags: ["tools"]
categories: ["tools"]

comments: true
math: true
---

# Linux 常用命令备忘

Linux 日常开发中常用的命令速查，包括磁盘管理、进程管理、文件操作、网络工具等。

## 1. 磁盘与文件大小

### 1.1 du - 查看目录/文件大小

```bash
du -sh *              # 查看当前目录下各文件/文件夹大小（人类可读）
du -sh /path/to/dir   # 查看指定目录大小
du -h --max-depth=1   # 只显示一级子目录大小
du -sh * | sort -rh   # 按大小排序（从大到小）
du -sh * | sort -rh | head -10  # 显示最大的 10 个文件/目录
```

### 1.2 df - 查看磁盘空间

```bash
df -h                 # 查看所有磁盘分区使用情况
df -h /home           # 查看指定目录所在分区
df -i                 # 查看 inode 使用情况（小文件过多时有用）
```

## 2. 进程管理

### 2.1 查看进程

```bash
ps aux                # 查看所有进程
ps aux | grep python  # 查找指定进程

top                   # 实时进程监控
htop                  # 更友好的实时监控（需安装）
```

### 2.2 pkill - 按名称杀进程

```bash
pkill python          # 杀死所有 python 进程
pkill -f "python script.py"  # 匹配完整命令
pkill -9 python       # 强制杀死
pkill -u user python  # 杀死指定用户的进程
```

### 2.3 killall - 按名称杀进程

```bash
killall nginx         # 杀死所有 nginx 进程
killall -9 nginx      # 强制杀死
killall -i nginx      # 交互式确认
```

### 2.4 kill - 按 PID 杀进程

```bash
kill 1234             # 发送 SIGTERM (15)
kill -9 1234          # 发送 SIGKILL (强制)
kill -l               # 查看所有信号
```

### 2.5 查找进程 PID

```bash
pgrep python          # 返回 python 进程的 PID
pgrep -l python       # 同时显示进程名
pgrep -a python       # 显示完整命令
pidof nginx           # 返回 nginx 的 PID
```

## 3. 文件操作

### 3.1 find - 查找文件

```bash
find /home -name "*.py"        # 按文件名查找
find . -type d -name "test"    # 查找目录
find . -type f -size +100M     # 查找大于 100M 的文件
find . -mtime -7               # 查找 7 天内修改的文件
find . -mtime +30              # 查找 30 天前修改的文件
find . -name "*.log" -delete   # 查找并删除
```

### 3.2 ln - 软链接/硬链接

```bash
ln -s /path/to/target /path/to/link  # 创建软链接
ln /path/to/file /path/to/hardlink   # 创建硬链接
ls -l /path/to/link                  # 查看链接指向
readlink /path/to/link               # 查看链接目标
unlink /path/to/link                 # 删除链接
# 软链接类似快捷方式， 硬链接类似别名
```

### 3.3 tar - 压缩解压

```bash
# 压缩
tar -czvf archive.tar.gz /path/to/dir   # 压缩为 .tar.gz
tar -cjvf archive.tar.bz2 /path/to/dir  # 压缩为 .tar.bz2

# 解压
tar -xzvf archive.tar.gz                # 解压 .tar.gz
tar -xjvf archive.tar.bz2               # 解压 .tar.bz2
tar -xzvf archive.tar.gz -C /target/dir # 解压到指定目录

# 参数说明: c-创建,  x-解压,  z-gzip,  j-bzip2,  v-显示过程,  f-指定文件
```

## 4. 网络工具

### 4.1 端口与连接

```bash
# 查看端口占用
netstat -tlnp          # 查看监听的 TCP 端口
netstat -tunlp         # TCP + UDP
ss -tlnp               # 更现代的替代品
lsof -i :8080          # 查看占用 8080 端口的进程

# 查看连接
netstat -an | grep ESTABLISHED  # 查看已建立的连接
ss -s                  # 连接统计
```

### 4.2 网络诊断

```bash
ping baidu.com         # 测试连通性
ping -c 4 baidu.com    # 只 ping 4 次

traceroute baidu.com   # 追踪路由
mtr baidu.com          # 实时路由追踪（更好用）

curl -I https://baidu.com    # 只获取响应头
curl -v https://baidu.com    # 显示详细信息
curl -o file.html https://example.com  # 保存到文件

wget https://example.com/file.zip   # 下载文件
wget -c https://example.com/file.zip  # 断点续传
```

### 4.3 防火墙 (ufw)

```bash
sudo ufw status        # 查看状态
sudo ufw enable        # 启用
sudo ufw allow 22      # 允许 22 端口
sudo ufw allow 8080/tcp
sudo ufw deny 3306     # 禁止 3306 端口
sudo ufw delete allow 22  # 删除规则
```

## 5. 系统信息

### 5.1 硬件信息

```bash
# CPU
lscpu                  # CPU 信息
nproc                  # CPU 核心数
cat /proc/cpuinfo      # 详细 CPU 信息

# 内存
free -h                # 内存使用情况
cat /proc/meminfo      # 详细内存信息

# GPU
nvidia-smi             # NVIDIA GPU 信息
watch -n 1 nvidia-smi  # 每秒刷新
nvtop                  # NVIDIA GPU 监控

# 磁盘
lsblk                  # 列出块设备
fdisk -l               # 磁盘分区信息
```

### 5.2 系统信息

```bash
uname -a               # 内核信息
cat /etc/os-release    # 系统版本
hostname               # 主机名
uptime                 # 运行时间
whoami                 # 当前用户
id                     # 用户 ID 信息
```

## 6. 用户与权限

### 6.1 用户管理

```bash
who                    # 查看登录用户
w                      # 查看登录用户及其活动
last                   # 查看登录历史

id username            # 查看指定用户信息
groups username        # 查看用户所属组
cat /etc/group         # 查看所有组信息
adduser username       # 添加用户
userdel username       # 删除用户
usermod -aG sudo user  # 将用户加入 sudo 组
passwd username        # 修改密码
```

### 6.2 权限管理

```bash
chmod 755 file         # 修改权限（数字）
chmod +x script.sh     # 添加执行权限
chmod -R 755 dir/      # 递归修改目录权限

chown user:group file  # 修改所有者
chown -R user:group dir/  # 递归修改

# 权限数字: 7=rwx,  6=rw-,  5=r-x,  4=r--,  0=---
```

## 7. 文本处理

### 7.1 grep - 文本搜索

```bash
grep "pattern" file    # 搜索文本
grep -r "pattern" dir/ # 递归搜索
grep -i "pattern" file # 忽略大小写
grep -n "pattern" file # 显示行号
grep -E "p1|p2" file   # 正则表达式
grep -c "pattern" file # 统计匹配行数
```

## 8. 其他常用

### 8.1 定时任务

```bash
crontab -l                   # 查看定时任务
crontab -e                   # 编辑定时任务
# 格式: 分 时 日 月 周 命令
# 0 2 * * * /path/to/backup.sh  # 每天凌晨 2 点执行
```

### 8.2 环境变量

```bash
env                          # 查看所有环境变量
echo $PATH                   # 查看 PATH
export MY_VAR="value"        # 设置环境变量（临时）
echo 'export MY_VAR="value"' >> ~/.bashrc  # 永久设置 或者是 ~/.zshrc
source ~/.bashrc             # 使配置生效 或者是 ~/.zshrc 
```

---

## 参考链接

- [Linux 命令大全](https://www.runoob.com/linux/linux-command-manual.html)
- [Linux Command](https://linux.die.net/)
- [TLDR Pages](https://tldr.sh/) - 简化版 man 手册

