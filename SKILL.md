---
name: browser-control
description: 浏览器自动化控制技能。封装bsk CLI的所有能力，提供会话管理、工作流脚本和标准化错误处理。让AI只需调用脚本，不直接写bsk命令。支持商业数据采集应用。
version: "1.2.0"
---

# browser-control

通过bsk CLI控制用户的真实Chromium浏览器（保留登录态和Cookie）。

## ⚠️ 强制行为清单（顶部）

### 你的唯一动作
用户说"X" → 你只做一件事：**调用scripts目录下的脚本**

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
├── get-html.sh         # 获取原始HTML（数据采集用）
├── click.sh            # 点击元素
├── fill.sh             # 填写输入框
├── select.sh           # 下拉框选择
├── press.sh            # 键盘按键
├── screenshot.sh       # 截图
├── wait.sh             # 等待
├── tab_create.sh       # 创建新标签
├── tab_list.sh         # 列出所有标签
├── reload.sh           # 刷新页面
└── workflow.sh         # 一键执行
```

## 数据采集策略

### snapshot vs get-html 选择指南

| 场景 | 工具 | 速度 | 说明 |
|------|------|------|------|
| **数据采集**（提取门店/价格/文本） | get-html | ~0.16s | 原始HTML，正则提取 |
| **需要交互**（点击/填写/选择） | snapshot | ~0.35s | ARIA结构化，有@eN引用 |
| **补充数据** | 两者结合 | - | get-html提取主数据，snapshot补充细节 |

### 最佳实践

```bash
# 1. 纯数据采集（推荐get-html）
SID=$(bash scripts/session_start.sh)
bash scripts/navigate.sh "https://www.dianping.com/search/keyword/2/10_火锅" "$SID"
HTML=$(bash scripts/get-html.sh "$SID")
echo "$HTML" | grep -oP '<h4>[^<]+</h4>'  # 提取门店名称
bash scripts/session_stop.sh "$SID"

# 2. 需要点击交互（必须snapshot）
SID=$(bash scripts/session_start.sh)
bash scripts/navigate.sh "https://example.com" "$SID"
bash scripts/snapshot.sh "$SID"
bash scripts/click.sh "@e5" "$SID"
bash scripts/session_stop.sh "$SID"
```

### 采集示例：大众点评

```bash
SID=$(bash scripts/session_start.sh)
bash scripts/navigate.sh "https://www.dianping.com/search/keyword/2/10_火锅" "$SID"
bash scripts/wait.sh 2s

# 门店名称（get-html）
HTML=$(bash scripts/get-html.sh "$SID")
echo "$HTML" | grep -oP '<h4>[^<]+</h4>' | grep -v "频道\|分类\|地点" | head -15

# 人均价格（snapshot更准确）
bash scripts/snapshot.sh "$SID" | grep -E "heading.*店|人均.*￥"

bash scripts/session_stop.sh "$SID"
```

---

## 商业应用

### 选址数据采集

**场景**：连锁品牌扩张选址分析

**数据源**：
- 大众点评：竞品门店、评分、评价数、人均价格
- 百度地图：人流热力图、交通覆盖
- 贝壳/房天下：租金参考

**示例**：
```bash
# 采集北京火锅品类数据
SID=$(bash scripts/session_start.sh)
bash scripts/navigate.sh "https://www.dianping.com/search/keyword/2/10_火锅" "$SID"
bash scripts/wait.sh 3s
bash scripts/snapshot.sh "$SID" | grep -E "heading.*店|人均.*￥"
bash scripts/session_stop.sh "$SID"
```

**详细用法**：见 `references/dianping-data-collection.md`

**商业模式**：
- 按次报告：299-999元/份
- 年费会员：5999-19999元/年
- 价值：节省人工调研时间，非替代决策

---

## 标准工作流

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

## 脚本详细说明

### session_start.sh
- 输出：4字母session ID（如`hvcq`）
- 失败：exit 1，stderr输出错误

### session_stop.sh
- 参数：$SESSION
- 退出码：0成功，1失败

### navigate.sh
- 参数：URL（必须带https://）
- 内部自动wait导航完成
- 失败：exit 1

### snapshot.sh
- 输出：ARIA树，`@e1, @e2...`元素引用
- **警告**：每次navigate后必须重新调用
- 失败：exit 1

### click.sh
- 参数：@eN引用（必须来自最新snapshot）
- 失败：exit 1（可能是ref过期，需重新snapshot）

### fill.sh
- 参数：@eN引用 文本内容
- 自动清空后填入
- 失败：exit 1

### screenshot.sh
- 参数：输出路径（可选，默认`C:/Users/dell/.qclaw-hermes/workspace/screenshot.png`）
- 输出：截图文件路径
- 失败：exit 1

### wait.sh
- 参数：时长（500ms, 2s, 1m）
- 用于等待JS渲染/动画
- **不要用这个等待导航**，用navigate.sh的自动等待

### tab_create.sh
- 参数：URL（可选）
- 在Agent Window创建新标签
- 输出：新tab ID

### tab_list.sh
- 列出所有标签（agent + user）

---

## 失败处理模板

脚本返回非0退出码时，**禁止分析原因**，直接输出：

```
❌ 浏览器操作失败

失败步骤：[具体步骤]
失败原因：[stderr原文]

请检查后重试。
```

---

## 高级操作

### 借用用户标签
当需要操作用户已打开的标签时：
```bash
# 1. 列出用户标签
bash scripts/tab_list.sh | grep user

# 2. 借用（需要tab ID）
bsk tab borrow <tab-id> --session "$SESSION"

# 3. 操作完后归还
bsk tab return <tab-id> --session "$SESSION"
```

### JS执行
```bash
bsk evaluate "document.title" --session "$SESSION"
```

### 页面元素截图
```bash
# 先snapshot获取ref
bash scripts/snapshot.sh "$SESSION"

# 截取特定元素
bsk screenshot --session "$SESSION" --ref @e5 --out "element.png"
```

### 键盘操作
```bash
bsk press Enter --session "$SESSION"
bsk press Ctrl+A --session "$SESSION"
```

---

## 自检清单

执行前确认：
- [ ] 调用的是scripts目录下的脚本，不是直接bsk命令
- [ ] session_start后一定有session_stop
- [ ] navigate后重新snapshot
- [ ] 失败时用标准模板，不分析原因
- [ ] session ID通过参数传递，不是直接写死
- [ ] 商业数据采集需声明数据来源和局限性
