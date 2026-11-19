# プロジェクト一式の雛形(工程別ワークフロー)の解説

雛形本体: [`../project-template/`](../project-template/README.md)(コピーして使う一式)
指示文: [`../prompts/`](../prompts/README.md)

要件整理・計画・実装・テスト・レビュー・コミット・リリースを工程ごとの Skills に分け、`/スキル名` で呼び出して進める構成です。毎回長い指示を書かずに、同じ手順を再現できます。Skills だけでなく、CLAUDE.md、Rules、Subagents、Hooks、Settings を、同じ工程に合わせて組み合わせています。

## 1. 全体の流れ

```text
/spec → /plan-tasks → ( /implement → /test → /review → /commit ) を繰り返す → /release
        ↑ 承認              ↑ タスクごとに1サイクル                              ↑ 公開は人が行う
```

- 計画(`docs/plan.md`)にタスクを溜め、**どれをやるかは人が `/implement <番号>` で指示**します。
- 各工程の終わりに Claude が報告して止まります。**次へ進むかは人が決めます。**
- 手順の詳細(指示文つき)は [`13-from-instruction-to-release.md`](13-from-instruction-to-release.md)、ルールとチェックリストの1枚は [`../project-template/docs/workflow.md`](../project-template/docs/workflow.md) にあります。

## 2. 構成

| 場所(`project-template/`) | 機能 | 役割 |
|---|---|---|
| `CLAUDE.md` | CLAUDE.md | 概要、Skills 一覧、ドキュメントの置き場所、Rules への案内 |
| `.claude/rules/`(5つ) | Rules(パスなし) | 技術スタック、コマンド、コード規約、作業ルール、注意事項(毎回読み込み) |
| `.claude/rules/`(2つ) | Rules(パス限定) | `docs/**` の書き方、テストの書き方 |
| `.claude/skills/`(7つ) | Skills | 工程別の手順 |
| `.claude/agents/`(2つ) | Subagents | 調査役、テスト実行役 |
| `.claude/hooks/`(3つ)+ `settings.json` | Hooks / Settings | 確実なブロックと進捗の再提示、権限 |
| `docs/` | ドキュメント | 作業の流れ(`workflow.md`) |
| `optional/` | 任意 | `plan-to-issues` Skill、プラグイン化の手順 |

## 3. 工程別の Skills

| Skill | 呼び出し | 役割 | 実行方法 | 設計上のポイント |
|---|---|---|---|---|
| `spec` | `/spec <概要>` | 要件を `docs/spec.md` に文書化 | 手動のみ | 質問 → 回答 → 文書化。推測した内容は「【仮定】」と明記。コードは変更しない |
| `plan-tasks` | `/plan-tasks <機能>` | タスク分解を `docs/plan.md` に保存 | 手動のみ | 1タスク=1つの検証可能な変更。承認を待つ。Issue は作らない |
| `implement` | `/implement <番号>` | 計画の1タスクを実装 | 手動のみ | 範囲外の改善をしない。コミットしない |
| `test` | `/test` | テスト実行と修正 | 自動/手動 | `allowed-tools` でテストコマンドを事前許可。テストを弱めて通さない |
| `review` | `/review` | 差分のレビュー | 自動/手動 | `context: fork` + `agent: Explore` で読み取り専用の別コンテキスト。**コミット前**の差分が対象 |
| `commit` | `/commit` | コミット | 手動のみ | `git push` を許可しない。秘密情報の混入を確認 |
| `release` | `/release <版>` | 公開前チェック | 手動のみ | デプロイ・タグ付け・ストア申請はしない(手順の提示まで) |

- 副作用のある作業(ファイル変更、コミット、公開)は `disable-model-invocation: true` で、Claude の自動実行を禁止しています。
- 各コマンドの日本語での意味・引数・書き方は、手引きの冒頭「コマンド早見表」にあります。覚え方は「作る(`/implement`)→ 確かめる(`/test`)→ 点検する(`/review`)→ 記録する(`/commit`)」です。

## 4. 誰が何を動かすか

| 動かすもの | きっかけ | 例 |
|---|---|---|
| Skills(`/名前`) | **人が呼ぶ** | `/implement 3`、`/commit` |
| `docs/plan.md` | 動かない。状態を持つファイル | 次にやるタスクの一覧。完了すると `[x]` |
| CLAUDE.md、Rules(パスなし) | **自動**(毎回) | 技術スタック、コマンド、作業ルール など |
| Rules(パス限定) | **自動**(対象ファイルを触ったとき) | `docs/**`、テストファイル |
| Hooks、権限設定 | **自動**(イベント) | `git push` のブロック、再開時の進捗表示 |
| Subagents | 人が頼む / Claude が委任 | `researcher`、`test-runner` |

## 5. 役割分担の考え方(同じ「push しない」でも)

| 層 | 書いてあること | 強制力 |
|---|---|---|
| `/commit`(Skill) | 「`git push` はしない」、`allowed-tools` に含めない | 弱い(指示) |
| `rules/work-rules.md` | 「`git push` は人が行う」 | 弱い(コンテキスト) |
| `settings.json` の `permissions.deny` | `Bash(git push *)` を拒否 | 強い(ルール。書き方によってはすり抜けられる) |
| `block-push.sh`(Hook) | `exit 2` でブロック | 強い(スクリプト。完全ではない) |

複数の層で重ねるのが確実です。ただし、どの層も `git -C . push` のような別の書き方やスクリプト経由の実行を完全には防げません。確実に制限したい場合は、サンドボックスやリモート側のブランチ保護も併用してください。

## 6. 設計の選択

### Skills と Subagents の使い分け

| 観点 | Skill | Subagent |
|---|---|---|
| 会話の文脈 | 引き継ぐ(`fork` なしの場合) | 引き継がない(独立) |
| 向いている工程 | 実装・計画など、対話しながら進めるもの | レビュー・調査など、出力が多く独立して行えるもの |
| 呼び出し | `/名前` | 自然言語、`@agent-名前` |

`/test`(Skill)は失敗を見ながら修正まで行い、`test-runner`(Subagent)は実行と原因の整理だけを行い要約を返します。

### 内容の置き場所

| 内容 | 置く場所 | 理由 |
|---|---|---|
| 技術・コマンド・コード規約・作業ルール・注意事項 | Rules(`paths` なし) | `CLAUDE.md` を短く保ち、トピックごとに更新できる |
| 特定ファイルだけの規約 | Rules(`paths` あり) | 該当ファイルを触るときだけ読み込む(コンテキストの節約) |
| 繰り返す手順 | Skills | 必要なときだけ読み込み、引数を受け取れる |
| 必ず守らせたいこと | Hooks / permissions | 指示ではなく、確実に実行される |

- コマンドを変えるときは、`rules/commands.md`、`settings.json` の `allow`、Skills の `allowed-tools` を合わせて直します。
- `paths` を付けた Rules は、そのファイルを触る前(計画や質問の段階)には読み込まれません。計画の段階でも守らせたいものは、`paths` なしにします。

## 7. 導入の手順

[`../project-template/README.md`](../project-template/README.md) の「導入の手順」に従います。要点は次のとおりです。

1. `CLAUDE.md`、`.claude/`、`docs/` を自分のプロジェクトにコピーする。
2. 【 】を埋める(CLAUDE.md、Rules の5つ、`settings.json`、Skills の `allowed-tools`)。
3. `chmod +x .claude/hooks/*.sh`、`git init`(`jq` が必要)。
4. `/hooks`、`/`(スキル一覧)、`/context all`(Memory files)で、読み込みを確認する。
5. 最初の指示(`../prompts/00-first-instruction.md`)から、手引きの Step 0〜8 に沿って進める。

## 8. 呼び出し方の注意

- **メッセージの先頭に `/スキル名` を書く**と直接実行されます。文中に書くだけでは直接実行になりません。
- 引数はスペース区切りで続けます(`/implement 3`、`/release 1.2.0`)。
- スキルを新しく作った後、一覧に出ない場合は `/reload-skills` を実行するか、再起動します。
- 同じ名前のスキルが複数の場所にあると、優先順位で上書きされます(管理 > ユーザー > プロジェクト)。
- スキルの本文では、感嘆符 + バッククォートで囲んだコマンドは、**本文のどこにあっても実行されます**(HTML コメント内の説明例でも)。説明として書くときは、この書式をそのまま書かないでください。

## 9. カスタマイズ

| やりたいこと | 方法 |
|---|---|
| 工程を足す(例: 設計、デプロイ) | 同じ形式で `SKILL.md` を追加する |
| 工程を減らす(小規模) | `/spec` と `/plan-tasks` を省き、`/implement` に直接要件を書く(手引きの「流れを短くしたいとき」を参照) |
| 種類別(LP、アプリ)の差を出す | 各スキルの本文や Rules に、種類ごとの確認項目を足す(例: `/review` にレスポンシブの観点) |
| 別の役割として隔離したい | Skill に `context: fork` と `agent:` を付けるか、Subagent にする |
| タスクを Issue にしたい | `optional/skills/plan-to-issues/` を `.claude/skills/` に追加する(`gh` が必要。作成前に確認を取る) |
| 複数プロジェクトで使い回す | `~/.claude/skills/` に置くか、プラグイン化する(`optional/plugin/`、`09-plugins.md`) |

## 10. 計画・要件・Issue の扱い

- **`/spec`**: 質問 → 回答 → 文書化。最大5個の質問(選択肢・おすすめ案つき)をまとめて行い、人の回答を受けて `docs/spec.md` を書きます。推測した項目は「【仮定】」で事実と区別し、依頼されていない要件は足しません。会話が新しくなった場合は、Step 1〜2 の合意が見えないため、Rules に書くか、`/spec` にファイルとして渡します(ひな形: `../prompts/11-spec-input.md`)。
- **`/plan-tasks`**: `docs/spec.md` と既存コードを読んで、タスクの下書きを自動で作り、`docs/plan.md` に保存して承認を待ちます。内容の確認と承認は人が行います。
- **GitHub Issue は自動では作られません。** 任意の Skill `plan-to-issues` を追加した場合も、作成前に一覧を提示して確認を取り、作成後に Issue 番号を `plan.md` に書き戻します。`plan.md` と Issue の両方を更新し続けるとずれやすいため、どちらを正とするかを先に決めます。
- 送り方の記載例(最小・標準・ファイル渡し・種類別・避けたい例)と、Step 6 の各工程の動き(報告の例を含む)は、手引きの Step 4〜6 にあります。

## 11. 動作確認の範囲

- フックのスクリプト3つは、サンプルの入力を渡して終了コードを確認しました(`git push` と `.env` の編集は `exit 2`、それ以外は `exit 0`。`show-progress.sh` は未完了タスクを表示)。
- Skills、Rules、Subagents、Hooks の登録が、実際の Claude Code 上で期待どおり動くかは、**未確認**です。導入後に、手順4の確認を行ってください。
- 工程の分け方、ルールの内容、文面は、公式ドキュメントの仕様に沿って私が作成した例です。公式が定めた構成ではありません。

## 配置場所(使うときに、どこに置くか)

`../project-template/` の中身を、**自分のプロジェクトのルート**に、次のようにコピーします。

| コピー元(`project-template/`) | コピー先(自分のプロジェクト) | 備考 |
|---|---|---|
| `CLAUDE.md` | `<プロジェクト>/CLAUDE.md` | 概要を埋める |
| `.claude/settings.json` | `<プロジェクト>/.claude/settings.json` | 権限とフック登録。すでに `settings.json` がある場合は、`permissions` と `hooks` を**マージ**する(上書きしない) |
| `.claude/rules/*.md`(7つ) | `<プロジェクト>/.claude/rules/` | 【 】を埋める |
| `.claude/skills/*/`(7つ) | `<プロジェクト>/.claude/skills/` | `test`、`release` の `allowed-tools` を直す |
| `.claude/agents/*.md`(2つ) | `<プロジェクト>/.claude/agents/` | |
| `.claude/hooks/*.sh`(3つ) | `<プロジェクト>/.claude/hooks/` | `chmod +x`、`jq` が必要 |
| `docs/workflow.md` | `<プロジェクト>/docs/workflow.md` | 作業の流れの手順書 |
| `optional/skills/plan-to-issues/` | `<プロジェクト>/.claude/skills/plan-to-issues/` | 任意。Issue 運用をするときだけ |
| `optional/plugin/` | (プラグインとして別フォルダにする) | 任意。複数プロジェクトに配るとき |

```text
<自分のプロジェクト>/                   ← コピー後の形
├── CLAUDE.md
├── .gitignore                          ← .env、CLAUDE.local.md、.claude/settings.local.json を追記
├── docs/
│   ├── workflow.md                     ← コピー
│   ├── spec.md                         ← /spec が作る
│   └── plan.md                         ← /plan-tasks が作る
└── .claude/
    ├── settings.json
    ├── rules/ skills/ agents/ hooks/
```

- **`optional/` は、そのままコピーしません。** 必要なものだけを、上の表のとおりに配置します。
- コピーしないもの: `project-template/README.md`(雛形の説明)。
- `.claude/` は、**プロジェクトのルート直下**に置きます(サブディレクトリの `.claude/` は、そのサブディレクトリで作業するときだけ読み込まれます)。
- 手引き(`13-from-instruction-to-release.md`)は雛形集の中に置いたままにし、必要に応じて参照します。
