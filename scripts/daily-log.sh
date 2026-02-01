#!/bin/bash
set -e

# ---------------- 配置 ----------------
DATE=$(date +"%Y-%m-%d")
# 脚本所在目录
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PROJECT_DIR="$SCRIPT_DIR/.."
LOG_DIR="$PROJECT_DIR/log"
README="$PROJECT_DIR/README.md"
BRANCH="master"   # 根据你的仓库实际分支改成 master 或 main
FILE="$LOG_DIR/$DATE.md"

mkdir -p "$LOG_DIR"

# ---------------- 生成当天日志 ----------------
echo "# 📅 $DATE 日语学习记录" > "$FILE"
echo "" >> "$FILE"
echo "```json" >> "$FILE"

# 只在本地 Mac 才用 pbpaste，否则输出空对象
if command -v pbpaste >/dev/null 2>&1; then
  pbpaste >> "$FILE"
else
  echo "{}" >> "$FILE"
fi

echo "```" >> "$FILE"

# ---------------- 更新 README ----------------
TMP=$(mktemp)
echo "# 日语学习日志" > "$TMP"
echo "" >> "$TMP"
echo "## 日志列表（最新在上）" >> "$TMP"
echo "" >> "$TMP"

for f in $(ls -1t "$LOG_DIR"); do
  name=$(basename "$f" .md)
  echo "- [$name 日语学习记录](./log/$f)" >> "$TMP"
done

mv "$TMP" "$README"

# ---------------- Git 提交 ----------------
cd "$PROJECT_DIR"

# 确保分支存在
if git show-ref --verify --quiet refs/heads/$BRANCH; then
  git checkout $BRANCH
else
  git checkout -b $BRANCH
fi

git add "$LOG_DIR" "$README"

# commit 信息：命令行参数优先，否则用默认
if [ $# -gt 0 ]; then
  COMMIT_MSG="$*"
else
  COMMIT_MSG="daily jp study log $DATE"
fi

# 检查是否有变动
if git diff --cached --quiet; then
  echo "📭 今天没有新内容"
else
  git commit -m "$COMMIT_MSG"
  git push origin $BRANCH
  echo "✅ 日志已提交到 $BRANCH"
fi
