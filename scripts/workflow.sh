#!/bin/bash
# workflow.sh - 浏览器自动化workflow执行器
# 用法：bash workflow.sh <action> [args...]
# 
# 支持的action：
#   open <url>              - 打开网页并截图
#   fill_click <url> <fill_ref> <fill_text> <click_ref> - 导航+填写+点击
#   extract <url> <pattern> - 打开网页并提取匹配内容

ACTION="$1"
shift

SKILL_DIR="C:/Users/dell/.qclaw-hermes/skills/browser-control/scripts"

case "$ACTION" in
    "open")
        URL="$1"
        if [ -z "$URL" ]; then
            echo "用法：workflow.sh open <url>" >&2
            exit 1
        fi
        SID=$($SKILL_DIR/session_start.sh)
        $SKILL_DIR/navigate.sh "$URL" "$SID"
        sleep 1
        $SKILL_DIR/screenshot.sh "$SID"
        $SKILL_DIR/session_stop.sh "$SID"
        ;;
    "fill_click")
        URL="$1"; FILL_REF="$2"; FILL_TEXT="$3"; CLICK_REF="$4"
        if [ -z "$URL" ] || [ -z "$FILL_REF" ] || [ -z "$FILL_TEXT" ] || [ -z "$CLICK_REF" ]; then
            echo "用法：workflow.sh fill_click <url> <fill_ref> <fill_text> <click_ref>" >&2
            exit 1
        fi
        SID=$($SKILL_DIR/session_start.sh)
        $SKILL_DIR/navigate.sh "$URL" "$SID"
        $SKILL_DIR/snapshot.sh "$SID"
        $SKILL_DIR/fill.sh "$FILL_REF" "$FILL_TEXT" "$SID"
        $SKILL_DIR/click.sh "$CLICK_REF" "$SID"
        $SKILL_DIR/wait.sh 2s
        $SKILL_DIR/snapshot.sh "$SID"
        $SKILL_DIR/session_stop.sh "$SID"
        ;;
    "extract")
        URL="$1"; PATTERN="$2"
        if [ -z "$URL" ] || [ -z "$PATTERN" ]; then
            echo "用法：workflow.sh extract <url> <pattern>" >&2
            exit 1
        fi
        SID=$($SKILL_DIR/session_start.sh)
        $SKILL_DIR/navigate.sh "$URL" "$SID"
        $SKILL_DIR/snapshot.sh "$SID" | grep -E "$PATTERN"
        $SKILL_DIR/session_stop.sh "$SID"
        ;;
    *)
        echo "未知action: $ACTION" >&2
        echo "支持的action: open, fill_click, extract" >&2
        exit 1
        ;;
esac
