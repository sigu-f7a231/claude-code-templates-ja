# Claude Code Skills の書き方・使い方

出典: 公式ドキュメント [Extend Claude with skills](https://code.claude.com/docs/en/skills)(2026-11-19 時点)
※ 取得時、ページ後半(サブエージェント詳細・権限・共有・トラブルシュート)は要約経由のため、細部は公式で確認してください。

## 1. Skills とは

- `SKILL.md` を含むディレクトリ。YAML フロントマター + Markdown の指示で構成されます。
- Claude が関連すると判断したときに自動で読み込むか、`/skill-name` で直接呼び出します。
- 繰り返し使う手順や複数ステップの作業向き。CLAUDE.md と違い、本文は使われたときだけ読み込まれます。
- 従来の `.claude/commands/` もスキルに統合済み(引き続き動作)。
- オープン標準 [Agent Skills](https://agentskills.io) に準拠し、Claude Code 独自の拡張があります。

## 2. 置き場所

| 種類 | パス | 対象 |
|---|---|---|
| Enterprise | 管理設定ディレクトリ内の `.claude/skills/<name>/SKILL.md` | 組織の全ユーザー |
| Personal | `~/.claude/skills/<name>/SKILL.md` | 自分の全プロジェクト |
| Project | `.claude/skills/<name>/SKILL.md` | そのリポジトリ(コミットして共有) |
| Nested | `<subdir>/.claude/skills/<name>/SKILL.md` | そのサブディレクトリ配下 |
| Plugin | `<plugin>/skills/<name>/SKILL.md` | `/plugin-name:skill-name` として利用 |

- 同名の優先順位: Enterprise > Personal > Project。プラグインは名前空間付きなので衝突しません。
- 予約名: `synced` や `anthropic-skills` で始まる名前は使えません。
- 編集は再起動不要で反映。新しく最上位の skills ディレクトリを作った場合は `/reload-skills`。
- コマンド名はフロントマターの `name`、なければディレクトリ名。

## 3. 基本構造

```markdown
---
name: my-skill
description: このスキルが何をするか・いつ使うか
disable-model-invocation: true
allowed-tools: Read Grep
---

ここに指示を書く...
```

- フロントマターは 1 行目から始める(そうでないと全体が本文扱い)。
- YAML が壊れているとフィールドなしで読み込まれる。未知のキーは黙って無視される。
- `SKILL.md` は 500 行以内を目安に。

## 4. フロントマター一覧(すべて任意)

| フィールド | 内容 |
|---|---|
| `name` | `/` メニューでの名前(省略時はディレクトリ名) |
| `description` | 何をするか/いつ使うか。Claude が自動読み込みの判断に使う |
| `when_to_use` | 追加のトリガー文脈。`description` に連結(合計 1,536 文字で切り詰め) |
| `argument-hint` | 補完時のヒント(例 `[issue-number]`) |
| `arguments` | 名前付き位置引数(`$name` で参照) |
| `disable-model-invocation` | `true` で Claude の自動呼び出しを禁止(手動のみ) |
| `user-invocable` | `false` で `/` メニューから隠す(Claude のみ呼べる) |
| `allowed-tools` | スキル実行中、確認なしで使えるツール |
| `disallowed-tools` | スキル実行中、使えなくするツール |
| `model` / `effort` | そのターンのモデル・思考量の上書き |
| `context` | `fork` でサブエージェントとして実行 |
| `agent` | `context: fork` 時のエージェント種別(`Explore`, `Plan` など) |
| `background` | `fork` 時にバックグラウンド実行するか(既定 `true`) |
| `hooks` | 呼び出し時に登録するフック |
| `paths` | 自動有効化を特定ファイル(glob)に限定 |
| `shell` | `!` コマンドのシェル(`bash` / `powershell`) |
| `metadata` / `license` / `compatibility` | 自前ツール用・仕様上のフィールド |

claude.ai へのアップロードや Skills API では、使えるキーが `name`, `description`, `license`, `compatibility`, `metadata`, `allowed-tools` のみ。他のキーはエラーになります。

## 5. description の書き方

- 最重要の用途を先頭に書く(1,536 文字を超える部分は切られる)。
- ユーザーが実際に言いそうな自然なキーワードを入れる。
- 発動しない → より具体的に。発動しすぎる → 絞るか `disable-model-invocation: true`。
- 山括弧 `<>` は `&lt;` と表示されるので `[branch]` などを使う。

```yaml
---
name: summarize-changes
description: Summarizes uncommitted changes and flags anything risky. Use when the user asks what changed, wants a commit message, or asks to review their diff.
---
```

## 6. 内容の種類

**参考知識型**(規約・スタイルガイド。会話内で適用):

```yaml
---
name: api-conventions
description: API design patterns for this codebase
---
When writing API endpoints:
- Use RESTful naming conventions
- Return consistent error formats
- Include request validation
```

**タスク型**(デプロイ・コミットなど。手動実行が安全):

```yaml
---
name: deploy
description: Deploy the application to production
context: fork
disable-model-invocation: true
---
Deploy the application:
1. Run the test suite
2. Build the application
3. Push to the deployment target
```

読み込まれた本文は以降のターンも文脈に残るため、簡潔に書きます。

## 7. 補助ファイル

```text
my-skill/
├── SKILL.md        # 必須。概要とナビゲーション
├── reference.md    # 詳細(必要時に読み込み)
├── examples.md     # 例(必要時に読み込み)
└── scripts/
    └── helper.py   # 実行用スクリプト(読み込まず実行)
```

SKILL.md から参照して、いつ読むべきかを Claude に伝えます。

```markdown
- 詳細な API は [reference.md](reference.md) を参照
- 使用例は [examples.md](examples.md) を参照
```

## 8. 引数と変数

| 変数 | 展開結果 |
|---|---|
| `$ARGUMENTS` | 入力した引数すべて(プレースホルダがなければ末尾に追記) |
| `$ARGUMENTS[N]` / `$N` | N 番目(0 始まり)の引数 |
| `$name` | `arguments` で名付けた引数 |
| `${CLAUDE_SESSION_ID}` | セッション ID |
| `${CLAUDE_SKILL_DIR}` | SKILL.md のあるディレクトリ |
| `${CLAUDE_PROJECT_DIR}` | プロジェクトルート |

```yaml
---
name: fix-issue
description: Fix a GitHub issue
disable-model-invocation: true
---
Fix GitHub issue $ARGUMENTS following our coding standards.
```

`/fix-issue 123` → 「Fix GitHub issue 123 following ...」

- `"hello world"` のようにクォートすれば 1 引数として扱われる。
- 引数が足りない `$2` はそのまま残り、名前付きは空になる。
- リテラルの `$` は `\$1.00` とエスケープ。

## 9. 呼び出し制御

| 設定 | 自分で呼べる | Claude が呼べる |
|---|---|---|
| (既定) | ○ | ○ |
| `disable-model-invocation: true` | ○ | ×(説明も文脈に載らない) |
| `user-invocable: false` | × | ○ |

- 直接実行するにはメッセージの先頭に `/deploy staging` のように書く。
- 自動圧縮後は、各スキルの直近の呼び出しが再添付される(スキルごと先頭 5,000 トークン、合計 25,000 トークンまで)。

## 10. 動的コンテキスト注入

`` !`コマンド` `` は、Claude に渡す前にシェルで実行され、出力で置換されます。

```yaml
---
name: pr-summary
description: Summarize changes in a pull request
context: fork
agent: Explore
allowed-tools: Bash(gh *)
---

## Pull request context
- PR diff: !`gh pr diff`
- PR comments: !`gh pr view --comments`
- Changed files: !`gh pr diff --name-only`

## Your task
Summarize this pull request...
```

複数行形式:

````markdown
```!
node --version
git status --short
```
````

- `!` は行頭か空白の後でのみ有効。
- 既定タイムアウト 2 分。非ゼロ終了で中断(`grep` の終了コード 1 は除く)。許容するなら `|| true`。
- 設定の `disableSkillShellExecution: true` で無効化可能。
- 実行は権限ルールで判定され、許可がないと中断されるため、`allowed-tools` で事前許可する。

## 11. サブエージェントで実行(`context: fork`)

- スキル本文がサブエージェントのタスクプロンプトになる。会話履歴は見えないので、自己完結した指示を書く。
- ガイドライン中心でタスクのないスキルを fork しても意味がない。

```yaml
---
name: deep-research
description: Research a topic thoroughly
context: fork
agent: Explore
---

Research $ARGUMENTS thoroughly:
1. Find relevant files using Glob and Grep
2. Read and analyze the code
3. Summarize findings with specific file references
```

## 12. 権限

- `allowed-tools` は、そのターン中に確認なしで使えるツールを追加する。ツールを制限するものではない。

```yaml
---
name: commit
description: Stage and commit the current changes
disable-model-invocation: true
allowed-tools: Bash(git add *) Bash(git commit *) Bash(git status *)
---
```

- deny ルールは常に優先。`Skill` ツールを deny すると全スキル無効、`Skill(commit)` のように個別指定も可能。
- 信頼していないリポジトリのスキルの `allowed-tools` は事前に確認する。

## 13. 共有・管理

- プロジェクト共有: `.claude/skills/` をコミット
- 配布: プラグインの `skills/` に入れる
- 組織配布: 管理設定で展開
- 設定の `skillOverrides` で `on` / `name-only` / `user-invocable-only` / `off` を個別設定
- `/skill-doctor` でスキルごとのコンテキスト消費と呼び出し頻度を確認

## 14. テスト・改善

- 狙ったプロンプトで発動するか、出力が正しいかを、スキルあり/なしの新規セッションで比較する。
- `skill-creator` プラグインで評価の自動化が可能。プラグイン用には `claude plugin eval`。

## 15. トラブルシュート

| 症状 | 対処 |
|---|---|
| 発動しない | description を具体的に/スキル一覧に出ているか確認/`/skill-name` で直接実行 |
| 発動しすぎる | description を絞る、または `disable-model-invocation: true` |
| 途中から従わなくなる | 重要ルールは冒頭に、守らせたいことはフックへ、圧縮後は再呼び出し |
| description が途中で切れる | スキルが多すぎる。`skillListingBudgetFraction` を上げる、または `name-only` に |
| 名前が拒否される | 制御文字・`<>` などを含んでいないか確認(`claude --debug` で `[names]` を検索) |
| `name:` を変更した | セッションを再起動 |

## 最小の作り方(手順)

1. `mkdir -p ~/.claude/skills/hello` (プロジェクト用なら `.claude/skills/hello`)
2. `SKILL.md` を作成:

   ```markdown
   ---
   name: hello
   description: Greets the user in Japanese. Use when the user says hello or asks for a greeting.
   ---
   日本語で丁寧にあいさつしてください。
   ```

3. Claude Code で `/hello` を実行、または「こんにちは」と話しかけて自動発動を確認。

---

# 追記: Skills にはどんなことを書けばよいか

方針は「毎回同じ手順を踏む作業」や「必要なときだけ読み込みたい専門知識」を、Claude が自己完結して実行できる形で書くことです(公式の指針をもとに整理)。

## 1. Skills に向いている内容

公式は、Skills を「繰り返し使う指示」「複数ステップの手順」に向くものとしています。本文は使われたときだけ読み込まれるので、CLAUDE.md に入れると常時コンテキストを消費する長い内容も置けます。

| 種類 | 例 | 呼び出し方の目安 |
|---|---|---|
| **参考知識型**(規約・ガイド) | API 設計パターン、社内のコードレビュー基準 | Claude の自動判断で OK |
| **タスク型**(手順・作業) | デプロイ、コミット、リリース、Issue 修正 | `disable-model-invocation: true`(手動のみ) |
| **調査・要約型** | PR の要約、コードベース調査 | `context: fork` でサブエージェント実行 |
| **スクリプト実行型** | CSV からグラフ生成、定型レポート出力 | `allowed-tools` でスクリプトを事前許可 |

## 2. 書くとよいもの

| 項目 | 内容 |
|---|---|
| **description** | 何をするか + いつ使うか(ユーザーが言いそうな自然なキーワード入り) |
| **手順** | 番号付きのステップ。「1. テスト実行 → 2. ビルド → 3. デプロイ」 |
| **判断基準** | 「どんな場合は止める」「どの結果なら成功」など |
| **出力形式** | 「箇条書きで3点以内」「ファイル参照を付ける」 |
| **引数の扱い** | `$ARGUMENTS`、`$0`、`$name` で受け取る値 |
| **実行時のコンテキスト** | `` !`git diff HEAD` `` のように、実行時点の情報を埋め込む |
| **補助ファイルへの案内** | 「詳細は `reference.md` を参照」 |

## 3. 書かないほうがよいもの

- **常に適用したい規約**。毎回効かせたいなら CLAUDE.md / Rules へ(Skills は呼ばれたときだけ効く)。
- **曖昧な description**。「便利なツール」のようにすると、発動しない原因になる。
- **長すぎる本文**。`SKILL.md` は 500 行以内が目安。詳細は `reference.md` などに分ける。
- **会話の文脈に依存した指示**。`context: fork` で動かすと会話履歴は見えないため、自己完結させる。
- **強制したいルール**。Skills も指示であり強制ではない。守らせたいことはフックへ。
- **一度きりの依頼**。その場のプロンプトで十分。

## 4. 書き方の型

### description は「何をする + いつ使う」

```yaml
description: Summarizes uncommitted changes and flags anything risky. Use when the user asks what changed, wants a commit message, or asks to review their diff.
```

- 重要な用途を先頭に書く(`description` + `when_to_use` は合計 1,536 文字で切り詰め)。
- 山括弧 `<>` は `&lt;` と表示されるので、`[branch]` のように書く。

### 本文は具体的な手順にする

| × 曖昧 | ○ 具体的 |
|---|---|
| ちゃんとデプロイする | 1. テストを実行 2. ビルド 3. デプロイ先に push |
| 要約する | 変更の目的、影響範囲、リスクを各1〜2文で要約する |

### 副作用のある作業は手動限定にする

デプロイ、コミット、メッセージ送信などは `disable-model-invocation: true` にして、Claude が勝手に実行しないようにします。

## 5. 例

### 参考知識型: `.claude/skills/api-conventions/SKILL.md`

```markdown
---
name: api-conventions
description: API design patterns for this codebase. Use when writing or reviewing API endpoints.
---

When writing API endpoints:
- Use RESTful naming conventions
- Return consistent error formats
- Include request validation
```

### タスク型(手動のみ): `.claude/skills/deploy/SKILL.md`

```markdown
---
name: deploy
description: Deploy the application to production
disable-model-invocation: true
context: fork
---

Deploy the application:
1. Run the test suite
2. Build the application
3. Push to the deployment target
```

### 引数付き: `.claude/skills/fix-issue/SKILL.md`

```markdown
---
name: fix-issue
description: Fix a GitHub issue
disable-model-invocation: true
---

Fix GitHub issue $ARGUMENTS following our coding standards.
```

`/fix-issue 123` と入力すると、`$ARGUMENTS` が `123` に置き換わります。

### 実行時の情報を埋め込む調査型: `.claude/skills/pr-summary/SKILL.md`

```markdown
---
name: pr-summary
description: Summarize changes in a pull request
context: fork
agent: Explore
allowed-tools: Bash(gh *)
---

## Pull request context
- PR diff: !`gh pr diff`
- PR comments: !`gh pr view --comments`
- Changed files: !`gh pr diff --name-only`

## Your task
Summarize this pull request...
```

### 日本語で書く場合の最小例

```markdown
---
name: review-japanese
description: 変更差分をレビューし、問題点を日本語で指摘する。ユーザーが「レビューして」「差分を確認して」と言ったときに使う。
---

`git diff` の内容を確認し、次の観点で日本語でレビューしてください。

1. バグの可能性
2. 命名・可読性
3. テストの不足

指摘は重要度の高い順に、ファイル名と行番号を付けて箇条書きで出力します。
```

## 6. 作り方のコツ

1. **まず手動で何度かやってみる。** 同じ依頼を3回くらい繰り返したら、Skills にするサイン。
2. **description を最初に丁寧に書く。** 発動するかどうかはほぼここで決まる。
3. **小さく作って試す。** `/skill-name` で直接実行して、期待通り動くか確認する。自動発動は、狙ったプロンプトで試す。
4. **発動しないときは description を具体的に、発動しすぎるときは絞る**か `disable-model-invocation: true` にする。
5. **補助ファイルに分ける。** `SKILL.md` は概要と手順だけにして、詳細は `reference.md`、スクリプトは `scripts/` に置く。
6. **チームで共有するなら** `.claude/skills/` をコミットする。

※ 「Skills に向いている内容」の分類表と、コツ 1〜3 は、公式の記述(参考知識型/タスク型の区別、description のガイダンス、トラブルシュート)から私が整理したものです。公式が定めた分類ではありません。日本語の最小例は公式の例ではなく、私が作成した例です。

## 配置場所(使うときに、どこに置くか)

| 範囲 | 置く場所 | 共有 | 使いどころ |
|---|---|---|---|
| プロジェクト | `<プロジェクト>/.claude/skills/<name>/SKILL.md` | ○(Git でコミット) | そのプロジェクトの手順。**基本はここ** |
| ユーザー(全プロジェクト共通) | `~/.claude/skills/<name>/SKILL.md` | ×(自分のマシンのみ) | どのプロジェクトでも使う個人の手順 |
| サブディレクトリ | `<サブディレクトリ>/.claude/skills/<name>/SKILL.md` | ○ | モノレポで、その配下で作業するときだけ使う手順 |
| プラグイン | `<プラグイン>/skills/<name>/SKILL.md` | 配布 | 複数プロジェクトへの配布(呼び出し名は `/プラグイン名:name`) |
| 組織(管理) | 管理設定ディレクトリ内の `.claude/skills/<name>/SKILL.md` | 組織全員 | 管理者が配布 |

```text
<プロジェクト>/
└── .claude/
    └── skills/
        ├── spec/                ← フォルダ名がコマンド名(/spec)になる(name を書けばそちらが優先)
        │   ├── SKILL.md         ← 必須
        │   ├── reference.md     ← 補助ファイル(必要なときに読み込む)
        │   └── scripts/helper.py
        └── commit/
            └── SKILL.md
~/.claude/skills/<name>/SKILL.md ← (任意)個人用
```

- **フォルダ名=スキル名**にします。補助ファイル(`reference.md`、`scripts/`)は、**同じフォルダ**に置き、`SKILL.md` から参照します。
- 同じ名前が複数の場所にあると、管理 > ユーザー > プロジェクトの順に優先されます。
- 新しく作った `skills/` ディレクトリが一覧に出ない場合は、`/reload-skills` を実行するか、再起動します。
- 雛形の入手元: `../templates/skills/`(2種)、`../project-template/.claude/skills/`(工程別の7つ)、`../project-template/optional/skills/`(任意)。

---

## テンプレートと使い方

- テンプレート: [`../templates/skills/reference-skill/SKILL.md`](../templates/skills/reference-skill/SKILL.md)(参考知識型)/ [`../templates/skills/task-skill/SKILL.md`](../templates/skills/task-skill/SKILL.md)(タスク型・手動実行)

### 使い方(手順)

1. `.claude/skills/<name>/SKILL.md` を作る(個人用は `~/.claude/skills/<name>/`)。
2. `description` に「何をするか + いつ使うか」を書く。
3. 副作用のある作業は `disable-model-invocation: true` にする。
4. `/<name>` で直接実行して動作を確認し、自動発動は狙ったプロンプトで試す。
5. 発動しない/しすぎるときは description を調整する。
