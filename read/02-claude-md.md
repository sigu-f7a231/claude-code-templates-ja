# CLAUDE.md でできること

出典: 公式ドキュメント [How Claude remembers your project](https://code.claude.com/docs/en/memory)(2026-11-19 時点)
関連ファイル: `03-rules.md`(書き方の詳細)/ `01-prompt-rules-skills-diff.md`(Skills・プロンプトとの違い)

## CLAUDE.md とは

毎セッションの開始時に Claude が読み込む、Markdown の指示ファイルです。会話をまたいで残したい前提・規約・手順を書いておくと、毎回言い直す必要がなくなります。

## できること

### 1. プロジェクトの前提を教える

Claude がコードから読み取れない情報を書きます。

- ビルド・テスト・lint のコマンド(例: 「コミット前に `npm test` を実行」)
- ディレクトリ構成(例: 「API ハンドラは `src/api/handlers/` に置く」)
- コーディング規約(例: 「インデントは2スペース」)
- ブランチ運用、コミットメッセージの書き方、レビュー方針

### 2. 他のファイルを取り込む(`@` インポート)

```text
See @README for project overview and @package.json for available npm commands.

# Additional Instructions
- git workflow @docs/git-instructions.md
```

- 相対パスは、書いたファイルの位置から解決される。最大4階層までネスト可能。
- 取り込んだ内容も一緒に読み込まれるため、コンテキスト消費は減らない。
- 他ツール用の `AGENTS.md` を共有するときは、先頭に `@AGENTS.md` と書く。

### 3. 適用範囲を使い分ける

| 範囲 | 場所 | 共有先 |
|---|---|---|
| 組織(管理) | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md` / Linux・WSL: `/etc/claude-code/CLAUDE.md` / Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | 組織の全員 |
| ユーザー | `~/.claude/CLAUDE.md` | 自分の全プロジェクト |
| プロジェクト | `./CLAUDE.md` または `./.claude/CLAUDE.md` | チーム(Git で共有) |
| ローカル | `./CLAUDE.local.md`(`.gitignore` に追加) | 自分だけ・このプロジェクト |

- 上書きではなく連結され、広い範囲 → 狭い範囲の順に読み込まれる。
- 作業ディレクトリの親ディレクトリのものも起動時に読み込まれる。
- サブディレクトリのものは、そこのファイルを Claude が読み書きしたときに読み込まれる(モノレポで便利)。

### 4. `.claude/rules/` と組み合わせて分割する

- トピックごとに `.md` を分けて置ける(`testing.md`、`security.md` など)。
- `paths` フロントマターを付けると、該当ファイルを触るときだけ読み込める。

```markdown
---
paths:
  - "src/api/**/*.ts"
---
- All API endpoints must include input validation
```

### 5. `/init` で自動生成する

- コードベースを解析し、ビルド/テスト手順や規約を含む CLAUDE.md を作成。
- 既存ファイルがあれば上書きせず、改善案を提示する。

### 6. 組織の方針を配布する

管理設定 `managed-settings.json` の `claudeMd` キーで、組織全員に指示を配布できます(ユーザー/プロジェクト設定では無効)。

```json
{
  "claudeMd": "Always run `make lint` before committing.\nNever push directly to main."
}
```

### 7. メンテナ向けメモを残す

ブロックレベルの HTML コメント `<!-- ... -->` は読み込み前に除去されるため、コンテキストを消費せずにメモを書けます。

## できないこと・注意点

- **強制力はない。** CLAUDE.md は「コンテキスト」であり、設定ではない。Claude が必ず従う保証はありません。
  - 必ず止めたい操作 → `permissions.deny` やフック(PreToolUse)
  - 必ず実行したい処理 → フック
- **長すぎると効きにくい。** 1ファイル200行未満が目安。
- **矛盾した指示は避ける。** 衝突すると Claude がどちらかを任意に選ぶ。
- **手順が長いものは Skills へ。** 複数ステップの手順や一部のコードにだけ関係する指示は、Skills かパス限定ルールに切り出すのが公式の推奨。
- **会話内で伝えただけの指示は `/compact` 後に残らない。** 残したいものは CLAUDE.md に書く(プロジェクトルートの CLAUDE.md は圧縮後に再読込される)。

## 書き方のコツ

- 検証できる具体的な指示にする。
  - ○「インデントは2スペース」/ ×「きれいに整形する」
  - ○「コミット前に `npm test` を実行」/ ×「変更をテストする」
- 見出しと箇条書きで整理する。
- 定期的に `/doctor prompt-audit` で、古い記述・存在しないファイルへの参照・矛盾を点検する。

## 便利なコマンド

| コマンド | 内容 |
|---|---|
| `/init` | CLAUDE.md を生成・改善提案 |
| `/memory` | 読み込まれているメモリファイルの一覧・編集 |
| `/context all` | 読み込み済みファイルの確認(**Memory files**) |
| `/doctor prompt-audit` | 指示ファイルの点検 |

## 最小の例

```markdown
# プロジェクト概要
社内向けの在庫管理 API(Node.js + TypeScript)。

## コマンド
- テスト: `npm test`
- Lint: `npm run lint`

## 規約
- インデントは2スペース
- API ハンドラは `src/api/handlers/` に置く
- コミット前に必ず `npm test` と `npm run lint` を実行する
```

---

# 追記: どんな内容を書けばよいか

方針は「Claude がコードを読んでも分からないこと」を、具体的に、短く書くことです(公式の指針をもとに整理)。

## 書くとよいもの

| 種類 | 例 |
|---|---|
| コマンド | テスト: `npm test` / Lint: `npm run lint` / 単一テスト: `npm test -- path/to/file` |
| コード規約(デフォルトと違うもの) | 「インデントは2スペース」「`any` は使わない」「default export は禁止」 |
| ディレクトリの役割 | 「API ハンドラは `src/api/handlers/`」「共通型は `src/types/`」 |
| 作業ルール | 「コミット前に test と lint を通す」「ブランチ名は `feature/xxx`」 |
| プロジェクト固有の落とし穴 | 「`.env.local` はコミットしない」「DB マイグレーションは手で実行しない」 |
| アーキテクチャの要点 | 「認証は `src/auth` に集約。他から直接 JWT を触らない」 |
| 参照先 | 詳しい仕様は `@docs/architecture.md` |

> **補足(このリポジトリの雛形での扱い):** `../project-template/` では、技術スタック・コマンド・コード規約・作業ルール・注意事項を `CLAUDE.md` ではなく `.claude/rules/` に分けて書き、`CLAUDE.md` には概要・Skills 一覧・ドキュメントの置き場所・Rules への案内だけを置いています(`CLAUDE.md` を短く保ち、トピックごとに更新できるため)。上の「書くとよいもの」は、その内容をどこに書くかの選択肢として読んでください。1ファイルにまとめたい小さなプロジェクトでは、これらを `CLAUDE.md` に書いても構いません(`../templates/CLAUDE.md` は、その1ファイル完結の形です)。

## 書かないほうがよいもの

- **コードを読めば分かること**(関数の説明、ファイル一覧)。公式も、コードベースから導出できる内容は削るよう勧めている。
- **一般的な常識**(「きれいなコードを書く」「テストを書く」)。曖昧で効果が薄い。
- **長い手順書**。複数ステップの手順は Skills に分ける。
- **特定ファイルにしか関係しない指示**。`paths` 付きの `.claude/rules/` に分ける。
- **頻繁に変わる情報**(進行中のタスクなど)。古くなって矛盾の原因になる。
- **矛盾する指示**。Claude がどちらかを任意に選ぶ。
- **必ず守らせたいこと**。CLAUDE.md には強制力がないため、`permissions.deny` やフックに任せる。

## 書き方の型

検証できる形で書きます。

| × 曖昧 | ○ 具体的 |
|---|---|
| きれいに整形する | インデントは2スペース |
| 変更をテストする | コミット前に `npm test` を実行 |
| ファイルを整理する | API ハンドラは `src/api/handlers/` に置く |

構成の例(この順がおすすめ):

1. プロジェクト概要(1〜3行)
2. よく使うコマンド
3. コード規約
4. ディレクトリ構成の要点
5. 作業ルール(コミット、ブランチ、レビュー)
6. 注意事項・落とし穴

分量は **200行未満**が目安。

## 例(Web アプリの場合)

```markdown
# 概要
社内向けの在庫管理 API(Node.js + TypeScript + PostgreSQL)

## コマンド
- テスト: `npm test`(単体: `npm test -- <path>`)
- Lint: `npm run lint`
- 開発サーバー: `npm run dev`

## 規約
- インデントは2スペース、`any` は使わない
- エラーは `src/errors/` のカスタムエラーを投げる

## 構成
- API ハンドラ: `src/api/handlers/`
- DB アクセス: `src/db/`(ハンドラから直接 SQL を書かない)

## 作業ルール
- コミット前に `npm test` と `npm run lint` を通す
- ブランチ名は `feature/<内容>`

## 注意
- `.env.local` はコミットしない
- マイグレーションは `npm run migrate` 経由でのみ実行
```

## 作り方のコツ

1. **まず `/init` を実行**して下書きを作る。ビルド・テスト手順や規約を自動で拾ってくれる。
2. **Claude が間違えたときに追記する。** 同じ指摘を2回したら、CLAUDE.md に書くサイン。
3. **定期的に削る。** `/doctor prompt-audit` で、古い記述や存在しないファイルへの参照を点検できる。
4. **個人用のメモは `CLAUDE.local.md`**(`.gitignore` に追加)に分ける。

※ コツの 2〜3(間違えたら追記、定期的に削る)は公式が明示している手順ではなく、公式の指針(具体的に・短く・矛盾を避ける)から整理したものです。

## 配置場所(使うときに、どこに置くか)

| 範囲 | 置く場所 | 共有 | 使いどころ |
|---|---|---|---|
| プロジェクト(チーム共有) | `<プロジェクト>/CLAUDE.md` または `<プロジェクト>/.claude/CLAUDE.md` | ○(Git でコミット) | そのプロジェクトの前提・案内。**基本はここ** |
| 個人用(そのプロジェクトだけ) | `<プロジェクト>/CLAUDE.local.md` | ×(`.gitignore` に追加) | 自分だけのメモ(ポート番号、好み) |
| ユーザー(全プロジェクト共通) | `~/.claude/CLAUDE.md` | ×(自分のマシンのみ) | どのプロジェクトでも守ってほしい個人の好み |
| サブディレクトリ | `<プロジェクト>/<サブディレクトリ>/CLAUDE.md` | ○ | モノレポで、その配下だけに効かせたい指示(その配下のファイルを触ったときに読み込まれる) |
| 組織(管理) | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md` / Linux: `/etc/claude-code/CLAUDE.md` / Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | 組織全員 | 組織の方針の配布(管理者が置く) |

```text
<プロジェクト>/
├── CLAUDE.md              ← ここに置く(チーム共有)
├── CLAUDE.local.md        ← 個人用(.gitignore に追加)
├── .gitignore             ← CLAUDE.local.md を追記
└── packages/api/CLAUDE.md ← (任意)サブディレクトリ専用
~/.claude/CLAUDE.md        ← (任意)全プロジェクト共通の個人設定
```

- **起動した場所**(作業ディレクトリ)と、その親ディレクトリの `CLAUDE.md` が、起動時に読み込まれます。サブディレクトリのものは、そこのファイルを触ったときに読み込まれます。
- 迷ったら、**プロジェクト直下の `CLAUDE.md`** に置きます。
- 雛形の入手元: `../templates/CLAUDE.md`(1ファイル完結)、`../project-template/CLAUDE.md`(Rules に分ける構成の案内版)。

---

## テンプレートと使い方

- テンプレート: [`../templates/CLAUDE.md`](../templates/CLAUDE.md)(チーム共有)/ [`../templates/CLAUDE.local.md`](../templates/CLAUDE.local.md)(個人用)

### 使い方(手順)

1. `/init` で下書きを作る(またはテンプレートを `./CLAUDE.md` にコピー)。
2. `【 】` の部分を自分のプロジェクトの内容に書き換え、不要な見出しを削除する。
3. 200 行未満に収める。長い手順は Skills、特定ファイル向けは Rules へ。
4. `/context all` の **Memory files** で読み込まれていることを確認する。
5. `CLAUDE.local.md` を使う場合は `.gitignore` に追加する。
