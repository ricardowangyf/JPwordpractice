#!/bin/bash
set -e  # 出错时停止脚本

# ---------- 配置 ----------
DATE=$(date +"%Y-%m-%d")
LOG_DIR="log"
FILE="$LOG_DIR/$DATE.md"
README="README.md"
BRANCH_MAIN="main"
BRANCH_PAGES="gh-pages"

# ---------- 生成日志 ----------
mkdir -p "$LOG_DIR"
echo "# 📅 $DATE 日语学习记录" > "$FILE"
echo "" >> "$FILE"
echo "⚠️ 请从浏览器复制 localStorage 的 jp-daily-records 内容" >> "$FILE"
echo "" >> "$FILE"
echo '```json' >> "$FILE"
pbpaste >> "$FILE"
echo '```' >> "$FILE"

# ---------- 更新 README ----------
[ ! -f "$README" ] && echo -e "# 日语学习日志\n" > "$README"

LOG_LIST=$(ls -1t "$LOG_DIR")

TMP=$(mktemp) || exit 1
echo "# 日语学习日志" > "$TMP"
echo "" >> "$TMP"
echo "## 日志列表（最新在上）" >> "$TMP"
echo "" >> "$TMP"
for f in $LOG_LIST; do
  TITLE=$(basename "$f" .md)
  echo "- [$TITLE 日语学习记录](./$LOG_DIR/$f)" >> "$TMP"
done
echo "" >> "$TMP"
echo "📄 每天点击链接查看详细日志" >> "$TMP"
mv "$TMP" "$README"

# ---------- Git 提交 main 分支 ----------
git checkout $BRANCH_MAIN
git add "$LOG_DIR" "$README"
if git diff --cached --quiet; then
  echo "没有新日志，无需提交 main"
else
  git commit -m "daily jp study log $DATE"
  git push origin $BRANCH_MAIN
fi

# ---------- 构建 Vue 项目 ----------
echo "🛠 构建 Vue 项目..."
npm install
npm run build  # 生成 dist/

# ---------- 部署到 gh-pages ----------
echo "🚀 部署 dist/ 到 $BRANCH_PAGES 分支..."
# 临时切换到 gh-pages 分支
git worktree add /tmp/gh-pages $BRANCH_PAGES || git worktree add -B $BRANCH_PAGES /tmp/gh-pages

# 清空旧内容
rm -rf /tmp/gh-pages/*
# 复制新 dist 内容
cp -r dist/* /tmp/gh-pages/
cp -r log README.md /tmp/gh-pages/  # 可选，把日志也放到 Pages 上

cd /tmp/gh-pages
git add .
if git diff --cached --quiet; then
  echo "gh-pages 无新改动，无需提交"
else
  git commit -m "deploy Vue app & daily logs $DATE"
  git push origin $BRANCH_PAGES
fi

# 清理 worktree
cd -
git worktree remove /tmp/gh-pages

echo "✅ 部署完成，Vue 页面和日志已上线"
