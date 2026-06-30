#!/bin/bash
# get-html.sh - 获取页面原始HTML
# 用途：数据采集，正则提取内容
# 速度：比snapshot快（~0.16s vs ~0.35s）
# 参数：session ID

SESSION="$1"

if [ -z "$SESSION" ]; then
    echo "用法: $0 <session_id>" >&2
    exit 1
fi

bsk get-html --session "$SESSION" 2>&1
