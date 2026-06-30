# browser-control

**v1.2.0** | 通过bsk CLI控制用户真实Chromium浏览器的Skill。让AI只需调用脚本，不直接写bsk命令。

## 🆕 v1.2.0 新功能

- `get-html.sh` - 快速获取原始HTML（数据采集专用，比snapshot快50%）
- `extract-data.sh` - 结构化数据提取（支持门店名/价格/评价数）
- 优化数据采集策略文档

## 功能

- 会话管理（启动/停止）
- 页面导航与结构提取
- 元素交互（点击、填写、选择）
- 截图与等待
- 多标签管理
- 一键workflow
- **🆕 快速数据采集**（get-html + extract-data）

## 快速开始

### 1. 安装依赖

**浏览器扩展** (必需)：
- 从 [browser-skill](https://github.com/nous-research/browser-skill) 下载扩展
- 在Chrome中加载扩展，确保popup显示绿色（已连接）

**bsk CLI** (必需)：
```bash
# 从 https://github.com/nous-research/browser-skill/releases 下载
# 或 cargo install bsk
bsk --version
```

**验证安装**：
```bash
bsk status
# 应该显示 browsers connected: 1
```

### 2. 克隆此仓库

```bash
git clone https://github.com/ysw-2025/browser-control.git
cd browser-control
chmod +x scripts/*.sh  # 如果需要
```

### 3. 使用

```bash
# 打开网页并截图
bash scripts/workflow.sh open "https://example.com"

# 提取页面内容
bash scripts/workflow.sh extract "https://example.com" "关键词"

# 填写表单并提交
bash scripts/workflow.sh fill_click "https://form.com" "@e5" "内容" "@e8"
```

## 脚本说明

| 脚本 | 用途 |
|------|------|
| `session_start.sh` | 启动会话，返回session ID |
| `session_stop.sh` | 停止会话 |
| `navigate.sh` | 导航到URL |
| `snapshot.sh` | 获取页面结构树（@eN引用） |
| `click.sh` | 点击元素 |
| `fill.sh` | 填写输入框 |
| `select.sh` | 下拉框选择 |
| `press.sh` | 键盘按键 |
| `screenshot.sh` | 截图 |
| `wait.sh` | 等待 |
| `tab_create.sh` | 创建新标签 |
| `tab_list.sh` | 列出所有标签 |
| `workflow.sh` | 一键执行 |

## 目录结构

```
browser-control/
├── SKILL.md              # Skill说明
├── README.md             # 本文件
└── scripts/
    ├── session_start.sh
    ├── session_stop.sh
    ├── navigate.sh
    ├── snapshot.sh
    ├── click.sh
    ├── fill.sh
    ├── select.sh
    ├── press.sh
    ├── screenshot.sh
    ├── wait.sh
    ├── tab_create.sh
    ├── tab_list.sh
    ├── reload.sh
    ├── do.sh
    └── workflow.sh
```

## AI使用规范

加载此Skill的AI必须：
- 始终调用scripts目录下的脚本
- session_start后必须有session_stop
- navigate后必须重新snapshot
- 失败时用标准模板报错，不分析原因

## License

MIT
