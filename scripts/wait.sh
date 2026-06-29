#!/bin/bash
# wait.sh - 等待
# 参数：$1 = 时长（500ms, 2s, 1m）

DURATION="$1"

if [ -z "$DURATION" ]; then
    echo "错误：缺少时长参数（用法：wait.sh 2s）" >&2
    exit 1
fi

bsk wait-ms "$DURATION" 2>&1
