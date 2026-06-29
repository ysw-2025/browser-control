---
name: browser-control
description: 浏览器自动化控制技能。封装bsk CLI的所有能力，提供会话管理、工作流脚本和标准化错误处理。让AI只需调用脚本，不直接写bsk命令。
version: "1.0.0"
---

# browser-control

通过bsk CLI控制用户的真实Chromium浏览器（保留登录态和Cookie）。

## ⚠️ 强制行为清单（顶部）

### 你的唯一动作
用户说"X" → 你只做一件事：**执行scripts目录下的脚本**

### 绝对禁止（违反任何一条=立即失败）

| 禁止词 | 解释 |
|--------|------|
| `bsk` | 禁止直接写bsk命令 |
| `让我试试` | 禁止自主决策 |
| `让我修正` | 禁止修正命令 |
| `echo $?` | 禁止检查退出码 |
| `session`/`端口`/`扩展` | 禁止分析失败原因 |
| `选择`/`建议` | 禁止给用户选择 |
| `让用户手动` | 禁止把脚本能做的事推给用户 |

### 正确行为

- ✅ 调用`scripts/session_start.sh`启动会话
- ✅ 所有操作通过`scripts/*.sh`执行
- ✅ 成功→原样展示stdout
- ❌ 失败→用标准模板报错（不分析、不解释）

---

## 脚本目录

```
skills/browser-control/scripts/
├── session_start.sh     # 启动会话，返回session ID
├── session_stop.sh      # 停止会话
├── navigate.sh         # 导航到URL
├── snapshot.sh         # 获取页面结构树（@eN引用）
├── click.sh            # 点击元素
├── fill.sh             # 填写输入框
├── select.sh           # 选择下拉框
├── press.sh            # 键盘按键
├── screenshot.sh       # 截图
├── wait.sh             # 等待
├── tab_create.sh       # 创建新标签
├── tab_list.sh         # 列出所有标签
├── reload.sh           # 刷新页面
└── do.sh               # 通用bsk命令接口
```

---

## 标准工作流

### 完整流程模板

```bash
# 1. 启动会话
SESSION_ID=$(bash scripts/session_start.sh)
echo "Session: $SESSION_ID"

# 2. 导航
bash scripts/navigate.sh "https://example.com" "$SESSION_ID"

# 3. 获取页面结构
bash scripts/snapshot.sh "$SESSION_ID"

# 4. 交互（用snapshot中的@eN引用）
bash scripts/fill.sh "@e5" "内容" "$SESSION_ID"
bash scripts/click.sh "@e8" "$SESSION_ID"

# 5. 等待（如需要）
bash scripts/wait.sh 2s

# 6. 再次获取页面结构（引用已失效）
bash scripts/snapshot.sh "$SESSION_ID"

# 7. 清理会话
bash scripts/session_stop.sh "$SESSION_ID"
```

### 脚本参数说明

| 脚本 | 参数 | 示例 |
|------|------|------|
| session_start | 无 | `SESSION_ID=$(bash session_start.sh)` |
| session_stop | session ID | `bash session_stop.sh $SID` |
| navigate | URL, session ID | `bash navigate.sh "https://..." $SID` |
| snapshot | session ID | `bash snapshot.sh $SID` |
| click | @eN引用, session ID | `bash click.sh "@e5" $SID` |
| fill | @eN引用, 文本, session ID | `bash fill.sh "@e5" "内容" $SID` |
| select | @eN引用, 选项值, session ID | `bash select.sh "@e5" "value" $SID` |
| screenshot | 路径(可选), session ID | `bash screenshot.sh "out.png" $SID` |
| wait | 时长 | `bash wait.sh 2s` |
| tab_create | URL(可选), session ID | `bash tab_create.sh "https://..." $SID` |
| tab_list | session ID, scope(可选) | `bash tab_list.sh $SID agent` |

---

## 元素引用（@eN）

`snapshot.sh`输出格式：
```
@e1 RootWebArea "页面标题"
  @e2 link "链接文字"
  @e3 textbox "输入框"
  @e4 button "按钮"
```

**关键规则**：
- 每次navigate后**必须重新snapshot**
- @eN引用只在当前页面有效，导航后失效
- 用grep提取特定元素：`bash snapshot.sh $SID | grep "关键词"`

---

## 失败处理模板

脚本返回非0退出码时，**禁止分析原因**：

```
❌ 浏览器操作失败

失败步骤：[具体步骤]
失败原因：[stderr原文]

请检查后重试。
```

---

## 常用操作示例

### 一键workflow（推荐）

```bash
# 打开网页并截图
bash scripts/workflow.sh open "https://example.com"

# 打开网页并提取内容
bash scripts/workflow.sh extract "https://example.com" "关键词"

# 填写表单并点击
bash scripts/workflow.sh fill_click "https://form.com" "@e5" "内容" "@e8"
```

### 手动workflow（完整控制）

```bash
# 1. 启动会话
SID=$(bash scripts/session_start.sh)

# 2. 导航
bash scripts/navigate.sh "https://example.com" "$SID"

# 3. 获取页面结构
bash scripts/snapshot.sh "$SID"

# 4. 交互（用snapshot中的@eN引用）
bash scripts/fill.sh "@e5" "内容" "$SID"
bash scripts/click.sh "@e8" "$SID"

# 5. 等待（如需要）
bash scripts/wait.sh 2s

# 6. 再次获取页面结构（引用已失效）
bash scripts/snapshot.sh "$SID"

# 7. 清理会话
bash scripts/session_stop.sh "$SID"
```

---

## 高级操作

### 借用用户标签
```bash
# 1. 列出用户标签
bash scripts/tab_list.sh "$SID" user

# 2. 借用（需要tab ID）
bsk tab borrow <tab-id> --session "$SID"

# 3. 操作完后归还
bsk tab return <tab-id> --session "$SID"
```

### JS执行
```bash
bsk evaluate "document.title" --session "$SID"
```

### 页面元素截图
```bash
bash scripts/snapshot.sh "$SID"
bsk screenshot --session "$SID" --ref @e5 --out "element.png"
```

### 键盘操作
```bash
bash scripts/press.sh Enter "$SID"
bash scripts/press.sh "Ctrl+A" "$SID"
```

### 下拉框选择
```bash
bash scripts/snapshot.sh "$SID"  # 先找到<select>的ref
bash scripts/select.sh "@e5" "option_value" "$SID"
```

---

## 自检清单

执行前确认：
- [ ] 调用的是scripts目录下的脚本，不是直接bsk命令
- [ ] session_start后一定有session_stop
- [ ] navigate后重新snapshot
- [ ] 失败时用标准模板，不分析原因
- [ ] session ID通过参数传递，不是直接写死
