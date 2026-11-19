#!/bin/bash
# ワークフロー用 Hook(セッション開始・再開・圧縮後に、進捗を Claude に思い出させる)
# 置き場所: .claude/hooks/show-progress.sh   実行権限: chmod +x
# 設定: `.claude/settings.json` の hooks の SessionStart(matcher: startup|resume|compact)
# SessionStart の標準出力は、Claude へのコンテキストとして追加される。
# 目的: 会話が圧縮・再開されても、docs/plan.md の未完了タスクと現在のブランチを見失わない。

cd "$CLAUDE_PROJECT_DIR" 2>/dev/null || exit 0

echo "【進捗メモ】"
echo "ブランチ: $(git branch --show-current 2>/dev/null || echo 'N/A')"

if [ -f docs/plan.md ]; then
  echo "未完了のタスク(docs/plan.md):"
  grep -E '^\s*- \[ \]' docs/plan.md | head -10
else
  echo "docs/plan.md はまだありません(/spec → /plan-tasks から始めます)。"
fi

exit 0
