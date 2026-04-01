---
title: "ADB 使用备忘"
date: 2026-04-01T10:00:00+08:00
lastmod: 2026-04-01T10:00:00+08:00
draft: false
description: "Android Debug Bridge 常用命令和使用技巧"
slug: "adb-guide"
tags: ["ADB", "Android"]
categories: ["实用工具"]
comments: true
math: true
---

# ADB 使用备忘

ADB (Android Debug Bridge) 是 Android 开发和调试的必备工具，用于与 Android 设备通信。本文记录常用命令和使用技巧。

## 1. 安装

### 1.1 Windows

```powershell
# 方式1: 使用 winget
winget install Google.PlatformTools

# 方式2: 手动安装
# 下载 SDK Platform-Tools
# https://developer.android.com/studio/releases/platform-tools
# 解压后添加到 PATH 环境变量
# 或放入已有 PATH 目录如 C:\Windows
```

### 1.2 Linux

```bash
# Ubuntu/Debian
sudo apt install android-tools-adb
```

### 1.3 验证安装

```bash
adb version
# Android Debug Bridge version 1.0.41
# Version 34.0.5-10900879
```

## 2. 连接设备

### 2.1 USB 连接

1. 手机开启开发者选项：设置 → 关于手机 → 连续点击"版本号" 7 次
2. 开启 USB 调试：设置 → 开发者选项 → USB 调试
3. USB 连接电脑，选择"文件传输"模式
4. 授权调试

```bash
# 查看已连接设备
adb devices

# 输出示例
# List of devices attached
# abc123    device
```
**DEBUG:`no permissions (user huluhulu is not in the plugdev group);`** ，[参考](https://blog.csdn.net/MrMyGod/article/details/140270806)
1. 确保自己添加在组`plugdev`中, 第一次添加需要重新登录用户才能生效。
```bash
sudo usermod -aG plugdev $USER
```
2. 添加 `udev` 规则，创建文件 `/etc/udev/rules.d/51-android.rules`，内容如下（根据`lsusb`命令的输出设置）：
```bash
huluhulu@march-dlng:~$ lsusb
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 001 Device 002: ID 048d:5702 Integrated Technology Express, Inc. RGB LED Controller
Bus 001 Device 003: ID 05e3:0608 Genesys Logic, Inc. Hub
Bus 001 Device 004: ID 05e3:0608 Genesys Logic, Inc. Hub
Bus 001 Device 005: ID 046d:c31c Logitech, Inc. Keyboard K120
Bus 001 Device 006: ID 046d:c53f Logitech, Inc. USB Receiver
Bus 001 Device 011: ID 22d9:2765 OPPO Electronics Corp. Oppo N1 # ----> 这里是连接的手机 记住ID后面的数字
Bus 002 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub

# 例如上面手机的 ID 是 22d9:2765，分别表示厂商 ID 和产品 ID，规则内容如下

# 接下来添加`udev`规则
sudo vim /etc/udev/rules.d/51-android.rules
# 把下面内容添加到文件中，保存退出
# SUBSYSTEM=="usb", ATTR{idVendor}=="22d9", ATTR{idProduct}=="2765", MODE="0666" # 这里0666表示所有用户可读写设备

# 修改权限并重启udev
sudo chmod a+rx /etc/udev/rules.d/51-android.rules
sudo service udev restart
# 重启adb服务
sudo adb kill-server
sudo adb start-server
```


### 2.2 无线连接

```bash
# 首次需要 USB 连接，开启 TCP/IP 模式
adb tcpip 5555

# 查看手机 IP
adb shell ip addr show wlan0

# 断开 USB，通过 WiFi 连接
adb connect 192.168.1.100:5555

# 断开连接
adb disconnect 192.168.1.100:5555

# Android 11+ 可直接扫码配对
# 设置 → 开发者选项 → 无线调试 → 使用配对码配对设备
adb pair 192.168.1.100:37123
# 输入配对码
adb connect 192.168.1.100:5555
```

### 2.3 多设备管理

```bash
# 查看所有设备
adb devices -l

# 指定设备执行命令
adb -s <serial> shell

# 通过 USB 连接
adb -d shell

# 通过 TCP/IP 连接
adb -e shell
```

## 3. 基本命令

### 3.1 设备信息

```bash
# 设备序列号
adb get-serialno

# 设备状态
adb get-state

# Android 版本
adb shell getprop ro.build.version.release

# SDK 版本
adb shell getprop ro.build.version.sdk

# 设备型号
adb shell getprop ro.product.model

# 设备品牌
adb shell getprop ro.product.brand

# 所有属性
adb shell getprop
```

### 3.2 Shell 操作

```bash
# 进入交互式 Shell
adb shell

# 执行单条命令
adb shell ls /sdcard
adb shell cat /proc/cpuinfo

# 以 root 身份运行（需设备已 root）
adb root
adb shell

# 重新挂载系统分区为可写
adb remount
```

## 4. 文件传输

### 4.1 推送文件到设备

```bash
# 基本语法
adb push <本地文件> <设备路径>

# 示例
adb push test.txt /sdcard/
adb push folder/ /sdcard/folder/

# 推送并设置权限
adb push script.sh /data/local/tmp/
adb shell chmod +x /data/local/tmp/script.sh
```

### 4.2 从设备拉取文件

```bash
# 基本语法
adb pull <设备路径> <本地路径>

# 示例
adb pull /sdcard/test.txt ./
adb pull /sdcard/DCIM/ ./photos/
```

### 4.3 同步文件

```bash
# 同步到设备（只传输变化的文件）
adb sync

# 指定同步目录
adb sync /sdcard/
```

## 5. 应用管理

### 5.1 安装应用

```bash
# 安装 APK
adb install app.apk

# 覆盖安装（保留数据）
adb install -r app.apk

# 允许降级安装
adb install -d app.apk

# 安装到 SD 卡
adb install -s app.apk

# 多个 APK（Split APK）
adb install-multiple base.apk config.arm.apk
```

### 5.2 卸载应用

```bash
# 卸载应用
adb uninstall com.example.app

# 卸载但保留数据
adb uninstall -k com.example.app

# 查看已安装应用
adb shell pm list packages
adb shell pm list packages -3  # 第三方应用
adb shell pm list packages -s  # 系统应用
```

### 5.3 清除应用数据

```bash
# 清除数据和缓存
adb shell pm clear com.example.app

# 清除缓存
adb shell rm -rf /data/data/com.example.app/cache/*
```

### 5.4 启动应用

```bash
# 启动应用
adb shell am start -n com.example.app/.MainActivity

# 启动特定 Activity
adb shell am start -n com.example.app/com.example.app.SecondActivity

# 带参数启动
adb shell am start -a android.intent.action.VIEW -d https://baidu.com

# 启动 Service
adb shell am startservice com.example.app/.MyService

# 停止应用
adb shell am force-stop com.example.app
```

### 5.5 应用信息

```bash
# 应用路径
adb shell pm path com.example.app

# 应用详细信息
adb shell dumpsys package com.example.app

# 当前前台应用
adb shell dumpsys activity activities | grep mCurrentFocus
```

## 6. 日志与调试

### 6.1 日志查看

```bash
# 查看所有日志
adb logcat

# 清除日志缓冲区
adb logcat -c

# 查看特定级别日志
adb logcat *:V    # Verbose
adb logcat *:D    # Debug
adb logcat *:I    # Info
adb logcat *:W    # Warning
adb logcat *:E    # Error

# 过滤特定标签
adb logcat -s TAG_NAME
adb logcat TAG_NAME:V *:S

# 过滤关键字
adb logcat | grep "keyword"

# 过滤应用日志（需要 PID）
adb logcat --pid=$(adb shell pidof com.example.app)

# 保存日志到文件
adb logcat > logcat.txt

# 查看内核日志
adb shell dmesg
```

### 6.2 Bug 报告

```bash
# 生成 bug 报告
adb bugreport bugreport.zip

# 快速报告
adb bugreport -k
```

### 6.3 内存信息

```bash
# 查看内存使用
adb shell dumpsys meminfo

# 特定应用内存
adb shell dumpsys meminfo com.example.app

# 查看 CPU 使用
adb shell top
adb shell dumpsys cpuinfo
```

## 7. 截图与录屏

### 7.1 截图

```bash
# 截图保存到设备
adb shell screencap /sdcard/screenshot.png

# 拉取到电脑
adb pull /sdcard/screenshot.png

# 一行命令截图并拉取
adb exec-out screencap -p > screenshot.png
```

### 7.2 录屏

```bash
# 开始录屏（最长 180 秒）
adb shell screenrecord /sdcard/video.mp4

# 设置时长（秒）
adb shell screenrecord --time-limit 30 /sdcard/video.mp4

# 设置分辨率
adb shell screenrecord --size 1280x720 /sdcard/video.mp4

# 设置比特率
adb shell screenrecord --bit-rate 4000000 /sdcard/video.mp4

# Ctrl+C 停止录屏，然后拉取
adb pull /sdcard/video.mp4
```

## 8. 端口转发与反向代理

### 8.1 正向端口转发

将电脑端口转发到设备端口：

```bash
# 电脑 8080 -> 设备 80
adb forward tcp:8080 tcp:80

# 查看转发列表
adb forward --list

# 删除转发
adb forward --remove tcp:8080

# 删除所有转发
adb forward --remove-all
```

### 8.2 反向端口转发

将设备端口转发到电脑端口：

```bash
# 设备 8080 -> 电脑 3000
adb reverse tcp:8080 tcp:3000

# 查看反向代理列表
adb reverse --list

# 删除反向代理
adb reverse --remove tcp:8080
```

## 9. 备份与恢复

```bash
# 备份应用数据
adb backup -f backup.ab com.example.app

# 备份所有应用
adb backup -f all.ab -all

# 备份应用及其 APK
adb backup -f backup.ab -apk com.example.app

# 恢复数据
adb restore backup.ab
```

## 10. 设备控制

### 10.1 重启

```bash
# 普通重启
adb reboot

# 重启到 Recovery
adb reboot recovery

# 重启到 Bootloader/Fastboot
adb reboot bootloader

# 重启到 EDL 模式（部分设备）
adb reboot edl
```

### 10.2 输入操作

```bash
# 发送按键事件
adb shell input keyevent KEYCODE_HOME
adb shell input keyevent KEYCODE_BACK
adb shell input keyevent KEYCODE_MENU
adb shell input keyevent KEYCODE_POWER
adb shell input keyevent KEYCODE_VOLUME_UP
adb shell input keyevent KEYCODE_VOLUME_DOWN

# 常用键值
# 3: HOME
# 4: BACK
# 24: VOLUME_UP
# 25: VOLUME_DOWN
# 26: POWER
# 27: CAMERA

# 点击屏幕
adb shell input tap 500 500

# 滑动
adb shell input swipe 100 500 1000 500      # 水平滑动
adb shell input swipe 500 1000 500 100 500  # 垂直滑动，持续 500ms

# 输入文本
adb shell input text "hello"

# 长按
adb shell input swipe 500 500 500 500 1000  # 长按 1 秒
```

## 11. 网络调试

```bash
# 查看 IP 地址
adb shell ifconfig wlan0
adb shell ip addr show wlan0

# ping 测试
adb shell ping baidu.com

# 查看网络连接
adb shell netstat

# 查看 DNS
adb shell getprop net.dns1
```

## 12. 常见问题

### 12.1 设备未识别

```bash
# 重启 adb 服务
adb kill-server
adb start-server

# 检查 USB 调试是否开启
# 检查驱动是否安装（Windows）
# 尝试换 USB 线或端口
```

### 12.2 授权问题

```bash
# 撤销所有授权
adb kill-server
rm ~/.android/adbkey*    # Linux/macOS
del %USERPROFILE%\.android\adbkey*    # Windows

# 重新连接设备，重新授权
```

### 12.3 offline 状态

```bash
# 设备显示 offline
adb kill-server
adb start-server
# 断开重连 USB，检查 USB 调试授权
```

## 13. 快速参考

```
┌─────────────────────────────────────────────────────┐
│                    ADB 常用命令                      │
├─────────────────────────────────────────────────────┤
│  设备管理                                            │
│  adb devices              列出设备                   │
│  adb -s <id> shell        指定设备                   │
│  adb connect IP:PORT      无线连接                   │
├─────────────────────────────────────────────────────┤
│  文件操作                                            │
│  adb push <local> <remote>  推送文件                 │
│  adb pull <remote> <local>  拉取文件                 │
├─────────────────────────────────────────────────────┤
│  应用管理                                            │
│  adb install app.apk      安装应用                   │
│  adb uninstall pkg        卸载应用                   │
│  adb shell pm clear pkg   清除数据                   │
│  adb shell am start -n pkg/.Activity  启动应用       │
├─────────────────────────────────────────────────────┤
│  日志调试                                            │
│  adb logcat               查看日志                   │
│  adb logcat -c            清除日志                   │
│  adb logcat *:E           只看错误                   │
├─────────────────────────────────────────────────────┤
│  截图录屏                                            │
│  adb exec-out screencap -p > ss.png  截图           │
│  adb shell screenrecord /sdcard/v.mp4  录屏         │
└─────────────────────────────────────────────────────┘
```

---

## 参考链接

- [ADB 官方文档](https://developer.android.com/studio/command-line/adb)
- [ADB Shell 命令](https://developer.android.com/studio/command-line/shell)
- [Platform Tools 下载](https://developer.android.com/studio/releases/platform-tools)
