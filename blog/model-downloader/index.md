---
title: "HuggingFace/ModelScope 模型下载工具"
date: 2026-03-26T17:00:00+08:00
lastmod: 2026-03-26T17:00:00+08:00
draft: false
description: "HuggingFace 和 ModelScope 模型下载工具介绍"
slug: "model-downloader"
tags: ["HuggingFace", "ModelScope", "模型下载"]
categories: ["实用工具"]
comments: true
math: true
---

# HuggingFace/ModelScope 模型下载工具备忘

在使用社区大模型时不太建议在代码内嵌模型下载，通过**预先下载至本地**，再从对应目录加载更加方便。

## 1. HuggingFace

### 1.1 专用下载工具
huggingface直连情况下速率较慢，可以通过[镜像站](https://hf-mirror.com/)进行下载，需要临时设置一次环境变量如下：
```bash
export HF_ENDPOINT=https://hf-mirror.com
```

“专用下载工具”的获取，以及赋予可执行权限：
```bash
wget https://hf-mirror.com/hfd/hfd.sh
chmod a+x hfd.sh 
```

寻找对应模型的id，左边绿色框内表示模型id，右边红色框可以一键复制模型id
![](./png/屏幕截图%202026-03-27%20232853.png)

在需要下载模型的目录中执行模型下载命令：
```bash
./hfd.sh Qwen/Qwen3.5-9B # 替换为自己需要的模型id
```

- 部分文件下载：通过`--include`命令执行正则表达式的筛选，只下载需要的文件，例如下面表示只下载config.json文件
    ```bash
    /hfd.sh <model_id> --include '^config.json$'
    ```

- 数据集下载：查找指定数据集id，执行下载命令如下：
    ```bash
    ./hfd.sh wikitext --dataset # wikitext是下载的数据集id
    ```

## 2. ModelScope
### 2.1 命令行
魔塔社区下载器通过python命令行形式，需要先安装python包
```bash
pip install modelscope # 先在指定虚拟环境下安装modelscope包
```
然后找到想要下载的模型的界面，旁边有下载指引
![](./png/屏幕截图%202026-03-27%20230714.png)
在下载指引可以看到下载教程，
![](./png/屏幕截图%202026-03-27%20231345.png)
通常来说，命令行下载只需要找到**模型id**，如上图左侧，随后执行下载命令
```bash
modelscope download --model Qwen/Qwen3.5-9B # 最后是模型id，确保当前命令行的python环境有modescope
```

- 特别的，可以只下载部分文件，通常会用于下载`README.md`或者`config.json`等，`README.md`包括模型介绍而`config.json`包括模型实例化的信息，可以空数据的形式加载到[元设备](https://docs.pytorch.org/docs/stable/meta.html)执行，命令如下：

    ```bash
    modelscope download --model Qwen/Qwen3.5-9B config.json
    ```

- 数据集下载：查找数据集id，把`--model`替换成`--dataset`即可
    ```bash
    modelscope download --dataset datai_id
    ```

### 2.2 其它方式

SDK或者git方式参考[官方文档](https://modelscope.cn/docs/models/download)或者对应模型的下载指引。

---

## 参考链接

- [HuggingFace Hub 文档](https://huggingface.co/docs/hub/)
- [ModelScope 文档](https://modelscope.cn/docs)
- [hf-mirror](https://hf-mirror.com/)
