#!/bin/bash
# reload.sh - 刷新页面
# 参数：$1 = SESSION (可选)

SESSION="${1:-}"

if [ -z "$SESSION" ] && [ -n "$SESSION_ID" ]; then
    SESSION="$SESSION_ID"
fi

if [ -z "$SESSION" ]; then
    echo "错误：缺少session ID" >&2
    exit 1
fi

bsk reload --session "$SESSION" 2>&1
