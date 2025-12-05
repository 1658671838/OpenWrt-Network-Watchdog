#!/bin/sh

# =========================================================
# OpenWrt 简易网络看门狗 (无自动认证版)
# =========================================================

# --- 1. 配置区域 ---
# 检测目标 IP (这里使用阿里 DNS，也可以换成 114.114.114.114)
TARGET_IP="223.5.5.5"

# 逻辑接口名称
# 在 OpenWrt "网络" -> "接口" 页面能看到的那个英文名
# 连无线中继通常叫 wwan，拨号通常叫 wan
INTERFACE="wwan"

# 日志标签 (方便在系统日志里搜索)
LOG_TAG="Network_Watchdog"

# --- 2. 核心逻辑 ---

# 尝试 Ping 目标 IP，发 3 个包，超时 10 秒
# > /dev/null 2>&1 表示静默运行，不输出 Ping 的结果到屏幕
if ping -c 3 -W 10 $TARGET_IP > /dev/null 2>&1; then
    # Ping 通了，网络正常，直接退出脚本，不占用资源
    exit 0
else
    # Ping 不通，网络断开
    logger -t "$LOG_TAG" "检测到网络断开 (Ping $TARGET_IP 失败)，正在重启接口 $INTERFACE ..."
    
    # 执行重启接口命令
    ifup $INTERFACE
    
    logger -t "$LOG_TAG" "接口重启命令已执行，等待网络恢复。"
fi