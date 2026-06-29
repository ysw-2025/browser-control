#!/bin/bash
# select.sh - 选择下拉框选项
# 参数：$1 = @eN引用, $2 = 选项值, $3 = SESSION (可选)

REF="$1"
VALUE="$2"
SESSION="${3:-}"

# 尝试从环境变量获取
if [ -z "$SESSION" ] && [ -n "$SESSION_ID" ]; then
    SESSION="$SESSION_ID"
fi

if [ -z "$SESSION" ]; then
    echo "错误：缺少session ID" >&2
    exit 1
fi

if [ -z "$REF" ] || [ -z "$VALUE" ]; then
    echo "错误：缺少参数（用法：select.sh @e5 \"option_value\"）" >&2
    exit 1
fi

bsk select "$REF" --value "$VALUE" --session "$SESSION" 2>&1
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    echo "选择失败：$REF = $VALUE" >&2
    exit 1
fi
