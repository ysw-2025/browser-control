#!/bin/bash
# extract-data.sh - 数据提取专用脚本
# 用途：从HTML中提取结构化数据
# 参数1：session ID
# 参数2：提取类型（names|prices|reviews）

SESSION="${1:-}"
TYPE="${2:-names}"

if [ -z "$SESSION" ]; then
    echo "错误：缺少session参数" >&2
    echo "用法：bash extract-data.sh <session_id> <类型>" >&2
    echo "类型：names(门店名) | prices(价格) | reviews(评价数)" >&2
    exit 1
fi

HTML=$(bsk get-html --session "$SESSION" 2>&1)

case "$TYPE" in
    names)
        echo "$HTML" | grep -oP '<h4>[^<]+</h4>' | grep -v "频道\|分类\|地点\|问题\|商户" | sed 's/<h4>//g;s/<\/h4>//g'
        ;;
    prices)
        echo "$HTML" | grep -oP 'class="mean-price"[^>]*>[^<]*<[^>]*>[^<]*'
        ;;
    reviews)
        echo "$HTML" | grep -oP '[0-9,]+ 条评价'
        ;;
    *)
        echo "未知类型: $TYPE" >&2
        echo "支持的类型：names | prices | reviews" >&2
        exit 1
        ;;
esac
