#!/bin/bash
# tab_list.sh - 列出所有标签
# 参数：$1 = SESSION (可选), $2 = scope（可选：agent/user/all）

SESSION="${1:-}"
SCOPE="${2:-all}"

# 尝试从环境变量获取
if [ -z "$SESSION" ] && [ -n "$SESSION_ID" ]; then
    SESSION="$SESSION_ID"
fi

if [ -z "$SESSION" ]; then
    echo "错误：缺少session ID" >&2
    exit 1
fi

bsk tab list --session "$SESSION" --scope "$SCOPE" 2>&1
