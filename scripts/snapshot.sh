#!/bin/bash
# snapshot.sh - 获取页面结构树
# 参数：$1 = SESSION (可选)

SESSION="${1:-}"

# 尝试从环境变量获取
if [ -z "$SESSION" ] && [ -n "$SESSION_ID" ]; then
    SESSION="$SESSION_ID"
fi

if [ -z "$SESSION" ]; then
    echo "错误：缺少session ID（参数1）" >&2
    exit 1
fi

bsk snapshot --session "$SESSION" 2>&1
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    echo "获取页面结构失败" >&2
    exit 1
fi
