#!/bin/bash
# Hooks スクリプトのテンプレート(PreToolUse で危険なコマンドをブロックする)
# 置き場所: .claude/hooks/block-dangerous.sh
# 実行権限: chmod +x .claude/hooks/block-dangerous.sh
# 設定: settings-hooks.json(templates/hooks/)の PreToolUse(matcher: Bash)から呼び出す
#
# 入力: stdin に JSON(tool_input.command などが入っている)。jq が必要。
# 終了コード:
#   exit 2 ... ブロック(stderr の内容が理由として Claude に返る)
#   exit 0 ... 判断なし(通常の権限フローに進む)。承認ではない
#   exit 1 ... 非ブロッキングエラー(ブロックされない! 強制したいときは使わない)

input=$(cat)
command=$(jq -r '.tool_input.command // empty' <<<"$input")

# ブロック対象のパターン(自分のプロジェクトに合わせて編集する)
BLOCKED_PATTERNS=("rm -rf" "git push --force" "【追加したいパターン】")

for pattern in "${BLOCKED_PATTERNS[@]}"; do
  if [[ "$command" == *"$pattern"* ]]; then
    echo "Blocked: '$pattern' を含むコマンドは許可されていません" >&2
    exit 2
  fi
done

exit 0
