#!/bin/bash
# ワークフロー用 Hook(秘密情報・生成物・ロックファイルの編集をブロックする)
# 置き場所: .claude/hooks/protect-files.sh   実行権限: chmod +x
# 設定: `.claude/settings.json` の hooks の PreToolUse(matcher: Edit|Write)
# 注意: シェルコマンド経由の書き換えは防げない。permissions.deny やサンドボックスと併用する。

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
FILE_PATH="${FILE_PATH//\\//}"   # Windows のバックスラッシュを正規化

PROTECTED_PATTERNS=(".env" "package-lock.json" ".git/" ".claude/settings.local.json")

for pattern in "${PROTECTED_PATTERNS[@]}"; do
  if [[ "$FILE_PATH" == *"$pattern"* ]]; then
    echo "Blocked: $FILE_PATH は保護対象 '$pattern' に一致します。変更が必要なら、理由を説明して人に依頼してください。" >&2
    exit 2
  fi
done

exit 0
