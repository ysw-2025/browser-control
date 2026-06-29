#!/bin/bash
# navigate.sh - 导航到URL
# 参数：$1 = URL, $2 = SESSION (可选)

URL="$1"
SESSION="${2:-}"

# 尝试从环境变量获取
if [ -z "$SESSION" ] && [ -n "$SESSION_ID" ]; then
    SESSION="$SESSION_ID"
fi

if [ -z "$SESSION" ]; then
    echo "错误：缺少session ID（参数2）" >&2
    exit 1
fi

if [ -z "$URL" ]; then
    echo "错误：缺少URL参数" >&2
    exit 1
fi

bsk navigate "$URL" --session "$SESSION" 2>&1
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    echo "导航失败：$URL" >&2
    exit 1
fi
