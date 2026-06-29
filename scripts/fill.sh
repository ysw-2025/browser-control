#!/bin/bash
# fill.sh - 填写输入框
# 参数：$1 = @eN引用, $2 = 文本内容, $3 = SESSION (可选)

REF="$1"
TEXT="$2"
SESSION="${3:-}"

# 尝试从环境变量获取
if [ -z "$SESSION" ] && [ -n "$SESSION_ID" ]; then
    SESSION="$SESSION_ID"
fi

if [ -z "$SESSION" ]; then
    echo "错误：缺少session ID" >&2
    exit 1
fi

if [ -z "$REF" ] || [ -z "$TEXT" ]; then
    echo "错误：缺少参数（用法：fill.sh @e5 \"文本内容\"）" >&2
    exit 1
fi

bsk fill "$REF" --value "$TEXT" --session "$SESSION" 2>&1
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    echo "填写失败：$REF" >&2
    exit 1
fi
