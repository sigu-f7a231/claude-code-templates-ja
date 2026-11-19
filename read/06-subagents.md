# Subagents(サブエージェント)

## 何か

独自のコンテキストウィンドウ、システムプロンプト、ツール権限を持つ専門アシスタントです。Claude が `description` に合うタスクを委任します。補助タスクの大量出力で、メインの会話を汚したくないときに使います。

## 置き場所(優先順位の高い順)

1. 管理設定(組織全体)
2. `--agents` CLI フラグ(そのセッションのみ、JSON で渡す)
3. `.claude/agents/`(プロジェクト。コミットして共有)
4. `~/.claude/agents/`(自分の全プロジェクト)
5. プラグインの `agents/`

- ディレクトリは再帰的に走査される。識別は `name` フィールドで、ファイル名ではない(重複不可)。

## ファイル形式

YAML フロントマター + Markdown 本文。**本文がそのままシステムプロンプト**になります(Claude Code の標準システムプロンプトは渡されない)。

```markdown
---
name: code-reviewer
description: Reviews code for quality and best practices
tools: Read, Glob, Grep
model: sonnet
---

You are a code reviewer. When invoked, analyze the code and provide
specific, actionable feedback on quality, security, and best practices.
```

## フロントマター(必須は `name` と `description` のみ)

| フィールド | 内容 |
|---|---|
| `name` | 一意の識別子(256文字以内、`:` 不可) |
| `description` | Claude がいつ委任すべきか |
| `tools` | 使えるツール(省略時は全継承)。`Read, Grep, Bash` のようにカンマ区切りまたは YAML リスト |
| `disallowedTools` | 禁止するツール |
| `model` | `sonnet` / `opus` / `haiku` / `fable` / 完全なモデル ID / `inherit` |
| `permissionMode` | `default` / `acceptEdits` / `auto` / `dontAsk` / `bypassPermissions` / `plan` |
| `maxTurns` | 最大ターン数 |
| `skills` | 起動時に事前読み込みするスキル |
| `mcpServers` | 使う MCP サーバー |
| `hooks` | このサブエージェント専用のフック |
| `memory` | `user` / `project` / `local`(セッションをまたぐ学習) |
| `background` | `true` で常にバックグラウンド実行 |
| `isolation` | `worktree` で一時的な git worktree 内で実行 |
| `effort` / `color` / `initialPrompt` ほか | 思考量、表示色、初回プロンプトなど |

- フィールド名は camelCase で正確に。未知のフィールドは黙って無視される。
- `name` / `description` がない、YAML が壊れている、`name` が `-` で始まる・`:` を含むなどだとスキップされる。
- プラグインのサブエージェントでは、`permissionMode` / `mcpServers` / `hooks` は無視される。

## モデルの決まり方

1. 呼び出し時の `model` 指定 → 2. 定義の `model` → 3. 環境変数 `CLAUDE_CODE_SUBAGENT_MODEL` → 4. メイン会話のモデル

## 呼び出し(要約情報)

- 自然言語: 「test-runner サブエージェントで失敗テストを直して」。`description` に "use proactively" を入れると自動委任されやすい。
- @メンション: `@agent-<name>`
- セッション全体: `claude --agent code-reviewer`、または設定の `"agent": "code-reviewer"`

## 組み込みサブエージェント

| 名前 | 内容 |
|---|---|
| Explore | 読み取り専用の高速なコードベース探索 |
| Plan | プランモードで使う読み取り専用リサーチ |
| general-purpose | 探索と変更の両方が必要な複数ステップの作業 |
| その他 | `claude`(汎用)、`statusline-setup`、`claude-code-guide` |

## 書き方のコツ

- 1サブエージェント=1つの明確な役割にする。
- `description` は具体的に(いつ使うかを書く)。
- 必要なツールだけを `tools` に絞る(レビュー役なら `Read, Glob, Grep`)。
- 本文に「何を調べ、どんな形式で返すか」を書く(要約だけが返るため)。

## 配置場所(使うときに、どこに置くか)

| 範囲 | 置く場所 | 共有 | 使いどころ |
|---|---|---|---|
| プロジェクト | `<プロジェクト>/.claude/agents/<name>.md` | ○(Git でコミット) | そのプロジェクトの専門役。**基本はここ** |
| ユーザー(全プロジェクト共通) | `~/.claude/agents/<name>.md` | ×(自分のマシンのみ) | どのプロジェクトでも使う個人の専門役 |
| プラグイン | `<プラグイン>/agents/<name>.md` | 配布 | 配布(優先順位は最も低い) |
| 一時的(そのセッションだけ) | `claude --agents '<JSON>'` | ×(保存されない) | 試すとき |
| 組織(管理) | 管理設定 | 組織全員 | 管理者が配布 |

```text
<プロジェクト>/
└── .claude/
    └── agents/              ← サブディレクトリも可(再帰的に検出)
        ├── researcher.md    ← 識別はファイル名ではなく、フロントマターの name
        └── test-runner.md
~/.claude/agents/<name>.md   ← (任意)個人用
```

- 優先順位(高い順): 管理 > `--agents` > プロジェクト > ユーザー > プラグイン。同じ `name` は、より優先度の高いものが使われます。
- `name` は**重複しない**ようにします(ファイル名ではなく `name` で識別)。
- 新しく作った `agents/` ディレクトリが、セッション開始時に存在しなかった場合は、再起動します。
- 雛形の入手元: `../templates/agents/reviewer.md`、`../project-template/.claude/agents/`(調査役、テスト実行役)。

---

## テンプレートと使い方

- テンプレート: [`../templates/agents/reviewer.md`](../templates/agents/reviewer.md)(読み取り専用のレビュー役)

### 使い方(手順)

1. `.claude/agents/<name>.md` を作る(個人用は `~/.claude/agents/`)。
2. `name` と `description` を書き、`tools` を必要最小限に絞る。
3. 本文(システムプロンプト)に、手順・出力形式・制約を書く。
4. 「`<name>` サブエージェントで〇〇して」と頼むか、`@agent-<name>` で呼び出す。
5. 新規に作ったディレクトリがセッション開始時に無かった場合は再起動する。
