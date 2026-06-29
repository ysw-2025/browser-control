#!/bin/bash
# session_start.sh - 启动浏览器会话
# 输出：session ID（4字母）
# 失败：exit 1

set -e

BSK_OUTPUT=$(bsk session start 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    echo "$BSK_OUTPUT" >&2
    exit 1
fi

SESSION_ID=$(echo "$BSK_OUTPUT" | tr -d '[:space:]')
echo "$SESSION_ID"
