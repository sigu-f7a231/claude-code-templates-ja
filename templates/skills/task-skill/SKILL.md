---
name: 【task-name】
description: 【何をするか】。【いつ使うか】
argument-hint: [【引数のヒント。例: issue-number】]
disable-model-invocation: true
allowed-tools: Bash(git status *) Bash(git diff *)
---

<!--
  タスク型 Skill テンプレート(デプロイ・コミット・Issue 修正など。手動実行向き)
  置き場所: .claude/skills/<task-name>/SKILL.md
  ポイント:
    - disable-model-invocation: true で Claude の自動実行を禁止(副作用のある作業は手動限定に)。
    - allowed-tools は、そのターン中に確認なしで使えるツールを追加する(制限ではない)。
    - 引数は $ARGUMENTS / $0 / $1 などで受け取る。`/task-name 123` のように呼び出す。
    - サブエージェントで隔離実行するなら context: fork(任意で agent: Explore など)を追加。
      その場合は会話履歴が見えないので、自己完結した指示にする。
    - 本文中の「感嘆符 + バッククォートで囲んだコマンド」は、実行時にシェルで実行され出力で置換される(非ゼロ終了で中断)。
      注意: この書式は本文のどこにあっても実行される。説明文やコメントの中に書かないこと。
-->

【引数 `$ARGUMENTS` を使うタスクの説明。例: GitHub Issue $ARGUMENTS を、コーディング規約に従って修正する】

## 現在の状態

- 変更ファイル: !`git status --short`

## 手順

1. 【例: 関連するコードを調べる】
2. 【例: 修正を実装する】
3. 【例: テストを実行して通ることを確認する】
4. 【例: 変更内容を要約する】

## 出力形式

- 【例: 変更の目的、影響範囲、リスクを各1〜2文で報告する】
