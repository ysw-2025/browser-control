# 大众点评数据采集

## 采集目标
- 门店名称
- 人均价格
- 评价数
- 商圈位置

## 采集脚本（推荐：get-html + snapshot结合）

```bash
SID=$(bash session_start.sh)

# 导航
bash navigate.sh "https://www.dianping.com/search/keyword/2/10_火锅" "$SID"
bash wait.sh 2s

# 门店名称 - 用get-html（快）
HTML=$(bash get-html.sh "$SID")
echo "$HTML" | grep -oP '<h4>[^<]+</h4>' | grep -v "频道\|分类\|地点\|问题\|商户" | head -15

# 价格/评价 - 用snapshot（结构化）
bash snapshot.sh "$SID" | grep -E "heading.*店|人均.*￥|条评价"

bash session_stop.sh "$SID"
```

## 数据结构

```
门店名称(get-html): <h4>芈重山老火锅(五道口店)</h4>
人均价格(snapshot): link "人均 ￥109"
评价数(snapshot): link "21546 条评价"
```

## 快速对比：get-html vs snapshot

| 指标 | get-html | snapshot |
|------|----------|----------|
| 速度 | ~0.16s | ~0.35s |
| 门店名称 | ✅ 完整 | ✅ |
| 人均价格 | ❌ 需JS渲染 | ✅ |
| 评价数 | ❌ 需JS渲染 | ✅ |
| 适用场景 | 批量数据提取 | 需交互操作 |

## 注意事项

1. 大众点评需要登录才能看完整数据
2. 数据有反爬机制，采集速度不宜过快
3. 评价数≠真实流水，仅供参考
4. 数据可用于选址分析，但不能商用售卖

## 商业应用

**选址报告服务**：
- 定价：299-999元/份
- 交付：竞品分布图 + 价格带分析 + 商圈评估
- 价值：节省人工跑腿时间3-5天

**数据来源声明**：
- 数据来自大众点评公开信息
- 仅提供分析结论，不提供原始数据
- 仅供参考，选址决策需实地验证
