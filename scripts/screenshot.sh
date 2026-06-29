#!/bin/bash
# screenshot.sh - 截图
# 参数：$1 = SESSION (必需), $2 = 输出路径（可选）

SESSION="$1"
OUTPUT="${2:-C:/Users/dell/.qclaw-hermes/workspace/screenshot.png}"

# 尝试从环境变量获取
if [ -z "$SESSION" ] && [ -n "$SESSION_ID" ]; then
    SESSION="$SESSION_ID"
fi

if [ -z "$SESSION" ]; then
    echo "错误：缺少session ID（参数1）" >&2
    exit 1
fi

bsk screenshot --session "$SESSION" --out "$OUTPUT" 2>&1
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    echo "截图失败" >&2
    exit 1
fi

echo "$OUTPUT"
