#!/bin/bash
# do.sh - 通用bsk命令接口（自动携带session ID）
# 参数：$1 = action, $2+ = action参数
# 用法：do.sh navigate "https://example.com"
#      do.sh click @e5
#      do.sh snapshot

ACTION="$1"
shift
ARGS="$@"

SESSION="${SESSION:-}"
if [ -z "$SESSION" ]; then
    echo "错误：缺少SESSION环境变量" >&2
    exit 1
fi

bsk "$ACTION" $ARGS --session "$SESSION" 2>&1
