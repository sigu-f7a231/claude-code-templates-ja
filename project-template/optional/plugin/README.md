# ワークフローをプラグインにまとめる

複数のプロジェクトで同じワークフローを使うときは、Skills・Subagents・Hooks を1つのプラグインにまとめると、1回のインストールで配れます。

## ディレクトリ構成

`project-template/` の内容を、次のように並べます。

```text
dev-workflow/
├── .claude-plugin/
│   └── plugin.json            ← このフォルダの .claude-plugin/plugin.json をコピー
├── skills/
│   ├── spec/SKILL.md          ← project-template/.claude/skills/ の各フォルダをコピー
│   ├── plan-tasks/SKILL.md
│   ├── implement/SKILL.md
│   ├── test/SKILL.md
│   ├── review/SKILL.md
│   ├── commit/SKILL.md
│   └── release/SKILL.md
├── agents/
│   ├── researcher.md          ← project-template/.claude/agents/ をコピー
│   └── test-runner.md
├── hooks/
│   └── hooks.json             ← .claude/settings.json の "hooks" の中身を、下の形式で書く
└── scripts/
    ├── block-push.sh          ← project-template/.claude/hooks/*.sh をコピー(chmod +x)
    ├── protect-files.sh
    └── show-progress.sh
```

`.claude-plugin/` の中に置くのは `plugin.json` だけです。それ以外はプラグインのルートに置きます。

## hooks/hooks.json の例

プラグイン内のスクリプトは、`${CLAUDE_PLUGIN_ROOT}` で参照します。

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "if": "Bash(git push *)",
            "command": "\"${CLAUDE_PLUGIN_ROOT}\"/scripts/block-push.sh"
          }
        ]
      }
    ]
  }
}
```

## プラグイン化したときの違い

| 項目 | プロジェクトの `.claude/` | プラグイン |
|---|---|---|
| スキルの呼び出し名 | `/spec` | `/dev-workflow:spec`(名前空間付き) |
| サブエージェントの名前 | `researcher` | `dev-workflow:researcher` |
| フックのスクリプトのパス | `$CLAUDE_PROJECT_DIR/.claude/hooks/` | `${CLAUDE_PLUGIN_ROOT}/scripts/` |
| プラグインのサブエージェント | `permissionMode` / `mcpServers` / `hooks` が使える | これらのフィールドは無視される |
| Rules / CLAUDE.md / permissions | 使える | プラグインには含められない(各プロジェクトで用意する) |

プラグインに含められないもの(CLAUDE.md、Rules、権限設定)は、`project-template/` の `CLAUDE.md`、`.claude/rules/`、`.claude/settings.json` を各プロジェクトにコピーして使います。

## 検証とインストール

```bash
claude plugin validate ./dev-workflow
```

その後、マーケットプレイスに載せるか、ローカルで試します(`/plugin` で管理、詳細は `read/09-plugins.md`)。

## 注意

- プラグインは、インストールした人のユーザー権限でコードを実行できます。フックのスクリプトは、配る前に内容を確認してください。
- プラグインのスキルは名前空間付きになるため、`CLAUDE.md` に書く呼び出し名(`/spec` など)も合わせて直してください。
