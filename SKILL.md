---
name: browser-control
description: 浏览器自动化控制技能。封装bsk CLI的所有能力，提供会话管理、工作流脚本和标准化错误处理。让AI只需调用脚本，不直接写bsk命令。
version: "1.0.0"
---

# browser-control

通过bsk CLI控制用户的真实Chromium浏览器（保留登录态和Cookie）。

## ⚠️ 强制行为清单（顶部 - 新AI第一眼必须看到）

### 你的唯一动作
用户说"X" → 你只做一件事：**调用scripts目录下的脚本**

### 绝对禁止（违反任何一条=立即失败）

| 禁止行为 | 具体词汇 | 解释 |
|---------|---------|------|
| 直接写bsk命令 | `bsk navigate`, `bsk click`, `bsk session` | 禁止直接拼接CLI命令字符串 |
| 自主决策 | `让我试试`, `让我修正`, `换个方式` | 脚本已封装所有能力 |
| 分析失败 | `session`, `端口`, `扩展`, `超时` | 只报步骤+原因，不解释技术细节 |
| 给用户选择 | `选择`, `建议`, `你想` | 只有执行，没有选择 |
| 让用户手动 | `请手动`, `你需要`, `打开浏览器` | 脚本能做的事不许推给用户 |

### 正确行为

- ✅ 调用`scripts/workflow.sh`（优先）或`scripts/*.sh`
- ✅ 成功→原样展示脚本stdout
- ❌ 失败→用标准模板报错（见下方）

### 脚本调用格式（唯一允许的格式）

```bash
# 一键workflow（推荐）
bash scripts/workflow.sh open "https://example.com"
bash scripts/workflow.sh extract "https://example.com" "关键词"
bash scripts/workflow.sh fill_click "https://form.com" "@e5" "内容" "@e8"

# 手动调用（仅在需要精细控制时）
SID=$(bash scripts/session_start.sh)
bash scripts/navigate.sh "https://example.com" "$SID"
bash scripts/snapshot.sh "$SID"
bash scripts/session_stop.sh "$SID"
```

**禁止格式**（AI不得写出这些）：
```bash
# ❌ 禁止：直接写bsk命令
bsk navigate "https://example.com" --session "$SID"

# ❌ 禁止：拼接命令字符串
CMD="bsk click $REF --session $SID"
eval $CMD

# ❌ 禁止：在SKILL.md中暴露CLI语法
# 用户可以按照 `bsk <cmd> --help` 查看命令帮助
```

---

## 失败处理模板（第2块）

脚本返回非0退出码时，**禁止分析原因**：

```
❌ 浏览器操作失败

失败步骤：[具体步骤]
失败原因：[stderr原文]

请检查后重试。
```

---

## 核心架构原则（第3块）

**AI不记规则 / 脚本控流程 / 文件记历史**

- 所有bsk能力封装在scripts/目录
- AI只调用脚本，不直接执行bsk命令
- 测试记录在references/目录

---

## 完整工作流（第4块）

### 标准生命周期

```
1. bash session_start.sh           → 获取SESSION_ID
2. bash navigate.sh URL $SID      → 导航+自动等待
3. bash snapshot.sh $SID          → 获取@eN引用
4. bash click/fill.sh @eN $SID    → 交互操作
5. bash wait.sh 2s                → 等待渲染（如需要）
6. bash snapshot.sh $SID          → 重新获取引用（必须！）
7. bash session_stop.sh $SID      → 清理会话
```

### 元素引用规则

`snapshot.sh`输出`@e1, @e2, @e3...`引用：
- 每次navigate后**必须重新snapshot**
- 引用只在当前页面有效
- 导航后原引用失效

### 一键workflow（快速场景）

```bash
# 打开网页并截图
bash workflow.sh open "https://example.com"

# 提取内容
bash workflow.sh extract "https://example.com" "关键词"

# 填写并点击
bash workflow.sh fill_click "https://form.com" "@e5" "内容" "@e8"
```

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
├── workflow.sh         # 一键执行（open/extract/fill_click）
└── do.sh               # 通用bsk命令接口
```

### 脚本参数说明

| 脚本 | 参数 | 示例 |
|------|------|------|
| session_start | 无 | `SID=$(bash session_start.sh)` |
| session_stop | session ID | `bash session_stop.sh $SID` |
| navigate | URL, session ID | `bash navigate.sh "https://..." $SID` |
| snapshot | session ID | `bash snapshot.sh $SID` |
| click | @eN引用, session ID | `bash click.sh "@e5" $SID` |
| fill | @eN引用, 文本, session ID | `bash fill.sh "@e5" "内容" $SID` |
| select | @eN引用, 选项值, session ID | `bash select.sh "@e5" "value" $SID` |
| screenshot | session ID, 路径(可选) | `bash screenshot.sh $SID "out.png"` |
| wait | 时长 | `bash wait.sh 2s` |
| tab_create | URL(可选), session ID | `bash tab_create.sh "https://..." $SID` |
| tab_list | session ID, scope(可选) | `bash tab_list.sh $SID agent` |

---

## 高级操作（需要直接bsk命令时）

这些操作scripts/未封装，AI可临时直接调用：

```bash
# 借用用户标签
bsk tab borrow <tab-id> --session "$SID"
bsk tab return <tab-id> --session "$SID"

# JS执行
bsk evaluate "document.title" --session "$SID"

# 元素截图
bsk screenshot --session "$SID" --ref @e5 --out "element.png"

# 键盘组合键
bsk press "Ctrl+A" --session "$SID"
```

---

## 自检清单

执行前确认：
- [ ] 调用scripts/目录下的脚本，不是直接bsk命令
- [ ] session_start后一定有session_stop
- [ ] navigate后重新snapshot
- [ ] 失败时用标准模板，不分析原因
- [ ] session ID通过参数传递

---

## 相关资源

- references/bsk-testing.md - bsk CLI完整测试记录
- scripts/workflow.sh - 一键执行入口
