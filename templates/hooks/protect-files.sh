#!/bin/bash
# Hooks スクリプトのテンプレート(PreToolUse で重要ファイルの編集をブロックする)
# 置き場所: .claude/hooks/protect-files.sh
# 実行権限: chmod +x .claude/hooks/protect-files.sh
# 設定: settings-hooks.json(templates/hooks/)の PreToolUse(matcher: Edit|Write)から呼び出す
# 注意: シェルコマンド経由の書き換えは防げない。permissions.deny やサンドボックスと併用する。

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Windows のバックスラッシュ区切りを正規化
FILE_PATH="${FILE_PATH//\\//}"

# 保護するパターン(自分のプロジェクトに合わせて編集する)
PROTECTED_PATTERNS=(".env" "package-lock.json" ".git/" "【追加したいパターン】")

for pattern in "${PROTECTED_PATTERNS[@]}"; do
  if [[ "$FILE_PATH" == *"$pattern"* ]]; then
    echo "Blocked: $FILE_PATH は保護対象 '$pattern' に一致します" >&2
    exit 2
  fi
done

exit 0
