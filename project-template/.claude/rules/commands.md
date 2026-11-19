<!--
  よく使うコマンドの Rules テンプレート
  置き場所: .claude/rules/commands.md(個人用は ~/.claude/rules/commands.md)
  CLAUDE.md には書かず、ここに書く。
  読み込み: paths なし(起動時に毎回読み込まれる)。
  Skills(/test /implement /release など)と Subagents(test-runner)が、ここのコマンドを参照して動く。
  コマンドを変えたら、ここを先に更新する。settings.json の権限(allow)や、Skills の allowed-tools も合わせて直す。
  このコメントは読み込み前に除去される。
-->

# よく使うコマンド

- テスト: `【例: npm test】`(単体: `【例: npm test -- <path>】`)
- Lint: `【例: npm run lint】`
- ビルド: `【例: npm run build】`
- 開発サーバー: `【例: npm run dev】`
