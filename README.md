# browser-control

**v1.3.0** | 通过bsk CLI控制用户真实Chromium浏览器的Skill。让AI只需调用脚本，不直接写bsk命令。**新增反爬机制诊断与应对能力**。

## 🆕 v1.3.0 新功能

- **反爬机制快速诊断** - 5种反爬类型自动识别（基础防护/浏览器指纹/JS混淆/WAF/验证码）
- **浏览器指纹检测与规避** - 知道bsk能绕过哪些、提前预警
- **JS混淆识别** - 快速判断网站是否用了JS混淆，知道用bsk还是放弃
- **WAF软封检测** - 识别假数据特征，避免以为成功实则失败
- **数据采集合规声明** - 方案自动带合规声明模板
- 新增 `references/anti-crawler-detection.md` 详细文档

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
- **🆕 反爬机制诊断**（自动识别反爬类型+推荐应对方案）
- **🆕 浏览器指纹检测**（知道边界，提前预警）

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

# 🆕 反爬诊断（遇到数据采集失败时）
# 查看 references/anti-crawler-detection.md
```

## 脚本说明

| 脚本 | 用途 |
|------|------|
| `session_start.sh` | 启动会话，返回session ID |
| `session_stop.sh` | 停止会话 |
| `navigate.sh` | 导航到URL |
| `snapshot.sh` | 获取页面结构树（@eN引用） |
| `get-html.sh` | 🆕 快速获取原始HTML（数据采集专用） |
| `click.sh` | 点击元素 |
| `fill.sh` | 填写输入框 |
| `select.sh` | 下拉框选择 |
| `press.sh` | 键盘按键 |
| `screenshot.sh` | 截图 |
| `wait.sh` | 等待 |
| `tab_create.sh` | 创建新标签 |
| `tab_list.sh` | 列出所有标签 |
| `workflow.sh` | 一键执行 |

## 反爬机制诊断（新功能）

### 快速诊断决策树

遇到数据采集问题时，按以下顺序快速判断：

```
数据采集失败 → 判断反爬类型：

1. 返回403 Forbidden？
   → IP被封或WAF硬封
   → 应对：换IP、降低频率、换数据源

2. 返回200但数据不变（软封）？
   → WAF识别了自动化行为，返回假数据
   → 应对：识别假数据特征、人机协作

3. 触发验证码？
   → 行为检测或访问频率过高
   → 应对：人机协作、打码平台

4. JS执行后才能看到数据？
   → 动态渲染或JS加密
   → 应对：bsk evaluate 或 browser_get_html

5. 翻页后内容重复？
   → 被软封（返回第一页数据）
   → 应对：人机协作（用户手动翻页）

6. 都不行？
   → WAF全面封锁
   → 应对：豆包快速探测 + 人工补录 或 换数据源
```

### 五种反爬机制详解

详见 `references/anti-crawler-detection.md`

| 类型 | 难度 | bsk能否绕过 | 应对方案 |
|------|------|-------------|----------|
| 基础防护 | ⭐ | ✅ | 降频、换UA |
| 浏览器指纹 | ⭐⭐ | ⚠️ 部分 | 提前预警、换数据源 |
| JS混淆/加密 | ⭐⭐⭐ | ⚠️ 看情况 | bsk执行 或 放弃 |
| WAF防护 | ⭐⭐⭐⭐ | ❌ | 人机协作 或 换数据源 |
| 验证码 | ⭐⭐⭐⭐⭐ | ❌ | 人工介入 |

### 浏览器指纹检测

**bsk能绕过**：
- WebDriver检测
- 基础UA检测
- 请求头检测

**bsk绕不过**：
- Canvas指纹
- WebGL渲染指纹
- 字体指纹

**应对策略**：
```
遇到Canvas/WebGL指纹检测 → 提前告知用户
→ "这个网站可能绕不过，建议换数据源"
```

## 实战案例

### 案例1：大众点评WAF全面封锁

**问题**：所有自动化翻页方式都被封

**解决方案**：人机协作模式
```
1. agent用bsk evaluate读取当前页数据
2. 通知用户："请手动点击下一页"
3. 用户点击后，agent再读取数据
4. 重复，一次会话可拿120+家
```

详见 `references/dianping-waf-detection.md`

### 案例2：高德POI采集（推荐方案）

**优势**：
- 合规（官方API）
- 完整（全量数据）
- 快速（1次调用拿全城数据）

详见 `references/amap-poi-collection.md`

## 目录结构

```
browser-control/
├── SKILL.md                            # Skill说明（AI加载）
├── README.md                           # 本文件
├── references/                         # 参考文档
│   ├── anti-crawler-detection.md       # 🆕 反爬机制识别与应对详解
│   ├── amap-poi-collection.md          # 高德POI采集
│   ├── dianping-waf-detection.md       # 大众点评WAF检测
│   ├── network-ghost-thinking.md       # 网络幽灵思维
│   └── ...
├── scripts/                            # 脚本目录
│   ├── session_start.sh
│   ├── session_stop.sh
│   ├── navigate.sh
│   ├── snapshot.sh
│   ├── get-html.sh                     # 🆕 快速数据采集
│   ├── click.sh
│   ├── fill.sh
│   ├── select.sh
│   ├── press.sh
│   ├── screenshot.sh
│   ├── wait.sh
│   ├── tab_create.sh
│   ├── tab_list.sh
│   ├── reload.sh
│   └── workflow.sh
└── templates/                          # 模板目录
    └── poi-analysis-report.md
```

## AI使用规范

加载此Skill的AI必须：
- 始终调用scripts目录下的脚本
- session_start后必须有session_stop
- navigate后必须重新snapshot
- 失败时用标准模板报错，不分析原因
- **🆕 遇到反爬问题时，先加载 `references/anti-crawler-detection.md`**
- **🆕 做数据采集方案时，必须加上合规声明**

## 数据采集合规声明模板

**重要**：做数据采集方案时，必须加上合规声明

```
【数据采集合规声明】
数据来源：XXX网站（公开页面）
采集方式：浏览器自动化（bsk）
采集频率：每页间隔2秒
数据用途：市场分析/竞品调研（内部使用）
合规措施：
1. 遵守目标网站robots.txt
2. 控制采集频率，不影响网站正常运营
3. 不采集付费内容和非公开数据
4. 数据仅用于内部分析，不转售
```

## 参考文档

| 文档 | 内容 |
|------|------|
| `references/anti-crawler-detection.md` | **🆕 反爬机制识别与应对详解** |
| `references/amap-poi-collection.md` | 高德POI采集（推荐方案） |
| `references/dianping-waf-detection.md` | 大众点评WAF检测与人机协作 |
| `references/network-ghost-thinking.md` | 网络幽灵思维：API优先于爬虫 |
| `references/data-extraction-technique.md` | snapshot vs get-html 技术对比 |
| `references/dianping-data-collection.md` | 大众点评采集案例（含局限性） |

## 更新日志

### v1.3.0 (2026-06-30)
- ✨ 新增反爬机制快速诊断决策树
- ✨ 新增浏览器指纹检测与规避指南
- ✨ 新增JS混淆识别技巧
- ✨ 新增WAF软封检测方法
- ✨ 新增数据采集合规声明模板
- 📝 新增 `references/anti-crawler-detection.md` 详细文档
- 📝 更新SKILL.md，加入反爬诊断章节

### v1.2.0 (2026-06-29)
- ✨ 新增 `get-html.sh` 快速获取原始HTML
- ✨ 新增 `extract-data.sh` 结构化数据提取
- 📝 优化数据采集策略文档
- 📝 新增 `references/data-extraction-technique.md`

### v1.1.0 (2026-06-28)
- ✨ 新增网络幽灵思维
- ✨ 新增广义品类采集策略
- 📝 新增 `references/network-ghost-thinking.md`
- 📝 新增 `references/v1-v3-evolution.md`

### v1.0.0 (2026-06-27)
- 🎉 初始版本
- ✨ 基础浏览器自动化能力
- ✨ 会话管理、元素交互、截图等

## License

MIT

## 贡献

欢迎提交Issue和Pull Request！

## 作者

杨首位 (ysw)

## 相关项目

- [browser-skill](https://github.com/nous-research/browser-skill) - bsk CLI和浏览器扩展
- [anti-crawler-web-security](https://github.com/ysw-2025/anti-crawler-web-security) - 反爬虫与Web安全知识库（Skill）
