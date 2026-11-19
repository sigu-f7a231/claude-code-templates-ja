# MCP(外部サービス連携)

## 何か

Claude Code を外部のツール・DB・API に接続するオープン標準(Model Context Protocol)です。接続すると、Claude がそのシステムを直接読み書きできます。

## 追加方法

```bash
# リモート(HTTP)。リモートサーバーに推奨
claude mcp add --transport http notion https://mcp.notion.com/mcp
claude mcp add --transport http secure-api https://api.example.com/mcp \
  --header "Authorization: Bearer your-token"

# ローカルプロセス(stdio)。`--` の後がサーバーのコマンド
claude mcp add --env AIRTABLE_API_KEY=YOUR_KEY --transport stdio airtable \
  -- npx -y airtable-mcp-server

# JSON で追加
claude mcp add-json <name> '<json>'
```

- SSE は非推奨(HTTP が使えるなら HTTP を使う)。

## スコープ

| スコープ | 読み込み先 | チーム共有 | 保存先 |
|---|---|---|---|
| local(既定) | 現在のプロジェクトのみ | しない | `~/.claude.json` |
| project | 現在のプロジェクトのみ | する(コミット) | プロジェクトルートの `.mcp.json` |
| user | 自分の全プロジェクト | しない | `~/.claude.json` |

優先順位は local > project > user > プラグイン > claude.ai コネクタ(フィールドのマージはせず、最優先のエントリを丸ごと使う)。`--scope local|project|user` で指定します。

## `.mcp.json`(プロジェクト共有)

```json
{
  "mcpServers": {
    "api-server": {
      "type": "http",
      "url": "${API_BASE_URL:-https://api.example.com}/mcp",
      "headers": {
        "Authorization": "Bearer ${API_KEY}"
      }
    }
  }
}
```

- `${VAR}` と `${VAR:-default}` が使える(`command` / `args` / `env` / `url` / `headers` で展開)。
- 認証情報系の変数(`ANTHROPIC_API_KEY` など)は、リモートの `url`/`headers` では空として扱われる(リポジトリ側が資格情報を外部に送れないようにするため)。
- stdio の `command`/`args` では `${CLAUDE_PROJECT_DIR}` が使える(project/local では `${CLAUDE_PROJECT_DIR:-.}` のように既定値が必要)。
- `type` を省略して `url` だけだと stdio 扱いになりスキップされる。

## 管理コマンド

| コマンド | 内容 |
|---|---|
| `claude mcp list` | 一覧と接続状態 |
| `claude mcp get <name>` | 詳細 |
| `claude mcp remove <name>` | 削除 |
| `/mcp` | セッション内で状態確認・認証 |

## セキュリティ

- 信頼できるサーバーだけを追加する(外部コンテンツを取得するサーバーは、プロンプトインジェクションの経路になりうる)。
- 対話セッションでは、`.mcp.json` のプロジェクトサーバーは承認を求められる。
- `claude -p` や SDK では、プロジェクトのサーバーが承認なしで読み込まれる。`--strict-mcp-config` などで除外できる(要約情報)。

## 配置場所(使うときに、どこに置くか)

| スコープ | 置く場所 | 共有 | 使いどころ |
|---|---|---|---|
| project | `<プロジェクト>/.mcp.json` | ○(Git でコミット) | チーム共通の接続先。**チームで使うならここ** |
| local(既定) | `~/.claude.json`(そのプロジェクト用の項目) | × | 自分だけ・そのプロジェクトだけ |
| user | `~/.claude.json` | × | 自分の全プロジェクトで使う接続先 |
| プラグイン | プラグインの `.mcp.json` または `plugin.json` 内 | 配布 | プラグインと一緒に配布 |

```text
<プロジェクト>/
├── .mcp.json     ← project スコープ(チーム共有。秘密情報は ${VAR} で環境変数から読む)
└── .gitignore    ← .env などを追記
~/.claude.json    ← local / user スコープ(claude mcp add が書き込む。直接は編集しない)
```

- project スコープは、手でファイルを置くか、`claude mcp add --scope project ...` で作ります。local / user スコープは `claude mcp add`(`--scope local|user`)で追加します。
- **秘密情報は `.mcp.json` に直接書かず**、`${API_KEY}` のように環境変数で渡します。
- 優先順位: local > project > user > プラグイン。同じ名前は、最優先の1つが丸ごと使われます。
- 雛形の入手元: `../templates/mcp/.mcp.json`。

---

## テンプレートと使い方

- テンプレート: [`../templates/mcp/.mcp.json`](../templates/mcp/.mcp.json)(HTTP とローカル stdio の例)

### 使い方(手順)

1. チーム共有なら、プロジェクトルートに `.mcp.json` を置く(またはコマンドで追加: `claude mcp add --transport http <name> <url> --scope project`)。
2. 秘密情報は直接書かず、`${VAR}` で環境変数から読む。
3. `claude mcp list` / `/mcp` で接続状態を確認する(認証が必要なら `/mcp` から)。
4. 信頼できるサーバーだけを追加する。
