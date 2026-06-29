#!/bin/bash
# press.sh - 键盘按键
# 参数：$1 = 按键（如Enter, Tab, Ctrl+A）, $2 = SESSION (可选)

KEY="$1"
SESSION="${2:-}"

# 尝试从环境变量获取
if [ -z "$SESSION" ] && [ -n "$SESSION_ID" ]; then
    SESSION="$SESSION_ID"
fi

if [ -z "$SESSION" ]; then
    echo "错误：缺少session ID" >&2
    exit 1
fi

if [ -z "$KEY" ]; then
    echo "错误：缺少按键参数（用法：press.sh Enter）" >&2
    exit 1
fi

bsk press "$KEY" --session "$SESSION" 2>&1
