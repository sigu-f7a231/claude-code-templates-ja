# プロジェクト一式の雛形(工程別ワークフロー)

新しいプロジェクトに**まるごとコピー**して使う雛形です。工程(要件整理 → 計画 → 実装 → テスト → レビュー → コミット → リリース)を、Claude Code の各機能に分けて組み合わせています。
解説は [`../read/12-project-template.md`](../read/12-project-template.md)、導入から公開前までの手引きは [`../read/13-from-instruction-to-release.md`](../read/13-from-instruction-to-release.md)、最初に貼る指示文は [`../prompts/`](../prompts/README.md) にあります。

## 構成(このフォルダ = 自分のプロジェクトのルートに置く形)

```text
project-template/
├── CLAUDE.md                     概要・Skills 一覧・ドキュメントの置き場所・Rules への案内
├── .claude/
│   ├── settings.json             権限(allow / ask / deny)+ フック登録
│   ├── skills/                   工程別の Skills(7つ)
│   │   ├── spec/                 /spec          要件整理 → docs/spec.md
│   │   ├── plan-tasks/           /plan-tasks    計画・タスク分解 → docs/plan.md
│   │   ├── implement/            /implement     計画の1タスクを実装
│   │   ├── test/                 /test          テスト実行と修正
│   │   ├── review/               /review        差分のレビュー(読み取り専用)
│   │   ├── commit/               /commit        コミット(push はしない)
│   │   └── release/              /release       公開前チェック(公開操作は人が行う)
│   ├── rules/                    Rules(7つ)
│   │   ├── tech-stack.md         技術スタック
│   │   ├── commands.md           よく使うコマンド(Skills・Subagents が参照)
│   │   ├── code-style.md         コード規約
│   │   ├── work-rules.md         作業ルール
│   │   ├── cautions.md           注意事項・落とし穴
│   │   ├── workflow-docs.md      docs/** の書き方(パス限定)
│   │   └── testing.md            テストの書き方(テストファイル限定)
│   ├── agents/                   Subagents
│   │   ├── researcher.md         読み取り専用の調査役
│   │   └── test-runner.md        テスト実行・失敗原因の整理役
│   └── hooks/                    Hooks のスクリプト
│       ├── block-push.sh         git push をブロック
│       ├── protect-files.sh      秘密情報・ロックファイルの編集をブロック
│       └── show-progress.sh      開始・再開・圧縮後に未完了タスクを伝える
├── docs/
│   └── workflow.md               作業の流れを1枚にまとめた手順書(ルール・チェックリスト)
└── optional/                     任意(必要なときだけ)
    ├── skills/plan-to-issues/    計画のタスクを GitHub Issue にする Skill
    └── plugin/                   一式を1つのプラグインにまとめる手順と plugin.json
```

`optional/` 以外は、そのままプロジェクトにコピーします。`optional/` は、必要になったときに、必要な分だけ使います。

## 導入の手順

1. **コピーする。** `CLAUDE.md`、`.claude/`、`docs/` を、自分のプロジェクトのルートにコピーする(`optional/` は必要なときだけ)。
2. **【 】を埋める。**
   - `CLAUDE.md`(概要)
   - `.claude/rules/` の5つ(技術スタック、コマンド、コード規約、作業ルール、注意事項)
   - `.claude/settings.json`(`allow` / `deny` を、自分のコマンドに合わせる)
   - Skills の `allowed-tools`(`test`、`release`)
3. **実行権限を付ける。** `chmod +x .claude/hooks/*.sh`(`jq` が必要)。
4. **git リポジトリにする。** `git init`(`/review` と `/commit` が使う)。
5. **確認する。** Claude Code を起動し、`/hooks` でフックが認識されていること、`/` でスキルが一覧に出ること、`/context all` の **Memory files** で `CLAUDE.md` と Rules が出ていることを確認する。
6. **進める。** `../read/13-from-instruction-to-release.md` の Step 0 から。最初の指示は `../prompts/00-first-instruction.md`。

## 役割分担

| やりたいこと | 使うもの | このセットでの例 |
|---|---|---|
| 毎回の前提(概要・案内) | CLAUDE.md | 概要、Skills 一覧、ドキュメントの場所 |
| 毎回の前提(中身) | Rules(`paths` なし) | 技術スタック、コマンド、コード規約、作業ルール、注意事項 |
| 特定ファイルだけの規約 | Rules(`paths` あり) | `docs/**` の書き方、テストの書き方 |
| 繰り返す手順 | Skills | `/spec` 〜 `/release` |
| 独立した調査・実行 | Subagents / `context: fork` | `researcher`、`test-runner`、`/review` |
| 確実に止める・伝える | Hooks / permissions | `git push` のブロック、進捗の再提示 |
| 許可・拒否の設定 | Settings | テストは許可、`push` や `.env` の読み取りは拒否 |
| 複数プロジェクトへ配る | Plugins(`optional/plugin/`) | `dev-workflow` |

## 導入後の確認チェックリスト

Claude Code 上での動作は、雛形側では確認できていないため、導入後に次を確認してください。

| 確認すること | 方法 | 期待する結果 |
|---|---|---|
| Rules が読み込まれている | `/context all` の **Memory files** | `CLAUDE.md` と、`paths` なしの Rules 5つが出ている |
| Skills が使える | `/` を入力 | `spec`、`plan-tasks`、`implement`、`test`、`review`、`commit`、`release` が一覧に出る |
| Hooks が認識されている | `/hooks` | `PreToolUse`(Bash、Edit\|Write)と `SessionStart` が出る |
| `git push` がブロックされる | 「`git push` を実行して」と頼む | 実行されず、ブロックの理由が返る |
| `.env` の編集がブロックされる | 「`.env` に1行追加して」と頼む | 実行されず、ブロックの理由が返る |
| 進捗が再提示される | `docs/plan.md` に `- [ ]` のタスクを書いて、セッションを再起動 | 未完了タスクが表示される |
| Skill が動く | 小さな機能で `/spec` から試す | 質問 → 回答 → `docs/spec.md` が作られる |

## この雛形フォルダ自体について

- `project-template/.claude/` は、**実際に効く設定**です(権限、フック、Skills)。このフォルダ内で Claude Code を起動すると、`git push` の拒否などが有効になります。雛形を編集するだけなら、リポジトリのルート(`test1/`)で起動してください。
- 雛形を直したときは、`templates/` に対応する雛形(`hooks/`、`settings/` など)がないか確認してください(Rules の5つは、ここだけにあります)。

## 注意

- コマンドを変えるときは、`rules/commands.md` に加えて、`settings.json` の `allow` と Skills の `allowed-tools` も合わせて直します。
- フックのスクリプトは自分のユーザー権限で実行されます。使う前に内容を確認してください。
- `.claude/settings.json` は、権限とフック登録の**両方**を含みます。`templates/hooks/settings-hooks.json`(フックだけの雛形)と二重に登録しないでください。
- この一式は、公式ドキュメントの仕様に沿って私が作成した例です。工程の分け方・ルール・フックの条件は、プロジェクトに合わせて調整してください。
- Claude Code 上で、一式を通しで動かしてはいません。
