---
title: "Docker 常用命令备忘"
date: 2026-03-29T13:00:00+08:00
lastmod: 2026-03-29T13:00:00+08:00
draft: false
description: "Docker 日常使用常用命令速查"
slug: "docker-commands"
tags: ["Docker", "容器"]
categories: ["实用工具"]
comments: true
math: true
---

# Docker 常用命令备忘

Docker 日常使用中最常用的命令速查，包括镜像管理、容器操作、网络配置、数据卷等。

## 1. 镜像管理
镜像分层情况：
```bash
┌─────────────────┐
│ 胶片5: 启动命令  │  ← 最后一层：定义容器启动时执行什么
│ "CMD python app.py" │
├─────────────────┤
│ 胶片4: 安装依赖  │  ← 中间层：安装 Python 包
│ "pip install flask" │
├─────────────────┤
│ 胶片3: 拷贝代码  │  ← 中间层：把代码放进容器
│ "COPY . /app"     │
├─────────────────┤
│ 胶片2: 设置环境  │  ← 中间层：配置工作目录
│ "WORKDIR /app"    │
├─────────────────┤
│ 胶片1: 基础系统  │  ← 最底层：操作系统 + 基础工具
│ "FROM ubuntu:20.04" │
└─────────────────┘
```
### 1.1 查看镜像

```bash
docker images              # 查看本地镜像
docker images -a           # 包含中间层镜像
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
```

### 1.2 搜索镜像

```bash
docker search nginx
docker search --limit 5 nginx
```

### 1.3 拉取镜像

```bash
docker pull nginx          # 拉取最新版
docker pull nginx:1.24     # 拉取指定版本
docker pull registry.cn-hangzhou.aliyuncs.com/xxx/xxx  # 从私有仓库拉取
```

### 1.4 删除镜像

```bash
docker rmi nginx           # 删除镜像
docker rmi -f nginx        # 强制删除
docker rmi $(docker images -q)  # 删除所有镜像
docker image prune         # 删除悬空镜像
docker image prune -a      # 删除未使用的镜像
```

### 1.5 镜像导入导出

```bash
# 保存镜像为 tar 文件
docker save -o nginx.tar nginx:latest

# 从 tar 文件加载镜像
docker load -i nginx.tar

# 导出容器为镜像
docker commit container_name myimage:v1
```

## 2. 容器管理

### 2.1 创建并运行容器

```bash
# 基本运行
docker run nginx

# 常用参数
docker run -d \                     # 后台运行
  --name mynginx \                  # 指定名称
  -p 8080:80 \                      # 端口映射
  -v /host/path:/container/path \   # 挂载目录
  -e MY_VAR=value \                 # 环境变量
  --restart=always \                # 自动重启策略
  --gpus all \                      # 使用 GPU
  nginx:latest

# 示例
docker run -d --name nginx -p 80:80 nginx:latest
docker run -it --name ubuntu ubuntu:latest /bin/bash
docker run -d --name mysql -e MYSQL_ROOT_PASSWORD=123456 -p 3306:3306 mysql:8
```

### 2.2 查看容器

```bash
docker ps                  # 查看运行中的容器
docker ps -a               # 查看所有容器
docker ps -q               # 只显示 ID
docker ps -l               # 最近创建的容器
docker inspect <container>   # 查看容器详情
docker logs <container>      # 查看日志
docker logs -f <container>   # 实时查看日志
docker logs --tail 100 <container>  # 最后 100 行
```

### 2.3 容器操作

```bash
# 启动/停止/重启
docker start <container>
docker stop <container>
docker restart <container>

# 强制停止
docker kill <container>

# 暂停/恢复
docker pause <container>
docker unpause <container>

# 进入容器
docker exec -it <container> /bin/bash
docker exec -it <container> sh      # Alpine 等精简镜像

# 在容器中执行命令
docker exec <container> ls /app

# 查看资源使用
docker stats <container>
docker top <container>              # 查看进程
```

### 2.4 删除容器

```bash
docker rm <container>              # 删除已停止的容器
docker rm -f <container>           # 强制删除运行中的容器
docker rm $(docker ps -aq)       # 删除所有容器
docker <container> prune           # 删除所有已停止的容器
```

### 2.5 容器与宿主机复制文件

```bash
# 宿主机 -> 容器
docker cp /host/file.txt container:/path/file.txt

# 容器 -> 宿主机
docker cp container:/path/file.txt /host/file.txt
```

## 3. 数据卷

### 3.1 创建和管理

```bash
# 创建数据卷
docker volume create myvolume

# 查看数据卷
docker volume ls
docker volume inspect myvolume

# 删除数据卷
docker volume rm myvolume
docker volume prune           # 删除未使用的数据卷
```

### 3.2 使用数据卷

```bash
# 挂载数据卷
docker run -v myvolume:/data nginx

# 挂载宿主机目录
docker run -v /host/path:/container/path nginx

# 只读挂载
docker run -v /host/path:/container/path:ro nginx
```

## 4. 网络

### 4.1 网络管理

```bash
# 查看网络
docker network ls

# 创建网络
docker network create mynet
docker network create --driver bridge mynet
docker network create --subnet=192.168.1.0/24 mynet

# 删除网络
docker network rm mynet

# 连接容器到网络
docker network connect mynet <container>
docker network disconnect mynet <container>
```

### 4.2 使用网络

```bash
# 指定网络运行容器
docker run --network mynet nginx

# 使用 host 网络
docker run --network host nginx

# 指定 IP
docker run --network mynet --ip 192.168.1.10 nginx
```

## 5. Docker Compose

### 5.1 基本命令
`docker compose` 是 Docker 官方的多容器编排工具，使用 `docker-compose.yml` 文件定义服务、网络和数据卷，可以使用 `-f` 或 `--file` 参数指定路径。

```bash
# 启动服务
docker compose up -d

# 停止服务
docker compose down
docker compose down -v       # 同时删除数据卷

# 查看状态
docker compose ps
docker compose logs -f
docker compose logs -f nginx

# 重启服务
docker compose restart
docker compose restart nginx

# 进入容器
docker compose exec nginx /bin/bash
```


## 6. 系统清理

```bash
# 查看磁盘使用
docker system df

# 清理未使用的资源
docker system prune          # 清理悬空镜像、停止的容器、未使用的网络
docker system prune -a       # 同时清理未使用的镜像
docker system prune -a --volumes  # 同时清理数据卷

# 分别清理
docker container prune       # 清理停止的容器
docker image prune -a        # 清理未使用的镜像
docker volume prune          # 清理未使用的数据卷
docker network prune         # 清理未使用的网络
```

## 7. 镜像加速

### 7.1 配置镜像源

编辑 `/etc/docker/daemon.json`：

```json
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com"
  ]
}
```

重启 Docker：

```bash
sudo systemctl daemon-reload
sudo systemctl restart docker
```

## 8. GPU 支持

```bash
# 安装 nvidia-container-toolkit
# Ubuntu/Debian
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt update
sudo apt install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

# 使用 GPU 运行容器
docker run --gpus all nvidia/cuda:11.8-base nvidia-smi
docker run --gpus '"device=0,1"' nvidia/cuda:11.8-base nvidia-smi  # 指定 GPU
docker run --gpus 2 nvidia/cuda:11.8-base nvidia-smi               # 指定数量
```


---

## 参考链接

- [Docker 官方文档](https://docs.docker.com/)
- [Docker Hub](https://hub.docker.com/)
- [Docker Compose 文档](https://docs.docker.com/compose/)
