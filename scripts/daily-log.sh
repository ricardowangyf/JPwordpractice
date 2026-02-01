#!/bin/bash
set -euo pipefail  # 出错停止，未定义变量报错，管道出错也停止

# ---------------- 参数支持 ----------------
CUSTOM_COMMIT_MSG=${1:-""}

# ---------------- 基本配置 ----------------
DATE=$(date +"%Y-%m-%d")
TIME=$(date +"%H:%M")
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)   # 脚本所在目录
PROJECT_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)  # 项目根目录

LOG_DIR="$PROJECT_ROOT/log"
FILE="$LOG_DIR/$DATE.md"
README="$PROJECT_ROOT/README.md"

# 获取当前分支
CURRENT_BRANCH=$(git -C "$PROJECT_ROOT" rev-parse --abbrev-ref HEAD || echo "master")

# 如果用户没自定义 commit message，使用默认
GIT_COMMIT_MSG=${CUSTOM_COMMIT_MSG:-"Add daily log for $DATE"}

# ---------------- 创建日志目录 ----------------
mkdir -p "$LOG_DIR"

# ---------------- 创建或追加日志 ----------------
if [ ! -f "$FILE" ]; then
    cat > "$FILE" <<EOF
# Daily Log - $DATE

- 今日任务：
- 今日总结：
EOF
    echo "✅ 日志文件已创建：$FILE"
else
    cat >> "$FILE" <<EOF

## 新增记录 $TIME
- 今日任务：
- 今日总结：
EOF
    echo "📝 日志文件已存在，追加新条目：$FILE"
fi

# ---------------- 更新 README.md ----------------
if [ -f "$README" ]; then
    # 避免重复添加
    if ! grep -q "$DATE" "$README"; then
        echo "- [$DATE]($LOG_DIR/$DATE.md)" >> "$README"
        echo "✅ README.md 已更新"
    fi
fi

# ---------------- Git 操作 ----------------
if git -C "$PROJECT_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    # 确保所有更改都被追踪，包括删除文件
    git -C "$PROJECT_ROOT" add -A

    # 只有有变化时才 commit
    if ! git -C "$PROJECT_ROOT" diff --cached --quiet; then
        git -C "$PROJECT_ROOT" commit -m "$GIT_COMMIT_MSG"
        git -C "$PROJECT_ROOT" push origin "$CURRENT_BRANCH"
        echo "✅ 日志已提交并推送到 $CURRENT_BRANCH"
    else
        echo "⚠️ 没有新的更改需要提交"
    fi
else
    echo "❌ 当前目录不是 Git 仓库，跳过提交"
fi
