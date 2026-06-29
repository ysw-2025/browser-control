# bsk CLI 测试记录

## 测试环境

- bsk版本: 0.1.5
- 协议版本: 1.0
- 操作系统: Windows 10
- 浏览器: Chromium (Chrome)

## 功能测试结果

### 会话管理 ✓

```bash
# 启动会话 - 返回4字母ID
bsk session start
# 输出: hvcq

# 停止会话
bsk session stop hvcq

# 列出活动会话
bsk session list
```

### 页面观察 ✓

```bash
# snapshot - 获取ARIA树和@eN引用
bsk snapshot --session <id>

# screenshot - 截图
bsk screenshot --session <id> --out path.png

# get-html - 原始HTML（高token消耗，仅snapshot不足时用）
bsk get-html --session <id>
```

### 导航 ✓

```bash
# 导航（自动等待load）
bsk navigate <url> --session <id>

# 后退/前进
bsk navigate-back --session <id>
bsk navigate-forward --session <id>

# 刷新
bsk reload --session <id>
```

### 交互 ✓

```bash
# 点击
bsk click @e5 --session <id>

# 填写输入框
bsk fill @e5 --value "文本" --session <id>

# 下拉框选择
bsk select @e5 --value "option_value" --session <id>

# 键盘按键
bsk press Enter --session <id>
bsk press "Ctrl+A" --session <id>
```

### 标签管理 ✓

```bash
# 创建标签
bsk tab create --session <id> --url <url>

# 列出标签
bsk tab list --session <id> --scope all|agent|user

# 借用用户标签
bsk tab borrow <tab-id> --session <id>
bsk tab return <tab-id> --session <id>

# 选择/关闭标签
bsk tab select <tab-id> --session <id>
bsk tab close <tab-id> --session <id>
```

### 高级 ✓

```bash
# JS执行
bsk evaluate "document.title" --session <id>

# 等待
bsk wait-ms 2s

# 等待导航完成
bsk wait-for-navigation --session <id> --timeout 10s
```

## 错误代码

| 退出码 | 含义 | 处理 |
|--------|------|------|
| 0 | 成功 | 继续 |
| 1 | 用户错误（参数、session无效、ref过期） | 检查参数，重试 |
| 2 | 协议错误（服务不可达、IPC失败） | bsk doctor检查 |
| 3 | 浏览器/CDP执行失败 | 重试，简化选择器 |
| 4 | 超时 | 增加timeout参数 |
| 5 | 版本不匹配 | 升级bsk |

## 已知限制

1. snapshot的@eN引用在页面导航后失效，必须重新snapshot
2. 用户标签借用后必须归还（或在session stop时自动归还）
3. wait-for-navigation在高并发页面可能不稳定
4. evaluate命令不能在敏感页面（银行、密码管理器）使用

## 观测优先级

1. snapshot - 默认选择，用于页面理解和交互
2. get-html - 仅当snapshot不足以获取隐藏DOM/元数据时
3. screenshot - 仅当需要视觉布局、canvas/图片内容时

## 环境检查

```bash
# 连接状态
bsk status

# 诊断
bsk doctor

# 列出浏览器
bsk browsers
```
