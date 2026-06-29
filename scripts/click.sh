#!/bin/bash
# click.sh - 点击元素
# 参数：$1 = @eN引用, $2 = SESSION (可选)

REF="$1"
SESSION="${2:-}"

# 尝试从环境变量获取
if [ -z "$SESSION" ] && [ -n "$SESSION_ID" ]; then
    SESSION="$SESSION_ID"
fi

if [ -z "$SESSION" ]; then
    echo "错误：缺少session ID" >&2
    exit 1
fi

if [ -z "$REF" ]; then
    echo "错误：缺少元素引用（如@e5）" >&2
    exit 1
fi

bsk click "$REF" --session "$SESSION" 2>&1
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    echo "点击失败：$REF（可能需要重新snapshot获取最新引用）" >&2
    exit 1
fi
