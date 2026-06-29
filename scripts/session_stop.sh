#!/bin/bash
# session_stop.sh - 停止浏览器会话
# 参数：$1 = session ID

SESSION="$1"

if [ -z "$SESSION" ]; then
    echo "错误：缺少session ID参数" >&2
    exit 1
fi

bsk session stop "$SESSION" 2>&1
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    echo "会话停止失败" >&2
    exit 1
fi
