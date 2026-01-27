#!/bin/bash

DATE=$(date +"%Y-%m-%d")
LOG_DIR="log"
FILE="$LOG_DIR/$DATE.md"

mkdir -p $LOG_DIR

echo "# 📅 $DATE 日语学习记录" > $FILE
echo "" >> $FILE

# 从浏览器 localStorage 手动复制 JSON
echo "⚠️ 请从浏览器复制 localStorage 的 jp-daily-records 内容" >> $FILE
echo "" >> $FILE
echo "\`\`\`json" >> $FILE
pbpaste >> $FILE
echo "\`\`\`" >> $FILE

git add .
git commit -m "daily jp study log $DATE"
git push origin master

echo "## $DATE 日语学习记录" >> README.md
echo "- 记录文件：[log/$DATE.md](log/$DATE.md)" >> README.md
