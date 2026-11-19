# Settings と Permissions

## settings.json の場所と優先順位

| 範囲 | ファイル | 備考 |
|---|---|---|
| ユーザー | `~/.claude/settings.json` | 全プロジェクト |
| プロジェクト共有 | `.claude/settings.json` | コミットしてチーム共有 |
| プロジェクトローカル | `.claude/settings.local.json` | 個人用(gitignore) |
| 管理 | `managed-settings.json` / MDM など | 組織が配布 |

- **優先順位(高い順): 管理 > CLI(`--settings`)> ローカル > プロジェクト共有 > ユーザー**
- `permissions.allow` などのリストは、複数ファイルで書くと**結合**される。
- ファイルの編集は再起動不要で反映。JSON は厳格(コメントと末尾カンマはエラー)。
- 読み込み状況は `/status` の `Setting sources` で確認。
- `~/.claude.json` は Claude Code 自身が書くファイルで、通常は編集しない。

## 主なキー

| キー | 内容 |
|---|---|
| `permissions.allow` / `ask` / `deny` | 許可/確認/拒否のルール配列 |
| `permissions.defaultMode` | `default` / `acceptEdits` / `plan` / `auto` / `dontAsk` / `bypassPermissions` |
| `permissions.additionalDirectories` | 追加でアクセスを許すディレクトリ |
| `env` | 全セッションに適用する環境変数 |
| `model` | 既定モデル(`--model` や `ANTHROPIC_MODEL` が優先) |
| `hooks` | フック設定(`05-hooks.md` 参照) |
| `statusLine` | ステータスラインのコマンド |
| `enabledPlugins` / `outputStyle` / `language` ほか | プラグイン、出力スタイル、言語など |

- `auto` と `bypassPermissions` は、プロジェクト/ローカル設定からは有効にならない(ユーザー/管理設定か `--permission-mode` で指定)。
- `permissions.disableBypassPermissionsMode: "disable"` で bypass モードを禁止できる。

## 権限ルールの書き方

形式は `Tool` または `Tool(specifier)`。

| ツール | 例 | 意味 |
|---|---|---|
| Bash | `Bash(npm run *)` | `npm run` で始まるコマンド(`*` はサブコマンドの後に) |
| Bash | `Bash(git *)` | すべての git コマンド |
| Read | `Read(./.env)` / `Read(./secrets/**)` | `.env` / `secrets/` 配下 |
| Edit | `Edit(/docs/**)` | プロジェクトの `docs/` 配下の編集 |
| WebFetch | `WebFetch(domain:example.com)` | そのドメイン |
| MCP | `mcp__puppeteer__*` | そのサーバーの全ツール |
| Agent | `Agent(Explore)` | 指定サブエージェント(deny で無効化) |

パスの接頭辞: `//path` は絶対パス、`~/path` はホーム相対、`/path` は設定ファイルのプロジェクトルート相対、`./path` は現在のディレクトリ相対。

## 評価順序(重要)

- **deny → ask → allow の順で評価され、最初に一致したものが結果になる。** 具体性は順序を変えない。
- 広い deny(`Bash(aws *)`)は、より狭い allow(`Bash(aws s3 ls)`)があっても優先される。
- どこかの設定レベルの deny は、他のファイルの allow でも上書きできない。
- PreToolUse フックの `"allow"` は deny/ask ルールを回避できない。`exit 2` のフックは allow ルールがあってもブロックする。

## 注意点

- `Bash(git push *)` は `git -C . push` に一致せず、`Bash(curl *)` は `/usr/bin/curl` に一致しません。**ルールはセキュリティ境界ではない**ので、確実に制限したい場合はサンドボックスを使います。
- Edit ルールは組み込みの編集ツール全般をカバーします。`Write(...)` ではなく `Edit(...)` で書きます。
- Read の deny は `cat` やリダイレクトも止めますが、スクリプト内部の読み込みは止められません。

## 配置場所(使うときに、どこに置くか)

| 範囲 | 置く場所 | 共有 | 使いどころ |
|---|---|---|---|
| プロジェクト(共有) | `<プロジェクト>/.claude/settings.json` | ○(Git でコミット) | チーム共通の権限・フック・環境変数。**基本はここ** |
| プロジェクト(個人用) | `<プロジェクト>/.claude/settings.local.json` | ×(gitignore) | 自分だけの例外(「今後は確認しない」で自動追記される許可もここ) |
| ユーザー(全プロジェクト共通) | `~/.claude/settings.json` | × | 個人の既定(モデル、`auto` / `bypassPermissions` などのモード設定) |
| 組織(管理) | `managed-settings.json`、MDM など | 組織全員 | 最優先で強制する設定 |

```text
<プロジェクト>/
└── .claude/
    ├── settings.json         ← チーム共通(コミット)
    └── settings.local.json   ← 個人用(gitignore)
~/.claude/settings.json       ← (任意)ユーザー共通
```

- **優先順位(高い順): 管理 > CLI(`--settings`)> ローカル > プロジェクト共有 > ユーザー。** `permissions.allow` などのリストは、複数ファイルのものが**結合**されます。
- `auto` と `bypassPermissions` は、プロジェクト/ローカル設定からは有効になりません(ユーザー/管理設定か、`--permission-mode` で指定)。
- `~/.claude.json` は、Claude Code 自身が書くファイルです。通常は編集しません。
- 変更は再起動不要で反映されます。読み込み状況は `/status` の `Setting sources` で確認します。
- 雛形の入手元: `../templates/settings/settings.json`(権限のみ)、`../project-template/.claude/settings.json`(権限 + フック登録)。

---

## テンプレートと使い方

- テンプレート: [`../templates/settings/settings.json`](../templates/settings/settings.json)

### 使い方(手順)

1. チーム共有なら `.claude/settings.json`、個人用なら `.claude/settings.local.json` / `~/.claude/settings.json` に置く。
2. `allow` / `ask` / `deny` を自分のプロジェクトに合わせて書き換える(`.env` の読み取り禁止など)。
3. JSON は厳格(コメントと末尾カンマはエラー)。
4. `/status` の `Setting sources` で読み込み状況を確認する。
5. 確実に制限したいものはサンドボックスやフックと併用する(権限ルールはセキュリティ境界ではない)。
