#!/bin/bash
set -euo pipefail  # 出错停止，未定义变量报错，管道出错也停止

# ---------------- 参数 ----------------
CUSTOM_COMMIT_MSG=${1:-""}

# ---------------- 基本配置 ----------------
DATE=$(date +"%Y-%m-%d")
TIME=$(date +"%H:%M")
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PROJECT_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)

LOG_DIR="$PROJECT_ROOT/log"
FILE="$LOG_DIR/$DATE.md"
README="$PROJECT_ROOT/README.md"

# 固定分支 main
CURRENT_BRANCH="master"

GIT_COMMIT_MSG=${CUSTOM_COMMIT_MSG:-"Daily log for $DATE"}

# ---------------- Git 操作 ----------------
if git -C "$PROJECT_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git -C "$PROJECT_ROOT" add -A

    # 如果有改动就 commit
    if ! git -C "$PROJECT_ROOT" diff --cached --quiet; then
        git -C "$PROJECT_ROOT" commit -m "$GIT_COMMIT_MSG"
        git -C "$PROJECT_ROOT" push origin "$CURRENT_BRANCH"
        echo "✅ 日志已提交并推送到 $CURRENT_BRANCH"
    else
        echo "⚠️ 没有新的更改需要提交"
    fi
else
    echo "❌ 当前目录不是 Git 仓库"
fi
