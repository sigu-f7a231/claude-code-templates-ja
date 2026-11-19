# Plugins(プラグイン)

## 何か

Skills、Agents、Hooks、MCP サーバーなどを**1つのインストール単位**にまとめたものです。マーケットプレイス(カタログ)から入れるか、自作して配布します。別のリポジトリでも同じ設定が必要になったら、プラグイン化を検討します。

## ディレクトリ構成

```text
my-plugin/
├── .claude-plugin/
│   └── plugin.json        # マニフェスト(ここにはこれだけ)
├── skills/
│   └── review/SKILL.md
├── agents/
│   └── reviewer.md
├── hooks/
│   └── hooks.json
├── commands/              # 単体の .md コマンド
├── output-styles/
├── bin/                   # Bash の PATH に追加される実行ファイル
├── scripts/
└── .mcp.json
```

`plugin.json` 以外はすべてプラグインのルートに置きます。

## `plugin.json`(必須は `name` のみ、kebab-case)

```json
{
  "name": "deploy-tools",
  "version": "1.0.0",
  "description": "Deployment commands and a review agent",
  "author": { "name": "Example Team" },
  "license": "MIT",
  "keywords": ["deployment"]
}
```

- マニフェスト自体も省略可能。コンポーネントは `name` で名前空間化される(`deploy-tools:reviewer`、`/deploy-tools:review`)。
- 予約: `claude-` や `anthropic-` で始まる名前は不可。
- コンポーネントのパスは `./` で始まり、プラグインのルート内に収める。
- 変数: `${CLAUDE_PLUGIN_ROOT}`(インストール先)、`${CLAUDE_PLUGIN_DATA}`(永続データ)、`${CLAUDE_PROJECT_DIR}`。
- 検証: `claude plugin validate ./my-plugin`(`--strict` で警告もエラー扱い)。

## インストールと管理

```text
/plugin                                              # パネルを開く
/plugin marketplace add anthropics/claude-plugins-official
/plugin install commit-commands@claude-plugins-official
/plugin enable | /plugin disable | /plugin uninstall
/reload-plugins
```

シェルからは `claude plugin install <name>@<marketplace> --scope project` など。`marketplace add` は GitHub(`owner/repo`)、git URL、ローカルディレクトリ、`https://` の `marketplace.json` を受け付けます。

## セキュリティ

プラグインは**自分のユーザー権限でコードを実行できます**。知らないマーケットプレイスのものは、内容を確認してから入れます。

## 配置場所(使うときに、どこに置くか)

プラグインには、「自作して配る側」と「入れて使う側」で置き場所が違います。

### 自作する場合(プラグインのソース)

```text
<プラグイン>/                       ← 独立したフォルダ/リポジトリにする(プロジェクトの .claude/ の中には置かない)
├── .claude-plugin/
│   └── plugin.json              ← ここに置くのはこのファイルだけ
├── skills/ agents/ hooks/ commands/ output-styles/ scripts/   ← それ以外はプラグインのルートに置く
└── .mcp.json
```

- 配布先: GitHub のリポジトリ、またはマーケットプレイス(`.claude-plugin/marketplace.json` を持つリポジトリ)。
- プロジェクトの `.claude/` ではなく、**プラグインのルート**に `skills/` などを置きます(呼び出し名は名前空間付きの `/プラグイン名:スキル名`)。
- 雛形の入手元: `../templates/plugin/plugin.json`、`../project-template/optional/plugin/`(一式をプラグイン化する手順)。

### 入れて使う場合

| 範囲 | 有効にする設定の場所 | 共有 |
|---|---|---|
| ユーザー | `~/.claude/settings.json` の `enabledPlugins` | × |
| プロジェクト | `<プロジェクト>/.claude/settings.json` の `enabledPlugins` | ○ |
| ローカル | `<プロジェクト>/.claude/settings.local.json` の `enabledPlugins` | × |

- インストールは `/plugin install <名前>@<マーケットプレイス>`(中身のファイルは Claude Code が管理するので、自分では置かない)。

---

## テンプレートと使い方

- テンプレート: [`../templates/plugin/plugin.json`](../templates/plugin/plugin.json)

### 使い方(手順)

1. `my-plugin/.claude-plugin/plugin.json` を作る(`.claude-plugin/` にはこのファイルだけ)。
2. `skills/`、`agents/`、`hooks/hooks.json`、`.mcp.json` などを、プラグインのルートに置く。
3. `claude plugin validate ./my-plugin` で検証する。
4. マーケットプレイスに載せるか、ローカルで試す。インストールは `/plugin install <name>@<marketplace>`。
