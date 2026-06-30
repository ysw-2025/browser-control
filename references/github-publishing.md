# GitHub发布流程 - 完整记录

## 问题1：git push超时

**现象**：`git push -u origin main` 命令超时（30s+）

**原因**：git需要认证，但Git Credential Manager弹出了GUI对话框，终端无法交互

**解决方案**：
1. 创建GitHub Personal Access Token（勾选repo权限）
2. 用token配置remote URL：
   ```bash
   git remote set-url origin "https://<token>@github.com/user/repo.git"
   git push -u origin main
   ```

## 问题2：gh auth login卡住

**现象**：`gh auth login --web` 超时

**原因**：gh CLI等待浏览器授权，但无法自动完成

**解决方案**：直接用token，不通过gh认证
   ```bash
   # 不需要gh auth login
   # 直接用token推送
   git remote set-url origin "https://<token>@github.com/user/repo.git"
   git push origin main
   ```

## 问题3：token格式

**正确格式**：`ghp_xxxxxxxxxxxxxxxxxxxx`

**错误用法**：在命令中直接写`ghp_AI...4RMj`（被截断）

**正确用法**：
   ```bash
   TOKEN="ghp_xxxxxxxxxxxxxxxxxxxx"
   git remote set-url origin "https://${TOKEN}@github.com/user/repo.git"
   ```

## 完整发布流程

```bash
# 1. 本地创建git仓库
cd your-skill
git init
git add .
git commit -m "feat: initial release"

# 2. 浏览器创建GitHub仓库
# 打开 https://github.com/new
# 填写Repository name、Description
# 点击"Create repository"

# 3. 创建Personal Access Token
# 打开 https://github.com/settings/tokens/new
# 勾选 repo 权限
# 生成后复制token

# 4. 推送代码
TOKEN="ghp_xxx..."
git remote add origin "https://${TOKEN}@github.com/user/repo.git"
git branch -M main
git push -u origin main
```

## 安全建议

推送完成后，立即删除token：
1. 打开 https://github.com/settings/tokens
2. 找到刚创建的token
3. 点击"Delete"
4. 重新创建一个有限权限的token（如果后续需要更新）

## 测试清单

发布前必须从干净状态测试：
```bash
# 1. 克隆到临时目录
cd /tmp && git clone https://github.com/user/repo.git test-skill
cd test-skill

# 2. 测试核心功能
bash scripts/session_start.sh
bash scripts/navigate.sh "https://www.baidu.com" "$SID"
bash scripts/snapshot.sh "$SID" | head -5
bash scripts/session_stop.sh "$SID"

# 3. 确认所有脚本有执行权限
ls -la scripts/*.sh

# 4. 确认README有完整的依赖说明
head -30 README.md | grep "安装依赖"
```

## 常见错误

### 错误1：README中仓库地址是YOUR_USERNAME

**修复**：发布前把README中的`YOUR_USERNAME`替换成实际用户名

### 错误2：scripts/目录下的脚本没有执行权限

**修复**：
```bash
chmod +x scripts/*.sh
git update-index --chmod=+x scripts/*.sh
git commit -m "fix: add execute permission"
git push origin main
```

### 错误3：SKILL.md中提到bsk但没有安装说明

**修复**：在README的"快速开始" section明确写：
- 浏览器扩展安装方法
- bsk CLI安装方法
- 验证安装命令
