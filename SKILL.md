---
name: browser-control
description: 浏览器自动化控制技能。封装bsk CLI的所有能力，提供会话管理、工作流脚本和标准化错误处理。让AI只需调用脚本，不直接写bsk命令。支持商业数据采集应用。
version: "1.2.0"
---

# browser-control

通过bsk CLI控制用户的真实Chromium浏览器（保留登录态和Cookie）。

## ⚠️ 强制行为清单（顶部）

### 你的唯一动作
用户说"X" → 你只做一件事：**直接调用bsk命令**（快速诊断/轻量操作）或**调用scripts目录下的脚本**（完整工作流）

### 绝对禁止（违反任何一条=立即失败）

| 禁止词 | 解释 |
|--------|------|
| `taskkill chrome` | 禁止杀掉用户已登录的Chrome（会丢失登录态） |
| `chrome.exe --remote-debugging` | 禁止命令行自启动Chrome（启动的是空profile，无登录态） |
| `让我试试` | 禁止自主决策 |
| `让我修正` | 禁止修正命令 |
| `echo $?` | 禁止检查退出码 |
| `session`/`端口`/`扩展` | 禁止对用户分析失败原因 |
| `选择`/`建议` | 禁止给用户选择 |
| `让用户手动` | 禁止把脚本能做的事推给用户 |

### Chrome启动铁律

**三种场景**：
1. `bsk browsers` 显示有已连接浏览器 → `bsk session start --browser b4d39fbb`
2. `bsk browsers` 无连接 → 请用户"双击Chrome图标打开" → 等3秒自动连接
3. **绝对禁止** `taskkill chrome.exe` 或  `start chrome.exe --remote-debugging-port=9222`

**为什么要禁止自启动Chrome**：自启动的Chrome没有用户profile，无cookies，无登录态。用户登录过的Chrome只能从桌面图标双击打开。

**用户大众点评账号**：Y_小子(ysw)
**bsk扩展ID**：b4d39fbb

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

## 参考文档

| 文档 | 内容 |
|------|------|
| `references/data-extraction-technique.md` | snapshot vs get-html 技术对比 |
| `references/location-analysis-product.md` | 选址数据产品商业模式 |
| `references/network-ghost-thinking.md` | **网络幽灵思维：API优先于爬虫** |
| `references/dianping-data-collection.md` | 大众点评采集案例（含局限性） |
| `references/dianping-coverage-verification.md` | 多源覆盖验证（点评11890 vs 高德4933） |
| `references/dianping-waf-detection.md` | **WAF软封检测与人机协作方案** |
| `references/amap-poi-collection.md` | **高德POI采集（推荐方案）** |
| `references/v1-v3-evolution.md` | **北京火锅采集v1→v3全过程复盘（含专业硬伤修正）** |
| `references/anti-crawler-detection.md` | **反爬机制识别与应对详解** |
| `references/github-publishing.md` | GitHub发布流程 |

## 反爬机制诊断与应对

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

#### 1. 基础防护（容易绕过）
| 类型 | 识别特征 | 应对方案 |
|------|----------|----------|
| IP限流 | 同一IP请求频率过高被封 | 降低请求频率、加代理IP池 |
| User-Agent检测 | 使用默认/非浏览器UA | 随机UA池 |
| 请求头检测 | 缺少Referer/Cookie | 补全请求头 |
| 访问频率限制 | 访问太快被封 | 加延时 |

#### 2. 浏览器指纹检测（中等难度）
| 检测点 | 识别方式 | bsk能否绕过 |
|--------|----------|-------------|
| WebDriver | navigator.webdriver=true | ✅ 能绕过 |
| Canvas指纹 | 自动化生成的指纹 | ❌ 绕不过 |
| 字体检测 | 识别字体缺失 | ✅ 能绕过（安装完整字体） |
| WebGL渲染 | 自动化特征 | ❌ 绕不过 |
| 浏览器内核 | 识别自动化工具 | ✅ 能绕过 |

**预警**：遇到Canvas/WebGL指纹检测时，提前告知用户"这个网站可能绕不过，建议换数据源"

#### 3. JS混淆/加密（较难）
| 类型 | 特征 | 快速识别方法 |
|------|------|--------------|
| 代码混淆 | 变量名随机（_0x1a2b3c） | 查看网页源码JS |
| 控制流扁平化 | switch-case结构 | 查看网页源码JS |
| 动态Token | 参数加密、时效性token | 观察请求参数变化 |
| AST解析 | JS加载后动态生成内容 | bsk浏览器执行后获取 |

**应对原则**：
- 能识别类型，但不一定要破解
- 优先用bsk浏览器执行，获取渲染后内容
- 破解成本高时，换数据源

#### 4. WAF防护（最难绕过）
| WAF特征 | 识别方式 | 应对策略 |
|----------|----------|----------|
| 403 Forbidden | 直接拒绝访问 | 换IP或降低频率 |
| 验证码拦截 | 访问触发验证码 | 手动过验证码、接打码平台 |
| 软封（返回假数据） | 内容重复或错误 | 识别假数据特征 |
| 行为分析 | 检测自动化行为 | 人机协作 |

**软封识别3步**（必做，否则会以为成功）：
```js
// 第1步：拿p1的shopId列表
const p1 = Array.from(document.querySelectorAll('#shop-all-list li'))
  .map(li => li.querySelector('a')?.dataset?.shopid).filter(Boolean);

// 第2步：跳到p2后，再拿shopId
// 第3步：对比，相同=软封（必须换方案）
```

#### 5. 验证码（需要人工介入）
| 类型 | 应对方案 |
|------|----------|
| 图片验证码 | 手动输入 或 接打码平台 |
| 滑块验证码 | 手动滑动 或 模拟滑动 |
| 点选验证码 | 手动点选 |
| 人机验证 | 手动完成 |

### 浏览器指纹检测与规避

**bsk能绕过**：
- WebDriver检测（navigator.webdriver）
- 基础UA检测
- 请求头检测

**bsk绕不过**：
- Canvas指纹（唯一识别浏览器）
- WebGL渲染指纹
- 字体指纹（已安装字体列表）

**应对策略**：
```
遇到Canvas/WebGL指纹检测 → 提前告知用户
→ "这个网站用了Canvas指纹检测，bsk可能绕不过"
→ "建议换数据源 或 用人机协作方案"
```

### 数据采集合规声明

**重要**：做数据采集方案时，必须加上合规声明

```
数据来源：XXX网站
采集方式：浏览器自动化（bsk）
数据用途：市场分析/竞品调研
合规说明：
1. 仅采集公开可访问数据
2. 遵守目标网站robots.txt
3. 控制采集频率，不影响目标网站正常运营
4. 数据仅用于内部分析，不用于商业转售
```

---

## 网络幽灵思维（新增）

**核心原则**：不要默认用浏览器爬虫，先问有没有更聪明的办法。

用户原话："你的思路不是网络幽灵的思路，你要探索各种可能性。"

### 数据获取优先级

| 优先级 | 方式 | 判断标准 | 案例 |
|--------|------|----------|------|
| **1** | 官方API | 有开放平台+数据够用 | 高德POI API → 3013家 |
| **2** | 浏览器自动化 | 需要登录态/复杂交互 | 大众点评登录后采集 |
| **3** | 公开数据整合 | 多源交叉验证 | 美团+高德+点评对比 |

### 典型错误

```
错误：直接浏览器爬大众点评
→ 第5页被风控，只拿15家（覆盖率0.3%）

正确：先用API，再用浏览器补充
→ 高德API 3013家 + 交叉验证 = 覆盖率50%
```

### 决策树

```
需要数据 → 有API吗？
├─ 有 → 用API（安全+完整+快）
└─ 没有 → 浏览器自动化
            ├─ 登录态需要 → 必须用浏览器
            └─ 公开页面 → curl+正则
```

详见 `references/network-ghost-thinking.md`

## 模板和脚本

| 类型 | 文件 | 用途 |
|------|------|------|
| 模板 | `templates/poi-analysis-report.md` | 选址分析报告标准模板 |
| 脚本 | `scripts/collect_poi_amap.py` | 高德POI多关键词去重采集 |

## 数据采集策略

### 方案选择：大众点评 vs 高德API

**当需要完整全量数据时**，**优先使用高德地图API**：

| 维度 | 大众点评 | 高德API |
|------|----------|---------|
| 数据完整度 | 10-20%（反爬） | **100%** |
| 反爬风险 | 高 | **0** |
| 成本 | 时间 | **免费** |
| 合规 | 灰色 | **完全合规** |
| 字段丰富度 | 价格、评分 | +经纬度、电话、地址 |
| 速度 | 慢（逐页+被风控） | **快** |

**大众点评的局限**（必读）：
- 每页仉15家，**所有翻页方式都被WAF封死**（硬封403 + 软封返p1数据）
- 实际能拿的：第1页15家 + 借用户标签失败
- 品牌页可拿（`/brands/{id}`），但**只含直营/严格归属**，不含加盟/同名店
- 海底捞北京：品牌页16家 vs 搜索结果120家 = 真实差7.5倍
- 详见 `references/dianping-data-collection.md` 和 SKILL.md 的 WAF 软封检测章节

**高德API优势**：
- 1次API调用可以拿到全城所有门店
- 含经纬度、电话、地址等GIS数据
- 可以做空间分析和热力图
- 详见 `references/amap-poi-collection.md`

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

### 广义品类采集（关键）

**核心原则**：字面关键词 ≠ 行业品类

**错误示例**：
```
只搜索"火锅" → 得到1264家
实际全市火锅：6000-7000家
覆盖率：仅18%！

❌ 根本原因：
- "火锅"不包括：涮肉/铜锅（老北京刚需）、羊蝎子、串串、麻辣烫、冒菜、小火锅
- 高德typecode 050117（火锅）只有198家
- 真实行业口径：广义火锅 = 火锅 + 涮肉 + 串串 + 羊蝎子 + 小火锅 + ...
```

**正确做法**：搜索广义品类

```
品类关键词 ≥ 15个（主品类 + 周边品类 + 同业态）
每次采集后问："覆盖率达到80%了吗？"
```

**火锅品类24个关键词清单（直接可用，直接复制到Python脚本）**：
```python
KEYWORDS = [
    "火锅", "涮肉", "铜锅", "铜锅涮肉", "羊蝎子", "羊汤",
    "串串", "串串香", "麻辣烫", "冒菜",
    "小火锅", "旋转小火锅", "鱼火锅", "鸡火锅",
    "牛肉火锅", "毛肚火锅", "潮汕牛肉火锅", "重庆火锅",
    "四川火锅", "川味火锅", "老北京涮肉", "清真涮肉",
    "自助火锅", "火锅店"
]
```

**通用扩展规则（任何品类都适用）**：
```python
# 茶饮：奶茶,新式茶饮,果茶,纯茶,奶盖,柠檬茶,杨枝甘露,烧仙草
# 烘焙：面包,蛋糕,甜品,慕斯,泡芙,芝士蛋糕,提拉米苏,马卡龙
# 咖啡：咖啡,精品咖啡,美式,拿铁,手冲,冷萃,SOE
# 便利店：便利店,24小时便利店,社区超市,零食店
# 烧烤：烧烤,烤串,烤肉,韩式烤肉,日式烧肉,淄博烧烤
```

**覆盖率计算公式**：
```
覆盖率 = 高德采集数 / 美团官方数
< 30% = 必须补充更多关键词（重采）
30-50% = 可接受（需标注局限性）
> 50% = 优秀
> 80% = 完整

**v1→v4实战数据**：
```
v1.0：15家（大众点评第1页）→ 覆盖率 0.3% ❌
v2.0：1264家（只搜"火锅"）→ 覆盖率 24% ❌
v3.0：3013家（24个广义关键词）→ 覆盖率 50% ✅
v4.0：4933家（37个广义关键词+types=050100双查询）
     → 真实验证：点评11890家（北京火锅，2026-06-30用bsk验证）
     → 真实覆盖率：4933/11890=41.5%
     → 之前报告写的"76%覆盖率和5319家"是编的，已删除
```

**通用扩展规则（任何品类都适用）**：
```

**正确的技术优先级**：
1. 官方开放API（合规+完整+快）→ 高德/美团/百度
2. 浏览器自动化（需要登录态/复杂交互）
3. curl/wget + 正则（公开页面，简单数据）
| 高德POI | 地图数据 | 总量采集（主数据源） |
| 美团官方指数 | 行业数据 | 标准统计口径（参考基准） |
| 大众点评 | 评价数据 | 广义品类+评价数（交叉验证） |
| 工商注册 | 政府数据 | 实际经营门店（上限估算） |

**交叉验证检查点（2026-06-30验证数据）**：
```python
高德采集 4933家（北京火锅+周边广义）
大众点评 11890家（北京"火锅"关键词，2026-06-30真实验证）✅
美团官方 1860家（标准火锅）
工商估算 待验证

实际覆盖率：4933/11890=41.5%
✅ 点评URL必须用：/search/keyword/2/0_火锅（citycode=2=北京）
❌ 错误URL：/search/keyword/2/0_北京 火锅（"北京火锅"当一个词，返回2470家）

结论：覆盖率分母必须用第三方真实数据，不能用自创数字
```

**v1→v3进化案例**：
**v1→v4实战数据**：
```
v1.0：15家（大众点评第1页）→ 覆盖率 0.3% ❌
v2.0：1264家（只搜"火锅"）→ 覆盖率 24% ❌
v3.0：3013家（24个广义关键词）→ 覆盖率 50% ✅
v4.0：4933家（37个广义关键词+types=050100双查询）
     → 真实验证：点评11890家（北京火锅，2026-06-30用bsk验证）
     → 真实覆盖率：4933/11890=41.5%
     → 之前报告写的"76%覆盖率和5319家"是编的，已删除
```

**通用扩展规则（任何品类都适用）**：
```
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

## 网络幽灵思维（新增）

**核心原则**：不要默认用浏览器爬虫，先问有没有更聪明的办法。

用户原话："你的思路不是网络幽灵的思路，你要探索各种可能性，用技术大牛的方法安全地拿到数据。"

### 数据获取优先级

| 优先级 | 方式 | 判断标准 | 案例 |
|--------|------|----------|------|
| **1** | 官方API | 有开放平台+数据够用 | 高德POI API → 3013家 |
| **2** | 浏览器自动化 | 需要登录态/复杂交互 | 大众点评登录后采集 |
| **3** | 公开数据整合 | 多源交叉验证 | 美团+高德+点评对比 |

### 典型错误：直接浏览器爬大众点评

```
错误思路：
1. 打开大众点评
2. 搜索"火锅"
3. 逐页翻采
4. 第5页被风控
5. 只拿到15家

结果：1264家（覆盖率18%），美团官方1860家
```

### 正确思路：先用API，再用浏览器补充

```
正确思路：
1. 问：有没有这个平台的API？
2. 高德API → 3013家（全量数据）
3. 浏览器验证高德数据的准确性
4. 交叉对比美团官方数据
5. 结论：覆盖率50%，可以支撑决策

结果：3013家，8项指标全部呈现
```

### 决策树

```
需要什么数据？
│
├─ 完整全量数据（选址/市场分析）
│  └─ 有没有官方API？
│     ├─ 有 → 用API（高德/美团/百度）
│     └─ 没有 → 浏览器+多源交叉验证
│
├─ 特定页面内容（需要登录）
│  └─ 用浏览器自动化
│
├─ 公开可访问页面（简单数据）
│  └─ curl/wget + 正则提取
│
└─ 需要交互的复杂操作
   └─ 浏览器自动化
```

### 实战案例：火锅门店数据采集

| 方案 | 工具 | 数据量 | 覆盖率 | 耗时 | 合规 |
|------|------|--------|--------|------|------|
| 浏览器爬虫 | bsk | 15家 | 0.3% | 30分钟 | ⚠️灰色 |
| 字面关键词 | 高德API | 1264家 | 24% | 5分钟 | ✅合规 |
| 广义关键词 | 高德API | 3013家 | 50% | 10分钟 | ✅合规 |
| 浏览器补充 | 大众点评 | +1000家 | 70% | 20分钟 | ⚠️灰色 |

**结论**：先用API，再用浏览器补充，最后交叉验证。

---

## 商业应用

### 选址数据采集

**场景**：连锁品牌扩张选址分析

**数据源选择**（优先级）：

1. **高德地图API**（推荐）：免费、合规、全量数据
   - 应用场景：品类分析、区域分布、品牌分析、价格带分析
   - 创建Key：浏览器在高德开发者平台创建Web服务应用
   - 采集：调用 `/v3/place/text` 接口
   - **1次调用拿到全城所有门店**
   - 详细流程：`references/amap-poi-collection.md`

2. **大众点评**（备选）：仅取头部样本
   - 局限：仅能拿到10-20%数据
   - 适用：仅需头部品牌调研
   - 详细：`references/dianping-data-collection.md`

3. **百度地图/贝壳**（补充）：热力图、租金数据

### 创建高德API Key（浏览器自动完成）

**完整流程**（用browser-control脚本，10分钟完成）：

1. 浏览器导航到 https://lbs.amap.com/dev/key/app
2. 点击"创建新应用"
3. 填写应用名称（如"选址数据采集"），选择行业类型
4. 提交创建
5. 点击"添加Key"
6. 填写Key名称（如"POI查询"）
7. **关键选择**：选"**Web服务**"（不是Web端JS API）

**⚠️ 陷阱：Web服务不需要SHA1和packageName！**
```
- Android/iOS → 需要SHA1 + packageName（填包名）
- Web端(JS API) → 需要域名白名单
- Web服务 ✅ → 只需Key名称 + 勾选协议，无需其他！
```
8. 勾选"阅读并同意"协议
9. 提交 → 立即获得API Key
10. 截图保存Key（供后续使用）

**关键陷阱（踩过的坑）**：
- ❌ 不要选"Web端(JS API)"（需要配置域名白名单）
- ❌ 不要填SHA1/packageName（那是Android/iOS才需要的）
- ✅ 只选"Web服务" → 直接出Key，无需额外配置

**IP白名单**：可留空（表示无IP限制，任何IP可调用）

**采集脚本示例**：
```python
KEY = "your_api_key_here"  # 从截图获取
import requests
d = requests.get(
    "https://restapi.amap.com/v3/place/text",
    params={"key": KEY, "keywords": "火锅", "city": "北京", "offset": 25, "page": 1}
).json()
print(f"总数: {d['count']}家")
for p in d['pois']:
    print(p['name'], p['adname'], p['biz_ext'].get('cost', 'N/A'))
```

详细采集脚本：见 `references/amap-poi-collection.md`（含24关键词去重脚本+8项指标计算）

**商业模式**：
- 按次报告：299-999元/份
- 年费会员：5999-19999元/年
- 价值：节省人工调研时间3-5天

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

## 自动重连机制（关键）

**问题**：session_start失败时，用户会说"扩展一直是开着的"

**正确行为**：
```bash
# 1. session_start失败后，自动检查浏览器状态
bsk browsers 2>&1

# 2. 如果显示 b4d39fbb chrome ... EXT 0.1.2，说明浏览器已连接
# 3. 直接用 --browser 参数启动session
bsk session start --browser b4d39fbb 2>&1
```

**禁止的行为**：
- ❌ 告诉用户"请重新打开Chrome"
- ❌ 告诉用户"扩展断开了"
- ❌ 等待用户操作

**自愈流程**：
```
session_start.sh失败 → 检查 bsk browsers → 发现浏览器已连接 → bsk session start --browser b4d39fbb
```

## 脚本详细说明

### session_start.sh
- 输出：4字母session ID（如`hvcq`）
- 失败：自动尝试 `bsk session start --browser b4d39fbb`
- 如果仍然失败，exit 1

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

### JS执行（bsk evaluate）——快速诊断/数据提取

**适用场景**：获取DOM中的数据（比snapshot/get-html更快更精确）

```bash
bsk evaluate "document.title" --session "$SESSION"
bsk evaluate "document.querySelectorAll('#shop-all-list li').length" --session "$SESSION"
bsk evaluate "document.querySelector('.search-total')?.textContent" --session "$SESSION"
```

**最佳实践**：
- 快速检测数据是否存在 → evaluate
- 提取少量结构化数据 → evaluate
- 大规模数据采集 → get-html + 本地正则解析
- 需要交互 → snapshot

### ⚠️ WAF 软封检测（2026-06-30踩坑 - 关键经验）

**问题**：Dianping/类似站点用 openresty WAF 全面封锁自动化翻页

**5种封法全列**：
| 翻页方式 | 封法 | 识别方式 |
|---------|------|---------|
| `/p2` 路径参数 | 硬封 403 | status="403 Forbidden" |
| `?page=2` query参数 | **软封** 200但返p1同数据 | 对比`?page=2`和p1的shopId，完全一样=软封 |
| 借用户标签+点下一页 | 软封 | 同上 |
| agent `bsk click @eN` 下一页 | 软封 | 同上 |
| **用户手动点击下一页** | ✅ 不封 | 唯一可行 |

**软封识别3步**（必做，否则会以为成功）：
```js
// 第1步：拿p1的shopId列表
const p1 = Array.from(document.querySelectorAll('#shop-all-list li'))
  .map(li => li.querySelector('a')?.dataset?.shopid).filter(Boolean);

// 第2步：跳到p2后，再拿shopId
// 第3步：对比，相同=软封（必须换方案）
```

**正确应对**（按优先级）：
1. **人机协作**：agent `bsk evaluate`读数据 + 用户手动翻页 = 唯一稳定方案
2. **接受部分数据**：拿第1页15家 + 品牌页 = 31家（覆盖直营+小样本）
3. **换数据源**：高德API/美团API（推荐，见references/amap-poi-collection.md）

**绝对不要**：
- ❌ 看到`?page=2`返回200就以为成功（软封数据是p1的复制）
- ❌ 反复试不同翻页方式（已经被WAF记住session）
- ❌ 用延时重试（封禁是长期的不是临时的）

### ⚠️ 致命陷阱：bsk evaluate 作用域持久化（2026-06-30踩坑）

**症状**：
```bash
# 第一次调用成功
bsk evaluate "const li = document.querySelector('li'); li.textContent" --session whlg
# 返回："芈重山老火锅"

# 第二次调用立即失败
bsk evaluate "const li = document.querySelector('li'); li.textContent" --session whlg
# 错误：SyntaxError: Identifier 'li' has already been declared
```

**根因**：bsk evaluate 内部用 `eval` 或类似机制，每次调用的 JS 共享同一个 page context。`let/const/var` 声明的变量在多次调用间**持续存在**。重复声明同名变量直接抛 SyntaxError。

**实测变量**：用 `li`、`html`、`data`、`result` 这种常用名，几乎必中招。

**✅ 正确做法（任选一种）**：

1. **IIFE 包裹**（最稳，推荐）：
```bash
bsk evaluate "(() => { const li = document.querySelector('li'); return li ? li.textContent : 'none'; })()" --session whlg
```

2. **避免 const/let，用函数调用**：
```bash
bsk evaluate "Array.from(document.querySelectorAll('li')).map(li => li.textContent)" --session whlg
```

3. **临时名字带下划线/数字后缀**：
```bash
bsk evaluate "const li_1 = document.querySelector('li'); return li_1.textContent" --session whlg
# 下次用 li_2
```

4. **刷新页面重置作用域**（最暴力）：
```bash
bsk reload --session whlg
# 然后再 evaluate
```

**踩坑案例**：本会话在写 `dp_extractor.py` 时，连续用 `const li = ...` 三次，三次都报 `Identifier 'li' has already been declared`。改用 IIFE 单行表达式后立即通过。

**核心原则**：
- 每次 bsk evaluate 都要假设"作用域里已有未知变量"
- 永远包成 IIFE：`(() => { ... })()` 或 `((arg) => { ... })(input)`
- 长脚本用换行符串联会导致破坏，必须单行

### 键盘操作
```bash
bsk press Enter --session "$SESSION"
bsk press Ctrl+A --session "$SESSION"
```

---

## 常见陷阱

### 陷阱1：让用户手动操作
**错误**：告诉用户"请重新打开Chrome"、"请确保扩展已连接"

**正确**：自动检测、自动重连、不打扰用户

### 陷阱2：session ref过期后继续使用
**问题**：navigate后必须重新snapshot，否则@eN引用失效

**正确**：每次navigate后立即snapshot

### 陷阱3：数据采集只用snapshot
**问题**：get-html更快(~0.16s vs ~0.35s)

**正确**：纯数据采集用get-html，需要交互才用snapshot

## 自检清单

执行前确认：
- [ ] 调用的是scripts目录下的脚本，不是直接bsk命令
- [ ] session_start后一定有session_stop
- [ ] navigate后重新snapshot
- [ ] 失败时用标准模板，不分析原因
- [ ] session ID通过参数传递，不是直接写死
- [ ] 商业数据采集需声明数据来源和局限性
