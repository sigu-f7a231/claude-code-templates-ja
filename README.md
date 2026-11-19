# Claude Code 学習・テンプレート集

Claude Code の公式ドキュメント(https://code.claude.com/docs/ )をもとに、**読む資料**、**1ファイルずつの雛形**、**プロジェクト一式の雛形**、**指示文の雛形**をまとめたものです(2026-11-19 時点)。

## どこに何があるか

| フォルダ | 役割 | 使い方 |
|---|---|---|
| [`read/`](read/00-index.md) | **解説**(読む資料)。CLAUDE.md、Rules、Skills、Hooks、Subagents、Settings、MCP、Plugins の書き方・使い方と、導入から公開前までの手引き | 最初に目次 `read/00-index.md` から読む |
| [`templates/`](templates/README.md) | **資料別テンプレート**。ファイル1つずつの雛形(書き方の確認用) | 書き方を忘れたとき、1つだけ作りたいときに見る |
| [`project-template/`](project-template/README.md) | **プロジェクト一式の雛形**。工程別ワークフロー(CLAUDE.md + `.claude/` 一式 + `docs/`) | 新しいプロジェクトに**まるごとコピー**して使う |
| [`prompts/`](prompts/README.md) | **指示文の雛形**。最初の指示と、種類別(静的ページ・LP・HP・Web アプリ・スマホアプリなど)、Skills の呼び出し | Claude Code に**貼り付けて**使う |

```text
test1/
├── README.md                ← このファイル(全体の地図)
├── read/                    解説(14本: 目次 + 13本)
├── templates/               資料別テンプレート(1ファイルずつ)
├── project-template/        プロジェクト一式の雛形(コピー用)
└── prompts/                 指示文の雛形(貼り付け用)
```

## 目的別の入り口

| やりたいこと | 見る場所 |
|---|---|
| Claude Code の機能を理解したい | `read/00-index.md` → `read/10-overview-and-others.md` |
| Rules / Skills / Hooks などの書き方を調べたい | `read/02`〜`read/09`、雛形は `templates/` |
| 新しいプロジェクトを、工程別ワークフローで進めたい | `project-template/README.md` → `read/13-from-instruction-to-release.md` |
| Claude Code に最初の指示を出したい | `prompts/00-first-instruction.md` と、種類別の指示 |

## フォルダの使い分けの原則

- **`templates/` は「1つの機能の書き方」、`project-template/` は「それらを組み合わせた一式」です。** 同じ内容を2か所に持たないため、技術スタック・コマンド・コード規約・作業ルール・注意事項の Rules は `project-template/` にだけあります。
- **`read/` は読むもの、それ以外は使うものです。** 手引き(`read/13`)は、雛形集のフォルダを参照します。自分のプロジェクトにコピーするのは、`project-template/` の中身です。
- 解説の書き方・コツの一部は、公式の記述から私が整理したものです。各ファイルの注記を確認してください。

## 注意

- 動作確認の範囲: フックのスクリプトは、サンプルの入力で終了コードを確認しました。Claude Code 上で、Skills・Rules・Hooks を通しで動かしてはいません。確認の手順は `project-template/README.md` の「導入後の確認チェックリスト」にあります。
- ツールやモデルの仕様は変わります。最新の公式ドキュメントも確認してください。
