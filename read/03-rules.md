# Claude Code Rules(CLAUDE.md / .claude/rules)の書き方・使い方

出典: 公式ドキュメント [How Claude remembers your project](https://code.claude.com/docs/en/memory)(2026-11-19 時点)
※ ここでの「Rules」は `.claude/rules/` の指示ファイル(Claude に渡すコンテキスト)を指します。許可/拒否の「権限ルール」([Permissions](https://code.claude.com/docs/en/permissions))とは別物です。
※ サイズ上限・auto memory の保存先・`/memory` の挙動・トラブルシュートは要約経由の情報です。細部は公式で確認してください。

## 1. 全体像

- **CLAUDE.md**: 毎セッション読み込まれる常設の指示ファイル。
- **`.claude/rules/*.md`**: トピックごとに分けた指示ファイル。`paths` を付けると特定ファイル操作時だけ読み込まれる。
- どちらも「強制設定」ではなく**コンテキスト**です。必ず守らせたい/必ず止めたいことは、フックや `permissions.deny`(管理設定)を使います。

## 2. 置き場所と読み込み順

複数のファイルは上書きではなく**連結**されます。広い範囲から順に読み込まれ、最後に読んだ(より具体的な)指示が後ろに来ます。

| 範囲 | 場所 | 共有先 |
|---|---|---|
| 組織(管理) | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md` / Linux・WSL: `/etc/claude-code/CLAUDE.md` / Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | 組織の全員 |
| ユーザー | `~/.claude/CLAUDE.md` | 自分の全プロジェクト |
| プロジェクト | `./CLAUDE.md` または `./.claude/CLAUDE.md` | チーム(Git で共有) |
| ローカル | `./CLAUDE.local.md`(`.gitignore` に追加) | 自分だけ・このプロジェクト |

- 同じディレクトリでは `CLAUDE.local.md` が `CLAUDE.md` の後ろに追加される。
- 起動時、作業ディレクトリとその親ディレクトリすべての `CLAUDE.md` / `CLAUDE.local.md` を読み込む。
- 作業ディレクトリ配下のサブディレクトリのものは、そこのファイルを Claude が読み書きしたときに読み込む。
- ブロックレベルの HTML コメント `<!-- ... -->` は読み込み前に除去されるので、メンテナ向けメモに使える(コンテキストを消費しない)。
- 読み込まれたか確認: `/context all` の **Memory files**。

## 3. 効果的な書き方

- **検証できる具体的な指示**にする。
  - ○「インデントは 2 スペース」/ ×「きれいに整形する」
  - ○「コミット前に `npm test` を実行」/ ×「変更をテストする」
  - ○「API ハンドラは `src/api/handlers/` に置く」/ ×「ファイルを整理する」
- 1 ファイル **200 行未満**を目安に(長いと消費が増え、遵守率が下がる)。
- 見出しと箇条書きで整理する。
- **矛盾する指示を残さない**(Claude がどちらかを任意に選ぶ)。
- 複数ステップの手順や、コードベースの一部だけに関する指示は、Skill かパス限定ルールに切り出す。
- `/doctor prompt-audit` で、古い記述・存在しないファイルやコマンドへの参照・矛盾を点検できる(提案のみで、承認するまで変更しない。v2.1.283 以上)。

## 4. `/init` で作る

- `/init` はコードベースを解析し、ビルド/テスト手順や規約を含む CLAUDE.md を生成。
- 既に存在する場合は上書きせず改善案を出す。Cursor / Copilot などのルールファイルも参照する。
- 環境変数 `CLAUDE_CODE_NEW_INIT=1` で、CLAUDE.md・スキル・フックまで提案する多段フローになる。

## 5. `@` によるインポート

```text
See @README for project overview and @package.json for available npm commands for this project.

# Additional Instructions
- git workflow @docs/git-instructions.md
```

- 相対パスは、**インポートを書いたファイルの位置**から解決される。絶対パスも可。
- 最大 4 階層までネスト可能。
- スペースを含むパスは `@Design\ Docs/api-conventions.md` のようにバックスラッシュでエスケープ。
- コードスパンやコードブロック内の `@` は無視される(`` `@README` `` と書けば参照だけできる)。
- インポートしたファイルも一緒に読み込まれるため、コンテキスト消費は減らない。
- 作業ディレクトリ外を指すインポートは、プロジェクトのファイルでは初回に承認ダイアログが出る。
- Git worktree 間で個人の指示を共有するには、ホームからインポートする: `- @~/.claude/my-project-instructions.md`

## 6. `.claude/rules/` の使い方

トピックごとに `.md` ファイルを置きます(サブディレクトリも再帰的に検出)。

```text
your-project/
├── .claude/
│   ├── CLAUDE.md           # メインのプロジェクト指示
│   └── rules/
│       ├── code-style.md   # コードスタイル
│       ├── testing.md      # テスト規約
│       └── security.md     # セキュリティ要件
```

`paths` のないルールは起動時に読み込まれ、`.claude/CLAUDE.md` と同じ優先度です。

### パス限定ルール

フロントマターに `paths` を書くと、該当ファイルを扱うときだけ読み込まれます。

```markdown
---
paths:
  - "src/api/**/*.ts"
---

# API Development Rules

- All API endpoints must include input validation
- Use the standard error response format
- Include OpenAPI documentation comments
```

- Read / Write / Edit が一致するファイルに対して使われたときに読み込まれる(単一ファイルへの `cat` / `head` でも)。
- パターンはルールの基準ディレクトリ相対(プロジェクトルールなら `.claude` フォルダのあるディレクトリ)。

| パターン | 対象 |
|---|---|
| `**/*.ts` | どこにある `.ts` も |
| `src/**/*` | `src/` 配下すべて |
| `*.md` | どこにある `.md` も |
| `/*.md` | 基準ディレクトリ直下のみ |
| `src/components/*.tsx` | そのディレクトリ直下のみ |

ブレース展開も使えます。

```markdown
---
paths:
  - "src/**/*.{ts,tsx}"
  - "lib/**/*.ts"
  - "tests/**/*.test.ts"
---
```

- `paths` は YAML リストまたはカンマ区切り文字列。Claude Code が読むフロントマターは `paths` のみ(他は無視)。
- YAML が壊れていると、フロントマターは無視され「`paths` なしルール」として常時読み込まれる。`claude --debug` でエラー確認。
- 展開後のパターン数は 1,000 / 4 MiB が上限(超えると一致しない)。

## 7. ユーザーレベルのルール

`~/.claude/rules/` に置くと、そのマシンの全プロジェクトに適用されます。

```text
~/.claude/rules/
├── preferences.md    # 個人のコーディング好み
└── workflows.md      # 好みのワークフロー
```

ユーザールールはプロジェクトルールより先に読み込まれます。どちらも他方を上書きしないので、矛盾させないこと。

## 8. シンボリックリンクでの共有

```bash
ln -s ~/shared-claude-rules .claude/rules/shared
ln -s ~/company-standards/security.md .claude/rules/security.md
```

- 循環リンクは処理される。
- 作業ディレクトリ外を指すリンクは「外部インポート」扱い。承認するまで読み込まれず、承認後も `paths` なしのルールだけ読み込まれる。
- 承認なしで共有したい場合は `~/.claude/rules/` に置く。
- ネットワークパス(UNC `\\server\share`、`/net`、`/Network`)のリンクは読み込まれない。

## 9. AGENTS.md との関係

- `CLAUDE.md` 系が無い場合のみ、`AGENTS.md` をプロジェクト指示として読む(v2.1.277 以上)。
- `/config` の **Project instructions** で切替: `claude-md-or-agents-md`(既定)/ `claude-md-and-agents-md` / `claude-md` / `managed-only`。
- 他ツールと共有するなら CLAUDE.md から取り込むのが簡単:

```markdown
@AGENTS.md

## Claude Code

Use plan mode for changes under `src/billing/`.
```

## 10. `--add-dir` で追加したディレクトリ

既定では、追加ディレクトリの CLAUDE.md は読み込まれません。

```bash
CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1 claude --add-dir ../shared-config
```

読み込み対象: `CLAUDE.md`, `.claude/CLAUDE.md`, `CLAUDE.local.md`, `.claude/rules/*.md`(`paths` 付きルールは除く)。

## 11. 組織管理の CLAUDE.md

管理設定 `managed-settings.json` の `claudeMd` キーでも指定できます(ユーザー/プロジェクト設定では無効)。

```json
{
  "claudeMd": "Always run `make lint` before committing.\nNever push directly to main."
}
```

厳格に強制したいルールは `permissions.deny` などの管理設定で、CLAUDE.md は振る舞いの指針に使います。

## 12. 関連: Auto memory

- Claude 自身が学んだことをメモする機能。ローカルセッションで既定オン。
- 種類は `user` / `feedback` / `project` / `reference`。コードや git 履歴から分かること、CLAUDE.md に既にあることは記録しない。
- 切替: `/memory`、設定 `"autoMemoryEnabled": false`、環境変数 `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`。
- 保存先(要約情報): `~/.claude/projects/<project>/memory/`。`MEMORY.md` の先頭 200 行 / 25 KB が毎回読み込まれる。

## 13. 便利なコマンド

| コマンド | 内容 |
|---|---|
| `/init` | CLAUDE.md を生成・改善提案 |
| `/memory` | 読み込まれているメモリファイルの一覧・編集、auto memory の切替 |
| `/context all` | 読み込み済みファイルの確認 |
| `/doctor prompt-audit` | 指示ファイルの点検 |
| `/config` | Project instructions の読み込み対象を設定 |

## 14. トラブルシュート(要約情報)

| 症状 | 対処 |
|---|---|
| CLAUDE.md を無視する | `/context all` で読み込みを確認。指示を具体的にし、矛盾を解消。必須の処理はフックで |
| `/compact` 後に消える | プロジェクトルートの CLAUDE.md は再読込される。会話内だけで伝えた指示は残らない |
| サブディレクトリの CLAUDE.md が切れる | サイズ上限あり。`wc -m` で確認し、縮めるかルールに分割 |
| ルールが読み込まれない | `claude --debug` で `paths` の YAML を確認。基準ディレクトリ、外部インポート承認を確認 |

## すぐ試せる例

`.claude/rules/testing.md`:

```markdown
---
paths:
  - "**/*.test.ts"
---

- テストは Arrange / Act / Assert の順で書く
- 1 テスト 1 アサーションを目安にする
- モックは最小限にする
```

---

# 追記: Rules にはどんなことを書けばよいか

方針は CLAUDE.md と同じく「Claude がコードを読んでも分からないこと」を、具体的に、短く書くことです。Rules はそれに加えて、**トピック単位で分割できる**こと、**`paths` で対象ファイルを絞れる**ことが特徴です(公式の指針をもとに整理)。

## 1. 1ファイル=1トピックにする

公式の例でも、`code-style.md` / `testing.md` / `security.md` のようにトピックごとにファイルを分けています。ファイル名は内容が分かる名前にします。

| ファイル名の例 | 書く内容 |
|---|---|
| `code-style.md` | 命名規則、インポート順、禁止する書き方 |
| `testing.md` | テストの書き方、モックの方針、実行コマンド |
| `security.md` | 入力検証、秘密情報の扱い、禁止事項 |
| `api.md` | エンドポイント設計、エラー形式、ドキュメントコメント |
| `git-workflow.md` | ブランチ名、コミットメッセージ、PR の作り方 |
| `frontend/components.md` | コンポーネントの構成、スタイリング方針(サブディレクトリも可) |

## 2. 書くとよいもの

| 種類 | 例 |
|---|---|
| 対象ファイル限定の規約 | 「API エンドポイントには必ず入力検証を入れる」(`src/api/**/*.ts`) |
| テストの作法 | 「Arrange / Act / Assert の順で書く」「モックは最小限」(`**/*.test.ts`) |
| 統一したい形式 | 「エラーレスポンスは標準フォーマットを使う」 |
| 守るべき制約 | 「ハンドラから直接 SQL を書かない。`src/db/` を経由する」 |
| 個人の好み(ユーザールール) | 「説明は日本語で」「差分は小さくまとめる」(`~/.claude/rules/preferences.md`) |

## 3. どこに書くかの使い分け

| 内容 | 置き場所 |
|---|---|
| 全体に常に関わる前提(コマンド、構成、概要) | CLAUDE.md |
| 特定のファイル種別・ディレクトリだけに関わる規約 | `paths` 付きの `.claude/rules/*.md` |
| 特定のトピックだけを切り出したい(常時読み込みでよい) | `paths` なしの `.claude/rules/*.md` |
| 自分の全プロジェクト共通の好み | `~/.claude/rules/` |
| 複数ステップの手順・ワークフロー | Skills |
| 例外なく強制したい制約 | フック / `permissions.deny` |

`paths` なしのルールは起動時に毎回読み込まれ、CLAUDE.md と同じ優先度です。常時不要なものは `paths` を付けて、必要なときだけ読み込ませるとコンテキストの節約になります。

## 4. 書かないほうがよいもの

- コードを読めば分かること
- 「きれいなコードを書く」のような一般論
- 他のルールや CLAUDE.md と矛盾する指示(ユーザールールとプロジェクトルールが衝突すると、Claude はどちらかを任意に選ぶ)
- 長い手順書(Skills へ)
- 必ず守らせたいこと(Rules は強制ではなくコンテキスト。フックや `permissions` へ)

## 5. 書き方の型

検証できる具体的な指示にします。

| × 曖昧 | ○ 具体的 |
|---|---|
| APIはちゃんと検証する | すべてのエンドポイントで入力値をスキーマ検証する |
| テストを書く | 1テスト1アサーションを目安にする |
| セキュリティに気を付ける | 秘密情報はコードに書かず、環境変数から読む |

見出しと箇条書きで整理し、1ファイルは短く保ちます(CLAUDE.md の「200行未満」の目安がここでも参考になります)。

## 6. 例

### セキュリティ(常時読み込み): `.claude/rules/security.md`

```markdown
# セキュリティ要件

- 秘密情報(API キー、パスワード)をコードに書かない。環境変数から読む
- ユーザー入力は必ずスキーマで検証してから使う
- ログに個人情報を出力しない
```

### API 開発(対象ファイル限定): `.claude/rules/api.md`

```markdown
---
paths:
  - "src/api/**/*.ts"
---

# API 開発ルール

- すべてのエンドポイントで入力検証を行う
- エラーレスポンスは `src/errors/` の標準フォーマットを使う
- OpenAPI 用のドキュメントコメントを付ける
```

### テスト(対象ファイル限定): `.claude/rules/testing.md`

```markdown
---
paths:
  - "**/*.test.ts"
  - "tests/**/*"
---

# テスト規約

- Arrange / Act / Assert の順で書く
- 1テスト1アサーションを目安にする
- モックは外部 API と時刻だけに限定する
```

### 個人の好み(全プロジェクト共通): `~/.claude/rules/preferences.md`

```markdown
- 説明と回答は日本語で行う
- 変更は小さな単位でまとめ、差分の理由を一言添える
```

## 7. 作り方のコツ

1. **まず CLAUDE.md に書き、膨らんできたら Rules に分割する。** 特定ファイルにしか関係しない項目から切り出すと効果的です。
2. **`paths` は広すぎないパターンにする。** `**/*` のようなパターンは、`paths` なしと変わらなくなります。
3. **読み込まれているか確認する。** `/context all` の **Memory files** で見られます。`paths` 付きルールは、該当ファイルを触るまで出てきません。
4. **効いていないときは `claude --debug` で `paths` の YAML エラーを確認する。** YAML が壊れていると、`paths` が無視されて常時読み込みになります。

※ 「どのトピックに分けるか」の例とコツ 1〜2 は、公式の例(code-style / testing / security、`paths` の例)と指針から私が整理したものです。公式が定めた分類ではありません。

## 配置場所(使うときに、どこに置くか)

| 範囲 | 置く場所 | 共有 | 使いどころ |
|---|---|---|---|
| プロジェクト | `<プロジェクト>/.claude/rules/<トピック>.md` | ○(Git でコミット) | そのプロジェクトの技術・規約・作業ルール など。**基本はここ** |
| ユーザー(全プロジェクト共通) | `~/.claude/rules/<トピック>.md` | ×(自分のマシンのみ) | どのプロジェクトでも守ってほしい個人の好み |
| 共有ルールの再利用 | `.claude/rules/` に、共有ファイルへのシンボリックリンクを置く | - | 複数プロジェクトで同じルールを使い回す(承認が必要。承認なしで共有したければ `~/.claude/rules/` に置く) |

```text
<プロジェクト>/
└── .claude/
    └── rules/                  ← サブディレクトリも可(再帰的に検出される)
        ├── tech-stack.md       ← paths なし = 起動時に毎回読み込まれる
        ├── commands.md
        ├── code-style.md
        ├── work-rules.md
        ├── cautions.md
        ├── testing.md          ← paths あり = 対象ファイルを触るときだけ
        └── frontend/
            └── components.md
~/.claude/rules/preferences.md  ← (任意)全プロジェクト共通の個人設定
```

- **1ファイル=1トピック**で、ファイル名は内容が分かる名前にします。
- `paths` の基準は、プロジェクトのルールなら **`.claude` フォルダのあるディレクトリ**(プロジェクトルート)です。
- ユーザーのルールは、プロジェクトのルールより先に読み込まれます。矛盾させないでください。
- 雛形の入手元: `../templates/rules/`(`general-rule.md`、`path-scoped-rule.md`)、`../project-template/.claude/rules/`(技術スタックなど7つ)。

---

## テンプレートと使い方

- テンプレート: [`../templates/rules/general-rule.md`](../templates/rules/general-rule.md)(常時読み込み)/ [`../templates/rules/path-scoped-rule.md`](../templates/rules/path-scoped-rule.md)(`paths` で対象ファイルを限定)
- 技術スタック・コマンド・コード規約・作業ルール・注意事項の Rules(5つ): [`../project-template/.claude/rules/`](../project-template/.claude/rules/)(プロジェクト一式の一部)

### 使い方(手順)

1. トピックごとに `.claude/rules/<topic>.md` を作る(1 ファイル = 1 トピック)。
2. 特定ファイルにだけ関係するなら、フロントマターに `paths` を書く。
3. `/context all` で読み込みを確認(`paths` 付きは該当ファイルを触るまで出ない)。
4. 効かないときは `claude --debug` で `paths` の YAML エラーを確認する。
