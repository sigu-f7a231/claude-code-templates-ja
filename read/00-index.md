# Claude Code 解説ドキュメント 目次

公式ドキュメント(https://code.claude.com/docs/)をもとに整理したものです(2026-11-19 時点)。
全体の地図(フォルダの関係)は [`../README.md`](../README.md) にあります。各ファイルには、**「配置場所(使うときに、どこに置くか)」**(02〜13)と、末尾の「テンプレートと使い方」(02〜09)があります。配置場所では、プロジェクト・ユーザー・組織などの範囲ごとの置き場所、共有の可否、置いた後の形を載せています。プロジェクト全体の置き場所の図は `10-overview-and-others.md` にあります。

## ファイル一覧

| ファイル | 内容 | テンプレート |
|---|---|---|
| [01-prompt-rules-skills-diff.md](01-prompt-rules-skills-diff.md) | プロンプト・Rules・Skills の違い | - |
| [02-claude-md.md](02-claude-md.md) | CLAUDE.md でできること、何を書くか | `../templates/CLAUDE.md`, `CLAUDE.local.md` |
| [03-rules.md](03-rules.md) | `.claude/rules/` の書き方・使い方 | `../templates/rules/` |
| [04-skills.md](04-skills.md) | Skills の書き方・使い方 | `../templates/skills/` |
| [05-hooks.md](05-hooks.md) | Hooks とは、何を書くか | `../templates/hooks/` |
| [06-subagents.md](06-subagents.md) | Subagents | `../templates/agents/` |
| [07-settings-permissions.md](07-settings-permissions.md) | settings.json と権限ルール | `../templates/settings/` |
| [08-mcp.md](08-mcp.md) | MCP(外部サービス連携) | `../templates/mcp/` |
| [09-plugins.md](09-plugins.md) | Plugins | `../templates/plugin/` |
| [10-overview-and-others.md](10-overview-and-others.md) | 全体マップ、Output style、最小構成 | - |
| [11-prompt-templates.md](11-prompt-templates.md) | 開発の指示テンプレート(最初の指示 + 種類別 7 種) | `../prompts/` |
| [12-project-template.md](12-project-template.md) | プロジェクト一式の雛形(工程別ワークフロー)の解説 | `../project-template/` |
| [13-from-instruction-to-release.md](13-from-instruction-to-release.md) | 指示を出すところから公開前までの手引き(Step 0〜8、貼り付ける指示文つき) | `../prompts/`、`../project-template/` |

## 読む順番のおすすめ

1. `10-overview-and-others.md` で全体像をつかむ
2. `01-prompt-rules-skills-diff.md` で使い分けを理解する
3. `02` → `03` → `04` → `05` の順に、基本の 4 つを読む
4. 必要に応じて `06`〜`09`
5. 実際に作り始めるときは `11-prompt-templates.md` の指示テンプレートを使う
6. 工程ごとにワークフローを組んで進めるときは `12-project-template.md` と `13-from-instruction-to-release.md`(雛形は `../project-template/`)

## フォルダの関係

| フォルダ | 役割 |
|---|---|
| `read/`(ここ) | 解説(読む) |
| `../templates/` | 資料別テンプレート(1ファイルずつの雛形) |
| `../project-template/` | プロジェクト一式の雛形(まるごとコピー) |
| `../prompts/` | 指示文の雛形(貼り付け) |

## 注意

- 公式ページの後半部分が要約経由だった箇所は、各ファイルに注記しています。細部は公式で確認してください。
- 「どの機能を使うか」の比較・コツの一部は、公式の記述から整理したもので、公式が定めた分類ではありません。

## 公式ドキュメントの出典

- [Quickstart](https://code.claude.com/docs/en/quickstart)
- [Features overview](https://code.claude.com/docs/en/features-overview)
- [Memory (CLAUDE.md / rules)](https://code.claude.com/docs/en/memory)
- [Skills](https://code.claude.com/docs/en/skills)
- [Hooks guide](https://code.claude.com/docs/en/hooks-guide) / [Hooks reference](https://code.claude.com/docs/en/hooks)
- [Subagents](https://code.claude.com/docs/en/sub-agents)
- [Settings](https://code.claude.com/docs/en/settings) / [Permissions](https://code.claude.com/docs/en/permissions)
- [MCP](https://code.claude.com/docs/en/mcp)
- [Plugins](https://code.claude.com/docs/en/plugins)
