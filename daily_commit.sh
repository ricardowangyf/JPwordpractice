#!/bin/bash

# ---------- 配置 ----------
DATE=$(date +"%Y-%m-%d")
LOG_DIR="log"
FILE="$LOG_DIR/$DATE.md"
README="README.md"

# ---------- 创建日志文件 ----------
mkdir -p $LOG_DIR

echo "# 📅 $DATE 日语学习记录" > $FILE
echo "" >> $FILE
echo "⚠️ 请从浏览器复制 localStorage 的 jp-daily-records 内容" >> $FILE
echo "" >> $FILE
echo "\`\`\`json" >> $FILE
pbpaste >> $FILE
echo "\`\`\`" >> $FILE

# ---------- 更新 README.md ----------
# 如果 README 不存在就创建
if [ ! -f $README ]; then
  echo "# 日语学习日志" > $README
  echo "" >> $README
fi

# 收集 log 文件，按日期倒序排列
LOG_LIST=$(ls -1 $LOG_DIR | sort -r)

# 创建临时文件
TMP=$(mktemp)
echo "# 日语学习日志" > $TMP
echo "" >> $TMP
echo "## 日志列表（最新在上）" >> $TMP
echo "" >> $TMP

for f in $LOG_LIST; do
  # 提取日期作为标题
  TITLE=$(basename "$f" .md)
  echo "- [$TITLE 日语学习记录](./$LOG_DIR/$f)" >> $TMP
done

echo "" >> $TMP
echo "📄 每天点击链接查看详细日志" >> $TMP

# 替换 README
mv $TMP $README

# ---------- Git 操作 ----------
git add .
if git diff --cached --quiet; then
  echo "没有新改动，无需提交"
else
  git commit -m "daily jp study log $DATE"
  git push origin master
fi

echo "✅ 日志生成并提交完成：$FILE"