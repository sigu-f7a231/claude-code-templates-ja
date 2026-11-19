# 資料別テンプレート(1ファイルずつの雛形)

Claude Code の各機能について、**ファイル1つ分の書き方の雛形**です。`【 】` や `<>` を自分のプロジェクトに合わせて書き換えます。書き方を忘れたとき、1つだけ作りたいときに見ます。
解説は `../read/`(目次: `../read/00-index.md`)にあります。

> **プロジェクト一式**をまとめて導入したいときは、[`../project-template/`](../project-template/README.md) を使います(ワークフロー用の CLAUDE.md・Rules・Skills・Subagents・Hooks・Settings)。
> **Claude Code に貼る指示文**は、[`../prompts/`](../prompts/README.md) にあります。

## 配置先の早見表

| テンプレート | コピー先 | 共有 | 解説 |
|---|---|---|---|
| `CLAUDE.md` | `./CLAUDE.md`(または `./.claude/CLAUDE.md`) | チーム | `read/02` |
| `CLAUDE.local.md` | `./CLAUDE.local.md`(`.gitignore` に追加) | 自分のみ | `read/02` |
| `rules/general-rule.md` | `.claude/rules/<topic>.md` | チーム | `read/03` |
| `rules/path-scoped-rule.md` | `.claude/rules/<topic>.md`(`paths` で対象ファイルを限定) | チーム | `read/03` |
| `skills/reference-skill/SKILL.md` | `.claude/skills/<name>/SKILL.md`(参考知識型) | チーム | `read/04` |
| `skills/task-skill/SKILL.md` | `.claude/skills/<name>/SKILL.md`(タスク型・手動実行) | チーム | `read/04` |
| `hooks/settings-hooks.json` | `.claude/settings.json` の `hooks` にマージ | チーム | `read/05` |
| `hooks/block-dangerous.sh` | `.claude/hooks/block-dangerous.sh`(`chmod +x`) | チーム | `read/05` |
| `hooks/protect-files.sh` | `.claude/hooks/protect-files.sh`(`chmod +x`) | チーム | `read/05` |
| `agents/reviewer.md` | `.claude/agents/<name>.md` | チーム | `read/06` |
| `settings/settings.json` | `.claude/settings.json` | チーム | `read/07` |
| `mcp/.mcp.json` | プロジェクトルートの `.mcp.json` | チーム | `read/08` |
| `plugin/plugin.json` | `<plugin>/.claude-plugin/plugin.json` | 配布 | `read/09` |

> 技術スタック・コマンド・コード規約・作業ルール・注意事項の Rules(5つ)は、プロジェクト一式の一部として [`../project-template/.claude/rules/`](../project-template/.claude/rules/) にあります(ここには置いていません。同じ内容を2か所に持たないため)。

ユーザー全体に効かせたいものは、`~/.claude/` 配下(`CLAUDE.md`、`rules/`、`skills/`、`agents/`、`settings.json`)に同じ形式で置きます。

## 使い分けの目安

| やりたいこと | 使うもの |
|---|---|
| 毎回の前提・概要を伝える | CLAUDE.md |
| 技術・コマンド・規約・作業ルール・注意事項を伝える | Rules(`paths` なし = 毎回、あり = 該当ファイルを触るとき) |
| 繰り返す手順を呼び出す | Skills |
| 確実に実行・ブロックしたい | Hooks / `permissions.deny` |
| 役割を分けて隔離実行したい | Subagents |
| 許可・拒否・環境変数を設定したい | settings.json |
| 外部サービスに接続したい | MCP |
| 一式を配布したい | Plugins |

## 共通の書き方の原則

1. **検証できる具体的な指示にする**(「きれいに」ではなく「インデントは2スペース」)。
2. **コードを読めば分かることは書かない。**
3. **短く保つ**(CLAUDE.md は1ファイル200行未満、SKILL.md は500行以内が目安)。
4. **矛盾する指示を残さない。**
5. **強制したいことは指示ではなく Hooks / permissions に書く。**
6. **JSON にコメントは書けない**(`//` や末尾カンマはエラー)。説明は、この README と `read/` で読み、実際のファイルには書かない。
7. **Skills の本文には、感嘆符 + バッククォートで囲んだコマンドを、説明として書かない**(本文のどこにあっても実行される)。
