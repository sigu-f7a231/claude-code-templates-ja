# 全体マップ・Output style・最小構成

| 機能 | 役割 | 置き場所 | コンテキスト消費 |
|---|---|---|---|
| **CLAUDE.md** | 毎回効く前提・規約 | `CLAUDE.md`, `~/.claude/CLAUDE.md` | 毎回全文 |
| **Rules** | トピック別/パス限定の規約 | `.claude/rules/*.md` | 常時(`paths` 付きは該当時のみ) |
| **Skills** | 再利用できる手順・知識 | `.claude/skills/<name>/SKILL.md` | 説明は常時、本文は使用時 |
| **Hooks** | イベントで確実に実行する処理 | `settings.json` の `hooks` | 出力しない限りゼロ |
| **Subagents** | 独立したコンテキストで動く専門ワーカー | `.claude/agents/*.md` | 本体とは分離 |
| **Settings / Permissions** | 許可・拒否・モデル・環境変数などの設定 | `.claude/settings.json` ほか | なし(設定) |
| **MCP** | 外部サービス・ツールへの接続 | `.mcp.json` / `claude mcp add` | 低(ツール検索が既定で有効) |
| **Plugins** | 上記一式をまとめた配布単位 | `.claude-plugin/plugin.json` ほか | 含むものによる |
| **Output style** | 役割・口調・応答形式の切替 | 設定 `outputStyle` | 毎回 |

その他の機能: Code intelligence(言語サーバー連携、対応プラグインが必要)、Dynamic workflow(多数のサブエージェントを一括実行するスクリプト)、Cross-session messaging(セッション間メッセージ)、Marketplace(プラグイン配布)、Artifact(出力を Web ページとして公開)。

## 追加を検討するタイミング(公式の目安)

| 状況 | 使うもの |
|---|---|
| 同じ規約を2回無視された | CLAUDE.md に追記 |
| 同じプロンプトや手順を繰り返している | Skill |
| ブラウザからデータをコピーしている | MCP サーバー |
| 補助タスクが会話を埋め尽くす | Subagent |
| 毎回必ず起きてほしい | Hook |
| 別のリポジトリでも同じ設定が必要 | Plugin |

## 組み合わせの考え方

- **Skill vs Subagent**: Skill は任意の文脈に読み込まれる再利用コンテンツ。Subagent は独立したコンテキストで作業し、要約だけが返る。Skill は `context: fork` で隔離実行でき、Subagent は `skills:` でスキルを事前読み込みできる。
- **MCP vs Skill**: MCP はツールとデータへのアクセスを与え、Skill はその使い方の知識を与える。
- **Hook vs Skill/CLAUDE.md**: 「`.env` を編集しない」は CLAUDE.md ではお願い、PreToolUse フックなら強制。
- **CLAUDE.md vs Output style**: CLAUDE.md はプロジェクトの事実と規約、Output style は役割・口調・形式(同時に有効なのは1つ)。

## 重なったときの扱い

- CLAUDE.md は加算(連結)。
- Skill と Subagent は名前で上書き(Subagent: 管理 > CLI フラグ > プロジェクト > ユーザー > プラグイン / Skill: 管理 > ユーザー > プロジェクト)。
- MCP サーバーは local > project > user。
- Hooks はマージされ、一致したものがすべて発火。

## Output style(出力スタイル)
Claude の役割・口調・応答形式をセッション全体で切り替えます(Concise などの組み込み、またはカスタム)。同時に有効なのは1つで、毎回のリクエストでコンテキストを消費します。設定の `outputStyle` で指定します。詳細ページは今回取得していません。


## 他にも必要なもの
| 目的 | 使うもの |
|---|---|
| チーム全員に同じ設定を配る | `.claude/settings.json` + `.claude/` 配下をコミット、またはプラグイン |
| 個人の設定をリポジトリに入れたくない | `.claude/settings.local.json` / `CLAUDE.local.md`(gitignore) |
| 認証・環境変数の統一 | `settings.json` の `env` |
| 実行を隔離したい | サンドボックス(`sandbox` 設定) |
| 並列・大規模な作業 | Dynamic workflow / 多数のサブエージェント |
| 組織の強制設定 | 管理設定(`managed-settings.json`、`allowManagedHooksOnly` など) |
| 自動化(CI など) | `claude -p`(非対話)。ただしフックやプロジェクト MCP が確認なしで動く点に注意 |

## 最小構成のおすすめ
1. **CLAUDE.md**(`/init` で作る)に、コマンド・規約・構成の要点を書く。
2. **`.claude/settings.json`** に、許可/拒否の権限ルールを書く(`.env` 読み取りの deny など)。
3. 繰り返す手順が出てきたら **Skills** に切り出す。
4. 必ず守らせたいことは **Hooks**(または `permissions.deny`)に書く。
5. 外部サービスが必要になったら **MCP**、役割を分けたくなったら **Subagents**。
6. 複数プロジェクトで使い回したくなったら **Plugins**。

記載テンプレートは `../templates/`(1ファイルずつの雛形)、`../project-template/`(プロジェクト一式の雛形)、`../prompts/`(指示文の雛形)にあります。全体の地図は `../README.md` を参照してください。

## 配置場所(使うときに、どこに置くか)

Claude Code の各機能が、プロジェクトとユーザーのどこに置かれるかの全体図です。

```text
<プロジェクト>/                         ← チーム共有(Git でコミット)
├── CLAUDE.md                          CLAUDE.md(概要・案内)
├── CLAUDE.local.md                    個人用(.gitignore)
├── .mcp.json                          MCP(project スコープ)
├── docs/                              spec.md、plan.md、workflow.md など
└── .claude/
    ├── settings.json                  Settings(権限・フック登録・環境変数)
    ├── settings.local.json            個人用の設定(.gitignore)
    ├── rules/                         Rules(.md)
    ├── skills/<name>/SKILL.md         Skills
    ├── agents/<name>.md               Subagents
    └── hooks/*.sh                     Hooks のスクリプト(chmod +x)

~/.claude/                              ← 自分の全プロジェクト共通(自分のマシンのみ)
├── CLAUDE.md、settings.json
├── rules/、skills/、agents/
~/.claude.json                          ← Claude Code が書く(MCP の local / user スコープなど。直接は編集しない)
```

| 機能 | プロジェクトの置き場所 | ユーザー共通の置き場所 | 詳細 |
|---|---|---|---|
| CLAUDE.md | `CLAUDE.md` | `~/.claude/CLAUDE.md` | `02-claude-md.md` |
| Rules | `.claude/rules/*.md` | `~/.claude/rules/` | `03-rules.md` |
| Skills | `.claude/skills/<name>/SKILL.md` | `~/.claude/skills/<name>/` | `04-skills.md` |
| Hooks | `.claude/settings.json` + `.claude/hooks/` | `~/.claude/settings.json` | `05-hooks.md` |
| Subagents | `.claude/agents/<name>.md` | `~/.claude/agents/` | `06-subagents.md` |
| Settings | `.claude/settings.json` | `~/.claude/settings.json` | `07-settings-permissions.md` |
| MCP | `.mcp.json` | `~/.claude.json`(`claude mcp add`) | `08-mcp.md` |
| Plugins | 別フォルダ/リポジトリ(自作)。有効化は `enabledPlugins` | 同左 | `09-plugins.md` |

- **チームで共有したいものは、プロジェクト側**(コミットする)、**自分だけのものは、`.local` か `~/.claude/`** に置きます。
- `.gitignore` に追加するもの: `CLAUDE.local.md`、`.claude/settings.local.json`、`.env`(秘密情報)。
