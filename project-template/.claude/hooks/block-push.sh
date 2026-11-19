#!/bin/bash
# ワークフロー用 Hook(git push を確実にブロックする)
# 置き場所: .claude/hooks/block-push.sh   実行権限: chmod +x
# 設定: `.claude/settings.json` の hooks の PreToolUse(matcher: Bash, if: Bash(git push *))
# 目的: /commit は「push しない」と指示しているが、指示は強制ではない。Hook で確実に止める。
# 注意: git -C . push や別名など、すべての書き方は防げない。permissions.deny(`.claude/settings.json`)と併用する。
# 終了コード: exit 2 = ブロック(stderr が理由として Claude に返る)

input=$(cat)
command=$(jq -r '.tool_input.command // empty' <<<"$input")

if [[ "$command" == *"git push"* ]]; then
  echo "Blocked: git push は人が実行します。変更内容を報告して、push の手順を案内してください。" >&2
  exit 2
fi

exit 0
