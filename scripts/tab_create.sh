#!/bin/bash
# tab_create.sh - 创建新标签
# 参数：$1 = URL（可选）, $2 = SESSION (可选)

URL="$1"
SESSION="${2:-}"

# 尝试从环境变量获取
if [ -z "$SESSION" ] && [ -n "$SESSION_ID" ]; then
    SESSION="$SESSION_ID"
fi

if [ -z "$SESSION" ]; then
    echo "错误：缺少session ID" >&2
    exit 1
fi

CMD="bsk tab create --session $SESSION"
if [ -n "$URL" ]; then
    CMD="$CMD --url $URL"
fi

RESULT=$($CMD 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    echo "创建标签失败" >&2
    exit 1
fi

echo "$RESULT"
